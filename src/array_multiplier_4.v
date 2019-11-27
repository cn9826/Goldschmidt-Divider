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
  
  wire [m*n:0] c_partial_1 ;
  wire [m*n:0] s_partial_1 ;

  // first line of the multiplier
  genvar i;
  generate
    for(i=0; i<m; i=i+1)
    begin
      Cell c_first(.Cnext(c_partial_1[i]), .Sthis(s_partial_1[i]),
                   .xn(x[0]), .am(a[i]), .Slast(1'b0), .Cthis(1'b0));
    end
  endgenerate
  
  
  // middle lines of the multiplier - except last column_1
  genvar j1, k1;
  generate
    for(k1=0; k1<(n-1)/2; k1=k1+1)
    begin
      for(j1=0; j1<m-1; j1=j1+1)
      begin
        Cell c_middle(c_partial_1[m*(k1+1)+j1], s_partial_1[m*(k1+1)+j1],
                      x[k1+1], a[j1], s_partial_1[m*(k1+1)+j1-m+1], c_partial_1[m*(k1+1)+j1-m]);
      end
    end
  endgenerate
  
  // middle lines of the multiplier - only last column_1
  genvar z1;
  generate
    for(z1=0; z1<(n-1)/2; z1=z1+1)
    begin
      Cell c_middle_last_col(c_partial_1[m*(z1+1)+(m-1)], s_partial_1[m*(z1+1)+(m-1)],
                             x[z1+1], a[+(m-1)], 1'b0, c_partial_1[m*(z1+1)+(m-1)-m]);
    end
  endgenerate

  reg [m*n:0] c_partial_reg_1 ;
  reg [m*n:0] s_partial_reg_1 ;
  reg [m-1:0] a_reg;
  reg [n-1:0] x_reg; 

  always @ (posedge clk)
  begin
  c_partial_reg_1[m*n : 0] = c_partial_1[m*n : 0];
  s_partial_reg_1[m*n : 0] = s_partial_1[m*n : 0];
  a_reg[m-1:0] = a[m-1:0];
  x_reg[n-1:0] = x[n-1:0];
  end

  wire [m*n:0] c_partial_2 ;
  wire [m*n:0] s_partial_2 ;


  genvar i0;
  generate
    for(i0=0; i0<m; i0=i0+1)
    begin
      buf (c_partial_2[i0], c_partial_reg_1[i0]);
      buf (s_partial_2[i0], s_partial_reg_1[i0]);
    end
  endgenerate
  
 
  genvar j10, k10;
  generate
    for(k10=0; k10<(n-1)/2; k10=k10+1)
    begin
      for(j10=0; j10<m-1; j10=j10+1)
      begin
        buf (c_partial_2[m*(k10+1)+j10], c_partial_reg_1[m*(k10+1)+j10]);
        buf (s_partial_2[m*(k10+1)+j10], s_partial_reg_1[m*(k10+1)+j10]);
      end
    end
  endgenerate
  
  genvar z10;
  generate
    for(z10=0; z10<(n-1)/2; z10=z10+1)
    begin
      buf (c_partial_2[m*(z10+1)+(m-1)], c_partial_reg_1[m*(z10+1)+(m-1)]);
      buf (s_partial_2[m*(z10+1)+(m-1)], s_partial_reg_1[m*(z10+1)+(m-1)]);
    end
  endgenerate

  // middle lines of the multiplier - except last column_2
  genvar j2, k2;
  generate
    for(k2=(n-1)/2; k2<(n-1); k2=k2+1)
    begin
      for(j2=0; j2<(m-1); j2=j2+1)
      begin
        Cell c_middle(c_partial_2[m*(k2+1)+j2], s_partial_2[m*(k2+1)+j2],
                      x_reg[k2+1], a_reg[j2], s_partial_2[m*(k2+1)+j2-m+1], c_partial_2[m*(k2+1)+j2-m]);
      end
    end
  endgenerate
  
  // middle lines of the multiplier - only last column_2
  genvar z2;
  generate
    for(z2=(n-1)/2; z2<(n-1); z2=z2+1)
    begin
      Cell c_middle_last_col(c_partial_2[m*(z2+1)+(m-1)], s_partial_2[m*(z2+1)+(m-1)],
                             x_reg[z2+1], a_reg[+(m-1)], 1'b0, c_partial_2[m*(z2+1)+(m-1)-m]);
    end
  endgenerate

  reg [m*n:0] c_partial_reg_2 ;
  reg [m*n:0] s_partial_reg_2 ;
  always @ (posedge clk)
  #1
  begin
  c_partial_reg_2[m*n : 0] = c_partial_2[m*n : 0];
  s_partial_reg_2[m*n : 0] = s_partial_2[m*n : 0];
  end

  // last line of the multiplier_1
  wire [m-1:0] c_last_partial_1 ;
  wire [m-2:0] s_last_partial_1 ;
  buf (c_last_partial_1[0], 0);
  
  genvar l1;
  generate
    for(l1=0; l1<(m-1); l1=l1+1)
    begin
      FACell c_last(c_last_partial_1[l1+1], s_last_partial_1[l1],
                    c_partial_reg_2[(n-1)*m+l1], s_partial_reg_2[(n-1)*m+l1+1], c_last_partial_1[l1]);
    end
  endgenerate

  // last line of the multiplier_2
  reg [m-1:0] c_last_partial_1_reg ;
  reg [m-2:0] s_last_partial_1_reg ;
  reg [m*n:0] c_partial_reg_3 ;
  reg [m*n:0] s_partial_reg_3 ;

  always @ (posedge clk)
  // #2
  begin
  c_last_partial_1_reg[m-1 : 0] = c_last_partial_1[m-1 : 0];
  s_last_partial_1_reg[m-2 : 0] = s_last_partial_1[m-2 : 0];
  c_partial_reg_3[m*n : 0] = c_partial_reg_2[m*n : 0];
  s_partial_reg_3[m*n : 0] = s_partial_reg_2[m*n : 0];
  end


  wire [m-1:0] c_last_partial_2 ;
  wire [m-2:0] s_last_partial_2 ;
 
  genvar l20;
  generate
    for(l20=0; l20<(m-1)/2; l20=l20+1)
    begin
      buf (c_last_partial_2[l20], c_last_partial_1_reg[l20]);
      buf (s_last_partial_2[l20], s_last_partial_1_reg[l20]);
    end
  endgenerate

  buf (c_last_partial_2[(m-1)/2], c_last_partial_1_reg[(m-1)/2]);
 
  genvar l2;
  generate
    for(l2=(m-1)/2; l2<(m-1); l2=l2+1)
    begin
      FACell c_last(c_last_partial_2[l2+1], s_last_partial_2[l2],
                    c_partial_reg_3[(n-1)*m+l2], s_partial_reg_3[(n-1)*m+l2+1], c_last_partial_2[l2]);
    end
  endgenerate


  // product bits from first and middle cells
  generate
    for(i=0; i<n; i=i+1)
    begin
      // buf (product[i], s_partial_reg_3[m*i]);
      buf (product[i], s_partial_reg_3[m*i]);
    end
  endgenerate
  
  // product bits from the last line of cells
  generate
    for(i=n; i<n+m-1; i=i+1)
    begin
      // buf (product[i], s_last_partial_2_reg[i-n]);
      buf (product[i], s_last_partial_2[i-n]);
    end
  endgenerate
    
  // msb of product
  // buf (product[m+n-1], c_last_partial_2_reg[m-2]);
  buf (product[m+n-1], c_last_partial_2[m-2]);

always @ (posedge clk)
begin
product_reg[m+n-1 : 0] = product[m+n-1 : 0];
end

endmodule
