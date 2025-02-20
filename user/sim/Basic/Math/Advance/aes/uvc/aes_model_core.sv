//=========================================================================
// AES 类封装（支持 128/192/256 位密钥，支持加密和解密模式）
// 注意：仅用于仿真，不可综合，且所有过程均为组合逻辑
//=========================================================================
class aes_model_core;

  //--------------------------------------------------------------------------
  // AES 参数
  //--------------------------------------------------------------------------
  int Nk;       // 密钥字数：4、6、8
  int Nr;       // 轮数：10、12、14
  int key_len;  // 密钥长度（单位：bit）：128、192、256

  // 扩展密钥（最大 60 个 32 位字足够覆盖 256 位密钥的情况）
  logic [31:0] expanded_key[0:59];

  //--------------------------------------------------------------------------
  // 常量：SBox（256个8位）
  //--------------------------------------------------------------------------
  localparam logic [7:0] SBox[0:255] = '{
    8'h63, 8'h7c, 8'h77, 8'h7b, 8'hf2, 8'h6b, 8'h6f, 8'hc5,
    8'h30, 8'h01, 8'h67, 8'h2b, 8'hfe, 8'hd7, 8'hab, 8'h76,
    8'hca, 8'h82, 8'hc9, 8'h7d, 8'hfa, 8'h59, 8'h47, 8'hf0,
    8'had, 8'hd4, 8'ha2, 8'haf, 8'h9c, 8'ha4, 8'h72, 8'hc0,
    8'hb7, 8'hfd, 8'h93, 8'h26, 8'h36, 8'h3f, 8'hf7, 8'hcc,
    8'h34, 8'ha5, 8'he5, 8'hf1, 8'h71, 8'hd8, 8'h31, 8'h15,
    8'h04, 8'hc7, 8'h23, 8'hc3, 8'h18, 8'h96, 8'h05, 8'h9a,
    8'h07, 8'h12, 8'h80, 8'he2, 8'heb, 8'h27, 8'hb2, 8'h75,
    8'h09, 8'h83, 8'h2c, 8'h1a, 8'h1b, 8'h6e, 8'h5a, 8'ha0,
    8'h52, 8'h3b, 8'hd6, 8'hb3, 8'h29, 8'he3, 8'h2f, 8'h84,
    8'h53, 8'hd1, 8'h00, 8'hed, 8'h20, 8'hfc, 8'hb1, 8'h5b,
    8'h6a, 8'hcb, 8'hbe, 8'h39, 8'h4a, 8'h4c, 8'h58, 8'hcf,
    8'hd0, 8'hef, 8'haa, 8'hfb, 8'h43, 8'h4d, 8'h33, 8'h85,
    8'h45, 8'hf9, 8'h02, 8'h7f, 8'h50, 8'h3c, 8'h9f, 8'ha8,
    8'h51, 8'ha3, 8'h40, 8'h8f, 8'h92, 8'h9d, 8'h38, 8'hf5,
    8'hbc, 8'hb6, 8'hda, 8'h21, 8'h10, 8'hff, 8'hf3, 8'hd2,
    8'hcd, 8'h0c, 8'h13, 8'hec, 8'h5f, 8'h97, 8'h44, 8'h17,
    8'hc4, 8'ha7, 8'h7e, 8'h3d, 8'h64, 8'h5d, 8'h19, 8'h73,
    8'h60, 8'h81, 8'h4f, 8'hdc, 8'h22, 8'h2a, 8'h90, 8'h88,
    8'h46, 8'hee, 8'hb8, 8'h14, 8'hde, 8'h5e, 8'h0b, 8'hdb,
    8'he0, 8'h32, 8'h3a, 8'h0a, 8'h49, 8'h06, 8'h24, 8'h5c,
    8'hc2, 8'hd3, 8'hac, 8'h62, 8'h91, 8'h95, 8'he4, 8'h79,
    8'he7, 8'hc8, 8'h37, 8'h6d, 8'h8d, 8'hd5, 8'h4e, 8'ha9,
    8'h6c, 8'h56, 8'hf4, 8'hea, 8'h65, 8'h7a, 8'hae, 8'h08,
    8'hba, 8'h78, 8'h25, 8'h2e, 8'h1c, 8'ha6, 8'hb4, 8'hc6,
    8'he8, 8'hdd, 8'h74, 8'h1f, 8'h4b, 8'hbd, 8'h8b, 8'h8a,
    8'h70, 8'h3e, 8'hb5, 8'h66, 8'h48, 8'h03, 8'hf6, 8'h0e,
    8'h61, 8'h35, 8'h57, 8'hb9, 8'h86, 8'hc1, 8'h1d, 8'h9e,
    8'he1, 8'hf8, 8'h98, 8'h11, 8'h69, 8'hd9, 8'h8e, 8'h94,
    8'h9b, 8'h1e, 8'h87, 8'he9, 8'hce, 8'h55, 8'h28, 8'hdf,
    8'h8c, 8'ha1, 8'h89, 8'h0d, 8'hbf, 8'he6, 8'h42, 8'h68,
    8'h41, 8'h99, 8'h2d, 8'h0f, 8'hb0, 8'h54, 8'hbb, 8'h16
  };

  //--------------------------------------------------------------------------
  // 常量：逆 SBox
  //--------------------------------------------------------------------------
  localparam logic [7:0] invSBox[0:255] = '{
    8'h52, 8'h09, 8'h6a, 8'hd5, 8'h30, 8'h36, 8'ha5, 8'h38,
    8'hbf, 8'h40, 8'ha3, 8'h9e, 8'h81, 8'hf3, 8'hd7, 8'hfb,
    8'h7c, 8'he3, 8'h39, 8'h82, 8'h9b, 8'h2f, 8'hff, 8'h87,
    8'h34, 8'h8e, 8'h43, 8'h44, 8'hc4, 8'hde, 8'he9, 8'hcb,
    8'h54, 8'h7b, 8'h94, 8'h32, 8'ha6, 8'hc2, 8'h23, 8'h3d,
    8'hee, 8'h4c, 8'h95, 8'h0b, 8'h42, 8'hfa, 8'hc3, 8'h4e,
    8'h08, 8'h2e, 8'ha1, 8'h66, 8'h28, 8'hd9, 8'h24, 8'hb2,
    8'h76, 8'h5b, 8'ha2, 8'h49, 8'h6d, 8'h8b, 8'hd1, 8'h25,
    8'h72, 8'hf8, 8'hf6, 8'h64, 8'h86, 8'h68, 8'h98, 8'h16,
    8'hd4, 8'ha4, 8'h5c, 8'hcc, 8'h5d, 8'h65, 8'hb6, 8'h92,
    8'h6c, 8'h70, 8'h48, 8'h50, 8'hfd, 8'hed, 8'hb9, 8'hda,
    8'h5e, 8'h15, 8'h46, 8'h57, 8'ha7, 8'h8d, 8'h9d, 8'h84,
    8'h90, 8'hd8, 8'hab, 8'h00, 8'h8c, 8'hbc, 8'hd3, 8'h0a,
    8'hf7, 8'he4, 8'h58, 8'h05, 8'hb8, 8'hb3, 8'h45, 8'h06,
    8'hd0, 8'h2c, 8'h1e, 8'h8f, 8'hca, 8'h3f, 8'h0f, 8'h02,
    8'hc1, 8'haf, 8'hbd, 8'h03, 8'h01, 8'h13, 8'h8a, 8'h6b,
    8'h3a, 8'h91, 8'h11, 8'h41, 8'h4f, 8'h67, 8'hdc, 8'hea,
    8'h97, 8'hf2, 8'hcf, 8'hce, 8'hf0, 8'hb4, 8'he6, 8'h73,
    8'h96, 8'hac, 8'h74, 8'h22, 8'he7, 8'had, 8'h35, 8'h85,
    8'he2, 8'hf9, 8'h37, 8'he8, 8'h1c, 8'h75, 8'hdf, 8'h6e,
    8'h47, 8'hf1, 8'h1a, 8'h71, 8'h1d, 8'h29, 8'hc5, 8'h89,
    8'h6f, 8'hb7, 8'h62, 8'h0e, 8'haa, 8'h18, 8'hbe, 8'h1b,
    8'hfc, 8'h56, 8'h3e, 8'h4b, 8'hc6, 8'hd2, 8'h79, 8'h20,
    8'h9a, 8'hdb, 8'hc0, 8'hfe, 8'h78, 8'hcd, 8'h5a, 8'hf4,
    8'h1f, 8'hdd, 8'ha8, 8'h33, 8'h88, 8'h07, 8'hc7, 8'h31,
    8'hb1, 8'h12, 8'h10, 8'h59, 8'h27, 8'h80, 8'hec, 8'h5f,
    8'h60, 8'h51, 8'h7f, 8'ha9, 8'h19, 8'hb5, 8'h4a, 8'h0d,
    8'h2d, 8'he5, 8'h7a, 8'h9f, 8'h93, 8'hc9, 8'h9c, 8'hef,
    8'ha0, 8'he0, 8'h3b, 8'h4d, 8'hae, 8'h2a, 8'hf5, 8'hb0,
    8'hc8, 8'heb, 8'hbb, 8'h3c, 8'h83, 8'h53, 8'h99, 8'h61,
    8'h17, 8'h2b, 8'h04, 8'h7e, 8'hba, 8'h77, 8'hd6, 8'h26,
    8'he1, 8'h69, 8'h14, 8'h63, 8'h55, 8'h21, 8'h0c, 8'h7d
  };

  //--------------------------------------------------------------------------
  // 常量：轮常数 Rcon（10个32位字，足够覆盖 128/192/256 的情况）
  //--------------------------------------------------------------------------
  localparam logic [31:0] Rcon[0:9] = '{
    32'h01000000, 32'h02000000, 32'h04000000, 32'h08000000,
    32'h10000000, 32'h20000000, 32'h40000000, 32'h80000000,
    32'h1b000000, 32'h36000000
  };

  //--------------------------------------------------------------------------
  // 函数：sub_byte
  // 作用：用 SBox 对一个字节进行代换
  //--------------------------------------------------------------------------
  function automatic logic [7:0] sub_byte(input logic [7:0] in);
    sub_byte = SBox[in];
  endfunction

  //--------------------------------------------------------------------------
  // 函数：inv_sub_byte
  // 作用：用逆 SBox 对一个字节进行代换
  //--------------------------------------------------------------------------
  function automatic logic [7:0] inv_sub_byte(input logic [7:0] in);
    inv_sub_byte = invSBox[in];
  endfunction

  //--------------------------------------------------------------------------
  // 函数：rot_word
  // 作用：对 32 位字做循环左移（最高字节移到最低位）
  //--------------------------------------------------------------------------
  function automatic logic [31:0] rot_word(input logic [31:0] word);
    rot_word = { word[23:0], word[31:24] };
  endfunction

  //--------------------------------------------------------------------------
  // 函数：sub_word
  // 作用：对 32 位字的每个字节做 SBox 代换
  //--------------------------------------------------------------------------
  function automatic logic [31:0] sub_word(input logic [31:0] word);
    logic [7:0] b0, b1, b2, b3;
    begin
      b0 = sub_byte(word[31:24]);
      b1 = sub_byte(word[23:16]);
      b2 = sub_byte(word[15:8]);
      b3 = sub_byte(word[7:0]);
      sub_word = {b0, b1, b2, b3};
    end
  endfunction

  //--------------------------------------------------------------------------
  // 函数：key_expansion
  // 作用：对输入密钥进行扩展，支持 128/192/256 位密钥
  // 输入参数：
  //   Nk      - 密钥字数（4,6,8）
  //   Nr      - 轮数（10,12,14）
  //   key     - 输入密钥（总宽度固定为 256 位，但仅 key_len 位有效）
  //   key_len - 密钥有效位数（128,192,256）
  // 输出：
  //   w       - 扩展后的轮密钥数组（总字数 = 4*(Nr+1)）
  //--------------------------------------------------------------------------
  function automatic void key_expansion(
    input int Nk,
    input int Nr,
    input logic [255:0] key,
    input int key_len,
    output logic [31:0] w[0:59]
  );
    int total_words;
    int i;
    logic [31:0] temp;
    begin
      total_words = 4 * (Nr + 1);
      // 将输入密钥按字划分：假设最高有效位在 key[key_len-1]
      for (i = 0; i < Nk; i++) begin
        // 每 32 位为一字，按“列优先”（高位为第一个字）
        w[i] = key[ key_len - 1 - (32*i) -: 32 ];
      end
      for (i = Nk; i < total_words; i++) begin
        temp = w[i-1];
        if ( (i % Nk) == 0 ) begin
          temp = sub_word(rot_word(temp)) ^ Rcon[(i / Nk) - 1];
        end else if ((Nk == 8) && ((i % Nk) == 4)) begin
          temp = sub_word(temp);
        end
        w[i] = w[i - Nk] ^ temp;
      end
    end
  endfunction

  //--------------------------------------------------------------------------
  // 函数：xtime
  // 作用：GF(2^8) 下乘以 2 的运算（用于 MixColumns）
  //--------------------------------------------------------------------------
  function automatic logic [7:0] xtime(input logic [7:0] b);
    xtime = {b[6:0], 1'b0} ^ (8'h1b & {8{b[7]}});
  endfunction

  //--------------------------------------------------------------------------
  // 函数：gmul
  // 作用：GF(2^8) 下乘法，计算 a * b
  //--------------------------------------------------------------------------
  function automatic logic [7:0] gmul(input logic [7:0] a, input logic [7:0] b);
    logic [7:0] p;
    logic hi_bit;
    int i;
    begin
      p = 8'd0;
      for (i = 0; i < 8; i++) begin
        if (b[0])
          p = p ^ a;
        hi_bit = a[7];
        a = a << 1;
        if (hi_bit)
          a = a ^ 8'h1b;
        b = b >> 1;
      end
      gmul = p;
    end
  endfunction

  //--------------------------------------------------------------------------
  // 任务：sub_bytes
  // 作用：对状态矩阵中每个字节做 SBox 代换
  //--------------------------------------------------------------------------
  function automatic void sub_bytes(inout logic [7:0] state [0:3][0:3]);
    int r, c;
    begin
      for (r = 0; r < 4; r++)
        for (c = 0; c < 4; c++)
          state[r][c] = sub_byte(state[r][c]);
    end
  endfunction

  //--------------------------------------------------------------------------
  // 任务：inv_sub_bytes
  // 作用：对状态矩阵中每个字节做逆 SBox 代换
  //--------------------------------------------------------------------------
  function automatic void inv_sub_bytes(inout logic [7:0] state [0:3][0:3]);
    int r, c;
    begin
      for (r = 0; r < 4; r++)
        for (c = 0; c < 4; c++)
          state[r][c] = inv_sub_byte(state[r][c]);
    end
  endfunction

  //--------------------------------------------------------------------------
  // 任务：shift_rows
  // 作用：对状态矩阵各行做循环左移（第 r 行左移 r 个字节）
  //--------------------------------------------------------------------------
  function automatic void shift_rows(inout logic [7:0] state [0:3][0:3]);
    logic [7:0] temp [0:3];
    int r, c;
    begin
      // 第一行不变，从第二行开始循环左移
      for (r = 1; r < 4; r++) begin
        for (c = 0; c < 4; c++)
          temp[c] = state[r][ (c + r) % 4 ];
        for (c = 0; c < 4; c++)
          state[r][c] = temp[c];
      end
    end
  endfunction

  //--------------------------------------------------------------------------
  // 任务：inv_shift_rows
  // 作用：对状态矩阵各行做循环右移（第 r 行右移 r 个字节）
  //--------------------------------------------------------------------------
  function automatic void inv_shift_rows(inout logic [7:0] state [0:3][0:3]);
    logic [7:0] temp [0:3];
    int r, c;
    begin
      // 第一行不变，从第二行开始循环右移
      for (r = 1; r < 4; r++) begin
        for (c = 0; c < 4; c++)
          // 右移 r 个位置，相当于左移 (4 - r)
          temp[c] = state[r][ (c + (4 - r)) % 4 ];
        for (c = 0; c < 4; c++)
          state[r][c] = temp[c];
      end
    end
  endfunction

  //--------------------------------------------------------------------------
  // 任务：mix_columns
  // 作用：对状态矩阵每列做 MixColumns 变换
  //--------------------------------------------------------------------------
  function automatic void mix_columns(inout logic [7:0] state [0:3][0:3]);
    int c;
    logic [7:0] a0, a1, a2, a3;
    logic [7:0] r0, r1, r2, r3;
    begin
      for (c = 0; c < 4; c++) begin
        a0 = state[0][c];
        a1 = state[1][c];
        a2 = state[2][c];
        a3 = state[3][c];
        r0 = xtime(a0) ^ (a1 ^ xtime(a1)) ^ a2 ^ a3;
        r1 = a0 ^ xtime(a1) ^ (a2 ^ xtime(a2)) ^ a3;
        r2 = a0 ^ a1 ^ xtime(a2) ^ (a3 ^ xtime(a3));
        r3 = (a0 ^ xtime(a0)) ^ a1 ^ a2 ^ xtime(a3);
        state[0][c] = r0;
        state[1][c] = r1;
        state[2][c] = r2;
        state[3][c] = r3;
      end
    end
  endfunction

  //--------------------------------------------------------------------------
  // 任务：inv_mix_columns
  // 作用：对状态矩阵每列做逆 MixColumns 变换
  //--------------------------------------------------------------------------
  function automatic void inv_mix_columns(inout logic [7:0] state [0:3][0:3]);
    int c;
    logic [7:0] a0, a1, a2, a3;
    logic [7:0] r0, r1, r2, r3;
    begin
      for (c = 0; c < 4; c++) begin
        a0 = state[0][c];
        a1 = state[1][c];
        a2 = state[2][c];
        a3 = state[3][c];
        r0 = gmul(a0,8'h0e) ^ gmul(a1,8'h0b) ^ gmul(a2,8'h0d) ^ gmul(a3,8'h09);
        r1 = gmul(a0,8'h09) ^ gmul(a1,8'h0e) ^ gmul(a2,8'h0b) ^ gmul(a3,8'h0d);
        r2 = gmul(a0,8'h0d) ^ gmul(a1,8'h09) ^ gmul(a2,8'h0e) ^ gmul(a3,8'h0b);
        r3 = gmul(a0,8'h0b) ^ gmul(a1,8'h0d) ^ gmul(a2,8'h09) ^ gmul(a3,8'h0e);
        state[0][c] = r0;
        state[1][c] = r1;
        state[2][c] = r2;
        state[3][c] = r3;
      end
    end
  endfunction

  //--------------------------------------------------------------------------
  // 任务：add_round_key
  // 作用：将状态矩阵与轮密钥进行异或（轮密钥为 4 个 32 位字）
  //--------------------------------------------------------------------------
  function automatic void add_round_key(
    inout logic [7:0] state [0:3][0:3],
    input logic [31:0] round_key [0:3]
  );
    int c;
    begin
      for (c = 0; c < 4; c++) begin
        state[0][c] = state[0][c] ^ round_key[c][31:24];
        state[1][c] = state[1][c] ^ round_key[c][23:16];
        state[2][c] = state[2][c] ^ round_key[c][15:8];
        state[3][c] = state[3][c] ^ round_key[c][7:0];
      end
    end
  endfunction

  //--------------------------------------------------------------------------
  // 函数：encrypt_block
  // 作用：对 128 位明文进行 AES 加密，返回 128 位密文
  //--------------------------------------------------------------------------
  function automatic logic [127:0] encrypt_block(input logic [127:0] plaintext);
    logic [7:0] state [0:3][0:3];
    logic [31:0] round_key [0:3];
    int round, c, r;
    logic [127:0] out;
    int total_round_keys;
    begin
      total_round_keys = 4 * (Nr + 1);
      // 将明文按列填入状态矩阵
      for (c = 0; c < 4; c++)
        for (r = 0; r < 4; r++)
          state[r][c] = plaintext[127 - ((4*c + r)*8) -: 8];
      // 初始轮：使用第 0 组轮密钥（w[0..3]）
      for (c = 0; c < 4; c++)
        round_key[c] = expanded_key[c];
      add_round_key(state, round_key);
      // 主轮：共 Nr-1 轮
      for (round = 1; round < Nr; round++) begin
        sub_bytes(state);
        shift_rows(state);
        mix_columns(state);
        for (c = 0; c < 4; c++)
          round_key[c] = expanded_key[4*round + c];
        add_round_key(state, round_key);
      end
      // 最后一轮：不做 MixColumns
      sub_bytes(state);
      shift_rows(state);
      for (c = 0; c < 4; c++)
        round_key[c] = expanded_key[4*Nr + c];
      add_round_key(state, round_key);
      // 将状态矩阵打包成 128 位输出
      for (c = 0; c < 4; c++)
        for (r = 0; r < 4; r++)
          out[127 - ((4*c + r)*8) -: 8] = state[r][c];
      encrypt_block = out;
    end
  endfunction

  //--------------------------------------------------------------------------
  // 函数：decrypt_block
  // 作用：对 128 位密文进行 AES 解密，返回 128 位明文
  //--------------------------------------------------------------------------
  function automatic logic [127:0] decrypt_block(input logic [127:0] ciphertext);
    logic [7:0] state [0:3][0:3];
    logic [31:0] round_key [0:3];
    int round, c, r;
    logic [127:0] out;
    begin
      // 将密文按列填入状态矩阵
      for (c = 0; c < 4; c++)
        for (r = 0; r < 4; r++)
          state[r][c] = ciphertext[127 - ((4*c + r)*8) -: 8];
      // 初始轮：使用最后一组轮密钥（w[4*Nr ... 4*Nr+3]）
      for (c = 0; c < 4; c++)
        round_key[c] = expanded_key[4*Nr + c];
      add_round_key(state, round_key);
      // 主轮：从 round = Nr-1 到 1
      for (round = Nr - 1; round > 0; round--) begin
        inv_shift_rows(state);
        inv_sub_bytes(state);
        for (c = 0; c < 4; c++)
          round_key[c] = expanded_key[4*round + c];
        add_round_key(state, round_key);
        inv_mix_columns(state);
      end
      // 最后一轮
      inv_shift_rows(state);
      inv_sub_bytes(state);
      for (c = 0; c < 4; c++)
        round_key[c] = expanded_key[c];
      add_round_key(state, round_key);
      // 将状态矩阵打包成 128 位输出
      for (c = 0; c < 4; c++)
        for (r = 0; r < 4; r++)
          out[127 - ((4*c + r)*8) -: 8] = state[r][c];
      decrypt_block = out;
    end
  endfunction

  //--------------------------------------------------------------------------
  // 构造函数
  // 说明：输入参数 key_len 必须为 128、192 或 256，
  //       key 参数为 256 位向量，其中只有低 key_len 位有效
  //--------------------------------------------------------------------------
  function new(input int key_len, input logic [255:0] key);
    begin
      if ((key_len != 128) && (key_len != 192) && (key_len != 256)) begin
        $error("不支持的密钥长度：%0d", key_len);
      end
      this.key_len = key_len;
      if (key_len == 128) begin
        Nk = 4; Nr = 10;
      end else if (key_len == 192) begin
        Nk = 6; Nr = 12;
      end else if (key_len == 256) begin
        Nk = 8; Nr = 14;
      end
      key_expansion(Nk, Nr, key, key_len, expanded_key);
    end
  endfunction

  //--------------------------------------------------------------------------
  // 公共方法 encrypt
  // 作用：对 128 位明文进行加密，返回 128 位密文
  //--------------------------------------------------------------------------
  function automatic logic [127:0] encrypt(input logic [127:0] plaintext);
    encrypt = encrypt_block(plaintext);
  endfunction

  //--------------------------------------------------------------------------
  // 公共方法 decrypt
  // 作用：对 128 位密文进行解密，返回 128 位明文
  //--------------------------------------------------------------------------
  function automatic logic [127:0] decrypt(input logic [127:0] ciphertext);
    decrypt = decrypt_block(ciphertext);
  endfunction

endclass
