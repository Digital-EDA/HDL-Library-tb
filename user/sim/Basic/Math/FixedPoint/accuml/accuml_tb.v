`timescale 1ns/1ps

module accuml_tb;

    parameter WIDTH = 16;

    // Testbench signals
    reg clock;
    reg reset;
    reg clr;
    reg add_sub;
    reg [WIDTH-1:0] D;
    wire [WIDTH:0] Q;

    // Instantiate the accuml module
    accuml #(
        .WIDTH(WIDTH)
    ) uut (
        .clock(clock),
        .reset(reset),
        .clr(clr),
        .add_sub(add_sub),
        .D(D),
        .Q(Q)
    );

    reg [WIDTH-1:0] phase = 0;
    always @(posedge clock) begin
        phase <= phase + 16'd10000;
    end

    // Clock generation
    always #5 clock = ~clock;

    // Testbench stimulus
    initial begin
        // Initialize signals
        clock = 0;
        reset = 1;
        clr = 0;
        add_sub = 0;
        D = 0;

        // Apply reset
        #20;
        reset = 0;

        // Test case 1: Clear and add operation
        clr = 1;
        D = 16'd10000;
        add_sub = 0; // Add operation
        #10;
        clr = 0;
        #10;
    end

    initial begin
        $dumpfile("accuml.vcd");        
        $dumpvars(0, accuml_tb);   
    end

endmodule
