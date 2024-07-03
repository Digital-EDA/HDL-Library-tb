
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
        #50 sys_rst <= 0;
    end

    always @(posedge sys_clk) begin
        if (sys_rst) 
            data <= 0;
        else      
            data <= data + 1;
    end

    //Instance 
    // outports wire
    wire [DATA_WIDTH-1:0] 	shiftout;
    
    shiftTaps #(
        .WIDTH 	( DATA_WIDTH     ),
        .SHIFT 	( 2             ))
    u_shiftTaps(
        .clock    	( sys_clk     ),
        .reset    	( sys_rst   ),

        .ivalid   	( ~sys_rst  ),
        .shiftin  	( data      ),

        .ovalid   	( ovalid    ),
        .shiftout 	( shiftout  )
    );
    
    // outports wire
    wire [DATA_WIDTH-1:0] 	odata;
    
    delay #(
        .WIDTH 	( DATA_WIDTH  ),
        .DELAY 	( 32         ))
    u_delay(
        .clock 	( sys_clk  ),
        .reset 	( sys_rst  ),
        .idata 	( data  ),
        .odata 	( odata  )
    );
    
    // outports wire
    wire [(DATA_WIDTH-1):0] 	data_out;
    wire                    	output_valid;

    delay_sample #(
        .DATA_WIDTH  	( DATA_WIDTH  ),
        .DELAY_SHIFT 	( 5   ))
    u_delay_sample(
        .clock        	( sys_clk        ),
        .enable       	( ~sys_rst       ),
        .reset        	( sys_rst        ),
        .data_in      	( data           ),
        .input_valid  	( sys_clk       ),
        .data_out     	( data_out       ),
        .output_valid 	( output_valid   )
    );

    always @(posedge sys_clk) begin
        if (~sys_rst) begin
            $strobe("ivalid:%d\tshiftin:%d\t\tovalid:%d\tshiftout:%d", ~sys_rst, $signed(data), ovalid, $signed(shiftout));
        end
    end

    initial begin            
        $dumpfile("shiftTaps.vcd");        
        $dumpvars(0, shiftTaps_tb);    
        #50000 $finish;
    end


endmodule  //TOP