module normalize_ff_tester();

reg			clk;
reg			clr_b;
reg			S_in;
reg		[ 7:0]	E_in;
reg		[47:0]	P_in;

wire		[31:0]	P_normalized;


initial begin
	clk = 1'b0;
	clr_b = 1'b0;	
	@(posedge clk);
	#1;
	@(posedge clk);
	// 32'd1
	S_in = 1'b0;
	E_in = 8'd127;
	P_in = 48'h400000000000;
	#1
	clr_b = 1'b1;

	#2
	// 32'd3.515625
	S_in = 1'b0;
	E_in = 8'd127;
	P_in = 48'hE10000000000;
	
end

always
#1 clk = ~clk;

//initial #8 $finish;


normalize_ff I0 (
.clk		(clk),
.clr_b		(clr_b),
.S_in		(S_in),
.E_in		(E_in),
.P_in		(P_in),
.P_normalized	(P_normalized)
);


endmodule
