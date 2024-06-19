
module DPRAM #(
        parameter WIDTH = 32,
        parameter DEPTH = 4
    ) (
        input                       clka,
        input                       ena,
        input                       wea,
        input [$clog2(DEPTH)-1:0]   addra,
        input [WIDTH-1:0]           dina,
        output reg [WIDTH-1:0]      douta,

        input                       clkb,
        input                       enb,
        input                       web,
        input [$clog2(DEPTH)-1:0]   addrb,
        input [WIDTH-1:0]           dinb,
        output reg [WIDTH-1:0]      doutb
    );

    reg [WIDTH - 1 : 0] ram [DEPTH - 1 : 0];
    integer i;
    initial begin
        for(i=0;i<DEPTH;i=i+1)
            ram[i] <= 0;
        douta <= 0;
        doutb <= 0;
    end

    always @(posedge clka) begin
        if (ena) begin
            if (wea) begin
                ram[addra] <= dina;
            end
            douta <= ram[addra];
        end
        else begin
            ram[addra] <= ram[addra];
            douta <= douta;
        end
    end

    always @(posedge clkb) begin
        if (enb) begin
            if (web) begin
                ram[addrb] <= dinb;
            end
            doutb <= ram[addrb];
        end
        else begin
            ram[addrb] <= ram[addrb];
            doutb <= doutb;
        end
    end
    
endmodule
