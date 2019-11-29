module am_FIFO (
clk,
clear_b,
a_in,
b_in,
sign_q,
exponent_q,
state_cnt,

sign_passed,
exponent_passed,
product
);

//-----------------------Input Ports-----------------------//
input	wire			clk;
input	wire			clear_b;
input	wire	[23:0]		a_in;		//24-bit extended mantissa of either D or N
input	wire	[23:0]		b_in;		//24-bit correction factor F
input	wire			sign_q;		//the sign bit needs to be passed down along the pipeline
input	wire	[ 7:0]		exponent_q;	//the difference in exponents needs to be passed down along the pipeline
input	wire	[ 4:0]		state_cnt;	//keeps track of which cycle it currently is within one division
						//provided by higher-heirarchy module
//-----------------------Input Ports-----------------------//
output	wire	[47:0]		product;
output	reg			sign_passed;
output	reg	[ 7:0]		exponent_passed;

//------------------Internal Variables--------------------//
reg			wr_en;
reg			rd_en;
wire			stage0_sign;
wire			stage1_sign;
wire	[ 7:0]		stage0_exponent;
wire	[ 7:0]		stage1_exponent;
wire	[23:0]		stage0_a;
wire	[23:0]		stage1_a;
wire	[23:0]		stage0_b;
wire	[23:0]		stage1_b;

//-----------------Code Starts Here--------------------//
always @(negedge clk)
begin: SET_WR_EN
	if (clear_b) begin
		if ((state_cnt % 4) == 0 && state_cnt != 20)
			wr_en <= 1;
		else if ((state_cnt % 4) == 2)
			wr_en <= 0;
	end
	else if (~clear_b)
		wr_en <= 0;
		
end

always @(negedge clk)
begin: SET_RD_EN
	if (clear_b) begin
		if ((state_cnt % 4) == 1)
			rd_en <= 1;
		else if ((state_cnt % 4) == 0)
			rd_en <= 0;
	end
	else if (~clear_b)
		rd_en <= 0;
		
end

always @(posedge clk)
begin: LATCH_SIGN_AND_EXPONENT
	if (clear_b) begin
		sign_passed <= stage1_sign;
		exponent_passed <= stage1_exponent;
	end
	else if (~clear_b) begin
		sign_passed <= 1'bz;
		exponent_passed <= 8'bz;
	end
end

mul_input_FIFO fifo     
(
	.clk		(clk),
	.clear_b	(clear_b),
	.a_in		(a_in),
	.b_in		(b_in),	
	.sign_q		(sign_q),
	.exponent_q	(exponent_q),
	.wr_en		(wr_en),
	.rd_en		(rd_en),
	
	.stage0_a	(stage0_a),
	.stage1_a	(stage1_a),
	.stage0_b	(stage0_b),
	.stage1_b	(stage1_b),
	.stage0_sign	(stage0_sign),
	.stage1_sign	(stage1_sign),
	.stage0_exponent(stage0_exponent),
	.stage1_exponent(stage1_exponent)

);

ArrayMultiplier am_2stage
(
	.clk		(clk),
	.a		(stage0_a),
	.x		(stage0_b),
	.product_reg	(product)
);


endmodule
