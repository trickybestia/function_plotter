module symbol_drawer_mem (
    addr,

    out
);

parameter SIZE = 123456;

localparam ADDR_WIDTH = $clog2(SIZE);

input  [ADDR_WIDTH - 1:0] addr;
output                    out;

reg [0:0] mem [0:SIZE - 1];

assign out = mem[addr];

`ifdef SYNTHESIS
initial begin
    $readmemb("../../../src/symbol_drawer_mem.mem", mem);
end
`else
initial begin
    $readmemb("../../../../../src/symbol_drawer_mem.mem", mem);
end
`endif


endmodule
