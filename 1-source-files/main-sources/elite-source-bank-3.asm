; ******************************************************************************
;
; NES ELITE GAME SOURCE (BANK 3)
;
; NES Elite was written by Ian Bell and David Braben and is copyright D. Braben
; and I. Bell 1992
;
; The code on this site has been reconstructed from a disassembly of the version
; released on Ian Bell's personal website at http://www.elitehomepage.org/
;
; The commentary is copyright Mark Moxon, and any misunderstandings or mistakes
; in the documentation are entirely my fault
;
; The terminology and notations used in this commentary are explained at
; https://www.bbcelite.com/about_site/terminology_used_in_this_commentary.html
;
; The deep dive articles referred to in this commentary can be found at
; https://www.bbcelite.com/deep_dives
;
; ------------------------------------------------------------------------------
;
; This source file produces the following binary file:
;
;   * bank3.bin
;
; ******************************************************************************

 INCLUDE "1-source-files/main-sources/elite-build-options.asm"

 _BANK = 3

 INCLUDE "1-source-files/main-sources/elite-source-common.asm"

 INCLUDE "1-source-files/main-sources/elite-source-bank-7.asm"

; ******************************************************************************
;
; ELITE BANK 1
;
; Produces the binary file bank1.bin.
;
; ******************************************************************************

 CODE% = $8000
 LOAD% = $8000

 ORG CODE%

; ******************************************************************************
;
;       Name: ResetMMC1
;       Type: Variable
;   Category: Start and end
;    Summary: The MMC1 mapper reset routine at the start of the ROM bank
;
; ------------------------------------------------------------------------------
;
; When the NES is switched on, it is hardwired to perform a JMP ($FFFC). At this
; point, there is no guarantee as to which ROM banks are mapped to $8000 and
; $C000, so to ensure that the game starts up correctly, we put the same code
; in each ROM at the following locations:
;
;   * We put $C000 in address $FFFC in every ROM bank, so the NES always jumps
;     to $C000 when it starts up via the JMP ($FFFC), irrespective of which
;     ROM bank is mapped to $C000.
;
;   * We put the same reset routine at the start of every ROM bank, so the same
;     routine gets run, whichever ROM bank is mapped to $C000.
;
; This reset routine is therefore called when the NES starts up, whatever the
; bank configuration ends up being. It then switches ROM bank 7 to $C000 and
; jumps into bank 7 at the game's entry point S%, which starts the game.
;
; ******************************************************************************

.ResetMMC1

 SEI                    ; Disable interrupts

 INC $C006              ; Reset the MMC1 mapper, which we can do by writing a
                        ; value with bit 7 set into any address in ROM space
                        ; (i.e. any address from $8000 to $FFFF)
                        ;
                        ; The INC instruction does this in a more efficient
                        ; manner than an LDA/STA pair, as it:
                        ;
                        ;   * Fetches the contents of address $C006, which
                        ;     contains the high byte of the JMP destination
                        ;     below, i.e. the high byte of S%, which is $C0
                        ;
                        ;   * Adds 1, to give $C1
                        ;
                        ;   * Writes the value $C1 back to address $C006
                        ;
                        ; $C006 is in the ROM space and $C1 has bit 7 set, so
                        ; the INC does all that is required to reset the mapper,
                        ; in fewer cycles and bytes than an LDA/STA pair
                        ;
                        ; Resetting MMC1 maps bank 7 to $C000 and enables the
                        ; bank at $8000 to be switched, so this instruction
                        ; ensures that bank 7 is present

 JMP S%                 ; Jump to S% in bank 7 to start the game

; ******************************************************************************
;
;       Name: Interrupts
;       Type: Subroutine
;   Category: Text
;    Summary: The IRQ and NMI handler while the MMC1 mapper reset routine is
;             still running
;
; ******************************************************************************

.Interrupts

 RTI                    ; Return from the IRQ interrupt without doing anything
                        ;
                        ; This ensures that while the system is starting up and
                        ; the ROM banks are in an unknown configuration, any IRQ
                        ; interrupts that go via the vector at $FFFE and any NMI
                        ; interrupts that go via the vector at $FFFA will end up
                        ; here and be dealt with
                        ;
                        ; Once bank 7 is switched into $C000 by the ResetMMC1
                        ; routine, the vector is overwritten with the last two
                        ; bytes of bank 7, which point to the IRQ routine

; ******************************************************************************
;
;       Name: Version number
;       Type: Variable
;   Category: Text
;    Summary: The game's version number
;
; ******************************************************************************

 EQUS " 5.0"

; ******************************************************************************
;
;       Name: L800C
;       Type: Variable
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

 EQUS "  NES ELITE IM"   ; 800C: 20 20 4E...   N
 EQUS "AGE 5.2  -   2"   ; 801A: 41 47 45... AGE
 EQUS "4 APR 1992  (C"   ; 8028: 34 20 41... 4 A
 EQUS ") D.Braben & I"   ; 8036: 29 20 44... ) D
 EQUS ".Bell 1991/92 "   ; 8044: 2E 42 65... .Be
 EQUS " "                ; 8052: 20
 EQUB $FF, $FF, $FF, $FF ; 8053: FF FF FF... ...
 EQUB $FF, $FF, $FF, $FF ; 8057: FF FF FF... ...
 EQUB $FF, $FF, $FF, $FF ; 805B: FF FF FF... ...
 EQUB $FF, $FF, $FF, $FF ; 805F: FF FF FF... ...
 EQUB $FF, $FF, $FF, $FF ; 8063: FF FF FF... ...
 EQUB $FF, $FF, $FF, $FF ; 8067: FF FF FF... ...
 EQUB $FF, $FF, $FF, $FF ; 806B: FF FF FF... ...
 EQUB $FF, $FF, $FF, $FF ; 806F: FF FF FF... ...
 EQUB $FF, $FF, $FF, $FF ; 8073: FF FF FF... ...
 EQUB $FF, $FF, $FF, $FF ; 8077: FF FF FF... ...
 EQUB $FF, $FF, $FF, $FF ; 807B: FF FF FF... ...
 EQUB $FF, $FF, $FF, $FF ; 807F: FF FF FF... ...
 EQUB $FF, $FF, $FF, $FF ; 8083: FF FF FF... ...
 EQUB $FF, $FF, $FF, $FF ; 8087: FF FF FF... ...
 EQUB $FF, $FF, $FF, $FF ; 808B: FF FF FF... ...
 EQUB $FF, $FF, $FF, $FF ; 808F: FF FF FF... ...
 EQUB $FF, $FF, $FF, $FF ; 8093: FF FF FF... ...
 EQUB $FF, $FF, $FF, $FF ; 8097: FF FF FF... ...
 EQUB $FF, $FF, $FF, $FF ; 809B: FF FF FF... ...
 EQUB $FF, $FF, $FF, $FF ; 809F: FF FF FF... ...
 EQUB $FF, $FF, $FF, $FF ; 80A3: FF FF FF... ...
 EQUB $FF, $FF, $FF, $FF ; 80A7: FF FF FF... ...
 EQUB $FF, $FF, $FF, $FF ; 80AB: FF FF FF... ...
 EQUB $FF, $FF, $FF, $FF ; 80AF: FF FF FF... ...
 EQUB $FF, $FF, $FF, $FF ; 80B3: FF FF FF... ...
 EQUB $FF, $FF, $FF, $FF ; 80B7: FF FF FF... ...
 EQUB $FF, $FF, $FF, $FF ; 80BB: FF FF FF... ...
 EQUB $FF, $FF, $FF, $FF ; 80BF: FF FF FF... ...
 EQUB $FF, $FF, $FF, $FF ; 80C3: FF FF FF... ...
 EQUB $FF, $FF, $FF, $FF ; 80C7: FF FF FF... ...
 EQUB $FF, $FF, $FF, $FF ; 80CB: FF FF FF... ...
 EQUB $FF, $FF, $FF, $FF ; 80CF: FF FF FF... ...
 EQUB $FF, $FF, $FF, $FF ; 80D3: FF FF FF... ...
 EQUB $FF, $FF, $FF, $FF ; 80D7: FF FF FF... ...
 EQUB $FF, $FF, $FF, $FF ; 80DB: FF FF FF... ...
 EQUB $FF, $FF, $FF, $FF ; 80DF: FF FF FF... ...
 EQUB $FF, $FF, $FF, $FF ; 80E3: FF FF FF... ...
 EQUB $FF, $FF, $FF, $FF ; 80E7: FF FF FF... ...
 EQUB $FF, $FF, $FF, $FF ; 80EB: FF FF FF... ...
 EQUB $FF, $FF, $FF, $FF ; 80EF: FF FF FF... ...
 EQUB $FF, $FF, $FF, $FF ; 80F3: FF FF FF... ...
 EQUB $FF, $FF, $FF, $FF ; 80F7: FF FF FF... ...
 EQUB $FF, $FF, $FF, $FF ; 80FB: FF FF FF... ...
 EQUB $FF                ; 80FF: FF          .

; ******************************************************************************
;
;       Name: tile3_0
;       Type: Variable
;   Category: Drawing images
;    Summary: ???
;
; ******************************************************************************

.tile3_0

 EQUB %00000000          ; 8100: 00          .
 EQUB %00000000          ; 8101: 00          .
 EQUB %00000000          ; 8102: 00          .
 EQUB %00000000          ; 8103: 00          .
 EQUB %00000000          ; 8104: 00          .
 EQUB %00000000          ; 8105: 00          .
 EQUB %00000000          ; 8106: 00          .
 EQUB %00000000          ; 8107: 00          .
 EQUB %11111110          ; 8108: FE          .
 EQUB %11111111          ; 8109: FF          .
 EQUB %11111111          ; 810A: FF          .
 EQUB %11111111          ; 810B: FF          .
 EQUB %11111111          ; 810C: FF          .
 EQUB %11111111          ; 810D: FF          .
 EQUB %11111111          ; 810E: FF          .
 EQUB %11111111          ; 810F: FF          .

; ******************************************************************************
;
;       Name: tile3_1
;       Type: Variable
;   Category: Drawing images
;    Summary: ???
;
; ******************************************************************************

.tile3_1

 EQUB %00000000          ; 8110: 00          .
 EQUB %00000000          ; 8111: 00          .
 EQUB %00000000          ; 8112: 00          .
 EQUB %00000000          ; 8113: 00          .
 EQUB %00000000          ; 8114: 00          .
 EQUB %00000000          ; 8115: 00          .
 EQUB %00000000          ; 8116: 00          .
 EQUB %00000000          ; 8117: 00          .
 EQUB %00000000          ; 8118: 00          .
 EQUB %00000001          ; 8119: 01          .
 EQUB %00000001          ; 811A: 01          .
 EQUB %01111101          ; 811B: 7D          }
 EQUB %01111101          ; 811C: 7D          }
 EQUB %10111011          ; 811D: BB          .
 EQUB %10111011          ; 811E: BB          .
 EQUB %10111011          ; 811F: BB          .

; ******************************************************************************
;
;       Name: tile3_2
;       Type: Variable
;   Category: Drawing images
;    Summary: ???
;
; ******************************************************************************

.tile3_2

 EQUB %00000000          ; 8120: 00          .
 EQUB %00000000          ; 8121: 00          .
 EQUB %00000000          ; 8122: 00          .
 EQUB %00000000          ; 8123: 00          .
 EQUB %00000000          ; 8124: 00          .
 EQUB %00000000          ; 8125: 00          .
 EQUB %00000000          ; 8126: 00          .
 EQUB %00000000          ; 8127: 00          .
 EQUB %11111111          ; 8128: FF          .
 EQUB %11111111          ; 8129: FF          .
 EQUB %11111111          ; 812A: FF          .
 EQUB %11111111          ; 812B: FF          .
 EQUB %11111111          ; 812C: FF          .
 EQUB %11111111          ; 812D: FF          .
 EQUB %11111111          ; 812E: FF          .
 EQUB %11111111          ; 812F: FF          .

; ******************************************************************************
;
;       Name: tile3_3
;       Type: Variable
;   Category: Drawing images
;    Summary: ???
;
; ******************************************************************************

.tile3_3

 EQUB %00000000          ; 8130: 00          .
 EQUB %00000000          ; 8131: 00          .
 EQUB %00000000          ; 8132: 00          .
 EQUB %00000000          ; 8133: 00          .
 EQUB %00000000          ; 8134: 00          .
 EQUB %00000000          ; 8135: 00          .
 EQUB %00000000          ; 8136: 00          .
 EQUB %00000000          ; 8137: 00          .
 EQUB %11100000          ; 8138: E0          .
 EQUB %11110000          ; 8139: F0          .
 EQUB %11110000          ; 813A: F0          .
 EQUB %11110111          ; 813B: F7          .
 EQUB %11110111          ; 813C: F7          .
 EQUB %11111011          ; 813D: FB          .
 EQUB %11111011          ; 813E: FB          .
 EQUB %11111011          ; 813F: FB          .

; ******************************************************************************
;
;       Name: tile3_4
;       Type: Variable
;   Category: Drawing images
;    Summary: ???
;
; ******************************************************************************

.tile3_4

 EQUB %00000000          ; 8140: 00          .
 EQUB %00000000          ; 8141: 00          .
 EQUB %00000000          ; 8142: 00          .
 EQUB %00000000          ; 8143: 00          .
 EQUB %00000000          ; 8144: 00          .
 EQUB %00000000          ; 8145: 00          .
 EQUB %00000000          ; 8146: 00          .
 EQUB %00000000          ; 8147: 00          .
 EQUB %00000011          ; 8148: 03          .
 EQUB %00000011          ; 8149: 03          .
 EQUB %00000011          ; 814A: 03          .
 EQUB %00000011          ; 814B: 03          .
 EQUB %00000011          ; 814C: 03          .
 EQUB %00000011          ; 814D: 03          .
 EQUB %00000111          ; 814E: 07          .
 EQUB %00000111          ; 814F: 07          .

; ******************************************************************************
;
;       Name: tile3_5
;       Type: Variable
;   Category: Drawing images
;    Summary: ???
;
; ******************************************************************************

.tile3_5

 EQUB %00000000          ; 8150: 00          .
 EQUB %00000000          ; 8151: 00          .
 EQUB %00000000          ; 8152: 00          .
 EQUB %00000000          ; 8153: 00          .
 EQUB %00000000          ; 8154: 00          .
 EQUB %00000000          ; 8155: 00          .
 EQUB %00000000          ; 8156: 00          .
 EQUB %00000000          ; 8157: 00          .
 EQUB %11000000          ; 8158: C0          .
 EQUB %11000000          ; 8159: C0          .
 EQUB %11000000          ; 815A: C0          .
 EQUB %11000000          ; 815B: C0          .
 EQUB %11000000          ; 815C: C0          .
 EQUB %11000000          ; 815D: C0          .
 EQUB %11100000          ; 815E: E0          .
 EQUB %11100000          ; 815F: E0          .

; ******************************************************************************
;
;       Name: tile3_6
;       Type: Variable
;   Category: Drawing images
;    Summary: ???
;
; ******************************************************************************

.tile3_6

 EQUB %00000000          ; 8160: 00          .
 EQUB %00000000          ; 8161: 00          .
 EQUB %00000000          ; 8162: 00          .
 EQUB %00000000          ; 8163: 00          .
 EQUB %00000010          ; 8164: 02          .
 EQUB %00000110          ; 8165: 06          .
 EQUB %00001110          ; 8166: 0E          .
 EQUB %00000110          ; 8167: 06          .
 EQUB %00001111          ; 8168: 0F          .
 EQUB %00011111          ; 8169: 1F          .
 EQUB %00011100          ; 816A: 1C          .
 EQUB %11011100          ; 816B: DC          .
 EQUB %11011010          ; 816C: DA          .
 EQUB %10110110          ; 816D: B6          .
 EQUB %10101110          ; 816E: AE          .
 EQUB %10110110          ; 816F: B6          .

; ******************************************************************************
;
;       Name: tile3_7
;       Type: Variable
;   Category: Drawing images
;    Summary: ???
;
; ******************************************************************************

.tile3_7

 EQUB %00000000          ; 8170: 00          .
 EQUB %00000000          ; 8171: 00          .
 EQUB %00000000          ; 8172: 00          .
 EQUB %10000100          ; 8173: 84          .
 EQUB %00100000          ; 8174: 20
 EQUB %01010000          ; 8175: 50          P
 EQUB %10001000          ; 8176: 88          .
 EQUB %01010000          ; 8177: 50          P
 EQUB %11111110          ; 8178: FE          .
 EQUB %11111111          ; 8179: FF          .
 EQUB %00000001          ; 817A: 01          .
 EQUB %00101001          ; 817B: 29          )
 EQUB %01010101          ; 817C: 55          U
 EQUB %10101001          ; 817D: A9          .
 EQUB %00000101          ; 817E: 05          .
 EQUB %10101001          ; 817F: A9          .

; ******************************************************************************
;
;       Name: tile3_8
;       Type: Variable
;   Category: Drawing images
;    Summary: ???
;
; ******************************************************************************

.tile3_8

 EQUB %00000000          ; 8180: 00          .
 EQUB %00000000          ; 8181: 00          .
 EQUB %00000000          ; 8182: 00          .
 EQUB %00000000          ; 8183: 00          .
 EQUB %00000000          ; 8184: 00          .
 EQUB %00000000          ; 8185: 00          .
 EQUB %00000000          ; 8186: 00          .
 EQUB %00000001          ; 8187: 01          .
 EQUB %11111111          ; 8188: FF          .
 EQUB %11110111          ; 8189: F7          .
 EQUB %01100001          ; 818A: 61          a
 EQUB %01010111          ; 818B: 57          W
 EQUB %01000001          ; 818C: 41          A
 EQUB %01110101          ; 818D: 75          u
 EQUB %01000011          ; 818E: 43          C
 EQUB %01110111          ; 818F: 77          w

; ******************************************************************************
;
;       Name: tile3_9
;       Type: Variable
;   Category: Drawing images
;    Summary: ???
;
; ******************************************************************************

.tile3_9

 EQUB %00000000          ; 8190: 00          .
 EQUB %00000000          ; 8191: 00          .
 EQUB %00000000          ; 8192: 00          .
 EQUB %00000000          ; 8193: 00          .
 EQUB %00000000          ; 8194: 00          .
 EQUB %01000000          ; 8195: 40          @
 EQUB %10100000          ; 8196: A0          .
 EQUB %00000000          ; 8197: 00          .
 EQUB %11100000          ; 8198: E0          .
 EQUB %11110000          ; 8199: F0          .
 EQUB %11110000          ; 819A: F0          .
 EQUB %11110111          ; 819B: F7          .
 EQUB %11110111          ; 819C: F7          .
 EQUB %11111011          ; 819D: FB          .
 EQUB %11111011          ; 819E: FB          .
 EQUB %11111011          ; 819F: FB          .

; ******************************************************************************
;
;       Name: tile3_10
;       Type: Variable
;   Category: Drawing images
;    Summary: ???
;
; ******************************************************************************

.tile3_10

 EQUB %00000000          ; 81A0: 00          .
 EQUB %00000000          ; 81A1: 00          .
 EQUB %00001101          ; 81A2: 0D          .
 EQUB %00000000          ; 81A3: 00          .
 EQUB %00000111          ; 81A4: 07          .
 EQUB %00000000          ; 81A5: 00          .
 EQUB %00000000          ; 81A6: 00          .
 EQUB %00000000          ; 81A7: 00          .
 EQUB %00001111          ; 81A8: 0F          .
 EQUB %00011111          ; 81A9: 1F          .
 EQUB %00010010          ; 81AA: 12          .
 EQUB %11011111          ; 81AB: DF          .
 EQUB %11011000          ; 81AC: D8          .
 EQUB %10111111          ; 81AD: BF          .
 EQUB %10100101          ; 81AE: A5          .
 EQUB %10101101          ; 81AF: AD          .

; ******************************************************************************
;
;       Name: tile3_11
;       Type: Variable
;   Category: Drawing images
;    Summary: ???
;
; ******************************************************************************

.tile3_11

 EQUB %00000000          ; 81B0: 00          .
 EQUB %00000000          ; 81B1: 00          .
 EQUB %01101010          ; 81B2: 6A          j
 EQUB %00000000          ; 81B3: 00          .
 EQUB %01011000          ; 81B4: 58          X
 EQUB %00000000          ; 81B5: 00          .
 EQUB %00000000          ; 81B6: 00          .
 EQUB %00000000          ; 81B7: 00          .
 EQUB %11111110          ; 81B8: FE          .
 EQUB %11111111          ; 81B9: FF          .
 EQUB %10010101          ; 81BA: 95          .
 EQUB %11111111          ; 81BB: FF          .
 EQUB %10100111          ; 81BC: A7          .
 EQUB %11111111          ; 81BD: FF          .
 EQUB %10100000          ; 81BE: A0          .
 EQUB %10110101          ; 81BF: B5          .

; ******************************************************************************
;
;       Name: tile3_12
;       Type: Variable
;   Category: Drawing images
;    Summary: ???
;
; ******************************************************************************

.tile3_12

 EQUB %00000000          ; 81C0: 00          .
 EQUB %00000000          ; 81C1: 00          .
 EQUB %00011100          ; 81C2: 1C          .
 EQUB %01100011          ; 81C3: 63          c
 EQUB %01000001          ; 81C4: 41          A
 EQUB %10000000          ; 81C5: 80          .
 EQUB %10000000          ; 81C6: 80          .
 EQUB %10000000          ; 81C7: 80          .
 EQUB %11111111          ; 81C8: FF          .
 EQUB %11111111          ; 81C9: FF          .
 EQUB %11111111          ; 81CA: FF          .
 EQUB %11111111          ; 81CB: FF          .
 EQUB %11111111          ; 81CC: FF          .
 EQUB %11110111          ; 81CD: F7          .
 EQUB %11100011          ; 81CE: E3          .
 EQUB %11110111          ; 81CF: F7          .

; ******************************************************************************
;
;       Name: tile3_13
;       Type: Variable
;   Category: Drawing images
;    Summary: ???
;
; ******************************************************************************

.tile3_13

 EQUB %00000000          ; 81D0: 00          .
 EQUB %00000000          ; 81D1: 00          .
 EQUB %00000000          ; 81D2: 00          .
 EQUB %01000000          ; 81D3: 40          @
 EQUB %00000000          ; 81D4: 00          .
 EQUB %10000000          ; 81D5: 80          .
 EQUB %10010000          ; 81D6: 90          .
 EQUB %10000000          ; 81D7: 80          .
 EQUB %11100000          ; 81D8: E0          .
 EQUB %11110000          ; 81D9: F0          .
 EQUB %11110000          ; 81DA: F0          .
 EQUB %10110111          ; 81DB: B7          .
 EQUB %11110111          ; 81DC: F7          .
 EQUB %11111011          ; 81DD: FB          .
 EQUB %11101011          ; 81DE: EB          .
 EQUB %11111011          ; 81DF: FB          .

; ******************************************************************************
;
;       Name: tile3_14
;       Type: Variable
;   Category: Drawing images
;    Summary: ???
;
; ******************************************************************************

.tile3_14

 EQUB %00000000          ; 81E0: 00          .
 EQUB %00000000          ; 81E1: 00          .
 EQUB %00000000          ; 81E2: 00          .
 EQUB %00000000          ; 81E3: 00          .
 EQUB %00000000          ; 81E4: 00          .
 EQUB %00000000          ; 81E5: 00          .
 EQUB %00000111          ; 81E6: 07          .
 EQUB %00000000          ; 81E7: 00          .
 EQUB %00001111          ; 81E8: 0F          .
 EQUB %00011111          ; 81E9: 1F          .
 EQUB %00011111          ; 81EA: 1F          .
 EQUB %11011111          ; 81EB: DF          .
 EQUB %11011111          ; 81EC: DF          .
 EQUB %10110000          ; 81ED: B0          .
 EQUB %10110111          ; 81EE: B7          .
 EQUB %10110000          ; 81EF: B0          .

; ******************************************************************************
;
;       Name: tile3_15
;       Type: Variable
;   Category: Drawing images
;    Summary: ???
;
; ******************************************************************************

.tile3_15

 EQUB %00000000          ; 81F0: 00          .
 EQUB %00000000          ; 81F1: 00          .
 EQUB %00000000          ; 81F2: 00          .
 EQUB %00000000          ; 81F3: 00          .
 EQUB %00011100          ; 81F4: 1C          .
 EQUB %00100000          ; 81F5: 20
 EQUB %11100000          ; 81F6: E0          .
 EQUB %00100000          ; 81F7: 20
 EQUB %11111110          ; 81F8: FE          .
 EQUB %11111111          ; 81F9: FF          .
 EQUB %11111111          ; 81FA: FF          .
 EQUB %11100011          ; 81FB: E3          .
 EQUB %11011101          ; 81FC: DD          .
 EQUB %00100001          ; 81FD: 21          !
 EQUB %11101111          ; 81FE: EF          .
 EQUB %00100001          ; 81FF: 21          !

; ******************************************************************************
;
;       Name: tile3_16
;       Type: Variable
;   Category: Drawing images
;    Summary: ???
;
; ******************************************************************************

.tile3_16

 EQUB %00000000          ; 8200: 00          .
 EQUB %00000000          ; 8201: 00          .
 EQUB %00001111          ; 8202: 0F          .
 EQUB %00000000          ; 8203: 00          .
 EQUB %00111111          ; 8204: 3F          ?
 EQUB %00000001          ; 8205: 01          .
 EQUB %01111101          ; 8206: 7D          }
 EQUB %01000100          ; 8207: 44          D
 EQUB %11111111          ; 8208: FF          .
 EQUB %11110000          ; 8209: F0          .
 EQUB %11100000          ; 820A: E0          .
 EQUB %11100000          ; 820B: E0          .
 EQUB %11111111          ; 820C: FF          .
 EQUB %00000001          ; 820D: 01          .
 EQUB %00000001          ; 820E: 01          .
 EQUB %00000000          ; 820F: 00          .

; ******************************************************************************
;
;       Name: tile3_17
;       Type: Variable
;   Category: Drawing images
;    Summary: ???
;
; ******************************************************************************

.tile3_17

 EQUB %00000000          ; 8210: 00          .
 EQUB %00000000          ; 8211: 00          .
 EQUB %10000000          ; 8212: 80          .
 EQUB %01000000          ; 8213: 40          @
 EQUB %01000000          ; 8214: 40          @
 EQUB %01000000          ; 8215: 40          @
 EQUB %01000000          ; 8216: 40          @
 EQUB %01000000          ; 8217: 40          @
 EQUB %11100000          ; 8218: E0          .
 EQUB %00010000          ; 8219: 10          .
 EQUB %00010000          ; 821A: 10          .
 EQUB %00010111          ; 821B: 17          .
 EQUB %00010111          ; 821C: 17          .
 EQUB %00011011          ; 821D: 1B          .
 EQUB %00011011          ; 821E: 1B          .
 EQUB %00011011          ; 821F: 1B          .

; ******************************************************************************
;
;       Name: tile3_18
;       Type: Variable
;   Category: Drawing images
;    Summary: ???
;
; ******************************************************************************

.tile3_18

 EQUB %00000000          ; 8220: 00          .
 EQUB %00000000          ; 8221: 00          .
 EQUB %00000000          ; 8222: 00          .
 EQUB %00000000          ; 8223: 00          .
 EQUB %00000000          ; 8224: 00          .
 EQUB %00000000          ; 8225: 00          .
 EQUB %00000000          ; 8226: 00          .
 EQUB %00000000          ; 8227: 00          .
 EQUB %00001111          ; 8228: 0F          .
 EQUB %00011111          ; 8229: 1F          .
 EQUB %00011111          ; 822A: 1F          .
 EQUB %11010001          ; 822B: D1          .
 EQUB %11010101          ; 822C: D5          .
 EQUB %10110001          ; 822D: B1          .
 EQUB %10110101          ; 822E: B5          .
 EQUB %10110101          ; 822F: B5          .

; ******************************************************************************
;
;       Name: tile3_19
;       Type: Variable
;   Category: Drawing images
;    Summary: ???
;
; ******************************************************************************

.tile3_19

 EQUB %00000000          ; 8230: 00          .
 EQUB %00000000          ; 8231: 00          .
 EQUB %00000000          ; 8232: 00          .
 EQUB %00001110          ; 8233: 0E          .
 EQUB %00001010          ; 8234: 0A          .
 EQUB %00001110          ; 8235: 0E          .
 EQUB %00001010          ; 8236: 0A          .
 EQUB %00001010          ; 8237: 0A          .
 EQUB %11111110          ; 8238: FE          .
 EQUB %11111111          ; 8239: FF          .
 EQUB %11111111          ; 823A: FF          .
 EQUB %00010001          ; 823B: 11          .
 EQUB %01010101          ; 823C: 55          U
 EQUB %00010001          ; 823D: 11          .
 EQUB %01010101          ; 823E: 55          U
 EQUB %01010101          ; 823F: 55          U

; ******************************************************************************
;
;       Name: tile3_20
;       Type: Variable
;   Category: Drawing images
;    Summary: ???
;
; ******************************************************************************

.tile3_20

 EQUB %00000000          ; 8240: 00          .
 EQUB %00000000          ; 8241: 00          .
 EQUB %00000000          ; 8242: 00          .
 EQUB %01101100          ; 8243: 6C          l
 EQUB %00000000          ; 8244: 00          .
 EQUB %01011101          ; 8245: 5D          ]
 EQUB %00000000          ; 8246: 00          .
 EQUB %11101100          ; 8247: EC          .
 EQUB %11111111          ; 8248: FF          .
 EQUB %11111111          ; 8249: FF          .
 EQUB %11111111          ; 824A: FF          .
 EQUB %10010010          ; 824B: 92          .
 EQUB %11111110          ; 824C: FE          .
 EQUB %10100011          ; 824D: A3          .
 EQUB %11111110          ; 824E: FE          .
 EQUB %00010010          ; 824F: 12          .

; ******************************************************************************
;
;       Name: tile3_21
;       Type: Variable
;   Category: Drawing images
;    Summary: ???
;
; ******************************************************************************

.tile3_21

 EQUB %00000000          ; 8250: 00          .
 EQUB %00000000          ; 8251: 00          .
 EQUB %00000000          ; 8252: 00          .
 EQUB %00000000          ; 8253: 00          .
 EQUB %11000000          ; 8254: C0          .
 EQUB %11100000          ; 8255: E0          .
 EQUB %11000000          ; 8256: C0          .
 EQUB %00000000          ; 8257: 00          .
 EQUB %11100000          ; 8258: E0          .
 EQUB %11110000          ; 8259: F0          .
 EQUB %11110000          ; 825A: F0          .
 EQUB %00010111          ; 825B: 17          .
 EQUB %11010111          ; 825C: D7          .
 EQUB %11111011          ; 825D: FB          .
 EQUB %11011011          ; 825E: DB          .
 EQUB %00011011          ; 825F: 1B          .

; ******************************************************************************
;
;       Name: tile3_22
;       Type: Variable
;   Category: Drawing images
;    Summary: ???
;
; ******************************************************************************

.tile3_22

 EQUB %00000000          ; 8260: 00          .
 EQUB %00000000          ; 8261: 00          .
 EQUB %00000000          ; 8262: 00          .
 EQUB %00000001          ; 8263: 01          .
 EQUB %00000010          ; 8264: 02          .
 EQUB %00000010          ; 8265: 02          .
 EQUB %00000010          ; 8266: 02          .
 EQUB %00000010          ; 8267: 02          .
 EQUB %00001111          ; 8268: 0F          .
 EQUB %00011111          ; 8269: 1F          .
 EQUB %00011100          ; 826A: 1C          .
 EQUB %11011001          ; 826B: D9          .
 EQUB %11011010          ; 826C: DA          .
 EQUB %10111010          ; 826D: BA          .
 EQUB %10111010          ; 826E: BA          .
 EQUB %10111010          ; 826F: BA          .

; ******************************************************************************
;
;       Name: tile3_23
;       Type: Variable
;   Category: Drawing images
;    Summary: ???
;
; ******************************************************************************

.tile3_23

 EQUB %00000000          ; 8270: 00          .
 EQUB %00000000          ; 8271: 00          .
 EQUB %11000000          ; 8272: C0          .
 EQUB %11100000          ; 8273: E0          .
 EQUB %11010000          ; 8274: D0          .
 EQUB %00010000          ; 8275: 10          .
 EQUB %11010000          ; 8276: D0          .
 EQUB %11010000          ; 8277: D0          .
 EQUB %11111110          ; 8278: FE          .
 EQUB %00111111          ; 8279: 3F          ?
 EQUB %11001111          ; 827A: CF          .
 EQUB %11100111          ; 827B: E7          .
 EQUB %11000111          ; 827C: C7          .
 EQUB %00000111          ; 827D: 07          .
 EQUB %00000111          ; 827E: 07          .
 EQUB %00000111          ; 827F: 07          .

; ******************************************************************************
;
;       Name: tile3_24
;       Type: Variable
;   Category: Drawing images
;    Summary: ???
;
; ******************************************************************************

.tile3_24

 EQUB %00000000          ; 8280: 00          .
 EQUB %00000000          ; 8281: 00          .
 EQUB %00000000          ; 8282: 00          .
 EQUB %00000000          ; 8283: 00          .
 EQUB %00000000          ; 8284: 00          .
 EQUB %00000000          ; 8285: 00          .
 EQUB %00000000          ; 8286: 00          .
 EQUB %00000000          ; 8287: 00          .
 EQUB %00000000          ; 8288: 00          .
 EQUB %00000000          ; 8289: 00          .
 EQUB %00000000          ; 828A: 00          .
 EQUB %00000000          ; 828B: 00          .
 EQUB %00000000          ; 828C: 00          .
 EQUB %00000000          ; 828D: 00          .
 EQUB %00000000          ; 828E: 00          .
 EQUB %00000000          ; 828F: 00          .

; ******************************************************************************
;
;       Name: tile3_25
;       Type: Variable
;   Category: Drawing images
;    Summary: ???
;
; ******************************************************************************

.tile3_25

 EQUB %00000000          ; 8290: 00          .
 EQUB %00000000          ; 8291: 00          .
 EQUB %00000000          ; 8292: 00          .
 EQUB %00000000          ; 8293: 00          .
 EQUB %00000000          ; 8294: 00          .
 EQUB %00000000          ; 8295: 00          .
 EQUB %00000000          ; 8296: 00          .
 EQUB %00000000          ; 8297: 00          .
 EQUB %00000000          ; 8298: 00          .
 EQUB %00000000          ; 8299: 00          .
 EQUB %00000000          ; 829A: 00          .
 EQUB %00000000          ; 829B: 00          .
 EQUB %00000000          ; 829C: 00          .
 EQUB %00000000          ; 829D: 00          .
 EQUB %00000000          ; 829E: 00          .
 EQUB %00000000          ; 829F: 00          .

; ******************************************************************************
;
;       Name: tile3_26
;       Type: Variable
;   Category: Drawing images
;    Summary: ???
;
; ******************************************************************************

.tile3_26

 EQUB %00000000          ; 82A0: 00          .
 EQUB %00000000          ; 82A1: 00          .
 EQUB %00000000          ; 82A2: 00          .
 EQUB %00000000          ; 82A3: 00          .
 EQUB %00000000          ; 82A4: 00          .
 EQUB %00000000          ; 82A5: 00          .
 EQUB %00000000          ; 82A6: 00          .
 EQUB %00000000          ; 82A7: 00          .
 EQUB %00000000          ; 82A8: 00          .
 EQUB %00000000          ; 82A9: 00          .
 EQUB %00000000          ; 82AA: 00          .
 EQUB %00000000          ; 82AB: 00          .
 EQUB %00000000          ; 82AC: 00          .
 EQUB %00000000          ; 82AD: 00          .
 EQUB %00000000          ; 82AE: 00          .
 EQUB %00000000          ; 82AF: 00          .

; ******************************************************************************
;
;       Name: tile3_27
;       Type: Variable
;   Category: Drawing images
;    Summary: ???
;
; ******************************************************************************

.tile3_27

 EQUB %00000000          ; 82B0: 00          .
 EQUB %00000000          ; 82B1: 00          .
 EQUB %00000000          ; 82B2: 00          .
 EQUB %00000000          ; 82B3: 00          .
 EQUB %00000000          ; 82B4: 00          .
 EQUB %00000000          ; 82B5: 00          .
 EQUB %00000000          ; 82B6: 00          .
 EQUB %00000000          ; 82B7: 00          .
 EQUB %00000000          ; 82B8: 00          .
 EQUB %00000000          ; 82B9: 00          .
 EQUB %00000000          ; 82BA: 00          .
 EQUB %00000000          ; 82BB: 00          .
 EQUB %00000000          ; 82BC: 00          .
 EQUB %00000000          ; 82BD: 00          .
 EQUB %00000000          ; 82BE: 00          .
 EQUB %00000000          ; 82BF: 00          .

; ******************************************************************************
;
;       Name: tile3_28
;       Type: Variable
;   Category: Drawing images
;    Summary: ???
;
; ******************************************************************************

.tile3_28

 EQUB %00000000          ; 82C0: 00          .
 EQUB %00000000          ; 82C1: 00          .
 EQUB %00000000          ; 82C2: 00          .
 EQUB %00000000          ; 82C3: 00          .
 EQUB %00000000          ; 82C4: 00          .
 EQUB %00000000          ; 82C5: 00          .
 EQUB %00000000          ; 82C6: 00          .
 EQUB %00000000          ; 82C7: 00          .
 EQUB %00000000          ; 82C8: 00          .
 EQUB %00000000          ; 82C9: 00          .
 EQUB %00000000          ; 82CA: 00          .
 EQUB %00000000          ; 82CB: 00          .
 EQUB %00000000          ; 82CC: 00          .
 EQUB %00000000          ; 82CD: 00          .
 EQUB %00000000          ; 82CE: 00          .
 EQUB %00000000          ; 82CF: 00          .

; ******************************************************************************
;
;       Name: tile3_29
;       Type: Variable
;   Category: Drawing images
;    Summary: ???
;
; ******************************************************************************

.tile3_29

 EQUB %00000000          ; 82D0: 00          .
 EQUB %00000000          ; 82D1: 00          .
 EQUB %00000000          ; 82D2: 00          .
 EQUB %00000000          ; 82D3: 00          .
 EQUB %00000000          ; 82D4: 00          .
 EQUB %00000000          ; 82D5: 00          .
 EQUB %00000000          ; 82D6: 00          .
 EQUB %00000000          ; 82D7: 00          .
 EQUB %00000000          ; 82D8: 00          .
 EQUB %00000000          ; 82D9: 00          .
 EQUB %00000000          ; 82DA: 00          .
 EQUB %00000000          ; 82DB: 00          .
 EQUB %00000000          ; 82DC: 00          .
 EQUB %00000000          ; 82DD: 00          .
 EQUB %00000000          ; 82DE: 00          .
 EQUB %00000000          ; 82DF: 00          .

; ******************************************************************************
;
;       Name: tile3_30
;       Type: Variable
;   Category: Drawing images
;    Summary: ???
;
; ******************************************************************************

.tile3_30

 EQUB %00000000          ; 82E0: 00          .
 EQUB %00000000          ; 82E1: 00          .
 EQUB %00000000          ; 82E2: 00          .
 EQUB %00000000          ; 82E3: 00          .
 EQUB %00000000          ; 82E4: 00          .
 EQUB %00000000          ; 82E5: 00          .
 EQUB %00000000          ; 82E6: 00          .
 EQUB %00000000          ; 82E7: 00          .
 EQUB %00000000          ; 82E8: 00          .
 EQUB %00000000          ; 82E9: 00          .
 EQUB %00000000          ; 82EA: 00          .
 EQUB %00000000          ; 82EB: 00          .
 EQUB %00000000          ; 82EC: 00          .
 EQUB %00000000          ; 82ED: 00          .
 EQUB %00000000          ; 82EE: 00          .
 EQUB %00000000          ; 82EF: 00          .

; ******************************************************************************
;
;       Name: tile3_31
;       Type: Variable
;   Category: Drawing images
;    Summary: ???
;
; ******************************************************************************

.tile3_31

 EQUB %00000000          ; 82F0: 00          .
 EQUB %00000000          ; 82F1: 00          .
 EQUB %00000000          ; 82F2: 00          .
 EQUB %00100000          ; 82F3: 20
 EQUB %00011111          ; 82F4: 1F          .
 EQUB %00000000          ; 82F5: 00          .
 EQUB %00100000          ; 82F6: 20
 EQUB %00000000          ; 82F7: 00          .
 EQUB %00111111          ; 82F8: 3F          ?
 EQUB %00111111          ; 82F9: 3F          ?
 EQUB %00111111          ; 82FA: 3F          ?
 EQUB %00011111          ; 82FB: 1F          .
 EQUB %00100000          ; 82FC: 20
 EQUB %00000000          ; 82FD: 00          .
 EQUB %01011111          ; 82FE: 5F          _
 EQUB %01000000          ; 82FF: 40          @

; ******************************************************************************
;
;       Name: tile3_32
;       Type: Variable
;   Category: Drawing images
;    Summary: ???
;
; ******************************************************************************

.tile3_32

 EQUB %00000000          ; 8300: 00          .
 EQUB %00000000          ; 8301: 00          .
 EQUB %00000000          ; 8302: 00          .
 EQUB %00000000          ; 8303: 00          .
 EQUB %11111111          ; 8304: FF          .
 EQUB %00000000          ; 8305: 00          .
 EQUB %00000000          ; 8306: 00          .
 EQUB %00000000          ; 8307: 00          .
 EQUB %11111111          ; 8308: FF          .
 EQUB %11111111          ; 8309: FF          .
 EQUB %11111111          ; 830A: FF          .
 EQUB %11111111          ; 830B: FF          .
 EQUB %00000000          ; 830C: 00          .
 EQUB %00000000          ; 830D: 00          .
 EQUB %11111111          ; 830E: FF          .
 EQUB %00000000          ; 830F: 00          .

; ******************************************************************************
;
;       Name: tile3_33
;       Type: Variable
;   Category: Drawing images
;    Summary: ???
;
; ******************************************************************************

.tile3_33

 EQUB %00000000          ; 8310: 00          .
 EQUB %00000000          ; 8311: 00          .
 EQUB %00000000          ; 8312: 00          .
 EQUB %10000010          ; 8313: 82          .
 EQUB %00000001          ; 8314: 01          .
 EQUB %00010000          ; 8315: 10          .
 EQUB %10010010          ; 8316: 92          .
 EQUB %00010000          ; 8317: 10          .
 EQUB %10010011          ; 8318: 93          .
 EQUB %10010011          ; 8319: 93          .
 EQUB %10010011          ; 831A: 93          .
 EQUB %00010001          ; 831B: 11          .
 EQUB %10010010          ; 831C: 92          .
 EQUB %00000000          ; 831D: 00          .
 EQUB %01000101          ; 831E: 45          E
 EQUB %01000100          ; 831F: 44          D

; ******************************************************************************
;
;       Name: tile3_34
;       Type: Variable
;   Category: Drawing images
;    Summary: ???
;
; ******************************************************************************

.tile3_34

 EQUB %00000000          ; 8320: 00          .
 EQUB %00000000          ; 8321: 00          .
 EQUB %00000000          ; 8322: 00          .
 EQUB %00001000          ; 8323: 08          .
 EQUB %11110000          ; 8324: F0          .
 EQUB %00000001          ; 8325: 01          .
 EQUB %00001001          ; 8326: 09          .
 EQUB %00000001          ; 8327: 01          .
 EQUB %11111001          ; 8328: F9          .
 EQUB %11111001          ; 8329: F9          .
 EQUB %11111001          ; 832A: F9          .
 EQUB %11110001          ; 832B: F1          .
 EQUB %00001001          ; 832C: 09          .
 EQUB %00000000          ; 832D: 00          .
 EQUB %11110100          ; 832E: F4          .
 EQUB %00000100          ; 832F: 04          .

; ******************************************************************************
;
;       Name: tile3_35
;       Type: Variable
;   Category: Drawing images
;    Summary: ???
;
; ******************************************************************************

.tile3_35

 EQUB %00000000          ; 8330: 00          .
 EQUB %00000000          ; 8331: 00          .
 EQUB %00000000          ; 8332: 00          .
 EQUB %00000000          ; 8333: 00          .
 EQUB %00000000          ; 8334: 00          .
 EQUB %00000000          ; 8335: 00          .
 EQUB %00000001          ; 8336: 01          .
 EQUB %00001011          ; 8337: 0B          .
 EQUB %00001111          ; 8338: 0F          .
 EQUB %00001111          ; 8339: 0F          .
 EQUB %00011111          ; 833A: 1F          .
 EQUB %00011111          ; 833B: 1F          .
 EQUB %00111111          ; 833C: 3F          ?
 EQUB %00111111          ; 833D: 3F          ?
 EQUB %01111110          ; 833E: 7E          ~
 EQUB %01110100          ; 833F: 74          t

; ******************************************************************************
;
;       Name: tile3_36
;       Type: Variable
;   Category: Drawing images
;    Summary: ???
;
; ******************************************************************************

.tile3_36

 EQUB %00000000          ; 8340: 00          .
 EQUB %00000000          ; 8341: 00          .
 EQUB %00000000          ; 8342: 00          .
 EQUB %00000000          ; 8343: 00          .
 EQUB %00000000          ; 8344: 00          .
 EQUB %00000000          ; 8345: 00          .
 EQUB %10000000          ; 8346: 80          .
 EQUB %11010000          ; 8347: D0          .
 EQUB %11110000          ; 8348: F0          .
 EQUB %11110000          ; 8349: F0          .
 EQUB %11111000          ; 834A: F8          .
 EQUB %11111000          ; 834B: F8          .
 EQUB %11111100          ; 834C: FC          .
 EQUB %11111100          ; 834D: FC          .
 EQUB %01111110          ; 834E: 7E          ~
 EQUB %00101110          ; 834F: 2E          .

; ******************************************************************************
;
;       Name: tile3_37
;       Type: Variable
;   Category: Drawing images
;    Summary: ???
;
; ******************************************************************************

.tile3_37

 EQUB %00000010          ; 8350: 02          .
 EQUB %00000000          ; 8351: 00          .
 EQUB %00000000          ; 8352: 00          .
 EQUB %00100000          ; 8353: 20
 EQUB %00011111          ; 8354: 1F          .
 EQUB %00000000          ; 8355: 00          .
 EQUB %00100000          ; 8356: 20
 EQUB %00000000          ; 8357: 00          .
 EQUB %00111010          ; 8358: 3A          :
 EQUB %00111100          ; 8359: 3C          <
 EQUB %00111100          ; 835A: 3C          <
 EQUB %00011111          ; 835B: 1F          .
 EQUB %00100000          ; 835C: 20
 EQUB %00000000          ; 835D: 00          .
 EQUB %01011111          ; 835E: 5F          _
 EQUB %01000000          ; 835F: 40          @

; ******************************************************************************
;
;       Name: tile3_38
;       Type: Variable
;   Category: Drawing images
;    Summary: ???
;
; ******************************************************************************

.tile3_38

 EQUB %00100000          ; 8360: 20
 EQUB %00000000          ; 8361: 00          .
 EQUB %00000000          ; 8362: 00          .
 EQUB %00000000          ; 8363: 00          .
 EQUB %11111111          ; 8364: FF          .
 EQUB %00000000          ; 8365: 00          .
 EQUB %00000000          ; 8366: 00          .
 EQUB %00000000          ; 8367: 00          .
 EQUB %01010101          ; 8368: 55          U
 EQUB %10101101          ; 8369: AD          .
 EQUB %00000001          ; 836A: 01          .
 EQUB %11111111          ; 836B: FF          .
 EQUB %00000000          ; 836C: 00          .
 EQUB %00000000          ; 836D: 00          .
 EQUB %11111111          ; 836E: FF          .
 EQUB %00000000          ; 836F: 00          .

; ******************************************************************************
;
;       Name: tile3_39
;       Type: Variable
;   Category: Drawing images
;    Summary: ???
;
; ******************************************************************************

.tile3_39

 EQUB %00100010          ; 8370: 22          "
 EQUB %01010100          ; 8371: 54          T
 EQUB %00001000          ; 8372: 08          .
 EQUB %00000000          ; 8373: 00          .
 EQUB %11111111          ; 8374: FF          .
 EQUB %00000000          ; 8375: 00          .
 EQUB %00000000          ; 8376: 00          .
 EQUB %00000000          ; 8377: 00          .
 EQUB %01111111          ; 8378: 7F          .
 EQUB %01111111          ; 8379: 7F          .
 EQUB %00001000          ; 837A: 08          .
 EQUB %11111111          ; 837B: FF          .
 EQUB %00000000          ; 837C: 00          .
 EQUB %00000000          ; 837D: 00          .
 EQUB %11111111          ; 837E: FF          .
 EQUB %00000000          ; 837F: 00          .

; ******************************************************************************
;
;       Name: tile3_40
;       Type: Variable
;   Category: Drawing images
;    Summary: ???
;
; ******************************************************************************

.tile3_40

 EQUB %00000000          ; 8380: 00          .
 EQUB %00000000          ; 8381: 00          .
 EQUB %00000000          ; 8382: 00          .
 EQUB %00001000          ; 8383: 08          .
 EQUB %11110000          ; 8384: F0          .
 EQUB %00000001          ; 8385: 01          .
 EQUB %00001001          ; 8386: 09          .
 EQUB %00000001          ; 8387: 01          .
 EQUB %11111001          ; 8388: F9          .
 EQUB %11111001          ; 8389: F9          .
 EQUB %00011001          ; 838A: 19          .
 EQUB %11110001          ; 838B: F1          .
 EQUB %00001001          ; 838C: 09          .
 EQUB %00000000          ; 838D: 00          .
 EQUB %11110100          ; 838E: F4          .
 EQUB %00000100          ; 838F: 04          .

; ******************************************************************************
;
;       Name: tile3_41
;       Type: Variable
;   Category: Drawing images
;    Summary: ???
;
; ******************************************************************************

.tile3_41

 EQUB %00000000          ; 8390: 00          .
 EQUB %00000000          ; 8391: 00          .
 EQUB %00000000          ; 8392: 00          .
 EQUB %00100000          ; 8393: 20
 EQUB %00011111          ; 8394: 1F          .
 EQUB %00000000          ; 8395: 00          .
 EQUB %00100000          ; 8396: 20
 EQUB %00000000          ; 8397: 00          .
 EQUB %00100101          ; 8398: 25          %
 EQUB %00101101          ; 8399: 2D          -
 EQUB %00100100          ; 839A: 24          $
 EQUB %00011111          ; 839B: 1F          .
 EQUB %00100000          ; 839C: 20
 EQUB %00000000          ; 839D: 00          .
 EQUB %01011111          ; 839E: 5F          _
 EQUB %01000000          ; 839F: 40          @

; ******************************************************************************
;
;       Name: tile3_42
;       Type: Variable
;   Category: Drawing images
;    Summary: ???
;
; ******************************************************************************

.tile3_42

 EQUB %00000000          ; 83A0: 00          .
 EQUB %00000000          ; 83A1: 00          .
 EQUB %00000000          ; 83A2: 00          .
 EQUB %00000000          ; 83A3: 00          .
 EQUB %11111111          ; 83A4: FF          .
 EQUB %00000000          ; 83A5: 00          .
 EQUB %00000000          ; 83A6: 00          .
 EQUB %00000000          ; 83A7: 00          .
 EQUB %10110100          ; 83A8: B4          .
 EQUB %10110101          ; 83A9: B5          .
 EQUB %10110100          ; 83AA: B4          .
 EQUB %11111111          ; 83AB: FF          .
 EQUB %00000000          ; 83AC: 00          .
 EQUB %00000000          ; 83AD: 00          .
 EQUB %11111111          ; 83AE: FF          .
 EQUB %00000000          ; 83AF: 00          .

; ******************************************************************************
;
;       Name: tile3_43
;       Type: Variable
;   Category: Drawing images
;    Summary: ???
;
; ******************************************************************************

.tile3_43

 EQUB %01000001          ; 83B0: 41          A
 EQUB %01100011          ; 83B1: 63          c
 EQUB %00011100          ; 83B2: 1C          .
 EQUB %00000000          ; 83B3: 00          .
 EQUB %11111111          ; 83B4: FF          .
 EQUB %00000000          ; 83B5: 00          .
 EQUB %00000000          ; 83B6: 00          .
 EQUB %00000000          ; 83B7: 00          .
 EQUB %11111111          ; 83B8: FF          .
 EQUB %11111111          ; 83B9: FF          .
 EQUB %11111111          ; 83BA: FF          .
 EQUB %11111111          ; 83BB: FF          .
 EQUB %00000000          ; 83BC: 00          .
 EQUB %00000000          ; 83BD: 00          .
 EQUB %11111111          ; 83BE: FF          .
 EQUB %00000000          ; 83BF: 00          .

; ******************************************************************************
;
;       Name: tile3_44
;       Type: Variable
;   Category: Drawing images
;    Summary: ???
;
; ******************************************************************************

.tile3_44

 EQUB %00000000          ; 83C0: 00          .
 EQUB %00100000          ; 83C1: 20
 EQUB %00000000          ; 83C2: 00          .
 EQUB %00001000          ; 83C3: 08          .
 EQUB %11110000          ; 83C4: F0          .
 EQUB %00000001          ; 83C5: 01          .
 EQUB %00001001          ; 83C6: 09          .
 EQUB %00000001          ; 83C7: 01          .
 EQUB %11111001          ; 83C8: F9          .
 EQUB %11011001          ; 83C9: D9          .
 EQUB %11111001          ; 83CA: F9          .
 EQUB %11110001          ; 83CB: F1          .
 EQUB %00001001          ; 83CC: 09          .
 EQUB %00000000          ; 83CD: 00          .
 EQUB %11110100          ; 83CE: F4          .
 EQUB %00000100          ; 83CF: 04          .

; ******************************************************************************
;
;       Name: tile3_45
;       Type: Variable
;   Category: Drawing images
;    Summary: ???
;
; ******************************************************************************

.tile3_45

 EQUB %00011100          ; 83D0: 1C          .
 EQUB %00000000          ; 83D1: 00          .
 EQUB %00000000          ; 83D2: 00          .
 EQUB %00000000          ; 83D3: 00          .
 EQUB %11111111          ; 83D4: FF          .
 EQUB %00000000          ; 83D5: 00          .
 EQUB %00000000          ; 83D6: 00          .
 EQUB %00000000          ; 83D7: 00          .
 EQUB %11011101          ; 83D8: DD          .
 EQUB %11100011          ; 83D9: E3          .
 EQUB %11111111          ; 83DA: FF          .
 EQUB %11111111          ; 83DB: FF          .
 EQUB %00000000          ; 83DC: 00          .
 EQUB %00000000          ; 83DD: 00          .
 EQUB %11111111          ; 83DE: FF          .
 EQUB %00000000          ; 83DF: 00          .

; ******************************************************************************
;
;       Name: tile3_46
;       Type: Variable
;   Category: Drawing images
;    Summary: ???
;
; ******************************************************************************

.tile3_46

 EQUB %01111101          ; 83E0: 7D          }
 EQUB %00000001          ; 83E1: 01          .
 EQUB %00011111          ; 83E2: 1F          .
 EQUB %00000000          ; 83E3: 00          .
 EQUB %11111111          ; 83E4: FF          .
 EQUB %00000000          ; 83E5: 00          .
 EQUB %00000000          ; 83E6: 00          .
 EQUB %00000000          ; 83E7: 00          .
 EQUB %00000000          ; 83E8: 00          .
 EQUB %00000000          ; 83E9: 00          .
 EQUB %11000000          ; 83EA: C0          .
 EQUB %11000000          ; 83EB: C0          .
 EQUB %00000000          ; 83EC: 00          .
 EQUB %00000000          ; 83ED: 00          .
 EQUB %11111111          ; 83EE: FF          .
 EQUB %00000000          ; 83EF: 00          .

; ******************************************************************************
;
;       Name: tile3_47
;       Type: Variable
;   Category: Drawing images
;    Summary: ???
;
; ******************************************************************************

.tile3_47

 EQUB %01000000          ; 83F0: 40          @
 EQUB %01000000          ; 83F1: 40          @
 EQUB %00000000          ; 83F2: 00          .
 EQUB %00001000          ; 83F3: 08          .
 EQUB %11110000          ; 83F4: F0          .
 EQUB %00000001          ; 83F5: 01          .
 EQUB %00001001          ; 83F6: 09          .
 EQUB %00000001          ; 83F7: 01          .
 EQUB %00011001          ; 83F8: 19          .
 EQUB %00011001          ; 83F9: 19          .
 EQUB %00111001          ; 83FA: 39          9
 EQUB %01110001          ; 83FB: 71          q
 EQUB %00001001          ; 83FC: 09          .
 EQUB %00000000          ; 83FD: 00          .
 EQUB %11110100          ; 83FE: F4          .
 EQUB %00000100          ; 83FF: 04          .

; ******************************************************************************
;
;       Name: tile3_48
;       Type: Variable
;   Category: Drawing images
;    Summary: ???
;
; ******************************************************************************

.tile3_48

 EQUB %00000000          ; 8400: 00          .
 EQUB %00001110          ; 8401: 0E          .
 EQUB %00000000          ; 8402: 00          .
 EQUB %00000000          ; 8403: 00          .
 EQUB %11111111          ; 8404: FF          .
 EQUB %00000000          ; 8405: 00          .
 EQUB %00000000          ; 8406: 00          .
 EQUB %00000000          ; 8407: 00          .
 EQUB %11111111          ; 8408: FF          .
 EQUB %11111111          ; 8409: FF          .
 EQUB %11111111          ; 840A: FF          .
 EQUB %11111111          ; 840B: FF          .
 EQUB %00000000          ; 840C: 00          .
 EQUB %00000000          ; 840D: 00          .
 EQUB %11111111          ; 840E: FF          .
 EQUB %00000000          ; 840F: 00          .

; ******************************************************************************
;
;       Name: tile3_49
;       Type: Variable
;   Category: Drawing images
;    Summary: ???
;
; ******************************************************************************

.tile3_49

 EQUB %00000000          ; 8410: 00          .
 EQUB %11011101          ; 8411: DD          .
 EQUB %00000000          ; 8412: 00          .
 EQUB %00000000          ; 8413: 00          .
 EQUB %11111111          ; 8414: FF          .
 EQUB %00000000          ; 8415: 00          .
 EQUB %00000000          ; 8416: 00          .
 EQUB %00000000          ; 8417: 00          .
 EQUB %11111111          ; 8418: FF          .
 EQUB %00100010          ; 8419: 22          "
 EQUB %11111111          ; 841A: FF          .
 EQUB %11111111          ; 841B: FF          .
 EQUB %00000000          ; 841C: 00          .
 EQUB %00000000          ; 841D: 00          .
 EQUB %11111111          ; 841E: FF          .
 EQUB %00000000          ; 841F: 00          .

; ******************************************************************************
;
;       Name: tile3_50
;       Type: Variable
;   Category: Drawing images
;    Summary: ???
;
; ******************************************************************************

.tile3_50

 EQUB %00000000          ; 8420: 00          .
 EQUB %10100000          ; 8421: A0          .
 EQUB %00000000          ; 8422: 00          .
 EQUB %00001000          ; 8423: 08          .
 EQUB %11110000          ; 8424: F0          .
 EQUB %00000001          ; 8425: 01          .
 EQUB %00001001          ; 8426: 09          .
 EQUB %00000001          ; 8427: 01          .
 EQUB %11111001          ; 8428: F9          .
 EQUB %01011001          ; 8429: 59          Y
 EQUB %11111001          ; 842A: F9          .
 EQUB %11110001          ; 842B: F1          .
 EQUB %00001001          ; 842C: 09          .
 EQUB %00000000          ; 842D: 00          .
 EQUB %11110100          ; 842E: F4          .
 EQUB %00000100          ; 842F: 04          .

; ******************************************************************************
;
;       Name: tile3_51
;       Type: Variable
;   Category: Drawing images
;    Summary: ???
;
; ******************************************************************************

.tile3_51

 EQUB %00000010          ; 8430: 02          .
 EQUB %00000010          ; 8431: 02          .
 EQUB %00000000          ; 8432: 00          .
 EQUB %00100000          ; 8433: 20
 EQUB %00011111          ; 8434: 1F          .
 EQUB %00000000          ; 8435: 00          .
 EQUB %00100000          ; 8436: 20
 EQUB %00000000          ; 8437: 00          .
 EQUB %00111010          ; 8438: 3A          :
 EQUB %00111010          ; 8439: 3A          :
 EQUB %00111100          ; 843A: 3C          <
 EQUB %00011111          ; 843B: 1F          .
 EQUB %00100000          ; 843C: 20
 EQUB %00000000          ; 843D: 00          .
 EQUB %01011111          ; 843E: 5F          _
 EQUB %01000000          ; 843F: 40          @

; ******************************************************************************
;
;       Name: tile3_52
;       Type: Variable
;   Category: Drawing images
;    Summary: ???
;
; ******************************************************************************

.tile3_52

 EQUB %11010000          ; 8440: D0          .
 EQUB %11010000          ; 8441: D0          .
 EQUB %11000000          ; 8442: C0          .
 EQUB %00000000          ; 8443: 00          .
 EQUB %11111111          ; 8444: FF          .
 EQUB %00000000          ; 8445: 00          .
 EQUB %00000000          ; 8446: 00          .
 EQUB %00000000          ; 8447: 00          .
 EQUB %00000111          ; 8448: 07          .
 EQUB %00000111          ; 8449: 07          .
 EQUB %00001111          ; 844A: 0F          .
 EQUB %00111111          ; 844B: 3F          ?
 EQUB %00000000          ; 844C: 00          .
 EQUB %00000000          ; 844D: 00          .
 EQUB %11111111          ; 844E: FF          .
 EQUB %00000000          ; 844F: 00          .

; ******************************************************************************
;
;       Name: tile3_53
;       Type: Variable
;   Category: Drawing images
;    Summary: ???
;
; ******************************************************************************

.tile3_53

 EQUB %00000000          ; 8450: 00          .
 EQUB %00000000          ; 8451: 00          .
 EQUB %00000000          ; 8452: 00          .
 EQUB %00000000          ; 8453: 00          .
 EQUB %00000000          ; 8454: 00          .
 EQUB %00000000          ; 8455: 00          .
 EQUB %00000000          ; 8456: 00          .
 EQUB %00000000          ; 8457: 00          .
 EQUB %00000000          ; 8458: 00          .
 EQUB %00000000          ; 8459: 00          .
 EQUB %00000000          ; 845A: 00          .
 EQUB %00000000          ; 845B: 00          .
 EQUB %00000000          ; 845C: 00          .
 EQUB %00000000          ; 845D: 00          .
 EQUB %00000000          ; 845E: 00          .
 EQUB %00000000          ; 845F: 00          .

; ******************************************************************************
;
;       Name: tile3_54
;       Type: Variable
;   Category: Drawing images
;    Summary: ???
;
; ******************************************************************************

.tile3_54

 EQUB %00000000          ; 8460: 00          .
 EQUB %00000000          ; 8461: 00          .
 EQUB %00000000          ; 8462: 00          .
 EQUB %00000000          ; 8463: 00          .
 EQUB %00000000          ; 8464: 00          .
 EQUB %00000000          ; 8465: 00          .
 EQUB %00000000          ; 8466: 00          .
 EQUB %00000000          ; 8467: 00          .
 EQUB %00000000          ; 8468: 00          .
 EQUB %00000000          ; 8469: 00          .
 EQUB %00000000          ; 846A: 00          .
 EQUB %00000000          ; 846B: 00          .
 EQUB %00000000          ; 846C: 00          .
 EQUB %00000000          ; 846D: 00          .
 EQUB %00000000          ; 846E: 00          .
 EQUB %00000000          ; 846F: 00          .

; ******************************************************************************
;
;       Name: tile3_55
;       Type: Variable
;   Category: Drawing images
;    Summary: ???
;
; ******************************************************************************

.tile3_55

 EQUB %00000000          ; 8470: 00          .
 EQUB %00000000          ; 8471: 00          .
 EQUB %00000000          ; 8472: 00          .
 EQUB %00000000          ; 8473: 00          .
 EQUB %00000000          ; 8474: 00          .
 EQUB %00000000          ; 8475: 00          .
 EQUB %00000000          ; 8476: 00          .
 EQUB %00000000          ; 8477: 00          .
 EQUB %00000000          ; 8478: 00          .
 EQUB %00000000          ; 8479: 00          .
 EQUB %00000000          ; 847A: 00          .
 EQUB %00000000          ; 847B: 00          .
 EQUB %00000000          ; 847C: 00          .
 EQUB %00000000          ; 847D: 00          .
 EQUB %00000000          ; 847E: 00          .
 EQUB %00000000          ; 847F: 00          .

; ******************************************************************************
;
;       Name: tile3_56
;       Type: Variable
;   Category: Drawing images
;    Summary: ???
;
; ******************************************************************************

.tile3_56

 EQUB %00000000          ; 8480: 00          .
 EQUB %00000000          ; 8481: 00          .
 EQUB %00000000          ; 8482: 00          .
 EQUB %00000000          ; 8483: 00          .
 EQUB %00000000          ; 8484: 00          .
 EQUB %00000000          ; 8485: 00          .
 EQUB %00000000          ; 8486: 00          .
 EQUB %00000000          ; 8487: 00          .
 EQUB %00000000          ; 8488: 00          .
 EQUB %00000000          ; 8489: 00          .
 EQUB %00000000          ; 848A: 00          .
 EQUB %00000000          ; 848B: 00          .
 EQUB %00000000          ; 848C: 00          .
 EQUB %00000000          ; 848D: 00          .
 EQUB %00000000          ; 848E: 00          .
 EQUB %00000000          ; 848F: 00          .

; ******************************************************************************
;
;       Name: tile3_57
;       Type: Variable
;   Category: Drawing images
;    Summary: ???
;
; ******************************************************************************

.tile3_57

 EQUB %00000000          ; 8490: 00          .
 EQUB %00000000          ; 8491: 00          .
 EQUB %00000000          ; 8492: 00          .
 EQUB %00000000          ; 8493: 00          .
 EQUB %00000000          ; 8494: 00          .
 EQUB %00000000          ; 8495: 00          .
 EQUB %00000000          ; 8496: 00          .
 EQUB %00000000          ; 8497: 00          .
 EQUB %00000000          ; 8498: 00          .
 EQUB %00000000          ; 8499: 00          .
 EQUB %00000000          ; 849A: 00          .
 EQUB %00000000          ; 849B: 00          .
 EQUB %00000000          ; 849C: 00          .
 EQUB %00000000          ; 849D: 00          .
 EQUB %00000000          ; 849E: 00          .
 EQUB %00000000          ; 849F: 00          .

; ******************************************************************************
;
;       Name: tile3_58
;       Type: Variable
;   Category: Drawing images
;    Summary: ???
;
; ******************************************************************************

.tile3_58

 EQUB %00000000          ; 84A0: 00          .
 EQUB %00000000          ; 84A1: 00          .
 EQUB %00000000          ; 84A2: 00          .
 EQUB %00000000          ; 84A3: 00          .
 EQUB %00000000          ; 84A4: 00          .
 EQUB %00000000          ; 84A5: 00          .
 EQUB %00000000          ; 84A6: 00          .
 EQUB %00000000          ; 84A7: 00          .
 EQUB %00000000          ; 84A8: 00          .
 EQUB %00000000          ; 84A9: 00          .
 EQUB %00000000          ; 84AA: 00          .
 EQUB %00000000          ; 84AB: 00          .
 EQUB %00000000          ; 84AC: 00          .
 EQUB %00000000          ; 84AD: 00          .
 EQUB %00000000          ; 84AE: 00          .
 EQUB %00000000          ; 84AF: 00          .

; ******************************************************************************
;
;       Name: tile3_59
;       Type: Variable
;   Category: Drawing images
;    Summary: ???
;
; ******************************************************************************

.tile3_59

 EQUB %00000000          ; 84B0: 00          .
 EQUB %00000000          ; 84B1: 00          .
 EQUB %00000000          ; 84B2: 00          .
 EQUB %00000000          ; 84B3: 00          .
 EQUB %00000000          ; 84B4: 00          .
 EQUB %00000000          ; 84B5: 00          .
 EQUB %00000000          ; 84B6: 00          .
 EQUB %00000000          ; 84B7: 00          .
 EQUB %00000000          ; 84B8: 00          .
 EQUB %00000000          ; 84B9: 00          .
 EQUB %00000000          ; 84BA: 00          .
 EQUB %00000000          ; 84BB: 00          .
 EQUB %00000000          ; 84BC: 00          .
 EQUB %00000000          ; 84BD: 00          .
 EQUB %00000000          ; 84BE: 00          .
 EQUB %00000000          ; 84BF: 00          .

; ******************************************************************************
;
;       Name: tile3_60
;       Type: Variable
;   Category: Drawing images
;    Summary: ???
;
; ******************************************************************************

.tile3_60

 EQUB %00000000          ; 84C0: 00          .
 EQUB %00000000          ; 84C1: 00          .
 EQUB %00000000          ; 84C2: 00          .
 EQUB %00000000          ; 84C3: 00          .
 EQUB %00000000          ; 84C4: 00          .
 EQUB %00000000          ; 84C5: 00          .
 EQUB %00000000          ; 84C6: 00          .
 EQUB %00000000          ; 84C7: 00          .
 EQUB %00000000          ; 84C8: 00          .
 EQUB %00000000          ; 84C9: 00          .
 EQUB %00000000          ; 84CA: 00          .
 EQUB %00000000          ; 84CB: 00          .
 EQUB %00000000          ; 84CC: 00          .
 EQUB %00000000          ; 84CD: 00          .
 EQUB %00000000          ; 84CE: 00          .
 EQUB %00000000          ; 84CF: 00          .

; ******************************************************************************
;
;       Name: tile3_61
;       Type: Variable
;   Category: Drawing images
;    Summary: ???
;
; ******************************************************************************

.tile3_61

 EQUB %00000000          ; 84D0: 00          .
 EQUB %00000000          ; 84D1: 00          .
 EQUB %00000000          ; 84D2: 00          .
 EQUB %00000000          ; 84D3: 00          .
 EQUB %00000000          ; 84D4: 00          .
 EQUB %00000000          ; 84D5: 00          .
 EQUB %00000000          ; 84D6: 00          .
 EQUB %00000000          ; 84D7: 00          .
 EQUB %00000000          ; 84D8: 00          .
 EQUB %00000000          ; 84D9: 00          .
 EQUB %00000000          ; 84DA: 00          .
 EQUB %00000000          ; 84DB: 00          .
 EQUB %00000000          ; 84DC: 00          .
 EQUB %00000000          ; 84DD: 00          .
 EQUB %00000000          ; 84DE: 00          .
 EQUB %00000000          ; 84DF: 00          .

; ******************************************************************************
;
;       Name: tile3_62
;       Type: Variable
;   Category: Drawing images
;    Summary: ???
;
; ******************************************************************************

.tile3_62

 EQUB %00000000          ; 84E0: 00          .
 EQUB %00000000          ; 84E1: 00          .
 EQUB %00000000          ; 84E2: 00          .
 EQUB %00000000          ; 84E3: 00          .
 EQUB %00000000          ; 84E4: 00          .
 EQUB %00000000          ; 84E5: 00          .
 EQUB %00000000          ; 84E6: 00          .
 EQUB %00000000          ; 84E7: 00          .
 EQUB %00000000          ; 84E8: 00          .
 EQUB %00000000          ; 84E9: 00          .
 EQUB %00000000          ; 84EA: 00          .
 EQUB %00000000          ; 84EB: 00          .
 EQUB %00000000          ; 84EC: 00          .
 EQUB %00000000          ; 84ED: 00          .
 EQUB %00000000          ; 84EE: 00          .
 EQUB %00000000          ; 84EF: 00          .

; ******************************************************************************
;
;       Name: tile3_63
;       Type: Variable
;   Category: Drawing images
;    Summary: ???
;
; ******************************************************************************

.tile3_63

 EQUB %00000000          ; 84F0: 00          .
 EQUB %00000000          ; 84F1: 00          .
 EQUB %00000000          ; 84F2: 00          .
 EQUB %00000000          ; 84F3: 00          .
 EQUB %00000000          ; 84F4: 00          .
 EQUB %00000000          ; 84F5: 00          .
 EQUB %00000000          ; 84F6: 00          .
 EQUB %00000000          ; 84F7: 00          .
 EQUB %00000000          ; 84F8: 00          .
 EQUB %00000000          ; 84F9: 00          .
 EQUB %00000000          ; 84FA: 00          .
 EQUB %00000000          ; 84FB: 00          .
 EQUB %00000000          ; 84FC: 00          .
 EQUB %00000000          ; 84FD: 00          .
 EQUB %00000000          ; 84FE: 00          .
 EQUB %00000000          ; 84FF: 00          .

; ******************************************************************************
;
;       Name: tile3_64
;       Type: Variable
;   Category: Drawing images
;    Summary: ???
;
; ******************************************************************************

.tile3_64

 EQUB %00000000          ; 8500: 00          .
 EQUB %00000000          ; 8501: 00          .
 EQUB %00000000          ; 8502: 00          .
 EQUB %00000000          ; 8503: 00          .
 EQUB %00000000          ; 8504: 00          .
 EQUB %00000000          ; 8505: 00          .
 EQUB %00000000          ; 8506: 00          .
 EQUB %00000000          ; 8507: 00          .
 EQUB %11111110          ; 8508: FE          .
 EQUB %11111111          ; 8509: FF          .
 EQUB %11111111          ; 850A: FF          .
 EQUB %11111111          ; 850B: FF          .
 EQUB %11111111          ; 850C: FF          .
 EQUB %11111111          ; 850D: FF          .
 EQUB %11111111          ; 850E: FF          .
 EQUB %11111111          ; 850F: FF          .

; ******************************************************************************
;
;       Name: tile3_65
;       Type: Variable
;   Category: Drawing images
;    Summary: ???
;
; ******************************************************************************

.tile3_65

 EQUB %00000000          ; 8510: 00          .
 EQUB %00000000          ; 8511: 00          .
 EQUB %00000000          ; 8512: 00          .
 EQUB %00000000          ; 8513: 00          .
 EQUB %00000000          ; 8514: 00          .
 EQUB %00000000          ; 8515: 00          .
 EQUB %00000000          ; 8516: 00          .
 EQUB %00000000          ; 8517: 00          .
 EQUB %00000000          ; 8518: 00          .
 EQUB %00000001          ; 8519: 01          .
 EQUB %00000001          ; 851A: 01          .
 EQUB %01111101          ; 851B: 7D          }
 EQUB %01111101          ; 851C: 7D          }
 EQUB %10111011          ; 851D: BB          .
 EQUB %10111011          ; 851E: BB          .
 EQUB %10111011          ; 851F: BB          .

; ******************************************************************************
;
;       Name: tile3_66
;       Type: Variable
;   Category: Drawing images
;    Summary: ???
;
; ******************************************************************************

.tile3_66

 EQUB %00000000          ; 8520: 00          .
 EQUB %00000000          ; 8521: 00          .
 EQUB %00000000          ; 8522: 00          .
 EQUB %00000000          ; 8523: 00          .
 EQUB %00000000          ; 8524: 00          .
 EQUB %00000000          ; 8525: 00          .
 EQUB %00000000          ; 8526: 00          .
 EQUB %00000000          ; 8527: 00          .
 EQUB %11111111          ; 8528: FF          .
 EQUB %11111111          ; 8529: FF          .
 EQUB %11111111          ; 852A: FF          .
 EQUB %11111111          ; 852B: FF          .
 EQUB %11111111          ; 852C: FF          .
 EQUB %11111111          ; 852D: FF          .
 EQUB %11111111          ; 852E: FF          .
 EQUB %11111111          ; 852F: FF          .

; ******************************************************************************
;
;       Name: tile3_67
;       Type: Variable
;   Category: Drawing images
;    Summary: ???
;
; ******************************************************************************

.tile3_67

 EQUB %00000000          ; 8530: 00          .
 EQUB %00000000          ; 8531: 00          .
 EQUB %00000000          ; 8532: 00          .
 EQUB %00000000          ; 8533: 00          .
 EQUB %00000000          ; 8534: 00          .
 EQUB %00000000          ; 8535: 00          .
 EQUB %00000000          ; 8536: 00          .
 EQUB %00000000          ; 8537: 00          .
 EQUB %11100000          ; 8538: E0          .
 EQUB %11110000          ; 8539: F0          .
 EQUB %11110000          ; 853A: F0          .
 EQUB %11110111          ; 853B: F7          .
 EQUB %11110111          ; 853C: F7          .
 EQUB %11111011          ; 853D: FB          .
 EQUB %11111011          ; 853E: FB          .
 EQUB %11111011          ; 853F: FB          .

; ******************************************************************************
;
;       Name: tile3_68
;       Type: Variable
;   Category: Drawing images
;    Summary: ???
;
; ******************************************************************************

.tile3_68

 EQUB %00000000          ; 8540: 00          .
 EQUB %00000000          ; 8541: 00          .
 EQUB %00000000          ; 8542: 00          .
 EQUB %00000000          ; 8543: 00          .
 EQUB %00000000          ; 8544: 00          .
 EQUB %00000000          ; 8545: 00          .
 EQUB %00000000          ; 8546: 00          .
 EQUB %00000000          ; 8547: 00          .
 EQUB %00000011          ; 8548: 03          .
 EQUB %00000011          ; 8549: 03          .
 EQUB %00000011          ; 854A: 03          .
 EQUB %00000011          ; 854B: 03          .
 EQUB %00000011          ; 854C: 03          .
 EQUB %00000011          ; 854D: 03          .
 EQUB %00000111          ; 854E: 07          .
 EQUB %00000111          ; 854F: 07          .

; ******************************************************************************
;
;       Name: tile3_69
;       Type: Variable
;   Category: Drawing images
;    Summary: ???
;
; ******************************************************************************

.tile3_69

 EQUB %00000000          ; 8550: 00          .
 EQUB %00000000          ; 8551: 00          .
 EQUB %00000000          ; 8552: 00          .
 EQUB %00000000          ; 8553: 00          .
 EQUB %00000000          ; 8554: 00          .
 EQUB %00000000          ; 8555: 00          .
 EQUB %00000000          ; 8556: 00          .
 EQUB %00000000          ; 8557: 00          .
 EQUB %11000000          ; 8558: C0          .
 EQUB %11000000          ; 8559: C0          .
 EQUB %11000000          ; 855A: C0          .
 EQUB %11000000          ; 855B: C0          .
 EQUB %11000000          ; 855C: C0          .
 EQUB %11000000          ; 855D: C0          .
 EQUB %11100000          ; 855E: E0          .
 EQUB %11100000          ; 855F: E0          .

; ******************************************************************************
;
;       Name: tile3_70
;       Type: Variable
;   Category: Drawing images
;    Summary: ???
;
; ******************************************************************************

.tile3_70

 EQUB %00000000          ; 8560: 00          .
 EQUB %00000000          ; 8561: 00          .
 EQUB %00000000          ; 8562: 00          .
 EQUB %00000001          ; 8563: 01          .
 EQUB %00000101          ; 8564: 05          .
 EQUB %00000110          ; 8565: 06          .
 EQUB %00000111          ; 8566: 07          .
 EQUB %00000110          ; 8567: 06          .
 EQUB %00001111          ; 8568: 0F          .
 EQUB %00011111          ; 8569: 1F          .
 EQUB %00011100          ; 856A: 1C          .
 EQUB %11010000          ; 856B: D0          .
 EQUB %11010100          ; 856C: D4          .
 EQUB %10110110          ; 856D: B6          .
 EQUB %10110111          ; 856E: B7          .
 EQUB %10110110          ; 856F: B6          .

; ******************************************************************************
;
;       Name: tile3_71
;       Type: Variable
;   Category: Drawing images
;    Summary: ???
;
; ******************************************************************************

.tile3_71

 EQUB %00000000          ; 8570: 00          .
 EQUB %00000000          ; 8571: 00          .
 EQUB %00000000          ; 8572: 00          .
 EQUB %10000100          ; 8573: 84          .
 EQUB %00100000          ; 8574: 20
 EQUB %01010000          ; 8575: 50          P
 EQUB %00001000          ; 8576: 08          .
 EQUB %01010000          ; 8577: 50          P
 EQUB %11111110          ; 8578: FE          .
 EQUB %11111111          ; 8579: FF          .
 EQUB %00000001          ; 857A: 01          .
 EQUB %00101001          ; 857B: 29          )
 EQUB %01010101          ; 857C: 55          U
 EQUB %10101001          ; 857D: A9          .
 EQUB %00000101          ; 857E: 05          .
 EQUB %10101001          ; 857F: A9          .

; ******************************************************************************
;
;       Name: tile3_72
;       Type: Variable
;   Category: Drawing images
;    Summary: ???
;
; ******************************************************************************

.tile3_72

 EQUB %00000000          ; 8580: 00          .
 EQUB %00000000          ; 8581: 00          .
 EQUB %00000000          ; 8582: 00          .
 EQUB %00000000          ; 8583: 00          .
 EQUB %00000000          ; 8584: 00          .
 EQUB %00000000          ; 8585: 00          .
 EQUB %00000000          ; 8586: 00          .
 EQUB %00000001          ; 8587: 01          .
 EQUB %11111111          ; 8588: FF          .
 EQUB %11110111          ; 8589: F7          .
 EQUB %01100001          ; 858A: 61          a
 EQUB %01010111          ; 858B: 57          W
 EQUB %01000001          ; 858C: 41          A
 EQUB %01110101          ; 858D: 75          u
 EQUB %01000011          ; 858E: 43          C
 EQUB %01110111          ; 858F: 77          w

; ******************************************************************************
;
;       Name: tile3_73
;       Type: Variable
;   Category: Drawing images
;    Summary: ???
;
; ******************************************************************************

.tile3_73

 EQUB %00000000          ; 8590: 00          .
 EQUB %00000000          ; 8591: 00          .
 EQUB %00000000          ; 8592: 00          .
 EQUB %00000000          ; 8593: 00          .
 EQUB %00000000          ; 8594: 00          .
 EQUB %01000000          ; 8595: 40          @
 EQUB %10100000          ; 8596: A0          .
 EQUB %00000000          ; 8597: 00          .
 EQUB %11100000          ; 8598: E0          .
 EQUB %11110000          ; 8599: F0          .
 EQUB %11110000          ; 859A: F0          .
 EQUB %11110111          ; 859B: F7          .
 EQUB %11110111          ; 859C: F7          .
 EQUB %11111011          ; 859D: FB          .
 EQUB %11111011          ; 859E: FB          .
 EQUB %11111011          ; 859F: FB          .

; ******************************************************************************
;
;       Name: tile3_74
;       Type: Variable
;   Category: Drawing images
;    Summary: ???
;
; ******************************************************************************

.tile3_74

 EQUB %00000000          ; 85A0: 00          .
 EQUB %00000000          ; 85A1: 00          .
 EQUB %00001101          ; 85A2: 0D          .
 EQUB %00000000          ; 85A3: 00          .
 EQUB %00000111          ; 85A4: 07          .
 EQUB %00000000          ; 85A5: 00          .
 EQUB %00000000          ; 85A6: 00          .
 EQUB %00000000          ; 85A7: 00          .
 EQUB %00001111          ; 85A8: 0F          .
 EQUB %00011111          ; 85A9: 1F          .
 EQUB %00010010          ; 85AA: 12          .
 EQUB %11011111          ; 85AB: DF          .
 EQUB %11011000          ; 85AC: D8          .
 EQUB %10111111          ; 85AD: BF          .
 EQUB %10100101          ; 85AE: A5          .
 EQUB %10101101          ; 85AF: AD          .

; ******************************************************************************
;
;       Name: tile3_75
;       Type: Variable
;   Category: Drawing images
;    Summary: ???
;
; ******************************************************************************

.tile3_75

 EQUB %00000000          ; 85B0: 00          .
 EQUB %00000000          ; 85B1: 00          .
 EQUB %01101010          ; 85B2: 6A          j
 EQUB %00000000          ; 85B3: 00          .
 EQUB %01011000          ; 85B4: 58          X
 EQUB %00000000          ; 85B5: 00          .
 EQUB %00000000          ; 85B6: 00          .
 EQUB %00000000          ; 85B7: 00          .
 EQUB %11111110          ; 85B8: FE          .
 EQUB %11111111          ; 85B9: FF          .
 EQUB %10010101          ; 85BA: 95          .
 EQUB %11111111          ; 85BB: FF          .
 EQUB %10100111          ; 85BC: A7          .
 EQUB %11111111          ; 85BD: FF          .
 EQUB %10100000          ; 85BE: A0          .
 EQUB %10110101          ; 85BF: B5          .

; ******************************************************************************
;
;       Name: tile3_76
;       Type: Variable
;   Category: Drawing images
;    Summary: ???
;
; ******************************************************************************

.tile3_76

 EQUB %00000000          ; 85C0: 00          .
 EQUB %00000000          ; 85C1: 00          .
 EQUB %00011100          ; 85C2: 1C          .
 EQUB %01100011          ; 85C3: 63          c
 EQUB %01000001          ; 85C4: 41          A
 EQUB %10000000          ; 85C5: 80          .
 EQUB %10000000          ; 85C6: 80          .
 EQUB %10000000          ; 85C7: 80          .
 EQUB %11111111          ; 85C8: FF          .
 EQUB %11111111          ; 85C9: FF          .
 EQUB %11111111          ; 85CA: FF          .
 EQUB %11111111          ; 85CB: FF          .
 EQUB %11111111          ; 85CC: FF          .
 EQUB %11110111          ; 85CD: F7          .
 EQUB %11100011          ; 85CE: E3          .
 EQUB %11110111          ; 85CF: F7          .

; ******************************************************************************
;
;       Name: tile3_77
;       Type: Variable
;   Category: Drawing images
;    Summary: ???
;
; ******************************************************************************

.tile3_77

 EQUB %00000000          ; 85D0: 00          .
 EQUB %00000000          ; 85D1: 00          .
 EQUB %00000000          ; 85D2: 00          .
 EQUB %01000000          ; 85D3: 40          @
 EQUB %00000000          ; 85D4: 00          .
 EQUB %10000000          ; 85D5: 80          .
 EQUB %10010000          ; 85D6: 90          .
 EQUB %10000000          ; 85D7: 80          .
 EQUB %11100000          ; 85D8: E0          .
 EQUB %11110000          ; 85D9: F0          .
 EQUB %11110000          ; 85DA: F0          .
 EQUB %10110111          ; 85DB: B7          .
 EQUB %11110111          ; 85DC: F7          .
 EQUB %11111011          ; 85DD: FB          .
 EQUB %11101011          ; 85DE: EB          .
 EQUB %11111011          ; 85DF: FB          .

; ******************************************************************************
;
;       Name: tile3_78
;       Type: Variable
;   Category: Drawing images
;    Summary: ???
;
; ******************************************************************************

.tile3_78

 EQUB %00000000          ; 85E0: 00          .
 EQUB %00000000          ; 85E1: 00          .
 EQUB %00000010          ; 85E2: 02          .
 EQUB %00000000          ; 85E3: 00          .
 EQUB %00000000          ; 85E4: 00          .
 EQUB %00000100          ; 85E5: 04          .
 EQUB %00000000          ; 85E6: 00          .
 EQUB %00000001          ; 85E7: 01          .
 EQUB %00001111          ; 85E8: 0F          .
 EQUB %00011111          ; 85E9: 1F          .
 EQUB %00011101          ; 85EA: 1D          .
 EQUB %11011111          ; 85EB: DF          .
 EQUB %11011111          ; 85EC: DF          .
 EQUB %10111010          ; 85ED: BA          .
 EQUB %10111111          ; 85EE: BF          .
 EQUB %10111111          ; 85EF: BF          .

; ******************************************************************************
;
;       Name: tile3_79
;       Type: Variable
;   Category: Drawing images
;    Summary: ???
;
; ******************************************************************************

.tile3_79

 EQUB %00000000          ; 85F0: 00          .
 EQUB %00000000          ; 85F1: 00          .
 EQUB %00000000          ; 85F2: 00          .
 EQUB %00000100          ; 85F3: 04          .
 EQUB %00000000          ; 85F4: 00          .
 EQUB %00000000          ; 85F5: 00          .
 EQUB %10100000          ; 85F6: A0          .
 EQUB %00010000          ; 85F7: 10          .
 EQUB %11111110          ; 85F8: FE          .
 EQUB %11111111          ; 85F9: FF          .
 EQUB %11111111          ; 85FA: FF          .
 EQUB %10111011          ; 85FB: BB          .
 EQUB %10111111          ; 85FC: BF          .
 EQUB %01001111          ; 85FD: 4F          O
 EQUB %10111111          ; 85FE: BF          .
 EQUB %10111111          ; 85FF: BF          .

; ******************************************************************************
;
;       Name: tile3_80
;       Type: Variable
;   Category: Drawing images
;    Summary: ???
;
; ******************************************************************************

.tile3_80

 EQUB %00000000          ; 8600: 00          .
 EQUB %00000000          ; 8601: 00          .
 EQUB %00000000          ; 8602: 00          .
 EQUB %00000000          ; 8603: 00          .
 EQUB %00000000          ; 8604: 00          .
 EQUB %00000000          ; 8605: 00          .
 EQUB %00000000          ; 8606: 00          .
 EQUB %00000000          ; 8607: 00          .
 EQUB %00000000          ; 8608: 00          .
 EQUB %00000001          ; 8609: 01          .
 EQUB %00000001          ; 860A: 01          .
 EQUB %01111101          ; 860B: 7D          }
 EQUB %01111101          ; 860C: 7D          }
 EQUB %10111011          ; 860D: BB          .
 EQUB %10111010          ; 860E: BA          .
 EQUB %10111011          ; 860F: BB          .

; ******************************************************************************
;
;       Name: tile3_81
;       Type: Variable
;   Category: Drawing images
;    Summary: ???
;
; ******************************************************************************

.tile3_81

 EQUB %00000000          ; 8610: 00          .
 EQUB %00000000          ; 8611: 00          .
 EQUB %00000000          ; 8612: 00          .
 EQUB %00000011          ; 8613: 03          .
 EQUB %00100111          ; 8614: 27          '
 EQUB %01101111          ; 8615: 6F          o
 EQUB %11101111          ; 8616: EF          .
 EQUB %01101111          ; 8617: 6F          o
 EQUB %11111111          ; 8618: FF          .
 EQUB %11111111          ; 8619: FF          .
 EQUB %11111100          ; 861A: FC          .
 EQUB %11010000          ; 861B: D0          .
 EQUB %10100110          ; 861C: A6          .
 EQUB %01101011          ; 861D: 6B          k
 EQUB %11100011          ; 861E: E3          .
 EQUB %01100101          ; 861F: 65          e

; ******************************************************************************
;
;       Name: tile3_82
;       Type: Variable
;   Category: Drawing images
;    Summary: ???
;
; ******************************************************************************

.tile3_82

 EQUB %00000000          ; 8620: 00          .
 EQUB %00000000          ; 8621: 00          .
 EQUB %00000000          ; 8622: 00          .
 EQUB %10000000          ; 8623: 80          .
 EQUB %11000000          ; 8624: C0          .
 EQUB %11100000          ; 8625: E0          .
 EQUB %11100000          ; 8626: E0          .
 EQUB %11100000          ; 8627: E0          .
 EQUB %11100000          ; 8628: E0          .
 EQUB %11110000          ; 8629: F0          .
 EQUB %01110000          ; 862A: 70          p
 EQUB %10010111          ; 862B: 97          .
 EQUB %01010111          ; 862C: 57          W
 EQUB %11101011          ; 862D: EB          .
 EQUB %00101011          ; 862E: 2B          +
 EQUB %00101011          ; 862F: 2B          +

; ******************************************************************************
;
;       Name: tile3_83
;       Type: Variable
;   Category: Drawing images
;    Summary: ???
;
; ******************************************************************************

.tile3_83

 EQUB %00000000          ; 8630: 00          .
 EQUB %00000000          ; 8631: 00          .
 EQUB %00000000          ; 8632: 00          .
 EQUB %00000010          ; 8633: 02          .
 EQUB %00000101          ; 8634: 05          .
 EQUB %00001000          ; 8635: 08          .
 EQUB %00000010          ; 8636: 02          .
 EQUB %00000001          ; 8637: 01          .
 EQUB %00001111          ; 8638: 0F          .
 EQUB %00011111          ; 8639: 1F          .
 EQUB %00011111          ; 863A: 1F          .
 EQUB %11011101          ; 863B: DD          .
 EQUB %11011000          ; 863C: D8          .
 EQUB %10110010          ; 863D: B2          .
 EQUB %10110101          ; 863E: B5          .
 EQUB %10111100          ; 863F: BC          .

; ******************************************************************************
;
;       Name: tile3_84
;       Type: Variable
;   Category: Drawing images
;    Summary: ???
;
; ******************************************************************************

.tile3_84

 EQUB %00000000          ; 8640: 00          .
 EQUB %00000000          ; 8641: 00          .
 EQUB %00010000          ; 8642: 10          .
 EQUB %00101000          ; 8643: 28          (
 EQUB %01000010          ; 8644: 42          B
 EQUB %10000100          ; 8645: 84          .
 EQUB %00101000          ; 8646: 28          (
 EQUB %01010010          ; 8647: 52          R
 EQUB %11111110          ; 8648: FE          .
 EQUB %11111111          ; 8649: FF          .
 EQUB %11101111          ; 864A: EF          .
 EQUB %11000111          ; 864B: C7          .
 EQUB %10010101          ; 864C: 95          .
 EQUB %00111001          ; 864D: 39          9
 EQUB %01010011          ; 864E: 53          S
 EQUB %10000101          ; 864F: 85          .

; ******************************************************************************
;
;       Name: tile3_85
;       Type: Variable
;   Category: Drawing images
;    Summary: ???
;
; ******************************************************************************

.tile3_85

 EQUB %00000000          ; 8650: 00          .
 EQUB %00000000          ; 8651: 00          .
 EQUB %00000000          ; 8652: 00          .
 EQUB %00000000          ; 8653: 00          .
 EQUB %00000000          ; 8654: 00          .
 EQUB %00000000          ; 8655: 00          .
 EQUB %00000000          ; 8656: 00          .
 EQUB %00000001          ; 8657: 01          .
 EQUB %00000000          ; 8658: 00          .
 EQUB %00000001          ; 8659: 01          .
 EQUB %00000001          ; 865A: 01          .
 EQUB %01111101          ; 865B: 7D          }
 EQUB %01111101          ; 865C: 7D          }
 EQUB %10111011          ; 865D: BB          .
 EQUB %10111011          ; 865E: BB          .
 EQUB %10111010          ; 865F: BA          .

; ******************************************************************************
;
;       Name: tile3_86
;       Type: Variable
;   Category: Drawing images
;    Summary: ???
;
; ******************************************************************************

.tile3_86

 EQUB %00000000          ; 8660: 00          .
 EQUB %00000000          ; 8661: 00          .
 EQUB %00000010          ; 8662: 02          .
 EQUB %00000100          ; 8663: 04          .
 EQUB %00001000          ; 8664: 08          .
 EQUB %00010000          ; 8665: 10          .
 EQUB %11100000          ; 8666: E0          .
 EQUB %11000000          ; 8667: C0          .
 EQUB %11111111          ; 8668: FF          .
 EQUB %11111111          ; 8669: FF          .
 EQUB %11111100          ; 866A: FC          .
 EQUB %11111000          ; 866B: F8          .
 EQUB %11110001          ; 866C: F1          .
 EQUB %11100011          ; 866D: E3          .
 EQUB %00000110          ; 866E: 06          .
 EQUB %00001110          ; 866F: 0E          .

; ******************************************************************************
;
;       Name: tile3_87
;       Type: Variable
;   Category: Drawing images
;    Summary: ???
;
; ******************************************************************************

.tile3_87

 EQUB %00000000          ; 8670: 00          .
 EQUB %00000000          ; 8671: 00          .
 EQUB %00000000          ; 8672: 00          .
 EQUB %00000000          ; 8673: 00          .
 EQUB %00000000          ; 8674: 00          .
 EQUB %00000011          ; 8675: 03          .
 EQUB %00000111          ; 8676: 07          .
 EQUB %00000010          ; 8677: 02          .
 EQUB %00001111          ; 8678: 0F          .
 EQUB %00011111          ; 8679: 1F          .
 EQUB %00011111          ; 867A: 1F          .
 EQUB %11011111          ; 867B: DF          .
 EQUB %11011111          ; 867C: DF          .
 EQUB %10111100          ; 867D: BC          .
 EQUB %10111000          ; 867E: B8          .
 EQUB %10111000          ; 867F: B8          .

; ******************************************************************************
;
;       Name: tile3_88
;       Type: Variable
;   Category: Drawing images
;    Summary: ???
;
; ******************************************************************************

.tile3_88

 EQUB %00000000          ; 8680: 00          .
 EQUB %00001000          ; 8681: 08          .
 EQUB %00010000          ; 8682: 10          .
 EQUB %00100000          ; 8683: 20
 EQUB %01000000          ; 8684: 40          @
 EQUB %10000000          ; 8685: 80          .
 EQUB %00000000          ; 8686: 00          .
 EQUB %01000000          ; 8687: 40          @
 EQUB %11111110          ; 8688: FE          .
 EQUB %11110011          ; 8689: F3          .
 EQUB %11100011          ; 868A: E3          .
 EQUB %11000111          ; 868B: C7          .
 EQUB %10001111          ; 868C: 8F          .
 EQUB %00011111          ; 868D: 1F          .
 EQUB %00111111          ; 868E: 3F          ?
 EQUB %00111111          ; 868F: 3F          ?

; ******************************************************************************
;
;       Name: tile3_89
;       Type: Variable
;   Category: Drawing images
;    Summary: ???
;
; ******************************************************************************

.tile3_89

 EQUB %00000000          ; 8690: 00          .
 EQUB %00000000          ; 8691: 00          .
 EQUB %00100100          ; 8692: 24          $
 EQUB %00011111          ; 8693: 1F          .
 EQUB %00011111          ; 8694: 1F          .
 EQUB %01111111          ; 8695: 7F          .
 EQUB %00011111          ; 8696: 1F          .
 EQUB %00011111          ; 8697: 1F          .
 EQUB %11111111          ; 8698: FF          .
 EQUB %10111011          ; 8699: BB          .
 EQUB %11111011          ; 869A: FB          .
 EQUB %11100000          ; 869B: E0          .
 EQUB %11100000          ; 869C: E0          .
 EQUB %01000000          ; 869D: 40          @
 EQUB %11100000          ; 869E: E0          .
 EQUB %11100000          ; 869F: E0          .

; ******************************************************************************
;
;       Name: tile3_90
;       Type: Variable
;   Category: Drawing images
;    Summary: ???
;
; ******************************************************************************

.tile3_90

 EQUB %00000000          ; 86A0: 00          .
 EQUB %00000000          ; 86A1: 00          .
 EQUB %10000000          ; 86A2: 80          .
 EQUB %00000000          ; 86A3: 00          .
 EQUB %00000000          ; 86A4: 00          .
 EQUB %11000000          ; 86A5: C0          .
 EQUB %00000000          ; 86A6: 00          .
 EQUB %00000000          ; 86A7: 00          .
 EQUB %11100000          ; 86A8: E0          .
 EQUB %10110000          ; 86A9: B0          .
 EQUB %11110000          ; 86AA: F0          .
 EQUB %11110111          ; 86AB: F7          .
 EQUB %11110111          ; 86AC: F7          .
 EQUB %01011011          ; 86AD: 5B          [
 EQUB %11111011          ; 86AE: FB          .
 EQUB %11111011          ; 86AF: FB          .

; ******************************************************************************
;
;       Name: tile3_91
;       Type: Variable
;   Category: Drawing images
;    Summary: ???
;
; ******************************************************************************

.tile3_91

 EQUB %00000000          ; 86B0: 00          .
 EQUB %00000000          ; 86B1: 00          .
 EQUB %00000000          ; 86B2: 00          .
 EQUB %00000000          ; 86B3: 00          .
 EQUB %00000001          ; 86B4: 01          .
 EQUB %00000000          ; 86B5: 00          .
 EQUB %00000000          ; 86B6: 00          .
 EQUB %00000000          ; 86B7: 00          .
 EQUB %00001111          ; 86B8: 0F          .
 EQUB %00011111          ; 86B9: 1F          .
 EQUB %00011111          ; 86BA: 1F          .
 EQUB %11011110          ; 86BB: DE          .
 EQUB %11011101          ; 86BC: DD          .
 EQUB %10111100          ; 86BD: BC          .
 EQUB %10111111          ; 86BE: BF          .
 EQUB %10111100          ; 86BF: BC          .

; ******************************************************************************
;
;       Name: tile3_92
;       Type: Variable
;   Category: Drawing images
;    Summary: ???
;
; ******************************************************************************

.tile3_92

 EQUB %00000000          ; 86C0: 00          .
 EQUB %00000000          ; 86C1: 00          .
 EQUB %01000000          ; 86C2: 40          @
 EQUB %11100000          ; 86C3: E0          .
 EQUB %11110000          ; 86C4: F0          .
 EQUB %00000000          ; 86C5: 00          .
 EQUB %00000000          ; 86C6: 00          .
 EQUB %00000000          ; 86C7: 00          .
 EQUB %11111110          ; 86C8: FE          .
 EQUB %10111111          ; 86C9: BF          .
 EQUB %01011111          ; 86CA: 5F          _
 EQUB %11101111          ; 86CB: EF          .
 EQUB %11110111          ; 86CC: F7          .
 EQUB %00000111          ; 86CD: 07          .
 EQUB %11111111          ; 86CE: FF          .
 EQUB %00000111          ; 86CF: 07          .

; ******************************************************************************
;
;       Name: tile3_93
;       Type: Variable
;   Category: Drawing images
;    Summary: ???
;
; ******************************************************************************

.tile3_93

 EQUB %00000000          ; 86D0: 00          .
 EQUB %00000000          ; 86D1: 00          .
 EQUB %00000000          ; 86D2: 00          .
 EQUB %00100001          ; 86D3: 21          !
 EQUB %00110001          ; 86D4: 31          1
 EQUB %00111001          ; 86D5: 39          9
 EQUB %00110001          ; 86D6: 31          1
 EQUB %00100001          ; 86D7: 21          !
 EQUB %11111111          ; 86D8: FF          .
 EQUB %11111111          ; 86D9: FF          .
 EQUB %10011100          ; 86DA: 9C          .
 EQUB %10101101          ; 86DB: AD          .
 EQUB %10110101          ; 86DC: B5          .
 EQUB %10111001          ; 86DD: B9          .
 EQUB %10110101          ; 86DE: B5          .
 EQUB %10101101          ; 86DF: AD          .

; ******************************************************************************
;
;       Name: tile3_94
;       Type: Variable
;   Category: Drawing images
;    Summary: ???
;
; ******************************************************************************

.tile3_94

 EQUB %00000000          ; 86E0: 00          .
 EQUB %00000000          ; 86E1: 00          .
 EQUB %00000000          ; 86E2: 00          .
 EQUB %00000000          ; 86E3: 00          .
 EQUB %10000000          ; 86E4: 80          .
 EQUB %11000000          ; 86E5: C0          .
 EQUB %10000000          ; 86E6: 80          .
 EQUB %00000000          ; 86E7: 00          .
 EQUB %11100000          ; 86E8: E0          .
 EQUB %11110000          ; 86E9: F0          .
 EQUB %11110000          ; 86EA: F0          .
 EQUB %01110111          ; 86EB: 77          w
 EQUB %10110111          ; 86EC: B7          .
 EQUB %11011011          ; 86ED: DB          .
 EQUB %10111011          ; 86EE: BB          .
 EQUB %01111011          ; 86EF: 7B          {

; ******************************************************************************
;
;       Name: tile3_95
;       Type: Variable
;   Category: Drawing images
;    Summary: ???
;
; ******************************************************************************

.tile3_95

 EQUB %00000000          ; 86F0: 00          .
 EQUB %00000000          ; 86F1: 00          .
 EQUB %00000000          ; 86F2: 00          .
 EQUB %00100000          ; 86F3: 20
 EQUB %00011111          ; 86F4: 1F          .
 EQUB %00000000          ; 86F5: 00          .
 EQUB %00100000          ; 86F6: 20
 EQUB %00000000          ; 86F7: 00          .
 EQUB %00111111          ; 86F8: 3F          ?
 EQUB %00111111          ; 86F9: 3F          ?
 EQUB %00111111          ; 86FA: 3F          ?
 EQUB %00011111          ; 86FB: 1F          .
 EQUB %00100000          ; 86FC: 20
 EQUB %00000000          ; 86FD: 00          .
 EQUB %01011111          ; 86FE: 5F          _
 EQUB %01000000          ; 86FF: 40          @

; ******************************************************************************
;
;       Name: tile3_96
;       Type: Variable
;   Category: Drawing images
;    Summary: ???
;
; ******************************************************************************

.tile3_96

 EQUB %00000000          ; 8700: 00          .
 EQUB %00000000          ; 8701: 00          .
 EQUB %00000000          ; 8702: 00          .
 EQUB %00000000          ; 8703: 00          .
 EQUB %11111111          ; 8704: FF          .
 EQUB %00000000          ; 8705: 00          .
 EQUB %00000000          ; 8706: 00          .
 EQUB %00000000          ; 8707: 00          .
 EQUB %11111111          ; 8708: FF          .
 EQUB %11111111          ; 8709: FF          .
 EQUB %11111111          ; 870A: FF          .
 EQUB %11111111          ; 870B: FF          .
 EQUB %00000000          ; 870C: 00          .
 EQUB %00000000          ; 870D: 00          .
 EQUB %11111111          ; 870E: FF          .
 EQUB %00000000          ; 870F: 00          .

; ******************************************************************************
;
;       Name: tile3_97
;       Type: Variable
;   Category: Drawing images
;    Summary: ???
;
; ******************************************************************************

.tile3_97

 EQUB %00000000          ; 8710: 00          .
 EQUB %00000000          ; 8711: 00          .
 EQUB %00000000          ; 8712: 00          .
 EQUB %10000010          ; 8713: 82          .
 EQUB %00000001          ; 8714: 01          .
 EQUB %00010000          ; 8715: 10          .
 EQUB %10010010          ; 8716: 92          .
 EQUB %00010000          ; 8717: 10          .
 EQUB %10010011          ; 8718: 93          .
 EQUB %10010011          ; 8719: 93          .
 EQUB %10010011          ; 871A: 93          .
 EQUB %00010001          ; 871B: 11          .
 EQUB %10010010          ; 871C: 92          .
 EQUB %00000000          ; 871D: 00          .
 EQUB %01000101          ; 871E: 45          E
 EQUB %01000100          ; 871F: 44          D

; ******************************************************************************
;
;       Name: tile3_98
;       Type: Variable
;   Category: Drawing images
;    Summary: ???
;
; ******************************************************************************

.tile3_98

 EQUB %00000000          ; 8720: 00          .
 EQUB %00000000          ; 8721: 00          .
 EQUB %00000000          ; 8722: 00          .
 EQUB %00001000          ; 8723: 08          .
 EQUB %11110000          ; 8724: F0          .
 EQUB %00000001          ; 8725: 01          .
 EQUB %00001001          ; 8726: 09          .
 EQUB %00000001          ; 8727: 01          .
 EQUB %11111001          ; 8728: F9          .
 EQUB %11111001          ; 8729: F9          .
 EQUB %11111001          ; 872A: F9          .
 EQUB %11110001          ; 872B: F1          .
 EQUB %00001001          ; 872C: 09          .
 EQUB %00000000          ; 872D: 00          .
 EQUB %11110100          ; 872E: F4          .
 EQUB %00000100          ; 872F: 04          .

; ******************************************************************************
;
;       Name: tile3_99
;       Type: Variable
;   Category: Drawing images
;    Summary: ???
;
; ******************************************************************************

.tile3_99

 EQUB %00000000          ; 8730: 00          .
 EQUB %00000000          ; 8731: 00          .
 EQUB %00000000          ; 8732: 00          .
 EQUB %00000000          ; 8733: 00          .
 EQUB %00000000          ; 8734: 00          .
 EQUB %00000000          ; 8735: 00          .
 EQUB %00000001          ; 8736: 01          .
 EQUB %00001011          ; 8737: 0B          .
 EQUB %00001111          ; 8738: 0F          .
 EQUB %00001111          ; 8739: 0F          .
 EQUB %00011111          ; 873A: 1F          .
 EQUB %00011111          ; 873B: 1F          .
 EQUB %00111111          ; 873C: 3F          ?
 EQUB %00111111          ; 873D: 3F          ?
 EQUB %01111110          ; 873E: 7E          ~
 EQUB %01110100          ; 873F: 74          t

; ******************************************************************************
;
;       Name: tile3_100
;       Type: Variable
;   Category: Drawing images
;    Summary: ???
;
; ******************************************************************************

.tile3_100

 EQUB %00000000          ; 8740: 00          .
 EQUB %00000000          ; 8741: 00          .
 EQUB %00000000          ; 8742: 00          .
 EQUB %00000000          ; 8743: 00          .
 EQUB %00000000          ; 8744: 00          .
 EQUB %00000000          ; 8745: 00          .
 EQUB %10000000          ; 8746: 80          .
 EQUB %11010000          ; 8747: D0          .
 EQUB %11110000          ; 8748: F0          .
 EQUB %11110000          ; 8749: F0          .
 EQUB %11111000          ; 874A: F8          .
 EQUB %11111000          ; 874B: F8          .
 EQUB %11111100          ; 874C: FC          .
 EQUB %11111100          ; 874D: FC          .
 EQUB %01111110          ; 874E: 7E          ~
 EQUB %00101110          ; 874F: 2E          .

; ******************************************************************************
;
;       Name: tile3_101
;       Type: Variable
;   Category: Drawing images
;    Summary: ???
;
; ******************************************************************************

.tile3_101

 EQUB %00000100          ; 8750: 04          .
 EQUB %00000001          ; 8751: 01          .
 EQUB %00000000          ; 8752: 00          .
 EQUB %00100000          ; 8753: 20
 EQUB %00011111          ; 8754: 1F          .
 EQUB %00000000          ; 8755: 00          .
 EQUB %00100000          ; 8756: 20
 EQUB %00000000          ; 8757: 00          .
 EQUB %00110101          ; 8758: 35          5
 EQUB %00110000          ; 8759: 30          0
 EQUB %00111100          ; 875A: 3C          <
 EQUB %00011111          ; 875B: 1F          .
 EQUB %00100000          ; 875C: 20
 EQUB %00000000          ; 875D: 00          .
 EQUB %01011111          ; 875E: 5F          _
 EQUB %01000000          ; 875F: 40          @

; ******************************************************************************
;
;       Name: tile3_102
;       Type: Variable
;   Category: Drawing images
;    Summary: ???
;
; ******************************************************************************

.tile3_102

 EQUB %00100000          ; 8760: 20
 EQUB %00000000          ; 8761: 00          .
 EQUB %00000000          ; 8762: 00          .
 EQUB %00000000          ; 8763: 00          .
 EQUB %11111111          ; 8764: FF          .
 EQUB %00000000          ; 8765: 00          .
 EQUB %00000000          ; 8766: 00          .
 EQUB %00000000          ; 8767: 00          .
 EQUB %01010101          ; 8768: 55          U
 EQUB %10101101          ; 8769: AD          .
 EQUB %00000001          ; 876A: 01          .
 EQUB %11111111          ; 876B: FF          .
 EQUB %00000000          ; 876C: 00          .
 EQUB %00000000          ; 876D: 00          .
 EQUB %11111111          ; 876E: FF          .
 EQUB %00000000          ; 876F: 00          .

; ******************************************************************************
;
;       Name: tile3_103
;       Type: Variable
;   Category: Drawing images
;    Summary: ???
;
; ******************************************************************************

.tile3_103

 EQUB %00100010          ; 8770: 22          "
 EQUB %01010100          ; 8771: 54          T
 EQUB %00001000          ; 8772: 08          .
 EQUB %00000000          ; 8773: 00          .
 EQUB %11111111          ; 8774: FF          .
 EQUB %00000000          ; 8775: 00          .
 EQUB %00000000          ; 8776: 00          .
 EQUB %00000000          ; 8777: 00          .
 EQUB %01111111          ; 8778: 7F          .
 EQUB %01111111          ; 8779: 7F          .
 EQUB %00001000          ; 877A: 08          .
 EQUB %11111111          ; 877B: FF          .
 EQUB %00000000          ; 877C: 00          .
 EQUB %00000000          ; 877D: 00          .
 EQUB %11111111          ; 877E: FF          .
 EQUB %00000000          ; 877F: 00          .

; ******************************************************************************
;
;       Name: tile3_104
;       Type: Variable
;   Category: Drawing images
;    Summary: ???
;
; ******************************************************************************

.tile3_104

 EQUB %00000000          ; 8780: 00          .
 EQUB %00000000          ; 8781: 00          .
 EQUB %00000000          ; 8782: 00          .
 EQUB %00001000          ; 8783: 08          .
 EQUB %11110000          ; 8784: F0          .
 EQUB %00000001          ; 8785: 01          .
 EQUB %00001001          ; 8786: 09          .
 EQUB %00000001          ; 8787: 01          .
 EQUB %11111001          ; 8788: F9          .
 EQUB %11111001          ; 8789: F9          .
 EQUB %00011001          ; 878A: 19          .
 EQUB %11110001          ; 878B: F1          .
 EQUB %00001001          ; 878C: 09          .
 EQUB %00000000          ; 878D: 00          .
 EQUB %11110100          ; 878E: F4          .
 EQUB %00000100          ; 878F: 04          .

; ******************************************************************************
;
;       Name: tile3_105
;       Type: Variable
;   Category: Drawing images
;    Summary: ???
;
; ******************************************************************************

.tile3_105

 EQUB %00000000          ; 8790: 00          .
 EQUB %00000000          ; 8791: 00          .
 EQUB %00000000          ; 8792: 00          .
 EQUB %00100000          ; 8793: 20
 EQUB %00011111          ; 8794: 1F          .
 EQUB %00000000          ; 8795: 00          .
 EQUB %00100000          ; 8796: 20
 EQUB %00000000          ; 8797: 00          .
 EQUB %00100101          ; 8798: 25          %
 EQUB %00101101          ; 8799: 2D          -
 EQUB %00100100          ; 879A: 24          $
 EQUB %00011111          ; 879B: 1F          .
 EQUB %00100000          ; 879C: 20
 EQUB %00000000          ; 879D: 00          .
 EQUB %01011111          ; 879E: 5F          _
 EQUB %01000000          ; 879F: 40          @

; ******************************************************************************
;
;       Name: tile3_106
;       Type: Variable
;   Category: Drawing images
;    Summary: ???
;
; ******************************************************************************

.tile3_106

 EQUB %00000000          ; 87A0: 00          .
 EQUB %00000000          ; 87A1: 00          .
 EQUB %00000000          ; 87A2: 00          .
 EQUB %00000000          ; 87A3: 00          .
 EQUB %11111111          ; 87A4: FF          .
 EQUB %00000000          ; 87A5: 00          .
 EQUB %00000000          ; 87A6: 00          .
 EQUB %00000000          ; 87A7: 00          .
 EQUB %10110100          ; 87A8: B4          .
 EQUB %10110101          ; 87A9: B5          .
 EQUB %10110100          ; 87AA: B4          .
 EQUB %11111111          ; 87AB: FF          .
 EQUB %00000000          ; 87AC: 00          .
 EQUB %00000000          ; 87AD: 00          .
 EQUB %11111111          ; 87AE: FF          .
 EQUB %00000000          ; 87AF: 00          .

; ******************************************************************************
;
;       Name: tile3_107
;       Type: Variable
;   Category: Drawing images
;    Summary: ???
;
; ******************************************************************************

.tile3_107

 EQUB %01000001          ; 87B0: 41          A
 EQUB %01100011          ; 87B1: 63          c
 EQUB %00011100          ; 87B2: 1C          .
 EQUB %00000000          ; 87B3: 00          .
 EQUB %11111111          ; 87B4: FF          .
 EQUB %00000000          ; 87B5: 00          .
 EQUB %00000000          ; 87B6: 00          .
 EQUB %00000000          ; 87B7: 00          .
 EQUB %11111111          ; 87B8: FF          .
 EQUB %11111111          ; 87B9: FF          .
 EQUB %11111111          ; 87BA: FF          .
 EQUB %11111111          ; 87BB: FF          .
 EQUB %00000000          ; 87BC: 00          .
 EQUB %00000000          ; 87BD: 00          .
 EQUB %11111111          ; 87BE: FF          .
 EQUB %00000000          ; 87BF: 00          .

; ******************************************************************************
;
;       Name: tile3_108
;       Type: Variable
;   Category: Drawing images
;    Summary: ???
;
; ******************************************************************************

.tile3_108

 EQUB %00000000          ; 87C0: 00          .
 EQUB %00100000          ; 87C1: 20
 EQUB %00000000          ; 87C2: 00          .
 EQUB %00001000          ; 87C3: 08          .
 EQUB %11110000          ; 87C4: F0          .
 EQUB %00000001          ; 87C5: 01          .
 EQUB %00001001          ; 87C6: 09          .
 EQUB %00000001          ; 87C7: 01          .
 EQUB %11111001          ; 87C8: F9          .
 EQUB %11011001          ; 87C9: D9          .
 EQUB %11111001          ; 87CA: F9          .
 EQUB %11110001          ; 87CB: F1          .
 EQUB %00001001          ; 87CC: 09          .
 EQUB %00000000          ; 87CD: 00          .
 EQUB %11110100          ; 87CE: F4          .
 EQUB %00000100          ; 87CF: 04          .

; ******************************************************************************
;
;       Name: tile3_109
;       Type: Variable
;   Category: Drawing images
;    Summary: ???
;
; ******************************************************************************

.tile3_109

 EQUB %00000110          ; 87D0: 06          .
 EQUB %00011100          ; 87D1: 1C          .
 EQUB %00001000          ; 87D2: 08          .
 EQUB %00100000          ; 87D3: 20
 EQUB %00011111          ; 87D4: 1F          .
 EQUB %00000000          ; 87D5: 00          .
 EQUB %00100000          ; 87D6: 20
 EQUB %00000000          ; 87D7: 00          .
 EQUB %00111111          ; 87D8: 3F          ?
 EQUB %00111111          ; 87D9: 3F          ?
 EQUB %00111111          ; 87DA: 3F          ?
 EQUB %00011111          ; 87DB: 1F          .
 EQUB %00100000          ; 87DC: 20
 EQUB %00000000          ; 87DD: 00          .
 EQUB %01011111          ; 87DE: 5F          _
 EQUB %01000000          ; 87DF: 40          @

; ******************************************************************************
;
;       Name: tile3_110
;       Type: Variable
;   Category: Drawing images
;    Summary: ???
;
; ******************************************************************************

.tile3_110

 EQUB %00001100          ; 87E0: 0C          .
 EQUB %01000111          ; 87E1: 47          G
 EQUB %00000010          ; 87E2: 02          .
 EQUB %00000000          ; 87E3: 00          .
 EQUB %11111111          ; 87E4: FF          .
 EQUB %00000000          ; 87E5: 00          .
 EQUB %00000000          ; 87E6: 00          .
 EQUB %00000000          ; 87E7: 00          .
 EQUB %11111111          ; 87E8: FF          .
 EQUB %10111111          ; 87E9: BF          .
 EQUB %11111111          ; 87EA: FF          .
 EQUB %11111111          ; 87EB: FF          .
 EQUB %00000000          ; 87EC: 00          .
 EQUB %00000000          ; 87ED: 00          .
 EQUB %11111111          ; 87EE: FF          .
 EQUB %00000000          ; 87EF: 00          .

; ******************************************************************************
;
;       Name: tile3_111
;       Type: Variable
;   Category: Drawing images
;    Summary: ???
;
; ******************************************************************************

.tile3_111

 EQUB %00100111          ; 87F0: 27          '
 EQUB %00000011          ; 87F1: 03          .
 EQUB %00000000          ; 87F2: 00          .
 EQUB %00000000          ; 87F3: 00          .
 EQUB %11111111          ; 87F4: FF          .
 EQUB %00000000          ; 87F5: 00          .
 EQUB %00000000          ; 87F6: 00          .
 EQUB %00000000          ; 87F7: 00          .
 EQUB %10100111          ; 87F8: A7          .
 EQUB %11010010          ; 87F9: D2          .
 EQUB %11111100          ; 87FA: FC          .
 EQUB %11111111          ; 87FB: FF          .
 EQUB %00000000          ; 87FC: 00          .
 EQUB %00000000          ; 87FD: 00          .
 EQUB %11111111          ; 87FE: FF          .
 EQUB %00000000          ; 87FF: 00          .

; ******************************************************************************
;
;       Name: tile3_112
;       Type: Variable
;   Category: Drawing images
;    Summary: ???
;
; ******************************************************************************

.tile3_112

 EQUB %11000000          ; 8800: C0          .
 EQUB %10000000          ; 8801: 80          .
 EQUB %00000000          ; 8802: 00          .
 EQUB %00001000          ; 8803: 08          .
 EQUB %11110000          ; 8804: F0          .
 EQUB %00000001          ; 8805: 01          .
 EQUB %00001001          ; 8806: 09          .
 EQUB %00000001          ; 8807: 01          .
 EQUB %01011001          ; 8808: 59          Y
 EQUB %10011001          ; 8809: 99          .
 EQUB %01111001          ; 880A: 79          y
 EQUB %11110001          ; 880B: F1          .
 EQUB %00001001          ; 880C: 09          .
 EQUB %00000000          ; 880D: 00          .
 EQUB %11110100          ; 880E: F4          .
 EQUB %00000100          ; 880F: 04          .

; ******************************************************************************
;
;       Name: tile3_113
;       Type: Variable
;   Category: Drawing images
;    Summary: ???
;
; ******************************************************************************

.tile3_113

 EQUB %00000000          ; 8810: 00          .
 EQUB %00000000          ; 8811: 00          .
 EQUB %00000000          ; 8812: 00          .
 EQUB %00100000          ; 8813: 20
 EQUB %00011111          ; 8814: 1F          .
 EQUB %00000000          ; 8815: 00          .
 EQUB %00100000          ; 8816: 20
 EQUB %00000000          ; 8817: 00          .
 EQUB %00111110          ; 8818: 3E          >
 EQUB %00111111          ; 8819: 3F          ?
 EQUB %00111111          ; 881A: 3F          ?
 EQUB %00011111          ; 881B: 1F          .
 EQUB %00100000          ; 881C: 20
 EQUB %00000000          ; 881D: 00          .
 EQUB %01011111          ; 881E: 5F          _
 EQUB %01000000          ; 881F: 40          @

; ******************************************************************************
;
;       Name: tile3_114
;       Type: Variable
;   Category: Drawing images
;    Summary: ???
;
; ******************************************************************************

.tile3_114

 EQUB %10000000          ; 8820: 80          .
 EQUB %00000000          ; 8821: 00          .
 EQUB %00000000          ; 8822: 00          .
 EQUB %00000000          ; 8823: 00          .
 EQUB %11111111          ; 8824: FF          .
 EQUB %00000000          ; 8825: 00          .
 EQUB %00000000          ; 8826: 00          .
 EQUB %00000000          ; 8827: 00          .
 EQUB %00101101          ; 8828: 2D          -
 EQUB %01111111          ; 8829: 7F          .
 EQUB %11111111          ; 882A: FF          .
 EQUB %11111111          ; 882B: FF          .
 EQUB %00000000          ; 882C: 00          .
 EQUB %00000000          ; 882D: 00          .
 EQUB %11111111          ; 882E: FF          .
 EQUB %00000000          ; 882F: 00          .

; ******************************************************************************
;
;       Name: tile3_115
;       Type: Variable
;   Category: Drawing images
;    Summary: ???
;
; ******************************************************************************

.tile3_115

 EQUB %10010000          ; 8830: 90          .
 EQUB %00110000          ; 8831: 30          0
 EQUB %00100000          ; 8832: 20
 EQUB %00000000          ; 8833: 00          .
 EQUB %11111111          ; 8834: FF          .
 EQUB %00000000          ; 8835: 00          .
 EQUB %00000000          ; 8836: 00          .
 EQUB %00000000          ; 8837: 00          .
 EQUB %00001001          ; 8838: 09          .
 EQUB %10001110          ; 8839: 8E          .
 EQUB %11011110          ; 883A: DE          .
 EQUB %11111111          ; 883B: FF          .
 EQUB %00000000          ; 883C: 00          .
 EQUB %00000000          ; 883D: 00          .
 EQUB %11111111          ; 883E: FF          .
 EQUB %00000000          ; 883F: 00          .

; ******************************************************************************
;
;       Name: tile3_116
;       Type: Variable
;   Category: Drawing images
;    Summary: ???
;
; ******************************************************************************

.tile3_116

 EQUB %00000000          ; 8840: 00          .
 EQUB %00000000          ; 8841: 00          .
 EQUB %00000000          ; 8842: 00          .
 EQUB %00001000          ; 8843: 08          .
 EQUB %11110000          ; 8844: F0          .
 EQUB %00000001          ; 8845: 01          .
 EQUB %00001001          ; 8846: 09          .
 EQUB %00000001          ; 8847: 01          .
 EQUB %00111001          ; 8848: 39          9
 EQUB %11111001          ; 8849: F9          .
 EQUB %11111001          ; 884A: F9          .
 EQUB %11110001          ; 884B: F1          .
 EQUB %00001001          ; 884C: 09          .
 EQUB %00000000          ; 884D: 00          .
 EQUB %11110100          ; 884E: F4          .
 EQUB %00000100          ; 884F: 04          .

; ******************************************************************************
;
;       Name: tile3_117
;       Type: Variable
;   Category: Drawing images
;    Summary: ???
;
; ******************************************************************************

.tile3_117

 EQUB %00000100          ; 8850: 04          .
 EQUB %00000110          ; 8851: 06          .
 EQUB %00000000          ; 8852: 00          .
 EQUB %00100000          ; 8853: 20
 EQUB %00011111          ; 8854: 1F          .
 EQUB %00000000          ; 8855: 00          .
 EQUB %00100000          ; 8856: 20
 EQUB %00000000          ; 8857: 00          .
 EQUB %00110100          ; 8858: 34          4
 EQUB %00110110          ; 8859: 36          6
 EQUB %00110001          ; 885A: 31          1
 EQUB %00011111          ; 885B: 1F          .
 EQUB %00100000          ; 885C: 20
 EQUB %00000000          ; 885D: 00          .
 EQUB %01011111          ; 885E: 5F          _
 EQUB %01000000          ; 885F: 40          @

; ******************************************************************************
;
;       Name: tile3_118
;       Type: Variable
;   Category: Drawing images
;    Summary: ???
;
; ******************************************************************************

.tile3_118

 EQUB %11000000          ; 8860: C0          .
 EQUB %10000000          ; 8861: 80          .
 EQUB %00000000          ; 8862: 00          .
 EQUB %00000000          ; 8863: 00          .
 EQUB %11111111          ; 8864: FF          .
 EQUB %00000000          ; 8865: 00          .
 EQUB %00000000          ; 8866: 00          .
 EQUB %00000000          ; 8867: 00          .
 EQUB %00111111          ; 8868: 3F          ?
 EQUB %01111111          ; 8869: 7F          .
 EQUB %11111111          ; 886A: FF          .
 EQUB %11111111          ; 886B: FF          .
 EQUB %00000000          ; 886C: 00          .
 EQUB %00000000          ; 886D: 00          .
 EQUB %11111111          ; 886E: FF          .
 EQUB %00000000          ; 886F: 00          .

; ******************************************************************************
;
;       Name: tile3_119
;       Type: Variable
;   Category: Drawing images
;    Summary: ???
;
; ******************************************************************************

.tile3_119

 EQUB %00100100          ; 8870: 24          $
 EQUB %00000000          ; 8871: 00          .
 EQUB %00000000          ; 8872: 00          .
 EQUB %00000000          ; 8873: 00          .
 EQUB %11111111          ; 8874: FF          .
 EQUB %00000000          ; 8875: 00          .
 EQUB %00000000          ; 8876: 00          .
 EQUB %00000000          ; 8877: 00          .
 EQUB %11111011          ; 8878: FB          .
 EQUB %10111011          ; 8879: BB          .
 EQUB %11111111          ; 887A: FF          .
 EQUB %11111111          ; 887B: FF          .
 EQUB %00000000          ; 887C: 00          .
 EQUB %00000000          ; 887D: 00          .
 EQUB %11111111          ; 887E: FF          .
 EQUB %00000000          ; 887F: 00          .

; ******************************************************************************
;
;       Name: tile3_120
;       Type: Variable
;   Category: Drawing images
;    Summary: ???
;
; ******************************************************************************

.tile3_120

 EQUB %10000000          ; 8880: 80          .
 EQUB %00000000          ; 8881: 00          .
 EQUB %00000000          ; 8882: 00          .
 EQUB %00001000          ; 8883: 08          .
 EQUB %11110000          ; 8884: F0          .
 EQUB %00000001          ; 8885: 01          .
 EQUB %00001001          ; 8886: 09          .
 EQUB %00000001          ; 8887: 01          .
 EQUB %11111001          ; 8888: F9          .
 EQUB %10111001          ; 8889: B9          .
 EQUB %11111001          ; 888A: F9          .
 EQUB %11110001          ; 888B: F1          .
 EQUB %00001001          ; 888C: 09          .
 EQUB %00000000          ; 888D: 00          .
 EQUB %11110100          ; 888E: F4          .
 EQUB %00000100          ; 888F: 04          .

; ******************************************************************************
;
;       Name: tile3_121
;       Type: Variable
;   Category: Drawing images
;    Summary: ???
;
; ******************************************************************************

.tile3_121

 EQUB %00000001          ; 8890: 01          .
 EQUB %00000000          ; 8891: 00          .
 EQUB %00000000          ; 8892: 00          .
 EQUB %00100000          ; 8893: 20
 EQUB %00011111          ; 8894: 1F          .
 EQUB %00000000          ; 8895: 00          .
 EQUB %00100000          ; 8896: 20
 EQUB %00000000          ; 8897: 00          .
 EQUB %00111101          ; 8898: 3D          =
 EQUB %00111100          ; 8899: 3C          <
 EQUB %00111111          ; 889A: 3F          ?
 EQUB %00011111          ; 889B: 1F          .
 EQUB %00100000          ; 889C: 20
 EQUB %00000000          ; 889D: 00          .
 EQUB %01011111          ; 889E: 5F          _
 EQUB %01000000          ; 889F: 40          @

; ******************************************************************************
;
;       Name: tile3_122
;       Type: Variable
;   Category: Drawing images
;    Summary: ???
;
; ******************************************************************************

.tile3_122

 EQUB %11110000          ; 88A0: F0          .
 EQUB %00000000          ; 88A1: 00          .
 EQUB %00000000          ; 88A2: 00          .
 EQUB %00000000          ; 88A3: 00          .
 EQUB %11111111          ; 88A4: FF          .
 EQUB %00000000          ; 88A5: 00          .
 EQUB %00000000          ; 88A6: 00          .
 EQUB %00000000          ; 88A7: 00          .
 EQUB %11110111          ; 88A8: F7          .
 EQUB %00000111          ; 88A9: 07          .
 EQUB %11111111          ; 88AA: FF          .
 EQUB %11111111          ; 88AB: FF          .
 EQUB %00000000          ; 88AC: 00          .
 EQUB %00000000          ; 88AD: 00          .
 EQUB %11111111          ; 88AE: FF          .
 EQUB %00000000          ; 88AF: 00          .

; ******************************************************************************
;
;       Name: tile3_123
;       Type: Variable
;   Category: Drawing images
;    Summary: ???
;
; ******************************************************************************

.tile3_123

 EQUB %00000000          ; 88B0: 00          .
 EQUB %00000000          ; 88B1: 00          .
 EQUB %00000000          ; 88B2: 00          .
 EQUB %00000000          ; 88B3: 00          .
 EQUB %11111111          ; 88B4: FF          .
 EQUB %00000000          ; 88B5: 00          .
 EQUB %00000000          ; 88B6: 00          .
 EQUB %00000000          ; 88B7: 00          .
 EQUB %10011100          ; 88B8: 9C          .
 EQUB %11111111          ; 88B9: FF          .
 EQUB %11111111          ; 88BA: FF          .
 EQUB %11111111          ; 88BB: FF          .
 EQUB %00000000          ; 88BC: 00          .
 EQUB %00000000          ; 88BD: 00          .
 EQUB %11111111          ; 88BE: FF          .
 EQUB %00000000          ; 88BF: 00          .

; ******************************************************************************
;
;       Name: tile3_124
;       Type: Variable
;   Category: Drawing images
;    Summary: ???
;
; ******************************************************************************

.tile3_124

 EQUB %00000000          ; 88C0: 00          .
 EQUB %00000000          ; 88C1: 00          .
 EQUB %00000000          ; 88C2: 00          .
 EQUB %00000000          ; 88C3: 00          .
 EQUB %00000000          ; 88C4: 00          .
 EQUB %00000000          ; 88C5: 00          .
 EQUB %00000000          ; 88C6: 00          .
 EQUB %00000000          ; 88C7: 00          .
 EQUB %00000000          ; 88C8: 00          .
 EQUB %00000000          ; 88C9: 00          .
 EQUB %00000000          ; 88CA: 00          .
 EQUB %00000000          ; 88CB: 00          .
 EQUB %00000000          ; 88CC: 00          .
 EQUB %00000000          ; 88CD: 00          .
 EQUB %00000000          ; 88CE: 00          .
 EQUB %00000000          ; 88CF: 00          .

; ******************************************************************************
;
;       Name: tile3_125
;       Type: Variable
;   Category: Drawing images
;    Summary: ???
;
; ******************************************************************************

.tile3_125

 EQUB %00000000          ; 88D0: 00          .
 EQUB %00000000          ; 88D1: 00          .
 EQUB %00000000          ; 88D2: 00          .
 EQUB %00000000          ; 88D3: 00          .
 EQUB %00000000          ; 88D4: 00          .
 EQUB %00000000          ; 88D5: 00          .
 EQUB %00000000          ; 88D6: 00          .
 EQUB %00000000          ; 88D7: 00          .
 EQUB %00000000          ; 88D8: 00          .
 EQUB %00000000          ; 88D9: 00          .
 EQUB %00000000          ; 88DA: 00          .
 EQUB %00000000          ; 88DB: 00          .
 EQUB %00000000          ; 88DC: 00          .
 EQUB %00000000          ; 88DD: 00          .
 EQUB %00000000          ; 88DE: 00          .
 EQUB %00000000          ; 88DF: 00          .

; ******************************************************************************
;
;       Name: tile3_126
;       Type: Variable
;   Category: Drawing images
;    Summary: ???
;
; ******************************************************************************

.tile3_126

 EQUB %00000000          ; 88E0: 00          .
 EQUB %00000000          ; 88E1: 00          .
 EQUB %00000000          ; 88E2: 00          .
 EQUB %00000000          ; 88E3: 00          .
 EQUB %00000000          ; 88E4: 00          .
 EQUB %00000000          ; 88E5: 00          .
 EQUB %00000000          ; 88E6: 00          .
 EQUB %00000000          ; 88E7: 00          .
 EQUB %00000000          ; 88E8: 00          .
 EQUB %00000000          ; 88E9: 00          .
 EQUB %00000000          ; 88EA: 00          .
 EQUB %00000000          ; 88EB: 00          .
 EQUB %00000000          ; 88EC: 00          .
 EQUB %00000000          ; 88ED: 00          .
 EQUB %00000000          ; 88EE: 00          .
 EQUB %00000000          ; 88EF: 00          .

; ******************************************************************************
;
;       Name: tile3_127
;       Type: Variable
;   Category: Drawing images
;    Summary: ???
;
; ******************************************************************************

.tile3_127

 EQUB %00000000          ; 88F0: 00          .
 EQUB %00000000          ; 88F1: 00          .
 EQUB %00000000          ; 88F2: 00          .
 EQUB %00000000          ; 88F3: 00          .
 EQUB %00000000          ; 88F4: 00          .
 EQUB %00000000          ; 88F5: 00          .
 EQUB %00000000          ; 88F6: 00          .
 EQUB %00000000          ; 88F7: 00          .
 EQUB %00000000          ; 88F8: 00          .
 EQUB %00000000          ; 88F9: 00          .
 EQUB %00000000          ; 88FA: 00          .
 EQUB %00000000          ; 88FB: 00          .
 EQUB %00000000          ; 88FC: 00          .
 EQUB %00000000          ; 88FD: 00          .
 EQUB %00000000          ; 88FE: 00          .
 EQUB %00000000          ; 88FF: 00          .

; ******************************************************************************
;
;       Name: tile3_128
;       Type: Variable
;   Category: Drawing images
;    Summary: ???
;
; ******************************************************************************

.tile3_128

 EQUB %00000000          ; 8900: 00          .
 EQUB %00000000          ; 8901: 00          .
 EQUB %00000000          ; 8902: 00          .
 EQUB %00000000          ; 8903: 00          .
 EQUB %00000000          ; 8904: 00          .
 EQUB %00000000          ; 8905: 00          .
 EQUB %00000000          ; 8906: 00          .
 EQUB %00000000          ; 8907: 00          .
 EQUB %11111110          ; 8908: FE          .
 EQUB %11111111          ; 8909: FF          .
 EQUB %11111111          ; 890A: FF          .
 EQUB %11111111          ; 890B: FF          .
 EQUB %11111111          ; 890C: FF          .
 EQUB %11111111          ; 890D: FF          .
 EQUB %11111111          ; 890E: FF          .
 EQUB %11111111          ; 890F: FF          .

; ******************************************************************************
;
;       Name: tile3_129
;       Type: Variable
;   Category: Drawing images
;    Summary: ???
;
; ******************************************************************************

.tile3_129

 EQUB %00000000          ; 8910: 00          .
 EQUB %00000000          ; 8911: 00          .
 EQUB %00000000          ; 8912: 00          .
 EQUB %00000000          ; 8913: 00          .
 EQUB %00000000          ; 8914: 00          .
 EQUB %00000000          ; 8915: 00          .
 EQUB %00000000          ; 8916: 00          .
 EQUB %00000000          ; 8917: 00          .
 EQUB %00000000          ; 8918: 00          .
 EQUB %00000001          ; 8919: 01          .
 EQUB %00000001          ; 891A: 01          .
 EQUB %01111101          ; 891B: 7D          }
 EQUB %01111101          ; 891C: 7D          }
 EQUB %10111011          ; 891D: BB          .
 EQUB %10111011          ; 891E: BB          .
 EQUB %10111011          ; 891F: BB          .

; ******************************************************************************
;
;       Name: tile3_130
;       Type: Variable
;   Category: Drawing images
;    Summary: ???
;
; ******************************************************************************

.tile3_130

 EQUB %00000000          ; 8920: 00          .
 EQUB %00000000          ; 8921: 00          .
 EQUB %00000000          ; 8922: 00          .
 EQUB %00000000          ; 8923: 00          .
 EQUB %00000000          ; 8924: 00          .
 EQUB %00000000          ; 8925: 00          .
 EQUB %00000000          ; 8926: 00          .
 EQUB %00000000          ; 8927: 00          .
 EQUB %11111111          ; 8928: FF          .
 EQUB %11111111          ; 8929: FF          .
 EQUB %11111111          ; 892A: FF          .
 EQUB %11111111          ; 892B: FF          .
 EQUB %11111111          ; 892C: FF          .
 EQUB %11111111          ; 892D: FF          .
 EQUB %11111111          ; 892E: FF          .
 EQUB %11111111          ; 892F: FF          .

; ******************************************************************************
;
;       Name: tile3_131
;       Type: Variable
;   Category: Drawing images
;    Summary: ???
;
; ******************************************************************************

.tile3_131

 EQUB %00000000          ; 8930: 00          .
 EQUB %00000000          ; 8931: 00          .
 EQUB %00000000          ; 8932: 00          .
 EQUB %00000000          ; 8933: 00          .
 EQUB %00000000          ; 8934: 00          .
 EQUB %00000000          ; 8935: 00          .
 EQUB %00000000          ; 8936: 00          .
 EQUB %00000000          ; 8937: 00          .
 EQUB %11100000          ; 8938: E0          .
 EQUB %11110000          ; 8939: F0          .
 EQUB %11110000          ; 893A: F0          .
 EQUB %11110111          ; 893B: F7          .
 EQUB %11110111          ; 893C: F7          .
 EQUB %11111011          ; 893D: FB          .
 EQUB %11111011          ; 893E: FB          .
 EQUB %11111011          ; 893F: FB          .

; ******************************************************************************
;
;       Name: tile3_132
;       Type: Variable
;   Category: Drawing images
;    Summary: ???
;
; ******************************************************************************

.tile3_132

 EQUB %00000000          ; 8940: 00          .
 EQUB %00000000          ; 8941: 00          .
 EQUB %00000000          ; 8942: 00          .
 EQUB %00000000          ; 8943: 00          .
 EQUB %00000000          ; 8944: 00          .
 EQUB %00000000          ; 8945: 00          .
 EQUB %00000000          ; 8946: 00          .
 EQUB %00000000          ; 8947: 00          .
 EQUB %00000011          ; 8948: 03          .
 EQUB %00000011          ; 8949: 03          .
 EQUB %00000011          ; 894A: 03          .
 EQUB %00000011          ; 894B: 03          .
 EQUB %00000011          ; 894C: 03          .
 EQUB %00000011          ; 894D: 03          .
 EQUB %00000111          ; 894E: 07          .
 EQUB %00000111          ; 894F: 07          .

; ******************************************************************************
;
;       Name: tile3_133
;       Type: Variable
;   Category: Drawing images
;    Summary: ???
;
; ******************************************************************************

.tile3_133

 EQUB %00000000          ; 8950: 00          .
 EQUB %00000000          ; 8951: 00          .
 EQUB %00000000          ; 8952: 00          .
 EQUB %00000000          ; 8953: 00          .
 EQUB %00000000          ; 8954: 00          .
 EQUB %00000000          ; 8955: 00          .
 EQUB %00000000          ; 8956: 00          .
 EQUB %00000000          ; 8957: 00          .
 EQUB %11000000          ; 8958: C0          .
 EQUB %11000000          ; 8959: C0          .
 EQUB %11000000          ; 895A: C0          .
 EQUB %11000000          ; 895B: C0          .
 EQUB %11000000          ; 895C: C0          .
 EQUB %11000000          ; 895D: C0          .
 EQUB %11100000          ; 895E: E0          .
 EQUB %11100000          ; 895F: E0          .

; ******************************************************************************
;
;       Name: tile3_134
;       Type: Variable
;   Category: Drawing images
;    Summary: ???
;
; ******************************************************************************

.tile3_134

 EQUB %00000000          ; 8960: 00          .
 EQUB %00000000          ; 8961: 00          .
 EQUB %00000000          ; 8962: 00          .
 EQUB %00000000          ; 8963: 00          .
 EQUB %00000010          ; 8964: 02          .
 EQUB %00000110          ; 8965: 06          .
 EQUB %00001110          ; 8966: 0E          .
 EQUB %00000110          ; 8967: 06          .
 EQUB %00001111          ; 8968: 0F          .
 EQUB %00011111          ; 8969: 1F          .
 EQUB %00011100          ; 896A: 1C          .
 EQUB %11011100          ; 896B: DC          .
 EQUB %11011010          ; 896C: DA          .
 EQUB %10110110          ; 896D: B6          .
 EQUB %10101110          ; 896E: AE          .
 EQUB %10110110          ; 896F: B6          .

; ******************************************************************************
;
;       Name: tile3_135
;       Type: Variable
;   Category: Drawing images
;    Summary: ???
;
; ******************************************************************************

.tile3_135

 EQUB %00000000          ; 8970: 00          .
 EQUB %00000000          ; 8971: 00          .
 EQUB %00000000          ; 8972: 00          .
 EQUB %10000100          ; 8973: 84          .
 EQUB %00100000          ; 8974: 20
 EQUB %01010000          ; 8975: 50          P
 EQUB %10001000          ; 8976: 88          .
 EQUB %01010000          ; 8977: 50          P
 EQUB %11111110          ; 8978: FE          .
 EQUB %11111111          ; 8979: FF          .
 EQUB %00000001          ; 897A: 01          .
 EQUB %00101001          ; 897B: 29          )
 EQUB %01010101          ; 897C: 55          U
 EQUB %10101001          ; 897D: A9          .
 EQUB %00000101          ; 897E: 05          .
 EQUB %10101001          ; 897F: A9          .

; ******************************************************************************
;
;       Name: tile3_136
;       Type: Variable
;   Category: Drawing images
;    Summary: ???
;
; ******************************************************************************

.tile3_136

 EQUB %00000000          ; 8980: 00          .
 EQUB %00000000          ; 8981: 00          .
 EQUB %00000000          ; 8982: 00          .
 EQUB %00000000          ; 8983: 00          .
 EQUB %00000000          ; 8984: 00          .
 EQUB %00000000          ; 8985: 00          .
 EQUB %00000000          ; 8986: 00          .
 EQUB %00000001          ; 8987: 01          .
 EQUB %11111111          ; 8988: FF          .
 EQUB %11110111          ; 8989: F7          .
 EQUB %01100001          ; 898A: 61          a
 EQUB %01010111          ; 898B: 57          W
 EQUB %01000001          ; 898C: 41          A
 EQUB %01110101          ; 898D: 75          u
 EQUB %01000011          ; 898E: 43          C
 EQUB %01110111          ; 898F: 77          w

; ******************************************************************************
;
;       Name: tile3_137
;       Type: Variable
;   Category: Drawing images
;    Summary: ???
;
; ******************************************************************************

.tile3_137

 EQUB %00000000          ; 8990: 00          .
 EQUB %00000000          ; 8991: 00          .
 EQUB %00000000          ; 8992: 00          .
 EQUB %00000000          ; 8993: 00          .
 EQUB %00000000          ; 8994: 00          .
 EQUB %01000000          ; 8995: 40          @
 EQUB %10100000          ; 8996: A0          .
 EQUB %00000000          ; 8997: 00          .
 EQUB %11100000          ; 8998: E0          .
 EQUB %11110000          ; 8999: F0          .
 EQUB %11110000          ; 899A: F0          .
 EQUB %11110111          ; 899B: F7          .
 EQUB %11110111          ; 899C: F7          .
 EQUB %11111011          ; 899D: FB          .
 EQUB %11111011          ; 899E: FB          .
 EQUB %11111011          ; 899F: FB          .

; ******************************************************************************
;
;       Name: tile3_138
;       Type: Variable
;   Category: Drawing images
;    Summary: ???
;
; ******************************************************************************

.tile3_138

 EQUB %00000000          ; 89A0: 00          .
 EQUB %00000000          ; 89A1: 00          .
 EQUB %00000001          ; 89A2: 01          .
 EQUB %00000110          ; 89A3: 06          .
 EQUB %00000100          ; 89A4: 04          .
 EQUB %00001000          ; 89A5: 08          .
 EQUB %00001000          ; 89A6: 08          .
 EQUB %00001000          ; 89A7: 08          .
 EQUB %00001111          ; 89A8: 0F          .
 EQUB %00011111          ; 89A9: 1F          .
 EQUB %00011111          ; 89AA: 1F          .
 EQUB %11011111          ; 89AB: DF          .
 EQUB %11011111          ; 89AC: DF          .
 EQUB %10111111          ; 89AD: BF          .
 EQUB %10111110          ; 89AE: BE          .
 EQUB %10111111          ; 89AF: BF          .

; ******************************************************************************
;
;       Name: tile3_139
;       Type: Variable
;   Category: Drawing images
;    Summary: ???
;
; ******************************************************************************

.tile3_139

 EQUB %00000000          ; 89B0: 00          .
 EQUB %00000000          ; 89B1: 00          .
 EQUB %11000000          ; 89B2: C0          .
 EQUB %00110100          ; 89B3: 34          4
 EQUB %00010000          ; 89B4: 10          .
 EQUB %00001000          ; 89B5: 08          .
 EQUB %00001001          ; 89B6: 09          .
 EQUB %00001000          ; 89B7: 08          .
 EQUB %11111110          ; 89B8: FE          .
 EQUB %11111111          ; 89B9: FF          .
 EQUB %11111111          ; 89BA: FF          .
 EQUB %11111011          ; 89BB: FB          .
 EQUB %11111111          ; 89BC: FF          .
 EQUB %01111111          ; 89BD: 7F          .
 EQUB %00111110          ; 89BE: 3E          >
 EQUB %01111111          ; 89BF: 7F          .

; ******************************************************************************
;
;       Name: tile3_140
;       Type: Variable
;   Category: Drawing images
;    Summary: ???
;
; ******************************************************************************

.tile3_140

 EQUB %00000000          ; 89C0: 00          .
 EQUB %00000000          ; 89C1: 00          .
 EQUB %00000000          ; 89C2: 00          .
 EQUB %01101100          ; 89C3: 6C          l
 EQUB %00000000          ; 89C4: 00          .
 EQUB %01011101          ; 89C5: 5D          ]
 EQUB %00000000          ; 89C6: 00          .
 EQUB %11101100          ; 89C7: EC          .
 EQUB %11111111          ; 89C8: FF          .
 EQUB %11111111          ; 89C9: FF          .
 EQUB %11111111          ; 89CA: FF          .
 EQUB %10010010          ; 89CB: 92          .
 EQUB %11111110          ; 89CC: FE          .
 EQUB %10100011          ; 89CD: A3          .
 EQUB %11111110          ; 89CE: FE          .
 EQUB %00010010          ; 89CF: 12          .

; ******************************************************************************
;
;       Name: tile3_141
;       Type: Variable
;   Category: Drawing images
;    Summary: ???
;
; ******************************************************************************

.tile3_141

 EQUB %00000000          ; 89D0: 00          .
 EQUB %00000000          ; 89D1: 00          .
 EQUB %00000000          ; 89D2: 00          .
 EQUB %00000000          ; 89D3: 00          .
 EQUB %11000000          ; 89D4: C0          .
 EQUB %11100000          ; 89D5: E0          .
 EQUB %11000000          ; 89D6: C0          .
 EQUB %00000000          ; 89D7: 00          .
 EQUB %11100000          ; 89D8: E0          .
 EQUB %11110000          ; 89D9: F0          .
 EQUB %11110000          ; 89DA: F0          .
 EQUB %00010111          ; 89DB: 17          .
 EQUB %11010111          ; 89DC: D7          .
 EQUB %11111011          ; 89DD: FB          .
 EQUB %11011011          ; 89DE: DB          .
 EQUB %00011011          ; 89DF: 1B          .

; ******************************************************************************
;
;       Name: tile3_142
;       Type: Variable
;   Category: Drawing images
;    Summary: ???
;
; ******************************************************************************

.tile3_142

 EQUB %00000000          ; 89E0: 00          .
 EQUB %00000000          ; 89E1: 00          .
 EQUB %00000010          ; 89E2: 02          .
 EQUB %00000000          ; 89E3: 00          .
 EQUB %00000000          ; 89E4: 00          .
 EQUB %00000100          ; 89E5: 04          .
 EQUB %00000000          ; 89E6: 00          .
 EQUB %00000001          ; 89E7: 01          .
 EQUB %00001111          ; 89E8: 0F          .
 EQUB %00011111          ; 89E9: 1F          .
 EQUB %00011101          ; 89EA: 1D          .
 EQUB %11011111          ; 89EB: DF          .
 EQUB %11011111          ; 89EC: DF          .
 EQUB %10111010          ; 89ED: BA          .
 EQUB %10111111          ; 89EE: BF          .
 EQUB %10111111          ; 89EF: BF          .

; ******************************************************************************
;
;       Name: tile3_143
;       Type: Variable
;   Category: Drawing images
;    Summary: ???
;
; ******************************************************************************

.tile3_143

 EQUB %00000000          ; 89F0: 00          .
 EQUB %00000000          ; 89F1: 00          .
 EQUB %00000000          ; 89F2: 00          .
 EQUB %00000100          ; 89F3: 04          .
 EQUB %00000000          ; 89F4: 00          .
 EQUB %00000000          ; 89F5: 00          .
 EQUB %10100000          ; 89F6: A0          .
 EQUB %00010000          ; 89F7: 10          .
 EQUB %11111110          ; 89F8: FE          .
 EQUB %11111111          ; 89F9: FF          .
 EQUB %11111111          ; 89FA: FF          .
 EQUB %10111011          ; 89FB: BB          .
 EQUB %10111111          ; 89FC: BF          .
 EQUB %01001111          ; 89FD: 4F          O
 EQUB %10111111          ; 89FE: BF          .
 EQUB %10111111          ; 89FF: BF          .

; ******************************************************************************
;
;       Name: tile3_144
;       Type: Variable
;   Category: Drawing images
;    Summary: ???
;
; ******************************************************************************

.tile3_144

 EQUB %00000000          ; 8A00: 00          .
 EQUB %00000000          ; 8A01: 00          .
 EQUB %00000100          ; 8A02: 04          .
 EQUB %00000100          ; 8A03: 04          .
 EQUB %00000100          ; 8A04: 04          .
 EQUB %00000100          ; 8A05: 04          .
 EQUB %01111011          ; 8A06: 7B          {
 EQUB %00000100          ; 8A07: 04          .
 EQUB %11111111          ; 8A08: FF          .
 EQUB %11111111          ; 8A09: FF          .
 EQUB %11111011          ; 8A0A: FB          .
 EQUB %11000000          ; 8A0B: C0          .
 EQUB %11011011          ; 8A0C: DB          .
 EQUB %11011011          ; 8A0D: DB          .
 EQUB %10000100          ; 8A0E: 84          .
 EQUB %11011011          ; 8A0F: DB          .

; ******************************************************************************
;
;       Name: tile3_145
;       Type: Variable
;   Category: Drawing images
;    Summary: ???
;
; ******************************************************************************

.tile3_145

 EQUB %00000000          ; 8A10: 00          .
 EQUB %00000000          ; 8A11: 00          .
 EQUB %00000000          ; 8A12: 00          .
 EQUB %00000000          ; 8A13: 00          .
 EQUB %00000000          ; 8A14: 00          .
 EQUB %00000000          ; 8A15: 00          .
 EQUB %11000000          ; 8A16: C0          .
 EQUB %00000000          ; 8A17: 00          .
 EQUB %11100000          ; 8A18: E0          .
 EQUB %11110000          ; 8A19: F0          .
 EQUB %11110000          ; 8A1A: F0          .
 EQUB %01110111          ; 8A1B: 77          w
 EQUB %01110111          ; 8A1C: 77          w
 EQUB %01111011          ; 8A1D: 7B          {
 EQUB %00111011          ; 8A1E: 3B          ;
 EQUB %01111011          ; 8A1F: 7B          {

; ******************************************************************************
;
;       Name: tile3_146
;       Type: Variable
;   Category: Drawing images
;    Summary: ???
;
; ******************************************************************************

.tile3_146

 EQUB %00000000          ; 8A20: 00          .
 EQUB %00000000          ; 8A21: 00          .
 EQUB %00000000          ; 8A22: 00          .
 EQUB %00000000          ; 8A23: 00          .
 EQUB %00000000          ; 8A24: 00          .
 EQUB %00000000          ; 8A25: 00          .
 EQUB %00000000          ; 8A26: 00          .
 EQUB %00000000          ; 8A27: 00          .
 EQUB %00001111          ; 8A28: 0F          .
 EQUB %00011111          ; 8A29: 1F          .
 EQUB %00011110          ; 8A2A: 1E          .
 EQUB %11011100          ; 8A2B: DC          .
 EQUB %11011111          ; 8A2C: DF          .
 EQUB %10111111          ; 8A2D: BF          .
 EQUB %10111111          ; 8A2E: BF          .
 EQUB %10111111          ; 8A2F: BF          .

; ******************************************************************************
;
;       Name: tile3_147
;       Type: Variable
;   Category: Drawing images
;    Summary: ???
;
; ******************************************************************************

.tile3_147

 EQUB %00000000          ; 8A30: 00          .
 EQUB %00000000          ; 8A31: 00          .
 EQUB %00000000          ; 8A32: 00          .
 EQUB %00000000          ; 8A33: 00          .
 EQUB %00000000          ; 8A34: 00          .
 EQUB %00000000          ; 8A35: 00          .
 EQUB %00000000          ; 8A36: 00          .
 EQUB %00000000          ; 8A37: 00          .
 EQUB %11111110          ; 8A38: FE          .
 EQUB %11111111          ; 8A39: FF          .
 EQUB %00001111          ; 8A3A: 0F          .
 EQUB %11100111          ; 8A3B: E7          .
 EQUB %11000111          ; 8A3C: C7          .
 EQUB %10001111          ; 8A3D: 8F          .
 EQUB %10011111          ; 8A3E: 9F          .
 EQUB %11111111          ; 8A3F: FF          .

; ******************************************************************************
;
;       Name: tile3_148
;       Type: Variable
;   Category: Drawing images
;    Summary: ???
;
; ******************************************************************************

.tile3_148

 EQUB %00000000          ; 8A40: 00          .
 EQUB %00000000          ; 8A41: 00          .
 EQUB %00000000          ; 8A42: 00          .
 EQUB %00000000          ; 8A43: 00          .
 EQUB %00000000          ; 8A44: 00          .
 EQUB %00000000          ; 8A45: 00          .
 EQUB %00000000          ; 8A46: 00          .
 EQUB %00000000          ; 8A47: 00          .
 EQUB %00000000          ; 8A48: 00          .
 EQUB %00000001          ; 8A49: 01          .
 EQUB %00000001          ; 8A4A: 01          .
 EQUB %01111101          ; 8A4B: 7D          }
 EQUB %01111101          ; 8A4C: 7D          }
 EQUB %10111011          ; 8A4D: BB          .
 EQUB %10111010          ; 8A4E: BA          .
 EQUB %10111011          ; 8A4F: BB          .

; ******************************************************************************
;
;       Name: tile3_149
;       Type: Variable
;   Category: Drawing images
;    Summary: ???
;
; ******************************************************************************

.tile3_149

 EQUB %00000000          ; 8A50: 00          .
 EQUB %00000000          ; 8A51: 00          .
 EQUB %00000000          ; 8A52: 00          .
 EQUB %00000011          ; 8A53: 03          .
 EQUB %00100111          ; 8A54: 27          '
 EQUB %01101111          ; 8A55: 6F          o
 EQUB %11101111          ; 8A56: EF          .
 EQUB %01101111          ; 8A57: 6F          o
 EQUB %11111111          ; 8A58: FF          .
 EQUB %11111111          ; 8A59: FF          .
 EQUB %11111100          ; 8A5A: FC          .
 EQUB %11010000          ; 8A5B: D0          .
 EQUB %10100110          ; 8A5C: A6          .
 EQUB %01101011          ; 8A5D: 6B          k
 EQUB %11100011          ; 8A5E: E3          .
 EQUB %01100101          ; 8A5F: 65          e

; ******************************************************************************
;
;       Name: tile3_150
;       Type: Variable
;   Category: Drawing images
;    Summary: ???
;
; ******************************************************************************

.tile3_150

 EQUB %00000000          ; 8A60: 00          .
 EQUB %00000000          ; 8A61: 00          .
 EQUB %00000000          ; 8A62: 00          .
 EQUB %10000000          ; 8A63: 80          .
 EQUB %11000000          ; 8A64: C0          .
 EQUB %11100000          ; 8A65: E0          .
 EQUB %11100000          ; 8A66: E0          .
 EQUB %11100000          ; 8A67: E0          .
 EQUB %11100000          ; 8A68: E0          .
 EQUB %11110000          ; 8A69: F0          .
 EQUB %01110000          ; 8A6A: 70          p
 EQUB %10010111          ; 8A6B: 97          .
 EQUB %01010111          ; 8A6C: 57          W
 EQUB %11101011          ; 8A6D: EB          .
 EQUB %00101011          ; 8A6E: 2B          +
 EQUB %00101011          ; 8A6F: 2B          +

; ******************************************************************************
;
;       Name: tile3_151
;       Type: Variable
;   Category: Drawing images
;    Summary: ???
;
; ******************************************************************************

.tile3_151

 EQUB %00000000          ; 8A70: 00          .
 EQUB %00000000          ; 8A71: 00          .
 EQUB %00000000          ; 8A72: 00          .
 EQUB %00000000          ; 8A73: 00          .
 EQUB %00000010          ; 8A74: 02          .
 EQUB %00000110          ; 8A75: 06          .
 EQUB %00001110          ; 8A76: 0E          .
 EQUB %00000110          ; 8A77: 06          .
 EQUB %00001111          ; 8A78: 0F          .
 EQUB %00011111          ; 8A79: 1F          .
 EQUB %00011111          ; 8A7A: 1F          .
 EQUB %11011101          ; 8A7B: DD          .
 EQUB %11011010          ; 8A7C: DA          .
 EQUB %10110110          ; 8A7D: B6          .
 EQUB %10101110          ; 8A7E: AE          .
 EQUB %10110110          ; 8A7F: B6          .

; ******************************************************************************
;
;       Name: tile3_152
;       Type: Variable
;   Category: Drawing images
;    Summary: ???
;
; ******************************************************************************

.tile3_152

 EQUB %00000000          ; 8A80: 00          .
 EQUB %00000000          ; 8A81: 00          .
 EQUB %00000000          ; 8A82: 00          .
 EQUB %00000000          ; 8A83: 00          .
 EQUB %00010000          ; 8A84: 10          .
 EQUB %00110000          ; 8A85: 30          0
 EQUB %00111000          ; 8A86: 38          8
 EQUB %00111000          ; 8A87: 38          8
 EQUB %11111110          ; 8A88: FE          .
 EQUB %11111111          ; 8A89: FF          .
 EQUB %11111111          ; 8A8A: FF          .
 EQUB %11000011          ; 8A8B: C3          .
 EQUB %10101001          ; 8A8C: A9          .
 EQUB %01000110          ; 8A8D: 46          F
 EQUB %01000011          ; 8A8E: 43          C
 EQUB %10000101          ; 8A8F: 85          .

; ******************************************************************************
;
;       Name: tile3_153
;       Type: Variable
;   Category: Drawing images
;    Summary: ???
;
; ******************************************************************************

.tile3_153

 EQUB %00000000          ; 8A90: 00          .
 EQUB %00000000          ; 8A91: 00          .
 EQUB %00000001          ; 8A92: 01          .
 EQUB %00100010          ; 8A93: 22          "
 EQUB %01010100          ; 8A94: 54          T
 EQUB %10001000          ; 8A95: 88          .
 EQUB %00100010          ; 8A96: 22          "
 EQUB %00010101          ; 8A97: 15          .
 EQUB %11111111          ; 8A98: FF          .
 EQUB %11111111          ; 8A99: FF          .
 EQUB %11111110          ; 8A9A: FE          .
 EQUB %11011100          ; 8A9B: DC          .
 EQUB %10001001          ; 8A9C: 89          .
 EQUB %00100011          ; 8A9D: 23          #
 EQUB %01010101          ; 8A9E: 55          U
 EQUB %11001000          ; 8A9F: C8          .

; ******************************************************************************
;
;       Name: tile3_154
;       Type: Variable
;   Category: Drawing images
;    Summary: ???
;
; ******************************************************************************

.tile3_154

 EQUB %00000000          ; 8AA0: 00          .
 EQUB %00000000          ; 8AA1: 00          .
 EQUB %00000000          ; 8AA2: 00          .
 EQUB %10000000          ; 8AA3: 80          .
 EQUB %00100000          ; 8AA4: 20
 EQUB %01000000          ; 8AA5: 40          @
 EQUB %10000000          ; 8AA6: 80          .
 EQUB %00100000          ; 8AA7: 20
 EQUB %11100000          ; 8AA8: E0          .
 EQUB %11110000          ; 8AA9: F0          .
 EQUB %11110000          ; 8AAA: F0          .
 EQUB %01110111          ; 8AAB: 77          w
 EQUB %01010111          ; 8AAC: 57          W
 EQUB %10011011          ; 8AAD: 9B          .
 EQUB %00111011          ; 8AAE: 3B          ;
 EQUB %01011011          ; 8AAF: 5B          [

; ******************************************************************************
;
;       Name: tile3_155
;       Type: Variable
;   Category: Drawing images
;    Summary: ???
;
; ******************************************************************************

.tile3_155

 EQUB %00000000          ; 8AB0: 00          .
 EQUB %00000000          ; 8AB1: 00          .
 EQUB %00000000          ; 8AB2: 00          .
 EQUB %00000000          ; 8AB3: 00          .
 EQUB %00000001          ; 8AB4: 01          .
 EQUB %00000000          ; 8AB5: 00          .
 EQUB %00000000          ; 8AB6: 00          .
 EQUB %00000000          ; 8AB7: 00          .
 EQUB %00001111          ; 8AB8: 0F          .
 EQUB %00011111          ; 8AB9: 1F          .
 EQUB %00011111          ; 8ABA: 1F          .
 EQUB %11011110          ; 8ABB: DE          .
 EQUB %11011101          ; 8ABC: DD          .
 EQUB %10111100          ; 8ABD: BC          .
 EQUB %10111111          ; 8ABE: BF          .
 EQUB %10111100          ; 8ABF: BC          .

; ******************************************************************************
;
;       Name: tile3_156
;       Type: Variable
;   Category: Drawing images
;    Summary: ???
;
; ******************************************************************************

.tile3_156

 EQUB %00000000          ; 8AC0: 00          .
 EQUB %00000000          ; 8AC1: 00          .
 EQUB %01000000          ; 8AC2: 40          @
 EQUB %11100000          ; 8AC3: E0          .
 EQUB %11110000          ; 8AC4: F0          .
 EQUB %00000000          ; 8AC5: 00          .
 EQUB %00000000          ; 8AC6: 00          .
 EQUB %00000000          ; 8AC7: 00          .
 EQUB %11111110          ; 8AC8: FE          .
 EQUB %10111111          ; 8AC9: BF          .
 EQUB %01011111          ; 8ACA: 5F          _
 EQUB %11101111          ; 8ACB: EF          .
 EQUB %11110111          ; 8ACC: F7          .
 EQUB %00000111          ; 8ACD: 07          .
 EQUB %11111111          ; 8ACE: FF          .
 EQUB %00000111          ; 8ACF: 07          .

; ******************************************************************************
;
;       Name: tile3_157
;       Type: Variable
;   Category: Drawing images
;    Summary: ???
;
; ******************************************************************************

.tile3_157

 EQUB %00000000          ; 8AD0: 00          .
 EQUB %00000000          ; 8AD1: 00          .
 EQUB %00000000          ; 8AD2: 00          .
 EQUB %00100001          ; 8AD3: 21          !
 EQUB %00110001          ; 8AD4: 31          1
 EQUB %00111001          ; 8AD5: 39          9
 EQUB %00110001          ; 8AD6: 31          1
 EQUB %00100001          ; 8AD7: 21          !
 EQUB %11111111          ; 8AD8: FF          .
 EQUB %11111111          ; 8AD9: FF          .
 EQUB %10011100          ; 8ADA: 9C          .
 EQUB %10101101          ; 8ADB: AD          .
 EQUB %10110101          ; 8ADC: B5          .
 EQUB %10111001          ; 8ADD: B9          .
 EQUB %10110101          ; 8ADE: B5          .
 EQUB %10101101          ; 8ADF: AD          .

; ******************************************************************************
;
;       Name: tile3_158
;       Type: Variable
;   Category: Drawing images
;    Summary: ???
;
; ******************************************************************************

.tile3_158

 EQUB %00000000          ; 8AE0: 00          .
 EQUB %00000000          ; 8AE1: 00          .
 EQUB %00000000          ; 8AE2: 00          .
 EQUB %00000000          ; 8AE3: 00          .
 EQUB %10000000          ; 8AE4: 80          .
 EQUB %11000000          ; 8AE5: C0          .
 EQUB %10000000          ; 8AE6: 80          .
 EQUB %00000000          ; 8AE7: 00          .
 EQUB %11100000          ; 8AE8: E0          .
 EQUB %11110000          ; 8AE9: F0          .
 EQUB %11110000          ; 8AEA: F0          .
 EQUB %01110111          ; 8AEB: 77          w
 EQUB %10110111          ; 8AEC: B7          .
 EQUB %11011011          ; 8AED: DB          .
 EQUB %10111011          ; 8AEE: BB          .
 EQUB %01111011          ; 8AEF: 7B          {

; ******************************************************************************
;
;       Name: tile3_159
;       Type: Variable
;   Category: Drawing images
;    Summary: ???
;
; ******************************************************************************

.tile3_159

 EQUB %00000000          ; 8AF0: 00          .
 EQUB %00000000          ; 8AF1: 00          .
 EQUB %00000000          ; 8AF2: 00          .
 EQUB %00100000          ; 8AF3: 20
 EQUB %00011111          ; 8AF4: 1F          .
 EQUB %00000000          ; 8AF5: 00          .
 EQUB %00100000          ; 8AF6: 20
 EQUB %00000000          ; 8AF7: 00          .
 EQUB %00111111          ; 8AF8: 3F          ?
 EQUB %00111111          ; 8AF9: 3F          ?
 EQUB %00111111          ; 8AFA: 3F          ?
 EQUB %00011111          ; 8AFB: 1F          .
 EQUB %00100000          ; 8AFC: 20
 EQUB %00000000          ; 8AFD: 00          .
 EQUB %01011111          ; 8AFE: 5F          _
 EQUB %01000000          ; 8AFF: 40          @

; ******************************************************************************
;
;       Name: tile3_160
;       Type: Variable
;   Category: Drawing images
;    Summary: ???
;
; ******************************************************************************

.tile3_160

 EQUB %00000000          ; 8B00: 00          .
 EQUB %00000000          ; 8B01: 00          .
 EQUB %00000000          ; 8B02: 00          .
 EQUB %00000000          ; 8B03: 00          .
 EQUB %11111111          ; 8B04: FF          .
 EQUB %00000000          ; 8B05: 00          .
 EQUB %00000000          ; 8B06: 00          .
 EQUB %00000000          ; 8B07: 00          .
 EQUB %11111111          ; 8B08: FF          .
 EQUB %11111111          ; 8B09: FF          .
 EQUB %11111111          ; 8B0A: FF          .
 EQUB %11111111          ; 8B0B: FF          .
 EQUB %00000000          ; 8B0C: 00          .
 EQUB %00000000          ; 8B0D: 00          .
 EQUB %11111111          ; 8B0E: FF          .
 EQUB %00000000          ; 8B0F: 00          .

; ******************************************************************************
;
;       Name: tile3_161
;       Type: Variable
;   Category: Drawing images
;    Summary: ???
;
; ******************************************************************************

.tile3_161

 EQUB %00000000          ; 8B10: 00          .
 EQUB %00000000          ; 8B11: 00          .
 EQUB %00000000          ; 8B12: 00          .
 EQUB %10000010          ; 8B13: 82          .
 EQUB %00000001          ; 8B14: 01          .
 EQUB %00010000          ; 8B15: 10          .
 EQUB %10010010          ; 8B16: 92          .
 EQUB %00010000          ; 8B17: 10          .
 EQUB %10010011          ; 8B18: 93          .
 EQUB %10010011          ; 8B19: 93          .
 EQUB %10010011          ; 8B1A: 93          .
 EQUB %00010001          ; 8B1B: 11          .
 EQUB %10010010          ; 8B1C: 92          .
 EQUB %00000000          ; 8B1D: 00          .
 EQUB %01000101          ; 8B1E: 45          E
 EQUB %01000100          ; 8B1F: 44          D

; ******************************************************************************
;
;       Name: tile3_162
;       Type: Variable
;   Category: Drawing images
;    Summary: ???
;
; ******************************************************************************

.tile3_162

 EQUB %00000000          ; 8B20: 00          .
 EQUB %00000000          ; 8B21: 00          .
 EQUB %00000000          ; 8B22: 00          .
 EQUB %00001000          ; 8B23: 08          .
 EQUB %11110000          ; 8B24: F0          .
 EQUB %00000001          ; 8B25: 01          .
 EQUB %00001001          ; 8B26: 09          .
 EQUB %00000001          ; 8B27: 01          .
 EQUB %11111001          ; 8B28: F9          .
 EQUB %11111001          ; 8B29: F9          .
 EQUB %11111001          ; 8B2A: F9          .
 EQUB %11110001          ; 8B2B: F1          .
 EQUB %00001001          ; 8B2C: 09          .
 EQUB %00000000          ; 8B2D: 00          .
 EQUB %11110100          ; 8B2E: F4          .
 EQUB %00000100          ; 8B2F: 04          .

; ******************************************************************************
;
;       Name: tile3_163
;       Type: Variable
;   Category: Drawing images
;    Summary: ???
;
; ******************************************************************************

.tile3_163

 EQUB %00000000          ; 8B30: 00          .
 EQUB %00000000          ; 8B31: 00          .
 EQUB %00000000          ; 8B32: 00          .
 EQUB %00000000          ; 8B33: 00          .
 EQUB %00000000          ; 8B34: 00          .
 EQUB %00000000          ; 8B35: 00          .
 EQUB %00000001          ; 8B36: 01          .
 EQUB %00001011          ; 8B37: 0B          .
 EQUB %00001111          ; 8B38: 0F          .
 EQUB %00001111          ; 8B39: 0F          .
 EQUB %00011111          ; 8B3A: 1F          .
 EQUB %00011111          ; 8B3B: 1F          .
 EQUB %00111111          ; 8B3C: 3F          ?
 EQUB %00111111          ; 8B3D: 3F          ?
 EQUB %01111110          ; 8B3E: 7E          ~
 EQUB %01110100          ; 8B3F: 74          t

; ******************************************************************************
;
;       Name: tile3_164
;       Type: Variable
;   Category: Drawing images
;    Summary: ???
;
; ******************************************************************************

.tile3_164

 EQUB %00000000          ; 8B40: 00          .
 EQUB %00000000          ; 8B41: 00          .
 EQUB %00000000          ; 8B42: 00          .
 EQUB %00000000          ; 8B43: 00          .
 EQUB %00000000          ; 8B44: 00          .
 EQUB %00000000          ; 8B45: 00          .
 EQUB %10000000          ; 8B46: 80          .
 EQUB %11010000          ; 8B47: D0          .
 EQUB %11110000          ; 8B48: F0          .
 EQUB %11110000          ; 8B49: F0          .
 EQUB %11111000          ; 8B4A: F8          .
 EQUB %11111000          ; 8B4B: F8          .
 EQUB %11111100          ; 8B4C: FC          .
 EQUB %11111100          ; 8B4D: FC          .
 EQUB %01111110          ; 8B4E: 7E          ~
 EQUB %00101110          ; 8B4F: 2E          .

; ******************************************************************************
;
;       Name: tile3_165
;       Type: Variable
;   Category: Drawing images
;    Summary: ???
;
; ******************************************************************************

.tile3_165

 EQUB %00000010          ; 8B50: 02          .
 EQUB %00000000          ; 8B51: 00          .
 EQUB %00000000          ; 8B52: 00          .
 EQUB %00100000          ; 8B53: 20
 EQUB %00011111          ; 8B54: 1F          .
 EQUB %00000000          ; 8B55: 00          .
 EQUB %00100000          ; 8B56: 20
 EQUB %00000000          ; 8B57: 00          .
 EQUB %00111010          ; 8B58: 3A          :
 EQUB %00111100          ; 8B59: 3C          <
 EQUB %00111100          ; 8B5A: 3C          <
 EQUB %00011111          ; 8B5B: 1F          .
 EQUB %00100000          ; 8B5C: 20
 EQUB %00000000          ; 8B5D: 00          .
 EQUB %01011111          ; 8B5E: 5F          _
 EQUB %01000000          ; 8B5F: 40          @

; ******************************************************************************
;
;       Name: tile3_166
;       Type: Variable
;   Category: Drawing images
;    Summary: ???
;
; ******************************************************************************

.tile3_166

 EQUB %00100000          ; 8B60: 20
 EQUB %00000000          ; 8B61: 00          .
 EQUB %00000000          ; 8B62: 00          .
 EQUB %00000000          ; 8B63: 00          .
 EQUB %11111111          ; 8B64: FF          .
 EQUB %00000000          ; 8B65: 00          .
 EQUB %00000000          ; 8B66: 00          .
 EQUB %00000000          ; 8B67: 00          .
 EQUB %01010101          ; 8B68: 55          U
 EQUB %10101101          ; 8B69: AD          .
 EQUB %00000001          ; 8B6A: 01          .
 EQUB %11111111          ; 8B6B: FF          .
 EQUB %00000000          ; 8B6C: 00          .
 EQUB %00000000          ; 8B6D: 00          .
 EQUB %11111111          ; 8B6E: FF          .
 EQUB %00000000          ; 8B6F: 00          .

; ******************************************************************************
;
;       Name: tile3_167
;       Type: Variable
;   Category: Drawing images
;    Summary: ???
;
; ******************************************************************************

.tile3_167

 EQUB %00100010          ; 8B70: 22          "
 EQUB %01010100          ; 8B71: 54          T
 EQUB %00001000          ; 8B72: 08          .
 EQUB %00000000          ; 8B73: 00          .
 EQUB %11111111          ; 8B74: FF          .
 EQUB %00000000          ; 8B75: 00          .
 EQUB %00000000          ; 8B76: 00          .
 EQUB %00000000          ; 8B77: 00          .
 EQUB %01111111          ; 8B78: 7F          .
 EQUB %01111111          ; 8B79: 7F          .
 EQUB %00001000          ; 8B7A: 08          .
 EQUB %11111111          ; 8B7B: FF          .
 EQUB %00000000          ; 8B7C: 00          .
 EQUB %00000000          ; 8B7D: 00          .
 EQUB %11111111          ; 8B7E: FF          .
 EQUB %00000000          ; 8B7F: 00          .

; ******************************************************************************
;
;       Name: tile3_168
;       Type: Variable
;   Category: Drawing images
;    Summary: ???
;
; ******************************************************************************

.tile3_168

 EQUB %00000000          ; 8B80: 00          .
 EQUB %00000000          ; 8B81: 00          .
 EQUB %00000000          ; 8B82: 00          .
 EQUB %00001000          ; 8B83: 08          .
 EQUB %11110000          ; 8B84: F0          .
 EQUB %00000001          ; 8B85: 01          .
 EQUB %00001001          ; 8B86: 09          .
 EQUB %00000001          ; 8B87: 01          .
 EQUB %11111001          ; 8B88: F9          .
 EQUB %11111001          ; 8B89: F9          .
 EQUB %00011001          ; 8B8A: 19          .
 EQUB %11110001          ; 8B8B: F1          .
 EQUB %00001001          ; 8B8C: 09          .
 EQUB %00000000          ; 8B8D: 00          .
 EQUB %11110100          ; 8B8E: F4          .
 EQUB %00000100          ; 8B8F: 04          .

; ******************************************************************************
;
;       Name: tile3_169
;       Type: Variable
;   Category: Drawing images
;    Summary: ???
;
; ******************************************************************************

.tile3_169

 EQUB %00000100          ; 8B90: 04          .
 EQUB %00000110          ; 8B91: 06          .
 EQUB %00000001          ; 8B92: 01          .
 EQUB %00100000          ; 8B93: 20
 EQUB %00011111          ; 8B94: 1F          .
 EQUB %00000000          ; 8B95: 00          .
 EQUB %00100000          ; 8B96: 20
 EQUB %00000000          ; 8B97: 00          .
 EQUB %00111111          ; 8B98: 3F          ?
 EQUB %00111111          ; 8B99: 3F          ?
 EQUB %00111111          ; 8B9A: 3F          ?
 EQUB %00011111          ; 8B9B: 1F          .
 EQUB %00100000          ; 8B9C: 20
 EQUB %00000000          ; 8B9D: 00          .
 EQUB %01011111          ; 8B9E: 5F          _
 EQUB %01000000          ; 8B9F: 40          @

; ******************************************************************************
;
;       Name: tile3_170
;       Type: Variable
;   Category: Drawing images
;    Summary: ???
;
; ******************************************************************************

.tile3_170

 EQUB %00010000          ; 8BA0: 10          .
 EQUB %00110010          ; 8BA1: 32          2
 EQUB %11000000          ; 8BA2: C0          .
 EQUB %00000000          ; 8BA3: 00          .
 EQUB %11111111          ; 8BA4: FF          .
 EQUB %00000000          ; 8BA5: 00          .
 EQUB %00000000          ; 8BA6: 00          .
 EQUB %00000000          ; 8BA7: 00          .
 EQUB %11111111          ; 8BA8: FF          .
 EQUB %11111101          ; 8BA9: FD          .
 EQUB %11111111          ; 8BAA: FF          .
 EQUB %11111111          ; 8BAB: FF          .
 EQUB %00000000          ; 8BAC: 00          .
 EQUB %00000000          ; 8BAD: 00          .
 EQUB %11111111          ; 8BAE: FF          .
 EQUB %00000000          ; 8BAF: 00          .

; ******************************************************************************
;
;       Name: tile3_171
;       Type: Variable
;   Category: Drawing images
;    Summary: ???
;
; ******************************************************************************

.tile3_171

 EQUB %00000000          ; 8BB0: 00          .
 EQUB %11011101          ; 8BB1: DD          .
 EQUB %00000000          ; 8BB2: 00          .
 EQUB %00000000          ; 8BB3: 00          .
 EQUB %11111111          ; 8BB4: FF          .
 EQUB %00000000          ; 8BB5: 00          .
 EQUB %00000000          ; 8BB6: 00          .
 EQUB %00000000          ; 8BB7: 00          .
 EQUB %11111111          ; 8BB8: FF          .
 EQUB %00100010          ; 8BB9: 22          "
 EQUB %11111111          ; 8BBA: FF          .
 EQUB %11111111          ; 8BBB: FF          .
 EQUB %00000000          ; 8BBC: 00          .
 EQUB %00000000          ; 8BBD: 00          .
 EQUB %11111111          ; 8BBE: FF          .
 EQUB %00000000          ; 8BBF: 00          .

; ******************************************************************************
;
;       Name: tile3_172
;       Type: Variable
;   Category: Drawing images
;    Summary: ???
;
; ******************************************************************************

.tile3_172

 EQUB %00000000          ; 8BC0: 00          .
 EQUB %10100000          ; 8BC1: A0          .
 EQUB %00000000          ; 8BC2: 00          .
 EQUB %00001000          ; 8BC3: 08          .
 EQUB %11110000          ; 8BC4: F0          .
 EQUB %00000001          ; 8BC5: 01          .
 EQUB %00001001          ; 8BC6: 09          .
 EQUB %00000001          ; 8BC7: 01          .
 EQUB %11111001          ; 8BC8: F9          .
 EQUB %01011001          ; 8BC9: 59          Y
 EQUB %11111001          ; 8BCA: F9          .
 EQUB %11110001          ; 8BCB: F1          .
 EQUB %00001001          ; 8BCC: 09          .
 EQUB %00000000          ; 8BCD: 00          .
 EQUB %11110100          ; 8BCE: F4          .
 EQUB %00000100          ; 8BCF: 04          .

; ******************************************************************************
;
;       Name: tile3_173
;       Type: Variable
;   Category: Drawing images
;    Summary: ???
;
; ******************************************************************************

.tile3_173

 EQUB %00000110          ; 8BD0: 06          .
 EQUB %00011100          ; 8BD1: 1C          .
 EQUB %00001000          ; 8BD2: 08          .
 EQUB %00100000          ; 8BD3: 20
 EQUB %00011111          ; 8BD4: 1F          .
 EQUB %00000000          ; 8BD5: 00          .
 EQUB %00100000          ; 8BD6: 20
 EQUB %00000000          ; 8BD7: 00          .
 EQUB %00111111          ; 8BD8: 3F          ?
 EQUB %00111111          ; 8BD9: 3F          ?
 EQUB %00111111          ; 8BDA: 3F          ?
 EQUB %00011111          ; 8BDB: 1F          .
 EQUB %00100000          ; 8BDC: 20
 EQUB %00000000          ; 8BDD: 00          .
 EQUB %01011111          ; 8BDE: 5F          _
 EQUB %01000000          ; 8BDF: 40          @

; ******************************************************************************
;
;       Name: tile3_174
;       Type: Variable
;   Category: Drawing images
;    Summary: ???
;
; ******************************************************************************

.tile3_174

 EQUB %00001100          ; 8BE0: 0C          .
 EQUB %01000111          ; 8BE1: 47          G
 EQUB %00000010          ; 8BE2: 02          .
 EQUB %00000000          ; 8BE3: 00          .
 EQUB %11111111          ; 8BE4: FF          .
 EQUB %00000000          ; 8BE5: 00          .
 EQUB %00000000          ; 8BE6: 00          .
 EQUB %00000000          ; 8BE7: 00          .
 EQUB %11111111          ; 8BE8: FF          .
 EQUB %10111111          ; 8BE9: BF          .
 EQUB %11111111          ; 8BEA: FF          .
 EQUB %11111111          ; 8BEB: FF          .
 EQUB %00000000          ; 8BEC: 00          .
 EQUB %00000000          ; 8BED: 00          .
 EQUB %11111111          ; 8BEE: FF          .
 EQUB %00000000          ; 8BEF: 00          .

; ******************************************************************************
;
;       Name: tile3_175
;       Type: Variable
;   Category: Drawing images
;    Summary: ???
;
; ******************************************************************************

.tile3_175

 EQUB %00000100          ; 8BF0: 04          .
 EQUB %00000100          ; 8BF1: 04          .
 EQUB %00000100          ; 8BF2: 04          .
 EQUB %00000000          ; 8BF3: 00          .
 EQUB %11111111          ; 8BF4: FF          .
 EQUB %00000000          ; 8BF5: 00          .
 EQUB %00000000          ; 8BF6: 00          .
 EQUB %00000000          ; 8BF7: 00          .
 EQUB %11011011          ; 8BF8: DB          .
 EQUB %11000000          ; 8BF9: C0          .
 EQUB %11111011          ; 8BFA: FB          .
 EQUB %11111111          ; 8BFB: FF          .
 EQUB %00000000          ; 8BFC: 00          .
 EQUB %00000000          ; 8BFD: 00          .
 EQUB %11111111          ; 8BFE: FF          .
 EQUB %00000000          ; 8BFF: 00          .

; ******************************************************************************
;
;       Name: tile3_176
;       Type: Variable
;   Category: Drawing images
;    Summary: ???
;
; ******************************************************************************

.tile3_176

 EQUB %00000000          ; 8C00: 00          .
 EQUB %00000000          ; 8C01: 00          .
 EQUB %00000000          ; 8C02: 00          .
 EQUB %00001000          ; 8C03: 08          .
 EQUB %11110000          ; 8C04: F0          .
 EQUB %00000001          ; 8C05: 01          .
 EQUB %00001001          ; 8C06: 09          .
 EQUB %00000001          ; 8C07: 01          .
 EQUB %01111001          ; 8C08: 79          y
 EQUB %01111001          ; 8C09: 79          y
 EQUB %11111001          ; 8C0A: F9          .
 EQUB %11110001          ; 8C0B: F1          .
 EQUB %00001001          ; 8C0C: 09          .
 EQUB %00000000          ; 8C0D: 00          .
 EQUB %11110100          ; 8C0E: F4          .
 EQUB %00000100          ; 8C0F: 04          .

; ******************************************************************************
;
;       Name: tile3_177
;       Type: Variable
;   Category: Drawing images
;    Summary: ???
;
; ******************************************************************************

.tile3_177

 EQUB %00000000          ; 8C10: 00          .
 EQUB %00000000          ; 8C11: 00          .
 EQUB %00000000          ; 8C12: 00          .
 EQUB %00000000          ; 8C13: 00          .
 EQUB %11111111          ; 8C14: FF          .
 EQUB %00000000          ; 8C15: 00          .
 EQUB %00000000          ; 8C16: 00          .
 EQUB %00000000          ; 8C17: 00          .
 EQUB %10011111          ; 8C18: 9F          .
 EQUB %10011111          ; 8C19: 9F          .
 EQUB %11111111          ; 8C1A: FF          .
 EQUB %11111111          ; 8C1B: FF          .
 EQUB %00000000          ; 8C1C: 00          .
 EQUB %00000000          ; 8C1D: 00          .
 EQUB %11111111          ; 8C1E: FF          .
 EQUB %00000000          ; 8C1F: 00          .

; ******************************************************************************
;
;       Name: tile3_178
;       Type: Variable
;   Category: Drawing images
;    Summary: ???
;
; ******************************************************************************

.tile3_178

 EQUB %00100111          ; 8C20: 27          '
 EQUB %00000011          ; 8C21: 03          .
 EQUB %00000000          ; 8C22: 00          .
 EQUB %00000000          ; 8C23: 00          .
 EQUB %11111111          ; 8C24: FF          .
 EQUB %00000000          ; 8C25: 00          .
 EQUB %00000000          ; 8C26: 00          .
 EQUB %00000000          ; 8C27: 00          .
 EQUB %10100111          ; 8C28: A7          .
 EQUB %11010010          ; 8C29: D2          .
 EQUB %11111100          ; 8C2A: FC          .
 EQUB %11111111          ; 8C2B: FF          .
 EQUB %00000000          ; 8C2C: 00          .
 EQUB %00000000          ; 8C2D: 00          .
 EQUB %11111111          ; 8C2E: FF          .
 EQUB %00000000          ; 8C2F: 00          .

; ******************************************************************************
;
;       Name: tile3_179
;       Type: Variable
;   Category: Drawing images
;    Summary: ???
;
; ******************************************************************************

.tile3_179

 EQUB %11000000          ; 8C30: C0          .
 EQUB %10000000          ; 8C31: 80          .
 EQUB %00000000          ; 8C32: 00          .
 EQUB %00001000          ; 8C33: 08          .
 EQUB %11110000          ; 8C34: F0          .
 EQUB %00000001          ; 8C35: 01          .
 EQUB %00001001          ; 8C36: 09          .
 EQUB %00000001          ; 8C37: 01          .
 EQUB %01011001          ; 8C38: 59          Y
 EQUB %10011001          ; 8C39: 99          .
 EQUB %01111001          ; 8C3A: 79          y
 EQUB %11110001          ; 8C3B: F1          .
 EQUB %00001001          ; 8C3C: 09          .
 EQUB %00000000          ; 8C3D: 00          .
 EQUB %11110100          ; 8C3E: F4          .
 EQUB %00000100          ; 8C3F: 04          .

; ******************************************************************************
;
;       Name: tile3_180
;       Type: Variable
;   Category: Drawing images
;    Summary: ???
;
; ******************************************************************************

.tile3_180

 EQUB %00000010          ; 8C40: 02          .
 EQUB %00000000          ; 8C41: 00          .
 EQUB %00000000          ; 8C42: 00          .
 EQUB %00100000          ; 8C43: 20
 EQUB %00011111          ; 8C44: 1F          .
 EQUB %00000000          ; 8C45: 00          .
 EQUB %00100000          ; 8C46: 20
 EQUB %00000000          ; 8C47: 00          .
 EQUB %00111010          ; 8C48: 3A          :
 EQUB %00111101          ; 8C49: 3D          =
 EQUB %00111111          ; 8C4A: 3F          ?
 EQUB %00011111          ; 8C4B: 1F          .
 EQUB %00100000          ; 8C4C: 20
 EQUB %00000000          ; 8C4D: 00          .
 EQUB %01011111          ; 8C4E: 5F          _
 EQUB %01000000          ; 8C4F: 40          @

; ******************************************************************************
;
;       Name: tile3_181
;       Type: Variable
;   Category: Drawing images
;    Summary: ???
;
; ******************************************************************************

.tile3_181

 EQUB %00011000          ; 8C50: 18          .
 EQUB %00010000          ; 8C51: 10          .
 EQUB %00000000          ; 8C52: 00          .
 EQUB %00000000          ; 8C53: 00          .
 EQUB %11111111          ; 8C54: FF          .
 EQUB %00000000          ; 8C55: 00          .
 EQUB %00000000          ; 8C56: 00          .
 EQUB %00000000          ; 8C57: 00          .
 EQUB %11000101          ; 8C58: C5          .
 EQUB %00101011          ; 8C59: 2B          +
 EQUB %10000111          ; 8C5A: 87          .
 EQUB %11111111          ; 8C5B: FF          .
 EQUB %00000000          ; 8C5C: 00          .
 EQUB %00000000          ; 8C5D: 00          .
 EQUB %11111111          ; 8C5E: FF          .
 EQUB %00000000          ; 8C5F: 00          .

; ******************************************************************************
;
;       Name: tile3_182
;       Type: Variable
;   Category: Drawing images
;    Summary: ???
;
; ******************************************************************************

.tile3_182

 EQUB %00001000          ; 8C60: 08          .
 EQUB %00000000          ; 8C61: 00          .
 EQUB %00000000          ; 8C62: 00          .
 EQUB %00000000          ; 8C63: 00          .
 EQUB %11111111          ; 8C64: FF          .
 EQUB %00000000          ; 8C65: 00          .
 EQUB %00000000          ; 8C66: 00          .
 EQUB %00000000          ; 8C67: 00          .
 EQUB %11100010          ; 8C68: E2          .
 EQUB %11110111          ; 8C69: F7          .
 EQUB %11111111          ; 8C6A: FF          .
 EQUB %11111111          ; 8C6B: FF          .
 EQUB %00000000          ; 8C6C: 00          .
 EQUB %00000000          ; 8C6D: 00          .
 EQUB %11111111          ; 8C6E: FF          .
 EQUB %00000000          ; 8C6F: 00          .

; ******************************************************************************
;
;       Name: tile3_183
;       Type: Variable
;   Category: Drawing images
;    Summary: ???
;
; ******************************************************************************

.tile3_183

 EQUB %00000000          ; 8C70: 00          .
 EQUB %00000000          ; 8C71: 00          .
 EQUB %00000000          ; 8C72: 00          .
 EQUB %00001000          ; 8C73: 08          .
 EQUB %11110000          ; 8C74: F0          .
 EQUB %00000001          ; 8C75: 01          .
 EQUB %00001001          ; 8C76: 09          .
 EQUB %00000001          ; 8C77: 01          .
 EQUB %11011001          ; 8C78: D9          .
 EQUB %11111001          ; 8C79: F9          .
 EQUB %11111001          ; 8C7A: F9          .
 EQUB %11110001          ; 8C7B: F1          .
 EQUB %00001001          ; 8C7C: 09          .
 EQUB %00000000          ; 8C7D: 00          .
 EQUB %11110100          ; 8C7E: F4          .
 EQUB %00000100          ; 8C7F: 04          .

; ******************************************************************************
;
;       Name: tile3_184
;       Type: Variable
;   Category: Drawing images
;    Summary: ???
;
; ******************************************************************************

.tile3_184

 EQUB %00000001          ; 8C80: 01          .
 EQUB %00000000          ; 8C81: 00          .
 EQUB %00000000          ; 8C82: 00          .
 EQUB %00100000          ; 8C83: 20
 EQUB %00011111          ; 8C84: 1F          .
 EQUB %00000000          ; 8C85: 00          .
 EQUB %00100000          ; 8C86: 20
 EQUB %00000000          ; 8C87: 00          .
 EQUB %00111101          ; 8C88: 3D          =
 EQUB %00111100          ; 8C89: 3C          <
 EQUB %00111111          ; 8C8A: 3F          ?
 EQUB %00011111          ; 8C8B: 1F          .
 EQUB %00100000          ; 8C8C: 20
 EQUB %00000000          ; 8C8D: 00          .
 EQUB %01011111          ; 8C8E: 5F          _
 EQUB %01000000          ; 8C8F: 40          @

; ******************************************************************************
;
;       Name: tile3_185
;       Type: Variable
;   Category: Drawing images
;    Summary: ???
;
; ******************************************************************************

.tile3_185

 EQUB %11110000          ; 8C90: F0          .
 EQUB %00000000          ; 8C91: 00          .
 EQUB %00000000          ; 8C92: 00          .
 EQUB %00000000          ; 8C93: 00          .
 EQUB %11111111          ; 8C94: FF          .
 EQUB %00000000          ; 8C95: 00          .
 EQUB %00000000          ; 8C96: 00          .
 EQUB %00000000          ; 8C97: 00          .
 EQUB %11110111          ; 8C98: F7          .
 EQUB %00000111          ; 8C99: 07          .
 EQUB %11111111          ; 8C9A: FF          .
 EQUB %11111111          ; 8C9B: FF          .
 EQUB %00000000          ; 8C9C: 00          .
 EQUB %00000000          ; 8C9D: 00          .
 EQUB %11111111          ; 8C9E: FF          .
 EQUB %00000000          ; 8C9F: 00          .

; ******************************************************************************
;
;       Name: tile3_186
;       Type: Variable
;   Category: Drawing images
;    Summary: ???
;
; ******************************************************************************

.tile3_186

 EQUB %00000000          ; 8CA0: 00          .
 EQUB %00000000          ; 8CA1: 00          .
 EQUB %00000000          ; 8CA2: 00          .
 EQUB %00000000          ; 8CA3: 00          .
 EQUB %11111111          ; 8CA4: FF          .
 EQUB %00000000          ; 8CA5: 00          .
 EQUB %00000000          ; 8CA6: 00          .
 EQUB %00000000          ; 8CA7: 00          .
 EQUB %10011100          ; 8CA8: 9C          .
 EQUB %11111111          ; 8CA9: FF          .
 EQUB %11111111          ; 8CAA: FF          .
 EQUB %11111111          ; 8CAB: FF          .
 EQUB %00000000          ; 8CAC: 00          .
 EQUB %00000000          ; 8CAD: 00          .
 EQUB %11111111          ; 8CAE: FF          .
 EQUB %00000000          ; 8CAF: 00          .

; ******************************************************************************
;
;       Name: tile3_187
;       Type: Variable
;   Category: Drawing images
;    Summary: ???
;
; ******************************************************************************

.tile3_187

 EQUB %00000000          ; 8CB0: 00          .
 EQUB %00000000          ; 8CB1: 00          .
 EQUB %00000000          ; 8CB2: 00          .
 EQUB %00000000          ; 8CB3: 00          .
 EQUB %00000000          ; 8CB4: 00          .
 EQUB %00000000          ; 8CB5: 00          .
 EQUB %00000000          ; 8CB6: 00          .
 EQUB %00000000          ; 8CB7: 00          .
 EQUB %00000000          ; 8CB8: 00          .
 EQUB %00000000          ; 8CB9: 00          .
 EQUB %00000000          ; 8CBA: 00          .
 EQUB %00000000          ; 8CBB: 00          .
 EQUB %00000000          ; 8CBC: 00          .
 EQUB %00000000          ; 8CBD: 00          .
 EQUB %00000000          ; 8CBE: 00          .
 EQUB %00000000          ; 8CBF: 00          .

; ******************************************************************************
;
;       Name: tile3_188
;       Type: Variable
;   Category: Drawing images
;    Summary: ???
;
; ******************************************************************************

.tile3_188

 EQUB %00000000          ; 8CC0: 00          .
 EQUB %00000000          ; 8CC1: 00          .
 EQUB %00000000          ; 8CC2: 00          .
 EQUB %00000000          ; 8CC3: 00          .
 EQUB %00000000          ; 8CC4: 00          .
 EQUB %00000000          ; 8CC5: 00          .
 EQUB %00000000          ; 8CC6: 00          .
 EQUB %00000000          ; 8CC7: 00          .
 EQUB %00000000          ; 8CC8: 00          .
 EQUB %00000000          ; 8CC9: 00          .
 EQUB %00000000          ; 8CCA: 00          .
 EQUB %00000000          ; 8CCB: 00          .
 EQUB %00000000          ; 8CCC: 00          .
 EQUB %00000000          ; 8CCD: 00          .
 EQUB %00000000          ; 8CCE: 00          .
 EQUB %00000000          ; 8CCF: 00          .

; ******************************************************************************
;
;       Name: tile3_189
;       Type: Variable
;   Category: Drawing images
;    Summary: ???
;
; ******************************************************************************

.tile3_189

 EQUB %00000000          ; 8CD0: 00          .
 EQUB %00000000          ; 8CD1: 00          .
 EQUB %00000000          ; 8CD2: 00          .
 EQUB %00000000          ; 8CD3: 00          .
 EQUB %00000000          ; 8CD4: 00          .
 EQUB %00000000          ; 8CD5: 00          .
 EQUB %00000000          ; 8CD6: 00          .
 EQUB %00000000          ; 8CD7: 00          .
 EQUB %00000000          ; 8CD8: 00          .
 EQUB %00000000          ; 8CD9: 00          .
 EQUB %00000000          ; 8CDA: 00          .
 EQUB %00000000          ; 8CDB: 00          .
 EQUB %00000000          ; 8CDC: 00          .
 EQUB %00000000          ; 8CDD: 00          .
 EQUB %00000000          ; 8CDE: 00          .
 EQUB %00000000          ; 8CDF: 00          .

; ******************************************************************************
;
;       Name: tile3_190
;       Type: Variable
;   Category: Drawing images
;    Summary: ???
;
; ******************************************************************************

.tile3_190

 EQUB %00000000          ; 8CE0: 00          .
 EQUB %00000000          ; 8CE1: 00          .
 EQUB %00000000          ; 8CE2: 00          .
 EQUB %00000000          ; 8CE3: 00          .
 EQUB %00000000          ; 8CE4: 00          .
 EQUB %00000000          ; 8CE5: 00          .
 EQUB %00000000          ; 8CE6: 00          .
 EQUB %00000000          ; 8CE7: 00          .
 EQUB %00000000          ; 8CE8: 00          .
 EQUB %00000000          ; 8CE9: 00          .
 EQUB %00000000          ; 8CEA: 00          .
 EQUB %00000000          ; 8CEB: 00          .
 EQUB %00000000          ; 8CEC: 00          .
 EQUB %00000000          ; 8CED: 00          .
 EQUB %00000000          ; 8CEE: 00          .
 EQUB %00000000          ; 8CEF: 00          .

; ******************************************************************************
;
;       Name: tile3_191
;       Type: Variable
;   Category: Drawing images
;    Summary: ???
;
; ******************************************************************************

.tile3_191

 EQUB %00000000          ; 8CF0: 00          .
 EQUB %00000000          ; 8CF1: 00          .
 EQUB %00000000          ; 8CF2: 00          .
 EQUB %00000000          ; 8CF3: 00          .
 EQUB %00000000          ; 8CF4: 00          .
 EQUB %00000000          ; 8CF5: 00          .
 EQUB %00000000          ; 8CF6: 00          .
 EQUB %00000000          ; 8CF7: 00          .
 EQUB %00000000          ; 8CF8: 00          .
 EQUB %00000000          ; 8CF9: 00          .
 EQUB %00000000          ; 8CFA: 00          .
 EQUB %00000000          ; 8CFB: 00          .
 EQUB %00000000          ; 8CFC: 00          .
 EQUB %00000000          ; 8CFD: 00          .
 EQUB %00000000          ; 8CFE: 00          .
 EQUB %00000000          ; 8CFF: 00          .

; ******************************************************************************
;
;       Name: tile3_192
;       Type: Variable
;   Category: Drawing images
;    Summary: ???
;
; ******************************************************************************

.tile3_192

 EQUB %00000000          ; 8D00: 00          .
 EQUB %00000000          ; 8D01: 00          .
 EQUB %00000000          ; 8D02: 00          .
 EQUB %00000000          ; 8D03: 00          .
 EQUB %00000000          ; 8D04: 00          .
 EQUB %00000000          ; 8D05: 00          .
 EQUB %00000000          ; 8D06: 00          .
 EQUB %00000000          ; 8D07: 00          .
 EQUB %11111110          ; 8D08: FE          .
 EQUB %11111111          ; 8D09: FF          .
 EQUB %11111111          ; 8D0A: FF          .
 EQUB %11111111          ; 8D0B: FF          .
 EQUB %11111111          ; 8D0C: FF          .
 EQUB %11111111          ; 8D0D: FF          .
 EQUB %11111111          ; 8D0E: FF          .
 EQUB %11111111          ; 8D0F: FF          .

; ******************************************************************************
;
;       Name: tile3_193
;       Type: Variable
;   Category: Drawing images
;    Summary: ???
;
; ******************************************************************************

.tile3_193

 EQUB %00000000          ; 8D10: 00          .
 EQUB %00000000          ; 8D11: 00          .
 EQUB %00000000          ; 8D12: 00          .
 EQUB %00000000          ; 8D13: 00          .
 EQUB %00000000          ; 8D14: 00          .
 EQUB %00000000          ; 8D15: 00          .
 EQUB %00000000          ; 8D16: 00          .
 EQUB %00000000          ; 8D17: 00          .
 EQUB %00000000          ; 8D18: 00          .
 EQUB %00000001          ; 8D19: 01          .
 EQUB %00000001          ; 8D1A: 01          .
 EQUB %01111101          ; 8D1B: 7D          }
 EQUB %01111101          ; 8D1C: 7D          }
 EQUB %10111011          ; 8D1D: BB          .
 EQUB %10111011          ; 8D1E: BB          .
 EQUB %10111011          ; 8D1F: BB          .

; ******************************************************************************
;
;       Name: tile3_194
;       Type: Variable
;   Category: Drawing images
;    Summary: ???
;
; ******************************************************************************

.tile3_194

 EQUB %00000000          ; 8D20: 00          .
 EQUB %00000000          ; 8D21: 00          .
 EQUB %00000000          ; 8D22: 00          .
 EQUB %00000000          ; 8D23: 00          .
 EQUB %00000000          ; 8D24: 00          .
 EQUB %00000000          ; 8D25: 00          .
 EQUB %00000000          ; 8D26: 00          .
 EQUB %00000000          ; 8D27: 00          .
 EQUB %11111111          ; 8D28: FF          .
 EQUB %11111111          ; 8D29: FF          .
 EQUB %11111111          ; 8D2A: FF          .
 EQUB %11111111          ; 8D2B: FF          .
 EQUB %11111111          ; 8D2C: FF          .
 EQUB %11111111          ; 8D2D: FF          .
 EQUB %11111111          ; 8D2E: FF          .
 EQUB %11111111          ; 8D2F: FF          .

; ******************************************************************************
;
;       Name: tile3_195
;       Type: Variable
;   Category: Drawing images
;    Summary: ???
;
; ******************************************************************************

.tile3_195

 EQUB %00000000          ; 8D30: 00          .
 EQUB %00000000          ; 8D31: 00          .
 EQUB %00000000          ; 8D32: 00          .
 EQUB %00000000          ; 8D33: 00          .
 EQUB %00000000          ; 8D34: 00          .
 EQUB %00000000          ; 8D35: 00          .
 EQUB %00000000          ; 8D36: 00          .
 EQUB %00000000          ; 8D37: 00          .
 EQUB %11100000          ; 8D38: E0          .
 EQUB %11110000          ; 8D39: F0          .
 EQUB %11110000          ; 8D3A: F0          .
 EQUB %11110111          ; 8D3B: F7          .
 EQUB %11110111          ; 8D3C: F7          .
 EQUB %11111011          ; 8D3D: FB          .
 EQUB %11111011          ; 8D3E: FB          .
 EQUB %11111011          ; 8D3F: FB          .

; ******************************************************************************
;
;       Name: tile3_196
;       Type: Variable
;   Category: Drawing images
;    Summary: ???
;
; ******************************************************************************

.tile3_196

 EQUB %00000000          ; 8D40: 00          .
 EQUB %00000000          ; 8D41: 00          .
 EQUB %00000000          ; 8D42: 00          .
 EQUB %00000000          ; 8D43: 00          .
 EQUB %00000000          ; 8D44: 00          .
 EQUB %00000000          ; 8D45: 00          .
 EQUB %00000000          ; 8D46: 00          .
 EQUB %00000000          ; 8D47: 00          .
 EQUB %00000011          ; 8D48: 03          .
 EQUB %00000011          ; 8D49: 03          .
 EQUB %00000011          ; 8D4A: 03          .
 EQUB %00000011          ; 8D4B: 03          .
 EQUB %00000011          ; 8D4C: 03          .
 EQUB %00000011          ; 8D4D: 03          .
 EQUB %00000111          ; 8D4E: 07          .
 EQUB %00000111          ; 8D4F: 07          .

; ******************************************************************************
;
;       Name: tile3_197
;       Type: Variable
;   Category: Drawing images
;    Summary: ???
;
; ******************************************************************************

.tile3_197

 EQUB %00000000          ; 8D50: 00          .
 EQUB %00000000          ; 8D51: 00          .
 EQUB %00000000          ; 8D52: 00          .
 EQUB %00000000          ; 8D53: 00          .
 EQUB %00000000          ; 8D54: 00          .
 EQUB %00000000          ; 8D55: 00          .
 EQUB %00000000          ; 8D56: 00          .
 EQUB %00000000          ; 8D57: 00          .
 EQUB %11000000          ; 8D58: C0          .
 EQUB %11000000          ; 8D59: C0          .
 EQUB %11000000          ; 8D5A: C0          .
 EQUB %11000000          ; 8D5B: C0          .
 EQUB %11000000          ; 8D5C: C0          .
 EQUB %11000000          ; 8D5D: C0          .
 EQUB %11100000          ; 8D5E: E0          .
 EQUB %11100000          ; 8D5F: E0          .

; ******************************************************************************
;
;       Name: tile3_198
;       Type: Variable
;   Category: Drawing images
;    Summary: ???
;
; ******************************************************************************

.tile3_198

 EQUB %00000000          ; 8D60: 00          .
 EQUB %00000000          ; 8D61: 00          .
 EQUB %00000001          ; 8D62: 01          .
 EQUB %00000000          ; 8D63: 00          .
 EQUB %00000000          ; 8D64: 00          .
 EQUB %00000000          ; 8D65: 00          .
 EQUB %00000000          ; 8D66: 00          .
 EQUB %00000000          ; 8D67: 00          .
 EQUB %00001111          ; 8D68: 0F          .
 EQUB %00011100          ; 8D69: 1C          .
 EQUB %00011101          ; 8D6A: 1D          .
 EQUB %11011110          ; 8D6B: DE          .
 EQUB %11011111          ; 8D6C: DF          .
 EQUB %10111111          ; 8D6D: BF          .
 EQUB %10111111          ; 8D6E: BF          .
 EQUB %10111111          ; 8D6F: BF          .

; ******************************************************************************
;
;       Name: tile3_199
;       Type: Variable
;   Category: Drawing images
;    Summary: ???
;
; ******************************************************************************

.tile3_199

 EQUB %00000000          ; 8D70: 00          .
 EQUB %00000000          ; 8D71: 00          .
 EQUB %11110000          ; 8D72: F0          .
 EQUB %11100000          ; 8D73: E0          .
 EQUB %01000000          ; 8D74: 40          @
 EQUB %00000000          ; 8D75: 00          .
 EQUB %00000000          ; 8D76: 00          .
 EQUB %00000000          ; 8D77: 00          .
 EQUB %11111110          ; 8D78: FE          .
 EQUB %00000111          ; 8D79: 07          .
 EQUB %11110111          ; 8D7A: F7          .
 EQUB %11101111          ; 8D7B: EF          .
 EQUB %01011111          ; 8D7C: 5F          _
 EQUB %10111111          ; 8D7D: BF          .
 EQUB %11111111          ; 8D7E: FF          .
 EQUB %10111111          ; 8D7F: BF          .

; ******************************************************************************
;
;       Name: tile3_200
;       Type: Variable
;   Category: Drawing images
;    Summary: ???
;
; ******************************************************************************

.tile3_200

 EQUB %00000000          ; 8D80: 00          .
 EQUB %00000000          ; 8D81: 00          .
 EQUB %00000000          ; 8D82: 00          .
 EQUB %00000000          ; 8D83: 00          .
 EQUB %00000000          ; 8D84: 00          .
 EQUB %00000000          ; 8D85: 00          .
 EQUB %00000000          ; 8D86: 00          .
 EQUB %00000000          ; 8D87: 00          .
 EQUB %00000000          ; 8D88: 00          .
 EQUB %00000001          ; 8D89: 01          .
 EQUB %00000001          ; 8D8A: 01          .
 EQUB %01111101          ; 8D8B: 7D          }
 EQUB %01111101          ; 8D8C: 7D          }
 EQUB %10111011          ; 8D8D: BB          .
 EQUB %10111010          ; 8D8E: BA          .
 EQUB %10111010          ; 8D8F: BA          .

; ******************************************************************************
;
;       Name: tile3_201
;       Type: Variable
;   Category: Drawing images
;    Summary: ???
;
; ******************************************************************************

.tile3_201

 EQUB %00000000          ; 8D90: 00          .
 EQUB %00000000          ; 8D91: 00          .
 EQUB %00000000          ; 8D92: 00          .
 EQUB %00000000          ; 8D93: 00          .
 EQUB %00000000          ; 8D94: 00          .
 EQUB %00000000          ; 8D95: 00          .
 EQUB %00000000          ; 8D96: 00          .
 EQUB %00000000          ; 8D97: 00          .
 EQUB %11111111          ; 8D98: FF          .
 EQUB %11111111          ; 8D99: FF          .
 EQUB %11111111          ; 8D9A: FF          .
 EQUB %11100000          ; 8D9B: E0          .
 EQUB %10011111          ; 8D9C: 9F          .
 EQUB %01111111          ; 8D9D: 7F          .
 EQUB %11111111          ; 8D9E: FF          .
 EQUB %11111111          ; 8D9F: FF          .

; ******************************************************************************
;
;       Name: tile3_202
;       Type: Variable
;   Category: Drawing images
;    Summary: ???
;
; ******************************************************************************

.tile3_202

 EQUB %00000000          ; 8DA0: 00          .
 EQUB %00000000          ; 8DA1: 00          .
 EQUB %00000000          ; 8DA2: 00          .
 EQUB %00000000          ; 8DA3: 00          .
 EQUB %00000000          ; 8DA4: 00          .
 EQUB %00000000          ; 8DA5: 00          .
 EQUB %00000000          ; 8DA6: 00          .
 EQUB %00000000          ; 8DA7: 00          .
 EQUB %11100000          ; 8DA8: E0          .
 EQUB %11110000          ; 8DA9: F0          .
 EQUB %11110000          ; 8DAA: F0          .
 EQUB %11110111          ; 8DAB: F7          .
 EQUB %00110111          ; 8DAC: 37          7
 EQUB %11011011          ; 8DAD: DB          .
 EQUB %11101011          ; 8DAE: EB          .
 EQUB %11101011          ; 8DAF: EB          .

; ******************************************************************************
;
;       Name: tile3_203
;       Type: Variable
;   Category: Drawing images
;    Summary: ???
;
; ******************************************************************************

.tile3_203

 EQUB %00000000          ; 8DB0: 00          .
 EQUB %00000000          ; 8DB1: 00          .
 EQUB %00000000          ; 8DB2: 00          .
 EQUB %00000000          ; 8DB3: 00          .
 EQUB %00000000          ; 8DB4: 00          .
 EQUB %00000000          ; 8DB5: 00          .
 EQUB %00000000          ; 8DB6: 00          .
 EQUB %00000000          ; 8DB7: 00          .
 EQUB %00001111          ; 8DB8: 0F          .
 EQUB %00011111          ; 8DB9: 1F          .
 EQUB %00011110          ; 8DBA: 1E          .
 EQUB %11011110          ; 8DBB: DE          .
 EQUB %11011110          ; 8DBC: DE          .
 EQUB %10111110          ; 8DBD: BE          .
 EQUB %10111110          ; 8DBE: BE          .
 EQUB %10111000          ; 8DBF: B8          .

; ******************************************************************************
;
;       Name: tile3_204
;       Type: Variable
;   Category: Drawing images
;    Summary: ???
;
; ******************************************************************************

.tile3_204

 EQUB %00000000          ; 8DC0: 00          .
 EQUB %00000000          ; 8DC1: 00          .
 EQUB %00000000          ; 8DC2: 00          .
 EQUB %00000000          ; 8DC3: 00          .
 EQUB %00000000          ; 8DC4: 00          .
 EQUB %00000000          ; 8DC5: 00          .
 EQUB %00000000          ; 8DC6: 00          .
 EQUB %00000000          ; 8DC7: 00          .
 EQUB %11111110          ; 8DC8: FE          .
 EQUB %11111111          ; 8DC9: FF          .
 EQUB %00000011          ; 8DCA: 03          .
 EQUB %00000011          ; 8DCB: 03          .
 EQUB %11111011          ; 8DCC: FB          .
 EQUB %11111011          ; 8DCD: FB          .
 EQUB %11111011          ; 8DCE: FB          .
 EQUB %11100011          ; 8DCF: E3          .

; ******************************************************************************
;
;       Name: tile3_205
;       Type: Variable
;   Category: Drawing images
;    Summary: ???
;
; ******************************************************************************

.tile3_205

 EQUB %00000000          ; 8DD0: 00          .
 EQUB %00000000          ; 8DD1: 00          .
 EQUB %00000000          ; 8DD2: 00          .
 EQUB %00000000          ; 8DD3: 00          .
 EQUB %00000000          ; 8DD4: 00          .
 EQUB %00000000          ; 8DD5: 00          .
 EQUB %00000000          ; 8DD6: 00          .
 EQUB %00000000          ; 8DD7: 00          .
 EQUB %11111111          ; 8DD8: FF          .
 EQUB %11111111          ; 8DD9: FF          .
 EQUB %11111110          ; 8DDA: FE          .
 EQUB %11111100          ; 8DDB: FC          .
 EQUB %11001000          ; 8DDC: C8          .
 EQUB %11001000          ; 8DDD: C8          .
 EQUB %11001000          ; 8DDE: C8          .
 EQUB %11001000          ; 8DDF: C8          .

; ******************************************************************************
;
;       Name: tile3_206
;       Type: Variable
;   Category: Drawing images
;    Summary: ???
;
; ******************************************************************************

.tile3_206

 EQUB %00000000          ; 8DE0: 00          .
 EQUB %00000000          ; 8DE1: 00          .
 EQUB %00000000          ; 8DE2: 00          .
 EQUB %00000000          ; 8DE3: 00          .
 EQUB %00000000          ; 8DE4: 00          .
 EQUB %00000000          ; 8DE5: 00          .
 EQUB %00000000          ; 8DE6: 00          .
 EQUB %00000000          ; 8DE7: 00          .
 EQUB %00001111          ; 8DE8: 0F          .
 EQUB %00011111          ; 8DE9: 1F          .
 EQUB %00011100          ; 8DEA: 1C          .
 EQUB %11011000          ; 8DEB: D8          .
 EQUB %11011000          ; 8DEC: D8          .
 EQUB %10111100          ; 8DED: BC          .
 EQUB %10111000          ; 8DEE: B8          .
 EQUB %10111000          ; 8DEF: B8          .

; ******************************************************************************
;
;       Name: tile3_207
;       Type: Variable
;   Category: Drawing images
;    Summary: ???
;
; ******************************************************************************

.tile3_207

 EQUB %00000000          ; 8DF0: 00          .
 EQUB %00000000          ; 8DF1: 00          .
 EQUB %00000000          ; 8DF2: 00          .
 EQUB %00000000          ; 8DF3: 00          .
 EQUB %00000000          ; 8DF4: 00          .
 EQUB %00000000          ; 8DF5: 00          .
 EQUB %00000000          ; 8DF6: 00          .
 EQUB %00000000          ; 8DF7: 00          .
 EQUB %11111110          ; 8DF8: FE          .
 EQUB %11111111          ; 8DF9: FF          .
 EQUB %11111111          ; 8DFA: FF          .
 EQUB %01111111          ; 8DFB: 7F          .
 EQUB %01100111          ; 8DFC: 67          g
 EQUB %11000011          ; 8DFD: C3          .
 EQUB %01000011          ; 8DFE: 43          C
 EQUB %01100111          ; 8DFF: 67          g

; ******************************************************************************
;
;       Name: tile3_208
;       Type: Variable
;   Category: Drawing images
;    Summary: ???
;
; ******************************************************************************

.tile3_208

 EQUB %00000000          ; 8E00: 00          .
 EQUB %00000000          ; 8E01: 00          .
 EQUB %00011111          ; 8E02: 1F          .
 EQUB %00110001          ; 8E03: 31          1
 EQUB %00111111          ; 8E04: 3F          ?
 EQUB %00101000          ; 8E05: 28          (
 EQUB %00111111          ; 8E06: 3F          ?
 EQUB %00100101          ; 8E07: 25          %
 EQUB %11111111          ; 8E08: FF          .
 EQUB %11111111          ; 8E09: FF          .
 EQUB %11100000          ; 8E0A: E0          .
 EQUB %11000000          ; 8E0B: C0          .
 EQUB %11000000          ; 8E0C: C0          .
 EQUB %11000000          ; 8E0D: C0          .
 EQUB %11000000          ; 8E0E: C0          .
 EQUB %11000000          ; 8E0F: C0          .

; ******************************************************************************
;
;       Name: tile3_209
;       Type: Variable
;   Category: Drawing images
;    Summary: ???
;
; ******************************************************************************

.tile3_209

 EQUB %00000000          ; 8E10: 00          .
 EQUB %00000000          ; 8E11: 00          .
 EQUB %00000000          ; 8E12: 00          .
 EQUB %10000000          ; 8E13: 80          .
 EQUB %10000000          ; 8E14: 80          .
 EQUB %10000000          ; 8E15: 80          .
 EQUB %10000000          ; 8E16: 80          .
 EQUB %10000000          ; 8E17: 80          .
 EQUB %11100000          ; 8E18: E0          .
 EQUB %11110000          ; 8E19: F0          .
 EQUB %01110000          ; 8E1A: 70          p
 EQUB %01110111          ; 8E1B: 77          w
 EQUB %00110111          ; 8E1C: 37          7
 EQUB %00111011          ; 8E1D: 3B          ;
 EQUB %00111011          ; 8E1E: 3B          ;
 EQUB %00111011          ; 8E1F: 3B          ;

; ******************************************************************************
;
;       Name: tile3_210
;       Type: Variable
;   Category: Drawing images
;    Summary: ???
;
; ******************************************************************************

.tile3_210

 EQUB %00000000          ; 8E20: 00          .
 EQUB %00000000          ; 8E21: 00          .
 EQUB %00000000          ; 8E22: 00          .
 EQUB %00000000          ; 8E23: 00          .
 EQUB %00000001          ; 8E24: 01          .
 EQUB %00000000          ; 8E25: 00          .
 EQUB %00000000          ; 8E26: 00          .
 EQUB %00000000          ; 8E27: 00          .
 EQUB %00001111          ; 8E28: 0F          .
 EQUB %00011111          ; 8E29: 1F          .
 EQUB %00011111          ; 8E2A: 1F          .
 EQUB %11011110          ; 8E2B: DE          .
 EQUB %11011101          ; 8E2C: DD          .
 EQUB %10111100          ; 8E2D: BC          .
 EQUB %10111111          ; 8E2E: BF          .
 EQUB %10111100          ; 8E2F: BC          .

; ******************************************************************************
;
;       Name: tile3_211
;       Type: Variable
;   Category: Drawing images
;    Summary: ???
;
; ******************************************************************************

.tile3_211

 EQUB %00000000          ; 8E30: 00          .
 EQUB %00000000          ; 8E31: 00          .
 EQUB %01000000          ; 8E32: 40          @
 EQUB %11100000          ; 8E33: E0          .
 EQUB %11110000          ; 8E34: F0          .
 EQUB %00000000          ; 8E35: 00          .
 EQUB %00000000          ; 8E36: 00          .
 EQUB %00000000          ; 8E37: 00          .
 EQUB %11111110          ; 8E38: FE          .
 EQUB %10111111          ; 8E39: BF          .
 EQUB %01011111          ; 8E3A: 5F          _
 EQUB %11101111          ; 8E3B: EF          .
 EQUB %11110111          ; 8E3C: F7          .
 EQUB %00000111          ; 8E3D: 07          .
 EQUB %11111111          ; 8E3E: FF          .
 EQUB %00000111          ; 8E3F: 07          .

; ******************************************************************************
;
;       Name: tile3_212
;       Type: Variable
;   Category: Drawing images
;    Summary: ???
;
; ******************************************************************************

.tile3_212

 EQUB %00000000          ; 8E40: 00          .
 EQUB %00000000          ; 8E41: 00          .
 EQUB %00000000          ; 8E42: 00          .
 EQUB %00000000          ; 8E43: 00          .
 EQUB %00000000          ; 8E44: 00          .
 EQUB %00000000          ; 8E45: 00          .
 EQUB %00000000          ; 8E46: 00          .
 EQUB %00000000          ; 8E47: 00          .
 EQUB %11111111          ; 8E48: FF          .
 EQUB %11111111          ; 8E49: FF          .
 EQUB %11111111          ; 8E4A: FF          .
 EQUB %11101010          ; 8E4B: EA          .
 EQUB %10011111          ; 8E4C: 9F          .
 EQUB %01111111          ; 8E4D: 7F          .
 EQUB %11111111          ; 8E4E: FF          .
 EQUB %11111111          ; 8E4F: FF          .

; ******************************************************************************
;
;       Name: tile3_213
;       Type: Variable
;   Category: Drawing images
;    Summary: ???
;
; ******************************************************************************

.tile3_213

 EQUB %00000000          ; 8E50: 00          .
 EQUB %00000000          ; 8E51: 00          .
 EQUB %00000000          ; 8E52: 00          .
 EQUB %00000000          ; 8E53: 00          .
 EQUB %00000000          ; 8E54: 00          .
 EQUB %00000000          ; 8E55: 00          .
 EQUB %00000000          ; 8E56: 00          .
 EQUB %00000000          ; 8E57: 00          .
 EQUB %11100000          ; 8E58: E0          .
 EQUB %11110000          ; 8E59: F0          .
 EQUB %11110000          ; 8E5A: F0          .
 EQUB %11110111          ; 8E5B: F7          .
 EQUB %10110111          ; 8E5C: B7          .
 EQUB %11111011          ; 8E5D: FB          .
 EQUB %11111011          ; 8E5E: FB          .
 EQUB %11111011          ; 8E5F: FB          .

; ******************************************************************************
;
;       Name: tile3_214
;       Type: Variable
;   Category: Drawing images
;    Summary: ???
;
; ******************************************************************************

.tile3_214

 EQUB %00000000          ; 8E60: 00          .
 EQUB %00000000          ; 8E61: 00          .
 EQUB %00000100          ; 8E62: 04          .
 EQUB %00000010          ; 8E63: 02          .
 EQUB %00000001          ; 8E64: 01          .
 EQUB %00000000          ; 8E65: 00          .
 EQUB %00000000          ; 8E66: 00          .
 EQUB %00000000          ; 8E67: 00          .
 EQUB %00001111          ; 8E68: 0F          .
 EQUB %00011111          ; 8E69: 1F          .
 EQUB %00011010          ; 8E6A: 1A          .
 EQUB %11011100          ; 8E6B: DC          .
 EQUB %11011110          ; 8E6C: DE          .
 EQUB %10111110          ; 8E6D: BE          .
 EQUB %10111110          ; 8E6E: BE          .
 EQUB %10111000          ; 8E6F: B8          .

; ******************************************************************************
;
;       Name: tile3_215
;       Type: Variable
;   Category: Drawing images
;    Summary: ???
;
; ******************************************************************************

.tile3_215

 EQUB %00000000          ; 8E70: 00          .
 EQUB %00000000          ; 8E71: 00          .
 EQUB %00000100          ; 8E72: 04          .
 EQUB %00001000          ; 8E73: 08          .
 EQUB %00010000          ; 8E74: 10          .
 EQUB %10100000          ; 8E75: A0          .
 EQUB %01000000          ; 8E76: 40          @
 EQUB %10100000          ; 8E77: A0          .
 EQUB %11111110          ; 8E78: FE          .
 EQUB %11111111          ; 8E79: FF          .
 EQUB %00000011          ; 8E7A: 03          .
 EQUB %00000011          ; 8E7B: 03          .
 EQUB %11101011          ; 8E7C: EB          .
 EQUB %01011011          ; 8E7D: 5B          [
 EQUB %10111011          ; 8E7E: BB          .
 EQUB %01000011          ; 8E7F: 43          C

; ******************************************************************************
;
;       Name: tile3_216
;       Type: Variable
;   Category: Drawing images
;    Summary: ???
;
; ******************************************************************************

.tile3_216

 EQUB %00000000          ; 8E80: 00          .
 EQUB %00000000          ; 8E81: 00          .
 EQUB %01000000          ; 8E82: 40          @
 EQUB %00100000          ; 8E83: 20
 EQUB %00010001          ; 8E84: 11          .
 EQUB %00001010          ; 8E85: 0A          .
 EQUB %00000100          ; 8E86: 04          .
 EQUB %00001010          ; 8E87: 0A          .
 EQUB %11111111          ; 8E88: FF          .
 EQUB %11111111          ; 8E89: FF          .
 EQUB %10111110          ; 8E8A: BE          .
 EQUB %11011100          ; 8E8B: DC          .
 EQUB %11001000          ; 8E8C: C8          .
 EQUB %11000000          ; 8E8D: C0          .
 EQUB %11001000          ; 8E8E: C8          .
 EQUB %11000000          ; 8E8F: C0          .

; ******************************************************************************
;
;       Name: tile3_217
;       Type: Variable
;   Category: Drawing images
;    Summary: ???
;
; ******************************************************************************

.tile3_217

 EQUB %00000000          ; 8E90: 00          .
 EQUB %00000000          ; 8E91: 00          .
 EQUB %01000000          ; 8E92: 40          @
 EQUB %10000000          ; 8E93: 80          .
 EQUB %00000000          ; 8E94: 00          .
 EQUB %00000000          ; 8E95: 00          .
 EQUB %00000000          ; 8E96: 00          .
 EQUB %00000000          ; 8E97: 00          .
 EQUB %11100000          ; 8E98: E0          .
 EQUB %11110000          ; 8E99: F0          .
 EQUB %10110000          ; 8E9A: B0          .
 EQUB %01110111          ; 8E9B: 77          w
 EQUB %11110111          ; 8E9C: F7          .
 EQUB %11111011          ; 8E9D: FB          .
 EQUB %11111011          ; 8E9E: FB          .
 EQUB %11111011          ; 8E9F: FB          .

; ******************************************************************************
;
;       Name: tile3_218
;       Type: Variable
;   Category: Drawing images
;    Summary: ???
;
; ******************************************************************************

.tile3_218

 EQUB %00000000          ; 8EA0: 00          .
 EQUB %00000000          ; 8EA1: 00          .
 EQUB %00000000          ; 8EA2: 00          .
 EQUB %00000000          ; 8EA3: 00          .
 EQUB %00000000          ; 8EA4: 00          .
 EQUB %00000000          ; 8EA5: 00          .
 EQUB %00000000          ; 8EA6: 00          .
 EQUB %00000000          ; 8EA7: 00          .
 EQUB %00001111          ; 8EA8: 0F          .
 EQUB %00011111          ; 8EA9: 1F          .
 EQUB %00011111          ; 8EAA: 1F          .
 EQUB %11011110          ; 8EAB: DE          .
 EQUB %11011110          ; 8EAC: DE          .
 EQUB %10111110          ; 8EAD: BE          .
 EQUB %10111111          ; 8EAE: BF          .
 EQUB %10111110          ; 8EAF: BE          .

; ******************************************************************************
;
;       Name: tile3_219
;       Type: Variable
;   Category: Drawing images
;    Summary: ???
;
; ******************************************************************************

.tile3_219

 EQUB %00000000          ; 8EB0: 00          .
 EQUB %00000000          ; 8EB1: 00          .
 EQUB %00000000          ; 8EB2: 00          .
 EQUB %00000000          ; 8EB3: 00          .
 EQUB %00000000          ; 8EB4: 00          .
 EQUB %00000000          ; 8EB5: 00          .
 EQUB %00000000          ; 8EB6: 00          .
 EQUB %00000000          ; 8EB7: 00          .
 EQUB %11111110          ; 8EB8: FE          .
 EQUB %11111111          ; 8EB9: FF          .
 EQUB %00011111          ; 8EBA: 1F          .
 EQUB %00001111          ; 8EBB: 0F          .
 EQUB %00001111          ; 8EBC: 0F          .
 EQUB %00001111          ; 8EBD: 0F          .
 EQUB %00011111          ; 8EBE: 1F          .
 EQUB %00001111          ; 8EBF: 0F          .

; ******************************************************************************
;
;       Name: tile3_220
;       Type: Variable
;   Category: Drawing images
;    Summary: ???
;
; ******************************************************************************

.tile3_220

 EQUB %00000000          ; 8EC0: 00          .
 EQUB %00000000          ; 8EC1: 00          .
 EQUB %00000000          ; 8EC2: 00          .
 EQUB %00000000          ; 8EC3: 00          .
 EQUB %00000000          ; 8EC4: 00          .
 EQUB %00000000          ; 8EC5: 00          .
 EQUB %00000000          ; 8EC6: 00          .
 EQUB %00000000          ; 8EC7: 00          .
 EQUB %00000000          ; 8EC8: 00          .
 EQUB %00000000          ; 8EC9: 00          .
 EQUB %00000000          ; 8ECA: 00          .
 EQUB %00000000          ; 8ECB: 00          .
 EQUB %00000000          ; 8ECC: 00          .
 EQUB %00000000          ; 8ECD: 00          .
 EQUB %00000000          ; 8ECE: 00          .
 EQUB %00000000          ; 8ECF: 00          .

; ******************************************************************************
;
;       Name: tile3_221
;       Type: Variable
;   Category: Drawing images
;    Summary: ???
;
; ******************************************************************************

.tile3_221

 EQUB %00000000          ; 8ED0: 00          .
 EQUB %00000000          ; 8ED1: 00          .
 EQUB %00000000          ; 8ED2: 00          .
 EQUB %00000000          ; 8ED3: 00          .
 EQUB %00000000          ; 8ED4: 00          .
 EQUB %00000000          ; 8ED5: 00          .
 EQUB %00000000          ; 8ED6: 00          .
 EQUB %00000000          ; 8ED7: 00          .
 EQUB %00000000          ; 8ED8: 00          .
 EQUB %00000000          ; 8ED9: 00          .
 EQUB %00000000          ; 8EDA: 00          .
 EQUB %00000000          ; 8EDB: 00          .
 EQUB %00000000          ; 8EDC: 00          .
 EQUB %00000000          ; 8EDD: 00          .
 EQUB %00000000          ; 8EDE: 00          .
 EQUB %00000000          ; 8EDF: 00          .

; ******************************************************************************
;
;       Name: tile3_222
;       Type: Variable
;   Category: Drawing images
;    Summary: ???
;
; ******************************************************************************

.tile3_222

 EQUB %00000000          ; 8EE0: 00          .
 EQUB %00000000          ; 8EE1: 00          .
 EQUB %00000000          ; 8EE2: 00          .
 EQUB %00000000          ; 8EE3: 00          .
 EQUB %00000000          ; 8EE4: 00          .
 EQUB %00000000          ; 8EE5: 00          .
 EQUB %00000000          ; 8EE6: 00          .
 EQUB %00000000          ; 8EE7: 00          .
 EQUB %00000000          ; 8EE8: 00          .
 EQUB %00000000          ; 8EE9: 00          .
 EQUB %00000000          ; 8EEA: 00          .
 EQUB %00000000          ; 8EEB: 00          .
 EQUB %00000000          ; 8EEC: 00          .
 EQUB %00000000          ; 8EED: 00          .
 EQUB %00000000          ; 8EEE: 00          .
 EQUB %00000000          ; 8EEF: 00          .

; ******************************************************************************
;
;       Name: tile3_223
;       Type: Variable
;   Category: Drawing images
;    Summary: ???
;
; ******************************************************************************

.tile3_223

 EQUB %00000000          ; 8EF0: 00          .
 EQUB %00000000          ; 8EF1: 00          .
 EQUB %00000000          ; 8EF2: 00          .
 EQUB %00100000          ; 8EF3: 20
 EQUB %00011111          ; 8EF4: 1F          .
 EQUB %00000000          ; 8EF5: 00          .
 EQUB %00100000          ; 8EF6: 20
 EQUB %00000000          ; 8EF7: 00          .
 EQUB %00111111          ; 8EF8: 3F          ?
 EQUB %00111111          ; 8EF9: 3F          ?
 EQUB %00111111          ; 8EFA: 3F          ?
 EQUB %00011111          ; 8EFB: 1F          .
 EQUB %00100000          ; 8EFC: 20
 EQUB %00000000          ; 8EFD: 00          .
 EQUB %01011111          ; 8EFE: 5F          _
 EQUB %01000000          ; 8EFF: 40          @

; ******************************************************************************
;
;       Name: tile3_224
;       Type: Variable
;   Category: Drawing images
;    Summary: ???
;
; ******************************************************************************

.tile3_224

 EQUB %00000000          ; 8F00: 00          .
 EQUB %00000000          ; 8F01: 00          .
 EQUB %00000000          ; 8F02: 00          .
 EQUB %00000000          ; 8F03: 00          .
 EQUB %11111111          ; 8F04: FF          .
 EQUB %00000000          ; 8F05: 00          .
 EQUB %00000000          ; 8F06: 00          .
 EQUB %00000000          ; 8F07: 00          .
 EQUB %11111111          ; 8F08: FF          .
 EQUB %11111111          ; 8F09: FF          .
 EQUB %11111111          ; 8F0A: FF          .
 EQUB %11111111          ; 8F0B: FF          .
 EQUB %00000000          ; 8F0C: 00          .
 EQUB %00000000          ; 8F0D: 00          .
 EQUB %11111111          ; 8F0E: FF          .
 EQUB %00000000          ; 8F0F: 00          .

; ******************************************************************************
;
;       Name: tile3_225
;       Type: Variable
;   Category: Drawing images
;    Summary: ???
;
; ******************************************************************************

.tile3_225

 EQUB %00000000          ; 8F10: 00          .
 EQUB %00000000          ; 8F11: 00          .
 EQUB %00000000          ; 8F12: 00          .
 EQUB %10000010          ; 8F13: 82          .
 EQUB %00000001          ; 8F14: 01          .
 EQUB %00010000          ; 8F15: 10          .
 EQUB %10010010          ; 8F16: 92          .
 EQUB %00010000          ; 8F17: 10          .
 EQUB %10010011          ; 8F18: 93          .
 EQUB %10010011          ; 8F19: 93          .
 EQUB %10010011          ; 8F1A: 93          .
 EQUB %00010001          ; 8F1B: 11          .
 EQUB %10010010          ; 8F1C: 92          .
 EQUB %00000000          ; 8F1D: 00          .
 EQUB %01000101          ; 8F1E: 45          E
 EQUB %01000100          ; 8F1F: 44          D

; ******************************************************************************
;
;       Name: tile3_226
;       Type: Variable
;   Category: Drawing images
;    Summary: ???
;
; ******************************************************************************

.tile3_226

 EQUB %00000000          ; 8F20: 00          .
 EQUB %00000000          ; 8F21: 00          .
 EQUB %00000000          ; 8F22: 00          .
 EQUB %00001000          ; 8F23: 08          .
 EQUB %11110000          ; 8F24: F0          .
 EQUB %00000001          ; 8F25: 01          .
 EQUB %00001001          ; 8F26: 09          .
 EQUB %00000001          ; 8F27: 01          .
 EQUB %11111001          ; 8F28: F9          .
 EQUB %11111001          ; 8F29: F9          .
 EQUB %11111001          ; 8F2A: F9          .
 EQUB %11110001          ; 8F2B: F1          .
 EQUB %00001001          ; 8F2C: 09          .
 EQUB %00000000          ; 8F2D: 00          .
 EQUB %11110100          ; 8F2E: F4          .
 EQUB %00000100          ; 8F2F: 04          .

; ******************************************************************************
;
;       Name: tile3_227
;       Type: Variable
;   Category: Drawing images
;    Summary: ???
;
; ******************************************************************************

.tile3_227

 EQUB %00000000          ; 8F30: 00          .
 EQUB %00000000          ; 8F31: 00          .
 EQUB %00000000          ; 8F32: 00          .
 EQUB %00000000          ; 8F33: 00          .
 EQUB %00000000          ; 8F34: 00          .
 EQUB %00000000          ; 8F35: 00          .
 EQUB %00000001          ; 8F36: 01          .
 EQUB %00001011          ; 8F37: 0B          .
 EQUB %00001111          ; 8F38: 0F          .
 EQUB %00001111          ; 8F39: 0F          .
 EQUB %00011111          ; 8F3A: 1F          .
 EQUB %00011111          ; 8F3B: 1F          .
 EQUB %00111111          ; 8F3C: 3F          ?
 EQUB %00111111          ; 8F3D: 3F          ?
 EQUB %01111110          ; 8F3E: 7E          ~
 EQUB %01110100          ; 8F3F: 74          t

; ******************************************************************************
;
;       Name: tile3_228
;       Type: Variable
;   Category: Drawing images
;    Summary: ???
;
; ******************************************************************************

.tile3_228

 EQUB %00000000          ; 8F40: 00          .
 EQUB %00000000          ; 8F41: 00          .
 EQUB %00000000          ; 8F42: 00          .
 EQUB %00000000          ; 8F43: 00          .
 EQUB %00000000          ; 8F44: 00          .
 EQUB %00000000          ; 8F45: 00          .
 EQUB %10000000          ; 8F46: 80          .
 EQUB %11010000          ; 8F47: D0          .
 EQUB %11110000          ; 8F48: F0          .
 EQUB %11110000          ; 8F49: F0          .
 EQUB %11111000          ; 8F4A: F8          .
 EQUB %11111000          ; 8F4B: F8          .
 EQUB %11111100          ; 8F4C: FC          .
 EQUB %11111100          ; 8F4D: FC          .
 EQUB %01111110          ; 8F4E: 7E          ~
 EQUB %00101110          ; 8F4F: 2E          .

; ******************************************************************************
;
;       Name: tile3_229
;       Type: Variable
;   Category: Drawing images
;    Summary: ???
;
; ******************************************************************************

.tile3_229

 EQUB %00000000          ; 8F50: 00          .
 EQUB %00000000          ; 8F51: 00          .
 EQUB %00000001          ; 8F52: 01          .
 EQUB %00100000          ; 8F53: 20
 EQUB %00011111          ; 8F54: 1F          .
 EQUB %00000000          ; 8F55: 00          .
 EQUB %00100000          ; 8F56: 20
 EQUB %00000000          ; 8F57: 00          .
 EQUB %00111111          ; 8F58: 3F          ?
 EQUB %00111110          ; 8F59: 3E          >
 EQUB %00111101          ; 8F5A: 3D          =
 EQUB %00011100          ; 8F5B: 1C          .
 EQUB %00100000          ; 8F5C: 20
 EQUB %00000000          ; 8F5D: 00          .
 EQUB %01011111          ; 8F5E: 5F          _
 EQUB %01000000          ; 8F5F: 40          @

; ******************************************************************************
;
;       Name: tile3_230
;       Type: Variable
;   Category: Drawing images
;    Summary: ???
;
; ******************************************************************************

.tile3_230

 EQUB %01000000          ; 8F60: 40          @
 EQUB %11100000          ; 8F61: E0          .
 EQUB %11110000          ; 8F62: F0          .
 EQUB %00000000          ; 8F63: 00          .
 EQUB %11111111          ; 8F64: FF          .
 EQUB %00000000          ; 8F65: 00          .
 EQUB %00000000          ; 8F66: 00          .
 EQUB %00000000          ; 8F67: 00          .
 EQUB %01011111          ; 8F68: 5F          _
 EQUB %11101111          ; 8F69: EF          .
 EQUB %11110111          ; 8F6A: F7          .
 EQUB %00000111          ; 8F6B: 07          .
 EQUB %00000000          ; 8F6C: 00          .
 EQUB %00000000          ; 8F6D: 00          .
 EQUB %11111111          ; 8F6E: FF          .
 EQUB %00000000          ; 8F6F: 00          .

; ******************************************************************************
;
;       Name: tile3_231
;       Type: Variable
;   Category: Drawing images
;    Summary: ???
;
; ******************************************************************************

.tile3_231

 EQUB %00000000          ; 8F70: 00          .
 EQUB %00000000          ; 8F71: 00          .
 EQUB %00000000          ; 8F72: 00          .
 EQUB %00000000          ; 8F73: 00          .
 EQUB %11111111          ; 8F74: FF          .
 EQUB %00000000          ; 8F75: 00          .
 EQUB %00000000          ; 8F76: 00          .
 EQUB %00000000          ; 8F77: 00          .
 EQUB %01111111          ; 8F78: 7F          .
 EQUB %10011111          ; 8F79: 9F          .
 EQUB %11100000          ; 8F7A: E0          .
 EQUB %11111111          ; 8F7B: FF          .
 EQUB %00000000          ; 8F7C: 00          .
 EQUB %00000000          ; 8F7D: 00          .
 EQUB %11111111          ; 8F7E: FF          .
 EQUB %00000000          ; 8F7F: 00          .

; ******************************************************************************
;
;       Name: tile3_232
;       Type: Variable
;   Category: Drawing images
;    Summary: ???
;
; ******************************************************************************

.tile3_232

 EQUB %00000000          ; 8F80: 00          .
 EQUB %00000000          ; 8F81: 00          .
 EQUB %00000000          ; 8F82: 00          .
 EQUB %00001000          ; 8F83: 08          .
 EQUB %11110000          ; 8F84: F0          .
 EQUB %00000001          ; 8F85: 01          .
 EQUB %00001001          ; 8F86: 09          .
 EQUB %00000000          ; 8F87: 00          .
 EQUB %11011001          ; 8F88: D9          .
 EQUB %00111001          ; 8F89: 39          9
 EQUB %11111001          ; 8F8A: F9          .
 EQUB %11110001          ; 8F8B: F1          .
 EQUB %00001001          ; 8F8C: 09          .
 EQUB %00000000          ; 8F8D: 00          .
 EQUB %11110100          ; 8F8E: F4          .
 EQUB %00000100          ; 8F8F: 04          .

; ******************************************************************************
;
;       Name: tile3_233
;       Type: Variable
;   Category: Drawing images
;    Summary: ???
;
; ******************************************************************************

.tile3_233

 EQUB %00000000          ; 8F90: 00          .
 EQUB %00000000          ; 8F91: 00          .
 EQUB %00000000          ; 8F92: 00          .
 EQUB %00100000          ; 8F93: 20
 EQUB %00011111          ; 8F94: 1F          .
 EQUB %00000000          ; 8F95: 00          .
 EQUB %00100000          ; 8F96: 20
 EQUB %00000000          ; 8F97: 00          .
 EQUB %00110000          ; 8F98: 30          0
 EQUB %00110000          ; 8F99: 30          0
 EQUB %00111001          ; 8F9A: 39          9
 EQUB %00011111          ; 8F9B: 1F          .
 EQUB %00100000          ; 8F9C: 20
 EQUB %00000000          ; 8F9D: 00          .
 EQUB %01011111          ; 8F9E: 5F          _
 EQUB %01000000          ; 8F9F: 40          @

; ******************************************************************************
;
;       Name: tile3_234
;       Type: Variable
;   Category: Drawing images
;    Summary: ???
;
; ******************************************************************************

.tile3_234

 EQUB %00000000          ; 8FA0: 00          .
 EQUB %00000000          ; 8FA1: 00          .
 EQUB %00000000          ; 8FA2: 00          .
 EQUB %00000000          ; 8FA3: 00          .
 EQUB %11111111          ; 8FA4: FF          .
 EQUB %00000000          ; 8FA5: 00          .
 EQUB %00000000          ; 8FA6: 00          .
 EQUB %00000000          ; 8FA7: 00          .
 EQUB %11000011          ; 8FA8: C3          .
 EQUB %11000011          ; 8FA9: C3          .
 EQUB %11100111          ; 8FAA: E7          .
 EQUB %11111111          ; 8FAB: FF          .
 EQUB %00000000          ; 8FAC: 00          .
 EQUB %00000000          ; 8FAD: 00          .
 EQUB %11111111          ; 8FAE: FF          .
 EQUB %00000000          ; 8FAF: 00          .

; ******************************************************************************
;
;       Name: tile3_235
;       Type: Variable
;   Category: Drawing images
;    Summary: ???
;
; ******************************************************************************

.tile3_235

 EQUB %00000000          ; 8FB0: 00          .
 EQUB %00000000          ; 8FB1: 00          .
 EQUB %00000000          ; 8FB2: 00          .
 EQUB %00000000          ; 8FB3: 00          .
 EQUB %11111111          ; 8FB4: FF          .
 EQUB %00000000          ; 8FB5: 00          .
 EQUB %00000000          ; 8FB6: 00          .
 EQUB %00000000          ; 8FB7: 00          .
 EQUB %11001000          ; 8FB8: C8          .
 EQUB %11111100          ; 8FB9: FC          .
 EQUB %11111110          ; 8FBA: FE          .
 EQUB %11111111          ; 8FBB: FF          .
 EQUB %00000000          ; 8FBC: 00          .
 EQUB %00000000          ; 8FBD: 00          .
 EQUB %11111111          ; 8FBE: FF          .
 EQUB %00000000          ; 8FBF: 00          .

; ******************************************************************************
;
;       Name: tile3_236
;       Type: Variable
;   Category: Drawing images
;    Summary: ???
;
; ******************************************************************************

.tile3_236

 EQUB %00000000          ; 8FC0: 00          .
 EQUB %00000000          ; 8FC1: 00          .
 EQUB %00000000          ; 8FC2: 00          .
 EQUB %00000000          ; 8FC3: 00          .
 EQUB %11111111          ; 8FC4: FF          .
 EQUB %00000000          ; 8FC5: 00          .
 EQUB %00000000          ; 8FC6: 00          .
 EQUB %00000000          ; 8FC7: 00          .
 EQUB %11000011          ; 8FC8: C3          .
 EQUB %11000011          ; 8FC9: C3          .
 EQUB %11111111          ; 8FCA: FF          .
 EQUB %11111111          ; 8FCB: FF          .
 EQUB %00000000          ; 8FCC: 00          .
 EQUB %00000000          ; 8FCD: 00          .
 EQUB %11111111          ; 8FCE: FF          .
 EQUB %00000000          ; 8FCF: 00          .

; ******************************************************************************
;
;       Name: tile3_237
;       Type: Variable
;   Category: Drawing images
;    Summary: ???
;
; ******************************************************************************

.tile3_237

 EQUB %00111111          ; 8FD0: 3F          ?
 EQUB %01111111          ; 8FD1: 7F          .
 EQUB %01111111          ; 8FD2: 7F          .
 EQUB %00000000          ; 8FD3: 00          .
 EQUB %11111111          ; 8FD4: FF          .
 EQUB %00000000          ; 8FD5: 00          .
 EQUB %00000000          ; 8FD6: 00          .
 EQUB %00000000          ; 8FD7: 00          .
 EQUB %11000000          ; 8FD8: C0          .
 EQUB %11100100          ; 8FD9: E4          .
 EQUB %11111111          ; 8FDA: FF          .
 EQUB %11111111          ; 8FDB: FF          .
 EQUB %00000000          ; 8FDC: 00          .
 EQUB %00000000          ; 8FDD: 00          .
 EQUB %11111111          ; 8FDE: FF          .
 EQUB %00000000          ; 8FDF: 00          .

; ******************************************************************************
;
;       Name: tile3_238
;       Type: Variable
;   Category: Drawing images
;    Summary: ???
;
; ******************************************************************************

.tile3_238

 EQUB %10000000          ; 8FE0: 80          .
 EQUB %10100000          ; 8FE1: A0          .
 EQUB %11100000          ; 8FE2: E0          .
 EQUB %00001000          ; 8FE3: 08          .
 EQUB %11110000          ; 8FE4: F0          .
 EQUB %00000001          ; 8FE5: 01          .
 EQUB %00001001          ; 8FE6: 09          .
 EQUB %00000001          ; 8FE7: 01          .
 EQUB %00111001          ; 8FE8: 39          9
 EQUB %11111001          ; 8FE9: F9          .
 EQUB %11111001          ; 8FEA: F9          .
 EQUB %11110001          ; 8FEB: F1          .
 EQUB %00001001          ; 8FEC: 09          .
 EQUB %00000000          ; 8FED: 00          .
 EQUB %11110100          ; 8FEE: F4          .
 EQUB %00000100          ; 8FEF: 04          .

; ******************************************************************************
;
;       Name: tile3_239
;       Type: Variable
;   Category: Drawing images
;    Summary: ???
;
; ******************************************************************************

.tile3_239

 EQUB %00000001          ; 8FF0: 01          .
 EQUB %00000000          ; 8FF1: 00          .
 EQUB %00000000          ; 8FF2: 00          .
 EQUB %00100000          ; 8FF3: 20
 EQUB %00011111          ; 8FF4: 1F          .
 EQUB %00000000          ; 8FF5: 00          .
 EQUB %00100000          ; 8FF6: 20
 EQUB %00000000          ; 8FF7: 00          .
 EQUB %00111101          ; 8FF8: 3D          =
 EQUB %00111110          ; 8FF9: 3E          >
 EQUB %00111111          ; 8FFA: 3F          ?
 EQUB %00011111          ; 8FFB: 1F          .
 EQUB %00100000          ; 8FFC: 20
 EQUB %00000000          ; 8FFD: 00          .
 EQUB %01011111          ; 8FFE: 5F          _
 EQUB %01000000          ; 8FFF: 40          @

; ******************************************************************************
;
;       Name: tile3_240
;       Type: Variable
;   Category: Drawing images
;    Summary: ???
;
; ******************************************************************************

.tile3_240

 EQUB %11110000          ; 9000: F0          .
 EQUB %11100000          ; 9001: E0          .
 EQUB %01000000          ; 9002: 40          @
 EQUB %00000000          ; 9003: 00          .
 EQUB %11111111          ; 9004: FF          .
 EQUB %00000000          ; 9005: 00          .
 EQUB %00000000          ; 9006: 00          .
 EQUB %00000000          ; 9007: 00          .
 EQUB %11110111          ; 9008: F7          .
 EQUB %11101111          ; 9009: EF          .
 EQUB %01011111          ; 900A: 5F          _
 EQUB %10111111          ; 900B: BF          .
 EQUB %00000000          ; 900C: 00          .
 EQUB %00000000          ; 900D: 00          .
 EQUB %11111111          ; 900E: FF          .
 EQUB %00000000          ; 900F: 00          .

; ******************************************************************************
;
;       Name: tile3_241
;       Type: Variable
;   Category: Drawing images
;    Summary: ???
;
; ******************************************************************************

.tile3_241

 EQUB %00000000          ; 9010: 00          .
 EQUB %00000000          ; 9011: 00          .
 EQUB %00000000          ; 9012: 00          .
 EQUB %00001000          ; 9013: 08          .
 EQUB %11110000          ; 9014: F0          .
 EQUB %00000001          ; 9015: 01          .
 EQUB %00001001          ; 9016: 09          .
 EQUB %00000001          ; 9017: 01          .
 EQUB %11011001          ; 9018: D9          .
 EQUB %00111001          ; 9019: 39          9
 EQUB %11111001          ; 901A: F9          .
 EQUB %11110001          ; 901B: F1          .
 EQUB %00001001          ; 901C: 09          .
 EQUB %00000000          ; 901D: 00          .
 EQUB %11110100          ; 901E: F4          .
 EQUB %00000100          ; 901F: 04          .

; ******************************************************************************
;
;       Name: tile3_242
;       Type: Variable
;   Category: Drawing images
;    Summary: ???
;
; ******************************************************************************

.tile3_242

 EQUB %00000001          ; 9020: 01          .
 EQUB %00000010          ; 9021: 02          .
 EQUB %00000100          ; 9022: 04          .
 EQUB %00100000          ; 9023: 20
 EQUB %00011111          ; 9024: 1F          .
 EQUB %00000000          ; 9025: 00          .
 EQUB %00100000          ; 9026: 20
 EQUB %00000000          ; 9027: 00          .
 EQUB %00110000          ; 9028: 30          0
 EQUB %00110000          ; 9029: 30          0
 EQUB %00111001          ; 902A: 39          9
 EQUB %00011111          ; 902B: 1F          .
 EQUB %00100000          ; 902C: 20
 EQUB %00000000          ; 902D: 00          .
 EQUB %01011111          ; 902E: 5F          _
 EQUB %01000000          ; 902F: 40          @

; ******************************************************************************
;
;       Name: tile3_243
;       Type: Variable
;   Category: Drawing images
;    Summary: ???
;
; ******************************************************************************

.tile3_243

 EQUB %00010000          ; 9030: 10          .
 EQUB %00001000          ; 9031: 08          .
 EQUB %00000100          ; 9032: 04          .
 EQUB %00000000          ; 9033: 00          .
 EQUB %11111111          ; 9034: FF          .
 EQUB %00000000          ; 9035: 00          .
 EQUB %00000000          ; 9036: 00          .
 EQUB %00000000          ; 9037: 00          .
 EQUB %11000011          ; 9038: C3          .
 EQUB %11000011          ; 9039: C3          .
 EQUB %11100011          ; 903A: E3          .
 EQUB %11111111          ; 903B: FF          .
 EQUB %00000000          ; 903C: 00          .
 EQUB %00000000          ; 903D: 00          .
 EQUB %11111111          ; 903E: FF          .
 EQUB %00000000          ; 903F: 00          .

; ******************************************************************************
;
;       Name: tile3_244
;       Type: Variable
;   Category: Drawing images
;    Summary: ???
;
; ******************************************************************************

.tile3_244

 EQUB %00010001          ; 9040: 11          .
 EQUB %00100000          ; 9041: 20
 EQUB %01000000          ; 9042: 40          @
 EQUB %00000000          ; 9043: 00          .
 EQUB %11111111          ; 9044: FF          .
 EQUB %00000000          ; 9045: 00          .
 EQUB %00000000          ; 9046: 00          .
 EQUB %00000000          ; 9047: 00          .
 EQUB %11001000          ; 9048: C8          .
 EQUB %11011100          ; 9049: DC          .
 EQUB %10111110          ; 904A: BE          .
 EQUB %11111111          ; 904B: FF          .
 EQUB %00000000          ; 904C: 00          .
 EQUB %00000000          ; 904D: 00          .
 EQUB %11111111          ; 904E: FF          .
 EQUB %00000000          ; 904F: 00          .

; ******************************************************************************
;
;       Name: tile3_245
;       Type: Variable
;   Category: Drawing images
;    Summary: ???
;
; ******************************************************************************

.tile3_245

 EQUB %00000000          ; 9050: 00          .
 EQUB %10000000          ; 9051: 80          .
 EQUB %01000000          ; 9052: 40          @
 EQUB %00001000          ; 9053: 08          .
 EQUB %11110000          ; 9054: F0          .
 EQUB %00000001          ; 9055: 01          .
 EQUB %00001001          ; 9056: 09          .
 EQUB %00000001          ; 9057: 01          .
 EQUB %11111001          ; 9058: F9          .
 EQUB %01111001          ; 9059: 79          y
 EQUB %10111001          ; 905A: B9          .
 EQUB %11110001          ; 905B: F1          .
 EQUB %00001001          ; 905C: 09          .
 EQUB %00000000          ; 905D: 00          .
 EQUB %11110100          ; 905E: F4          .
 EQUB %00000100          ; 905F: 04          .

; ******************************************************************************
;
;       Name: tile3_246
;       Type: Variable
;   Category: Drawing images
;    Summary: ???
;
; ******************************************************************************

.tile3_246

 EQUB %00000000          ; 9060: 00          .
 EQUB %00000000          ; 9061: 00          .
 EQUB %00000000          ; 9062: 00          .
 EQUB %00100000          ; 9063: 20
 EQUB %00011111          ; 9064: 1F          .
 EQUB %00000000          ; 9065: 00          .
 EQUB %00100000          ; 9066: 20
 EQUB %00000000          ; 9067: 00          .
 EQUB %00111100          ; 9068: 3C          <
 EQUB %00111100          ; 9069: 3C          <
 EQUB %00111111          ; 906A: 3F          ?
 EQUB %00011111          ; 906B: 1F          .
 EQUB %00100000          ; 906C: 20
 EQUB %00000000          ; 906D: 00          .
 EQUB %01011111          ; 906E: 5F          _
 EQUB %01000000          ; 906F: 40          @

; ******************************************************************************
;
;       Name: tile3_247
;       Type: Variable
;   Category: Drawing images
;    Summary: ???
;
; ******************************************************************************

.tile3_247

 EQUB %00000000          ; 9070: 00          .
 EQUB %00000000          ; 9071: 00          .
 EQUB %00000000          ; 9072: 00          .
 EQUB %00000000          ; 9073: 00          .
 EQUB %11111111          ; 9074: FF          .
 EQUB %00000000          ; 9075: 00          .
 EQUB %00000000          ; 9076: 00          .
 EQUB %00000000          ; 9077: 00          .
 EQUB %00000111          ; 9078: 07          .
 EQUB %00000111          ; 9079: 07          .
 EQUB %11111111          ; 907A: FF          .
 EQUB %11111111          ; 907B: FF          .
 EQUB %00000000          ; 907C: 00          .
 EQUB %00000000          ; 907D: 00          .
 EQUB %11111111          ; 907E: FF          .
 EQUB %00000000          ; 907F: 00          .

; ******************************************************************************
;
;       Name: tile3_248
;       Type: Variable
;   Category: Drawing images
;    Summary: ???
;
; ******************************************************************************

.tile3_248

 EQUB %00000000          ; 9080: 00          .
 EQUB %00000000          ; 9081: 00          .
 EQUB %00000000          ; 9082: 00          .
 EQUB %00000000          ; 9083: 00          .
 EQUB %00000000          ; 9084: 00          .
 EQUB %00000000          ; 9085: 00          .
 EQUB %00000000          ; 9086: 00          .
 EQUB %00000000          ; 9087: 00          .
 EQUB %00000000          ; 9088: 00          .
 EQUB %00000000          ; 9089: 00          .
 EQUB %00000000          ; 908A: 00          .
 EQUB %00000000          ; 908B: 00          .
 EQUB %00000000          ; 908C: 00          .
 EQUB %00000000          ; 908D: 00          .
 EQUB %00000000          ; 908E: 00          .
 EQUB %00000000          ; 908F: 00          .

; ******************************************************************************
;
;       Name: tile3_249
;       Type: Variable
;   Category: Drawing images
;    Summary: ???
;
; ******************************************************************************

.tile3_249

 EQUB %00000000          ; 9090: 00          .
 EQUB %00000000          ; 9091: 00          .
 EQUB %00000000          ; 9092: 00          .
 EQUB %00000000          ; 9093: 00          .
 EQUB %00000000          ; 9094: 00          .
 EQUB %00000000          ; 9095: 00          .
 EQUB %00000000          ; 9096: 00          .
 EQUB %00000000          ; 9097: 00          .
 EQUB %00000000          ; 9098: 00          .
 EQUB %00000000          ; 9099: 00          .
 EQUB %00000000          ; 909A: 00          .
 EQUB %00000000          ; 909B: 00          .
 EQUB %00000000          ; 909C: 00          .
 EQUB %00000000          ; 909D: 00          .
 EQUB %00000000          ; 909E: 00          .
 EQUB %00000000          ; 909F: 00          .

; ******************************************************************************
;
;       Name: tile3_250
;       Type: Variable
;   Category: Drawing images
;    Summary: ???
;
; ******************************************************************************

.tile3_250

 EQUB %00000000          ; 90A0: 00          .
 EQUB %00000000          ; 90A1: 00          .
 EQUB %00000000          ; 90A2: 00          .
 EQUB %00000000          ; 90A3: 00          .
 EQUB %00000000          ; 90A4: 00          .
 EQUB %00000000          ; 90A5: 00          .
 EQUB %00000000          ; 90A6: 00          .
 EQUB %00000000          ; 90A7: 00          .
 EQUB %00000000          ; 90A8: 00          .
 EQUB %00000000          ; 90A9: 00          .
 EQUB %00000000          ; 90AA: 00          .
 EQUB %00000000          ; 90AB: 00          .
 EQUB %00000000          ; 90AC: 00          .
 EQUB %00000000          ; 90AD: 00          .
 EQUB %00000000          ; 90AE: 00          .
 EQUB %00000000          ; 90AF: 00          .

; ******************************************************************************
;
;       Name: tile3_251
;       Type: Variable
;   Category: Drawing images
;    Summary: ???
;
; ******************************************************************************

.tile3_251

 EQUB %00000000          ; 90B0: 00          .
 EQUB %00000000          ; 90B1: 00          .
 EQUB %00000000          ; 90B2: 00          .
 EQUB %00000000          ; 90B3: 00          .
 EQUB %00000000          ; 90B4: 00          .
 EQUB %00000000          ; 90B5: 00          .
 EQUB %00000000          ; 90B6: 00          .
 EQUB %00000000          ; 90B7: 00          .
 EQUB %00000000          ; 90B8: 00          .
 EQUB %00000000          ; 90B9: 00          .
 EQUB %00000000          ; 90BA: 00          .
 EQUB %00000000          ; 90BB: 00          .
 EQUB %00000000          ; 90BC: 00          .
 EQUB %00000000          ; 90BD: 00          .
 EQUB %00000000          ; 90BE: 00          .
 EQUB %00000000          ; 90BF: 00          .

; ******************************************************************************
;
;       Name: tile3_252
;       Type: Variable
;   Category: Drawing images
;    Summary: ???
;
; ******************************************************************************

.tile3_252

 EQUB %00000000          ; 90C0: 00          .
 EQUB %00000000          ; 90C1: 00          .
 EQUB %00000000          ; 90C2: 00          .
 EQUB %00000000          ; 90C3: 00          .
 EQUB %00000000          ; 90C4: 00          .
 EQUB %00000000          ; 90C5: 00          .
 EQUB %00000000          ; 90C6: 00          .
 EQUB %00000000          ; 90C7: 00          .
 EQUB %00000000          ; 90C8: 00          .
 EQUB %00000000          ; 90C9: 00          .
 EQUB %00000000          ; 90CA: 00          .
 EQUB %00000000          ; 90CB: 00          .
 EQUB %00000000          ; 90CC: 00          .
 EQUB %00000000          ; 90CD: 00          .
 EQUB %00000000          ; 90CE: 00          .
 EQUB %00000000          ; 90CF: 00          .

; ******************************************************************************
;
;       Name: tile3_253
;       Type: Variable
;   Category: Drawing images
;    Summary: ???
;
; ******************************************************************************

.tile3_253

 EQUB %00000000          ; 90D0: 00          .
 EQUB %00000000          ; 90D1: 00          .
 EQUB %00000000          ; 90D2: 00          .
 EQUB %00000000          ; 90D3: 00          .
 EQUB %00000000          ; 90D4: 00          .
 EQUB %00000000          ; 90D5: 00          .
 EQUB %00000000          ; 90D6: 00          .
 EQUB %00000000          ; 90D7: 00          .
 EQUB %00000000          ; 90D8: 00          .
 EQUB %00000000          ; 90D9: 00          .
 EQUB %00000000          ; 90DA: 00          .
 EQUB %00000000          ; 90DB: 00          .
 EQUB %00000000          ; 90DC: 00          .
 EQUB %00000000          ; 90DD: 00          .
 EQUB %00000000          ; 90DE: 00          .
 EQUB %00000000          ; 90DF: 00          .

; ******************************************************************************
;
;       Name: tile3_254
;       Type: Variable
;   Category: Drawing images
;    Summary: ???
;
; ******************************************************************************

.tile3_254

 EQUB %00000000          ; 90E0: 00          .
 EQUB %00000000          ; 90E1: 00          .
 EQUB %00000000          ; 90E2: 00          .
 EQUB %00000000          ; 90E3: 00          .
 EQUB %00000000          ; 90E4: 00          .
 EQUB %00000000          ; 90E5: 00          .
 EQUB %00000000          ; 90E6: 00          .
 EQUB %00000000          ; 90E7: 00          .
 EQUB %00000000          ; 90E8: 00          .
 EQUB %00000000          ; 90E9: 00          .
 EQUB %00000000          ; 90EA: 00          .
 EQUB %00000000          ; 90EB: 00          .
 EQUB %00000000          ; 90EC: 00          .
 EQUB %00000000          ; 90ED: 00          .
 EQUB %00000000          ; 90EE: 00          .
 EQUB %00000000          ; 90EF: 00          .

; ******************************************************************************
;
;       Name: tile3_255
;       Type: Variable
;   Category: Drawing images
;    Summary: ???
;
; ******************************************************************************

.tile3_255

 EQUB %00000000          ; 90F0: 00          .
 EQUB %00000000          ; 90F1: 00          .
 EQUB %00000000          ; 90F2: 00          .
 EQUB %00000000          ; 90F3: 00          .
 EQUB %00000000          ; 90F4: 00          .
 EQUB %00000000          ; 90F5: 00          .
 EQUB %00000000          ; 90F6: 00          .
 EQUB %00000000          ; 90F7: 00          .
 EQUB %00000000          ; 90F8: 00          .
 EQUB %00000000          ; 90F9: 00          .
 EQUB %00000000          ; 90FA: 00          .
 EQUB %00000000          ; 90FB: 00          .
 EQUB %00000000          ; 90FC: 00          .
 EQUB %00000000          ; 90FD: 00          .
 EQUB %00000000          ; 90FE: 00          .
 EQUB %00000000          ; 90FF: 00          .

; ******************************************************************************
;
;       Name: tile3_256
;       Type: Variable
;   Category: Drawing images
;    Summary: ???
;
; ******************************************************************************

.tile3_256

 EQUB %00000000          ; 9100: 00          .
 EQUB %00000000          ; 9101: 00          .
 EQUB %00000000          ; 9102: 00          .
 EQUB %00000000          ; 9103: 00          .
 EQUB %00000000          ; 9104: 00          .
 EQUB %00000000          ; 9105: 00          .
 EQUB %00000000          ; 9106: 00          .
 EQUB %00000000          ; 9107: 00          .
 EQUB %00001111          ; 9108: 0F          .
 EQUB %00011111          ; 9109: 1F          .
 EQUB %00011111          ; 910A: 1F          .
 EQUB %11011111          ; 910B: DF          .
 EQUB %11011111          ; 910C: DF          .
 EQUB %10111111          ; 910D: BF          .
 EQUB %10111111          ; 910E: BF          .
 EQUB %10111111          ; 910F: BF          .

; ******************************************************************************
;
;       Name: tile3_257
;       Type: Variable
;   Category: Drawing images
;    Summary: ???
;
; ******************************************************************************

.tile3_257

 EQUB %00000000          ; 9110: 00          .
 EQUB %00000000          ; 9111: 00          .
 EQUB %00000000          ; 9112: 00          .
 EQUB %00000000          ; 9113: 00          .
 EQUB %00000000          ; 9114: 00          .
 EQUB %00000000          ; 9115: 00          .
 EQUB %00000000          ; 9116: 00          .
 EQUB %00000000          ; 9117: 00          .
 EQUB %11111110          ; 9118: FE          .
 EQUB %11111111          ; 9119: FF          .
 EQUB %11111111          ; 911A: FF          .
 EQUB %11111111          ; 911B: FF          .
 EQUB %11111111          ; 911C: FF          .
 EQUB %11111111          ; 911D: FF          .
 EQUB %11111111          ; 911E: FF          .
 EQUB %11111111          ; 911F: FF          .

; ******************************************************************************
;
;       Name: tile3_258
;       Type: Variable
;   Category: Drawing images
;    Summary: ???
;
; ******************************************************************************

.tile3_258

 EQUB %00000000          ; 9120: 00          .
 EQUB %00000000          ; 9121: 00          .
 EQUB %00000000          ; 9122: 00          .
 EQUB %00000000          ; 9123: 00          .
 EQUB %00000000          ; 9124: 00          .
 EQUB %00000000          ; 9125: 00          .
 EQUB %00000000          ; 9126: 00          .
 EQUB %00000000          ; 9127: 00          .
 EQUB %00000000          ; 9128: 00          .
 EQUB %00000001          ; 9129: 01          .
 EQUB %00000001          ; 912A: 01          .
 EQUB %01111101          ; 912B: 7D          }
 EQUB %01111101          ; 912C: 7D          }
 EQUB %10111011          ; 912D: BB          .
 EQUB %10111011          ; 912E: BB          .
 EQUB %10111011          ; 912F: BB          .

; ******************************************************************************
;
;       Name: tile3_259
;       Type: Variable
;   Category: Drawing images
;    Summary: ???
;
; ******************************************************************************

.tile3_259

 EQUB %00000000          ; 9130: 00          .
 EQUB %00000000          ; 9131: 00          .
 EQUB %00000000          ; 9132: 00          .
 EQUB %00000000          ; 9133: 00          .
 EQUB %00000000          ; 9134: 00          .
 EQUB %00000000          ; 9135: 00          .
 EQUB %00000000          ; 9136: 00          .
 EQUB %00000000          ; 9137: 00          .
 EQUB %11111111          ; 9138: FF          .
 EQUB %11111111          ; 9139: FF          .
 EQUB %11111111          ; 913A: FF          .
 EQUB %11111111          ; 913B: FF          .
 EQUB %11111111          ; 913C: FF          .
 EQUB %11111111          ; 913D: FF          .
 EQUB %11111111          ; 913E: FF          .
 EQUB %11111111          ; 913F: FF          .

; ******************************************************************************
;
;       Name: tile3_260
;       Type: Variable
;   Category: Drawing images
;    Summary: ???
;
; ******************************************************************************

.tile3_260

 EQUB %00000000          ; 9140: 00          .
 EQUB %00000000          ; 9141: 00          .
 EQUB %00000000          ; 9142: 00          .
 EQUB %00000000          ; 9143: 00          .
 EQUB %00000000          ; 9144: 00          .
 EQUB %00000000          ; 9145: 00          .
 EQUB %00000000          ; 9146: 00          .
 EQUB %00000000          ; 9147: 00          .
 EQUB %11100000          ; 9148: E0          .
 EQUB %11110000          ; 9149: F0          .
 EQUB %11110000          ; 914A: F0          .
 EQUB %11110111          ; 914B: F7          .
 EQUB %11110111          ; 914C: F7          .
 EQUB %11111011          ; 914D: FB          .
 EQUB %11111011          ; 914E: FB          .
 EQUB %11111011          ; 914F: FB          .

; ******************************************************************************
;
;       Name: tile3_261
;       Type: Variable
;   Category: Drawing images
;    Summary: ???
;
; ******************************************************************************

.tile3_261

 EQUB %00000000          ; 9150: 00          .
 EQUB %00000000          ; 9151: 00          .
 EQUB %00000000          ; 9152: 00          .
 EQUB %00000000          ; 9153: 00          .
 EQUB %00000000          ; 9154: 00          .
 EQUB %00000000          ; 9155: 00          .
 EQUB %00000000          ; 9156: 00          .
 EQUB %00000000          ; 9157: 00          .
 EQUB %00000011          ; 9158: 03          .
 EQUB %00000011          ; 9159: 03          .
 EQUB %00000011          ; 915A: 03          .
 EQUB %00000011          ; 915B: 03          .
 EQUB %00000011          ; 915C: 03          .
 EQUB %00000011          ; 915D: 03          .
 EQUB %00000111          ; 915E: 07          .
 EQUB %00000111          ; 915F: 07          .

; ******************************************************************************
;
;       Name: tile3_262
;       Type: Variable
;   Category: Drawing images
;    Summary: ???
;
; ******************************************************************************

.tile3_262

 EQUB %00000000          ; 9160: 00          .
 EQUB %00000000          ; 9161: 00          .
 EQUB %00000000          ; 9162: 00          .
 EQUB %00000000          ; 9163: 00          .
 EQUB %00000000          ; 9164: 00          .
 EQUB %00000000          ; 9165: 00          .
 EQUB %00000000          ; 9166: 00          .
 EQUB %00000000          ; 9167: 00          .
 EQUB %11000000          ; 9168: C0          .
 EQUB %11000000          ; 9169: C0          .
 EQUB %11000000          ; 916A: C0          .
 EQUB %11000000          ; 916B: C0          .
 EQUB %11000000          ; 916C: C0          .
 EQUB %11000000          ; 916D: C0          .
 EQUB %11100000          ; 916E: E0          .
 EQUB %11100000          ; 916F: E0          .

; ******************************************************************************
;
;       Name: tile3_263
;       Type: Variable
;   Category: Drawing images
;    Summary: ???
;
; ******************************************************************************

.tile3_263

 EQUB %00000000          ; 9170: 00          .
 EQUB %00000000          ; 9171: 00          .
 EQUB %00000000          ; 9172: 00          .
 EQUB %00000000          ; 9173: 00          .
 EQUB %00000000          ; 9174: 00          .
 EQUB %11111000          ; 9175: F8          .
 EQUB %00000000          ; 9176: 00          .
 EQUB %00000000          ; 9177: 00          .
 EQUB %11111111          ; 9178: FF          .
 EQUB %11111111          ; 9179: FF          .
 EQUB %11111111          ; 917A: FF          .
 EQUB %11111111          ; 917B: FF          .
 EQUB %11111111          ; 917C: FF          .
 EQUB %11111111          ; 917D: FF          .
 EQUB %00000111          ; 917E: 07          .
 EQUB %11111111          ; 917F: FF          .

; ******************************************************************************
;
;       Name: tile3_264
;       Type: Variable
;   Category: Drawing images
;    Summary: ???
;
; ******************************************************************************

.tile3_264

 EQUB %00000000          ; 9180: 00          .
 EQUB %00000000          ; 9181: 00          .
 EQUB %11111011          ; 9182: FB          .
 EQUB %11000011          ; 9183: C3          .
 EQUB %11000011          ; 9184: C3          .
 EQUB %11000011          ; 9185: C3          .
 EQUB %11000011          ; 9186: C3          .
 EQUB %11000011          ; 9187: C3          .
 EQUB %11111111          ; 9188: FF          .
 EQUB %11111111          ; 9189: FF          .
 EQUB %11111111          ; 918A: FF          .
 EQUB %11000111          ; 918B: C7          .
 EQUB %11111111          ; 918C: FF          .
 EQUB %11111111          ; 918D: FF          .
 EQUB %11111111          ; 918E: FF          .
 EQUB %11111111          ; 918F: FF          .

; ******************************************************************************
;
;       Name: tile3_265
;       Type: Variable
;   Category: Drawing images
;    Summary: ???
;
; ******************************************************************************

.tile3_265

 EQUB %00000000          ; 9190: 00          .
 EQUB %00000000          ; 9191: 00          .
 EQUB %11101111          ; 9192: EF          .
 EQUB %01101101          ; 9193: 6D          m
 EQUB %01101101          ; 9194: 6D          m
 EQUB %01101101          ; 9195: 6D          m
 EQUB %01101111          ; 9196: 6F          o
 EQUB %01101100          ; 9197: 6C          l
 EQUB %11111111          ; 9198: FF          .
 EQUB %11111111          ; 9199: FF          .
 EQUB %11111111          ; 919A: FF          .
 EQUB %01111101          ; 919B: 7D          }
 EQUB %11111111          ; 919C: FF          .
 EQUB %11111111          ; 919D: FF          .
 EQUB %11111111          ; 919E: FF          .
 EQUB %11111100          ; 919F: FC          .

; ******************************************************************************
;
;       Name: tile3_266
;       Type: Variable
;   Category: Drawing images
;    Summary: ???
;
; ******************************************************************************

.tile3_266

 EQUB %00000000          ; 91A0: 00          .
 EQUB %00000000          ; 91A1: 00          .
 EQUB %10110110          ; 91A2: B6          .
 EQUB %10110110          ; 91A3: B6          .
 EQUB %10110110          ; 91A4: B6          .
 EQUB %10110110          ; 91A5: B6          .
 EQUB %10011110          ; 91A6: 9E          .
 EQUB %00000110          ; 91A7: 06          .
 EQUB %11111111          ; 91A8: FF          .
 EQUB %11111111          ; 91A9: FF          .
 EQUB %11111111          ; 91AA: FF          .
 EQUB %11111111          ; 91AB: FF          .
 EQUB %11111111          ; 91AC: FF          .
 EQUB %11111111          ; 91AD: FF          .
 EQUB %11011111          ; 91AE: DF          .
 EQUB %01100111          ; 91AF: 67          g

; ******************************************************************************
;
;       Name: tile3_267
;       Type: Variable
;   Category: Drawing images
;    Summary: ???
;
; ******************************************************************************

.tile3_267

 EQUB %00000000          ; 91B0: 00          .
 EQUB %00000000          ; 91B1: 00          .
 EQUB %11111011          ; 91B2: FB          .
 EQUB %11011011          ; 91B3: DB          .
 EQUB %11011011          ; 91B4: DB          .
 EQUB %11110011          ; 91B5: F3          .
 EQUB %11011011          ; 91B6: DB          .
 EQUB %11011011          ; 91B7: DB          .
 EQUB %11111111          ; 91B8: FF          .
 EQUB %11111111          ; 91B9: FF          .
 EQUB %11111111          ; 91BA: FF          .
 EQUB %11011111          ; 91BB: DF          .
 EQUB %11111111          ; 91BC: FF          .
 EQUB %11110111          ; 91BD: F7          .
 EQUB %11011111          ; 91BE: DF          .
 EQUB %11111111          ; 91BF: FF          .

; ******************************************************************************
;
;       Name: tile3_268
;       Type: Variable
;   Category: Drawing images
;    Summary: ???
;
; ******************************************************************************

.tile3_268

 EQUB %00000000          ; 91C0: 00          .
 EQUB %00000000          ; 91C1: 00          .
 EQUB %01111101          ; 91C2: 7D          }
 EQUB %01100001          ; 91C3: 61          a
 EQUB %01100001          ; 91C4: 61          a
 EQUB %01101101          ; 91C5: 6D          m
 EQUB %01101101          ; 91C6: 6D          m
 EQUB %01101101          ; 91C7: 6D          m
 EQUB %11111111          ; 91C8: FF          .
 EQUB %11111111          ; 91C9: FF          .
 EQUB %11111111          ; 91CA: FF          .
 EQUB %11100011          ; 91CB: E3          .
 EQUB %11111111          ; 91CC: FF          .
 EQUB %11111111          ; 91CD: FF          .
 EQUB %11111111          ; 91CE: FF          .
 EQUB %11111111          ; 91CF: FF          .

; ******************************************************************************
;
;       Name: tile3_269
;       Type: Variable
;   Category: Drawing images
;    Summary: ???
;
; ******************************************************************************

.tile3_269

 EQUB %00000000          ; 91D0: 00          .
 EQUB %00000000          ; 91D1: 00          .
 EQUB %10110111          ; 91D2: B7          .
 EQUB %10110011          ; 91D3: B3          .
 EQUB %10110011          ; 91D4: B3          .
 EQUB %11110011          ; 91D5: F3          .
 EQUB %10110011          ; 91D6: B3          .
 EQUB %10110011          ; 91D7: B3          .
 EQUB %11111111          ; 91D8: FF          .
 EQUB %11111111          ; 91D9: FF          .
 EQUB %11111111          ; 91DA: FF          .
 EQUB %11111011          ; 91DB: FB          .
 EQUB %11111111          ; 91DC: FF          .
 EQUB %11111111          ; 91DD: FF          .
 EQUB %10111111          ; 91DE: BF          .
 EQUB %11111111          ; 91DF: FF          .

; ******************************************************************************
;
;       Name: tile3_270
;       Type: Variable
;   Category: Drawing images
;    Summary: ???
;
; ******************************************************************************

.tile3_270

 EQUB %00000000          ; 91E0: 00          .
 EQUB %00000000          ; 91E1: 00          .
 EQUB %10000001          ; 91E2: 81          .
 EQUB %00000000          ; 91E3: 00          .
 EQUB %00000000          ; 91E4: 00          .
 EQUB %00000000          ; 91E5: 00          .
 EQUB %00000000          ; 91E6: 00          .
 EQUB %00000000          ; 91E7: 00          .
 EQUB %11111111          ; 91E8: FF          .
 EQUB %11111111          ; 91E9: FF          .
 EQUB %11111111          ; 91EA: FF          .
 EQUB %01111110          ; 91EB: 7E          ~
 EQUB %11111111          ; 91EC: FF          .
 EQUB %11111111          ; 91ED: FF          .
 EQUB %11111111          ; 91EE: FF          .
 EQUB %11111111          ; 91EF: FF          .

; ******************************************************************************
;
;       Name: tile3_271
;       Type: Variable
;   Category: Drawing images
;    Summary: ???
;
; ******************************************************************************

.tile3_271

 EQUB %00000000          ; 91F0: 00          .
 EQUB %00000000          ; 91F1: 00          .
 EQUB %11011111          ; 91F2: DF          .
 EQUB %11011011          ; 91F3: DB          .
 EQUB %11011011          ; 91F4: DB          .
 EQUB %11011011          ; 91F5: DB          .
 EQUB %11011111          ; 91F6: DF          .
 EQUB %11000011          ; 91F7: C3          .
 EQUB %11111111          ; 91F8: FF          .
 EQUB %11111111          ; 91F9: FF          .
 EQUB %11111111          ; 91FA: FF          .
 EQUB %11111011          ; 91FB: FB          .
 EQUB %11111111          ; 91FC: FF          .
 EQUB %11111111          ; 91FD: FF          .
 EQUB %11111111          ; 91FE: FF          .
 EQUB %11100011          ; 91FF: E3          .

; ******************************************************************************
;
;       Name: tile3_272
;       Type: Variable
;   Category: Drawing images
;    Summary: ???
;
; ******************************************************************************

.tile3_272

 EQUB %00000000          ; 9200: 00          .
 EQUB %00000000          ; 9201: 00          .
 EQUB %01111101          ; 9202: 7D          }
 EQUB %01101100          ; 9203: 6C          l
 EQUB %01101100          ; 9204: 6C          l
 EQUB %01101100          ; 9205: 6C          l
 EQUB %01111100          ; 9206: 7C          |
 EQUB %00001100          ; 9207: 0C          .
 EQUB %11111111          ; 9208: FF          .
 EQUB %11111111          ; 9209: FF          .
 EQUB %11111111          ; 920A: FF          .
 EQUB %11101110          ; 920B: EE          .
 EQUB %11111111          ; 920C: FF          .
 EQUB %11111111          ; 920D: FF          .
 EQUB %11111111          ; 920E: FF          .
 EQUB %10001111          ; 920F: 8F          .

; ******************************************************************************
;
;       Name: tile3_273
;       Type: Variable
;   Category: Drawing images
;    Summary: ???
;
; ******************************************************************************

.tile3_273

 EQUB %00000000          ; 9210: 00          .
 EQUB %00000000          ; 9211: 00          .
 EQUB %11000000          ; 9212: C0          .
 EQUB %11000000          ; 9213: C0          .
 EQUB %11000000          ; 9214: C0          .
 EQUB %11000000          ; 9215: C0          .
 EQUB %11000000          ; 9216: C0          .
 EQUB %11011000          ; 9217: D8          .
 EQUB %11111111          ; 9218: FF          .
 EQUB %11111111          ; 9219: FF          .
 EQUB %11111111          ; 921A: FF          .
 EQUB %11111111          ; 921B: FF          .
 EQUB %11111111          ; 921C: FF          .
 EQUB %11111111          ; 921D: FF          .
 EQUB %11111111          ; 921E: FF          .
 EQUB %11111111          ; 921F: FF          .

; ******************************************************************************
;
;       Name: tile3_274
;       Type: Variable
;   Category: Drawing images
;    Summary: ???
;
; ******************************************************************************

.tile3_274

 EQUB %00000000          ; 9220: 00          .
 EQUB %00000000          ; 9221: 00          .
 EQUB %11110000          ; 9222: F0          .
 EQUB %11011000          ; 9223: D8          .
 EQUB %11011000          ; 9224: D8          .
 EQUB %11011000          ; 9225: D8          .
 EQUB %11011000          ; 9226: D8          .
 EQUB %11011011          ; 9227: DB          .
 EQUB %11111111          ; 9228: FF          .
 EQUB %11111111          ; 9229: FF          .
 EQUB %11111111          ; 922A: FF          .
 EQUB %11011111          ; 922B: DF          .
 EQUB %11111111          ; 922C: FF          .
 EQUB %11111111          ; 922D: FF          .
 EQUB %11111111          ; 922E: FF          .
 EQUB %11111111          ; 922F: FF          .

; ******************************************************************************
;
;       Name: tile3_275
;       Type: Variable
;   Category: Drawing images
;    Summary: ???
;
; ******************************************************************************

.tile3_275

 EQUB %00000000          ; 9230: 00          .
 EQUB %00000000          ; 9231: 00          .
 EQUB %01111101          ; 9232: 7D          }
 EQUB %01101101          ; 9233: 6D          m
 EQUB %01101101          ; 9234: 6D          m
 EQUB %01111001          ; 9235: 79          y
 EQUB %01101101          ; 9236: 6D          m
 EQUB %01101101          ; 9237: 6D          m
 EQUB %11111111          ; 9238: FF          .
 EQUB %11111111          ; 9239: FF          .
 EQUB %11111111          ; 923A: FF          .
 EQUB %11101111          ; 923B: EF          .
 EQUB %11111111          ; 923C: FF          .
 EQUB %11111011          ; 923D: FB          .
 EQUB %11101111          ; 923E: EF          .
 EQUB %11101111          ; 923F: EF          .

; ******************************************************************************
;
;       Name: tile3_276
;       Type: Variable
;   Category: Drawing images
;    Summary: ???
;
; ******************************************************************************

.tile3_276

 EQUB %00000000          ; 9240: 00          .
 EQUB %00000000          ; 9241: 00          .
 EQUB %11110111          ; 9242: F7          .
 EQUB %10110110          ; 9243: B6          .
 EQUB %10110110          ; 9244: B6          .
 EQUB %11100111          ; 9245: E7          .
 EQUB %10110110          ; 9246: B6          .
 EQUB %10110110          ; 9247: B6          .
 EQUB %11111111          ; 9248: FF          .
 EQUB %11111111          ; 9249: FF          .
 EQUB %11111111          ; 924A: FF          .
 EQUB %10111110          ; 924B: BE          .
 EQUB %11111111          ; 924C: FF          .
 EQUB %11101111          ; 924D: EF          .
 EQUB %10111110          ; 924E: BE          .
 EQUB %11111111          ; 924F: FF          .

; ******************************************************************************
;
;       Name: tile3_277
;       Type: Variable
;   Category: Drawing images
;    Summary: ???
;
; ******************************************************************************

.tile3_277

 EQUB %00000000          ; 9250: 00          .
 EQUB %00000000          ; 9251: 00          .
 EQUB %11011111          ; 9252: DF          .
 EQUB %11011011          ; 9253: DB          .
 EQUB %11011011          ; 9254: DB          .
 EQUB %11011110          ; 9255: DE          .
 EQUB %11011011          ; 9256: DB          .
 EQUB %11011011          ; 9257: DB          .
 EQUB %11111111          ; 9258: FF          .
 EQUB %11111111          ; 9259: FF          .
 EQUB %11111111          ; 925A: FF          .
 EQUB %11111011          ; 925B: FB          .
 EQUB %11111111          ; 925C: FF          .
 EQUB %11111110          ; 925D: FE          .
 EQUB %11111011          ; 925E: FB          .
 EQUB %11111111          ; 925F: FF          .

; ******************************************************************************
;
;       Name: tile3_278
;       Type: Variable
;   Category: Drawing images
;    Summary: ???
;
; ******************************************************************************

.tile3_278

 EQUB %00000000          ; 9260: 00          .
 EQUB %00000000          ; 9261: 00          .
 EQUB %01111101          ; 9262: 7D          }
 EQUB %01100001          ; 9263: 61          a
 EQUB %01100001          ; 9264: 61          a
 EQUB %01111001          ; 9265: 79          y
 EQUB %01100001          ; 9266: 61          a
 EQUB %01100001          ; 9267: 61          a
 EQUB %11111111          ; 9268: FF          .
 EQUB %11111111          ; 9269: FF          .
 EQUB %11111111          ; 926A: FF          .
 EQUB %11100011          ; 926B: E3          .
 EQUB %11111111          ; 926C: FF          .
 EQUB %11111111          ; 926D: FF          .
 EQUB %11100111          ; 926E: E7          .
 EQUB %11111111          ; 926F: FF          .

; ******************************************************************************
;
;       Name: tile3_279
;       Type: Variable
;   Category: Drawing images
;    Summary: ???
;
; ******************************************************************************

.tile3_279

 EQUB %00000000          ; 9270: 00          .
 EQUB %00000000          ; 9271: 00          .
 EQUB %11110000          ; 9272: F0          .
 EQUB %10110000          ; 9273: B0          .
 EQUB %10110000          ; 9274: B0          .
 EQUB %10110000          ; 9275: B0          .
 EQUB %10110000          ; 9276: B0          .
 EQUB %10110000          ; 9277: B0          .
 EQUB %11111111          ; 9278: FF          .
 EQUB %11111111          ; 9279: FF          .
 EQUB %11111111          ; 927A: FF          .
 EQUB %10111111          ; 927B: BF          .
 EQUB %11111111          ; 927C: FF          .
 EQUB %11111111          ; 927D: FF          .
 EQUB %11111111          ; 927E: FF          .
 EQUB %11111111          ; 927F: FF          .

; ******************************************************************************
;
;       Name: tile3_280
;       Type: Variable
;   Category: Drawing images
;    Summary: ???
;
; ******************************************************************************

.tile3_280

 EQUB %00000000          ; 9280: 00          .
 EQUB %00000000          ; 9281: 00          .
 EQUB %00111110          ; 9282: 3E          >
 EQUB %00110110          ; 9283: 36          6
 EQUB %00110110          ; 9284: 36          6
 EQUB %00111110          ; 9285: 3E          >
 EQUB %00110110          ; 9286: 36          6
 EQUB %00110110          ; 9287: 36          6
 EQUB %11111111          ; 9288: FF          .
 EQUB %11111111          ; 9289: FF          .
 EQUB %11111111          ; 928A: FF          .
 EQUB %11110111          ; 928B: F7          .
 EQUB %11111111          ; 928C: FF          .
 EQUB %11111111          ; 928D: FF          .
 EQUB %11110111          ; 928E: F7          .
 EQUB %11111111          ; 928F: FF          .

; ******************************************************************************
;
;       Name: tile3_281
;       Type: Variable
;   Category: Drawing images
;    Summary: ???
;
; ******************************************************************************

.tile3_281

 EQUB %00000000          ; 9290: 00          .
 EQUB %00000000          ; 9291: 00          .
 EQUB %11111011          ; 9292: FB          .
 EQUB %11011011          ; 9293: DB          .
 EQUB %11011011          ; 9294: DB          .
 EQUB %11011011          ; 9295: DB          .
 EQUB %11011011          ; 9296: DB          .
 EQUB %11011011          ; 9297: DB          .
 EQUB %11111111          ; 9298: FF          .
 EQUB %11111111          ; 9299: FF          .
 EQUB %11111111          ; 929A: FF          .
 EQUB %11011111          ; 929B: DF          .
 EQUB %11111111          ; 929C: FF          .
 EQUB %11111111          ; 929D: FF          .
 EQUB %11111111          ; 929E: FF          .
 EQUB %11111111          ; 929F: FF          .

; ******************************************************************************
;
;       Name: tile3_282
;       Type: Variable
;   Category: Drawing images
;    Summary: ???
;
; ******************************************************************************

.tile3_282

 EQUB %00000000          ; 92A0: 00          .
 EQUB %00000000          ; 92A1: 00          .
 EQUB %11000000          ; 92A2: C0          .
 EQUB %01100000          ; 92A3: 60          `
 EQUB %01100000          ; 92A4: 60          `
 EQUB %01100000          ; 92A5: 60          `
 EQUB %01100000          ; 92A6: 60          `
 EQUB %01100000          ; 92A7: 60          `
 EQUB %11111111          ; 92A8: FF          .
 EQUB %11111111          ; 92A9: FF          .
 EQUB %11111111          ; 92AA: FF          .
 EQUB %01111111          ; 92AB: 7F          .
 EQUB %11111111          ; 92AC: FF          .
 EQUB %11111111          ; 92AD: FF          .
 EQUB %11111111          ; 92AE: FF          .
 EQUB %11111111          ; 92AF: FF          .

; ******************************************************************************
;
;       Name: tile3_283
;       Type: Variable
;   Category: Drawing images
;    Summary: ???
;
; ******************************************************************************

.tile3_283

 EQUB %00000000          ; 92B0: 00          .
 EQUB %00000000          ; 92B1: 00          .
 EQUB %01111000          ; 92B2: 78          x
 EQUB %00110000          ; 92B3: 30          0
 EQUB %00110000          ; 92B4: 30          0
 EQUB %00110000          ; 92B5: 30          0
 EQUB %00110000          ; 92B6: 30          0
 EQUB %00110011          ; 92B7: 33          3
 EQUB %11111111          ; 92B8: FF          .
 EQUB %11111111          ; 92B9: FF          .
 EQUB %11111111          ; 92BA: FF          .
 EQUB %10110111          ; 92BB: B7          .
 EQUB %11111111          ; 92BC: FF          .
 EQUB %11111111          ; 92BD: FF          .
 EQUB %11111111          ; 92BE: FF          .
 EQUB %11111111          ; 92BF: FF          .

; ******************************************************************************
;
;       Name: tile3_284
;       Type: Variable
;   Category: Drawing images
;    Summary: ???
;
; ******************************************************************************

.tile3_284

 EQUB %00000000          ; 92C0: 00          .
 EQUB %00000000          ; 92C1: 00          .
 EQUB %01111101          ; 92C2: 7D          }
 EQUB %01101101          ; 92C3: 6D          m
 EQUB %01101101          ; 92C4: 6D          m
 EQUB %01111001          ; 92C5: 79          y
 EQUB %01101101          ; 92C6: 6D          m
 EQUB %01101101          ; 92C7: 6D          m
 EQUB %11111111          ; 92C8: FF          .
 EQUB %11111111          ; 92C9: FF          .
 EQUB %11111111          ; 92CA: FF          .
 EQUB %11101111          ; 92CB: EF          .
 EQUB %11111111          ; 92CC: FF          .
 EQUB %11111011          ; 92CD: FB          .
 EQUB %11101111          ; 92CE: EF          .
 EQUB %11111111          ; 92CF: FF          .

; ******************************************************************************
;
;       Name: tile3_285
;       Type: Variable
;   Category: Drawing images
;    Summary: ???
;
; ******************************************************************************

.tile3_285

 EQUB %00000000          ; 92D0: 00          .
 EQUB %00000000          ; 92D1: 00          .
 EQUB %11110110          ; 92D2: F6          .
 EQUB %10000110          ; 92D3: 86          .
 EQUB %10000110          ; 92D4: 86          .
 EQUB %11100110          ; 92D5: E6          .
 EQUB %10000110          ; 92D6: 86          .
 EQUB %10000110          ; 92D7: 86          .
 EQUB %11111111          ; 92D8: FF          .
 EQUB %11111111          ; 92D9: FF          .
 EQUB %11111111          ; 92DA: FF          .
 EQUB %10001111          ; 92DB: 8F          .
 EQUB %11111111          ; 92DC: FF          .
 EQUB %11111111          ; 92DD: FF          .
 EQUB %10011111          ; 92DE: 9F          .
 EQUB %11111111          ; 92DF: FF          .

; ******************************************************************************
;
;       Name: tile3_286
;       Type: Variable
;   Category: Drawing images
;    Summary: ???
;
; ******************************************************************************

.tile3_286

 EQUB %00000000          ; 92E0: 00          .
 EQUB %00000000          ; 92E1: 00          .
 EQUB %00011000          ; 92E2: 18          .
 EQUB %00011000          ; 92E3: 18          .
 EQUB %00011000          ; 92E4: 18          .
 EQUB %00011000          ; 92E5: 18          .
 EQUB %00011000          ; 92E6: 18          .
 EQUB %00011000          ; 92E7: 18          .
 EQUB %11111111          ; 92E8: FF          .
 EQUB %11111111          ; 92E9: FF          .
 EQUB %11111111          ; 92EA: FF          .
 EQUB %11111111          ; 92EB: FF          .
 EQUB %11111111          ; 92EC: FF          .
 EQUB %11111111          ; 92ED: FF          .
 EQUB %11111111          ; 92EE: FF          .
 EQUB %11111111          ; 92EF: FF          .

; ******************************************************************************
;
;       Name: tile3_287
;       Type: Variable
;   Category: Drawing images
;    Summary: ???
;
; ******************************************************************************

.tile3_287

 EQUB %00000000          ; 92F0: 00          .
 EQUB %00000000          ; 92F1: 00          .
 EQUB %00000000          ; 92F2: 00          .
 EQUB %00000000          ; 92F3: 00          .
 EQUB %00000000          ; 92F4: 00          .
 EQUB %00011111          ; 92F5: 1F          .
 EQUB %00000000          ; 92F6: 00          .
 EQUB %00000000          ; 92F7: 00          .
 EQUB %11111111          ; 92F8: FF          .
 EQUB %11111111          ; 92F9: FF          .
 EQUB %11111111          ; 92FA: FF          .
 EQUB %11111111          ; 92FB: FF          .
 EQUB %11111111          ; 92FC: FF          .
 EQUB %11111111          ; 92FD: FF          .
 EQUB %11100000          ; 92FE: E0          .
 EQUB %11111111          ; 92FF: FF          .

; ******************************************************************************
;
;       Name: tile3_288
;       Type: Variable
;   Category: Drawing images
;    Summary: ???
;
; ******************************************************************************

.tile3_288

 EQUB %00000000          ; 9300: 00          .
 EQUB %00000000          ; 9301: 00          .
 EQUB %00000000          ; 9302: 00          .
 EQUB %00100000          ; 9303: 20
 EQUB %00011111          ; 9304: 1F          .
 EQUB %00000000          ; 9305: 00          .
 EQUB %00100000          ; 9306: 20
 EQUB %00000000          ; 9307: 00          .
 EQUB %00111111          ; 9308: 3F          ?
 EQUB %00111111          ; 9309: 3F          ?
 EQUB %00111111          ; 930A: 3F          ?
 EQUB %00011111          ; 930B: 1F          .
 EQUB %00100000          ; 930C: 20
 EQUB %00000000          ; 930D: 00          .
 EQUB %01011111          ; 930E: 5F          _
 EQUB %01000000          ; 930F: 40          @

; ******************************************************************************
;
;       Name: tile3_289
;       Type: Variable
;   Category: Drawing images
;    Summary: ???
;
; ******************************************************************************

.tile3_289

 EQUB %00000000          ; 9310: 00          .
 EQUB %00000000          ; 9311: 00          .
 EQUB %00000000          ; 9312: 00          .
 EQUB %00000000          ; 9313: 00          .
 EQUB %11111111          ; 9314: FF          .
 EQUB %00000000          ; 9315: 00          .
 EQUB %00000000          ; 9316: 00          .
 EQUB %00000000          ; 9317: 00          .
 EQUB %11111111          ; 9318: FF          .
 EQUB %11111111          ; 9319: FF          .
 EQUB %11111111          ; 931A: FF          .
 EQUB %11111111          ; 931B: FF          .
 EQUB %00000000          ; 931C: 00          .
 EQUB %00000000          ; 931D: 00          .
 EQUB %11111111          ; 931E: FF          .
 EQUB %00000000          ; 931F: 00          .

; ******************************************************************************
;
;       Name: tile3_290
;       Type: Variable
;   Category: Drawing images
;    Summary: ???
;
; ******************************************************************************

.tile3_290

 EQUB %00000000          ; 9320: 00          .
 EQUB %00000000          ; 9321: 00          .
 EQUB %00000000          ; 9322: 00          .
 EQUB %10000010          ; 9323: 82          .
 EQUB %00000001          ; 9324: 01          .
 EQUB %00010000          ; 9325: 10          .
 EQUB %10010010          ; 9326: 92          .
 EQUB %00010000          ; 9327: 10          .
 EQUB %10010011          ; 9328: 93          .
 EQUB %10010011          ; 9329: 93          .
 EQUB %10010011          ; 932A: 93          .
 EQUB %00010001          ; 932B: 11          .
 EQUB %10010010          ; 932C: 92          .
 EQUB %00000000          ; 932D: 00          .
 EQUB %01000101          ; 932E: 45          E
 EQUB %01000100          ; 932F: 44          D

; ******************************************************************************
;
;       Name: tile3_291
;       Type: Variable
;   Category: Drawing images
;    Summary: ???
;
; ******************************************************************************

.tile3_291

 EQUB %00000000          ; 9330: 00          .
 EQUB %00000000          ; 9331: 00          .
 EQUB %00000000          ; 9332: 00          .
 EQUB %00001000          ; 9333: 08          .
 EQUB %11110000          ; 9334: F0          .
 EQUB %00000001          ; 9335: 01          .
 EQUB %00001001          ; 9336: 09          .
 EQUB %00000001          ; 9337: 01          .
 EQUB %11111001          ; 9338: F9          .
 EQUB %11111001          ; 9339: F9          .
 EQUB %11111001          ; 933A: F9          .
 EQUB %11110001          ; 933B: F1          .
 EQUB %00001001          ; 933C: 09          .
 EQUB %00000000          ; 933D: 00          .
 EQUB %11110100          ; 933E: F4          .
 EQUB %00000100          ; 933F: 04          .

; ******************************************************************************
;
;       Name: tile3_292
;       Type: Variable
;   Category: Drawing images
;    Summary: ???
;
; ******************************************************************************

.tile3_292

 EQUB %00000000          ; 9340: 00          .
 EQUB %00000000          ; 9341: 00          .
 EQUB %00000000          ; 9342: 00          .
 EQUB %00000000          ; 9343: 00          .
 EQUB %00000000          ; 9344: 00          .
 EQUB %00000000          ; 9345: 00          .
 EQUB %00000001          ; 9346: 01          .
 EQUB %00001011          ; 9347: 0B          .
 EQUB %00001111          ; 9348: 0F          .
 EQUB %00001111          ; 9349: 0F          .
 EQUB %00011111          ; 934A: 1F          .
 EQUB %00011111          ; 934B: 1F          .
 EQUB %00111111          ; 934C: 3F          ?
 EQUB %00111111          ; 934D: 3F          ?
 EQUB %01111110          ; 934E: 7E          ~
 EQUB %01110100          ; 934F: 74          t

; ******************************************************************************
;
;       Name: tile3_293
;       Type: Variable
;   Category: Drawing images
;    Summary: ???
;
; ******************************************************************************

.tile3_293

 EQUB %00000000          ; 9350: 00          .
 EQUB %00000000          ; 9351: 00          .
 EQUB %00000000          ; 9352: 00          .
 EQUB %00000000          ; 9353: 00          .
 EQUB %00000000          ; 9354: 00          .
 EQUB %00000000          ; 9355: 00          .
 EQUB %10000000          ; 9356: 80          .
 EQUB %11010000          ; 9357: D0          .
 EQUB %11110000          ; 9358: F0          .
 EQUB %11110000          ; 9359: F0          .
 EQUB %11111000          ; 935A: F8          .
 EQUB %11111000          ; 935B: F8          .
 EQUB %11111100          ; 935C: FC          .
 EQUB %11111100          ; 935D: FC          .
 EQUB %01111110          ; 935E: 7E          ~
 EQUB %00101110          ; 935F: 2E          .

; ******************************************************************************
;
;       Name: tile3_294
;       Type: Variable
;   Category: Drawing images
;    Summary: ???
;
; ******************************************************************************

.tile3_294

 EQUB %11111011          ; 9360: FB          .
 EQUB %00000000          ; 9361: 00          .
 EQUB %00000000          ; 9362: 00          .
 EQUB %00000000          ; 9363: 00          .
 EQUB %11111111          ; 9364: FF          .
 EQUB %00000000          ; 9365: 00          .
 EQUB %00000000          ; 9366: 00          .
 EQUB %00000000          ; 9367: 00          .
 EQUB %11111111          ; 9368: FF          .
 EQUB %00000100          ; 9369: 04          .
 EQUB %11111111          ; 936A: FF          .
 EQUB %11111111          ; 936B: FF          .
 EQUB %00000000          ; 936C: 00          .
 EQUB %00000000          ; 936D: 00          .
 EQUB %11111111          ; 936E: FF          .
 EQUB %00000000          ; 936F: 00          .

; ******************************************************************************
;
;       Name: tile3_295
;       Type: Variable
;   Category: Drawing images
;    Summary: ???
;
; ******************************************************************************

.tile3_295

 EQUB %11101100          ; 9370: EC          .
 EQUB %00000000          ; 9371: 00          .
 EQUB %00000000          ; 9372: 00          .
 EQUB %00000000          ; 9373: 00          .
 EQUB %11111111          ; 9374: FF          .
 EQUB %00000000          ; 9375: 00          .
 EQUB %00000000          ; 9376: 00          .
 EQUB %00000000          ; 9377: 00          .
 EQUB %11111111          ; 9378: FF          .
 EQUB %00010011          ; 9379: 13          .
 EQUB %11111111          ; 937A: FF          .
 EQUB %11111111          ; 937B: FF          .
 EQUB %00000000          ; 937C: 00          .
 EQUB %00000000          ; 937D: 00          .
 EQUB %11111111          ; 937E: FF          .
 EQUB %00000000          ; 937F: 00          .

; ******************************************************************************
;
;       Name: tile3_296
;       Type: Variable
;   Category: Drawing images
;    Summary: ???
;
; ******************************************************************************

.tile3_296

 EQUB %00001100          ; 9380: 0C          .
 EQUB %00000000          ; 9381: 00          .
 EQUB %00000000          ; 9382: 00          .
 EQUB %00000000          ; 9383: 00          .
 EQUB %11111111          ; 9384: FF          .
 EQUB %00000000          ; 9385: 00          .
 EQUB %00000000          ; 9386: 00          .
 EQUB %00000000          ; 9387: 00          .
 EQUB %11111101          ; 9388: FD          .
 EQUB %11110011          ; 9389: F3          .
 EQUB %11111111          ; 938A: FF          .
 EQUB %11111111          ; 938B: FF          .
 EQUB %00000000          ; 938C: 00          .
 EQUB %00000000          ; 938D: 00          .
 EQUB %11111111          ; 938E: FF          .
 EQUB %00000000          ; 938F: 00          .

; ******************************************************************************
;
;       Name: tile3_297
;       Type: Variable
;   Category: Drawing images
;    Summary: ???
;
; ******************************************************************************

.tile3_297

 EQUB %11011011          ; 9390: DB          .
 EQUB %00000000          ; 9391: 00          .
 EQUB %00000000          ; 9392: 00          .
 EQUB %00000000          ; 9393: 00          .
 EQUB %11111111          ; 9394: FF          .
 EQUB %00000000          ; 9395: 00          .
 EQUB %00000000          ; 9396: 00          .
 EQUB %00000000          ; 9397: 00          .
 EQUB %11111111          ; 9398: FF          .
 EQUB %00100100          ; 9399: 24          $
 EQUB %11111111          ; 939A: FF          .
 EQUB %11111111          ; 939B: FF          .
 EQUB %00000000          ; 939C: 00          .
 EQUB %00000000          ; 939D: 00          .
 EQUB %11111111          ; 939E: FF          .
 EQUB %00000000          ; 939F: 00          .

; ******************************************************************************
;
;       Name: tile3_298
;       Type: Variable
;   Category: Drawing images
;    Summary: ???
;
; ******************************************************************************

.tile3_298

 EQUB %01111101          ; 93A0: 7D          }
 EQUB %00000000          ; 93A1: 00          .
 EQUB %00000000          ; 93A2: 00          .
 EQUB %00000000          ; 93A3: 00          .
 EQUB %11111111          ; 93A4: FF          .
 EQUB %00000000          ; 93A5: 00          .
 EQUB %00000000          ; 93A6: 00          .
 EQUB %00000000          ; 93A7: 00          .
 EQUB %11111111          ; 93A8: FF          .
 EQUB %10000010          ; 93A9: 82          .
 EQUB %11111111          ; 93AA: FF          .
 EQUB %11111111          ; 93AB: FF          .
 EQUB %00000000          ; 93AC: 00          .
 EQUB %00000000          ; 93AD: 00          .
 EQUB %11111111          ; 93AE: FF          .
 EQUB %00000000          ; 93AF: 00          .

; ******************************************************************************
;
;       Name: tile3_299
;       Type: Variable
;   Category: Drawing images
;    Summary: ???
;
; ******************************************************************************

.tile3_299

 EQUB %10110011          ; 93B0: B3          .
 EQUB %00000000          ; 93B1: 00          .
 EQUB %00000000          ; 93B2: 00          .
 EQUB %00000000          ; 93B3: 00          .
 EQUB %11111111          ; 93B4: FF          .
 EQUB %00000000          ; 93B5: 00          .
 EQUB %00000000          ; 93B6: 00          .
 EQUB %00000000          ; 93B7: 00          .
 EQUB %11111111          ; 93B8: FF          .
 EQUB %01001100          ; 93B9: 4C          L
 EQUB %11111111          ; 93BA: FF          .
 EQUB %11111111          ; 93BB: FF          .
 EQUB %00000000          ; 93BC: 00          .
 EQUB %00000000          ; 93BD: 00          .
 EQUB %11111111          ; 93BE: FF          .
 EQUB %00000000          ; 93BF: 00          .

; ******************************************************************************
;
;       Name: tile3_300
;       Type: Variable
;   Category: Drawing images
;    Summary: ???
;
; ******************************************************************************

.tile3_300

 EQUB %11000011          ; 93C0: C3          .
 EQUB %00000000          ; 93C1: 00          .
 EQUB %00000000          ; 93C2: 00          .
 EQUB %00000000          ; 93C3: 00          .
 EQUB %11111111          ; 93C4: FF          .
 EQUB %00000000          ; 93C5: 00          .
 EQUB %00000000          ; 93C6: 00          .
 EQUB %00000000          ; 93C7: 00          .
 EQUB %11111111          ; 93C8: FF          .
 EQUB %00111100          ; 93C9: 3C          <
 EQUB %11111111          ; 93CA: FF          .
 EQUB %11111111          ; 93CB: FF          .
 EQUB %00000000          ; 93CC: 00          .
 EQUB %00000000          ; 93CD: 00          .
 EQUB %11111111          ; 93CE: FF          .
 EQUB %00000000          ; 93CF: 00          .

; ******************************************************************************
;
;       Name: tile3_301
;       Type: Variable
;   Category: Drawing images
;    Summary: ???
;
; ******************************************************************************

.tile3_301

 EQUB %00001100          ; 93D0: 0C          .
 EQUB %00000000          ; 93D1: 00          .
 EQUB %00000000          ; 93D2: 00          .
 EQUB %00000000          ; 93D3: 00          .
 EQUB %11111111          ; 93D4: FF          .
 EQUB %00000000          ; 93D5: 00          .
 EQUB %00000000          ; 93D6: 00          .
 EQUB %00000000          ; 93D7: 00          .
 EQUB %11111111          ; 93D8: FF          .
 EQUB %11110011          ; 93D9: F3          .
 EQUB %11111111          ; 93DA: FF          .
 EQUB %11111111          ; 93DB: FF          .
 EQUB %00000000          ; 93DC: 00          .
 EQUB %00000000          ; 93DD: 00          .
 EQUB %11111111          ; 93DE: FF          .
 EQUB %00000000          ; 93DF: 00          .

; ******************************************************************************
;
;       Name: tile3_302
;       Type: Variable
;   Category: Drawing images
;    Summary: ???
;
; ******************************************************************************

.tile3_302

 EQUB %11011000          ; 93E0: D8          .
 EQUB %00000000          ; 93E1: 00          .
 EQUB %00000000          ; 93E2: 00          .
 EQUB %00000000          ; 93E3: 00          .
 EQUB %11111111          ; 93E4: FF          .
 EQUB %00000000          ; 93E5: 00          .
 EQUB %00000000          ; 93E6: 00          .
 EQUB %00000000          ; 93E7: 00          .
 EQUB %11111111          ; 93E8: FF          .
 EQUB %00100111          ; 93E9: 27          '
 EQUB %11111111          ; 93EA: FF          .
 EQUB %11111111          ; 93EB: FF          .
 EQUB %00000000          ; 93EC: 00          .
 EQUB %00000000          ; 93ED: 00          .
 EQUB %11111111          ; 93EE: FF          .
 EQUB %00000000          ; 93EF: 00          .

; ******************************************************************************
;
;       Name: tile3_303
;       Type: Variable
;   Category: Drawing images
;    Summary: ???
;
; ******************************************************************************

.tile3_303

 EQUB %11110011          ; 93F0: F3          .
 EQUB %00000000          ; 93F1: 00          .
 EQUB %00000000          ; 93F2: 00          .
 EQUB %00000000          ; 93F3: 00          .
 EQUB %11111111          ; 93F4: FF          .
 EQUB %00000000          ; 93F5: 00          .
 EQUB %00000000          ; 93F6: 00          .
 EQUB %00000000          ; 93F7: 00          .
 EQUB %11110111          ; 93F8: F7          .
 EQUB %00001100          ; 93F9: 0C          .
 EQUB %11111111          ; 93FA: FF          .
 EQUB %11111111          ; 93FB: FF          .
 EQUB %00000000          ; 93FC: 00          .
 EQUB %00000000          ; 93FD: 00          .
 EQUB %11111111          ; 93FE: FF          .
 EQUB %00000000          ; 93FF: 00          .

; ******************************************************************************
;
;       Name: tile3_304
;       Type: Variable
;   Category: Drawing images
;    Summary: ???
;
; ******************************************************************************

.tile3_304

 EQUB %10110110          ; 9400: B6          .
 EQUB %00000000          ; 9401: 00          .
 EQUB %00000000          ; 9402: 00          .
 EQUB %00000000          ; 9403: 00          .
 EQUB %11111111          ; 9404: FF          .
 EQUB %00000000          ; 9405: 00          .
 EQUB %00000000          ; 9406: 00          .
 EQUB %00000000          ; 9407: 00          .
 EQUB %11111111          ; 9408: FF          .
 EQUB %01001001          ; 9409: 49          I
 EQUB %11111111          ; 940A: FF          .
 EQUB %11111111          ; 940B: FF          .
 EQUB %00000000          ; 940C: 00          .
 EQUB %00000000          ; 940D: 00          .
 EQUB %11111111          ; 940E: FF          .
 EQUB %00000000          ; 940F: 00          .

; ******************************************************************************
;
;       Name: tile3_305
;       Type: Variable
;   Category: Drawing images
;    Summary: ???
;
; ******************************************************************************

.tile3_305

 EQUB %11011111          ; 9410: DF          .
 EQUB %00000000          ; 9411: 00          .
 EQUB %00000000          ; 9412: 00          .
 EQUB %00000000          ; 9413: 00          .
 EQUB %11111111          ; 9414: FF          .
 EQUB %00000000          ; 9415: 00          .
 EQUB %00000000          ; 9416: 00          .
 EQUB %00000000          ; 9417: 00          .
 EQUB %11111111          ; 9418: FF          .
 EQUB %00100000          ; 9419: 20
 EQUB %11111111          ; 941A: FF          .
 EQUB %11111111          ; 941B: FF          .
 EQUB %00000000          ; 941C: 00          .
 EQUB %00000000          ; 941D: 00          .
 EQUB %11111111          ; 941E: FF          .
 EQUB %00000000          ; 941F: 00          .

; ******************************************************************************
;
;       Name: tile3_306
;       Type: Variable
;   Category: Drawing images
;    Summary: ???
;
; ******************************************************************************

.tile3_306

 EQUB %10110000          ; 9420: B0          .
 EQUB %00000000          ; 9421: 00          .
 EQUB %00000000          ; 9422: 00          .
 EQUB %00000000          ; 9423: 00          .
 EQUB %11111111          ; 9424: FF          .
 EQUB %00000000          ; 9425: 00          .
 EQUB %00000000          ; 9426: 00          .
 EQUB %00000000          ; 9427: 00          .
 EQUB %11111111          ; 9428: FF          .
 EQUB %01001111          ; 9429: 4F          O
 EQUB %11111111          ; 942A: FF          .
 EQUB %11111111          ; 942B: FF          .
 EQUB %00000000          ; 942C: 00          .
 EQUB %00000000          ; 942D: 00          .
 EQUB %11111111          ; 942E: FF          .
 EQUB %00000000          ; 942F: 00          .

; ******************************************************************************
;
;       Name: tile3_307
;       Type: Variable
;   Category: Drawing images
;    Summary: ???
;
; ******************************************************************************

.tile3_307

 EQUB %00110110          ; 9430: 36          6
 EQUB %00000000          ; 9431: 00          .
 EQUB %00000000          ; 9432: 00          .
 EQUB %00000000          ; 9433: 00          .
 EQUB %11111111          ; 9434: FF          .
 EQUB %00000000          ; 9435: 00          .
 EQUB %00000000          ; 9436: 00          .
 EQUB %00000000          ; 9437: 00          .
 EQUB %11111111          ; 9438: FF          .
 EQUB %11001001          ; 9439: C9          .
 EQUB %11111111          ; 943A: FF          .
 EQUB %11111111          ; 943B: FF          .
 EQUB %00000000          ; 943C: 00          .
 EQUB %00000000          ; 943D: 00          .
 EQUB %11111111          ; 943E: FF          .
 EQUB %00000000          ; 943F: 00          .

; ******************************************************************************
;
;       Name: tile3_308
;       Type: Variable
;   Category: Drawing images
;    Summary: ???
;
; ******************************************************************************

.tile3_308

 EQUB %11000000          ; 9440: C0          .
 EQUB %00000000          ; 9441: 00          .
 EQUB %00000000          ; 9442: 00          .
 EQUB %00000000          ; 9443: 00          .
 EQUB %11111111          ; 9444: FF          .
 EQUB %00000000          ; 9445: 00          .
 EQUB %00000000          ; 9446: 00          .
 EQUB %00000000          ; 9447: 00          .
 EQUB %11011111          ; 9448: DF          .
 EQUB %00111111          ; 9449: 3F          ?
 EQUB %11111111          ; 944A: FF          .
 EQUB %11111111          ; 944B: FF          .
 EQUB %00000000          ; 944C: 00          .
 EQUB %00000000          ; 944D: 00          .
 EQUB %11111111          ; 944E: FF          .
 EQUB %00000000          ; 944F: 00          .

; ******************************************************************************
;
;       Name: tile3_309
;       Type: Variable
;   Category: Drawing images
;    Summary: ???
;
; ******************************************************************************

.tile3_309

 EQUB %01111011          ; 9450: 7B          {
 EQUB %00000000          ; 9451: 00          .
 EQUB %00000000          ; 9452: 00          .
 EQUB %00000000          ; 9453: 00          .
 EQUB %11111111          ; 9454: FF          .
 EQUB %00000000          ; 9455: 00          .
 EQUB %00000000          ; 9456: 00          .
 EQUB %00000000          ; 9457: 00          .
 EQUB %11111111          ; 9458: FF          .
 EQUB %10000100          ; 9459: 84          .
 EQUB %11111111          ; 945A: FF          .
 EQUB %11111111          ; 945B: FF          .
 EQUB %00000000          ; 945C: 00          .
 EQUB %00000000          ; 945D: 00          .
 EQUB %11111111          ; 945E: FF          .
 EQUB %00000000          ; 945F: 00          .

; ******************************************************************************
;
;       Name: tile3_310
;       Type: Variable
;   Category: Drawing images
;    Summary: ???
;
; ******************************************************************************

.tile3_310

 EQUB %11110111          ; 9460: F7          .
 EQUB %00000000          ; 9461: 00          .
 EQUB %00000000          ; 9462: 00          .
 EQUB %00000000          ; 9463: 00          .
 EQUB %11111111          ; 9464: FF          .
 EQUB %00000000          ; 9465: 00          .
 EQUB %00000000          ; 9466: 00          .
 EQUB %00000000          ; 9467: 00          .
 EQUB %11111111          ; 9468: FF          .
 EQUB %00001000          ; 9469: 08          .
 EQUB %11111111          ; 946A: FF          .
 EQUB %11111111          ; 946B: FF          .
 EQUB %00000000          ; 946C: 00          .
 EQUB %00000000          ; 946D: 00          .
 EQUB %11111111          ; 946E: FF          .
 EQUB %00000000          ; 946F: 00          .

; ******************************************************************************
;
;       Name: tile3_311
;       Type: Variable
;   Category: Drawing images
;    Summary: ???
;
; ******************************************************************************

.tile3_311

 EQUB %00000000          ; 9470: 00          .
 EQUB %00000000          ; 9471: 00          .
 EQUB %00000000          ; 9472: 00          .
 EQUB %00000000          ; 9473: 00          .
 EQUB %00000000          ; 9474: 00          .
 EQUB %00000000          ; 9475: 00          .
 EQUB %00000000          ; 9476: 00          .
 EQUB %00000000          ; 9477: 00          .
 EQUB %00000000          ; 9478: 00          .
 EQUB %00000000          ; 9479: 00          .
 EQUB %00000000          ; 947A: 00          .
 EQUB %00000000          ; 947B: 00          .
 EQUB %00000000          ; 947C: 00          .
 EQUB %00000000          ; 947D: 00          .
 EQUB %00000000          ; 947E: 00          .
 EQUB %00000000          ; 947F: 00          .

; ******************************************************************************
;
;       Name: tile3_312
;       Type: Variable
;   Category: Drawing images
;    Summary: ???
;
; ******************************************************************************

.tile3_312

 EQUB %00000000          ; 9480: 00          .
 EQUB %00000000          ; 9481: 00          .
 EQUB %00000000          ; 9482: 00          .
 EQUB %00000000          ; 9483: 00          .
 EQUB %00000000          ; 9484: 00          .
 EQUB %00000000          ; 9485: 00          .
 EQUB %00000000          ; 9486: 00          .
 EQUB %00000000          ; 9487: 00          .
 EQUB %00000000          ; 9488: 00          .
 EQUB %00000000          ; 9489: 00          .
 EQUB %00000000          ; 948A: 00          .
 EQUB %00000000          ; 948B: 00          .
 EQUB %00000000          ; 948C: 00          .
 EQUB %00000000          ; 948D: 00          .
 EQUB %00000000          ; 948E: 00          .
 EQUB %00000000          ; 948F: 00          .

; ******************************************************************************
;
;       Name: tile3_313
;       Type: Variable
;   Category: Drawing images
;    Summary: ???
;
; ******************************************************************************

.tile3_313

 EQUB %00000000          ; 9490: 00          .
 EQUB %00000000          ; 9491: 00          .
 EQUB %00000000          ; 9492: 00          .
 EQUB %00000000          ; 9493: 00          .
 EQUB %00000000          ; 9494: 00          .
 EQUB %00000000          ; 9495: 00          .
 EQUB %00000000          ; 9496: 00          .
 EQUB %00000000          ; 9497: 00          .
 EQUB %00000000          ; 9498: 00          .
 EQUB %00000000          ; 9499: 00          .
 EQUB %00000000          ; 949A: 00          .
 EQUB %00000000          ; 949B: 00          .
 EQUB %00000000          ; 949C: 00          .
 EQUB %00000000          ; 949D: 00          .
 EQUB %00000000          ; 949E: 00          .
 EQUB %00000000          ; 949F: 00          .

; ******************************************************************************
;
;       Name: tile3_314
;       Type: Variable
;   Category: Drawing images
;    Summary: ???
;
; ******************************************************************************

.tile3_314

 EQUB %00000000          ; 94A0: 00          .
 EQUB %00000000          ; 94A1: 00          .
 EQUB %00000000          ; 94A2: 00          .
 EQUB %00000000          ; 94A3: 00          .
 EQUB %00000000          ; 94A4: 00          .
 EQUB %00000000          ; 94A5: 00          .
 EQUB %00000000          ; 94A6: 00          .
 EQUB %00000000          ; 94A7: 00          .
 EQUB %00000000          ; 94A8: 00          .
 EQUB %00000000          ; 94A9: 00          .
 EQUB %00000000          ; 94AA: 00          .
 EQUB %00000000          ; 94AB: 00          .
 EQUB %00000000          ; 94AC: 00          .
 EQUB %00000000          ; 94AD: 00          .
 EQUB %00000000          ; 94AE: 00          .
 EQUB %00000000          ; 94AF: 00          .

; ******************************************************************************
;
;       Name: tile3_315
;       Type: Variable
;   Category: Drawing images
;    Summary: ???
;
; ******************************************************************************

.tile3_315

 EQUB %00000000          ; 94B0: 00          .
 EQUB %00000000          ; 94B1: 00          .
 EQUB %00000000          ; 94B2: 00          .
 EQUB %00000000          ; 94B3: 00          .
 EQUB %00000000          ; 94B4: 00          .
 EQUB %00000000          ; 94B5: 00          .
 EQUB %00000000          ; 94B6: 00          .
 EQUB %00000000          ; 94B7: 00          .
 EQUB %00000000          ; 94B8: 00          .
 EQUB %00000000          ; 94B9: 00          .
 EQUB %00000000          ; 94BA: 00          .
 EQUB %00000000          ; 94BB: 00          .
 EQUB %00000000          ; 94BC: 00          .
 EQUB %00000000          ; 94BD: 00          .
 EQUB %00000000          ; 94BE: 00          .
 EQUB %00000000          ; 94BF: 00          .

; ******************************************************************************
;
;       Name: tile3_316
;       Type: Variable
;   Category: Drawing images
;    Summary: ???
;
; ******************************************************************************

.tile3_316

 EQUB %00000000          ; 94C0: 00          .
 EQUB %00000000          ; 94C1: 00          .
 EQUB %00000000          ; 94C2: 00          .
 EQUB %00000000          ; 94C3: 00          .
 EQUB %00000000          ; 94C4: 00          .
 EQUB %00000000          ; 94C5: 00          .
 EQUB %00000000          ; 94C6: 00          .
 EQUB %00000000          ; 94C7: 00          .
 EQUB %00000000          ; 94C8: 00          .
 EQUB %00000000          ; 94C9: 00          .
 EQUB %00000000          ; 94CA: 00          .
 EQUB %00000000          ; 94CB: 00          .
 EQUB %00000000          ; 94CC: 00          .
 EQUB %00000000          ; 94CD: 00          .
 EQUB %00000000          ; 94CE: 00          .
 EQUB %00000000          ; 94CF: 00          .

; ******************************************************************************
;
;       Name: tile3_317
;       Type: Variable
;   Category: Drawing images
;    Summary: ???
;
; ******************************************************************************

.tile3_317

 EQUB %00000000          ; 94D0: 00          .
 EQUB %00000000          ; 94D1: 00          .
 EQUB %00000000          ; 94D2: 00          .
 EQUB %00000000          ; 94D3: 00          .
 EQUB %00000000          ; 94D4: 00          .
 EQUB %00000000          ; 94D5: 00          .
 EQUB %00000000          ; 94D6: 00          .
 EQUB %00000000          ; 94D7: 00          .
 EQUB %00000000          ; 94D8: 00          .
 EQUB %00000000          ; 94D9: 00          .
 EQUB %00000000          ; 94DA: 00          .
 EQUB %00000000          ; 94DB: 00          .
 EQUB %00000000          ; 94DC: 00          .
 EQUB %00000000          ; 94DD: 00          .
 EQUB %00000000          ; 94DE: 00          .
 EQUB %00000000          ; 94DF: 00          .

; ******************************************************************************
;
;       Name: tile3_318
;       Type: Variable
;   Category: Drawing images
;    Summary: ???
;
; ******************************************************************************

.tile3_318

 EQUB %00000000          ; 94E0: 00          .
 EQUB %00000000          ; 94E1: 00          .
 EQUB %00000000          ; 94E2: 00          .
 EQUB %00000000          ; 94E3: 00          .
 EQUB %00000000          ; 94E4: 00          .
 EQUB %00000000          ; 94E5: 00          .
 EQUB %00000000          ; 94E6: 00          .
 EQUB %00000000          ; 94E7: 00          .
 EQUB %00000000          ; 94E8: 00          .
 EQUB %00000000          ; 94E9: 00          .
 EQUB %00000000          ; 94EA: 00          .
 EQUB %00000000          ; 94EB: 00          .
 EQUB %00000000          ; 94EC: 00          .
 EQUB %00000000          ; 94ED: 00          .
 EQUB %00000000          ; 94EE: 00          .
 EQUB %00000000          ; 94EF: 00          .

; ******************************************************************************
;
;       Name: tile3_319
;       Type: Variable
;   Category: Drawing images
;    Summary: ???
;
; ******************************************************************************

.tile3_319

 EQUB %00000000          ; 94F0: 00          .
 EQUB %00000000          ; 94F1: 00          .
 EQUB %00000000          ; 94F2: 00          .
 EQUB %00000000          ; 94F3: 00          .
 EQUB %00000000          ; 94F4: 00          .
 EQUB %00000000          ; 94F5: 00          .
 EQUB %00000000          ; 94F6: 00          .
 EQUB %00000000          ; 94F7: 00          .
 EQUB %00000000          ; 94F8: 00          .
 EQUB %00000000          ; 94F9: 00          .
 EQUB %00000000          ; 94FA: 00          .
 EQUB %00000000          ; 94FB: 00          .
 EQUB %00000000          ; 94FC: 00          .
 EQUB %00000000          ; 94FD: 00          .
 EQUB %00000000          ; 94FE: 00          .
 EQUB %00000000          ; 94FF: 00          .

; ******************************************************************************
;
;       Name: L9500
;       Type: Variable
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.L9500

 EQUB $09, $0B, $0C, $06, $0D, $0E, $0F, $10  ; 9500: 09 0B 0C... ...
 EQUB $06, $11, $12, $13, $14, $06, $15, $16  ; 9508: 06 11 12... ...
 EQUB $17, $18, $06, $19, $1A, $1B, $1C, $06  ; 9510: 17 18 06... ...
 EQUB $07, $08, $04, $05, $06, $07, $08, $0A  ; 9518: 07 08 04... ...
 EQUB $28, $2A, $2B, $26, $2C, $2D, $2E, $2F  ; 9520: 28 2A 2B... (*+
 EQUB $26, $30, $31, $24, $32, $26, $33, $34  ; 9528: 26 30 31... $01
 EQUB $24, $35, $26, $36, $37, $38, $39, $26  ; 9530: 24 35 26... $5&
 EQUB $25, $27, $24, $25, $26, $25, $27, $29  ; 9538: 25 27 24... %'$
 EQUB $09, $0B, $0C, $06, $0D, $0E, $0F, $10  ; 9540: 09 0B 0C... ...
 EQUB $06, $11, $12, $13, $14, $15, $16, $17  ; 9548: 06 11 12... ...
 EQUB $18, $19, $1A, $1B, $08, $1C, $1D, $06  ; 9550: 18 19 1A... ...
 EQUB $1E, $1F, $20, $21, $06, $22, $23, $0A  ; 9558: 1E 1F 20... ..
 EQUB $28, $2A, $2B, $26, $2C, $2D, $2E, $2F  ; 9560: 28 2A 2B... (*+
 EQUB $26, $30, $31, $32, $33, $26, $34, $35  ; 9568: 26 30 31... $01
 EQUB $36, $37, $26, $38, $39, $3A, $3B, $26  ; 9570: 36 37 26... 67&
 EQUB $3C, $3D, $3E, $3F, $26, $40, $27, $29  ; 9578: 3C 3D 3E... <=>
 EQUB $09, $0B, $0C, $06, $0D, $0E, $0F, $10  ; 9580: 09 0B 0C... ...
 EQUB $06, $11, $12, $13, $14, $06, $15, $16  ; 9588: 06 11 12... ...
 EQUB $17, $18, $19, $1A, $1B, $1C, $1D, $06  ; 9590: 17 18 19... ...
 EQUB $1E, $1F, $20, $21, $06, $22, $23, $0A  ; 9598: 1E 1F 20... ..
 EQUB $28, $2A, $2B, $26, $2C, $2D, $2E, $2F  ; 95A0: 28 2A 2B... (*+
 EQUB $26, $30, $31, $32, $33, $26, $34, $35  ; 95A8: 26 30 31... $01
 EQUB $24, $36, $26, $37, $38, $39, $3A, $26  ; 95B0: 24 36 26... $6&
 EQUB $3B, $3C, $3D, $3E, $26, $3F, $27, $29  ; 95B8: 3B 3C 3D... ;<=
 EQUB $09, $0B, $0C, $0D, $0E, $0F, $10, $11  ; 95C0: 09 0B 0C... ...
 EQUB $06, $12, $08, $13, $14, $06            ; 95C8: 06 12 08... ...

; ******************************************************************************
;
;       Name: L95CE
;       Type: Variable
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.L95CE

 EQUB $15, $16, $17, $18, $0D, $19, $1A, $1B  ; 95CE: 15 16 17... ...
 EQUB $1C, $06, $1D, $1E, $1F, $20, $06, $15  ; 95D6: 1C 06 1D... ...
 EQUB $16, $0A, $28, $2A, $2B, $26, $2C, $2D  ; 95DE: 16 0A 28... ..(
 EQUB $2E, $2F, $26, $30, $27, $24, $31, $26  ; 95E6: 2E 2F 26... ./&
 EQUB $32, $33, $34, $35, $26, $2C, $36, $37  ; 95EE: 32 33 34... 234
 EQUB $38, $26, $39, $3A, $3B, $3C, $26, $32  ; 95F6: 38 26 39... 8$9
 EQUB $33, $29, $0A, $05, $08, $0C, $0D, $0E  ; 95FE: 33 29 0A... 3).
 EQUB $0F, $10, $11, $12, $13, $14, $15, $16  ; 9606: 0F 10 11... ...
 EQUB $08, $17, $18, $19, $1A, $1B, $1C, $1D  ; 960E: 08 17 18... ...
 EQUB $1E, $1F, $20, $21, $22, $23, $24, $08  ; 9616: 1E 1F 20... ..
 EQUB $09, $0B, $29, $25, $26, $26, $2B, $2C  ; 961E: 09 0B 29... ..)
 EQUB $2D, $2E, $2F, $30, $26, $31, $32, $33  ; 9626: 2D 2E 2F... -./
 EQUB $26, $34, $2F, $35, $36, $2F, $37, $38  ; 962E: 26 34 2F... $4/
 EQUB $2E, $39, $3A, $2F, $3B, $36, $26, $26  ; 9636: 2E 39 3A... .9:
 EQUB $28

; ******************************************************************************
;
;       Name: L963F
;       Type: Variable
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.L963F

 EQUB $2A, $45, $46, $47, $48, $47, $49, $4A  ; 963F: 2A 45 46... *EF
 EQUB $4B, $4C, $4D, $4E, $4F, $4D, $4C, $4D  ; 9647: 4B 4C 4D... KLM
 EQUB $4E, $4F, $4D, $4C, $4D, $50, $4F, $4D  ; 964F: 4E 4F 4D... NOM
 EQUB $4C, $51, $52, $46, $47, $48, $47, $49  ; 9657: 4C 51 52... LQR
 EQUB $53, $54, $55, $55, $55, $55, $56, $57  ; 965F: 53 54 55... STU
 EQUB $58, $59, $00, $5A, $5B, $5C, $5D, $5E  ; 9667: 58 59 00... XY.
 EQUB $5F, $60, $61, $62, $63, $64, $65, $00  ; 966F: 5F 60 61... _`a
 EQUB $66, $67, $68, $69, $6A, $6B, $85, $85  ; 9677: 66 67 68... fgh
 EQUB $6E, $54, $55, $55, $55, $55, $6F, $70  ; 967F: 6E 54 55... nTU
 EQUB $00, $71, $72, $73, $74, $75, $76, $77  ; 9687: 00 71 72... .qr
 EQUB $78, $79, $7A, $7B, $7C, $7D, $7E, $7F  ; 968F: 78 79 7A... xyz
 EQUB $80, $00, $81, $82, $83, $84, $85, $85  ; 9697: 80 00 81... ...
 EQUB $6E, $54, $55, $55, $55, $55, $86, $70  ; 969F: 6E 54 55... nTU
 EQUB $87, $88, $89, $8A, $8B, $8C, $8D, $8C  ; 96A7: 87 88 89... ...
 EQUB $8E, $8F, $8C, $90, $8C, $91, $92, $93  ; 96AF: 8E 8F 8C... ...
 EQUB $94, $95, $96, $97, $55, $55, $55, $55  ; 96B7: 94 95 96... ...
 EQUB $98, $54, $55, $55, $55, $55, $99, $9A  ; 96BF: 98 54 55... .TU
 EQUB $9B, $9C, $9D, $9E, $9F, $A0, $A1, $A2  ; 96C7: 9B 9C 9D... ...
 EQUB $A2, $A3, $A2, $A4, $A0, $A5, $A6, $A7  ; 96CF: A2 A3 A2... ...
 EQUB $A8, $A9, $AA, $AB, $55, $55, $55, $55  ; 96D7: A8 A9 AA... ...
 EQUB $98, $54, $55, $55, $55, $55, $AC, $AD  ; 96DF: 98 54 55... .TU
 EQUB $58, $AE, $AF, $B0, $B1, $B2, $B3, $B4  ; 96E7: 58 AE AF... X..
 EQUB $B5, $B6, $B7, $B8, $B9, $BA, $BB, $BC  ; 96EF: B5 B6 B7... ...
 EQUB $BD, $67, $BE, $BF, $55, $55, $55, $55  ; 96F7: BD 67 BE... .g.
 EQUB $98, $54, $55, $55, $55, $55, $C0, $C1  ; 96FF: 98 54 55... .TU
 EQUB $00, $00, $00, $00, $00, $C2, $C3, $C4  ; 9707: 00 00 00... ...
 EQUB $C5, $C6, $C7, $C8, $C9, $00, $00, $00  ; 970F: C5 C6 C7... ...
 EQUB $00, $00, $CA, $97, $55, $55, $55, $55  ; 9717: 00 00 CA... ...
 EQUB $98, $00, $00, $00, $00, $00, $00, $00  ; 971F: 98 00 00... ...
 EQUB $00, $00, $00, $00, $00, $00, $00, $00  ; 9727: 00 00 00... ...
 EQUB $00, $00, $00, $00, $00, $00, $00, $00  ; 972F: 00 00 00... ...
 EQUB $00, $00, $00, $00, $00, $00, $00, $00  ; 9737: 00 00 00... ...
 EQUB $00, $00, $00, $00, $00, $00, $00, $00  ; 973F: 00 00 00... ...
 EQUB $00, $00, $00, $00, $00, $00, $00, $00  ; 9747: 00 00 00... ...
 EQUB $00, $00, $00, $00, $00, $00, $00, $00  ; 974F: 00 00 00... ...
 EQUB $00, $00, $00, $00, $00, $00, $00, $00  ; 9757: 00 00 00... ...
 EQUB $00                                     ; 975F: 00          .

; ******************************************************************************
;
;       Name: dialsImage
;       Type: Variable
;   Category: Drawing images
;    Summary: Packed image data for the dashboard and dials
;
; ******************************************************************************

.dialsImage

 EQUB $32, $17, $3F, $05, $21, $07, $E8, $C0
 EQUB $FC, $E8, $D1, $83, $21, $07, $98, $00
 EQUB $80, $04, $AA, $FF, $00, $7F, $00, $13
 EQUB $55, $07, $AA, $FF, $00, $FF, $00, $13
 EQUB $55, $00, $10, $21, $38, $04, $AA, $FF
 EQUB $00, $C7, $00, $13, $55, $00, $32, $01
 EQUB $03, $04, $AA, $FF, $00, $FC, $00, $13
 EQUB $55, $02, $80, $00, $32, $06, $0C, $5C
 EQUB $B8, $F8, $00, $7F, $00, $F9, $F3, $A3
 EQUB $46, $21, $07, $09, $FF, $7F, $05, $10
 EQUB $22, $38, $10, $05, $22, $C7, $33, $28
 EQUB $38, $38, $10, $0A, $12, $05, $34, $01
 EQUB $03, $03, $01, $05, $22, $FC, $34, $02
 EQUB $03, $03, $01, $02, $22, $80, $06, $22
 EQUB $7F, $23, $80, $02, $35, $01, $03, $03
 EQUB $01, $01, $04, $22, $FC, $22, $02, $32
 EQUB $03, $01, $0A, $FF, $FE, $05, $32, $01
 EQUB $03, $00, $40, $20, $33, $34, $1A, $1F
 EQUB $00, $FC, $00, $BF, $DF, $CB, $65, $E0
 EQUB $E8, $FC, $04, $80, $E0, $34, $17, $03
 EQUB $3F, $17, $8B, $C1, $60, $21, $19, $03
 EQUB $31, $02, $23, $03, $35, $02, $07, $04
 EQUB $06, $05, $23, $04, $21, $05, $08, $FF
 EQUB $05, $12, $03, $21, $0C, $00, $21, $0C
 EQUB $00, $21, $11, $FF, $31, $3F, $24, $22
 EQUB $21, $2E, $AE, $23, $08, $22, $09, $22
 EQUB $08, $C8, $F6, $F7, $23, $B6, $B5, $32
 EQUB $34, $35, $03, $F0, $F2, $21, $12, $00
 EQUB $10, $04, $21, $04, $E4, $21, $12, $E0
 EQUB $32, $02, $01, $02, $50, $40, $02, $21
 EQUB $0C, $10, $32, $05, $15, $8A, $90, $40
 EQUB $09, $21, $01, $03, $21, $02, $0A, $7F
 EQUB $03, $21, $09, $40, $02, $7F, $06, $FF
 EQUB $57, $02, $21, $09, $40, $02, $FF, $57
 EQUB $05, $FF, $E0, $5D, $10, $00, $7F, $02
 EQUB $FF, $E0, $5D, $05, $FF, $21, $04, $5D
 EQUB $00, $21, $17, $40, $02, $FF, $21, $04
 EQUB $5D, $05, $FF, $00, $55, $21, $01, $FF
 EQUB $03, $FF, $00, $55, $05, $FF, $80, $D5
 EQUB $00, $FF, $03, $FF, $80, $D5, $05, $FF
 EQUB $20, $55, $00, $E8, $21, $02, $02, $FF
 EQUB $20, $55, $05, $FF, $21, $06, $5D, $10
 EQUB $00, $FD, $02, $FF, $21, $06, $5D, $06
 EQUB $FF, $55, $02, $20, $21, $05, $02, $FF
 EQUB $55, $06, $80, $7F, $21, $01, $02, $20
 EQUB $21, $04, $00, $80, $7F, $0C, $80, $03
 EQUB $40, $80, $02, $32, $0A, $02, $02, $30
 EQUB $21, $08, $A0, $A8, $51, $32, $09, $02
 EQUB $04, $21, $0F, $4F, $48, $00, $21, $08
 EQUB $04, $20, $21, $27, $48, $21, $07, $23
 EQUB $10, $22, $90, $32, $11, $12, $10, $6F
 EQUB $EF, $23, $6F, $AE, $21, $2C, $AE, $04
 EQUB $F0, $32, $08, $04, $00, $14, $34, $0F
 EQUB $07, $03, $07, $03, $21, $01, $00, $22
 EQUB $01, $21, $17, $FC, $F0, $E0, $C1, $80
 EQUB $81, $32, $01, $17, $07, $D0, $7F, $36
 EQUB $1F, $0F, $07, $03, $03, $01, $D1, $02
 EQUB $35, $01, $02, $04, $08, $08, $00, $FC
 EQUB $F8, $F0, $E1, $83, $22, $07, $9F, $34
 EQUB $03, $07, $0F, $1E, $7C, $22, $F8, $60
 EQUB $12, $FE, $FD, $FB, $22, $F7, $FF, $08
 EQUB $28, $E0, $03, $21, $0C, $00, $21, $0D
 EQUB $00, $21, $11, $FF, $31, $3F, $24, $22
 EQUB $21, $2E, $AE, $23, $08, $C8, $21, $08
 EQUB $88, $21, $08, $C8, $F6, $F7, $36, $36
 EQUB $37, $36, $37, $36, $37, $04, $34, $01
 EQUB $07, $0C, $38, $04, $41, $33, $07, $0C
 EQUB $38, $02, $21, $0F, $78, $C0, $AA, $04
 EQUB $21, $0F, $78, $C0, $AA, $02, $21, $0F
 EQUB $F8, $AA, $32, $01, $06, $AA, $30, $40
 EQUB $21, $0F, $F8, $AA, $32, $01, $06, $AA
 EQUB $30, $40, $C8, $30, $EA, $80, $00, $AA
 EQUB $00, $21, $01, $C8, $30, $EA, $80, $00
 EQUB $AA, $00, $33, $01, $04, $08, $BA, $10
 EQUB $20, $EA, $80, $00, $32, $04, $08, $BA
 EQUB $10, $20, $EA, $80, $00, $32, $06, $01
 EQUB $AA, $02, $AA, $02, $32, $06, $01, $AA
 EQUB $02, $AA, $02, $21, $08, $90, $FA, $21
 EQUB $38, $44, $EB, $22, $80, $21, $08, $90
 EQUB $FA, $21, $38, $44, $EB, $22, $80, $02
 EQUB $AA, $02, $AA, $C0, $30, $02, $AA, $02
 EQUB $AA, $C0, $30, $22, $80, $AA, $22, $80
 EQUB $AA, $81, $86, $22, $80, $AA, $22, $80
 EQUB $AA, $81, $86, $10, $21, $08, $AB, $3D
 EQUB $0C, $32, $EA, $01, $01, $10, $08, $AB
 EQUB $0C, $32, $EA, $01, $01, $60, $80, $AA
 EQUB $02, $AA, $02, $60, $80, $AA, $02, $AA
 EQUB $02, $20, $10, $AA, $34, $08, $04, $AA
 EQUB $01, $00, $20, $10, $AA, $39, $08, $04
 EQUB $AA, $01, $00, $11, $0C, $AA, $01, $00
 EQUB $AA, $00, $80, $34, $11, $0C, $AA, $01
 EQUB $00, $AA, $00, $80, $F8, $21, $0F, $AA
 EQUB $80, $60, $BA, $34, $0C, $02, $F8, $0F
 EQUB $AA, $80, $60, $BA, $32, $0C, $02, $00
 EQUB $80, $F8, $32, $0F, $01, $AA, $03, $80
 EQUB $F8, $32, $0F, $01, $AA, $06, $C0, $F0
 EQUB $32, $18, $0E, $04, $C2, $F0, $35, $18
 EQUB $0E, $12, $10, $11, $25, $10, $6C, $EE
 EQUB $6E, $EE, $6F, $EF, $6F, $EF, $21, $04
 EQUB $00, $21, $08, $60, $04, $35, $03, $07
 EQUB $07, $97, $0F, $13, $22, $01, $80, $21
 EQUB $01, $40, $20, $33, $18, $07, $01, $81
 EQUB $00, $C1, $A0, $D0, $E4, $F8, $02, $21
 EQUB $02, $00, $32, $04, $08, $30, $C0, $38
 EQUB $01, $03, $01, $07, $0B, $17, $4F, $3F
 EQUB $08, $18, $03, $21, $08, $00, $21, $09
 EQUB $00, $21, $15, $FF, $31, $3F, $24, $22
 EQUB $21, $2A, $AA, $08, $21, $08, $00, $24
 EQUB $10, $22, $18, $30, $6A, $22, $60, $30
 EQUB $33, $3D, $0E, $07, $30, $6A, $22, $60
 EQUB $30, $36, $3D, $0E, $07, $01, $AA, $0C
 EQUB $30, $40, $D5, $02, $21, $01, $AA, $21
 EQUB $0C, $30, $40, $D5, $02, $80, $AA, $03
 EQUB $55, $02, $80, $AA, $03, $55, $02, $21
 EQUB $02, $AE, $21, $08, $10, $20, $55, $22
 EQUB $80, $21, $02, $AE, $21, $08, $10, $20
 EQUB $55, $22, $80, $00, $AA, $03, $55, $03
 EQUB $AA, $03, $55, $02, $21, $01, $AB, $3E
 EQUB $02, $04, $04, $5D, $08, $10, $01, $AB
 EQUB $02, $04, $04, $5D, $08, $10, $21, $0C
 EQUB $AB, $03, $55, $02, $21, $0C, $AB, $03
 EQUB $55, $02, $98, $EA, $23, $80, $D5, $22
 EQUB $80, $98, $EA, $23, $80, $D5, $23, $80
 EQUB $AA, $40, $22, $20, $55, $10, $21, $08
 EQUB $80, $AA, $40, $22, $20, $55, $10, $21
 EQUB $08, $40, $AA, $10, $35, $08, $04, $57
 EQUB $01, $01, $40, $AA, $10, $33, $08, $04
 EQUB $57, $23, $01, $AA, $03, $55, $02, $21
 EQUB $01, $AA, $03, $55, $02, $80, $EA, $30
 EQUB $32, $0C, $02, $55, $02, $80, $EA, $30
 EQUB $32, $0C, $02, $55, $02, $21, $06, $AB
 EQUB $22, $03, $21, $06, $DE, $58, $70, $21
 EQUB $06, $AB, $22, $03, $21, $06, $DE, $58
 EQUB $70, $08, $10, $00, $24, $08, $22, $18
 EQUB $23, $10, $35, $12, $11, $12, $10, $15
 EQUB $6F, $EF, $68, $E8, $68, $E8, $6A, $EA
 EQUB $07, $70, $FF, $FC, $24, $BC, $8C, $8D
 EQUB $03, $40, $23, $C0, $40, $E0, $20, $60
 EQUB $A0, $23, $20, $A0, $03, $21, $0C, $00
 EQUB $21, $0C, $00, $21, $1D, $FF, $31, $3F
 EQUB $25, $22, $A2, $23, $08, $88, $23, $08
 EQUB $48, $F6, $F7, $76, $21, $37, $B6, $B7
 EQUB $B6, $B7, $03, $21, $01, $04, $36, $1C
 EQUB $0E, $0F, $06, $03, $01, $02, $21, $01
 EQUB $04, $58, $33, $2E, $07, $01, $02, $C0
 EQUB $F0, $A4, $51, $21, $18, $C0, $7A, $21
 EQUB $0F, $05, $C0, $7A, $21, $0F, $04, $80
 EQUB $21, $01, $AA, $84, $F8, $21, $1F, $03
 EQUB $21, $01, $AA, $84, $F8, $21, $1F, $04
 EQUB $AA, $02, $C0, $FF, $03, $AA, $02, $C0
 EQUB $FF, $03, $AA, $03, $AA, $FF, $02, $AA
 EQUB $03, $AA, $FF, $00, $20, $AA, $22, $40
 EQUB $80, $AA, $80, $7F, $20, $AA, $22, $40
 EQUB $80, $AA, $80, $7F, $00, $AA, $03, $AA
 EQUB $00, $FF, $00, $AA, $03, $AA, $00, $FF
 EQUB $80, $AA, $23, $80, $AA, $80, $FF, $80
 EQUB $AA, $23, $80, $AA, $80, $FF, $21, $04
 EQUB $AE, $22, $02, $21, $01, $AB, $00, $FF
 EQUB $21, $04, $AE, $22, $02, $21, $01, $AB
 EQUB $00, $FF, $00, $AA, $02, $21, $01, $FF
 EQUB $80, $02, $AA, $02, $21, $01, $FF, $80
 EQUB $00, $80, $EA, $20, $21, $1F, $F8, $80
 EQUB $02, $80, $EA, $20, $21, $1F, $F8, $80
 EQUB $02, $21, $01, $AF, $F8, $80, $03, $22
 EQUB $01, $AF, $F8, $80, $03, $21, $02, $C0
 EQUB $04, $21, $1A, $74, $E0, $C0, $02, $35
 EQUB $03, $0F, $25, $8A, $18, $03, $80, $04
 EQUB $21, $38, $70, $F0, $60, $C0, $80, $02
 EQUB $23, $10, $21, $12, $22, $10, $32, $11
 EQUB $16, $6F, $EF, $69, $E8, $6A, $EA, $68
 EQUB $E9, $03, $30, $03, $70, $FF, $FC, $22
 EQUB $8C, $22, $BC, $8C, $8D, $03, $21, $0D
 EQUB $03, $21, $1C, $FF, $37, $3F, $22, $22
 EQUB $2F, $2F, $23, $A3, $23, $08, $49, $33
 EQUB $09, $08, $08, $88, $F6, $F7, $22, $36
 EQUB $76, $75, $74, $75, $21, $03, $03, $C0
 EQUB $40, $02, $32, $04, $01, $03, $90, $5A
 EQUB $00, $F0, $FE, $32, $1F, $03, $04, $34
 EQUB $08, $01, $20, $04, $06, $E0, $FF, $7F
 EQUB $21, $0F, $04, $10, $00, $80, $10, $21
 EQUB $01, $05, $FC, $12, $21, $01, $03, $C0
 EQUB $21, $03, $02, $21, $06, $05, $F8, $12
 EQUB $04, $80, $21, $07, $08, $21, $3F, $06
 EQUB $21, $3F, $40, $BF, $06, $FF, $06, $FF
 EQUB $00, $FF, $06, $FF, $06, $FF, $00, $21
 EQUB $17, $06, $FF, $06, $FF, $00, $44, $06
 EQUB $FF, $06, $FF, $00, $7F, $06, $FC, $06
 EQUB $FC, $21, $02, $FD, $05, $21, $1F, $12
 EQUB $04, $21, $01, $E0, $06, $21, $3F, $12
 EQUB $80, $03, $21, $03, $C0, $02, $60, $02
 EQUB $21, $07, $FF, $FE, $F0, $04, $21, $08
 EQUB $00, $32, $01, $08, $80, $00, $21, $0F
 EQUB $7F, $F8, $C0, $04, $10, $80, $21, $04
 EQUB $20, $04, $C0, $03, $32, $03, $02, $02
 EQUB $20, $80, $03, $21, $09, $5A, $00, $23
 EQUB $10, $93, $90, $21, $16, $10, $21, $17
 EQUB $6F, $EF, $23, $68, $A8, $21, $28, $A8
 EQUB $03, $20, $00, $30, $00, $40, $FF, $FC
 EQUB $24, $8C, $BC, $BD, $03, $21, $01, $03
 EQUB $21, $1C, $FF, $37, $3F, $2E, $2E, $2F
 EQUB $2F, $23, $A3, $23, $08, $48, $21, $08
 EQUB $00, $21, $08, $80, $F6, $F7, $32, $36
 EQUB $37, $76, $7E, $74, $7C, $21, $01, $07
 EQUB $21, $0E, $0F, $DF, $34, $0F, $07, $03
 EQUB $01, $05, $21, $0C, $05, $FF, $22, $F3
 EQUB $12, $03, $60, $00, $60, $00, $EE, $03
 EQUB $23, $17, $22, $11, $03, $21, $29, $00
 EQUB $21, $01, $00, $93, $03, $44, $24, $6C
 EQUB $03, $80, $00, $98, $00, $80, $03, $7F
 EQUB $22, $67, $22, $7F, $0B, $FB, $F0, $E0
 EQUB $C0, $80, $03, $C0, $07, $21, $38, $07
 EQUB $23, $10, $21, $12, $10, $21, $02, $10
 EQUB $21, $05, $6F, $EF, $68, $E8, $68, $78
 EQUB $34, $2A, $3A, $00, $38, $22, $10, $21
 EQUB $38, $04, $21, $38, $22, $10, $21, $38
 EQUB $06, $FF, $07, $FF, $04, $28, $18, $28
 EQUB $18, $23, $01, $FF, $24, $C0, $23, $01
 EQUB $FF, $24, $C0, $08, $E0, $98, $86, $81
 EQUB $86, $98, $E0, $09, $FF, $81, $42, $32
 EQUB $24, $18, $03, $C0, $60, $30, $34, $18
 EQUB $0C, $06, $02, $00, $C0, $60, $30, $34
 EQUB $18, $0C, $06, $02, $03, $31, $18, $23
 EQUB $3C, $21, $18, $0B, $34, $18, $3C, $3C
 EQUB $18, $0D, $22, $18, $0E, $21, $18, $0F
 EQUB $10, $0F, $22, $18, $06, $22, $18, $05
 EQUB $34, $08, $1C, $18, $08, $04, $34, $18
 EQUB $2C, $24, $18, $03, $10, $34, $34, $28
 EQUB $28, $1C, $10, $02, $36, $18, $38, $2C
 EQUB $18, $3C, $18, $09, $28, $18, $0F, $78
 EQUB $0E, $78, $21, $18, $0D, $78, $22, $18
 EQUB $0C, $78, $23, $18, $0B, $78, $24, $18
 EQUB $0A, $78, $25, $18, $09, $78, $26, $18
 EQUB $08, $78, $27, $18, $03, $13, $02, $FF
 EQUB $05, $12, $04, $80, $03, $FF, $05, $12
 EQUB $03, $80, $C0, $80, $02, $FF, $05, $12
 EQUB $03, $C0, $E0, $C0, $02, $FF, $05, $12
 EQUB $03, $E0, $F0, $E0, $02, $FF, $05, $12
 EQUB $03, $F0, $F8, $F0, $02, $FF, $05, $12
 EQUB $03, $F8, $FC, $F8, $02, $FF, $05, $12
 EQUB $03, $FC, $FE, $FC, $02, $FF, $05, $12
 EQUB $03, $FE, $FF, $FE, $02, $FF, $05, $12
 EQUB $03, $13, $02, $FF, $02, $15, $04, $80
 EQUB $03, $FF, $03, $80, $00, $12, $03, $80
 EQUB $C0, $80, $02, $FF, $02, $80, $C0, $80
 EQUB $12, $03, $C0, $E0, $C0, $02, $FF, $02
 EQUB $C0, $E0, $C0, $12, $03, $E0, $F0, $E0
 EQUB $02, $FF, $02, $E0, $F0, $E0, $12, $03
 EQUB $F0, $F8, $F0, $02, $FF, $02, $F0, $F8
 EQUB $F0, $12, $03, $F8, $FC, $F8, $02, $FF
 EQUB $02, $F8, $FC, $F8, $12, $03, $FC, $FE
 EQUB $FC, $02, $FF, $02, $FC, $FE, $FC, $12
 EQUB $03, $FE, $FF, $FE, $02, $FF, $02, $FE
 EQUB $FF, $FE, $12, $10, $33, $0C, $3A, $2B
 EQUB $87, $E3, $A4, $35, $08, $04, $34, $27
 EQUB $3A, $BB, $48, $90, $21, $18, $02, $33
 EQUB $18, $24, $18, $0F, $06, $33, $18, $3C
 EQUB $18, $03, $FF, $26, $81, $12, $26, $81
 EQUB $FF, $02, $34, $18, $3C, $3C, $18, $0F
 EQUB $05, $34, $18, $3C, $3C, $18, $02, $70
 EQUB $24, $60, $23, $C0, $70, $23, $60, $22
 EQUB $40, $22, $C0, $7F, $24, $60, $23, $C0
 EQUB $7F, $23, $60, $22, $40, $22, $C0, $22
 EQUB $60, $24, $C0, $12, $60, $22, $40, $23
 EQUB $C0, $FF, $FE, $24, $C0, $0C, $18, $08
 EQUB $3F

; ******************************************************************************
;
;       Name: cobraImage
;       Type: Variable
;   Category: Drawing images
;    Summary: Packed image data for the Cobra Mk III shown on the Equip Ship
;             screen
;
; ******************************************************************************

.cobraImage

 EQUB $07, $21, $01, $0B, $32, $05, $34, $6B
 EQUB $D6, $9F, $03, $34, $02, $0F, $1F, $3F
 EQUB $7F, $02, $14, $DF, $B7, $03, $12, $7F
 EQUB $BF, $CF, $02, $FE, $F5, $F9, $FB, $FD
 EQUB $D3, $03, $22, $FE, $FD, $FB, $FF, $03
 EQUB $C0, $B0, $CC, $F2, $69, $04, $C0, $F0
 EQUB $EC, $F6, $06, $32, $02, $0B, $06, $32
 EQUB $01, $07, $05, $21, $2B, $EA, $FC, $05
 EQUB $21, $1F, $F5, $FF, $04, $21, $01, $FF
 EQUB $5F, $F9, $05, $12, $21, $07, $04, $9F
 EQUB $FF, $EE, $BB, $04, $7F, $13, $03, $21
 EQUB $19, $12, $E0, $BF, $03, $21, $07, $14
 EQUB $03, $FD, $FB, $E6, $D8, $21, $27, $03
 EQUB $22, $FE, $12, $DF, $03, $BE, $DF, $DA
 EQUB $FD, $C5, $03, $7F, $BF, $EC, $21, $36
 EQUB $FB, $03, $60, $FF, $10, $7E, $A7, $03
 EQUB $80, $FF, $33, $0F, $01, $18, $04, $21
 EQUB $1E, $5F, $10, $CE, $04, $E0, $FF, $EF
 EQUB $21, $31, $05, $40, $21, $03, $F6, $05
 EQUB $FF, $FC, $21, $01, $05, $E0, $32, $0A
 EQUB $2F, $06, $21, $05, $D0, $06, $80, $E0
 EQUB $0E, $32, $01, $06, $07, $34, $01, $03
 EQUB $06, $19, $30, $65, $D2, $67, $87, $00
 EQUB $38, $01, $06, $0F, $1B, $2F, $1F, $3F
 EQUB $2F, $5F, $FF, $FE, $79, $F7, $FF, $EF
 EQUB $16, $F7, $FF, $F3, $DF, $EE, $21, $14
 EQUB $EB, $FD, $FB, $F7, $DC, $FE, $12, $F6
 EQUB $FA, $22, $FC, $9E, $F5, $CE, $BC, $98
 EQUB $68, $D0, $E0, $67, $EF, $FF, $DF, $FF
 EQUB $BF, $22, $7F, $B4, $58, $86, $21, $03
 EQUB $00, $21, $01, $02, $FB, $FF, $FD, $FE
 EQUB $14, $80, $40, $10, $48, $B4, $4A, $BF
 EQUB $21, $2C, $00, $80, $E0, $B0, $48, $A4
 EQUB $C0, $D1, $07, $C0, $08, $20, $FF, $00
 EQUB $21, $05, $04, $21, $1F, $07, $21, $01
 EQUB $EA, $21, $02, $7F, $21, $06, $03, $FE
 EQUB $21, $14, $06, $6B, $81, $FA, $FE, $A1
 EQUB $21, $0E, $02, $21, $1C, $7F, $21, $05
 EQUB $05, $A7, $8C, $21, $11, $00, $55, $03
 EQUB $5F, $F3, $EE, $05, $7E, $DD, $21, $16
 EQUB $FC, $68, $21, $0A, $85, $21, $01, $FF
 EQUB $21, $3E, $E9, $22, $03, $21, $01, $02
 EQUB $BF, $7F, $FD, $32, $3F, $0B, $E8, $F5
 EQUB $FE, $7F, $12, $C0, $F4, $03, $FB, $FD
 EQUB $00, $F8, $D4, $02, $A1, $FC, $FE, $FF
 EQUB $05, $78, $86, $BF, $21, $1F, $00, $80
 EQUB $53, $00, $87, $78, $06, $21, $3D, $E0
 EQUB $FF, $F0, $00, $21, $0A, $C0, $00, $C0
 EQUB $21, $1F, $06, $83, $FF, $FE, $00, $21
 EQUB $02, $C0, $02, $7C, $07, $12, $00, $21
 EQUB $13, $C0, $0B, $F8, $FE, $00, $80, $0F
 EQUB $01, $34, $01, $03, $06, $0D, $06, $35
 EQUB $01, $02, $0D, $1F, $3A, $74, $A9, $52
 EQUB $81, $35, $27, $02, $00, $05, $0B, $57
 EQUB $AF, $21, $3F, $5B, $8F, $34, $1F, $3F
 EQUB $7F, $3F, $DF, $EE, $FD, $5F, $16, $F7
 EQUB $12, $EF, $D5, $AB, $54, $BB, $71, $22
 EQUB $EF, $12, $F7, $FB, $FC, $FE, $F9, $F5
 EQUB $E9, $B2, $4C, $B2, $DE, $F2, $23, $FE
 EQUB $FD, $F3, $CD, $32, $21, $01, $80, $00
 EQUB $C0, $D0, $B4, $AC, $92, $E4, $12, $21
 EQUB $3F, $6F, $7B, $7F, $6F, $21, $23, $06
 EQUB $80, $A0, $16, $7F, $DF, $37, $1C, $2C
 EQUB $04, $05, $02, $00, $01, $00, $E0, $F0
 EQUB $22, $F8, $FC, $22, $FE, $FF, $E0, $30
 EQUB $98, $4C, $A7, $FB, $7D, $BD, $0D, $80
 EQUB $C0, $60, $0C, $34, $01, $02, $0C, $1D
 EQUB $05, $35, $01, $03, $03, $1A, $1C, $65
 EQUB $B9, $21, $12, $60, $C2, $A1, $33, $04
 EQUB $01, $02, $40, $EC, $DF, $BF, $5E, $4B
 EQUB $95, $32, $2E, $17, $6F, $BF, $5F, $FA
 EQUB $BF, $7F, $12, $21, $3F, $7F, $14, $FB
 EQUB $54, $E9, $E6, $D8, $7F, $FB, $FD, $FE
 EQUB $FF, $BE, $D8, $E0, $80, $A5, $4F, $B5
 EQUB $CA, $B1, $7E, $21, $1F, $DF, $F8, $F0
 EQUB $C0, $05, $E2, $82, $21, $3B, $DA, $73
 EQUB $21, $1F, $C3, $D8, $22, $01, $00, $21
 EQUB $01, $04, $82, $C0, $8E, $CC, $60, $D7
 EQUB $72, $21, $18, $61, $20, $60, $36, $21
 EQUB $07, $28, $01, $07, $28, $96, $45, $21
 EQUB $0F, $F9, $40, $02, $F7, $79, $21, $3E
 EQUB $F0, $32, $07, $3F, $12, $00, $D3, $EB
 EQUB $FE, $BA, $6F, $36, $2E, $0F, $FF, $2C
 EQUB $14, $01, $C1, $22, $D0, $FC, $32, $3D
 EQUB $1C, $AD, $95, $6D, $73, $21, $3D, $F2
 EQUB $80, $C0, $40, $20, $10, $21, $08, $40
 EQUB $21, $04, $10, $21, $08, $42, $21, $11
 EQUB $40, $22, $50, $D0, $0C, $80, $00, $20
 EQUB $21, $08, $08, $21, $3F, $7A, $BD, $9E
 EQUB $85, $AA, $D9, $FC, $00, $21, $05, $42
 EQUB $61, $72, $51, $20, $00, $45, $8B, $34
 EQUB $16, $2B, $54, $31, $64, $F2, $BF, $7D
 EQUB $FB, $F7, $EF, $CE, $98, $00, $F4, $A3
 EQUB $CC, $10, $44, $90, $60, $FD, $FF, $FC
 EQUB $F0, $E0, $80, $03, $D5, $55, $02, $21
 EQUB $05, $02, $48, $08, $5B, $4E, $34, $1D
 EQUB $0A, $51, $02, $0A, $DF, $FE, $DE, $85
 EQUB $39, $2E, $03, $80, $01, $00, $01, $01
 EQUB $00, $01, $03, $50, $E8, $FD, $7F, $D0
 EQUB $7E, $38, $2F, $15, $2F, $17, $02, $00
 EQUB $2F, $01, $02, $BE, $21, $03, $42, $F3
 EQUB $21, $1D, $BF, $22, $ED, $41, $FC, $BD
 EQUB $21, $0C, $E0, $40, $02, $33, $23, $02
 EQUB $2E, $00, $82, $55, $AD, $EA, $DD, $FD
 EQUB $D1, $FF, $7D, $AA, $50, $00, $FD, $EF
 EQUB $32, $3B, $0C, $BB, $C1, $AA, $FF, $21
 EQUB $02, $80, $E0, $F0, $44, $21, $3E, $55
 EQUB $00, $50, $70, $B0, $D0, $60, $E9, $21
 EQUB $37, $CA, $08, $34, $04, $02, $16, $0A
 EQUB $42, $A0, $21, $02, $8E, $08, $35, $0E
 EQUB $04, $06, $04, $08, $03, $34, $04, $0E
 EQUB $0C, $08, $08, $34, $04, $0C, $1C, $0A
 EQUB $05, $22, $0E, $21, $04, $02, $60, $05
 EQUB $80, $50, $7D, $0C, $21, $0D, $0E, $60
 EQUB $B0, $07, $60, $3E, $0B, $07, $0F, $0A
 EQUB $1F, $16, $19, $0F, $04, $02, $01, $05
 EQUB $00, $09, $21, $06, $00, $78, $F8, $68
 EQUB $70, $22, $F0, $E0, $00, $90, $10, $90
 EQUB $A0, $40, $80, $02, $21, $08, $00, $21
 EQUB $08, $03, $21, $18, $00, $21, $18, $00
 EQUB $35, $18, $08, $00, $18, $3C, $20, $7E
 EQUB $5A, $3E, $24, $3C, $34, $2C, $3C, $2C
 EQUB $00, $3C, $18, $00, $08, $18, $00, $18
 EQUB $03, $A0, $07, $B0, $A0, $08, $33, $3C
 EQUB $34, $2C, $06, $21, $18, $10, $21, $04
 EQUB $00, $21, $04, $03, $21, $18, $00, $37
 EQUB $2C, $04, $2C, $04, $00, $18, $3C, $20
 EQUB $7E, $5A, $66, $7E, $7A, $56, $7A, $56
 EQUB $00, $37, $3C, $18, $00, $04, $2C, $04
 EQUB $2C, $02, $A0, $07, $F0, $A0, $00, $A0
 EQUB $06, $21, $3C, $22, $7A, $21, $24, $04
 EQUB $37, $18, $24, $24, $18, $00, $08, $08
 EQUB $03, $21, $18, $02, $22, $18, $21, $08
 EQUB $00, $32, $18, $3C, $20, $7E, $5A, $3D
 EQUB $24, $3C, $34, $2C, $2C, $3C, $00, $3C
 EQUB $18, $00, $08, $18, $18, $04, $C0, $07
 EQUB $E0, $C0, $09, $21, $18, $10, $06, $22
 EQUB $18, $3A, $28, $08, $24, $00, $08, $10
 EQUB $08, $10, $34, $34, $02, $10, $21, $18
 EQUB $10, $00, $35, $3C, $2C, $34, $2C, $3C
 EQUB $7E, $4A, $6A, $00, $10, $21, $18, $10
 EQUB $02, $22, $34, $02, $A0, $21, $05, $CA
 EQUB $20, $04, $C0, $CE, $21, $04, $C0, $06
 EQUB $7E, $22, $7A, $66, $04, $36, $18, $24
 EQUB $24, $18, $00, $0F, $20, $60, $04, $32
 EQUB $06, $2F, $78, $F0, $0D, $C0, $32, $0A
 EQUB $03, $04, $22, $7E, $21, $3C, $05, $22
 EQUB $30, $08, $99, $21, $33, $66, $CC, $99
 EQUB $21, $33, $0A, $66, $80, $99, $32, $33
 EQUB $26, $8C, $03, $4C, $32, $19, $33, $66
 EQUB $4C, $21, $38, $76, $C2, $C3, $83, $46
 EQUB $7C, $21, $18, $C7, $BB, $23, $7D, $BB
 EQUB $C7, $FF, $35, $08, $2C, $3C, $2C, $04
 EQUB $03, $34, $04, $1C, $7C, $1C, $04, $80
 EQUB $00, $CD, $06, $80, $F0, $08, $60, $70
 EQUB $30, $32, $08, $04, $03, $7C, $6C, $4C
 EQUB $74, $78, $05, $21, $08, $00, $21, $08
 EQUB $03, $2B, $08, $02, $24, $08, $22, $0C
 EQUB $02, $3F

; ******************************************************************************
;
;       Name: missileImage
;       Type: Variable
;   Category: Drawing images
;    Summary: Image data for the missiles shown on the Equip Ship screen (this
;             data is not packed)
;
; ******************************************************************************

.missileImage

 EQUB $00, $00, $00, $06, $0F, $16, $10, $16
 EQUB $00, $00, $06, $1F, $3F, $3F, $3F, $39
 EQUB $00, $00, $00, $00, $00, $80, $80, $80
 EQUB $00, $00, $00, $80, $C0, $40, $40, $40
 EQUB $16, $16, $16, $06, $00, $00, $00, $00
 EQUB $39, $39, $39, $19, $06, $00, $00, $00
 EQUB $80, $80, $80, $00, $00, $00, $00, $00
 EQUB $40, $40, $40, $80, $00, $00, $00, $00

; ******************************************************************************
;
;       Name: eliteLogo
;       Type: Variable
;   Category: Drawing images
;    Summary: Packed image data for the small Elite logo shown on the save/load
;             screen
;
; ******************************************************************************

.eliteLogo

 EQUB $00, $22, $80, $C0, $E0, $F0, $F8, $A0
 EQUB $80, $40, $22, $20, $10, $32, $08, $04
 EQUB $5E, $0F, $21, $01, $00, $3C, $06, $0C
 EQUB $00, $3C, $06, $CC, $3C, $00, $06, $0A
 EQUB $12, $22, $42, $00, $21, $04, $4C, $3E
 EQUB $1D, $1E, $05, $0F, $02, $13, $01, $33
 EQUB $22, $01, $0A, $00, $1D, $1C, $21, $1E
 EQUB $02, $80, $C0, $A0, $78, $B0, $78, $00
 EQUB $80, $40, $20, $50, $88, $48, $84, $36
 EQUB $02, $01, $01, $0F, $3F, $2F, $7E, $F5
 EQUB $00, $32, $04, $08, $10, $22, $20, $41
 EQUB $8A, $30, $22, $F0, $A0, $40, $A0, $20
 EQUB $00, $21, $08, $02, $40, $80, $40, $22
 EQUB $E0, $10, $00, $21, $08, $00, $21, $04
 EQUB $03, $22, $0F, $22, $07, $31, $03, $23
 EQUB $01, $FA, $71, $37, $36, $3F, $1E, $3B
 EQUB $07, $8F, $02, $81, $22, $C0, $E0, $C4
 EQUB $F8, $70, $02, $80, $C0, $00, $60, $A8
 EQUB $F0, $02, $80, $40, $20, $22, $10, $21
 EQUB $08, $02, $23, $48, $78, $22, $58, $02
 EQUB $40, $02, $22, $20, $00, $3E, $01, $03
 EQUB $0C, $1A, $35, $2A, $35, $4F, $01, $02
 EQUB $06, $0C, $18, $31, $63, $62, $B8, $D8
 EQUB $88, $B0, $00, $22, $C5, $86, $32, $07
 EQUB $27, $77, $4F, $FF, $BF, $21, $3E, $7C
 EQUB $00, $20, $40, $C0, $22, $80, $02, $E0
 EQUB $22, $C0, $22, $80, $03, $21, $01, $07
 EQUB $24, $01, $04, $21, $07, $93, $33, $03
 EQUB $0A, $0A, $40, $43, $00, $F8, $EC, $FC
 EQUB $22, $F5, $FF, $7C, $21, $3D, $C8, $F8
 EQUB $E8, $F8, $E8, $F8, $F1, $20, $24, $08
 EQUB $21, $18, $22, $10, $D0, $58, $10, $58
 EQUB $BC, $22, $30, $4C, $90, $22, $20, $60
 EQUB $40, $02, $21, $02, $68, $72, $58, $60
 EQUB $72, $21, $3B, $10, $32, $0B, $33, $4F
 EQUB $47, $5F, $4F, $67, $35, $2F, $17, $0F
 EQUB $3A, $1E, $5E, $B4, $32, $26, $1C, $10
 EQUB $78, $24, $FE, $22, $FC, $F8, $F0, $03
 EQUB $21, $0B, $00, $32, $05, $02, $04, $21
 EQUB $07, $00, $3E, $03, $01, $00, $02, $17
 EQUB $23, $FA, $03, $8A, $0E, $03, $1D, $08
 EQUB $1B, $FA, $21, $03, $F3, $F2, $32, $03
 EQUB $33, $F8, $F3, $21, $37, $C4, $22, $37
 EQUB $EF, $CC, $00, $E4, $21, $04, $E4, $C4
 EQUB $21, $04, $E7, $B8, $7F, $D7, $B1, $21
 EQUB $21, $B1, $FD, $F1, $21, $03, $00, $31
 EQUB $2F, $24, $21, $A1, $EB, $E0, $CF, $32
 EQUB $08, $0F, $E8, $EB, $21, $1F, $D6, $21
 EQUB $1F, $EF, $35, $08, $0F, $0F, $08, $0F
 EQUB $10, $00, $80, $21, $3F, $00, $BC, $21
 EQUB $01, $00, $22, $E0, $C0, $40, $80, $7F
 EQUB $7E, $22, $80, $36, $1C, $08, $07, $03
 EQUB $00, $01, $00, $7C, $34, $38, $18, $0F
 EQUB $07, $03, $10, $21, $38, $10, $12, $34
 EQUB $0B, $07, $FE, $18, $10, $30, $12, $21
 EQUB $07, $FF, $7F, $32, $0C, $1C, $88, $22
 EQUB $AF, $76, $57, $DB, $22, $0C, $21, $1C
 EQUB $15, $60, $F0, $60, $12, $80, $21, $02
 EQUB $F8, $70, $60, $E0, $12, $00, $22, $FC
 EQUB $F8, $70, $E0, $C0, $80, $03, $7C, $F8
 EQUB $F0, $E0, $C0, $03, $36, $3D, $1F, $07
 EQUB $07, $02, $01, $02, $35, $03, $1F, $0F
 EQUB $01, $03, $03, $AD, $AF, $77, $57, $DA
 EQUB $AC, $F8, $70, $FE, $12, $FC, $FE, $F8
 EQUB $70, $F8, $F0, $E0, $C0, $06, $C0, $80
 EQUB $05, $FC, $02, $30, $50, $03, $F8, $00
 EQUB $20, $60, $20, $05, $10, $22, $30, $20
 EQUB $02, $32, $0E, $1E, $26, $30, $02, $10
 EQUB $22, $30, $20, $02, $22, $3E, $26, $30
 EQUB $02, $10, $22, $30, $20, $02, $28, $30
 EQUB $22, $C0, $10, $22, $30, $20, $02, $22
 EQUB $FE, $26, $30, $08, $32, $1E, $0E, $09
 EQUB $30, $21, $18, $06, $22, $7E, $03, $3F

; ******************************************************************************
;
;       Name: eliteLogoBall
;       Type: Variable
;   Category: Drawing images
;    Summary: Packed image data for the ball at the bottom of the large Elite
;             logo shown on the start screen
;
; ******************************************************************************

.eliteLogoBall

 EQUB $35, $51, $38, $3F, $11, $0B, $03, $21
 EQUB $0C, $02, $21, $0E, $04, $20, $40, $00
 EQUB $80, $0C, $0D, $13, $3F

; ******************************************************************************
;
;       Name: subm_A730
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.subm_A730

 LDY #$E0

.loop_CA732

 SETUP_PPU_FOR_ICON_BAR ; If the PPU has started drawing the icon bar, configure
                        ; the PPU to use nametable 0 and pattern table 0

 LDA L963F,Y
 STA nameBuffer0+704,Y
 STA nameBuffer1+704,Y
 DEY
 BNE loop_CA732
 LDA nameBuffer0+736
 STA nameBuffer0+704
 LDA nameBuffer0+768
 STA nameBuffer0+736
 LDA nameBuffer0+800
 STA nameBuffer0+768
 LDA nameBuffer0+832
 STA nameBuffer0+800
 LDA nameBuffer0+896
 STA nameBuffer0+864
 LDA nameBuffer0+928
 STA nameBuffer0+896
 LDA #0
 STA nameBuffer0+928
 RTS

; ******************************************************************************
;
;       Name: subm_A775
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.subm_A775

 SETUP_PPU_FOR_ICON_BAR ; If the PPU has started drawing the icon bar, configure
                        ; the PPU to use nametable 0 and pattern table 0

 LDY #$60
 LDA #0

.loop_CA786

 STA nameBuffer0+927,Y
 DEY
 BNE loop_CA786
 LDA #$CB
 STA tileSprite11
 STA tileSprite12
 LDA #3
 STA attrSprite11
 STA attrSprite12
 LDA #0
 STA attrSprite13
 LDX #$18
 LDY #$38

.loop_CA7A5

 LDA #$DA
 STA tileSprite0,Y
 LDA #0
 STA attrSprite0,Y
 INY
 INY
 INY
 INY
 DEX
 BNE loop_CA7A5
 RTS

; ******************************************************************************
;
;       Name: subm_A7B7
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.subm_A7B7

 JSR KeepPPUTablesAt0
 LDA ppuCtrlCopy
 PHA
 LDA #0
 STA ppuCtrlCopy
 STA PPU_CTRL
 STA setupPPUForIconBar
 LDA #0
 STA PPU_MASK
 LDA QQ11
 CMP #$B9
 BNE CA7D4
 JMP CA87D

.CA7D4

 CMP #$9D
 BEQ CA83A
 CMP #$DF
 BEQ CA83A
 CMP #$96
 BNE CA7E6
 JSR SetSystemImage_b5
 JMP CA8A2

.CA7E6

 CMP #$98
 BNE CA7F0
 JSR SetCmdrImage_b4
 JMP CA8A2

.CA7F0

 CMP #$BA
 BNE CA810

 LDA #HI(16*69)         ; Set PPU_ADDR to the address of pattern #69 in pattern
 STA PPU_ADDR           ; table 0
 LDA #LO(16*69)
 STA PPU_ADDR

 LDA #HI(missileImage)  ; Set SC(1 0) = missileImage
 STA SC+1
 LDA #LO(missileImage)
 STA SC

 LDA #$F5
 STA systemFlag
 LDX #4
 JMP CA89F

.CA810

 CMP #$BB
 BNE CA82A

 LDA #HI(16*69)         ; Set PPU_ADDR to the address of pattern #69 in pattern
 STA PPU_ADDR           ; table 0
 LDA #LO(16*69)
 STA PPU_ADDR

 LDA #HI(eliteLogo)     ; Set V(1 0) = eliteLogo
 STA V+1                ;
 LDA #LO(eliteLogo)     ; So we can unpack the image data for the small Elite
 STA V                  ; logo into pattern #69 onwards in pattern table 0

 LDA #3                 ; Set A = 3 so we only unpack the image data when
                        ; systemFlag does not equal 3

 BNE CA891              ; Jump to CA891 to unpack the image data (this BNE is
                        ; effectivelt a JMP as A is never zero)

.CA82A

 LDA #0

 CMP systemFlag
 BEQ CA8A2
 STA systemFlag

 JSR subm_A95D

 JMP CA8A2

.CA83A

 LDA #$24
 STA L00D9
 LDA #1
 CMP systemFlag
 BEQ CA8A2
 STA systemFlag

 LDA #HI(16*68)         ; Set PPU_ADDR to the address of pattern #68 in pattern
 STA PPU_ADDR           ; table 0
 LDA #LO(16*68)
 STA PPU_ADDR

 LDX #$5F

 LDA #HI(fontImage)     ; Set SC(1 0) = fontImage
 STA SC+1
 LDA #LO(fontImage)
 STA SC

 JSR subm_A909

 LDA QQ11
 CMP #$DF
 BNE CA8A2

 LDA #HI(16*227)        ; Set PPU_ADDR to the address of pattern #227 in pattern
 STA PPU_ADDR           ; table 0
 LDA #LO(16*227)
 STA PPU_ADDR

 LDA #HI(eliteLogoBall) ; Set V(1 0) = eliteLogoBall
 STA V+1                ;
 LDA #LO(eliteLogoBall) ; So we can unpack the image data for the ball at the
 STA V                  ; bottom of the big Elite logo into pattern #227 onwards
                        ; in pattern table 0

 JSR UnpackToPPU
 JMP CA8A2

.CA87D

 LDA #HI(16*69)         ; Set PPU_ADDR to the address of pattern #69 in pattern
 STA PPU_ADDR           ; table 0
 LDA #LO(16*69)
 STA PPU_ADDR

 LDA #HI(cobraImage)    ; Set V(1 0) = cobraImage
 STA V+1                ;
 LDA #LO(cobraImage)    ; So we can unpack the image data for the Cobra Mk III
 STA V                  ; image into pattern #69 onwards in pattern table 0

 LDA #2                 ; Set A = 2 so we only unpack the image data when
                        ; systemFlag does not equal 2

.CA891

 CMP systemFlag
 BEQ CA8A2
 STA systemFlag
 JSR UnpackToPPU
 JMP CA8A2

.CA89F

 JSR SendToPPU2

.CA8A2

 JSR subm_AC86

 LDA #HI($1000+16*0)    ; Set PPU_ADDR to the address of pattern #0 in pattern
 STA PPU_ADDR           ; table 1
 LDA #LO($1000+16*0)
 STA PPU_ADDR

 LDY #0

 LDX #$50

.loop_CA8B3

 LDA LAA6C,Y
 STA PPU_DATA
 INY
 DEX
 BNE loop_CA8B3

 LDA #HI($1000+16*255)  ; Set PPU_ADDR to the address of pattern #255 in pattern
 STA PPU_ADDR           ; table 1
 LDA #LO($1000+16*255)
 STA PPU_ADDR

 LDA #0
 LDX #$10

.loop_CA8CB

 STA PPU_DATA
 DEX
 BNE loop_CA8CB
 JSR subm_D946
 LDX #0
 JSR subm_A972
 LDX #1
 JSR subm_A972
 LDX #0
 STX palettePhase
 STX otherPhase
 JSR subm_D8EC
 JSR subm_D946
 LDA QQ11
 STA QQ11a
 AND #$40
 BEQ CA8FC
 LDA QQ11
 CMP #$DF
 BEQ CA8FC
 LDA #0
 BEQ CA8FE

.CA8FC

 LDA #$80

.CA8FE

 STA showUserInterface
 PLA
 STA ppuCtrlCopy
 STA PPU_CTRL
 JMP CB673_b3

; ******************************************************************************
;
;       Name: subm_A909
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.subm_A909

 LDY #0

.CA90B

 LDA (SC),Y
 STA PPU_DATA
 INY
 LDA (SC),Y
 STA PPU_DATA
 INY
 LDA (SC),Y
 STA PPU_DATA
 INY
 LDA (SC),Y
 STA PPU_DATA
 INY
 LDA (SC),Y
 STA PPU_DATA
 INY
 LDA (SC),Y
 STA PPU_DATA
 INY
 LDA (SC),Y
 STA PPU_DATA
 INY
 LDA (SC),Y
 STA PPU_DATA
 INY
 BNE CA93F
 INC SC+1

.CA93F

 LDA #0
 STA PPU_DATA
 STA PPU_DATA
 STA PPU_DATA
 STA PPU_DATA
 STA PPU_DATA
 STA PPU_DATA
 STA PPU_DATA
 STA PPU_DATA
 DEX
 BNE CA90B
 RTS

; ******************************************************************************
;
;       Name: subm_A95D
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.subm_A95D

 LDA #HI(16*69)         ; Set PPU_ADDR to the address of pattern #69 in pattern
 STA PPU_ADDR           ; table 0
 LDA #LO(16*69)
 STA PPU_ADDR

 LDA #HI(dialsImage)    ; Set V(1 0) = dialsImage
 STA V+1                ;
 LDA #LO(dialsImage)    ; So we can unpack the image data for the dashboard and
 STA V                  ; dials into pattern #69 onwards in pattern table 0

 JMP UnpackToPPU        ; Unpack the image data to the PPU, returning from the
                        ; subroutine using a tail call

; ******************************************************************************
;
;       Name: subm_A972
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.subm_A972

 STX drawingPhase
 STX otherPhase
 STX palettePhase

 LDA #0
 STA L00CC

 LDA QQ11
 CMP #$DF
 BNE CA986

 LDA #4
 BNE CA988

.CA986

 LDA #$25

.CA988

 STA L00D2
 LDA tileNumber
 STA tile0Phase0,X
 LDA #$C4
 JSR subm_D977
 JSR CA99B
 LDA tileNumber
 STA tile1Phase0,X
 RTS

.CA99B

 TXA
 PHA
 LDA #$3F
 STA tempVar+1
 LDA #$FF
 STA tempVar
 JSR subm_C6F4
 PLA
 PHA
 TAX
 LDA L03EF,X
 AND #$20
 BNE CA9CC
 LDA #$10
 STA tempVar+1
 LDA #0
 STA tempVar
 JSR subm_C6F4
 PLA
 TAX
 LDA L03EF,X
 AND #$20
 BNE CA9CE
 JSR subm_D946
 JMP CA99B

.CA9CC

 PLA
 TAX

.CA9CE

 JMP subm_D946

; ******************************************************************************
;
;       Name: subm_A9D1
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.subm_A9D1

 PHA
 JSR subm_D8C5
 LDA QQ11
 CMP #$96
 BNE CA9E1
 JSR GetSystemImage_b5
 JMP CA9E8

.CA9E1

 CMP #$98
 BNE CA9E8
 JSR GetCmdrImage_b4

.CA9E8

 LDA QQ11
 AND #$40
 BEQ CA9F2
 LDA #0
 STA showUserInterface

.CA9F2

 JSR subm_AC86
 LDA #0
 STA L00CC
 LDA #$25
 STA L00D2
 LDA tileNumber
 STA tile0Phase0
 STA tile0Phase1
 LDA #$54
 LDX #0
 PLA
 JSR subm_D977
 INC drawingPhase
 JSR subm_D977
 JSR subm_D8C5
 LDA #$50
 STA L00CD
 STA L00CE
 LDA QQ11
 STA QQ11a
 LDA tileNumber
 STA tile1Phase0
 STA tile1Phase1
 LDA #0
 LDX #0
 STX palettePhase
 STX otherPhase
 JSR subm_D8EC
 LDA QQ11
 AND #$40
 BNE CAA3B
 JSR KeepPPUTablesAt0
 LDA #$80
 STA showUserInterface

.CAA3B

 LDA L0473
 BPL CAA43
 JMP CB673_b3

.CAA43

 LDA QQ11
 AND #$0F
 TAX
 LDA LAA5C,X
 CMP L03F2
 STA L03F2
 JSR subm_B57F
 DEC L00DA
 JSR KeepPPUTablesAt0
 INC L00DA
 RTS

; ******************************************************************************
;
;       Name: LAA5C
;       Type: Variable
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.LAA5C

 EQUB   0,   2, $0A, $0A ; AA5C: 00 02 0A... ...
 EQUB   0, $0A,   6,   8 ; AA60: 00 0A 06... ...
 EQUB   8,   5,   1,   7 ; AA64: 08 05 01... ...
 EQUB   3,   4,   0,   9 ; AA68: 03 04 00... ...

.LAA6C

 EQUB   0,   0,   0,   0 ; AA6C: 00 00 00... ...
 EQUB   0,   0,   0,   0 ; AA70: 00 00 00... ...
 EQUB   0,   0,   0,   0 ; AA74: 00 00 00... ...
 EQUB   0,   0,   0,   0 ; AA78: 00 00 00... ...
 EQUB   0,   0,   0,   0 ; AA7C: 00 00 00... ...
 EQUB   0,   0,   0,   0 ; AA80: 00 00 00... ...
 EQUB   3,   3,   3,   3 ; AA84: 03 03 03... ...
 EQUB   3,   3,   3,   3 ; AA88: 03 03 03... ...
 EQUB   0,   0,   0,   0 ; AA8C: 00 00 00... ...
 EQUB   0,   0,   0,   0 ; AA90: 00 00 00... ...
 EQUB $C0, $C0, $C0, $C0 ; AA94: C0 C0 C0... ...
 EQUB $C0, $C0, $C0, $C0 ; AA98: C0 C0 C0... ...
 EQUB   0,   0,   0,   0 ; AA9C: 00 00 00... ...
 EQUB   0,   0,   0,   0 ; AAA0: 00 00 00... ...
 EQUB   0,   0,   0, $FF ; AAA4: 00 00 00... ...
 EQUB $FF, $FF,   0,   0 ; AAA8: FF FF 00... ...
 EQUB   0,   0,   0,   0 ; AAAC: 00 00 00... ...
 EQUB   0,   0,   0,   0 ; AAB0: 00 00 00... ...
 EQUB $0F, $1F, $1F, $DF ; AAB4: 0F 1F 1F... ...
 EQUB $DF, $BF, $BF, $BF ; AAB8: DF BF BF... ...

; ******************************************************************************
;
;       Name: DrawTitleScreen
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.DrawTitleScreen

 JSR subm_D933
 LDA #2
 STA addr1+1
 LDA #$80
 STA addr1

 LDA #$3F
 STA PPU_ADDR
 LDA #0
 STA PPU_ADDR

 LDA #$0F
 LDX #$1F

.loop_CAAD5

 STA PPU_DATA
 DEX
 BPL loop_CAAD5

 LDA #$20
 STA PPU_ADDR
 LDA #0
 STA PPU_ADDR

 LDA #0
 LDX #8
 LDY #0

.CAAEB

 STA PPU_DATA
 DEY
 BNE CAAEB
 JSR subm_D933
 LDA #0
 DEX
 BNE CAAEB
 LDA #$F5
 STA L03F2
 STA systemFlag
 LDA #0
 STA PPU_ADDR
 LDA #0
 STA PPU_ADDR
 LDY #0
 LDX #$50

.loop_CAB0F

 LDA LAA6C,Y
 STA PPU_DATA
 INY
 DEX
 BNE loop_CAB0F
 LDA #$10
 STA PPU_ADDR
 LDA #0
 STA PPU_ADDR
 LDY #0
 LDX #$50

.loop_CAB27

 LDA LAA6C,Y
 STA PPU_DATA
 INY
 DEX
 BNE loop_CAB27
 LDY #0

.loop_CAB33

 LDA #$F0
 STA ySprite0,Y
 INY
 LDA #$FE
 STA ySprite0,Y
 INY
 LDA #3
 STA ySprite0,Y
 INY
 LDA #0
 STA ySprite0,Y
 INY
 BNE loop_CAB33
 JSR subm_A95D
 LDA #$9D
 STA ySprite0
 LDA #$FE
 STA tileSprite0
 LDA #$F8
 STA xSprite0
 LDA #$23
 STA attrSprite0
 LDA #$FB
 STA tileSprite1
 STA tileSprite2
 LDA #$FD
 STA tileSprite3
 STA tileSprite4
 LDA #3
 STA attrSprite1
 LDA #$43
 STA attrSprite2
 LDA #$43
 STA attrSprite3
 LDA #3
 STA attrSprite4
 JSR subm_D933
 LDA #0
 STA OAM_ADDR
 LDA #2
 STA OAM_DMA
 LDA #0
 STA otherPhase
 STA drawingPhase
 STA palettePhase
 LDA #$10
 STA L00E0
 LDA #0
 STA pallettePhasex8
 LDA #$20
 STA debugNametableHi
 LDA #0
 STA debugNametableLo
 LDA #$28
 STA L03EF
 STA L03F0
 LDA #4
 STA tile1Phase0
 STA tile1Phase1
 STA tile2Phase0
 STA tile2Phase1
 STA L00CA
 STA L00CB
 STA tile3Phase0
 STA tile3Phase1
 LDA #$0F
 STA hiddenColour
 STA visibleColour
 STA paletteColour1
 STA paletteColour2
 LDA #0
 STA L00DA
 STA QQ11a
 LDA #$FF
 STA L0473
 JSR subm_D933
 LDA #$90
 STA ppuCtrlCopy
 STA PPU_CTRL
 RTS

; ******************************************************************************
;
;       Name: subm_ABE7
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.subm_ABE7

 LDA QQ11
 CMP #$BA
 BNE CAC08
 LDA L0464
 CMP #3
 BEQ CABFA
 JSR Set_K_K3_XC_YC
 JMP CAC08

.CABFA

 LDX #$F0
 STX ySprite8
 STX ySprite9
 STX ySprite10
 STX ySprite11

.CAC08

 LDA #2
 STA addr1+1
 LDA #$80
 STA addr1
 LDA QQ11
 BPL CAC1C
 LDA #3
 STA addr1+1
 LDA #$60
 STA addr1

.CAC1C

 RTS

; ******************************************************************************
;
;       Name: subm_AC1D
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.subm_AC1D

 TAY
 LDA QQ11
 AND #$40
 BNE CAC1C
 STY L0464
 JSR subm_ACEB
 LDA #2
 STA addr1+1
 LDA #$80
 STA addr1
 LDA QQ11
 BPL CAC3E
 LDA #3
 STA addr1+1
 LDA #$60
 STA addr1

.CAC3E

 LDA L0464
 ASL A
 ASL A
 ADC #$81
 STA L00D6
 LDX #0
 STX L00D3

.loop_CAC4B

 SETUP_PPU_FOR_ICON_BAR ; If the PPU has started drawing the icon bar, configure
                        ; the PPU to use nametable 0 and pattern table 0

 LDA L00D3
 BPL loop_CAC4B

; ******************************************************************************
;
;       Name: subm_AC5C
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.subm_AC5C

 LDA L0464
 JSR subm_AE18
 LDA QQ11
 AND #$40
 BNE CAC85
 JSR subm_ABE7
 LDA #$80
 STA L00D7
 ASL A
 STA L00D3

.loop_CAC72

 SETUP_PPU_FOR_ICON_BAR ; If the PPU has started drawing the icon bar, configure
                        ; the PPU to use nametable 0 and pattern table 0

 LDA L00D3
 BPL loop_CAC72
 ASL L00D7

.CAC85

 RTS

; ******************************************************************************
;
;       Name: subm_AC86
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.subm_AC86

 SETUP_PPU_FOR_ICON_BAR ; If the PPU has started drawing the icon bar, configure
                        ; the PPU to use nametable 0 and pattern table 0

 LDA #$F8
 STA xSprite0
 LDY #$12
 LDX #$9D
 LDA QQ11
 BPL CACCC
 CMP #$C4
 BNE CACA8
 LDX #$F0
 BNE CACCC

.CACA8

 LDY #$19
 LDX #$D5
 CMP #$B9
 BNE CACB7
 LDX #$96
 LDA #$F8
 STA xSprite0

.CACB7

 LDA QQ11
 AND #$0F
 CMP #$0F
 BNE CACC1
 LDX #$A6

.CACC1

 CMP #$0D
 BNE CACCC
 LDX #$AD
 LDA #$F8
 STA xSprite0

.CACCC

 STX ySprite0
 TYA
 SEC
 ROL A
 ASL A
 ASL A
 STA L0461
 LDA L0464
 ASL A
 ASL A
 ADC #$81
 STA L00D6
 LDA QQ11
 AND #$40
 BNE CACEA
 LDX #0
 STX L00D3

.CACEA

 RTS

; ******************************************************************************
;
;       Name: subm_ACEB
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.subm_ACEB

 JSR subm_AD2A
 LDY #2
 JSR subm_AF2E
 LDY #4
 JSR subm_AF5B
 LDY #7
 JSR subm_AF2E
 LDY #9
 JSR subm_AF5B
 LDY #$0C
 JSR subm_AF2E
 LDY #$1D
 JSR subm_AF5B

; ******************************************************************************
;
;       Name: subm_AD0C
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.subm_AD0C

 LDY #$0E
 JSR subm_AF5B
 LDY #$11
 JSR subm_AF2E

; ******************************************************************************
;
;       Name: subm_AD16
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.subm_AD16

 LDY #$13
 JSR subm_AF5B
 LDY #$16
 JSR subm_AF2E
 LDY #$18
 JSR subm_AF5B
 LDY #$1B
 JMP subm_AF2E

; ******************************************************************************
;
;       Name: subm_AD2A
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.subm_AD2A

 LDA L0464
 ASL A
 ASL A
 ASL A
 ASL A
 ASL A
 ASL A
 TAY
 BNE CAD3A
 LDA #$94
 BNE CAD3C

.CAD3A

 LDA #$95

.CAD3C

 DEY
 STY V
 ADC #0
 STA V+1
 LDA QQ11
 BMI CAD5A

 LDA #HI(nameBuffer0+8*80)  ; Set SC(1 0) to the address of tile number #80 in
 STA SC+1                   ; nametable buffer 0
 LDA #LO(nameBuffer0+8*80)
 STA SC

 LDA #HI(nameBuffer1+8*80)  ; Set SC2(1 0) to the address of tile number #80 in
 STA SC2+1                  ; nametable buffer 1
 LDA #LO(nameBuffer1+8*80)
 STA SC2

 JMP CAD77

.CAD5A

 LDA #HI(nameBuffer0+8*108) ; Set SC(1 0) to the address of tile number #108 in
 STA SC+1                   ; nametable buffer 0
 LDA #LO(nameBuffer0+8*108)
 STA SC

 LDA #HI(nameBuffer1+8*108) ; Set SC2(1 0) to the address of tile number #108 in
 STA SC2+1                  ; nametable buffer 1
 LDA #LO(nameBuffer1+8*108)
 STA SC2

 SETUP_PPU_FOR_ICON_BAR ; If the PPU has started drawing the icon bar, configure
                        ; the PPU to use nametable 0 and pattern table 0

.CAD77

 LDY #$3F

.loop_CAD79

 LDA (V),Y
 STA (SC),Y
 STA (SC2),Y
 DEY
 CPY #$21
 BNE loop_CAD79

 SETUP_PPU_FOR_ICON_BAR ; If the PPU has started drawing the icon bar, configure
                        ; the PPU to use nametable 0 and pattern table 0

.CAD91

 LDA (V),Y
 STA (SC),Y
 STA (SC2),Y
 DEY
 BNE CAD91

 SETUP_PPU_FOR_ICON_BAR ; If the PPU has started drawing the icon bar, configure
                        ; the PPU to use nametable 0 and pattern table 0

 LDY #$20
 LDA (V),Y
 LDY #0
 STA (SC),Y
 STA (SC2),Y
 LDY #$40
 LDA (V),Y
 LDY #$20
 STA (SC),Y
 STA (SC2),Y
 RTS

; ******************************************************************************
;
;       Name: subm_AE18_ADBC
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.subm_AE18_ADBC

 LDA #HI(nameBuffer0+8*108) ; Set SC(1 0) to the address of tile number #108 in
 STA SC+1                   ; nametable buffer 0
 LDA #LO(nameBuffer0+8*108)
 STA SC

 LDA #HI(nameBuffer1+8*108) ; Set SC2(1 0) to the address of tile number #108 in
 STA SC2+1                  ; nametable buffer 1
 LDA #LO(nameBuffer1+8*108)
 STA SC2

 LDY #$3F
 LDA #0

.loop_CADD0

 STA (SC),Y
 STA (SC2),Y
 DEY
 BNE loop_CADD0
 LDA #$20
 LDY #0
 STA (SC),Y
 STA (SC2),Y
 RTS

; ******************************************************************************
;
;       Name: subm_AE18_ADE0
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.subm_AE18_ADE0

 LDA L03EB
 BEQ CADEA
 LDY #2
 JSR subm_AF9A

.CADEA

 LDA L03EA
 BEQ CADF4
 LDY #4
 JSR subm_AF96

.CADF4

 LDA L03ED
 BPL CADFE
 LDY #7
 JSR subm_AF9A

.CADFE

 LDA L03EC
 BMI CAE08
 LDY #9
 JSR subm_AF96

.CAE08

 LDA scanController2
 BNE CAE12
 LDY #$0C
 JSR subm_AF9A

.CAE12

 JSR subm_AD0C

.CAE15

 JMP CAEC6

; ******************************************************************************
;
;       Name: subm_AE18
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.subm_AE18

 TAY
 BMI subm_AE18_ADBC
 STA L0464

 SETUP_PPU_FOR_ICON_BAR ; If the PPU has started drawing the icon bar, configure
                        ; the PPU to use nametable 0 and pattern table 0

 JSR subm_AD2A
 LDA L0464
 BEQ CAEAB
 CMP #1
 BEQ CAE42
 CMP #3
 BEQ subm_AE18_ADE0
 CMP #2
 BNE CAE15
 JMP CAEE5

.CAE42

 LDA SSPR
 BNE CAE4C
 LDY #2
 JSR subm_AF2E

.CAE4C

 LDA ECM
 BNE CAE56
 LDY #$11
 JSR subm_AF2E

.CAE56

 LDA QQ22+1
 BNE CAE60
 LDA L0395
 ASL A
 BMI CAE65

.CAE60

 LDY #$0E
 JSR subm_AF5B

.CAE65

 LDA QQ11
 BEQ CAE6F
 JSR subm_AD16
 JMP CAE9C

.CAE6F

 LDA NOMSL
 BNE CAE79
 LDY #$13
 JSR subm_AF5B

.CAE79

 LDA MSTG
 BPL CAE83
 LDY #$16
 JSR subm_AF2E

.CAE83

 LDA BOMB
 BNE CAE8D
 LDY #$18
 JSR subm_AF5B

.CAE8D

 LDA MJ
 BNE CAE97
 LDA ESCP
 BNE CAE9C

.CAE97

 LDY #$1B
 JSR subm_AF2E

.CAE9C

 LDA L0300
 AND #$C0
 BEQ CAEBB

.CAEA3

 LDY #$1D
 JSR subm_AF5B
 JMP CAEBB

.CAEAB

 LDA COK
 BNE CAEB6
 LDA QQ11
 CMP #$BB
 BEQ CAEBB

.CAEB6

 LDY #$11
 JSR subm_AF2E

.CAEBB

 LDA QQ11
 CMP #$BA
 BNE CAEC6
 LDY #4
 JSR subm_AF5B

.CAEC6

 SETUP_PPU_FOR_ICON_BAR ; If the PPU has started drawing the icon bar, configure
                        ; the PPU to use nametable 0 and pattern table 0

 LDA L0464
 ASL A
 ASL A
 ASL A
 ASL A
 ADC #$27
 STA L00BE
 LDA #$EB
 ADC #0
 STA L00BF
 RTS

.CAEE5

 LDX #4
 LDA QQ12
 BEQ CAEF6
 LDY #$0C
 JSR subm_AF2E
 JSR subm_AD16
 JMP CAEA3

.CAEF6

 LDY #2
 JSR subm_AF2E
 LDA QQ22+1
 BEQ CAF0C
 LDY #$0E
 JSR subm_AF5B
 LDY #$11
 JSR subm_AF2E
 JMP CAF12

.CAF0C

 LDA L0395
 ASL A
 BMI CAF17

.CAF12

 LDY #$13
 JSR subm_AF5B

.CAF17

 LDA GHYP
 BNE CAF21
 LDY #$16
 JSR subm_AF2E

.CAF21

 LDA ECM
 BNE CAF2B
 LDY #$18
 JSR subm_AF5B

.CAF2B

 JMP CAE8D

; ******************************************************************************
;
;       Name: subm_AF2E
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.subm_AF2E

 SETUP_PPU_FOR_ICON_BAR ; If the PPU has started drawing the icon bar, configure
                        ; the PPU to use nametable 0 and pattern table 0

 LDA #4
 STA (SC),Y
 STA (SC2),Y
 INY
 LDA #5
 STA (SC),Y
 STA (SC2),Y
 TYA
 CLC
 ADC #$1F
 TAY
 LDA #$24
 STA (SC),Y
 STA (SC2),Y
 INY
 LDA #$25
 STA (SC),Y
 STA (SC2),Y
 RTS

; ******************************************************************************
;
;       Name: subm_AF5B
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.subm_AF5B

 SETUP_PPU_FOR_ICON_BAR ; If the PPU has started drawing the icon bar, configure
                        ; the PPU to use nametable 0 and pattern table 0

 LDA #6
 STA (SC),Y
 STA (SC2),Y
 INY
 LDA #7
 STA (SC),Y
 STA (SC2),Y
 INY
 LDA #8
 STA (SC),Y
 STA (SC2),Y
 TYA
 CLC
 ADC #$1E
 TAY
 LDA #$26
 STA (SC),Y
 STA (SC2),Y
 INY
 LDA #$25
 STA (SC),Y
 STA (SC2),Y
 INY
 LDA #$27
 STA (SC),Y
 STA (SC2),Y
 RTS

; ******************************************************************************
;
;       Name: subm_AF96
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.subm_AF96

 JSR subm_AFAB
 INY

; ******************************************************************************
;
;       Name: subm_AF9A
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.subm_AF9A

 SETUP_PPU_FOR_ICON_BAR ; If the PPU has started drawing the icon bar, configure
                        ; the PPU to use nametable 0 and pattern table 0

 JSR subm_AFAB
 INY

; ******************************************************************************
;
;       Name: subm_AFAB
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.subm_AFAB

 LDA L95CE,Y
 STA (SC),Y
 STA (SC2),Y
 STY T
 TYA
 CLC
 ADC #$20
 TAY
 LDA L95CE,Y
 STA (SC),Y
 STA (SC2),Y
 LDY T
 RTS

; ******************************************************************************
;
;       Name: subm_AFCD_AFC3
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.subm_AFCD_AFC3

 LDX #4
 STX tileNumber
 RTS

; ******************************************************************************
;
;       Name: subm_AFCD_AFC8
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.subm_AFCD_AFC8

 LDX #$25
 STX tileNumber
 RTS

; ******************************************************************************
;
;       Name: subm_AFCD
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.subm_AFCD

 LDA QQ11
 CMP #$CF
 BEQ subm_AFCD_AFC3
 CMP #$10
 BEQ subm_AFCD_AFC8
 LDX #$42
 LDA QQ11
 BMI CAFDF
 LDX #$3C

.CAFDF

 STX tileNumber

 LDA #HI(LFC00)         ; Set V(1 0) = LFC00
 STA V+1
 LDA #LO(LFC00)
 STA V

 LDA #HI(pattBuffer0+8*37)  ; Set SC(1 0) to the address of pattern #37 in
 STA SC+1                   ; pattern buffer 0
 LDA #LO(pattBuffer0+8*37)
 STA SC

 LDA #HI(pattBuffer1+8*37)  ; Set SC2(1 0) to the address of pattern #37 in
 STA SC2+1                  ; pattern buffer 0
 LDA #LO(pattBuffer1+8*37)
 STA SC2

 LDY #0
 LDX #$25

.CAFFD

 SETUP_PPU_FOR_ICON_BAR ; If the PPU has started drawing the icon bar, configure
                        ; the PPU to use nametable 0 and pattern table 0

 LDA (V),Y
 STA (SC),Y
 STA (SC2),Y
 INY
 LDA (V),Y
 STA (SC),Y
 STA (SC2),Y
 INY
 LDA (V),Y
 STA (SC),Y
 STA (SC2),Y
 INY
 LDA (V),Y
 STA (SC),Y
 STA (SC2),Y
 INY
 LDA (V),Y
 STA (SC),Y
 STA (SC2),Y
 INY
 LDA (V),Y
 STA (SC),Y
 STA (SC2),Y
 INY
 LDA (V),Y
 STA (SC),Y
 STA (SC2),Y
 INY
 LDA (V),Y
 STA (SC),Y
 STA (SC2),Y
 INY
 BNE CB04A
 INC V+1
 INC SC+1
 INC SC2+1

.CB04A

 INX
 CPX #$3C
 BNE CAFFD

.CB04F

 SETUP_PPU_FOR_ICON_BAR ; If the PPU has started drawing the icon bar, configure
                        ; the PPU to use nametable 0 and pattern table 0

 CPX tileNumber
 BEQ CB0B4
 LDA (V),Y
 STA (SC2),Y
 LDA #0
 STA (SC),Y
 INY
 LDA (V),Y
 STA (SC2),Y
 LDA #0
 STA (SC),Y
 INY
 LDA (V),Y
 STA (SC2),Y
 LDA #0
 STA (SC),Y
 INY
 LDA (V),Y
 STA (SC2),Y
 LDA #0
 STA (SC),Y
 INY
 LDA (V),Y
 STA (SC2),Y
 LDA #0
 STA (SC),Y
 INY
 LDA (V),Y
 STA (SC2),Y
 LDA #0
 STA (SC),Y
 INY
 LDA (V),Y
 STA (SC2),Y
 LDA #0
 STA (SC),Y
 INY
 LDA (V),Y
 STA (SC2),Y
 LDA #0
 STA (SC),Y
 INY
 BNE CB0B0
 INC V+1
 INC SC+1
 INC SC2+1

.CB0B0

 INX
 JMP CB04F

.CB0B4

 SETUP_PPU_FOR_ICON_BAR ; If the PPU has started drawing the icon bar, configure
                        ; the PPU to use nametable 0 and pattern table 0

 LDA #0
 LDX #$30

.loop_CB0C5

 STA (SC2),Y
 STA (SC),Y
 INY
 BNE CB0D0
 INC SC2+1
 INC SC+1

.CB0D0

 DEX
 BNE loop_CB0C5

 SETUP_PPU_FOR_ICON_BAR ; If the PPU has started drawing the icon bar, configure
                        ; the PPU to use nametable 0 and pattern table 0

 RTS

; ******************************************************************************
;
;       Name: subm_B0E1
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.subm_B0E1

 STA SC
 SEC
 SBC #$20
 STA L00D9
 LDA SC
 CLC
 ADC #$5F
 STA tileNumber
 LDX #0
 LDA QQ11
 CMP #$BB
 BNE CB0F8
 DEX

.CB0F8

 STX T
 LDA #0
 ASL SC
 ROL A
 ASL SC
 ROL A
 ASL SC
 ROL A
 ADC #HI(pattBuffer0)
 STA SC2+1
 ADC #8
 STA SC+1
 LDA SC
 STA SC2

 LDA #HI(fontImage)     ; Set V(1 0) = fontImage
 STA V+1
 LDA #LO(fontImage)
 STA V

 LDX #$5F
 LDY #0

.CB11D

 SETUP_PPU_FOR_ICON_BAR ; If the PPU has started drawing the icon bar, configure
                        ; the PPU to use nametable 0 and pattern table 0

 LDA (V),Y
 STA (SC2),Y
 AND T
 EOR T
 STA (SC),Y
 INY
 LDA (V),Y
 STA (SC2),Y
 AND T
 EOR T
 STA (SC),Y
 INY
 LDA (V),Y
 STA (SC2),Y
 AND T
 EOR T
 STA (SC),Y
 INY
 LDA (V),Y
 STA (SC2),Y
 AND T
 EOR T
 STA (SC),Y
 INY
 LDA (V),Y
 STA (SC2),Y
 AND T
 EOR T
 STA (SC),Y
 INY
 LDA (V),Y
 STA (SC2),Y
 AND T
 EOR T
 STA (SC),Y
 INY
 LDA (V),Y
 STA (SC2),Y
 AND T
 EOR T
 STA (SC),Y
 INY
 LDA (V),Y
 STA (SC2),Y
 AND T
 EOR T
 STA (SC),Y
 INY
 BNE CB18A
 INC V+1
 INC SC2+1
 INC SC+1

.CB18A

 DEX
 BNE CB11D
 RTS

; ******************************************************************************
;
;       Name: subm_B18E
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.subm_B18E

 LDA #HI(pattBuffer0+8*161) ; Set SC(1 0) to the address of pattern #161 in
 STA SC2+1                  ; pattern buffer 0
 LDA #LO(pattBuffer0+8*161)
 STA SC2

 LDA #HI(pattBuffer1+8*161) ; Set SC(1 0) to the address of pattern #161 in
 STA SC+1                   ; pattern buffer 1
 LDA #LO(pattBuffer1+8*161)
 STA SC

 LDX #$5F
 LDA QQ11
 CMP #$BB
 BNE CB1A8
 LDX #$46

.CB1A8

 TXA
 CLC
 ADC tileNumber
 STA tileNumber

 LDA #HI(fontImage)     ; Set V(1 0) = fontImage
 STA V+1
 LDA #LO(fontImage)
 STA V

 LDY #0

.CB1B8

 SETUP_PPU_FOR_ICON_BAR ; If the PPU has started drawing the icon bar, configure
                        ; the PPU to use nametable 0 and pattern table 0

 LDA (V),Y
 STA (SC),Y
 LDA #$FF
 STA (SC2),Y
 INY
 LDA (V),Y
 STA (SC),Y
 LDA #$FF
 STA (SC2),Y
 INY
 LDA (V),Y
 STA (SC),Y
 LDA #$FF
 STA (SC2),Y
 INY
 LDA (V),Y
 STA (SC),Y
 LDA #$FF
 STA (SC2),Y
 INY
 LDA (V),Y
 STA (SC),Y
 LDA #$FF
 STA (SC2),Y
 INY
 LDA (V),Y
 STA (SC),Y
 LDA #$FF
 STA (SC2),Y
 INY
 LDA (V),Y
 STA (SC),Y
 LDA #$FF
 STA (SC2),Y
 INY
 LDA (V),Y
 STA (SC),Y
 LDA #$FF
 STA (SC2),Y
 INY
 BNE CB215
 INC V+1
 INC SC+1
 INC SC2+1

.CB215

 DEX
 BNE CB1B8
 RTS

; ******************************************************************************
;
;       Name: subm_B219
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.subm_B219

 STX K
 STY K+1
 LDA tileNumber
 STA pictureTile
 CLC
 ADC #$38
 STA tileNumber
 LDA pictureTile
 STA K+2
 JSR CB2FB_b3
 LDA #$45
 STA K+2
 LDA #8
 STA K+3
 LDX #0
 LDY #0
 JSR CA0F8_b6
 DEC XC
 DEC YC
 INC K
 INC K+1
 INC K+1

; ******************************************************************************
;
;       Name: subm_B248
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.subm_B248

 JSR subm_B2A9
 LDY #0
 LDA #$40
 STA (SC),Y
 STA (SC2),Y
 LDA #$3C
 JSR CB29D
 LDA #$3E
 STA (SC),Y
 STA (SC2),Y
 DEC K+1
 JMP CB276

.CB263

 JSR SetupPPUForIconBar ; If the PPU has started drawing the icon bar, configure
                        ; the PPU to use nametable 0 and pattern table 0

 LDA #1
 LDY #0
 STA (SC),Y
 STA (SC2),Y
 LDA #2
 LDY K
 STA (SC),Y
 STA (SC2),Y

.CB276

 LDA SC
 CLC
 ADC #$20
 STA SC
 STA SC2
 BCC CB285
 INC SC+1
 INC SC2+1

.CB285

 DEC K+1
 BNE CB263
 LDY #0
 LDA #$41
 STA (SC),Y
 STA (SC2),Y
 LDA #$3D
 JSR CB29D
 LDA #$3F
 STA (SC),Y
 STA (SC2),Y
 RTS

.CB29D

 LDY #1

.loop_CB29F

 STA (SC),Y
 STA (SC2),Y
 INY
 CPY K
 BNE loop_CB29F
 RTS

; ******************************************************************************
;
;       Name: subm_B2A9
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.subm_B2A9

 JSR subm_DBD8
 LDA SC
 CLC
 ADC XC
 STA SC
 STA SC2
 BCC CB2BB
 INC SC+1
 INC SC2+1

.CB2BB

 RTS

; ******************************************************************************
;
;       Name: subm_B2BC
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.subm_B2BC

 LDA K+2
 STA XC
 LDA K+3
 STA YC
 JSR subm_B2A9
 LDA #$3D
 JSR CB29D
 LDX K+1
 JMP CB2E3

.CB2D1

 JSR SetupPPUForIconBar ; If the PPU has started drawing the icon bar, configure
                        ; the PPU to use nametable 0 and pattern table 0

 LDA SC
 CLC
 ADC #$20
 STA SC
 STA SC2
 BCC CB2E3
 INC SC+1
 INC SC2+1

.CB2E3

 LDA #1
 LDY #0
 STA (SC),Y
 STA (SC2),Y
 LDA #2
 LDY K
 STA (SC),Y
 STA (SC2),Y
 DEX
 BNE CB2D1
 LDA #$3C
 JMP CB29D

; ******************************************************************************
;
;       Name: subm_B2FB
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.subm_B2FB

 JSR subm_DBD8
 LDA SC
 CLC
 ADC XC
 STA SC
 STA SC2
 BCC CB30D
 INC SC+1
 INC SC2+1

.CB30D

 LDX K+1

.CB30F

 SETUP_PPU_FOR_ICON_BAR ; If the PPU has started drawing the icon bar, configure
                        ; the PPU to use nametable 0 and pattern table 0

 LDY #0
 LDA K+2

.loop_CB320

 STA (SC2),Y
 STA (SC),Y
 CLC
 ADC #1
 INY
 CPY K
 BNE loop_CB320
 STA K+2
 LDA SC
 CLC
 ADC #$20
 STA SC
 STA SC2
 BCC CB33D
 INC SC+1
 INC SC2+1

.CB33D

 DEX
 BNE CB30F
 RTS

; ******************************************************************************
;
;       Name: ClearTiles
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.ClearTiles

 LDA #0
 STA SC+1
 LDA #$42
 ASL A
 ROL SC+1
 ASL A
 ROL SC+1
 ASL A
 ROL SC+1
 STA SC
 STA SC2
 LDA SC+1
 ADC #HI(pattBuffer1)
 STA SC2+1
 LDA SC+1
 ADC #HI(pattBuffer0)
 STA SC+1
 LDX #$42
 LDY #0

.CB364

 LDA #0
 STA (SC),Y
 STA (SC2),Y
 INY
 STA (SC),Y
 STA (SC2),Y
 INY
 STA (SC),Y
 STA (SC2),Y
 INY
 STA (SC),Y
 STA (SC2),Y
 INY
 STA (SC),Y
 STA (SC2),Y
 INY
 STA (SC),Y
 STA (SC2),Y
 INY
 STA (SC),Y
 STA (SC2),Y
 INY
 STA (SC),Y
 STA (SC2),Y
 INY
 BNE CB394
 INC SC+1
 INC SC2+1

.CB394

 SETUP_PPU_FOR_ICON_BAR ; If the PPU has started drawing the icon bar, configure
                        ; the PPU to use nametable 0 and pattern table 0

 INX
 BNE CB364

 LDA #LO(nameBuffer0)   ; Set SC(1 0)  = nameBuffer0
 STA SC
 STA SC2
 LDA #HI(nameBuffer0)
 STA SC+1

 LDA #HI(nameBuffer1)   ; Set SC2(1 0) = nameBuffer1
 STA SC2+1

 LDX #$1C

.CB3B4

 LDY #$20
 LDA #0

.loop_CB3B8

 STA (SC),Y
 STA (SC2),Y
 DEY
 BPL loop_CB3B8

 SETUP_PPU_FOR_ICON_BAR ; If the PPU has started drawing the icon bar, configure
                        ; the PPU to use nametable 0 and pattern table 0

 LDA SC
 CLC
 ADC #$20
 STA SC
 STA SC2
 BCC CB3DB
 INC SC+1
 INC SC2+1

.CB3DB

 DEX
 BNE CB3B4
 RTS

; ******************************************************************************
;
;       Name: LB3DF
;       Type: Variable
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.LB3DF

 EQUB $0F, $2C, $0F, $2C ; B3DF: 0F 2C 0F... .,.
 EQUB $0F, $28, $00, $1A ; B3E3: 0F 28 00... .(.
 EQUB $0F, $10, $00, $16 ; B3E7: 0F 10 00... ...
 EQUB $0F, $10, $00, $1C ; B3EB: 0F 10 00... ...
 EQUB $0F, $38, $2A, $15 ; B3EF: 0F 38 2A... .8*
 EQUB $0F, $1C, $22, $28 ; B3F3: 0F 1C 22... .."
 EQUB $0F, $16, $28, $27 ; B3F7: 0F 16 28... ..(
 EQUB $0F, $15, $20, $25 ; B3FB: 0F 15 20... ..
 EQUB $0F, $38, $38, $38 ; B3FF: 0F 38 38... .88
 EQUB $0F, $10, $06, $1A ; B403: 0F 10 06... ...
 EQUB $0F, $22, $00, $28 ; B407: 0F 22 00... .".
 EQUB $0F, $10, $00, $1C ; B40B: 0F 10 00... ...
 EQUB $0F, $38, $10, $15 ; B40F: 0F 38 10... .8.
 EQUB $0F, $10, $0F, $1C ; B413: 0F 10 0F... ...
 EQUB $0F, $06, $28, $25 ; B417: 0F 06 28... ..(
 EQUB $0F, $15, $20, $25 ; B41B: 0F 15 20... ..
 EQUB $0F, $2C, $0F, $2C ; B41F: 0F 2C 0F... .,.
 EQUB $0F, $28, $00, $1A ; B423: 0F 28 00... .(.
 EQUB $0F, $10, $00, $16 ; B427: 0F 10 00... ...
 EQUB $0F, $10, $00, $3A ; B42B: 0F 10 00... ...
 EQUB $0F, $38, $10, $15 ; B42F: 0F 38 10... .8.
 EQUB $0F, $1C, $10, $28 ; B433: 0F 1C 10... ...
 EQUB $0F, $06, $10, $27 ; B437: 0F 06 10... ...
 EQUB $0F, $00, $10, $25 ; B43B: 0F 00 10... ...
 EQUB $0F, $2C, $0F, $2C ; B43F: 0F 2C 0F... .,.
 EQUB $0F, $10, $1A, $28 ; B443: 0F 10 1A... ...
 EQUB $0F, $10, $00, $16 ; B447: 0F 10 00... ...
 EQUB $0F, $10, $00, $1C ; B44B: 0F 10 00... ...
 EQUB $0F, $38, $2A, $15 ; B44F: 0F 38 2A... .8*
 EQUB $0F, $1C, $22, $28 ; B453: 0F 1C 22... .."
 EQUB $0F, $06, $28, $27 ; B457: 0F 06 28... ..(
 EQUB $0F, $15, $20, $25 ; B45B: 0F 15 20... ..
 EQUB $0F, $2C, $0F, $2C ; B45F: 0F 2C 0F... .,.
 EQUB $0F, $20, $28, $25 ; B463: 0F 20 28... . (
 EQUB $0F, $10, $00, $16 ; B467: 0F 10 00... ...
 EQUB $0F, $10, $00, $1C ; B46B: 0F 10 00... ...
 EQUB $0F, $38, $2A, $15 ; B46F: 0F 38 2A... .8*
 EQUB $0F, $1C, $22, $28 ; B473: 0F 1C 22... .."
 EQUB $0F, $06, $28, $27 ; B477: 0F 06 28... ..(
 EQUB $0F, $15, $20, $25 ; B47B: 0F 15 20... ..
 EQUB $0F, $28, $10, $06 ; B47F: 0F 28 10... .(.
 EQUB $0F, $10, $00, $1A ; B483: 0F 10 00... ...
 EQUB $0F, $0C, $1C, $2C ; B487: 0F 0C 1C... ...
 EQUB $0F, $10, $00, $1C ; B48B: 0F 10 00... ...
 EQUB $0F, $0C, $1C, $2C ; B48F: 0F 0C 1C... ...
 EQUB $0F, $18, $28, $38 ; B493: 0F 18 28... ..(
 EQUB $0F, $25, $35, $25 ; B497: 0F 25 35... .%5
 EQUB $0F, $15, $20, $25 ; B49B: 0F 15 20... ..
 EQUB $0F, $2A, $00, $06 ; B49F: 0F 2A 00... .*.
 EQUB $0F, $20, $00, $2A ; B4A3: 0F 20 00... . .
 EQUB $0F, $10, $00, $20 ; B4A7: 0F 10 00... ...
 EQUB $0F, $10, $00, $1C ; B4AB: 0F 10 00... ...
 EQUB $0F, $38, $2A, $15 ; B4AF: 0F 38 2A... .8*
 EQUB $0F, $27, $28, $17 ; B4B3: 0F 27 28... .'(
 EQUB $0F, $06, $28, $27 ; B4B7: 0F 06 28... ..(
 EQUB $0F, $15, $20, $25 ; B4BB: 0F 15 20... ..
 EQUB $0F, $28, $0F, $25 ; B4BF: 0F 28 0F... .(.
 EQUB $0F, $10, $06, $1A ; B4C3: 0F 10 06... ...
 EQUB $0F, $10, $0F, $1A ; B4C7: 0F 10 0F... ...
 EQUB $0F, $10, $00, $1C ; B4CB: 0F 10 00... ...
 EQUB $0F, $38, $2A, $15 ; B4CF: 0F 38 2A... .8*
 EQUB $0F, $18, $28, $38 ; B4D3: 0F 18 28... ..(
 EQUB $0F, $06, $2C, $2C ; B4D7: 0F 06 2C... ..,
 EQUB $0F, $15, $20, $25 ; B4DB: 0F 15 20... ..
 EQUB $0F, $1C, $10, $30 ; B4DF: 0F 1C 10... ...
 EQUB $0F, $20, $00, $2A ; B4E3: 0F 20 00... . .
 EQUB $0F, $2A, $00, $06 ; B4E7: 0F 2A 00... .*.
 EQUB $0F, $10, $00, $1C ; B4EB: 0F 10 00... ...
 EQUB $0F, $0F, $10, $30 ; B4EF: 0F 0F 10... ...
 EQUB $0F, $17, $27, $37 ; B4F3: 0F 17 27... ..'
 EQUB $0F, $0F, $28, $38 ; B4F7: 0F 0F 28... ..(
 EQUB $0F, $15, $25, $25 ; B4FB: 0F 15 25... ..%
 EQUB $0F, $1C, $2C, $3C ; B4FF: 0F 1C 2C... ..,
 EQUB $0F, $38, $11, $11 ; B503: 0F 38 11... .8.
 EQUB $0F, $16, $00, $20 ; B507: 0F 16 00... ...
 EQUB $0F, $2B, $00, $25 ; B50B: 0F 2B 00... .+.
 EQUB $0F, $10, $1A, $25 ; B50F: 0F 10 1A... ...
 EQUB $0F, $08, $18, $27 ; B513: 0F 08 18... ...
 EQUB $0F, $0F, $28, $38 ; B517: 0F 0F 28... ..(
 EQUB $0F, $00, $10, $30 ; B51B: 0F 00 10... ...
 EQUB $0F, $2C, $0F, $2C ; B51F: 0F 2C 0F... .,.
 EQUB $0F, $10, $28, $1A ; B523: 0F 10 28... ..(
 EQUB $0F, $10, $00, $16 ; B527: 0F 10 00... ...
 EQUB $0F, $10, $00, $1C ; B52B: 0F 10 00... ...
 EQUB $0F, $38, $2A, $15 ; B52F: 0F 38 2A... .8*
 EQUB $0F, $1C, $22, $28 ; B533: 0F 1C 22... .."
 EQUB $0F, $06, $28, $27 ; B537: 0F 06 28... ..(
 EQUB $0F, $15, $20, $25 ; B53B: 0F 15 20... ..

; ******************************************************************************
;
;       Name: LB53F
;       Type: Variable
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.LB53F

 EQUB $0F, $0F, $0F, $0F ; B53F: 0F 0F 0F... ...
 EQUB $0F, $0F, $0F, $0F ; B543: 0F 0F 0F... ...
 EQUB $0F, $0F, $0F, $0F ; B547: 0F 0F 0F... ...
 EQUB $0F, $0F, $0F, $0F ; B54B: 0F 0F 0F... ...
 EQUB $00, $01, $02, $03 ; B54F: 00 01 02... ...
 EQUB $04, $05, $06, $07 ; B553: 04 05 06... ...
 EQUB $08, $09, $0A, $0B ; B557: 08 09 0A... ...
 EQUB $0C, $0F, $0F, $0F ; B55B: 0C 0F 0F... ...
 EQUB $10, $11, $12, $13 ; B55F: 10 11 12... ...
 EQUB $14, $15, $16, $17 ; B563: 14 15 16... ...
 EQUB $18, $19, $1A, $1B ; B567: 18 19 1A... ...
 EQUB $1C, $0F, $0F, $0F ; B56B: 1C 0F 0F... ...
 EQUB $20, $21, $22, $23 ; B56F: 20 21 22...  !"
 EQUB $24, $25, $26, $27 ; B573: 24 25 26... $%&
 EQUB $28, $29, $2A, $2B ; B577: 28 29 2A... ()*
 EQUB $2C, $0F, $0F, $0F ; B57B: 2C 0F 0F... ,..

; ******************************************************************************
;
;       Name: subm_B57F
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.subm_B57F

 LDA QQ11a
 AND #$0F
 TAX
 LDA #0
 STA SC+1
 LDA LAA5C,X
 LDY #0
 STY SC+1
 ASL A
 ASL A
 ASL A
 ASL A
 ASL A
 ROL SC+1
 ADC #$DF
 STA SC
 LDA #$B3
 ADC SC+1
 STA SC+1
 LDY #$20

.loop_CB5A2

 LDA (SC),Y
 STA XX3,Y
 DEY
 BPL loop_CB5A2
 LDA QQ11a
 BEQ CB5DE
 CMP #$98
 BEQ CB607
 CMP #$96
 BNE CB5DB
 LDA QQ15
 EOR QQ15+5
 EOR QQ15+2
 LSR A
 LSR A
 EOR #$0C
 AND #$1C
 TAX
 LDA LB6A5,X
 STA XX3+20
 LDA LB6A6,X
 STA XX3+21
 LDA LB6A7,X
 STA XX3+22
 LDA LB6A8,X
 STA XX3+23

.CB5DB

 JMP CB607

.CB5DE

 LDA XX3
 LDY XX3+3
 LDA palettePhase
 BNE CB5EF
 STA XX3+1
 STY XX3+2
 RTS

.CB5EF

 STY XX3+1
 STA XX3+2
 RTS

; ******************************************************************************
;
;       Name: subm_B5F6
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.subm_B5F6

 JSR subm_B5F9

; ******************************************************************************
;
;       Name: subm_B5F9
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.subm_B5F9

 LDX #$1F

.loop_CB5FB

 LDY XX3,X
 LDA LB53F,Y
 STA XX3,X
 DEX
 BNE loop_CB5FB

.CB607

 LDA #$0F
 STA hiddenColour
 LDA QQ11a
 BPL CB627
 CMP #$C4
 BEQ CB627
 CMP #$98
 BEQ CB62D
 LDA XX3+21
 STA visibleColour
 LDA XX3+22
 STA paletteColour1
 LDA XX3+23
 STA paletteColour2
 RTS

.CB627

 LDA XX3+3
 STA visibleColour
 RTS

.CB62D

 LDA XX3+1
 STA visibleColour
 LDA XX3+2
 STA paletteColour1
 LDA XX3+3
 STA paletteColour2
 RTS

; ******************************************************************************
;
;       Name: subm_B63D
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.subm_B63D

 LDA QQ11a
 CMP #$FF
 BEQ CB66D
 LDA L0473
 BMI CB66D
 JSR subm_D8C5
 JSR KeepPPUTablesAt0
 JSR subm_B57F
 DEC L00DA
 JSR subm_B5F9
 JSR KeepPPUTablesAt0x2
 JSR subm_B5F9
 JSR KeepPPUTablesAt0x2
 JSR subm_B5F9
 JSR KeepPPUTablesAt0x2
 JSR subm_B5F9
 JSR KeepPPUTablesAt0x2
 INC L00DA

.CB66D

 LDA #$FF
 STA L0473
 RTS

; ******************************************************************************
;
;       Name: subm_B673
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.subm_B673

 JSR KeepPPUTablesAt0
 JSR subm_B57F
 JSR subm_B5F6
 JSR subm_B5F9
 DEC L00DA
 JSR KeepPPUTablesAt0x2
 JSR subm_B57F
 JSR subm_B5F6
 JSR KeepPPUTablesAt0x2
 JSR subm_B57F
 JSR subm_B5F9
 JSR KeepPPUTablesAt0x2
 JSR subm_B57F
 JSR CB607
 JSR KeepPPUTablesAt0
 INC L00DA
 LSR L0473
 RTS

; ******************************************************************************
;
;       Name: LB6A5
;       Type: Variable
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.LB6A5

 EQUB $0F                ; B6A5: 0F          .

.LB6A6

 EQUB $25                ; B6A6: 25          %

.LB6A7

 EQUB $16                ; B6A7: 16          .

.LB6A8

 EQUB $15, $0F, $35, $16 ; B6A8: 15 0F 35... ..5
 EQUB $25, $0F, $34, $04 ; B6AC: 25 0F 34... %.4
 EQUB $14, $0F, $27, $28 ; B6B0: 14 0F 27... ..'
 EQUB $17, $0F, $29, $2C ; B6B4: 17 0F 29... ..)
 EQUB $19, $0F, $2A, $1B ; B6B8: 19 0F 2A... ..*
 EQUB $0A, $0F, $32, $21 ; B6BC: 0A 0F 32... ..2
 EQUB $02, $0F, $2C, $22 ; B6C0: 02 0F 2C... ..,
 EQUB $1C, $18, $00      ; B6C4: 1C 18 00    ...

; ******************************************************************************
;
;       Name: LB6C7
;       Type: Variable
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.LB6C7

 EQUB $32                ; B6C7: 32          2

.LB6C8

 EQUB $00, $56, $00, $77 ; B6C8: 00 56 00... .V.
 EQUB $00, $8B, $00, $A6 ; B6CC: 00 8B 00... ...
 EQUB $00, $C1, $00, $DA ; B6D0: 00 C1 00... ...
 EQUB $00, $EF, $00, $04 ; B6D4: 00 EF 00... ...
 EQUB $01, $19, $01, $2F ; B6D8: 01 19 01... ...
 EQUB $01, $55, $01, $77 ; B6DC: 01 55 01... .U.
 EQUB $01, $9A, $01, $B7 ; B6E0: 01 9A 01... ...
 EQUB $01, $D6, $01, $F4 ; B6E4: 01 D6 01... ...
 EQUB $01, $25, $02, $57 ; B6E8: 01 25 02... .%.
 EQUB $02, $89, $02, $96 ; B6EC: 02 89 02... ...
 EQUB $02, $A5, $02, $B5 ; B6F0: 02 A5 02... ...
 EQUB $02, $CC, $02, $31 ; B6F4: 02 CC 02... ...
 EQUB $3F, $27, $0F, $21 ; B6F8: 3F 27 0F... ?'.
 EQUB $33, $07, $21, $33 ; B6FC: 33 07 21... 3.!
 EQUB $07, $21, $33, $07 ; B700: 07 21 33... .!3
 EQUB $21, $33, $07, $FF ; B704: 21 33 07... !3.
 EQUB $BF, $23, $AF, $22 ; B708: BF 23 AF... .#.
 EQUB $AB, $AE, $77, $99 ; B70C: AB AE 77... ..w
 EQUB $25, $AA, $5A, $32 ; B710: 25 AA 5A... %.Z
 EQUB $07, $09, $25, $0A ; B714: 07 09 25... ..%
 EQUB $21, $0F, $3F, $31 ; B718: 21 0F 3F... !.?
 EQUB $3F, $27, $0F, $21 ; B71C: 3F 27 0F... ?'.
 EQUB $33, $07, $21, $33 ; B720: 33 07 21... 3.!
 EQUB $07, $21, $33, $07 ; B724: 07 21 33... .!3
 EQUB $21, $33, $07, $12 ; B728: 21 33 07... !3.
 EQUB $26, $AF, $77, $DD ; B72C: 26 AF 77... &.w
 EQUB $25, $AA, $5A, $32 ; B730: 25 AA 5A... %.Z
 EQUB $07, $0D, $24, $0F ; B734: 07 0D 24... ..$
 EQUB $32, $0E, $05, $3F ; B738: 32 0E 05... 2..
 EQUB $18, $77, $27, $55 ; B73C: 18 77 27... .w'
 EQUB $77, $27, $55, $77 ; B740: 77 27 55... w'U
 EQUB $27, $55, $77, $27 ; B744: 27 55 77... 'Uw
 EQUB $55, $77, $27, $55 ; B748: 55 77 27... Uw'
 EQUB $18, $28, $0F, $3F ; B74C: 18 28 0F... .(.
 EQUB $18, $77, $27, $55 ; B750: 18 77 27... .w'
 EQUB $77, $27, $55, $77 ; B754: 77 27 55... w'U
 EQUB $27, $55, $77, $27 ; B758: 27 55 77... 'Uw
 EQUB $55, $77, $27, $55 ; B75C: 55 77 27... Uw'
 EQUB $15, $22, $BF, $EF ; B760: 15 22 BF... .".
 EQUB $25, $0F, $22, $0B ; B764: 25 0F 22... %."
 EQUB $21, $0E, $3F, $31 ; B768: 21 0E 3F... !.?
 EQUB $3F, $27, $0F, $21 ; B76C: 3F 27 0F... ?'.
 EQUB $33, $07, $73, $27 ; B770: 33 07 73... 3.s
 EQUB $50, $77, $27, $55 ; B774: 50 77 27... Pw'
 EQUB $77, $27, $55, $77 ; B778: 77 27 55... w'U
 EQUB $27, $55, $F7, $FD ; B77C: 27 55 F7... 'U.
 EQUB $14, $FE, $F5, $28 ; B780: 14 FE F5... ...
 EQUB $0F, $3F, $31, $3F ; B784: 0F 3F 31... .?1
 EQUB $27, $0F, $21, $33 ; B788: 27 0F 21... '.!
 EQUB $07, $21, $33, $07 ; B78C: 07 21 33... .!3
 EQUB $21, $33, $07, $21 ; B790: 21 33 07... !3.
 EQUB $33, $07, $21, $33 ; B794: 33 07 21... 3.!
 EQUB $07, $21, $33, $07 ; B798: 07 21 33... .!3
 EQUB $28, $0F, $3F, $28 ; B79C: 28 0F 3F... (.?
 EQUB $AF, $77, $27, $55 ; B7A0: AF 77 27... .w'
 EQUB $77, $27, $55, $77 ; B7A4: 77 27 55... w'U
 EQUB $27, $55, $77, $27 ; B7A8: 27 55 77... 'Uw
 EQUB $55, $77, $27, $55 ; B7AC: 55 77 27... Uw'
 EQUB $18, $28, $0F, $3F ; B7B0: 18 28 0F... .(.
 EQUB $28, $AF, $77, $27 ; B7B4: 28 AF 77... (.w
 EQUB $5A, $77, $27, $55 ; B7B8: 5A 77 27... Zw'
 EQUB $77, $27, $55, $77 ; B7BC: 77 27 55... w'U
 EQUB $27, $55, $77, $27 ; B7C0: 27 55 77... 'Uw
 EQUB $55, $18, $28, $0F ; B7C4: 55 18 28... U.(
 EQUB $3F, $28, $AF, $77 ; B7C8: 3F 28 AF... ?(.
 EQUB $27, $55, $77, $27 ; B7CC: 27 55 77... 'Uw
 EQUB $55, $77, $27, $55 ; B7D0: 55 77 27... Uw'
 EQUB $77, $27, $55, $77 ; B7D4: 77 27 55... w'U
 EQUB $27, $55, $18, $28 ; B7D8: 27 55 18... 'U.
 EQUB $0F, $3F, $28, $5F ; B7DC: 0F 3F 28... .?(
 EQUB $77, $27, $55, $77 ; B7E0: 77 27 55... w'U
 EQUB $27, $55, $77, $27 ; B7E4: 27 55 77... 'Uw
 EQUB $55, $77, $27, $55 ; B7E8: 55 77 27... Uw'
 EQUB $BB, $27, $AA, $FB ; B7EC: BB 27 AA... .'.
 EQUB $27, $FA, $18, $3F ; B7F0: 27 FA 18... '..
 EQUB $23, $0F, $25, $5F ; B7F4: 23 0F 25... #.%
 EQUB $21, $33, $00, $21 ; B7F8: 21 33 00... !3.
 EQUB $04, $45, $24, $55 ; B7FC: 04 45 24... .E$
 EQUB $21, $33, $02, $54 ; B800: 21 33 02... !3.
 EQUB $55, $99, $22, $AA ; B804: 55 99 22... U."
 EQUB $21, $33, $00, $21 ; B808: 21 33 00... !3.
 EQUB $04, $22, $55, $99 ; B80C: 04 22 55... ."U
 EQUB $22, $AA, $F7, $27 ; B810: 22 AA F7... "..
 EQUB $F5, $1F, $11, $28 ; B814: F5 1F 11... ...
 EQUB $0F, $3F, $23, $0F ; B818: 0F 3F 23... .?#
 EQUB $4F, $24, $5F, $21 ; B81C: 4F 24 5F... O$_
 EQUB $33, $02, $25, $55 ; B820: 33 02 25... 3.%
 EQUB $21, $33, $00, $40 ; B824: 21 33 00... !3.
 EQUB $54, $55, $99, $22 ; B828: 54 55 99... TU.
 EQUB $AA, $21, $33, $00 ; B82C: AA 21 33... .!3
 EQUB $21, $04, $45, $55 ; B830: 21 04 45... !.E
 EQUB $99, $22, $AA, $1F ; B834: 99 22 AA... .".
 EQUB $19, $28, $0F, $3F ; B838: 19 28 0F... .(.
 EQUB $23, $0F, $25, $5F ; B83C: 23 0F 25... #.%
 EQUB $21, $33, $00, $21 ; B840: 21 33 00... !3.
 EQUB $04, $45, $24, $55 ; B844: 04 45 24... .E$
 EQUB $21, $33, $00, $22 ; B848: 21 33 00... !3.
 EQUB $50, $55, $99, $22 ; B84C: 50 55 99... PU.
 EQUB $AA, $21, $33, $00 ; B850: AA 21 33... .!3
 EQUB $21, $04, $22, $55 ; B854: 21 04 22... !."
 EQUB $99, $22, $AA, $1F ; B858: 99 22 AA... .".
 EQUB $1F, $12, $3F, $23 ; B85C: 1F 12 3F... ..?
 EQUB $AF, $25, $5F, $BB ; B860: AF 25 5F... .%_
 EQUB $22, $AA, $22, $5A ; B864: 22 AA 22... "."
 EQUB $23, $55, $BB, $AA ; B868: 23 55 BB... #U.
 EQUB $22, $A5, $22, $55 ; B86C: 22 A5 22... "."
 EQUB $02, $FB, $24, $FA ; B870: 02 FB 24... ..$
 EQUB $FF, $02, $16, $22 ; B874: FF 02 16... ...
 EQUB $F0, $1F, $19, $3F ; B878: F0 1F 19... ...
 EQUB $25, $AF, $23, $5F ; B87C: 25 AF 23... %.#
 EQUB $BB, $AA, $6A, $23 ; B880: BB AA 6A... ..j
 EQUB $5A, $22, $55, $BB ; B884: 5A 22 55... Z"U
 EQUB $22, $AA, $65, $22 ; B888: 22 AA 65... ".e
 EQUB $55, $02, $FB, $24 ; B88C: 55 02 FB... U..
 EQUB $FA, $FF, $02, $16 ; B890: FA FF 02... ...
 EQUB $22, $F0, $1F, $11 ; B894: 22 F0 1F... "..
 EQUB $28, $0F, $3F, $23 ; B898: 28 0F 3F... (.?
 EQUB $AF, $6F, $24, $5F ; B89C: AF 6F 24... .o$
 EQUB $BB, $23, $AA, $5A ; B8A0: BB 23 AA... .#.
 EQUB $56, $22, $55, $BB ; B8A4: 56 22 55... V"U
 EQUB $AA, $6A, $56, $22 ; B8A8: AA 6A 56... .jV
 EQUB $55, $22, $05, $FB ; B8AC: 55 22 05... U".
 EQUB $24, $FA, $FF, $02 ; B8B0: 24 FA FF... $..
 EQUB $16, $02, $1F, $19 ; B8B4: 16 02 1F... ...
 EQUB $3F, $18, $73, $22 ; B8B8: 3F 18 73... ?.s
 EQUB $50, $22, $A0, $60 ; B8BC: 50 22 A0... P".
 EQUB $22, $50, $77, $00 ; B8C0: 22 50 77... "Pw
 EQUB $99, $22, $AA, $66 ; B8C4: 99 22 AA... .".
 EQUB $22, $55, $73, $22 ; B8C8: 22 55 73... "Us
 EQUB $50, $22, $AA, $66 ; B8CC: 50 22 AA... P".
 EQUB $22, $55, $77, $55 ; B8D0: 22 55 77... "Uw
 EQUB $99, $22, $AA, $66 ; B8D4: 99 22 AA... .".
 EQUB $22, $55, $33, $37 ; B8D8: 22 55 33... "U3
 EQUB $05, $09, $22, $AA ; B8DC: 05 09 22... .."
 EQUB $A6, $22, $A5, $F3 ; B8E0: A6 22 A5... .".
 EQUB $22, $F0, $24, $FA ; B8E4: 22 F0 24... ".$
 EQUB $19, $3F, $18, $73 ; B8E8: 19 3F 18... .?.
 EQUB $22, $50, $22, $A0 ; B8EC: 22 50 22... "P"
 EQUB $60, $22, $50, $77 ; B8F0: 60 22 50... `"P
 EQUB $00, $99, $22, $AA ; B8F4: 00 99 22... .."
 EQUB $66, $22, $55, $73 ; B8F8: 66 22 55... f"U
 EQUB $22, $50, $22, $AA ; B8FC: 22 50 22... "P"
 EQUB $66, $22, $55, $77 ; B900: 66 22 55... f"U
 EQUB $55, $99, $22, $AA ; B904: 55 99 22... U."
 EQUB $66, $22, $55, $33 ; B908: 66 22 55... f"U
 EQUB $37, $05, $09, $8A ; B90C: 37 05 09... 7..
 EQUB $AA, $A6, $22, $A5 ; B910: AA A6 22... .."
 EQUB $F3, $22, $F0, $F8 ; B914: F3 22 F0... .".
 EQUB $23, $FA, $19, $3F ; B918: 23 FA 19... #..
 EQUB $18, $73, $22, $50 ; B91C: 18 73 22... .s"
 EQUB $22, $A0, $60, $22 ; B920: 22 A0 60... ".`
 EQUB $50, $77, $00, $99 ; B924: 50 77 00... Pw.
 EQUB $22, $AA, $66, $22 ; B928: 22 AA 66... ".f
 EQUB $55, $73, $22, $50 ; B92C: 55 73 22... Us"
 EQUB $22, $AA, $66, $22 ; B930: 22 AA 66... ".f
 EQUB $55, $77, $55, $99 ; B934: 55 77 55... UwU
 EQUB $22, $AA, $66, $22 ; B938: 22 AA 66... ".f
 EQUB $55, $33, $37, $05 ; B93C: 55 33 37... U37
 EQUB $09, $8A, $AA, $A6 ; B940: 09 8A AA... ...
 EQUB $22, $A5, $F3, $22 ; B944: 22 A5 F3... "..
 EQUB $F0, $F8, $23, $FA ; B948: F0 F8 23... ..#
 EQUB $19, $3F, $AF, $27 ; B94C: 19 3F AF... .?.
 EQUB $5F, $FB, $FA, $26 ; B950: 5F FB FA... _..
 EQUB $F5, $1F, $1F, $1A ; B954: F5 1F 1F... ...
 EQUB $28, $0F, $3F, $23 ; B958: 28 0F 3F... (.?
 EQUB $AF, $25, $5F, $FB ; B95C: AF 25 5F... .%_
 EQUB $22, $FA, $25, $F5 ; B960: 22 FA 25... ".%
 EQUB $1F, $1F, $1A, $28 ; B964: 1F 1F 1A... ...
 EQUB $0F, $3F, $22, $AF ; B968: 0F 3F 22... .?"
 EQUB $6F, $25, $5F, $FB ; B96C: 6F 25 5F... o%_
 EQUB $FA, $F6, $25, $F5 ; B970: FA F6 25... ..%
 EQUB $1F, $1F, $1A, $28 ; B974: 1F 1F 1A... ...
 EQUB $0F, $3F, $31, $3F ; B978: 0F 3F 31... .?1
 EQUB $27, $0F, $21, $33 ; B97C: 27 0F 21... '.!
 EQUB $07, $21, $33, $07 ; B980: 07 21 33... .!3
 EQUB $21, $33, $07, $21 ; B984: 21 33 07... !3.
 EQUB $33, $07, $21, $33 ; B988: 33 07 21... 3.!
 EQUB $07, $18, $28, $0F ; B98C: 07 18 28... ..(
 EQUB $3F, $31, $3F, $27 ; B990: 3F 31 3F... ?1?
 EQUB $0F, $21, $33, $07 ; B994: 0F 21 33... .!3
 EQUB $21, $33, $07, $21 ; B998: 21 33 07... !3.
 EQUB $33, $07, $21, $33 ; B99C: 33 07 21... 3.!
 EQUB $07, $F3, $27, $F0 ; B9A0: 07 F3 27... ..'
 EQUB $FB, $27, $5A, $28 ; B9A4: FB 27 5A... .'Z
 EQUB $0F, $3F           ; B9A8: 0F 3F       .?

; ******************************************************************************
;
;       Name: LB9AA
;       Type: Variable
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.LB9AA

 EQUB $00, $01, $16, $04 ; B9AA: 00 01 16... ...
 EQUB $05, $02, $0A, $13 ; B9AE: 05 02 0A... ...
 EQUB $0D, $09, $06, $10 ; B9B2: 0D 09 06... ...
 EQUB $03, $03, $02, $17 ; B9B6: 03 03 02... ...

; ******************************************************************************
;
;       Name: LB9BA
;       Type: Variable
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.LB9BA

 EQUB $00, $01, $16, $04 ; B9BA: 00 01 16... ...
 EQUB $05, $02, $0B, $14 ; B9BE: 05 02 0B... ...
 EQUB $0E, $09, $07, $11 ; B9C2: 0E 09 07... ...
 EQUB $03, $03, $02, $02 ; B9C6: 03 03 02... ...

; ******************************************************************************
;
;       Name: LB9CA
;       Type: Variable
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.LB9CA

 EQUB $00, $01, $16, $04 ; B9CA: 00 01 16... ...
 EQUB $05, $02, $0C, $15 ; B9CE: 05 02 0C... ...
 EQUB $0F, $09, $08, $12 ; B9D2: 0F 09 08... ...
 EQUB $03, $03, $02, $17 ; B9D6: 03 03 02... ...

; ******************************************************************************
;
;       Name: LB9DA
;       Type: Variable
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.LB9DA

 EQUB $AA, $BA, $CA, $AA ; B9DA: AA BA CA... ...

; ******************************************************************************
;
;       Name: LB9DE
;       Type: Variable
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.LB9DE

 EQUB $B9, $B9, $B9, $B9 ; B9DE: B9 B9 B9... ...

; ******************************************************************************
;
;       Name: subm_B9E2
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.subm_B9E2

 LDX language
 LDA LB9DA,X
 STA V
 LDA LB9DE,X
 STA V+1
 LDA QQ11
 AND #$0F
 TAY
 LDA (V),Y
 ASL A
 TAX
 LDA LB6C7,X
 ADC #$C5
 STA V
 LDA LB6C8,X
 ADC #$B6
 STA V+1

 LDA #HI(nameBuffer0+8*120) ; Set SC(1 0) to the address of tile number #120 in
 STA SC+1                   ; nametable buffer 0
 LDA #LO(nameBuffer0+8*120)
 STA SC

 JMP UnpackToRAM

; ******************************************************************************
;
;       Name: subm_BA23_BA11
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.subm_BA23_BA11

 LDA #$F0
 STA ySprite5
 STA ySprite6
 STA ySprite7
 STA ySprite8
 STA ySprite9
 RTS

; ******************************************************************************
;
;       Name: subm_BA23
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.subm_BA23

 LDY VIEW
 LDA LASER,Y
 BEQ subm_BA23_BA11
 CMP #$18
 BNE CBA32
 JMP CBAC6

.CBA32

 CMP #$8F
 BNE CBA39
 JMP CBB08

.CBA39

 CMP #$97
 BNE CBA83
 LDA #$80
 STA attrSprite8
 LDA #$40
 STA attrSprite6
 LDA #0
 STA attrSprite7
 STA attrSprite5
 LDY #$CF
 STY tileSprite5
 STY tileSprite6
 INY
 STY tileSprite7
 STY tileSprite8
 LDA #$76
 STA xSprite5
 LDA #$86
 STA xSprite6
 LDA #$7E
 STA xSprite7
 STA xSprite8
 LDA #$53
 STA ySprite5
 STA ySprite6
 LDA #$4B
 STA ySprite7
 LDA #$5B
 STA ySprite8
 RTS

.CBA83

 LDA #3
 STA attrSprite5
 LDA #$43
 STA attrSprite6
 LDA #$83
 STA attrSprite7
 LDA #$C3
 STA attrSprite8
 LDA #$D1
 STA tileSprite5
 STA tileSprite6
 STA tileSprite7
 STA tileSprite8
 LDA #$76
 STA xSprite5
 STA xSprite7
 LDA #$86
 STA xSprite6
 STA xSprite8
 LDA #$4B
 STA ySprite5
 STA ySprite6
 LDA #$5B
 STA ySprite7
 STA ySprite8
 RTS

.CBAC6

 LDA #1
 LDY #$CC
 STA attrSprite5
 STA attrSprite6
 STA attrSprite7
 STA attrSprite8
 STY tileSprite5
 STY tileSprite6
 INY
 STY tileSprite7
 STY tileSprite8
 LDA #$72
 STA xSprite5
 LDA #$8A
 STA xSprite6
 LDA #$7E
 STA xSprite7
 STA xSprite8
 LDA #$53
 STA ySprite5
 STA ySprite6
 LDA #$47
 STA ySprite7
 LDA #$5F
 STA ySprite8
 RTS

.CBB08

 LDA #2
 STA attrSprite5
 LDA #$42
 STA attrSprite6
 LDA #$82
 STA attrSprite7
 LDA #$C2
 STA attrSprite8
 LDA #$CE
 STA tileSprite5
 STA tileSprite6
 STA tileSprite7
 STA tileSprite8
 LDA #$7A
 STA xSprite5
 STA xSprite7
 LDA #$82
 STA xSprite6
 STA xSprite8
 LDA #$4B
 STA ySprite5
 STA ySprite6
 LDA #$5B
 STA ySprite7
 STA ySprite8
 RTS

; ******************************************************************************
;
;       Name: Vectors
;       Type: Variable
;   Category: Text
;    Summary: Vectors and padding at the end of the ROM bank
;
; ******************************************************************************

 FOR I%, P%, $BFF9

  EQUB $FF              ; Pad out the rest of the ROM bank with $FF

 NEXT

 EQUW Interrupts+$4000  ; Vector to the NMI handler in case this bank is loaded
                        ; into $C000 during startup (the handler contains an RTI
                        ; so the interrupt is processed but has no effect)

 EQUW ResetMMC1+$4000   ; Vector to the RESET handler in case this bank is
                        ; loaded into $C000 during startup (the handler resets
                        ; the MMC1 mapper to map bank 7 into $C000 instead)

 EQUW Interrupts+$4000  ; Vector to the IRQ/BRK handler in case this bank is
                        ; loaded into $C000 during startup (the handler contains
                        ; an RTI so the interrupt is processed but has no
                        ; effect)

; ******************************************************************************
;
; Save bank3.bin
;
; ******************************************************************************

 PRINT "S.bank3.bin ", ~CODE%, " ", ~P%, " ", ~LOAD%, " ", ~LOAD%
 SAVE "3-assembled-output/bank3.bin", CODE%, P%, LOAD%
