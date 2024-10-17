`include "Register_30b_RTL.v"
`timescale 1ns/1ps
module Test_Register_30b_RTL();
    logic clk;
    logic [29:0] dut_d, dut_q; 
    Register_30b_RTL dut
    (
        .clk (clk),
        .d (dut_d),
        .q (dut_q)
    );
    initial begin
        #0.5
        clk = 1'b1;
        forever #0.5 clk = ~clk;
    end
    task check(logic [29:0] d, logic [29:0] q_expected);
        $monitor("time=%3d, %b => %b \n", $time, dut_d, dut_q);
        dut_d = d;
        #1
        if (dut_q == q_expected) $display("Success");
        else $display("Test Failed");
    endtask
    logic [29:0] random_d;
    initial begin
        #0.5
        // Generate 50 random input value pairs, with the former having en=1
        // and the latter having en=0
        for (int i=0; i<50; i=i+1) begin
            random_d = 30'($urandom());
            check(random_d, random_d);
        end
    end
endmodule : Test_Register_30b_RTL
