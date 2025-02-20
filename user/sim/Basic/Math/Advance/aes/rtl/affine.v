module affine(
        input [7:0] data,
        output wire [7:0] affine);

    //affine trasformation
    assign	affine[0]=(!data[0])^data[4]^data[5]^data[6]^data[7];
    assign	affine[1]=(!data[0])^data[1]^data[5]^data[6]^data[7];
    assign	affine[2]=data[0]^data[1]^data[2]^data[6]^data[7];
    assign	affine[3]=data[0]^data[1]^data[2]^data[3]^data[7];
    assign	affine[4]=data[0]^data[1]^data[2]^data[3]^data[4];
    assign	affine[5]=(!data[1])^data[2]^data[3]^data[4]^data[5];
    assign	affine[6]=(!data[2])^data[3]^data[4]^data[5]^data[6];
    assign	affine[7]=data[3]^data[4]^data[5]^data[6]^data[7];

endmodule
