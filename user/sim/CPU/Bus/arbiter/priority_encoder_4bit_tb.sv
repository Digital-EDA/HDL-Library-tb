module priority_encoder_4bit_tb;

// 参数设置
parameter WIDTH             = 4;
parameter LSB_HIGH_PRIORITY = 0;

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
input_unencoded = 4'b0000;

// 等待一段时间观察初始化状态
#10;
$display("Test Case 1: input_unencoded = %b, output_valid = %b, output_encoded = %b, output_unencoded = %b",
            input_unencoded, output_valid, output_encoded, output_unencoded);

// 测试用例 1
input_unencoded = 4'b0001;
#10;
$display("Test Case 2: input_unencoded = %b, output_valid = %b, output_encoded = %b, output_unencoded = %b",
            input_unencoded, output_valid, output_encoded, output_unencoded);

// 测试用例 2
input_unencoded = 4'b0010;
#10;
$display("Test Case 3: input_unencoded = %b, output_valid = %b, output_encoded = %b, output_unencoded = %b",
            input_unencoded, output_valid, output_encoded, output_unencoded);

// 测试用例 3
input_unencoded = 4'b0100;
#10;
$display("Test Case 4: input_unencoded = %b, output_valid = %b, output_encoded = %b, output_unencoded = %b",
            input_unencoded, output_valid, output_encoded, output_unencoded);

// 测试用例 4
input_unencoded = 4'b1000;
#10;
$display("Test Case 5: input_unencoded = %b, output_valid = %b, output_encoded = %b, output_unencoded = %b",
            input_unencoded, output_valid, output_encoded, output_unencoded);

// 测试用例 5
input_unencoded = 4'b1100;
#10;
$display("Test Case 6: input_unencoded = %b, output_valid = %b, output_encoded = %b, output_unencoded = %b",
            input_unencoded, output_valid, output_encoded, output_unencoded);

// 测试用例 6
input_unencoded = 4'b1010;
#10;
$display("Test Case 7: input_unencoded = %b, output_valid = %b, output_encoded = %b, output_unencoded = %b",
            input_unencoded, output_valid, output_encoded, output_unencoded);

// 测试用例 7
input_unencoded = 4'b0110;
#10;
$display("Test Case 8: input_unencoded = %b, output_valid = %b, output_encoded = %b, output_unencoded = %b",
            input_unencoded, output_valid, output_encoded, output_unencoded);

// 结束模拟
$finish;
end

initial begin
    $dumpfile("./sim/priority_encoder_4bit.vcd");
    $dumpvars(0, priority_encoder_4bit_tb);
    #1000 
    $finish;
end


endmodule