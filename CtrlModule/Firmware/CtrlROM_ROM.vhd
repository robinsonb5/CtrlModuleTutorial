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
     0 => x"880b0b0b",
     1 => x"0b81e004",
     2 => x"8804ff0d",
     3 => x"80040000",
     4 => x"80e0040b",
     5 => x"80f5040b",
     6 => x"81a2040b",
     7 => x"81b70404",
     8 => x"0b0b0b8b",
     9 => x"90080b0b",
    10 => x"0b8b9408",
    11 => x"0b0b0b8b",
    12 => x"98080b0b",
    13 => x"0b80cc08",
    14 => x"2d0b0b0b",
    15 => x"8b980c0b",
    16 => x"0b0b8b94",
    17 => x"0c0b0b0b",
    18 => x"8b900c04",
    19 => x"0000001f",
    20 => x"00ffffff",
    21 => x"ff00ffff",
    22 => x"ffff00ff",
    23 => x"ffffff00",
    24 => x"71fd0608",
    25 => x"72830609",
    26 => x"81058205",
    27 => x"832b2a83",
    28 => x"ffff0652",
    29 => x"0471fd06",
    30 => x"0883ffff",
    31 => x"73830609",
    32 => x"81058205",
    33 => x"832b2b09",
    34 => x"067383ff",
    35 => x"ff067383",
    36 => x"06098105",
    37 => x"8205832b",
    38 => x"0b2b0772",
    39 => x"fc060c51",
    40 => x"510471fc",
    41 => x"06087283",
    42 => x"06098105",
    43 => x"83051010",
    44 => x"102a81ff",
    45 => x"06520471",
    46 => x"fc06080b",
    47 => x"0b0b80d0",
    48 => x"73830610",
    49 => x"10050806",
    50 => x"7381ff06",
    51 => x"73830609",
    52 => x"81058305",
    53 => x"1010102b",
    54 => x"0772fc06",
    55 => x"0c515104",
    56 => x"8b90708b",
    57 => x"d8278e38",
    58 => x"80717084",
    59 => x"05530c0b",
    60 => x"0b0b81e2",
    61 => x"04885181",
    62 => x"fa0402f0",
    63 => x"050d8053",
    64 => x"815484a2",
    65 => x"2d86b62d",
    66 => x"86c22d0b",
    67 => x"0b0b8a84",
    68 => x"5188d52d",
    69 => x"0b0b0b8a",
    70 => x"a45188d5",
    71 => x"2d84ba2d",
    72 => x"875185f1",
    73 => x"2d8b9008",
    74 => x"812a7081",
    75 => x"06515271",
    76 => x"802e8538",
    77 => x"73813254",
    78 => x"735188f9",
    79 => x"2d855185",
    80 => x"f12d8b90",
    81 => x"08098105",
    82 => x"708b9008",
    83 => x"07700970",
    84 => x"9f2c7606",
    85 => x"56515152",
    86 => x"865185f1",
    87 => x"2d8b9008",
    88 => x"802e8338",
    89 => x"81538451",
    90 => x"85f12d8b",
    91 => x"9008802e",
    92 => x"83388253",
    93 => x"8c5185f1",
    94 => x"2d8b9008",
    95 => x"802e8338",
    96 => x"835372fc",
    97 => x"0c829d04",
    98 => x"02fc050d",
    99 => x"72518071",
   100 => x"0c800b84",
   101 => x"120c0284",
   102 => x"050d0402",
   103 => x"f0050d75",
   104 => x"70088412",
   105 => x"08535353",
   106 => x"ff547171",
   107 => x"2ea83886",
   108 => x"bc2d8413",
   109 => x"08708429",
   110 => x"14881170",
   111 => x"087081ff",
   112 => x"06841808",
   113 => x"81118706",
   114 => x"841a0c53",
   115 => x"51555151",
   116 => x"5186b62d",
   117 => x"7154738b",
   118 => x"900c0290",
   119 => x"050d0402",
   120 => x"f8050d86",
   121 => x"bc2de008",
   122 => x"708b2a70",
   123 => x"81065152",
   124 => x"5270802e",
   125 => x"9d388ba0",
   126 => x"08708429",
   127 => x"8ba80573",
   128 => x"81ff0671",
   129 => x"0c51518b",
   130 => x"a0088111",
   131 => x"87068ba0",
   132 => x"0c51800b",
   133 => x"8bc80c86",
   134 => x"af2d86b6",
   135 => x"2d028805",
   136 => x"0d0402fc",
   137 => x"050d8ba0",
   138 => x"5183882d",
   139 => x"85d42d83",
   140 => x"df5186aa",
   141 => x"2d028405",
   142 => x"0d0402f4",
   143 => x"050d85bc",
   144 => x"048b9008",
   145 => x"81f02e09",
   146 => x"81068938",
   147 => x"810b8b84",
   148 => x"0c85bc04",
   149 => x"8b900881",
   150 => x"e02e0981",
   151 => x"06893881",
   152 => x"0b8b880c",
   153 => x"85bc048b",
   154 => x"9008528b",
   155 => x"8808802e",
   156 => x"88388b90",
   157 => x"08818005",
   158 => x"5271842c",
   159 => x"728f0653",
   160 => x"538b8408",
   161 => x"802e9938",
   162 => x"7284298a",
   163 => x"c4057213",
   164 => x"81712b70",
   165 => x"09730806",
   166 => x"730c5153",
   167 => x"5385b204",
   168 => x"7284298a",
   169 => x"c4057213",
   170 => x"83712b72",
   171 => x"0807720c",
   172 => x"5353800b",
   173 => x"8b880c80",
   174 => x"0b8b840c",
   175 => x"8ba05183",
   176 => x"9b2d8b90",
   177 => x"08ff24fe",
   178 => x"f838800b",
   179 => x"8b900c02",
   180 => x"8c050d04",
   181 => x"02f8050d",
   182 => x"8ac4528f",
   183 => x"51807270",
   184 => x"8405540c",
   185 => x"ff115170",
   186 => x"8025f238",
   187 => x"0288050d",
   188 => x"0402f005",
   189 => x"0d755186",
   190 => x"bc2d7082",
   191 => x"2cfc068a",
   192 => x"c4117210",
   193 => x"9e067108",
   194 => x"70722a70",
   195 => x"83068274",
   196 => x"2b700974",
   197 => x"06760c54",
   198 => x"51565753",
   199 => x"515386b6",
   200 => x"2d718b90",
   201 => x"0c029005",
   202 => x"0d047180",
   203 => x"cc0c04ff",
   204 => x"b0088b90",
   205 => x"0c04810b",
   206 => x"ffb00c04",
   207 => x"800bffb0",
   208 => x"0c0402fc",
   209 => x"050df880",
   210 => x"518f0b8b",
   211 => x"cc0c9f0b",
   212 => x"8bd00ca0",
   213 => x"71708105",
   214 => x"53348bd0",
   215 => x"08ff058b",
   216 => x"d00c8bd0",
   217 => x"088025eb",
   218 => x"388bcc08",
   219 => x"ff058bcc",
   220 => x"0c8bcc08",
   221 => x"8025d738",
   222 => x"800b8bd0",
   223 => x"0c800b8b",
   224 => x"cc0c0284",
   225 => x"050d0402",
   226 => x"f0050df8",
   227 => x"8053f8a0",
   228 => x"5483bf52",
   229 => x"73708105",
   230 => x"55335170",
   231 => x"73708105",
   232 => x"5534ff12",
   233 => x"52718025",
   234 => x"eb38fbc0",
   235 => x"539f52a0",
   236 => x"73708105",
   237 => x"5534ff12",
   238 => x"52718025",
   239 => x"f2380290",
   240 => x"050d0402",
   241 => x"f4050d74",
   242 => x"538e0b8b",
   243 => x"cc08258f",
   244 => x"3887872d",
   245 => x"8bcc08ff",
   246 => x"058bcc0c",
   247 => x"87c9048b",
   248 => x"cc088bd0",
   249 => x"08535172",
   250 => x"8a2e0981",
   251 => x"06b73871",
   252 => x"51719f24",
   253 => x"a0388bcc",
   254 => x"08a02911",
   255 => x"f8801151",
   256 => x"51a07134",
   257 => x"8bd00881",
   258 => x"058bd00c",
   259 => x"8bd00851",
   260 => x"9f7125e2",
   261 => x"38800b8b",
   262 => x"d00c8bcc",
   263 => x"0881058b",
   264 => x"cc0c88b9",
   265 => x"0470a029",
   266 => x"12f88011",
   267 => x"51517271",
   268 => x"348bd008",
   269 => x"81058bd0",
   270 => x"0c8bd008",
   271 => x"a02e0981",
   272 => x"068e3880",
   273 => x"0b8bd00c",
   274 => x"8bcc0881",
   275 => x"058bcc0c",
   276 => x"028c050d",
   277 => x"0402f405",
   278 => x"0d745372",
   279 => x"70810554",
   280 => x"33527180",
   281 => x"2e893871",
   282 => x"5187c32d",
   283 => x"88db0481",
   284 => x"0b8b900c",
   285 => x"028c050d",
   286 => x"0402ec05",
   287 => x"0d800b8b",
   288 => x"d40cf68c",
   289 => x"08f69008",
   290 => x"71882c56",
   291 => x"5481ff06",
   292 => x"52737225",
   293 => x"88387154",
   294 => x"820b8bd4",
   295 => x"0c72882c",
   296 => x"7381ff06",
   297 => x"54557473",
   298 => x"258b3872",
   299 => x"8bd40884",
   300 => x"078bd40c",
   301 => x"5573842b",
   302 => x"86a07125",
   303 => x"83713170",
   304 => x"8b8c0c81",
   305 => x"712bff05",
   306 => x"f6880cfe",
   307 => x"cc13ff12",
   308 => x"2c788829",
   309 => x"ff940570",
   310 => x"812c8bd4",
   311 => x"08525852",
   312 => x"55515254",
   313 => x"76802e85",
   314 => x"38708107",
   315 => x"5170f694",
   316 => x"0c710981",
   317 => x"05f6800c",
   318 => x"72098105",
   319 => x"f6840c02",
   320 => x"94050d04",
   321 => x"50726573",
   322 => x"73204631",
   323 => x"2d463420",
   324 => x"746f2063",
   325 => x"68616e67",
   326 => x"65207061",
   327 => x"74746572",
   328 => x"6e0a0000",
   329 => x"50726573",
   330 => x"73204631",
   331 => x"3220746f",
   332 => x"2073686f",
   333 => x"772f6869",
   334 => x"64652074",
   335 => x"6865204f",
   336 => x"53440a00",
   337 => x"00000000",
   338 => x"00000000",
   339 => x"00000000",
   340 => x"00000000",
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
   355 => x"00000002",
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

