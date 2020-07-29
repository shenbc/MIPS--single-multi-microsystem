module npc (pc,npc_sel,zero,imme,rs,npc,pc_4,epc); //next pc
    input  [25:0]   imme        ;           // clock and reset
    input  [31:0]   pc          ;           // next pc input , pc = present instruction+4
    input  [31:0]   rs          ;           // data in the $rs
    input  [2:0]    npc_sel     ;           // instr type
    input           zero        ;           // ctrl the operation
    input  [31:2]   epc         ;
    output [31:0]   npc         ;           // ouput pc 
    output [31:0]   pc_4        ; 
    
    wire   [31:0]   npc , pc_4;
    wire   [15:0]   offset    ;
    
    assign  offset  = imme[15:0];           // set the offset   
    assign  pc_4    = pc        ;           // ouput pc+4 ,pc has already added 4,should not add 4 again 
    
    parameter  R  = 3'b000,                 // other instruction
               BEQ= 3'b001,                 // BEQ
               J  = 3'b010,                 // J or JAL
               JR = 3'b011;                 // JR      
    
    assign  npc= (npc_sel==R)?   pc+4:      // pc = present instruction+8
                 (npc_sel==BEQ&&zero)? pc_4+{{14{offset[15]}},offset,2'b0}:
                 (npc_sel==J)?   {pc[31:28],imme,2'b0}:
                 (npc_sel==JR)?  rs:
                 (npc_sel==3'b100)?32'h0000_4180://S10,interrupt
                 (npc_sel==3'b101)?{epc,2'b00}://eret
                                 pc_4;
endmodule
