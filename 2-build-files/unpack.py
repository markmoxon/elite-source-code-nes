#!/usr/bin/env python
#
# ******************************************************************************
#
# NES ELITE IMAGE EXTRACTOR
#
# Written by Mark Moxon
#
# ******************************************************************************

import png


def fetch_byte(input_data, index):
    if index < len(input_data):
        byte = input_data[index]
        index += 1
        return byte, index
    else:
        print("End of file reached at index " + str(index))
        return -1, index


def unpack(input_data, unpacked_data, index):
    read_file = True
    while read_file:
        if index < len(input_data):
            byte = input_data[index]
            index += 1
            if byte >= 0x40 or byte == 0x30 or byte == 0x20 or byte == 0x10 or byte == 0x00:
                unpacked_data.append(byte)
            elif byte == 0x3F:
                print("End of section found at index " + str(index))
                read_file = False
            elif byte >= 0x01 and byte <= 0x0F:
                for i in range(0, byte):
                    unpacked_data.append(0)
            elif byte >= 0x11 and byte <= 0x1F:
                for i in range(0, byte - 0x10):
                    unpacked_data.append(0xFF)
            elif byte >= 0x21 and byte <= 0x2F:
                byte2, index = fetch_byte(input_data, index)
                if byte2 != -1:
                    for i in range(0, byte - 0x20):
                        unpacked_data.append(byte2)
                else:
                    read_file = False
            elif byte >= 0x31 and byte < 0x3F:
                for i in range(0, byte - 0x30):
                    byte2, index = fetch_byte(input_data, index)
                    if byte2 != -1:
                        unpacked_data.append(byte2)
                    else:
                        read_file = False
        else:
            print("End of file reached at index " + str(index))
            read_file = False
    return index


def extract(input_data, unpacked_data, index):
    read_file = True
    while read_file:
        if index < len(input_data):
            byte = input_data[index]
            unpacked_data.append(byte)
            index += 1
        else:
            print("End of file reached at index " + str(index))
            read_file = False
    return index


def unpack_data(input_data, filename, index, data_is_packed):
    unpacked_data = bytearray()
    if data_is_packed:
        index = unpack(input_data, unpacked_data, index)
    else:
        index = extract(input_data, unpacked_data, index)
    output_file = open(filename, "wb")
    output_file.write(unpacked_data)
    output_file.close()
    return unpacked_data, index


def png_pixel(colour, palette):
    if colour == 0:
        return [0, 0, 0]
    return palettes[palette][colour - 1]


def png_8_pixel_row(byte_0, byte_1, palette):
    row = []
    for i in range(0, 8):
        pixel = ((byte_0 & (1 << i)) + ((byte_1 & (1 << i)) << 1)) >> i
        row = png_pixel(pixel, palette) + row
    return row


def png_full_pixel_row_ram(y, pixel_width, data_0, data_1, palette):
    row = []
    start_byte = (y // 8) * pixel_width + (y % 8)
    for i in range(start_byte, start_byte + pixel_width, 8):
        row = row + png_8_pixel_row(pad_with_black(data_0, i), pad_with_black(data_1, i), palette)
    return row


def png_full_pixel_row_ppu(y, pixel_width, data, palette):
    row = []
    start_byte = (y // 8) * pixel_width * 2 + (y % 8)
    for i in range(start_byte, start_byte + (pixel_width * 2), 16):
        row = row + png_8_pixel_row(pad_with_black(data, i), pad_with_black(data, i + 8), palette)
    return row


def pad_with_black(data, i):
    if i < len(data):
        return data[i]
    return 0


def create_png_from_ppu_data(unpacked_data, output_path_pngs, pixel_width, palette):
    pixel_height = int(0.5 * len(unpacked_data) / (pixel_width / 8))

    if pixel_height != 8 * (pixel_height // 8):
        pixel_height = 8 * (pixel_height // 8) + 8

    print("Image dimensions " + str(pixel_width) + "px wide x " + str(pixel_height) + "px high")

    png_array = []
    for i in range(0, pixel_height):
        pixel_row = png_full_pixel_row_ppu(i, pixel_width, unpacked_data, palette)
        png_array.append(pixel_row)

    png.from_array(png_array, 'RGB').save(output_path_pngs + "_ppu.png")


def create_png_from_ram_data(unpacked_data_0, unpacked_data_1, output_path_pngs, pixel_width, palette):
    pixel_height = int(len(unpacked_data_0) / (pixel_width / 8))

    if pixel_height != 8 * (pixel_height // 8):
        pixel_height = 8 * (pixel_height // 8) + 8

    print("Image dimensions 0/1 " + str(pixel_width) + "px wide x " + str(pixel_height) + "px high")

    png_array = []
    for i in range(0, pixel_height):
        pixel_row = png_full_pixel_row_ram(i, pixel_width, unpacked_data_0, unpacked_data_1, palette)
        png_array.append(pixel_row)

    png.from_array(png_array, 'RGB').save(output_path_pngs + "_ram.png")


def extract_image(input_data, sections, output_folder, input_file, palette, pixel_width, data_is_packed):
    print("\nExtracting image: " + input_file)

    output_path_pngs = output_folder + "pngs/" + input_file
    output_path_binaries = output_folder + "binaries/" + input_file

    unpacked_data_0, index = unpack_data(input_data, output_path_binaries + "_pattern0.bin", 0, data_is_packed)

    if sections >= 2:
        unpacked_data_1, index = unpack_data(input_data, output_path_binaries + "_pattern1.bin", index, data_is_packed)

    if sections >= 4:
        unpacked_data_2, index = unpack_data(input_data, output_path_binaries + "_sprite0.bin", index, data_is_packed)
        unpacked_data_3, index = unpack_data(input_data, output_path_binaries + "_sprite1.bin", index, data_is_packed)

    print("End index is " + str(index))
    print("File size " + str(len(input_data)))

    if (index == len(input_data)):
        print("All sections extracted")
    else:
        print("More sections detected")

    if sections == 1:
        create_png_from_ppu_data(unpacked_data_0, output_path_pngs, pixel_width, palette)

    if sections >= 2:
        if sections >= 4:
            # For multiple-section images, RAM is always greyscale
            create_png_from_ram_data(unpacked_data_0, unpacked_data_1, output_path_pngs, pixel_width, 1)
        else:
            create_png_from_ram_data(unpacked_data_0, unpacked_data_1, output_path_pngs, pixel_width, palette)

    if sections >= 4:
        create_png_from_ppu_data(unpacked_data_2 + unpacked_data_3, output_path_pngs, pixel_width, palette)


# Main loop

# Palettes used to create PNGs

palettes = [
    [[255,   0,   0], [  0, 255,   0], [  0,   0, 255]],        # 0 RGB
    [[173, 173, 173], [102, 102, 102], [255, 254, 255]],        # 1 Grey palette for system image backgrounds (RAM)
    [[234, 158,  34], [188, 190,   0], [153,  78,   0]],        # 2 Palette for Leesti foreground sprite (PPU)
    [[254, 196, 234], [181,  49,  32], [254, 110, 204]],        # 3 Palette for Diso foreground sprite (PPU)
    [[ 92, 228,  48], [  0, 143,  50], [  0,  82,   0]],        # 4 Palette for Reorte foreground sprite (PPU)
    [[254, 110, 204], [181,  49,  32], [183,  30, 123]],        # 5 Palette for Lave foreground sprite (PPU)
    [[188, 190,   0], [173, 173, 173], [255, 254, 255]],        # 6 Palette for commander headshot background (RAM)
    [[153,  78,   0], [234, 158,  34], [247, 216, 165]],        # 7 Palette for commander face foreground sprite (PPU)
    [[255, 255, 255], [  0,   0,   0], [255, 255, 255]],        # 8 Only show colour 1
    [[0,     0,   0], [255, 255, 255], [255, 255, 255]],        # 9 Only show colour 2
]

# Palettes to use for colour foreground sprite in system images

system_image_palettes = [
    1,
    1,
    1,
    1,
    5,      # 4 Lave
    1,
    1,
    1,
    3,      # 8 Diso
    4,      # 9 Reorte
    2,      # 10 Leesti
    1,
    1,
    1,
    1
]

# faceOffset entries from bank 4

face_offsets = [
    0x001E,
    0x0195,
    0x0305,
    0x0473,
    0x05F9,
    0x0783,
    0x0904,
    0x0A87,
    0x0C09,
    0x0D7C,
    0x0EFC,
    0x108E,
    0x1205,
    0x1387,
    0x150E
]

# headOffset entries from bank 4

head_offsets = [
    0x001E,
    0x0195,
    0x0310,
    0x047D,
    0x0611,
    0x07A4,
    0x092C,
    0x0AAC,
    0x0C28,
    0x0D9F,
    0x0F27,
    0x10C9,
    0x1240,
    0x13D6,
    0x1585
]

# systemOffset entries from bank 4

system_offsets = [
    0x0020,
    0x0458,
    0x0847,
    0x0E08,
    0x12E0,
    0x166C,
    0x1A90,
    0x1E90,
    0x22E8,
    0x2611,
    0x29D8,
    0x2E20,
    0x3232,
    0x36C5,
    0x3B07,
    0x3E82
]

# Load game binaries

bank_data3 = bytearray()
bank_file = open("../4-reference-binaries/ntsc/bank3.bin", "rb")
bank_data3.extend(bank_file.read())
bank_file.close()

bank_data4 = bytearray()
bank_file = open("../4-reference-binaries/ntsc/bank4.bin", "rb")
bank_data4.extend(bank_file.read())
bank_file.close()

bank_data5 = bytearray()
bank_file = open("../4-reference-binaries/ntsc/bank5.bin", "rb")
bank_data5.extend(bank_file.read())
bank_file.close()

bank_data7 = bytearray()
bank_file = open("../4-reference-binaries/ntsc/bank7.bin", "rb")
bank_data7.extend(bank_file.read())
bank_file.close()

# Face images have one section per image, one image per face
# Stored as interleaved PPU tile format for sprite foreground
# (i.e. each pattern is 8 bytes for bit 0, then 8 bytes for bit 1)

for i in range(0, 14):
    start = face_offsets[i] + 0x0C
    end = face_offsets[i + 1] + 0x0C
    extract_image(bank_data4[start: end], 1, "../1-source-files/images/face-images/", "faceImage" + str(i), palette=7, pixel_width=40, data_is_packed=True)

# Headshot images have two sections per image, one image per headshot
# Each section is stored as a 1-bpp pattern buffer for unpacking into RAM
# (i.e. section 1 contains bit 0, section 2 contains bit 1)

for i in range(0, 14):
    start = head_offsets[i] + 0x151A
    end = head_offsets[i + 1] + 0x151A
    extract_image(bank_data4[start: end], 2, "../1-source-files/images/headshot-images/", "headImage" + str(i), palette=6, pixel_width=48, data_is_packed=True)

# System images have four sections per image, two images per system
# First two sections are as for headshots: each is in 1-bpp pattern buffer format
# Second two sections are as for faces: concatenate to give interleaved PPU tile format

for i in range(0, 15):
    start = system_offsets[i] + 0x0C
    end = system_offsets[i + 1] + 0x0C
    palette = system_image_palettes[i]
    extract_image(bank_data5[start: end], 4, "../1-source-files/images/system-images/", "systemImage" + str(i), palette, pixel_width=64, data_is_packed=True)

# Other images all have one section per image
# Stored as interleaved PPU tile format
# (i.e. each pattern is 8 bytes for bit 0, then 8 bytes for bit 1)

start = 0xAA9F - 0x8000
end = 0xAB1C - 0x8000
extract_image(bank_data4[start: end], 1, "../1-source-files/images/other-images/", "glassesImage", palette=7, pixel_width=24, data_is_packed=True)

start = 0xAB1C - 0x8000
end = 0xB5CC - 0x8000
extract_image(bank_data4[start: end], 1, "../1-source-files/images/other-images/", "eliteLogoBig", palette=7, pixel_width=48, data_is_packed=True)

start = 0x9760 - 0x8000
end = 0x9FA1 - 0x8000
extract_image(bank_data3[start: end], 1, "../1-source-files/images/other-images/", "dialsImage", palette=7, pixel_width=160, data_is_packed=True)

start = 0x9FA1 - 0x8000
end = 0xA493 - 0x8000
extract_image(bank_data3[start: end], 1, "../1-source-files/images/other-images/", "cobraImage", palette=7, pixel_width=40, data_is_packed=True)

start = 0xA4D3 - 0x8000
end = 0xA730 - 0x8000
extract_image(bank_data3[start: end], 1, "../1-source-files/images/other-images/", "eliteLogo", palette=7, pixel_width=40, data_is_packed=True)

start = 0xA71B - 0x8000
end = 0xA730 - 0x8000
extract_image(bank_data3[start: end], 1, "../1-source-files/images/other-images/", "eliteLogoBall", palette=7, pixel_width=16, data_is_packed=True)

start = 0xA493 - 0x8000
end = 0xA4D3 - 0x8000
extract_image(bank_data3[start: end], 1, "../1-source-files/images/other-images/", "missileImage", palette=7, pixel_width=16, data_is_packed=False)

start = 0x8100 - 0x8000
end = 0x8500 - 0x8000
extract_image(bank_data3[start: end], 1, "../1-source-files/images/other-images/", "iconBarImage0", palette=7, pixel_width=256, data_is_packed=False)

start = 0x8500 - 0x8000
end = 0x8900 - 0x8000
extract_image(bank_data3[start: end], 1, "../1-source-files/images/other-images/", "iconBarImage1", palette=7, pixel_width=256, data_is_packed=False)

start = 0x8900 - 0x8000
end = 0x8D00 - 0x8000
extract_image(bank_data3[start: end], 1, "../1-source-files/images/other-images/", "iconBarImage2", palette=7, pixel_width=256, data_is_packed=False)

start = 0x8D00 - 0x8000
end = 0x9100 - 0x8000
extract_image(bank_data3[start: end], 1, "../1-source-files/images/other-images/", "iconBarImage3", palette=7, pixel_width=256, data_is_packed=False)

start = 0x9100 - 0x8000
end = 0x9500 - 0x8000
extract_image(bank_data3[start: end], 1, "../1-source-files/images/other-images/", "iconBarImage4", palette=7, pixel_width=256, data_is_packed=False)

# The font is stored as interleaved PPU tile format
# But with one set of characters in colour 1 and another in colour 2
# We can save this as two images, with different palettes, to expose the letters

start = 0xFCE8 - 0xC000
end = 0xFFE0 - 0xC000
extract_image(bank_data7[start: end], 1, "../1-source-files/images/other-images/", "font_0", palette=8, pixel_width=64, data_is_packed=False)
extract_image(bank_data7[start: end], 1, "../1-source-files/images/other-images/", "font_1", palette=9, pixel_width=64, data_is_packed=False)
