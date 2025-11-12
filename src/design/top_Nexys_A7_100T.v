module top_Nexys_A7_100T (
    clk_100M,
    
    ps2_clk,
    ps2_dat,
    
    vga_r,
    vga_g,
    vga_b,
    vga_hs,
    vga_vs
);

parameter HOR_TOTAL_PIXELS       = 800;
parameter HOR_ACTIVE_PIXELS      = 640;
parameter HOR_BACK_PORCH_PIXELS  = 48;
parameter HOR_FRONT_PORCH_PIXELS = 16;
parameter HOR_SYNC_PIXELS        = 96;
parameter HOR_SYNC_POLARITY      = 0; // negative

parameter VER_TOTAL_PIXELS       = 525;
parameter VER_ACTIVE_PIXELS      = 480;
parameter VER_BACK_PORCH_PIXELS  = 33;
parameter VER_FRONT_PORCH_PIXELS = 10;
parameter VER_SYNC_PIXELS        = 2;
parameter VER_SYNC_POLARITY      = 0; // negative

parameter SYMBOL_WIDTH = 7;

localparam X_WIDTH      = $clog2(HOR_ACTIVE_PIXELS);
localparam Y_WIDTH      = $clog2(VER_ACTIVE_PIXELS);
localparam PIXELS_COUNT = HOR_ACTIVE_PIXELS * VER_ACTIVE_PIXELS;
localparam ADDR_WIDTH   = $clog2(PIXELS_COUNT);

input clk_100M;

input ps2_clk;
input ps2_dat;

output [3:0] vga_r;
output [3:0] vga_g;
output [3:0] vga_b;
output       vga_hs;
output       vga_vs;

wire clk_25M175;

wire [SYMBOL_WIDTH - 1:0] keyboard_symbol;

wire [X_WIDTH - 1:0]    line_drawer_x1;
wire [Y_WIDTH - 1:0]    line_drawer_y1;
wire [X_WIDTH - 1:0]    line_drawer_x2;
wire [Y_WIDTH - 1:0]    line_drawer_y2;
wire                    line_drawer_start;
wire                    line_drawer_ready;
wire                    line_drawer_write_enable;
wire [ADDR_WIDTH - 1:0] line_drawer_write_addr;
wire                    line_drawer_write_data;

wire                      symbol_drawer_start;
wire                      symbol_drawer_ready;
wire [X_WIDTH - 1:0]      symbol_drawer_x;
wire [Y_WIDTH - 1:0]      symbol_drawer_y;
wire [SYMBOL_WIDTH - 1:0] symbol_drawer_symbol;
wire                      symbol_drawer_cursor_left;
wire                      symbol_drawer_cursor_right;
wire                      symbol_drawer_write_enable;
wire [ADDR_WIDTH - 1:0]   symbol_drawer_write_addr;
wire                      symbol_drawer_write_data;

wire                    fill_drawer_start;
wire                    fill_drawer_ready;
wire                    fill_drawer_write_enable;
wire [ADDR_WIDTH - 1:0] fill_drawer_write_addr;
wire                    fill_drawer_write_data;

wire frame_buffer_read_data;

wire [ADDR_WIDTH - 1:0] vga_read_addr;
wire                    vga_swap;

vga_mmcm vga_mmcm (
    .clk_100M   (clk_100M),
    .clk_25M175 (clk_25M175)
);

ps2 ps2 (
    .clk     (clk_25M175),
    .ps2_clk (ps2_clk),
    .ps2_dat (ps2_dat),
    .symbol  (keyboard_symbol)
);

logic_ #(
    .HOR_ACTIVE_PIXELS (HOR_ACTIVE_PIXELS),
    .VER_ACTIVE_PIXELS (VER_ACTIVE_PIXELS),
    .SYMBOL_WIDTH      (SYMBOL_WIDTH)
) logic_ (
    .clk (clk_25M175),

    .keyboard_symbol (keyboard_symbol),

    .line_drawer_x1    (line_drawer_x1),
    .line_drawer_y1    (line_drawer_y1),
    .line_drawer_x2    (line_drawer_x2),
    .line_drawer_y2    (line_drawer_y2),
    .line_drawer_start (line_drawer_start),
    .line_drawer_ready (line_drawer_ready),

    .symbol_drawer_x            (symbol_drawer_x),
    .symbol_drawer_y            (symbol_drawer_y),
    .symbol_drawer_symbol       (symbol_drawer_symbol),
    .symbol_drawer_cursor_left  (symbol_drawer_cursor_left),
    .symbol_drawer_cursor_right (symbol_drawer_cursor_right),
    .symbol_drawer_start        (symbol_drawer_start),
    .symbol_drawer_ready        (symbol_drawer_ready),

    .fill_drawer_start (fill_drawer_start),
    .fill_drawer_ready (fill_drawer_ready),

    .swap (vga_swap)
);

line_drawer #(
    .HOR_ACTIVE_PIXELS (HOR_ACTIVE_PIXELS),
    .VER_ACTIVE_PIXELS (VER_ACTIVE_PIXELS)
) line_drawer (
    .clk          (clk_25M175),
    .start        (line_drawer_start),
    .ready        (line_drawer_ready),
    .x1           (line_drawer_x1),
    .y1           (line_drawer_y1),
    .x2           (line_drawer_x2),
    .y2           (line_drawer_y2),
    .write_enable (line_drawer_write_enable),
    .write_addr   (line_drawer_write_addr),
    .write_data   (line_drawer_write_data)
);

symbol_drawer #(
    .SYMBOL_WIDTH      (SYMBOL_WIDTH),
    .HOR_ACTIVE_PIXELS (HOR_ACTIVE_PIXELS),
    .VER_ACTIVE_PIXELS (VER_ACTIVE_PIXELS)
) symbol_drawer (
    .clk          (clk_25M175),
    .start        (symbol_drawer_start),
    .ready        (symbol_drawer_ready),
    .x            (symbol_drawer_x),
    .y            (symbol_drawer_y),
    .symbol       (symbol_drawer_symbol),
    .cursor_left  (symbol_drawer_cursor_left),
    .cursor_right (symbol_drawer_cursor_right),
    .write_enable (symbol_drawer_write_enable),
    .write_addr   (symbol_drawer_write_addr),
    .write_data   (symbol_drawer_write_data)
);

fill_drawer #(
    .PIXELS_COUNT (PIXELS_COUNT)
) fill_drawer (
    .clk          (clk_25M175),
    .start        (fill_drawer_start),
    .ready        (fill_drawer_ready),
    .write_enable (fill_drawer_write_enable),
    .write_addr   (fill_drawer_write_addr),
    .write_data   (fill_drawer_write_data)
);

frame_buffer #(
    .HOR_ACTIVE_PIXELS (HOR_ACTIVE_PIXELS),
    .VER_ACTIVE_PIXELS (VER_ACTIVE_PIXELS)
) frame_buffer (
    .clk          (clk_25M175),
    .write_enable (fill_drawer_write_enable | line_drawer_write_enable | symbol_drawer_write_enable),
    .write_addr   (fill_drawer_write_addr | line_drawer_write_addr | symbol_drawer_write_addr),
    .write_data   (fill_drawer_write_data | line_drawer_write_data | symbol_drawer_write_data),
    .read_addr    (vga_read_addr),
    .read_data    (frame_buffer_read_data),
    .swap         (vga_swap)
);

vga #(
    .HOR_TOTAL_PIXELS       (HOR_TOTAL_PIXELS),
    .HOR_ACTIVE_PIXELS      (HOR_ACTIVE_PIXELS),
    .HOR_BACK_PORCH_PIXELS  (HOR_BACK_PORCH_PIXELS),
    .HOR_FRONT_PORCH_PIXELS (HOR_FRONT_PORCH_PIXELS),
    .HOR_SYNC_PIXELS        (HOR_SYNC_PIXELS),
    .HOR_SYNC_POLARITY      (HOR_SYNC_POLARITY),

    .VER_TOTAL_PIXELS       (VER_TOTAL_PIXELS),
    .VER_ACTIVE_PIXELS      (VER_ACTIVE_PIXELS),
    .VER_BACK_PORCH_PIXELS  (VER_BACK_PORCH_PIXELS),
    .VER_FRONT_PORCH_PIXELS (VER_FRONT_PORCH_PIXELS),
    .VER_SYNC_PIXELS        (VER_SYNC_PIXELS),
    .VER_SYNC_POLARITY      (VER_SYNC_POLARITY)
) vga (
    .clk       (clk_25M175),
    .read_data (frame_buffer_read_data),
    .read_addr (vga_read_addr),
    .r         (vga_r),
    .g         (vga_g),
    .b         (vga_b),
    .hs        (vga_hs),
    .vs        (vga_vs),
    .swap      (vga_swap)
);

endmodule
