`timescale 1ns/100ps

`define win 1

`ifdef win
    `define ireal "d:/project/ASIC/FFT_IFFT_IP/user/sim/test/in/real.vec"
    `define iimag "d:/project/ASIC/FFT_IFFT_IP/user/sim/test/in/imag.vec"
    `define oreal "d:/project/ASIC/FFT_IFFT_IP/user/sim/test/out/real.vec"
    `define oimag "d:/project/ASIC/FFT_IFFT_IP/user/sim/test/out/imag.vec"
`else
    `define ireal "/home/project/ASIC/FFT_IFFT_IP/user/sim/test/in/real.vec"
    `define iimag "/home/project/ASIC/FFT_IFFT_IP/user/sim/test/in/imag.vec"
    `define oreal "/home/project/ASIC/FFT_IFFT_IP/user/sim/test/out/real.vec"
    `define oimag "/home/project/ASIC/FFT_IFFT_IP/user/sim/test/out/imag.vec"
`endif

module FFT_IFFT_tb();

    localparam FFT_IFFT   = 0;
    localparam SCALE_KCOE = 1;
    localparam TOTAL_STEP = 5;
    localparam BUFLY_MODE = 0;
    localparam TWIDD_MODE = 1;
    localparam DATA_WIDTH = 16;
    localparam FFT_MAX = 1<<TOTAL_STEP;
    localparam MAIN_FRE = 100; //unit MHz

    reg  iclk = 1;
    reg  rstn = 0;

    reg  [DATA_WIDTH-1:0] Ireal_r [511:0];
    reg  [DATA_WIDTH-1:0] Iimag_r [511:0];

    reg  [10:0]  index;
    wire [DATA_WIDTH-1:0] iReal = Ireal_r[index];
    wire [DATA_WIDTH-1:0] iImag = Iimag_r[index];

    always begin
        #(500/MAIN_FRE) iclk <= ~iclk;
    end

    always begin
        #50 rstn <= 1;
    end

    integer oreal, oimag;
    initial begin
        oreal = $fopen(`oreal);
        oimag = $fopen(`oimag);
        $readmemb(`ireal, Ireal_r);
        $readmemb(`iimag, Iimag_r);
    end

    reg ien;
    always @(posedge iclk or negedge rstn) begin
        if (~rstn) begin
            ien <= 0;
        end
        else begin
            if (index >= 63) begin
                ien <= 0;
            end else begin
                ien <= 1;
            end
        end
    end

    always @(posedge iclk or negedge rstn) begin
        if (~rstn) begin
            index <= 0;
        end
        else begin
            if (ien) begin
                index <= index + 1;
            end
        end
    end

    wire oen;
    wire [DATA_WIDTH-1:0] oReal;
    wire [DATA_WIDTH-1:0] oImag;
    FFT_IFFT #(
        .FFT_IFFT(FFT_IFFT),
        .ORDERING(1),
        .SCALE_KCOE(SCALE_KCOE),
        .TOTAL_STEP(TOTAL_STEP),
        .BUFLY_MODE(BUFLY_MODE),
        .TWIDD_MODE(TWIDD_MODE),
        .DATA_WIDTH(DATA_WIDTH)) 
    fft_ifft_ins (
        .iclk(iclk),
        .rstn(rstn),
        .ien(ien),
        .iReal(iReal),
        .iImag(iImag),
        .oen(oen),
        .oReal(oReal),
        .oImag(oImag)
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
        $dumpfile("FFT_IFFT_tb.vcd");        
        $dumpvars(0, FFT_IFFT_tb); 
        #2000 $finish();
    end

endmodule
