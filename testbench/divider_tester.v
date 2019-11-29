module divider_tester();

reg			clk;
reg			clear_b;
reg		[31:0]	N;
reg		[31:0]	D;
wire		[31:0]	Q;


initial begin
	clk = 1'b0;
	clear_b = 1'b0;
	@(posedge clk);
	#5;	
	clear_b = 1'b1;	
	

	N = 32'h41280000;	//10.25
	D = 32'h40100000;	//2.25
				//	4.66666666666667
				//vs	4.6666667	

	#200
	N = 32'h453B8000;	//3000
	D = 32'h41A40000;	//20.5
				//	146.34146341463 
			       	//vs    146.34148

	#200
	N = 32'h3e712ec7;	// 0.23553
	D = 32'hbec4fb55;	//-0.38473
				//	-0.6121955657  
				//vs 	-0.6121955
end

divider I0 (
	.clk		(clk),
	.clear_b	(clear_b),
	.N		(N),
	.D		(D),
	.Q	 	(Q)
);


always
#5 clk = ~clk;

initial #800 $finish;

endmodule
