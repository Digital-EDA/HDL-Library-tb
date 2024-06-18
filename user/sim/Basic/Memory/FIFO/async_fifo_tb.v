module async_fifo_tb();

parameter DATA_WIDTH = 16;
parameter DEPTH      = 512;
parameter MODE       = "Standard";

parameter WR_FRE   = 100; //unit MHz
parameter RD_FRE   = 50;

reg                   wr_clk  = 0;
reg                   rd_clk  = 0;
reg                   sys_rst = 0;

always begin
    #(500/WR_FRE) wr_clk = ~wr_clk;
end

always begin
    #(500/RD_FRE) rd_clk = ~rd_clk;
end

always begin
    #50 sys_rst = 1;
end

//Instance 
// outports wire
wire [DATA_WIDTH - 1 : 0] rd_data;
wire                  	  full;
wire                  	  empty;

reg                       wr_en;
reg  [DATA_WIDTH - 1 : 0] wr_data;

reg                       rd_en;

initial begin
    wr_en = 1'b0;
    rd_en = 1'b0;
    #100
    wr_en = 1'b1;
    #200
    wr_en = 1'b0;
    #100
    rd_en = 1'b1;
    #200
    rd_en = 1'b0;
end

always @(posedge wr_clk) begin
    if(sys_rst == 1'b0)begin
        wr_data <= 1'b0;
    end
    else if(wr_en)begin
        wr_data <= wr_data + 1'b1;
    end
end

async_fifo #(
	.DATA_WIDTH 	( DATA_WIDTH ),
	.DEPTH      	( DEPTH      ),
	.MODE       	( MODE       )
)
u_async_fifo(
	.wr_clk  	( wr_clk   ),
	.wr_rst  	( sys_rst  ),
	.wr_en   	( wr_en    ),
	.wr_data 	( wr_data  ),
	
    .rd_clk  	( rd_clk   ),
	.rd_rst  	( sys_rst  ),
	.rd_en   	( rd_en    ),
	.rd_data 	( rd_data  ),
	.full    	( full     ),
	.empty   	( empty    )
);

initial begin            
    $dumpfile("wave.vcd");        
    $dumpvars(0, async_fifo_tb);    
    #50000 $finish;
end

endmodule  //TOP
