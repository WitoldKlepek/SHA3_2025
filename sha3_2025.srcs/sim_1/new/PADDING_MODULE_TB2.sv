
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


module PADDING_MODULE_TB2();

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
    #10 in_valid    = 1'b0; //160
    #10 in_valid    = 1'b1; //170 //2mess
    #10 in_valid    = 1'b0; //180
    #10 in_valid    = 1'b1; //190 //3mess
    #10 in_valid    = 1'b0; //200
    #10 in_valid    = 1'b1; //210 //4mess
    #10 in_valid    = 1'b0; //220
    #10 in_valid    = 1'b1; //230 //5mess
    #10 in_valid    = 1'b0; //240
    #10 in_valid    = 1'b1; //250 //6mess
    #10 in_valid    = 1'b0; //260
    #10 in_valid    = 1'b1; //270 //7mess
    #10 in_valid    = 1'b0; //280
    #10 in_valid    = 1'b1; //290 //8mess
    #10 in_valid    = 1'b0; //300
    #70 in_valid    = 1'b1; //370 //9mess
    #10 in_valid    = 1'b0; //380
    #1000 $finish;    
end

initial begin
    #0  in_bus      = {4{8'hF0}};
    #150 in_bus     = {32'hFFFFFFFF}; //1mess
    #10 in_bus      = {32'hEEEEEEEE}; //160
    #10 in_bus      = {32'hDDDDDDDD}; //170 //2mess
    #10 in_bus      = {32'hCCCCCCCC}; //180
    #10 in_bus      = {32'hBBBBBBBB}; //190 //3mess
    #10 in_bus      = {32'hAAAAAAAA}; //200
    #10 in_bus      = {32'h99999999}; //210 //4mess
    #10 in_bus      = {32'h88888888}; //220
    #10 in_bus      = {32'h77777777}; //230 //5mess
    #10 in_bus      = {32'h66666666}; //240
    #10 in_bus      = {32'h55555555}; //250 //6mess
    #10 in_bus      = {32'h44444444}; //260
    #10 in_bus      = {32'h33333333}; //270 //7mess
    #10 in_bus      = {32'h22222222}; //280
    #10 in_bus      = {32'h11111111}; //290 //8mess
    #10 in_bus      = {32'h00000000}; //300
    #70 in_bus       ={32'hF0F0F0F0}; //370   
end


initial begin
    #0  read_req_perm   = 1'b0;
    #250 read_req_perm  = 1'b1; //1read
    #10 read_req_perm   = 1'b0; //260
    #100 read_req_perm  = 1'b1; //360 //2read
    #10 read_req_perm   = 1'b0; //370
    #90 read_req_perm   = 1'b1; //460 //3read  
    #10 read_req_perm   = 1'b0; //470
    #90 read_req_perm   = 1'b1; //560 //4read  
    #10 read_req_perm   = 1'b0; //570
    #90 read_req_perm   = 1'b1; //660 //5read  
    #10 read_req_perm   = 1'b0; //670  
end

endmodule
