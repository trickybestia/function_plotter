# r14 - data buffer next sample index
# r13 - data buffer length

    add r14, r0, r0 # r14 = 0
    li r13, 1000    # r13 = 1000
    
    add r1, r0, r0 # r1 = 0
    li r2, 1       # r2 = 1
reset_mem_loop:
    jmpeq r1, r13, wait_swap_loop

    store r1, r0
    add r1, r1, r2

    jmp reset_mem_loop

wait_swap_loop:
    call r15, read_samples # read_samples while waiting for swap
    jmpncr acc0, wait_swap_loop
    racc r0, acc0

    wacc r0, acc2 # start fill_drawer

wait_fill_drawer_loop:
    call r15, read_samples # read_samples while waiting for fill drawer to finish
    jmpncw acc2, wait_fill_drawer_loop

    li r2, 640      # r2 = 640
    li r3, 1        # r3 = 1
    add r1, r3, r0  # r1 = i = 0
    add r8, r0, r0  # r8 = previous i
    li r6, 368      # r6 = 480 / 2 + 256 / 2
    add r4, r14, r0 # r4 = data buffer index

    sub r4, r4, r3

    jmpne r4, r0, first_skip_load_r13

    add r4, r13, r0
first_skip_load_r13:
    sub r4, r4, r3

    load r7, r4    # r7 = previous y
    sub r7, r6, r7

draw_samples_loop:
    jmpeq r1, r2, wait_swap_loop

    jmpne r4, r0, loop_skip_load_r13

    add r4, r13, r0
loop_skip_load_r13:
    sub r4, r4, r3

    load r5, r4    # y = mem[r4]
    sub r5, r6, r5 # y = r6 - y

    wacc r8, acc1
    wacc r7, acc1
    wacc r1, acc1
    wacc r5, acc1

    add r8, r1, r0 # previous i = i
    add r7, r5, r0 # previous y = y
    add r1, r1, r3 # i++

wait_line_drawer_loop:
    jmpncw acc1, wait_line_drawer_loop

    jmp draw_samples_loop


# r15 - return address
read_samples:
    jmpncr acc7, read_samples_done

    racc r1, acc7    # r1 - new sample
    store r14, r1    # mem[r14] = new sample
    ll r1, 1         # r1 = 1
    add r14, r14, r1 # r14++

    jmpne r14, r13, read_samples

    add r14, r0, r0 # r14 = 0

    jmp read_samples

read_samples_done:
    lpcl r0, r15
