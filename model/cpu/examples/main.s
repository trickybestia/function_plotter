# WORK IN PROGRESS
# r14 - cursor position
# r13 - text buffer length

    li r14, 0
    li r13, 0

    li r1, 1

    li r2, '2'
    store r13, r2
    add r13, r13, r1
    add r14, r14, r1

    li r2, '0'
    store r13, r2
    add r13, r13, r1
    add r14, r14, r1

    li r2, '0'
    store r13, r2
    add r13, r13, r1
    add r14, r14, r1

wait_swap_loop:
    jmpncr acc0, wait_swap_loop
    racc r0, acc0

    # handle keyboard

handle_keyboard_loop:
    jmpncr acc4, end_handle_keyboard_loop
    racc r1, acc4 # r1 = symbol
    li r2, 1
    jmpeq r1, r2, match_arrow_left
    li r2, 2
    jmpeq r1, r2, match_arrow_right
    li r2, 3
    jmpeq r1, r2, match_backspace
    # handle symbol insertion
    add r2, r14, r0
    call r15, insert_symbol
    li r1, 1
    add r14, r14, r1
    jmp handle_keyboard_loop
match_arrow_left:
    jmpeq r14, r0, handle_keyboard_loop
    sub r14, r14, r2
    jmp handle_keyboard_loop
match_arrow_right:
    jmpeq r13, r14, handle_keyboard_loop
    li r2, 1
    add r14, r14, r2
    jmp handle_keyboard_loop
match_backspace:
    jmpeq r14, r0, handle_keyboard_loop
    li r1, 1
    sub r14, r14, r1
    add r1, r14, r0
    call r15, remove_symbol
    jmp handle_keyboard_loop

end_handle_keyboard_loop:

    wacc r0, acc2 # start fill_drawer

wait_fill_drawer_loop:
    jmpncw acc2, wait_fill_drawer_loop

    li r2, 0 # symbol x
    li r3, 459 # symbol y
    li r4, 0 # symbol index
    li r6, 0 # cursor_left
    li r7, 0 # cursor_right

draw_symbols_loop:
    jmpeq r4, r13, end_draw_symbols_loop

    wacc r2, acc3 # symbol x
    wacc r3, acc3 # symbol y
    load r5, r4 # symbol
    wacc r5, acc3 # symbol
    ll r6, 0
    jmpne r4, r14 skip_set_cursor_left
    ll r6, 1
skip_set_cursor_left:
    ll r7, 0
    jmpeq r14, r0, skip_set_cursor_right
    li r8, 1
    sub r5, r14, r8
    jmpne r5, r4, skip_set_cursor_right
    ll r7, 1
skip_set_cursor_right:
    wacc r6, acc3 # cursor_left
    wacc r7, acc3 # cursor_right

    li r5, 1
    add r4, r4, r5
    li r5, 15
    add r2, r2, r5
    jmp draw_symbols_loop

end_draw_symbols_loop:
    jmpncw acc3, end_draw_symbols_loop

    call r15, parse_number

    li r3, 639

    wacc r0, acc1 # x1 = 0
    wacc r1, acc1 # y1 = parse_number() integer part
    wacc r3, acc1 # x2 = 639
    wacc r1, acc1 # y2 = parse_number() integer part

wait_line_drawer_loop:
    jmpncw acc1, wait_line_drawer_loop

    jmp wait_swap_loop

# Removes symbol from text buffer
# r1 - index
# r15 - return address
remove_symbol:
    li r2, 1 # r2 = 1
    sub r3, r13, r2 # r3 = text buffer length - 1

    jmpeq r1, r3, remove_symbol_done

    add r4, r1, r0 # r4 = j = index
    sub r7, r3, r2 # r7 = text buffer length - 2

remove_symbol_loop:
    add r5, r4, r2 # r5 = j + 1
    load r6, r5 # tmp = mem[r5]
    store r4, r6 # mem[j] = tmp

    jmpeq r4, r7, remove_symbol_done

    add r4, r4, r2 # j += 1

    jmp remove_symbol_loop

remove_symbol_done:
    sub r13, r13, r2

    lpcl r0, r15

# Inserts symbol into text buffer
# r1 - symbol
# r2 - index
# r15 - return address
insert_symbol:
    jmpeq r2, r13, insert_symbol_insert_done

    add r3, r13, r0 # r3 = j = text buffer length
    li r4, 1 # r4 = 1

insert_symbol_loop:
    sub r5, r3, r4 # r5 = j - 1
    load r6, r5 # r6 = tmp
    store r3, r6

    jmpeq r3, r2, insert_symbol_insert_done

    sub r3, r3, r4

    jmp insert_symbol_loop

insert_symbol_insert_done:
    store r2, r1
    li r3, 1
    add r13, r13, r3

    lpcl r0, r15

# Parses number from text buffer
# r15 - return address
# Returns:
# r1 - integer part
# r2 - fractional part
parse_number:
    add r1, r0, r0
    add r2, r0, r0

    jmpne r13, r0, parse_number_1

    lpcl r0, r15

parse_number_1:
    li r3, 10   # r3 = constant 10
    li r4, 1    # r4 = constant 1
    li r11, '0' # r11 = '0'

    add r5, r4, r0 # r5 = i = 1
    add r8, r4, r0 # minus = True

    load r6, r0 # r6 = mem[0] = symbol
    li r7, '-'

    jmpeq r6, r7, parse_number_skip_reset_minus

    add r8, r0, r0 # minus = False
    add r5, r0, r0 # r5 = i = 0

parse_number_skip_reset_minus:
    ll r7, '.'
    li r9, 2 # OP_MUL

parse_number_loop_integer:
    jmpne r5, r13, parse_number_2

    lpcl r0, r15

parse_number_2:
    load r6, r5 # r6 = mem[r5] = symbol

    jmpne r6, r7, parse_number_loop_integer_skip_match_dot

    add r5, r5, r4
    jmp parse_number_parse_fractional_part

parse_number_loop_integer_skip_match_dot:
    wacc r9, acc5 # | result integer part *= 10
    wacc r1, acc5 # |
    wacc r0, acc5 # |
    wacc r3, acc5 # |
    wacc r0, acc5 # |
    racc r1, acc5 # |
    racc r0, acc5 # |

    sub r6, r6, r11 # r6 = r6 - '0'
    add r1, r1, r6  # result integer part += r6

    add r5, r5, r4 # i += const_1

    jmp parse_number_loop_integer

parse_number_parse_fractional_part:
    add r10, r3, r0 # r10 = j = const_10

parse_number_loop_fractional:
    # TODO: result += int(s[i]) / j

    wacc r9, acc5 # | result *= 10
    wacc r0, acc5 # |
    wacc r2, acc5 # |
    wacc r3, acc5 # |
    wacc r0, acc5 # |
    racc r2, acc5 # |
    racc r0, acc5 # |

    add r5, r5, r4 # i += const_1

    jmp parse_number_loop_fractional

parse_number_done:
    lpcl r0, r15
