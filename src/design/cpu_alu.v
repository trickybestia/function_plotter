module cpu_alu (
    op,

    rs1_value,
    rs2_value,
    imm,

    result,
    eq,
    gt,
    lt
);

parameter REG_WIDTH = 16;

localparam IMM_WIDTH = REG_WIDTH / 2;
localparam OP_WIDTH  = 3;

localparam OP_ADD = 0;
localparam OP_SUB = 1;
localparam OP_AND = 2;
localparam OP_OR  = 3;
localparam OP_XOR = 4;
localparam OP_LH  = 5;
localparam OP_LL  = 6;

input [OP_WIDTH - 1:0] op;

input [REG_WIDTH - 1:0] rs1_value;
input [REG_WIDTH - 1:0] rs2_value;
input [IMM_WIDTH - 1:0] imm;

output reg [REG_WIDTH - 1:0] result;
output                       eq;
output                       gt;
output                       lt;

assign eq = (rs1_value == rs2_value);
assign gt = (rs1_value > rs2_value);
assign lt = (rs1_value < rs2_value);

// result
always @(*) begin
    case (op)
        OP_ADD:  result = rs1_value + rs2_value;
        OP_SUB:  result = rs1_value - rs2_value;
        OP_AND:  result = rs1_value & rs2_value;
        OP_OR:   result = rs1_value | rs2_value;
        OP_XOR:  result = rs1_value ^ rs2_value;
        OP_LH:   result = {imm, rs1_value[IMM_WIDTH - 1:0]};
        OP_LL:   result = {rs1_value[REG_WIDTH - 1:IMM_WIDTH], imm};
        default: result = 0;
    endcase
end

endmodule
