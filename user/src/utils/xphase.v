module xphase
#(
    parameter DATA_WIDTH = 32
)
(
    input clock,
    input reset,
    input enable,

    input signed [DATA_WIDTH-1:0] in_i,
    input signed [DATA_WIDTH-1:0] in_q,
    input input_strobe,

    // [-pi, pi) scaled up by 512
    output reg signed [15:0] phase,
    output output_strobe
);
localparam PI =             1608;       //  = PI*(1<<`ATAN_LUT_SCALE_SHIFT)
localparam DOUBLE_PI =      PI<<1;
localparam PI_2 =           PI>>1;
localparam PI_4 =           PI>>2;
localparam PI_3_4 =         PI_2 + PI_4;
reg [DATA_WIDTH-1:0] in_i_delay;
reg [DATA_WIDTH-1:0] in_q_delay;
reg [DATA_WIDTH-1:0] abs_i;
reg [DATA_WIDTH-1:0] abs_q;
reg [DATA_WIDTH-1:0] max;
reg [DATA_WIDTH-1:0] min;
wire [DATA_WIDTH-1:0] dividend;
wire [DATA_WIDTH-9-1:0] divisor;
assign dividend = (max > 4194304) ? min                                   : {min[DATA_WIDTH-9-1:0], {9{1'b0}}};
assign divisor  = (max > 4194304) ? max[DATA_WIDTH-1:9] :  max[DATA_WIDTH-9-1:0];

wire div_in_stb;

wire [31:0] quotient;
wire div_out_stb;

wire [9-1:0] atan_addr;
wire [9-1:0] atan_data;

assign atan_addr = (quotient>511?511:quotient[9-1:0]);
wire signed [9:0] _phase = {1'b0, atan_data};

reg [2:0] quadrant;
wire [2:0] quadrant_delayed;

// 1 cycle for abs
// 1 cycle for quadrant
delayT #(.DATA_WIDTH(1), .DELAY(2)) div_in_inst (
    .clock(clock),
    .reset(reset),

    .data_in(input_strobe),
    .data_out(div_in_stb)
);

// 1 cycle for atan_lut
// 1 cycle for quadrant_delayed
delayT #(.DATA_WIDTH(1), .DELAY(2)) output_inst  (
    .clock(clock),
    .reset(reset),

    .data_in(div_out_stb),
    .data_out(output_strobe)
);


xdivider div_inst (
    .clock(clock),
    .enable(enable),
    .reset(reset),

    .dividend(dividend),
    .divisor({{(9-8){1'b0}}, divisor}),
    .input_valid(div_in_stb),

    .quotient(quotient),
    .output_valid(div_out_stb)
);

delayT #(.DATA_WIDTH(3), .DELAY(37)) quadrant_inst  (
    .clock(clock),
    .reset(reset),

    .data_in(quadrant),
    .data_out(quadrant_delayed)
);

atan_lut lut_inst (
    .clka(clock),
    .addra(atan_addr),
    .douta(atan_data)
);


always @(posedge clock) begin
    if (reset) begin
        max <= 0;
        min <= 0;
        abs_i <= 0;
        abs_q <= 0;
        in_i_delay <= 0;
        in_q_delay <= 0;
    end else if (enable) begin
        // 1st cycle
        abs_i <= in_i[DATA_WIDTH-1]? ~in_i+1: in_i;
        abs_q <= in_q[DATA_WIDTH-1]? ~in_q+1: in_q;
        in_i_delay <= in_i;
        in_q_delay <= in_q;

        // 2nd cycle
        if (abs_i >= abs_q) begin
            quadrant <= {in_i_delay[DATA_WIDTH-1], in_q_delay[DATA_WIDTH-1], 1'b0};
            max <= abs_i;
            min <= abs_q;
        end else begin
            quadrant <= {in_i_delay[DATA_WIDTH-1], in_q_delay[DATA_WIDTH-1], 1'b1};
            max <= abs_q;
            min <= abs_i;
        end

        case(quadrant_delayed)
            3'b000: phase <= _phase;            // [0, PI/4]
            3'b001: phase <= PI_2 - _phase;     // [PI/4, PI/2]
            3'b010: phase <= -_phase;           // [-PI/4, 0]
            3'b011: phase <= _phase - PI_2;     // [-PI/2, -Pi/4]
            3'b100: phase <= PI - _phase;       // [3/4PI, PI]
            3'b101: phase <= PI_2 + _phase;     // [PI/2, 3/4PI]
            3'b110: phase <= _phase - PI;       // [-3/4PI, -PI]
            3'b111: phase <= -PI_2 - _phase;    // [-PI/2, -3/4PI]
        endcase
    end
end

endmodule
