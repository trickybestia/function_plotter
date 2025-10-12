module stack_machine (
    clk,

    x,
    y,

    output_queue,
    output_queue_p,                  
);

parameter INTEGER_PART_WIDTH     = 8;
parameter FRACTIONAL_PART_WIDTH  = 8;
parameter NUMBER_WIDTH           = INTEGER_PART_WIDTH + FRACTIONAL_PART_WIDTH;
parameter OUTPUT_VALUE_WIDTH     = NUMBER_WIDTH + 1;
parameter OUTPUT_QUEUE_SIZE      = 64;

localparam OPERATOR_WIDTH = 3; 
localparam STACK_SIZE     = 64;

input clk;

input [] output_queue_p;

reg [NUMBER_WIDTH - 1:0] stack [0:STACK_SIZE - 1];
reg [STACK_SIZE - 1:0] stack_p;
reg [NUMBER_WIDTH - 1:0] regA, regB;
reg [NUMBER_WIDTH - 1:0] result;
   
reg [OPERATOR_WIDTH - 1:0] operator;
reg [2:0] op_for_alu;   
   
reg [2:0] state;
wire output_queue_val = output_queue[output_queue_p - 1];   
   
initial begin
   state = 0;
   
end


always @(posedge clk) begin
   case (state)
     FETCH_OUTPUT_VAL: begin
        
     end
     ANALYZE_OUTPUT_VAL: begin
        
     end

     PUT_VAL_TO_STACK: begin
        state <= PUT_VAL_TO_STACK_2;        
     end
     PUT_VAL_TO_STACK_2: begin
        
     end

     PERFORM_MATN_OP: begin
        regA <= stack[stack_p - 1];
        state <= PERFORM_MATN_OP_2;        
     end
     PERFORM_MATN_OP_2: begin
        regB <= stack[stack_p - 2];
        state <= PERFORM_MATN_OP_3;        
     end
     PERFORM_MATN_OP_3: begin
        regB <= stack[stack_p - 2];
        state <= PERFORM_MATN_OP_4;        
     end
     PERFORM_MATN_OP_4: begin
        stack_p <=  stack_p - 1;
        
     end
     PERFORM_MATN_OP_5: begin
        stack[stack_p - 1] = result;
        state <= FETCH_OUTPUT_VAL;        
     end
     
   endcase
end

endmodule
