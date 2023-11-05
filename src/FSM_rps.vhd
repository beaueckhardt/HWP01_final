-------------------------------------------------------------------------------
--
-- Title       : rps_entity
-- Design      : RPS
-- Author      : Beau
-- Company     : Beau
--
-------------------------------------------------------------------------------
--
-- File        : c:\Users\Beau\Documents\git\Active-HDL\HWP_final_RPS\RPS\src\FSM_rps.vhd
-- Generated   : Thu Nov  2 18:17:58 2023
-- From        : interface description file
-- By          : Itf2Vhdl ver. 1.22
--
-------------------------------------------------------------------------------
--
-- Description : Statemachine for RockPaperScissors game using IR_tx and
-- 				 IR_rx modules
--
-------------------------------------------------------------------------------

--{{ Section below this comment is automatically maintained
--   and may be overwritten
--{entity {rps_entity} architecture {rps_architecture}}

library IEEE;
use IEEE.std_logic_1164.all;

entity FSM_rps is
	 port(
		 clk_i 			: in STD_ULOGIC;
		 rst_i 			: in STD_ULOGIC;
		 send_i 		: in STD_ULOGIC;
		 game_mode_i 	: in STD_ULOGIC;
		 rps_i 			: in STD_ULOGIC_VECTOR(3 downto 0);
		 digit_rx_i 	: in STD_ULOGIC_VECTOR(3 downto 0);
		 result_o 		: out STD_ULOGIC_VECTOR(1 downto 0)
	     );
end FSM_rps;

--}} End of automatically maintained section

architecture rps_architecture of FSM_rps is


--------------------------
-- Signal declarations  --
--------------------------
type state_type is (idle, game, ready, result);

signal present_state, next_state : state_type;
signal result_temp : std_ulogic_vector(1 downto 0) := "00";
signal digit_rx_temp : std_ulogic_vector(3 downto 0) := "0000";

-------------------
-- State machine --
-------------------

begin
	--------------------
	-- state register --
	--------------------
	process (clk_i, rst_i)
	begin
		if rst_i = '1' then
			present_state <= idle;
		elsif rising_edge(clk_i) then
			present_state <= next_state;
		end if;
	end process;
	
	
 	---------------------------------------
	-- logic to determine the next state --
	---------------------------------------
	process (present_state, send_i, game_mode_i, digit_rx_i)
	begin
		case present_state is
		
			when idle => 
				result_temp <= "00";                     ------!------!------!------!
				digit_rx_temp  <= "0000"; 
				if game_mode_i = '1' then
					next_state <= game;
				else
					next_state <= idle;
				end if;
				
			when game =>
				-- enable ready state once valid input is given
				if game_mode_i = '1' and rps_i > "1000" then
					next_state <= ready;
				elsif game_mode_i = '0' then
					next_state <= idle;
				else
					next_state <= game;
				end if;
				
			when ready =>
				-- enable send if input is valid and ready is high
				if (rps_i = "1001" xor rps_i = "1010" xor rps_i = "1100") then
					if send_i = '1' then
						-- send stuff
					next_state <= result;
					end if;
				-- return if game, ready or input goes back to 0	
				elsif game_mode_i = '0' or rps_i(3) = '0' then		
					next_state <= idle;
				else
					next_state <= ready;
				end if;
				
			when result =>
				------------------------------------------
				-- determine winner when value received --
				------------------------------------------
				digit_rx_temp		<= digit_rx_i;	
				
				if digit_rx_temp /= "0000" then
					-------------------
					-- when scissors --
					-------------------
					if rps_i = "1100" then
						if digit_rx_temp = "1001" then
							result_temp <= "10"; 	-- won
						elsif digit_rx_temp = "1010" then
							result_temp <= "01";	-- lost
						elsif digit_rx_temp = "1100" then
							result_temp <= "11";	-- draw
						end if;
					end if;
					
					---------------
					-- when rock --
					---------------
					if rps_i = "1010" then
						if digit_rx_temp = "1001" then
							result_temp <= "01"; 	-- lost
						elsif digit_rx_temp = "1010" then
							result_temp <= "11";	-- draw
						elsif digit_rx_temp = "1100" then
							result_temp <= "10";	-- won
						end if;
					end if;
					
					----------------
					-- when paper --
					----------------
					if rps_i = "1001" then
						if digit_rx_temp = "1001" then
							result_temp <= "11"; 	-- draw
						elsif digit_rx_temp = "1010" then
							result_temp <= "10";	-- won
						elsif digit_rx_temp = "1100" then
							result_temp <= "01";	-- lost
						end if;
					end if;
				
				-- stay here untill value is received or reset
				else
					result_temp <= "00";
					next_state <= result;
				end if;
		end case;
	end process;
	
	
	------------------------------------
	-- Logic to determine the outputs --
	------------------------------------
	process (present_state)
	begin
		case present_state is
			when idle => 
				result_o 		<= "00";

			when game => 
				result_o 		<= "00";
				
			when ready => 
				result_o 		<= "00";

			when result =>
						
				result_o 		<= result_temp;

		end case;
	end process;

end architecture;
