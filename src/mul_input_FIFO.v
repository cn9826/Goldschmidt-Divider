/* This module is used to read in single-precision multiplication inputs and 
 * arbitrate these pair of inputs to corresponding stages in the pipelined 
 * array multipleir.
 * Multiplications need to be done in Goldschmidt includes:
 * 	r3 = K3 * K2 * K1 * D = 1 - epsilon^4;
 *	q4 = K4 * K3 * K2 * K1 * N; 	where K4 = 1 + epsilon^4 = 2'sComp(r3)
 */
module mul_input_FIFO(
clk,
clear_b,
a_in,
b_in,
rd_en,

stage0_a,
stage1_a,
stage2_a,
stage0_b,
stage1_b,
stage2_b
);

//----------------Input Ports------------------------//
input	wire			clk;
input	wire			clear_b; //low-active clear signal
input	wire	[31:0]		a_in;
input	wire	[31:0]		b_in;
input	wire			rd_en;


//---------------Output Ports------------------------//
output	reg	[31:0]		stage0_a;
output	reg	[31:0]		stage1_a;
output	reg	[31:0]		stage2_a;
output	reg	[31:0]		stage0_b; 
output	reg	[31:0]		stage1_b; 
output	reg	[31:0]		stage2_b; 
//output	reg			INTR;     // Full Interrupt
//---------------Internal Variables------------------//
reg	[31:0]	a_buffer	[ 0:3]; //RAM Depth is 4, subject to change
reg	[31:0]	b_buffer	[ 0:3]; //RAM Depth is 4, subject to change
reg	[ 1:0]  stg_cnt 	[ 0:3]; //Stage number is 3, subject to change
reg	[ 1:0]	rd_ptr; //RAM Depth is 4, subject to change
reg	[ 1:0] 	wr_ptr;//RAM Depth is 4, subject to change


//---------------Code Starts Here--------------------//

always @(posedge clk)
begin: UPDATE_WR_PTR
	if (clear_b) //&& ~INTR)
		wr_ptr <= wr_ptr + 1;
	else if (~clear_b)
		wr_ptr <= 2'b0;
end

always @(posedge clk)
begin: UPDATE_RD_PTR
	if (clear_b && rd_en)
		rd_ptr <= rd_ptr + 1;
	else if (~clear_b)
		rd_ptr <= 2'b0;
end

//genvar i;
//generate
//for (i = 0; i < 3; i = i + 1) begin
//	always @(posedge clk)
//	begin: UPDATE_STG_CNT
//		stg_cnt[i] <= 0;
//	end
//end
//endgenerate

always @(posedge clk)
begin: WRITE_TO_RAM
	if (clear_b) begin //&& ~INTR) begin
		a_buffer[wr_ptr] <= a_in;
		b_buffer[wr_ptr] <= b_in;
	end
	else if (~clear_b) begin
		a_buffer[wr_ptr] <= 32'bz;
		b_buffer[wr_ptr] <= 32'bz;
	end
end

always @(posedge clk)
begin: SEND_INPUT_TO_STG0
	if (clear_b && rd_en) begin
		stage0_a <= a_buffer[rd_ptr];
		stage0_b <= b_buffer[rd_ptr];
	end
	else if (~clear_b) begin
		stage0_a <= 32'bz; 	
		stage0_b <= 32'bz;
	end
end
always @(posedge clk)
begin: SEND_INPUT_TO_STG1
	if (clear_b && rd_en) begin
		if (rd_ptr >= 1) begin		
			stage1_a <= a_buffer[rd_ptr-1];
			stage1_b <= b_buffer[rd_ptr-1];
		end
		else if (rd_ptr <1) begin
			stage1_a <= a_buffer[3];
			stage1_b <= b_buffer[3];
		end
	end
	else if (~clear_b) begin
		stage1_a <= 32'bz; 	
		stage1_b <= 32'bz;
	end
end
always @(posedge clk)
begin: SEND_INPUT_TO_STG2
	if (clear_b && rd_en) begin
		if (rd_ptr >= 2) begin
			stage2_a <= a_buffer[rd_ptr-2];
			stage2_b <= b_buffer[rd_ptr-2];
		end
		else begin
			case (rd_ptr)
				2'b1: 
				begin
					stage2_a <= a_buffer[3];
					stage2_b <= b_buffer[3];
				end	
				2'b0:
				begin 
					stage2_a <= a_buffer[2];
					stage2_b <= b_buffer[2];
				end
			endcase
		end
	end
	else if (~clear_b) begin
		stage2_a <= 32'bz; 	
		stage2_b <= 32'bz;
	end
end
endmodule



	
