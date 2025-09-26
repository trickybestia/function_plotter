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

input                              read_data;
output reg [READ_ADDR_WIDTH - 1:0] read_addr;

output reg [3:0] r;
output reg [3:0] g;
output reg [3:0] b;
output reg       hs;
output reg       vs;

output swap;

reg [X_WIDTH-1:0] x;
reg [Y_WIDTH-1:0] y;

reg hs_reg_0, hs_reg_1;
reg vs_reg_0, vs_reg_1;
reg de_reg_0, de_reg_1; // data enable, a.k.a. VGA display time

wire [3:0] color;

assign color = (de_reg_1 & read_data) ? 4'b1111 : 0;

assign swap = (x == HOR_TOTAL_PIXELS - 1) & (y == VER_TOTAL_PIXELS - 1);

initial begin
    x         = 0;
    y         = 0;
    read_addr = 0;
    r         = 0;
    g         = 0;
    b         = 0;
    hs        = 0;
    vs        = 0;
    hs_reg_0  = 0;
    hs_reg_1  = 0;
    vs_reg_0  = 0;
    vs_reg_1  = 0;
    de_reg_0  = 0;
    de_reg_1  = 0;
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
    r <= color;
    g <= color;
    b <= color;
end

// hs_reg_0
always @(posedge clk) begin
    hs_reg_0 <= ((x >= HOR_ACTIVE_PIXELS + HOR_FRONT_PORCH_PIXELS) & (x < HOR_ACTIVE_PIXELS + HOR_FRONT_PORCH_PIXELS + HOR_SYNC_PIXELS)) ? HOR_SYNC_POLARITY : ~HOR_SYNC_POLARITY;
end

// hs_reg_1
always @(posedge clk) begin
    hs_reg_1 <= hs_reg_0;
end

// hs
always @(posedge clk) begin
    hs <= hs_reg_1;
end

// vs_reg_0
always @(posedge clk) begin
    vs_reg_0 <= ((y >= VER_ACTIVE_PIXELS + VER_FRONT_PORCH_PIXELS) & (y < VER_ACTIVE_PIXELS + VER_FRONT_PORCH_PIXELS + VER_SYNC_PIXELS)) ? VER_SYNC_POLARITY : ~VER_SYNC_POLARITY;
end

// vs_reg_1
always @(posedge clk) begin
    vs_reg_1 <= vs_reg_0;
end

// vs
always @(posedge clk) begin
    vs <= vs_reg_1;
end

// de_reg_0
always @(posedge clk) begin
    de_reg_0 <= (x < HOR_ACTIVE_PIXELS) & (y < VER_ACTIVE_PIXELS);
end

// de_reg_1
always @(posedge clk) begin
    de_reg_1 <= de_reg_0;
end

// read_addr
always @(posedge clk) begin
    read_addr <= y * HOR_ACTIVE_PIXELS + x;
end

endmodule
