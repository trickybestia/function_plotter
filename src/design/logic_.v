module logic_ (
    clk,

    start,
    ready,

    x1,
    y1,
    x2,
    y2,
    line_drawer_start,
    line_drawer_ready,

    symbol_iter_en,
    symbol,
    symbol_valid
);

parameter HOR_ACTIVE_PIXELS = 640;
parameter VER_ACTIVE_PIXELS = 480;
parameter SYMBOL_WIDTH      = 7;

localparam X_WIDTH = $clog2(HOR_ACTIVE_PIXELS);
localparam Y_WIDTH = $clog2(VER_ACTIVE_PIXELS);

localparam INSTRUCTION_WIDTH          = 16;
localparam INSTRUCTION_MEM_SIZE       = 128;
localparam INSTRUCTION_MEM_ADDR_WIDTH = $clog2(INSTRUCTION_MEM_SIZE);

localparam DATA_WIDTH          = 16;
localparam DATA_MEM_SIZE       = 16;
localparam DATA_MEM_ADDR_WIDTH = $clog2(DATA_MEM_SIZE);

localparam STATE_READY = 0;
localparam STATE_WORK  = 1;

input clk;

input  start;
output ready;

output [X_WIDTH - 1:0] x1;
output [Y_WIDTH - 1:0] y1;
output [X_WIDTH - 1:0] x2;
output [Y_WIDTH - 1:0] y2;
output                 line_drawer_start;
input                  line_drawer_ready;

output                      symbol_iter_en;
input  [SYMBOL_WIDTH - 1:0] symbol;
input                       symbol_valid;

// cpu_instr_mem
wire [INSTRUCTION_MEM_ADDR_WIDTH - 1:0] instr_mem_addr;
wire [INSTRUCTION_WIDTH - 1:0]          instr_mem_data_0;
wire [INSTRUCTION_WIDTH - 1:0]          instr_mem_data_1;

// cpu_data_mem
wire [DATA_MEM_ADDR_WIDTH - 1:0] data_mem_addr;
wire [DATA_WIDTH - 1:0]          data_mem_read_data;
wire                             data_mem_write_enable;
wire [DATA_WIDTH - 1:0]          data_mem_write_data;

// accelerators
wire  [3:0] accel_id;
reg         accel_can_read;
reg         accel_can_write;
wire        accel_read_enable;
wire        accel_write_enable;
reg  [15:0] accel_read_data;
wire [15:0] accel_write_data;

// line_drawer_accel_adapter
wire        line_drawer_can_read;
wire        line_drawer_can_write;
wire [15:0] line_drawer_read_data;

// cpu
reg cpu_rst;

reg state;

assign ready = (state == STATE_READY);

assign symbol_iter_en = 0;

// accel_id = 1
line_drawer_accel_adapter line_drawer_accel_adapter (
    .clk                (clk),
    .accel_can_read     (line_drawer_can_read),
    .accel_can_write    (line_drawer_can_write),
    .accel_read_enable  (accel_id == 1 && accel_read_enable),
    .accel_write_enable (accel_id == 1 && accel_write_enable),
    .accel_read_data    (line_drawer_read_data),
    .accel_write_data   (accel_write_data),
    .line_drawer_start  (line_drawer_start),
    .line_drawer_ready  (line_drawer_ready),
    .line_drawer_x1     (x1),
    .line_drawer_y1     (y1),
    .line_drawer_x2     (x2),
    .line_drawer_y2     (y2)
);

cpu_instr_mem #(
    .DATA_WIDTH (INSTRUCTION_WIDTH),
    .SIZE       (INSTRUCTION_MEM_SIZE),
`ifdef SYNTHESIS
    .INIT_FILE  ("../../../model/cpu/compiled_examples/compiled_program.mem")
`else
    .INIT_FILE  ("../../../../../model/cpu/compiled_examples/compiled_program.mem")
`endif
) cpu_instr_mem (
    .clk    (clk),
    .addr   (instr_mem_addr),
    .data_0 (instr_mem_data_0),
    .data_1 (instr_mem_data_1)
);

cpu_data_mem #(
    .DATA_WIDTH (DATA_WIDTH),
    .SIZE       (DATA_MEM_SIZE),
    .ADDR_WIDTH (DATA_MEM_ADDR_WIDTH)
) cpu_data_mem (
    .clk          (clk),
    .addr         (data_mem_addr),
    .read_data    (data_mem_read_data),
    .write_enable (data_mem_write_enable),
    .write_data   (data_mem_write_data)
);

cpu cpu (
    .clk                   (clk),
    .rst                   (cpu_rst),
    .instr_mem_addr        (instr_mem_addr),
    .instr_mem_data_0      (instr_mem_data_0),
    .instr_mem_data_1      (instr_mem_data_1),
    .data_mem_addr         (data_mem_addr),
    .data_mem_read_data    (data_mem_read_data),
    .data_mem_write_enable (data_mem_write_enable),
    .data_mem_write_data   (data_mem_write_data),
    .accel_id              (accel_id),
    .accel_can_read        (accel_can_read),
    .accel_can_write       (accel_can_write),
    .accel_read_enable     (accel_read_enable),
    .accel_read_data       (accel_read_data),
    .accel_write_enable    (accel_write_enable),
    .accel_write_data      (accel_write_data)
);

initial begin
    state   = STATE_READY;
    cpu_rst = 1;
end

// accel_can_read
always @(*) begin
    accel_can_read = 0;

    case (accel_id)
        0: accel_can_read = (state == STATE_WORK);
        1: accel_can_read = line_drawer_can_read;
        default: ;
    endcase
end

// accel_can_write
always @(*) begin
    accel_can_write = 0;

    case (accel_id)
        0: accel_can_write = 1;
        1: accel_can_write = line_drawer_can_write;
        default: ;
    endcase
end

// accel_read_data
always @(*) begin
    accel_read_data = 0;

    case (accel_id)
        0: accel_read_data = 0;
        1: accel_read_data = line_drawer_read_data;
        default: ;
    endcase
end

// cpu_rst
always @(posedge clk) begin
    cpu_rst <= 0;
end

// state
always @(posedge clk) begin
    case (state)
        STATE_READY: if (start) state <= STATE_WORK;
        STATE_WORK:  if (accel_id == 0 && accel_write_enable) state <= STATE_READY;
    endcase
end

endmodule
