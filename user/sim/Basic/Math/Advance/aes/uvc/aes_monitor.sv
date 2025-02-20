class aes_monitor extends uvm_monitor;

   virtual aes_interface_port vif;
   virtual aes_interface_inner vif_i;
   uvm_active_passive_enum is_active = UVM_ACTIVE;
   uvm_analysis_port #(uvm_sequence_item)  ap;
   
   `uvm_component_utils(aes_monitor)
   function new(string name = "aes_monitor", uvm_component parent = null);
      super.new(name, parent);
   endfunction

   virtual function void build_phase(uvm_phase phase);
      int active;
      super.build_phase(phase);
      if(!uvm_config_db#(virtual aes_interface_port)::get(this, "", "vif", vif))
         `uvm_fatal("aes_monitor", "virtual interface must be set for vif!!!")
      if(!uvm_config_db#(virtual aes_interface_inner)::get(this, "", "vif_i", vif_i))
         `uvm_fatal("aes_monitor", "virtual interface must be set for vif_i!!!")
      ap = new("ap", this);      
      if(get_config_int("is_active", active)) is_active = uvm_active_passive_enum'(active);
   endfunction

   extern task main_phase(uvm_phase phase);
   extern task collect_one_pkt_drv(aes_transaction tr);
   extern task collect_one_pkt_mon(aes_transaction tr);
endclass

task aes_monitor::main_phase(uvm_phase phase);
   aes_transaction tr;
   //------------forever------//
   while(1) begin
      if(is_active == UVM_ACTIVE) begin
         tr = new("tr");
         collect_one_pkt_drv(tr);
         ap.write(tr);
      end
      else begin
         tr = new("tr");
         collect_one_pkt_mon(tr);
         ap.write(tr);
      end
   end

   //------------repeat-------//
   // repeat(1) begin
   //    if(is_active == UVM_ACTIVE) begin
   //       tr = new("tr");
   //       collect_one_pkt_drv(tr);
   //       ap.write(tr);
   //    end
   //    else begin
   //       tr = new("tr");
   //       collect_one_pkt_mon(tr);
   //       ap.write(tr);
   //    end
   // end


endtask

task aes_monitor::collect_one_pkt_drv(aes_transaction tr);
   while(1) begin
      @(posedge vif.clock);
      if(vif.start) begin
         tr.block_input = vif.block_input;
         tr.key_in = vif.key_in;
         tr.mode = vif.mode;
         tr.key_lenth = vif.key_lenth;
         break;
      end
   end
endtask


task aes_monitor::collect_one_pkt_mon(aes_transaction tr);
   while(1) begin
      @(posedge vif.clock);
      if(vif.start) begin
         tr.block_input = vif.block_input;
         tr.key_in = vif.key_in;
         tr.mode = vif.mode;
         tr.key_lenth = vif.key_lenth;
      end
      if(vif.done) begin
         tr.block_output = vif.block_output;
         break;
      end
   end
endtask