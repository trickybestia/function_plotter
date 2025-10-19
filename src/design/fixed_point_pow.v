// Computes a ** b, expecting b to be non-negative number.
// b's fractional part is currently ignored.
module fixed_point_pow (
    clk,

    start,
    done,

    a,
    b,

    result
);

parameter INTEGER_PART_WIDTH    = 8;
parameter FRACTIONAL_PART_WIDTH = 8;

localparam NUMBER_WIDTH = INTEGER_PART_WIDTH + FRACTIONAL_PART_WIDTH;

localparam MAX_POSITIVE_NUMBER = 2 ** (NUMBER_WIDTH - 1) - 1;
localparam MIN_NEGATIVE_NUMBER = -MAX_POSITIVE_NUMBER - 1;

localparam STATE_READY            = 0;
localparam STATE_CHECK_POWER_ZERO = 1;
localparam STATE_START_MUL        = 2;
localparam STATE_WAIT_MUL         = 3;

input clk;

input  start;
output done;

input signed [NUMBER_WIDTH - 1:0] a;
input signed [NUMBER_WIDTH - 1:0] b;

output reg signed [NUMBER_WIDTH - 1:0] result;

reg signed [NUMBER_WIDTH - 1:0]       value;
reg        [INTEGER_PART_WIDTH - 1:0] power;

reg [1:0] state;

wire                             value_mul_start = (state == STATE_START_MUL);
wire                             value_mul_done;
wire signed [NUMBER_WIDTH - 1:0] value_mul_a     = value;
wire signed [NUMBER_WIDTH - 1:0] value_mul_b     = value;
wire signed [NUMBER_WIDTH - 1:0] value_mul_result;

wire                             result_mul_start = (state == STATE_START_MUL && power[0]);
wire                             result_mul_done;
wire signed [NUMBER_WIDTH - 1:0] result_mul_a     = result;
wire signed [NUMBER_WIDTH - 1:0] result_mul_b     = value;
wire signed [NUMBER_WIDTH - 1:0] result_mul_result;

assign done = (state == STATE_READY);

fixed_point_mul #(
    .INTEGER_PART_WIDTH    (INTEGER_PART_WIDTH),
    .FRACTIONAL_PART_WIDTH (FRACTIONAL_PART_WIDTH)
) value_mul (
    .clk    (clk),
    .start  (value_mul_start),
    .done   (value_mul_done),
    .a      (value_mul_a),
    .b      (value_mul_b),
    .result (value_mul_result)
);

fixed_point_mul #(
    .INTEGER_PART_WIDTH    (INTEGER_PART_WIDTH),
    .FRACTIONAL_PART_WIDTH (FRACTIONAL_PART_WIDTH)
) result_mul (
    .clk    (clk),
    .start  (result_mul_start),
    .done   (result_mul_done),
    .a      (result_mul_a),
    .b      (result_mul_b),
    .result (result_mul_result)
);

initial begin
    result = {NUMBER_WIDTH{1'b0}};
    state  = STATE_READY;
    value  = {NUMBER_WIDTH{1'b0}};
    power  = 0;
end

// state
always @(posedge clk) begin
    case (state)
        STATE_READY:            state <= start ? STATE_CHECK_POWER_ZERO : STATE_READY;
        STATE_CHECK_POWER_ZERO: state <= (power == 0) ? STATE_READY : STATE_START_MUL;
        STATE_START_MUL:        state <= STATE_WAIT_MUL;
        STATE_WAIT_MUL: begin
            if (value_mul_done && result_mul_done) begin
                if (power == 0) state <= STATE_READY;
                else            state <= STATE_START_MUL;
            end
        end
    endcase
end

// value
always @(posedge clk) begin
    case (state)
        STATE_READY: begin
            if (start) begin
                value <= a;
            end
        end
        STATE_WAIT_MUL: begin
            if (value_mul_done && result_mul_done) begin
                value <= value_mul_result;
            end
        end
    endcase
end

// power
always @(posedge clk) begin
    case (state)
        STATE_READY: begin
            if (start) begin
                power <= b[NUMBER_WIDTH - 1-:INTEGER_PART_WIDTH];
            end
        end
        STATE_START_MUL: begin
            power <= power >> 1;
        end
    endcase
end

// result
always @(posedge clk) begin
    case (state)
        STATE_READY: begin
            if (start) begin
                result <= 1 << FRACTIONAL_PART_WIDTH;
            end
        end
        STATE_WAIT_MUL: begin
            if (value_mul_done && result_mul_done) begin
                result <= result_mul_result;
            end
        end
    endcase
end

endmodule
