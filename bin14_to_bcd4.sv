// File: bin14_to_bcd4.sv
// Author: Raghav Marwah
// Date: Apr 02, 2025
// Description: Converts a 14-bit binary number to BCD (Binary-Coded Decimal) format
//              using a shift-and-add-3 algorithm. The output is 4 BCD digits.

module bin14_to_bcd4 (
    input  logic [13:0] bin,
    output logic [3:0] bcd3,  // thousands
    output logic [3:0] bcd2,  // hundreds
    output logic [3:0] bcd1,  // tens
    output logic [3:0] bcd0   // ones
);

    logic [31:0] shift_reg;

    always_comb begin
        // initialize the shift register: binary input in LSB
        shift_reg = 32'd0;
        shift_reg[13:0] = bin;

        // perform 14 iterations of shift-and-add-3
        for (int i = 0; i < 14; i++) begin
            if (shift_reg[17:14] >= 5)
                shift_reg[17:14] += 3;
            if (shift_reg[21:18] >= 5)
                shift_reg[21:18] += 3;
            if (shift_reg[25:22] >= 5)
                shift_reg[25:22] += 3;
            if (shift_reg[29:26] >= 5)
                shift_reg[29:26] += 3;

            shift_reg = shift_reg << 1;
        end
    end

    assign bcd3 = shift_reg[29:26];  // thousands
    assign bcd2 = shift_reg[25:22];  // hundreds
    assign bcd1 = shift_reg[21:18];  // tens
    assign bcd0 = shift_reg[17:14];  // ones

endmodule
