`include "ClockDivider_RTL.v"
`timescale 1ns/1ps // unrelated to actual clock speed of Pynq-Z2, but is specified so that
// we can specify a #0.5 delay
module Test_ClockDivider_RTL();
    logic dut_clk_in, dut_clk_out;
    logic [3:0] dut_btn;
    ClockDivider_RTL dut
    (
        .clk_in (dut_clk_in),
        .btn (dut_btn),
        .clk_out (dut_clk_out)
    );
    initial begin
        #0.5
        dut_clk_in = 1'b1;
        forever #0.5 dut_clk_in = ~dut_clk_in;
    end

    initial 
        #3694 $finish;

    task check(logic [1:0] mid, logic [3:0] btn1, logic [3:0] btn2, logic [29:0] clock_btn1, logic [29:0] clock_btn2); 
        // code for 1/2 of button 1 clock cycle
        logic [29:0] half_clock_btn1;
        half_clock_btn1[29] = 1'b0;
        half_clock_btn1[28:0] = clock_btn1[29:1];
        //monitors changes in button input and the output clock
        $monitor("time=%3d, %b => %b", $time, dut_btn, dut_clk_out);
        // mid[1] indicates whether a button has been pressed in the middle of a clock cycle or not
        // mid[0] indicates whether the counter is greater than/equal to or less than the clock specified by
        // the second button input
        if (mid == 2'b00) begin
            dut_btn = btn1; 
            #0.5
            // user will not be holding the button, but momentarily pressing it; we will model this
            // period as 0.5 (half of a clk_in cycle) for simplicity's sake
            dut_btn = 4'b0000; 
            #(clock_btn1 - 0.5)
            // first clock cycle = button 1 cycle
            dut_btn = btn2;
            #0.5
            dut_btn = 4'b0000;
            #(clock_btn2 - 0.5);
            // second clock cycle = button 2 cycle
        end else begin
            dut_btn = btn1;
            #0.5
            dut_btn = 4'b0000;
            #(half_clock_btn1 - 0.5)
            // for simplicity's sake, let us say that the user presses the button
            // when exactly half of the clock cycle has passed
            if (mid == 2'b11) begin
                // when the counter is greater than the new clock cycle, the counter resets to 1
                // in the next clk_in rising edge, producing a clk_out rising edge. Then, it 
                // continues with the new clock cycle.
                dut_btn = btn2;
                #0.5
                dut_btn = 4'b0000;
                #0.5
                // first clock cycle = 1/2 button 1 cycle + 1 clk_in cycle
                #(clock_btn2);
                // second clock cycle = button 2 cycle
            end
            if (mid == 2'b10) begin
                // when the counter is less than the new clock cycle, the counter switches to
                // the new clock cycle and produces a clk_out rising edge once the new clock 
                // cycle is finished.
                dut_btn = btn2;
                #0.5
                dut_btn = 4'b0000;
                #(clock_btn2 - half_clock_btn1 - 0.5);
                // total clock cycle = button 2 cycle
            end
            
        end
    endtask
    initial begin
        $dumpfile("Test_ClockDivider_RTL.vcd"); $dumpvars;
        // testing how pressing a button at the middle of a clock cycle will change the clock
        // If mid=10, dut_clk_out should have the button 2 clock cycle
        // If mid=11, dut_clk_out should have a clock cycle of (button 2 clock cycle)+(1 clk_in cycle)
        #0.5 // clk_out = 1 when t = 1 here, since $time is rounded to the nearest whole number
        // for button 3
        check(2'b10, 4'b1000, 4'b1001, 30'b000000000000000000000000000100, 30'b000000000000000000000000010000); //expected cycle = 16 clk_in (clk_out = 1 when t=17)
        check(2'b10, 4'b1010, 4'b1011, 30'b000000000000000000000001000000, 30'b000000000000000000000100000000); // 256 clk_in (t=273)
        check(2'b10, 4'b1100, 4'b1101, 30'b000000000000000000000000000010, 30'b000000000000000000000000001000); // 8 clk_in (t=281)
        check(2'b10, 4'b1110, 4'b1111, 30'b000000000000000000000000100000, 30'b000000000000000000000010000000); // 128 clk_in (t=409)
        check(2'b11, 4'b1000, 4'b1001, 30'b000000000000000000001000000000, 30'b000000000000000000000000000100); // 257 clk_in + 4 clk_in (t=666, 670)
        // for button 2
        check(2'b10, 4'b0100, 4'b0101, 30'b000000000000000000000000001000, 30'b000000000000000000000000010000); // 16 clk_in (t=686)
        check(2'b10, 4'b0110, 4'b0111, 30'b000000000000000000000000100000, 30'b000000000000000000000001000000); // 64 clk_in (t=750)
        check(2'b10, 4'b0100, 4'b0101, 30'b000000000000000000000010000000, 30'b000000000000000000000100000000); // 256 clk_in (t=1006)
        check(2'b11, 4'b0110, 4'b0111, 30'b000000000000000000001000000000, 30'b000000000000000000000000000010); // 257 clk_in + 2 clk_in (t=1263, 1265)
        check(2'b10, 4'b0100, 4'b0101, 30'b000000000000000000000000000100, 30'b000000000000000000000000001000); // 8 clk_in (t=1273)
        // for button 1
        check(2'b11, 4'b0011, 4'b0010, 30'b000000000000000000000000000100, 30'b000000000000000000000000000010); // 3 clk_in + 2 clk_in (t=1276, 1278)
        check(2'b11, 4'b0011, 4'b0010, 30'b000000000000000000001000000000, 30'b000000000000000000000100000000); // 257 clk_in + 256 clk_in (t=1535, 1791)
        check(2'b11, 4'b0011, 4'b0010, 30'b000000000000000000000010000000, 30'b000000000000000000000001000000); // 65 clk_in + 64 clk_in (t=1856, 1920)
        check(2'b11, 4'b0011, 4'b0010, 30'b000000000000000000000000100000, 30'b000000000000000000000000010000); // 17 clk_in + 16 clk_in (t=1937, 1953)
        check(2'b11, 4'b0011, 4'b0010, 30'b000000000000000000000000001000, 30'b000000000000000000000000000100); // 5 clk_in + 4 clk_in (t=1958, 1962)
        // for button 0
        check(2'b11, 4'b0001, 4'b0001, 30'b000000000000000000001000000000, 30'b000000000000000000000010000000); // 257 clk_in + 128 clk_in (t=2219, 2347)
        check(2'b11, 4'b0001, 4'b0001, 30'b000000000000000000000000100000, 30'b000000000000000000000000001000); // 17 clk_in + 8 clk_in (t=2364, 2372)
        check(2'b10, 4'b0001, 4'b0001, 30'b000000000000000000000000000010, 30'b000000000000000000000100000000); // 256 clk_in (t=2628)
        check(2'b11, 4'b0001, 4'b0001, 30'b000000000000000000000001000000, 30'b000000000000000000000000010000); // 33 clk_in + 16 clk_in (t=2661, 2677)
        check(2'b10, 4'b0001, 4'b0001, 30'b000000000000000000000000000100, 30'b000000000000000000001000000000); // 512 clk_in (t=3189)
        // testing how pressing a button at the end of a clock cycle will change the clock
        // dut_clk_out should have the button 1 clock cycle for the first test and the button 2 clock cycle
        // for the second test
        check(2'b00, 4'b0011, 4'b0010, 30'b000000000000000000000100000000, 30'b000000000000000000000010000000); // 256 clk_in + 128 clk_in (t=3445, 3573)
        check(2'b00, 4'b0011, 4'b0010, 30'b000000000000000000000001000000, 30'b000000000000000000000000100000); // 64 clk_in + 32 clk_in (t=3637, 3669)
        check(2'b00, 4'b0011, 4'b0010, 30'b000000000000000000000000010000, 30'b000000000000000000000000001000); // 16 clk_in + 8 clk_in (t=3685, 3693)
    end
endmodule : Test_ClockDivider_RTL
