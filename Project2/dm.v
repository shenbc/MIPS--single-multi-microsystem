/*module dm(addr,din,we,clk,isbyte,dout);//8*1024
    input [31:0] din;                  //inut data                     
    input [11:0] addr;                 //input address
    input        we;                   //enable
    input        clk; 
    input        isbyte;               //lb or sb                        
    output[31:0] dout;                 //output data

    reg  [7:0] ram [1023:0];           //data memory

    assign  dout=(isbyte==1'b0)? {ram[addr+3],ram[addr+2],ram[addr+1],ram[addr+0]}:// output data
                 (isbyte==1'b1)? {{24{ram[addr][7]}},ram[addr]}:
                                 32'b0;
    
    always  @(posedge clk)begin
        if(we) begin
          if(isbyte==1'b0)
            {ram[addr+3],ram[addr+2],ram[addr+1],ram[addr+0]}<=din;
          else if(isbyte==1'b1)
            ram[addr+0]<=din[7:0];
        end
    end
endmodule*/

module dm(addr,din,we,clk,dout);       //8*1024
    input [31:0] din;                  //inut data                     
    input [11:0] addr;                 //input address
    input        we;                   //enable
    input        clk;                   
    output[31:0] dout;                 //output data

    reg  [7:0] ram [1023:0];           //data memory

    assign  dout={ram[addr+3],ram[addr+2],ram[addr+1],ram[addr+0]};// output data
    
    always  @(posedge clk)begin
        if(we) begin
            {ram[addr+3],ram[addr+2],ram[addr+1],ram[addr+0]}<=din;
        end
    end
endmodule