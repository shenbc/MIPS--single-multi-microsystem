module main(clk,reset,indata,outdata);
  input clk,reset;
  input [31:0] indata;
  output[31:0] outdata;
  wire [31:0] DEV0_RD,DEV1_RD,LEDOUT,PrRD,PrWD,Timerout,DEV_WD;
  wire [29:0] PrAddr;
  wire [5:0] HWInt;
  wire [1:0] DEV_Addr;
  wire WeDEV0,WeDEV1,WeDEV2,HitDEV,WeCPU,IRQ;
  wire [31:0] outdata=DEV1_RD;
 
  indev INDEV_17(clk,reset,WeDEV0,DEV_Addr,indata,DEV0_RD);
  outdev OUTDEV_17(clk,reset,WeDEV1,DEV_Addr,DEV_WD,DEV1_RD);
  Timer Timer_17(clk,reset,DEV_Addr,WeDEV2,DEV_WD,Timerout,IRQ);
  Bridge Bridge_17(WeCPU,IRQ,PrAddr,PrWD,DEV0_RD,DEV1_RD,Timerout,DEV_Addr,PrRD,DEV_WD,WeDEV0,WeDEV1,WeDEV2,HitDEV,HWInt);
  mips MIPS_17(clk,reset,HitDEV,PrRD,HWInt,PrAddr,PrWD,WeCPU);
endmodule
