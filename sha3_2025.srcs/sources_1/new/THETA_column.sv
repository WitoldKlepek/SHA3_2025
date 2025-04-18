`define COLUMN_SIZE 5

module THETA_column (
	input logic [`COLUMN_SIZE-1:0] IN,
	output logic [`COLUMN_SIZE-1:0] OUT,
	input logic C1_IN, C2_IN,
	output logic C_OUT
	);

logic [`COLUMN_SIZE-1:0] out_reg;
logic c_reg, d_reg;

always_comb
begin
	c_reg		= ^(IN);
	out_reg[0]	= IN[0] ^ C1_IN ^ C2_IN;
	out_reg[1]	= IN[1] ^ C1_IN ^ C2_IN;
	out_reg[2]	= IN[2] ^ C1_IN ^ C2_IN;
	out_reg[3]	= IN[3] ^ C1_IN ^ C2_IN;
	out_reg[4]	= IN[4] ^ C1_IN ^ C2_IN;
end	 

assign OUT = out_reg;
assign C_OUT = c_reg;


endmodule
