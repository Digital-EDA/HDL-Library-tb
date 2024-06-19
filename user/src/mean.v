module mean (
        input  clock,
        input  reset,
        input  sign,
 
        input                ivalid,
        input  signed [15:0] A,
        input  signed [15:0] B,

        output               ovalid,
        output signed [15:0] C
    );

    reg signed [16:0] sum;
    reg signed [15:0] res;
    reg signed [15:0] cc;

    reg [1:0] sign_buf;
    reg [2:0] ovalid_buf;

    always @(posedge clock or posedge reset) begin
        if (reset) begin
            sign_buf <= 0;
            ovalid_buf <= 0;
        end 
        else begin    
            sign_buf <= {sign_buf[0], sign};
            ovalid_buf <= {ovalid_buf[1:0], ivalid};
        end
    end

    always @(posedge clock or posedge reset) begin
        if (reset) begin
            sum <= 0;
            res <= 0;
            cc <= 0;
        end 
        else if (ivalid) begin
            sum <= A + B;
            res <= sum >>> 1;
            cc <= sign_buf[1] ? ~res+1 : res;
        end
    end

    assign ovalid = ovalid_buf[2];
    assign C = cc;

endmodule

