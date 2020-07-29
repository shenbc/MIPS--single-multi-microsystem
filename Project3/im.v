module im (addr,dout);                // 8*1024*8=8KB
    input  [14:0] addr;               //  address bus
    output [31:0] dout;               // 32-bit memory output

    reg    [7:0] rom [8191:0];
    
    //assign dout = {rom[addr+3-15'h3000],rom[addr+2-15'h3000],rom[addr+1-15'h3000],rom[addr+0-15'h3000]};//test only
    assign dout = {rom[addr+0-15'h3000],rom[addr+1-15'h3000],rom[addr+2-15'h3000],rom[addr+3-15'h3000]};//test3 use,dif from dm
    //need to sub 3000H 
endmodule