library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;
  use std.textio.all;

library uvvm_util;
  context uvvm_util.uvvm_util_context;

library bitvis_vip_axistream;
  use bitvis_vip_axistream.axistream_bfm_pkg.all;

use std.env.finish;

entity axi_lite_tb is
end axi_lite_tb;

architecture sim of axi_lite_tb is
-- CONSTANTS --
constant C_CLOCK_PERIOD             : time := 10 ns;
constant C_CLOCK_FREQ              	: integer := 100_000_000;
constant C_CLOCK_HIGH_PERCENTAGE    : integer := 50;
constant C_AXIS_TDATA_WIDTH          : integer := 32;

subtype t_axis is t_axistream_if(
	tdata(C_AXIS_TDATA_WIDTH-1 downto 0),
	tkeep(0 downto 0),
	tuser(0 downto 0),
	tstrb((C_AXIS_TDATA_WIDTH/8)-1 downto 0),
	tid(0 downto 0),
	tdest( 0 downto 0)
 );


signal m_axis : t_axis;

signal axistream_bfm_config : t_axistream_bfm_config := C_AXISTREAM_BFM_CONFIG_DEFAULT;
signal alert_level : t_alert_level := error;
signal clk	: std_logic := '0';
signal aresetn : std_logic := '1';



begin

	DUT : entity work.axi_stream_top 
	generic map(
	-- Parameters of Axi Slave Bus Interface S_AXIS
	C_S00_AXIS_TDATA_WIDTH    => C_AXI_TDATA_WIDTH
	)
	port map(
	-- Users to add ports here
	
	-- Ports of Axi Slave Bus Interface S00_AXIS
	s00_axis_aclk    => clk,
	s00_axis_aresetn => aresetn,
	
	-- AXI4 Stream channel
	s00_axis_tready  	=> m_axis.tready,
	s00_axis_tdata  	=> m_axis.tdata,
	s00_axis_tstrb 		=> m_axis.tstrb,
	s00_axis_tlast 		=> m_axis.tlast,
	s00_axis_tvalid   	=> m_axis.tvalid,

	);
	
	-----------------------------------------------------------------------------
	-- Clock Generator
	-----------------------------------------------------------------------------
	clock_generator(clk, C_CLOCK_PERIOD, C_CLOCK_HIGH_PERCENTAGE);


    ------------------------------------------------
    -- PROCESS: p_main
    ------------------------------------------------
    p_main: process
	constant C_SCOPE     : string  := C_TB_SCOPE_DEFAULT;
	variable v_time_stamp   : time := 0 ns;
	  
	procedure axistream_transmit_bytes (
		constant data_array : in t_byte_array;
		constant msg : in string) is
	begin
		axistream_transmit_bytes(data_array, -- keep as is
		msg, -- keep as is
		clk, -- Clock signal
		axistream_if, -- Signal must be visible in local process scope
		C_SCOPE, -- Just use the default
		shared_msg_id_panel, -- Use global, shared msg_id_panel
		C_AXISTREAM_BFM_CONFIG_LOCAL); -- Use locally defined configuration or C_AXISTREAM_BFM_CONFIG_DEFAULT
	end;
		
	variable v_reg	: std_logic_vector(C_AXI_DATA_WIDTH-1 downto 0);
    variable v_addr	: unsigned(C_AXI_ADDR_WIDTH - 1 downto 0);
	
    begin
	
		-- initialize AXI4-LITE Bus
		axilite_if <= init_axilite_if_signals(C_AXI_ADDR_WIDTH, 32);
		
			
		-- Print the configuration to the log
		report_global_ctrl(VOID);
		report_msg_id_panel(VOID);

		enable_log_msg(ALL_MESSAGES);
		--disable_log_msg(ALL_MESSAGES);
		--enable_log_msg(ID_LOG_HDR);

		log(ID_LOG_HDR, "Start Simulation of AXI4-LITE Interface", C_SCOPE);
		
		
		-- Reset the DUT
		aresetn  <= '0';
		wait for C_CLOCK_PERIOD*10;
		aresetn  <= '1';
		wait for C_CLOCK_PERIOD*10;
		
		--Testing channels of AXI4-LITE interface.
		v_addr	:= C_REG0_ADDR;
		v_reg	:= X"55262655";
		axilite_write(v_addr, v_reg, "Write to memory");
		axilite_check(v_addr, v_reg, "Check memory");
		wait for C_CLOCK_PERIOD*10;
		
		v_addr	:= C_REG1_ADDR;
		v_reg	:= X"55262655";
		axilite_write(v_addr, v_reg, "Write to memory");
		axilite_read(v_addr, v_reg, "Read from memory");
		wait for C_CLOCK_PERIOD*10;


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
