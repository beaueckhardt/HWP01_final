library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity FSM_IR_tx is
    generic(
        BAUD        : natural;
        CLK_FREQ    : natural;
        PLZ_FREQ    : natural
    );
    port (
        clk50_i, rst_i, send_i: in std_ulogic;
        sw_i: in std_ulogic_vector(3 downto 0);
        --state_now: out std_ulogic_vector(3 downto 0); --for debug
        IR_o: out std_ulogic
    );
end entity;

architecture rtl of FSM_IR_tx is

    -- Define an enumerated type for the state machine
    type state_type is (idle, transmit, stop);

    -- Register to hold the current state
    signal present_state, next_state : state_type;
    
    -- constant for the frequency of the pulses
    constant CLK_TO_PLZ         : integer := CLK_FREQ/PLZ_FREQ;
    -- constant for the time to send a bit
    constant CLK_TO_BIT         : integer := CLK_FREQ/BAUD;
    
    --signals for the baudrate
    signal tx_clk_count         : integer range 0 to CLK_TO_BIT -1 := 0;
    signal tx_clk_count_max     : std_logic := '0';

    -- signal for the CDC
    signal tx_cdc1              : std_ulogic_vector(3 downto 0) := (others => '0');
    signal tx_cdc2              : std_ulogic_vector(3 downto 0) := (others => '0');
    
    signal send_cdc1              : std_ulogic := '0';
    signal send_cdc2              : std_ulogic := '0';
    
    signal rst_cdc1              : std_ulogic := '0';
    signal rst_cdc2              : std_ulogic := '0';
    
    signal send_data: integer := 0;
    signal ready: std_ulogic := '0';
    signal done: std_ulogic := '0';
begin
    
    -- TX CDC
    tx_sync : process(clk50_i)
    begin
        if rising_edge(clk50_i) then
            if rst_cdc2 = '1' then
                tx_cdc1 <= (others => '1');
                
            else
                tx_cdc1 <= sw_i;
                tx_cdc2 <= tx_cdc1;
            end if;
        end if;
    end process tx_sync;
    -- send button CDC
    send_sync : process(clk50_i)
    begin
        if rising_edge(clk50_i) then
            if rst_cdc2 = '1' then
                send_cdc1 <= '0';
                
            else
                send_cdc1 <= send_i;
                send_cdc2 <= send_cdc1;
            end if;
        end if;
    end process send_sync;
    -- reset button CDC
    reset_sync : process(clk50_i)
    begin
        if rising_edge(clk50_i) then
            rst_cdc1 <= rst_i;
            rst_cdc2 <= rst_cdc1;
        end if;
    end process reset_sync;
    
    
    -- state register
    pr_flipflops : process (clk50_i, rst_cdc2)
    begin
        if rst_cdc2 then
            present_state <= idle;
        elsif rising_edge(clk50_i) then
            present_state <= next_state;
        end if;
    end process;
 
    -- logic to determine the next state
    pr_next_state : process (present_state, send_cdc2, clk50_i, done)
    variable count: integer := 0;
    begin
        if rising_edge(clk50_i) then
            case present_state is
                when idle => 
                    if send_cdc2 then --Waits for the start button to be pressed
                        count := 0;
                        ready <= '0';
                        next_state <= transmit;
                    else
                        ready <= '0';
                        next_state <= idle;
                    end if;
                when transmit =>
                    if ready = '0' and done = '0' then -- looking if the next bit needs to be set.
                        ready <= '1';           -- sets "ready" to 1. Indicating that the bit is ready to be send.
                        send_data <= count;     --sets new data bit ready to be send
                        tx_clk_count <= 0;      --reseting the clock.
                    elsif tx_clk_count_max = '1' and done = '1' and ready = '1' then
                            ready <= '0';   --setting 'ready' on 0. Indicating that the next data bit needs to be set. Will cause 'done' to be 0
                            --when the data bit is send the count increases to set a new data bit
                            if count = 3 then   -- looks if the last bit has been send. If true set the count back to 0 and sets the next state.
                                count := 0;
                                next_state <= stop;
                            else 
                                count := count+1;   --increases count for the next
                            end if;
                            tx_clk_count <= 0;
                    else -- the counting of the clk for the timing of sending
                        if tx_clk_count_max = '1' then 
                            tx_clk_count <= 0;
                        else
                            tx_clk_count <= tx_clk_count + 1;
                        end if;
                        if next_state = transmit then
                            next_state <= transmit;
                        end if;
                    end if; 
                when stop => 
                    if send_cdc2 = '0' then --keeps the state machine in stop if the send button isn't released after it has been pressed
                                            --keeps the state machine from continuous sending
                        next_state <= idle;
                    else
                        if next_state = stop then
                            next_state <= stop;
                        end if;
                    end if;
            end case;
        end if;
    end process;

    --continuous checks if tx_clk_count < BAUD - 1. This is needed
    tx_clk_count_max  <= '0' when tx_clk_count < CLK_TO_BIT - 1 else '1';

    --Logic to determine the outputs
    pr_outputs : process (present_state, clk50_i, send_data, ready)
        variable count: integer := 0;
        variable bit_count: integer := 0;
    begin
        if rising_edge(clk50_i) then
            case present_state is
                when idle => 
                    --state_now <= "0001"; --for debug
                    
                    IR_o <= '0';    --sets to output to 0
                    done <= '0';    --sets to 'done' to 0
                when transmit =>
                if done = '1' and ready = '0' then --sets 'done' to 0 after 'ready' has been set to 0
                    done <= '0';
                end if;
                --state_now <= "0100"; --for debug
                
                --below is the code voor sending a '1' or a '0' bit depending on the bit in 'tx_cdc2'
                --a '1' sends 16 pulses and a '0' sends 8 pulses.
                if ready = '1' and tx_cdc2(send_data) = '1' and done = '0' then --when 'ready' is 1 and 'done' is 0 start sending the bit '1'
                    if count = (CLK_TO_PLZ / 2)-1 and bit_count /= 32 then --inverts every 20us (50kHz) the output.
                        IR_o <= not IR_o;   --inverts the output
                        count := 0;
                        bit_count := bit_count+1; --increases the count of how many times the output has been inverted
                    elsif bit_count = 32 then
                        done <= '1';    --sets 'dont' to 1 after al the pulses has been send
                        bit_count := 0;
                    else 
                        count := count+1;
                    end if;
                elsif ready = '1' and tx_cdc2(send_data) = '0' and done = '0' then --when 'ready' is 1 and 'done' is 0 start sending the bit '0'
                    if count = (CLK_TO_PLZ / 2)-1 and bit_count /= 16 then --inverts every 20us (50kHz) the output.
                        IR_o <= not IR_o; --inverts the output
                        count := 0;
                        bit_count := bit_count+1; --increases the count of how many times the output has been inverted
                    elsif bit_count = 16 then
                        done <= '1';    --sets 'dont' to 1 after al the pulses has been send
                        bit_count := 0;
                    else 
                        count := count+1;
                    end if;
                end if;
                when stop => 
                --state_now <= "1000"; --for debug
                
                    IR_o <= '0';    --sets to output to 0
                    done <= '0';    --sets to 'done' to 0
            end case;
        end if;
    end process;
end architecture;