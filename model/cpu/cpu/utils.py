def ones(width: int) -> int:
    return 2**width - 1


def encode(value: int, lsb: int) -> int:
    return value << lsb


def decode(value: int, lsb: int, width: int) -> int:
    return (value >> lsb) & ones(width)
