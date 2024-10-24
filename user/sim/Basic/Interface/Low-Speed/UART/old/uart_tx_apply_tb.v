module uart_tx_apply_tb();

    reg        CLK_50M;
    reg        RST;
 
    uart_tx_apply u1_uart_tx_apply(
        .clk            (CLK_50M),
        .rst            (RST),
        .tx             ()
    );
    
    defparam u1_uart_tx_apply.u1_uart_tx.BAUD_CNT = 10;
    defparam u1_uart_tx_apply.CNT_10MS            = 50;
    
    always #10 CLK_50M  <= ~CLK_50M;
    
    initial begin
        CLK_50M <= 1'b0;
        RST     <= 1'b1;
        #20
        RST     <= 1'b0;
    end    
 
    initial begin
        $dumpfile("./sim/uart_tx_apply_tb.vcd");
        $dumpvars(0, uart_tx_apply_tb);
        #100000 
        $finish;
    end

endmodule
