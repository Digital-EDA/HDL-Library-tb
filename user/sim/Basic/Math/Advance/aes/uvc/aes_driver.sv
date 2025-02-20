class aes_driver extends uvm_driver;

   virtual aes_interface_port vif;
   virtual aes_interface_inner vif_i;

   `uvm_component_utils(aes_driver)
   function new(string name = "aes_driver", uvm_component parent = null);
      super.new(name, parent);
   endfunction

   virtual function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      if(!uvm_config_db#(virtual aes_interface_port)::get(this, "", "vif", vif))
         `uvm_fatal("aes_driver", "virtual interface must be set for vif!!!")
      if(!uvm_config_db#(virtual aes_interface_inner)::get(this, "", "vif_i", vif_i))
         `uvm_fatal("aes_driver", "virtual interface must be set for vif_i!!!")

   endfunction

   extern task main_phase(uvm_phase phase);
   extern task drive_one_pkt(aes_transaction tr);
endclass

task aes_driver::main_phase(uvm_phase phase);
   aes_transaction tr;
   vif.block_input <= 0;
   vif.key_in <= 0;
   vif.key_lenth <= 0;
   vif.mode <= 0;
   vif.start <= 0;
   while(1) begin
      seq_item_port.get_next_item(req);
      $cast(tr,req);
      drive_one_pkt(tr);
      seq_item_port.item_done();
   end
endtask

task aes_driver::drive_one_pkt(aes_transaction tr);
   // `uvm_info("aes_driver", "begin to drive one pkt", UVM_LOW);
   @(posedge vif.clock);
   vif.block_input <= tr.block_input;
   vif.start <= 1'b1;
   vif.key_in <= tr.key_in;
   vif.key_lenth <= tr.key_lenth;
   vif.mode <= tr.mode;
   @(posedge vif.clock);
   vif.start <= 1'b0;
   vif.mode <= 0;
   wait(vif.done);


   // `uvm_info("aes_driver", "end drive one pkt", UVM_LOW);
endtask


