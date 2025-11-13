from random import choice, randrange
from sys import argv

from cpu.assembly import Assembly, INSTRUCTIONS_LIST, JMPBase, CALL
from cpu.emulator import Emulator
from cpu.accelerators.dummy_accelerator import DummyAccelerator


def random_asm() -> Assembly:
    asm = Assembly()

    instructions_count = randrange(0, 100)

    for i in range(instructions_count):
        asm.label(str(i))

        instr = choice(INSTRUCTIONS_LIST).randomize()

        if isinstance(instr, JMPBase):
            instr.jmp_pc = str(randrange(0, instructions_count))
        elif isinstance(instr, CALL):
            instr.pc = str(randrange(0, instructions_count))

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

    asm.compile_to_file(instr_mem_path)

    asm.load_into_emulator(emulator)

    with open(asm_path, "w") as asm_file:
        for instr in asm.instructions:
            asm_file.write(f"{instr}\n")

    with open(log_path, "w") as log_file:
        for _ in range(1000):
            log_file.write(emulator.dump_state())
            log_file.write("\n")

            emulator.tick()


main()
