`define STATE_SIZE 1600
`define CD_SIZE 320
`define Z_WIDTH 64

module IOTA (
	input logic [0:`STATE_SIZE-1] IN,
	output logic [0:`STATE_SIZE-1] OUT,
	input logic [0:`Z_WIDTH-1] RC_CONSTANT
	);
	
logic [0:`STATE_SIZE-1]	out_reg;

always_comb
begin
	integer i;
	for(i = 0; i < `Z_WIDTH; i++) begin
		out_reg[i] = IN[i] ^ RC_CONSTANT[`Z_WIDTH - 1 - i];
	end
	out_reg[`Z_WIDTH:`STATE_SIZE-1] = IN[`Z_WIDTH:`STATE_SIZE-1];
end

assign OUT = out_reg;
endmodule