`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Engineer: Nishad Saraf (nishadsaraf@gmail.com)
// University: Portland State University
// Create Date: 04/06/2017 10:55:43 PM
// Module Name: FullAdder
// Project Name: 64-bit Fibonacci Sequence Generator
// Description: 
// Full Adder.
// 
// Revision:
// Revision 0.01 - File Created
// 
//////////////////////////////////////////////////////////////////////////////////


module FullAdder
(
    // ports
    input A,
    input B,
    input Cin,
    output Sum,
    output Carry
);

// local variables
logic s1, c1, c2;

// module instantiation
HalfAdder HA1 ( .A(A),
                .B(B),
                .Sum(s1),
                .Carry(c1));
    
HalfAdder HA2 ( .A(Cin),
                .B(s1),
                .Sum(Sum),
                .Carry(c2));    

or (Carry, c1, c2);

endmodule
