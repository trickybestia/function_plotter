module vga (
    clk,

    read_data,
    read_addr,

    r,
    g,
    b,
    hs,
    vs,

    swap
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

localparam X_WIDTH = $clog2(HOR_TOTAL_PIXELS);
localparam Y_WIDTH = $clog2(VER_TOTAL_PIXELS);

localparam READ_ADDR_WIDTH = $clog2(HOR_ACTIVE_PIXELS * VER_ACTIVE_PIXELS);

input clk;

input                          read_data;
output [READ_ADDR_WIDTH - 1:0] read_addr;

output reg [3:0] r;
output reg [3:0] g;
output reg [3:0] b;
output reg       hs;
output reg       vs;

output reg swap;

reg [X_WIDTH-1:0] x;
reg [Y_WIDTH-1:0] y;

assign read_addr = y * HOR_ACTIVE_PIXELS + x;

initial begin
    x    = 0;
    y    = 0;
    r    = 0;
    g    = 0;
    b    = 0;
    hs   = 0;
    vs   = 0;
    swap = 1;
end

// x
always @(posedge clk) begin
    x <= (x == HOR_TOTAL_PIXELS - 1) ? 0 : x + 1;
end

// y
always @(posedge clk) begin
    if (x == HOR_TOTAL_PIXELS - 1) begin
        y <= (y == VER_TOTAL_PIXELS - 1) ? 0 : y + 1;
    end
end

// r, g, b
always @(posedge clk) begin
    r <= read_data ? 4'b1111 : 0;
    g <= read_data ? 4'b1111 : 0;
    b <= read_data ? 4'b1111 : 0;
end

// hs
always @(posedge clk) begin
    hs <= (x >= HOR_BACK_PORCH_PIXELS + HOR_ACTIVE_PIXELS + HOR_FRONT_PORCH_PIXELS) ? HOR_SYNC_POLARITY : ~HOR_SYNC_POLARITY;
end

// vs
always @(posedge clk) begin
    vs <= (y >= VER_BACK_PORCH_PIXELS + VER_ACTIVE_PIXELS + VER_FRONT_PORCH_PIXELS) ? VER_SYNC_POLARITY : ~VER_SYNC_POLARITY;
end

// swap
always @(posedge clk) begin
    swap <= (x == HOR_TOTAL_PIXELS - 1) & (y == VER_TOTAL_PIXELS - 1);
end

endmodule
