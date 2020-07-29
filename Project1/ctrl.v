module ctrl(instr,regdst,alusrc,memtoreg,memwrite,regwrite,npc_sel,ext_op,alu_ctr);
    input  [31:0] instr ;                        
    output        alusrc ,  regwrite , memwrite;
    output [1:0]  memtoreg ,regdst , ext_op ,npc_sel , alu_ctr; 
    wire   [5:0]  opcode , funct , rt , hint  ; 
    assign  opcode = instr[31:26];
    assign  funct  = instr[5:0];
    assign  hint   = instr[10:6];
    assign  rt     = instr[20:16];
    
    /*instruction decode*/
    wire addu = (opcode == 6'h00) & (funct == 6'h21); // addu
    wire subu = (opcode == 6'h00) & (funct == 6'h23); // subu
    wire jr   = (opcode == 6'h00) & (funct == 6'h08); // jr
    wire slt  = (opcode == 6'h00) & (funct == 6'h2a); // slt
    wire addi = (opcode == 6'h08);                    // addi
    wire addiu= (opcode == 6'h09);                    // addiu
    wire ori  = (opcode == 6'h0d);                    // ori
    wire lw   = (opcode == 6'h23);                    // lw
    wire sw   = (opcode == 6'h2b);                    // sw
    wire beq  = (opcode == 6'h04);                    // beq
    wire lui  = (opcode == 6'h0f);                    // lui
    wire j    = (opcode == 6'h02);                    // j
    wire jal  = (opcode == 6'h03);                    // jal
    wire jalr = (opcode == 6'h00) & (funct == 6'h09); //jalr 
    
    /*output control signal*/
    assign  regdst      = jal               ? 2'b10 :
                          (addu||subu||slt||jalr) ? 2'b01 : /*new jalr*/
                                              2'b00 ;
    assign  alusrc      = (addu||subu||beq||jr||slt) ? 0 :
                                                       1 ;
    assign  memtoreg    = (jal||jalr) ? 2'b10 :             /*new jalr*/
                          lw  ? 2'b01 :
                                2'b00 ;
    assign  regwrite    = (sw||beq||j||jr) ? 0 :
                                             1 ; /*new jalr*/
    assign  npc_sel     = beq       ? 2'b01 :
                          (j||jal)  ? 2'b10 :
                          (jr||jalr)        ? 2'b11 :  /*new jalr*/
                                      2'b00 ;
    assign  memwrite    = sw ? 1 :
                               0 ;
    assign  ext_op      = lui ? 2'b10 :
                          ori ? 2'b00 :
                                2'b01 ;
    assign  alu_ctr     = (slt)       ? 2'b11 :
                          (ori||lui)  ? 2'b10 :
                          (subu||beq) ? 2'b01 :
                                        3'b00 ;
endmodule                                                              
