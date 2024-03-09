library ieee;
use ieee.std_logic_1164.all;

library STD;
use std.env.all;

library uvvm_util;
context uvvm_util.uvvm_util_context;

use std.textio.all;
use std.env.finish;

entity uvvm_test_tb is
end uvvm_test_tb;

architecture sim of uvvm_test_tb is

begin

    ------------------------------------------------
    -- PROCESS: p_main
    ------------------------------------------------
    p_main: process
      constant C_SCOPE     : string  := C_TB_SCOPE_DEFAULT;

      variable v_time_stamp   : time := 0 ns;

    begin

      -- Print the configuration to the log
      report_global_ctrl(VOID);
      report_msg_id_panel(VOID);

      enable_log_msg(ALL_MESSAGES);
      --disable_log_msg(ALL_MESSAGES);
      --enable_log_msg(ID_LOG_HDR);

      log(ID_LOG_HDR, "Start Simulation TB_IRQC", C_SCOPE);

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
