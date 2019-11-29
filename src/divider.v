module divider(
clk,
clear_b,
N,
D,

Q
);

//----------------Input Port-----------------//
input 	wire		clk;		
input	wire		clear_b;	//active low clear
input	wire	[31:0]	N;		//32-bit floating point Numerator
input	wire	[31:0]	D;		//32-bit floating point Denominator

//----------------Output Port----------------//
output	reg	[31:0]	Q;		//32-bit Quotient


//---------------Internal Variables------------//
reg		new_input_flag;		// indicate a new pair of N and D is being processed by the divider		
reg	[4:0]	state_cnt;		//keep track of which stage the data is in the pipeline within one iteration
reg	[23:0]	F_I;
reg	[23:0] 	N_I;		
reg	[23:0]	D_I;		

reg		sign_q;			// the sign bit of the quotient latched at the end of 0th stage
reg	[ 7:0]	exponent_q;		// the exponent of the quotient latched at the end of 0th stage
wire		sign_passed;
wire	[ 7:0]	exponent_passed;
reg	[23:0]	a_in;			// array multiplier input "a"
reg	[23:0]	b_in;			// array multiplier input "b"
wire	[47:0]	product;		// the product coming out of the array multiplier
wire	[47:0]	product_nlz;		// product produced by array multiplier normalized
//----------------Code Starts Here--------------//

always@(posedge clk) 
begin: UPDATE_STATE_CNT
	if (clear_b) begin
		if (state_cnt < 20)
			state_cnt <= state_cnt + 1;
		else if (state_cnt == 20)
			state_cnt <= 0;
	end
			
	else if (~clear_b)
		state_cnt <= 20;
end

always@(posedge clk)
begin: INDICATE_NEW_INPUT_ENTERING_PIPELINE
	if (clear_b) begin
		if (state_cnt == 20)
			new_input_flag <= 1;
		else
			new_input_flag <= 0;
	end
	else if (~clear_b)
		new_input_flag <= 0;
end

/* cross of the MSB and paste an LSB in the end as normalization on the
 * product */
assign product_nlz = {product[46:0],product[0]};

/**************0th Stage*********************************************/
// Produce F(i+1) = 2 - D(i)
// Get difference of exponents
// Resolve the sign bit of the product
// and latch N(i) and D(i)
// initially i= -1 
/*****************************************************************/
/* Produce F(i+1) and latched it*/ 
always @(clear_b or state_cnt) 
begin: PRODUCE_CORRECTION_FACTORS
	if (clear_b) begin
		if (state_cnt == 0) 
			F_I = -{1'b1, D[22:0]};
		else begin
			if (state_cnt % 4 == 0)
				F_I = -{product_nlz[47:24]};
		end
	end
	else if (~clear_b)
		F_I = 24'bz;
end

/* Resolve the sign bit and calculate the exponent of the quotient */
always @(posedge clk)
begin: GET_SIGN_AND_EXPONENT
	if (clear_b) begin
		if (state_cnt == 20) begin
			sign_q <= N[31] ^ D[31];
			exponent_q <= N[30:23] - D[30:23] + 127;	
		end
	end
	else if (~clear_b) begin
		sign_q <= 1'bz;
		exponent_q <= 8'bz;
	end

end


/* Latch N(i) and D(i) */
always @(clear_b or state_cnt) 
begin: LATCH_N_I
	if (clear_b) begin
		if (state_cnt == 1) 
			N_I = {1'b1, N[22:0]};
		else begin
			if (state_cnt % 4 == 1)
				N_I = product_nlz[47:24];
		end
	end
	else if (~clear_b)
		N_I = 24'bz;
end


always @(clear_b or state_cnt) 
begin: LATCH_D_I
	if (clear_b) begin
		if (state_cnt == 0) 
			D_I = {1'b1, D[22:0]};
		else begin
			if (state_cnt % 4 == 0)
				D_I = product_nlz[47:24];
		end
	end
	else if (~clear_b)
		D_I = 24'bz;
end
/*****************************************************************/



/******************Iterations***********************************/
// write D & F0 to FIFO 	cycle 1		(for the 1st iteration) 
// calculate D0 = D * F0	cycle 2 to 3
// write N & F0 to FIFO		cycle 2
// calculate N0 = N * F0	cycle 3 to 4 			
/***************************************************************/
always @(D_I or N_I or state_cnt)
begin: PREPARE_INPUT_A_TO_ARRAY_MULTIPLIER
	if (clear_b) begin
 		case (state_cnt % 4)
			0:	begin 
					a_in = D_I;
					b_in = F_I;
				end
			1: 	begin	
					a_in = N_I;
					b_in = F_I;
				end
			default:begin
					a_in = 24'bz;
					b_in = 24'bz;
				end
		endcase
	end
	else if (~clear_b) begin
		a_in = 24'bz;
		b_in = 24'bz;
	end
end
am_FIFO am_FIFO 
(
	.clk		(clk),	
	.clear_b	(clear_b),
	.a_in		(a_in),
	.b_in		(b_in),
	.sign_q		(sign_q),
	.exponent_q	(exponent_q),
	.state_cnt	(state_cnt),
	.sign_passed	(sign_passed),
	.exponent_passed(exponent_passed),
	.product	(product)

);
/***************************************************************/



/**********Finally Assemble the Quotient***********************/
always @(posedge clk) 
begin:LATCH_QUOTIENT
	if (clear_b) begin
		if (state_cnt == 0) begin
			Q <= {sign_passed,exponent_passed,product_nlz[46:24]};
		end
	end
	else if (~clear_b)
		Q <= 32'bz;
end



/***************************************************************/


endmodule
