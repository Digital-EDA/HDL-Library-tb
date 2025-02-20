module inverse(
        input [3:0] data,
        output wire[3:0] inverse);
    wire a;

    assign	a=data[1]^data[2]^data[3]^(data[1]&data[2]&data[3]);
    assign	inverse[0]=a^data[0]^(data[0]&data[2])^(data[1]&data[2])^(data[0]&data[1]&data[2]);
    assign	inverse[1]=(data[0]&data[1])^(data[0]&data[2])^(data[1]&data[2])^data[3]^
           (data[1]&data[3])^(data[0]&data[1]&data[3]);
    assign	inverse[2]=(data[0]&data[1])^data[2]^(data[0]&data[2])^data[3]^
           (data[0]&data[3])^(data[0]&data[2]&data[3]);
    assign	inverse[3]=a^(data[0]&data[3])^(data[1]&data[3])^(data[2]&data[3]);

endmodule
