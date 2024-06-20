`timescale 1 ps / 1 ps
/*
* @state: finish-test
* @description: 
*/
module cmplMult #(
        parameter    SCALE_FACTOR = 1,
        parameter    REAL_WIDTH_A = 12,
        parameter    IMGN_WIDTH_A = 12,

        parameter    REAL_WIDTH_B = 12,
        parameter    IMGN_WIDTH_B = 12,

        parameter    REAL_WIDTH_O = 12,
        parameter    IMGN_WIDTH_O = 12
    ) (
        input  clock,
        input  reset,

        input                            ivalid,
        input signed [REAL_WIDTH_A-1:0]  dataa_r,
        input signed [IMGN_WIDTH_A-1:0]  dataa_i,
    
        input signed [REAL_WIDTH_B-1:0]  datab_r,
        input signed [IMGN_WIDTH_B-1:0]  datab_i,
        
        output                           ovalid,   
        output signed [REAL_WIDTH_O-1:0] result_r,
        output signed [IMGN_WIDTH_O-1:0] result_i
    );

    localparam AB_RR_WIDTH = REAL_WIDTH_A + REAL_WIDTH_B;
    localparam AB_II_WIDTH = IMGN_WIDTH_A + IMGN_WIDTH_B;
    localparam AB_RI_WIDTH = REAL_WIDTH_A + IMGN_WIDTH_B;
    localparam AB_IR_WIDTH = IMGN_WIDTH_A + REAL_WIDTH_B;

    localparam REAL_WIDTH = AB_RR_WIDTH > AB_II_WIDTH ? 
                            AB_RR_WIDTH : AB_II_WIDTH;
    localparam IMGN_WIDTH = AB_RI_WIDTH > AB_IR_WIDTH ? 
                            AB_RI_WIDTH : AB_IR_WIDTH;      

    localparam END_INDEX_R = REAL_WIDTH - REAL_WIDTH_O + 1;
    localparam END_INDEX_I = IMGN_WIDTH - IMGN_WIDTH_O + 1;

    reg signed [REAL_WIDTH:0]    outr;
    reg signed [IMGN_WIDTH:0]    outi;
    reg signed [AB_RR_WIDTH-1:0] ab_rr;
    reg signed [AB_II_WIDTH-1:0] ab_ii;
    reg signed [AB_RI_WIDTH-1:0] ab_ri;
    reg signed [AB_IR_WIDTH-1:0] ab_ir;

    always @(posedge clock or posedge reset) begin
        if(reset) begin
            ab_rr <= 0;
            ab_ii <= 0;
            ab_ri <= 0;
            ab_ir <= 0;

            outr <= 0;
            outi <= 0;
        end
        else begin
            if (ivalid) begin                
                ab_rr <= dataa_r * datab_r;
                ab_ii <= dataa_i * datab_i;
                ab_ri <= dataa_r * datab_i;
                ab_ir <= dataa_i * datab_r;

                outr <= ab_rr - ab_ii;
                outi <= ab_ri + ab_ir;
            end
        end
    end

    reg [3:0] ovalid_buf;

    always @(posedge clock or posedge reset) begin
        if (reset) begin
            ovalid_buf <= 0;
        end 
        else begin    
            ovalid_buf <= {ovalid_buf[2:0], ivalid};
        end
    end
    assign ovalid = ovalid_buf[3];

    assign result_r = outr[REAL_WIDTH - SCALE_FACTOR : END_INDEX_R - SCALE_FACTOR];
    assign result_i = outi[IMGN_WIDTH - SCALE_FACTOR : END_INDEX_I - SCALE_FACTOR];

endmodule
