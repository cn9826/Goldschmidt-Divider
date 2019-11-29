/* This module is used to read in single-precision multiplication inputs and 
 * arbitrate these pair of inputs to corresponding stages in the pipelined 
 * array multipleir.
 * Multiplications need to be done in Goldschmidt includes:
 * 	D4 = F4 * F3 * F2 * F1 * F0 * D = 1 - epsilon^4;
 *	N4 = F4 * F3 * F2 * F1 * F0 * N; 	where K4 = 1 + epsilon^4 = 2'sComp(D3)
 */
module mul_input_FIFO(
clk,
clear_b,
a_in,
b_in,
sign_q,
exponent_q,
wr_en,
rd_en,

stage0_a,
stage1_a,
stage0_b,
stage1_b,
stage0_sign,
stage1_sign,
stage0_exponent,
stage1_exponent
);

//----------------Input Ports------------------------//
input	wire			clk;
input	wire			clear_b; 	// low-active clear signal
input	wire	[23:0]		a_in; 		// extended mantissa of either D or N 
input	wire	[23:0]		b_in; 		// 24-bit correction factor F
input	wire			sign_q; 	// the sign bit that needs to be passed down the pipeline
input	wire	[ 7:0]		exponent_q; 	// the difference in exponents that needs to be passed down the pipeline
input	wire			wr_en;
input	wire			rd_en;


//---------------Output Ports------------------------//
output	reg	[23:0]		stage0_a;
output	reg	[23:0]		stage1_a;
output	reg			stage0_sign;
output	reg	[ 7:0]		stage0_exponent;

output	reg	[23:0]		stage0_b; 
output	reg	[23:0]		stage1_b; 
output	reg			stage1_sign;
output	reg	[ 7:0]		stage1_exponent;
//---------------Internal Variables------------------//
reg	[23:0]	a_buffer	[ 0:1]; //RAM Depth is 2
reg	[23:0]	b_buffer	[ 0:1]; //RAM Depth is 2
reg		sign_buffer	[ 0:1];
reg	[ 7:0]	exponent_buffer	[ 0:1];
reg	[ 1:0]	rd_ptr; //RAM Depth is 2
reg	 	wr_ptr; //RAM Depth is 2


//---------------Code Starts Here--------------------//

always @(posedge clk)
begin: UPDATE_WR_PTR
	if (clear_b)
		if (wr_en)
			wr_ptr <= wr_ptr + 1;
		else
			wr_ptr <= 1'b0;
	else if (~clear_b)
		wr_ptr <= 1'b0;
end

always @(posedge clk)
begin: UPDATE_RD_PTR
	if (clear_b)
		if (rd_en && rd_ptr < 2)
			rd_ptr <= rd_ptr + 1;
		else
			rd_ptr <= 2'b0;
	else if (~clear_b)
		rd_ptr <= 2'b0;
end

always @(posedge clk)
begin: WRITE_TO_RAM
	if (clear_b && wr_en) begin 
		a_buffer[wr_ptr] <= a_in;
		b_buffer[wr_ptr] <= b_in;
		sign_buffer[wr_ptr] <= sign_q;
		exponent_buffer[wr_ptr] <= exponent_q;
	end
	else if (~clear_b) begin
		a_buffer[wr_ptr] <= 24'bz;
		b_buffer[wr_ptr] <= 24'bz;
		sign_buffer[wr_ptr] <= 1'bz;
		exponent_buffer[wr_ptr] <= 8'bz;
	end
end

always @(posedge clk)
begin: SEND_INPUT_TO_STG0
	if (clear_b && rd_en) begin
		if (rd_ptr < 2) begin	
			stage0_a <= a_buffer[rd_ptr];
			stage0_b <= b_buffer[rd_ptr];
			stage0_sign <= sign_buffer[rd_ptr];
			stage0_exponent <= exponent_buffer[rd_ptr];
		end
		else begin
			stage0_a <= 24'bz;
			stage0_b <= 24'bz;
			stage0_sign <= 1'bz;
			stage0_exponent <= 8'bz;
		end
	end
	else if (~clear_b) begin
		stage0_a <= 24'bz; 	
		stage0_b <= 24'bz;
		stage0_sign <= 1'bz;
		stage0_exponent <= 8'bz;
	end
end

always @(posedge clk)
begin: SEND_INPUT_TO_STG1
	if (clear_b && rd_en) begin
		if (rd_ptr >= 1) begin
			stage1_a <= a_buffer[rd_ptr-1];
			stage1_b <= b_buffer[rd_ptr-1];	
			stage1_sign <= sign_buffer[rd_ptr-1];
			stage1_exponent <= exponent_buffer[rd_ptr-1];
		end
		else begin 
			stage1_a <= 24'bz;
			stage1_b <= 24'bz;
			stage1_sign <= 1'bz;
			stage1_exponent <= 8'bz;
		end
	end
	else if (~clear_b) begin
		stage1_a <= 24'bz; 	
		stage1_b <= 24'bz;
		stage1_sign <= 1'bz;
		stage1_exponent <= 8'bz;
	end
end
endmodule



	
