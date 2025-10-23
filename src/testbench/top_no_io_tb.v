`timescale 1ps / 1ps

module top_no_io_tb;

parameter HOR_ACTIVE_PIXELS = 640;
parameter VER_ACTIVE_PIXELS = 480;

parameter SYMBOL_WIDTH = 7;

localparam X_WIDTH      = $clog2(HOR_ACTIVE_PIXELS);
localparam Y_WIDTH      = $clog2(VER_ACTIVE_PIXELS);
localparam PIXELS_COUNT = HOR_ACTIVE_PIXELS * VER_ACTIVE_PIXELS;
localparam ADDR_WIDTH   = $clog2(PIXELS_COUNT);

reg clk;

reg                      ps2_left;
reg                      ps2_right;
reg                      ps2_backspace;
reg [SYMBOL_WIDTH - 1:0] ps2_symbol;

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

reg [ADDR_WIDTH - 1:0] frame_buffer_read_addr;
reg                    swap;

wire                 graphics_fsm_visible_iter_en;
wire                 graphics_fsm_logic_start;
wire                 graphics_fsm_fill_drawer_start;
wire                 graphics_fsm_symbol_drawer_start;
wire [X_WIDTH - 1:0] graphics_fsm_symbol_drawer_x;
wire [Y_WIDTH - 1:0] graphics_fsm_symbol_drawer_y;

input_buffer #(
    .SYMBOL_WIDTH (SYMBOL_WIDTH)
) input_buffer (
    .clk           (clk),
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
    .clk             (clk),
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

logic #(
    .HOR_ACTIVE_PIXELS (HOR_ACTIVE_PIXELS),
    .VER_ACTIVE_PIXELS (VER_ACTIVE_PIXELS),
    .SYMBOL_WIDTH      (SYMBOL_WIDTH)
) logic (
    .clk               (clk),
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
    .clk          (clk),
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
    .clk          (clk),
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
    .clk          (clk),
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
    .clk          (clk),
    .write_enable (fill_drawer_write_enable | line_drawer_write_enable | symbol_drawer_write_enable),
    .write_addr   (fill_drawer_write_addr | line_drawer_write_addr | symbol_drawer_write_addr),
    .write_data   (fill_drawer_write_data | line_drawer_write_data | symbol_drawer_write_data),
    .read_addr    (frame_buffer_read_addr),
    .read_data    (frame_buffer_read_data),
    .swap         (swap)
);

graphics_fsm #(
    .HOR_ACTIVE_PIXELS (HOR_ACTIVE_PIXELS),
    .VER_ACTIVE_PIXELS (VER_ACTIVE_PIXELS)
) graphics_fsm (
    .clk                 (clk),
    .swap                (swap),
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

task dump_frame_buffer;
    integer x;
    integer y;
    integer file;

    begin
        file = $fopen("frame_buffer.txt", "w");

        for (y = 0; y != 480; y = y + 1) begin
            for (x = 0; x != 640; x = x + 1) begin
                frame_buffer_read_addr = y * 640 + x;
                @(posedge clk);
                $fwrite(file, frame_buffer_read_data);
            end

            $fwrite(file, "\n");
        end

        $fclose(file);
    end
endtask

task draw_frame;
    begin
        while (~logic_ready) @(posedge clk);
        while (logic_ready)  @(posedge clk);
        while (~logic_ready) @(posedge clk);

        swap <= 1;
        @(posedge clk);
        swap <= 0;
        @(posedge clk);

        dump_frame_buffer();
        // run
        // python utils/show_frame_buffer_txt.py vivado_project/function_plotter.sim/top_no_io_tb/behav/xsim/frame_buffer.txt
        // from project root to see frame buffer content
    end
endtask

always begin // generate 25.175 MHz clock
    clk = 1'b0;
    #19861;
    clk = 1'b1;
    #19861;
end

initial begin
    frame_buffer_read_addr = 0;
    swap                   = 0;
    ps2_left               = 0;
    ps2_right              = 0;
    ps2_backspace          = 0;
    ps2_symbol             = 0;

    @(posedge clk);

    // draw 3 frames normally
/* -----\/----- EXCLUDED -----\/-----
    repeat (3) begin
        draw_frame();

        $stop;
    end
 -----/\----- EXCLUDED -----/\----- */

    ps2_symbol <= "[";
    @(posedge clk);
    ps2_symbol <= 0;
    @(posedge clk);

    draw_frame();


    ps2_symbol <= "x";
    @(posedge clk);
    ps2_symbol <= 0;
    @(posedge clk);

    draw_frame();


    ps2_symbol <= "-";
    @(posedge clk);
    ps2_symbol <= 0;
    @(posedge clk);

    draw_frame();


    ps2_symbol <= "5";
    @(posedge clk);
    ps2_symbol <= 0;
    @(posedge clk);

    draw_frame();


    ps2_symbol <= "]";
    @(posedge clk);
    ps2_symbol <= 0;
    @(posedge clk);

    draw_frame();


    ps2_symbol <= "*";
    @(posedge clk);
    ps2_symbol <= 0;
    @(posedge clk);

    draw_frame();



        ps2_symbol <= "[";
    @(posedge clk);
    ps2_symbol <= 0;
    @(posedge clk);

    draw_frame();


    ps2_symbol <= "x";
    @(posedge clk);
    ps2_symbol <= 0;
    @(posedge clk);

    draw_frame();


    ps2_symbol <= "+";
    @(posedge clk);
    ps2_symbol <= 0;
    @(posedge clk);

    draw_frame();


    ps2_symbol <= "5";
    @(posedge clk);
    ps2_symbol <= 0;
    @(posedge clk);

    draw_frame();


    ps2_symbol <= "]";
    @(posedge clk);
    ps2_symbol <= 0;
    @(posedge clk);

    draw_frame();


        ps2_symbol <= "*";
    @(posedge clk);
    ps2_symbol <= 0;
    @(posedge clk);

    draw_frame();
    $stop; 


        ps2_symbol <= "[";
    @(posedge clk);
    ps2_symbol <= 0;
    @(posedge clk);

    draw_frame();


    ps2_symbol <= "x";
    @(posedge clk);
    ps2_symbol <= 0;
    @(posedge clk);

    draw_frame();


    ps2_symbol <= "-";
    @(posedge clk);
    ps2_symbol <= 0;
    @(posedge clk);

    draw_frame();


    ps2_symbol <= "3";
    @(posedge clk);
    ps2_symbol <= 0;
    @(posedge clk);

    draw_frame();


    ps2_symbol <= "]";
    @(posedge clk);
    ps2_symbol <= 0;
    @(posedge clk);

    draw_frame();
    $stop; 
/* -----\/----- EXCLUDED -----\/-----
    ps2_symbol <= "3";
    @(posedge clk);
    ps2_symbol <= 0;
    @(posedge clk);

    draw_frame();
    $stop;


    ps2_symbol <= "-";
    @(posedge clk);
    ps2_symbol <= 0;
    @(posedge clk);

    draw_frame();
    $stop;

    ps2_symbol <= "2";
    @(posedge clk);
    ps2_symbol <= 0;
    @(posedge clk);

    draw_frame();
    $stop;

    ps2_symbol <= "]";
    @(posedge clk);
    ps2_symbol <= 0;
    @(posedge clk);

    draw_frame();
    $stop; 

    ps2_symbol <= "+";
    @(posedge clk);
    ps2_symbol <= 0;
    @(posedge clk);

    draw_frame();
    $stop;

    ps2_symbol <= "x";
    @(posedge clk);
    ps2_symbol <= 0;
    @(posedge clk);

    draw_frame();
    $stop;

    ps2_symbol <= "*";
    @(posedge clk);
    ps2_symbol <= 0;
    @(posedge clk);

    draw_frame();
    $stop; 

    ps2_symbol <= "2";
    @(posedge clk);
    ps2_symbol <= 0;
    @(posedge clk);

    draw_frame();
    $stop;
 -----/\----- EXCLUDED -----/\----- */

/* -----\/----- EXCLUDED -----\/-----
    // draw 3 frames with "a1" displayed, cursor between "a" and "1"
    repeat (3) begin
        draw_frame();

        $stop;
    end
 -----/\----- EXCLUDED -----/\----- */

/* -----\/----- EXCLUDED -----\/-----
    ps2_backspace <= 1;
    @(posedge clk);
    ps2_backspace <= 0;
    @(posedge clk);

    // draw 3 frames with "1" displayed, cursor at position 0
    repeat (3) begin
        draw_frame();

        $stop;
    end

    ps2_right <= 1;
    @(posedge clk);
    ps2_right <= 0;
    @(posedge clk);

    // draw 3 frames with "1" displayed, cursor at position 1
    repeat (3) begin
        draw_frame();

        $stop;
    end

    ps2_backspace <= 1;
    @(posedge clk);
    ps2_backspace <= 0;
    @(posedge clk);

    // draw 3 frames
    repeat (3) begin
        draw_frame();

        $stop;
    end
 -----/\----- EXCLUDED -----/\----- */

    $finish;
end

endmodule
