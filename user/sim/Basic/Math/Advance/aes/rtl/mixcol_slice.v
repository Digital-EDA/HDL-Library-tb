////////////////////////////////////////////////////////////////// ////
//// 																////
//// AES Decryption Core for FPGA									////
//// 																////
//// This file is part of the AES Decryption Core for FPGA project 	////
//// http://www.opencores.org/cores/xxx/ 							////
//// 																////
//// Description 													////
//// Implementation of  AES Decryption Core for FPGA according to 	////
//// core specification document.		 							////
//// 																////
//// To Do: 														////
//// - 																////
//// 																////
//// Author(s): 													////
//// - scheng, schengopencores@opencores.org 						////
//// 																////
//////////////////////////////////////////////////////////////////////
//// 																////
//// Copyright (C) 2009 Authors and OPENCORES.ORG 					////
//// 																////
//// This source file may be used and distributed without 			////
//// restriction provided that this copyright statement is not 		////
//// removed from the file and that any derivative work contains 	////
//// the original copyright notice and the associated disclaimer. 	////
//// 																////
//// This source file is free software; you can redistribute it 	////
//// and/or modify it under the terms of the GNU Lesser General 	////
//// Public License as published by the Free Software Foundation; 	////
//// either version 2.1 of the License, or (at your option) any 	////
//// later version. 												////
//// 																////
//// This source is distributed in the hope that it will be 		////
//// useful, but WITHOUT ANY WARRANTY; without even the implied 	////
//// warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR 		////
//// PURPOSE. See the GNU Lesser General Public License for more 	////
//// details. 														////
//// 																////
//// You should have received a copy of the GNU Lesser General 		////
//// Public License along with this source; if not, download it 	////
//// from http://www.opencores.org/lgpl.shtml 						////
//// 																//// ///
///////////////////////////////////////////////////////////////////
////																////
//// This module computes one column of the InvMixColumns() defined	////
//// in section 5.3.3 in FIPS-197 specification.					////
//// 																////
////////////////////////////////////////////////////////////////////////
module mixcol_slice(
        input   [31:0]  S_old,
        input           mode,
        // input	[7:0]	S0c,
        // input	[7:0]	S1c,
        // input	[7:0]	S2c,
        // input	[7:0]	S3c,
        input	bypass,
        output	[31:0]	new_S);

    wire	[7:0]	s0cx2,s0cx3, S0cx9, S0cxb, S0cxd, S0cxe;
    wire	[7:0]	s1cx2,s1cx3, S1cx9, S1cxb, S1cxd, S1cxe;
    wire	[7:0]	s2cx2,s2cx3, S2cx9, S2cxb, S2cxd, S2cxe;
    wire	[7:0]	s3cx2,s3cx3, S3cx9, S3cxb, S3cxd, S3cxe;

    wire	[7:0]	sum0, sum1, sum2, sum3;

    // GF multipliers to generate products for x9, xb, xd, xe
    gfmul gfmul_u0(.d(S_old[31:24]), .x2(s0cx2), .x3(s0cx3), .x9(S0cx9), .xb(S0cxb), .xd(S0cxd), .xe(S0cxe));
    gfmul gfmul_u1(.d(S_old[23:16]), .x2(s1cx2), .x3(s1cx3), .x9(S1cx9), .xb(S1cxb), .xd(S1cxd), .xe(S1cxe));
    gfmul gfmul_u2(.d(S_old[15:8]), .x2(s2cx2), .x3(s2cx3), .x9(S2cx9), .xb(S2cxb), .xd(S2cxd), .xe(S2cxe));
    gfmul gfmul_u3(.d(S_old[7:0]), .x2(s3cx2), .x3(s3cx3), .x9(S3cx9), .xb(S3cxb), .xd(S3cxd), .xe(S3cxe));

    // Compute InvMixColumns according to section 5.3.3 of FIPS-197 spec.
    // Feed input through directly when bypass=1.
    assign sum0 = mode? (S0cxe ^ S1cxb ^ S2cxd ^ S3cx9)   : (s0cx2 ^ s1cx3 ^ S_old[15:8] ^ S_old[7:0]);
    assign sum1 = mode? (S0cx9 ^ S1cxe ^ S2cxb ^ S3cxd)   : (S_old[31:24] ^ s1cx2 ^ s2cx3 ^ S_old[7:0]);
    assign sum2 = mode? (S0cxd ^ S1cx9 ^ S2cxe ^ S3cxb)   : (S_old[31:24] ^ S_old[23:16] ^ s2cx2 ^ s3cx3) ;
    assign sum3 = mode? (S0cxb ^ S1cxd ^ S2cx9 ^ S3cxe)   : (s0cx3 ^ S_old[23:16] ^ S_old[15:8] ^ s3cx2);

    assign new_S = bypass ? S_old : {sum0, sum1, sum2, sum3};
endmodule
