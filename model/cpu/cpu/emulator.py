from dataclasses import dataclass
from math import log2, ceil
from typing import Optional, Self

OP_WIDTH = 4

REG_WIDTH = 16
INSTRUCTION_WIDTH = 16

REG_COUNT = 16
REG_ADDR_WIDTH = ceil(log2(REG_COUNT))

DATA_MEM_SIZE = 1024
INSTRUCTION_MEM_SIZE = 1024

DATA_MEM_ADDR_WIDTH = 16
INSTRUCTION_MEM_ADDR_WIDTH = 16

OP_LSB = INSTRUCTION_WIDTH - OP_WIDTH

RD_LSB = OP_LSB - REG_ADDR_WIDTH
RS1_LSB = RD_LSB - REG_ADDR_WIDTH
RS2_LSB = RS1_LSB - REG_ADDR_WIDTH

COND_LSB = RD_LSB
COND_WIDTH = REG_ADDR_WIDTH

ACCEL_ID_LSB = RS2_LSB
ACCEL_ID_WIDTH = 4

ACCEL_COUNT = 2**ACCEL_ID_WIDTH

IMM_WIDTH = REG_WIDTH // 2
IMM_LSB = RD_LSB - IMM_WIDTH


class JMPCond:
    EQ = 0
    NE = 1
    LT = 2
    LE = 3
    GT = 4
    GE = 5
    CR = 6
    CW = 7
    NCR = 8
    NCW = 9


def _ones(width: int) -> int:
    return 2**width - 1


def _encode(value: int, lsb: int) -> int:
    return value << lsb


def _decode(value: int, lsb: int, width: int) -> int:
    return (value >> lsb) & _ones(width)


class EmulatorInstruction:
    @staticmethod
    def op() -> int:
        raise NotImplementedError()

    @classmethod
    def try_decode(cls, words: tuple[int, int]) -> Optional[Self]:
        raise NotImplementedError()

    def encode(self) -> list[int]:
        raise NotImplementedError()


@dataclass(frozen=True)
class ADD(EmulatorInstruction):
    rd: int
    rs1: int
    rs2: int

    def __post_init__(self):
        assert 0 <= self.rd < REG_COUNT
        assert 0 <= self.rs1 < REG_COUNT
        assert 0 <= self.rs2 < REG_COUNT

    @staticmethod
    def op() -> int:
        return 0

    @classmethod
    def try_decode(cls, words: tuple[int, int]) -> Optional[Self]:
        op = _decode(words[0], OP_LSB, OP_WIDTH)

        if op != cls.op():
            return None

        return cls(
            _decode(words[0], RD_LSB, REG_ADDR_WIDTH),
            _decode(words[0], RS1_LSB, REG_ADDR_WIDTH),
            _decode(words[0], RS2_LSB, REG_ADDR_WIDTH),
        )

    def encode(self) -> list[int]:
        return [
            _encode(self.op(), OP_LSB)
            | _encode(self.rd, RD_LSB)
            | _encode(self.rs1, RS1_LSB)
            | _encode(self.rs2, RS2_LSB)
        ]


@dataclass(frozen=True)
class SUB(EmulatorInstruction):
    rd: int
    rs1: int
    rs2: int

    def __post_init__(self):
        assert 0 <= self.rd < REG_COUNT
        assert 0 <= self.rs1 < REG_COUNT
        assert 0 <= self.rs2 < REG_COUNT

    @staticmethod
    def op() -> int:
        return 1

    @classmethod
    def try_decode(cls, words: tuple[int, int]) -> Optional[Self]:
        op = _decode(words[0], OP_LSB, OP_WIDTH)

        if op != cls.op():
            return None

        return cls(
            _decode(words[0], RD_LSB, REG_ADDR_WIDTH),
            _decode(words[0], RS1_LSB, REG_ADDR_WIDTH),
            _decode(words[0], RS2_LSB, REG_ADDR_WIDTH),
        )

    def encode(self) -> list[int]:
        return [
            _encode(self.op(), OP_LSB)
            | _encode(self.rd, RD_LSB)
            | _encode(self.rs1, RS1_LSB)
            | _encode(self.rs2, RS2_LSB)
        ]


@dataclass(frozen=True)
class AND(EmulatorInstruction):
    rd: int
    rs1: int
    rs2: int

    def __post_init__(self):
        assert 0 <= self.rd < REG_COUNT
        assert 0 <= self.rs1 < REG_COUNT
        assert 0 <= self.rs2 < REG_COUNT

    @staticmethod
    def op() -> int:
        return 2

    @classmethod
    def try_decode(cls, words: tuple[int, int]) -> Optional[Self]:
        op = _decode(words[0], OP_LSB, OP_WIDTH)

        if op != cls.op():
            return None

        return cls(
            _decode(words[0], RD_LSB, REG_ADDR_WIDTH),
            _decode(words[0], RS1_LSB, REG_ADDR_WIDTH),
            _decode(words[0], RS2_LSB, REG_ADDR_WIDTH),
        )

    def encode(self) -> list[int]:
        return [
            _encode(self.op(), OP_LSB)
            | _encode(self.rd, RD_LSB)
            | _encode(self.rs1, RS1_LSB)
            | _encode(self.rs2, RS2_LSB)
        ]


@dataclass(frozen=True)
class OR(EmulatorInstruction):
    rd: int
    rs1: int
    rs2: int

    def __post_init__(self):
        assert 0 <= self.rd < REG_COUNT
        assert 0 <= self.rs1 < REG_COUNT
        assert 0 <= self.rs2 < REG_COUNT

    @staticmethod
    def op() -> int:
        return 3

    @classmethod
    def try_decode(cls, words: tuple[int, int]) -> Optional[Self]:
        op = _decode(words[0], OP_LSB, OP_WIDTH)

        if op != cls.op():
            return None

        return cls(
            _decode(words[0], RD_LSB, REG_ADDR_WIDTH),
            _decode(words[0], RS1_LSB, REG_ADDR_WIDTH),
            _decode(words[0], RS2_LSB, REG_ADDR_WIDTH),
        )

    def encode(self) -> list[int]:
        return [
            _encode(self.op(), OP_LSB)
            | _encode(self.rd, RD_LSB)
            | _encode(self.rs1, RS1_LSB)
            | _encode(self.rs2, RS2_LSB)
        ]


@dataclass(frozen=True)
class XOR(EmulatorInstruction):
    rd: int
    rs1: int
    rs2: int

    def __post_init__(self):
        assert 0 <= self.rd < REG_COUNT
        assert 0 <= self.rs1 < REG_COUNT
        assert 0 <= self.rs2 < REG_COUNT

    @staticmethod
    def op() -> int:
        return 4

    @classmethod
    def try_decode(cls, words: tuple[int, int]) -> Optional[Self]:
        op = _decode(words[0], OP_LSB, OP_WIDTH)

        if op != cls.op():
            return None

        return cls(
            _decode(words[0], RD_LSB, REG_ADDR_WIDTH),
            _decode(words[0], RS1_LSB, REG_ADDR_WIDTH),
            _decode(words[0], RS2_LSB, REG_ADDR_WIDTH),
        )

    def encode(self) -> list[int]:
        return [
            _encode(self.op(), OP_LSB)
            | _encode(self.rd, RD_LSB)
            | _encode(self.rs1, RS1_LSB)
            | _encode(self.rs2, RS2_LSB)
        ]


@dataclass(frozen=True)
class LH(EmulatorInstruction):
    rd: int
    imm: int

    def __post_init__(self):
        assert 0 <= self.rd < REG_COUNT
        assert 0 <= self.imm < 2**IMM_WIDTH

    @staticmethod
    def op() -> int:
        return 5

    @classmethod
    def try_decode(cls, words: tuple[int, int]) -> Optional[Self]:
        op = _decode(words[0], OP_LSB, OP_WIDTH)

        if op != cls.op():
            return None

        return cls(
            _decode(words[0], RD_LSB, REG_ADDR_WIDTH),
            _decode(words[0], IMM_LSB, IMM_WIDTH),
        )

    def encode(self) -> list[int]:
        return [
            _encode(self.op(), OP_LSB)
            | _encode(self.rd, RD_LSB)
            | _encode(self.imm, IMM_LSB)
        ]


@dataclass(frozen=True)
class LL(EmulatorInstruction):
    rd: int
    imm: int

    def __post_init__(self):
        assert 0 <= self.rd < REG_COUNT
        assert 0 <= self.imm < 2**IMM_WIDTH

    @staticmethod
    def op() -> int:
        return 6

    @classmethod
    def try_decode(cls, words: tuple[int, int]) -> Optional[Self]:
        op = _decode(words[0], OP_LSB, OP_WIDTH)

        if op != cls.op():
            return None

        return cls(
            _decode(words[0], RD_LSB, REG_ADDR_WIDTH),
            _decode(words[0], IMM_LSB, IMM_WIDTH),
        )

    def encode(self) -> list[int]:
        return [
            _encode(self.op(), OP_LSB)
            | _encode(self.rd, RD_LSB)
            | _encode(self.imm, IMM_LSB)
        ]


@dataclass(frozen=True)
class JMP(EmulatorInstruction):
    cond: int
    rs1: int
    rs2: int  # rs2 or accel_id
    jmp_pc: int

    def __post_init__(self):
        assert 0 <= self.cond < 2**COND_WIDTH
        assert 0 <= self.rs2 < REG_COUNT
        assert 0 <= self.jmp_pc < INSTRUCTION_MEM_SIZE

    @staticmethod
    def op() -> int:
        return 7

    @classmethod
    def try_decode(cls, words: tuple[int, int]) -> Optional[Self]:
        op = _decode(words[0], OP_LSB, OP_WIDTH)

        if op != cls.op():
            return None

        return cls(
            _decode(words[0], COND_LSB, COND_WIDTH),
            _decode(words[0], RS1_LSB, REG_ADDR_WIDTH),
            _decode(words[0], RS2_LSB, REG_ADDR_WIDTH),
            words[1],
        )

    def encode(self) -> list[int]:
        return [
            _encode(self.op(), OP_LSB)
            | _encode(self.cond, COND_LSB)
            | _encode(self.rs1, RS1_LSB)
            | _encode(self.rs2, RS2_LSB),
            self.jmp_pc,
        ]


@dataclass(frozen=True)
class LOAD(EmulatorInstruction):
    rd: int
    rs1: int

    def __post_init__(self):
        assert 0 <= self.rd < REG_COUNT
        assert 0 <= self.rs1 < REG_COUNT

    @staticmethod
    def op() -> int:
        return 8

    @classmethod
    def try_decode(cls, words: tuple[int, int]) -> Optional[Self]:
        op = _decode(words[0], OP_LSB, OP_WIDTH)

        if op != cls.op():
            return None

        return cls(
            _decode(words[0], RD_LSB, REG_ADDR_WIDTH),
            _decode(words[0], RS1_LSB, REG_ADDR_WIDTH),
        )

    def encode(self) -> list[int]:
        return [
            _encode(self.op(), OP_LSB)
            | _encode(self.rd, RD_LSB)
            | _encode(self.rs1, RS1_LSB)
        ]


@dataclass(frozen=True)
class STORE(EmulatorInstruction):
    rs1: int
    rs2: int

    def __post_init__(self):
        assert 0 <= self.rs1 < REG_COUNT
        assert 0 <= self.rs2 < REG_COUNT

    @staticmethod
    def op() -> int:
        return 9

    @classmethod
    def try_decode(cls, words: tuple[int, int]) -> Optional[Self]:
        op = _decode(words[0], OP_LSB, OP_WIDTH)

        if op != cls.op():
            return None

        return cls(
            _decode(words[0], RS1_LSB, REG_ADDR_WIDTH),
            _decode(words[0], RS2_LSB, REG_ADDR_WIDTH),
        )

    def encode(self) -> list[int]:
        return [
            _encode(self.op(), OP_LSB)
            | _encode(self.rs1, RS1_LSB)
            | _encode(self.rs2, RS2_LSB)
        ]


@dataclass(frozen=True)
class WACC(EmulatorInstruction):
    rs1: int
    accel_id: int

    def __post_init__(self):
        assert 0 <= self.rs1 < REG_COUNT
        assert 0 <= self.accel_id < ACCEL_COUNT

    @staticmethod
    def op() -> int:
        return 10

    @classmethod
    def try_decode(cls, words: tuple[int, int]) -> Optional[Self]:
        op = _decode(words[0], OP_LSB, OP_WIDTH)

        if op != cls.op():
            return None

        return cls(
            _decode(words[0], RS1_LSB, REG_ADDR_WIDTH),
            _decode(words[0], ACCEL_ID_LSB, ACCEL_ID_WIDTH),
        )

    def encode(self) -> list[int]:
        return [
            _encode(self.op(), OP_LSB)
            | _encode(self.rs1, RS1_LSB)
            | _encode(self.accel_id, ACCEL_ID_LSB)
        ]


@dataclass(frozen=True)
class RACC(EmulatorInstruction):
    rd: int
    accel_id: int

    def __post_init__(self):
        assert 0 <= self.rd < REG_COUNT
        assert 0 <= self.accel_id < ACCEL_COUNT

    @staticmethod
    def op() -> int:
        return 11

    @classmethod
    def try_decode(cls, words: tuple[int, int]) -> Optional[Self]:
        op = _decode(words[0], OP_LSB, OP_WIDTH)

        if op != cls.op():
            return None

        return cls(
            _decode(words[0], RD_LSB, REG_ADDR_WIDTH),
            _decode(words[0], ACCEL_ID_LSB, ACCEL_ID_WIDTH),
        )

    def encode(self) -> list[int]:
        return [
            _encode(self.op(), OP_LSB)
            | _encode(self.rd, RD_LSB)
            | _encode(self.accel_id, ACCEL_ID_LSB)
        ]


class Accelerator:
    def can_read(self) -> bool:
        raise NotImplementedError()

    def can_write(self) -> bool:
        raise NotImplementedError()

    def read(self) -> int:
        raise NotImplementedError()

    def write(self, value: int):
        raise NotImplementedError()

    def tick(self):
        raise NotImplementedError()


class Emulator:
    regs: list[int]
    pc: int
    instructions_mem: list[int]
    data_mem: list[int]
    accelerators: list[Optional[Accelerator]]

    executed_instructions_count: int

    def __init__(self):
        self.regs = [0] * (REG_COUNT - 1)
        self.pc = 0
        self.instructions_mem = [0] * INSTRUCTION_MEM_SIZE
        self.data_mem = [0] * DATA_MEM_SIZE
        self.accelerators = [None] * ACCEL_COUNT

        self.executed_instructions_count = 0

    def read_reg(self, index: int) -> int:
        if index == 0:
            return 0

        return self.regs[index - 1]

    def write_reg(self, index: int, value: int):
        if index >= 1:
            self.regs[index - 1] = value

    def read_instr_mem(self, pc: int) -> tuple[int, int]:
        return (
            self.instructions_mem[pc % len(self.instructions_mem)],
            self.instructions_mem[(pc + 1) % len(self.instructions_mem)],
        )

    def tick(self):
        instr_words = self.read_instr_mem(self.pc)

        override_pc = False

        if (instr := ADD.try_decode(instr_words)) is not None:
            self.write_reg(
                instr.rd,
                (self.read_reg(instr.rs1) + self.read_reg(instr.rs2))
                & _ones(REG_WIDTH),
            )
        elif (instr := SUB.try_decode(instr_words)) is not None:
            self.write_reg(
                instr.rd,
                (
                    2**REG_WIDTH
                    + self.read_reg(instr.rs1)
                    - self.read_reg(instr.rs2)
                )
                & _ones(REG_WIDTH),
            )
        elif (instr := AND.try_decode(instr_words)) is not None:
            self.write_reg(
                instr.rd,
                self.read_reg(instr.rs1) & self.read_reg(instr.rs2),
            )
        elif (instr := OR.try_decode(instr_words)) is not None:
            self.write_reg(
                instr.rd,
                self.read_reg(instr.rs1) | self.read_reg(instr.rs2),
            )
        elif (instr := XOR.try_decode(instr_words)) is not None:
            self.write_reg(
                instr.rd,
                self.read_reg(instr.rs1) | self.read_reg(instr.rs2),
            )
        elif (instr := JMP.try_decode(instr_words)) is not None:
            cond_value = False

            match instr.cond:
                case JMPCond.EQ:
                    cond_value = self.read_reg(instr.rs1) == self.read_reg(
                        instr.rs2
                    )
                case JMPCond.NE:
                    cond_value = self.read_reg(instr.rs1) != self.read_reg(
                        instr.rs2
                    )
                case JMPCond.LT:
                    cond_value = self.read_reg(instr.rs1) < self.read_reg(
                        instr.rs2
                    )
                case JMPCond.LE:
                    cond_value = self.read_reg(instr.rs1) <= self.read_reg(
                        instr.rs2
                    )
                case JMPCond.GT:
                    cond_value = self.read_reg(instr.rs1) > self.read_reg(
                        instr.rs2
                    )
                case JMPCond.GE:
                    cond_value = self.read_reg(instr.rs1) >= self.read_reg(
                        instr.rs2
                    )
                case JMPCond.CR:
                    cond_value = self.accelerators[instr.rs2].can_read()
                case JMPCond.CW:
                    cond_value = self.accelerators[instr.rs2].can_write()
                case JMPCond.NCR:
                    cond_value = not self.accelerators[instr.rs2].can_read()
                case JMPCond.NCW:
                    cond_value = not self.accelerators[instr.rs2].can_write()
                case _:
                    raise Exception(f"Invalid instruction: {instr}")

            if cond_value:
                override_pc = True
                self.pc = self.instructions_mem[self.pc + 1]
        elif (instr := LOAD.try_decode(instr_words)) is not None:
            self.write_reg(instr.rd, self.data_mem[self.read_reg(instr.rs1)])
        elif (instr := STORE.try_decode(instr_words)) is not None:
            self.data_mem[self.read_reg(instr.rs1)] = self.read_reg(instr.rs2)
        elif (instr := WACC.try_decode(instr_words)) is not None:
            accelerator = self.accelerators[instr.accel_id]

            if accelerator.can_write():
                accelerator.write(self.read_reg(instr.rs1))
            else:
                override_pc = True  # do not update pc - wait for accelerator to become writable
        elif (instr := RACC.try_decode(instr_words)) is not None:
            accelerator = self.accelerators[instr.accel_id]

            if accelerator.can_read():
                self.write_reg(instr.rd, accelerator.read())
            else:
                override_pc = True  # do not update pc - wait for accelerator to become readable
        elif (instr := LH.try_decode(instr_words)) is not None:
            self.write_reg(
                instr.rd,
                self.read_reg(instr.rd) & _ones(REG_WIDTH // 2)
                | (instr.imm << (REG_WIDTH // 2)),
            )
        elif (instr := LL.try_decode(instr_words)) is not None:
            self.write_reg(
                instr.rd,
                self.read_reg(instr.rd)
                & (_ones(REG_WIDTH // 2) << (REG_WIDTH // 2))
                | instr.imm,
            )
        else:
            raise Exception(f"Invalid instruction: {instr}")

        self.executed_instructions_count += 1

        if not override_pc:
            self.pc = (self.pc + 1) & _ones(INSTRUCTION_MEM_ADDR_WIDTH)

        for accelerator in self.accelerators:
            if accelerator is not None:
                accelerator.tick()
