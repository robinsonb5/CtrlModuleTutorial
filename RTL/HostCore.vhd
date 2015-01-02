library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_TEXTIO.all;
use IEEE.NUMERIC_STD.ALL;

library work;
use work.DMACache_pkg.ALL;
use work.DMACache_config.ALL;

entity HostCore is
	generic (
		sdram_rows : integer := 12;
		sdram_cols : integer := 8;
		sysclk_frequency : integer := 1000 -- Sysclk frequency * 10
	);
	port(
		reset_n : in std_logic;
		clk : in std_logic;
		
		-- SDRAM
		sdr_data		: inout std_logic_vector(15 downto 0);
		sdr_addr		: out std_logic_vector((sdram_rows-1) downto 0);
		sdr_dqm 		: out std_logic_vector(1 downto 0);
		sdr_we 		: out std_logic;
		sdr_cas 		: out std_logic;
		sdr_ras 		: out std_logic;
		sdr_cs		: out std_logic;
		sdr_ba		: out std_logic_vector(1 downto 0);
--		sdr_clk		: out std_logic;
		sdr_cke		: out std_logic;

		vga_r		: out std_logic_vector(7 downto 0);
		vga_g		: out std_logic_vector(7 downto 0);
		vga_b		: out std_logic_vector(7 downto 0);
		vga_hs	: out std_logic;
		vga_vs	: out std_logic;

		ps2k_clk_out : out std_logic;
		ps2k_dat_out : out std_logic;
		ps2k_clk_in : in std_logic;
		ps2k_dat_in : in std_logic;
		
		spi_miso		: in std_logic := '1';
		spi_mosi		: out std_logic;
		spi_clk		: out std_logic;
		spi_cs 		: out std_logic;
		
		-- "Front panel" controls.
		testpattern : in std_logic_vector(1 downto 0);
		scalered : in unsigned(4 downto 0);
		scalegreen : in unsigned(4 downto 0);
		scaleblue : in unsigned(4 downto 0);
		
		-- Boot data uploading interface
		bootdata : in std_logic_vector(31 downto 0):=(others => 'X');
		bootdata_req : in std_logic:='0';
		bootdata_ack : out std_logic
	);
end entity;

architecture rtl of HostCore is

-- Internal video signals:

signal eopixel : std_logic;
signal eoline : std_logic;
signal eoframe : std_logic;
signal vga_X : unsigned(11 downto 0);
signal vga_Y : unsigned(11 downto 0);
signal vga_offset : unsigned(7 downto 0);
signal vga_ysum : unsigned(11 downto 0);

signal vga_red_i : unsigned(7 downto 0);
signal vga_green_i : unsigned(7 downto 0);
signal vga_blue_i	: unsigned(7 downto 0);		
signal vga_red_i_scaled : unsigned(12 downto 0);
signal vga_green_i_scaled : unsigned(12 downto 0);
signal vga_blue_i_scaled : unsigned(12 downto 0);


-- Keyboard signals

signal kbdrecv : std_logic;
signal kbdrecvbyte : std_logic_vector(10 downto 0);


-- Plumbing between DMA controller and SDRAM

signal vga_addr : std_logic_vector(31 downto 0);
signal vga_data : std_logic_vector(15 downto 0);
signal vga_req : std_logic;
signal vga_fill : std_logic;
signal vga_refresh : std_logic;
signal vga_newframe : std_logic;
signal vga_reservebank : std_logic; -- Keep bank clear for instant access.
signal vga_reserveaddr : std_logic_vector(31 downto 0); -- to SDRAM

signal dma_data : std_logic_vector(15 downto 0);


-- Plumbing between VGA controller and DMA controller

signal vgachannel_fromhost : DMAChannel_FromHost;
signal vgachannel_tohost : DMAChannel_ToHost;
signal spr0channel_fromhost : DMAChannel_FromHost;
signal spr0channel_tohost : DMAChannel_ToHost;


-- VGA register block signals

signal vga_reg_addr : std_logic_vector(11 downto 0);
signal vga_reg_dataout : std_logic_vector(31 downto 0);
signal vga_reg_datain : std_logic_vector(31 downto 0);
signal vga_reg_rw : std_logic;
signal vga_reg_req : std_logic;
signal vga_reg_dtack : std_logic;
signal vga_ack : std_logic;
signal vblank_int : std_logic;


-- SDRAM signals

signal sdr_ready : std_logic;
signal sdram_write : std_logic_vector(31 downto 0); -- 32-bit width for ZPU
signal sdram_addr : std_logic_vector(31 downto 0);
signal sdram_req : std_logic;
signal sdram_wr : std_logic;
signal sdram_read : std_logic_vector(31 downto 0);
signal sdram_ack : std_logic;

signal sdram_wrL : std_logic;
signal sdram_wrU : std_logic;
signal sdram_wrU2 : std_logic;


-- General signals
type boot_states is (idle, ramwait);
signal boot_state : boot_states := idle;

begin

-- Enable SDRAM

sdr_cke<='1';

-- Safe defaults for unused signals 

spi_cs<='1';
spi_clk<='0';
spi_mosi<='1';


-- State machine to receive and stash boot data in SDRAM
process(clk, bootdata_req)
begin
	if rising_edge(clk) then
		if reset_n='0' then
			sdram_addr<=X"00100000"; -- The VGA controller's default framebuffer address
			sdram_req<='0';
			sdram_wr<='1';
			bootdata_ack<='0';
			boot_state<=idle;
		else
			bootdata_ack<='0';
			case boot_state is
				when idle =>
					if bootdata_req='1' then
						sdram_write<=bootdata;
						sdram_wr<='0';
						sdram_req<='1';
						boot_state<=ramwait;
						bootdata_ack<='1';
					end if;
				when ramwait =>
					if sdram_ack='1' then
						sdram_addr<=std_logic_vector((unsigned(sdram_addr)+4));
						sdram_req<='0';
						sdram_wr<='1';
						boot_state<=idle;
					end if;
			end case;
		end if;
	end if;
end process;


-- DMA controller

	mydmacache : entity work.DMACache
		port map(
			clk => clk,
			reset_n => reset_n,

			channels_from_host(0) => vgachannel_fromhost,
			channels_from_host(1) => spr0channel_fromhost,
			channels_to_host(0) => vgachannel_tohost,	
			channels_to_host(1) => spr0channel_tohost,

			data_out => dma_data,

			-- SDRAM interface
			sdram_addr=> vga_addr,
			sdram_reserveaddr(31 downto 0) => vga_reserveaddr,
			sdram_reserve => vga_reservebank,
			sdram_req => vga_req,
			sdram_ack => vga_ack,
			sdram_fill => vga_fill,
			sdram_data => vga_data
		);	

	
-- SDRAM
mysdram : entity work.sdram_simple
	generic map
	(
		rows => sdram_rows,
		cols => sdram_cols
	)
	port map
	(
	-- Physical connections to the SDRAM
		sdata => sdr_data,
		sdaddr => sdr_addr,
		sd_we	=> sdr_we,
		sd_ras => sdr_ras,
		sd_cas => sdr_cas,
		sd_cs	=> sdr_cs,
		dqm => sdr_dqm,
		ba	=> sdr_ba,

	-- Housekeeping
		sysclk => clk,
		reset => reset_n,  -- Contributes to reset, so have to use reset_in here.
		reset_out => sdr_ready,

		vga_addr => vga_addr,
		vga_data => vga_data,
		vga_fill => vga_fill,
		vga_req => vga_req,
		vga_ack => vga_ack,
		vga_refresh => vga_refresh,
		vga_reservebank => vga_reservebank,
		vga_reserveaddr => vga_reserveaddr,

		vga_newframe => vga_newframe,
		datawr1 => sdram_write,
		addr1 => sdram_addr,
		req1 => sdram_req,
		wr1 => sdram_wr, -- active low
		wrL1 => sdram_wr, -- lower byte
		wrU1 => sdram_wr, -- upper byte
		wrU2 => sdram_wr, -- upper halfword, only written on longword accesses
		dataout1 => sdram_read,
		dtack1 => sdram_ack
	);

	
-- VGA controller
-- Video
	
	myvga : entity work.vga_controller
		generic map (
			enable_sprite => false
		)
		port map (
		clk => clk,
		reset => reset_n,

		reg_addr_in => vga_reg_addr(7 downto 0),
		reg_data_in => vga_reg_datain,
--		reg_data_out => vga_reg_dataout,
		reg_rw => vga_reg_rw,
		reg_req => vga_reg_req,

		sdr_refresh => vga_refresh,

		dma_data => dma_data,
		vgachannel_fromhost => vgachannel_fromhost,
		vgachannel_tohost => vgachannel_tohost,
		spr0channel_fromhost => spr0channel_fromhost,
		spr0channel_tohost => spr0channel_tohost,

		hsync => vga_hs,
		vsync => vga_vs,
		vblank_int => vblank_int,
		red => vga_red_i,
		green => vga_green_i,
		blue => vga_blue_i
--		vga_window => vga_window
	);

	
-- PS2 keyboard
mykeyboard : entity work.io_ps2_com
generic map (
	clockFilter => 15,
	ticksPerUsec => sysclk_frequency/10
)
port map (
	clk => clk,
	reset => not reset_n, -- active high!
	ps2_clk_in => ps2k_clk_in,
	ps2_dat_in => ps2k_dat_in,
	ps2_clk_out => ps2k_clk_out,
	ps2_dat_out => ps2k_dat_out,
	
	inIdle => open,
	sendTrigger => '0',
	sendByte => (others=>'X'),
	sendBusy => open,
	sendDone => open,
	recvTrigger => kbdrecv,
	recvByte => kbdrecvbyte
);

vga_reg_req<='0';
vga_reg_rw<='1';

-- Scale according to the RGB scale values;
vga_red_i_scaled<=scalered * vga_red_i;
vga_green_i_scaled<=scalegreen * vga_green_i;
vga_blue_i_scaled<=scaleblue * vga_blue_i;

-- Swap channels based on testpattern signal

with testpattern select vga_r <=
	std_logic_vector(vga_red_i_scaled(11 downto 4)) when "00",
	std_logic_vector(vga_green_i_scaled(11 downto 4)) when "01",
	std_logic_vector(vga_blue_i_scaled(11 downto 4)) when "10",
	std_logic_vector(vga_red_i_scaled(11 downto 4)) when "11";
	
with testpattern select vga_g <=
	std_logic_vector(vga_green_i_scaled(11 downto 4)) when "00",
	std_logic_vector(vga_blue_i_scaled(11 downto 4)) when "01",
	std_logic_vector(vga_red_i_scaled(11 downto 4)) when "10",
	std_logic_vector(vga_blue_i_scaled(11 downto 4)) when "11";

with testpattern select vga_b <=
	std_logic_vector(vga_blue_i_scaled(11 downto 4)) when "00",
	std_logic_vector(vga_red_i_scaled(11 downto 4)) when "01",
	std_logic_vector(vga_green_i_scaled(11 downto 4)) when "10",
	std_logic_vector(vga_green_i_scaled(11 downto 4)) when "11";

end rtl;
