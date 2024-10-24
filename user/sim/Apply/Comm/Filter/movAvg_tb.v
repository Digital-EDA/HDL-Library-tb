`timescale 1ns / 1ps

module movAvg_tb;

    // Parameters
    parameter DATA_WIDTH = 32;
    parameter WINDOW_SHIFT = 2;
    parameter WINDOW_SIZE = 1 << WINDOW_SHIFT;
    parameter SIGNED = 0;

    // Inputs
    reg clock;
    reg enable;
    reg reset;
    reg signed [DATA_WIDTH-1:0] data_in;
    reg input_valid;

    wire signed [DATA_WIDTH-1:0] odata;
    wire ovalid;
    movAvg #(
        .WIDTH(DATA_WIDTH),
        .WINDOW(1<<WINDOW_SHIFT)) 
    u_movAvg (
        .clock(clock),
        .reset(reset),
        .idata(data_in),
        .ivalid(input_valid),
        .odata(odata),
        .ovalid(ovalid)
    );

    // Clock generation
    initial begin
        clock = 0;
        forever #5 clock = ~clock; // 10 ns clock period
    end

    // Test sequence
    initial begin
        // Initialize inputs
        reset = 1;
        enable = 0;
        data_in = 0;
        input_valid = 0;

        // Apply reset
        #20;
        reset = 0;
        enable = 1;

        // Provide input values and valid signals
        // Test sequence: 16 inputs to fill the window and then some more

        repeat(2) begin
            // Fill the window
            input_data(32'h00000001); // input 1
            input_data(32'h00000002); // input 2
            input_data(32'h00000003); // input 3
            input_data(32'h00000004); // input 4
            input_data(32'h00000005); // input 5
            input_data(32'h00000006); // input 6
            input_data(32'h00000007); // input 7
            input_data(32'h00000008); // input 8
            input_data(32'h00000009); // input 9
            input_data(32'h0000000A); // input 10
            input_data(32'h0000000B); // input 11
            input_data(32'h0000000C); // input 12
            input_data(32'h0000000D); // input 13
            input_data(32'h0000000E); // input 14
            input_data(32'h0000000F); // input 15
            input_data(32'h00000010); // input 16
        end

        // Additional inputs to observe the sliding window behavior
        input_data(32'h00000020); // input 32
        input_data(32'h00000030); // input 48
        input_data(32'h00000040); // input 64
        input_data(32'h00000050); // input 80
        input_data(32'h00000060); // input 96

        // Finish the simulation
        #100;
        $finish;
    end

    // Task to provide input data
    task input_data;
        input [DATA_WIDTH-1:0] data;
        begin
            @(posedge clock);
            data_in = data;
            input_valid = 1;
            @(posedge clock);
            input_valid = 0;
        end
    endtask

    // Monitor the outputs
    initial begin
        $dumpfile("movAvg.vcd");        
        $dumpvars(0, movAvg_tb);
    end

endmodule
