`timescale 1ns / 1ps

module text_buffer_tb;

reg clk;

reg       left;
reg       right;
reg       backspace;
reg [6:0] symbol;

wire       input_buffer_left_out;
wire       input_buffer_right_out;
wire       input_buffer_backspace_out;
wire [6:0] input_buffer_symbol_out;

wire input_ready;

reg        full_iter_start;
reg        visible_iter_start;
reg        iter_en;
wire [6:0] iter_out;
wire       iter_out_valid;
wire       cursor_left;
wire       cursor_right;

input_buffer #(
    .SYMBOL_WIDTH (7)
) input_buffer (
    .clk           (clk),
    .left_in       (left),
    .right_in      (right),
    .backspace_in  (backspace),
    .symbol_in     (symbol),
    .left_out      (input_buffer_left_out),
    .right_out     (input_buffer_right_out),
    .backspace_out (input_buffer_backspace_out),
    .symbol_out    (input_buffer_symbol_out),
    .out_ready     (input_ready)
);

text_buffer #(
    .SYMBOL_WIDTH  (7),
    .SYMBOLS_COUNT (127)
) uut (
    .clk                (clk),
    .left               (input_buffer_left_out),
    .right              (input_buffer_right_out),
    .backspace          (input_buffer_backspace_out),
    .symbol             (input_buffer_symbol_out),
    .input_ready        (input_ready),
    .full_iter_start    (full_iter_start),
    .visible_iter_start (visible_iter_start),
    .iter_en            (iter_en),
    .iter_out           (iter_out),
    .iter_out_valid     (iter_out_valid),
    .cursor_left        (cursor_left),
    .cursor_right       (cursor_right)
);

task wait_input_ready;
    while (~input_ready) @(posedge clk);
endtask

task automatic send_symbol;
    input [6:0] symbol_;

    begin
        symbol <= symbol_;
        @(posedge clk);
        symbol <= 0;

        wait_input_ready();
    end
endtask

task automatic print_text_buffer;
    reg loop_done;

    begin
        assign full_iter_start = ~iter_out_valid;
        iter_en <= 1;

        while (~iter_out_valid) @(posedge clk);

        deassign full_iter_start;
        loop_done = 0;

        while (~loop_done) begin
            if (iter_out_valid) begin
                if (cursor_left) $write("<");

                if (iter_out == 0) begin
                    loop_done = 1;
                    $write("NUL");

                    iter_en <= 0;
                end else begin
                    $write("%s", iter_out);
                end

                if (cursor_right) $write(">");
            end

            @(posedge clk);
        end

        $display("");

        @(posedge clk);
    end
endtask

always begin
    clk = 1'b0;
    #5;
    clk = 1'b1;
    #5;
end

initial begin
    left               = 0;
    right              = 0;
    backspace          = 0;
    symbol             = 0;
    full_iter_start    = 0;
    visible_iter_start = 0;
    iter_en            = 0;

    // Test if nothing breaks on idle
    @(posedge clk);
    @(posedge clk);
    @(posedge clk);

    // Expect empty text
    print_text_buffer();
    
    // Check inputs
    left <= 1;
    @(posedge clk);
    left <= 0;
    wait_input_ready();
    
    right <= 1;
    @(posedge clk);
    right <= 0;
    wait_input_ready();
    
    backspace <= 1;
    @(posedge clk);
    backspace <= 0;
    wait_input_ready();

    // Expect empty text
    print_text_buffer();
    
    // Simple insertion test
    send_symbol("a");

    print_text_buffer();

    send_symbol("b");
    send_symbol("c");
    send_symbol("d");

    // Manual iteration test
    full_iter_start <= 1;
    @(posedge clk);
    full_iter_start <= 0;

    @(posedge clk);
    @(posedge clk);
    @(posedge clk);

    iter_en <= 1;

    while (~iter_out_valid | iter_out != 0) @(posedge clk);

    @(posedge clk);
    @(posedge clk);

    // print_text_buffer test
    print_text_buffer();
    print_text_buffer();
    
    // request both input and iteration at the same time
    backspace <= 1;
    @(posedge clk);
    backspace <= 0;
    print_text_buffer();

    left <= 1;
    @(posedge clk);
    left <= 0;
    print_text_buffer();

    symbol <= "f";
    @(posedge clk);
    symbol <= 0;
    print_text_buffer();

    right <= 1;
    @(posedge clk);
    right <= 0;
    print_text_buffer();

    // Test if nothing breaks on idle
    @(posedge clk);
    @(posedge clk);
    @(posedge clk);

    $finish;
end

endmodule
