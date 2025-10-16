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

parameter HOR_ACTIVE_PIXELS = 640;
parameter VER_ACTIVE_PIXELS = 480;
parameter SYMBOL_WIDTH      = 7;

localparam X_WIDTH = $clog2(HOR_ACTIVE_PIXELS);
localparam Y_WIDTH = $clog2(VER_ACTIVE_PIXELS);

localparam STATE_READY              = 0;
localparam STATE_DRAW_LINE          = 1;
localparam STATE_WAIT_LINE_DRAWER_1 = 2;
localparam STATE_WAIT_LINE_DRAWER_2 = 3;

parameter INTEGER_PART_WIDTH     = 8;
parameter FRACTIONAL_PART_WIDTH  = 8;
parameter NUMBER_WIDTH           = INTEGER_PART_WIDTH + FRACTIONAL_PART_WIDTH;
parameter OUTPUT_VALUE_WIDTH     = NUMBER_WIDTH + 1;

localparam OUTPUT_QUEUE_SIZE = 64;

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

reg [1:0] state;

reg [X_WIDTH - 1:0] t;

// instantiate vector module for output_queue
wire [$clog2(OUTPUT_QUEUE_SIZE) + 1:0] parser_index;
wire [$clog2(OUTPUT_QUEUE_SIZE) + 1:0] stack_machine_index;
reg                                    index_switch;   

wire [$clog2(OUTPUT_QUEUE_SIZE) + 1:0]  output_queue_index = index_switch ? stack_machine_index : parser_index;
wire                                    output_queue_get;
wire                                    output_queue_insert;   
wire [OUTPUT_VALUE_WIDTH - 1:0]         output_queue_data_in;
wire [OUTPUT_VALUE_WIDTH - 1:0]         output_queue_data_out;
wire                                    output_queue_ready;
   
   
vector #(
    .DATA_WIDTH (OUTPUT_VALUE_WIDTH),
    .DATA_COUNT (OUTPUT_QUEUE_SIZE),
) output_queue (
    .clk        (clk),
    .index      (output_queue_index),
    .get        (output_queue_get),
    .insert     (output_queue_insert),
    .data_in    (output_queue_data_in),
    .data_out   (output_queue_data_out),
    .ready      (output_queue_ready)                    
);         

// instantiate parser module
wire parser_ready;
   
parser parser (
    .clk                  (clk),
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
wire stack_machine_ready;   
   
stack_machine stack_machine (
    .clk                   (clk),
    .x                     (),
    .y                     (),
    .output_queue_index    (stack_machine_index),
    .output_queue_get      (output_queue_get),
    .output_queue_data_out (output_queue_data_out),
    .output_queue_ready    (output_queue_ready),
    .ready                 (stack_machine_ready)                        
);   

assign ready = (state == STATE_READY);

assign symbol_iter_en = 0;

initial begin
    state             = STATE_READY;
    t                 = 0;
    x1                = 0;
    y1                = 0;
    x2                = 0;
    y2                = 0;
    line_drawer_start = 0;
end

always @(posedge clk) begin
    case (state)
        STATE_READY: begin
            x1 <= 0;
            y1 <= VER_ACTIVE_PIXELS / 2;
            x2 <= 0;
            y2 <= VER_ACTIVE_PIXELS / 2;

            if (start) state <= STATE_DRAW_LINE;
        end
        STATE_DRAW_LINE: begin
            x1 <= x2;
            y1 <= y2;
            x2 <= t * 8;
            y2 <= t[0] ? (VER_ACTIVE_PIXELS / 2 - t * 2) : (VER_ACTIVE_PIXELS / 2 + t * 2);
            line_drawer_start <= 1;

            state <= STATE_WAIT_LINE_DRAWER_1;
        end
        STATE_WAIT_LINE_DRAWER_1: begin
            line_drawer_start <= 0;

            state <= STATE_WAIT_LINE_DRAWER_2;
        end
        STATE_WAIT_LINE_DRAWER_2: begin
            if (line_drawer_ready) begin
                if (t == HOR_ACTIVE_PIXELS / 8 - 2) begin
                    t <= 0;

                    state <= STATE_READY;
                end else begin
                    t <= t + 1;

                    state <= STATE_DRAW_LINE;
                end
            end
        end
    endcase
end

endmodule
