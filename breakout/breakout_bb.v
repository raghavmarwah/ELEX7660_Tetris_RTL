
module breakout (
	adcinterface_0_conduit_end_adc_convst,
	adcinterface_0_conduit_end_adc_sck,
	adcinterface_0_conduit_end_adc_sdi,
	adcinterface_0_conduit_end_adc_sdo,
	adcinterface_0_conduit_end_chan,
	adcinterface_0_conduit_end_result,
	clk_clk,
	gpio_export,
	reset_reset_n,
	spi_0_external_MISO,
	spi_0_external_MOSI,
	spi_0_external_SCLK,
	spi_0_external_SS_n);	

	output		adcinterface_0_conduit_end_adc_convst;
	output		adcinterface_0_conduit_end_adc_sck;
	output		adcinterface_0_conduit_end_adc_sdi;
	input		adcinterface_0_conduit_end_adc_sdo;
	input	[2:0]	adcinterface_0_conduit_end_chan;
	output	[11:0]	adcinterface_0_conduit_end_result;
	input		clk_clk;
	output	[7:0]	gpio_export;
	input		reset_reset_n;
	input		spi_0_external_MISO;
	output		spi_0_external_MOSI;
	output		spi_0_external_SCLK;
	output		spi_0_external_SS_n;
endmodule
