`timescale 1ns / 1ps

module vector_tb;

reg clk;

reg [2:0] index;

reg get;
reg insert;
reg remove;

reg  [7:0] data_in;
wire [7:0] data_out;

wire [2:0] length;

wire ready;

vector #(
    .DATA_WIDTH (8),
    .DATA_COUNT (7)
) uut (
    .clk      (clk),
    .index    (index),
    .get      (get),
    .insert   (insert),
    .remove   (remove),
    .data_in  (data_in),
    .data_out (data_out),
    .length   (length),
    .ready    (ready)
);

task print_vector;
    integer i;

    begin
        $write("%d [", length);
    
        for (i = 0; i != 7; i = i + 1) begin
            index <= i;
            get   <= 1;
            @(posedge clk);
            get <= 0;
            @(posedge clk);
            $write("%d, ", data_out);
        end
        
        get <= 0;
        
        $display("]");
    end
endtask

always begin
    clk = 1'b0;
    #5;
    clk = 1'b1;
    #5;
end

initial begin
    index   = 0;
    get     = 0;
    insert  = 0;
    remove  = 0;
    data_in = 0;
    
    @(posedge clk);
    @(posedge clk);
    
    // vector.insert(0, 10)
    insert  <= 1;
    index   <= 0;
    data_in <= 10;
    @(posedge clk);
    insert <= 0;
    @(posedge clk);
    while (~ready) @(posedge clk);
    
    // vector.insert(1, 20)
    insert  <= 1;
    index   <= 1;
    data_in <= 20;
    @(posedge clk);
    insert <= 0;
    @(posedge clk);
    while (~ready) @(posedge clk);
    
    // vector.insert(2, 30)
    insert  <= 1;
    index   <= 2;
    data_in <= 30;
    @(posedge clk);
    insert <= 0;
    @(posedge clk);
    while (~ready) @(posedge clk);
    
    // vector.insert(3, 40)
    insert  <= 1;
    index   <= 3;
    data_in <= 40;
    @(posedge clk);
    insert <= 0;
    @(posedge clk);
    while (~ready) @(posedge clk);
    
    // vector.insert(4, 50)
    insert  <= 1;
    index   <= 4;
    data_in <= 50;
    @(posedge clk);
    insert <= 0;
    @(posedge clk);
    while (~ready) @(posedge clk);
    
    // vector.insert(5, 60)
    insert  <= 1;
    index   <= 5;
    data_in <= 60;
    @(posedge clk);
    insert <= 0;
    @(posedge clk);
    while (~ready) @(posedge clk);
    
    // vector.insert(6, 70)
    insert  <= 1;
    index   <= 6;
    data_in <= 70;
    @(posedge clk);
    insert <= 0;
    @(posedge clk);
    while (~ready) @(posedge clk);
    
    print_vector();
    
    // vector.remove(0)
    remove <= 1;
    index  <= 0;
    @(posedge clk);
    remove <= 0;
    @(posedge clk);
    while (~ready) @(posedge clk);
    
    print_vector();
    
    // vector.insert(3, 99)
    insert  <= 1;
    index   <= 3;
    data_in <= 99;
    @(posedge clk);
    insert <= 0;
    @(posedge clk);
    while (~ready) @(posedge clk);
    
    print_vector();
    
    while (length != 0) begin
        // vector.remove(0)
        remove <= 1;
        index  <= 0;
        @(posedge clk);
        remove <= 0;
        @(posedge clk);
        while (~ready) @(posedge clk);
    end
    
    print_vector();
    
    #100;

    $finish;
end

endmodule