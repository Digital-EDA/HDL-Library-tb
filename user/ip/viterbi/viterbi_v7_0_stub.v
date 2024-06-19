// Copyright 1986-2018 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2018.3 (win64) Build 2405991 Thu Dec  6 23:38:27 MST 2018
// Date        : Sat Jun 15 17:03:29 2024
// Host        : LAPTOP-4156P8SE running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode synth_stub
//               d:/Project/FPGA/Design/TCL_project/Prj/Communication/user/ip/viterbi/viterbi_v7_0_stub.v
// Design      : viterbi_v7_0
// Purpose     : Stub declaration of top-level module interface
// Device      : xc7z020clg400-2
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
(* x_core_info = "viterbi_v9_1_10,Vivado 2018.3" *)
module viterbi_v7_0(aclk, aresetn, aclken, s_axis_data_tdata, 
  s_axis_data_tuser, s_axis_data_tvalid, s_axis_data_tready, m_axis_data_tdata, 
  m_axis_data_tvalid)
/* synthesis syn_black_box black_box_pad_pin="aclk,aresetn,aclken,s_axis_data_tdata[15:0],s_axis_data_tuser[7:0],s_axis_data_tvalid,s_axis_data_tready,m_axis_data_tdata[7:0],m_axis_data_tvalid" */;
  input aclk;
  input aresetn;
  input aclken;
  input [15:0]s_axis_data_tdata;
  input [7:0]s_axis_data_tuser;
  input s_axis_data_tvalid;
  output s_axis_data_tready;
  output [7:0]m_axis_data_tdata;
  output m_axis_data_tvalid;
endmodule
