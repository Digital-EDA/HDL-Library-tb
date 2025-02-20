module square(
        input [3:0] data,
        output wire[3:0] square);

    assign	square[0] = data[0]^data[2];
    assign	square[1] = data[2];
    assign	square[2] = data[1]^data[3];
    assign	square[3] = data[3];

endmodule
