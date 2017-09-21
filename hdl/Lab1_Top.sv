`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Engineer: Nishad Saraf (nishadsaraf@gmail.com)
// University: Portland State University
// Create Date: 04/08/2017 02:48:13 PM
// Design Name: Top level module
// Module Name: TestBench
// Project Name: 64-bit Fibonacci Sequence Generator
// Description:
// This is a top level module for 64 bit fibonacci sequence generator written in SystemVerilog.
// Here three modules are being instantiated. One is a clock generator modules which provides clock
// pulses to the other two modules. fib_num_test is a test module while fsm_num_gen is the actual DUT.
//
// Revision:
// Revision 0.01 - File Created
// 
//////////////////////////////////////////////////////////////////////////////////
`define DATA_WIDTH      64
`define ORDER_WIDTH     16
`define CLOCK_PERIOD    10      // in nanoseconds

module TestBench;
// local variables
logic CLOCK,RESET,LOAD,CLEAR,DONE,ERROR,OVERFLOW;
logic [`DATA_WIDTH-1:0]     StartValue,Result;
logic [`ORDER_WIDTH-1:0]    Position;

// Clock module instantiation. Default parameter passed is the value of CLOCK_PERIOD in nanoseconds
ClockGenerator #(`CLOCK_PERIOD)CGen(.clock(CLOCK));

// test module
fib_num_test FNT(   .clk(CLOCK),
                    .reset_n(RESET),
                    .load(LOAD),
                    .clear(CLEAR),
                    .order(Position),
                    .data_in(StartValue),
                    .done(DONE),
                    .error(ERROR),
                    .overflow(OVERFLOW),
                    .data_out(Result));
// FSM DUT
fsm_num_gen #(`DATA_WIDTH,`ORDER_WIDTH)FNG(     .data_out(Result),
                                                .done(DONE),
                                                .overflow(OVERFLOW),
                                                .error(ERROR),
                                                .order(Position),
                                                .data_in(StartValue),
                                                .clk(CLOCK),
                                                .reset_n(RESET),
                                                .load(LOAD),
                                                .clear(CLEAR));
// Ckecker module
fib_num_chkr #(`DATA_WIDTH,`ORDER_WIDTH)check(  .clk(CLOCK),
                                                .reset_n(RESET),
                                                .load(LOAD),
                                                .done(DONE),
                                                .error(ERROR),
                                                .overflow(OVERFLOW),
                                                .data_in(StartValue),
                                                .data_out(Result),
                                                .order(Position));

endmodule