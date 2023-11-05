library ieee;
use ieee.std_logic_1164.all;

entity assignment_final_top is
port(
    CLOCK_50		:in  std_ulogic;                     	-- clk input
    KEY				:in  std_ulogic_vector(3 downto 0);  	-- rst (KEY[0]) and send(KEY[1]) inputs
	SW				:in std_ulogic_vector(3 downto 0);   	-- input switches
	SW_GAME_MODE	:in std_ulogic;   						-- game mode switch (SW[9])
    IRDA_RXD		:in  std_ulogic;                     	-- IR input
	IRDA_TXD		:out std_ulogic;                     	-- IR output
    HEX0			:out std_ulogic_vector(6 downto 0);  	-- HEX digit o/p tx
    HEX2			:out std_ulogic_vector(6 downto 0);  	-- HEX digit o/p rx
	HEX3			:out std_ulogic_vector(6 downto 0);  	-- HEX char o/p rps
	HEX4			:out std_ulogic_vector(6 downto 0);  	-- HEX char o/p rps
	HEX5			:out std_ulogic_vector(6 downto 0);  	-- HEX char o/p rps
    LEDR			:out std_ulogic_vector(9 downto 0);  	-- LED chase o/p
	GPIO_0			:out std_ulogic_vector(35 downto 0)		-- Debug monitoring GPIOs
);
end entity;

architecture implementation of assignment_final_top is
    
---------------------------------------------
-- Component declarations
---------------------------------------------

-- Decoding 4 bit input to hex on sev seg display 0 and 2
component seven_segment_decoder is
	port (
		sw_i		:in std_ulogic_vector(3 downto 0);
		blank_i		:in std_ulogic;
		hex_o		:out std_ulogic_vector(6 downto 0)
	);
end component;

-- Decoding 3 bit input to characters on sev seg displays 3, 4 and 5
component hex_dec_char is
	port(
		sw_i		:in std_ulogic_vector(2 downto 0);
		blank_i		:in std_ulogic;
		hex1_o		:out std_ulogic_vector(6 downto 0);
		hex2_o		:out std_ulogic_vector(6 downto 0);
		hex3_o		:out std_ulogic_vector(6 downto 0)
	);
end component;

-- Led chaser for RPS result
component led_chase is
	port(
		result_i	:in std_ulogic_vector(1 downto 0);
		clk_i		:in std_ulogic;
		led_o		:out std_ulogic_vector(9 downto 0)
	);
end component;

-- Clock divider for led chaser
component clock_divider is
	generic (
		divisor: natural);
	port(
		clk			:in std_ulogic;
		rst			:in std_ulogic;
		clk_div		:out std_ulogic
	);
end component;

-- Processing received IR inputs
component FSM_IR_rx is
	generic(
		BAUD        :natural;
		CLK_FREQ    :natural
	);
	port (
		rst_i		:in std_ulogic;
		clk_i		:in std_ulogic;
		IR_rx_i		:in std_ulogic;
		digit_o		:out std_ulogic_vector(3 downto 0)
	);
end component;


-- Processing IR transmissions
component FSM_IR_tx is
    generic(
        BAUD        :natural;
        CLK_FREQ    :natural;
		PLZ_FREQ    :natural
    );
    port (
        clk50_i		:in std_ulogic;
		rst_i 		:in std_ulogic;
		send_i		:in std_ulogic;
        sw_i		:in std_ulogic_vector(3 downto 0);
        IR_o		:out std_ulogic
    );
end component;

-- Rock Paper Scissors game FSM
component FSM_rps is
	port(
		clk_i 		:in STD_ULOGIC;
		rst_i 		:in STD_ULOGIC;
		send_i 		:in STD_ULOGIC;
		game_mode_i :in STD_ULOGIC;
		rps_i 		:in STD_ULOGIC_VECTOR(3 downto 0);
		digit_rx_i 	:in STD_ULOGIC_VECTOR(3 downto 0);
		result_o 	:out STD_ULOGIC_VECTOR(1 downto 0)
	);
end component;


---------------------------------------------
-- Variable declarations
---------------------------------------------

-- Constants
constant CLK_FREQ	:integer := 50000000;
constant BAUD		:integer := 1000;
constant PLZ_FREQ	:integer := 50000;

-- SIGNAL DECLARATIONS
signal rst			:std_ulogic	:= '0';
signal clk_10		:std_ulogic	:= '0';
signal blank_a		:std_ulogic	:= '0';
signal blank_b		:std_ulogic	:= '1';
signal result		:std_ulogic_vector(1 downto 0) 	:= "00";
signal input_digit	:std_ulogic_vector(3 downto 0) 	:= "0000";
signal input_rps	:std_ulogic_vector(3 downto 0) 	:= "0000";

signal hex0_sig		:std_ulogic_vector(3 downto 0) 	:= "0000";
signal hex2_sig		:std_ulogic_vector(3 downto 0) 	:= "0000";
signal hex3_sig		:std_ulogic_vector(3 downto 0) 	:= "0000";
signal hex4_sig		:std_ulogic_vector(3 downto 0) 	:= "0000";
signal hex5_sig		:std_ulogic_vector(3 downto 0) 	:= "0000";

signal sw0			:std_ulogic_vector(3 downto 0)	:= "0000";
signal send			:std_ulogic	:= '0';


---------------------------------------------
-- Architecture
---------------------------------------------

begin
    
	---------------------------------------------
    -- Combinatorial statements
	---------------------------------------------
	
	rst 		<= not KEY(0);
	send 		<= not KEY(1);
	
	blank_a 	<= not blank_b;
	blank_b 	<= '0' when SW_GAME_MODE = '1' else '1';
	
	input_digit <= SW when SW_GAME_MODE = '0' else "0000";
	input_rps 	<= SW when SW_GAME_MODE = '1' else "0000";

	---------------------------------------------
    -- Module instantiations
    ---------------------------------------------

	-- tx value HEX
    sev_seg_0 : seven_segment_decoder port map(
        sw_i 		=> input_digit,
        blank_i 	=> blank_a,
        hex_o       => HEX0
    );

	-- rx value HEX
    sev_seg_2 : seven_segment_decoder port map(
        sw_i        => hex2_sig,
        blank_i     => blank_a,
        hex_o       => HEX2
    );
    
	-- RPS char to 3 displays
	sev_seg_3 : hex_dec_char port map(
        sw_i	    => input_rps(2 downto 0),
        blank_i     => blank_b,
        hex1_o      => HEX3,
		hex2_o      => HEX4,
		hex3_o      => HEX5
    );

	clk_div_0 : clock_divider 
	generic map(
		divisor		=> 5000000 -- 10Hz
	)
	port map(
		clk 		=> CLOCK_50, 
		rst 		=> rst, 
		clk_div 	=> clk_10
	);
	
	led_0 : led_chase
	port map(
		result_i 	=> result,
		clk_i 		=> clk_10,
		led_o 		=> LEDR
	);
	
    state_machine_rx : FSM_IR_rx
    generic map(
        BAUD        => BAUD,
        CLK_FREQ    => CLK_FREQ
    )
    port map(
        rst_i       => rst,
        clk_i       => CLOCK_50,
        IR_rx_i     => IRDA_RXD,
        digit_o     => hex2_sig
    );

    state_machine_tx : FSM_IR_tx 
    generic map(
        BAUD => BAUD,
        CLK_FREQ => CLK_FREQ,
		PLZ_FREQ => PLZ_FREQ
    )
    port map(
        clk50_i 	=> CLOCK_50,
		rst_i 		=> rst,
		send_i 		=> send,
        sw_i	 	=> SW,
		--IR_o 		=> IRDA_TXD
        IR_o 		=> GPIO_0(0)
    );
	
	state_machine_rps : FSM_rps
	port map(
		clk_i		=> CLOCK_50,
		rst_i 		=> rst,
		send_i 		=> send,
		game_mode_i => SW_GAME_MODE,
		rps_i 		=> input_rps,
		digit_rx_i 	=> hex2_sig,
		result_o 	=> result
	);
	

end architecture;