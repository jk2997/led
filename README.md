# Blinking LED Sequence on Pynq-Z2
by Joonho Kim

This project started on October 11th and finished on October 17th. It is my first independent project in which I implemented a circuit entirely written in SystemVerilog RTL and created test benches on my own. I used Verilator (`verilator --Wall --lint-only file.v`) to check for code syntax and Icarus Verilog (`iverilog -Wall -g2012 -o test testfile.v file_being_tested.v`) to compile and execute Verilog test benches. The design has not yet been implemented in hardware, but I am planning to use thedatabus.in's Chiprentals platform (https://thedatabus.in/chiprentals) to see it perform on a Pynq-Z2 FPGA development board. 
This project was mainly created to demonstrate my interest in digital circuit design to the Cornell Custom Silicon Systems (C2S2) project team (https://c2s2.engineering.cornell.edu/index.html) and hopefully increase my chances of being admitted into the Digital Subteam. However, even if I am rejected, it would still be meaningful in that it gave me valuable hands-on experience in designing hardware through SystemVerilog.
## Project Overview
![Screenshot 2024-10-17 163629](https://github.com/user-attachments/assets/da159429-dd7b-4f82-b6a5-080687f3a5d1)

Image Source: https://www.open-electronics.org/pynq-z2-open-source-python-fpga-board/

The Pynq-Z2 board has two switches, four buttons, and four LEDs. The light sequence that I planned to create using the LEDs was as follows:
![image](https://github.com/user-attachments/assets/b8d99cd5-ce59-41c0-9344-019660886d2d)

For user controls:
- Switches: Switch 1 would control sequence progression: logic 1 would mean that the sequence automatically progresses from STATE_S0 to STATE_S7 and repeats, while a 0 would pause the sequence at a certain step. Switch 0 would control on/off.
- Buttons: Speed controls. There would be 9 speeds available: 4 sec/step, 2 sec/step, 1 sec/step, 0.5 sec/step, 0.25 sec/step, 0.125 sec/step, 0.0625 sec/step, 0.03125 sec/step, and 0.015625 sec/step. Button 3 (the leftmost button) would move the speed left by 2 (e.g., 1 to 4, 0.5 to 2), button 2 left by 1 (e.g., 1 to 2), button 1 right by 1 (e.g., 1 to 0.5), and button 0 right by 2 (e.g., 1 to 0.25). The button controls would also loop back (e.g., pressing button 3 at 4 sec/step would make the speed 0.3125 sec/step).

The circuit was implemented in four modules: Register_4b_RTL.v (4-bit register with enable), Register_30b_RTL.v (30-bit register), ClockDivider_RTL.v, and fsm1_RTL.v. The clock divider had nine states, which were 30-bit binary numbers that specified the number of Pynq-Z2 clock cycles per step for each speed. As Pynq-Z2 had a 125MHz clock, 0.25 sec/step corresponded to 500M cycles/step, 0.5 sec/step to 250M cycles, and so on in binary. The 30-bit register had the OR of all four buttons as its clock, updating the state every time a button was pushed, while the combinational circuit used if-else statements to determine the state in the next rising edge depending on the button pressed. If the current state was unresolved (x), `default : state_next = STATE_S#;` was used to determine the next state. Lastly, a counter incremented upward at each rising edge if it was less than the current state and produced a rising edge in the output clock whenever it reached the state.

The fsm1_RTL.v file defined the 8 steps in the LED sequence as states and used combinational logic to specify the state of the next rising edge as the next step in the LED sequence. The 4-bit register updated the state at each rising edge of the ClockDivider_RTL output clock. The enable of the 4-bit register was set to ~sw[1] so that the state would stop updating if Switch 1 was turned on. The last always_comb block would define the led output as STATE_S0 if sw[0] = 0, turning off the lights when Switch 0 is off. 

ClockDivider_RTL was tested by defining a `check` task that inserted button inputs into the clock divider at specific times and monitored the output clock signal. A `mid` variable sorted inputs into 3 categories: mid = 00 for when a button is pressed right after the previous clock cycle, mid=10 for when the button is pressed in the middle of an output clock cycle, and mid=11 for when the button is pressed midway and the counter already exceeds the new clock cycle specified by the button. After basic arithmetic was used to predict the output clock periods for each `check`, the execution of the test bench revealed that the predictions matched up with the actual clock cycles: 

Predicted Clocks (Note: the clock dividers' states were modified to represent smaller clock periods, as they were taking too long to be simulated. However, the proportions of the 30-bit state numbers were kept the same.):
![test_clockdivider_rtl testing modification](https://github.com/user-attachments/assets/33194c0b-9498-4962-a6a3-ebbca6bf95ac)

(modified ClockDivider_RTL states:)
![clockdivider_rtl testing modification](https://github.com/user-attachments/assets/b7f0fb09-0b4d-47e5-b934-5de81c8620c1)

Console: 
```
ECE2300: ~/led/hw+tests % ./Test_ClockDivider_RTL
VCD info: dumpfile Test_ClockDivider_RTL.vcd opened for output.
VCD warning: $dumpvars: Package ($unit) is not dumpable with VCD.
time=  1, 1000 => 1
time=  1, 0000 => 1
time=  2, 0000 => 0
time=  3, 1001 => 0
time=  3, 0000 => 0
time= 17, 1010 => 1
time= 17, 0000 => 1
time= 18, 0000 => 0
time= 49, 1011 => 0
time= 49, 0000 => 0
time=273, 1100 => 1
time=273, 0000 => 1
time=274, 1101 => 0
time=274, 0000 => 0
time=281, 1110 => 1
time=281, 0000 => 1
time=282, 0000 => 0
time=297, 1111 => 0
time=297, 0000 => 0
time=409, 1000 => 1
time=409, 0000 => 1
time=410, 0000 => 0
time=665, 1001 => 0
time=665, 0000 => 0
time=666, 0000 => 1
time=667, 0000 => 0
time=670, 0100 => 1
time=670, 0000 => 1
time=671, 0000 => 0
time=674, 0101 => 0
time=674, 0000 => 0
time=686, 0110 => 1
time=686, 0000 => 1
time=687, 0000 => 0
time=702, 0111 => 0
time=702, 0000 => 0
time=750, 0100 => 1
time=750, 0000 => 1
time=751, 0000 => 0
time=814, 0101 => 0
time=814, 0000 => 0
time=1006, 0110 => 1
time=1006, 0000 => 1
time=1007, 0000 => 0
time=1262, 0111 => 0
time=1262, 0000 => 0
time=1263, 0000 => 1
time=1264, 0000 => 0
time=1265, 0100 => 1
time=1265, 0000 => 1
time=1266, 0000 => 0
time=1267, 0101 => 0
time=1267, 0000 => 0
time=1273, 0011 => 1
time=1273, 0000 => 1
time=1274, 0000 => 0
time=1275, 0010 => 0
time=1275, 0000 => 0
time=1276, 0000 => 1
time=1277, 0000 => 0
time=1278, 0011 => 1
time=1278, 0000 => 1
time=1279, 0000 => 0
time=1534, 0010 => 0
time=1534, 0000 => 0
time=1535, 0000 => 1
time=1536, 0000 => 0
time=1791, 0011 => 1
time=1791, 0000 => 1
time=1792, 0000 => 0
time=1855, 0010 => 0
time=1855, 0000 => 0
time=1856, 0000 => 1
time=1857, 0000 => 0
time=1920, 0011 => 1
time=1920, 0000 => 1
time=1921, 0000 => 0
time=1936, 0010 => 0
time=1936, 0000 => 0
time=1937, 0000 => 1
time=1938, 0000 => 0
time=1953, 0011 => 1
time=1953, 0000 => 1
time=1954, 0000 => 0
time=1957, 0010 => 0
time=1957, 0000 => 0
time=1958, 0000 => 1
time=1959, 0000 => 0
time=1962, 0001 => 1
time=1962, 0000 => 1
time=1963, 0000 => 0
time=2218, 0001 => 0
time=2218, 0000 => 0
time=2219, 0000 => 1
time=2220, 0000 => 0
time=2347, 0001 => 1
time=2347, 0000 => 1
time=2348, 0000 => 0
time=2363, 0001 => 0
time=2363, 0000 => 0
time=2364, 0000 => 1
time=2365, 0000 => 0
time=2372, 0001 => 1
time=2372, 0000 => 1
time=2373, 0001 => 0
time=2373, 0000 => 0
time=2628, 0001 => 1
time=2628, 0000 => 1
time=2629, 0000 => 0
time=2660, 0001 => 0
time=2660, 0000 => 0
time=2661, 0000 => 1
time=2662, 0000 => 0
time=2677, 0001 => 1
time=2677, 0000 => 1
time=2678, 0000 => 0
time=2679, 0001 => 0
time=2679, 0000 => 0
time=3189, 0011 => 1
time=3189, 0000 => 1
time=3190, 0000 => 0
time=3445, 0010 => 1
time=3445, 0000 => 1
time=3446, 0000 => 0
time=3573, 0011 => 1
time=3573, 0000 => 1
time=3574, 0000 => 0
time=3637, 0010 => 1
time=3637, 0000 => 1
time=3638, 0000 => 0
time=3669, 0011 => 1
time=3669, 0000 => 1
time=3670, 0000 => 0
time=3685, 0010 => 1
time=3685, 0000 => 1
time=3686, 0000 => 0
time=3693, 0000 => 1
time=3694, 0000 => 0
Test_ClockDivider_RTL.v:20: $finish called at 3694000 (1ps)
```

fsm_1_RTL was tested using the same modified ClockDivider_RTL states. The checks inserted button and switch inputs into fsm1_RTL and monitored whether the LED output in the next rising edge matched expected values; however, for the case of turning off Switch 0, the checks checked the LED outputs immediately after to see if the LEDs turned off with Switch 0 instead of at the next rising edge. The checks simulated the process of a user turning the lights on, pressing buttons to modify the speed, pausing the sequence progression, and turning off the lights. Running the tests showed the following: 
```
ECE2300: ~/led/hw+tests % ./Test_fsm1_RTL
VCD info: dumpfile Test_fsm1_RTL.vcd opened for output.
VCD warning: $dumpvars: Package ($unit) is not dumpable with VCD.
time=                   1, 0000, 00 => 0000 

Success
time=                   2, 0000, 01 => 0000 

Success
time=                   3, 1000, 01 => 0000 

Success
time=                   4, 0000, 01 => 0000 

Success
time=                   5, 0000, 01 => 0000 

Success
time=                   6, 0000, 01 => 0000 

time=                   7, 0000, 01 => 1000 

Success
time=                   7, 0000, 01 => 1000 

Success
time=                   8, 0000, 01 => 1000 

Success
time=                   9, 0000, 01 => 1000 

Success
time=                  10, 0000, 01 => 1000 

time=                  11, 0000, 01 => 1100 

Success
time=                  11, 0100, 01 => 1100 

Success
time=                  12, 0000, 01 => 1100 

Success
time=                  13, 0000, 01 => 1100 

Success
time=                  14, 0000, 01 => 1100 

Success
time=                  15, 0000, 01 => 1100 

Success
time=                  16, 0000, 01 => 1100 

Success
time=                  17, 0000, 01 => 1100 

Success
time=                  18, 0000, 01 => 1100

time=                  19, 0000, 01 => 1110 

Success
time=                  19, 0001, 01 => 1110 

Success
time=                  20, 0000, 01 => 1110 

time=                  21, 0000, 01 => 1111 

Success
time=                  21, 0100, 01 => 1111 

Success
time=                  22, 0000, 01 => 1111 

Success
time=                  23, 0000, 01 => 1111 

Success
time=                  24, 0000, 01 => 1111 

time=                  25, 0000, 01 => 0111 

Success
time=                  25, 0010, 01 => 0111 

Success
time=                  26, 0000, 01 => 0111 

time=                  27, 0000, 01 => 0011 

Success
time=                  27, 0000, 01 => 0011 

Success
time=                  28, 0000, 01 => 0011 

time=                  29, 0000, 01 => 0001 

Success
time=                  29, 0000, 01 => 0001 

Success
time=                  30, 0000, 01 => 0001 

time=                  31, 0000, 01 => 0000 

Success
time=                  31, 0000, 01 => 0000 

Success
time=                  32, 0000, 01 => 0000 

time=                  33, 0000, 01 => 1000 

Success
time=                  33, 1000, 11 => 1000 

Success
time=                  40, 0000, 11 => 1000 

Success
time=                  41, 0010, 11 => 1000 

Success
time=                  44, 0000, 11 => 1000 

Success
time=                  45, 0010, 10 => 0000 

Success
time=                 557, 0000, 10 => 0000 

Success
```
## Hardware Implementation
Not implemented yet.
## Comments
Among all the modules, I found coding the clock divider and the test benches to be difficult, as I had not encountered these types of problems in my ECE 2300 class. Debugging unexpected Verilator errors and discrepancies between predicted and actual clock cycles was also challenging, as I had yet to develop a comprehensive knowledge of SystemVerilog syntax, and the clock divider consisted of many interacting components. Furthermore, as I had to complete my project within a week, I think that my haste led me to implement inefficient designs and testing methods. Further research on clock timing manipulation and greater reliance on organized brainstorming methods such as state-machine diagrams would likely determine the success of my next project.
