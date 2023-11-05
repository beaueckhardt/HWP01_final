----------------------------------------------------------------------------------
-- Company:
-- Engineer: 
-- 
-- Create Date:  08.08.2017
-- Design Name: 
-- Module Name: x - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description:
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;

---------------------------------------------
-- Package Definition für Komponente
---------------------------------------------
package uart_inst_pkg is

    component uart is
        generic(
            BAUD        : positive;
            CLK_FREQ    : positive;
            PARTITY     : string   := "NONE"; -- NONE, ODD, EVEN
            RX_STOPBITS : positive := 1; -- 1 oder 2
            TX_STOPBITS : positive := 1 -- 1 oder 2
        );
        port(
            clk_i           : in  std_logic;
            reset           : in  std_logic;
            data_tx_i       : in  std_logic_vector(7 downto 0);
            data_tx_valid_i : in  std_logic;
            data_tx_ready_o : out std_logic;
            data_rx_o       : out std_logic_vector(7 downto 0);
            data_rx_valid_o : out std_logic;
            parity_error_o  : out std_logic;
            uart_tx_o       : out std_logic;
            uart_rx_i       : in  std_logic
        );
    end component uart;

end package uart_inst_pkg;

library IEEE;
use IEEE.std_logic_1164.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

---------------------------------------------
-- UART
---------------------------------------------
entity uart is
    generic(
        BAUD        : positive;
        CLK_FREQ    : positive;
        PARTITY     : string   := "NONE"; -- NONE, ODD, EVEN
        RX_STOPBITS : positive := 1;    -- 1 oder 2
        TX_STOPBITS : positive := 1     -- 1 oder 2
    );
    port(
        clk_i           : in  std_logic;
        reset           : in  std_logic;
        data_tx_i       : in  std_logic_vector(7 downto 0);
        data_tx_valid_i : in  std_logic;
        data_tx_ready_o : out std_logic;
        data_rx_o       : out std_logic_vector(7 downto 0);
        data_rx_valid_o : out std_logic;
        parity_error_o  : out std_logic;
        uart_tx_o       : out std_logic;
        uart_rx_i       : in  std_logic
    );
end uart;

architecture rtl of uart is

    ---------------------------------------------
    -- function declarations
    ---------------------------------------------
    -- Parity function
    function parityVec8(vec : std_logic_vector(7 downto 0)) return std_logic is
        variable p : std_logic := '0';
    begin
        for i in 0 to 7 loop
            p := p xor vec(i);
        end loop;
        if PARTITY = "ODD" then
            return not p;
        else
            return p;
        end if;
    end function parityVec8;

    ---------------------------------------------
    -- constant declarations
    ---------------------------------------------
    constant C_CLK_TO_BIT : integer := CLK_FREQ / BAUD;

    ---------------------------------------------
    -- component declarations
    ---------------------------------------------

    ---------------------------------------------
    -- attribute declarations
    ---------------------------------------------

    ---------------------------------------------
    -- signal declarations
    ---------------------------------------------

    type t_tx_state is (
        txStateStartBit,
        txStateData,
        txStateParity,
        txStateStopBit,
        txStateStopBit2
    );
    signal tx_state      : t_tx_state                   := txStateStartBit;
    signal data_tx_vec   : std_logic_vector(7 downto 0) := (others => '0');
    signal uart_tx       : std_logic                    := '1';
    signal tx_count      : unsigned(2 downto 0)         := (others => '0');
    signal data_rx_ready : std_logic                    := '0';

    type t_rx_state is (
        rxStateIdle,
        rxStateStartBit,
        rxStateData,
        rxStateParity,
        rxStateStopBit,
        rxStateStopBit2
    );

    signal rx_state      : t_rx_state                   := rxStateIdle;
    signal data_rx_vec   : std_logic_vector(7 downto 0) := (others => '0');
    signal rx_cdc        : std_logic_vector(1 downto 0) := (others => '1');
    signal data_rx_valid : std_logic                    := '0';

    signal tx_parity       : std_logic := '0';

    signal rx_parity_error : std_logic := '0';

    signal rx_clk_count, tx_clk_count          : integer range 0 to C_CLK_TO_BIT - 1 := 0;

    signal rx_clk_count_half, rx_clk_count_max : std_logic                           := '0';

    signal tx_baud_en   : std_logic            := '0';
    
    signal rx_bit_count : integer range 0 to 7 := 0;

begin

    ---------------------------------------------
    -- RX CDC
    ---------------------------------------------
    rxd_synchronise : process(clk_i)
    begin
        if rising_edge(clk_i) then
            if reset = '1' then
                rx_cdc <= (others => '1');
            else
                rx_cdc(0) <= uart_rx_i;
                rx_cdc(1) <= rx_cdc(0);
            end if;
        end if;
    end process rxd_synchronise;

    ---------------------------------------------
    -- RX State Machine
    ---------------------------------------------
    process(clk_i) is
    begin
        if rising_edge(clk_i) then
            if reset = '1' then
                rx_state      <= rxStateIdle;
                data_rx_valid <= '0';
            else
                -- defaults
                rx_state      <= rx_state;
                data_rx_valid <= '0';

                case rx_state is
                    when rxStateIdle =>
                        rx_parity_error <= '0';
                        rx_clk_count    <= 0;
                        rx_bit_count    <= 0;

                        if rx_cdc(1) = '0' then -- first falling edge -> start bit
                            rx_state <= rxStateStartBit;
                        end if;

                    when rxStateStartBit =>
                        if rx_clk_count_half = '1' then -- check after half of clock cycles per bit
                            if rx_cdc(1) = '0' then
                                rx_clk_count <= 0;
                                rx_state     <= rxStateData;
                            else
                                rx_state <= rxStateIdle; -- abort
                            end if;
                        else
                            rx_clk_count <= rx_clk_count + 1;
                        end if;

                    when rxStateData =>
                        if rx_clk_count_max = '0' then -- wait cycles per bit
                            rx_clk_count <= rx_clk_count + 1;
                        else
                            rx_clk_count              <= 0;
                            data_rx_vec(rx_bit_count) <= rx_cdc(1);

                            if rx_bit_count < 7 then
                                rx_bit_count <= rx_bit_count + 1;
                            else
                                rx_bit_count <= 0;
                                if PARTITY = "NONE" then
                                    rx_state <= rxStateStopBit;
                                else
                                    rx_state <= rxStateParity;
                                end if;
                            end if;
                        end if;

                    when rxStateParity =>
                        if rx_clk_count_max = '0' then -- wait cycles per bit
                            rx_clk_count <= rx_clk_count + 1;
                        else
                            rx_clk_count <= 0;
                            if rx_cdc(1) /= parityVec8(data_rx_vec) then
                                rx_parity_error <= '1';
                            end if;
                            rx_state     <= rxStateStopBit;
                        end if;

                    when rxStateStopBit =>
                        if rx_clk_count_max = '0' then -- wait cycles per bit
                            rx_clk_count <= rx_clk_count + 1;
                        else
                            rx_clk_count <= 0;
                            if rx_cdc(1) = '1' then -- stop bit = 1
                                if RX_STOPBITS = 1 then
                                    rx_state      <= rxStateIdle;
                                    data_rx_valid <= '1';
                                else
                                    rx_state <= rxStateStopBit2;
                                end if;

                            else
                                rx_state <= rxStateIdle; -- abort
                            end if;
                        end if;

                    when rxStateStopBit2 =>
                        if rx_clk_count_max = '0' then -- wait cycles per bit
                            rx_clk_count <= rx_clk_count + 1;
                        else
                            rx_clk_count <= 0;
                            rx_state     <= rxStateIdle;
                            if rx_cdc(1) = '1' then -- stop bit = 1
                                data_rx_valid <= '1';
                            end if;
                        end if;

                end case;
            end if;
        end if;
    end process;

    rx_clk_count_half <= '1' when rx_clk_count = C_CLK_TO_BIT / 2 else '0';
    rx_clk_count_max  <= '0' when rx_clk_count < C_CLK_TO_BIT - 1 else '1';

    ---------------------------------------------
    -- TX Zähler
    ---------------------------------------------
    process(clk_i)
    begin
        if rising_edge(clk_i) then
            if reset = '1' then
                tx_clk_count <= 0;
                tx_baud_en   <= '0';
            else
                if tx_clk_count = C_CLK_TO_BIT - 1 then
                    tx_clk_count <= 0;
                    tx_baud_en   <= '1';
                else
                    tx_clk_count <= tx_clk_count + 1;
                    tx_baud_en   <= '0';
                    
                end if;
            end if;
        end if;
    end process;

    ---------------------------------------------
    -- TX
    ---------------------------------------------
    process(clk_i)
    begin
        if rising_edge(clk_i) then
            if reset = '1' then
                uart_tx       <= '1';
                data_tx_vec   <= (others => '0');
                tx_count      <= (others => '0');
                tx_state      <= txStateStartBit;
                data_rx_ready <= '0';
            else
                data_rx_ready <= '0';

                case tx_state is

                    when txStateStartBit =>
                        if tx_baud_en = '1' and data_tx_valid_i = '1' then
                            uart_tx       <= '0';
                            tx_state      <= txStateData;
                            tx_count      <= (others => '0');
                            data_rx_ready <= '1';
                            data_tx_vec   <= data_tx_i;
                            tx_parity     <= parityVec8(data_tx_i);
                        end if;

                    when txStateData =>
                        if tx_baud_en = '1' then
                            uart_tx                                    <= data_tx_vec(0);
                            data_tx_vec(data_tx_vec'high - 1 downto 0) <= data_tx_vec(data_tx_vec'high downto 1);
                            if tx_count < 7 then
                                tx_count <= tx_count + 1;
                            else
                                tx_count <= (others => '0');
                                if PARTITY = "NONE" then
                                    tx_state <= txStateStopBit;
                                else
                                    tx_state <= txStateParity;
                                end if;
                            end if;
                        end if;

                    when txStateParity =>
                        if tx_baud_en = '1' then
                            uart_tx  <= tx_parity;
                            tx_state <= txStateStopBit;
                        end if;

                    when txStateStopBit =>
                        if tx_baud_en = '1' then
                            uart_tx <= '1';
                            if TX_STOPBITS = 1 then
                                tx_state <= txStateStartBit;
                            else
                                tx_state <= txStateStopBit2;
                            end if;
                        end if;

                    when txStateStopBit2 =>
                        if tx_baud_en = '1' then
                            uart_tx  <= '1';
                            tx_state <= txStateStartBit;
                        end if;

                    when others =>
                        uart_tx  <= '1';
                        tx_state <= txStateStartBit;
                end case;
            end if;
        end if;
    end process;

    ---------------------------------------------
    -- Port Zuweisungen
    ---------------------------------------------
    data_tx_ready_o <= data_rx_ready;
    data_rx_o       <= data_rx_vec;
    data_rx_valid_o <= data_rx_valid;
    parity_error_o  <= rx_parity_error;
    uart_tx_o       <= uart_tx;

end rtl;