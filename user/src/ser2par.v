module ser2par #(
        parameter LENGTH = 8
    ) (
        input clock,
        input enable,
        input reset,
        input direct,

        input ivalid,
        input idata,

        output reg              ovalid,
        output reg [LENGTH-1:0] odata
    );

    reg [LENGTH-1:0]            data_buf;
    reg [$clog2(LENGTH)-1:0]    cnt;

    always @(posedge clock or posedge reset) begin
        if (reset) begin
            cnt <= 0;
            data_buf <= 0;
            odata <= 0;
            ovalid <= 0;
        end 
        else if (enable & ivalid) begin
            data_buf[LENGTH-1] <= idata;
            data_buf[LENGTH-2:0] <= data_buf[LENGTH-1:1];
            cnt <= cnt + 1;
            if (cnt == LENGTH-1) begin
                if (direct == 0) begin
                    odata <= {idata, data_buf[LENGTH-1:1]};
                end
                else begin
                    odata <= {data_buf[LENGTH-1:1], idata};
                end
                ovalid <= 1;
            end 
            else begin
                ovalid <= 0;
            end
        end 
        else begin
            ovalid <= 0;
        end
    end
endmodule
