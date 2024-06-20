module delay #(
        parameter WIDTH = 32,
        parameter DELAY = 1
    )(
        input clock,
        input reset,

        input  [WIDTH-1:0] idata,
        output [WIDTH-1:0] odata
    );

    reg [WIDTH-1:0] ram[DELAY-1:0];
    integer i;

    assign odata = ram[DELAY-1];

    always @(posedge clock) begin
        if (reset) begin
            for (i = 0; i < DELAY; i = i+1) begin
                ram[i] <= 0;
            end
        end else begin
            ram[0] <= idata;
            for (i = 1; i < DELAY; i= i+1) begin
                ram[i] <= ram[i-1];
            end
        end
    end

endmodule
