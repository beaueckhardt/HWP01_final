library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- The entity of your testbench. No ports declaration in this case.
entity led_chase_tb is
end entity;

architecture testbench of led_chase_tb is
    -- The component declaration should match your entity.
    -- It is very important that the name of the component and the 
    -- ports (remember direction of ports!) match your entity! 
	component led_chase is
	port(
		result_i: in std_ulogic_vector(1 downto 0);
		--rst_i: in std_ulogic;
		clk_i: in std_ulogic;
		led_o: out std_ulogic_vector(9 downto 0)
	);
	end component;
		-- Signal declaration. These signals are used to drive your
    -- inputs and store results (if required).
	signal clk_tb: std_ulogic := '0';
	constant clk_cycles1: integer := 1000;
	

	--tb signals
	signal result_tb: std_ulogic_vector(1 downto 0) := "00";
	signal rst_tb:  std_ulogic := '0';
	signal led_tb: std_ulogic_vector(9 downto 0) := "0000000000";
	signal blink: std_ulogic_vector(9 downto 0) := "0000000000";

begin
    -- A port map is in this case nothing more than a construction to
    -- connect your entity ports with your signals.
    duv : led_chase 
	port map(
		clk_i => clk_tb, 		-- clock input 1
		--rst_i => rst_tb,		-- reset
		result_i => result_tb,	-- result input
		led_o => led_tb			-- led output
    );



	process
	-- process for the clock
	begin
		for i in 0 to clk_cycles1 loop
			clk_tb <= not clk_tb;
			wait for 10 ns;
			clk_tb <= not clk_tb;
			wait for 10 ns;
		end loop;
	end process;
	
	process(led_tb)
	variable i: integer :=0;
	variable reverse: integer :=0;
	variable led_test: std_ulogic_vector(9 downto 0) :="0000000000";
	begin
		-- in this test it is tested if the right led has been turned on and the others off
		-- for the led_chase.
		if result_tb = "10" and reverse = 0 then
			if i = 0 then
				led_test := "0000000000";
				led_test(i) := '1';
				assert led_tb = led_test
				report "test failed for led(i) = " & to_string(i)
				severity error;
				i := i+1;
			elsif i /= 9 then
				led_test := "0000000000";
				led_test(i) := '1';
				assert led_tb = led_test
				report "test failed for led(i) = " & to_string(i)
				severity error;
				i := i+1;
			else
				led_test := "0000000000";
				led_test(i) := '1';
				assert led_tb = led_test
				report "test failed for led(i) = " & to_string(i)
				severity error;
				i := i-1;
				reverse := 1;
			end if;
		elsif result_tb = "10" and reverse = 1 then
			if i /= 0 then
				led_test := "0000000000";
				led_test(i) := '1';
				assert led_tb = led_test
				report "test failed for reverse led(i) = " & to_string(i)
				severity error;
				i := i-1;
			else
				led_test := "0000000000";
				led_test(i) := '1';
				assert led_tb = led_test
				report "test failed for reverse led(i) = " & to_string(i)
				severity error;
				i := i+1;
				reverse := 0;
			end if;
		-- in this test it is tested if all the led blink
		elsif result_tb = "01" then
			i := 0;
			if led_tb /= "0000000000" and led_tb /= "1111111111" then
				report "test failed for blink led"
				severity error;
			else
				assert led_tb = not blink
				report "test failed for blink led = " & to_string(led_tb)
				severity error;
				blink <= led_tb;
			end if;	
		end if;
	end process;
		
	process

    begin
        report "Testing entity fsm.";
		result_tb <= "00";
		wait for 10 us;
		assert led_tb = "0000000000" -- here it is tested of all lights are off
		report "test failed for result = 00 "
		severity error;
		
		result_tb <= "01";
		wait for 10 us;

			
		result_tb <= "10";
        wait for 10 us;

		result_tb <= "11";
        wait for 10 us;
		assert led_tb = "1111111111" -- here it is tested of all lights are on
		report "test failed for result = 11 "
		severity error;
		
        wait for 25 us;
		report "Test completed.";
        std.env.stop;
    end process;
end architecture;




