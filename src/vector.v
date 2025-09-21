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

initial begin
    data_out = 0;
    length   = 0;
    state    = STATE_READY;
    j        = 0;
    tmp      = 0;
end

// state
always @(posedge clk) begin
    case (state)
        STATE_READY: begin
            if (insert) state <= (index != length) ? STATE_INSERT_READ : STATE_INSERT_DONE;
            if (remove) state <= (index != length - 1) ? STATE_REMOVE_READ : STATE_REMOVE_DONE;
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
            if (insert) j <= length;
            if (remove) j <= index; 
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
    if ((state == STATE_READY) & get) begin
        data_out <= mem[index];
    end
end

endmodule
