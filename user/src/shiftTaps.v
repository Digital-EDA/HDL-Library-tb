`timescale 1 ns / 1 ns

module shiftTaps #(
        parameter WIDTH = 8,
        parameter SHIFT = 640
    ) (
        input                   clock,
        input                   reset,

        input                   ivalid, 
        input  [WIDTH - 1 : 0]  shiftin,

        output                  ovalid, 
        output [WIDTH - 1 : 0]  shiftout
    );

    reg                     done;
    reg                     valid;
    reg [$clog2(SHIFT)-1:0] count;

    reg [WIDTH-1:0] ram [SHIFT-1:0];
    reg [WIDTH-1:0] odata;

    always @(posedge clock or posedge reset) begin
        if (ivalid) begin
            ram[count] <= shiftin;
            odata <= ram[count];
        end
    end

    integer i;
    always @(posedge clock or posedge reset) begin
        if (reset) begin
            count <= 0;
            done <= 0;
            odata <= 0;
            valid <= 0;

            for (i = 0; i < SHIFT; i = i+1) begin
                ram[i] <= 0;
            end
        end 
        else begin            
            if (ivalid) begin
                count <= count + 1;
                if (count == (SHIFT-1)) begin
                    done <= 1;
                end
                valid <= done;
            end 
            else begin
                valid <= 0;
            end
        end
    end

    assign ovalid = valid;
    assign shiftout = odata;

endmodule

