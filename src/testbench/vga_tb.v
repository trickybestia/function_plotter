`timescale 1ps / 1ps

module vga_tb;

reg clk;

wire        read_data;
wire [18:0] read_addr;

wire [3:0] r;
wire [3:0] g;
wire [3:0] b;
wire       hs;
wire       vs;

wire swap;

reg  fill_drawer_start;
wire fill_drawer_ready;

wire        fill_drawer_write_enable;
wire [18:0] fill_drawer_write_addr;
wire        fill_drawer_write_data;

vga vga (
    .clk       (clk),
    .read_data (read_data),
    .read_addr (read_addr),
    .r         (r),
    .g         (g),
    .b         (b),
    .hs        (hs),
    .vs        (vs),
    .swap      (swap)
);

fill_drawer #(
    .COLOR (1)
) fill_drawer (
    .clk          (clk),
    .start        (fill_drawer_start),
    .ready        (fill_drawer_ready),
    .write_enable (fill_drawer_write_enable),
    .write_addr   (fill_drawer_write_addr),
    .write_data   (fill_drawer_write_data)
);

frame_buffer frame_buffer (
    .clk          (clk),
    .write_enable (fill_drawer_write_enable),
    .write_addr   (fill_drawer_write_addr),
    .write_data   (fill_drawer_write_data),
    .read_addr    (read_addr),
    .read_data    (read_data),
    .swap         (swap)
);

always begin // generate 25.175 MHz clock
    clk = 1'b0;
    #19861;
    clk = 1'b1;
    #19861;
end

initial begin
    fill_drawer_start = 0;

    @(posedge clk);
    @(posedge clk);

    fill_drawer_start <= 1;
    @(posedge clk);
    fill_drawer_start <= 0;

    while (~swap) @(posedge clk);
    
    @(posedge clk);
    @(posedge clk);
    
    while (~swap) @(posedge clk);

    repeat (100) @(posedge clk);

    $finish;
end

endmodule
