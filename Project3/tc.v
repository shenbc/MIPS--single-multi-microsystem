module Timer(CLK_I,RST_I,ADD_I,WE_I,DAT_I,DAT_O,IRQ);
  input CLK_I,RST_I,WE_I;
  input [1:0] ADD_I;
  input [31:0] DAT_I;
  output [31:0] DAT_O;
  output IRQ;
  reg [31:0] CTRL,PRESET,COUNT;
  wire IM,Enable,IRQ;
  wire [1:0] Mode;
  wire [31:0] DAT_O;
  assign IM=CTRL[3];
  assign Mode=CTRL[2:1];
  assign Enable=CTRL[0];
  assign IRQ=((Mode==2'b00)&(IM==1)&(COUNT==0))?1:0;
  assign DAT_O=(ADD_I==2'b00)?CTRL:(ADD_I==2'b01)?PRESET:COUNT;
  always@(posedge CLK_I or posedge RST_I)
    begin
      if(RST_I)
        begin
          CTRL=0;
          PRESET=0;
          COUNT=0;
        end
      else
        begin
          if(WE_I)
            case(ADD_I)
              2'b00:CTRL=DAT_I;
              2'b01:PRESET=DAT_I;
            endcase
          case(Mode)
            2'b00:begin
                    if(!Enable)  COUNT<=PRESET;
                    else if(Enable&&(COUNT!=0))  COUNT<=COUNT-1;
                  end
            2'b01:begin
                    if(COUNT==0)  COUNT<=PRESET;
                    else if(Enable&&(COUNT!=0))  COUNT<=COUNT-1;
                  end
          endcase
        end
    end
endmodule