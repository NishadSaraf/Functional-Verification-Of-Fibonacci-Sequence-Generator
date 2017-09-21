`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Engineer: Nishad Saraf (nishadsaraf@gmail.com)
// University: Portland State University
// Create Date: 04/06/2017 11:17:32 PM
// Module Name: RippleCarryAdder
// Project Name: 64-bit Fibonacci Sequence Generator
// Description: 
// This module create multiple instances of full adder to generate a n-bit addder(n is equal to width).
// The carry bit from one full adder is given as an input to the next full adder in the array of full adders.
// 
// Revision:
// Revision 0.01 - File Created
// 
//////////////////////////////////////////////////////////////////////////////////


module RippleCarryAdder
#(
    // parameter
    WIDTH = 64
)
(
    // ports
    input           [WIDTH-1:0] Num1,
                                Num2,
    input                       Cin,
    output logic    [WIDTH-1:0] Sum,
    output logic                Cout   
);
    // loacl variable
    logic [WIDTH-1:1] carry_connect; 
    
    // creates an array of instances  
    FullAdder FA    [WIDTH-1:0](    Num1,
                                    Num2,
                                    {carry_connect,Cin},
                                    Sum,
                                    {Cout,carry_connect});
  
endmodule