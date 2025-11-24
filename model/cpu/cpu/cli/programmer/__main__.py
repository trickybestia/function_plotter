from sys import argv

from serial import Serial

from cpu.utils import read_mem

BYTES_PER_INSTRUCTION_MEMORY_WORD = 2


def mem_to_serial(mem: list[int], words_count: int) -> list[int]:
    result = [0] * words_count * BYTES_PER_INSTRUCTION_MEMORY_WORD

    for i in range(len(mem)):
        result[i * 2] = mem[i] >> 8
        result[i * 2 + 1] = mem[i] & 0xFF

    return result


def main():
    port = argv[1]
    baud_rate = int(argv[2])
    mem_file_path = argv[3]
    instr_mem_size = int(argv[4])

    mem = read_mem(mem_file_path)

    serial = Serial(port, baud_rate)

    serial.write(mem_to_serial(mem, instr_mem_size))


main()
