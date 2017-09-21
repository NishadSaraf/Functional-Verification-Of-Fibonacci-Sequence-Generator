`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Engineer: Nishad Saraf (nishadsaraf@gmail.com)
// University: Portland State University
// Create Date: 04/07/2017 11:08:11 PM
// Design Name: FSM DUT
// Module Name: fsm_num_gen
// Project Name: 64-bit Fibonacci Sequence Generator
// Description: 
// This module is the main module wherein incomming data is been operated on and corresponding results are reflected on the output ports.
// Once load signal is asserted state change occurs to LOAD state. On successful load operation the machin goes into ADD state if the data is valid 
// else it goes into ERROR state. ADD state in where the main computation takes places. Based on the value of data and order, nth number (equal to order)
// in the fibonacci sequence is computed. If the value of resultant number is greater than 64-bit value machine changes state to OVERFLOW state setting the 
// overflow pin high. When clear signal is asserted machine comes back to IDLE state.
// 
// Revision:
// Revision 0.01 - File Created
// 
//////////////////////////////////////////////////////////////////////////////////


module fsm_num_gen
#(
    // parameters
    parameter DATA_WIDTH   = 64,
    parameter ORDER_WIDTH  = 16
)
(   // ports
    output  logic   [DATA_WIDTH-1:0]   data_out,
    output  logic                      done,
                                       overflow,
                                       error,
    input           [ORDER_WIDTH-1:0]  order,
                    [DATA_WIDTH-1:0]   data_in,
    input                              clk,         // system clock
                                       reset_n,     // active low reset
                                       load,
                                       clear
 );

 // enum defaults
 enum logic [2:0]{RESET, IDLE, LOAD, ERROR, ADD, DONE, OVERFLOW} currentState, nextState;
 
 // local variables
 logic carry, finish;
 logic [DATA_WIDTH-1:0] num, sum;
 logic [ORDER_WIDTH-1:0] position;
 logic readFlag;    // flag to load data into local variables only when a valid data is available on the input ports

 // module instantiaton
 FiboGenerator #(DATA_WIDTH,ORDER_WIDTH)FG( .clk(clk),
                                            .load(readFlag),
                                            .data(num),
                                            .order(position),
                                            .result(sum),
                                            .carry(carry),
                                            .done(finish));
                 
 always_ff @(posedge clk or negedge reset_n)
    if(!reset_n) currentState <= RESET;  // reset to RESET state
    else         currentState <= nextState;
    
 // assign the next states
 always_comb begin
    nextState = currentState;   // default for each branch below
    unique case(currentState)
        RESET:      if(reset_n == 1'b1) nextState = IDLE; else nextState = RESET;
        IDLE:       if(load == 1'b1)    nextState = LOAD; else nextState = IDLE;
        LOAD:
        begin  
                    if(load == 1'b0) nextState = IDLE;      // change to ADD state when load signal is high for atleast 2 clock pulses for succesful load operation
                    else 
                    begin
                        if (data_in == {DATA_WIDTH{1'b0}} || order == {ORDER_WIDTH{1'b0}}) nextState = ERROR;  // check for invalid inputs
                        else                                                               nextState = ADD;
                    end
        end
        ADD:
        begin        
                    if(order == 'd1) nextState = DONE;
                    else if(finish) nextState = DONE;   
                    else if(carry)  nextState = OVERFLOW; 
                    else nextState = ADD;   // wait until either computation is done or value overflows
        end      
        DONE:       nextState = IDLE; // switch to IDLE state after one clock cycle
        ERROR:      if(clear == 1'b1) nextState = IDLE; else nextState = ERROR;
        OVERFLOW:   if(clear == 1'b1) nextState = IDLE; else nextState = OVERFLOW;
    endcase
 end
 
 // set the output port corresponding to each state
 always_comb begin
    {position,num,data_out,done,overflow,error,readFlag} = {{ORDER_WIDTH{1'b0}},{2{{DATA_WIDTH{1'b0}}}},{4{1'b0}}}; // default values
    unique case(currentState)
        RESET:  
        begin
                data_out = {DATA_WIDTH{1'b0}}; 
                done     = 1'b0; 
                overflow = {ORDER_WIDTH{1'b0}};
                error    = 1'b0;
                readFlag = 1'b0;
                num      = {DATA_WIDTH{1'b0}};
                position = {ORDER_WIDTH{1'b0}}; 
        end
        IDLE: 
        begin
                data_out = {DATA_WIDTH{1'b0}};
                done     = 1'b0;
                overflow = 1'b0;
                error    = 1'b0;
                readFlag = 1'b0;
                num      = {DATA_WIDTH{1'b0}};
                position = {ORDER_WIDTH{1'b0}}; 
        end  
        LOAD:
        begin
                data_out = {DATA_WIDTH{1'b0}};
                done     = 1'b0;
                overflow = 1'b0;
                error    = 1'b0;
                readFlag = 1'b1;        //  set readFlag high high to latch data
                num      = data_in;     //  loaad the data into local variables
                position = order;       //  loaad the data into local variables
        end
        ADD:
        begin
                data_out = {DATA_WIDTH{1'b0}};
                done     = 1'b0;
                overflow = 1'b0;
                error    = 1'b0;
                readFlag = 1'b0;        //  clear readFlag to avoid invalid data being loaded 
                num      = data_in;
                position = order; 
        end 
        DONE:
        begin      
                overflow = 1'b0;
                error    = 1'b0;
                readFlag = 1'b0;
                data_out = sum;
                done     = 1'b1;        // set done pin high
                num      = {DATA_WIDTH{1'b0}};
                position = {ORDER_WIDTH{1'b0}}; 
        end
        ERROR:
        begin    
                done     = 1'b0;
                overflow = 1'b0;
                readFlag = 1'b0;
                data_out = {DATA_WIDTH{1'bx}};
                error    = 1'b1;       // set error pin high
                num      = {DATA_WIDTH{1'b0}};
                position = {ORDER_WIDTH{1'b0}}; 
        end
        OVERFLOW:   
        begin
                done     = 1'b0;
                readFlag = 1'b0;
                error    = 1'b0;
                data_out = sum;
                overflow = 1'b1;        // set overflow pin high
                num      = {DATA_WIDTH{1'b0}};
                position = {ORDER_WIDTH{1'b0}}; 
        end
    endcase
 end
endmodule