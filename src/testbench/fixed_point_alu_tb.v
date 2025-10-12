`timescale 1ns / 1ps

module fixed_point_alu_tb;

parameter INTEGER_PART_WIDTH    = 2;
parameter FRACTIONAL_PART_WIDTH = 1;

localparam NUMBER_WIDTH = INTEGER_PART_WIDTH + FRACTIONAL_PART_WIDTH;

localparam OP_ADD = 3'b000;
localparam OP_SUB = 3'b001;
localparam OP_MUL = 3'b010;
localparam OP_DIV = 3'b011;
localparam OP_POW = 3'b100;

reg clk;

reg  start;
wire done;

reg [2:0] op;

reg signed [NUMBER_WIDTH - 1:0] a;
reg signed [NUMBER_WIDTH - 1:0] b;

wire signed [NUMBER_WIDTH - 1:0] result;

fixed_point_alu #(
    .INTEGER_PART_WIDTH    (INTEGER_PART_WIDTH),
    .FRACTIONAL_PART_WIDTH (FRACTIONAL_PART_WIDTH)
) uut (
    .clk    (clk),
    .start  (start),
    .done   (done),
    .op     (op),
    .a      (a),
    .b      (b),
    .result (result)
);

task test;
    input signed [NUMBER_WIDTH - 1:0] a_;
    input signed [NUMBER_WIDTH - 1:0] b_;
    input        [2:0]                op_;

    begin
        a  <= a_;
        b  <= b_;
        op <= op_;

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

integer i;
integer j;

initial begin
    start = 0;
    op    = 0;
    a     = 0;
    b     = 0;

    // Test if nothing breaks on idle
    @(posedge clk);
    @(posedge clk);
    @(posedge clk);

    for (i = 0; i != 2 ** NUMBER_WIDTH; i = i + 1) begin
        for (j = 0; j != 2 ** NUMBER_WIDTH; j = j + 1) begin
            test(i, j, OP_ADD);
            test(i, j, OP_SUB);
            test(i, j, OP_MUL);
        end
    end

    // Test if nothing breaks on idle
    @(posedge clk);
    @(posedge clk);
    @(posedge clk);

    $finish;
end

endmodule
