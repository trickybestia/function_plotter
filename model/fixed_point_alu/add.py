from unsigned import Unsigned


def main():
    INTEGER_PART_WIDTH = 3
    FRACTIONAL_PART_WIDTH = 2
    NUMBER_WIDTH = INTEGER_PART_WIDTH + FRACTIONAL_PART_WIDTH

    for i in range(2**NUMBER_WIDTH):
        a = Unsigned(i, NUMBER_WIDTH)

        for j in range(2**NUMBER_WIDTH):
            b = Unsigned(j, NUMBER_WIDTH)

            print(
                f"a: {int(a)}, b: {int(b)}, result: {int(a.saturating_add(b))}"
            )


main()
