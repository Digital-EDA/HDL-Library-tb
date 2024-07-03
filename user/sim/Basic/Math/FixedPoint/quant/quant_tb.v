`timescale 1ns/1ps

module quant_tb;

    // Testbench signals
    reg clock;
    reg reset;
    reg signed [17:0] idata;
    reg signed [15:0] scale;
    reg [3:0] shift;
    reg [7:0] zero_point;
    wire [7:0] odata;

    // Instantiate the quant module
    quant u0ut (
        .clock(clock),
        .reset(reset),
        .idata(idata),
        .scale(scale),
        .shift(shift),
        .zero_point(zero_point),
        .odata(odata)
    );

    wire [7:0] out;
    Quant u1ut (
        .clk(clock),
        .acc_result(idata),
        .scale(scale),
        .shift(shift),
        .zero_point(zero_point),
        .quant_result(out)
    );

    // Clock generation
    always #5 clock = ~clock;

    // Testbench stimulus
    initial begin
        // Initialize signals
        clock = 0;
        reset = 0;
        idata = 0;
        scale = 0;
        shift = 0;
        zero_point = 0;

        // Apply reset
        #10;
        reset = 1;
        #10;
        reset = 0;

        // Test case 1: Simple case
        idata = 18'sb0000_0000_0000_0001_00;
        scale = 16'sb0000_0000_0000_0010;
        shift = 4'b0010;
        zero_point = 8'b0000_0001;
        #20;
        $display("Test case 1: odata = %d", odata);

        // Test case 2: Overflow case
        idata = 18'sb0111_1111_1111_1111_11;
        scale = 16'sb0000_0000_0000_0100;
        shift = 4'b0011;
        zero_point = 8'b0000_0001;
        #20;
        $display("Test case 2: odata = %d", odata);

        // Test case 3: Negative input
        idata = 18'sb1111_1111_1111_1110_00;
        scale = 16'sb1111_1111_1111_1100;
        shift = 4'b0010;
        zero_point = 8'b0000_0001;
        #20;
        $display("Test case 3: odata = %d", odata);

        // Test case 4: Large scale
        idata = 18'sb0000_0000_0000_0001_00;
        scale = 16'sb1000_0000_0000_0000;
        shift = 4'b0001;
        zero_point = 8'b0000_0001;
        #20;
        $display("Test case 4: odata = %d", odata);

        // Test case 5: Zero point offset
        idata = 18'sb0000_0000_0000_0010_00;
        scale = 16'sb0000_0000_0000_0001;
        shift = 4'b0000;
        zero_point = 8'b0000_0100;
        #20;
        $display("Test case 5: odata = %d", odata);

        // End simulation
        $finish;
    end

endmodule
