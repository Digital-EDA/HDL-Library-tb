module spi_tb();
 
    reg         clk_50m;
    reg         CPOL;
    reg         CPHA;
    reg         CS_input;

    initial begin
        clk_50m     <= 1;
        CPOL        <= 1;
        CPHA        <= 0;
        CS_input    <= 1;
    end

    always #10  clk_50m <= ~clk_50m;
    
    reg rst;

    initial begin
        rst <= 1;
        #200
        rst <= 0;
    end
    
    reg             valid;
    reg     [7:0]   data_send;
    wire            ready;
    wire    [7:0]   data_receive;
    wire            spi_clk;
    wire            spi_mosi;
    wire            spi_miso;
    wire            CS_output;
    
    spi #(   
        .value_divide                   (4)
    ) u1_spi (
        // -----------------internal interface------------------
        .clk                            (clk_50m),
        .rst                            (rst),
        .CPOL                           (CPOL),
        .CPHA                           (CPHA),
        .CS_input                       (CS_input),
        .valid                          (valid),
        .data_send                      (data_send),
        .ready                          (ready),        
        .data_receive                    (data_receive),
        // ------------------external interface------------------
        .spi_clk                        (spi_clk),
        .spi_mosi                       (spi_mosi),
        .spi_miso                       (spi_miso),
        .CS_output                      (CS_output)
    );
    
    assign spi_miso = spi_mosi;
    
    initial begin
        valid <= 0;
        data_send <= 0;
        #400;
        valid <= 1;
        data_send <= 8'haf;
        #20
        valid <= 0;
        #800;
        valid <= 1;
        data_send <= 8'h55;
        #20
        valid <= 0;
    end

    initial begin
        $dumpfile("./sim/spi_tb.vcd");
        $dumpvars(0, spi_tb);
        #100000
        $finish;
    end
endmodule