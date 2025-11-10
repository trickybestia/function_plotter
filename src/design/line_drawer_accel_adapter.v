module line_drawer_accel_adapter (
    clk,

    accel_can_read,
    accel_can_write,
    accel_read_enable,
    accel_write_enable,
    accel_read_data,
    accel_write_data,

    line_drawer_start,
    line_drawer_ready,
    line_drawer_x1,
    line_drawer_y1,
    line_drawer_x2,
    line_drawer_y2
);

localparam STATE_READ_X1 = 0;
localparam STATE_READ_Y1 = 1;
localparam STATE_READ_X2 = 2;
localparam STATE_READ_Y2 = 3;
localparam STATE_WORK    = 4;

input clk;

output        accel_can_read;
output        accel_can_write;
input         accel_read_enable;
input         accel_write_enable;
output [15:0] accel_read_data;
input  [15:0] accel_write_data;

output            line_drawer_start;
input             line_drawer_ready;
output reg [15:0] line_drawer_x1;
output reg [15:0] line_drawer_y1;
output reg [15:0] line_drawer_x2;
output reg [15:0] line_drawer_y2;

reg [2:0] state;

assign accel_can_read  = 0;
assign accel_can_write = (state == STATE_READ_X1 || state == STATE_READ_Y1 || state == STATE_READ_X2 || state == STATE_READ_Y2);
assign accel_read_data = 0;

assign line_drawer_start = (state == STATE_READ_Y2 && accel_write_enable);

initial begin
    state = STATE_READ_X1;
end

// state
always @(posedge clk) begin
    case (state)
        STATE_READ_X1: if (accel_write_enable) state <= STATE_READ_Y1;
        STATE_READ_Y1: if (accel_write_enable) state <= STATE_READ_X2;
        STATE_READ_X2: if (accel_write_enable) state <= STATE_READ_Y2;
        STATE_READ_Y2: if (accel_write_enable) state <= STATE_WORK;
        STATE_WORK:    if (line_drawer_ready)  state <= STATE_READ_X1;
    endcase
end

// line_drawer_x1
always @(posedge clk) begin
    if (state == STATE_READ_X1 && accel_write_enable) begin
        line_drawer_x1 <= accel_write_data;
    end
end

// line_drawer_y1
always @(posedge clk) begin
    if (state == STATE_READ_Y1 && accel_write_enable) begin
        line_drawer_y1 <= accel_write_data;
    end
end

// line_drawer_x2
always @(posedge clk) begin
    if (state == STATE_READ_X2 && accel_write_enable) begin
        line_drawer_x2 <= accel_write_data;
    end
end

// line_drawer_y2
always @(posedge clk) begin
    if (state == STATE_READ_Y2 && accel_write_enable) begin
        line_drawer_y2 <= accel_write_data;
    end
end

endmodule
