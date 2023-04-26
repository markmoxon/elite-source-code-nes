\ ******************************************************************************
\
\ NES ELITE GAME SOURCE (BANK 2)
\
\ NES Elite was written by Ian Bell and David Braben and is copyright D. Braben
\ and I. Bell 1992
\
\ The code on this site has been reconstructed from a disassembly of the version
\ released on Ian Bell's personal website at http://www.elitehomepage.org/
\
\ The commentary is copyright Mark Moxon, and any misunderstandings or mistakes
\ in the documentation are entirely my fault
\
\ The terminology and notations used in this commentary are explained at
\ https://www.bbcelite.com/about_site/terminology_used_in_this_commentary.html
\
\ The deep dive articles referred to in this commentary can be found at
\ https://www.bbcelite.com/deep_dives
\
\ ------------------------------------------------------------------------------
\
\ This source file produces the following binary file:
\
\   * bank2.bin
\
\ ******************************************************************************

 INCLUDE "1-source-files/main-sources/elite-build-options.asm"

 _NTSC                  = (_VARIANT = 1)
 _PAL                   = (_VARIANT = 2)

CODE% = &8000
LOAD% = &8000

VE = &57

; Memory locations
ZP                = &0000
RAND              = &0002
RAND_1            = &0002
RAND_2            = &0003
RAND_3            = &0004
T1                = &0006
SC                = &0007
SC_1              = &0008
INWK              = &0009
XX1               = &0009
INWK_1            = &000A
INWK_2            = &000B
INWK_3            = &000C
INWK_4            = &000D
INWK_5            = &000E
INWK_6            = &000F
INWK_7            = &0010
INWK_8            = &0011
INWK_9            = &0012
INWK_10           = &0013
INWK_11           = &0014
INWK_12           = &0015
INWK_13           = &0016
INWK_14           = &0017
INWK_15           = &0018
INWK_16           = &0019
INWK_17           = &001A
INWK_18           = &001B
INWK_19           = &001C
INWK_20           = &001D
INWK_21           = &001E
INWK_22           = &001F
INWK_23           = &0020
INWK_24           = &0021
INWK_25           = &0022
INWK_26           = &0023
INWK_27           = &0024
INWK_28           = &0025
INWK_29           = &0026
INWK_30           = &0027
INWK_31           = &0028
INWK_32           = &0029
INWK_33           = &002A
INWK_34           = &002B
INWK_35           = &002C
NEWB              = &002D
P                 = &002F
P_1               = &0030
P_2               = &0031
XC                = &0032
L0037             = &0037
YC                = &003B
QQ17              = &003C
K3                = &003D
XX2               = &003D
XX2_1             = &003E
XX2_2             = &003F
XX2_3             = &0040
XX2_4             = &0041
XX2_5             = &0042
XX2_6             = &0043
XX2_7             = &0044
XX2_8             = &0045
XX2_9             = &0046
XX2_10            = &0047
XX2_11            = &0048
XX2_12            = &0049
XX2_13            = &004A
K4                = &004B
K4_1              = &004C
XX16              = &004D
XX16_1            = &004E
XX16_2            = &004F
XX16_3            = &0050
XX16_4            = &0051
XX16_5            = &0052
XX16_6            = &0053
XX16_7            = &0054
XX16_8            = &0055
XX16_9            = &0056
XX16_10           = &0057
XX16_11           = &0058
XX16_12           = &0059
XX16_13           = &005A
XX16_14           = &005B
XX16_15           = &005C
XX16_16           = &005D
XX16_17           = &005E
XX0               = &005F
XX0_1             = &0060
INF               = &0061
XX19              = &0061
INF_1             = &0062
V                 = &0063
V_1               = &0064
XX                = &0065
XX_1              = &0066
YY                = &0067
YY_1              = &0068
BETA              = &0069
BET1              = &006A
ECMA              = &006D
ALP1              = &006E
ALP2              = &006F
ALP2_1            = &0070
X1                = &0071
XX15              = &0071
Y1                = &0072
X2                = &0073
Y2                = &0074
XX15_4            = &0075
XX15_5            = &0076
XX12              = &0077
XX12_1            = &0078
XX12_2            = &0079
XX12_3            = &007A
XX12_4            = &007B
XX12_5            = &007C
K                 = &007D
K_1               = &007E
K_2               = &007F
K_3               = &0080
QQ15              = &0082
QQ15_1            = &0083
QQ15_2            = &0084
QQ15_3            = &0085
QQ15_4            = &0086
QQ15_5            = &0087
K5                = &0088
XX18              = &0088
XX18_1            = &0089
XX18_2            = &008A
XX18_3            = &008B
K6                = &008C
K6_1              = &008D
K6_2              = &008E
K6_3              = &008F
K6_4              = &0090
BET2              = &0091
BET2_1            = &0092
DELTA             = &0093
DELT4             = &0094
DELT4_1           = &0095
U                 = &0096
Q                 = &0097
R                 = &0098
S                 = &0099
T                 = &009A
XSAV              = &009B
YSAV              = &009C
XX17              = &009D
W                 = &009E
QQ11              = &009F
ZZ                = &00A0
XX13              = &00A1
MCNT              = &00A2
TYPE              = &00A3
ALPHA             = &00A4
QQ12              = &00A5
TGT               = &00A6
FLAG              = &00A7
CNT               = &00A8
CNT2              = &00A9
STP               = &00AA
XX4               = &00AB
XX20              = &00AC
RAT               = &00AE
RAT2              = &00AF
widget            = &00B0
Yx1M2             = &00B1
Yx2M2             = &00B2
Yx2M1             = &00B3
newzp             = &00B6
L00B8             = &00B8
L00B9             = &00B9
L00BA             = &00BA
L00BB             = &00BB
L00CC             = &00CC
L00D2             = &00D2
L00D8             = &00D8
L00D9             = &00D9
L00E6             = &00E6
L00E9             = &00E9
BANK              = &00F7
XX3m3             = &00F9
XX3               = &0100
XX3_1             = &0101
FRIN              = &036A
MJ                = &038A
VIEW              = &038E
EV                = &0392
TP                = &039E
QQ0               = &039F
QQ1               = &03A0
CASH              = &03A1
QQ14              = &03A5
GCNT              = &03A7
CRGO              = &03AC
QQ20              = &03AD
BST               = &03BF
BOMB              = &03C0
GHYP              = &03C3
ESCP              = &03C6
NOMSL             = &03C8
FIST              = &03C9
AVL               = &03CA
QQ26              = &03DB
TALLY             = &03DC
TALLY_1           = &03DD
QQ21              = &03DF
NOSTM             = &03E5
DTW6              = &03F3
DTW2              = &03F4
DTW3              = &03F5
DTW4              = &03F6
DTW5              = &03F7
DTW1              = &03F8
DTW8              = &03F9
MSTG              = &0401
QQ19              = &044D
QQ19_1            = &044E
QQ19_3            = &0450
QQ19_4            = &0450
K2                = &0459
K2_1              = &045A
K2_2              = &045B
K2_3              = &045C
QQ19_2            = &045F
SWAP              = &047F
L0481             = &0481
L0482             = &0482
QQ24              = &0487
QQ25              = &0488
QQ28              = &0489
QQ29              = &048A
gov               = &048C
tek               = &048D
QQ2               = &048E
QQ3               = &0494
QQ4               = &0495
QQ5               = &0496
QQ8               = &049B
QQ8_1             = &049C
QQ9               = &049D
QQ10              = &049E
L049F             = &049F
QQ18LO            = &04A4
QQ18HI            = &04A5
TOKENLO           = &04A6
TOKENHI           = &04A7
LANG              = &04A8
L04B2             = &04B2
L04B4             = &04B4
SX                = &04C8
SY                = &04DD
SZ                = &04F2
BUFm1             = &0506
BUF               = &0507
BUF_1             = &0508
L0524             = &0524
L0525             = &0525
HANGFLAG          = &0561
MANY              = &0562
SSPR              = &0564
SXL               = &05A5
SYL               = &05BA
SZL               = &05CF
safehouse         = &05E4
Kpercent          = &0600
L07A9             = &07A9
PPUCTRL           = &2000
PPUMASK           = &2001
PPUSTATUS         = &2002
OAMADDR           = &2003
OAMDATA           = &2004
PPUSCROLL         = &2005
PPUADDR           = &2006
PPUDATA           = &2007
OAMDMA            = &4014
L80A9             = &80A9
LB0A9             = &B0A9
LC006             = &C006
LC007             = &C007
RESETBANK         = &C0AD
SETBANK           = &C0AE
log               = &C100
logL              = &C200
antilog           = &C300
antilogODD        = &C400
SNE               = &C500
ACT               = &C520
XX21m2            = &C53E
XX21m1            = &C53F
XX21              = &C540
UNIV              = &CE7E
UNIV_1            = &CE7E
GINF              = &CE90
NMI               = &CED5
NAMETABLE0        = &D06D
LD8C5             = &D8C5
LDBD8             = &DBD8
LOIN              = &DC0F
PIXEL             = &E4F0
ECBLB2            = &E596
DELAY             = &EBA2
EXNO3             = &EBAD
BOOP              = &EBE5
NOISE             = &EBF2
LEC7D             = &EC7D
TIDY              = &EDEA
PAS1              = &EF7A
LL164             = &EFF7
DETOK             = &F082
DTS               = &F09D
LF186             = &F186
MVS5              = &F1A2
HALL              = &F1BD
DASC              = &F1E6
TT27              = &F201
TT27_control_codes = &F237
TT66              = &F26E
SCAN              = &F2A8
LF2BD             = &F2BD
CLYNS             = &F2DE
Ze                = &F42E
NLIN4             = &F473
DORND2            = &F4AC
DORND             = &F4AD
PROJ              = &F4C1
MU5               = &F65A
MULT3             = &F664
MLS2              = &F6BA
MLS1              = &F6C2
MULTSm2           = &F6C4
MULTS             = &F6C6
MU6               = &F707
SQUA              = &F70C
SQUA2             = &F70E
MU1               = &F713
MLU1              = &F718
MLU2              = &F71D
MULTU             = &F721
MU11              = &F725
FMLTU2            = &F766
FMLTU             = &F770
MLTU2m2           = &F7AB
MLTU2             = &F7AD
MUT2              = &F7D2
MUT1              = &F7D6
MULT1             = &F7DA
MULT12            = &F83C
TAS3              = &F853
MAD               = &F86F
ADD               = &F872
TIS1              = &F8AE
DV42              = &F8D1
DV41              = &F8D4
DVID3B2           = &F962
LL5               = &FA55
LL28              = &FA91
NORM              = &FAF8

 ORG &8000

 SEI
 INC &C006
 JMP &C007

 EQUS "@ 5.0"

\ ******************************************************************************
\
\       Name: EJMP
\       Type: Macro
\   Category: Text
\    Summary: Macro definition for jump tokens in the extended token table
\  Deep dive: Extended text tokens
\
\ ------------------------------------------------------------------------------
\
\ The following macro is used when building the extended token table:
\
\   EJMP n              Insert a jump to address n in the JMTB table
\
\ See the deep dive on "Printing extended text tokens" for details on how jump
\ tokens are stored in the extended token table.
\
\ Arguments:
\
\   n                   The jump number to insert into the table
\
\ ******************************************************************************

MACRO EJMP n

 EQUB n EOR VE

ENDMACRO

\ ******************************************************************************
\
\       Name: ECHR
\       Type: Macro
\   Category: Text
\    Summary: Macro definition for characters in the extended token table
\  Deep dive: Extended text tokens
\
\ ------------------------------------------------------------------------------
\
\ The following macro is used when building the extended token table:
\
\   ECHR 'x'            Insert ASCII character "x"
\
\ To include an apostrophe, use a backtick character, as in ECHR '`'.
\
\ See the deep dive on "Printing extended text tokens" for details on how
\ characters are stored in the extended token table.
\
\ Arguments:
\
\   'x'                 The character to insert into the table
\
\ ******************************************************************************

MACRO ECHR x

 IF x = '`'
  EQUB 39 EOR VE
 ELSE
  EQUB x EOR VE
 ENDIF

ENDMACRO

\ ******************************************************************************
\
\       Name: ETOK
\       Type: Macro
\   Category: Text
\    Summary: Macro definition for recursive tokens in the extended token table
\  Deep dive: Extended text tokens
\
\ ------------------------------------------------------------------------------
\
\ The following macro is used when building the extended token table:
\
\   ETOK n              Insert extended recursive token [n]
\
\ See the deep dive on "Printing extended text tokens" for details on how
\ recursive tokens are stored in the extended token table.
\
\ Arguments:
\
\   n                   The number of the recursive token to insert into the
\                       table, in the range 129 to 214
\
\ ******************************************************************************

MACRO ETOK n

 EQUB n EOR VE

ENDMACRO

\ ******************************************************************************
\
\       Name: ETWO
\       Type: Macro
\   Category: Text
\    Summary: Macro definition for two-letter tokens in the extended token table
\  Deep dive: Extended text tokens
\
\ ------------------------------------------------------------------------------
\
\ The following macro is used when building the extended token table:
\
\   ETWO 'x', 'y'       Insert two-letter token "xy"
\
\ The newline token can be entered using ETWO '-', '-'.
\
\ See the deep dive on "Printing extended text tokens" for details on how
\ two-letter tokens are stored in the extended token table.
\
\ Arguments:
\
\   'x'                 The first letter of the two-letter token to insert into
\                       the table
\
\   'y'                 The second letter of the two-letter token to insert into
\                       the table
\
\ ******************************************************************************

MACRO ETWO t, k

 IF t = '-' AND k = '-' : EQUB 215 EOR VE : ENDIF
 IF t = 'A' AND k = 'B' : EQUB 216 EOR VE : ENDIF
 IF t = 'O' AND k = 'U' : EQUB 217 EOR VE : ENDIF
 IF t = 'S' AND k = 'E' : EQUB 218 EOR VE : ENDIF
 IF t = 'I' AND k = 'T' : EQUB 219 EOR VE : ENDIF
 IF t = 'I' AND k = 'L' : EQUB 220 EOR VE : ENDIF
 IF t = 'E' AND k = 'T' : EQUB 221 EOR VE : ENDIF
 IF t = 'S' AND k = 'T' : EQUB 222 EOR VE : ENDIF
 IF t = 'O' AND k = 'N' : EQUB 223 EOR VE : ENDIF
 IF t = 'L' AND k = 'O' : EQUB 224 EOR VE : ENDIF
 IF t = 'N' AND k = 'U' : EQUB 225 EOR VE : ENDIF
 IF t = 'T' AND k = 'H' : EQUB 226 EOR VE : ENDIF
 IF t = 'N' AND k = 'O' : EQUB 227 EOR VE : ENDIF

 IF t = 'A' AND k = 'L' : EQUB 228 EOR VE : ENDIF
 IF t = 'L' AND k = 'E' : EQUB 229 EOR VE : ENDIF
 IF t = 'X' AND k = 'E' : EQUB 230 EOR VE : ENDIF
 IF t = 'G' AND k = 'E' : EQUB 231 EOR VE : ENDIF
 IF t = 'Z' AND k = 'A' : EQUB 232 EOR VE : ENDIF
 IF t = 'C' AND k = 'E' : EQUB 233 EOR VE : ENDIF
 IF t = 'B' AND k = 'I' : EQUB 234 EOR VE : ENDIF
 IF t = 'S' AND k = 'O' : EQUB 235 EOR VE : ENDIF
 IF t = 'U' AND k = 'S' : EQUB 236 EOR VE : ENDIF
 IF t = 'E' AND k = 'S' : EQUB 237 EOR VE : ENDIF
 IF t = 'A' AND k = 'R' : EQUB 238 EOR VE : ENDIF
 IF t = 'M' AND k = 'A' : EQUB 239 EOR VE : ENDIF
 IF t = 'I' AND k = 'N' : EQUB 240 EOR VE : ENDIF
 IF t = 'D' AND k = 'I' : EQUB 241 EOR VE : ENDIF
 IF t = 'R' AND k = 'E' : EQUB 242 EOR VE : ENDIF
 IF t = 'A' AND k = '?' : EQUB 243 EOR VE : ENDIF
 IF t = 'E' AND k = 'R' : EQUB 244 EOR VE : ENDIF
 IF t = 'A' AND k = 'T' : EQUB 245 EOR VE : ENDIF
 IF t = 'E' AND k = 'N' : EQUB 246 EOR VE : ENDIF
 IF t = 'B' AND k = 'E' : EQUB 247 EOR VE : ENDIF
 IF t = 'R' AND k = 'A' : EQUB 248 EOR VE : ENDIF
 IF t = 'L' AND k = 'A' : EQUB 249 EOR VE : ENDIF
 IF t = 'V' AND k = 'E' : EQUB 250 EOR VE : ENDIF
 IF t = 'T' AND k = 'I' : EQUB 251 EOR VE : ENDIF
 IF t = 'E' AND k = 'D' : EQUB 252 EOR VE : ENDIF
 IF t = 'O' AND k = 'R' : EQUB 253 EOR VE : ENDIF
 IF t = 'Q' AND k = 'U' : EQUB 254 EOR VE : ENDIF
 IF t = 'A' AND k = 'N' : EQUB 255 EOR VE : ENDIF

ENDMACRO

\ ******************************************************************************
\
\       Name: ERND
\       Type: Macro
\   Category: Text
\    Summary: Macro definition for random tokens in the extended token table
\  Deep dive: Extended text tokens
\
\ ------------------------------------------------------------------------------
\
\ The following macro is used when building the extended token table:
\
\   ERND n              Insert recursive token [n]
\
\                         * Tokens 0-123 get stored as n + 91
\
\ See the deep dive on "Printing extended text tokens" for details on how
\ random tokens are stored in the extended token table.
\
\ Arguments:
\
\   n                   The number of the random token to insert into the
\                       table, in the range 0 to 37
\
\ ******************************************************************************

MACRO ERND n

 EQUB (n + 91) EOR VE

ENDMACRO

\ ******************************************************************************
\
\       Name: TOKN
\       Type: Macro
\   Category: Text
\    Summary: Macro definition for standard tokens in the extended token table
\  Deep dive: Printing text tokens
\
\ ------------------------------------------------------------------------------
\
\ The following macro is used when building the recursive token table:
\
\   TOKN n              Insert recursive token [n]
\
\                         * Tokens 0-95 get stored as n + 160
\
\                         * Tokens 128-145 get stored as n - 114
\
\                         * Tokens 96-127 get stored as n
\
\ See the deep dive on "Printing text tokens" for details on how recursive
\ tokens are stored in the recursive token table.
\
\ Arguments:
\
\   n                   The number of the recursive token to insert into the
\                       table, in the range 0 to 145
\
\ ******************************************************************************

MACRO TOKN n

 IF n >= 0 AND n <= 95
  t = n + 160
 ELIF n >= 128
  t = n - 114
 ELSE
  t = n
 ENDIF

 EQUB t EOR VE

ENDMACRO

.TKN1

 EQUB VE                \ Token 0:      ""

 EJMP 19                \ Token 1:      ""
 ECHR 'Y'
 ETWO 'E', 'S'
 EQUB VE

 EJMP 19                \ Token 2:      ""
 ETWO 'N', 'O'
 EQUB VE

 EJMP 2                 \ Token 3:      ""
 EJMP 19
 ECHR 'I'
 ETWO 'M', 'A'
 ECHR 'G'
 ETWO 'I', 'N'
 ECHR 'E'
 ETWO 'E', 'R'
 EJMP 26
 ECHR 'P'
 ETWO 'R', 'E'
 ETWO 'S', 'E'
 ECHR 'N'
 ECHR 'T'
 ECHR 'S'
 EQUB VE

 EJMP 19                \ Token 4:      ""
 ETWO 'E', 'N'
 ECHR 'G'
 ECHR 'L'
 ECHR 'I'
 ECHR 'S'
 ECHR 'H'
 EQUB VE

 ETOK 176               \ Token 5:      ""
 ERND 18
 ETOK 202
 ERND 19
 ETOK 177
 EQUB VE

 EJMP 19                \ Token 6:      ""
 ECHR 'L'
 ECHR 'I'
 ETWO 'C', 'E'
 ECHR 'N'
 ETWO 'S', 'E'
 ECHR 'D'
 EJMP 13
 ECHR ' '
 ECHR 'T'
 ECHR 'O'
 EQUB VE

 EJMP 19                \ Token 7:      ""
 ECHR 'L'
 ECHR 'I'
 ETWO 'C', 'E'
 ECHR 'N'
 ETWO 'S', 'E'
 ECHR 'D'
 ECHR ' '
 ECHR 'B'
 ECHR 'Y'
 EJMP 26
 ECHR 'N'
 ETWO 'I', 'N'
 ECHR 'T'
 ETWO 'E', 'N'
 ECHR 'D'
 ECHR 'O'
 EQUB VE

 EJMP 19                \ Token 8:      ""
 ECHR 'N'
 ECHR 'E'
 ECHR 'W'
 EJMP 26
 ECHR 'N'
 ECHR 'A'
 ECHR 'M'
 ECHR 'E'
 ECHR ':'
 ECHR ' '
 EQUB VE

 EJMP 19                \ Token 9:      ""
 ECHR 'I'
 ETWO 'M', 'A'
 ECHR 'G'
 ETWO 'I', 'N'
 ECHR 'E'
 ETWO 'E', 'R'
 EJMP 26
 ECHR 'C'
 ECHR 'O'
 ECHR '.'
 EJMP 26
 ECHR 'L'
 ECHR 'T'
 ECHR 'D'
 ECHR '.'
 ECHR ','
 EJMP 26
 ECHR 'J'
 ECHR 'A'
 ECHR 'P'
 ETWO 'A', 'N'
 EQUB VE

 EJMP 23                \ Token 10:     ""
 EJMP 14
 EJMP 13
 EJMP 19
 ECHR 'G'
 ETWO 'R', 'E'
 ETWO 'E', 'T'
 ETWO 'I', 'N'
 ECHR 'G'
 ECHR 'S'
 ETOK 213
 ECHR ' '
 ETWO 'A', 'N'
 ECHR 'D'
 EJMP 26
 ECHR 'I'
 ECHR ' '
 ETWO 'B', 'E'
 ECHR 'G'
 ETOK 208
 ECHR 'M'
 ECHR 'O'
 ECHR 'M'
 ETWO 'E', 'N'
 ECHR 'T'
 ECHR ' '
 ECHR 'O'
 ECHR 'F'
 ECHR ' '
 ETOK 179
 ECHR 'R'
 ECHR ' '
 ECHR 'V'
 ETWO 'A', 'L'
 ECHR 'U'
 ETWO 'A', 'B'
 ETWO 'L', 'E'
 ECHR ' '
 ETWO 'T', 'I'
 ECHR 'M'
 ECHR 'E'
 ETOK 204
 ECHR 'W'
 ECHR 'E'
 ECHR ' '
 ECHR 'W'
 ETWO 'O', 'U'
 ECHR 'L'
 ECHR 'D'
 ECHR ' '
 ECHR 'L'
 ECHR 'I'
 ECHR 'K'
 ECHR 'E'
 ECHR ' '
 ETOK 179
 ETOK 201
 ECHR 'D'
 ECHR 'O'
 ETOK 208
 ECHR 'L'
 ETWO 'I', 'T'
 ECHR 'T'
 ETWO 'L', 'E'
 ECHR ' '
 ECHR 'J'
 ECHR 'O'
 ECHR 'B'
 ECHR ' '
 ECHR 'F'
 ETWO 'O', 'R'
 ECHR ' '
 ETWO 'U', 'S'
 ETOK 204
 ETOK 147
 ETOK 207
 ECHR ' '
 ETOK 179
 ECHR ' '
 ETWO 'S', 'E'
 ECHR 'E'
 ECHR ' '
 ECHR 'H'
 ECHR 'E'
 ETWO 'R', 'E'
 ETOK 202
 ECHR 'A'
 ETOK 210
 ECHR 'M'
 ECHR 'O'
 ECHR 'D'
 ECHR 'E'
 ECHR 'L'
 ECHR ','
 ECHR ' '
 ETWO 'T', 'H'
 ECHR 'E'
 EJMP 26
 ECHR 'C'
 ETWO 'O', 'N'
 ETWO 'S', 'T'
 ECHR 'R'
 ECHR 'I'
 ECHR 'C'
 ECHR 'T'
 ETWO 'O', 'R'
 ECHR ','
 ECHR ' '
 ECHR 'E'
 ETWO 'Q', 'U'
 ECHR 'I'
 ECHR 'P'
 ECHR 'P'
 ETOK 196
 ECHR 'W'
 ETWO 'I', 'T'
 ECHR 'H'
 ETOK 208
 ECHR 'T'
 ECHR 'O'
 ECHR 'P'
 ECHR ' '
 ETWO 'S', 'E'
 ECHR 'C'
 ECHR 'R'
 ETWO 'E', 'T'
 ETOK 210
 ECHR 'S'
 ECHR 'H'
 ECHR 'I'
 ECHR 'E'
 ECHR 'L'
 ECHR 'D'
 ECHR ' '
 ETWO 'G', 'E'
 ECHR 'N'
 ETWO 'E', 'R'
 ETWO 'A', 'T'
 ETWO 'O', 'R'
 ETOK 204
 ECHR 'U'
 ECHR 'N'
 ECHR 'F'
 ETWO 'O', 'R'
 ECHR 'T'
 ECHR 'U'
 ECHR 'N'
 ETWO 'A', 'T'
 ECHR 'E'
 ECHR 'L'
 ECHR 'Y'
 ECHR ' '
 ETWO 'I', 'T'
 ECHR '`'
 ECHR 'S'
 ECHR ' '
 ETWO 'B', 'E'
 ETWO 'E', 'N'
 ECHR ' '
 ETWO 'S', 'T'
 ECHR 'O'
 ETWO 'L', 'E'
 ECHR 'N'
 ETOK 204
 EJMP 22
 EJMP 19
 ETWO 'I', 'T'
 ECHR ' '
 ECHR 'W'
 ETWO 'E', 'N'
 ECHR 'T'
 ECHR ' '
 ECHR 'M'
 ECHR 'I'
 ECHR 'S'
 ECHR 'S'
 ETOK 195
 ECHR 'F'
 ECHR 'R'
 ECHR 'O'
 ECHR 'M'
 ECHR ' '
 ETWO 'O', 'U'
 ECHR 'R'
 ECHR ' '
 ETOK 207
 ECHR ' '
 ECHR 'Y'
 ETWO 'A', 'R'
 ECHR 'D'
 ECHR ' '
 ETWO 'O', 'N'
 EJMP 26
 ETWO 'X', 'E'
 ETWO 'E', 'R'
 ECHR ' '
 ECHR 'F'
 ECHR 'I'
 ETWO 'V', 'E'
 ECHR ' '
 ECHR 'M'
 ETWO 'O', 'N'
 ETWO 'T', 'H'
 ECHR 'S'
 ECHR ' '
 ECHR 'A'
 ECHR 'G'
 ECHR 'O'
 ETOK 178
 EJMP 28
 ETOK 204
 ETOK 179
 ECHR 'R'
 ECHR ' '
 ECHR 'M'
 ECHR 'I'
 ECHR 'S'
 ECHR 'S'
 ECHR 'I'
 ETWO 'O', 'N'
 ECHR ','
 ECHR ' '
 ECHR 'S'
 ECHR 'H'
 ETWO 'O', 'U'
 ECHR 'L'
 ECHR 'D'
 ECHR ' '
 ETOK 179
 ECHR ' '
 ECHR 'D'
 ECHR 'E'
 ECHR 'C'
 ECHR 'I'
 ECHR 'D'
 ECHR 'E'
 ETOK 201
 ECHR 'A'
 ECHR 'C'
 ETWO 'C', 'E'
 ECHR 'P'
 ECHR 'T'
 ECHR ' '
 ETWO 'I', 'T'
 ECHR ','
 ECHR ' '
 ECHR 'I'
 ECHR 'S'
 ETOK 201
 ETWO 'S', 'E'
 ECHR 'E'
 ECHR 'K'
 ETOK 178
 ECHR 'D'
 ECHR 'E'
 ETWO 'S', 'T'
 ECHR 'R'
 ECHR 'O'
 ECHR 'Y'
 ECHR ' '
 ETOK 148
 ETOK 207
 ETOK 204
 ETOK 179
 ECHR ' '
 ETWO 'A', 'R'
 ECHR 'E'
 ECHR ' '
 ECHR 'C'
 ECHR 'A'
 ECHR 'U'
 ETWO 'T', 'I'
 ETWO 'O', 'N'
 ETOK 196
 ETWO 'T', 'H'
 ETWO 'A', 'T'
 ECHR ' '
 ETWO 'O', 'N'
 ECHR 'L'
 ECHR 'Y'
 ECHR ' '
 EJMP 6
 ERND 26
 EJMP 5
 ECHR 'S'
 ECHR ' '
 ECHR 'W'
 ETWO 'I', 'L'
 ECHR 'L'
 ECHR ' '
 ECHR 'G'
 ETWO 'E', 'T'
 ECHR ' '
 ETWO 'T', 'H'
 ECHR 'R'
 ETWO 'O', 'U'
 ECHR 'G'
 ECHR 'H'
 ECHR ' '
 ETOK 147
 ECHR 'N'
 ECHR 'E'
 ECHR 'W'
 ECHR ' '
 ECHR 'S'
 ECHR 'H'
 ECHR 'I'
 ECHR 'E'
 ECHR 'L'
 ECHR 'D'
 ECHR 'S'
 ETOK 178
 ETWO 'T', 'H'
 ETWO 'A', 'T'
 ECHR ' '
 ETWO 'T', 'H'
 ECHR 'E'
 EJMP 26
 ECHR 'C'
 ETWO 'O', 'N'
 ETWO 'S', 'T'
 ECHR 'R'
 ECHR 'I'
 ECHR 'C'
 ECHR 'T'
 ETWO 'O', 'R'
 ETOK 202
 ECHR 'F'
 ETWO 'I', 'T'
 ECHR 'T'
 ETOK 196
 ECHR 'W'
 ETWO 'I', 'T'
 ECHR 'H'
 ECHR ' '
 ETWO 'A', 'N'
 ECHR ' '
 EJMP 6
 ERND 17
 EJMP 5
 ETOK 177
 EJMP 8
 EJMP 19
 ECHR 'G'
 ECHR 'O'
 ECHR 'O'
 ECHR 'D'
 EJMP 26
 ECHR 'L'
 ECHR 'U'
 ECHR 'C'
 ECHR 'K'
 ECHR ','
 ECHR ' '
 ETOK 154
 ETOK 212
 EJMP 22
 EQUB VE

 EJMP 25                \ Token 11:     ""
 EJMP 9
 EJMP 23
 EJMP 14
 ECHR ' '
 EJMP 26
 ETWO 'A', 'T'
 ECHR 'T'
 ETWO 'E', 'N'
 ETWO 'T', 'I'
 ETWO 'O', 'N'
 ETOK 213
 ECHR '.'
 EJMP 26
 ECHR 'W'
 ECHR 'E'
 ECHR ' '
 ECHR 'H'
 ECHR 'A'
 ETWO 'V', 'E'
 ECHR ' '
 ECHR 'N'
 ECHR 'E'
 ETOK 196
 ECHR 'O'
 ECHR 'F'
 ECHR ' '
 ETOK 179
 ECHR 'R'
 ECHR ' '
 ETWO 'S', 'E'
 ECHR 'R'
 ECHR 'V'
 ECHR 'I'
 ETWO 'C', 'E'
 ECHR 'S'
 ECHR ' '
 ECHR 'A'
 ECHR 'G'
 ECHR 'A'
 ETWO 'I', 'N'
 ETOK 204
 ECHR 'I'
 ECHR 'F'
 ECHR ' '
 ETOK 179
 ECHR ' '
 ECHR 'W'
 ETWO 'O', 'U'
 ECHR 'L'
 ECHR 'D'
 ECHR ' '
 ETWO 'B', 'E'
 ECHR ' '
 ETWO 'S', 'O'
 ECHR ' '
 ECHR 'G'
 ECHR 'O'
 ECHR 'O'
 ECHR 'D'
 ECHR ' '
 ECHR 'A'
 ECHR 'S'
 ETOK 201
 ECHR 'G'
 ECHR 'O'
 ECHR ' '
 ECHR 'T'
 ECHR 'O'
 EJMP 26
 ETWO 'C', 'E'
 ETWO 'E', 'R'
 ETWO 'D', 'I'
 ECHR ' '
 ETOK 179
 ECHR ' '
 ECHR 'W'
 ETWO 'I', 'L'
 ECHR 'L'
 ECHR ' '
 ETWO 'B', 'E'
 ECHR ' '
 ECHR 'B'
 ECHR 'R'
 ECHR 'I'
 ECHR 'E'
 ECHR 'F'
 ETWO 'E', 'D'
 ETOK 204
 ECHR 'I'
 ECHR 'F'
 ECHR ' '
 ECHR 'S'
 ECHR 'U'
 ECHR 'C'
 ETWO 'C', 'E'
 ECHR 'S'
 ECHR 'S'
 ECHR 'F'
 ECHR 'U'
 ECHR 'L'
 ECHR ','
 ECHR ' '
 ETOK 179
 ECHR ' '
 ECHR 'W'
 ETWO 'I', 'L'
 ECHR 'L'
 ECHR ' '
 ETWO 'B', 'E'
 ECHR ' '
 ECHR 'W'
 ECHR 'E'
 ECHR 'L'
 ECHR 'L'
 ECHR ' '
 ETWO 'R', 'E'
 ECHR 'W'
 ETWO 'A', 'R'
 ECHR 'D'
 ETWO 'E', 'D'
 ETOK 212
 EJMP 24
 EQUB VE

 ECHR '('               \ Token 12:     ""
 EJMP 19
 ECHR 'C'
 ECHR ')'
 ETOK 197
 ECHR ' '
 ECHR '1'
 ECHR '9'
 ECHR '9'
 ECHR '1'
 EQUB VE

 ECHR 'B'               \ Token 13:     ""
 ECHR 'Y'
 ETOK 197
 EQUB VE

 EJMP 21                \ Token 14:     ""
 ETOK 145
 ETOK 200
 EQUB VE

 EJMP 25                \ Token 15:     ""
 EJMP 9
 EJMP 23
 EJMP 14
 EJMP 13
 ECHR ' '
 EJMP 26
 ECHR 'C'
 ETWO 'O', 'N'
 ECHR 'G'
 ECHR 'R'
 ETWO 'A', 'T'
 ECHR 'U'
 ECHR 'L'
 ETWO 'A', 'T'
 ECHR 'I'
 ETWO 'O', 'N'
 ECHR 'S'
 ECHR ' '
 ETOK 154
 ECHR '!'
 EJMP 12
 EJMP 12
 EJMP 19
 ETWO 'T', 'H'
 ECHR 'E'
 ETWO 'R', 'E'
 ECHR ' '
 ECHR 'W'
 ETWO 'I', 'L'
 ECHR 'L'
 ECHR ' '
 ETWO 'A', 'L'
 ECHR 'W'
 ECHR 'A'
 ECHR 'Y'
 ECHR 'S'
 ECHR ' '
 ETWO 'B', 'E'
 ETOK 208
 ECHR 'P'
 ETWO 'L', 'A'
 ETWO 'C', 'E'
 ECHR ' '
 ECHR 'F'
 ETWO 'O', 'R'
 ECHR ' '
 ETOK 179
 ECHR ' '
 ETWO 'I', 'N'
 ETOK 211
 ETOK 204
 ETWO 'A', 'N'
 ECHR 'D'
 ECHR ' '
 ETWO 'M', 'A'
 ECHR 'Y'
 ETWO 'B', 'E'
 ECHR ' '
 ETWO 'S', 'O'
 ETWO 'O', 'N'
 ETWO 'E', 'R'
 ECHR ' '
 ETWO 'T', 'H'
 ETWO 'A', 'N'
 ECHR ' '
 ETOK 179
 ECHR ' '
 ETWO 'T', 'H'
 ETWO 'I', 'N'
 ECHR 'K'
 ECHR '.'
 ECHR '.'
 ETOK 212
 EJMP 24
 EQUB VE

 ECHR 'F'               \ Token 16:     ""
 ETWO 'A', 'B'
 ETWO 'L', 'E'
 ECHR 'D'
 EQUB VE

 ETWO 'N', 'O'          \ Token 17:     ""
 ECHR 'T'
 ETWO 'A', 'B'
 ETWO 'L', 'E'
 EQUB VE

 ECHR 'W'               \ Token 18:     ""
 ECHR 'E'
 ECHR 'L'
 ECHR 'L'
 ECHR ' '
 ECHR 'K'
 ETWO 'N', 'O'
 ECHR 'W'
 ECHR 'N'
 EQUB VE

 ECHR 'F'               \ Token 19:     ""
 ECHR 'A'
 ECHR 'M'
 ETWO 'O', 'U'
 ECHR 'S'
 EQUB VE

 ETWO 'N', 'O'          \ Token 20:     ""
 ECHR 'T'
 ETWO 'E', 'D'
 EQUB VE

 ECHR 'V'               \ Token 21:     ""
 ETWO 'E', 'R'
 ECHR 'Y'
 EQUB VE

 ECHR 'M'               \ Token 22:     ""
 ETWO 'I', 'L'
 ECHR 'D'
 ECHR 'L'
 ECHR 'Y'
 EQUB VE

 ECHR 'M'               \ Token 23:     ""
 ECHR 'O'
 ETWO 'S', 'T'
 EQUB VE

 ETWO 'R', 'E'          \ Token 24:     ""
 ECHR 'A'
 ECHR 'S'
 ETWO 'O', 'N'
 ETWO 'A', 'B'
 ECHR 'L'
 ECHR 'Y'
 EQUB VE

 EQUB VE                \ Token 25:     ""

 ETOK 165               \ Token 26:     ""
 EQUB VE

 ERND 23                \ Token 27:     ""
 EQUB VE

 ECHR 'G'               \ Token 28:     ""
 ETWO 'R', 'E'
 ETWO 'A', 'T'
 EQUB VE

 ECHR 'V'               \ Token 29:     ""
 ECHR 'A'
 ETWO 'S', 'T'
 EQUB VE

 ECHR 'P'               \ Token 30:     ""
 ETWO 'I', 'N'
 ECHR 'K'
 EQUB VE

 EJMP 2                 \ Token 31:     ""
 ERND 28
 ECHR ' '
 ERND 27
 EJMP 13
 ECHR ' '
 ETOK 185
 ETWO 'A', 'T'
 ECHR 'I'
 ETWO 'O', 'N'
 ECHR 'S'
 EQUB VE

 ETOK 156               \ Token 32:     ""
 ECHR 'S'
 EQUB VE

 ERND 26                \ Token 33:     ""
 EQUB VE

 ERND 37                \ Token 34:     ""
 ECHR ' '
 ECHR 'F'
 ECHR 'O'
 ETWO 'R', 'E'
 ETWO 'S', 'T'
 ECHR 'S'
 EQUB VE

 ECHR 'O'               \ Token 35:     ""
 ETWO 'C', 'E'
 ETWO 'A', 'N'
 ECHR 'S'
 EQUB VE

 ECHR 'S'               \ Token 36:     ""
 ECHR 'H'
 ECHR 'Y'
 ECHR 'N'
 ETWO 'E', 'S'
 ECHR 'S'
 EQUB VE

 ECHR 'S'               \ Token 37:     ""
 ETWO 'I', 'L'
 ECHR 'L'
 ETWO 'I', 'N'
 ETWO 'E', 'S'
 ECHR 'S'
 EQUB VE

 ECHR 'T'               \ Token 38:     ""
 ECHR 'E'
 ECHR 'A'
 ECHR ' '
 ETWO 'C', 'E'
 ETWO 'R', 'E'
 ECHR 'M'
 ETWO 'O', 'N'
 ECHR 'I'
 ETWO 'E', 'S'
 EQUB VE

 ETWO 'L', 'O'          \ Token 39:     ""
 ECHR 'A'
 ETWO 'T', 'H'
 ETOK 195
 ECHR 'O'
 ECHR 'F'
 ECHR ' '
 ERND 9
 EQUB VE

 ETWO 'L', 'O'          \ Token 40:     ""
 ETWO 'V', 'E'
 ECHR ' '
 ECHR 'F'
 ETWO 'O', 'R'
 ECHR ' '
 ERND 9
 EQUB VE

 ECHR 'F'               \ Token 41:     ""
 ECHR 'O'
 ECHR 'O'
 ECHR 'D'
 ECHR ' '
 ECHR 'B'
 ETWO 'L', 'E'
 ECHR 'N'
 ECHR 'D'
 ETWO 'E', 'R'
 ECHR 'S'
 EQUB VE

 ECHR 'T'               \ Token 42:     ""
 ETWO 'O', 'U'
 ECHR 'R'
 ECHR 'I'
 ETWO 'S', 'T'
 ECHR 'S'
 EQUB VE

 ECHR 'P'               \ Token 43:     ""
 ECHR 'O'
 ETWO 'E', 'T'
 ECHR 'R'
 ECHR 'Y'
 EQUB VE

 ETWO 'D', 'I'          \ Token 44:     ""
 ECHR 'S'
 ECHR 'C'
 ECHR 'O'
 ECHR 'S'
 EQUB VE

 ERND 17                \ Token 45:     ""
 EQUB VE

 ECHR 'W'               \ Token 46:     ""
 ETWO 'A', 'L'
 ECHR 'K'
 ETOK 195
 ETOK 158
 EQUB VE

 ECHR 'C'               \ Token 47:     ""
 ECHR 'R'
 ETWO 'A', 'B'
 EQUB VE

 ECHR 'B'               \ Token 48:     ""
 ETWO 'A', 'T'
 EQUB VE

 ETWO 'L', 'O'          \ Token 49:     ""
 ECHR 'B'
 ETWO 'S', 'T'
 EQUB VE

 EJMP 18                \ Token 50:     ""
 EQUB VE

 ETWO 'B', 'E'          \ Token 51:     ""
 ETWO 'S', 'E'
 ECHR 'T'
 EQUB VE

 ECHR 'P'               \ Token 52:     ""
 ETWO 'L', 'A'
 ECHR 'G'
 ECHR 'U'
 ETWO 'E', 'D'
 EQUB VE

 ETWO 'R', 'A'          \ Token 53:     ""
 ECHR 'V'
 ECHR 'A'
 ETWO 'G', 'E'
 ECHR 'D'
 EQUB VE

 ECHR 'C'               \ Token 54:     ""
 ECHR 'U'
 ECHR 'R'
 ETWO 'S', 'E'
 ECHR 'D'
 EQUB VE

 ECHR 'S'               \ Token 55:     ""
 ECHR 'C'
 ETWO 'O', 'U'
 ECHR 'R'
 ETWO 'G', 'E'
 ECHR 'D'
 EQUB VE

 ERND 22                \ Token 56:     ""
 ECHR ' '
 ECHR 'C'
 ECHR 'I'
 ECHR 'V'
 ETWO 'I', 'L'
 ECHR ' '
 ECHR 'W'
 ETWO 'A', 'R'
 EQUB VE

 ERND 13                \ Token 57:     ""
 ECHR ' '
 ERND 4
 ECHR ' '
 ERND 5
 ECHR 'S'
 EQUB VE

 ECHR 'A'               \ Token 58:     ""
 ECHR ' '
 ERND 13
 ECHR ' '
 ETWO 'D', 'I'
 ETWO 'S', 'E'
 ECHR 'A'
 ETWO 'S', 'E'
 EQUB VE

 ERND 22                \ Token 59:     ""
 ECHR ' '
 ECHR 'E'
 ETWO 'A', 'R'
 ETWO 'T', 'H'
 ETWO 'Q', 'U'
 ECHR 'A'
 ECHR 'K'
 ETWO 'E', 'S'
 EQUB VE

 ERND 22                \ Token 60:     ""
 ECHR ' '
 ETWO 'S', 'O'
 ECHR 'L'
 ETWO 'A', 'R'
 ECHR ' '
 ECHR 'A'
 ECHR 'C'
 ETWO 'T', 'I'
 ECHR 'V'
 ETWO 'I', 'T'
 ECHR 'Y'
 EQUB VE

 ETOK 175               \ Token 61:     ""
 ERND 2
 ECHR ' '
 ERND 3
 EQUB VE

 ETOK 147               \ Token 62:     ""
 EJMP 17
 ECHR ' '
 ERND 4
 ECHR ' '
 ERND 5
 EQUB VE

 ETOK 175               \ Token 63:     ""
 ETOK 193
 ECHR 'S'
 ECHR ' '
 ERND 7
 ECHR ' '
 ERND 8
 EQUB VE

 EJMP 2                 \ Token 64:     ""
 ERND 31
 EJMP 13
 EQUB VE

 ETOK 175               \ Token 65:     ""
 ERND 16
 ECHR ' '
 ERND 17
 EQUB VE

 ECHR 'J'               \ Token 66:     ""
 ECHR 'U'
 ECHR 'I'
 ETWO 'C', 'E'
 EQUB VE

 ECHR 'D'               \ Token 67:     ""
 ECHR 'R'
 ETWO 'I', 'N'
 ECHR 'K'
 EQUB VE

 ECHR 'W'               \ Token 68:     ""
 ETWO 'A', 'T'
 ETWO 'E', 'R'
 EQUB VE

 ECHR 'T'               \ Token 69:     ""
 ECHR 'E'
 ECHR 'A'
 EQUB VE

 EJMP 19                \ Token 70:     ""
 ECHR 'G'
 ETWO 'A', 'R'
 ECHR 'G'
 ETWO 'L', 'E'
 EJMP 26
 ECHR 'B'
 ETWO 'L', 'A'
 ETWO 'S', 'T'
 ETWO 'E', 'R'
 ECHR 'S'
 EQUB VE

 EJMP 18                \ Token 71:     ""
 EQUB VE

 EJMP 17                \ Token 72:     ""
 ECHR ' '
 ERND 5
 EQUB VE

 ETOK 191               \ Token 73:     ""
 EQUB VE

 ETOK 192               \ Token 74:     ""
 EQUB VE

 ERND 13                \ Token 75:     ""
 ECHR ' '
 EJMP 18
 EQUB VE

 ECHR 'F'               \ Token 76:     ""
 ETWO 'A', 'B'
 ECHR 'U'
 ECHR 'L'
 ETWO 'O', 'U'
 ECHR 'S'
 EQUB VE

 ECHR 'E'               \ Token 77:     ""
 ECHR 'X'
 ECHR 'O'
 ETWO 'T', 'I'
 ECHR 'C'
 EQUB VE

 ECHR 'H'               \ Token 78:     ""
 ECHR 'O'
 ECHR 'O'
 ECHR 'P'
 ECHR 'Y'
 EQUB VE

 ETOK 132               \ Token 79:     ""
 EQUB VE

 ECHR 'E'               \ Token 80:     ""
 ECHR 'X'
 ECHR 'C'
 ETWO 'I', 'T'
 ETWO 'I', 'N'
 ECHR 'G'
 EQUB VE

 ECHR 'C'               \ Token 81:     ""
 ECHR 'U'
 ECHR 'I'
 ECHR 'S'
 ETWO 'I', 'N'
 ECHR 'E'
 EQUB VE

 ECHR 'N'               \ Token 82:     ""
 ECHR 'I'
 ECHR 'G'
 ECHR 'H'
 ECHR 'T'
 ECHR ' '
 ECHR 'L'
 ECHR 'I'
 ECHR 'F'
 ECHR 'E'
 EQUB VE

 ECHR 'C'               \ Token 83:     ""
 ECHR 'A'
 ECHR 'S'
 ECHR 'I'
 ETWO 'N', 'O'
 ECHR 'S'
 EQUB VE

 ECHR 'C'               \ Token 84:     ""
 ETWO 'I', 'N'
 ECHR 'E'
 ETWO 'M', 'A'
 ECHR 'S'
 EQUB VE

 EJMP 2                 \ Token 85:     ""
 ERND 31
 EJMP 13
 EQUB VE

 EJMP 3                 \ Token 86:     ""
 EQUB VE

 ETOK 147               \ Token 87:     ""
 ETOK 145
 ECHR ' '
 EJMP 3
 EQUB VE

 ETOK 147               \ Token 88:     ""
 ETOK 146
 ECHR ' '
 EJMP 3
 EQUB VE

 ETOK 148               \ Token 89:     ""
 ETOK 145
 EQUB VE

 ETOK 148               \ Token 90:     ""
 ETOK 146
 EQUB VE

 ECHR 'S'               \ Token 91:     ""
 ECHR 'W'
 ETWO 'I', 'N'
 ECHR 'E'
 EQUB VE

 ECHR 'S'               \ Token 92:     ""
 ECHR 'C'
 ETWO 'O', 'U'
 ECHR 'N'
 ECHR 'D'
 ETWO 'R', 'E'
 ECHR 'L'
 EQUB VE

 ECHR 'B'               \ Token 93:     ""
 ETWO 'L', 'A'
 ECHR 'C'
 ECHR 'K'
 ECHR 'G'
 ECHR 'U'
 ETWO 'A', 'R'
 ECHR 'D'
 EQUB VE

 ECHR 'R'               \ Token 94:     ""
 ECHR 'O'
 ECHR 'G'
 ECHR 'U'
 ECHR 'E'
 EQUB VE

 ECHR 'W'               \ Token 95:     ""
 ECHR 'R'
 ETWO 'E', 'T'
 ECHR 'C'
 ECHR 'H'
 EQUB VE

 ECHR 'N'               \ Token 96:     ""
 ECHR ' '
 ECHR 'U'
 ECHR 'N'
 ETWO 'R', 'E'
 ECHR 'M'
 ETWO 'A', 'R'
 ECHR 'K'
 ETWO 'A', 'B'
 ETWO 'L', 'E'
 EQUB VE

 ECHR ' '               \ Token 97:     ""
 ECHR 'B'
 ETWO 'O', 'R'
 ETWO 'I', 'N'
 ECHR 'G'
 EQUB VE

 ECHR ' '               \ Token 98:     ""
 ECHR 'D'
 ECHR 'U'
 ECHR 'L'
 ECHR 'L'
 EQUB VE

 ECHR ' '               \ Token 99:     ""
 ECHR 'T'
 ECHR 'E'
 ETWO 'D', 'I'
 ETWO 'O', 'U'
 ECHR 'S'
 EQUB VE

 ECHR ' '               \ Token 100:    ""
 ETWO 'R', 'E'
 ECHR 'V'
 ECHR 'O'
 ECHR 'L'
 ECHR 'T'
 ETWO 'I', 'N'
 ECHR 'G'
 EQUB VE

 ETOK 145               \ Token 101:    ""
 EQUB VE

 ETOK 146               \ Token 102:    ""
 EQUB VE

 ECHR 'P'               \ Token 103:    ""
 ETWO 'L', 'A'
 ETWO 'C', 'E'
 EQUB VE

 ECHR 'L'               \ Token 104:    ""
 ETWO 'I', 'T'
 ECHR 'T'
 ETWO 'L', 'E'
 ECHR ' '
 ETOK 145
 EQUB VE

 ECHR 'D'               \ Token 105:    ""
 ECHR 'U'
 ECHR 'M'
 ECHR 'P'
 EQUB VE

 EJMP 19                \ Token 106:    ""
 ECHR 'I'
 ECHR ' '
 ECHR 'H'
 ECHR 'E'
 ETWO 'A', 'R'
 ETOK 208
 ERND 23
 ECHR ' '
 ETWO 'L', 'O'
 ECHR 'O'
 ECHR 'K'
 ETOK 195
 ETOK 207
 ECHR ' '
 ECHR 'A'
 ECHR 'P'
 ECHR 'P'
 ECHR 'E'
 ETWO 'A', 'R'
 ETOK 196
 ETWO 'A', 'T'
 ETOK 209
 EQUB VE

 EJMP 19                \ Token 107:    ""
 ECHR 'Y'
 ECHR 'E'
 ECHR 'A'
 ECHR 'H'
 ECHR ','
 EJMP 26
 ECHR 'I'
 ECHR ' '
 ECHR 'H'
 ECHR 'E'
 ETWO 'A', 'R'
 ETOK 208
 ERND 23
 ECHR ' '
 ETOK 207
 ECHR ' '
 ETWO 'L', 'E'
 ECHR 'F'
 ECHR 'T'
 ETOK 209
 ETOK 208
 ECHR ' '
 ECHR 'W'
 ECHR 'H'
 ETWO 'I', 'L'
 ECHR 'E'
 ECHR ' '
 ECHR 'B'
 ECHR 'A'
 ECHR 'C'
 ECHR 'K'
 EQUB VE

 EJMP 19                \ Token 108:    ""
 ECHR 'G'
 ETWO 'E', 'T'
 ECHR ' '
 ETOK 179
 ECHR 'R'
 ECHR ' '
 ECHR 'I'
 ECHR 'R'
 ETWO 'O', 'N'
 ECHR ' '
 ECHR 'H'
 ECHR 'I'
 ECHR 'D'
 ECHR 'E'
 ECHR ' '
 ECHR 'O'
 ECHR 'V'
 ETWO 'E', 'R'
 ECHR ' '
 ECHR 'T'
 ECHR 'O'
 ETOK 209
 EQUB VE

 ETWO 'S', 'O'          \ Token 109:    ""
 ECHR 'M'
 ECHR 'E'
 ECHR ' '
 ERND 24
 ETOK 210
 ETOK 207
 ECHR ' '
 ECHR 'W'
 ECHR 'A'
 ECHR 'S'
 ECHR ' '
 ETWO 'S', 'E'
 ETWO 'E', 'N'
 ECHR ' '
 ETWO 'A', 'T'
 ETOK 209
 EQUB VE

 ECHR 'T'               \ Token 110:    ""
 ECHR 'R'
 ECHR 'Y'
 ETOK 209
 EQUB VE

 ECHR ' '               \ Token 111:    ""
 ECHR 'C'
 ECHR 'U'
 ECHR 'D'
 ECHR 'D'
 ECHR 'L'
 ECHR 'Y'
 EQUB VE

 ECHR ' '               \ Token 112:    ""
 ECHR 'C'
 ECHR 'U'
 ECHR 'T'
 ECHR 'E'
 EQUB VE

 ECHR ' '               \ Token 113:    ""
 ECHR 'F'
 ECHR 'U'
 ECHR 'R'
 ECHR 'R'
 ECHR 'Y'
 EQUB VE

 ECHR ' '               \ Token 114:    ""
 ECHR 'F'
 ECHR 'R'
 ECHR 'I'
 ETWO 'E', 'N'
 ECHR 'D'
 ECHR 'L'
 ECHR 'Y'
 EQUB VE

 ECHR 'W'               \ Token 115:    ""
 ECHR 'A'
 ECHR 'S'
 ECHR 'P'
 EQUB VE

 ECHR 'M'               \ Token 116:    ""
 ECHR 'O'
 ETWO 'T', 'H'
 EQUB VE

 ECHR 'G'               \ Token 117:    ""
 ECHR 'R'
 ECHR 'U'
 ECHR 'B'
 EQUB VE

 ETWO 'A', 'N'          \ Token 118:    ""
 ECHR 'T'
 EQUB VE

 EJMP 18                \ Token 119:    ""
 EQUB VE

 ECHR 'P'               \ Token 120:    ""
 ECHR 'O'
 ETWO 'E', 'T'
 EQUB VE

 ECHR 'H'               \ Token 121:    ""
 ECHR 'O'
 ECHR 'G'
 EQUB VE

 ECHR 'Y'               \ Token 122:    ""
 ECHR 'A'
 ECHR 'K'
 EQUB VE

 ECHR 'S'               \ Token 123:    ""
 ECHR 'N'
 ECHR 'A'
 ETWO 'I', 'L'
 EQUB VE

 ECHR 'S'               \ Token 124:    ""
 ECHR 'L'
 ECHR 'U'
 ECHR 'G'
 EQUB VE

 ECHR 'T'               \ Token 125:    ""
 ECHR 'R'
 ECHR 'O'
 ECHR 'P'
 ECHR 'I'
 ECHR 'C'
 ETWO 'A', 'L'
 EQUB VE

 ECHR 'D'               \ Token 126:    ""
 ETWO 'E', 'N'
 ETWO 'S', 'E'
 EQUB VE

 ETWO 'R', 'A'          \ Token 127:    ""
 ETWO 'I', 'N'
 EQUB VE

 ECHR 'I'               \ Token 128:    ""
 ECHR 'M'
 ECHR 'P'
 ETWO 'E', 'N'
 ETWO 'E', 'T'
 ECHR 'R'
 ETWO 'A', 'B'
 ETWO 'L', 'E'
 EQUB VE

 ECHR 'E'               \ Token 129:    ""
 ECHR 'X'
 ECHR 'U'
 ECHR 'B'
 ETWO 'E', 'R'
 ETWO 'A', 'N'
 ECHR 'T'
 EQUB VE

 ECHR 'F'               \ Token 130:    ""
 ECHR 'U'
 ECHR 'N'
 ECHR 'N'
 ECHR 'Y'
 EQUB VE

 ECHR 'W'               \ Token 131:    ""
 ECHR 'E'
 ECHR 'I'
 ECHR 'R'
 ECHR 'D'
 EQUB VE

 ECHR 'U'               \ Token 132:    ""
 ETWO 'N', 'U'
 ECHR 'S'
 ECHR 'U'
 ETWO 'A', 'L'
 EQUB VE

 ETWO 'S', 'T'          \ Token 133:    ""
 ETWO 'R', 'A'
 ECHR 'N'
 ETWO 'G', 'E'
 EQUB VE

 ECHR 'P'               \ Token 134:    ""
 ECHR 'E'
 ECHR 'C'
 ECHR 'U'
 ECHR 'L'
 ECHR 'I'
 ETWO 'A', 'R'
 EQUB VE

 ECHR 'F'               \ Token 135:    ""
 ETWO 'R', 'E'
 ETWO 'Q', 'U'
 ETWO 'E', 'N'
 ECHR 'T'
 EQUB VE

 ECHR 'O'               \ Token 136:    ""
 ECHR 'C'
 ECHR 'C'
 ECHR 'A'
 ECHR 'S'
 ECHR 'I'
 ETWO 'O', 'N'
 ETWO 'A', 'L'
 EQUB VE

 ECHR 'U'               \ Token 137:    ""
 ECHR 'N'
 ECHR 'P'
 ETWO 'R', 'E'
 ETWO 'D', 'I'
 ECHR 'C'
 ECHR 'T'
 ETWO 'A', 'B'
 ETWO 'L', 'E'
 EQUB VE

 ECHR 'D'               \ Token 138:    ""
 ETWO 'R', 'E'
 ECHR 'A'
 ECHR 'D'
 ECHR 'F'
 ECHR 'U'
 ECHR 'L'
 EQUB VE

 ETOK 171               \ Token 139:    ""
 EQUB VE

 ERND 1                 \ Token 140:    ""
 ECHR ' '
 ERND 0
 ECHR ' '
 ECHR 'F'
 ETWO 'O', 'R'
 ECHR ' '
 ERND 10
 EQUB VE

 ETOK 140               \ Token 141:    ""
 ETOK 178
 ERND 10
 EQUB VE

 ERND 11                \ Token 142:    ""
 ECHR ' '
 ECHR 'B'
 ECHR 'Y'
 ECHR ' '
 ERND 12
 EQUB VE

 ETOK 140               \ Token 143:    ""
 ECHR ' '
 ECHR 'B'
 ECHR 'U'
 ECHR 'T'
 ECHR ' '
 ETOK 142
 EQUB VE

 ECHR ' '               \ Token 144:    ""
 ECHR 'A'
 ERND 20
 ECHR ' '
 ERND 21
 EQUB VE

 ECHR 'P'               \ Token 145:    ""
 ETWO 'L', 'A'
 ECHR 'N'
 ETWO 'E', 'T'
 EQUB VE

 ECHR 'W'               \ Token 146:    ""
 ETWO 'O', 'R'
 ECHR 'L'
 ECHR 'D'
 EQUB VE

 ETWO 'T', 'H'          \ Token 147:    ""
 ECHR 'E'
 ECHR ' '
 EQUB VE

 ETWO 'T', 'H'          \ Token 148:    ""
 ECHR 'I'
 ECHR 'S'
 ECHR ' '
 EQUB VE

 EQUB VE                \ Token 149:    ""

 EJMP 9                 \ Token 150:    ""
 EJMP 11
 EJMP 1
 EJMP 8
 EQUB VE

 EQUB VE                \ Token 151:    ""

 EQUB VE                \ Token 152:    ""

 ECHR 'I'               \ Token 153:    ""
 ETWO 'A', 'N'
 EQUB VE

 EJMP 19                \ Token 154:    ""
 ECHR 'C'
 ECHR 'O'
 ECHR 'M'
 ETWO 'M', 'A'
 ECHR 'N'
 ECHR 'D'
 ETWO 'E', 'R'
 EQUB VE

 ERND 13                \ Token 155:    ""
 EQUB VE

 ECHR 'M'               \ Token 156:    ""
 ETWO 'O', 'U'
 ECHR 'N'
 ECHR 'T'
 ECHR 'A'
 ETWO 'I', 'N'
 EQUB VE

 ECHR 'E'               \ Token 157:    ""
 ETWO 'D', 'I'
 ECHR 'B'
 ETWO 'L', 'E'
 EQUB VE

 ECHR 'T'               \ Token 158:    ""
 ETWO 'R', 'E'
 ECHR 'E'
 EQUB VE

 ECHR 'S'               \ Token 159:    ""
 ECHR 'P'
 ECHR 'O'
 ECHR 'T'
 ECHR 'T'
 ETWO 'E', 'D'
 EQUB VE

 ERND 29                \ Token 160:    ""
 EQUB VE

 ERND 30                \ Token 161:    ""
 EQUB VE

 ERND 6                 \ Token 162:    ""
 ECHR 'O'
 ECHR 'I'
 ECHR 'D'
 EQUB VE

 ERND 36                \ Token 163:    ""
 EQUB VE

 ERND 35                \ Token 164:    ""
 EQUB VE

 ETWO 'A', 'N'          \ Token 165:    ""
 ECHR 'C'
 ECHR 'I'
 ETWO 'E', 'N'
 ECHR 'T'
 EQUB VE

 ECHR 'E'               \ Token 166:    ""
 ECHR 'X'
 ETWO 'C', 'E'
 ECHR 'P'
 ETWO 'T', 'I'
 ETWO 'O', 'N'
 ETWO 'A', 'L'
 EQUB VE

 ECHR 'E'               \ Token 167:    ""
 ECHR 'C'
 ETWO 'C', 'E'
 ECHR 'N'
 ECHR 'T'
 ECHR 'R'
 ECHR 'I'
 ECHR 'C'
 EQUB VE

 ETWO 'I', 'N'          \ Token 168:    ""
 ECHR 'G'
 ETWO 'R', 'A'
 ETWO 'I', 'N'
 ETWO 'E', 'D'
 EQUB VE

 ERND 23                \ Token 169:    ""
 EQUB VE

 ECHR 'K'               \ Token 170:    ""
 ETWO 'I', 'L'
 ETWO 'L', 'E'
 ECHR 'R'
 EQUB VE

 ECHR 'D'               \ Token 171:    ""
 ECHR 'E'
 ECHR 'A'
 ECHR 'D'
 ECHR 'L'
 ECHR 'Y'
 EQUB VE

 ECHR 'W'               \ Token 172:    ""
 ECHR 'I'
 ECHR 'C'
 ECHR 'K'
 ETWO 'E', 'D'
 EQUB VE

 ECHR 'L'               \ Token 173:    ""
 ETWO 'E', 'T'
 ECHR 'H'
 ETWO 'A', 'L'
 EQUB VE

 ECHR 'V'               \ Token 174:    ""
 ECHR 'I'
 ECHR 'C'
 ECHR 'I'
 ETWO 'O', 'U'
 ECHR 'S'
 EQUB VE

 ETWO 'I', 'T'          \ Token 175:    ""
 ECHR 'S'
 ECHR ' '
 EQUB VE

 EJMP 13                \ Token 176:    ""
 EJMP 14
 EJMP 19
 EQUB VE

 ECHR '.'               \ Token 177:    ""
 EJMP 12
 EJMP 15
 EQUB VE

 ECHR ' '               \ Token 178:    ""
 ETWO 'A', 'N'
 ECHR 'D'
 ECHR ' '
 EQUB VE

 ECHR 'Y'               \ Token 179:    ""
 ETWO 'O', 'U'
 EQUB VE

 ECHR 'P'               \ Token 180:    ""
 ETWO 'A', 'R'
 ECHR 'K'
 ETOK 195
 ECHR 'M'
 ETWO 'E', 'T'
 ETWO 'E', 'R'
 ECHR 'S'
 EQUB VE

 ECHR 'D'               \ Token 181:    ""
 ECHR 'U'
 ETWO 'S', 'T'
 ECHR ' '
 ECHR 'C'
 ECHR 'L'
 ETWO 'O', 'U'
 ECHR 'D'
 ECHR 'S'
 EQUB VE

 ECHR 'I'               \ Token 182:    ""
 ETWO 'C', 'E'
 ECHR ' '
 ECHR 'B'
 ETWO 'E', 'R'
 ECHR 'G'
 ECHR 'S'
 EQUB VE

 ECHR 'R'               \ Token 183:    ""
 ECHR 'O'
 ECHR 'C'
 ECHR 'K'
 ECHR ' '
 ECHR 'F'
 ETWO 'O', 'R'
 ETWO 'M', 'A'
 ETWO 'T', 'I'
 ETWO 'O', 'N'
 ECHR 'S'
 EQUB VE

 ECHR 'V'               \ Token 184:    ""
 ECHR 'O'
 ECHR 'L'
 ECHR 'C'
 ECHR 'A'
 ETWO 'N', 'O'
 ETWO 'E', 'S'
 EQUB VE

 ECHR 'P'               \ Token 185:    ""
 ETWO 'L', 'A'
 ECHR 'N'
 ECHR 'T'
 EQUB VE

 ECHR 'T'               \ Token 186:    ""
 ECHR 'U'
 ECHR 'L'
 ECHR 'I'
 ECHR 'P'
 EQUB VE

 ECHR 'B'               \ Token 187:    ""
 ETWO 'A', 'N'
 ETWO 'A', 'N'
 ECHR 'A'
 EQUB VE

 ECHR 'C'               \ Token 188:    ""
 ETWO 'O', 'R'
 ECHR 'N'
 EQUB VE

 EJMP 18                \ Token 189:    ""
 ECHR 'W'
 ECHR 'E'
 ETWO 'E', 'D'
 EQUB VE

 EJMP 18                \ Token 190:    ""
 EQUB VE

 EJMP 17                \ Token 191:    ""
 ECHR ' '
 EJMP 18
 EQUB VE

 EJMP 17                \ Token 192:    ""
 ECHR ' '
 ERND 13
 EQUB VE

 ETWO 'I', 'N'          \ Token 193:    ""
 ECHR 'H'
 ETWO 'A', 'B'
 ETWO 'I', 'T'
 ETWO 'A', 'N'
 ECHR 'T'
 EQUB VE

 ETOK 191               \ Token 194:    ""
 EQUB VE

 ETWO 'I', 'N'          \ Token 195:    ""
 ECHR 'G'
 ECHR ' '
 EQUB VE

 ETWO 'E', 'D'          \ Token 196:    ""
 ECHR ' '
 EQUB VE

 EJMP 26                \ Token 197:    ""
 ECHR 'D'
 ECHR '.'
 EJMP 19
 ECHR 'B'
 ECHR 'R'
 ETWO 'A', 'B'
 ETWO 'E', 'N'
 ECHR ' '
 ECHR '&'
 EJMP 26
 ECHR 'I'
 ECHR '.'
 EJMP 19
 ETWO 'B', 'E'
 ECHR 'L'
 ECHR 'L'
 EQUB VE

 ECHR ' '               \ Token 198:    ""
 ECHR 'L'
 ETWO 'I', 'T'
 ECHR 'T'
 ETWO 'L', 'E'
 EJMP 26
 ECHR 'S'
 ETWO 'Q', 'U'
 ECHR 'E'
 ECHR 'A'
 ECHR 'K'
 ECHR 'Y'
 EQUB VE

 EJMP 25                \ Token 199:    ""
 EJMP 9
 EJMP 29
 EJMP 14
 EJMP 13
 EJMP 19
 ECHR 'G'
 ECHR 'O'
 ECHR 'O'
 ECHR 'D'
 ECHR ' '
 ECHR 'D'
 ECHR 'A'
 ECHR 'Y'
 ECHR ' '
 ETOK 154
 ECHR ' '
 EJMP 4
 ECHR ','
 ECHR ' '
 ETWO 'A', 'L'
 ETWO 'L', 'O'
 ECHR 'W'
 ECHR ' '
 ECHR 'M'
 ECHR 'E'
 ETOK 201
 ETWO 'I', 'N'
 ECHR 'T'
 ECHR 'R'
 ECHR 'O'
 ECHR 'D'
 ECHR 'U'
 ETWO 'C', 'E'
 ECHR ' '
 ECHR 'M'
 ECHR 'Y'
 ETWO 'S', 'E'
 ECHR 'L'
 ECHR 'F'
 ECHR '.'
 EJMP 26
 ECHR 'I'
 ECHR ' '
 ECHR 'A'
 ECHR 'M'
 EJMP 26
 ETWO 'T', 'H'
 ECHR 'E'
 EJMP 26
 ECHR 'M'
 ETWO 'E', 'R'
 ECHR 'C'
 ECHR 'H'
 ETWO 'A', 'N'
 ECHR 'T'
 EJMP 26
 ECHR 'P'
 ECHR 'R'
 ETWO 'I', 'N'
 ETWO 'C', 'E'
 ECHR ' '
 ECHR 'O'
 ECHR 'F'
 EJMP 26
 ETWO 'T', 'H'
 ECHR 'R'
 ECHR 'U'
 ECHR 'N'
 ECHR ' '
 ETWO 'A', 'N'
 ECHR 'D'
 EJMP 26
 ECHR 'I'
 EJMP 26
 ECHR 'F'
 ETWO 'I', 'N'
 ECHR 'D'
 ECHR ' '
 ECHR 'M'
 ECHR 'Y'
 ETWO 'S', 'E'
 ECHR 'L'
 ECHR 'F'
 ECHR ' '
 ECHR 'F'
 ETWO 'O', 'R'
 ETWO 'C', 'E'
 ECHR 'D'
 ETOK 201
 ETWO 'S', 'E'
 ECHR 'L'
 ECHR 'L'
 ECHR ' '
 ECHR 'M'
 ECHR 'Y'
 ECHR ' '
 ECHR 'M'
 ECHR 'O'
 ETWO 'S', 'T'
 ECHR ' '
 ECHR 'T'
 ETWO 'R', 'E'
 ECHR 'A'
 ECHR 'S'
 ECHR 'U'
 ETWO 'R', 'E'
 ECHR 'D'
 ECHR ' '
 ECHR 'P'
 ECHR 'O'
 ECHR 'S'
 ETWO 'S', 'E'
 ECHR 'S'
 ECHR 'S'
 ECHR 'I'
 ETWO 'O', 'N'
 ETOK 204
 EJMP 19
 ECHR 'I'
 ECHR ' '
 ECHR 'A'
 ECHR 'M'
 ECHR ' '
 ECHR 'O'
 ECHR 'F'
 ECHR 'F'
 ETWO 'E', 'R'
 ETOK 195
 ETOK 179
 ECHR ','
 ECHR ' '
 ECHR 'F'
 ETWO 'O', 'R'
 ECHR ' '
 ETOK 147
 ECHR 'P'
 ETWO 'A', 'L'
 ECHR 'T'
 ECHR 'R'
 ECHR 'Y'
 ECHR ' '
 ECHR 'S'
 ECHR 'U'
 ECHR 'M'
 ECHR ' '
 ECHR 'O'
 ECHR 'F'
 ECHR ' '
 ECHR 'J'
 ECHR 'U'
 ETWO 'S', 'T'
 ECHR ' '
 ECHR '5'
 ECHR '0'
 ECHR '0'
 ECHR '0'
 EJMP 19
 ECHR 'C'
 EJMP 19
 ECHR 'R'
 ECHR ' '
 ETOK 147
 ECHR 'R'
 ETWO 'A', 'R'
 ECHR 'E'
 ETWO 'S', 'T'
 ECHR ' '
 ETWO 'T', 'H'
 ETOK 195
 ECHR ' '
 ETWO 'I', 'N'
 ECHR ' '
 ETWO 'T', 'H'
 ECHR 'E'
 EJMP 26
 ECHR 'K'
 ETWO 'N', 'O'
 ECHR 'W'
 ECHR 'N'
 EJMP 26
 ECHR 'U'
 ECHR 'N'
 ECHR 'I'
 ECHR 'V'
 ETWO 'E', 'R'
 ETWO 'S', 'E'
 ETOK 204
 EJMP 19
 ECHR 'W'
 ETWO 'I', 'L'
 ECHR 'L'
 ECHR ' '
 ETOK 179
 ECHR ' '
 ECHR 'T'
 ECHR 'A'
 ECHR 'K'
 ECHR 'E'
 ECHR ' '
 ETWO 'I', 'T'
 ECHR '?'
 EJMP 12
 EJMP 15
 EJMP 1
 EJMP 8
 EQUB VE

 EJMP 26                \ Token 200:    ""
 ECHR 'N'
 ECHR 'A'
 ECHR 'M'
 ECHR 'E'
 ECHR '?'
 ECHR ' '
 EQUB VE

 ECHR ' '               \ Token 201:    ""
 ECHR 'T'
 ECHR 'O'
 ECHR ' '
 EQUB VE

 ECHR ' '               \ Token 202:    ""
 ECHR 'I'
 ECHR 'S'
 ECHR ' '
 EQUB VE

 ECHR 'W'               \ Token 203:    ""
 ECHR 'A'
 ECHR 'S'
 ECHR ' '
 ETWO 'L', 'A'
 ETWO 'S', 'T'
 ECHR ' '
 ETWO 'S', 'E'
 ETWO 'E', 'N'
 ECHR ' '
 ETWO 'A', 'T'
 ECHR ' '
 EJMP 19
 EQUB VE

 ECHR '.'               \ Token 204:    ""
 EJMP 12
 EJMP 12
 ECHR ' '
 EJMP 19
 EQUB VE

 EJMP 19                \ Token 205:    ""
 ECHR 'D'
 ECHR 'O'
 ECHR 'C'
 ECHR 'K'
 ETWO 'E', 'D'
 EQUB VE

 EQUB VE                \ Token 206:    ""

 ECHR 'S'               \ Token 207:    ""
 ECHR 'H'
 ECHR 'I'
 ECHR 'P'
 EQUB VE

 ECHR ' '               \ Token 208:    ""
 ECHR 'A'
 ECHR ' '
 EQUB VE

 EJMP 26                \ Token 209:    ""
 ETWO 'E', 'R'
 ECHR 'R'
 ECHR 'I'
 ETWO 'U', 'S'
 EQUB VE

 ECHR ' '               \ Token 210:    ""
 ECHR 'N'
 ECHR 'E'
 ECHR 'W'
 ECHR ' '
 EQUB VE

 EJMP 26                \ Token 211:    ""
 ECHR 'H'
 ETWO 'E', 'R'
 EJMP 26
 ETWO 'M', 'A'
 ECHR 'J'
 ECHR 'E'
 ETWO 'S', 'T'
 ECHR 'Y'
 ECHR '`'
 ECHR 'S'
 EJMP 26
 ECHR 'S'
 ECHR 'P'
 ECHR 'A'
 ETWO 'C', 'E'
 EJMP 26
 ECHR 'N'
 ECHR 'A'
 ECHR 'V'
 ECHR 'Y'
 EQUB VE

 ETOK 177               \ Token 212:    ""
 EJMP 12
 EJMP 8
 EJMP 1
 ECHR ' '
 EJMP 26
 ECHR 'M'
 ETWO 'E', 'S'
 ECHR 'S'
 ECHR 'A'
 ETWO 'G', 'E'
 EJMP 26
 ETWO 'E', 'N'
 ECHR 'D'
 ECHR 'S'
 EQUB VE

 ECHR ' '               \ Token 213:    ""
 ETOK 154
 ECHR ' '
 EJMP 4
 ECHR ','
 EJMP 26
 ECHR 'I'
 ECHR ' '
 EJMP 13
 ECHR 'A'
 ECHR 'M'
 EJMP 26
 ECHR 'C'
 ECHR 'A'
 ECHR 'P'
 ECHR 'T'
 ECHR 'A'
 ETWO 'I', 'N'
 ECHR ' '
 EJMP 27
 ECHR ' '
 ECHR 'O'
 ECHR 'F'
 ETOK 211
 EQUB VE

 EQUB VE                \ Token 214:    ""

 EJMP 15                \ Token 215:    ""
 ECHR ' '
 ECHR 'U'
 ECHR 'N'
 ECHR 'K'
 ETWO 'N', 'O'
 ECHR 'W'
 ECHR 'N'
 ECHR ' '
 ETOK 145
 EQUB VE

 EJMP 9                 \ Token 216:    ""
 EJMP 8
 EJMP 23
 EJMP 1
 ECHR ' '
 ETWO 'I', 'N'
 ECHR 'C'
 ECHR 'O'
 ECHR 'M'
 ETOK 195
 ECHR 'M'
 ETWO 'E', 'S'
 ECHR 'S'
 ECHR 'A'
 ETWO 'G', 'E'
 EQUB VE

 EJMP 19                \ Token 217:    ""
 ECHR 'C'
 ECHR 'U'
 ECHR 'R'
 ECHR 'R'
 ECHR 'U'
 ETWO 'T', 'H'
 ETWO 'E', 'R'
 ECHR 'S'
 EQUB VE

 EJMP 19                \ Token 218:    ""
 ECHR 'F'
 ECHR 'O'
 ECHR 'S'
 ECHR 'D'
 ECHR 'Y'
 ECHR 'K'
 ECHR 'E'
 EJMP 26
 ECHR 'S'
 ECHR 'M'
 ECHR 'Y'
 ETWO 'T', 'H'
 ECHR 'E'
 EQUB VE

 EJMP 19                \ Token 219:    ""
 ECHR 'F'
 ETWO 'O', 'R'
 ECHR 'T'
 ETWO 'E', 'S'
 ETWO 'Q', 'U'
 ECHR 'E'
 EQUB VE

 ETOK 203               \ Token 220:    ""
 EJMP 19
 ETWO 'R', 'E'
 ETWO 'E', 'S'
 ETWO 'D', 'I'
 ETWO 'C', 'E'
 EQUB VE

 ECHR 'I'               \ Token 221:    ""
 ECHR 'S'
 ECHR ' '
 ETWO 'B', 'E'
 ECHR 'L'
 ECHR 'I'
 ECHR 'E'
 ETWO 'V', 'E'
 ECHR 'D'
 ETOK 201
 ECHR 'H'
 ECHR 'A'
 ETWO 'V', 'E'
 ECHR ' '
 ECHR 'J'
 ECHR 'U'
 ECHR 'M'
 ECHR 'P'
 ETOK 196
 ECHR 'T'
 ECHR 'O'
 ECHR ' '
 ETOK 148
 ECHR 'G'
 ETWO 'A', 'L'
 ECHR 'A'
 ECHR 'X'
 ECHR 'Y'
 EQUB VE

 EJMP 25                \ Token 222:    ""
 EJMP 9
 EJMP 29
 EJMP 14
 EJMP 13
 EJMP 19
 ECHR 'G'
 ECHR 'O'
 ECHR 'O'
 ECHR 'D'
 ECHR ' '
 ECHR 'D'
 ECHR 'A'
 ECHR 'Y'
 ECHR ' '
 ETOK 154
 ECHR ' '
 EJMP 4
 ETOK 204
 EJMP 19
 ECHR 'I'
 ECHR ' '
 ECHR 'A'
 ECHR 'M'
 EJMP 26
 ECHR 'A'
 ETWO 'G', 'E'
 ECHR 'N'
 ECHR 'T'
 EJMP 26
 ECHR 'B'
 ETWO 'L', 'A'
 ECHR 'K'
 ECHR 'E'
 ECHR ' '
 ECHR 'O'
 ECHR 'F'
 EJMP 26
 ECHR 'N'
 ECHR 'A'
 ECHR 'V'
 ETWO 'A', 'L'
 EJMP 26
 ETWO 'I', 'N'
 ECHR 'T'
 ECHR 'E'
 ECHR 'L'
 ECHR 'L'
 ECHR 'I'
 ETWO 'G', 'E'
 ECHR 'N'
 ETWO 'C', 'E'
 ETOK 204
 EJMP 19
 ECHR 'A'
 ECHR 'S'
 ECHR ' '
 ETOK 179
 ECHR ' '
 ECHR 'K'
 ETWO 'N', 'O'
 ECHR 'W'
 ECHR ','
 ECHR ' '
 ETWO 'T', 'H'
 ECHR 'E'
 EJMP 26
 ECHR 'N'
 ECHR 'A'
 ECHR 'V'
 ECHR 'Y'
 ECHR ' '
 ECHR 'H'
 ECHR 'A'
 ETWO 'V', 'E'
 ECHR ' '
 ETWO 'B', 'E'
 ETWO 'E', 'N'
 ECHR ' '
 ECHR 'K'
 ECHR 'E'
 ECHR 'E'
 ECHR 'P'
 ETOK 195
 ETWO 'T', 'H'
 ECHR 'E'
 EJMP 26
 ETWO 'T', 'H'
 ETWO 'A', 'R'
 ECHR 'G'
 ECHR 'O'
 ECHR 'I'
 ECHR 'D'
 ECHR 'S'
 ECHR ' '
 ECHR 'O'
 ECHR 'F'
 ECHR 'F'
 ECHR ' '
 ETOK 179
 ECHR 'R'
 ECHR ' '
 ECHR 'B'
 ECHR 'A'
 ECHR 'C'
 ECHR 'K'
 ECHR ' '
 ETWO 'O', 'U'
 ECHR 'T'
 ECHR ' '
 ETWO 'I', 'N'
 EJMP 26
 ECHR 'D'
 ECHR 'E'
 ECHR 'E'
 ECHR 'P'
 EJMP 26
 ECHR 'S'
 ECHR 'P'
 ECHR 'A'
 ETWO 'C', 'E'
 ECHR ' '
 ECHR 'F'
 ETWO 'O', 'R'
 ECHR ' '
 ETWO 'M', 'A'
 ECHR 'N'
 ECHR 'Y'
 ECHR ' '
 ECHR 'Y'
 ECHR 'E'
 ETWO 'A', 'R'
 ECHR 'S'
 ECHR ' '
 ETWO 'N', 'O'
 ECHR 'W'
 ECHR '.'
 EJMP 26
 ECHR 'W'
 ECHR 'E'
 ECHR 'L'
 ECHR 'L'
 ECHR ' '
 ETOK 147
 ECHR 'S'
 ETWO 'I', 'T'
 ECHR 'U'
 ETWO 'A', 'T'
 ECHR 'I'
 ETWO 'O', 'N'
 ECHR ' '
 ECHR 'H'
 ECHR 'A'
 ECHR 'S'
 ECHR ' '
 ECHR 'C'
 ECHR 'H'
 ETWO 'A', 'N'
 ETWO 'G', 'E'
 ECHR 'D'
 ETOK 204
 EJMP 19
 ETWO 'O', 'U'
 ECHR 'R'
 ECHR ' '
 ECHR 'B'
 ECHR 'O'
 ECHR 'Y'
 ECHR 'S'
 ECHR ' '
 ETWO 'A', 'R'
 ECHR 'E'
 ECHR ' '
 ETWO 'R', 'E'
 ECHR 'A'
 ECHR 'D'
 ECHR 'Y'
 ECHR ' '
 ECHR 'F'
 ETWO 'O', 'R'
 ETOK 208
 ECHR 'P'
 ETWO 'U', 'S'
 ECHR 'H'
 ECHR ' '
 ECHR 'R'
 ECHR 'I'
 ECHR 'G'
 ECHR 'H'
 ECHR 'T'
 ETOK 201
 ETWO 'T', 'H'
 ECHR 'E'
 EJMP 26
 ECHR 'H'
 ECHR 'O'
 ECHR 'M'
 ECHR 'E'
 EJMP 26
 ECHR 'S'
 ECHR 'Y'
 ETWO 'S', 'T'
 ECHR 'E'
 ECHR 'M'
 ECHR ' '
 ECHR 'O'
 ECHR 'F'
 ECHR ' '
 ETWO 'T', 'H'
 ECHR 'O'
 ETWO 'S', 'E'
 ECHR ' '
 ECHR 'M'
 ECHR 'U'
 ECHR 'R'
 ECHR 'D'
 ECHR 'E'
 ETWO 'R', 'E'
 ECHR 'R'
 ECHR 'S'
 ETOK 204
 EJMP 19
 ECHR 'I'
 EJMP 13
 ECHR ' '
 ECHR 'H'
 ECHR 'A'
 ETWO 'V', 'E'
 ECHR ' '
 ECHR 'O'
 ECHR 'B'
 ECHR 'T'
 ECHR 'A'
 ETWO 'I', 'N'
 ETOK 196
 ETOK 147
 ECHR 'D'
 ECHR 'E'
 ECHR 'F'
 ETWO 'E', 'N'
 ETWO 'C', 'E'
 ECHR ' '
 ECHR 'P'
 ETWO 'L', 'A'
 ECHR 'N'
 ECHR 'S'
 ECHR ' '
 ECHR 'F'
 ETWO 'O', 'R'
 ECHR ' '
 ETWO 'T', 'H'
 ECHR 'E'
 ECHR 'I'
 ECHR 'R'
 EJMP 26
 ECHR 'H'
 ECHR 'I'
 ETWO 'V', 'E'
 EJMP 26
 ETOK 146
 ECHR 'S'
 ETOK 204
 EJMP 24
 EJMP 9
 EJMP 29
 EJMP 19
 ETOK 147
 ETWO 'B', 'E'
 ETWO 'E', 'T'
 ETWO 'L', 'E'
 ECHR 'S'
 ECHR ' '
 ECHR 'K'
 ETWO 'N', 'O'
 ECHR 'W'
 ECHR ' '
 ECHR 'W'
 ECHR 'E'
 ECHR '`'
 ETWO 'V', 'E'
 ECHR ' '
 ECHR 'G'
 ECHR 'O'
 ECHR 'T'
 ECHR ' '
 ETWO 'S', 'O'
 ECHR 'M'
 ETWO 'E', 'T'
 ECHR 'H'
 ETOK 195
 ECHR 'B'
 ECHR 'U'
 ECHR 'T'
 ECHR ' '
 ETWO 'N', 'O'
 ECHR 'T'
 ECHR ' '
 ECHR 'W'
 ECHR 'H'
 ETWO 'A', 'T'
 ETOK 204
 EJMP 19
 ECHR 'I'
 ECHR 'F'
 EJMP 26
 ECHR 'I'
 ECHR ' '
 ECHR 'T'
 ETWO 'R', 'A'
 ECHR 'N'
 ECHR 'S'
 ECHR 'M'
 ETWO 'I', 'T'
 ECHR ' '
 ETWO 'T', 'H'
 ECHR 'E'
 EJMP 26
 ECHR 'P'
 ETWO 'L', 'A'
 ECHR 'N'
 ECHR 'S'
 ETOK 201
 ETWO 'O', 'U'
 ECHR 'R'
 ECHR ' '
 ECHR 'B'
 ECHR 'A'
 ETWO 'S', 'E'
 ECHR ' '
 ETWO 'O', 'N'
 EJMP 26
 ETWO 'B', 'I'
 ETWO 'R', 'E'
 ETWO 'R', 'A'
 ECHR ' '
 ETWO 'T', 'H'
 ECHR 'E'
 ECHR 'Y'
 ECHR '`'
 ECHR 'L'
 ECHR 'L'
 ECHR ' '
 ETWO 'I', 'N'
 ECHR 'T'
 ETWO 'E', 'R'
 ETWO 'C', 'E'
 ECHR 'P'
 ECHR 'T'
 ECHR ' '
 ETOK 147
 ECHR 'T'
 ETWO 'R', 'A'
 ECHR 'N'
 ECHR 'S'
 ECHR 'M'
 ECHR 'I'
 ECHR 'S'
 ECHR 'S'
 ECHR 'I'
 ETWO 'O', 'N'
 ECHR '.'
 EJMP 26
 ECHR 'I'
 ECHR ' '
 ECHR 'N'
 ECHR 'E'
 ETOK 196
 ECHR 'A'
 ECHR ' '
 ETOK 207
 ETOK 201
 ETWO 'M', 'A'
 ECHR 'K'
 ECHR 'E'
 ECHR ' '
 ETOK 147
 ECHR 'R'
 ECHR 'U'
 ECHR 'N'
 ETOK 204
 EJMP 19
 ETOK 179
 ECHR '`'
 ETWO 'R', 'E'
 ECHR ' '
 ECHR 'E'
 ETWO 'L', 'E'
 ECHR 'C'
 ECHR 'T'
 ETWO 'E', 'D'
 ETOK 204
 ETOK 147
 ECHR 'P'
 ETWO 'L', 'A'
 ECHR 'N'
 ECHR 'S'
 ECHR ' '
 ETWO 'A', 'R'
 ECHR 'E'
 EJMP 26
 ECHR 'U'
 ECHR 'N'
 ECHR 'I'
 ECHR 'P'
 ECHR 'U'
 ECHR 'L'
 ETWO 'S', 'E'
 ECHR ' '
 ECHR 'C'
 ECHR 'O'
 ECHR 'D'
 ETOK 196
 ECHR 'W'
 ETWO 'I', 'T'
 ECHR 'H'
 ETWO 'I', 'N'
 ECHR ' '
 ETOK 148
 ECHR 'T'
 ETWO 'R', 'A'
 ECHR 'N'
 ECHR 'S'
 ECHR 'M'
 ECHR 'I'
 ECHR 'S'
 ECHR 'S'
 ECHR 'I'
 ETWO 'O', 'N'
 ECHR '.'
 EJMP 26
 ETOK 179
 ECHR ' '
 ECHR 'W'
 ETWO 'I', 'L'
 ECHR 'L'
 ECHR ' '
 ETWO 'B', 'E'
 ECHR ' '
 ECHR 'P'
 ECHR 'A'
 ECHR 'I'
 ECHR 'D'
 ETOK 204
 ECHR ' '
 ECHR ' '
 ECHR ' '
 EJMP 26
 ECHR 'G'
 ECHR 'O'
 ECHR 'O'
 ECHR 'D'
 ECHR ' '
 ECHR 'L'
 ECHR 'U'
 ECHR 'C'
 ECHR 'K'
 ECHR ' '
 ETOK 154
 ETOK 212
 EJMP 24
 EQUB VE

 EJMP 25                \ Token 223:    ""
 EJMP 9
 EJMP 29
 EJMP 8
 EJMP 14
 EJMP 13
 EJMP 19
 ECHR 'W'
 ECHR 'E'
 ECHR 'L'
 ECHR 'L'
 ECHR ' '
 ECHR 'D'
 ETWO 'O', 'N'
 ECHR 'E'
 ECHR ' '
 ETOK 154
 ETOK 204
 ETOK 179
 ECHR ' '
 ECHR 'H'
 ECHR 'A'
 ETWO 'V', 'E'
 ECHR ' '
 ETWO 'S', 'E'
 ECHR 'R'
 ETWO 'V', 'E'
 ECHR 'D'
 ECHR ' '
 ETWO 'U', 'S'
 ECHR ' '
 ECHR 'W'
 ECHR 'E'
 ECHR 'L'
 ECHR 'L'
 ETOK 178
 ECHR 'W'
 ECHR 'E'
 ECHR ' '
 ECHR 'S'
 ECHR 'H'
 ETWO 'A', 'L'
 ECHR 'L'
 ECHR ' '
 ETWO 'R', 'E'
 ECHR 'M'
 ECHR 'E'
 ECHR 'M'
 ECHR 'B'
 ETWO 'E', 'R'
 ETOK 204
 EJMP 19
 ECHR 'W'
 ECHR 'E'
 ECHR ' '
 ETWO 'D', 'I'
 ECHR 'D'
 ECHR ' '
 ETWO 'N', 'O'
 ECHR 'T'
 ECHR ' '
 ECHR 'E'
 ECHR 'X'
 ECHR 'P'
 ECHR 'E'
 ECHR 'C'
 ECHR 'T'
 ECHR ' '
 ETWO 'T', 'H'
 ECHR 'E'
 EJMP 26
 ETWO 'T', 'H'
 ETWO 'A', 'R'
 ECHR 'G'
 ECHR 'O'
 ECHR 'I'
 ECHR 'D'
 ECHR 'S'
 ETOK 201
 ECHR 'F'
 ETWO 'I', 'N'
 ECHR 'D'
 ECHR ' '
 ETWO 'O', 'U'
 ECHR 'T'
 ECHR ' '
 ETWO 'A', 'B'
 ETWO 'O', 'U'
 ECHR 'T'
 ECHR ' '
 ETOK 179
 ETOK 204
 EJMP 19
 ECHR 'F'
 ETWO 'O', 'R'
 ECHR ' '
 ETOK 147
 ECHR 'M'
 ECHR 'O'
 ECHR 'M'
 ETWO 'E', 'N'
 ECHR 'T'
 ECHR ' '
 ECHR 'P'
 ETWO 'L', 'E'
 ECHR 'A'
 ETWO 'S', 'E'
 ECHR ' '
 ECHR 'A'
 ECHR 'C'
 ETWO 'C', 'E'
 ECHR 'P'
 ECHR 'T'
 ECHR ' '
 ETWO 'T', 'H'
 ECHR 'I'
 ECHR 'S'
 EJMP 26
 ECHR 'N'
 ECHR 'A'
 ECHR 'V'
 ECHR 'Y'
 ECHR ' '
 EJMP 6
 ERND 23
 EJMP 5
 ECHR ' '
 ECHR 'A'
 ECHR 'S'
 ECHR ' '
 ECHR 'P'
 ECHR 'A'
 ECHR 'Y'
 ECHR 'M'
 ETWO 'E', 'N'
 ECHR 'T'
 ETOK 212
 EJMP 24
 EQUB VE

 EQUB VE                \ Token 224:    ""

 ECHR 'S'               \ Token 225:    ""
 ECHR 'H'
 ETWO 'R', 'E'
 ECHR 'W'
 EQUB VE

 ETWO 'B', 'E'          \ Token 226:    ""
 ECHR 'A'
 ETWO 'S', 'T'
 EQUB VE

 ECHR 'G'               \ Token 227:    ""
 ETWO 'N', 'U'
 EQUB VE

 ECHR 'S'               \ Token 228:    ""
 ECHR 'N'
 ECHR 'A'
 ECHR 'K'
 ECHR 'E'
 EQUB VE

 ECHR 'D'               \ Token 229:    ""
 ECHR 'O'
 ECHR 'G'
 EQUB VE

 ETWO 'L', 'E'          \ Token 230:    ""
 ECHR 'O'
 ECHR 'P'
 ETWO 'A', 'R'
 ECHR 'D'
 EQUB VE

 ECHR 'C'               \ Token 231:    ""
 ETWO 'A', 'T'
 EQUB VE

 ECHR 'M'               \ Token 232:    ""
 ETWO 'O', 'N'
 ECHR 'K'
 ECHR 'E'
 ECHR 'Y'
 EQUB VE

 ECHR 'G'               \ Token 233:    ""
 ECHR 'O'
 ETWO 'A', 'T'
 EQUB VE

 ECHR 'C'               \ Token 234:    ""
 ETWO 'A', 'R'
 ECHR 'P'
 EQUB VE

 ERND 15                \ Token 235:    ""
 ECHR ' '
 ERND 14
 EQUB VE

 EJMP 17                \ Token 236:    ""
 ECHR ' '
 ERND 29
 ECHR ' '
 ERND 32
 EQUB VE

 ETOK 175               \ Token 237:    ""
 ERND 16
 ECHR ' '
 ERND 30
 ECHR ' '
 ERND 32
 EQUB VE

 ERND 33                \ Token 238:    ""
 ECHR ' '
 ERND 34
 EQUB VE

 ERND 15                \ Token 239:    ""
 ECHR ' '
 ERND 14
 EQUB VE

 ECHR 'M'               \ Token 240:    ""
 ECHR 'E'
 ETWO 'A', 'T'
 EQUB VE

 ECHR 'C'               \ Token 241:    ""
 ECHR 'U'
 ECHR 'T'
 ECHR 'L'
 ETWO 'E', 'T'
 EQUB VE

 ETWO 'S', 'T'          \ Token 242:    ""
 ECHR 'E'
 ECHR 'A'
 ECHR 'K'
 EQUB VE

 ECHR 'B'               \ Token 243:    ""
 ECHR 'U'
 ECHR 'R'
 ETWO 'G', 'E'
 ECHR 'R'
 ECHR 'S'
 EQUB VE

 ECHR 'S'               \ Token 244:    ""
 ETWO 'O', 'U'
 ECHR 'P'
 EQUB VE

 ECHR 'I'               \ Token 245:    ""
 ETWO 'C', 'E'
 EQUB VE

 ECHR 'M'               \ Token 246:    ""
 ECHR 'U'
 ECHR 'D'
 EQUB VE

 ECHR 'Z'               \ Token 247:    ""
 ETWO 'E', 'R'
 ECHR 'O'
 ECHR '-'
 EJMP 19
 ECHR 'G'
 EQUB VE

 ECHR 'V'               \ Token 248:    ""
 ECHR 'A'
 ECHR 'C'
 ECHR 'U'
 ECHR 'U'
 ECHR 'M'
 EQUB VE

 EJMP 17                \ Token 249:    ""
 ECHR ' '
 ECHR 'U'
 ECHR 'L'
 ECHR 'T'
 ETWO 'R', 'A'
 EQUB VE

 ECHR 'H'               \ Token 250:    ""
 ECHR 'O'
 ECHR 'C'
 ECHR 'K'
 ECHR 'E'
 ECHR 'Y'
 EQUB VE

 ECHR 'C'               \ Token 251:    ""
 ECHR 'R'
 ECHR 'I'
 ECHR 'C'
 ECHR 'K'
 ETWO 'E', 'T'
 EQUB VE

 ECHR 'K'               \ Token 252:    ""
 ETWO 'A', 'R'
 ETWO 'A', 'T'
 ECHR 'E'
 EQUB VE

 ECHR 'P'               \ Token 253:    ""
 ECHR 'O'
 ETWO 'L', 'O'
 EQUB VE

 ECHR 'T'               \ Token 254:    ""
 ETWO 'E', 'N'
 ECHR 'N'
 ECHR 'I'
 ECHR 'S'
 EQUB VE

 EQUB VE                \ Token 255:    ""

\ ******************************************************************************
\
\       Name: RUPLA
\       Type: Variable
\   Category: Text
\    Summary: System numbers that have extended decription overrides
\  Deep dive: Extended system descriptions
\             Extended text tokens
\
\ ------------------------------------------------------------------------------
\
\ This table contains the extended token numbers to show as the specified
\ system's extended description, if the criteria in the RUGAL table are met.
\
\ The three variables work as follows:
\
\   * The RUPLA table contains the system numbers
\
\   * The RUGAL table contains the galaxy numbers and mission criteria
\
\   * The RUTOK table contains the extended token to display instead of the
\     normal extended description if the criteria in RUPLA and RUGAL are met
\
\ See the PDESC routine for details of how extended system descriptions work.
\
\ ******************************************************************************

.RUPLA

 EQUB 211               \ System 211, Galaxy 0                 Teorge = Token  1
 EQUB 150               \ System 150, Galaxy 0, Mission 1        Xeer = Token  2
 EQUB 36                \ System  36, Galaxy 0, Mission 1    Reesdice = Token  3
 EQUB 28                \ System  28, Galaxy 0, Mission 1       Arexe = Token  4
 EQUB 253               \ System 253, Galaxy 1, Mission 1      Errius = Token  5
 EQUB 79                \ System  79, Galaxy 1, Mission 1      Inbibe = Token  6
 EQUB 53                \ System  53, Galaxy 1, Mission 1       Ausar = Token  7
 EQUB 118               \ System 118, Galaxy 1, Mission 1      Usleri = Token  8
 EQUB 32                \ System  32, Galaxy 1, Mission 1      Bebege = Token 10
 EQUB 68                \ System  68, Galaxy 1, Mission 1      Cearso = Token 11
 EQUB 164               \ System 164, Galaxy 1, Mission 1      Dicela = Token 12
 EQUB 220               \ System 220, Galaxy 1, Mission 1      Eringe = Token 13
 EQUB 106               \ System 106, Galaxy 1, Mission 1      Gexein = Token 14
 EQUB 16                \ System  16, Galaxy 1, Mission 1      Isarin = Token 15
 EQUB 162               \ System 162, Galaxy 1, Mission 1    Letibema = Token 16
 EQUB 3                 \ System   3, Galaxy 1, Mission 1      Maisso = Token 17
 EQUB 107               \ System 107, Galaxy 1, Mission 1        Onen = Token 18
 EQUB 26                \ System  26, Galaxy 1, Mission 1      Ramaza = Token 19
 EQUB 192               \ System 192, Galaxy 1, Mission 1      Sosole = Token 20
 EQUB 184               \ System 184, Galaxy 1, Mission 1      Tivere = Token 21
 EQUB 5                 \ System   5, Galaxy 1, Mission 1      Veriar = Token 22
 EQUB 101               \ System 101, Galaxy 2, Mission 1      Xeveon = Token 23
 EQUB 193               \ System 193, Galaxy 1, Mission 1      Orarra = Token 24

\ ******************************************************************************
\
\       Name: RUGAL
\       Type: Variable
\   Category: Text
\    Summary: The criteria for systems with extended decription overrides
\  Deep dive: Extended system descriptions
\             Extended text tokens
\
\ ------------------------------------------------------------------------------
\
\ This table contains the criteria for printing an extended decription override
\ for a system. The galaxy number is in bits 0-6, while bit 7 determines whether
\ to show this token during mission 1 only (bit 7 is clear, i.e. a value of &0x
\ in the table below), or all of the time (bit 7 is set, i.e. a value of &8x in
\ the table below).
\
\ In other words, Teorge, Arredi, Anreer and Lave have extended decription
\ overrides that are always shown, while the rest only appear when mission 1 is
\ in progress.
\
\ The three variables work as follows:
\
\   * The RUPLA table contains the system numbers
\
\   * The RUGAL table contains the galaxy numbers and mission criteria
\
\   * The RUTOK table contains the extended token to display instead of the
\     normal extended description if the criteria in RUPLA and RUGAL are met
\
\ See the PDESC routine for details of how extended system descriptions work.
\
\ ******************************************************************************

.RUGAL

 EQUB &80               \ System 211, Galaxy 0                 Teorge = Token  1
 EQUB &00               \ System 150, Galaxy 0, Mission 1        Xeer = Token  2
 EQUB &00               \ System  36, Galaxy 0, Mission 1    Reesdice = Token  3
 EQUB &00               \ System  28, Galaxy 0, Mission 1       Arexe = Token  4
 EQUB &01               \ System 253, Galaxy 1, Mission 1      Errius = Token  5
 EQUB &01               \ System  79, Galaxy 1, Mission 1      Inbibe = Token  6
 EQUB &01               \ System  53, Galaxy 1, Mission 1       Ausar = Token  7
 EQUB &01               \ System 118, Galaxy 1, Mission 1      Usleri = Token  8
 EQUB &01               \ System  32, Galaxy 1, Mission 1      Bebege = Token 10
 EQUB &01               \ System  68, Galaxy 1, Mission 1      Cearso = Token 11
 EQUB &01               \ System 164, Galaxy 1, Mission 1      Dicela = Token 12
 EQUB &01               \ System 220, Galaxy 1, Mission 1      Eringe = Token 13
 EQUB &01               \ System 106, Galaxy 1, Mission 1      Gexein = Token 14
 EQUB &01               \ System  16, Galaxy 1, Mission 1      Isarin = Token 15
 EQUB &01               \ System 162, Galaxy 1, Mission 1    Letibema = Token 16
 EQUB &01               \ System   3, Galaxy 1, Mission 1      Maisso = Token 17
 EQUB &01               \ System 107, Galaxy 1, Mission 1        Onen = Token 18
 EQUB &01               \ System  26, Galaxy 1, Mission 1      Ramaza = Token 19
 EQUB &01               \ System 192, Galaxy 1, Mission 1      Sosole = Token 20
 EQUB &01               \ System 184, Galaxy 1, Mission 1      Tivere = Token 21
 EQUB &01               \ System   5, Galaxy 1, Mission 1      Veriar = Token 22
 EQUB &02               \ System 101, Galaxy 2, Mission 1      Xeveon = Token 23
 EQUB &01               \ System 193, Galaxy 1, Mission 1      Orarra = Token 24

.RUTOK

 EQUB VE

 EJMP 19                \ Token xxx:    "
 ETWO 'T', 'H'
 ECHR 'E'
 ECHR ' '
 ECHR 'C'
 ECHR 'O'
 ECHR 'L'
 ETWO 'O', 'N'
 ECHR 'I'
 ETWO 'S', 'T'
 ECHR 'S'
 ECHR ' '
 ECHR 'H'
 ECHR 'E'
 ETWO 'R', 'E'
 ECHR ' '
 ECHR 'H'
 ECHR 'A'
 ETWO 'V', 'E'
 ECHR ' '
 ECHR 'V'
 ECHR 'I'
 ECHR 'O'
 ECHR 'L'
 ETWO 'A', 'T'
 ETWO 'E', 'D'
 EJMP 26
 ETWO 'I', 'N'
 ECHR 'T'
 ETWO 'E', 'R'
 ECHR 'G'
 ETWO 'A', 'L'
 ECHR 'A'
 ECHR 'C'
 ETWO 'T', 'I'
 ECHR 'C'
 EJMP 26
 ECHR 'C'
 ECHR 'L'
 ETWO 'O', 'N'
 ETWO 'I', 'N'
 ECHR 'G'
 EJMP 26
 ECHR 'P'
 ECHR 'R'
 ECHR 'O'
 ECHR 'T'
 ECHR 'O'
 ECHR 'C'
 ECHR 'O'
 ECHR 'L'
 ECHR ' '
 ETWO 'A', 'N'
 ECHR 'D'
 ECHR ' '
 ECHR 'S'
 ECHR 'H'
 ETWO 'O', 'U'
 ECHR 'L'
 ECHR 'D'
 ECHR ' '
 ETWO 'B', 'E'
 ECHR ' '
 ECHR 'A'
 ECHR 'V'
 ECHR 'O'
 ECHR 'I'
 ECHR 'D'
 ETWO 'E', 'D'
 EQUB VE

 EJMP 19                \ Token xxx:    "
 ETWO 'T', 'H'
 ECHR 'E'
 EJMP 26
 ECHR 'C'
 ETWO 'O', 'N'
 ETWO 'S', 'T'
 ECHR 'R'
 ECHR 'I'
 ECHR 'C'
 ECHR 'T'
 ETWO 'O', 'R'
 ECHR ' '
 ETOK 203
 EJMP 19
 ETWO 'R', 'E'
 ETWO 'E', 'S'
 ETWO 'D', 'I'
 ETWO 'C', 'E'
 ECHR ','
 ECHR ' '
 ETOK 154
 EQUB VE

 EJMP 19                \ Token xxx:    "
 ECHR 'A'
 ECHR ' '
 ERND 23
 ECHR ' '
 ETWO 'L', 'O'
 ECHR 'O'
 ECHR 'K'
 ETWO 'I', 'N'
 ECHR 'G'
 ECHR ' '
 ECHR 'S'
 ECHR 'H'
 ECHR 'I'
 ECHR 'P'
 ECHR ' '
 ETWO 'L', 'E'
 ECHR 'F'
 ECHR 'T'
 ECHR ' '
 ECHR 'H'
 ECHR 'E'
 ETWO 'R', 'E'
 ECHR ' '
 ECHR 'A'
 ECHR ' '
 ECHR 'W'
 ECHR 'H'
 ETWO 'I', 'L'
 ECHR 'E'
 ECHR ' '
 ECHR 'B'
 ECHR 'A'
 ECHR 'C'
 ECHR 'K'
 ECHR '.'
 EJMP 26
 ETWO 'L', 'O'
 ECHR 'O'
 ECHR 'K'
 ETWO 'E', 'D'
 ECHR ' '
 ECHR 'B'
 ETWO 'O', 'U'
 ECHR 'N'
 ECHR 'D'
 ECHR ' '
 ECHR 'F'
 ETWO 'O', 'R'
 EJMP 26
 ETWO 'A', 'R'
 ECHR 'E'
 ETWO 'X', 'E'
 EQUB VE

 EJMP 19                \ Token xxx:    "
 ECHR 'Y'
 ETWO 'E', 'S'
 ECHR ','
 ECHR ' '
 ECHR 'A'
 ECHR ' '
 ERND 23
 ECHR ' '
 ECHR 'N'
 ECHR 'E'
 ECHR 'W'
 ECHR ' '
 ECHR 'S'
 ECHR 'H'
 ECHR 'I'
 ECHR 'P'
 ECHR ' '
 ECHR 'H'
 ECHR 'A'
 ECHR 'D'
 ECHR ' '
 ECHR 'A'
 EJMP 26
 ECHR 'G'
 ETWO 'A', 'L'
 ECHR 'A'
 ECHR 'C'
 ETWO 'T', 'I'
 ECHR 'C'
 EJMP 26
 ECHR 'H'
 ECHR 'Y'
 ECHR 'P'
 ETWO 'E', 'R'
 ECHR 'D'
 ECHR 'R'
 ECHR 'I'
 ETWO 'V', 'E'
 ECHR ' '
 ECHR 'F'
 ETWO 'I', 'T'
 ECHR 'T'
 ETWO 'E', 'D'
 ECHR ' '
 ECHR 'H'
 ECHR 'E'
 ETWO 'R', 'E'
 ECHR '.'
 EJMP 26
 ECHR 'U'
 ETWO 'S', 'E'
 ECHR 'D'
 ECHR ' '
 ETWO 'I', 'T'
 ECHR ' '
 ECHR 'T'
 ECHR 'O'
 ECHR 'O'
 EQUB VE

 EJMP 19                \ Token xxx:    "
 ETWO 'T', 'H'
 ECHR 'I'
 ECHR 'S'
 ECHR ' '
 ECHR ' '
 ERND 23
 ECHR ' '
 ECHR 'S'
 ECHR 'H'
 ECHR 'I'
 ECHR 'P'
 ECHR ' '
 ECHR 'D'
 ECHR 'E'
 ECHR 'H'
 ECHR 'Y'
 ECHR 'P'
 ETWO 'E', 'D'
 ECHR ' '
 ECHR 'H'
 ECHR 'E'
 ETWO 'R', 'E'
 ECHR ' '
 ECHR 'F'
 ECHR 'R'
 ECHR 'O'
 ECHR 'M'
 ECHR ' '
 ETWO 'N', 'O'
 ECHR 'W'
 ECHR 'H'
 ECHR 'E'
 ETWO 'R', 'E'
 ECHR ','
 EJMP 26
 ECHR 'S'
 ECHR 'U'
 ECHR 'N'
 ECHR '-'
 EJMP 19
 ECHR 'S'
 ECHR 'K'
 ECHR 'I'
 ECHR 'M'
 ECHR 'M'
 ETWO 'E', 'D'
 ECHR ' '
 ETWO 'A', 'N'
 ECHR 'D'
 ECHR ' '
 ECHR 'J'
 ECHR 'U'
 ECHR 'M'
 ECHR 'P'
 ETWO 'E', 'D'
 ECHR '.'
 EJMP 26
 ECHR 'I'
 ECHR ' '
 ECHR 'H'
 ECHR 'E'
 ETWO 'A', 'R'
 ECHR ' '
 ETWO 'I', 'T'
 ECHR ' '
 ECHR 'W'
 ETWO 'E', 'N'
 ECHR 'T'
 ECHR ' '
 ECHR 'T'
 ECHR 'O'
 EJMP 26
 ETWO 'I', 'N'
 ETWO 'B', 'I'
 ETWO 'B', 'E'
 EQUB VE

 ERND 24                \ Token xxx:    "
 ECHR ' '
 ECHR 'S'
 ECHR 'H'
 ECHR 'I'
 ECHR 'P'
 ECHR ' '
 ECHR 'W'
 ETWO 'E', 'N'
 ECHR 'T'
 ECHR ' '
 ECHR 'F'
 ETWO 'O', 'R'
 ECHR ' '
 ECHR 'M'
 ECHR 'E'
 ECHR ' '
 ETWO 'A', 'T'
 EJMP 26
 ECHR 'A'
 ETWO 'U', 'S'
 ETWO 'A', 'R'
 ECHR '.'
 EJMP 26
 ECHR 'M'
 ECHR 'Y'
 ECHR ' '
 ETWO 'L', 'A'
 ETWO 'S', 'E'
 ECHR 'R'
 ECHR 'S'
 ECHR ' '
 ETWO 'D', 'I'
 ECHR 'D'
 ECHR 'N'
 ECHR '`'
 ECHR 'T'
 ECHR ' '
 ECHR 'E'
 ECHR 'V'
 ETWO 'E', 'N'
 ECHR ' '
 ECHR 'S'
 ECHR 'C'
 ECHR 'R'
 ETWO 'A', 'T'
 ECHR 'C'
 ECHR 'H'
 ECHR ' '
 ETWO 'T', 'H'
 ECHR 'E'
 ECHR ' '
 ERND 24
 EQUB VE

 EJMP 19                \ Token xxx:    "
 ECHR 'O'
 ECHR 'H'
 ECHR ' '
 ECHR 'D'
 ECHR 'E'
 ETWO 'A', 'R'
 ECHR ' '
 ECHR 'M'
 ECHR 'E'
 ECHR ' '
 ECHR 'Y'
 ETWO 'E', 'S'
 ECHR '.'
 ECHR ' '
 ECHR 'A'
 ECHR ' '
 ECHR 'F'
 ECHR 'R'
 ECHR 'I'
 ECHR 'G'
 ECHR 'H'
 ECHR 'T'
 ECHR 'F'
 ECHR 'U'
 ECHR 'L'
 ECHR ' '
 ECHR 'R'
 ECHR 'O'
 ECHR 'G'
 ECHR 'U'
 ECHR 'E'
 ECHR ' '
 ECHR 'S'
 ECHR 'H'
 ECHR 'O'
 ECHR 'T'
 ECHR ' '
 ECHR 'U'
 ECHR 'P'
 ECHR ' '
 ETWO 'L', 'O'
 ECHR 'T'
 ECHR 'S'
 ECHR ' '
 ECHR 'O'
 ECHR 'F'
 ECHR ' '
 ETWO 'T', 'H'
 ECHR 'O'
 ETWO 'S', 'E'
 ECHR ' '
 ETWO 'B', 'E'
 ECHR 'A'
 ETWO 'S', 'T'
 ECHR 'L'
 ECHR 'Y'
 ECHR ' '
 ECHR 'P'
 ECHR 'I'
 ECHR 'R'
 ETWO 'A', 'T'
 ETWO 'E', 'S'
 ECHR ' '
 ETWO 'A', 'N'
 ECHR 'D'
 ECHR ' '
 ECHR 'W'
 ETWO 'E', 'N'
 ECHR 'T'
 ECHR ' '
 ECHR 'T'
 ECHR 'O'
 EJMP 26
 ETWO 'U', 'S'
 ETWO 'L', 'E'
 ECHR 'R'
 ECHR 'I'
 EQUB VE

 EJMP 19                \ Token xxx:    "
 ECHR 'Y'
 ETWO 'O', 'U'
 ECHR ' '
 ECHR 'C'
 ETWO 'A', 'N'
 ECHR ' '
 ECHR 'T'
 ECHR 'A'
 ECHR 'C'
 ECHR 'K'
 ETWO 'L', 'E'
 ECHR ' '
 ETWO 'T', 'H'
 ECHR 'E'
 ECHR ' '
 ERND 13
 ECHR ' '
 ERND 24
 ECHR ' '
 ECHR 'I'
 ECHR 'F'
 ECHR ' '
 ECHR 'Y'
 ETWO 'O', 'U'
 ECHR ' '
 ECHR 'L'
 ECHR 'I'
 ECHR 'K'
 ECHR 'E'
 ECHR '.'
 EJMP 26
 ECHR 'H'
 ECHR 'E'
 ECHR '`'
 ECHR 'S'
 ECHR ' '
 ETWO 'A', 'T'
 EJMP 26
 ETWO 'O', 'R'
 ETWO 'A', 'R'
 ETWO 'R', 'A'
 EQUB VE

 ERND 25                \ Token xxx:    "
 EQUB VE

 ERND 25                \ Token xxx:    "
 EQUB VE

 ERND 25                \ Token xxx:    "
 EQUB VE

 ERND 25                \ Token xxx:    "
 EQUB VE

 ERND 25                \ Token xxx:    "
 EQUB VE

 ERND 25                \ Token xxx:    "
 EQUB VE

 ERND 25                \ Token xxx:    "
 EQUB VE

 ERND 25                \ Token xxx:    "
 EQUB VE

 ERND 25                \ Token xxx:    "
 EQUB VE

 ERND 25                \ Token xxx:    "
 EQUB VE

 ERND 25                \ Token xxx:    "
 EQUB VE

 ERND 25                \ Token xxx:    "
 EQUB VE

 ERND 25                \ Token xxx:    "
 EQUB VE

 EJMP 19                \ Token xxx:    "
 ECHR 'B'
 ECHR 'O'
 ECHR 'Y'
 ECHR ' '
 ETWO 'A', 'R'
 ECHR 'E'
 ECHR ' '
 ECHR 'Y'
 ETWO 'O', 'U'
 ECHR ' '
 ETWO 'I', 'N'
 ECHR ' '
 ETWO 'T', 'H'
 ECHR 'E'
 ECHR ' '
 ECHR 'W'
 ECHR 'R'
 ETWO 'O', 'N'
 ECHR 'G'
 EJMP 26
 ECHR 'G'
 ETWO 'A', 'L'
 ECHR 'A'
 ECHR 'X'
 ECHR 'Y'
 ECHR '!'
 EQUB VE

 EJMP 19                \ Token xxx:    "
 ETWO 'T', 'H'
 ECHR 'E'
 ETWO 'R', 'E'
 ECHR '`'
 ECHR 'S'
 ECHR ' '
 ECHR 'A'
 ECHR ' '
 ETWO 'R', 'E'
 ETWO 'A', 'L'
 ECHR ' '
 ERND 24
 ECHR ' '
 ECHR 'P'
 ECHR 'I'
 ECHR 'R'
 ETWO 'A', 'T'
 ECHR 'E'
 ECHR ' '
 ETWO 'O', 'U'
 ECHR 'T'
 ECHR ' '
 ETWO 'T', 'H'
 ECHR 'E'
 ETWO 'R', 'E'
 EQUB VE

\ ******************************************************************************
\
\       Name: TKN1_DE
\       Type: Variable
\   Category: Text
\    Summary: The first extended token table for recursive tokens 0-255 (DETOK)
\             (German)
\  Deep dive: Extended text tokens
\
\ ******************************************************************************

.TKN1_DE

 EQUB VE                \ Token 0:      ""

 EJMP 19                \ Token 1:      ""
 ECHR 'J'
 ECHR 'A'
 EQUB VE

 EJMP 19                \ Token 2:      ""
 ECHR 'N'
 ETOK 183
 EQUB VE

 EQUB VE                \ Token 3:      ""

 EJMP 19                \ Token 4:      ""
 ECHR 'D'
 ECHR 'E'
 ECHR 'U'
 ECHR 'T'
 ETOK 187
 EQUB VE

 EQUB VE                \ Token 5:      ""

 EQUB VE                \ Token 6:      ""

 EQUB VE                \ Token 7:      ""

 EJMP 19                \ Token 8:      ""
 ECHR 'N'
 ECHR 'E'
 ECHR 'U'
 ETWO 'E', 'R'
 EJMP 26
 ETWO 'N', 'O'
 ECHR 'M'
 ECHR 'E'
 ECHR ':'
 ECHR ' '
 EQUB VE

 EQUB VE                \ Token 9:      ""

 EJMP 23                \ Token 10:     ""
 EJMP 14
 EJMP 13
 EJMP 26
 ETWO 'S', 'E'
 ECHR 'I'
 ECHR 'D'
 ECHR ' '
 ETWO 'G', 'E'
 ECHR 'G'
 ECHR 'R'
 ERND 2
 ERND 3
 ECHR 'T'
 ETOK 213
 ECHR '.'
 EJMP 26
 ETOK 186
 ECHR ' '
 ECHR 'B'
 ETWO 'I', 'T'
 ECHR 'T'
 ECHR 'E'
 ETOK 179
 ECHR ' '
 ECHR 'U'
 ECHR 'M'
 ECHR ' '
 ETOK 183
 ETWO 'E', 'N'
 EJMP 26
 ECHR 'M'
 ECHR 'O'
 ECHR 'M'
 ETWO 'E', 'N'
 ECHR 'T'
 EJMP 26
 ECHR 'I'
 ECHR 'H'
 ETWO 'R', 'E'
 ECHR 'R'
 ECHR ' '
 ECHR 'W'
 ETWO 'E', 'R'
 ECHR 'T'
 ECHR 'V'
 ECHR 'O'
 ECHR 'L'
 ETWO 'L', 'E'
 ECHR 'N'
 EJMP 26
 ECHR 'Z'
 ECHR 'E'
 ETWO 'I', 'T'
 ETOK 204
 ECHR 'W'
 ECHR 'I'
 ECHR 'R'
 ECHR ' '
 ECHR 'W'
 ERND 2
 ECHR 'R'
 ECHR 'D'
 ETWO 'E', 'N'
 ECHR ' '
 ECHR 'U'
 ECHR 'N'
 ECHR 'S'
 ECHR ' '
 ECHR 'F'
 ETWO 'R', 'E'
 ECHR 'U'
 ETWO 'E', 'N'
 ECHR ','
 ECHR ' '
 ECHR 'W'
 ETWO 'E', 'N'
 ECHR 'N'
 ETOK 179
 ECHR ' '
 ETOK 183
 ETWO 'E', 'N'
 ECHR ' '
 ECHR 'K'
 ETWO 'L', 'E'
 ETWO 'I', 'N'
 ETWO 'E', 'N'
 EJMP 26
 ECHR 'A'
 ECHR 'U'
 ECHR 'F'
 ECHR 'T'
 ETWO 'R', 'A'
 ECHR 'G'
 ECHR ' '
 ECHR 'F'
 ERND 2
 ECHR 'R'
 ECHR ' '
 ECHR 'U'
 ECHR 'N'
 ECHR 'S'
 ECHR ' '
 ETWO 'E', 'R'
 ECHR 'F'
 ERND 2
 ECHR 'L'
 ETWO 'L', 'E'
 ECHR 'N'
 ETOK 204
 EJMP 22
 EJMP 19
 ETWO 'B', 'E'
 ECHR 'I'
 ECHR ' '
 ECHR 'D'
 ECHR 'E'
 ECHR 'M'
 ETOK 182
 ECHR ','
 ECHR ' '
 ECHR 'D'
 ECHR 'A'
 ECHR 'S'
 ETOK 179
 ECHR ' '
 ECHR 'H'
 ECHR 'I'
 ETWO 'E', 'R'
 ECHR ' '
 ETWO 'S', 'E'
 ECHR 'H'
 ETWO 'E', 'N'
 ECHR ','
 ECHR ' '
 ECHR 'H'
 ETWO 'A', 'N'
 ECHR 'D'
 ECHR 'E'
 ECHR 'L'
 ECHR 'T'
 ETOK 161
 ECHR 'S'
 ETOK 186
 ECHR ' '
 ECHR 'U'
 ECHR 'M'
 ETOK 185
 ECHR 'N'
 ECHR 'E'
 ECHR 'U'
 ETWO 'E', 'S'
 EJMP 26
 ECHR 'M'
 ECHR 'O'
 ECHR 'D'
 ECHR 'E'
 ECHR 'L'
 ECHR 'L'
 ECHR ','
 EJMP 26
 ECHR 'C'
 ETWO 'O', 'N'
 ETWO 'S', 'T'
 ECHR 'R'
 ECHR 'I'
 ECHR 'C'
 ECHR 'T'
 ETWO 'O', 'R'
 ECHR ','
 ECHR ' '
 ETOK 156
 ECHR 'M'
 ETWO 'I', 'T'
 ECHR ' '
 ETOK 183
 ECHR 'E'
 ECHR 'M'
 ECHR ' '
 ECHR ' '
 ETWO 'G', 'E'
 ECHR 'H'
 ECHR 'E'
 ECHR 'I'
 ECHR 'M'
 ETWO 'E', 'N'
 ECHR ' '
 ECHR 'N'
 ECHR 'E'
 ECHR 'U'
 ETWO 'E', 'N'
 EJMP 26
 ETOK 187
 ETWO 'I', 'L'
 ECHR 'D'
 ETWO 'G', 'E'
 ECHR 'N'
 ETWO 'E', 'R'
 ETWO 'A', 'T'
 ETWO 'O', 'R'
 ECHR ' '
 ECHR 'A'
 ETWO 'U', 'S'
 ETWO 'G', 'E'
 ECHR 'R'
 ERND 2
 ETWO 'S', 'T'
 ETWO 'E', 'T'
 ECHR ' '
 ECHR 'I'
 ETWO 'S', 'T'
 ETOK 204
 EJMP 19
 ETWO 'L', 'E'
 ECHR 'I'
 ETOK 155
 ECHR 'W'
 ECHR 'U'
 ECHR 'R'
 ECHR 'D'
 ECHR 'E'
 ETOK 161
 ETWO 'G', 'E'
 ETWO 'S', 'T'
 ECHR 'O'
 ECHR 'H'
 ETWO 'L', 'E'
 ECHR 'N'
 ETOK 204
 EJMP 19
 ETWO 'E', 'S'
 ECHR ' '
 ECHR 'V'
 ETWO 'E', 'R'
 ETOK 187
 ECHR 'W'
 ETWO 'A', 'N'
 ECHR 'D'
 ECHR ' '
 ETOK 157
 ECHR ' '
 ECHR 'F'
 ERND 2
 ECHR 'N'
 ECHR 'F'
 EJMP 26
 ECHR 'M'
 ETWO 'O', 'N'
 ETWO 'A', 'T'
 ETWO 'E', 'N'
 ECHR ' '
 ECHR 'V'
 ETWO 'O', 'N'
 ECHR ' '
 ECHR 'U'
 ECHR 'N'
 ETWO 'S', 'E'
 ETWO 'R', 'E'
 ECHR 'R'
 EJMP 26
 ECHR 'W'
 ETWO 'E', 'R'
 ECHR 'F'
 ECHR 'T'
 ECHR ' '
 ECHR 'A'
 ECHR 'U'
 ECHR 'F'
 EJMP 26
 ETWO 'X', 'E'
 ETWO 'E', 'R'
 ECHR '.'
 EJMP 26
 ETWO 'E', 'S'
 ECHR ' '
 EJMP 28
 ETOK 204
 EJMP 22
 EJMP 19
 ETWO 'S', 'O'
 ECHR 'L'
 ECHR 'L'
 ECHR 'T'
 ETWO 'E', 'N'
 ETOK 179
 ECHR ' '
 ECHR 'S'
 ETOK 186
 ECHR ' '
 ECHR 'D'
 ECHR 'A'
 ETOK 159
 ECHR ' '
 ETWO 'E', 'N'
 ECHR 'T'
 ETOK 187
 ECHR 'L'
 ECHR 'I'
 ECHR 'E'
 ERND 3
 ETWO 'E', 'N'
 ECHR ','
 ECHR ' '
 ECHR 'I'
 ECHR 'H'
 ECHR 'N'
 ECHR ' '
 ETWO 'A', 'N'
 ETOK 159
 ECHR 'N'
 ECHR 'E'
 ECHR 'H'
 ECHR 'M'
 ETWO 'E', 'N'
 ECHR ','
 ECHR ' '
 ETWO 'S', 'O'
 ECHR ' '
 ETWO 'L', 'A'
 ECHR 'U'
 ECHR 'T'
 ETWO 'E', 'T'
 EJMP 26
 ECHR 'I'
 ECHR 'H'
 ECHR 'R'
 EJMP 26
 ECHR 'A'
 ECHR 'U'
 ECHR 'F'
 ECHR 'T'
 ETWO 'R', 'A'
 ECHR 'G'
 ECHR ','
 ECHR ' '
 ECHR 'D'
 ECHR 'A'
 ECHR 'S'
 ETOK 182
 ETOK 160
 ECHR 'F'
 ETWO 'I', 'N'
 ECHR 'D'
 ETWO 'E', 'N'
 ETOK 178
 ETWO 'E', 'S'
 ETOK 160
 ECHR 'V'
 ETWO 'E', 'R'
 ETOK 162
 ETWO 'E', 'N'
 ETOK 204
 ETWO 'N', 'U'
 ECHR 'R'
 ECHR ' '
 ECHR 'V'
 ETWO 'O', 'N'
 ECHR ' '
 ECHR 'M'
 ETWO 'I', 'L'
 ETWO 'I', 'T'
 ERND 0
 ECHR 'R'
 ECHR 'I'
 ETOK 187
 ETWO 'E', 'N'
 EJMP 26
 ETWO 'L', 'A'
 ETWO 'S', 'E'
 ECHR 'R'
 ECHR 'N'
 ECHR ' '
 ECHR 'K'
 ERND 1
 ECHR 'N'
 ECHR 'N'
 ETWO 'E', 'N'
 ECHR ' '
 ETOK 147
 ECHR 'N'
 ECHR 'E'
 ECHR 'U'
 ETWO 'E', 'N'
 EJMP 26
 ETOK 187
 ETWO 'I', 'L'
 ECHR 'D'
 ECHR 'E'
 ECHR ' '
 ECHR 'D'
 ECHR 'U'
 ECHR 'R'
 ECHR 'C'
 ECHR 'H'
 ECHR 'D'
 ECHR 'R'
 ECHR 'U'
 ECHR 'N'
 ETWO 'G', 'E'
 ECHR 'N'
 ECHR ' '
 ECHR 'W'
 ETWO 'E', 'R'
 ECHR 'D'
 ETWO 'E', 'N'
 ETOK 204
 EJMP 19
 ECHR 'C'
 ETWO 'O', 'N'
 ETWO 'S', 'T'
 ECHR 'R'
 ECHR 'I'
 ECHR 'C'
 ECHR 'T'
 ETWO 'O', 'R'
 ETOK 181
 ECHR 'M'
 ETWO 'I', 'T'
 ECHR ' '
 EJMP 6
 ERND 17
 EJMP 5
 ECHR ' '
 ECHR 'A'
 ETWO 'U', 'S'
 ETWO 'G', 'E'
 ETWO 'S', 'T'
 ETWO 'A', 'T'
 ECHR 'T'
 ETWO 'E', 'T'
 ETOK 177
 EJMP 8
 EJMP 19
 ECHR 'V'
 ECHR 'I'
 ECHR 'E'
 ECHR 'L'
 EJMP 26
 ECHR 'G'
 ECHR 'L'
 ERND 2
 ECHR 'C'
 ECHR 'K'
 ECHR ','
 ECHR ' '
 ETOK 154
 ETOK 212
 EJMP 22
 EQUB VE

 EJMP 25                \ Token 11:     ""
 EJMP 9
 EJMP 29
 EJMP 14
 EJMP 26
 ETOK 164
 ECHR 'T'
 ECHR 'U'
 ECHR 'N'
 ECHR 'G'
 ETOK 213
 ECHR '.'
 EJMP 26
 ECHR 'I'
 ECHR 'H'
 ETWO 'R', 'E'
 EJMP 26
 ETWO 'D', 'I'
 ETWO 'E', 'N'
 ETWO 'S', 'T'
 ECHR 'E'
 ECHR ' '
 ECHR 'W'
 ETWO 'E', 'R'
 ECHR 'D'
 ETWO 'E', 'N'
 ECHR ' '
 ECHR 'W'
 ECHR 'I'
 ETWO 'E', 'D'
 ETWO 'E', 'R'
 ECHR ' '
 ECHR 'B'
 ETWO 'E', 'N'
 ERND 1
 ETWO 'T', 'I'
 ECHR 'G'
 ECHR 'T'
 ETOK 204
 ECHR 'W'
 ETWO 'E', 'N'
 ECHR 'N'
 ETOK 179
 ECHR ' '
 ETWO 'S', 'O'
 ECHR ' '
 ECHR 'G'
 ECHR 'U'
 ECHR 'T'
 ECHR ' '
 ECHR 'W'
 ERND 0
 ETWO 'R', 'E'
 ECHR 'N'
 ECHR ','
 ECHR ' '
 ECHR 'N'
 ETOK 164
 EJMP 26
 ETWO 'C', 'E'
 ETWO 'E', 'R'
 ETWO 'D', 'I'
 ETOK 160
 ECHR 'F'
 ECHR 'A'
 ECHR 'H'
 ETWO 'R', 'E'
 ECHR 'N'
 ECHR ','
 ECHR ' '
 ECHR 'W'
 ETWO 'E', 'R'
 ECHR 'D'
 ETWO 'E', 'N'
 ETOK 179
 ECHR ' '
 ECHR 'D'
 ETWO 'O', 'R'
 ECHR 'T'
 ECHR ' '
 ETWO 'G', 'E'
 ECHR 'N'
 ECHR 'A'
 ECHR 'U'
 ECHR 'E'
 EJMP 26
 ETWO 'A', 'N'
 ECHR 'W'
 ECHR 'E'
 ECHR 'I'
 ECHR 'S'
 ECHR 'U'
 ECHR 'N'
 ETWO 'G', 'E'
 ECHR 'N'
 ECHR ' '
 ETWO 'E', 'R'
 ECHR 'H'
 ETWO 'A', 'L'
 ECHR 'T'
 ETWO 'E', 'N'
 ETOK 204
 EJMP 19
 ECHR 'W'
 ETWO 'E', 'N'
 ECHR 'N'
 ETOK 179
 ECHR ' '
 ETWO 'E', 'R'
 ECHR 'F'
 ECHR 'O'
 ECHR 'L'
 ECHR 'G'
 ETWO 'R', 'E'
 ETOK 186
 ECHR ' '
 ECHR 'S'
 ETWO 'I', 'N'
 ECHR 'D'
 ECHR ','
 ECHR ' '
 ETWO 'S', 'O'
 ECHR ' '
 ECHR 'W'
 ETWO 'E', 'R'
 ECHR 'D'
 ETWO 'E', 'N'
 ETOK 179
 ECHR ' '
 ETWO 'R', 'E'
 ETOK 186
 ECHR 'L'
 ETOK 186
 ECHR ' '
 ETWO 'B', 'E'
 ETWO 'L', 'O'
 ECHR 'H'
 ECHR 'N'
 ECHR 'T'
 ETOK 212
 EJMP 24
 EQUB VE

 EQUB VE                \ Token 12:     ""

 EQUB VE                \ Token 13:     ""

 EJMP 21                \ Token 14:     ""
 ETOK 145
 ETOK 200
 EQUB VE

 EJMP 25                \ Token 15:     ""
 EJMP 9
 EJMP 29
 EJMP 14
 EJMP 13
 EJMP 26
 ECHR 'B'
 ETWO 'R', 'A'
 ECHR 'V'
 ECHR 'O'
 ECHR ' '
 ETOK 154
 ECHR '!'
 EJMP 12
 EJMP 12
 EJMP 26
 ECHR 'F'
 ERND 2
 ECHR 'R'
 ETOK 179
 ECHR ' '
 ECHR 'G'
 ECHR 'I'
 ECHR 'B'
 ECHR 'T'
 ETOK 161
 ETWO 'S', 'T'
 ETWO 'E', 'T'
 ECHR 'S'
 ECHR ' '
 ETOK 183
 ETWO 'E', 'N'
 EJMP 26
 ECHR 'P'
 ECHR 'L'
 ETWO 'A', 'T'
 ECHR 'Z'
 ETOK 188
 ETOK 155
 ETOK 211
 ETOK 204
 ECHR 'U'
 ECHR 'N'
 ECHR 'D'
 ECHR ' '
 ECHR 'V'
 ECHR 'I'
 ECHR 'E'
 ECHR 'L'
 ETWO 'L', 'E'
 ETOK 186
 ECHR 'T'
 ECHR ' '
 ECHR 'F'
 ECHR 'R'
 ERND 2
 ECHR 'H'
 ETWO 'E', 'R'
 ECHR ' '
 ETWO 'A', 'L'
 ECHR 'S'
 ETOK 179
 ECHR ' '
 ECHR 'D'
 ETWO 'E', 'N'
 ECHR 'K'
 ETWO 'E', 'N'
 ECHR '.'
 ECHR '.'
 ETOK 212
 EJMP 24
 EQUB VE

 EQUB VE                \ Token 16:     ""

 EQUB VE                \ Token 17:     ""

 EQUB VE                \ Token 18:     ""

 EQUB VE                \ Token 19:     ""

 EQUB VE                \ Token 20:     ""

 EQUB VE                \ Token 21:     ""

 EQUB VE                \ Token 22:     ""

 EQUB VE                \ Token 23:     ""

 EQUB VE                \ Token 24:     ""

 EQUB VE                \ Token 25:     ""

 EQUB VE                \ Token 26:     ""

 EQUB VE                \ Token 27:     ""

 EQUB VE                \ Token 28:     ""

 EQUB VE                \ Token 29:     ""

 EQUB VE                \ Token 30:     ""

 EQUB VE                \ Token 31:     ""

 EQUB VE                \ Token 32:     ""

 EQUB VE                \ Token 33:     ""

 EQUB VE                \ Token 34:     ""

 EQUB VE                \ Token 35:     ""

 EQUB VE                \ Token 36:     ""

 EQUB VE                \ Token 37:     ""

 EQUB VE                \ Token 38:     ""

 EQUB VE                \ Token 39:     ""

 EQUB VE                \ Token 40:     ""

 EQUB VE                \ Token 41:     ""

 EQUB VE                \ Token 42:     ""

 EQUB VE                \ Token 43:     ""

 EQUB VE                \ Token 44:     ""

 EQUB VE                \ Token 45:     ""

 EQUB VE                \ Token 46:     ""

 EQUB VE                \ Token 47:     ""

 EQUB VE                \ Token 48:     ""

 EQUB VE                \ Token 49:     ""

 EQUB VE                \ Token 50:     ""

 EQUB VE                \ Token 51:     ""

 EQUB VE                \ Token 52:     ""

 EQUB VE                \ Token 53:     ""

 EQUB VE                \ Token 54:     ""

 EQUB VE                \ Token 55:     ""

 EQUB VE                \ Token 56:     ""

 EQUB VE                \ Token 57:     ""

 EQUB VE                \ Token 58:     ""

 EQUB VE                \ Token 59:     ""

 EQUB VE                \ Token 60:     ""

 EQUB VE                \ Token 61:     ""

 EQUB VE                \ Token 62:     ""

 EQUB VE                \ Token 63:     ""

 EQUB VE                \ Token 64:     ""

 EQUB VE                \ Token 65:     ""

 EQUB VE                \ Token 66:     ""

 EQUB VE                \ Token 67:     ""

 EQUB VE                \ Token 68:     ""

 EQUB VE                \ Token 69:     ""

 EQUB VE                \ Token 70:     ""

 EQUB VE                \ Token 71:     ""

 EQUB VE                \ Token 72:     ""

 EQUB VE                \ Token 73:     ""

 EQUB VE                \ Token 74:     ""

 EQUB VE                \ Token 75:     ""

 EQUB VE                \ Token 76:     ""

 EQUB VE                \ Token 77:     ""

 EQUB VE                \ Token 78:     ""

 EQUB VE                \ Token 79:     ""

 EQUB VE                \ Token 80:     ""

 EQUB VE                \ Token 81:     ""

 EQUB VE                \ Token 82:     ""

 EQUB VE                \ Token 83:     ""

 EQUB VE                \ Token 84:     ""

 EJMP 2                 \ Token 85:     ""
 ERND 31
 EJMP 13
 EQUB VE

 EQUB VE                \ Token 86:     ""

 EQUB VE                \ Token 87:     ""

 EQUB VE                \ Token 88:     ""

 EQUB VE                \ Token 89:     ""

 EQUB VE                \ Token 90:     ""

 EJMP 19                \ Token 91:     ""
 ECHR 'H'
 ETWO 'A', 'L'
 ECHR 'U'
 ECHR 'N'
 ECHR 'K'
 ECHR 'E'
 EQUB VE

 EJMP 19                \ Token 92:     ""
 ETOK 187
 ECHR 'U'
 ECHR 'R'
 ECHR 'K'
 ECHR 'E'
 EQUB VE

 EJMP 19                \ Token 93:     ""
 ECHR 'L'
 ECHR 'U'
 ECHR 'M'
 ECHR 'P'
 EQUB VE

 EJMP 19                \ Token 94:     ""
 ECHR 'G'
 ECHR 'A'
 ECHR 'U'
 ECHR 'N'
 ETWO 'E', 'R'
 EQUB VE

 EJMP 19                \ Token 95:     ""
 ETOK 187
 ECHR 'U'
 ECHR 'F'
 ECHR 'T'
 EQUB VE

 EQUB VE                \ Token 96:     ""

 EQUB VE                \ Token 97:     ""

 EQUB VE                \ Token 98:     ""

 EQUB VE                \ Token 99:     ""

 EQUB VE                \ Token 100:    ""

 EQUB VE                \ Token 101:    ""

 EQUB VE                \ Token 102:    ""

 EQUB VE                \ Token 103:    ""

 EQUB VE                \ Token 104:    ""

 EQUB VE                \ Token 105:    ""

 EJMP 19                \ Token 106:    ""
 ETWO 'A', 'N'
 ETOK 187
 ETOK 183
 ETWO 'E', 'N'
 ECHR 'D'
 ECHR ' '
 ETWO 'E', 'R'
 ETOK 187
 ECHR 'I'
 ETWO 'E', 'N'
 ETOK 185
 ECHR 'G'
 ECHR 'R'
 ECHR 'I'
 ECHR 'M'
 ECHR 'M'
 ECHR 'I'
 ECHR 'G'
 ECHR ' '
 ECHR 'A'
 ETWO 'U', 'S'
 ETWO 'S', 'E'
 ECHR 'H'
 ETWO 'E', 'N'
 ECHR 'D'
 ETWO 'E', 'S'
 ETOK 182
 ECHR ' '
 ETWO 'I', 'N'
 ETOK 209
 EQUB VE

 EJMP 19                \ Token 107:    ""
 ECHR 'J'
 ECHR 'A'
 ECHR ','
 ETOK 185
 ECHR 'U'
 ECHR 'N'
 ECHR 'H'
 ECHR 'E'
 ECHR 'I'
 ECHR 'M'
 ECHR 'L'
 ETOK 186
 ETWO 'E', 'S'
 ETOK 182
 ECHR ' '
 ETWO 'S', 'O'
 ECHR 'L'
 ECHR 'L'
 ECHR ' '
 ETOK 157
 ECHR ' '
 ETOK 183
 ECHR 'I'
 ETWO 'G', 'E'
 ECHR 'R'
 EJMP 26
 ECHR 'Z'
 ECHR 'E'
 ETWO 'I', 'T'
 ECHR ' '
 ECHR 'V'
 ETWO 'O', 'N'
 ETOK 209
 ECHR ' '
 ETWO 'A', 'B'
 ETWO 'G', 'E'
 ECHR 'F'
 ETWO 'L', 'O'
 ETWO 'G', 'E'
 ECHR 'N'
 ECHR ' '
 ETWO 'S', 'E'
 ETWO 'I', 'N'
 EQUB VE

 EJMP 19                \ Token 108:    ""
 ETWO 'S', 'E'
 ETOK 158
 ETWO 'E', 'N'
 ETOK 179
 EJMP 26
 ECHR 'I'
 ECHR 'H'
 ECHR 'R'
 ECHR ' '
 ETWO 'D', 'I'
 ECHR 'C'
 ECHR 'K'
 ETWO 'E', 'S'
 EJMP 26
 ECHR 'F'
 ECHR 'E'
 ECHR 'L'
 ECHR 'L'
 ECHR ' '
 ETWO 'I', 'N'
 EJMP 26
 ETWO 'B', 'E'
 ECHR 'W'
 ECHR 'E'
 ECHR 'G'
 ECHR 'U'
 ECHR 'N'
 ECHR 'G'
 ECHR ' '
 ECHR 'N'
 ETOK 164
 ETOK 209
 EQUB VE

 ETOK 183               \ Token 109:    ""
 ECHR ' '
 ERND 24
 ECHR ' '
 ECHR 'V'
 ETWO 'O', 'N'
 ECHR ' '
 ETOK 183
 ECHR 'E'
 ECHR 'M'
 ECHR ' '
 ECHR 'N'
 ECHR 'E'
 ECHR 'U'
 ETWO 'E', 'N'
 ETOK 182
 ECHR ' '
 ECHR 'W'
 ECHR 'U'
 ECHR 'R'
 ECHR 'D'
 ECHR 'E'
 ETOK 188
 ECHR 'D'
 ETWO 'E', 'R'
 EJMP 26
 ECHR 'N'
 ERND 0
 ECHR 'H'
 ECHR 'E'
 ECHR ' '
 ECHR 'V'
 ETWO 'O', 'N'
 ETOK 209
 ECHR ' '
 ETWO 'G', 'E'
 ETWO 'S', 'E'
 ECHR 'H'
 ETWO 'E', 'N'
 EQUB VE

 ECHR 'F'               \ Token 110:    ""
 ECHR 'A'
 ECHR 'H'
 ETWO 'R', 'E'
 ECHR 'N'
 ETOK 179
 ECHR ' '
 ECHR 'N'
 ETOK 164
 ETOK 209
 EQUB VE

 ECHR ' '               \ Token 111:    ""
 ECHR 'K'
 ETWO 'N', 'U'
 ECHR 'D'
 ECHR 'D'
 ECHR 'E'
 ECHR 'L'
 ECHR 'I'
 ECHR 'G'
 EQUB VE

 ECHR ' '               \ Token 112:    ""
 ECHR 'N'
 ECHR 'I'
 ETWO 'E', 'D'
 ECHR 'L'
 ETOK 186
 EQUB VE

 ECHR ' '               \ Token 113:    ""
 ECHR 'P'
 ECHR 'U'
 ETOK 158
 ECHR 'I'
 ECHR 'G'
 EQUB VE

 ECHR ' '               \ Token 114:    ""
 ECHR 'F'
 ETWO 'R', 'E'
 ECHR 'U'
 ECHR 'N'
 ECHR 'D'
 ECHR 'L'
 ETOK 186
 EQUB VE

 EQUB VE                \ Token 115:    ""

 EQUB VE                \ Token 116:    ""

 EQUB VE                \ Token 117:    ""

 EQUB VE                \ Token 118:    ""

 EQUB VE                \ Token 119:    ""

 EQUB VE                \ Token 120:    ""

 EQUB VE                \ Token 121:    ""

 EQUB VE                \ Token 122:    ""

 EQUB VE                \ Token 123:    ""

 EQUB VE                \ Token 124:    ""

 EQUB VE                \ Token 125:    ""

 EQUB VE                \ Token 126:    ""

 EQUB VE                \ Token 127:    ""

 EQUB VE                \ Token 128:    ""

 EQUB VE                \ Token 129:    ""

 EQUB VE                \ Token 130:    ""

 EQUB VE                \ Token 131:    ""

 EQUB VE                \ Token 132:    ""

 EQUB VE                \ Token 133:    ""

 EQUB VE                \ Token 134:    ""

 EQUB VE                \ Token 135:    ""

 EQUB VE                \ Token 136:    ""

 EQUB VE                \ Token 137:    ""

 EQUB VE                \ Token 138:    ""

 EQUB VE                \ Token 139:    ""

 EQUB VE                \ Token 140:    ""

 EQUB VE                \ Token 141:    ""

 EQUB VE                \ Token 142:    ""

 EQUB VE                \ Token 143:    ""

 EQUB VE                \ Token 144:    ""

 EJMP 19                \ Token 145:    ""
 ECHR 'P'
 ETWO 'L', 'A'
 ECHR 'N'
 ETWO 'E', 'T'
 EQUB VE

 EJMP 19                \ Token 146:    ""
 ECHR 'W'
 ECHR 'E'
 ECHR 'L'
 ECHR 'T'
 EQUB VE

 ETWO 'D', 'I'          \ Token 147:    ""
 ECHR 'E'
 ECHR ' '
 EQUB VE

 ETWO 'D', 'I'          \ Token 148:    ""
 ECHR 'E'
 ETWO 'S', 'E'
 ECHR ' '
 EQUB VE

 EQUB VE                \ Token 149:    ""

 EJMP 9                 \ Token 150:    ""
 EJMP 11
 EJMP 1
 EJMP 8
 EQUB VE

 EQUB VE                \ Token 151:    ""

 EQUB VE                \ Token 152:    ""

 ECHR 'I'               \ Token 153:    ""
 ETWO 'A', 'N'
 EQUB VE

 EJMP 19                \ Token 154:    ""
 ECHR 'K'
 ECHR 'O'
 ECHR 'M'
 ETWO 'M', 'A'
 ECHR 'N'
 ECHR 'D'
 ETWO 'A', 'N'
 ECHR 'T'
 EQUB VE

 ECHR 'D'               \ Token 155:    ""
 ETWO 'E', 'R'
 ECHR ' '
 EQUB VE

 ECHR 'D'               \ Token 156:    ""
 ECHR 'A'
 ECHR 'S'
 ECHR ' '
 EQUB VE

 ECHR 'V'               \ Token 157:    ""
 ETWO 'O', 'R'
 EQUB VE

 ECHR 'T'               \ Token 158:    ""
 ECHR 'Z'
 EQUB VE

 ECHR 'Z'               \ Token 159:    ""
 ECHR 'U'
 EQUB VE

 ECHR ' '               \ Token 160:    ""
 ETOK 159
 ECHR ' '
 EQUB VE

 ECHR ' '               \ Token 161:    ""
 ETWO 'E', 'S'
 ECHR ' '
 EQUB VE

 ECHR 'N'               \ Token 162:    ""
 ETOK 186
 ECHR 'T'
 EQUB VE

 ECHR 'M'               \ Token 163:    ""
 ETWO 'A', 'R'
 ETWO 'I', 'N'
 ECHR 'E'
 EQUB VE

 ECHR 'A'               \ Token 164:    ""
 ECHR 'C'
 ECHR 'H'
 EQUB VE

 EQUB VE                \ Token 165:    ""

 EQUB VE                \ Token 166:    ""

 EQUB VE                \ Token 167:    ""

 EQUB VE                \ Token 168:    ""

 EQUB VE                \ Token 169:    ""

 EQUB VE                \ Token 170:    ""

 EQUB VE                \ Token 171:    ""

 EQUB VE                \ Token 172:    ""

 EQUB VE                \ Token 173:    ""

 EQUB VE                \ Token 174:    ""

 ETWO 'I', 'T'          \ Token 175:    ""
 ECHR 'S'
 ECHR ' '
 EQUB VE

 EJMP 13                \ Token 176:    ""
 EJMP 14
 EJMP 19
 EQUB VE

 ECHR '.'               \ Token 177:    ""
 EJMP 12
 EJMP 15
 EQUB VE

 ECHR ' '               \ Token 178:    ""
 ECHR 'U'
 ECHR 'N'
 ECHR 'D'
 ECHR ' '
 EQUB VE

 EJMP 26                \ Token 179:    ""
 ECHR 'S'
 ECHR 'I'
 ECHR 'E'
 EQUB VE

 ECHR ' '               \ Token 180:    ""
 ECHR 'N'
 ETOK 164
 ECHR ' '
 EQUB VE

 ECHR ' '               \ Token 181:    ""
 ECHR 'I'
 ETWO 'S', 'T'
 ECHR ' '
 EQUB VE

 EJMP 26                \ Token 182:    ""
 ETOK 187
 ECHR 'I'
 ECHR 'F'
 ECHR 'F'
 EQUB VE

 ECHR 'E'               \ Token 183:    ""
 ETWO 'I', 'N'
 EQUB VE

 ECHR ' '               \ Token 184:    ""
 ECHR 'N'
 ECHR 'E'
 ECHR 'U'
 ETWO 'E', 'S'
 ECHR ' '
 EQUB VE

 ECHR ' '               \ Token 185:    ""
 ETOK 183
 ECHR ' '
 EQUB VE

 ECHR 'I'               \ Token 186:    ""
 ECHR 'C'
 ECHR 'H'
 EQUB VE

 ECHR 'S'               \ Token 187:    ""
 ECHR 'C'
 ECHR 'H'
 EQUB VE

 ECHR ' '               \ Token 188:    ""
 ETWO 'I', 'N'
 ECHR ' '
 EQUB VE

 EQUB VE                \ Token 189:    ""

 EQUB VE                \ Token 190:    ""

 EQUB VE                \ Token 191:    ""

 EQUB VE                \ Token 192:    ""

 EQUB VE                \ Token 193:    ""

 EQUB VE                \ Token 194:    ""

 ETWO 'I', 'N'          \ Token 195:    ""
 ECHR 'G'
 ECHR ' '
 EQUB VE

 ETWO 'E', 'D'          \ Token 196:    ""
 ECHR ' '
 EQUB VE

 EQUB VE                \ Token 197:    ""

 EJMP 26                \ Token 198:    ""
 ECHR 'S'
 ETWO 'Q', 'U'
 ECHR 'E'
 ECHR 'A'
 ECHR 'K'
 ECHR 'Y'
 EQUB VE

 EJMP 25                \ Token 199:    ""
 EJMP 9
 EJMP 29
 EJMP 14
 EJMP 13
 EJMP 26
 ECHR 'G'
 ECHR 'U'
 ECHR 'T'
 ETWO 'E', 'N'
 EJMP 26
 ECHR 'T'
 ECHR 'A'
 ECHR 'G'
 EJMP 26
 ECHR 'K'
 ECHR 'O'
 ECHR 'M'
 ETWO 'M', 'A'
 ECHR 'N'
 ECHR 'D'
 ETWO 'A', 'N'
 ECHR 'T'
 ECHR '.'
 EJMP 26
 ECHR 'D'
 ETWO 'A', 'R'
 ECHR 'F'
 ECHR ' '
 ETOK 186
 ECHR ' '
 ECHR 'M'
 ETOK 186
 ECHR ' '
 ETOK 157
 ETWO 'S', 'T'
 ECHR 'E'
 ECHR 'L'
 ETWO 'L', 'E'
 ECHR 'N'
 ECHR '?'
 EJMP 26
 ETOK 186
 ECHR ' '
 ETWO 'B', 'I'
 ECHR 'N'
 ECHR ' '
 ECHR 'D'
 ETWO 'E', 'R'
 EJMP 26
 ECHR 'P'
 ECHR 'R'
 ETWO 'I', 'N'
 ECHR 'Z'
 ECHR ' '
 ECHR 'V'
 ETWO 'O', 'N'
 EJMP 26
 ETWO 'T', 'H'
 ECHR 'R'
 ECHR 'U'
 ECHR 'N'
 ECHR '.'
 EJMP 26
 ETOK 186
 ECHR ' '
 ETWO 'S', 'E'
 ECHR 'H'
 ECHR 'E'
 ECHR ' '
 ECHR 'M'
 ETOK 186
 ECHR ' '
 ETWO 'L', 'E'
 ECHR 'I'
 ETOK 155
 ETWO 'G', 'E'
 ECHR 'Z'
 ECHR 'W'
 ECHR 'U'
 ECHR 'N'
 ETWO 'G', 'E'
 ECHR 'N'
 ECHR ','
 ECHR ' '
 ECHR 'M'
 ETOK 183
 ETWO 'E', 'N'
 ECHR ' '
 ECHR 'L'
 ECHR 'I'
 ECHR 'E'
 ECHR 'B'
 ETWO 'S', 'T'
 ETWO 'E', 'N'
 EJMP 26
 ECHR 'B'
 ETWO 'E', 'S'
 ETWO 'I', 'T'
 ECHR 'Z'
 ETOK 160
 ECHR 'V'
 ETWO 'E', 'R'
 ERND 0
 ECHR 'U'
 ERND 3
 ETWO 'E', 'R'
 ECHR 'N'
 ETOK 204
 EJMP 19
 ECHR 'F'
 ERND 2
 ECHR 'R'
 ECHR ' '
 ETWO 'D', 'I'
 ECHR 'E'
 EJMP 26
 ECHR 'K'
 ETWO 'L', 'E'
 ETWO 'I', 'N'
 ECHR 'I'
 ECHR 'G'
 ECHR 'K'
 ECHR 'E'
 ETWO 'I', 'T'
 ECHR ' '
 ECHR 'V'
 ETWO 'O', 'N'
 ECHR ' '
 ECHR '5'
 ECHR '0'
 ECHR '0'
 ECHR '0'
 EJMP 19
 ECHR 'C'
 ECHR 'R'
 ECHR ' '
 ETWO 'B', 'I'
 ETWO 'E', 'T'
 ECHR 'E'
 ECHR ' '
 ETOK 186
 EJMP 26
 ECHR 'I'
 ECHR 'H'
 ECHR 'N'
 ETWO 'E', 'N'
 ECHR ' '
 ECHR 'D'
 ECHR 'A'
 ECHR 'S'
 EJMP 26
 ETWO 'S', 'E'
 ECHR 'L'
 ECHR 'T'
 ETWO 'E', 'N'
 ETWO 'S', 'T'
 ECHR 'E'
 ECHR ' '
 ECHR 'D'
 ETWO 'E', 'S'
 EJMP 26
 ECHR 'U'
 ECHR 'N'
 ECHR 'I'
 ECHR 'V'
 ETWO 'E', 'R'
 ECHR 'S'
 ECHR 'U'
 ECHR 'M'
 ECHR 'S'
 ECHR ' '
 ETWO 'A', 'N'
 ETOK 204
 EJMP 19
 ECHR 'N'
 ECHR 'E'
 ECHR 'H'
 ECHR 'M'
 ETWO 'E', 'N'
 ETOK 179
 ECHR ' '
 ETWO 'E', 'S'
 ECHR '?'
 EJMP 12
 EJMP 15
 EJMP 1
 EJMP 8
 EQUB VE

 EJMP 26                \ Token 200:    ""
 ECHR 'N'
 ECHR 'A'
 ECHR 'M'
 ECHR 'E'
 ECHR '?'
 ECHR ' '
 EQUB VE

 EQUB VE                \ Token 201:    ""

 EQUB VE                \ Token 202:    ""

 ECHR 'W'               \ Token 203:    ""
 ECHR 'U'
 ECHR 'R'
 ECHR 'D'
 ECHR 'E'
 ECHR ' '
 ETOK 159
 ECHR 'L'
 ETWO 'E', 'T'
 ECHR 'Z'
 ECHR 'T'
 ECHR ' '
 ETWO 'G', 'E'
 ETWO 'S', 'E'
 ECHR 'H'
 ETWO 'E', 'N'
 ETOK 188
 EJMP 19
 ECHR ' '
 EQUB VE

 ECHR '.'               \ Token 204:    ""
 EJMP 12
 EJMP 12
 ECHR ' '
 EJMP 19
 EQUB VE

 EJMP 19                \ Token 205:    ""
 ETWO 'G', 'E'
 ECHR 'D'
 ECHR 'O'
 ECHR 'C'
 ECHR 'K'
 ECHR 'T'
 EQUB VE

 EQUB VE                \ Token 206:    ""

 EQUB VE                \ Token 207:    ""

 EQUB VE                \ Token 208:    ""

 EJMP 26                \ Token 209:    ""
 ETWO 'E', 'R'
 ECHR 'R'
 ECHR 'I'
 ETWO 'U', 'S'
 EQUB VE

 EQUB VE                \ Token 210:    ""

 EJMP 26                \ Token 211:    ""
 ETWO 'R', 'A'
 ECHR 'U'
 ECHR 'M'
 ECHR 'F'
 ECHR 'A'
 ECHR 'H'
 ECHR 'R'
 ECHR 'T'
 ETOK 163
 ECHR ' '
 ECHR 'U'
 ECHR 'N'
 ETWO 'S', 'E'
 ETWO 'R', 'E'
 ECHR 'R'
 EJMP 26
 ETWO 'M', 'A'
 ECHR 'J'
 ECHR 'E'
 ETWO 'S', 'T'
 ERND 0
 ECHR 'T'
 EQUB VE

 ETOK 177               \ Token 212:    ""
 EJMP 12
 EJMP 8
 EJMP 1
 EJMP 26
 ETWO 'E', 'N'
 ECHR 'D'
 ECHR 'E'
 ECHR ' '
 ECHR 'D'
 ETWO 'E', 'R'
 EJMP 26
 ECHR 'N'
 ETOK 164
 ECHR 'R'
 ETOK 186
 ECHR 'T'
 EQUB VE

 ECHR ' '               \ Token 213:    ""
 ETOK 154
 ECHR ' '
 EJMP 4
 ECHR '.'
 EJMP 26
 ETOK 186
 ECHR ' '
 EJMP 13
 ETWO 'B', 'I'
 ECHR 'N'
 EJMP 26
 ECHR 'K'
 ECHR 'A'
 ECHR 'P'
 ETWO 'I', 'T'
 ERND 0
 ECHR 'N'
 ECHR ' '
 EJMP 27
 ECHR ' '
 ECHR 'D'
 ETWO 'E', 'R'
 ETOK 211
 EQUB VE

 EQUB VE                \ Token 214:    ""

 EJMP 15                \ Token 215:    ""
 EJMP 26
 ECHR 'U'
 ECHR 'N'
 ETWO 'B', 'E'
 ECHR 'K'
 ETWO 'A', 'N'
 ECHR 'N'
 ECHR 'T'
 ETWO 'E', 'R'
 EJMP 26
 ECHR 'P'
 ETWO 'L', 'A'
 ECHR 'N'
 ETWO 'E', 'T'
 EQUB VE

 EJMP 9                 \ Token 216:    ""
 EJMP 8
 EJMP 23
 EJMP 1
 ETWO 'A', 'N'
 ECHR 'K'
 ECHR 'O'
 ECHR 'M'
 ECHR 'M'
 ETWO 'E', 'N'
 ECHR 'D'
 ECHR 'E'
 EJMP 26
 ECHR 'N'
 ETOK 164
 ECHR 'R'
 ETOK 186
 ECHR 'T'
 EQUB VE

 EJMP 19                \ Token 217:    ""
 ECHR 'R'
 ETOK 186
 ECHR 'T'
 ECHR 'O'
 ECHR 'F'
 ETWO 'E', 'N'
 EQUB VE

 EJMP 19                \ Token 218:    ""
 ECHR 'V'
 ETWO 'A', 'N'
 ECHR 'D'
 ETWO 'E', 'R'
 ECHR 'B'
 ETWO 'I', 'L'
 ECHR 'T'
 EQUB VE

 EJMP 19                \ Token 219:    ""
 ECHR 'H'
 ETWO 'A', 'B'
 ECHR 'S'
 ECHR 'B'
 ECHR 'U'
 ECHR 'R'
 ECHR 'G'
 EQUB VE

 ETOK 203               \ Token 220:    ""
 EJMP 19
 ETWO 'R', 'E'
 ETWO 'E', 'S'
 ETWO 'D', 'I'
 ETWO 'C', 'E'
 EQUB VE

 ETWO 'S', 'O'          \ Token 221:    ""
 ECHR 'L'
 ETWO 'L', 'E'
 ECHR 'N'
 ETOK 188
 ETWO 'D', 'I'
 ECHR 'E'
 ETWO 'S', 'E'
 EJMP 26
 ECHR 'G'
 ETWO 'A', 'L'
 ECHR 'A'
 ECHR 'X'
 ECHR 'I'
 ECHR 'E'
 ECHR ' '
 ETWO 'G', 'E'
 ECHR 'S'
 ECHR 'P'
 ECHR 'R'
 ECHR 'U'
 ECHR 'N'
 ETWO 'G', 'E'
 ECHR 'N'
 ECHR ' '
 ETWO 'S', 'E'
 ETWO 'I', 'N'
 EQUB VE

 EJMP 25                \ Token 222:    ""
 EJMP 9
 EJMP 29
 EJMP 14
 EJMP 13
 EJMP 26
 ECHR 'G'
 ECHR 'U'
 ECHR 'T'
 ETWO 'E', 'N'
 EJMP 26
 ECHR 'T'
 ECHR 'A'
 ECHR 'G'
 EJMP 26
 ECHR 'K'
 ECHR 'O'
 ECHR 'M'
 ETWO 'M', 'A'
 ECHR 'N'
 ECHR 'D'
 ETWO 'A', 'N'
 ECHR 'T'
 ETOK 204
 EJMP 19
 ETOK 186
 ECHR ' '
 ETWO 'B', 'I'
 ECHR 'N'
 EJMP 26
 ECHR 'A'
 ETWO 'G', 'E'
 ECHR 'N'
 ECHR 'T'
 EJMP 26
 ECHR 'B'
 ETWO 'L', 'A'
 ECHR 'K'
 ECHR 'E'
 ECHR ' '
 ECHR 'D'
 ETWO 'E', 'S'
 EJMP 26
 ETWO 'G', 'E'
 ECHR 'H'
 ECHR 'E'
 ECHR 'I'
 ECHR 'M'
 ETWO 'D', 'I'
 ETWO 'E', 'N'
 ETWO 'S', 'T'
 ETWO 'E', 'S'
 ECHR ' '
 ECHR 'D'
 ETWO 'E', 'R'
 EJMP 26
 ETOK 163
 ETOK 204
 EJMP 19
 ECHR 'W'
 ECHR 'I'
 ECHR 'E'
 ETOK 179
 ECHR ' '
 ECHR 'W'
 ECHR 'I'
 ECHR 'S'
 ETWO 'S', 'E'
 ECHR 'N'
 ECHR ','
 ECHR ' '
 ECHR 'H'
 ETWO 'A', 'T'
 ECHR ' '
 ETWO 'D', 'I'
 ECHR 'E'
 EJMP 26
 ETOK 163
 ECHR ' '
 ETWO 'D', 'I'
 ECHR 'E'
 EJMP 26
 ETWO 'T', 'H'
 ETWO 'A', 'R'
 ECHR 'G'
 ECHR 'O'
 ECHR 'I'
 ECHR 'D'
 ECHR 'S'
 ECHR ' '
 ETWO 'S', 'E'
 ETWO 'I', 'T'
 ECHR ' '
 ECHR 'V'
 ECHR 'I'
 ECHR 'E'
 ETWO 'L', 'E'
 ECHR 'N'
 EJMP 26
 ECHR 'J'
 ECHR 'A'
 ECHR 'H'
 ETWO 'R', 'E'
 ECHR 'N'
 ECHR ' '
 ECHR 'W'
 ECHR 'E'
 ETWO 'I', 'T'
 ECHR ' '
 ECHR 'W'
 ECHR 'E'
 ECHR 'G'
 ECHR ' '
 ECHR 'V'
 ETWO 'O', 'N'
 EJMP 26
 ECHR 'I'
 ECHR 'H'
 ECHR 'N'
 ETWO 'E', 'N'
 ECHR ' '
 ECHR 'I'
 ECHR 'M'
 ECHR ' '
 ETWO 'T', 'I'
 ECHR 'E'
 ECHR 'F'
 ETWO 'S', 'T'
 ETWO 'E', 'N'
 EJMP 26
 ECHR 'W'
 ECHR 'E'
 ECHR 'L'
 ECHR 'T'
 ETWO 'R', 'A'
 ECHR 'U'
 ECHR 'M'
 ECHR ' '
 ETWO 'G', 'E'
 ECHR 'H'
 ETWO 'A', 'L'
 ECHR 'T'
 ETWO 'E', 'N'
 ECHR '.'
 EJMP 26
 ECHR 'J'
 ETWO 'E', 'T'
 ECHR 'Z'
 ECHR 'T'
 ECHR ' '
 ETWO 'A', 'B'
 ETWO 'E', 'R'
 ECHR ' '
 ECHR 'H'
 ETWO 'A', 'T'
 ECHR ' '
 ETWO 'D', 'I'
 ECHR 'E'
 EJMP 26
 ETWO 'L', 'A'
 ETWO 'G', 'E'
 ECHR ' '
 ECHR 'S'
 ETOK 186
 ECHR ' '
 ETWO 'G', 'E'
 ERND 0
 ECHR 'N'
 ECHR 'D'
 ETWO 'E', 'R'
 ECHR 'T'
 ETOK 204
 EJMP 19
 ECHR 'U'
 ECHR 'N'
 ETWO 'S', 'E'
 ETWO 'R', 'E'
 EJMP 26
 ECHR 'J'
 ECHR 'U'
 ECHR 'N'
 ECHR 'G'
 ECHR 'S'
 ECHR ' '
 ECHR 'S'
 ETWO 'I', 'N'
 ECHR 'D'
 ECHR ' '
 ETWO 'B', 'E'
 ETWO 'R', 'E'
 ETWO 'I', 'T'
 ECHR ','
 ECHR ' '
 ETWO 'B', 'I'
 ECHR 'S'
 ECHR ' '
 ETWO 'I', 'N'
 ECHR 'S'
 EJMP 26
 ETWO 'G', 'E'
 ECHR 'H'
 ECHR 'E'
 ECHR 'I'
 ECHR 'M'
 ECHR 'S'
 ECHR 'Y'
 ETWO 'S', 'T'
 ECHR 'E'
 ECHR 'M'
 ECHR ' '
 ECHR 'D'
 ETWO 'E', 'R'
 EJMP 26
 ECHR 'M'
 ERND 1
 ECHR 'R'
 ETOK 155
 ETOK 157
 ETOK 159
 ETWO 'S', 'T'
 ECHR 'O'
 ERND 3
 ETWO 'E', 'N'
 ETOK 204
 EJMP 24
 EJMP 9
 EJMP 29
 ETWO 'D', 'I'
 ECHR 'E'
 EJMP 26
 ECHR 'V'
 ETWO 'E', 'R'
 ECHR 'T'
 ECHR 'E'
 ECHR 'I'
 ETWO 'D', 'I'
 ECHR 'G'
 ECHR 'U'
 ECHR 'N'
 ECHR 'G'
 ECHR 'S'
 ECHR 'P'
 ECHR 'L'
 ERND 0
 ECHR 'N'
 ECHR 'E'
 ECHR ' '
 ECHR 'D'
 ETWO 'E', 'R'
 EJMP 26
 ECHR 'H'
 ECHR 'I'
 ETWO 'V', 'E'
 EJMP 26
 ECHR 'W'
 ECHR 'E'
 ECHR 'L'
 ECHR 'T'
 ECHR ' '
 ECHR 'H'
 ETWO 'A', 'B'
 ECHR 'E'
 ECHR ' '
 ETOK 186
 ECHR ' '
 ETWO 'E', 'R'
 ECHR 'H'
 ETWO 'A', 'L'
 ECHR 'T'
 ETWO 'E', 'N'
 ETOK 204
 EJMP 19
 ETWO 'D', 'I'
 ECHR 'E'
 EJMP 26
 ECHR 'K'
 ERND 0
 ECHR 'F'
 ETWO 'E', 'R'
 ECHR ' '
 ECHR 'W'
 ECHR 'I'
 ECHR 'S'
 ETWO 'S', 'E'
 ECHR 'N'
 ECHR ','
 ECHR ' '
 ECHR 'D'
 ECHR 'A'
 ERND 3
 ECHR ' '
 ECHR 'W'
 ECHR 'I'
 ECHR 'R'
 ECHR ' '
 ETWO 'E', 'T'
 ECHR 'W'
 ECHR 'A'
 ECHR 'S'
 ECHR ' '
 ECHR 'H'
 ETWO 'A', 'B'
 ETWO 'E', 'N'
 ECHR ','
 ECHR ' '
 ETWO 'A', 'B'
 ETWO 'E', 'R'
 ECHR ' '
 ETOK 162
 ECHR ' '
 ETWO 'G', 'E'
 ECHR 'N'
 ECHR 'A'
 ECHR 'U'
 ECHR ' '
 ECHR 'W'
 ECHR 'A'
 ECHR 'S'
 ETOK 204
 EJMP 19
 ECHR 'W'
 ETWO 'E', 'N'
 ECHR 'N'
 ECHR ' '
 ETOK 186
 ECHR ' '
 ETWO 'D', 'I'
 ECHR 'E'
 EJMP 26
 ECHR 'P'
 ECHR 'L'
 ERND 0
 ECHR 'N'
 ECHR 'E'
 ETOK 180
 ECHR 'U'
 ECHR 'N'
 ETWO 'S', 'E'
 ETWO 'R', 'E'
 ECHR 'R'
 EJMP 26
 ECHR 'B'
 ECHR 'A'
 ECHR 'S'
 ECHR 'I'
 ECHR 'S'
 ECHR ' '
 ECHR 'A'
 ECHR 'U'
 ECHR 'F'
 EJMP 26
 ETWO 'B', 'I'
 ETWO 'R', 'E'
 ETWO 'R', 'A'
 ECHR ' '
 ETWO 'S', 'E'
 ECHR 'N'
 ECHR 'D'
 ECHR 'E'
 ECHR ','
 ECHR ' '
 ECHR 'W'
 ETWO 'E', 'R'
 ECHR 'D'
 ETWO 'E', 'N'
 ECHR ' '
 ETWO 'D', 'I'
 ECHR 'E'
 EJMP 26
 ECHR 'K'
 ERND 0
 ECHR 'F'
 ETWO 'E', 'R'
 ECHR ' '
 ECHR 'S'
 ECHR 'I'
 ECHR 'E'
 ECHR ' '
 ETWO 'A', 'B'
 ECHR 'F'
 ETWO 'A', 'N'
 ETWO 'G', 'E'
 ECHR 'N'
 ECHR '.'
 EJMP 26
 ETOK 186
 ECHR ' '
 ECHR 'B'
 ETWO 'R', 'A'
 ECHR 'U'
 ECHR 'C'
 ECHR 'H'
 ECHR 'E'
 ECHR ' '
 ETOK 183
 ETOK 182
 ECHR ','
 ECHR ' '
 ECHR 'U'
 ECHR 'M'
 ECHR ' '
 ETWO 'D', 'I'
 ECHR 'E'
 EJMP 26
 ECHR 'N'
 ETOK 164
 ECHR 'R'
 ETOK 186
 ECHR 'T'
 ETOK 160
 ERND 2
 ECHR 'B'
 ETWO 'E', 'R'
 ECHR 'B'
 ECHR 'R'
 ETWO 'I', 'N'
 ETWO 'G', 'E'
 ECHR 'N'
 ETOK 204
 EJMP 19
 ECHR 'S'
 ECHR 'I'
 ECHR 'E'
 ECHR ' '
 ECHR 'W'
 ETWO 'E', 'R'
 ECHR 'D'
 ETWO 'E', 'N'
 ECHR ' '
 ECHR 'D'
 ECHR 'A'
 ETOK 159
 ECHR ' '
 ECHR 'A'
 ECHR 'U'
 ETWO 'S', 'E'
 ECHR 'R'
 ECHR 'W'
 ERND 0
 ECHR 'H'
 ECHR 'L'
 ECHR 'T'
 ETOK 204
 EJMP 24
 EJMP 9
 EJMP 29
 ETWO 'D', 'I'
 ECHR 'E'
 EJMP 26
 ECHR 'P'
 ECHR 'L'
 ERND 0
 ECHR 'N'
 ECHR 'E'
 ECHR ' '
 ECHR 'S'
 ETWO 'I', 'N'
 ECHR 'D'
 ETOK 188
 ETWO 'D', 'I'
 ECHR 'E'
 ETWO 'S', 'E'
 ECHR 'R'
 EJMP 26
 ETWO 'S', 'E'
 ECHR 'N'
 ECHR 'D'
 ECHR 'U'
 ECHR 'N'
 ECHR 'G'
 ECHR ' '
 ETWO 'I', 'N'
 EJMP 26
 ECHR 'U'
 ECHR 'N'
 ECHR 'I'
 EJMP 19
 ECHR 'P'
 ECHR 'U'
 ECHR 'L'
 ETWO 'S', 'E'
 ECHR ' '
 ECHR 'K'
 ECHR 'O'
 ETWO 'D', 'I'
 ETWO 'E', 'R'
 ECHR 'T'
 ETOK 204
 EJMP 19
 ECHR 'S'
 ECHR 'I'
 ECHR 'E'
 ECHR ' '
 ECHR 'W'
 ETWO 'E', 'R'
 ECHR 'D'
 ETWO 'E', 'N'
 ECHR ' '
 ECHR 'D'
 ECHR 'A'
 ECHR 'F'
 ERND 2
 ECHR 'R'
 ECHR ' '
 ETWO 'B', 'E'
 ETWO 'Z', 'A'
 ECHR 'H'
 ECHR 'L'
 ECHR 'T'
 ETOK 204
 EJMP 19
 ECHR 'V'
 ECHR 'I'
 ECHR 'E'
 ECHR 'L'
 EJMP 26
 ECHR 'G'
 ECHR 'L'
 ERND 2
 ECHR 'C'
 ECHR 'K'
 ECHR ' '
 ETOK 154
 ETOK 212
 EJMP 24
 EQUB VE

 EJMP 25                \ Token 223:    ""
 EJMP 9
 EJMP 29
 EJMP 14
 EJMP 13
 EJMP 26
 ECHR 'G'
 ECHR 'U'
 ECHR 'T'
 ECHR ' '
 ETWO 'G', 'E'
 ETWO 'M', 'A'
 ECHR 'C'
 ECHR 'H'
 ECHR 'T'
 ECHR ' '
 ETOK 154
 ETOK 204
 EJMP 19
 ECHR 'S'
 ECHR 'I'
 ECHR 'E'
 ECHR ' '
 ECHR 'H'
 ETWO 'A', 'B'
 ETWO 'E', 'N'
 ECHR ' '
 ECHR 'U'
 ECHR 'N'
 ECHR 'S'
 ECHR ' '
 ECHR 'F'
 ETWO 'L', 'E'
 ECHR 'I'
 ERND 3
 ECHR 'I'
 ECHR 'G'
 ECHR ' '
 ETWO 'G', 'E'
 ETWO 'D', 'I'
 ETWO 'E', 'N'
 ECHR 'T'
 ECHR ','
 ETOK 178
 ECHR 'W'
 ECHR 'I'
 ECHR 'R'
 ECHR ' '
 ECHR 'W'
 ETWO 'E', 'R'
 ECHR 'D'
 ETWO 'E', 'N'
 ETOK 161
 ETOK 162
 ECHR ' '
 ECHR 'V'
 ETWO 'E', 'R'
 ETWO 'G', 'E'
 ECHR 'S'
 ETWO 'S', 'E'
 ECHR 'N'
 ETOK 204
 EJMP 19
 ECHR 'W'
 ECHR 'I'
 ECHR 'R'
 ECHR ' '
 ECHR 'H'
 ETWO 'A', 'B'
 ETWO 'E', 'N'
 ECHR ' '
 ETOK 162
 ECHR ' '
 ETWO 'E', 'R'
 ECHR 'W'
 ETWO 'A', 'R'
 ECHR 'T'
 ETWO 'E', 'T'
 ECHR ','
 ECHR ' '
 ECHR 'D'
 ECHR 'A'
 ERND 3
 ECHR ' '
 ETWO 'D', 'I'
 ECHR 'E'
 EJMP 26
 ETWO 'T', 'H'
 ETWO 'A', 'R'
 ECHR 'G'
 ECHR 'O'
 ECHR 'I'
 ECHR 'D'
 ECHR 'S'
 ECHR ' '
 ERND 2
 ECHR 'B'
 ETWO 'E', 'R'
 ETOK 179
 EJMP 26
 ECHR 'B'
 ETWO 'E', 'S'
 ECHR 'C'
 ECHR 'H'
 ECHR 'E'
 ECHR 'I'
 ECHR 'D'
 ECHR ' '
 ECHR 'W'
 ECHR 'U'
 ERND 3
 ECHR 'T'
 ETWO 'E', 'N'
 ETOK 204
 EJMP 19
 ECHR 'B'
 ETWO 'I', 'T'
 ECHR 'T'
 ECHR 'E'
 ECHR ' '
 ECHR 'A'
 ECHR 'K'
 ECHR 'Z'
 ECHR 'E'
 ECHR 'P'
 ETWO 'T', 'I'
 ECHR 'E'
 ETWO 'R', 'E'
 ECHR 'N'
 ETOK 179
 ECHR ' '
 ETWO 'D', 'I'
 ECHR 'E'
 ETWO 'S', 'E'
 EJMP 26
 ETWO 'E', 'N'
 ETWO 'E', 'R'
 ECHR 'G'
 ECHR 'I'
 ECHR 'E'
 ECHR '-'
 EJMP 19
 ETOK 183
 ECHR 'H'
 ECHR 'E'
 ETWO 'I', 'T'
 ECHR ' '
 ECHR 'D'
 ETWO 'E', 'R'
 EJMP 26
 ETOK 163
 ECHR ' '
 ETWO 'A', 'L'
 ECHR 'S'
 EJMP 26
 ETWO 'B', 'E'
 ETWO 'Z', 'A'
 ECHR 'H'
 ECHR 'L'
 ECHR 'U'
 ECHR 'N'
 ECHR 'G'
 ETOK 212
 EJMP 24
 EQUB VE

 EQUB VE                \ Token 224:    ""

 EQUB VE                \ Token 225:    ""

 EQUB VE                \ Token 226:    ""

 EQUB VE                \ Token 227:    ""

 EQUB VE                \ Token 228:    ""

 EQUB VE                \ Token 229:    ""

 EQUB VE                \ Token 230:    ""

 EQUB VE                \ Token 231:    ""

 EQUB VE                \ Token 232:    ""

 EQUB VE                \ Token 233:    ""

 EQUB VE                \ Token 234:    ""

 EQUB VE                \ Token 235:    ""

 EQUB VE                \ Token 236:    ""

 EQUB VE                \ Token 237:    ""

 EQUB VE                \ Token 238:    ""

 EQUB VE                \ Token 239:    ""

 EQUB VE                \ Token 240:    ""

 EQUB VE                \ Token 241:    ""

 EQUB VE                \ Token 242:    ""

 EQUB VE                \ Token 243:    ""

 EQUB VE                \ Token 244:    ""

 EQUB VE                \ Token 245:    ""

 EQUB VE                \ Token 246:    ""

 EQUB VE                \ Token 247:    ""

 EQUB VE                \ Token 248:    ""

 EQUB VE                \ Token 249:    ""

 EQUB VE                \ Token 250:    ""

 EQUB VE                \ Token 251:    ""

 EQUB VE                \ Token 252:    ""

 EQUB VE                \ Token 253:    ""

 EQUB VE                \ Token 254:    ""

 EQUB VE                \ Token 255:    ""

\ ******************************************************************************
\
\       Name: RUPLA_DE
\       Type: Variable
\   Category: Text
\    Summary: System numbers that have extended decription overrides (German)
\  Deep dive: Extended system descriptions
\             Extended text tokens
\
\ ------------------------------------------------------------------------------
\
\ This table contains the extended token numbers to show as the specified
\ system's extended description, if the criteria in the RUGAL_DE table are met.
\
\ The three variables work as follows:
\
\   * The RUPLA_DE table contains the system numbers
\
\   * The RUGAL_DE table contains the galaxy numbers and mission criteria
\
\   * The RUTOK_DE table contains the extended token to display instead of the
\     normal extended description if the criteria in RUPLA_DE and RUGAL_DE are
\     met
\
\ See the PDESC routine for details of how extended system descriptions work.
\
\ ******************************************************************************

.RUPLA_DE

 EQUB 211               \ System 211, Galaxy 0                 Teorge = Token  1
 EQUB 150               \ System 150, Galaxy 0, Mission 1        Xeer = Token  2
 EQUB 36                \ System  36, Galaxy 0, Mission 1    Reesdice = Token  3
 EQUB 28                \ System  28, Galaxy 0, Mission 1       Arexe = Token  4
 EQUB 253               \ System 253, Galaxy 1, Mission 1      Errius = Token  5
 EQUB 79                \ System  79, Galaxy 1, Mission 1      Inbibe = Token  6
 EQUB 53                \ System  53, Galaxy 1, Mission 1       Ausar = Token  7
 EQUB 118               \ System 118, Galaxy 1, Mission 1      Usleri = Token  8
 EQUB 32                \ System  32, Galaxy 1, Mission 1      Bebege = Token  9
 EQUB 68                \ System  68, Galaxy 1, Mission 1      Cearso = Token 10
 EQUB 164               \ System 164, Galaxy 1, Mission 1      Dicela = Token 11
 EQUB 220               \ System 220, Galaxy 1, Mission 1      Eringe = Token 12
 EQUB 106               \ System 106, Galaxy 1, Mission 1      Gexein = Token 13
 EQUB 16                \ System  16, Galaxy 1, Mission 1      Isarin = Token 14
 EQUB 162               \ System 162, Galaxy 1, Mission 1    Letibema = Token 15
 EQUB 3                 \ System   3, Galaxy 1, Mission 1      Maisso = Token 16
 EQUB 107               \ System 107, Galaxy 1, Mission 1        Onen = Token 17
 EQUB 26                \ System  26, Galaxy 1, Mission 1      Ramaza = Token 18
 EQUB 192               \ System 192, Galaxy 1, Mission 1      Sosole = Token 19
 EQUB 184               \ System 184, Galaxy 1, Mission 1      Tivere = Token 20
 EQUB 5                 \ System   5, Galaxy 1, Mission 1      Veriar = Token 21
 EQUB 101               \ System 101, Galaxy 2, Mission 1      Xeveon = Token 22
 EQUB 193               \ System 193, Galaxy 1, Mission 1      Orarra = Token 23

\ ******************************************************************************
\
\       Name: RUGAL_DE
\       Type: Variable
\   Category: Text
\    Summary: The criteria for systems with extended decription overrides
\             (German)
\  Deep dive: Extended system descriptions
\             Extended text tokens
\
\ ------------------------------------------------------------------------------
\
\ This table contains the criteria for printing an extended decription override
\ for a system. The galaxy number is in bits 0-6, while bit 7 determines whether
\ to show this token during mission 1 only (bit 7 is clear, i.e. a value of &0x
\ in the table below), or all of the time (bit 7 is set, i.e. a value of &8x in
\ the table below).
\
\ In other words, Teorge has an extended decription override description that is
\ always shown, while the rest only appear when mission 1 is in progress.
\
\ The three variables work as follows:
\
\   * The RUPLA_DE table contains the system numbers
\
\   * The RUGAL_DE table contains the galaxy numbers and mission criteria
\
\   * The RUTOK_DE table contains the extended token to display instead of the
\     normal extended description if the criteria in RUPLA_DE and RUGAL_DE are
\     met
\
\ See the PDESC routine for details of how extended system descriptions work.
\
\ ******************************************************************************

.RUGAL_DE

 EQUB &80               \ System 211, Galaxy 0                 Teorge = Token  1
 EQUB &00               \ System 150, Galaxy 0, Mission 1        Xeer = Token  2
 EQUB &00               \ System  36, Galaxy 0, Mission 1    Reesdice = Token  3
 EQUB &00               \ System  28, Galaxy 0, Mission 1       Arexe = Token  4
 EQUB &01               \ System 253, Galaxy 1, Mission 1      Errius = Token  5
 EQUB &01               \ System  79, Galaxy 1, Mission 1      Inbibe = Token  6
 EQUB &01               \ System  53, Galaxy 1, Mission 1       Ausar = Token  7
 EQUB &01               \ System 118, Galaxy 1, Mission 1      Usleri = Token  8
 EQUB &01               \ System  32, Galaxy 1, Mission 1      Bebege = Token  9
 EQUB &01               \ System  68, Galaxy 1, Mission 1      Cearso = Token 10
 EQUB &01               \ System 164, Galaxy 1, Mission 1      Dicela = Token 11
 EQUB &01               \ System 220, Galaxy 1, Mission 1      Eringe = Token 12
 EQUB &01               \ System 106, Galaxy 1, Mission 1      Gexein = Token 13
 EQUB &01               \ System  16, Galaxy 1, Mission 1      Isarin = Token 14
 EQUB &01               \ System 162, Galaxy 1, Mission 1    Letibema = Token 15
 EQUB &01               \ System   3, Galaxy 1, Mission 1      Maisso = Token 16
 EQUB &01               \ System 107, Galaxy 1, Mission 1        Onen = Token 17
 EQUB &01               \ System  26, Galaxy 1, Mission 1      Ramaza = Token 18
 EQUB &01               \ System 192, Galaxy 1, Mission 1      Sosole = Token 19
 EQUB &01               \ System 184, Galaxy 1, Mission 1      Tivere = Token 20
 EQUB &01               \ System   5, Galaxy 1, Mission 1      Veriar = Token 21
 EQUB &02               \ System 101, Galaxy 2, Mission 1      Xeveon = Token 22
 EQUB &01               \ System 193, Galaxy 1, Mission 1      Orarra = Token 23

\ ******************************************************************************
\
\       Name: RUTOK_DE
\       Type: Variable
\   Category: Text
\    Summary: The second extended token table for recursive tokens 0-26 (DETOK3)
\             (German)
\  Deep dive: Extended system descriptions
\             Extended text tokens
\
\ ------------------------------------------------------------------------------
\
\ Contains the tokens for extended description overrides of systems that match
\ the system number in RUPLA_DE and the conditions in RUGAL_DE.
\
\ The three variables work as follows:
\
\   * The RUPLA_DE table contains the system numbers
\
\   * The RUGAL_DE table contains the galaxy numbers and mission criteria
\
\   * The RUTOK_DE table contains the extended token to display instead of the
\     normal extended description if the criteria in RUPLA_DE and RUGAL_DE are
\     met
\
\ See the PDESC routine for details of how extended system descriptions work.
\
\ ******************************************************************************

.RUTOK_DE

 EQUB VE                \ Token 0:      ""

 EJMP 19                \ Token 1:      ""
 ETWO 'D', 'I'
 ECHR 'E'
 EJMP 26
 ECHR 'K'
 ECHR 'O'
 ECHR 'L'
 ETWO 'O', 'N'
 ECHR 'I'
 ETWO 'S', 'T'
 ETWO 'E', 'N'
 ECHR ' '
 ECHR 'H'
 ETWO 'A', 'B'
 ETWO 'E', 'N'
 ECHR ' '
 ETWO 'G', 'E'
 ETWO 'G', 'E'
 ECHR 'N'
 ECHR ' '
 ETOK 155
 EJMP 26
 ETWO 'I', 'N'
 ECHR 'T'
 ETWO 'E', 'R'
 ECHR 'G'
 ETWO 'A', 'L'
 ECHR 'A'
 ECHR 'K'
 ETWO 'T', 'I'
 ECHR 'S'
 ECHR 'C'
 ECHR 'H'
 ECHR 'E'
 EJMP 26
 ECHR 'K'
 ECHR 'L'
 ETWO 'O', 'N'
 ETWO 'I', 'N'
 ECHR 'G'
 EJMP 26
 ECHR 'P'
 ECHR 'R'
 ECHR 'O'
 ECHR 'T'
 ECHR 'O'
 ECHR 'K'
 ECHR 'O'
 ECHR 'L'
 ECHR ' '
 ECHR 'V'
 ETWO 'E', 'R'
 ETWO 'S', 'T'
 ECHR 'O'
 ERND 3
 ETWO 'E', 'N'
 ECHR ';'
 ECHR ' '
 ETWO 'M', 'A'
 ECHR 'N'
 ECHR ' '
 ECHR 'M'
 ECHR 'U'
 ERND 3
 ECHR ' '
 ECHR 'S'
 ECHR 'I'
 ECHR 'E'
 ECHR ' '
 ECHR 'M'
 ECHR 'E'
 ECHR 'I'
 ECHR 'D'
 ETWO 'E', 'N'
 EQUB VE

 EJMP 19                \ Token 2:      ""
 ECHR 'C'
 ETWO 'O', 'N'
 ETWO 'S', 'T'
 ECHR 'R'
 ECHR 'I'
 ECHR 'C'
 ECHR 'T'
 ETWO 'O', 'R'
 ECHR ' '
 ETOK 203
 EJMP 19
 ETWO 'R', 'E'
 ETWO 'E', 'S'
 ETWO 'D', 'I'
 ETWO 'C', 'E'
 ECHR ','
 ECHR ' '
 ETOK 154
 EQUB VE

 EJMP 19                \ Token 3:      ""
 ECHR 'E'
 ETWO 'I', 'N'
 ECHR ' '
 ETWO 'G', 'E'
 ECHR 'F'
 ERND 0
 ECHR 'H'
 ECHR 'R'
 ECHR 'L'
 ECHR 'I'
 ECHR 'C'
 ECHR 'H'
 ECHR ' '
 ECHR 'A'
 ETWO 'U', 'S'
 ETWO 'S', 'E'
 ECHR 'H'
 ETWO 'E', 'N'
 ECHR 'D'
 ETWO 'E', 'S'
 EJMP 26
 ECHR 'S'
 ECHR 'C'
 ECHR 'H'
 ECHR 'I'
 ECHR 'F'
 ECHR 'F'
 ECHR ' '
 ECHR 'F'
 ETWO 'L', 'O'
 ECHR 'G'
 ECHR ' '
 ECHR 'V'
 ETWO 'O', 'R'
 ECHR ' '
 ECHR 'E'
 ETWO 'I', 'N'
 ETWO 'E', 'R'
 EJMP 26
 ECHR 'W'
 ECHR 'E'
 ETWO 'I', 'L'
 ECHR 'E'
 ECHR ' '
 ECHR 'V'
 ETWO 'O', 'N'
 ECHR ' '
 ECHR 'H'
 ECHR 'I'
 ETWO 'E', 'R'
 ECHR ' '
 ETWO 'A', 'B'
 ECHR '.'
 EJMP 26
 ETWO 'E', 'S'
 ECHR ' '
 ECHR 'S'
 ECHR 'A'
 ECHR 'H'
 ECHR ' '
 ECHR 'A'
 ETWO 'U', 'S'
 ECHR ','
 ECHR ' '
 ETWO 'A', 'L'
 ECHR 'S'
 ECHR ' '
 ECHR 'O'
 ECHR 'B'
 ECHR ' '
 ETWO 'E', 'S'
 ECHR ' '
 ECHR 'N'
 ECHR 'A'
 ECHR 'C'
 ECHR 'H'
 EJMP 26
 ETWO 'A', 'R'
 ECHR 'E'
 ETWO 'X', 'E'
 ECHR ' '
 ECHR 'F'
 ECHR 'L'
 ERND 1
 ETWO 'G', 'E'
 EQUB VE

 EJMP 19                \ Token 4:      ""
 ECHR 'J'
 ECHR 'A'
 ECHR ','
 ECHR ' '
 ECHR 'E'
 ETWO 'I', 'N'
 ECHR ' '
 ETWO 'S', 'E'
 ECHR 'L'
 ECHR 'T'
 ECHR 'S'
 ECHR 'A'
 ECHR 'M'
 ETWO 'E', 'S'
 EJMP 26
 ECHR 'S'
 ECHR 'C'
 ECHR 'H'
 ECHR 'I'
 ECHR 'F'
 ECHR 'F'
 ECHR ' '
 ETWO 'B', 'E'
 ECHR 'K'
 ECHR 'A'
 ECHR 'M'
 ECHR ' '
 ECHR 'H'
 ECHR 'I'
 ETWO 'E', 'R'
 ECHR ' '
 ECHR 'E'
 ETWO 'I', 'N'
 ETWO 'E', 'N'
 ECHR ' '
 ECHR 'G'
 ETWO 'A', 'L'
 ECHR 'A'
 ECHR 'K'
 ETWO 'T', 'I'
 ECHR 'S'
 ECHR 'C'
 ECHR 'H'
 ETWO 'E', 'N'
 EJMP 26
 ECHR 'H'
 ECHR 'Y'
 ECHR 'P'
 ETWO 'E', 'R'
 ECHR 'S'
 ECHR 'P'
 ECHR 'R'
 ECHR 'U'
 ECHR 'N'
 ECHR 'G'
 ETWO 'A', 'N'
 ECHR 'T'
 ECHR 'R'
 ECHR 'I'
 ECHR 'E'
 ECHR 'B'
 ECHR '.'
 EJMP 26
 ETWO 'B', 'E'
 ETWO 'N', 'U'
 ECHR 'T'
 ECHR 'Z'
 ECHR 'T'
 ECHR ' '
 ECHR 'W'
 ECHR 'U'
 ECHR 'R'
 ECHR 'D'
 ECHR 'E'
 ECHR ' '
 ETWO 'E', 'S'
 ECHR ' '
 ECHR 'A'
 ECHR 'U'
 ECHR 'C'
 ECHR 'H'
 ETOK 159
 EJMP 19
 ETWO 'D', 'I'
 ECHR 'E'
 ETWO 'S', 'E'
 ECHR 'S'
 ECHR ' '
 ECHR 'M'
 ETWO 'E', 'R'
 ECHR 'K'
 ECHR 'W'
 ERND 2
 ECHR 'R'
 ETWO 'D', 'I'
 ETWO 'G', 'E'
 EJMP 26
 ECHR 'S'
 ECHR 'C'
 ECHR 'H'
 ECHR 'I'
 ECHR 'F'
 ECHR 'F'
 ECHR ' '
 ECHR 'T'
 ECHR 'A'
 ECHR 'U'
 ETOK 161
 ECHR 'E'
 ECHR ' '
 ECHR 'W'
 ECHR 'I'
 ECHR 'E'
 ECHR ' '
 ECHR 'A'
 ETWO 'U', 'S'
 ECHR ' '
 ECHR 'D'
 ECHR 'E'
 ECHR 'M'
 EJMP 26
 ECHR 'N'
 ECHR 'I'
 ETOK 161
 ECHR 'S'
 ECHR ' '
 ECHR 'A'
 ECHR 'U'
 ECHR 'F'
 ECHR ','
 ECHR ' '
 ECHR 'U'
 ECHR 'N'
 ECHR 'D'
 ECHR ' '
 ECHR 'V'
 ETWO 'E', 'R'
 ECHR 'S'
 ECHR 'C'
 ECHR 'H'
 ECHR 'W'
 ETWO 'A', 'N'
 ECHR 'D'
 ECHR ' '
 ECHR 'A'
 ECHR 'U'
 ECHR 'C'
 ECHR 'H'
 ECHR ' '
 ECHR 'W'
 ECHR 'I'
 ETWO 'E', 'D'
 ETWO 'E', 'R'
 ECHR ' '
 ETWO 'G', 'E'
 ECHR 'N'
 ECHR 'A'
 ECHR 'U'
 ETWO 'S', 'O'
 ECHR ' '
 ECHR 'S'
 ECHR 'C'
 ECHR 'H'
 ECHR 'N'
 ECHR 'E'
 ECHR 'L'
 ECHR 'L'
 ECHR '.'
 EJMP 26
 ETWO 'M', 'A'
 ECHR 'N'
 ECHR ' '
 ECHR 'S'
 ECHR 'A'
 ECHR 'G'
 ECHR 'T'
 ECHR ','
 ECHR ' '
 ETWO 'E', 'S'
 ECHR ' '
 ECHR 'F'
 ECHR 'L'
 ERND 1
 ETWO 'G', 'E'
 ECHR ' '
 ECHR 'N'
 ECHR 'A'
 ECHR 'C'
 ECHR 'H'
 EJMP 26
 ETWO 'I', 'N'
 ETWO 'B', 'I'
 ETWO 'B', 'E'
 EQUB VE

 EJMP 19                \ Token 5:      ""
 ECHR 'E'
 ETWO 'I', 'N'
 ECHR ' '
 ECHR 'M'
 ERND 0
 ECHR 'C'
 ECHR 'H'
 ETWO 'T', 'I'
 ETWO 'G', 'E'
 ECHR 'S'
 EJMP 26
 ECHR 'S'
 ECHR 'C'
 ECHR 'H'
 ECHR 'I'
 ECHR 'F'
 ECHR 'F'
 ECHR ' '
 ECHR 'G'
 ECHR 'R'
 ECHR 'I'
 ECHR 'F'
 ECHR 'F'
 ECHR ' '
 ECHR 'M'
 ECHR 'I'
 ECHR 'C'
 ECHR 'H'
 ECHR ' '
 ECHR 'V'
 ETWO 'O', 'R'
 EJMP 26
 ECHR 'A'
 ETWO 'U', 'S'
 ETWO 'A', 'R'
 ECHR ' '
 ETWO 'A', 'N'
 ECHR '.'
 EJMP 26
 ECHR 'M'
 ECHR 'E'
 ETWO 'I', 'N'
 ECHR 'E'
 EJMP 26
 ETWO 'L', 'A'
 ETWO 'S', 'E'
 ECHR 'R'
 ECHR ' '
 ECHR 'K'
 ETWO 'O', 'N'
 ECHR 'N'
 ECHR 'T'
 ETWO 'E', 'N'
 ECHR ' '
 ETWO 'D', 'I'
 ECHR 'E'
 ETWO 'S', 'E'
 ECHR 'M'
 ECHR ' '
 ERND 24
 ECHR 'N'
 ECHR ' '
 ECHR 'N'
 ECHR 'I'
 ETOK 161
 ECHR ' '
 ECHR 'E'
 ETWO 'I', 'N'
 ECHR 'M'
 ETWO 'A', 'L'
 ECHR ' '
 ECHR 'E'
 ETWO 'I', 'N'
 ETWO 'E', 'N'
 EJMP 26
 ECHR 'K'
 ECHR 'R'
 ETWO 'A', 'T'
 ECHR 'Z'
 ETWO 'E', 'R'
 ECHR ' '
 ECHR 'V'
 ETWO 'E', 'R'
 ECHR 'P'
 ECHR 'A'
 ECHR 'S'
 ETWO 'S', 'E'
 ECHR 'N'
 ECHR '.'
 EQUB VE

 EJMP 19                \ Token 6:      ""
 ECHR 'A'
 ECHR 'C'
 ECHR 'H'
 ECHR ' '
 ECHR 'J'
 ECHR 'A'
 ECHR ','
 ECHR ' '
 ECHR 'E'
 ETWO 'I', 'N'
 ECHR ' '
 ECHR 'F'
 ERND 2
 ECHR 'R'
 ETOK 161
 ETWO 'E', 'R'
 ECHR 'L'
 ECHR 'I'
 ECHR 'C'
 ECHR 'H'
 ETWO 'E', 'R'
 EJMP 26
 ECHR 'G'
 ECHR 'A'
 ECHR 'U'
 ECHR 'N'
 ETWO 'E', 'R'
 ECHR ' '
 ECHR 'S'
 ECHR 'C'
 ECHR 'H'
 ECHR 'O'
 ERND 3
 ECHR ' '
 ECHR 'A'
 ECHR 'U'
 ECHR 'F'
 ECHR ' '
 ECHR 'V'
 ECHR 'I'
 ECHR 'E'
 ETWO 'L', 'E'
 ECHR ' '
 ETWO 'D', 'I'
 ECHR 'E'
 ETWO 'S', 'E'
 ECHR 'R'
 ECHR ' '
 ECHR 'S'
 ECHR 'C'
 ECHR 'H'
 ETWO 'R', 'E'
 ECHR 'C'
 ECHR 'K'
 ECHR 'L'
 ECHR 'I'
 ECHR 'C'
 ECHR 'H'
 ETWO 'E', 'N'
 EJMP 26
 ECHR 'P'
 ECHR 'I'
 ECHR 'R'
 ETWO 'A', 'T'
 ETWO 'E', 'N'
 ECHR ' '
 ECHR 'U'
 ECHR 'N'
 ECHR 'D'
 ECHR ' '
 ECHR 'F'
 ECHR 'U'
 ECHR 'H'
 ECHR 'R'
 ECHR ' '
 ECHR 'N'
 ECHR 'A'
 ECHR 'C'
 ECHR 'H'
 ECHR 'H'
 ETWO 'E', 'R'
 ECHR ' '
 ECHR 'N'
 ECHR 'A'
 ECHR 'C'
 ECHR 'H'
 EJMP 26
 ETWO 'U', 'S'
 ETWO 'L', 'E'
 ECHR 'R'
 ECHR 'I'
 EQUB VE

 EJMP 19                \ Token 7:      ""
 ECHR 'S'
 ECHR 'I'
 ECHR 'E'
 ECHR ' '
 ECHR 'K'
 ERND 1
 ECHR 'N'
 ECHR 'N'
 ETWO 'E', 'N'
 ECHR ' '
 ECHR 'S'
 ECHR 'I'
 ECHR 'C'
 ECHR 'H'
 ECHR ' '
 ECHR 'D'
 ETWO 'E', 'N'
 ECHR ' '
 ERND 24
 ECHR ' '
 ECHR 'V'
 ETWO 'O', 'R'
 ECHR 'N'
 ECHR 'E'
 ECHR 'H'
 ECHR 'M'
 ETWO 'E', 'N'
 ECHR ','
 ECHR ' '
 ECHR 'W'
 ETWO 'E', 'N'
 ECHR 'N'
 EJMP 26
 ECHR 'S'
 ECHR 'I'
 ECHR 'E'
 ECHR ' '
 ECHR 'W'
 ECHR 'O'
 ECHR 'L'
 ETWO 'L', 'E'
 ECHR 'N'
 ECHR '.'
 EJMP 26
 ETWO 'E', 'R'
 ECHR ' '
 ECHR 'I'
 ETWO 'S', 'T'
 ECHR ' '
 ETWO 'I', 'N'
 EJMP 26
 ETWO 'O', 'R'
 ETWO 'A', 'R'
 ETWO 'R', 'A'
 EQUB VE

 ERND 25                \ Token 8:      ""
 EQUB VE

 ERND 25                \ Token 9:      ""
 EQUB VE

 ERND 25                \ Token 10:     ""
 EQUB VE

 ERND 25                \ Token 11:     ""
 EQUB VE

 ERND 25                \ Token 12:     ""
 EQUB VE

 ERND 25                \ Token 13:     ""
 EQUB VE

 ERND 25                \ Token 14:     ""
 EQUB VE

 ERND 25                \ Token 15:     ""
 EQUB VE

 ERND 25                \ Token 16:     ""
 EQUB VE

 ERND 25                \ Token 17:     ""
 EQUB VE

 ERND 25                \ Token 18:     ""
 EQUB VE

 ERND 25                \ Token 19:     ""
 EQUB VE

 ERND 25                \ Token 20:     ""
 EQUB VE

 EJMP 19                \ Token 21:     ""
 ECHR 'D'
 ECHR 'A'
 ECHR ' '
 ECHR 'S'
 ETWO 'I', 'N'
 ECHR 'D'
 EJMP 26
 ECHR 'S'
 ECHR 'I'
 ECHR 'E'
 ECHR ' '
 ETWO 'A', 'B'
 ETWO 'E', 'R'
 ECHR ' '
 ETWO 'I', 'N'
 ECHR ' '
 ECHR 'D'
 ETWO 'E', 'R'
 ECHR ' '
 ECHR 'F'
 ETWO 'A', 'L'
 ECHR 'S'
 ECHR 'C'
 ECHR 'H'
 ETWO 'E', 'N'
 EJMP 26
 ECHR 'G'
 ETWO 'A', 'L'
 ECHR 'A'
 ECHR 'X'
 ECHR 'I'
 ECHR 'S'
 ECHR '!'
 ETOK 159
 EJMP 19
 ECHR 'D'
 ECHR 'A'
 ECHR ' '
 ECHR 'D'
 ETWO 'R', 'A'
 ECHR 'U'
 ERND 3
 ETWO 'E', 'N'
 ECHR ' '
 ECHR 'G'
 ECHR 'I'
 ECHR 'B'
 ECHR 'T'
 ECHR ' '
 ETWO 'E', 'S'
 ECHR ' '
 ECHR 'E'
 ETWO 'I', 'N'
 ETWO 'E', 'N'
 ECHR ' '
 ERND 24
 ECHR ' '
 ECHR 'V'
 ETWO 'O', 'N'
 ECHR ' '
 ECHR 'E'
 ETWO 'I', 'N'
 ECHR 'E'
 ECHR 'M'
 EJMP 26
 ECHR 'P'
 ECHR 'I'
 ECHR 'R'
 ETWO 'A', 'T'
 ETWO 'E', 'N'
 ETOK 159

\ ******************************************************************************
\
\       Name: TKN1_FR
\       Type: Variable
\   Category: Text
\    Summary: The first extended token table for recursive tokens 0-255 (DETOK)
\             (French)
\  Deep dive: Extended text tokens
\
\ ******************************************************************************

.TKN1_FR

 EQUB VE                \ Token 0:      ""

 EJMP 19                \ Token 1:      ""
 ETWO 'O', 'U'
 ECHR 'I'
 EQUB VE

 EJMP 19                \ Token 2:      ""
 ECHR 'N'
 ETWO 'O', 'N'
 EQUB VE

 EQUB VE                \ Token 3:      ""

 EJMP 19                \ Token 4:      ""
 ECHR 'F'
 ETWO 'R', 'A'
 ECHR 'N'
 ECHR '@'
 ECHR 'A'
 ECHR 'I'
 ECHR 'S'
 EQUB VE

 EQUB VE                \ Token 5:      ""

 EQUB VE                \ Token 6:      ""

 EQUB VE                \ Token 7:      ""

 EJMP 19                \ Token 8:      ""
 ECHR 'N'
 ETWO 'O', 'U'
 ETWO 'V', 'E'
 ECHR 'A'
 ECHR 'U'
 EJMP 26
 ETWO 'N', 'O'
 ECHR 'M'
 ECHR ':'
 ECHR ' '
 EQUB VE

 EQUB VE                \ Token 9:      ""

 EJMP 23                \ Token 10:     ""
 EJMP 14
 EJMP 13
 ECHR ' '
 ETOK 213
 EJMP 26
 ETOK 181
 ETOK 190
 ECHR ' '
 ECHR 'P'
 ECHR 'R'
 ECHR 'I'
 ECHR 'E'
 ETOK 179
 ECHR 'M'
 ECHR '`'
 ECHR 'A'
 ECHR 'C'
 ECHR 'C'
 ETWO 'O', 'R'
 ECHR 'D'
 ETWO 'E', 'R'
 ECHR ' '
 ETWO 'Q', 'U'
 ECHR 'E'
 ECHR 'L'
 ETWO 'Q', 'U'
 ETWO 'E', 'S'
 ECHR ' '
 ETWO 'I', 'N'
 ETWO 'S', 'T'
 ETWO 'A', 'N'
 ECHR 'T'
 ECHR 'S'
 ETOK 204
 ECHR 'N'
 ETWO 'O', 'U'
 ECHR 'S'
 ECHR ' '
 ECHR 'A'
 ECHR 'I'
 ECHR 'M'
 ETWO 'E', 'R'
 ECHR 'I'
 ETWO 'O', 'N'
 ECHR 'S'
 ECHR ' '
 ETOK 190
 ECHR ' '
 ECHR 'C'
 ETWO 'O', 'N'
 ECHR 'F'
 ECHR 'I'
 ETWO 'E', 'R'
 ECHR ' '
 ETOK 186
 ECHR 'P'
 ETWO 'E', 'T'
 ETWO 'I', 'T'
 ECHR ' '
 ECHR 'T'
 ETWO 'R', 'A'
 ECHR 'V'
 ECHR 'A'
 ETWO 'I', 'L'
 ETOK 204
 ETOK 188
 ECHR 'N'
 ETWO 'O', 'U'
 ETWO 'V', 'E'
 ECHR 'A'
 ECHR 'U'
 ECHR ' '
 ECHR 'M'
 ECHR 'O'
 ECHR 'D'
 ECHR '='
 ETOK 178
 ECHR 'D'
 ECHR 'E'
 ETOK 173
 ETOK 178
 ECHR '`'
 EJMP 19
 ECHR 'C'
 ETWO 'O', 'N'
 ETWO 'S', 'T'
 ECHR 'R'
 ECHR 'I'
 ECHR 'C'
 ECHR 'T'
 ETWO 'O', 'R'
 ECHR '`'
 ECHR ' '
 ETOK 184
 ECHR ' '
 ECHR 'D'
 ECHR 'O'
 ECHR 'T'
 ECHR '<'
 ECHR ' '
 ECHR 'D'
 ECHR '`'
 ETOK 186
 ECHR 'G'
 ECHR '<'
 ECHR 'N'
 ECHR '<'
 ECHR 'R'
 ETWO 'A', 'T'
 ECHR 'E'
 ECHR 'U'
 ECHR 'R'
 ETOK 179
 ECHR 'B'
 ETWO 'O', 'U'
 ECHR 'C'
 ECHR 'L'
 ECHR 'I'
 ETWO 'E', 'R'
 ECHR 'S'
 ECHR ' '
 ECHR 'T'
 ECHR 'O'
 ECHR 'P'
 ECHR ' '
 ETWO 'S', 'E'
 ECHR 'C'
 ECHR 'R'
 ETWO 'E', 'T'
 ETOK 204
 EJMP 19
 ECHR 'M'
 ETWO 'A', 'L'
 ECHR 'H'
 ECHR 'E'
 ECHR 'U'
 ETWO 'R', 'E'
 ECHR 'U'
 ETWO 'S', 'E'
 ECHR 'M'
 ETWO 'E', 'N'
 ECHR 'T'
 ECHR ' '
 ETWO 'I', 'L'
 ETOK 129
 ECHR '<'
 ECHR 'T'
 ECHR '<'
 ECHR ' '
 ECHR 'V'
 ECHR 'O'
 ECHR 'L'
 ECHR '<'
 ETOK 204
 EJMP 22
 EJMP 19
 ETWO 'I', 'L'
 ETOK 129
 ETWO 'D', 'I'
 ECHR 'S'
 ECHR 'P'
 ETWO 'A', 'R'
 ECHR 'U'
 ECHR ' '
 ECHR 'D'
 ECHR 'U'
 ECHR ' '
 ECHR 'C'
 ECHR 'H'
 ETWO 'A', 'N'
 ETWO 'T', 'I'
 ETWO 'E', 'R'
 ECHR ' '
 ECHR 'N'
 ECHR 'A'
 ECHR 'V'
 ETWO 'A', 'L'
 ECHR ' '
 ECHR '"'
 EJMP 26
 ETWO 'X', 'E'
 ETWO 'E', 'R'
 ECHR ' '
 ETWO 'I', 'L'
 ECHR ' '
 ECHR 'Y'
 ETOK 129
 ECHR 'C'
 ETWO 'I', 'N'
 ECHR 'Q'
 ECHR ' '
 ECHR 'M'
 ECHR 'O'
 ECHR 'I'
 ECHR 'S'
 ECHR '.'
 EJMP 26
 ETWO 'O', 'N'
 ECHR ' '
 ECHR 'L'
 ECHR '`'
 ECHR 'A'
 ECHR ' '
 EJMP 28
 ETOK 204
 EJMP 19
 ECHR 'V'
 ECHR 'O'
 ECHR 'T'
 ETWO 'R', 'E'
 ECHR ' '
 ECHR 'M'
 ECHR 'I'
 ECHR 'S'
 ECHR 'S'
 ECHR 'I'
 ETWO 'O', 'N'
 ECHR ' '
 ETOK 184
 ETOK 179
 ECHR 'R'
 ETWO 'E', 'T'
 ECHR 'R'
 ETWO 'O', 'U'
 ECHR 'V'
 ETWO 'E', 'R'
 ECHR ' '
 ETWO 'C', 'E'
 ETOK 173
 ECHR 'A'
 ECHR 'F'
 ETWO 'I', 'N'
 ETOK 179
 ETOK 178
 ECHR 'D'
 ECHR '<'
 ECHR 'T'
 ECHR 'R'
 ECHR 'U'
 ECHR 'I'
 ETWO 'R', 'E'
 ETOK 204
 EJMP 19
 ETWO 'I', 'L'
 ECHR ' '
 ECHR 'N'
 ECHR '`'
 ECHR 'Y'
 ETOK 129
 ETOK 192
 ETOK 187
 ETWO 'L', 'A'
 ETWO 'S', 'E'
 ECHR 'R'
 ECHR 'S'
 ECHR ' '
 ECHR 'M'
 ETWO 'I', 'L'
 ETWO 'I', 'T'
 ECHR 'A'
 ECHR 'I'
 ECHR 'R'
 ETWO 'E', 'S'
 ECHR ' '
 ETWO 'Q', 'U'
 ECHR 'I'
 ECHR ' '
 ECHR 'S'
 ETWO 'O', 'N'
 ECHR 'T'
 ECHR ' '
 ECHR 'C'
 ECHR 'A'
 ECHR 'P'
 ETWO 'A', 'B'
 ETWO 'L', 'E'
 ECHR 'S'
 ETOK 179
 ECHR 'T'
 ETWO 'R', 'A'
 ECHR 'N'
 ECHR 'S'
 ECHR 'P'
 ETWO 'E', 'R'
 ETWO 'C', 'E'
 ECHR 'R'
 ECHR ' '
 ETOK 187
 ECHR 'B'
 ETWO 'O', 'U'
 ECHR 'C'
 ECHR 'L'
 ECHR 'I'
 ETWO 'E', 'R'
 ECHR 'S'
 ECHR '.'
 EJMP 26
 ECHR 'D'
 ECHR 'E'
 ECHR ' '
 ETOK 196
 ECHR ','
 ECHR ' '
 ETOK 178
 ECHR 'C'
 ETWO 'O', 'N'
 ETWO 'S', 'T'
 ECHR 'R'
 ECHR 'I'
 ECHR 'C'
 ECHR 'T'
 ETWO 'O', 'R'
 ECHR ' '
 ETOK 184
 ECHR ' '
 ECHR 'D'
 ECHR 'O'
 ECHR 'T'
 ECHR '<'
 ECHR ' '
 ECHR 'D'
 ECHR '`'
 ETOK 186
 EJMP 6
 ERND 17
 EJMP 5
 ETOK 177
 EJMP 8
 EJMP 19
 ECHR 'B'
 ETWO 'O', 'N'
 ECHR 'N'
 ECHR 'E'
 ECHR ' '
 ECHR 'C'
 ECHR 'H'
 ETWO 'A', 'N'
 ETOK 188
 ETOK 154
 ETOK 212
 EJMP 22
 EQUB VE

 EJMP 25                \ Token 11:     ""
 EJMP 9
 EJMP 23
 EJMP 14
 ECHR ' '
 EJMP 26
 ETWO 'A', 'T'
 ECHR 'T'
 ETWO 'E', 'N'
 ETWO 'T', 'I'
 ETWO 'O', 'N'
 ECHR ' '
 ETOK 213
 ECHR '.'
 EJMP 26
 ECHR 'N'
 ETWO 'O', 'U'
 ECHR 'S'
 ECHR ' '
 ETOK 172
 ECHR 'S'
 ETOK 179
 ECHR 'N'
 ETWO 'O', 'U'
 ETWO 'V', 'E'
 ECHR 'A'
 ECHR 'U'
 ECHR ' '
 ETWO 'R', 'E'
 ECHR 'C'
 ETWO 'O', 'U'
 ECHR 'R'
 ECHR 'S'
 ETOK 183
 ETOK 190
 ETOK 204
 EJMP 19
 ETOK 190
 ECHR ' '
 ETWO 'R', 'E'
 ETWO 'C', 'E'
 ECHR 'V'
 ETWO 'R', 'E'
 ECHR 'Z'
 ECHR ' '
 ETOK 195
 ETWO 'I', 'N'
 ETWO 'S', 'T'
 ECHR 'R'
 ECHR 'U'
 ECHR 'C'
 ETWO 'T', 'I'
 ETWO 'O', 'N'
 ECHR 'S'
 ECHR ' '
 ECHR 'S'
 ECHR 'I'
 ECHR ' '
 ETOK 190
 ECHR ' '
 ETWO 'A', 'L'
 ETWO 'L', 'E'
 ECHR 'Z'
 ECHR ' '
 ECHR 'J'
 ETWO 'U', 'S'
 ETWO 'Q', 'U'
 ECHR '`'
 ECHR '"'
 EJMP 26
 ETWO 'C', 'E'
 ETWO 'E', 'R'
 ETWO 'D', 'I'
 ETOK 204
 ETOK 190
 ECHR ' '
 ETWO 'S', 'E'
 ETWO 'R', 'E'
 ECHR 'Z'
 ECHR ' '
 ECHR 'R'
 ECHR '<'
 ECHR 'C'
 ECHR 'O'
 ECHR 'M'
 ECHR 'P'
 ETWO 'E', 'N'
 ECHR 'S'
 ECHR '<'
 ECHR ' '
 ECHR 'S'
 ECHR 'I'
 ECHR ' '
 ETOK 190
 ECHR ' '
 ECHR 'R'
 ECHR '<'
 ETWO 'U', 'S'
 ECHR 'S'
 ECHR 'I'
 ECHR 'S'
 ETWO 'S', 'E'
 ECHR 'Z'
 ETOK 212
 EJMP 24
 EQUB VE

 EQUB VE                \ Token 12:     ""

 EQUB VE                \ Token 13:     ""

 EJMP 21                \ Token 14:     ""
 EJMP 19
 ETWO 'N', 'O'
 ECHR 'M'
 EJMP 26
 ECHR 'P'
 ETWO 'L', 'A'
 ECHR 'N'
 ECHR '<'
 ECHR 'T'
 ECHR 'E'
 ECHR '?'
 ECHR ' '
 EQUB VE

 EJMP 25                \ Token 15:     ""
 EJMP 9
 EJMP 23
 EJMP 14
 EJMP 13
 ECHR ' '
 EJMP 26
 ECHR 'F'
 ECHR '<'
 ECHR 'L'
 ECHR 'I'
 ECHR 'C'
 ETWO 'I', 'T'
 ETWO 'A', 'T'
 ECHR 'I'
 ETWO 'O', 'N'
 ECHR 'S'
 ECHR ' '
 ETOK 154
 ECHR '!'
 EJMP 12
 EJMP 12
 EJMP 26
 ETOK 190
 ECHR ' '
 ETWO 'S', 'E'
 ETWO 'R', 'E'
 ECHR 'Z'
 ECHR ' '
 ECHR 'T'
 ETWO 'O', 'U'
 ECHR 'J'
 ETWO 'O', 'U'
 ECHR 'R'
 ECHR 'S'
 ECHR ' '
 ETOK 178
 ETWO 'B', 'I'
 ETWO 'E', 'N'
 ETWO 'V', 'E'
 ETWO 'N', 'U'
 ETOK 183
 ETOK 211
 ETOK 204
 ETWO 'E', 'T'
 ECHR ' '
 ECHR 'P'
 ECHR 'E'
 ECHR 'U'
 ECHR 'T'
 ECHR '-'
 ETOK 193
 ETWO 'R', 'E'
 ECHR ' '
 ETOK 196
 ECHR ' '
 ECHR 'T'
 ECHR '#'
 ECHR 'T'
 ECHR ' '
 ETOK 192
 ECHR 'P'
 ECHR 'R'
 ECHR '<'
 ECHR 'V'
 ECHR 'U'
 ECHR '.'
 ECHR '.'
 ETOK 212
 EJMP 24
 EQUB VE

 EQUB VE                \ Token 16:     ""

 EQUB VE                \ Token 17:     ""

 EQUB VE                \ Token 18:     ""

 EQUB VE                \ Token 19:     ""

 EQUB VE                \ Token 20:     ""

 EQUB VE                \ Token 21:     ""

 EQUB VE                \ Token 22:     ""

 EQUB VE                \ Token 23:     ""

 EQUB VE                \ Token 24:     ""

 EQUB VE                \ Token 25:     ""

 EQUB VE                \ Token 26:     ""

 EQUB VE                \ Token 27:     ""

 EQUB VE                \ Token 28:     ""

 EQUB VE                \ Token 29:     ""

 EQUB VE                \ Token 30:     ""

 EQUB VE                \ Token 31:     ""

 EQUB VE                \ Token 32:     ""

 EQUB VE                \ Token 33:     ""

 EQUB VE                \ Token 34:     ""

 EQUB VE                \ Token 35:     ""

 EQUB VE                \ Token 36:     ""

 EQUB VE                \ Token 37:     ""

 EQUB VE                \ Token 38:     ""

 EQUB VE                \ Token 39:     ""

 EQUB VE                \ Token 40:     ""

 EQUB VE                \ Token 41:     ""

 EQUB VE                \ Token 42:     ""

 EQUB VE                \ Token 43:     ""

 EQUB VE                \ Token 44:     ""

 EQUB VE                \ Token 45:     ""

 EQUB VE                \ Token 46:     ""

 EQUB VE                \ Token 47:     ""

 EQUB VE                \ Token 48:     ""

 EQUB VE                \ Token 49:     ""

 EQUB VE                \ Token 50:     ""

 EQUB VE                \ Token 51:     ""

 EQUB VE                \ Token 52:     ""

 EQUB VE                \ Token 53:     ""

 EQUB VE                \ Token 54:     ""

 EQUB VE                \ Token 55:     ""

 EQUB VE                \ Token 56:     ""

 EQUB VE                \ Token 57:     ""

 EQUB VE                \ Token 58:     ""

 EQUB VE                \ Token 59:     ""

 EQUB VE                \ Token 60:     ""

 EQUB VE                \ Token 61:     ""

 EQUB VE                \ Token 62:     ""

 EQUB VE                \ Token 63:     ""

 EQUB VE                \ Token 64:     ""

 EQUB VE                \ Token 65:     ""

 EQUB VE                \ Token 66:     ""

 EQUB VE                \ Token 67:     ""

 EQUB VE                \ Token 68:     ""

 EQUB VE                \ Token 69:     ""

 EQUB VE                \ Token 70:     ""

 EQUB VE                \ Token 71:     ""

 EQUB VE                \ Token 72:     ""

 EQUB VE                \ Token 73:     ""

 EQUB VE                \ Token 74:     ""

 EQUB VE                \ Token 75:     ""

 EQUB VE                \ Token 76:     ""

 EQUB VE                \ Token 77:     ""

 EQUB VE                \ Token 78:     ""

 EQUB VE                \ Token 79:     ""

 EQUB VE                \ Token 80:     ""

 EQUB VE                \ Token 81:     ""

 EQUB VE                \ Token 82:     ""

 EQUB VE                \ Token 83:     ""

 EQUB VE                \ Token 84:     ""

 EJMP 2                 \ Token 85:     ""
 ERND 31
 EJMP 13
 EQUB VE

 EQUB VE                \ Token 86:     ""

 EQUB VE                \ Token 87:     ""

 EQUB VE                \ Token 88:     ""

 EQUB VE                \ Token 89:     ""

 EQUB VE                \ Token 90:     ""

 ECHR 'C'               \ Token 91:     ""
 ETWO 'R', 'A'
 ECHR 'P'
 ECHR 'U'
 ETWO 'L', 'E'
 EQUB VE

 ECHR 'V'               \ Token 92:     ""
 ECHR 'A'
 ECHR 'U'
 ECHR 'R'
 ECHR 'I'
 ETWO 'E', 'N'
 EQUB VE

 ETWO 'E', 'S'          \ Token 93:     ""
 ECHR 'C'
 ECHR 'R'
 ECHR 'O'
 ECHR 'C'
 EQUB VE

 ECHR 'G'               \ Token 94:     ""
 ETWO 'R', 'E'
 ECHR 'D'
 ETWO 'I', 'N'
 EQUB VE

 ECHR 'B'               \ Token 95:     ""
 ECHR 'R'
 ECHR 'I'
 ECHR 'G'
 ETWO 'A', 'N'
 ECHR 'D'
 EQUB VE

 EQUB VE                \ Token 96:     ""

 EQUB VE                \ Token 97:     ""

 EQUB VE                \ Token 98:     ""

 EQUB VE                \ Token 99:     ""

 EQUB VE                \ Token 100:    ""

 EQUB VE                \ Token 101:    ""

 EQUB VE                \ Token 102:    ""

 EQUB VE                \ Token 103:    ""

 EQUB VE                \ Token 104:    ""

 EQUB VE                \ Token 105:    ""

 EJMP 19                \ Token 106:    ""
 ECHR 'U'
 ECHR 'N'
 ETOK 173
 ETWO 'R', 'E'
 ECHR 'D'
 ETWO 'O', 'U'
 ECHR 'T'
 ETWO 'A', 'B'
 ETOK 178
 ETWO 'S', 'E'
 ETWO 'R', 'A'
 ETWO 'I', 'T'
 ECHR ' '
 ECHR 'A'
 ECHR 'P'
 ECHR 'P'
 ETWO 'A', 'R'
 ECHR 'U'
 ECHR ' '
 ECHR '"'
 ETOK 209
 ECHR ' '
 EQUB VE

 EJMP 19                \ Token 107:    ""
 ETWO 'O', 'U'
 ECHR 'A'
 ECHR 'I'
 ECHR 'S'
 ECHR ','
 ECHR ' '
 ECHR 'U'
 ECHR 'N'
 ETOK 173
 ECHR 'A'
 ECHR 'U'
 ETWO 'R', 'A'
 ETWO 'I', 'T'
 ECHR ' '
 ETWO 'Q', 'U'
 ETWO 'I', 'T'
 ECHR 'T'
 ECHR '<'
 ETOK 209
 EQUB VE

 EJMP 19                \ Token 108:    ""
 ETWO 'A', 'L'
 ETWO 'L', 'E'
 ECHR 'Z'
 ECHR ' '
 ECHR '"'
 ETOK 209
 EQUB VE

 EJMP 19                \ Token 109:    ""
 ETWO 'O', 'N'
 ETOK 129
 ECHR 'V'
 ECHR 'U'
 ECHR ' '
 ETOK 186
 ECHR 'A'
 ECHR 'U'
 ECHR 'T'
 ETWO 'R', 'E'
 ETOK 173
 ECHR '"'
 ETOK 209
 EQUB VE

 EJMP 19                \ Token 110:    ""
 ETWO 'E', 'S'
 ECHR 'S'
 ECHR 'A'
 ECHR 'Y'
 ECHR 'E'
 ECHR 'Z'
 ETOK 209
 EQUB VE

 EQUB VE                \ Token 111:    ""

 EQUB VE                \ Token 112:    ""

 EQUB VE                \ Token 113:    ""

 EQUB VE                \ Token 114:    ""

 EQUB VE                \ Token 115:    ""

 EQUB VE                \ Token 116:    ""

 EQUB VE                \ Token 117:    ""

 EQUB VE                \ Token 118:    ""

 EQUB VE                \ Token 119:    ""

 EQUB VE                \ Token 120:    ""

 EQUB VE                \ Token 121:    ""

 EQUB VE                \ Token 122:    ""

 EQUB VE                \ Token 123:    ""

 EQUB VE                \ Token 124:    ""

 EQUB VE                \ Token 125:    ""

 EQUB VE                \ Token 126:    ""

 EQUB VE                \ Token 127:    ""

 EQUB VE                \ Token 128:    ""

 ECHR ' '               \ Token 129:    ""
 ECHR 'A'
 ECHR ' '
 EQUB VE

 EQUB VE                \ Token 130:    ""

 EQUB VE                \ Token 131:    ""

 EQUB VE                \ Token 132:    ""

 EQUB VE                \ Token 133:    ""

 EQUB VE                \ Token 134:    ""

 EQUB VE                \ Token 135:    ""

 EQUB VE                \ Token 136:    ""

 EQUB VE                \ Token 137:    ""

 EQUB VE                \ Token 138:    ""

 EQUB VE                \ Token 139:    ""

 EQUB VE                \ Token 140:    ""

 EQUB VE                \ Token 141:    ""

 EQUB VE                \ Token 142:    ""

 EQUB VE                \ Token 143:    ""

 EQUB VE                \ Token 144:    ""

 ECHR 'P'               \ Token 145:    ""
 ETWO 'L', 'A'
 ECHR 'N'
 ECHR '='
 ECHR 'T'
 ECHR 'E'
 EQUB VE

 ECHR 'M'               \ Token 146:    ""
 ETWO 'O', 'N'
 ECHR 'D'
 ECHR 'E'
 EQUB VE

 ECHR 'E'               \ Token 147:    ""
 ECHR 'C'
 ECHR ' '
 EQUB VE

 ETWO 'C', 'E'          \ Token 148:    ""
 ECHR 'C'
 ECHR 'I'
 ECHR ' '
 EQUB VE

 EQUB VE                \ Token 149:    ""

 EJMP 9                 \ Token 150:    ""
 EJMP 11
 EJMP 1
 EJMP 8
 EQUB VE

 EQUB VE                \ Token 151:    ""

 EQUB VE                \ Token 152:    ""

 ECHR 'I'               \ Token 153:    ""
 ETWO 'A', 'N'
 EQUB VE

 EJMP 19                \ Token 154:    ""
 ECHR 'C'
 ECHR 'O'
 ECHR 'M'
 ETWO 'M', 'A'
 ECHR 'N'
 ECHR 'D'
 ETWO 'A', 'N'
 ECHR 'T'
 EQUB VE

 EQUB VE                \ Token 155:    ""

 EQUB VE                \ Token 156:    ""

 EQUB VE                \ Token 157:    ""

 EQUB VE                \ Token 158:    ""

 EQUB VE                \ Token 159:    ""

 EQUB VE                \ Token 160:    ""

 EQUB VE                \ Token 161:    ""

 EQUB VE                \ Token 162:    ""

 EQUB VE                \ Token 163:    ""

 EQUB VE                \ Token 164:    ""

 EQUB VE                \ Token 165:    ""

 EQUB VE                \ Token 166:    ""

 EQUB VE                \ Token 167:    ""

 EQUB VE                \ Token 168:    ""

 EQUB VE                \ Token 169:    ""

 EQUB VE                \ Token 170:    ""

 ECHR 'S'               \ Token 171:    ""
 ECHR 'U'
 ECHR 'I'
 ECHR 'S'
 ECHR ' '
 EQUB VE

 ECHR 'A'               \ Token 172:    ""
 ECHR 'V'
 ETWO 'O', 'N'
 EQUB VE

 ECHR ' '               \ Token 173:    ""
 ECHR 'N'
 ECHR 'A'
 ECHR 'V'
 ECHR 'I'
 ETWO 'R', 'E'
 ECHR ' '
 EQUB VE

 ETWO 'A', 'R'          \ Token 174:    ""
 ETWO 'I', 'N'
 ECHR 'E'
 EQUB VE

 ECHR 'P'               \ Token 175:    ""
 ETWO 'O', 'U'
 ECHR 'R'
 EQUB VE

 EJMP 13                \ Token 176:    ""
 EJMP 14
 EJMP 19
 EQUB VE

 ECHR '.'               \ Token 177:    ""
 EJMP 12
 EJMP 15
 EQUB VE

 ETWO 'L', 'E'          \ Token 178:    ""
 ECHR ' '
 EQUB VE

 ECHR ' '               \ Token 179:    ""
 ECHR 'D'
 ECHR 'E'
 ECHR ' '
 EQUB VE

 ECHR ' '               \ Token 180:    ""
 ETWO 'E', 'T'
 ECHR ' '
 EQUB VE

 ECHR 'J'               \ Token 181:    ""
 ECHR 'E'
 ECHR ' '
 EQUB VE

 ETWO 'L', 'A'          \ Token 182:    ""
 ECHR ' '
 EQUB VE

 ECHR ' '               \ Token 183:    ""
 ECHR '"'
 ECHR ' '
 EQUB VE

 ECHR 'E'               \ Token 184:    ""
 ETWO 'S', 'T'
 EQUB VE

 ETWO 'I', 'L'          \ Token 185:    ""
 EQUB VE

 ECHR 'U'               \ Token 186:    ""
 ECHR 'N'
 ECHR ' '
 EQUB VE

 ETWO 'L', 'E'          \ Token 187:    ""
 ECHR 'S'
 ECHR ' '
 EQUB VE

 ETWO 'C', 'E'          \ Token 188:    ""
 ECHR ' '
 EQUB VE

 ECHR 'D'               \ Token 189:    ""
 ECHR 'E'
 ECHR ' '
 ETOK 182
 EQUB VE

 ECHR 'V'               \ Token 190:    ""
 ETWO 'O', 'U'
 ECHR 'S'
 EQUB VE

 EJMP 26                \ Token 191:    ""
 ECHR 'B'
 ETWO 'O', 'N'
 ECHR 'J'
 ETWO 'O', 'U'
 ECHR 'R'
 ECHR ' '
 EQUB VE

 ETWO 'Q', 'U'          \ Token 192:    ""
 ECHR 'E'
 ECHR ' '
 EQUB VE

 ERND 4                 \ Token 193:    ""
 ECHR 'T'
 EQUB VE

 EQUB VE                \ Token 194:    ""

 ECHR 'D'               \ Token 195:    ""
 ETWO 'E', 'S'
 ECHR ' '
 EQUB VE

 ECHR 'P'               \ Token 196:    ""
 ECHR 'L'
 ETWO 'U', 'S'
 EQUB VE

 EQUB VE                \ Token 197:    ""

 EJMP 26                \ Token 198:    ""
 ECHR 'S'
 ETWO 'Q', 'U'
 ECHR 'E'
 ECHR 'A'
 ECHR 'K'
 ECHR 'Y'
 EQUB VE

 EJMP 25                \ Token 199:    ""
 EJMP 9
 EJMP 29
 EJMP 14
 EJMP 13
 ECHR ' '
 ETOK 191
 ETOK 154
 ECHR ' '
 EJMP 4
 ECHR ','
 ECHR ' '
 ETOK 181
 ECHR 'V'
 ETWO 'O', 'U'
 ECHR 'D'
 ETWO 'R', 'A'
 ECHR 'I'
 ECHR 'S'
 ECHR ' '
 ECHR 'M'
 ECHR 'E'
 ECHR ' '
 ECHR 'P'
 ECHR 'R'
 ECHR '<'
 ETWO 'S', 'E'
 ECHR 'N'
 ECHR 'T'
 ETWO 'E', 'R'
 ECHR '.'
 EJMP 26
 ETOK 181
 ETOK 171
 ETWO 'L', 'E'
 EJMP 26
 ECHR 'P'
 ECHR 'R'
 ETWO 'I', 'N'
 ETOK 188
 ECHR 'D'
 ECHR 'E'
 EJMP 26
 ETWO 'T', 'H'
 ECHR 'R'
 ECHR 'U'
 ECHR 'N'
 ETOK 180
 ETOK 181
 ETOK 171
 ECHR 'O'
 ECHR 'B'
 ECHR 'L'
 ECHR 'I'
 ECHR 'G'
 ECHR '<'
 ETOK 179
 ECHR 'M'
 ECHR 'E'
 ECHR ' '
 ECHR 'S'
 ECHR '<'
 ECHR 'P'
 ETWO 'A', 'R'
 ETWO 'E', 'R'
 ETOK 179
 ETOK 182
 ECHR 'P'
 ECHR 'L'
 ECHR 'U'
 ECHR 'P'
 ETWO 'A', 'R'
 ECHR 'T'
 ETOK 179
 ECHR 'M'
 ETWO 'E', 'S'
 ECHR ' '
 ECHR 'T'
 ECHR 'R'
 ECHR '<'
 ETWO 'S', 'O'
 ECHR 'R'
 ECHR 'S'
 ETOK 204
 EJMP 19
 ETOK 175
 ECHR ' '
 ETOK 182
 ECHR 'J'
 ECHR 'O'
 ECHR 'L'
 ECHR 'I'
 ECHR 'E'
 ECHR ' '
 ETWO 'S', 'O'
 ECHR 'M'
 ECHR 'M'
 ECHR 'E'
 ETOK 179
 ECHR '5'
 ECHR '0'
 ECHR '0'
 ECHR '0'
 EJMP 19
 ECHR 'C'
 EJMP 19
 ECHR 'R'
 ECHR ' '
 ETOK 181
 ETOK 190
 ECHR ' '
 ECHR 'O'
 ECHR 'F'
 ECHR 'F'
 ETWO 'R', 'E'
 ECHR ' '
 ECHR 'L'
 ECHR '`'
 ECHR 'O'
 ECHR 'B'
 ECHR 'J'
 ETWO 'E', 'T'
 ECHR ' '
 ETOK 178
 ETOK 196
 ECHR ' '
 ECHR 'R'
 ETWO 'A', 'R'
 ECHR 'E'
 ETOK 179
 ECHR 'T'
 ETWO 'O', 'U'
 ECHR 'T'
 ECHR ' '
 ECHR 'L'
 ECHR '`'
 ECHR 'U'
 ECHR 'N'
 ECHR 'I'
 ECHR 'V'
 ETWO 'E', 'R'
 ECHR 'S'
 ETOK 204
 EJMP 19
 ECHR 'V'
 ETWO 'O', 'U'
 ETWO 'L', 'E'
 ECHR 'Z'
 ECHR '-'
 ETOK 190
 ECHR ' '
 ETOK 178
 ECHR 'P'
 ETWO 'R', 'E'
 ECHR 'N'
 ECHR 'D'
 ETWO 'R', 'E'
 ECHR '?'
 EJMP 12
 EJMP 15
 EJMP 1
 EJMP 8
 EQUB VE

 EJMP 26                \ Token 200:    ""
 ETWO 'N', 'O'
 ECHR 'M'
 ECHR '?'
 ECHR ' '
 EQUB VE

 EQUB VE                \ Token 201:    ""

 EQUB VE                \ Token 202:    ""

 ECHR 'P'               \ Token 203:    ""
 ETWO 'E', 'R'
 ECHR 'D'
 ECHR 'U'
 ETOK 179
 ECHR 'V'
 ECHR 'U'
 ECHR 'E'
 ETOK 183
 EJMP 19
 EQUB VE

 ECHR '.'               \ Token 204:    ""
 EJMP 12
 EJMP 12
 ECHR ' '
 EJMP 19
 EQUB VE

 ECHR '"'               \ Token 205:    ""
 ECHR ' '
 ETWO 'Q', 'U'
 ECHR 'A'
 ECHR 'I'
 EQUB VE

 EQUB VE                \ Token 206:    ""

 EQUB VE                \ Token 207:    ""

 EQUB VE                \ Token 208:    ""

 EJMP 26                \ Token 209:    ""
 ETWO 'E', 'R'
 ECHR 'R'
 ECHR 'I'
 ETWO 'U', 'S'
 EQUB VE

 EQUB VE                \ Token 210:    ""

 ECHR ' '               \ Token 211:    ""
 ETWO 'L', 'A'
 EJMP 26
 ECHR 'M'
 ETOK 174
 EJMP 26
 ECHR 'S'
 ECHR 'P'
 ETWO 'A', 'T'
 ECHR 'I'
 ETWO 'A', 'L'
 ECHR 'E'
 ETOK 179
 ECHR 'S'
 ECHR 'A'
 EJMP 26
 ETWO 'M', 'A'
 ECHR 'J'
 ETOK 184
 ECHR '<'
 EQUB VE

 ETOK 177               \ Token 212:    ""
 EJMP 12
 EJMP 8
 EJMP 1
 ECHR ' '
 EJMP 26
 ECHR 'F'
 ETWO 'I', 'N'
 ECHR ' '
 ECHR 'D'
 ECHR 'U'
 ECHR ' '
 ECHR 'M'
 ETWO 'E', 'S'
 ECHR 'S'
 ECHR 'A'
 ETWO 'G', 'E'
 EQUB VE

 ECHR ' '               \ Token 213:    ""
 ETOK 154
 ECHR ' '
 EJMP 4
 ECHR ','
 ECHR ' '
 ETOK 181
 EJMP 13
 ETOK 171
 ETOK 178
 ECHR 'C'
 ECHR 'A'
 ECHR 'P'
 ETWO 'I', 'T'
 ECHR 'A'
 ETWO 'I', 'N'
 ECHR 'E'
 ECHR ' '
 EJMP 27
 ECHR ' '
 ECHR 'D'
 ECHR 'E'
 ETOK 211
 EQUB VE

 EQUB VE                \ Token 214:    ""

 EJMP 15                \ Token 215:    ""
 ECHR ' '
 ETOK 145
 ECHR ' '
 ETWO 'I', 'N'
 ECHR 'C'
 ETWO 'O', 'N'
 ETWO 'N', 'U'
 ECHR 'E'
 ECHR ' '
 EQUB VE

 EJMP 9                 \ Token 216:    ""
 EJMP 8
 EJMP 23
 EJMP 1
 ECHR ' '
 EJMP 26
 ECHR 'M'
 ETWO 'E', 'S'
 ECHR 'S'
 ECHR 'A'
 ETWO 'G', 'E'
 ECHR 'S'
 ECHR ' '
 ETWO 'R', 'E'
 ECHR '@'
 ETWO 'U', 'S'
 EQUB VE

 ECHR 'D'               \ Token 217:    ""
 ECHR 'E'
 EJMP 26
 ETWO 'R', 'E'
 ECHR 'M'
 ECHR 'I'
 ECHR 'G'
 ECHR 'N'
 ECHR 'Y'
 EQUB VE

 ECHR 'D'               \ Token 218:    ""
 ECHR 'E'
 EJMP 26
 ETWO 'S', 'E'
 ECHR 'V'
 ECHR 'I'
 ECHR 'G'
 ECHR 'N'
 ECHR 'Y'
 EQUB VE

 ECHR 'D'               \ Token 219:    ""
 ECHR 'E'
 EJMP 26
 ECHR 'R'
 ECHR 'O'
 ETWO 'M', 'A'
 ECHR 'N'
 ECHR 'C'
 ECHR 'H'
 ECHR 'E'
 EQUB VE

 ETOK 203               \ Token 220:    ""
 EJMP 19
 ETWO 'R', 'E'
 ETWO 'E', 'S'
 ETWO 'D', 'I'
 ETWO 'C', 'E'
 EQUB VE

 ECHR ' '               \ Token 221:    ""
 ETWO 'O', 'N'
 ECHR ' '
 ECHR 'P'
 ETWO 'E', 'N'
 ETWO 'S', 'E'
 ECHR ' '
 ETOK 192
 ETWO 'S', 'E'
 ETWO 'R', 'A'
 ETWO 'I', 'T'
 ECHR ' '
 ETWO 'A', 'L'
 ECHR 'L'
 ECHR '<'
 ECHR ' '
 ECHR 'D'
 ETWO 'A', 'N'
 ECHR 'S'
 ECHR ' '
 ECHR 'C'
 ETWO 'E', 'T'
 ECHR 'T'
 ECHR 'E'
 ECHR ' '
 ECHR 'G'
 ETWO 'A', 'L'
 ECHR 'A'
 ECHR 'X'
 ECHR 'I'
 ECHR 'E'
 EQUB VE

 EJMP 25                \ Token 222:    ""
 EJMP 9
 EJMP 29
 EJMP 14
 EJMP 13
 ECHR ' '
 ETOK 191
 ETOK 154
 ECHR ' '
 EJMP 4
 ETOK 204
 ETOK 181
 ECHR 'S'
 ECHR 'U'
 ECHR 'I'
 ECHR 'S'
 EJMP 26
 ECHR 'A'
 ETWO 'G', 'E'
 ECHR 'N'
 ECHR 'T'
 EJMP 26
 ECHR 'B'
 ETWO 'L', 'A'
 ECHR 'K'
 ECHR 'E'
 ECHR ' '
 ETOK 195
 ETWO 'S', 'E'
 ECHR 'R'
 ECHR 'V'
 ECHR 'I'
 ETWO 'C', 'E'
 ECHR 'S'
 ECHR ' '
 ETWO 'S', 'E'
 ECHR 'C'
 ECHR 'R'
 ETWO 'E', 'T'
 ECHR 'S'
 ETOK 179
 ETWO 'L', 'A'
 EJMP 26
 ECHR 'M'
 ETOK 174
 EJMP 26
 ECHR 'S'
 ECHR 'P'
 ETWO 'A', 'T'
 ECHR 'I'
 ETWO 'A', 'L'
 ECHR 'E'
 ETOK 204
 EJMP 19
 ETWO 'L', 'A'
 EJMP 26
 ECHR 'M'
 ETOK 174
 ETOK 129
 ECHR 'G'
 ETWO 'A', 'R'
 ECHR 'D'
 ECHR '<'
 ECHR ' '
 ETWO 'L', 'E'
 ECHR 'S'
 EJMP 26
 ETWO 'T', 'H'
 ETWO 'A', 'R'
 ECHR 'G'
 ECHR 'O'
 ECHR 'I'
 ECHR 'D'
 ECHR 'S'
 ETOK 183
 ETWO 'D', 'I'
 ETWO 'S', 'T'
 ETWO 'A', 'N'
 ETOK 188
 ECHR 'P'
 ETWO 'E', 'N'
 ECHR 'D'
 ETWO 'A', 'N'
 ECHR 'T'
 ECHR ' '
 ETOK 196
 ECHR 'I'
 ECHR 'E'
 ECHR 'U'
 ECHR 'R'
 ECHR 'S'
 ECHR ' '
 ETWO 'A', 'N'
 ECHR 'N'
 ECHR '<'
 ETWO 'E', 'S'
 ECHR '.'
 EJMP 26
 ETWO 'M', 'A'
 ECHR 'I'
 ECHR 'S'
 ECHR ' '
 ETOK 182
 ECHR 'S'
 ETWO 'I', 'T'
 ECHR 'U'
 ETWO 'A', 'T'
 ECHR 'I'
 ETWO 'O', 'N'
 ETOK 129
 ECHR 'C'
 ECHR 'H'
 ETWO 'A', 'N'
 ECHR 'G'
 ECHR '<'
 ETOK 204
 EJMP 19
 ETWO 'N', 'O'
 ECHR 'S'
 ECHR ' '
 ECHR 'G'
 ETWO 'A', 'R'
 ECHR 'S'
 ECHR ' '
 ECHR 'S'
 ETWO 'O', 'N'
 ECHR 'T'
 ECHR ' '
 ECHR 'P'
 ECHR 'R'
 ETOK 193
 ECHR 'S'
 ETOK 183
 ETWO 'A', 'L'
 ETWO 'L', 'E'
 ECHR 'R'
 ECHR ' '
 ECHR 'J'
 ETWO 'U', 'S'
 ETWO 'Q', 'U'
 ECHR '`'
 ECHR '"'
 ECHR ' '
 ETOK 182
 ECHR 'B'
 ECHR 'A'
 ETWO 'S', 'E'
 ETOK 179
 ETWO 'C', 'E'
 ECHR 'S'
 ECHR ' '
 ECHR 'A'
 ECHR 'S'
 ECHR 'S'
 ECHR 'A'
 ECHR 'S'
 ECHR 'S'
 ETWO 'I', 'N'
 ECHR 'S'
 ETOK 204
 EJMP 24
 EJMP 9
 EJMP 29
 EJMP 19
 ECHR 'N'
 ETWO 'O', 'U'
 ECHR 'S'
 ECHR ' '
 EJMP 13
 ETOK 172
 ECHR 'S'
 ECHR ' '
 ECHR 'O'
 ECHR 'B'
 ECHR 'T'
 ECHR 'E'
 ETWO 'N', 'U'
 ECHR ' '
 ETOK 187
 ECHR 'P'
 ETWO 'L', 'A'
 ECHR 'N'
 ECHR 'S'
 ETOK 179
 ECHR 'D'
 ECHR '<'
 ECHR 'F'
 ETWO 'E', 'N'
 ETWO 'S', 'E'
 ECHR ' '
 ETOK 175
 ECHR ' '
 ETWO 'L', 'E'
 ECHR 'U'
 ECHR 'R'
 ECHR 'S'
 ECHR ' '
 ECHR 'M'
 ETWO 'O', 'N'
 ETOK 195
 ETWO 'O', 'R'
 ECHR 'I'
 ECHR 'G'
 ETWO 'I', 'N'
 ECHR 'E'
 ECHR 'L'
 ECHR 'S'
 ETOK 204
 EJMP 19
 ETOK 187
 ETWO 'I', 'N'
 ETWO 'S', 'E'
 ECHR 'C'
 ECHR 'T'
 ETWO 'E', 'S'
 ECHR ' '
 ECHR 'I'
 ECHR 'G'
 ETWO 'N', 'O'
 ETWO 'R', 'E'
 ECHR 'N'
 ECHR 'T'
 ECHR ' '
 ETOK 192
 ECHR 'N'
 ETWO 'O', 'U'
 ECHR 'S'
 ECHR ' '
 ETOK 172
 ECHR 'S'
 ECHR ' '
 ETWO 'C', 'E'
 ECHR 'S'
 ECHR ' '
 ECHR 'P'
 ETWO 'L', 'A'
 ECHR 'N'
 ECHR 'S'
 ETOK 204
 EJMP 19
 ECHR 'S'
 ECHR 'I'
 ECHR ' '
 ETOK 181
 ETOK 187
 ETWO 'E', 'N'
 ECHR 'V'
 ECHR 'O'
 ECHR 'I'
 ECHR 'E'
 ETOK 183
 ETWO 'N', 'O'
 ECHR 'T'
 ETWO 'R', 'E'
 ECHR ' '
 ECHR 'B'
 ECHR 'A'
 ETWO 'S', 'E'
 ECHR ' '
 ECHR 'D'
 ECHR 'E'
 EJMP 26
 ETWO 'B', 'I'
 ETWO 'R', 'E'
 ETWO 'R', 'A'
 ECHR ','
 ECHR ' '
 ETWO 'I', 'L'
 ECHR 'S'
 ECHR ' '
 ETWO 'I', 'N'
 ECHR 'T'
 ETWO 'E', 'R'
 ETWO 'C', 'E'
 ECHR 'P'
 ECHR 'T'
 ETWO 'E', 'R'
 ETWO 'O', 'N'
 ECHR 'T'
 ECHR ' '
 ETOK 178
 ECHR 'M'
 ETWO 'E', 'S'
 ECHR 'S'
 ECHR 'A'
 ETWO 'G', 'E'
 ECHR '.'
 EJMP 26
 ETWO 'I', 'L'
 ECHR ' '
 ECHR 'M'
 ECHR 'E'
 ECHR ' '
 ECHR 'F'
 ECHR 'A'
 ECHR 'U'
 ECHR 'T'
 ECHR ' '
 ECHR 'U'
 ECHR 'N'
 ETOK 173
 ECHR '<'
 ECHR 'M'
 ECHR 'I'
 ECHR 'S'
 ECHR 'S'
 ECHR 'A'
 ECHR 'I'
 ETWO 'R', 'E'
 ETOK 204
 EJMP 19
 ETOK 190
 ECHR ' '
 ETOK 193
 ETWO 'E', 'S'
 ECHR ' '
 ECHR 'C'
 ECHR 'H'
 ECHR 'O'
 ECHR 'I'
 ECHR 'S'
 ECHR 'I'
 ETOK 204
 EJMP 24
 EJMP 9
 EJMP 23
 EJMP 19
 ETOK 187
 ECHR 'P'
 ETWO 'L', 'A'
 ECHR 'N'
 ECHR 'S'
 ECHR ' '
 ECHR 'S'
 ETWO 'O', 'N'
 ECHR 'T'
 ECHR ' '
 ECHR 'C'
 ECHR 'O'
 ECHR 'D'
 ECHR '<'
 ECHR 'S'
 ECHR ' '
 ETOK 175
 ECHR ' '
 ECHR 'C'
 ETWO 'E', 'T'
 ECHR 'T'
 ECHR 'E'
 ECHR ' '
 ECHR 'T'
 ETWO 'R', 'A'
 ECHR 'N'
 ECHR 'S'
 ECHR 'M'
 ECHR 'I'
 ECHR 'S'
 ECHR 'S'
 ECHR 'I'
 ETWO 'O', 'N'
 ETOK 204
 EJMP 8
 ETOK 190
 ECHR ' '
 ETWO 'S', 'E'
 ETWO 'R', 'E'
 ECHR 'Z'
 ECHR ' '
 ECHR 'P'
 ECHR 'A'
 ECHR 'Y'
 ECHR '<'
 ETOK 204
 EJMP 26
 ECHR 'B'
 ETWO 'O', 'N'
 ECHR 'N'
 ECHR 'E'
 ECHR ' '
 ECHR 'C'
 ECHR 'H'
 ETWO 'A', 'N'
 ETOK 188
 ETOK 154
 ETOK 212
 EJMP 24
 EQUB VE

 EJMP 25                \ Token 223:    ""
 EJMP 9
 EJMP 29
 EJMP 8
 EJMP 14
 EJMP 13
 EJMP 26
 ECHR 'B'
 ETWO 'R', 'A'
 ECHR 'V'
 ECHR 'O'
 ECHR ' '
 ETOK 154
 ETOK 204
 ECHR 'N'
 ETWO 'O', 'U'
 ECHR 'S'
 ECHR ' '
 ECHR 'N'
 ECHR '`'
 ETWO 'O', 'U'
 ECHR 'B'
 ECHR 'L'
 ECHR 'I'
 ETWO 'E', 'R'
 ETWO 'O', 'N'
 ECHR 'S'
 ECHR ' '
 ECHR 'P'
 ECHR 'A'
 ECHR 'S'
 ECHR ' '
 ETOK 188
 ETOK 192
 ETOK 190
 ECHR ' '
 ECHR 'A'
 ETWO 'V', 'E'
 ECHR 'Z'
 ECHR ' '
 ECHR 'F'
 ECHR 'A'
 ETWO 'I', 'T'
 ECHR ' '
 ETOK 175
 ECHR ' '
 ECHR 'N'
 ETWO 'O', 'U'
 ECHR 'S'
 ETOK 204
 EJMP 19
 ECHR 'N'
 ETWO 'O', 'U'
 ECHR 'S'
 ECHR ' '
 ECHR 'I'
 ECHR 'G'
 ETWO 'N', 'O'
 ECHR 'R'
 ECHR 'I'
 ETWO 'O', 'N'
 ECHR 'S'
 ECHR ' '
 ETOK 192
 ETWO 'L', 'E'
 ECHR 'S'
 EJMP 26
 ETWO 'T', 'H'
 ETWO 'A', 'R'
 ECHR 'G'
 ECHR 'O'
 ECHR 'I'
 ECHR 'D'
 ECHR 'S'
 ECHR ' '
 ECHR 'A'
 ECHR 'V'
 ECHR 'A'
 ECHR 'I'
 ETWO 'E', 'N'
 ECHR 'T'
 ECHR ' '
 ECHR 'C'
 ETWO 'O', 'N'
 ECHR 'S'
 ECHR 'C'
 ECHR 'I'
 ETWO 'E', 'N'
 ETWO 'C', 'E'
 ETOK 179
 ECHR 'V'
 ECHR 'O'
 ECHR 'T'
 ETWO 'R', 'E'
 ECHR ' '
 ECHR 'E'
 ECHR 'X'
 ECHR 'I'
 ETWO 'S', 'T'
 ETWO 'E', 'N'
 ETWO 'C', 'E'
 ETOK 204
 ECHR 'A'
 ECHR 'C'
 ETWO 'C', 'E'
 ECHR 'P'
 ECHR 'T'
 ECHR 'E'
 ECHR 'Z'
 ECHR ' '
 ECHR 'U'
 ECHR 'N'
 ECHR 'E'
 ECHR ' '
 ECHR 'U'
 ECHR 'N'
 ETWO 'I', 'T'
 ECHR '<'
 ECHR ' '
 ECHR 'D'
 ECHR '`'
 ECHR '<'
 ECHR 'N'
 ETWO 'E', 'R'
 ECHR 'G'
 ECHR 'I'
 ECHR 'E'
 ECHR ' '
 ECHR 'M'
 ETOK 174
 ECHR ' '
 ECHR 'C'
 ECHR 'O'
 ECHR 'M'
 ECHR 'M'
 ECHR 'E'
 ECHR ' '
 ECHR 'P'
 ECHR 'A'
 ECHR 'I'
 ECHR 'E'
 ECHR 'M'
 ETWO 'E', 'N'
 ECHR 'T'
 ETOK 212
 EJMP 24
 EQUB VE

 EQUB VE                \ Token 224:    ""

 EQUB VE                \ Token 225:    ""

 EQUB VE                \ Token 226:    ""

 EQUB VE                \ Token 227:    ""

 EQUB VE                \ Token 228:    ""

 EQUB VE                \ Token 229:    ""

 EQUB VE                \ Token 230:    ""

 EQUB VE                \ Token 231:    ""

 EQUB VE                \ Token 232:    ""

 EQUB VE                \ Token 233:    ""

 EQUB VE                \ Token 234:    ""

 EQUB VE                \ Token 235:    ""

 EQUB VE                \ Token 236:    ""

 EQUB VE                \ Token 237:    ""

 EQUB VE                \ Token 238:    ""

 EQUB VE                \ Token 239:    ""

 EQUB VE                \ Token 240:    ""

 EQUB VE                \ Token 241:    ""

 EQUB VE                \ Token 242:    ""

 EQUB VE                \ Token 243:    ""

 EQUB VE                \ Token 244:    ""

 EQUB VE                \ Token 245:    ""

 EQUB VE                \ Token 246:    ""

 EQUB VE                \ Token 247:    ""

 EQUB VE                \ Token 248:    ""

 EQUB VE                \ Token 249:    ""

 EQUB VE                \ Token 250:    ""

 EQUB VE                \ Token 251:    ""

 EQUB VE                \ Token 252:    ""

 EQUB VE                \ Token 253:    ""

 EQUB VE                \ Token 254:    ""

 EQUB VE                \ Token 255:    ""

\ ******************************************************************************
\
\       Name: RUPLA_FR
\       Type: Variable
\   Category: Text
\    Summary: System numbers that have extended decription overrides (French)
\  Deep dive: Extended system descriptions
\             Extended text tokens
\
\ ------------------------------------------------------------------------------
\
\ This table contains the extended token numbers to show as the specified
\ system's extended description, if the criteria in the RUGAL_FR table are met.
\
\ The three variables work as follows:
\
\   * The RUPLA_FR table contains the system numbers
\
\   * The RUGAL_FR table contains the galaxy numbers and mission criteria
\
\   * The RUTOK_FR table contains the extended token to display instead of the
\     normal extended description if the criteria in RUPLA_FR and RUGAL_FR are
\     met
\
\ See the PDESC routine for details of how extended system descriptions work.
\
\ ******************************************************************************

.RUPLA_FR

 EQUB 211               \ System 211, Galaxy 0                 Teorge = Token  1
 EQUB 150               \ System 150, Galaxy 0, Mission 1        Xeer = Token  2
 EQUB 36                \ System  36, Galaxy 0, Mission 1    Reesdice = Token  3
 EQUB 28                \ System  28, Galaxy 0, Mission 1       Arexe = Token  4
 EQUB 253               \ System 253, Galaxy 1, Mission 1      Errius = Token  5
 EQUB 79                \ System  79, Galaxy 1, Mission 1      Inbibe = Token  6
 EQUB 53                \ System  53, Galaxy 1, Mission 1       Ausar = Token  7
 EQUB 118               \ System 118, Galaxy 1, Mission 1      Usleri = Token  8
 EQUB 32                \ System  32, Galaxy 1, Mission 1      Bebege = Token  9
 EQUB 68                \ System  68, Galaxy 1, Mission 1      Cearso = Token 10
 EQUB 164               \ System 164, Galaxy 1, Mission 1      Dicela = Token 11
 EQUB 220               \ System 220, Galaxy 1, Mission 1      Eringe = Token 12
 EQUB 106               \ System 106, Galaxy 1, Mission 1      Gexein = Token 13
 EQUB 16                \ System  16, Galaxy 1, Mission 1      Isarin = Token 14
 EQUB 162               \ System 162, Galaxy 1, Mission 1    Letibema = Token 15
 EQUB 3                 \ System   3, Galaxy 1, Mission 1      Maisso = Token 16
 EQUB 107               \ System 107, Galaxy 1, Mission 1        Onen = Token 17
 EQUB 26                \ System  26, Galaxy 1, Mission 1      Ramaza = Token 18
 EQUB 192               \ System 192, Galaxy 1, Mission 1      Sosole = Token 19
 EQUB 184               \ System 184, Galaxy 1, Mission 1      Tivere = Token 20
 EQUB 5                 \ System   5, Galaxy 1, Mission 1      Veriar = Token 21
 EQUB 101               \ System 101, Galaxy 2, Mission 1      Xeveon = Token 22
 EQUB 193               \ System 193, Galaxy 1, Mission 1      Orarra = Token 23

\ ******************************************************************************
\
\       Name: RUGAL_FR
\       Type: Variable
\   Category: Text
\    Summary: The criteria for systems with extended decription overrides
\             (French)
\  Deep dive: Extended system descriptions
\             Extended text tokens
\
\ ------------------------------------------------------------------------------
\
\ This table contains the criteria for printing an extended decription override
\ for a system. The galaxy number is in bits 0-6, while bit 7 determines whether
\ to show this token during mission 1 only (bit 7 is clear, i.e. a value of &0x
\ in the table below), or all of the time (bit 7 is set, i.e. a value of &8x in
\ the table below).
\
\ In other words, Teorge has an extended decription override description that is
\ always shown, while the rest only appear when mission 1 is in progress.
\
\ The three variables work as follows:
\
\   * The RUPLA_FR table contains the system numbers
\
\   * The RUGAL_FR table contains the galaxy numbers and mission criteria
\
\   * The RUTOK_FR table contains the extended token to display instead of the
\     normal extended description if the criteria in RUPLA_FR and RUGAL_FR are
\     met
\
\ See the PDESC routine for details of how extended system descriptions work.
\
\ ******************************************************************************

.RUGAL_FR

 EQUB &80               \ System 211, Galaxy 0                 Teorge = Token  1
 EQUB &00               \ System 150, Galaxy 0, Mission 1        Xeer = Token  2
 EQUB &00               \ System  36, Galaxy 0, Mission 1    Reesdice = Token  3
 EQUB &00               \ System  28, Galaxy 0, Mission 1       Arexe = Token  4
 EQUB &01               \ System 253, Galaxy 1, Mission 1      Errius = Token  5
 EQUB &01               \ System  79, Galaxy 1, Mission 1      Inbibe = Token  6
 EQUB &01               \ System  53, Galaxy 1, Mission 1       Ausar = Token  7
 EQUB &01               \ System 118, Galaxy 1, Mission 1      Usleri = Token  8
 EQUB &01               \ System  32, Galaxy 1, Mission 1      Bebege = Token  9
 EQUB &01               \ System  68, Galaxy 1, Mission 1      Cearso = Token 10
 EQUB &01               \ System 164, Galaxy 1, Mission 1      Dicela = Token 11
 EQUB &01               \ System 220, Galaxy 1, Mission 1      Eringe = Token 12
 EQUB &01               \ System 106, Galaxy 1, Mission 1      Gexein = Token 13
 EQUB &01               \ System  16, Galaxy 1, Mission 1      Isarin = Token 14
 EQUB &01               \ System 162, Galaxy 1, Mission 1    Letibema = Token 15
 EQUB &01               \ System   3, Galaxy 1, Mission 1      Maisso = Token 16
 EQUB &01               \ System 107, Galaxy 1, Mission 1        Onen = Token 17
 EQUB &01               \ System  26, Galaxy 1, Mission 1      Ramaza = Token 18
 EQUB &01               \ System 192, Galaxy 1, Mission 1      Sosole = Token 19
 EQUB &01               \ System 184, Galaxy 1, Mission 1      Tivere = Token 20
 EQUB &01               \ System   5, Galaxy 1, Mission 1      Veriar = Token 21
 EQUB &02               \ System 101, Galaxy 2, Mission 1      Xeveon = Token 22
 EQUB &01               \ System 193, Galaxy 1, Mission 1      Orarra = Token 23

\ ******************************************************************************
\
\       Name: RUTOK_FR
\       Type: Variable
\   Category: Text
\    Summary: The second extended token table for recursive tokens 0-26 (DETOK3)
\             (French)
\  Deep dive: Extended system descriptions
\             Extended text tokens
\
\ ------------------------------------------------------------------------------
\
\ Contains the tokens for extended description overrides of systems that match
\ the system number in RUPLA_FR and the conditions in RUGAL_FR.
\
\ The three variables work as follows:
\
\   * The RUPLA_FR table contains the system numbers
\
\   * The RUGAL_FR table contains the galaxy numbers and mission criteria
\
\   * The RUTOK_FR table contains the extended token to display instead of the
\     normal extended description if the criteria in RUPLA_FR and RUGAL_FR are
\     met
\
\ See the PDESC routine for details of how extended system descriptions work.
\
\ ******************************************************************************

.RUTOK_FR

 EQUB VE                \ Token 0:      ""

 EJMP 19                \ Token 1:      ""
 ETWO 'L', 'E'
 ECHR 'S'
 ECHR ' '
 ECHR 'C'
 ECHR 'O'
 ECHR 'L'
 ETWO 'O', 'N'
 ECHR 'I'
 ECHR 'S'
 ETWO 'A', 'T'
 ECHR 'E'
 ECHR 'U'
 ECHR 'R'
 ECHR 'S'
 ECHR ' '
 ETWO 'O', 'N'
 ECHR 'T'
 ECHR ' '
 ECHR 'V'
 ECHR 'I'
 ECHR 'O'
 ECHR 'L'
 ECHR '<'
 ECHR ' '
 ETWO 'L', 'E'
 EJMP 26
 ECHR 'P'
 ECHR 'R'
 ECHR 'O'
 ECHR 'T'
 ECHR 'O'
 ECHR 'C'
 ECHR 'O'
 ETWO 'L', 'E'
 EJMP 26
 ETWO 'I', 'N'
 ECHR 'T'
 ETWO 'E', 'R'
 ECHR 'G'
 ETWO 'A', 'L'
 ECHR 'A'
 ECHR 'C'
 ETWO 'T', 'I'
 ETWO 'Q', 'U'
 ECHR 'E'
 ECHR ','
 ECHR ' '
 ETWO 'I', 'L'
 ECHR ' '
 ECHR 'F'
 ECHR 'A'
 ECHR 'U'
 ECHR 'T'
 ECHR ' '
 ETWO 'L', 'E'
 ECHR 'S'
 ECHR ' '
 ECHR '<'
 ECHR 'V'
 ETWO 'I', 'T'
 ETWO 'E', 'R'
 EQUB VE

 EJMP 19                \ Token 2:      ""
 ETWO 'L', 'E'
 ECHR ' '
 ECHR 'C'
 ETWO 'O', 'N'
 ETWO 'S', 'T'
 ECHR 'R'
 ECHR 'I'
 ECHR 'C'
 ECHR 'T'
 ETWO 'O', 'R'
 ECHR ' '
 ETOK 203
 EJMP 19
 ETWO 'R', 'E'
 ETWO 'E', 'S'
 ETWO 'D', 'I'
 ETWO 'C', 'E'
 ECHR ','
 ECHR ' '
 ETOK 154
 EQUB VE

 EJMP 19                \ Token 3:      ""
 ECHR 'U'
 ECHR 'N'
 ECHR ' '
 ECHR 'N'
 ECHR 'A'
 ECHR 'V'
 ECHR 'I'
 ETWO 'R', 'E'
 ECHR ' '
 ETWO 'R', 'E'
 ECHR 'D'
 ETWO 'O', 'U'
 ECHR 'T'
 ETWO 'A', 'B'
 ETWO 'L', 'E'
 ECHR ' '
 ECHR 'E'
 ETWO 'S', 'T'
 ECHR ' '
 ECHR 'P'
 ETWO 'A', 'R'
 ETWO 'T', 'I'
 ECHR ' '
 ECHR 'D'
 ECHR '`'
 ECHR 'I'
 ECHR 'C'
 ECHR 'I'
 ECHR '.'
 EJMP 26
 ETWO 'I', 'L'
 ECHR ' '
 ETWO 'S', 'E'
 ECHR 'M'
 ECHR 'B'
 ETWO 'L', 'A'
 ETWO 'I', 'T'
 ECHR ' '
 ETWO 'A', 'L'
 ETWO 'L', 'E'
 ECHR 'R'
 ECHR ' '
 ECHR '"'
 EJMP 26
 ETWO 'A', 'R'
 ECHR 'E'
 ETWO 'X', 'E'
 EQUB VE

 EJMP 19                \ Token 4:      ""
 ETWO 'O', 'U'
 ECHR 'I'
 ECHR ','
 ECHR ' '
 ETWO 'C', 'E'
 ECHR ' '
 ECHR 'P'
 ECHR 'U'
 ECHR 'I'
 ECHR 'S'
 ECHR 'S'
 ETWO 'A', 'N'
 ECHR 'T'
 ECHR ' '
 ECHR 'N'
 ECHR 'A'
 ECHR 'V'
 ECHR 'I'
 ETWO 'R', 'E'
 ECHR ' '
 ECHR 'A'
 ECHR 'V'
 ECHR 'A'
 ETWO 'I', 'T'
 ECHR ' '
 ECHR 'U'
 ECHR 'N'
 ECHR ' '
 ECHR 'P'
 ECHR 'R'
 ECHR 'O'
 ECHR 'P'
 ECHR 'U'
 ECHR 'L'
 ETWO 'S', 'E'
 ECHR 'U'
 ECHR 'R'
 EJMP 26
 ECHR 'G'
 ETWO 'A', 'L'
 ECHR 'A'
 ECHR 'C'
 ETWO 'T', 'I'
 ETWO 'Q', 'U'
 ECHR 'E'
 ECHR ' '
 ETWO 'I', 'N'
 ECHR 'C'
 ETWO 'O', 'R'
 ECHR 'P'
 ETWO 'O', 'R'
 ECHR '<'
 EQUB VE

 EJMP 19                \ Token 5:      ""
 ETWO 'O', 'U'
 ECHR 'I'
 ECHR ','
 ECHR ' '
 ECHR 'U'
 ECHR 'N'
 ECHR ' '
 ECHR 'N'
 ECHR 'A'
 ECHR 'V'
 ECHR 'I'
 ETWO 'R', 'E'
 ECHR ' '
 ETWO 'R', 'E'
 ECHR 'D'
 ETWO 'O', 'U'
 ECHR 'T'
 ETWO 'A', 'B'
 ETWO 'L', 'E'
 ECHR ' '
 ECHR 'A'
 ECHR ' '
 ECHR 'S'
 ECHR 'U'
 ECHR 'R'
 ECHR 'G'
 ECHR 'I'
 ECHR ' '
 ECHR 'D'
 ECHR 'E'
 ECHR ' '
 ETWO 'N', 'U'
 ECHR 'L'
 ETWO 'L', 'E'
 ECHR ' '
 ECHR 'P'
 ETWO 'A', 'R'
 ECHR 'T'
 ECHR '.'
 EJMP 26
 ECHR 'J'
 ECHR 'E'
 ECHR ' '
 ECHR 'C'
 ECHR 'R'
 ECHR 'O'
 ECHR 'I'
 ECHR 'S'
 ECHR ' '
 ETWO 'Q', 'U'
 ECHR '`'
 ETWO 'I', 'L'
 ECHR ' '
 ETWO 'A', 'L'
 ETWO 'L', 'A'
 ETWO 'I', 'T'
 ECHR ' '
 ECHR '"'
 EJMP 26
 ETWO 'I', 'N'
 ETWO 'B', 'I'
 ETWO 'B', 'E'
 EQUB VE

 EJMP 19                \ Token 6:      ""
 ECHR 'U'
 ECHR 'N'
 ECHR ' '
 ECHR 'N'
 ECHR 'A'
 ECHR 'V'
 ECHR 'I'
 ETWO 'R', 'E'
 ECHR ' '
 ERND 24
 ECHR ' '
 ECHR 'M'
 ECHR '`'
 ECHR 'A'
 ECHR ' '
 ECHR 'C'
 ECHR 'H'
 ETWO 'E', 'R'
 ECHR 'C'
 ECHR 'H'
 ECHR '<'
 ECHR ' '
 ECHR '"'
 EJMP 26
 ECHR 'A'
 ETWO 'U', 'S'
 ETWO 'A', 'R'
 ECHR '.'
 EJMP 26
 ECHR 'M'
 ETWO 'E', 'S'
 ECHR ' '
 ETWO 'L', 'A'
 ETWO 'S', 'E'
 ECHR 'R'
 ECHR 'S'
 ECHR ' '
 ECHR 'N'
 ECHR '`'
 ETWO 'O', 'N'
 ECHR 'T'
 ECHR ' '
 ECHR 'R'
 ECHR 'I'
 ETWO 'E', 'N'
 ECHR ' '
 ECHR 'P'
 ECHR 'U'
 ECHR ' '
 ECHR 'F'
 ECHR 'A'
 ECHR 'I'
 ETWO 'R', 'E'
 ECHR ' '
 ECHR 'C'
 ETWO 'O', 'N'
 ECHR 'T'
 ETWO 'R', 'E'
 ECHR ' '
 ETWO 'C', 'E'
 ECHR ' '
 ECHR 'V'
 ECHR 'A'
 ECHR 'U'
 ECHR 'R'
 ECHR 'I'
 ETWO 'E', 'N'
 EQUB VE

 EJMP 19                \ Token 7:      ""
 ECHR 'U'
 ECHR 'N'
 ECHR ' '
 ECHR 'N'
 ECHR 'A'
 ECHR 'V'
 ECHR 'I'
 ETWO 'R', 'E'
 ECHR ' '
 ETWO 'R', 'E'
 ECHR 'D'
 ETWO 'O', 'U'
 ECHR 'T'
 ETWO 'A', 'B'
 ETWO 'L', 'E'
 ECHR ' '
 ECHR 'A'
 ECHR ' '
 ETWO 'T', 'I'
 ECHR 'R'
 ECHR '<'
 ECHR ' '
 ECHR 'S'
 ECHR 'U'
 ECHR 'R'
 ECHR ' '
 ETWO 'B', 'E'
 ECHR 'A'
 ECHR 'U'
 ECHR 'C'
 ETWO 'O', 'U'
 ECHR 'P'
 ECHR ' '
 ECHR 'D'
 ECHR 'E'
 ECHR ' '
 ECHR 'P'
 ECHR 'I'
 ECHR 'R'
 ETWO 'A', 'T'
 ETWO 'E', 'S'
 ECHR ','
 ECHR ' '
 ECHR 'P'
 ECHR 'U'
 ECHR 'I'
 ECHR 'S'
 ECHR ' '
 ETWO 'I', 'L'
 ECHR ' '
 ECHR 'E'
 ETWO 'S', 'T'
 ECHR ' '
 ECHR 'P'
 ETWO 'A', 'R'
 ETWO 'T', 'I'
 ECHR ' '
 ECHR 'V'
 ETWO 'E', 'R'
 ECHR 'S'
 EJMP 26
 ETWO 'U', 'S'
 ETWO 'L', 'E'
 ECHR 'R'
 ECHR 'I'
 EQUB VE

 EJMP 19                \ Token 8:      ""
 ECHR 'V'
 ETWO 'O', 'U'
 ECHR 'S'
 ECHR ' '
 ECHR 'P'
 ETWO 'O', 'U'
 ETWO 'V', 'E'
 ECHR 'Z'
 ECHR ' '
 ETWO 'A', 'L'
 ETWO 'L', 'E'
 ECHR 'R'
 ECHR ' '
 ECHR 'V'
 ECHR 'O'
 ECHR 'I'
 ECHR 'R'
 ECHR ' '
 ETWO 'C', 'E'
 ECHR ' '
 ECHR 'V'
 ECHR 'A'
 ECHR 'U'
 ECHR 'R'
 ECHR 'I'
 ETWO 'E', 'N'
 ECHR '.'
 EJMP 26
 ETWO 'I', 'L'
 ECHR ' '
 ECHR 'E'
 ETWO 'S', 'T'
 ECHR ' '
 ECHR '"'
 EJMP 26
 ETWO 'O', 'R'
 ETWO 'A', 'R'
 ETWO 'R', 'A'
 EQUB VE

 ERND 25                \ Token 9:      ""
 EQUB VE

 ERND 25                \ Token 10:     ""
 EQUB VE

 ERND 25                \ Token 11:     ""
 EQUB VE

 ERND 25                \ Token 12:     ""
 EQUB VE

 ERND 25                \ Token 13:     ""
 EQUB VE

 ERND 25                \ Token 14:     ""
 EQUB VE

 ERND 25                \ Token 15:     ""
 EQUB VE

 ERND 25                \ Token 16:     ""
 EQUB VE

 ERND 25                \ Token 17:     ""
 EQUB VE

 ERND 25                \ Token 18:     ""
 EQUB VE

 ERND 25                \ Token 19:     ""
 EQUB VE

 ERND 25                \ Token 20:     ""
 EQUB VE

 ERND 25                \ Token 21:     ""
 EQUB VE

 EJMP 19                \ Token 22:     ""
 ETWO 'C', 'E'
 ECHR ' '
 ECHR 'N'
 ECHR '`'
 ECHR 'E'
 ETWO 'S', 'T'
 ECHR ' '
 ECHR 'P'
 ECHR 'A'
 ECHR 'S'
 ECHR ' '
 ETOK 182
 ECHR 'B'
 ETWO 'O', 'N'
 ECHR 'N'
 ECHR 'E'
 ECHR ' '
 ECHR 'G'
 ETWO 'A', 'L'
 ECHR 'A'
 ECHR 'X'
 ECHR 'I'
 ECHR 'E'
 ECHR '!'
 EQUB VE

 EJMP 19                \ Token 23:     ""
 ETWO 'I', 'L'
 ECHR ' '
 ECHR 'Y'
 ECHR ' '
 ECHR 'A'
 ECHR ' '
 ECHR 'U'
 ECHR 'N'
 ECHR ' '
 ECHR 'P'
 ECHR 'I'
 ECHR 'R'
 ETWO 'A', 'T'
 ECHR 'E'
 ECHR ' '
 ERND 24
 ECHR ' '
 ECHR 'C'
 ECHR 'R'
 ECHR 'U'
 ECHR 'E'
 ECHR 'L'
 ECHR ' '
 ECHR 'L'
 ECHR '"'
 ECHR '-'
 ECHR 'B'
 ECHR 'A'
 ECHR 'S'
 EQUB VE

\ ******************************************************************************
\
\       Name: CHAR
\       Type: Macro
\   Category: Text
\    Summary: Macro definition for characters in the recursive token table
\  Deep dive: Printing text tokens
\
\ ------------------------------------------------------------------------------
\
\ The following macro is used when building the recursive token table:
\
\   CHAR 'x'            Insert ASCII character "x"
\
\ To include an apostrophe, use a backtick character, as in CHAR '`'.
\
\ See the deep dive on "Printing text tokens" for details on how characters are
\ stored in the recursive token table.
\
\ Arguments:
\
\   'x'                 The character to insert into the table
\
\ ******************************************************************************

MACRO CHAR x

 IF x = '`'
   EQUB 39 EOR 62
 ELSE
   EQUB x EOR 62
 ENDIF

ENDMACRO

\ ******************************************************************************
\
\       Name: TWOK
\       Type: Macro
\   Category: Text
\    Summary: Macro definition for two-letter tokens in the token table
\  Deep dive: Printing text tokens
\
\ ------------------------------------------------------------------------------
\
\ The following macro is used when building the recursive token table:
\
\   TWOK 'x', 'y'       Insert two-letter token "xy"
\
\ See the deep dive on "Printing text tokens" for details on how two-letter
\ tokens are stored in the recursive token table.
\
\ Arguments:
\
\   'x'                 The first letter of the two-letter token to insert into
\                       the table
\
\   'y'                 The second letter of the two-letter token to insert into
\                       the table
\
\ ******************************************************************************

MACRO TWOK t, k

 IF t = 'A' AND k = 'L' : EQUB 128 EOR 62 : ENDIF
 IF t = 'L' AND k = 'E' : EQUB 129 EOR 62 : ENDIF
 IF t = 'X' AND k = 'E' : EQUB 130 EOR 62 : ENDIF
 IF t = 'G' AND k = 'E' : EQUB 131 EOR 62 : ENDIF
 IF t = 'Z' AND k = 'A' : EQUB 132 EOR 62 : ENDIF
 IF t = 'C' AND k = 'E' : EQUB 133 EOR 62 : ENDIF
 IF t = 'B' AND k = 'I' : EQUB 134 EOR 62 : ENDIF
 IF t = 'S' AND k = 'O' : EQUB 135 EOR 62 : ENDIF
 IF t = 'U' AND k = 'S' : EQUB 136 EOR 62 : ENDIF
 IF t = 'E' AND k = 'S' : EQUB 137 EOR 62 : ENDIF
 IF t = 'A' AND k = 'R' : EQUB 138 EOR 62 : ENDIF
 IF t = 'M' AND k = 'A' : EQUB 139 EOR 62 : ENDIF
 IF t = 'I' AND k = 'N' : EQUB 140 EOR 62 : ENDIF
 IF t = 'D' AND k = 'I' : EQUB 141 EOR 62 : ENDIF
 IF t = 'R' AND k = 'E' : EQUB 142 EOR 62 : ENDIF
 IF t = 'A' AND k = '?' : EQUB 143 EOR 62 : ENDIF
 IF t = 'E' AND k = 'R' : EQUB 144 EOR 62 : ENDIF
 IF t = 'A' AND k = 'T' : EQUB 145 EOR 62 : ENDIF
 IF t = 'E' AND k = 'N' : EQUB 146 EOR 62 : ENDIF
 IF t = 'B' AND k = 'E' : EQUB 147 EOR 62 : ENDIF
 IF t = 'R' AND k = 'A' : EQUB 148 EOR 62 : ENDIF
 IF t = 'L' AND k = 'A' : EQUB 149 EOR 62 : ENDIF
 IF t = 'V' AND k = 'E' : EQUB 150 EOR 62 : ENDIF
 IF t = 'T' AND k = 'I' : EQUB 151 EOR 62 : ENDIF
 IF t = 'E' AND k = 'D' : EQUB 152 EOR 62 : ENDIF
 IF t = 'O' AND k = 'R' : EQUB 153 EOR 62 : ENDIF
 IF t = 'Q' AND k = 'U' : EQUB 154 EOR 62 : ENDIF
 IF t = 'A' AND k = 'N' : EQUB 155 EOR 62 : ENDIF
 IF t = 'T' AND k = 'E' : EQUB 156 EOR 62 : ENDIF
 IF t = 'I' AND k = 'S' : EQUB 157 EOR 62 : ENDIF
 IF t = 'R' AND k = 'I' : EQUB 158 EOR 62 : ENDIF
 IF t = 'O' AND k = 'N' : EQUB 159 EOR 62 : ENDIF

ENDMACRO

\ ******************************************************************************
\
\       Name: CONT
\       Type: Macro
\   Category: Text
\    Summary: Macro definition for control codes in the recursive token table
\  Deep dive: Printing text tokens
\
\ ------------------------------------------------------------------------------
\
\ The following macro is used when building the recursive token table:
\
\   CONT n              Insert control code token {n}
\
\ See the deep dive on "Printing text tokens" for details on how characters are
\ stored in the recursive token table.
\
\ Arguments:
\
\   n                   The control code to insert into the table
\
\ ******************************************************************************

MACRO CONT n

 EQUB n EOR 62

ENDMACRO

\ ******************************************************************************
\
\       Name: RTOK
\       Type: Macro
\   Category: Text
\    Summary: Macro definition for recursive tokens in the recursive token table
\  Deep dive: Printing text tokens
\
\ ------------------------------------------------------------------------------
\
\ The following macro is used when building the recursive token table:
\
\   RTOK n              Insert recursive token [n]
\
\                         * Tokens 0-95 get stored as n + 160
\
\                         * Tokens 128-145 get stored as n - 114
\
\                         * Tokens 96-127 get stored as n
\
\ See the deep dive on "Printing text tokens" for details on how recursive
\ tokens are stored in the recursive token table.
\
\ Arguments:
\
\   n                   The number of the recursive token to insert into the
\                       table, in the range 0 to 145
\
\ ******************************************************************************

MACRO RTOK n

 IF n >= 0 AND n <= 95
  t = n + 160
 ELIF n >= 128
  t = n - 114
 ELSE
  t = n
 ENDIF

 EQUB t EOR 62

ENDMACRO

.QQ18

 RTOK 111               \ Token 0:      ""
 RTOK 131
 CONT 7
 EQUB 0

 CHAR ' '               \ Token 1:      ""
 CHAR 'C'
 CHAR 'H'
 TWOK 'A', 'R'
 CHAR 'T'
 EQUB 0

 CHAR 'G'               \ Token 2:      ""
 CHAR 'O'
 CHAR 'V'
 TWOK 'E', 'R'
 CHAR 'N'
 CHAR 'M'
 TWOK 'E', 'N'
 CHAR 'T'
 EQUB 0

 CHAR 'D'               \ Token 3:      ""
 TWOK 'A', 'T'
 CHAR 'A'
 RTOK 131
 CONT 3
 EQUB 0

 TWOK 'I', 'N'          \ Token 4:      ""
 CHAR 'V'
 TWOK 'E', 'N'
 CHAR 'T'
 TWOK 'O', 'R'
 CHAR 'Y'
 CONT 12
 EQUB 0

 CHAR 'S'               \ Token 5:      ""
 CHAR 'Y'
 CHAR 'S'
 TWOK 'T', 'E'
 CHAR 'M'
 EQUB 0

 CHAR 'P'               \ Token 6:      ""
 TWOK 'R', 'I'
 TWOK 'C', 'E'
 EQUB 0

 CONT 2                 \ Token 7:      ""
 CHAR ' '
 CHAR 'M'
 TWOK 'A', 'R'
 CHAR 'K'
 CHAR 'E'
 CHAR 'T'
 CHAR ' '
 RTOK 6
 CHAR 'S'
 EQUB 0

 TWOK 'I', 'N'          \ Token 8:      ""
 CHAR 'D'
 TWOK 'U', 'S'
 CHAR 'T'
 TWOK 'R', 'I'
 CHAR 'A'
 CHAR 'L'
 EQUB 0

 CHAR 'A'               \ Token 9:      ""
 CHAR 'G'
 TWOK 'R', 'I'
 CHAR 'C'
 CHAR 'U'
 CHAR 'L'
 CHAR 'T'
 CHAR 'U'
 TWOK 'R', 'A'
 CHAR 'L'
 EQUB 0

 TWOK 'R', 'I'          \ Token 10:     ""
 CHAR 'C'
 CHAR 'H'
 CHAR ' '
 EQUB 0

 RTOK 139               \ Token 11:     ""
 CHAR ' '
 EQUB 0

 RTOK 138               \ Token 12:     ""
 CHAR ' '
 EQUB 0

 TWOK 'M', 'A'          \ Token 13:     ""
 TWOK 'I', 'N'
 CHAR 'L'
 CHAR 'Y'
 CHAR ' '
 EQUB 0

 CHAR 'U'               \ Token 14:     ""
 CHAR 'N'
 CHAR 'I'
 CHAR 'T'
 EQUB 0

 CHAR 'V'               \ Token 15:     ""
 CHAR 'I'
 CHAR 'E'
 CHAR 'W'
 CHAR ' '
 EQUB 0

 EQUB 0                 \ Token 16:     ""

 TWOK 'A', 'N'          \ Token 17:     ""
 TWOK 'A', 'R'
 CHAR 'C'
 CHAR 'H'
 CHAR 'Y'
 EQUB 0

 CHAR 'F'               \ Token 18:     ""
 CHAR 'E'
 CHAR 'U'
 CHAR 'D'
 CHAR 'A'
 CHAR 'L'
 EQUB 0

 CHAR 'M'               \ Token 19:     ""
 CHAR 'U'
 CHAR 'L'
 TWOK 'T', 'I'
 CHAR '-'
 CONT 6
 RTOK 2
 EQUB 0

 TWOK 'D', 'I'          \ Token 20:     ""
 CHAR 'C'
 CHAR 'T'
 TWOK 'A', 'T'
 TWOK 'O', 'R'
 RTOK 25
 EQUB 0

 RTOK 91                \ Token 21:     ""
 CHAR 'M'
 CHAR 'U'
 CHAR 'N'
 TWOK 'I', 'S'
 CHAR 'T'
 EQUB 0

 CHAR 'C'               \ Token 22:     ""
 TWOK 'O', 'N'
 CHAR 'F'
 TWOK 'E', 'D'
 TWOK 'E', 'R'
 CHAR 'A'
 CHAR 'C'
 CHAR 'Y'
 EQUB 0

 CHAR 'D'               \ Token 23:     ""
 CHAR 'E'
 CHAR 'M'
 CHAR 'O'
 CHAR 'C'
 TWOK 'R', 'A'
 CHAR 'C'
 CHAR 'Y'
 EQUB 0

 CHAR 'C'               \ Token 24:     ""
 TWOK 'O', 'R'
 CHAR 'P'
 TWOK 'O', 'R'
 TWOK 'A', 'T'
 CHAR 'E'
 CHAR ' '
 RTOK 43
 TWOK 'A', 'T'
 CHAR 'E'
 EQUB 0

 CHAR 'S'               \ Token 25:     ""
 CHAR 'H'
 CHAR 'I'
 CHAR 'P'
 EQUB 0

 CHAR 'P'               \ Token 26:     ""
 RTOK 94
 CHAR 'D'
 CHAR 'U'
 CHAR 'C'
 CHAR 'T'
 EQUB 0

 CHAR ' '               \ Token 27:     ""
 TWOK 'L', 'A'
 CHAR 'S'
 TWOK 'E', 'R'
 EQUB 0

 CHAR 'H'               \ Token 28:     ""
 CHAR 'U'
 TWOK 'M', 'A'
 CHAR 'N'
 CHAR ' '
 CHAR 'C'
 CHAR 'O'
 CHAR 'L'
 TWOK 'O', 'N'
 CHAR 'I'
 CHAR 'A'
 CHAR 'L'
 CHAR 'S'
 EQUB 0

 CHAR 'H'               \ Token 29:     ""
 CHAR 'Y'
 CHAR 'P'
 TWOK 'E', 'R'
 CHAR 'S'
 CHAR 'P'
 CHAR 'A'
 TWOK 'C', 'E'
 CHAR ' '
 EQUB 0

 CHAR 'S'               \ Token 30:     ""
 CHAR 'H'
 TWOK 'O', 'R'
 CHAR 'T'
 CHAR ' '
 RTOK 42
 RTOK 1
 EQUB 0

 TWOK 'D', 'I'          \ Token 31:     ""
 RTOK 43
 TWOK 'A', 'N'
 TWOK 'C', 'E'
 EQUB 0

 CHAR 'P'               \ Token 32:     ""
 CHAR 'O'
 CHAR 'P'
 CHAR 'U'
 CHAR 'L'
 TWOK 'A', 'T'
 CHAR 'I'
 TWOK 'O', 'N'
 EQUB 0

 CHAR 'T'               \ Token 33:     ""
 CHAR 'U'
 CHAR 'R'
 CHAR 'N'
 CHAR 'O'
 CHAR 'V'
 TWOK 'E', 'R'
 EQUB 0

 CHAR 'E'               \ Token 34:     ""
 CHAR 'C'
 TWOK 'O', 'N'
 CHAR 'O'
 CHAR 'M'
 CHAR 'Y'
 EQUB 0

 CHAR ' '               \ Token 35:     ""
 CHAR 'L'
 CHAR 'I'
 CHAR 'G'
 CHAR 'H'
 CHAR 'T'
 CHAR ' '
 CHAR 'Y'
 CHAR 'E'
 TWOK 'A', 'R'
 CHAR 'S'
 EQUB 0

 TWOK 'T', 'E'          \ Token 36:     ""
 CHAR 'C'
 CHAR 'H'
 CHAR '.'
 TWOK 'L', 'E'
 TWOK 'V', 'E'
 CHAR 'L'
 EQUB 0

 CHAR 'C'               \ Token 37:     ""
 CHAR 'A'
 CHAR 'S'
 CHAR 'H'
 EQUB 0

 CHAR ' '               \ Token 38:     ""
 TWOK 'B', 'I'
 CHAR 'L'
 CHAR 'L'
 CHAR 'I'
 TWOK 'O', 'N'
 EQUB 0

 RTOK 122               \ Token 39:     ""
 RTOK 1
 CONT 1
 EQUB 0

 CHAR 'T'               \ Token 40:     ""
 TWOK 'A', 'R'
 TWOK 'G', 'E'
 CHAR 'T'
 CHAR ' '
 CHAR 'L'
 CHAR 'O'
 RTOK 43
 EQUB 0

 RTOK 106               \ Token 41:     ""
 CHAR ' '
 CHAR 'J'
 CHAR 'A'
 CHAR 'M'
 CHAR 'M'
 TWOK 'E', 'D'
 EQUB 0

 TWOK 'R', 'A'          \ Token 42:     ""
 CHAR 'N'
 TWOK 'G', 'E'
 EQUB 0

 CHAR 'S'               \ Token 43:     ""
 CHAR 'T'
 EQUB 0

 EQUB 0                 \ Token 44:     ""

 CHAR 'S'               \ Token 45:     ""
 CHAR 'E'
 CHAR 'L'
 CHAR 'L'
 EQUB 0

 CHAR ' '               \ Token 46:     ""
 CHAR 'C'
 TWOK 'A', 'R'
 CHAR 'G'
 CHAR 'O'
 CONT 6
 EQUB 0

 CHAR 'E'               \ Token 47:     ""
 TWOK 'Q', 'U'
 CHAR 'I'
 CHAR 'P'
 CHAR ' '
 RTOK 25
 EQUB 0

 CHAR 'F'               \ Token 48:     ""
 CHAR 'O'
 CHAR 'O'
 CHAR 'D'
 EQUB 0

 TWOK 'T', 'E'          \ Token 49:     ""
 CHAR 'X'
 TWOK 'T', 'I'
 TWOK 'L', 'E'
 CHAR 'S'
 EQUB 0

 TWOK 'R', 'A'          \ Token 50:     ""
 TWOK 'D', 'I'
 CHAR 'O'
 CHAR 'A'
 CHAR 'C'
 TWOK 'T', 'I'
 CHAR 'V'
 TWOK 'E', 'S'
 EQUB 0

 RTOK 94                \ Token 51:     ""
 CHAR 'B'
 CHAR 'O'
 CHAR 'T'
 CHAR ' '
 CHAR 'S'
 TWOK 'L', 'A'
 CHAR 'V'
 TWOK 'E', 'S'
 EQUB 0

 TWOK 'B', 'E'          \ Token 52:     ""
 CHAR 'V'
 TWOK 'E', 'R'
 CHAR 'A'
 TWOK 'G', 'E'
 CHAR 'S'
 EQUB 0

 CHAR 'L'               \ Token 53:     ""
 CHAR 'U'
 CHAR 'X'
 CHAR 'U'
 TWOK 'R', 'I'
 TWOK 'E', 'S'
 EQUB 0

 CHAR 'R'               \ Token 54:     ""
 TWOK 'A', 'R'
 CHAR 'E'
 CHAR ' '
 CHAR 'S'
 CHAR 'P'
 CHAR 'E'
 CHAR 'C'
 CHAR 'I'
 TWOK 'E', 'S'
 EQUB 0

 RTOK 91                \ Token 55:     ""
 CHAR 'P'
 CHAR 'U'
 CHAR 'T'
 TWOK 'E', 'R'
 CHAR 'S'
 EQUB 0

 TWOK 'M', 'A'          \ Token 56:     ""
 CHAR 'C'
 CHAR 'H'
 TWOK 'I', 'N'
 TWOK 'E', 'R'
 CHAR 'Y'
 EQUB 0

 RTOK 124               \ Token 57:     ""
 CHAR 'O'
 CHAR 'Y'
 CHAR 'S'
 EQUB 0

 CHAR 'F'               \ Token 58:     ""
 CHAR 'I'
 RTOK 97
 CHAR 'M'
 CHAR 'S'
 EQUB 0

 CHAR 'F'               \ Token 59:     ""
 CHAR 'U'
 CHAR 'R'
 CHAR 'S'
 EQUB 0

 CHAR 'M'               \ Token 60:     ""
 TWOK 'I', 'N'
 TWOK 'E', 'R'
 CHAR 'A'
 CHAR 'L'
 CHAR 'S'
 EQUB 0

 CHAR 'G'               \ Token 61:     ""
 CHAR 'O'
 CHAR 'L'
 CHAR 'D'
 EQUB 0

 CHAR 'P'               \ Token 62:     ""
 CHAR 'L'
 TWOK 'A', 'T'
 TWOK 'I', 'N'
 CHAR 'U'
 CHAR 'M'
 EQUB 0

 TWOK 'G', 'E'          \ Token 63:     ""
 CHAR 'M'
 CHAR '-'
 RTOK 43
 TWOK 'O', 'N'
 TWOK 'E', 'S'
 EQUB 0

 CHAR 'A'               \ Token 64:     ""
 CHAR 'L'
 CHAR 'I'
 TWOK 'E', 'N'
 CHAR ' '
 RTOK 127
 CHAR 'S'
 EQUB 0

 EQUB 0                 \ Token 65:     ""

 CHAR ' '               \ Token 66:     ""
 CHAR 'C'
 CHAR 'R'
 EQUB 0

 EQUB 0                 \ Token 67:     ""

 EQUB 0                 \ Token 68:     ""

 EQUB 0                 \ Token 69:     ""

 CHAR 'G'               \ Token 70:     ""
 TWOK 'R', 'E'
 TWOK 'E', 'N'
 EQUB 0

 TWOK 'R', 'E'          \ Token 71:     ""
 CHAR 'D'
 EQUB 0

 CHAR 'Y'               \ Token 72:     ""
 CHAR 'E'
 CHAR 'L'
 CHAR 'L'
 CHAR 'O'
 CHAR 'W'
 EQUB 0

 CHAR 'B'               \ Token 73:     ""
 CHAR 'L'
 CHAR 'U'
 CHAR 'E'
 EQUB 0

 CHAR 'B'               \ Token 74:     ""
 TWOK 'L', 'A'
 CHAR 'C'
 CHAR 'K'
 EQUB 0

 RTOK 136               \ Token 75:     ""
 EQUB 0

 CHAR 'S'               \ Token 76:     ""
 CHAR 'L'
 CHAR 'I'
 CHAR 'M'
 CHAR 'Y'
 EQUB 0

 CHAR 'B'               \ Token 77:     ""
 CHAR 'U'
 CHAR 'G'
 CHAR '-'
 CHAR 'E'
 CHAR 'Y'
 TWOK 'E', 'D'
 EQUB 0

 CHAR 'H'               \ Token 78:     ""
 TWOK 'O', 'R'
 CHAR 'N'
 TWOK 'E', 'D'
 EQUB 0

 CHAR 'B'               \ Token 79:     ""
 TWOK 'O', 'N'
 CHAR 'Y'
 EQUB 0

 CHAR 'F'               \ Token 80:     ""
 TWOK 'A', 'T'
 EQUB 0

 CHAR 'F'               \ Token 81:     ""
 CHAR 'U'
 CHAR 'R'
 CHAR 'R'
 CHAR 'Y'
 EQUB 0

 RTOK 94                \ Token 82:     ""
 CHAR 'D'
 TWOK 'E', 'N'
 CHAR 'T'
 CHAR 'S'
 EQUB 0

 CHAR 'F'               \ Token 83:     ""
 RTOK 94
 CHAR 'G'
 CHAR 'S'
 EQUB 0

 CHAR 'L'               \ Token 84:     ""
 CHAR 'I'
 TWOK 'Z', 'A'
 CHAR 'R'
 CHAR 'D'
 CHAR 'S'
 EQUB 0

 CHAR 'L'               \ Token 85:     ""
 CHAR 'O'
 CHAR 'B'
 RTOK 43
 TWOK 'E', 'R'
 CHAR 'S'
 EQUB 0

 TWOK 'B', 'I'          \ Token 86:     ""
 CHAR 'R'
 CHAR 'D'
 CHAR 'S'
 EQUB 0

 CHAR 'H'               \ Token 87:     ""
 CHAR 'U'
 TWOK 'M', 'A'
 CHAR 'N'
 CHAR 'O'
 CHAR 'I'
 CHAR 'D'
 CHAR 'S'
 EQUB 0

 CHAR 'F'               \ Token 88:     ""
 CHAR 'E'
 CHAR 'L'
 TWOK 'I', 'N'
 TWOK 'E', 'S'
 EQUB 0

 TWOK 'I', 'N'          \ Token 89:     ""
 CHAR 'S'
 CHAR 'E'
 CHAR 'C'
 CHAR 'T'
 CHAR 'S'
 EQUB 0

 TWOK 'R', 'A'          \ Token 90:     ""
 TWOK 'D', 'I'
 TWOK 'U', 'S'
 EQUB 0

 CHAR 'C'               \ Token 91:     ""
 CHAR 'O'
 CHAR 'M'
 EQUB 0

 RTOK 91                \ Token 92:     ""
 TWOK 'M', 'A'
 CHAR 'N'
 CHAR 'D'
 TWOK 'E', 'R'
 EQUB 0

 CHAR ' '               \ Token 93:     ""
 CHAR 'D'
 TWOK 'E', 'S'
 CHAR 'T'
 RTOK 94
 CHAR 'Y'
 TWOK 'E', 'D'
 EQUB 0

 CHAR 'R'               \ Token 94:     ""
 CHAR 'O'
 EQUB 0

 RTOK 26                \ Token 95:     ""
 CHAR ' '
 CHAR ' '
 CHAR ' '
 RTOK 14
 CHAR ' '
 RTOK 6
 CHAR ' '
 TWOK 'Q', 'U'
 TWOK 'A', 'N'
 TWOK 'T', 'I'
 CHAR 'T'
 CHAR 'Y'
 EQUB 0

 CHAR 'F'               \ Token 96:     ""
 CHAR 'R'
 TWOK 'O', 'N'
 CHAR 'T'
 EQUB 0

 TWOK 'R', 'E'          \ Token 97:     ""
 TWOK 'A', 'R'
 EQUB 0

 TWOK 'L', 'E'          \ Token 98:     ""
 CHAR 'F'
 CHAR 'T'
 EQUB 0

 TWOK 'R', 'I'          \ Token 99:     ""
 CHAR 'G'
 CHAR 'H'
 CHAR 'T'
 EQUB 0

 RTOK 121               \ Token 100:    ""
 CHAR 'L'
 CHAR 'O'
 CHAR 'W'
 CONT 7
 EQUB 0

 RTOK 99                \ Token 101:    ""
 RTOK 131
 RTOK 92
 CHAR '!'
 EQUB 0

 CHAR 'E'               \ Token 102:    ""
 CHAR 'X'
 CHAR 'T'
 TWOK 'R', 'A'
 CHAR ' '
 EQUB 0

 CHAR 'P'               \ Token 103:    ""
 CHAR 'U'
 CHAR 'L'
 CHAR 'S'
 CHAR 'E'
 RTOK 27
 EQUB 0

 TWOK 'B', 'E'          \ Token 104:    ""
 CHAR 'A'
 CHAR 'M'
 RTOK 27
 EQUB 0

 CHAR 'F'               \ Token 105:    ""
 CHAR 'U'
 CHAR 'E'
 CHAR 'L'
 EQUB 0

 CHAR 'M'               \ Token 106:    ""
 TWOK 'I', 'S'
 CHAR 'S'
 CHAR 'I'
 TWOK 'L', 'E'
 EQUB 0

 CHAR 'L'               \ Token 107:    ""
 TWOK 'A', 'R'
 TWOK 'G', 'E'
 CHAR ' '
 CHAR 'C'
 TWOK 'A', 'R'
 CHAR 'G'
 CHAR 'O'
 CHAR ' '
 CHAR 'B'
 CHAR 'A'
 CHAR 'Y'
 EQUB 0

 CHAR 'E'               \ Token 108:    ""
 CHAR '.'
 CHAR 'C'
 CHAR '.'
 CHAR 'M'
 CHAR '.'
 RTOK 5
 EQUB 0

 RTOK 102               \ Token 109:    ""
 RTOK 103
 CHAR 'S'
 EQUB 0

 RTOK 102               \ Token 110:    ""
 RTOK 104
 CHAR 'S'
 EQUB 0

 RTOK 105               \ Token 111:    ""
 CHAR ' '
 CHAR 'S'
 CHAR 'C'
 CHAR 'O'
 CHAR 'O'
 CHAR 'P'
 CHAR 'S'
 EQUB 0

 TWOK 'E', 'S'          \ Token 112:    ""
 CHAR 'C'
 CHAR 'A'
 CHAR 'P'
 CHAR 'E'
 CHAR ' '
 CHAR 'C'
 CHAR 'A'
 CHAR 'P'
 CHAR 'S'
 CHAR 'U'
 TWOK 'L', 'E'
 EQUB 0

 RTOK 121               \ Token 113:    ""
 CHAR 'B'
 CHAR 'O'
 CHAR 'M'
 CHAR 'B'
 EQUB 0

 RTOK 121               \ Token 114:    ""
 RTOK 14
 EQUB 0

 CHAR 'D'               \ Token 115:    ""
 CHAR 'O'
 CHAR 'C'
 CHAR 'K'
 TWOK 'I', 'N'
 CHAR 'G'
 CHAR ' '
 RTOK 55
 EQUB 0

 RTOK 122               \ Token 116:    ""
 CHAR ' '
 CHAR 'H'
 CHAR 'Y'
 CHAR 'P'
 TWOK 'E', 'R'
 CHAR 'S'
 CHAR 'P'
 CHAR 'A'
 TWOK 'C', 'E'
 EQUB 0

 CHAR 'M'               \ Token 117:    ""
 CHAR 'I'
 CHAR 'L'
 CHAR 'I'
 CHAR 'T'
 TWOK 'A', 'R'
 CHAR 'Y'
 RTOK 27
 EQUB 0

 CHAR 'M'               \ Token 118:    ""
 TWOK 'I', 'N'
 TWOK 'I', 'N'
 CHAR 'G'
 RTOK 27
 EQUB 0

 RTOK 37                \ Token 119:    ""
 CHAR ':'
 CONT 0
 EQUB 0

 TWOK 'I', 'N'          \ Token 120:    ""
 RTOK 91
 TWOK 'I', 'N'
 CHAR 'G'
 CHAR ' '
 RTOK 106
 EQUB 0

 TWOK 'E', 'N'          \ Token 121:    ""
 TWOK 'E', 'R'
 CHAR 'G'
 CHAR 'Y'
 CHAR ' '
 EQUB 0

 CHAR 'G'               \ Token 122:    ""
 CHAR 'A'
 TWOK 'L', 'A'
 CHAR 'C'
 TWOK 'T', 'I'
 CHAR 'C'
 EQUB 0

 RTOK 115               \ Token 123:    ""
 RTOK 131
 EQUB 0

 CHAR 'A'               \ Token 124:    ""
 CHAR 'L'
 CHAR 'L'
 EQUB 0

 TWOK 'L', 'E'          \ Token 125:    ""
 CHAR 'G'
 CHAR 'A'
 CHAR 'L'
 CHAR ' '
 RTOK 43
 TWOK 'A', 'T'
 TWOK 'U', 'S'
 CHAR ':'
 EQUB 0

 RTOK 92                \ Token 126:    ""
 CHAR ' '
 CONT 4
 CONT 12
 CONT 12
 CONT 12
 CONT 6
 CHAR 'C'
 CHAR 'U'
 CHAR 'R'
 TWOK 'R', 'E'
 CHAR 'N'
 CHAR 'T'
 CHAR ' '
 RTOK 5
 CONT 9
 CONT 2
 CONT 12
 RTOK 29
 RTOK 5
 CONT 9
 CONT 3
 CONT 12
 CHAR 'C'
 TWOK 'O', 'N'
 TWOK 'D', 'I'
 TWOK 'T', 'I'
 TWOK 'O', 'N'
 CONT 9
 EQUB 0

 CHAR 'I'               \ Token 127:    ""
 TWOK 'T', 'E'
 CHAR 'M'
 EQUB 0

 EQUB 0                 \ Token 128:    ""

 CHAR 'L'               \ Token 129:    ""
 CHAR 'L'
 EQUB 0

 CHAR 'R'               \ Token 130:    ""
 TWOK 'A', 'T'
 TWOK 'I', 'N'
 CHAR 'G'
 EQUB 0

 CHAR ' '               \ Token 131:    ""
 TWOK 'O', 'N'
 CHAR ' '
 EQUB 0

 CONT 12                \ Token 132:    ""
 CHAR 'E'
 TWOK 'Q', 'U'
 CHAR 'I'
 CHAR 'P'
 CHAR 'M'
 TWOK 'E', 'N'
 CHAR 'T'
 CHAR ':'
 EQUB 0

 CHAR 'C'               \ Token 133:    ""
 TWOK 'L', 'E'
 TWOK 'A', 'N'
 EQUB 0

 CHAR 'O'               \ Token 134:    ""
 CHAR 'F'
 CHAR 'F'
 TWOK 'E', 'N'
 CHAR 'D'
 TWOK 'E', 'R'
 EQUB 0

 CHAR 'F'               \ Token 135:    ""
 CHAR 'U'
 CHAR 'G'
 CHAR 'I'
 TWOK 'T', 'I'
 TWOK 'V', 'E'
 EQUB 0

 CHAR 'H'               \ Token 136:    ""
 TWOK 'A', 'R'
 CHAR 'M'
 TWOK 'L', 'E'
 CHAR 'S'
 CHAR 'S'
 EQUB 0

 CHAR 'M'               \ Token 137:    ""
 CHAR 'O'
 RTOK 43
 CHAR 'L'
 CHAR 'Y'
 CHAR ' '
 RTOK 136
 EQUB 0

 CHAR 'P'               \ Token 138:    ""
 CHAR 'O'
 TWOK 'O', 'R'
 EQUB 0

 CHAR 'A'               \ Token 139:    ""
 CHAR 'V'
 TWOK 'E', 'R'
 CHAR 'A'
 TWOK 'G', 'E'
 EQUB 0

 CHAR 'A'               \ Token 140:    ""
 CHAR 'B'
 CHAR 'O'
 TWOK 'V', 'E'
 CHAR ' '
 RTOK 139
 EQUB 0

 RTOK 91                \ Token 141:    ""
 CHAR 'P'
 CHAR 'E'
 CHAR 'T'
 TWOK 'E', 'N'
 CHAR 'T'
 EQUB 0

 CHAR 'D'               \ Token 142:    ""
 TWOK 'A', 'N'
 TWOK 'G', 'E'
 RTOK 94
 TWOK 'U', 'S'
 EQUB 0

 CHAR 'D'               \ Token 143:    ""
 CHAR 'E'
 CHAR 'A'
 CHAR 'D'
 CHAR 'L'
 CHAR 'Y'
 EQUB 0

 CHAR '-'               \ Token 144:    ""
 CHAR '-'
 CHAR '-'
 CHAR '-'
 CHAR ' '
 CHAR 'E'
 CHAR ' '
 CHAR 'L'
 CHAR ' '
 CHAR 'I'
 CHAR ' '
 CHAR 'T'
 CHAR ' '
 CHAR 'E'
 CHAR ' '
 CHAR '-'
 CHAR '-'
 CHAR '-'
 CHAR '-'
 EQUB 0

 CHAR 'P'               \ Token 145:    ""
 CHAR 'R'
 TWOK 'E', 'S'
 TWOK 'E', 'N'
 CHAR 'T'
 EQUB 0

 CONT 8                 \ Token 146:    ""
 CHAR 'G'
 CHAR 'A'
 CHAR 'M'
 CHAR 'E'
 CHAR ' '
 CHAR 'O'
 CHAR 'V'
 TWOK 'E', 'R'
 EQUB 0

 CHAR '6'               \ Token 147:    ""
 CHAR '0'
 CHAR ' '
 CHAR 'S'
 CHAR 'E'
 CHAR 'C'
 TWOK 'O', 'N'
 CHAR 'D'
 CHAR ' '
 CHAR 'P'
 TWOK 'E', 'N'
 CHAR 'A'
 CHAR 'L'
 CHAR 'T'
 CHAR 'Y'
 EQUB 0

 EQUB 0                 \ Token 148:    ""

\ ******************************************************************************
\
\       Name: QQ18_DE
\       Type: Variable
\   Category: Text
\    Summary: The recursive token table for tokens 0-148 (German)
\  Deep dive: Printing text tokens
\
\ ******************************************************************************

.QQ18_DE

 RTOK 105               \ Token 0:      ""
 CHAR 'S'
 CHAR 'C'
 CHAR 'H'
 CHAR 'A'
 CHAR 'U'
 CHAR 'F'
 CHAR 'E'
 CHAR 'L'
 RTOK 131
 CONT 7
 EQUB 0

 CHAR ' '               \ Token 1:      ""
 CHAR 'K'
 TWOK 'A', 'R'
 TWOK 'T', 'E'
 EQUB 0

 TWOK 'R', 'E'          \ Token 2:      ""
 CHAR 'G'
 CHAR 'I'
 TWOK 'E', 'R'
 CHAR 'U'
 CHAR 'N'
 CHAR 'G'
 EQUB 0

 CHAR 'D'               \ Token 3:      ""
 TWOK 'A', 'T'
 TWOK 'E', 'N'
 CHAR ' '
 CHAR 'E'
 TWOK 'I', 'N'
 CHAR ' '
 CONT 3
 EQUB 0

 TWOK 'I', 'N'          \ Token 4:      ""
 CHAR 'H'
 CHAR 'A'
 CHAR 'L'
 CHAR 'T'
 CONT 12
 EQUB 0

 CONT 6                 \ Token 5:      ""
 CHAR 'S'
 CHAR 'Y'
 CHAR 'S'
 TWOK 'T', 'E'
 CHAR 'M'
 EQUB 0

 CONT 6                 \ Token 6:      ""
 CHAR 'P'
 TWOK 'R', 'E'
 TWOK 'I', 'S'
 EQUB 0

 CONT 2                 \ Token 7:      ""
 CHAR ' '
 CHAR 'B'
 CHAR '\'
 CHAR 'R'
 CHAR 'S'
 TWOK 'E', 'N'
 CHAR 'P'
 TWOK 'R', 'E'
 TWOK 'I', 'S'
 CHAR 'E'
 CHAR ' '
 EQUB 0

 TWOK 'I', 'N'          \ Token 8:      ""
 CHAR 'D'
 TWOK 'U', 'S'
 CHAR 'T'
 TWOK 'R', 'I'
 CHAR 'E'
 EQUB 0

 CHAR 'A'               \ Token 9:      ""
 CHAR 'G'
 TWOK 'R', 'I'
 CHAR 'K'
 CHAR 'U'
 CHAR 'L'
 CHAR 'T'
 CHAR 'U'
 CHAR 'R'
 EQUB 0

 TWOK 'R', 'E'          \ Token 10:     ""
 CHAR 'I'
 CHAR 'C'
 CHAR 'H'
 CHAR 'E'
 CHAR ' '
 EQUB 0

 CHAR 'M'               \ Token 11:     ""
 CHAR 'I'
 CHAR 'T'
 TWOK 'T', 'E'
 CHAR 'L'
 CHAR 'M'
 CHAR ' '
 EQUB 0

 RTOK 138               \ Token 12:     ""
 CHAR 'E'
 CHAR ' '
 EQUB 0

 CHAR 'H'               \ Token 13:     ""
 CHAR 'A'
 CHAR 'U'
 CHAR 'P'
 CHAR 'T'
 CHAR 'S'
 CHAR ' '
 EQUB 0

 CHAR 'E'               \ Token 14:     ""
 TWOK 'I', 'N'
 CHAR 'H'
 CHAR 'E'
 CHAR 'I'
 CHAR 'T'
 EQUB 0

 TWOK 'A', 'N'          \ Token 15:     ""
 CHAR 'S'
 CHAR 'I'
 CHAR 'C'
 CHAR 'H'
 CHAR 'T'
 EQUB 0

 RTOK 44                \ Token 16:     ""
 CHAR ' '
 CHAR 'S'
 CHAR 'E'
 CHAR 'H'
 TWOK 'E', 'N'
 CHAR ' '
 EQUB 0

 TWOK 'A', 'N'          \ Token 17:     ""
 TWOK 'A', 'R'
 CHAR 'C'
 CHAR 'H'
 CHAR 'I'
 CHAR 'E'
 EQUB 0

 CHAR 'F'               \ Token 18:     ""
 CHAR 'E'
 CHAR 'U'
 CHAR 'D'
 CHAR 'A'
 CHAR 'L'
 RTOK 43
 CHAR 'A'
 TWOK 'A', 'T'
 EQUB 0

 CHAR 'M'               \ Token 19:     ""
 CHAR 'E'
 CHAR 'H'
 CHAR 'R'
 CHAR 'F'
 CHAR 'A'
 CHAR 'C'
 CHAR 'H'
 RTOK 2
 EQUB 0

 TWOK 'D', 'I'          \ Token 21:     ""
 CHAR 'K'
 CHAR 'T'
 TWOK 'A', 'T'
 CHAR 'U'
 CHAR 'R'
 EQUB 0

 CHAR 'K'               \ Token 22:     ""
 CHAR 'O'
 CHAR 'M'
 CHAR 'M'
 CHAR 'U'
 CHAR 'N'
 TWOK 'I', 'S'
 CHAR 'T'
 TWOK 'E', 'N'
 EQUB 0

 CHAR 'K'               \ Token 2x:     ""
 TWOK 'O', 'N'
 CHAR 'F'
 CHAR '\'
 CHAR 'D'
 TWOK 'E', 'R'
 TWOK 'A', 'T'
 CHAR 'I'
 TWOK 'O', 'N'
 EQUB 0

 CHAR 'D'               \ Token 23:     ""
 CHAR 'E'
 CHAR 'M'
 CHAR 'O'
 CHAR 'K'
 CHAR 'R'
 TWOK 'A', 'T'
 CHAR 'I'
 CHAR 'E'
 EQUB 0

 CHAR 'K'               \ Token 24:     ""
 TWOK 'O', 'R'
 CHAR 'P'
 TWOK 'O', 'R'
 TWOK 'A', 'T'
 CHAR 'I'
 CHAR 'V'
 RTOK 43
 CHAR 'A'
 TWOK 'A', 'T'
 EQUB 0

 CHAR 'S'               \ Token 25:     ""
 CHAR 'C'
 CHAR 'H'
 CHAR 'I'
 CHAR 'F'
 CHAR 'F'
 EQUB 0

 CHAR 'P'               \ Token 26:     ""
 RTOK 94
 CHAR 'D'
 CHAR 'U'
 CHAR 'K'
 CHAR 'T'
 EQUB 0

 CHAR ' '               \ Token 27:     ""
 TWOK 'L', 'A'
 CHAR 'S'
 TWOK 'E', 'R'
 EQUB 0

 CHAR 'M'               \ Token 28:     ""
 TWOK 'E', 'N'
 CHAR 'S'
 CHAR 'C'
 CHAR 'H'
 CHAR 'L'
 CHAR '.'
 CHAR ' '
 CHAR 'K'
 CHAR 'O'
 CHAR 'L'
 TWOK 'O', 'N'
 TWOK 'I', 'S'
 CHAR 'T'
 EQUB 0

 CHAR 'H'               \ Token 29:     ""
 CHAR 'Y'
 CHAR 'P'
 TWOK 'E', 'R'
 TWOK 'R', 'A'
 CHAR 'U'
 CHAR 'M'
 CHAR ' '
 EQUB 0

 CHAR '\'               \ Token 30:     ""
 CHAR 'R'
 CHAR 'T'
 CHAR 'L'
 CHAR 'I'
 CHAR 'C'
 CHAR 'H'
 CHAR 'E'
 RTOK 1
 EQUB 0

 TWOK 'E', 'N'          \ Token 31:     ""
 CHAR 'T'
 CHAR 'F'
 TWOK 'E', 'R'
 CHAR 'N'
 CHAR 'U'
 CHAR 'N'
 CHAR 'G'
 EQUB 0

 TWOK 'B', 'E'          \ Token 32:     ""
 CHAR 'V'
 CHAR '\'
 CHAR 'L'
 CHAR 'K'
 TWOK 'E', 'R'
 CHAR 'U'
 CHAR 'N'
 CHAR 'G'
 EQUB 0

 CHAR 'U'               \ Token 33:     ""
 CHAR 'M'
 CHAR 'S'
 TWOK 'A', 'T'
 CHAR 'Z'
 EQUB 0

 CHAR 'W'               \ Token 34:     ""
 CHAR 'I'
 CHAR 'R'
 CHAR 'T'
 CHAR 'S'
 CHAR 'C'
 CHAR 'H'
 CHAR 'A'
 CHAR 'F'
 CHAR 'T'
 EQUB 0

 CHAR ' '               \ Token 35:     ""
 CHAR 'L'
 CHAR 'I'
 CHAR 'C'
 CHAR 'H'
 CHAR 'T'
 CHAR 'J'
 EQUB 0

 TWOK 'T', 'E'          \ Token 36:     ""
 CHAR 'C'
 CHAR 'H'
 CHAR '.'
 CHAR 'N'
 CHAR 'I'
 TWOK 'V', 'E'
 CHAR 'A'
 CHAR 'U'
 EQUB 0

 CHAR 'B'               \ Token 37:     ""
 TWOK 'A', 'R'
 TWOK 'G', 'E'
 CHAR 'L'
 CHAR 'D'
 EQUB 0

 CHAR ' '               \ Token 38:     ""
 TWOK 'B', 'I'
 CHAR 'L'
 CHAR 'L'
 CHAR '.'
 EQUB 0

 RTOK 122               \ Token 39:     ""
 CHAR 'E'
 RTOK 1
 CONT 1
 EQUB 0

 CHAR 'Z'               \ Token 40:     ""
 CHAR 'I'
 CHAR 'E'
 CHAR 'L'
 CHAR ' '
 CHAR 'V'
 TWOK 'E', 'R'
 CHAR 'L'
 CHAR 'O'
 TWOK 'R', 'E'
 CHAR 'N'
 CHAR ' '
 EQUB 0

 RTOK 106               \ Token 41:     ""
 CHAR ' '
 CHAR 'K'
 TWOK 'L', 'E'
 CHAR 'M'
 CHAR 'M'
 CHAR 'T'
 CHAR ' '
 EQUB 0

 RTOK 31                \ Token 42:     ""
 EQUB 0

 CHAR 'S'               \ Token 43:     ""
 CHAR 'T'
 EQUB 0

 CHAR 'M'               \ Token 44:     ""
 TWOK 'E', 'N'
 TWOK 'G', 'E'
 EQUB 0

 CHAR 'V'               \ Token 45:     ""
 TWOK 'E', 'R'
 CHAR 'K'
 CHAR 'A'
 CHAR 'U'
 CHAR 'F'
 TWOK 'E', 'N'
 CHAR ' '
 CHAR '"'
 EQUB 0

 CHAR 'K'               \ Token 46:     ""
 TWOK 'A', 'R'
 CHAR 'G'
 CHAR 'O'
 CONT 6
 EQUB 0

 RTOK 25                \ Token 47:     ""
 CHAR ' '
 CHAR 'A'
 TWOK 'U', 'S'
 CHAR 'R'
 CHAR ']'
 RTOK 43
 TWOK 'E', 'N'
 EQUB 0

 CHAR 'N'               \ Token 48:     ""
 CHAR 'A'
 CHAR 'H'
 CHAR 'R'
 CHAR 'U'
 CHAR 'N'
 CHAR 'G'
 EQUB 0

 TWOK 'T', 'E'          \ Token 49:     ""
 CHAR 'X'
 TWOK 'T', 'I'
 CHAR 'L'
 CHAR 'I'
 TWOK 'E', 'N'
 EQUB 0

 TWOK 'R', 'A'          \ Token 50:     ""
 TWOK 'D', 'I'
 CHAR 'O'
 CHAR 'A'
 CHAR 'K'
 TWOK 'T', 'I'
 CHAR 'V'
 TWOK 'E', 'S'
 EQUB 0

 RTOK 94                \ Token 51:     ""
 CHAR 'B'
 CHAR 'O'
 CHAR 'T'
 CHAR 'S'
 CHAR 'K'
 TWOK 'L', 'A'
 CHAR 'V'
 TWOK 'E', 'N'
 EQUB 0

 TWOK 'G', 'E'          \ Token 52:     ""
 CHAR 'T'
 CHAR 'R'
 CHAR '['
 CHAR 'N'
 CHAR 'K'
 CHAR 'E'
 EQUB 0

 CHAR 'L'               \ Token 53:     ""
 CHAR 'U'
 CHAR 'X'
 TWOK 'U', 'S'
 CHAR 'G'
 CHAR ']'
 CHAR 'T'
 TWOK 'E', 'R'
 EQUB 0

 CHAR 'S'               \ Token 54:     ""
 CHAR 'E'
 CHAR 'L'
 CHAR 'T'
 TWOK 'E', 'N'
 TWOK 'E', 'S'
 EQUB 0

 RTOK 91                \ Token 55:     ""
 CHAR 'P'
 CHAR 'U'
 CHAR 'T'
 TWOK 'E', 'R'
 EQUB 0

 TWOK 'M', 'A'          \ Token 56:     ""
 CHAR 'S'
 CHAR 'C'
 CHAR 'H'
 TWOK 'I', 'N'
 TWOK 'E', 'N'
 EQUB 0

 TWOK 'L', 'E'          \ Token 57:     ""
 CHAR 'G'
 CHAR 'I'
 TWOK 'E', 'R'
 CHAR 'U'
 CHAR 'N'
 TWOK 'G', 'E'
 CHAR 'N'
 EQUB 0

 CHAR 'F'               \ Token 58:     ""
 CHAR 'E'
 CHAR 'U'
 TWOK 'E', 'R'
 CHAR 'W'
 CHAR 'A'
 CHAR 'F'
 CHAR 'F'
 TWOK 'E', 'N'
 EQUB 0

 CHAR 'P'               \ Token 59:     ""
 CHAR 'E'
 CHAR 'L'
 CHAR 'Z'
 CHAR 'E'
 EQUB 0

 CHAR 'M'               \ Token 60:     ""
 TWOK 'I', 'N'
 TWOK 'E', 'R'
 CHAR 'A'
 CHAR 'L'
 CHAR 'I'
 TWOK 'E', 'N'
 EQUB 0

 CHAR 'G'               \ Token 61:     ""
 CHAR 'O'
 CHAR 'L'
 CHAR 'D'
 EQUB 0

 CHAR 'P'               \ Token 62:     ""
 CHAR 'L'
 TWOK 'A', 'T'
 TWOK 'I', 'N'
 EQUB 0

 TWOK 'E', 'D'          \ Token 63:     ""
 CHAR 'E'
 CHAR 'L'
 CHAR 'S'
 TWOK 'T', 'E'
 TWOK 'I', 'N'
 CHAR 'E'
 EQUB 0

 CHAR 'F'               \ Token 64:     ""
 TWOK 'R', 'E'
 CHAR 'M'
 CHAR 'D'
 CHAR 'W'
 TWOK 'A', 'R'
 TWOK 'E', 'N'
 EQUB 0

 EQUB 0                 \ Token 65:     ""

 CHAR ' '               \ Token 66:     ""
 CHAR 'C'
 CHAR 'R'
 EQUB 0

 CHAR 'G'               \ Token 67:     ""
 RTOK 94
 CHAR '^'
 CHAR 'E'
 EQUB 0

 RTOK 142               \ Token 68:     ""
 CHAR 'E'
 EQUB 0

 CHAR 'K'               \ Token 69:     ""
 TWOK 'L', 'E'
 TWOK 'I', 'N'
 CHAR 'E'
 EQUB 0

 CHAR 'G'               \ Token 70:     ""
 CHAR 'R'
 CHAR ']'
 CHAR 'N'
 CHAR 'E'
 EQUB 0

 RTOK 94                \ Token 71:     ""
 TWOK 'T', 'E'
 EQUB 0

 TWOK 'G', 'E'          \ Token 72:     ""
 CHAR 'L'
 TWOK 'B', 'E'
 EQUB 0

 CHAR 'B'               \ Token 73:     ""
 TWOK 'L', 'A'
 CHAR 'U'
 CHAR 'E'
 EQUB 0

 CHAR 'S'               \ Token 74:     ""
 CHAR 'C'
 CHAR 'H'
 CHAR 'W'
 TWOK 'A', 'R'
 CHAR 'Z'
 CHAR 'E'
 EQUB 0

 RTOK 136               \ Token 75:     ""
 CHAR 'E'
 EQUB 0

 CHAR 'G'               \ Token 76:     ""
 CHAR 'L'
 CHAR 'I'
 CHAR 'T'
 CHAR 'S'
 CHAR 'C'
 CHAR 'H'
 CHAR 'I'
 TWOK 'G', 'E'
 EQUB 0

 CHAR 'W'               \ Token 77:     ""
 TWOK 'A', 'N'
 CHAR 'Z'
 TWOK 'E', 'N'
 CHAR '['
 CHAR 'U'
 CHAR 'G'
 CHAR 'I'
 TWOK 'G', 'E'
 EQUB 0

 TWOK 'G', 'E'          \ Token 78:     ""
 CHAR 'H'
 CHAR '\'
 CHAR 'R'
 CHAR 'N'
 TWOK 'T', 'E'
 EQUB 0

 CHAR 'K'               \ Token 79:     ""
 CHAR 'N'
 CHAR 'O'
 CHAR 'C'
 CHAR 'H'
 CHAR 'I'
 TWOK 'G', 'E'
 EQUB 0

 TWOK 'D', 'I'          \ Token 80:     ""
 CHAR 'C'
 CHAR 'K'
 CHAR 'E'
 EQUB 0

 CHAR 'P'               \ Token 81:     ""
 CHAR 'E'
 CHAR 'L'
 CHAR 'Z'
 CHAR 'I'
 TWOK 'G', 'E'
 EQUB 0

 CONT 6                 \ Token 82:     ""
 CHAR 'N'
 CHAR 'A'
 TWOK 'G', 'E'
 TWOK 'T', 'I'
 CHAR 'E'
 TWOK 'R', 'E'
 EQUB 0

 CONT 6                 \ Token 83:     ""
 CHAR 'F'
 CHAR 'R'
 CHAR '\'
 CHAR 'S'
 CHAR 'C'
 CHAR 'H'
 CHAR 'E'
 EQUB 0

 CONT 6                 \ Token 84:     ""
 CHAR 'E'
 CHAR 'C'
 CHAR 'H'
 CHAR 'S'
 TWOK 'E', 'N'
 EQUB 0

 CONT 6                 \ Token 85:     ""
 CHAR 'H'
 CHAR 'U'
 CHAR 'M'
 CHAR 'M'
 TWOK 'E', 'R'
 EQUB 0

 CONT 6                 \ Token 86:     ""
 CHAR 'V'
 CHAR '\'
 TWOK 'G', 'E'
 CHAR 'L'
 EQUB 0

 CONT 6                 \ Token 87:     ""
 CHAR 'H'
 CHAR 'U'
 TWOK 'M', 'A'
 CHAR 'N'
 CHAR 'O'
 CHAR 'I'
 CHAR 'D'
 CHAR 'S'
 EQUB 0

 CONT 6                 \ Token 88:     ""
 CHAR 'K'
 TWOK 'A', 'T'
 CHAR 'Z'
 TWOK 'E', 'N'
 EQUB 0

 CONT 6                 \ Token 89:     ""
 TWOK 'I', 'N'
 CHAR 'S'
 CHAR 'E'
 CHAR 'K'
 CHAR 'T'
 TWOK 'E', 'N'
 EQUB 0

 TWOK 'R', 'A'          \ Token 90:     ""
 TWOK 'D', 'I'
 TWOK 'U', 'S'
 EQUB 0

 CHAR 'C'               \ Token 91:     ""
 CHAR 'O'
 CHAR 'M'
 EQUB 0

 CHAR 'K'               \ Token 92:     ""
 CHAR 'O'
 CHAR 'M'
 TWOK 'M', 'A'
 CHAR 'N'
 CHAR 'D'
 TWOK 'A', 'N'
 CHAR 'T'
 EQUB 0

 CHAR ' '               \ Token 93:     ""
 CHAR 'V'
 TWOK 'E', 'R'
 CHAR 'N'
 CHAR 'I'
 CHAR 'C'
 CHAR 'H'
 TWOK 'T', 'E'
 CHAR 'T'
 EQUB 0

 CHAR 'R'               \ Token 94:     ""
 CHAR 'O'
 EQUB 0

 RTOK 26                \ Token 95:     ""
 CHAR ' '
 CHAR ' '
 CHAR ' '
 CHAR ' '
 CHAR ' '
 CHAR ' '
 CHAR ' '
 CHAR ' '
 CHAR 'P'
 TWOK 'R', 'E'
 TWOK 'I', 'S'
 CHAR '-'
 CHAR ' '
 CHAR ' '
 RTOK 44
 CHAR ' '
 CHAR ' '
 CHAR ' '
 CHAR ' '
 CHAR ' '
 CHAR ' '
 CHAR ' '
 CHAR ' '
 CHAR ' '
 CHAR ' '
 CHAR ' '
 CHAR ' '
 CHAR ' '
 CHAR ' '
 CHAR ' '
 CHAR ' '
 CHAR ' '
 RTOK 14
 EQUB 0

 CHAR 'V'               \ Token 96:     ""
 TWOK 'O', 'R'
 CHAR 'N'
 EQUB 0

 CHAR 'H'               \ Token 97:     ""
 TWOK 'I', 'N'
 CHAR 'T'
 TWOK 'E', 'N'
 EQUB 0

 CHAR 'L'               \ Token 98:     ""
 TWOK 'I', 'N'
 CHAR 'K'
 CHAR 'S'
 EQUB 0

 TWOK 'R', 'E'          \ Token 99:     ""
 CHAR 'C'
 CHAR 'H'
 CHAR 'T'
 CHAR 'S'
 EQUB 0

 RTOK 121               \ Token 100:    ""
 CHAR 'N'
 CHAR 'I'
 TWOK 'E', 'D'
 TWOK 'R', 'I'
 CHAR 'G'
 CHAR ' '
 CONT 7
 EQUB 0

 CHAR 'B'               \ Token 101:    ""
 TWOK 'R', 'A'
 CHAR 'V'
 CHAR 'O'
 CHAR ' '
 RTOK 92
 CHAR '!'
 EQUB 0

 CHAR 'E'               \ Token 102:    ""
 CHAR 'X'
 CHAR 'T'
 TWOK 'R', 'A'
 CHAR ' '
 EQUB 0

 CHAR 'P'               \ Token 103:    ""
 CHAR 'U'
 CHAR 'L'
 CHAR 'S'
 TWOK 'L', 'A'
 CHAR 'S'
 TWOK 'E', 'R'
 EQUB 0

 RTOK 43                \ Token 104:    ""
 TWOK 'R', 'A'
 CHAR 'H'
 TWOK 'L', 'E'
 CHAR 'N'
 TWOK 'L', 'A'
 CHAR 'S'
 TWOK 'E', 'R'
 EQUB 0

 CHAR 'T'               \ Token 105:    ""
 TWOK 'R', 'E'
 CHAR 'I'
 CHAR 'B'
 RTOK 43
 CHAR 'O'
 CHAR 'F'
 CHAR 'F'
 EQUB 0

 TWOK 'R', 'A'          \ Token 106:    ""
 CHAR 'K'
 CHAR 'E'
 TWOK 'T', 'E'
 EQUB 0

 CHAR 'G'               \ Token 107:    ""
 RTOK 94
 CHAR '^'
 TWOK 'E', 'R'
 CHAR ' '
 CHAR 'K'
 TWOK 'A', 'R'
 CHAR 'G'
 CHAR 'O'
 TWOK 'R', 'A'
 CHAR 'U'
 CHAR 'M'
 EQUB 0

 CHAR 'E'               \ Token 108:    ""
 CHAR '.'
 CHAR 'C'
 CHAR '.'
 CHAR 'M'
 CHAR '.'
 CHAR 'S'
 CHAR 'Y'
 CHAR 'S'
 TWOK 'T', 'E'
 CHAR 'M'
 EQUB 0

 RTOK 102               \ Token 109:    ""
 RTOK 103
 EQUB 0

 RTOK 102               \ Token 110:    ""
 RTOK 104
 EQUB 0

 RTOK 105               \ Token 111:    ""
 CHAR 'S'
 CHAR 'C'
 CHAR 'H'
 CHAR 'A'
 CHAR 'U'
 CHAR 'F'
 CHAR 'E'
 CHAR 'L'
 CHAR 'N'
 EQUB 0

 CHAR 'F'               \ Token 112:    ""
 CHAR 'L'
 CHAR 'U'
 CHAR 'C'
 CHAR 'H'
 CHAR 'T'
 CHAR 'K'
 CHAR 'A'
 CHAR 'P'
 CHAR 'S'
 CHAR 'E'
 CHAR 'L'
 EQUB 0

 TWOK 'E', 'N'          \ Token 113:    ""
 TWOK 'E', 'R'
 CHAR 'G'
 CHAR 'I'
 CHAR 'E'
 CHAR 'B'
 CHAR 'O'
 CHAR 'M'
 TWOK 'B', 'E'
 EQUB 0

 TWOK 'E', 'N'          \ Token 114:    ""
 TWOK 'E', 'R'
 CHAR 'G'
 CHAR 'I'
 CHAR 'E'
 CHAR '-'
 RTOK 14
 EQUB 0

 CHAR 'D'               \ Token 115:    ""
 CHAR 'O'
 CHAR 'C'
 CHAR 'K'
 CHAR ' '
 RTOK 55
 EQUB 0

 CHAR 'G'               \ Token 116:    ""
 CHAR 'A'
 TWOK 'L', 'A'
 CHAR 'K'
 CHAR 'T'
 CHAR '.'
 CHAR ' '
 CHAR 'H'
 CHAR 'Y'
 CHAR 'P'
 TWOK 'E', 'R'
 TWOK 'R', 'A'
 CHAR 'U'
 CHAR 'M'
 EQUB 0

 CHAR 'M'               \ Token 117:    ""
 CHAR 'I'
 CHAR 'L'
 CHAR 'I'
 CHAR 'T'
 CHAR '.'
 RTOK 27
 EQUB 0

 CHAR 'G'               \ Token 118:    ""
 CHAR 'R'
 CHAR 'U'
 CHAR 'B'
 TWOK 'E', 'N'
 TWOK 'L', 'A'
 CHAR 'S'
 TWOK 'E', 'R'
 CHAR ' '
 EQUB 0

 CONT 6                 \ Token 119:    ""
 RTOK 37
 CHAR ':'
 CONT 0
 EQUB 0

 TWOK 'A', 'N'          \ Token 120:    ""
 CHAR 'K'
 CHAR 'O'
 CHAR 'M'
 CHAR 'M'
 TWOK 'E', 'N'
 CHAR 'D'
 CHAR 'E'
 CHAR ' '
 RTOK 106
 EQUB 0

 TWOK 'E', 'N'          \ Token 121:    ""
 TWOK 'E', 'R'
 CHAR 'G'
 CHAR 'I'
 CHAR 'E'
 CHAR ' '
 EQUB 0

 CHAR 'G'               \ Token 122:    ""
 CHAR 'A'
 TWOK 'L', 'A'
 CHAR 'K'
 TWOK 'T', 'I'
 CHAR 'S'
 CHAR 'C'
 CHAR 'H'
 EQUB 0

 RTOK 115               \ Token 123:    ""
 CHAR ' '
 TWOK 'A', 'N'
 EQUB 0

 CHAR 'A'               \ Token 124:    ""
 CHAR 'L'
 TWOK 'L', 'E'
 EQUB 0

 TWOK 'L', 'E'          \ Token 125:    ""
 CHAR 'G'
 CHAR 'A'
 CHAR 'L'
 RTOK 43
 TWOK 'A', 'T'
 TWOK 'U', 'S'
 CHAR ':'
 EQUB 0

 RTOK 92                \ Token 126:    ""
 CHAR ' '
 CONT 4
 CONT 12
 CONT 12
 CONT 12
 CONT 6
 CONT 6
 TWOK 'G', 'E'
 TWOK 'G', 'E'
 CHAR 'N'
 CHAR 'W'
 CHAR '['
 CHAR 'R'
 TWOK 'T', 'I'
 TWOK 'G', 'E'
 CHAR 'S'
 CHAR ' '
 RTOK 5
 CONT 9
 CONT 2
 CONT 12
 CONT 6
 CHAR 'H'
 CHAR 'Y'
 CHAR 'P'
 TWOK 'E', 'R'
 TWOK 'R', 'A'
 CHAR 'U'
 CHAR 'M'
 CHAR 'S'
 CHAR 'Y'
 CHAR 'S'
 TWOK 'T', 'E'
 CHAR 'M'
 CONT 9
 CONT 3
 CONT 12
 CHAR 'Z'
 TWOK 'U', 'S'
 CHAR 'T'
 TWOK 'A', 'N'
 CHAR 'D'
 CONT 9
 EQUB 0

 CHAR 'W'               \ Token 127:    ""
 TWOK 'A', 'R'
 CHAR 'E'
 EQUB 0

 EQUB 0                 \ Token 128:    ""

 CHAR 'I'               \ Token 129:    ""
 CHAR 'E'
 EQUB 0

 CHAR 'W'               \ Token 130:    ""
 TWOK 'E', 'R'
 CHAR 'T'
 CHAR 'U'
 CHAR 'N'
 CHAR 'G'
 EQUB 0

 CHAR ' '               \ Token 131:    ""
 TWOK 'A', 'N'
 CHAR ' '
 EQUB 0

 CONT 12                \ Token 132:    ""
 CONT 8
 CONT 6
 CHAR 'A'
 TWOK 'U', 'S'
 CHAR 'R'
 CHAR ']'
 RTOK 43
 CHAR 'U'
 CHAR 'N'
 CHAR 'G'
 CHAR ':'
 CONT 6
 EQUB 0

 CHAR 'S'               \ Token 133:    ""
 CHAR 'A'
 CHAR 'U'
 CHAR 'B'
 TWOK 'E', 'R'
 EQUB 0

 RTOK 43                \ Token 134:    ""
 TWOK 'R', 'A'
 CHAR 'F'
 CHAR 'T'
 CHAR '['
 CHAR 'T'
 TWOK 'E', 'R'
 EQUB 0

 CHAR 'F'               \ Token 135:    ""
 CHAR 'L'
 CHAR ']'
 CHAR 'C'
 CHAR 'H'
 CHAR 'T'
 CHAR 'L'
 TWOK 'I', 'N'
 CHAR 'G'
 EQUB 0

 CHAR 'H'               \ Token 136:    ""
 RTOK 138
 CHAR 'L'
 CHAR 'O'
 CHAR 'S'
 EQUB 0

 CHAR ']'               \ Token 137:    ""
 CHAR 'B'
 TWOK 'E', 'R'
 CHAR 'W'
 CHAR 'I'
 CHAR 'E'
 TWOK 'G', 'E'
 CHAR 'N'
 CHAR 'D'
 CHAR ' '
 RTOK 136
 EQUB 0

 TWOK 'A', 'R'          \ Token 138:    ""
 CHAR 'M'
 EQUB 0

 CHAR 'D'               \ Token 139:    ""
 CHAR 'U'
 CHAR 'R'
 CHAR 'C'
 CHAR 'H'
 CHAR 'S'
 CHAR 'C'
 CHAR 'H'
 CHAR 'N'
 CHAR 'I'
 CHAR 'T'
 CHAR 'T'
 CHAR 'L'
 CHAR 'I'
 CHAR 'C'
 CHAR 'H'
 EQUB 0

 CHAR ']'               \ Token 140:    ""
 CHAR 'B'
 TWOK 'E', 'R'
 RTOK 139
 CHAR ' '
 EQUB 0

 CHAR 'K'               \ Token 141:    ""
 CHAR 'O'
 CHAR 'M'
 CHAR 'P'
 CHAR 'E'
 CHAR 'T'
 TWOK 'E', 'N'
 CHAR 'T'
 EQUB 0

 TWOK 'G', 'E'          \ Token 142:    ""
 CHAR 'F'
 CHAR '['
 CHAR 'H'
 CHAR 'R'
 CHAR 'L'
 CHAR 'I'
 CHAR 'C'
 CHAR 'H'
 EQUB 0

 CHAR 'T'               \ Token 143:    ""
 CHAR '\'
 CHAR 'D'
 CHAR 'L'
 CHAR 'I'
 CHAR 'C'
 CHAR 'H'
 EQUB 0

 CHAR '-'               \ Token 144:    ""
 CHAR '-'
 CHAR '-'
 CHAR '-'
 CHAR ' '
 CHAR 'E'
 CHAR ' '
 CHAR 'L'
 CHAR ' '
 CHAR 'I'
 CHAR ' '
 CHAR 'T'
 CHAR ' '
 CHAR 'E'
 CHAR ' '
 CHAR '-'
 CHAR '-'
 CHAR '-'
 CHAR '-'
 EQUB 0

 TWOK 'A', 'N'          \ Token 145:    ""
 CHAR 'W'
 TWOK 'E', 'S'
 TWOK 'E', 'N'
 CHAR 'D'
 EQUB 0

 CONT 8                 \ Token 146:    ""
 CHAR 'S'
 CHAR 'P'
 CHAR 'I'
 CHAR 'E'
 CHAR 'L'
 CHAR ' '
 CHAR 'Z'
 CHAR 'U'
 CHAR ' '
 TWOK 'E', 'N'
 CHAR 'D'
 CHAR 'E'
 EQUB 0

 CHAR '6'               \ Token 147:    ""
 CHAR '0'
 CHAR ' '
 RTOK 43
 TWOK 'R', 'A'
 CHAR 'F'
 CHAR 'S'
 CHAR 'E'
 CHAR 'K'
 CHAR 'U'
 CHAR 'N'
 CHAR 'D'
 TWOK 'E', 'N'
 EQUB 0

 EQUB 0                 \ Token 148:    ""

\ ******************************************************************************
\
\       Name: QQ18_FR
\       Type: Variable
\   Category: Text
\    Summary: The recursive token table for tokens 0-148 (French)
\  Deep dive: Printing text tokens
\
\ ******************************************************************************

.QQ18_FR

 RTOK 105               \ Token 0:      ""
 CHAR ' '
 CONT 7
 EQUB 0

 CHAR ' '               \ Token 1:      ""
 CHAR 'C'
 TWOK 'A', 'R'
 TWOK 'T', 'E'
 EQUB 0

 CHAR 'G'               \ Token 2:      ""
 CHAR 'O'
 CHAR 'U'
 CHAR 'V'
 TWOK 'E', 'R'
 CHAR 'N'
 CHAR 'E'
 CHAR 'M'
 TWOK 'E', 'N'
 CHAR 'T'
 EQUB 0

 CHAR 'D'               \ Token 3:      ""
 TWOK 'O', 'N'
 CHAR 'N'
 CHAR '<'
 TWOK 'E', 'S'
 RTOK 131
 CONT 3
 EQUB 0

 TWOK 'I', 'N'          \ Token 4:      ""
 CHAR 'V'
 TWOK 'E', 'N'
 CHAR 'T'
 CHAR 'A'
 CHAR 'I'
 TWOK 'R', 'E'
 CONT 12
 EQUB 0

 CHAR 'S'               \ Token 5:      ""
 CHAR 'Y'
 RTOK 43
 CHAR '='
 CHAR 'M'
 CHAR 'E'
 EQUB 0

 CHAR 'P'               \ Token 6:      ""
 TWOK 'R', 'I'
 CHAR 'X'
 EQUB 0

 CONT 2                 \ Token 7:      ""
 CHAR ' '
 RTOK 6
 CHAR ' '
 CHAR 'D'
 CHAR 'U'
 CHAR ' '
 CHAR 'M'
 TWOK 'A', 'R'
 CHAR 'C'
 CHAR 'H'
 CHAR '<'
 CHAR ' '
 EQUB 0

 TWOK 'I', 'N'          \ Token 8:      ""
 CHAR 'D'
 TWOK 'U', 'S'
 CHAR 'T'
 TWOK 'R', 'I'
 CHAR 'E'
 CHAR 'L'
 TWOK 'L', 'E'
 EQUB 0

 CHAR 'A'               \ Token 9:      ""
 CHAR 'G'
 TWOK 'R', 'I'
 CHAR 'C'
 CHAR 'O'
 TWOK 'L', 'E'
 EQUB 0

 TWOK 'R', 'I'          \ Token 10:     ""
 CHAR 'C'
 CHAR 'H'
 CHAR 'E'
 CHAR ' '
 EQUB 0

 RTOK 139               \ Token 11:     ""
 CHAR 'N'
 CHAR 'E'
 CHAR ' '
 EQUB 0

 CHAR 'P'               \ Token 12:     ""
 CHAR 'A'
 CHAR 'U'
 CHAR 'V'
 TWOK 'R', 'E'
 CHAR ' '
 EQUB 0

 CHAR 'S'               \ Token 13:     ""
 CHAR 'U'
 CHAR 'R'
 RTOK 124
 CHAR ' '
 EQUB 0

 CHAR 'U'               \ Token 14:     ""
 CHAR 'N'
 CHAR 'I'
 TWOK 'T', 'E'
 EQUB 0

 CHAR ' '               \ Token 15:     ""
 EQUB 0

 CHAR 'P'               \ Token 16:     ""
 TWOK 'L', 'E'
 TWOK 'I', 'N'
 EQUB 0

 TWOK 'A', 'N'          \ Token 17:     ""
 TWOK 'A', 'R'
 CHAR 'C'
 CHAR 'H'
 CHAR 'I'
 CHAR 'E'
 EQUB 0

 CHAR 'F'               \ Token 18:     ""
 CHAR '<'
 CHAR 'O'
 CHAR 'D'
 CHAR 'A'
 CHAR 'L'
 EQUB 0

 CHAR 'P'               \ Token 19:     ""
 CHAR 'L'
 CHAR 'U'
 TWOK 'R', 'I'
 CHAR '-'
 CHAR 'G'
 CHAR 'O'
 CHAR 'U'
 CHAR 'V'
 TWOK 'E', 'R'
 CHAR '.'
 EQUB 0

 TWOK 'D', 'I'          \ Token 20:     ""
 CHAR 'C'
 CHAR 'T'
 TWOK 'A', 'T'
 CHAR 'U'
 TWOK 'R', 'E'
 EQUB 0

 RTOK 91                \ Token 21:     ""
 CHAR 'M'
 CHAR 'U'
 CHAR 'N'
 TWOK 'I', 'S'
 TWOK 'T', 'E'
 EQUB 0

 CHAR 'C'               \ Token 22:     ""
 TWOK 'O', 'N'
 CHAR 'F'
 CHAR '<'
 CHAR 'D'
 CHAR '<'
 CHAR 'R'
 TWOK 'A', 'T'
 CHAR 'I'
 TWOK 'O', 'N'
 EQUB 0

 CHAR 'D'               \ Token 23:     ""
 CHAR '<'
 CHAR 'M'
 CHAR 'O'
 CHAR 'C'
 CHAR 'R'
 TWOK 'A', 'T'
 CHAR 'I'
 CHAR 'E'
 EQUB 0

 CHAR '<'               \ Token 24:     ""
 CHAR 'T'
 TWOK 'A', 'T'
 CHAR ' '
 CHAR 'C'
 TWOK 'O', 'R'
 CHAR 'P'
 TWOK 'O', 'R'
 TWOK 'A', 'T'
 TWOK 'I', 'S'
 TWOK 'T', 'E'
 EQUB 0

 CHAR 'N'               \ Token 25:     ""
 CHAR 'A'
 CHAR 'V'
 CHAR 'I'
 TWOK 'R', 'E'
 EQUB 0

 CHAR 'P'               \ Token 26:     ""
 CHAR 'R'
 CHAR 'O'
 CHAR 'D'
 CHAR 'U'
 CHAR 'I'
 CHAR 'T'
 EQUB 0

 TWOK 'L', 'A'          \ Token 27:     ""
 CHAR 'S'
 TWOK 'E', 'R'
 EQUB 0

 CHAR 'H'               \ Token 28:     ""
 CHAR 'U'
 TWOK 'M', 'A'
 TWOK 'I', 'N'
 CHAR 'S'
 CHAR ' '
 CHAR 'C'
 CHAR 'O'
 CHAR 'L'
 TWOK 'O', 'N'
 CHAR 'I'
 CHAR 'A'
 CHAR 'U'
 CHAR 'X'
 EQUB 0

 RTOK 116               \ Token 29:     ""
 CHAR ' '
 EQUB 0

 CHAR 'C'               \ Token 30:     ""
 TWOK 'A', 'R'
 TWOK 'T', 'E'
 CHAR ' '
 CHAR 'L'
 CHAR 'O'
 CHAR 'C'
 CHAR 'A'
 TWOK 'L', 'E'
 EQUB 0

 TWOK 'D', 'I'          \ Token 31:     ""
 RTOK 43
 TWOK 'A', 'N'
 TWOK 'C', 'E'
 EQUB 0

 CHAR 'P'               \ Token 32:     ""
 CHAR 'O'
 CHAR 'P'
 CHAR 'U'
 CHAR 'L'
 TWOK 'A', 'T'
 CHAR 'I'
 TWOK 'O', 'N'
 EQUB 0

 CONT 6                 \ Token 33:     ""
 CHAR 'C'
 CHAR '.'
 CONT 6
 CHAR 'A'
 CHAR '.'
 EQUB 0

 CHAR '<'               \ Token 34:     ""
 CHAR 'C'
 TWOK 'O', 'N'
 CHAR 'O'
 CHAR 'M'
 CHAR 'I'
 CHAR 'E'
 EQUB 0

 CHAR ' '               \ Token 35:     ""
 CONT 6
 CHAR 'A'
 CHAR '.'
 CONT 6
 CHAR 'L'
 CHAR 'U'
 CHAR 'M'
 CHAR '.'
 EQUB 0

 CHAR 'N'               \ Token 36:     ""
 CHAR 'I'
 TWOK 'V', 'E'
 CHAR 'A'
 CHAR 'U'
 CHAR ' '
 TWOK 'T', 'E'
 CHAR 'C'
 CHAR 'H'
 CHAR '.'
 EQUB 0

 TWOK 'A', 'R'          \ Token 37:     ""
 TWOK 'G', 'E'
 CHAR 'N'
 CHAR 'T'
 EQUB 0

 CHAR ' '               \ Token 38:     ""
 TWOK 'B', 'I'
 CHAR 'L'
 CHAR 'L'
 CHAR 'I'
 TWOK 'O', 'N'
 EQUB 0

 CHAR 'C'               \ Token 39:     ""
 TWOK 'A', 'R'
 TWOK 'T', 'E'
 CHAR ' '
 RTOK 122
 CONT 1
 EQUB 0

 CHAR 'C'               \ Token 40:     ""
 CHAR 'I'
 CHAR 'B'
 RTOK 94
 CHAR 'P'
 TWOK 'E', 'R'
 CHAR 'D'
 CHAR 'U'
 CHAR 'E'
 CHAR ' '
 EQUB 0

 RTOK 106               \ Token 41:     ""
 CHAR ' '
 TWOK 'E', 'N'
 CHAR 'V'
 CHAR 'O'
 CHAR 'Y'
 CHAR 'E'
 CHAR '<'
 CHAR ' '
 EQUB 0

 CHAR 'P'               \ Token 42:     ""
 TWOK 'O', 'R'
 CHAR 'T'
 CHAR '<'
 CHAR 'E'
 EQUB 0

 CHAR 'S'               \ Token 43:     ""
 CHAR 'T'
 EQUB 0

 RTOK 16                \ Token 44:     ""
 CHAR ' '
 CHAR 'D'
 CHAR 'E'
 CHAR ' '
 EQUB 0

 CHAR 'S'               \ Token 45:     ""
 CHAR 'E'
 EQUB 0

 CHAR ' '               \ Token 46:     ""
 CHAR 'C'
 TWOK 'A', 'R'
 CHAR 'G'
 CHAR 'A'
 CHAR 'I'
 TWOK 'S', 'O'
 CHAR 'N'
 CONT 6
 EQUB 0

 CHAR 'E'               \ Token 47:     ""
 TWOK 'Q', 'U'
 CHAR 'I'
 CHAR 'P'
 CHAR 'E'
 CHAR 'M'
 TWOK 'E', 'N'
 CHAR 'T'
 EQUB 0

 CHAR 'N'               \ Token 48:     ""
 CHAR 'O'
 CHAR 'U'
 CHAR 'R'
 TWOK 'R', 'I'
 CHAR 'T'
 CHAR 'U'
 TWOK 'R', 'E'
 EQUB 0

 TWOK 'T', 'E'          \ Token 49:     ""
 CHAR 'X'
 TWOK 'T', 'I'
 TWOK 'L', 'E'
 CHAR 'S'
 EQUB 0

 TWOK 'R', 'A'          \ Token 50:     ""
 TWOK 'D', 'I'
 CHAR 'O'
 CHAR 'A'
 CHAR 'C'
 TWOK 'T', 'I'
 CHAR 'F'
 CHAR 'S'
 EQUB 0

 TWOK 'E', 'S'          \ Token 51:     ""
 CHAR 'C'
 TWOK 'L', 'A'
 TWOK 'V', 'E'
 CHAR '-'
 CHAR 'R'
 CHAR 'O'
 CHAR 'B'
 CHAR 'T'
 EQUB 0

 CHAR 'B'               \ Token 52:     ""
 CHAR 'O'
 TWOK 'I', 'S'
 TWOK 'S', 'O'
 CHAR 'N'
 CHAR 'S'
 EQUB 0

 CHAR 'P'               \ Token 53:     ""
 CHAR 'D'
 CHAR 'T'
 CHAR 'S'
 CHAR ' '
 CHAR 'D'
 CHAR 'E'
 CHAR ' '
 CHAR 'L'
 CHAR 'U'
 TWOK 'X', 'E'
 EQUB 0

 TWOK 'E', 'S'          \ Token 54:     ""
 CHAR 'P'
 CHAR '='
 TWOK 'C', 'E'
 CHAR ' '
 CHAR 'R'
 TWOK 'A', 'R'
 CHAR 'E'
 EQUB 0

 TWOK 'O', 'R'          \ Token 55:     ""
 CHAR 'D'
 TWOK 'I', 'N'
 TWOK 'A', 'T'
 CHAR 'E'
 CHAR 'U'
 CHAR 'R'
 EQUB 0

 TWOK 'M', 'A'          \ Token 56:     ""
 CHAR 'C'
 CHAR 'H'
 TWOK 'I', 'N'
 TWOK 'E', 'S'
 EQUB 0

 CHAR 'A'               \ Token 57:     ""
 CHAR 'L'
 CHAR 'L'
 CHAR 'I'
 CHAR 'A'
 TWOK 'G', 'E'
 CHAR 'S'
 EQUB 0

 TWOK 'A', 'R'          \ Token 58:     ""
 CHAR 'M'
 TWOK 'E', 'S'
 EQUB 0

 CHAR 'F'               \ Token 59:     ""
 CHAR 'O'
 CHAR 'U'
 CHAR 'R'
 CHAR 'R'
 CHAR 'U'
 CHAR 'R'
 TWOK 'E', 'S'
 EQUB 0

 CHAR 'M'               \ Token 60:     ""
 TWOK 'I', 'N'
 CHAR '<'
 TWOK 'R', 'A'
 CHAR 'U'
 CHAR 'X'
 EQUB 0

 TWOK 'O', 'R'          \ Token 61:     ""
 EQUB 0

 CHAR 'P'               \ Token 62:     ""
 CHAR 'L'
 TWOK 'A', 'T'
 TWOK 'I', 'N'
 CHAR 'E'
 EQUB 0

 TWOK 'G', 'E'          \ Token 63:     ""
 CHAR 'M'
 CHAR 'M'
 TWOK 'E', 'S'
 EQUB 0

 RTOK 127               \ Token 64:     ""
 CHAR ' '
 CHAR 'E'
 CHAR '.'
 CHAR 'T'
 CHAR '.'
 EQUB 0

 EQUB 0                 \ Token 65:     ""

 CHAR ' '               \ Token 66:     ""
 CHAR 'C'
 CHAR 'R'
 EQUB 0

 CHAR 'L'               \ Token 67:     ""
 TWOK 'A', 'R'
 TWOK 'G', 'E'
 CHAR 'S'
 EQUB 0

 CHAR 'F'               \ Token 68:     ""
 CHAR '<'
 CHAR 'R'
 CHAR 'O'
 TWOK 'C', 'E'
 CHAR 'S'
 EQUB 0

 CHAR 'P'               \ Token 69:     ""
 CHAR 'E'
 TWOK 'T', 'I'
 CHAR 'T'
 CHAR 'S'
 EQUB 0

 CHAR 'V'               \ Token 70:     ""
 TWOK 'E', 'R'
 CHAR 'T'
 CHAR 'S'
 EQUB 0

 CHAR 'R'               \ Token 71:     ""
 CHAR 'O'
 CHAR 'U'
 TWOK 'G', 'E'
 CHAR 'S'
 EQUB 0

 CHAR 'J'               \ Token 72:     ""
 CHAR 'A'
 CHAR 'U'
 CHAR 'N'
 TWOK 'E', 'S'
 EQUB 0

 CHAR 'B'               \ Token 73:     ""
 TWOK 'L', 'E'
 TWOK 'U', 'S'
 EQUB 0

 CHAR 'N'               \ Token 74:     ""
 CHAR 'O'
 CHAR 'I'
 CHAR 'R'
 CHAR 'S'
 EQUB 0

 RTOK 136               \ Token 75:     ""
 CHAR 'S'
 EQUB 0

 CHAR 'V'               \ Token 76:     ""
 TWOK 'I', 'S'
 TWOK 'Q', 'U'
 CHAR 'E'
 CHAR 'U'
 CHAR 'X'
 EQUB 0

 CHAR 'Y'               \ Token 77:     ""
 CHAR 'E'
 CHAR 'U'
 CHAR 'X'
 CHAR ' '
 CHAR 'E'
 CHAR 'X'
 TWOK 'O', 'R'
 TWOK 'B', 'I'
 CHAR 'T'
 CHAR '<'
 CHAR 'S'
 EQUB 0

 CHAR '"'               \ Token 78:     ""
 CHAR ' '
 CHAR 'C'
 TWOK 'O', 'R'
 CHAR 'N'
 TWOK 'E', 'S'
 EQUB 0

 TWOK 'A', 'N'          \ Token 79:     ""
 CHAR 'G'
 CHAR 'U'
 TWOK 'L', 'E'
 CHAR 'U'
 CHAR 'X'
 EQUB 0

 CHAR 'G'               \ Token 80:     ""
 TWOK 'R', 'A'
 CHAR 'S'
 EQUB 0

 CHAR '"'               \ Token 81:     ""
 CHAR ' '
 CHAR 'F'
 CHAR 'O'
 CHAR 'U'
 CHAR 'R'
 CHAR 'R'
 CHAR 'U'
 TWOK 'R', 'E'
 EQUB 0

 CHAR 'R'               \ Token 82:     ""
 TWOK 'O', 'N'
 TWOK 'G', 'E'
 CHAR 'U'
 CHAR 'R'
 CHAR 'S'
 EQUB 0

 CHAR 'G'               \ Token 83:     ""
 TWOK 'R', 'E'
 CHAR 'N'
 CHAR 'O'
 CHAR 'U'
 CHAR 'I'
 CHAR 'L'
 TWOK 'L', 'E'
 CHAR 'S'
 EQUB 0

 CHAR 'L'               \ Token 84:     ""
 CHAR '<'
 TWOK 'Z', 'A'
 CHAR 'R'
 CHAR 'D'
 CHAR 'S'
 EQUB 0

 CHAR 'H'               \ Token 85:     ""
 CHAR 'O'
 CHAR 'M'
 TWOK 'A', 'R'
 CHAR 'D'
 CHAR 'S'
 EQUB 0

 CHAR 'O'               \ Token 86:     ""
 TWOK 'I', 'S'
 CHAR 'E'
 CHAR 'A'
 CHAR 'U'
 CHAR 'X'
 EQUB 0

 CHAR 'H'               \ Token 87:     ""
 CHAR 'U'
 TWOK 'M', 'A'
 CHAR 'N'
 CHAR 'O'
 CHAR 'I'
 CHAR 'D'
 TWOK 'E', 'S'
 EQUB 0

 CHAR 'F'               \ Token 88:     ""
 CHAR '<'
 CHAR 'L'
 TWOK 'I', 'N'
 CHAR 'S'
 EQUB 0

 TWOK 'I', 'N'          \ Token 89:     ""
 RTOK 45
 CHAR 'C'
 CHAR 'T'
 TWOK 'E', 'S'
 EQUB 0

 TWOK 'R', 'A'          \ Token 90:     ""
 CHAR 'Y'
 TWOK 'O', 'N'
 EQUB 0

 CHAR 'C'               \ Token 91:     ""
 CHAR 'O'
 CHAR 'M'
 EQUB 0

 RTOK 91                \ Token 92:     ""
 TWOK 'M', 'A'
 CHAR 'N'
 CHAR 'D'
 TWOK 'A', 'N'
 CHAR 'T'
 EQUB 0

 CHAR ' '               \ Token 93:     ""
 CHAR 'D'
 CHAR '<'
 CHAR 'T'
 CHAR 'R'
 CHAR 'U'
 CHAR 'I'
 CHAR 'T'
 EQUB 0

 TWOK 'L', 'E'          \ Token 94:     ""
 CHAR ' '
 EQUB 0

 RTOK 26                \ Token 95:     ""
 CHAR ' '
 CHAR ' '
 CHAR ' '
 CHAR ' '
 CHAR ' '
 CHAR 'Q'
 CHAR 'T'
 CHAR '<'
 CHAR ' '
 RTOK 6
 CHAR ' '
 CHAR 'U'
 CHAR 'N'
 CHAR 'I'
 CHAR 'T'
 CHAR 'A'
 CHAR 'I'
 TWOK 'R', 'E'
 EQUB 0

 CHAR 'A'               \ Token 96:     ""
 CHAR 'V'
 TWOK 'A', 'N'
 CHAR 'T'
 EQUB 0

 TWOK 'A', 'R'          \ Token 97:     ""
 TWOK 'R', 'I'
 CHAR '='
 TWOK 'R', 'E'
 EQUB 0

 CHAR 'G'               \ Token 98:     ""
 CHAR 'A'
 CHAR 'U'
 CHAR 'C'
 CHAR 'H'
 CHAR 'E'
 EQUB 0

 CHAR 'D'               \ Token 99:     ""
 CHAR 'R'
 CHAR 'O'
 CHAR 'I'
 TWOK 'T', 'E'
 EQUB 0

 RTOK 121               \ Token 100:    ""
 RTOK 138
 CONT 7
 EQUB 0

 CHAR 'B'               \ Token 101:    ""
 TWOK 'R', 'A'
 CHAR 'V'
 CHAR 'O'
 CHAR ' '
 RTOK 92
 CHAR '!'
 EQUB 0

 TWOK 'E', 'N'          \ Token 102:    ""
 CHAR ' '
 CHAR 'P'
 CHAR 'L'
 TWOK 'U', 'S'
 CHAR ' '
 EQUB 0

 CHAR 'C'               \ Token 103:    ""
 TWOK 'A', 'N'
 CHAR 'N'
 TWOK 'O', 'N'
 CHAR ' '
 RTOK 27
 EQUB 0

 RTOK 90                \ Token 104:    ""
 CHAR ' '
 RTOK 27
 EQUB 0

 RTOK 94                \ Token 105:    ""
 CHAR 'F'
 CHAR 'U'
 CHAR 'E'
 CHAR 'L'
 EQUB 0

 CHAR 'M'               \ Token 106:    ""
 TWOK 'I', 'S'
 CHAR 'S'
 CHAR 'I'
 TWOK 'L', 'E'
 EQUB 0

 CHAR 'G'               \ Token 107:    ""
 TWOK 'R', 'A'
 CHAR 'N'
 CHAR 'D'
 CHAR 'E'
 CHAR ' '
 TWOK 'S', 'O'
 CHAR 'U'
 TWOK 'T', 'E'
 EQUB 0

 RTOK 5                 \ Token 108:    ""
 CHAR ' '
 CHAR 'E'
 CHAR '.'
 CHAR 'C'
 CHAR '.'
 CHAR 'M'
 CHAR '.'
 EQUB 0

 CHAR 'C'               \ Token 109:    ""
 TWOK 'A', 'N'
 TWOK 'O', 'N'
 CHAR ' '
 RTOK 27
 EQUB 0

 RTOK 104               \ Token 110:    ""
 EQUB 0

 CHAR 'R'               \ Token 111:    ""
 CHAR '<'
 CHAR 'C'
 CHAR 'O'
 CHAR 'L'
 TWOK 'T', 'E'
 CHAR 'U'
 CHAR 'R'
 CHAR ' '
 CHAR 'D'
 CHAR 'E'
 CHAR ' '
 CHAR 'F'
 CHAR 'U'
 CHAR 'E'
 CHAR 'L'
 EQUB 0

 CHAR 'C'               \ Token 112:    ""
 CHAR 'A'
 CHAR 'P'
 CHAR 'S'
 CHAR 'U'
 RTOK 94
 CHAR 'D'
 CHAR 'E'
 CHAR ' '
 CHAR 'S'
 CHAR 'A'
 CHAR 'U'
 TWOK 'V', 'E'
 CHAR 'T'
 CHAR 'A'
 TWOK 'G', 'E'
 EQUB 0

 CHAR 'B'               \ Token 113:    ""
 CHAR 'O'
 CHAR 'M'
 TWOK 'B', 'E'
 CHAR ' '
 CHAR 'D'
 CHAR '`'
 CHAR '<'
 CHAR 'N'
 TWOK 'E', 'R'
 CHAR 'G'
 CHAR 'I'
 CHAR 'E'
 EQUB 0

 CHAR 'U'               \ Token 114:    ""
 CHAR 'N'
 CHAR 'I'
 CHAR 'T'
 CHAR '<'
 CHAR ' '
 CHAR 'D'
 CHAR '`'
 CHAR '<'
 CHAR 'N'
 TWOK 'E', 'R'
 CHAR 'G'
 CHAR 'I'
 CHAR 'E'
 EQUB 0

 TWOK 'O', 'R'          \ Token 115:    ""
 CHAR 'D'
 CHAR '.'
 CHAR ' '
 CHAR 'D'
 CHAR '`'
 TWOK 'A', 'R'
 TWOK 'R', 'I'
 TWOK 'M', 'A'
 TWOK 'G', 'E'
 EQUB 0

 TWOK 'I', 'N'          \ Token 116:    ""
 CHAR 'T'
 TWOK 'E', 'R'
 RTOK 122
 EQUB 0

 RTOK 27                \ Token 117:    ""
 CHAR ' '
 CHAR 'M'
 CHAR 'I'
 CHAR 'L'
 CHAR 'I'
 CHAR 'T'
 CHAR 'A'
 CHAR 'I'
 TWOK 'R', 'E'
 EQUB 0

 RTOK 27                \ Token 118:    ""
 CHAR ' '
 CONT 6
 CHAR 'M'
 TWOK 'I', 'N'
 CHAR 'E'
 CHAR 'U'
 CHAR 'R'
 EQUB 0

 RTOK 37                \ Token 119:    ""
 CHAR ':'
 CONT 0
 EQUB 0

 RTOK 106               \ Token 120:    ""
 CHAR ' '
 TWOK 'E', 'N'
 CHAR ' '
 CHAR 'V'
 CHAR 'U'
 CHAR 'E'
 EQUB 0

 CHAR '<'               \ Token 121:    ""
 CHAR 'N'
 TWOK 'E', 'R'
 CHAR 'G'
 CHAR 'I'
 CHAR 'E'
 CHAR ' '
 EQUB 0

 CHAR 'G'               \ Token 122:    ""
 CHAR 'A'
 TWOK 'L', 'A'
 CHAR 'C'
 TWOK 'T', 'I'
 TWOK 'Q', 'U'
 CHAR 'E'
 EQUB 0

 RTOK 115               \ Token 123:    ""
 CHAR ' '
 TWOK 'E', 'N'
 CHAR ' '
 CHAR 'M'
 TWOK 'A', 'R'
 CHAR 'C'
 CHAR 'H'
 CHAR 'E'
 EQUB 0

 CHAR 'T'               \ Token 124:    ""
 CHAR 'O'
 CHAR 'U'
 CHAR 'T'
 EQUB 0

 RTOK 43                \ Token 125:    ""
 TWOK 'A', 'T'
 CHAR 'U'
 CHAR 'T'
 CHAR ' '
 CHAR 'L'
 CHAR '<'
 CHAR 'G'
 CHAR 'A'
 CHAR 'L'
 CHAR ':'
 EQUB 0

 RTOK 92                \ Token 126:    ""
 CHAR ' '
 CONT 4
 CONT 12
 CONT 12
 CONT 12
 CONT 6
 RTOK 5
 CHAR ' '
 CHAR 'A'
 CHAR 'C'
 CHAR 'T'
 CHAR 'U'
 CHAR 'E'
 CHAR 'L'
 CONT 9
 CONT 2
 CONT 12
 RTOK 5
 CHAR ' '
 TWOK 'I', 'N'
 CHAR 'T'
 TWOK 'E', 'R'
 CHAR 'G'
 CHAR 'A'
 TWOK 'L', 'A'
 CHAR 'C'
 CHAR 'T'
 CONT 9
 CONT 3
 CONT 12
 CHAR 'C'
 TWOK 'O', 'N'
 TWOK 'D', 'I'
 TWOK 'T', 'I'
 TWOK 'O', 'N'
 CONT 9
 EQUB 0

 CHAR 'O'               \ Token 127:    ""
 CHAR 'B'
 CHAR 'J'
 CHAR 'E'
 CHAR 'T'
 EQUB 0

 EQUB 0                 \ Token 128:    ""

 CHAR '"'               \ Token 129:    ""
 CHAR ' '
 EQUB 0

 CHAR '<'               \ Token 130:    ""
 CHAR 'V'
 CHAR 'A'
 CHAR 'L'
 CHAR 'U'
 TWOK 'A', 'T'
 CHAR 'I'
 TWOK 'O', 'N'
 EQUB 0

 CHAR ' '               \ Token 131:    ""
 CHAR 'S'
 CHAR 'U'
 CHAR 'R'
 CHAR ' '
 EQUB 0

 CONT 12                \ Token 132:    ""
 CHAR '<'
 TWOK 'Q', 'U'
 CHAR 'I'
 CHAR 'P'
 CHAR 'E'
 CHAR 'M'
 TWOK 'E', 'N'
 CHAR 'T'
 CHAR ':'
 EQUB 0

 CHAR 'P'               \ Token 133:    ""
 CHAR 'R'
 CHAR 'O'
 CHAR 'P'
 TWOK 'R', 'E'
 EQUB 0

 CHAR 'D'               \ Token 134:    ""
 CHAR '<'
 CHAR 'L'
 TWOK 'I', 'N'
 TWOK 'Q', 'U'
 TWOK 'A', 'N'
 CHAR 'T'
 EQUB 0

 CHAR 'F'               \ Token 135:    ""
 CHAR 'U'
 CHAR 'G'
 CHAR 'I'
 TWOK 'T', 'I'
 CHAR 'F'
 EQUB 0

 TWOK 'I', 'N'          \ Token 136:    ""
 CHAR 'O'
 CHAR 'F'
 CHAR 'F'
 TWOK 'E', 'N'
 CHAR 'S'
 CHAR 'I'
 CHAR 'F'
 EQUB 0

 TWOK 'Q', 'U'          \ Token 137:    ""
 CHAR 'A'
 CHAR 'S'
 CHAR 'I'
 CHAR ' '
 RTOK 136
 EQUB 0

 CHAR 'F'               \ Token 138:    ""
 CHAR 'A'
 CHAR 'I'
 CHAR 'B'
 TWOK 'L', 'E'
 EQUB 0

 CHAR 'M'               \ Token 139:    ""
 CHAR 'O'
 CHAR 'Y'
 TWOK 'E', 'N'
 EQUB 0

 TWOK 'I', 'N'          \ Token 140:    ""
 CHAR 'T'
 TWOK 'E', 'R'
 CHAR 'M'
 CHAR '<'
 TWOK 'D', 'I'
 CHAR 'A'
 CHAR 'I'
 TWOK 'R', 'E'
 EQUB 0

 RTOK 91                \ Token 141:    ""
 CHAR 'P'
 CHAR '<'
 CHAR 'T'
 TWOK 'E', 'N'
 CHAR 'T'
 EQUB 0

 CHAR 'D'               \ Token 142:    ""
 TWOK 'A', 'N'
 TWOK 'G', 'E'
 TWOK 'R', 'E'
 CHAR 'U'
 CHAR 'X'
 EQUB 0

 CHAR 'M'               \ Token 143:    ""
 TWOK 'O', 'R'
 TWOK 'T', 'E'
 CHAR 'L'
 TWOK 'L', 'E'
 CHAR 'M'
 TWOK 'E', 'N'
 CHAR 'T'
 EQUB 0

 CHAR '-'               \ Token 144:    ""
 CHAR '-'
 CHAR '-'
 CHAR ' '
 CHAR 'E'
 CHAR ' '
 CHAR 'L'
 CHAR ' '
 CHAR 'I'
 CHAR ' '
 CHAR 'T'
 CHAR ' '
 CHAR 'E'
 CHAR ' '
 CHAR '-'
 CHAR '-'
 CHAR '-'
 EQUB 0

 CHAR 'P'               \ Token 145:    ""
 CHAR 'R'
 CHAR '<'
 CHAR 'S'
 TWOK 'E', 'N'
 CHAR 'T'
 EQUB 0

 CONT 8                 \ Token 146:    ""
 CHAR 'J'
 CHAR 'E'
 CHAR 'U'
 CHAR ' '
 CHAR 'T'
 TWOK 'E', 'R'
 CHAR 'M'
 TWOK 'I', 'N'
 CHAR '<'
 EQUB 0

 CHAR 'P'               \ Token 147:    ""
 CHAR '<'
 CHAR 'N'
 CHAR 'A'
 CHAR 'L'
 CHAR 'I'
 CHAR 'T'
 CHAR '<'
 CHAR ' '
 CHAR 'D'
 CHAR 'E'
 CHAR ' '
 CHAR '6'
 CHAR '0'
 CHAR ' '
 RTOK 45
 CHAR 'C'
 EQUB 0

 EQUB 0                 \ Token 148:    ""

 EQUB 0, 0, 0, 0
 EQUB 0, 0, 0

.RUTOK_LO

 EQUB LO(RUTOK)
 EQUB LO(RUTOK_DE)
 EQUB LO(RUTOK_FR)
 EQUB &72

.RUTOK_HI

 EQUB HI(RUTOK)
 EQUB HI(RUTOK_DE)
 EQUB HI(RUTOK_FR)
 EQUB &AB

; ******************************************************************************
.DETOK3
 PHA                                              ; B0D6: 48          H
 TAX                                              ; B0D7: AA          .
 TYA                                              ; B0D8: 98          .
 PHA                                              ; B0D9: 48          H
 LDA V                                            ; B0DA: A5 63       .c
 PHA                                              ; B0DC: 48          H
 LDA V_1                                          ; B0DD: A5 64       .d
 PHA                                              ; B0DF: 48          H
 LDY LANG                                         ; B0E0: AC A8 04    ...
 LDA RUTOK_LO,Y                                   ; B0E3: B9 CE B0    ...
 STA V                                            ; B0E6: 85 63       .c
 LDA RUTOK_HI,Y                                   ; B0E8: B9 D2 B0    ...
 STA V_1                                          ; B0EB: 85 64       .d
 BNE CB111                                        ; B0ED: D0 22       ."
; ******************************************************************************
.DETOK_BANK2
 TAX                                              ; B0EF: AA          .
 LDA L00E9                                        ; B0F0: A5 E9       ..
 BPL CB0FD                                        ; B0F2: 10 09       ..
 LDA PPUSTATUS                                    ; B0F4: AD 02 20    ..
 ASL A                                            ; B0F7: 0A          .
 BPL CB0FD                                        ; B0F8: 10 03       ..
 JSR NAMETABLE0                                   ; B0FA: 20 6D D0     m.
.CB0FD
 TXA                                              ; B0FD: 8A          .
 PHA                                              ; B0FE: 48          H
 TYA                                              ; B0FF: 98          .
 PHA                                              ; B100: 48          H
 LDA V                                            ; B101: A5 63       .c
 PHA                                              ; B103: 48          H
 LDA V_1                                          ; B104: A5 64       .d
 PHA                                              ; B106: 48          H
 LDA TOKENLO                                      ; B107: AD A6 04    ...
 STA V                                            ; B10A: 85 63       .c
 LDA TOKENHI                                      ; B10C: AD A7 04    ...
 STA V_1                                          ; B10F: 85 64       .d
.CB111
 LDY #0                                           ; B111: A0 00       ..
.CB113
 LDA L00E9                                        ; B113: A5 E9       ..
 BPL CB120                                        ; B115: 10 09       ..
 LDA PPUSTATUS                                    ; B117: AD 02 20    ..
 ASL A                                            ; B11A: 0A          .
 BPL CB120                                        ; B11B: 10 03       ..
 JSR NAMETABLE0                                   ; B11D: 20 6D D0     m.
.CB120
 LDA (V),Y                                        ; B120: B1 63       .c
 EOR #&57 ; 'W'                                   ; B122: 49 57       IW
 BNE CB129                                        ; B124: D0 03       ..
 DEX                                              ; B126: CA          .
 BEQ CB130                                        ; B127: F0 07       ..
.CB129
 INY                                              ; B129: C8          .
 BNE CB113                                        ; B12A: D0 E7       ..
 INC V_1                                          ; B12C: E6 64       .d
 BNE CB113                                        ; B12E: D0 E3       ..
.CB130
 INY                                              ; B130: C8          .
 BNE CB135                                        ; B131: D0 02       ..
 INC V_1                                          ; B133: E6 64       .d
.CB135
 LDA (V),Y                                        ; B135: B1 63       .c
 EOR #&57 ; 'W'                                   ; B137: 49 57       IW
 BEQ CB141                                        ; B139: F0 06       ..
 JSR DETOK2                                       ; B13B: 20 4B B1     K.
 JMP CB130                                        ; B13E: 4C 30 B1    L0.

.CB141
 PLA                                              ; B141: 68          h
 STA V_1                                          ; B142: 85 64       .d
 PLA                                              ; B144: 68          h
 STA V                                            ; B145: 85 63       .c
 PLA                                              ; B147: 68          h
 TAY                                              ; B148: A8          .
 PLA                                              ; B149: 68          h
 RTS                                              ; B14A: 60          `

; ******************************************************************************
.DETOK2
 CMP #&20 ; ' '                                   ; B14B: C9 20       .
 BCC DT3                                          ; B14D: 90 5A       .Z
 BIT DTW3                                         ; B14F: 2C F5 03    ,..
 BPL CB164                                        ; B152: 10 10       ..
 TAX                                              ; B154: AA          .
 TYA                                              ; B155: 98          .
 PHA                                              ; B156: 48          H
 LDA V                                            ; B157: A5 63       .c
 PHA                                              ; B159: 48          H
 LDA V_1                                          ; B15A: A5 64       .d
 PHA                                              ; B15C: 48          H
 TXA                                              ; B15D: 8A          .
 JSR TT27_BANK2                                   ; B15E: 20 4F B4     O.
 JMP CB1C4                                        ; B161: 4C C4 B1    L..

.CB164
 CMP XX3m3                                        ; B164: C5 F9       ..
 BCC CB187                                        ; B166: 90 1F       ..
 CMP #&81                                         ; B168: C9 81       ..
 BCC CB1D0                                        ; B16A: 90 64       .d
 CMP #&D7                                         ; B16C: C9 D7       ..
 BCS CB173                                        ; B16E: B0 03       ..
 JMP DETOK_BANK2                                  ; B170: 4C EF B0    L..

.CB173
 SBC #&D7                                         ; B173: E9 D7       ..
 ASL A                                            ; B175: 0A          .
 PHA                                              ; B176: 48          H
 TAX                                              ; B177: AA          .
 LDA TKN2,X                                       ; B178: BD 19 B3    ...
 JSR CB187                                        ; B17B: 20 87 B1     ..
 PLA                                              ; B17E: 68          h
 TAX                                              ; B17F: AA          .
 LDA TKN2_1,X                                     ; B180: BD 1A B3    ...
 CMP #&3F ; '?'                                   ; B183: C9 3F       .?
 BEQ CB1CC                                        ; B185: F0 45       .E
.CB187
 BIT DTW1                                         ; B187: 2C F8 03    ,..
 BPL CB1A6                                        ; B18A: 10 1A       ..
 BIT DTW6                                         ; B18C: 2C F3 03    ,..
 BMI CB196                                        ; B18F: 30 05       0.
 BIT DTW2                                         ; B191: 2C F4 03    ,..
 BMI CB1A6                                        ; B194: 30 10       0.
.CB196
 BIT DTW8                                         ; B196: 2C F9 03    ,..
 BPL CB1A6                                        ; B199: 10 0B       ..
 STX SC                                           ; B19B: 86 07       ..
 TAX                                              ; B19D: AA          .
 LDA LB8B4,X                                      ; B19E: BD B4 B8    ...
 LDX SC                                           ; B1A1: A6 07       ..
 AND DTW8                                         ; B1A3: 2D F9 03    -..
.CB1A6
 JMP DASC_BANK2                                   ; B1A6: 4C F5 B4    L..

.DT3
 TAX                                              ; B1A9: AA          .
 TYA                                              ; B1AA: 98          .
 PHA                                              ; B1AB: 48          H
 LDA V                                            ; B1AC: A5 63       .c
 PHA                                              ; B1AE: 48          H
 LDA V_1                                          ; B1AF: A5 64       .d
 PHA                                              ; B1B1: 48          H
 TXA                                              ; B1B2: 8A          .
 ASL A                                            ; B1B3: 0A          .
 TAX                                              ; B1B4: AA          .
 LDA JMTBm2,X                                     ; B1B5: BD 04 B2    ...
 STA V                                            ; B1B8: 85 63       .c
 LDA JMTBm1,X                                     ; B1BA: BD 05 B2    ...
 STA V_1                                          ; B1BD: 85 64       .d
 TXA                                              ; B1BF: 8A          .
 LSR A                                            ; B1C0: 4A          J
 JSR sub_CB1CD                                    ; B1C1: 20 CD B1     ..
.CB1C4
 PLA                                              ; B1C4: 68          h
 STA V_1                                          ; B1C5: 85 64       .d
 PLA                                              ; B1C7: 68          h
 STA V                                            ; B1C8: 85 63       .c
 PLA                                              ; B1CA: 68          h
 TAY                                              ; B1CB: A8          .
.CB1CC
 RTS                                              ; B1CC: 60          `

.sub_CB1CD
 JMP (V)                                          ; B1CD: 6C 63 00    lc.

.CB1D0
 STA SC                                           ; B1D0: 85 07       ..
 LDA L00E9                                        ; B1D2: A5 E9       ..
 BPL CB1DF                                        ; B1D4: 10 09       ..
 LDA PPUSTATUS                                    ; B1D6: AD 02 20    ..
 ASL A                                            ; B1D9: 0A          .
 BPL CB1DF                                        ; B1DA: 10 03       ..
 JSR NAMETABLE0                                   ; B1DC: 20 6D D0     m.
.CB1DF
 TYA                                              ; B1DF: 98          .
 PHA                                              ; B1E0: 48          H
 LDA V                                            ; B1E1: A5 63       .c
 PHA                                              ; B1E3: 48          H
 LDA V_1                                          ; B1E4: A5 64       .d
 PHA                                              ; B1E6: 48          H
 JSR DORND                                        ; B1E7: 20 AD F4     ..
 TAX                                              ; B1EA: AA          .
.CB1EB
 LDA #0                                           ; B1EB: A9 00       ..
 CPX #&33 ; '3'                                   ; B1ED: E0 33       .3
 ADC #0                                           ; B1EF: 69 00       i.
 CPX #&66 ; 'f'                                   ; B1F1: E0 66       .f
 ADC #0                                           ; B1F3: 69 00       i.
 CPX #&99                                         ; B1F5: E0 99       ..
 ADC #0                                           ; B1F7: 69 00       i.
 CPX #&CC                                         ; B1F9: E0 CC       ..
 LDX SC                                           ; B1FB: A6 07       ..
 ADC CB1EB,X                                      ; B1FD: 7D EB B1    }..
 JSR DETOK_BANK2                                  ; B200: 20 EF B0     ..
.sub_CB203
JMTBm2 = sub_CB203+1
JMTBm1 = sub_CB203+2
 JMP CB1C4                                        ; B203: 4C C4 B1    L..

.JMTB
 EQUB &79, &B2, &7C, &B2, &4F, &B4, &4F, &B4, &A2 ; B206: 79 B2 7C... y.|
 EQUB &B2, &9B, &B2, &F5, &B4, &87, &B2, &92, &B2 ; B20F: B2 9B B2... ...
 EQUB &F5, &B4, &73, &F4, &F5, &B4, &B8, &B3, &A8 ; B218: F5 B4 73... ..s
 EQUB &B2, &AB, &B2, &91, &B2, &B5, &B2, &D3, &B2 ; B221: B2 AB B2... ...
 EQUB &FB, &B2, &F5, &B4, &DE, &F2, &80, &B3, &B1 ; B22A: FB B2 F5... ...
 EQUB &B3, &C1, &B3, &73, &B3, &F6, &B2, &6C, &B2 ; B233: B3 C1 B3... ...
 EQUB &70, &B2, &B4, &B3, &91, &B2, &91, &B2, &F5 ; B23C: 70 B2 B4... p..
 EQUB &B4                                         ; B245: B4          .
.MTIN
 EQUB &10, &15, &1A, &1F, &9B, &A0, &2E, &A5      ; B246: 10 15 1A... ...
 EQUS "$)=38"                                     ; B24E: 24 29 3D... $)=
 EQUB &AA                                         ; B253: AA          .
 EQUS "BGLQV"                                     ; B254: 42 47 4C... BGL
 EQUB &8C, &60, &65, &87, &82, &5B, &6A, &B4, &B9 ; B259: 8C 60 65... .`e
 EQUB &BE, &E1, &E6, &EB, &F0, &F5, &FA           ; B262: BE E1 E6... ...
 EQUS "sx}"                                       ; B269: 73 78 7D    sx}

; ******************************************************************************
.MT27
 LDA #&D9                                         ; B26C: A9 D9       ..
 BNE CB272                                        ; B26E: D0 02       ..
; ******************************************************************************
.MT28
 LDA #&DC                                         ; B270: A9 DC       ..
.CB272
 CLC                                              ; B272: 18          .
 ADC GCNT                                         ; B273: 6D A7 03    m..
 JMP DETOK                                        ; B276: 4C 82 F0    L..

; ******************************************************************************
.MT1
 LDA #0                                           ; B279: A9 00       ..
; overlapping:  L80A9                             ; B27B: 2C A9 80    ,..
 EQUB &2C                                         ; B27B: 2C          ,

; ******************************************************************************
.MT2
 LDA #&80                                         ; B27C: A9 80       ..
 STA DTW1                                         ; B27E: 8D F8 03    ...
 LDA #0                                           ; B281: A9 00       ..
 STA DTW6                                         ; B283: 8D F3 03    ...
 RTS                                              ; B286: 60          `

; ******************************************************************************
.MT8
 LDA #6                                           ; B287: A9 06       ..
 STA XC                                           ; B289: 85 32       .2
 LDA #&FF                                         ; B28B: A9 FF       ..
 STA DTW2                                         ; B28D: 8D F4 03    ...
 RTS                                              ; B290: 60          `

; ******************************************************************************
.FILEPR
.MT16
.OTHERFILEPR
 RTS                                              ; B291: 60          `

; ******************************************************************************
.MT9
 LDA #1                                           ; B292: A9 01       ..
 STA XC                                           ; B294: 85 32       .2
 LDA #&95                                         ; B296: A9 95       ..
 JMP TT66                                         ; B298: 4C 6E F2    Ln.

; ******************************************************************************
.MT6
 LDA #&80                                         ; B29B: A9 80       ..
 STA QQ17                                         ; B29D: 85 3C       .<
 LDA #&FF                                         ; B29F: A9 FF       ..
; overlapping: B &2C, <(CNT2), >(CNT2) ; BIT+2 CNT2; B2A1: 2C A9 00    ,..
 EQUB &2C                                         ; B2A1: 2C          ,

; ******************************************************************************
.MT5
 LDA #0                                           ; B2A2: A9 00       ..
 STA DTW3                                         ; B2A4: 8D F5 03    ...
 RTS                                              ; B2A7: 60          `

; ******************************************************************************
.MT14
 LDA #&80                                         ; B2A8: A9 80       ..
; overlapping: B &2C, <(CNT2), >(CNT2) ; BIT+2 CNT2; B2AA: 2C A9 00    ,..
 EQUB &2C                                         ; B2AA: 2C          ,

; ******************************************************************************
.MT15
 LDA #0                                           ; B2AB: A9 00       ..
 STA DTW4                                         ; B2AD: 8D F6 03    ...
 ASL A                                            ; B2B0: 0A          .
 STA DTW5                                         ; B2B1: 8D F7 03    ...
 RTS                                              ; B2B4: 60          `

; ******************************************************************************
.MT17
 LDA QQ17                                         ; B2B5: A5 3C       .<
 AND #&BF                                         ; B2B7: 29 BF       ).
 STA QQ17                                         ; B2B9: 85 3C       .<
 LDA #3                                           ; B2BB: A9 03       ..
 JSR TT27_BANK2                                   ; B2BD: 20 4F B4     O.
 LDX DTW5                                         ; B2C0: AE F7 03    ...
 LDA BUFm1,X                                      ; B2C3: BD 06 05    ...
 JSR VOWEL                                        ; B2C6: 20 01 B3     ..
 BCC CB2CE                                        ; B2C9: 90 03       ..
 DEC DTW5                                         ; B2CB: CE F7 03    ...
.CB2CE
 LDA #&99                                         ; B2CE: A9 99       ..
 JMP DETOK                                        ; B2D0: 4C 82 F0    L..

; ******************************************************************************
.MT18
 JSR MT19                                         ; B2D3: 20 FB B2     ..
 JSR DORND                                        ; B2D6: 20 AD F4     ..
 AND #3                                           ; B2D9: 29 03       ).
 TAY                                              ; B2DB: A8          .
.loop_CB2DC
 JSR DORND                                        ; B2DC: 20 AD F4     ..
 AND #&3E ; '>'                                   ; B2DF: 29 3E       )>
 TAX                                              ; B2E1: AA          .
 LDA TKN2_2,X                                     ; B2E2: BD 1B B3    ...
 JSR DTS                                          ; B2E5: 20 9D F0     ..
 LDA TKN2_3,X                                     ; B2E8: BD 1C B3    ...
 CMP #&3F ; '?'                                   ; B2EB: C9 3F       .?
 BEQ CB2F2                                        ; B2ED: F0 03       ..
 JSR DTS                                          ; B2EF: 20 9D F0     ..
.CB2F2
 DEY                                              ; B2F2: 88          .
 BPL loop_CB2DC                                   ; B2F3: 10 E7       ..
 RTS                                              ; B2F5: 60          `

; ******************************************************************************
.MT26
 LDA #&20 ; ' '                                   ; B2F6: A9 20       .
 JSR DASC_BANK2                                   ; B2F8: 20 F5 B4     ..
; ******************************************************************************
.MT19
 LDA #0                                           ; B2FB: A9 00       ..
 STA DTW8                                         ; B2FD: 8D F9 03    ...
 RTS                                              ; B300: 60          `

; ******************************************************************************
.VOWEL
 ORA #&20 ; ' '                                   ; B301: 09 20       .
 CMP #&61 ; 'a'                                   ; B303: C9 61       .a
 BEQ CB318                                        ; B305: F0 11       ..
 CMP #&65 ; 'e'                                   ; B307: C9 65       .e
 BEQ CB318                                        ; B309: F0 0D       ..
 CMP #&69 ; 'i'                                   ; B30B: C9 69       .i
 BEQ CB318                                        ; B30D: F0 09       ..
 CMP #&6F ; 'o'                                   ; B30F: C9 6F       .o
 BEQ CB318                                        ; B311: F0 05       ..
 CMP #&75 ; 'u'                                   ; B313: C9 75       .u
 BEQ CB318                                        ; B315: F0 01       ..
 CLC                                              ; B317: 18          .
.CB318
 RTS                                              ; B318: 60          `

.TKN2
 EQUB &0C                                         ; B319: 0C          .
.TKN2_1
 EQUB &0A                                         ; B31A: 0A          .
.TKN2_2
 EQUB &41                                         ; B31B: 41          A
.TKN2_3
 EQUS "BOUSEITILETSTONLONUTHNO"                   ; B31C: 42 4F 55... BOU
.QQ16
 EQUB &41                                         ; B333: 41          A
.QQ16_1
 EQUS "LLEXEGEZACEBISOUSESARMAINDIREA?ERATENBE"   ; B334: 4C 4C 45... LLE
 EQUS "RALAVETIEDORQUANTEISRION"                  ; B35B: 52 41 4C... RAL

; ******************************************************************************
.BRIS
 LDA #&D8                                         ; B373: A9 D8       ..
 JSR DETOK_BANK2                                  ; B375: 20 EF B0     ..
 JSR LF2BD                                        ; B378: 20 BD F2     ..
 LDY #&64 ; 'd'                                   ; B37B: A0 64       .d
 JMP DELAY                                        ; B37D: 4C A2 EB    L..

; ******************************************************************************
.PAUSE
 JSR LF186                                        ; B380: 20 86 F1     ..
 JSR LD8C5                                        ; B383: 20 C5 D8     ..
 LDA L00B8                                        ; B386: A5 B8       ..
 STA L00D2                                        ; B388: 85 D2       ..
 LDA #&28 ; '('                                   ; B38A: A9 28       .(
 STA L00D8                                        ; B38C: 85 D8       ..
 LDX #8                                           ; B38E: A2 08       ..
 STX L00CC                                        ; B390: 86 CC       ..
.loop_CB392
 JSR PAS1                                         ; B392: 20 7A EF     z.
 LDA L04B2                                        ; B395: AD B2 04    ...
 ORA L04B4                                        ; B398: 0D B4 04    ...
 BPL loop_CB392                                   ; B39B: 10 F5       ..
.loop_CB39D
 JSR PAS1                                         ; B39D: 20 7A EF     z.
 LDA L04B2                                        ; B3A0: AD B2 04    ...
 ORA L04B4                                        ; B3A3: 0D B4 04    ...
 BMI loop_CB39D                                   ; B3A6: 30 F5       0.
 LDA #0                                           ; B3A8: A9 00       ..
 STA INWK_31                                      ; B3AA: 85 28       .(
 LDA #&93                                         ; B3AC: A9 93       ..
 JSR TT66                                         ; B3AE: 20 6E F2     n.
; ******************************************************************************
.MT23
 LDA #9                                           ; B3B1: A9 09       ..
; overlapping:  L07A9                             ; B3B3: 2C A9 07    ,..
 EQUB &2C                                         ; B3B3: 2C          ,

; ******************************************************************************
.MT29
 LDA #7                                           ; B3B4: A9 07       ..
 STA YC                                           ; B3B6: 85 3B       .;
; ******************************************************************************
.MT13
 LDA #&80                                         ; B3B8: A9 80       ..
 STA DTW1                                         ; B3BA: 8D F8 03    ...
 STA DTW6                                         ; B3BD: 8D F3 03    ...
 RTS                                              ; B3C0: 60          `

; ******************************************************************************
.PAUSE2
 JSR LF186                                        ; B3C1: 20 86 F1     ..
.loop_CB3C4
 JSR LEC7D                                        ; B3C4: 20 7D EC     }.
 LDA L04B2                                        ; B3C7: AD B2 04    ...
 ORA L04B4                                        ; B3CA: 0D B4 04    ...
 AND #&C0                                         ; B3CD: 29 C0       ).
 CMP #&40 ; '@'                                   ; B3CF: C9 40       .@
 BNE loop_CB3C4                                   ; B3D1: D0 F1       ..
 RTS                                              ; B3D3: 60          `

.RUPLA_LO

 EQUB LO(RUPLA - 1)
 EQUB LO(RUPLA_DE - 1)
 EQUB LO(RUPLA_FR - 1)
 EQUB &43

.RUPLA_HI

 EQUB HI(RUPLA - 1)
 EQUB HI(RUPLA_DE - 1)
 EQUB HI(RUPLA_FR - 1)
 EQUB &AB

.RUGAL_LO

 EQUB LO(RUGAL - 1)
 EQUB LO(RUGAL_DE - 1)
 EQUB LO(RUGAL_FR - 1)
 EQUB &5A

.RUGAL_HI
 EQUB HI(RUGAL - 1)
 EQUB HI(RUGAL_DE - 1)
 EQUB HI(RUGAL_FR - 1)
 EQUB &AB

.NRU

 EQUB &17, &17, &17, &17                          ; B3E4: 17 17 17... ...

; ******************************************************************************
.PDESC
 LDA QQ8                                          ; B3E8: AD 9B 04    ...
 ORA QQ8_1                                        ; B3EB: 0D 9C 04    ...
 BNE CB43E                                        ; B3EE: D0 4E       .N
 LDA QQ12                                         ; B3F0: A5 A5       ..
 BPL CB43E                                        ; B3F2: 10 4A       .J
 LDX LANG                                         ; B3F4: AE A8 04    ...
 LDA RUPLA_LO,X                                   ; B3F7: BD D4 B3    ...
 STA SC                                           ; B3FA: 85 07       ..
 LDA RUPLA_HI,X                                   ; B3FC: BD D8 B3    ...
 STA SC_1                                         ; B3FF: 85 08       ..
 LDA RUGAL_LO,X                                   ; B401: BD DC B3    ...
 STA L00BA                                        ; B404: 85 BA       ..
 LDA RUGAL_HI,X                                   ; B406: BD E0 B3    ...
 STA L00BB                                        ; B409: 85 BB       ..
 LDY NRU,X                                        ; B40B: BC E4 B3    ...
.CB40E
 LDA (SC),Y                                       ; B40E: B1 07       ..
 CMP L049F                                        ; B410: CD 9F 04    ...
 BNE CB43B                                        ; B413: D0 26       .&
 LDA (L00BA),Y                                    ; B415: B1 BA       ..
 AND #&7F                                         ; B417: 29 7F       ).
 CMP GCNT                                         ; B419: CD A7 03    ...
 BNE CB43B                                        ; B41C: D0 1D       ..
 LDA (L00BA),Y                                    ; B41E: B1 BA       ..
 BMI CB42E                                        ; B420: 30 0C       0.
 LDA TP                                           ; B422: AD 9E 03    ...
 LSR A                                            ; B425: 4A          J
 BCC CB43E                                        ; B426: 90 16       ..
 JSR MT14                                         ; B428: 20 A8 B2     ..
 LDA #1                                           ; B42B: A9 01       ..
; overlapping:  LB0A9                             ; B42D: 2C A9 B0    ,..
 EQUB &2C                                         ; B42D: 2C          ,

.CB42E
 LDA #&B0                                         ; B42E: A9 B0       ..
 JSR DETOK2                                       ; B430: 20 4B B1     K.
 TYA                                              ; B433: 98          .
 JSR DETOK3                                       ; B434: 20 D6 B0     ..
 LDA #&B1                                         ; B437: A9 B1       ..
 BNE CB449                                        ; B439: D0 0E       ..
.CB43B
 DEY                                              ; B43B: 88          .
 BNE CB40E                                        ; B43C: D0 D0       ..
.CB43E
 LDX #3                                           ; B43E: A2 03       ..
.loop_CB440
 LDA QQ15_2,X                                     ; B440: B5 84       ..
 STA RAND,X                                       ; B442: 95 02       ..
 DEX                                              ; B444: CA          .
 BPL loop_CB440                                   ; B445: 10 F9       ..
 LDA #5                                           ; B447: A9 05       ..
.CB449
 JMP DETOK_BANK2                                  ; B449: 4C EF B0    L..

.loop_CB44C
 JMP TT27_control_codes                           ; B44C: 4C 37 F2    L7.

; ******************************************************************************
.TT27_BANK2
 PHA                                              ; B44F: 48          H
 LDA L00E9                                        ; B450: A5 E9       ..
 BPL CB45D                                        ; B452: 10 09       ..
 LDA PPUSTATUS                                    ; B454: AD 02 20    ..
 ASL A                                            ; B457: 0A          .
 BPL CB45D                                        ; B458: 10 03       ..
 JSR NAMETABLE0                                   ; B45A: 20 6D D0     m.
.CB45D
 PLA                                              ; B45D: 68          h
 TAX                                              ; B45E: AA          .
 BMI TT43                                         ; B45F: 30 31       01
 CMP #&0A                                         ; B461: C9 0A       ..
 BCC loop_CB44C                                   ; B463: 90 E7       ..
 CMP #&60 ; '`'                                   ; B465: C9 60       .`
 BCS ex                                           ; B467: B0 41       .A
 CMP #&0E                                         ; B469: C9 0E       ..
 BCC CB471                                        ; B46B: 90 04       ..
 CMP #&20 ; ' '                                   ; B46D: C9 20       .
 BCC qw                                           ; B46F: 90 18       ..
.CB471
 LDX QQ17                                         ; B471: A6 3C       .<
 BEQ CB47F                                        ; B473: F0 0A       ..
 BMI CB482                                        ; B475: 30 0B       0.
 BIT QQ17                                         ; B477: 24 3C       $<
 BVS CB47F                                        ; B479: 70 04       p.
.loop_CB47B
 TAX                                              ; B47B: AA          .
 LDA LB8B4,X                                      ; B47C: BD B4 B8    ...
.CB47F
 JMP DASC_BANK2                                   ; B47F: 4C F5 B4    L..

.CB482
 BIT QQ17                                         ; B482: 24 3C       $<
 BVS CB48D                                        ; B484: 70 07       p.
 JMP DASC_BANK2                                   ; B486: 4C F5 B4    L..

.qw
 ADC #&72 ; 'r'                                   ; B489: 69 72       ir
 BNE ex                                           ; B48B: D0 1D       ..
.CB48D
 CPX #&FF                                         ; B48D: E0 FF       ..
 BNE loop_CB47B                                   ; B48F: D0 EA       ..
 RTS                                              ; B491: 60          `

; ******************************************************************************
.TT43
 CMP #&A0                                         ; B492: C9 A0       ..
 BCS CB4A8                                        ; B494: B0 12       ..
 AND #&7F                                         ; B496: 29 7F       ).
 ASL A                                            ; B498: 0A          .
 TAY                                              ; B499: A8          .
 LDA QQ16,Y                                       ; B49A: B9 33 B3    .3.
 JSR TT27_BANK2                                   ; B49D: 20 4F B4     O.
 LDA QQ16_1,Y                                     ; B4A0: B9 34 B3    .4.
 CMP #&3F ; '?'                                   ; B4A3: C9 3F       .?
 BNE TT27_BANK2                                   ; B4A5: D0 A8       ..
 RTS                                              ; B4A7: 60          `

.CB4A8
 SBC #&A0                                         ; B4A8: E9 A0       ..
; ******************************************************************************
.ex
 TAX                                              ; B4AA: AA          .
 LDA QQ18LO                                       ; B4AB: AD A4 04    ...
 STA V                                            ; B4AE: 85 63       .c
 LDA QQ18HI                                       ; B4B0: AD A5 04    ...
 STA V_1                                          ; B4B3: 85 64       .d
 LDY #0                                           ; B4B5: A0 00       ..
 TXA                                              ; B4B7: 8A          .
 BEQ CB4DA                                        ; B4B8: F0 20       .
.CB4BA
 LDA (V),Y                                        ; B4BA: B1 63       .c
 BEQ CB4C5                                        ; B4BC: F0 07       ..
 INY                                              ; B4BE: C8          .
 BNE CB4BA                                        ; B4BF: D0 F9       ..
 INC V_1                                          ; B4C1: E6 64       .d
 BNE CB4BA                                        ; B4C3: D0 F5       ..
.CB4C5
 LDA L00E9                                        ; B4C5: A5 E9       ..
 BPL CB4D2                                        ; B4C7: 10 09       ..
 LDA PPUSTATUS                                    ; B4C9: AD 02 20    ..
 ASL A                                            ; B4CC: 0A          .
 BPL CB4D2                                        ; B4CD: 10 03       ..
 JSR NAMETABLE0                                   ; B4CF: 20 6D D0     m.
.CB4D2
 INY                                              ; B4D2: C8          .
 BNE CB4D7                                        ; B4D3: D0 02       ..
 INC V_1                                          ; B4D5: E6 64       .d
.CB4D7
 DEX                                              ; B4D7: CA          .
 BNE CB4BA                                        ; B4D8: D0 E0       ..
.CB4DA
 TYA                                              ; B4DA: 98          .
 PHA                                              ; B4DB: 48          H
 LDA V_1                                          ; B4DC: A5 64       .d
 PHA                                              ; B4DE: 48          H
 LDA (V),Y                                        ; B4DF: B1 63       .c
 EOR #&3E ; '>'                                   ; B4E1: 49 3E       I>
 JSR TT27_BANK2                                   ; B4E3: 20 4F B4     O.
 PLA                                              ; B4E6: 68          h
 STA V_1                                          ; B4E7: 85 64       .d
 PLA                                              ; B4E9: 68          h
 TAY                                              ; B4EA: A8          .
 INY                                              ; B4EB: C8          .
 BNE CB4F0                                        ; B4EC: D0 02       ..
 INC V_1                                          ; B4EE: E6 64       .d
.CB4F0
 LDA (V),Y                                        ; B4F0: B1 63       .c
 BNE CB4DA                                        ; B4F2: D0 E6       ..
 RTS                                              ; B4F4: 60          `

; ******************************************************************************
.DASC_BANK2
 STA SC_1                                         ; B4F5: 85 08       ..
 LDA L00E9                                        ; B4F7: A5 E9       ..
 BPL CB504                                        ; B4F9: 10 09       ..
 LDA PPUSTATUS                                    ; B4FB: AD 02 20    ..
 ASL A                                            ; B4FE: 0A          .
 BPL CB504                                        ; B4FF: 10 03       ..
 JSR NAMETABLE0                                   ; B501: 20 6D D0     m.
.CB504
 LDA SC_1                                         ; B504: A5 08       ..
 STX SC                                           ; B506: 86 07       ..
 LDX #&FF                                         ; B508: A2 FF       ..
 STX DTW8                                         ; B50A: 8E F9 03    ...
 CMP #&20 ; ' '                                   ; B50D: C9 20       .
 BEQ CB536                                        ; B50F: F0 25       .%
 CMP #&2E ; '.'                                   ; B511: C9 2E       ..
 BEQ CB536                                        ; B513: F0 21       .!
 CMP #&3A ; ':'                                   ; B515: C9 3A       .:
 BEQ CB536                                        ; B517: F0 1D       ..
 CMP #&27 ; '''                                   ; B519: C9 27       .'
 BEQ CB536                                        ; B51B: F0 19       ..
 CMP #&28 ; '('                                   ; B51D: C9 28       .(
 BEQ CB536                                        ; B51F: F0 15       ..
 CMP #&0A                                         ; B521: C9 0A       ..
 BEQ CB536                                        ; B523: F0 11       ..
 CMP #&0C                                         ; B525: C9 0C       ..
 BEQ CB536                                        ; B527: F0 0D       ..
 CMP #&2D ; '-'                                   ; B529: C9 2D       .-
 BEQ CB536                                        ; B52B: F0 09       ..
 LDA QQ17                                         ; B52D: A5 3C       .<
 ORA #&40 ; '@'                                   ; B52F: 09 40       .@
 STA QQ17                                         ; B531: 85 3C       .<
 INX                                              ; B533: E8          .
 BEQ CB53C                                        ; B534: F0 06       ..
.CB536
 LDA QQ17                                         ; B536: A5 3C       .<
 AND #&BF                                         ; B538: 29 BF       ).
 STA QQ17                                         ; B53A: 85 3C       .<
.CB53C
 STX DTW2                                         ; B53C: 8E F4 03    ...
 LDX SC                                           ; B53F: A6 07       ..
 LDA SC_1                                         ; B541: A5 08       ..
 BIT DTW4                                         ; B543: 2C F6 03    ,..
 BMI CB54B                                        ; B546: 30 03       0.
 JMP CHPR                                         ; B548: 4C 35 B6    L5.

.CB54B
 BIT DTW4                                         ; B54B: 2C F6 03    ,..
 BVS CB554                                        ; B54E: 70 04       p.
 CMP #&0C                                         ; B550: C9 0C       ..
 BEQ DA1                                          ; B552: F0 20       .
.CB554
 LDX DTW5                                         ; B554: AE F7 03    ...
 STA BUF,X                                        ; B557: 9D 07 05    ...
 LDX SC                                           ; B55A: A6 07       ..
 INC DTW5                                         ; B55C: EE F7 03    ...
 LDA L00E9                                        ; B55F: A5 E9       ..
 BPL CB56C                                        ; B561: 10 09       ..
 LDA PPUSTATUS                                    ; B563: AD 02 20    ..
 ASL A                                            ; B566: 0A          .
 BPL CB56C                                        ; B567: 10 03       ..
 JSR NAMETABLE0                                   ; B569: 20 6D D0     m.
.CB56C
 CLC                                              ; B56C: 18          .
 RTS                                              ; B56D: 60          `

.loop_CB56E
 JMP CB615                                        ; B56E: 4C 15 B6    L..

.loop_CB571
 JMP CB612                                        ; B571: 4C 12 B6    L..

.DA1
 TXA                                              ; B574: 8A          .
 PHA                                              ; B575: 48          H
 TYA                                              ; B576: 98          .
 PHA                                              ; B577: 48          H
.CB578
 LDX DTW5                                         ; B578: AE F7 03    ...
 BEQ loop_CB56E                                   ; B57B: F0 F1       ..
 CPX #&1E                                         ; B57D: E0 1E       ..
 BCC loop_CB571                                   ; B57F: 90 F0       ..
 LSR SC_1                                         ; B581: 46 08       F.
.CB583
 LDA SC_1                                         ; B583: A5 08       ..
 BMI CB58B                                        ; B585: 30 04       0.
 LDA #&40 ; '@'                                   ; B587: A9 40       .@
 STA SC_1                                         ; B589: 85 08       ..
.CB58B
 LDY #&1C                                         ; B58B: A0 1C       ..
.CB58D
 LDA L0524                                        ; B58D: AD 24 05    .$.
 CMP #&20 ; ' '                                   ; B590: C9 20       .
 BEQ CB5DD                                        ; B592: F0 49       .I
.CB594
 LDA L00E9                                        ; B594: A5 E9       ..
 BPL CB5A1                                        ; B596: 10 09       ..
 LDA PPUSTATUS                                    ; B598: AD 02 20    ..
 ASL A                                            ; B59B: 0A          .
 BPL CB5A1                                        ; B59C: 10 03       ..
 JSR NAMETABLE0                                   ; B59E: 20 6D D0     m.
.CB5A1
 DEY                                              ; B5A1: 88          .
 BMI CB583                                        ; B5A2: 30 DF       0.
 BEQ CB583                                        ; B5A4: F0 DD       ..
 LDA BUF,Y                                        ; B5A6: B9 07 05    ...
 CMP #&20 ; ' '                                   ; B5A9: C9 20       .
 BNE CB594                                        ; B5AB: D0 E7       ..
 ASL SC_1                                         ; B5AD: 06 08       ..
 BMI CB594                                        ; B5AF: 30 E3       0.
 STY SC                                           ; B5B1: 84 07       ..
 LDY DTW5                                         ; B5B3: AC F7 03    ...
.loop_CB5B6
 LDA L00E9                                        ; B5B6: A5 E9       ..
 BPL CB5C3                                        ; B5B8: 10 09       ..
 LDA PPUSTATUS                                    ; B5BA: AD 02 20    ..
 ASL A                                            ; B5BD: 0A          .
 BPL CB5C3                                        ; B5BE: 10 03       ..
 JSR NAMETABLE0                                   ; B5C0: 20 6D D0     m.
.CB5C3
 LDA BUF,Y                                        ; B5C3: B9 07 05    ...
 STA BUF_1,Y                                      ; B5C6: 99 08 05    ...
 DEY                                              ; B5C9: 88          .
 CPY SC                                           ; B5CA: C4 07       ..
 BCS loop_CB5B6                                   ; B5CC: B0 E8       ..
 INC DTW5                                         ; B5CE: EE F7 03    ...
 LDA #&20 ; ' '                                   ; B5D1: A9 20       .
.loop_CB5D3
 CMP BUF,Y                                        ; B5D3: D9 07 05    ...
 BNE CB58D                                        ; B5D6: D0 B5       ..
 DEY                                              ; B5D8: 88          .
 BPL loop_CB5D3                                   ; B5D9: 10 F8       ..
 BMI CB583                                        ; B5DB: 30 A6       0.
.CB5DD
 LDX #&1D                                         ; B5DD: A2 1D       ..
 JSR DAS1                                         ; B5DF: 20 05 B6     ..
 LDA #&0C                                         ; B5E2: A9 0C       ..
 JSR CHPR                                         ; B5E4: 20 35 B6     5.
 LDA DTW5                                         ; B5E7: AD F7 03    ...
 SBC #&1D                                         ; B5EA: E9 1D       ..
 STA DTW5                                         ; B5EC: 8D F7 03    ...
 TAX                                              ; B5EF: AA          .
 BEQ CB615                                        ; B5F0: F0 23       .#
 LDY #0                                           ; B5F2: A0 00       ..
 INX                                              ; B5F4: E8          .
 JSR LEC7D                                        ; B5F5: 20 7D EC     }.
.loop_CB5F8
 LDA L0525,Y                                      ; B5F8: B9 25 05    .%.
 STA BUF,Y                                        ; B5FB: 99 07 05    ...
 INY                                              ; B5FE: C8          .
 DEX                                              ; B5FF: CA          .
 BNE loop_CB5F8                                   ; B600: D0 F6       ..
 JMP CB578                                        ; B602: 4C 78 B5    Lx.

.DAS1
 LDY #0                                           ; B605: A0 00       ..
.loop_CB607
 LDA BUF,Y                                        ; B607: B9 07 05    ...
 JSR CHPR                                         ; B60A: 20 35 B6     5.
 INY                                              ; B60D: C8          .
 DEX                                              ; B60E: CA          .
 BNE loop_CB607                                   ; B60F: D0 F6       ..
 RTS                                              ; B611: 60          `

.CB612
 JSR DAS1                                         ; B612: 20 05 B6     ..
.CB615
 STX DTW5                                         ; B615: 8E F7 03    ...
 PLA                                              ; B618: 68          h
 TAY                                              ; B619: A8          .
 PLA                                              ; B61A: 68          h
 TAX                                              ; B61B: AA          .
 LDA #&0C                                         ; B61C: A9 0C       ..
; overlapping:  L07A9                             ; B61E: 2C A9 07    ,..
 EQUB &2C                                         ; B61E: 2C          ,

; ******************************************************************************
.BELL
 LDA #7                                           ; B61F: A9 07       ..
 JMP CHPR                                         ; B621: 4C 35 B6    L5.

.CB624
 JMP CB75B                                        ; B624: 4C 5B B7    L[.

.CB627
 LDA #2                                           ; B627: A9 02       ..
 STA YC                                           ; B629: 85 3B       .;
 LDA K3                                           ; B62B: A5 3D       .=
 JMP CB652                                        ; B62D: 4C 52 B6    LR.

.CB630
 JMP CB75B                                        ; B630: 4C 5B B7    L[.

; ******************************************************************************
.TT67X
 LDA #&0C                                         ; B633: A9 0C       ..
; ******************************************************************************
.CHPR
 STA K3                                           ; B635: 85 3D       .=
 LDA L00E9                                        ; B637: A5 E9       ..
 BPL CB644                                        ; B639: 10 09       ..
 LDA PPUSTATUS                                    ; B63B: AD 02 20    ..
 ASL A                                            ; B63E: 0A          .
 BPL CB644                                        ; B63F: 10 03       ..
 JSR NAMETABLE0                                   ; B641: 20 6D D0     m.
.CB644
 LDA K3                                           ; B644: A5 3D       .=
 STY L0482                                        ; B646: 8C 82 04    ...
 STX L0481                                        ; B649: 8E 81 04    ...
 LDY QQ17                                         ; B64C: A4 3C       .<
 CPY #&FF                                         ; B64E: C0 FF       ..
 BEQ CB630                                        ; B650: F0 DE       ..
.CB652
 CMP #7                                           ; B652: C9 07       ..
 BEQ CB624                                        ; B654: F0 CE       ..
 CMP #&20 ; ' '                                   ; B656: C9 20       .
 BCS RR1                                          ; B658: B0 10       ..
 CMP #&0A                                         ; B65A: C9 0A       ..
 BEQ CB662                                        ; B65C: F0 04       ..
 LDX #1                                           ; B65E: A2 01       ..
 STX XC                                           ; B660: 86 32       .2
.CB662
 CMP #&0D                                         ; B662: C9 0D       ..
 BEQ CB630                                        ; B664: F0 CA       ..
 INC YC                                           ; B666: E6 3B       .;
 BNE CB630                                        ; B668: D0 C6       ..
.RR1
 LDX XC                                           ; B66A: A6 32       .2
 CPX #&1F                                         ; B66C: E0 1F       ..
 BCC CB676                                        ; B66E: 90 06       ..
 LDX #1                                           ; B670: A2 01       ..
 STX XC                                           ; B672: 86 32       .2
 INC YC                                           ; B674: E6 3B       .;
.CB676
 LDX YC                                           ; B676: A6 3B       .;
 CPX #&1B                                         ; B678: E0 1B       ..
 BCC CB67F                                        ; B67A: 90 03       ..
 JMP CB627                                        ; B67C: 4C 27 B6    L'.

.CB67F
 CMP #&7F                                         ; B67F: C9 7F       ..
 BNE CB686                                        ; B681: D0 03       ..
 JMP CB7BF                                        ; B683: 4C BF B7    L..

.CB686
 INC XC                                           ; B686: E6 32       .2
 LDA W                                            ; B688: A5 9E       ..
 AND #&30 ; '0'                                   ; B68A: 29 30       )0
 BEQ CB6A9                                        ; B68C: F0 1B       ..
 LDY L0037                                        ; B68E: A4 37       .7
 CPY #1                                           ; B690: C0 01       ..
 BEQ CB6A4                                        ; B692: F0 10       ..
 AND #&20 ; ' '                                   ; B694: 29 20       )
 BEQ CB6A9                                        ; B696: F0 11       ..
 CPY #2                                           ; B698: C0 02       ..
 BNE CB6A9                                        ; B69A: D0 0D       ..
 LDA K3                                           ; B69C: A5 3D       .=
 CLC                                              ; B69E: 18          .
 ADC #&5F ; '_'                                   ; B69F: 69 5F       i_
 JMP CB7CF                                        ; B6A1: 4C CF B7    L..

.CB6A4
 LDA K3                                           ; B6A4: A5 3D       .=
 JMP CB7CF                                        ; B6A6: 4C CF B7    L..

.CB6A9
 LDA K3                                           ; B6A9: A5 3D       .=
 CMP #&20 ; ' '                                   ; B6AB: C9 20       .
 BNE CB6B2                                        ; B6AD: D0 03       ..
 JMP CB75B                                        ; B6AF: 4C 5B B7    L[.

.CB6B2
 TAY                                              ; B6B2: A8          .
 CLC                                              ; B6B3: 18          .
 ADC #&FD                                         ; B6B4: 69 FD       i.
 LDX #0                                           ; B6B6: A2 00       ..
 STX P_2                                          ; B6B8: 86 31       .1
 ASL A                                            ; B6BA: 0A          .
 ROL P_2                                          ; B6BB: 26 31       &1
 ASL A                                            ; B6BD: 0A          .
 ROL P_2                                          ; B6BE: 26 31       &1
 ASL A                                            ; B6C0: 0A          .
 ROL P_2                                          ; B6C1: 26 31       &1
 ADC #0                                           ; B6C3: 69 00       i.
 STA P_1                                          ; B6C5: 85 30       .0
 LDA P_2                                          ; B6C7: A5 31       .1
 ADC #&FC                                         ; B6C9: 69 FC       i.
 STA P_2                                          ; B6CB: 85 31       .1
 LDA #0                                           ; B6CD: A9 00       ..
 STA SC_1                                         ; B6CF: 85 08       ..
 LDA YC                                           ; B6D1: A5 3B       .;
 BNE CB6D8                                        ; B6D3: D0 03       ..
 JMP CB8A6                                        ; B6D5: 4C A6 B8    L..

.CB6D8
 LDA W                                            ; B6D8: A5 9E       ..
 BNE CB6DF                                        ; B6DA: D0 03       ..
 JMP CB83E                                        ; B6DC: 4C 3E B8    L>.

.CB6DF
 JSR LDBD8                                        ; B6DF: 20 D8 DB     ..
 LDY XC                                           ; B6E2: A4 32       .2
 DEY                                              ; B6E4: 88          .
 LDA (SC),Y                                       ; B6E5: B1 07       ..
 BEQ CB6E9                                        ; B6E7: F0 00       ..
.CB6E9
 LDA L00B8                                        ; B6E9: A5 B8       ..
 BEQ CB75B                                        ; B6EB: F0 6E       .n
 CMP #&FF                                         ; B6ED: C9 FF       ..
 BEQ CB75B                                        ; B6EF: F0 6A       .j
 STA (SC),Y                                       ; B6F1: 91 07       ..
 STA (L00BA),Y                                    ; B6F3: 91 BA       ..
 INC L00B8                                        ; B6F5: E6 B8       ..
 LDY L0037                                        ; B6F7: A4 37       .7
 DEY                                              ; B6F9: 88          .
 BEQ CB772                                        ; B6FA: F0 76       .v
 DEY                                              ; B6FC: 88          .
 BNE CB702                                        ; B6FD: D0 03       ..
 JMP CB784                                        ; B6FF: 4C 84 B7    L..

.CB702
 TAY                                              ; B702: A8          .
 LDX #&0C                                         ; B703: A2 0C       ..
 STX L00BB                                        ; B705: 86 BB       ..
 ASL A                                            ; B707: 0A          .
 ROL L00BB                                        ; B708: 26 BB       &.
 ASL A                                            ; B70A: 0A          .
 ROL L00BB                                        ; B70B: 26 BB       &.
 ASL A                                            ; B70D: 0A          .
 ROL L00BB                                        ; B70E: 26 BB       &.
 STA L00BA                                        ; B710: 85 BA       ..
 TYA                                              ; B712: 98          .
 LDX #&0D                                         ; B713: A2 0D       ..
 STX SC_1                                         ; B715: 86 08       ..
 ASL A                                            ; B717: 0A          .
 ROL SC_1                                         ; B718: 26 08       &.
 ASL A                                            ; B71A: 0A          .
 ROL SC_1                                         ; B71B: 26 08       &.
 ASL A                                            ; B71D: 0A          .
 ROL SC_1                                         ; B71E: 26 08       &.
 STA SC                                           ; B720: 85 07       ..
 LDY #0                                           ; B722: A0 00       ..
 LDA (P_1),Y                                      ; B724: B1 30       .0
 STA (SC),Y                                       ; B726: 91 07       ..
 STA (L00BA),Y                                    ; B728: 91 BA       ..
 INY                                              ; B72A: C8          .
 LDA (P_1),Y                                      ; B72B: B1 30       .0
 STA (SC),Y                                       ; B72D: 91 07       ..
 STA (L00BA),Y                                    ; B72F: 91 BA       ..
 INY                                              ; B731: C8          .
 LDA (P_1),Y                                      ; B732: B1 30       .0
 STA (SC),Y                                       ; B734: 91 07       ..
 STA (L00BA),Y                                    ; B736: 91 BA       ..
 INY                                              ; B738: C8          .
 LDA (P_1),Y                                      ; B739: B1 30       .0
 STA (SC),Y                                       ; B73B: 91 07       ..
 STA (L00BA),Y                                    ; B73D: 91 BA       ..
 INY                                              ; B73F: C8          .
 LDA (P_1),Y                                      ; B740: B1 30       .0
 STA (SC),Y                                       ; B742: 91 07       ..
 STA (L00BA),Y                                    ; B744: 91 BA       ..
 INY                                              ; B746: C8          .
 LDA (P_1),Y                                      ; B747: B1 30       .0
 STA (SC),Y                                       ; B749: 91 07       ..
 STA (L00BA),Y                                    ; B74B: 91 BA       ..
 INY                                              ; B74D: C8          .
 LDA (P_1),Y                                      ; B74E: B1 30       .0
 STA (SC),Y                                       ; B750: 91 07       ..
 STA (L00BA),Y                                    ; B752: 91 BA       ..
 INY                                              ; B754: C8          .
 LDA (P_1),Y                                      ; B755: B1 30       .0
 STA (L00BA),Y                                    ; B757: 91 BA       ..
 STA (SC),Y                                       ; B759: 91 07       ..
.CB75B
 LDY L0482                                        ; B75B: AC 82 04    ...
 LDX L0481                                        ; B75E: AE 81 04    ...
 LDA L00E9                                        ; B761: A5 E9       ..
 BPL CB76E                                        ; B763: 10 09       ..
 LDA PPUSTATUS                                    ; B765: AD 02 20    ..
 ASL A                                            ; B768: 0A          .
 BPL CB76E                                        ; B769: 10 03       ..
 JSR NAMETABLE0                                   ; B76B: 20 6D D0     m.
.CB76E
 LDA K3                                           ; B76E: A5 3D       .=
 CLC                                              ; B770: 18          .
 RTS                                              ; B771: 60          `

.CB772
 LDX #&0C                                         ; B772: A2 0C       ..
 STX SC_1                                         ; B774: 86 08       ..
 ASL A                                            ; B776: 0A          .
 ROL SC_1                                         ; B777: 26 08       &.
 ASL A                                            ; B779: 0A          .
 ROL SC_1                                         ; B77A: 26 08       &.
 ASL A                                            ; B77C: 0A          .
 ROL SC_1                                         ; B77D: 26 08       &.
 STA SC                                           ; B77F: 85 07       ..
 JMP CB793                                        ; B781: 4C 93 B7    L..

.CB784
 LDX #&0D                                         ; B784: A2 0D       ..
 STX SC_1                                         ; B786: 86 08       ..
 ASL A                                            ; B788: 0A          .
 ROL SC_1                                         ; B789: 26 08       &.
 ASL A                                            ; B78B: 0A          .
 ROL SC_1                                         ; B78C: 26 08       &.
 ASL A                                            ; B78E: 0A          .
 ROL SC_1                                         ; B78F: 26 08       &.
 STA SC                                           ; B791: 85 07       ..
.CB793
 LDY #0                                           ; B793: A0 00       ..
 LDA (P_1),Y                                      ; B795: B1 30       .0
 STA (SC),Y                                       ; B797: 91 07       ..
 INY                                              ; B799: C8          .
 LDA (P_1),Y                                      ; B79A: B1 30       .0
 STA (SC),Y                                       ; B79C: 91 07       ..
 INY                                              ; B79E: C8          .
 LDA (P_1),Y                                      ; B79F: B1 30       .0
 STA (SC),Y                                       ; B7A1: 91 07       ..
 INY                                              ; B7A3: C8          .
 LDA (P_1),Y                                      ; B7A4: B1 30       .0
 STA (SC),Y                                       ; B7A6: 91 07       ..
 INY                                              ; B7A8: C8          .
 LDA (P_1),Y                                      ; B7A9: B1 30       .0
 STA (SC),Y                                       ; B7AB: 91 07       ..
 INY                                              ; B7AD: C8          .
 LDA (P_1),Y                                      ; B7AE: B1 30       .0
 STA (SC),Y                                       ; B7B0: 91 07       ..
 INY                                              ; B7B2: C8          .
 LDA (P_1),Y                                      ; B7B3: B1 30       .0
 STA (SC),Y                                       ; B7B5: 91 07       ..
 INY                                              ; B7B7: C8          .
 LDA (P_1),Y                                      ; B7B8: B1 30       .0
 STA (SC),Y                                       ; B7BA: 91 07       ..
 JMP CB75B                                        ; B7BC: 4C 5B B7    L[.

.CB7BF
 JSR LDBD8                                        ; B7BF: 20 D8 DB     ..
 LDY XC                                           ; B7C2: A4 32       .2
 DEC XC                                           ; B7C4: C6 32       .2
 LDA #0                                           ; B7C6: A9 00       ..
 STA (SC),Y                                       ; B7C8: 91 07       ..
 STA (L00BA),Y                                    ; B7CA: 91 BA       ..
 JMP CB75B                                        ; B7CC: 4C 5B B7    L[.

.CB7CF
 PHA                                              ; B7CF: 48          H
 JSR LDBD8                                        ; B7D0: 20 D8 DB     ..
 PLA                                              ; B7D3: 68          h
 CMP #&20 ; ' '                                   ; B7D4: C9 20       .
 BEQ CB7E5                                        ; B7D6: F0 0D       ..
.loop_CB7D8
 CLC                                              ; B7D8: 18          .
 ADC L00D9                                        ; B7D9: 65 D9       e.
.loop_CB7DB
 LDY XC                                           ; B7DB: A4 32       .2
 DEY                                              ; B7DD: 88          .
 STA (SC),Y                                       ; B7DE: 91 07       ..
 STA (L00BA),Y                                    ; B7E0: 91 BA       ..
 JMP CB75B                                        ; B7E2: 4C 5B B7    L[.

.CB7E5
 LDY W                                            ; B7E5: A4 9E       ..
 CPY #&9D                                         ; B7E7: C0 9D       ..
 BEQ CB7EF                                        ; B7E9: F0 04       ..
 CPY #&DF                                         ; B7EB: C0 DF       ..
 BNE loop_CB7D8                                   ; B7ED: D0 E9       ..
.CB7EF
 LDA #0                                           ; B7EF: A9 00       ..
 BEQ loop_CB7DB                                   ; B7F1: F0 E8       ..
.CB7F3
 LDX L00B9                                        ; B7F3: A6 B9       ..
 STX SC_1                                         ; B7F5: 86 08       ..
 ASL A                                            ; B7F7: 0A          .
 ROL SC_1                                         ; B7F8: 26 08       &.
 ASL A                                            ; B7FA: 0A          .
 ROL SC_1                                         ; B7FB: 26 08       &.
 ASL A                                            ; B7FD: 0A          .
 ROL SC_1                                         ; B7FE: 26 08       &.
 STA SC                                           ; B800: 85 07       ..
 LDY #0                                           ; B802: A0 00       ..
 LDA (P_1),Y                                      ; B804: B1 30       .0
 ORA (SC),Y                                       ; B806: 11 07       ..
 STA (SC),Y                                       ; B808: 91 07       ..
 INY                                              ; B80A: C8          .
 LDA (P_1),Y                                      ; B80B: B1 30       .0
 ORA (SC),Y                                       ; B80D: 11 07       ..
 STA (SC),Y                                       ; B80F: 91 07       ..
 INY                                              ; B811: C8          .
 LDA (P_1),Y                                      ; B812: B1 30       .0
 ORA (SC),Y                                       ; B814: 11 07       ..
 STA (SC),Y                                       ; B816: 91 07       ..
 INY                                              ; B818: C8          .
 LDA (P_1),Y                                      ; B819: B1 30       .0
 ORA (SC),Y                                       ; B81B: 11 07       ..
 STA (SC),Y                                       ; B81D: 91 07       ..
 INY                                              ; B81F: C8          .
 LDA (P_1),Y                                      ; B820: B1 30       .0
 ORA (SC),Y                                       ; B822: 11 07       ..
 STA (SC),Y                                       ; B824: 91 07       ..
 INY                                              ; B826: C8          .
 LDA (P_1),Y                                      ; B827: B1 30       .0
 ORA (SC),Y                                       ; B829: 11 07       ..
 STA (SC),Y                                       ; B82B: 91 07       ..
 INY                                              ; B82D: C8          .
 LDA (P_1),Y                                      ; B82E: B1 30       .0
 ORA (SC),Y                                       ; B830: 11 07       ..
 STA (SC),Y                                       ; B832: 91 07       ..
 INY                                              ; B834: C8          .
 LDA (P_1),Y                                      ; B835: B1 30       .0
 ORA (SC),Y                                       ; B837: 11 07       ..
 STA (SC),Y                                       ; B839: 91 07       ..
 JMP CB75B                                        ; B83B: 4C 5B B7    L[.

.CB83E
 LDA #0                                           ; B83E: A9 00       ..
 STA SC_1                                         ; B840: 85 08       ..
 LDA YC                                           ; B842: A5 3B       .;
 BNE CB848                                        ; B844: D0 02       ..
 LDA #&FF                                         ; B846: A9 FF       ..
.CB848
 CLC                                              ; B848: 18          .
 ADC #1                                           ; B849: 69 01       i.
 ASL A                                            ; B84B: 0A          .
 ASL A                                            ; B84C: 0A          .
 ASL A                                            ; B84D: 0A          .
 ASL A                                            ; B84E: 0A          .
 ROL SC_1                                         ; B84F: 26 08       &.
 SEC                                              ; B851: 38          8
 ROL A                                            ; B852: 2A          *
 STA SC                                           ; B853: 85 07       ..
 LDA SC_1                                         ; B855: A5 08       ..
 ROL A                                            ; B857: 2A          *
 ADC L00E6                                        ; B858: 65 E6       e.
 STA SC_1                                         ; B85A: 85 08       ..
 LDY XC                                           ; B85C: A4 32       .2
 DEY                                              ; B85E: 88          .
 LDA (SC),Y                                       ; B85F: B1 07       ..
 BNE CB7F3                                        ; B861: D0 90       ..
 LDA L00B8                                        ; B863: A5 B8       ..
 BEQ CB8A3                                        ; B865: F0 3C       .<
 STA (SC),Y                                       ; B867: 91 07       ..
 INC L00B8                                        ; B869: E6 B8       ..
 LDX L00B9                                        ; B86B: A6 B9       ..
 STX SC_1                                         ; B86D: 86 08       ..
 ASL A                                            ; B86F: 0A          .
 ROL SC_1                                         ; B870: 26 08       &.
 ASL A                                            ; B872: 0A          .
 ROL SC_1                                         ; B873: 26 08       &.
 ASL A                                            ; B875: 0A          .
 ROL SC_1                                         ; B876: 26 08       &.
 STA SC                                           ; B878: 85 07       ..
 LDY #0                                           ; B87A: A0 00       ..
 LDA (P_1),Y                                      ; B87C: B1 30       .0
 STA (SC),Y                                       ; B87E: 91 07       ..
 INY                                              ; B880: C8          .
 LDA (P_1),Y                                      ; B881: B1 30       .0
 STA (SC),Y                                       ; B883: 91 07       ..
 INY                                              ; B885: C8          .
 LDA (P_1),Y                                      ; B886: B1 30       .0
 STA (SC),Y                                       ; B888: 91 07       ..
 INY                                              ; B88A: C8          .
 LDA (P_1),Y                                      ; B88B: B1 30       .0
 STA (SC),Y                                       ; B88D: 91 07       ..
 INY                                              ; B88F: C8          .
 LDA (P_1),Y                                      ; B890: B1 30       .0
 STA (SC),Y                                       ; B892: 91 07       ..
 INY                                              ; B894: C8          .
 LDA (P_1),Y                                      ; B895: B1 30       .0
 STA (SC),Y                                       ; B897: 91 07       ..
 INY                                              ; B899: C8          .
 LDA (P_1),Y                                      ; B89A: B1 30       .0
 STA (SC),Y                                       ; B89C: 91 07       ..
 INY                                              ; B89E: C8          .
 LDA (P_1),Y                                      ; B89F: B1 30       .0
 STA (SC),Y                                       ; B8A1: 91 07       ..
.CB8A3
 JMP CB75B                                        ; B8A3: 4C 5B B7    L[.

.CB8A6
 LDA #&21 ; '!'                                   ; B8A6: A9 21       .!
 STA SC                                           ; B8A8: 85 07       ..
 LDA L00E6                                        ; B8AA: A5 E6       ..
 STA SC_1                                         ; B8AC: 85 08       ..
 LDY XC                                           ; B8AE: A4 32       .2
 DEY                                              ; B8B0: 88          .
 JMP CB6E9                                        ; B8B1: 4C E9 B6    L..

.LB8B4
 EQUB   0,   1,   2,   3,   4,   5,   6,   7,   8 ; B8B4: 00 01 02... ...
 EQUB   9, &0A, &0B, &0C, &0D, &0E, &0F, &10, &11 ; B8BD: 09 0A 0B... ...
 EQUB &12, &13, &14, &15, &16, &17, &18, &19, &1A ; B8C6: 12 13 14... ...
 EQUB &1B, &1C, &1D, &1E, &1F                     ; B8CF: 1B 1C 1D... ...
 EQUS " !$/$%&'()*+,-./0123456789:;%*>?`abcdef"   ; B8D4: 20 21 24...  !$
 EQUS "ghijklmnopqrstuvwxyz{|};+`abcdefghijklm"   ; B8FB: 67 68 69... ghi
 EQUS "nopqrstuvwxyz{|}~"                         ; B922: 6E 6F 70... nop
 EQUB &7F

 EQUB &FF, &FF, &FF, &FF, &FF, &FF, &FF, &FF ; B933: 7F FF FF... ...
 EQUB &FF, &FF, &FF, &FF, &FF, &FF, &FF, &FF, &FF ; B93C: FF FF FF... ...
 EQUB &FF, &FF, &FF, &FF, &FF, &FF, &FF, &FF, &FF ; B945: FF FF FF... ...
 EQUB &FF, &FF, &FF, &FF, &FF, &FF, &FF, &FF, &FF ; B94E: FF FF FF... ...
 EQUB &FF, &FF, &FF, &FF, &FF, &FF, &FF, &FF, &FF ; B957: FF FF FF... ...
 EQUB &FF, &FF, &FF, &FF, &FF, &FF, &FF, &FF, &FF ; B960: FF FF FF... ...
 EQUB &FF, &FF, &FF, &FF, &FF, &FF, &FF, &FF, &FF ; B969: FF FF FF... ...
 EQUB &FF, &FF, &FF, &FF, &FF, &FF, &FF, &FF, &FF ; B972: FF FF FF... ...
 EQUB &FF, &FF, &FF, &FF, &FF, &FF, &FF, &FF, &FF ; B97B: FF FF FF... ...
 EQUB &FF, &FF, &FF, &FF, &FF, &FF, &FF, &FF, &FF ; B984: FF FF FF... ...
 EQUB &FF, &FF, &FF, &FF, &FF, &FF, &FF, &FF, &FF ; B98D: FF FF FF... ...
 EQUB &FF, &FF, &FF, &FF, &FF, &FF, &FF, &FF, &FF ; B996: FF FF FF... ...
 EQUB &FF, &FF, &FF, &FF, &FF, &FF, &FF, &FF, &FF ; B99F: FF FF FF... ...
 EQUB &FF, &FF, &FF, &FF, &FF, &FF, &FF, &FF, &FF ; B9A8: FF FF FF... ...
 EQUB &FF, &FF, &FF, &FF, &FF, &FF, &FF, &FF, &FF ; B9B1: FF FF FF... ...
 EQUB &FF, &FF, &FF, &FF, &FF, &FF, &FF, &FF, &FF ; B9BA: FF FF FF... ...
 EQUB &FF, &FF, &FF, &FF, &FF, &FF, &FF, &FF, &FF ; B9C3: FF FF FF... ...
 EQUB &FF, &FF, &FF, &FF, &FF, &FF, &FF, &FF, &FF ; B9CC: FF FF FF... ...
 EQUB &FF, &FF, &FF, &FF, &FF, &FF, &FF, &FF, &FF ; B9D5: FF FF FF... ...
 EQUB &FF, &FF, &FF, &FF, &FF, &FF, &FF, &FF, &FF ; B9DE: FF FF FF... ...
 EQUB &FF, &FF, &FF, &FF, &FF, &FF, &FF, &FF, &FF ; B9E7: FF FF FF... ...
 EQUB &FF, &FF, &FF, &FF, &FF, &FF, &FF, &FF, &FF ; B9F0: FF FF FF... ...
 EQUB &FF, &FF, &FF, &FF, &FF, &FF, &FF, &FF, &FF ; B9F9: FF FF FF... ...
 EQUB &FF, &FF, &FF, &FF, &FF, &FF, &FF, &FF, &FF ; BA02: FF FF FF... ...
 EQUB &FF, &FF, &FF, &FF, &FF, &FF, &FF, &FF, &FF ; BA0B: FF FF FF... ...
 EQUB &FF, &FF, &FF, &FF, &FF, &FF, &FF, &FF, &FF ; BA14: FF FF FF... ...
 EQUB &FF, &FF, &FF, &FF, &FF, &FF, &FF, &FF, &FF ; BA1D: FF FF FF... ...
 EQUB &FF, &FF, &FF, &FF, &FF, &FF, &FF, &FF, &FF ; BA26: FF FF FF... ...
 EQUB &FF, &FF, &FF, &FF, &FF, &FF, &FF, &FF, &FF ; BA2F: FF FF FF... ...
 EQUB &FF, &FF, &FF, &FF, &FF, &FF, &FF, &FF, &FF ; BA38: FF FF FF... ...
 EQUB &FF, &FF, &FF, &FF, &FF, &FF, &FF, &FF, &FF ; BA41: FF FF FF... ...
 EQUB &FF, &FF, &FF, &FF, &FF, &FF, &FF, &FF, &FF ; BA4A: FF FF FF... ...
 EQUB &FF, &FF, &FF, &FF, &FF, &FF, &FF, &FF, &FF ; BA53: FF FF FF... ...
 EQUB &FF, &FF, &FF, &FF, &FF, &FF, &FF, &FF, &FF ; BA5C: FF FF FF... ...
 EQUB &FF, &FF, &FF, &FF, &FF, &FF, &FF, &FF, &FF ; BA65: FF FF FF... ...
 EQUB &FF, &FF, &FF, &FF, &FF, &FF, &FF, &FF, &FF ; BA6E: FF FF FF... ...
 EQUB &FF, &FF, &FF, &FF, &FF, &FF, &FF, &FF, &FF ; BA77: FF FF FF... ...
 EQUB &FF, &FF, &FF, &FF, &FF, &FF, &FF, &FF, &FF ; BA80: FF FF FF... ...
 EQUB &FF, &FF, &FF, &FF, &FF, &FF, &FF, &FF, &FF ; BA89: FF FF FF... ...
 EQUB &FF, &FF, &FF, &FF, &FF, &FF, &FF, &FF, &FF ; BA92: FF FF FF... ...
 EQUB &FF, &FF, &FF, &FF, &FF, &FF, &FF, &FF, &FF ; BA9B: FF FF FF... ...
 EQUB &FF, &FF, &FF, &FF, &FF, &FF, &FF, &FF, &FF ; BAA4: FF FF FF... ...
 EQUB &FF, &FF, &FF, &FF, &FF, &FF, &FF, &FF, &FF ; BAAD: FF FF FF... ...
 EQUB &FF, &FF, &FF, &FF, &FF, &FF, &FF, &FF, &FF ; BAB6: FF FF FF... ...
 EQUB &FF, &FF, &FF, &FF, &FF, &FF, &FF, &FF, &FF ; BABF: FF FF FF... ...
 EQUB &FF, &FF, &FF, &FF, &FF, &FF, &FF, &FF, &FF ; BAC8: FF FF FF... ...
 EQUB &FF, &FF, &FF, &FF, &FF, &FF, &FF, &FF, &FF ; BAD1: FF FF FF... ...
 EQUB &FF, &FF, &FF, &FF, &FF, &FF, &FF, &FF, &FF ; BADA: FF FF FF... ...
 EQUB &FF, &FF, &FF, &FF, &FF, &FF, &FF, &FF, &FF ; BAE3: FF FF FF... ...
 EQUB &FF, &FF, &FF, &FF, &FF, &FF, &FF, &FF, &FF ; BAEC: FF FF FF... ...
 EQUB &FF, &FF, &FF, &FF, &FF, &FF, &FF, &FF, &FF ; BAF5: FF FF FF... ...
 EQUB &FF, &FF, &FF, &FF, &FF, &FF, &FF, &FF, &FF ; BAFE: FF FF FF... ...
 EQUB &FF, &FF, &FF, &FF, &FF, &FF, &FF, &FF, &FF ; BB07: FF FF FF... ...
 EQUB &FF, &FF, &FF, &FF, &FF, &FF, &FF, &FF, &FF ; BB10: FF FF FF... ...
 EQUB &FF, &FF, &FF, &FF, &FF, &FF, &FF, &FF, &FF ; BB19: FF FF FF... ...
 EQUB &FF, &FF, &FF, &FF, &FF, &FF, &FF, &FF, &FF ; BB22: FF FF FF... ...
 EQUB &FF, &FF, &FF, &FF, &FF, &FF, &FF, &FF, &FF ; BB2B: FF FF FF... ...
 EQUB &FF, &FF, &FF, &FF, &FF, &FF, &FF, &FF, &FF ; BB34: FF FF FF... ...
 EQUB &FF, &FF, &FF, &FF, &FF, &FF, &FF, &FF, &FF ; BB3D: FF FF FF... ...
 EQUB &FF, &FF, &FF, &FF, &FF, &FF, &FF, &FF, &FF ; BB46: FF FF FF... ...
 EQUB &FF, &FF, &FF, &FF, &FF, &FF, &FF, &FF, &FF ; BB4F: FF FF FF... ...
 EQUB &FF, &FF, &FF, &FF, &FF, &FF, &FF, &FF, &FF ; BB58: FF FF FF... ...
 EQUB &FF, &FF, &FF, &FF, &FF, &FF, &FF, &FF, &FF ; BB61: FF FF FF... ...
 EQUB &FF, &FF, &FF, &FF, &FF, &FF, &FF, &FF, &FF ; BB6A: FF FF FF... ...
 EQUB &FF, &FF, &FF, &FF, &FF, &FF, &FF, &FF, &FF ; BB73: FF FF FF... ...
 EQUB &FF, &FF, &FF, &FF, &FF, &FF, &FF, &FF, &FF ; BB7C: FF FF FF... ...
 EQUB &FF, &FF, &FF, &FF, &FF, &FF, &FF, &FF, &FF ; BB85: FF FF FF... ...
 EQUB &FF, &FF, &FF, &FF, &FF, &FF, &FF, &FF, &FF ; BB8E: FF FF FF... ...
 EQUB &FF, &FF, &FF, &FF, &FF, &FF, &FF, &FF, &FF ; BB97: FF FF FF... ...
 EQUB &FF, &FF, &FF, &FF, &FF, &FF, &FF, &FF, &FF ; BBA0: FF FF FF... ...
 EQUB &FF, &FF, &FF, &FF, &FF, &FF, &FF, &FF, &FF ; BBA9: FF FF FF... ...
 EQUB &FF, &FF, &FF, &FF, &FF, &FF, &FF, &FF, &FF ; BBB2: FF FF FF... ...
 EQUB &FF, &FF, &FF, &FF, &FF, &FF, &FF, &FF, &FF ; BBBB: FF FF FF... ...
 EQUB &FF, &FF, &FF, &FF, &FF, &FF, &FF, &FF, &FF ; BBC4: FF FF FF... ...
 EQUB &FF, &FF, &FF, &FF, &FF, &FF, &FF, &FF, &FF ; BBCD: FF FF FF... ...
 EQUB &FF, &FF, &FF, &FF, &FF, &FF, &FF, &FF, &FF ; BBD6: FF FF FF... ...
 EQUB &FF, &FF, &FF, &FF, &FF, &FF, &FF, &FF, &FF ; BBDF: FF FF FF... ...
 EQUB &FF, &FF, &FF, &FF, &FF, &FF, &FF, &FF, &FF ; BBE8: FF FF FF... ...
 EQUB &FF, &FF, &FF, &FF, &FF, &FF, &FF, &FF, &FF ; BBF1: FF FF FF... ...
 EQUB &FF, &FF, &FF, &FF, &FF, &FF, &FF, &FF, &FF ; BBFA: FF FF FF... ...
 EQUB &FF, &FF, &FF, &FF, &FF, &FF, &FF, &FF, &FF ; BC03: FF FF FF... ...
 EQUB &FF, &FF, &FF, &FF, &FF, &FF, &FF, &FF, &FF ; BC0C: FF FF FF... ...
 EQUB &FF, &FF, &FF, &FF, &FF, &FF, &FF, &FF, &FF ; BC15: FF FF FF... ...
 EQUB &FF, &FF, &FF, &FF, &FF, &FF, &FF, &FF, &FF ; BC1E: FF FF FF... ...
 EQUB &FF, &FF, &FF, &FF, &FF, &FF, &FF, &FF, &FF ; BC27: FF FF FF... ...
 EQUB &FF, &FF, &FF, &FF, &FF, &FF, &FF, &FF, &FF ; BC30: FF FF FF... ...
 EQUB &FF, &FF, &FF, &FF, &FF, &FF, &FF, &FF, &FF ; BC39: FF FF FF... ...
 EQUB &FF, &FF, &FF, &FF, &FF, &FF, &FF, &FF, &FF ; BC42: FF FF FF... ...
 EQUB &FF, &FF, &FF, &FF, &FF, &FF, &FF, &FF, &FF ; BC4B: FF FF FF... ...
 EQUB &FF, &FF, &FF, &FF, &FF, &FF, &FF, &FF, &FF ; BC54: FF FF FF... ...
 EQUB &FF, &FF, &FF, &FF, &FF, &FF, &FF, &FF, &FF ; BC5D: FF FF FF... ...
 EQUB &FF, &FF, &FF, &FF, &FF, &FF, &FF, &FF, &FF ; BC66: FF FF FF... ...
 EQUB &FF, &FF, &FF, &FF, &FF, &FF, &FF, &FF, &FF ; BC6F: FF FF FF... ...
 EQUB &FF, &FF, &FF, &FF, &FF, &FF, &FF, &FF, &FF ; BC78: FF FF FF... ...
 EQUB &FF, &FF, &FF, &FF, &FF, &FF, &FF, &FF, &FF ; BC81: FF FF FF... ...
 EQUB &FF, &FF, &FF, &FF, &FF, &FF, &FF, &FF, &FF ; BC8A: FF FF FF... ...
 EQUB &FF, &FF, &FF, &FF, &FF, &FF, &FF, &FF, &FF ; BC93: FF FF FF... ...
 EQUB &FF, &FF, &FF, &FF, &FF, &FF, &FF, &FF, &FF ; BC9C: FF FF FF... ...
 EQUB &FF, &FF, &FF, &FF, &FF, &FF, &FF, &FF, &FF ; BCA5: FF FF FF... ...
 EQUB &FF, &FF, &FF, &FF, &FF, &FF, &FF, &FF, &FF ; BCAE: FF FF FF... ...
 EQUB &FF, &FF, &FF, &FF, &FF, &FF, &FF, &FF, &FF ; BCB7: FF FF FF... ...
 EQUB &FF, &FF, &FF, &FF, &FF, &FF, &FF, &FF, &FF ; BCC0: FF FF FF... ...
 EQUB &FF, &FF, &FF, &FF, &FF, &FF, &FF, &FF, &FF ; BCC9: FF FF FF... ...
 EQUB &FF, &FF, &FF, &FF, &FF, &FF, &FF, &FF, &FF ; BCD2: FF FF FF... ...
 EQUB &FF, &FF, &FF, &FF, &FF, &FF, &FF, &FF, &FF ; BCDB: FF FF FF... ...
 EQUB &FF, &FF, &FF, &FF, &FF, &FF, &FF, &FF, &FF ; BCE4: FF FF FF... ...
 EQUB &FF, &FF, &FF, &FF, &FF, &FF, &FF, &FF, &FF ; BCED: FF FF FF... ...
 EQUB &FF, &FF, &FF, &FF, &FF, &FF, &FF, &FF, &FF ; BCF6: FF FF FF... ...
 EQUB &FF, &FF, &FF, &FF, &FF, &FF, &FF, &FF, &FF ; BCFF: FF FF FF... ...
 EQUB &FF, &FF, &FF, &FF, &FF, &FF, &FF, &FF, &FF ; BD08: FF FF FF... ...
 EQUB &FF, &FF, &FF, &FF, &FF, &FF, &FF, &FF, &FF ; BD11: FF FF FF... ...
 EQUB &FF, &FF, &FF, &FF, &FF, &FF, &FF, &FF, &FF ; BD1A: FF FF FF... ...
 EQUB &FF, &FF, &FF, &FF, &FF, &FF, &FF, &FF, &FF ; BD23: FF FF FF... ...
 EQUB &FF, &FF, &FF, &FF, &FF, &FF, &FF, &FF, &FF ; BD2C: FF FF FF... ...
 EQUB &FF, &FF, &FF, &FF, &FF, &FF, &FF, &FF, &FF ; BD35: FF FF FF... ...
 EQUB &FF, &FF, &FF, &FF, &FF, &FF, &FF, &FF, &FF ; BD3E: FF FF FF... ...
 EQUB &FF, &FF, &FF, &FF, &FF, &FF, &FF, &FF, &FF ; BD47: FF FF FF... ...
 EQUB &FF, &FF, &FF, &FF, &FF, &FF, &FF, &FF, &FF ; BD50: FF FF FF... ...
 EQUB &FF, &FF, &FF, &FF, &FF, &FF, &FF, &FF, &FF ; BD59: FF FF FF... ...
 EQUB &FF, &FF, &FF, &FF, &FF, &FF, &FF, &FF, &FF ; BD62: FF FF FF... ...
 EQUB &FF, &FF, &FF, &FF, &FF, &FF, &FF, &FF, &FF ; BD6B: FF FF FF... ...
 EQUB &FF, &FF, &FF, &FF, &FF, &FF, &FF, &FF, &FF ; BD74: FF FF FF... ...
 EQUB &FF, &FF, &FF, &FF, &FF, &FF, &FF, &FF, &FF ; BD7D: FF FF FF... ...
 EQUB &FF, &FF, &FF, &FF, &FF, &FF, &FF, &FF, &FF ; BD86: FF FF FF... ...
 EQUB &FF, &FF, &FF, &FF, &FF, &FF, &FF, &FF, &FF ; BD8F: FF FF FF... ...
 EQUB &FF, &FF, &FF, &FF, &FF, &FF, &FF, &FF, &FF ; BD98: FF FF FF... ...
 EQUB &FF, &FF, &FF, &FF, &FF, &FF, &FF, &FF, &FF ; BDA1: FF FF FF... ...
 EQUB &FF, &FF, &FF, &FF, &FF, &FF, &FF, &FF, &FF ; BDAA: FF FF FF... ...
 EQUB &FF, &FF, &FF, &FF, &FF, &FF, &FF, &FF, &FF ; BDB3: FF FF FF... ...
 EQUB &FF, &FF, &FF, &FF, &FF, &FF, &FF, &FF, &FF ; BDBC: FF FF FF... ...
 EQUB &FF, &FF, &FF, &FF, &FF, &FF, &FF, &FF, &FF ; BDC5: FF FF FF... ...
 EQUB &FF, &FF, &FF, &FF, &FF, &FF, &FF, &FF, &FF ; BDCE: FF FF FF... ...
 EQUB &FF, &FF, &FF, &FF, &FF, &FF, &FF, &FF, &FF ; BDD7: FF FF FF... ...
 EQUB &FF, &FF, &FF, &FF, &FF, &FF, &FF, &FF, &FF ; BDE0: FF FF FF... ...
 EQUB &FF, &FF, &FF, &FF, &FF, &FF, &FF, &FF, &FF ; BDE9: FF FF FF... ...
 EQUB &FF, &FF, &FF, &FF, &FF, &FF, &FF, &FF, &FF ; BDF2: FF FF FF... ...
 EQUB &FF, &FF, &FF, &FF, &FF, &FF, &FF, &FF, &FF ; BDFB: FF FF FF... ...
 EQUB &FF, &FF, &FF, &FF, &FF, &FF, &FF, &FF, &FF ; BE04: FF FF FF... ...
 EQUB &FF, &FF, &FF, &FF, &FF, &FF, &FF, &FF, &FF ; BE0D: FF FF FF... ...
 EQUB &FF, &FF, &FF, &FF, &FF, &FF, &FF, &FF, &FF ; BE16: FF FF FF... ...
 EQUB &FF, &FF, &FF, &FF, &FF, &FF, &FF, &FF, &FF ; BE1F: FF FF FF... ...
 EQUB &FF, &FF, &FF, &FF, &FF, &FF, &FF, &FF, &FF ; BE28: FF FF FF... ...
 EQUB &FF, &FF, &FF, &FF, &FF, &FF, &FF, &FF, &FF ; BE31: FF FF FF... ...
 EQUB &FF, &FF, &FF, &FF, &FF, &FF, &FF, &FF, &FF ; BE3A: FF FF FF... ...
 EQUB &FF, &FF, &FF, &FF, &FF, &FF, &FF, &FF, &FF ; BE43: FF FF FF... ...
 EQUB &FF, &FF, &FF, &FF, &FF, &FF, &FF, &FF, &FF ; BE4C: FF FF FF... ...
 EQUB &FF, &FF, &FF, &FF, &FF, &FF, &FF, &FF, &FF ; BE55: FF FF FF... ...
 EQUB &FF, &FF, &FF, &FF, &FF, &FF, &FF, &FF, &FF ; BE5E: FF FF FF... ...
 EQUB &FF, &FF, &FF, &FF, &FF, &FF, &FF, &FF, &FF ; BE67: FF FF FF... ...
 EQUB &FF, &FF, &FF, &FF, &FF, &FF, &FF, &FF, &FF ; BE70: FF FF FF... ...
 EQUB &FF, &FF, &FF, &FF, &FF, &FF, &FF, &FF, &FF ; BE79: FF FF FF... ...
 EQUB &FF, &FF, &FF, &FF, &FF, &FF, &FF, &FF, &FF ; BE82: FF FF FF... ...
 EQUB &FF, &FF, &FF, &FF, &FF, &FF, &FF, &FF, &FF ; BE8B: FF FF FF... ...
 EQUB &FF, &FF, &FF, &FF, &FF, &FF, &FF, &FF, &FF ; BE94: FF FF FF... ...
 EQUB &FF, &FF, &FF, &FF, &FF, &FF, &FF, &FF, &FF ; BE9D: FF FF FF... ...
 EQUB &FF, &FF, &FF, &FF, &FF, &FF, &FF, &FF, &FF ; BEA6: FF FF FF... ...
 EQUB &FF, &FF, &FF, &FF, &FF, &FF, &FF, &FF, &FF ; BEAF: FF FF FF... ...
 EQUB &FF, &FF, &FF, &FF, &FF, &FF, &FF, &FF, &FF ; BEB8: FF FF FF... ...
 EQUB &FF, &FF, &FF, &FF, &FF, &FF, &FF, &FF, &FF ; BEC1: FF FF FF... ...
 EQUB &FF, &FF, &FF, &FF, &FF, &FF, &FF, &FF, &FF ; BECA: FF FF FF... ...
 EQUB &FF, &FF, &FF, &FF, &FF, &FF, &FF, &FF, &FF ; BED3: FF FF FF... ...
 EQUB &FF, &FF, &FF, &FF, &FF, &FF, &FF, &FF, &FF ; BEDC: FF FF FF... ...
 EQUB &FF, &FF, &FF, &FF, &FF, &FF, &FF, &FF, &FF ; BEE5: FF FF FF... ...
 EQUB &FF, &FF, &FF, &FF, &FF, &FF, &FF, &FF, &FF ; BEEE: FF FF FF... ...
 EQUB &FF, &FF, &FF, &FF, &FF, &FF, &FF, &FF, &FF ; BEF7: FF FF FF... ...
 EQUB &FF, &FF, &FF, &FF, &FF, &FF, &FF, &FF, &FF ; BF00: FF FF FF... ...
 EQUB &FF, &FF, &FF, &FF, &FF, &FF, &FF, &FF, &FF ; BF09: FF FF FF... ...
 EQUB &FF, &FF, &FF, &FF, &FF, &FF, &FF, &FF, &FF ; BF12: FF FF FF... ...
 EQUB &FF, &FF, &FF, &FF, &FF, &FF, &FF, &FF, &FF ; BF1B: FF FF FF... ...
 EQUB &FF, &FF, &FF, &FF, &FF, &FF, &FF, &FF, &FF ; BF24: FF FF FF... ...
 EQUB &FF, &FF, &FF, &FF, &FF, &FF, &FF, &FF, &FF ; BF2D: FF FF FF... ...
 EQUB &FF, &FF, &FF, &FF, &FF, &FF, &FF, &FF, &FF ; BF36: FF FF FF... ...
 EQUB &FF, &FF, &FF, &FF, &FF, &FF, &FF, &FF, &FF ; BF3F: FF FF FF... ...
 EQUB &FF, &FF, &FF, &FF, &FF, &FF, &FF, &FF, &FF ; BF48: FF FF FF... ...
 EQUB &FF, &FF, &FF, &FF, &FF, &FF, &FF, &FF, &FF ; BF51: FF FF FF... ...
 EQUB &FF, &FF, &FF, &FF, &FF, &FF, &FF, &FF, &FF ; BF5A: FF FF FF... ...
 EQUB &FF, &FF, &FF, &FF, &FF, &FF, &FF, &FF, &FF ; BF63: FF FF FF... ...
 EQUB &FF, &FF, &FF, &FF, &FF, &FF, &FF, &FF, &FF ; BF6C: FF FF FF... ...
 EQUB &FF, &FF, &FF, &FF, &FF, &FF, &FF, &FF, &FF ; BF75: FF FF FF... ...
 EQUB &FF, &FF, &FF, &FF, &FF, &FF, &FF, &FF, &FF ; BF7E: FF FF FF... ...
 EQUB &FF, &FF, &FF, &FF, &FF, &FF, &FF, &FF, &FF ; BF87: FF FF FF... ...
 EQUB &FF, &FF, &FF, &FF, &FF, &FF, &FF, &FF, &FF ; BF90: FF FF FF... ...
 EQUB &FF, &FF, &FF, &FF, &FF, &FF, &FF, &FF, &FF ; BF99: FF FF FF... ...
 EQUB &FF, &FF, &FF, &FF, &FF, &FF, &FF, &FF, &FF ; BFA2: FF FF FF... ...
 EQUB &FF, &FF, &FF, &FF, &FF, &FF, &FF, &FF, &FF ; BFAB: FF FF FF... ...
 EQUB &FF, &FF, &FF, &FF, &FF, &FF, &FF, &FF, &FF ; BFB4: FF FF FF... ...
 EQUB &FF, &FF, &FF, &FF, &FF, &FF, &FF, &FF, &FF ; BFBD: FF FF FF... ...
 EQUB &FF, &FF, &FF, &FF, &FF, &FF, &FF, &FF, &FF ; BFC6: FF FF FF... ...
 EQUB &FF, &FF, &FF, &FF, &FF, &FF, &FF, &FF, &FF ; BFCF: FF FF FF... ...
 EQUB &FF, &FF, &FF, &FF, &FF, &FF, &FF, &FF, &FF ; BFD8: FF FF FF... ...
 EQUB &FF, &FF, &FF, &FF, &FF, &FF, &FF, &FF, &FF ; BFE1: FF FF FF... ...
 EQUB &FF, &FF, &FF, &FF, &FF, &FF, &FF, &FF, &FF ; BFEA: FF FF FF... ...
 EQUB &FF, &FF, &FF, &FF, &FF, &FF, &FF,   7, &C0 ; BFF3: FF FF FF... ...
 EQUB   0, &C0,   7, &C0                          ; BFFC: 00 C0 07... ...
.pydis_end

\ ******************************************************************************
\
\ Save bank2.bin
\
\ ******************************************************************************

 PRINT "S.bank2.bin ", ~CODE%, " ", ~P%, " ", ~LOAD%, " ", ~LOAD%
 SAVE "3-assembled-output/bank2.bin", CODE%, P%, LOAD%
