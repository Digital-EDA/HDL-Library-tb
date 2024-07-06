`timescale 1 ns / 1 ns
module shiftTaps_tb();

    parameter DATA_WIDTH = 32;
    parameter ADDR_WIDTH = 32;
    parameter MAIN_FRE   = 100; //unit MHz
    reg                   sys_clk = 1;
    reg                   sys_rst = 1;
    reg [DATA_WIDTH-1:0]  data = 0;

    always begin
        #(500/MAIN_FRE) sys_clk <= ~sys_clk;
    end

    always begin
        #45 sys_rst <= 0;
    end

    // always @(posedge sys_clk) begin
    //     if (sys_rst) 
    //         data <= 0;
    //     else      
    //         data <= data + 1;
    // end

    reg ivalid;
    always @(posedge sys_clk or posedge sys_rst) begin
        if (sys_rst) begin
            ivalid <= 0;
        end
        else begin
            ivalid <= 1;
        end
    end

    always @(posedge sys_clk or posedge sys_rst) begin
        if (sys_rst) begin
            data <= 0;
        end
        else begin
            if (ivalid) begin
                data <= data + 1;
            end
        end
    end

    //Instance 
    // outports wire
    wire [DATA_WIDTH-1:0] 	shiftout;
    
    shiftTaps #(
        .WIDTH 	( DATA_WIDTH     ),
        .SHIFT 	( 1             ))
    u_shiftTaps(
        .clock    	( sys_clk   ),
        .reset    	( sys_rst   ),

        .ivalid   	( ivalid    ),
        .shiftin  	( data      ),

        .ovalid   	( ovalid    ),
        .shiftout 	( shiftout  )
    );
    
    // outports wire
    wire [(DATA_WIDTH-1):0] 	data_out;
    wire                    	output_valid;

    always @(posedge sys_clk) begin
        if (ivalid) begin
            $strobe("ivalid:%d\tshiftin:%d\t\tovalid:%d\tshiftout:%d", u_shiftTaps.ivalid, $signed(u_shiftTaps.shiftin), u_shiftTaps.ovalid, $signed(u_shiftTaps.shiftout));
        end
    end

    initial begin            
        $dumpfile("/home/icer/Project/library/user/sim/Basic/Memory/SRAM/Shift/shiftTaps/shiftTaps.vcd");        
        $dumpvars(0, shiftTaps_tb);    
        #500 $finish;
    end


endmodule  //TOP