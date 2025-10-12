/* Parse infix math expression to Rever polish notation
   using Shunting yard algorithm.

   Operators: {+, -, /, *, ^}

*/


#include "config.h"

#include <stdio.h>


oper_t stack[STACK_SIZE];
int stack_p = 0;

output_t output [OUTPUT_SIZE];
int output_p = 0;

enum {WAIT_FOR_TOKEN = 0, GET_NUMBER, SAVE_NUMBER_TO_OUTPUT, \
      HANDLE_OPERATOR, HANDLE_OPERATOR_2, HANDLE_OPERATOR_3, \
      HANDLE_VAR, HANDLE_LEFT_BRACKET, HANDLE_RIGHT_BRACKET, \
      RELEASE_STACK, END};

static int is_number(char c) {
    if ((c >= '0' && c <= '9') || c == '.')
        return 1;
    return 0;
}
static int is_operator(char c) {
    switch (c) {
    case '+':
        return PLUS;
    case '-':
        return MINUS;
    case '*':
        return MULT;
    case '/':
        return DIV;
    case '^':
        return POWER;
    default:
        return 0;
    }
}
static int cmp_operators(int op1 , int op2) {
    op1--;
    op2--;

    if (op1 / 2 >= op2 / 2)
        return 1;
    else
        return 0;
}
static int is_less_precedence(int operator) {
    /* if (stack[stack_p - 1] >= operator) */
    /*     return 1; */
    if (cmp_operators(stack[stack_p - 1], operator))
        return 1;
    return 0;
}
static int is_left_bracket(char c) {
    return c == '(' ? 1 : 0;
}
static int is_right_bracket(char c) {
    return c == ')' ? 1 : 0;
}

int parse(const char* expr) {
    int state = 0, it = 0;
    int operand, operator;
    output_t out;

    while (1) {
        switch (state) {
        case WAIT_FOR_TOKEN: /* Wait for new token */
            if (is_number(expr[it])) {
                state = GET_NUMBER;
                operand = 0;
            }
            else if (is_operator(expr[it])) {
                state = HANDLE_OPERATOR;
            }
            else if (expr[it] == 'x') {
                state = HANDLE_VAR;
            }
            else if (is_left_bracket(expr[it])) {
                state = HANDLE_LEFT_BRACKET;
            }
            else if (is_right_bracket(expr[it])) {
                state = HANDLE_RIGHT_BRACKET;
            }
            else if (expr[it] == '\0')
                state = RELEASE_STACK;
            else
                it++;
            break;
        case GET_NUMBER: /* Accumulate number */
            if (!is_number(expr[it]))
                state = SAVE_NUMBER_TO_OUTPUT; /* save number in output */
            else {
                operand *= 10;
                operand += (expr[it] - 48);
                it++;
            }
            break;
        case SAVE_NUMBER_TO_OUTPUT: /* Put number in output queue */
            out.val = operand;
            out.is_operator = 0;

            output[output_p] = out;
            output_p++;

            state = WAIT_FOR_TOKEN;
            break;
        case HANDLE_OPERATOR: /* If operator + - * / ^ */
            operator = is_operator(expr[it]);
            state = HANDLE_OPERATOR_2;
            break;
        case HANDLE_OPERATOR_2: /* Compare op with op on the top of stack */
            while (stack_p != 0 && stack[stack_p - 1] != LEFT_BRACKET && \
                   is_less_precedence(operator)) {
                out.val = stack[stack_p - 1];
                stack_p--;
                out.is_operator = 1;

                output[output_p] = out;
                output_p++;

                state = WAIT_FOR_TOKEN;
            }

            state = HANDLE_OPERATOR_3;
            break;
        case HANDLE_OPERATOR_3: /* Make some action with operator */
            stack[stack_p] = operator;
            stack_p++;
            state = WAIT_FOR_TOKEN;

            it++;
            break;
        case HANDLE_VAR:
            out.val = VAR;
            out.is_operator = 1;

            output[output_p] = out;
            output_p++;
            state = WAIT_FOR_TOKEN;
            it++;
            break;
        case HANDLE_LEFT_BRACKET: /* Left bracket, add to stack */
            stack[stack_p] = LEFT_BRACKET;
            stack_p++;
            
            state = WAIT_FOR_TOKEN;
            it++;
            break;
        case HANDLE_RIGHT_BRACKET: /* Right bracket, stay in this state
                                      until left bracket is got from stack */
            while (stack[stack_p - 1] != LEFT_BRACKET) {
                out.val = stack[stack_p - 1];
                out.is_operator = 1;

                output[output_p] = out;
                output_p++;
                stack_p--;
            }

            /* Delete left bracket from stack */
            stack_p--;

            state = WAIT_FOR_TOKEN;
            it++;
            break;
        case RELEASE_STACK: /* End of expr, stay in this state
                               until stack isn't empty */
            while (stack_p > 0) {
                out.val = stack[stack_p - 1];
                out.is_operator = 1;

                output[output_p] = out;
                output_p++;
                stack_p--;
            }

            state = END;
            break;
        case END: /* End */
            puts("End of parsing");
            return 0;
        default:
            return 0;
        }
    }
}

