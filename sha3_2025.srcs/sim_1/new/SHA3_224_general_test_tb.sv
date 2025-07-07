`timescale 1ns / 1ps

/*
10mess 89ABCDEF X 10: hash: 13CF17EB0A8E6B1FF7B8E7F6CF0F348F0CCE31C51653327C648B012613CF17EB0A8E6B1FF7B8E7F6CF0F348F0CCE31C51653327C648B0113
15mess 89ABCDEF X 15: hash: BD6C587B2FCE5089AA4D4AE75783F70A7CE827F9AF22848E01934DFFBD6C587B2FCE5089AA4D4AE75783F70A7CE827F9AF22848E01934DBD
20mess 89ABCDEF X 20: hash: B38664ECDF5D8A33F5680A581615012CA74CB3E6465DBF4B1C242BB9B38664ECDF5D8A33F5680A581615012CA74CB3E6465DBF4B1C242BB3
25mess 89ABCDEF X 25: hash: A7124464CA5B937305D377277D09A4E31B692A9D51471455FC6609C0A7124464CA5B937305D377277D09A4E31B692A9D51471455FC6609A7
30mess 89ABCDEF X 30: hash: DE6FD56647F0056D2061AE530B569E9068873665059C16A91038DE83DE6FD56647F0056D2061AE530B569E9068873665059C16A91038DEDE
35mess 89ABCDEF X 35: hash: 2C7616D4950B8D977DD64D9FB528EF3C92C3DDE9004E0423EECEBDEB2C7616D4950B8D977DD64D9FB528EF3C92C3DDE9004E0423EECEBD2C
36mess 89ABCDEF X 36: hash: 73A35DD659A89B96D30C45BFD752F3099B77B227B5AEC69DC751488273A35DD659A89B96D30C45BFD752F3099B77B227B5AEC69DC7514873
37mess 89ABCDEF X 37: hash: 1A7B297732AE5D12F7B3F6DD6394016802A9896DC49AE4B0137773271A7B297732AE5D12F7B3F6DD6394016802A9896DC49AE4B01377731A
*/


module SHA3_224_general_test_TB();

localparam DATA_INPUT_WIDTH = 32;
localparam MEMORY_DEPTH = 5;
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
    #10 data_in_valid   = 1'b1; //3mess start 420
    #200 data_in_valid  = 1'b0; //3mess end 620
    #10 data_in_valid   = 1'b1; //4mess start 630
    #250 data_in_valid  = 1'b0; //4mess end 880
    #10 data_in_valid   = 1'b1; //5mess start 890
    #300 data_in_valid  = 1'b0; //5mess end 1190
    #10 data_in_valid   = 1'b1; //6mess start 1200
    #350 data_in_valid  = 1'b0; //6mess end 1550
    #10 data_in_valid   = 1'b1; //7mess start 1560
    #360 data_in_valid  = 1'b0; //7mess end 1920
    #10 data_in_valid   = 1'b1; //8mess start 1930
    #370 data_in_valid  = 1'b0; //8mess end 2300
    #1000 $finish;
    
end

initial begin
    #0 data_in_seq      =  {4{8'hF0}};
    #140 data_in_seq    =  {32'h91D5B3F7};
    #2160 data_in_seq   =   {4{8'hF0}};
end

endmodule
