module ps2 (
    clk,
    
    ps2_clk,
    ps2_dat,
    
    left,
    right,
    backspace,
    symbol
);

input clk;

input ps2_clk;
input ps2_dat;

output           left;
output           right;
output           backspace;
output reg [5:0] symbol;

wire [15:0] key;
wire        key_pressed;
wire        new_key;

assign left      = new_key & key_pressed & (key == 16'hE06B);
assign right     = new_key & key_pressed & (key == 16'hE074);
assign backspace = new_key & key_pressed & (key == 16'h0066);

ps2_rx ps2_rx (
    .clk         (clk),
    .rx_clk      (ps2_clk),
    .rx          (ps2_dat),
    .key         (key),
    .key_pressed (key_pressed),
    .new_key     (new_key)
);

always @(*) begin
    symbol = 0;
    
    if (new_key & key_pressed) begin
        case (key)
        
        endcase
    end
end

endmodule
