from sys import argv

from cpu.utils import read_asm
from cpu.emulator import INSTRUCTION_WIDTH
from cpu.assembly import Assembly


def write_asm_to_file(asm: Assembly, filename: str):
    with open(filename, "w") as file:
        for instr in asm.compile():
            for word in instr.encode():
                bits_str = bin(word)[2:].rjust(INSTRUCTION_WIDTH, "0")

                file.write(bits_str + "\n")


def main():
    input_path = argv[1]
    output_path = argv[2]

    asm = read_asm(input_path)

    write_asm_to_file(asm, output_path)


main()
