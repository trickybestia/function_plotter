import sys
import PIL.Image

txt_path = sys.argv[1]

with open(txt_path, "rt") as file:
    lines = file.readlines()

    image_width = len(lines[0]) - 1  # there is newline symbol at each line
    image_height = len(
        lines
    )  # there is newline at the end of file, but file.readlines() trims it

    image = PIL.Image.new("RGB", (image_width, image_height))

    for y in range(image_height):
        for x in range(image_width):
            if lines[y][x] == "1":
                image.putpixel((x, y), (255, 255, 255))

    image.show()
