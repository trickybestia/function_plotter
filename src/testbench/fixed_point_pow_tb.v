`timescale 1ns / 1ps

module fixed_point_pow_tb;

parameter INTEGER_PART_WIDTH    = 3;
parameter FRACTIONAL_PART_WIDTH = 2;

localparam NUMBER_WIDTH = INTEGER_PART_WIDTH + FRACTIONAL_PART_WIDTH;

reg clk;

reg  start;
wire done;

reg signed [NUMBER_WIDTH - 1:0] a;
reg signed [NUMBER_WIDTH - 1:0] b;

wire signed [NUMBER_WIDTH - 1:0] result;

fixed_point_pow #(
    .INTEGER_PART_WIDTH    (INTEGER_PART_WIDTH),
    .FRACTIONAL_PART_WIDTH (FRACTIONAL_PART_WIDTH)
) uut (
    .clk    (clk),
    .start  (start),
    .done   (done),
    .a      (a),
    .b      (b),
    .result (result)
);

task test;
    input signed [NUMBER_WIDTH - 1:0] a_;
    input signed [NUMBER_WIDTH - 1:0] b_;

    begin
        a <= a_;
        b <= b_;

        start <= 1;
        @(posedge clk);
        start <= 0;
        @(posedge clk);

        while (!done) @(posedge clk);
    end
endtask

always begin
    clk = 1'b0;
    #5;
    clk = 1'b1;
    #5;
end

integer file;

integer i;
integer j;

initial begin
    file = $fopen("fixed_point_pow_tb.log", "w");

    a     = 0;
    b     = 0;
    start = 0;

    // Test if nothing breaks on idle
    @(posedge clk);
    @(posedge clk);
    @(posedge clk);

    for (i = 0; i != 2 ** NUMBER_WIDTH; i = i + 1) begin
        for (j = 0; j != 2 ** NUMBER_WIDTH; j = j + 1) begin
            test(i, j);

            $fdisplay(file, "a: %0d, b: %0d, result: %0d", $unsigned(a), $unsigned(b), $unsigned(result));
        end
    end

    // Test if nothing breaks on idle
    @(posedge clk);
    @(posedge clk);
    @(posedge clk);
    
    $fclose(file);

    $finish;
end

endmodule
