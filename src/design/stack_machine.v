module stack_machine (
    clk,

    start,                      
    ready,

    x_input,
    y_output,

    output_queue_index,
    output_queue_get,
    output_queue_data_out,
    output_queue_ready
);

parameter INTEGER_PART_WIDTH     = 8;
parameter FRACTIONAL_PART_WIDTH  = 8;
parameter OUTPUT_QUEUE_SIZE      = 64;
parameter HOR_ACTIVE_PIXELS      = 640;
parameter VER_ACTIVE_PIXELS      = 480;

localparam NUMBER_WIDTH       = INTEGER_PART_WIDTH + FRACTIONAL_PART_WIDTH;
localparam OUTPUT_VALUE_WIDTH = NUMBER_WIDTH + 1;

localparam OPERATOR_WIDTH = 3; 
localparam STACK_SIZE     = 64;

localparam READY              = 0;
localparam TRANSFORM_X        = 1;
localparam TRANSFORM_X_2      = 2;
localparam TRANSFORM_X_3      = 3;
localparam FETCH_OUTPUT_VAL   = 4;
localparam FETCH_OUTPUT_VAL_2 = 5;
localparam ANALYZE_OUTPUT_VAL = 6;
localparam PUT_VAR_TO_STACK   = 7;
localparam PUT_VAL_TO_STACK   = 8;
localparam PERFORM_MATN_OP    = 9;
localparam PERFORM_MATN_OP_2  = 10;
localparam TRANSFORM_Y        = 11;
localparam TRANSFORM_Y_2      = 12;
localparam TRANSFORM_Y_3      = 13;
localparam TRANSFORM_Y_4      = 14;

input clk;

input      [NUMBER_WIDTH - 1:0] x_input;
reg        [NUMBER_WIDTH - 1:0] x;
reg        [NUMBER_WIDTH - 1:0] y;   
output reg [NUMBER_WIDTH - 1:0] y_output;
   
output reg [$clog2(OUTPUT_QUEUE_SIZE) + 1:0] output_queue_index;
output reg                                   output_queue_get;
input [OUTPUT_VALUE_WIDTH - 1:0]             output_queue_data_out;
wire [$clog2(OUTPUT_QUEUE_SIZE) + 1:0]       output_queue_length;
input                                        output_queue_ready;    

reg [OUTPUT_VALUE_WIDTH - 1:0] fetched_value;   

input      start;   
output reg ready;   
   
reg [NUMBER_WIDTH - 1:0]         stack [0:STACK_SIZE - 1];
reg [$clog2(STACK_SIZE) + 1:0]   stack_p;
reg [NUMBER_WIDTH - 1:0]         a, b;
wire [NUMBER_WIDTH - 1:0]        result;
   
reg [OPERATOR_WIDTH - 1:0] operator;

localparam PLUS = 3'b000;
localparam SUB  = 3'b001;
localparam MUL  = 3'b010;
localparam DIV  = 3'b011;
localparam POW  = 3'b100;

reg [2:0] op_for_alu;   
   
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
   stack_p            = 0; 
   alu_start          = 0;   
end

always @(posedge clk) begin
   case (state)
     READY: begin
        if (start) begin
           state <= TRANSFORM_X;
           x[NUMBER_WIDTH - 1:FRACTIONAL_PART_WIDTH] <= x_input;           
        end
     end
     TRANSFORM_X: begin
        op_for_alu <= SUB;
        a <= x;
        b <= HOR_ACTIVE_PIXELS / 2;
        alu_start <= 1;
        state <= TRANSFORM_X_2;        
     end
     TRANSFORM_X_2: begin
        alu_start <= 0;
        if (alu_done) begin
           state <= TRANSFORM_Y_3;
           x <= result;           
        end
     end
     TRANSFORM_X_3: begin
        op_for_alu <= DIV;
        a <= x;
        b <= 20;
        alu_start <= 1;
        state <= TRANSFORM_X_3;                
     end
     TRANSFORM_X_3: begin
        alu_start <= 0;
        if (alu_done) begin
           state <= FETCH_OUTPUT_VAL;
           x <= result;           
        end
     end
     
     FETCH_OUTPUT_VAL: begin
        if (output_queue_length < output_queue_index)
          state <= TRANSFORM_Y;
        else begin
           output_queue_get <= 1;
           state <= FETCH_OUTPUT_VAL_2;
        end
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
        if (fetched_value[NUMBER_WIDTH - 1] && 
            fetched_value[NUMBER_WIDTH - 2:0] == 6)
          state <= PUT_VAR_TO_STACK;
        else if (fetched_value[NUMBER_WIDTH - 1]) begin
           op_for_alu <= fetched_value[2:0];
           state <= PERFORM_MATN_OP;     
        end
        else begin
           state <= PUT_VAL_TO_STACK;           
        end
     end

     PUT_VAR_TO_STACK: begin
        stack[stack_p] <= x;
        stack_p <= stack_p + 1;
        state <= FETCH_OUTPUT_VAL;        
     end

     PUT_VAL_TO_STACK: begin
        stack[stack_p] <= fetched_value[NUMBER_WIDTH - 1:0];
        stack_p <= stack_p + 1;        
        state <= FETCH_OUTPUT_VAL;        
     end

     PERFORM_MATN_OP: begin
        a <= stack[stack_p - 1];
        b <= stack[stack_p - 2];
        alu_start <= 1;        
        state <= PERFORM_MATN_OP_2;        
     end
     PERFORM_MATN_OP_2: begin
        alu_start <= 0;
        if (alu_done) begin
           stack[stack_p - 2] <= result;
           stack_p <= stack_p - 1;
           state <= FETCH_OUTPUT_VAL;        
        end
     end

     TRANSFORM_Y: begin
        op_for_alu <= DIV; 
        a <= stack[0];
        b <= 20;
        alu_start <= 1;
        state <= TRANSFORM_Y_2;    
     end
     TRANSFORM_Y_2: begin
        alu_start <= 0;
        if (alu_done) begin
           y <= result;
           state <= TRANSFORM_Y_3;           
        end
     end
     TRANSFORM_Y_3: begin
        op_for_alu <= PLUS; 
        a <= y;
        b <= VER_ACTIVE_PIXELS / 2;
        alu_start <= 1;
        state <= TRANSFORM_Y_2;            
     end
     TRANSFORM_Y_4: begin
        alu_start <= 0;
        if (alu_done) begin
           y_output <= result[NUMBER_WIDTH - 1:FRACTIONAL_PART_WIDTH];
           state <= READY;

           stack_p <= 0;           
        end
     end
     
   endcase
end

endmodule
