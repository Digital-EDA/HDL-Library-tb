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

    reg [31:0] RAM_CNT;
    reg [WIDTH - 1 : 0] ram_buf;
    reg [WIDTH - 1 : 0] shift_buf;
    reg [WIDTH - 1 : 0] shift_ram [SHIFT - 1 : 0];

    reg [SHIFT:0] ovalid_buf;

    always @(posedge clock or posedge reset) begin
        if (reset) begin
            ovalid_buf <= 0;
        end 
        else begin    
            ovalid_buf <= {ovalid_buf[SHIFT-1:0], ivalid};
        end
    end

    always @(posedge clock or posedge reset) begin
        if (reset) begin
            RAM_CNT <= 0;
        end
        else begin            
            if (RAM_CNT == (SHIFT - 1)) begin
                RAM_CNT <= 0;
            end
            else if (ivalid) begin
                RAM_CNT <= RAM_CNT + 1;
            end
            else begin
                RAM_CNT <= RAM_CNT;
            end
        end
    end

    integer i;
    always @(posedge clock or posedge reset) begin
        if (reset) begin
            for (i = 0; i < SHIFT; i = i+1) begin
                shift_ram[i] <= 0;
            end
            shift_buf <= 0;
        end
        else begin            
            if (ivalid) begin
                shift_ram[RAM_CNT] <= shiftin;
                shift_buf <= shift_ram[RAM_CNT];
            end  
            else begin
                shift_ram[RAM_CNT] <= shift_ram[RAM_CNT];
                shift_buf <= shift_buf;
            end
        end
    end

    assign ovalid = ovalid_buf[SHIFT];
    assign shiftout = shift_buf;

endmodule

