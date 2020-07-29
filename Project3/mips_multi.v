module mips (clock,reset,HitDEV,PrDIn,HWInt,PrAddr,PrDOut,WeCPU);
    input         clock,reset,HitDEV;     // clock and reset
    input  [31:0] PrDIn;
    input  [5:0]  HWInt;
    output [29:0] PrAddr;
    output [31:0] PrDOut;
    output        WeCPU;
    
    wire   [31:0]  PC , NPC , PC_4                  ;                 //  programmer counter i/o
    wire   [31:0]  INSTR                            ;                 //  instruction
    wire   [31:0]  RD1 , RD2 , ALU_OUT              ;                 //  data and calulate
    wire   [31:0]  WD ,EXT_D , CAL_D ,DM_D          ;                 //  data
    wire   [4:0]   WRITEREG                         ;                 //  register to write in data
    wire           ALUSRC , REGWRITE , MEMWRITE ,ZERO;                //  control signals
    wire   [1:0]   REGDST  , EXT_OP , ALUCTR;                         //  control signals
    wire   [2:0]   NPC_SEL , MEMTOREG;
    wire           PCWr , IRWr ,UPOVER , ISBYTE;
    reg    [31:0]  A , B , ALUOUTreg , DR ;
    wire   [31:0]  IR;
    wire   [31:0]  BtoDM,DMtoDR;
    wire           HitDEV,EPCWR,WEN,EXLSET,EXLCLR,INTREQ;      //new
    wire   [5:0]   HWInt;
    wire   [31:0]  PrDOut,DOUT,CP0OUT;
    wire   [29:0]  PrAddr,EPC;
    wire   [3:0]   FSM;
    
                                        
    assign  BtoDM=(ISBYTE==1'b1)?{DM_D[31:8],B[7:0]}:
                                        B;
    assign  DMtoDR=(ISBYTE==1'b1)?{{24{DM_D[7]}},DM_D[7:0]}:
                                        DM_D;  
    
    assign  PrDOut=B;
    
    assign  PrAddr=ALUOUTreg[31:2];
    
    assign WeCPU=(({PrAddr,2'b00}>=32'h0000_7A00)&&(IR[31:26]==6'h2b)&&(FSM===4'd5))?1:0;

    
    pc PC_17( .clk(clock), .pcwr(PCWr), .rst(reset), .npc(NPC), .pc(PC));
    
    npc NPC_17( .pc(PC), .npc_sel(NPC_SEL), .zero(ZERO), .imme(IR[25:0]), .rs(A), .npc(NPC), .pc_4(PC_4), .epc(EPC));/*epc need to add*/
                
    im IM_17( .addr(PC[14:0]), .dout(INSTR));
    
    ir IR_17( .clk(clock), .irwr(IRWr), .din(INSTR), .dout(IR));  
    
    mux_3_5 MUX1_17( .a0(IR[20:16]), .a1(IR[15:11]), .a2(5'h1f), .ch(REGDST), .out(WRITEREG));
                   
    gpr GPR_17( .clk(clock), .rst(reset), .readreg1(IR[25:21]), .readreg2(IR[20:16]), .writereg(WRITEREG),
                .we(REGWRITE), .writedata(WD), .readdata1(RD1), .readdata2(RD2), .upover(UPOVER));
                
    mux_2_32 MUX2_17(.a0(B), .a1(EXT_D), .ch(ALUSRC), .out(CAL_D));
              
    alu ALU_17(.a(A), .b(CAL_D), .alu_ctr(ALUCTR), .alu_out(ALU_OUT), .zero(ZERO), .upover(UPOVER));
    
    ctrl CTRL_17( .instr(IR), .pcwr(PCWr), .irwr(IRWr), .clk(clock), .rst(reset),.zero(ZERO),
                  .regdst(REGDST), .alusrc(ALUSRC), .memtoreg(MEMTOREG), .memwrite(MEMWRITE),
                  .regwrite(REGWRITE), .npc_sel(NPC_SEL), .ext_op(EXT_OP), .alu_ctr(ALUCTR),
                  .isbyte(ISBYTE), .intreq(INTREQ), .hitdev(HitDEV), .epcwr(EPCWR), .wen(WEN), .exlset(EXLSET), .exlclr(EXLCLR), .fsm(FSM)); 
    
    dm DM_17( .addr(ALUOUTreg[11:0]), .din(BtoDM), .we(MEMWRITE), .clk(clock), .dout(DM_D)); 
    
    
    mux_5_32 MUX3_17(.a0(ALUOUTreg), .a1(DR), .a2(PC_4), .a3(CP0OUT), .a4(PrDIn), .ch(MEMTOREG), .out(WD));/*new*/
    
    ext EXT_17( .din(IR[15:0]) , .ext_op(EXT_OP) , .dout(EXT_D) );
    
    cp0 CP0_17( .clk(clock), .reset(reset), .EPCWr(EPCWR), .pc(PC[31:2]), .DIn(B), .HWInt(HWInt), .Sel(IR[15:11]),
                .Wen(WEN), .EXLSet(EXLSET), .EXLClr(EXLCLR), .IntReq(INTREQ), .epc(EPC), .DOut(CP0OUT));

    
    always  @(posedge clock)
      begin
        A           <=  RD1     ;
        B           <=  RD2     ;
        ALUOUTreg   <=  ALU_OUT ;
        DR          <=  DMtoDR  ;
      end
    
endmodule
