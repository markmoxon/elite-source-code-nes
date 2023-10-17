#!/usr/bin/env python
#
# ******************************************************************************
#
# NES ELITE DATA UNPACKER
#
# Written by Mark Moxon
#
# This script implements the algorithm in the UnpackToRAM and UnpackToPPU
# routines to unpack images and data directly from the game binary
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


def png_pixel(colour, palette, transparent):
    if colour == 0:
        if transparent:
            return [0, 0, 0, 0]
        else:
            return [0, 0, 0, 255]
    return palettes[palette][colour - 1]


def png_8_pixel_row(byte_0, byte_1, palette, transparent):
    row = []
    if byte_0 == -1 and byte_1 == -1:
        for i in range(0, 8):
            row = [0, 0, 0, 0] + row
    else:
        if byte_0 == -1:
            byte_0 = 0
        if byte_1 == -1:
            byte_1 = 0
        for i in range(0, 8):
            pixel = ((byte_0 & (1 << i)) + ((byte_1 & (1 << i)) << 1)) >> i
            row = png_pixel(pixel, palette, transparent) + row
    return row


def png_full_pixel_row_ram(y, pixel_width, data_0, data_1, palette):
    row = []
    start_byte = (y // 8) * pixel_width + (y % 8)
    for i in range(start_byte, start_byte + pixel_width, 8):
        row = row + png_8_pixel_row(pad_with_black(data_0, i), pad_with_black(data_1, i), palette, transparent=False)
    return row


def png_full_pixel_row_ppu(y, pixel_width, data, palette, transparent):
    row = []
    start_byte = (y // 8) * pixel_width * 2 + (y % 8)
    for i in range(start_byte, start_byte + (pixel_width * 2), 16):
        row = row + png_8_pixel_row(pad_with_black(data, i), pad_with_black(data, i + 8), palette, transparent)
    return row


def pad_with_black(data, i):
    if i < len(data):
        return data[i]
    return -1


def create_png_from_ppu_data(unpacked_data, output_path_pngs, pixel_width, palette, transparent):
    pixel_height = int(0.5 * len(unpacked_data) / (pixel_width / 8))

    if pixel_height != 8 * (pixel_height // 8):
        pixel_height = 8 * (pixel_height // 8) + 8

    print("Image dimensions " + str(pixel_width) + "px wide x " + str(pixel_height) + "px high")

    png_array = []
    for i in range(0, pixel_height):
        pixel_row = png_full_pixel_row_ppu(i, pixel_width, unpacked_data, palette, transparent)
        png_array.append(pixel_row)

    png.from_array(png_array, 'RGBA').save(output_path_pngs + "_ppu.png")


def create_png_from_ram_data(unpacked_data_0, unpacked_data_1, output_path_pngs, pixel_width, palette):
    pixel_height = int(len(unpacked_data_0) / (pixel_width / 8))

    if pixel_height != 8 * (pixel_height // 8):
        pixel_height = 8 * (pixel_height // 8) + 8

    print("Image dimensions 0/1 " + str(pixel_width) + "px wide x " + str(pixel_height) + "px high")

    png_array = []
    for i in range(0, pixel_height):
        pixel_row = png_full_pixel_row_ram(i, pixel_width, unpacked_data_0, unpacked_data_1, palette)
        png_array.append(pixel_row)

    png.from_array(png_array, 'RGBA').save(output_path_pngs + "_ram.png")


def extract_image(input_data, sections, output_folder, input_file, palette, pixel_width, data_is_packed, transparent):
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

    if sections == 0:
        # For one-bit-per-pixel pattern buffer format, so fill bitplane 1 with zeroes
        create_png_from_ram_data(unpacked_data_0, [0] * len(unpacked_data_0), output_path_pngs, pixel_width, palette)

    if sections == 1:
        create_png_from_ppu_data(unpacked_data_0, output_path_pngs, pixel_width, palette, transparent)

    if sections >= 2:
        if sections >= 4:
            # For multiple-section images, RAM is always greyscale
            create_png_from_ram_data(unpacked_data_0, unpacked_data_1, output_path_pngs, pixel_width, 8)
        else:
            create_png_from_ram_data(unpacked_data_0, unpacked_data_1, output_path_pngs, pixel_width, palette)

    if sections >= 4:
        for palette in range(0, 8):
            create_png_from_ppu_data(unpacked_data_2 + unpacked_data_3, output_path_pngs + "_" + str(palette), pixel_width, palette, transparent)


# Main loop

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
    extract_image(bank_data4[start: end], 1, "../1-source-files/images/commander-images/", "faceImage" + str(i), palette=11, pixel_width=40, data_is_packed=True, transparent=True)

# Headshot images have two sections per image, one image per headshot
# Each section is stored as a 1-bpp pattern buffer for unpacking into RAM
# (i.e. section 1 contains bit 0, section 2 contains bit 1)

for i in range(0, 14):
    start = head_offsets[i] + 0x151A
    end = head_offsets[i + 1] + 0x151A
    extract_image(bank_data4[start: end], 2, "../1-source-files/images/commander-images/", "headImage" + str(i), palette=10, pixel_width=48, data_is_packed=True, transparent=False)

# System images have four sections per image, two images per system
# First two sections are as for headshots: each is in 1-bpp pattern buffer format
# Second two sections are as for faces: concatenate to give interleaved PPU tile format

for i in range(0, 15):
    start = system_offsets[i] + 0x0C
    end = system_offsets[i + 1] + 0x0C
    extract_image(bank_data5[start: end], 4, "../1-source-files/images/system-images/", "systemImage" + str(i), palette=0, pixel_width=64, data_is_packed=True, transparent=True)

# Other images all have one section per image
# Stored as interleaved PPU tile format
# (i.e. each pattern is 8 bytes for bit 0, then 8 bytes for bit 1)

start = 0xAA9F - 0x8000
end = 0xAB1C - 0x8000
extract_image(bank_data4[start: end], 1, "../1-source-files/images/other-images/", "glassesImage", palette=11, pixel_width=24, data_is_packed=True, transparent=False)

start = 0xAB1C - 0x8000
end = 0xB5CC - 0x8000
extract_image(bank_data4[start: end], 1, "../1-source-files/images/other-images/", "bigLogoImage", palette=11, pixel_width=48, data_is_packed=True, transparent=False)

start = 0x9760 - 0x8000
end = 0x9FA1 - 0x8000
extract_image(bank_data3[start: end], 1, "../1-source-files/images/other-images/", "dashImage", palette=11, pixel_width=160, data_is_packed=True, transparent=False)

start = 0x9FA1 - 0x8000
end = 0xA493 - 0x8000
extract_image(bank_data3[start: end], 1, "../1-source-files/images/other-images/", "cobraImage", palette=11, pixel_width=40, data_is_packed=True, transparent=False)

start = 0xA4D3 - 0x8000
end = 0xA730 - 0x8000
extract_image(bank_data3[start: end], 1, "../1-source-files/images/other-images/", "smallLogoImage", palette=11, pixel_width=40, data_is_packed=True, transparent=False)

start = 0xA71B - 0x8000
end = 0xA730 - 0x8000
extract_image(bank_data3[start: end], 1, "../1-source-files/images/other-images/", "logoBallImage", palette=11, pixel_width=16, data_is_packed=True, transparent=False)

start = 0xA493 - 0x8000
end = 0xA4D3 - 0x8000
extract_image(bank_data3[start: end], 1, "../1-source-files/images/other-images/", "inventoryIcon", palette=11, pixel_width=16, data_is_packed=False, transparent=False)

start = 0x8100 - 0x8000
end = 0x8500 - 0x8000
extract_image(bank_data3[start: end], 1, "../1-source-files/images/other-images/", "iconBarImage0", palette=11, pixel_width=256, data_is_packed=False, transparent=False)

start = 0x8500 - 0x8000
end = 0x8900 - 0x8000
extract_image(bank_data3[start: end], 1, "../1-source-files/images/other-images/", "iconBarImage1", palette=11, pixel_width=256, data_is_packed=False, transparent=False)

start = 0x8900 - 0x8000
end = 0x8D00 - 0x8000
extract_image(bank_data3[start: end], 1, "../1-source-files/images/other-images/", "iconBarImage2", palette=11, pixel_width=256, data_is_packed=False, transparent=False)

start = 0x8D00 - 0x8000
end = 0x9100 - 0x8000
extract_image(bank_data3[start: end], 1, "../1-source-files/images/other-images/", "iconBarImage3", palette=11, pixel_width=256, data_is_packed=False, transparent=False)

start = 0x9100 - 0x8000
end = 0x9500 - 0x8000
extract_image(bank_data3[start: end], 1, "../1-source-files/images/other-images/", "iconBarImage4", palette=11, pixel_width=256, data_is_packed=False, transparent=False)

# The lines image is stored as a 1bpp pattern buffer image

start = 0xFC00 - 0xC000
end = 0xFCE8 - 0xC000
extract_image(bank_data7[start: end], 0, "../1-source-files/images/other-images/", "lineImage", palette=12, pixel_width=120, data_is_packed=False, transparent=False)

# The font image is stored as a 1bpp pattern buffer image
# There are 94 characters in the font

start = 0xFCE8 - 0xC000
end = 0xFFD8 - 0xC000
extract_image(bank_data7[start: end], 0, "../1-source-files/images/other-images/", "fontImage", palette=12, pixel_width=64, data_is_packed=False, transparent=False)
