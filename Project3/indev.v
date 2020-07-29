module indev(clk,reset,WeDEV0,DEV_Addr,indata,outdata);
  input clk,reset,WeDEV0;
  input [1:0] DEV_Addr;
  input [31:0] indata;
  output [31:0] outdata;
  wire [31:0] outdata;
  assign outdata=indata;
endmodule
