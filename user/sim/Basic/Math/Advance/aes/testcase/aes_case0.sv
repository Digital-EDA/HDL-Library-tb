class aes_case0 extends aes_base_test;

   function new(string name = "case0", uvm_component parent = null);
      super.new(name,parent);
   endfunction 
   extern virtual function void build_phase(uvm_phase phase); 
   `uvm_component_utils(aes_case0)
endclass


function void aes_case0::build_phase(uvm_phase phase);
   super.build_phase(phase);

   uvm_config_db#(uvm_object_wrapper)::set(this, 
                                           "vsqr.main_phase", 
                                           "default_sequence", 
                                           aes_case0_vseq::type_id::get());
endfunction

