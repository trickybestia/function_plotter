# WORK IN PROGRESS
# r15 - cursor position
# r14 - text buffer length

wait_swap_loop:
    jmpncr acc0, wait_swap_loop
    racc r0, acc0

    # handle keyboard

handle_keyboard_loop:
    jmpncr acc4, end_handle_keyboard_loop
    racc r1, acc4
    li r2, 1
    jmpeq r1, r2, match_arrow_left
    li r2, 2
    jmpeq r1, r2, match_arrow_right
    li r2, 8 # backspace symbol
    jmpeq r1, r2, match_backspace
match_arrow_left:
    jmpeq r15, r0, handle_keyboard_loop
    sub r15, r15, r2
    jmp handle_keyboard_loop
match_arrow_right:
    jmpeq r14, r0, handle_keyboard_loop
    li r2, 1
    sub r13, r15, r2 # r13 = text buffer length - 1
    jmpge r15, r13, handle_keyboard_loop
    sub r15, r15, r2handle_keyboard_loop
    jmp handle_keyboard_loop
match_backspace:

end_handle_keyboard_loop:

    wacc r0, acc2 # start fill_drawer

wait_fill_drawer_loop:
    jmpncw acc2, wait_fill_drawer_loop

    wacc r0, acc1 # x1 = 0
    wacc r0, acc1 # y1 = 0
    wacc r1, acc1 # x2 = 300
    wacc r1, acc1 # y2 = 300

wait_line_drawer_loop_1:
    jmpncw acc1, wait_line_drawer_loop_1

    wacc r1, acc1 # x1 = 300
    wacc r1, acc1 # y1 = 300
    wacc r2, acc1 # x2 = 100
    wacc r1, acc1 # y2 = 300

wait_line_drawer_loop_2:
    jmpncw acc1, wait_line_drawer_loop_2

    jmp wait_swap_loop
