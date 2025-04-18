`define STATE_SIZE 1600
`define CD_SIZE 320
`define Z_WIDTH 64

module PI (
	input logic [0:`STATE_SIZE-1] IN,
	output logic [0:`STATE_SIZE-1] OUT);
	
logic	[0:`STATE_SIZE-1] out_reg;

localparam integer new_position_array [0:`STATE_SIZE/`Z_WIDTH-1] = 
'{0,10,20,5,15,
16,1,11,21,6,
7,17,2,12,22,
23,8,18,3,13,
14,24,9,19,4};
//
//{0,16,7,23,14, 
//10,1,17,8,24,
//20,11,2,18,9,
//5,21,12,3,19,
//15,6,22,13,4};

always_comb
begin
	integer i,j;
	for(i = 0; i < `STATE_SIZE/`Z_WIDTH; i++) begin
		for(j = 0; j<`Z_WIDTH; j++) begin
			out_reg[new_position_array[i]*`Z_WIDTH+j] = IN[i*`Z_WIDTH+j];
		end
	end
end

assign OUT = out_reg;

endmodule