class aes_model extends uvm_component;
   
   uvm_blocking_get_port #(uvm_sequence_item)  port;
   uvm_analysis_port #(uvm_sequence_item)  ap;

   extern function new(string name, uvm_component parent);
   extern function void build_phase(uvm_phase phase);
   extern virtual  task main_phase(uvm_phase phase);

   `uvm_component_utils(aes_model)

endclass 

function aes_model::new(string name, uvm_component parent);
   super.new(name, parent);
endfunction 

function void aes_model::build_phase(uvm_phase phase);
   super.build_phase(phase);
   port = new("port", this);
   ap = new("ap", this);
endfunction

task aes_model::main_phase(uvm_phase phase);
   uvm_sequence_item drive_req;
   aes_transaction drive_tr;
   aes_transaction scb_tr;
   aes_model_core aes_inst;
   int key_length;
   super.main_phase(phase);
   while(1) begin
      port.get(drive_req);
      $cast(drive_tr,drive_req);
      scb_tr = new("scb_tr");
      scb_tr.mode = 0;
      scb_tr.key_in = drive_tr.key_in;
      scb_tr.key_lenth = drive_tr.key_lenth;
      scb_tr.block_input = drive_tr.block_input;
      scb_tr.mode = drive_tr.mode;
      case(scb_tr.key_lenth)
         2'b00:key_length = 128;
         2'b01:key_length = 192;
         2'b10:key_length = 256;
         2'b11:key_length = 256;
      endcase
      aes_inst = new(key_length, scb_tr.key_in);
      if (scb_tr.mode == 0) begin
         scb_tr.block_output = aes_inst.encrypt(scb_tr.block_input);
      end
      else begin
         scb_tr.block_output = aes_inst.decrypt(scb_tr.block_input);
      end
      ap.write(scb_tr);
   end
endtask