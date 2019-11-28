module mul_input_FIFO_tester();

reg			clk;
reg			clear_b;
reg		[31:0]	a_in;
reg		[31:0]	b_in;
reg			rd_en;


wire		[47:0]	product;

initial begin
	clk = 1'b0;
	clear_b = 1'b0;
	rd_en = 1'b0;
	@(posedge clk);
	#20;
	clear_b = 1'b1;	
	a_in = 32'h00ABCCD1;
	b_in = 32'h002314A5;
	
	#40
	rd_en = 1'b1;
	a_in = 32'h00111111;
	b_in = 32'h00000001;
	
	#40
	a_in = 32'h00111111;
	b_in = 32'h00000011;
	
	#40
	a_in = 32'h00111111;
	b_in = 32'h00000111;
	
	#40
	a_in = 32'h00111111;
	b_in = 32'h00001111;
	
	#40
	a_in = 32'h00456789;
	b_in = 32'h00123456;
end

am_FIFO I0 (
	.clk		(clk),
	.clear_b	(clear_b),
	.a_in		(a_in),
	.b_in		(b_in),
	.rd_en		(rd_en),
	.product	(product)
);


always
#20 clk = ~clk;

initial #600 $finish;

endmodule
