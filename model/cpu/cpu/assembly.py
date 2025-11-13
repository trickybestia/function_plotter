from dataclasses import dataclass
from typing import Self
from random import randrange

from . import emulator
from cpu.utils import ones


def _parse_int_or_label(s: str) -> str | int:
    try:
        return int(s)
    except:
        return s


def _format_jmp_pc(value: int) -> str:
    return str(value)


def _parse_reg_addr(s: str) -> int:
    assert s.startswith("r")

    return int(s[1:])


def _format_reg_addr(value: int) -> str:
    return f"r{value}"


def _parse_accel_id(s: str) -> int:
    assert s.startswith("acc")

    return int(s[3:])


def _format_accel_id(value: int) -> str:
    return f"acc{value}"


def _parse_imm(s: str) -> int:
    if s.startswith("0x"):  # hexadecimal
        return int(s[2:], 16)
    elif s.startswith("0o"):  # octal
        return int(s[2:], 8)
    elif s.startswith("0b"):  # binary
        return int(s[2:], 2)
    elif len(s) == 3 and s[0] == "'" and s[2] == "'":  # ASCII symbol
        return ord(s[1])
    else:  # decimal
        return int(s)


def _format_imm(value: int) -> str:
    return str(value)


class AssemblyInstruction:
    @classmethod
    def name(cls) -> str:
        return cls.__name__.lower()

    @classmethod
    def parse_args(cls, args: list[str]) -> Self:
        raise NotImplementedError()

    @classmethod
    def randomize(cls) -> Self:
        """Returns instance with valid randomized field values.
        Used for fuzzing.
        """

        raise NotImplementedError()

    def into_emulator_instructions(self) -> list[emulator.EmulatorInstruction]:
        raise NotImplementedError()

    def substitute_label(self, label: str, value: int): ...

    @staticmethod
    def __len__() -> int:
        return 1


@dataclass
class ADD(AssemblyInstruction):
    rd: int
    rs1: int
    rs2: int

    @classmethod
    def parse_args(cls, args: list[str]) -> Self:
        assert len(args) == 3

        return cls(
            _parse_reg_addr(args[0]),
            _parse_reg_addr(args[1]),
            _parse_reg_addr(args[2]),
        )

    @classmethod
    def randomize(cls) -> Self:
        return cls(
            randrange(0, emulator.REG_COUNT),
            randrange(0, emulator.REG_COUNT),
            randrange(0, emulator.REG_COUNT),
        )

    def into_emulator_instructions(self) -> list[emulator.EmulatorInstruction]:
        return [emulator.ADD(self.rd, self.rs1, self.rs2)]

    def __str__(self) -> str:
        return f"{self.name()} {_format_reg_addr(self.rd)}, {_format_reg_addr(self.rs1)}, {_format_reg_addr(self.rs2)}"


@dataclass
class SUB(AssemblyInstruction):
    rd: int
    rs1: int
    rs2: int

    @classmethod
    def parse_args(cls, args: list[str]) -> Self:
        assert len(args) == 3

        return cls(
            _parse_reg_addr(args[0]),
            _parse_reg_addr(args[1]),
            _parse_reg_addr(args[2]),
        )

    @classmethod
    def randomize(cls) -> Self:
        return cls(
            randrange(0, emulator.REG_COUNT),
            randrange(0, emulator.REG_COUNT),
            randrange(0, emulator.REG_COUNT),
        )

    def into_emulator_instructions(self) -> list[emulator.EmulatorInstruction]:
        return [emulator.SUB(self.rd, self.rs1, self.rs2)]

    def __str__(self) -> str:
        return f"{self.name()} {_format_reg_addr(self.rd)}, {_format_reg_addr(self.rs1)}, {_format_reg_addr(self.rs2)}"


@dataclass
class AND(AssemblyInstruction):
    rd: int
    rs1: int
    rs2: int

    @classmethod
    def parse_args(cls, args: list[str]) -> Self:
        assert len(args) == 3

        return cls(
            _parse_reg_addr(args[0]),
            _parse_reg_addr(args[1]),
            _parse_reg_addr(args[2]),
        )

    @classmethod
    def randomize(cls) -> Self:
        return cls(
            randrange(0, emulator.REG_COUNT),
            randrange(0, emulator.REG_COUNT),
            randrange(0, emulator.REG_COUNT),
        )

    def into_emulator_instructions(self) -> list[emulator.EmulatorInstruction]:
        return [emulator.AND(self.rd, self.rs1, self.rs2)]

    def __str__(self) -> str:
        return f"{self.name()} {_format_reg_addr(self.rd)}, {_format_reg_addr(self.rs1)}, {_format_reg_addr(self.rs2)}"


@dataclass
class OR(AssemblyInstruction):
    rd: int
    rs1: int
    rs2: int

    @classmethod
    def parse_args(cls, args: list[str]) -> Self:
        assert len(args) == 3

        return cls(
            _parse_reg_addr(args[0]),
            _parse_reg_addr(args[1]),
            _parse_reg_addr(args[2]),
        )

    @classmethod
    def randomize(cls) -> Self:
        return cls(
            randrange(0, emulator.REG_COUNT),
            randrange(0, emulator.REG_COUNT),
            randrange(0, emulator.REG_COUNT),
        )

    def into_emulator_instructions(self) -> list[emulator.EmulatorInstruction]:
        return [emulator.OR(self.rd, self.rs1, self.rs2)]

    def __str__(self) -> str:
        return f"{self.name()} {_format_reg_addr(self.rd)}, {_format_reg_addr(self.rs1)}, {_format_reg_addr(self.rs2)}"


@dataclass
class XOR(AssemblyInstruction):
    rd: int
    rs1: int
    rs2: int

    @classmethod
    def parse_args(cls, args: list[str]) -> Self:
        assert len(args) == 3

        return cls(
            _parse_reg_addr(args[0]),
            _parse_reg_addr(args[1]),
            _parse_reg_addr(args[2]),
        )

    @classmethod
    def randomize(cls) -> Self:
        return cls(
            randrange(0, emulator.REG_COUNT),
            randrange(0, emulator.REG_COUNT),
            randrange(0, emulator.REG_COUNT),
        )

    def into_emulator_instructions(self) -> list[emulator.EmulatorInstruction]:
        return [emulator.XOR(self.rd, self.rs1, self.rs2)]

    def __str__(self) -> str:
        return f"{self.name()} {_format_reg_addr(self.rd)}, {_format_reg_addr(self.rs1)}, {_format_reg_addr(self.rs2)}"


@dataclass
class LH(AssemblyInstruction):
    rd: int
    imm: int

    @classmethod
    def parse_args(cls, args: list[str]) -> Self:
        assert len(args) == 2

        return cls(_parse_reg_addr(args[0]), _parse_imm(args[1]))

    @classmethod
    def randomize(cls) -> Self:
        return cls(
            randrange(0, emulator.REG_COUNT),
            randrange(0, 2**emulator.IMM_WIDTH),
        )

    def into_emulator_instructions(self) -> list[emulator.EmulatorInstruction]:
        return [emulator.LH(self.rd, self.imm)]

    def __str__(self) -> str:
        return f"{self.name()} {_format_reg_addr(self.rd)}, {_format_imm(self.imm)}"


@dataclass
class LL(AssemblyInstruction):
    rd: int
    imm: int

    @classmethod
    def parse_args(cls, args: list[str]) -> Self:
        assert len(args) == 2

        return cls(_parse_reg_addr(args[0]), _parse_imm(args[1]))

    @classmethod
    def randomize(cls) -> Self:
        return cls(
            randrange(0, emulator.REG_COUNT),
            randrange(0, 2**emulator.IMM_WIDTH),
        )

    def into_emulator_instructions(self) -> list[emulator.EmulatorInstruction]:
        return [emulator.LL(self.rd, self.imm)]

    def __str__(self) -> str:
        return f"{self.name()} {_format_reg_addr(self.rd)}, {_format_imm(self.imm)}"


@dataclass
class LI(AssemblyInstruction):
    rd: int
    imm: int

    @classmethod
    def parse_args(cls, args: list[str]) -> Self:
        assert len(args) == 2

        return cls(_parse_reg_addr(args[0]), _parse_imm(args[1]))

    @classmethod
    def randomize(cls) -> Self:
        return cls(
            randrange(0, emulator.REG_COUNT),
            randrange(0, 2**emulator.REG_WIDTH),
        )

    def into_emulator_instructions(self) -> list[emulator.EmulatorInstruction]:
        return [
            emulator.LL(self.rd, self.imm & ones(emulator.IMM_WIDTH)),
            emulator.LH(self.rd, self.imm >> emulator.IMM_WIDTH),
        ]

    def __str__(self) -> str:
        return f"{self.name()} {_format_reg_addr(self.rd)}, {_format_imm(self.imm)}"

    @staticmethod
    def __len__() -> int:
        return 2


class JMPBase(AssemblyInstruction):
    def substitute_label(self, label: str, value: int):
        if self.jmp_pc == label:
            self.jmp_pc = value

    @staticmethod
    def __len__() -> int:
        return 2


@dataclass
class JMP(JMPBase):
    jmp_pc: int | str

    @classmethod
    def parse_args(cls, args: list[str]) -> Self:
        assert len(args) == 1

        return cls(_parse_int_or_label(args[0]))

    @classmethod
    def randomize(cls) -> Self:
        return cls(randrange(0, emulator.INSTRUCTION_MEM_SIZE))

    def into_emulator_instructions(self) -> list[emulator.EmulatorInstruction]:
        if isinstance(self.jmp_pc, str):
            raise Exception(f"Label {self.jmp_pc} has no value")

        return [emulator.JMP(emulator.JMPCond.EQ, 0, 0, self.jmp_pc)]

    def __str__(self) -> str:
        return f"{self.name()} {_format_jmp_pc(self.jmp_pc)}"


@dataclass
class JMPEQ(JMPBase):
    rs1: int
    rs2: int
    jmp_pc: int | str

    @classmethod
    def parse_args(cls, args: list[str]) -> Self:
        assert len(args) == 3

        return cls(
            _parse_reg_addr(args[0]),
            _parse_reg_addr(args[1]),
            _parse_int_or_label(args[2]),
        )

    @classmethod
    def randomize(cls) -> Self:
        return cls(
            randrange(0, emulator.REG_COUNT),
            randrange(0, emulator.REG_COUNT),
            randrange(0, emulator.INSTRUCTION_MEM_SIZE),
        )

    def into_emulator_instructions(self) -> list[emulator.EmulatorInstruction]:
        if isinstance(self.jmp_pc, str):
            raise Exception(f"Label {self.jmp_pc} has no value")

        return [
            emulator.JMP(emulator.JMPCond.EQ, self.rs1, self.rs2, self.jmp_pc)
        ]

    def __str__(self) -> str:
        return f"{self.name()} {_format_reg_addr(self.rs1)}, {_format_reg_addr(self.rs2)}, {_format_jmp_pc(self.jmp_pc)}"


@dataclass
class JMPNE(JMPBase):
    rs1: int
    rs2: int
    jmp_pc: int | str

    @classmethod
    def parse_args(cls, args: list[str]) -> Self:
        assert len(args) == 3

        return cls(
            _parse_reg_addr(args[0]),
            _parse_reg_addr(args[1]),
            _parse_int_or_label(args[2]),
        )

    @classmethod
    def randomize(cls) -> Self:
        return cls(
            randrange(0, emulator.REG_COUNT),
            randrange(0, emulator.REG_COUNT),
            randrange(0, emulator.INSTRUCTION_MEM_SIZE),
        )

    def into_emulator_instructions(self) -> list[emulator.EmulatorInstruction]:
        if isinstance(self.jmp_pc, str):
            raise Exception(f"Label {self.jmp_pc} has no value")

        return [
            emulator.JMP(emulator.JMPCond.NE, self.rs1, self.rs2, self.jmp_pc)
        ]

    def __str__(self) -> str:
        return f"{self.name()} {_format_reg_addr(self.rs1)}, {_format_reg_addr(self.rs2)}, {_format_jmp_pc(self.jmp_pc)}"


@dataclass
class JMPLT(JMPBase):
    rs1: int
    rs2: int
    jmp_pc: int | str

    @classmethod
    def parse_args(cls, args: list[str]) -> Self:
        assert len(args) == 3

        return cls(
            _parse_reg_addr(args[0]),
            _parse_reg_addr(args[1]),
            _parse_int_or_label(args[2]),
        )

    @classmethod
    def randomize(cls) -> Self:
        return cls(
            randrange(0, emulator.REG_COUNT),
            randrange(0, emulator.REG_COUNT),
            randrange(0, emulator.INSTRUCTION_MEM_SIZE),
        )

    def into_emulator_instructions(self) -> list[emulator.EmulatorInstruction]:
        if isinstance(self.jmp_pc, str):
            raise Exception(f"Label {self.jmp_pc} has no value")

        return [
            emulator.JMP(emulator.JMPCond.LT, self.rs1, self.rs2, self.jmp_pc)
        ]

    def __str__(self) -> str:
        return f"{self.name()} {_format_reg_addr(self.rs1)}, {_format_reg_addr(self.rs2)}, {_format_jmp_pc(self.jmp_pc)}"


@dataclass
class JMPLE(JMPBase):
    rs1: int
    rs2: int
    jmp_pc: int | str

    @classmethod
    def parse_args(cls, args: list[str]) -> Self:
        assert len(args) == 3

        return cls(
            _parse_reg_addr(args[0]),
            _parse_reg_addr(args[1]),
            _parse_int_or_label(args[2]),
        )

    @classmethod
    def randomize(cls) -> Self:
        return cls(
            randrange(0, emulator.REG_COUNT),
            randrange(0, emulator.REG_COUNT),
            randrange(0, emulator.INSTRUCTION_MEM_SIZE),
        )

    def into_emulator_instructions(self) -> list[emulator.EmulatorInstruction]:
        if isinstance(self.jmp_pc, str):
            raise Exception(f"Label {self.jmp_pc} has no value")

        return [
            emulator.JMP(emulator.JMPCond.LE, self.rs1, self.rs2, self.jmp_pc)
        ]

    def __str__(self) -> str:
        return f"{self.name()} {_format_reg_addr(self.rs1)}, {_format_reg_addr(self.rs2)}, {_format_jmp_pc(self.jmp_pc)}"


@dataclass
class JMPGT(JMPBase):
    rs1: int
    rs2: int
    jmp_pc: int | str

    @classmethod
    def parse_args(cls, args: list[str]) -> Self:
        assert len(args) == 3

        return cls(
            _parse_reg_addr(args[0]),
            _parse_reg_addr(args[1]),
            _parse_int_or_label(args[2]),
        )

    @classmethod
    def randomize(cls) -> Self:
        return cls(
            randrange(0, emulator.REG_COUNT),
            randrange(0, emulator.REG_COUNT),
            randrange(0, emulator.INSTRUCTION_MEM_SIZE),
        )

    def into_emulator_instructions(self) -> list[emulator.EmulatorInstruction]:
        if isinstance(self.jmp_pc, str):
            raise Exception(f"Label {self.jmp_pc} has no value")

        return [
            emulator.JMP(emulator.JMPCond.GT, self.rs1, self.rs2, self.jmp_pc)
        ]

    def __str__(self) -> str:
        return f"{self.name()} {_format_reg_addr(self.rs1)}, {_format_reg_addr(self.rs2)}, {_format_jmp_pc(self.jmp_pc)}"


@dataclass
class JMPGE(JMPBase):
    rs1: int
    rs2: int
    jmp_pc: int | str

    @classmethod
    def parse_args(cls, args: list[str]) -> Self:
        assert len(args) == 3

        return cls(
            _parse_reg_addr(args[0]),
            _parse_reg_addr(args[1]),
            _parse_int_or_label(args[2]),
        )

    @classmethod
    def randomize(cls) -> Self:
        return cls(
            randrange(0, emulator.REG_COUNT),
            randrange(0, emulator.REG_COUNT),
            randrange(0, emulator.INSTRUCTION_MEM_SIZE),
        )

    def into_emulator_instructions(self) -> list[emulator.EmulatorInstruction]:
        if isinstance(self.jmp_pc, str):
            raise Exception(f"Label {self.jmp_pc} has no value")

        return [
            emulator.JMP(emulator.JMPCond.GE, self.rs1, self.rs2, self.jmp_pc)
        ]

    def __str__(self) -> str:
        return f"{self.name()} {_format_reg_addr(self.rs1)}, {_format_reg_addr(self.rs2)}, {_format_jmp_pc(self.jmp_pc)}"


@dataclass
class JMPCR(JMPBase):
    accel_id: int
    jmp_pc: int | str

    @classmethod
    def parse_args(cls, args: list[str]) -> Self:
        assert len(args) == 2

        return cls(
            _parse_accel_id(args[0]),
            _parse_int_or_label(args[1]),
        )

    @classmethod
    def randomize(cls) -> Self:
        return cls(
            randrange(0, emulator.ACCEL_COUNT),
            randrange(0, emulator.INSTRUCTION_MEM_SIZE),
        )

    def into_emulator_instructions(self) -> list[emulator.EmulatorInstruction]:
        if isinstance(self.jmp_pc, str):
            raise Exception(f"Label {self.jmp_pc} has no value")

        return [
            emulator.JMP(emulator.JMPCond.CR, 0, self.accel_id, self.jmp_pc)
        ]

    def __str__(self) -> str:
        return f"{self.name()} {_format_accel_id(self.accel_id)}, {_format_jmp_pc(self.jmp_pc)}"


@dataclass
class JMPCW(JMPBase):
    accel_id: int
    jmp_pc: int | str

    @classmethod
    def parse_args(cls, args: list[str]) -> Self:
        assert len(args) == 2

        return cls(
            _parse_accel_id(args[0]),
            _parse_int_or_label(args[1]),
        )

    @classmethod
    def randomize(cls) -> Self:
        return cls(
            randrange(0, emulator.ACCEL_COUNT),
            randrange(0, emulator.INSTRUCTION_MEM_SIZE),
        )

    def into_emulator_instructions(self) -> list[emulator.EmulatorInstruction]:
        if isinstance(self.jmp_pc, str):
            raise Exception(f"Label {self.jmp_pc} has no value")

        return [
            emulator.JMP(emulator.JMPCond.CW, 0, self.accel_id, self.jmp_pc)
        ]

    def __str__(self) -> str:
        return f"{self.name()} {_format_accel_id(self.accel_id)}, {_format_jmp_pc(self.jmp_pc)}"


@dataclass
class JMPNCR(JMPBase):
    accel_id: int
    jmp_pc: int | str

    @classmethod
    def parse_args(cls, args: list[str]) -> Self:
        assert len(args) == 2

        return cls(
            _parse_accel_id(args[0]),
            _parse_int_or_label(args[1]),
        )

    @classmethod
    def randomize(cls) -> Self:
        return cls(
            randrange(0, emulator.ACCEL_COUNT),
            randrange(0, emulator.INSTRUCTION_MEM_SIZE),
        )

    def into_emulator_instructions(self) -> list[emulator.EmulatorInstruction]:
        if isinstance(self.jmp_pc, str):
            raise Exception(f"Label {self.jmp_pc} has no value")

        return [
            emulator.JMP(emulator.JMPCond.NCR, 0, self.accel_id, self.jmp_pc)
        ]

    def __str__(self) -> str:
        return f"{self.name()} {_format_accel_id(self.accel_id)}, {_format_jmp_pc(self.jmp_pc)}"


@dataclass
class JMPNCW(JMPBase):
    accel_id: int
    jmp_pc: int | str

    @classmethod
    def parse_args(cls, args: list[str]) -> Self:
        assert len(args) == 2

        return cls(
            _parse_accel_id(args[0]),
            _parse_int_or_label(args[1]),
        )

    @classmethod
    def randomize(cls) -> Self:
        return cls(
            randrange(0, emulator.ACCEL_COUNT),
            randrange(0, emulator.INSTRUCTION_MEM_SIZE),
        )

    def into_emulator_instructions(self) -> list[emulator.EmulatorInstruction]:
        if isinstance(self.jmp_pc, str):
            raise Exception(f"Label {self.jmp_pc} has no value")

        return [
            emulator.JMP(emulator.JMPCond.NCW, 0, self.accel_id, self.jmp_pc)
        ]

    def __str__(self) -> str:
        return f"{self.name()} {_format_accel_id(self.accel_id)}, {_format_jmp_pc(self.jmp_pc)}"


@dataclass
class LOAD(AssemblyInstruction):
    rd: int
    rs1: int

    @classmethod
    def parse_args(cls, args: list[str]) -> Self:
        assert len(args) == 2

        return cls(_parse_reg_addr(args[0]), _parse_reg_addr(args[1]))

    @classmethod
    def randomize(cls) -> Self:
        return cls(
            randrange(0, emulator.REG_COUNT),
            randrange(0, emulator.REG_COUNT),
        )

    def into_emulator_instructions(self) -> list[emulator.EmulatorInstruction]:
        return [emulator.LOAD(self.rd, self.rs1)]

    def __str__(self) -> str:
        return f"{self.name()} {_format_reg_addr(self.rd)}, {_format_reg_addr(self.rs1)}"


@dataclass
class STORE(AssemblyInstruction):
    rs1: int
    rs2: int

    @classmethod
    def parse_args(cls, args: list[str]) -> Self:
        assert len(args) == 2

        return cls(_parse_reg_addr(args[0]), _parse_reg_addr(args[1]))

    @classmethod
    def randomize(cls) -> Self:
        return cls(
            randrange(0, emulator.REG_COUNT),
            randrange(0, emulator.REG_COUNT),
        )

    def into_emulator_instructions(self) -> list[emulator.EmulatorInstruction]:
        return [emulator.STORE(self.rs1, self.rs2)]

    def __str__(self) -> str:
        return f"{self.name()} {_format_reg_addr(self.rs1)}, {_format_reg_addr(self.rs2)}"


@dataclass
class WACC(AssemblyInstruction):
    rs1: int
    accel_id: int

    @classmethod
    def parse_args(cls, args: list[str]) -> Self:
        assert len(args) == 2

        return cls(_parse_reg_addr(args[0]), _parse_accel_id(args[1]))

    @classmethod
    def randomize(cls) -> Self:
        return cls(
            randrange(0, emulator.REG_COUNT),
            randrange(0, emulator.ACCEL_COUNT),
        )

    def into_emulator_instructions(self) -> list[emulator.EmulatorInstruction]:
        return [emulator.WACC(self.rs1, self.accel_id)]

    def __str__(self) -> str:
        return f"{self.name()} {_format_reg_addr(self.rs1)}, {_format_accel_id(self.accel_id)}"


@dataclass
class RACC(AssemblyInstruction):
    rd: int
    accel_id: int

    @classmethod
    def parse_args(cls, args: list[str]) -> Self:
        assert len(args) == 2

        return cls(_parse_reg_addr(args[0]), _parse_accel_id(args[1]))

    @classmethod
    def randomize(cls) -> Self:
        return cls(
            randrange(0, emulator.REG_COUNT),
            randrange(0, emulator.ACCEL_COUNT),
        )

    def into_emulator_instructions(self) -> list[emulator.EmulatorInstruction]:
        return [emulator.RACC(self.rd, self.accel_id)]

    def __str__(self) -> str:
        return f"{self.name()} {_format_reg_addr(self.rd)}, {_format_accel_id(self.accel_id)}"


@dataclass
class LPCL(AssemblyInstruction):
    rd: int
    rs1: int

    @classmethod
    def parse_args(cls, args: list[str]) -> Self:
        assert len(args) == 2

        return cls(_parse_reg_addr(args[0]), _parse_reg_addr(args[1]))

    @classmethod
    def randomize(cls) -> Self:
        return cls(
            randrange(0, emulator.REG_COUNT),
            randrange(0, emulator.REG_COUNT),
        )

    def into_emulator_instructions(self) -> list[emulator.EmulatorInstruction]:
        return [emulator.LPCL(self.rd, self.rs1)]

    def __str__(self) -> str:
        return f"{self.name()} {_format_reg_addr(self.rd)}, {_format_reg_addr(self.rs1)}"


@dataclass
class CALL(AssemblyInstruction):
    rd: int
    pc: int | str

    @classmethod
    def parse_args(cls, args: list[str]) -> Self:
        assert len(args) == 2

        return cls(_parse_reg_addr(args[0]), _parse_int_or_label(args[1]))

    @classmethod
    def randomize(cls) -> Self:
        return cls(
            randrange(0, emulator.REG_COUNT),
            randrange(0, emulator.INSTRUCTION_MEM_SIZE),
        )

    def into_emulator_instructions(self) -> list[emulator.EmulatorInstruction]:
        if isinstance(self.pc, str):
            raise Exception(f"Label {self.pc} has no value")

        assert 2 * emulator.IMM_WIDTH <= emulator.INSTRUCTION_MEM_ADDR_WIDTH

        return [
            emulator.LL(self.rd, self.pc & ones(emulator.IMM_WIDTH)),
            emulator.LH(self.rd, self.pc >> emulator.IMM_WIDTH),
            emulator.LPCL(self.rd, self.rd),
        ]

    def substitute_label(self, label: str, value: int):
        if self.pc == label:
            self.pc = value

    def __str__(self) -> str:
        return f"{self.name()} {_format_reg_addr(self.rd)}, {_format_jmp_pc(self.pc)}"


INSTRUCTIONS_LIST: list[type[AssemblyInstruction]] = [
    ADD,
    SUB,
    AND,
    OR,
    XOR,
    JMP,
    JMPEQ,
    JMPNE,
    JMPLT,
    JMPLE,
    JMPGT,
    JMPGE,
    JMPCR,
    JMPCW,
    JMPNCR,
    JMPNCW,
    LOAD,
    STORE,
    WACC,
    RACC,
    LH,
    LL,
    LI,
    LPCL,
    CALL,
]
INSTRUCTIONS_DICT: dict[str, type[AssemblyInstruction]] = dict(
    (instr.name(), instr) for instr in INSTRUCTIONS_LIST
)


class Assembly:
    instructions: list[AssemblyInstruction]
    instruction_pointer: int
    labels: dict[str, int]

    @classmethod
    def read_from_file(cls, input_path: str) -> Self:
        asm = cls()

        with open(input_path, "r") as input_file:
            while (line := input_file.readline()) != "":
                line_without_comment = line.split("#")[0]
                line_parts = line_without_comment.replace(",", " ").split()

                if len(line_parts) == 0:
                    continue
                elif len(line_parts) == 1 and line_parts[0][-1] == ":":
                    asm.label(line_parts[0][:-1])

                    continue

                op, args = line_parts[0], line_parts[1:]

                asm.instruction(INSTRUCTIONS_DICT[op].parse_args(args))

        return asm

    def __init__(self):
        self.instructions = []
        self.instruction_pointer = 0
        self.labels = {}

    def instruction(self, instruction: AssemblyInstruction):
        self.instructions.append(instruction)

        self.instruction_pointer += len(instruction)

    def label(self, name: str):
        self.labels[name] = self.instruction_pointer

    def compile(self) -> list[emulator.EmulatorInstruction]:
        for instr in self.instructions:
            for label, label_value in self.labels.items():
                instr.substitute_label(label, label_value)

        return sum(
            (instr.into_emulator_instructions() for instr in self.instructions),
            [],
        )

    def load_into_emulator(self, emulator: emulator.Emulator):
        i = 0

        for instr in self.compile():
            for word in instr.encode():
                emulator.instructions_mem[i] = word

                i += 1

    def compile_to_file(self, filename: str):
        with open(filename, "w") as file:
            for instr in self.compile():
                for word in instr.encode():
                    bits_str = bin(word)[2:].rjust(
                        emulator.INSTRUCTION_WIDTH, "0"
                    )

                    file.write(bits_str + "\n")
