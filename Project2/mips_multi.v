module mips (clock,reset);
    input  clock,reset;     // clock and reset
    
    wire   [31:0]  PC , NPC , PC_4                  ;                 //  programmer counter i/o
    wire   [31:0]  INSTR                            ;                 //  instruction
    wire   [31:0]  RD1 , RD2 , ALU_OUT              ;                 //  data and calulate
    wire   [31:0]  WD ,EXT_D , CAL_D ,DM_D          ;                 //  data
    wire   [4:0]   WRITEREG                         ;                 //  register to write in data
    wire           ALUSRC , REGWRITE , MEMWRITE ,ZERO,NEG;            //  control signals
    wire   [1:0]   REGDST , MEMTOREG , EXT_OP , NPC_SEL , ALUCTR;     //  control signals
    wire           PCWr , IRWr ,UPOVER , ISBYTE;
    reg    [31:0]  A , B , ALUOUTreg , DR ;
    wire   [31:0]  IR;
    wire   [31:0]  BtoDM,DMtoDR;
                                        
    assign  BtoDM=(ISBYTE==1'b1)?{DM_D[31:8],B[7:0]}:
                                        B;
    assign  DMtoDR=(ISBYTE==1'b1)?{{24{DM_D[7]}},DM_D[7:0]}:
                                        DM_D;  
    
    pc PC_17( .clk(clock), .pcwr(PCWr), .rst(reset), .npc(NPC), .pc(PC));
    
    npc NPC_17( .pc(PC), .npc_sel(NPC_SEL), .zero(ZERO), .imme(IR[25:0]), .rs(A), .npc(NPC), .pc_4(PC_4), .neg(NEG));
                
    im IM_17( .addr(PC[11:0]), .dout(INSTR));
    
    ir IR_17( .clk(clock), .irwr(IRWr), .din(INSTR), .dout(IR));  
    
    mux_3_5 MUX1_17( .a0(IR[20:16]), .a1(IR[15:11]), .a2(5'h1f), .ch(REGDST), .out(WRITEREG));
                   
    gpr GPR_17( .clk(clock), .rst(reset), .readreg1(IR[25:21]), .readreg2(IR[20:16]), .writereg(WRITEREG),
                .we(REGWRITE), .writedata(WD), .readdata1(RD1), .readdata2(RD2), .upover(UPOVER));
                
    mux_2_32 MUX2_17(.a0(B), .a1(EXT_D), .ch(ALUSRC), .out(CAL_D));
              
    alu ALU_17(.a(A), .b(CAL_D), .alu_ctr(ALUCTR), .alu_out(ALU_OUT), .zero(ZERO), .upover(UPOVER), .neg(NEG));
    
    ctrl CTRL_17( .instr(IR), .pcwr(PCWr), .irwr(IRWr), .clk(clock), .rst(reset),.zero(ZERO),
                  .regdst(REGDST), .alusrc(ALUSRC), .memtoreg(MEMTOREG), .memwrite(MEMWRITE),
                  .regwrite(REGWRITE), .npc_sel(NPC_SEL), .ext_op(EXT_OP), .alu_ctr(ALUCTR),
                  .isbyte(ISBYTE), .neg(NEG)); 
    
    dm DM_17( .addr(ALUOUTreg[11:0]), /*.din(B),*/ .din(BtoDM), .we(MEMWRITE), /*.isbyte(ISBYTE),*/ .clk(clock), .dout(DM_D)); 
    
    
    mux_3_32 MUX3_17(.a0(ALUOUTreg), .a1(DR), .a2(PC_4), .ch(MEMTOREG), .out(WD));
    
    ext EXT_17( .din(IR[15:0]) , .ext_op(EXT_OP) , .dout(EXT_D) );
    
    always  @(posedge clock)
      begin
        A           <=  RD1     ;
        B           <=  RD2     ;
        ALUOUTreg   <=  ALU_OUT ;
        //DR          <=  DM_D;
        DR          <=  DMtoDR  ;
      end
    
endmodule
