module parser (
    clk,

    ready,               
    output_queue,
    output_queue_p,

    symbol_iter_en,
    symbol,
    symbol_valid               
);

parameter SYMBOL_WIDTH      = 7;
   
parameter INTEGER_PART_WIDTH     = 8;
parameter FRACTIONAL_PART_WIDTH  = 8;
parameter NUMBER_WIDTH           = INTEGER_PART_WIDTH + FRACTIONAL_PART_WIDTH;
parameter OUTPUT_VALUE_WIDTH     = NUMBER_WIDTH + 1;
parameter OUTPUT_QUEUE_SIZE      = 64;

localparam STACK_SIZE = 64;

localparam OPERATOR_WIDTH = 3;   

localparam PLUS         = 0;
localparam SUB          = 1;
localparam MUL          = 2;
localparam DIV          = 3;
localparam POW          = 4;
localparam LEFT_BRACKET = 5;
localparam VAR          = 6;   

localparam REQUEST_SYMBOLE                = 0;   
localparam WAIT_FOR_SYMBOLE               = 1;
localparam ANALYZE_SYMBOLE                = 2;
localparam ACCUMULATE_NUMBER              = 3;
localparam ACCUMULATE_INTEGER_PART        = 4;
localparam ACCUMULATE_FRACTION_PART       = 5;
localparam PUT_NUMBER_TO_OUTPUT           = 6;
localparam PUT_NUMBER_TO_OUTPUT_2         = 7;
localparam HANDLE_PLUS_SUB                = 8;
localparam HANDLE_MUL_DIV                 = 9;
localparam PUSH_OPERATOR_TO_STACK         = 10;
localparam PUSH_OPERATOR_TO_STACK_2       = 11;
localparam PUT_OPERATOR_TO_OUTPUT         = 12;
localparam PUT_OPERATOR_TO_OUTPUT_2       = 13;
localparam PUT_LEFT_BRACKET_TO_STACK      = 14;
localparam PUT_LEFT_BRACKET_TO_STACK_2    = 15;
localparam HANDLE_RIGHT_BRACKET           = 16;
localparam RELEASE_STACK_TO_OUTPUT        = 17;
localparam MOVE_OP_FROM_STACK_TO_OUTPUT   = 18;
localparam MOVE_OP_FROM_STACK_TO_OUTPUT_2 = 19;
localparam END                            = 20;   
   
input clk;

output                      symbol_iter_en;
input  [SYMBOL_WIDTH - 1:0] symbol;
input                       symbol_valid;

output reg [OUTPUT_VALUE_WIDTH - 1:0] output_queue [0:OUTPUT_QUEUE_SIZE - 1];
output reg [0:OUTPUT_QUEUE_SIZE - 1] output_queue_p;
   
output reg ready;   
 
reg [4:0] state, next_state;
reg [2:0] fractional_count;   
reg [NUMBER_WIDTH - 1:0] operand;
reg [OPERATOR_WIDTH - 1:0] operator;
   
reg [OPERATOR_WIDTH - 1:0] stack [0:STACK_SIZE - 1];
reg [STACK_SIZE - 1:0] stack_p;
reg acc_number, acc_number_fraction;  
   
initial begin
   state               = REQUEST_SYMBOLE;
   next_state          = 0; 
   stack_p             = 0;
   acc_number          = 0;
   acc_number_fraction = 0;
   symbol_iter_en      = 0;
   ready               = 0;   
end

assign symbol_valid = ( && ~symbol_iter_en);
   
always @(posedge clk) begin
   case (state)
     REQUEST_SYMBOLE: begin
        symbol_iter_en <= 1;
        state <= WAIT_FOR_SYMBOLE; 
     end

     WAIT_FOR_SYMBOLE: begin
        if (symbol_valid) begin
           symbol_iter_en <= 0;
           state <= ANALYZE_SYMBOLE;           
        end
     end

     ANALYZE_SYMBOLE: begin
        if (acc_number) begin
           if (~((symbol >= "0" && symbol <= "9") || symbol == "."))
             state <= PUT_NUMBER_TO_OUTPUT;           
        end
        else begin
           case (symbol)
             0: begin //null
                state <= RELEASE_STACK_TO_OUTPUT;                        
             end
             "+": begin
                operator <= PLUS;
                state <= HANDLE_PLUS_SUB;                
             end
             "-": begin
                operator <= SUB;
                state <= HANDLE_PLUS_SUB;                
             end
             "*": begin
                operator <= MUL;
                state <= HANDLE_MUL_DIV;                
             end
             "/": begin
                operator <= DIV;
                state <= HANDLE_MUL_DIV;                
             end
             "^": begin
                operator <= POW;
                state <= PUSH_OPERATOR_TO_STACK;                
             end
             "[": begin
                state <= PUT_LEFT_BRACKET_TO_STACK;                
             end
             "]": begin
                state <= HANDLE_RIGHT_BRACKET;
             end
             "x": begin
                operator <= VAR;
                next_state <= REQUEST_SYMBOLE;
                state <= PUT_OPERATOR_TO_OUTPUT;                
             end
             "0", "1", "2", "3", "4", "5", "6", "7", "8", "9": begin
                state <= ACCUMULATE_NUMBER;
                // prepare value (val - 48)
             end
             ".": begin
                acc_number_fraction <= 1;
                state <= ACCUMULATE_FRACTION_PART;                
             end
             default:
               state <= REQUEST_SYMBOLE;             
           endcase
        end
     end

     ACCUMULATE_NUMBER: begin
        if (acc_number_fraction)
          state <= ACCUMULATE_FRACTION_PART;
        else
          state <= ACCUMULATE_INTEGER_PART;        
     end
     ACCUMULATE_INTEGER_PART: begin
        operator[15:8] <= operator[15:8] * 10 + (symbol - 48);
        state <= REQUEST_SYMBOLE;        
     end
     ACCUMULATE_FRACTION_PART: begin
        operator[7:0] <= operator[7:0] + ((symbol - 48) << 
                                          (8 - fractional_count * 4));
        state <= REQUEST_SYMBOLE;
     end

     PUT_NUMBER_TO_OUTPUT: begin
        output_queue[output_queue_p] <= {1'b0, operand};
        state <= PUT_NUMBER_TO_OUTPUT_2;        
     end
     PUT_NUMBER_TO_OUTPUT_2: begin
        output_queue_p <= output_queue_p + 1;
        acc_number <= 0;
        acc_number_fraction <= 0;
        state <= ANALYZE_SYMBOLE;        
     end

     HANDLE_PLUS_SUB: begin
        if (stack_p == 0)
          state <= PUSH_OPERATOR_TO_STACK;
        else if (stack[stack_p - 1] == "*" ||
                 stack[stack_p - 1] == "/" ||
                 stack[stack_p - 1] == "^" ) begin
           next_state <= HANDLE_PLUS_SUB;
           state <= MOVE_OP_FROM_STACK_TO_OUTPUT;           
        end
        else
          state <= REQUEST_SYMBOLE;        
     end

     HANDLE_MUL_DIV: begin
        if (stack_p == 0)
          state <= PUSH_OPERATOR_TO_STACK;
        else if (stack[stack_p - 1] == "^") begin
           next_state <= HANDLE_MUL_DIV;
           state <= MOVE_OP_FROM_STACK_TO_OUTPUT;           
        end
        else
          state <= REQUEST_SYMBOLE;        
     end
     
     PUSH_OPERATOR_TO_STACK: begin
        stack[stack_p] <= operator;
        state <= PUSH_OPERATOR_TO_STACK_2;        
     end
     PUSH_OPERATOR_TO_STACK_2: begin
        stack_p <= stack_p + 1;
        state <= REQUEST_SYMBOLE;        
     end
     
     PUT_OPERATOR_TO_OUTPUT: begin
        output_queue[output_queue_p] <= {1'b1, operator};
        state <= PUT_OPERATOR_TO_OUTPUT_2;        
     end
     PUT_OPERATOR_TO_OUTPUT_2: begin
        output_queue_p <= output_queue_p + 1;
        state <= next_state;        
     end

     PUT_LEFT_BRACKET_TO_STACK: begin
        stack[stack_p] <= LEFT_BRACKET;
        state <= PUT_LEFT_BRACKET_TO_STACK_2;        
     end
     PUT_LEFT_BRACKET_TO_STACK_2: begin
        stack_p <= stack_p + 1;
        state <= REQUEST_SYMBOLE;        
     end

     HANDLE_RIGHT_BRACKET: begin
        if (stack[stack_p - 1] == LEFT_BRACKET) begin
           stack_p <= stack_p - 1;
           state <= REQUEST_SYMBOLE;            
        end
        else begin
           next_state <= HANDLE_RIGHT_BRACKET;
           state <=  MOVE_OP_FROM_STACK_TO_OUTPUT;           
        end
     end

     RELEASE_STACK_TO_OUTPUT: begin
        if (stack_p == 0) begin
           state <= END;        
        end
        else begin
           next_state <= RELEASE_STACK_TO_OUTPUT;
           state <= MOVE_OP_FROM_STACK_TO_OUTPUT;           
        end
     end

     MOVE_OP_FROM_STACK_TO_OUTPUT: begin
        output_queue[output_queue_p] <= {1'b1, stack[stack_p - 1]};
        state <= MOVE_OP_FROM_STACK_TO_OUTPUT_2;        
     end
     MOVE_OP_FROM_STACK_TO_OUTPUT_2: begin
        output_queue_p <= output_queue_p + 1;
        stack_p <= stack_p - 1;
        state <= next_state;        
     end

   END: begin
   end

   endcase
end


endmodule   
