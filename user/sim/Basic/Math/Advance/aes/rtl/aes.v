module aes(
        input clock,
        input rstn,
        input [127:0] block_input,   // input data
        input start,                 // start process
        input [255:0] key_in,        // key
        input [1:0]key_lenth,        // key length : 2'b00 128; 2'b01 192; 2'b10/2'b11 256
        input mode,                  // 0 : encrypt 1 : decrypt
        output done,                 // process done
        output [127:0] block_output, // output data
        output proc_busy);           // module busy


    reg block_busy_r;
    reg block_done_r;
    reg [1:0] key_len_r;
    reg [255:0] key_reg;
    reg [255:0] key_first_reg;
    reg [255:0] key_last_reg;
    reg [127:0] block_temp;
    reg [127:0] sbox_out_r;
    reg [127:0] shift_row_out_r;
    reg [127:0] mix_out_r;
    reg mode_r;
    wire [1:0] key_len;
    wire key_exp_mode;
    wire sbox_mode;
    reg [3:0] counter;
    //reg [31:0]
    localparam idle = 3'b000;
    localparam init =  3'b110;
    localparam subB = 3'b001;
    localparam shiftrow = 3'b010;
    localparam mixC = 3'b011;
    localparam addkey = 3'b100;
    localparam keygen = 3'b101;

    reg [2:0] c_state;
    reg [2:0] n_state;
    reg [7:0] rcon;
    reg [1:0]  flag;

    wire key_gen;
    wire mix_bypass;
    wire rcon_bypass;
    wire [127:0] sbox_in;
    wire [127:0] sbox_out;
    wire [63:0] mul1_d1;
    wire [63:0] mul1_d2;
    wire [63:0] mul2_d1;
    wire [63:0] mul2_d2;
    wire [63:0] mul3_d1;
    wire [63:0] mul3_d2;
    wire [63:0] mul1_out;
    wire [63:0] mul2_out;
    wire [63:0] mul3_out;
    wire [63:0] mulB_in;
    wire [63:0] mulB_out;
    // wire   mode;
    wire  [255:0] key_in_temp           ;
    wire  [255:0] key_out          ;
    // wire  [1:0] key_lenth        ;
    // wire  [31:0] rcon             ;
    wire  [31:0] keyexp_sbox_in1   ;
    wire  [31:0] keyexp_sbox_out1  ;
    wire  [31:0] keyexp_sbox_in   ;
    wire  [31:0] keyexp_sbox_out  ;
    wire [127:0] gf256To16_in;
    wire [127:0] gf256To16_out;
    wire [127:0] gf16To256_in;
    wire [127:0] gf16To256_out;
    wire [7:0] rcon_o;
    wire [127:0] mix_in;
    wire [127:0] mix_out;
    wire [127:0] state_out;
    wire [127:0] state_in;
    wire [127:0] key_add_in;
    wire [127:0] key_i_add;
    wire last_round;
    wire first_round;
    wire keygen_done;
    wire key_done;
    // wire [127:0] mix_in

    assign key_len = key_lenth[1] ? 2'b10 : key_lenth;
    wire [127:0] key_add;
    always @( posedge clock or negedge rstn) begin
        if(~rstn) begin
            // block_busy_r <= 1'b0 ;
            // block_done_r <= 1'b0 ;
            key_len_r <= 2'b0;
            // key_reg <= 256'b0;
            // block_temp <= 128'b0;
        end
        else if((~proc_busy) && (start)) begin
            // block_busy_r <= 1'b1 ;
            // block_done_r <= 1'b0 ;
            key_len_r <= key_len;
        end
        else
            key_len_r <= key_len_r;
    end
    always @(posedge clock or negedge rstn) begin
        if(~rstn) begin
            mode_r <= 0;
        end
        else if(~proc_busy && start ) begin
            mode_r <= mode;
        end
        else begin
            mode_r <= mode_r;
        end

    end


    always @(posedge clock or negedge rstn) begin
        if(~rstn) begin
            block_busy_r <= 1'b0;
        end
        else if((~block_busy_r) && start) begin
            block_busy_r <= 1'b1;
        end
        else if(c_state!= idle && n_state == idle) begin
            block_busy_r <= 1'b0;
        end
        else begin
            block_busy_r <= block_busy_r;
        end
    end
    assign proc_busy = block_busy_r;

    always @(posedge clock or negedge rstn) begin
        if(!rstn) begin
            block_done_r <= 1'b0;
        end
        else if(c_state!= idle && n_state == idle) begin
            block_done_r <= 1'b1;
        end
        else begin
            block_done_r <= 1'b0;
        end
    end
    assign done = block_done_r;

    // assign block_output = done ? block_temp : 128'b0;
    assign block_output = block_temp;



    always @(posedge clock or negedge rstn) begin
        if(~rstn) begin
            block_temp <= 128'b0;
        end
        else if(~proc_busy && start) begin
            block_temp <= block_input;
        end
        else if(c_state == init) begin
            block_temp <= key_add ^ (mode_r ? sbox_out_r : block_temp);
        end
        else if(c_state == addkey) begin
            block_temp <= key_add ^ key_add_in;
        end
        else begin
            block_temp <= block_temp;
        end
    end
    assign key_add_in = (first_round && mode_r == 1) ? block_temp : (mode_r ? sbox_out_r : mix_out_r);

    always @(posedge clock or negedge rstn) begin
        if(~rstn) begin
            key_reg <= 256'b0;
        end
        else if((c_state == idle) && start) begin
            case (key_len)
                2'b00: begin
                    key_reg <= key_done  ? key_last_reg :{key_in[127:0],{128'b0}};
                end
                2'b01: begin
                    key_reg <= key_done  ? key_last_reg :{key_in[191:0],{64'b0}};
                end
                2'b10: begin
                    key_reg <= key_done  ? key_last_reg :key_in;
                end
                default: begin
                    key_reg <= 0;
                end
                // key_reg <= key_in;
            endcase
        end
        else if((c_state == shiftrow) || (c_state == keygen))
            key_reg <= key_out;
        else
            key_reg <= key_reg;
    end

    always @(posedge clock or negedge rstn) begin
        if(~rstn)  begin
            key_first_reg <= 256'b0;
        end
        else if((c_state == idle) && start) begin
            key_first_reg <= key_in;
        end
        else begin
            key_first_reg <= key_first_reg;
        end
    end
    always @(posedge clock or negedge rstn) begin
        if(~rstn)  begin
            key_last_reg <= 256'b0;
        end
        else if((c_state == shiftrow && last_round && mode == 0) || (c_state == keygen && keygen_done)) begin
            key_last_reg <= key_out;
        end
        else begin
            key_last_reg <= key_last_reg;
        end
    end

    always@(posedge clock or negedge rstn) begin
        if(!rstn) begin
            c_state <= idle;
        end
        else begin
            c_state <= n_state;
        end
    end
    always @(posedge clock or negedge rstn) begin
        if(!rstn) begin
            counter <= 4'b0;
        end
        else if(((c_state == idle) && (n_state == init|| key_done)) || keygen_done ) begin
            counter <= key_len[1] ? 4'd13 : key_len[0] ? 4'd11 : 4'd9;
        end
        else if(c_state == idle && n_state == keygen) begin
            counter <= key_len[1] ? 4'd6 : key_len[0] ? 4'd7 : 4'd9;
        end
        // else if((((c_state == addkey) && (mode_r == 0))|| (c_state == keygen) || ((c_state == subB) && (mode_r == 1))) && (counter != 0)) begin
        else if(((c_state == (mode_r ? subB : addkey))  || c_state == keygen ) && counter != 0) begin
            counter <= counter - 1;
        end
        else begin
            counter <= counter;
        end
    end
    always @(posedge clock or negedge rstn) begin
        if(~rstn) begin
            flag <= 2'b0;
        end
        else if(c_state == idle || keygen_done) begin
            flag <= 0;
        end
        else if(c_state == shiftrow || c_state == keygen) begin
            case (key_len_r)
                2'b00: begin
                    flag <= 0;
                end
                2'b01: begin
                    if(flag == 2'b10) begin
                        flag <= 2'b00;
                    end
                    else begin
                        flag <= flag + 1;
                    end
                end
                default: begin
                    flag[0] <= ~flag[0];
                    flag[1] <= flag[1];
                    // if(flag == 2'b01) begin
                    //     flag <= 2'b00;
                    // end
                    // else begin
                    //     flag <= flag + 1;
                    // end
                end
            endcase
        end
    end


    // assign key_add = (key_len_r == 2'b00) ? key_reg[127:0] :(key_len_r == 2'b10) ? key_reg[255:128] : (flag == 2'b01 || ? key_reg[127]

    // assign key_add = ((key_len_r == 2'b10) || (flag[0] == 1)) ? key_reg[255:128] : key_reg[127:0];
    assign key_add = mode_r ? key_i_add : (((key_len_r == 2'b01) && (flag[1] == 1)) || (counter == 0)) ? key_reg[127:0] : key_reg[255:128];
    assign key_i_add = (key_len_r == 2'b01 && flag == 2'b10 || key_len_r == 2'b10) ? key_reg[255:128] : key_reg[127:0];
    always @(*) begin
        case (c_state)
            idle: begin
                if(start) begin
                    n_state = mode == 0 ?  init : key_done ? addkey : keygen;
                end
                else
                    n_state = idle;
            end
            init: begin
                n_state = mode_r ? idle : subB;
            end
            subB: begin
                n_state = (mode_r == 0) ? shiftrow : counter == 0 ? init : addkey;
            end
            shiftrow: begin
                n_state = mode_r ? subB :mixC ;
            end
            mixC: begin
                n_state = mode_r ? shiftrow : addkey;
            end
            addkey: begin
                // if((counter == 0) && (mode_r == 0)) begin
                //     n_state = idle;
                // end
                // else begin
                // n_state = mode_r ? mixC : subB;
                // end
                n_state = mode_r ? mixC : counter == 0 ? idle : subB;
            end
            keygen: begin
                if(keygen_done) begin
                    n_state = addkey;
                end
                else begin
                    n_state = keygen;
                end
            end
            default: begin
                n_state = idle;
            end
        endcase
    end

    assign keygen_done = (c_state == keygen) && (counter == 0);
    assign mix_bypass = mode_r ? first_round : last_round ;
    assign last_round = (counter == 0) && (c_state != idle) ;
    assign first_round = ((counter == 4'd13) & (key_len_r == 2'b10)) |  ((counter == 4'd11) & (key_len_r == 2'b01)) | ((counter == 4'd9) & (key_len_r == 2'b00));
    // assign key_done = (key_last_reg == 0 && key_first_reg == 0) ? 0 : (mode && ((key_in == key_first_reg) && (key_lenth == key_len_r)));
    assign key_done = 1'b0;

    always @(posedge clock or negedge rstn) begin
        if(!rstn) begin
            sbox_out_r <= 128'b0;
        end
        else if(c_state == subB) begin
            sbox_out_r <= sbox_out;
        end
        else begin
            sbox_out_r <= sbox_out_r;
        end
    end


    assign key_gen = c_state == keygen;
    always @(posedge clock or negedge rstn) begin
        if(~rstn) begin
            shift_row_out_r <= 128'b0;
        end
        else if(c_state == shiftrow) begin
            shift_row_out_r <= state_out;
        end
        else begin
            shift_row_out_r <= shift_row_out_r;
        end
    end
    always @(posedge clock or negedge rstn) begin
        if(~rstn) begin
            mix_out_r <= 128'b0;
        end
        else if(c_state == mixC) begin
            mix_out_r <= mix_out;
        end
        else begin
            mix_out_r <= mix_out_r;
        end
    end


    always @(posedge clock or negedge rstn) begin
        if(!rstn) begin
            rcon <= 0;
        end
        else if(n_state == subB || n_state == keygen) begin
            rcon <= (c_state == init || c_state == idle) ? 8'h01 : rcon_o;
        end
        else if(c_state == idle && key_done) begin
            rcon <= (({8{key_len == 2'b00}} & 8'h36) | ({8{key_len == 2'b01}} & 8'h80) | ({8{key_len == 2'b10}} & 8'h40));

        end
        else begin
            rcon <= rcon;
        end
    end


    // assign key_in_temp = c_state == shiftrow ? key_reg : 256'b0;
    assign key_in_temp = key_reg ;
    assign sbox_in[63:0]  = ((c_state == shiftrow) || (c_state == keygen)) ? {keyexp_sbox_in1 ,keyexp_sbox_in} : mode_r ? shift_row_out_r[63:0] : block_temp[63:0];
    assign sbox_in[127:64] = mode_r ? shift_row_out_r[127:64] : block_temp[127:64];
    assign keyexp_sbox_out = sbox_out[31:0];
    assign keyexp_sbox_out1 = sbox_out[63:32];
    assign mix_in = mode_r ? block_temp : shift_row_out_r;
    assign state_in = mode_r ? mix_out_r : sbox_out_r;
    assign rcon_bypass = (c_state != keygen) && (flag == 2'b01);
    assign key_exp_mode = c_state == keygen ? 0 : mode_r;
    assign sbox_mode = (c_state == keygen || c_state == shiftrow) ? 0 : mode_r;
    // assign

    key_exp key_exp_inst (
                .key_in           (key_in_temp      ) ,//input   [255:0]
                .key_out          (key_out          ) ,//output  [255:0]
                .key_lenth        (key_len_r        ) ,//input   [1:0]
                .rcon             (rcon             ) ,//input   [7:0]
                .keyexp_sbox_in   (keyexp_sbox_in   ) ,//output  [31:0]
                .keyexp_sbox_in1  (keyexp_sbox_in1  ) ,//output  [31:0]
                .keyexp_sbox_out1 (keyexp_sbox_out1 ) ,//input   [31:0]
                .keyexp_sbox_out  (keyexp_sbox_out  ) ,//input   [31:0]
                .last_round       (last_round       ) ,//input
                // .bypass           (rcon_bypass      ) ,//input
                .key_gen          (key_gen          ) ,//input
                .flag             (flag             ) ,//input   [1:0]
                .mode             (key_exp_mode     ));//input


    mix_colums_ctrl mix_colums_ctrl (
                        .mix_bypass(mix_bypass) ,//input
                        .mix_in    (mix_in    ) ,//input   [127:0]
                        .mix_out   (mix_out   ) ,//output  [127:0]
                        .mode      (mode_r      ));//input


    aes_shiftrows shift_row_inst (
                      .state_in   (state_in   ) ,//input   [127:0]
                      .mode       (mode_r       ) ,//input
                      .state_out  (state_out  ));//output  [127:0]


    sbox_ctrl sbox_ctrl_inst (
                  .sbox_in        (sbox_in        ) ,//input   [127:0]
                  .mode           (sbox_mode      ) ,//input
                  .sbox_out       (sbox_out       ) ,//output  [127:0]
                  .mul1_d1        (mul1_d1        ) ,//output  [63:0]
                  .mul1_d2        (mul1_d2        ) ,//output  [63:0]
                  .mul2_d1        (mul2_d1        ) ,//output  [63:0]
                  .mul2_d2        (mul2_d2        ) ,//output  [63:0]
                  .mul3_d1        (mul3_d1        ) ,//output  [63:0]
                  .mul3_d2        (mul3_d2        ) ,//output  [63:0]
                  .mul1_out       (mul1_out       ) ,//input   [63:0]
                  .mul2_out       (mul2_out       ) ,//input   [63:0]
                  .mul3_out       (mul3_out       ) ,//input   [63:0]
                  .mulB_in        (mulB_in        ) ,//output  [63:0]
                  .mulB_out       (mulB_out       ) ,//input   [63:0]
                  .gf256To16_in   (gf256To16_in   ) ,//output  [127:0]
                  .gf256To16_out  (gf256To16_out  ) ,//input   [127:0]
                  .gf16To256_in   (gf16To256_in   ) ,//output  [127:0]
                  .gf16To256_out  (gf16To256_out  ));//input   [127:0]

    gf_convert_ctrl gf_convert_ctrl_inst (
                        .gf256To16_in   (gf256To16_in   ) ,//input   [127:0]
                        .gf256To16_out  (gf256To16_out  ) ,//output  [127:0]
                        .gf16To256_in   (gf16To256_in   ) ,//input   [127:0]
                        .gf16To256_out  (gf16To256_out  ));//output  [127:0]

    mul_ctrl mul_ctrl_inst (
                 .mul1_d1   (mul1_d1   ) ,//input   [63:0]
                 .mul1_d2   (mul1_d2   ) ,//input   [63:0]
                 .mul2_d1   (mul2_d1   ) ,//input   [63:0]
                 .mul2_d2   (mul2_d2   ) ,//input   [63:0]
                 .mul3_d1   (mul3_d1   ) ,//input   [63:0]
                 .mul3_d2   (mul3_d2   ) ,//input   [63:0]
                 .mul1_out  (mul1_out  ) ,//output  [63:0]
                 .mul2_out  (mul2_out  ) ,//output  [63:0]
                 .mul3_out  (mul3_out  ) ,//output  [63:0]
                 .mulB_in   (mulB_in   ) ,//input   [63:0]
                 .mulB_out  (mulB_out  ));//output  [63:0]

    rcongen rcongen_inst (
                .i          (rcon) ,//input   [7:0]
                .o          (rcon_o) ,//output  [7:0]
                .bypass(rcon_bypass),
                .mode  (key_exp_mode));//input

endmodule
