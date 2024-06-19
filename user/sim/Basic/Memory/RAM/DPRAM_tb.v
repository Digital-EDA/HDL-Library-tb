`timescale 1ns / 1ps

module tb_DPRAM;

    // Parameters
    parameter WIDTH = 32;
    parameter DEPTH = 4;

    // Inputs
    reg clka;
    reg ena;
    reg wea;
    reg [$clog2(DEPTH)-1:0] addra;
    reg [WIDTH-1:0] dina;
    reg clkb;
    reg enb;
    reg web;
    reg [$clog2(DEPTH)-1:0] addrb;
    reg [WIDTH-1:0] dinb;

    // Outputs
    wire [WIDTH-1:0] douta;
    wire [WIDTH-1:0] doutb;

    // Instantiate the DUT (Device Under Test)
    DPRAM #(
        .WIDTH(WIDTH),
        .DEPTH(DEPTH)) 
    dut (
        .clka(clka),
        .ena(ena),
        .wea(wea),
        .addra(addra),
        .dina(dina),
        .douta(douta),
        .clkb(clkb),
        .enb(enb),
        .web(web),
        .addrb(addrb),
        .dinb(dinb),
        .doutb(doutb)
    );

    // Clock generation
    initial begin
        clka = 0;
        forever #5 clka = ~clka; // 10 ns clock period
    end

    initial begin
        clkb = 0;
        forever #5 clkb = ~clkb; // 10 ns clock period
    end

    // Test sequence
    initial begin
        // Initialize inputs
        ena = 0;
        wea = 0;
        addra = 0;
        dina = 0;
        enb = 0;
        web = 0;
        addrb = 0;
        dinb = 0;

        // Apply reset
        #10;

        // Write to port A
        ena = 1;
        wea = 1;
        addra = 0;
        dina = 32'hA5A5A5A5;
        #10;
        
        addra = 1;
        dina = 32'h5A5A5A5A;
        #10;

        wea = 0; // Stop writing

        // Read from port A
        #10;
        addra = 0;
        #10;
        addra = 1;
        #10;

        ena = 0; // Disable port A

        // Write to port B
        enb = 1;
        web = 1;
        addrb = 2;
        dinb = 32'h12345678;
        #10;
        
        addrb = 3;
        dinb = 32'h87654321;
        #10;

        web = 0; // Stop writing

        // Read from port B
        #10;
        addrb = 2;
        #10;
        addrb = 3;
        #10;

        enb = 0; // Disable port B

        // End simulation
        #20;
        $finish;
    end

    // Monitor outputs
    initial begin
        $monitor("Time: %0t | clka: %b | ena: %b | wea: %b | addra: %0d | dina: %h | douta: %h | clkb: %b | enb: %b | web: %b | addrb: %0d | dinb: %h | doutb: %h",
                 $time, clka, ena, wea, addra, dina, douta, clkb, enb, web, addrb, dinb, doutb);
    end

endmodule
