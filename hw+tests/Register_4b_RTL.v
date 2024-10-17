`ifndef REGISTER_4B_RTL_V
`define REGISTER_4B_RTL_V
`timescale 1ns/1ps // unrelated to actual clock speed of Pynq-Z2, but is specified so that
// we can specify a #0.5 delay
module Register_4b_RTL 
(
  (* keep=1 *) input  logic       clk,
  (* keep=1 *) input  logic       en,
  (* keep=1 *) input  logic [3:0] d,
  (* keep=1 *) output logic [3:0] q
);
    always_ff @(posedge clk) begin
        if (en)
            q <= d;
    end
endmodule
`endif /* REGISTER_4B_RTL_V */
