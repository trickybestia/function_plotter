from .emulator import Emulator
from .assembly import INSTRUCTIONS_DICT, Assembly


def dump_emulator_state(emulator: Emulator) -> str:
    return f"executed_instructions_count: {emulator.executed_instructions_count}, pc: {emulator.pc}, regs[1:15]: {emulator.regs}, data_mem: {emulator.data_mem}"


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
