module phase_tb;

    // Parameters
    parameter DATA_WIDTH = 32;

    // Testbench signals
    reg clock;
    reg reset;
    reg enable;
    reg signed [DATA_WIDTH-1:0] in_i;
    reg signed [DATA_WIDTH-1:0] in_q;
    reg input_strobe;

    wire 	           ovalid;
    wire signed [15:0] phase;

    phase #(
        .WIDTH 		( DATA_WIDTH 	))
    u_phase(
        //ports
        .clock   		( clock   		),
        .reset   		( reset   		),
        .ivalid  		( input_strobe  ),
        .idata_r 		( in_i 		    ),
        .idata_i 		( in_q 		    ),
        .ovalid  		( ovalid  		),
        .phase   		( phase   		)
    );

    // Clock generation
    always #5 clock = ~clock;

    // Testbench stimulus
    initial begin
        // Initialize signals
        clock = 0;
        reset = 1;
        enable = 0;
        in_i = 0;
        in_q = 0;
        input_strobe = 0;

        // Apply reset
        #25;
        reset = 0;

        // Enable the module
        enable = 1;

        // Test case 1: in_i = 1, in_q = 0 (0 degrees)
        in_i = 32'd1;
        in_q = 32'd0;
        // in_i = 32'd10000;
        // in_q = 32'd0;
        input_strobe = 1;
        #10;
        input_strobe = 0;
        #10;
        $display("Test case 1: phase = %d", phase);

        // Test case 2: in_i = 0, in_q = 1 (90 degrees)
        in_i = 32'd0;
        in_q = 32'd1;
        input_strobe = 1;
        #10;
        input_strobe = 0;
        #10;
        $display("Test case 2: phase = %d", phase);

        // Test case 3: in_i = -1, in_q = 0 (180 degrees)
        in_i = -32'd1;
        in_q = 32'd0;
        input_strobe = 1;
        #10;
        input_strobe = 0;
        #10;
        $display("Test case 3: phase = %d", phase);

        // Test case 4: in_i = 0, in_q = -1 (-90 degrees)
        in_i = 32'd0;
        in_q = -32'd1;
        input_strobe = 1;
        #10;
        input_strobe = 0;
        #10;
        $display("Test case 4: phase = %d", phase);

        // Test case 5: in_i = 1, in_q = 1 (45 degrees)
        in_i = 32'd1;
        in_q = 32'd1;
        input_strobe = 1;
        #10;
        input_strobe = 0;
        #10;
        $display("Test case 5: phase = %d", phase);

        // End simulation
        $finish;
    end

    initial begin
        $dumpfile("phase.vcd");        
        $dumpvars(0, phase_tb);   
    end

endmodule
