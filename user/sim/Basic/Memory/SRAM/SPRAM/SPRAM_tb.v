module SPRAM_tb();

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
    SPRAM #(
        .MODE(  0        ),
        .DEPTH( 1<<STEP  ),
        .WIDTH( WIDTH    )) 
    mem (
        .clka(clock),
        .ena(~reset),
        .wea(wen),
        .addra(waddr),
        .dina(din),
        .douta(dout)
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
        waddr = 0;
        raddr = 0;
        din = 0;

        // Apply reset
        #15;

        // 写模式
        wen = 1;
        waddr = 0;
        din = 8'ha0;
        #10;

        wen = 1;
        waddr = 0;
        din = 8'hb0;
        #10;

        wen = 1;
        waddr = 1;
        din = 8'ha1;
        #10;

        // 读模式
        wen = 0;
        waddr = 0;
        din = 8'ha2;
        #10;

        wen = 0;
        waddr = 1;
        din = 8'ha3;
        #10;

        // 失能
        reset = 1;
        #40

        // 结束仿真
        $display("Simulation finished successfully.");
        $finish;
    end

    initial begin
        $dumpfile("SPRAM.vcd");        
        $dumpvars(0, SPRAM_tb);
    end

endmodule
