module frame_buffer (
    clk,

    write_enable,
    write_addr,
    write_data,

    read_addr,
    read_data,

    swap
);

parameter HOR_ACTIVE_PIXELS = 640;
parameter VER_ACTIVE_PIXELS = 480;

localparam TOTAL_PIXELS = HOR_ACTIVE_PIXELS * VER_ACTIVE_PIXELS;
localparam ADDR_WIDTH   = $clog2(TOTAL_PIXELS);

input clk;

input                    write_enable;
input [ADDR_WIDTH - 1:0] write_addr;
input                    write_data;

input  [ADDR_WIDTH - 1:0] read_addr;
output                    read_data;

input swap;

wire buffer_0_read_data;
wire buffer_1_read_data;

reg active_buffer;

assign read_data = active_buffer ? buffer_1_read_data : buffer_0_read_data;

frame_buffer_mem #(
    .SIZE (TOTAL_PIXELS)
) buffer_0 (
    .clk          (clk),
    .write_enable (write_enable & (active_buffer == 0)),
    .write_addr   (write_addr),
    .write_data   (write_data),
    .read_addr    (read_addr),
    .read_data    (buffer_0_read_data)
);

frame_buffer_mem #(
    .SIZE (TOTAL_PIXELS)
) buffer_1 (
    .clk          (clk),
    .write_enable (write_enable & (active_buffer == 1)),
    .write_addr   (write_addr),
    .write_data   (write_data),
    .read_addr    (read_addr),
    .read_data    (buffer_1_read_data)
);

initial begin
    active_buffer = 0;
end

// active_buffer
always @(posedge clk) begin
    if (swap) active_buffer <= ~active_buffer;
end

endmodule
