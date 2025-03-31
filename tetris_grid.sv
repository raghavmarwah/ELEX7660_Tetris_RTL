// File: tetris_grid.sv
// Author: Raghav Marwah
// Date: Mar 30, 2025
// Description:

module tetris_grid (
    input  logic clk, reset_n,              // clock and reset
    input  logic move_left,                 // move left signal
    input  logic move_right,                // move right signal
    input  logic move_down,                 // move down signal
    input  logic rotate,                    // rotate signal
    input  logic [3:0] active_tetromino,    // 4-bit tetromino ID
    output logic [199:0] grid_state,        // 200 bits for 10x20 grid
    output logic row_cleared,               // high when a row is cleared
    output logic game_over                  // high when game ends
);
    // 2D register grid
    logic [9:0] grid [19:0];

    // tetromino position
    logic [3:0] tetromino_x, tetromino_y;
    
    // update logic (move & rotate)
    always_ff @(posedge clk, negedge reset_n) begin
        if (!reset_n) begin
            tetromino_x <= 4'd4;
            tetromino_y <= 4'd0;
        end
        else begin
            if (move_left && tetromino_x > 0) tetromino_x <= tetromino_x - 1;
            if (move_right && tetromino_x < 9) tetromino_x <= tetromino_x + 1;
            if (move_down) tetromino_y <= tetromino_y + 1;
            
            // Rotation Logic can be added here
        end
    end

    // Collision detection, piece locking, and row clearing logic here...

    // row clearing logic
    always_ff @(posedge clk) begin
        for (int y = 19; y > 0; y--) begin
            // if all 10 bits in a row are 1s
            if (&grid[y]) begin
                for (int j = y; j > 0; j--) begin
                    grid[j] <= grid[j-1]; // shift rows down
                end
                grid[0] <= 10'b0; // clear the top row
                row_cleared <= 1'b1;
            end
            else begin
                row_cleared <= 1'b0;
            end
        end
    end

    // flatten grid into a 1D output for easy readout by the CPU
    // memory-mapped interfaces deal with vectors (1D arrays), not nested 2D arrays
    genvar r, c;
    // generate
    //     for (r = 0; r < 20; r++) begin : row_loop
    //         for (c = 0; c < 10; c++) begin : col_loop
    //             assign grid_state[r*10 + c] = grid[r][c];
    //         end
    //     end
    // endgenerate
    generate
        for (r = 0; r < 20; r++) begin : row_loop
            for (c = 0; c < 10; c++) begin : col_loop
                assign grid_state[r*10 + c] = 'b1;
            end
        end
    endgenerate

endmodule
