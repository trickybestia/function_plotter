from sys import argv

from cpu.utils import read_asm, compile_asm_to_file


def main():
    input_path = argv[1]
    output_path = argv[2]

    asm = read_asm(input_path)

    compile_asm_to_file(asm, output_path)


main()
