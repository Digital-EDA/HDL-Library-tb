class aes_vsqr extends uvm_sequencer;
  
   aes_sequencer  sqr0;

   function new(string name, uvm_component parent);
      super.new(name, parent);
   endfunction 
   
   `uvm_component_utils(aes_vsqr)
endclass