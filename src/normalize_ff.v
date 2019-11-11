module normalize_ff(
P,
P_normalized
);


//------------------------Input Port-----------------------------//
input	wire	[31:0]	P;


//------------------------Output Port-----------------------------//
output	wire	[31:0] 	P_normalized;

//------------------------Internal Variables-----------------------//
reg			S; //Sign bit
reg		[ 7:0]	E; //Exponent
reg		[23:0]  M; //Mantissa

//------------------------Code Starts Here-------------------------//
 
endmodule
