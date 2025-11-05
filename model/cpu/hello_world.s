    lh r1, 0
    ll r1, 1
    ll r1, 'H'
    wacc r1, acc0
    ll r1, 'e'
    wacc r1, acc0
    ll r1, 'l'
    wacc r1, acc0
    ll r1, 'l'
    wacc r1, acc0
    ll r1, 'o'
    wacc r1, acc0
    ll r1, 32 # 32 is space symbol
    wacc r1, acc0
    ll r1, 'w'
    wacc r1, acc0
    ll r1, 'o'
    wacc r1, acc0
    ll r1, 'r'
    wacc r1, acc0
    ll r1, 'l'
    wacc r1, acc0
    ll r1, 'd'
    wacc r1, acc0
    ll r1, '!'
    wacc r1, acc0
    ll r1, '!'
    wacc r1, acc0
    ll r1, '!'
    wacc r1, acc0
    ll r1, 10 # 10 is LF (\n) symbol
    wacc r1, acc0
loop:
    jmp loop
