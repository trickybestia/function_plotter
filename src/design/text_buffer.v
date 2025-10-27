module text_buffer (
    clk,
    
    left,
    right,
    backspace,
    symbol,
    input_ready,
    
    full_iter_en,
    visible_iter_en,
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
localparam STATE_ITER                = 2;

input clk;

input                       left;
input                       right;
input                       backspace;
input  [SYMBOL_WIDTH - 1:0] symbol;
output                      input_ready;

input                           full_iter_en;
input                           visible_iter_en;
output     [SYMBOL_WIDTH - 1:0] iter_out;
output reg                      iter_out_valid;
output reg                      cursor_left;
output reg                      cursor_right;

reg [1:0] state;

reg [LENGTH_WIDTH - 1:0] cursor_index;
reg [LENGTH_WIDTH - 1:0] iter_index;

reg  [INDEX_WIDTH - 1:0]  vector_index;
reg                       vector_get;
reg                       vector_insert;
reg                       vector_remove;
wire [SYMBOL_WIDTH - 1:0] vector_data_out;
wire [LENGTH_WIDTH - 1:0] vector_length;
wire                      vector_ready;

wire iter_en      = full_iter_en | visible_iter_en;
wire handle_input = left | right | backspace | (symbol != 0);

assign input_ready = (state == STATE_HANDLE_INPUT) & vector_ready;
assign iter_out    = (state == STATE_ITER) ? vector_data_out : 0;

vector #(
    .DATA_WIDTH (SYMBOL_WIDTH),
    .DATA_COUNT (SYMBOLS_COUNT)
) vector (
    .clk      (clk),
    .reset    (0),
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

always @(*) begin
    vector_get    = 0;
    vector_insert = 0;
    vector_remove = 0;
    vector_index  = 0;

    case (state)
        STATE_READY: begin
            if ((symbol != 0) & (vector_length != SYMBOLS_COUNT)) begin
                vector_index  = cursor_index;
                vector_insert = 1;
            end
            if (backspace & (cursor_index != 0)) begin
                vector_index  = cursor_index - 1;
                vector_remove = 1;
            end
        end
        STATE_HANDLE_INPUT: begin
            if ((symbol != 0) & (vector_length != SYMBOLS_COUNT)) begin
                vector_index = cursor_index;
            end
            if (backspace & (cursor_index != 0)) begin
                vector_index = cursor_index - 1;
            end
        end
        STATE_ITER: begin
            vector_index = iter_index;
            vector_get   = iter_en;
        end
    endcase
end

always @(posedge clk) begin
    iter_out_valid <= 0;

    case (state)
        STATE_READY: begin
            if (handle_input) begin
                state <= STATE_HANDLE_INPUT;
            end else if (iter_en) begin
                if (vector_length == 0) begin
                    iter_out_valid <= 1;
                    cursor_left    <= 1;
                    cursor_right   <= 0;
                end else begin
                    state <= STATE_ITER;
                end
            end
        end
        STATE_HANDLE_INPUT: begin
            if (vector_ready) begin
                if ((left | backspace) & (cursor_index != 0)) begin
                    cursor_index <= cursor_index - 1;
                end
                if (((right | (symbol != 0)) & (cursor_index != vector_length))) begin
                    cursor_index <= cursor_index + 1;
                end

                state <= STATE_READY;
            end
        end
        STATE_ITER: begin
            if (iter_en) begin
                iter_out_valid <= 1;
                cursor_left    <= (iter_index == cursor_index);
                cursor_right   <= (cursor_index != 0) & (iter_index == cursor_index - 1);

                if (iter_index == vector_length) begin
                    iter_index <= 0;

                    state <= STATE_READY;
                end else begin
                    iter_index <= iter_index + 1;
                end
            end
        end
    endcase
end

endmodule
