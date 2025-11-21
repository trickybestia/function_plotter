module uart_rx (
    clk,
    rst,

    data,
    data_valid,

    rx
);

parameter CLK_FREQUENCY_HZ = 100_000_000;
parameter BAUD_RATE        = 9600;

localparam BITS_COUNT        = 1 + 8 + 1; // start + data [7:0] + stop
localparam COUNTER_MAX_VALUE = CLK_FREQUENCY_HZ * BITS_COUNT / BAUD_RATE - 1;
localparam COUNTER_WIDTH     = $clog2(COUNTER_MAX_VALUE);

input clk;
input rst;

output reg [7:0] data;
output           data_valid;

input rx;

reg [COUNTER_WIDTH - 1:0] counter;

reg [1:0] rx_prev;

assign data_valid = (counter == COUNTER_MAX_VALUE);

initial begin
    counter = 0;
    rx_prev = 2'b11;
end

// counter
always @(posedge clk) begin
    if (rst) begin
        counter <= 0;
    end else begin
        if (counter == 0) begin
            if (!rx_prev[1]) begin
                counter <= counter + 1;
            end
        end else if (counter == COUNTER_MAX_VALUE) begin
            counter <= 0;
        end else begin
            counter <= counter + 1;
        end
    end
end

// data
always @(posedge clk) begin
    case (counter)
        CLK_FREQUENCY_HZ * 3 / 2 / BAUD_RATE,
        CLK_FREQUENCY_HZ * 5 / 2 / BAUD_RATE,
        CLK_FREQUENCY_HZ * 7 / 2 / BAUD_RATE,
        CLK_FREQUENCY_HZ * 9 / 2 / BAUD_RATE,
        CLK_FREQUENCY_HZ * 11 / 2 / BAUD_RATE,
        CLK_FREQUENCY_HZ * 13 / 2 / BAUD_RATE,
        CLK_FREQUENCY_HZ * 15 / 2 / BAUD_RATE,
        CLK_FREQUENCY_HZ * 17 / 2 / BAUD_RATE: begin
            data <= {rx_prev[1], data[7:1]};
        end
    endcase
end

// rx_prev
always @(posedge clk) begin
    if (rst) begin
        rx_prev <= 2'b11;
    end else begin
        rx_prev <= {rx_prev[0], rx};
    end
end

endmodule
