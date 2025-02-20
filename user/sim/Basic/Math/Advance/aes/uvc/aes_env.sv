class aes_env extends uvm_env;

   aes_agent   mst_agt;
   aes_agent   slv_agt;
   aes_model   mdl;
   aes_scoreboard scb;
   
   uvm_tlm_analysis_fifo #(uvm_sequence_item) agt_scb_fifo;
   uvm_tlm_analysis_fifo #(uvm_sequence_item) agt_mdl_fifo;
   uvm_tlm_analysis_fifo #(uvm_sequence_item) mdl_scb_fifo;
   
   function new(string name = "aes_env", uvm_component parent);
      super.new(name, parent);
   endfunction

   virtual function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      mst_agt = aes_agent::type_id::create("mst_agt", this);
      slv_agt = aes_agent::type_id::create("slv_agt", this);
      mst_agt.is_active = UVM_ACTIVE;
      slv_agt.is_active = UVM_PASSIVE;
      mdl = aes_model::type_id::create("mdl", this);
      scb = aes_scoreboard::type_id::create("scb", this);
      agt_scb_fifo = new("agt_scb_fifo", this);
      agt_mdl_fifo = new("agt_mdl_fifo", this);
      mdl_scb_fifo = new("mdl_scb_fifo", this);

   endfunction

   extern virtual function void connect_phase(uvm_phase phase);
   
   `uvm_component_utils(aes_env)
endclass

function void aes_env::connect_phase(uvm_phase phase);
   super.connect_phase(phase);
   mst_agt.ap.connect(agt_mdl_fifo.analysis_export);
   mdl.port.connect(agt_mdl_fifo.blocking_get_export);
   mdl.ap.connect(mdl_scb_fifo.analysis_export);
   scb.exp_port.connect(mdl_scb_fifo.blocking_get_export);
   slv_agt.ap.connect(agt_scb_fifo.analysis_export);
   scb.act_port.connect(agt_scb_fifo.blocking_get_export); 
endfunction
