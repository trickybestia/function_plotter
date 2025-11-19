# CPU ISA

## Registers

The CPU contains sixteen 16-bit registers. Register r0 is hardwired to zero, registers r1-r15 are general-purpose.

## Data Memory

The data memory stores 16-bit words. The memory size can be configured in the Verilog implementation.

## Instruction Memory

The instruction memory stores 16-bit words. The memory size can be configured in the Verilog implementation.

## Accelerators

The CPU supports connection of up to 16 accelerators (acc0-acc15). The accelerators use the following interface:

| Direction    | Width | Name               |
| ------------ | ----- | ------------------ |
| CPU <- Accel | 1     | accel_can_read     |
| CPU <- Accel | 1     | accel_can_write    |
| CPU -> Accel | 1     | accel_read_enable  |
| CPU -> Accel | 1     | accel_write_enable |
| CPU <- Accel | 16    | accel_read_data    |
| CPU -> Accel | 16    | accel_write_data   |

## Instructions

The CPU executes every instruction in a single clock cycle. Each instruction occupies either one (INSTR_LEN = 1) or two (INSTR_LEN = 2) instruction memory words, totaling 16 or 32 bits respectively.

See [cpu_instructions_encoding.ods](./cpu_instructions_encoding.ods) for more information about bit fields encoding.

### ADD (SUB, AND, OR, XOR)

These instructions perform arithmetic and logical operations using the ALU.

INSTR_LEN = 1.

Format: `add rd, rs1, rs2`

Operation: `regs[rd] <- regs[rs1] + regs[rs2]`

Examples:
```
    add r1, r1, r2 # r1 = r1 + r2
```
```
    add r1, r2, r0 # r1 = r2 (using r0 as zero)
```

### LH (Load High)

INSTR_LEN = 1.

Loads an 8-bit immediate value into the high 8 bits of a register. The low bits remain unchanged.

Format: `lh rd, imm`

Operation: `regs[rd][15:8] <- imm`

### LL (Load Low)

INSTR_LEN = 1.

Loads an 8-bit immediate value into the low 8 bits of a register. The high bits remain unchanged.

Format: `ll rd, imm`

Operation: `regs[rd][7:0] <- imm`

### LI (Load Immediate) Pseudoinstruction

This pseudoinstruction compiles into two instructions: `ll` followed by `lh`. It loads a 16-bit immediate value into a register.

Format: `li rd, imm`

Operation: `regs[rd] <- imm`

Examples:
```
    li r1, 'a'        # ASCII character
    li r2, 97         # Decimal code of 'a'
    li r3, 0x61       # Hexadecimal code of 'a'
    li r4, 0o141      # Octal code of 'a'
    li r5, 0b01100001 # Binary code of 'a'
```

### JMP*

INSTR_LEN = 2.

These instructions perform a condition check and, if the condition is true, load `jmp_pc` into the `pc`.

| Instruction               | Condition                    |
| ------------------------- | ---------------------------- |
| `jmpeq rs1, rs2, jmp_pc`  | `regs[rs1] == regs[rs2]`     |
| `jmpne rs1, rs2, jmp_pc`  | `regs[rs1] != regs[rs2]`     |
| `jmplt rs1, rs2, jmp_pc`  | `regs[rs1] < regs[rs2]`      |
| `jmple rs1, rs2, jmp_pc`  | `regs[rs1] <= regs[rs2]`     |
| `jmpgt rs1, rs2, jmp_pc`  | `regs[rs1] > regs[rs2]`      |
| `jmpge rs1, rs2, jmp_pc`  | `regs[rs1] >= regs[rs2]`     |
| `jmpcr accel_id, jmp_pc`  | can read from accelerator    |
| `jmpcw accel_id, jmp_pc`  | can write to accelerator     |
| `jmpncr accel_id, jmp_pc` | cannot read from accelerator |
| `jmpncw accel_id, jmp_pc` | cannot write to accelerator  |

### JMP Pseudoinstruction

This pseudoinstruction performs an unconditional jump. It compiles into `jmpeq r0, r0, jmp_pc`.

Format: `jmp jmp_pc`

### LOAD

INSTR_LEN = 1.

Loads a value from data memory into a register.

Format: `load rd, rs1`

Operation: `regs[rd] <- data_mem[regs[rs1]]`

### STORE

INSTR_LEN = 1.

Stores a register's value in data memory.

Format: `store rs1, rs2`

Operation: `data_mem[regs[rs1]] <- regs[rs2]`

### WACC (Write to ACCelerator)

INSTR_LEN = 1.

Waits until `accel_can_write` is set to 1, then writes a register value to the specified accelerator.

Format: `wacc rs1, accel_id`

Operation: `accelerators[accel_id] <- regs[rs1]`

### RACC (Read from ACCelerator)

INSTR_LEN = 1.

Waits until `accel_can_read` is set to 1, then reads a value from the specified accelerator into a register.

Format: `racc rd, accel_id`

Operation: `regs[rd] <- accelerators[accel_id]`

### LPCL (Load PC and Link)

INSTR_LEN = 1.

Copies the next instruction address into register `rd` and loads the value from register `rs1` into the `pc`.

Operation: `regs[rd], pc <- pc + 1, regs[rs1]`

### CALL Pseudoinstruction

This pseudoinstruction performs a function call. It compiles into three instructions: `li rd, pc` (which compiles into 2 instructions itself) followed by `lpcl rd, rd`.

Format: `call rd, pc`

Example:
```
    # Main code
    call r15, function

# Arguments:
# r15 - return address
# Returns:
# r1 - result
function:
    # Function body
    # ...
    li r1, 12345
    lpcl r0, r15  # Set pc to return address
```
