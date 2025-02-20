interface aes_interface_port;
logic clock;
logic rstn;
logic [127:0] block_input;
logic start;
logic [255:0] key_in;
logic [1:0] key_lenth;
logic mode;
logic done;
logic [127:0] block_output;
logic proc_busy;




endinterface