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
    logic [9:0] grid [19:0];    // main game grid
    logic [9:0] shadow [19:0];  // holds the currently falling tetromino bits

    // tetromino position
    logic [3:0] tetromino_x;    // column (0–9) 
    logic [4:0] tetromino_y;    // row (0–19)
    logic falling;

    // tick counter (clock divider)
    logic [25:0] counter;
    logic tick;
    always_ff @(posedge clk, negedge reset_n) begin
        if (!reset_n) begin
            counter <= 0;
            tick    <= 0;
        end
        else begin
            counter <= counter + 1;
            tick <= (counter == 26'd48_000_000);
            if (tick) counter <= 0;
        end
    end

    // draw current tetromino into the shadow grid
    always_comb begin
        // clear shadow grid
        for (int y = 0; y < 20; y++) begin
            shadow[y] = 10'd0;
        end
        // draw 1x1 block at tetromino position
        if (tetromino_y < 20 && tetromino_x < 10) begin
            shadow[tetromino_y][tetromino_x] = 1'b1;
        end
    end

    
    // update logic (move & rotate)
    always_ff @(posedge clk, negedge reset_n) begin
        if (!reset_n) begin
            falling <= 1'b0;
            // clear main grid
            for (int y = 0; y < 20; y++) begin
                grid[y] = 10'd0;
            end
        end
        else if (!falling) begin
            // spawn a new piece
            falling             <= 1'b1;
            //active_tetromino    <= 4'd0;
            tetromino_x         <= 4'd4;
            tetromino_y         <= 5'd0;
        end
        // move the piece down
        else if (falling && tick) begin
            if (tetromino_y == 19 || grid[tetromino_y + 1][tetromino_x]) begin
                grid[tetromino_y][tetromino_x] <= 1'b1;
                falling <= 1'b0;  // lock piece and allow next to spawn
            end else begin
                tetromino_y <= tetromino_y + 1'd1;
            end
        end
    end

    // Collision detection, piece locking, and row clearing logic here...

    // row clearing logic
    // always_ff @(posedge clk) begin
    //     for (int y = 19; y > 0; y--) begin
    //         // if all 10 bits in a row are 1s
    //         if (&grid[y]) begin
    //             for (int j = y; j > 0; j--) begin
    //                 grid[j] <= grid[j-1]; // shift rows down
    //             end
    //             grid[0] <= 10'b0; // clear the top row
    //             row_cleared <= 1'b1;
    //         end
    //         else begin
    //             row_cleared <= 1'b0;
    //         end
    //     end
    // end

    // flatten grid into a 1D output for easy readout by the CPU
    // memory-mapped interfaces deal with vectors (1D arrays), not nested 2D arrays
    genvar r, c;
    generate
        for (r = 0; r < 20; r++) begin : row_loop
            for (c = 0; c < 10; c++) begin : col_loop
                assign grid_state[r*10 + c] = grid[r][c] | shadow[r][c];
            end
        end
    endgenerate

endmodule
