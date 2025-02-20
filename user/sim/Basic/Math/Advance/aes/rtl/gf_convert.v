module gf_convert(
        input [7:0]     sbox_gf16To256_data_in,
        output [7:0]    sbox_gf16To256_data_out,
        // sbox_gf_data_mode,
        input [7:0]     sbox_gf256To16_data_in,
        output [7:0]    sbox_gf256To16_data_out
    );

    gf16_to_gf256 GF16_TO_GF256_inst (
                      .p              (sbox_gf16To256_data_in[3:0]) ,//input   [3:0]
                      .q              (sbox_gf16To256_data_in[7:4]) ,//input   [3:0]
                      .gf16_to_gf256  (sbox_gf16To256_data_out));//output  [7:0]
    gf256_to_gf16 GF256_TO_GF16_isnt (
                      .data           (sbox_gf256To16_data_in) ,//input   [7:0]
                      .gf256_to_gf16  (sbox_gf256To16_data_out));//output  [7:0]
endmodule
