`timescale 1ns / 1ps

module complexAdsu_tb();

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
    wire 	ovalid;
    wire [15:0]	result_r;
    wire [15:0]	result_i;

    cmplAdsu #(
        .SCALE_FACTOR 		( 1  		),
        .REAL_WIDTH_A 		( 16 		),
        .IMAG_WIDTH_A 		( 16 		),
        .REAL_WIDTH_B 		( 16 		),
        .IMAG_WIDTH_B 		( 16 		),
        .REAL_WIDTH_O 		( 16 		),
        .IMAG_WIDTH_O 		( 16 		))
    u_cmplMult(
        //ports
        .clock    		( clock    		),
        .reset    		( reset    		),
        .add_sub        ( 0             ),
        .ivalid   		( input_valid   ),
        .dataa_r  		( a_i  		    ),
        .dataa_i  		( a_q  		    ),
        .datab_r  		( b_i  		    ),
        .datab_i  		( b_q  		    ),
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
        $dumpfile("complexAdsu.vcd");        
        $dumpvars(0, complexAdsu_tb); 
    end

endmodule
