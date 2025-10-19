module fixed_point_sub (
    a,
    b,

    result
);

parameter INTEGER_PART_WIDTH    = 8;
parameter FRACTIONAL_PART_WIDTH = 8;

localparam NUMBER_WIDTH = INTEGER_PART_WIDTH + FRACTIONAL_PART_WIDTH;

localparam MAX_POSITIVE_NUMBER = 2 ** (NUMBER_WIDTH - 1) - 1;
localparam MIN_NEGATIVE_NUMBER = -MAX_POSITIVE_NUMBER - 1;

input signed [NUMBER_WIDTH - 1:0] a;
input signed [NUMBER_WIDTH - 1:0] b;

output reg signed [NUMBER_WIDTH - 1:0] result;

wire signed [NUMBER_WIDTH:0] result_with_overflow;

assign result_with_overflow = a - b;

always @(*) begin
    if      (result_with_overflow < MIN_NEGATIVE_NUMBER) result = MIN_NEGATIVE_NUMBER;
    else if (result_with_overflow > MAX_POSITIVE_NUMBER) result = MAX_POSITIVE_NUMBER;
    else                                                 result = result_with_overflow;
end

endmodule
