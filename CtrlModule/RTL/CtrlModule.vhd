library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.ALL;

library work;
use work.zpupkg.ALL;

entity CtrlModule is
	generic (
		sysclk_frequency : integer := 1000 -- Sysclk frequency * 10
	);
	port (
		clk 			: in std_logic;
		reset_n 	: in std_logic;

		-- Video signals for OSD
		vga_hsync : in std_logic;
		vga_vsync : in std_logic;
		osd_window : out std_logic;
		osd_pixel : out std_logic;

		-- DIP switches
		dipswitches : out std_logic_vector(15 downto 0)
	);
end entity;

architecture rtl of CtrlModule is

-- ZPU signals
constant maxAddrBit : integer := 20; -- Optional - defaults to 32 - but helps keep the logic element count down.
signal mem_busy           : std_logic;
signal mem_read             : std_logic_vector(wordSize-1 downto 0);
signal mem_write            : std_logic_vector(wordSize-1 downto 0);
signal mem_addr             : std_logic_vector(maxAddrBit downto 0);
signal mem_writeEnable      : std_logic; 
signal mem_readEnable       : std_logic;
signal mem_hEnable      : std_logic; 
signal mem_bEnable      : std_logic; 

signal zpu_to_rom : ZPU_ToROM;
signal zpu_from_rom : ZPU_FromROM;

-- OSD related signals
signal osd_wr : std_logic;
signal osd_charwr : std_logic;
signal osd_char_q : std_logic_vector(7 downto 0);
signal osd_data : std_logic_vector(15 downto 0);

begin

-- ROM

	myrom : entity work.CtrlROM_ROM
	generic map
	(
		maxAddrBitBRAM => 13
	)
	port map (
		clk => clk,
		from_zpu => zpu_to_rom,
		to_zpu => zpu_from_rom
	);

	
-- Main CPU
-- We instantiate the CPU with the optional instructions enabled, which allows us to reduce
-- the size of the ROM by leaving out emulation code.
	zpu: zpu_core_flex
	generic map (
		IMPL_MULTIPLY => true,
		IMPL_COMPARISON_SUB => true,
		IMPL_EQBRANCH => true,
		IMPL_STOREBH => true,
		IMPL_LOADBH => true,
		IMPL_CALL => true,
		IMPL_SHIFT => true,
		IMPL_XOR => true,
		REMAP_STACK => false, -- We're not using SDRAM so no need to remap the Boot ROM / Stack RAM
		EXECUTE_RAM => false, -- We don't need to execute code from external RAM.
		maxAddrBit => maxAddrBit,
		maxAddrBitBRAM => 13
	)
	port map (
		clk                 => clk,
		reset               => not reset_n,
		in_mem_busy         => mem_busy,
		mem_read            => mem_read,
		mem_write           => mem_write,
		out_mem_addr        => mem_addr,
		out_mem_writeEnable => mem_writeEnable,
		out_mem_hEnable     => mem_hEnable,
		out_mem_bEnable     => mem_bEnable,
		out_mem_readEnable  => mem_readEnable,
		from_rom => zpu_from_rom,
		to_rom => zpu_to_rom
	);


-- OSD

myosd : entity work.OnScreenDisplay
port map(
	reset_n => reset_n,
	clk => clk,
	-- Video
	hsync_n => vga_hsync,
	vsync_n => vga_vsync,
	pixel => osd_pixel,
	window => osd_window,
	-- Registers
	addr => mem_addr(8 downto 0),	-- low 9 bits of address
	data_in => mem_write(15 downto 0),
	data_out => osd_data(15 downto 0),
	reg_wr => osd_wr,			-- Trigger a write to the control registers
	char_wr => osd_charwr,	-- Trigger a write to the character RAM
	char_q => osd_char_q		-- Data from the character RAM
);


	
process(clk)
begin
	if reset_n='0' then

	elsif rising_edge(clk) then
		mem_busy<='1';
		osd_charwr<='0';
		osd_wr<='0';
		
		-- Write from CPU?
		if mem_writeEnable='1' then
			case mem_addr(maxAddrBit)&mem_addr(10 downto 8) is
				when X"B" =>	-- OSD controller at 0xFFFFFB00
					osd_wr<='1';
					mem_busy<='0';
				when X"C" =>	-- OSD controller at 0xFFFFFC00 & 0xFFFFFD00
					osd_charwr<='1';
					mem_busy<='0';
				when X"D" =>	-- OSD controller at 0xFFFFFC00 & 0xFFFFFD00
					osd_charwr<='1';
					mem_busy<='0';
				when X"F" =>	-- Peripherals at 0xFFFFFF00
					case mem_addr(7 downto 0) is							
						when X"FC" => -- Host SW
							mem_busy<='0';
							dipswitches<=mem_write(15 downto 0);

						when others =>
							mem_busy<='0';
							null;
					end case;
				when others =>
					mem_busy<='0';
			end case;

		-- Read from CPU?
		elsif mem_readEnable='1' then
			case mem_addr(maxAddrBit)&mem_addr(10 downto 8) is
				when X"B" =>	-- OSD registers
					mem_read(31 downto 16)<=(others => '0');
					mem_read(15 downto 0)<=osd_data;
					mem_busy<='0';
				when X"C" =>	-- OSD controller at 0xFFFFFC00 & 0xFFFFFD00
					mem_read(31 downto 8)<=(others => 'X');
					mem_read(7 downto 0)<=osd_char_q;
					mem_busy<='0';
				when X"D" =>	-- OSD controller at 0xFFFFFC00 & 0xFFFFFD00
					mem_read(31 downto 8)<=(others => 'X');
					mem_read(7 downto 0)<=osd_char_q;
					mem_busy<='0';
				when X"F" =>	-- Peripherals
					case mem_addr(7 downto 0) is
						-- We don't have any readable registers yet.
						when others =>
							mem_busy<='0';
							null;
					end case;

				when others => -- SDRAM
					mem_busy<='0';
			end case;
		end if;
		
	end if; -- rising-edge(clk)

end process;
	
end architecture;
