module logic_ (
    clk,

    keyboard_left,
    keyboard_right,
    keyboard_backspace,
    keyboard_symbol,

    line_drawer_x1,
    line_drawer_y1,
    line_drawer_x2,
    line_drawer_y2,
    line_drawer_start,
    line_drawer_ready,

    symbol_drawer_x,
    symbol_drawer_y,
    symbol_drawer_symbol,
    symbol_drawer_cursor_left,
    symbol_drawer_cursor_right,
    symbol_drawer_start,
    symbol_drawer_ready,

    fill_drawer_start,
    fill_drawer_ready,

    swap
);

parameter HOR_ACTIVE_PIXELS = 640;
parameter VER_ACTIVE_PIXELS = 480;
parameter SYMBOL_WIDTH      = 7;

localparam X_WIDTH = $clog2(HOR_ACTIVE_PIXELS);
localparam Y_WIDTH = $clog2(VER_ACTIVE_PIXELS);

localparam INSTRUCTION_WIDTH          = 16;
localparam INSTRUCTION_MEM_SIZE       = 1024;
localparam INSTRUCTION_MEM_ADDR_WIDTH = $clog2(INSTRUCTION_MEM_SIZE);

localparam DATA_WIDTH          = 16;
localparam DATA_MEM_SIZE       = 256;
localparam DATA_MEM_ADDR_WIDTH = $clog2(DATA_MEM_SIZE);

localparam STATE_READY = 0;
localparam STATE_WORK  = 1;

input clk;

input                      keyboard_left;
input                      keyboard_right;
input                      keyboard_backspace;
input [SYMBOL_WIDTH - 1:0] keyboard_symbol;

output [X_WIDTH - 1:0] line_drawer_x1;
output [Y_WIDTH - 1:0] line_drawer_y1;
output [X_WIDTH - 1:0] line_drawer_x2;
output [Y_WIDTH - 1:0] line_drawer_y2;
output                 line_drawer_start;
input                  line_drawer_ready;

output [X_WIDTH - 1:0]      symbol_drawer_x;
output [Y_WIDTH - 1:0]      symbol_drawer_y;
output [SYMBOL_WIDTH - 1:0] symbol_drawer_symbol;
output                      symbol_drawer_cursor_left;
output                      symbol_drawer_cursor_right;
output                      symbol_drawer_start;
input                       symbol_drawer_ready;

output fill_drawer_start;
input  fill_drawer_ready;

input swap;

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

// symbol_drawer_accel_adapter
wire        symbol_drawer_can_read;
wire        symbol_drawer_can_write;
wire [15:0] symbol_drawer_read_data;

// cpu
reg cpu_rst;

reg swap_pending;

assign fill_drawer_start = fill_drawer_ready && accel_id == 2 && accel_write_enable;

// accel_id = 1
line_drawer_accel_adapter line_drawer_accel_adapter (
    .clk (clk),

    .accel_can_read     (line_drawer_can_read),
    .accel_can_write    (line_drawer_can_write),
    .accel_read_enable  (accel_id == 1 && accel_read_enable),
    .accel_write_enable (accel_id == 1 && accel_write_enable),
    .accel_read_data    (line_drawer_read_data),
    .accel_write_data   (accel_write_data),

    .line_drawer_start (line_drawer_start),
    .line_drawer_ready (line_drawer_ready),
    .line_drawer_x1    (line_drawer_x1),
    .line_drawer_y1    (line_drawer_y1),
    .line_drawer_x2    (line_drawer_x2),
    .line_drawer_y2    (line_drawer_y2)
);

// accel_id = 3
symbol_drawer_accel_adapter symbol_drawer_accel_adapter (
    .clk (clk),

    .accel_can_read     (symbol_drawer_can_read),
    .accel_can_write    (symbol_drawer_can_write),
    .accel_read_enable  (accel_id == 3 && accel_read_enable),
    .accel_write_enable (accel_id == 3 && accel_write_enable),
    .accel_read_data    (symbol_drawer_read_data),
    .accel_write_data   (accel_write_data),

    .symbol_drawer_start        (symbol_drawer_start),
    .symbol_drawer_ready        (symbol_drawer_ready),
    .symbol_drawer_x            (symbol_drawer_x),
    .symbol_drawer_y            (symbol_drawer_y),
    .symbol_drawer_symbol       (symbol_drawer_symbol),
    .symbol_drawer_cursor_left  (symbol_drawer_cursor_left),
    .symbol_drawer_cursor_right (symbol_drawer_cursor_right)
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
    cpu_rst      = 1;
    swap_pending = 1;
end

// accel_can_read
always @(*) begin
    accel_can_read = 0;

    case (accel_id)
        0: accel_can_read = swap_pending;
        1: accel_can_read = line_drawer_can_read;
        2: accel_can_read = 0;
        3: accel_can_read = symbol_drawer_can_read;
        default: ;
    endcase
end

// accel_can_write
always @(*) begin
    accel_can_write = 0;

    case (accel_id)
        0: accel_can_write = 0;
        1: accel_can_write = line_drawer_can_write;
        2: accel_can_write = fill_drawer_ready;
        3: accel_can_write = symbol_drawer_can_write;
        default: ;
    endcase
end

// accel_read_data
always @(*) begin
    accel_read_data = 0;

    case (accel_id)
        0: accel_read_data = 0;
        1: accel_read_data = line_drawer_read_data;
        2: accel_read_data = 0;
        3: accel_read_data = symbol_drawer_read_data;
        default: ;
    endcase
end

// cpu_rst
always @(posedge clk) begin
    cpu_rst <= 0;
end

// swap_pending
always @(posedge clk) begin
    if (swap) begin
        swap_pending <= 1;
    end else if (accel_id == 0 && accel_read_enable) begin
        swap_pending <= 0;
    end
end

endmodule
