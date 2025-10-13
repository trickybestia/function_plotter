module fixed_point_alu (
    clk,

    start,
    done,

    op,

    a,
    b,

    result
);

parameter INTEGER_PART_WIDTH    = 8;
parameter FRACTIONAL_PART_WIDTH = 8;

localparam NUMBER_WIDTH = INTEGER_PART_WIDTH + FRACTIONAL_PART_WIDTH;

localparam OP_ADD = 3'b000;
localparam OP_SUB = 3'b001;
localparam OP_MUL = 3'b010;
localparam OP_DIV = 3'b011;
localparam OP_POW = 3'b100;

localparam STATE_READY     = 0;
localparam STATE_ADD       = 1;
localparam STATE_SUB       = 2;
localparam STATE_MUL_START = 3;
localparam STATE_MUL_WAIT  = 4;
localparam STATE_DIV_START = 5;
localparam STATE_DIV_WAIT  = 6;

input clk;

input  start;
output done;

input [2:0] op;

input [NUMBER_WIDTH - 1:0] a;
input [NUMBER_WIDTH - 1:0] b;

output reg [NUMBER_WIDTH - 1:0] result;

wire [NUMBER_WIDTH - 1:0] fixed_point_add_result;

wire [NUMBER_WIDTH - 1:0] fixed_point_sub_result;

wire                      fixed_point_mul_start;
wire                      fixed_point_mul_done;
wire [NUMBER_WIDTH - 1:0] fixed_point_mul_result;

wire                      fixed_point_div_start;
wire                      fixed_point_div_done;
wire [NUMBER_WIDTH - 1:0] fixed_point_div_result;

reg [2:0] state;

assign done = (state == STATE_READY);

assign fixed_point_mul_start = (state == STATE_MUL_START);

assign fixed_point_div_start = (state == STATE_DIV_START);

fixed_point_add #(
    .INTEGER_PART_WIDTH    (INTEGER_PART_WIDTH),
    .FRACTIONAL_PART_WIDTH (FRACTIONAL_PART_WIDTH)
) fixed_point_add (
    .a      (a),
    .b      (b),
    .result (fixed_point_add_result)
);

fixed_point_sub #(
    .INTEGER_PART_WIDTH    (INTEGER_PART_WIDTH),
    .FRACTIONAL_PART_WIDTH (FRACTIONAL_PART_WIDTH)
) fixed_point_sub (
    .a      (a),
    .b      (b),
    .result (fixed_point_sub_result)
);

fixed_point_mul #(
    .INTEGER_PART_WIDTH    (INTEGER_PART_WIDTH),
    .FRACTIONAL_PART_WIDTH (FRACTIONAL_PART_WIDTH)
) fixed_point_mul (
    .clk    (clk),
    .start  (fixed_point_mul_start),
    .done   (fixed_point_mul_done),
    .a      (a),
    .b      (b),
    .result (fixed_point_mul_result)
);

fixed_point_div #(
    .INTEGER_PART_WIDTH    (INTEGER_PART_WIDTH),
    .FRACTIONAL_PART_WIDTH (FRACTIONAL_PART_WIDTH)
) fixed_point_div (
    .clk    (clk),
    .start  (fixed_point_div_start),
    .done   (fixed_point_div_done),
    .a      (a),
    .b      (b),
    .result (fixed_point_div_result)
);

initial begin
    result = 0;
    state  = STATE_READY;
end

// state
always @(posedge clk) begin
    case (state)
        STATE_READY: begin
            if (start) begin
                case (op)
                    OP_ADD: state <= STATE_ADD;
                    OP_SUB: state <= STATE_SUB;
                    OP_MUL: state <= STATE_MUL_START;
                    OP_DIV: state <= STATE_DIV_START;
                endcase
            end
        end
        STATE_ADD, STATE_SUB: state <= STATE_READY;
        STATE_MUL_START: state <= STATE_MUL_WAIT;
        STATE_MUL_WAIT: if (fixed_point_mul_done) state <= STATE_READY;
        STATE_DIV_START: state <= STATE_DIV_WAIT;
        STATE_DIV_WAIT: if (fixed_point_div_done) state <= STATE_READY;
    endcase
end

// result
always @(posedge clk) begin
    case (state)
        STATE_ADD: result <= fixed_point_add_result;
        STATE_SUB: result <= fixed_point_sub_result;
        STATE_MUL_WAIT: if (fixed_point_mul_done) result <= fixed_point_mul_result;
        STATE_DIV_WAIT: if (fixed_point_div_done) result <= fixed_point_div_result;
    endcase
end

endmodule
