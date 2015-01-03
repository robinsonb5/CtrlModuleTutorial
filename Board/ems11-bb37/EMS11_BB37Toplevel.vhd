-- Toplevel file for EMS11-BB37 board

library ieee;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.ALL;

library UNISIM;
use UNISIM.vcomponents.all;

entity EMS11_BB37Toplevel is
port
(
		-- Housekeeping
	CLK50 : in std_logic;

		-- UART
	UART1_TXD : out std_logic;
	UART1_RXD : in std_logic;
	UART1_RTS_N : out std_logic;
	UART1_CTS_N : in std_logic;
	
		-- SDRAM
	DR_CAS_N : out std_logic;
	DR_CS_N : out std_logic;
	DR_RAS_N : out std_logic;
	DR_WE_N	: out std_logic;
	DR_CLK_I : in std_logic;
	DR_CLK_O : out std_logic;
	DR_CKE : out std_logic;
	DR_A : out std_logic_vector(12 downto 0);
	DR_D : inout std_logic_vector(15 downto 0);
	DR_DQMH : out std_logic;
	DR_DQML : out std_logic;
	DR_BA : out std_logic_vector(1 downto 0);
	
		-- SD Card

	FPGA_SD_CDET_N : in std_logic;
	FPGA_SD_WPROT_N : in std_logic;
	FPGA_SD_CMD : out std_logic;
	FPGA_SD_D0 : in std_logic;
	FPGA_SD_D1 : in std_logic; -- High Z since we're using SPI-mode
	FPGA_SD_D2 : in std_logic; -- High Z since we're using SPI-mode
	FPGA_SD_D3 : out std_logic;
	FPGA_SD_SCLK : out std_logic;
	
		-- VGA Connector
	UART2_RTS_N : out std_logic; -- Actually used for VGA
	-- M1_S : inout std_logic_vector(39 downto 0);
	
	M1_VGA_RED : out std_logic_vector(7 downto 0);
	M1_VGA_GREEN : out std_logic_vector(7 downto 0);
	M1_VGA_BLUE : out std_logic_vector(7 downto 0);
	M1_VGA_HSYNC : out std_logic;
	M1_VGA_VSYNC : out std_logic;
	M1_VGA_CLOCK : out std_logic;
	M1_VGA_PSAVE_N : out std_logic;
	M1_VGA_BLANK_N : out std_logic;
	M1_VGA_SYNC_N : out std_logic;
	
	M1_PS2_A_CLK : inout std_logic;
	M1_PS2_A_DATA : inout std_logic;
	M1_PS2_B_CLK : inout std_logic;
	M1_PS2_B_DATA : inout std_logic;

		-- LEDs
	LED1 : out std_logic;
	LED2 : out std_logic;
	
		-- Emus GPIO
	GPIO : inout std_logic_vector(15 downto 0);

		-- Buttons
	DIAG_N : in std_logic;
	RESET_N : in std_logic
);
end entity;


architecture rtl of EMS11_BB37Toplevel is

signal sdram_clk : std_logic;
signal sdram_clk_inv : std_logic;
signal sysclk : std_logic;
signal sysclk_inv : std_logic;
signal clklocked : std_logic;
signal sysclk_slow : std_logic;

signal vga_red : std_logic_vector(7 downto 0);
signal vga_green : std_logic_vector(7 downto 0);
signal vga_blue : std_logic_vector(7 downto 0);
signal vga_hsync : std_logic;
signal vga_vsync : std_logic;
signal vga_window : std_logic;
signal vga_clock : std_logic;
signal vga_blank : std_logic;
signal vga_sync : std_logic;
signal vga_psave : std_logic;

-- PS/2 ports
-- alias PS2_MCLK : std_logic is M1_S(35);
-- alias PS2_MDAT : std_logic is M1_S(33);
-- alias PS2_CLK : std_logic is M1_S(37);
-- alias PS2_DAT : std_logic is M1_S(39);

alias PS2_MCLK : std_logic is M1_PS2_A_CLK;
alias PS2_MDAT : std_logic is M1_PS2_A_DATA;
alias PS2_CLK : std_logic is M1_PS2_B_CLK;
alias PS2_DAT : std_logic is M1_PS2_B_DATA;

signal ps2m_clk_in : std_logic;
signal ps2m_clk_out : std_logic;
signal ps2m_dat_in : std_logic;
signal ps2m_dat_out : std_logic;

signal ps2k_clk_in : std_logic;
signal ps2k_clk_out : std_logic;
signal ps2k_dat_in : std_logic;
signal ps2k_dat_out : std_logic;

signal reset_s : std_logic;

begin
UART1_RTS_N<='1';  -- safe default since we're not using handshaking.


-- DR_CLK_O<='1';
process(sysclk)
	begin
	if rising_edge(sysclk) then
		reset_s <= RESET_N;
	end if;
end process;

LED1 <= reset_s;
LED2 <= DIAG_N;

ps2m_dat_in<=PS2_MDAT;
PS2_MDAT <= '0' when ps2m_dat_out='0' else 'Z';
ps2m_clk_in<=PS2_MCLK;
PS2_MCLK <= '0' when ps2m_clk_out='0' else 'Z';

ps2k_dat_in<=PS2_DAT;
PS2_DAT <= '0' when ps2k_dat_out='0' else 'Z';
ps2k_clk_in<=PS2_CLK;
PS2_CLK <= '0' when ps2k_clk_out='0' else 'Z';

-- Clock generation.  We need a system clock and an SDRAM clock.
-- Limitations of the Spartan 6 mean we need to "forward" the SDRAM clock
-- to the io pin.

myclock : entity work.Clock_50to100Split
port map(
	CLK_IN1 => CLK50,
	RESET => '0',
	CLK_OUT1 => sysclk,
	CLK_OUT2 => sdram_clk,
	CLK_OUT3 => sysclk_slow,
	LOCKED => clklocked
);

sysclk_inv <= not sysclk;
sdram_clk_inv <= not sdram_clk;

ODDR2_inst : ODDR2
generic map(
	DDR_ALIGNMENT => "NONE",
	INIT => '0',
	SRTYPE => "SYNC")
port map (
	Q => DR_CLK_O,
	C0 => sdram_clk,
	C1 => sdram_clk_inv,
	CE => '1',
	D0 => '0',
	D1 => '1',
	R => '0',    -- 1-bit reset input
	S => '0'     -- 1-bit set input
);

-- Forward the VGA clock too.

ODDR2_inst2 : ODDR2
generic map(
	DDR_ALIGNMENT => "NONE",
	INIT => '0',
	SRTYPE => "SYNC")
port map (
	Q => vga_clock,
	C0 => sysclk,
	C1 => sysclk_inv,
	CE => '1',
	D0 => '0',
	D1 => '1',
	R => '0',    -- 1-bit reset input
	S => '0'     -- 1-bit set input
);


-- vga_clock <= sysclk;
vga_sync <= '0';
vga_blank <= '1';
vga_psave <= '1';

-- M1_VGA_GREEN(9)<=vga_green(9);
-- M1_VGA_GREEN(8)<=vga_green(8);
M1_VGA_GREEN(7)<=vga_green(7);
M1_VGA_GREEN(6)<=vga_green(6);
M1_VGA_GREEN(5)<=vga_green(5);
M1_VGA_GREEN(4)<=vga_green(4);
M1_VGA_GREEN(3)<=vga_green(3);
M1_VGA_GREEN(2)<=vga_green(2);
M1_VGA_GREEN(1)<=vga_green(1);
M1_VGA_GREEN(0)<=vga_green(0);

-- M1_VGA_BLUE(9)<=vga_blue(9);
-- M1_VGA_BLUE(8)<=vga_blue(8);
M1_VGA_BLUE(7)<=vga_blue(7);
M1_VGA_BLUE(6)<=vga_blue(6);
M1_VGA_BLUE(5)<=vga_blue(5);
M1_VGA_BLUE(4)<=vga_blue(4);
M1_VGA_BLUE(3)<=vga_blue(3);
M1_VGA_BLUE(2)<=vga_blue(2);
M1_VGA_BLUE(1)<=vga_blue(1);
M1_VGA_BLUE(0)<=vga_blue(0);

-- M1_VGA_RED(9)<=vga_red(9);
-- M1_VGA_RED(8)<=vga_red(8);
M1_VGA_RED(7)<=vga_red(7);
M1_VGA_RED(6)<=vga_red(6);
M1_VGA_RED(5)<=vga_red(5);
M1_VGA_RED(4)<=vga_red(4);
M1_VGA_RED(3)<=vga_red(3);
M1_VGA_RED(2)<=vga_red(2);
M1_VGA_RED(1)<=vga_red(1);
M1_VGA_RED(0)<=vga_red(0);

M1_VGA_CLOCK<=vga_clock;
M1_VGA_PSAVE_N<=vga_psave;
M1_VGA_HSYNC<=vga_hsync;
M1_VGA_VSYNC<=vga_vsync;


M1_VGA_BLANK_N<=vga_blank;
M1_VGA_SYNC_N<=vga_sync;

-- M1_S(38)<='1';

DR_A(12)<='0'; -- Temporary measure

project: entity work.Virtual_Toplevel
	port map (
		clk => sysclk,
		reset => reset_s,
	
		-- VGA
		-- vga_red => vga_red(9 downto 2),
		-- vga_green => vga_green(9 downto 2),
		-- vga_blue => vga_blue(9 downto 2),

		vga_r => vga_red,
		vga_g => vga_green,
		vga_b => vga_blue,
		vga_hs => vga_hsync,
		vga_vs => vga_vsync,

		-- SDRAM
		DRAM_DQ => DR_D,
		DRAM_ADDR => DR_A(11 downto 0),
		DRAM_UDQM => DR_DQMH,
		DRAM_LDQM => DR_DQML,
		DRAM_WE_N => DR_WE_N,
		DRAM_CAS_N => DR_CAS_N,
		DRAM_RAS_N => DR_RAS_N,
		DRAM_CS_N => DR_CS_N,
		DRAM_BA_0 => DR_BA(0),
		DRAM_BA_1 => DR_BA(1),
		DRAM_CKE => DR_CKE,

		-- SD Card
		spi_cs => FPGA_SD_D3,
		spi_miso => FPGA_SD_D0,
		spi_mosi => FPGA_SD_CMD,
		spi_clk => FPGA_SD_SCLK,

		-- PS/2
		ps2k_clk_in => ps2k_clk_in,
		ps2k_dat_in => ps2k_dat_in,
		ps2k_clk_out => ps2k_clk_out,
		ps2k_dat_out => ps2k_dat_out,
--		ps2m_clk_in => ps2m_clk_in,
--		ps2m_dat_in => ps2m_dat_in,
--		ps2m_clk_out => ps2m_clk_out,
--		ps2m_dat_out => ps2m_dat_out,
		
		-- UART
		rs232_rxd => UART1_RXD,
		rs232_txd => UART1_TXD
);

end architecture;
