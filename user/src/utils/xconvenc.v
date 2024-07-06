/*
*   Date : 
*   Author : Nitcloud
*   Called by : 2024-06-17
*   Revision Historyc : v0.1
*   Revision : 
*   Description : Convolutional Encoder ( n = 2, k = 1, N = 7 )
*   Company : ncai Technology .Inc
*   Copyright(c) 1999, ncai Technology Inc, All right reserved
*/
module xconvenc(
        input  wire         clk,
        input  wire         rst,

        input  wire         enc_en,
        input  wire         bit_in,
        output wire [1:0]   bits_out
    );

    reg [5:0] state;
    always @(posedge clk) begin      
        if (rst) begin
            state <= 0;
        end 
        else if(enc_en) begin
            state <= {state[4:0], bit_in};
        end
    end

    // SA = 1 + X^1 + X^2 + X^3 + X^6 ---- g0 = 1111001 = (171)_8
    assign bits_out[0] = bit_in ^ state[0] ^ state[1] ^ state[2] ^ state[5];

    // SB = 1 + X^2 + X^3 + X^5 + X^6 ---- g1 = 1011011 = (133)_8
    assign bits_out[1] = bit_in ^ state[1] ^ state[2] ^ state[4] ^ state[5];

endmodule
