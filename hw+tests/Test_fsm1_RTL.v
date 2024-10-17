`include "fsm1_RTL.v"
`timescale 1ns/1ps // unrelated to actual clock speed of Pynq-Z2, but is specified so that
// we can specify a #0.5 delay
module Test_fsm1_RTL();
    logic dut_clk;
    logic [3:0] dut_btn, dut_led;
    logic [1:0] dut_sw;
    fsm1_RTL dut
    (
        .clk (dut_clk),
        .btn (dut_btn),
        .sw (dut_sw),
        .led (dut_led)
    );
    initial begin
        #0.5
        dut_clk = 1'b1;
        forever #0.5 dut_clk = ~dut_clk;
    end
    task check(logic [3:0] btn, logic [1:0] sw, logic [3:0] led_expected);
        $monitor("time=%d, %b, %b => %b \n", $time, dut_btn, dut_sw, dut_led);
        dut_btn = btn;
        dut_sw = sw;
        if (sw != 2'b10) #1.001; // the task needs to read the next rising edge,
        // so it is #1.001 delay and not exactly #1 delay
        else #0.001;
        //check output LED at the next rising edge
        if (dut_led == led_expected) $display("Success");
        else $display("Test Failed");
    endtask
    initial begin
        $dumpfile("Test_fsm1_RTL.vcd"); $dumpvars;
        //       btn      sw   led_expected
        #0.5
        //testing for startup
        check(4'b0000, 2'b00, 4'b0000); 
        check(4'b0000, 2'b01, 4'b0000);
        //testing for button presses
        check(4'b1000, 2'b01, 4'b0000); // btn[3] pressed
        check(4'b0000, 2'b01, 4'b0000);
        check(4'b0000, 2'b01, 4'b0000);
        check(4'b0000, 2'b01, 4'b1000); // clock period 4 (4x speed decrease)
        check(4'b0000, 2'b01, 4'b1000);
        check(4'b0000, 2'b01, 4'b1000);
        check(4'b0000, 2'b01, 4'b1000);
        check(4'b0000, 2'b01, 4'b1100);
        check(4'b0100, 2'b01, 4'b1100); // btn[2] pressed
        check(4'b0000, 2'b01, 4'b1100);
        check(4'b0000, 2'b01, 4'b1100);
        check(4'b0000, 2'b01, 4'b1100);
        check(4'b0000, 2'b01, 4'b1100);
        check(4'b0000, 2'b01, 4'b1100);
        check(4'b0000, 2'b01, 4'b1100);
        check(4'b0000, 2'b01, 4'b1110); // clock period 8 (2x speed decrease)
        check(4'b0001, 2'b01, 4'b1110); // btn[0] pressed
        check(4'b0000, 2'b01, 4'b1111); // clock period 2 (4x speed increase)
        check(4'b0100, 2'b01, 4'b1111); // btn[2] pressed
        check(4'b0000, 2'b01, 4'b1111);
        check(4'b0000, 2'b01, 4'b1111);
        check(4'b0000, 2'b01, 4'b0111);
        check(4'b0010, 2'b01, 4'b0111); // btn[1] pressed
        check(4'b0000, 2'b01, 4'b0011); // clock period 2 (2x speed increase)
        check(4'b0000, 2'b01, 4'b0011);
        check(4'b0000, 2'b01, 4'b0001);
        check(4'b0000, 2'b01, 4'b0001);
        check(4'b0000, 2'b01, 4'b0000);
        check(4'b0000, 2'b01, 4'b0000);
        check(4'b0000, 2'b01, 4'b1000);
        //testing for enable (sw[1])
        check(4'b1000, 2'b11, 4'b1000);
        #6 check(4'b0000, 2'b11, 4'b1000); // output will have a constant state when
        // sw[1] = 1 and the enable is off
        check(4'b0010, 2'b11, 4'b1000);
        #2 check(4'b0000, 2'b11, 4'b1000); // no change in output
        //if sw[0] is turned off, all LEDs will turn off immediately
        check(4'b0010, 2'b10, 4'b0000);
        #512 check(4'b0000, 2'b10, 4'b0000); // no change in output
        
    end
endmodule
