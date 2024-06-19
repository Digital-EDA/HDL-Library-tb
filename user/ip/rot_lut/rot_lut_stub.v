// Copyright 1986-2018 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2018.3 (win64) Build 2405991 Thu Dec  6 23:38:27 MST 2018
// Date        : Sat Jun 15 17:03:29 2024
// Host        : LAPTOP-4156P8SE running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode synth_stub
//               d:/Project/FPGA/Design/TCL_project/Prj/Communication/user/ip/rot_lut/rot_lut_stub.v
// Design      : rot_lut
// Purpose     : Stub declaration of top-level module interface
// Device      : xc7z020clg400-2
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
(* x_core_info = "blk_mem_gen_v8_4_2,Vivado 2018.3" *)
module rot_lut(clka, addra, douta, clkb, addrb, doutb)
/* synthesis syn_black_box black_box_pad_pin="clka,addra[8:0],douta[31:0],clkb,addrb[8:0],doutb[31:0]" */;
  input clka;
  input [8:0]addra;
  output [31:0]douta;
  input clkb;
  input [8:0]addrb;
  output [31:0]doutb;
endmodule
