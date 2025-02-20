
module aes_shiftrows(
        input	[127:0]	state_in,
        input   mode,//0:enc 1:dec
        output	[127:0]	state_out);
    wire[31:0] raw_row0 = {state_in[127-:8], state_in[95-:8], state_in[63-:8], state_in[31-:8]};
    wire[31:0] raw_row1 = {state_in[119-:8], state_in[87-:8], state_in[55-:8], state_in[23-:8]};
    wire[31:0] raw_row2 = {state_in[111-:8], state_in[79-:8], state_in[47-:8], state_in[15-:8]};
    wire[31:0] raw_row3 = {state_in[103-:8], state_in[71-:8], state_in[39-:8], state_in[7-:8]};
    // wire	[31:0]	raw_row0 = {state_in[07:00], state_in[39:32], state_in[71:64], state_in[103:096]};
    // wire	[31:0]	raw_row1 = {state_in[15:08], state_in[47:40], state_in[79:72], state_in[111:104]};
    // wire	[31:0]	raw_row2 = {state_in[23:16], state_in[55:48], state_in[87:80], state_in[119:112]};
    // wire	[31:0]	raw_row3 = {state_in[31:24], state_in[63:56], state_in[95:88], state_in[127:120]};


    function [31:0]	shift_row(input	[31:0] raw_row, input[1:0] sh);
        begin
            case(sh)
                2'b00:
                    shift_row = raw_row;
                2'b01:
                    shift_row = {raw_row[23:0], raw_row[31:24]};
                2'b10:
                    shift_row = {raw_row[15:0], raw_row[31:16]};
                2'b11:
                    shift_row = {raw_row[07:0], raw_row[31:08]};
            endcase
        end
    endfunction

    wire    [31:0] shift_row0 = mode ? shift_row(raw_row0, 0) : shift_row(raw_row0, 0);
    wire    [31:0] shift_row1 = mode ? shift_row(raw_row1, 3) : shift_row(raw_row1, 1);
    wire    [31:0] shift_row2 = mode ? shift_row(raw_row2, 2) : shift_row(raw_row2, 2);
    wire    [31:0] shift_row3 = mode ? shift_row(raw_row3, 1) : shift_row(raw_row3, 3);

    assign	state_out = {
               shift_row0[31-:8], shift_row1[31-:8], shift_row2[31-:8], shift_row3[31-:8],
               shift_row0[23-:8], shift_row1[23-:8], shift_row2[23-:8], shift_row3[23-:8],
               shift_row0[15-:8], shift_row1[15-:8], shift_row2[15-:8], shift_row3[15-:8],
               shift_row0[7-:8], shift_row1[7-:8], shift_row2[7-:8], shift_row3[7-:8]
           };
endmodule
