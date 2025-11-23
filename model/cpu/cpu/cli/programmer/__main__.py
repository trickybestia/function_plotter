from sys import argv

from serial import Serial

from cpu.utils import read_mem


def main():
    port = argv[1]
    baud_rate = int(argv[2])
    mem_file_path = argv[3]

    serial = Serial(port, baud_rate)

    for word in read_mem(mem_file_path):
        msb = word >> 8
        lsb = word & 0xFF

        serial.write([msb, lsb])


main()
