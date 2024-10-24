////////////////////////////////////////////////////////////////////////////////
//
// Filename:	fftstage.v
//
// Project:	A General Purpose Pipelined FFT Implementation
//
// Purpose:	This file is (almost) a Verilog source file.  It is meant to
//		be used by a FFT core compiler to generate FFTs which may be
//	used as part of an FFT core.  Specifically, this file encapsulates
//	the options of an FFT-stage.  For any 2^N length FFT, there shall be
//	(N-1) of these stages.
//
//
// Operation:
// 	Given a stream of values, operate upon them as though they were
// 	value pairs, x[n] and x[n+N/2].  The stream begins when n=0, and ends
// 	when n=N/2-1 (i.e. there's a full set of N values).  When the value
// 	x[0] enters, the synchronization input, i_sync, must be true as well.
//
// 	For this stream, produce outputs
// 	y[n    ] = x[n] + x[n+N/2], and
// 	y[n+N/2] = (x[n] - x[n+N/2]) * c[n],
// 			where c[n] is a complex coefficient found in the
// 			external memory file COEFFILE.
// 	When y[0] is output, a synchronization bit o_sync will be true as
// 	well, otherwise it will be zero.
//
// 	Most of the work to do this is done within the butterfly, whether the
// 	hardware accelerated butterfly (uses a DSP) or not.
//
// Creator:	Dan Gisselquist, Ph.D.
//		Gisselquist Technology, LLC
//
////////////////////////////////////////////////////////////////////////////////
//
// Copyright (C) 2015-2019, Gisselquist Technology, LLC
//
// This file is part of the general purpose pipelined FFT project.
//
// The pipelined FFT project is free software (firmware): you can redistribute
// it and/or modify it under the terms of the GNU Lesser General Public License
// as published by the Free Software Foundation, either version 3 of the
// License, or (at your option) any later version.
//
// The pipelined FFT project is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTIBILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Lesser
// General Public License for more details.
//
// You should have received a copy of the GNU Lesser General Public License
// along with this program.  (It's in the $(ROOT)/doc directory.  Run make
// with no target there if the PDF file isn't present.)  If not, see
// <http://www.gnu.org/licenses/> for a copy.
//
// License:	LGPL, v3, as defined and found on www.gnu.org,
//		http://www.gnu.org/licenses/lgpl.html
//
//
////////////////////////////////////////////////////////////////////////////////
//
//
//`default_nettype	none
//
module	fftstage(i_clk, i_reset, i_ce, i_sync, i_data, o_data, o_sync);
	parameter	IWIDTH=16,CWIDTH=20,OWIDTH=17;
	// Parameters specific to the core that should be changed when this
	// core is built ... Note that the minimum LGSPAN (the base two log
	// of the span, or the base two log of the current FFT size) is 3.
	// Smaller spans (i.e. the span of 2) must use the dbl laststage module.
	parameter	LGSPAN=5, BFLYSHIFT=0; // LGWIDTH=6
	parameter	[0:0]	OPT_HWMPY = 1;
	// Clocks per CE.  If your incoming data rate is less than 50% of your
	// clock speed, you can set CKPCE to 2'b10, make sure there's at least
	// one clock between cycles when i_ce is high, and then use two
	// multiplies instead of three.  Setting CKPCE to 2'b11, and insisting
	// on at least two clocks with i_ce low between cycles with i_ce high,
	// then the hardware optimized butterfly code will used one multiply
	// instead of two.
	parameter		CKPCE = 1;
	// The COEFFILE parameter contains the name of the file containing the
	// FFT twiddle factors
	parameter	COEFFILE = 64;

`ifdef	VERILATOR
	parameter [0:0] ZERO_ON_IDLE = 1'b0;
`else
	localparam [0:0] ZERO_ON_IDLE = 1'b0;
`endif // VERILATOR

	input	wire				i_clk, i_reset, i_ce, i_sync;
	input	wire	[(2*IWIDTH-1):0]	i_data;
	output	reg	[(2*OWIDTH-1):0]	o_data;
	output	reg				o_sync;

	// I am using the prefixes
	// 	ib_*	to reference the inputs to the butterfly, and
	// 	ob_*	to reference the outputs from the butterfly
	reg	wait_for_sync;
	reg	[(2*IWIDTH-1):0]	ib_a, ib_b;
	reg	[(2*CWIDTH-1):0]	ib_c;
	reg	ib_sync;

	reg	b_started;
	wire	ob_sync;
	wire	[(2*OWIDTH-1):0]	ob_a, ob_b;

	// cmem is defined as an array of real and complex values,
	// where the top CWIDTH bits are the real value and the bottom
	// CWIDTH bits are the imaginary value.
	//
	// cmem[i] = { (2^(CWIDTH-2)) * cos(2*pi*i/(2^LGWIDTH)),
	//		(2^(CWIDTH-2)) * sin(2*pi*i/(2^LGWIDTH)) };
	//
	wire	[(2*CWIDTH-1):0]	cmem [0:((1<<LGSPAN)-1)];
	// initial	$readmemh(COEFFILE,cmem);
    generate 
        if(COEFFILE == 8) begin : stage3
            // stage 3 cmem
            assign cmem[0] = 'h4000000000;
            assign cmem[1] = 'h2d4142d414;
            assign cmem[2] = 'h0000040000;
            assign cmem[3] = 'hd2bec2d414;
        end
        else if(COEFFILE == 16) begin : stage4
            // stage 4 cmem
            assign cmem[0] = 'h4000000000;
            assign cmem[1] = 'h3b20d187de;
            assign cmem[2] = 'h2d4142d414;
            assign cmem[3] = 'h187de3b20d;
            assign cmem[4] = 'h0000040000;
            assign cmem[5] = 'he78223b20d;
            assign cmem[6] = 'hd2bec2d414;
            assign cmem[7] = 'hc4df3187de;
        end
        else if(COEFFILE == 32) begin : stage5
            // stage 5 cmem
            assign cmem[0]  = 'h4000000000;
            assign cmem[1]  = 'h3ec530c7c6;
            assign cmem[2]  = 'h3b20d187de;
            assign cmem[3]  = 'h3536d238e7;
            assign cmem[4]  = 'h2d4142d414;
            assign cmem[5]  = 'h238e73536d;
            assign cmem[6]  = 'h187de3b20d;
            assign cmem[7]  = 'h0c7c63ec53;
            assign cmem[8]  = 'h0000040000;
            assign cmem[9]  = 'hf383a3ec53;
            assign cmem[10] = 'he78223b20d;
            assign cmem[11] = 'hdc7193536d;
            assign cmem[12] = 'hd2bec2d414;
            assign cmem[13] = 'hcac93238e7;
            assign cmem[14] = 'hc4df3187de;
            assign cmem[15] = 'hc13ad0c7c6;
        end
        else if(COEFFILE == 64) begin : stage6
            // stage 6 cmem
            assign cmem[0]  = 'h4000000000;
            assign cmem[1]  = 'h3fb120645f;
            assign cmem[2]  = 'h3ec530c7c6;
            assign cmem[3]  = 'h3d3e812940;
            assign cmem[4]  = 'h3b20d187de;
            assign cmem[5]  = 'h387161e2b6;
            assign cmem[6]  = 'h3536d238e7;
            assign cmem[7]  = 'h317902899e;
            assign cmem[8]  = 'h2d4142d414;
            assign cmem[9]  = 'h2899e31790;
            assign cmem[10] = 'h238e73536d;
            assign cmem[11] = 'h1e2b638716;
            assign cmem[12] = 'h187de3b20d;
            assign cmem[13] = 'h129403d3e8;
            assign cmem[14] = 'h0c7c63ec53;
            assign cmem[15] = 'h0645f3fb12;
            assign cmem[16] = 'h0000040000;
            assign cmem[17] = 'hf9ba13fb12;
            assign cmem[18] = 'hf383a3ec53;
            assign cmem[19] = 'hed6c03d3e8;
            assign cmem[20] = 'he78223b20d;
            assign cmem[21] = 'he1d4a38716;
            assign cmem[22] = 'hdc7193536d;
            assign cmem[23] = 'hd766231790;
            assign cmem[24] = 'hd2bec2d414;
            assign cmem[25] = 'hce8702899e;
            assign cmem[26] = 'hcac93238e7;
            assign cmem[27] = 'hc78ea1e2b6;
            assign cmem[28] = 'hc4df3187de;
            assign cmem[29] = 'hc2c1812940;
            assign cmem[30] = 'hc13ad0c7c6;
            assign cmem[31] = 'hc04ee0645f;
        end
    endgenerate

	reg	[(LGSPAN):0]		iaddr;
	reg	[(2*IWIDTH-1):0]	imem	[0:((1<<LGSPAN)-1)];

	reg	[LGSPAN:0]		oaddr;
	reg	[(2*OWIDTH-1):0]	omem	[0:((1<<LGSPAN)-1)];

	initial wait_for_sync = 1'b1;
	initial iaddr = 0;
	always @(posedge i_clk)
	if (i_reset)
	begin
		wait_for_sync <= 1'b1;
		iaddr <= 0;
	end else if ((i_ce)&&((!wait_for_sync)||(i_sync)))
	begin
		//
		// First step: Record what we're not ready to use yet
		//
		iaddr <= iaddr + { {(LGSPAN){1'b0}}, 1'b1 };
		wait_for_sync <= 1'b0;
	end
	always @(posedge i_clk) // Need to make certain here that we don't read
	if ((i_ce)&&(!iaddr[LGSPAN])) // and write the same address on
		imem[iaddr[(LGSPAN-1):0]] <= i_data; // the same clk

	//
	// Now, we have all the inputs, so let's feed the butterfly
	//
	// ib_sync is the synchronization bit to the butterfly.  It will
	// be tracked within the butterfly, and used to create the o_sync
	// value when the results from this output are produced
	initial ib_sync = 1'b0;
	always @(posedge i_clk)
	if (i_reset)
		ib_sync <= 1'b0;
	else if (i_ce)
	begin
		// Set the sync to true on the very first
		// valid input in, and hence on the very
		// first valid data out per FFT.
		ib_sync <= (iaddr==(1<<(LGSPAN)));
	end

	// Read the values from our input memory, and use them to feed first of two
	// butterfly inputs
	always	@(posedge i_clk)
	if (i_ce)
	begin
		// One input from memory, ...
		ib_a <= imem[iaddr[(LGSPAN-1):0]];
		// One input clocked in from the top
		ib_b <= i_data;
		// and the coefficient or twiddle factor
		ib_c <= cmem[iaddr[(LGSPAN-1):0]];
	end

	// The idle register is designed to keep track of when an input
	// to the butterfly is important and going to be used.  It's used
	// in a flag following, so that when useful values are placed
	// into the butterfly they'll be non-zero (idle=0), otherwise when
	// the inputs to the butterfly are irrelevant and will be ignored,
	// then (idle=1) those inputs will be set to zero.  This
	// functionality is not designed to be used in operation, but only
	// within a Verilator simulation context when chasing a bug.
	// In this limited environment, the non-zero answers will stand
	// in a trace making it easier to highlight a bug.
	reg	idle;
	generate if (ZERO_ON_IDLE)
	begin
		initial	idle = 1;
		always @(posedge i_clk)
		if (i_reset)
			idle <= 1'b1;
		else if (i_ce)
			idle <= (!iaddr[LGSPAN])&&(!wait_for_sync);

	end else begin

		initial idle = 0;

	end endgenerate

// For the formal proof, we'll assume the outputs of hwbfly and/or
// butterfly, rather than actually calculating them.  This will simplify
// the proof and (if done properly) will be equivalent.  Be careful of
// defining FORMAL if you want the full logic!
`ifndef	FORMAL
	//
	generate if (OPT_HWMPY)
	begin : HWBFLY
		hwbfly #(.IWIDTH(IWIDTH),.CWIDTH(CWIDTH),.OWIDTH(OWIDTH),
				.CKPCE(CKPCE), .SHIFT(BFLYSHIFT))
			bfly(i_clk, i_reset, i_ce, (idle)?0:ib_c,
				(idle || (!i_ce)) ? 0:ib_a,
				(idle || (!i_ce)) ? 0:ib_b,
				(ib_sync)&&(i_ce),
				ob_a, ob_b, ob_sync);
	end else begin : FWBFLY
		butterfly #(.IWIDTH(IWIDTH),.CWIDTH(CWIDTH),.OWIDTH(OWIDTH),
				.CKPCE(CKPCE),.SHIFT(BFLYSHIFT))
			bfly(i_clk, i_reset, i_ce,
					(idle||(!i_ce))?0:ib_c,
					(idle||(!i_ce))?0:ib_a,
					(idle||(!i_ce))?0:ib_b,
					(ib_sync&&i_ce),
					ob_a, ob_b, ob_sync);
	end endgenerate
`endif

	//
	// Next step: recover the outputs from the butterfly
	//
	// The first output can go immediately to the output of this routine
	// The second output must wait until this time in the idle cycle
	// oaddr is the output memory address, keeping track of where we are
	// in this output cycle.
	initial oaddr     = 0;
	initial o_sync    = 0;
	initial b_started = 0;
	always @(posedge i_clk)
	if (i_reset)
	begin
		oaddr     <= 0;
		o_sync    <= 0;
		// b_started will be true once we've seen the first ob_sync
		b_started <= 0;
	end else if (i_ce)
	begin
		o_sync <= (!oaddr[LGSPAN])?ob_sync : 1'b0;
		if (ob_sync||b_started)
			oaddr <= oaddr + 1'b1;
		if ((ob_sync)&&(!oaddr[LGSPAN]))
			// If b_started is true, then a butterfly output is available
			b_started <= 1'b1;
	end

	reg	[(LGSPAN-1):0]		nxt_oaddr;
	reg	[(2*OWIDTH-1):0]	pre_ovalue;
	always @(posedge i_clk)
	if (i_ce)
		nxt_oaddr[0] <= oaddr[0];
	generate if (LGSPAN>1)
	begin

		always @(posedge i_clk)
		if (i_ce)
			nxt_oaddr[LGSPAN-1:1] <= oaddr[LGSPAN-1:1] + 1'b1;

	end endgenerate

	// Only write to the memory on the first half of the outputs
	// We'll use the memory value on the second half of the outputs
	always @(posedge i_clk)
	if ((i_ce)&&(!oaddr[LGSPAN]))
		omem[oaddr[(LGSPAN-1):0]] <= ob_b;

	always @(posedge i_clk)
	if (i_ce)
		pre_ovalue <= omem[nxt_oaddr[(LGSPAN-1):0]];

	always @(posedge i_clk)
	if (i_ce)
		o_data <= (!oaddr[LGSPAN]) ? ob_a : pre_ovalue;

endmodule
