`timescale 1ns/1ns

module ram(data, addr, ena, rd, wr);
  inout [7:0] data;
  input [9:0] addr;
  input ena;
  input rd, wr;
  reg [7:0] ram [10'h3ff:0];

  assign data = (rd && ena)? ram[addr]: 8'hzz;

  always @(posedge wr)
    begin
      ram[addr] <= data;
    end

endmodule

module rom(data, addr, rd, ena);
  output [7:0] data;
  input [12:0] addr;
  input rd, ena;
  reg [7:0] memory [13'h1fff:0];
  wire [7:0] data;

  assign data = (rd && ena)? memory[addr]:8'hzz;

endmodule