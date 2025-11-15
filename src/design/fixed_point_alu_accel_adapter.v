module fixed_point_alu_accel_adapter (
    clk,

    accel_can_read,
    accel_can_write,
    accel_read_enable,
    accel_write_enable,
    accel_read_data,
    accel_write_data,

    alu_start,
    alu_done,
    alu_op,
    alu_a,
    alu_b,
    alu_result
);

parameter INTEGER_PART_WIDTH    = 8;
parameter FRACTIONAL_PART_WIDTH = 8;

localparam NUMBER_WIDTH = INTEGER_PART_WIDTH + FRACTIONAL_PART_WIDTH;

localparam STATE_READ_OP                  = 0;
localparam STATE_READ_A_INTEGER           = 1;
localparam STATE_READ_A_FRACTIONAL        = 2;
localparam STATE_READ_B_INTEGER           = 3;
localparam STATE_READ_B_FRACTIONAL        = 4;
localparam STATE_ALU_START                = 5;
localparam STATE_WORK                     = 6;
localparam STATE_RETURN_RESULT_INTEGER    = 7;
localparam STATE_RETURN_RESULT_FRACTIONAL = 8;

input clk;

output            accel_can_read;
output            accel_can_write;
input             accel_read_enable;
input             accel_write_enable;
output reg [15:0] accel_read_data;
input      [15:0] accel_write_data;

output                          alu_start;
input                           alu_done;
output reg [2:0]                alu_op;
output reg [NUMBER_WIDTH - 1:0] alu_a;
output reg [NUMBER_WIDTH - 1:0] alu_b;
input      [NUMBER_WIDTH - 1:0] alu_result;

reg [3:0] state;

assign accel_can_read  = (state == STATE_RETURN_RESULT_INTEGER || state == STATE_RETURN_RESULT_FRACTIONAL);
assign accel_can_write = (state == STATE_READ_OP || state == STATE_READ_A_INTEGER || state == STATE_READ_A_FRACTIONAL || state == STATE_READ_B_INTEGER || state == STATE_READ_B_FRACTIONAL);

assign alu_start = (state == STATE_ALU_START);

initial begin
    state = STATE_READ_OP;
end

// accel_read_data
always @(*) begin
    accel_read_data = 0;

    case (state)
        STATE_RETURN_RESULT_INTEGER:    accel_read_data = alu_result[NUMBER_WIDTH - 1-:INTEGER_PART_WIDTH];
        STATE_RETURN_RESULT_FRACTIONAL: accel_read_data = alu_result[0+:FRACTIONAL_PART_WIDTH];
        default: ;
    endcase
end

// state
always @(posedge clk) begin
    case (state)
        STATE_READ_OP:                  if (accel_write_enable) state <= STATE_READ_A_INTEGER;
        STATE_READ_A_INTEGER:           if (accel_write_enable) state <= STATE_READ_A_FRACTIONAL;
        STATE_READ_A_FRACTIONAL:        if (accel_write_enable) state <= STATE_READ_B_INTEGER;
        STATE_READ_B_INTEGER:           if (accel_write_enable) state <= STATE_READ_B_FRACTIONAL;
        STATE_READ_B_FRACTIONAL:        if (accel_write_enable) state <= STATE_ALU_START;
        STATE_ALU_START:                state <= STATE_WORK;
        STATE_WORK:                     if (alu_done) state <= STATE_RETURN_RESULT_INTEGER;
        STATE_RETURN_RESULT_INTEGER:    if (accel_read_enable) state <= STATE_RETURN_RESULT_FRACTIONAL;
        STATE_RETURN_RESULT_FRACTIONAL: if (accel_read_enable) state <= STATE_READ_OP;
    endcase
end

// alu_op
always @(posedge clk) begin
    if (state == STATE_READ_OP && accel_write_enable) begin
        alu_op <= accel_write_data;
    end
end

// alu_a
always @(posedge clk) begin
    if (accel_write_enable) begin
        case (state)
            STATE_READ_A_INTEGER:    alu_a[NUMBER_WIDTH - 1-:INTEGER_PART_WIDTH] <= accel_write_data;
            STATE_READ_A_FRACTIONAL: alu_a[0+:FRACTIONAL_PART_WIDTH]             <= accel_write_data;
            default: ;
        endcase
    end
end

// alu_b
always @(posedge clk) begin
    if (accel_write_enable) begin
        case (state)
            STATE_READ_B_INTEGER:    alu_b[NUMBER_WIDTH - 1-:INTEGER_PART_WIDTH] <= accel_write_data;
            STATE_READ_B_FRACTIONAL: alu_b[0+:FRACTIONAL_PART_WIDTH]             <= accel_write_data;
            default: ;
        endcase
    end
end

endmodule
