module fixed_point_div (
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

localparam COUNTER_WIDTH = $clog2(NUMBER_WIDTH + FRACTIONAL_PART_WIDTH + 1);

input clk;

input      start;
output reg done;

input signed [NUMBER_WIDTH - 1:0] a;
input signed [NUMBER_WIDTH - 1:0] b;

output reg signed [NUMBER_WIDTH - 1:0] result;

reg [NUMBER_WIDTH + FRACTIONAL_PART_WIDTH:0] a_abs_reg;
reg [NUMBER_WIDTH:0]                         b_abs_reg;
reg                                          result_sign; // 0 - positive, 1 - negative

reg [NUMBER_WIDTH + FRACTIONAL_PART_WIDTH:0] quotient, next_quotient;
reg [NUMBER_WIDTH + FRACTIONAL_PART_WIDTH:0] remainder, next_remainder;

reg [COUNTER_WIDTH - 1:0] counter;

initial begin
    done        = 1;
    a_abs_reg   = {(NUMBER_WIDTH + FRACTIONAL_PART_WIDTH){1'b0}};
    b_abs_reg   = {NUMBER_WIDTH{1'b0}};
    result_sign = 0;
    quotient    = {(NUMBER_WIDTH + FRACTIONAL_PART_WIDTH){1'b0}};
    remainder   = {(NUMBER_WIDTH + FRACTIONAL_PART_WIDTH){1'b0}};
    counter     = NUMBER_WIDTH + FRACTIONAL_PART_WIDTH;
end

// result
// TODO: implement rounding by computing one more fractional digit of quotient
always @(*) begin
    if (result_sign) begin
        if (quotient > -MIN_NEGATIVE_NUMBER) result = MIN_NEGATIVE_NUMBER;
        else                                 result = -quotient;
    end else begin
        if (quotient > MAX_POSITIVE_NUMBER) result = MAX_POSITIVE_NUMBER;
        else                                result = quotient;
    end
end

// next_quotient, next_remainder
always @(*) begin
    next_quotient  = quotient;
    next_remainder = remainder;

    if (done) begin
        if (start) begin
            next_quotient  = {(NUMBER_WIDTH + FRACTIONAL_PART_WIDTH){1'b0}};
            next_remainder = {(NUMBER_WIDTH + FRACTIONAL_PART_WIDTH){1'b0}};
        end
    end else begin
        next_remainder = {next_remainder, a_abs_reg[counter]};

        if (next_remainder >= b_abs_reg) begin
            next_quotient[counter] = 1;
            next_remainder         = next_remainder - b_abs_reg;
        end
    end
end

// done
always @(posedge clk) begin
    if (done)              done <= !start;
    else if (counter == 0) done <= 1;
end

// a_abs_reg
always @(posedge clk) begin
    if (done && start) begin
        a_abs_reg <= ((a < 0) ? -a : a) << FRACTIONAL_PART_WIDTH;
    end
end

// b_abs_reg
always @(posedge clk) begin
    if (done && start) begin
        b_abs_reg <= (b < 0) ? -b : b;
    end
end

// result_sign
always @(posedge clk) begin
    if (done && start) result_sign <= (a < 0) ^ (b < 0);
end

// quotient
always @(posedge clk) begin
    quotient <= next_quotient;
end

// remainder
always @(posedge clk) begin
    remainder <= next_remainder;
end

// counter
always @(posedge clk) begin
    if (!done) begin
        if (counter == 0) counter <= NUMBER_WIDTH + FRACTIONAL_PART_WIDTH;
        else              counter <= counter - 1;
    end
end

endmodule
