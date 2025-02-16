module basic_tb();

    parameter DATA_WIDTH = 8;
    parameter ADDR_WIDTH = 8;
    parameter MAIN_FRE   = 100; //unit MHz
    reg                   sys_clk = 1;
    reg                   sys_rst = 1;
    reg [DATA_WIDTH-1:0]  data;

    always begin
        #(500/MAIN_FRE) sys_clk <= ~sys_clk;
    end

    always begin
        #45 sys_rst <= 0;
    end

    // rst as valid 
    // always @(posedge sys_clk or posedge sys_rst) begin
    //     if (sys_rst) begin
    //         data <= 0;
    //     end
    //     else begin
    //         data <= data + 1;
    //     end
    // end

    // valid after rst
    // reg ivalid;
    // always @(posedge sys_clk or posedge sys_rst) begin
    //     if (sys_rst) begin
    //         ivalid <= 0;
    //     end
    //     else begin
    //         ivalid <= 1;
    //     end
    // end

    always @(posedge sys_clk or posedge sys_rst) begin
        if (sys_rst) begin
            data <= 0;
        end
        else begin
            if (~sys_rst) begin
                if (data == 10) begin
                    data <= 0;
                end
                else begin
                    data <= data + 1;
                end
            end
        end
    end

    reg                   ovalid;
    reg [DATA_WIDTH-1:0]  odata;
    always @(posedge sys_clk or posedge sys_rst) begin
        if (sys_rst) begin
            ovalid <= 0;
            odata <= 0;
        end 
        else begin            
            if (~sys_rst) begin
                ovalid <= ~sys_rst;
                odata <= data;
            end
        end
    end

    // display & strobe
    always @(posedge sys_clk) begin
        if (~sys_rst) begin
            $display("$display :\tivalid:%d\tdata:%d", ~sys_rst, $signed(data));
            // $strobe("$strobe :\tivalid:%d\tdata:%d", ~sys_rst, $signed(data));
        end
    end

    initial begin
        $dumpfile("basic.vcd");        
        $dumpvars(0, basic_tb);    
        #500 $finish;
    end


endmodule  //TOP