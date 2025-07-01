`timescale 1ns / 1ps

`define PERMUTATION_VOLUME 1600
`define RESET_ACTIVE 1'b1
`define CE_ACTIVE 1'b1
`define Z_WIDTH 64
`define PERMUTATION_NUMBER 24

module ACC_PERMUTATION_MODULE #(
    parameter SHA3_VERSION = 512,
    parameter ACC_LEVEL = 2,
    localparam PERMUTATION_WORD_SIZE = `PERMUTATION_VOLUME - 2*SHA3_VERSION,
    localparam ACC_PERMUTATION_NUMBER = `PERMUTATION_NUMBER/ACC_LEVEL
)(
    input logic CLK,
    input logic CE,
    input logic A_RST,
    input logic [PERMUTATION_WORD_SIZE-1:0] PERMUTATION_WORD,
    output logic [`PERMUTATION_VOLUME-1:0] HASH_OUTPUT,
    output logic HASH_VALID,
    input logic WORD_WAITING_FROM_PADDING,
    input logic LAST_WORD_FROM_PADDING,
    input logic FIRST_MESSAGE_FROM_PADDING,
    output logic READ_REQ     
);

//logic [0:`PERMUTATION_VOLUME-1]  rnd_out,rnd_in, s_reg;
//logic [0:`Z_WIDTH-1] round_constant;

logic [0:`PERMUTATION_VOLUME-1] s_reg;
logic [0:`PERMUTATION_VOLUME-1] rnd_in_out_vec [0:ACC_LEVEL];
//logic [0:`PERMUTATION_VOLUME-1] rnd_in_vec [0:ACC_LEVEL-1];
logic [0:`Z_WIDTH-1] round_constant_vec [0:ACC_LEVEL-1];

//logic [$clog2(`PERMUTATION_NUMBER)-1:0] permutation_counter;
logic [$clog2(ACC_PERMUTATION_NUMBER)-1:0] permutation_counter;

logic first_message_f_padd_prev;
logic load_word_without_req_sig;
logic load_word;

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
                        //state   <=  LOAD_NEW_WORD;
                        state   <=  PROCESSING;
                    else
                        state   <=  INIT;
                LOAD_NEW_WORD:
                    state   <=  PROCESSING;
                PROCESSING:
                    if(permutation_counter == ACC_PERMUTATION_NUMBER - 1)
                        if(LAST_WORD_FROM_PADDING)
                            state   <= END_OF_MESSAGE_HASH_READY;
                        else
                            if(WORD_WAITING_FROM_PADDING)
                                state   <= LOAD_NEW_WORD;
                            else
                                state   <= NO_WORK;
                    else
                        state   <= PROCESSING;
                //REQ_FOR_NEW_WORD:
                    //state   <=  LOAD_NEW_WORD;
                END_OF_MESSAGE_HASH_READY:
                    if(WORD_WAITING_FROM_PADDING)
                        state   <=  LOAD_NEW_WORD;
                    else
                        state   <=  NO_WORK;
                NO_WORK:
                    if(WORD_WAITING_FROM_PADDING)
                        state   <=  LOAD_NEW_WORD;
                    else
                        state   <=  NO_WORK;
                default:
                    state   <=  INIT;
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
                    if(load_word_without_req_sig)
                        permutation_counter <=  permutation_counter + 1;
                    else
                        permutation_counter   <= 0;
                LOAD_NEW_WORD:
                    permutation_counter <=  permutation_counter + 1;
                PROCESSING:
                    if(permutation_counter == ACC_PERMUTATION_NUMBER - 1)
                        if(WORD_WAITING_FROM_PADDING)
                            permutation_counter <=  0;
                        else
                            permutation_counter <= ACC_PERMUTATION_NUMBER - 1;
                    else
                        permutation_counter <=  permutation_counter + 1;
                //REQ_FOR_NEW_WORD:
                    //permutation_counter <=  0;
                END_OF_MESSAGE_HASH_READY:
                    permutation_counter <=  0;    
                NO_WORK:
                    if(permutation_counter == ACC_PERMUTATION_NUMBER - 1)
                        if(WORD_WAITING_FROM_PADDING)
                            permutation_counter <=  0;
                    else
                        permutation_counter <=  permutation_counter;
                default:
                    permutation_counter <=  0;  
            endcase       
end

//assign READ_REQ = (state == LOAD_NEW_WORD)? 1'b1 : 1'b0;
assign READ_REQ =   ((permutation_counter == ACC_PERMUTATION_NUMBER - 1) && !LAST_WORD_FROM_PADDING && WORD_WAITING_FROM_PADDING) ? 1'b1
                    :((state == NO_WORK || state == END_OF_MESSAGE_HASH_READY) && WORD_WAITING_FROM_PADDING) ? 1'b1
                    : 1'b0;
                  
//pobranie wiadomosci


assign HASH_VALID = (state == END_OF_MESSAGE_HASH_READY)? 1'b1 : 1'b0;
//wyjscie


/*ROUND_CONSTANT_CONVERTER CONV1(
    .COUNTER(permutation_counter),
    .CONSTANT_VALUE(round_constant)
);*/

genvar i;
generate
    for(i = 0; i < ACC_LEVEL; i++) begin : RC_CONVERTERS
        ROUND_CONSTANT_CONVERTER RC_CONVS(
        .COUNTER(ACC_LEVEL*permutation_counter+i),
        .CONSTANT_VALUE(round_constant_vec[i])
        );
    end
endgenerate

assign load_word = (state == LOAD_NEW_WORD) || load_word_without_req_sig; 

//wejscie rundy
//assign rnd_in = load_word ? (state == {INIT, NO_WORK,HASH_VALID} ? {{(`PERMUTATION_VOLUME-PERMUTATION_WORD_SIZE){1'b0}},PERMUTATION_WORD} 
                    //:{s_reg ^ {{(`PERMUTATION_VOLUME-PERMUTATION_WORD_SIZE){1'b0}},PERMUTATION_WORD}})      
                    //: s_reg;
always_comb begin
    case(state)
        INIT: 
            rnd_in_out_vec[0] = {PERMUTATION_WORD,{(`PERMUTATION_VOLUME-PERMUTATION_WORD_SIZE){1'b0}}};
        LOAD_NEW_WORD:
                rnd_in_out_vec[0] = s_reg ^ {PERMUTATION_WORD,{(`PERMUTATION_VOLUME-PERMUTATION_WORD_SIZE){1'b0}}};
        PROCESSING:
            rnd_in_out_vec[0]  = s_reg;
    endcase  
end

/*always@(posedge CLK, posedge A_RST) begin
    if(A_RST == `RESET_ACTIVE)
        rnd_in  = 0;
    else
        if(CE == `CE_ACTIVE)
            case(state)
                INIT: 
                    rnd_in  <= {PERMUTATION_WORD,{(`PERMUTATION_VOLUME-PERMUTATION_WORD_SIZE){1'b0}}};
                LOAD_NEW_WORD:
                    rnd_in  <= s_reg ^ {PERMUTATION_WORD,{(`PERMUTATION_VOLUME-PERMUTATION_WORD_SIZE){1'b0}}};
                PROCESSING:
                    rnd_in  <= s_reg;
            endcase
end*/

//rejestr rundy
always@(posedge CLK, posedge A_RST) begin
	if(A_RST == `RESET_ACTIVE)
		s_reg	<=	{`PERMUTATION_VOLUME{1'b0}};
	else
		if(CE == `CE_ACTIVE)
		  //if(state == LOAD_NEW_WORD)
		      //s_reg	<=	{`PERMUTATION_VOLUME{1'b0}};    
		  //else 
		  if(state == PROCESSING | state == LOAD_NEW_WORD | load_word_without_req_sig)
		      s_reg	<=	rnd_in_out_vec[ACC_LEVEL];
		  else if(state == END_OF_MESSAGE_HASH_READY)
		      s_reg	<=	{`PERMUTATION_VOLUME{1'b0}};
end



/*RND RND1(
	.IN(rnd_in),
	.OUT(rnd_out),
	.RND_CONST(round_constant)
);*/

genvar j;
generate 
    for(i=0;i<ACC_LEVEL;i++) begin: ROUNDS
    RND RNDS(
    .IN(rnd_in_out_vec[i]),
    .OUT(rnd_in_out_vec[i+1]),
    .RND_CONST(round_constant_vec[i])
    );
    end
endgenerate

assign HASH_OUTPUT = s_reg;

endmodule
