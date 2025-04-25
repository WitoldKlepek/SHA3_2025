`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 15.04.2025 16:50:28
// Design Name: 
// Module Name: PERMUTATION_MODULE
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

`define PERMUTATION_VOLUME 1600
`define RESET_ACTIVE 1'b1
`define CE_ACTIVE 1'b1
`define Z_WIDTH 64
`define PERMUTATION_NUMBER 24

module PERMUTATION_MODULE #(
    parameter SHA3_VERSION = 512,
    localparam PERMUTATION_WORD_SIZE = `PERMUTATION_VOLUME - 2*SHA3_VERSION,
)(
    input logic CLK,
    input logic CE,
    input logic A_RST,
    input logic [PERMUTATION_WORD_SIZE-1] PERMUTATION_WORD,
    output logic [SHA3_VERSION_SIZE-1:0] HASH_OUTPUT,
    output logic HASH_VALID,
    input logic WORD_WAITING_FROM_PADDING,
    input logic LAST_WORD_FROM_PADDING,
    input logic FIRST_MESSAGE_FROM_PADDING,
    output logic READ_REQ     
);

logic [0:`PERMUTATION_VOLUME-1]  rnd_out,rnd_in, s_reg;
logic [0:`Z_WIDTH-1] round_constant;

logic [$clog2(`PERMUTATION_NUMBER)-1:0] permutation_counter;

logic first_message_f_padd_prev;
logic load_word_without_req_sig;

typedef enum {  INIT,
                LOAD_NEW_WORD,
                PROCESSING,
                //REQ_FOR_NEW_WORD,
                END_OF_MESSAGE_HASH_READY,
                NO_WORK} permutation_fsm;

permutation_fsm state;

//detekcja pierwszej pobranej wiadomoœci
always_ff @(posedge CLK, posedge A_RST) begin
    if(A_RST == `RESET_ACTIVE)
        first_message_f_padd_prev <=  1'b0;
    else
        if(CE == `CE_ACTIVE)
            first_message_f_padd_prev   <= FIRST_MESSAGE_FROM_PADDING; 
        end
end

assign load_word_without_req_sig = !FIRST_MESSAGE_FROM_PADDING & first_message_f_padd_prev;


//fsm              
always_ff @(posedge CLK, posedge A_RST) begin
    if(A_RST == `RESET_ACTIVE)
        state   <= INIT;
    else
        if(CE == `CE_ACTIVE)
            case(state)
                INIT:
                    if(load_word_without_req_sig)
                        state   <=  LOAD_NEW_WORD;
                    else
                        state   <=  INIT;
                LOAD_NEW_WORD:
                    state   <=  PROCESSING;
                PROCESSING:
                    if(permutation_counter == `PERMUTATION_NUMBER - 1)
                        if(LAST_WORD_FROM_PADDING)
                            state   <= END_OF_MESSAGE_HASH_READY;
                        else
                            state   <= LOAD_NEW_WORD;
                    else
                        state   <= PROCESSING;
                //REQ_FOR_NEW_WORD:
                    //state   <=  LOAD_NEW_WORD;
                END_OF_MESSAGE_HASH_READY:
                    if(WORD_WAITING)
                        state   <=  LOAD_NEW_WORD;
                    else
                        state   <=  NO_WORK;
                NO_WORK:
                    if(WORD_WAITING)
                        state   <=  LOAD_NEW_WORD;
                default:
            endcase
        
end

//licznik permutacji
always_ff @(posedge CLK, posedge A_RST) begin
    if(A_RST == `RESET_ACTIVE)
        permutation_counter   <= 0;
    else
        if(CE == `CE_ACTIVE)
            case(state)
                INIT:
                    //chyba nic?
                LOAD_NEW_WORD:
                    permutation_counter <=  permutation_counter + 1;
                PROCESSING:
                    if(permutation_counter == `PERMUTATION_NUMBER - 1)
                        permutation_counter <=  0;
                    else
                        permutation_counter <=  permutation_counter + 1;
                //REQ_FOR_NEW_WORD:
                    //permutation_counter <=  0;
                END_OF_MESSAGE_HASH_READY:
                    permutation_counter <=  0;    
                NO_WORK:
                default:
            endcase
        
end

assign READ_REQ = (state == LOAD_NEW_WORD)? 1'b1 : 1'b0;
//pobranie wiadomosci


assign HASH_VALID = (state == END_OF_MESSAGE_HASH_READY)? 1'b1 : 1'b0;
//wyjscie


ROUND_CONSTANT_CONVERTER CONV1(
    .COUNTER(permutation_counter),
    .CONSTANT_VALUE(round_constant)
)

RND RND1(
	.IN(rnd_in),
	.OUT(rnd_out),
	.RND_CONST(round_constant)
);

endmodule
