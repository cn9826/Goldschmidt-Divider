module mul_input_FIFO_tester();

reg			clk;
reg			clear_b;
reg		[23:0]	a_in;
reg		[23:0]	b_in;
reg			sign_q;
reg		[ 7:0]	exponent_q;
reg		[ 4:0]	state_cnt;

wire			sign_passed;
wire		[ 7:0]	exponent_passed;
wire		[47:0]	product;

always @(posedge clk)
begin
	if (clear_b) begin
		state_cnt <= state_cnt + 1;
	end
	else if (~clear_b) 
		state_cnt <= 5'b11111;	
end

initial begin
	clk = 1'b0;
	clear_b = 1'b0;
	@(posedge clk);
	#10;
	clear_b = 1'b1;
	
	#5
	a_in = 24'hABCCD1;
	b_in = 24'h2314A5;
	sign_q = 1;
	exponent_q = 8'd130;
	
	#10
//	rd_en = 1'b1;//&& ~I
	a_in = 24'h111111;
	b_in = 24'h000001;
	sign_q = 0;
	exponent_q = 8'd129;
	
	#10
	a_in = 24'h111111;
	b_in = 24'h000011;
	sign_q = 1;
	exponent_q = 8'd128;

	#10
	a_in = 24'h111111;
	b_in = 24'h000111;
	sign_q = 0;
	exponent_q = 8'd127;
	
	#10
	a_in = 24'h111111;
	b_in = 24'h001111;
	sign_q = 1;
	exponent_q = 8'd126;
	
	#10
	a_in = 24'h456789;
	b_in = 24'h123456;
	sign_q = 0;
	exponent_q = 8'd125;

end

am_FIFO I0 (
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


always
#5 clk = ~clk;

initial #200 $finish;

endmodule
