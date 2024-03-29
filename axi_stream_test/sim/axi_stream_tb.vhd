library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;
  use std.textio.all;

library uvvm_util;
  context uvvm_util.uvvm_util_context;

library bitvis_vip_axistream;
  use bitvis_vip_axistream.axistream_bfm_pkg.all;

use std.env.finish;

entity axi_stream_tb is
end axi_stream_tb;

architecture sim of axi_stream_tb is
-- CONSTANTS --
constant C_CLOCK_PERIOD             : time := 10 ns;
constant C_CLOCK_FREQ              	: integer := 100_000_000;
constant C_CLOCK_HIGH_PERCENTAGE    : integer := 50;
constant C_AXIS_TDATA_WIDTH          : integer := 32;

signal m_axis : t_axistream_if(
        tdata(C_AXIS_TDATA_WIDTH-1 downto 0),
        tkeep((C_AXIS_TDATA_WIDTH/8)-1 downto 0),
        tuser(0 downto 0),
        tstrb((C_AXIS_TDATA_WIDTH/8)-1 downto 0),
        tid(0 downto 0),
        tdest(0 downto 0)
    );

signal s_axis : t_axistream_if(
	tdata(C_AXIS_TDATA_WIDTH-1 downto 0),
	tkeep((C_AXIS_TDATA_WIDTH/8)-1 downto 0),
	tuser(0 downto 0),
	tstrb((C_AXIS_TDATA_WIDTH/8)-1 downto 0),
	tid(0 downto 0),
	tdest(0 downto 0)
);

signal axistream_bfm_config : t_axistream_bfm_config := C_AXISTREAM_BFM_CONFIG_DEFAULT;
signal alert_level : t_alert_level := error;
signal clk	: std_logic := '0';
signal aresetn : std_logic := '1';



begin

	DUT : entity work.axi_stream_top 
	generic map(
	-- Parameters of Axi Slave Bus Interface S_AXIS
	C_S00_AXIS_TDATA_WIDTH    => C_AXIS_TDATA_WIDTH
	)
	port map(
	-- Users to add ports here
	
	-- Ports of Axi Slave Bus Interface S00_AXIS
	s00_axis_aclk    => clk,
	s00_axis_aresetn => aresetn,
	
	-- AXI4 Slave Stream channel
	s00_axis_tready  	=> m_axis.tready,
	s00_axis_tdata  	=> m_axis.tdata,
	s00_axis_tstrb 		=> m_axis.tstrb,
	s00_axis_tlast 		=> m_axis.tlast,
	s00_axis_tvalid   	=> m_axis.tvalid,

	-- Ports of Axi Master Bus Interface M00_AXIS
	m00_axis_aclk 		=> clk,
 	m00_axis_aresetn	=> aresetn,

	-- AXI4 Master Stream channel
	m00_axis_tvalid		=> s_axis.tvalid,
	m00_axis_tdata		=> s_axis.tdata,
	m00_axis_tstrb		=> s_axis.tstrb,
	m00_axis_tkeep		=> s_axis.tkeep,
	m00_axis_tlast		=> s_axis.tlast,
	m00_axis_tready		=> s_axis.tready

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
	--variable v_exp_data_array  : t_slv_array(0 to 256 - 1)(C_AXIS_TDATA_WIDTH - 1 downto 0);
	variable v_data_array : t_byte_array(0 to 4*256 - 1);
	variable v_data_array_receive : t_byte_array(0 to 256 - 1);

	variable tdata_received_array_v         : t_slv_array(0 to 256 - 1) (C_AXIS_TDATA_WIDTH - 1 downto 0);
	variable tdata_received_packet_length_v : natural;
	variable tuser_received_array_v         : t_user_array(0 to 256 - 1);
	variable tstrb_received_array_v         : t_strb_array(0 to 256 - 1);
	variable tid_received_array_v           : t_id_array(0 to 256 - 1);
	variable tdest_received_array_v         : t_dest_array(0 to 256 - 1);

	variable v_exp_user_array  : t_user_array(0 to 0) := (others => (others => '-'));
    variable v_exp_strb_array  : t_strb_array(0 to 0) := (others => (others => '-'));
    variable v_exp_dest_array  : t_dest_array(0 to 0) := (others => (others => '-'));
    variable v_exp_id_array    : t_id_array(0 to 0)   := (others => (others => '-'));
    variable v_exp_data_array  : t_slv_array(0 to 256 - 1)(C_AXIS_TDATA_WIDTH - 1 downto 0);
    variable v_exp_data_length : natural;
	
	variable sample_counter : integer := 0;
	
	procedure axistream_transmit_bytes (
		constant data_array : in t_byte_array;
		constant msg : in string) is
	begin
		axistream_transmit_bytes(data_array, -- keep as is
		msg, -- keep as is
		clk, -- Clock signal
		m_axis, -- Signal must be visible in local process scope
		C_SCOPE, -- Just use the default
		shared_msg_id_panel, -- Use global, shared msg_id_panel
		axistream_bfm_config); -- Use locally defined configuration or C_AXISTREAM_BFM_CONFIG_DEFAULT
	end;

    begin
	
		-- initialize AXI4-LITE Bus
		--axistream_bfm_config.clock_period <= C_CLOCK_PERIOD;
		--wait for C_CLOCK_PERIOD;
		--m_axis	<= init_axistream_if_signals(
		--	true,                       -- is_master   : boolean;  -- When true, this BFM drives data signals
		--	C_AXIS_TDATA_WIDTH,     -- data_width  : natural;
		--	1,                          -- user_width  : natural;
		--	0,                          -- id_width    : natural;
		--	0,                          -- dest_width  : natural;
		--	axistream_bfm_config        -- config      : t_axistream_bfm_config := C_AXISTREAM_BFM_CONFIG_DEFAULT
        --);
		m_axis <= init_axistream_if_signals(true, C_AXIS_TDATA_WIDTH, 1, 1, 1, axistream_bfm_config);
		s_axis <= init_axistream_if_signals(false, C_AXIS_TDATA_WIDTH, 1, 1, 1, axistream_bfm_config);
		axistream_bfm_config.clock_period        <= C_CLOCK_PERIOD;

		wait for C_CLOCK_PERIOD;
			
		-- Print the configuration to the log
		report_global_ctrl(VOID);
		report_msg_id_panel(VOID);

		enable_log_msg(ALL_MESSAGES);
		--disable_log_msg(ALL_MESSAGES);
		--enable_log_msg(ID_LOG_HDR);

		log(ID_LOG_HDR, "Start Simulation of AXI4-Stream Interface", C_SCOPE);
		
		
		-- Reset the DUT
		aresetn  <= '0';
		wait for C_CLOCK_PERIOD*10;
		aresetn  <= '1';
		wait for C_CLOCK_PERIOD*10;
		
		for i in 0 to 1023 loop
			if i mod 4 = 0 then
				v_data_array(i) := std_logic_vector(to_unsigned(sample_counter, v_data_array(i)'length));
				sample_counter := sample_counter + 1;
			else 
				v_data_array(i) := std_logic_vector(to_unsigned(0, v_data_array(i)'length));
			end if;
			
		end loop;
		
		--Testing master channel of DUT's AXI4-Stream interface.
		--axistream_expect_bytes(v_data_array, "DATA EXPECT");

		axistream_receive(	  data_array => v_exp_data_array(0 to 256 - 1),
			data_length                  => v_exp_data_length,
			user_array                   => v_exp_user_array,
			strb_array                   => v_exp_strb_array,
			id_array                     => v_exp_id_array,
			dest_array                   => v_exp_dest_array,
			msg                          => "Received",
			clk                          => clk,
			axistream_if                 => s_axis,
			scope                        => C_SCOPE,
			msg_id_panel                 => shared_msg_id_panel,
			config                       => axistream_bfm_config
		);


		--Testing slave channel of DUT's AXI4-Stream interface.
		axistream_transmit_bytes(v_data_array, "DATA SENT TO DUT");

		
		wait for C_CLOCK_PERIOD*20;
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
