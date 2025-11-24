wait_swap_loop:
    jmpncr acc0, wait_swap_loop
    racc r0, acc0

    wacc r0, acc2 # start fill_drawer

wait_fill_drawer_loop:
    jmpncw acc2, wait_fill_drawer_loop

    li r1, 0 # symbol x
    li r2, 0 # symbol y
    li r5, 15 # symbol delta x
    
    li r3, 'h'
    call r4, draw_symbol
    add r1, r1, r5

    li r3, 'e'
    call r4, draw_symbol
    add r1, r1, r5

    li r3, 'l'
    call r4, draw_symbol
    add r1, r1, r5

    li r3, 'l'
    call r4, draw_symbol
    add r1, r1, r5

    li r3, 'o'
    call r4, draw_symbol
    add r1, r1, r5

    add r1, r1, r5 # space

    li r3, 'w'
    call r4, draw_symbol
    add r1, r1, r5

    li r3, 'o'
    call r4, draw_symbol
    add r1, r1, r5

    li r3, 'r'
    call r4, draw_symbol
    add r1, r1, r5

    li r3, 'l'
    call r4, draw_symbol
    add r1, r1, r5

    li r3, 'd'
    call r4, draw_symbol
    add r1, r1, r5

wait_symbol_drawer_loop:
    jmpncw acc3, wait_symbol_drawer_loop

    jmp wait_swap_loop

# draw symbol using symbol_drawer accelerator (acc3)
# args:
# r1 - symbol x coordinate
# r2 - symbol y coordinate
# r3 - symbol
# r4 - return address
draw_symbol:
    wacc r1, acc3
    wacc r2, acc3
    wacc r3, acc3
    wacc r0, acc3
    wacc r0, acc3
    lpcl r0, r4
