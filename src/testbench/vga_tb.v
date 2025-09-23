`timescale 1ps / 1ps

module vga_tb;

reg clk;

wire        read_data;
wire [17:0] read_addr;

wire [3:0] r;
wire [3:0] g;
wire [3:0] b;
wire       hs;
wire       vs;

wire swap;

assign read_data = ^read_addr;

vga uut (
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

always begin // generate 25.175 MHz clock
    clk = 1'b0;
    #19861;
    clk = 1'b1;
    #19861;
end

initial begin
    @(posedge clk);
    @(posedge clk);

    while (~swap) @(posedge clk);
    
    @(posedge clk);
    @(posedge clk);
    
    while (~swap) @(posedge clk);

    repeat (100) @(posedge clk);

    $finish;
end

endmodule
