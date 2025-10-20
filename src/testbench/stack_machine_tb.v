`timescale 1ns / 1ps

module stack_machine_tb;

localparam INTEGER_PART_WIDTH     = 11;
localparam FRACTIONAL_PART_WIDTH  = 8;
localparam OUTPUT_QUEUE_SIZE      = 64;
localparam HOR_ACTIVE_PIXELS      = 640;
localparam VER_ACTIVE_PIXELS      = 480;

localparam NUMBER_WIDTH       = INTEGER_PART_WIDTH + FRACTIONAL_PART_WIDTH;
localparam OUTPUT_VALUE_WIDTH = NUMBER_WIDTH + 1;

reg  clk, start;
wire ready;
   
reg        [NUMBER_WIDTH - 1:0] x_input;
wire       [NUMBER_WIDTH - 1:0] y_output; 

wire [$clog2(OUTPUT_QUEUE_SIZE) - 1:0]     output_queue_index;
wire                                       output_queue_get;
reg  [OUTPUT_VALUE_WIDTH - 1:0]            output_queue_data_out;
reg  [$clog2(OUTPUT_QUEUE_SIZE + 1) - 1:0] output_queue_length;
reg                                        output_queue_ready;    

stack_machine #(
    .INTEGER_PART_WIDTH    (INTEGER_PART_WIDTH),
    .FRACTIONAL_PART_WIDTH (FRACTIONAL_PART_WIDTH),
    .OUTPUT_QUEUE_SIZE     (OUTPUT_QUEUE_SIZE),
    .HOR_ACTIVE_PIXELS     (HOR_ACTIVE_PIXELS),
    .VER_ACTIVE_PIXELS     (VER_ACTIVE_PIXELS)               
) uut (
    .clk                   (clk),
    .start                 (start),
    .ready                 (ready),
    .x_input               (x_input),
    .y_output              (y_output),
    .output_queue_index    (output_queue_index),
    .output_queue_get      (output_queue_get),
    .output_queue_length   (output_queue_length),
    .output_queue_data_out (output_queue_data_out),
    .output_queue_ready    (output_queue_ready)  
);   

always begin
    clk = 1'b0;
    #5;
    clk = 1'b1;
    #5;
end

initial begin
   start                 = 0;
   output_queue_ready    = 0;
   output_queue_length   = 3;
   x_input               = 300; // quiet correct result with this x
   output_queue_data_out = 0;   

   #20;
   start <= 1;

   #10;
   start <= 0;
   #1000;   

   // x
   output_queue_data_out[NUMBER_WIDTH] <= 1;
   output_queue_data_out[NUMBER_WIDTH - 1:0] <= 6;
   output_queue_ready <= 1;

   #10;
   output_queue_ready <= 0;

   #100;

   // 1
   output_queue_data_out[NUMBER_WIDTH] <= 0;
   output_queue_data_out[FRACTIONAL_PART_WIDTH - 1:0] <= 0;
   output_queue_data_out[NUMBER_WIDTH - 1:FRACTIONAL_PART_WIDTH] <= 1;
   output_queue_ready <= 1;

   #10;
   output_queue_ready <= 0;

   #100;

   // +
   output_queue_data_out[NUMBER_WIDTH] <= 1;
   output_queue_data_out[NUMBER_WIDTH - 1:0] <= 1;
   
   output_queue_ready <= 1;

   #10;
   output_queue_ready <= 0;

   #1000;
   
   $finish;
end
   
endmodule
