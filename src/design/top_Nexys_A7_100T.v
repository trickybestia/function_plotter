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

wire                      ps2_left;
wire                      ps2_right;
wire                      ps2_backspace;
wire [SYMBOL_WIDTH - 1:0] ps2_symbol;

wire                      input_buffer_left_out;
wire                      input_buffer_right_out;
wire                      input_buffer_backspace_out;
wire [SYMBOL_WIDTH - 1:0] input_buffer_symbol_out;

wire                      text_buffer_input_ready;
wire [SYMBOL_WIDTH - 1:0] text_buffer_iter_out;
wire                      text_buffer_iter_out_valid;
wire                      text_buffer_cursor_left;
wire                      text_buffer_cursor_right;

wire                 logic_ready;
wire [X_WIDTH - 1:0] logic_x1;
wire [Y_WIDTH - 1:0] logic_y1;
wire [X_WIDTH - 1:0] logic_x2;
wire [Y_WIDTH - 1:0] logic_y2;
wire                 logic_line_drawer_start;
wire                 logic_symbol_iter_en;

wire                    line_drawer_ready;
wire                    line_drawer_write_enable;
wire [ADDR_WIDTH - 1:0] line_drawer_write_addr;
wire                    line_drawer_write_data;

wire                    symbol_drawer_ready;
wire                    symbol_drawer_write_enable;
wire [ADDR_WIDTH - 1:0] symbol_drawer_write_addr;
wire                    symbol_drawer_write_data;

wire                    fill_drawer_ready;
wire                    fill_drawer_write_enable;
wire [ADDR_WIDTH - 1:0] fill_drawer_write_addr;
wire                    fill_drawer_write_data;

wire frame_buffer_read_data;

wire [ADDR_WIDTH - 1:0] vga_read_addr;
wire                    vga_swap;

wire                 graphics_fsm_visible_iter_en;
wire                 graphics_fsm_logic_start;
wire                 graphics_fsm_fill_drawer_start;
wire                 graphics_fsm_symbol_drawer_start;
wire [X_WIDTH - 1:0] graphics_fsm_symbol_drawer_x;
wire [Y_WIDTH - 1:0] graphics_fsm_symbol_drawer_y;

vga_mmcm vga_mmcm (
    .clk_100M   (clk_100M),
    .clk_25M175 (clk_25M175)
);

ps2 ps2 (
    .clk       (clk_25M175),
    .ps2_clk   (ps2_clk),
    .ps2_dat   (ps2_dat),
    .left      (ps2_left),
    .right     (ps2_right),
    .backspace (ps2_backspace),
    .symbol    (ps2_symbol)
);

input_buffer #(
    .SYMBOL_WIDTH (SYMBOL_WIDTH)
) input_buffer (
    .clk           (clk_25M175),
    .left_in       (ps2_left),
    .right_in      (ps2_right),
    .backspace_in  (ps2_backspace),
    .symbol_in     (ps2_symbol),
    .left_out      (input_buffer_left_out),
    .right_out     (input_buffer_right_out),
    .backspace_out (input_buffer_backspace_out),
    .symbol_out    (input_buffer_symbol_out),
    .out_ready     (text_buffer_input_ready)
);

text_buffer #(
    .SYMBOL_WIDTH  (SYMBOL_WIDTH),
    .SYMBOLS_COUNT (40)
) text_buffer (
    .clk             (clk_25M175),
    .left            (input_buffer_left_out),
    .right           (input_buffer_right_out),
    .backspace       (input_buffer_backspace_out),
    .symbol          (input_buffer_symbol_out),
    .input_ready     (text_buffer_input_ready),
    .full_iter_en    (logic_symbol_iter_en),
    .visible_iter_en (graphics_fsm_visible_iter_en),
    .iter_out        (text_buffer_iter_out),
    .iter_out_valid  (text_buffer_iter_out_valid),
    .cursor_left     (text_buffer_cursor_left),
    .cursor_right    (text_buffer_cursor_right)
);

logic_ #(
    .HOR_ACTIVE_PIXELS (HOR_ACTIVE_PIXELS),
    .VER_ACTIVE_PIXELS (VER_ACTIVE_PIXELS),
    .SYMBOL_WIDTH      (SYMBOL_WIDTH)
) logic_ (
    .clk               (clk_25M175),
    .start             (graphics_fsm_logic_start),
    .ready             (logic_ready),
    .x1                (logic_x1),
    .y1                (logic_y1),
    .x2                (logic_x2),
    .y2                (logic_y2),
    .line_drawer_start (logic_line_drawer_start),
    .line_drawer_ready (line_drawer_ready),
    .symbol_iter_en    (logic_symbol_iter_en),
    .symbol            (text_buffer_iter_out),
    .symbol_valid      (text_buffer_iter_out_valid)
);

line_drawer #(
    .HOR_ACTIVE_PIXELS (HOR_ACTIVE_PIXELS),
    .VER_ACTIVE_PIXELS (VER_ACTIVE_PIXELS)
) line_drawer (
    .clk          (clk_25M175),
    .start        (logic_line_drawer_start),
    .ready        (line_drawer_ready),
    .x1           (logic_x1),
    .y1           (logic_y1),
    .x2           (logic_x2),
    .y2           (logic_y2),
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
    .start        (graphics_fsm_symbol_drawer_start),
    .ready        (symbol_drawer_ready),
    .x            (graphics_fsm_symbol_drawer_x),
    .y            (graphics_fsm_symbol_drawer_y),
    .symbol       (text_buffer_iter_out),
    .cursor_left  (text_buffer_cursor_left),
    .cursor_right (text_buffer_cursor_right),
    .write_enable (symbol_drawer_write_enable),
    .write_addr   (symbol_drawer_write_addr),
    .write_data   (symbol_drawer_write_data)
);

fill_drawer #(
    .PIXELS_COUNT (PIXELS_COUNT)
) fill_drawer (
    .clk          (clk_25M175),
    .start        (graphics_fsm_fill_drawer_start),
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

graphics_fsm #(
    .HOR_ACTIVE_PIXELS (HOR_ACTIVE_PIXELS),
    .VER_ACTIVE_PIXELS (VER_ACTIVE_PIXELS)
) graphics_fsm (
    .clk                 (clk_25M175),
    .swap                (vga_swap),
    .visible_iter_en     (graphics_fsm_visible_iter_en),
    .symbol              (text_buffer_iter_out),
    .symbol_valid        (text_buffer_iter_out_valid),
    .logic_start         (graphics_fsm_logic_start),
    .logic_ready         (logic_ready),
    .fill_drawer_start   (graphics_fsm_fill_drawer_start),
    .fill_drawer_ready   (fill_drawer_ready),
    .symbol_drawer_start (graphics_fsm_symbol_drawer_start),
    .symbol_drawer_ready (symbol_drawer_ready),
    .symbol_drawer_x     (graphics_fsm_symbol_drawer_x),
    .symbol_drawer_y     (graphics_fsm_symbol_drawer_y)
);

endmodule
