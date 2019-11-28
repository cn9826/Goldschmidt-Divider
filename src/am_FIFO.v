module am_FIFO (
clk,
clear_b,
a_in,
b_in,
rd_en,

product
);

//-----------------------Input Ports-----------------------//
input	wire			clk;
input	wire			clear_b;
input	wire	[31:0]		a_in;
input	wire	[31:0]		b_in;
input	wire			rd_en;


//-----------------------Input Ports-----------------------//
output	wire	[47:0]		product;

//------------------Internal Variables--------------------//
wire	[31:0]	stage0_a;
wire	[31:0]	stage1_a;
wire	[31:0]	stage2_a;
wire	[31:0]	stage0_b;
wire	[31:0]	stage1_b;
wire	[31:0]	stage2_b;

mul_input_FIFO fifo     
(
	.clk		(clk),
	.clear_b	(clear_b),
	.a_in		(a_in),
	.b_in		(b_in),
	.rd_en		(rd_en),
	
	.stage0_a	(stage0_a),
	.stage1_a	(stage1_a),
	.stage2_a	(stage2_a),
	.stage0_b	(stage0_b),
	.stage1_b	(stage1_b),
	.stage2_b	(stage2_b)
);

ArrayMultiplier am_3stage
(
	.clk		(clk),
	.a0		(stage0_a[23:0]),
	.a1		(stage1_a[23:0]),
	.x0		(stage0_b[23:0]),
	.x1		(stage1_b[23:0]),
	.product_reg	(product)
);


endmodule
