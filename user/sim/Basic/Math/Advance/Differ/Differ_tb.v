`timescale 1ns/1ps

module Differ_tb;

    parameter WIDTH = 12;

    // Testbench signals
    reg clock;
    reg reset;
    reg ivalid;
    reg signed [WIDTH-1:0] idata;
    wire ovalid;
    wire signed [WIDTH-1:0] odata;

    // Instantiate the Differ module
    Differ #(
        .WIDTH(WIDTH)
    ) uut (
        .clock(clock),
        .reset(reset),
        .ivalid(ivalid),
        .idata(idata),
        .ovalid(ovalid),
        .odata(odata)
    );

    // Clock generation
    always #5 clock = ~clock;

    // Testbench stimulus
    initial begin
        // Initialize signals
        clock = 0;
        reset = 0;
        ivalid = 0;
        idata = 0;

        // Apply reset
        #10;
        reset = 1;
        #10;
        reset = 0;

        // Test case 1: Simple difference
        idata = 12'sd5;
        ivalid = 1;
        #10;
        ivalid = 0;
        #10;
        
        // Wait for ovalid
        #20;
        $display("Test case 1: odata = %d, expected = 0", odata);

        // Test case 2: Incremental data
        idata = 12'sd10;
        ivalid = 1;
        #10;
        ivalid = 0;
        #10;
        
        // Wait for ovalid
        #20;
        $display("Test case 2: odata = %d, expected = 5", odata);

        // Test case 3: Decremental data
        idata = 12'sd7;
        ivalid = 1;
        #10;
        ivalid = 0;
        #10;
        
        // Wait for ovalid
        #20;
        $display("Test case 3: odata = %d, expected = -3", odata);

        // Test case 4: Zero input
        idata = 12'sd0;
        ivalid = 1;
        #10;
        ivalid = 0;
        #10;
        
        // Wait for ovalid
        #20;
        $display("Test case 4: odata = %d, expected = -7", odata);

        // Test case 5: Negative input
        idata = -12'sd3;
        ivalid = 1;
        #10;
        ivalid = 0;
        #10;
        
        // Wait for ovalid
        #20;
        $display("Test case 5: odata = %d, expected = -3", odata);

        // End simulation
        $finish;
    end

    initial begin
        $dumpfile("Differ.vcd");        
        $dumpvars(0, Differ_tb);   
    end

endmodule
