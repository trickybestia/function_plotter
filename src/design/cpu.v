module cpu (
    clk,
    rst,

    instr_mem_addr,
    instr_mem_data_0,
    instr_mem_data_1,

    data_mem_addr,
    data_mem_read_data,
    data_mem_write_enable,
    data_mem_write_data,

    accel_id,
    accel_can_read,
    accel_can_write,
    accel_read_enable,
    accel_read_data,
    accel_write_enable,
    accel_write_data
);

localparam OP_WIDTH = 4;

localparam REG_WIDTH         = 16;
localparam INSTRUCTION_WIDTH = 16;

localparam REG_COUNT      = 16;
localparam REG_ADDR_WIDTH = $clog2(REG_COUNT);

localparam DATA_MEM_ADDR_WIDTH        = 16;
localparam INSTRUCTION_MEM_ADDR_WIDTH = 16;

localparam OP_LSB = INSTRUCTION_WIDTH - OP_WIDTH;

localparam RD_LSB  = OP_LSB - REG_ADDR_WIDTH;
localparam RS1_LSB = RD_LSB - REG_ADDR_WIDTH;
localparam RS2_LSB = RS1_LSB - REG_ADDR_WIDTH;

localparam COND_LSB   = RD_LSB;
localparam COND_WIDTH = REG_ADDR_WIDTH;

localparam ACCEL_ID_LSB   = RS2_LSB;
localparam ACCEL_ID_WIDTH = 4;

localparam IMM_WIDTH = REG_WIDTH / 2;
localparam IMM_LSB   = RD_LSB - IMM_WIDTH;

localparam OP_ADD   = 0;
localparam OP_SUB   = 1;
localparam OP_AND   = 2;
localparam OP_OR    = 3;
localparam OP_XOR   = 4;
localparam OP_LH    = 5;
localparam OP_LL    = 6;
localparam OP_JMP   = 7;
localparam OP_LOAD  = 8;
localparam OP_STORE = 9;
localparam OP_WACC  = 10;
localparam OP_RACC  = 11;

input clk;
input rst;

output [REG_WIDTH - 1:0] instr_mem_addr;
input  [REG_WIDTH - 1:0] instr_mem_data_0;
input  [REG_WIDTH - 1:0] instr_mem_data_1;

output [REG_WIDTH - 1:0] data_mem_addr;
input  [REG_WIDTH - 1:0] data_mem_read_data;
output                   data_mem_write_enable;
output [REG_WIDTH - 1:0] data_mem_write_data;

output [ACCEL_ID_WIDTH - 1:0] accel_id;
input                         accel_can_read;
input                         accel_can_write;
output                        accel_read_enable;
input  [REG_WIDTH - 1:0]      accel_read_data;
output                        accel_write_enable;
output [REG_WIDTH - 1:0]      accel_write_data;

// instruction decoding
wire [OP_WIDTH - 1:0]                   op                    = instr_mem_data_0[OP_LSB+:OP_WIDTH];
wire [REG_ADDR_WIDTH - 1:0]             rd1                   = instr_mem_data_0[RD_LSB+:REG_ADDR_WIDTH];
wire [REG_ADDR_WIDTH - 1:0]             rs1                   = (op == OP_LH || op == OP_LL) ? rd1 : instr_mem_data_0[RS1_LSB+:REG_ADDR_WIDTH];
wire [REG_ADDR_WIDTH - 1:0]             rs2                   = instr_mem_data_0[RS2_LSB+:REG_ADDR_WIDTH];
wire                                    rd1_write_enable      = (op == OP_ADD || op == OP_SUB || op == OP_AND || op == OP_OR || op == OP_XOR || op == OP_LH || op == OP_LL || op == OP_RACC);
wire                                    rd1_write_src         = (op == OP_RACC);
wire                                    jmp                   = (op == OP_JMP);
wire [3:0]                              cond                  = instr_mem_data_0[COND_LSB+:COND_WIDTH];
wire [INSTRUCTION_MEM_ADDR_WIDTH - 1:0] jmp_pc                = instr_mem_data_1;
wire [IMM_WIDTH - 1:0]                  imm                   = instr_mem_data_0[IMM_LSB+:IMM_WIDTH];
assign                                  accel_id              = instr_mem_data_0[ACCEL_ID_LSB+:ACCEL_ID_WIDTH];
assign                                  data_mem_write_enable = (op == OP_STORE);
assign                                  accel_read_enable     = (accel_can_read && op == OP_RACC);
assign                                  accel_write_enable    = (accel_can_write && op == OP_WACC);
wire                                    data_mem_read         = (op == OP_LOAD);

// cpu_reg_file
wire [REG_WIDTH - 1:0] rs1_value;
wire [REG_WIDTH - 1:0] rs2_value;

// cpu_alu
wire [REG_WIDTH - 1:0] alu_result;
wire                   alu_eq;
wire                   alu_gt;
wire                   alu_lt;

// cpu_jmp_cond_decoder
wire jmp_cond_decoder_result;

reg [3:0] rd2_reg;

reg data_mem_read_reg;

reg [REG_WIDTH - 1:0] pc, pc_next;
reg [REG_WIDTH - 1:0] executed, executed_next; // executed instructions count

assign instr_mem_addr      = pc_next;
assign data_mem_addr       = rs1_value;
assign data_mem_write_data = rs2_value;
assign accel_write_data    = rs1_value;

cpu_reg_file #(
    .REG_COUNT (REG_COUNT),
    .REG_WIDTH (REG_WIDTH)
) cpu_reg_file (
    .clk              (clk),
    .rs1              (rs1),
    .rs2              (rs2),
    .rs1_value        (rs1_value),
    .rs2_value        (rs2_value),
    .rd1              (rd1),
    .rd1_write_enable (rd1_write_enable),
    .rd1_write_data   (rd1_write_src ? accel_read_data : alu_result),
    .rd2              (rd2_reg),
    .rd2_write_enable (data_mem_read_reg),
    .rd2_write_data   (data_mem_read_data)
);

cpu_alu #(
    .REG_WIDTH (REG_WIDTH)
) cpu_alu (
    .op        (op),
    .rs1_value (rs1_value),
    .rs2_value (rs2_value),
    .imm       (imm),
    .result    (alu_result),
    .eq        (alu_eq),
    .gt        (alu_gt),
    .lt        (alu_lt)
);

cpu_jmp_cond_decoder cpu_jmp_cond_decoder (
    .cond            (cond),
    .eq              (alu_eq),
    .gt              (alu_gt),
    .lt              (alu_lt),
    .accel_can_read  (accel_can_read),
    .accel_can_write (accel_can_write),
    .result          (jmp_cond_decoder_result)
);

// pc_next, executed_next
always @(*) begin
    if (rst) begin
        pc_next       = 0;
        executed_next = 0;
    end else if ((op == OP_WACC && !accel_can_write) || (op == OP_RACC && !accel_can_read)) begin
        pc_next       = pc;
        executed_next = executed;
    end else if (jmp && jmp_cond_decoder_result) begin
        pc_next       = jmp_pc;
        executed_next = executed + 1;
    end else begin
        pc_next       = jmp ? pc + 2 : pc + 1;
        executed_next = executed + 1;
    end
end

// rd2_reg
always @(posedge clk) begin
    rd2_reg <= rd1;
end

// data_mem_read_reg
always @(posedge clk) begin
    if (rst) begin
        data_mem_read_reg <= 0;
    end else begin
        data_mem_read_reg <= data_mem_read;
    end
end

// pc
always @(posedge clk) begin
    pc <= pc_next;
end

// executed
always @(posedge clk) begin
    executed <= executed_next;
end

endmodule
