library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity led_chase is
port(
	result_i: in std_ulogic_vector(1 downto 0);
	--rst_i: in std_ulogic;
	clk_i: in std_ulogic;
	led_o: out std_ulogic_vector(9 downto 0)
);
end led_chase;

architecture implementation of led_chase is
begin
	process(clk_i, result_i)
	variable i: integer := 0;
	variable reverse: integer :=0;
	begin
	if result_i /= "00" then
		if rising_edge(clk_i) then
			if result_i = "10" and reverse = 0 then
				if i = 0 then
					led_o <= "0000000000";
					led_o(i) <= '1';
					i := i+1;
				elsif i /= 9 then
					led_o <= "0000000000";
					led_o(i) <= '1';
					i := i+1;
				else
					led_o <= "0000000000";
					led_o(i) <= '1';
					reverse := 1;
				end if;
			elsif result_i = "10" and reverse = 1 then
				if i = 9 then
					led_o <= "0000000000";
					led_o(i) <= '1';
					i := i-1;
				elsif i /= 0 then
					led_o <= "0000000000";
					led_o(i) <= '1';
					i := i-1;
				else
					led_o <= "0000000000";
					led_o(i) <= '1';
					reverse := 0;
				end if;
			elsif result_i = "01" then
				if led_o /= "0000000000" and led_o /= "1111111111" then
					led_o <= "0000000000";
				else
					led_o <= not led_o;
				end if;
			else
				led_o <= "1111111111";
			end if;
		end if;
	else
		i := 0;
		reverse := 0;
		led_o <= "0000000000";
	end if;	
	end process;
end implementation;