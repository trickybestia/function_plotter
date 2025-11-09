from sys import argv

from cpu.utils import dump_emulator_state
from cpu.emulator import Emulator
from cpu.accelerators.dummy_accelerator import DummyAccelerator


def read_mem(path: str) -> list[int]:
    result = []

    with open(path, "r") as file:
        while (line := file.readline()) != "":
            result.append(int(line, 2))

    return result


def test_emulator() -> Emulator:
    result = Emulator()

    for i in range(len(result.accelerators)):
        result.accelerators[i] = DummyAccelerator()

    return result


def main():
    input_path = argv[1]
    ticks_count = int(argv[2])

    emulator = test_emulator()

    for i, instr in enumerate(read_mem(input_path)):
        emulator.instructions_mem[i] = instr

    for _ in range(ticks_count):
        print(dump_emulator_state(emulator))

        emulator.tick()


main()
