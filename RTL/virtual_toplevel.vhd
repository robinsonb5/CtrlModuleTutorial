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

signal ps2k_divert : std_logic;
signal spi_divert : std_logic;

-- Internal video signals:
signal vga_red_i : std_logic_vector(7 downto 0);
signal vga_green_i : std_logic_vector(7 downto 0);
signal vga_blue_i	: std_logic_vector(7 downto 0);		
signal scalered : unsigned(4 downto 0);
signal scalegreen : unsigned(4 downto 0);
signal scaleblue : unsigned(4 downto 0);
signal vga_vsync_i : std_logic;
signal vga_hsync_i : std_logic;

signal osd_window : std_logic;
signal osd_pixel : std_logic;

signal testpattern : std_logic_vector(1 downto 0);
signal scanlines : std_logic;

begin

RS232_TXD<='1';

DRAM_CS_N <='1';
DRAM_RAS_N <='1';
DRAM_CAS_N <='1';


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
--		ps2k_divert => ps2k_divert,

		-- SD card signals
--		spi_clk => spi_clk,
--		spi_mosi => spi_mosi,
--		spi_miso => spi_miso,
--		spi_cs => spi_cs,
--		spi_divert => spi_divert,
		
		-- We leave the mouse disconnected for now
		
		-- DIP switches
		dipswitches(15 downto 3) => open,
		dipswitches(2) => scanlines,
		dipswitches(1 downto 0) => testpattern, -- Replaces previous binding from the physical DIP switches
		
		-- RGB scaling
		scalered => scalered,
		scalegreen => scalegreen,
		scaleblue => scaleblue
	);


-- The core proper

myhostcore : entity work.HostCore
	port map(
		reset => reset,
		clk => clk,
		
		vga_r	=> vga_red_i,
		vga_g	=> vga_green_i,
		vga_b => vga_blue_i,
		vga_hs => vga_hsync_i,
		vga_vs => vga_vsync_i,

		ps2k_clk_out => ps2k_clk_out,
		ps2k_dat_out => ps2k_dat_out,
		ps2k_clk_in => ps2k_clk_in,
		ps2k_dat_in => ps2k_dat_in,
		
		spi_miso => spi_miso,
		spi_mosi => spi_mosi,
		spi_clk => spi_clk,
		spi_cs => spi_cs,
		
		-- "Front panel" controls.
		testpattern => testpattern,
		scalered => scalered,
		scalegreen => scalegreen,
		scaleblue => scaleblue
	);

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
		scanline_ena => scanlines
	);

VGA_HS <= vga_hsync_i;
VGA_VS <= vga_vsync_i;

end rtl;
