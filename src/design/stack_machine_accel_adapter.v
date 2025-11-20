module stack_machine_accel_adapter (
    clk,

    accel_can_read,
    accel_can_write,
    accel_read_enable,
    accel_write_enable,
    accel_read_data,
    accel_write_data,

    // stack machine
    sm_start,
    sm_ready,
    sm_x_input,
    sm_y_output,
    sm_skip_pixel,
    sm_output_queue_index,
    sm_output_queue_get,
    sm_output_queue_length,
    sm_output_queue_data_out,
    sm_output_queue_ready
);

parameter INTEGER_PART_WIDTH     = 8;
parameter FRACTIONAL_PART_WIDTH  = 8;
parameter OUTPUT_QUEUE_SIZE      = 64;
parameter HOR_ACTIVE_PIXELS      = 640;
parameter VER_ACTIVE_PIXELS      = 480;

localparam X_WIDTH = $clog2(HOR_ACTIVE_PIXELS);
localparam Y_WIDTH = $clog2(VER_ACTIVE_PIXELS);

localparam NUMBER_WIDTH       = INTEGER_PART_WIDTH + FRACTIONAL_PART_WIDTH;
localparam OUTPUT_QUEUE_WIDTH = NUMBER_WIDTH + 1;

localparam STATE_READ_OUTPUT_QUEUE_ITEM_TYPE       = 0;
localparam STATE_READ_OUTPUT_QUEUE_ITEM_INTEGER    = 1;
localparam STATE_READ_OUTPUT_QUEUE_ITEM_FRACTIONAL = 2;
localparam STATE_READ_X                            = 3;
localparam STATE_START                             = 4;
localparam STATE_WORK                              = 5;
localparam STATE_WRITE_Y                           = 6;

input clk;

output        accel_can_read;
output        accel_can_write;
input         accel_read_enable;
input         accel_write_enable;
output [15:0] accel_read_data;
input  [15:0] accel_write_data;

output                                           sm_start;
input                                            sm_ready;
output reg [X_WIDTH - 1:0]                       sm_x_input;
input      [Y_WIDTH - 1:0]                       sm_y_output;
input                                            sm_skip_pixel;
input      [$clog2(OUTPUT_QUEUE_SIZE) - 1:0]     sm_output_queue_index;
input                                            sm_output_queue_get;
output reg [$clog2(OUTPUT_QUEUE_SIZE + 1) - 1:0] sm_output_queue_length;
output reg [OUTPUT_QUEUE_WIDTH - 1:0]            sm_output_queue_data_out;
output                                           sm_output_queue_ready;

reg [OUTPUT_QUEUE_WIDTH - 1:0] output_queue [0:OUTPUT_QUEUE_SIZE - 1];

reg [2:0] state;

reg                            output_queue_item_type;
reg [INTEGER_PART_WIDTH - 1:0] output_queue_item_integer;

assign accel_can_read  = (state == STATE_WRITE_Y);
assign accel_can_write = (state == STATE_READ_OUTPUT_QUEUE_ITEM_TYPE || state == STATE_READ_OUTPUT_QUEUE_ITEM_INTEGER || state == STATE_READ_OUTPUT_QUEUE_ITEM_FRACTIONAL || state == STATE_READ_X);
assign accel_read_data = sm_skip_pixel ? {16{1'b1}} : sm_y_output;

assign sm_start              = (state == STATE_START);
assign sm_output_queue_ready = 1;

initial begin
    state                  = STATE_READ_OUTPUT_QUEUE_ITEM_TYPE;
    sm_output_queue_length = 0;
end

// state
always @(posedge clk) begin
    case (state)
        STATE_READ_OUTPUT_QUEUE_ITEM_TYPE: begin
            if (accel_write_enable) begin
                if (accel_write_data[1]) begin
                    state <= STATE_READ_OUTPUT_QUEUE_ITEM_INTEGER;
                end else begin
                    state <= STATE_READ_X;
                end
            end
        end
        STATE_READ_OUTPUT_QUEUE_ITEM_INTEGER: begin
            if (accel_write_enable) begin
                state <= STATE_READ_OUTPUT_QUEUE_ITEM_FRACTIONAL;
            end
        end
        STATE_READ_OUTPUT_QUEUE_ITEM_FRACTIONAL: begin
            if (accel_write_enable) begin
                state <= STATE_READ_OUTPUT_QUEUE_ITEM_TYPE;
            end
        end
        STATE_READ_X: begin
            if (accel_write_enable) begin
                if (accel_write_data == {16{1'b1}}) begin
                    state <= STATE_READ_OUTPUT_QUEUE_ITEM_TYPE;
                end else begin
                    state <= STATE_START;
                end
            end
        end
        STATE_START: state <= STATE_WORK;
        STATE_WORK: begin
            if (sm_ready) begin
                state <= STATE_WRITE_Y;
            end
        end
        STATE_WRITE_Y: begin
            if (accel_read_enable) begin
                state <= STATE_READ_X;
            end
        end
    endcase
end

// output_queue_item_type
always @(posedge clk) begin
    if (state == STATE_READ_OUTPUT_QUEUE_ITEM_TYPE && accel_write_enable && accel_write_data[1]) begin
        output_queue_item_type <= accel_write_data[0];
    end
end

// output_queue_item_integer
always @(posedge clk) begin
    if (state == STATE_READ_OUTPUT_QUEUE_ITEM_INTEGER && accel_write_enable) begin
        output_queue_item_integer <= accel_write_data;
    end
end

// sm_output_queue_length
always @(posedge clk) begin
    case (state)
        STATE_READ_OUTPUT_QUEUE_ITEM_FRACTIONAL: begin
            if (accel_write_enable) begin
                sm_output_queue_length <= sm_output_queue_length + 1;
            end
        end
        STATE_READ_X: begin
            if (accel_write_enable && accel_write_data == {16{1'b1}}) begin
                sm_output_queue_length <= 0;
            end
        end
    endcase
end

// sm_x_input
always @(posedge clk) begin
    if (state == STATE_READ_X && accel_write_enable) begin
        sm_x_input <= accel_write_data;
    end
end

// output_queue, sm_output_queue_data_out
always @(posedge clk) begin
    if (state == STATE_READ_OUTPUT_QUEUE_ITEM_FRACTIONAL && accel_write_enable) begin
        output_queue[sm_output_queue_length - 1] <= {output_queue_item_type, output_queue_item_integer, accel_write_data[0+:FRACTIONAL_PART_WIDTH]};
    end else if (sm_output_queue_get) begin
        sm_output_queue_data_out <= output_queue[sm_output_queue_index];
    end
end

endmodule
