`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 13.01.2025 13:40:10
// Design Name: 
// Module Name: PADDING_MODULE
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
`define DEPTH 90

module PADDING_MODULE #(
    parameter IN_BUS_WIDTH = 32,
    parameter SHA3_VERSION = 512,
    parameter MEMORY_DEPTH = `DEPTH,
    localparam PERMUTATION_WORD_SIZE = `PERMUTATION_VOLUME - 2*SHA3_VERSION,
    localparam PTR_SIZE = $clog2(MEMORY_DEPTH),
    localparam RATIO =  PERMUTATION_WORD_SIZE / IN_BUS_WIDTH
)   (    
    input logic CLK,
    input logic CE,
    input logic A_RST,
    input logic [IN_BUS_WIDTH-1:0] IN_BUS,
    input logic IN_VALID,
    output logic [PERMUTATION_WORD_SIZE-1:0] PERMUTATION_WORD,
    output logic WORD_WAITING,
    input logic READ_REQ_PERM,
    output logic BLOCKED_INPUT
);

function automatic logic [PTR_SIZE:0] Add_Modulo_Depth (logic [PTR_SIZE:0] pointer, logic [PTR_SIZE-1:0] increment);
    logic [PTR_SIZE-1:0] pointer_short = pointer[PTR_SIZE-1:0];
    logic [PTR_SIZE:0] new_pointer;
    if(pointer_short + increment >= MEMORY_DEPTH) begin
        new_pointer = {pointer_short + increment - MEMORY_DEPTH};
        new_pointer[PTR_SIZE] = ~pointer[PTR_SIZE];
    end else
        new_pointer = pointer + increment;
    return new_pointer;   
endfunction

function automatic logic [PTR_SIZE:0] NextWordCalc (logic [PTR_SIZE:0] ptr );
    logic [PTR_SIZE:0] temp;
    temp[PTR_SIZE-1:0]  = (ptr[PTR_SIZE-1:0] / RATIO) * RATIO;
    temp[PTR_SIZE]  = ptr[PTR_SIZE];
    temp = Add_Modulo_Depth(temp, RATIO);
    return temp;
endfunction

function automatic logic [PTR_SIZE-1:0] Ptr_Distance (logic [PTR_SIZE:0] ptr_front, logic [PTR_SIZE:0] ptr_back);
    logic [PTR_SIZE-1:0] temp;
    if(ptr_front[PTR_SIZE] == ptr_back[PTR_SIZE]) begin
        temp = ptr_front - ptr_back;
    end else begin
        temp = MEMORY_DEPTH - ptr_back;
        temp += ptr_front[PTR_SIZE-1:0];
    end
    return temp;
endfunction

logic [IN_BUS_WIDTH-1:0] in_bus_latch;

logic [IN_BUS_WIDTH-1:0] memory[MEMORY_DEPTH];
logic [PTR_SIZE:0] wrPtr, nextWrPtr, nextWordPtr, lastCellPtr;
logic [PTR_SIZE-1:0] wrPtr_short, nextWrPtr_short, nextWordPtr_short, lastCellPtr_short;

logic [PTR_SIZE:0] rdPtr;
logic [PTR_SIZE-1:0] rdPtr_short;

logic buf_full, buf_empty;
logic is_data_entered;

logic [PTR_SIZE-1:0] distanceWrToRd;

assign wrPtr_short          = wrPtr[PTR_SIZE-1:0];
assign nextWrPtr_short      = nextWrPtr[PTR_SIZE-1:0];
assign nextWordPtr_short    = nextWordPtr[PTR_SIZE-1:0];
assign lastCellPtr_short    = lastCellPtr[PTR_SIZE-1:0];

assign rdPtr_short          = rdPtr[PTR_SIZE-1:0];

assign distanceWrToRd = Ptr_Distance(nextWrPtr, rdPtr);
//assign WORD_WAITING = (nextWrPtr >= Add_Modulo_Depth(rdPtr, RATIO) )? 1'b1 : 1'b0;
assign WORD_WAITING = distanceWrToRd > RATIO ? 1'b1 : ((distanceWrToRd == RATIO & state == END_OF_MESSAGE) ? 1'b1 :1'b0);

typedef enum {  INIT,
                MESSAGE,
                END_OF_MESSAGE,
                NO_MESSAGE} padding_fsm;


padding_fsm state;

//assign is_data_entered = IN_VALID & !buf_full; //IN_VALID & !BLOCKED_INPUT
assign is_data_entered = (IN_VALID & !buf_full)  | (buf_full & IN_VALID & READ_REQ_PERM); //IN_VALID & !BLOCKED_INPUT
always_ff @(posedge CLK, posedge A_RST) begin
    if(A_RST == `RESET_ACTIVE) 
        state   <=  INIT;
    else
        if(CE == `CE_ACTIVE) 
            case(state)
                INIT:
                    //rozpoczêcie pierwsze wiadomoœci
                    if(is_data_entered)                    
                        state   <=  MESSAGE;
                MESSAGE:
                    //koniec wiadomoœci
                    if(!is_data_entered)
                        if(buf_full)
                        //jeœli bufor zaczyna byæ pe³ny to nie mo¿na zakoñczyæ wiadomoœci
                        //paddingiem, bo nadpisze nastêpn¹!
                            state   <=  NO_MESSAGE;
                        else
                            state   <=  END_OF_MESSAGE;
                END_OF_MESSAGE: begin
                    if(!is_data_entered)
                        state   <=  NO_MESSAGE;
                    else
                        state   <=  MESSAGE;
                end                   
                NO_MESSAGE:
                    //w zasadzie jak init
                    //czekamy na rozpoczêcie nowej wiadomoœci
                    if(is_data_entered)
                        state   <=  MESSAGE;
                default:
                    state   <=  INIT;      
            endcase
end

//wydaje mi siê ¿e ptr nastêpnego s³owa jest logik¹ kombinacyjn¹

 
assign nextWordPtr = NextWordCalc(wrPtr);
//assign lastCellPtr = Add_Modulo_Depth(nextWordPtr, MEMORY_DEPTH-1);
assign lastCellPtr  = (nextWordPtr_short == 0) ? {!nextWordPtr[PTR_SIZE],MEMORY_DEPTH-1} : nextWordPtr - 1;
assign nextWrPtr = (state == MESSAGE || buf_empty) ? Add_Modulo_Depth(wrPtr, 1) : nextWordPtr;
        
//póki co bez logiki modulo!!!
//pointery wpisywania wiadomoœci
always_ff @(posedge CLK, posedge A_RST) begin
    if(A_RST == `RESET_ACTIVE) begin
        wrPtr       <=  0;
    end else
        if(CE == `CE_ACTIVE)
            case(state)
                INIT: begin
                    wrPtr   <=  0;
                end
                MESSAGE: begin
                    //if(is_data_entered
                    if(is_data_entered | !buf_full)                     
                        wrPtr   <=  nextWrPtr;
                    //else
                                     
                end
                END_OF_MESSAGE: begin
                    if(is_data_entered)
                        wrPtr   <=  nextWrPtr;                      
                end
                NO_MESSAGE: begin
                    if(is_data_entered)
                        wrPtr   <=  nextWrPtr;   
                end
                default: begin
                    //jak init bez nowej wiadomoœci
                    //wrPtr   <=  0;
                end            
            endcase                      
end

//pointer odczytywania wiadomoœci
always_ff @(posedge CLK, posedge A_RST) begin
    if(A_RST == `RESET_ACTIVE)
        rdPtr   <=  0;
    else
        if(CE == `CE_ACTIVE)
            if(READ_REQ_PERM)
                rdPtr   <=  Add_Modulo_Depth(rdPtr, RATIO);                   
end

//sygnalizacja pustego buforu
assign buf_empty = (wrPtr == rdPtr )? 1'b1 : 1'b0;
//sygnalizacja pe³nego buforu
//assign buf_full = ( (wrPtr_short == rdPtr_short) && (wrPtr[PTR_SIZE] != rdPtr[PTR_SIZE]) ) ? 1'b1 : 1'b0; 
assign buf_full = ( (nextWrPtr_short == rdPtr_short) && (nextWrPtr[PTR_SIZE] != rdPtr[PTR_SIZE]) ) ? 1'b1 : 1'b0; 
assign BLOCKED_INPUT = buf_full;

always_ff @(posedge CLK, posedge A_RST) begin
    if(A_RST == `RESET_ACTIVE) 
        in_bus_latch    <=  0;
    else
        if(CE == `CE_ACTIVE)
            in_bus_latch    <=  IN_BUS; 
end


//wpisywanie do pamiêci
always_comb
begin
    if(state == END_OF_MESSAGE)
    //wtedy trzeba uzupe³niæ pamiêc o padding
        for(int i = wrPtr_short ; i <= lastCellPtr_short;  i++) begin
            if(lastCellPtr_short - wrPtr_short == 0)
                memory[wrPtr_short+1+i]   =   {3'b011,{(IN_BUS_WIDTH-4){1'b0}},1'b1};
            else
                case(i)
                        wrPtr_short:
                            memory[i]  =   {3'b011,{(IN_BUS_WIDTH-3){1'b0}}};
                        lastCellPtr_short: //tu mo¿e byæ problem przy przejœciu przez 0?
                            memory[i]  =   {{(IN_BUS_WIDTH-2){1'b0}}, 1'b1};
                        default:
                            memory[i]  =   {{IN_BUS_WIDTH{1'b0}}};
                    endcase
            end   
    else if(state == MESSAGE /*&& is_data_entered*/)
        //gdy wiadomoœæ wpisuj normalnie
        memory[wrPtr_short] = in_bus_latch;
end

//odczyt z pamiêci
genvar j;
generate
    for(j = 0; j < RATIO; j++) begin
        assign PERMUTATION_WORD[(RATIO-j) * IN_BUS_WIDTH - 1 : (RATIO-j-1) * IN_BUS_WIDTH]
                =   memory[rdPtr_short+j];
    end
endgenerate

endmodule
