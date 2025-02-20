module mul(
        // input   [3:0]	sbox_mul_req,
        input   [3:0]   sbox_mul1_d1,
        input   [3:0]   sbox_mul1_d2,
        output  [3:0] sbox_mul1_out,
        input   [3:0]      sbox_mul2_d1,
        input[3:0] sbox_mul2_d2,
        output[3:0] sbox_mul2_out,
        input[3:0] sbox_mul3_d1,
        input[3:0] sbox_mul3_d2,
        output[3:0] sbox_mul3_out,
        input[3:0] sbox_mulB_d1,
        output[3:0] sbox_mulB_out
    );

    mul_core mul_inst0(
                 .d1(sbox_mul1_d1),
                 .d2(sbox_mul1_d2),
                 .mul_core(sbox_mul1_out));
    mul_core mul_inst1(
                 .d1(sbox_mul2_d1),
                 .d2(sbox_mul2_d2),
                 .mul_core(sbox_mul2_out));
    mul_core mul_inst2(
                 .d1(sbox_mul3_d1),
                 .d2(sbox_mul3_d2),
                 .mul_core(sbox_mul3_out));

    assign sbox_mulB_out[0]=sbox_mulB_d1[1]^sbox_mulB_d1[2]^sbox_mulB_d1[3];
    assign sbox_mulB_out[1]=sbox_mulB_d1[0]^sbox_mulB_d1[1];
    assign sbox_mulB_out[2]=sbox_mulB_d1[0]^sbox_mulB_d1[1]^sbox_mulB_d1[2];
    assign sbox_mulB_out[3]=sbox_mulB_d1[0]^sbox_mulB_d1[1]^sbox_mulB_d1[2]^sbox_mulB_d1[3];


endmodule
