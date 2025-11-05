from dataclasses import dataclass
from typing import Self

from . import emulator


def _parse_int_or_label(s: str) -> str | int:
    try:
        return int(s)
    except:
        return s


def _parse_reg_addr(s: str) -> int:
    assert s.startswith("r")

    return int(s[1:])


def _parse_accel_id(s: str) -> int:
    assert s.startswith("acc")

    return int(s[3:])


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


class AssemblyInstruction:
    @classmethod
    def name(cls) -> str:
        return cls.__name__.lower()

    @classmethod
    def parse_args(cls, args: list[str]) -> Self:
        raise NotImplementedError()

    def into_emulator_instruction(self) -> emulator.EmulatorInstruction:
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

        return ADD(
            _parse_reg_addr(args[0]),
            _parse_reg_addr(args[1]),
            _parse_reg_addr(args[2]),
        )

    def into_emulator_instruction(self) -> emulator.EmulatorInstruction:
        return emulator.ADD(self.rd, self.rs1, self.rs2)


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

    def into_emulator_instruction(self) -> emulator.EmulatorInstruction:
        return emulator.SUB(self.rd, self.rs1, self.rs2)


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

    def into_emulator_instruction(self) -> emulator.EmulatorInstruction:
        return emulator.AND(self.rd, self.rs1, self.rs2)


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

    def into_emulator_instruction(self) -> emulator.EmulatorInstruction:
        return emulator.OR(self.rd, self.rs1, self.rs2)


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

    def into_emulator_instruction(self) -> emulator.EmulatorInstruction:
        return emulator.XOR(self.rd, self.rs1, self.rs2)


@dataclass
class JMP(AssemblyInstruction):
    jmp_pc: int | str

    @classmethod
    def parse_args(cls, args: list[str]) -> Self:
        assert len(args) == 1

        return cls(_parse_int_or_label(args[0]))

    def into_emulator_instruction(self) -> emulator.EmulatorInstruction:
        if isinstance(self.jmp_pc, str):
            raise Exception(f"Label {self.jmp_pc} has no value")

        return emulator.JMP(emulator.JMPCond.EQ, 0, 0, self.jmp_pc)

    def substitute_label(self, label: str, value: int):
        if self.jmp_pc == label:
            self.jmp_pc = value

    @staticmethod
    def __len__() -> int:
        return 2


@dataclass
class JMPEQ(AssemblyInstruction):
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

    def into_emulator_instruction(self) -> emulator.EmulatorInstruction:
        if isinstance(self.jmp_pc, str):
            raise Exception(f"Label {self.jmp_pc} has no value")

        return emulator.JMP(
            emulator.JMPCond.EQ, self.rs1, self.rs2, self.jmp_pc
        )

    def substitute_label(self, label: str, value: int):
        if self.jmp_pc == label:
            self.jmp_pc = value

    @staticmethod
    def __len__() -> int:
        return 2


@dataclass
class JMPNE(AssemblyInstruction):
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

    def into_emulator_instruction(self) -> emulator.EmulatorInstruction:
        if isinstance(self.jmp_pc, str):
            raise Exception(f"Label {self.jmp_pc} has no value")

        return emulator.JMP(
            emulator.JMPCond.NE, self.rs1, self.rs2, self.jmp_pc
        )

    def substitute_label(self, label: str, value: int):
        if self.jmp_pc == label:
            self.jmp_pc = value

    @staticmethod
    def __len__() -> int:
        return 2


@dataclass
class JMPLT(AssemblyInstruction):
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

    def into_emulator_instruction(self) -> emulator.EmulatorInstruction:
        if isinstance(self.jmp_pc, str):
            raise Exception(f"Label {self.jmp_pc} has no value")

        return emulator.JMP(
            emulator.JMPCond.LT, self.rs1, self.rs2, self.jmp_pc
        )

    def substitute_label(self, label: str, value: int):
        if self.jmp_pc == label:
            self.jmp_pc = value

    @staticmethod
    def __len__() -> int:
        return 2


@dataclass
class JMPLE(AssemblyInstruction):
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

    def into_emulator_instruction(self) -> emulator.EmulatorInstruction:
        if isinstance(self.jmp_pc, str):
            raise Exception(f"Label {self.jmp_pc} has no value")

        return emulator.JMP(
            emulator.JMPCond.LE, self.rs1, self.rs2, self.jmp_pc
        )

    def substitute_label(self, label: str, value: int):
        if self.jmp_pc == label:
            self.jmp_pc = value

    @staticmethod
    def __len__() -> int:
        return 2


@dataclass
class JMPGT(AssemblyInstruction):
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

    def into_emulator_instruction(self) -> emulator.EmulatorInstruction:
        if isinstance(self.jmp_pc, str):
            raise Exception(f"Label {self.jmp_pc} has no value")

        return emulator.JMP(
            emulator.JMPCond.GT, self.rs1, self.rs2, self.jmp_pc
        )

    def substitute_label(self, label: str, value: int):
        if self.jmp_pc == label:
            self.jmp_pc = value

    @staticmethod
    def __len__() -> int:
        return 2


@dataclass
class JMPGE(AssemblyInstruction):
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

    def into_emulator_instruction(self) -> emulator.EmulatorInstruction:
        if isinstance(self.jmp_pc, str):
            raise Exception(f"Label {self.jmp_pc} has no value")

        return emulator.JMP(
            emulator.JMPCond.GE, self.rs1, self.rs2, self.jmp_pc
        )

    def substitute_label(self, label: str, value: int):
        if self.jmp_pc == label:
            self.jmp_pc = value

    @staticmethod
    def __len__() -> int:
        return 2


@dataclass
class JMPCR(AssemblyInstruction):
    accel_id: int
    jmp_pc: int | str

    @classmethod
    def parse_args(cls, args: list[str]) -> Self:
        assert len(args) == 2

        return cls(
            _parse_accel_id(args[0]),
            _parse_int_or_label(args[1]),
        )

    def into_emulator_instruction(self) -> emulator.EmulatorInstruction:
        if isinstance(self.jmp_pc, str):
            raise Exception(f"Label {self.jmp_pc} has no value")

        return emulator.JMP(emulator.JMPCond.CR, 0, self.accel_id, self.jmp_pc)

    def substitute_label(self, label: str, value: int):
        if self.jmp_pc == label:
            self.jmp_pc = value

    @staticmethod
    def __len__() -> int:
        return 2


@dataclass
class JMPCW(AssemblyInstruction):
    accel_id: int
    jmp_pc: int | str

    @classmethod
    def parse_args(cls, args: list[str]) -> Self:
        assert len(args) == 2

        return cls(
            _parse_accel_id(args[0]),
            _parse_int_or_label(args[1]),
        )

    def into_emulator_instruction(self) -> emulator.EmulatorInstruction:
        if isinstance(self.jmp_pc, str):
            raise Exception(f"Label {self.jmp_pc} has no value")

        return emulator.JMP(emulator.JMPCond.CW, 0, self.accel_id, self.jmp_pc)

    def substitute_label(self, label: str, value: int):
        if self.jmp_pc == label:
            self.jmp_pc = value

    @staticmethod
    def __len__() -> int:
        return 2


@dataclass
class JMPNCR(AssemblyInstruction):
    accel_id: int
    jmp_pc: int | str

    @classmethod
    def parse_args(cls, args: list[str]) -> Self:
        assert len(args) == 2

        return cls(
            _parse_accel_id(args[0]),
            _parse_int_or_label(args[1]),
        )

    def into_emulator_instruction(self) -> emulator.EmulatorInstruction:
        if isinstance(self.jmp_pc, str):
            raise Exception(f"Label {self.jmp_pc} has no value")

        return emulator.JMP(emulator.JMPCond.NCR, 0, self.accel_id, self.jmp_pc)

    def substitute_label(self, label: str, value: int):
        if self.jmp_pc == label:
            self.jmp_pc = value

    @staticmethod
    def __len__() -> int:
        return 2


@dataclass
class JMPNCW(AssemblyInstruction):
    accel_id: int
    jmp_pc: int | str

    @classmethod
    def parse_args(cls, args: list[str]) -> Self:
        assert len(args) == 2

        return cls(
            _parse_accel_id(args[0]),
            _parse_int_or_label(args[1]),
        )

    def into_emulator_instruction(self) -> emulator.EmulatorInstruction:
        if isinstance(self.jmp_pc, str):
            raise Exception(f"Label {self.jmp_pc} has no value")

        return emulator.JMP(emulator.JMPCond.NCW, 0, self.accel_id, self.jmp_pc)

    def substitute_label(self, label: str, value: int):
        if self.jmp_pc == label:
            self.jmp_pc = value

    @staticmethod
    def __len__() -> int:
        return 2


@dataclass
class LOAD(AssemblyInstruction):
    rd: int
    rs1: int

    @classmethod
    def parse_args(cls, args: list[str]) -> Self:
        assert len(args) == 2

        return cls(_parse_reg_addr(args[0]), _parse_reg_addr(args[1]))

    def into_emulator_instruction(self) -> emulator.EmulatorInstruction:
        return emulator.LOAD(self.rd, self.rs1)


@dataclass
class STORE(AssemblyInstruction):
    rs1: int
    rs2: int

    @classmethod
    def parse_args(cls, args: list[str]) -> Self:
        assert len(args) == 2

        return cls(_parse_reg_addr(args[0]), _parse_reg_addr(args[1]))

    def into_emulator_instruction(self) -> emulator.EmulatorInstruction:
        return emulator.STORE(self.rs1, self.rs2)


@dataclass
class WACC(AssemblyInstruction):
    rs1: int
    accel_id: int

    @classmethod
    def parse_args(cls, args: list[str]) -> Self:
        assert len(args) == 2

        return cls(_parse_reg_addr(args[0]), _parse_accel_id(args[1]))

    def into_emulator_instruction(self) -> emulator.EmulatorInstruction:
        return emulator.WACC(self.rs1, self.accel_id)


@dataclass
class RACC(AssemblyInstruction):
    rd: int
    accel_id: int

    @classmethod
    def parse_args(cls, args: list[str]) -> Self:
        assert len(args) == 2

        return cls(_parse_reg_addr(args[0]), _parse_accel_id(args[1]))

    def into_emulator_instruction(self) -> emulator.EmulatorInstruction:
        return emulator.RACC(self.rd, self.accel_id)


@dataclass
class LH(AssemblyInstruction):
    rd: int
    imm: int

    @classmethod
    def parse_args(cls, args: list[str]) -> Self:
        assert len(args) == 2

        return cls(_parse_reg_addr(args[0]), _parse_imm(args[1]))

    def into_emulator_instruction(self) -> emulator.EmulatorInstruction:
        return emulator.LH(self.rd, self.imm)


@dataclass
class LL(AssemblyInstruction):
    rd: int
    imm: int

    @classmethod
    def parse_args(cls, args: list[str]) -> Self:
        assert len(args) == 2

        return cls(_parse_reg_addr(args[0]), _parse_imm(args[1]))

    def into_emulator_instruction(self) -> emulator.EmulatorInstruction:
        return emulator.LL(self.rd, self.imm)


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
]
INSTRUCTIONS_DICT: dict[str, type[AssemblyInstruction]] = dict(
    (instr.name(), instr) for instr in INSTRUCTIONS_LIST
)


class Assembly:
    instructions: list[AssemblyInstruction]
    instruction_pointer: int
    labels: dict[str, int]

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

        return [
            instr.into_emulator_instruction() for instr in self.instructions
        ]
