from unsigned import Unsigned


# https://en.wikipedia.org/wiki/Exponentiation_by_squaring
def pow(value: int, power: int) -> int:
    """Custom __pow__ implementation close to one used in Verilog module fixed_point_div.

    Need to check that it behaves similarly.
    """

    if power == 0:
        return 1

    result = 1

    while power != 0:
        if power & 1:
            result *= value

        value *= value
        power >>= 1

    return result


def check_pow():
    NUMBER_WIDTH = 5

    for i in range(2**NUMBER_WIDTH):
        a = Unsigned(i, NUMBER_WIDTH)

        for j in range(2**NUMBER_WIDTH):
            b = Unsigned(j, NUMBER_WIDTH)

            assert (a**b).value == pow(i, j) % (2**NUMBER_WIDTH)


def main():
    check_pow()

    INTEGER_PART_WIDTH = 3
    FRACTIONAL_PART_WIDTH = 2
    NUMBER_WIDTH = INTEGER_PART_WIDTH + FRACTIONAL_PART_WIDTH

    for i in range(2**NUMBER_WIDTH):
        a = Unsigned(i, NUMBER_WIDTH)

        for j in range(2**NUMBER_WIDTH):
            b = Unsigned(j, NUMBER_WIDTH)

            print(
                f"a: {a.to_str_fixed_point_signed(INTEGER_PART_WIDTH, FRACTIONAL_PART_WIDTH)}, b: {b.to_str_fixed_point_signed(INTEGER_PART_WIDTH, FRACTIONAL_PART_WIDTH)}, result: {a.fixed_point_saturating_pow(b, INTEGER_PART_WIDTH, FRACTIONAL_PART_WIDTH).to_str_fixed_point_signed(INTEGER_PART_WIDTH, FRACTIONAL_PART_WIDTH)}"
            )


main()
