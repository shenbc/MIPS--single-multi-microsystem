module pc(clk,pcwr,rst,npc,pc);
    input           clk,rst,pcwr;    // clock and reset
    input  [31:0]   npc         ;    // next pc
    output [31:0]   pc          ;    // output pc 
    
    reg    [31:0]   pc          ; 

    always@(posedge clk or posedge rst)
        if(rst)
          pc<=32'h0000_3000;
        else if(pcwr)
          pc<=npc;
endmodule
