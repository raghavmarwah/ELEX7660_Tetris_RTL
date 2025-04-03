// File: decode7.sv
// Author: Raghav Marwah
// Date: Jan 17, 2025
// Description: decode7 module implements a 4-bit to 7-segment decoder.

module decode7 (input logic [3:0] num, output logic [7:0] leds);

always_comb
	case (num)
		0 : leds = 7'b0111111; // display 0
		1 : leds = 7'b0000110;	//display 1   
		2 : leds = 7'b1011011;	//display 2
		3 : leds = 7'b1001111;	//display 3
		4 : leds = 7'b1100110;	//display 4
		5 : leds = 7'b1101101;	//display 5
		6 : leds = 7'b1111101;	//display 6
		7 : leds = 7'b0000111;	//display 7
		8 : leds = 7'b1111111;	//display 8
		9 : leds = 7'b1100111;	//display 9 
		10: leds = 7'b1110111;	//display A
		11: leds = 7'b1111111;	//display B
		12: leds = 7'b0111001;	//display C
		13: leds = 7'b0111111;	//display D
		14: leds = 7'b1111001;	//display E
		15: leds = 7'b1110001;	//display F
		default: leds = 7'b0000000; // display nothing
	endcase

endmodule
