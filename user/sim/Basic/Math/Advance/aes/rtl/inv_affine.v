// inverse affine transformation
module inv_affine(
        input [7:0] data,
        output wire [7:0] inv_affine);
    wire a,b,c,d;

    assign	a=data[0]^data[5];
    assign	b=data[1]^data[4];
    assign	c=data[2]^data[7];
    assign	d=data[3]^data[6];
    assign	inv_affine[0]=(!data[5])^c;
    assign	inv_affine[1]=data[0]^d;
    assign	inv_affine[2]=(!data[7])^b;
    assign	inv_affine[3]=data[2]^a;
    assign	inv_affine[4]=data[1]^d;
    assign	inv_affine[5]=data[4]^c;
    assign	inv_affine[6]=data[3]^a;
    assign	inv_affine[7]=data[6]^b;

endmodule
