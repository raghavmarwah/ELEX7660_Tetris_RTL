// File: tetris_grid.sv
// Author: Raghav Marwah
// Date: Mar 30, 2025
// Description:

module tetris_grid (
    input  logic clk, reset_n,          // clock and reset
    input  logic move_left,             // move left signal
    input  logic move_right,            // move right signal
    input  logic move_down,             // move down signal
    input  logic rotate,                // rotate signal
    input  logic pause,                 // pause signal
    output logic row_cleared,           // high when a row is cleared
    output logic game_over,             // high when game ends
    output logic game_paused,           // high when game is paused
    output logic [199:0] grid_state,    // 200 bits for 10x20 grid
    output logic [13:0] score           // score output
);
    // state machine for game logic
    typedef enum logic [3:0] {
        idle,
        spawn,
        falling,
        paused,
        lock,
        clear_rows,
        update_score,
        check_gameover,
        gameover
    } game_state_t;
    game_state_t state;

    // tetromino type and rotation
    logic [2:0] tetromino_type;
    logic [1:0] rotation;
    logic [1:0] next_rotation;
    logic [15:0] shape;
    logic rotate_prev, rotate_pressed;
    // tetromino shapes return function
    // 16 bits for each tetromino, 4 rotations
    function automatic logic [15:0] get_tetromino(input logic [2:0] t_type, input logic [1:0] rot);
        case (t_type)
            // O
            3'd0: get_tetromino = 16'b1100_1100_0000_0000;
            // I
            3'd1: case (rot)
                2'd0: get_tetromino = 16'b1111_0000_0000_0000;
                2'd1: get_tetromino = 16'b1000_1000_1000_1000;
                2'd2: get_tetromino = 16'b1111_0000_0000_0000;
                2'd3: get_tetromino = 16'b1000_1000_1000_1000;
            endcase

            // T
            3'd2: case (rot)
                2'd0: get_tetromino = 16'b1110_0100_0000_0000;
                2'd1: get_tetromino = 16'b0100_1100_0100_0000;
                2'd2: get_tetromino = 16'b0100_1110_0000_0000;
                2'd3: get_tetromino = 16'b1000_1100_1000_0000;
            endcase

            // J
            3'd3: case (rot)
                2'd0: get_tetromino = 16'b1000_1110_0000_0000;
                2'd1: get_tetromino = 16'b1100_1000_1000_0000;
                2'd2: get_tetromino = 16'b1110_0010_0000_0000;
                2'd3: get_tetromino = 16'b0100_0100_1100_0000;
            endcase

            // L
            3'd4: case (rot)
                2'd0: get_tetromino = 16'b0010_1110_0000_0000;
                2'd1: get_tetromino = 16'b1000_1000_1100_0000;
                2'd2: get_tetromino = 16'b1110_1000_0000_0000;
                2'd3: get_tetromino = 16'b1100_0100_0100_0000;
            endcase

            // S
            3'd5: case (rot)
                2'd0, 2'd2: get_tetromino = 16'b0110_1100_0000_0000;
                2'd1, 2'd3: get_tetromino = 16'b1000_1100_0100_0000;
            endcase

            // Z
            3'd6: case (rot)
                2'd0, 2'd2: get_tetromino = 16'b1100_0110_0000_0000;
                2'd1, 2'd3: get_tetromino = 16'b0100_1100_1000_0000;
            endcase
            default: get_tetromino = 16'd0;
        endcase
    endfunction
    assign shape = get_tetromino(tetromino_type, rotation);
    // avoid multiple rotations
    always_ff @(posedge clk) begin
        rotate_prev <= rotate;
    end
    assign rotate_pressed = rotate && !rotate_prev;
    
    // game register grids
    logic [9:0] grid [19:0];    // main game grid
    logic [9:0] shadow [19:0];  // holds the currently falling tetromino bits

    // tetromino position
    logic [3:0] tetromino_x;    // column (0–9) 
    logic [4:0] tetromino_y;    // row (0–19)

    // tick counter (clock divider)
    logic [25:0] counter;
    logic [25:0] counter_set_value;
    logic tick;
    always_ff @(posedge clk, negedge reset_n) begin
        if (!reset_n) begin
            counter <= 0;
            tick    <= 0;
        end
        else begin
            counter <= counter + 1;
            tick <= (counter == counter_set_value);
            if (tick) counter <= 0;
        end
    end
    // set the counter value based on move_down signal
    assign counter_set_value = (move_down) ? 26'd8_000_000 : 26'd40_000_000;

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

    // score register
    logic [13:0] score_reg;
    assign score = score_reg;

    // pause edge detection
    logic prev_pause;
    logic pause_toggle;
    assign pause_toggle = pause && !prev_pause;

    // draw current tetromino into the shadow grid
    always_comb begin
        // clear shadow grid
        for (int y = 0; y < 20; y++) begin
            shadow[y] = 10'd0;
        end
        // draw the tetromino shape into the shadow grid
        // tetromino_x and tetromino_y are the top-left corner of the tetromino
        for (int row = 0; row < 4; row++) begin
            for (int col = 0; col < 4; col++) begin
                if (shape[15 - (row * 4 + col)]) begin
                    int gx, gy;
                    gx = tetromino_x + col;
                    gy = tetromino_y + row;
                    if (gx >= 0 && gx < 10 && gy >= 0 && gy < 20)
                        shadow[gy][gx] = 1'b1;
                end
            end
        end
    end

    // lfsr for pseudo-random tetromino generation
    logic [4:0] lfsr = 5'b00001;  // non-zero seed
    logic [2:0] next_tetromino_type;
    logic [2:0] last_tetromino_type;
    always_ff @(posedge clk, negedge reset_n) begin
        if (!reset_n)
            lfsr <= 5'b00001;
        else begin
            // x^5 + x^3 + 1 (common taps)
            lfsr <= {lfsr[3] ^ lfsr[0], lfsr[4:1]};
        end
    end
    assign next_tetromino_type = lfsr[2:0] % 7;
    assign next_rotation = lfsr[4:3] % 4;

    logic row_cleared_this_frame;

    // state machine for game logic
    always_ff @(posedge clk, negedge reset_n) begin
        if (!reset_n) begin
            state <= idle;
            tetromino_x <= 4'd3;
            tetromino_y <= 5'd0;
            tetromino_type <= next_tetromino_type;
            rotation <= 2'd0;
            score_reg <= 14'd0;
            game_over <= 1'b0;
            game_paused <= 1'b0;
            row_cleared <= 1'b0;
            row_cleared_this_frame <= 1'b0;
            // clear main grid
            for (int y = 0; y < 20; y++) begin
                grid[y] = 10'd0;
            end
        end 
        else begin
            prev_pause <= pause;
            case (state)

                idle: begin
                    state <= spawn;
                end

                // spawn a new piece
                spawn: begin
                    tetromino_x <= 4'd3;
                    tetromino_y <= 5'd0;
                    // generate a new tetromino type
                    if (next_tetromino_type == last_tetromino_type)
                        tetromino_type <= (next_tetromino_type + 3'd1) % 7;
                    else
                        tetromino_type <= next_tetromino_type;
                    last_tetromino_type <= tetromino_type;
                    rotation <= next_rotation;
                    rotation <= 2'd0;
                    row_cleared <= 1'b0;
                    row_cleared_this_frame <= 1'b0;
                    if (check_collision(shape, 4, 0))
                        state <= gameover;
                    else
                        state <= falling;
                end

                falling: begin
                    // gravity tick
                    if (tick) begin
                        // check if the piece can move down
                        // if it can't, lock it in place
                        if (check_collision(shape, tetromino_x, tetromino_y + 1))
                            state <= lock;
                        else begin
                            // move left/right based on ADC value
                            if (move_left && !check_collision(shape, tetromino_x - 1, tetromino_y))
                                tetromino_x <= tetromino_x - 1;
                            else if (move_right && !check_collision(shape, tetromino_x + 1, tetromino_y))
                                tetromino_x <= tetromino_x + 1;
                            // move down
                            tetromino_y <= tetromino_y + 1;
                        end
                    end
                    // pause the game
                    if (pause_toggle) begin
                        game_paused <= 1'b1;
                        state <= paused;
                    end
                    // rotate piece by updating the rotation index value
                    if (rotate_pressed) rotation <= (rotation + 1) % 4;

                end

                paused: begin
                    // unpause the game
                    if (move_left || move_right || move_down) begin
                        game_paused <= 1'b0;
                        state <= falling;
                    end
                end

                lock: begin
                    // copy shadow to grid
                    for (int y = 0; y < 20; y++) begin
                        for (int x = 0; x < 10; x++) begin
                            if (shadow[y][x])
                                grid[y][x] <= 1'b1;
                        end
                    end
                    state <= clear_rows;
                end

                clear_rows: begin
                    // row clearing logic
                    for (int y = 19; y >= 0; y--) begin
                        // if all 10 bits in the row are 1s
                        if (&grid[y]) begin
                            // shift all rows above down
                            for (int j = y; j > 0; j--) begin
                                grid[j] <= grid[j-1];
                            end
                            // clear the top row
                            grid[0] <= 10'd0;
                            // set row_cleared_this_frame signal
                            row_cleared_this_frame <= 1'b1;

                            // future update: implement multiple row clearing
                        end
                    end
                    // increment score if a row was cleared
                    state <= update_score;
                end

                update_score: begin
                    if (row_cleared_this_frame) begin
                        score_reg <= (score_reg + 10 > 9999) ? 9999 : score_reg + 10;
                        row_cleared <= 1'b1;
                        row_cleared_this_frame <= 1'b0;
                    end
                    state <= check_gameover;
                end

                check_gameover: begin
                    if (grid[0][4])
                        state <= gameover;
                    else
                        state <= spawn;
                end

                gameover: begin
                    // hold in game over
                    game_over <= 1'b1;
                end

            endcase
        end
    end

    // collision check function
    function automatic logic check_collision(
        input logic [15:0] shape,
        input logic [3:0] x,
        input logic [4:0] y
    );
        logic collision = 0;
        for (int row = 0; row < 4; row++) begin
            for (int col = 0; col < 4; col++) begin
                int bit_index = 15 - (row * 4 + col);
                if (shape[bit_index]) begin
                    int gx = x + col;
                    int gy = y + row;

                    if (gx < 0 || gx >= 10 || gy < 0 || gy >= 20) begin
                        collision = 1;
                    end else if (grid[gy][gx]) begin
                        collision = 1;
                    end
                end
            end
        end
        return collision;
    endfunction

endmodule
