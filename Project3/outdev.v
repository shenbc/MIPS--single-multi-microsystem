module outdev(clk,reset,WeDEV1,DEV_Addr,indata,outdata);
  input clk,reset,WeDEV1;
  input [1:0] DEV_Addr;
  input [31:0] indata;
  output [31:0] outdata;
  reg [31:0] outdata;
  
  always@(posedge clk or posedge reset)
    begin
      if(reset)  outdata<=0;
      else if(WeDEV1&&DEV_Addr==2'b00)  outdata<=indata;
    end
endmodule