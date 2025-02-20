module gf_convert_ctrl(
        input  [127:0] gf256To16_in,
        output [127:0] gf256To16_out,
        input  [127:0] gf16To256_in,
        output [127:0] gf16To256_out
    );



    genvar i;
    generate
        for(i = 0; i < 16; i = i + 1) begin:gf_convert
            gf_convert GF_CONVERT_INST (
                           .sbox_gf16To256_data_in   (gf16To256_in[i*8+:8]     ) ,//input   [7:0]
                           .sbox_gf16To256_data_out  (gf16To256_out[i*8+:8]    ) ,//output  [7:0]
                           .sbox_gf256To16_data_in   (gf256To16_in[i*8+:8]     ) ,//input   [7:0]
                           .sbox_gf256To16_data_out  (gf256To16_out[i*8+:8]     ));//output  [7:0]
        end

    endgenerate
endmodule
