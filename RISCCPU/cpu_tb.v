`include "./cpu.v"
`include "./mem/mem.v"
`include "./mem/addr_decoder.v"

`timescale 1ns/1ns
`define PERIOD 100

module cputop;
  reg reset_req, clock;
  integer test;
  reg[(3*8):0] mnemonic;
  wire [12:0] ir_addr, pc_addr;
  reg [12:0] IR_addr, PC_addr;
  //reg load_pc, inc_pc, control_ena;
  wire [7:0] data; wire [12:0] addr;
  wire rd, wr, halt, ram_sel, rom_sel;
  wire [2:0] opcode;
  wire fetch;

 cpu t_cpu(.clk(clock), .reset(reset_req), .halt(halt), 
           .rd(rd), .wr(wr), .addr(addr), .data(data), 
	   .opcode(opcode), .fetch(fetch), .ir_addr(ir_addr), 
	   .pc_addr(pc_addr));// .load_pc(load_pc), .inc_pc(inc_pc), .control_ena(control_ena)); 
 ram t_ram(.data(data), .addr(addr[9:0]), .ena(ram_sel), .rd(rd), .wr(wr));
 rom t_rom(.data(data), .addr(addr), .rd(rd), .ena(rom_sel));
 addr_decoder t_addr_decoder(.addr(addr), .rom_sel(rom_sel), .ram_sel(ram_sel));

 initial
   begin
     clock = 1;
     // display time in nanoseconds
     $timeformat (-9, 1, "ns", 12);
     display_debug_message;
     sys_reset;
     test1;
     $stop;
     test2;
     $stop;
     test3;
     $finish;
   end

   task display_debug_message;
     begin
       $display("\n************************************************");
       $display("*   The following debug task are available       *");
       $display("*   \"test1:\" to load 1st diagnostic program.   *");
       $display("*   \"test2:\" to load 2nd diagnostic program.   *");
       $display("*   \"test3:\" to load Fibonacci program.        *");
       $display("\n************************************************");
     end
  endtask

  task test1;
    begin
      test = 0;
      disable MONITOR;
      $readmemb("./data/test1.pro", t_rom.memory);
      $display("rom loaded successfully!");
      $readmemb("./data/test1.dat", t_ram.ram);
      $display("ram loaded successfully!");
      #1 test = 1;
      #14800 ;
      sys_reset;
    end
  endtask

  task test2;
    begin
      test = 0;
      disable MONITOR;
      $readmemb("./data/test2.pro", t_rom.memory);
      $display("rom loaded successfully!");
      $readmemb("./data/test2.dat", t_ram.ram);
      $display("ram loaded successfully!");
      #1 test = 2;
      #11600 ;
      sys_reset;
    end
  endtask

  task test3;
    begin
      test = 0;
      disable MONITOR;
      $readmemb("./data/test3.pro", t_rom.memory);
      $display("rom loaded successfully!");
      $readmemb("./data/test3.dat", t_ram.ram);
      $display("ram loaded successfully!");
      #1 test = 3;
      #94000 ;
      sys_reset;
    end
  endtask

  task sys_reset;
    begin
      reset_req = 0;
      #(`PERIOD*0.7) reset_req = 1;
      #(`PERIOD*1.5) reset_req = 0;
    end
  endtask

  always @(test)
    begin: MONITOR
      case (test)
        1:
	  begin
	    $display("\n*** Running CPUtest1 - The basic CPU Diagnostic program **");
	    $display("\n    TIME     PC    INSTR    ADDR     DATA  ");
	    $display("     -------  -----  ------  ------   ------ ");
	    while (test == 1)
	      @(t_cpu.pc_addr)
	      if((t_cpu.pc_addr%2 == 1) && (t_cpu.fetch == 1))
	        begin
		  #60 PC_addr <= t_cpu.pc_addr -1;
		      IR_addr <= t_cpu.ir_addr;
		  #340 $strobe("%t     %h    %s   %h   %h", $time, PC_addr, mnemonic, IR_addr, data);
		end
	  end

	2:
	  begin
	    $display("\n*** Running CPUtest2 - The advanced CPU Diagnostic program **");
	    $display("\n    TIME     PC    INSTR    ADDR     DATA  ");
	    $display("     -------  -----  ------  ------   ------ ");
	    while (test == 2)
	      @(t_cpu.pc_addr)
	      if((t_cpu.pc_addr%2 == 1) && (t_cpu.fetch == 1))
	        begin
		  #60 PC_addr <= t_cpu.pc_addr -1;
		      IR_addr <= t_cpu.ir_addr;
		  #340 $strobe("%t     %h    %s   %h   %h", $time, PC_addr, mnemonic, IR_addr, data);
		end
	  end

	3:
	  begin
	    $display("\n*** Running CPUtest3 - An Executable program **");
	    $display("* * * This program should calculate the fibonacci * * *");
	    $display("\n   TIME        FIBONACCI NUMBER");
	    $display("  ----------    -----------------");
	    while (test == 3)
	      /*
	      @(t_cpu.pc_addr)
	      if((t_cpu.pc_addr%2 == 1) && (t_cpu.fetch == 1))
	        begin
		  #60 PC_addr <= t_cpu.pc_addr -1;
		      IR_addr <= t_cpu.ir_addr;
		  #340 $strobe("%t     %h    %s   %h   %h", $time, PC_addr, mnemonic, IR_addr, data);
		end
              */
	      begin
		wait (t_cpu.opcode == 3'h1);
		$strobe("%t       %d", $time, t_ram.ram[10'h2]);
		wait(t_cpu.opcode != 3'h1);
	      end
	  end
      endcase
    end

  always @(posedge halt)
    begin
      #500 
        $display("\n******************************************");
	$display(" ** A HALT instruction was processed !!   **");
        $display("\n******************************************");
    end

  always #(`PERIOD/2) clock = ~clock;
  always @(t_cpu.opcode)
    case (t_cpu.opcode)
      3'b000: mnemonic = "HLT";
      3'b001: mnemonic = "SKZ";
      3'b010: mnemonic = "ADD";
      3'b011: mnemonic = "AND";
      3'b100: mnemonic = "XOR";
      3'b101: mnemonic = "LDA";
      3'b110: mnemonic = "STO";
      3'b111: mnemonic = "JMP";
      default: mnemonic = "???";
    endcase

endmodule
