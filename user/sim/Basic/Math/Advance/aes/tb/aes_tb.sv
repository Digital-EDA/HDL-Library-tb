`include "uvm_macros.svh"
module aes_tb;
aes_interface_port ifo ();
aes_interface_inner ifi ();
logic clock;
logic rstn;
logic rst_p;
aes aes_inst (
        .clock           (ifo.clock         ) ,//input   
        .rstn         (ifo.rstn       ) ,//input   
        .block_input   (ifo.block_input ) ,//input   [127:0]
        .start     (ifo.start   ) ,//input   
        .key_in        (ifo.key_in      ) ,//input   [255:0]
        .key_lenth     (ifo.key_lenth   ) ,//input   [1:0]
        .mode          (ifo.mode        ) ,//input   
        .done    (ifo.done  ) ,//output  
        .block_output  (ifo.block_output) ,//output  [127:0]
        .proc_busy    (ifo.proc_busy  ));//output  
always #5 clock = ~clock;

initial begin
clock = 0;
rstn = 0;
rst_p = 1;
#2 rstn = 1;
#1 rst_p = 0;

end

always_comb begin
ifo.clock = clock;
ifo.rstn = rstn;

end

initial begin
   run_test();
end

initial begin
   uvm_config_db#(virtual aes_interface_port)::set(null, "uvm_test_top.env.mst_agt.drv", "vif", ifo);
   uvm_config_db#(virtual aes_interface_port)::set(null, "uvm_test_top.env.mst_agt.mon", "vif", ifo);
   uvm_config_db#(virtual aes_interface_port)::set(null, "uvm_test_top.env.slv_agt.mon", "vif", ifo);
   uvm_config_db#(virtual aes_interface_inner)::set(null, "uvm_test_top.env.mst_agt.drv", "vif_i", ifi);
   uvm_config_db#(virtual aes_interface_inner)::set(null, "uvm_test_top.env.mst_agt.mon", "vif_i", ifi);
   uvm_config_db#(virtual aes_interface_inner)::set(null, "uvm_test_top.env.slv_agt.mon", "vif_i", ifi);
end
initial begin
   $fsdbDumpvars();
end





endmodule
