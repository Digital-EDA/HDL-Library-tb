module movingAvg #(
        parameter WIDTH = 32,
        parameter WINDOW = 4
    ) (
        input  clock,
        input  reset,

        input  ivalid,
        input  signed [WIDTH-1:0] idata,

        output ovalid,
        output signed [WIDTH-1:0] odata
    );

    localparam SUM_WIDTH = WIDTH + $clog2(WINDOW);

    reg                    done;
    reg signed [WIDTH-1:0] odata_buf;
    reg signed [(SUM_WIDTH-1):0] sum;

    wire 	                mvalid;
    wire signed [WIDTH-1:0] mdata;
    wire signed [SUM_WIDTH-1:0] ext_old_data = {{$clog2(WINDOW){mdata[WIDTH-1]}}, mdata};
    wire signed [SUM_WIDTH-1:0] ext_new_data = {{$clog2(WINDOW){idata[WIDTH-1]}}, idata};

    shiftTaps #(
        .WIDTH 		( WIDTH   	),
        .SHIFT 		( WINDOW 	))
    u_shiftTaps(
        //ports
        .clock    		( clock    		),
        .reset    		( reset    		),

        .ivalid   		( ivalid   		),
        .shiftin  		( idata  		),

        .ovalid   		( mvalid   		),
        .shiftout 		( mdata 		)
    );

    always @(posedge clock or posedge reset) begin
        if(reset) begin
            odata_buf <= 0;
            sum <= 0;
        end
        else begin
            if (ivalid) begin
                odata_buf <= sum[SUM_WIDTH-1:$clog2(WINDOW)];
                if (done) begin
                    sum <= sum + ext_new_data - ext_old_data;
                end else begin
                    sum <= sum + ext_new_data;
                end
            end
        end
    end

    always @(posedge clock or posedge reset) begin
        if(reset) begin
            done <= 1'b0;
        end
        else begin
            if (mvalid && (~done)) begin
                done <= 1'b1;
            end
            else begin
                done <= done;
            end
        end
    end

    assign odata = odata_buf;
    assign ovalid = mvalid;

endmodule
