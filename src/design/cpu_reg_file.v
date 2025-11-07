module cpu_reg_file (
    clk,

    rs1,
    rs2,

    rs1_value,
    rs2_value,

    rd1,
    rd1_write_enable,
    rd1_write_data,

    rd2,
    rd2_write_enable,
    rd2_write_data
);

parameter REG_COUNT = 16;
parameter REG_WIDTH = 16;

localparam ADDR_WIDTH = $clog2(REG_COUNT);

input clk;

input [ADDR_WIDTH - 1:0] rs1;
input [ADDR_WIDTH - 1:0] rs2;

output reg [REG_WIDTH - 1:0] rs1_value;
output reg [REG_WIDTH - 1:0] rs2_value;

input [ADDR_WIDTH - 1:0] rd1;
input                    rd1_write_enable;
input [REG_WIDTH - 1:0]  rd1_write_data;

input [ADDR_WIDTH - 1:0] rd2;
input                    rd2_write_enable;
input [REG_WIDTH - 1:0]  rd2_write_data;

reg [REG_WIDTH - 1:0] regs [1:REG_COUNT - 1];

// rs1_value
always @(*) begin
    if      (rs1 == 0)                       rs1_value = 0;
    else if (rd2_write_enable && rs1 == rd2) rs1_value = rd2_write_data;
    else                                     rs1_value = regs[rs1];
end

// rs2_value
always @(*) begin
    if      (rs2 == 0)                       rs2_value = 0;
    else if (rd2_write_enable && rs2 == rd2) rs2_value = rd2_write_data;
    else                                     rs2_value = regs[rs2];
end

// regs
always @(posedge clk) begin
    if (rd2_write_enable && rd2 != 0) regs[rd2] <= rd2_write_data;
    if (rd1_write_enable && rd1 != 0) regs[rd1] <= rd1_write_data; // rd1 has priority over rd2
end

endmodule
