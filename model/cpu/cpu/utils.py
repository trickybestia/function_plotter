def read_mem(path: str) -> list[int]:
    result = []

    with open(path, "r") as file:
        while (line := file.readline()) != "":
            line = line.split("/", 2)[0]

            result.append(int(line, 2))

    return result


def ones(width: int) -> int:
    return 2**width - 1


def encode(value: int, lsb: int) -> int:
    return value << lsb


def decode(value: int, lsb: int, width: int) -> int:
    return (value >> lsb) & ones(width)
