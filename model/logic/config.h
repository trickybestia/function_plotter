#ifndef CONFIG_H
#define CONFIG_H

#define STACK_SIZE 1024
#define OUTPUT_SIZE 1024

enum operators {PLUS = 1, MINUS, MULT, DIV, POWER, LEFT_BRACKET,
                RIGHT_BRACKET, VAR};
typedef unsigned short int oper_t;

typedef struct {
    int val;
    int is_operator;
} output_t;

int parse(const char* expr);
int evaluate(int x);
#endif
