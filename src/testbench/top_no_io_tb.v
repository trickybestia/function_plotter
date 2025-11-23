`timescale 1ps / 1ps

module top_no_io_tb;

parameter HOR_ACTIVE_PIXELS = 640;
parameter HOR_TOTAL_PIXELS  = 800;
parameter VER_ACTIVE_PIXELS = 480;
parameter VER_TOTAL_PIXELS  = 525;

parameter SYMBOL_WIDTH = 7;

localparam X_WIDTH      = $clog2(HOR_ACTIVE_PIXELS);
localparam Y_WIDTH      = $clog2(VER_ACTIVE_PIXELS);
localparam PIXELS_COUNT = HOR_ACTIVE_PIXELS * VER_ACTIVE_PIXELS;
localparam ADDR_WIDTH   = $clog2(PIXELS_COUNT);

reg clk;

reg [SYMBOL_WIDTH - 1:0] keyboard_symbol;
reg [7:0]                data;
reg                      data_valid;

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

reg [ADDR_WIDTH - 1:0] frame_buffer_read_addr;
reg                    swap;

logic_ #(
    .HOR_ACTIVE_PIXELS (HOR_ACTIVE_PIXELS),
    .VER_ACTIVE_PIXELS (VER_ACTIVE_PIXELS),
    .SYMBOL_WIDTH      (SYMBOL_WIDTH)
) logic_ (
    .clk (clk),

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

    .swap (swap),

    .data       (data),
    .data_valid (data_valid),

    .instr_mem_write_enable (0),
    .instr_mem_write_addr   (0),
    .instr_mem_write_data   (0)
);

line_drawer #(
    .HOR_ACTIVE_PIXELS (HOR_ACTIVE_PIXELS),
    .VER_ACTIVE_PIXELS (VER_ACTIVE_PIXELS)
) line_drawer (
    .clk          (clk),
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
    .clk          (clk),
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
    .clk          (clk),
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
    .clk          (clk),
    .write_enable (fill_drawer_write_enable | line_drawer_write_enable | symbol_drawer_write_enable),
    .write_addr   (fill_drawer_write_addr | line_drawer_write_addr | symbol_drawer_write_addr),
    .write_data   (fill_drawer_write_data | line_drawer_write_data | symbol_drawer_write_data),
    .read_addr    (frame_buffer_read_addr),
    .read_data    (frame_buffer_read_data),
    .swap         (swap)
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
        repeat (HOR_TOTAL_PIXELS * VER_TOTAL_PIXELS) @(posedge clk);

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

task send_symbol;
    input [SYMBOL_WIDTH - 1:0] symbol;

    begin
        keyboard_symbol <= symbol;
        @(posedge clk);
        keyboard_symbol <= 0;
        @(posedge clk);
    end
endtask

task send_left_arrow;
    send_symbol(1);
endtask

task send_right_arrow;
    send_symbol(2);
endtask

task send_backspace;
    send_symbol(3);
endtask

always begin // generate 25.175 MHz clock
    clk = 1'b0;
    #19861;
    clk = 1'b1;
    #19861;
end

initial begin
    data       = 0;
    data_valid = 0;

    @(posedge clk);

    forever begin
        repeat (2500) @(posedge clk);

        data       <= data + 1;
        data_valid <= 1;

        @(posedge clk);

        data_valid <= 0;
    end
end

initial begin
    frame_buffer_read_addr = 0;
    swap                   = 0;
    keyboard_symbol        = 0;

    @(posedge clk);

    // draw 3 frames normally
    repeat (3) begin
        draw_frame();

        $stop;
    end

    send_symbol("1");

    // draw 3 frames with "1" displayed
    repeat (3) begin
        draw_frame();

        $stop;
    end

    send_left_arrow();

    // draw 3 frames with "1" displayed, cursor at position 0
    repeat (3) begin
        draw_frame();

        $stop;
    end

    send_symbol("a");

    // draw 3 frames with "a1" displayed, cursor between "a" and "1"
    repeat (3) begin
        draw_frame();

        $stop;
    end

    send_backspace();

    // draw 3 frames with "1" displayed, cursor at position 0
    repeat (3) begin
        draw_frame();

        $stop;
    end

    send_right_arrow();

    // draw 3 frames with "1" displayed, cursor at position 1
    repeat (3) begin
        draw_frame();

        $stop;
    end

    send_backspace();

    // draw 3 frames
    repeat (3) begin
        draw_frame();

        $stop;
    end

    $finish;
end

endmodule
