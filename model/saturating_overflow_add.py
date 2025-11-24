import matplotlib.pyplot as plt
import numpy as np


def main():
    x = np.arange(256)

    y1 = (x + 127) % 256
    plt.subplot(2, 2, 1).set_title("переполнение")
    plt.subplot(2, 2, 1).set_xlabel("x")
    plt.subplot(2, 2, 1).set_ylabel("x + 127")
    plt.subplot(2, 2, 1).set_xlim((0, 255))
    plt.subplot(2, 2, 1).set_ylim((0, 255))
    plt.subplot(2, 2, 1).scatter(x, y1, s=6)

    y2 = (x + 127).clip(0, 255)
    plt.subplot(2, 2, 2).set_title("насыщение")
    plt.subplot(2, 2, 2).set_xlabel("x")
    plt.subplot(2, 2, 2).set_ylabel("x + 127")
    plt.subplot(2, 2, 2).set_xlim((0, 255))
    plt.subplot(2, 2, 2).set_ylim((0, 255))
    plt.subplot(2, 2, 2).scatter(x, y2, s=6)

    y3 = (x - 127) % 256
    plt.subplot(2, 2, 3).set_title("переполнение")
    plt.subplot(2, 2, 3).set_xlabel("x")
    plt.subplot(2, 2, 3).set_ylabel("x - 127")
    plt.subplot(2, 2, 3).set_xlim((0, 255))
    plt.subplot(2, 2, 3).set_ylim((0, 255))
    plt.subplot(2, 2, 3).scatter(x, y3, s=6)

    y4 = (x - 127).clip(0, 255)
    plt.subplot(2, 2, 4).set_title("насыщение")
    plt.subplot(2, 2, 4).set_xlabel("x")
    plt.subplot(2, 2, 4).set_ylabel("x - 127")
    plt.subplot(2, 2, 4).set_xlim((0, 255))
    plt.subplot(2, 2, 4).set_ylim((0, 255))
    plt.subplot(2, 2, 4).scatter(x, y4, s=6)

    plt.tight_layout()
    plt.show()


main()
