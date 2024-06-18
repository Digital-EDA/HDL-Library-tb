`timescale 1ns / 1ps

module arbiter_rr4_tb;

// 参数定义
parameter PORTS = 4;
parameter ARB_TYPE_ROUND_ROBIN = 1;
parameter ARB_BLOCK = 0;
parameter ARB_BLOCK_ACK = 1;
parameter ARB_LSB_HIGH_PRIORITY = 0;

// 信号定义
reg clk;
reg rst;
reg [PORTS - 1 : 0] request;
reg [PORTS - 1 : 0] acknowledge;
wire [PORTS - 1 : 0] grant;
wire grant_valid;
wire [$clog2(PORTS)-1:0] grant_encoded;
reg [511:0] test_case; // 当前测试用例描述

// 仲裁器实例化
arbiter #(
    .PORTS(PORTS),
    .ARB_TYPE_ROUND_ROBIN(ARB_TYPE_ROUND_ROBIN),
    .ARB_BLOCK(ARB_BLOCK),
    .ARB_BLOCK_ACK(ARB_BLOCK_ACK),
    .ARB_LSB_HIGH_PRIORITY(ARB_LSB_HIGH_PRIORITY)
) uut (
    .clk(clk),
    .rst(rst),
    .request(request),
    .acknowledge(acknowledge),
    .grant(grant),
    .grant_valid(grant_valid),
    .grant_encoded(grant_encoded)
);

// 时钟生成
initial begin
    clk = 0;
    forever #1 clk = ~clk;
end

// 复位信号
initial begin
    rst = 1;
    #20;
    rst = 0;
end

// 测试用例
initial begin

$display("-------------------------------------------------");
$display("Module: Arbiter");
$display("Parameters:");
$display("\tPORTS \t\t\t= %0d", PORTS);
$display("\tARB_TYPE_ROUND_ROBIN \t= %0d", ARB_TYPE_ROUND_ROBIN);
$display("\tARB_BLOCK \t\t= %0d", ARB_BLOCK);
$display("\tARB_BLOCK_ACK \t\t= %0d", ARB_BLOCK_ACK);
$display("\tARB_LSB_HIGH_PRIORITY \t= %0d", ARB_LSB_HIGH_PRIORITY);
$display("-------------------------------------------------");



// 初始化
request = 0;
acknowledge = 0;
test_case = "Initial state";

// 等待复位结束
#30;

// 测试用例 1: 单个请求
test_case = "Test Case 1: Single request";
#10;
request[0] = 1;
#10;
request[0] = 0;
#10;


// 测试用例 2: 多个请求
test_case = "Test Case 2: Multiple requests";
#10;
request = 4'b1010;
#10;
request = 4'b0101;
#10;
request = 0;
#10;

// 测试用例 4: 轮询仲裁
test_case = "Test Case 4: Round-robin arbitration";
#10;
request = 4'b1111;
#50;
request = 0;
#10;

// 测试用例结束
$finish;

end



// 输出信号监视
initial begin
    $monitor("Time: %0d, Request: %b, Acknowledge: %b, Grant: %b, Grant Valid: %b, Grant Encoded: %d", 
              $time, request, acknowledge, grant, grant_valid, grant_encoded);
end

// 输出测试用例信息
always @(test_case) begin
    #1; // 等待一个时间单位，以确保监视器输出正确
    $display("");
    $display("-----------------------------------------------------------------------------");
    $display("Time: %0d, %s", $time, test_case);
    $display("-----------------------------------------------------------------------------");
end

initial begin
    $dumpfile("./sim/arbiter_rr4_tb.vcd");
    $dumpvars(0, arbiter_rr4_tb);
    #1000 
    $finish;
end

endmodule
