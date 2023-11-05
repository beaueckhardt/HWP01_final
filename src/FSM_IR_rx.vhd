library ieee;
use ieee.std_logic_1164.all;

entity FSM_IR_rx is
    generic(
        BAUD        : natural;
        CLK_FREQ    : natural
    );
    port (
        rst_i       :in std_ulogic;
        clk_i       :in std_ulogic;
        IR_rx_i     :in std_ulogic;
        digit_o     :out std_ulogic_vector(3 downto 0)
    );
end FSM_IR_rx;

architecture behavior of FSM_IR_rx is

-- reset and CDC signals
signal rst                  : std_ulogic := '0';
signal rst_cdc              : std_ulogic_vector(1 downto 0) := (others => '1');
signal rx_cdc               : std_ulogic_vector(1 downto 0) := (others => '1');

-- states
type state_type is (
    idle,
    data,
    store
    );
signal state, nx_state      : state_type;

-- data signals
signal ir_val               : std_ulogic_vector(3 downto 0) := "0000";
signal data_rx              : std_logic := '0';
signal data_rx_valid        : std_logic := '0';
signal data_rx_error        : std_logic := '0';

-- counter signals
constant CLK_TO_BIT         : integer := CLK_FREQ / BAUD;
signal rx_bit_count         : integer range 0 to 4 := 0;
signal rx_clk_count         : integer range 0 to CLK_TO_BIT - 1 := 0;
signal rx_clk_count_half    : std_ulogic := '0';
signal rx_clk_count_max     : std_ulogic := '0';
signal pulse_width_ctr      : integer range 0 to CLK_TO_BIT - 1 := 0;

begin

    ---------------------------------------------
    -- RESET CDC
    ---------------------------------------------
    rst_sync : process(clk_i)
    begin
        if rising_edge(clk_i) then
            if rst_i = '1' then
                rst_cdc <= (others => '1');
            else
                rst_cdc(0) <= rst_i;
                rst_cdc(1) <= rst_cdc(0);
            end if;
        end if;
    end process rst_sync;
    
    rst <= rst_cdc(1);

    ---------------------------------------------
    -- IR RX CDC
    ---------------------------------------------
    rx_sync : process(clk_i)
    begin
        if rising_edge(clk_i) then
            if rst = '1' then
                rx_cdc <= (others => '1');
            else
                rx_cdc(0) <= IR_rx_i;
                rx_cdc(1) <= rx_cdc(0);
            end if;
        end if;
    end process rx_sync;
    

    ---------------------------------------------
    -- BAUD counter
    ---------------------------------------------

    rx_clk_count_half <= '1' when rx_clk_count = CLK_TO_BIT / 2 else '0';
    rx_clk_count_max  <= '0' when rx_clk_count < CLK_TO_BIT - 1 else '1';
    
    ---------------------------------------------
    -- RX State Machine
    ---------------------------------------------

    decoder : process(clk_i)
    begin
    
        if rising_edge(clk_i) then
            -- reset parameters and switch states
            if rst then
                state           <= idle;
                ir_val          <= "0000";
                data_rx_error   <= '0'; 
                rx_clk_count    <= 0;
                rx_bit_count    <= 0;
                pulse_width_ctr <= 0;
                data_rx_valid   <= '0';
            else
                state           <= nx_state;
            end if;
            
            -- FSM
            case state is
                -- wait for IR line to go low
                when idle =>
                    data_rx_valid   <= '0';
                    pulse_width_ctr <= 0;
                    
                    -- reset bitcounter afer last bit
                    if rx_bit_count > 3 then
                        rx_bit_count <= 0;
                    
                    -- switch to data state if sequence has started
                    elsif rx_bit_count > 0 then
                        nx_state        <= data;
                        rx_clk_count    <= rx_clk_count + 1;
                    
                    -- switch when dataline is low
                    elsif rx_cdc(1)  = '0' then
                        nx_state        <= data;
                        rx_clk_count    <= rx_clk_count + 1;
                    end if;
                    
                -- receive data and measure pulse width
                when data =>
                    rx_clk_count    <= rx_clk_count + 1;
                    
                    -- count pulsewidth while data line is low
                    if rx_cdc(1)  = '0' then
                        pulse_width_ctr <= pulse_width_ctr + 1;
                        data_rx_valid   <= '0';
                    end if;
                    
                    -- switch to decode when half a baud has passed
                    if rx_clk_count_half = '1' then
                        nx_state <= store;
                    end if;
                
                -- decode and store data
                when store =>
                    rx_clk_count    <= rx_clk_count + 1;
            
                    -- decode received data
                    if pulse_width_ctr > 17500 and pulse_width_ctr < 25000 then
                        data_rx         <= '1'; -- data is bin 1 for long pulse
                        data_rx_valid   <= '1';
                        pulse_width_ctr <= 0;
                    elsif pulse_width_ctr > 7500 and pulse_width_ctr < 17500 then
                        data_rx         <= '0'; -- data is bin 0 for short pulse
                        data_rx_valid   <= '1';
                        pulse_width_ctr <= 0;
                    end if;
                    
                    -- store data at end of baud and switch state
                    if rx_clk_count_max = '1' then
                        rx_bit_count    <= rx_bit_count + 1;
                        rx_clk_count    <= 0;
                        -- store data when data valid
                        if data_rx_valid = '1' then
                            ir_val(rx_bit_count)    <= data_rx;
                            data_rx_valid           <= '0';
                            nx_state                <= idle;
                        -- set error flag when data not valid
                        else
                            ir_val(rx_bit_count)    <= '0';
                            data_rx_error           <= '1'; 
                            nx_state                <= idle;
                        end if;
                    end if;
                        
                end case;
        end if;
            
    end process decoder;
	
    digit_o         <= ir_val;

end architecture;