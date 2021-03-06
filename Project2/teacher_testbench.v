module teacher_testbench() ;
    reg clk, rst ;
    
    mips CPU_17( .clock(clk), .reset(rst));
    
    initial begin  
        sys_reset;
        test1;
        //$stop;
    end
    
    task sys_reset;
      begin
        clk=0 ;
        rst=1 ;
        #(1)rst = 0;
      end
    endtask
    
    always #(50) clk=~clk;
       
    task test1 ;      
        begin
            //$readmemh ("teacher_test2.txt",CPU_17.IM_17.rom); 
            $readmemh ("bltzal.txt",CPU_17.IM_17.rom);
            //$display  ("im.rom loaded  successfully");
            #30000;
        end
    endtask
     
    initial
    begin

      $display("\n\t\t  TIME\tPC\t  INSTR\t   STATE\tWD\t $t0\t $t1\t   $t2\t     $t3\t $t4\t  $t5\t   $t6\t    $t7\t     $30\t $ra\t   pic0\t     pic1\t pic2\t   pic3\t   pic4\t    pic5    pic6\t");

      $monitor($time,"  %h  %h  %d  %h  %h  %h  %h  %h  %h  %h  %h  %h  %h  %h  %h%h%h%h  %h%h%h%h  %h%h%h%h  %h%h%h%h  %h%h%h%h  %h%h%h%h  %h%h%h%h  %h %h %h",
      CPU_17.PC,CPU_17.INSTR,CPU_17.CTRL_17.fsm,CPU_17.WD,CPU_17.GPR_17.register[8],
      CPU_17.GPR_17.register[9],CPU_17.GPR_17.register[10],CPU_17.GPR_17.register[11],
      CPU_17.GPR_17.register[12],CPU_17.GPR_17.register[13],CPU_17.GPR_17.register[14],
      CPU_17.GPR_17.register[15],CPU_17.GPR_17.register[30],CPU_17.GPR_17.register[31],
      CPU_17.DM_17.ram[3],CPU_17.DM_17.ram[2],CPU_17.DM_17.ram[1],CPU_17.DM_17.ram[0],
      CPU_17.DM_17.ram[7],CPU_17.DM_17.ram[6],CPU_17.DM_17.ram[5],CPU_17.DM_17.ram[4],
      CPU_17.DM_17.ram[11],CPU_17.DM_17.ram[10],CPU_17.DM_17.ram[9],CPU_17.DM_17.ram[8],
      CPU_17.DM_17.ram[15],CPU_17.DM_17.ram[14],CPU_17.DM_17.ram[13],CPU_17.DM_17.ram[12],
      CPU_17.DM_17.ram[19],CPU_17.DM_17.ram[18],CPU_17.DM_17.ram[17],CPU_17.DM_17.ram[16],
      CPU_17.DM_17.ram[23],CPU_17.DM_17.ram[22],CPU_17.DM_17.ram[21],CPU_17.DM_17.ram[20],
      CPU_17.DM_17.ram[27],CPU_17.DM_17.ram[26],CPU_17.DM_17.ram[25],CPU_17.DM_17.ram[24],CPU_17.NEG,CPU_17.NPC_SEL,CPU_17.NPC_17.npc);
      //$monitor($time," %h  %h  %h  %h  %h  %h  %h  %h  %h ",CPU_17.PC, CPU_17.CTRL_17.fsm, CPU_17.ALUSRC, CPU_17.A, CPU_17.CAL_D, CPU_17.ALUOUTreg, CPU_17.CTRL_17.alusrc, CPU_17.GPR_17.register[11], CPU_17.GPR_17.register[12]);
    end
       
endmodule



