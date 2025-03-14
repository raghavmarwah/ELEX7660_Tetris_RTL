// File: adcinterface.sv
// Author: Raghav Marwah
// Date: Feb 09, 2025
// Description: this module interfaces with the LTC2308 ADC to continuously 
//   			sample from the input channel. It generates the required  
//   			CONVST pulses, 12 SCK cycles for shifting out the configuration
//   			word (SDI) and shifting in the ADC data (SDO), and outputs
//				the final 12-bit conversion result.

module adcinterface (
    input  logic clk, reset_n,		// clock and reset
    input  logic [2:0] chan,		// ADC channel to sample
    output logic [11:0] result,	    // ADC result
    // LTC2308 signals
    input  logic ADC_SDO,   		// serial data out (from ADC)
    output logic ADC_CONVST, 		// start conversion
    output logic ADC_SCK,    		// serial clock
    output logic ADC_SDI,      	    // serial data in (to ADC)
    // Avalon-MM Interface
    input  logic avs_read,              // read signal from CPU
    output logic [31:0] avs_readdata    // data to CPU
);

    // 4-bit counter for conversion sequence
    logic [3:0] conv_cycle_count;   
    // ADC clock output enable
    logic sck_enable;              
    // 6-bit shift register for config word
    logic [5:0] sdi_shift_reg;     
    // 12-bit shift register for ADC output
    logic [11:0] sdo_shift_reg;
    
    // count used to divide clock
    logic [15:0] clk_div_count;
    logic clk2; 
    // clock divider
    always_ff @(posedge clk) 
		clk_div_count <= clk_div_count + 1'b1 ;
    assign clk2 = clk_div_count[14];   

	// conversion cycle counter; sequential 4-bit counter
	// increments on the negative edge of clk
    always_ff @(negedge clk2, negedge reset_n) begin
        if (~reset_n) begin
            conv_cycle_count <= 4'd0;
        end
        else begin
            conv_cycle_count <= conv_cycle_count + 1'b1;
        end
    end
    
    always_comb begin
        // enable the ADC serial clock between counts 2 and 13 (inclusive)
        sck_enable = (conv_cycle_count >= 4'd2) && (conv_cycle_count <= 4'd13);

        // gate the system clock onto ADC_SCK only when sck_enable is high
        ADC_SCK = sck_enable ? clk2 : 1'b0;

        // pulse ADC_CONVST high for one clock cycle when conv_cycle_count == 0
        ADC_CONVST = (&(~conv_cycle_count)) ? 1'b1 : 1'b0;

        // drive the MSB of sdi_shift_reg onto ADC_SDI
        ADC_SDI = sdi_shift_reg[5];
    end

	// shift register for SDI
    // loads config word on rising edge of ADC_CONVST
    // shifts left on falling edge of ADC_SCK
    always_ff @(posedge ADC_CONVST, negedge ADC_SCK) begin
        if (ADC_CONVST) begin
            sdi_shift_reg <= {1'b1, chan[0], chan[2:1], 1'b1, 1'b0};
        end
        else begin
            sdi_shift_reg <= sdi_shift_reg << 1'b1;
        end
    end

	// shift register for SDO
    // on rising edge of ADC_SCK, latch next bit from ADC_SDO
    always_ff @(posedge ADC_SCK) begin
        sdo_shift_reg <= (sdo_shift_reg << 1'b1) | ADC_SDO;
    end

    // update final ADC result
    // when sck_enable goes low, the 12 bits have been fully captured
    always_ff @(negedge sck_enable, negedge reset_n) begin
        if (~reset_n) begin
            result <= 12'd0;
        end
        else begin
            result <= sdo_shift_reg;
        end
    end

    // Avalon-MM read operation
    // send 12-bit ADC result to CPU (upper 20 bits are 0)
    //assign avs_readdata = {20'd0, result};
    always_ff @(posedge clk) begin
        if (avs_read) begin
            avs_readdata <= {20'd0, result}; // Update only on read request
        end
    end

endmodule
