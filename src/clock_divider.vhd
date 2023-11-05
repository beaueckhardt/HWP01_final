library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity clock_divider is
	generic (
		divisor: natural);
port(
	clk: in std_ulogic;
	rst: in std_ulogic;
	clk_div: out std_ulogic := '0'
);
end clock_divider;

architecture implementation of clock_divider is


begin
	process(clk, rst)
	variable count: integer := 0;
	begin
	if (rst = '1') then
		count := 0;
		clk_div <= '0';
	elsif rising_edge(clk) then
	 	count := count+1;
		if (count = divisor/2) then
			clk_div <= not clk_div;
			count := 0;
		end if;
	end if;	
	end process;
	
end implementation;