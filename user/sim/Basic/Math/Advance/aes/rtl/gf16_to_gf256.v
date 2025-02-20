module gf16_to_gf256(
        input [3:0] p,
        input [3:0] q,
        output wire[7:0] gf16_to_gf256);
    wire a,b;

    assign	a=p[1]^q[3];
    assign	b=q[0]^q[1];

    assign	gf16_to_gf256[0]=p[0]^q[0];
    assign	gf16_to_gf256[1]=b^q[3];
    assign	gf16_to_gf256[2]=a^b;
    assign	gf16_to_gf256[3]=b^p[1]^q[2];
    assign	gf16_to_gf256[4]=a^b^p[3];
    assign	gf16_to_gf256[5]=b^p[2];
    assign	gf16_to_gf256[6]=a^p[2]^p[3]^q[0];
    assign	gf16_to_gf256[7]=b^p[2]^q[3];

endmodule
