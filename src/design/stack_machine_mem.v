module stack_machine_mem (
    clk,

    a_addr,
    a_write_enable,
    a_write_data,
    a_read_data,

    b_addr,
    b_read_data
);

parameter DATA_WIDTH = 16;
parameter SIZE       = 64;

localparam ADDR_WIDTH = $clog2(SIZE);

input clk;

input      [ADDR_WIDTH - 1:0] a_addr;
input                         a_write_enable;
input      [DATA_WIDTH - 1:0] a_write_data;
output reg [DATA_WIDTH - 1:0] a_read_data;

input      [ADDR_WIDTH - 1:0] b_addr;
output reg [DATA_WIDTH - 1:0] b_read_data;

reg [DATA_WIDTH - 1:0] mem [0:SIZE - 1];

// mem, a_read_data
always @(posedge clk) begin
    if (a_write_enable) begin
        mem[a_addr] <= a_write_data;
    end else begin
        a_read_data <= mem[a_addr];
    end
end

// b_read_data
always @(posedge clk) begin
    b_read_data <= mem[b_addr];
end

endmodule
