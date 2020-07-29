module pc(clk,rst,npc,pc);
    input         clk,rst ;           // clock and reset
    input  [31:0]   npc   ;
    output [31:0]   pc    ;
    reg    [31:0]   pc    ; 

    always@(posedge clk or posedge rst)
        if(rst)
          pc<=32'h0000_3000;     //reset the pc to 0x0000_3000
        else
          pc<=npc;               //output next pc
endmodule
