    li r1, 300
    li r2, 100

wait_swap_loop:
    jmpncr acc0, wait_swap_loop
    racc r0, acc0

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
