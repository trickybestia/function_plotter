    lh r1, 0

wait_start_loop:
    jmpncr acc0, wait_start_loop

    ll r1, 0
    wacc r1, acc1 # x1 = 0
    wacc r1, acc1 # y1 = 0
    ll r1, 255
    wacc r1, acc1 # x2 = 255
    wacc r1, acc1 # y2 = 255

wait_line_drawer_loop_1:
    jmpncw acc1, wait_line_drawer_loop_1

    wacc r1, acc1 # x1 = 0
    wacc r1, acc1 # y1 = 0
    ll r1, 100
    wacc r1, acc1 # x2 = 100
    ll r1, 255
    wacc r1, acc1 # y2 = 255

wait_line_drawer_loop_2:
    jmpncw acc1, wait_line_drawer_loop_2

    wacc r0, acc0 # write anything to acc0 - set ready = 1
    jmp wait_start_loop
