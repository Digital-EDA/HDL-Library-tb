class aes_case0_sequence extends uvm_sequence #(uvm_sequence_item);
   aes_transaction m_trans;

   function  new(string name= "aes_case0_sequence");
      super.new(name);
   endfunction 
   
   virtual task body();
      repeat (100) begin
         `uvm_do(m_trans)
      end
   endtask

   `uvm_object_utils(aes_case0_sequence)
endclass