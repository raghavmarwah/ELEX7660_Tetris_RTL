// File: tetris_top.sv
// Author: Raghav Marwah
// Date: Mar 13, 2025
// Description: 

module tetris_top (
    input  logic FPGA_CLK1_50,      // 50 MHz input clock
    input  logic s1,                // S1 pushbutton
    input  logic s2,                // S2 pushbutton
    input  logic joy_sel,           // joystick select
    input  logic ADC_SDO,           // serial data out (from ADC)
    output logic ADC_CONVST,        // ADC start conversion
    output logic ADC_SCK,           // ADC serial clock
    output logic ADC_SDI,           // serial data in (to ADC)
    output logic lcd_sda,           // SPI data signal to LCD
    output logic lcd_scl,           // SPI clock signal to LCD
    output logic lcd_cs,            // SPI chip select signal to LCD
    output logic lcd_rs,            // LCD data/command signal
    output logic lcd_rst,           // LCD reset signal
    output logic red, green, blue,  // RGB LED signals
    output logic [7:0] leds,        // 7-seg LED enables
    output logic [3:0] ct,          // digit cathodes for 7-segment display
    output logic spkr               // speaker output   
);

    // Avalon-MM Interface Signals
    logic avs_read;
    logic [4:0] avalon_slave_0_address;
    logic [31:0] avs_readdata;

    logic [7:0]  gpio;              // gpio signal from processor
    logic [1:0]  digit;  		    // select digit to display
	logic [3:0]  disp_digit;  	    // current digit of count to display
	logic [15:0] clk_div_count;     // count used to divide clock
    logic [11:0] adc_value;         // 12-bit ADC output
    logic [7:0]  paddle_x;          // paddle X position (range: 0 - 127)
    logic [2:0]  channel_val;       // 3-bit selected channel

    logic [199:0] grid_state;       // 200 bits for 10x20 grid
    logic [13:0] score;             // score value
    logic pause;                    // pause signal
    logic row_cleared;              // high when a row is cleared
    logic game_over;                // high when game ends
    logic game_paused;              // high when game is paused

    logic move_left;                // move left signal
    logic move_right;               // move right signal
    logic move_down;                // move down signal
    logic rotate;                   // rotate signal
    logic reset_game;               // reset game signal

    logic [3:0] bcd0;
    logic [3:0] bcd1;
    logic [3:0] bcd2;
    logic [3:0] bcd3;               // BCD digits from bin14_to_bcd4

    localparam int ADC_LEFT_THRESHOLD = 1750;   // ADC threshold for left movement
    localparam int ADC_RIGHT_THRESHOLD = 1550;  // ADC threshold for right movement
    localparam int ADC_DIFF_THRESHOLD = 429;    // ADC threshold for no movement

    // instantiate modules
    decode2 decode2_0 (
        .digit (digit),
        .ct    (ct)
    );
	decode7 decode7_0 (
        .num  (disp_digit),
        .leds (leds)
    );
    bin14_to_bcd4 bin14_to_bcd4_0 (
        .bin  (score),
        .bcd3 (bcd3),
        .bcd2 (bcd2),
        .bcd1 (bcd1),
        .bcd0 (bcd0)
    );
    tonegen #(
        .FCLK(50000000)  // 50 MHz clock, matches FPGA system clock
    ) tonegen_0 (
        .clk        (FPGA_CLK1_50),
        .reset_n    (reset_game),
        .game_over  (game_over),
        .spkr       (spkr)
    );
    tetris tetris_0 (
	    .clk_clk                    (FPGA_CLK1_50),
		.gpio_export                (gpio),
		.reset_reset_n              (reset_game),
        .lcd_signals_MISO           ('0),
		.lcd_signals_MOSI           (lcd_sda),
		.lcd_signals_SCLK           (lcd_scl),
		.lcd_signals_SS_n           (lcd_cs),
        .adc_signals_adc_convst     (ADC_CONVST),
		.adc_signals_adc_sck        (ADC_SCK),
		.adc_signals_adc_sdi        (ADC_SDI),
		.adc_signals_adc_sdo        (ADC_SDO),
		.adc_signals_chan           ('0),
		.adc_signals_result         (adc_value),
        .grid_interface_grid_state  (grid_state)
	);
    tetris_grid tetris_grid_0 (
        .clk            (FPGA_CLK1_50),
        .reset_n        (reset_game),
        .move_left      (move_left),
        .move_right     (move_right),
        .move_down      (move_down),
        .rotate         (rotate),
        .pause          (pause),
        .row_cleared    (row_cleared),
        .game_over      (game_over),
        .game_paused    (game_paused),
        .grid_state     (grid_state),
        .score          (score)
    );
 	
    // control the display data/command (lcd_rs) with gpio[0] from processor
    assign lcd_rs = gpio[0];
	
    // control active low display reset (lcd_rst) with gpio[1] from processor
    assign lcd_rst = gpio[1];

	// turn off the RGB LED on the BoosterPack
	//assign {red, green, blue} = '0;
    assign red = game_over;
    assign blue = game_paused;

    // divide clock and generate a 2-bit digit counter to determine which digit to display
	always_ff @(posedge FPGA_CLK1_50) 
		clk_div_count <= clk_div_count + 1'b1 ;

	// assign the top two bits of count to select digit to display
	assign digit = clk_div_count[15:14];  

    // 7-segment LED display multiplexing
    always_comb begin
        case (digit)
            2'd0: disp_digit = bcd0;  // rightmost digit
            2'd1: disp_digit = bcd1;
            2'd2: disp_digit = bcd2;
            2'd3: disp_digit = bcd3;  // leftmost digit
            default: disp_digit = 4'd0;
        endcase
    end

    always_ff @(posedge FPGA_CLK1_50) begin
        if (adc_value > (ADC_LEFT_THRESHOLD + ADC_DIFF_THRESHOLD)) begin
            move_right  <= 1'b1;
            move_left   <= 1'b0;
            green       <= 1'b1;
        end
        else if (adc_value < (ADC_RIGHT_THRESHOLD - ADC_DIFF_THRESHOLD)) begin
            move_right  <= 1'b0;
            move_left   <= 1'b1;
            green       <= 1'b1;
        end
        else begin
            move_right  <= 1'b0;
            move_left   <= 1'b0;
            green       <= 1'b0;
        end
    end

    // reset game when S1 and S2 are pressed
    assign reset_game = s1 || s2;
    assign rotate = !s1;
    assign move_down = !s2;
    assign pause = !joy_sel;

endmodule
