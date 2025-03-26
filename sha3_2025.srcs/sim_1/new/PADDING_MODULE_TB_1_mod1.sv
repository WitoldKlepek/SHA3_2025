
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


module PADDING_MODULE_TB_1_mod1();

localparam IN_BUS_WIDTH = 32;
localparam SHA3_VERSION = 512;
localparam MEMORY_DEPTH = 54;
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
    #50 in_valid    = 1'b1; //150
    #200 in_valid   = 1'b0; //350
    #200 in_valid   = 1'b1; //550
    #630 in_valid = 1'b0;   //1180 //po zwolnieniu bloka nie trwa wiadomoœæ
    #1000 $finish;    
end

initial begin
    #0  in_bus     =  {4{8'hF0}};
    #150 in_bus    =  {32'hFFFFFFFF};
    #170 in_bus    =  {32'h55555555}; //320
    #30  in_bus    =  {32'hCCCCCCCC}; //350
    #200 in_bus    =  {32'hFFFFFFFF}; //550  
    #170 in_bus    =  {32'h55555555}; //720
    #10  in_bus    =  {32'hEEEEEEEE}; //730
    #450 in_bus    =  {32'h11111111};//1180
    #10  in_bus    =  {32'hEEEEEEEE};//1190
end


initial begin
    #0  read_req_perm = 1'b0;
    #360 read_req_perm = 1'b1;
    #10  read_req_perm = 1'b0;  //30
    #400 read_req_perm = 1'b1;  //770
    #10  read_req_perm = 1'b0;  //780
    #400 read_req_perm = 1'b1;  //1180
    #10  read_req_perm = 1'b0;  //1190
end

endmodule
