
`define STATE_SIZE 1600
`define CD_SIZE 320
`define Z_WIDTH 64

module RHO (
	input logic [0:`STATE_SIZE-1] IN,
	output logic [0:`STATE_SIZE-1] OUT);
	
logic [0:`STATE_SIZE-1] out_reg;

localparam integer offset_array [0:`STATE_SIZE/`Z_WIDTH-1] = 
'{0,1,190,28,91,
36,300,6,55,276,
3,10,171,153,231,
105,45,15,21,136,
210,66,253,120,78};

//{0,36,3,105,210,
//1,300,10,45,66,
//190,6,171,15,253,
//28,55,153,21,120,
//91,276,231,136,78};

always_comb
begin
	integer i,j;
	for(i = 0; i < `STATE_SIZE/`Z_WIDTH; i++) begin
		for(j = 0; j<`Z_WIDTH; j++) begin
			out_reg[i*`Z_WIDTH + j] = IN[i*`Z_WIDTH + (j +`CD_SIZE - offset_array[i]) % `Z_WIDTH];
		end
	end
end

assign OUT = out_reg;
endmodule