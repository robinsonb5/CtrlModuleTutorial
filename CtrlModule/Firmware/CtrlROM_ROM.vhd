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
     8 => x"0b0b0b8b",
     9 => x"9c080b0b",
    10 => x"0b8ba008",
    11 => x"0b0b0b8b",
    12 => x"a4080b0b",
    13 => x"0b0b9808",
    14 => x"2d0b0b0b",
    15 => x"8ba40c0b",
    16 => x"0b0b8ba0",
    17 => x"0c0b0b0b",
    18 => x"8b9c0c04",
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
    47 => x"0b0b8a80",
    48 => x"73830610",
    49 => x"10050806",
    50 => x"7381ff06",
    51 => x"73830609",
    52 => x"81058305",
    53 => x"1010102b",
    54 => x"0772fc06",
    55 => x"0c515104",
    56 => x"8b9c708b",
    57 => x"e4278b38",
    58 => x"80717084",
    59 => x"05530c81",
    60 => x"e2048c51",
    61 => x"85be0402",
    62 => x"fc050df8",
    63 => x"80518f0b",
    64 => x"8bac0c9f",
    65 => x"0b8bb00c",
    66 => x"a0717081",
    67 => x"0553348b",
    68 => x"b008ff05",
    69 => x"8bb00c8b",
    70 => x"b0088025",
    71 => x"eb388bac",
    72 => x"08ff058b",
    73 => x"ac0c8bac",
    74 => x"088025d7",
    75 => x"38800b8b",
    76 => x"b00c800b",
    77 => x"8bac0c02",
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
    96 => x"8bac0825",
    97 => x"8f3882bc",
    98 => x"2d8bac08",
    99 => x"ff058bac",
   100 => x"0c82fe04",
   101 => x"8bac088b",
   102 => x"b0085351",
   103 => x"728a2e09",
   104 => x"8106b738",
   105 => x"7151719f",
   106 => x"24a0388b",
   107 => x"ac08a029",
   108 => x"11f88011",
   109 => x"5151a071",
   110 => x"348bb008",
   111 => x"81058bb0",
   112 => x"0c8bb008",
   113 => x"519f7125",
   114 => x"e238800b",
   115 => x"8bb00c8b",
   116 => x"ac088105",
   117 => x"8bac0c83",
   118 => x"ee0470a0",
   119 => x"2912f880",
   120 => x"11515172",
   121 => x"71348bb0",
   122 => x"0881058b",
   123 => x"b00c8bb0",
   124 => x"08a02e09",
   125 => x"81068e38",
   126 => x"800b8bb0",
   127 => x"0c8bac08",
   128 => x"81058bac",
   129 => x"0c028c05",
   130 => x"0d0402ec",
   131 => x"050d800b",
   132 => x"8bb40cf6",
   133 => x"8c08f690",
   134 => x"0871882c",
   135 => x"565481ff",
   136 => x"06527372",
   137 => x"25883871",
   138 => x"54820b8b",
   139 => x"b40c7288",
   140 => x"2c7381ff",
   141 => x"06545574",
   142 => x"73258b38",
   143 => x"728bb408",
   144 => x"84078bb4",
   145 => x"0c557384",
   146 => x"2b86a071",
   147 => x"25837131",
   148 => x"700b0b0b",
   149 => x"8ad00c81",
   150 => x"712bff05",
   151 => x"f6880cfe",
   152 => x"cc13ff12",
   153 => x"2c788829",
   154 => x"ff940570",
   155 => x"812c8bb4",
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
   173 => x"810b8b9c",
   174 => x"0c028c05",
   175 => x"0d0402f0",
   176 => x"050d8053",
   177 => x"815489e7",
   178 => x"2d86d12d",
   179 => x"81f72d8a",
   180 => x"90518598",
   181 => x"2d8ab051",
   182 => x"85982d86",
   183 => x"dd2d8751",
   184 => x"88942d8b",
   185 => x"9c08812a",
   186 => x"70810651",
   187 => x"5271802e",
   188 => x"85387381",
   189 => x"32547351",
   190 => x"848a2d85",
   191 => x"5188942d",
   192 => x"8b9c0809",
   193 => x"8105708b",
   194 => x"9c080770",
   195 => x"09709f2c",
   196 => x"76065651",
   197 => x"51528651",
   198 => x"88942d8b",
   199 => x"9c08802e",
   200 => x"83388153",
   201 => x"84518894",
   202 => x"2d8b9c08",
   203 => x"802e8338",
   204 => x"82538c51",
   205 => x"88942d8b",
   206 => x"9c08802e",
   207 => x"83388353",
   208 => x"72fc0c85",
   209 => x"db047198",
   210 => x"0c04ffb0",
   211 => x"088b9c0c",
   212 => x"04810bff",
   213 => x"b00c0480",
   214 => x"0bffb00c",
   215 => x"0402f405",
   216 => x"0d87df04",
   217 => x"8b9c0881",
   218 => x"f02e0981",
   219 => x"06893881",
   220 => x"0b8b940c",
   221 => x"87df048b",
   222 => x"9c0881e0",
   223 => x"2e098106",
   224 => x"8938810b",
   225 => x"8b980c87",
   226 => x"df048b9c",
   227 => x"08528b98",
   228 => x"08802e88",
   229 => x"388b9c08",
   230 => x"81800552",
   231 => x"71842c72",
   232 => x"8f065353",
   233 => x"8b940880",
   234 => x"2e993872",
   235 => x"84298ad4",
   236 => x"05721381",
   237 => x"712b7009",
   238 => x"73080673",
   239 => x"0c515353",
   240 => x"87d50472",
   241 => x"84298ad4",
   242 => x"05721383",
   243 => x"712b7208",
   244 => x"07720c53",
   245 => x"53800b8b",
   246 => x"980c800b",
   247 => x"8b940c8b",
   248 => x"b85188e0",
   249 => x"2d8b9c08",
   250 => x"ff24fef8",
   251 => x"38800b8b",
   252 => x"9c0c028c",
   253 => x"050d0402",
   254 => x"f8050d8a",
   255 => x"d4528f51",
   256 => x"80727084",
   257 => x"05540cff",
   258 => x"11517080",
   259 => x"25f23802",
   260 => x"88050d04",
   261 => x"02f0050d",
   262 => x"755186d7",
   263 => x"2d70822c",
   264 => x"fc068ad4",
   265 => x"1172109e",
   266 => x"06710870",
   267 => x"722a7083",
   268 => x"0682742b",
   269 => x"70097406",
   270 => x"760c5451",
   271 => x"56575351",
   272 => x"5386d12d",
   273 => x"718b9c0c",
   274 => x"0290050d",
   275 => x"0402fc05",
   276 => x"0d725180",
   277 => x"710c800b",
   278 => x"84120c02",
   279 => x"84050d04",
   280 => x"02f0050d",
   281 => x"75700884",
   282 => x"12085353",
   283 => x"53ff5471",
   284 => x"712ea838",
   285 => x"86d72d84",
   286 => x"13087084",
   287 => x"29148811",
   288 => x"70087081",
   289 => x"ff068418",
   290 => x"08811187",
   291 => x"06841a0c",
   292 => x"53515551",
   293 => x"515186d1",
   294 => x"2d715473",
   295 => x"8b9c0c02",
   296 => x"90050d04",
   297 => x"02f8050d",
   298 => x"86d72de0",
   299 => x"08708b2a",
   300 => x"70810651",
   301 => x"52527080",
   302 => x"2e9d388b",
   303 => x"b8087084",
   304 => x"298bc005",
   305 => x"7381ff06",
   306 => x"710c5151",
   307 => x"8bb80881",
   308 => x"1187068b",
   309 => x"b80c5180",
   310 => x"0b8be00c",
   311 => x"86ca2d86",
   312 => x"d12d0288",
   313 => x"050d0402",
   314 => x"fc050d8b",
   315 => x"b85188cd",
   316 => x"2d87f72d",
   317 => x"89a45186",
   318 => x"c62d0284",
   319 => x"050d0400",
   320 => x"00ffffff",
   321 => x"ff00ffff",
   322 => x"ffff00ff",
   323 => x"ffffff00",
   324 => x"50726573",
   325 => x"73204631",
   326 => x"2d463420",
   327 => x"746f2063",
   328 => x"68616e67",
   329 => x"65207061",
   330 => x"74746572",
   331 => x"6e0a0000",
   332 => x"50726573",
   333 => x"73204631",
   334 => x"3220746f",
   335 => x"2073686f",
   336 => x"772f6869",
   337 => x"64652074",
   338 => x"6865204f",
   339 => x"53440a00",
   340 => x"00000002",
   341 => x"00000000",
   342 => x"00000000",
   343 => x"00000000",
   344 => x"00000000",
   345 => x"00000000",
   346 => x"00000000",
   347 => x"00000000",
   348 => x"00000000",
   349 => x"00000000",
   350 => x"00000000",
   351 => x"00000000",
   352 => x"00000000",
   353 => x"00000000",
   354 => x"00000000",
   355 => x"00000000",
   356 => x"00000000",
   357 => x"00000000",
   358 => x"00000000",
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

