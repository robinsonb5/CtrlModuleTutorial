library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_TEXTIO.all;
use IEEE.NUMERIC_STD.ALL;

entity HostCore is
	port(
		reset : in std_logic;
		clk : in std_logic;
		
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
		scaleblue : in unsigned(4 downto 0)
	);
end entity;

architecture rtl of HostCore is

signal eopixel : std_logic;
signal eoline : std_logic;
signal eoframe : std_logic;
signal vga_X : unsigned(11 downto 0);
signal vga_Y : unsigned(11 downto 0);


-- Internal video signals:
signal vga_red_i : unsigned(7 downto 0);
signal vga_green_i : unsigned(7 downto 0);
signal vga_blue_i	: unsigned(7 downto 0);		
signal vga_red_i_scaled : unsigned(12 downto 0);
signal vga_green_i_scaled : unsigned(12 downto 0);
signal vga_blue_i_scaled : unsigned(12 downto 0);

begin


-- Safe defaults for unused signals 

ps2k_clk_out<='1';
ps2k_dat_out<='1';

spi_cs<='1';
spi_clk<='0';
spi_mosi<='1';


-- Video timings generator

vgamaster : entity work.video_vga_master
	port map (
-- System
		clk => clk,
		clkDiv => X"3", -- 100Mhz / (3+1) = 25 MHz dot clock

-- Sync outputs
		hSync => vga_hs, -- Now internal signals
		vSync => vga_vs,

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

	
-- Render the test pattern

process(clk,vga_X,vga_Y)
begin
	if rising_edge(clk) then
		if vga_Y<X"1E0" and vga_X<X"280" then
			case testpattern is
				when "00" =>
					vga_red_i<=vga_X(7 downto 0);
					vga_green_i<=vga_Y(7 downto 0);
					vga_blue_i<=vga_X(3)&vga_Y(3)&vga_X(2)&vga_Y(2)&vga_X(1)&vga_Y(1)&vga_X(0)&vga_Y(0);
				when "01" =>
					vga_red_i<=not vga_X(7 downto 0);
					vga_green_i<=vga_Y(7 downto 0);
					vga_blue_i<=not (vga_X(3)&vga_Y(3)&vga_X(2)&vga_Y(2)&vga_X(1)&vga_Y(1)&vga_X(0)&vga_Y(0));
				when "10" =>
					vga_red_i<=vga_X(7 downto 0);
					vga_green_i<=not vga_Y(7 downto 0);
					vga_blue_i<=vga_X(3)&vga_Y(3)&vga_X(2)&vga_Y(2)&vga_X(1)&vga_Y(1)&vga_X(0)&vga_Y(0);
				when "11" =>
					vga_red_i<=not vga_X(7 downto 0);
					vga_green_i<=not vga_Y(7 downto 0);
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

-- Scale according to the RGB scale values;
vga_red_i_scaled<=scalered * vga_red_i;
vga_green_i_scaled<=scalegreen * vga_green_i;
vga_blue_i_scaled<=scaleblue * vga_blue_i;

vga_r<=std_logic_vector(vga_red_i_scaled(11 downto 4));
vga_g<=std_logic_vector(vga_green_i_scaled(11 downto 4));
vga_b<=std_logic_vector(vga_blue_i_scaled(11 downto 4));

end rtl;
