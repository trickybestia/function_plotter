def get_bit(n: int, index: int) -> int:
    return int(n & (1 << index) != 0)


def set_bit(n: int, index: int) -> int:
    return n | (1 << index)


def divide(a: int, b: int, number_size_bits: int) -> int:
    remainder = 0
    quotient = 0

    for i in range(number_size_bits - 1, -1, -1):
        remainder = (remainder << 1) | get_bit(a, i)

        if remainder >= b:
            quotient = set_bit(quotient, i)
            remainder = remainder - b

    return quotient


def main():
    for i in range(10):
        i *= 10

        for j in range(10):
            print(f"{i} // {j} = {divide(i, j, 10)}")


main()
