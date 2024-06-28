`timescale 1ns/100ps

`define ireal "/home/icer/Project/library/user/data/FFT/test/in/real.vec"
`define iimag "/home/icer/Project/library/user/data/FFT/test/in/imag.vec"
`define oreal "/home/icer/Project/library/user/data/FFT/test/out/oreal.vec"
`define oimag "/home/icer/Project/library/user/data/FFT/test/out/oimag.vec"

module FFT_IFFT_tb();

    localparam FFT_IFFT = 0;
    localparam SCALE_FACTOR = 2;
    localparam FFT_STAGE = 6;
    localparam CPMULT_DLY = 2;
    localparam DATA_WIDTH = 16;
    localparam FFT_MAX = 1<<FFT_STAGE;

    reg  iclk = 0;
    reg  rstn = 0;

    reg  ien = 0;
    reg  [DATA_WIDTH-1:0] iReal = 0;
    reg  [DATA_WIDTH-1:0] iImag = 0;

    wire oen;
    wire [DATA_WIDTH-1:0] oReal;
    wire [DATA_WIDTH-1:0] oImag;

    reg [DATA_WIDTH-1:0] Ireal_r [511:0];
    reg [DATA_WIDTH-1:0] Iimag_r [511:0];

    initial	begin		
        iclk <= 0;
        rstn <= 0;
        #20 rstn <= 1;

        forever
            #10 iclk = ~iclk;
    end

    initial begin
        ien = 1'b0;
        #1125 ien = 1'b1;
    end

    integer oreal, oimag;
    initial begin
        oreal  = $fopen(`oreal);
        oimag = $fopen(`oimag);
    end

    integer index = 0;
    initial begin
        $readmemh(`ireal, Ireal_r);
        $readmemh(`iimag, Iimag_r);
        #1092 
        repeat(1) begin
            for(index=0; index<511; index=index+1) begin
                #20
                iReal <= Ireal_r[index];
                iImag <= Iimag_r[index];
            end
        end
        #40 ien = 0;
    end

    FFT_IFFT #(
        .FFT_IFFT(FFT_IFFT),
        .ORDERING(1),
        .SCALE_FACTOR(SCALE_FACTOR),
        .TOTAL_STEP(FFT_STAGE),
        .CPMULT_DLY(CPMULT_DLY),
        .DATA_WIDTH(DATA_WIDTH)) 
    fft_ifft_ins (
        .iclk(iclk),
        .rstn(rstn),
        .iReal(iReal),
        .iImag(iImag),
        .ien(ien),
        .oReal(oReal),
        .oImag(oImag),
        .oen(oen)
    );

    // wire fft_ready;
    // wire fft_valid;
    // wire s_axis_config_tready;
    // wire m_axis_data_tlast;
    // wire fft_din_data_tlast_delayed;
    // wire event_frame_started;
    // wire event_tlast_unexpected;
    // wire event_tlast_missing;
    // wire event_status_channel_halt;
    // wire event_data_in_channel_halt;
    // wire event_data_out_channel_halt;

    // wire [22:0] fft_out_re;
    // wire [22:0] fft_out_im;
    // wire [15:0] fft_ore = fft_out_re[22:7];
    // wire [15:0] fft_oim = fft_out_im[22:7];
    // wire idle_line1;
    // wire idle_line2;

    // xfft_v9 dft_inst (
    //     .aclk(iclk),       // input wire aclk
    //     .aresetn(rstn),                                               
    //     .s_axis_config_tdata({7'b0, FFT_IFFT}),                         
    //     .s_axis_config_tvalid(1'b1),                               
    //     .s_axis_config_tready(s_axis_config_tready),   
    //     .s_axis_data_tdata({iImag, iReal}),                   
    //     .s_axis_data_tvalid(ien),                   
    //     .s_axis_data_tready(fft_ready),                   
    //     .s_axis_data_tlast(fft_din_data_tlast_delayed),                     
    //     .m_axis_data_tdata({idle_line1, fft_out_im, idle_line2, fft_out_re}),                 
    //     .m_axis_data_tvalid(fft_valid),                 
    //     .m_axis_data_tready(1'b1),                   
    //     .m_axis_data_tlast(m_axis_data_tlast),                     
    //     .event_frame_started(event_frame_started),             
    //     .event_tlast_unexpected(event_tlast_unexpected),         
    //     .event_tlast_missing(event_tlast_missing),               
    //     .event_status_channel_halt(event_status_channel_halt),   
    //     .event_data_in_channel_halt(event_data_in_channel_halt), 
    //     .event_data_out_channel_halt(event_data_out_channel_halt)
    // );

    // wire [15:0] ifft_ore;
    // wire [15:0] ifft_oim;
    // wire 	o_sync;

    // ifftmain u_ifftmain(
    //     //ports
    //     .i_clk    		( iclk    		        ),
    //     .i_reset  		( ~rstn  		        ),
    //     .i_ce     		( ien     		        ),
    //     .i_sample 		( {iReal, iImag}        ),
    //     .o_result 		( {ifft_ore, ifft_oim}  ),
    //     .o_sync   		( o_sync   		        )
    // );

    always @(posedge iclk) begin
        if (rstn & oen) begin
            $fdisplay(oreal, "%d", $signed(oReal));
            $fdisplay(oimag, "%d", $signed(oImag));
        end
    end

    // always @(posedge iclk) begin
    //     if (rstn & fft_valid) begin
    //         $fdisplay(xfft,  "%d, %d", $signed(fft_out_re[22:7]), $signed(fft_out_im[22:7]));
    //     end
    // end

    initial begin
        $dumpfile("/home/icer/Project/library/user/sim/Apply/DSP/FFT/IFFT.vcd");        
        $dumpvars(0, FFT_IFFT_tb); 
        #30000 $finish();
    end

endmodule
