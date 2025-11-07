`timescale 1ns / 1ps

module cpu_reg_file_tb;

localparam REG_COUNT = 16;
localparam REG_WIDTH = 16;

localparam ADDR_WIDTH = $clog2(REG_COUNT);

reg clk;

reg [ADDR_WIDTH - 1:0] rs1;
reg [ADDR_WIDTH - 1:0] rs2;

wire [REG_WIDTH - 1:0] rs1_value;
wire [REG_WIDTH - 1:0] rs2_value;

reg [ADDR_WIDTH - 1:0] rd1;
reg                    rd1_write_enable;
reg [REG_WIDTH - 1:0]  rd1_write_data;

reg [ADDR_WIDTH - 1:0] rd2;
reg                    rd2_write_enable;
reg [REG_WIDTH - 1:0]  rd2_write_data;



endmodule
