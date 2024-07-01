`timescale 1ns/1ps

module Sort3_tb;

    // Testbench signals
    reg clock;
    reg reset;
    reg [7:0] data1;
    reg [7:0] data2;
    reg [7:0] data3;
    wire [7:0] max_data;
    wire [7:0] mid_data;
    wire [7:0] min_data;

    // Instantiate the Sort3 module
    Sort3 #(
        .WIDTH(8)
    ) uut (
        .clock(clock),
        .reset(reset),
        .data1(data1),
        .data2(data2),
        .data3(data3),
        .max_data(max_data),
        .mid_data(mid_data),
        .min_data(min_data)
    );

    // Clock generation
    always #5 clock = ~clock;

    // Testbench stimulus
    initial begin
        // Initialize signals
        clock = 0;
        reset = 0;
        data1 = 0;
        data2 = 0;
        data3 = 0;

        // Apply reset
        #15;
        reset = 1;
        #10;
        reset = 0;

        // Test case 1: Random values
        data1 = 8'd10;
        data2 = 8'd5;
        data3 = 8'd15;
        #10;
        $display("Test case 1: max_data = %d, mid_data = %d, min_data = %d, expected = 15, 10, 5", max_data, mid_data, min_data);

        // Test case 2: Values in order
        data1 = 8'd20;
        data2 = 8'd25;
        data3 = 8'd30;
        #10;
        $display("Test case 2: max_data = %d, mid_data = %d, min_data = %d, expected = 30, 25, 20", max_data, mid_data, min_data);

        // Test case 3: Values in reverse order
        data1 = 8'd35;
        data2 = 8'd30;
        data3 = 8'd25;
        #10;
        $display("Test case 3: max_data = %d, mid_data = %d, min_data = %d, expected = 35, 30, 25", max_data, mid_data, min_data);

        // Test case 4: All values are the same
        data1 = 8'd50;
        data2 = 8'd50;
        data3 = 8'd50;
        #10;
        $display("Test case 4: max_data = %d, mid_data = %d, min_data = %d, expected = 50, 50, 50", max_data, mid_data, min_data);

        // Test case 5: Two values are the same
        data1 = 8'd45;
        data2 = 8'd45;
        data3 = 8'd40;
        #10;
        $display("Test case 5: max_data = %d, mid_data = %d, min_data = %d, expected = 45, 45, 40", max_data, mid_data, min_data);

        // Test case 6: Edge case with minimum and maximum values
        data1 = 8'd0;
        data2 = 8'd255;
        data3 = 8'd128;
        #10;
        $display("Test case 6: max_data = %d, mid_data = %d, min_data = %d, expected = 255, 128, 0", max_data, mid_data, min_data);

        // End simulation
        $finish;
    end

    initial begin
        $dumpfile("Sort3.vcd");        
        $dumpvars(0, Sort3_tb);   
    end

endmodule
