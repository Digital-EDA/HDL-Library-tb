`timescale 1ns/1ps

module DDS_tb;

    // Parameters
    parameter OUTPUT_WIDTH = 12;
    parameter PHASE_WIDTH  = 32;

    // Testbench signals
    reg                       clock;
    reg                       reset; 
    reg  [PHASE_WIDTH-1 : 0]  Fre_word;
    reg  [PHASE_WIDTH-1 : 0]  Pha_word;
    wire [OUTPUT_WIDTH-1 : 0] wave_out_sin;
    wire [OUTPUT_WIDTH-1 : 0] wave_out_tri;
    wire [OUTPUT_WIDTH-1 : 0] wave_out_saw;

    // Instantiate the DDS module
    DDS #(
        .OUTPUT_WIDTH(OUTPUT_WIDTH),
        .PHASE_WIDTH(PHASE_WIDTH)
    ) uut (
        .clock(clock),
        .reset(reset),
        .Fre_word(32'h00300000),
        .Pha_word(32'h00400000),
        .wave_out_sin(wave_out_sin),
        .wave_out_tri(wave_out_tri),
        .wave_out_saw(wave_out_saw)
    );

    // Clock generation
    always #5 clock = ~clock;

    // Testbench stimulus
    initial begin
        // Initialize signals
        clock = 0;
        reset = 0;
        Fre_word = 0;
        Pha_word = 0;

        // Apply reset
        #10;
        reset = 1;
        #10;
        reset = 0;

        // Test case 1: Basic frequency and phase
        Fre_word = 32'h10000000; // Some frequency word
        Pha_word = 32'h20000000; // Some phase word
        #100;
        $display("Test case 1: wave_out_sin = %d, wave_out_tri = %d, wave_out_saw = %d", wave_out_sin, wave_out_tri, wave_out_saw);

        // Test case 2: Different frequency and phase
        Fre_word = 32'h30000000; // Different frequency word
        Pha_word = 32'h40000000; // Different phase word
        #100;
        $display("Test case 2: wave_out_sin = %d, wave_out_tri = %d, wave_out_saw = %d", wave_out_sin, wave_out_tri, wave_out_saw);

        // Test case 3: Edge case with maximum frequency and phase
        Fre_word = 32'hFFFFFFFF; // Maximum frequency word
        Pha_word = 32'hFFFFFFFF; // Maximum phase word
        #100;
        $display("Test case 3: wave_out_sin = %d, wave_out_tri = %d, wave_out_saw = %d", wave_out_sin, wave_out_tri, wave_out_saw);

        // Test case 4: Zero frequency and phase
        Fre_word = 32'h00000000; // Zero frequency word
        Pha_word = 32'h00000000; // Zero phase word
        #100;
        $display("Test case 4: wave_out_sin = %d, wave_out_tri = %d, wave_out_saw = %d", wave_out_sin, wave_out_tri, wave_out_saw);

        // End simulation
        $finish;
    end

    initial begin
        $dumpfile("DDS.vcd");        
        $dumpvars(0, DDS_tb);   
    end

endmodule
