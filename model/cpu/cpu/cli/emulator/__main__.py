from sys import argv

from cpu.utils import dump_emulator_state, read_asm
from cpu.emulator import Emulator


def main():
    input_path = argv[1]
    ticks_count = int(argv[2])

    asm = read_asm(input_path)

    emulator = Emulator()

    for i, instr in enumerate(asm.compile()):
        emulator.instructions_mem[i] = instr

    for _ in range(ticks_count):
        print(dump_emulator_state(emulator))

        emulator.tick()


main()
