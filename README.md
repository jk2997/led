# Blinking LED Sequence on Pynq-Z2 by Joonho Kim
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
