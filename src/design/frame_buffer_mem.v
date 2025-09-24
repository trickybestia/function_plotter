module frame_buffer_mem (
    clk,

    write_enable,
    write_addr,
    write_data,

    read_addr,
    read_data
);

parameter SIZE = 640 * 480;

localparam ADDR_WIDTH = $clog2(SIZE);

input clk;

input                    write_enable;
input [ADDR_WIDTH - 1:0] write_addr;
input                    write_data;

input      [ADDR_WIDTH - 1:0] read_addr;
output reg                    read_data;

reg mem [0:SIZE - 1];

initial begin
    read_data = 0;
end

always @(posedge clk) begin
    if (write_enable) mem[write_addr] <= write_data;
    else              read_data       <= mem[read_addr];
end

endmodule
