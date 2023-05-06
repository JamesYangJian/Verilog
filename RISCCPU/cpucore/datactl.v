`timescale 1ns/1ns

module datactl(data, in, data_ena);
  input [7:0] in;
  output [7:0] data;
  input data_ena;

  assign data = (data_ena)?in : 8'bzzzz_zzzz;
endmodule
