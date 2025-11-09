from .emulator import INSTRUCTION_WIDTH, Emulator
from .assembly import INSTRUCTIONS_DICT, Assembly


def dump_emulator_state(emulator: Emulator) -> str:
    return f"executed: {emulator.executed_instructions_count}; pc: {emulator.pc}; regs: {emulator.regs}"


def compile_asm_to_file(asm: Assembly, filename: str):
    with open(filename, "w") as file:
        for instr in asm.compile():
            for word in instr.encode():
                bits_str = bin(word)[2:].rjust(INSTRUCTION_WIDTH, "0")

                file.write(bits_str + "\n")


def load_asm_into_emulator(asm: Assembly, emulator: Emulator):
    i = 0

    for instr in asm.compile():
        for word in instr.encode():
            emulator.instructions_mem[i] = word

            i += 1


def read_asm(input_path: str) -> Assembly:
    asm = Assembly()

    with open(input_path, "r") as input_file:
        while (line := input_file.readline()) != "":
            line_without_comment = line.split("#")[0]
            line_parts = line_without_comment.replace(",", " ").split()

            if len(line_parts) == 0:
                continue
            elif len(line_parts) == 1 and line_parts[0][-1] == ":":
                asm.label(line_parts[0][:-1])

                continue

            op, args = line_parts[0], line_parts[1:]

            asm.instruction(INSTRUCTIONS_DICT[op].parse_args(args))

    return asm
