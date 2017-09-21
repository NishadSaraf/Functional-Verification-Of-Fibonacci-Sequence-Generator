`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Engineer: Nishad Saraf (nishadsaraf@gmail.com)
// University: Portland State University.
// Create Date: 04/08/2017 03:25:50 PM
// Module Name: ClockGenerator
// Project Name: 64-bit Fibonacci Sequence Generator
// Description: 
// Clock generator by default runs at 100MHz. Parameter CLOCK_PERIOD takes in the clock pulse duration in nanoseconds.
// 
// Revision:
// Revision 0.01 - File Created
// 
//////////////////////////////////////////////////////////////////////////////////


module ClockGenerator #(CLOCK_PERIOD = 10)(output logic clock);
    
    initial
    begin
        clock = 1'b1;
        forever #(CLOCK_PERIOD/2) clock = ~clock;
    end
   
endmodule