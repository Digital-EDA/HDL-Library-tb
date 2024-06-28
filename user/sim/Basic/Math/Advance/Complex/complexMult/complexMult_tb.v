`timescale 1ns / 1ps

module complexMult_tb();

    // Inputs
    reg clock;
    reg enable;
    reg reset;
    reg [15:0] a_i;
    reg [15:0] a_q;
    reg [15:0] b_i;
    reg [15:0] b_q;
    reg input_valid;

    // Outputs
    wire [31:0] p_i;
    wire [31:0] p_q;
    wire output_valid;

    // Instantiate the DUT (Device Under Test)
    complex_mult dut (
        .clock(clock),
        .enable(enable),
        .reset(reset),
        .a_i(a_i),
        .a_q(a_q),
        .b_i(b_i),
        .b_q(b_q),
        .input_valid(input_valid),
        .p_i(p_i),
        .p_q(p_q),
        .output_valid(output_valid)
    );

    wire 	ovalid;
    wire [31:0]	result_r;
    wire [31:0]	result_i;

    cmplMult #(
        .SCALE_FACTOR 		( 0  		),
        .REAL_WIDTH_A 		( 16 		),
        .IMAG_WIDTH_A 		( 16 		),
        .REAL_WIDTH_B 		( 16 		),
        .IMAG_WIDTH_B 		( 16 		),
        .REAL_WIDTH_O 		( 32 		),
        .IMAG_WIDTH_O 		( 32 		))
    u_cmplMult(
        //ports
        .clock    		( clock    		),
        .reset    		( reset    		),
        .ivalid   		( input_valid   		),
        .dataa_r  		( a_i  		),
        .dataa_i  		( a_q  		),
        .datab_r  		( b_i  		),
        .datab_i  		( b_q  		),
        .ovalid   		( ovalid   		),
        .result_r 		( result_r 		),
        .result_i 		( result_i 		)
    );

    // Clock generation
    initial begin
        clock = 0;
        forever #5 clock = ~clock; // 10 ns clock period
    end

    // Test sequence
    initial begin
        // Initialize inputs
        enable = 0;
        reset = 1;
        a_i = 16'd0;
        a_q = 16'd0;
        b_i = 16'd0;
        b_q = 16'd0;
        input_valid = 0;

        // Apply reset
        #10;
        reset = 0;
        enable = 1;
        
        // Test case 1
        #10;
        a_i = 16'd3;
        a_q = 16'd4;
        b_i = 16'd1;
        b_q = 16'd2;
        input_valid = 1;
        #10;
        input_valid = 0;

        // Test case 2
        #20;
        a_i = 16'd7;
        a_q = 16'd8;
        b_i = 16'd5;
        b_q = 16'd6;
        input_valid = 1;
        #10;
        input_valid = 0;

        // Test case 3
        #20;
        a_i = -16'd3;
        a_q = 16'd2;
        b_i = 16'd4;
        b_q = -16'd1;
        input_valid = 1;
        #10;
        input_valid = 0;

        // End simulation
        #30;
        $finish;
    end

    // Monitor outputs
    initial begin
        $dumpfile("complexMult.vcd");        
        $dumpvars(0, complexMult_tb);  
        $monitor("Time: %0t | a_i: %d | a_q: %d | b_i: %d | b_q: %d | p_i: %d | p_q: %d | output_valid: %b",
                 $time, a_i, a_q, b_i, b_q, p_i, p_q, output_valid);
    end

endmodule
