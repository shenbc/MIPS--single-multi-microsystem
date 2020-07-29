module cp0(clk,reset,EPCWr,pc,DIn,HWInt,Sel,Wen,EXLSet,EXLClr,IntReq,epc,DOut);
  input clk,reset,EPCWr,Wen,EXLSet,EXLClr;
  input [29:0] pc;
  input [31:0] DIn;
  input [5:0] HWInt;
  input [4:0] Sel;
  output IntReq;
  output [29:0] epc;
  output [31:0] DOut;
  wire IntReq;
  wire [31:0] Dout;
  wire [31:0] EPCdetect={epc,2'b00};//testbench use only
  reg [5:0] im,hwint_pend;
  reg exl,ie;
  reg [29:0] epc;
  wire [31:0] SR,Cause,Prid;
  assign SR={16'b0,im,8'b0,exl,ie};
  assign Cause={16'b0,hwint_pend,10'b0};
  assign IntReq=|(HWInt&im)&ie&!exl;
  assign Prid=32'h1804_1117;
  assign DOut=(Sel==12)?SR:(Sel==13)?Cause:(Sel==14)?{epc,2'b00}:(Sel==15)?Prid:32'b0;
  always @(posedge clk or posedge reset)
    begin
      if(reset)
        begin
          im=0;
          exl=0;
          ie=0;
          hwint_pend=0;//cause-ip
          epc=0;
        end
      else
        if(!Wen)
          begin
            if(EXLSet)  exl<=1'b1;
            else if(EXLClr)  exl<=1'b0;
            hwint_pend=HWInt;
            if(EPCWr) epc<=pc;
          end
        if(Wen)
          case(Sel)
            5'b01100:{im,exl,ie}<={DIn[15:10],DIn[1],DIn[0]};
            5'b01101:hwint_pend=DIn[15:10];
            5'b01110:epc=DIn[31:2];
          endcase
    end   
endmodule