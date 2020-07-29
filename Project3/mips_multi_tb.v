module mips_multi_testbench() ;
    reg         clk, rst ;
    reg  [31:0] INDATA;
    wire [31:0] OUTDATA;    //outdev has a reg,no need reg more
    //mips CPU_17( .clock(clk), .reset(rst));
    main MAIN_17(.clk(clk), .reset(rst), .indata(INDATA), .outdata(OUTDATA));

    
    initial begin  
        sys_reset;
        test1;
        //$stop;
    end
    
    task sys_reset;
      begin
        clk=0 ;
        rst=1 ;
        INDATA=32'h1234_abcd;
        #(1)rst = 0;  
      end
    endtask
    
    always #(50) clk=~clk;
      
    initial
      begin
        #7750 INDATA=32'haaaa_bbbb; 
      end 
       
    task test1 ;      
        begin
            $readmemh ("test3.txt",MAIN_17.MIPS_17.IM_17.rom);
            $readmemh ("test3_exception.txt",MAIN_17.MIPS_17.IM_17.rom,32'h0000_1180);
            //$display  ("im.rom loaded  successfully");
            //$readmemh ("test3_dm.txt",MAIN_17.MIPS_17.DM_17.ram );
            //$display  ("dm.ram loaded  successfully");
            //$readmemh ("test3_gpr.txt",MAIN_17.MIPS_17.GPR_17.register );
            //$display  ("gpr.register loaded  successfully");
            #30000;
        end
    endtask
     
    initial
    begin
      /*test3 ,monitor*/
      $display("                TIME    pc    status CP0_SR CP0_CAUSE  CP0_EPC TIMER_CTRL TIMER_PRESET COUNT     indata    outdata        $1        $2        $3        $4        $5        $6        $7        $8        $9        $10       $11       $14       $16       $27");
      $monitor($time,"  %h  %h  %h  %h  %h  %h  %h  %h || %h  %h || %h  %h  %h  %h  %h  %h  %h  %h  %h  %h  %h  %h  %h  %h",
      MAIN_17.MIPS_17.PC, MAIN_17.MIPS_17.CTRL_17.fsm, MAIN_17.MIPS_17.CP0_17.SR, MAIN_17.MIPS_17.CP0_17.Cause, MAIN_17.MIPS_17.CP0_17.EPCdetect, MAIN_17.Timer_17.CTRL, MAIN_17.Timer_17.PRESET, MAIN_17.Timer_17.COUNT, MAIN_17.indata, MAIN_17.outdata,
      MAIN_17.MIPS_17.GPR_17.register[1], MAIN_17.MIPS_17.GPR_17.register[2], MAIN_17.MIPS_17.GPR_17.register[3], MAIN_17.MIPS_17.GPR_17.register[4], MAIN_17.MIPS_17.GPR_17.register[5], MAIN_17.MIPS_17.GPR_17.register[6], MAIN_17.MIPS_17.GPR_17.register[7], 
      MAIN_17.MIPS_17.GPR_17.register[8], MAIN_17.MIPS_17.GPR_17.register[9], MAIN_17.MIPS_17.GPR_17.register[10], MAIN_17.MIPS_17.GPR_17.register[11], MAIN_17.MIPS_17.GPR_17.register[14], MAIN_17.MIPS_17.GPR_17.register[16], MAIN_17.MIPS_17.GPR_17.register[27]); 
      
      /*datapath monitor*/
      //$monitor($time,"  %h  %h  %d  %d  %h  %h  %h  %h  %h  %h",MAIN_17.MIPS_17.PC, MAIN_17.MIPS_17.CTRL_17.fsm, MAIN_17.MIPS_17.IR[25:21], MAIN_17.MIPS_17.IR[20:16], MAIN_17.MIPS_17.RD1, MAIN_17.MIPS_17.RD2, MAIN_17.MIPS_17.ALUOUTreg, MAIN_17.MIPS_17.DR, MAIN_17.MIPS_17.HitDEV, MAIN_17.MIPS_17.CP0OUT);
      //$monitor($time,"  %h  %h  %h  %h  %h  %b  %b",MAIN_17.MIPS_17.PC, MAIN_17.MIPS_17.CTRL_17.fsm, MAIN_17.Bridge_17.HitDEV0, MAIN_17.Bridge_17.HitDEV1, MAIN_17.Bridge_17.HitDEV2, MAIN_17.Bridge_17.WeCPU, MAIN_17.Bridge_17.PrAddr[1:0],  MAIN_17.Timer_17.DAT_I);

      /*test2 monitor($t0~$t7,pics 0~6)*/
      //$display("\n\t\t  TIME\tPC\t  INSTR\t   STATE\tWD\t $t0\t $t1\t   $t2\t     $t3\t $t4\t  $t5\t   $t6\t    $t7\t     $30\t $ra\t   pic0\t     pic1\t pic2\t   pic3\t   pic4\t    pic5    pic6\t");
      /*$monitor($time,"  %h  %h  %d  %h  %h  %h  %h  %h  %h  %h  %h  %h  %h  %h  %h%h%h%h  %h%h%h%h  %h%h%h%h  %h%h%h%h  %h%h%h%h  %h%h%h%h  %h%h%h%h  ",
      MAIN_17.MIPS_17.PC,MAIN_17.MIPS_17.INSTR,MAIN_17.MIPS_17.CTRL_17.fsm,MAIN_17.MIPS_17.WD,MAIN_17.MIPS_17.GPR_17.register[8],
      MAIN_17.MIPS_17.GPR_17.register[9],MAIN_17.MIPS_17.GPR_17.register[10],MAIN_17.MIPS_17.GPR_17.register[11],
      MAIN_17.MIPS_17.GPR_17.register[12],MAIN_17.MIPS_17.GPR_17.register[13],MAIN_17.MIPS_17.GPR_17.register[14],
      MAIN_17.MIPS_17.GPR_17.register[15],MAIN_17.MIPS_17.GPR_17.register[30],MAIN_17.MIPS_17.GPR_17.register[31],
      MAIN_17.MIPS_17.DM_17.ram[3],MAIN_17.MIPS_17.DM_17.ram[2],MAIN_17.MIPS_17.DM_17.ram[1],MAIN_17.MIPS_17.DM_17.ram[0],
      MAIN_17.MIPS_17.DM_17.ram[7],MAIN_17.MIPS_17.DM_17.ram[6],MAIN_17.MIPS_17.DM_17.ram[5],MAIN_17.MIPS_17.DM_17.ram[4],
      MAIN_17.MIPS_17.DM_17.ram[11],MAIN_17.MIPS_17.DM_17.ram[10],MAIN_17.MIPS_17.DM_17.ram[9],MAIN_17.MIPS_17.DM_17.ram[8],
      MAIN_17.MIPS_17.DM_17.ram[15],MAIN_17.MIPS_17.DM_17.ram[14],MAIN_17.MIPS_17.DM_17.ram[13],MAIN_17.MIPS_17.DM_17.ram[12],
      MAIN_17.MIPS_17.DM_17.ram[19],MAIN_17.MIPS_17.DM_17.ram[18],MAIN_17.MIPS_17.DM_17.ram[17],MAIN_17.MIPS_17.DM_17.ram[16],
      MAIN_17.MIPS_17.DM_17.ram[23],MAIN_17.MIPS_17.DM_17.ram[22],MAIN_17.MIPS_17.DM_17.ram[21],MAIN_17.MIPS_17.DM_17.ram[20],
      MAIN_17.MIPS_17.DM_17.ram[27],MAIN_17.MIPS_17.DM_17.ram[26],MAIN_17.MIPS_17.DM_17.ram[25],MAIN_17.MIPS_17.DM_17.ram[24]);*/
      //$monitor($time," %h  %h  %h  %h  %h  %h  %h  %h  %h ",CPU_17.PC, CPU_17.CTRL_17.fsm, CPU_17.ALUSRC, CPU_17.A, CPU_17.CAL_D, CPU_17.ALUOUTreg, CPU_17.CTRL_17.alusrc, CPU_17.GPR_17.register[11], CPU_17.GPR_17.register[12]);
    end
       
endmodule

