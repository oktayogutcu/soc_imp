`timescale 1 ns / 1 ps

module moduleName #(
    
		// Parameters of Axi Slave Bus Interface S00_AXI
		parameter integer C_S00_AXI_DATA_WIDTH	= 32,
		parameter integer C_S00_AXI_ADDR_WIDTH	= 7,

        // Parameters of Axi Slave Bus Interface S00_AXIS
		parameter integer C_S00_AXIS_TDATA_WIDTH	= 32,

		// Parameters of Axi Master Bus Interface M00_AXIS
		parameter integer C_M00_AXIS_TDATA_WIDTH	= 32,
		parameter integer C_M00_AXIS_START_COUNT	= 32
) (

   		// Ports of Axi Lite Slave Bus Interface S00_AXI
		input wire  s00_axi_aclk,
		input wire  s00_axi_aresetn,
		input wire [C_S00_AXI_ADDR_WIDTH-1 : 0] s00_axi_awaddr,
		input wire [2 : 0] s00_axi_awprot,
		input wire  s00_axi_awvalid,
		output wire  s00_axi_awready,
		input wire [C_S00_AXI_DATA_WIDTH-1 : 0] s00_axi_wdata,
		input wire [(C_S00_AXI_DATA_WIDTH/8)-1 : 0] s00_axi_wstrb,
		input wire  s00_axi_wvalid,
		output wire  s00_axi_wready,
		output wire [1 : 0] s00_axi_bresp,
		output wire  s00_axi_bvalid,
		input wire  s00_axi_bready,
		input wire [C_S00_AXI_ADDR_WIDTH-1 : 0] s00_axi_araddr,
		input wire [2 : 0] s00_axi_arprot,
		input wire  s00_axi_arvalid,
		output wire  s00_axi_arready,
		output wire [C_S00_AXI_DATA_WIDTH-1 : 0] s00_axi_rdata,
		output wire [1 : 0] s00_axi_rresp,
		output wire  s00_axi_rvalid,
		input wire  s00_axi_rready,
        
		// Ports of Axi Stream Slave Bus Interface S00_AXIS
		input wire  s00_axis_aclk,
		input wire  s00_axis_aresetn,
		output wire  s00_axis_tready,
		input wire [C_S00_AXIS_TDATA_WIDTH-1 : 0] s00_axis_tdata,
		input wire [(C_S00_AXIS_TDATA_WIDTH/8)-1 : 0] s00_axis_tstrb,
		input wire  s00_axis_tlast,
		input wire  s00_axis_tvalid,

		// Ports of Axi Stream Master Bus Interface M00_AXIS
		input wire  m00_axis_aclk,
		input wire  m00_axis_aresetn,
		output wire  m00_axis_tvalid,
		output wire [C_M00_AXIS_TDATA_WIDTH-1 : 0] m00_axis_tdata,
		output wire [(C_M00_AXIS_TDATA_WIDTH/8)-1 : 0] m00_axis_tstrb,
		output wire [(C_M00_AXIS_TDATA_WIDTH/8)-1 : 0] m00_axis_tkeep,
		output wire  m00_axis_tlast,
		input wire  m00_axis_tready

);

    reg 	read_counter;
    wire [C_S00_AXIS_TDATA_WIDTH-1 : 0] stream_data_in;
    reg 	read_data;
    wire 	data_valid;
    reg [1:0] operation = 2'b00;
    reg [C_S00_AXIS_TDATA_WIDTH-1 : 0] offset = 15;
    wire [C_S00_AXIS_TDATA_WIDTH-1 : 0] stream_data_out;
    wire op_done;
    wire m_fifo_empty;
    wire m_fifo_full;

    axi_stream_slave # ( 
		.C_S_AXIS_TDATA_WIDTH(C_S00_AXIS_TDATA_WIDTH)
	) axi_stream_slave_inst (
		.read_data(read_data),
		.data_valid(data_valid),
		.fifo_data(stream_data_in),
		.S_AXIS_ACLK(s00_axis_aclk),
		.S_AXIS_ARESETN(s00_axis_aresetn),
		.S_AXIS_TREADY(s00_axis_tready),
		.S_AXIS_TDATA(s00_axis_tdata),
		.S_AXIS_TSTRB(s00_axis_tstrb),
		.S_AXIS_TLAST(s00_axis_tlast),
		.S_AXIS_TVALID(s00_axis_tvalid)
	);

// Instantiation of Axi Bus Interface M00_AXIS
	axi_stream_master # ( 
		.C_M_AXIS_TDATA_WIDTH(C_M00_AXIS_TDATA_WIDTH),
		.C_M_START_COUNT(C_M00_AXIS_START_COUNT)
	) axi_stream_master_inst (
        .fifo_wren(op_done),
		.data_in(stream_data_out),
        .fifo_full(m_fifo_full),
		.fifo_empty(m_fifo_empty),
		.M_AXIS_ACLK(m00_axis_aclk),
		.M_AXIS_ARESETN(m00_axis_aresetn),
		.M_AXIS_TVALID(m00_axis_tvalid),
		.M_AXIS_TDATA(m00_axis_tdata),
		.M_AXIS_TSTRB(m00_axis_tstrb),
		.M_AXIS_TKEEP(m00_axis_tkeep),
		.M_AXIS_TLAST(m00_axis_tlast),
		.M_AXIS_TREADY(m00_axis_tready)
	);

    op # (
        .DATA_WIDTH(C_M00_AXIS_TDATA_WIDTH)
    )
    op_inst (
        .clk(s00_axi_aclk),
        .rst(s00_axi_aresetn),
        .op(operation),
        .data1(stream_data_in),
        .data2(offset),
        .data_valid(data_valid),
        .result(stream_data_out),
        .result_valid(op_done)
    );

    
    always@(posedge s00_axis_aclk)
	begin
		if(!s00_axis_aresetn)
			begin
				read_counter <= 0;
				read_data <= 0;
			end
		else
			begin
				if(data_valid)
					begin
					if(read_counter == 8)
						begin
							read_counter <= 0;
						end
					else	
						begin
							read_counter <= read_counter + 1;
						end
						
					if(read_counter < 4)
						begin
							read_data <= 1'b1;
						end
					else
						begin
							read_data <= 1'b0;
						end
					end
			end
	end




    



endmodule