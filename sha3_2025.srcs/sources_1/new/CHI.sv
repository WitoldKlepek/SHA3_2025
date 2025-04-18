`define STATE_SIZE 1600
`define Z_WIDTH 64
`define ROW_SIZE 5

module CHI (
	input logic [0:`STATE_SIZE-1] IN,
	output logic [0:`STATE_SIZE-1] OUT);
	
logic [0:`STATE_SIZE-1] out_reg;

genvar i,j;

generate                                                                                       
for(i = 0; i < `ROW_SIZE; i++) begin
	for(j = 0; j < `Z_WIDTH; j++) begin
		CHI_row c0 (
		.IN(		
		{IN[i*`Z_WIDTH*`ROW_SIZE + j],
		IN[i*`Z_WIDTH*`ROW_SIZE + j+ 64],
		IN[i*`Z_WIDTH*`ROW_SIZE + j + 128],
		IN[i*`Z_WIDTH*`ROW_SIZE + j + 192],
		IN[i*`Z_WIDTH*`ROW_SIZE + j + 256]}
		),
		.OUT(
		{out_reg[i*`Z_WIDTH*`ROW_SIZE + j],
		out_reg[i*`Z_WIDTH*`ROW_SIZE + j+ 64],
		out_reg[i*`Z_WIDTH*`ROW_SIZE + j + 128],
		out_reg[i*`Z_WIDTH*`ROW_SIZE + j + 192],
		out_reg[i*`Z_WIDTH*`ROW_SIZE + j + 256]}
		));
	end		
end                                                                                        
endgenerate

assign OUT = out_reg;
endmodule