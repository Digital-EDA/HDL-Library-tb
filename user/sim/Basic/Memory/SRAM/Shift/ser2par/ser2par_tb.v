`timescale 1ns/1ps

module ser2par_tb();

    // Inputs
    reg clock;
    reg enable;
    reg reset;
    reg ivalid;
    reg idata;

    // Outputs
    wire ovalid;
    wire [7:0] odata; // LENGTH = 8 for this test

    // Instantiate the Unit Under Test (UUT)
    ser2par #(
        .LENGTH(8)) 
    u_ser2par (
        .clock(clock),
        .enable(enable),
        .reset(reset),
        .direct(0),

        .ivalid(clock),
        .idata(idata),

        .ovalid(ovalid),
        .odata(odata)
    );

    // 时钟生成
    always #5 clock = ~clock; // 10ns 时钟周期

    initial begin
        // 初始化输入
        clock = 0;
        enable = 0;
        reset = 1;
        ivalid = 0;
        idata = 0;

        // 释放复位
        #10;
        reset = 0;
        enable = 1;

        // 输入串行数据 (例如：8'b11010101)
        ivalid = 1;
        idata = 1; #10;
        idata = 0; #10;
        idata = 1; #10;
        idata = 0; #10;
        idata = 1; #10;
        idata = 0; #10;
        idata = 1; #10;
        idata = 1; #10;

        // 停止串行输入
        // ivalid = 0;
        idata = 1; #10;
        idata = 0; #10;
        idata = 1; #10;
        idata = 1; #10;
        idata = 1; #10;
        idata = 0; #10;
        idata = 1; #10;
        idata = 1; #10;

        // 等待一段时间以观察输出
        #20;

        // 结束仿真
        $finish;
    end

    // 监控信号
    initial begin
        $dumpfile("ser2par.vcd");        
        $dumpvars(0, ser2par_tb);   
        $monitor("Time: %0t | clock: %b | reset: %b | enable: %b | ivalid: %b | idata: %b | ovalid: %b | odata: %b", 
                 $time, clock, reset, enable, ivalid, idata, ovalid, odata);
    end

endmodule
