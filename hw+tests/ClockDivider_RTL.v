`ifndef CLOCKDIVIDER_RTL_V
`define CLOCKDIVIDER_RTL_V
`include "Register_30b_RTL.v"
`timescale 1ns/1ps // unrelated to actual clock speed of Pynq-Z2, but is specified so that
// we can specify a #0.5 delay
module ClockDivider_RTL
(
  input logic clk_in,
  input logic [3:0] btn,
  output logic clk_out
);
    localparam STATE_S0 = 30'b011101110011010110010100000000; //0.25Hz (500M cycles)
    // for testing replace 30-bit above with 30'b000000000000000000001000000000 (512 clk_in cycles)
    localparam STATE_S1 = 30'b001110111001101011001010000000; //0.5Hz
    // for testing replace 30-bit above with 30'b000000000000000000000100000000 (256 clk_in cycles)
    localparam STATE_S2 = 30'b000111011100110101100101000000; //1Hz
    // for testing replace 30-bit above with 30'b000000000000000000000010000000 (128 clk_in cycles)
    localparam STATE_S3 = 30'b000011101110011010110010100000; //2Hz
    // for testing replace 30-bit above with 30'b000000000000000000000001000000 (64 clk_in cycles)
    localparam STATE_S4 = 30'b000001110111001101011001010000; //4Hz
    // for testing replace 30-bit above with 30'b000000000000000000000000100000 (32 clk_in cycles)
    localparam STATE_S5 = 30'b000000111011100110101100101000; //8Hz
    // for testing replace 30-bit above with 30'b000000000000000000000000010000 (16 clk_in cycles)
    localparam STATE_S6 = 30'b000000011101110011010110010100; //16Hz
    // for testing replace 30-bit above with 30'b000000000000000000000000001000 (8 clk_in cycles)
    localparam STATE_S7 = 30'b000000001110111001101011001010; //32Hz
    // for testing replace 30-bit above with 30'b000000000000000000000000000100 (4 clk_in cycles)
    localparam STATE_S8 = 30'b000000000111011100110101100101; //64Hz
    // for testing replace 30-bit above with 30'b000000000000000000000000000010 (2 clk_in cycles)
    logic [29:0] state;
    logic [29:0] state_next;
    logic btn3, btn2, btn1, btn0;
    assign btn3 = btn[3];
    assign btn2 = btn[2];
    assign btn1 = btn[1];
    assign btn0 = btn[0];
    Register_30b_RTL state_reg
    (
        .clk(btn3 | btn2 | btn1 | btn0),
        .q (state),
        .d (state_next)
    );
    always_comb begin
        if (btn3) begin
            case (state)
                STATE_S0 : state_next = STATE_S7;
                STATE_S1 : state_next = STATE_S8;
                STATE_S2 : state_next = STATE_S0;
                STATE_S3 : state_next = STATE_S1;
                STATE_S4 : state_next = STATE_S2;
                STATE_S5 : state_next = STATE_S3;
                STATE_S6 : state_next = STATE_S4;
                STATE_S7 : state_next = STATE_S5;
                STATE_S8 : state_next = STATE_S6;
                default : state_next = STATE_S7;
            endcase
        end else begin
            if (btn2) begin
                case (state)
                    STATE_S0 : state_next = STATE_S8;
                    STATE_S1 : state_next = STATE_S0;
                    STATE_S2 : state_next = STATE_S1;
                    STATE_S3 : state_next = STATE_S2;
                    STATE_S4 : state_next = STATE_S3;
                    STATE_S5 : state_next = STATE_S4;
                    STATE_S6 : state_next = STATE_S5;
                    STATE_S7 : state_next = STATE_S6;
                    STATE_S8 : state_next = STATE_S7;
                    default : state_next = STATE_S8;
                endcase
            end else begin
                if (btn1) begin
                    case (state)
                        STATE_S0 : state_next = STATE_S1;
                        STATE_S1 : state_next = STATE_S2;
                        STATE_S2 : state_next = STATE_S3;
                        STATE_S3 : state_next = STATE_S4;
                        STATE_S4 : state_next = STATE_S5;
                        STATE_S5 : state_next = STATE_S6;
                        STATE_S6 : state_next = STATE_S7;
                        STATE_S7 : state_next = STATE_S8;
                        STATE_S8 : state_next = STATE_S0;
                        default : state_next = STATE_S1;
                    endcase
                end else begin
                    if (btn0) begin
                        case (state)
                            STATE_S0 : state_next = STATE_S2;
                            STATE_S1 : state_next = STATE_S3;
                            STATE_S2 : state_next = STATE_S4;
                            STATE_S3 : state_next = STATE_S5;
                            STATE_S4 : state_next = STATE_S6;
                            STATE_S5 : state_next = STATE_S7;
                            STATE_S6 : state_next = STATE_S8;
                            STATE_S7 : state_next = STATE_S0;
                            STATE_S8 : state_next = STATE_S1;
                            default : state_next = STATE_S2;
                        endcase
                    end else begin
                        casez (state)
                            default: state_next = STATE_S0;
                        endcase
                    end
                end
            end
        end
    end
    logic [29:0] counter;
    always_ff @(posedge clk_in) begin
        if (counter < state) begin
            counter <= counter + 30'b000000000000000000000000000001;
            clk_out <= 1'b0;
        end else begin
            counter <= 30'b000000000000000000000000000001;
            clk_out <= 1'b1;  
        end
    end
endmodule
`endif /* CLOCKDIVIDER_RTL_V */
