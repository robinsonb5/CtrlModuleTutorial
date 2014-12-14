library STD;
use STD.TEXTIO.ALL;
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_TEXTIO.all;
use IEEE.NUMERIC_STD.ALL;


entity Virtual_Toplevel is
	generic
	(
		colAddrBits : integer := 8;
		rowAddrBits : integer := 12
	);
	port(
		reset : in std_logic;
		CLK : in std_logic;
		
		DRAM_ADDR	: out std_logic_vector(rowAddrBits-1 downto 0);
		DRAM_BA_0	: out std_logic;
		DRAM_BA_1	: out std_logic;
		DRAM_CAS_N	: out std_logic;
		DRAM_CKE	: out std_logic;
		DRAM_CS_N	: out std_logic;
		DRAM_DQ		: inout std_logic_vector(15 downto 0);
		DRAM_LDQM	: out std_logic;
		DRAM_RAS_N	: out std_logic;
		DRAM_UDQM	: out std_logic;
		DRAM_WE_N	: out std_logic;
		
		DAC_LDATA : out std_logic_vector(15 downto 0);
		DAC_RDATA : out std_logic_vector(15 downto 0);
		
		VGA_R		: out std_logic_vector(7 downto 0);
		VGA_G		: out std_logic_vector(7 downto 0);
		VGA_B		: out std_logic_vector(7 downto 0);
		VGA_VS		: out std_logic;
		VGA_HS		: out std_logic;

		RS232_RXD : in std_logic;
		RS232_TXD : out std_logic;

		ps2k_clk_out : out std_logic;
		ps2k_dat_out : out std_logic;
		ps2k_clk_in : in std_logic;
		ps2k_dat_in : in std_logic;
		
		joya : in std_logic_vector(7 downto 0) := (others =>'1');
		joyb : in std_logic_vector(7 downto 0) := (others =>'1');
		joyc : in std_logic_vector(7 downto 0) := (others =>'1');
		joyd : in std_logic_vector(7 downto 0) := (others =>'1');
		joye : in std_logic_vector(7 downto 0) := (others =>'1');

		spi_miso		: in std_logic := '1';
		spi_mosi		: out std_logic;
		spi_clk		: out std_logic;
		spi_cs 		: out std_logic
	);
end entity;

architecture rtl of Virtual_Toplevel is

signal eopixel : std_logic;
signal eoline : std_logic;
signal eoframe : std_logic;
signal vga_X : unsigned(11 downto 0);
signal vga_Y : unsigned(11 downto 0);


-- Internal video signals:
signal vga_red_i : std_logic_vector(7 downto 0);
signal vga_green_i : std_logic_vector(7 downto 0);
signal vga_blue_i	: std_logic_vector(7 downto 0);		
signal vga_vsync_i : std_logic;
signal vga_hsync_i : std_logic;

signal osd_window : std_logic;
signal osd_pixel : std_logic;

signal testpattern : std_logic_vector(1 downto 0);

begin

RS232_TXD<='1';

ps2k_clk_out<='1';	-- Since the Control module only receives keyboard data
ps2k_dat_out<='1';	-- we need to make sure the CLK and Data lines are high Z.

DRAM_CS_N <='1';
DRAM_RAS_N <='1';
DRAM_CAS_N <='1';

spi_cs<='1';
spi_clk<='0';
spi_mosi<='1';


-- Control module

MyCtrlModule : entity work.CtrlModule
	port map (
		clk => CLK,
		reset_n => reset,

		-- Video signals for OSD
		vga_hsync => vga_hsync_i,
		vga_vsync => vga_vsync_i,
		osd_window => osd_window,
		osd_pixel => osd_pixel,

		-- PS2 keyboard
		ps2k_clk_in => ps2k_clk_in,
		ps2k_dat_in => ps2k_dat_in,
		
		-- We leave the mouse disconnected for now
		
		-- DIP switches
		dipswitches(15 downto 2) => open,
		dipswitches(1 downto 0) => testpattern -- Replaces previous binding from the physical DIP switches
	);


-- The core proper

vgamaster : entity work.video_vga_master
	port map (
-- System
		clk => clk,
		clkDiv => X"3", -- 100Mhz / (3+1) = 25 MHz dot clock

-- Sync outputs
		hSync => vga_hsync_i, -- Now internal signals
		vSync => vga_vsync_i,

-- Control outputs
		endOfPixel => eopixel,
		endOfLine => eoline,
		endOfFrame => eoframe,
		currentX => vga_X,
		currentY => vga_Y,

-- Configuration
		xSize => X"320",
		ySize => X"20D",
		xSyncFr => X"290",
		xSyncTo => X"2F0",
		ySyncFr => X"1F4",
		ySyncTo => X"1F6"
	);

process(clk,vga_X,vga_Y)
begin
	if rising_edge(clk) then
		if vga_Y<X"1E0" and vga_X<X"280" then
			-- Instead of sending the test pattern directly to VGA_[R|G|B] we now write it
			-- to internal signals which are merged with the OSD.
			case testpattern is
				when "00" =>
					vga_red_i<=std_logic_vector(vga_X(7 downto 0));
					vga_green_i<=std_logic_vector(vga_Y(7 downto 0));
					vga_blue_i<=vga_X(3)&vga_Y(3)&vga_X(2)&vga_Y(2)&vga_X(1)&vga_Y(1)&vga_X(0)&vga_Y(0);
				when "01" =>
					vga_red_i<=std_logic_vector(not vga_X(7 downto 0));
					vga_green_i<=std_logic_vector(vga_Y(7 downto 0));
					vga_blue_i<=not (vga_X(3)&vga_Y(3)&vga_X(2)&vga_Y(2)&vga_X(1)&vga_Y(1)&vga_X(0)&vga_Y(0));
				when "10" =>
					vga_red_i<=std_logic_vector(vga_X(7 downto 0));
					vga_green_i<=std_logic_vector(not vga_Y(7 downto 0));
					vga_blue_i<=vga_X(3)&vga_Y(3)&vga_X(2)&vga_Y(2)&vga_X(1)&vga_Y(1)&vga_X(0)&vga_Y(0);
				when "11" =>
					vga_red_i<=std_logic_vector(not vga_X(7 downto 0));
					vga_green_i<=std_logic_vector(not vga_Y(7 downto 0));
					vga_blue_i<=not (vga_X(3)&vga_Y(3)&vga_X(2)&vga_Y(2)&vga_X(1)&vga_Y(1)&vga_X(0)&vga_Y(0));
				when others =>
					null;
			end case;
		else
			vga_red_i<=X"00";
			vga_green_i<=X"00";
			vga_blue_i<=X"00";
		end if;
	end if;
end process;


-- Merge the host's VGA output and the OSD output:

overlay : entity work.OSD_Overlay
	port map
	(
		clk => CLK,
		red_in => vga_red_i,
		green_in => vga_green_i,
		blue_in => vga_blue_i,
		window_in => '1',
		osd_window_in => osd_window,
		osd_pixel_in => osd_pixel,
		hsync_in => vga_hsync_i,
		red_out => VGA_R,
		green_out => VGA_G,
		blue_out => VGA_B,
		window_out => open,
		scanline_ena => '0'
	);

VGA_HS <= vga_hsync_i;
VGA_VS <= vga_vsync_i;


end rtl;
