`timescale 1ns / 1ps

module symbol_drawer_tb;

reg clk;

reg  fill_drawer_start;
wire fill_drawer_ready;

reg  symbol_drawer_start;
wire symbol_drawer_ready;

reg [9:0] x;
reg [8:0] y;
reg [6:0] symbol;
reg       cursor_left;
reg       cursor_right;

wire        fill_drawer_write_enable;
wire [18:0] fill_drawer_write_addr;
wire        fill_drawer_write_data;

wire        symbol_drawer_write_enable;
wire [18:0] symbol_drawer_write_addr;
wire        symbol_drawer_write_data;  

wire        write_enable;
wire [18:0] write_addr;
wire        write_data;

reg  [18:0] read_addr;
wire        read_data;

reg swap;

assign write_enable = fill_drawer_write_enable | symbol_drawer_write_enable;
assign write_addr   = fill_drawer_write_addr | symbol_drawer_write_addr;
assign write_data   = fill_drawer_write_data | symbol_drawer_write_data;

fill_drawer fill_drawer (
    .clk          (clk),
    .start        (fill_drawer_start),
    .ready        (fill_drawer_ready),
    .write_enable (fill_drawer_write_enable),
    .write_addr   (fill_drawer_write_addr),
    .write_data   (fill_drawer_write_data)
);

symbol_drawer symbol_drawer (
    .clk          (clk),
    .start        (symbol_drawer_start),
    .ready        (symbol_drawer_ready),
    .x            (x),
    .y            (y),
    .symbol       (symbol),
    .cursor_left  (cursor_left),
    .cursor_right (cursor_right),
    .write_enable (symbol_drawer_write_enable),
    .write_addr   (symbol_drawer_write_addr),
    .write_data   (symbol_drawer_write_data)
);

frame_buffer frame_buffer (
    .clk          (clk),
    .write_enable (write_enable),
    .write_addr   (write_addr),
    .write_data   (write_data),
    .read_addr    (read_addr),
    .read_data    (read_data),
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
                read_addr <= y * 640 + x;
                @(posedge clk);
                $fwrite(file, read_data);
            end

            $fwrite(file, "\n");
        end

        $fclose(file);
    end
endtask

task draw_symbol;
    input [6:0] symbol_;

    begin
        symbol <= symbol_;

        symbol_drawer_start <= 1;
        @(posedge clk);
        symbol_drawer_start <= 0;
        @(posedge clk);

        while (~symbol_drawer_ready) @(posedge clk);

        x <= x + 15;
    end
endtask

always begin
    clk = 1'b0;
    #5;
    clk = 1'b1;
    #5;
end

initial begin
    fill_drawer_start   = 0;
    symbol_drawer_start = 0;
    x                   = 0;
    y                   = 0;
    symbol              = 0;
    cursor_left         = 0;
    cursor_right        = 0;
    read_addr           = 0;
    swap                = 0;

    @(posedge clk);
    @(posedge clk);

    swap <= 1;
    @(posedge clk);
    swap <= 0;
    @(posedge clk);

    fill_drawer_start <= 1;
    @(posedge clk);
    fill_drawer_start <= 0;
    @(posedge clk);

    while (~fill_drawer_ready) @(posedge clk);

    x <= 100;
    y <= 100;

    cursor_right <= 1;
    draw_symbol("h");
    cursor_right <= 0;
    cursor_left  <= 1;
    draw_symbol("e");
    cursor_left <= 0;
    draw_symbol("l");
    draw_symbol("l");
    draw_symbol("o");
    draw_symbol(0);
    draw_symbol("w");
    draw_symbol("o");
    draw_symbol("r");
    draw_symbol("l");
    draw_symbol("d");

    x <= 0;
    y <= 200;

    draw_symbol(0);
    draw_symbol("*");
    draw_symbol("+");
    draw_symbol("-");
    draw_symbol(".");
    draw_symbol("/");
    draw_symbol("0");
    draw_symbol("1");
    draw_symbol("2");
    draw_symbol("3");
    draw_symbol("4");
    draw_symbol("5");
    draw_symbol("6");
    draw_symbol("7");
    draw_symbol("8");
    draw_symbol("9");
    draw_symbol("[");
    draw_symbol("]");
    draw_symbol("a");
    draw_symbol("b");
    draw_symbol("c");
    draw_symbol("d");
    draw_symbol("e");
    draw_symbol("f");
    draw_symbol("g");
    draw_symbol("h");
    draw_symbol("i");
    draw_symbol("j");
    draw_symbol("k");
    draw_symbol("l");

    x <= 0;
    y <= 220;

    draw_symbol("m");
    draw_symbol("n");
    draw_symbol("o");
    draw_symbol("p");
    draw_symbol("q");
    draw_symbol("r");
    draw_symbol("s");
    draw_symbol("t");
    draw_symbol("u");
    draw_symbol("v");
    draw_symbol("w");
    draw_symbol("x");
    draw_symbol("y");
    draw_symbol("z");

    dump_frame_buffer();
    // run
    // python utils/show_frame_buffer_txt.py vivado_project/function_plotter.sim/symbol_drawer_tb/behav/xsim/frame_buffer.txt
    // from project root to see frame buffer content

    repeat (10) @(posedge clk);

    $finish;
end

endmodule
