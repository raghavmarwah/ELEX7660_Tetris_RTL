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
    localparam int NUM_NOTES = 23;

    // ROMs for frequency (in Hz)
    function automatic [31:0] get_note_freq(input logic [4:0] idx);
        case (idx)
            5'd0:  get_note_freq = 659; // E5
            5'd1:  get_note_freq = 494; // B4
            5'd2:  get_note_freq = 523; // C5
            5'd3:  get_note_freq = 587; // D5
            5'd4:  get_note_freq = 523; // C5
            5'd5:  get_note_freq = 494; // B4
            5'd6:  get_note_freq = 440; // A4
            5'd7:  get_note_freq = 440; // A4
            5'd8:  get_note_freq = 523; // C5
            5'd9:  get_note_freq = 659; // E5
            5'd10: get_note_freq = 587; // D5
            5'd11: get_note_freq = 523; // C5
            5'd12: get_note_freq = 494; // B4
            5'd13: get_note_freq = 523; // C5
            5'd14: get_note_freq = 587; // D5
            5'd15: get_note_freq = 659; // E5
            5'd16: get_note_freq = 523; // C5
            5'd17: get_note_freq = 494; // B4
            5'd18: get_note_freq = 523; // C5
            5'd19: get_note_freq = 440; // A4
            5'd20: get_note_freq = 0;   // rest
            5'd21: get_note_freq = 440; // A4
            5'd22: get_note_freq = 0;   // rest
            default: get_note_freq = 0;
        endcase
    endfunction

    // ROM for note duration (in ms)
    function automatic [15:0] get_note_duration(input logic [4:0] idx);
        case (idx)
            6'd0:  get_note_duration = 500;
            6'd1:  get_note_duration = 250;
            6'd2:  get_note_duration = 250;
            6'd3:  get_note_duration = 500;
            6'd4:  get_note_duration = 250;
            6'd5:  get_note_duration = 250;
            6'd6:  get_note_duration = 500;
            6'd7:  get_note_duration = 250;
            6'd8:  get_note_duration = 250;
            6'd9:  get_note_duration = 500;
            6'd10: get_note_duration = 250;
            6'd11: get_note_duration = 250;
            6'd12: get_note_duration = 500;
            6'd13: get_note_duration = 250;
            6'd14: get_note_duration = 250;
            6'd15: get_note_duration = 500;
            6'd16: get_note_duration = 250;
            6'd17: get_note_duration = 250;
            6'd18: get_note_duration = 500;
            6'd19: get_note_duration = 500;
            6'd20: get_note_duration = 100;
            6'd21: get_note_duration = 500;
            6'd22: get_note_duration = 15000;
            default: get_note_duration = 0;
        endcase
    endfunction

    // internal state
    logic playing;
    logic [3:0] note_index;
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
