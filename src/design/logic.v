module logic (
    clk,

    start,
    ready,

    x1,
    y1,
    x2,
    y2,
    line_drawer_start,
    line_drawer_ready,

    symbol_iter_en,
    symbol,
    symbol_valid
);

// parameters
parameter HOR_ACTIVE_PIXELS = 640;
parameter VER_ACTIVE_PIXELS = 480;
parameter SYMBOL_WIDTH      = 7;

// local parameters
localparam ACTUAL_VER_ACTIVE_PIXELS = VER_ACTIVE_PIXELS - 30;

localparam X_WIDTH = $clog2(HOR_ACTIVE_PIXELS);
localparam Y_WIDTH = $clog2(VER_ACTIVE_PIXELS);

localparam INTEGER_PART_WIDTH     = 11;
localparam FRACTIONAL_PART_WIDTH  = 8;
localparam NUMBER_WIDTH           = INTEGER_PART_WIDTH + FRACTIONAL_PART_WIDTH;
localparam OUTPUT_VALUE_WIDTH     = NUMBER_WIDTH + 1;

localparam OUTPUT_QUEUE_SIZE = 64;

// FSM states
localparam READY              = 0;
localparam PARSE_EXPRESSION   = 1;
localparam PARSE_EXPRESSION_2 = 2;
localparam PARSE_EXPRESSION_3 = 3;   
localparam CALCULATE          = 4;
localparam CALCULATE_2        = 5;
localparam CALCULATE_3        = 6;
localparam DRAW_X_AXIS        = 7;
localparam DRAW_X_AXIS_2      = 8;
localparam DRAW_X_AXIS_3      = 9;
localparam DRAW_Y_AXIS        = 10;
localparam DRAW_Y_AXIS_2      = 11;
localparam DRAW_Y_AXIS_3      = 12;  
localparam DRAW               = 13;
localparam DRAW_2             = 14;
localparam DRAW_3             = 15;   

// input/output
input clk;

input  start;
output ready;

output reg [X_WIDTH - 1:0] x1;
output reg [Y_WIDTH - 1:0] y1;
output reg [X_WIDTH - 1:0] x2;
output reg [Y_WIDTH - 1:0] y2;
output reg                 line_drawer_start;
input                      line_drawer_ready;

output                      symbol_iter_en;
input  [SYMBOL_WIDTH - 1:0] symbol;
input                       symbol_valid;

// reg/wire
reg [3:0] state;
reg       is_first_iter;   

reg [X_WIDTH - 1:0] x2_axis;
reg [Y_WIDTH - 1:0] y2_axis;

// instantiate vector module for output_queue
wire [$clog2(OUTPUT_QUEUE_SIZE) - 1:0] parser_index;
wire [$clog2(OUTPUT_QUEUE_SIZE) - 1:0] stack_machine_index;
reg                                    index_switch;   

wire [$clog2(OUTPUT_QUEUE_SIZE) - 1:0]     output_queue_index = 
 index_switch ? stack_machine_index : parser_index;
reg                                        output_queue_reset;
wire                                       output_queue_get;
wire                                       output_queue_insert;   
wire [OUTPUT_VALUE_WIDTH - 1:0]            output_queue_data_in;
wire [OUTPUT_VALUE_WIDTH - 1:0]            output_queue_data_out;
wire [$clog2(OUTPUT_QUEUE_SIZE + 1) - 1:0] output_queue_length;
wire                                       output_queue_ready;
   
vector #(
    .DATA_WIDTH (OUTPUT_VALUE_WIDTH),
    .DATA_COUNT (OUTPUT_QUEUE_SIZE)
) output_queue (
    .clk        (clk),
    .reset      (output_queue_reset),
    .index      (output_queue_index),
    .get        (output_queue_get),
    .insert     (output_queue_insert),
    .data_in    (output_queue_data_in),
    .data_out   (output_queue_data_out),
    .length     (output_queue_length),                
    .ready      (output_queue_ready)                    
);         

// instantiate parser module
reg  parser_start;   
wire parser_ready;
   
parser #(
    .INTEGER_PART_WIDTH    (INTEGER_PART_WIDTH),
    .FRACTIONAL_PART_WIDTH (FRACTIONAL_PART_WIDTH),
    .OUTPUT_QUEUE_SIZE     (OUTPUT_QUEUE_SIZE),
    .SYMBOL_WIDTH          (SYMBOL_WIDTH)         
) parser (
    .clk                  (clk),
    .start                (parser_start),
    .ready                (parser_ready),           
    .output_queue_insert  (output_queue_insert),
    .output_queue_index   (parser_index),
    .output_queue_data_in (output_queue_data_in),
    .output_queue_ready   (output_queue_ready),
    .symbol_iter_en       (symbol_iter_en),
    .symbol               (symbol),
    .symbol_valid         (symbol_valid)               
);    

// instantiate stack_machine module
wire                      stack_machine_ready;
reg                       stack_machine_start;
wire                      skip_pixel;
reg  [X_WIDTH - 1:0]      x;
wire [Y_WIDTH - 1:0]      stack_machine_result;   
    
stack_machine #(
    .INTEGER_PART_WIDTH    (INTEGER_PART_WIDTH),
    .FRACTIONAL_PART_WIDTH (FRACTIONAL_PART_WIDTH),
    .OUTPUT_QUEUE_SIZE     (OUTPUT_QUEUE_SIZE),
    .HOR_ACTIVE_PIXELS     (HOR_ACTIVE_PIXELS),
    .VER_ACTIVE_PIXELS     (ACTUAL_VER_ACTIVE_PIXELS)                
) stack_machine (
    .clk                   (clk),
    .ready                 (stack_machine_ready),
    .start                 (stack_machine_start),                         
    .x_input               (x),
    .y_output              (stack_machine_result),
    .skip_pixel            (skip_pixel),
    .output_queue_index    (stack_machine_index),
    .output_queue_get      (output_queue_get),
    .output_queue_length   (output_queue_length),                 
    .output_queue_data_out (output_queue_data_out),
    .output_queue_ready    (output_queue_ready)
);   

assign ready = (state == READY);

initial begin
    state               = READY;
    x1                  = 0;
    y1                  = 0;
    x2                  = 0;
    y2                  = 0;
    x                   = 0;   
    line_drawer_start   = 0;
    parser_start        = 0;
    index_switch        = 0;
    stack_machine_start = 0;
    is_first_iter       = 1;
    output_queue_reset  = 0;
end

always @(posedge clk) begin
    case (state)
        READY: begin
            if (start) begin
                state <= PARSE_EXPRESSION;
                x <= 0;
                x1 <= 0;
                y1 <= 0;
                x2 <= 0;
                y2 <= 0;
                index_switch <= 0;
                is_first_iter <= 1;
                output_queue_reset <= 1;
            end
        end

        PARSE_EXPRESSION: begin
            output_queue_reset <= 0;
            parser_start <= 1;
            state <= PARSE_EXPRESSION_2;
        end
        PARSE_EXPRESSION_2: begin
            parser_start <= 0;
            state <= PARSE_EXPRESSION_3;
        end
        PARSE_EXPRESSION_3: begin        
            if (parser_ready) begin
                state <= CALCULATE;
                index_switch <= 1;           
            end 
        end

        CALCULATE: begin
            if (x > HOR_ACTIVE_PIXELS)
              state <= READY;
            else begin
                stack_machine_start <= 1;
                state <= CALCULATE_2;
            end
        end
        CALCULATE_2: begin
            stack_machine_start <= 0;
            state <= CALCULATE_3;
        end
        CALCULATE_3: begin
            if (stack_machine_ready) begin
                state <= DRAW_X_AXIS;
            end
        end


        DRAW_X_AXIS: begin
            x2_axis <= x2; 
            y2_axis <= y2;            
            x1 <= 0;
            y1 <= ACTUAL_VER_ACTIVE_PIXELS / 2;
            x2 <= HOR_ACTIVE_PIXELS;
            y2 <= ACTUAL_VER_ACTIVE_PIXELS / 2;
            line_drawer_start <= 1;
            state <= DRAW_X_AXIS_2;
        end
        DRAW_X_AXIS_2: begin
            line_drawer_start <= 0;
            state <= DRAW_X_AXIS_3;
        end
        DRAW_X_AXIS_3: begin
            if (line_drawer_ready) begin
                state <= DRAW_Y_AXIS;
            end
        end 
        DRAW_Y_AXIS: begin
            x1 <= HOR_ACTIVE_PIXELS / 2;
            y1 <= 0;
            x2 <= HOR_ACTIVE_PIXELS / 2;
            y2 <= ACTUAL_VER_ACTIVE_PIXELS;
            line_drawer_start <= 1;
            state <= DRAW_Y_AXIS_2;
        end
        DRAW_Y_AXIS_2: begin
            line_drawer_start <= 0;
            state <= DRAW_Y_AXIS_3;
        end
        DRAW_Y_AXIS_3: begin
            if (line_drawer_ready) begin
                state <= DRAW;
                x2 <= x2_axis; 
                y2 <= y2_axis;
            end
        end

        DRAW: begin
            if (skip_pixel) begin
                x <= x + 1;
                state <= CALCULATE;
                is_first_iter <= 1;
            end            
            else if (is_first_iter) begin
                x2 <= x;
                y2 <= stack_machine_result;
                x <= x + 1; 
                state <= CALCULATE;
                is_first_iter <= 0;
            end
            else begin
                x1 <= x2;
                y1 <= y2;
                x2 <= x;
                y2 <= stack_machine_result;
                line_drawer_start <= 1;
                state <= DRAW_2;           
            end
        end
        DRAW_2: begin
            line_drawer_start <= 0;
            state <= DRAW_3;        
        end
        DRAW_3: begin
            if (line_drawer_ready) begin
                x <= x + 1;
                state <= CALCULATE;           
            end
        end

    endcase
end

endmodule
