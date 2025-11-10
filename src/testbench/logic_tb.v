`timescale 1ns / 1ps

module logic_tb;

reg clk;

reg  fill_drawer_start;
wire fill_drawer_ready;

wire line_drawer_start;
wire line_drawer_ready;

reg  logic_start;
wire logic_ready;

wire [9:0] x1;
wire [8:0] y1;
wire [9:0] x2;
wire [8:0] y2;

wire        fill_drawer_write_enable;
wire [18:0] fill_drawer_write_addr;
wire        fill_drawer_write_data;

wire        line_drawer_write_enable;
wire [18:0] line_drawer_write_addr;
wire        line_drawer_write_data;  

wire        write_enable;
wire [18:0] write_addr;
wire        write_data;

reg  [18:0] read_addr;
wire        read_data;

reg swap;

assign write_enable = fill_drawer_write_enable | line_drawer_write_enable;
assign write_addr   = fill_drawer_write_addr | line_drawer_write_addr;
assign write_data   = fill_drawer_write_data | line_drawer_write_data;

logic_ logic_ (
    .clk               (clk),
    .start             (logic_start),
    .ready             (logic_ready),
    .x1                (x1),
    .y1                (y1),
    .x2                (x2),
    .y2                (y2),
    .line_drawer_start (line_drawer_start),
    .line_drawer_ready (line_drawer_ready),
    .symbol_iter_start (),
    .symbol_iter_en    (),
    .symbol            (),
    .symbol_valid      ()
);

fill_drawer fill_drawer (
    .clk          (clk),
    .start        (fill_drawer_start),
    .ready        (fill_drawer_ready),
    .write_enable (fill_drawer_write_enable),
    .write_addr   (fill_drawer_write_addr),
    .write_data   (fill_drawer_write_data)
);

line_drawer line_drawer (
    .clk          (clk),
    .start        (line_drawer_start),
    .ready        (line_drawer_ready),
    .x1           (x1),
    .y1           (y1),
    .x2           (x2),
    .y2           (y2),
    .write_enable (line_drawer_write_enable),
    .write_addr   (line_drawer_write_addr),
    .write_data   (line_drawer_write_data)
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
                read_addr = y * 640 + x;
                @(posedge clk);
                $fwrite(file, read_data);
            end

            $fwrite(file, "\n");
        end

        $fclose(file);
    end
endtask

always begin
    clk = 1'b0;
    #5;
    clk = 1'b1;
    #5;
end

initial begin
    fill_drawer_start = 0;
    logic_start       = 0;
    read_addr         = 0;
    swap              = 0;

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

    logic_start <= 1;
    @(posedge clk);
    logic_start <= 0;
    @(posedge clk);

    while (~logic_ready) @(posedge clk);

    swap <= 1;
    @(posedge clk);
    swap <= 0;
    @(posedge clk);

    dump_frame_buffer();
    // run
    // python utils/show_frame_buffer_txt.py vivado_project/function_plotter.sim/logic_tb/behav/xsim/frame_buffer.txt
    // from project root to see frame buffer content

    repeat (10) @(posedge clk);

    $finish;
end

endmodule
