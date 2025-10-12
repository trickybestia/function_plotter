#include <stdio.h>

#include "config.h"

extern output_t output[OUTPUT_SIZE];
extern int output_p;

static void print_output() {
    for (int i = 0; i < output_p; i++) {
        if (output[i].is_operator)
            switch (output[i].val) {
            case PLUS:
                printf("+\n");
                break;
            case MINUS:
                printf("-\n");
                break;
            case MULT:
                printf("*\n");
                break;
            case DIV:
                printf("/\n");
                break;
            case POWER:
                printf("^\n");
                break;
            case VAR:
                printf("x\n");
                break;
            }

        else
            printf("%d\n", output[i].val);
    }
}


int main() {
    
    parse("2 + 2");
    print_output();

    output_p = 0;
    parse("12 + 2 - 5");
    print_output();

    output_p = 0;
    parse("(12 + (2 - 5)) * 6");
    print_output();

    output_p = 0;
    parse("1 + 2 * 6 ^ 3");
    print_output();

    output_p = 0;
    parse("(x - 6) + x^2 - 5");
    print_output();
    return 0;
}
