library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- The entity of your testbench. No ports declaration in this case.
entity fsm_tb is
end entity;

architecture testbench of fsm_tb is
    -- The component declaration should match your entity.
    -- It is very important that the name of the component and the 
    -- ports (remember direction of ports!) match your entity! 
    component finite_state_machine is
	    generic(
			BAUD        : natural;
			CLK_FREQ    : natural;
			PLZ_FREQ	: natural
		);
        port (
			clk50_i, rst_i, send_i: in std_ulogic;
			sw_i: in std_ulogic_vector(3 downto 0);
			--state_now: out std_ulogic_vector(3 downto 0);
			IR_o: out std_ulogic
        );
    end component;
    -- Signal declaration. These signals are used to drive your
    -- inputs and store results (if required).
	signal clk50_tb: std_ulogic := '0';
	constant clk_cycles1: integer := 100000000;
	
	--reset
	signal rst:     std_ulogic:= '1';

	--FSM
	signal send: std_ulogic:= '0';
	signal sw_tb: std_ulogic_vector(3 downto 0) := "0000";
	signal IR_tb: std_ulogic;
	signal data_tb: std_ulogic_vector(3 downto 0) := "0000";

	signal total_expected_count: integer :=0;
	signal total_count: integer :=0;
begin
    -- A port map is in this case nothing more than a construction to
    -- connect your entity ports with your signals.
    duv : finite_state_machine 
	generic map(
		CLK_FREQ => 50000000,
		BAUD => 1000,
		PLZ_FREQ => 50000
	)
	port map(
		clk50_i => clk50_tb, 	-- clock input 1
		rst_i => rst,		-- key0 input
		send_i => send,		-- key1 input
		sw_i => sw_tb,		-- switch input
		IR_o => IR_tb		-- IR output
		--state_now => state_tb	-- state voor testbench
    );



	process
	-- process for the clock
	begin
		for i in 0 to clk_cycles1 loop
			clk50_tb <= not clk50_tb;
			wait for 10 ns;
			clk50_tb <= not clk50_tb;
			wait for 10 ns;
		end loop;
	end process;
	

	process(send, rst, IR_tb)
	variable i: integer :=0;
	variable count: integer :=0;
	variable expected_count: integer :=0;
	begin
		if rst = '0' then
				if send = '1' then
					report "test started for start bit ";
				end if;
				if IR_tb = '1' then
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
				end if;
			else
				count := 0;
				i := 0;
		end if;
	end process;
		
	process
	-- here we test if the values read from the pulses are equal to the value of sw_tb
	--(the value put into the transmitter)
	-- Failure happens when the wrong value has been send.
	
	--also testing if the counted pulses are equal to the expected pulses for the value of
	--sw_tb. failure means that there are too much, too little pulses or the wrong value
	-- has been transmitted
    begin
        report "Testing entity fsm.";
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
		report "Test completed.";
        std.env.stop;
    end process;
end architecture;



