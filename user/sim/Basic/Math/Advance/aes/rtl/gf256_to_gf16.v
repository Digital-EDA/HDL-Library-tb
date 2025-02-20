module gf256_to_gf16(
        input [7:0] data,
        output wire[7:0] gf256_to_gf16);
    wire a,b,c;

    assign	a = data[1]^data[7];
    assign	b = data[5]^data[7];
    assign	c = data[4]^data[6];
    assign	gf256_to_gf16[0] = c^data[0]^data[5];
    assign	gf256_to_gf16[1] = data[1]^data[2];
    assign	gf256_to_gf16[2] = a;
    assign	gf256_to_gf16[3] = data[2]^data[4];
    assign	gf256_to_gf16[4] = c^data[5];
    assign	gf256_to_gf16[5] = a^c;
    assign	gf256_to_gf16[6] = b^data[2]^data[3];
    assign	gf256_to_gf16[7] = b;

endmodule
