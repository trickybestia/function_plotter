    li r1, 0
    li r2, 15

wait_swap_loop:
    jmpncr acc0, wait_swap_loop
    racc r0, acc0

    wacc r0, acc2 # start fill_drawer

wait_fill_drawer_loop:
    jmpncw acc2, wait_fill_drawer_loop
    
    wacc r1, acc3
    wacc r0, acc3
    li r3, 'w'
    wacc r3, acc3
    wacc r0, acc3
    wacc r0, acc3
    add r1, r1, r2

    wacc r1, acc3
    wacc r0, acc3
    li r3, 'h'
    wacc r3, acc3
    wacc r0, acc3
    wacc r0, acc3
    add r1, r1, r2

    wacc r1, acc3
    wacc r0, acc3
    li r3, 'a'
    wacc r3, acc3
    wacc r0, acc3
    wacc r0, acc3
    add r1, r1, r2

    wacc r1, acc3
    wacc r0, acc3
    li r3, 't'
    wacc r3, acc3
    wacc r0, acc3
    wacc r0, acc3
    add r1, r1, r2

    wacc r1, acc3
    wacc r0, acc3
    li r3, 's'
    wacc r3, acc3
    wacc r0, acc3
    wacc r0, acc3
    add r1, r1, r2

    add r1, r1, r2 # space

    wacc r1, acc3
    wacc r0, acc3
    li r3, 'o'
    wacc r3, acc3
    wacc r0, acc3
    wacc r0, acc3
    add r1, r1, r2

    wacc r1, acc3
    wacc r0, acc3
    li r3, 'r'
    wacc r3, acc3
    wacc r0, acc3
    wacc r0, acc3
    add r1, r1, r2

    wacc r1, acc3
    wacc r0, acc3
    li r3, 'a'
    wacc r3, acc3
    wacc r0, acc3
    wacc r0, acc3
    add r1, r1, r2

    wacc r1, acc3
    wacc r0, acc3
    li r3, 'n'
    wacc r3, acc3
    wacc r0, acc3
    wacc r0, acc3
    add r1, r1, r2

    wacc r1, acc3
    wacc r0, acc3
    li r3, 'g'
    wacc r3, acc3
    wacc r0, acc3
    wacc r0, acc3
    add r1, r1, r2

    wacc r1, acc3
    wacc r0, acc3
    li r3, 'e'
    wacc r3, acc3
    wacc r0, acc3
    wacc r0, acc3
    add r1, r1, r2

    add r1, r1, r2 # space

    wacc r1, acc3
    wacc r0, acc3
    li r3, 'a'
    wacc r3, acc3
    wacc r0, acc3
    wacc r0, acc3
    add r1, r1, r2

    wacc r1, acc3
    wacc r0, acc3
    li r3, 'n'
    wacc r3, acc3
    wacc r0, acc3
    wacc r0, acc3
    add r1, r1, r2

    wacc r1, acc3
    wacc r0, acc3
    li r3, 'd'
    wacc r3, acc3
    wacc r0, acc3
    wacc r0, acc3
    add r1, r1, r2

    add r1, r1, r2 # space

    wacc r1, acc3
    wacc r0, acc3
    li r3, 's'
    wacc r3, acc3
    wacc r0, acc3
    wacc r0, acc3
    add r1, r1, r2

    wacc r1, acc3
    wacc r0, acc3
    li r3, 'o'
    wacc r3, acc3
    wacc r0, acc3
    wacc r0, acc3
    add r1, r1, r2

    wacc r1, acc3
    wacc r0, acc3
    li r3, 'n'
    wacc r3, acc3
    wacc r0, acc3
    wacc r0, acc3
    add r1, r1, r2

    wacc r1, acc3
    wacc r0, acc3
    li r3, 'd'
    wacc r3, acc3
    wacc r0, acc3
    wacc r0, acc3
    add r1, r1, r2

    wacc r1, acc3
    wacc r0, acc3
    li r3, 's'
    wacc r3, acc3
    wacc r0, acc3
    wacc r0, acc3
    add r1, r1, r2

    add r1, r1, r2 # space

    wacc r1, acc3
    wacc r0, acc3
    li r3, 'l'
    wacc r3, acc3
    wacc r0, acc3
    wacc r0, acc3
    add r1, r1, r2

    wacc r1, acc3
    wacc r0, acc3
    li r3, 'i'
    wacc r3, acc3
    wacc r0, acc3
    wacc r0, acc3
    add r1, r1, r2

    wacc r1, acc3
    wacc r0, acc3
    li r3, 'k'
    wacc r3, acc3
    wacc r0, acc3
    wacc r0, acc3
    add r1, r1, r2

    wacc r1, acc3
    wacc r0, acc3
    li r3, 'e'
    wacc r3, acc3
    wacc r0, acc3
    wacc r0, acc3
    add r1, r1, r2

    add r1, r1, r2 # space

    wacc r1, acc3
    wacc r0, acc3
    li r3, 'a'
    wacc r3, acc3
    wacc r0, acc3
    wacc r0, acc3
    add r1, r1, r2

    add r1, r1, r2 # space

    wacc r1, acc3
    wacc r0, acc3
    li r3, 'p'
    wacc r3, acc3
    wacc r0, acc3
    wacc r0, acc3
    add r1, r1, r2

    wacc r1, acc3
    wacc r0, acc3
    li r3, 'a'
    wacc r3, acc3
    wacc r0, acc3
    wacc r0, acc3
    add r1, r1, r2

    wacc r1, acc3
    wacc r0, acc3
    li r3, 'r'
    wacc r3, acc3
    wacc r0, acc3
    wacc r0, acc3
    add r1, r1, r2

    wacc r1, acc3
    wacc r0, acc3
    li r3, 'r'
    wacc r3, acc3
    wacc r0, acc3
    wacc r0, acc3
    add r1, r1, r2

    wacc r1, acc3
    wacc r0, acc3
    li r3, 'o'
    wacc r3, acc3
    wacc r0, acc3
    wacc r0, acc3
    add r1, r1, r2

    wacc r1, acc3
    wacc r0, acc3
    li r3, 't'
    wacc r3, acc3
    wacc r0, acc3
    wacc r0, acc3
    add r1, r1, r2

    li r1, 0
    li r4, 30

    wacc r1, acc3
    wacc r4, acc3
    li r3, 'a'
    wacc r3, acc3
    wacc r0, acc3
    wacc r0, acc3
    add r1, r1, r2

    add r1, r1, r2 # space

    wacc r1, acc3
    wacc r4, acc3
    li r3, 'c'
    wacc r3, acc3
    wacc r0, acc3
    wacc r0, acc3
    add r1, r1, r2

    wacc r1, acc3
    wacc r4, acc3
    li r3, 'a'
    wacc r3, acc3
    wacc r0, acc3
    wacc r0, acc3
    add r1, r1, r2

    wacc r1, acc3
    wacc r4, acc3
    li r3, 'r'
    wacc r3, acc3
    wacc r0, acc3
    wacc r0, acc3
    add r1, r1, r2

    wacc r1, acc3
    wacc r4, acc3
    li r3, 'r'
    wacc r3, acc3
    wacc r0, acc3
    wacc r0, acc3
    add r1, r1, r2

    wacc r1, acc3
    wacc r4, acc3
    li r3, 'o'
    wacc r3, acc3
    wacc r0, acc3
    wacc r0, acc3
    add r1, r1, r2

    wacc r1, acc3
    wacc r4, acc3
    li r3, 't'
    wacc r3, acc3
    wacc r0, acc3
    wacc r0, acc3
    add r1, r1, r2

wait_symbol_drawer_loop:
    jmpncw acc3, wait_symbol_drawer_loop

    jmp wait_swap_loop
