module divider #(
    parameter QUOTIENT = 32,
    parameter DIVIDEND = 32,
    parameter DIVISOR = 24
) (
    input clock,
    input reset,

    input ivalid,
    input signed [DIVIDEND-1:0] dividend,
    input signed [DIVISOR-1:0] divisor,

    output reg ovalid,
    output reg signed [QUOTIENT-1:0] quotient
);

    // Pipeline registers
    reg signed [DIVIDEND-1:0] dividend_reg [0:5];
    reg signed [DIVISOR-1:0] divisor_reg [0:5];
    reg signed [DIVIDEND+DIVISOR-1:0] remainder [0:5];
    reg signed [QUOTIENT-1:0] quotient_reg [0:5];
    reg valid_reg [0:5];

    integer i;
    always @(posedge clock or posedge reset) begin
        if (reset) begin
            for (i = 0; i < 6; i = i + 1) begin
                dividend_reg[i] <= 0;
                divisor_reg[i] <= 0;
                remainder[i] <= 0;
                quotient_reg[i] <= 0;
                valid_reg[i] <= 0;
            end
            ovalid <= 0;
            quotient <= 0;
        end 
        else begin
            // Shift pipeline registers
            for (i = 0; i < 5; i = i + 1) begin
                dividend_reg[i+1] <= dividend_reg[i];
                divisor_reg[i+1] <= divisor_reg[i];
                remainder[i+1] <= remainder[i];
                quotient_reg[i+1] <= quotient_reg[i];
                valid_reg[i+1] <= valid_reg[i];
            end

            // Initialize the first stage
            if (ivalid) begin
                dividend_reg[0] <= dividend;
                divisor_reg[0] <= divisor;
                remainder[0] <= dividend;
                quotient_reg[0] <= 0;
                valid_reg[0] <= 1;
            end 
            else begin
                valid_reg[0] <= 0;
            end

            // Perform division steps
            for (i = 0; i < 5; i = i + 1) begin
                if (valid_reg[i]) begin
                    if (remainder[i] >= (divisor_reg[i] << (DIVIDEND - i - 1))) begin
                        remainder[i+1] <= remainder[i] - (divisor_reg[i] << (DIVIDEND - i - 1));
                        quotient_reg[i+1] <= quotient_reg[i] | (1 << (DIVIDEND - i - 1));
                    end 
                    else begin
                        remainder[i+1] <= remainder[i];
                        quotient_reg[i+1] <= quotient_reg[i];
                    end
                end
            end

            // Output the result
            if (valid_reg[5]) begin
                quotient <= quotient_reg[5];
                ovalid <= 1;
            end 
            else begin
                ovalid <= 0;
            end
        end
    end

endmodule
