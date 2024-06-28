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
    Mean uut (
        .clock(clock),
        .reset(reset),
        .sign(0),
        .A(a),
        .B(b),
        .ivalid(input_valid),
        .C(c),
        .ovalid(output_valid)
    );

    wire [15:0]	cout;
    wire 	output_strobe;

    calc_mean u_calc_mean(
        //ports
        .clock         		( clock         		),
        .enable        		( enable        		),
        .reset         		( reset         		),
        .a             		( a             		),
        .b             		( b             		),
        .sign          		( 0          		),
        .input_strobe  		( input_valid  		),
        .c             		( cout             		),
        .output_strobe 		( output_strobe 		)
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
    end

endmodule
