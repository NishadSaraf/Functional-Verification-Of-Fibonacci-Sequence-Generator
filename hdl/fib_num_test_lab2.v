// =======================================================================
//   Filename:     fib_num_test.v
//   Created by:   Tareque Ahmad
//   Date:         Apr 17, 2017
//
//   Description:  Test module for fib_num_gen dut in Lab2
// =======================================================================

`timescale 1ns/1ps

`define DATA_WIDTH 64
`define FIB_ORDER  16

module fib_num_test
  (
   // Global inputs
   input                    clk,
   output                   reset_n,

   // Control outputs
   output                   load,
   output                   clear,

   // Data output
   output [`FIB_ORDER-1:0]  order,
   output [`DATA_WIDTH-1:0] data_in,

   // Inputs
   input                    done,
   input                    error,
   input                    overflow,
   input  [`DATA_WIDTH-1:0] data_out
   );

   parameter RESET_DURATION = 500;
   parameter MAX_SEQ_COUNT = 100000;

   // Define internal registers
   reg                   int_reset_n;
   reg                   int_load;
   reg                   int_clear;
   reg [`FIB_ORDER-1:0]  int_order;
   reg [`DATA_WIDTH-1:0] int_data;
   reg [31:0] test_seq;
   reg [3:0] delay;
   reg [3:0] err_delay;
   reg [3:0] rst_delay;

   initial begin

      // Generate one-time internal reset signal
      int_reset_n = 0;
      int_load = 0;
      int_clear = 0;
      int_order = 0;
      int_data = 8'h00;

      # RESET_DURATION int_reset_n = 1;
      $display ("\n@ %0d ns The chip is out of reset", $time);

      repeat (10)  @(posedge clk);

      test_seq = 0;

      repeat (MAX_SEQ_COUNT) begin

         // Increment test sequence counter
         test_seq = test_seq+1;

         // Set load
         int_load = 1;
         repeat (1)  @(posedge clk);

         // Randomly generate order and data_in
         int_order = ({$random} % 8'hff);
         int_data = ({$random} % 8'hff);
         $display ("@ %0d ns: Test sequence: %0d: Initial data= %0d. Fibonacci order= %0d ", $time, test_seq, int_data, int_order);

         // Wait until either done, error or overflow flag is set
         while (done == 0 && error == 0 && overflow == 0) @(posedge clk);

         // Wait for a extra cycle for overflow case - this is implementation specific. You might not need that
         if (overflow) repeat (1)  @(posedge clk);
         $display ("@ %0d ns: Result: %0d. Overflow bit: %h. Error bit: %h\n", $time, data_out, overflow, error);

         // In case of error or overflow, wait for a few cycle and set clear
         if (error == 1 || overflow == 1) begin
            err_delay = ({$random} % 4'hf);
            repeat (err_delay+2)  @(posedge clk);
            int_clear = 1;
         end

         // Clear the inputs to the DUT
         int_load = 0;
         int_order = 0;
         int_data = 8'h0;
         delay = ({$random} % 4'hf);

         // Wait for a few cycle before doing the next load
         repeat (delay+2)  @(posedge clk);
         int_clear = 0;

      end

      // Another set of stimuli for reset conditions
      repeat (500) begin

         // Increment test sequence counter
         test_seq = test_seq+1;

         // Set load
         int_load = 1;
         repeat (1)  @(posedge clk);

         // Randomly generate order and data_in
         int_order = ({$random} % 8'hff);
         int_data = ({$random} % 8'hff);
         $display ("@ %0d ns: Test sequence: %0d: Initial data= %0d. Fibonacci order= %0d ", $time, test_seq, int_data, order);

         // Wait for some random number of cycles and assert reset
         rst_delay = ({$random} % 8'hff);
         repeat (rst_delay)  @(posedge clk);
         int_reset_n = 0;

         // Clear the inputs to the DUT
         int_load = 0;
         int_order = 0;
         int_data = 8'h0;
         delay = ({$random} % 4'hf);

         // Wait for a few cycle before doing the next load
         repeat (delay+2)  @(posedge clk);
         int_clear = 0;
         int_reset_n = 1;

      end

      $finish;

   end

   // Continuous assignment to output
   assign reset_n = int_reset_n;
   assign load    = int_load;
   assign clear   = int_clear;
   assign order   = int_order;
   assign data_in = int_data;

endmodule //  fib_num_test

