`timescale 1ns / 1ps

module PERMUTATION_MODULE_TB();

localparam STATE_SIZE = 1600;
localparam SHA3_VERSION = 224;
localparam R_BLOCK_SIZE = STATE_SIZE - 2*SHA3_VERSION;

logic [0:STATE_SIZE-1] out, out_conv; 

logic [0:R_BLOCK_SIZE-1] in,in_conv;

logic CLK, A_RST, CE;

logic hash_valid;

logic word_waiting_from_padding, last_word_from_padding, first_message_from_padding;

logic read_req;

integer i,j;
function [STATE_SIZE-1:0] ConvertData1600; 
	input [STATE_SIZE-1:0] in_f;
	for (i = 0; i < STATE_SIZE/8; i++) begin
		for (j = 0; j < 8; j++) begin
			ConvertData1600[i*8+j] = in_f[(i+1)*8-j-1];
		end
	end
endfunction

function [R_BLOCK_SIZE-1:0] ConvertDataRBlock; 
	input [R_BLOCK_SIZE-1:0] in_f;
	for (i = 0; i < R_BLOCK_SIZE/8; i++) begin
		for (j = 0; j < 8; j++) begin
			ConvertDataRBlock[i*8+j] = in_f[(i+1)*8-j-1];
		end
	end
endfunction

PERMUTATION_MODULE #(
	.SHA3_VERSION(SHA3_VERSION)
	) UUT1 (
	.CLK(CLK),
	.A_RST(A_RST),
	.CE(CE),
	.PERMUTATION_WORD(in_conv),
	.HASH_OUTPUT(out_conv),
	.HASH_VALID(hash_valid),
    .WORD_WAITING_FROM_PADDING(word_waiting_from_padding),
    .LAST_WORD_FROM_PADDING(last_word_from_padding),
    .FIRST_MESSAGE_FROM_PADDING(first_message_from_padding),
    .READ_REQ(read_req)   
);

assign in_conv = ConvertDataRBlock(in);
assign out = ConvertData1600(out_conv);

initial begin
	#0 $monitor("TIME = %0t \n in = %h \n in_conv = %h \n out = %h ",$time, in, in_conv, out);
	   in  <=  {{R_BLOCK_SIZE/8}{8'b10100011}};
	#380 in <= {{56{8'b10100011}},{8'b00000110},{86{8'b00000000}},{8'b10000000}};
	//#5 in	<= {{40'h53587B9901},{{R_BLOCK_SIZE-48}{1'b0}},{8'h80}};
end

initial begin
    CE = 1'b1;
	CLK = 1'b1;
	forever 
	#5 CLK = ~CLK;
end

initial begin
	#0 A_RST = 1'b1;
	first_message_from_padding = 1'b1;
	word_waiting_from_padding  = 1'b0;
	last_word_from_padding     = 1'b0;
	#50 A_RST = 1'b0;
    #330 first_message_from_padding = 1'b0; //380
    word_waiting_from_padding = 1'b1;
    #240 last_word_from_padding  = 1'b1;
    word_waiting_from_padding = 1'b0;
	#1000 $finish;
end 


endmodule
