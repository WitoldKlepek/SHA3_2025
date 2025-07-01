`timescale 1ns / 1ps

`define DEPTH 1024
`define PERMUTATION_VOLUME 1600

module SHA3_512_IN_32W #(
    parameter MEMORY_DEPTH = `DEPTH,
    localparam SHA3_VERSION = 512,
    localparam ACC_LEVEL = 2,
    localparam IN_BUS_WIDTH = 32
)   (
    input logic CLK,
    input logic A_RST,
    input logic CE,
    input logic [IN_BUS_WIDTH-1:0] IN_BUS,
    input logic IN_VALID,
    output logic BLOCKED_INPUT,
    output logic [SHA3_VERSION-1:0] SHA3_HASH_OUTPUT,
    output logic SHA3_HASH_VALID
);

logic [SHA3_VERSION-1:0] hash_output_permutation_out;

SHA3_MODULE_ACC #(
    .SHA3_VERSION(SHA3_VERSION),
    .IN_BUS_WIDTH(IN_BUS_WIDTH),
    .MEMORY_DEPTH(MEMORY_DEPTH),
    .ACC_LEVEL(ACC_LEVEL) 
)   SHA3_512_IN_32W   (
    .CLK(CLK),
    .A_RST(A_RST),
    .CE(CE),
    .IN_BUS(IN_BUS),
    .IN_VALID(IN_VALID),
    .BLOCKED_INPUT(BLOCKED_INPUT),
    .HASH_OUTPUT(hash_output_permutation_out),
    .HASH_VALID(SHA3_HASH_VALID) 
);

//assign SHA3_HASH_OUTPUT = hash_output_permutation_out[`PERMUTATION_VOLUME-1:`PERMUTATION_VOLUME-SHA3_VERSION];
assign SHA3_HASH_OUTPUT =  hash_output_permutation_out;
/*genvar j;
generate
    for(j = 0; j < SHA3_VERSION; j++) begin
        assign SHA3_HASH_OUTPUT[j] = hash_output_permutation_out[j+`PERMUTATION_VOLUME-SHA3_VERSION];
    end
endgenerate*/

endmodule