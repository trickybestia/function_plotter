`timescale 1ns / 1ps

module fixed_point_sub_tb;

parameter INTEGER_PART_WIDTH    = 3;
parameter FRACTIONAL_PART_WIDTH = 2;

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

integer file;

integer i;
integer j;

initial begin
    file = $fopen("fixed_point_sub_tb.log", "w");

    for (i = 0; i != 2 ** NUMBER_WIDTH; i = i + 1) begin
        for (j = 0; j != 2 ** NUMBER_WIDTH; j = j + 1) begin
            a = i;
            b = j;

            #10;

            $fdisplay(file, "a: %0d, b: %0d, result: %0d", $unsigned(a), $unsigned(b), $unsigned(result));
        end
    end

    $fclose(file);

    $finish;
end

endmodule
