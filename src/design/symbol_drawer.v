module symbol_drawer (
    clk,

    start,
    ready,

    x,
    y,
    symbol,
    cursor_left,
    cursor_right,

    write_enable,
    write_addr,
    write_data
);

parameter SYMBOL_WIDTH      = 7;
parameter HOR_ACTIVE_PIXELS = 640;
parameter VER_ACTIVE_PIXELS = 480;

localparam X_WIDTH           = $clog2(HOR_ACTIVE_PIXELS);
localparam Y_WIDTH           = $clog2(VER_ACTIVE_PIXELS);
localparam PIXELS_COUNT      = HOR_ACTIVE_PIXELS * VER_ACTIVE_PIXELS;
localparam WRITE_ADDR_WIDTH  = $clog2(PIXELS_COUNT);
localparam SYMBOL_HOR_PIXELS = 15;
localparam SYMBOL_VER_PIXELS = 20;
localparam REL_X_WIDTH       = $clog2(SYMBOL_HOR_PIXELS);
localparam REL_Y_WIDTH       = $clog2(SYMBOL_VER_PIXELS);

localparam SYMBOL_DRAWER_MEM_SIZE       = 38400;
localparam SYMBOL_DRAWER_MEM_ADDR_WIDTH = $clog2(SYMBOL_DRAWER_MEM_SIZE);

localparam STATE_READY = 0;
localparam STATE_WORK  = 1;

input clk;

input  start;
output ready;

input [X_WIDTH - 1:0]      x;
input [Y_WIDTH - 1:0]      y;
input [SYMBOL_WIDTH - 1:0] symbol;
input                      cursor_left;
input                      cursor_right;

output                          write_enable;
output [WRITE_ADDR_WIDTH - 1:0] write_addr;
output                          write_data;

wire [SYMBOL_DRAWER_MEM_ADDR_WIDTH - 1:0] symbol_drawer_mem_addr;
wire                                      symbol_drawer_mem_out;

wire cursor;

reg state;

reg [REL_X_WIDTH - 1:0] rel_x;
reg [REL_Y_WIDTH - 1:0] rel_y;

assign ready = (state == STATE_READY);

assign write_enable = (state == STATE_WORK);
assign write_addr   = write_enable ? ((y + rel_y) * HOR_ACTIVE_PIXELS + x + rel_x) : 0;
assign write_data   = write_enable ? (symbol_drawer_mem_out | cursor) : 0;

assign symbol_drawer_mem_addr = symbol * SYMBOL_HOR_PIXELS * SYMBOL_VER_PIXELS + rel_y * SYMBOL_HOR_PIXELS + rel_x;

assign cursor = (cursor_left & (rel_x == 0)) | (cursor_right & (rel_x == SYMBOL_HOR_PIXELS - 1));

symbol_drawer_mem #(
    .SIZE (SYMBOL_DRAWER_MEM_SIZE)
) symbol_drawer_mem (
    .addr (symbol_drawer_mem_addr),
    .out  (symbol_drawer_mem_out)
);

initial begin
    state = STATE_READY;
    rel_x = 0;
    rel_y = 0;
end

// state
always @(posedge clk) begin
    case (state)
        STATE_READY: begin
            if (start) state <= STATE_WORK;
        end
        STATE_WORK: begin
            if ((rel_x == SYMBOL_HOR_PIXELS - 1) & (rel_y == SYMBOL_VER_PIXELS - 1)) state <= STATE_READY;
        end
    endcase
end

// rel_x
always @(posedge clk) begin
    case (state)
        STATE_WORK: begin
            rel_x <= (rel_x == SYMBOL_HOR_PIXELS - 1) ? 0 : rel_x + 1;
        end
        default: ;
    endcase
end

// rel_y
always @(posedge clk) begin
    case (state)
        STATE_WORK: begin
            if (rel_x == SYMBOL_HOR_PIXELS - 1) begin
                rel_y <= (rel_y == SYMBOL_VER_PIXELS - 1) ? 0 : rel_y + 1;
            end
        end
        default: ;
    endcase
end

endmodule
