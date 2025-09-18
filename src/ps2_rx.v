module ps2_rx (
    input clk,
    
    input rx_clk,
    input rx,
    
    output reg [15:0] key,
    output reg        key_pressed, // 1 если кнопка нажата, 0 если отпущена
    output reg        new_key      // переходит в 1 на один такт, когда считана новая клавиша
);

localparam STATE_IDLE = 0,
           STATE_WAIT_ONE_BYTE_KEY_RELEASE = 1,
           STATE_WAIT_TWO_BYTE_KEY_PRESS = 2,
           STATE_WAIT_TWO_BYTE_KEY_RELEASE = 3;

reg [1:0] state;

wire [7:0] rx_data;
wire       rx_new_data;

ps2_raw_rx ps2_raw_rx_inst (
    .clk(clk),
    .rx_clk(rx_clk),
    .rx(rx),
    .data(rx_data),
    .new_data(rx_new_data)
);

initial begin
    state <= STATE_IDLE;
    
    key         <= 0;
    key_pressed <= 0;
    new_key     <= 0;
end

always @(posedge clk) begin
    new_key <= 0;
    
    if (rx_new_data) case (state)
        STATE_IDLE: begin
            case (rx_data)
                8'hF0: state <= STATE_WAIT_ONE_BYTE_KEY_RELEASE;
                8'hE0: state <= STATE_WAIT_TWO_BYTE_KEY_PRESS;
                default: begin
                    key         <= rx_data;
                    key_pressed <= 1;
                    new_key     <= 1;
                end
            endcase
        end
        STATE_WAIT_ONE_BYTE_KEY_RELEASE: begin
            key         <= rx_data;
            key_pressed <= 0;
            new_key     <= 1;
            
            state <= STATE_IDLE;
        end
        STATE_WAIT_TWO_BYTE_KEY_PRESS: begin
            if (rx_data == 8'hF0) begin
                state <= STATE_WAIT_TWO_BYTE_KEY_RELEASE;
            end else begin
                key         <= {8'hE0, rx_data};
                key_pressed <= 1;
                new_key     <= 1;
                
                state <= STATE_IDLE;
            end
        end
        STATE_WAIT_TWO_BYTE_KEY_RELEASE: begin
            key         <= {8'hE0, rx_data};
            key_pressed <= 0;
            new_key     <= 1;
            
            state <= STATE_IDLE;
        end
    endcase
end

endmodule