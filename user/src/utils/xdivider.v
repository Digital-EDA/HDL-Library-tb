/*
* xianjun.jiao@imec.be; putaoshu@msn.com
* DELAY: 36 cycles -- this is old parameter
* The new div_gen 5.x allow the valid signal, auto delay or manual delay config
*/
module xdivider (
    input clock,
    input reset,
    input enable,

    input signed [31:0] dividend,
    input signed [23:0] divisor,
    input input_valid,

    output signed [31:0] quotient,
    output output_valid
);

div_gen div_inst (
    .clk(clock),
    .dividend(dividend),
    .divisor(divisor),
    .input_strobe(input_valid),
    .output_strobe(output_valid),
    .quotient(quotient)
);

endmodule
