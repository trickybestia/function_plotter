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

reg active_buffer;

reg buffer_0 [0:TOTAL_PIXELS - 1];
reg buffer_1 [0:TOTAL_PIXELS - 1];

assign read_data = active_buffer ? buffer_1[read_addr] : buffer_0[read_addr];

initial begin
    active_buffer = 0;
end

// active_buffer
always @(posedge clk) begin
    if (swap) active_buffer <= ~active_buffer;
end

// buffer_0, buffer_1
always @(posedge clk) begin
    if (write_enable) begin
        if (active_buffer) buffer_1[write_addr] <= write_data;
        else               buffer_0[write_addr] <= write_data;
    end
end

endmodule
