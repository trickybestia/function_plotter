from sys import argv

from cpu.assembly import Assembly


def main():
    input_path = argv[1]
    output_path = argv[2]

    asm = Assembly.read_from_file(input_path)

    asm.compile_to_file(output_path)


main()
