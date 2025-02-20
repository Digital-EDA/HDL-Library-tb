class aes_transaction extends uvm_sequence_item;
rand bit [127:0] block_input;
   rand bit [255:0] key_in;
   rand bit [1:0]   key_lenth;
   rand bit         mode;
   bit [127:0] block_output;

    constraint pload_cons{
      // key_lenth == 2'b10;
      // key_lenth == 2'b10;
      // key_in == 256'hed90_629b_7057_d948_2308_81ef_fd54_6a1a_375f_571b_41c2_943c_8433_4649_abd2_44a0;
      // mode == 2'b01;
   }



   function void post_randomize();
   endfunction

   `uvm_object_utils_begin(aes_transaction)
      `uvm_field_int(block_input, UVM_ALL_ON);
      `uvm_field_int(block_output, UVM_ALL_ON);
      `uvm_field_int(key_in, UVM_ALL_ON);
      `uvm_field_int(key_lenth, UVM_ALL_ON);
      `uvm_field_int(mode, UVM_ALL_ON);
   `uvm_object_utils_end

   function new(string name = "aes_transaction");
      super.new();
   endfunction

endclass
