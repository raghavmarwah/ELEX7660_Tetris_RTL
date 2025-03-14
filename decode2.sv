// File: decode2.sv
// Author: Raghav Marwah
// Date: Jan 17, 2025
// Description: decode2 module implements a 2-to-4 decoder

module decode2 (input logic [1:0] digit, output logic [3:0] ct);

always_comb
	case (digit)
		0 : ct = 4'b1110;	//turn on the right most LED
		1 : ct = 4'b1101;	//turn on the 3rd LED
		2 : ct=  4'b1011;	//turn on the 2nd LED
		3 : ct = 4'b0111;	//turn on the 1st LED
	endcase

endmodule
