module symbol_drawer_mem_tb;

localparam SIZE = 38400;

localparam ADDR_WIDTH = $clog2(SIZE);

reg [ADDR_WIDTH - 1:0] addr;
wire                   out;

symbol_drawer_mem #(
    .SIZE (SIZE)
) uut (
    .addr (addr),
    .out  (out)
);

integer i;

initial begin
    for (i = 0; i != SIZE; i = i + 1) begin
        addr = i;
        #10;
    end

    $finish;
end

endmodule
