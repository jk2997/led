`include "Register_4b_RTL.v"
`timescale 1ns/1ps
module Test_Register_4b_RTL();
    logic clk;
    logic dut_en;
    logic [3:0] dut_d, dut_q; 
    Register_4b_RTL dut
    (
        .clk (clk),
        .en (dut_en),
        .d (dut_d),
        .q (dut_q)
    );
    initial begin
        #0.5
        clk = 1'b1;
        forever #0.5 clk = ~clk;
    end
    task check(logic en, logic [3:0] d, logic [3:0] q_expected);
        $monitor("time=%3d, %b %b => %b \n", $time, dut_en, dut_d, dut_q);
        dut_en = en;
        dut_d = d;
        #1
        if (dut_q == q_expected) $display("Success");
        else $display("Test Failed");
    endtask
    initial begin
        //     en    d       q_expected
        #0.5
        check(1'b1, 4'b0000, 4'b0000);
        check(1'b1, 4'b0001, 4'b0001);
        check(1'b1, 4'b0010, 4'b0010);
        check(1'b1, 4'b0011, 4'b0011);

        check(1'b0, 4'b1100, 4'b0011);
        check(1'b0, 4'b1101, 4'b0011);
        check(1'b0, 4'b1110, 4'b0011);
        check(1'b0, 4'b1111, 4'b0011);

        check(1'b1, 4'b0100, 4'b0100);
        check(1'b1, 4'b0101, 4'b0101);
        check(1'b1, 4'b0110, 4'b0110);
        check(1'b1, 4'b0111, 4'b0111);

        check(1'b0, 4'b0000, 4'b0111);
        check(1'b0, 4'b0001, 4'b0111);
        check(1'b0, 4'b0010, 4'b0111);
        check(1'b0, 4'b0011, 4'b0111);

        check(1'b1, 4'b1000, 4'b1000);
        check(1'b1, 4'b1001, 4'b1001);
        check(1'b1, 4'b1010, 4'b1010);
        check(1'b1, 4'b1011, 4'b1011);

        check(1'b0, 4'b0100, 4'b1011);
        check(1'b0, 4'b0101, 4'b1011);
        check(1'b0, 4'b0110, 4'b1011);
        check(1'b0, 4'b0111, 4'b1011);

        check(1'b1, 4'b1100, 4'b1100);
        check(1'b1, 4'b1101, 4'b1101);
        check(1'b1, 4'b1110, 4'b1110);
        check(1'b1, 4'b1111, 4'b1111);

        check(1'b0, 4'b1000, 4'b1111);
        check(1'b0, 4'b1001, 4'b1111);
        check(1'b0, 4'b1010, 4'b1111);
        check(1'b0, 4'b1011, 4'b1111);
    end
endmodule : Test_Register_4b_RTL
