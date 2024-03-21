
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

library STD;
use std.env.all;

library uvvm_util;
context uvvm_util.uvvm_util_context;

library bitvis_vip_uart;
context bitvis_vip_uart.vvc_context;
use bitvis_vip_uart.monitor_cmd_pkg.all;

library uvvm_vvc_framework;
use uvvm_vvc_framework.ti_vvc_framework_support_pkg.all;

use std.textio.all;
use std.env.finish;

entity uart_tb is
end uart_tb;

architecture sim of uart_tb is

-- CONSTANTS
constant C_CLOCK_PERIOD             : time := 10 ns;
constant C_CLOCK_FREQ               : integer := 100_000_000;
constant C_CLOCK_HIGH_PERCENTAGE    : integer := 50;
constant C_BAUD_RATE                : integer := 115_200;
constant C_DATA_WIDTH               : integer := 8;

signal clk                  : std_logic := '0';
signal rst                  : std_logic := '0';

signal tx_start             : std_logic := '0';
signal tx_busy              : std_logic;
signal tx_done              : std_logic;
signal tx                   : std_logic;
signal tx_data              : std_logic_vector (C_DATA_WIDTH-1 downto 0) := (others => '0');

signal rx_data              : std_logic_vector (C_DATA_WIDTH-1 downto 0);
signal rx_busy              : std_logic;
signal rx_data_valid        : std_logic;
signal rx                   : std_logic := '1';

signal uart_bfm_config      : t_uart_bfm_config := C_UART_BFM_CONFIG_DEFAULT;
signal terminate_loop       : std_logic := '0';

begin

DUT : entity work.uart_tx 
generic map(
    CLOCK_FREQ      => C_CLOCK_FREQ,
    BAUD_RATE       => C_BAUD_RATE,
    STOP_COUNT      => 1,
    DATA_WIDTH      => C_DATA_WIDTH
)
port map (
    clk 		    => clk,
    rst			    => rst,
    start	 	    => tx_start,
    data 		    => tx_data,
    busy		    => tx_busy,
    tx			    => tx,
    done		    => tx_done
);

DUTR : entity work.uart_rx 
generic map(
    CLOCK_FREQ      => C_CLOCK_FREQ,
    BAUD_RATE       => C_BAUD_RATE,
    STOP_COUNT      => 1,
    DATA_WIDTH      => C_DATA_WIDTH
)
port map (
    clk 		    => clk,
    rst			    => rst,
    rx			    => rx,
    busy		    => rx_busy,
    data_valid 	    => rx_data_valid,
    data 		    => rx_data
);

-----------------------------------------------------------------------------
-- Clock Generator
-----------------------------------------------------------------------------
clock_generator(clk, C_CLOCK_PERIOD, C_CLOCK_HIGH_PERCENTAGE);

------------------------------------------------
-- PROCESS: p_main
------------------------------------------------
p_main: process
    constant C_SCOPE        : string  := C_TB_SCOPE_DEFAULT;
    variable v_time_stamp   : time := 0 ns;
    variable recv_byte      : std_logic_vector (C_DATA_WIDTH-1 downto 0) := (others => '0');
    variable transmit_byte   : std_logic_vector (C_DATA_WIDTH-1 downto 0) := (others => '0');
begin

-- uart initializations
    uart_bfm_config.bit_time            <= 8.68055 us;
    uart_bfm_config.num_data_bits       <= 8;
    uart_bfm_config.idle_state          <= '1';
    uart_bfm_config.num_stop_bits       <= STOP_BITS_ONE;
    uart_bfm_config.parity              <= PARITY_NONE;
    uart_bfm_config.timeout             <= 0 ns;
    uart_bfm_config.timeout_severity    <= error;
    wait for 1 ps;

   -- Print the configuration to the log
    report_global_ctrl(VOID);
    report_msg_id_panel(VOID);

    enable_log_msg(ALL_MESSAGES);
    --disable_log_msg(ALL_MESSAGES);
    --enable_log_msg(ID_LOG_HDR);


        -- Reset the DUT
    rst  <= '0';
    wait for C_CLOCK_PERIOD*5;
    rst  <= '1';
    wait for C_CLOCK_PERIOD*5;

    log(ID_LOG_HDR, "Simulation for UART_TX", C_SCOPE);

    for i in 0 to 10 loop
        tx_data   <= CONV_STD_LOGIC_VECTOR(i*10,C_DATA_WIDTH);
        tx_start  <= '1';
        uart_receive(recv_byte,  "Receiving data to DUT(UART_TX)", tx, terminate_loop, uart_bfm_config, C_SCOPE, shared_msg_id_panel,"");
        wait for C_CLOCK_PERIOD;
        tx_start  <= '0';
        wait until rising_edge(tx_done);
        check_value(CONV_STD_LOGIC_VECTOR(i*10,C_DATA_WIDTH), recv_byte, ERROR, "Transmit byte = " & to_string(tx_data,HEX) & " Received byte = " & to_string(recv_byte,HEX));
        wait for 1 ps;
    end loop;

    log(ID_LOG_HDR, "Simulation for UART_RX", C_SCOPE);

    for i in 0 to 10 loop
        transmit_byte :=  CONV_STD_LOGIC_VECTOR(i*10,C_DATA_WIDTH);
        wait for 1 ps;
        uart_transmit(transmit_byte, "Transmitting data to DUT(UART_RX)", rx, uart_bfm_config, C_SCOPE, shared_msg_id_panel);
        --wait until rising_edge(rx_data_valid);
        check_value(CONV_STD_LOGIC_VECTOR(i*10,C_DATA_WIDTH), rx_data, ERROR, "Transmit byte = " & to_string(CONV_STD_LOGIC_VECTOR(i*10,C_DATA_WIDTH),HEX) & " Received byte = " & to_string(rx_data,HEX));
        wait for 1 ps;
    end loop;


    --==================================================================================================
    -- Ending the simulation
    --------------------------------------------------------------------------------------
    wait for 1000 ns;             -- to allow some time for completion
    report_alert_counters(FINAL); -- Report final counters and print conclusion for simulation (Success/Fail)
    log(ID_LOG_HDR, "SIMULATION COMPLETED", C_SCOPE);

    -- Finish the simulation
    std.env.stop;
    wait;  -- to stop completely

end process p_main;

end architecture;
