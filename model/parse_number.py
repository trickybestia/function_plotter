def parse_number(s: str) -> float:
    const_10 = 10
    const_1 = 1

    if s[0] == "-":
        minus = True
        i = const_1
    else:
        minus = False
        i = 0

    result = 0

    while i != len(s):
        symbol = s[i]

        if symbol == ".":
            i += const_1

            break

        result *= const_10
        result += int(s[i])
        i += const_1

    j = const_10

    while i != len(s):
        result += int(s[i]) / j

        j *= const_10
        i += const_1

    if minus:
        result = 0 - result

    return result


def main():
    while True:
        print(parse_number(input()))


main()
