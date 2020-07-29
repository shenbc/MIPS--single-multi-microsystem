module alu (a,b,alu_ctr,alu_out,zero,upover);
    input  [31:0] a,b     ;   // input data
    input  [1:0]  alu_ctr ;   // control
    output [31:0] alu_out ;   // output data
    output        zero    ;   // zero sign
    output        upover  ;   // upwards overflow
    
    wire   [31:0] alu_out;
    wire   [31:0] sub,ori,slt;
    wire   [32:0] add;
    
    assign add={a[31],a}+{b[31],b};
    assign sub=a-b;
    assign ori=a|b;
    assign slt={31'b0,sub[31]};// a>b:0;a<b:1         
              
    assign zero=!(|sub);
    assign upover=(alu_ctr==2'b00)&&((add[32:31]==2'b01)||(add[32:31]==2'b10)) ? 1 : 0;
    
    assign alu_out=(alu_ctr==2'b00)?add[31:0]:
                   (alu_ctr==2'b01)?sub:
                   (alu_ctr==2'b10)?ori:
                   (alu_ctr==2'b11)?slt:
                                  32'b0;
    
endmodule
