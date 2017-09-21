`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Engineer: Nishad Saraf (nishadsaraf@gmail.com)
// University: Portland State University
// Create Date: 04/07/2017 02:36:10 PM
// Module Name: FiboGenerator
// Project Name: 64-bit Fibonacci Sequence Generator
// Description: 
// This module computes the value of nth word in the fibonacci sequence.
// 
// Revision:
// Revision 0.01 - File Created
// 
//////////////////////////////////////////////////////////////////////////////////

module FiboGenerator
#(
    // parameters
    parameter DATA_WIDTH = 64,
    parameter ORDER_WIDTH = 16
)
(
    // ports
    input                               clk,
                                        load,
    input           [DATA_WIDTH-1:0]    data,
    input           [ORDER_WIDTH-1:0]   order,
    output logic    [DATA_WIDTH-1:0]    result,
    output logic                        carry,
                                        done
);
    // local variables  
    logic [DATA_WIDTH-1:0] currentNum, prevNum, nextNum;
    logic [ORDER_WIDTH-1:0] counter;
    logic tempCarry = 1'b0;
 
    // module instantiation
    RippleCarryAdder #(DATA_WIDTH) RA(  .Num1(prevNum),
                                        .Num2(currentNum),   
                                        .Cin(1'b0),
                                        .Sum(nextNum),
                                        .Cout(tempCarry));
           
    always_ff @(posedge clk)
    begin
        if(load == 1'b1 && data)    // check if data is not equal to zero
        begin
            currentNum  <= data;
            prevNum     <= data;
            counter     <= 'd1;
            result      <= {DATA_WIDTH{1'b0}};
            done        <= 1'b0;
            carry       <= 1'b0;
        end
        else if(counter == order)   // incase when order is equal to 1 
        begin
            done    <= 1'b1;        // output the results
            result  <= data;
            carry   <= 1'b0;
        end
        else if(tempCarry == 1'b1)  // when result overflows
        begin
            done    <= 1'b0;
            carry   <= 1'b1;
            result  <= {DATA_WIDTH{1'b1}};
        end
        else if(counter == (order - 1))   // end computation when required number of iteration are finished 
        begin
            done    <= 1'b1;        // output the results
            result  <= nextNum;
            carry   <= 1'b0;
        end
        else if(counter < order)    // continue iterating 
        begin
            currentNum <= nextNum;
            prevNum    <= currentNum;
            counter    <= counter + 1;
        end
    end
endmodule