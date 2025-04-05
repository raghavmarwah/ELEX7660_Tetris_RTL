// File: tonegen.sv
// Author: Raghav Marwah
// Date: Apr 03, 2025
// Description: A tone generator module that plays a melody when the game is over.
//              The melody is defined in the module using frequency and duration values
//              for each note. The melody is played through a speaker output (spkr) and
//              is controlled by the game_over signal. The module uses a clock divider
//              to generate a 1ms tick for timing the note durations.

module tonegen #(
    parameter FCLK = 50000000  // 50 MHz default
)(
    input  logic clk,
    input  logic reset_n,
    input  logic game_over,
    output logic spkr
);

    // number of notes in the melody
    localparam int NUM_NOTES = 97;
    typedef logic [$clog2(NUM_NOTES)-1:0] note_t; // auto-sized note index type

    // -----------------------------------------------------------------------------
    // MELODY ROMs  –  Tetris “Korobeiniki” (quarter‑note = 500 ms)
    // https://github.com/robsoncouto/arduino-songs/blob/master/tetris/tetris.ino
    // Converted by ChatGPT
    // -----------------------------------------------------------------------------

    // ROMs for frequency (in Hz)
    function automatic [31:0] get_note_freq(input note_t idx);
        case (idx)
            7'd0 : get_note_freq = 659;  // E5
            7'd1 : get_note_freq = 494;  // B4
            7'd2 : get_note_freq = 523;  // C5
            7'd3 : get_note_freq = 587;  // D5
            7'd4 : get_note_freq = 523;  // C5
            7'd5 : get_note_freq = 494;  // B4
            7'd6 : get_note_freq = 440;  // A4
            7'd7 : get_note_freq = 440;  // A4
            7'd8 : get_note_freq = 523;  // C5
            7'd9 : get_note_freq = 659;  // E5
            7'd10: get_note_freq = 587;  // D5
            7'd11: get_note_freq = 523;  // C5
            7'd12: get_note_freq = 494;  // B4
            7'd13: get_note_freq = 523;  // C5
            7'd14: get_note_freq = 587;  // D5
            7'd15: get_note_freq = 659;  // E5
            7'd16: get_note_freq = 523;  // C5
            7'd17: get_note_freq = 440;  // A4
            7'd18: get_note_freq = 440;  // A4
            7'd19: get_note_freq =   0;  // rest
            7'd20: get_note_freq =   0;  // rest
            7'd21: get_note_freq = 587;  // D5
            7'd22: get_note_freq = 698;  // F5
            7'd23: get_note_freq = 880;  // A5
            7'd24: get_note_freq = 784;  // G5
            7'd25: get_note_freq = 698;  // F5
            7'd26: get_note_freq = 659;  // E5
            7'd27: get_note_freq = 523;  // C5
            7'd28: get_note_freq = 659;  // E5
            7'd29: get_note_freq = 587;  // D5
            7'd30: get_note_freq = 523;  // C5
            7'd31: get_note_freq = 494;  // B4
            7'd32: get_note_freq = 494;  // B4
            7'd33: get_note_freq = 523;  // C5
            7'd34: get_note_freq = 587;  // D5
            7'd35: get_note_freq = 659;  // E5
            7'd36: get_note_freq = 523;  // C5
            7'd37: get_note_freq = 440;  // A4
            7'd38: get_note_freq = 440;  // A4
            7'd39: get_note_freq =   0;  // rest
            7'd40: get_note_freq = 659;  // E5
            7'd41: get_note_freq = 523;  // C5
            7'd42: get_note_freq = 587;  // D5
            7'd43: get_note_freq = 494;  // B4
            7'd44: get_note_freq = 523;  // C5
            7'd45: get_note_freq = 440;  // A4
            7'd46: get_note_freq = 494;  // B4
            7'd47: get_note_freq = 659;  // E5
            7'd48: get_note_freq = 523;  // C5
            7'd49: get_note_freq = 587;  // D5
            7'd50: get_note_freq = 494;  // B4
            7'd51: get_note_freq = 523;  // C5
            7'd52: get_note_freq = 659;  // E5
            7'd53: get_note_freq = 880;  // A5
            7'd54: get_note_freq = 831;  // G#5
            7'd55: get_note_freq = 659;  // E5
            7'd56: get_note_freq = 494;  // B4
            7'd57: get_note_freq = 523;  // C5
            7'd58: get_note_freq = 587;  // D5
            7'd59: get_note_freq = 523;  // C5
            7'd60: get_note_freq = 494;  // B4
            7'd61: get_note_freq = 440;  // A4
            7'd62: get_note_freq = 440;  // A4
            7'd63: get_note_freq = 523;  // C5
            7'd64: get_note_freq = 659;  // E5
            7'd65: get_note_freq = 587;  // D5
            7'd66: get_note_freq = 523;  // C5
            7'd67: get_note_freq = 494;  // B4
            7'd68: get_note_freq = 523;  // C5
            7'd69: get_note_freq = 587;  // D5
            7'd70: get_note_freq = 659;  // E5
            7'd71: get_note_freq = 523;  // C5
            7'd72: get_note_freq = 440;  // A4
            7'd73: get_note_freq = 440;  // A4
            7'd74: get_note_freq =   0;  // rest
            7'd75: get_note_freq =   0;  // rest
            7'd76: get_note_freq = 587;  // D5
            7'd77: get_note_freq = 698;  // F5
            7'd78: get_note_freq = 880;  // A5
            7'd79: get_note_freq = 784;  // G5
            7'd80: get_note_freq = 698;  // F5
            7'd81: get_note_freq =   0;  // rest
            7'd82: get_note_freq = 659;  // E5
            7'd83: get_note_freq = 523;  // C5
            7'd84: get_note_freq = 659;  // E5
            7'd85: get_note_freq = 587;  // D5
            7'd86: get_note_freq = 523;  // C5
            7'd87: get_note_freq =   0;  // rest
            7'd88: get_note_freq = 494;  // B4
            7'd89: get_note_freq = 523;  // C5
            7'd90: get_note_freq = 587;  // D5
            7'd91: get_note_freq = 659;  // E5
            7'd92: get_note_freq =   0;  // rest
            7'd93: get_note_freq = 523;  // C5
            7'd94: get_note_freq = 440;  // A4
            7'd95: get_note_freq = 440;  // A4
            7'd96: get_note_freq =   0;  // rest
            default: get_note_freq = 0;
        endcase
    endfunction

    // ROM for note duration (in ms)
    function automatic [15:0] get_note_duration(input note_t idx);
        case (idx)
            7'd0 : get_note_duration = 500;
            7'd1 : get_note_duration = 250;
            7'd2 : get_note_duration = 250;
            7'd3 : get_note_duration = 500;
            7'd4 : get_note_duration = 250;
            7'd5 : get_note_duration = 250;
            7'd6 : get_note_duration = 500;
            7'd7 : get_note_duration = 250;
            7'd8 : get_note_duration = 250;
            7'd9 : get_note_duration = 500;
            7'd10: get_note_duration = 250;
            7'd11: get_note_duration = 250;
            7'd12: get_note_duration = 750;   // dotted ¼
            7'd13: get_note_duration = 250;
            7'd14: get_note_duration = 500;
            7'd15: get_note_duration = 500;
            7'd16: get_note_duration = 500;
            7'd17: get_note_duration = 500;
            7'd18: get_note_duration = 500;
            7'd19: get_note_duration = 500;   // rest
            7'd20: get_note_duration = 250;   // rest
            7'd21: get_note_duration = 500;
            7'd22: get_note_duration = 250;
            7'd23: get_note_duration = 500;
            7'd24: get_note_duration = 250;
            7'd25: get_note_duration = 250;
            7'd26: get_note_duration = 750;
            7'd27: get_note_duration = 250;
            7'd28: get_note_duration = 500;
            7'd29: get_note_duration = 250;
            7'd30: get_note_duration = 250;
            7'd31: get_note_duration = 500;
            7'd32: get_note_duration = 250;
            7'd33: get_note_duration = 250;
            7'd34: get_note_duration = 500;
            7'd35: get_note_duration = 500;
            7'd36: get_note_duration = 500;
            7'd37: get_note_duration = 500;
            7'd38: get_note_duration = 500;
            7'd39: get_note_duration = 500;   // rest
            7'd40: get_note_duration = 1000;
            7'd41: get_note_duration = 1000;
            7'd42: get_note_duration = 1000;
            7'd43: get_note_duration = 1000;
            7'd44: get_note_duration = 1000;
            7'd45: get_note_duration = 1000;
            7'd46: get_note_duration = 2000;  // whole note
            7'd47: get_note_duration = 1000;
            7'd48: get_note_duration = 1000;
            7'd49: get_note_duration = 1000;
            7'd50: get_note_duration = 1000;
            7'd51: get_note_duration = 500;
            7'd52: get_note_duration = 500;
            7'd53: get_note_duration = 1000;
            7'd54: get_note_duration = 2000;
            7'd55: get_note_duration = 500;
            7'd56: get_note_duration = 250;
            7'd57: get_note_duration = 250;
            7'd58: get_note_duration = 500;
            7'd59: get_note_duration = 250;
            7'd60: get_note_duration = 250;
            7'd61: get_note_duration = 500;
            7'd62: get_note_duration = 250;
            7'd63: get_note_duration = 250;
            7'd64: get_note_duration = 500;
            7'd65: get_note_duration = 250;
            7'd66: get_note_duration = 250;
            7'd67: get_note_duration = 750;
            7'd68: get_note_duration = 250;
            7'd69: get_note_duration = 500;
            7'd70: get_note_duration = 500;
            7'd71: get_note_duration = 500;
            7'd72: get_note_duration = 500;
            7'd73: get_note_duration = 500;
            7'd74: get_note_duration = 500;   // rest
            7'd75: get_note_duration = 250;   // rest
            7'd76: get_note_duration = 500;
            7'd77: get_note_duration = 250;
            7'd78: get_note_duration = 500;
            7'd79: get_note_duration = 250;
            7'd80: get_note_duration = 250;
            7'd81: get_note_duration = 250;   // rest
            7'd82: get_note_duration = 500;
            7'd83: get_note_duration = 250;
            7'd84: get_note_duration = 500;
            7'd85: get_note_duration = 250;
            7'd86: get_note_duration = 250;
            7'd87: get_note_duration = 250;   // rest
            7'd88: get_note_duration = 500;
            7'd89: get_note_duration = 250;
            7'd90: get_note_duration = 500;
            7'd91: get_note_duration = 500;
            7'd92: get_note_duration = 250;   // rest
            7'd93: get_note_duration = 500;
            7'd94: get_note_duration = 250;
            7'd95: get_note_duration = 500;
            7'd96: get_note_duration = 5000; // <-- long pause before the loop
            default: get_note_duration = 0;
        endcase
    endfunction

    // internal state
    logic playing;
    note_t note_index;
    logic [15:0] ms_counter;
    logic [31:0] freq;
    logic [31:0] acc;

    // speaker toggle generation
    logic [31:0] count;

    // 1 ms tick generator using clk divider
    logic [15:0] ms_tick_divider;
    logic ms_tick;

    always_ff @(posedge clk, negedge reset_n) begin
        if (!reset_n) begin
            playing <= 0;
            note_index <= 0;
            ms_counter <= 0;
            freq <= 0;
            acc <= 0;
            spkr <= 0;
            ms_tick_divider <= 0;
            ms_tick <= 0;
        end else begin
            // generate 1ms tick from 50 MHz clock
            if (ms_tick_divider == 49999) begin
                ms_tick_divider <= 0;
                ms_tick <= 1;
            end else begin
                ms_tick_divider <= ms_tick_divider + 1;
                ms_tick <= 0;
            end

            // start playing melody on game over
            if (game_over && !playing) begin
                playing <= 1;
                note_index <= 0;
                ms_counter <= get_note_duration(0);
                freq <= get_note_freq(0);
            end else if (playing) begin
                // countdown for current note duration
                if (ms_tick && ms_counter > 0) begin
                    ms_counter <= ms_counter - 1;
                end else if (ms_counter == 0) begin
                    note_index <= note_index + 1;
                    if (note_index + 1 < NUM_NOTES) begin
                        freq <= get_note_freq(note_index + 1);
                        ms_counter <= get_note_duration(note_index + 1);
                    end else begin
                        playing <= 0;
                        freq <= 0;
                    end
                end
            end

            // square wave generation
            if (freq > 0) begin
                acc <= acc + (freq << 1); // accumulate twice the freq
                if (acc >= FCLK) begin
                    acc <= acc - FCLK;
                    spkr <= ~spkr; // toggle speaker output
                end
            end else begin
                spkr <= 0; // silence on rest
            end
        end
    end

endmodule
