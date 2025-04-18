`define STATE_SIZE 1600
`define CD_SIZE 320
`define Z_WIDTH 64

module RND (
	input logic [0:`STATE_SIZE-1] IN,
	output logic[0:`STATE_SIZE-1] OUT,
	input logic [0:`Z_WIDTH-1] RND_CONST
	);

logic [0:`STATE_SIZE-1] theta_to_rho, rho_to_pi, pi_to_chi, chi_to_iota, iota_out;	
logic [0:`STATE_SIZE-1] in_reg, out_reg;	


assign OUT = out_reg;

THETA T(
	.IN(IN),
	.OUT(theta_to_rho)
);

RHO R(
	.IN(theta_to_rho),
	.OUT(rho_to_pi)
);

PI P (
	.IN(rho_to_pi),
	.OUT(pi_to_chi)
);


CHI C(
	.IN(pi_to_chi),
	.OUT(chi_to_iota)
);

IOTA I(
	.IN(chi_to_iota),
	.OUT(out_reg),
	.RC_CONSTANT(RND_CONST)
);


endmodule
	