module cpu_instr_mem (
    clk,

    addr,
    data_0,
    data_1
);

parameter DATA_WIDTH = 16;
parameter SIZE       = 1024;
parameter ADDR_WIDTH = $clog2(SIZE);
parameter INIT_FILE  = "path_to_init_mem";

input clk;

input      [ADDR_WIDTH - 1:0] addr;
output reg [DATA_WIDTH - 1:0] data_0;
output reg [DATA_WIDTH - 1:0] data_1;

reg [DATA_WIDTH - 1:0] mem [0:SIZE - 1];

initial begin
    $readmemb(INIT_FILE, mem);
end

// data_0
always @(posedge clk) begin
    data_0 <= mem[addr];
end

// data_1
always @(posedge clk) begin
    data_1 <= mem[addr + 1];
end

endmodule
