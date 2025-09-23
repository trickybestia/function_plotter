module input_buffer (
    clk,

    left_in,
    right_in,
    backspace_in,
    symbol_in,
    
    left_out,
    right_out,
    backspace_out,
    symbol_out,
    out_ready
);

parameter SYMBOL_WIDTH = 7;

input clk;

input                      left_in;
input                      right_in;
input                      backspace_in;
input [SYMBOL_WIDTH - 1:0] symbol_in;

output reg                      left_out;
output reg                      right_out;
output reg                      backspace_out;
output reg [SYMBOL_WIDTH - 1:0] symbol_out;
input                           out_ready;

wire out_valid = left_out | right_out | backspace_out | (symbol_out != 0);

initial begin
    left_out      = 0;
    right_out     = 0;
    backspace_out = 0;
    symbol_out    = 0;
end

always @(posedge clk) begin
    if ((~out_valid) | (out_valid & out_ready)) begin
        left_out      <= left_in;
        right_out     <= right_in;
        backspace_out <= backspace_in;
        symbol_out    <= symbol_in;
    end
end

endmodule
