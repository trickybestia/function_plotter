module symbol_drawer_accel_adapter (
    clk,

    accel_can_read,
    accel_can_write,
    accel_read_enable,
    accel_write_enable,
    accel_read_data,
    accel_write_data,

    symbol_drawer_start,
    symbol_drawer_ready,
    symbol_drawer_x,
    symbol_drawer_y,
    symbol_drawer_symbol,
    symbol_drawer_cursor_left,
    symbol_drawer_cursor_right
);

localparam STATE_READ_X            = 0;
localparam STATE_READ_Y            = 1;
localparam STATE_READ_SYMBOL       = 2;
localparam STATE_READ_CURSOR_LEFT  = 3;
localparam STATE_READ_CURSOR_RIGHT = 4;
localparam STATE_WORK              = 5;

input clk;

output        accel_can_read;
output        accel_can_write;
input         accel_read_enable;
input         accel_write_enable;
output [15:0] accel_read_data;
input  [15:0] accel_write_data;

output reg [15:0] symbol_drawer_x;
output reg [15:0] symbol_drawer_y;
output reg [15:0] symbol_drawer_symbol;
output reg        symbol_drawer_cursor_left;
output reg        symbol_drawer_cursor_right;
output            symbol_drawer_start;
input             symbol_drawer_ready;

reg [2:0] state;

assign accel_can_read  = 0;
assign accel_can_write = (state == STATE_READ_X || state == STATE_READ_Y || state == STATE_READ_SYMBOL || state == STATE_READ_CURSOR_LEFT || state == STATE_READ_CURSOR_RIGHT);
assign accel_read_data = 0;

assign symbol_drawer_start = (state == STATE_READ_CURSOR_RIGHT && accel_write_enable);

initial begin
    state = STATE_READ_X;
end

// state
always @(posedge clk) begin
    case (state)
        STATE_READ_X:            if (accel_write_enable)  state <= STATE_READ_Y;
        STATE_READ_Y:            if (accel_write_enable)  state <= STATE_READ_SYMBOL;
        STATE_READ_SYMBOL:       if (accel_write_enable)  state <= STATE_READ_CURSOR_LEFT;
        STATE_READ_CURSOR_LEFT:  if (accel_write_enable)  state <= STATE_READ_CURSOR_RIGHT;
        STATE_READ_CURSOR_RIGHT: if (accel_write_enable)  state <= STATE_WORK;
        STATE_WORK:              if (symbol_drawer_ready) state <= STATE_READ_X;
    endcase
end

// symbol_drawer_x
always @(posedge clk) begin
    if (state == STATE_READ_X && accel_write_enable) begin
        symbol_drawer_x <= accel_write_data;
    end
end

// symbol_drawer_y
always @(posedge clk) begin
    if (state == STATE_READ_Y && accel_write_enable) begin
        symbol_drawer_y <= accel_write_data;
    end
end

// symbol_drawer_symbol
always @(posedge clk) begin
    if (state == STATE_READ_SYMBOL && accel_write_enable) begin
        symbol_drawer_symbol <= accel_write_data;
    end
end

// symbol_drawer_cursor_left
always @(posedge clk) begin
    if (state == STATE_READ_CURSOR_LEFT && accel_write_enable) begin
        symbol_drawer_cursor_left <= accel_write_data[0];
    end
end

// symbol_drawer_cursor_right
always @(posedge clk) begin
    if (state == STATE_READ_CURSOR_RIGHT && accel_write_enable) begin
        symbol_drawer_cursor_right <= accel_write_data[0];
    end
end

endmodule
