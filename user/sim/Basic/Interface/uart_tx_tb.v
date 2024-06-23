module uart_tx_tb();
    
    reg        CLK_50M;
    reg        RST_N;
    reg [7:0]  data;
    reg        valid;
        
    uart_tx u1_uart_tx(
        .data          (data),
        .valid         (valid),
        .clk           (CLK_50M),
        .rst_n         (RST_N),
        .tx            (),
        .ready         ()
    );
    
    defparam u1_uart_tx.BAUD_CNT = 10;
    
    always #10 CLK_50M  <= ~CLK_50M;
    
    initial begin
        CLK_50M <= 1'b0;
        RST_N   <= 1'b0;
        data    <= 8'b0;
        valid <= 1'b0;
        #100
        RST_N   <= 1'b1;
        valid <= 1'b1;
        data    <= 8'b10111001;
        #20
        valid <= 1'b0;
        #2500
        valid <= 1'b1;
        #20
        valid <= 1'b0;
    end

    initial begin
        $dumpfile("./sim/uart_tx_tb.vcd");
        $dumpvars(0, uart_tx_tb);
        #100000
        $finish;
    end
endmodule
 