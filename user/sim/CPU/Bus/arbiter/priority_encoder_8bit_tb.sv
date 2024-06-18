module priority_encoder_8bit_tb;

// 参数设置
parameter WIDTH             = 8;
parameter LSB_HIGH_PRIORITY = 1;

// 端口信号声明
reg  [WIDTH-1:0]            input_unencoded;
wire                        output_valid;
wire [$clog2(WIDTH)-1:0]    output_encoded;
wire [WIDTH-1:0]            output_unencoded;

// 实例化被测试模块
priority_encoder #(
    .WIDTH(WIDTH),
    .LSB_HIGH_PRIORITY(LSB_HIGH_PRIORITY)
) uut (
    .input_unencoded(input_unencoded),
    .output_valid(output_valid),
    .output_encoded(output_encoded),
    .output_unencoded(output_unencoded)
);

// 测试过程
initial begin

$display("-------------------------------------------------");
$display("Module: Priority Encoder");
$display("Parameters:");
$display("\tWIDTH \t\t\t= %0d", WIDTH);
$display("\tLSB_HIGH_PRIORITY \t= %0d", LSB_HIGH_PRIORITY);
$display("-------------------------------------------------");

// 初始化输入信号
input_unencoded = 8'b00000000;

// 等待一段时间观察初始化状态
#10;
$display("Test Case 1: input_unencoded = %b, output_valid = %b, output_encoded = %b, output_unencoded = %b",
            input_unencoded, output_valid, output_encoded, output_unencoded);

// 测试用例 1
input_unencoded = 8'b00000001;
#10;
$display("Test Case 2: input_unencoded = %b, output_valid = %b, output_encoded = %b, output_unencoded = %b",
            input_unencoded, output_valid, output_encoded, output_unencoded);

// 测试用例 2
input_unencoded = 8'b00000010;
#10;
$display("Test Case 3: input_unencoded = %b, output_valid = %b, output_encoded = %b, output_unencoded = %b",
            input_unencoded, output_valid, output_encoded, output_unencoded);

// 测试用例 3
input_unencoded = 8'b00000100;
#10;
$display("Test Case 4: input_unencoded = %b, output_valid = %b, output_encoded = %b, output_unencoded = %b",
            input_unencoded, output_valid, output_encoded, output_unencoded);

// 测试用例 4
input_unencoded = 8'b00001000;
#10;
$display("Test Case 5: input_unencoded = %b, output_valid = %b, output_encoded = %b, output_unencoded = %b",
            input_unencoded, output_valid, output_encoded, output_unencoded);

// 测试用例 5
input_unencoded = 8'b00010000;
#10;
$display("Test Case 6: input_unencoded = %b, output_valid = %b, output_encoded = %b, output_unencoded = %b",
            input_unencoded, output_valid, output_encoded, output_unencoded);

// 测试用例 6
input_unencoded = 8'b00100000;
#10;
$display("Test Case 7: input_unencoded = %b, output_valid = %b, output_encoded = %b, output_unencoded = %b",
            input_unencoded, output_valid, output_encoded, output_unencoded);

// 测试用例 7
input_unencoded = 8'b01000000;
#10;
$display("Test Case 8: input_unencoded = %b, output_valid = %b, output_encoded = %b, output_unencoded = %b",
            input_unencoded, output_valid, output_encoded, output_unencoded);

// 测试用例 8
input_unencoded = 8'b10000000;
#10;
$display("Test Case 9: input_unencoded = %b, output_valid = %b, output_encoded = %b, output_unencoded = %b",
            input_unencoded, output_valid, output_encoded, output_unencoded);

// 测试用例 9
input_unencoded = 8'b11000000;
#10;
$display("Test Case 10: input_unencoded = %b, output_valid = %b, output_encoded = %b, output_unencoded = %b",
            input_unencoded, output_valid, output_encoded, output_unencoded);

// 测试用例 10
input_unencoded = 8'b00110000;
#10;
$display("Test Case 11: input_unencoded = %b, output_valid = %b, output_encoded = %b, output_unencoded = %b",
            input_unencoded, output_valid, output_encoded, output_unencoded);

// 测试用例 11
input_unencoded = 8'b00001111;
#10;
$display("Test Case 12: input_unencoded = %b, output_valid = %b, output_encoded = %b, output_unencoded = %b",
            input_unencoded, output_valid, output_encoded, output_unencoded);

// 测试用例 12
input_unencoded = 8'b11111111;
#10;
$display("Test Case 13: input_unencoded = %b, output_valid = %b, output_encoded = %b, output_unencoded = %b",
            input_unencoded, output_valid, output_encoded, output_unencoded);

// 结束模拟
$finish;

end

initial begin
    $dumpfile("./sim/priority_encoder_8bit.vcd");
    $dumpvars(0, priority_encoder_8bit_tb);
    #1000 
    $finish;
end


endmodule