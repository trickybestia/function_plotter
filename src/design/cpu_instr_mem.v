module cpu_instr_mem (
    clk,

    write_enable,
    write_addr,
    write_data,

    addr,
    data_0,
    data_1
);

parameter DATA_WIDTH = 16;
parameter SIZE       = 1024;
parameter ADDR_WIDTH = $clog2(SIZE);
parameter INIT_FILE  = "";

input clk;

input                    write_enable;
input [ADDR_WIDTH - 1:0] write_addr;
input [DATA_WIDTH - 1:0] write_data;

input      [ADDR_WIDTH - 1:0] addr;
output reg [DATA_WIDTH - 1:0] data_0;
output reg [DATA_WIDTH - 1:0] data_1;

reg [DATA_WIDTH - 1:0] mem [0:SIZE - 1];

initial begin
    if (INIT_FILE != "") begin
        $readmemb(INIT_FILE, mem);
    end
end

// mem, data_0, data_1
always @(posedge clk) begin
    if (write_enable) begin
        mem[write_addr] <= write_data;
    end else begin
        data_0 <= mem[addr];
        data_1 <= mem[addr + 1];
    end
end

endmodule
