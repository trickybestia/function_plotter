module vector (
    clk,
    
    index,
    
    // operations. only one operation must be selected
    get,
    insert,
    remove,
    
    data_in,
    data_out,
    
    length,
    
    ready
);

parameter DATA_WIDTH = 7;
parameter DATA_COUNT = 127;

localparam INDEX_WIDTH  = $clog2(DATA_COUNT);
localparam LENGTH_WIDTH = $clog2(DATA_COUNT + 1);

localparam STATE_READY        = 0;
localparam STATE_INSERT_READ  = 1;
localparam STATE_INSERT_WRITE = 2;
localparam STATE_INSERT_DONE  = 3;
localparam STATE_REMOVE_READ  = 4;
localparam STATE_REMOVE_WRITE = 5;
localparam STATE_REMOVE_DONE  = 6;

input clk;

input [INDEX_WIDTH - 1:0] index;

input get;
input insert;
input remove;

input      [DATA_WIDTH - 1:0] data_in;
output reg [DATA_WIDTH - 1:0] data_out;

output reg [LENGTH_WIDTH - 1:0] length;

output ready;

reg [DATA_WIDTH - 1:0] mem [0:DATA_COUNT - 1];

reg [2:0] state;

reg [LENGTH_WIDTH - 1:0] j;
reg [DATA_WIDTH - 1:0]   tmp;

assign ready = (state == STATE_READY);

reg get_;
reg insert_;
reg remove_;

initial begin
    data_out = 0;
    length   = 0;
    state    = STATE_READY;
    j        = 0;
    tmp      = 0;
end

// purpose of this block is to tell synthesizer to treat get, insert, remove
// signals as mutually exclusive, maybe it works, maybe not ¯\_(ツ)_/¯
always @(*) begin
    get_    = 0;
    insert_ = 0;
    remove_ = 0;

    casez ({get, insert, remove})
        3'b1??: get_    = 1;
        3'b?1?: insert_ = 1;
        3'b??1: remove_ = 1;
    endcase
    
    // uncomment to see difference in resource usage
    /*
    get_    = get;
    insert_ = insert;
    remove_ = remove;
    */
end

// state
always @(posedge clk) begin
    case (state)
        STATE_READY: begin
            if (insert_) state <= (index != length) ? STATE_INSERT_READ : STATE_INSERT_DONE;
            if (remove_) state <= (index != length - 1) ? STATE_REMOVE_READ : STATE_REMOVE_DONE;
        end
        STATE_INSERT_READ:  state <= STATE_INSERT_WRITE;
        STATE_INSERT_WRITE: state <= (j == index) ? STATE_INSERT_DONE : STATE_INSERT_READ;
        STATE_INSERT_DONE:  state <= STATE_READY;
        STATE_REMOVE_READ:  state <= STATE_REMOVE_WRITE;
        STATE_REMOVE_WRITE: state <= (j == length - 2) ? STATE_REMOVE_DONE : STATE_REMOVE_READ;
        STATE_REMOVE_DONE:  state <= STATE_READY;
    endcase
end

// j
always @(posedge clk) begin
    case (state)
        STATE_READY: begin
            if (insert_) j <= length;
            if (remove_) j <= index; 
        end
        STATE_INSERT_WRITE: j <= j - 1;
        STATE_REMOVE_WRITE: j <= j + 1;
        default: ;
    endcase
end

// tmp
always @(posedge clk) begin
    case (state)
        STATE_INSERT_READ: tmp <= mem[j - 1];
        STATE_REMOVE_READ: tmp <= mem[j + 1];
        default: ;
    endcase
end

// mem
always @(posedge clk) begin
    case (state)
        STATE_INSERT_WRITE,
        STATE_REMOVE_WRITE: mem[j]     <= tmp;
        STATE_INSERT_DONE:  mem[index] <= data_in;
        default: ;
    endcase
end

// length
always @(posedge clk) begin
    case (state)
        STATE_INSERT_DONE: length <= length + 1;
        STATE_REMOVE_DONE: length <= length - 1;
        default: ;
    endcase
end

// data_out
always @(posedge clk) begin
    if ((state == STATE_READY) & get_) begin
        data_out <= mem[index];
    end
end

endmodule
