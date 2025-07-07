`timescale 1ns / 1ps

/*
10mess 89ABCDEF X 10: hash: 13CF17EB0A8E6B1FF7B8E7F6CF0F348F0CCE31C51653327C648B012613CF17EB0A8E6B1FF7B8E7F6CF0F348F0CCE31C51653327C648B0113
15mess 89ABCDEF X 15: hash: BD6C587B2FCE5089AA4D4AE75783F70A7CE827F9AF22848E01934DFFBD6C587B2FCE5089AA4D4AE75783F70A7CE827F9AF22848E01934DBD

*/


module SHA3_224_short_mess_TB();

localparam MEMORY_DEPTH = 10;
localparam DATA_INPUT_WIDTH = 32;
localparam OUTPUT_HASH_SIZE = 224;
localparam PERMUTATION_INPUT_WORD_WIDTH = 1600 - 2 * OUTPUT_HASH_SIZE;

logic [DATA_INPUT_WIDTH-1:0] data_in_seq;
logic [OUTPUT_HASH_SIZE-1:0] hash_out;
logic clk, a_rst, ce, data_in_valid, hash_out_valid,blocked_in;

SHA3_224_IN_32W #(
    .MEMORY_DEPTH_RATIO_SIZED(MEMORY_DEPTH)
)   UUT (
    .CLK(clk),
    .A_RST(a_rst),
    .CE(ce),
    .IN_BUS(data_in_seq),
    .IN_VALID(data_in_valid),
    .BLOCKED_INPUT(blocked_in),
    .SHA3_HASH_OUTPUT(hash_out),
    .SHA3_HASH_VALID(hash_out_valid)
);

initial begin
	#0 clk = 1'b1;
	forever 
	#5 clk = ~clk;
end

initial begin
    #0 a_rst       =  1'b1;
    ce          =  1'b0;
    data_in_valid   =  1'b0;
    #50 a_rst   =  1'b0;
    #50 ce      =  1'b1; //100
    #50 data_in_valid   = 1'b1; //1mess start 150
    #100 data_in_valid  = 1'b0; //1mess end 250
    #10 data_in_valid   = 1'b1; //2mess start 260
    #150 data_in_valid  = 1'b0; //2mess end 410
    #1000 $finish;
    
end

initial begin
    #0 data_in_seq      =  {4{8'hF0}};
    #140 data_in_seq    =  {32'h91D5B3F7};
    #270 data_in_seq   =   {4{8'hF0}};
end

endmodule
