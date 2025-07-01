`timescale 1ns / 1ps

`define DEPTH 1024
`define PERMUTATION_VOLUME 1600

module SHA3_MODULE_ACC #(
    parameter SHA3_VERSION = 224,
    parameter IN_BUS_WIDTH = 32,
    parameter MEMORY_DEPTH = `DEPTH,
    parameter ACC_LEVEL = 2,
    localparam PERMUTATION_WORD_SIZE = `PERMUTATION_VOLUME - 2*SHA3_VERSION
)   (
    input logic CLK,
    input logic A_RST,
    input logic CE,
    input logic [IN_BUS_WIDTH-1:0] IN_BUS,
    input logic IN_VALID,
    output logic BLOCKED_INPUT,
    output logic [SHA3_VERSION - 1:0] HASH_OUTPUT,
    output logic HASH_VALID
);

logic [PERMUTATION_WORD_SIZE-1:0] word_padding_out_permutation_in;
logic word_waiting_padding_out_permutation_in;        

logic read_req_permutation_out_padding_in;

logic last_word_of_mess_padding_out_permutation_in, first_mess_af_init_padding_out_permutation_in;

logic [`PERMUTATION_VOLUME-1:0] hash_output_permutation_out;
       
PADDING_MODULE #(
    .IN_BUS_WIDTH(IN_BUS_WIDTH),
    .SHA3_VERSION(SHA3_VERSION),
    .MEMORY_DEPTH(MEMORY_DEPTH)
)   PADDING (
    .CLK(CLK),
    .A_RST(A_RST),
    .CE(CE),
    .IN_BUS(IN_BUS),
    .IN_VALID(IN_VALID),
    .PERMUTATION_WORD(word_padding_out_permutation_in),
    .WORD_WAITING(word_waiting_padding_out_permutation_in),
    .READ_REQ_PERM(read_req_permutation_out_padding_in),
    .BLOCKED_INPUT(BLOCKED_INPUT),
    .LAST_WORD_OF_MESSAGE(last_word_of_mess_padding_out_permutation_in),
    .FIRST_MESSAGE_AFTER_INIT(first_mess_af_init_padding_out_permutation_in)
);

ACC_PERMUTATION_MODULE #(
    .SHA3_VERSION(SHA3_VERSION),
    .ACC_LEVEL(ACC_LEVEL)
)   PERMUTATION (
    .CLK(CLK),
    .A_RST(A_RST),
    .CE(CE),
    .PERMUTATION_WORD(word_padding_out_permutation_in),
    .HASH_OUTPUT(hash_output_permutation_out),
    .HASH_VALID(HASH_VALID),
    .WORD_WAITING_FROM_PADDING(word_waiting_padding_out_permutation_in),
    .LAST_WORD_FROM_PADDING(last_word_of_mess_padding_out_permutation_in),
    .FIRST_MESSAGE_FROM_PADDING(first_mess_af_init_padding_out_permutation_in),
    .READ_REQ(read_req_permutation_out_padding_in)
);

assign HASH_OUTPUT = hash_output_permutation_out[`PERMUTATION_VOLUME-1:`PERMUTATION_VOLUME-SHA3_VERSION];

endmodule
