`timescale 1ns / 1ps

module divider_tb;

    // Inputs
    reg clock;
    reg reset;
    reg enable;
    reg signed [31:0] dividend;
    reg signed [23:0] divisor;
    reg input_valid;

    wire 	            ovalid;
    wire signed [31:0]	quotient;

    divider #(
        .DIVIDEND 		( 32 		),
        .DIVISOR  		( 24 		))
    u_divider(
        //ports
        .clock    		( clock    		),
        .reset    		( reset    		),
        .ivalid   		( input_valid   ),
        .divisor  		( divisor  		),
        .dividend 		( dividend 		),
        .ovalid   		( ovalid   		),
        .quotient 		( quotient 		)
    );


    // Clock generation
    initial begin
        clock = 0;
        forever #5 clock = ~clock; // 10 ns clock period
    end

    initial begin
        $dumpfile("divider.vcd");        
        $dumpvars(0, divider_tb);   
    end

    // Test sequence
    initial begin
        // Initialize inputs
        reset = 1;
        enable = 0;
        dividend = 0;
        divisor = 0;
        input_valid = 0;

        // Apply reset
        #15;
        reset = 0;
        enable = 1;

        // Test case 1: dividend = 100, divisor = 5
        #10;
        dividend = 100;
        divisor = 5;
        input_valid = 1;
        #10;
        input_valid = 0;

        // Wait for output
        #360; // Adjust this delay based on your divider implementation
        $display("Test case 1: dividend=100, divisor=5 | quotient=%d, output_valid=%b (Expected quotient=20)", quotient, output_valid);

        // Test case 2: dividend = -100, divisor = 5
        #10;
        dividend = -100;
        divisor = 5;
        input_valid = 1;
        #10;
        input_valid = 0;

        // Wait for output
        #360;
        $display("Test case 2: dividend=-100, divisor=5 | quotient=%d, output_valid=%b (Expected quotient=-20)", quotient, output_valid);

        // Test case 3: dividend = 100, divisor = -5
        #10;
        dividend = 103;
        divisor = -5;
        input_valid = 1;
        #10;
        input_valid = 0;

        // Wait for output
        #360;
        $display("Test case 3: dividend=100, divisor=-5 | quotient=%d, output_valid=%b (Expected quotient=-20)", quotient, output_valid);

        // Test case 4: dividend = -100, divisor = -5
        #10;
        dividend = -100;
        divisor = -5;
        input_valid = 1;
        #10;
        input_valid = 0;

        // Wait for output
        #360;
        $display("Test case 4: dividend=-100, divisor=-5 | quotient=%d, output_valid=%b (Expected quotient=20)", quotient, output_valid);

        // Test case 5: dividend = 0, divisor = 5
        #10;
        dividend = 0;
        divisor = 5;
        input_valid = 1;
        #10;
        input_valid = 0;

        // Wait for output
        #360;
        $display("Test case 5: dividend=0, divisor=5 | quotient=%d, output_valid=%b (Expected quotient=0)", quotient, output_valid);

        // End simulation
        #360;
        $finish;
    end

endmodule
