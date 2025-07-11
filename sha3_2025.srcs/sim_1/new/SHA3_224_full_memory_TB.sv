`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05.07.2025 19:14:18
// Design Name: 
// Module Name: SHA3_224_full_memory_TB
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


module SHA3_224_full_memory_TB();

localparam DATA_INPUT_WIDTH = 32;
localparam MEMORY_DEPTH = 2;
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
    #4330 data_in_valid   = 1'b0; //1mess end 4480
    #10 data_in_valid   = 1'b1; //2mess start 4490
    #4330 data_in_valid   = 1'b0; //1mess end 8820
    #1000 $finish;
    
end

initial begin
    #0 data_in_seq      =  {4{8'hF0}};
    #150 data_in_seq    =  {32'h91D5B3F7};
    #720 data_in_seq    =  {32'hFFFFFFFF}; //1240
    #720 data_in_seq    =  {32'h91D5B3F7}; //
    #720 data_in_seq    =  {32'hFFFFFFFF}; //
    #720 data_in_seq    =  {32'h91D5B3F7}; //
    #720 data_in_seq    =  {32'hFFFFFFFF}; //
    #720 data_in_seq    =  {32'h91D5B3F7}; //
    #10 data_in_seq     =  {32'hFFFFFFFF}; //
    #10 data_in_seq     =  {32'h91D5B3F7};
    #720 data_in_seq    =  {32'hFFFFFFFF}; //1240
    #720 data_in_seq    =  {32'h91D5B3F7}; //
    #720 data_in_seq    =  {32'hFFFFFFFF}; //
    #720 data_in_seq    =  {32'h91D5B3F7}; //
    #720 data_in_seq    =  {32'hFFFFFFFF}; //
    #720 data_in_seq    =  {32'h91D5B3F7}; //
end

endmodule
