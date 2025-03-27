
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


module PADDING_MODULE_TB3();

localparam IN_BUS_WIDTH = 32;
localparam SHA3_VERSION = 512;
localparam MEMORY_DEPTH = 108;
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
    #160 in_valid   = 1'b0; //310 //16clk (18-2)
    #190 in_valid   = 1'b1; //500 //2mess
    #170 in_valid   = 1'b0; //670 //17clk (18-1)
    #330 in_valid   = 1'b1; //1000 //3mess
    #180 in_valid   = 1'b0; //1180 //18clk (18-0)
    #320 in_valid   = 1'b1; //1500 //4mess
    #190 in_valid   = 1'b0; //1690 //19clk (18+1)
    #1000 $finish;    
end

initial begin
    #0  in_bus      = {4{8'hFFFFFFF}};
    #150 in_bus     = {32'h00000000}; //1mess
    #10 in_bus      = {32'h11111111}; //160
    #140 in_bus     = {32'h00000000}; //300
    #10 in_bus      = {32'hFFFFFFFF}; //310
    #190 in_bus     = {32'h00000000}; //500 //2mess
    #10 in_bus      = {32'h22222222}; //510
    #150 in_bus     = {32'h00000000}; //660
    #10 in_bus      = {32'hFFFFFFFF}; //670
    #330 in_bus     = {32'h00000000}; //1000 //3mess
    #10 in_bus      = {32'h33333333}; //1010
    #160 in_bus     = {32'h00000000}; //1170
    #10 in_bus      = {32'hFFFFFFFF}; //1180
    #320 in_bus     = {32'h00000000}; //1500 //4mess
    #10 in_bus      = {32'h44444444}; //1510
    #170 in_bus     = {32'h00000000}; //1680
    #10 in_bus      = {32'hFFFFFFFF}; //1690
end


initial begin
    #0  read_req_perm   = 1'b0;
    #2000   read_req_perm   = 1'b1; //1read
    #10     read_req_perm   = 1'b0; //2010
    #90     read_req_perm   = 1'b1; //2100 //2read
    #10     read_req_perm   = 1'b0; //2110
    #90     read_req_perm   = 1'b1; //2200 //3read
    #10     read_req_perm   = 1'b0; //2210
    #90     read_req_perm   = 1'b1; //2300 //4read
    #10     read_req_perm   = 1'b0; //2310
    #90     read_req_perm   = 1'b1; //2400 //5read
    #10     read_req_perm   = 1'b0; //2410
    #90     read_req_perm   = 1'b1; //2500 //6read
    #10     read_req_perm   = 1'b0; //2510
end

endmodule
