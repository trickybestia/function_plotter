`timescale 1ns / 1ps

module fill_drawer_tb;

reg clk;

reg  start;
wire ready;

wire       write_enable;
wire [2:0] write_addr;
wire       write_data;

fill_drawer #(
    .PIXELS_COUNT (5)
) uut (
    .clk          (clk),
    .start        (start),
    .ready        (ready),
    .write_enable (write_enable),
    .write_addr   (write_addr),
    .write_data   (write_data)
);

always begin
    clk = 1'b0;
    #5;
    clk = 1'b1;
    #5;
end

integer i;

initial begin
    start = 0;
    
    #20;
    
    for (i = 0; i != 3; i = i + 1) begin
        start = 1;
        
        #10;
        
        start = 0;
        
        while (!ready) #10;
        
        #10;
    end
    
    start = 1;
    
    #200;

    $finish;
end

endmodule
