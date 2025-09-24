module graphics_fsm (
    clk,

    swap,

    visible_iter_start,
    iter_en,
    symbol,
    symbol_valid,

    logic_start,
    logic_ready,

    logic_symbol_iter_en,

    fill_drawer_start,
    fill_drawer_ready,

    symbol_drawer_start,
    symbol_drawer_ready,

    symbol_drawer_x,
    symbol_drawer_y,
);

parameter SYMBOL_WIDTH      = 7;
parameter HOR_ACTIVE_PIXELS = 640;
parameter VER_ACTIVE_PIXELS = 480;

localparam X_WIDTH = $clog2(HOR_ACTIVE_PIXELS);
localparam Y_WIDTH = $clog2(VER_ACTIVE_PIXELS);

localparam STATE_WAIT_SWAP                      = 0;
localparam STATE_FILL_DRAWER_START              = 1;
localparam STATE_WAIT_FILL_DRAWER_1             = 2;
localparam STATE_WAIT_FILL_DRAWER_2             = 3;
localparam STATE_SYMBOL_ITER_START              = 4;
localparam STATE_SYMBOL_ITER_NEXT               = 5;
localparam STATE_SYMBOL_ITER_DONE_WAIT_SYMBOL_DRAWER = 6;
localparam STATE_SYMBOL_ITER_WAIT_SYMBOL_DRAWER = 7;
localparam STATE_LOGIC_START                    = 8;
localparam STATE_WAIT_LOGIC_1                   = 9;
localparam STATE_WAIT_LOGIC_2                   = 10;

input clk;

input swap;

output                      visible_iter_start;
output                      iter_en;
input  [SYMBOL_WIDTH - 1:0] symbol;
input                       symbol_valid;

output logic_start;
input  logic_ready;

input logic_symbol_iter_en;

output fill_drawer_start;
input  fill_drawer_ready;

output symbol_drawer_start;
input  symbol_drawer_ready;

output reg [X_WIDTH - 1:0] symbol_drawer_x;
output     [Y_WIDTH - 1:0] symbol_drawer_y;

reg [3:0] state;

assign visible_iter_start = (state == STATE_SYMBOL_ITER_START);
assign iter_en            = ((state == STATE_SYMBOL_ITER_START) & ~symbol_valid) | ((state == STATE_SYMBOL_ITER_NEXT) & ~symbol_valid) | logic_symbol_iter_en;

assign logic_start = (state == STATE_LOGIC_START);

assign fill_drawer_start = (state == STATE_FILL_DRAWER_START);

assign symbol_drawer_start = (state == STATE_SYMBOL_ITER_START);

assign symbol_drawer_y = VER_ACTIVE_PIXELS - 20;

initial begin
    state           = STATE_WAIT_SWAP;
    symbol_drawer_x = 0;
end

always @(posedge clk) begin
    case (state)
        STATE_WAIT_SWAP: begin
            if (swap) state <= STATE_FILL_DRAWER_START;
        end
        STATE_FILL_DRAWER_START: begin
            state <= STATE_WAIT_FILL_DRAWER_1;
        end
        STATE_WAIT_FILL_DRAWER_1: begin
            state <= STATE_WAIT_FILL_DRAWER_2;
        end
        STATE_WAIT_FILL_DRAWER_2: begin
            if (fill_drawer_ready) state <= STATE_SYMBOL_ITER_START;
        end
        STATE_SYMBOL_ITER_START, STATE_SYMBOL_ITER_NEXT: begin
            if (symbol_valid) begin
                state <= (symbol == 0) ? STATE_SYMBOL_ITER_DONE_WAIT_SYMBOL_DRAWER : STATE_SYMBOL_ITER_WAIT_SYMBOL_DRAWER;
            end
        end
        STATE_SYMBOL_ITER_DONE_WAIT_SYMBOL_DRAWER: begin
            if (symbol_drawer_ready) state <= STATE_LOGIC_START;
        end
        STATE_SYMBOL_ITER_WAIT_SYMBOL_DRAWER: begin
            if (symbol_drawer_ready) state <= STATE_SYMBOL_ITER_NEXT;
        end
        STATE_LOGIC_START: begin
            state <= STATE_WAIT_LOGIC_1;
        end
        STATE_WAIT_LOGIC_1: begin
            state <= STATE_WAIT_LOGIC_2;
        end
        STATE_WAIT_LOGIC_2: begin
            if (logic_ready) state <= STATE_WAIT_SWAP;
        end
    endcase
end

// symbol_drawer_x
always @(posedge clk) begin
    case (state)
        STATE_SYMBOL_ITER_START: symbol_drawer_x <= 0;
        STATE_SYMBOL_ITER_NEXT:  symbol_drawer_x <= symbol_drawer_x + 15;
    endcase
end

endmodule
