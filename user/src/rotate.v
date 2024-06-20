module rotate #(
        parameter ROTATE_WIDTH = 9,
        parameter ROTATE_SCALE = 11
    )(
        input  clock,
        input  reset,

        input  [15:0] phase,

        input  [31:0]             rot_data,
        output [ROTATE_WIDTH-1:0] rot_addr,

        input  ivalid,
        input  [15:0] in_i,
        input  [15:0] in_q,

        output ovalid,
        output [15:0] out_i,
        output [15:0] out_q
    );
    //////////////////////////////////////////////////////////////////////////
    // OPI DEFINITION
    //////////////////////////////////////////////////////////////////////////
    localparam OPI  = 1608;            
    localparam DPI  = OPI<<1;
    localparam HPI  = OPI>>1;
    localparam QPI  = OPI>>2;
    localparam TQPI = HPI + QPI;

    reg [15:0]  phase_buf;
    reg [15:0]  phase_abs;
    reg [15:0]  phase_act;

    reg [2:0]   quadrant;
    reg [2:0]   quadrant_buf;

    wire [31:0] p_i;
    wire [31:0] p_q;

    reg [15:0]  rot_i;
    reg [15:0]  rot_q;

    wire [15:0] raw_rot_i;
    wire [15:0] raw_rot_q;

    assign raw_rot_i = rot_data[31:16];
    assign raw_rot_q = rot_data[15:0];

    always @(posedge clock or posedge reset) begin
        if (reset) begin
            quadrant <= 0;
            quadrant_buf <= 0;

            rot_i <= 0;
            rot_q <= 0;

            phase_act <= 0;
            phase_abs <= 0;
            phase_buf <= 0;
        end 
        else if (ivalid) begin
            // if (phase > OPI || phase < -OPI) begin
            //     $display("[WARN] phase overflow: %d\n", phase);
            // end

            // cycle 1
            phase_abs <= phase[15] ? (~phase+1) : phase;
            phase_buf <= phase;

            // cycle 2
            if (phase_abs <= QPI) begin
                quadrant <= {phase_buf[15], 2'b00};
                phase_act <= phase_abs;
            end 
            else if (phase_abs <= HPI) begin
                quadrant <= {phase_buf[15], 2'b01};
                phase_act <= HPI - phase_abs;
            end 
            else if (phase_abs <= TQPI) begin
                quadrant <= {phase_buf[15], 2'b10};
                phase_act <= phase_abs - HPI;
            end 
            else begin
                quadrant <= {phase_buf[15], 2'b11};
                phase_act <= OPI - phase_abs;
            end

            // cycle 3
            // wait for raw_rot_i
            quadrant_buf <= quadrant;

            // cycle 4
            case(quadrant_buf)
                3'b000: begin
                    rot_i <= raw_rot_i;
                    rot_q <= raw_rot_q;
                end
                3'b001: begin
                    rot_i <= raw_rot_q;
                    rot_q <= raw_rot_i;
                end
                3'b010: begin
                    rot_i <= ~raw_rot_q+1;
                    rot_q <= raw_rot_i;
                end
                3'b011: begin
                    rot_i <= ~raw_rot_i+1;
                    rot_q <= raw_rot_q;
                end
                3'b100: begin
                    rot_i <= raw_rot_i;
                    rot_q <= ~raw_rot_q+1;
                end
                3'b101: begin
                    rot_i <= raw_rot_q;
                    rot_q <= ~raw_rot_i+1;
                end
                3'b110: begin
                    rot_i <= ~raw_rot_q+1;
                    rot_q <= ~raw_rot_i+1;
                end
                3'b111: begin
                    rot_i <= ~raw_rot_i+1;
                    rot_q <= ~raw_rot_q+1;
                end
            endcase
        end
    end

    assign rot_addr = phase_act[ROTATE_WIDTH-1:0];

    // delay 3
    wire 	    mvalid;
    wire [15:0] in_i_buf;
    wire [15:0] in_q_buf;

    shiftTaps #(
        .WIDTH 		( 32   		),
        .SHIFT 		( 3 		))
    u_shiftTaps(
        //ports
        .clock    		( clock    		                ),
        .reset    		( reset    		                ),
        .ivalid   		( ivalid   		                ),
        .shiftin  		( {in_i, in_q}          ),
        .ovalid         ( mvalid ),
        .shiftout 		( {in_i_buf, in_q_buf}  )
    );


    cmplMult #(
        .SCALE_FACTOR 		( 0  ),
        .REAL_WIDTH_A 		( 16 ),
        .IMGN_WIDTH_A 		( 16 ),
        .REAL_WIDTH_B 		( 16 ),
        .IMGN_WIDTH_B 		( 16 ),
        .REAL_WIDTH_O 		( 32 ),
        .IMGN_WIDTH_O 		( 32 ))
    u_cmplMult(
        //ports
        .clock    		( clock    ),
        .reset    		( reset    ),

        .ivalid   		( mvalid   ),
        .dataa_r  		( in_i_buf ),
        .dataa_i  		( in_q_buf ),
        .datab_r  		( rot_i    ),
        .datab_i  		( rot_q    ),
        .ovalid   		( ovalid   ),
        .result_r 		( p_i      ),
        .result_i 		( p_q      )
    );

    assign out_i = p_i[ROTATE_SCALE + 15 : ROTATE_SCALE];
    assign out_q = p_q[ROTATE_SCALE + 15 : ROTATE_SCALE];

endmodule
