library ieee;
use ieee.std_logic_1164.all;

entity seven_segment_decoder is
port(
	sw_i: 		in 	std_ulogic_vector(3 downto 0);
   	blank_i: 	in 	std_ulogic;
   	hex_o: 		out 	std_ulogic_vector(6 downto 0)
);
end seven_segment_decoder;

architecture implementation of seven_segment_decoder is
begin
		hex_o <= 	"1111111" when blank_i='1' else
					"1000000" when sw_i="0000" else
					"1111001" when sw_i="0001" else
					"0100100" when sw_i="0010" else
					"0110000" when sw_i="0011" else
					"0011001" when sw_i="0100" else
					"0010010" when sw_i="0101" else
					"0000010" when sw_i="0110" else
					"1111000" when sw_i="0111" else
					"0000000" when sw_i="1000" else
					"0010000" when sw_i="1001" else
					"0001000" when sw_i="1010" else
					"0000011" when sw_i="1011" else
					"1000110" when sw_i="1100" else
					"0100001" when sw_i="1101" else
					"0000110" when sw_i="1110" else
					"0001110" when sw_i="1111";
end implementation;