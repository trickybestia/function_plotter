from random import choice, randrange
from sys import argv

from cpu.assembly import Assembly, INSTRUCTIONS_LIST, JMPBase
from cpu.emulator import Emulator
from cpu.utils import (
    load_asm_into_emulator,
    dump_emulator_state,
    compile_asm_to_file,
)
from cpu.accelerators.dummy_accelerator import DummyAccelerator


def random_asm() -> Assembly:
    asm = Assembly()

    instructions_count = randrange(0, 100)

    for i in range(instructions_count):
        asm.label(str(i))

        instr = choice(INSTRUCTIONS_LIST).randomize()

        if isinstance(instr, JMPBase):
            instr.jmp_pc = str(randrange(0, instructions_count))

        asm.instruction(instr)

    return asm


def test_emulator() -> Emulator:
    result = Emulator()

    for i in range(len(result.accelerators)):
        result.accelerators[i] = DummyAccelerator()

    return result


def main():
    asm_path = argv[1]
    instr_mem_path = argv[2]
    log_path = argv[3]

    emulator = test_emulator()
    asm = random_asm()

    compile_asm_to_file(asm, instr_mem_path)

    load_asm_into_emulator(asm, emulator)

    with open(asm_path, "w") as asm_file:
        for instr in asm.instructions:
            asm_file.write(f"{instr}\n")

    with open(log_path, "w") as log_file:
        for _ in range(1000):
            log_file.write(dump_emulator_state(emulator))
            log_file.write("\n")

            emulator.tick()


main()
