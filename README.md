# Blinking LED Sequence on Pynq-Z2 by Joonho Kim
This project started on October 11th and finished on October 17th. It is my first independent project in which I implemented a circuit entirely written in SystemVerilog RTL and created test benches on my own. I used Verilator (`verilator --Wall --lint-only file.v`) to check for code syntax and Icarus Verilog (`iverilog -Wall -g2012 -o test testfile.v file_being_tested.v`) to compile and execute Verilog test benches. The design has not yet been implemented in hardware, but I am planning to use thedatabus.in's Chiprentals platform (https://thedatabus.in/chiprentals) to see it perform on a Pynq-Z2 FPGA development board. 
This project was mainly created to demonstrate my interest in digital circuit design to the Cornell Custom Silicon Systems (C2S2) project team (https://c2s2.engineering.cornell.edu/index.html) and hopefully increase my chances of being admitted into the Digital Subteam. However, even if I am rejected, it would still be meaningful in that it gave me valuable hands-on experience in designing hardware through SystemVerilog.
## Project Overview
![Screenshot 2024-10-17 163629](https://github.com/user-attachments/assets/da159429-dd7b-4f82-b6a5-080687f3a5d1)
Image Source: https://www.open-electronics.org/pynq-z2-open-source-python-fpga-board/

The following 
