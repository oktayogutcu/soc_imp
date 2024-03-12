library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;
  use std.textio.all;

library uvvm_util;
  context uvvm_util.uvvm_util_context;

library bitvis_vip_axilite;
  use bitvis_vip_axilite.axilite_bfm_pkg.all;

use std.env.finish;

entity axi_lite_tb is
end axi_lite_tb;

architecture sim of axi_lite_tb is
-- CONSTANTS
constant C_CLOCK_PERIOD                : time := 10 ns;
constant C_CLOCK_FREQ                  : integer := 100_000_000;
constant C_CLOCK_HIGH_PERCENTAGE    : integer := 50;
constant C_AXI_ADDR_WIDTH           : integer := 7;
constant C_AXI_DATA_WIDTH           : integer := 32;
constant C_REG0_ADDR                : unsigned (C_AXI_ADDR_WIDTH-1 downto 0) := (others => '0');
constant C_REG1_ADDR                : unsigned (C_AXI_ADDR_WIDTH-1 downto 0) := "0001100";

signal axilite_if : t_axilite_if(
    write_address_channel(
        awaddr(C_AXI_ADDR_WIDTH-1 downto 0)
        ),
    write_data_channel(
        wdata(C_AXI_DATA_WIDTH-1 downto 0),
        wstrb((C_AXI_DATA_WIDTH/8)-1 downto 0)
        ),
    read_address_channel(
        araddr(C_AXI_ADDR_WIDTH-1 downto 0)
    ),
    read_data_channel(
        rdata(C_AXI_DATA_WIDTH-1 downto 0)
    )
);

signal axilite_bfm_config : t_axilite_bfm_config := C_AXILITE_BFM_CONFIG_DEFAULT;
signal alert_level : t_alert_level := error;
signal clk	: std_logic := '0';
signal aresetn : std_logic := '1';



begin

	DUT : entity work.axi_lite_top 
	generic map(
	-- Parameters of Axi Slave Bus Interface S00_AXI
	C_S00_AXI_DATA_WIDTH    => C_AXI_DATA_WIDTH,
	C_S00_AXI_ADDR_WIDTH    => C_AXI_ADDR_WIDTH
	)
	port map(
	-- Users to add ports here
	
	-- Ports of Axi Slave Bus Interface S00_AXI
	s00_axi_aclk    => clk,
	s00_axi_aresetn => aresetn,
	
	-- AXI4 write address channel
	s00_axi_awaddr  => axilite_if.write_address_channel.awaddr,
	s00_axi_awprot  => axilite_if.write_address_channel.awprot,
	s00_axi_awvalid => axilite_if.write_address_channel.awvalid,
	s00_axi_awready => axilite_if.write_address_channel.awready,
	
	-- AXI4 write data channel
	s00_axi_wdata   => axilite_if.write_data_channel.wdata,
	s00_axi_wstrb   => axilite_if.write_data_channel.wstrb,
	s00_axi_wvalid  => axilite_if.write_data_channel.wvalid,
	s00_axi_wready  => axilite_if.write_data_channel.wready,
	
	-- AXI4 write response channel
	s00_axi_bresp   => axilite_if.write_response_channel.bresp,
	s00_axi_bvalid  => axilite_if.write_response_channel.bvalid,
	s00_axi_bready  => axilite_if.write_response_channel.bready,
	
	-- AXI4 read address channel
	s00_axi_araddr  => axilite_if.read_address_channel.araddr,
	s00_axi_arprot  => axilite_if.read_address_channel.arprot,
	s00_axi_arvalid => axilite_if.read_address_channel.arvalid,
	s00_axi_arready => axilite_if.read_address_channel.arready,
	
	-- AXI4 read data channel
	s00_axi_rdata   => axilite_if.read_data_channel.rdata,
	s00_axi_rresp   => axilite_if.read_data_channel.rresp,
	s00_axi_rvalid  => axilite_if.read_data_channel.rvalid,
	s00_axi_rready  => axilite_if.read_data_channel.rready
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
	  
	procedure axilite_write(
		constant addr_value : in unsigned;
		constant data_value : in std_logic_vector;
		constant msg : in string) is
	begin
	
		axilite_write(
			addr_value, -- keep as is
			data_value, -- keep as is
			msg, -- keep as is
			clk, -- Clock signal
			axilite_if, -- Signal must be visible in local process scope
			C_TB_SCOPE_DEFAULT, -- Just use the default
			shared_msg_id_panel, -- Use global, shared msg_id_panel
			C_AXILITE_BFM_CONFIG_DEFAULT); -- Use locally defined configuration or C_AXILITE_BFM_CONFIG_DEFAULT
		
	end;
	
	procedure axilite_read(
		constant addr_value : in unsigned;
		variable data_value : out std_logic_vector;
		constant msg : in string) is
	begin
	
		axilite_read(
			addr_value, -- keep as is
			data_value, -- keep as is
			msg, -- keep as is
			clk, -- Clock signal
			axilite_if, -- Signal must be visible in local process scope
			C_TB_SCOPE_DEFAULT, -- Just use the default
			shared_msg_id_panel, -- Use global, shared msg_id_panel
			C_AXILITE_BFM_CONFIG_DEFAULT); -- Use locally defined configuration or C_AXILITE_BFM_CONFIG_DEFAULT
		
	end;
	
	procedure axilite_check(
		constant addr_value : in unsigned;
		constant data_exp : in std_logic_vector;
		constant msg : in string) is
	begin
	
		axilite_check(
			addr_value, -- keep as is
			data_exp, -- keep as is
			msg, -- keep as is
			clk, -- Clock signal
			axilite_if, -- Signal must be visible in local process scope
			alert_level,
			C_TB_SCOPE_DEFAULT, -- Just use the default
			shared_msg_id_panel, -- Use global, shared msg_id_panel
			C_AXILITE_BFM_CONFIG_DEFAULT); -- Use locally defined configuration or C_AXILITE_BFM_CONFIG_DEFAULT
		
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
