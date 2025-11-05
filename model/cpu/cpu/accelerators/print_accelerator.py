from cpu.emulator import Accelerator


class PrintAccelerator(Accelerator):
    buffer: str

    def __init__(self):
        self.buffer = ""

    def can_read(self) -> bool:
        return False

    def can_write(self) -> bool:
        return True

    def write(self, value: int):
        self.buffer += chr(value)

    def tick(self):
        if self.buffer.endswith("\n"):
            print(self.buffer, end="")

            self.buffer = ""
