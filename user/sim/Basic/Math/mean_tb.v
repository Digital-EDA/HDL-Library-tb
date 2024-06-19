`timescale 1ns/1ps

module mean_tb();

    // Inputs
    reg clock;
    reg enable;
    reg reset;
    reg signed [15:0] a;
    reg signed [15:0] b;
    reg input_valid;

    // Outputs
    wire signed [15:0] c;
    wire output_valid;

    // Instantiate the Unit Under Test (UUT)
    mean uut (
        .clock(clock),
        .enable(enable),
        .reset(reset),
        .sign(0),
        .A(a),
        .B(b),
        .ivalid(input_valid),
        .C(c),
        .ovalid(output_valid)
    );

    // Clock generation
    always #5 clock = ~clock; // 10ns clock period

    initial begin
        // Initialize inputs
        clock = 0;
        enable = 0;
        reset = 1;
        a = 0;
        b = 0;
        input_valid = 0;

        // Release reset
        #10;
        reset = 0;
        enable = 1;

        // Apply inputs
        #10;
        input_valid = 1;
        a = -31;
        b = 11;
        #10;
        input_valid = 0;

        // Wait for result
        #20;

        // Apply more inputs
        #10;
        input_valid = 1;
        a = 11;
        b = 21;
        #10;
        input_valid = 0;

        // Wait for result
        #20;

        // Finish simulation
        $finish;
    end

    // Monitor signals
    initial begin
        $dumpfile("mean.vcd");        
        $dumpvars(0, mean_tb);   
        $monitor("Time: %0t | clock: %b | reset: %b | enable: %b | input_valid: %b | a: %d | b: %d | c: %d | output_valid: %b", 
                 $time, clock, reset, enable, input_valid, a, b, c, output_valid);
    end

endmodule
