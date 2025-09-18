import pygame


def draw_line(screen: pygame.Surface, x1: int, y1: int, x2: int, y2: int):
    delta_x = abs(x2 - x1)
    delta_y = abs(y2 - y1)

    primary_is_x = delta_x > delta_y

    if primary_is_x:
        p_start = x1
        p_end = x2
        s_start = y1
        s_end = y2
    else:
        p_start = y1
        p_end = y2
        s_start = x1
        s_end = x2

    delta_p = abs(p_end - p_start)

    if p_end > p_start:
        p_direction = 1
    elif p_end < p_start:
        p_direction = -1
    else:
        p_direction = 0

    if s_end > s_start:
        s_direction = 1
    elif s_end < s_start:
        s_direction = -1
    else:
        s_direction = 0

    delta_error = abs(s_end - s_start) + 1

    error = 0

    p = p_start
    s = s_start

    while True:
        if primary_is_x:
            screen.set_at((p, s), "white")
        else:
            screen.set_at((s, p), "white")

        if p == p_end:
            break

        p += p_direction
        error += delta_error

        if error >= delta_p + 1:
            s += s_direction
            error -= delta_p + 1

    print(f"done")


def main():
    pygame.init()

    screen = pygame.display.set_mode((640, 480))

    while True:
        for x in range(100, 300 + 1):
            screen.fill("black")

            draw_line(screen, 200, 200, x, 100)

            pygame.display.update()

            input()

        for y in range(100, 300 + 1):
            screen.fill("black")

            draw_line(screen, 200, 200, 300, y)

            pygame.display.update()

            input()

        for x in range(300, 100 - 1, -1):
            screen.fill("black")

            draw_line(screen, 200, 200, x, 300)

            pygame.display.update()

            input()

        for y in range(300, 100 - 1, -1):
            screen.fill("black")

            draw_line(screen, 200, 200, 100, y)

            pygame.display.update()

            input()


main()
