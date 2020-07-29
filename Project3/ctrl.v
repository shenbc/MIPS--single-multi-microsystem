module ctrl ( instr , pcwr , irwr , clk , rst , zero , regdst , alusrc , memtoreg , memwrite , regwrite , npc_sel , ext_op , alu_ctr , isbyte ,intreq,hitdev,epcwr,wen,exlset,exlclr,fsm); 
    input  [31:0] instr;
    input         rst ,clk ,zero ;
    input         intreq,hitdev;            /*new*/
    output        epcwr,wen,exlset,exlclr;  /*new*/
    output        alusrc ,  regwrite , memwrite;
    output [1:0]  regdst , ext_op , alu_ctr;
    output [2:0]  memtoreg ,npc_sel;        /*new*/
    output        pcwr , irwr , isbyte;
    output [3:0]  fsm;                      /*new*/
    wire   [5:0]  opcode , funct; 
    wire   [4:0]  rs , rt;
    assign  opcode = instr[31:26];
    assign  funct  = instr[5:0];
    assign  rt     = instr[20:16];
    assign  rs     = instr[25:21];
    
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
    
    wire eret = (opcode == 6'h10) && (funct == 6'h18);
    wire mfc0 = (opcode == 6'h10) && (rs == 5'h00);
    wire mtc0 = (opcode == 6'h10) && (rs == 5'h04);
    
    /*FSM*/
    reg   [3:0]   fsm;
    parameter     S0 = 4'd0,S1 = 4'd1,S2 = 4'd2,S3 = 4'd3,S4 = 4'd4,
                  S5 = 4'd5,S6 = 4'd6,S7 = 4'd7,S8 = 4'd8,S9 = 4'd9,S10 = 4'd10;
    
    /*op*/
    parameter       R  =  3'b000,           // R_type
                    B  =  3'b001,           // B_type
                    J  =  3'b010,           // J_type
                    MA =  3'b011;           // lw/sw_type
    
    wire  [2:0]     op  = (addu|| subu || addi || addiu || slt || ori || lui || mfc0 || mtc0)? R   :
                          (beq)                                                              ? B   :
                          (j || jal || jr || eret)                                           ? J   :
                          (sw || sb || lw || lb )                                            ? MA  :
                                                                                             3'bx  ;
    
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
            S3:           fsm   <=  S4  ;
            S4:if(intreq) fsm   <=  S10 ; else fsm  <=  S0;
            S5:if(intreq) fsm   <=  S10 ; else fsm  <=  S0;
            S6:           fsm   <=  S7  ;
            S7:if(intreq) fsm   <=  S10 ; else fsm  <=  S0;
            S8:if(intreq) fsm   <=  S10 ; else fsm  <=  S0;
            S9:if(intreq) fsm   <=  S10 ; else fsm  <=  S0;
            S10:          fsm   <=  S0  ;
            default:      fsm   <=  S0  ;
           endcase

    //output control signal
    wire [1:0]  regdst,ext_op,alu_ctr;
    wire [2:0]  memtoreg,npc_sel;
    wire        alusrc,regwrite,memwrite,pcwr,irwr,isbyte;
    wire        epcwr,wen,exlset,exlclr;
    
    assign  npc_sel     = (fsm == S0)                         ?   3'b000:
                          ((fsm == S8) && (beq))              ?   3'b001:
                          (fsm == S9) && (jr)                 ?   3'b011:
                          ((fsm == S9) && (jal || j))         ?   3'b010:
                          (fsm== S10)                         ?   3'b100:
                          (fsm == S9) && (eret)               ?   3'b101:
                                                                  3'bxxx;
                                                                  
    assign  pcwr        = (fsm == S0)||(fsm == S9)||((fsm == S8)&&(zero&&beq))||(fsm == S10);
    
    assign  irwr        = (fsm == S0);
    
    assign  memtoreg    = (fsm == S7) && !mfc0                ?   3'b000 :
                          (fsm == S4) && !hitdev              ?   3'b001 :
                          (fsm == S9)                         ?   3'b010 :
                          (fsm == S7) && mfc0                 ?   3'b011 :
                          (hitdev&lw)                         ?   3'b100 :
                                                                  3'bxxx ;
                                                                                                                                
    assign  regdst      = ((fsm == S7) && i) || (fsm == S4) ||((fsm==S7)&&mfc0) ?   2'b00 :
                          ((fsm == S7) && !i )                                  ?   2'b01 :
                          (fsm == S9) && (jal)                                  ?   2'b10 :
                                                                                    2'bxx ;
                                                                  
    assign  regwrite    = (fsm == S7)&&(addu+subu+ori+lui+slt+addi+addiu+mfc0) || ((fsm == S4) && l) || ((fsm == S9) && (jal));
  
    assign  ext_op      = ((fsm == S6) && lui)                                                    ?   2'b10 :
                          (fsm == S6) && (ori)                                                    ?   2'b00 :
                          (((fsm == S6)&&i)||(fsm == S2)||(fsm == S3)||(fsm == S4)||(fsm == S5))  ?   2'b01 :
                                                                                                      2'bxx ; 
                                                                                                                                                                                             
    assign  alusrc      = (((fsm == S6)&&i) || (fsm == S2) || (fsm == S3) || (fsm == S4) || (fsm == S5));

    assign  alu_ctr     = ((fsm == S6)&&(slt))                      ?   2'b11 :
                          ((fsm == S6)&&(ori || lui))               ?   2'b10 :
                          (subu)                                    ?   2'b01 :
                          (((fsm==S6)&&(addu||addiu||addi)) || (fsm==S2) || (fsm==S3) || (fsm==S4) || (fsm==S5))  
                                                                    ?   2'b00 :
                                                                        2'bxx ;
                                                            
    assign  memwrite    = (s && (fsm == S5)) ;
    
    assign  isbyte      = ((fsm == S3) && lb) || ((fsm == S5) &&sb);
    
    assign  wen         =(mtc0&(fsm===S7))?1:0;
	  assign  exlset      =(fsm===S10)?1:0;
	  assign  exlclr      =(eret==1)?1:0;
	  assign  epcwr       =(fsm===S10)?1:0; 
                                     
endmodule                                     
