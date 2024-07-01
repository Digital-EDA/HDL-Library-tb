module cordic_tb;

    // Parameters
    parameter DATA_WIDTH = 32;

    // Testbench signals
    reg clock;
    reg reset;
    reg enable;
    reg signed [DATA_WIDTH-1:0] in_i;
    reg signed [DATA_WIDTH-1:0] in_q;
    reg input_strobe;
    wire signed [15:0] phase;
    wire output_strobe;

    // Instantiate the phase module
    phase #(
        .DATA_WIDTH(DATA_WIDTH)
    ) uut (
        .clock(clock),
        .reset(reset),
        .enable(enable),
        .in_i(in_i),
        .in_q(in_q),
        .input_strobe(input_strobe),
        .phase(phase),
        .output_strobe(output_strobe)
    );

    wire 	vec_valid;
    wire [31:0]	x_vec;
    wire [31:0]	y_vec;
    wire [31:0]	phase_vec;

    cordic #(
        .XY_BITS      		( 32       		),
        .PH_BITS      		( 32       		),
        .ITERATIONS   		( 32       		),
        .STYLE       		( "VECTOR" 		),
        .CALMODE    		( "SPRECISION"  ))
    u_cordic_vec(
        //ports
        .clock     		( clock     		),
        .reset     		( reset     		),
        .ivalid    		( input_strobe    	),
        .x_i       		( in_i       		),
        .y_i       		( in_q       		),
        .z_i    		( 0           		),
        .ovalid    		( vec_valid    		),
        .x_o       		( x_vec       		),
        .y_o       		( y_vec       		),
        .z_o     		( phase_vec 		)
    );

    reg signed [31 : 0] iphase = 0;
    always @(posedge clock) begin
        if (enable) begin
            iphase <= iphase + 32'sd34456666;
        end
        else begin
            iphase <= 0;
        end
    end

    wire 	rot_valid;
    wire [31:0]	x_rot;
    wire [31:0]	y_rot;
    wire [31:0]	phase_rot;
    
    cordic #(
        .XY_BITS      		( 32       		),
        .PH_BITS      		( 32       		),
        .ITERATIONS   		( 16       		),
        .STYLE       		( "ROTATE" 	    ),
        .CALMODE    		( "SPRECISION"  ))
    u_cordic_rot(
        //ports
        .clock     		( clock     		),
        .reset     		( reset     		),
        .ivalid    		( enable        	),
        .x_i       		( 32'b0111_1111_1111_1111_1111_1111_1111_1111 ),
        .y_i       		( 32'b0111_1111_1111_1111_1111_1111_1111_1111 ),
        .z_i    		( 32'b0001_1111_1111_1111_1111_1111_1111_1111 ),
        .ovalid    		( rot_valid    		),
        .x_o       		( x_rot       		),
        .y_o       		( y_rot       		),
        .z_o     		( phase_rot 		)
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
        #20;
        reset = 0;

        // Enable the module
        enable = 1;

        // Test case 1: in_i = 1, in_q = 0 (0 degrees)
        in_i = 32'b0111_1111_1111_1111_1111_1111_1111_1111;
        in_q = 32'b0111_1111_1111_1111_1111_1111_1111_1111;
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
        $dumpfile("cordic.vcd");        
        $dumpvars(0, cordic_tb);   
    end

endmodule
