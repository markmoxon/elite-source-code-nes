# NI% = 0x26 = 38

# NOSH = 8    		\ As UNIV contains 9 addresses, 0 to NOSH
# NI% = &2A = 42    \ Same source - different to above?

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

# solaun = 9

# Variables

label(0x0000, "ZP")
label(0x0002, "RAND")
label(0x0002, "RAND_1")
label(0x0003, "RAND_2")
label(0x0004, "RAND_3")
label(0x0006, "T1")
label(0x0007, "SC")
label(0x0008, "SC_1")
label(0x0009, "XX1")
label(0x0009, "INWK")
label(0x000A, "INWK_1")
label(0x000B, "INWK_2")
label(0x000C, "INWK_3")
label(0x000D, "INWK_4")
label(0x000E, "INWK_5")
label(0x000F, "INWK_6")
label(0x0010, "INWK_7")
label(0x0011, "INWK_8")
label(0x0012, "INWK_9")
label(0x0013, "INWK_10")
label(0x0014, "INWK_11")
label(0x0015, "INWK_12")
label(0x0016, "INWK_13")
label(0x0017, "INWK_14")
label(0x0018, "INWK_15")
label(0x0019, "INWK_16")
label(0x001A, "INWK_17")
label(0x001B, "INWK_18")
label(0x001C, "INWK_19")
label(0x001D, "INWK_20")
label(0x001E, "INWK_21")
label(0x001F, "INWK_22")
label(0x0020, "INWK_23")
label(0x0021, "INWK_24")
label(0x0022, "INWK_25")
label(0x0023, "INWK_26")
label(0x0024, "INWK_27")
label(0x0025, "INWK_28")
label(0x0026, "INWK_29")
label(0x0027, "INWK_30")
label(0x0028, "INWK_31")
label(0x0029, "INWK_32")
label(0x002A, "INWK_33")    # No heap, reused
label(0x002B, "INWK_34")    # No heap, reused
label(0x002C, "INWK_35")    # Used? NI% is one bigger than in Master
label(0x002D, "NEWB")
label(0x002F, "P")
label(0x0030, "P_1")
label(0x0031, "P_2")
label(0x0032, "XC")
label(0x003B, "YC")
label(0x003C, "QQ17")
label(0x003D, "K3")
label(0x003D, "XX2")
label(0x003E, "XX2_1")
label(0x003F, "XX2_2")
label(0x0040, "XX2_3")
label(0x0041, "XX2_4")
label(0x0042, "XX2_5")
label(0x0043, "XX2_6")
label(0x0044, "XX2_7")
label(0x0045, "XX2_8")
label(0x0046, "XX2_9")
label(0x0047, "XX2_10")
label(0x0048, "XX2_11")
label(0x0049, "XX2_12")
label(0x004A, "XX2_13")
label(0x004B, "K4")
label(0x004C, "K4_1")
label(0x004D, "XX16")
label(0x004E, "XX16_1")
label(0x004F, "XX16_2")
label(0x0050, "XX16_3")
label(0x0051, "XX16_4")
label(0x0052, "XX16_5")
label(0x0053, "XX16_6")
label(0x0054, "XX16_7")
label(0x0055, "XX16_8")
label(0x0056, "XX16_9")
label(0x0057, "XX16_10")
label(0x0058, "XX16_11")
label(0x0059, "XX16_12")
label(0x005A, "XX16_13")
label(0x005B, "XX16_14")
label(0x005C, "XX16_15")
label(0x005D, "XX16_16")
label(0x005E, "XX16_17")
label(0x005F, "XX0")
label(0x0060, "XX0_1")
label(0x0061, "XX19")
label(0x0061, "INF")
label(0x0062, "INF_1")
label(0x0063, "V")
label(0x0064, "V_1")
label(0x0065, "XX")
label(0x0066, "XX_1")
label(0x0067, "YY")
label(0x0068, "YY_1")
label(0x0069, "BETA")
label(0x006A, "BET1")
label(0x006D, "ECMA")
label(0x006E, "ALP1")
label(0x006F, "ALP2")
label(0x0070, "ALP2_1")
label(0x0071, "XX15")
label(0x0071, "X1")
label(0x0072, "Y1")
label(0x0073, "X2")
label(0x0074, "Y2")
label(0x0075, "XX15_4")
label(0x0076, "XX15_5")
label(0x0077, "XX12")
label(0x0078, "XX12_1")
label(0x0079, "XX12_2")
label(0x007A, "XX12_3")
label(0x007B, "XX12_4")
label(0x007C, "XX12_5")
label(0x007D, "K")
label(0x007E, "K_1")
label(0x007F, "K_2")
label(0x0080, "K_3")
label(0x0082, "QQ15")
label(0x0083, "QQ15_1")
label(0x0084, "QQ15_2")
label(0x0085, "QQ15_3")
label(0x0086, "QQ15_4")
label(0x0087, "QQ15_5")
label(0x0088, "K5")
label(0x0088, "XX18")
label(0x0089, "XX18_1")
label(0x008A, "XX18_2")
label(0x008B, "XX18_3")
label(0x008C, "K6")
label(0x008D, "K6_1")
label(0x008E, "K6_2")
label(0x008F, "K6_3")	# XX18+7
label(0x0090, "K6_4")
label(0x0091, "BET2")
label(0x0092, "BET2_1")
label(0x0093, "DELTA")
label(0x0094, "DELT4")
label(0x0095, "DELT4_1")
label(0x0096, "U")
label(0x0097, "Q")
label(0x0098, "R")
label(0x0099, "S")
label(0x009A, "T")
label(0x009B, "XSAV")
label(0x009C, "YSAV")
label(0x009D, "XX17")
label(0x009E, "W")
label(0x00A0, "ZZ")
label(0x00A1, "XX13")
label(0x00A2, "MCNT")
label(0x00A3, "TYPE")
label(0x00A4, "ALPHA")
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
label(0x00B1, "Yx1M2")		# My addition = height of screen for text screens?
label(0x00B2, "Yx2M2")		# My addition = 2 x Yx1M2
label(0x00B3, "Yx2M1")
label(0x00B6, "newzp")

label(0x00F7, "BANK")        # My addition, contains lower bank number

label(0x00F9, "XX3m3")
label(0x0100, "XX3")
label(0x0101, "XX3_1")

label(0x038A, "MJ")
label(0x038E, "VIEW")
label(0x039F, "QQ0")
label(0x03A0, "QQ1")
label(0x03A1, "CASH")
label(0x03A7, "GCNT")
label(0x03AC, "CRGO")
label(0x03AD, "QQ20")
label(0x03BF, "BST")
label(0x03C3, "GHYP")
label(0x03C9, "FIST")
label(0x03CA, "AVL")
label(0x03DB, "QQ26")
label(0x03DF, "QQ21")
label(0x03E5, "NOSTM")
label(0x03F3, "DTW6")
label(0x03F4, "DTW2")
label(0x03F5, "DTW3")
label(0x03F6, "DTW4")
label(0x03F7, "DTW5")
label(0x03F8, "DTW1")
label(0x03F9, "DTW8")
label(0x044D, "QQ19")
label(0x044E, "QQ19_1")
label(0x0450, "QQ19_3")
label(0x0450, "QQ19_4")
label(0x0459, "K2")
label(0x045A, "K2_1")
label(0x045B, "K2_2")
label(0x045C, "K2_3")
label(0x045F, "QQ19_2")
label(0x047F, "SWAP")
label(0x0487, "QQ24")
label(0x0488, "QQ25")
label(0x0489, "QQ28")
label(0x048A, "QQ29")
label(0x049B, "QQ8")
label(0x049D, "QQ9")
label(0x049E, "QQ10")

label(0x04A4, "QQ18LO")     # My addition, gets set to address of token table
label(0x04A5, "QQ18HI")     # that ex then accesses
label(0x04A6, "TOKENLO")    # My addition, gets set to address of token table
label(0x04A7, "TOKENHI")    # that DETOK then accesses

label(0x04C8, "SX")
label(0x04DD, "SY")
label(0x04F2, "SZ")
label(0x0506, "BUFm1")
label(0x0507, "BUF")
label(0x0508, "BUF_1")
label(0x0561, "HANGFLAG")
label(0x0562, "MANY")
label(0x0564, "SSPR")
label(0x05A5, "SXL")
label(0x05BA, "SYL")
label(0x05CF, "SZL")
label(0x05E4, "safehouse")
label(0x0600, "Kpercent")

# NES registers

label(0x2000, "PPUCTRL")
label(0x2001, "PPUMASK")
label(0x2002, "PPUSTATUS")
label(0x2003, "OAMADDR")
label(0x2004, "OAMDATA")
label(0x2005, "PPUSCROLL")
label(0x2006, "PPUADDR")
label(0x2007, "PPUDATA")
label(0x4014, "OAMDMA")

# Permanently loaded labels in 7.asm ($C000-$FFFF)


label(0xC100, "log")
label(0xC200, "logL")
label(0xC300, "antilog")
label(0xC400, "antilogODD")
label(0xC500, "SNE")
label(0xC520, "ACT")
label(0xC53E, "XX21m2")
label(0xC53F, "XX21m1")
label(0xC540, "XX21")
label(0xCE7E, "UNIV")
label(0xCE7E, "UNIV_1")

subroutine(0xC0AD, "RESETBANK")     # My addition, switch bank to stack value
subroutine(0xC0AE, "SETBANK")       # My addition, switch bank to A
subroutine(0xCED5, "NMI")           # My addition, NMI handler
subroutine(0xD06D, "NAMETABLE0")    # My addition, switches PPU to namespace 0
subroutine(0xDC0F, "LOIN")     # Could also be LSPUT
subroutine(0xE4F0, "PIXEL")
subroutine(0xE596, "ECBLB2")
subroutine(0xEBA2, "DELAY")
subroutine(0xEBAD, "EXNO3")
subroutine(0xEBF2, "NOISE")
subroutine(0xEDEA, "TIDY")
subroutine(0xEF7A, "PAS1")
subroutine(0xF082, "DETOK")
subroutine(0xF09D, "DTS")
subroutine(0xF1A2, "MVS5")
subroutine(0xF1BD, "HALL")
subroutine(0xF1E6, "DASC")
subroutine(0xF201, "TT27")
subroutine(0xF237, "TT27_control_codes")    # My addition, it's the control code part of TT27 in bank 0
subroutine(0xF26E, "TT66")
subroutine(0xF2A8, "SCAN")
subroutine(0xF2DE, "CLYNS")
subroutine(0xF473, "NLIN4")
subroutine(0xF4AC, "DORND2")
subroutine(0xF4AD, "DORND")
subroutine(0xF4C1, "PROJ")
subroutine(0xF65A, "MU5")
subroutine(0xF664, "MULT3")
subroutine(0xF6BA, "MLS2")
subroutine(0xF6C2, "MLS1")
subroutine(0xF6C4, "MULTSm2")
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
subroutine(0xF7AB, "MLTU2m2")
subroutine(0xF7AD, "MLTU2")
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
subroutine(0xF962, "DVID3B2")
subroutine(0xFA55, "LL5")
subroutine(0xFA91, "LL28")
subroutine(0xFAF8, "NORM")