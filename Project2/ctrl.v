module ctrl ( instr , pcwr , irwr , clk , rst , zero , regdst , alusrc , memtoreg , memwrite , regwrite , npc_sel , ext_op , alu_ctr , isbyte, neg); 
    input  [31:0] instr;
    input         rst ,clk ,zero ,neg;
    output        alusrc ,  regwrite , memwrite;
    output [1:0]  memtoreg ,regdst , ext_op , alu_ctr,npc_sel; //  ouput control signal
    output        pcwr , irwr , isbyte;
    wire   [5:0]  opcode , funct , rt ; 
    assign  opcode = instr[31:26];
    assign  funct  = instr[5:0];
    assign  rt     = instr[20:16];
    
    // instruction decode
    wire addu = (opcode == 6'h00) & (funct == 6'h21); // addu
    wire subu = (opcode == 6'h00) & (funct == 6'h23); // subu
    wire slt  = (opcode == 6'h00) & (funct == 6'h2a); // slt

    wire addi = (opcode == 6'h08);                    // addi
    wire addiu= (opcode == 6'h09);                    // addiu
    wire ori  = (opcode == 6'h0d);                    // ori
    wire lui  = (opcode == 6'h0f);                    // lui
    
    wire lw   = (opcode == 6'h23);                    // lw
    wire lb   = (opcode == 6'h20);                    // lb
    
    wire sw   = (opcode == 6'h2b);                    // sw
    wire sb   = (opcode == 6'h28);                    // sb
    
    wire beq  = (opcode == 6'h04);                    // beq
    
    wire j    = (opcode == 6'h02);                    // j
    wire jal  = (opcode == 6'h03);                    // jal
    wire jr   = (opcode == 6'h00) & (funct == 6'h08); // jr
    
    wire bltzal=(opcode == 6'b000001) & (instr[20:16] == 5'b10000);
    
    /*FSM*/
    reg   [3:0]   fsm;
    parameter     S0 = 4'd0,S1 = 4'd1,S2 = 4'd2,S3 = 4'd3,S4 = 4'd4,
                  S5 = 4'd5,S6 = 4'd6,S7 = 4'd7,S8 = 4'd8,S9 = 4'd9;
    
    /*op*/
    parameter       R  =  3'b000,           // R_type
                    B  =  3'b001,           // B_type
                    J  =  3'b010,           // J_type
                    MA =  3'b011;           // lw/sw_type
    
    wire  [2:0]     op  = (addu|| subu || addi || addiu || slt || ori || lui)? R   :
                          (beq||bltzal)                                      ? B   :
                          (j || jal || jr )                                  ? J   :
                          (sw || sb || lw || lb )                            ? MA  :
                                                                               3'bx;
    
    /*judge u or i*/
    wire  i   = (addu || subu || slt)         ? 0   :
                (addi || addiu || ori || lui) ? 1   :
                                                0   ;                                                              
    wire  s   = (sw || sb);               
    wire  l   = (lw || lb);
                                                
    /*FSM*/
    always@(posedge clk or posedge rst)
        if (rst)
          fsm <= S0 ;
        else
          case(fsm)
            S0: fsm   <=  S1  ;                       
            S1: case(op)
                  R :   fsm   <=  S6  ;
                  B :   fsm   <=  S8  ;
                  J :   fsm   <=  S9  ;
                  MA:   fsm   <=  S2  ;
                endcase
            S2: case(1'b1)
                  l :   fsm   <=  S3  ;
                  s :   fsm   <=  S5  ;
                endcase
            S3:         fsm   <=  S4  ;
            S4:         fsm   <=  S0  ;
            S5:         fsm   <=  S0  ;
            S6:         fsm   <=  S7  ;
            S7:         fsm   <=  S0  ;
            S8:         fsm   <=  S0  ;
            S9:         fsm   <=  S0  ;
            default:    fsm   <=  S0  ;
           endcase

    //output control signal
    wire [1:0]  memtoreg,regdst,ext_op,npc_sel,alu_ctr;
    wire        alusrc,regwrite,memwrite,pcwr,irwr,isbyte;
    
    assign  npc_sel     = (fsm == S0)                         ?   2'b00:
                          ((fsm == S8))                       ?   2'b01:/*new*/
                          (fsm == S9) && (jr)                 ?   2'b11:
                          ((fsm == S9) && (jal || j))         ?   2'b10:
                                                                  2'bxx;
                                                                  
    assign  pcwr        = (fsm == S0)||(fsm == S9)||((fsm == S8)&&(zero&&beq))||((fsm == S8)&&(bltzal&&neg));
    
    assign  irwr        = (fsm == S0);
    
    assign  memtoreg    = (fsm == S7)                         ?   2'b00 :
                          (fsm == S4)                         ?   2'b01 :
                          (fsm == S9)||(fsm == S8)            ?   2'b10 :
                                                                  2'bxx ;
                                                                                                                                
    assign  regdst      = ((fsm == S7) && i) || (fsm == S4)         ?   2'b00 :
                          ((fsm == S7) && !i )                      ?   2'b01 :
                          (fsm == S9) && (jal) ||(fsm==S8)                     ?   2'b10 :
                                                                        2'bxx ;
                                                                  
    assign  regwrite    = (fsm == S7) || ((fsm == S4) && l) || ((fsm == S9) && (jal)) ||((fsm==S8)&&(bltzal));
  
    assign  ext_op      = ((fsm == S6) && lui)                       ?   2'b10 :
                          (fsm == S6) && (ori)                       ?   2'b00 :
                          (((fsm == S6)&&i)||((fsm == S2)))          ?   2'b01 :/*new*/
                                                                         2'bxx ; 
                                                                                                                                                                                             
    assign  alusrc      = (((fsm == S6)&&i) || ((fsm == S2)));

    assign  alu_ctr     = ((fsm == S6)&&(slt))                      ?   2'b11 :
                          ((fsm == S6)&&(ori || lui))               ?   2'b10 :
                          (subu)                                    ?   2'b01 :
                          (((fsm==S6)&&(addu||addiu||addi)) || (fsm==S2))  
                                                                    ?   2'b00 :
                                                                        2'bxx ;
                                                            
    assign  memwrite    = (s && (fsm == S5)) ;
    
    assign  isbyte      = ((fsm == S3) && lb) || ((fsm == S5) &&sb);
                                     
endmodule                                     
