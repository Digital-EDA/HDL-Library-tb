module axilite_uart_tb();
    reg             clock           ;
    reg             async_resetn    ;
    reg     [15:0]  s_axi_awaddr    ;
    reg             s_axi_awvalid   ;
    wire            s_axi_awready   ;
    reg     [31:0]  s_axi_wdata     ;
    reg             s_axi_wvalid    ;
    wire            s_axi_wready    ;
    wire    [1:0]   s_axi_bresp     ;
    wire            s_axi_bvalid    ;
    reg             s_axi_bready    ;
    reg     [15:0]  s_axi_araddr    ;
    reg             s_axi_arvalid   ;
    wire            s_axi_arready   ;
    wire    [31:0]  s_axi_rdata     ;
    wire    [1:0]   s_axi_rresp     ;
    wire            s_axi_rvalid    ;
    reg             s_axi_rready    ;
    wire            interrupt       ;

    // inner logic
    // 10ns --> Freq = 100MHz
    parameter       Clockperiod = 10;    
    logic           start_write;
    logic           start_read;
    logic   [31:0]  rd_data;
    logic           TxD_RxD;


    axilite_uart  #(
        .SYS_CLK        (100000000)     ,
        .BAUD_RATE      (115200)
    ) dut (
        .clock          (clock)         , 
        .async_resetn   (async_resetn)  ,

        .s_axi_awaddr   (s_axi_awaddr)  ,
        .s_axi_awvalid  (s_axi_awvalid) ,
        .s_axi_awready  (s_axi_awready) ,

        .s_axi_wdata    (s_axi_wdata)   ,
        .s_axi_wvalid   (s_axi_wvalid)  ,
        .s_axi_wready   (s_axi_wready)  ,

        .s_axi_bresp    (s_axi_bresp)   ,
        .s_axi_bvalid   (s_axi_bvalid)  ,
        .s_axi_bready   (s_axi_bready)  ,

        .s_axi_araddr   (s_axi_araddr)  ,
        .s_axi_arvalid  (s_axi_arvalid) ,
        .s_axi_arready  (s_axi_arready) ,

        .s_axi_rdata    (s_axi_rdata)   ,
        .s_axi_rresp    (s_axi_rresp)   ,
        .s_axi_rvalid   (s_axi_rvalid)  ,
        .s_axi_rready   (s_axi_rready)  , 

        .interrupt      (interrupt)     ,
        .RxD            (TxD_RxD)           ,
        .TxD            (TxD_RxD)           ,
        // .RTSn           ()              ,
        .CTSn           (1'b0)             
    );


    //  ============================= Control =============================
    //  100MHz Clock
    initial                 clock = 1'b0       ;
    always #(Clockperiod/2) clock = ~clock;
    

    initial begin
        async_resetn    =   1'b0    ;
              
        s_axi_awaddr    =   16'h0   ;
        s_axi_awvalid   =   1'b0    ;
        s_axi_wdata     =   32'h0   ;
        s_axi_wvalid    =   1'b0    ;
        s_axi_bready    =   1'b0    ;

        s_axi_araddr    =   16'h0   ;
        s_axi_arvalid   =   1'b0    ;
        s_axi_rready    =   1'b0    ;

        #1500
        async_resetn    =   1'b1    ;
        s_axi_bready    =   1'b1    ;

        #1500                       
        start_write=0;
        #50
        start_write=1;
        #10
        start_write=0;
    end

    //  发起写请求
    //  写地址通道
    //  s_axi_awvalid
    always_ff @(posedge clock, negedge async_resetn) begin
        if(!async_resetn) begin
            s_axi_awvalid <= 0;
        end else if(start_write) begin
            s_axi_awvalid <= 1;
        end else if(s_axi_awvalid && s_axi_awready) begin
            //写地址通道完成
            s_axi_awvalid <= 0;
        end
    end
    //  s_axi_awaddr
    always_ff @(posedge clock, negedge async_resetn) begin
        if(!async_resetn) begin
            s_axi_awaddr <= 16'd0;
        end else if(start_write) begin
            s_axi_awaddr <= 16'd4;
        end
    end
    //  写数据通道
    //  s_axi_wdata
    always_ff @(posedge clock, negedge async_resetn) begin
        if(!async_resetn) begin
            s_axi_wdata <= 0;
        end else if(s_axi_awvalid && s_axi_awready) begin 
            // 写地址通道完成
            s_axi_wdata <= 16'd12;
        end
    end
    //  s_axi_wvalid
    always_ff @(posedge clock, negedge async_resetn) begin
        if(!async_resetn) begin
            s_axi_wvalid <= 0;
        end else if(s_axi_awvalid && s_axi_awready) begin 
            // 写地址结束，开始写数据，写数据写地址可同时进行
            s_axi_wvalid <= 1;
        end else if(s_axi_wvalid && s_axi_wready) begin
            // 写数据完毕
            s_axi_wvalid <= 0;
        end
    end
    //  写响应通道
    //  s_axi_bready
    always_ff @(posedge clock, negedge async_resetn) begin
        if(!async_resetn) begin
            s_axi_bready <= 0;
        end else if(s_axi_awvalid && s_axi_awready) begin // 写地址通道结束后可提前拉高
            s_axi_bready <= 1;
        end else if(s_axi_bready && s_axi_bvalid && s_axi_bresp == 2'b00) begin      
            s_axi_bready <= 0;
        end
    end

    //  发起读请求
    //  start_read
    // always_ff @(posedge clock, negedge async_resetn)
    // if(!async_resetn)
    //     start_read <= 0;
    // else if(s_axi_bresp == 2'b00 && s_axi_bvalid && s_axi_bready)
    //     start_read <= 1;
    // else
    //     start_read <= 0;
    initial begin
        #120000
        start_read=0;
        #50
        start_read=1;
        #10
        start_read=0;
    end

    //  读地址通道
    //  s_axi_arvalid
    always_ff @(posedge clock, negedge async_resetn) begin
        if(!async_resetn) begin
            s_axi_arvalid <= 0;
        end else if(start_read) begin
            s_axi_arvalid <= 1;
        end else if(s_axi_arvalid && s_axi_arready) begin   
            //读地址通道结束
            s_axi_arvalid <= 0;
        end
    end
    //  s_axi_araddr
    always_ff @(posedge clock, negedge async_resetn) begin
        if(!async_resetn) begin
            s_axi_araddr <= 0;
        end else if(start_read) begin
            s_axi_araddr <= 16'd0;
        end
    end
    //  读数据通道
    //  s_axi_rready
    always_ff @(posedge clock, negedge async_resetn) begin
        if(!async_resetn) begin
            s_axi_rready <= 0;
        end else if(s_axi_arvalid && s_axi_arready) begin    
            //读地址通道结束后，拉高RREADY以准备接收数据
            s_axi_rready <= 1;
        end else if(s_axi_rready && s_axi_rvalid) begin                   //读数据完成
            s_axi_rready <= 0;
        end
    end
    //  rd_data
    always @(posedge clock, negedge async_resetn) begin
        if(!async_resetn) begin
            rd_data <= 0;
        end else if(s_axi_rvalid && s_axi_rready) begin  //同时为高，可读取数据
            rd_data <= s_axi_rdata;
            $strobe("%d",rd_data);
        end
    end

    initial begin
        $dumpfile("./sim/axilite_uart_tb.vcd");
        $dumpvars(0, axilite_uart_tb);
        #10000000
        $finish;
    end

endmodule