`timescale 1ns / 1ps

module modulus_tb();

    // Parameters
    parameter DATA_WIDTH = 16;

    // Inputs
    reg clock;
    reg enable;
    reg reset;
    reg signed [DATA_WIDTH-1:0] i;
    reg signed [DATA_WIDTH-1:0] q;
    reg input_valid;

    // Outputs
    wire [DATA_WIDTH-1:0] mag;
    wire mag_stb;

    // Instantiate the DUT (Device Under Test)
    modulus #(
        .WIDTH(DATA_WIDTH)) 
    dut (
        .clock(clock),
        .reset(reset),
        .idata_r(i),
        .idata_i(q),
        .ivalid(input_valid),
        .modulus(mag),
        .ovalid(mag_stb)
    );

    // Clock generation
    initial begin
        clock = 0;
        forever #5 clock = ~clock; // 10 ns clock period
    end

    initial begin
        $dumpfile("modulus.vcd");        
        $dumpvars(0, modulus_tb);   
    end
    
    // Test sequence
    initial begin
        // Initialize inputs
        enable = 0;
        reset = 1;
        i = 0;
        q = 0;
        input_valid = 0;

        // Apply reset
        #10;
        reset = 0;
        enable = 1;

        // Test case 1: i = 4, q = 3
        #10;
        i = 4;
        q = 3;
        input_valid = 1;
        #10;
        input_valid = 0;

        // Wait for output
        #30;
        $display("Test case 1: i=4, q=3 | mag=%d, mag_stb=%b (Expected mag=5)", mag, mag_stb);

        // Test case 2: i = -8, q = 7
        #10;
        i = -8;
        q = 7;
        input_valid = 1;
        #10;
        input_valid = 0;

        // Wait for output
        #30;
        $display("Test case 2: i=-8, q=7 | mag=%d, mag_stb=%b (Expected mag=11)", mag, mag_stb);

        // Test case 3: i = 2, q = -3
        #10;
        i = 2;
        q = -3;
        input_valid = 1;
        #10;
        input_valid = 0;

        // Wait for output
        #30;
        $display("Test case 3: i=2, q=-3 | mag=%d, mag_stb=%b (Expected mag=3)", mag, mag_stb);

        // End simulation
        #30;
        $finish;
    end

endmodule
