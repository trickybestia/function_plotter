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

input clk_100M;

input ps2_clk;
input ps2_dat;

output [3:0] vga_r;
output [3:0] vga_g;
output [3:0] vga_b;
output       vga_hs;
output       vga_vs;

wire clk_25M175;

vga_mmcm vga_mmcm (
    .clk_100M(clk_100M),
    .clk_25M175(clk_25M175)
);

endmodule
