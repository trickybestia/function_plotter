from math import sin, inf
from random import randint

import matplotlib.pyplot as plt
import numpy as np


def sample_signal(t: int) -> int:
    return min(
        255,
        max(0, round((sin(t / 30) + 1) * 255 / 2) + randint(-20, 20)),
    )


def similarity(a: list[int], b: list[int]) -> int:
    return sum(np.array(a) * np.array(b))


def period(samples: list[int], window_size: int, step: int) -> int:
    best_similarity = -inf
    best_similarity_index = 0

    periods = []
    similarities = []

    for i in range(0, len(samples) - window_size, step):
        period = len(samples) - i
        samples_a = samples[-window_size:]
        samples_b = samples[i : i + window_size]

        new_similarity = similarity(samples_a, samples_b) * (-period)

        periods.append(period)
        similarities.append(new_similarity)

        if new_similarity > best_similarity:
            best_similarity_index = period
            best_similarity = new_similarity

    return best_similarity_index


def offset_index(samples: list[int], period: int) -> int:
    global_avg = sum(samples) / len(samples)
    last_zero_index = 0

    previous_sign = 1

    for i in range(10, len(samples) - period):
        avg_window = samples[i - 10 : i + 10]
        avg = sum(avg_window) / len(avg_window)

        current_sign = 1 if avg >= global_avg else -1

        if previous_sign == -1 and current_sign == 1:
            last_zero_index = i

        previous_sign = current_sign

    return last_zero_index


def main():
    t = 0
    samples = []

    while True:
        samples.append(sample_signal(t))

        if len(samples) == 1000:
            if t % 500 == 0:
                _period = period(samples, 50, 10)
                print(f"Period: {_period} samples")

                offset = offset_index(samples, _period)

                plt.plot(samples[offset : offset + _period])

                plt.pause(1)

            samples.pop(0)

        t += 1


main()
