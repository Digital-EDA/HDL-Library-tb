class aes_agent extends uvm_agent ;
   aes_sequencer  sqr;
   aes_driver     drv;
   aes_monitor    mon;
   
   uvm_analysis_port #(uvm_sequence_item)  ap;
   
   function new(string name, uvm_component parent);
      super.new(name, parent);
   endfunction 
   
   extern virtual function void build_phase(uvm_phase phase);
   extern virtual function void connect_phase(uvm_phase phase);

   `uvm_component_utils(aes_agent)
endclass 


function void aes_agent::build_phase(uvm_phase phase);
   super.build_phase(phase);
   if (is_active == UVM_ACTIVE) begin
      sqr = aes_sequencer::type_id::create("sqr", this);
      drv = aes_driver::type_id::create("drv", this);
   end
   mon = aes_monitor::type_id::create("mon", this);
   mon.is_active = is_active;
endfunction 

function void aes_agent::connect_phase(uvm_phase phase);
   super.connect_phase(phase);
   if (is_active == UVM_ACTIVE) begin
      drv.seq_item_port.connect(sqr.seq_item_export);
   end
   ap = mon.ap;
endfunction

