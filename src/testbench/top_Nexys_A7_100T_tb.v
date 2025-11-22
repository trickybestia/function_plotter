`timescale 1ns / 1ps

module top_Nexys_A7_100T_tb;

reg clk;

reg ps2_clk;
reg ps2_dat;

wire [3:0] vga_r;
wire [3:0] vga_g;
wire [3:0] vga_b;
wire       vga_hs;
wire       vga_vs;

reg uart_rx_in;

top_Nexys_A7_100T uut (
    .clk_100M   (clk),
    .ps2_clk    (ps2_clk),
    .ps2_dat    (ps2_dat),
    .vga_r      (vga_r),
    .vga_g      (vga_g),
    .vga_b      (vga_b),
    .vga_hs     (vga_hs),
    .vga_vs     (vga_vs),
    .uart_rx_in (uart_rx_in)
);

always begin
    clk = 1'b0;
    #5;
    clk = 1'b1;
    #5;
end

initial begin
    ps2_clk    = 1;
    ps2_dat    = 0;
    uart_rx_in = 1;

    @(posedge uut.clk_25M175);

    // Draw 3 frames
    repeat (3) begin
        while (uut.fill_drawer.ready) @(posedge uut.clk_25M175);
        while (~uut.fill_drawer.ready) @(posedge uut.clk_25M175);

        while (uut.logic_.ready) @(posedge uut.clk_25M175);
        while (~uut.logic_.ready) @(posedge uut.clk_25M175);

        repeat (1000) @(posedge uut.clk_25M175);

        $stop;
    end

    $finish;
end

endmodule
