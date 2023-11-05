
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- The entity of your testbench. No ports declaration in this case.
entity hex_dec_char_tb is
end entity;

architecture testbench of hex_dec_char_tb is
	-- The component declaration should match your entity.
	-- It is very important that the name of the component and the 
    -- ports (remember direction of ports!) match your entity! 
component hex_dec_char is
port(
	sw_i	:in std_ulogic_vector(2 downto 0);
	blank_i	:in std_ulogic;
	hex1_o	:out std_ulogic_vector(6 downto 0);
	hex2_o	:out std_ulogic_vector(6 downto 0);
	hex3_o	:out std_ulogic_vector(6 downto 0)
);
end component;
	-- Signal declaration. These signals are used to drive your
    -- inputs and store results (if required).
	signal sw_tb: std_ulogic_vector(2 downto 0);
	signal blank_tb: std_ulogic;
	signal hex3_tb: std_ulogic_vector(6 downto 0);
	signal hex4_tb: std_ulogic_vector(6 downto 0);
	signal hex5_tb: std_ulogic_vector(6 downto 0);
begin
	-- A port map is in this case nothing more than a construction to
	-- connect your entity ports with your signals.
	duv : hex_dec_char port map(
		sw_i => sw_tb, 
		blank_i => blank_tb, 
		hex1_o => hex3_tb,
		hex2_o => hex4_tb,
		hex3_o => hex5_tb
	);

	process
	begin
		report "Testing entity assignment2.";
		-- Initialize signals.
		sw_tb <= "000";

		blank_tb <= '1';
		wait for 10 ns;
		-- Check blank.
		assert hex3_tb = "1111111"
			report "test failed for hex3 blank = 1" severity error; 
		assert hex4_tb = "1111111"
			report "test failed for hex4 blank = 1" severity error;
		assert hex5_tb = "1111111"
			report "test failed for hex5 blank = 1" severity error;

		blank_tb <= '0';
		wait for 10 ns;
		assert hex3_tb = "1111111"
			report "test failed for hex3 blank = 1" severity error; 
		assert hex4_tb = "1111111"
			report "test failed for hex4 blank = 1" severity error;
		assert hex5_tb = "1111111"
			report "test failed for hex5 blank = 1" severity error;

		sw_tb <= "001";
		wait for 10 ns;
		assert hex3_tb = "1000110"
			report "test roc failed for hex3 C" severity error;
		assert hex4_tb = "1000000"
			report "test roc failed for hex4 O" severity error;
		assert hex5_tb = "1001100"
			report "test roc failed for hex5 R" severity error;
			
		sw_tb <= "010";
		wait for 10 ns;
		assert hex3_tb = "0001100"
			report "test pap failed for hex3 P" severity error;
		assert hex4_tb = "0001000"
			report "test pap failed for hex4 A" severity error;
		assert hex5_tb = "0001100"
			report "test pap failed for hex5 P" severity error;

		sw_tb <= "100";
		wait for 10 ns;
		assert hex3_tb = "1001111"
			report "test sci failed for hex3 I" severity error;
		assert hex4_tb = "1000110"
			report "test sci failed for hex4 C" severity error;
		assert hex5_tb = "0010010"
			report "test sci failed for hex5 S" severity error;

		sw_tb <= "011";
		wait for 10 ns;
		assert hex3_tb = "1001100"
			report "test err1 failed for hex3 E" severity error;
		assert hex4_tb = "1001100"
			report "test err1 failed for hex4 R" severity error;
		assert hex5_tb = "0000110"
			report "test err1 failed for hex5 R" severity error;

		sw_tb <= "101";
		wait for 10 ns;
		assert hex3_tb = "1001100"
			report "test err2 failed for hex3 E" severity error;
		assert hex4_tb = "1001100"
			report "test err2 failed for hex4 R" severity error;
		assert hex5_tb = "0000110"
			report "test err3 failed for hex5 R" severity error;

		sw_tb <= "110";
		wait for 10 ns;
		assert hex3_tb = "1001100"
			report "test err3 failed for hex3 E" severity error;
		assert hex4_tb = "1001100"
			report "test err3 failed for hex4 R" severity error;
		assert hex5_tb = "0000110"
			report "test err3 failed for hex5 R" severity error;

		sw_tb <= "111";
		wait for 10 ns;
		assert hex3_tb = "1001100"
			report "test err4 failed for hex3 E" severity error;
		assert hex4_tb = "1001100"
			report "test err4 failed for hex4 R" severity error;
		assert hex5_tb = "0000110"
			report "test err4 failed for hex5 R" severity error;


		report "Test completed.";
		std.env.stop;
	end process;

end architecture;
