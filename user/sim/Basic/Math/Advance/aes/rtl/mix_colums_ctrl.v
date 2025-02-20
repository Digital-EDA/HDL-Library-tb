module mix_colums_ctrl (
        input   [127:0] mix_in,
        output  [127:0] mix_out,
        input           mix_bypass,
        input           mode);

    wire [127:0] mix_slice_in;
    wire [127:0] mix_slice_out;
    genvar j;
    generate
        for (j=0; j<4; j=j+1)	begin : mixcol
            mixcol_slice Mixcol_slice_inst (
                             .S_old  (mix_in[j*32+:32]) ,//input   [31:0]
                             .mode   (mode) ,//input
                             .bypass (mix_bypass),//input
                             .new_S  (mix_out[j*32+:32]));//output  [31:0]
        end
    endgenerate

    // assign mix_slice_in = mode ? mix_in : {mix_in}

endmodule
