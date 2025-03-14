// File: breakout_top.sv
// Author: Raghav Marwah
// Date: Mar 13, 2025
// Description: 

module breakout_top (
    input  logic FPGA_CLK1_50,      // 50 MHz input clock
    input  logic s1,                // S1 pushbutton
    input  logic s2,                // S2 pushbutton
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
    output logic [3:0] ct           // digit cathodes for 7-segment display
);

    logic [7:0]  gpio;              // gpio signal from processor
    logic [1:0]  digit;  		    // select digit to display
	logic [3:0]  disp_digit;  	    // current digit of count to display
	logic [15:0] clk_div_count;     // count used to divide clock
    logic [11:0] adc_value;         // 12-bit ADC output
    //logic [2:0]  channel_val;       // 3-bit selected channel
    
    logic [7:0]  paddle_x;          // paddle X position (range: 0 - 127)

    // Avalon-MM Interface Signals
    logic avs_read;
    logic [31:0] avs_readdata;

    // instantiate modules
    decode2 decode2_0 (
        .digit (digit),
        .ct    (ct)
    );
	decode7 decode7_0 (
        .num  (disp_digit),
        .leds (leds)
    );
    // adcinterface adc_int_0 (
    //     .clk          (clk_div_count[14]),
    //     .reset_n      (s1),
    //     .chan         ('0),       // channel 0: joystick X-axis
    //     .result       (adc_value),
    //     .avs_read     (avs_read),
    //     .avs_readdata (avs_readdata),
    //     .ADC_SDO      (ADC_SDO),
    //     .ADC_CONVST   (ADC_CONVST),
    //     .ADC_SCK      (ADC_SCK),
    //     .ADC_SDI      (ADC_SDI)
    // );
    breakout breakout_0 (
		.clk_clk             (FPGA_CLK1_50),
		.gpio_export         (gpio),
		.reset_reset_n       (s1),
		.spi_0_external_MISO ('0),
		.spi_0_external_MOSI (lcd_sda),
		.spi_0_external_SCLK (lcd_scl),
		.spi_0_external_SS_n (lcd_cs)
	);
 	
    // control the display data/command (lcd_rs) with gpio[0] from processor
    assign lcd_rs = gpio[0];
	
    // control active low display reset (lcd_rst) with gpio[1] from processor
    assign lcd_rst = gpio[1];

	// turn off the RGB LED on the BoosterPack
	assign {red, green, blue} = '0;

    // divide clock and generate a 2-bit digit counter to determine which digit to display
	always_ff @(posedge FPGA_CLK1_50) 
		clk_div_count <= clk_div_count + 1'b1 ;

	// assign the top two bits of count to select digit to display
	assign digit = clk_div_count[15:14];  

    // 7-segment LED display multiplexing
    always_comb begin
    //    case(digit)
    //         2'b00: disp_digit = adc_value[3:0];
    //         2'b01: disp_digit = adc_value[7:4];
    //         2'b10: disp_digit = adc_value[11:8];
	// 	    2'b11: disp_digit = {1'b0, channel_val};
	// 		default: disp_digit = 4'd0; // default case to prevent any problems
	// 	endcase
        disp_digit = '0;
    end

    // scale 12-bit ADC value to 8-bit Paddle X (0-127)
    // always_ff @(posedge FPGA_CLK1_50, negedge s1) begin
    //     if (!s1)
    //         paddle_x <= 'd64;               // center paddle on reset
    //     else
    //         paddle_x <= adc_value[11:4];  // scale ADC value
    // end 

endmodule
