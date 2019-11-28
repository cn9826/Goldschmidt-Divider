module FACell(output Cnext, Sthis, input xn, am, Cthis);
  
  wire t1, t2, t3;
  xor (t1, am, xn);
  and (t2, t1, Cthis);
  and (t3, am, xn);
  or (Cnext, t2, t3);
  xor (Sthis, t1, Cthis);

endmodule
