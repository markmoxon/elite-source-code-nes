# NI% = 42          \ Sometimes need to do NI%-4

# NOSH = 8          \ As UNIV contains 9 addresses, 0 to NOSH

# NOST = 20

# VE = &57
# LL = 29

# MSL = 1
# SST = 2
# PLT = 4
# SHU = 9
# ANA = 14
# HER = 15
# COPS = 16
# SH3 = 17
# WRM = 23
# THG = 29
# TGL = 30

# CYL = 11
# CYL2 = &18

# solaun = 9

# Variables

label(0x0000, "ZP")
label(0x0002, "RAND")
expr_label(0x0003, "RAND+1")
expr_label(0x0004, "RAND+2")
expr_label(0x0005, "RAND+3")
label(0x0006, "T1")
label(0x0007, "SC")
expr_label(0x0008, "SC+1")
label(0x0009, "XX1")
label(0x0009, "INWK")
expr_label(0x000A, "INWK+1")
expr_label(0x000B, "INWK+2")
expr_label(0x000C, "INWK+3")
expr_label(0x000D, "INWK+4")
expr_label(0x000E, "INWK+5")
expr_label(0x000F, "INWK+6")
expr_label(0x0010, "INWK+7")
expr_label(0x0011, "INWK+8")
expr_label(0x0012, "INWK+9")
expr_label(0x0013, "INWK+10")
expr_label(0x0014, "INWK+11")
expr_label(0x0015, "INWK+12")
expr_label(0x0016, "INWK+13")
expr_label(0x0017, "INWK+14")
expr_label(0x0018, "INWK+15")
expr_label(0x0019, "INWK+16")
expr_label(0x001A, "INWK+17")
expr_label(0x001B, "INWK+18")
expr_label(0x001C, "INWK+19")
expr_label(0x001D, "INWK+20")
expr_label(0x001E, "INWK+21")
expr_label(0x001F, "INWK+22")
expr_label(0x0020, "INWK+23")
expr_label(0x0021, "INWK+24")
expr_label(0x0022, "INWK+25")
expr_label(0x0023, "INWK+26")
expr_label(0x0024, "INWK+27")
expr_label(0x0025, "INWK+28")
expr_label(0x0026, "INWK+29")
expr_label(0x0027, "INWK+30")
expr_label(0x0028, "INWK+31")
expr_label(0x0029, "INWK+32")
expr_label(0x002A, "INWK+33")            # No heap in NES Elite, so this is reused
expr_label(0x002B, "INWK+34")            # No heap in NES Elite, so this is reused
expr_label(0x002C, "INWK+35")            # Is this used? NI% is one bigger than in Master
label(0x002D, "NEWB")
label(0x002F, "P")
expr_label(0x0030, "P+1")
expr_label(0x0031, "P+2")
label(0x0032, "XC")

label(0x0033, "hiddenColour")       # Contains the colour value for when lines are hidden
                                    # in palette 0, e.g. &0F for black (SetPalette)

label(0x0034, "visibleColour")      # Contains the colour value for when lines are visible
                                    # in palette 0, e.g. &2C for cyan (SetPalette)

label(0x0035, "paletteColour1")     # Contains the colour value to be used for palette entry 1
                                    # in the current (non-space) view (SetPalette)

label(0x0036, "paletteColour2")     # Contains the colour value to be used for palette entry 1
                                    # in the current (non-space) view (SetPalette)

label(0x0038, "nmiTimer")           # Mine, decremented in NMI from 50 (&32) to 1
                                    # and back up to &32
label(0x0039, "nmiTimerLo")         # Mine, incremented by 1 every time nmiTimer wraps
label(0x003A, "nmiTimerHi")

label(0x003B, "YC")
label(0x003C, "QQ17")
label(0x003D, "K3")
label(0x003D, "XX2")
expr_label(0x003E, "XX2+1")
expr_label(0x003F, "XX2+2")
expr_label(0x0040, "XX2+3")
expr_label(0x0041, "XX2+4")
expr_label(0x0042, "XX2+5")
expr_label(0x0043, "XX2+6")
expr_label(0x0044, "XX2+7")
expr_label(0x0045, "XX2+8")
expr_label(0x0046, "XX2+9")
expr_label(0x0047, "XX2+10")
expr_label(0x0048, "XX2+11")
expr_label(0x0049, "XX2+12")
expr_label(0x004A, "XX2+13")
label(0x004B, "K4")
expr_label(0x004C, "K4+1")
label(0x004D, "XX16")
expr_label(0x004E, "XX16+1")
expr_label(0x004F, "XX16+2")
expr_label(0x0050, "XX16+3")
expr_label(0x0051, "XX16+4")
expr_label(0x0052, "XX16+5")
expr_label(0x0053, "XX16+6")
expr_label(0x0054, "XX16+7")
expr_label(0x0055, "XX16+8")
expr_label(0x0056, "XX16+9")
expr_label(0x0057, "XX16+10")
expr_label(0x0058, "XX16+11")
expr_label(0x0059, "XX16+12")
expr_label(0x005A, "XX16+13")
expr_label(0x005B, "XX16+14")
expr_label(0x005C, "XX16+15")
expr_label(0x005D, "XX16+16")
expr_label(0x005E, "XX16+17")
label(0x005F, "XX0")
expr_label(0x0060, "XX0+1")
label(0x0061, "XX19")
label(0x0061, "INF")
expr_label(0x0062, "INF+1")
label(0x0063, "V")
expr_label(0x0064, "V+1")
label(0x0065, "XX")
expr_label(0x0066, "XX+1")
label(0x0067, "YY")
expr_label(0x0068, "YY+1")
label(0x0069, "BETA")
label(0x006A, "BET1")
label(0x006B, "QQ22")
expr_label(0x006C, "QQ22+1")
label(0x006D, "ECMA")
label(0x006E, "ALP1")
label(0x006F, "ALP2")
expr_label(0x0070, "ALP2+1")
label(0x0071, "XX15")
label(0x0071, "X1")
label(0x0072, "Y1")
label(0x0073, "X2")
label(0x0074, "Y2")
expr_label(0x0075, "XX15+4")
expr_label(0x0076, "XX15+5")
label(0x0077, "XX12")
expr_label(0x0078, "XX12+1")
expr_label(0x0079, "XX12+2")
expr_label(0x007A, "XX12+3")
expr_label(0x007B, "XX12+4")
expr_label(0x007C, "XX12+5")
label(0x007D, "K")
expr_label(0x007E, "K+1")
expr_label(0x007F, "K+2")
expr_label(0x0080, "K+3")
label(0x0082, "QQ15")
expr_label(0x0083, "QQ15+1")
expr_label(0x0084, "QQ15+2")
expr_label(0x0085, "QQ15+3")
expr_label(0x0086, "QQ15+4")
expr_label(0x0087, "QQ15+5")
label(0x0088, "K5")
label(0x0088, "XX18")
expr_label(0x0089, "XX18+1")
expr_label(0x008A, "XX18+2")
expr_label(0x008B, "XX18+3")
label(0x008C, "K6")
expr_label(0x008D, "K6+1")
expr_label(0x008E, "K6+2")
expr_label(0x008F, "K6+3")
expr_label(0x0090, "K6+4")
label(0x0091, "BET2")
expr_label(0x0092, "BET2+1")
label(0x0093, "DELTA")
label(0x0094, "DELT4")
expr_label(0x0095, "DELT4+1")
label(0x0096, "U")
label(0x0097, "Q")
label(0x0098, "R")
label(0x0099, "S")
label(0x009A, "T")
label(0x009B, "XSAV")
label(0x009C, "YSAV")
label(0x009D, "XX17")
label(0x009E, "QQ11")
label(0x009F, "QQ11a")              # Mine, can be 0, &FF or QQ11 - some kind of view flag
label(0x00A0, "ZZ")
label(0x00A1, "XX13")
label(0x00A2, "MCNT")
label(0x00A3, "TYPE")
label(0x00A4, "ALPHA")
label(0x00A5, "QQ12")
label(0x00A6, "TGT")
label(0x00A7, "FLAG")
label(0x00A8, "CNT")
label(0x00A9, "CNT2")
label(0x00AA, "STP")
label(0x00AB, "XX4")
label(0x00AC, "XX20")
label(0x00AE, "RAT")
label(0x00AF, "RAT2")
label(0x00B0, "widget")
label(0x00B1, "Yx1M2")              # Mine = height of screen for text screens?
label(0x00B2, "Yx2M2")              # Mine = 2 x Yx1M2
label(0x00B3, "Yx2M1")
label(0x00B4, "messXC")
label(0x00B6, "newzp")

label(0x00B8, "tileNumber")         # Mine, contains tile number to draw into

label(0x00B9, "pattBufferHi")       # Mine, high byte of current pattern buffer (&60 or &68)

label(0x00BA, "SC2")                # Mine, typically an address that's used alongside
expr_label(0x00BB, "SC2+1")         # SC(1 0)

label(0x00C0, "drawingPhase")       # Mine, 0 or 1, flipped manually by calling ChangeDrawingPhase,
                                    # controls whether we are showing namespace/palette buffer 0 or 1
                                    # (and which tile number is chosen from the followingf)

label(0x00C1, "tile0Phase0")        # Mine, stores a pair of tile numbers, for phase 0 and 1
label(0x00C2, "tile0Phase1")

label(0x00C3, "tile1Phase0")        # Mine, stores a pair of tile numbers, for phase 0 and 1
label(0x00C4, "tile1Phase1")

label(0x00C5, "tile2Phase0")        # Mine, stores a pair of tile numbers, for phase 0 and 1
label(0x00C6, "tile2Phase1")

label(0x00C7, "tile3Phase0")        # Mine, stores a pair of tile numbers, for phase 0 and 1
label(0x00C8, "tile3Phase1")

label(0x00D0, "tempVar")            # Mine, stores a 16-bit number, not an address?
expr_label(0x00D1, "tempVar+1")

label(0x00D4, "addr1")              # Mine, an address within the PPU to be poked to
expr_label(0x00D5, "addr1+1")

label(0x00DF, "pallettePhasex8")    # Set to 0 or palettePhase * 8 (i.e. 0 or %0001)

label(0x00E1, "patternBufferLo")    # Mine, address of the current pattern buffer (unused)
label(0x00E2, "patternBufferHi")    # i.e. &6000 when drawingPhase = 0
                                    #      &6800 when drawingPhase = 1

label(0x00E3, "ppuNametableLo")     # Mine, address of the current PPU nametable (unused)
label(0x00E4, "ppuNametableHi")     # i.e. &2000 when palettePhase = 0
                                    #      &2400 when palettePhase = 1

label(0x00E5, "drawingPhaseDebug")  # Mine, always set to 0 when changing drawing phase

label(0x00E6, "nameBufferHi")       # Mine, high byte of current nametable buffer (&70 or &74)

label(0x00E7, "startupDebug")       # Mine, set to 0 in S%, never used again

label(0x00E8, "temp1")              # Mine, temporary variable, used in bank 7

label(0x00E9, "setupPPUForIconBar") # Mine, bit 7 set means we set nametable 0 and palette
                                    # table 0 when the PPU starts drawing the icon bar

label(0x00EA, "showUserInterface")  # Mine, bit 7 set means display user interface (clear for
                                    # game over screen) 

label(0x00EB, "addr4")              # Mine, an address within the PPU to be poked to
expr_label(0x00EC, "addr4+1")

label(0x00ED, "addr5")              # Mine, an address to fetch PPU data from
expr_label(0x00EE, "addr5+1")

label(0x00F1, "addr6")              # Mine
expr_label(0x00F2, "addr6+1")

label(0x00F3, "palettePhase")       # Mine, 0 or 1, flips every NMI, controls palette switching for space
                                    # view in NMI

label(0x00F4, "otherPhase")         # Mine, 0 or 1, flipped in subm_CB42 ???

label(0x00F5, "ppuCtrlCopy")        # Mine, contains a copy of PPU_CTRL

label(0x00F7, "currentBank")        # Mine, contains current lower bank number

label(0x00F8, "runningSetBank")     # Mine, set to &FF if we are inside SetBank when
                                    # the NMI interrupts, 0 otherwise

label(0x00FA, "addr2")              # Mine, an address within the PPU to be poked to
expr_label(0x00FB, "addr2+1")

label(0x0100, "XX3")
for i in range(1, 24):
    expr_label(0x0100 + i, "XX3+" + str(i))

for i in range(0, 64):
    label(0x0200 + i * 4, "ySprite" + str(i))
    label(0x0201 + i * 4, "tileSprite" + str(i))
    label(0x0202 + i * 4, "attrSprite" + str(i))
    label(0x0203 + i * 4, "xSprite" + str(i))

expr_label(0x036A, "FRIN")
expr_label(0x036B, "FRIN+1")
expr_label(0x036C, "FRIN+2")
expr_label(0x036D, "FRIN+3")
expr_label(0x036E, "FRIN+4")
expr_label(0x036F, "FRIN+5")
expr_label(0x0370, "FRIN+6")
expr_label(0x0371, "FRIN+7")
expr_label(0x0372, "FRIN+8")
label(0x0373, "JUNK")
label(0x0374, "L0374")
label(0x037E, "L037E")
label(0x0388, "auto")
label(0x0389, "ECMP")
label(0x038A, "MJ")
label(0x038B, "CABTMP")
label(0x038C, "LAS2")
label(0x038D, "MSAR")
label(0x038E, "VIEW")
label(0x038F, "LASCT")
label(0x0390, "GNTMP")
label(0x0391, "HFX")
label(0x0392, "EV")
label(0x0393, "L0393")
label(0x0394, "L0394")
label(0x0395, "L0395")
label(0x0396, "NAME")
expr_label(0x039D, "NAME+7")
label(0x039E, "TP")
label(0x039F, "QQ0")
label(0x03A0, "QQ1")
label(0x03A1, "CASH")
expr_label(0x03A2, "CASH+1")
expr_label(0x03A3, "CASH+2")
expr_label(0x03A4, "CASH+3")
label(0x03A5, "QQ14")
label(0x03A6, "COK")
label(0x03A7, "GCNT")
label(0x03A8, "LASER")
expr_label(0x03A9, "LASER+1")
expr_label(0x03AA, "LASER+2")
expr_label(0x03AB, "LASER+3")
label(0x03AC, "CRGO")
label(0x03AD, "QQ20")
expr_label(0x03AE, "QQ20+1")
expr_label(0x03AF, "QQ20+2")
expr_label(0x03B0, "QQ20+3")
expr_label(0x03B1, "QQ20+4")
expr_label(0x03B2, "QQ20+5")
expr_label(0x03B3, "QQ20+6")
expr_label(0x03B4, "QQ20+7")
expr_label(0x03B5, "QQ20+8")
expr_label(0x03B6, "QQ20+9")
expr_label(0x03B7, "QQ20+10")
expr_label(0x03B8, "QQ20+11")
expr_label(0x03B9, "QQ20+12")
expr_label(0x03BA, "QQ20+13")
expr_label(0x03BB, "QQ20+14")
expr_label(0x03BC, "QQ20+15")
expr_label(0x03BD, "QQ20+16")
label(0x03BE, "ECM")
label(0x03BF, "BST")
label(0x03C0, "BOMB")
label(0x03C1, "ENGY")
label(0x03C2, "DKCMP")
label(0x03C3, "GHYP")
label(0x03C4, "ESCP")
label(0x03C5, "TRIBBLE")
expr_label(0x03C6, "TRIBBLE+1")
label(0x03C7, "TALLYL")
label(0x03C8, "NOMSL")
label(0x03C9, "FIST")
label(0x03CA, "AVL")
expr_label(0x03CB, "AVL+1")
expr_label(0x03CC, "AVL+2")
expr_label(0x03CD, "AVL+3")
expr_label(0x03CE, "AVL+4")
expr_label(0x03CF, "AVL+5")
expr_label(0x03D0, "AVL+6")
expr_label(0x03D1, "AVL+7")
expr_label(0x03D2, "AVL+8")
expr_label(0x03D3, "AVL+9")
expr_label(0x03D4, "AVL+10")
expr_label(0x03D5, "AVL+11")
expr_label(0x03D6, "AVL+12")
expr_label(0x03D7, "AVL+13")
expr_label(0x03D8, "AVL+14")
expr_label(0x03D9, "AVL+15")
expr_label(0x03DA, "AVL+16")
label(0x03DB, "QQ26")
label(0x03DC, "TALLY")
expr_label(0x03DD, "TALLY+1")
label(0x03DF, "QQ21")
label(0x03E5, "NOSTM")
label(0x03F1, "frameCounter")       # Mine, increments every VBlank
label(0x03F3, "DTW6")
label(0x03F4, "DTW2")
label(0x03F5, "DTW3")
label(0x03F6, "DTW4")
label(0x03F7, "DTW5")
label(0x03F8, "DTW1")
label(0x03F9, "DTW8")
label(0x03FA, "XP")
label(0x03FB, "YP")
label(0x0400, "LAS")
label(0x0401, "MSTG")
label(0x0403, "KL")
label(0x0403, "KY1")
label(0x0404, "KY2")
label(0x0405, "KY3")
label(0x0406, "KY4")
label(0x0407, "KY5")
label(0x0408, "KY6")
label(0x0409, "KY7")
label(0x044D, "QQ19")
expr_label(0x044E, "QQ19+1")
expr_label(0x044F, "QQ19+2")
expr_label(0x0450, "QQ19+3")
expr_label(0x0451, "QQ19+4")
expr_label(0x0452, "QQ19+5")
label(0x0459, "K2")
expr_label(0x045A, "K2+1")
expr_label(0x045B, "K2+2")
expr_label(0x045C, "K2+3")
label(0x045D, "DLY")

label(0x0469, "nmiStoreA")          # Mine, temporary storage for registers during NMI
label(0x046A, "nmiStoreX")
label(0x046B, "nmiStoreY")
label(0x046C, "pictureTile")       # Mine, the number of the first tile where system pictures are stored

label(0x046E, "boxEdge1")          # Mine, bitmap for drawing box edge?
label(0x046F, "boxEdge2")          # Mine, bitmap for drawing box edge?
label(0x0475, "scanController2")   # Mine, if non-zero, scan controller 2
label(0x0476, "JSTX")
label(0x0477, "JSTY")
label(0x047B, "LASX")
label(0x047C, "LASY")
label(0x047E, "ALTIT")
label(0x047F, "SWAP")
label(0x0481, "XSAV2")
label(0x0482, "YSAV2")
label(0x0484, "FSH")
label(0x0485, "ASH")
label(0x0486, "ENERGY")
label(0x0487, "QQ24")
label(0x0488, "QQ25")
label(0x0489, "QQ28")
label(0x048A, "QQ29")
label(0x048B, "systemFlag")         # Mine, contains a new generated value for current system
                                    # Bits 0-3 contain system image number from bank 5
                                    # Bits 6 and 7 are set in bank 5 routine
label(0x048C, "gov")
label(0x048D, "tek")
label(0x048E, "QQ2")
label(0x0494, "QQ3")
label(0x0495, "QQ4")
label(0x0496, "QQ5")
label(0x0497, "QQ6")
label(0x0499, "QQ7")
expr_label(0x049A, "QQ7+1")
label(0x049B, "QQ8")
expr_label(0x049C, "QQ8+1")
label(0x049D, "QQ9")
label(0x049E, "QQ10")
label(0x04A4, "QQ18Lo")             # Mine, gets set to address of token table
label(0x04A5, "QQ18Hi")             #   that ex then accesses
label(0x04A6, "TKN1Lo")             # Mine, gets set to address of token table
label(0x04A7, "TKN1Hi")             #   that DETOK then accesses
label(0x04A8, "language")           # Mine
label(0x04AA, "controller1Down")    # Mine
label(0x04AB, "controller2Down")    # Mine
label(0x04AC, "controller1Up")      # Mine
label(0x04AD, "controller2Up")      # Mine
label(0x04AE, "controller1Left")    # Mine
label(0x04AF, "controller2Left")    # Mine
label(0x04B0, "controller1Right")   # Mine
label(0x04B1, "controller2Right")   # Mine
label(0x04B2, "controller1A")       # Mine
label(0x04B3, "controller2A")       # Mine
label(0x04B4, "controller1B")       # Mine
label(0x04B5, "controller2B")       # Mine
label(0x04B6, "controller1Start")   # Mine
label(0x04B7, "controller2Start")   # Mine
label(0x04B8, "controller1Select")  # Mine
label(0x04B9, "controller2Select")  # Mine
label(0x04C8, "SX")
label(0x04DD, "SY")
label(0x04F2, "SZ")
expr_label(0x0506, "BUF-1")
label(0x0507, "BUF")
expr_label(0x0508, "BUF+1")
expr_label(0x050E, "BUF+7")
expr_label(0x0517, "BUF+16")
expr_label(0x0518, "BUF+17")
expr_label(0x0527, "BUF+32")
expr_label(0x0550, "BUF+73")
label(0x0561, "HANGFLAG")
label(0x0562, "MANY")
expr_label(0x0563, "MANY+1")
label(0x0564, "SSPR")
for i in range(5, 33):
    expr_label(0x0562 + i, "MANY+" + str(i))
label(0x05A5, "SXL")
label(0x05BA, "SYL")
label(0x05CF, "SZL")
label(0x05E4, "safehouse")

label(0x0600, "Kpercent")
for i in range(1, 0x200):
    expr_label(0x0600 + i, "Kpercent+" + str(i))

# NES registers

label(0x2000, "PPU_CTRL")
label(0x2001, "PPU_MASK")
label(0x2002, "PPU_STATUS")
label(0x2003, "OAM_ADDR")
label(0x2004, "OAM_DATA")
label(0x2005, "PPU_SCROLL")
label(0x2006, "PPU_ADDR")
label(0x2007, "PPU_DATA")
label(0x4014, "OAM_DMA")

# CPU registers

label(0x4000, "SQ1_VOL")        # See https://www.nesdev.org/wiki/2A03
label(0x4001, "SQ1_SWEEP")
label(0x4002, "SQ1_LO")
label(0x4003, "SQ1_HI")
label(0x4004, "SQ2_VOL")
label(0x4005, "SQ2_SWEEP")
label(0x4006, "SQ2_LO")
label(0x4007, "SQ2_HI")
label(0x4008, "TRI_LINEAR")
label(0x400A, "TRI_LO")
label(0x400B, "TRI_HI")
label(0x400C, "NOISE_VOL")
label(0x400E, "NOISE_LO")
label(0x400F, "NOISE_HI")
label(0x4010, "DMC_FREQ")
label(0x4011, "DMC_RAW")
label(0x4012, "DMC_START")
label(0x4013, "DMC_LEN")
label(0x4015, "SND_CHN")
label(0x4016, "JOY1")
label(0x4017, "JOY2")


# Battery-backed WRAM in the cartridge

label(0x6000, "pattBuffer0")         # Mine, two buffers for tile patterns
for i in range(1, 0x800):
    expr_label(0x6000 + i, "pattBuffer0+" + str(i))
label(0x6800, "pattBuffer1")
for i in range(1, 0x800):
    expr_label(0x6800 + i, "pattBuffer1+" + str(i))

label(0x7000, "nameBuffer0")         # Mine, two buffers for nametables
for i in range(1, 0x400):
    expr_label(0x7000 + i, "nameBuffer0+" + str(i))
label(0x7400, "nameBuffer1")
for i in range(1, 0x400):
    expr_label(0x7400 + i, "nameBuffer1+" + str(i))

# Permanently loaded labels in 7.asm ($C000-$FFFF)

label(0xC0DF, "LC0DF")              # Mine
label(0xC100, "log")
byte(0xC100, 0xC200 - 0xC100)
hexadecimal(0xC100, 0xC200 - 0xC100)
label(0xC200, "logL")
byte(0xC200, 0xC300 - 0xC200)
hexadecimal(0xC200, 0xC300 - 0xC200)
label(0xC300, "antilog")
byte(0xC300, 0xC400 - 0xC300)
hexadecimal(0xC300, 0xC400 - 0xC300)
label(0xC400, "antilogODD")
byte(0xC400, 0xC500 - 0xC400)
hexadecimal(0xC400, 0xC500 - 0xC400)
label(0xC500, "SNE")
byte(0xC500, 0xC520 - 0xC500)
hexadecimal(0xC500, 0xC520 - 0xC500)
label(0xC520, "ACT")
byte(0xC520, 0xC53E - 0xC520)
hexadecimal(0xC520, 0xC53E - 0xC520)

expr_label(0xC53E, "XX21-2")
expr_label(0xC53F, "XX21-1")
label(0xC540, "XX21")
expr_label(0xC541, "XX21+1")
expr_label(0xC542, "XX21+2")
expr_label(0xC543, "XX21+3")
expr_label(0xC547, "XX21+7")
expr_label(0xC580, "XX21+64")
expr_label(0xC581, "XX21+65")
label(0xCE7E, "UNIV")
expr_label(0xCE7F, "UNIV+1")
label(0xCED0, "nameBufferAddr")     # Mine, contains high byte of name buffers (&70, &74)
label(0xCED2, "pattBufferAddr")     # Mine, contains high byte of pattern buffers (&60, &68)
label(0xD9F7, "TWOS")
label(0xDA01, "TWOS2")
label(0xDA09, "TWFL")
label(0xDA10, "TWFR")
label(0xDA18, "yLookupLo")          # Mine
byte(0xDA18, 0xDAF8 - 0xDA18)
hexadecimal(0xDA18, 0xDAF8 - 0xDA18)
label(0xDAF8, "yLookupHi")          # Mine
byte(0xDAF8, 0xDBD8 - 0xDAF8)
hexadecimal(0xDAF8, 0xDBD8 - 0xDAF8)
label(0xEC3C, "noiseLookup1")       # Mine
label(0xEC5C, "noiseLookup2")       # Mine
label(0xF333, "LF333")              # Mine

subroutine(0xC007, "Spercent")
subroutine(0xC0AD, "ResetBank")     # Mine, switch bank to stack value
subroutine(0xC0AE, "SetBank")       # Mine, switch bank to A
subroutine(0xC03E, "ResetVariables")
subroutine(0xC0A8, "subm_C0A8")
subroutine(0xC582, "subm_C582")
subroutine(0xC5D2, "subm_C5D2")
subroutine(0xC630, "subm_C630")
subroutine(0xC6C0, "subm_C6C0")
subroutine(0xC6C6, "subm_C6C6")
subroutine(0xC6F4, "subm_C6F4")
subroutine(0xC836, "subm_C836")
subroutine(0xCA56, "subm_CA56")
subroutine(0xCB42, "subm_CB42")
subroutine(0xCB9C, "subm_CB9C")
subroutine(0xCC1F, "subm_CC1F")
subroutine(0xCC2E, "SendToPPU1")    # Mine, something to do with sending to PPU?
subroutine(0xCD34, "CopyNametable0To1")    # Mine, copies nametable buffer 0 to buffer 1
subroutine(0xCD62, "subm_CD62")
subroutine(0xCD6F, "DrawBoxEdges")  # Mine, draw space view box edges?
subroutine(0xCE90, "GINF")
subroutine(0xCED4, "IRQ")           # Mine, IRQ handler
subroutine(0xCED5, "NMI")           # Mine, NMI handler
subroutine(0xCE9E, "subm_CE9E")
subroutine(0xCEA5, "subm_CEA5")
subroutine(0xCF2E, "SetPalette")      # Mine, set PPU palette?
subroutine(0xD02D, "ResetNametable1")  # Mine, does this clear down nametable 1?
subroutine(0xD0F8, "ReadControllers")   # Mine, reads controllers
subroutine(0xD06D, "SetPPUTablesTo0")      # Mine, switches PPU to nametable/palette table 0
subroutine(0xD164, "KeepPPUTablesAt0x2")    # Mine, set PPU tables to 0 for the rest of the frame count plus another 
subroutine(0xD167, "KeepPPUTablesAt0")      # Mine, set PPU tables to 0 for the rest of the frame count
subroutine(0xD710, "FillMemory")    # Mine, something to do with memory filling?
subroutine(0xD8C5, "subm_D8C5")
subroutine(0xDBD8, "subm_DBD8")
subroutine(0xD8E1, "ChangeDrawingPhase")
subroutine(0xD8EC, "subm_D8EC")
subroutine(0xD908, "subm_D908")
subroutine(0xD919, "subm_D919")
subroutine(0xD933, "subm_D933")
subroutine(0xD946, "subm_D946")
subroutine(0xD951, "subm_D951")
subroutine(0xD96F, "subm_D96F")
subroutine(0xD986, "SendToPPU2")    # Mine, something to do with sending to PPU?
subroutine(0xDC0F, "LOIN")
subroutine(0xDEA5, "subm_DEA5")
subroutine(0xDF76, "subm_DF76")
subroutine(0xE04A, "subm_E04A")
subroutine(0xE0BA, "subm_E0BA")
subroutine(0xE18E, "subm_E18E")
subroutine(0xE33E, "subm_E33E")
subroutine(0xE4F0, "PIXEL")
subroutine(0xE543, "DrawDash")      # Mine, draws two pixel dash in space view
subroutine(0xE596, "ECBLB2")
subroutine(0xE59F, "MSBAR")
subroutine(0xE802, "subm_E802")
subroutine(0xE8DE, "subm_E8DE")
subroutine(0xE802, "subm_E802")
subroutine(0xE909, "subm_E909")
subroutine(0xE91D, "subm_E91D")
subroutine(0xEA8D, "subm_EA8D")
subroutine(0xEAB0, "subm_EAB0")
subroutine(0xEB0D, "subm_EB0D")
subroutine(0xEB19, "subm_EB19")
subroutine(0xEB67, "subm_EB67")
subroutine(0xEB86, "subm_EB86")
subroutine(0xEBA2, "DELAY")
subroutine(0xEBA9, "BEEP")
subroutine(0xEBAD, "EXNO3")
subroutine(0xEBBF, "ECBLB")
subroutine(0xEBE5, "BOOP")
subroutine(0xEBF2, "NOISE")
subroutine(0xEC7D, "SetupPPUForIconBar")   # Preserves A
subroutine(0xEC8D, "LDA_XX0_Y")
subroutine(0xECA0, "LDA_Epc_Y")
subroutine(0xECAE, "IncreaseTally")     # Mine, adds KWL/KWH to TALLY
subroutine(0xECE2, "CB1D4_b0")
subroutine(0xECF9, "Set_K_K3_XC_YC")    # Temporary name
subroutine(0xED16, "PlayMusic_b6")
subroutine(0xED24, "C8021_b6")
subroutine(0xED24, "C8021_b6")
subroutine(0xED50, "C89D1_b6")
subroutine(0xED6B, "ResetSound_b6")
subroutine(0xED6E, "ResetSoundNow_b6")
subroutine(0xED81, "CBF41_b5")
subroutine(0xED8F, "CB9F9_b4")
subroutine(0xED9D, "CB96B_b4")
subroutine(0xEDAB, "CB63D_b3")
subroutine(0xEDB9, "CB88C_b6")
subroutine(0xEDC7, "LL9_b1")
subroutine(0xEDDC, "CBA23_b3")
subroutine(0xEDEA, "TIDY_b1")
subroutine(0xEDFF, "TITLE_b6")
subroutine(0xEE0D, "SpawnDemoShips_b0")
subroutine(0xEE15, "STARS_b1")
subroutine(0xEE3F, "SUN_b1")
subroutine(0xEE54, "CB2FB_b3")
subroutine(0xEE62, "CB219_b3")
subroutine(0xEE78, "CB9C1_b4")
subroutine(0xEE8B, "CA082_b6")
subroutine(0xEE99, "CA0F8_b6")
subroutine(0xEEA7, "CB882_b4")
subroutine(0xEEB5, "CA4A5_b6")
subroutine(0xEEC3, "CB2EF_b0")
subroutine(0xEED3, "CB9E2_b3")
subroutine(0xEEE8, "CB673_b3")
subroutine(0xEEF6, "CB2BC_b3")
subroutine(0xEF04, "CB248_b3")
subroutine(0xEF12, "CBA17_b6")
subroutine(0xEF20, "CAFCD_b3")
subroutine(0xEF35, "CBE52_b6")
subroutine(0xEF43, "CBED2_b6")
subroutine(0xEF51, "CB0E1_b3")
subroutine(0xEF6C, "CB18E_b3")
subroutine(0xEF7A, "PAS1_b0")
subroutine(0xEF88, "SetSystemImage_b5")
subroutine(0xEF96, "GetSystemImage_b5")
subroutine(0xEFA4, "SetSystemImage2_b4")
subroutine(0xEFB2, "GetSystemImage2_b4")
subroutine(0xEFC0, "DIALS_b6")
subroutine(0xEFCE, "CBA63_b6")
subroutine(0xEFDC, "CB39D_b0")
subroutine(0xEFF7, "LL164_b6")
subroutine(0xF005, "CB919_b6")
subroutine(0xF013, "CA166_b6")
subroutine(0xF021, "CBBDE_b6")
subroutine(0xF02F, "CBB37_b6")
subroutine(0xF03D, "CB8FE_b6")
subroutine(0xF04B, "CB90D_b6")
subroutine(0xF059, "CA5AB_b6")
subroutine(0xF06F, "subm_F06F")
subroutine(0xF074, "BEEP_b7")
subroutine(0xF082, "DETOK_b2")
subroutine(0xF09D, "DTS_b2")
subroutine(0xF0B8, "PDESC_b2")
subroutine(0xF0C6, "CAE18_b3")
subroutine(0xF0E1, "CAC1D_b3")
subroutine(0xF0FC, "CA730_b3")
subroutine(0xF10A, "CA775_b3")
subroutine(0xF118, "DrawTitleScreen_b3")
subroutine(0xF126, "CA7B7_b3")
subroutine(0xF139, "CA9D1_b3")
subroutine(0xF15C, "CA972_b3")
subroutine(0xF171, "CAC5C_b3")
subroutine(0xF186, "C8980_b0")
subroutine(0xF194, "CB459_b6")
subroutine(0xF1A2, "MVS5_b0")
subroutine(0xF1BD, "HALL_b1")
subroutine(0xF1CB, "CHPR_b2")
subroutine(0xF1E6, "DASC_b2")
subroutine(0xF201, "TT27_b2")
subroutine(0xF21C, "ex_b2")
subroutine(0xF237, "TT27_b0")    # Control code part of TT27 in bank 0
subroutine(0xF245, "BR1_b0")
subroutine(0xF25A, "CBAF3_b1")
subroutine(0xF26E, "TT66_b0")
subroutine(0xF280, "CLIP_b1")
subroutine(0xF293, "ClearTiles_b3")
subroutine(0xF2A8, "SCAN_b1")
subroutine(0xF2BD, "C8926_b0")
subroutine(0xF2CE, "subm_F2CE")
subroutine(0xF2DE, "CLYNS")
subroutine(0xF338, "subm_F338")
subroutine(0xF359, "subm_F359")
subroutine(0xF362, "subm_F362")
subroutine(0xF3AB, "sub_CF3AB")
subroutine(0xF3BC, "subm_F3BC")
subroutine(0xF42A, "subm_F42A")
subroutine(0xF42E, "Ze")
subroutine(0xF454, "subm_F454")
subroutine(0xF46A, "NLIN3")
subroutine(0xF473, "NLIN4")
subroutine(0xF48D, "subm_F48D")
subroutine(0xF493, "subm_F493")
subroutine(0xF4AC, "DORND2")
subroutine(0xF4AD, "DORND")
subroutine(0xF4C1, "PROJ")
subroutine(0xF4FB, "subm_F4FB")
subroutine(0xF52D, "UnpackToRAM")
subroutine(0xF5AF, "UnpackToPPU")
subroutine(0xF5B1, "UnpackToPPU_2")
subroutine(0xF60C, "FAROF2")
subroutine(0xF65A, "MU5")
subroutine(0xF664, "MULT3")
subroutine(0xF6BA, "MLS2")
subroutine(0xF6C2, "MLS1")
subroutine(0xF6C4, "MULTS-2")
subroutine(0xF6C6, "MULTS")
subroutine(0xF707, "MU6")
subroutine(0xF70C, "SQUA")
subroutine(0xF70E, "SQUA2")
subroutine(0xF713, "MU1")
subroutine(0xF718, "MLU1")
subroutine(0xF71D, "MLU2")
subroutine(0xF721, "MULTU")
subroutine(0xF725, "MU11")
subroutine(0xF766, "FMLTU2")
subroutine(0xF770, "FMLTU")
subroutine(0xF7AB, "MLTU2-2")
subroutine(0xF7AD, "MLTU2")
subroutine(0xF7CE, "MUT3")
subroutine(0xF7D2, "MUT2")
subroutine(0xF7D6, "MUT1")
subroutine(0xF7DA, "MULT1")
subroutine(0xF83C, "MULT12")
subroutine(0xF853, "TAS3")
subroutine(0xF86F, "MAD")
subroutine(0xF872, "ADD")
subroutine(0xF8AE, "TIS1")
subroutine(0xF8D1, "DV42")
subroutine(0xF8D4, "DV41")
subroutine(0xF8D8, "DVID4")
subroutine(0xF962, "DVID3B2")
subroutine(0xFA16, "subm_FA16")
subroutine(0xFA33, "BUMP2")
subroutine(0xFA43, "REDU2")
subroutine(0xFA55, "LL5")
subroutine(0xFA91, "LL28")
subroutine(0xFACB, "subm_FACB")
subroutine(0xFAF8, "NORM")
subroutine(0xFB89, "SetupMMC1")