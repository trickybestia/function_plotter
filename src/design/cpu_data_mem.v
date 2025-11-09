module cpu_data_mem (
    clk,

    addr,
    read_data,
    write_enable,
    write_data
);

parameter DATA_WIDTH = 16;
parameter SIZE       = 1024;
parameter ADDR_WIDTH = $clog2(SIZE);

input clk;

input      [ADDR_WIDTH - 1:0] addr;
output reg [DATA_WIDTH - 1:0] read_data;
input                         write_enable;
input      [DATA_WIDTH - 1:0] write_data;

reg [DATA_WIDTH - 1:0] mem [0:SIZE - 1];

// mem, read_data
always @(posedge clk) begin
    if (write_enable) mem[addr] <= write_data;
    else              read_data <= mem[addr];
end

endmodule
