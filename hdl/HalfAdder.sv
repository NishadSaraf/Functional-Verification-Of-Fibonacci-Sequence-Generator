`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Engineer: Nishad Saraf (nishadsaraf@gmail.com)
// University: Portland State University
// Create Date: 04/06/2017 10:46:00 PM
// Design Name: Nishad Saraf
// Module Name: HalfAdder
// Project Name: 64-bit Fibonacci Sequence Generator 
// Description: 
// Half adder.
// 
// Revision:
// Revision 0.01 - File Created
//
//////////////////////////////////////////////////////////////////////////////////


module HalfAdder
(
    // ports
    input A,
    input B,
    output Sum,
    output Carry
);
    
 xor (Sum, A, B);
 and (Carry, A, B);
 
endmodule
