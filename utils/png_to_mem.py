from pathlib import Path

import PIL.Image

IMAGE_SIZE = (15, 20)

RESULT_PATH = "src/symbol_drawer_mem.mem"
# https://www.ascii-code.com/
# fmt: off
SOURCES = [
    "font/space.png", # NUL
    "x", # SOH
    "x", # STX
    "x", # ETX
    "x", # EOT
    "x", # ENQ
    "x", # ACK
    "x", # BEL
    "x", # BS
    "x", # HT
    "x", # LF
    "x", # VT
    "x", # FF
    "x", # CR
    "x", # SO
    "x", # SI
    "x", # DLE
    "x", # DC1
    "x", # DC2
    "x", # DC3
    "x", # DC4
    "x", # NAK
    "x", # SYN
    "x", # ETB
    "x", # CAN
    "x", # EM
    "x", # SUM
    "x", # ESC
    "x", # FS
    "x", # GS
    "x", # RS
    "x", # US
    "x", # SP
    "x", # !
    "x", # "
    "x", # #
    "x", # $
    "x", # %
    "x", # &
    "x", # '
    "x", # (
    "x", # )
    "font/asterisk.png", # *
    "font/plus.png", # +
    "x", # ,
    "font/minus.png", # -
    "font/period.png", # .
    "font/slash.png", # /
    "font/0.png", # 0
    "font/1.png", # 1
    "font/2.png", # 2
    "font/3.png", # 3
    "font/4.png", # 4
    "font/5.png", # 5
    "font/6.png", # 6
    "font/7.png", # 7
    "font/8.png", # 8
    "font/9.png", # 9
    "x", # :
    "x", # ;
    "x", # <
    "x", # =
    "x", # >
    "x", # ?
    "x", # @
    "x", # A
    "x", # B
    "x", # C
    "x", # D
    "x", # E
    "x", # F
    "x", # G
    "x", # H
    "x", # I
    "x", # J
    "x", # K
    "x", # L
    "x", # M
    "x", # N
    "x", # O
    "x", # P
    "x", # Q
    "x", # R
    "x", # S
    "x", # T
    "x", # U
    "x", # V
    "x", # W
    "x", # X
    "x", # Y
    "x", # Z
    "font/opening_square_bracket.png", # [
    "x", # \
    "font/closing_square_bracket.png", # ]
    "x", # ^
    "x", # _
    "x", # `
    "font/a.png", # a
    "font/b.png", # b
    "font/c.png", # c
    "font/d.png", # d
    "font/e.png", # e
    "font/f.png", # f
    "font/g.png", # g
    "font/h.png", # h
    "font/i.png", # i
    "font/j.png", # j
    "font/k.png", # k
    "font/l.png", # l
    "font/m.png", # m
    "font/n.png", # n
    "font/o.png", # o
    "font/p.png", # p
    "font/q.png", # q
    "font/r.png", # r
    "font/s.png", # s
    "font/t.png", # t
    "font/u.png", # u
    "font/v.png", # v
    "font/w.png", # w
    "font/x.png", # x
    "font/y.png", # y
    "font/z.png", # z
    "x", # {
    "x", # |
    "x", # }
    "x", # ~
    "x", # DEL
]
# fmt: on

result = []

for source in SOURCES:
    if source == "x":
        for x in range(IMAGE_SIZE[0]):
            for y in range(IMAGE_SIZE[1]):
                result.append("x")

        continue

    image = PIL.Image.open(source)

    print(
        f"{source} ({image.size[0]}x{image.size[1]}): {len(result)}..{len(result) + (image.size[0] * image.size[1]) - 1}"
    )

    for y in range(image.size[1]):
        for x in range(image.size[0]):
            result.append(image.getpixel((x, y)))

print(f"{len(result)} bits total")

Path(RESULT_PATH).write_text(" ".join(map(str, result)))
