library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity assignment_final_tb is
end entity;

architecture testbench of assignment_final_tb is
	component assignment_final_top is
		port (
			CLK_50MHZ:		in 	std_ulogic;						-- clk input
			KEY0: 			in 	std_ulogic;						-- rst input
			IR_i: 			in 	std_ulogic;						-- IR input
			HEX0: 			out std_ulogic_vector(6 downto 0) 	-- HEX output
		);
	end component;
	
	-- SIGNAL DECLARATIONS SIM
	-- # clock cycles for sim
	constant clk_cycles: 	integer := 10000;
	
	-- signals TB
	signal rst: 	std_ulogic:= '0';
	signal clk: std_ulogic := '0';
	signal blank: std_ulogic := '0';
	signal ir_i_tb: std_ulogic := '1';
	signal hex0_sig: std_ulogic_vector(3 downto 0);
	signal hex0_o_tb: 	std_ulogic_vector(6 downto 0);
	
	
begin

	duv_top : assignment_final_top port map(
			CLK_50MHZ	=> clk,
			KEY0 		=> rst,
			IR_i 		=> ir_i_tb,
			HEX0 		=> hex0_o_tb
	);

	-- clock gen
	process
	
	begin
		for i in 1 to clk_cycles loop
		clk <= not clk;
		wait for 10 ms;
		clk <= not clk;
		wait for 10 ms;
		end loop;
	end process;


	-- testbench
	process

	begin
		report "Testing entity final assignment.";
		wait for 30 ms;
		ir_i_tb <= '0'; -- start bit 0
		wait for 50 ms;
		ir_i_tb <= '0'; -- start bit 1
		wait for 100 ms;
		ir_i_tb <= '1'; -- data bit 0
		wait for 100 ms;
		ir_i_tb <= '0'; -- data bit 1
		wait for 80 ms;
		ir_i_tb <= '1'; -- data bit 2
		wait for 80 ms;
		ir_i_tb <= '1'; -- data bit 3
		wait for 80 ms;
		ir_i_tb <= '0'; -- stop bit 0
		wait for 80 ms;
		ir_i_tb <= '0'; -- stop bit 1
		wait for 80 ms;
		ir_i_tb <= '1'; -- stop bit 1
		wait for 400 ms;
		rst <= '1';
		wait for 200 ms;
		rst <= '0';
		wait for 2000 ms;

		std.env.stop;
	end process;
end architecture;
