`timescale 1ns / 1ps

module line_drawer_tb;

reg clk;

reg  start;
wire ready;

reg [2:0] x1;
reg [1:0] y1;
reg [2:0] x2;
reg [1:0] y2;

wire       write_enable;
wire [4:0] write_addr;
wire       write_data;

reg [31:0] screen;

line_drawer #(
    .HOR_ACTIVE_PIXELS (8),
    .VER_ACTIVE_PIXELS (4)
) uut (
    .clk          (clk),
    .start        (start),
    .ready        (ready),
    .x1           (x1),
    .y1           (y1),
    .x2           (x2),
    .y2           (y2),
    .write_enable (write_enable),
    .write_addr   (write_addr),
    .write_data   (write_data)
);

task display_screen;
    integer x;
    integer y;

    begin
        for (y = 0; y != 4; y = y + 1) begin
            for (x = 0; x != 8; x = x + 1) begin
                if (screen[y * 8 + x]) $write("■");
                else $write("□");
            end
            
            $display("");
        end
        
        $display("");
    end
endtask

task test;
    input integer x1_; // underscore postfix to distinct from uut.x1 port
    input integer y1_;
    input integer x2_;
    input integer y2_;
    
    begin
        x1 = x1_;
        y1 = y1_;
        x2 = x2_;
        y2 = y2_;
        
        start = 1;
        
        #10;
        
        start = 0;
        
        while (!ready) #10;
        
        $display("(%d, %d) -> (%d, %d)", x1_, y1_, x2_, y2_);
        display_screen();
        
        screen = 0;
    end
endtask

always begin
    clk = 1'b0;
    #5;
    clk = 1'b1;
    #5;
end

always @(posedge clk) begin
    if (write_enable) begin
        screen[write_addr] <= write_data;
    end
end

integer i;

integer x;
integer y;

initial begin
    start  = 0;
    x1     = 0;
    y1     = 0;
    x2     = 0;
    y2     = 0;
    screen = 0;
    
    #20;
    
    test(0, 0, 7, 0);
    test(7, 0, 7, 3);
    test(7, 3, 0, 3);
    test(0, 3, 0, 0);
    
    for (i = 0; i != 4; i = i + 1) test(0, 0, 7, i);
    for (i = 0; i != 8; i = i + 1) test(0, 0, i, 3);
    
    for (x = 0; x != 8; x = x + 1) begin
        for (y = 0; y != 4; y = y + 1) begin
            test (3, 1, x, y);
        end
    end

    $finish;
end

endmodule
