module mul_input_FIFO_tester();

reg			clk;
reg			clear_b;
reg		[31:0]	a_in;
reg		[31:0]	b_in;
reg			rd_en;

wire		[31:0]	stage0_a;
wire		[31:0]	stage1_a;
wire		[31:0]	stage2_a;
wire		[31:0]	stage0_b;
wire		[31:0]	stage1_b;
wire		[31:0]	stage2_b;

initial begin
	clk = 1'b0;
	clear_b = 1'b0;
	rd_en = 1'b0;
	@(posedge clk);
	#1;
	clear_b = 1'b1;	
	a_in = 32'h00000000;
	b_in = 32'h00000000;
	
	#2
	rd_en = 1'b1;
	a_in = 32'h00000001;
	b_in = 32'h00000001;
	
	#2
	a_in = 32'h00000002;
	b_in = 32'h00000002;
	
	#2
	a_in = 32'h00000003;
	b_in = 32'h00000003;
	
	#2
	a_in = 32'h00000004;
	b_in = 32'h00000004;
	
	#2
	a_in = 32'h00000005;
	b_in = 32'h00000005;
end

always
#1 clk = ~clk;

initial #12 $finish;

mul_input_FIFO I0 (
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

endmodule
