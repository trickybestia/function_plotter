module cpu_instr_mem_writer (
    clk,

    data_in,
    data_in_valid,

    instr_mem_write_enable,
    instr_mem_write_addr,
    instr_mem_write_data
);

parameter INSTRUCTION_WIDTH    = 16;
parameter INSTRUCTION_MEM_SIZE = 1024;

localparam INSTRUCTION_MEM_ADDR_WIDTH = $clog2(INSTRUCTION_MEM_SIZE);

localparam STATE_IDLE           = 0;
localparam STATE_READ_INSTR_MSB = 1;
localparam STATE_READ_INSTR_LSB = 2;

input clk;

input [7:0] data_in;
input       data_in_valid;

output                                        instr_mem_write_enable;
output reg [INSTRUCTION_MEM_ADDR_WIDTH - 1:0] instr_mem_write_addr;
output     [INSTRUCTION_WIDTH - 1:0]          instr_mem_write_data;

reg [1:0] state;

reg [7:0] instr_msb;

assign instr_mem_write_enable = (state != STATE_IDLE);
assign instr_mem_write_data   = {instr_msb, data_in};

initial begin
    state = STATE_IDLE;
end

// state
always @(posedge clk) begin
    case (state)
        STATE_IDLE:           if (data_in_valid) state <= STATE_READ_INSTR_LSB;
        STATE_READ_INSTR_MSB: if (data_in_valid) state <= STATE_READ_INSTR_LSB;
        STATE_READ_INSTR_LSB: begin
            if (data_in_valid) begin
                if (instr_mem_write_addr == INSTRUCTION_MEM_SIZE - 1) begin
                    state <= STATE_IDLE;
                end else begin
                    state <= STATE_READ_INSTR_MSB;
                end
            end
        end
    endcase
end

// instr_mem_write_addr
always @(posedge clk) begin
    if (state == STATE_READ_INSTR_LSB && data_in_valid) begin
        if (instr_mem_write_addr == INSTRUCTION_MEM_SIZE - 1) begin
            instr_mem_write_addr <= 0;
        end else begin
            instr_mem_write_addr <= instr_mem_write_addr + 1;
        end
    end
end

// instr_msb
always @(posedge clk) begin
    if (state == STATE_READ_INSTR_MSB && data_in_valid) begin
        instr_msb <= data_in;
    end
end

endmodule
