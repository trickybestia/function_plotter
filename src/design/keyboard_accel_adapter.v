module keyboard_accel_adapter (
    clk,

    accel_can_read,
    accel_can_write,
    accel_read_enable,
    accel_write_enable,
    accel_read_data,
    accel_write_data,

    keyboard_symbol
);

parameter SYMBOL_WIDTH = 7;

localparam PTR_WIDTH = 4;

input clk;

output        accel_can_read;
output        accel_can_write;
input         accel_read_enable;
input         accel_write_enable;
output [15:0] accel_read_data;
input  [15:0] accel_write_data;

input [SYMBOL_WIDTH - 1:0] keyboard_symbol;

reg [PTR_WIDTH - 1:0] write_ptr;
reg [PTR_WIDTH - 1:0] read_ptr;

reg [SYMBOL_WIDTH - 1:0] mem [0:2**PTR_WIDTH - 1];

assign accel_read_data = mem[read_ptr];
assign accel_can_read  = (read_ptr != write_ptr);

assign accel_can_write = 0;

initial begin
    write_ptr = 0;
    read_ptr  = 0;
end

// write_ptr
always @(posedge clk) begin
    if (write_ptr + 1 != read_ptr && keyboard_symbol != 0) begin
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
    if (write_ptr + 1 != read_ptr && keyboard_symbol != 0) begin
        mem[write_ptr] <= keyboard_symbol;
    end
end

endmodule
