module im (addr,dout);                // 8*1024
    input  [11:0] addr;               //  address bus
    output [31:0] dout;               // 32-bit memory output

    reg    [7:0] rom [1023:0];
    
    //assign dout = {rom[addr+3],rom[addr+2],rom[addr+1],rom[addr+0]};// my test use
    assign dout = {rom[addr+0],rom[addr+1],rom[addr+2],rom[addr+3]};//teacher_test use
    //no need to sub 3000H 
endmodule
