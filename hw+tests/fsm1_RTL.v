`ifndef FSM1_RTL_V
`define FSM1_RTL_V
`include "Register_4b_RTL.v"
`include "ClockDivider_RTL.v"
`timescale 1ns/1ps // unrelated to actual clock speed of Pynq-Z2, but is specified so that
// we can specify a #0.5 delay
module fsm1_RTL
(
    input logic clk,
    input logic [1:0] sw, 
    input logic [3:0] btn,
    output logic [3:0] led
);
    localparam STATE_S0 = 4'b0000;
    localparam STATE_S1 = 4'b1000;
    localparam STATE_S2 = 4'b1100;
    localparam STATE_S3 = 4'b1110;
    localparam STATE_S4 = 4'b1111;
    localparam STATE_S5 = 4'b0111;
    localparam STATE_S6 = 4'b0011;
    localparam STATE_S7 = 4'b0001;

    logic clk_out;
    ClockDivider_RTL clockdivider 
    (
        .clk_in (clk),
        .btn (btn),
        .clk_out (clk_out)
    );

    logic [3:0] state;
    logic [3:0] state_next;
    Register_4b_RTL state_reg
    (
        .clk (clk_out),
        .en (~sw[1]),
        .q (state),
        .d (state_next)
    );

    always_comb begin
        case (state)
            STATE_S0 : state_next = STATE_S1;
            STATE_S1 : state_next = STATE_S2;
            STATE_S2 : state_next = STATE_S3;
            STATE_S3 : state_next = STATE_S4;
            STATE_S4 : state_next = STATE_S5;
            STATE_S5 : state_next = STATE_S6;
            STATE_S6 : state_next = STATE_S7;
            STATE_S7 : state_next = STATE_S0;
            default : state_next = STATE_S0;
        endcase
    end
    logic sw0;
    assign sw0 = sw[0];
    always_comb begin
        if (sw0 == 1'b1) led = state;
        else led = STATE_S0;
    end

endmodule
`endif /* FSM1_RTL_V */
