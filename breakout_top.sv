// File: breakout_top.sv
// Author: Raghav Marwah
// Date: Mar 13, 2025
// Description: 

module breakout_top (
    input  logic FPGA_CLK1_50,      // 50 MHz input clock
    input  logic s1,                // S1 pushbutton
    input  logic s2,                // S2 pushbutton
    output logic lcd_sda,           // SPI data signal to LCD
    output logic lcd_scl,           // SPI clock signal to LCD
    output logic lcd_cs,            // SPI chip select signal to LCD
    output logic lcd_rs,            // LCD data/command signal
    output logic lcd_rst,           // LCD reset signal
    output logic red, green, blue   // RGB LED signals
);

    // gpio signal from processor
    logic [7:0] gpio;  

    // instantiate processor system
    breakout b0 (
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

endmodule
