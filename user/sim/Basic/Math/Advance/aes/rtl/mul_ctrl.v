module mul_ctrl(
        input   [63:0] mul1_d1,
        input   [63:0] mul1_d2,
        input   [63:0] mul2_d1,
        input   [63:0] mul2_d2,
        input   [63:0] mul3_d1,
        input   [63:0] mul3_d2,
        output  [63:0] mul1_out,
        output  [63:0] mul2_out,
        output  [63:0] mul3_out,
        input   [63:0] mulB_in,
        output  [63:0] mulB_out
    );


    genvar i;
    generate
        for (i = 0; i < 16; i = i + 1) begin:mul
            mul mul_inst (
                    // .sbox_mul_req   () ,//input   [3:0]
                    .sbox_mul1_d1   (mul1_d1[(i*4)+:4]   ) ,//input   [3:0]
                    .sbox_mul1_d2   (mul1_d2[(i*4)+:4]   ) ,//input   [3:0]
                    .sbox_mul1_out  (mul1_out[(i*4)+:4]  ) ,//output  [3:0]
                    .sbox_mul2_d1   (mul2_d1[(i*4)+:4]   ) ,//input   [3:0]
                    .sbox_mul2_d2   (mul2_d2[(i*4)+:4]   ) ,//input   [3:0]
                    .sbox_mul2_out  (mul2_out[(i*4)+:4]  ) ,//output  [3:0]
                    .sbox_mul3_d1   (mul3_d1[(i*4)+:4]   ) ,//input   [3:0]
                    .sbox_mul3_d2   (mul3_d2[(i*4)+:4]   ) ,//input   [3:0]
                    .sbox_mul3_out  (mul3_out[(i*4)+:4]  ) ,//output  [3:0]
                    .sbox_mulB_d1   (mulB_in[(i*4)+:4]   ) ,//input   [3:0]
                    .sbox_mulB_out  (mulB_out[(i*4)+:4]  ));//output  [3:0]
        end
    endgenerate
endmodule
