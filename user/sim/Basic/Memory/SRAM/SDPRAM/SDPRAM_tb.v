module SDPRAM_tb();

    // Parameters
    parameter WIDTH = 8;  // 数据宽度
    parameter STEP = 2;   // 地址宽度

    // Signals
    reg clock = 0;
    reg reset = 0;
    reg wen = 0;
    reg ren = 0;
    reg [STEP:0] waddr = 0;
    reg [STEP:0] raddr = 0;
    reg [WIDTH-1:0] din = 0;
    wire [WIDTH-1:0] dout;

    // Instantiate memory module
    // 替换为实际的存储器模块实例化
    SDPRAM #(
        .DEPTH( 1<<STEP  ),
        .WIDTH( WIDTH    )) 
    mem (
        .clock(clock),
        .reset(reset),
        .wen(wen),
        .ren(ren),
        .waddr(waddr),
        .raddr(raddr),
        .din(din),
        .dout(dout)
    );

    // Clock generation
    always #5 clock = ~clock;  // 假设时钟周期为10个时间单位

    // Testbench stimulus
    initial begin
        // 模拟复位
        reset = 1;
        #20;
        reset = 0;
        #20;

        // Initialize inputs
        wen = 0;
        ren = 0;
        waddr = 0;
        raddr = 0;
        din = 0;

        // Apply reset
        #15;

        // 同时读写同一地址
        wen = 1;
        ren = 1;
        waddr = 0;
        raddr = 0;
        din = 8'ha0;
        #10;

        // 同时读写同一地址不同的值  
        wen = 1;
        ren = 1;
        waddr = 0;
        raddr = 0;
        din = 8'ha1;
        #10;

        // 同时读写不同一地址
        wen = 1;
        ren = 1;
        waddr = 1;
        raddr = 2;
        din = 8'ha2;
        #10;

        wen = 1;
        ren = 1;
        waddr = 1;
        raddr = 0;
        din = 8'ha2;
        #10;

        // 只写不读
        wen = 1;
        ren = 0;
        waddr = 1;
        raddr = 1;
        din = 8'ha3;
        #10;

        // 只读不写
        wen = 0;
        ren = 1;
        waddr = 2;
        raddr = 0;
        din = 8'ha4;
        #10;

        // 结束仿真
        $display("Simulation finished successfully.");
        $finish;
    end

    initial begin
        $dumpfile("SDPRAM.vcd");        
        $dumpvars(0, SDPRAM_tb);
    end

endmodule
