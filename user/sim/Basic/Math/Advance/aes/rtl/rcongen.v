module rcongen(
        input [7:0] i,
        output [7:0] o,
        input bypass,
        input mode);
    function [7:0] xtime(input	[7:0] x);
        begin
            // Multiplication by 2 over GF(256)
            // Refer to FIPS-197 spec section 4.2.1 on definition of GF(256) multiplication
            xtime = (x[7])? (x<<1) ^ 8'h1b : x<<1;
        end
    endfunction
    function [7:0] GFmul4(input	[7:0] x);
        begin
            // Multiply by 4 over GF(256)
            // 4*x = 2*(2*x)
            GFmul4 = xtime(xtime(x));
        end
    endfunction

    function [7:0] GFmul8(input	[7:0] x);
        begin
            // Multiply by 8 over GF(256)
            // 8*x = 2*(4*x)
            GFmul8 = xtime(GFmul4(x));
        end
    endfunction

    function [7:0] GFmuld(input	[7:0] x);
        begin
            // Multiply by 0xd over GF(256)
            // d*x = 8*x + 4*x + x
            GFmuld = GFmul8(x) ^ GFmul4(x) ^ x;
        end
    endfunction
    function [7:0] GFmulf(input	[7:0] x);
        begin
            // Multiply by 0xf over GF(256)
            // e*x = 8*x + 4*x +2*x + x
            GFmulf = GFmul8(x) ^ GFmul4(x) ^ xtime(x) ^ x;
        end
    endfunction
    function [7:0] GFmul80(input	[7:0] x);
        begin
            // Multiply by 0xf over GF(256)
            // f*x = 8*x + 4*x +2*x + x
            //   GFmul80 = GFmul8(GFmul8(x) ^ GFmul4(x) ^ xtime(x) ^ x);
            GFmul80 = GFmul8(xtime(GFmul8(x)));
        end
    endfunction
    function [7:0] GFmul8d(input	[7:0] x);
        begin
            // Multiply by 0xf over GF(256)
            // f*x = 8*x + 4*x +2*x + x
            GFmul8d = GFmul80(x) ^ GFmuld(x);
        end
    endfunction
    // assign o = shiftmode ?  {{1'b0},i[7:1]} : {i[6:0],{1'b0}};

    assign o = bypass ? i : mode ? GFmul8d(i) : xtime(i);

endmodule
