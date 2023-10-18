#!/usr/bin/env python
#
# ******************************************************************************
#
# NES ELITE IMAGE COMBINER
#
# Written by Mark Moxon
#
# This script combines the background and foreground images that make up the
# system and commander images and saves them as individual images and galleries
#
# ******************************************************************************

import png


def combine_images(background_image, foreground_image, combined_image):
    bg = png.Reader(filename=background_image)
    (bg_width, bg_height, bg_rows, bg_info) = bg.asDirect()
    bg_png = list(bg_rows)

    fg = png.Reader(filename=foreground_image)
    (fg_width, fg_height, fg_rows, fg_info) = fg.asDirect()
    fg_png = list(fg_rows)

    indent = int((bg_width * 4 - fg_width * 4) / 2)

    for i in range(0, fg_height):
        if i < bg_height:
            bg_row = bg_png[i]
            fg_row = fg_png[i]
            for j in range(0, fg_width):
                if fg_row[j * 4] > 0 or fg_row[j * 4 + 1] > 0 or fg_row[j * 4 + 2] > 0:
                    for k in range(4):
                        bg_row[indent + j * 4 + k] = fg_row[j * 4 + k]
            bg_png[i] = bg_row

    with open(combined_image, 'wb') as img:
        combined = png.Writer(bg_width, bg_height, greyscale=False, alpha=True, bitdepth=8)
        combined.write(img, bg_png)


def add_jewellery(all_image_rows, image_width, image_height, margin, fg_png, i, j, x_indent, y_indent, x_lo, x_hi, y_lo, y_hi, palette_from, palette_to):
    x_pos = (image_width + margin) * j + margin + x_indent
    y_pos = (image_height + margin) * i + margin + y_indent
    for y in range(y_lo, y_hi):
        fg_row = fg_png[y]
        for x in range(x_lo, x_hi):
            for k in range(3):
                if fg_row[x * 4] == palettes[palette_from][k][0] and fg_row[x * 4 + 1] == palettes[palette_from][k][1] and fg_row[x * 4 + 2] == palettes[palette_from][k][2]:
                    all_image_rows[y_pos + y][(x_pos + x) * 4 + 0] = palettes[palette_to][k][0]
                    all_image_rows[y_pos + y][(x_pos + x) * 4 + 1] = palettes[palette_to][k][1]
                    all_image_rows[y_pos + y][(x_pos + x) * 4 + 2] = palettes[palette_to][k][2]
                    all_image_rows[y_pos + y][(x_pos + x) * 4 + 3] = palettes[palette_to][k][3]


def add_gallery_background(all_image_rows, all_image_width, all_image_height, image_width, image_height, margin):
    gap = int(margin / 2)
    hframe = 3
    vframe = 2
    for j in range(all_image_height):
        row = []
        for i in range(all_image_width):
            hgap = (i - gap) % (image_width + margin)
            vgap = (j - gap) % (image_height + margin)
            if i < gap or i >= (all_image_width - gap) or hgap < hframe or hgap >= image_width + margin - hframe:
                row.extend([0, 0, 0, 255])
            elif j < gap or j >= (all_image_height - gap) or vgap < vframe or vgap >= image_height + margin - vframe:
                row.extend([0, 0, 0, 255])
            else:
                row.extend(palettes[8][1])
        all_image_rows.append(row)


def generate_gallery(image_width, image_height, margin, images_across, images_down, input_image, output_image, jewellery):
    all_image_rows = []
    all_image_width = (image_width + margin) * images_across + margin
    all_image_height = (image_height + margin) * images_down + margin

    add_gallery_background(all_image_rows, all_image_width, all_image_height, image_width, image_height, margin)

    for i in range(images_down):
        for j in range(images_across):
            if jewellery:
                combined_image = input_image + str(i) + '_0.png'
            else:
                combined_image = input_image + str(i) + '_' + str(j) + '.png'
            fg = png.Reader(filename=combined_image)
            (fg_width, fg_height, fg_rows, fg_info) = fg.asDirect()
            fg_png = list(fg_rows)
            x_pos = (image_width + margin) * j + margin
            y_pos = (image_height + margin) * i + margin
            for y in range(fg_height):
                fg_row = fg_png[y]
                for x in range(fg_width):
                    for k in range(4):
                        all_image_rows[y_pos + y][(x_pos + x) * 4 + k] = fg_row[x * 4 + k]

    if jewellery:
        fg = png.Reader(filename='../1-source-files/images/other-images/pngs/glassesImage_ppu.png')
        (fg_width, fg_height, fg_rows, fg_info) = fg.asDirect()
        fg_png = list(fg_rows)

        for i in range(images_down):
            # Add dark glasses to column 4 onwards
            for j in range(4, 8):
                add_jewellery(all_image_rows, image_width, image_height, margin, fg_png, i, j, x_indent=11, y_indent=20, x_lo=0, x_hi=fg_width, y_lo=0, y_hi=8, palette_from=11, palette_to=14)

            # Add left earring to column 1-3 and 5-7 onwards
            for j in [1, 2, 3, 5, 6, 7]:
                add_jewellery(all_image_rows, image_width, image_height, margin, fg_png, i, j, x_indent=3, y_indent=20, x_lo=0, x_hi=8, y_lo=8, y_hi=16, palette_from=11, palette_to=15)

            # Add right earring to column 2-3 and 6-7 onwards
            for j in [2, 3, 6, 7]:
                add_jewellery(all_image_rows, image_width, image_height, margin, fg_png, i, j, x_indent=27, y_indent=20, x_lo=8, x_hi=16, y_lo=8, y_hi=16, palette_from=11, palette_to=15)

            # Add medallion to columns 3 and 7
            for j in [3, 7]:
                add_jewellery(all_image_rows, image_width, image_height, margin, fg_png, i, j, x_indent=3, y_indent=33, x_lo=8, x_hi=16, y_lo=16, y_hi=24, palette_from=11, palette_to=15)
                add_jewellery(all_image_rows, image_width, image_height, margin, fg_png, i, j, x_indent=3, y_indent=33, x_lo=8, x_hi=24, y_lo=24, y_hi=32, palette_from=11, palette_to=15)
                add_jewellery(all_image_rows, image_width, image_height, margin, fg_png, i, j, x_indent=27, y_indent=25, x_lo=0, x_hi=8, y_lo=24, y_hi=40, palette_from=11, palette_to=15)

    with open(output_image, 'wb') as img:
        png_writer = png.Writer(width=all_image_width, height=all_image_height, greyscale=False, alpha=True, bitdepth=8)
        png_writer.write(img, all_image_rows)


# Palettes used to create PNGs
# For the 8 system palettes see .systemPalettes in source

palettes = [
    [[254, 110, 204, 255], [181,  49,  32, 255], [183,  30, 123, 255]],        # 0  System palette 0 for system image foreground sprite (PPU), e.g. Lave
    [[254, 196, 234, 255], [181,  49,  32, 255], [254, 110, 204, 255]],        # 1  System palette 1 for system image foreground sprite (PPU), e.g. Diso
    [[251, 194, 255, 255], [ 92,   0, 126, 255], [160,  26, 204, 255]],        # 2  System palette 2 for system image foreground sprite (PPU), e.g. Zaonce
    [[234, 158,  34, 255], [188, 190,   0, 255], [153,  78,   0, 255]],        # 3  System palette 3 for system image foreground sprite (PPU), e.g. Leesti
    [[136, 216,   0, 255], [ 75, 205, 222, 255], [ 56, 135,   0, 255]],        # 4  System palette 4 for system image foreground sprite (PPU), e.g. Onrira
    [[ 92, 228,  48, 255], [  0, 143,  50, 255], [  0,  82,   0, 255]],        # 5  System palette 5 for system image foreground sprite (PPU), e.g. Reorte
    [[211, 210, 255, 255], [100, 176, 255, 255], [ 20,  18, 167, 255]],        # 6  System palette 6 for system image foreground sprite (PPU), e.g. Uszaa
    [[ 72, 205, 222, 255], [146, 144, 255, 255], [  0, 124, 141, 255]],        # 7  System palette 7 for system image foreground sprite (PPU), e.g. Orerve
    [[173, 173, 173, 255], [102, 102, 102, 255], [255, 254, 255, 255]],        # 8  Grey palette for system image backgrounds (RAM)
    [[255,   0,   0, 255], [  0, 255,   0, 255], [  0,   0, 255, 255]],        # 9  RGB (useful for debugging)
    [[  0, 124, 141, 255], [173, 173, 173, 255], [255, 254, 255, 255]],        # 10 Palette for commander headshot background (RAM)
    [[153,  78,   0, 255], [234, 158,  34, 255], [247, 216, 165, 255]],        # 11 Palette for commander face foreground sprite (PPU)
    [[255, 255, 255, 255], [  0,   0,   0, 255], [255, 255, 255, 255]],        # 12 Only show colour 1 in the font character set
    [[0,     0,   0, 255], [255, 255, 255, 255], [255, 255, 255, 255]],        # 13 Only show colour 2 in the font character set
    [[0,     0,   0, 255], [173, 173, 173, 255], [255, 254, 255, 255]],        # 14 Palette for dark glasses
    [[0,     0,   0, 255], [188, 190,   0, 255], [228, 229, 148, 255]],        # 15 Palette for earrings and necklace
]

for i in range(15):
    for j in range(8):
        print("Generating image: systemImage" + str(i) + '_' + str(j))
        background_image = '../1-source-files/images/system-images/pngs/systemImage' + str(i) + '_ram.png'
        foreground_image = '../1-source-files/images/system-images/pngs/systemImage' + str(i) + '_' + str(j) + '_ppu.png'
        combined_image = '../1-source-files/images/system-images/combined/systemImage' + str(i) + '_' + str(j) + '.png'
        combine_images(background_image, foreground_image, combined_image)

for i in range(14):
    for j in range(1):
        print("Generating image: commanderImage" + str(i) + '_' + str(j))
        background_image = '../1-source-files/images/commander-images/pngs/headImage' + str(i) + '_ram.png'
        foreground_image = '../1-source-files/images/commander-images/pngs/faceImage' + str(i) + '_ppu.png'
        combined_image = '../1-source-files/images/commander-images/combined/commanderImage' + str(i) + '_' + str(j) + '.png'
        combine_images(background_image, foreground_image, combined_image)

# Gallery of system images

image_width = 64
image_height = 56
margin = 10
images_across = 8
images_down = 15
input_image = '../1-source-files/images/system-images/combined/systemImage'
output_image = '../1-source-files/images/system-images/allSystemImages.png'
print("Generating gallery: allSystemImages")
generate_gallery(image_width, image_height, margin, images_across, images_down, input_image, output_image, jewellery=False)

# Gallery of commander images

image_width = 48
image_height = 64
margin = 10
images_across = 8
images_down = 14
input_image = '../1-source-files/images/commander-images/combined/commanderImage'
output_image = '../1-source-files/images/commander-images/allCommanderImages.png'
print("Generating gallery: allCommanderImages")
generate_gallery(image_width, image_height, margin, images_across, images_down, input_image, output_image, jewellery=True)
