module logic_placeholder (
    clk,

    start,
    ready,

    x1,
    y1,
    x2,
    y2,
    line_drawer_start,
    line_drawer_ready,

    symbol_iter_start,
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

input clk;

input  start;
output ready;

output reg [X_WIDTH - 1:0] x1;
output reg [Y_WIDTH - 1:0] y1;
output     [X_WIDTH - 1:0] x2;
output     [Y_WIDTH - 1:0] y2;
output reg                 line_drawer_start;
input                      line_drawer_ready;

output                      symbol_iter_start;
output                      symbol_iter_en;
input  [SYMBOL_WIDTH - 1:0] symbol;
input                       symbol_valid;

reg [1:0] state;

reg  [X_WIDTH - 1:0] t;
wire [Y_WIDTH - 1:0] y;

assign ready = (state == STATE_READY);

assign x2 = t * 8;
assign y2 = y;

assign symbol_iter_start = 0;
assign symbol_iter_en    = 0;

assign y = t[0] ? (240 - t * 2) : (240 + t * 2);

initial begin
    state             = STATE_READY;
    t                 = 0;
    x1                = 0;
    y1                = 240;
    line_drawer_start = 0;
end

// state
always @(posedge clk) begin
    case (state)
        STATE_READY: begin
            if (start) state <= STATE_DRAW_LINE;
        end
        STATE_DRAW_LINE: begin
            state <= STATE_WAIT_LINE_DRAWER_1;
        end
        STATE_WAIT_LINE_DRAWER_1: begin
            state <= STATE_WAIT_LINE_DRAWER_2;
        end
        STATE_WAIT_LINE_DRAWER_2: begin
            if (line_drawer_ready) begin
                if (t == HOR_ACTIVE_PIXELS / 8 - 2) begin
                    state <= STATE_READY;
                end else begin
                    state <= STATE_DRAW_LINE;
                end
            end
        end
    endcase
end

// t
always @(posedge clk) begin
    if ((state == STATE_WAIT_LINE_DRAWER_2) & line_drawer_ready) begin
        t <= (t == HOR_ACTIVE_PIXELS / 8 - 2) ? 0 : t + 1;
    end
end

// x1
always @(posedge clk) begin
    if ((state == STATE_WAIT_LINE_DRAWER_2) & line_drawer_ready) begin
        x1 <= x2;
    end
end

// y1
always @(posedge clk) begin
    if ((state == STATE_WAIT_LINE_DRAWER_2) & line_drawer_ready) begin
        y1 <= y2;
    end
end

// line_drawer_start
always @(posedge clk) begin
    line_drawer_start <= (state == STATE_DRAW_LINE);
end

endmodule
