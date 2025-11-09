from cpu.emulator import Accelerator


class DummyAccelerator(Accelerator):
    def can_read(self) -> bool:
        return True

    def can_write(self) -> bool:
        return True

    def read(self) -> int:
        return 42

    def write(self, value: int): ...

    def tick(self): ...
