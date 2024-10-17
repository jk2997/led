`ifndef REGISTER_30B_RTL_V
`define REGISTER_30B_RTL_V
`timescale 1ns/1ps // unrelated to actual clock speed of Pynq-Z2, but is specified so that
// we can specify a #0.5 delay
module Register_30b_RTL 
(
  (* keep=1 *) input  logic       clk,
  (* keep=1 *) input  logic [29:0] d,
  (* keep=1 *) output logic [29:0] q
);
    always_ff @(posedge clk) begin
      q <= d;
    end
endmodule
`endif /* REGISTER_30B_RTL_V */
