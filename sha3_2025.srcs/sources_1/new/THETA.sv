
`define STATE_SIZE 1600
`define CD_SIZE 320
`define Z_WIDTH 64

module THETA (
	input logic [0:`STATE_SIZE-1] IN,
	output logic [0:`STATE_SIZE-1] OUT);
	

logic [0:`CD_SIZE-1] c , d;
logic [0:`STATE_SIZE-1] out_reg;

genvar i;

generate                                                                                       
	for(i = 0; i < `CD_SIZE; i++) begin
		if(i % `Z_WIDTH == 0)
		THETA_column t0 (   
			.IN({IN[i],IN[320 + i],IN[640 + i],IN[960+i],IN[1280+i]}),
			.OUT({out_reg[i],out_reg[320 + i],out_reg[640 + i],out_reg[960+i],out_reg[1280+i]}),
			.C1_IN(c[(i+127) % `CD_SIZE]), 
			.C2_IN(c[(i+256) % `CD_SIZE]),
			.C_OUT(c[i])	
		);
		else
		THETA_column t0 (   
			.IN({IN[i],IN[320 + i],IN[640 + i],IN[960+i],IN[1280+i]}),
			.OUT({out_reg[i],out_reg[320 + i],out_reg[640 + i],out_reg[960+i],out_reg[1280+i]}),
			.C1_IN(c[(i+63) % `CD_SIZE]), 
			.C2_IN(c[(i+256) % `CD_SIZE]),
			.C_OUT(c[i])	
		);
	end                                                                                        
endgenerate

assign OUT = out_reg;

endmodule