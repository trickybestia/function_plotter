from random import choice, randrange

from cpu.assembly import Assembly, INSTRUCTIONS_LIST, JMPBase
from cpu.emulator import Emulator
from cpu.utils import load_asm_into_emulator
from cpu.accelerators.dummy_accelerator import DummyAccelerator


def random_asm() -> Assembly:
    asm = Assembly()

    instructions_count = randrange(0, 512)

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
    while True:
        emulator = test_emulator()
        asm = random_asm()

        load_asm_into_emulator(asm, emulator)

        for tick in range(1000):
            emulator.tick()


main()
