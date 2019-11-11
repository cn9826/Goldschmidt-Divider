module normalize_ff(
clk,
clr_b,
S_in,
E_in,
P_in,
P_normalized,
);

// P is the IEEE 754 single precision floating point product
// The Exponent of P is expected to be -127 adjusted 
// The Mantissa is not expected to be shifted yet

//------------------------Input Port-----------------------------//
input	wire		clk;
input	wire		clr_b; // low_active clear
input 	wire		S_in; // input sign bit
input	wire	[ 7:0]	E_in; // input exponent
input	wire	[47:0]	P_in; // input 48-bit product from array multiplier
//------------------------Output Port-----------------------------//
output	reg	[31:0] 	P_normalized;

//------------------------Internal Variables-----------------------//
reg			S_out; //Sign bit
reg		[ 7:0]	E_out; //Exponent
reg		[22:0]  M_out; //Mantissa

//------------------------Code Starts Here-------------------------//
always @(S_in or E_in or P_in)
begin
	S_out = S_in;
	M_out =P_in[46:24];
	if (P_in[47]) 
		E_out = E_in + 1;
	else if (~P_in[47]) 
		E_out = E_in;
end

always @(posedge clk)
begin: PIPELINE_LATCH
	if (clr_b)
		P_normalized <= {S_out,E_out,M_out};
	else if (~clr_b)
		P_normalized <= 32'bz;
end

endmodule
