module complex_to_mag_sq (
        input clock,
        input enable,
        input reset,

        input signed [15:0] i,
        input signed [15:0] q,
        input input_valid,

        output [31:0] mag_sq,
        output mag_sq_valid
    );

    reg valid_in;
    reg [15:0] input_i;
    reg [15:0] input_q;
    reg [15:0] input_q_neg;

    complex_mult mult_inst (
        .clock(clock),
        .reset(reset),
        .enable(enable),
        
        .a_i(input_i),
        .a_q(input_q),
        .b_i(input_i),
        .b_q(input_q_neg),
        .input_valid(valid_in),

        .p_i(mag_sq),
        .output_valid(mag_sq_valid)
    );

    always @(posedge clock) begin
        if (reset) begin
            input_i <= 0;
            input_q <= 0;
            input_q_neg <= 0;
            valid_in <= 0;
        end else if (enable) begin
            valid_in <= input_valid;
            input_i <= i;
            input_q <= q;
            input_q_neg <= ~q+1;
        end
    end
    
endmodule
