module uart_tx_apply(
        input               clk,
        input               rst,
        output              tx
    );
    
    reg [18:0]  cnt_10ms;
    reg [ 7:0]  data;
    reg         valid;
    wire        ready;
    reg [ 1:0]  ready_d;
    reg         wait_10ms;
    
    parameter CNT_10MS = 500_000;
    
    uart_tx u1_uart_tx(
        .data       (data),
        .valid      (valid),
        .clk        (clk),
        .rst        (rst),
        .tx         (tx),
        .ready      (ready)
    );

    defparam u1_uart_tx.TX_BAUD = 115200;

    always @(posedge clk or posedge rst) begin
        if(rst) begin
            cnt_10ms    <= 0;
            valid       <= 0;
            data        <= 8'b0;
            wait_10ms   <= 1'b1;
        end
    end

    always @(posedge clk) begin
        if(cnt_10ms == CNT_10MS - 1) begin
            cnt_10ms <= 0;
        end else if(wait_10ms == 1) begin
            cnt_10ms <= cnt_10ms + 1'b1;
        end
    end
    
    always @(posedge clk) begin
        if(cnt_10ms == CNT_10MS - 1) begin
            valid <= 1'b1;
        end else begin
            valid <= 0;
        end
    end
    
    always @(posedge clk) begin
        if(valid == 1) begin
            data <= data + 1'b1;
        end else begin
            data <= data;
        end
    end

    always @(posedge clk) begin
        ready_d <= {ready_d[0], ready};
    end

    always @(posedge clk) begin
        if(ready_d[0]) begin
            wait_10ms <= 1'b1;
        end else if(cnt_10ms == CNT_10MS - 1) begin
            wait_10ms <= 0;
        end
    end
    
endmodule
 