`timescale 1ns / 1ps

module logic_tb;

localparam SYMBOL_WIDTH       = 7;
localparam OUTPUT_QUEUE_SIZE  = 64;
localparam INTEGER_PART_WIDTH     = 8;
localparam FRACTIONAL_PART_WIDTH  = 8;

localparam NUMBER_WIDTH           = INTEGER_PART_WIDTH + FRACTIONAL_PART_WIDTH;
localparam OUTPUT_VALUE_WIDTH     = NUMBER_WIDTH + 1;

localparam HOR_ACTIVE_PIXELS = 640;
localparam VER_ACTIVE_PIXELS = 480;
localparam X_WIDTH           = $clog2(HOR_ACTIVE_PIXELS);
localparam Y_WIDTH           = $clog2(VER_ACTIVE_PIXELS);

reg  clk, start;
wire ready;

wire [X_WIDTH - 1:0] x1;
wire [Y_WIDTH - 1:0] y1;
wire [X_WIDTH - 1:0] x2;
wire [Y_WIDTH - 1:0] y2;

wire line_drawer_start;
reg  line_drawer_ready;

wire                      symbol_iter_en;
reg  [SYMBOL_WIDTH - 1:0] symbol;
reg                       symbol_valid;

logic logic (
    .clk               (clk),
    .start             (start),
    .ready             (ready),
    .x1                (x1),
    .y1                (y1),
    .x2                (x2),
    .y2                (y2),
    .line_drawer_start (line_drawer_start),
    .line_drawer_ready (line_drawer_ready),
    .symbol_iter_en    (symbol_iter_en),
    .symbol            (symbol),
    .symbol_valid      (symbol_valid)
);

always begin
    clk = 1'b0;
    #5;
    clk = 1'b1;
    #5;
end

initial begin
   start             = 0;
   line_drawer_ready = 1;
   symbol_valid      = 0;

   #200;
   start <= 1;
   
   #200;
   start <= 0;
   
   symbol <= "1";
   symbol_valid <= 1;
   #10;
   symbol_valid <= 0;

   #200;   
   symbol <= "*";
   symbol_valid <= 1;
   #10;
   symbol_valid <= 0;

   #200;
   symbol <= "2";
   symbol_valid <= 1;
   #10;
   symbol_valid <= 0;   

   #200;
   symbol <= "+";
   symbol_valid <= 1;
   #10;
   symbol_valid <= 0;

   #200;
   symbol <= "3";
   symbol_valid <= 1;
   #10;
   symbol_valid <= 0;

   #200;
   symbol <= 0;
   symbol_valid <= 1;
   #10;
   symbol_valid <= 0;

   #1000000;   
   
   $finish;
end   
   
endmodule   

/* -----\/----- EXCLUDED -----\/-----
`timescale 1ns / 1ps

module logic_tb;

reg clk;

reg  fill_drawer_start;
wire fill_drawer_ready;

wire line_drawer_start;
wire line_drawer_ready;

reg  logic_start;
wire logic_ready;

wire [9:0] x1;
wire [8:0] y1;
wire [9:0] x2;
wire [8:0] y2;

wire        fill_drawer_write_enable;
wire [18:0] fill_drawer_write_addr;
wire        fill_drawer_write_data;

wire        line_drawer_write_enable;
wire [18:0] line_drawer_write_addr;
wire        line_drawer_write_data;  

wire        write_enable;
wire [18:0] write_addr;
wire        write_data;

reg  [18:0] read_addr;
wire        read_data;

reg swap;

assign write_enable = fill_drawer_write_enable | line_drawer_write_enable;
assign write_addr   = fill_drawer_write_addr | line_drawer_write_addr;
assign write_data   = fill_drawer_write_data | line_drawer_write_data;

fill_drawer fill_drawer (
    .clk          (clk),
    .start        (fill_drawer_start),
    .ready        (fill_drawer_ready),
    .write_enable (fill_drawer_write_enable),
    .write_addr   (fill_drawer_write_addr),
    .write_data   (fill_drawer_write_data)
);

line_drawer line_drawer (
    .clk          (clk),
    .start        (line_drawer_start),
    .ready        (line_drawer_ready),
    .x1           (x1),
    .y1           (y1),
    .x2           (x2),
    .y2           (y2),
    .write_enable (line_drawer_write_enable),
    .write_addr   (line_drawer_write_addr),
    .write_data   (line_drawer_write_data)
);

frame_buffer frame_buffer (
    .clk          (clk),
    .write_enable (write_enable),
    .write_addr   (write_addr),
    .write_data   (write_data),
    .read_addr    (read_addr),
    .read_data    (read_data),
    .swap         (swap)
);

task dump_frame_buffer;
    integer x;
    integer y;
    integer file;

    begin
        file = $fopen("frame_buffer.txt", "w");

        for (y = 0; y != 480; y = y + 1) begin
            for (x = 0; x != 640; x = x + 1) begin
                read_addr = y * 640 + x;
                @(posedge clk);
                $fwrite(file, read_data);
            end

            $fwrite(file, "\n");
        end

        $fclose(file);
    end
endtask

always begin
    clk = 1'b0;
    #5;
    clk = 1'b1;
    #5;
end

initial begin
    fill_drawer_start       = 0;
    logic_start             = 0;
    read_addr               = 0;
    swap                    = 0;

    @(posedge clk);
    @(posedge clk);

    swap <= 1;
    @(posedge clk);
    swap <= 0;
    @(posedge clk);

    fill_drawer_start <= 1;
    @(posedge clk);
    fill_drawer_start <= 0;
    @(posedge clk);

    while (~fill_drawer_ready) @(posedge clk);

    logic_start <= 1;
    @(posedge clk);
    logic_start <= 0;
    @(posedge clk);

    while (~logic_ready) @(posedge clk);

    swap <= 1;
    @(posedge clk);
    swap <= 0;
    @(posedge clk);

    dump_frame_buffer();
    // run
    // python utils/show_frame_buffer_txt.py vivado_project/function_plotter.sim/logic_tb/behav/xsim/frame_buffer.txt
    // from project root to see frame buffer content

    repeat (10) @(posedge clk);

    $finish;
end

endmodule
 -----/\----- EXCLUDED -----/\----- */
