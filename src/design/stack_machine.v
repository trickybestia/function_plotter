module stack_machine (
    clk,

    x,
    y,

    output_queue_index,
    output_queue_get,
    output_queue_data_out,
    output_queue_ready,

    ready                      
);

parameter INTEGER_PART_WIDTH     = 8;
parameter FRACTIONAL_PART_WIDTH  = 8;
parameter NUMBER_WIDTH           = INTEGER_PART_WIDTH + FRACTIONAL_PART_WIDTH;
parameter OUTPUT_VALUE_WIDTH     = NUMBER_WIDTH + 1;
parameter OUTPUT_QUEUE_SIZE      = 64;

localparam OPERATOR_WIDTH = 3; 
localparam STACK_SIZE     = 64;

input clk;

input      [NUMBER_WIDTH - 1:0] x_wire;
reg        [NUMBER_WIDTH - 1:0] x;   
output reg [NUMBER_WIDTH - 1:0] y;
   
output reg [$clog2(OUTPUT_QUEUE_SIZE) + 1:0] output_queue_index;
output reg                                   output_queue_get;
input [OUTPUT_VALUE_WIDTH - 1:0]             output_queue_data_out;
input                                        output_queue_ready;    

reg [OUTPUT_VALUE_WIDTH - 1:0] fetched_value;   
   
reg [NUMBER_WIDTH - 1:0]         stack [0:STACK_SIZE - 1];
reg [$clog2(STACK_SIZE) + 1:0]   stack_p;
reg [NUMBER_WIDTH - 1:0]         a, b;
reg [NUMBER_WIDTH - 1:0]         result;
   
reg [OPERATOR_WIDTH - 1:0] operator;
reg [2:0]                  op_for_alu;   
   
reg [2:0] state;

// instantiate alu module 
reg  alu_start;
wire alu_done;
   
fixed_point_alu #(
    .INTEGER_PART_WIDTH    (INTEGER_PART_WIDTH),
    .FRACTIONAL_PART_WIDTH (FRACTIONAL_PART_WIDTH)                 
) alu (
    .clk    (clk),
    .start  (alu_start),
    .done   (alu_done),
    .op     (op_for_alu),
    .a      (a),
    .b      (b),
    .result (result)                     
);
   
initial begin
   state              = 0;
   ready              = 0;
   output_queue_get   = 0;
   output_queue_index = 0;   
   alu_start          = 0;   
end

always @(posedge clk) begin
   case (state)
     TRANSFORM_X: begin
        x <= x_wire;
        
     end
     FETCH_OUTPUT_VAL: begin
        output_queue_get <= 1;
        state <= FETCH_OUTPUT_VAL_2;        
     end
     FETCH_OUTPUT_VAL_2: begin
        output_queue_get <= 0;
        if (output_queue_ready) begin
           output_queue_index <= output_queue_index + 1;
           fetched_value <= output_queue_data_out;           
           state <= ANALYZE_OUTPUT_VAL;           
        end          
     end
     ANALYZE_OUTPUT_VAL: begin
        if (fetched_value[32] && fetched_value[31:0] == 6) // add localparam
          state <= PUT_VAR_TO_STACK;
        else if (fetched_value[32]) begin
           op_for_alu <= fetched_value[2:0];
           state <= PERFORM_MATN_OP;           
        end
        else begin
           state <= PUT_VAL_TO_STACK;           
        end
     end

     PUT_VAR_TO_STACK: begin
        stack[stack_p] <= x; // some prepared x
        stack_p <= stack_p + 1;
        state <= FETCH_OUTPUT_VAL;        
     end

     PUT_VAL_TO_STACK: begin
        stack[stack_p] <= fetched_value[31:0];
        stack_p <= stack_p + 1;        
        state <= FETCH_OUTPUT_VAL;        
     end

     PERFORM_MATN_OP: begin
        a <= stack[stack_p - 1];
        state <= PERFORM_MATN_OP_2;        
     end
     PERFORM_MATN_OP_2: begin
        b <= stack[stack_p - 2];
        state <= PERFORM_MATN_OP_3;        
     end
     PERFORM_MATN_OP_3: begin
        alu_start <= 1;        
        state <= PERFORM_MATN_OP_4;        
     end
     PERFORM_MATN_OP_4: begin
        alu_start <= 0;
        if (alu_done) begin
           stack_p <= stack_p - 1;
           state <= PERFORM_MATN_OP_5;           
        end
     end
     PERFORM_MATN_OP_5: begin
        stack[stack_p - 1] = result;
        state <= FETCH_OUTPUT_VAL;        
     end
     
   endcase
end

endmodule
