module mux_2_32(a0,a1,ch,out);
  input   [31:0]   a0,a1;
  input            ch   ;
  output  [31:0]   out  ;
  wire    [31:0]   out  ;
  
  assign  out=(ch==0) ? a0 :
                        a1 ;
endmodule 

module mux_3_32(a0,a1,a2,ch,out);
  input   [31:0]   a0,a1,a2;
  input   [1:0]    ch      ;
  output  [31:0]   out     ;
  wire    [31:0]   out     ;
  
  assign  out=(ch==2'b00) ? a0    :
              (ch==2'b01) ? a1    :
              (ch==2'b10) ? a2    :
                            32'b0 ;
endmodule 

module mux_3_5(a0,a1,a2,ch,out);
  input   [4:0]    a0,a1,a2;
  input   [1:0]    ch      ;
  output  [4:0]    out     ;
  wire    [4:0]    out     ;
  
  assign  out=(ch == 2'b00) ? a0  :
              (ch == 2'b01) ? a1  :
              (ch == 2'b10) ? a2  :
                              5'b0;
endmodule