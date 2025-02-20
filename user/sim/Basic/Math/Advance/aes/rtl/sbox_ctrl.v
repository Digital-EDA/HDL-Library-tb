module sbox_ctrl(
        input   [127:0] sbox_in,
        input               mode,
        output  [127:0] sbox_out,
        //mul_ctl
        output [63:0] mul1_d1,
        output [63:0] mul1_d2,
        output [63:0] mul2_d1,
        output [63:0] mul2_d2,
        output [63:0] mul3_d1,
        output [63:0] mul3_d2,
        input  [63:0] mul1_out,
        input  [63:0] mul2_out,
        input  [63:0] mul3_out,
        output [63:0] mulB_in,
        input  [63:0] mulB_out,


        //gf_convert/
        output [127:0] gf256To16_in,
        input  [127:0] gf256To16_out,
        output [127:0] gf16To256_in,
        input  [127:0] gf16To256_out
    );



    genvar i;
    generate
        for(i = 0; i < 16; i = i + 1)  begin:sbox
            s_box s_box_inst (
                      .sbox_mul1_d1             (mul1_d1[(i*4)+:4]             ) ,//output  [3:0]
                      .sbox_mul1_d2             (mul1_d2[(i*4)+:4]             ) ,//output  [3:0]
                      .sbox_mul2_d1             (mul2_d1[(i*4)+:4]             ) ,//output  [3:0]
                      .sbox_mul2_d2             (mul2_d2[(i*4)+:4]             ) ,//output  [3:0]
                      .sbox_mul3_d1             (mul3_d1[(i*4)+:4]             ) ,//output  [3:0]
                      .sbox_mul3_d2             (mul3_d2[(i*4)+:4]             ) ,//output  [3:0]
                      .sbox_mul1_out            (mul1_out[(i*4)+:4]            ) ,//input   [3:0]
                      .sbox_mul2_out            (mul2_out[(i*4)+:4]            ) ,//input   [3:0]
                      .sbox_mul3_out            (mul3_out[(i*4)+:4]            ) ,//input   [3:0]
                      .sbox_mulB_d1             (mulB_in[(i*4)+:4]             ) ,//output  [3:0]
                      .sbox_mulB_out            (mulB_out[(i*4)+:4]            ) ,//input   [3:0]
                      .din                      (sbox_in[(i*8)+:8]             ) ,//input   [7:0]
                      .sbox_gf256To16_data_in   (gf256To16_in[(i*8)+:8]   ) ,//output  [7:0]
                      .sbox_gf256To16_data_out  (gf256To16_out[(i*8)+:8]  ) ,//input   [7:0]
                      .sbox_gf16To256_data_in   (gf16To256_in[(i*8)+:8]   ) ,//output  [7:0]
                      .sbox_gf16To256_data_out  (gf16To256_out[(i*8)+:8]  ) ,//input   [7:0]
                      .mode                     (mode                            ) ,//input
                      .dout                     (sbox_out[(i*8)+:8]            ));//output  [7:0]
        end
    endgenerate

endmodule
