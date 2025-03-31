// File: grid_interface.sv
// Author: Raghav Marwah
// Date: Mar 30, 2025
// Description:

module grid_interface (
    input logic clk, reset_n,           // clock and reset
    input logic [199:0] grid_state,     // 200 bits for 10x20 grid
    // Avalon-MM Interface
    input  logic avs_read,              // read signal from CPU
    output logic [31:0] avs_readdata    // data to CPU
);

    // Avalon-MM read operation
    // CPU reads one row at a time
    // upper 22 bits are 0s
    always_ff @(posedge clk) begin
        if (avs_read)
            avs_readdata <= {22'd0, grid_state[199:190]}; 
    end
endmodule
