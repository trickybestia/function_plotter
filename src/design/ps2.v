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
output reg [6:0] symbol;

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

// symbol
always @(*) begin
    symbol = 0;
    
    if (new_key & key_pressed) begin
        // Technoblogy - PS2 Keyboard Scan Codes
        // http://www.technoblogy.com/show?4QEL
        case (key)
            16'h0016: symbol = "1";
            16'h001E: symbol = "2";
            16'h0026: symbol = "3";
            16'h0025: symbol = "4";
            16'h002E: symbol = "5";
            16'h0036: symbol = "6";
            16'h003D: symbol = "7";
            16'h003E: symbol = "8";
            16'h0046: symbol = "9";
            16'h0045: symbol = "0";
            16'h004E: symbol = "-";
            16'h0015: symbol = "q";
            16'h001D: symbol = "w";
            16'h0024: symbol = "e";
            16'h002D: symbol = "r";
            16'h002C: symbol = "t";
            16'h0035: symbol = "y";
            16'h003C: symbol = "u";
            16'h0043: symbol = "i";
            16'h0044: symbol = "o";
            16'h004D: symbol = "p";
            16'h0054: symbol = "[";
            16'h005B: symbol = "]";
            16'h001C: symbol = "a";
            16'h001B: symbol = "s";
            16'h0023: symbol = "d";
            16'h002B: symbol = "f";
            16'h0034: symbol = "g";
            16'h0033: symbol = "h";
            16'h003B: symbol = "j";
            16'h0042: symbol = "k";
            16'h004B: symbol = "l";
            16'h001A: symbol = "z";
            16'h0022: symbol = "x";
            16'h0021: symbol = "c";
            16'h002A: symbol = "v";
            16'h0032: symbol = "b";
            16'h0031: symbol = "n";
            16'h003A: symbol = "m";
            16'h0049: symbol = ".";
            16'h004A: symbol = "/";
            16'h0029: symbol = " ";
            16'hE04A: symbol = "/";
            16'h007C: symbol = "*";
            16'h007B: symbol = "-";
            16'h006C: symbol = "7";
            16'h0075: symbol = "8";
            16'h007D: symbol = "9";
            16'h0079: symbol = "+";
            16'h006B: symbol = "4";
            16'h0073: symbol = "5";
            16'h0074: symbol = "6";
            16'h0069: symbol = "1";
            16'h0072: symbol = "2";
            16'h007A: symbol = "3";
            16'h0070: symbol = "0";
            16'h0071: symbol = ".";
        endcase
    end
end

endmodule
