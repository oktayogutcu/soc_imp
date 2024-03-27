module op #(
    		parameter integer DATA_WIDTH	= 32
) (
    input wire clk,
    input wire rst,
    input reg[1:0] op,
    input reg[DATA_WIDTH-1:0] data1,
    input reg[DATA_WIDTH-1:0] data2,
    input wire data_valid,
    output reg[DATA_WIDTH-1:0] result,  
    output reg result_valid
);
    always @(posedge clk ) begin
        if(data_valid) begin
            result_valid <= data_valid;
            if(op == 0) begin   
                result <= data1 + data2;
            end
            else begin
                result <= 0;
            end
        end
        else begin
            result <= 0;
        end
    end
endmodule