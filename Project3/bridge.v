module Bridge(WeCPU,IRQ,PrAddr,PrWD,DEV0_RD,DEV1_RD,DEV2_RD,DEV_Addr,PrRD,DEV_WD,WeDEV0,WeDEV1,WeDEV2,HitDEV,HWInt);
  input WeCPU,IRQ;
  input [29:0] PrAddr;
  input [31:0] PrWD,DEV0_RD,DEV1_RD,DEV2_RD;
  output [1:0] DEV_Addr;
  output [5:0] HWInt;
  output [31:0] PrRD;  //GPR
  output [31:0] DEV_WD;  //waishe
  output WeDEV0,WeDEV1,WeDEV2,HitDEV;
  
  wire HitDEV0,HitDEV1,HitDEV2,HitDEV,WeDEV0,WeDEV1,WeDEV2;
  wire [1:0] DEV_Addr;
  wire [31:0] DEV_WD,PrRD;
  wire [5:0] HWInt;
  
  assign HWInt={5'b0,IRQ};
  assign HitDEV=(HitDEV0|HitDEV1|HitDEV2)?1:0;
  assign DEV_Addr=PrAddr[1:0];
  assign DEV_WD=PrWD;
  assign HitDEV0=(({PrAddr,2'b00}>=32'h0000_7A00)&&({PrAddr,2'b00}<=32'h0000_7A03))?1:0;  //input
  assign HitDEV1=(({PrAddr,2'b00}>=32'h0000_7B00)&&({PrAddr,2'b00}<=32'h0000_7B0B))?1:0;  //output
  assign HitDEV2=(({PrAddr,2'b00}>=32'h0000_7F00)&&({PrAddr,2'b00}<=32'h0000_7F0B))?1:0;  //Timer
  assign PrRD=(HitDEV0)?DEV0_RD:(HitDEV1)?DEV1_RD:DEV2_RD;
  assign WeDEV0=WeCPU&HitDEV0;  //input
  assign WeDEV1=WeCPU&HitDEV1;  //output
  assign WeDEV2=WeCPU&HitDEV2;  //Timer
endmodule