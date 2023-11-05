library ieee;
use ieee.std_logic_1164.all;
--use ieee.numeric_std.all;

entity FSM_IR_rx_tb is
end entity;

architecture testbench of FSM_IR_rx_tb is
    component FSM_IR_rx is
	    generic(
			BAUD        : natural;
			CLK_FREQ    : natural
		);
        port (
			rst_i		: in std_ulogic;
			clk_i		: in std_ulogic;
			IR_rx_i		: in std_ulogic;
			digit_o		: out std_ulogic_vector(3 downto 0)
        );
    end component;

	signal rst: std_ulogic := '1';
	signal clk: std_ulogic := '0';
	constant clk_cycles1: integer := 100000000;
	

	signal IR_rx_i: std_ulogic:= '1';
	signal digit: std_ulogic_vector(3 downto 0) := "0000";

	signal total_expected_count: integer :=0;
	signal total_count: integer :=0;


begin

    duv : FSM_IR_rx 
	generic map(
		CLK_FREQ 	=> 50000000,
		BAUD 		=> 1000
	)
	port map(
		rst_i 		=> rst,		
		clk_i 		=> clk, 	
		IR_rx_i 	=> IR_rx_i,
		digit_o 	=> digit		
    );



	process
	begin
		for i in 0 to clk_cycles1 loop
			clk <= not clk;
			wait for 10 ns;
			clk <= not clk;
			wait for 10 ns;
		end loop;
	end process;
	

	process(clk, rst, IR_rx_i)
	variable i: integer :=0;
	variable count: integer :=0;
	variable expected_count: integer :=0;
	begin
		if rst = '0' then
				if IR_rx_i = '0' then
					report "Testing incoming datastream";
				end if;
				if IR_rx_i = '1' then
				/*
					if sw_tb(i) = '1' and count = 15 then
						count := 0;
						--saves the value readed from the pulses
						data_tb(i) <= '1';
						i := i+1;
					elsif sw_tb(i) = '0' and count = 7 then						
						count := 0;
						data_tb(i) <= '0';
						i := i+1;
					else
						total_count <= total_count + 1;
						count := count+1;
					end if;
					if i = 4 then
					expected_count := 0;
						for j in 0 to 3 loop
							if sw_tb(j) then
								expected_count := expected_count + 15;
							else
								expected_count := expected_count + 7;
							end if;
						end loop;
						total_expected_count <= total_expected_count + expected_count;
						i := 0;
					end if;
			*/
				end if;
			else
				count := 0;
				i := 0;
		end if;
	end process;
		
	process

    begin
        report "Testing IR rx";
		/*
		sw_tb <= "0001";
		wait for 10 us;
        rst <= '0';
        wait for 10 us;
        send <= '1';
        wait for 5 us;
        send <= '0';
        wait for 10 ms;
		
		assert data_tb = sw_tb
		report "test failed for sw = " & to_string(sw_tb)
		severity error;
		
		assert total_count = total_expected_count
		report "test failed for total pulse count = " & to_string(total_count)
		severity error;
		
		
        rst <= '1';
        wait for 10 us;
        rst <= '0';
		
		sw_tb <= "0000";
        wait for 10 us;
        send <= '1';
        wait for 5 us;
        send <= '0';
        wait for 10 ms;
		
		assert data_tb = sw_tb
		report "test failed for sw = " & to_string(sw_tb)
		severity error;
		
		assert total_count = total_expected_count
		report "test failed for total pulse count = " & to_string(total_count)
		severity error;
		
		sw_tb <= "0010";
       wait for 10 us;
       send <= '1';
       wait for 5 us;
       send <= '0';
       wait for 10 ms;
	   
		assert data_tb = sw_tb
		report "test failed for sw = " & to_string(sw_tb)
		severity error;
		
		assert total_count = total_expected_count
		report "test failed for total pulse count = " & to_string(total_count)
		severity error;
		
		sw_tb <= "1010";
        wait for 10 us;
        send <= '1';
        wait for 5 us;
        send <= '0';
        wait for 10 ms;
		
		assert data_tb = sw_tb
		report "test failed for sw = " & to_string(sw_tb)
		severity error;
		
		assert total_count = total_expected_count
		report "test failed for total pulse count = " & to_string(total_count)
		severity error;
		
		sw_tb <= "1110";
        wait for 10 us;
        send <= '1';
        wait for 5 us;
        send <= '0';
        wait for 10 ms;
		assert data_tb = sw_tb
		report "test failed for sw = " & to_string(sw_tb)
		severity error;

		assert total_count = total_expected_count
		report "test failed for total pulse count = " & to_string(total_count)
		severity error;

		sw_tb <= "1111";
        wait for 10 us;
        send <= '1';
        wait for 5 us;
        send <= '0';
        wait for 10 ms;
		assert data_tb = sw_tb
		report "test failed for sw = " & to_string(sw_tb)
		severity error;


		assert total_count = total_expected_count
		report "test failed for total pulse count = " & to_string(total_count)
		severity error;


        wait for 25 us;
		*/
		report "Test completed.";
        std.env.stop;
    end process;
end architecture;



