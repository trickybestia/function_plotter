module line_drawer (
    clk,
    
    x1,
    y1,
    x2,
    y2,
    
    start,
    ready,
    
    write_enable,
    write_addr,
    write_data
);

// ОБРЕГИСТРИТЬ ЧТО ТО. ЧТО ЕСЛИ x1, y1, x2, y2 поменяются во время работы модуля?

parameter HOR_ACTIVE_PIXELS = 640;
parameter VER_ACTIVE_PIXELS = 480;
parameter COLOR             = 0;
parameter WRITE_DATA_WIDTH  = 1;

localparam X_WIDTH          = $clog2(HOR_ACTIVE_PIXELS);
localparam Y_WIDTH          = $clog2(VER_ACTIVE_PIXELS);
localparam COORD_WIDTH      = X_WIDTH > Y_WIDTH ? X_WIDTH : Y_WIDTH;
localparam PIXELS_COUNT     = HOR_ACTIVE_PIXELS * VER_ACTIVE_PIXELS;
localparam WRITE_ADDR_WIDTH = $clog2(PIXELS_COUNT);

input clk;

input [X_WIDTH - 1:0] x1;
input [Y_WIDTH - 1:0] y1;
input [X_WIDTH - 1:0] x2;
input [Y_WIDTH - 1:0] y2;

input  start;
output ready;

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

initial begin
    error = 0;
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

endmodule
