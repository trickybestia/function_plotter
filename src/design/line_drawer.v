module line_drawer (
    clk,
    
    start,
    ready,

    x1,
    y1,
    x2,
    y2,
    
    write_enable,
    write_addr,
    write_data
);

parameter HOR_ACTIVE_PIXELS = 640;
parameter VER_ACTIVE_PIXELS = 480;
parameter COLOR             = 1;
parameter WRITE_DATA_WIDTH  = 1;

localparam X_WIDTH          = $clog2(HOR_ACTIVE_PIXELS);
localparam Y_WIDTH          = $clog2(VER_ACTIVE_PIXELS);
localparam COORD_WIDTH      = X_WIDTH > Y_WIDTH ? X_WIDTH : Y_WIDTH;
localparam PIXELS_COUNT     = HOR_ACTIVE_PIXELS * VER_ACTIVE_PIXELS;
localparam WRITE_ADDR_WIDTH = $clog2(PIXELS_COUNT);

localparam STATE_READY = 0;
localparam STATE_WORK  = 1;

input clk;

input  start;
output ready;

input [X_WIDTH - 1:0] x1;
input [Y_WIDTH - 1:0] y1;
input [X_WIDTH - 1:0] x2;
input [Y_WIDTH - 1:0] y2;

output                          write_enable;
output [WRITE_ADDR_WIDTH - 1:0] write_addr;
output [WRITE_DATA_WIDTH - 1:0] write_data;

wire [X_WIDTH - 1:0] delta_x = x2 > x1 ? x2 - x1 : x1 - x2;
wire [Y_WIDTH - 1:0] delta_y = y2 > y1 ? y2 - y1 : y1 - y2;

wire primary_is_x = delta_x > delta_y;

wire [COORD_WIDTH - 1:0] p_start = primary_is_x ? x1 : y1;
wire [COORD_WIDTH - 1:0] p_end   = primary_is_x ? x2 : y2;
wire [COORD_WIDTH - 1:0] s_start = primary_is_x ? y1 : x1;
wire [COORD_WIDTH - 1:0] s_end   = primary_is_x ? y2 : x2;

wire [COORD_WIDTH - 1:0] delta_p = p_end > p_start ? p_end - p_start : p_start - p_end;

reg signed [1:0] p_direction;
reg signed [1:0] s_direction;

wire [COORD_WIDTH - 1:0] delta_error = (s_end > s_start ? s_end - s_start : s_start - s_end) + 1;

reg [COORD_WIDTH:0] error;

reg [COORD_WIDTH - 1:0] p;
reg [COORD_WIDTH - 1:0] s;

reg state;

assign ready = (state == STATE_READY);

assign write_enable = (state == STATE_WORK);
assign write_addr   = write_enable ? (primary_is_x ? (s * HOR_ACTIVE_PIXELS + p) : (p * HOR_ACTIVE_PIXELS + s)) : 0;
assign write_data   = write_enable ? COLOR : 0;

function [COORD_WIDTH - 1:0] apply_direction;
    input        [COORD_WIDTH - 1:0] value;
    input signed [1:0]               direction;
    
    case (direction)
        1:  apply_direction      = value + 1;
        -1: apply_direction      = value - 1;
        default: apply_direction = value;
    endcase
endfunction

initial begin
    state = STATE_READY;
    error = 0;
    p     = 0;
    s     = 0;
end

always @(*) begin
    if (p_end > p_start) p_direction = 1;
    else if (p_end < p_start) p_direction = -1;
    else p_direction = 0;
end

always @(*) begin
    if (s_end > s_start) s_direction = 1;
    else if (s_end < s_start) s_direction = -1;
    else s_direction = 0;
end

always @(posedge clk) begin
    case (state)
        STATE_READY: state <= start ? STATE_WORK : STATE_READY;
        STATE_WORK:  state <= (p == p_end) ? STATE_READY : STATE_WORK;
    endcase
end

always @(posedge clk) begin
    if ((state == STATE_READY) & start) begin
        error <= 0;
        p     <= p_start;
        s     <= s_start;
    end else if (state == STATE_WORK) begin
        p <= apply_direction(p, p_direction);
        
        if (error + delta_error >= delta_p + 1) begin
            s     <= apply_direction(s, s_direction);
            error <= error + delta_error - delta_p - 1;
        end else begin
            error <= error + delta_error;
        end
    end
end

endmodule
