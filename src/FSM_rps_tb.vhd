-------------------------------------------------------------------------------
--
-- Title       : FSM_rps_tb
-- Design      : RPS
-- Author      : Beau
-- Company     : Beau
--
-------------------------------------------------------------------------------
--
-- File        : c:\Users\Beau\Documents\git\Active-HDL\HWP_final_RPS\RPS\src\FSM_rps_tb.vhd
-- Generated   : Thu Nov  2 18:42:33 2023
-- From        : interface description file
-- By          : Itf2Vhdl ver. 1.22
--
-------------------------------------------------------------------------------
--
-- Description : 
--
-------------------------------------------------------------------------------

--{{ Section below this comment is automatically maintained
--   and may be overwritten
--{entity {FSM_rps_tb} architecture {FSM_rps_tb}}
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity FSM_rps_tb is
end entity;

--}} End of automatically maintained section

architecture testbench of FSM_rps_tb is


	component FSM_rps is
		port (
			clk_i				: in 	std_ulogic;							-- clk input
			rst_i				: in  	std_ulogic;
			send_i				: in 	std_ulogic;
			--ready_i			: in  	std_ulogic;
			game_mode_i		: in 	std_ulogic;
			rps_i				: in 	std_ulogic_vector(3 downto 0);  	-- HEX tx
			digit_rx_i			: in 	std_ulogic_vector(3 downto 0);  	-- HEX rx
			blank_o			: out 	std_ulogic;						  	-- HEX output rps
			result_o			: out 	std_ulogic_vector(1 downto 0);  	-- HEX output rps
			char0_o			: out 	std_ulogic_vector(3 downto 0);  	-- HEX output rps
			char1_o			: out 	std_ulogic_vector(3 downto 0);  		-- Result LED outputs
			char2_o			: out 	std_ulogic_vector(3 downto 0)  		-- Result LED outputs
		);
	end component;--
	
	-----------------------------
	-- SIGNAL DECLARATIONS SIM --
	-----------------------------
	
	-- # clock cycles for sim
	constant clk_cycles: 	integer := 1000;
	
	-- signals TB
	signal rst			: std_ulogic	:= '0';
	signal clk			: std_ulogic 	:= '0';
	signal send			: std_ulogic 	:= '0';
	--signal ready		: std_ulogic 	:= '0'; 
	signal game_mode	: std_ulogic 	:= '0';
	signal rps			: std_ulogic_vector(3 downto 0);
	signal digit_rx		: std_ulogic_vector(3 downto 0);
	signal blank		: std_ulogic	:= '0';
	signal result		: std_ulogic_vector(1 downto 0);
	signal char0		: std_ulogic_vector(3 downto 0);
	signal char1		: std_ulogic_vector(3 downto 0);
	signal char2		: std_ulogic_vector(3 downto 0);

	
	begin	
	duv_RPS : FSM_rps port map(
		clk_i			=> clk,
		rst_i 			=> rst,
		send_i 			=> send,
		--ready_i 		=> ready,
		game_mode_i 	=> game_mode,
		rps_i 			=> rps,
		digit_rx_i 		=> digit_rx,
		blank_o 		=> blank,
		result_o 		=> result,
		char0_o 		=> char0,
		char1_o 		=> char1,
		char2_o 		=> char2
	);
	
	---------------------------
	-- Generate clock for TB --
	---------------------------
	process
	
	begin
		for i in 1 to clk_cycles loop
			clk <= not clk;
			wait for 10 ns;
			clk <= not clk;
			wait for 10 ns;
		end loop;
	end process;
	
	---------------
	-- Testbench --
	---------------
	process

	begin
		report "Testing entity FSM_rps.";
	
			
		
			wait for 100 ns;
			game_mode	<= '1';
			
			wait for 100 ns;
			rps 		<= "1010";
			
			wait for 100 ns;
			send 		<= '1';
			
			wait for 100 ns;
			digit_rx 		<= "1001";	 
			
			wait for 1 us;
		std.env.stop;
	end process;
end architecture;
