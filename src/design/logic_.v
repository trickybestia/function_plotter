module logic_ (
    clk,

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

    swap,

    data,
    data_valid,

    instr_mem_write_enable,
    instr_mem_write_addr,
    instr_mem_write_data
);

parameter INTEGER_PART_WIDTH    = 11;
parameter FRACTIONAL_PART_WIDTH = 8;

parameter HOR_ACTIVE_PIXELS = 640;
parameter VER_ACTIVE_PIXELS = 480;
parameter SYMBOL_WIDTH      = 7;

localparam NUMBER_WIDTH = INTEGER_PART_WIDTH + FRACTIONAL_PART_WIDTH;

localparam SM_OUTPUT_QUEUE_SIZE  = 64;
localparam SM_OUTPUT_QUEUE_WIDTH = NUMBER_WIDTH + 1;

localparam X_WIDTH = $clog2(HOR_ACTIVE_PIXELS);
localparam Y_WIDTH = $clog2(VER_ACTIVE_PIXELS);

localparam INSTRUCTION_WIDTH          = 16;
localparam INSTRUCTION_MEM_SIZE       = 1024;
localparam INSTRUCTION_MEM_ADDR_WIDTH = $clog2(INSTRUCTION_MEM_SIZE);

localparam DATA_WIDTH          = 16;
localparam DATA_MEM_SIZE       = 1024;
localparam DATA_MEM_ADDR_WIDTH = $clog2(DATA_MEM_SIZE);

localparam STATE_READY = 0;
localparam STATE_WORK  = 1;

input clk;

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

input [7:0] data;
input       data_valid;

input                                    instr_mem_write_enable;
input [INSTRUCTION_MEM_ADDR_WIDTH - 1:0] instr_mem_write_addr;
input [INSTRUCTION_WIDTH - 1:0]          instr_mem_write_data;

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

// keyboard_accel_adapter
wire                      keyboard_can_read;
wire                      keyboard_can_write;
wire [SYMBOL_WIDTH - 1:0] keyboard_read_data;

// fixed_point_alu_accel_adapter
wire        alu_accel_can_read;
wire        alu_accel_can_write;
wire [15:0] alu_accel_read_data;

// stack_machine_accel_adapter
wire        sm_accel_can_read;
wire        sm_accel_can_write;
wire [15:0] sm_accel_read_data;

// data_fifo
wire        data_fifo_accel_can_read;
wire        data_fifo_accel_can_write;
wire [15:0] data_fifo_accel_read_data;

// stack_machine
wire                                          sm_start;
wire                                          sm_ready;
wire [X_WIDTH - 1:0]                          sm_x_input;
wire [Y_WIDTH - 1:0]                          sm_y_output;
wire                                          sm_skip_pixel;
wire [$clog2(SM_OUTPUT_QUEUE_SIZE) - 1:0]     sm_output_queue_index;
wire                                          sm_output_queue_get;
wire [$clog2(SM_OUTPUT_QUEUE_SIZE + 1) - 1:0] sm_output_queue_length;
wire [SM_OUTPUT_QUEUE_WIDTH - 1:0]            sm_output_queue_data_out;
wire                                          sm_output_queue_ready;

// fixed_point_alu
wire                      alu_start;
wire                      alu_done;
wire [2:0]                alu_op;
wire [NUMBER_WIDTH - 1:0] alu_a;
wire [NUMBER_WIDTH - 1:0] alu_b;
wire [NUMBER_WIDTH - 1:0] alu_result;

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

// accel_id = 4
keyboard_accel_adapter #(
    .SYMBOL_WIDTH (SYMBOL_WIDTH)
) keyboard_accel_adapter (
    .clk (clk),
    
    .accel_can_read     (keyboard_can_read),
    .accel_can_write    (keyboard_can_write),
    .accel_read_enable  (accel_id == 4 && accel_read_enable),
    .accel_write_enable (accel_id == 4 && accel_write_enable),
    .accel_read_data    (keyboard_read_data),
    .accel_write_data   (accel_write_data),

    .keyboard_symbol (keyboard_symbol)
);

// accel_id = 5
fixed_point_alu_accel_adapter #(
    .INTEGER_PART_WIDTH    (INTEGER_PART_WIDTH),
    .FRACTIONAL_PART_WIDTH (FRACTIONAL_PART_WIDTH)
) fixed_point_alu_accel_adapter (
    .clk (clk),

    .accel_can_read     (alu_accel_can_read),
    .accel_can_write    (alu_accel_can_write),
    .accel_read_enable  (accel_id == 5 && accel_read_enable),
    .accel_write_enable (accel_id == 5 && accel_write_enable),
    .accel_read_data    (alu_accel_read_data),
    .accel_write_data   (accel_write_data),

    .alu_start  (alu_start),
    .alu_done   (alu_done),
    .alu_op     (alu_op),
    .alu_a      (alu_a),
    .alu_b      (alu_b),
    .alu_result (alu_result)
);

// accel_id = 6
stack_machine_accel_adapter #(
    .INTEGER_PART_WIDTH    (INTEGER_PART_WIDTH),
    .FRACTIONAL_PART_WIDTH (FRACTIONAL_PART_WIDTH),
    .OUTPUT_QUEUE_SIZE     (SM_OUTPUT_QUEUE_SIZE),
    .HOR_ACTIVE_PIXELS     (HOR_ACTIVE_PIXELS),
    .VER_ACTIVE_PIXELS     (VER_ACTIVE_PIXELS)
) stack_machine_accel_adapter (
    .clk (clk),

    .accel_can_read     (sm_accel_can_read),
    .accel_can_write    (sm_accel_can_write),
    .accel_read_enable  (accel_id == 6 && accel_read_enable),
    .accel_write_enable (accel_id == 6 && accel_write_enable),
    .accel_read_data    (sm_accel_read_data),
    .accel_write_data   (accel_write_data),

    .sm_start                 (sm_start),
    .sm_ready                 (sm_ready),
    .sm_x_input               (sm_x_input),
    .sm_y_output              (sm_y_output),
    .sm_skip_pixel            (sm_skip_pixel),
    .sm_output_queue_index    (sm_output_queue_index),
    .sm_output_queue_get      (sm_output_queue_get),
    .sm_output_queue_length   (sm_output_queue_length),
    .sm_output_queue_data_out (sm_output_queue_data_out),
    .sm_output_queue_ready    (sm_output_queue_ready)
);

// accel_id = 7
fifo_accel_adapter #(
    .DATA_WIDTH (8),
    .PTR_WIDTH  (10)
) data_fifo (
    .clk (clk),

    .accel_can_read     (data_fifo_accel_can_read),
    .accel_can_write    (data_fifo_accel_can_write),
    .accel_read_enable  (accel_id == 7 && accel_read_enable),
    .accel_write_enable (accel_id == 7 && accel_write_enable),
    .accel_read_data    (data_fifo_accel_read_data),
    .accel_write_data   (accel_write_data),

    .data_in       (data),
    .data_in_valid (data_valid)
);

stack_machine #(
    .INTEGER_PART_WIDTH    (INTEGER_PART_WIDTH),
    .FRACTIONAL_PART_WIDTH (FRACTIONAL_PART_WIDTH),
    .OUTPUT_QUEUE_SIZE     (SM_OUTPUT_QUEUE_SIZE),
    .HOR_ACTIVE_PIXELS     (HOR_ACTIVE_PIXELS),
    .VER_ACTIVE_PIXELS     (VER_ACTIVE_PIXELS)
) stack_machine (
    .clk                   (clk),
    .start                 (sm_start),
    .ready                 (sm_ready),
    .x_input               (sm_x_input),
    .y_output              (sm_y_output),
    .skip_pixel            (sm_skip_pixel),
    .output_queue_index    (sm_output_queue_index),
    .output_queue_get      (sm_output_queue_get),
    .output_queue_length   (sm_output_queue_length),
    .output_queue_data_out (sm_output_queue_data_out),
    .output_queue_ready    (sm_output_queue_ready)
);

fixed_point_alu #(
    .INTEGER_PART_WIDTH    (INTEGER_PART_WIDTH),
    .FRACTIONAL_PART_WIDTH (FRACTIONAL_PART_WIDTH)
) fixed_point_alu (
    .clk    (clk),
    .start  (alu_start),
    .done   (alu_done),
    .op     (alu_op),
    .a      (alu_a),
    .b      (alu_b),
    .result (alu_result)
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

    .write_enable (instr_mem_write_enable),
    .write_addr   (instr_mem_write_addr),
    .write_data   (instr_mem_write_data),

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
    .rst                   (cpu_rst | instr_mem_write_enable),
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
        4: accel_can_read = keyboard_can_read;
        5: accel_can_read = alu_accel_can_read;
        6: accel_can_read = sm_accel_can_read;
        7: accel_can_read = data_fifo_accel_can_read;
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
        4: accel_can_write = keyboard_can_write;
        5: accel_can_write = alu_accel_can_write;
        6: accel_can_write = sm_accel_can_write;
        7: accel_can_write = data_fifo_accel_can_write;
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
        4: accel_read_data = keyboard_read_data;
        5: accel_read_data = alu_accel_read_data;
        6: accel_read_data = sm_accel_read_data;
        7: accel_read_data = data_fifo_accel_read_data;
        default: ;
    endcase
end

// cpu_rst
always @(posedge clk) begin
    cpu_rst <= instr_mem_write_enable;
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
