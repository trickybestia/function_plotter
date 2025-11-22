module fifo_accel_adapter (
    clk,

    accel_can_read,
    accel_can_write,
    accel_read_enable,
    accel_write_enable,
    accel_read_data,
    accel_write_data,

    data_in,
    data_in_valid
);

parameter DATA_WIDTH = 8;
parameter PTR_WIDTH = 10;

input clk;

output        accel_can_read;
output        accel_can_write;
input         accel_read_enable;
input         accel_write_enable;
output [15:0] accel_read_data;
input  [15:0] accel_write_data;

input [DATA_WIDTH - 1:0] data_in;
input                    data_in_valid;

reg [PTR_WIDTH - 1:0] write_ptr;
reg [PTR_WIDTH - 1:0] read_ptr;

reg [DATA_WIDTH - 1:0] mem [0:2**PTR_WIDTH - 1];

assign accel_read_data = mem[read_ptr];
assign accel_can_read  = (read_ptr != write_ptr);

assign accel_can_write = 0;

initial begin
    write_ptr = 0;
    read_ptr  = 0;
end

// write_ptr
always @(posedge clk) begin
    if (write_ptr + 1 != read_ptr && data_in_valid) begin
        write_ptr <= write_ptr + 1;
    end
end

// read_ptr
always @(posedge clk) begin
    if (accel_can_read && accel_read_enable) begin
        read_ptr <= read_ptr + 1;
    end
end

// mem
always @(posedge clk) begin
    if (write_ptr + 1 != read_ptr && data_in_valid) begin
        mem[write_ptr] <= data_in;
    end
end

endmodule
