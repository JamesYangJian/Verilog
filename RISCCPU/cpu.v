`include "./cpucore/clk_gen.v"
`include "./cpucore/ir.v"
`include "./cpucore/accum.v"
`include "./cpucore/datactl.v"
`include "./cpucore/adr.v"
`include "./cpucore/counter.v"
`include "./cpucore/state.v"
`include "./cpucore/alu.v"

`timescale 1ns/1ns

module cpu(clk, reset, halt, rd, wr, addr, data, opcode, fetch, ir_addr, pc_addr);//,load_pc,inc_pc, control_ena);
  input clk, reset;
  output rd, wr, halt;//, load_pc,inc_pc,control_ena;
  output [12:0] addr;
  output [2:0] opcode;
  output fetch;
  output [12:0] ir_addr, pc_addr;
  inout [7:0] data;
  wire clk, reset, halt; 
  wire [7:0] data;
  wire [12:0] addr;
  wire rd, wr;
  wire clk, fetch, alu_ena;
  wire [2:0] opcode;
  wire [12:0] ir_addr, pc_addr;
  wire [7:0] alu_out, accum;
  wire zero, inc_pc, load_acc, load_pc, load_ir, data_ena, control_ena;

  clk_gen m_clk_gen(.clk(clk), .reset(reset), .fetch(fetch), .alu_ena(alu_ena));
  register m_register(.opc_iraddr({opcode, ir_addr}), .data(data), 
                      .ena(load_ir), .clk(clk), .rst(reset));
  accum m_accum(.accum(accum), .data(alu_out), .ena(load_acc), .clk(clk), .rst(reset));
  alu m_alu(.clk(clk), .alu_out(alu_out), .zero(zero), .data(data), 
            .accum(accum), .alu_ena(alu_ena), .opcode(opcode));
  statectl m_statectl(.ena(control_ena), .fetch(fetch), .rst(reset), .clk(clk));
  state m_state(.inc_pc(inc_pc), .load_acc(load_acc), .load_pc(load_pc), 
                .rd(rd), .wr(wr), .load_ir(load_ir),
                .datactl_ena(data_ena), .halt(halt), .clk(clk), 
		.zero(zero), .ena(control_ena), .opcode(opcode));
  datactl m_datactl(.data(data), .in(alu_out), .data_ena(data_ena));
  adr m_adr(.addr(addr), .fetch(fetch), .ir_addr(ir_addr), .pc_addr(pc_addr));
  counter m_counter(.pc_addr(pc_addr), .ir_addr(ir_addr), .load(load_pc), .clk(inc_pc), .rst(reset));

endmodule
