/*
module Cell(output Cnext, Sthis, input xn, am, Slast, Cthis);

  wire t;
  and (t, xn, am);

  xor (Sthis, t, Slast, Cthis);
  xor (t1, Slast, Cthis);
  and (t2, t, t1);
  and (t3, Cthis, Slast);
  or (Cnext, t2, t3);
  
endmodule

module FACell(output Cnext, Sthis, input xn, am, Cthis);
  
  wire t1, t2, t3;
  xor (t1, am, xn);
  and (t2, t1, Cthis);
  and (t3, am, xn);
  or (Cnext, t2, t3);
  xor (Sthis, t1, Cthis);

endmodule
*/


module ArrayMultiplier(clk, product_reg, a, x);
  
  parameter m = 24;
  parameter n = 24;
  output reg [m+n-1:0] product_reg;
  wire [m+n-1:0] product;
  input [m-1:0] a;
  input [n-1:0] x;
  input clk;
  
  wire [m*n:0] c_partial ;
  wire [m*n:0] s_partial ;

  // first line of the multiplier
  genvar i;
  generate
    for(i=0; i<m; i=i+1)
    begin
      Cell c_first(.Cnext(c_partial[i]), .Sthis(s_partial[i]),
                   .xn(x[0]), .am(a[i]), .Slast(1'b0), .Cthis(1'b0));
    end
  endgenerate
  
  
  // middle lines of the multiplier - except last column
  genvar j, k;
  generate
    for(k=0; k<n-1; k=k+1)
    begin
      for(j=0; j<m-1; j=j+1)
      begin
        Cell c_middle(c_partial[m*(k+1)+j], s_partial[m*(k+1)+j],
                      x[k+1], a[j], s_partial[m*(k+1)+j-m+1], c_partial[m*(k+1)+j-m]);
      end
    end
  endgenerate
  
  // middle lines of the multiplier - only last column
  genvar z;
  generate
    for(z=0; z<n-1; z=z+1)
    begin
      Cell c_middle_last_col(c_partial[m*(z+1)+(m-1)], s_partial[m*(z+1)+(m-1)],
                             x[z+1], a[+(m-1)], 1'b0, c_partial[m*(z+1)+(m-1)-m]);
    end
  endgenerate

  reg [m*n:0] c_partial_reg ;
  reg [m*n:0] s_partial_reg ;
  always @ (posedge clk)
  begin
  c_partial_reg[m*n : 0] = c_partial[m*n : 0];
  s_partial_reg[m*n : 0] = s_partial[m*n : 0];
  end

  // last line of the multiplier
  wire c_last_partial[m-1:0] ;
  wire s_last_partial[m-2:0] ;
  buf (c_last_partial[0], 0);
  
  genvar l1;
  generate
    for(l1=0; l1<(m-1); l1=l1+1)
    begin
      FACell c_last(c_last_partial[l1+1], s_last_partial[l1],
                    c_partial_reg[(n-1)*m+l1], s_partial_reg[(n-1)*m+l1+1], c_last_partial[l1]);
    end
  endgenerate

  genvar l2;
  generate
    for(l2=(m+1)/2; l2<m-1; l2=l2+1)
    begin
      FACell c_last(c_last_partial[l2+1], s_last_partial[l2],
                    c_partial_reg[(n-1)*m+l2], s_partial_reg[(n-1)*m+l2+1], c_last_partial[l2]);
    end
  endgenerate

  
  // product bits from first and middle cells
  generate
    for(i=0; i<n; i=i+1)
    begin
      buf (product[i], s_partial_reg[m*i]);
    end
  endgenerate
  
  // product bits from the last line of cells
  generate
    for(i=n; i<n+m-1; i=i+1)
    begin
      buf (product[i], s_last_partial[i-n]);
    end
  endgenerate
    
  // msb of product
  buf (product[m+n-1], c_last_partial[m-2]);

  always @ (posedge clk)
  begin
  product_reg[m+n-1 : 0] = product[m+n-1 : 0];
  end

endmodule
