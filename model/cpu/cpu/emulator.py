from dataclasses import dataclass
from math import log2, ceil

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


def _encode(value: int, lsb: int) -> int:
    return value << lsb


def _ones(width: int) -> int:
    return 2**width - 1


class EmulatorInstruction:
    @staticmethod
    def op() -> int:
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

    def encode(self) -> list[int]:
        return [
            _encode(self.op(), OP_LSB)
            | _encode(self.rd, RD_LSB)
            | _encode(self.rs1, RS1_LSB)
            | _encode(self.rs2, RS2_LSB)
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
        return 5

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
        return 6

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
        return 7

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
        return 8

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
        return 9

    def encode(self) -> list[int]:
        return [
            _encode(self.op(), OP_LSB)
            | _encode(self.rd, RD_LSB)
            | _encode(self.accel_id, ACCEL_ID_LSB)
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
        return 10

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
        return 11

    def encode(self) -> list[int]:
        return [
            _encode(self.op(), OP_LSB)
            | _encode(self.rd, RD_LSB)
            | _encode(self.imm, IMM_LSB)
        ]


class Emulator:
    regs: list[int]
    pc: int
    instructions_mem: list[EmulatorInstruction]
    data_mem: list[int]

    executed_instructions_count: int

    def __init__(self):
        self.regs = [0] * (REG_COUNT - 1)
        self.pc = 0
        self.instructions_mem = [None] * INSTRUCTION_MEM_SIZE
        self.data_mem = [0] * DATA_MEM_SIZE

        self.executed_instructions_count = 0

    def read_reg(self, index: int) -> int:
        if index == 0:
            return 0

        return self.regs[index - 1]

    def write_reg(self, index: int, value: int):
        if index >= 1:
            self.regs[index - 1] = value

    def tick(self):
        instr = self.instructions_mem[self.pc]

        override_pc = False

        if isinstance(instr, ADD):
            self.write_reg(
                instr.rd,
                (self.read_reg(instr.rs1) + self.read_reg(instr.rs2))
                & _ones(REG_WIDTH),
            )
        elif isinstance(instr, SUB):
            self.write_reg(
                instr.rd,
                (
                    2**REG_WIDTH
                    + self.read_reg(instr.rs1)
                    - self.read_reg(instr.rs2)
                )
                & _ones(REG_WIDTH),
            )
        elif isinstance(instr, AND):
            self.write_reg(
                instr.rd,
                self.read_reg(instr.rs1) & self.read_reg(instr.rs2),
            )
        elif isinstance(instr, OR):
            self.write_reg(
                instr.rd,
                self.read_reg(instr.rs1) | self.read_reg(instr.rs2),
            )
        elif isinstance(instr, XOR):
            self.write_reg(
                instr.rd,
                self.read_reg(instr.rs1) | self.read_reg(instr.rs2),
            )
        elif isinstance(instr, JMP):
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
                    ...
                case JMPCond.CW:
                    ...
                case JMPCond.NCR:
                    ...
                case JMPCond.NCW:
                    ...
                case _:
                    raise Exception(f"Invalid instruction: {instr}")

            if cond_value:
                override_pc = True
                self.pc = self.instructions_mem[self.pc + 1]
        elif isinstance(instr, LOAD):
            self.write_reg(instr.rd, self.data_mem[self.read_reg(instr.rs1)])
        elif isinstance(instr, STORE):
            self.data_mem[self.read_reg(instr.rs1)] = self.read_reg(instr.rs2)
        elif isinstance(instr, WACC):
            ...
        elif isinstance(instr, RACC):
            ...
        elif isinstance(instr, LH):
            self.write_reg(
                instr.rd,
                self.read_reg(instr.rd) & _ones(REG_WIDTH // 2)
                | (instr.imm << (REG_WIDTH // 2)),
            )
        elif isinstance(instr, LL):
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
