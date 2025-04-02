// File: grid_interface.sv
// Author: Raghav Marwah
// Date: Mar 30, 2025
// Description:

module grid_interface (
    input logic clk, reset_n,           // clock and reset
    input logic [199:0] grid_state,     // 200 bits for 10x20 grid
    // Avalon-MM Interface
    input  logic avs_read,                          // read signal from CPU
    output logic [31:0] avs_readdata,               // data to CPU
    input  logic [4:0] avalon_slave_0_address       // address from CPU
);

    // Avalon-MM read operation
    // CPU reads one row at a time
    // upper 22 bits are 0s
    always_ff @(posedge clk) begin
        if (avs_read) begin
            case (avalon_slave_0_address)
                5'd0:  avs_readdata <= {22'd0, grid_state[9:0]};
                5'd1:  avs_readdata <= {22'd0, grid_state[19:10]};
                5'd2:  avs_readdata <= {22'd0, grid_state[29:20]};
                5'd3:  avs_readdata <= {22'd0, grid_state[39:30]};
                5'd4:  avs_readdata <= {22'd0, grid_state[49:40]};
                5'd5:  avs_readdata <= {22'd0, grid_state[59:50]};
                5'd6:  avs_readdata <= {22'd0, grid_state[69:60]};
                5'd7:  avs_readdata <= {22'd0, grid_state[79:70]};
                5'd8:  avs_readdata <= {22'd0, grid_state[89:80]};
                5'd9:  avs_readdata <= {22'd0, grid_state[99:90]};
                5'd10: avs_readdata <= {22'd0, grid_state[109:100]};
                5'd11: avs_readdata <= {22'd0, grid_state[119:110]};
                5'd12: avs_readdata <= {22'd0, grid_state[129:120]};
                5'd13: avs_readdata <= {22'd0, grid_state[139:130]};
                5'd14: avs_readdata <= {22'd0, grid_state[149:140]};
                5'd15: avs_readdata <= {22'd0, grid_state[159:150]};
                5'd16: avs_readdata <= {22'd0, grid_state[169:160]};
                5'd17: avs_readdata <= {22'd0, grid_state[179:170]};
                5'd18: avs_readdata <= {22'd0, grid_state[189:180]};
                5'd19: avs_readdata <= {22'd0, grid_state[199:190]};
                default: avs_readdata <= 32'd0;
            endcase
        end
    end

endmodule
