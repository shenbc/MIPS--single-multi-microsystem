module mips(clock,reset);
    input  clock,reset;
       
    wire   [31:0]  PC,NPC,PC_4;                           //  programmer counter i/o
    wire   [31:0]  INSTR;                                 //  instruction
    wire   [31:0]  RD1,RD2,ALU_OUT;                       //  data and calulate
    wire   [31:0]  WD,EXT_D,CAL_D,DM_D;                   //  data
    wire   [4:0]   WRITEREG;                              //  register to write in data
    wire           ALUSRC,REGWRITE,MEMWRITE,ZERO,UPOVER;  //  control signals
    wire   [1:0]   REGDST,MEMTOREG,EXT_OP,NPC_SEL,ALUCTR; //  control signals
    
    pc PC_17( .clk(clock), .rst(reset), .npc(NPC), .pc(PC));
        
    npc NPC_17( .pc(PC), .npc_sel(NPC_SEL), .zero(ZERO), .imme(INSTR[25:0]), .rs(RD1),
             .npc(NPC), .pc_4(PC_4));
                
    im IM_17( .addr(PC[11:0]), .dout(INSTR));
    
    mux_3_5 MUX1_17( .a0(INSTR[20:16]), .a1(INSTR[15:11]), .a2(5'h1f), .ch(REGDST) , .out(WRITEREG));
                   
    gpr GPR_17( .clk(clock), .rst(reset), .readreg1(INSTR[25:21]) , 
             .readreg2(INSTR[20:16]), .writereg(WRITEREG), .we(REGWRITE), 
             .writedata(WD), .readdata1(RD1), .readdata2(RD2), .upover(UPOVER));
                
    mux_2_32 MUX2_17(.a0(RD2) , .a1(EXT_D) , .ch(ALUSRC) , .out(CAL_D) );
              
    alu ALU_17(.a(RD1), .b(CAL_D) , .alu_ctr(ALUCTR) , .alu_out(ALU_OUT) , .zero(ZERO), .upover(UPOVER));
    
    ctrl CTRL_17( .instr(INSTR), .regdst(REGDST), .alusrc(ALUSRC), .memtoreg(MEMTOREG), .memwrite(MEMWRITE), 
               .regwrite(REGWRITE), .npc_sel(NPC_SEL), .ext_op(EXT_OP), .alu_ctr(ALUCTR)); 
    
    dm DM_17( .addr(ALU_OUT[11:0]), .din(RD2), .we(MEMWRITE), .clk(clock), .dout(DM_D)); 
    
    mux_3_32 MUX3_17(.a0(ALU_OUT), .a1(DM_D), .a2(PC_4), .ch(MEMTOREG), .out(WD));
                 
    ext EXT_17( .din(INSTR[15:0]), .ext_op(EXT_OP), .dout(EXT_D));
    
endmodule