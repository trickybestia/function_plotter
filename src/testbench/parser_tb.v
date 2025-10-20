`timescale 1ns / 1ps

module parser_tb;

localparam SYMBOL_WIDTH       = 7;
localparam OUTPUT_QUEUE_SIZE  = 64;
localparam INTEGER_PART_WIDTH     = 8;
localparam FRACTIONAL_PART_WIDTH  = 8;

localparam NUMBER_WIDTH           = INTEGER_PART_WIDTH + FRACTIONAL_PART_WIDTH;
localparam OUTPUT_VALUE_WIDTH     = NUMBER_WIDTH + 1;   

reg  start, clk;
wire ready;    

wire                                   output_queue_insert;
wire [$clog2(OUTPUT_QUEUE_SIZE) + 1:0] output_queue_index;
wire [OUTPUT_VALUE_WIDTH - 1:0]        output_queue_data_in;
reg                                    output_queue_ready;   

wire                     symbol_iter_en;
reg [SYMBOL_WIDTH - 1:0] symbol;   
reg                      symbol_valid;   

parser #(
    .SYMBOL_WIDTH          (SYMBOL_WIDTH),
    .INTEGER_PART_WIDTH    (INTEGER_PART_WIDTH),
    .FRACTIONAL_PART_WIDTH (FRACTIONAL_PART_WIDTH),    
    .OUTPUT_QUEUE_SIZE     (OUTPUT_QUEUE_SIZE)         
) uut (
    .clk                  (clk),
    .start                (start),
    .ready                (ready),
    .output_queue_insert  (output_queue_insert),
    .output_queue_index   (output_queue_index),           
    .output_queue_data_in (output_queue_data_in),
    .output_queue_ready   (output_queue_ready),
    .symbol_iter_en       (symbol_iter_en),
    .symbol               (symbol),
    .symbol_valid         (symbol_valid)                 
);
  
always begin
    clk = 1'b0;
    #5;
    clk = 1'b1;
    #5;
end

initial begin
   // 1 * 2 + 3
   start              = 0;
   symbol_valid       = 0;
   output_queue_ready = 1;   

   #20;
   start <= 1;

   // 1
   #200;
   start <= 0;

   symbol <= "1";
   symbol_valid <= 1;

   #10;
   symbol_valid <= 0;

   // ' '
   #200;
   symbol <= "*";
   symbol_valid <= 1;

   #10;
   symbol_valid <= 0;

   // '+'
   #200;
   symbol <= "2";
   symbol_valid <= 1;

   #10;
   symbol_valid <= 0;

   // ' '
   #200;
   symbol <= "+";
   symbol_valid <= 1;

   #10;
   symbol_valid <= 0;

   // '1'
   #200;
   symbol <= "3";
   symbol_valid <= 1;

   #10;
   symbol_valid <= 0;

   // null
   #200;
   symbol <= 0;
   symbol_valid <= 1;

   #10;
   symbol_valid <= 0;

   #200;   

   $finish;
end

endmodule
