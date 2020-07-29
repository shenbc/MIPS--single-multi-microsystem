module ir(clk,irwr,din,dout);            // instruction memory
    input  [31:0]  din   ;               //  32-bit memory input
    input          clk   ;                // clock
    input          irwr  ;                // ctrl
    output [31:0]  dout  ;               // 32-bit memory output
    reg    [31:0]  dout  ;
    
    always @(posedge clk)
      if(irwr)
        dout <= din  ; // output data
endmodule
