# Accelerator

## swap (`acc0`)

Sets `accel_can_read` flag to 1 when `swap` arrives, and resets the flag when the CPU reads from it.

The `accel_can_write` flag is always 0.

Example:

```
wait_swap_loop:
    # Can do something useful here
    # ...
    jmpncr acc0, wait_swap_loop
    racc r0, acc0
```

Alternatively, if blocking on read is allowed:

```
    racc r0, acc0
```

## Drawers

Since these accelerators access the same framebuffer, ensure that only one is active at a time.

### line_drawer (`acc1`)

Draws a line between points (`x1`, `y1`) and (`x2`, `y2`).  
Note: `x1`, `x2` must be less than `HOR_ACTIVE_PIXELS`, and `y1`, `y2` must be less than `VER_ACTIVE_PIXELS`.

Starts drawing as soon as points coordinates are received.

Sets `accel_can_write` to 1 if ready to receive point coordinates. Use `jmpncw` to check whether the `line_drawer` has finished drawing or is still in process.

The `accel_can_read` flag is always 0.

Example:

```
    li r1, 300

    wacc r0, acc1 # x1 = 0
    wacc r0, acc1 # y1 = 0
    wacc r1, acc1 # x2 = 300
    wacc r1, acc1 # y2 = 300

wait_line_drawer_loop:
    jmpncw acc1, wait_line_drawer_loop
```

### fill_drawer (`acc2`)

Fills the framebuffer with black pixels.

Starts when the CPU writes any data to it (the data itself is ignored).

Sets `accel_can_write` to 1 if ready to start. Use `jmpncw` to check whether the `fill_drawer` has finished drawing or is still in process.

The `accel_can_read` flag is always 0.

Example:

```
    wacc r0, acc2 # Start the fill_drawer

wait_fill_drawer_loop:
    jmpncw acc2, wait_fill_drawer_loop
```

### symbol_drawer (acc3)

Draws a symbol with the top-left corner at coordinates (`x`, `y`).  
Note: `x` must be less than `HOR_ACTIVE_PIXELS`, and `y` must be less than `VER_ACTIVE_PIXELS`.

Starts drawing as soon as all arguments are received.

Sets `accel_can_write` to 1 if ready to receive arguments. Use `jmpncw` to check whether the `symbol_drawer` has finished drawing or is still in process.

The `accel_can_read` flag is always 0.

Example:

```
    li r1, 0
    li r2, 0
    li r3, 'w'
    call r4, draw_symbol

# Draw a symbol using the symbol_drawer accelerator (acc3)
# Arguments:
# r1 - symbol x coordinate
# r2 - symbol y coordinate
# r3 - symbol
# r4 - return address
draw_symbol:
    wacc r1, acc3
    wacc r2, acc3
    wacc r3, acc3
    wacc r0, acc3 # cursor_left - draws a thin vertical line at the left edge of the symbol if set to 1
    wacc r0, acc3 # cursor_right - draws a thin vertical line at the right edge of the symbol if set to 1

draw_symbol_loop:
    jmpncw acc3, draw_symbol_loop

    lpcl r0, r4
```

## keyboard (acc4)

A FIFO buffer for keyboard input. By default, it stores up to 16 keys.  
Sets `accel_can_read` to 1 when the buffer is not empty.

See possible key codes in [ps2.v](../src/design/ps2.v).

The `accel_can_write` flag is always 0.

Example:

```
    racc r1, acc4 # r1 = symbol
    li r2, 1
    jmpeq r1, r2, match_arrow_left
    li r2, 2
    jmpeq r1, r2, match_arrow_right
    li r2, 3
    jmpeq r1, r2, match_backspace
    # Other keys handling
    # ...
    jmp match_end
match_arrow_left:
    # Arrow left key handling
    # ...
    jmp match_end
match_arrow_right:
    # Arrow right key handling
    # ...
    jmp match_end
match_backspace:
    # Backspace key handling
    # ...
match_end:
    # ...
```
