module graphics_fsm (
    clk,

    swap,

    visible_iter_en,
    symbol,
    symbol_valid,

    logic_start,
    logic_ready,

    fill_drawer_start,
    fill_drawer_ready,

    symbol_drawer_start,
    symbol_drawer_ready,

    symbol_drawer_x,
    symbol_drawer_y
);

parameter SYMBOL_WIDTH      = 7;
parameter HOR_ACTIVE_PIXELS = 640;
parameter VER_ACTIVE_PIXELS = 480;

localparam X_WIDTH = $clog2(HOR_ACTIVE_PIXELS);
localparam Y_WIDTH = $clog2(VER_ACTIVE_PIXELS);

localparam STATE_WAIT_SWAP            = 0;
localparam STATE_FILL_DRAWER_START    = 1;
localparam STATE_WAIT_FILL_DRAWER_1   = 2;
localparam STATE_WAIT_FILL_DRAWER_2   = 3;
localparam STATE_SYMBOL_ITER_START    = 4;
localparam STATE_DRAW_FIRST_SYMBOL_1  = 5;
localparam STATE_DRAW_FIRST_SYMBOL_2  = 6;
localparam STATE_DRAW_FIRST_SYMBOL_3  = 7;
localparam STATE_SYMBOL_ITER_NEXT     = 8;
localparam STATE_WAIT_SYMBOL_DRAWER_1 = 9;
localparam STATE_WAIT_SYMBOL_DRAWER_2 = 10;
localparam STATE_LOGIC_START          = 11;
localparam STATE_WAIT_LOGIC_1         = 12;
localparam STATE_WAIT_LOGIC_2         = 13;

input clk;

input swap;

output                      visible_iter_en;
input  [SYMBOL_WIDTH - 1:0] symbol;
input                       symbol_valid;

output reg logic_start;
input      logic_ready;

output reg fill_drawer_start;
input      fill_drawer_ready;

output reg symbol_drawer_start;
input      symbol_drawer_ready;

output reg [X_WIDTH - 1:0] symbol_drawer_x;
output     [Y_WIDTH - 1:0] symbol_drawer_y;

reg [3:0] state;

assign visible_iter_en = ((state == STATE_SYMBOL_ITER_START) | (state == STATE_SYMBOL_ITER_NEXT)) & ~symbol_valid;

assign symbol_drawer_y = VER_ACTIVE_PIXELS - 20;

initial begin
    state               = STATE_FILL_DRAWER_START;
    logic_start         = 0;
    fill_drawer_start   = 0;
    symbol_drawer_start = 0;
    symbol_drawer_x     = 0;
end

always @(posedge clk) begin
    case (state)
        STATE_WAIT_SWAP: begin
            if (swap) state <= STATE_FILL_DRAWER_START;
        end
        STATE_FILL_DRAWER_START: begin
            fill_drawer_start <= 1;

            state <= STATE_WAIT_FILL_DRAWER_1;
        end
        STATE_WAIT_FILL_DRAWER_1: begin
            fill_drawer_start <= 0;

            state <= STATE_WAIT_FILL_DRAWER_2;
        end
        STATE_WAIT_FILL_DRAWER_2: begin
            if (fill_drawer_ready) state <= STATE_SYMBOL_ITER_START;
        end
        STATE_SYMBOL_ITER_START: begin
            symbol_drawer_x <= 0;

            if (symbol_valid) state <= STATE_DRAW_FIRST_SYMBOL_1;
        end
        STATE_DRAW_FIRST_SYMBOL_1: begin
            symbol_drawer_start <= 1;

            state <= STATE_DRAW_FIRST_SYMBOL_2;
        end
        STATE_DRAW_FIRST_SYMBOL_2: begin
            symbol_drawer_start <= 0;

            state <= STATE_DRAW_FIRST_SYMBOL_3;
        end
        STATE_DRAW_FIRST_SYMBOL_3: begin
            if (symbol_drawer_ready) begin
                symbol_drawer_x <= symbol_drawer_x + 15;

                state <= (symbol == 0) ? STATE_LOGIC_START : STATE_SYMBOL_ITER_NEXT;
            end
        end
        STATE_SYMBOL_ITER_NEXT: begin
            if (symbol_valid) begin
                symbol_drawer_start <= 1;

                state <= STATE_WAIT_SYMBOL_DRAWER_1;
            end
        end
        STATE_WAIT_SYMBOL_DRAWER_1: begin
            symbol_drawer_start <= 0;

            state <= STATE_WAIT_SYMBOL_DRAWER_2;
        end
        STATE_WAIT_SYMBOL_DRAWER_2: begin
            if (symbol_drawer_ready) begin
                symbol_drawer_x <= symbol_drawer_x + 15;

                state <= (symbol == 0) ? STATE_LOGIC_START : STATE_SYMBOL_ITER_NEXT;
            end
        end
        STATE_LOGIC_START: begin
            logic_start <= 1;

            state <= STATE_WAIT_LOGIC_1;
        end
        STATE_WAIT_LOGIC_1: begin
            logic_start <= 0;

            state <= STATE_WAIT_LOGIC_2;
        end
        STATE_WAIT_LOGIC_2: begin
            if (logic_ready) state <= STATE_WAIT_SWAP;
        end
    endcase
end

endmodule
