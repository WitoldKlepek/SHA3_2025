`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 17.05.2025 16:16:12
// Design Name: 
// Module Name: SHA3_224_IN_32W
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


`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 16.05.2025 15:01:54
// Design Name: 
// Module Name: SHA3_MODULE
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

`define DEPTH 1024
`define PERMUTATION_VOLUME 1600

module SHA3_224_IN_32W #(
    parameter MEMORY_DEPTH = `DEPTH,
    localparam SHA3_VERSION = 224,
    localparam IN_BUS_WIDTH = 32
)   (
    input logic CLK,
    input logic A_RST,
    input logic CE,
    input logic [IN_BUS_WIDTH-1:0] IN_BUS,
    input logic IN_VALID,
    output logic BLOCKED_INPUT,
    output logic HASH_OUTPUT,
    output logic HASH_VALID
);

logic [`PERMUTATION_VOLUME-1:0] hash_output_permutation_out;

SHA3_MODULE #(
    .SHA3_VERSION(SHA3_VERSION),
    .IN_BUS_WIDTH(IN_BUS_WIDTH),
    .MEMORY_DEPTH(MEMORY_DEPTH)    
)   SHA3_224_IN_32W   (
    .CLK(CLK),
    .A_RST(A_RST),
    .CE(CE),
    .IN_BUS(IN_BUS),
    .IN_VALID(IN_VALID),
    .BLOCKED_INPUT(BLOCKED_INPUT),
    .HASH_OUTPUT(hash_output_permutation_out),
    .HASH_VALID(HASH_VALID) 
);

assign HASH_OUTPUT = hash_output_permutation_out[`PERMUTATION_VOLUME-1:`PERMUTATION_VOLUME-SHA3_VERSION];

endmodule