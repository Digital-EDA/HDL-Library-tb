//////////////////////////////////////////////////////////////////////
////                                                              ////
////  Sub Bytes Box file                                          ////
////                                                              ////
////  Description:                                                ////
////  Implement sub byte box look up table                        ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
module s_box(
        din,
        mode,
        dout,
        // gf interface
        // sbox_gf_convert_req,
        sbox_gf16To256_data_in,
        sbox_gf16To256_data_out,
        // sbox_gf_data_mode,
        sbox_gf256To16_data_in,
        sbox_gf256To16_data_out,

        //mul interface
        // sbox_mul_req,
        sbox_mul1_d1,
        sbox_mul1_d2,
        sbox_mul1_out,
        sbox_mul2_d1,
        sbox_mul2_d2,
        sbox_mul2_out,
        sbox_mul3_d1,
        sbox_mul3_d2,
        sbox_mul3_out,
        sbox_mulB_d1,
        sbox_mulB_out

    );

    output [3:0] sbox_mul1_d1;
    output [3:0] sbox_mul1_d2;
    output [3:0] sbox_mul2_d1;
    output [3:0] sbox_mul2_d2;
    output [3:0] sbox_mul3_d1;
    output [3:0] sbox_mul3_d2;
    input [3:0] sbox_mul1_out;
    input [3:0] sbox_mul2_out;
    input [3:0] sbox_mul3_out;
    output [3:0] sbox_mulB_d1;
    input  [3:0] sbox_mulB_out;
    input	[7:0]	din;


    // output sbox_gf_convert_req;
    output [7:0] sbox_gf256To16_data_in;
    input [7:0] sbox_gf256To16_data_out;
    output [7:0] sbox_gf16To256_data_in;
    input [7:0] sbox_gf16To256_data_out;
    // output sbox_gf_data_mode;

    input		mode;  //0: encryption;  1: decryption
    output	[7:0]	dout;

    wire [7:0] first_matrix_out,first_matrix_in,last_matrix_out_enc,last_matrix_out_dec;
    wire [3:0] p,q,p2,q2,sumpq,sump2q2,inv_sump2q2,p_new,q_new,mulpq,q2B;

    // GF(256) to GF(16) transformation
    wire [7:0] INV_AFFINE_din;
    wire [7:0] GF256_TO_GF16_fmin;
    inv_affine INV_AFFINE_inst(.data(din[7:0]),.inv_affine(INV_AFFINE_din));
    // gf256_to_gf16 GF256_TO_GF16_inst(.data(first_matrix_in[7:0]),.gf256_to_gf16(GF256_TO_GF16_fmin));
    assign first_matrix_in[7:0] = mode ? INV_AFFINE_din: din[7:0];
    // assign first_matrix_out[7:0] = GF256_TO_GF16_fmin;
    assign first_matrix_out[7:0] = sbox_gf256To16_data_out;


    assign sbox_gf256To16_data_in =  first_matrix_in;
    /*****************************************************************************/
    // GF16 inverse logic
    /*****************************************************************************/
    //                     p+q _____
    //                              \
    //  p --> p2 ___                 \
    //   \          \                 x --> p_new
    //    x -> p*q -- + --> inverse -/
    //   /          /                \
    //  q --> q2*B-/                  x --> q_new
    //   \___________________________/
    //
    assign p[3:0] = first_matrix_out[3:0];
    assign q[3:0] = first_matrix_out[7:4];

    wire [3:0] SQUARE_p,SQUARE_q;
    square SQUARE_inst1(.data(p[3:0]),.square(SQUARE_p));
    square SQUARE_inst2(.data(q[3:0]),.square(SQUARE_q));
    assign p2[3:0] = SQUARE_p;
    assign q2[3:0] = SQUARE_q;
    //p+q
    assign sumpq[3:0] = p[3:0] ^ q[3:0];
    //p*q
    // wire [3:0] MUL_pq;
    // mul_core MUL_inst(.d1(p[3:0]),.d2(q[3:0]),.mul_core(MUL_pq));
    assign sbox_mul1_d1 = p[3:0];
    assign sbox_mul1_d2 = q[3:0];
    // assign mulpq[3:0] = MUL_pq;
    assign mulpq[3:0] = sbox_mul1_out;
    //q2B calculation
    assign sbox_mulB_d1 = q2;
    assign q2B = sbox_mulB_out;
    // assign q2B[0]=q2[1]^q2[2]^q2[3];
    // assign q2B[1]=q2[0]^q2[1];
    // assign q2B[2]=q2[0]^q2[1]^q2[2];
    // assign q2B[3]=q2[0]^q2[1]^q2[2]^q2[3];
    //p2+p*q+q2B
    assign sump2q2[3:0] = q2B[3:0] ^ mulpq[3:0] ^ p2[3:0];
    // inverse p2+pq+q2B
    wire [3:0] INVERSE_sump2q2;
    inverse INVERSE_inst(.data(sump2q2[3:0]),.inverse(INVERSE_sump2q2));
    assign inv_sump2q2[3:0] = INVERSE_sump2q2;
    // results
    wire [3:0] MUL_p_new,MUL_q_new;
    // mul_core MUL_inst1(.d1(sumpq[3:0]),.d2(inv_sump2q2[3:0]),.mul_core(MUL_p_new));
    assign sbox_mul2_d1 = sumpq;
    assign sbox_mul2_d2 = inv_sump2q2;
    assign MUL_p_new = sbox_mul2_out;
    // mul_core MUL_inst2(.d1(q[3:0]),.d2(inv_sump2q2[3:0]),.mul_core(MUL_q_new));
    assign sbox_mul3_d1 = q;
    assign sbox_mul3_d2 = inv_sump2q2;
    assign MUL_q_new = sbox_mul3_out;
    assign p_new[3:0] = MUL_p_new;
    assign q_new[3:0] = MUL_q_new;


    // GF(16) to GF(256) transformation
    wire [7:0] GF16_TO_GF256_pq;
    // gf16_to_gf256 GF16_TO_GF256_inst(.p(p_new[3:0]),.q(q_new[3:0]),.gf16_to_gf256(GF16_TO_GF256_pq));
    assign sbox_gf16To256_data_in =  {q_new,p_new};
    assign GF16_TO_GF256_pq = sbox_gf16To256_data_out;
    wire [7:0] AFFINE_lmod;
    affine AFFINE_inst(.data(last_matrix_out_dec[7:0]),.affine(AFFINE_lmod));
    assign last_matrix_out_dec[7:0] = GF16_TO_GF256_pq;
    assign last_matrix_out_enc[7:0] = AFFINE_lmod;
    assign dout[7:0] = mode ? last_matrix_out_dec[7:0] : last_matrix_out_enc;

endmodule
/*****************************************************************************/
// Functions
/*****************************************************************************/

// convert GF(256) to GF(16)


// squre


// inverse


// multiply


// GF16 to GF256 transform


// affine transformation


