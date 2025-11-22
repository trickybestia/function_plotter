from math import sin
from random import randint
from sys import argv
from time import sleep

from serial import Serial


def sample_signal(t: int) -> int:
    return min(
        255,
        max(0, round((sin(t / 30) + 1) * 255 / 2) + randint(-20, 20)),
    )


def main():
    port = argv[1]
    baud_rate = int(argv[2])

    serial = Serial(port, baud_rate)

    t = 0

    while True:
        serial.write([sample_signal(t)])

        sleep(0.01)

        t += 1


main()
