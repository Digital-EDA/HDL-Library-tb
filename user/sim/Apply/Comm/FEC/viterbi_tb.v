`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 07.07.2022 15:24:48
// Design Name:
// Module Name: tb_viterbi_enc
// Project Name:
// Target Devices:
// Tool Versions:
// Description:
//
// Dependencies:
//
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
//
//////////////////////////////////////////////////////////////////////////////////


module viterbi_tb();

    localparam MAIN_FRE = 100; //unit MHz

    reg  clock = 1;
    reg  reset = 1;

    always begin
        #(500/MAIN_FRE) clock <= ~clock;
    end

    always begin
        #50 reset <= 0;
    end

    reg  valid;
    wire data;

    localparam  size = 11;
    // localparam [size*2+4:0] polinimError = 28'b0000000000000001001000;
    localparam  [size*2+4:0] polinimError = 28'b0000000000000000000000;
    reg  [size-1:0] modData = 11'b11001111010;
    reg  [10:0]  index;
    always @(posedge clock or posedge reset) begin
        if (reset) begin
            valid <= 0;
        end
        else begin
            if (index >= size) begin
                valid <= 0;
            end else begin
                valid <= 1;
            end
        end
    end

    always @(posedge clock or posedge reset) begin
        if (reset) begin
            index <= 0;
        end
        else begin
            if (valid) begin
                if (index == (size-1)) begin
                    index <= 0;
                end
                else begin
                    index <= index + 1;
                end
            end
        end
    end

    assign data = modData[index];

    wire validData;
    wire [1:0] outData;

    convenc #(
        .POLINOM_DEPTH(7),
        .POLINOM_VSET0(7'b1001111),
        .POLINOM_VSET1(7'b1101101),
        .DEFAULT_STATE(7'b0000000))
    enc(
        .clock(clock),
        .reset(reset),
        .idata(data),
        .ivalid(valid),
        .odata(outData),
        .ovalid(validData)
    );

    wire [1:0]	bits_out;

    xconvenc u_xconvenc(
        //ports
        .clk        	( clock      	),
        .rst      		( reset      	),
        .enc_en   		( valid   		),
        .bit_in   		( data   		),
        .bits_out 		( bits_out 		)
    );

    reg  [1:0]  bits_test;
    always @(posedge clock or posedge reset) begin
        if (reset) begin
            bits_test <= 0;
        end
        else begin
            bits_test <= bits_out;
            if (validData && (bits_test != outData) && ($time() > 0)) begin
                $display("%t\terr: xconvenc:%d\tconvenc:%d", $time(), bits_test, outData);
            end
        end
    end

    wire [1:0] dataDecIn;

    reg  [10:0]  count = 0;
    always @(posedge clock or posedge reset) begin
        if (reset) begin
            count <= 0;
        end
        else begin
            if (validData) begin
                if (count == size) begin
                    count <= 0;
                end
                else begin
                    count <= count + 1;
                end
            end
        end
    end

    assign dataDecIn = outData ^ {polinimError[count*2+1], polinimError[count*2]};

    wire [1:0] dec_valid;
    wire [1:0] dec_data;
    wire       dec_error;

    viterbi_dec #(
        .p_size_polinom(7),
        .p_polinom_0(7'b1001111),
        .p_polinom_1(7'b1101101),
        .p_defoult_state(7'b0000000))
    dec(
        .i_clk(clock),
        .i_reset(1'b0),
        .i_data(dataDecIn),
        .i_valid({validData, validData}),
        .o_data(dec_valid),
        .o_valid(dec_data),
        .o_error(dec_error)
    );

    reg [size+1:0] resData = 0;
    reg [4:0] counter = 0;

    always @(posedge clock) begin
        if(dec_valid[1]) begin
            counter <= counter + 2;
            resData[counter+1] <= dec_data[0];
            resData[counter] <= dec_data[1];
        end
        else if(dec_valid[0]) begin
            counter <= counter + 1;
            resData[counter] <= dec_data[0];
        end
    end

    wire [1:0] speed_data;
    wire [1:0] speed_valid;

    viterbi_speed_map #(
        .p_auto_pol(1), 
        .p_speed_size(3), 
        .p_speed_pol0(3'b101), 
        .p_speed_pol1(3'b011)) 
    map (
        .i_clk(clock),
        .i_reset(1'b0),
        .i_data(dataDecIn),
        .i_valid(validData),
        .i_speed(2),
        .o_data(speed_data),
        .o_valid(speed_valid)
    );

    wire [6:0] dec_valid2;
    wire [6:0] dec_data2;
    wire dec_valid_d12;
    wire dec_data_d12;
    wire dec_error2;

    viterbi_dec #(
        .p_size_polinom(7), 
        .p_polinom_0(7'b1001111), 
        .p_polinom_1(7'b1101101), 
        .p_defoult_state(7'b0000000)) 
    dec2(
        .i_clk(clock),
        .i_reset(1'b0),
        .i_data(speed_data),
        .i_valid(speed_valid),
        .o_data(dec_data2),
        .o_valid(dec_valid2),
        .o_error(dec_error2)
    );

    reg [size+1:0] resData2 = 0;
    reg [4:0] counter2 = 0;

    always @(posedge clock) begin
        if(dec_valid2[3]) begin
            counter2 <= counter2 + 4;
            resData2[counter2+3] <= dec_data2[0];
            resData2[counter2+2] <= dec_data2[1];
            resData2[counter2+1] <= dec_data2[2];
            resData2[counter2+0] <= dec_data2[3];
        end
        else if(dec_valid2[2]) begin
            counter2 <= counter2 + 3;
            resData2[counter2+2] <= dec_data2[0];
            resData2[counter2+1] <= dec_data2[1];
            resData2[counter2+0] <= dec_data2[2];
        end
        else if(dec_valid2[1]) begin
            counter2 <= counter2 + 2;
            resData2[counter2+1] <= dec_data2[0];
            resData2[counter2+0] <= dec_data2[1];
        end
        else if(dec_valid2[0]) begin
            counter2 <= counter2 + 1;
            resData2[counter2+0] <= dec_data2[0];
        end
    end

    initial begin
        $dumpfile("/home/icer/Project/library/user/sim/Apply/Comm/FEC/viterbi.vcd");
        $dumpvars(0, viterbi_tb);
        #1000 $finish;
    end


endmodule
