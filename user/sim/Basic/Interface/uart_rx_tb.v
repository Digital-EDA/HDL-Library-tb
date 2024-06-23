module uart_rx_tb();
    
    reg        CLK_50M;
    reg        RST_N;
    
    wire [7:0] data;    
    reg        rx;
    reg  [7:0] test_data;
    wire       ready;

    uart_rx #(
        .RX_BAUD   (9600),
        .CLK_FQC   (50_000_000),
        .BAUD_CNT  (50)
    ) u1_uart_rx (
        .clk        (CLK_50M),
        .rst_n      (RST_N),
        .rx         (rx),
        .data       (data),
        .ready      (ready)
    );
    
    always #10 CLK_50M  <= ~CLK_50M;
    
    initial begin
        CLK_50M <= 1'b0;
        RST_N   <= 1'b0;
        rx <= 1'b1;
        test_data <= 8'h0;
        #100
        RST_N   <= 1'b1;
        #20
        test_data <= 8'haf;
        #1000
        rx <= 1'b0;
        #1000             
        rx <= test_data[0];
        #1000             
        rx <= test_data[1];
        #1000             
        rx <= test_data[2];
        #1000             
        rx <= test_data[3];
        #1000             
        rx <= test_data[4];
        #1000             
        rx <= test_data[5];
        #1000             
        rx <= test_data[6];
        #1000             
        rx <= test_data[7];
        #1000             
        rx <= 1'b1;
        test_data <= 8'h56;
        #1000
        rx <= 1'b0;
        #1000             
        rx <= test_data[0];
        #1000             
        rx <= test_data[1];
        #1000             
        rx <= test_data[2];
        #1000             
        rx <= test_data[3];
        #1000             
        rx <= test_data[4];
        #1000             
        rx <= test_data[5];
        #1000             
        rx <= test_data[6];
        #1000             
        rx <= test_data[7];
        #1000             
        rx <= 1'b1;
    end

    initial begin
        $dumpfile("./sim/uart_rx_tb.vcd");
        $dumpvars(0, uart_rx_tb);
        #100000
        $finish;
    end
    
endmodule