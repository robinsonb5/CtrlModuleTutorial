-- ZPU
--
-- Copyright 2004-2008 oharboe - �yvind Harboe - oyvind.harboe@zylin.com
-- Modified by Alastair M. Robinson for the ZPUFlex project.
--
-- The FreeBSD license
-- 
-- Redistribution and use in source and binary forms, with or without
-- modification, are permitted provided that the following conditions
-- are met:
-- 
-- 1. Redistributions of source code must retain the above copyright
--    notice, this list of conditions and the following disclaimer.
-- 2. Redistributions in binary form must reproduce the above
--    copyright notice, this list of conditions and the following
--    disclaimer in the documentation and/or other materials
--    provided with the distribution.
-- 
-- THIS SOFTWARE IS PROVIDED BY THE ZPU PROJECT ``AS IS'' AND ANY
-- EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
-- THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A
-- PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE
-- ZPU PROJECT OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT,
-- INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
-- (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
-- OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
-- HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT,
-- STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
-- ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
-- ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
-- 
-- The views and conclusions contained in the software and documentation
-- are those of the authors and should not be interpreted as representing
-- official policies, either expressed or implied, of the ZPU Project.

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


library work;
use work.zpupkg.all;

entity CtrlROM_ROM is
generic
	(
		maxAddrBitBRAM : integer := maxAddrBitBRAMLimit -- Specify your actual ROM size to save LEs and unnecessary block RAM usage.
	);
port (
	clk : in std_logic;
	areset : in std_logic := '0';
	from_zpu : in ZPU_ToROM;
	to_zpu : out ZPU_FromROM
);
end CtrlROM_ROM;

architecture arch of CtrlROM_ROM is

type ram_type is array(natural range 0 to ((2**(maxAddrBitBRAM+1))/4)-1) of std_logic_vector(wordSize-1 downto 0);

shared variable ram : ram_type :=
(
     0 => x"0b0b0b0b",
     1 => x"8c0b0b0b",
     2 => x"0b81e004",
     3 => x"0b0b0b0b",
     4 => x"8c04ff0d",
     5 => x"80040400",
     6 => x"00000016",
     7 => x"00000000",
     8 => x"0b0b0b86",
     9 => x"90080b0b",
    10 => x"0b869408",
    11 => x"0b0b0b86",
    12 => x"98080b0b",
    13 => x"0b0b9808",
    14 => x"2d0b0b0b",
    15 => x"86980c0b",
    16 => x"0b0b8694",
    17 => x"0c0b0b0b",
    18 => x"86900c04",
    19 => x"00000000",
    20 => x"00000000",
    21 => x"00000000",
    22 => x"00000000",
    23 => x"00000000",
    24 => x"71fd0608",
    25 => x"72830609",
    26 => x"81058205",
    27 => x"832b2a83",
    28 => x"ffff0652",
    29 => x"0471fc06",
    30 => x"08728306",
    31 => x"09810583",
    32 => x"05101010",
    33 => x"2a81ff06",
    34 => x"520471fd",
    35 => x"060883ff",
    36 => x"ff738306",
    37 => x"09810582",
    38 => x"05832b2b",
    39 => x"09067383",
    40 => x"ffff0673",
    41 => x"83060981",
    42 => x"05820583",
    43 => x"2b0b2b07",
    44 => x"72fc060c",
    45 => x"51510471",
    46 => x"fc06080b",
    47 => x"0b0b85ec",
    48 => x"73830610",
    49 => x"10050806",
    50 => x"7381ff06",
    51 => x"73830609",
    52 => x"81058305",
    53 => x"1010102b",
    54 => x"0772fc06",
    55 => x"0c515104",
    56 => x"86907086",
    57 => x"ac278b38",
    58 => x"80717084",
    59 => x"05530c81",
    60 => x"e2048c51",
    61 => x"85be0402",
    62 => x"fc050df8",
    63 => x"80518f0b",
    64 => x"86a00c9f",
    65 => x"0b86a40c",
    66 => x"a0717081",
    67 => x"05533486",
    68 => x"a408ff05",
    69 => x"86a40c86",
    70 => x"a4088025",
    71 => x"eb3886a0",
    72 => x"08ff0586",
    73 => x"a00c86a0",
    74 => x"088025d7",
    75 => x"38800b86",
    76 => x"a40c800b",
    77 => x"86a00c02",
    78 => x"84050d04",
    79 => x"02f0050d",
    80 => x"f88053f8",
    81 => x"a05483bf",
    82 => x"52737081",
    83 => x"05553351",
    84 => x"70737081",
    85 => x"055534ff",
    86 => x"12527180",
    87 => x"25eb38fb",
    88 => x"c0539f52",
    89 => x"a0737081",
    90 => x"055534ff",
    91 => x"12527180",
    92 => x"25f23802",
    93 => x"90050d04",
    94 => x"02f4050d",
    95 => x"74538e0b",
    96 => x"86a00825",
    97 => x"8f3882bc",
    98 => x"2d86a008",
    99 => x"ff0586a0",
   100 => x"0c82fe04",
   101 => x"86a00886",
   102 => x"a4085351",
   103 => x"728a2e09",
   104 => x"8106b738",
   105 => x"7151719f",
   106 => x"24a03886",
   107 => x"a008a029",
   108 => x"11f88011",
   109 => x"5151a071",
   110 => x"3486a408",
   111 => x"810586a4",
   112 => x"0c86a408",
   113 => x"519f7125",
   114 => x"e238800b",
   115 => x"86a40c86",
   116 => x"a0088105",
   117 => x"86a00c83",
   118 => x"ee0470a0",
   119 => x"2912f880",
   120 => x"11515172",
   121 => x"713486a4",
   122 => x"08810586",
   123 => x"a40c86a4",
   124 => x"08a02e09",
   125 => x"81068e38",
   126 => x"800b86a4",
   127 => x"0c86a008",
   128 => x"810586a0",
   129 => x"0c028c05",
   130 => x"0d0402ec",
   131 => x"050d800b",
   132 => x"86a80cf6",
   133 => x"8c08f690",
   134 => x"0871882c",
   135 => x"565481ff",
   136 => x"06527372",
   137 => x"25883871",
   138 => x"54820b86",
   139 => x"a80c7288",
   140 => x"2c7381ff",
   141 => x"06545574",
   142 => x"73258b38",
   143 => x"7286a808",
   144 => x"840786a8",
   145 => x"0c557384",
   146 => x"2b86a071",
   147 => x"25837131",
   148 => x"700b0b0b",
   149 => x"868c0c81",
   150 => x"712bff05",
   151 => x"f6880cfe",
   152 => x"cc13ff12",
   153 => x"2c788829",
   154 => x"ff940570",
   155 => x"812c86a8",
   156 => x"08525852",
   157 => x"55515254",
   158 => x"76802e85",
   159 => x"38708107",
   160 => x"5170f694",
   161 => x"0c710981",
   162 => x"05f6800c",
   163 => x"72098105",
   164 => x"f6840c02",
   165 => x"94050d04",
   166 => x"02f4050d",
   167 => x"74537270",
   168 => x"81055480",
   169 => x"f52d5271",
   170 => x"802e8938",
   171 => x"715182f8",
   172 => x"2d859e04",
   173 => x"810b8690",
   174 => x"0c028c05",
   175 => x"0d0402f4",
   176 => x"050d8053",
   177 => x"81f72d85",
   178 => x"fc518598",
   179 => x"2dbd84bf",
   180 => x"5272fc0c",
   181 => x"ff125271",
   182 => x"8025f638",
   183 => x"81138306",
   184 => x"53815184",
   185 => x"8a2d85cd",
   186 => x"04000000",
   187 => x"00ffffff",
   188 => x"ff00ffff",
   189 => x"ffff00ff",
   190 => x"ffffff00",
   191 => x"48656c6c",
   192 => x"6f2c2077",
   193 => x"6f726c64",
   194 => x"210a0000",
   195 => x"00000002",
	others => x"00000000"
);

begin

process (clk)
begin
	if (clk'event and clk = '1') then
		if (from_zpu.memAWriteEnable = '1') and (from_zpu.memBWriteEnable = '1') and (from_zpu.memAAddr=from_zpu.memBAddr) and (from_zpu.memAWrite/=from_zpu.memBWrite) then
			report "write collision" severity failure;
		end if;
	
		if (from_zpu.memAWriteEnable = '1') then
			ram(to_integer(unsigned(from_zpu.memAAddr(maxAddrBitBRAM downto 2)))) := from_zpu.memAWrite;
			to_zpu.memARead <= from_zpu.memAWrite;
		else
			to_zpu.memARead <= ram(to_integer(unsigned(from_zpu.memAAddr(maxAddrBitBRAM downto 2))));
		end if;
	end if;
end process;

process (clk)
begin
	if (clk'event and clk = '1') then
		if (from_zpu.memBWriteEnable = '1') then
			ram(to_integer(unsigned(from_zpu.memBAddr(maxAddrBitBRAM downto 2)))) := from_zpu.memBWrite;
			to_zpu.memBRead <= from_zpu.memBWrite;
		else
			to_zpu.memBRead <= ram(to_integer(unsigned(from_zpu.memBAddr(maxAddrBitBRAM downto 2))));
		end if;
	end if;
end process;


end arch;

