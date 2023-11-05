library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity hex_dec_char is
port(
	sw_i: in std_ulogic_vector(2 downto 0);
	blank_i: in std_ulogic;
	hex1_o: out std_ulogic_vector(6 downto 0);
	hex2_o: out std_ulogic_vector(6 downto 0);
	hex3_o: out std_ulogic_vector(6 downto 0)
);
end hex_dec_char;

architecture implementation of hex_dec_char is
begin
	hex1_o <= "1111111" when blank_i='1' else --Least Significant hex
		"1111111" when sw_i="000" else	--Blank
		"1000110" when sw_i="001" else 	--C
		"0001100" when sw_i="010" else	--P
		"1001111" when sw_i="100" else	--I
		"1001100";						--R
	hex2_o <= "1111111" when blank_i='1' else
		"1111111" when sw_i="000" else	--Blank
		"1000000" when sw_i="001" else 	--O
		"0001000" when sw_i="010" else	--A
		"1000110" when sw_i="100" else	--C
		"1001100";						--R
	hex3_o <= "1111111" when blank_i='1' else --Most Significant hex
		"1111111" when sw_i="000" else	--Blank
		"1001100" when sw_i="001" else 	--R
		"0001100" when sw_i="010" else	--P
		"0010010" when sw_i="100" else	--S
		"0000110";						--E
end implementation;
