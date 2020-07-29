module ext (din,ext_op,dout);       //extender,00->zero ext,01->sign ext,10->low_zero ext
    input  [15:0] din     ;         // input data 
    input  [1:0]  ext_op  ;         // ext_op to control the extension  
    output [31:0] dout    ;         // result data output
    wire   [31:0] dout    ;
                                                   
    wire   [31:0] z_ext,s_ext,shift;
    
    assign z_ext={16'b0,din};         //zero extender
    assign s_ext={{16{din[15]}}, din};//sign extender
    assign shift={din,16'b0};         //low_zero extender
    
    assign dout=(ext_op==2'b00)?z_ext:
                (ext_op==2'b01)?s_ext:
                (ext_op==2'b10)?shift:
                                32'b0;
    
endmodule
