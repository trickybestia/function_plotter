module symbol_drawer_mem (
    addr,

    out
);

parameter SIZE = 123456;

localparam ADDR_WIDTH = $clog2(SIZE);

input  [ADDR_WIDTH - 1:0] addr;
output                    out;

reg mem [0:SIZE - 1];

assign out = mem[addr];

initial begin
    $readmemb("../../../../../src/symbol_drawer_mem.mem", mem); // 99% this path will be different on synthesis
end

endmodule
