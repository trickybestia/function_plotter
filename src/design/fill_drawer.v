module fill_drawer (
    clk,
    
    start,
    ready,
    
    write_enable,
    write_addr,
    write_data
);

parameter PIXELS_COUNT     = 640 * 480;
parameter COLOR            = 0;
parameter WRITE_DATA_WIDTH = 1;

localparam WRITE_ADDR_WIDTH = $clog2(PIXELS_COUNT);

localparam STATE_READY = 0;
localparam STATE_WORK  = 1;

input clk;

input  start;
output ready;

output                          write_enable;
output [WRITE_ADDR_WIDTH - 1:0] write_addr;
output [WRITE_DATA_WIDTH - 1:0] write_data;

reg state;

reg [WRITE_ADDR_WIDTH - 1:0] write_addr_reg;

assign ready = (state == STATE_READY);

assign write_enable = (state == STATE_WORK);
assign write_addr   = write_enable ? write_addr_reg : 0;
assign write_data   = write_enable ? COLOR : 0;

initial begin
    state          = STATE_READY;
    write_addr_reg = 0;
end

// write_addr_reg
always @(posedge clk) begin
    if (state == STATE_WORK) begin
        write_addr_reg <= (write_addr_reg == PIXELS_COUNT - 1) ? 0 : write_addr_reg + 1;
    end
end

// state
always @(posedge clk) begin
    case (state)
        STATE_READY: begin
            if (start) state <= STATE_WORK;
        end
        STATE_WORK: begin
            if (write_addr_reg == PIXELS_COUNT - 1) state <= STATE_READY;
        end
    endcase
end

endmodule
