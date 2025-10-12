#include "config.h"

#include <math.h>

extern output_t output[OUTPUT_SIZE];
extern int output_p;

int stack[STACK_SIZE];
int stack_p = 0;

enum {FETCH_VAL = 0, HANDLE_VAL, LOAD_NUMBER_TO_STACK, LOAD_VAR_TO_STACK, \
      MATH_OP, MATH_OP_2, MATH_OP_3, END};

int evaluate(int x) {
    int state = 0, it = 0, reg1, reg2, ans;
    output_t out;
    
    while(1) {
        out = output[it];

        if (output_p == it)
            state = END;

        switch (state) {
        case FETCH_VAL: /* Get value from output */
            out = output[output_p - 1];
            state = HANDLE_VAL; 
            break;
        case HANDLE_VAL:
            if (out.is_operator && out.val == VAR)
                state = LOAD_VAR_TO_STACK;
            else if (out.is_operator)
                state = MATH_OP;
            else if (!out.is_operator)
                state = LOAD_NUMBER_TO_STACK;
            break;
        case LOAD_NUMBER_TO_STACK:
            stack[stack_p] = out.val;
            stack_p++;
            it++;
            state = FETCH_VAL; 
            break;
        case LOAD_VAR_TO_STACK: 
            stack[stack_p] = x;
            stack_p++;
            it++;
            state = FETCH_VAL;
            break;
        case MATH_OP:
            reg1 = stack[stack_p - 1];
            reg2 = stack[stack_p - 2];
            state = MATH_OP_2;
            break;
        case MATH_OP_2:
            switch (out.val) {
            case PLUS:
                ans = reg1 + reg2;
                break;
            case MINUS:
                ans = reg2 - reg1;
                break;
            case MULT:
                ans = reg1 * reg2;
                break;
            case DIV:
                ans = reg2 / reg1;
                break;
            case POWER:
                ans = (int)pow(reg2, reg1);
                break;
            }
            state = MATH_OP_3; 
            
            break;
        case MATH_OP_3:
            stack_p--;
            stack[stack_p - 1] = ans;
            it++;
            state = FETCH_VAL;
            break;
        case END:
            goto exitlbl;
            break;
        }
    }

 exitlbl:
    stack_p = 0; 
    return stack[0];
}
