

module stimulus;

  wire [47:0] p;
  reg [23:0] a_in;
  reg [23:0] b_in;
  reg clock;

  initial clock = 1'b0;
  always  #20 clock = ~clock;

  ArrayMultiplier #(.m(24), .n(24)) am (clock, p, a_in, b_in);
  // initial $monitor("a=%b,x=%b,p=%b", a, x, p);

  // array4x4 am (clock, a_in, b_in, p);


  initial
  begin
        #21
        a_in = 24'hABCCD1;
        b_in = 24'h2314A5;

        #40
        a_in = 24'h111111;
        b_in = 24'h000001;

        #40
        a_in = 24'h111111;
        b_in = 24'h000011;

        #40
        a_in = 24'h111111;
        b_in = 24'h000111;

        #40
        a_in = 24'h111111;
        b_in = 24'h001111;

        #40
        a_in = 24'h111111;
        b_in = 24'h011111;

        #40
        a_in = 24'h111111;
        b_in = 24'h111111;

        #40
        a_in = 24'h456789;
        b_in = 24'h123456;

  end

  initial #600 $finish;

endmodule
