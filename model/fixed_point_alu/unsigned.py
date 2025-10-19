from dataclasses import dataclass


@dataclass(frozen=True)
class Unsigned:
    value: int
    width: int

    @classmethod
    def max_signed(cls, width: int) -> "Unsigned":
        assert width > 0

        return Unsigned(2 ** (width - 1) - 1, width)

    @classmethod
    def min_signed(cls, width: int) -> "Unsigned":
        return cls.max_signed(width) + Unsigned(1, width)

    def __post_init__(self):
        assert self.width > 0
        assert 0 <= self.value < 2**self.width

    def extend(self, width: int) -> "Unsigned":
        assert width >= self.width

        return Unsigned(self, width)

    def sign_extend(self, width: int) -> "Unsigned":
        assert width >= self.width

        if self[self.width - 1]:
            sign_bits = (2**width - 1) ^ (2**self.width - 1)

            return Unsigned(sign_bits | self.value, width)

        return Unsigned(self.value, width)

    def signed_value(self) -> int:
        if self[self.width - 1]:
            return -(-self.sign_extend(self.width + 1)).value
        else:
            return self.value

    def truncate(self, width: int) -> "Unsigned":
        assert 1 <= width <= self.width

        return Unsigned(self.value & (2**width - 1), width)

    def saturating_add(self, other: "Unsigned") -> "Unsigned":
        assert self.width == other.width

        result_with_overflow = self + other

        if (
            self.signed_value() >= 0
            and other.signed_value() >= 0
            and result_with_overflow.signed_value() < 0
        ):
            return Unsigned.max_signed(self.width)
        elif (
            self.signed_value() < 0
            and other.signed_value() < 0
            and result_with_overflow.signed_value() >= 0
        ):
            return Unsigned.min_signed(self.width)
        else:
            return result_with_overflow

    def saturating_sub(self, other: "Unsigned") -> "Unsigned":
        assert self.width == other.width

        result_with_overflow = self.sign_extend(
            self.width + 1
        ) - other.sign_extend(other.width + 1)

        if (
            result_with_overflow.signed_value()
            < Unsigned.min_signed(self.width).signed_value()
        ):
            return Unsigned.min_signed(self.width)
        elif (
            result_with_overflow.signed_value()
            > Unsigned.max_signed(self.width).signed_value()
        ):
            return Unsigned.max_signed(self.width)
        else:
            return result_with_overflow.truncate(self.width)

    def __add__(self, other: "Unsigned") -> "Unsigned":
        assert self.width == other.width

        return Unsigned(
            (self.value + other.value) % (2**self.width), self.width
        )

    def __sub__(self, other: "Unsigned") -> "Unsigned":
        assert self.width == other.width

        return Unsigned(
            (2**self.width + self.value - other.value) % (2**self.width),
            self.width,
        )

    def __invert__(self) -> "Unsigned":
        return Unsigned(2**self.width - self.value - 1, self.width)

    def __neg__(self) -> "Unsigned":
        return ~self + Unsigned(1, self.width)

    def __getitem__(self, index: int) -> int:
        assert 0 <= index < self.width

        return (self.value >> index) & 1

    def __int__(self) -> int:
        return self.value

    def __str__(self) -> str:
        return f"{self.width}'d{self.value}"

    def to_str_signed(self) -> str:
        if self[self.width - 1]:
            # negative number

            abs_value = -self.sign_extend(self.width + 1)

            return f"-{self.width}'d{abs_value.value}"
        else:
            # non-negative number

            return str(self)

    def fixed_point_parts(
        self, integer_part_width: int, fractional_part_width: int
    ) -> tuple["Unsigned", "Unsigned"]:
        """Returns (integer_part, fractional_part)"""

        assert self.width == integer_part_width + fractional_part_width

        return Unsigned(
            self.value >> fractional_part_width, integer_part_width
        ), Unsigned(
            self.value & (2**fractional_part_width - 1), fractional_part_width
        )

    def to_str_fixed_point_signed(
        self, integer_part_width: int, fractional_part_width: int
    ) -> str:
        if self[self.width - 1]:
            # negative number

            integer_part, fractional_part = (
                -self.sign_extend(
                    integer_part_width + fractional_part_width + 1
                )
            ).fixed_point_parts(integer_part_width + 1, fractional_part_width)

            return f"-{integer_part.value}.({fractional_part.value}/{2**fractional_part_width})"
        else:
            # non-negative number

            integer_part, fractional_part = self.fixed_point_parts(
                integer_part_width, fractional_part_width
            )

            return f"{integer_part.value}.({fractional_part.value}/{2**fractional_part_width})"
