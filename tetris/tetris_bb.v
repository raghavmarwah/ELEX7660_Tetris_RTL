
module tetris (
	adc_signals_adc_convst,
	adc_signals_adc_sck,
	adc_signals_adc_sdi,
	adc_signals_adc_sdo,
	adc_signals_chan,
	adc_signals_result,
	clk_clk,
	gpio_export,
	lcd_signals_MISO,
	lcd_signals_MOSI,
	lcd_signals_SCLK,
	lcd_signals_SS_n,
	reset_reset_n,
	grid_interface_grid_state);	

	output		adc_signals_adc_convst;
	output		adc_signals_adc_sck;
	output		adc_signals_adc_sdi;
	input		adc_signals_adc_sdo;
	input	[2:0]	adc_signals_chan;
	output	[11:0]	adc_signals_result;
	input		clk_clk;
	output	[7:0]	gpio_export;
	input		lcd_signals_MISO;
	output		lcd_signals_MOSI;
	output		lcd_signals_SCLK;
	output		lcd_signals_SS_n;
	input		reset_reset_n;
	input	[199:0]	grid_interface_grid_state;
endmodule
