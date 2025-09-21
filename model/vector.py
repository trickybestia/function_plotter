class Vector:
    data: list[int]
    length: int

    def __init__(self, size: int):
        self.data = [0] * size
        self.length = 0

    def get(self, index: int) -> int:
        """no bounds check, index must be < size"""

        # STATE_READY

        return self.data[index]

    def insert(self, index: int, data_in: int):
        """no bounds check, index must be <= self.length < size"""

        # STATE_READY

        if index != self.length:
            j = self.length

            while True:
                # STATE_INSERT_READ
                tmp = self.data[j - 1]

                # STATE_INSERT_WRITE
                self.data[j] = tmp

                if j == index:
                    break

                j -= 1

        # STATE_INSERT_DONE
        self.data[index] = data_in
        self.length += 1

        # STATE_READY

    def remove(self, index: int):
        """no bounds check, index must be < self.length < size"""

        # STATE_READY

        if index != self.length - 1:
            j = index

            while True:
                # STATE_REMOVE_READ
                tmp = self.data[j + 1]

                # STATE_REMOVE_WRITE
                self.data[j] = tmp

                if j == self.length - 2:
                    break

                j += 1

        # STATE_REMOVE_DONE
        self.length -= 1

        # STATE_READY


def main():
    vector = Vector(7)

    vector.insert(0, 10)
    vector.insert(1, 20)
    vector.insert(2, 30)
    vector.insert(3, 40)
    vector.insert(4, 50)
    vector.insert(5, 60)
    vector.insert(6, 70)

    print(vector.length, vector.data)

    vector.remove(0)

    print(vector.length, vector.data)

    vector.insert(3, 99)

    print(vector.length, vector.data)

    while vector.length != 0:
        vector.remove(0)

    print(vector.length, vector.data)


main()
