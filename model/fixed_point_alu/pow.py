# https://en.wikipedia.org/wiki/Exponentiation_by_squaring
def pow(value: int, power: int) -> int:
    if power == 0:
        return 1

    result = 1

    while power != 0:
        if power & 1:
            result *= value

        value *= value
        power >>= 1

    return result


def main():
    for value in range(10):
        for power in range(10):
            print(f"{value} ** {power} = {pow(value, power)}")

            if pow(value, power) != value**power:
                print(f"Error: {value ** power} expected")

                return


main()
