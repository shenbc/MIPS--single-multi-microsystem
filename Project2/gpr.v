module gpr(clk,rst,readreg1,readreg2,writereg,we,writedata,readdata1,readdata2,upover);
    input  [4:0]    readreg1,readreg2,writereg;   // reg bus
    input           we,upover                 ;   // write enable , addi upward overflow
    input           clk , rst                 ;   // clock,reset
    input  [31:0]   writedata                 ;   // input data
    output [31:0]   readdata1 , readdata2     ;   // output data
    wire   [31:0]   readdata1 , readdata2     ;   // output data
    reg    [31:0]   register [31:0];
    integer         i;
    
    /*output data*/
    assign readdata1=register[readreg1];
    assign readdata2=register[readreg2];
    /*input data*/
    always @(posedge clk or posedge rst)
      begin
        if(rst)
          for(i=0;i<32;i=i+1)
            case(i) 
              28:     register[i]<=32'h0000_1800;       //global pointer
              29:     register[i]<=32'h0000_2ffc;       //stack pointer
              default:register[i]<=32'b0;               //others
            endcase 
        else if(we)
            if(writereg!=5'b00000)
              register[writereg]<=writedata ;             //write in data
            
        if(upover==1)
          register[30][0]<=1'b1;
        /*else
          register[30][0]<=1'b0;*/
      end
endmodule
