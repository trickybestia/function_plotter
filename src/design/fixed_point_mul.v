module fixed_point_mul (
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

localparam COUNTER_WIDTH = $clog2(NUMBER_WIDTH);

input clk;

input      start;
output reg done;

input signed [NUMBER_WIDTH - 1:0] a;
input signed [NUMBER_WIDTH - 1:0] b;

output reg signed [NUMBER_WIDTH - 1:0] result;

reg [NUMBER_WIDTH:0] a_abs_reg;
reg [NUMBER_WIDTH:0] b_abs_reg;
reg                  result_sign; // 0 - positive, 1 - negative

reg [2 * NUMBER_WIDTH:0] full_precision_result_abs;

reg [COUNTER_WIDTH - 1:0] counter;

wire [2 * NUMBER_WIDTH - FRACTIONAL_PART_WIDTH:0] full_precision_result_abs_rounded = full_precision_result_abs[2 * NUMBER_WIDTH:FRACTIONAL_PART_WIDTH] + full_precision_result_abs[FRACTIONAL_PART_WIDTH - 1];

initial begin
    done                      = 1;
    a_abs_reg                 = {NUMBER_WIDTH{1'b0}};
    b_abs_reg                 = {NUMBER_WIDTH{1'b0}};
    result_sign               = 0;
    full_precision_result_abs = {(2 * NUMBER_WIDTH + 1){1'b0}};
    counter                   = 0;
end

// result
always @(*) begin
    if (result_sign) begin
        if (full_precision_result_abs_rounded > -MIN_NEGATIVE_NUMBER) begin
            result = MIN_NEGATIVE_NUMBER;
        end else begin
            result = -full_precision_result_abs_rounded;
        end
    end else begin
        if (full_precision_result_abs_rounded > MAX_POSITIVE_NUMBER) begin
            result = MAX_POSITIVE_NUMBER;
        end else begin
            result = full_precision_result_abs_rounded;
        end
    end
end

// done
always @(posedge clk) begin
    if (done)                             done <= !start;
    else if (counter == NUMBER_WIDTH - 1) done <= 1;
end

// a_abs_reg
always @(posedge clk) begin
    if (done && start) begin
        a_abs_reg <= (a < 0) ? -a : a;
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

// full_precision_result_abs
always @(posedge clk) begin
    if (done) begin
        if (start) begin
            full_precision_result_abs <= {(2 * NUMBER_WIDTH + 1){1'b0}};
        end
    end else if (b_abs_reg[counter]) begin
        full_precision_result_abs <= full_precision_result_abs + (a_abs_reg << counter);
    end
end

// counter
always @(posedge clk) begin
    if (!done) begin
        if (counter == NUMBER_WIDTH - 1) counter <= 0;
        else                             counter <= counter + 1;
    end
end

endmodule
