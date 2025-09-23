module ps2_raw_rx (
    input clk,
    
    input rx_clk,
    input rx,
    
    output reg [7:0] data,
    output reg       new_data // переходит в 1 на один такт, когда считана новая клавиша
);

localparam STATE_IDLE = 0, STATE_RECEIVE_DATA = 1, STATE_RECEIVE_PARITY = 2, STATE_RECEIVE_STOP_BIT = 3;

reg [1:0] state;

reg [2:0] rx_clk_sync;
reg [2:0] rx_sync;

reg       parity_valid;
reg       rx_buffer_parity;
reg [7:0] rx_buffer;
reg [2:0] rx_count;

initial begin
    rx_clk_sync <= 3'b111;
    rx_sync     <= 3'b111;
    
    state <= STATE_IDLE;
    
    parity_valid     <= 0;
    rx_buffer_parity <= 1;
    rx_buffer        <= 0;
    rx_count         <= 0;
    
    data     <= 0;
    new_data <= 0;
end

always @(posedge clk) begin
    rx_clk_sync <= (rx_clk_sync << 1) | rx_clk;
    rx_sync     <= (rx_sync << 1) | rx;
end

always @(posedge clk) begin
    new_data <= 0;
     
    if (rx_clk_sync[2] == 1 && rx_clk_sync[1] == 0)
    case (state)
        STATE_IDLE: begin
            parity_valid     <= 0;
            rx_buffer_parity <= 1;
            rx_buffer        <= 0;
            rx_count         <= 0;
        
            state <= rx_sync[1] == 0 ? STATE_RECEIVE_DATA : STATE_IDLE;
        end
        STATE_RECEIVE_DATA: begin
            rx_buffer        <= {rx_sync[1], rx_buffer[7:1]};
            rx_buffer_parity <= rx_buffer_parity ^ rx_sync[1];
            rx_count         <= rx_count + 1;
            
            state <= rx_count == 7 ? STATE_RECEIVE_PARITY : STATE_RECEIVE_DATA;
        end
        STATE_RECEIVE_PARITY: begin
            parity_valid <= rx_sync[1] == rx_buffer_parity;
            
            state <= STATE_RECEIVE_STOP_BIT; 
        end
        STATE_RECEIVE_STOP_BIT: begin
            if (rx_sync[1] && parity_valid) begin
                data     <= rx_buffer;
                new_data <= 1;
            end
            
            state <= STATE_IDLE;
        end
    endcase
end

endmodule