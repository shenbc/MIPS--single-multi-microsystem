module dm(addr,din,we,clk,dout);       //8*1024
    input [31:0] din;                  //inut data                     
    input [11:0] addr;                 //input address
    input        we;                   //enable
    input        clk;                   
    output[31:0] dout;                 //output data

    reg  [7:0] ram [12287:0];           //data memory

    assign  dout={ram[addr+3],ram[addr+2],ram[addr+1],ram[addr+0]};// output data
    
    always  @(posedge clk)begin
        if(we) begin
            {ram[addr+3],ram[addr+2],ram[addr+1],ram[addr+0]}<=din;
        end
    end
endmodule