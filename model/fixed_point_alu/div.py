from unsigned import Unsigned

# TODO: implement rounding by computing one more fractional digit of quotient


def get_bit(n: int, index: int) -> int:
    return int(n & (1 << index) != 0)


def set_bit(n: int, index: int) -> int:
    return n | (1 << index)


def divide(a: int, b: int, number_size_bits: int) -> int:
    """Custom __floordiv__ implementation close to one used in Verilog module fixed_point_div.

    Need to check that it behaves similarly.
    """

    remainder = 0
    quotient = 0

    for i in range(number_size_bits - 1, -1, -1):
        remainder = (remainder << 1) | get_bit(a, i)

        if remainder >= b:
            quotient = set_bit(quotient, i)
            remainder = remainder - b

    return quotient


def check_divide():
    NUMBER_WIDTH = 5

    for i in range(2**NUMBER_WIDTH):
        a = Unsigned(i, NUMBER_WIDTH)

        for j in range(2**NUMBER_WIDTH):
            b = Unsigned(j, NUMBER_WIDTH)

            assert (a // b).value == divide(i, j, NUMBER_WIDTH)


def main():
    check_divide()

    INTEGER_PART_WIDTH = 3
    FRACTIONAL_PART_WIDTH = 2
    NUMBER_WIDTH = INTEGER_PART_WIDTH + FRACTIONAL_PART_WIDTH

    for i in range(2**NUMBER_WIDTH):
        a = Unsigned(i, NUMBER_WIDTH)

        for j in range(2**NUMBER_WIDTH):
            b = Unsigned(j, NUMBER_WIDTH)

            print(
                f"a: {int(a)}, b: {int(b)}, result: {int(a.fixed_point_saturating_div(b, INTEGER_PART_WIDTH, FRACTIONAL_PART_WIDTH))}"
            )


main()
