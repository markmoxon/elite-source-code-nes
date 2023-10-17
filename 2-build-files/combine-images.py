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
    # Combine foreground and background images

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


def generate_gallery(image_width, image_height, margin, images_across, images_down, input_image, output_image):
    all_image_rows = []
    all_image_width = (image_width + margin) * images_across + margin
    all_image_height = (image_height + margin) * images_down + margin

    for j in range(all_image_height):
        row = []
        for i in range(all_image_width):
            row.extend([173, 173, 173, 255])
        all_image_rows.append(row)

    for i in range(images_down):
        for j in range(images_across):
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

    with open(output_image, 'wb') as img:
        png_writer = png.Writer(width=all_image_width, height=all_image_height, greyscale=False, alpha=True, bitdepth=8)
        png_writer.write(img, all_image_rows)


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


# All system images

image_width = 64
image_height = 56
margin = 10
images_across = 8
images_down = 15
input_image = '../1-source-files/images/system-images/combined/systemImage'
output_image = '../1-source-files/images/system-images/allSystemImages.png'
print("Generating gallery: allSystemImages")
generate_gallery(image_width, image_height, margin, images_across, images_down, input_image, output_image)

image_width = 48
image_height = 64
margin = 10
images_across = 1
images_down = 14
input_image = '../1-source-files/images/commander-images/combined/commanderImage'
output_image = '../1-source-files/images/commander-images/allCommanderImages.png'
print("Generating gallery: allCommanderImages")
generate_gallery(image_width, image_height, margin, images_across, images_down, input_image, output_image)
