module key_exp(
        input [255:0] key_in,
        output [255:0] key_out,
        input [1:0] key_lenth,
        input [7:0] rcon,
        input [1:0] flag,
        output [31:0] keyexp_sbox_in,
        output [31:0] keyexp_sbox_in1,
        input [31:0] keyexp_sbox_out,
        input [31:0] keyexp_sbox_out1,
        input last_round,
        input key_gen,
        // input bypass,
        input mode);
    // wire [127:0] key128_in;
    wire [191:0] key192_in;
    // wire [191:0] key192_i_in;
    // wire [255:0] key256_in;
    wire [31:0] rcon_inner;
    wire [255:0] key256_out_temp;
    wire [127:0] key128_out;
    wire [191:0] key192_out;
    wire [255:0] key192_out_temp;
    wire [255:0] key128_out_temp;
    wire [255:0] key256_out;
    wire [127:0] key256_gen_temp;

    wire [255:0] key256_i_out_temp;
    wire [127:0] key128_i_out;
    wire [191:0] key192_i_out;
    wire [255:0] key192_i_out_temp;
    wire [255:0] key128_i_out_temp;
    wire [255:0] key256_i_out;
    // wire [127:0] key256_gen_temp

    assign rcon_inner = {rcon,{24'b0}};
    reg [31:0] sbox_in;
    wire [31:0] sbox_in_temp;
    wire [31:0] sbox_128_temp;
    wire [31:0] sbox_192_temp;
    wire [31:0] sbox_256_temp;
    always @(*) begin
        case ({flag,key_lenth})
            4'b0000: begin
                sbox_in = {key_in[151:128],key_in[159:152]};
            end
            4'b0001: begin
                sbox_in = {key_in[87:64],key_in[95:88]};
            end
            // default:begin
            //     sbox_in = key_in[31:0];
            // end
            4'b0101,4'b1001,4'b0010: begin
                sbox_in = {key_in[23:0],key_in[31:24]};
            end
            4'b0110: begin
                sbox_in = key_in[31:0];
            end
            default: begin
                sbox_in = 32'b0;
            end
            // 4'b0010:begin
            //     sbox_in = key_in
            // end
        endcase
    end

    assign sbox_128_temp = key128_i_out[31:0];
    assign sbox_192_temp = {32{flag == 2'b00}} & key_in[159:128] | {32{flag == 2'b10}} & key_in[223:192];
    assign sbox_256_temp = {32{flag == 2'b00}} & {key_in[23:0],key_in[31:24]} | {32{flag == 2'b01}} & key_in[31:0];
    assign sbox_in_temp = {32{key_lenth == 2'b00}} & {sbox_128_temp[23:0],sbox_128_temp[31:24]} |
           {32{key_lenth == 2'b01}} & {sbox_192_temp[23:0],sbox_192_temp[31:24]} |
           {32{key_lenth == 2'b10}} &  sbox_256_temp;
    // assign key128_in = (key_lenth == 2'b00) ? key_in[127:0] : 0;
    // assign key192_in = (key_lenth == 2'b01) ? key_in[255:0] : 0;
    // assign key256_in = (key_lenth[1] == 1'b1) ? key_in : 0;

    // assign keyexp_sbox_in = (key_lenth == 2'b11) ? key_in[31:0] : {key_in[23:0],key_in[31:24]};
    assign keyexp_sbox_in = key_gen ? ({32{key_lenth == 2'b00}} & {key_in[151:128],key_in[159:152]} | {32{key_lenth == 2'b01}} &
                                       {key_in[87:64],key_in[95:88]} | {32{key_lenth == 2'b10}} & {key_in[23:0],key_in[31:24]}
                                      ) : mode ? sbox_in_temp : sbox_in;

    assign keyexp_sbox_in1 = key256_out[31:0];


    //128

    assign key128_out[127:96] = keyexp_sbox_out ^ rcon_inner ^ key_in[255:224];
    assign key128_out[95:64] = key128_out[127:96] ^ key_in[223:192];
    assign key128_out[63:32] = key128_out[95:64] ^ key_in[191:160];
    assign key128_out[31:0] = key128_out[63:32] ^ key_in[159:128];
    assign key128_out_temp = last_round ? {128'b0,key128_out} : {key128_out,128'b0};


    assign key128_i_out[31:0] = key_in[63:32] ^ key_in[31:0];
    assign key128_i_out[63:32] = key_in[95:64] ^ key_in[63:32];
    assign key128_i_out[95:64] = key_in[127:96] ^ key_in[95:64];
    assign key128_i_out[127:96] = keyexp_sbox_out ^ key_in[127:96] ^ rcon_inner;


    //192
    assign key192_in = (((flag == 2'b00) && (mode == 0)) || ((mode == 1) && (flag == 2'b10)) || key_gen) ? key_in[255:64] : key_in[191:0];
    assign key192_out[191:160] = keyexp_sbox_out ^ rcon_inner ^ key192_in[191:160];
    assign key192_out[159:128] = key192_out[191:160]  ^ key192_in[159:128];
    assign key192_out[127:96] = key192_out[159:128]  ^ key192_in[127:96];
    assign key192_out[95:64] = key192_out[127:96] ^ key192_in[95:64];
    assign key192_out[63:32] = key192_out[95:64] ^ key192_in[63:32];
    assign key192_out[31:0] = key192_out[63:32] ^ key192_in[31:0] ;
    assign key192_out_temp = key_gen ? (last_round ? {64'b0,key_in[127:64], key192_out[191:64]} : {key192_out,{64'b0}})  : last_round ? {key_in[127:0] , key192_out[191:64]} :({256{flag == 2'b00}} & {key_in[127:64],key192_out} |
            {256{flag == 2'b01}} & key_in |
            {256{flag == 2'b10}} & {key192_out,64'b00});

    // assign key192_i_in = flag == 2'b10 ? key_in[255:64] : key_in[191:0]
    // assign key256_i_out[31:0] = key192_in[]
    assign key192_i_out[31:0] = key192_in[63:32] ^ key192_in[31:0];
    assign key192_i_out[63:32] = key192_in[95:64] ^ key192_in[63:32];
    assign key192_i_out[95:64] = key192_in[127:96] ^ key192_in[95:64];
    assign key192_i_out[127:96] = keyexp_sbox_out ^ key192_in[127:96] ^ rcon_inner;
    assign key192_i_out[159:128] = key192_in[159:128] ^ key192_in[191:160];
    assign key192_i_out[191:160] = key192_in[191:160] ^ key192_i_out[31:0];
    assign key192_i_out_temp =  last_round ? {128'b0, key192_i_out[127:0]} : {256{flag == 2'b00}} & {key192_i_out,key_in[191:128]} |
           {256{flag == 2'b01}} & key_in |
           {256{flag == 2'b10}} & {64'b00,key192_i_out};

    //256
    wire [31:0] rcon_temp;
    // assign rcon_temp = (((flag == 2'b01 && mode == 0) || (flag == 2'b00 && mode == 1 ))&& !key_gen) ? 0 : rcon_inner;
    assign rcon_temp = (flag == 2'b01&& !key_gen) ? 0 : rcon_inner;
    assign key256_out[127:96] = keyexp_sbox_out ^ rcon_temp ^ key_in[255:224];
    assign key256_out[95:64] = key256_out[127:96] ^ key_in[223:192];
    assign key256_out[63:32] = key256_out[95:64] ^ key_in[191:160];
    assign key256_out[31:0] = key256_out[63:32] ^ key_in[159:128];


    assign key256_gen_temp[127:96] = keyexp_sbox_out1 ^ key_in[127:96];
    assign key256_gen_temp[95:64] = key256_gen_temp[127:96] ^ key_in[95:64];
    assign key256_gen_temp[63:32] = key256_gen_temp[95:64] ^ key_in[63:32];
    assign key256_gen_temp[31:0] = key256_gen_temp[63:32] ^ key_in[31:0];

    assign key256_i_out[31:0] = key_in[191:160] ^ key_in[159:128];
    assign key256_i_out[63:32] = key_in[223:192] ^ key_in[191:160];
    assign key256_i_out[95:64] = key_in[255:224] ^ key_in[223:192];
    assign key256_i_out[127:96] = flag == 2'b00 ? keyexp_sbox_out
           ^ key_in[255:224]
           ^ rcon_temp
           :keyexp_sbox_out  ^
           key_in[255:224];
    assign key256_i_out [255:128] = key_in[127:0];

    assign key256_out[255:128] = key_in[127:0];
    assign key256_out_temp =   last_round ? {key256_out[127:0],key_in[127:0]} :  key_gen ? {key256_out[127:0],key256_gen_temp} : key256_out;

    // assign key_out = key_lenth[1] ? key256_out : key_lenth[0] ? {{64'b0},key192_out} : { key128_out,{128'b0}};
    assign key_out =mode ? ({256{key_lenth == 2'b10}} & key256_i_out |
                            {256{key_lenth == 2'b01}} & key192_i_out_temp |
                            {256{key_lenth == 2'b00}} & key128_i_out) :
           ({256{key_lenth == 2'b10}} & key256_out_temp |
            {256{key_lenth == 2'b01}} & key192_out_temp |
            {256{key_lenth == 2'b00}} & key128_out_temp);
endmodule


