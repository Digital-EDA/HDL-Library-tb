`timescale 1ns / 1ps

module DPRAM_tb;

    // Parameters
    parameter WIDTH = 8;
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

    wire [WIDTH-1:0]	doa;
    wire [WIDTH-1:0]	dob;

    ram_2port #(
        .DWIDTH 		( WIDTH 		),
        .AWIDTH 		( $clog2(DEPTH) ))
    u_ram_2port(
        //ports
        .clka  		( clka  		),
        .ena   		( ena   		),
        .wea   		( wea   		),
        .addra 		( addra 		),
        .dia   		( dina   		),
        .doa   		( doa   		),
        .clkb  		( clkb  		),
        .enb   		( enb   		),
        .web   		( web   		),
        .addrb 		( addrb 		),
        .dib   		( dinb   		),
        .dob   		( dob   		)
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
        #15;

        // Write to port A
        ena = 1;
        enb = 1;
        wea = 1;
        web = 1;
        addra = 0;
        addrb = 0;
        dina = 32'ha0;
        dinb = 32'hb0;
        #10;
        
        addra = 0;
        addrb = 0;
        dina = 32'ha1;
        dinb = 32'hb1;
        #10;

        wea = 0; // Stop writing
        web = 0;
        addra = 1;
        addrb = 1;

        // Read from port A
        #10;
        addra = 0;
        addrb = 0;
        #10;
        addra = 1;
        addrb = 1;
        #10;

        ena = 0; // Disable port A

        // Write to port B
        enb = 1;
        web = 1;
        addrb = 2;
        dinb = 32'h12;
        #10;
        
        addrb = 3;
        dinb = 32'h87;
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
        $dumpfile("DPRAM.vcd");        
        $dumpvars(0, DPRAM_tb);
        $monitor("Time: %0t | clka: %b | ena: %b | wea: %b | addra: %0d | dina: %h | douta: %h | clkb: %b | enb: %b | web: %b | addrb: %0d | dinb: %h | doutb: %h",
                 $time, clka, ena, wea, addra, dina, douta, clkb, enb, web, addrb, dinb, doutb);
    end

endmodule
