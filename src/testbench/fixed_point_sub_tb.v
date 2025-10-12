`timescale 1ns / 1ps

module fixed_point_sub_tb;

parameter INTEGER_PART_WIDTH    = 2;
parameter FRACTIONAL_PART_WIDTH = 1;

localparam NUMBER_WIDTH = INTEGER_PART_WIDTH + FRACTIONAL_PART_WIDTH;

reg signed [NUMBER_WIDTH - 1:0] a;
reg signed [NUMBER_WIDTH - 1:0] b;

wire signed [NUMBER_WIDTH - 1:0] result;

fixed_point_sub #(
    .INTEGER_PART_WIDTH    (INTEGER_PART_WIDTH),
    .FRACTIONAL_PART_WIDTH (FRACTIONAL_PART_WIDTH)
) uut (
    .a      (a),
    .b      (b),
    .result (result)
);

integer i;
integer j;

initial begin
    for (i = 0; i != 2 ** NUMBER_WIDTH; i = i + 1) begin
        for (j = 0; j != 2 ** NUMBER_WIDTH; j = j + 1) begin
            a = i;
            b = j;

            #10;
        end
    end

    $finish;
end

endmodule
