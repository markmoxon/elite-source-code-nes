; ******************************************************************************
;
; NES ELITE GAME SOURCE (BANK 7)
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
;   * bank7.bin
;
; ******************************************************************************

 INCLUDE "1-source-files/main-sources/elite-bank-options.asm"

IF _BANK = 7

 INCLUDE "1-source-files/main-sources/elite-build-options.asm"

 INCLUDE "1-source-files/main-sources/elite-source-common.asm"

ENDIF

; ******************************************************************************
;
; ELITE BANK 7
;
; Produces the binary file bank7.bin.
;
; ******************************************************************************

 CODE_BANK_7% = $C000
 LOAD_BANK_7% = $C000

 ORG CODE_BANK_7%

; ******************************************************************************
;
;       Name: ResetMMC1_b7
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
; We need to give a different label to this version of the reset routine so we
; can assemble bank 7 at the same time as banks 0 to 6, to enable the lower
; banks to see the exported addresses for bank 7.
;
; ******************************************************************************

.ResetMMC1_b7

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
;       Name: S%
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.S%

 SEI
 CLD
 LDX #$FF
 TXS
 LDX #0
 STX startupDebug
 LDA #$10
 STA PPU_CTRL
 STA ppuCtrlCopy
 LDA #0
 STA PPU_MASK

.loop_CC01C

 LDA PPU_STATUS
 BPL loop_CC01C

.loop_CC021

 LDA PPU_STATUS
 BPL loop_CC021

.loop_CC026

 LDA PPU_STATUS
 BPL loop_CC026
 LDA #0
 STA K%
 LDA #$3C
 STA K%+1

.CC035

 LDX #$FF
 TXS
 JSR ResetVariables
 JMP subm_B2C3

; ******************************************************************************
;
;       Name: ResetVariables
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.ResetVariables

 LDA #0
 STA PPU_CTRL
 STA ppuCtrlCopy
 STA PPU_MASK
 STA setupPPUForIconBar
 LDA #$40
 STA JOY2
 INC $C006
 LDA PPU_STATUS

.loop_CC055

 LDA PPU_STATUS
 BPL loop_CC055

.loop_CC05A

 LDA PPU_STATUS
 BPL loop_CC05A

.loop_CC05F

 LDA PPU_STATUS
 BPL loop_CC05F
 LDA #0
 TAX

.loop_CC067

 STA ZP,X
 INX
 BNE loop_CC067
 LDA #3
 STA SC+1
 LDA #0
 STA SC
 TXA
 LDX #3
 TAY

.CC078

 STA (SC),Y
 INY
 BNE CC078
 INC SC+1
 DEX
 BNE CC078
 JSR SetupMMC1
 JSR ResetSoundL045E
 LDA #$80
 ASL A
 JSR DrawTitleScreen_b3
 JSR subm_F48D
 JSR subm_F493
 LDA #0
 STA DTW6
 LDA #$FF
 STA DTW2
 LDA #$FF
 STA DTW8

.CC0A3

 LDA #0
 JMP SetBank

; ******************************************************************************
;
;       Name: subm_C0A8
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.subm_C0A8

 CMP currentBank
 BNE SetBank
 RTS

; ******************************************************************************
;
;       Name: ResetBank
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.ResetBank

 PLA

; ******************************************************************************
;
;       Name: SetBank
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.SetBank

 DEC runningSetBank
 STA currentBank
 STA $FFFF
 LSR A
 STA $FFFF
 LSR A
 STA $FFFF
 LSR A
 STA $FFFF
 LSR A
 STA $FFFF
 INC runningSetBank
 BNE CC0CA
 RTS

.CC0CA

 LDA #0
 STA runningSetBank
 LDA currentBank
 PHA
 TXA
 PHA
 TYA
 PHA
 JSR PlayMusic_b6
 PLA
 TAY
 PLA
 TAX
 JMP ResetBank

; ******************************************************************************
;
;       Name: LC0DF
;       Type: Variable
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.LC0DF

 EQUB   6,   6,   7,   7

; ******************************************************************************
;
;       Name: LC0E3
;       Type: Variable
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.LC0E3

 EQUB $0B,   9, $0D, $0A

IF _NTSC

 EQUB $20, $20, $20, $20  ; C0DF: 06 06 07... ...
 EQUB $10,   0, $C4, $ED, $5E, $E5, $22, $E5  ; C0EB: 10 00 C4... ...
 EQUB $22,   0,   0, $ED, $5E, $E5, $22,   9  ; C0F3: 22 00 00... "..
 EQUB $68,   0,   0,   0,   0                 ; C0FB: 68 00 00... h..

ELIF _PAL

 EQUB $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
 EQUB $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
 EQUB $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
 EQUB $FF

ENDIF

; ******************************************************************************
;
;       Name: log
;       Type: Variable
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.log

 EQUB $6C, $00, $20, $32, $40, $4A, $52, $59  ; C100: 6C 00 20... l.
 EQUB $5F, $65, $6A, $6E, $72, $76, $79, $7D  ; C108: 5F 65 6A... _ej
 EQUB $80, $82, $85, $87, $8A, $8C, $8E, $90  ; C110: 80 82 85... ...
 EQUB $92, $94, $96, $98, $99, $9B, $9D, $9E  ; C118: 92 94 96... ...
 EQUB $A0, $A1, $A2, $A4, $A5, $A6, $A7, $A9  ; C120: A0 A1 A2... ...
 EQUB $AA, $AB, $AC, $AD, $AE, $AF, $B0, $B1  ; C128: AA AB AC... ...
 EQUB $B2, $B3, $B4, $B5, $B6, $B7, $B8, $B9  ; C130: B2 B3 B4... ...
 EQUB $B9, $BA, $BB, $BC, $BD, $BD, $BE, $BF  ; C138: B9 BA BB... ...
 EQUB $BF, $C0, $C1, $C2, $C2, $C3, $C4, $C4  ; C140: BF C0 C1... ...
 EQUB $C5, $C6, $C6, $C7, $C7, $C8, $C9, $C9  ; C148: C5 C6 C6... ...
 EQUB $CA, $CA, $CB, $CC, $CC, $CD, $CD, $CE  ; C150: CA CA CB... ...
 EQUB $CE, $CF, $CF, $D0, $D0, $D1, $D1, $D2  ; C158: CE CF CF... ...
 EQUB $D2, $D3, $D3, $D4, $D4, $D5, $D5, $D5  ; C160: D2 D3 D3... ...
 EQUB $D6, $D6, $D7, $D7, $D8, $D8, $D9, $D9  ; C168: D6 D6 D7... ...
 EQUB $D9, $DA, $DA, $DB, $DB, $DB, $DC, $DC  ; C170: D9 DA DA... ...
 EQUB $DD, $DD, $DD, $DE, $DE, $DE, $DF, $DF  ; C178: DD DD DD... ...
 EQUB $E0, $E0, $E0, $E1, $E1, $E1, $E2, $E2  ; C180: E0 E0 E0... ...
 EQUB $E2, $E3, $E3, $E3, $E4, $E4, $E4, $E5  ; C188: E2 E3 E3... ...
 EQUB $E5, $E5, $E6, $E6, $E6, $E7, $E7, $E7  ; C190: E5 E5 E6... ...
 EQUB $E7, $E8, $E8, $E8, $E9, $E9, $E9, $EA  ; C198: E7 E8 E8... ...
 EQUB $EA, $EA, $EA, $EB, $EB, $EB, $EC, $EC  ; C1A0: EA EA EA... ...
 EQUB $EC, $EC, $ED, $ED, $ED, $ED, $EE, $EE  ; C1A8: EC EC ED... ...
 EQUB $EE, $EE, $EF, $EF, $EF, $EF, $F0, $F0  ; C1B0: EE EE EF... ...
 EQUB $F0, $F1, $F1, $F1, $F1, $F1, $F2, $F2  ; C1B8: F0 F1 F1... ...
 EQUB $F2, $F2, $F3, $F3, $F3, $F3, $F4, $F4  ; C1C0: F2 F2 F3... ...
 EQUB $F4, $F4, $F5, $F5, $F5, $F5, $F5, $F6  ; C1C8: F4 F4 F5... ...
 EQUB $F6, $F6, $F6, $F7, $F7, $F7, $F7, $F7  ; C1D0: F6 F6 F6... ...
 EQUB $F8, $F8, $F8, $F8, $F9, $F9, $F9, $F9  ; C1D8: F8 F8 F8... ...
 EQUB $F9, $FA, $FA, $FA, $FA, $FA, $FB, $FB  ; C1E0: F9 FA FA... ...
 EQUB $FB, $FB, $FB, $FC, $FC, $FC, $FC, $FC  ; C1E8: FB FB FB... ...
 EQUB $FD, $FD, $FD, $FD, $FD, $FD, $FE, $FE  ; C1F0: FD FD FD... ...
 EQUB $FE, $FE, $FE, $FF, $FF, $FF, $FF, $FF  ; C1F8: FE FE FE... ...

; ******************************************************************************
;
;       Name: logL
;       Type: Variable
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.logL

 EQUB $0D, $00, $00, $B8, $00, $4D, $B8, $D5  ; C200: 0D 00 00... ...
 EQUB $FF, $70, $4D, $B3, $B8, $6A, $D5, $05  ; C208: FF 70 4D... .pM
 EQUB $00, $CC, $70, $EF, $4D, $8D, $B3, $C1  ; C210: 00 CC 70... ..p
 EQUB $B8, $9A, $6A, $28, $D5, $74, $05, $88  ; C218: B8 9A 6A... ..j
 EQUB $00, $6B, $CC, $23, $70, $B3, $EF, $22  ; C220: 00 6B CC... .k.
 EQUB $4D, $71, $8D, $A3, $B3, $BD, $C1, $BF  ; C228: 4D 71 8D... Mq.
 EQUB $B8, $AB, $9A, $84, $6A, $4B, $28, $00  ; C230: B8 AB 9A... ...
 EQUB $D5, $A7, $74, $3E, $05, $C8, $88, $45  ; C238: D5 A7 74... ..t
 EQUB $FF, $B7, $6B, $1D, $CC, $79, $23, $CA  ; C240: FF B7 6B... ..k
 EQUB $70, $13, $B3, $52, $EF, $89, $22, $B8  ; C248: 70 13 B3... p..
 EQUB $4D, $E0, $71, $00, $8D, $19, $A3, $2C  ; C250: 4D E0 71... M.q
 EQUB $B3, $39, $BD, $3F, $C1, $40, $BF, $3C  ; C258: B3 39 BD... .9.
 EQUB $B8, $32, $AB, $23, $9A, $10, $84, $F7  ; C260: B8 32 AB... .2.
 EQUB $6A, $DB, $4B, $BA, $28, $94, $00, $6B  ; C268: 6A DB 4B... j.K
 EQUB $D5, $3E, $A7, $0E, $74, $DA, $3E, $A2  ; C270: D5 3E A7... .>.
 EQUB $05, $67, $C8, $29, $88, $E7, $45, $A3  ; C278: 05 67 C8... .g.
 EQUB $00, $5B, $B7, $11, $6B, $C4, $1D, $75  ; C280: 00 5B B7... .[.
 EQUB $CC, $23, $79, $CE, $23, $77, $CA, $1D  ; C288: CC 23 79... .#y
 EQUB $70, $C1, $13, $63, $B3, $03, $52, $A1  ; C290: 70 C1 13... p..
 EQUB $EF, $3C, $89, $D6, $22, $6D, $B8, $03  ; C298: EF 3C 89... .<.
 EQUB $4D, $96, $E0, $28, $71, $B8, $00, $47  ; C2A0: 4D 96 E0... M..
 EQUB $8D, $D4, $19, $5F, $A3, $E8, $2C, $70  ; C2A8: 8D D4 19... ...
 EQUB $B3, $F6, $39, $7B, $BD, $FE, $3F, $80  ; C2B0: B3 F6 39... ..9
 EQUB $C1, $01, $40, $80, $BF, $FD, $3C, $7A  ; C2B8: C1 01 40... ..@
 EQUB $B8, $F5, $32, $6F, $AB, $E7, $23, $5F  ; C2C0: B8 F5 32... ..2
 EQUB $9A, $D5, $10, $4A, $84, $BE, $F7, $31  ; C2C8: 9A D5 10... ...
 EQUB $6A, $A2, $DB, $13, $4B, $82, $BA, $F1  ; C2D0: 6A A2 DB... j..
 EQUB $28, $5E, $94, $CB, $00, $36, $6B, $A0  ; C2D8: 28 5E 94... (^.
 EQUB $D5, $0A, $3E, $73, $A7, $DA, $0E, $41  ; C2E0: D5 0A 3E... ..>
 EQUB $74, $A7, $DA, $0C, $3E, $70, $A2, $D3  ; C2E8: 74 A7 DA... t..
 EQUB $05, $36, $67, $98, $C8, $F8, $29, $59  ; C2F0: 05 36 67... .6g
 EQUB $88, $B8, $E7, $16, $45, $74, $A3, $D1  ; C2F8: 88 B8 E7... ...

; ******************************************************************************
;
;       Name: antilog
;       Type: Variable
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.antilog

 EQUB $01, $01, $01, $01, $01, $01, $01, $01  ; C300: 01 01 01... ...
 EQUB $01, $01, $01, $01, $01, $01, $01, $01  ; C308: 01 01 01... ...
 EQUB $01, $01, $01, $01, $01, $01, $01, $01  ; C310: 01 01 01... ...
 EQUB $01, $01, $01, $01, $01, $01, $01, $01  ; C318: 01 01 01... ...
 EQUB $02, $02, $02, $02, $02, $02, $02, $02  ; C320: 02 02 02... ...
 EQUB $02, $02, $02, $02, $02, $02, $02, $02  ; C328: 02 02 02... ...
 EQUB $02, $02, $02, $03, $03, $03, $03, $03  ; C330: 02 02 02... ...
 EQUB $03, $03, $03, $03, $03, $03, $03, $03  ; C338: 03 03 03... ...
 EQUB $04, $04, $04, $04, $04, $04, $04, $04  ; C340: 04 04 04... ...
 EQUB $04, $04, $04, $05, $05, $05, $05, $05  ; C348: 04 04 04... ...
 EQUB $05, $05, $05, $06, $06, $06, $06, $06  ; C350: 05 05 05... ...
 EQUB $06, $06, $07, $07, $07, $07, $07, $07  ; C358: 06 06 07... ...
 EQUB $08, $08, $08, $08, $08, $08, $09, $09  ; C360: 08 08 08... ...
 EQUB $09, $09, $09, $0A, $0A, $0A, $0A, $0B  ; C368: 09 09 09... ...
 EQUB $0B, $0B, $0B, $0C, $0C, $0C, $0C, $0D  ; C370: 0B 0B 0B... ...
 EQUB $0D, $0D, $0E, $0E, $0E, $0E, $0F, $0F  ; C378: 0D 0D 0E... ...
 EQUB $10, $10, $10, $11, $11, $11, $12, $12  ; C380: 10 10 10... ...
 EQUB $13, $13, $13, $14, $14, $15, $15, $16  ; C388: 13 13 13... ...
 EQUB $16, $17, $17, $18, $18, $19, $19, $1A  ; C390: 16 17 17... ...
 EQUB $1A, $1B, $1C, $1C, $1D, $1D, $1E, $1F  ; C398: 1A 1B 1C... ...
 EQUB $20, $20, $21, $22, $22, $23, $24, $25  ; C3A0: 20 20 21...   !
 EQUB $26, $26, $27, $28, $29, $2A, $2B, $2C  ; C3A8: 26 26 27... &&'
 EQUB $2D, $2E, $2F, $30, $31, $32, $33, $34  ; C3B0: 2D 2E 2F... -./
 EQUB $35, $36, $38, $39, $3A, $3B, $3D, $3E  ; C3B8: 35 36 38... 568
 EQUB $40, $41, $42, $44, $45, $47, $48, $4A  ; C3C0: 40 41 42... @AB
 EQUB $4C, $4D, $4F, $51, $52, $54, $56, $58  ; C3C8: 4C 4D 4F... LMO
 EQUB $5A, $5C, $5E, $60, $62, $64, $67, $69  ; C3D0: 5A 5C 5E... Z\^
 EQUB $6B, $6D, $70, $72, $75, $77, $7A, $7D  ; C3D8: 6B 6D 70... kmp
 EQUB $80, $82, $85, $88, $8B, $8E, $91, $94  ; C3E0: 80 82 85... ...
 EQUB $98, $9B, $9E, $A2, $A5, $A9, $AD, $B1  ; C3E8: 98 9B 9E... ...
 EQUB $B5, $B8, $BD, $C1, $C5, $C9, $CE, $D2  ; C3F0: B5 B8 BD... ...
 EQUB $D7, $DB, $E0, $E5, $EA, $EF, $F5, $FA  ; C3F8: D7 DB E0... ...

; ******************************************************************************
;
;       Name: antilogODD
;       Type: Variable
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.antilogODD

 EQUB $01, $01, $01, $01, $01, $01, $01, $01  ; C400: 01 01 01... ...
 EQUB $01, $01, $01, $01, $01, $01, $01, $01  ; C408: 01 01 01... ...
 EQUB $01, $01, $01, $01, $01, $01, $01, $01  ; C410: 01 01 01... ...
 EQUB $01, $01, $01, $01, $01, $01, $01, $01  ; C418: 01 01 01... ...
 EQUB $02, $02, $02, $02, $02, $02, $02, $02  ; C420: 02 02 02... ...
 EQUB $02, $02, $02, $02, $02, $02, $02, $02  ; C428: 02 02 02... ...
 EQUB $02, $02, $02, $03, $03, $03, $03, $03  ; C430: 02 02 02... ...
 EQUB $03, $03, $03, $03, $03, $03, $03, $03  ; C438: 03 03 03... ...
 EQUB $04, $04, $04, $04, $04, $04, $04, $04  ; C440: 04 04 04... ...
 EQUB $04, $04, $05, $05, $05, $05, $05, $05  ; C448: 04 04 05... ...
 EQUB $05, $05, $05, $06, $06, $06, $06, $06  ; C450: 05 05 05... ...
 EQUB $06, $06, $07, $07, $07, $07, $07, $07  ; C458: 06 06 07... ...
 EQUB $08, $08, $08, $08, $08, $09, $09, $09  ; C460: 08 08 08... ...
 EQUB $09, $09, $0A, $0A, $0A, $0A, $0A, $0B  ; C468: 09 09 0A... ...
 EQUB $0B, $0B, $0B, $0C, $0C, $0C, $0D, $0D  ; C470: 0B 0B 0B... ...
 EQUB $0D, $0D, $0E, $0E, $0E, $0F, $0F, $0F  ; C478: 0D 0D 0E... ...
 EQUB $10, $10, $10, $11, $11, $12, $12, $12  ; C480: 10 10 10... ...
 EQUB $13, $13, $14, $14, $14, $15, $15, $16  ; C488: 13 13 14... ...
 EQUB $16, $17, $17, $18, $18, $19, $1A, $1A  ; C490: 16 17 17... ...
 EQUB $1B, $1B, $1C, $1D, $1D, $1E, $1E, $1F  ; C498: 1B 1B 1C... ...
 EQUB $20, $21, $21, $22, $23, $24, $24, $25  ; C4A0: 20 21 21...  !!
 EQUB $26, $27, $28, $29, $29, $2A, $2B, $2C  ; C4A8: 26 27 28... &'(
 EQUB $2D, $2E, $2F, $30, $31, $32, $34, $35  ; C4B0: 2D 2E 2F... -./
 EQUB $36, $37, $38, $3A, $3B, $3C, $3D, $3F  ; C4B8: 36 37 38... 678
 EQUB $40, $42, $43, $45, $46, $48, $49, $4B  ; C4C0: 40 42 43... @BC
 EQUB $4C, $4E, $50, $52, $53, $55, $57, $59  ; C4C8: 4C 4E 50... LNP
 EQUB $5B, $5D, $5F, $61, $63, $65, $68, $6A  ; C4D0: 5B 5D 5F... []_
 EQUB $6C, $6F, $71, $74, $76, $79, $7B, $7E  ; C4D8: 6C 6F 71... loq
 EQUB $81, $84, $87, $8A, $8D, $90, $93, $96  ; C4E0: 81 84 87... ...
 EQUB $99, $9D, $A0, $A4, $A7, $AB, $AF, $B3  ; C4E8: 99 9D A0... ...
 EQUB $B6, $BA, $BF, $C3, $C7, $CB, $D0, $D4  ; C4F0: B6 BA BF... ...
 EQUB $D9, $DE, $E3, $E8, $ED, $F2, $F7, $FD  ; C4F8: D9 DE E3... ...

; ******************************************************************************
;
;       Name: SNE
;       Type: Variable
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.SNE

 EQUB $00, $19, $32, $4A, $62, $79, $8E, $A2  ; C500: 00 19 32... ..2
 EQUB $B5, $C6, $D5, $E2, $ED, $F5, $FB, $FF  ; C508: B5 C6 D5... ...
 EQUB $FF, $FF, $FB, $F5, $ED, $E2, $D5, $C6  ; C510: FF FF FB... ...
 EQUB $B5, $A2, $8E, $79, $62, $4A, $32, $19  ; C518: B5 A2 8E... ...

; ******************************************************************************
;
;       Name: ACT
;       Type: Variable
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.ACT

 EQUB $00, $01, $03, $04, $05, $06, $08, $09  ; C520: 00 01 03... ...
 EQUB $0A, $0B, $0C, $0D, $0F, $10, $11, $12  ; C528: 0A 0B 0C... ...
 EQUB $13, $14, $15, $16, $17, $18, $19, $19  ; C530: 13 14 15... ...
 EQUB $1A, $1B, $1C, $1D, $1D, $1E, $1F, $1F  ; C538: 1A 1B 1C... ...

; ******************************************************************************
;
;       Name: XX21
;       Type: Variable
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.XX21

 EQUB $A5                                     ; C540: A5          .
 EQUB $80                                     ; C541: 80          .
 EQUB $A3                                     ; C542: A3          .
 EQUB $81, $BF, $82, $13                      ; C543: 81 BF 82... ...
 EQUB $83, $53, $83, $FB, $83, $9D, $84, $73  ; C547: 83 53 83... .S.
 EQUB $85, $AF, $85, $E1, $86, $C3, $88, $4B  ; C54F: 85 AF 85... ...
 EQUB $8A, $3D, $8B, $33, $8C, $35, $8D, $0B  ; C557: 8A 3D 8B... .=.
 EQUB $8E, $E5, $8E, $8D, $8F, $BB, $90, $A1  ; C55F: 8E E5 8E... ...
 EQUB $91, $D1, $92, $95, $93, $5B, $94, $0B  ; C567: 91 D1 92... ...
 EQUB $95, $93, $96, $BD, $97, $AF, $98, $C9  ; C56F: 95 93 96... ...
 EQUB $99, $A1, $9A, $BD, $9B, $29, $9C, $2B  ; C577: 99 A1 9A... ...
 EQUB $9D                                     ; C57F: 9D          .
 EQUB $2D                                     ; C580: 2D          -
 EQUB $9E                                     ; C581: 9E          .

; ******************************************************************************
;
;       Name: subm_C582
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.subm_C582

 SEC
 LDA tempVar
 SBC #$53
 STA tempVar
 LDA tempVar+1
 SBC #8
 STA tempVar+1
 LDX addr1
 STX addr5
 LDA addr1+1
 CLC
 ADC #$70
 STA addr5+1
 LDA addr1+1
 ADC #$20
 STA PPU_ADDR
 STX PPU_ADDR
 LDY #0

.loop_CC5A6

 LDA (addr5),Y
 STA PPU_DATA
 INY
 CPY #$40
 BNE loop_CC5A6
 LDA addr1+1
 ADC #$23
 STA PPU_ADDR
 STX PPU_ADDR
 LDY #0

.loop_CC5BC

 LDA (addr5),Y
 STA PPU_DATA
 INY
 CPY #$40
 BNE loop_CC5BC
 LDA L00D7
 BMI CC5CD
 JMP subm_C630

.CC5CD

 STA L00D3
 JMP subm_C6C6

; ******************************************************************************
;
;       Name: subm_C5D2
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.subm_C5D2

 SEC
 LDA tempVar
 SBC #$9A
 STA tempVar
 LDA tempVar+1
 SBC #2
 STA tempVar+1
 BMI CC5E4
 JMP CC5F3

.CC5E4

 LDA tempVar
 ADC #$6F
 STA tempVar
 LDA tempVar+1
 ADC #2
 STA tempVar+1
 JMP CC6F3

.CC5F3

 LDA #0
 STA addr5
 LDA L00D3
 ASL A
 ASL A
 ASL A
 TAY
 LDA #1
 ROL A
 STA addr4
 TYA
 ADC #$50
 TAX
 LDA addr4
 ADC #0
 STA PPU_ADDR
 STX PPU_ADDR
 LDA L00D6
 ADC addr4
 STA addr5+1
 LDX #$20

.loop_CC618

 LDA (addr5),Y
 STA PPU_DATA
 INY
 DEX
 BEQ CC624
 JMP loop_CC618

.CC624

 LDA L00D3
 CLC
 ADC #4
 STA L00D3
 BPL subm_C5D2
 JMP subm_C6C6

; ******************************************************************************
;
;       Name: subm_C630
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.subm_C630

 ASL A
 BMI subm_C5D2
 SEC
 LDA tempVar
 SBC #$11
 STA tempVar
 LDA tempVar+1
 SBC #5
 STA tempVar+1
 BMI CC645
 JMP CC654

.CC645

 LDA tempVar
 ADC #$E3
 STA tempVar
 LDA tempVar+1
 ADC #4
 STA tempVar+1
 JMP CC6F3

.CC654

 LDA #0
 STA addr5
 LDA L00D3
 ASL A
 ASL A
 ASL A
 TAY
 LDA #0
 ROL A
 STA addr4
 TYA
 ADC #$50
 TAX
 LDA addr4
 ADC #0
 STA PPU_ADDR
 STX PPU_ADDR
 LDA L00D6
 ADC addr4
 STA addr5+1
 LDX #$20

.loop_CC679

 LDA (addr5),Y
 STA PPU_DATA
 INY
 DEX
 BEQ CC685
 JMP loop_CC679

.CC685

 LDA #0
 STA addr5
 LDA L00D3
 ASL A
 ASL A
 ASL A
 TAY
 LDA #0
 ROL A
 STA addr4
 TYA
 ADC #$50
 TAX
 LDA addr4
 ADC #$10
 STA PPU_ADDR
 STX PPU_ADDR
 LDA L00D6
 ADC addr4
 STA addr5+1
 LDX #$20

.loop_CC6AA

 LDA (addr5),Y
 STA PPU_DATA
 INY
 DEX
 BEQ CC6B6
 JMP loop_CC6AA

.CC6B6

 LDA L00D3
 CLC
 ADC #4
 STA L00D3
 JMP subm_C630

; ******************************************************************************
;
;       Name: subm_C6C0
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.subm_C6C0

 JMP subm_C630

; ******************************************************************************
;
;       Name: subm_C6C3
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.subm_C6C3

 JMP subm_C582

; ******************************************************************************
;
;       Name: subm_C6C6
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.subm_C6C6

 LDX otherPhase
 LDA L03EF,X
 AND #$10
 BEQ CC6F3
 SEC
 LDA tempVar
 SBC #$2A
 STA tempVar
 LDA tempVar+1
 SBC #0
 STA tempVar+1
 BMI CC6E1
 JMP CC6F0

.CC6E1

 LDA tempVar
 ADC #$F1
 STA tempVar
 LDA tempVar+1
 ADC #$FF
 STA tempVar+1
 JMP CC6F3

.CC6F0

 JMP CC849

.CC6F3

 RTS

; ******************************************************************************
;
;       Name: subm_C6F4
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.subm_C6F4

 LDA L00D3
 BEQ subm_C6C3
 BPL subm_C6C0
 LDX otherPhase
 LDA L03EF,X
 AND #$10
 BEQ CC77E
 SEC
 LDA tempVar
 SBC #$38
 STA tempVar
 LDA tempVar+1
 SBC #0
 STA tempVar+1
 TXA
 EOR #1
 TAY
 LDA L03EF,Y
 AND #$A0
 ORA L00F6
 CMP #$81
 BNE CC738
 LDA tile0Phase0,X
 BNE CC725
 LDA #$FF

.CC725

 CMP L00CA,X
 BEQ CC73B
 BCS CC73B
 SEC
 LDA tempVar
 SBC #$20
 STA tempVar
 LDA tempVar+1
 SBC #0
 STA tempVar+1

.CC738

 JMP CC849

.CC73B

 LDA L03EF,X
 ASL A
 BPL CC6F3
 LDY L00CD,X
 AND #8
 BEQ CC749
 LDY #$80

.CC749

 TYA
 SEC
 SBC tile3Phase0,X
 CMP #$30
 BCC CC761
 SEC
 LDA tempVar
 SBC #$3C
 STA tempVar
 LDA tempVar+1
 SBC #0
 STA tempVar+1

.loop_CC75E

 JMP CC849

.CC761

 LDA ppuCtrlCopy
 BEQ loop_CC75E
 SEC
 LDA tempVar
 SBC #$86
 STA tempVar
 LDA tempVar+1
 SBC #0
 STA tempVar+1
 LDA L00F6
 EOR palettePhase
 STA palettePhase
 JSR subm_CF4C
 JMP CC849

.CC77E

 SEC
 LDA tempVar
 SBC #$2A
 STA tempVar
 LDA tempVar+1
 SBC #1
 STA tempVar+1
 LDA L03EF
 AND #$A0
 CMP #$80
 BNE CC79E
 NOP
 NOP
 NOP
 NOP
 NOP
 LDX #0
 JMP CC7C7

.CC79E

 LDA L03F0
 AND #$A0
 CMP #$80
 BEQ CC7C5
 CLC
 LDA tempVar
 ADC #$DF
 STA tempVar
 LDA tempVar+1
 ADC #0
 STA tempVar+1
 RTS

.loop_CC7B5

 CLC
 LDA tempVar
 ADC #$2D
 STA tempVar
 LDA tempVar+1
 ADC #0
 STA tempVar+1
 JMP CC7D2

.CC7C5

 LDX #1

.CC7C7

 STX otherPhase
 LDA L00F6
 BEQ loop_CC7B5
 STX palettePhase
 JSR subm_CF4C

.CC7D2

 TXA
 ASL A
 ASL A
 ASL A
 STA pallettePhasex8
 LSR A
 ORA #$20
 STA debugNametableHi
 LDA #$10
 STA L00E0
 LDA #0
 STA debugNametableLo
 LDA L00CC
 STA tile3Phase0,X
 STA tile2Phase0,X
 LDA L00D2
 STA L00CA,X
 STA tile1Phase0,X
 LDA L03EF,X
 ORA #$10
 STA L03EF,X
 LDA #0
 STA addr4
 LDA L00CA,X
 ASL A
 ROL addr4
 ASL A
 ROL addr4
 ASL A
 STA L00DB,X
 LDA addr4
 ROL A
 ADC pattBufferAddr,X
 STA L04BE,X
 LDA #0
 STA addr4
 LDA tile3Phase0,X
 ASL A
 ROL addr4
 ASL A
 ROL addr4
 ASL A
 STA L00DD,X
 ROL addr4
 LDA addr4
 ADC nameBufferAddr,X
 STA L04C0,X
 LDA debugNametableHi
 SEC
 SBC nameBufferAddr,X
 STA L04C6,X
 JMP CC849

; ******************************************************************************
;
;       Name: subm_C836
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.subm_C836

 CLC
 LDA tempVar
 ADC #4
 STA tempVar
 LDA tempVar+1
 ADC #0
 STA tempVar+1
 JMP CCBDD

.CC846

 JMP CCA2E

.CC849

 SEC
 LDA tempVar
 SBC #$B6
 STA tempVar
 LDA tempVar+1
 SBC #0
 STA tempVar+1
 BMI CC85B
 JMP CC86A

.CC85B

 LDA tempVar
 ADC #$8D
 STA tempVar
 LDA tempVar+1
 ADC #0
 STA tempVar+1
 JMP CC6F3

.CC86A

 LDA tile0Phase0,X
 BNE CC870
 LDA #$FF

.CC870

 STA temp1
 LDA debugNametableHi
 SEC
 SBC nameBufferAddr,X
 STA L04C6,X
 LDY L00DB,X
 LDA L04BE,X
 STA addr5+1
 LDA L00CA,X
 STA L00C9
 SEC
 SBC temp1
 BCS subm_C836
 LDX ppuCtrlCopy
 BEQ CC893
 CMP #$BF
 BCC CC846

.CC893

 LDA L00C9
 LDX #0
 STX addr4
 STX addr5
 ASL A
 ROL addr4
 ASL A
 ROL addr4
 ASL A
 ROL addr4
 ASL A
 TAX
 LDA addr4
 ROL A
 ADC L00E0
 STA PPU_ADDR
 STA addr4+1
 TXA
 ADC pallettePhasex8
 STA PPU_ADDR
 STA addr4
 JMP CC8D0

.CC8BB

 INC addr5+1
 SEC
 LDA tempVar
 SBC #$1B
 STA tempVar
 LDA tempVar+1
 SBC #0
 STA tempVar+1
 JMP CC925

.CC8CD

 JMP CC9EB

.CC8D0

 LDX L00C9

.CC8D2

 SEC
 LDA tempVar
 SBC #$90
 STA tempVar
 LDA tempVar+1
 SBC #1
 STA tempVar+1
 BMI CC8E4
 JMP CC8F3

.CC8E4

 LDA tempVar
 ADC #$67
 STA tempVar
 LDA tempVar+1
 ADC #1
 STA tempVar+1
 JMP CCB30

.CC8F3

 LDA (addr5),Y
 STA PPU_DATA
 INY
 LDA (addr5),Y
 STA PPU_DATA
 INY
 LDA (addr5),Y
 STA PPU_DATA
 INY
 LDA (addr5),Y
 STA PPU_DATA
 INY
 LDA (addr5),Y
 STA PPU_DATA
 INY
 LDA (addr5),Y
 STA PPU_DATA
 INY
 LDA (addr5),Y
 STA PPU_DATA
 INY
 LDA (addr5),Y
 STA PPU_DATA
 INY
 BEQ CC8BB

.CC925

 LDA addr4
 CLC
 ADC #$10
 STA addr4
 LDA addr4+1
 ADC #0
 STA addr4+1
 STA PPU_ADDR
 LDA addr4
 STA PPU_ADDR
 INX
 CPX temp1
 BCS CC8CD
 LDA (addr5),Y
 STA PPU_DATA
 INY
 LDA (addr5),Y
 STA PPU_DATA
 INY
 LDA (addr5),Y
 STA PPU_DATA
 INY
 LDA (addr5),Y
 STA PPU_DATA
 INY
 LDA (addr5),Y
 STA PPU_DATA
 INY
 LDA (addr5),Y
 STA PPU_DATA
 INY
 LDA (addr5),Y
 STA PPU_DATA
 INY
 LDA (addr5),Y
 STA PPU_DATA
 INY
 BEQ CC9D8

.CC971

 LDA addr4
 ADC #$10
 STA addr4
 LDA addr4+1
 ADC #0
 STA addr4+1
 STA PPU_ADDR
 LDA addr4
 STA PPU_ADDR
 INX
 CPX temp1
 BCS CC9FB
 LDA (addr5),Y
 STA PPU_DATA
 INY
 LDA (addr5),Y
 STA PPU_DATA
 INY
 LDA (addr5),Y
 STA PPU_DATA
 INY
 LDA (addr5),Y
 STA PPU_DATA
 INY
 LDA (addr5),Y
 STA PPU_DATA
 INY
 LDA (addr5),Y
 STA PPU_DATA
 INY
 LDA (addr5),Y
 STA PPU_DATA
 INY
 LDA (addr5),Y
 STA PPU_DATA
 INY
 BEQ CCA1B

.CC9BC

 LDA addr4
 ADC #$10
 STA addr4
 LDA addr4+1
 ADC #0
 STA addr4+1
 STA PPU_ADDR
 LDA addr4
 STA PPU_ADDR
 INX
 CPX temp1
 BCS CCA08
 JMP CC8D2

.CC9D8

 INC addr5+1
 SEC
 LDA tempVar
 SBC #$1D
 STA tempVar
 LDA tempVar+1
 SBC #0
 STA tempVar+1
 CLC
 JMP CC971

.CC9EB

 CLC
 LDA tempVar
 ADC #$E0
 STA tempVar
 LDA tempVar+1
 ADC #0
 STA tempVar+1
 JMP CCA08

.CC9FB

 CLC
 LDA tempVar
 ADC #$6D
 STA tempVar
 LDA tempVar+1
 ADC #0
 STA tempVar+1

.CCA08

 STX L00C9
 NOP
 LDX otherPhase
 STY L00DB,X
 LDA addr5+1
 STA L04BE,X
 LDA L00C9
 STA L00CA,X
 JMP CCBBC

.CCA1B

 INC addr5+1
 SEC
 LDA tempVar
 SBC #$1D
 STA tempVar
 LDA tempVar+1
 SBC #0
 STA tempVar+1
 CLC
 JMP CC9BC

.CCA2E

 LDA L00C9
 LDX #0
 STX addr4
 STX addr5
 ASL A
 ROL addr4
 ASL A
 ROL addr4
 ASL A
 ROL addr4
 ASL A
 TAX
 LDA addr4
 ROL A
 ADC L00E0
 STA PPU_ADDR
 STA addr4+1
 TXA
 ADC pallettePhasex8
 STA PPU_ADDR
 STA addr4
 JMP CCA68

; ******************************************************************************
;
;       Name: subm_CA56
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.subm_CA56

 INC addr5+1
 SEC
 LDA tempVar
 SBC #$1B
 STA tempVar
 LDA tempVar+1
 SBC #0
 STA tempVar+1
 JMP CCABD

.CCA68

 LDX L00C9

.CCA6A

 SEC
 LDA tempVar
 SBC #$0A
 STA tempVar
 LDA tempVar+1
 SBC #1
 STA tempVar+1
 BMI CCA7C
 JMP CCA8B

.CCA7C

 LDA tempVar
 ADC #$E1
 STA tempVar
 LDA tempVar+1
 ADC #0
 STA tempVar+1
 JMP CCB30

.CCA8B

 LDA (addr5),Y
 STA PPU_DATA
 INY
 LDA (addr5),Y
 STA PPU_DATA
 INY
 LDA (addr5),Y
 STA PPU_DATA
 INY
 LDA (addr5),Y
 STA PPU_DATA
 INY
 LDA (addr5),Y
 STA PPU_DATA
 INY
 LDA (addr5),Y
 STA PPU_DATA
 INY
 LDA (addr5),Y
 STA PPU_DATA
 INY
 LDA (addr5),Y
 STA PPU_DATA
 INY
 BEQ subm_CA56

.CCABD

 LDA addr4
 CLC
 ADC #$10
 STA addr4
 LDA addr4+1
 ADC #0
 STA addr4+1
 STA PPU_ADDR
 LDA addr4
 STA PPU_ADDR
 LDA (addr5),Y
 STA PPU_DATA
 INY
 LDA (addr5),Y
 STA PPU_DATA
 INY
 LDA (addr5),Y
 STA PPU_DATA
 INY
 LDA (addr5),Y
 STA PPU_DATA
 INY
 LDA (addr5),Y
 STA PPU_DATA
 INY
 LDA (addr5),Y
 STA PPU_DATA
 INY
 LDA (addr5),Y
 STA PPU_DATA
 INY
 LDA (addr5),Y
 STA PPU_DATA
 INY
 BEQ CCB1D

.CCB04

 LDA addr4
 ADC #$10
 STA addr4
 LDA addr4+1
 ADC #0
 STA addr4+1
 STA PPU_ADDR
 LDA addr4
 STA PPU_ADDR
 INX
 INX
 JMP CCA6A

.CCB1D

 INC addr5+1
 SEC
 LDA tempVar
 SBC #$1D
 STA tempVar
 LDA tempVar+1
 SBC #0
 STA tempVar+1
 CLC
 JMP CCB04

.CCB30

 STX L00C9
 LDX otherPhase
 STY L00DB,X
 LDA addr5+1
 STA L04BE,X
 LDA L00C9
 STA L00CA,X
 JMP CC6F3

; ******************************************************************************
;
;       Name: subm_CB42
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.subm_CB42

 LDX otherPhase
 LDA #$20
 STA L03EF,X
 SEC
 LDA tempVar
 SBC #$E3
 STA tempVar
 LDA tempVar+1
 SBC #0
 STA tempVar+1
 BMI CCB5B
 JMP CCB6A

.CCB5B

 LDA tempVar
 ADC #$B0
 STA tempVar
 LDA tempVar+1
 ADC #0
 STA tempVar+1
 JMP CC6F3

.CCB6A

 TXA
 EOR #1
 STA otherPhase
 CMP palettePhase
 BNE CCB8E
 TAX
 LDA L03EF,X
 AND #$A0
 CMP #$80
 BEQ CCB80
 JMP CC7D2

.CCB80

 CLC
 LDA tempVar
 ADC #$97
 STA tempVar
 LDA tempVar+1
 ADC #0
 STA tempVar+1
 RTS

.CCB8E

 CLC
 LDA tempVar
 ADC #$A3
 STA tempVar
 LDA tempVar+1
 ADC #0
 STA tempVar+1
 RTS

; ******************************************************************************
;
;       Name: subm_CB9C
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.subm_CB9C

 CLC
 LDA tempVar
 ADC #$3A
 STA tempVar
 LDA tempVar+1
 ADC #0
 STA tempVar+1
 JMP CC6F3

.CCBAC

 CLC
 LDA tempVar
 ADC #$35
 STA tempVar
 LDA tempVar+1
 ADC #0
 STA tempVar+1
 JMP subm_CB42

.CCBBC

 SEC
 LDA tempVar
 SBC #$6D
 STA tempVar
 LDA tempVar+1
 SBC #0
 STA tempVar+1
 BMI CCBCE
 JMP CCBDD

.CCBCE

 LDA tempVar
 ADC #$44
 STA tempVar
 LDA tempVar+1
 ADC #0
 STA tempVar+1
 JMP CC6F3

.CCBDD

 LDX otherPhase
 LDA L03EF,X
 ASL A
 BPL subm_CB9C
 LDY L00CD,X
 AND #8
 BEQ CCBED
 LDY #$80

.CCBED

 STY temp1
 LDA tile3Phase0,X
 STA L00CF
 SEC
 SBC temp1
 BCS CCBAC
 LDY L00DD,X
 LDA L04C0,X
 STA addr5+1
 CLC
 ADC L04C6,X
 STA PPU_ADDR
 STY PPU_ADDR
 LDA #0
 STA addr5

.CCC0D

 SEC
 LDA tempVar
 SBC #$89
 STA tempVar
 LDA tempVar+1
 SBC #1
 STA tempVar+1
 BMI subm_CC1F
 JMP SendToPPU1

; ******************************************************************************
;
;       Name: subm_CC1F
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.subm_CC1F

 LDA tempVar
 ADC #$5D
 STA tempVar
 LDA tempVar+1
 ADC #1
 STA tempVar+1
 JMP CCD26

; ******************************************************************************
;
;       Name: SendToPPU1
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.SendToPPU1

 LDA (addr5),Y
 STA PPU_DATA
 INY
 LDA (addr5),Y
 STA PPU_DATA
 INY
 LDA (addr5),Y
 STA PPU_DATA
 INY
 LDA (addr5),Y
 STA PPU_DATA
 INY
 LDA (addr5),Y
 STA PPU_DATA
 INY
 LDA (addr5),Y
 STA PPU_DATA
 INY
 LDA (addr5),Y
 STA PPU_DATA
 INY
 LDA (addr5),Y
 STA PPU_DATA
 INY
 LDA (addr5),Y
 STA PPU_DATA
 INY
 LDA (addr5),Y
 STA PPU_DATA
 INY
 LDA (addr5),Y
 STA PPU_DATA
 INY
 LDA (addr5),Y
 STA PPU_DATA
 INY
 LDA (addr5),Y
 STA PPU_DATA
 INY
 LDA (addr5),Y
 STA PPU_DATA
 INY
 LDA (addr5),Y
 STA PPU_DATA
 INY
 LDA (addr5),Y
 STA PPU_DATA
 INY
 LDA (addr5),Y
 STA PPU_DATA
 INY
 LDA (addr5),Y
 STA PPU_DATA
 INY
 LDA (addr5),Y
 STA PPU_DATA
 INY
 LDA (addr5),Y
 STA PPU_DATA
 INY
 LDA (addr5),Y
 STA PPU_DATA
 INY
 LDA (addr5),Y
 STA PPU_DATA
 INY
 LDA (addr5),Y
 STA PPU_DATA
 INY
 LDA (addr5),Y
 STA PPU_DATA
 INY
 LDA (addr5),Y
 STA PPU_DATA
 INY
 LDA (addr5),Y
 STA PPU_DATA
 INY
 LDA (addr5),Y
 STA PPU_DATA
 INY
 LDA (addr5),Y
 STA PPU_DATA
 INY
 LDA (addr5),Y
 STA PPU_DATA
 INY
 LDA (addr5),Y
 STA PPU_DATA
 INY
 LDA (addr5),Y
 STA PPU_DATA
 INY
 LDA (addr5),Y
 STA PPU_DATA
 INY
 BEQ CCD09
 LDA L00CF
 ADC #3
 STA L00CF
 CMP temp1
 BCS CCCFD
 JMP CCC0D

.CCCFD

 STA tile3Phase0,X
 STY L00DD,X
 LDA addr5+1
 STA L04C0,X
 JMP subm_CB42

.CCD09

 INC addr5+1
 SEC
 LDA tempVar
 SBC #$1A
 STA tempVar
 LDA tempVar+1
 SBC #0
 STA tempVar+1
 LDA L00CF
 CLC
 ADC #4
 STA L00CF
 CMP temp1
 BCS CCCFD
 JMP CCC0D

.CCD26

 LDA L00CF
 STA tile3Phase0,X
 STY L00DD,X
 LDA addr5+1
 STA L04C0,X
 JMP CC6F3

; ******************************************************************************
;
;       Name: CopyNametable0To1
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.CopyNametable0To1

 LDY #0
 LDX #$10

.CCD38

 LDA nameBuffer0,Y
 STA nameBuffer1,Y
 LDA nameBuffer0+256,Y
 STA nameBuffer1+256,Y
 LDA nameBuffer0+512,Y
 STA nameBuffer1+512,Y
 LDA nameBuffer0+768,Y
 STA nameBuffer1+768,Y

 JSR SetupPPUForIconBar ; If the PPU has started drawing the icon bar, configure
                        ; the PPU to use nametable 0 and pattern table 0

 DEX
 BNE CCD58
 LDX #$10

.CCD58

 DEY
 BNE CCD38
 LDA tileNumber
 STA tile0Phase0
 STA tile0Phase1
 RTS

; ******************************************************************************
;
;       Name: subm_CD62
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.subm_CD62

 LDY #1
 LDA #3

.loop_CCD66

 STA nameBuffer0,Y
 INY
 CPY #$20
 BNE loop_CCD66
 RTS

; ******************************************************************************
;
;       Name: DrawBoxEdges
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.DrawBoxEdges

 LDX drawingPhase
 BNE CCDF2
 LDA boxEdge1
 STA nameBuffer0+1
 STA nameBuffer0+33
 STA nameBuffer0+65
 STA nameBuffer0+97
 STA nameBuffer0+129
 STA nameBuffer0+161
 STA nameBuffer0+193
 STA nameBuffer0+225
 STA nameBuffer0+257
 STA nameBuffer0+289
 STA nameBuffer0+321
 STA nameBuffer0+353
 STA nameBuffer0+385
 STA nameBuffer0+417
 STA nameBuffer0+449
 STA nameBuffer0+481
 STA nameBuffer0+513
 STA nameBuffer0+545
 STA nameBuffer0+577
 STA nameBuffer0+609
 LDA boxEdge2
 STA nameBuffer0
 STA nameBuffer0+32
 STA nameBuffer0+64
 STA nameBuffer0+96
 STA nameBuffer0+128
 STA nameBuffer0+160
 STA nameBuffer0+192
 STA nameBuffer0+224
 STA nameBuffer0+256
 STA nameBuffer0+288
 STA nameBuffer0+320
 STA nameBuffer0+352
 STA nameBuffer0+384
 STA nameBuffer0+416
 STA nameBuffer0+448
 STA nameBuffer0+480
 STA nameBuffer0+512
 STA nameBuffer0+544
 STA nameBuffer0+576
 STA nameBuffer0+608
 RTS

.CCDF2

 LDA boxEdge1
 STA nameBuffer1+1
 STA nameBuffer1+33
 STA nameBuffer1+65
 STA nameBuffer1+97
 STA nameBuffer1+129
 STA nameBuffer1+161
 STA nameBuffer1+193
 STA nameBuffer1+225
 STA nameBuffer1+257
 STA nameBuffer1+289
 STA nameBuffer1+321
 STA nameBuffer1+353
 STA nameBuffer1+385
 STA nameBuffer1+417
 STA nameBuffer1+449
 STA nameBuffer1+481
 STA nameBuffer1+513
 STA nameBuffer1+545
 STA nameBuffer1+577
 STA nameBuffer1+609
 LDA boxEdge2
 STA nameBuffer1
 STA nameBuffer1+32
 STA nameBuffer1+64
 STA nameBuffer1+96
 STA nameBuffer1+128
 STA nameBuffer1+160
 STA nameBuffer1+192
 STA nameBuffer1+224
 STA nameBuffer1+256
 STA nameBuffer1+288
 STA nameBuffer1+320
 STA nameBuffer1+352
 STA nameBuffer1+384
 STA nameBuffer1+416
 STA nameBuffer1+448
 STA nameBuffer1+480
 STA nameBuffer1+512
 STA nameBuffer1+544
 STA nameBuffer1+576
 STA nameBuffer1+608

 SETUP_PPU_FOR_ICON_BAR ; If the PPU has started drawing the icon bar, configure
                        ; the PPU to use nametable 0 and pattern table 0

 RTS

; ******************************************************************************
;
;       Name: UNIV
;       Type: Variable
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.UNIV

 EQUB 0                                       ; CE7E: 00          .
 EQUB   6, $2A,   6, $54,   6, $7E,   6, $A8  ; CE7F: 06 2A 06... .*.
 EQUB   6, $D2,   6, $FC,   6, $26,   7, $50  ; CE87: 06 D2 06... ...
 EQUB   7                                     ; CE8F: 07          .

; ******************************************************************************
;
;       Name: GINF
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.GINF

 TXA
 ASL A
 TAY
 LDA UNIV,Y
 STA XX19
 LDA UNIV+1,Y
 STA INF+1
 RTS

; ******************************************************************************
;
;       Name: subm_CE9E
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.subm_CE9E

 LDX #4
 LDY #$EC
 JMP CCEC0

; ******************************************************************************
;
;       Name: subm_CEA5
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.subm_CEA5

 LDX #0

.loop_CCEA7

 LDA FRIN,X
 BEQ CCEBC
 BMI CCEB9
 JSR GINF
 LDY #$1F
 LDA (XX19),Y
 AND #$EF
 STA (XX19),Y

.CCEB9

 INX
 BNE loop_CCEA7

.CCEBC

 LDY #$2C
 LDX #$1B

.CCEC0

 LDA #$F0

.loop_CCEC2

 STA ySprite0,Y
 INY
 INY
 INY
 INY
 DEX
 BNE loop_CCEC2
 RTS

 EQUB $0C, $20, $1F                           ; CECD: 0C 20 1F    . .

; ******************************************************************************
;
;       Name: nameBufferAddr
;       Type: Variable
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.nameBufferAddr

 EQUB $70, $74                                ; CED0: 70 74       pt

; ******************************************************************************
;
;       Name: pattBufferAddr
;       Type: Variable
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.pattBufferAddr

 EQUB $60, $68                                ; CED2: 60 68       `h

; ******************************************************************************
;
;       Name: IRQ
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.IRQ

 RTI

; ******************************************************************************
;
;       Name: NMI
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.NMI

 JSR SetPalette
 LDA showUserInterface
 STA setupPPUForIconBar

IF _NTSC

 LDA #$1A
 STA tempVar+1
 LDA #$8D
 STA tempVar

ELIF _PAL

 LDA #$1D
 STA tempVar+1
 LDA #$09
 STA tempVar

ENDIF

 JSR subm_D00B
 JSR ReadControllers
 LDA L03EE
 BPL CCEF2
 JSR subm_E802

.CCEF2

 JSR subm_E91D
 JSR subm_EAB0
 JSR subm_CF18
 LDA runningSetBank
 BNE CCF0C
 JSR PlayMusic_b6
 LDA nmiStoreA
 LDX nmiStoreX
 LDY nmiStoreY
 RTI

.CCF0C

 INC runningSetBank
 LDA nmiStoreA
 LDX nmiStoreX
 LDY nmiStoreY
 RTI

; ******************************************************************************
;
;       Name: subm_CF18
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.subm_CF18

 DEC nmiTimer
 BNE CCF2D
 LDA #$32
 STA nmiTimer
 LDA nmiTimerLo
 CLC
 ADC #1
 STA nmiTimerLo
 LDA nmiTimerHi
 ADC #0
 STA nmiTimerHi

.CCF2D

 RTS

; ******************************************************************************
;
;       Name: SetPalette
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.SetPalette

 STA nmiStoreA
 STX nmiStoreX
 STY nmiStoreY
 LDA PPU_STATUS
 INC frameCounter
 LDA #0
 STA OAM_ADDR
 LDA #2
 STA OAM_DMA
 LDA #0
 STA PPU_MASK

; ******************************************************************************
;
;       Name: subm_CF4C
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.subm_CF4C

 LDA QQ11a
 BNE CCF96
 LDY visibleColour
 LDA palettePhase
 BNE CCF76
 LDA #$3F
 STA PPU_ADDR
 LDA #1
 STA PPU_ADDR
 LDA hiddenColour
 STA PPU_DATA
 STY PPU_DATA
 STY PPU_DATA
 LDA #0
 STA PPU_ADDR
 LDA #0
 STA PPU_ADDR
 RTS

.CCF76

 LDA #$3F
 STA PPU_ADDR
 LDA #1
 STA PPU_ADDR
 LDA hiddenColour
 STY PPU_DATA
 STA PPU_DATA
 STY PPU_DATA
 LDA #0
 STA PPU_ADDR
 LDA #0
 STA PPU_ADDR
 RTS

.CCF96

 CMP #$98
 BEQ CCFBE
 LDA #$3F
 STA PPU_ADDR
 LDA #$15
 STA PPU_ADDR
 LDA visibleColour
 STA PPU_DATA
 LDA paletteColour1
 STA PPU_DATA
 LDA paletteColour2
 STA PPU_DATA
 LDA #0
 STA PPU_ADDR
 LDA #0
 STA PPU_ADDR
 RTS

.CCFBE

 LDA #$3F
 STA PPU_ADDR
 LDA #1
 STA PPU_ADDR
 LDA visibleColour
 STA PPU_DATA
 LDA paletteColour1
 STA PPU_DATA
 LDA paletteColour2
 STA PPU_DATA
 LDA #0
 STA PPU_ADDR
 LDA #0
 STA PPU_ADDR
 RTS

.CCFE2

 LDA #$3F
 STA PPU_ADDR
 LDA #1
 STA PPU_ADDR
 LDX #1

.loop_CCFEE

 LDA XX3,X
 AND #$3F
 STA PPU_DATA
 INX
 CPX #$20
 BNE loop_CCFEE
 SEC
 LDA tempVar
 SBC #$2F
 STA tempVar
 LDA tempVar+1
 SBC #2
 STA tempVar+1
 JMP CD00F

; ******************************************************************************
;
;       Name: subm_D00B
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.subm_D00B

 LDA L00DA
 BNE CCFE2

.CD00F

 JSR subm_C6F4
 JSR ResetNametable1
 LDA tempVar
 CLC
 ADC #$64
 STA tempVar
 LDA tempVar+1
 ADC #0
 STA tempVar+1
 BMI CD027
 JSR subm_D07C

.CD027

 LDA #$1E
 STA PPU_MASK
 RTS

; ******************************************************************************
;
;       Name: ResetNametable1
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.ResetNametable1

 LDX #$90
 LDA palettePhase
 BNE CD035
 LDX #$91

.CD035

 STX PPU_CTRL
 STX ppuCtrlCopy
 LDA #$20
 LDX palettePhase
 BNE CD042
 LDA #$24

.CD042

 STA PPU_ADDR
 LDA #0
 STA PPU_ADDR
 LDA PPU_DATA
 LDA PPU_DATA
 LDA PPU_DATA
 LDA PPU_DATA
 LDA PPU_DATA
 LDA PPU_DATA
 LDA PPU_DATA
 LDA PPU_DATA
 LDA #8
 STA PPU_SCROLL
 LDA #0
 STA PPU_SCROLL
 RTS

; ******************************************************************************
;
;       Name: SetPPUTablesTo0
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.SetPPUTablesTo0

 LDA #0
 STA setupPPUForIconBar
 LDA ppuCtrlCopy
 AND #$EE
 STA PPU_CTRL
 STA ppuCtrlCopy
 CLC
 RTS

; ******************************************************************************
;
;       Name: subm_D07C
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.subm_D07C

 LDA tempVar+1
 BEQ CD0D0
 SEC
 LDA tempVar
 SBC #$6B
 STA tempVar
 LDA tempVar+1
 SBC #1
 STA tempVar+1
 BMI CD092
 JMP CD0A1

.CD092

 LDA tempVar
 ADC #$3E
 STA tempVar
 LDA tempVar+1
 ADC #1
 STA tempVar+1
 JMP CD0D0

.CD0A1

 LDA L00EF
 PHA
 LDA L00F0
 PHA
 LDA addr6
 PHA
 LDA addr6+1
 PHA
 LDX #0
 JSR subm_D2C4
 LDX #1
 JSR subm_D2C4
 PLA
 STA addr6+1
 PLA
 STA addr6
 PLA
 STA L00F0
 PLA
 STA L00EF
 CLC
 LDA tempVar
 ADC #$EE
 STA tempVar
 LDA tempVar+1
 ADC #0
 STA tempVar+1

.CD0D0

 SEC
 LDA tempVar
 SBC #$20
 STA tempVar
 LDA tempVar+1
 SBC #0
 STA tempVar+1
 BMI CD0E2
 JMP CD0F1

.CD0E2

 LDA tempVar
 ADC #$F7
 STA tempVar
 LDA tempVar+1
 ADC #$FF
 STA tempVar+1
 JMP CD0F7

.CD0F1

 NOP
 NOP
 NOP
 JMP CD0D0

.CD0F7

 RTS

; ******************************************************************************
;
;       Name: ReadControllers
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.ReadControllers

 LDA #1
 STA JOY1
 LSR A
 STA JOY1
 TAX
 JSR subm_D10A
 LDX scanController2
 BEQ CD15A

; ******************************************************************************
;
;       Name: subm_D10A
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.subm_D10A

 LDA JOY1,X
 AND #3
 CMP #1
 ROR controller1A,X
 LDA JOY1,X
 AND #3
 CMP #1
 ROR controller1B,X
 LDA JOY1,X
 AND #3
 CMP #1
 ROR controller1Select,X
 LDA JOY1,X
 AND #3
 CMP #1
 ROR controller1Start,X
 LDA JOY1,X
 AND #3
 CMP #1
 ROR controller1Up,X
 LDA JOY1,X
 AND #3
 CMP #1
 ROR controller1Down,X
 LDA JOY1,X
 AND #3
 CMP #1
 ROR controller1Left,X
 LDA JOY1,X
 AND #3
 CMP #1
 ROR controller1Right,X

.CD15A

 RTS

 LDA frameCounter

.loop_CD15E

 CMP frameCounter
 BEQ loop_CD15E
 RTS

; ******************************************************************************
;
;       Name: KeepPPUTablesAt0x2
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.KeepPPUTablesAt0x2

 JSR KeepPPUTablesAt0

; ******************************************************************************
;
;       Name: KeepPPUTablesAt0
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.KeepPPUTablesAt0

 PHA
 LDX frameCounter

.loop_CD16B

 SETUP_PPU_FOR_ICON_BAR ; If the PPU has started drawing the icon bar, configure
                        ; the PPU to use nametable 0 and pattern table 0

 CPX frameCounter
 BEQ loop_CD16B
 PLA
 RTS

; ******************************************************************************
;
;       Name: subm_D17F
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.subm_D17F

 LDA setupPPUForIconBar
 BEQ subm_D17F

.loop_CD183

 SETUP_PPU_FOR_ICON_BAR ; If the PPU has started drawing the icon bar, configure
                        ; the PPU to use nametable 0 and pattern table 0

 LDA setupPPUForIconBar
 BNE loop_CD183
 RTS

 LDX #0
 JSR CD19C
 LDX #1

.CD19C

 SETUP_PPU_FOR_ICON_BAR ; If the PPU has started drawing the icon bar, configure
                        ; the PPU to use nametable 0 and pattern table 0

 LDA L03EF,X
 BEQ CD1C7
 AND #$20
 BNE CD1B8
 JSR CD1C8
 JMP CD19C

.CD1B8

 JSR CD1C8
 LDA #0
 STA L03EF,X
 LDA L00D2
 STA tileNumber
 JMP subm_CD62

.CD1C7

 RTS

.CD1C8

 LDY frameCounter
 LDA tile3Phase0,X
 STA SC
 LDA tile2Phase0,X
 CPY frameCounter
 BNE CD1C8
 LDY SC
 CPY L00D8
 BCC CD1DE
 LDY L00D8

.CD1DE

 STY SC
 CMP SC
 BCS CD239
 STY tile2Phase0,X
 LDY #0
 STY addr6+1
 ASL A
 ROL addr6+1
 ASL A
 ROL addr6+1
 ASL A
 STA addr6
 LDA addr6+1
 ROL A
 ADC nameBufferAddr,X
 STA addr6+1
 LDA #0
 ASL SC
 ROL A
 ASL SC
 ROL A
 ASL SC
 ROL A
 ADC nameBufferAddr,X
 STA SC+1

.CD20B

 SETUP_PPU_FOR_ICON_BAR ; If the PPU has started drawing the icon bar, configure
                        ; the PPU to use nametable 0 and pattern table 0

 LDA SC
 SEC
 SBC addr6
 STA L00EF
 LDA SC+1
 SBC addr6+1
 BCC CD239
 STA L00F0
 ORA L00EF
 BEQ CD239
 LDA #3
 STA tempVar+1
 LDA #$16
 STA tempVar
 JSR FillMemory
 JMP CD20B

.CD239

 LDY frameCounter
 LDA L00CA,X
 STA SC
 LDA tile1Phase0,X
 CPY frameCounter
 BNE CD239
 LDY SC
 CMP SC
 BCS CD2A2
 STY tile1Phase0,X
 LDY #0
 STY addr6+1
 ASL A
 ROL addr6+1
 ASL A
 ROL addr6+1
 ASL A
 STA addr6
 LDA addr6+1
 ROL A
 ADC pattBufferAddr,X
 STA addr6+1
 LDA #0
 ASL SC
 ROL A
 ASL SC
 ROL A
 ASL SC
 ROL A
 ADC pattBufferAddr,X
 STA SC+1

.CD274

 SETUP_PPU_FOR_ICON_BAR ; If the PPU has started drawing the icon bar, configure
                        ; the PPU to use nametable 0 and pattern table 0

 LDA SC
 SEC
 SBC addr6
 STA L00EF
 LDA SC+1
 SBC addr6+1
 BCC CD239
 STA L00F0
 ORA L00EF
 BEQ CD2A2
 LDA #3
 STA tempVar+1
 LDA #$16
 STA tempVar
 JSR FillMemory
 JMP CD274

.CD2A2

 RTS

; ******************************************************************************
;
;       Name: LD2A3
;       Type: Variable
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.LD2A3

 EQUB $30                                     ; D2A3: 30          0

; ******************************************************************************
;
;       Name: subm_D2C4
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.CD2A4

 NOP
 NOP

.CD2A6

 SEC
 LDA tempVar
 SBC #$27
 STA tempVar
 LDA tempVar+1
 SBC #0
 STA tempVar+1

.CD2B3

 RTS

.CD2B4

 CLC
 LDA tempVar
 ADC #$7E
 STA tempVar
 LDA tempVar+1
 ADC #0
 STA tempVar+1
 JMP CD37E

.subm_D2C4

 LDA tempVar+1
 BEQ CD2B3
 LDA L03EF,X
 BIT LD2A3
 BEQ CD2A4
 AND #8
 BEQ CD2A6
 SEC
 LDA tempVar
 SBC #$D5
 STA tempVar
 LDA tempVar+1
 SBC #0
 STA tempVar+1
 BMI CD2E6
 JMP CD2F5

.CD2E6

 LDA tempVar
 ADC #$99
 STA tempVar
 LDA tempVar+1
 ADC #0
 STA tempVar+1
 JMP CD2B3

.CD2F5

 LDA tile2Phase0,X
 LDY tile3Phase0,X
 CPY L00D8
 BCC CD2FF
 LDY L00D8

.CD2FF

 STY L00EF
 CMP L00EF
 BCS CD2B4
 LDY #0
 STY addr6+1
 ASL A
 ROL addr6+1
 ASL A
 ROL addr6+1
 ASL A
 STA addr6
 LDA addr6+1
 ROL A
 ADC nameBufferAddr,X
 STA addr6+1
 LDA #0
 ASL L00EF
 ROL A
 ASL L00EF
 ROL A
 ASL L00EF
 ROL A
 ADC nameBufferAddr,X
 STA L00F0
 LDA L00EF
 SEC
 SBC addr6
 STA L00EF
 LDA L00F0
 SBC addr6+1
 BCC CD359
 STA L00F0
 ORA L00EF
 BEQ CD35D
 JSR FillMemory
 LDA addr6+1
 SEC
 SBC nameBufferAddr,X
 LSR A
 ROR addr6
 LSR A
 ROR addr6
 LSR A
 LDA addr6
 ROR A
 CMP tile2Phase0,X
 BCC CD37B
 STA tile2Phase0,X
 JMP CD37E

.CD359

 NOP
 NOP
 NOP
 NOP

.CD35D

 CLC
 LDA tempVar
 ADC #$1C
 STA tempVar
 LDA tempVar+1
 ADC #0
 STA tempVar+1
 JMP CD37E

.CD36D

 CLC
 LDA tempVar
 ADC #$7E
 STA tempVar
 LDA tempVar+1
 ADC #0
 STA tempVar+1

.CD37A

 RTS

.CD37B

 NOP
 NOP
 NOP

.CD37E

 SEC
 LDA tempVar
 SBC #$BB
 STA tempVar
 LDA tempVar+1
 SBC #0
 STA tempVar+1
 BMI CD390
 JMP CD39F

.CD390

 LDA tempVar
 ADC #$92
 STA tempVar
 LDA tempVar+1
 ADC #0
 STA tempVar+1
 JMP CD37A

.CD39F

 LDA tile1Phase0,X
 LDY L00CA,X
 STY L00EF
 CMP L00EF
 BCS CD36D
 NOP
 LDY #0
 STY addr6+1
 ASL A
 ROL addr6+1
 ASL A
 ROL addr6+1
 ASL A
 STA addr6
 LDA addr6+1
 ROL A
 ADC pattBufferAddr,X
 STA addr6+1
 LDA #0
 ASL L00EF
 ROL A
 ASL L00EF
 ROL A
 ASL L00EF
 ROL A
 ADC pattBufferAddr,X
 STA L00F0
 LDA L00EF
 SEC
 SBC addr6
 STA L00EF
 LDA L00F0
 SBC addr6+1
 BCC CD3FC
 STA L00F0
 ORA L00EF
 BEQ CD401
 JSR FillMemory
 LDA addr6+1
 SEC
 SBC pattBufferAddr,X
 LSR A
 ROR addr6
 LSR A
 ROR addr6
 LSR A
 LDA addr6
 ROR A
 CMP tile1Phase0,X
 BCC CD3FC
 STA tile1Phase0,X
 RTS

.CD3FC

 NOP
 NOP
 NOP
 NOP
 RTS

.CD401

 CLC
 LDA tempVar
 ADC #$23
 STA tempVar
 LDA tempVar+1
 ADC #0
 STA tempVar+1
 RTS

; ******************************************************************************
;
;       Name: subm_D40F
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.subm_D40F

 STA (addr6),Y
 INY
 STA (addr6),Y
 INY
 STA (addr6),Y
 INY
 STA (addr6),Y
 INY
 STA (addr6),Y
 INY
 STA (addr6),Y
 INY
 STA (addr6),Y
 INY
 STA (addr6),Y
 INY
 STA (addr6),Y
 INY
 STA (addr6),Y
 INY
 STA (addr6),Y
 INY
 STA (addr6),Y
 INY
 STA (addr6),Y
 INY
 STA (addr6),Y
 INY
 STA (addr6),Y
 INY
 STA (addr6),Y
 INY
 STA (addr6),Y
 INY
 STA (addr6),Y
 INY
 STA (addr6),Y
 INY
 STA (addr6),Y
 INY
 STA (addr6),Y
 INY
 STA (addr6),Y
 INY
 STA (addr6),Y
 INY
 STA (addr6),Y
 INY
 STA (addr6),Y
 INY
 STA (addr6),Y
 INY
 STA (addr6),Y
 INY
 STA (addr6),Y
 INY
 STA (addr6),Y
 INY
 STA (addr6),Y
 INY
 STA (addr6),Y
 INY
 STA (addr6),Y
 INY
 STA (addr6),Y
 INY
 STA (addr6),Y
 INY
 STA (addr6),Y
 INY
 STA (addr6),Y
 INY
 STA (addr6),Y
 INY
 STA (addr6),Y
 INY
 STA (addr6),Y
 INY
 STA (addr6),Y
 INY
 STA (addr6),Y
 INY
 STA (addr6),Y
 INY
 STA (addr6),Y
 INY
 STA (addr6),Y
 INY
 STA (addr6),Y
 INY
 STA (addr6),Y
 INY
 STA (addr6),Y
 INY
 STA (addr6),Y
 INY
 STA (addr6),Y
 INY
 STA (addr6),Y
 INY
 STA (addr6),Y
 INY
 STA (addr6),Y
 INY
 STA (addr6),Y
 INY
 STA (addr6),Y
 INY
 STA (addr6),Y
 INY
 STA (addr6),Y
 INY
 STA (addr6),Y
 INY
 STA (addr6),Y
 INY
 STA (addr6),Y
 INY
 STA (addr6),Y
 INY
 STA (addr6),Y
 INY
 STA (addr6),Y
 INY
 STA (addr6),Y
 INY
 STA (addr6),Y
 INY
 STA (addr6),Y
 INY
 STA (addr6),Y
 INY
 STA (addr6),Y
 INY
 STA (addr6),Y
 INY
 STA (addr6),Y
 INY
 STA (addr6),Y
 INY
 STA (addr6),Y
 INY
 STA (addr6),Y
 INY
 STA (addr6),Y
 INY
 STA (addr6),Y
 INY
 STA (addr6),Y
 INY
 STA (addr6),Y
 INY
 STA (addr6),Y
 INY
 STA (addr6),Y
 INY
 STA (addr6),Y
 INY
 STA (addr6),Y
 INY
 STA (addr6),Y
 INY
 STA (addr6),Y
 INY
 STA (addr6),Y
 INY
 STA (addr6),Y
 INY
 STA (addr6),Y
 INY
 STA (addr6),Y
 INY
 STA (addr6),Y
 INY
 STA (addr6),Y
 INY
 STA (addr6),Y
 INY
 STA (addr6),Y
 INY
 STA (addr6),Y
 INY
 STA (addr6),Y
 INY
 STA (addr6),Y
 INY
 STA (addr6),Y
 INY
 STA (addr6),Y
 INY
 STA (addr6),Y
 INY
 STA (addr6),Y
 INY
 STA (addr6),Y
 INY
 STA (addr6),Y
 INY
 STA (addr6),Y
 INY
 STA (addr6),Y
 INY
 STA (addr6),Y
 INY
 STA (addr6),Y
 INY
 STA (addr6),Y
 INY
 STA (addr6),Y
 INY
 STA (addr6),Y
 INY
 STA (addr6),Y
 INY
 STA (addr6),Y
 INY
 STA (addr6),Y
 INY
 STA (addr6),Y
 INY
 STA (addr6),Y
 INY
 STA (addr6),Y
 INY
 STA (addr6),Y
 INY
 STA (addr6),Y
 INY
 STA (addr6),Y
 INY
 STA (addr6),Y
 INY
 STA (addr6),Y
 INY
 STA (addr6),Y
 INY
 STA (addr6),Y
 INY
 STA (addr6),Y
 INY
 STA (addr6),Y
 INY
 STA (addr6),Y
 INY
 STA (addr6),Y
 INY
 STA (addr6),Y
 INY
 STA (addr6),Y
 INY
 STA (addr6),Y
 INY
 STA (addr6),Y
 INY
 STA (addr6),Y
 INY
 STA (addr6),Y
 INY
 STA (addr6),Y
 INY
 STA (addr6),Y
 INY
 STA (addr6),Y
 INY
 STA (addr6),Y
 INY
 STA (addr6),Y
 INY
 STA (addr6),Y
 INY
 STA (addr6),Y
 INY
 STA (addr6),Y
 INY
 STA (addr6),Y
 INY
 STA (addr6),Y
 INY
 STA (addr6),Y
 INY
 STA (addr6),Y
 INY
 STA (addr6),Y
 INY
 STA (addr6),Y
 INY
 STA (addr6),Y
 INY
 STA (addr6),Y
 INY
 STA (addr6),Y
 INY
 STA (addr6),Y
 INY
 STA (addr6),Y
 INY
 STA (addr6),Y
 INY
 STA (addr6),Y
 INY
 STA (addr6),Y
 INY
 STA (addr6),Y
 INY
 STA (addr6),Y
 INY
 STA (addr6),Y
 INY
 STA (addr6),Y
 INY
 STA (addr6),Y
 INY
 STA (addr6),Y
 INY
 STA (addr6),Y
 INY
 STA (addr6),Y
 INY
 STA (addr6),Y
 INY
 STA (addr6),Y
 INY
 STA (addr6),Y
 INY
 STA (addr6),Y
 INY
 STA (addr6),Y
 INY
 STA (addr6),Y
 INY
 STA (addr6),Y
 INY
 STA (addr6),Y
 INY
 STA (addr6),Y
 INY
 STA (addr6),Y
 INY
 STA (addr6),Y
 INY
 STA (addr6),Y
 INY
 STA (addr6),Y
 INY
 STA (addr6),Y
 INY
 STA (addr6),Y
 INY
 STA (addr6),Y
 INY
 STA (addr6),Y
 INY
 STA (addr6),Y
 INY
 STA (addr6),Y
 INY
 STA (addr6),Y
 INY
 STA (addr6),Y
 INY
 STA (addr6),Y
 INY
 STA (addr6),Y
 INY
 STA (addr6),Y
 INY
 STA (addr6),Y
 INY
 STA (addr6),Y
 INY
 STA (addr6),Y
 INY
 STA (addr6),Y
 INY
 STA (addr6),Y
 INY
 STA (addr6),Y
 INY
 STA (addr6),Y
 INY
 STA (addr6),Y
 INY
 STA (addr6),Y
 INY
 STA (addr6),Y
 INY
 STA (addr6),Y
 INY
 STA (addr6),Y
 INY
 STA (addr6),Y
 INY
 STA (addr6),Y
 INY
 STA (addr6),Y
 INY
 STA (addr6),Y
 INY
 STA (addr6),Y
 INY
 STA (addr6),Y
 INY
 STA (addr6),Y
 INY
 STA (addr6),Y
 INY
 STA (addr6),Y
 INY
 STA (addr6),Y
 INY
 STA (addr6),Y
 INY
 STA (addr6),Y
 INY
 STA (addr6),Y
 INY
 STA (addr6),Y
 INY
 STA (addr6),Y
 INY
 STA (addr6),Y
 INY
 STA (addr6),Y
 INY
 STA (addr6),Y
 INY
 STA (addr6),Y
 INY
 STA (addr6),Y
 INY
 STA (addr6),Y
 INY
 STA (addr6),Y
 INY
 STA (addr6),Y
 INY
 STA (addr6),Y
 INY
 STA (addr6),Y
 INY
 STA (addr6),Y
 INY
 STA (addr6),Y
 INY
 STA (addr6),Y
 INY
 STA (addr6),Y
 INY

; ******************************************************************************
;
;       Name: subm_D6AF
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.subm_D6AF

 STA (addr6),Y
 INY
 STA (addr6),Y
 INY
 STA (addr6),Y
 INY
 STA (addr6),Y
 INY
 STA (addr6),Y
 INY
 STA (addr6),Y
 INY
 STA (addr6),Y
 INY
 STA (addr6),Y
 INY
 STA (addr6),Y
 INY
 STA (addr6),Y
 INY
 STA (addr6),Y
 INY
 STA (addr6),Y
 INY
 STA (addr6),Y
 INY
 STA (addr6),Y
 INY
 STA (addr6),Y
 INY
 STA (addr6),Y
 INY
 STA (addr6),Y
 INY
 STA (addr6),Y
 INY
 STA (addr6),Y
 INY
 STA (addr6),Y
 INY
 STA (addr6),Y
 INY
 STA (addr6),Y
 INY
 STA (addr6),Y
 INY
 STA (addr6),Y
 INY
 STA (addr6),Y
 INY
 STA (addr6),Y
 INY
 STA (addr6),Y
 INY
 STA (addr6),Y
 INY
 STA (addr6),Y
 INY
 STA (addr6),Y
 INY
 STA (addr6),Y
 INY
 STA (addr6),Y
 INY
 RTS

; ******************************************************************************
;
;       Name: FillMemory
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.FillMemory

 LDA L00F0
 BEQ CD789
 SEC
 LDA tempVar
 SBC #$39
 STA tempVar
 LDA tempVar+1
 SBC #8
 STA tempVar+1
 BMI CD726
 JMP CD735

.CD726

 LDA tempVar
 ADC #$0B
 STA tempVar
 LDA tempVar+1
 ADC #8
 STA tempVar+1
 JMP CD743

.CD735

 LDA #0
 LDY #0
 JSR subm_D40F
 DEC L00F0
 INC addr6+1
 JMP FillMemory

.CD743

 SEC
 LDA tempVar
 SBC #$3E
 STA tempVar
 LDA tempVar+1
 SBC #1
 STA tempVar+1
 BMI CD755
 JMP CD764

.CD755

 LDA tempVar
 ADC #$15
 STA tempVar
 LDA tempVar+1
 ADC #1
 STA tempVar+1
 JMP CD788

.CD764

 LDA #0
 LDY #0
 JSR subm_D6AF
 LDA addr6
 CLC
 ADC #$20
 STA addr6
 LDA addr6+1
 ADC #0
 STA addr6+1
 JMP CD743

.CD77B

 CLC
 LDA tempVar
 ADC #$84
 STA tempVar
 LDA tempVar+1
 ADC #0
 STA tempVar+1

.CD788

 RTS

.CD789

 SEC
 LDA tempVar
 SBC #$BA
 STA tempVar
 LDA tempVar+1
 SBC #0
 STA tempVar+1
 BMI CD79B
 JMP CD7AA

.CD79B

 LDA tempVar
 ADC #$8A
 STA tempVar
 LDA tempVar+1
 ADC #0
 STA tempVar+1
 JMP CD788

.CD7AA

 LDA L00EF
 BEQ CD77B
 LSR A
 LSR A
 LSR A
 LSR A
 CMP tempVar+1
 BCS CD809
 LDA #0
 STA L00F0
 LDA L00EF
 ASL A
 ROL L00F0
 ASL A
 ROL L00F0
 ASL A
 ROL L00F0
 EOR #$FF
 SEC
 ADC tempVar
 STA tempVar
 LDA L00F0
 EOR #$FF
 ADC tempVar+1
 STA tempVar+1
 LDY #0
 STY L00F0
 LDA L00EF
 PHA
 ASL A
 ROL L00F0
 ADC L00EF
 STA L00EF
 LDA L00F0
 ADC #0
 STA L00F0
 LDA #$10
 SBC L00EF
 STA L00EF
 LDA #$D7
 SBC L00F0
 STA L00F0
 LDA #0
 JSR CD806
 PLA
 CLC
 ADC addr6
 STA addr6
 LDA addr6+1
 ADC #0
 STA addr6+1
 RTS

.CD806

 JMP (L00EF)

.CD809

 CLC
 LDA tempVar
 ADC #$76
 STA tempVar
 LDA tempVar+1
 ADC #0
 STA tempVar+1

.CD816

 SEC
 LDA tempVar
 SBC #$41
 STA tempVar
 LDA tempVar+1
 SBC #1
 STA tempVar+1
 BMI CD828
 JMP CD837

.CD828

 LDA tempVar
 ADC #$18
 STA tempVar
 LDA tempVar+1
 ADC #1
 STA tempVar+1
 JMP CD855

.CD837

 LDA L00EF
 SEC
 SBC #$20
 BCC CD856
 STA L00EF
 LDA #0
 LDY #0
 JSR subm_D6AF
 LDA addr6
 CLC
 ADC #$20
 STA addr6
 BCC CD816
 INC addr6+1
 JMP CD816

.CD855

 RTS

.CD856

 CLC
 LDA tempVar
 ADC #$0D
 STA tempVar
 LDA tempVar+1
 ADC #1
 STA tempVar+1

.CD863

 SEC
 LDA tempVar
 SBC #$77
 STA tempVar
 LDA tempVar+1
 SBC #0
 STA tempVar+1
 BMI CD875
 JMP CD884

.CD875

 LDA tempVar
 ADC #$4E
 STA tempVar
 LDA tempVar+1
 ADC #0
 STA tempVar+1
 JMP CD855

.CD884

 LDA L00EF
 SEC
 SBC #8
 BCC CD8B7
 STA L00EF
 LDA #0
 LDY #0
 STA (addr6),Y
 INY
 STA (addr6),Y
 INY
 STA (addr6),Y
 INY
 STA (addr6),Y
 INY
 STA (addr6),Y
 INY
 STA (addr6),Y
 INY
 STA (addr6),Y
 INY
 STA (addr6),Y
 INY
 LDA addr6
 CLC
 ADC #8
 STA addr6
 BCC CD8B4
 INC addr6+1

.CD8B4

 JMP CD863

.CD8B7

 CLC
 LDA tempVar
 ADC #$42
 STA tempVar
 LDA tempVar+1
 ADC #0
 STA tempVar+1
 RTS

; ******************************************************************************
;
;       Name: subm_D8C5
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.subm_D8C5

 SETUP_PPU_FOR_ICON_BAR ; If the PPU has started drawing the icon bar, configure
                        ; the PPU to use nametable 0 and pattern table 0

 LDA L03EF
 AND #$40
 BNE subm_D8C5
 LDA L03F0
 AND #$40
 BNE subm_D8C5
 RTS

; ******************************************************************************
;
;       Name: ChangeDrawingPhase
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.ChangeDrawingPhase

 LDA drawingPhase
 EOR #1
 TAX
 JSR subm_D8EC
 JMP CD19C

; ******************************************************************************
;
;       Name: subm_D8EC
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.subm_D8EC

 STX drawingPhase
 LDA tile0Phase0,X
 STA tileNumber
 LDA nameBufferAddr,X
 STA nameBufferHi
 LDA #0
 STA debugPattBufferLo
 STA drawingPhaseDebug

; ******************************************************************************
;
;       Name: subm_D8FD
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.subm_D8FD

 LDA pattBufferAddr,X
 STA debugPattBufferHi
 LSR A
 LSR A
 LSR A
 STA patternBufferHi
 RTS

; ******************************************************************************
;
;       Name: subm_D908
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.subm_D908

 LDY #0

.CD90A

 LDA (V),Y
 STA (SC),Y
 DEY
 BNE CD90A
 INC V+1
 INC SC+1
 DEX
 BNE CD90A
 RTS

; ******************************************************************************
;
;       Name: subm_D919
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.subm_D919

 LDY #0
 INC V
 INC V+1

.CD91F

 LDA (SC2),Y
 STA (SC),Y
 INY
 BNE CD92A
 INC SC+1
 INC SC2+1

.CD92A

 DEC V
 BNE CD91F
 DEC V+1
 BNE CD91F
 RTS

; ******************************************************************************
;
;       Name: subm_D933
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.subm_D933

 LDA PPU_STATUS

.loop_CD936

 LDA PPU_STATUS
 BPL loop_CD936

.loop_CD93B

 LDA PPU_STATUS
 BPL loop_CD93B

.CD940

 LDA PPU_STATUS
 BPL CD940
 RTS

; ******************************************************************************
;
;       Name: subm_D946
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.subm_D946

 TXA
 PHA
 JSR CD940
 JSR PlayMusic_b6
 PLA
 TAX
 RTS

; ******************************************************************************
;
;       Name: subm_D951
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.subm_D951

 JSR subm_D8C5
 LDA tileNumber
 STA tile0Phase0
 STA tile0Phase1
 LDA #$58
 STA L00CC
 LDA #$64
 STA L00CD
 STA L00CE
 LDA #$C4
 STA L03EF
 STA L03F0
 JMP subm_D8C5

; ******************************************************************************
;
;       Name: subm_D96F
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.subm_D96F

 JSR ChangeDrawingPhase
 JSR LL9_b1

; ******************************************************************************
;
;       Name: subm_D975
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.subm_D975

 LDA #$C8

; ******************************************************************************
;
;       Name: subm_D977
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.subm_D977

 PHA
 JSR DrawBoxEdges
 LDX drawingPhase
 LDA tileNumber
 STA tile0Phase0,X
 PLA
 STA L03EF,X
 RTS

; ******************************************************************************
;
;       Name: SendToPPU2
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.SendToPPU2

 LDY #0
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
 LDA SC
 CLC
 ADC #$10
 STA SC
 BCC CD9F3
 INC SC+1

.CD9F3

 DEX
 BNE SendToPPU2
 RTS

; ******************************************************************************
;
;       Name: TWOS
;       Type: Variable
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.TWOS

 EQUB $80, $40, $20, $10,   8,   4,   2,   1  ; D9F7: 80 40 20... .@
 EQUB $80, $40                                ; D9FF: 80 40       .@

; ******************************************************************************
;
;       Name: TWOS2
;       Type: Variable
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.TWOS2

 EQUB $C0, $C0, $60, $30, $18, $0C,   6,   3  ; DA01: C0 C0 60... ..`

; ******************************************************************************
;
;       Name: TWFL
;       Type: Variable
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.TWFL

 EQUB $80, $C0, $E0, $F0, $F8, $FC, $FE       ; DA09: 80 C0 E0... ...

; ******************************************************************************
;
;       Name: TWFR
;       Type: Variable
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.TWFR

 EQUB $FF, $7F, $3F, $1F, $0F,   7,   3,   1  ; DA10: FF 7F 3F... ..?

; ******************************************************************************
;
;       Name: yLookupLo
;       Type: Variable
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.yLookupLo

 EQUB $41, $41, $41, $41, $41, $41, $41, $41  ; DA18: 41 41 41... AAA
 EQUB $61, $61, $61, $61, $61, $61, $61, $61  ; DA20: 61 61 61... aaa
 EQUB $81, $81, $81, $81, $81, $81, $81, $81  ; DA28: 81 81 81... ...
 EQUB $A1, $A1, $A1, $A1, $A1, $A1, $A1, $A1  ; DA30: A1 A1 A1... ...
 EQUB $C1, $C1, $C1, $C1, $C1, $C1, $C1, $C1  ; DA38: C1 C1 C1... ...
 EQUB $E1, $E1, $E1, $E1, $E1, $E1, $E1, $E1  ; DA40: E1 E1 E1... ...
 EQUB $01, $01, $01, $01, $01, $01, $01, $01  ; DA48: 01 01 01... ...
 EQUB $21, $21, $21, $21, $21, $21, $21, $21  ; DA50: 21 21 21... !!!
 EQUB $41, $41, $41, $41, $41, $41, $41, $41  ; DA58: 41 41 41... AAA
 EQUB $61, $61, $61, $61, $61, $61, $61, $61  ; DA60: 61 61 61... aaa
 EQUB $81, $81, $81, $81, $81, $81, $81, $81  ; DA68: 81 81 81... ...
 EQUB $A1, $A1, $A1, $A1, $A1, $A1, $A1, $A1  ; DA70: A1 A1 A1... ...
 EQUB $C1, $C1, $C1, $C1, $C1, $C1, $C1, $C1  ; DA78: C1 C1 C1... ...
 EQUB $E1, $E1, $E1, $E1, $E1, $E1, $E1, $E1  ; DA80: E1 E1 E1... ...
 EQUB $01, $01, $01, $01, $01, $01, $01, $01  ; DA88: 01 01 01... ...
 EQUB $21, $21, $21, $21, $21, $21, $21, $21  ; DA90: 21 21 21... !!!
 EQUB $41, $41, $41, $41, $41, $41, $41, $41  ; DA98: 41 41 41... AAA
 EQUB $61, $61, $61, $61, $61, $61, $61, $61  ; DAA0: 61 61 61... aaa
 EQUB $81, $81, $81, $81, $81, $81, $81, $81  ; DAA8: 81 81 81... ...
 EQUB $A1, $A1, $A1, $A1, $A1, $A1, $A1, $A1  ; DAB0: A1 A1 A1... ...
 EQUB $C1, $C1, $C1, $C1, $C1, $C1, $C1, $C1  ; DAB8: C1 C1 C1... ...
 EQUB $E1, $E1, $E1, $E1, $E1, $E1, $E1, $E1  ; DAC0: E1 E1 E1... ...
 EQUB $01, $01, $01, $01, $01, $01, $01, $01  ; DAC8: 01 01 01... ...
 EQUB $21, $21, $21, $21, $21, $21, $21, $21  ; DAD0: 21 21 21... !!!
 EQUB $41, $41, $41, $41, $41, $41, $41, $41  ; DAD8: 41 41 41... AAA
 EQUB $61, $61, $61, $61, $61, $61, $61, $61  ; DAE0: 61 61 61... aaa
 EQUB $81, $81, $81, $81, $81, $81, $81, $81  ; DAE8: 81 81 81... ...
 EQUB $A1, $A1, $A1, $A1, $A1, $A1, $A1, $A1  ; DAF0: A1 A1 A1... ...

; ******************************************************************************
;
;       Name: yLookupHi
;       Type: Variable
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.yLookupHi

 EQUB $00, $00, $00, $00, $00, $00, $00, $00  ; DAF8: 00 00 00... ...
 EQUB $00, $00, $00, $00, $00, $00, $00, $00  ; DB00: 00 00 00... ...
 EQUB $00, $00, $00, $00, $00, $00, $00, $00  ; DB08: 00 00 00... ...
 EQUB $00, $00, $00, $00, $00, $00, $00, $00  ; DB10: 00 00 00... ...
 EQUB $00, $00, $00, $00, $00, $00, $00, $00  ; DB18: 00 00 00... ...
 EQUB $00, $00, $00, $00, $00, $00, $00, $00  ; DB20: 00 00 00... ...
 EQUB $01, $01, $01, $01, $01, $01, $01, $01  ; DB28: 01 01 01... ...
 EQUB $01, $01, $01, $01, $01, $01, $01, $01  ; DB30: 01 01 01... ...
 EQUB $01, $01, $01, $01, $01, $01, $01, $01  ; DB38: 01 01 01... ...
 EQUB $01, $01, $01, $01, $01, $01, $01, $01  ; DB40: 01 01 01... ...
 EQUB $01, $01, $01, $01, $01, $01, $01, $01  ; DB48: 01 01 01... ...
 EQUB $01, $01, $01, $01, $01, $01, $01, $01  ; DB50: 01 01 01... ...
 EQUB $01, $01, $01, $01, $01, $01, $01, $01  ; DB58: 01 01 01... ...
 EQUB $01, $01, $01, $01, $01, $01, $01, $01  ; DB60: 01 01 01... ...
 EQUB $02, $02, $02, $02, $02, $02, $02, $02  ; DB68: 02 02 02... ...
 EQUB $02, $02, $02, $02, $02, $02, $02, $02  ; DB70: 02 02 02... ...
 EQUB $02, $02, $02, $02, $02, $02, $02, $02  ; DB78: 02 02 02... ...
 EQUB $02, $02, $02, $02, $02, $02, $02, $02  ; DB80: 02 02 02... ...
 EQUB $02, $02, $02, $02, $02, $02, $02, $02  ; DB88: 02 02 02... ...
 EQUB $02, $02, $02, $02, $02, $02, $02, $02  ; DB90: 02 02 02... ...
 EQUB $02, $02, $02, $02, $02, $02, $02, $02  ; DB98: 02 02 02... ...
 EQUB $02, $02, $02, $02, $02, $02, $02, $02  ; DBA0: 02 02 02... ...
 EQUB $03, $03, $03, $03, $03, $03, $03, $03  ; DBA8: 03 03 03... ...
 EQUB $03, $03, $03, $03, $03, $03, $03, $03  ; DBB0: 03 03 03... ...
 EQUB $03, $03, $03, $03, $03, $03, $03, $03  ; DBB8: 03 03 03... ...
 EQUB $03, $03, $03, $03, $03, $03, $03, $03  ; DBC0: 03 03 03... ...
 EQUB $03, $03, $03, $03, $03, $03, $03, $03  ; DBC8: 03 03 03... ...
 EQUB $03, $03, $03, $03, $03, $03, $03, $03  ; DBD0: 03 03 03... ...

; ******************************************************************************
;
;       Name: subm_DBD8
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.subm_DBD8

 LDA #0
 STA SC+1
 LDA YC
 BEQ CDBFE
 LDA YC
 CLC
 ADC #1
 ASL A
 ASL A
 ASL A
 ASL A
 ROL SC+1
 SEC
 ROL A
 ROL SC+1
 STA SC
 STA SC2
 LDA SC+1
 ADC #$70
 STA SC+1
 ADC #4
 STA SC2+1
 RTS

.CDBFE

 LDA #$70
 STA SC+1
 LDA #$21
 STA SC
 LDA #$74
 STA SC2+1
 LDA #$21
 STA SC2
 RTS

; ******************************************************************************
;
;       Name: LOIN
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.LOIN

 STY YSAV

 SETUP_PPU_FOR_ICON_BAR ; If the PPU has started drawing the icon bar, configure
                        ; the PPU to use nametable 0 and pattern table 0

 LDA #$80
 STA S
 ASL A
 STA SWAP
 LDA X2
 SBC XX15
 BCS CDC30
 EOR #$FF
 ADC #1

.CDC30

 STA P
 SEC
 LDA Y2
 SBC Y1
 BCS CDC3D
 EOR #$FF
 ADC #1

.CDC3D

 STA Q
 CMP P
 BCC CDC46
 JMP CDE20

.CDC46

 LDX XX15
 CPX X2
 BCC CDC5E
 DEC SWAP
 LDA X2
 STA XX15
 STX X2
 TAX
 LDA Y2
 LDY Y1
 STA Y1
 STY Y2

.CDC5E

 LDX Q
 BEQ CDC84
 LDA logL,X
 LDX P
 SEC
 SBC logL,X
 BMI CDC88
 LDX Q
 LDA log,X
 LDX P
 SBC log,X
 BCS CDC80
 TAX
 LDA antilog,X
 JMP CDC98

.CDC80

 LDA #$FF
 BNE CDC98

.CDC84

 LDA #0
 BEQ CDC98

.CDC88

 LDX Q
 LDA log,X
 LDX P
 SBC log,X
 BCS CDC80
 TAX
 LDA antilogODD,X

.CDC98

 STA Q
 LDA P
 CLC
 ADC #1
 STA P
 LDY Y1
 CPY Y2
 BCS CDCAA
 JMP CDD62

.CDCAA

 LDA XX15
 LSR A
 LSR A
 LSR A
 CLC
 ADC yLookupLo,Y
 STA SC2
 LDA nameBufferHi
 ADC yLookupHi,Y
 STA SC2+1
 TYA
 AND #7
 TAY
 LDA XX15
 AND #7
 TAX
 LDA TWOS,X

.CDCC8

 STA R

.CDCCA

 SETUP_PPU_FOR_ICON_BAR ; If the PPU has started drawing the icon bar, configure
                        ; the PPU to use nametable 0 and pattern table 0

 LDX #0
 LDA (SC2,X)
 BNE CDCE5
 LDA tileNumber
 BEQ CDD32
 STA (SC2,X)
 INC tileNumber

.CDCE5

 LDX patternBufferHi
 STX SC+1
 ASL A
 ROL SC+1
 ASL A
 ROL SC+1
 ASL A
 ROL SC+1
 STA SC
 CLC

.loop_CDCF5

 LDA R
 ORA (SC),Y
 STA (SC),Y
 DEC P
 BEQ CDD51
 LDA S
 ADC Q
 STA S
 BCC CDD0A
 DEY
 BMI CDD18

.CDD0A

 LSR R
 BNE loop_CDCF5
 LDA #$80
 INC SC2
 BNE CDCC8
 INC SC2+1
 BNE CDCC8

.CDD18

 LDA SC2
 SBC #$20
 STA SC2
 BCS CDD22
 DEC SC2+1

.CDD22

 LDY #7
 LSR R
 BNE CDCCA
 LDA #$80
 INC SC2
 BNE CDCC8
 INC SC2+1
 BNE CDCC8

.CDD32

 DEC P
 BEQ CDD51
 CLC
 LDA S
 ADC Q
 STA S
 BCC CDD42
 DEY
 BMI CDD18

.CDD42

 LSR R
 BNE CDD32
 LDA #$80
 INC SC2
 BNE CDD4E
 INC SC2+1

.CDD4E

 JMP CDCC8

.CDD51

 LDY YSAV

 SETUP_PPU_FOR_ICON_BAR ; If the PPU has started drawing the icon bar, configure
                        ; the PPU to use nametable 0 and pattern table 0

 CLC
 RTS

.CDD62

 LDA XX15
 LSR A
 LSR A
 LSR A
 CLC
 ADC yLookupLo,Y
 STA SC2
 LDA nameBufferHi
 ADC yLookupHi,Y
 STA SC2+1
 TYA
 AND #7
 TAY
 LDA XX15
 AND #7
 TAX
 LDA TWOS,X

.CDD80

 STA R

.CDD82

 SETUP_PPU_FOR_ICON_BAR ; If the PPU has started drawing the icon bar, configure
                        ; the PPU to use nametable 0 and pattern table 0

 LDX #0
 LDA (SC2,X)
 BNE CDD9D
 LDA tileNumber
 BEQ CDDEE
 STA (SC2,X)
 INC tileNumber

.CDD9D

 LDX patternBufferHi
 STX SC+1
 ASL A
 ROL SC+1
 ASL A
 ROL SC+1
 ASL A
 ROL SC+1
 STA SC
 CLC

.loop_CDDAD

 LDA R
 ORA (SC),Y
 STA (SC),Y
 DEC P
 BEQ CDD51
 LDA S
 ADC Q
 STA S
 BCC CDDC4
 INY
 CPY #8
 BEQ CDDD3

.CDDC4

 LSR R
 BNE loop_CDDAD
 LDA #$80
 INC SC2
 BNE CDD80
 INC SC2+1
 JMP CDD80

.CDDD3

 LDA SC2
 ADC #$1F
 STA SC2
 BCC CDDDD
 INC SC2+1

.CDDDD

 LDY #0
 LSR R
 BNE CDD82
 LDA #$80
 INC SC2
 BNE CDD80
 INC SC2+1
 JMP CDD80

.CDDEE

 DEC P
 BEQ CDE1C
 CLC
 LDA S
 ADC Q
 STA S
 BCC CDE00
 INY
 CPY #8
 BEQ CDDD3

.CDE00

 LSR R
 BNE CDDEE
 LDA #$80
 INC SC2
 BNE CDE0C
 INC SC2+1

.CDE0C

 JMP CDD80

.loop_CDE0F

 SETUP_PPU_FOR_ICON_BAR ; If the PPU has started drawing the icon bar, configure
                        ; the PPU to use nametable 0 and pattern table 0

.CDE1C

 LDY YSAV
 CLC
 RTS

.CDE20

 LDY Y1
 TYA
 LDX XX15
 CPY Y2
 BEQ loop_CDE0F
 BCS CDE3C
 DEC SWAP
 LDA X2
 STA XX15
 STX X2
 TAX
 LDA Y2
 STA Y1
 STY Y2
 TAY

.CDE3C

 LDX P
 BEQ CDE62
 LDA logL,X
 LDX Q
 SEC
 SBC logL,X
 BMI CDE66
 LDX P
 LDA log,X
 LDX Q
 SBC log,X
 BCS CDE5E
 TAX
 LDA antilog,X
 JMP CDE76

.CDE5E

 LDA #$FF
 BNE CDE76

.CDE62

 LDA #0
 BEQ CDE76

.CDE66

 LDX P
 LDA log,X
 LDX Q
 SBC log,X
 BCS CDE5E
 TAX
 LDA antilogODD,X

.CDE76

 STA P
 LDA XX15
 LSR A
 LSR A
 LSR A
 CLC
 ADC yLookupLo,Y
 STA SC2
 LDA nameBufferHi
 ADC yLookupHi,Y
 STA SC2+1
 TYA
 AND #7
 TAY
 SEC
 LDA X2
 SBC XX15
 LDA XX15
 AND #7
 TAX
 LDA TWOS,X
 STA R
 LDX Q
 INX
 BCS CDEDD
 JMP CDFAA

; ******************************************************************************
;
;       Name: subm_DEA5
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.subm_DEA5

 LDY YSAV
 CLC
 RTS

.CDEA9

 LDX patternBufferHi
 STX SC+1
 ASL A
 ROL SC+1
 ASL A
 ROL SC+1
 ASL A
 ROL SC+1
 STA SC
 CLC
 LDX Q

.loop_CDEBB

 LDA R
 STA (SC),Y
 DEX
 BEQ subm_DEA5
 LDA S
 ADC P
 STA S
 BCC CDECE
 LSR R
 BCS CDF35

.CDECE

 DEY
 BPL loop_CDEBB
 LDY #7
 LDA SC2
 SBC #$1F
 STA SC2
 BCS CDEDD
 DEC SC2+1

.CDEDD

 STX Q

 SETUP_PPU_FOR_ICON_BAR ; If the PPU has started drawing the icon bar, configure
                        ; the PPU to use nametable 0 and pattern table 0

 LDX #0
 LDA (SC2,X)
 BNE CDEFD
 LDA tileNumber
 BEQ CDF4F
 STA (SC2,X)
 INC tileNumber
 JMP CDEA9

.CDEFD

 LDX patternBufferHi
 STX SC+1
 ASL A
 ROL SC+1
 ASL A
 ROL SC+1
 ASL A
 ROL SC+1
 STA SC
 CLC
 LDX Q

.loop_CDF0F

 LDA R
 ORA (SC),Y
 STA (SC),Y
 DEX
 BEQ subm_DEA5
 LDA S
 ADC P
 STA S
 BCC CDF24
 LSR R
 BCS CDF35

.CDF24

 DEY
 BPL loop_CDF0F
 LDY #7
 LDA SC2
 SBC #$1F
 STA SC2
 BCS CDEDD
 DEC SC2+1
 BNE CDEDD

.CDF35

 ROR R
 INC SC2
 BNE CDF3D
 INC SC2+1

.CDF3D

 DEY
 BPL CDEDD
 LDY #7
 LDA SC2
 SBC #$1F
 STA SC2
 BCS CDEDD
 DEC SC2+1
 JMP CDEDD

.CDF4F

 LDX Q

.loop_CDF51

 DEX
 BEQ CDF72
 LDA S
 ADC P
 STA S
 BCC CDF60
 LSR R
 BCS CDF35

.CDF60

 DEY
 BPL loop_CDF51
 LDY #7
 LDA SC2
 SBC #$1F
 STA SC2
 BCS CDF6F
 DEC SC2+1

.CDF6F

 JMP CDEDD

.CDF72

 LDY YSAV
 CLC
 RTS

; ******************************************************************************
;
;       Name: subm_DF76
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.subm_DF76

 LDX patternBufferHi
 STX SC+1
 ASL A
 ROL SC+1
 ASL A
 ROL SC+1
 ASL A
 ROL SC+1
 STA SC
 CLC
 LDX Q

.loop_CDF88

 LDA R
 STA (SC),Y
 DEX
 BEQ CDF72
 LDA S
 ADC P
 STA S
 BCC CDF9B
 ASL R
 BCS CE003

.CDF9B

 DEY
 BPL loop_CDF88
 LDY #7
 LDA SC2
 SBC #$1F
 STA SC2
 BCS CDFAA
 DEC SC2+1

.CDFAA

 STX Q

 SETUP_PPU_FOR_ICON_BAR ; If the PPU has started drawing the icon bar, configure
                        ; the PPU to use nametable 0 and pattern table 0

 LDX #0
 LDA (SC2,X)
 BNE CDFCA
 LDA tileNumber
 BEQ CE01F
 STA (SC2,X)
 INC tileNumber
 JMP subm_DF76

.CDFCA

 LDX patternBufferHi
 STX SC+1
 ASL A
 ROL SC+1
 ASL A
 ROL SC+1
 ASL A
 ROL SC+1
 STA SC
 CLC
 LDX Q

.loop_CDFDC

 LDA R
 ORA (SC),Y
 STA (SC),Y
 DEX
 BEQ CE046
 LDA S
 ADC P
 STA S
 BCC CDFF1
 ASL R
 BCS CE003

.CDFF1

 DEY
 BPL loop_CDFDC
 LDY #7
 LDA SC2
 SBC #$1F
 STA SC2
 BCS CDFAA
 DEC SC2+1
 JMP CDFAA

.CE003

 ROL R
 LDA SC2
 BNE CE00B
 DEC SC2+1

.CE00B

 DEC SC2
 DEY
 BPL CDFAA
 LDY #7
 LDA SC2
 SBC #$1F
 STA SC2
 BCS CDFAA
 DEC SC2+1
 JMP CDFAA

.CE01F

 LDX Q

.loop_CE021

 DEX
 BEQ CE042
 LDA S
 ADC P
 STA S
 BCC CE030
 ASL R
 BCS CE003

.CE030

 DEY
 BPL loop_CE021
 LDY #7
 LDA SC2
 SBC #$1F
 STA SC2
 BCS CE03F
 DEC SC2+1

.CE03F

 JMP CDFAA

.CE042

 LDY YSAV
 CLC
 RTS

.CE046

 LDY YSAV
 CLC
 RTS

; ******************************************************************************
;
;       Name: subm_E04A
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.subm_E04A

 SETUP_PPU_FOR_ICON_BAR ; If the PPU has started drawing the icon bar, configure
                        ; the PPU to use nametable 0 and pattern table 0

 STY YSAV
 LDA P
 LSR A
 LSR A
 LSR A
 CLC
 ADC yLookupLo,Y
 STA SC2
 LDA nameBufferHi
 ADC yLookupHi,Y
 STA SC2+1
 LDA P+1
 SEC
 SBC P
 LSR A
 LSR A
 LSR A
 TAY
 DEY

.CE075

 LDA (SC2),Y
 BNE CE083
 LDA #$33
 STA (SC2),Y
 DEY
 BPL CE075
 LDY YSAV
 RTS

.CE083

 STY T
 LDY patternBufferHi
 STY SC+1
 ASL A
 ROL SC+1
 ASL A
 ROL SC+1
 ASL A
 ROL SC+1
 STA SC

 SETUP_PPU_FOR_ICON_BAR ; If the PPU has started drawing the icon bar, configure
                        ; the PPU to use nametable 0 and pattern table 0

 LDY #7

.loop_CE0A3

 LDA #$FF
 EOR (SC),Y
 STA (SC),Y
 DEY
 BPL loop_CE0A3
 LDY T
 DEY
 BPL CE075
 LDY YSAV
 RTS

.CE0B4

 JMP CE2A6

 LDY YSAV

.loop_CE0B9

 RTS

; ******************************************************************************
;
;       Name: subm_E0BA
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.subm_E0BA

 SETUP_PPU_FOR_ICON_BAR ; If the PPU has started drawing the icon bar, configure
                        ; the PPU to use nametable 0 and pattern table 0

 STY YSAV
 LDX XX15
 CPX X2
 BEQ loop_CE0B9
 BCC CE0D8
 LDA X2
 STA XX15
 STX X2
 TAX

.CE0D8

 DEC X2
 TXA
 LSR A
 LSR A
 LSR A
 CLC
 ADC yLookupLo,Y
 STA SC2
 LDA nameBufferHi
 ADC yLookupHi,Y
 STA SC2+1
 TYA
 AND #7
 TAY
 TXA
 AND #$F8
 STA T
 LDA X2
 AND #$F8
 SEC
 SBC T
 BEQ CE0B4
 LSR A
 LSR A
 LSR A
 STA R

 SETUP_PPU_FOR_ICON_BAR ; If the PPU has started drawing the icon bar, configure
                        ; the PPU to use nametable 0 and pattern table 0

 LDX #0
 LDA (SC2,X)
 BNE CE123
 LDA tileNumber
 BEQ CE120
 STA (SC2,X)
 INC tileNumber
 JMP CE163

.CE120

 JMP CE17E

.CE123

 CMP #$3C
 BCS CE163
 CMP #$25
 BCC CE120
 LDX patternBufferHi
 STX L00BD
 ASL A
 ROL L00BD
 ASL A
 ROL L00BD
 ASL A
 ROL L00BD
 STA L00BC
 LDA tileNumber
 BEQ CE120
 LDX #0
 STA (SC2,X)
 INC tileNumber
 LDX patternBufferHi
 STX SC+1
 ASL A
 ROL SC+1
 ASL A
 ROL SC+1
 ASL A
 ROL SC+1
 STA SC
 STY T
 LDY #7

.loop_CE157

 LDA (L00BC),Y
 STA (SC),Y
 DEY
 BPL loop_CE157
 LDY T
 JMP CE172

.CE163

 LDX patternBufferHi
 STX SC+1
 ASL A
 ROL SC+1
 ASL A
 ROL SC+1
 ASL A
 ROL SC+1
 STA SC

.CE172

 LDA XX15
 AND #7
 TAX
 LDA TWFR,X
 EOR (SC),Y
 STA (SC),Y

.CE17E

 INC SC2
 BNE CE184
 INC SC2+1

.CE184

 LDX R
 DEX
 BNE CE18C
 JMP CE22B

.CE18C

 STX R

; ******************************************************************************
;
;       Name: subm_E18E
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.subm_E18E

 SETUP_PPU_FOR_ICON_BAR ; If the PPU has started drawing the icon bar, configure
                        ; the PPU to use nametable 0 and pattern table 0

 LDX #0
 LDA (SC2,X)
 BEQ CE1C7
 CMP #$3C
 BCC CE1E4
 LDX patternBufferHi
 STX SC+1
 ASL A
 ROL SC+1
 ASL A
 ROL SC+1
 ASL A
 ROL SC+1
 STA SC
 LDA #$FF
 EOR (SC),Y
 STA (SC),Y

.CE1BA

 INC SC2
 BNE CE1C0
 INC SC2+1

.CE1C0

 DEC R
 BNE subm_E18E
 JMP CE22B

.CE1C7

 TYA
 CLC
 ADC #$25
 STA (SC2,X)
 JMP CE1BA

.loop_CE1D0

 TYA
 EOR #$FF
 ADC #$33
 STA (SC2,X)
 INC SC2
 BNE CE1DD
 INC SC2+1

.CE1DD

 DEC R
 BNE subm_E18E
 JMP CE22B

.CE1E4

 STA SC
 TYA
 ADC SC
 CMP #$32
 BEQ loop_CE1D0
 LDA tileNumber
 BEQ CE1BA
 INC tileNumber
 STA (SC2,X)
 LDX patternBufferHi
 STX L00BD
 ASL A
 ROL L00BD
 ASL A
 ROL L00BD
 ASL A
 ROL L00BD
 STA L00BC
 LDA SC
 LDX patternBufferHi
 STX SC+1
 ASL A
 ROL SC+1
 ASL A
 ROL SC+1
 ASL A
 ROL SC+1
 STA SC
 STY T
 LDY #7

.loop_CE219

 LDA (SC),Y
 STA (L00BC),Y
 DEY
 BPL loop_CE219
 LDY T
 LDA #$FF
 EOR (L00BC),Y
 STA (L00BC),Y
 JMP CE1BA

.CE22B

 SETUP_PPU_FOR_ICON_BAR ; If the PPU has started drawing the icon bar, configure
                        ; the PPU to use nametable 0 and pattern table 0

 LDX #0
 LDA (SC2,X)
 BNE CE24C
 LDA tileNumber
 BEQ CE249
 STA (SC2,X)
 INC tileNumber
 JMP CE28C

.CE249

 JMP CE32E

.CE24C

 CMP #$3C
 BCS CE28C
 CMP #$25
 BCC CE249
 LDX patternBufferHi
 STX L00BD
 ASL A
 ROL L00BD
 ASL A
 ROL L00BD
 ASL A
 ROL L00BD
 STA L00BC
 LDA tileNumber
 BEQ CE249
 LDX #0
 STA (SC2,X)
 INC tileNumber
 LDX patternBufferHi
 STX SC+1
 ASL A
 ROL SC+1
 ASL A
 ROL SC+1
 ASL A
 ROL SC+1
 STA SC
 STY T
 LDY #7

.loop_CE280

 LDA (L00BC),Y
 STA (SC),Y
 DEY
 BPL loop_CE280
 LDY T
 JMP CE29B

.CE28C

 LDX patternBufferHi
 STX SC+1
 ASL A
 ROL SC+1
 ASL A
 ROL SC+1
 ASL A
 ROL SC+1
 STA SC

.CE29B

 LDA X2
 AND #7
 TAX
 LDA TWFL,X
 JMP CE32A

.CE2A6

 SETUP_PPU_FOR_ICON_BAR ; If the PPU has started drawing the icon bar, configure
                        ; the PPU to use nametable 0 and pattern table 0

 LDX #0
 LDA (SC2,X)
 BNE CE2C7
 LDA tileNumber
 BEQ CE2C4
 STA (SC2,X)
 INC tileNumber
 JMP CE307

.CE2C4

 JMP CE32E

.CE2C7

 CMP #$3C
 BCS CE307
 CMP #$25
 BCC CE2C4
 LDX patternBufferHi
 STX L00BD
 ASL A
 ROL L00BD
 ASL A
 ROL L00BD
 ASL A
 ROL L00BD
 STA L00BC
 LDA tileNumber
 BEQ CE2C4
 LDX #0
 STA (SC2,X)
 INC tileNumber
 LDX patternBufferHi
 STX SC+1
 ASL A
 ROL SC+1
 ASL A
 ROL SC+1
 ASL A
 ROL SC+1
 STA SC
 STY T
 LDY #7

.loop_CE2FB

 LDA (L00BC),Y
 STA (SC),Y
 DEY
 BPL loop_CE2FB
 LDY T
 JMP CE316

.CE307

 LDX patternBufferHi
 STX SC+1
 ASL A
 ROL SC+1
 ASL A
 ROL SC+1
 ASL A
 ROL SC+1
 STA SC

.CE316

 LDA XX15
 AND #7
 TAX
 LDA TWFR,X
 STA T
 LDA X2
 AND #7
 TAX
 LDA TWFL,X
 AND T

.CE32A

 EOR (SC),Y
 STA (SC),Y

.CE32E

 SETUP_PPU_FOR_ICON_BAR ; If the PPU has started drawing the icon bar, configure
                        ; the PPU to use nametable 0 and pattern table 0

 LDY YSAV
 RTS

; ******************************************************************************
;
;       Name: subm_E33E
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.subm_E33E

 SETUP_PPU_FOR_ICON_BAR ; If the PPU has started drawing the icon bar, configure
                        ; the PPU to use nametable 0 and pattern table 0

 STY YSAV
 LDY Y1
 CPY Y2
 BEQ CE391
 BCC CE35C
 LDA Y2
 STA Y1
 STY Y2
 TAY

.CE35C

 LDA XX15
 LSR A
 LSR A
 LSR A
 CLC
 ADC yLookupLo,Y
 STA SC2
 LDA nameBufferHi
 ADC yLookupHi,Y
 STA SC2+1
 LDA XX15
 AND #7
 STA S
 LDA Y2
 SEC
 SBC Y1
 STA R
 TYA
 AND #7
 TAY
 BNE CE394
 JMP CE43D

.CE384

 STY T
 LDA R
 ADC T
 SBC #7
 BCC CE391
 JMP CE423

.CE391

 LDY YSAV
 RTS

.CE394

 STY Q

 SETUP_PPU_FOR_ICON_BAR ; If the PPU has started drawing the icon bar, configure
                        ; the PPU to use nametable 0 and pattern table 0

 LDX #0
 LDA (SC2,X)
 BNE CE3B7
 LDA tileNumber
 BEQ CE3B4
 STA (SC2,X)
 INC tileNumber
 JMP CE3F7

.CE3B4

 JMP CE384

.CE3B7

 CMP #$3C
 BCS CE3F7
 CMP #$25
 BCC CE3B4
 LDX patternBufferHi
 STX L00BD
 ASL A
 ROL L00BD
 ASL A
 ROL L00BD
 ASL A
 ROL L00BD
 STA L00BC
 LDA tileNumber
 BEQ CE3B4
 LDX #0
 STA (SC2,X)
 INC tileNumber
 LDX patternBufferHi
 STX SC+1
 ASL A
 ROL SC+1
 ASL A
 ROL SC+1
 ASL A
 ROL SC+1
 STA SC
 STY T
 LDY #7

.loop_CE3EB

 LDA (L00BC),Y
 STA (SC),Y
 DEY
 BPL loop_CE3EB
 LDY T
 JMP CE406

.CE3F7

 LDX patternBufferHi
 STX SC+1
 ASL A
 ROL SC+1
 ASL A
 ROL SC+1
 ASL A
 ROL SC+1
 STA SC

.CE406

 LDX S
 LDY Q
 LDA R
 BEQ CE420

.loop_CE40E

 LDA (SC),Y
 ORA TWOS,X
 STA (SC),Y
 DEC R
 BEQ CE420
 INY
 CPY #8
 BCC loop_CE40E
 BCS CE423

.CE420

 LDY YSAV
 RTS

.CE423

 SETUP_PPU_FOR_ICON_BAR ; If the PPU has started drawing the icon bar, configure
                        ; the PPU to use nametable 0 and pattern table 0

 LDY #0
 LDA SC2
 CLC
 ADC #$20
 STA SC2
 BCC CE43D
 INC SC2+1

.CE43D

 LDA R
 BEQ CE420
 SEC
 SBC #8
 BCS CE449
 JMP CE394

.CE449

 STA R
 LDX #0
 LDA (SC2,X)
 BEQ CE4AA
 CMP #$3C
 BCC CE4B4
 LDX patternBufferHi
 STX SC+1
 ASL A
 ROL SC+1
 ASL A
 ROL SC+1
 ASL A
 ROL SC+1
 STA SC
 LDX S
 LDY #0
 LDA (SC),Y
 ORA TWOS,X
 STA (SC),Y
 INY
 LDA (SC),Y
 ORA TWOS,X
 STA (SC),Y
 INY
 LDA (SC),Y
 ORA TWOS,X
 STA (SC),Y
 INY
 LDA (SC),Y
 ORA TWOS,X
 STA (SC),Y
 INY
 LDA (SC),Y
 ORA TWOS,X
 STA (SC),Y
 INY
 LDA (SC),Y
 ORA TWOS,X
 STA (SC),Y
 INY
 LDA (SC),Y
 ORA TWOS,X
 STA (SC),Y
 INY
 LDA (SC),Y
 ORA TWOS,X
 STA (SC),Y
 JMP CE423

.CE4AA

 LDA S
 CLC
 ADC #$34
 STA (SC2,X)

.CE4B1

 JMP CE423

.CE4B4

 STA SC
 LDA tileNumber
 BEQ CE4B1
 INC tileNumber
 STA (SC2,X)
 LDX patternBufferHi
 STX L00BD
 ASL A
 ROL L00BD
 ASL A
 ROL L00BD
 ASL A
 ROL L00BD
 STA L00BC
 LDA SC
 LDX patternBufferHi
 STX SC+1
 ASL A
 ROL SC+1
 ASL A
 ROL SC+1
 ASL A
 ROL SC+1
 STA SC
 STY T
 LDY #7
 LDX S

.loop_CE4E4

 LDA (SC),Y
 ORA TWOS,X
 STA (L00BC),Y
 DEY
 BPL loop_CE4E4
 BMI CE4B1

; ******************************************************************************
;
;       Name: PIXEL
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.PIXEL

 STX SC2
 STY T1
 TAY
 TXA
 LSR A
 LSR A
 LSR A
 CLC
 ADC yLookupLo,Y
 STA SC
 LDA nameBufferHi
 ADC yLookupHi,Y
 STA SC+1

 SETUP_PPU_FOR_ICON_BAR ; If the PPU has started drawing the icon bar, configure
                        ; the PPU to use nametable 0 and pattern table 0

 LDX #0
 LDA (SC,X)
 BNE CE521
 LDA tileNumber
 BEQ CE540
 STA (SC,X)
 INC tileNumber

.CE521

 LDX patternBufferHi
 STX SC+1
 ASL A
 ROL SC+1
 ASL A
 ROL SC+1
 ASL A
 ROL SC+1
 STA SC
 TYA
 AND #7
 TAY
 LDA SC2
 AND #7
 TAX
 LDA TWOS,X
 ORA (SC),Y
 STA (SC),Y

.CE540

 LDY T1
 RTS

; ******************************************************************************
;
;       Name: DrawDash
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.DrawDash

 STX SC2
 STY T1
 TAY
 TXA
 LSR A
 LSR A
 LSR A
 CLC
 ADC yLookupLo,Y
 STA SC
 LDA nameBufferHi
 ADC yLookupHi,Y
 STA SC+1

 SETUP_PPU_FOR_ICON_BAR ; If the PPU has started drawing the icon bar, configure
                        ; the PPU to use nametable 0 and pattern table 0

 LDX #0
 LDA (SC,X)
 BNE CE574
 LDA tileNumber
 BEQ CE540
 STA (SC,X)
 INC tileNumber

.CE574

 LDX #$0C
 STX SC+1
 ASL A
 ROL SC+1
 ASL A
 ROL SC+1
 ASL A
 ROL SC+1
 STA SC
 TYA
 AND #7
 TAY
 LDA SC2
 AND #7
 TAX
 LDA TWOS2,X
 ORA (SC),Y
 STA (SC),Y
 LDY T1
 RTS

; ******************************************************************************
;
;       Name: ECBLB2
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.ECBLB2

 LDA #$20
 STA ECMA
 LDY #2
 JMP NOISE

; ******************************************************************************
;
;       Name: MSBAR
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.MSBAR

 TYA
 PHA
 LDY LE5AB,X
 PLA
 STA nameBuffer0+704,Y
 LDY #0
 RTS

; ******************************************************************************
;
;       Name: LE5AB
;       Type: Variable
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.LE5AB

 EQUB $00, $5F, $5E, $3F, $3E                 ; E5AB: 00 5F 5E... ._^

; ******************************************************************************
;
;       Name: LE5B0_EN
;       Type: Variable
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.LE5B0_EN

IF _NTSC

 EQUB $9F, $C2, $00, $75, $05, $8A, $40, $04  ; E5B0: 9F C2 00... ...

ELIF _PAL

 EQUB $9F, $C2, $00, $76, $05, $8A, $40, $04  ; E5B0: 9F C2 00... ...

ENDIF

 EQUB $83, $C2, $00, $6E, $03, $9C, $04, $14  ; E5B8: 83 C2 00... ...
 EQUB $44, $06, $40, $1F, $40, $1F, $21, $0E  ; E5C0: 44 06 40... D.@
 EQUB $83, $10, $03, $88, $8D, $01, $1F, $01  ; E5C8: 83 10 03... ...
 EQUB $15, $08, $14, $8E, $08, $1F, $08, $14  ; E5D0: 15 08 14... ...
 EQUB $08, $14, $21, $02, $83, $C3, $08, $01  ; E5D8: 08 14 21... ..!
 EQUB $04, $10, $03, $88, $9F, $9F, $22, $16  ; E5E0: 04 10 03... ...
 EQUB $83, $10, $03, $88, $21, $12, $83, $01  ; E5E8: 83 10 03... ...
 EQUB $08, $04, $1F, $10, $03, $88, $21, $02  ; E5F0: 08 04 1F... ...
 EQUB $83, $04, $13, $24, $11, $C3, $00, $01  ; E5F8: 83 04 13... ...
 EQUB $04, $C0                                ; E600: 04 C0       ..

; ******************************************************************************
;
;       Name: LE602_DE
;       Type: Variable
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.LE602_DE

IF _NTSC

 EQUB $9F, $C2, $00, $75, $05, $8A, $40, $04  ; E602: 9F C2 00... ...

ELIF _PAL

 EQUB $9F, $C2, $00, $76, $05, $8A, $40, $04  ; E602: 9F C2 00... ...

ENDIF

 EQUB $83, $C2, $00, $6E, $03, $9C, $04, $14  ; E60A: 83 C2 00... ...
 EQUB $44, $06, $40, $1F, $40, $1F, $21, $0E  ; E612: 44 06 40... D.@
 EQUB $83, $10, $03, $88, $8D, $01, $1F, $01  ; E61A: 83 10 03... ...
 EQUB $13, $08, $14, $8E, $08, $1F, $08, $1F  ; E622: 13 08 14... ...
 EQUB $08, $16, $21, $02, $83, $C3, $08, $01  ; E62A: 08 16 21... ..!
 EQUB $04, $10, $03, $88, $9F, $22, $16, $83  ; E632: 04 10 03... ...
 EQUB $10, $03, $88, $21, $12, $83, $10, $03  ; E63A: 10 03 88... ...
 EQUB $88, $21, $02, $83, $01, $0C, $04, $1F  ; E642: 88 21 02... .!.
 EQUB $04, $1E, $24, $16, $C3, $00, $01, $04  ; E64A: 04 1E 24... ..$
 EQUB $C0                                     ; E652: C0          .

; ******************************************************************************
;
;       Name: LE653_FR
;       Type: Variable
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.LE653_FR

IF _NTSC

 EQUB $9F, $C2, $00, $75, $05, $8A, $40, $04  ; E653: 9F C2 00... ...

ELIF _PAL

 EQUB $9F, $C2, $00, $76, $05, $8A, $40, $04  ; E653: 9F C2 00... ...

ENDIF

 EQUB $83, $C2, $00, $6E, $03, $9C, $04, $14  ; E65B: 83 C2 00... ...
 EQUB $44, $06, $40, $1F, $40, $1F, $21, $0E  ; E663: 44 06 40... D.@
 EQUB $83, $10, $03, $88, $8D, $01, $1F, $01  ; E66B: 83 10 03... ...
 EQUB $15, $08, $14, $8E, $08, $1F, $08, $1F  ; E673: 15 08 14... ...
 EQUB $08, $14, $21, $02, $83, $C3, $08, $01  ; E67B: 08 14 21... ..!
 EQUB $04, $10, $03, $88, $9F, $98, $22, $16  ; E683: 04 10 03... ...
 EQUB $83, $10, $03, $88, $21, $12, $83, $10  ; E68B: 83 10 03... ...
 EQUB $03, $88, $21, $02, $83, $01, $0E, $04  ; E693: 03 88 21... ..!
 EQUB $1F, $24, $11, $04, $1C, $C3, $00, $01  ; E69B: 1F 24 11... .$.
 EQUB $04                                     ; E6A3: 04          .

; ******************************************************************************
;
;       Name: LE6A4_subm_E802
;       Type: Variable
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.LE6A4_subm_E802

 EQUB $89, $10, $03, $88, $28, $19, $C2, $00  ; E6A4: 89 10 03... ...
 EQUB $A5, $00, $9F, $9F, $22, $16, $83, $10  ; E6AC: A5 00 9F... ...
 EQUB $03, $88, $9F, $04, $04, $83, $40, $04  ; E6B4: 03 88 9F... ...
 EQUB $83, $9F, $22, $12, $83, $10, $03, $88  ; E6BC: 83 9F 22... .."
 EQUB $9F, $01, $04, $83, $01, $04, $83, $01  ; E6C4: 9F 01 04... ...
 EQUB $04, $83, $01, $04, $83, $01, $04, $83  ; E6CC: 04 83 01... ...
 EQUB $01, $04, $83, $01, $04, $83, $01, $04  ; E6D4: 01 04 83... ...
 EQUB $83, $04, $04, $83, $01, $04, $83, $04  ; E6DC: 83 04 04... ...
 EQUB $04, $83, $04, $04, $83, $04, $04, $83  ; E6E4: 04 83 04... ...
 EQUB $04, $04, $83, $04, $04, $83, $04, $04  ; E6EC: 04 04 83... ...
 EQUB $83, $04, $04, $83, $04, $04, $83, $04  ; E6F4: 83 04 04... ...
 EQUB $04, $83, $04, $04, $83, $04, $04, $83  ; E6FC: 04 83 04... ...
 EQUB $04, $04, $83, $04, $04, $83, $04, $04  ; E704: 04 04 83... ...
 EQUB $83, $01, $04, $83, $9F, $10, $03, $88  ; E70C: 83 01 04... ...
 EQUB $9F, $9F, $22, $02, $83, $10, $03, $88  ; E714: 9F 9F 22... .."
 EQUB $9F, $9F, $9F, $9F, $21, $16, $83, $10  ; E71C: 9F 9F 9F... ...
 EQUB $03, $88, $9F, $08, $1E, $9F, $22, $02  ; E724: 03 88 9F... ...
 EQUB $83, $10, $03, $88, $9F, $10, $03, $88  ; E72C: 83 10 03... ...
 EQUB $9F, $9F, $9F, $10, $03, $88, $9F, $01  ; E734: 9F 9F 9F... ...
 EQUB $1F, $05, $1F, $01, $05, $9F, $10, $03  ; E73C: 1F 05 1F... ...
 EQUB $88, $9F, $9F, $9F, $10, $03, $88, $22  ; E744: 88 9F 9F... ...
 EQUB $02, $83, $9F, $10, $03, $88, $9F, $9F  ; E74C: 02 83 9F... ...
 EQUB $10, $03, $88, $9F, $21, $1A, $83, $10  ; E754: 10 03 88... ...
 EQUB $03, $88, $96, $22, $12, $83, $10, $03  ; E75C: 03 88 96... ...
 EQUB $88, $C4, $00, $6B, $03, $02, $16, $04  ; E764: 88 C4 00... ...
 EQUB $1E, $21, $22, $83, $10, $03, $88, $10  ; E76C: 1E 21 22... .!"
 EQUB $03, $88, $10, $03, $88, $10, $03, $88  ; E774: 03 88 10... ...

IF _NTSC

 EQUB $C2, $00, $64, $05, $22, $3A, $83, $10  ; E77C: C2 00 64... ..d

ELIF _PAL

 EQUB $C2, $00, $65, $05, $22, $3A, $83, $10  ; E77C: C2 00 64... ..d

ENDIF

 EQUB $03, $88, $C2, $00, $A5, $00, $9F, $21  ; E784: 03 88 C2... ...
 EQUB $02, $83, $10, $03, $88, $9F, $02, $04  ; E78C: 02 83 10... ...
 EQUB $83, $02, $04, $83, $02, $04, $83, $02  ; E794: 83 02 04... ...
 EQUB $04, $83, $02, $04, $83, $02, $04, $83  ; E79C: 04 83 02... ...
 EQUB $02, $04, $83, $02, $04, $83, $04, $04  ; E7A4: 02 04 83... ...
 EQUB $83, $02, $04, $83, $21, $12, $83, $10  ; E7AC: 83 02 04... ...
 EQUB $03, $88, $9F, $40, $1F, $40, $1F, $40  ; E7B4: 03 88 9F... ...
 EQUB $1F, $40, $1F, $22, $36, $83, $10, $03  ; E7BC: 1F 40 1F... .@.
 EQUB $88, $9F, $9F, $08, $1F, $08, $1F, $28  ; E7C4: 88 9F 9F... ...
 EQUB $0A, $83, $21, $0E, $83, $10, $03, $88  ; E7CC: 0A 83 21... ..!
 EQUB $9F, $9F, $21, $0E, $83, $10, $03, $88  ; E7D4: 9F 9F 21... ..!
 EQUB $9F, $21, $12, $83, $24, $1F, $08, $1F  ; E7DC: 9F 21 12... .!.
 EQUB $08, $1F, $83, $10, $03, $88, $C3, $08  ; E7E4: 08 1F 83... ...
 EQUB $01, $04, $9F, $21, $02, $83, $10, $03  ; E7EC: 01 04 9F... ...
 EQUB $88, $22, $1E, $83, $28, $0A, $C3, $00  ; E7F4: 88 22 1E... .".

IF _NTSC

 EQUB $86, $04, $10, $03, $88, $80            ; E7FC: 86 04 10... ...

ELIF _PAL

 EQUB $87, $04, $10, $03, $88, $80            ; E7FC: 86 04 10... ...

ENDIF

; ******************************************************************************
;
;       Name: subm_E802
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.subm_E802

 LDA controller1A
 ORA controller1B
 ORA controller1Left
 ORA controller1Right
 ORA controller1Up
 ORA controller1Down
 ORA controller1Start
 ORA controller1Select
 BPL CE822
 LDA #0
 STA L03EE
 RTS

.CE822

 LDX L04BD
 BNE CE83F
 LDY #0
 LDA (addr2),Y
 BMI CE878
 STA L04BC
 INY
 LDA (addr2),Y
 SEC
 TAX

.CE835

 LDA #1

.CE837

 ADC addr2
 STA addr2
 BCC CE83F
 INC addr2+1

.CE83F

 DEX
 STX L04BD
 LDA L04BC
 ASL controller1Right
 LSR A
 ROR controller1Right
 ASL controller1Left
 LSR A
 ROR controller1Left
 ASL controller1Down
 LSR A
 ROR controller1Down
 ASL controller1Up
 LSR A
 ROR controller1Up
 ASL controller1Select
 LSR A
 ROR controller1Select
 ASL controller1B
 LSR A
 ROR controller1B
 ASL controller1A
 LSR A
 ROR controller1A
 RTS

.CE878

 ASL A
 BEQ CE8DA
 BMI CE886
 ASL A
 TAX

.CE87F

 LDA #0
 STA L04BC
 BEQ CE835

.CE886

 ASL A
 BEQ CE8D1
 PHA
 INY
 LDA (addr2),Y
 STA L04BC
 INY
 LDA (addr2),Y
 STA addr4
 INY
 LDA (addr2),Y
 STA addr4+1
 LDY #0
 LDX #1
 PLA
 CMP #8
 BCS CE8AC
 LDA (addr4),Y
 BNE CE83F

.CE8A7

 LDA #4
 CLC
 BCC CE837

.CE8AC

 BNE CE8B4
 LDA (addr4),Y
 BEQ CE83F
 BNE CE8A7

.CE8B4

 CMP #$10
 BCS CE8BE
 LDA (addr4),Y
 BMI CE83F
 BPL CE8A7

.CE8BE

 BNE CE8C7
 LDA (addr4),Y
 BMI CE8A7
 JMP CE83F

.CE8C7

 LDA #$C0
 STA controller1Start
 LDX #$16
 CLC
 BCC CE87F

.CE8D1

 LDA #$E6
 STA addr2+1
 LDA #$A4
 STA addr2
 RTS

.CE8DA

 STA L03EE
 RTS

; ******************************************************************************
;
;       Name: subm_E8DE
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.subm_E8DE

 LDA controller1Start
 AND #$C0
 CMP #$40
 BNE CE8EE
 LDA #$50
 STA L0465
 BNE CE8FA

.CE8EE

 LDA L0465
 CMP #$50
 BEQ CE8FA

.CE8F5

 LDA #0
 STA L0465

.CE8FA

 LDA #$F0
 STA ySprite1
 STA ySprite2
 STA ySprite3
 STA ySprite4
 RTS

; ******************************************************************************
;
;       Name: subm_E909
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.subm_E909

 ASL A
 ASL A
 STA L0460
 LDX #0

 STX L0463
 STX L0462
 STX L0468
 STX L0467

IF _PAL

 STX PAL_EXTRA

ENDIF

 RTS

; ******************************************************************************
;
;       Name: subm_E91D
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.subm_E91D

IF _NTSC

 DEC L0467

ELIF _PAL

 DEC $0468
 BNE CE928
 LSR $045F

.CE928

ENDIF

 BPL CE925
 INC L0467

.CE925

 DEC L0463
 BPL CE92D
 INC L0463

.CE92D

 LDA L0473
 BMI CE8F5
 LDA L045F
 BEQ subm_E8DE
 LDA L0462
 CLC
 ADC L0460
 STA L0460
 AND #3
 BNE CE98D
 LDA #0
 STA L0462
 LDA L0463
 BNE CE98D
 LDA controller1B
 ORA scanController2
 BPL CE98D
 LDX controller1Left
 BMI CE964
 LDA #0
 STA controller1Left
 JMP CE972

.CE964

 LDA #$FF
 CPX #$80
 BNE CE96F
 LDX #$0C
 STX L0463

.CE96F

 STA L0462

.CE972

 LDX controller1Right
 BMI CE97F
 LDA #0
 STA controller1Right
 JMP CE98D

.CE97F

 LDA #1
 CPX #$80
 BNE CE98A
 LDX #$0C
 STX L0463

.CE98A

 STA L0462

.CE98D

 LDA L0460
 BPL CE999
 LDA #0
 STA L0462
 BEQ CE9A4

.CE999

 CMP #$2D
 BCC CE9A4
 LDA #0
 STA L0462
 LDA #$2C

.CE9A4

 STA L0460
 LDA L0460
 AND #3
 ORA L0462
 BNE CEA04
 LDA controller1B
 BMI CEA04
 LDA controller1B
 BMI CEA04
 LDA controller1Select
 BNE CEA04
 LDA #$FB
 STA tileSprite1
 STA tileSprite2
 LDA L0461
 CLC

IF _NTSC

 ADC #$0B

ELIF _PAL

 ADC #$11

ENDIF

 STA ySprite1
 STA ySprite2
 LDA L0460
 ASL A
 ASL A
 ADC L0460
 ADC #6
 STA xSprite4
 ADC #1
 STA xSprite1
 ADC #$0D
 STA xSprite2
 ADC #1
 STA xSprite3
 LDA L0461
 CLC

IF _NTSC

 ADC #$13

ELIF _PAL

 ADC #$19

ENDIF

 STA ySprite4
 STA ySprite3
 LDA L0460
 BNE CEA40
 JMP CEA40

.CEA04

 LDA #$FC
 STA tileSprite1
 STA tileSprite2
 LDA L0461
 CLC

IF _NTSC

 ADC #8

ELIF _PAL

 ADC #$E

ENDIF

 STA ySprite1
 STA ySprite2
 LDA L0460
 ASL A
 ASL A
 ADC L0460
 ADC #6
 STA xSprite4
 ADC #1
 STA xSprite1
 ADC #$0D
 STA xSprite2
 ADC #1
 STA xSprite3
 LDA L0461
 CLC

IF _NTSC

 ADC #$10

ELIF _PAL

 ADC #$16

ENDIF

 STA ySprite4
 STA ySprite3

.CEA40

 LDA controller1Left
 ORA controller1Right
 ORA controller1Up
 ORA controller1Down
 BPL CEA53
 LDA #0
 STA L0468

.CEA53

 LDA controller1Select
 AND #$F0
 CMP #$80
 BEQ CEA73
 LDA controller1B
 AND #$C0
 CMP #$80
 BNE CEA6A
 LDA #$1E
 STA L0468

.CEA6A

 CMP #$40
 BNE CEA7E

IF _NTSC

 LDA L0468
 BEQ CEA7E

.CEA73

 LDA L0460
 LSR A
 LSR A
 TAY
 LDA (L00BE),Y
 STA L0465

ELIF _PAL

 LDA $0469
 BNE CEA80
 STA $045F
 BEQ CEA7E

.CEA80

 LDA #$28
 STA $0468
 LDA $045F
 BNE CEA73
 INC $045F
 BNE CEA7E

.CEA73

 LSR $045F
 LDA $0461
 LSR A
 LSR A
 TAY
 LDA ($BE),Y
 STA $0466

ENDIF

.CEA7E

 LDA controller1Start
 AND #$C0
 CMP #$40
 BNE CEA8C
 LDA #$50
 STA L0465

.CEA8C

 RTS

; ******************************************************************************
;
;       Name: subm_EA8D
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.subm_EA8D

 LDA controller1B
 BNE CEAA7
 LDA controller1Left
 ASL A
 ASL A
 ASL A
 ASL A
 STA L04BA
 LDA controller1Right
 ASL A
 ASL A
 ASL A
 ASL A
 STA L04BB
 RTS

.CEAA7

 LDA #0
 STA L04BA
 STA L04BB
 RTS

; ******************************************************************************
;
;       Name: subm_EAB0
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.subm_EAB0

 LDA QQ11a
 BNE subm_EA8D
 LDX JSTX
 LDA #8
 STA addr4
 LDY scanController2
 BNE CEAC5
 LDA controller1B
 BMI CEB0C

.CEAC5

 LDA controller1Right,Y
 BPL CEACD
 JSR subm_EB19

.CEACD

 LDA controller1Left,Y
 BPL CEAD5
 JSR subm_EB0D

.CEAD5

 STX JSTX
 TYA
 BNE CEADB

.CEADB

 LDA #4
 STA addr4
 LDX JSTY
 LDA L03EB
 BMI CEAFB
 LDA controller1Down,Y
 BPL CEAEF
 JSR subm_EB19

.CEAEF

 LDA controller1Up,Y
 BPL CEAF7

.loop_CEAF4

 JSR subm_EB0D

.CEAF7

 STX JSTY
 RTS

.CEAFB

 LDA controller1Up,Y
 BPL CEB03
 JSR subm_EB19

.CEB03

 LDA controller1Down,Y
 BMI loop_CEAF4
 STX JSTY
 RTS

.CEB0C

 RTS

; ******************************************************************************
;
;       Name: subm_EB0D
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.subm_EB0D

 TXA
 CLC
 ADC addr4
 TAX
 BCC CEB16
 LDX #$FF

.CEB16

 BPL CEB24
 RTS

; ******************************************************************************
;
;       Name: subm_EB19
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.subm_EB19

 TXA
 SEC
 SBC addr4
 TAX
 BCS CEB22
 LDX #1

.CEB22

 BPL CEB26

.CEB24

 LDX #$80

.CEB26

 RTS

; ******************************************************************************
;
;       Name: LEB27
;       Type: Variable
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

 EQUB $01, $02, $03, $04, $05, $06, $07, $23  ; EB27: 01 02 03... ...
 EQUB $08, $00, $00, $0C, $00, $00, $00, $00  ; EB2F: 08 00 00... ...
 EQUB $11, $02, $03, $04, $15, $16, $17, $18  ; EB37: 11 02 03... ...
 EQUB $19, $1A, $1B, $0C, $00, $00, $00, $00  ; EB3F: 19 1A 1B... ...
 EQUB $01, $02, $24, $23, $15, $26, $27, $16  ; EB47: 01 02 24... ..$
 EQUB $29, $17, $1B, $0C, $00, $00, $00, $00  ; EB4F: 29 17 1B... )..
 EQUB $31, $32, $33, $34, $35, $00, $00, $00  ; EB57: 31 32 33... 123
 EQUB $00, $00, $00, $3C, $00, $00, $00, $00  ; EB5F: 00 00 00... ...

; ******************************************************************************
;
;       Name: subm_EB67
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.subm_EB67

 SETUP_PPU_FOR_ICON_BAR ; If the PPU has started drawing the icon bar, configure
                        ; the PPU to use nametable 0 and pattern table 0

 LDX NOSTM
 LDY #$98

.CEB79

 LDA #$F0

.loop_CEB7B

 STA ySprite0,Y
 INY
 INY
 INY
 INY
 DEX
 BPL loop_CEB7B
 RTS

; ******************************************************************************
;
;       Name: subm_EB86
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.subm_EB86

 LDA QQ11a
 CMP QQ11
 BEQ subm_EB8F

; ******************************************************************************
;
;       Name: subm_EB8C
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.subm_EB8C

 JSR CB63D_b3

; ******************************************************************************
;
;       Name: subm_EB8F
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.subm_EB8F

 SETUP_PPU_FOR_ICON_BAR ; If the PPU has started drawing the icon bar, configure
                        ; the PPU to use nametable 0 and pattern table 0

 LDX #$3A
 LDY #$14
 BNE CEB79

; ******************************************************************************
;
;       Name: DELAY
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.DELAY

 JSR KeepPPUTablesAt0
 DEY
 BNE DELAY
 RTS

; ******************************************************************************
;
;       Name: BEEP
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.BEEP

 LDY #3
 BNE NOISE

; ******************************************************************************
;
;       Name: EXNO3
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.EXNO3

 LDY #$0D
 BNE NOISE

; ******************************************************************************
;
;       Name: subm_EBB1
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.subm_EBB1

 LDX #0
 JSR CEBCF

.loop_CEBB6

 LDX #1
 JSR CEBCF
 LDX #2
 BNE CEBCF

; ******************************************************************************
;
;       Name: ECBLB
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.ECBLB

 LDX noiseLookup1,Y
 CPX #3
 BCC CEBCF
 BNE loop_CEBB6
 LDX #0
 JSR CEBCF
 LDX #2

.CEBCF

 SETUP_PPU_FOR_ICON_BAR ; If the PPU has started drawing the icon bar, configure
                        ; the PPU to use nametable 0 and pattern table 0

 LDA #0
 STA L0478,X
 LDA #$1A
 BNE CEC2B

; ******************************************************************************
;
;       Name: BOOP
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.BOOP

 LDY #4
 BNE NOISE

; ******************************************************************************
;
;       Name: subm_EBE9
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.subm_EBE9

 LDY #1
 BNE NOISE

; ******************************************************************************
;
;       Name: subm_EBED
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.subm_EBED

 JSR subm_EBB1
 LDY #$15

; ******************************************************************************
;
;       Name: NOISE
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.NOISE

 LDA L03EC
 BPL CEC2E
 LDX noiseLookup1,Y
 CPX #3
 BCC CEC0A
 TYA
 PHA
 DEX
 DEX
 DEX
 JSR CEC0A
 PLA
 TAY
 LDX #2

.CEC0A

 LDA L0302,X
 BEQ CEC17
 LDA noiseLookup2,Y
 CMP L0478,X
 BCC CEC2E

.CEC17

 LDA noiseLookup2,Y
 STA L0478,X

 SETUP_PPU_FOR_ICON_BAR ; If the PPU has started drawing the icon bar, configure
                        ; the PPU to use nametable 0 and pattern table 0

 TYA

.CEC2B

 JSR C89D1_b6

.CEC2E

 SETUP_PPU_FOR_ICON_BAR ; If the PPU has started drawing the icon bar, configure
                        ; the PPU to use nametable 0 and pattern table 0

 RTS

; ******************************************************************************
;
;       Name: noiseLookup1
;       Type: Variable
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.noiseLookup1

 EQUB 2, 1, 1, 1, 1, 0, 0, 1, 2, 2, 2, 2, 3   ; EC3C: 02 01 01... ...
 EQUB 2, 2, 0, 0, 0, 0, 0, 2, 3, 3, 2, 1, 2   ; EC49: 02 02 00... ...
 EQUB 0, 2, 0, 1, 0, 0                        ; EC56: 00 02 00... ...

; ******************************************************************************
;
;       Name: noiseLookup2
;       Type: Variable
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.noiseLookup2

 EQUB $80, $82, $C0, $21, $21, $10, $10, $41  ; EC5C: 80 82 C0... ...
 EQUB $82, $32, $84, $20, $C0, $60, $40, $80  ; EC64: 82 32 84... .2.
 EQUB $80, $80, $80, $90, $84, $33, $33, $20  ; EC6C: 80 80 80... ...
 EQUB $C0, $18, $10, $10, $10, $10, $10, $60  ; EC74: C0 18 10... ...
 EQUB $60                                     ; EC7C: 60          `

; ******************************************************************************
;
;       Name: SetupPPUForIconBar
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.SetupPPUForIconBar

 PHA

 SETUP_PPU_FOR_ICON_BAR ; If the PPU has started drawing the icon bar, configure
                        ; the PPU to use nametable 0 and pattern table 0

 PLA
 RTS

; ******************************************************************************
;
;       Name: GetShipBlueprint
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.GetShipBlueprint

 LDA currentBank
 PHA
 LDA #1
 JSR SetBank
 LDA (XX0),Y

.loop_CEC97

 STA L00B7
 PLA
 JSR SetBank
 LDA L00B7
 RTS

; ******************************************************************************
;
;       Name: GetDefaultNEWB
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.GetDefaultNEWB

 LDA currentBank
 PHA
 LDA #1
 JSR SetBank
 LDA E%-1,Y
 JMP loop_CEC97

; ******************************************************************************
;
;       Name: IncreaseTally
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.IncreaseTally

 SETUP_PPU_FOR_ICON_BAR ; If the PPU has started drawing the icon bar, configure
                        ; the PPU to use nametable 0 and pattern table 0

 LDA currentBank
 PHA
 LDA #1
 JSR SetBank
 LDA KWL%-1,X
 ASL A
 PHA
 LDA KWH%-1,X
 ROL A
 TAY
 PLA
 ADC TALLYL
 STA TALLYL
 TYA
 ADC TALLY
 STA TALLY

.loop_CECDB

 PLA
 PHP
 JSR SetBank
 PLP

.CECE1

 RTS

; ******************************************************************************
;
;       Name: subm_ECE2
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.subm_ECE2

 LDA L0465
 BEQ CECE1

; ******************************************************************************
;
;       Name: CB1D4_b0
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.CB1D4_b0

 STA L00B7
 LDA currentBank
 PHA
 LDA #0
 JSR SetBank
 LDA L00B7
 JSR subm_B1D4
 JMP loop_CECDB

; ******************************************************************************
;
;       Name: Set_K_K3_XC_YC
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.Set_K_K3_XC_YC

 LDA #2
 STA K
 STA K+1
 LDA #$45
 STA K+2
 LDA #8
 STA K+3
 LDA #3
 STA XC
 LDA #$19
 STA YC
 LDX #7
 LDY #7
 JMP CA0F8_b6

; ******************************************************************************
;
;       Name: PlayMusic_b6
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.PlayMusic_b6

 LDA currentBank
 PHA
 LDA #6
 JSR SetBank
 JSR PlayMusic
 JMP ResetBank

; ******************************************************************************
;
;       Name: C8021_b6
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.C8021_b6

 PHA
 JSR KeepPPUTablesAt0
 PLA
 ORA #$80
 STA L045E
 AND #$7F
 LDX L03ED
 BMI CECE1
 STA L00B7
 LDA currentBank
 CMP #6
 BEQ CED4B
 PHA
 LDA #6
 JSR SetBank
 LDA L00B7
 JSR subm_8021
 JMP ResetBank

.CED4B

 LDA L00B7
 JMP subm_8021

; ******************************************************************************
;
;       Name: C89D1_b6
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.C89D1_b6

 STA L00B7
 LDA currentBank
 CMP #6
 BEQ CED66
 PHA
 LDA #6
 JSR SetBank
 LDA L00B7
 JSR subm_89D1
 JMP ResetBank

.CED66

 LDA L00B7
 JMP subm_89D1

; ******************************************************************************
;
;       Name: WaitResetSound
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.WaitResetSound

 JSR KeepPPUTablesAt0

; ******************************************************************************
;
;       Name: ResetSoundL045E
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.ResetSoundL045E

 LDA #0
 STA L045E

; ******************************************************************************
;
;       Name: ResetSound_b6
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.ResetSound_b6

 LDA currentBank
 PHA
 LDA #6
 JSR SetBank
 JSR ResetSound
 JMP ResetBank

; ******************************************************************************
;
;       Name: CBF41_b5
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.CBF41_b5

 LDA currentBank
 PHA
 LDA #5
 JSR SetBank
 JSR subm_BF41
 JMP ResetBank

; ******************************************************************************
;
;       Name: CB9F9_b4
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.CB9F9_b4

 LDA currentBank
 PHA
 LDA #4
 JSR SetBank
 JSR subm_B9F9
 JMP ResetBank

; ******************************************************************************
;
;       Name: CB96B_b4
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.CB96B_b4

 LDA currentBank
 PHA
 LDA #4
 JSR SetBank
 JSR subm_B96B
 JMP ResetBank

; ******************************************************************************
;
;       Name: CB63D_b3
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.CB63D_b3

 LDA currentBank
 PHA
 LDA #3
 JSR SetBank
 JSR subm_B63D
 JMP ResetBank

; ******************************************************************************
;
;       Name: CB88C_b6
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.CB88C_b6

 LDA currentBank
 PHA
 LDA #6
 JSR SetBank
 JSR subm_B88C
 JMP ResetBank

; ******************************************************************************
;
;       Name: LL9_b1
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.LL9_b1

 LDA currentBank
 CMP #1
 BEQ CEDD9
 PHA
 LDA #1
 JSR SetBank
 JSR LL9
 JMP ResetBank

.CEDD9

 JMP LL9

; ******************************************************************************
;
;       Name: CBA23_b3
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.CBA23_b3

 LDA currentBank
 PHA
 LDA #3
 JSR SetBank
 JSR subm_BA23
 JMP ResetBank

; ******************************************************************************
;
;       Name: TIDY_b1
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.TIDY_b1

 LDA currentBank
 CMP #1
 BEQ CEDFC
 PHA
 LDA #1
 JSR SetBank
 JSR TIDY
 JMP ResetBank

.CEDFC

 JMP TIDY

; ******************************************************************************
;
;       Name: TITLE_b6
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.TITLE_b6

 LDA currentBank
 PHA
 LDA #6
 JSR SetBank
 JSR TITLE
 JMP ResetBank

; ******************************************************************************
;
;       Name: SpawnDemoShips_b0
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.SpawnDemoShips_b0

 LDA #0
 JSR SetBank
 JMP DemoShips

; ******************************************************************************
;
;       Name: STARS_b1
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.STARS_b1

 LDA currentBank
 CMP #1
 BEQ CEE27
 PHA
 LDA #1
 JSR SetBank
 JSR STARS
 JMP ResetBank

.CEE27

 JMP STARS

; ******************************************************************************
;
;       Name: CIRCLE2_b1
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.CIRCLE2_b1

 LDA currentBank
 CMP #1
 BEQ CEE3C
 PHA
 LDA #1
 JSR SetBank
 JSR CIRCLE2
 JMP ResetBank

.CEE3C

 JMP CIRCLE2

; ******************************************************************************
;
;       Name: SUN_b1
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.SUN_b1

 LDA currentBank
 CMP #1
 BEQ CEE51
 PHA
 LDA #1
 JSR SetBank
 JSR SUN
 JMP ResetBank

.CEE51

 JMP SUN

; ******************************************************************************
;
;       Name: CB2FB_b3
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.CB2FB_b3

 LDA currentBank
 PHA
 LDA #3
 JSR SetBank
 JSR subm_B2FB
 JMP ResetBank

; ******************************************************************************
;
;       Name: CB219_b3
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.CB219_b3

 STA L00B7
 LDA currentBank
 CMP #3
 BEQ CEE78
 PHA
 LDA #3
 JSR SetBank
 LDA L00B7
 JSR subm_B219
 JMP ResetBank

.CEE78

 LDA L00B7
 JMP subm_B219

; ******************************************************************************
;
;       Name: CB9C1_b4
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.CB9C1_b4

 LDA currentBank
 PHA
 LDA #4
 JSR SetBank
 JSR subm_B9C1
 JMP ResetBank

; ******************************************************************************
;
;       Name: CA082_b6
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.CA082_b6

 LDA currentBank
 PHA
 LDA #6
 JSR SetBank
 JSR subm_A082
 JMP ResetBank

; ******************************************************************************
;
;       Name: CA0F8_b6
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.CA0F8_b6

 LDA currentBank
 PHA
 LDA #6
 JSR SetBank
 JSR subm_A0F8
 JMP ResetBank

; ******************************************************************************
;
;       Name: CB882_b4
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.CB882_b4

 LDA currentBank
 PHA
 LDA #4
 JSR SetBank
 JSR subm_B882
 JMP ResetBank

; ******************************************************************************
;
;       Name: CA4A5_b6
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.CA4A5_b6

 LDA currentBank
 PHA
 LDA #6
 JSR SetBank
 JSR subm_A4A5
 JMP ResetBank

; ******************************************************************************
;
;       Name: CB2EF_b0
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.CB2EF_b0

 LDA #0
 JSR SetBank
 JMP subm_B2EF

; ******************************************************************************
;
;       Name: CB358_b0
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.CB358_b0

 LDA #0
 JSR SetBank
 JMP subm_B358

; ******************************************************************************
;
;       Name: CB9E2_b3
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.CB9E2_b3

 LDA currentBank
 CMP #3
 BEQ CEEE5
 PHA
 LDA #3
 JSR SetBank
 JSR subm_B9E2
 JMP ResetBank

.CEEE5

 JMP subm_B9E2

; ******************************************************************************
;
;       Name: CB673_b3
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.CB673_b3

 LDA currentBank
 PHA
 LDA #3
 JSR SetBank
 JSR subm_B673
 JMP ResetBank

; ******************************************************************************
;
;       Name: CB2BC_b3
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.CB2BC_b3

 LDA currentBank
 PHA
 LDA #3
 JSR SetBank
 JSR subm_B2BC
 JMP ResetBank

; ******************************************************************************
;
;       Name: CB248_b3
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.CB248_b3

 LDA currentBank
 PHA
 LDA #3
 JSR SetBank
 JSR subm_B248
 JMP ResetBank

; ******************************************************************************
;
;       Name: CBA17_b6
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.CBA17_b6

 LDA currentBank
 PHA
 LDA #6
 JSR SetBank
 JSR subm_BA17
 JMP ResetBank

; ******************************************************************************
;
;       Name: CAFCD_b3
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.CAFCD_b3

 LDA currentBank
 CMP #3
 BEQ CEF32
 PHA
 LDA #3
 JSR SetBank
 JSR subm_AFCD
 JMP ResetBank

.CEF32

 JMP subm_AFCD

; ******************************************************************************
;
;       Name: CBE52_b6
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.CBE52_b6

 LDA currentBank
 PHA
 LDA #6
 JSR SetBank
 JSR subm_BE52
 JMP ResetBank

; ******************************************************************************
;
;       Name: CBED2_b6
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.CBED2_b6

 LDA currentBank
 PHA
 LDA #6
 JSR SetBank
 JSR subm_BED2
 JMP ResetBank

; ******************************************************************************
;
;       Name: CB0E1_b3
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.CB0E1_b3

 STA L00B7
 LDA currentBank
 CMP #3
 BEQ CEF67
 PHA
 LDA #3
 JSR SetBank
 LDA L00B7
 JSR subm_B0E1
 JMP ResetBank

.CEF67

 LDA L00B7
 JMP subm_B0E1

; ******************************************************************************
;
;       Name: CB18E_b3
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.CB18E_b3

 LDA currentBank
 PHA
 LDA #3
 JSR SetBank
 JSR subm_B18E
 JMP ResetBank

; ******************************************************************************
;
;       Name: PAS1_b0
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.PAS1_b0

 LDA currentBank
 PHA
 LDA #0
 JSR SetBank
 JSR PAS1
 JMP ResetBank

; ******************************************************************************
;
;       Name: SetSystemImage_b5
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.SetSystemImage_b5

 LDA currentBank
 PHA
 LDA #5
 JSR SetBank
 JSR SetSystemImage
 JMP ResetBank

; ******************************************************************************
;
;       Name: GetSystemImage_b5
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.GetSystemImage_b5

 LDA currentBank
 PHA
 LDA #5
 JSR SetBank
 JSR GetSystemImage
 JMP ResetBank

; ******************************************************************************
;
;       Name: SetCmdrImage_b4
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.SetCmdrImage_b4

 LDA currentBank
 PHA
 LDA #4
 JSR SetBank
 JSR SetCmdrImage
 JMP ResetBank

; ******************************************************************************
;
;       Name: GetCmdrImage_b4
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.GetCmdrImage_b4

 LDA currentBank
 PHA
 LDA #4
 JSR SetBank
 JSR GetCmdrImage
 JMP ResetBank

; ******************************************************************************
;
;       Name: DIALS_b6
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.DIALS_b6

 LDA currentBank
 PHA
 LDA #6
 JSR SetBank
 JSR DIALS
 JMP ResetBank

; ******************************************************************************
;
;       Name: CBA63_b6
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.CBA63_b6

 LDA currentBank
 PHA
 LDA #6
 JSR SetBank
 JSR subm_BA63
 JMP ResetBank

; ******************************************************************************
;
;       Name: CB39D_b0
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.CB39D_b0

 STA L00B7
 LDA currentBank
 CMP #0
 BEQ CEFF2
 PHA
 LDA #0
 JSR SetBank
 LDA L00B7
 JSR subm_B39D
 JMP ResetBank

.CEFF2

 LDA L00B7
 JMP subm_B39D

; ******************************************************************************
;
;       Name: LL164_b6
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.LL164_b6

 LDA currentBank
 PHA
 LDA #6
 JSR SetBank
 JSR LL164
 JMP ResetBank

; ******************************************************************************
;
;       Name: CB919_b6
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.CB919_b6

 LDA currentBank
 PHA
 LDA #6
 JSR SetBank
 JSR subm_B919
 JMP ResetBank

; ******************************************************************************
;
;       Name: CA166_b6
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.CA166_b6

 LDA currentBank
 PHA
 LDA #6
 JSR SetBank
 JSR subm_A166
 JMP ResetBank

; ******************************************************************************
;
;       Name: CBBDE_b6
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.CBBDE_b6

 LDA currentBank
 PHA
 LDA #6
 JSR SetBank
 JSR subm_BBDE
 JMP ResetBank

; ******************************************************************************
;
;       Name: CBB37_b6
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.CBB37_b6

 LDA currentBank
 PHA
 LDA #6
 JSR SetBank
 JSR subm_BB37
 JMP ResetBank

; ******************************************************************************
;
;       Name: CB8FE_b6
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.CB8FE_b6

 LDA currentBank
 PHA
 LDA #6
 JSR SetBank
 JSR subm_B8FE
 JMP ResetBank

; ******************************************************************************
;
;       Name: CB90D_b6
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.CB90D_b6

 LDA currentBank
 PHA
 LDA #6
 JSR SetBank
 JSR subm_B90D6
 JMP ResetBank

; ******************************************************************************
;
;       Name: CA5AB_b6
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.CA5AB_b6

 STA L00B7
 LDA currentBank
 CMP #6
 BEQ CF06F
 PHA
 LDA #6
 JSR SetBank
 LDA L00B7
 JSR subm_A5AB
 JMP ResetBank

.CF06F

 LDA L00B7
 JMP subm_A5AB

; ******************************************************************************
;
;       Name: BEEP_b7
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.BEEP_b7

 LDA currentBank
 PHA
 LDA #0
 JSR SetBank
 JSR BEEP
 JMP ResetBank

; ******************************************************************************
;
;       Name: DETOK_b2
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.DETOK_b2

 STA L00B7
 LDA currentBank
 CMP #2
 BEQ CF098
 PHA
 LDA #2
 JSR SetBank
 LDA L00B7
 JSR DETOK
 JMP ResetBank

.CF098

 LDA L00B7
 JMP DETOK

; ******************************************************************************
;
;       Name: DTS_b2
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.DTS_b2

 STA L00B7
 LDA currentBank
 CMP #2
 BEQ CF0B3
 PHA
 LDA #2
 JSR SetBank
 LDA L00B7
 JSR DTS
 JMP ResetBank

.CF0B3

 LDA L00B7
 JMP DTS

; ******************************************************************************
;
;       Name: PDESC_b2
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.PDESC_b2

 LDA currentBank
 PHA
 LDA #2
 JSR SetBank
 JSR PDESC
 JMP ResetBank

; ******************************************************************************
;
;       Name: CAE18_b3
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.CAE18_b3

 STA L00B7
 LDA currentBank
 CMP #3
 BEQ CF0DC
 PHA
 LDA #3
 JSR SetBank
 LDA L00B7
 JSR subm_AE18
 JMP ResetBank

.CF0DC

 LDA L00B7
 JMP subm_AE18

; ******************************************************************************
;
;       Name: CAC1D_b3
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.CAC1D_b3

 STA L00B7
 LDA currentBank
 CMP #3
 BEQ CF0F7
 PHA
 LDA #3
 JSR SetBank
 LDA L00B7
 JSR subm_AC1D
 JMP ResetBank

.CF0F7

 LDA L00B7
 JMP subm_AC1D

; ******************************************************************************
;
;       Name: CA730_b3
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.CA730_b3

 LDA currentBank
 PHA
 LDA #3
 JSR SetBank
 JSR subm_A730
 JMP ResetBank

; ******************************************************************************
;
;       Name: CA775_b3
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.CA775_b3

 LDA currentBank
 PHA
 LDA #3
 JSR SetBank
 JSR subm_A775
 JMP ResetBank

; ******************************************************************************
;
;       Name: DrawTitleScreen_b3
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.DrawTitleScreen_b3

 LDA currentBank
 PHA
 LDA #3
 JSR SetBank
 JSR DrawTitleScreen
 JMP ResetBank

; ******************************************************************************
;
;       Name: subm_F126
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.subm_F126

 LDA L0473
 BPL subm_F139

; ******************************************************************************
;
;       Name: CA7B7_b3
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.CA7B7_b3

 LDA currentBank
 PHA
 LDA #3
 JSR SetBank
 JSR subm_A7B7
 JMP ResetBank

; ******************************************************************************
;
;       Name: subm_F139
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.subm_F139

 LDA #$74
 STA L00CD
 STA L00CE

; ******************************************************************************
;
;       Name: CA9D1_b3
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.CA9D1_b3

 LDA #$C0
 STA L00B7
 LDA currentBank
 CMP #3
 BEQ CF157
 PHA
 LDA #3
 JSR SetBank
 LDA L00B7
 JSR subm_A9D1
 JMP ResetBank

.CF157

 LDA L00B7
 JMP subm_A9D1

; ******************************************************************************
;
;       Name: CA972_b3
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.CA972_b3

 LDA currentBank
 CMP #3
 BEQ CF16E
 PHA
 LDA #3
 JSR SetBank
 JSR subm_A972
 JMP ResetBank

.CF16E

 JMP subm_A972

; ******************************************************************************
;
;       Name: CAC5C_b3
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.CAC5C_b3

 LDA currentBank
 CMP #3
 BEQ CF183
 PHA
 LDA #3
 JSR SetBank
 JSR subm_AC5C
 JMP ResetBank

.CF183

 JMP subm_AC5C

; ******************************************************************************
;
;       Name: C8980_b0
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.C8980_b0

 LDA currentBank
 PHA
 LDA #0
 JSR SetBank
 JSR subm_8980
 JMP ResetBank

; ******************************************************************************
;
;       Name: CB459_b6
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.CB459_b6

 LDA currentBank
 PHA
 LDA #6
 JSR SetBank
 JSR subm_B459
 JMP ResetBank

; ******************************************************************************
;
;       Name: MVS5_b0
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.MVS5_b0

 STA L00B7
 LDA currentBank
 CMP #0
 BEQ CF1B8
 PHA
 LDA #0
 JSR SetBank
 LDA L00B7
 JSR MVS5
 JMP ResetBank

.CF1B8

 LDA L00B7
 JMP MVS5

; ******************************************************************************
;
;       Name: HALL_b1
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.HALL_b1

 LDA currentBank
 PHA
 LDA #1
 JSR SetBank
 JSR HALL
 JMP ResetBank

; ******************************************************************************
;
;       Name: CHPR_b2
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.CHPR_b2

 STA L00B7
 LDA currentBank
 CMP #2
 BEQ CF1E1
 PHA
 LDA #2
 JSR SetBank
 LDA L00B7
 JSR CHPR
 JMP ResetBank

.CF1E1

 LDA L00B7
 JMP CHPR

; ******************************************************************************
;
;       Name: DASC_b2
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.DASC_b2

 STA L00B7
 LDA currentBank
 CMP #2
 BEQ CF1FC
 PHA
 LDA #2
 JSR SetBank
 LDA L00B7
 JSR DASC
 JMP ResetBank

.CF1FC

 LDA L00B7
 JMP DASC

; ******************************************************************************
;
;       Name: TT27_b2
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.TT27_b2

 STA L00B7
 LDA currentBank
 CMP #2
 BEQ CF217
 PHA
 LDA #2
 JSR SetBank
 LDA L00B7
 JSR TT27
 JMP ResetBank

.CF217

 LDA L00B7
 JMP TT27

; ******************************************************************************
;
;       Name: ex_b2
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.ex_b2

 STA L00B7
 LDA currentBank
 CMP #2
 BEQ CF232
 PHA
 LDA #2
 JSR SetBank
 LDA L00B7
 JSR ex
 JMP ResetBank

.CF232

 LDA L00B7
 JMP ex

; ******************************************************************************
;
;       Name: TT27_b0
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.TT27_b0

 LDA currentBank
 PHA
 LDA #0
 JSR SetBank
 JSR TT27_0
 JMP ResetBank

; ******************************************************************************
;
;       Name: BR1_b0
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.BR1_b0

 LDA currentBank
 CMP #0
 BEQ CF257
 PHA
 LDA #0
 JSR SetBank
 JSR BR1
 JMP ResetBank

.CF257

 JMP BR1

; ******************************************************************************
;
;       Name: subm_F25A
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.subm_F25A

 LDA #0
 LDY #$21
 STA (XX19),Y

; ******************************************************************************
;
;       Name: CBAF3_b1
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.CBAF3_b1

 LDA currentBank
 PHA
 LDA #1
 JSR SetBank
 JSR subm_BAF3
 JMP ResetBank

; ******************************************************************************
;
;       Name: TT66_b0
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.TT66_b0

 STA L00B7
 LDA currentBank
 PHA
 LDA #0
 JSR SetBank
 LDA L00B7
 JSR TT66
 JMP ResetBank

; ******************************************************************************
;
;       Name: CLIP_b1
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.CLIP_b1

 LDA currentBank
 PHA
 LDA #1
 JSR SetBank
 JSR CLIP
 BCS CF290
 JSR LOIN

.CF290

 JMP ResetBank

; ******************************************************************************
;
;       Name: ClearTiles_b3
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.ClearTiles_b3

 LDA currentBank
 CMP #3
 BEQ CF2A5
 PHA
 LDA #3
 JSR SetBank
 JSR ClearTiles
 JMP ResetBank

.CF2A5

 JMP ClearTiles

; ******************************************************************************
;
;       Name: SCAN_b1
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.SCAN_b1

 LDA currentBank
 CMP #1
 BEQ CF2BA
 PHA
 LDA #1
 JSR SetBank
 JSR SCAN
 JMP ResetBank

.CF2BA

 JMP SCAN

; ******************************************************************************
;
;       Name: subm_F2BD
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.subm_F2BD

 JSR subm_EB86

; ******************************************************************************
;
;       Name: C8926_b0
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.C8926_b0

 LDA currentBank
 PHA
 LDA #0
 JSR SetBank
 JSR subm_8926
 JMP ResetBank

; ******************************************************************************
;
;       Name: subm_F2CE
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.subm_F2CE

 LDA #0
 JSR SetBank
 JSR CopyNametable0To1
 JSR subm_F126
 LDX #1
 STX palettePhase
 RTS

; ******************************************************************************
;
;       Name: CLYNS
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ------------------------------------------------------------------------------
;
; Other entry points:
;
;   CLYNS+8             Don't zero L0393 and L0394
;
; ******************************************************************************

.CLYNS

 LDA #0
 STA L0393
 STA L0394

 LDA #$FF
 STA DTW2
 LDA #$80
 STA QQ17
 LDA #$16
 STA YC
 LDA #1
 STA XC
 LDA L00D2
 STA tileNumber
 LDA QQ11
 BPL CF332
 LDA #$72
 STA SC+1
 LDA #$E0
 STA SC
 LDA #$76
 STA SC2+1
 LDA #$E0
 STA SC2
 LDX #2

.loop_CF311

 JSR SetupPPUForIconBar ; If the PPU has started drawing the icon bar, configure
                        ; the PPU to use nametable 0 and pattern table 0

 LDY #2
 LDA #0

.loop_CF318

 STA (SC),Y
 STA (SC2),Y
 INY
 CPY #$1F
 BNE loop_CF318
 LDA SC
 ADC #$1F
 STA SC
 STA SC2
 BCC CF32F
 INC SC+1
 INC SC2+1

.CF32F

 DEX
 BNE loop_CF311

.CF332

 RTS

; ******************************************************************************
;
;       Name: LF333
;       Type: Variable
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.LF333

 EQUB $1C, $1A, $28, $16,   6                 ; F333: 1C 1A 28... ..(

; ******************************************************************************
;
;       Name: GetStatusCondition
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.GetStatusCondition

 LDX #0
 LDY QQ12
 BNE CF355
 INX
 LDY JUNK
 LDA FRIN+2,Y
 BEQ CF355
 INX
 LDY L0472
 CPY #3
 BEQ subm_F359
 LDA ENERGY
 BMI CF355

.loop_CF354

 INX

.CF355

 STX L0472
 RTS

; ******************************************************************************
;
;       Name: subm_F359
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.subm_F359

 LDA ENERGY
 CMP #$A0
 BCC loop_CF354
 BCS CF355

; ******************************************************************************
;
;       Name: subm_F362
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.subm_F362

 LDY #$0C
 JSR DELAY
 LDA #0
 CLC
 ADC #0
 STA frameCounter
 STA nmiTimer
 STA nmiTimerLo
 STA nmiTimerHi
 STA palettePhase
 STA otherPhase
 STA drawingPhase
 LDA #$FF
 STA L0307
 LDA #$80
 STA L0308
 LDA #$1B
 STA L0309
 LDA #$34
 STA L030A
 JSR subm_F3AB
 LDA #0
 STA K%+6
 STA K%

; ******************************************************************************
;
;       Name: subm_F39A
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.subm_F39A

 LDA #$75
 STA RAND
 LDA #$0A
 STA RAND+1
 LDA #$2A
 STA RAND+2
 LDX #$E6
 STX RAND+3
 RTS

; ******************************************************************************
;
;       Name: subm_F3AB
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.subm_F3AB

 LDA #0
 STA L03EB
 STA L03ED
 LDA #$FF
 STA L03EA
 STA L03EC
 RTS

; ******************************************************************************
;
;       Name: subm_F3BC
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.subm_F3BC

 JSR CB63D_b3
 LDA #0
 JSR C8021_b6
 JSR subm_EB8F
 LDA #$FF
 STA QQ11a
 LDA #1
 STA scanController2
 LDA #$32
 STA nmiTimer
 LDA #0
 STA nmiTimerLo
 STA nmiTimerHi

.loop_CF3DA

 LDY #0

.loop_CF3DC

 STY L03FC
 LDA LF415,Y
 BEQ loop_CF3DA
 TAX
 LDA LF422,Y
 TAY
 LDA #6
 JSR subm_B3BC
 BCS CF411
 LDY L03FC
 INY
 LDA nmiTimerHi
 CMP #1
 BCC loop_CF3DC
 LSR scanController2
 JSR WaitResetSound
 JSR CB63D_b3
 LDA language
 STA K%
 LDA #5
 STA K%+1
 JMP CC035

.CF411

 JSR WaitResetSound
 RTS

; ******************************************************************************
;
;       Name: LF415
;       Type: Variable
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.LF415

 EQUB $0B, $13, $14, $19, $1D, $15, $12, $1B  ; F415: 0B 13 14... ...
 EQUB $0A,   1, $11, $10,   0                 ; F41D: 0A 01 11... ...

; ******************************************************************************
;
;       Name: LF422
;       Type: Variable
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.LF422

 EQUB $64, $0A, $0A, $1E, $B4, $0A, $28, $5A  ; F422: 64 0A 0A... d..
 EQUB $0A, $46, $28, $0A

; ******************************************************************************
;
;       Name: Ze
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.Ze

 JSR ZINF_0
 JSR DORND
 STA T1
 AND #$80
 STA INWK+2
 JSR DORND
 AND #$80
 STA INWK+5
 LDA #$19
 STA INWK+1
 STA INWK+4
 STA INWK+7
 TXA
 CMP #$F5
 ROL A
 ORA #$C0
 STA INWK+32
 JMP DORND2

; ******************************************************************************
;
;       Name: subm_F454
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.subm_F454

 PHA
 LDA NAME+7
 BMI CF463
 CLC
 ADC #1
 CMP #$64
 BCC CF463
 LDA #0

.CF463

 ORA #$80
 STA NAME+7
 PLA
 RTS

; ******************************************************************************
;
;       Name: NLIN3
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.NLIN3

 PHA
 LDA #0
 STA YC
 PLA
 JSR TT27_b2

; ******************************************************************************
;
;       Name: NLIN4
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.NLIN4

 LDA #4
 BNE subm_F47D
 LDA #1
 STA YC
 LDA #4

; ******************************************************************************
;
;       Name: subm_F47D
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.subm_F47D

 JSR SetupPPUForIconBar ; If the PPU has started drawing the icon bar, configure
                        ; the PPU to use nametable 0 and pattern table 0

 LDY #1
 LDA #3

.loop_CF484

 STA nameBuffer0+64,Y
 INY
 CPY #$20
 BNE loop_CF484
 RTS

; ******************************************************************************
;
;       Name: subm_F48D
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.subm_F48D

 LDX #0
 JSR subm_D8EC
 RTS

; ******************************************************************************
;
;       Name: subm_F493
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.subm_F493

 LDA #$60
 STA SC2+1
 LDA #0
 STA SC2
 LDY #0
 LDX #$18
 LDA #0

.CF4A1

 STA (SC2),Y
 INY
 BNE CF4A1
 INC SC2+1
 DEX
 BNE CF4A1
 RTS

; ******************************************************************************
;
;       Name: DORND2
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.DORND2

 CLC

; ******************************************************************************
;
;       Name: DORND
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.DORND

 LDA RAND
 ROL A
 TAX
 ADC RAND+2
 STA RAND
 STX RAND+2
 LDA RAND+1
 TAX
 ADC RAND+3
 STA RAND+1
 STX RAND+3
 RTS

; ******************************************************************************
;
;       Name: PROJ
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.PROJ

 LDA XX1
 STA P
 LDA INWK+1
 STA P+1
 LDA INWK+2
 JSR subm_F4FB
 BCS CF4F8
 LDA K
 ADC #$80
 STA K3
 TXA
 ADC #0
 STA XX2+1
 LDA INWK+3
 STA P
 LDA INWK+4
 STA P+1
 LDA INWK+5
 EOR #$80
 JSR subm_F4FB
 BCS CF4F8
 LDA K
 ADC Yx1M2
 STA K4
 TXA
 ADC #0
 STA K4+1
 CLC

.CF4F8

 RTS

; ******************************************************************************
;
;       Name: subm_F4FB
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.CF4F9

 SEC
 RTS

.subm_F4FB

 JSR DVID3B2

 SETUP_PPU_FOR_ICON_BAR ; If the PPU has started drawing the icon bar, configure
                        ; the PPU to use nametable 0 and pattern table 0

 LDA K+3
 AND #$7F
 ORA K+2
 BNE CF4F9
 LDX K+1
 CPX #4
 BCS CF52C
 LDA K+3
 BPL CF52C
 LDA K
 EOR #$FF
 ADC #1
 STA K
 TXA
 EOR #$FF
 ADC #0
 TAX
 CLC

.CF52C

 RTS

; ******************************************************************************
;
;       Name: UnpackToRAM
;       Type: Subroutine
;   Category: ???
;    Summary: Unpack compressed image data to RAM
;
; ------------------------------------------------------------------------------
;
; UnpackToRAM copies data from V(1 0) to SC(1 0)
; Fetch byte from V(1 0) and increment V(1 0), say byte is $xx
;   >= $40 store byte as is and move on to next
;   = $x0 store byte as is and move on to next
;   = $3F stop and return from subroutine - end of decompression
;   >= $20, jump to CF572
;           >= $30 jump to CF589 to copy next $0x bytes from V(1 0) as they
;                  are, incrementing V(1 0) as we go
;           >= $20 fetch next byte and store it for $0x bytes
;   >= $10, jump to CF56E to store $FF for $0x bytes
;   < $10, store 0 for $0x bytes
; 
; $00 = unchanged
; $0x = store 0 for $0x bytes
; $10 = unchanged
; $1x = store $FF for $0x bytes
; $20 = unchanged
; $2x = store next byte for $0x bytes
; $30 = unchanged
; $3x = store next $0x bytes unchanged
; $40 and above = unchanged
;
; ******************************************************************************

.UnpackToRAM

 LDY #0

.CF52F

 SETUP_PPU_FOR_ICON_BAR ; If the PPU has started drawing the icon bar, configure
                        ; the PPU to use nametable 0 and pattern table 0

 LDX #0
 LDA (V,X)
 INC V
 BNE CF546
 INC V+1

.CF546

 CMP #$40
 BCS CF5A4
 TAX
 AND #$0F
 BEQ CF5A3
 CPX #$3F
 BEQ CF5AE
 TXA
 CMP #$20
 BCS CF572
 CMP #$10
 AND #$0F
 TAX
 BCS CF56E
 LDA #0

.CF561

 STA (SC),Y
 INY
 BNE CF568
 INC SC+1

.CF568

 DEX
 BNE CF561
 JMP CF52F

.CF56E

 LDA #$FF
 BNE CF561

.CF572

 LDX #0
 CMP #$30
 BCS CF589
 AND #$0F
 STA T
 LDA (V,X)
 LDX T
 INC V
 BNE CF561
 INC V+1
 JMP CF561

.CF589

 AND #$0F
 STA T

.loop_CF58D

 LDA (V,X)
 INC V
 BNE CF595
 INC V+1

.CF595

 STA (SC),Y
 INY
 BNE CF59C
 INC SC+1

.CF59C

 DEC T
 BNE loop_CF58D
 JMP CF52F

.CF5A3

 TXA

.CF5A4

 STA (SC),Y
 INY
 BNE CF52F
 INC SC+1
 JMP CF52F

.CF5AE

 RTS

; ******************************************************************************
;
;       Name: UnpackToPPU
;       Type: Subroutine
;   Category: ???
;    Summary: Unpack compressed image data and send it to the PPU
;
; ******************************************************************************

.UnpackToPPU

 LDY #0

.CF5B1

 LDA (V),Y
 INY
 BNE CF5B8
 INC V+1

.CF5B8

 CMP #$40
 BCS CF605
 TAX
 AND #$0F
 BEQ CF604
 CPX #$3F
 BEQ CF60B
 TXA
 CMP #$20
 BCS CF5E0
 CMP #$10
 AND #$0F
 TAX
 BCS CF5DC
 LDA #0

.CF5D3

 STA PPU_DATA
 DEX
 BNE CF5D3
 JMP CF5B1

.CF5DC

 LDA #$FF
 BNE CF5D3

.CF5E0

 CMP #$30
 BCS CF5F1
 AND #$0F
 TAX
 LDA (V),Y
 INY
 BNE CF5D3
 INC V+1
 JMP CF5D3

.CF5F1

 AND #$0F
 TAX

.loop_CF5F4

 LDA (V),Y
 INY
 BNE CF5FB
 INC V+1

.CF5FB

 STA PPU_DATA
 DEX
 BNE loop_CF5F4
 JMP CF5B1

.CF604

 TXA

.CF605

 STA PPU_DATA
 JMP CF5B1

.CF60B

 RTS

; ******************************************************************************
;
;       Name: FAROF2
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.FAROF2

 STA T

 SETUP_PPU_FOR_ICON_BAR ; If the PPU has started drawing the icon bar, configure
                        ; the PPU to use nametable 0 and pattern table 0

 LDA INWK+2
 ORA INWK+5
 ORA INWK+8
 ASL A
 BNE CF658
 LDA INWK+7
 LSR A
 STA K+2
 LDA INWK+1
 LSR A
 STA K
 LDA INWK+4
 LSR A
 STA K+1
 CMP K
 BCS CF639
 LDA K

.CF639

 CMP K+2
 BCS CF63F
 LDA K+2

.CF63F

 STA SC
 LDA K
 CLC
 ADC K+1
 ADC K+2
 SEC
 SBC SC
 LSR A
 LSR A
 STA SC+1
 LSR A
 LSR A
 ADC SC+1
 ADC SC
 CMP T
 RTS

.CF658

 SEC
 RTS

; ******************************************************************************
;
;       Name: MU5
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.MU5

 STA K
 STA K+1
 STA K+2
 STA K+3
 CLC
 RTS

; ******************************************************************************
;
;       Name: MULT3
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.MULT3

 STA R
 AND #$7F
 STA K+2
 LDA Q
 AND #$7F
 BEQ MU5
 SEC
 SBC #1
 STA T
 LDA P+1
 LSR K+2
 ROR A
 STA K+1
 LDA P
 ROR A
 STA K

 SETUP_PPU_FOR_ICON_BAR ; If the PPU has started drawing the icon bar, configure
                        ; the PPU to use nametable 0 and pattern table 0

 LDA #0
 LDX #$18

.loop_CF692

 BCC CF696
 ADC T

.CF696

 ROR A
 ROR K+2
 ROR K+1
 ROR K
 DEX
 BNE loop_CF692
 STA T

 SETUP_PPU_FOR_ICON_BAR ; If the PPU has started drawing the icon bar, configure
                        ; the PPU to use nametable 0 and pattern table 0

 LDA R
 EOR Q
 AND #$80
 ORA T
 STA K+3
 RTS

; ******************************************************************************
;
;       Name: MLS2
;       Type: Subroutine
;   Category: Maths (Arithmetic)
;    Summary: Calculate (S R) = XX(1 0) and (A P) = A * ALP1
;
; ------------------------------------------------------------------------------
;
; Calculate the following:
;
;   (S R) = XX(1 0)
;
;   (A P) = A * ALP1
;
; where ALP1 is the magnitude of the current roll angle alpha, in the range
; 0-31.
;
; ******************************************************************************

.MLS2

 LDX XX                 ; Set (S R) = XX(1 0), starting with the low bytes
 STX R

 LDX XX+1               ; And then doing the high bytes
 STX S

                        ; Fall through into MLS1 to calculate (A P) = A * ALP1

; ******************************************************************************
;
;       Name: MLS1
;       Type: Subroutine
;   Category: Maths (Arithmetic)
;    Summary: Calculate (A P) = ALP1 * A
;
; ------------------------------------------------------------------------------
;
; Calculate the following:
;
;   (A P) = ALP1 * A
;
; where ALP1 is the magnitude of the current roll angle alpha, in the range
; 0-31.
;
; This routine uses an unrolled version of MU11. MU11 calculates P * X, so we
; use the same algorithm but with P set to ALP1 and X set to A. The unrolled
; version here can skip the bit tests for bits 5-7 of P as we know P < 32, so
; only 5 shifts with bit tests are needed (for bits 0-4), while the other 3
; shifts can be done without a test (for bits 5-7).
;
; Other entry points:
;
;   MULTS-2             Calculate (A P) = X * A
;
; ******************************************************************************

.MLS1

 LDX ALP1               ; Set P to the roll angle alpha magnitude in ALP1
 STX P                  ; (0-31), so now we calculate P * A

.MULTS

 TAX                    ; Set X = A, so now we can calculate P * X instead of
                        ; P * A to get our result, and we can use the algorithm
                        ; from MU11 to do that, just unrolled (as MU11 returns
                        ; P * X)

 AND #%10000000         ; Set T to the sign bit of A
 STA T

 TXA                    ; Set A = |A|
 AND #127

 BEQ MU6                ; If A = 0, jump to MU6 to set P(1 0) = 0 and return
                        ; from the subroutine using a tail call

 TAX                    ; Set T1 = X - 1
 DEX                    ;
 STX T1                 ; We subtract 1 as the C flag will be set when we want
                        ; to do an addition in the loop below

 LDA #0                 ; Set A = 0 so we can start building the answer in A

 LSR P                  ; Set P = P >> 1
                        ; and C flag = bit 0 of P

                        ; We are now going to work our way through the bits of
                        ; P, and do a shift-add for any bits that are set,
                        ; keeping the running total in A, but instead of using a
                        ; loop like MU11, we just unroll it, starting with bit 0

 BCC P%+4               ; If C (i.e. the next bit from P) is set, do the
 ADC T1                 ; addition for this bit of P:
                        ;
                        ;   A = A + T1 + C
                        ;     = A + X - 1 + 1
                        ;     = A + X

 ROR A                  ; Shift A right to catch the next digit of our result,
                        ; which the next ROR sticks into the left end of P while
                        ; also extracting the next bit of P

 ROR P                  ; Add the overspill from shifting A to the right onto
                        ; the start of P, and shift P right to fetch the next
                        ; bit for the calculation into the C flag

 BCC P%+4               ; Repeat the shift-and-add loop for bit 1
 ADC T1
 ROR A
 ROR P

 BCC P%+4               ; Repeat the shift-and-add loop for bit 2
 ADC T1
 ROR A
 ROR P

 BCC P%+4               ; Repeat the shift-and-add loop for bit 3
 ADC T1
 ROR A
 ROR P

 BCC P%+4               ; Repeat the shift-and-add loop for bit 4
 ADC T1
 ROR A
 ROR P

 LSR A                  ; Just do the "shift" part for bit 5
 ROR P

 LSR A                  ; Just do the "shift" part for bit 6
 ROR P

 LSR A                  ; Just do the "shift" part for bit 7
 ROR P

 ORA T                  ; Give A the sign bit of the original argument A that
                        ; we put into T above

 RTS                    ; Return from the subroutine

; ******************************************************************************
;
;       Name: MU6
;       Type: Subroutine
;   Category: Maths (Arithmetic)
;    Summary: Set P(1 0) = (A A)
;
; ------------------------------------------------------------------------------
;
; In practice this is only called via a BEQ following an AND instruction, in
; which case A = 0, so this routine effectively does this:
;
;   P(1 0) = 0
;
; ******************************************************************************

.MU6

 STA P+1                ; Set P(1 0) = (A A)
 STA P

 RTS                    ; Return from the subroutine

; ******************************************************************************
;
;       Name: SQUA
;       Type: Subroutine
;   Category: Maths (Arithmetic)
;    Summary: Clear bit 7 of A and calculate (A P) = A * A
;
; ------------------------------------------------------------------------------
;
; Do the following multiplication of unsigned 8-bit numbers, after first
; clearing bit 7 of A:
;
;   (A P) = A * A
;
; ******************************************************************************

.SQUA

 AND #%01111111         ; Clear bit 7 of A and fall through into SQUA2 to set
                        ; (A P) = A * A

; ******************************************************************************
;
;       Name: SQUA2
;       Type: Subroutine
;   Category: Maths (Arithmetic)
;    Summary: Calculate (A P) = A * A
;
; ------------------------------------------------------------------------------
;
; Do the following multiplication of unsigned 8-bit numbers:
;
;   (A P) = A * A
;
; ******************************************************************************

.SQUA2

 STA P                  ; Copy A into P and X
 TAX

 BNE MU11               ; If X = 0 fall through into MU1 to return a 0,
                        ; otherwise jump to MU11 to return P * X

; ******************************************************************************
;
;       Name: MU1
;       Type: Subroutine
;   Category: Maths (Arithmetic)
;    Summary: Copy X into P and A, and clear the C flag
;
; ------------------------------------------------------------------------------
;
; Used to return a 0 result quickly from MULTU below.
;
; ******************************************************************************

.MU1

 CLC                    ; Clear the C flag

 STX P                  ; Copy X into P and A
 TXA

 RTS                    ; Return from the subroutine

; ******************************************************************************
;
;       Name: MLU1
;       Type: Subroutine
;   Category: Maths (Arithmetic)
;    Summary: Calculate Y1 = y_hi and (A P) = |y_hi| * Q for Y-th stardust
;
; ------------------------------------------------------------------------------
;
; Do the following assignment, and multiply the Y-th stardust particle's
; y-coordinate with an unsigned number Q:
;
;   Y1 = y_hi
;
;   (A P) = |y_hi| * Q
;
; ******************************************************************************

.MLU1

 LDA SY,Y               ; Set Y1 the Y-th byte of SY
 STA Y1

                        ; Fall through into MLU2 to calculate:
                        ;
                        ;   (A P) = |A| * Q

; ******************************************************************************
;
;       Name: MLU2
;       Type: Subroutine
;   Category: Maths (Arithmetic)
;    Summary: Calculate (A P) = |A| * Q
;
; ------------------------------------------------------------------------------
;
; Do the following multiplication of a sign-magnitude 8-bit number P with an
; unsigned number Q:
;
;   (A P) = |A| * Q
;
; ******************************************************************************

.MLU2

 AND #%01111111         ; Clear the sign bit in P, so P = |A|
 STA P

                        ; Fall through into MULTU to calculate:
                        ;
                        ;   (A P) = P * Q
                        ;         = |A| * Q

; ******************************************************************************
;
;       Name: MULTU
;       Type: Subroutine
;   Category: Maths (Arithmetic)
;    Summary: Calculate (A P) = P * Q
;
; ------------------------------------------------------------------------------
;
; Do the following multiplication of unsigned 8-bit numbers:
;
;   (A P) = P * Q
;
; ******************************************************************************

.MULTU

 LDX Q                  ; Set X = Q

 BEQ MU1                ; If X = Q = 0, jump to MU1 to copy X into P and A,
                        ; clear the C flag and return from the subroutine using
                        ; a tail call

                        ; Otherwise fall through into MU11 to set (A P) = P * X

; ******************************************************************************
;
;       Name: MU11
;       Type: Subroutine
;   Category: Maths (Arithmetic)
;    Summary: Calculate (A P) = P * X
;  Deep dive: Shift-and-add multiplication
;
; ------------------------------------------------------------------------------
;
; Do the following multiplication of two unsigned 8-bit numbers:
;
;   (A P) = P * X
;
; This uses the same shift-and-add approach as MULT1, but it's simpler as we
; are dealing with unsigned numbers in P and X. See the deep dive on
; "Shift-and-add multiplication" for a discussion of how this algorithm works.
;
; ******************************************************************************

.MU11

 DEX                    ; Set T = X - 1
 STX T                  ;
                        ; We subtract 1 as the C flag will be set when we want
                        ; to do an addition in the loop below

 LDA #0                 ; Set A = 0 so we can start building the answer in A

;LDX #8                 ; This instruction is commented out in the original
                        ; source

 TAX                    ; Copy A into X. There is a comment in the original
                        ; source here that says "just in case", which refers to
                        ; the MU11 routine in the cassette and disc versions,
                        ; which set X to 0 (as they use X as a loop counter).
                        ; The version here doesn't use a loop, but this
                        ; instruction makes sure the unrolled version returns
                        ; the same results as the loop versions, just in case
                        ; something out there relies on MU11 returning X = 0

 LSR P                  ; Set P = P >> 1
                        ; and C flag = bit 0 of P

                        ; We now repeat the following four instruction block
                        ; eight times, one for each bit in P. In the cassette
                        ; and disc versions of Elite the following is done with
                        ; a loop, but it is marginally faster to unroll the loop
                        ; and have eight copies of the code, though it does take
                        ; up a bit more memory (though that isn't a concern when
                        ; you have a 6502 Second Processor)

 BCC P%+4               ; If C (i.e. bit 0 of P) is set, do the
 ADC T                  ; addition for this bit of P:
                        ;
                        ;   A = A + T + C
                        ;     = A + X - 1 + 1
                        ;     = A + X

 ROR A                  ; Shift A right to catch the next digit of our result,
                        ; which the next ROR sticks into the left end of P while
                        ; also extracting the next bit of P

 ROR P                  ; Add the overspill from shifting A to the right onto
                        ; the start of P, and shift P right to fetch the next
                        ; bit for the calculation into the C flag

 BCC P%+4               ; Repeat for the second time
 ADC T
 ROR A
 ROR P

 BCC P%+4               ; Repeat for the third time
 ADC T
 ROR A
 ROR P

 BCC P%+4               ; Repeat for the fourth time
 ADC T
 ROR A
 ROR P

 BCC P%+4               ; Repeat for the fifth time
 ADC T
 ROR A
 ROR P

 BCC P%+4               ; Repeat for the sixth time
 ADC T
 ROR A
 ROR P

 BCC P%+4               ; Repeat for the seventh time
 ADC T
 ROR A
 ROR P

 BCC P%+4               ; Repeat for the eighth time
 ADC T
 ROR A
 ROR P

 RTS                    ; Return from the subroutine

; ******************************************************************************
;
;       Name: FMLTU2
;       Type: Subroutine
;   Category: Maths (Arithmetic)
;    Summary: Calculate A = K * sin(A)
;  Deep dive: The sine, cosine and arctan tables
;
; ------------------------------------------------------------------------------
;
; Calculate the following:
;
;   A = K * sin(A)
;
; Because this routine uses the sine lookup table SNE, we can also call this
; routine to calculate cosine multiplication. To calculate the following:
;
;   A = K * cos(B)
;
; call this routine with B + 16 in the accumulator, as sin(B + 16) = cos(B).
;
; ******************************************************************************

.FMLTU2

 AND #%00011111         ; Restrict A to bits 0-5 (so it's in the range 0-31)

 TAX                    ; Set Q = sin(A) * 256
 LDA SNE,X
 STA Q

 LDA K                  ; Set A to the radius in K

                        ; Fall through into FMLTU to do the following:
                        ;
                        ;   (A ?) = A * Q
                        ;         = K * sin(A) * 256
                        ;
                        ; which is equivalent to:
                        ;
                        ;   A = K * sin(A)

; ******************************************************************************
;
;       Name: FMLTU
;       Type: Subroutine
;   Category: Maths (Arithmetic)
;    Summary: Calculate A = A * Q / 256
;  Deep dive: Multiplication and division using logarithms
;
; ------------------------------------------------------------------------------
;
; Do the following multiplication of two unsigned 8-bit numbers, returning only
; the high byte of the result:
;
;   (A ?) = A * Q
;
; or, to put it another way:
;
;   A = A * Q / 256
;
; The Master and 6502 Second Processor versions use logarithms to speed up the
; multiplication process. See the deep dive on "Multiplication using logarithms"
; for more details.
;
; Returns:
;
;   C flag              The C flag is clear if A = 0, or set if we return a
;                       result from one of the log tables
;
; ******************************************************************************

.FMLTU

 STX P                  ; Store X in P so we can preserve it through the call to
                        ; FMULTU

 STA widget             ; Store A in widget, so now widget = argument A

 TAX                    ; Transfer A into X, so now X = argument A

 BEQ MU3                ; If A = 0, jump to MU3 to return a result of 0, as
                        ; 0 * Q / 256 is always 0

                        ; We now want to calculate La + Lq, first adding the low
                        ; bytes (from the logL table), and then the high bytes
                        ; (from the log table)

 LDA logL,X             ; Set A = low byte of La
                        ;       = low byte of La (as we set X to A above)

 LDX Q                  ; Set X = Q

 BEQ MU3again           ; If X = 0, jump to MU3again to return a result of 0, as
                        ; A * 0 / 256 is always 0

 CLC                    ; Set A = A + low byte of Lq
 ADC logL,X             ;       = low byte of La + low byte of Lq

 BMI oddlog             ; If A > 127, jump to oddlog

 LDA log,X              ; Set A = high byte of Lq

 LDX widget             ; Set A = A + C + high byte of La
 ADC log,X              ;       = high byte of Lq + high byte of La + C
                        ;
                        ; so we now have:
                        ;
                        ;   A = high byte of (La + Lq)

 BCC MU3again           ; If the addition fitted into one byte and didn't carry,
                        ; then La + Lq < 256, so we jump to MU3again to return a
                        ; result of 0 and the C flag clear

                        ; If we get here then the C flag is set, ready for when
                        ; we return from the subroutine below

 TAX                    ; Otherwise La + Lq >= 256, so we return the A-th entry
 LDA antilog,X          ; from the antilog table

 LDX P                  ; Restore X from P so it is preserved

 RTS                    ; Return from the subroutine

.oddlog

 LDA log,X              ; Set A = high byte of Lq

 LDX widget             ; Set A = A + C + high byte of La
 ADC log,X              ;       = high byte of Lq + high byte of La + C
                        ;
                        ; so we now have:
                        ;
                        ;   A = high byte of (La + Lq)

 BCC MU3again           ; If the addition fitted into one byte and didn't carry,
                        ; then La + Lq < 256, so we jump to MU3again to return a
                        ; result of 0 and the C flag clear

                        ; If we get here then the C flag is set, ready for when
                        ; we return from the subroutine below

 TAX                    ; Otherwise La + Lq >= 256, so we return the A-th entry
 LDA antilogODD,X       ; from the antilogODD table

.MU3

                        ; If we get here then A (our result) is already 0

 LDX P                  ; Restore X from P so it is preserved

 RTS                    ; Return from the subroutine

.MU3again

 LDA #0                 ; Set A = 0

 LDX P                  ; Restore X from P so it is preserved

 RTS                    ; Return from the subroutine

; ******************************************************************************
;
;       Name: MLTU2
;       Type: Subroutine
;   Category: Maths (Arithmetic)
;    Summary: Calculate (A P+1 P) = (A ~P) * Q
;  Deep dive: Shift-and-add multiplication
;
; ------------------------------------------------------------------------------
;
; Do the following multiplication of an unsigned 16-bit number and an unsigned
; 8-bit number:
;
;   (A P+1 P) = (A ~P) * Q
;
; where ~P means P EOR %11111111 (i.e. P with all its bits flipped). In other
; words, if you wanted to calculate $1234 * $56, you would:
;
;   * Set A to $12
;   * Set P to $34 EOR %11111111 = $CB
;   * Set Q to $56
;
; before calling MLTU2.
;
; This routine is like a mash-up of MU11 and FMLTU. It uses part of FMLTU's
; inverted argument trick to work out whether or not to do an addition, and like
; MU11 it sets up a counter in X to extract bits from (P+1 P). But this time we
; extract 16 bits from (P+1 P), so the result is a 24-bit number. The core of
; the algorithm is still the shift-and-add approach explained in MULT1, just
; with more bits.
;
; Returns:
;
;   Q                   Q is preserved
;
; Other entry points:
;
;   MLTU2-2             Set Q to X, so this calculates (A P+1 P) = (A ~P) * X
;
; ******************************************************************************

 STX Q                  ; Store X in Q

.MLTU2

 EOR #%11111111         ; Flip the bits in A and rotate right, storing the
 LSR A                  ; result in P+1, so we now calculate (P+1 P) * Q
 STA P+1

 LDA #0                 ; Set A = 0 so we can start building the answer in A

 LDX #16                ; Set up a counter in X to count the 16 bits in (P+1 P)

 ROR P                  ; Set P = P >> 1 with bit 7 = bit 0 of A
                        ; and C flag = bit 0 of P

.MUL7

 BCS MU21               ; If C (i.e. the next bit from P) is set, do not do the
                        ; addition for this bit of P, and instead skip to MU21
                        ; to just do the shifts

 ADC Q                  ; Do the addition for this bit of P:
                        ;
                        ;   A = A + Q + C
                        ;     = A + Q

 ROR A                  ; Rotate (A P+1 P) to the right, so we capture the next
 ROR P+1                ; digit of the result in P+1, and extract the next digit
 ROR P                  ; of (P+1 P) in the C flag

 DEX                    ; Decrement the loop counter

 BNE MUL7               ; Loop back for the next bit until P has been rotated
                        ; all the way

 RTS                    ; Return from the subroutine

.MU21

 LSR A                  ; Shift (A P+1 P) to the right, so we capture the next
 ROR P+1                ; digit of the result in P+1, and extract the next digit
 ROR P                  ; of (P+1 P) in the C flag

 DEX                    ; Decrement the loop counter

 BNE MUL7               ; Loop back for the next bit until P has been rotated
                        ; all the way

 RTS                    ; Return from the subroutine

; ******************************************************************************
;
;       Name: MUT3
;       Type: Subroutine
;   Category: Maths (Arithmetic)
;    Summary: Unused routine that does the same as MUT2
;
; ------------------------------------------------------------------------------
;
; This routine is never actually called, but it is identical to MUT2, as the
; extra instructions have no effect.
;
; ******************************************************************************

.MUT3

 LDX ALP1               ; Set P = ALP1, though this gets overwritten by the
 STX P                  ; following, so this has no effect

                        ; Fall through into MUT2 to do the following:
                        ;
                        ;   (S R) = XX(1 0)
                        ;   (A P) = Q * A

; ******************************************************************************
;
;       Name: MUT2
;       Type: Subroutine
;   Category: Maths (Arithmetic)
;    Summary: Calculate (S R) = XX(1 0) and (A P) = Q * A
;
; ------------------------------------------------------------------------------
;
; Do the following assignment, and multiplication of two signed 8-bit numbers:
;
;   (S R) = XX(1 0)
;   (A P) = Q * A
;
; ******************************************************************************

.MUT2

 LDX XX+1               ; Set S = XX+1
 STX S

                        ; Fall through into MUT1 to do the following:
                        ;
                        ;   R = XX
                        ;   (A P) = Q * A

; ******************************************************************************
;
;       Name: MUT1
;       Type: Subroutine
;   Category: Maths (Arithmetic)
;    Summary: Calculate R = XX and (A P) = Q * A
;
; ------------------------------------------------------------------------------
;
; Do the following assignment, and multiplication of two signed 8-bit numbers:
;
;   R = XX
;   (A P) = Q * A
;
; ******************************************************************************

.MUT1

 LDX XX                 ; Set R = XX
 STX R

                        ; Fall through into MULT1 to do the following:
                        ;
                        ;   (A P) = Q * A

; ******************************************************************************
;
;       Name: MULT1
;       Type: Subroutine
;   Category: Maths (Arithmetic)
;    Summary: Calculate (A P) = Q * A
;  Deep dive: Shift-and-add multiplication
;
; ------------------------------------------------------------------------------
;
; Do the following multiplication of two 8-bit sign-magnitude numbers:
;
;   (A P) = Q * A
;
; ******************************************************************************

.MULT1

 TAX                    ; Store A in X

 SETUP_PPU_FOR_ICON_BAR ; If the PPU has started drawing the icon bar, configure
                        ; the PPU to use nametable 0 and pattern table 0

 TXA                    ; ???

 AND #%01111111         ; Set P = |A| >> 1
 LSR A                  ; and C flag = bit 0 of A
 STA P

 TXA                    ; Restore argument A

 EOR Q                  ; Set bit 7 of A and T if Q and A have different signs,
 AND #%10000000         ; clear bit 7 if they have the same signs, 0 all other
 STA T                  ; bits, i.e. T contains the sign bit of Q * A

 LDA Q                  ; Set A = |Q|
 AND #%01111111

 BEQ mu10               ; If |Q| = 0 jump to mu10 (with A set to 0)

 TAX                    ; Set T1 = |Q| - 1
 DEX                    ;
 STX T1                 ; We subtract 1 as the C flag will be set when we want
                        ; to do an addition in the loop below

                        ; We are now going to work our way through the bits of
                        ; P, and do a shift-add for any bits that are set,
                        ; keeping the running total in A. We already set up
                        ; the first shift at the start of this routine, as
                        ; P = |A| >> 1 and C = bit 0 of A, so we now need to set
                        ; up a loop to sift through the other 7 bits in P

 LDA #0                 ; Set A = 0 so we can start building the answer in A

 TAX                    ; Copy A into X, to make sure the unrolled version
                        ; returns the same results as the loop versions, just
                        ; in case something out there relies on MULT1 returning
                        ; X = 0

 BCC P%+4               ; If C (i.e. the next bit from P) is set, do the
 ADC T1                 ; addition for this bit of P:
                        ;
                        ;   A = A + T1 + C
                        ;     = A + |Q| - 1 + 1
                        ;     = A + |Q|

 ROR A                  ; As mentioned above, this ROR shifts A right and
                        ; catches bit 0 in C - giving another digit for our
                        ; result - and the next ROR sticks that bit into the
                        ; left end of P while also extracting the next bit of P
                        ; for the next addition

 ROR P                  ; Add the overspill from shifting A to the right onto
                        ; the start of P, and shift P right to fetch the next
                        ; bit for the calculation

 BCC P%+4               ; Repeat for the second time
 ADC T1
 ROR A
 ROR P

 BCC P%+4               ; Repeat for the third time
 ADC T1
 ROR A
 ROR P

 BCC P%+4               ; Repeat for the fourth time
 ADC T1
 ROR A
 ROR P

 BCC P%+4               ; Repeat for the fifth time
 ADC T1
 ROR A
 ROR P

 BCC P%+4               ; Repeat for the sixth time
 ADC T1
 ROR A
 ROR P

 BCC P%+4               ; Repeat for the seventh time
 ADC T1
 ROR A
 ROR P

 LSR A                  ; Rotate (A P) once more to get the final result, as
 ROR P                  ; we only pushed 7 bits through the above process

 ORA T                  ; Set the sign bit of the result that we stored in T

 RTS                    ; Return from the subroutine

.mu10

 STA P                  ; If we get here, the result is 0 and A = 0, so set
                        ; P = 0 so (A P) = 0

 RTS                    ; Return from the subroutine

; ******************************************************************************
;
;       Name: MULT12
;       Type: Subroutine
;   Category: Maths (Arithmetic)
;    Summary: Calculate (S R) = Q * A
;
; ------------------------------------------------------------------------------
;
; Calculate:
;
;   (S R) = Q * A
;
; ******************************************************************************

.MULT12

 JSR MULT1              ; Set (A P) = Q * A

 STA S                  ; Set (S P) = (A P)
                        ;           = Q * A

 SETUP_PPU_FOR_ICON_BAR ; If the PPU has started drawing the icon bar, configure
                        ; the PPU to use nametable 0 and pattern table 0

 LDA P                  ; Set (S R) = (S P)
 STA R                  ;           = Q * A

 RTS                    ; Return from the subroutine

; ******************************************************************************
;
;       Name: TAS3
;       Type: Subroutine
;   Category: Maths (Geometry)
;    Summary: Calculate the dot product of XX15 and an orientation vector
;
; ------------------------------------------------------------------------------
;
; Calculate the dot product of the vector in XX15 and one of the orientation
; vectors, as determined by the value of Y. If vect is the orientation vector,
; we calculate this:
;
;   (A X) = vect . XX15
;         = vect_x * XX15 + vect_y * XX15+1 + vect_z * XX15+2
;
; Arguments:
;
;   Y                   The orientation vector:
;
;                         * If Y = 10, calculate nosev . XX15
;
;                         * If Y = 16, calculate roofv . XX15
;
;                         * If Y = 22, calculate sidev . XX15
;
; Returns:
;
;   (A X)               The result of the dot product
;
; ******************************************************************************

.TAS3

 LDX INWK,Y             ; Set Q = the Y-th byte of INWK, i.e. vect_x
 STX Q

 LDA XX15               ; Set A = XX15

 JSR MULT12             ; Set (S R) = Q * A
                        ;           = vect_x * XX15

 LDX INWK+2,Y           ; Set Q = the Y+2-th byte of INWK, i.e. vect_y
 STX Q

 LDA XX15+1             ; Set A = XX15+1

 JSR MAD                ; Set (A X) = Q * A + (S R)
                        ;           = vect_y * XX15+1 + vect_x * XX15

 STA S                  ; Set (S R) = (A X)
 STX R

 LDX INWK+4,Y           ; Set Q = the Y+2-th byte of INWK, i.e. vect_z
 STX Q

 LDA XX15+2             ; Set A = XX15+2

                        ; Fall through into MAD to set:
                        ;
                        ;   (A X) = Q * A + (S R)
                        ;           = vect_z * XX15+2 + vect_y * XX15+1 +
                        ;             vect_x * XX15

; ******************************************************************************
;
;       Name: MAD
;       Type: Subroutine
;   Category: Maths (Arithmetic)
;    Summary: Calculate (A X) = Q * A + (S R)
;
; ------------------------------------------------------------------------------
;
; Calculate
;
;   (A X) = Q * A + (S R)
;
; ******************************************************************************

.MAD

 JSR MULT1              ; Call MULT1 to set (A P) = Q * A

                        ; Fall through into ADD to do:
                        ;
                        ;   (A X) = (A P) + (S R)
                        ;         = Q * A + (S R)

; ******************************************************************************
;
;       Name: ADD
;       Type: Subroutine
;   Category: Maths (Arithmetic)
;    Summary: Calculate (A X) = (A P) + (S R)
;  Deep dive: Adding sign-magnitude numbers
;
; ------------------------------------------------------------------------------
;
; Add two 16-bit sign-magnitude numbers together, calculating:
;
;   (A X) = (A P) + (S R)
;
; ******************************************************************************

.ADD

 STA T1                 ; Store argument A in T1

 AND #%10000000         ; Extract the sign (bit 7) of A and store it in T
 STA T

 EOR S                  ; EOR bit 7 of A with S. If they have different bit 7s
 BMI MU8                ; (i.e. they have different signs) then bit 7 in the
                        ; EOR result will be 1, which means the EOR result is
                        ; negative. So the AND, EOR and BMI together mean "jump
                        ; to MU8 if A and S have different signs"

                        ; If we reach here, then A and S have the same sign, so
                        ; we can add them and set the sign to get the result

 LDA R                  ; Add the least significant bytes together into X:
 CLC                    ;
 ADC P                  ;   X = P + R
 TAX

 LDA S                  ; Add the most significant bytes together into A. We
 ADC T1                 ; stored the original argument A in T1 earlier, so we
                        ; can do this with:
                        ;
                        ;   A = A  + S + C
                        ;     = T1 + S + C

 ORA T                  ; If argument A was negative (and therefore S was also
                        ; negative) then make sure result A is negative by
                        ; OR-ing the result with the sign bit from argument A
                        ; (which we stored in T)

 RTS                    ; Return from the subroutine

.MU8

                        ; If we reach here, then A and S have different signs,
                        ; so we can subtract their absolute values and set the
                        ; sign to get the result

 LDA S                  ; Clear the sign (bit 7) in S and store the result in
 AND #%01111111         ; U, so U now contains |S|
 STA U

 LDA P                  ; Subtract the least significant bytes into X:
 SEC                    ;
 SBC R                  ;   X = P - R
 TAX

 LDA T1                 ; Restore the A of the argument (A P) from T1 and
 AND #%01111111         ; clear the sign (bit 7), so A now contains |A|

 SBC U                  ; Set A = |A| - |S|

                        ; At this point we have |A P| - |S R| in (A X), so we
                        ; need to check whether the subtraction above was the
                        ; the right way round (i.e. that we subtracted the
                        ; smaller absolute value from the larger absolute
                        ; value)

 BCS MU9                ; If |A| >= |S|, our subtraction was the right way
                        ; round, so jump to MU9 to set the sign

                        ; If we get here, then |A| < |S|, so our subtraction
                        ; above was the wrong way round (we actually subtracted
                        ; the larger absolute value from the smaller absolute
                        ; value). So let's subtract the result we have in (A X)
                        ; from zero, so that the subtraction is the right way
                        ; round

 STA U                  ; Store A in U

 TXA                    ; Set X = 0 - X using two's complement (to negate a
 EOR #$FF               ; number in two's complement, you can invert the bits
 ADC #1                 ; and add one - and we know the C flag is clear as we
 TAX                    ; didn't take the BCS branch above, so the ADC will do
                        ; the correct addition)

 LDA #0                 ; Set A = 0 - A, which we can do this time using a
 SBC U                  ; a subtraction with the C flag clear

 ORA #%10000000         ; We now set the sign bit of A, so that the EOR on the
                        ; next line will give the result the opposite sign to
                        ; argument A (as T contains the sign bit of argument
                        ; A). This is the same as giving the result the same
                        ; sign as argument S (as A and S have different signs),
                        ; which is what we want, as S has the larger absolute
                        ; value

.MU9

 EOR T                  ; If we get here from the BCS above, then |A| >= |S|,
                        ; so we want to give the result the same sign as
                        ; argument A, so if argument A was negative, we flip
                        ; the sign of the result with an EOR (to make it
                        ; negative)

 RTS                    ; Return from the subroutine

; ******************************************************************************
;
;       Name: TIS1
;       Type: Subroutine
;   Category: Maths (Arithmetic)
;    Summary: Calculate (A ?) = (-X * A + (S R)) / 96
;  Deep dive: Shift-and-subtract division
;
; ------------------------------------------------------------------------------
;
; Calculate the following expression between sign-magnitude numbers, ignoring
; the low byte of the result:
;
;   (A ?) = (-X * A + (S R)) / 96
;
; This uses the same shift-and-subtract algorithm as TIS2, just with the
; quotient A hard-coded to 96.
;
; Returns:
;
;   Q                   Gets set to the value of argument X
;
; ******************************************************************************

.TIS1

 STX Q                  ; Set Q = X

 EOR #%10000000         ; Flip the sign bit in A

 JSR MAD                ; Set (A X) = Q * A + (S R)
                        ;           = X * -A + (S R)

.DVID96

 TAX                    ; Set T to the sign bit of the result
 AND #%10000000
 STA T

 TXA                    ; Set A to the high byte of the result with the sign bit
 AND #%01111111         ; cleared, so (A ?) = |X * A + (S R)|

                        ; The following is identical to TIS2, except Q is
                        ; hard-coded to 96, so this does A = A / 96

 LDX #254               ; Set T1 to have bits 1-7 set, so we can rotate through
 STX T1                 ; 7 loop iterations, getting a 1 each time, and then
                        ; getting a 0 on the 8th iteration... and we can also
                        ; use T1 to catch our result bits into bit 0 each time

.DVL3

 ASL A                  ; Shift A to the left

 CMP #96                ; If A < 96 skip the following subtraction
 BCC DV4

 SBC #96                ; Set A = A - 96
                        ;
                        ; Going into this subtraction we know the C flag is
                        ; set as we passed through the BCC above, and we also
                        ; know that A >= 96, so the C flag will still be set
                        ; once we are done

.DV4

 ROL T1                 ; Rotate the counter in T1 to the left, and catch the
                        ; result bit into bit 0 (which will be a 0 if we didn't
                        ; do the subtraction, or 1 if we did)

 BCS DVL3               ; If we still have set bits in T1, loop back to DVL3 to
                        ; do the next iteration of 7

 LDA T1                 ; Fetch the result from T1 into A

 ORA T                  ; Give A the sign of the result that we stored above

 RTS                    ; Return from the subroutine

; ******************************************************************************
;
;       Name: DV42
;       Type: Subroutine
;   Category: Maths (Arithmetic)
;    Summary: Calculate (P R) = 256 * DELTA / z_hi
;
; ------------------------------------------------------------------------------
;
; Calculate the following division and remainder:
;
;   P = DELTA / (the Y-th stardust particle's z_hi coordinate)
;
;   R = remainder as a fraction of A, where 1.0 = 255
;
; Another way of saying the above is this:
;
;   (P R) = 256 * DELTA / z_hi
;
; DELTA is a value between 1 and 40, and the minimum z_hi is 16 (dust particles
; are removed at lower values than this), so this means P is between 0 and 2
; (as 40 / 16 = 2.5, so the maximum result is P = 2 and R = 128.
;
; This uses the same shift-and-subtract algorithm as TIS2, but this time we
; keep the remainder.
;
; Arguments:
;
;   Y                   The number of the stardust particle to process
;
; Returns:
;
;   C flag              The C flag is cleared
;
; ******************************************************************************

.DV42

 LDA SZ,Y               ; Fetch the Y-th dust particle's z_hi coordinate into A

                        ; Fall through into DV41 to do:
                        ;
                        ;   (P R) = 256 * DELTA / A
                        ;         = 256 * DELTA / Y-th stardust particle's z_hi

; ******************************************************************************
;
;       Name: DV41
;       Type: Subroutine
;   Category: Maths (Arithmetic)
;    Summary: Calculate (P R) = 256 * DELTA / A
;
; ------------------------------------------------------------------------------
;
; Calculate the following division and remainder:
;
;   P = DELTA / A
;
;   R = remainder as a fraction of A, where 1.0 = 255
;
; Another way of saying the above is this:
;
;   (P R) = 256 * DELTA / A
;
; This uses the same shift-and-subtract algorithm as TIS2, but this time we
; keep the remainder.
;
; Returns:
;
;   C flag              The C flag is cleared
;
; ******************************************************************************

.DV41

 STA Q                  ; Store A in Q

 LDA DELTA              ; Fetch the speed from DELTA into A

                        ; Fall through into DVID4 to do:
                        ;
                        ;   (P R) = 256 * A / Q
                        ;         = 256 * DELTA / A

; ******************************************************************************
;
;       Name: DVID4
;       Type: Subroutine
;   Category: Maths (Arithmetic)
;    Summary: Calculate (P R) = 256 * A / Q
;  Deep dive: Shift-and-subtract division
;
; ------------------------------------------------------------------------------
;
; Calculate the following division and remainder:
;
;   P = A / Q
;
;   R = remainder as a fraction of Q, where 1.0 = 255
;
; Another way of saying the above is this:
;
;   (P R) = 256 * A / Q
;
; This uses the same shift-and-subtract algorithm as TIS2, but this time we
; keep the remainder and the loop is unrolled.
;
; Returns:
;
;   C flag              The C flag is cleared
;
; ******************************************************************************

.DVID4

 ASL A                  ; Shift A left and store in P (we will build the result
 STA P                  ; in P)

 LDA #0                 ; Set A = 0 for us to build a remainder

                        ; We now repeat the following five instruction block
                        ; eight times, one for each bit in P. In the cassette
                        ; and disc versions of Elite the following is done with
                        ; a loop, but it is marginally faster to unroll the loop
                        ; and have eight copies of the code, though it does take
                        ; up a bit more memory (though that isn't a concern when
                        ; you have a 6502 Second Processor)

 ROL A                  ; Shift A to the left

 CMP Q                  ; If A < Q skip the following subtraction
 BCC P%+4

 SBC Q                  ; A >= Q, so set A = A - Q

 ROL P                  ; Shift P to the left, pulling the C flag into bit 0

 ROL A                  ; Repeat for the second time
 CMP Q
 BCC P%+4
 SBC Q
 ROL P

 ROL A                  ; Repeat for the third time
 CMP Q
 BCC P%+4
 SBC Q
 ROL P

 ROL A                  ; Repeat for the fourth time
 CMP Q
 BCC P%+4
 SBC Q
 ROL P

 ROL A                  ; Repeat for the fifth time
 CMP Q
 BCC P%+4
 SBC Q
 ROL P

 ROL A                  ; Repeat for the sixth time
 CMP Q
 BCC P%+4
 SBC Q
 ROL P

 ROL A                  ; Repeat for the seventh time
 CMP Q
 BCC P%+4
 SBC Q
 ROL P

 ROL A                  ; Repeat for the eighth time
 CMP Q
 BCC P%+4
 SBC Q
 ROL P

 LDX #0                 ; Set X = 0 so this unrolled version of DVID4 also
                        ; returns X = 0

 STA widget             ; This contains the code from the LL28+4 routine, so
 TAX                    ; this section is exactly equivalent to a JMP LL28+4
 BEQ LLfix22            ; call, but is slightly faster as it's been inlined
 LDA logL,X             ; (so it converts the remainder in A into an integer
 LDX Q                  ; representation of the fractional value A / Q, in R,
 SEC                    ; where 1.0 = 255, and it also clears the C flag
 SBC logL,X

 BMI CF94F              ; ???

 LDX widget
 LDA log,X
 LDX Q
 SBC log,X
 BCS LL222
 TAX
 LDA antilog,X

.LLfix22

 STA R
 RTS

.LL222

 LDA #255
 STA R
 RTS

.CF94F

 LDX widget             ; ???
 LDA log,X
 LDX Q
 SBC log,X
 BCS LL222
 TAX
 LDA antilogODD,X
 STA R
 RTS

; ******************************************************************************
;
;       Name: DVID3B2
;       Type: Subroutine
;   Category: Maths (Arithmetic)
;    Summary: Calculate K(3 2 1 0) = (A P+1 P) / (z_sign z_hi z_lo)
;  Deep dive: Shift-and-subtract division
;
; ------------------------------------------------------------------------------
;
; Calculate the following:
;
;   K(3 2 1 0) = (A P+1 P) / (z_sign z_hi z_lo)
;
; The actual division here is done as an 8-bit calculation using LL31, but this
; routine shifts both the numerator (the top part of the division) and the
; denominator (the bottom part of the division) around to get the multi-byte
; result we want.
;
; Specifically, it shifts both of them to the left as far as possible, keeping a
; tally of how many shifts get done in each one - and specifically, the
; difference in the number of shifts between the top and bottom (as shifting
; both of them once in the same direction won't change the result). It then
; divides the two highest bytes with the simple 8-bit routine in LL31, and
; shifts the result by the difference in the number of shifts, which acts as a
; scale factor to get the correct result.
;
; Returns:
;
;   K(3 2 1 0)          The result of the division
;
;   X                   X is preserved
;
; ******************************************************************************

.DVID3B2

 STA P+2                ; Set P+2 = A

 LDA INWK+6             ; Set Q = z_lo, making sure Q is at least 1
 ORA #1
 STA Q

 LDA INWK+7             ; Set R = z_hi
 STA R

 LDA INWK+8             ; Set S = z_sign
 STA S

.DVID3B

 SETUP_PPU_FOR_ICON_BAR ; If the PPU has started drawing the icon bar, configure
                        ; the PPU to use nametable 0 and pattern table 0

                        ; Given the above assignments, we now want to calculate
                        ; the following to get the result we want:
                        ;
                        ;   K(3 2 1 0) = P(2 1 0) / (S R Q)

 LDA P                  ; Make sure P(2 1 0) is at least 1
 ORA #1
 STA P

 LDA P+2                ; Set T to the sign of P+2 * S (i.e. the sign of the
 EOR S                  ; result) and store it in T
 AND #%10000000
 STA T

 LDY #0                 ; Set Y = 0 to store the scale factor

 LDA P+2                ; Clear the sign bit of P+2, so the division can be done
 AND #%01111111         ; with positive numbers and we'll set the correct sign
                        ; below, once all the maths is done
                        ;
                        ; This also leaves A = P+2, which we use below

.DVL9

                        ; We now shift (A P+1 P) left until A >= 64, counting
                        ; the number of shifts in Y. This makes the top part of
                        ; the division as large as possible, thus retaining as
                        ; much accuracy as we can.  When we come to return the
                        ; final result, we shift the result by the number of
                        ; places in Y, and in the correct direction

 CMP #64                ; If A >= 64, jump down to DV14
 BCS DV14

 ASL P                  ; Shift (A P+1 P) to the left
 ROL P+1
 ROL A

 INY                    ; Increment the scale factor in Y

 BNE DVL9               ; Loop up to DVL9 (this BNE is effectively a JMP, as Y
                        ; will never be zero)

.DV14

                        ; If we get here, A >= 64 and contains the highest byte
                        ; of the numerator, scaled up by the number of left
                        ; shifts in Y

 STA P+2                ; Store A in P+2, so we now have the scaled value of
                        ; the numerator in P(2 1 0)

 LDA S                  ; Set A = |S|
 AND #%01111111

.DVL6

                        ; We now shift (S R Q) left until bit 7 of S is set,
                        ; reducing Y by the number of shifts. This makes the
                        ; bottom part of the division as large as possible, thus
                        ; retaining as much accuracy as we can. When we come to
                        ; return the final result, we shift the result by the
                        ; total number of places in Y, and in the correct
                        ; direction, to give us the correct result
                        ;
                        ; We set A to |S| above, so the following actually
                        ; shifts (A R Q)

 DEY                    ; Decrement the scale factor in Y

 ASL Q                  ; Shift (A R Q) to the left
 ROL R
 ROL A

 BPL DVL6               ; Loop up to DVL6 to do another shift, until bit 7 of A
                        ; is set and we can't shift left any further

.DV9

                        ; We have now shifted both the numerator and denominator
                        ; left as far as they will go, keeping a tally of the
                        ; overall scale factor of the various shifts in Y. We
                        ; can now divide just the two highest bytes to get our
                        ; result

 STA Q                  ; Set Q = A, the highest byte of the denominator

 SETUP_PPU_FOR_ICON_BAR ; If the PPU has started drawing the icon bar, configure
                        ; the PPU to use nametable 0 and pattern table 0

 LDA #254               ; Set R to have bits 1-7 set, so we can pass this to
 STA R                  ; LL31 to act as the bit counter in the division

 LDA P+2                ; Set A to the highest byte of the numerator

.LL31new

 ASL A                  ; This contains the code from the LL31 routine, so
 BCS LL29new            ; this section is exactly equivalent to a JSR LL31
 CMP Q                  ; call, but is slightly faster as it's been inlined,
 BCC P%+4               ; so it calculates:
 SBC Q                  ;
 ROL R                  ;   R = 256 * A / Q
 BCS LL31new            ;     = 256 * numerator / denominator
 JMP LL312new

.LL29new

 SBC Q
 SEC
 ROL R
 BCS LL31new
 LDA R

.LL312new

                        ; The result of our division is now in R, so we just
                        ; need to shift it back by the scale factor in Y

 LDA #0                 ; Set K(3 2 1) = 0 to hold the result (we populate K
 STA K+1                ; next)
 STA K+2
 STA K+3

 TYA                    ; If Y is positive, jump to DV12
 BPL DV12

                        ; If we get here then Y is negative, so we need to shift
                        ; the result R to the left by Y places, and then set the
                        ; correct sign for the result

 LDA R                  ; Set A = R

.DVL8

 ASL A                  ; Shift (K+3 K+2 K+1 A) left
 ROL K+1
 ROL K+2
 ROL K+3

 INY                    ; Increment the scale factor in Y

 BNE DVL8               ; Loop back to DVL8 until we have shifted left by Y
                        ; places

 STA K                  ; Store A in K so the result is now in K(3 2 1 0)

 LDA K+3                ; Set K+3 to the sign in T, which we set above to the
 ORA T                  ; correct sign for the result
 STA K+3

 RTS                    ; Return from the subroutine

.DV13

                        ; If we get here then Y is zero, so we don't need to
                        ; shift the result R, we just need to set the correct
                        ; sign for the result

 LDA R                  ; Store R in K so the result is now in K(3 2 1 0)
 STA K

 LDA T                  ; Set K+3 to the sign in T, which we set above to the
 STA K+3                ; correct sign for the result

 RTS                    ; Return from the subroutine

.DV12

 BEQ DV13               ; We jumped here having set A to the scale factor in Y,
                        ; so this jumps up to DV13 if Y = 0

                        ; If we get here then Y is positive and non-zero, so we
                        ; need to shift the result R to the right by Y places
                        ; and then set the correct sign for the result. We also
                        ; know that K(3 2 1) will stay 0, as we are shifting the
                        ; lowest byte to the right, so no set bits will make
                        ; their way into the top three bytes

 LDA R                  ; Set A = R

.DVL10

 LSR A                  ; Shift A right

 DEY                    ; Decrement the scale factor in Y

 BNE DVL10              ; Loop back to DVL10 until we have shifted right by Y
                        ; places

 STA K                  ; Store the shifted A in K so the result is now in
                        ; K(3 2 1 0)

 LDA T                  ; Set K+3 to the sign in T, which we set above to the
 STA K+3                ; correct sign for the result

 RTS                    ; Return from the subroutine

; ******************************************************************************
;
;       Name: subm_FA16
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.CFA13

 LDX #$80

.loop_CFA15

 RTS

.subm_FA16

 STA T
 LDA auto
 BNE CFA22
 LDA L03EA
 BEQ loop_CFA15

.CFA22

 TXA
 BMI CFA2C
 CLC
 ADC T
 BMI CFA13
 TAX
 RTS

.CFA2C

 SEC
 SBC T
 BPL CFA13
 TAX
 RTS

; ******************************************************************************
;
;       Name: BUMP2
;       Type: Subroutine
;   Category: Dashboard
;    Summary: Bump up the value of the pitch or roll dashboard indicator
;
; ------------------------------------------------------------------------------
;
; Increase ("bump up") X by A, where X is either the current rate of pitch or
; the current rate of roll.
;
; The rate of pitch or roll ranges from 1 to 255 with 128 as the centre point.
; This is the amount by which the pitch or roll is currently changing, so 1
; means it is decreasing at the maximum rate, 128 means it is not changing,
; and 255 means it is increasing at the maximum rate. These values correspond
; to the line on the DC or RL indicators on the dashboard, with 1 meaning full
; left, 128 meaning the middle, and 255 meaning full right.
;
; If bumping up X would push it past 255, then X is set to 255.
;
; If keyboard auto-recentre is configured and the result is less than 128, we
; bump X up to the mid-point, 128. This is the equivalent of having a roll or
; pitch in the left half of the indicator, when increasing the roll or pitch
; should jump us straight to the mid-point.
;
; Other entry points:
;
;   RE2+2               Restore A from T and return from the subroutine
;
; ******************************************************************************

.BUMP2

 STA T                  ; Store argument A in T so we can restore it later

 TXA                    ; Copy argument X into A

 CLC                    ; Clear the C flag so we can do addition without the
                        ; C flag affecting the result

 ADC T                  ; Set X = A = argument X + argument A
 TAX

 BCC RE2                ; If the C flag is clear, then we didn't overflow, so
                        ; jump to RE2 to auto-recentre and return the result

 LDX #255               ; We have an overflow, so set X to the maximum possible
                        ; value of 255

.RE2

 BPL djd1               ; If X has bit 7 clear (i.e. the result < 128), then
                        ; jump to djd1 in routine REDU2 to do an auto-recentre,
                        ; if configured, because the result is on the left side
                        ; of the centre point of 128

                        ; Jumps to RE2+2 end up here

 LDA T                  ; Restore the original argument A from T into A

 RTS                    ; Return from the subroutine

; ******************************************************************************
;
;       Name: REDU2
;       Type: Subroutine
;   Category: Dashboard
;    Summary: Reduce the value of the pitch or roll dashboard indicator
;
; ------------------------------------------------------------------------------
;
; Reduce X by A, where X is either the current rate of pitch or the current
; rate of roll.
;
; The rate of pitch or roll ranges from 1 to 255 with 128 as the centre point.
; This is the amount by which the pitch or roll is currently changing, so 1
; means it is decreasing at the maximum rate, 128 means it is not changing,
; and 255 means it is increasing at the maximum rate. These values correspond
; to the line on the DC or RL indicators on the dashboard, with 1 meaning full
; left, 128 meaning the middle, and 255 meaning full right.
;
; If reducing X would bring it below 1, then X is set to 1.
;
; If keyboard auto-recentre is configured and the result is greater than 128, we
; reduce X down to the mid-point, 128. This is the equivalent of having a roll
; or pitch in the right half of the indicator, when decreasing the roll or pitch
; should jump us straight to the mid-point.
;
; Other entry points:
;
;
; ******************************************************************************

.REDU2

 STA T                  ; Store argument A in T so we can restore it later

 TXA                    ; Copy argument X into A

 SEC                    ; Set the C flag so we can do subtraction without the
                        ; C flag affecting the result

 SBC T                  ; Set X = A = argument X - argument A
 TAX

 BCS RE3                ; If the C flag is set, then we didn't underflow, so
                        ; jump to RE3 to auto-recentre and return the result

 LDX #1                 ; We have an underflow, so set X to the minimum possible
                        ; value, 1

.RE3

 BPL RE2+2              ; If X has bit 7 clear (i.e. the result < 128), then
                        ; jump to RE2+2 above to return the result as is,
                        ; because the result is on the left side of the centre
                        ; point of 128, so we don't need to auto-centre

.djd1

 LDX #128               ; ???
 LDA T
 RTS

; ******************************************************************************
;
;       Name: LL5
;       Type: Subroutine
;   Category: Maths (Arithmetic)
;    Summary: Calculate Q = SQRT(R Q)
;  Deep dive: Calculating square roots
;
; ------------------------------------------------------------------------------
;
; Calculate the following square root:
;
;   Q = SQRT(R Q)
;
; ******************************************************************************

.LL5

 LDY R                  ; Set (Y S) = (R Q)
 LDA Q
 STA S

                        ; So now to calculate Q = SQRT(Y S)

 LDX #0                 ; Set X = 0, to hold the remainder

 STX Q                  ; Set Q = 0, to hold the result

 LDA #8                 ; Set T = 8, to use as a loop counter
 STA T

.LL6

 CPX Q                  ; If X < Q, jump to LL7
 BCC LL7

 BNE P%+6               ; If X > Q, skip the next two instructions

 CPY #64                ; If Y < 64, jump to LL7 with the C flag clear,
 BCC LL7                ; otherwise fall through into LL8 with the C flag set

 TYA                    ; Set Y = Y - 64
 SBC #64                ;
 TAY                    ; This subtraction will work as we know C is set from
                        ; the BCC above, and the result will not underflow as we
                        ; already checked that Y >= 64, so the C flag is also
                        ; set for the next subtraction

 TXA                    ; Set X = X - Q
 SBC Q
 TAX

.LL7

 ROL Q                  ; Shift the result in Q to the left, shifting the C flag
                        ; into bit 0 and bit 7 into the C flag

 ASL S                  ; Shift the dividend in (Y S) to the left, inserting
 TYA                    ; bit 7 from above into bit 0
 ROL A
 TAY

 TXA                    ; Shift the remainder in X to the left
 ROL A
 TAX

 ASL S                  ; Shift the dividend in (Y S) to the left
 TYA
 ROL A
 TAY

 TXA                    ; Shift the remainder in X to the left
 ROL A
 TAX

 DEC T                  ; Decrement the loop counter

 BNE LL6                ; Loop back to LL6 until we have done 8 loops

 RTS                    ; Return from the subroutine

; ******************************************************************************
;
;       Name: LL28
;       Type: Subroutine
;   Category: Maths (Arithmetic)
;    Summary: Calculate R = 256 * A / Q
;  Deep dive: Multiplication and division using logarithms
;
; ------------------------------------------------------------------------------
;
; Calculate the following, where A < Q:
;
;   R = 256 * A / Q
;
; This is a sister routine to LL61, which does the division when A >= Q.
;
; If A >= Q then 255 is returned and the C flag is set to indicate an overflow
; (the C flag is clear if the division was a success).
;
; The result is returned in one byte as the result of the division multiplied
; by 256, so we can return fractional results using integers.
;
; This routine uses the same logarithm algorithm that's documented in FMLTU,
; except it subtracts the logarithm values, to do a division instead of a
; multiplication.
;
; Returns:
;
;   C flag              Set if the answer is too big for one byte, clear if the
;                       division was a success
;
; Other entry points:
;
;   LL28+4              Skips the A >= Q check and always returns with C flag
;                       cleared, so this can be called if we know the division
;                       will work
;
; ******************************************************************************

.LL2

 LDA #255               ; The division is very close to 1, so return the closest
 STA R                  ; possible answer to 256, i.e. R = 255

 RTS                    ; Return from the subroutine

.LL28

 CMP Q                  ; If A >= Q, then the answer will not fit in one byte,
 BCS LL2                ; so jump to LL2 to return 255

 STA widget             ; Store A in widget, so now widget = argument A

 TAX                    ; Transfer A into X, so now X = argument A

 BEQ LLfix              ; If A = 0, jump to LLfix to return a result of 0, as
                        ; 0 * Q / 256 is always 0

                        ; We now want to calculate log(A) - log(Q), first adding
                        ; the low bytes (from the logL table), and then the high
                        ; bytes (from the log table)

 LDA logL,X             ; Set A = low byte of log(X)
                        ;       = low byte of log(A) (as we set X to A above)

 LDX Q                  ; Set X = Q

 SEC                    ; Set A = A - low byte of log(Q)
 SBC logL,X             ;       = low byte of log(A) - low byte of log(Q)

 BMI noddlog            ; If the subtraction is negative, jump to noddlog

 LDX widget             ; Set A = high byte of log(A) - high byte of log(Q)
 LDA log,X
 LDX Q
 SBC log,X

 BCS LL2                ; If the subtraction fitted into one byte and didn't
                        ; underflow, then log(A) - log(Q) < 256, so we jump to
                        ; LL2 return a result of 255

 TAX                    ; Otherwise we return the A-th entry from the antilog
 LDA antilog,X          ; table

.LLfix

 STA R                  ; Set the result in R to the value of A

 RTS                    ; Return from the subroutine

.noddlog

 LDX widget             ; Set A = high byte of log(A) - high byte of log(Q)
 LDA log,X
 LDX Q
 SBC log,X

 BCS LL2                ; If the subtraction fitted into one byte and didn't
                        ; underflow, then log(A) - log(Q) < 256, so we jump to
                        ; LL2 to return a result of 255

 TAX                    ; Otherwise we return the A-th entry from the antilogODD
 LDA antilogODD,X       ; table

 STA R                  ; Set the result in R to the value of A

 RTS                    ; Return from the subroutine

; ******************************************************************************
;
;       Name: TIS2
;       Type: Subroutine
;   Category: Maths (Arithmetic)
;    Summary: Calculate A = A / Q
;  Deep dive: Shift-and-subtract division
;
; ------------------------------------------------------------------------------
;
; Calculate the following division, where A is a sign-magnitude number and Q is
; a positive integer:
;
;   A = A / Q
;
; The value of A is returned as a sign-magnitude number with 96 representing 1,
; and the maximum value returned is 1 (i.e. 96). This routine is used when
; normalising vectors, where we represent fractions using integers, so this
; gives us an approximation to two decimal places.
;
; ******************************************************************************

.TIS2

 TAY                    ; Store the argument A in Y

 AND #%01111111         ; Strip the sign bit from the argument, so A = |A|

 CMP Q                  ; If A >= Q then jump to TI4 to return a 1 with the
 BCS TI4                ; correct sign

 LDX #%11111110         ; Set T to have bits 1-7 set, so we can rotate through 7
 STX T                  ; loop iterations, getting a 1 each time, and then
                        ; getting a 0 on the 8th iteration... and we can also
                        ; use T to catch our result bits into bit 0 each time

.TIL2

 ASL A                  ; Shift A to the left

 CMP Q                  ; If A < Q skip the following subtraction
 BCC P%+4

 SBC Q                  ; A >= Q, so set A = A - Q
                        ;
                        ; Going into this subtraction we know the C flag is
                        ; set as we passed through the BCC above, and we also
                        ; know that A >= Q, so the C flag will still be set once
                        ; we are done

 ROL T                  ; Rotate the counter in T to the left, and catch the
                        ; result bit into bit 0 (which will be a 0 if we didn't
                        ; do the subtraction, or 1 if we did)

 BCS TIL2               ; If we still have set bits in T, loop back to TIL2 to
                        ; do the next iteration of 7

                        ; We've done the division and now have a result in the
                        ; range 0-255 here, which we need to reduce to the range
                        ; 0-96. We can do that by multiplying the result by 3/8,
                        ; as 256 * 3/8 = 96

 LDA T                  ; Set T = T / 4
 LSR A
 LSR A
 STA T

 LSR A                  ; Set T = T / 8 + T / 4
 ADC T                  ;       = 3T / 8
 STA T

 TYA                    ; Fetch the sign bit of the original argument A
 AND #%10000000

 ORA T                  ; Apply the sign bit to T

 RTS                    ; Return from the subroutine

.TI4

 TYA                    ; Fetch the sign bit of the original argument A
 AND #%10000000

 ORA #96                ; Apply the sign bit to 96 (which represents 1)

 RTS                    ; Return from the subroutine

; ******************************************************************************
;
;       Name: NORM
;       Type: Subroutine
;   Category: Maths (Geometry)
;    Summary: Normalise the three-coordinate vector in XX15
;  Deep dive: Tidying orthonormal vectors
;             Orientation vectors
;
; ------------------------------------------------------------------------------
;
; We do this by dividing each of the three coordinates by the length of the
; vector, which we can calculate using Pythagoras. Once normalised, 96 ($60) is
; used to represent a value of 1, and 96 with bit 7 set ($E0) is used to
; represent -1. This enables us to represent fractional values of less than 1
; using integers.
;
; Arguments:
;
;   XX15                The vector to normalise, with:
;
;                         * The x-coordinate in XX15
;
;                         * The y-coordinate in XX15+1
;
;                         * The z-coordinate in XX15+2
;
; Returns:
;
;   XX15                The normalised vector
;
;   Q                   The length of the original XX15 vector
;
; Other entry points:
;
;   NO1                 Contains an RTS
;
; ******************************************************************************

.NORM

 SETUP_PPU_FOR_ICON_BAR ; If the PPU has started drawing the icon bar, configure
                        ; the PPU to use nametable 0 and pattern table 0

 LDA XX15               ; Fetch the x-coordinate into A

 JSR SQUA               ; Set (A P) = A * A = x^2

 STA R                  ; Set (R Q) = (A P) = x^2
 LDA P
 STA Q

 LDA XX15+1             ; Fetch the y-coordinate into A

 JSR SQUA               ; Set (A P) = A * A = y^2

 STA T                  ; Set (T P) = (A P) = y^2

 LDA P                  ; Set (R Q) = (R Q) + (T P) = x^2 + y^2
 ADC Q                  ;
 STA Q                  ; First, doing the low bytes, Q = Q + P

 LDA T                  ; And then the high bytes, R = R + T
 ADC R
 STA R

 LDA XX15+2             ; Fetch the z-coordinate into A

 JSR SQUA               ; Set (A P) = A * A = z^2

 STA T                  ; Set (T P) = (A P) = z^2

 SETUP_PPU_FOR_ICON_BAR ; If the PPU has started drawing the icon bar, configure
                        ; the PPU to use nametable 0 and pattern table 0

 CLC                    ; Clear the C flag (though this isn't nedded, as the
                        ; SETUP_PPU_FOR_ICON_BAR does this for us)

 LDA P                  ; Set (R Q) = (R Q) + (T P) = x^2 + y^2 + z^2
 ADC Q                  ;
 STA Q                  ; First, doing the low bytes, Q = Q + P

 LDA T                  ; And then the high bytes, R = R + T
 ADC R

 BCS CFB79              ; ???

 STA R

 JSR LL5                ; We now have the following:
                        ;
                        ; (R Q) = x^2 + y^2 + z^2
                        ;
                        ; so we can call LL5 to use Pythagoras to get:
                        ;
                        ; Q = SQRT(R Q)
                        ;   = SQRT(x^2 + y^2 + z^2)
                        ;
                        ; So Q now contains the length of the vector (x, y, z),
                        ; and we can normalise the vector by dividing each of
                        ; the coordinates by this value, which we do by calling
                        ; routine TIS2. TIS2 returns the divided figure, using
                        ; 96 to represent 1 and 96 with bit 7 set for -1

.CFB49

 LDA XX15               ; Call TIS2 to divide the x-coordinate in XX15 by Q,
 JSR TIS2               ; with 1 being represented by 96
 STA XX15

 SETUP_PPU_FOR_ICON_BAR ; If the PPU has started drawing the icon bar, configure
                        ; the PPU to use nametable 0 and pattern table 0

 LDA XX15+1             ; Call TIS2 to divide the y-coordinate in XX15+1 by Q,
 JSR TIS2               ; with 1 being represented by 96
 STA XX15+1

 LDA XX15+2             ; Call TIS2 to divide the z-coordinate in XX15+2 by Q,
 JSR TIS2               ; with 1 being represented by 96
 STA XX15+2

 SETUP_PPU_FOR_ICON_BAR ; If the PPU has started drawing the icon bar, configure
                        ; the PPU to use nametable 0 and pattern table 0

.NO1

 RTS                    ; Return from the subroutine

.CFB79

 ROR A                  ; ???
 ROR Q
 LSR A
 ROR Q
 STA R
 JSR LL5
 ASL Q
 JMP CFB49

; ******************************************************************************
;
;       Name: SetupMMC1
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.SetupMMC1

 LDA #$0E
 STA $9FFF
 LSR A
 STA $9FFF
 LSR A
 STA $9FFF
 LSR A
 STA $9FFF
 LSR A
 STA $9FFF
 LDA #0
 STA $BFFF
 LSR A
 STA $BFFF
 LSR A
 STA $BFFF
 LSR A
 STA $BFFF
 LSR A
 STA $BFFF
 LDA #0
 STA $DFFF
 LSR A
 STA $DFFF
 LSR A
 STA $DFFF
 LSR A
 STA $DFFF
 LSR A
 STA $DFFF
 JMP CC0A3

; ******************************************************************************
;
;       Name: LFBCB
;       Type: Variable
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

IF _NTSC

 EQUB $F5, $F5, $F5, $F5, $F6, $F6, $F6, $F6  ; FBCB: F5 F5 F5... ...
 EQUB $F7, $F7, $F7, $F7, $F7, $F8, $F8, $F8  ; FBD3: F7 F7 F7... ...
 EQUB $F8, $F9, $F9, $F9, $F9, $F9, $FA, $FA  ; FBDB: F8 F9 F9... ...
 EQUB $FA, $FA, $FA, $FB, $FB, $FB, $FB, $FB  ; FBE3: FA FA FA... ...
 EQUB $FC, $FC, $FC, $FC, $FC, $FD, $FD, $FD  ; FBEB: FC FC FC... ...
 EQUB $FD, $FD, $FD, $FE, $FE, $FE, $FE, $FE  ; FBF3: FD FD FD... ...
 EQUB $FF, $FF, $FF, $FF, $FF

ELIF _PAL

 EQUB $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
 EQUB $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
 EQUB $FF, $FF, $FF, $FF, $FF, $FF

ENDIF

; ******************************************************************************
;
;       Name: lineImage
;       Type: Variable
;   Category: Drawing images
;    Summary: Image data for the horizontal line, vertical line and block images
;
; ******************************************************************************

.lineImage

 EQUB $FF, $00, $00, $00, $00, $00, $00, $00  ; FC00: FF 00 00... ...
 EQUB $00, $FF, $00, $00, $00, $00, $00, $00  ; FC08: 00 FF 00... ...
 EQUB $00, $00, $FF, $00, $00, $00, $00, $00  ; FC10: 00 00 FF... ...
 EQUB $00, $00, $00, $FF, $00, $00, $00, $00  ; FC18: 00 00 00... ...
 EQUB $00, $00, $00, $00, $FF, $00, $00, $00  ; FC20: 00 00 00... ...
 EQUB $00, $00, $00, $00, $00, $FF, $00, $00  ; FC28: 00 00 00... ...
 EQUB $00, $00, $00, $00, $00, $00, $FF, $00  ; FC30: 00 00 00... ...
 EQUB $00, $00, $00, $00, $00, $00, $00, $FF  ; FC38: 00 00 00... ...
 EQUB $00, $00, $00, $00, $00, $00, $FF, $FF  ; FC40: 00 00 00... ...
 EQUB $00, $00, $00, $00, $00, $FF, $FF, $FF  ; FC48: 00 00 00... ...
 EQUB $00, $00, $00, $00, $FF, $FF, $FF, $FF  ; FC50: 00 00 00... ...
 EQUB $00, $00, $00, $FF, $FF, $FF, $FF, $FF  ; FC58: 00 00 00... ...
 EQUB $00, $00, $FF, $FF, $FF, $FF, $FF, $FF  ; FC60: 00 00 FF... ...
 EQUB $00, $FF, $FF, $FF, $FF, $FF, $FF, $FF  ; FC68: 00 FF FF... ...
 EQUB $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF  ; FC70: FF FF FF... ...
 EQUB $80, $80, $80, $80, $80, $80, $80, $80  ; FC78: 80 80 80... ...
 EQUB $40, $40, $40, $40, $40, $40, $40, $40  ; FC80: 40 40 40... @@@
 EQUB $20, $20, $20, $20, $20, $20, $20, $20  ; FC88: 20 20 20...
 EQUB $10, $10, $10, $10, $10, $10, $10, $10  ; FC90: 10 10 10... ...
 EQUB $08, $08, $08, $08, $08, $08, $08, $08  ; FC98: 08 08 08... ...
 EQUB $04, $04, $04, $04, $04, $04, $04, $04  ; FCA0: 04 04 04... ...
 EQUB $02, $02, $02, $02, $02, $02, $02, $02  ; FCA8: 02 02 02... ...
 EQUB $01, $01, $01, $01, $01, $01, $01, $01  ; FCB0: 01 01 01... ...
 EQUB $00, $00, $00, $00, $00, $FF, $FF, $FF  ; FCB8: 00 00 00... ...
 EQUB $FF, $FF, $FF, $00, $00, $00, $00, $00  ; FCC0: FF FF FF... ...
 EQUB $00, $00, $00, $00, $00, $C0, $C0, $C0  ; FCC8: 00 00 00... ...
 EQUB $C0, $C0, $C0, $00, $00, $00, $00, $00  ; FCD0: C0 C0 C0... ...
 EQUB $00, $00, $00, $00, $00, $03, $03, $03  ; FCD8: 00 00 00... ...
 EQUB $03, $03, $03, $00, $00, $00, $00, $00  ; FCE0: 03 03 03... ...

; ******************************************************************************
;
;       Name: fontImage
;       Type: Variable
;   Category: Text
;    Summary: Image data for the text font
;
; ******************************************************************************

.fontImage

 EQUB $00, $00, $00, $00, $00, $00, $00, $00
 EQUB $30, $30, $30, $30, $00, $30, $30, $00
 EQUB $7F, $63, $63, $63, $7F, $63, $63, $00
 EQUB $7F, $63, $63, $63, $63, $63, $7F, $00
 EQUB $78, $1E, $7F, $03, $7F, $63, $7F, $00
 EQUB $1F, $78, $7F, $63, $7F, $60, $7F, $00
 EQUB $7C, $CC, $78, $38, $6D, $C6, $7F, $00
 EQUB $30, $30, $30, $00, $00, $00, $00, $00
 EQUB $06, $0C, $18, $18, $18, $0C, $06, $00
 EQUB $60, $30, $18, $18, $18, $30, $60, $00
 EQUB $78, $1E, $7F, $63, $7F, $60, $7F, $00
 EQUB $1C, $36, $7F, $63, $7F, $60, $7F, $00
 EQUB $00, $00, $00, $00, $00, $30, $30, $60
 EQUB $00, $00, $00, $7E, $00, $00, $00, $00
 EQUB $00, $00, $00, $00, $00, $30, $30, $00
 EQUB $1C, $36, $7F, $63, $63, $63, $7F, $00
 EQUB $7F, $63, $63, $63, $63, $63, $7F, $00
 EQUB $1C, $0C, $0C, $0C, $0C, $0C, $3F, $00
 EQUB $7F, $03, $03, $7F, $60, $60, $7F, $00
 EQUB $7F, $03, $03, $3F, $03, $03, $7F, $00
 EQUB $60, $60, $66, $66, $7F, $06, $06, $00
 EQUB $7F, $60, $60, $7F, $03, $03, $7F, $00
 EQUB $7F, $60, $60, $7F, $63, $63, $7F, $00
 EQUB $7F, $03, $03, $07, $03, $03, $03, $00
 EQUB $7F, $63, $63, $7F, $63, $63, $7F, $00
 EQUB $7F, $63, $63, $7F, $03, $03, $7F, $00
 EQUB $00, $00, $30, $30, $00, $30, $30, $00
 EQUB $00, $00, $7E, $66, $7F, $63, $7F, $60
 EQUB $7F, $60, $60, $7E, $60, $60, $7F, $00
 EQUB $7F, $60, $60, $7E, $60, $60, $7F, $00
 EQUB $18, $0C, $06, $03, $06, $0C, $18, $00
 EQUB $7F, $03, $1F, $18, $00, $18, $18, $00
 EQUB $7F, $60, $60, $60, $60, $7F, $0C, $3C
 EQUB $7F, $63, $63, $63, $7F, $63, $63, $00
 EQUB $7E, $66, $66, $7F, $63, $63, $7F, $00
 EQUB $7F, $60, $60, $60, $60, $60, $7F, $00
 EQUB $7F, $33, $33, $33, $33, $33, $7F, $00
 EQUB $7F, $60, $60, $7E, $60, $60, $7F, $00
 EQUB $7F, $60, $60, $7E, $60, $60, $60, $00
 EQUB $7F, $60, $60, $60, $63, $63, $7F, $00
 EQUB $63, $63, $63, $7F, $63, $63, $63, $00
 EQUB $3F, $0C, $0C, $0C, $0C, $0C, $3F, $00
 EQUB $7F, $0C, $0C, $0C, $0C, $0C, $7C, $00
 EQUB $66, $66, $66, $7F, $63, $63, $63, $00
 EQUB $60, $60, $60, $60, $60, $60, $7F, $00
 EQUB $63, $77, $7F, $6B, $63, $63, $63, $00
 EQUB $63, $73, $7B, $6F, $67, $63, $63, $00
 EQUB $7F, $63, $63, $63, $63, $63, $7F, $00
 EQUB $7F, $63, $63, $7F, $60, $60, $60, $00
 EQUB $7F, $63, $63, $63, $63, $67, $7F, $03
 EQUB $7F, $63, $63, $7F, $66, $66, $66, $00
 EQUB $7F, $60, $60, $7F, $03, $03, $7F, $00
 EQUB $7E, $18, $18, $18, $18, $18, $18, $00
 EQUB $63, $63, $63, $63, $63, $63, $7F, $00
 EQUB $63, $63, $66, $6C, $78, $70, $60, $00
 EQUB $63, $63, $63, $6B, $7F, $77, $63, $00
 EQUB $63, $36, $1C, $1C, $1C, $36, $63, $00
 EQUB $63, $33, $1B, $0F, $07, $03, $03, $00
 EQUB $7F, $06, $0C, $18, $30, $60, $7F, $00
 EQUB $63, $3E, $63, $63, $7F, $63, $63, $00
 EQUB $63, $3E, $63, $63, $63, $63, $7F, $00
 EQUB $63, $00, $63, $63, $63, $63, $7F, $00
 EQUB $7E, $66, $66, $7F, $63, $63, $7F, $60
 EQUB $7F, $60, $60, $7E, $60, $60, $7F, $00
 EQUB $00, $00, $7F, $60, $60, $7F, $0C, $3C
 EQUB $00, $00, $7F, $03, $7F, $63, $7F, $00
 EQUB $60, $60, $7F, $63, $63, $63, $7F, $00
 EQUB $00, $00, $7F, $60, $60, $60, $7F, $00
 EQUB $03, $03, $7F, $63, $63, $63, $7F, $00
 EQUB $00, $00, $7F, $63, $7F, $60, $7F, $00
 EQUB $3F, $30, $30, $7C, $30, $30, $30, $00
 EQUB $00, $00, $7F, $63, $63, $7F, $03, $7F
 EQUB $60, $60, $7F, $63, $63, $63, $63, $00
 EQUB $18, $00, $78, $18, $18, $18, $7E, $00
 EQUB $0C, $00, $3C, $0C, $0C, $0C, $0C, $7C
 EQUB $60, $60, $66, $66, $7F, $63, $63, $00
 EQUB $78, $18, $18, $18, $18, $18, $7E, $00
 EQUB $00, $00, $77, $7F, $6B, $63, $63, $00
 EQUB $00, $00, $7F, $63, $63, $63, $63, $00
 EQUB $00, $00, $7F, $63, $63, $63, $7F, $00
 EQUB $00, $00, $7F, $63, $63, $7F, $60, $60
 EQUB $00, $00, $7F, $63, $63, $7F, $03, $03
 EQUB $00, $00, $7F, $60, $60, $60, $60, $00
 EQUB $00, $00, $7F, $60, $7F, $03, $7F, $00
 EQUB $30, $30, $7C, $30, $30, $30, $3F, $00
 EQUB $00, $00, $63, $63, $63, $63, $7F, $00
 EQUB $00, $00, $63, $66, $6C, $78, $70, $00
 EQUB $00, $00, $63, $63, $6B, $7F, $7F, $00
 EQUB $00, $00, $63, $36, $1C, $36, $63, $00
 EQUB $00, $00, $63, $63, $63, $7F, $03, $7F
 EQUB $00, $00, $7F, $0C, $18, $30, $7F, $00
 EQUB $36, $00, $7F, $03, $7F, $63, $7F, $00
 EQUB $36, $00, $7F, $63, $63, $63, $7F, $00
 EQUB $36, $00, $63, $63, $63, $63, $7F, $00

IF _NTSC

 EQUB $00, $8D, $06, $20, $A9, $4C, $00, $C0

ELIF _PAL

 EQUB $FF, $FF, $FF, $FF, $FF, $4C, $00, $C0

ENDIF

 EQUB $45, $4C, $20, $20, $20, $20, $20, $20
 EQUB $20, $20, $20, $20, $20, $20, $20, $20
 EQUB $00, $00, $00, $00, $38, $04, $01, $07
 EQUB $9C, $2A

; ******************************************************************************
;
;       Name: Vectors
;       Type: Variable
;   Category: Text
;    Summary: Vectors at the end of the ROM bank
;
; ******************************************************************************

 EQUW NMI               ; Vector to the NMI handler

 EQUW ResetMMC1_b7      ; Vector to the RESET handler

 EQUW IRQ               ; Vector to the IRQ/BRK handler

; ******************************************************************************
;
; Save bank7.bin
;
; ******************************************************************************

IF _BANK = 7

 PRINT "S.bank7.bin ", ~CODE_BANK_7%, " ", ~P%, " ", ~LOAD_BANK_7%, " ", ~LOAD_BANK_7%
 SAVE "3-assembled-output/bank7.bin", CODE_BANK_7%, P%, LOAD_BANK_7%

ENDIF
