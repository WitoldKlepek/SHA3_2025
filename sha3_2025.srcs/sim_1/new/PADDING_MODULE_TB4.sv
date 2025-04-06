
`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 15.01.2025 21:35:42
// Design Name: 
// Module Name: PADDING_MODULE_TB
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


module PADDING_MODULE_TB4();

localparam IN_BUS_WIDTH = 32;
localparam SHA3_VERSION = 512;
localparam MEMORY_DEPTH = 72;
localparam PERMUTATION_WORD_WIDTH = 1600 - 2 * SHA3_VERSION;

logic clk, a_rst, ce;
logic [IN_BUS_WIDTH-1:0] in_bus;
logic in_valid;
logic [PERMUTATION_WORD_WIDTH - 1:0] permutation_word;
logic word_waiting, read_req_perm;
logic blocked_input;

PADDING_MODULE  #(
    .IN_BUS_WIDTH(IN_BUS_WIDTH),
    .SHA3_VERSION(SHA3_VERSION),
    .MEMORY_DEPTH(MEMORY_DEPTH)
)   UUT (
    .CLK(clk),
    .A_RST(a_rst),
    .CE(ce),
    .IN_BUS(in_bus),
    .IN_VALID(in_valid),   
    .PERMUTATION_WORD(permutation_word),   
    .WORD_WAITING(word_waiting),
    .READ_REQ_PERM(read_req_perm),
    .BLOCKED_INPUT(blocked_input) 
);

initial begin
	#0 clk = 1'b1;
	forever 
	#5 clk = ~clk;
end

initial begin
    #0 a_rst   =  1'b1;
    ce         =  1'b0;
    in_valid   =  1'b0;
    #50 a_rst  =  1'b0;
    #50 ce     =  1'b1; //100
    #50 in_valid    = 1'b1; //150 //1mess
    #360 in_valid   = 1'b0; //510
    #10 in_valid    = 1'b1; //520 //2mess
    #180 in_valid   = 1'b0; //700
    #20 in_valid    = 1'b1; //720 //3mess
    #10 in_valid    = 1'b0; //730
    #10 in_valid    = 1'b1; //740 //4mess
    #10 in_valid    = 1'b0; //750
    #1000 $finish;    
end

initial begin
    #0  in_bus      = {4{8'hFFFFFFF}};
    #150 in_bus     = {32'h00000000}; //1mess
    #10 in_bus      = {32'h11111111}; //160
    #340 in_bus     = {32'hEEEEEEEE}; //500
    #10 in_bus      = {32'hFFFFFFFF}; //510
    #10 in_bus      = {32'h00000000}; //520 //2mess
    #10 in_bus      = {32'h22222222}; //530
    #160 in_bus     = {32'hEEEEEEEE}; //690
    #10 in_bus      = {32'hFFFFFFFF}; //700
    #20 in_bus      = {32'h33333333}; //720 //3mess
    #10 in_bus      = {32'hFFFFFFFF}; //730
    #10 in_bus      = {32'h44444444}; //740 //4mess
    #10 in_bus      = {32'hFFFFFFFF}; //750
end


initial begin
    #0  read_req_perm   = 1'b0;
    #700 read_req_perm  = 1'b1; //1read
    #10 read_req_perm   = 1'b0; //710
    #10 read_req_perm   = 1'b1; //720 //2read
    #10 read_req_perm   = 1'b0; //730
end

endmodule
