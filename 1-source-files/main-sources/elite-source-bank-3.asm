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

IF _NTSC

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

ENDIF

; ******************************************************************************
;
;       Name: Version number
;       Type: Variable
;   Category: Text
;    Summary: The game's version number
;
; ******************************************************************************

IF _NTSC

 EQUS " 5.0"

ELIF _PAL

 EQUS "<2.8>"

ENDIF

; ******************************************************************************
;
;       Name: Copyright and version message
;       Type: Variable
;   Category: Copy protection
;    Summary: A copyright and version message buried in the code
;
; ******************************************************************************

IF _NTSC

 EQUS "  NES ELITE IMAGE 5.2"
 EQUS "  - "
 EQUS "  24 APR 1992"
 EQUS "  (C) D.Braben & I.Bell 1991/92"
 EQUS "  "

ELIF _PAL

 EQUS "  NES ELITE IMAGE 2.8"
 EQUS "  - "
 EQUS "  04 MAR 1992"
 EQUS "  (C) D.Braben & I.Bell 1991/92"
 EQUS "  "

ENDIF

 EQUB $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
 EQUB $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
 EQUB $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
 EQUB $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
 EQUB $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
 EQUB $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
 EQUB $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
 EQUB $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
 EQUB $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
 EQUB $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
 EQUB $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
 EQUB $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
 EQUB $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
 EQUB $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
 EQUB $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
 EQUB $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
 EQUB $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
 EQUB $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
 EQUB $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
 EQUB $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
 EQUB $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
 EQUB $FF, $FF, $FF, $FF, $FF

; ******************************************************************************
;
;       Name: iconBarImage0
;       Type: Variable
;   Category: Drawing images
;    Summary: Image data for icon bar 0 (docked)
;
; ******************************************************************************

.iconBarImage0

 EQUB $00, $00, $00, $00, $00, $00, $00, $00
 EQUB $FE, $FF, $FF, $FF, $FF, $FF, $FF, $FF
 EQUB $00, $00, $00, $00, $00, $00, $00, $00
 EQUB $00, $01, $01, $7D, $7D, $BB, $BB, $BB
 EQUB $00, $00, $00, $00, $00, $00, $00, $00
 EQUB $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
 EQUB $00, $00, $00, $00, $00, $00, $00, $00
 EQUB $E0, $F0, $F0, $F7, $F7, $FB, $FB, $FB
 EQUB $00, $00, $00, $00, $00, $00, $00, $00
 EQUB $03, $03, $03, $03, $03, $03, $07, $07
 EQUB $00, $00, $00, $00, $00, $00, $00, $00
 EQUB $C0, $C0, $C0, $C0, $C0, $C0, $E0, $E0
 EQUB $00, $00, $00, $00, $02, $06, $0E, $06
 EQUB $0F, $1F, $1C, $DC, $DA, $B6, $AE, $B6
 EQUB $00, $00, $00, $84, $20, $50, $88, $50
 EQUB $FE, $FF, $01, $29, $55, $A9, $05, $A9
 EQUB $00, $00, $00, $00, $00, $00, $00, $01
 EQUB $FF, $F7, $61, $57, $41, $75, $43, $77
 EQUB $00, $00, $00, $00, $00, $40, $A0, $00
 EQUB $E0, $F0, $F0, $F7, $F7, $FB, $FB, $FB
 EQUB $00, $00, $0D, $00, $07, $00, $00, $00
 EQUB $0F, $1F, $12, $DF, $D8, $BF, $A5, $AD
 EQUB $00, $00, $6A, $00, $58, $00, $00, $00
 EQUB $FE, $FF, $95, $FF, $A7, $FF, $A0, $B5
 EQUB $00, $00, $1C, $63, $41, $80, $80, $80
 EQUB $FF, $FF, $FF, $FF, $FF, $F7, $E3, $F7
 EQUB $00, $00, $00, $40, $00, $80, $90, $80
 EQUB $E0, $F0, $F0, $B7, $F7, $FB, $EB, $FB
 EQUB $00, $00, $00, $00, $00, $00, $07, $00
 EQUB $0F, $1F, $1F, $DF, $DF, $B0, $B7, $B0
 EQUB $00, $00, $00, $00, $1C, $20, $E0, $20
 EQUB $FE, $FF, $FF, $E3, $DD, $21, $EF, $21
 EQUB $00, $00, $0F, $00, $3F, $01, $7D, $44
 EQUB $FF, $F0, $E0, $E0, $FF, $01, $01, $00
 EQUB $00, $00, $80, $40, $40, $40, $40, $40
 EQUB $E0, $10, $10, $17, $17, $1B, $1B, $1B
 EQUB $00, $00, $00, $00, $00, $00, $00, $00
 EQUB $0F, $1F, $1F, $D1, $D5, $B1, $B5, $B5
 EQUB $00, $00, $00, $0E, $0A, $0E, $0A, $0A
 EQUB $FE, $FF, $FF, $11, $55, $11, $55, $55
 EQUB $00, $00, $00, $6C, $00, $5D, $00, $EC
 EQUB $FF, $FF, $FF, $92, $FE, $A3, $FE, $12
 EQUB $00, $00, $00, $00, $C0, $E0, $C0, $00
 EQUB $E0, $F0, $F0, $17, $D7, $FB, $DB, $1B
 EQUB $00, $00, $00, $01, $02, $02, $02, $02
 EQUB $0F, $1F, $1C, $D9, $DA, $BA, $BA, $BA
 EQUB $00, $00, $C0, $E0, $D0, $10, $D0, $D0
 EQUB $FE, $3F, $CF, $E7, $C7, $07, $07, $07
 EQUB $00, $00, $00, $00, $00, $00, $00, $00
 EQUB $00, $00, $00, $00, $00, $00, $00, $00
 EQUB $00, $00, $00, $00, $00, $00, $00, $00
 EQUB $00, $00, $00, $00, $00, $00, $00, $00
 EQUB $00, $00, $00, $00, $00, $00, $00, $00
 EQUB $00, $00, $00, $00, $00, $00, $00, $00
 EQUB $00, $00, $00, $00, $00, $00, $00, $00
 EQUB $00, $00, $00, $00, $00, $00, $00, $00
 EQUB $00, $00, $00, $00, $00, $00, $00, $00
 EQUB $00, $00, $00, $00, $00, $00, $00, $00
 EQUB $00, $00, $00, $00, $00, $00, $00, $00
 EQUB $00, $00, $00, $00, $00, $00, $00, $00
 EQUB $00, $00, $00, $00, $00, $00, $00, $00
 EQUB $00, $00, $00, $00, $00, $00, $00, $00
 EQUB $00, $00, $00, $20, $1F, $00, $20, $00
 EQUB $3F, $3F, $3F, $1F, $20, $00, $5F, $40
 EQUB $00, $00, $00, $00, $FF, $00, $00, $00
 EQUB $FF, $FF, $FF, $FF, $00, $00, $FF, $00
 EQUB $00, $00, $00, $82, $01, $10, $92, $10
 EQUB $93, $93, $93, $11, $92, $00, $45, $44
 EQUB $00, $00, $00, $08, $F0, $01, $09, $01
 EQUB $F9, $F9, $F9, $F1, $09, $00, $F4, $04
 EQUB $00, $00, $00, $00, $00, $00, $01, $0B
 EQUB $0F, $0F, $1F, $1F, $3F, $3F, $7E, $74
 EQUB $00, $00, $00, $00, $00, $00, $80, $D0
 EQUB $F0, $F0, $F8, $F8, $FC, $FC, $7E, $2E
 EQUB $02, $00, $00, $20, $1F, $00, $20, $00
 EQUB $3A, $3C, $3C, $1F, $20, $00, $5F, $40
 EQUB $20, $00, $00, $00, $FF, $00, $00, $00
 EQUB $55, $AD, $01, $FF, $00, $00, $FF, $00
 EQUB $22, $54, $08, $00, $FF, $00, $00, $00
 EQUB $7F, $7F, $08, $FF, $00, $00, $FF, $00
 EQUB $00, $00, $00, $08, $F0, $01, $09, $01
 EQUB $F9, $F9, $19, $F1, $09, $00, $F4, $04
 EQUB $00, $00, $00, $20, $1F, $00, $20, $00
 EQUB $25, $2D, $24, $1F, $20, $00, $5F, $40
 EQUB $00, $00, $00, $00, $FF, $00, $00, $00
 EQUB $B4, $B5, $B4, $FF, $00, $00, $FF, $00
 EQUB $41, $63, $1C, $00, $FF, $00, $00, $00
 EQUB $FF, $FF, $FF, $FF, $00, $00, $FF, $00
 EQUB $00, $20, $00, $08, $F0, $01, $09, $01
 EQUB $F9, $D9, $F9, $F1, $09, $00, $F4, $04
 EQUB $1C, $00, $00, $00, $FF, $00, $00, $00
 EQUB $DD, $E3, $FF, $FF, $00, $00, $FF, $00
 EQUB $7D, $01, $1F, $00, $FF, $00, $00, $00
 EQUB $00, $00, $C0, $C0, $00, $00, $FF, $00
 EQUB $40, $40, $00, $08, $F0, $01, $09, $01
 EQUB $19, $19, $39, $71, $09, $00, $F4, $04
 EQUB $00, $0E, $00, $00, $FF, $00, $00, $00
 EQUB $FF, $FF, $FF, $FF, $00, $00, $FF, $00
 EQUB $00, $DD, $00, $00, $FF, $00, $00, $00
 EQUB $FF, $22, $FF, $FF, $00, $00, $FF, $00
 EQUB $00, $A0, $00, $08, $F0, $01, $09, $01
 EQUB $F9, $59, $F9, $F1, $09, $00, $F4, $04
 EQUB $02, $02, $00, $20, $1F, $00, $20, $00
 EQUB $3A, $3A, $3C, $1F, $20, $00, $5F, $40
 EQUB $D0, $D0, $C0, $00, $FF, $00, $00, $00
 EQUB $07, $07, $0F, $3F, $00, $00, $FF, $00
 EQUB $00, $00, $00, $00, $00, $00, $00, $00
 EQUB $00, $00, $00, $00, $00, $00, $00, $00
 EQUB $00, $00, $00, $00, $00, $00, $00, $00
 EQUB $00, $00, $00, $00, $00, $00, $00, $00
 EQUB $00, $00, $00, $00, $00, $00, $00, $00
 EQUB $00, $00, $00, $00, $00, $00, $00, $00
 EQUB $00, $00, $00, $00, $00, $00, $00, $00
 EQUB $00, $00, $00, $00, $00, $00, $00, $00
 EQUB $00, $00, $00, $00, $00, $00, $00, $00
 EQUB $00, $00, $00, $00, $00, $00, $00, $00
 EQUB $00, $00, $00, $00, $00, $00, $00, $00
 EQUB $00, $00, $00, $00, $00, $00, $00, $00
 EQUB $00, $00, $00, $00, $00, $00, $00, $00
 EQUB $00, $00, $00, $00, $00, $00, $00, $00
 EQUB $00, $00, $00, $00, $00, $00, $00, $00
 EQUB $00, $00, $00, $00, $00, $00, $00, $00
 EQUB $00, $00, $00, $00, $00, $00, $00, $00
 EQUB $00, $00, $00, $00, $00, $00, $00, $00
 EQUB $00, $00, $00, $00, $00, $00, $00, $00
 EQUB $00, $00, $00, $00, $00, $00, $00, $00
 EQUB $00, $00, $00, $00, $00, $00, $00, $00
 EQUB $00, $00, $00, $00, $00, $00, $00, $00

; ******************************************************************************
;
;       Name: iconBarImage1
;       Type: Variable
;   Category: Drawing images
;    Summary: Image data for icon bar 1 (flight)
;
; ******************************************************************************

.iconBarImage1

 EQUB $00, $00, $00, $00, $00, $00, $00, $00
 EQUB $FE, $FF, $FF, $FF, $FF, $FF, $FF, $FF
 EQUB $00, $00, $00, $00, $00, $00, $00, $00
 EQUB $00, $01, $01, $7D, $7D, $BB, $BB, $BB
 EQUB $00, $00, $00, $00, $00, $00, $00, $00
 EQUB $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
 EQUB $00, $00, $00, $00, $00, $00, $00, $00
 EQUB $E0, $F0, $F0, $F7, $F7, $FB, $FB, $FB
 EQUB $00, $00, $00, $00, $00, $00, $00, $00
 EQUB $03, $03, $03, $03, $03, $03, $07, $07
 EQUB $00, $00, $00, $00, $00, $00, $00, $00
 EQUB $C0, $C0, $C0, $C0, $C0, $C0, $E0, $E0
 EQUB $00, $00, $00, $01, $05, $06, $07, $06
 EQUB $0F, $1F, $1C, $D0, $D4, $B6, $B7, $B6
 EQUB $00, $00, $00, $84, $20, $50, $08, $50
 EQUB $FE, $FF, $01, $29, $55, $A9, $05, $A9
 EQUB $00, $00, $00, $00, $00, $00, $00, $01
 EQUB $FF, $F7, $61, $57, $41, $75, $43, $77
 EQUB $00, $00, $00, $00, $00, $40, $A0, $00
 EQUB $E0, $F0, $F0, $F7, $F7, $FB, $FB, $FB
 EQUB $00, $00, $0D, $00, $07, $00, $00, $00
 EQUB $0F, $1F, $12, $DF, $D8, $BF, $A5, $AD
 EQUB $00, $00, $6A, $00, $58, $00, $00, $00
 EQUB $FE, $FF, $95, $FF, $A7, $FF, $A0, $B5
 EQUB $00, $00, $1C, $63, $41, $80, $80, $80
 EQUB $FF, $FF, $FF, $FF, $FF, $F7, $E3, $F7
 EQUB $00, $00, $00, $40, $00, $80, $90, $80
 EQUB $E0, $F0, $F0, $B7, $F7, $FB, $EB, $FB
 EQUB $00, $00, $02, $00, $00, $04, $00, $01
 EQUB $0F, $1F, $1D, $DF, $DF, $BA, $BF, $BF
 EQUB $00, $00, $00, $04, $00, $00, $A0, $10
 EQUB $FE, $FF, $FF, $BB, $BF, $4F, $BF, $BF
 EQUB $00, $00, $00, $00, $00, $00, $00, $00
 EQUB $00, $01, $01, $7D, $7D, $BB, $BA, $BB
 EQUB $00, $00, $00, $03, $27, $6F, $EF, $6F
 EQUB $FF, $FF, $FC, $D0, $A6, $6B, $E3, $65
 EQUB $00, $00, $00, $80, $C0, $E0, $E0, $E0
 EQUB $E0, $F0, $70, $97, $57, $EB, $2B, $2B
 EQUB $00, $00, $00, $02, $05, $08, $02, $01
 EQUB $0F, $1F, $1F, $DD, $D8, $B2, $B5, $BC
 EQUB $00, $00, $10, $28, $42, $84, $28, $52
 EQUB $FE, $FF, $EF, $C7, $95, $39, $53, $85
 EQUB $00, $00, $00, $00, $00, $00, $00, $01
 EQUB $00, $01, $01, $7D, $7D, $BB, $BB, $BA
 EQUB $00, $00, $02, $04, $08, $10, $E0, $C0
 EQUB $FF, $FF, $FC, $F8, $F1, $E3, $06, $0E
 EQUB $00, $00, $00, $00, $00, $03, $07, $02
 EQUB $0F, $1F, $1F, $DF, $DF, $BC, $B8, $B8
 EQUB $00, $08, $10, $20, $40, $80, $00, $40
 EQUB $FE, $F3, $E3, $C7, $8F, $1F, $3F, $3F
 EQUB $00, $00, $24, $1F, $1F, $7F, $1F, $1F
 EQUB $FF, $BB, $FB, $E0, $E0, $40, $E0, $E0
 EQUB $00, $00, $80, $00, $00, $C0, $00, $00
 EQUB $E0, $B0, $F0, $F7, $F7, $5B, $FB, $FB
 EQUB $00, $00, $00, $00, $01, $00, $00, $00
 EQUB $0F, $1F, $1F, $DE, $DD, $BC, $BF, $BC
 EQUB $00, $00, $40, $E0, $F0, $00, $00, $00
 EQUB $FE, $BF, $5F, $EF, $F7, $07, $FF, $07
 EQUB $00, $00, $00, $21, $31, $39, $31, $21
 EQUB $FF, $FF, $9C, $AD, $B5, $B9, $B5, $AD
 EQUB $00, $00, $00, $00, $80, $C0, $80, $00
 EQUB $E0, $F0, $F0, $77, $B7, $DB, $BB, $7B
 EQUB $00, $00, $00, $20, $1F, $00, $20, $00
 EQUB $3F, $3F, $3F, $1F, $20, $00, $5F, $40
 EQUB $00, $00, $00, $00, $FF, $00, $00, $00
 EQUB $FF, $FF, $FF, $FF, $00, $00, $FF, $00
 EQUB $00, $00, $00, $82, $01, $10, $92, $10
 EQUB $93, $93, $93, $11, $92, $00, $45, $44
 EQUB $00, $00, $00, $08, $F0, $01, $09, $01
 EQUB $F9, $F9, $F9, $F1, $09, $00, $F4, $04
 EQUB $00, $00, $00, $00, $00, $00, $01, $0B
 EQUB $0F, $0F, $1F, $1F, $3F, $3F, $7E, $74
 EQUB $00, $00, $00, $00, $00, $00, $80, $D0
 EQUB $F0, $F0, $F8, $F8, $FC, $FC, $7E, $2E
 EQUB $04, $01, $00, $20, $1F, $00, $20, $00
 EQUB $35, $30, $3C, $1F, $20, $00, $5F, $40
 EQUB $20, $00, $00, $00, $FF, $00, $00, $00
 EQUB $55, $AD, $01, $FF, $00, $00, $FF, $00
 EQUB $22, $54, $08, $00, $FF, $00, $00, $00
 EQUB $7F, $7F, $08, $FF, $00, $00, $FF, $00
 EQUB $00, $00, $00, $08, $F0, $01, $09, $01
 EQUB $F9, $F9, $19, $F1, $09, $00, $F4, $04
 EQUB $00, $00, $00, $20, $1F, $00, $20, $00
 EQUB $25, $2D, $24, $1F, $20, $00, $5F, $40
 EQUB $00, $00, $00, $00, $FF, $00, $00, $00
 EQUB $B4, $B5, $B4, $FF, $00, $00, $FF, $00
 EQUB $41, $63, $1C, $00, $FF, $00, $00, $00
 EQUB $FF, $FF, $FF, $FF, $00, $00, $FF, $00
 EQUB $00, $20, $00, $08, $F0, $01, $09, $01
 EQUB $F9, $D9, $F9, $F1, $09, $00, $F4, $04
 EQUB $06, $1C, $08, $20, $1F, $00, $20, $00
 EQUB $3F, $3F, $3F, $1F, $20, $00, $5F, $40
 EQUB $0C, $47, $02, $00, $FF, $00, $00, $00
 EQUB $FF, $BF, $FF, $FF, $00, $00, $FF, $00
 EQUB $27, $03, $00, $00, $FF, $00, $00, $00
 EQUB $A7, $D2, $FC, $FF, $00, $00, $FF, $00
 EQUB $C0, $80, $00, $08, $F0, $01, $09, $01
 EQUB $59, $99, $79, $F1, $09, $00, $F4, $04
 EQUB $00, $00, $00, $20, $1F, $00, $20, $00
 EQUB $3E, $3F, $3F, $1F, $20, $00, $5F, $40
 EQUB $80, $00, $00, $00, $FF, $00, $00, $00
 EQUB $2D, $7F, $FF, $FF, $00, $00, $FF, $00
 EQUB $90, $30, $20, $00, $FF, $00, $00, $00
 EQUB $09, $8E, $DE, $FF, $00, $00, $FF, $00
 EQUB $00, $00, $00, $08, $F0, $01, $09, $01
 EQUB $39, $F9, $F9, $F1, $09, $00, $F4, $04
 EQUB $04, $06, $00, $20, $1F, $00, $20, $00
 EQUB $34, $36, $31, $1F, $20, $00, $5F, $40
 EQUB $C0, $80, $00, $00, $FF, $00, $00, $00
 EQUB $3F, $7F, $FF, $FF, $00, $00, $FF, $00
 EQUB $24, $00, $00, $00, $FF, $00, $00, $00
 EQUB $FB, $BB, $FF, $FF, $00, $00, $FF, $00
 EQUB $80, $00, $00, $08, $F0, $01, $09, $01
 EQUB $F9, $B9, $F9, $F1, $09, $00, $F4, $04
 EQUB $01, $00, $00, $20, $1F, $00, $20, $00
 EQUB $3D, $3C, $3F, $1F, $20, $00, $5F, $40
 EQUB $F0, $00, $00, $00, $FF, $00, $00, $00
 EQUB $F7, $07, $FF, $FF, $00, $00, $FF, $00
 EQUB $00, $00, $00, $00, $FF, $00, $00, $00
 EQUB $9C, $FF, $FF, $FF, $00, $00, $FF, $00
 EQUB $00, $00, $00, $00, $00, $00, $00, $00
 EQUB $00, $00, $00, $00, $00, $00, $00, $00
 EQUB $00, $00, $00, $00, $00, $00, $00, $00
 EQUB $00, $00, $00, $00, $00, $00, $00, $00
 EQUB $00, $00, $00, $00, $00, $00, $00, $00
 EQUB $00, $00, $00, $00, $00, $00, $00, $00
 EQUB $00, $00, $00, $00, $00, $00, $00, $00
 EQUB $00, $00, $00, $00, $00, $00, $00, $00

; ******************************************************************************
;
;       Name: iconBarImage2
;       Type: Variable
;   Category: Drawing images
;    Summary: Image data for icon bar 2 (charts)
;
; ******************************************************************************

.iconBarImage2

 EQUB $00, $00, $00, $00, $00, $00, $00, $00
 EQUB $FE, $FF, $FF, $FF, $FF, $FF, $FF, $FF
 EQUB $00, $00, $00, $00, $00, $00, $00, $00
 EQUB $00, $01, $01, $7D, $7D, $BB, $BB, $BB
 EQUB $00, $00, $00, $00, $00, $00, $00, $00
 EQUB $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
 EQUB $00, $00, $00, $00, $00, $00, $00, $00
 EQUB $E0, $F0, $F0, $F7, $F7, $FB, $FB, $FB
 EQUB $00, $00, $00, $00, $00, $00, $00, $00
 EQUB $03, $03, $03, $03, $03, $03, $07, $07
 EQUB $00, $00, $00, $00, $00, $00, $00, $00
 EQUB $C0, $C0, $C0, $C0, $C0, $C0, $E0, $E0
 EQUB $00, $00, $00, $00, $02, $06, $0E, $06
 EQUB $0F, $1F, $1C, $DC, $DA, $B6, $AE, $B6
 EQUB $00, $00, $00, $84, $20, $50, $88, $50
 EQUB $FE, $FF, $01, $29, $55, $A9, $05, $A9
 EQUB $00, $00, $00, $00, $00, $00, $00, $01
 EQUB $FF, $F7, $61, $57, $41, $75, $43, $77
 EQUB $00, $00, $00, $00, $00, $40, $A0, $00
 EQUB $E0, $F0, $F0, $F7, $F7, $FB, $FB, $FB
 EQUB $00, $00, $01, $06, $04, $08, $08, $08
 EQUB $0F, $1F, $1F, $DF, $DF, $BF, $BE, $BF
 EQUB $00, $00, $C0, $34, $10, $08, $09, $08
 EQUB $FE, $FF, $FF, $FB, $FF, $7F, $3E, $7F
 EQUB $00, $00, $00, $6C, $00, $5D, $00, $EC
 EQUB $FF, $FF, $FF, $92, $FE, $A3, $FE, $12
 EQUB $00, $00, $00, $00, $C0, $E0, $C0, $00
 EQUB $E0, $F0, $F0, $17, $D7, $FB, $DB, $1B
 EQUB $00, $00, $02, $00, $00, $04, $00, $01
 EQUB $0F, $1F, $1D, $DF, $DF, $BA, $BF, $BF
 EQUB $00, $00, $00, $04, $00, $00, $A0, $10
 EQUB $FE, $FF, $FF, $BB, $BF, $4F, $BF, $BF
 EQUB $00, $00, $04, $04, $04, $04, $7B, $04
 EQUB $FF, $FF, $FB, $C0, $DB, $DB, $84, $DB
 EQUB $00, $00, $00, $00, $00, $00, $C0, $00
 EQUB $E0, $F0, $F0, $77, $77, $7B, $3B, $7B
 EQUB $00, $00, $00, $00, $00, $00, $00, $00
 EQUB $0F, $1F, $1E, $DC, $DF, $BF, $BF, $BF
 EQUB $00, $00, $00, $00, $00, $00, $00, $00
 EQUB $FE, $FF, $0F, $E7, $C7, $8F, $9F, $FF
 EQUB $00, $00, $00, $00, $00, $00, $00, $00
 EQUB $00, $01, $01, $7D, $7D, $BB, $BA, $BB
 EQUB $00, $00, $00, $03, $27, $6F, $EF, $6F
 EQUB $FF, $FF, $FC, $D0, $A6, $6B, $E3, $65
 EQUB $00, $00, $00, $80, $C0, $E0, $E0, $E0
 EQUB $E0, $F0, $70, $97, $57, $EB, $2B, $2B
 EQUB $00, $00, $00, $00, $02, $06, $0E, $06
 EQUB $0F, $1F, $1F, $DD, $DA, $B6, $AE, $B6
 EQUB $00, $00, $00, $00, $10, $30, $38, $38
 EQUB $FE, $FF, $FF, $C3, $A9, $46, $43, $85
 EQUB $00, $00, $01, $22, $54, $88, $22, $15
 EQUB $FF, $FF, $FE, $DC, $89, $23, $55, $C8
 EQUB $00, $00, $00, $80, $20, $40, $80, $20
 EQUB $E0, $F0, $F0, $77, $57, $9B, $3B, $5B
 EQUB $00, $00, $00, $00, $01, $00, $00, $00
 EQUB $0F, $1F, $1F, $DE, $DD, $BC, $BF, $BC
 EQUB $00, $00, $40, $E0, $F0, $00, $00, $00
 EQUB $FE, $BF, $5F, $EF, $F7, $07, $FF, $07
 EQUB $00, $00, $00, $21, $31, $39, $31, $21
 EQUB $FF, $FF, $9C, $AD, $B5, $B9, $B5, $AD
 EQUB $00, $00, $00, $00, $80, $C0, $80, $00
 EQUB $E0, $F0, $F0, $77, $B7, $DB, $BB, $7B
 EQUB $00, $00, $00, $20, $1F, $00, $20, $00
 EQUB $3F, $3F, $3F, $1F, $20, $00, $5F, $40
 EQUB $00, $00, $00, $00, $FF, $00, $00, $00
 EQUB $FF, $FF, $FF, $FF, $00, $00, $FF, $00
 EQUB $00, $00, $00, $82, $01, $10, $92, $10
 EQUB $93, $93, $93, $11, $92, $00, $45, $44
 EQUB $00, $00, $00, $08, $F0, $01, $09, $01
 EQUB $F9, $F9, $F9, $F1, $09, $00, $F4, $04
 EQUB $00, $00, $00, $00, $00, $00, $01, $0B
 EQUB $0F, $0F, $1F, $1F, $3F, $3F, $7E, $74
 EQUB $00, $00, $00, $00, $00, $00, $80, $D0
 EQUB $F0, $F0, $F8, $F8, $FC, $FC, $7E, $2E
 EQUB $02, $00, $00, $20, $1F, $00, $20, $00
 EQUB $3A, $3C, $3C, $1F, $20, $00, $5F, $40
 EQUB $20, $00, $00, $00, $FF, $00, $00, $00
 EQUB $55, $AD, $01, $FF, $00, $00, $FF, $00
 EQUB $22, $54, $08, $00, $FF, $00, $00, $00
 EQUB $7F, $7F, $08, $FF, $00, $00, $FF, $00
 EQUB $00, $00, $00, $08, $F0, $01, $09, $01
 EQUB $F9, $F9, $19, $F1, $09, $00, $F4, $04
 EQUB $04, $06, $01, $20, $1F, $00, $20, $00
 EQUB $3F, $3F, $3F, $1F, $20, $00, $5F, $40
 EQUB $10, $32, $C0, $00, $FF, $00, $00, $00
 EQUB $FF, $FD, $FF, $FF, $00, $00, $FF, $00
 EQUB $00, $DD, $00, $00, $FF, $00, $00, $00
 EQUB $FF, $22, $FF, $FF, $00, $00, $FF, $00
 EQUB $00, $A0, $00, $08, $F0, $01, $09, $01
 EQUB $F9, $59, $F9, $F1, $09, $00, $F4, $04
 EQUB $06, $1C, $08, $20, $1F, $00, $20, $00
 EQUB $3F, $3F, $3F, $1F, $20, $00, $5F, $40
 EQUB $0C, $47, $02, $00, $FF, $00, $00, $00
 EQUB $FF, $BF, $FF, $FF, $00, $00, $FF, $00
 EQUB $04, $04, $04, $00, $FF, $00, $00, $00
 EQUB $DB, $C0, $FB, $FF, $00, $00, $FF, $00
 EQUB $00, $00, $00, $08, $F0, $01, $09, $01
 EQUB $79, $79, $F9, $F1, $09, $00, $F4, $04
 EQUB $00, $00, $00, $00, $FF, $00, $00, $00
 EQUB $9F, $9F, $FF, $FF, $00, $00, $FF, $00
 EQUB $27, $03, $00, $00, $FF, $00, $00, $00
 EQUB $A7, $D2, $FC, $FF, $00, $00, $FF, $00
 EQUB $C0, $80, $00, $08, $F0, $01, $09, $01
 EQUB $59, $99, $79, $F1, $09, $00, $F4, $04
 EQUB $02, $00, $00, $20, $1F, $00, $20, $00
 EQUB $3A, $3D, $3F, $1F, $20, $00, $5F, $40
 EQUB $18, $10, $00, $00, $FF, $00, $00, $00
 EQUB $C5, $2B, $87, $FF, $00, $00, $FF, $00
 EQUB $08, $00, $00, $00, $FF, $00, $00, $00
 EQUB $E2, $F7, $FF, $FF, $00, $00, $FF, $00
 EQUB $00, $00, $00, $08, $F0, $01, $09, $01
 EQUB $D9, $F9, $F9, $F1, $09, $00, $F4, $04
 EQUB $01, $00, $00, $20, $1F, $00, $20, $00
 EQUB $3D, $3C, $3F, $1F, $20, $00, $5F, $40
 EQUB $F0, $00, $00, $00, $FF, $00, $00, $00
 EQUB $F7, $07, $FF, $FF, $00, $00, $FF, $00
 EQUB $00, $00, $00, $00, $FF, $00, $00, $00
 EQUB $9C, $FF, $FF, $FF, $00, $00, $FF, $00
 EQUB $00, $00, $00, $00, $00, $00, $00, $00
 EQUB $00, $00, $00, $00, $00, $00, $00, $00
 EQUB $00, $00, $00, $00, $00, $00, $00, $00
 EQUB $00, $00, $00, $00, $00, $00, $00, $00
 EQUB $00, $00, $00, $00, $00, $00, $00, $00
 EQUB $00, $00, $00, $00, $00, $00, $00, $00
 EQUB $00, $00, $00, $00, $00, $00, $00, $00
 EQUB $00, $00, $00, $00, $00, $00, $00, $00
 EQUB $00, $00, $00, $00, $00, $00, $00, $00
 EQUB $00, $00, $00, $00, $00, $00, $00, $00

; ******************************************************************************
;
;       Name: iconBarImage3
;       Type: Variable
;   Category: Drawing images
;    Summary: Image data for icon bar 3 (pause options)
;
; ******************************************************************************

.iconBarImage3

 EQUB $00, $00, $00, $00, $00, $00, $00, $00
 EQUB $FE, $FF, $FF, $FF, $FF, $FF, $FF, $FF
 EQUB $00, $00, $00, $00, $00, $00, $00, $00
 EQUB $00, $01, $01, $7D, $7D, $BB, $BB, $BB
 EQUB $00, $00, $00, $00, $00, $00, $00, $00
 EQUB $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
 EQUB $00, $00, $00, $00, $00, $00, $00, $00
 EQUB $E0, $F0, $F0, $F7, $F7, $FB, $FB, $FB
 EQUB $00, $00, $00, $00, $00, $00, $00, $00
 EQUB $03, $03, $03, $03, $03, $03, $07, $07
 EQUB $00, $00, $00, $00, $00, $00, $00, $00
 EQUB $C0, $C0, $C0, $C0, $C0, $C0, $E0, $E0
 EQUB $00, $00, $01, $00, $00, $00, $00, $00
 EQUB $0F, $1C, $1D, $DE, $DF, $BF, $BF, $BF
 EQUB $00, $00, $F0, $E0, $40, $00, $00, $00
 EQUB $FE, $07, $F7, $EF, $5F, $BF, $FF, $BF
 EQUB $00, $00, $00, $00, $00, $00, $00, $00
 EQUB $00, $01, $01, $7D, $7D, $BB, $BA, $BA
 EQUB $00, $00, $00, $00, $00, $00, $00, $00
 EQUB $FF, $FF, $FF, $E0, $9F, $7F, $FF, $FF
 EQUB $00, $00, $00, $00, $00, $00, $00, $00
 EQUB $E0, $F0, $F0, $F7, $37, $DB, $EB, $EB
 EQUB $00, $00, $00, $00, $00, $00, $00, $00
 EQUB $0F, $1F, $1E, $DE, $DE, $BE, $BE, $B8
 EQUB $00, $00, $00, $00, $00, $00, $00, $00
 EQUB $FE, $FF, $03, $03, $FB, $FB, $FB, $E3
 EQUB $00, $00, $00, $00, $00, $00, $00, $00
 EQUB $FF, $FF, $FE, $FC, $C8, $C8, $C8, $C8
 EQUB $00, $00, $00, $00, $00, $00, $00, $00
 EQUB $0F, $1F, $1C, $D8, $D8, $BC, $B8, $B8
 EQUB $00, $00, $00, $00, $00, $00, $00, $00
 EQUB $FE, $FF, $FF, $7F, $67, $C3, $43, $67
 EQUB $00, $00, $1F, $31, $3F, $28, $3F, $25
 EQUB $FF, $FF, $E0, $C0, $C0, $C0, $C0, $C0
 EQUB $00, $00, $00, $80, $80, $80, $80, $80
 EQUB $E0, $F0, $70, $77, $37, $3B, $3B, $3B
 EQUB $00, $00, $00, $00, $01, $00, $00, $00
 EQUB $0F, $1F, $1F, $DE, $DD, $BC, $BF, $BC
 EQUB $00, $00, $40, $E0, $F0, $00, $00, $00
 EQUB $FE, $BF, $5F, $EF, $F7, $07, $FF, $07
 EQUB $00, $00, $00, $00, $00, $00, $00, $00
 EQUB $FF, $FF, $FF, $EA, $9F, $7F, $FF, $FF
 EQUB $00, $00, $00, $00, $00, $00, $00, $00
 EQUB $E0, $F0, $F0, $F7, $B7, $FB, $FB, $FB
 EQUB $00, $00, $04, $02, $01, $00, $00, $00
 EQUB $0F, $1F, $1A, $DC, $DE, $BE, $BE, $B8
 EQUB $00, $00, $04, $08, $10, $A0, $40, $A0
 EQUB $FE, $FF, $03, $03, $EB, $5B, $BB, $43
 EQUB $00, $00, $40, $20, $11, $0A, $04, $0A
 EQUB $FF, $FF, $BE, $DC, $C8, $C0, $C8, $C0
 EQUB $00, $00, $40, $80, $00, $00, $00, $00
 EQUB $E0, $F0, $B0, $77, $F7, $FB, $FB, $FB
 EQUB $00, $00, $00, $00, $00, $00, $00, $00
 EQUB $0F, $1F, $1F, $DE, $DE, $BE, $BF, $BE
 EQUB $00, $00, $00, $00, $00, $00, $00, $00
 EQUB $FE, $FF, $1F, $0F, $0F, $0F, $1F, $0F
 EQUB $00, $00, $00, $00, $00, $00, $00, $00
 EQUB $00, $00, $00, $00, $00, $00, $00, $00
 EQUB $00, $00, $00, $00, $00, $00, $00, $00
 EQUB $00, $00, $00, $00, $00, $00, $00, $00
 EQUB $00, $00, $00, $00, $00, $00, $00, $00
 EQUB $00, $00, $00, $00, $00, $00, $00, $00
 EQUB $00, $00, $00, $20, $1F, $00, $20, $00
 EQUB $3F, $3F, $3F, $1F, $20, $00, $5F, $40
 EQUB $00, $00, $00, $00, $FF, $00, $00, $00
 EQUB $FF, $FF, $FF, $FF, $00, $00, $FF, $00
 EQUB $00, $00, $00, $82, $01, $10, $92, $10
 EQUB $93, $93, $93, $11, $92, $00, $45, $44
 EQUB $00, $00, $00, $08, $F0, $01, $09, $01
 EQUB $F9, $F9, $F9, $F1, $09, $00, $F4, $04
 EQUB $00, $00, $00, $00, $00, $00, $01, $0B
 EQUB $0F, $0F, $1F, $1F, $3F, $3F, $7E, $74
 EQUB $00, $00, $00, $00, $00, $00, $80, $D0
 EQUB $F0, $F0, $F8, $F8, $FC, $FC, $7E, $2E
 EQUB $00, $00, $01, $20, $1F, $00, $20, $00
 EQUB $3F, $3E, $3D, $1C, $20, $00, $5F, $40
 EQUB $40, $E0, $F0, $00, $FF, $00, $00, $00
 EQUB $5F, $EF, $F7, $07, $00, $00, $FF, $00
 EQUB $00, $00, $00, $00, $FF, $00, $00, $00
 EQUB $7F, $9F, $E0, $FF, $00, $00, $FF, $00
 EQUB $00, $00, $00, $08, $F0, $01, $09, $00
 EQUB $D9, $39, $F9, $F1, $09, $00, $F4, $04
 EQUB $00, $00, $00, $20, $1F, $00, $20, $00
 EQUB $30, $30, $39, $1F, $20, $00, $5F, $40
 EQUB $00, $00, $00, $00, $FF, $00, $00, $00
 EQUB $C3, $C3, $E7, $FF, $00, $00, $FF, $00
 EQUB $00, $00, $00, $00, $FF, $00, $00, $00
 EQUB $C8, $FC, $FE, $FF, $00, $00, $FF, $00
 EQUB $00, $00, $00, $00, $FF, $00, $00, $00
 EQUB $C3, $C3, $FF, $FF, $00, $00, $FF, $00
 EQUB $3F, $7F, $7F, $00, $FF, $00, $00, $00
 EQUB $C0, $E4, $FF, $FF, $00, $00, $FF, $00
 EQUB $80, $A0, $E0, $08, $F0, $01, $09, $01
 EQUB $39, $F9, $F9, $F1, $09, $00, $F4, $04
 EQUB $01, $00, $00, $20, $1F, $00, $20, $00
 EQUB $3D, $3E, $3F, $1F, $20, $00, $5F, $40
 EQUB $F0, $E0, $40, $00, $FF, $00, $00, $00
 EQUB $F7, $EF, $5F, $BF, $00, $00, $FF, $00
 EQUB $00, $00, $00, $08, $F0, $01, $09, $01
 EQUB $D9, $39, $F9, $F1, $09, $00, $F4, $04
 EQUB $01, $02, $04, $20, $1F, $00, $20, $00
 EQUB $30, $30, $39, $1F, $20, $00, $5F, $40
 EQUB $10, $08, $04, $00, $FF, $00, $00, $00
 EQUB $C3, $C3, $E3, $FF, $00, $00, $FF, $00
 EQUB $11, $20, $40, $00, $FF, $00, $00, $00
 EQUB $C8, $DC, $BE, $FF, $00, $00, $FF, $00
 EQUB $00, $80, $40, $08, $F0, $01, $09, $01
 EQUB $F9, $79, $B9, $F1, $09, $00, $F4, $04
 EQUB $00, $00, $00, $20, $1F, $00, $20, $00
 EQUB $3C, $3C, $3F, $1F, $20, $00, $5F, $40
 EQUB $00, $00, $00, $00, $FF, $00, $00, $00
 EQUB $07, $07, $FF, $FF, $00, $00, $FF, $00
 EQUB $00, $00, $00, $00, $00, $00, $00, $00
 EQUB $00, $00, $00, $00, $00, $00, $00, $00
 EQUB $00, $00, $00, $00, $00, $00, $00, $00
 EQUB $00, $00, $00, $00, $00, $00, $00, $00
 EQUB $00, $00, $00, $00, $00, $00, $00, $00
 EQUB $00, $00, $00, $00, $00, $00, $00, $00
 EQUB $00, $00, $00, $00, $00, $00, $00, $00
 EQUB $00, $00, $00, $00, $00, $00, $00, $00
 EQUB $00, $00, $00, $00, $00, $00, $00, $00
 EQUB $00, $00, $00, $00, $00, $00, $00, $00
 EQUB $00, $00, $00, $00, $00, $00, $00, $00
 EQUB $00, $00, $00, $00, $00, $00, $00, $00
 EQUB $00, $00, $00, $00, $00, $00, $00, $00
 EQUB $00, $00, $00, $00, $00, $00, $00, $00
 EQUB $00, $00, $00, $00, $00, $00, $00, $00
 EQUB $00, $00, $00, $00, $00, $00, $00, $00

; ******************************************************************************
;
;       Name: iconBarImage4
;       Type: Variable
;   Category: Drawing images
;    Summary: Image data for icon bar 4 (title screen copyright message)
;
; ******************************************************************************

.iconBarImage4

 EQUB $00, $00, $00, $00, $00, $00, $00, $00
 EQUB $0F, $1F, $1F, $DF, $DF, $BF, $BF, $BF
 EQUB $00, $00, $00, $00, $00, $00, $00, $00
 EQUB $FE, $FF, $FF, $FF, $FF, $FF, $FF, $FF
 EQUB $00, $00, $00, $00, $00, $00, $00, $00
 EQUB $00, $01, $01, $7D, $7D, $BB, $BB, $BB
 EQUB $00, $00, $00, $00, $00, $00, $00, $00
 EQUB $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
 EQUB $00, $00, $00, $00, $00, $00, $00, $00
 EQUB $E0, $F0, $F0, $F7, $F7, $FB, $FB, $FB
 EQUB $00, $00, $00, $00, $00, $00, $00, $00
 EQUB $03, $03, $03, $03, $03, $03, $07, $07
 EQUB $00, $00, $00, $00, $00, $00, $00, $00
 EQUB $C0, $C0, $C0, $C0, $C0, $C0, $E0, $E0
 EQUB $00, $00, $00, $00, $00, $F8, $00, $00
 EQUB $FF, $FF, $FF, $FF, $FF, $FF, $07, $FF
 EQUB $00, $00, $FB, $C3, $C3, $C3, $C3, $C3
 EQUB $FF, $FF, $FF, $C7, $FF, $FF, $FF, $FF
 EQUB $00, $00, $EF, $6D, $6D, $6D, $6F, $6C
 EQUB $FF, $FF, $FF, $7D, $FF, $FF, $FF, $FC
 EQUB $00, $00, $B6, $B6, $B6, $B6, $9E, $06
 EQUB $FF, $FF, $FF, $FF, $FF, $FF, $DF, $67
 EQUB $00, $00, $FB, $DB, $DB, $F3, $DB, $DB
 EQUB $FF, $FF, $FF, $DF, $FF, $F7, $DF, $FF
 EQUB $00, $00, $7D, $61, $61, $6D, $6D, $6D
 EQUB $FF, $FF, $FF, $E3, $FF, $FF, $FF, $FF
 EQUB $00, $00, $B7, $B3, $B3, $F3, $B3, $B3
 EQUB $FF, $FF, $FF, $FB, $FF, $FF, $BF, $FF
 EQUB $00, $00, $81, $00, $00, $00, $00, $00
 EQUB $FF, $FF, $FF, $7E, $FF, $FF, $FF, $FF
 EQUB $00, $00, $DF, $DB, $DB, $DB, $DF, $C3
 EQUB $FF, $FF, $FF, $FB, $FF, $FF, $FF, $E3
 EQUB $00, $00, $7D, $6C, $6C, $6C, $7C, $0C
 EQUB $FF, $FF, $FF, $EE, $FF, $FF, $FF, $8F
 EQUB $00, $00, $C0, $C0, $C0, $C0, $C0, $D8
 EQUB $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
 EQUB $00, $00, $F0, $D8, $D8, $D8, $D8, $DB
 EQUB $FF, $FF, $FF, $DF, $FF, $FF, $FF, $FF
 EQUB $00, $00, $7D, $6D, $6D, $79, $6D, $6D
 EQUB $FF, $FF, $FF, $EF, $FF, $FB, $EF, $EF
 EQUB $00, $00, $F7, $B6, $B6, $E7, $B6, $B6
 EQUB $FF, $FF, $FF, $BE, $FF, $EF, $BE, $FF
 EQUB $00, $00, $DF, $DB, $DB, $DE, $DB, $DB
 EQUB $FF, $FF, $FF, $FB, $FF, $FE, $FB, $FF
 EQUB $00, $00, $7D, $61, $61, $79, $61, $61
 EQUB $FF, $FF, $FF, $E3, $FF, $FF, $E7, $FF
 EQUB $00, $00, $F0, $B0, $B0, $B0, $B0, $B0
 EQUB $FF, $FF, $FF, $BF, $FF, $FF, $FF, $FF
 EQUB $00, $00, $3E, $36, $36, $3E, $36, $36
 EQUB $FF, $FF, $FF, $F7, $FF, $FF, $F7, $FF
 EQUB $00, $00, $FB, $DB, $DB, $DB, $DB, $DB
 EQUB $FF, $FF, $FF, $DF, $FF, $FF, $FF, $FF
 EQUB $00, $00, $C0, $60, $60, $60, $60, $60
 EQUB $FF, $FF, $FF, $7F, $FF, $FF, $FF, $FF
 EQUB $00, $00, $78, $30, $30, $30, $30, $33
 EQUB $FF, $FF, $FF, $B7, $FF, $FF, $FF, $FF
 EQUB $00, $00, $7D, $6D, $6D, $79, $6D, $6D
 EQUB $FF, $FF, $FF, $EF, $FF, $FB, $EF, $FF
 EQUB $00, $00, $F6, $86, $86, $E6, $86, $86
 EQUB $FF, $FF, $FF, $8F, $FF, $FF, $9F, $FF
 EQUB $00, $00, $18, $18, $18, $18, $18, $18
 EQUB $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
 EQUB $00, $00, $00, $00, $00, $1F, $00, $00
 EQUB $FF, $FF, $FF, $FF, $FF, $FF, $E0, $FF
 EQUB $00, $00, $00, $20, $1F, $00, $20, $00
 EQUB $3F, $3F, $3F, $1F, $20, $00, $5F, $40
 EQUB $00, $00, $00, $00, $FF, $00, $00, $00
 EQUB $FF, $FF, $FF, $FF, $00, $00, $FF, $00
 EQUB $00, $00, $00, $82, $01, $10, $92, $10
 EQUB $93, $93, $93, $11, $92, $00, $45, $44
 EQUB $00, $00, $00, $08, $F0, $01, $09, $01
 EQUB $F9, $F9, $F9, $F1, $09, $00, $F4, $04
 EQUB $00, $00, $00, $00, $00, $00, $01, $0B
 EQUB $0F, $0F, $1F, $1F, $3F, $3F, $7E, $74
 EQUB $00, $00, $00, $00, $00, $00, $80, $D0
 EQUB $F0, $F0, $F8, $F8, $FC, $FC, $7E, $2E
 EQUB $FB, $00, $00, $00, $FF, $00, $00, $00
 EQUB $FF, $04, $FF, $FF, $00, $00, $FF, $00
 EQUB $EC, $00, $00, $00, $FF, $00, $00, $00
 EQUB $FF, $13, $FF, $FF, $00, $00, $FF, $00
 EQUB $0C, $00, $00, $00, $FF, $00, $00, $00
 EQUB $FD, $F3, $FF, $FF, $00, $00, $FF, $00
 EQUB $DB, $00, $00, $00, $FF, $00, $00, $00
 EQUB $FF, $24, $FF, $FF, $00, $00, $FF, $00
 EQUB $7D, $00, $00, $00, $FF, $00, $00, $00
 EQUB $FF, $82, $FF, $FF, $00, $00, $FF, $00
 EQUB $B3, $00, $00, $00, $FF, $00, $00, $00
 EQUB $FF, $4C, $FF, $FF, $00, $00, $FF, $00
 EQUB $C3, $00, $00, $00, $FF, $00, $00, $00
 EQUB $FF, $3C, $FF, $FF, $00, $00, $FF, $00
 EQUB $0C, $00, $00, $00, $FF, $00, $00, $00
 EQUB $FF, $F3, $FF, $FF, $00, $00, $FF, $00
 EQUB $D8, $00, $00, $00, $FF, $00, $00, $00
 EQUB $FF, $27, $FF, $FF, $00, $00, $FF, $00
 EQUB $F3, $00, $00, $00, $FF, $00, $00, $00
 EQUB $F7, $0C, $FF, $FF, $00, $00, $FF, $00
 EQUB $B6, $00, $00, $00, $FF, $00, $00, $00
 EQUB $FF, $49, $FF, $FF, $00, $00, $FF, $00
 EQUB $DF, $00, $00, $00, $FF, $00, $00, $00
 EQUB $FF, $20, $FF, $FF, $00, $00, $FF, $00
 EQUB $B0, $00, $00, $00, $FF, $00, $00, $00
 EQUB $FF, $4F, $FF, $FF, $00, $00, $FF, $00
 EQUB $36, $00, $00, $00, $FF, $00, $00, $00
 EQUB $FF, $C9, $FF, $FF, $00, $00, $FF, $00
 EQUB $C0, $00, $00, $00, $FF, $00, $00, $00
 EQUB $DF, $3F, $FF, $FF, $00, $00, $FF, $00
 EQUB $7B, $00, $00, $00, $FF, $00, $00, $00
 EQUB $FF, $84, $FF, $FF, $00, $00, $FF, $00
 EQUB $F7, $00, $00, $00, $FF, $00, $00, $00
 EQUB $FF, $08, $FF, $FF, $00, $00, $FF, $00
 EQUB $00, $00, $00, $00, $00, $00, $00, $00
 EQUB $00, $00, $00, $00, $00, $00, $00, $00
 EQUB $00, $00, $00, $00, $00, $00, $00, $00
 EQUB $00, $00, $00, $00, $00, $00, $00, $00
 EQUB $00, $00, $00, $00, $00, $00, $00, $00
 EQUB $00, $00, $00, $00, $00, $00, $00, $00
 EQUB $00, $00, $00, $00, $00, $00, $00, $00
 EQUB $00, $00, $00, $00, $00, $00, $00, $00
 EQUB $00, $00, $00, $00, $00, $00, $00, $00
 EQUB $00, $00, $00, $00, $00, $00, $00, $00
 EQUB $00, $00, $00, $00, $00, $00, $00, $00
 EQUB $00, $00, $00, $00, $00, $00, $00, $00
 EQUB $00, $00, $00, $00, $00, $00, $00, $00
 EQUB $00, $00, $00, $00, $00, $00, $00, $00
 EQUB $00, $00, $00, $00, $00, $00, $00, $00
 EQUB $00, $00, $00, $00, $00, $00, $00, $00
 EQUB $00, $00, $00, $00, $00, $00, $00, $00
 EQUB $00, $00, $00, $00, $00, $00, $00, $00

; ******************************************************************************
;
;       Name: L9500
;       Type: Variable
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.L9500

 EQUB $09, $0B, $0C, $06, $0D, $0E, $0F, $10
 EQUB $06, $11, $12, $13, $14, $06, $15, $16
 EQUB $17, $18, $06, $19, $1A, $1B, $1C, $06
 EQUB $07, $08, $04, $05, $06, $07, $08, $0A
 EQUB $28, $2A, $2B, $26, $2C, $2D, $2E, $2F
 EQUB $26, $30, $31, $24, $32, $26, $33, $34
 EQUB $24, $35, $26, $36, $37, $38, $39, $26
 EQUB $25, $27, $24, $25, $26, $25, $27, $29
 EQUB $09, $0B, $0C, $06, $0D, $0E, $0F, $10
 EQUB $06, $11, $12, $13, $14, $15, $16, $17
 EQUB $18, $19, $1A, $1B, $08, $1C, $1D, $06
 EQUB $1E, $1F, $20, $21, $06, $22, $23, $0A
 EQUB $28, $2A, $2B, $26, $2C, $2D, $2E, $2F
 EQUB $26, $30, $31, $32, $33, $26, $34, $35
 EQUB $36, $37, $26, $38, $39, $3A, $3B, $26
 EQUB $3C, $3D, $3E, $3F, $26, $40, $27, $29
 EQUB $09, $0B, $0C, $06, $0D, $0E, $0F, $10
 EQUB $06, $11, $12, $13, $14, $06, $15, $16
 EQUB $17, $18, $19, $1A, $1B, $1C, $1D, $06
 EQUB $1E, $1F, $20, $21, $06, $22, $23, $0A
 EQUB $28, $2A, $2B, $26, $2C, $2D, $2E, $2F
 EQUB $26, $30, $31, $32, $33, $26, $34, $35
 EQUB $24, $36, $26, $37, $38, $39, $3A, $26
 EQUB $3B, $3C, $3D, $3E, $26, $3F, $27, $29
 EQUB $09, $0B, $0C, $0D, $0E, $0F, $10, $11
 EQUB $06, $12, $08, $13, $14, $06

; ******************************************************************************
;
;       Name: L95CE
;       Type: Variable
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.L95CE

 EQUB $15, $16, $17, $18, $0D, $19, $1A, $1B
 EQUB $1C, $06, $1D, $1E, $1F, $20, $06, $15
 EQUB $16, $0A, $28, $2A, $2B, $26, $2C, $2D
 EQUB $2E, $2F, $26, $30, $27, $24, $31, $26
 EQUB $32, $33, $34, $35, $26, $2C, $36, $37
 EQUB $38, $26, $39, $3A, $3B, $3C, $26, $32
 EQUB $33, $29, $0A, $05, $08, $0C, $0D, $0E
 EQUB $0F, $10, $11, $12, $13, $14, $15, $16
 EQUB $08, $17, $18, $19, $1A, $1B, $1C, $1D
 EQUB $1E, $1F, $20, $21, $22, $23, $24, $08
 EQUB $09, $0B, $29, $25, $26, $26, $2B, $2C
 EQUB $2D, $2E, $2F, $30, $26, $31, $32, $33
 EQUB $26, $34, $2F, $35, $36, $2F, $37, $38
 EQUB $2E, $39, $3A, $2F, $3B, $36, $26, $26
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

 EQUB $2A, $45, $46, $47, $48, $47, $49, $4A
 EQUB $4B, $4C, $4D, $4E, $4F, $4D, $4C, $4D
 EQUB $4E, $4F, $4D, $4C, $4D, $50, $4F, $4D
 EQUB $4C, $51, $52, $46, $47, $48, $47, $49
 EQUB $53, $54, $55, $55, $55, $55, $56, $57
 EQUB $58, $59, $00, $5A, $5B, $5C, $5D, $5E
 EQUB $5F, $60, $61, $62, $63, $64, $65, $00
 EQUB $66, $67, $68, $69, $6A, $6B, $85, $85
 EQUB $6E, $54, $55, $55, $55, $55, $6F, $70
 EQUB $00, $71, $72, $73, $74, $75, $76, $77
 EQUB $78, $79, $7A, $7B, $7C, $7D, $7E, $7F
 EQUB $80, $00, $81, $82, $83, $84, $85, $85
 EQUB $6E, $54, $55, $55, $55, $55, $86, $70
 EQUB $87, $88, $89, $8A, $8B, $8C, $8D, $8C
 EQUB $8E, $8F, $8C, $90, $8C, $91, $92, $93
 EQUB $94, $95, $96, $97, $55, $55, $55, $55
 EQUB $98, $54, $55, $55, $55, $55, $99, $9A
 EQUB $9B, $9C, $9D, $9E, $9F, $A0, $A1, $A2
 EQUB $A2, $A3, $A2, $A4, $A0, $A5, $A6, $A7
 EQUB $A8, $A9, $AA, $AB, $55, $55, $55, $55
 EQUB $98, $54, $55, $55, $55, $55, $AC, $AD
 EQUB $58, $AE, $AF, $B0, $B1, $B2, $B3, $B4
 EQUB $B5, $B6, $B7, $B8, $B9, $BA, $BB, $BC
 EQUB $BD, $67, $BE, $BF, $55, $55, $55, $55
 EQUB $98, $54, $55, $55, $55, $55, $C0, $C1
 EQUB $00, $00, $00, $00, $00, $C2, $C3, $C4
 EQUB $C5, $C6, $C7, $C8, $C9, $00, $00, $00
 EQUB $00, $00, $CA, $97, $55, $55, $55, $55
 EQUB $98, $00, $00, $00, $00, $00, $00, $00
 EQUB $00, $00, $00, $00, $00, $00, $00, $00
 EQUB $00, $00, $00, $00, $00, $00, $00, $00
 EQUB $00, $00, $00, $00, $00, $00, $00, $00
 EQUB $00, $00, $00, $00, $00, $00, $00, $00
 EQUB $00, $00, $00, $00, $00, $00, $00, $00
 EQUB $00, $00, $00, $00, $00, $00, $00, $00
 EQUB $00, $00, $00, $00, $00, $00, $00, $00
 EQUB $00

; ******************************************************************************
;
;       Name: dialImage
;       Type: Variable
;   Category: Drawing images
;    Summary: Packed image data for the dashboard and dials
;
; ******************************************************************************

.dialImage

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
;    Summary: Image data for the missiles shown on the Equip Ship screen
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

 LDY #7*32

.loop_CA732

 SETUP_PPU_FOR_ICON_BAR ; If the PPU has started drawing the icon bar, configure
                        ; the PPU to use nametable 0 and pattern table 0

 LDA L963F,Y

 STA nameBuffer0+22*32,Y
 STA nameBuffer1+22*32,Y

 DEY

 BNE loop_CA732

 LDA nameBuffer0+23*32
 STA nameBuffer0+22*32

 LDA nameBuffer0+24*32
 STA nameBuffer0+23*32

 LDA nameBuffer0+25*32
 STA nameBuffer0+24*32

 LDA nameBuffer0+26*32
 STA nameBuffer0+25*32

 LDA nameBuffer0+28*32
 STA nameBuffer0+27*32

 LDA nameBuffer0+29*32
 STA nameBuffer0+28*32

 LDA #0
 STA nameBuffer0+29*32

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

 LDY #3*32

 LDA #0

.loop_CA786

 STA nameBuffer0+29*32-1,Y

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
;       Name: SetupView
;       Type: Subroutine
;   Category: Utility routines
;    Summary: ???
;
; ******************************************************************************

.SetupView

 JSR WSCAN
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

 JSR SendDialImageToPPU ; Unpack the image for the dashboard and dials and send
                        ; it to the PPU

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

 JSR SendPattern0ToPPU

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

 JSR SendMissilesToPPU

.CA8A2

 JSR subm_AC86

 LDA #HI(PPU_PATT_1+16*0)   ; Set PPU_ADDR to the address of pattern #0 in
 STA PPU_ADDR               ; pattern table 1
 LDA #LO(PPU_PATT_1+16*0)
 STA PPU_ADDR

 LDY #0

 LDX #$50

.loop_CA8B3

 LDA LAA6C,Y
 STA PPU_DATA
 INY
 DEX
 BNE loop_CA8B3

 LDA #HI(PPU_PATT_1+16*255) ; Set PPU_ADDR to the address of pattern #255 in
 STA PPU_ADDR               ; pattern table 1
 LDA #LO(PPU_PATT_1+16*255)
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
 STX hiddenBitPlane
 STX nmiBitplane
 JSR SetDrawingBitplane
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
 JMP subm_B673_b3

; ******************************************************************************
;
;       Name: SendPattern0ToPPU
;       Type: Subroutine
;   Category: Drawing the screen
;    Summary: Send a pattern to bitplane 0 in the PPU and zeroes to bitplane 1
;
; ******************************************************************************

.SendPattern0ToPPU

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
;       Name: SendDialImageToPPU
;       Type: Subroutine
;   Category: Drawing the screen
;    Summary: Unpack the image for the dashboard and dials and send it to the
;             PPU
;
; ******************************************************************************

.SendDialImageToPPU

 LDA #HI(16*69)         ; Set PPU_ADDR to the address of pattern #69 in pattern
 STA PPU_ADDR           ; table 0
 LDA #LO(16*69)
 STA PPU_ADDR

 LDA #HI(dialImage)     ; Set V(1 0) = dialImage
 STA V+1                ;
 LDA #LO(dialImage)     ; So we can unpack the image data for the dashboard and
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

 STX drawingBitplane
 STX nmiBitplane
 STX hiddenBitPlane

 LDA #0
 STA nameTileNumber

 LDA QQ11
 CMP #$DF
 BNE CA986

 LDA #4
 BNE CA988

.CA986

 LDA #$25

.CA988

 STA pattTileNumber
 LDA tileNumber
 STA nextTileNumber,X

 LDA #%11000100
 JSR subm_D977

 JSR CA99B
 LDA tileNumber
 STA pattTileNumber2,X
 RTS

.CA99B

 TXA
 PHA
 LDA #$3F
 STA cycleCount+1
 LDA #$FF
 STA cycleCount
 JSR SendBuffersToPPU
 PLA
 PHA
 TAX
 LDA bitplaneFlags,X
 AND #%00100000
 BNE CA9CC

 LDA #$10
 STA cycleCount+1
 LDA #0
 STA cycleCount

 JSR SendBuffersToPPU
 PLA
 TAX
 LDA bitplaneFlags,X
 AND #%00100000
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
 JSR ScreenUpdateIsDone
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
 STA nameTileNumber
 LDA #37
 STA pattTileNumber
 LDA tileNumber
 STA nextTileNumber
 STA nextTileNumber+1

 LDA #%01010100
 LDX #0
 PLA
 JSR subm_D977

 INC drawingBitplane

 JSR subm_D977

 JSR ScreenUpdateIsDone
 LDA #80
 STA lastTileNumber
 STA lastTileNumber+1
 LDA QQ11
 STA QQ11a
 LDA tileNumber
 STA pattTileNumber2
 STA pattTileNumber2+1
 LDA #0
 LDX #0
 STX hiddenBitPlane
 STX nmiBitplane
 JSR SetDrawingBitplane
 LDA QQ11
 AND #$40
 BNE CAA3B
 JSR WSCAN
 LDA #$80
 STA showUserInterface

.CAA3B

 LDA L0473
 BPL CAA43
 JMP subm_B673_b3

.CAA43

 LDA QQ11
 AND #$0F
 TAX
 LDA LAA5C,X
 CMP L03F2
 STA L03F2
 JSR subm_B57F
 DEC updatePaletteInNMI
 JSR WSCAN
 INC updatePaletteInNMI
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
;   Category: Start and end
;    Summary: ???
;
; ******************************************************************************

.DrawTitleScreen

 JSR subm_D933

 LDA #HI(20*32)         ; Set iconBarOffset(1 0) = 20*32
 STA iconBarOffset+1
 LDA #LO(20*32)
 STA iconBarOffset

 LDA #$3F               ; Set PPU_ADDR = $3F00
 STA PPU_ADDR
 LDA #$00
 STA PPU_ADDR

 LDA #$0F

 LDX #$1F

.loop_CAAD5

 STA PPU_DATA
 DEX
 BPL loop_CAAD5

 LDA #$20               ; Set PPU_ADDR = $2000
 STA PPU_ADDR
 LDA #$00
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
 LDA #$00
 STA PPU_ADDR
 LDA #$00
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
 LDA #$00
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
 JSR SendDialImageToPPU

IF _NTSC

 LDA #$9D

ELIF _PAL

 LDA #$A3

ENDIF

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
 STA nmiBitplane
 STA drawingBitplane
 STA hiddenBitPlane
 LDA #$10
 STA ppuPatternTableHi
 LDA #0
 STA nmiBitplane8

 LDA #$20
 STA ppuNametableAddr+1
 LDA #0
 STA ppuNametableAddr

 LDA #%00101000         ; Set bits 3 and 5 of both bitplane flags
 STA bitplaneFlags
 STA bitplaneFlags+1

 LDA #4
 STA pattTileNumber2
 STA pattTileNumber2+1
 STA nameTileNumber2
 STA nameTileNumber2+1
 STA pattTileNumber1
 STA pattTileNumber1+1
 STA nameTileNumber1
 STA nameTileNumber1+1

 LDA #$0F               ; Set hiddenColour to $0F, which is black, so this hides
 STA hiddenColour       ; any pixels that use the hidden colour in palette 0

 STA visibleColour
 STA paletteColour2
 STA paletteColour3
 LDA #0
 STA updatePaletteInNMI
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
 LDA iconBarType
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

 LDA #HI(20*32)         ; Set iconBarOffset(1 0) = 20*32
 STA iconBarOffset+1
 LDA #LO(20*32)
 STA iconBarOffset

 LDA QQ11               ; If bit 7 of the view number is clear, jump to CAC1C to
 BPL CAC1C              ; keep this value of iconBarOffset

 LDA #HI(27*32)         ; Set iconBarOffset(1 0) = 27*32
 STA iconBarOffset+1
 LDA #LO(27*32)         ; So the icon bar is on row 20 if bit 7 of the view
 STA iconBarOffset      ; number is clear (so there is a dashboard), and it's on
                        ; row 27 is bit 7 is set (so there is no dashboard)

.CAC1C

 RTS                    ; Return from the subroutine

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
 STY iconBarType
 JSR subm_ACEB

 LDA #HI(20*32)         ; Set iconBarOffset(1 0) = 20*32
 STA iconBarOffset+1
 LDA #LO(20*32)
 STA iconBarOffset

 LDA QQ11               ; If bit 7 of the view number is clear, jump to CAC3E to
 BPL CAC3E              ; keep this value of iconBarOffset

 LDA #HI(27*32)         ; Set iconBarOffset(1 0) = 27*32
 STA iconBarOffset+1    ;
 LDA #LO(27*32)         ; So the icon bar is on row 20 if bit 7 of the view
 STA iconBarOffset      ; number is clear (so there is a dashboard), and it's on
                        ; row 27 is bit 7 is set (so there is no dashboard)

.CAC3E

 LDA iconBarType        ; Set iconBarImageHi to the high byte of the correct
 ASL A                  ; icon bar image block for the current icon bar type,
 ASL A                  ; which we can calculate like this:
 ADC #HI(iconBarImage0) ;
 STA iconBarImageHi     ;   HI(iconBarImage0) + 4 * iconBarType
                        ;
                        ; as each icon bar image block contains $0400 bytes,
                        ; and iconBarType is the icon bar type, 0 to 4

 LDX #0                 ; Set barPatternCounter = 0 so the NMI handler sends the
 STX barPatternCounter  ; icon bar's nametable and pattern data to the PPU

.loop_CAC4B

 SETUP_PPU_FOR_ICON_BAR ; If the PPU has started drawing the icon bar, configure
                        ; the PPU to use nametable 0 and pattern table 0

 LDA barPatternCounter  ; Loop back to keep the PPU configured in this way until
 BPL loop_CAC4B         ; barPatternCounter is set to 128
                        ;
                        ; This happens when the NMI handler has finished sending
                        ; all the icon bar's nametable and pattern data to
                        ; the PPU, so this loop keeps the PPU configured to use
                        ; nametable 0 and pattern table 0 until the icon bar
                        ; nametable and pattern data have all been sent

; ******************************************************************************
;
;       Name: subm_AC5C
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.subm_AC5C

 LDA iconBarType
 JSR subm_AE18

 LDA QQ11               ; If bit 6 of the view number is set, then there is no
 AND #%01000000         ; icon bar, so jump to CAC85 to return from the
 BNE CAC85              ; subroutine ???

 JSR subm_ABE7

 LDA #%10000000         ; Set bit 7 of skipBarPatternsPPU, so the NMI handler
 STA skipBarPatternsPPU ; only sends the nametable entries and not the tile
                        ; patterns

 ASL A                  ; Set barPatternCounter = 0, so the NMI handler sends
 STA barPatternCounter  ; icon bar data to the PPU

.loop_CAC72

 SETUP_PPU_FOR_ICON_BAR ; If the PPU has started drawing the icon bar, configure
                        ; the PPU to use nametable 0 and pattern table 0

 LDA barPatternCounter  ; Loop back to keep the PPU configured in this way until
 BPL loop_CAC72         ; barPatternCounter is set to 128
                        ;
                        ; This happens when the NMI handler has finished sending
                        ; all the icon bar's nametable entries to the PPU, so
                        ; this loop keeps the PPU configured to use nametable 0
                        ; and pattern table 0 until the icon bar nametable
                        ; entries have been sent

 ASL skipBarPatternsPPU ; Set skipBarPatternsPPU = 0, so the NMI handler goes
                        ; back to sending both nametable entries and tile
                        ; patterns for the icon bar (when barPatternCounter is
                        ; non-zero)

.CAC85

 RTS                    ; Return from the subroutine

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

IF _NTSC

 LDX #$9D

ELIF _PAL

 LDX #$A3

ENDIF

 LDA QQ11
 BPL CACCC
 CMP #$C4
 BNE CACA8
 LDX #$F0
 BNE CACCC

.CACA8

 LDY #$19

IF _NTSC

 LDX #$D5

ELIF _PAL

 LDX #$DB

ENDIF

 CMP #$B9
 BNE CACB7

IF _NTSC

 LDX #$96

ELIF _PAL

 LDX #$9C

ENDIF

 LDA #$F8
 STA xSprite0

.CACB7

 LDA QQ11
 AND #$0F
 CMP #$0F
 BNE CACC1

IF _NTSC

 LDX #$A6

ELIF _PAL

 LDX #$AC

ENDIF

.CACC1

 CMP #$0D
 BNE CACCC

IF _NTSC

 LDX #$AD

ELIF _PAL

 LDX #$B3

ENDIF

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

 LDA iconBarType        ; Set iconBarImageHi to the high byte of the correct
 ASL A                  ; icon bar image block for the current icon bar type,
 ASL A                  ; which we can calculate like this:
 ADC #HI(iconBarImage0) ;
 STA iconBarImageHi     ;   HI(iconBarImage0) + 4 * iconBarType
                        ;
                        ; as each icon bar image block contains $0400 bytes,
                        ; and iconBarType is the icon bar type, 0 to 4

 LDA QQ11
 AND #$40
 BNE CACEA

 LDX #0                 ; Set barPatternCounter = 0 so the NMI handler sends the
 STX barPatternCounter  ; icon bar's nametable and pattern data to the PPU

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

 LDA iconBarType
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

 LDA #HI(nameBuffer0+20*32) ; Set SC(1 0) to the address of the first tile on
 STA SC+1                   ; tile row 20 in nametable buffer 0
 LDA #LO(nameBuffer0+20*32)
 STA SC

 LDA #HI(nameBuffer1+20*32) ; Set SC2(1 0) to the address of the first tile on
 STA SC2+1                  ; tile row 20 in nametable buffer 1
 LDA #LO(nameBuffer1+20*32)
 STA SC2

 JMP CAD77

.CAD5A

 LDA #HI(nameBuffer0+27*32) ; Set SC(1 0) to the address of the first tile on
 STA SC+1                   ; tile row 27 in nametable buffer 0
 LDA #LO(nameBuffer0+27*32)
 STA SC

 LDA #HI(nameBuffer1+27*32) ; Set SC2(1 0) to the address of the first tile on
 STA SC2+1                  ; tile row 27 in nametable buffer 1
 LDA #LO(nameBuffer1+27*32)
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

 LDA #HI(nameBuffer0+27*32) ; Set SC(1 0) to the address of the first tile on
 STA SC+1                   ; tile row 27 in nametable buffer 0
 LDA #LO(nameBuffer0+27*32)
 STA SC

 LDA #HI(nameBuffer1+27*32) ; Set SC2(1 0) to the address of the first tile on
 STA SC2+1                  ; tile row 27 in nametable buffer 1
 LDA #LO(nameBuffer1+27*32)
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
 STA iconBarType

 SETUP_PPU_FOR_ICON_BAR ; If the PPU has started drawing the icon bar, configure
                        ; the PPU to use nametable 0 and pattern table 0

 JSR subm_AD2A
 LDA iconBarType
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

 LDA iconBarType
 ASL A
 ASL A
 ASL A
 ASL A

IF _NTSC

 ADC #$27

ELIF _PAL

 ADC #$46

ENDIF

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

 LDA #HI(lineImage)     ; Set V(1 0) = lineImage
 STA V+1
 LDA #LO(lineImage)
 STA V

 LDA #HI(pattBuffer0+8*37)  ; Set SC(1 0) to the address of pattern #37 in
 STA SC+1                   ; pattern buffer 0
 LDA #LO(pattBuffer0+8*37)
 STA SC

 LDA #HI(pattBuffer1+8*37)  ; Set SC2(1 0) to the address of pattern #37 in
 STA SC2+1                  ; pattern buffer 1
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
 JSR subm_B2FB_b3
 LDA #$45
 STA K+2
 LDA #8
 STA K+3
 LDX #0
 LDY #0
 JSR subm_A0F8_b6
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
;   Category: Utility routines
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
 LDA hiddenBitPlane
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

 LDA #$0F               ; Set hiddenColour to $0F, which is black, so this hides
 STA hiddenColour       ; any pixels that use the hidden colour in palette 0

 LDA QQ11a
 BPL CB627
 CMP #$C4
 BEQ CB627
 CMP #$98
 BEQ CB62D
 LDA XX3+21
 STA visibleColour
 LDA XX3+22
 STA paletteColour2
 LDA XX3+23
 STA paletteColour3
 RTS

.CB627

 LDA XX3+3
 STA visibleColour
 RTS

.CB62D

 LDA XX3+1
 STA visibleColour
 LDA XX3+2
 STA paletteColour2
 LDA XX3+3
 STA paletteColour3
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
 JSR ScreenUpdateIsDone
 JSR WSCAN
 JSR subm_B57F
 DEC updatePaletteInNMI
 JSR subm_B5F9
 JSR WSCAN-3
 JSR subm_B5F9
 JSR WSCAN-3
 JSR subm_B5F9
 JSR WSCAN-3
 JSR subm_B5F9
 JSR WSCAN-3
 INC updatePaletteInNMI

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

 JSR WSCAN
 JSR subm_B57F
 JSR subm_B5F6
 JSR subm_B5F9
 DEC updatePaletteInNMI
 JSR WSCAN-3
 JSR subm_B57F
 JSR subm_B5F6
 JSR WSCAN-3
 JSR subm_B57F
 JSR subm_B5F9
 JSR WSCAN-3
 JSR subm_B57F
 JSR CB607
 JSR WSCAN
 INC updatePaletteInNMI
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

 LDX chosenLanguage
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

 LDA #HI(attrBuffer0)   ; Set SC(1 0) to the address of attribute buffer 0
 STA SC+1
 LDA #LO(attrBuffer0)
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

IF _NTSC

 LDA #$53
 STA ySprite5
 STA ySprite6
 LDA #$4B
 STA ySprite7
 LDA #$5B
 STA ySprite8

ELIF _PAL

 LDA #$59
 STA ySprite5
 STA ySprite6
 LDA #$51
 STA ySprite7
 LDA #$61
 STA ySprite8

ENDIF

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

IF _NTSC

 LDA #$4B
 STA ySprite5
 STA ySprite6
 LDA #$5B
 STA ySprite7
 STA ySprite8

ELIF _PAL

 LDA #$51
 STA ySprite5
 STA ySprite6
 LDA #$61
 STA ySprite7
 STA ySprite8

ENDIF

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

IF _NTSC

 LDA #$53
 STA ySprite5
 STA ySprite6
 LDA #$47
 STA ySprite7
 LDA #$5F
 STA ySprite8

ELIF _PAL

 LDA #$59
 STA ySprite5
 STA ySprite6
 LDA #$4D
 STA ySprite7
 LDA #$65
 STA ySprite8

ENDIF

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

IF _NTSC

 LDA #$4B
 STA ySprite5
 STA ySprite6
 LDA #$5B
 STA ySprite7
 STA ySprite8

ELIF _PAL

 LDA #$51
 STA ySprite5
 STA ySprite6
 LDA #$61
 STA ySprite7
 STA ySprite8

ENDIF

 RTS

; ******************************************************************************
;
;       Name: Vectors
;       Type: Variable
;   Category: Utility routines
;    Summary: Vectors and padding at the end of the ROM bank
;
; ******************************************************************************

 FOR I%, P%, $BFF9

  EQUB $FF              ; Pad out the rest of the ROM bank with $FF

 NEXT

IF _NTSC

 EQUW Interrupts+$4000  ; Vector to the NMI handler in case this bank is loaded
                        ; into $C000 during start-up (the handler contains an
                        ; RTI so the interrupt is processed but has no effect)

 EQUW ResetMMC1+$4000   ; Vector to the RESET handler in case this bank is
                        ; loaded into $C000 during start-up (the handler resets
                        ; the MMC1 mapper to map bank 7 into $C000 instead)

 EQUW Interrupts+$4000  ; Vector to the IRQ/BRK handler in case this bank is
                        ; loaded into $C000 during start-up (the handler
                        ; contains an RTI so the interrupt is processed but has
                        ; no effect)

ELIF _PAL

 EQUW NMI               ; Vector to the NMI handler

 EQUW ResetMMC1+$4000   ; Vector to the RESET handler in case this bank is
                        ; loaded into $C000 during start-up (the handler resets
                        ; the MMC1 mapper to map bank 7 into $C000 instead)

 EQUW IRQ               ; Vector to the IRQ/BRK handler

ENDIF

; ******************************************************************************
;
; Save bank3.bin
;
; ******************************************************************************

 PRINT "S.bank3.bin ", ~CODE%, " ", ~P%, " ", ~LOAD%, " ", ~LOAD%
 SAVE "3-assembled-output/bank3.bin", CODE%, P%, LOAD%
