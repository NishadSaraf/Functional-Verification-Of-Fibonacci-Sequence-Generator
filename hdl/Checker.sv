`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Engineer: Nishad Saraf (nishadsaraf@gmail.com)
// University: Portland State University
// Create Date: 04/20/2017 12:43:18 AM
// Design Name: 6 Rule Checker
// Module Name: Checker
// Project Name: 64-bit Fibonacci Sequence Generator
// Description: 
// This a checker module written for a 64-bit fibonacci sequence generator. The desgin 
// is bug free if it passed the following six rules.
// 1. when reset_n is asserted (driven to 0), all outputs become 0 within 1 clock cycle.
// 2. when load is asserted, valid data_in and valid order (no X or Z) must be driven on the same cycle.
// 3. Once "done' is asserted, output "data_out" must be correct on the same cycle.
// 4. Once "overflow' is asserted, output "data_out" must be all 1's on the same cycle.
// 5. Once "error' is asserted, output "data_out" must be all x's on the same cycle.
// 6. Unless it's an error or overflow condition, done and correct data must show up on the output "order+2" cycles after load is asserted.
// 
// By default all the rules are enabled but they can be enabled/disabled at simulation time using the command 
// "vsim -c +<RULE#>=<1/0> <top_module>"(1 to enabled & 0 to disable). Once a rule is violated checking of that rule 
// particular is halted.
// 
// For example to turn OFF rule  1 and 3: vsim -c +RULE1=0 +RULE3=0 TestBench
//
// Revision:
// Revision 0.01 - File Created
// 
//////////////////////////////////////////////////////////////////////////////////


module fib_num_chkr
#(
	// local parameters
    parameter   DATA_WIDTH  =   64,
    parameter   ORDER_WIDTH =   16
)
(
	// ports
    input                       clk,
                                reset_n,
                                load,
                                done,
                                error,
                                overflow,
    input   [DATA_WIDTH-1:0]    data_in,
                                data_out,
    input   [ORDER_WIDTH-1:0]   order
);

	// local variables
	logic R1, R2, R3, R4, R5, R6;					// knobs from enabling/disabling rules
	logic [DATA_WIDTH-1:0]  expDataOut, tempData; 
	logic [ORDER_WIDTH-1:0] counter, tempOrder;    // counter is used for counting the number clock cycles required for computation
	 
	// The following function mathematically calculates the expected output based on the input data and order
	// returns a value of width equal to DATA_WIDTH
	function logic [DATA_WIDTH-1:0] fib
	(
		// input arguments
		input logic [DATA_WIDTH-1:0]	data,
		input logic [ORDER_WIDTH-1:0]	order
	);
		// variables internal to function
		logic [DATA_WIDTH-1:0] currentNum, prevNum, nextNum;

		prevNum = {DATA_WIDTH{1'b0}};
		currentNum = data;
		// if any one of the inputs to function are zero then the output is also zero
		if(data == {DATA_WIDTH{1'b0}} || order == {ORDER_WIDTH{1'b0}})
			fib = {DATA_WIDTH{1'b0}};
		else
		begin	// if inputs are valid
			for(int i = 0; i < order; i++)
			begin
				nextNum = prevNum + currentNum;
				// the value of nextNum may exceed its range and could cause the expected output to wrap around
				if(prevNum + currentNum < prevNum) // if true means it will overflow
				begin
					currentNum = {DATA_WIDTH{1'b1}};	// all F's when overflow happens
					break;
				end
				else	// if the value is within the range 
				begin
					prevNum = currentNum;
					currentNum = nextNum;
				end
			end
			fib = currentNum;	// return the end result
		end
	endfunction

	initial 
	begin 
		// by default all the rule are enabled
		R1  =   1'b1;
		R2  =   1'b1;
		R3  =   1'b1;
		R4  =   1'b1;
		R5  =   1'b1;
		R6  =   1'b1;
		counter		= 1;
		tempData	= {DATA_WIDTH{1'b0}};
		tempOrder	= {ORDER_WIDTH{1'b0}};
		
		// if arguments are found on the command line save them in R1 and acknowledge the input
		if($value$plusargs("RULE1=%d",R1)) $display("Rule 1 input recorded");
		if($value$plusargs("RULE2=%d",R2)) $display("Rule 2 input recorded");
		if($value$plusargs("RULE3=%d",R3)) $display("Rule 3 input recorded");
		if($value$plusargs("RULE4=%d",R4)) $display("Rule 4 input recorded");
		if($value$plusargs("RULE5=%d",R5)) $display("Rule 5 input recorded");                                                                    
		if($value$plusargs("RULE6=%d",R6)) $display("Rule 6 input recorded");
		
		// summarize which rules are enable and which rule are disabled	
		if(R1)$display("Rule 1 is ON"); else    $display("Rule 1 is OFF");
		if(R2)$display("Rule 2 is ON"); else    $display("Rule 2 is OFF");
		if(R3)$display("Rule 3 is ON"); else    $display("Rule 3 is OFF");                                                                    
		if(R4)$display("Rule 4 is ON"); else    $display("Rule 4 is OFF");
		if(R5)$display("Rule 5 is ON"); else    $display("Rule 5 is OFF");
		if(R6)$display("Rule 6 is ON"); else    $display("Rule 6 is OFF");
	end 
	
	// whenever data_in and order changes compute the expected value
	always_comb
		expDataOut = fib(data_in,order);

	// Rule #1 
	always@(posedge clk)
	begin	
		if(R1 && !reset_n )
		begin
			repeat(1)@(posedge clk);	// wait for 1 clock cycle
			if(done == 1'b0 && overflow == 1'b0 && error == 1'b0 && data_out == {DATA_WIDTH{1'b0}})
				$display("Rule 1 successful!");
			else 
			begin
				$error("Rule 1 violation. Possible Reason: Output port are not initialized to 0' on reset.");
				R1 = 1'b0;
			end
		end
	end

	// Rule #2
	always@(posedge clk)
	begin   
		if(R2)@(posedge load)	// check only once for a set of data and order
		begin
			while(data_in == 0 && order == 0)@(posedge clk);    // wait until valid  data and order is available
			if(!(data_in === {DATA_WIDTH{1'bx}} || data_in === {DATA_WIDTH{1'bz}} || order === {ORDER_WIDTH{1'bx}} || order === {ORDER_WIDTH{1'bz}}))
			begin	// true only if valid data_in and order(no x and z) are available
				tempData    <= data_in;
				tempOrder   <= order;
				repeat(1)@(posedge clk);	// wait for one cycles if there's a change in the input values means that data_in and order are not driven on the samee cycle
				if(tempData == data_in && tempOrder == order)
				begin
					tempData   <= {DATA_WIDTH{1'b0}};
					tempOrder  <= {ORDER_WIDTH{1'b0}};
					$display("Rule 2 successful!");
				end
				else
				begin
					$error("Rule 2 violation. Possible Reason: Data and order are not driven on the same cycle.");
					R2 = 1'b0;	// disable the rule is it fails
				end
			end
			else 
			begin
				$error("Rule 2 violation. Possible Reason: Invalid Data and order.");
				R2 = 1'b0;
			end
		end
	end

	// Rule #3
	always@(posedge clk)
	begin
		if(R3 && done)
		begin
			if(data_out == expDataOut)
				$display("Rule 3 successful!");
			else 
			begin
				$error("Rule 3 violation. Possible Reason: Output data not driven on the same cycle of done signal or the actual value doesn't match the expected value.");
				R3 = 1'b0;
			end
		end
	end

	// Rule #4
	always@(posedge clk)
	begin    
		if(R4 && overflow)
		begin
			if(data_out == {DATA_WIDTH{1'b1}})
				$display("Rule 4 successful!");
			else 
			begin
				$error("Rule 4 violation. Possible Reason: Output data is not available on the same clock cycle as overflow");
				R4 = 1'b0;
			end
		end
	end

	// Rule #5
	always@(posedge clk)
	begin
		if(R5 && error)
		begin
			if(data_out === {DATA_WIDTH{1'bx}})
				$display("Rule 5 successful!");
			else 
			begin
				$error("Rule 5 violation. Possible Reason: Output data is dosn't contain all x's or the output is not available on the same cycle as error signal.");
				R5 = 1'b0;
			end
		end
	end

	// Rule #6
	always@(posedge clk)
	begin
		if(R6 && load)
		begin
			while(order == {ORDER_WIDTH{1'b0}})@(posedge clk);  // waits for valid input order to arrive
			
			if(done)
			begin
				if(counter == (order + 2))            
				begin
					counter = 'd1;
					$display("Rule 6 successful");
				end
				else 
				begin
					counter = 1;
					$error("Rule 6 violation. Possible Reason: Computation took longer than expected.");
					R6 = 1'b0;					
				end
			end
			else if(!overflow && !error)	counter++;		// when done signal is not high keep on incrementing the counter
			else 							counter = 'd1;    // if overflow or error signal goes high reset the counter to 1  
		end
	end

endmodule