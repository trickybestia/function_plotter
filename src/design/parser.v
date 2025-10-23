module parser (
    clk,

    start,               
    ready,              
 
    output_queue_insert,
    output_queue_index,           
    output_queue_data_in,
    output_queue_ready,

    symbol_iter_en,
    symbol,
    symbol_valid               
);

// parameters
parameter SYMBOL_WIDTH      = 7;
   
parameter INTEGER_PART_WIDTH     = 8;
parameter FRACTIONAL_PART_WIDTH  = 8;
parameter OUTPUT_QUEUE_SIZE      = 64;

// local parameters
localparam NUMBER_WIDTH           = INTEGER_PART_WIDTH + FRACTIONAL_PART_WIDTH;
localparam OUTPUT_VALUE_WIDTH     = NUMBER_WIDTH + 1;

localparam STACK_SIZE = 64;

localparam OPERATOR_WIDTH = 3;   

// operator types   
localparam PLUS         = 0;
localparam SUB          = 1;
localparam MUL          = 2;
localparam DIV          = 3;
localparam POW          = 4;
localparam LEFT_BRACKET = 5;
localparam VAR          = 6;

// FSM states
localparam READY                          = 0;   
localparam REQUEST_SYMBOLE                = 1;   
localparam WAIT_FOR_SYMBOLE               = 2;
localparam ANALYZE_SYMBOLE                = 3;
localparam ACCUMULATE_NUMBER              = 4;
localparam ACCUMULATE_INTEGER_PART        = 5;
localparam ACCUMULATE_FRACTION_PART       = 6;
localparam PUT_OPERAND_TO_OUTPUT          = 7;
localparam PUT_OPERAND_TO_OUTPUT_2        = 8;
localparam PUT_OPERAND_TO_OUTPUT_3        = 9;
localparam HANDLE_PLUS_SUB                = 10;
localparam HANDLE_MUL                     = 11;
localparam HANDLE_DIV                     = 12;
localparam PUSH_OPERATOR_TO_STACK         = 13;
localparam PUT_OPERATOR_TO_OUTPUT         = 14;
localparam PUT_OPERATOR_TO_OUTPUT_2       = 15;
localparam PUT_OPERATOR_TO_OUTPUT_3       = 16;   
localparam PUT_LEFT_BRACKET_TO_STACK      = 17;
localparam HANDLE_RIGHT_BRACKET           = 18;
localparam RELEASE_STACK_TO_OUTPUT        = 19;
localparam MOVE_OP_FROM_STACK_TO_OUTPUT   = 20;
localparam MOVE_OP_FROM_STACK_TO_OUTPUT_2 = 21;
localparam MOVE_OP_FROM_STACK_TO_OUTPUT_3 = 22;   

// input/output
input clk;

input  start;    
output ready;

output reg                                    output_queue_insert;
output reg  [$clog2(OUTPUT_QUEUE_SIZE) - 1:0] output_queue_index;
output reg  [OUTPUT_VALUE_WIDTH - 1:0]        output_queue_data_in;
input                                         output_queue_ready;

output                      symbol_iter_en;
input  [SYMBOL_WIDTH - 1:0] symbol;
input                       symbol_valid;

// reg/wire
reg [4:0]                  state, next_state;
reg [2:0]                  fractional_count;   
reg [NUMBER_WIDTH - 1:0]   operand;
reg [OPERATOR_WIDTH - 1:0] operator;

// stack   
reg [OPERATOR_WIDTH - 1:0]     stack [0:STACK_SIZE - 1];
reg [$clog2(STACK_SIZE) - 1:0] stack_p;

// flags   
reg acc_operand, acc_operand_fraction, acc_asterisk;  

reg iterate_enable; 
assign symbol_iter_en = (iterate_enable && ~symbol_valid);   

assign ready = (state == READY);

initial begin
    state                = READY;
    next_state           = 0; 
    stack_p              = 0;
    acc_operand          = 0;
    acc_operand_fraction = 0;
    acc_asterisk         = 0;   
    iterate_enable       = 0;
    output_queue_insert  = 0;
    output_queue_index   = 0;   
end

always @(posedge clk) begin
    case (state)
        READY: begin
            if (start) begin
                state <= REQUEST_SYMBOLE;
                stack_p <= 0;       
                output_queue_index <= 0;       
            end
        end 

        REQUEST_SYMBOLE: begin
            iterate_enable <= 1;
            state <= WAIT_FOR_SYMBOLE; 
        end

        WAIT_FOR_SYMBOLE: begin
            if (symbol_valid) begin
                iterate_enable <= 0;
                state <= ANALYZE_SYMBOLE;           
            end
        end

        ANALYZE_SYMBOLE: begin
            if (acc_operand) begin
                if (symbol == 0) begin // null
                    acc_operand <= 0;
                    state <= PUT_OPERAND_TO_OUTPUT;
                    next_state <= RELEASE_STACK_TO_OUTPUT;              
                end
                else if (~((symbol >= "0" && symbol <= "9") || 
                           symbol == ".")) begin
                    acc_operand <= 0;
                    state <= PUT_OPERAND_TO_OUTPUT;
                    next_state <= ANALYZE_SYMBOLE;
                end
                else begin
                    state <= ACCUMULATE_NUMBER;
                end
            end
            else if (acc_asterisk) begin
                if (symbol == "*") begin
                    operator <= POW;
                    next_state <= REQUEST_SYMBOLE;
                    state <= PUSH_OPERATOR_TO_STACK;
                end
                else begin
                    operator <= MUL;
                    state <= HANDLE_MUL;
                end
                acc_asterisk <= 0;
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
                        acc_asterisk <= 1;
                        state <= REQUEST_SYMBOLE;                
                    end
                    "/": begin
                        operator <= DIV;
                        state <= HANDLE_DIV;                
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
                        acc_operand <= 1; 
                        state <= ACCUMULATE_NUMBER;
                        operand <= 0;                
                        // prepare value (val - 48)
                    end
                    ".": begin
                        acc_operand_fraction <= 1;
                        state <= ACCUMULATE_FRACTION_PART;                
                    end
                    default:
                      state <= REQUEST_SYMBOLE;             
                endcase
            end
        end

        ACCUMULATE_NUMBER: begin
            if (acc_operand_fraction)
              state <= ACCUMULATE_FRACTION_PART;
            else
              state <= ACCUMULATE_INTEGER_PART;        
        end
        ACCUMULATE_INTEGER_PART: begin
            operand[NUMBER_WIDTH - 1:FRACTIONAL_PART_WIDTH] <=
             operand[NUMBER_WIDTH - 1:FRACTIONAL_PART_WIDTH]
              * 10 + (symbol - 48);
            state <= REQUEST_SYMBOLE;        
        end
        ACCUMULATE_FRACTION_PART: begin
            operand[FRACTIONAL_PART_WIDTH - 1:0] <= 
             operand[FRACTIONAL_PART_WIDTH - 1:0] + 
              ((symbol - 48) << (8 - fractional_count * 4));
            state <= REQUEST_SYMBOLE;
            fractional_count <= fractional_count + 1; 
        end
        PUT_OPERAND_TO_OUTPUT: begin
            output_queue_data_in[NUMBER_WIDTH] <= 1'b0;
            output_queue_data_in[NUMBER_WIDTH - 1:0] <= operand;

            output_queue_insert <= 1;
            state <= PUT_OPERAND_TO_OUTPUT_2;
        end
        PUT_OPERAND_TO_OUTPUT_2: begin
            output_queue_insert <= 0;
            state <= PUT_OPERAND_TO_OUTPUT_3;
        end
        PUT_OPERAND_TO_OUTPUT_3: begin
            if (output_queue_ready) begin
                acc_operand <= 0;
                acc_operand_fraction <= 0;
                state <= next_state;
                output_queue_index <= output_queue_index + 1;
            end
        end

        HANDLE_PLUS_SUB: begin
            if (stack_p == 0) begin
                state <= PUSH_OPERATOR_TO_STACK;
                next_state <= REQUEST_SYMBOLE;           
            end
            else if (stack[stack_p - 1] == MUL ||
                     stack[stack_p - 1] == DIV ||
                     stack[stack_p - 1] == POW ) begin
                next_state <= HANDLE_PLUS_SUB;
                state <= MOVE_OP_FROM_STACK_TO_OUTPUT;           
            end
            else begin
                state <= PUSH_OPERATOR_TO_STACK;           
                next_state <= REQUEST_SYMBOLE;
            end
        end

        HANDLE_MUL: begin
            if (stack_p == 0) begin
                state <= PUSH_OPERATOR_TO_STACK;
                next_state <= ANALYZE_SYMBOLE;
            end
            else if (stack[stack_p - 1] == POW) begin
                next_state <= HANDLE_MUL;
                state <= MOVE_OP_FROM_STACK_TO_OUTPUT;           
            end
            else begin
                state <= PUSH_OPERATOR_TO_STACK;
                next_state <= ANALYZE_SYMBOLE;           
            end
        end

        HANDLE_DIV: begin
            if (stack_p == 0) begin
                state <= PUSH_OPERATOR_TO_STACK;
                next_state <= REQUEST_SYMBOLE;
            end
            else if (stack[stack_p - 1] == POW) begin
                next_state <= HANDLE_DIV;
                state <= MOVE_OP_FROM_STACK_TO_OUTPUT;           
            end
            else begin
                state <= PUSH_OPERATOR_TO_STACK;           
                state <= REQUEST_SYMBOLE;
            end
        end
        
        PUSH_OPERATOR_TO_STACK: begin
            stack[stack_p] <= operator;
            stack_p <= stack_p + 1;
            state <= next_state;
        end
        
        PUT_OPERATOR_TO_OUTPUT: begin
            output_queue_data_in[NUMBER_WIDTH] <= 1'b1;
            output_queue_data_in[NUMBER_WIDTH - 1:OPERATOR_WIDTH] <= 0;
            output_queue_data_in[OPERATOR_WIDTH - 1:0] <= operator;

            output_queue_insert <= 1;        
            state <= PUT_OPERATOR_TO_OUTPUT_2;        
        end
        PUT_OPERATOR_TO_OUTPUT_2: begin
            output_queue_insert <= 0;
            state <= PUT_OPERATOR_TO_OUTPUT_3;        
        end
        PUT_OPERATOR_TO_OUTPUT_3: begin        
            if (output_queue_ready) begin
                output_queue_index <= output_queue_index + 1;           
                state <= next_state;
            end
        end

        PUT_LEFT_BRACKET_TO_STACK: begin
            stack[stack_p] <= LEFT_BRACKET;
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
                state <= READY;
            end
            else begin
                next_state <= RELEASE_STACK_TO_OUTPUT;
                state <= MOVE_OP_FROM_STACK_TO_OUTPUT;
            end
        end

        MOVE_OP_FROM_STACK_TO_OUTPUT: begin
            if (stack[stack_p - 1] == LEFT_BRACKET) begin
                state <= READY;
            end
            else begin
                output_queue_data_in[NUMBER_WIDTH] <= 1'b1;
                output_queue_data_in[NUMBER_WIDTH - 1:OPERATOR_WIDTH] <= 0;
                output_queue_data_in[OPERATOR_WIDTH - 1:0] <= stack[stack_p - 1];
                output_queue_insert <= 1;
                state <= MOVE_OP_FROM_STACK_TO_OUTPUT_2;
            end
        end
        MOVE_OP_FROM_STACK_TO_OUTPUT_2: begin
            output_queue_insert <= 0;
            state <= MOVE_OP_FROM_STACK_TO_OUTPUT_3;
        end
        MOVE_OP_FROM_STACK_TO_OUTPUT_3: begin
            if (output_queue_ready) begin
                stack_p <= stack_p - 1;
                state <= next_state;
                output_queue_index <= output_queue_index + 1;
            end
        end

    endcase
end

endmodule   
