module modulus #(
        parameter WIDTH = 16
    ) (
        input clock,
        input reset,

        input ivalid,
        input signed [WIDTH-1:0] i,
        input signed [WIDTH-1:0] q,

        output                   ovalid,
        output reg [WIDTH-1:0]   modulus
    );

    reg [WIDTH-1:0] abs_i;
    reg [WIDTH-1:0] abs_q;

    reg [WIDTH-1:0] max;
    reg[ WIDTH-1:0] min;

    // delay #(
    //     .WIDTH(1), 
    //     .DELAY(3)) 
    // stb_delay_inst (
    //     .clock(clock),
    //     .reset(reset),

    //     .idata(ivalid),
    //     .odata(ovalid)
    // );

    reg [2:0] ovalid_buf;

    always @(posedge clock or posedge reset) begin
        if (reset) begin
            ovalid_buf <= 0;
        end 
        else begin    
            ovalid_buf <= {ovalid_buf[1:0], ivalid};
        end
    end
    assign ovalid = ovalid_buf[2];

    // http://dspguru.com/dsp/tricks/magnitude-estimator
    // alpha = 1, beta = 1/4
    // avg err 0.006
    always @(posedge clock or posedge reset) begin
        if (reset) begin
            modulus <= 0;
            abs_i <= 0;
            abs_q <= 0;
            max <= 0;
            min <= 0;
        end 
        else if (ivalid) begin
            abs_i <= i[WIDTH-1] ? (~i+1) : i;
            abs_q <= q[WIDTH-1] ? (~q+1) : q;

        end
        max <= (abs_i > abs_q) ? abs_i : abs_q;
        min <= (abs_i > abs_q) ? abs_q : abs_i;

        modulus <= max + (min>>2);
    end

endmodule
