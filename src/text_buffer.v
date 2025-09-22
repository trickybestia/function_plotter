module text_buffer (
    clk,
    
    left,
    right,
    backspace,
    symbol,
    input_ready,
    
    full_iter_start,
    visible_iter_start,
    iter_en,
    iter_out,
    iter_out_valid,
    cursor_left,
    cursor_right
);

parameter SYMBOL_WIDTH  = 7;
parameter SYMBOLS_COUNT = 127;

localparam INDEX_WIDTH  = $clog2(SYMBOLS_COUNT);
localparam LENGTH_WIDTH = $clog2(SYMBOLS_COUNT + 1);

localparam STATE_READY               = 0;
localparam STATE_HANDLE_INPUT        = 1;
localparam STATE_HANDLE_INPUT_FINISH = 2;
localparam STATE_ITER                = 3;
localparam STATE_ITER_FINISH         = 4;

input clk;

input                       left;
input                       right;
input                       backspace;
input  [SYMBOL_WIDTH - 1:0] symbol;
output                      input_ready;

input                           full_iter_start;
input                           visible_iter_start;
input                           iter_en;
output     [SYMBOL_WIDTH - 1:0] iter_out;
output reg                      iter_out_valid;
output reg                      cursor_left;
output reg                      cursor_right;

reg [2:0] state, next_state;

reg [LENGTH_WIDTH - 1:0] cursor_index;
reg [LENGTH_WIDTH - 1:0] iter_index;

reg  [INDEX_WIDTH - 1:0]  vector_index;
wire                      vector_get;
wire                      vector_insert;
wire                      vector_remove;
wire [SYMBOL_WIDTH - 1:0] vector_data_out;
wire [LENGTH_WIDTH - 1:0] vector_length;
wire                      vector_ready;

wire handle_input = left | right | backspace | (symbol != 0);

assign vector_get    = (state == STATE_ITER) & iter_en;
assign vector_insert = (state == STATE_READY) & (symbol != 0) & (vector_length != SYMBOLS_COUNT);
assign vector_remove = (state == STATE_READY) & backspace & (cursor_index != 0);

assign input_ready = (state == STATE_HANDLE_INPUT_FINISH);

assign iter_out     = (state == STATE_ITER) ? vector_data_out : 0;

vector #(
    .DATA_WIDTH (SYMBOL_WIDTH),
    .DATA_COUNT (SYMBOLS_COUNT)
) vector (
    .clk      (clk),
    .index    (vector_index),
    .get      (vector_get),
    .insert   (vector_insert),
    .remove   (vector_remove),
    .data_in  (symbol),
    .data_out (vector_data_out),
    .length   (vector_length),
    .ready    (vector_ready)
);

initial begin
    state          = STATE_READY;
    cursor_index   = 0;
    iter_index     = 0;
    iter_out_valid = 0;
    cursor_left    = 0;
    cursor_right   = 0;
end

// vector_index
always @(*) begin
    vector_index = 0;

    if (vector_get)                                       vector_index = iter_index;
    if ((symbol != 0) & (vector_length != SYMBOLS_COUNT)) vector_index = cursor_index;
    if (backspace & (cursor_index != 0))                  vector_index = cursor_index - 1;
end

// next_state
always @(*) begin
    next_state = state;

    case (state)
        STATE_READY: begin
            if (handle_input)                              next_state = STATE_HANDLE_INPUT;
            else if (full_iter_start | visible_iter_start) next_state = (vector_length == 0) ? STATE_ITER_FINISH : STATE_ITER;
        end
        STATE_HANDLE_INPUT: begin
            if (vector_ready) next_state = STATE_HANDLE_INPUT_FINISH;
        end
        STATE_HANDLE_INPUT_FINISH: begin
            next_state = STATE_READY;
        end
        STATE_ITER: begin
            if (iter_en & (iter_index == vector_length)) next_state = STATE_ITER_FINISH;
        end
        STATE_ITER_FINISH: begin
            if (iter_en) next_state = STATE_READY;
        end
    endcase
end

// state
always @(posedge clk) begin
    state <= next_state;
end

// cursor_index
always @(posedge clk) begin
    if (state == STATE_HANDLE_INPUT_FINISH) begin
        if ((left & (cursor_index != 0)) | (backspace & (cursor_index != 0))) begin
            cursor_index <= cursor_index - 1;
        end
        if ((right & (cursor_index != vector_length)) | ((symbol != 0) & (vector_length != SYMBOLS_COUNT))) begin
            cursor_index <= cursor_index + 1;
        end
    end
end

// iter_index
always @(posedge clk) begin
    case (state)
        STATE_READY: begin
            if (~handle_input & full_iter_start)    iter_index <= 0;
            if (~handle_input & visible_iter_start) iter_index <= 0; // TODO: show only visible text
        end
        STATE_ITER: begin
            if (iter_en) iter_index <= iter_index + 1;
        end
    endcase
end

// iter_out_valid
always @(posedge clk) begin
    iter_out_valid <= ((state == STATE_ITER) | (state == STATE_ITER_FINISH)) & iter_en;
end

// cursor_left
always @(posedge clk) begin
    cursor_left <= (iter_index == cursor_index);
end

// cursor_right
always @(posedge clk) begin
    cursor_right <= (cursor_index != 0) & (iter_index == cursor_index - 1);
end

endmodule
