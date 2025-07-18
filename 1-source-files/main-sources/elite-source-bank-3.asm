; ******************************************************************************
;
; NES ELITE GAME SOURCE (BANK 3)
;
; NES Elite was written by Ian Bell and David Braben and is copyright D. Braben
; and I. Bell 1991/1992
;
; The code in this file has been reconstructed from a disassembly of the version
; released on Ian Bell's personal website at http://www.elitehomepage.org/
;
; The commentary is copyright Mark Moxon, and any misunderstandings or mistakes
; in the documentation are entirely my fault
;
; The terminology and notations used in this commentary are explained at
; https://elite.bbcelite.com/terminology
;
; The deep dive articles referred to in this commentary can be found at
; https://elite.bbcelite.com/deep_dives
;
; ------------------------------------------------------------------------------
;
; This source file contains the game code for ROM bank 3 of NES Elite.
;
; ------------------------------------------------------------------------------
;
; This source file produces the following binary file:
;
;   * bank3.bin
;
; ******************************************************************************

; ******************************************************************************
;
; ELITE BANK 3
;
; Produces the binary file bank1.bin.
;
; ******************************************************************************

 ORG CODE%              ; Set the assembly address to CODE%

; ******************************************************************************
;
;       Name: ResetMMC1_b3
;       Type: Subroutine
;   Category: Start and end
;    Summary: The MMC1 mapper reset routine at the start of the ROM bank
;  Deep dive: Splitting NES Elite across multiple ROM banks
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
;   * We put the same reset routine (this routine, ResetMMC1) at the start of
;     every ROM bank, so the same routine gets run, whichever ROM bank is mapped
;     to $C000.
;
; This ResetMMC1 routine is therefore called when the NES starts up, whatever
; the bank configuration ends up being. It then switches ROM bank 7 to $C000 and
; jumps into bank 7 at the game's entry point BEGIN, which starts the game.
;
; ******************************************************************************

.ResetMMC1_b3

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
                        ;     below, i.e. the high byte of BEGIN, which is $C0
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

 JMP BEGIN              ; Jump to BEGIN in bank 7 to start the game

; ******************************************************************************
;
;       Name: Interrupts_b3
;       Type: Subroutine
;   Category: Start and end
;    Summary: The IRQ and NMI handler while the MMC1 mapper reset routine is
;             still running
;
; ******************************************************************************

.Interrupts_b3

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
;       Name: versionNumber_b3
;       Type: Variable
;   Category: Text
;    Summary: The game's version number in bank 3
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
;   Category: Text
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
;   Category: Icon bar
;    Summary: Image data for icon bar 0 (Docked)
;
; ------------------------------------------------------------------------------
;
; You can view the tiles that make up the Docked icon bar here:
;
; https://elite.bbcelite.com/images/source/nes/iconBarImage0_ppu.png
;
; and you can see what the Docked icon bar looks like on-screen here:
;
; https://elite.bbcelite.com/images/nes/general/data_on_lave.png
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
;   Category: Icon bar
;    Summary: Image data for icon bar 1 (Flight)
;
; ------------------------------------------------------------------------------
;
; You can view the tiles that make up the Flight icon bar here:
;
; https://elite.bbcelite.com/images/source/nes/iconBarImage0_ppu.png
;
; and you can see what the Flight icon bar looks like on-screen here:
;
; https://elite.bbcelite.com/images/nes/general/station.png
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
;   Category: Icon bar
;    Summary: Image data for icon bar 2 (Charts)
;
; ------------------------------------------------------------------------------
;
; You can view the tiles that make up the Charts icon bar here:
;
; https://elite.bbcelite.com/images/source/nes/iconBarImage2_ppu.png
;
; and you can see what the Charts icon bar looks like on-screen here:
;
; https://elite.bbcelite.com/images/nes/general/short_range_chart.png
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
;   Category: Icon bar
;    Summary: Image data for icon bar 3 (Pause)
;
; ------------------------------------------------------------------------------
;
; You can view the tiles that make up the Pause icon bar here:
;
; https://elite.bbcelite.com/images/source/nes/iconBarImage3_ppu.png
;
; and you can see what the Pause icon bar looks like on-screen here:
;
; https://elite.bbcelite.com/images/nes/general/pause_icon_bar.png
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
;   Category: Icon bar
;    Summary: Image data for icon bar 4 (Title screen copyright message)
;
; ------------------------------------------------------------------------------
;
; You can view the tiles that make up the copyright message here:
;
; https://elite.bbcelite.com/images/source/nes/iconBarImage4_ppu.png
;
; and you can see what the copyright message looks like on-screen here:
;
; https://elite.bbcelite.com/images/nes/general/title.png
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
;       Name: barNames0
;       Type: Variable
;   Category: Icon bar
;    Summary: Nametable entries for icon bar 0 (Docked)
;
; ******************************************************************************

.barNames0

 EQUB $09, $0B, $0C, $06, $0D, $0E, $0F, $10
 EQUB $06, $11, $12, $13, $14, $06, $15, $16
 EQUB $17, $18, $06, $19, $1A, $1B, $1C, $06
 EQUB $07, $08, $04, $05, $06, $07, $08, $0A
 EQUB $28, $2A, $2B, $26, $2C, $2D, $2E, $2F
 EQUB $26, $30, $31, $24, $32, $26, $33, $34
 EQUB $24, $35, $26, $36, $37, $38, $39, $26
 EQUB $25, $27, $24, $25, $26, $25, $27, $29

; ******************************************************************************
;
;       Name: barNames1
;       Type: Variable
;   Category: Icon bar
;    Summary: Nametable entries for icon bar 1 (Flight)
;
; ******************************************************************************

.barNames1

 EQUB $09, $0B, $0C, $06, $0D, $0E, $0F, $10
 EQUB $06, $11, $12, $13, $14, $15, $16, $17
 EQUB $18, $19, $1A, $1B, $08, $1C, $1D, $06
 EQUB $1E, $1F, $20, $21, $06, $22, $23, $0A
 EQUB $28, $2A, $2B, $26, $2C, $2D, $2E, $2F
 EQUB $26, $30, $31, $32, $33, $26, $34, $35
 EQUB $36, $37, $26, $38, $39, $3A, $3B, $26
 EQUB $3C, $3D, $3E, $3F, $26, $40, $27, $29

; ******************************************************************************
;
;       Name: barNames2
;       Type: Variable
;   Category: Icon bar
;    Summary: Nametable entries for icon bar 2 (Charts)
;
; ******************************************************************************

.barNames2

 EQUB $09, $0B, $0C, $06, $0D, $0E, $0F, $10
 EQUB $06, $11, $12, $13, $14, $06, $15, $16
 EQUB $17, $18, $19, $1A, $1B, $1C, $1D, $06
 EQUB $1E, $1F, $20, $21, $06, $22, $23, $0A
 EQUB $28, $2A, $2B, $26, $2C, $2D, $2E, $2F
 EQUB $26, $30, $31, $32, $33, $26, $34, $35
 EQUB $24, $36, $26, $37, $38, $39, $3A, $26
 EQUB $3B, $3C, $3D, $3E, $26, $3F, $27, $29

; ******************************************************************************
;
;       Name: barNames3
;       Type: Variable
;   Category: Icon bar
;    Summary: Nametable entries for icon bar 3 (Pause)
;
; ******************************************************************************

.barNames3

 EQUB $09, $0B, $0C, $0D, $0E, $0F, $10, $11
 EQUB $06, $12, $08, $13, $14, $06, $15, $16
 EQUB $17, $18, $0D, $19, $1A, $1B, $1C, $06
 EQUB $1D, $1E, $1F, $20, $06, $15, $16, $0A
 EQUB $28, $2A, $2B, $26, $2C, $2D, $2E, $2F
 EQUB $26, $30, $27, $24, $31, $26, $32, $33
 EQUB $34, $35, $26, $2C, $36, $37, $38, $26
 EQUB $39, $3A, $3B, $3C, $26, $32, $33, $29

; ******************************************************************************
;
;       Name: barNames4
;       Type: Variable
;   Category: Icon bar
;    Summary: Nametable entries for icon bar 4 (Title screen copyright message)
;
; ******************************************************************************

.barNames4

 EQUB $0A, $05, $08, $0C, $0D, $0E, $0F, $10
 EQUB $11, $12, $13, $14, $15, $16, $08, $17
 EQUB $18, $19, $1A, $1B, $1C, $1D, $1E, $1F
 EQUB $20, $21, $22, $23, $24, $08, $09, $0B
 EQUB $29, $25, $26, $26, $2B, $2C, $2D, $2E
 EQUB $2F, $30, $26, $31, $32, $33, $26, $34
 EQUB $2F, $35, $36, $2F, $37, $38, $2E, $39
 EQUB $3A, $2F, $3B, $36, $26, $26, $28, $2A

; ******************************************************************************
;
;       Name: dashNames
;       Type: Variable
;   Category: Dashboard
;    Summary: Nametable entries for the dashboard
;
; ******************************************************************************

.dashNames

 EQUB $45, $46, $47, $48, $47, $49, $4A, $4B
 EQUB $4C, $4D, $4E, $4F, $4D, $4C, $4D, $4E
 EQUB $4F, $4D, $4C, $4D, $50, $4F, $4D, $4C
 EQUB $51, $52, $46, $47, $48, $47, $49, $53
 EQUB $54, $55, $55, $55, $55, $56, $57, $58
 EQUB $59, $00, $5A, $5B, $5C, $5D, $5E, $5F
 EQUB $60, $61, $62, $63, $64, $65, $00, $66
 EQUB $67, $68, $69, $6A, $6B, $85, $85, $6E
 EQUB $54, $55, $55, $55, $55, $6F, $70, $00
 EQUB $71, $72, $73, $74, $75, $76, $77, $78
 EQUB $79, $7A, $7B, $7C, $7D, $7E, $7F, $80
 EQUB $00, $81, $82, $83, $84, $85, $85, $6E
 EQUB $54, $55, $55, $55, $55, $86, $70, $87
 EQUB $88, $89, $8A, $8B, $8C, $8D, $8C, $8E
 EQUB $8F, $8C, $90, $8C, $91, $92, $93, $94
 EQUB $95, $96, $97, $55, $55, $55, $55, $98
 EQUB $54, $55, $55, $55, $55, $99, $9A, $9B
 EQUB $9C, $9D, $9E, $9F, $A0, $A1, $A2, $A2
 EQUB $A3, $A2, $A4, $A0, $A5, $A6, $A7, $A8
 EQUB $A9, $AA, $AB, $55, $55, $55, $55, $98
 EQUB $54, $55, $55, $55, $55, $AC, $AD, $58
 EQUB $AE, $AF, $B0, $B1, $B2, $B3, $B4, $B5
 EQUB $B6, $B7, $B8, $B9, $BA, $BB, $BC, $BD
 EQUB $67, $BE, $BF, $55, $55, $55, $55, $98
 EQUB $54, $55, $55, $55, $55, $C0, $C1, $00
 EQUB $00, $00, $00, $00, $C2, $C3, $C4, $C5
 EQUB $C6, $C7, $C8, $C9, $00, $00, $00, $00
 EQUB $00, $CA, $97, $55, $55, $55, $55, $98
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
;       Name: dashImage
;       Type: Variable
;   Category: Dashboard
;    Summary: Packed image data for the dashboard
;  Deep dive: Image and data compression
;             Views and view types in NES Elite
;
; ------------------------------------------------------------------------------
;
; You can view the tiles that make up the dashboard image here:
;
; https://elite.bbcelite.com/images/source/nes/dashImage_ppu.png
;
; and you can see what the dashboard looks like on-screen here:
;
; https://elite.bbcelite.com/images/nes/general/dashboard.png
;
; ******************************************************************************

.dashImage

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
;   Category: Equipment
;    Summary: Packed image data for the Cobra Mk III shown on the Equip Ship
;             screen
;  Deep dive: Image and data compression
;
; ------------------------------------------------------------------------------
;
; You can view the tiles that make up the Cobra Mk III image here:
;
; https://elite.bbcelite.com/images/source/nes/cobraImage_ppu.png
;
; and you can see what the Cobra Mk III looks like on-screen here:
;
; https://elite.bbcelite.com/images/nes/general/equipment.png
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
;       Name: inventoryIcon
;       Type: Variable
;   Category: Equipment
;    Summary: Image data for the inventory icon shown on the icon bar in the
;             Market Price screen
;
; ------------------------------------------------------------------------------
;
; You can view the tiles that make up the inventory icon here:
;
; https://elite.bbcelite.com/images/source/nes/inventoryIcon_ppu.png
;
; ******************************************************************************

.inventoryIcon

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
;       Name: smallLogoImage
;       Type: Variable
;   Category: Save and load
;    Summary: Packed image data for the small Elite logo shown on the Save and
;             Load screen
;  Deep dive: Image and data compression
;
; ------------------------------------------------------------------------------
;
; You can view the tiles that make up the small logo image here:
;
; https://elite.bbcelite.com/images/source/nes/smallLogoImage_ppu.png
;
; and you can see what the small logo looks like on-screen here:
;
; https://elite.bbcelite.com/images/nes/general/save_and_load.png
;
; ******************************************************************************

.smallLogoImage

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
;       Name: logoBallImage
;       Type: Variable
;   Category: Start and end
;    Summary: Packed image data for the ball at the bottom of the big Elite logo
;             shown on the Start screen
;  Deep dive: Image and data compression
;
; ------------------------------------------------------------------------------
;
; You can view the tiles that make up the big logo ball image here:
;
; https://elite.bbcelite.com/images/source/nes/logoBallImage_ppu.png
;
; and you can see what the full big logo looks like on-screen here (the ball is
; at the bottom of the logo):
;
; https://elite.bbcelite.com/images/nes/general/start.png
;
; ******************************************************************************

.logoBallImage

 EQUB $35, $51, $38, $3F, $11, $0B, $03, $21
 EQUB $0C, $02, $21, $0E, $04, $20, $40, $00
 EQUB $80, $0C, $0D, $13, $3F

; ******************************************************************************
;
;       Name: DrawDashNames
;       Type: Subroutine
;   Category: Dashboard
;    Summary: Draw the dashboard into both the nametable buffers
;
; ******************************************************************************

.DrawDashNames

 LDY #7*32              ; We are about to draw the dashboard, which consists of
                        ; 7 rows of 32 tiles, so set a tile counter in Y to use
                        ; as an index into the dashNames table, so we can copy
                        ; the nametable entries from dashNames into the
                        ; nametable buffer

.ddsh1

 SETUP_PPU_FOR_ICON_BAR ; If the PPU has started drawing the icon bar, configure
                        ; the PPU to use nametable 0 and pattern table 0

 LDA dashNames-1,Y      ; Set A to the Y-th nametable entry in dashNames
                        ;
                        ; Note that we fetch from dashNames-1 as the screen is
                        ; horizontally scrolled by one tile (see below)

 STA nameBuffer0+22*32,Y    ; Store the nametable entry in both nametable
 STA nameBuffer1+22*32,Y    ; buffers, so that the dashboard starts at row 22

 DEY                    ; Decrement the tile counter in Y

 BNE ddsh1              ; Loop back to write the next nametable entry until we
                        ; have written all 7 rows of 32 tiles

                        ; Because the horizontal scroll in PPU_SCROLL is set to
                        ; 8, the leftmost tile on each row is scrolled around to
                        ; the right side, which means that in terms of tiles,
                        ; column 1 is the left edge of the screen, then columns
                        ; 2 to 31 form the body of the screen, and column 0 is
                        ; the right edge of the screen
                        ;
                        ; We therefore have to fix the tiles that appear at the
                        ; end of each row, i.e. column 0 on row 22 (for the end
                        ; of the top row of the dashboard) all the way down to
                        ; column 0 on row 28 (for the end of the bottom row of
                        ; the dashboard)

 LDA nameBuffer0+23*32  ; Wrap around the scrolled tile on row 22
 STA nameBuffer0+22*32

 LDA nameBuffer0+24*32  ; Wrap around the scrolled tile on row 23
 STA nameBuffer0+23*32

 LDA nameBuffer0+25*32  ; Wrap around the scrolled tile on row 24
 STA nameBuffer0+24*32

 LDA nameBuffer0+26*32  ; Wrap around the scrolled tile on row 25
 STA nameBuffer0+25*32

                        ; Interestingly, the scrolled tile on row 26 is omitted,
                        ; though I'm not sure why

 LDA nameBuffer0+28*32  ; Wrap around the scrolled tile on row 27
 STA nameBuffer0+27*32

 LDA nameBuffer0+29*32  ; Wrap around the scrolled tile on row 28
 STA nameBuffer0+28*32

                        ; Finally, we have to clear up the overspill in column 0
                        ; on row 29

 LDA #0                 ; Set the first tile on row 29 to the blank tile
 STA nameBuffer0+29*32

 RTS                    ; Return from the subroutine

; ******************************************************************************
;
;       Name: ResetScanner
;       Type: Subroutine
;   Category: Dashboard
;    Summary: Reset the sprites used for drawing ships on the scanner
;
; ******************************************************************************

.ResetScanner

 SETUP_PPU_FOR_ICON_BAR ; If the PPU has started drawing the icon bar, configure
                        ; the PPU to use nametable 0 and pattern table 0

                        ; We start by clearing tile rows 29 to 31 in namespace
                        ; buffer 0, which are the three rows just below the
                        ; dashboard

 LDY #3*32              ; Set Y as a tile counter for three rows of 32 tiles

 LDA #0                 ; We are going to set the tiles to the background
                        ; pattern, so set A = 0 to use as the tile number

.rscn1

 STA nameBuffer0+29*32-1,Y      ; Clear the Y-th tile from the start of row 29
                                ; in namespace buffer 0

 DEY                    ; Decrement the tile counter in Y

 BNE rscn1              ; Loop back until we have cleared all three rows

 LDA #203               ; Set the pattern number for sprites 11 and 12 (the
 STA pattSprite11       ; pitch and roll indicators) to 203, which is the I-bar
 STA pattSprite12       ; pattern

 LDA #%00000011         ; Set the attributes for sprites 11 and 12 (the pitch
 STA attrSprite11       ; and roll indicators) as follows:
 STA attrSprite12       ;
                        ;   * Bits 0-1    = sprite palette 3
                        ;   * Bit 5 clear = show in front of background
                        ;   * Bit 6 clear = do not flip horizontally
                        ;   * Bit 7 clear = do not flip vertically

 LDA #%00000000         ; Set the attributes for sprite 13 (the compass dot) as
 STA attrSprite13       ; follows:
                        ;
                        ;   * Bits 0-1    = sprite palette 0
                        ;   * Bit 5 clear = show in front of background
                        ;   * Bit 6 clear = do not flip horizontally
                        ;   * Bit 7 clear = do not flip vertically

                        ; We now reset the 24 sprites from sprite 14 to 37,
                        ; which are the sprites used to show ships on the
                        ; scanner

 LDX #24                ; Set a sprite counter in X so we reset 24 sprites

 LDY #56                ; Set Y = 56 so we start setting the attributes and tile
                        ; for sprite 56 / 4 = 14 onwards

.rscn2

 LDA #218               ; Set the pattern number for sprite Y / 4 to 218, which
 STA pattSprite0,Y      ; is the vertical bar used for drawing a ship's stick
                        ; on the scanner

 LDA #%00000000         ; Set the attributes for sprite Y / 4 as follows:
 STA attrSprite0,Y      ;
                        ;
                        ;   * Bits 0-1    = sprite palette 0
                        ;   * Bit 5 clear = show in front of background
                        ;   * Bit 6 clear = do not flip horizontally
                        ;   * Bit 7 clear = do not flip vertically

 INY                    ; Add 4 to Y so it points to the next sprite's data in
 INY                    ; the sprite buffer
 INY
 INY

 DEX                    ; Decrement the sprite counter in X

 BNE rscn2              ; Loop back until we have reset all 24 sprites

 RTS                    ; Return from the subroutine

; ******************************************************************************
;
;       Name: SendViewToPPU
;       Type: Subroutine
;   Category: PPU
;    Summary: Configure the PPU for the view type in QQ11
;  Deep dive: Views and view types in NES Elite
;
; ******************************************************************************

.SendViewToPPU

 JSR WaitForNMI         ; Wait until the next NMI interrupt has passed (i.e. the
                        ; next VBlank)

 LDA ppuCtrlCopy        ; Store the value of ppuCtrlCopy on the stack so we can
 PHA                    ; restore it at the end of the subroutine

 LDA #%00000000         ; Set A to use as the new value for PPU_CTRL below

 STA ppuCtrlCopy        ; Store the new value of PPU_CTRL in ppuCtrlCopy so we
                        ; can check its value without having to access the PPU

 STA PPU_CTRL           ; Configure the PPU by setting PPU_CTRL as follows:
                        ;
                        ;   * Bits 0-1    = base nametable address %00 ($2000)
                        ;   * Bit 2 clear = increment PPU_ADDR by 1 each time
                        ;   * Bit 3 clear = sprite pattern table is at $0000
                        ;   * Bit 4 clear = background pattern table is at $0000
                        ;   * Bit 5 clear = sprites are 8x8 pixels
                        ;   * Bit 6 clear = use PPU 0 (the only option on a NES)
                        ;   * Bit 7 clear = disable VBlank NMI generation

 STA setupPPUForIconBar ; Clear bit 7 of setupPPUForIconBar so we do nothing
                        ; when the PPU starts drawing the icon bar

 LDA #%00000000         ; Configure the PPU by setting PPU_MASK as follows:
 STA PPU_MASK           ;
                        ;   * Bit 0 clear = normal colour (not monochrome)
                        ;   * Bit 1 clear = hide leftmost 8 pixels of background
                        ;   * Bit 2 clear = hide sprites in leftmost 8 pixels
                        ;   * Bit 3 clear = hide background
                        ;   * Bit 4 clear = hide sprites
                        ;   * Bit 5 clear = do not intensify greens
                        ;   * Bit 6 clear = do not intensify blues
                        ;   * Bit 7 clear = do not intensify reds

 LDA QQ11               ; If the view type in QQ11 is not $B9 (Equip Ship),
 CMP #$B9               ; jump to svip1 to keep checking for view types
 BNE svip1

 JMP svip7              ; Jump to svip7 to set up the Equip Ship screen

.svip1

 CMP #$9D               ; If the view type in QQ11 is $9D (Long-range Chart with
 BEQ svip6              ; the normal font loaded), jump to svip6

 CMP #$DF               ; If the view type in QQ11 is $DF (Start screen with the
 BEQ svip6              ; normal font loaded), jump to svip6

 CMP #$96               ; If the view type in QQ11 is not $96 (Data on System),
 BNE svip2              ; jump to svip2 to keep checking for view types

                        ; If we get here then this is the Data on System screen

 JSR GetSystemImage_b5  ; This is the Data on System view, so fetch the
                        ; background image and foreground sprite for the current
                        ; system image and send them to the pattern buffers and
                        ; PPU

 JMP svip10             ; Jump to svip10 to finish off setting up the view

.svip2

 CMP #$98               ; If the view type in QQ11 is not $98 (Status Mode),
 BNE svip3              ; jump to svip3 to keep checking for view types

                        ; If we get here then this is the Status Mode screen

 JSR GetCmdrImage_b4    ; This is the Status Mode view, so fetch the headshot
                        ; image for the commander and store it in the pattern
                        ; buffers, and send the face and glasses images to the
                        ; PPU

 JMP svip10             ; Jump to svip10 to finish off setting up the view

.svip3

 CMP #$BA               ; If the view type in QQ11 is not $BA (Market Price),
 BNE svip4              ; jump to svip4 to keep checking for view types

                        ; If we get here then this is the Market Price screen

 LDA #HI(16*69)         ; Set PPU_ADDR to the address of pattern 69 in pattern
 STA PPU_ADDR           ; table 0, so we load the missile image here
 LDA #LO(16*69)
 STA PPU_ADDR

 LDA #HI(inventoryIcon) ; Set SC(1 0) = inventoryIcon so we send the inventory
 STA SC+1               ; icon bar image to the PPU
 LDA #LO(inventoryIcon)
 STA SC

 LDA #245               ; Set imageSentToPPU = 245 to denote that we have sent
 STA imageSentToPPU     ; the inventory icon image to the PPU

 LDX #4                 ; Set X = 4 so we send four batches of 16 bytes to the
                        ; PPU in the call to SendInventoryToPPU below

 JMP svip9              ; Jump to svip9 to send the missile image to the PPU and
                        ; finish off setting up the view

.svip4

 CMP #$BB               ; If the view type in QQ11 is not $BB (Save and load
 BNE svip5              ; with the normal and highlight fonts loaded), jump to
                        ; svip5 to keep checking for view types

                        ; If we get here then this is the Save and Load screen
                        ; with the normal and highlight fonts loaded

 LDA #HI(16*69)         ; Set PPU_ADDR to the address of pattern 69 in pattern
 STA PPU_ADDR           ; table 0, so we load the small logo image here
 LDA #LO(16*69)
 STA PPU_ADDR

 LDA #HI(smallLogoImage)    ; Set V(1 0) = smallLogoImage
 STA V+1                    ;
 LDA #LO(smallLogoImage)    ; So we can unpack the image data for the small
 STA V                      ; Elite logo into pattern 69 onwards in pattern
                            ; table 0

 LDA #3                 ; Set A = 3 so we only unpack the image data below when
                        ; imageSentToPPU does not equal 3 (i.e. if we haven't
                        ; already sent the small logo image to the PPU)

 BNE svip8              ; Jump to svip8 to unpack the image data (this BNE is
                        ; effectively a JMP as A is never zero)

.svip5

                        ; If we get here then this not one of these views:
                        ;
                        ;   * Equip Ship
                        ;   * Long-range Chart with the normal font loaded
                        ;   * Start screen with the normal font loaded
                        ;   * Data on System
                        ;   * Status Mode
                        ;   * Market Price
                        ;   * Save and load with normal and highlight fonts
                        ;     loaded
                        ;
                        ; so now we load the dashboard image, if we haven't
                        ; already

 LDA #0                 ; Set A = 0 to set as the new value of imageSentToPPU
                        ; below

 CMP imageSentToPPU     ; If imageSentToPPU = 0 then we have already sent the
 BEQ svip10             ; dashboard image to the PPU, so jump to svip10 to
                        ; finish off setting up the view without sending the
                        ; dashboard image again

 STA imageSentToPPU     ; Set imageSentToPPU = 0 to denote that we have sent the
                        ; dashboard image to the PPU

 JSR SendDashImageToPPU ; Unpack the dashboard image and send it to patterns 69
                        ; to 255 in pattern table 0 in the PPU

 JMP svip10             ; Jump to svip10 to finish off setting up the view

.svip6

                        ; If we get here then QQ11 is $9D (Long-range Chart with
                        ; the normal font loaded) or $DF (Start screen with
                        ; the normal font loaded), so now we load the font
                        ; images, starting at pattern 68 in the PPU

 LDA #36                ; Set asciiToPattern = 36, so we add 36 to an ASCII code
 STA asciiToPattern     ; in the CHPR routine to get the pattern number in the
                        ; PPU of the corresponding character image (as we are
                        ; about to load the font at pattern 68, and the font
                        ; starts with a space character, which is ASCII 32, and
                        ; 32 + 36 = 68)

 LDA #1                 ; Set A = 1 to set as the new value of imageSentToPPU
                        ; below

 CMP imageSentToPPU     ; If imageSentToPPU = 1 then we have already sent the
 BEQ svip10             ; font image to the PPU, so jump to svip10 to finish off
                        ; setting up the view without sending the font image
                        ; again

 STA imageSentToPPU     ; Set imageSentToPPU = 1 to denote that we have sent the
                        ; font image to the PPU

 LDA #HI(16*68)         ; Set PPU_ADDR to the address of pattern 68 in pattern
 STA PPU_ADDR           ; table 0
 LDA #LO(16*68)
 STA PPU_ADDR

 LDX #95                ; Set X = 95 so the call to SendFontImageToPPU sends 95
                        ; font patterns to the PPU as a colour 1 font on a black
                        ; background (though the 95th character is full of
                        ; random junk, so it never gets used)

 LDA #HI(fontImage)     ; Set SC(1 0) = fontImage so we send the font image in
 STA SC+1               ; the call to SendFontImageToPPU
 LDA #LO(fontImage)
 STA SC

 JSR SendFontImageToPPU ; Send the 95 font patterns to the PPU as a colour 1
                        ; font on a black background

 LDA QQ11               ; If the view type in QQ11 is not $DF (Start screen with
 CMP #$DF               ; the normal font loaded), then jump to svip10 to
 BNE svip10             ; finish off setting up the view without loading the
                        ; logo ball image

 LDA #HI(16*227)        ; Set PPU_ADDR to the address of pattern 227 in pattern
 STA PPU_ADDR           ; table 0
 LDA #LO(16*227)
 STA PPU_ADDR

 LDA #HI(logoBallImage) ; Set V(1 0) = logoBallImage
 STA V+1                ;
 LDA #LO(logoBallImage) ; So we can unpack the image data for the ball at the
 STA V                  ; bottom of the big Elite logo into pattern 227 onwards
                        ; in pattern table 0

 JSR UnpackToPPU        ; Unpack the image data to the PPU

 JMP svip10             ; Jump to svip10 to finish off setting up the view

.svip7

                        ; If we get here then this is the Equip Ship screen

 LDA #HI(16*69)         ; Set PPU_ADDR to the address of pattern 69 in pattern
 STA PPU_ADDR           ; table 0
 LDA #LO(16*69)
 STA PPU_ADDR

 LDA #HI(cobraImage)    ; Set V(1 0) = cobraImage
 STA V+1                ;
 LDA #LO(cobraImage)    ; So we can unpack the image data for the Cobra Mk III
 STA V                  ; image into pattern 69 onwards in pattern table 0

 LDA #2                 ; Set A = 2 so we only unpack the image data when
                        ; imageSentToPPU does not equal 2, i.e. if we have not
                        ; already sent the Cobra image to the PPU

.svip8

                        ; If we get here then A determines which image we should
                        ; be loading (the Cobra Mk III image when A = 2, or the
                        ; small logo image when A = 3)

 CMP imageSentToPPU     ; If imageSentToPPU = A then we have already sent the
 BEQ svip10             ; image specified in A to the PPU

 STA imageSentToPPU     ; Set imageSentToPPU = A to denote that we have sent the
                        ; relevant image to the PPU

 JSR UnpackToPPU        ; Unpack the image data to the PPU

 JMP svip10             ; Jump to svip10 to finish off setting up the view

.svip9

 JSR SendInventoryToPPU ; Send X batches of 16 bytes from SC(1 0) to the PPU
                        ;
                        ; We only get here with the following values:
                        ;
                        ;   SC(1 0) = inventoryIcon
                        ;
                        ;   X = 4
                        ;
                        ; So this sends 16 * 4 = 64 bytes from inventoryIcon to
                        ; the PPU, which sends the inventory icon bar image

.svip10

                        ; We have finished setting up any view-specific images
                        ; and settings, so now we finish off with some settings
                        ; that apply to all views

 JSR SetupSprite0       ; Set the coordinates of sprite 0 so we can detect when
                        ; the PPU starts to draw the icon bar

                        ; We now send patterns 0 to 4 to the PPU, which contain
                        ; the box edges

 LDA #HI(PPU_PATT_1+16*0)   ; Set PPU_ADDR to the address of pattern 0 in
 STA PPU_ADDR               ; pattern table 1
 LDA #LO(PPU_PATT_1+16*0)
 STA PPU_ADDR

 LDY #0                 ; We are about to send a batch of bytes to the PPU, so
                        ; set an index counter in Y

 LDX #80                ; There are 80 bytes of pattern data in the five tile
                        ; patterns (5 * 16 bytes), so set a byte counter in X

.svip11

 LDA boxEdgeImages,Y    ; Send the Y-th byte from boxEdgeImages to the PPU
 STA PPU_DATA

 INY                    ; Increment the index counter in Y

 DEX                    ; Decrement the byte counter in X

 BNE svip11             ; Loop back until we have sent all 80 bytes to the PPU

                        ; We now zero pattern 255 in pattern table 1 so it is
                        ; a full block of background colour

 LDA #HI(PPU_PATT_1+16*255) ; Set PPU_ADDR to the address of pattern 255 in
 STA PPU_ADDR               ; pattern table 1
 LDA #LO(PPU_PATT_1+16*255)
 STA PPU_ADDR

 LDA #0                 ; We are going to zero the pattern, so set A = 0 to send
                        ; to the PPU

 LDX #16                ; There are 16 bytes in a pattern, so set a byte counter
                        ; in X

.svip12

 STA PPU_DATA           ; Send a zero to the PPU

 DEX                    ; Decrement the byte counter in X

 BNE svip12             ; Loop back until we have sent all 16 zeroes to the PPU

 JSR MakeSoundsAtVBlank ; Wait for the next VBlank and make the current sounds
                        ; (music and sound effects)

 LDX #0                 ; Configure bitplane 0 to be sent to the PPU in the NMI,
 JSR SendBitplaneToPPU  ; so the patterns and nametables will be sent to the PPU
                        ; during the next few VBlanks

 LDX #1                 ; Configure bitplane 1 to be sent to the PPU in the NMI
 JSR SendBitplaneToPPU  ; so the patterns and nametables will be sent to the PPU
                        ; during the next few VBlanks

 LDX #0                 ; Hide bitplane 0, so:
 STX hiddenBitplane     ;
                        ;   * Colour %01 (1) is the hidden colour (black)
                        ;   * Colour %10 (2) is the visible colour (cyan)

 STX nmiBitplane        ; Set nmiBitplane = 0 so bitplane 0 is the first to be
                        ; sent in the NMI handler

 JSR SetDrawingBitplane ; Set the drawing bitplane to bitplane 0

 JSR MakeSoundsAtVBlank ; Wait for the next VBlank and make the current sounds
                        ; (music and sound effects)

 LDA QQ11               ; Set the old view type in QQ11a to the new view type in
 STA QQ11a              ; QQ11, to denote that we have now changed view to the
                        ; view in QQ11

 AND #%01000000         ; If bit 6 of the view type is clear, then there is an
 BEQ svip13             ; icon bar, so jump to svip13 to set showUserInterface
                        ; to denote there is a user interface

 LDA QQ11               ; If the view type in QQ11 is $DF (Start screen with
 CMP #$DF               ; the normal font loaded), jump to svip13 to set bit 7
 BEQ svip13             ; of showUserInterface so that the nametable and palette
                        ; table get set to 0 when sprite 0 is drawn, even though
                        ; there is no icon bar (this ensures that the part of
                        ; the Start screen below x-coordinate 166 is always
                        ; drawn using nametable 0, which covers the interface
                        ; part of the screen where the language gets chosen)

                        ; If we get here then there is no user interface and
                        ; and this is not the Start screen with the normal font
                        ; loaded

 LDA #0                 ; Clear bit 7 of A so we can set showUserInterface to
 BEQ svip14             ; denote that there is no user interface, and jump
                        ; to svip14 to set the value (this BEQ is effectively
                        ; a JMP as A is always zero)

.svip13

 LDA #%10000000         ; Set bit 7 of A so we can set showUserInterface to
                        ; denote that there is a user interface

.svip14

 STA showUserInterface  ; Set showUserInterface to the value of A that we just
                        ; set for the view

 PLA                    ; Restore the copy of ppuCtrlCopy that we put on the
 STA ppuCtrlCopy        ; stack so it's preserved across the call to the
                        ; subroutine

 STA PPU_CTRL           ; Set PPU_CTRL to the copy we made, so it's also
                        ; preserved across the call

 JMP FadeToColour_b3    ; Reverse-fade the screen from black to full colour over
                        ; the next four VBlanks, returning from the subroutine
                        ; using a tail call

; ******************************************************************************
;
;       Name: SendFontImageToPPU
;       Type: Subroutine
;   Category: PPU
;    Summary: Send a font to the PPU as a colour 1 font on a colour 0 background
;             (i.e. colour 1 on black)
;
; ------------------------------------------------------------------------------
;
; Arguments:
;
;   X                   The number of patterns to send to the PPU
;
;   SC(1 0)             The address of the data in the pattern buffer to send to
;                       the PPU
;
; ******************************************************************************

.SendFontImageToPPU

 LDY #0                 ; We are about to send a batch of bytes to the PPU, so
                        ; set an index counter in Y

.sppu1

                        ; We repeat the following code eight times, so it sends
                        ; all eight bytes of the pattern into bitplane 0 to the
                        ; PPU
                        ;
                        ; Bitplane 0 is used for bit 0 of the colour number, and
                        ; we send zeroes to bitplane 1 below, which is used for
                        ; bit 1 of the colour number, so the result is a pattern
                        ; with the font in colour 1 on background colour 0

 LDA (SC),Y             ; Send the Y-th byte of SC(1 0) to the PPU and increment
 STA PPU_DATA           ; the index in Y
 INY

 LDA (SC),Y             ; Send the Y-th byte of SC(1 0) to the PPU and increment
 STA PPU_DATA           ; the index in Y
 INY

 LDA (SC),Y             ; Send the Y-th byte of SC(1 0) to the PPU and increment
 STA PPU_DATA           ; the index in Y
 INY

 LDA (SC),Y             ; Send the Y-th byte of SC(1 0) to the PPU and increment
 STA PPU_DATA           ; the index in Y
 INY

 LDA (SC),Y             ; Send the Y-th byte of SC(1 0) to the PPU and increment
 STA PPU_DATA           ; the index in Y
 INY

 LDA (SC),Y             ; Send the Y-th byte of SC(1 0) to the PPU and increment
 STA PPU_DATA           ; the index in Y
 INY

 LDA (SC),Y             ; Send the Y-th byte of SC(1 0) to the PPU and increment
 STA PPU_DATA           ; the index in Y
 INY

 LDA (SC),Y             ; Send the Y-th byte of SC(1 0) to the PPU and increment
 STA PPU_DATA           ; the index in Y
 INY

 BNE sppu2              ; If Y just wrapped around to zero, increment the high
 INC SC+1               ; byte of SC(1 0) to point to the next page in memory

.sppu2

 LDA #0                 ; Send the pattern's second bitplane to the PPU, so all
 STA PPU_DATA           ; eight bytes of the pattern in bitplane 1 are set to
 STA PPU_DATA           ; zero (so bit 1 of the colour number is zero)
 STA PPU_DATA
 STA PPU_DATA
 STA PPU_DATA
 STA PPU_DATA
 STA PPU_DATA
 STA PPU_DATA

 DEX                    ; Decrement the pattern counter in X

 BNE sppu1              ; Loop back to send the next pattern to the PPU until we
                        ; have sent X patterns

 RTS                    ; Return from the subroutine

; ******************************************************************************
;
;       Name: SendDashImageToPPU
;       Type: Subroutine
;   Category: PPU
;    Summary: Unpack the dashboard image and send it to patterns 69 to 255 in
;             pattern table 0 in the PPU
;  Deep dive: Views and view types in NES Elite
;
; ******************************************************************************

.SendDashImageToPPU

 LDA #HI(16*69)         ; Set PPU_ADDR to the address of pattern 69 in pattern
 STA PPU_ADDR           ; table 0
 LDA #LO(16*69)
 STA PPU_ADDR

 LDA #HI(dashImage)     ; Set V(1 0) = dashImage
 STA V+1                ;
 LDA #LO(dashImage)     ; So we can unpack the image data for the dashboard into
 STA V                  ; into patterns 69 to 255 in pattern table 0

 JMP UnpackToPPU        ; Unpack the image data to the PPU, returning from the
                        ; subroutine using a tail call

; ******************************************************************************
;
;       Name: SendBitplaneToPPU
;       Type: Subroutine
;   Category: PPU
;    Summary: Send a bitplane to the PPU immediately
;  Deep dive: Views and view types in NES Elite
;
; ------------------------------------------------------------------------------
;
; Arguments:
;
;   X                   The number of the bitplane to configure to be sent to
;                       the PPU in the NMI handler
;
; ******************************************************************************

.SendBitplaneToPPU

 STX drawingBitplane    ; Set the drawing bitplane and the NMI bitplane to the
 STX nmiBitplane        ; argument in X, so all the following operations apply
                        ; to the specified bitplane

 STX hiddenBitplane     ; Hide bitplane X so it isn't visible on-screen while
                        ; we do the following

 LDA #0                 ; Tell the NMI handler to send nametable entries from
 STA firstNameTile      ; tile 0 onwards

 LDA QQ11               ; If the view type in QQ11 is not $DF (Start screen with
 CMP #$DF               ; the normal font loaded), then jump to sbit1 to skip
 BNE sbit1              ; the following and start sending pattern data from
                        ; pattern 37 onwards

 LDA #4                 ; This is the Start screen with font loaded in bitplane
 BNE sbit2              ; 0, so set A = 4 so we start sending pattern data
                        ; from pattern 4 onwards

.sbit1

 LDA #37                ; So set A = 37 so we start sending pattern data from
                        ; pattern 37 onwards

.sbit2

 STA firstPattern       ; Tell the NMI handler to send pattern entries from
                        ; pattern A in the buffer

 LDA firstFreePattern   ; Tell the NMI handler to send pattern entries up to the
 STA lastPattern,X      ; first free pattern, for the drawing bitplane in X

 LDA #%11000100         ; Set the bitplane flags for the drawing bitplane to the
 JSR SetDrawPlaneFlags  ; following:
                        ;
                        ;   * Bit 2 set   = send tiles up to end of the buffer
                        ;   * Bit 3 clear = don't clear buffers after sending
                        ;   * Bit 4 clear = we've not started sending data yet
                        ;   * Bit 5 clear = we have not yet sent all the data
                        ;   * Bit 6 set   = send both pattern and nametable data
                        ;   * Bit 7 set   = send data to the PPU
                        ;
                        ; Bits 0 and 1 are ignored and are always clear
                        ;
                        ; This configures the NMI to send nametable and pattern
                        ; data for the drawing bitplane to the PPU during VBlank

 JSR SendDataNowToPPU   ; Send the drawing bitplane buffers to the PPU
                        ; immediately, without trying to squeeze it into VBlanks

 LDA firstFreePattern   ; Set clearingPattern for the drawing bitplane to the
 STA clearingPattern,X  ; number of the first free pattern, so the NMI handler
                        ; only clears patterns from this point onwards
                        ;
                        ; This ensures that the tiles that we just sent to the
                        ; PPU don't get cleared out by the NMI handler

 RTS                    ; Return from the subroutine

; ******************************************************************************
;
;       Name: SendDataNowToPPU
;       Type: Subroutine
;   Category: PPU
;    Summary: Send the specified bitplane buffers to the PPU immediately,
;             without trying to squeeze it into VBlanks
;
; ------------------------------------------------------------------------------
;
; Arguments:
;
;   X                   The number of the bitplane to send
;
; ------------------------------------------------------------------------------
;
; Returns:
;
;   X                   X is preserved
;
; ******************************************************************************

.SendDataNowToPPU

 TXA                    ; Store the bitplane in X on the stack
 PHA

 LDA #HI(16383)         ; Set cycleCount = 16383 so the call to SendBuffersToPPU
 STA cycleCount+1       ; runs for as long as possible without quitting early
 LDA #LO(16383)         ; (we are not in the NMI handler, so we don't need to
 STA cycleCount         ; count cycles, so this just ensures that the
                        ; cycle-counting checks are not triggered where
                        ; possible)

 JSR SendBuffersToPPU   ; Send the nametable and palette buffers to the PPU for
                        ; bitplane X, as configured in the bitplane flags

 PLA                    ; Set X to the bitplane number we stored on the stack
 PHA                    ; above, leaving the value on the stack so we can still
 TAX                    ; restore it at the end of the routine

 LDA bitplaneFlags,X    ; If bit 5 is set in the flags for bitplane X, then we
 AND #%00100000         ; have now sent all the data to the PPU for this
 BNE sdat1              ; bitplane, so jump to sdat1 to return from the
                        ; subroutine

 LDA #HI(4096)          ; Otherwise the large cycle count above wasn't long
 STA cycleCount+1       ; enough to send all the data to the PPU, so set
 LDA #LO(4096)          ; cycleCount to 4096 to have another go
 STA cycleCount

 JSR SendBuffersToPPU   ; Send the nametable and palette buffers to the PPU for
                        ; bitplane X, as configured in the bitplane flags

 PLA                    ; Retrieve the bitplane number from the stack
 TAX

 LDA bitplaneFlags,X    ; If bit 5 is set in the flags for bitplane X, then we
 AND #%00100000         ; have now sent all the data to the PPU for this
 BNE sdat2              ; bitplane, so jump to sdat2 to return from the
                        ; subroutine

                        ; Otherwise we still haven't sent all the data to the
                        ; PPU, so we play the background music and repeat the
                        ; above

 JSR MakeSoundsAtVBlank ; Wait for the next VBlank and make the current sounds
                        ; (music and sound effects)

 JMP SendDataNowToPPU   ; Loop back to keep sending data to the PPU

.sdat1

 PLA                    ; Retrieve the bitplane number from the stack
 TAX

.sdat2

 JMP MakeSoundsAtVBlank ; Wait for the next VBlank and make the current sounds
                        ; (music and sound effects), returning from the
                        ; subroutine using a tail call

; ******************************************************************************
;
;       Name: SetupViewInNMI
;       Type: Subroutine
;   Category: Drawing the screen
;    Summary: Setup the view and configure the NMI to send both bitplanes to the
;             PPU during VBlank
;  Deep dive: Views and view types in NES Elite
;
; ------------------------------------------------------------------------------
;
; This routine is only ever called with the following bitplane flags in A:
;
;   * Bit 2 clear = send tiles up to configured numbers
;   * Bit 3 clear = don't clear buffers after sending
;   * Bit 4 clear = we've not started sending data yet
;   * Bit 5 clear = we have not yet sent all the data
;   * Bit 6 set   = send both pattern and nametable data
;   * Bit 7 set   = send data to the PPU
;
; Bits 0 and 1 are ignored and are always clear.
;
; This routine therefore configures the NMI to send both bitplanes to the PPU.
;
; ------------------------------------------------------------------------------
;
; Arguments:
;
;   A                   The bitplane flags to set for the drawing bitplane
;
; ******************************************************************************

.SetupViewInNMI

 PHA                    ; Store the bitplane flags on the stack so we can
                        ; retrieve them later

 JSR WaitForPPUToFinish ; Wait until both bitplanes of the screen have been
                        ; sent to the PPU, so the screen is fully updated and
                        ; there is no more data waiting to be sent to the PPU

 LDA QQ11               ; If the view type in QQ11 is not $96 (Data on System),
 CMP #$96               ; jump to svin1 to keep checking for view types
 BNE svin1

                        ; If we get here then this is the Data on System screen

 JSR GetSystemBack_b5   ; Fetch the background image for the current system and
                        ; store it in the pattern buffers

 JMP svin2              ; Jump to svin2 to continue setting up the view

.svin1

 CMP #$98               ; If the view type in QQ11 is not $98 (Status Mode),
 BNE svin2              ; jump to svin2 to keep checking for view types

                        ; If we get here then this is the Status Mode screen

 JSR GetHeadshot_b4     ; Fetch the headshot image for the commander and store
                        ; it in the pattern buffers, starting at pattern number
                        ; picturePattern

.svin2

 LDA QQ11               ; If bit 6 of the view type is clear, then there is an
 AND #%01000000         ; icon bar, so jump to svin3 to skip the following
 BEQ svin3              ; instruction

 LDA #0                 ; There is no icon bar, so set showUserInterface to 0 to
 STA showUserInterface  ; indicate that there is no user interface

.svin3

 JSR SetupSprite0       ; Set the coordinates of sprite 0 so we can detect when
                        ; the PPU starts to draw the icon bar

 LDA #0                 ; Tell the NMI handler to send nametable entries from
 STA firstNameTile      ; tile 0 onwards

 LDA #37                ; Tell the NMI handler to send pattern entries from
 STA firstPattern       ; pattern 37 in the buffer

 LDA firstFreePattern   ; Tell the NMI handler to send pattern entries up to the
 STA lastPattern        ; first free pattern, for both bitplanes
 STA lastPattern+1

 LDA #%01010100         ; This instruction has no effect as we are about to pull
                        ; the value of A from the stack

 LDX #0                 ; This instruction has no effect as the call to
                        ; SetDrawPlaneFlags overwrites X with the value of the
                        ; drawing bitplane, though this could be remnants of
                        ; code to set the drawing bitplane to 0, as the
                        ; following code depends on this being the case

 PLA                    ; Retrieve the bitplane flags that were passed to this
                        ; routine and which we stored on the stack above

 JSR SetDrawPlaneFlags  ; Set the bitplane flags to A for the current drawing
                        ; bitplane, which must be bitplane 0 at this point
                        ; (though it is not entirely obvious why this is the
                        ; case)

 INC drawingBitplane    ; Increment drawingBitplane to 1

 JSR SetDrawPlaneFlags  ; Set the bitplane flags to A for bitplane 1

 JSR WaitForPPUToFinish ; Wait until both bitplanes of the screen have been
                        ; sent to the PPU, so the screen is fully updated and
                        ; there is no more data waiting to be sent to the PPU

 LDA #80                ; Tell the PPU to send nametable entries up to tile
 STA lastNameTile       ; 80 * 8 = 640 (i.e. to the end of tile row 19) in both
 STA lastNameTile+1     ; bitplanes

 LDA QQ11               ; Set the old view type in QQ11a to the new view type
 STA QQ11a              ; in QQ11, to denote that we have now changed view to
                        ; the view in QQ11

 LDA firstFreePattern   ; Set clearingPattern for both bitplanes to the number
 STA clearingPattern    ; of the first free pattern, so the NMI handler only
 STA clearingPattern+1  ; clears patterns from this point onwards
                        ;
                        ; This ensures that the tiles that have already been
                        ; sent to the PPU above don't get cleared out by the NMI
                        ; handler

 LDA #0                 ; Set A = 0, though this has no effect as we don't use
                        ; it

 LDX #0                 ; Hide bitplane 0, so:
 STX hiddenBitplane     ;
                        ;   * Colour %01 (1) is the hidden colour (black)
                        ;   * Colour %10 (2) is the visible colour (cyan)

 STX nmiBitplane        ; Set nmiBitplane = 0 so bitplane 0 is the first to be
                        ; sent in the NMI handler

 JSR SetDrawingBitplane ; Set the drawing bitplane to bitplane 0

 LDA QQ11               ; If bit 6 of the view type is set, then there is no
 AND #%01000000         ; icon bar, so jump to svin4 to skip the following
 BNE svin4              ; instructions

 JSR WaitForNMI         ; Wait until the next NMI interrupt has passed (i.e. the
                        ; next VBlank)

 LDA #%10000000         ; Set bit 7 of showUserInterface to denote that there is
 STA showUserInterface  ; a user interface

.svin4

 LDA screenFadedToBlack ; If bit 7 of screenFadedToBlack is clear then the
 BPL svin5              ; screen is visible and has not been faded to black, so
                        ; jump to svin5 to update the screen without fading it

 JMP FadeToColour_b3    ; Reverse-fade the screen from black to full colour over
                        ; the next four VBlanks, returning from the subroutine
                        ; using a tail call

.svin5

 LDA QQ11               ; Set X to the new view type in the low nibble of QQ11
 AND #%00001111
 TAX

 LDA paletteForView,X   ; Set A to the palette number used by the view from the
 CMP screenReset        ; paletteForView table, compare it to screenReset, set
 STA screenReset        ; the processor flags accordingly, and store the palette
                        ; number in screenReset
                        ;
                        ; This has no effect, as screenReset is not read
                        ; anywhere and neither the value of A nor the processor
                        ; flags are used in the following

 JSR GetViewPalettes    ; Get the palette for the view type in QQ11a and store
                        ; it in a table at XX3

 DEC updatePaletteInNMI ; Decrement updatePaletteInNMI to a non-zero value so we
                        ; do send palette data from XX3 to the PPU during NMI,
                        ; which will ensure the screen updates with the colours
                        ; as we fade to black

 JSR WaitForNMI         ; Wait until the next NMI interrupt has passed (i.e. the
                        ; next VBlank) so we know the palette data has been sent
                        ; to the PPU

 INC updatePaletteInNMI ; Increment updatePaletteInNMI back to the value it had
                        ; before we decremented it above

 RTS                    ; Return from the subroutine

; ******************************************************************************
;
;       Name: paletteForView
;       Type: Variable
;   Category: Drawing the screen
;    Summary: Palette numbers for each view
;
; ------------------------------------------------------------------------------
;
; These palette numbers refer to the palettes in the viewPalettes table.
;
; ******************************************************************************

.paletteForView

 EQUB  0                ; Space view
 EQUB  2                ; Title screen
 EQUB 10                ; Mission 1 briefing: rotating ship
 EQUB 10                ; Mission 1 briefing: ship and text
 EQUB  0                ; Game Over screen
 EQUB 10                ; Text-based mission briefing
 EQUB  6                ; Data on System
 EQUB  8                ; Inventory
 EQUB  8                ; Status Mode
 EQUB  5                ; Equip Ship
 EQUB  1                ; Market Price
 EQUB  7                ; Save and load
 EQUB  3                ; Short-range Chart
 EQUB  4                ; Long-range Chart
 EQUB  0                ; Unused
 EQUB  9                ; Start screen

; ******************************************************************************
;
;       Name: boxEdgeImages
;       Type: Variable
;   Category: Drawing the screen
;    Summary: Image data for patterns 0 to 4
;
; ------------------------------------------------------------------------------
;
; This table contains image data for patterns 0 to 4, which are as follows:
;
;   * 0 is the blank tile (all black)
;
;   * 1 contains a vertical bar down the right edge of the pattern (for the
;     left box edge)
;
;   * 2 contains a vertical bar down the left edge of the pattern (for the
;     right box edge)
;
;   * 3 contains a horizontal bar along the lower-middle of the pattern (for the
;     top box edge)
;
;   * 4 contains the first pattern for the top-left corner of the icon bar
;
; ******************************************************************************

.boxEdgeImages

 EQUB $00, $00, $00, $00
 EQUB $00, $00, $00, $00
 EQUB $00, $00, $00, $00
 EQUB $00, $00, $00, $00

 EQUB $00, $00, $00, $00
 EQUB $00, $00, $00, $00
 EQUB $03, $03, $03, $03
 EQUB $03, $03, $03, $03

 EQUB $00, $00, $00, $00
 EQUB $00, $00, $00, $00
 EQUB $C0, $C0, $C0, $C0
 EQUB $C0, $C0, $C0, $C0

 EQUB $00, $00, $00, $00
 EQUB $00, $00, $00, $00
 EQUB $00, $00, $00, $FF
 EQUB $FF, $FF, $00, $00

 EQUB $00, $00, $00, $00
 EQUB $00, $00, $00, $00
 EQUB $0F, $1F, $1F, $DF
 EQUB $DF, $BF, $BF, $BF

; ******************************************************************************
;
;       Name: ResetScreen
;       Type: Subroutine
;   Category: Start and end
;    Summary: Reset the screen by clearing down the PPU, setting all colours to
;             black, and resetting the screen-related variables
;
; ******************************************************************************

.ResetScreen

 JSR WaitFor3xVBlank    ; Wait for three VBlanks to pass

 LDA #HI(20*32)         ; Set iconBarRow(1 0) = 20*32
 STA iconBarRow+1       ;
 LDA #LO(20*32)         ; So the icon bar is on row 20
 STA iconBarRow

                        ; We now want to set all the colours in all the palettes
                        ; to black, to hide anything that's on-screen

 LDA #$3F               ; Set PPU_ADDR = $3F00, so it points to the background
 STA PPU_ADDR           ; colour palette entry in the PPU
 LDA #$00
 STA PPU_ADDR

 LDA #$0F               ; Set A to $0F, which is the HSV value for black

 LDX #31                ; There are 32 bytes in the background and sprite
                        ; palettes in the PPU, so set a loop counter in X to
                        ; count through them all

.rscr1

 STA PPU_DATA           ; Send A to the PPU to set palette entry X to black

 DEX                    ; Decrement the loop counter

 BPL rscr1              ; Loop back until we have set all the palette entries to
                        ; black

                        ; We now want to reset both PPU nametables to show blank
                        ; tiles (i.e. tile 0), so nothing is shown on-screen
                        ;
                        ; The two nametables and associated attribute tables are
                        ; structured like this in the PPU:
                        ;
                        ;   * PPU_NAME_0 ($2000 to $23BF)
                        ;   * PPU_ATTR_0 ($23C0 to $23FF)
                        ;   * PPU_NAME_1 ($2400 to $27BF)
                        ;   * PPU_ATTR_1 ($27C0 to $27FF)
                        ;
                        ; Each nametable/attribute table consists of 1024 bytes
                        ; (i.e. four pages of 256 bytes), and because the tables
                        ; are consecutive in PPU memory, we can zero the whole
                        ; lot by sending eight pages of zeroes to the PPU,
                        ; tarting at the start of nametable 0 at PPU_NAME_0

 LDA #HI(PPU_NAME_0)    ; Set PPU_ADDR to PPU_NAME_0, so it points to nametable
 STA PPU_ADDR           ; 0 in the PPU
 LDA #LO(PPU_NAME_0)
 STA PPU_ADDR

 LDA #0                 ; Set A = 0 so we can send it to the PPU to fill both
                        ; PPU nametables with blank tiles

 LDX #8                 ; We want to zero 8 pages of 256 bytes, so set a page
                        ; counter in X

 LDY #0                 ; Set Y as a byte counter to count through each of the
                        ; 256 bytes in a page of memory

.rscr2

 STA PPU_DATA           ; Zero the next entry in the nametable

 DEY                    ; Decrement the byte counter

 BNE rscr2              ; Loop back until we have zeroed a whole page

 JSR WaitFor3xVBlank    ; Wait for three VBlanks to pass

 LDA #0                 ; Set A = 0 again, as it gets changed by WaitFor3xVBlank

 DEX                    ; Decrement the page counter

 BNE rscr2              ; Loop back until we have zeroed 8 pages of nametable in
                        ; the PPU

 LDA #245               ; Set screenReset = 245, though this is not used
 STA screenReset        ; anywhere, so this has no effect on anything

 STA imageSentToPPU     ; Set imageSentToPPU = 245 to denote that we have sent
                        ; the inventory icon image to the PPU

                        ; We now send patterns 0 to 4 to the PPU, to set up the
                        ; blank tile (pattern 0), the three box edges (patterns
                        ; 1 to 3) and the top-left corner of the icon bar
                        ; (pattern 4)
                        ;
                        ; We do this for both pattern tables

 LDA #HI(PPU_PATT_0)    ; Set PPU_ADDR to PPU_PATT_0, so it points to pattern
 STA PPU_ADDR           ; table 0 in the PPU
 LDA #LO(PPU_PATT_0)
 STA PPU_ADDR

 LDY #0                 ; Set Y to use as an index counter as we work through
                        ; the boxEdgeImages table and send its data to the PPU

 LDX #80                ; The boxEdgeImages table contains five patterns with 16
                        ; bytes per pattern, so that's a total of 80 bytes to
                        ; send to the PPU, so set X as a byte counter

.rscr3

 LDA boxEdgeImages,Y    ; Send the Y-th entry from the boxEdgeImages table to
 STA PPU_DATA           ; the PPU

 INY                    ; Increment the index into the boxEdgeImages table to
                        ; point at the next byte

 DEX                    ; Decrement the byte counter

 BNE rscr3              ; Loop back until we have sent all 80 bytes to the PPU

 LDA #HI(PPU_PATT_1)    ; Set PPU_ADDR to PPU_PATT_1, so it points to pattern
 STA PPU_ADDR           ; table 1 in the PPU
 LDA #LO(PPU_PATT_1)
 STA PPU_ADDR

 LDY #0                 ; Set Y to use as an index counter as we work through
                        ; the boxEdgeImages table and send its data to the PPU

 LDX #80                ; The boxEdgeImages table contains five patterns with 16
                        ; bytes per pattern, so that's a total of 80 bytes to
                        ; send to the PPU, so set X as a byte counter

.rscr4

 LDA boxEdgeImages,Y    ; Send the Y-th entry from the boxEdgeImages table to
 STA PPU_DATA           ; the PPU

 INY                    ; Increment the index into the boxEdgeImages table to
                        ; point at the next byte

 DEX                    ; Decrement the byte counter

 BNE rscr4              ; Loop back until we have sent all 80 bytes to the PPU

                        ; We now reset the sprite buffer by setting all 64
                        ; sprites as follows:
                        ;
                        ;   * Set the coordinates to (0, 240), which is just
                        ;     below the bottom of the screen, so the sprite is
                        ;     hidden from view
                        ;
                        ;   * Set the pattern number to 254 (this value seems to
                        ;     be arbitrary, but is possibly 254 so that sprite 0
                        ;     keeps using pattern 254 throughout the reset)
                        ;
                        ;   * Set the attributes so the sprite uses palette 3,
                        ;     is shown in front of the background, and is not
                        ;     flipped in either direction

 LDY #0                 ; We are about to loop through the sprite buffer, so set
                        ; a byte index in Y

.rscr5

 LDA #240               ; Set the y-coordinate for this sprite to 240, to move
 STA ySprite0,Y         ; it off the bottom of the screen

 INY                    ; Increment Y to point to the second byte for this
                        ; sprite, i.e. pattSprite0,Y

 LDA #254               ; Set the pattern number for this sprite to 254
 STA ySprite0,Y

 INY                    ; Increment Y to point to the third byte for this
                        ; sprite, i.e. attrSprite0,Y

 LDA #%00000011         ; Set the attributes for this sprite as follows:
 STA ySprite0,Y         ;
                        ;   * Bits 0-1    = sprite palette 3
                        ;   * Bit 5 clear = show in front of background
                        ;   * Bit 6 clear = do not flip horizontally
                        ;   * Bit 7 clear = do not flip vertically

 INY                    ; Increment Y to point to the fourth byte for this
                        ; sprite, i.e. xSprite0,Y

 LDA #0                 ; Set the x-coordinate for this sprite to 0
 STA ySprite0,Y

 INY                    ; Increment Y to point to the first byte for the next
                        ; sprite
 BNE rscr5

 JSR SendDashImageToPPU ; Unpack the dashboard image and send it to patterns 69
                        ; to 255 in pattern table 0 in the PPU

                        ; We now set up sprite 0, which is used to detect when
                        ; the PPU starts drawing the icon bar, so this places
                        ; the sprite at the right side of the screen, just
                        ; above the icon bar, so when the PPU gets to this part
                        ; of the screen, it will set the sprite 0 collision flag
                        ; which we can then detect

 LDA #157+YPAL          ; Set sprite 0 as follows:
 STA ySprite0           ;
 LDA #254               ;   * Set the coordinates to (248, 157)
 STA pattSprite0        ;
 LDA #248               ;   * Set the pattern number to 254
 STA xSprite0           ;
 LDA #%00100011         ;   * Set the attributes as follows:
 STA attrSprite0        ;
                        ;     * Bits 0-1    = sprite palette 3
                        ;     * Bit 5 set   = show behind background
                        ;     * Bit 6 clear = do not flip horizontally
                        ;     * Bit 7 clear = do not flip vertically

                        ; We now set sprites 1 to 4 so they contain the four
                        ; corners of the icon bar pointer:
                        ;
                        ;   * Sprite 1 = top-left corner
                        ;   * Sprite 2 = top-right corner
                        ;   * Sprite 3 = bottom-left corner
                        ;   * Sprite 4 = bottom-right corner

 LDA #251               ; Set sprites 1 and 2 to use pattern 251
 STA pattSprite1
 STA pattSprite2

 LDA #253               ; Set sprites 3 and 4 to use pattern 253
 STA pattSprite3
 STA pattSprite4

 LDA #%00000011         ; Set the attributes for sprite 1 as follows:
 STA attrSprite1        ;
                        ;   * Bits 0-1    = sprite palette 3
                        ;   * Bit 5 clear = show in front of background
                        ;   * Bit 6 clear = do not flip horizontally
                        ;   * Bit 7 clear = do not flip vertically

 LDA #%01000011         ; Set the attributes for sprite 2 as follows:
 STA attrSprite2        ;
                        ;   * Bits 0-1    = sprite palette 3
                        ;   * Bit 5 clear = show in front of background
                        ;   * Bit 6 set   = flip horizontally
                        ;   * Bit 7 clear = do not flip vertically

 LDA #%01000011         ; Set the attributes for sprite 3 as follows:
 STA attrSprite3        ;
                        ;   * Bits 0-1    = sprite palette 3
                        ;   * Bit 5 clear = show in front of background
                        ;   * Bit 6 set   = flip horizontally
                        ;   * Bit 7 clear = do not flip vertically

 LDA #%00000011         ; Set the attributes for sprite 4 as follows:
 STA attrSprite4        ;
                        ;   * Bits 0-1    = sprite palette 3
                        ;   * Bit 5 clear = show in front of background
                        ;   * Bit 6 clear = do not flip horizontally
                        ;   * Bit 7 clear = do not flip vertically

 JSR WaitFor3xVBlank    ; Wait for three VBlanks to pass

 LDA #0                 ; Write 0 to OAM_ADDR so we can use OAM_DMA to send
 STA OAM_ADDR           ; sprite data to the PPU

 LDA #$02               ; Write $02 to OAM_DMA to upload 256 bytes of sprite
 STA OAM_DMA            ; data from the sprite buffer at $02xx into the PPU

 LDA #0                 ; Reset all the bitplanes to 0
 STA nmiBitplane
 STA drawingBitplane
 STA hiddenBitplane

 LDA #HI(PPU_PATT_1)    ; Set ppuPatternTableHi to the high byte of PPU pattern
 STA ppuPatternTableHi  ; table 1, which is the table we use for drawing dynamic
                        ; tiles

 LDA #0                 ; Set nmiBitplane8 to 8 * nmiBitplane, which is 0
 STA nmiBitplane8

 LDA #HI(PPU_NAME_0)    ; Set ppuNametableAddr(1 0) to the address of pattern
 STA ppuNametableAddr+1 ; table 0 in the PPU
 LDA #LO(PPU_NAME_0)
 STA ppuNametableAddr

 LDA #%00101000         ; Set both bitplane flags as follows:
 STA bitplaneFlags      ;
 STA bitplaneFlags+1    ;   * Bit 2 clear = send tiles up to configured numbers
                        ;   * Bit 3 set   = clear buffers after sending data
                        ;   * Bit 4 clear = we've not started sending data yet
                        ;   * Bit 5 set   = we have already sent all the data
                        ;   * Bit 6 clear = only send pattern data to the PPU
                        ;   * Bit 7 clear = do not send data to the PPU
                        ;
                        ; Bits 0 and 1 are ignored and are always clear
                        ;
                        ; The NMI handler will now start sending data to the PPU
                        ; according to the above configuration, splitting the
                        ; process across multiple VBlanks if necessary

 LDA #4                 ; Set the number of the first and last tiles to send
 STA clearingPattern    ; from the PPU to 4, which is the first tile after the
 STA clearingPattern+1  ; blank tile (tile 0) and the box edges (tiles 1 to 3),
 STA clearingNameTile   ; which are the only fixed tiles in both bitplanes
 STA clearingNameTile+1 ;
 STA sendingPattern     ; This ensures that both buffers are almost entirely
 STA sendingPattern+1   ; cleared out by the NMI, as we set bit 3 in the
 STA sendingNameTile    ; bitplane flags above
 STA sendingNameTile+1

 LDA #$0F               ; Set the hidden and visible colours to $0F, which is
 STA hiddenColour       ; the HSV value for black, and do the same for the
 STA visibleColour      ; colours to use for palette entries 2 and 3 in the
 STA paletteColour2     ; non-space views
 STA paletteColour3

 LDA #0                 ; Configure the NMI handler not to send palette data to
 STA updatePaletteInNMI ; the PPU

 STA QQ11a              ; Set the old view type in QQ11a to $00 (Space view with
                        ; no fonts loaded)

 LDA #$FF               ; Set bit 7 of screenFadedToBlack to indicate that we
 STA screenFadedToBlack ; have faded the screen to black

 JSR WaitFor3xVBlank    ; Wait for three VBlanks to pass

 LDA #%10010000         ; Set A to use as the new value for PPU_CTRL below

 STA ppuCtrlCopy        ; Store the new value of PPU_CTRL in ppuCtrlCopy so we
                        ; can check its value without having to access the PPU

 STA PPU_CTRL           ; Configure the PPU by setting PPU_CTRL as follows:
                        ;
                        ;   * Bits 0-1    = base nametable address %00 ($2000)
                        ;   * Bit 2 clear = increment PPU_ADDR by 1 each time
                        ;   * Bit 3 clear = sprite pattern table is at $0000
                        ;   * Bit 4 set   = background pattern table is at $1000
                        ;   * Bit 5 clear = sprites are 8x8 pixels
                        ;   * Bit 6 clear = use PPU 0 (the only option on a NES)
                        ;   * Bit 7 set   = enable VBlank NMI generation

 RTS                    ; Return from the subroutine

; ******************************************************************************
;
;       Name: SetIconBarRow
;       Type: Subroutine
;   Category: Icon bar
;    Summary: Set the row on which the icon bar appears, which depends on the
;             view type
;
; ------------------------------------------------------------------------------
;
; Other entry points:
;
;   RTS9                Contains an RTS
;
; ******************************************************************************

.SetIconBarRow

 LDA QQ11               ; If the view type in QQ11 is not $BA (Market Price),
 CMP #$BA               ; then jump to bpos2 to calculate the icon bar row
 BNE bpos2

 LDA iconBarType        ; If this is icon bar type 3 (Pause), jump to bpos1 to
 CMP #3                 ; hide the Inventory icon before calculating the icon
 BEQ bpos1              ; bar row

                        ; If we get here then this is the Market Price screen
                        ; and the game is not paused, so we are showing the
                        ; normal icon bar for this screen
                        ;
                        ; The Market Price screen uses the normal Docked or
                        ; Flight icon bar, but with the second icon overwritten
                        ; with the Inventory icon

 JSR DrawInventoryIcon  ; Draw the inventory icon on top of the second button
                        ; in the icon bar

 JMP bpos2              ; Jump to bpos2 to calculate the icon bar row

.bpos1

                        ; If we get here then this is the Market Price screen
                        ; and we are showing the pause options on the icon bar,
                        ; so we need to hide the Inventory icon from the second
                        ; button on the icon bar, so it doesn't overwrite the
                        ; pause options
                        ;
                        ; The Inventory button is in sprites 8 to 11, so we now
                        ; hide these sprites by moving them off-screen

 LDX #240               ; Hide sprites 8 to 11 by setting their y-coordinates to
 STX ySprite8           ; to 240, which is off the bottom of the screen
 STX ySprite9
 STX ySprite10
 STX ySprite11

.bpos2

 LDA #HI(20*32)         ; Set iconBarRow(1 0) = 20*32
 STA iconBarRow+1
 LDA #LO(20*32)
 STA iconBarRow

 LDA QQ11               ; If bit 7 of the view type in QQ11 is clear then there
 BPL RTS9               ; is a dashboard, so jump to RTS9 to keep this value of
                        ; iconBarRow and return from the subroutine

 LDA #HI(27*32)         ; Set iconBarRow(1 0) = 27*32
 STA iconBarRow+1       ;
 LDA #LO(27*32)         ; So the icon bar is on row 20 if bit 7 of the view
 STA iconBarRow         ; number is clear (so there is a dashboard), and it's on
                        ; row 27 is bit 7 is set (so there is no dashboard)

.RTS9

 RTS                    ; Return from the subroutine

; ******************************************************************************
;
;       Name: ShowIconBar
;       Type: Subroutine
;   Category: Icon bar
;    Summary: Show a specified icon bar on-screen
;  Deep dive: Views and view types in NES Elite
;
; ------------------------------------------------------------------------------
;
; Arguments:
;
;   A                   The type of icon bar to show:
;
;                         * 0 = Docked
;
;                         * 1 = Flight
;
;                         * 2 = Charts
;
;                         * 3 = Pause
;
;                         * 4 = Title screen copyright message
;
; ******************************************************************************

.ShowIconBar

 TAY                    ; Copy the icon bar type into Y

 LDA QQ11               ; If bit 6 of the view type is set, then there is no
 AND #%01000000         ; icon bar on the screen, so jump to RTS9 to return
 BNE RTS9               ; from the subroutine as there is nothing to show

 STY iconBarType        ; Set the type of the current icon bar in iconBarType to
                        ; to the new type in Y

 JSR BlankAllButtons    ; Blank all the buttons on the icon bar

 LDA #HI(20*32)         ; Set iconBarRow(1 0) = 20*32
 STA iconBarRow+1
 LDA #LO(20*32)
 STA iconBarRow

 LDA QQ11               ; If bit 7 of the view type in QQ11 is clear then there
 BPL obar1              ; is a dashboard, so jump to obar1 to keep this value of
                        ; iconBarRow

 LDA #HI(27*32)         ; Set iconBarRow(1 0) = 27*32
 STA iconBarRow+1       ;
 LDA #LO(27*32)         ; So the icon bar is on row 20 if bit 7 of the view
 STA iconBarRow         ; number is clear (so there is a dashboard), and it's on
                        ; row 27 is bit 7 is set (so there is no dashboard)

.obar1

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

.obar2

 SETUP_PPU_FOR_ICON_BAR ; If the PPU has started drawing the icon bar, configure
                        ; the PPU to use nametable 0 and pattern table 0

 LDA barPatternCounter  ; Loop back to keep the PPU configured in this way until
 BPL obar2              ; barPatternCounter is set to 128
                        ;
                        ; This happens when the NMI handler has finished sending
                        ; all the icon bar's nametable and pattern data to
                        ; the PPU, so this loop keeps the PPU configured to use
                        ; nametable 0 and pattern table 0 until the icon bar
                        ; nametable and pattern data have all been sent

                        ; Fall through into UpdateIconBar to update the icon bar

; ******************************************************************************
;
;       Name: UpdateIconBar
;       Type: Subroutine
;   Category: Icon bar
;    Summary: Update the icon bar
;  Deep dive: Views and view types in NES Elite
;
; ******************************************************************************

.UpdateIconBar

 LDA iconBarType        ; Set A to the current icon bar type

 JSR SetupIconBar       ; Set up the icon bar

 LDA QQ11               ; If bit 6 of the view type is set, then there is no
 AND #%01000000         ; icon bar on the screen, so jump to ubar2 to return
 BNE ubar2              ; from the subroutine as there is no icon bar to update

 JSR SetIconBarRow      ; Set the row on which the icon bar appears, which
                        ; depends on the view type

 LDA #%10000000         ; Set bit 7 of skipBarPatternsPPU, so the NMI handler
 STA skipBarPatternsPPU ; only sends the nametable entries and not the tile
                        ; patterns

 ASL A                  ; Set barPatternCounter = 0, so the NMI handler sends
 STA barPatternCounter  ; icon bar data to the PPU

.ubar1

 SETUP_PPU_FOR_ICON_BAR ; If the PPU has started drawing the icon bar, configure
                        ; the PPU to use nametable 0 and pattern table 0

 LDA barPatternCounter  ; Loop back to keep the PPU configured in this way until
 BPL ubar1              ; barPatternCounter is set to 128
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

.ubar2

 RTS                    ; Return from the subroutine

; ******************************************************************************
;
;       Name: SetupSprite0
;       Type: Subroutine
;   Category: PPU
;    Summary: Set the coordinates of sprite 0 so we can detect when the PPU
;             starts to draw the icon bar
;
; ******************************************************************************

.SetupSprite0

 SETUP_PPU_FOR_ICON_BAR ; If the PPU has started drawing the icon bar, configure
                        ; the PPU to use nametable 0 and pattern table 0

 LDA #248               ; Set the x-coordinate of sprite 0 to 248
 STA xSprite0

                        ; We now set X and Y depending on the type of view, as
                        ; follows:
                        ;
                        ;   * X is the pixel y-coordinate of sprite 0, which is
                        ;     positioned just above the icon bar
                        ;
                        ;   * Y is the row containing the top part of the icon
                        ;     bar pointer

 LDY #18                ; Set Y = 18

 LDX #157+YPAL          ; Set X = 157

 LDA QQ11               ; If bit 7 of the view type in QQ11 is clear then there
 BPL sets4              ; is a dashboard, so jump to sets4 with X = 157 and
                        ; Y = 18

 CMP #$C4               ; If the view type in QQ11 is not $C4 (Game Over screen)
 BNE sets1              ; then jump to sets1 to keep checking the view type

 LDX #240               ; This is the Game Over screen, so jump to sets 4 with
 BNE sets4              ; X = 240 and Y = 18 (this BNE is effectively a JMP as
                        ; X is never zero)

.sets1

 LDY #25                ; Set Y = 25

 LDX #213+YPAL          ; Set X = 213

 CMP #$B9               ; If the view type in QQ11 is not $B9 (Equip Ship) then
 BNE sets2              ; jump to sets2 to keep checking the view type

 LDX #150+YPAL          ; This is the Equip Ship screen, so set X = 150

 LDA #248               ; Set the x-coordinate of sprite 0 to 248 (though we
 STA xSprite0           ; already did this above, so perhaps this is left over
                        ; code from development)

.sets2

 LDA QQ11               ; If the view type in QQ11 is not $xF (the Start screen
 AND #$0F               ; in any of its font configurations), jump to sets3 to
 CMP #$0F               ; keep checking the view type
 BNE sets3

 LDX #166+YPAL          ; This is the Start screen, so set X = 166

.sets3

 CMP #$0D               ; If the view type in QQ11 is not $xD (the Long-range or
 BNE sets4              ; Short-range Chart), jump to sets4 to use the current
                        ; values of X and Y

 LDX #173+YPAL          ; This is a chart screen, so set X = 173

 LDA #248               ; Set the x-coordinate of sprite 0 to 248 (though we
 STA xSprite0           ; already did this above, so perhaps this is left over
                        ; code from development)

.sets4

                        ; We get here with X and Y set as follows:
                        ;
                        ;   * X = 157, Y = 18 if there is a dashboard
                        ;   * X = 240, Y = 18 if this is the Game Over screen
                        ;   * X = 150, Y = 25 if this is the Equip Ship screen
                        ;   * X = 166, Y = 25 if this is the Start screen
                        ;   * X = 173, Y = 25 if this is a chart screen
                        ;   * X = 213, Y = 25 otherwise
                        ;
                        ; In all cases the x-coordinate of sprite 0 is 248

 STX ySprite0           ; Set the y-coordinate of sprite 0 to X
                        ;
                        ; This means that sprite 0 is at these coordinates:
                        ;
                        ;   * (248, 157) if there is a dashboard
                        ;   * (248, 240) if this is the Game Over screen
                        ;   * (248, 150) if this is the Equip Ship screen
                        ;   * (248, 166) if this is the Start screen
                        ;   * (248, 173) if this is a chart screen
                        ;   * (248, 213) otherwise

 TYA                    ; Set the y-coordinate of the icon bar pointer in
 SEC                    ; yIconBarPointer to Y * 8 + %100, which is either
 ROL A                  ; 148 or 204 (when Y is 18 or 25)
 ASL A                  ;
 ASL A                  ; This means the icon bar pointer is at y-coordinate
 STA yIconBarPointer    ; 148 when there is a dashboard or this is the Game Over
                        ; screen, and it's at y-coordinate 204 otherwise

 LDA iconBarType        ; Set iconBarImageHi to the high byte of the correct
 ASL A                  ; icon bar image block for the current icon bar type,
 ASL A                  ; which we can calculate like this:
 ADC #HI(iconBarImage0) ;
 STA iconBarImageHi     ;   HI(iconBarImage0) + 4 * iconBarType
                        ;
                        ; as each icon bar image block contains $0400 bytes,
                        ; and iconBarType is the icon bar type, 0 to 4

 LDA QQ11               ; If bit 6 of the view type is set, then there is no
 AND #%01000000         ; icon bar, so jump to sets5 to skip the following
 BNE sets5              ; instruction

 LDX #0                 ; If we get here then there is an icon bar, so set
 STX barPatternCounter  ; barPatternCounter = 0 so the NMI handler sends the
                        ; icon bar's nametable and pattern data to the PPU

.sets5

 RTS                    ; Return from the subroutine

; ******************************************************************************
;
;       Name: BlankAllButtons
;       Type: Subroutine
;   Category: Icon bar
;    Summary: Blank all the buttons on the icon bar
;
; ******************************************************************************

.BlankAllButtons

 JSR DrawIconBar        ; Draw the icon bar into the nametable buffers for both
                        ; bitplanes
                        ;
                        ; This also sets the following variables, which we pass
                        ; to the following routines:
                        ;
                        ;   * SC(1 0) is the address of the nametable entries
                        ;     for the on-screen icon bar in nametable buffer 0
                        ;
                        ;   * SC2(1 0) is the address of the nametable entries
                        ;     for the on-screen icon bar in nametable buffer 1

 LDY #2                 ; Blank the first button on the icon bar
 JSR DrawBlankButton2x2

 LDY #4                 ; Blank the second button on the icon bar
 JSR DrawBlankButton3x2

 LDY #7                 ; Blank the third button on the icon bar
 JSR DrawBlankButton2x2

 LDY #9                 ; Blank the fourth button on the icon bar
 JSR DrawBlankButton3x2

 LDY #12                ; Blank the fifth button on the icon bar
 JSR DrawBlankButton2x2

 LDY #29                ; Blank the twelfth button on the icon bar
 JSR DrawBlankButton3x2

; ******************************************************************************
;
;       Name: BlankButtons6To11
;       Type: Subroutine
;   Category: Icon bar
;    Summary: Blank from the sixth to the eleventh button on the icon bar
;
; ******************************************************************************

.BlankButtons6To11

 LDY #14                ; Blank the sixth button on the icon bar
 JSR DrawBlankButton3x2

 LDY #17                ; Blank the seventh button on the icon bar
 JSR DrawBlankButton2x2

; ******************************************************************************
;
;       Name: BlankButtons8To11
;       Type: Subroutine
;   Category: Icon bar
;    Summary: Blank from the eighth to the eleventh button on the icon bar
;
; ******************************************************************************

.BlankButtons8To11

 LDY #19                ; Blank the eighth button on the icon bar
 JSR DrawBlankButton3x2

 LDY #22                ; Blank the ninth button on the icon bar
 JSR DrawBlankButton2x2

 LDY #24                ; Blank the tenth button on the icon bar
 JSR DrawBlankButton3x2

 LDY #27                ; Blank the eleventh button on the icon bar and return
 JMP DrawBlankButton2x2 ; from the subroutine using a tail call

; ******************************************************************************
;
;       Name: DrawIconBar
;       Type: Subroutine
;   Category: Icon bar
;    Summary: Draw the icon bar into the nametable buffers for both bitplanes
;
; ------------------------------------------------------------------------------
;
; Returns:
;
;   SC(1 0)             The address of the nametable entries for the on-screen
;                       icon bar in nametable buffer 0
;
;   SC2(1 0)            The address of the nametable entries for the on-screen
;                       icon bar in nametable buffer 1
;
; ******************************************************************************

.DrawIconBar

                        ; We start by setting V(1 0) to the address of the
                        ; barNames table that corresponds to the current icon
                        ; bar type (i.e. barNames0 to barNames4)
                        ;
                        ; This contains the nametable entries we need to put in
                        ; the nametable buffer to show this icon bar type on
                        ; the screen

 LDA iconBarType        ; Set (C Y) = iconBarType << 6
 ASL A                  ;           = iconBarType * 64
 ASL A
 ASL A
 ASL A
 ASL A
 ASL A
 TAY

 BNE dbar1              ; If Y is non-zero (i.e. iconBarType = 1 to 3), jump to
                        ; dbar1 to set A = HI(barNames0)

 LDA #HI(barNames0)-1   ; Otherwise Y is zero (i.e. iconBarType = 0 or 4) so set
 BNE dbar2              ; A = HI(barNames0) - 1 and jump to dbar2 to skip the
                        ; following (this BNE is effectively a JMP as A is never
                        ; zero)

.dbar1

 LDA #HI(barNames0)     ; Set A = HI(barNames0) for when iconBarType = 1 to 3

.dbar2

                        ; When we get here, we have A set as follows:
                        ;
                        ;   * HI(barNames0) - 1        when iconBarType = 0 or 4
                        ;
                        ;   * HI(barNames0)            when iconBarType = 1 to 3

 DEY                    ; Decrement Y, so Y is now:
                        ;
                        ;   * $FF                     when iconBarType = 0 or 4
                        ;
                        ;   * iconBarType * 64 - 1    when iconBarType = 1 to 3

 STY V                  ; Set V(1 0) = (A 0) + (C 0) + Y
 ADC #0                 ;
 STA V+1                ; So this sets V(1 0) to the following:
                        ;
                        ;   * When iconBarType = 0:
                        ;
                        ;       (HI(barNames0)-1 0) + (0 0) + $FF
                        ;       (HI(barNames0)-1 0) + $FF
                        ;     = (HI(barNames0)-1 0) + (1 0) - 1
                        ;     = (HI(barNames0) 0) - 1
                        ;     = (HI(barNames0) 0) + iconBarType * 64 - 1
                        ;
                        ;   * When iconBarType = 1 to 3
                        ;
                        ;       (HI(barNames0) 0) + (0 0) + iconBarType * 64 - 1
                        ;     = (HI(barNames0) 0) + iconBarType * 64 - 1
                        ;
                        ;   * When iconBarType = 4
                        ;
                        ;       (HI(barNames0-1 0) + (1 0) + $FF
                        ;     = (HI(barNames0-1 0) + (1 0) + (1 0) - 1
                        ;     = (HI(barNames0) 0) + (1 0) - 1
                        ;     = (HI(barNames0) 0) + 4 * 64 - 1
                        ;     = (HI(barNames0) 0) + iconBarType * 64 - 1
                        ;
                        ; In other words, V(1 0) is as follows, for all the icon
                        ; bar types:
                        ;
                        ;   V(1 0) = (HI(barNames0) 0) + iconBarType * 64 - 1
                        ;
                        ; and because barNames0 is on a page boundary, we know
                        ; that LO(barNames0) = 0, so:
                        ;
                        ;   (HI(barNames0) 0) = (HI(barNames0) LO(barNames0))
                        ;                     = barNames0(1 0)
                        ;
                        ; So we have:
                        ;
                        ;   V(1 0) = barNames0(1 0) + iconBarType * 64 - 1
                        ;
                        ; barNames0 through barNames4 each contain 64 bytes, for
                        ; the two rows of 32 tiles that make up the icon bar,
                        ; and they are one after the other in memory, so V(1 0)
                        ; therefore contains the address of the relevant table
                        ; for the current icon bar's nametable entries (i.e.
                        ; barNames0 to barNames4), minus 1
                        ;
                        ; Let's refer to the relevant table from barNames0 to
                        ; barNames4 as barNames, to make things simpler, so we
                        ; have the following:
                        ;
                        ;   V(1 0) = barNames - 1

                        ; Next, we set SC(1 0) and SC2(1 0) to the addresses in
                        ; the two nametable buffers for the icon bar, so we can
                        ; write the nametable entries there to draw the icon bar
                        ; on-screen

 LDA QQ11               ; If bit 7 of the view type in QQ11 is set then there
 BMI dbar3              ; is no dashboard and the icon bar is at the bottom of
                        ; the screen, so jump to dbar3 to set SC(1 0) and
                        ; SC2(1 0) accordingly

 LDA #HI(nameBuffer0+20*32) ; Set SC(1 0) to the address of the first tile on
 STA SC+1                   ; tile row 20 in nametable buffer 0
 LDA #LO(nameBuffer0+20*32)
 STA SC

 LDA #HI(nameBuffer1+20*32) ; Set SC2(1 0) to the address of the first tile on
 STA SC2+1                  ; tile row 20 in nametable buffer 1
 LDA #LO(nameBuffer1+20*32)
 STA SC2

 JMP dbar4              ; Jump to dbar4 to skip the following

.dbar3

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

.dbar4

                        ; By this point, we have the following:
                        ;
                        ;   * V(1 0) is the address of the icon bar's nametable
                        ;     table (from barNames0 to barNames4), minus 1,
                        ;     i.e. V(1 0) = barNames - 1
                        ;
                        ;   * SC(1 0) is the address of the nametable entries
                        ;     for the on-screen icon bar in nametable buffer 0
                        ;
                        ;   * SC2(1 0) is the address of the nametable entries
                        ;     for the on-screen icon bar in nametable buffer 1
                        ;
                        ; So to draw the icon bar on-screen, we need to copy the
                        ; nametable entries from V(1 0) to both SC(1 0) and
                        ; SC2(1 0)

 LDY #63                ; Set Y as an index, which will count down from 63 to 1,
                        ; so we copy bytes 0 to 62 in V(1 0) to bytes 1 to 63
                        ; in the nametable buffers
                        ;
                        ; We do this in two stages purely so we can clip in a
                        ; call to the SETUP_PPU_FOR_ICON_BAR macro

.dbar5

 LDA (V),Y              ; Copy the Y-th nametable entry from V(1 0) to SC(1 0)
 STA (SC),Y

 STA (SC2),Y            ; Copy the Y-th nametable entry from V(1 0) to SC2(1 0)

 DEY                    ; Decrement the index counter

 CPY #33                ; Loop back until we have done Y = 63 to 34
 BNE dbar5

 SETUP_PPU_FOR_ICON_BAR ; If the PPU has started drawing the icon bar, configure
                        ; the PPU to use nametable 0 and pattern table 0

.dbar6

 LDA (V),Y              ; Copy the Y-th nametable entry from V(1 0) to SC(1 0)
 STA (SC),Y

 STA (SC2),Y            ; Copy the Y-th nametable entry from V(1 0) to SC2(1 0)

 DEY                    ; Decrement the index counter

 BNE dbar6              ; Loop back until we have done Y = 33 to 1

 SETUP_PPU_FOR_ICON_BAR ; If the PPU has started drawing the icon bar, configure
                        ; the PPU to use nametable 0 and pattern table 0

                        ; By this point we have copied bytes 0 to 62 in V(1 0)
                        ; to bytes 1 to 63 in the nametable buffers, and because
                        ; V(1 0) = barNames - 1, this means we have copied
                        ; bytes 1 to 63 from the relevant barNames table to the
                        ; nametable buffers
                        ;
                        ; This covers almost all of the two rows of 3 characters
                        ; that make up the icon bar, but it is one short, as we
                        ; aren't done yet
                        ;
                        ; Because the horizontal scroll in PPU_SCROLL is set to
                        ; 8, the leftmost tile on each row is scrolled around to
                        ; the right side, which means that in terms of tiles,
                        ; column 1 is the left edge of the screen, then columns
                        ; 2 to 31 form the body of the screen, and column 0 is
                        ; the right edge of the screen
                        ;
                        ; We therefore have to fix the tiles that appear at the
                        ; end of each row, i.e. column 0 on row 0 (for the end
                        ; of the top row of the icon bar) and column 0 on row 1
                        ; (for the end of the bottom row of the icon bar)

 LDY #32                ; Copy byte 32 from V(1 0), i.e. byte 31 of barNames,
 LDA (V),Y              ; to byte 0 of SC(1 0) and SC2(1 0), which moves the
 LDY #0                 ; tile at the end of the first row of the icon bar into
 STA (SC),Y             ; column 0 on row 0 (for the end of the top row of the
 STA (SC2),Y            ; icon bar on-screen)

 LDY #64                ; Copy byte 64 from V(1 0), i.e. byte 63 of barNames,
 LDA (V),Y              ; to byte 32 of SC(1 0) and SC2(1 0), which moves the
 LDY #32                ; tile at the end of the second row of the icon bar into
 STA (SC),Y             ; column 0 on row 1 (for the end of the bottom row of
 STA (SC2),Y            ; the icon bar on-screen)

 RTS                    ; Return from the subroutine

; ******************************************************************************
;
;       Name: HideIconBar
;       Type: Subroutine
;   Category: Icon bar
;    Summary: Remove the icon bar from the screen by replacing it with
;             background tiles
;
; ******************************************************************************

.HideIconBar

 LDA #HI(nameBuffer0+27*32) ; Set SC(1 0) to the address of the first tile on
 STA SC+1                   ; tile row 27 in nametable buffer 0
 LDA #LO(nameBuffer0+27*32)
 STA SC

 LDA #HI(nameBuffer1+27*32) ; Set SC2(1 0) to the address of the first tile on
 STA SC2+1                  ; tile row 27 in nametable buffer 1
 LDA #LO(nameBuffer1+27*32)
 STA SC2

 LDY #63                ; Set Y as an index, which will count down from 63 to 1,
                        ; so we blank tile 1 to 63 of the icon bar in the
                        ; following loop

 LDA #0                 ; Set A = 0 to store in the nametable buffers, as tile 0
                        ; is the empty background tile

.hbar1

 STA (SC),Y             ; Set the Y-th nametable entry for the icon bar to the
 STA (SC2),Y            ; empty tile in A

 DEY                    ; Decrement the index counter

 BNE hbar1              ; Loop back until we have replaced all 63 tiles with the
                        ; background tile

 LDA #32                ; Set A = 32 as the pattern number to show at the start
                        ; of row 27 (though I don't know why we do this, as
                        ; pattern 32 is part of the icon bar pattern, so this
                        ; seems a bit strange)

 LDY #0                 ; Set the first nametable entry on tile row 27 to A
 STA (SC),Y
 STA (SC2),Y

 RTS                    ; Return from the subroutine

; ******************************************************************************
;
;       Name: SetupIconBarPause
;       Type: Subroutine
;   Category: Icon bar
;    Summary: Set up the game options shown on the icon bar when the game is
;             paused
;
; ******************************************************************************

.SetupIconBarPause

                        ; By default the icon bar shows all possible icons, so
                        ; now we work our way through the buttons, hiding any
                        ; icons that do not apply

 LDA JSTGY              ; If JSTGY is 0 then the game is not configured to
 BEQ pbar1              ; reverse the controller y-axis, so jump to pbar1 to
                        ; skip the following and leave the default icon showing

 LDY #2                 ; Draw four tiles over the top of the first button to
 JSR Draw4OptionTiles   ; show that the controller y-axis is reversed

.pbar1

 LDA DAMP               ; If DAMP is 0 then controller damping is disabled, so
 BEQ pbar2              ; jump to pbar2 to skip the following and leave the
                        ; default icon showing

 LDY #4                 ; Draw six tiles over the top of the second button to
 JSR Draw6OptionTiles   ; shot that controller damping is enabled

.pbar2

 LDA disableMusic       ; If bit 7 of disableMusic is clear then music is
 BPL pbar3              ; enabled, so jump to pbar3 to skip the following and
                        ; leave the default icon showing

 LDY #7                 ; Draw four tiles over the top of the third button to
 JSR Draw4OptionTiles   ; show that music is disabled

.pbar3

 LDA DNOIZ              ; If bit 7 of DNOIZ is set then sound is on, so jump to
 BMI pbar4              ; pbar4 to skip the following and leave the default icon
                        ; showing

 LDY #9                 ; Draw six tiles over the top of the fourth button to
 JSR Draw6OptionTiles   ; shot that sound is disabled

.pbar4

 LDA numberOfPilots     ; If the game is configured for two pilots, jump to
 BNE pbar5              ; pbar5 to skip the following and leave the default icon
                        ; showing

 LDY #12                ; Draw four tiles over the top of the fifth button to
 JSR Draw4OptionTiles   ; show that one pilot is configured

.pbar5

 JSR BlankButtons6To11  ; Blank from the sixth to the eleventh button on the
                        ; icon bar

                        ; Fall through into SetIconBarButtonsS to jump to
                        ; SetIconBarButtons to set the correct list of button
                        ; numbers for the icon bar

; ******************************************************************************
;
;       Name: SetIconBarButtonsS
;       Type: Subroutine
;   Category: Icon bar
;    Summary: Set the correct list of button numbers for the icon bar (this is a
;             jump so we can call this routine using a branch instruction)
;
; ******************************************************************************

.SetIconBarButtonsS

 JMP SetIconBarButtons  ; Jump to SetIconBarButtons to set the barButtons
                        ; variable to point to the correct list of button
                        ; numbers for the icon bar we are setting up, returning
                        ; from the subroutine using a tail call

; ******************************************************************************
;
;       Name: SetupIconBar
;       Type: Subroutine
;   Category: Icon bar
;    Summary: Set up the icons on the icon bar to show all available options
;
; ------------------------------------------------------------------------------
;
; Arguments:
;
;   A                   The type of the icon bar to set up:
;
;                         * 0 = Docked
;
;                         * 1 = Flight
;
;                         * 2 = Charts
;
;                         * 3 = Pause
;
;                         * 4 = Title screen copyright message
;
;                         * $FF = Hide the icon bar on row 27
;
; ******************************************************************************

.SetupIconBar

 TAY                    ; Copy the icon bar type into Y

 BMI HideIconBar        ; If the icon bar type has bit 7 set, then this must be
                        ; type $FF, so jump to HideIconBar to hide the icon bar
                        ; on row 27, returning from the subroutine using a tail
                        ; call

 STA iconBarType        ; Set the type of the current icon bar in iconBarType to
                        ; to the new type in A

 SETUP_PPU_FOR_ICON_BAR ; If the PPU has started drawing the icon bar, configure
                        ; the PPU to use nametable 0 and pattern table 0

 JSR DrawIconBar        ; Draw the icon bar into the nametable buffers for both
                        ; bitplanes

 LDA iconBarType        ; If iconBarType = 0 then jump to SetupIconBarDocked to
 BEQ SetupIconBarDocked ; set up the Docked icon bar, returning from the
                        ; subroutine using a tail call

 CMP #1                 ; If iconBarType = 1 then jump to SetupIconBarFlight to
 BEQ SetupIconBarFlight ; set up the Flight icon bar, returning from the
                        ; subroutine using a tail call

 CMP #3                 ; If iconBarType = 3 then jump to SetupIconBarPause to
 BEQ SetupIconBarPause  ; set up the Pause icon bar, returning from the
                        ; subroutine using a tail call

 CMP #2                 ; If iconBarType <> 2 then it must be 4, so this is the
 BNE SetIconBarButtonsS ; title screen and we need to show the title screen
                        ; copyright message in place of the icon bar, so jump to
                        ; SetIconBarButtons via SetIconBarButtonsS to skip
                        ; setting up any bespoke buttons and simply display the
                        ; copyright message patterns as they are, returning from
                        ; the subroutine using a tail call

 JMP SetupIconBarCharts ; Otherwise iconBarType must be 2, so jump to
                        ; SetupIconBarCharts to set up the Charts icon bar,
                        ; returning from the subroutine using a tail call

; ******************************************************************************
;
;       Name: SetupIconBarFlight
;       Type: Subroutine
;   Category: Icon bar
;    Summary: Set up the Flight icon bar
;
; ------------------------------------------------------------------------------
;
; Other entry points:
;
;   fbar8                Process the escape pod, fast-forward and Market Price
;                        buttons
;
;   fbar11               Process the fast-forward and Market Price buttons
;
; ******************************************************************************

.SetupIconBarFlight

                        ; By default the icon bar shows all possible icons, so
                        ; now we work our way through the buttons, hiding any
                        ; icons that do not apply

 LDA SSPR               ; If we are inside the space station safe zone then SSPR
 BNE fbar1              ; is non-zero, so jump to fbar1 to leave the first
                        ; button showing the docking computer icon

 LDY #2                 ; Otherwise blank the first button on the icon bar to
 JSR DrawBlankButton2x2 ; hide the docking computer icon as we can't activate
                        ; the docking computer outside of the safe zone

.fbar1

 LDA ECM                ; If we have an E.C.M. fitted, jump to fbar2 to leave
 BNE fbar2              ; the seventh button showing the E.C.M. icon

 LDY #17                ; Otherwise blank the seventh button on the icon bar to
 JSR DrawBlankButton2x2 ; hide the E.C.M. icon we don't have an E.C.M. fitted

.fbar2

 LDA QQ22+1             ; Fetch QQ22+1, which contains the number that's shown
                        ; on-screen during hyperspace countdown

 BNE fbar3              ; If it is non-zero then there is a hyperspace countdown
                        ; in progress, so jump to fbar3 to blank the sixth
                        ; button on the icon bar, as otherwise it would show the
                        ; hyperspace icon (which we can't choose as we are
                        ; already counting down)

 LDA selectedSystemFlag ; If bit 6 of selectedSystemFlag is set, then we can
 ASL A                  ; hyperspace to the currently selected system, so jump
 BMI fbar4              ; to fbar4 to leave the sixth button showing the
                        ; hyperspace icon

.fbar3

 LDY #14                ; If we get here then there is either a hyperspace
 JSR DrawBlankButton3x2 ; countdown already in progress, or we can't hyperspace
                        ; to the selected system, so blank the sixth button on
                        ; the icon bar to hide the hyperspace icon

.fbar4

 LDA QQ11               ; If this is the space view, jump to fbar5 to process
 BEQ fbar5              ; the weapon buttons

 JSR BlankButtons8To11  ; Otherwise this is not a space view and we don't want
                        ; to show the weapon buttons, so blank from the eighth
                        ; to the eleventh button on the icon bar

 JMP fbar10             ; Jump to fbar10 to process the eleventh button on the
                        ; icon bar

.fbar5

 LDA NOMSL              ; If we have at least one missile fitted then NOMSL will
 BNE fbar6              ; be non-zero, so jump to fbar6 to leave the eighth
                        ; button showing the target missile icon

 LDY #19                ; Otherwise we have no missiles fitted so blank the
 JSR DrawBlankButton3x2 ; eighth button on the icon bar to hide the target
                        ; missile icon

.fbar6

 LDA MSTG               ; If MSTG is positive (i.e. it does not have bit 7 set),
 BPL fbar7              ; then it indicates we already have a missile locked on
                        ; a target (in which case MSTG contains the ship number
                        ; of the target), so jump to fbar7 to leave the ninth
                        ; button showing the fire missile icon

 LDY #22                ; Otherwise the missile is not targeted, so blank the
 JSR DrawBlankButton2x2 ; ninth button on the icon bar to hide the fire missile
                        ; icon

.fbar7

 LDA BOMB               ; If we do have an energy bomb fitted, jump to fbar8 to
 BNE fbar8              ; leave the tenth button showing the energy bomb icon

 LDY #24                ; Otherwise we do not have an energy bomb fitted, so
 JSR DrawBlankButton3x2 ; blank the tenth button on the icon bar to hide the
                        ; energy bomb icon

.fbar8

 LDA MJ                 ; If we are in witchspace (i.e. MJ is non-zero), jump to
 BNE fbar9              ; fbar9 to hide the escape pod icon, as we can't use the
                        ; escape pod in witchspace

 LDA ESCP               ; If we have an escape pod fitted, jump to fbar10 to
 BNE fbar10             ; leave the eleventh button showing the escape pod icon

.fbar9

 LDY #27                ; If we get here then we are either in space or don't
 JSR DrawBlankButton2x2 ; have an escape pod fitted, so blank the eleventh
                        ; button on the icon bar to hide the escape pod icon

.fbar10

 LDA allowInSystemJump  ; If bits 6 and 7 of allowInSystemJump are clear then we
 AND #%11000000         ; are allowed to do an in-system jump, so jump to dock2
 BEQ dock2              ; in SetupIconBarDocked to leave the twelfth button
                        ; showing the fast-forward icon and move on to
                        ; processing the second button on the icon bar

.fbar11

 LDY #29                ; Otherwise we can't do an in-system jump, so blank the
 JSR DrawBlankButton3x2 ; twelfth button on the icon bar to hide the
                        ; fast-forward icon

 JMP dock2              ; Jump to dock2 in SetupIconBarDocked to move on to
                        ; processing the second button on the icon bar

; ******************************************************************************
;
;       Name: SetupIconBarDocked
;       Type: Subroutine
;   Category: Icon bar
;    Summary: Set up the Docked icon bar
;
; ------------------------------------------------------------------------------
;
; Other entry points:
;
;   dock2                Process the second button on the Docked or Flight icon
;                        bars
;
; ******************************************************************************

.SetupIconBarDocked

                        ; By default the icon bar shows all possible icons, so
                        ; now we work our way through the buttons, hiding any
                        ; icons that do not apply

 LDA COK                ; If COK is non-zero then cheat mode has been applied,
 BNE dock1              ; so jump to dock1 to hide the button to change the
                        ; commander name (as cheats can't change their commander
                        ; name away from "CHEATER")

 LDA QQ11               ; If the view type in QQ11 is $BB (Save and load with
 CMP #$BB               ; the normal and highlight fonts loaded), jump to ifon1
 BEQ dock2              ; to leave the seventh button showing the icon to change
                        ; the commander name

.dock1

 LDY #17                ; If we get here then either cheat mode has been applied
 JSR DrawBlankButton2x2 ; or this is not the save screen, so blank the seventh
                        ; button on the icon bar to hide the change commander
                        ; name icon

.dock2

 LDA QQ11               ; If the view type in QQ11 is not $BA (Market Price),
 CMP #$BA               ; then jump to SetIconBarButtons to skip the following
 BNE SetIconBarButtons  ; two instructions

 LDY #4                 ; This is the Market Price screen, so blank the second
 JSR DrawBlankButton3x2 ; button on the icon bar (though as we are going to draw
                        ; the Inventory button over the top, this isn't strictly
                        ; necessary)

                        ; Fall through into SetIconBarButtons to set the correct
                        ; list of button numbers for the icon bar

; ******************************************************************************
;
;       Name: SetIconBarButtons
;       Type: Subroutine
;   Category: Icon bar
;    Summary: Set the correct list of button numbers for the icon bar
;
; ******************************************************************************

.SetIconBarButtons

 SETUP_PPU_FOR_ICON_BAR ; If the PPU has started drawing the icon bar, configure
                        ; the PPU to use nametable 0 and pattern table 0

 LDA iconBarType        ; Set barButtons(1 0) = iconBarButtons
 ASL A                  ;                       + iconBarType * 16
 ASL A                  ;
 ASL A                  ; So barButtons(1 0) points to list of button numbers in
 ASL A                  ; the iconBarButtons table for this icon bar type
 ADC #LO(iconBarButtons)
 STA barButtons
 LDA #HI(iconBarButtons)
 ADC #0
 STA barButtons+1

 RTS                    ; Return from the subroutine

; ******************************************************************************
;
;       Name: SetupIconBarCharts
;       Type: Subroutine
;   Category: Icon bar
;    Summary: Set up the Charts icon bar
;
; ******************************************************************************

.SetupIconBarCharts

                        ; By default the icon bar shows all possible icons, so
                        ; now we work our way through the buttons, hiding any
                        ; icons that do not apply

 LDX #4                 ; Set X = 4 (though this appears to be unused)

 LDA QQ12               ; If we are in space (QQ12 = 0) then jump to char1 to
 BEQ char1              ; leave the fifth button showing the laser view icon
                        ; and process the rest of the icon bar

                        ; If we get here then we setting up the Charts icon bar
                        ; when are docked

 LDY #12                ; Blank the fifth button on the icon bar to hide the
 JSR DrawBlankButton2x2 ; laser view button, as this doesn't apply when we are
                        ; docked

 JSR BlankButtons8To11  ; Blank from the eighth to the eleventh button on the
                        ; icon bar as none of these icons apply when we are
                        ; docked

 JMP fbar11             ; Jump to fbar11 in SetupIconBarFlight to process the
                        ; fast-forward and Market Price buttons, returning from
                        ; the subroutine using a tail call

.char1

                        ; If we get here then we setting up the Charts icon bar
                        ; when we are in space

 LDY #2                 ; Blank the first button on the icon bar to hide the
 JSR DrawBlankButton2x2 ; docking computer icon so we can't activate it while
                        ; looking at the charts while in space

 LDA QQ22+1             ; Fetch QQ22+1, which contains the number that's shown
                        ; on-screen during hyperspace countdown

 BEQ char2              ; If the counter is zero then there is no countdown in
                        ; progress, so jump to char2 to leave the "Return
                        ; pointer to current system" and "Search for system"
                        ; icons visible

 LDY #14                ; Blank the sixth button on the icon bar to hide the
 JSR DrawBlankButton3x2 ; "Return pointer to current system" icon, as this
                        ; can't be done during a hyperspace countdown

 LDY #17                ; Blank the seventh button on the icon bar to hide the
 JSR DrawBlankButton2x2 ; "Search for system" icon, as this can't be done during
                        ; a hyperspace countdown

 JMP char3              ; Jump to char3 to move on to the eighth button on the
                        ; icon bar

.char2

                        ; If we get here then there is no hyperspace countdown

 LDA selectedSystemFlag ; If bit 6 of selectedSystemFlag is set, then we can
 ASL A                  ; hyperspace to the currently selected system, so jump
 BMI char4              ; to char4 to leave the eighth button showing the
                        ; hyperspace icon

.char3

 LDY #19                ; Blank the eighth button on the icon bar to hide the
 JSR DrawBlankButton3x2 ; hyperspace icon, as we can't hyperspace to the
                        ; currently selected system

.char4

 LDA GHYP               ; If we have a galactic hyperdrive fitted, jump to char5
 BNE char5              ; to leave the ninth button showing the galactic
                        ; hyperspace icon

 LDY #22                ; Blank the ninth button on the icon bar to hide the
 JSR DrawBlankButton2x2 ; galactic hyperspace icon, as we don't have a galactic
                        ; hyperdrive fitted

.char5

 LDA ECM                ; If we have an E.C.M. fitted, jump to char6 to leave
 BNE char6              ; the seventh tenth showing the E.C.M. icon

 LDY #24                ; Otherwise blank the tenth button on the icon bar to
 JSR DrawBlankButton3x2 ; hide the E.C.M. icon we don't have an E.C.M. fitted

.char6

 JMP fbar8              ; Jump to fbar8 in SetupIconBarFlight to process the
                        ; escape pod, fast-forward and Market Price buttons,
                        ; returning from the subroutine using a tail call

; ******************************************************************************
;
;       Name: DrawBlankButton2x2
;       Type: Subroutine
;   Category: Icon bar
;    Summary: Draw a blank icon bar button as a 2x2 tile block
;
; ------------------------------------------------------------------------------
;
; Arguments:
;
;   Y                   The number of the top-left tile of the icon bar button
;                       we want to draw, given as a nametable offset from the
;                       first tile in the icon bar (i.e. the tile in the
;                       top-left corner of the icon bar)
;
;   SC(1 0)             The address of the nametable entries for the on-screen
;                       icon bar in nametable buffer 0
;
;   SC2(1 0)            The address of the nametable entries for the on-screen
;                       icon bar in nametable buffer 1
;
; ******************************************************************************

.DrawBlankButton2x2

 SETUP_PPU_FOR_ICON_BAR ; If the PPU has started drawing the icon bar, configure
                        ; the PPU to use nametable 0 and pattern table 0

 LDA #4                 ; Set A = 4, which is the number of the top-left pattern
                        ; for a blank 2x2 icon bar button

 STA (SC),Y             ; Set the top-left corner of the 2x2 tile block we want
 STA (SC2),Y            ; to draw to the pattern in A, in both nametable buffers

 INY                    ; Increment Y to move right by one tile

 LDA #5                 ; Set A = 5, which is the number of the top-right
                        ; pattern for a blank 2x2 icon bar button

 STA (SC),Y             ; Set the top-right corner of the 2x2 tile block we want
 STA (SC2),Y            ; to draw to the pattern in A, in both nametable buffers

 TYA                    ; Set Y = Y + 31
 CLC                    ;
 ADC #31                ; So Y now points to the bottom-left tile of the 2x2
 TAY                    ; tile block that we want to draw buffers (as there are
                        ; 32 tiles in a row and we already moved right by one)

 LDA #36                ; Set A = 36, which is the number of the bottom-left
                        ; pattern for a blank 2x2 icon bar button

 STA (SC),Y             ; Set the bottom-left corner of the 2x2 tile block we
 STA (SC2),Y            ; want to draw to the pattern in A, in both nametable
                        ; buffers

 INY                    ; Increment Y to move right by one tile

 LDA #37                ; Set A = 37, which is the number of the bottom-right
                        ; pattern for a blank 2x2 icon bar button

 STA (SC),Y             ; Set the bottom-right corner of the 2x2 tile block we
 STA (SC2),Y            ; want to draw to the pattern in A, in both nametable
                        ; buffers

 RTS                    ; Return from the subroutine

; ******************************************************************************
;
;       Name: DrawBlankButton3x2
;       Type: Subroutine
;   Category: Icon bar
;    Summary: Draw a blank icon bar button as a 3x2 tile block
;
; ------------------------------------------------------------------------------
;
; Arguments:
;
;   Y                   The number of the top-left tile of the icon bar button
;                       we want to draw, given as a nametable offset from the
;                       first tile in the icon bar (i.e. the tile in the
;                       top-left corner of the icon bar)
;
;   SC(1 0)             The address of the nametable entries for the on-screen
;                       icon bar in nametable buffer 0
;
;   SC2(1 0)            The address of the nametable entries for the on-screen
;                       icon bar in nametable buffer 1
;
; ******************************************************************************

.DrawBlankButton3x2

 SETUP_PPU_FOR_ICON_BAR ; If the PPU has started drawing the icon bar, configure
                        ; the PPU to use nametable 0 and pattern table 0

 LDA #6                 ; Set A = 6, which is the number of the top-left pattern
                        ; for a blank 3x2 icon bar button

 STA (SC),Y             ; Set the top-left corner of the 3x2 tile block we
 STA (SC2),Y            ; want to draw to the pattern in A, in both nametable
                        ; buffers

 INY                    ; Increment Y to move right by one tile

 LDA #7                 ; Set A = 7, which is the number of the top-middle
                        ; pattern for a blank 3x2 icon bar button

 STA (SC),Y             ; Set the top-middle tile of the 3x2 tile block we
 STA (SC2),Y            ; want to draw to the pattern in A, in both nametable
                        ; buffers

 INY                    ; Increment Y to move right by one tile

 LDA #8                 ; Set A = 8, which is the number of the top-right
                        ; pattern for a blank 3x2 icon bar button

 STA (SC),Y             ; Set the top-right corner of the 3x2 tile block we
 STA (SC2),Y            ; want to draw to the pattern in A, in both nametable
                        ; buffers

 TYA                    ; Set Y = Y + 30
 CLC                    ;
 ADC #30                ; So Y now points to the bottom-left tile of the 3x2
 TAY                    ; tile block that we want to draw buffers (as there are
                        ; 32 tiles in a row and we already moved right by two)

 LDA #38                ; Set A = 36, which is the number of the bottom-left
                        ; pattern for a blank 3x2 icon bar button

 STA (SC),Y             ; Set the bottom-left corner of the 3x2 tile block we
 STA (SC2),Y            ; want to draw to the pattern in A, in both nametable
                        ; buffers

 INY                    ; Increment Y to move right by one tile

 LDA #37                ; Set A = 37, which is the number of the bottom-middle
                        ; pattern for a blank 3x2 icon bar button

 STA (SC),Y             ; Set the bottom-middle tile of the 3x2 tile block we
 STA (SC2),Y            ; want to draw to the pattern in A, in both nametable
                        ; buffers

 INY                    ; Increment Y to move right by one tile

 LDA #39                ; Set A = 39, which is the number of the bottom-right
                        ; pattern for a blank 3x2 icon bar button

 STA (SC),Y             ; Set the bottom-right corner of the 3x2 tile block we
 STA (SC2),Y            ; want to draw to the pattern in A, in both nametable
                        ; buffers

 RTS                    ; Return from the subroutine

; ******************************************************************************
;
;       Name: Draw6OptionTiles
;       Type: Subroutine
;   Category: Icon bar
;    Summary: Draw six tiles over the top of an icon bar button in the Pause
;             icon bar to change an option icon to a non-default state
;
; ------------------------------------------------------------------------------
;
; Arguments:
;
;   Y                   The tile column of the top-left tile in the block of six
;                       tiles that we want to draw (three across and two high)
;
;   SC(1 0)             The address of the nametable entries for the on-screen
;                       icon bar in nametable buffer 0
;
;   SC2(1 0)            The address of the nametable entries for the on-screen
;                       icon bar in nametable buffer 1
;
; ------------------------------------------------------------------------------
;
; Returns:
;
;   Y                   Y is preserved
;
; ******************************************************************************

.Draw6OptionTiles

 JSR Draw2OptionTiles   ; Call Draw2OptionTiles to draw two tiles over the top
                        ; of the option icon specified in Y

 INY                    ; Increment Y to move along to the next tile column

                        ; Fall through into Draw4OptionTiles to draw four more
                        ; tiles

; ******************************************************************************
;
;       Name: Draw4OptionTiles
;       Type: Subroutine
;   Category: Icon bar
;    Summary: Draw four tiles over the top of an icon bar button in the Pause
;             icon bar to change an option icon to a non-default state
;
; ------------------------------------------------------------------------------
;
; Arguments:
;
;   Y                   The tile column of the top-left tile in the 2x2 block of
;                       four tiles that we want to draw
;
;   SC(1 0)             The address of the nametable entries for the on-screen
;                       icon bar in nametable buffer 0
;
;   SC2(1 0)            The address of the nametable entries for the on-screen
;                       icon bar in nametable buffer 1
;
; ------------------------------------------------------------------------------
;
; Returns:
;
;   Y                   Y is preserved
;
; ******************************************************************************

.Draw4OptionTiles

 SETUP_PPU_FOR_ICON_BAR ; If the PPU has started drawing the icon bar, configure
                        ; the PPU to use nametable 0 and pattern table 0

 JSR Draw2OptionTiles   ; Call Draw2OptionTiles to draw two tiles over the top
                        ; of the option icon specified in Y

 INY                    ; Increment Y to move along to the next tile column

                        ; Fall through into Draw4OptionTiles to draw two more
                        ; tiles

; ******************************************************************************
;
;       Name: Draw2OptionTiles
;       Type: Subroutine
;   Category: Icon bar
;    Summary: Draw a top and bottom tile over the top of an icon bar button in
;             the Pause icon bar to change an option icon to a non-default state
;
; ------------------------------------------------------------------------------
;
; Arguments:
;
;   Y                   The tile column of the top and bottom tiles that we want
;                       to draw
;
;   SC(1 0)             The address of the nametable entries for the on-screen
;                       icon bar in nametable buffer 0
;
;   SC2(1 0)            The address of the nametable entries for the on-screen
;                       icon bar in nametable buffer 1
;
; ------------------------------------------------------------------------------
;
; Returns:
;
;   Y                   Y is preserved
;
; ******************************************************************************

.Draw2OptionTiles

 LDA barNames3+14,Y     ; Set A to the nametable entry for the top tile of this
                        ; option's icon when it is not in the default state,
                        ; which can be found in entry Y + 14 of the barNames3
                        ; table

 STA (SC),Y             ; Set the top tile of the block we want to draw to the
 STA (SC2),Y            ; pattern in A, in both nametable buffers

 STY T                  ; Store Y in T so we can retrieve it below

 TYA                    ; Set Y = Y + 32
 CLC                    ;
 ADC #32                ; So Y now points to the next tile down in the row below
 TAY                    ; (as there are 32 tiles in a row)

 LDA barNames3+14,Y     ; Set A to the nametable entry for the bottom tile of
                        ; this option's icon when it is not in the default
                        ; state, which can be found in entry Y + 14 of the
                        ; barNames3 table

 STA (SC),Y             ; Set the bottom tile of the block we want to draw to
 STA (SC2),Y            ; the pattern in A, in both nametable buffers

 LDY T                  ; Restore Y from T so it is preserved

 RTS                    ; Return from the subroutine

; ******************************************************************************
;
;       Name: SetLinePatterns
;       Type: Subroutine
;   Category: Drawing the screen
;    Summary: Copy the patterns for horizontal line, vertical line and block
;             images into the pattern buffers, depending on the view
;  Deep dive: Drawing lines in the NES version
;
; ******************************************************************************

.vpat1

 LDX #4                 ; This is the Start screen with no fonts loaded, so set
 STX firstFreePattern   ; firstFreePattern to 4

 RTS                    ; Return from the subroutine without copying anything to
                        ; the pattern buffers

.vpat2

 LDX #37                ; This is the Space view with the normal font loaded,
 STX firstFreePattern   ; so set firstFreePattern to 37

 RTS                    ; Return from the subroutine without copying anything to
                        ; the pattern buffers

.SetLinePatterns

 LDA QQ11               ; If the view type in QQ11 is $CF (Start screen with no
 CMP #$CF               ; font loaded), jump to vpat1 to set firstFreePattern to
 BEQ vpat1              ; 4 and return from the subroutine

 CMP #$10               ; If the view type in QQ11 is $10 (Space view with
 BEQ vpat2              ; the normal font loaded), jump to vpat2 to set
                        ; firstFreePattern to 37 and return from the subroutine

 LDX #66                ; Set X = 66 to use as the value of firstFreePattern
                        ; then there is no dashboard

 LDA QQ11               ; If bit 7 of the view type in QQ11 is set then there
 BMI vpat3              ; is no dashboard, so jump to vpat3 to keep X = 66

 LDX #60                ; There is a dashboard, so set X = 60 to use as the
                        ; value of firstFreePattern

.vpat3

 STX firstFreePattern   ; Set firstFreePattern to the value we set in X, so it
                        ; is 66 when there is no dashboard, or 60 when there is
                        ;
                        ; We now load the image data for the horizontal line,
                        ; vertical line and block images, starting at pattern 37
                        ; and ending at the pattern in firstFreePattern (60 or
                        ; 66)

 LDA #HI(lineImage)     ; Set V(1 0) = lineImage so we copy the pattern data for
 STA V+1                ; the line images into the pattern buffers below
 LDA #LO(lineImage)
 STA V

 LDA #HI(pattBuffer0+8*37)  ; Set SC(1 0) to the address of pattern 37 in
 STA SC+1                   ; pattern buffer 0
 LDA #LO(pattBuffer0+8*37)
 STA SC

 LDA #HI(pattBuffer1+8*37)  ; Set SC2(1 0) to the address of pattern 37 in
 STA SC2+1                  ; pattern buffer 1
 LDA #LO(pattBuffer1+8*37)
 STA SC2

 LDY #0                 ; We are about to copy data into the pattern buffers,
                        ; so set an index counter in Y

 LDX #37                ; We are copying the image data into patterns 37 to 60,
                        ; so set a pattern counter in X

.vpat4

 SETUP_PPU_FOR_ICON_BAR ; If the PPU has started drawing the icon bar, configure
                        ; the PPU to use nametable 0 and pattern table 0

                        ; We repeat the following code eight times, so it copies
                        ; eight bytes of each pattern into both pattern buffers

 LDA (V),Y              ; Copy the Y-th pattern byte from the line image table
 STA (SC),Y             ; into pattern buffers 0 and 1, and increment the index
 STA (SC2),Y            ; in Y
 INY

 LDA (V),Y              ; Copy the Y-th pattern byte from the line image table
 STA (SC),Y             ; into pattern buffers 0 and 1, and increment the index
 STA (SC2),Y            ; in Y
 INY

 LDA (V),Y              ; Copy the Y-th pattern byte from the line image table
 STA (SC),Y             ; into pattern buffers 0 and 1, and increment the index
 STA (SC2),Y            ; in Y
 INY

 LDA (V),Y              ; Copy the Y-th pattern byte from the line image table
 STA (SC),Y             ; into pattern buffers 0 and 1, and increment the index
 STA (SC2),Y            ; in Y
 INY

 LDA (V),Y              ; Copy the Y-th pattern byte from the line image table
 STA (SC),Y             ; into pattern buffers 0 and 1, and increment the index
 STA (SC2),Y            ; in Y
 INY

 LDA (V),Y              ; Copy the Y-th pattern byte from the line image table
 STA (SC),Y             ; into pattern buffers 0 and 1, and increment the index
 STA (SC2),Y            ; in Y
 INY

 LDA (V),Y              ; Copy the Y-th pattern byte from the line image table
 STA (SC),Y             ; into pattern buffers 0 and 1, and increment the index
 STA (SC2),Y            ; in Y
 INY

 LDA (V),Y              ; Copy the Y-th pattern byte from the line image table
 STA (SC),Y             ; into pattern buffers 0 and 1, and increment the index
 STA (SC2),Y            ; in Y
 INY

 BNE vpat5              ; If we just incremented Y back around to 0, then
 INC V+1                ; increment the high bytes of V(1 0), SC(1 0) and
 INC SC+1               ; SC2(1 0) to point to the next page in memory
 INC SC2+1

.vpat5

 INX                    ; Increment the pattern counter in X

 CPX #60                ; Loop back until we have copied patterns 37 to 59
 BNE vpat4

.vpat6

 SETUP_PPU_FOR_ICON_BAR ; If the PPU has started drawing the icon bar, configure
                        ; the PPU to use nametable 0 and pattern table 0

 CPX firstFreePattern   ; If the pattern counter in X matches firstFreePattern,
 BEQ vpat8              ; jump to vpat8 to exit the following loop

                        ; Otherwise we keep copying tiles until X matches
                        ; firstFreePattern

 LDA (V),Y              ; Copy the Y-th pattern byte from the line image table
 STA (SC2),Y            ; into pattern buffer 1, zero the Y-th byte of pattern
 LDA #0                 ; buffer 0, and increment the index
 STA (SC),Y
 INY

 LDA (V),Y              ; Copy the Y-th pattern byte from the line image table
 STA (SC2),Y            ; into pattern buffer 1, zero the Y-th byte of pattern
 LDA #0                 ; buffer 0, and increment the index
 STA (SC),Y
 INY

 LDA (V),Y              ; Copy the Y-th pattern byte from the line image table
 STA (SC2),Y            ; into pattern buffer 1, zero the Y-th byte of pattern
 LDA #0                 ; buffer 0, and increment the index
 STA (SC),Y
 INY

 LDA (V),Y              ; Copy the Y-th pattern byte from the line image table
 STA (SC2),Y            ; into pattern buffer 1, zero the Y-th byte of pattern
 LDA #0                 ; buffer 0, and increment the index
 STA (SC),Y
 INY

 LDA (V),Y              ; Copy the Y-th pattern byte from the line image table
 STA (SC2),Y            ; into pattern buffer 1, zero the Y-th byte of pattern
 LDA #0                 ; buffer 0, and increment the index
 STA (SC),Y
 INY

 LDA (V),Y              ; Copy the Y-th pattern byte from the line image table
 STA (SC2),Y            ; into pattern buffer 1, zero the Y-th byte of pattern
 LDA #0                 ; buffer 0, and increment the index
 STA (SC),Y
 INY

 LDA (V),Y              ; Copy the Y-th pattern byte from the line image table
 STA (SC2),Y            ; into pattern buffer 1, zero the Y-th byte of pattern
 LDA #0                 ; buffer 0, and increment the index
 STA (SC),Y
 INY

 LDA (V),Y              ; Copy the Y-th pattern byte from the line image table
 STA (SC2),Y            ; into pattern buffer 1, zero the Y-th byte of pattern
 LDA #0                 ; buffer 0, and increment the index
 STA (SC),Y
 INY

 BNE vpat7              ; If we just incremented Y back around to 0, then
 INC V+1                ; increment the high bytes of V(1 0), SC(1 0) and
 INC SC+1               ; SC2(1 0) to point to the next page in memory
 INC SC2+1

.vpat7

 INX                    ; Increment the pattern counter in X

 JMP vpat6              ; Loop back to copy more patterns, if required

.vpat8

 SETUP_PPU_FOR_ICON_BAR ; If the PPU has started drawing the icon bar, configure
                        ; the PPU to use nametable 0 and pattern table 0

                        ; Finally, we reset the next six patterns (i.e. the ones
                        ; from firstFreePattern onwards), so we need to zero 48
                        ; bytes, as there are eight bytes in each pattern
                        ;
                        ; We keep using the index in Y, as it already points to
                        ; the correct place in the buffers

 LDA #0                 ; Set A = 0 so we can zero the pattern buffers

 LDX #48                ; Set X as a byte counter

.vpat9

 STA (SC2),Y            ; Zero the Y-th byte of both pattern buffers
 STA (SC),Y

 INY                    ; Increment the index counter

 BNE vpat10             ; If we just incremented Y back around to 0, then
 INC SC2+1              ; increment the high bytes of SC(1 0) and SC2(1 0)
 INC SC+1               ; to point to the next page in memory

.vpat10

 DEX                    ; Decrement the byte counter

 BNE vpat9              ; Loop back until we have zeroed all 48 bytes

 SETUP_PPU_FOR_ICON_BAR ; If the PPU has started drawing the icon bar, configure
                        ; the PPU to use nametable 0 and pattern table 0

 RTS                    ; Return from the subroutine

; ******************************************************************************
;
;       Name: LoadNormalFont
;       Type: Subroutine
;   Category: Text
;    Summary: Load the normal font into the pattern buffer from pattern 66 to
;             160
;  Deep dive: Fonts in NES Elite
;
; ------------------------------------------------------------------------------
;
; This routine fills the pattern buffer from pattern 66 to 160 with the font in
; colour 1 on a colour 0 background (typically a white or cyan font on a black
; background).
;
; If the view type in QQ11 is $BB (Save and load with the normal and highlight
; fonts loaded), then the font is in colour 1 on a colour 2 background (which
; is a grey font on a red background in that view's palette).
;
; This is always called with A = 66, so it always loads the fonts from pattern
; 66 to 160.
;
; ------------------------------------------------------------------------------
;
; Arguments:
;
;   A                   The pattern number to start at when loading the font
;                       patterns into the pattern buffers
;
; ******************************************************************************

.LoadNormalFont

 STA SC                 ; Set SC to the pattern number where we need to load the
                        ; font patterns

 SEC                    ; Set asciiToPattern = A - ASCII code for space
 SBC #' '               ;                    = start pattern - ASCII for space
 STA asciiToPattern     ;
                        ; The font that we load starts with a space character as
                        ; the first entry, so asciiToPattern is the number we
                        ; need to add to an ASCII code to get the corresponding
                        ; character pattern

 LDA SC                 ; Set firstFreePattern = SC + 95
 CLC                    ;
 ADC #95                ; There are 95 characters in the font, and we are about
 STA firstFreePattern   ; to load them at pattern number SC in the buffers, so
                        ; this sets the next free pattern number in
                        ; firstFreePattern to the pattern after the 95 font
                        ; patterns we are loading
                        ;
                        ; The font pattern data at fontImage actually contains
                        ; 96 characters, but we ignore the last one, which is
                        ; full of random workspace noise left over from the
                        ; assembly process

 LDX #0                 ; Set X = 0 to use in the font inversion logic below

 LDA QQ11               ; If the view type in QQ11 is not $BB (Save and load
 CMP #$BB               ; with the normal and highlight fonts loaded), jump to
 BNE ifon1              ; ifon1 to skip the following instruction

 DEX                    ; This is the Save and Load screen with font loaded in
                        ; both bitplanes, so set X = $FF to use in the font
                        ; inversion logic below

.ifon1

 STX T                  ; Set T = X, so we have the following:
                        ;
                        ;   * T = $FF if QQ11 is $BB (Save and Load screen with
                        ;         the normal and highlight fonts loaded)
                        ;
                        ;   * T = 0 for all other screens
                        ;
                        ; This is used to invert the font characters below

 LDA #0                 ; Set SC2(1 0) = pattBuffer0 + SC * 8
 ASL SC                 ;
 ROL A                  ; So this points to the pattern in pattern buffer 0 that
 ASL SC                 ; corresponds to tile number SC
 ROL A
 ASL SC
 ROL A
 ADC #HI(pattBuffer0)
 STA SC2+1

 ADC #8                 ; Set SC(1 0) = SC2(1 0) + (8 0)
 STA SC+1               ;
 LDA SC                 ; Pattern buffer 0 consists of 8 pages of memory and is
 STA SC2                ; followed by pattern buffer 1, so this sets SC(1 0) to
                        ; the pattern in pattern buffer 1 that corresponds to
                        ; tile number SC

 LDA #HI(fontImage)     ; Set V(1 0) = fontImage, so we copy the font patterns
 STA V+1                ; to the pattern buffers in the following
 LDA #LO(fontImage)
 STA V

 LDX #95                ; There are 95 characters in the game font, so set a
                        ; character counter in X to count down from 95 to 1

 LDY #0                 ; Set Y to use as an index counter as we copy the font
                        ; to the pattern buffers

.ifon2

 SETUP_PPU_FOR_ICON_BAR ; If the PPU has started drawing the icon bar, configure
                        ; the PPU to use nametable 0 and pattern table 0

                        ; We repeat the following code eight times, so it sends
                        ; all eight bytes of this character's font pattern to
                        ; both pattern buffers
                        ;
                        ; In each of the following, the font character is copied
                        ; into pattern buffer 0 unchanged, but when the same
                        ; character is copied into pattern buffer 1, the
                        ; following transformation is applied:
                        ;
                        ;   AND T
                        ;   EOR T
                        ;
                        ; T is 0, unless this is the Save and Load screen, in
                        ; which case T is $FF
                        ;
                        ; When T = 0, we have A AND 0 EOR 0, which is 0, so
                        ; pattern buffer 1 gets filled with zeroes, and as
                        ; pattern buffer 0 contains the font, this means the
                        ; pattern buffer contains the font in colour 1 on a
                        ; colour 0 background (i.e. a black background)
                        ;
                        ; When T = $FF, we have A AND $FF EOR $FF, which is the
                        ; same as A EOR $FF, which is the value in A inverted,
                        ; so pattern buffer 1 gets filled with the font, but
                        ; with ones for the background and zeroes for the
                        ; foreground, which means the pattern buffer contains
                        ; the font in colour 2 on a colour 1 background

 LDA (V),Y              ; Copy the Y-th pattern byte from the font to pattern
 STA (SC2),Y            ; buffer 0, and copy the same pattern to pattern buffer
 AND T                  ; 1, either as a row of eight filled pixels or as an
 EOR T                  ; inverted font, and increment the index in Y
 STA (SC),Y
 INY

 LDA (V),Y              ; Copy the Y-th pattern byte from the font to pattern
 STA (SC2),Y            ; buffer 0, and copy the same pattern to pattern buffer
 AND T                  ; 1, either as a white block or as an inverted font, and
 EOR T                  ; increment the index in Y
 STA (SC),Y
 INY

 LDA (V),Y              ; Copy the Y-th pattern byte from the font to pattern
 STA (SC2),Y            ; buffer 0, and copy the same pattern to pattern buffer
 AND T                  ; 1, either as a white block or as an inverted font, and
 EOR T                  ; increment the index in Y
 STA (SC),Y
 INY

 LDA (V),Y              ; Copy the Y-th pattern byte from the font to pattern
 STA (SC2),Y            ; buffer 0, and copy the same pattern to pattern buffer
 AND T                  ; 1, either as a white block or as an inverted font, and
 EOR T                  ; increment the index in Y
 STA (SC),Y
 INY

 LDA (V),Y              ; Copy the Y-th pattern byte from the font to pattern
 STA (SC2),Y            ; buffer 0, and copy the same pattern to pattern buffer
 AND T                  ; 1, either as a white block or as an inverted font, and
 EOR T                  ; increment the index in Y
 STA (SC),Y
 INY

 LDA (V),Y              ; Copy the Y-th pattern byte from the font to pattern
 STA (SC2),Y            ; buffer 0, and copy the same pattern to pattern buffer
 AND T                  ; 1, either as a white block or as an inverted font, and
 EOR T                  ; increment the index in Y
 STA (SC),Y
 INY

 LDA (V),Y              ; Copy the Y-th pattern byte from the font to pattern
 STA (SC2),Y            ; buffer 0, and copy the same pattern to pattern buffer
 AND T                  ; 1, either as a white block or as an inverted font, and
 EOR T                  ; increment the index in Y
 STA (SC),Y
 INY

 LDA (V),Y              ; Copy the Y-th pattern byte from the font to pattern
 STA (SC2),Y            ; buffer 0, and copy the same pattern to pattern buffer
 AND T                  ; 1, either as a white block or as an inverted font, and
 EOR T                  ; increment the index in Y
 STA (SC),Y
 INY

 BNE ifon3              ; If we just incremented Y back around to 0, then
 INC V+1                ; increment the high bytes of V(1 0), SC(1 0) and
 INC SC2+1              ; SC2(1 0) to point to the next page in memory
 INC SC+1

.ifon3

 DEX                    ; Decrement the character counter in X

 BNE ifon2              ; Loop back until we have copied all 95 characters to
                        ; the pattern buffers

 RTS                    ; Return from the subroutine

; ******************************************************************************
;
;       Name: LoadHighFont
;       Type: Subroutine
;   Category: Text
;    Summary: Load the highlight font into the pattern buffer from pattern 161
;             to 255
;  Deep dive: Fonts in NES Elite
;
; ------------------------------------------------------------------------------
;
; This routine fills the pattern buffer from pattern 161 to 255 with the font in
; colour 3 on a colour 1 background (which is typically a green font on a grey
; background that can be used for drawing highlighted text in menu selections).
;
; If the view type in QQ11 is $BB (Save and load with the normal and highlight
; fonts loaded), then only the first 70 characters of the font are loaded, into
; patterns 161 to 230.
;
; ******************************************************************************

.LoadHighFont

 LDA #HI(pattBuffer0+8*161) ; Set SC(1 0) to the address of pattern 161 in
 STA SC2+1                  ; pattern buffer 0
 LDA #LO(pattBuffer0+8*161)
 STA SC2

 LDA #HI(pattBuffer1+8*161) ; Set SC(1 0) to the address of pattern 161 in
 STA SC+1                   ; pattern buffer 1
 LDA #LO(pattBuffer1+8*161)
 STA SC

 LDX #95                ; There are 95 characters in the game font, so set a
                        ; character counter in X to count down from 95 to 1
                        ;
                        ; The font pattern data at fontImage actually contains
                        ; 96 characters, but we ignore the last one, which is
                        ; full of random workspace noise left over from the
                        ; assembly process

 LDA QQ11               ; If the view type in QQ11 is not $BB (Save and load
 CMP #$BB               ; with the normal and highlight fonts loaded), jump to
 BNE font1              ; font1 to skip the following instruction

 LDX #70                ; This is the Save and Load screen with font loaded in
                        ; both bitplanes, so set X = 70 so that we only copy 70
                        ; characters from the font

.font1

 TXA                    ; Set firstFreePattern = firstFreePattern + X
 CLC                    ;
 ADC firstFreePattern   ; We are about to copy X character patterns for the
 STA firstFreePattern   ; font, so this sets the next free pattern number in
                        ; firstFreePattern to the pattern that is X patterns
                        ; after its current value, i.e. just after the font we
                        ; are copying

 LDA #HI(fontImage)     ; Set V(1 0) = fontImage, so we copy the font patterns
 STA V+1                ; to the pattern buffers in the following
 LDA #LO(fontImage)
 STA V

 LDY #0                 ; Set Y to use as an index counter as we copy the font
                        ; to the pattern buffers

.font2

 SETUP_PPU_FOR_ICON_BAR ; If the PPU has started drawing the icon bar, configure
                        ; the PPU to use nametable 0 and pattern table 0

                        ; We repeat the following code eight times, so it sends
                        ; all eight bytes of this character's font pattern to
                        ; both pattern buffers

 LDA (V),Y              ; Copy the Y-th pattern byte from the font to pattern
 STA (SC),Y             ; buffer 1, set the Y-th pattern byte in pattern buffer
 LDA #$FF               ; 0 to a row of eight set pixels, and increment the
 STA (SC2),Y            ; index in Y
 INY

 LDA (V),Y              ; Copy the Y-th pattern byte from the font to pattern
 STA (SC),Y             ; buffer 1, set the Y-th pattern byte in pattern buffer
 LDA #$FF               ; 0 to a row of eight set pixels, and increment the
 STA (SC2),Y            ; index in Y
 INY

 LDA (V),Y              ; Copy the Y-th pattern byte from the font to pattern
 STA (SC),Y             ; buffer 1, set the Y-th pattern byte in pattern buffer
 LDA #$FF               ; 0 to a row of eight set pixels, and increment the
 STA (SC2),Y            ; index in Y
 INY

 LDA (V),Y              ; Copy the Y-th pattern byte from the font to pattern
 STA (SC),Y             ; buffer 1, set the Y-th pattern byte in pattern buffer
 LDA #$FF               ; 0 to a row of eight set pixels, and increment the
 STA (SC2),Y            ; index in Y
 INY

 LDA (V),Y              ; Copy the Y-th pattern byte from the font to pattern
 STA (SC),Y             ; buffer 1, set the Y-th pattern byte in pattern buffer
 LDA #$FF               ; 0 to a row of eight set pixels, and increment the
 STA (SC2),Y            ; index in Y
 INY

 LDA (V),Y              ; Copy the Y-th pattern byte from the font to pattern
 STA (SC),Y             ; buffer 1, set the Y-th pattern byte in pattern buffer
 LDA #$FF               ; 0 to a row of eight set pixels, and increment the
 STA (SC2),Y            ; index in Y
 INY

 LDA (V),Y              ; Copy the Y-th pattern byte from the font to pattern
 STA (SC),Y             ; buffer 1, set the Y-th pattern byte in pattern buffer
 LDA #$FF               ; 0 to a row of eight set pixels, and increment the
 STA (SC2),Y            ; index in Y
 INY

 LDA (V),Y              ; Copy the Y-th pattern byte from the font to pattern
 STA (SC),Y             ; buffer 1, set the Y-th pattern byte in pattern buffer
 LDA #$FF               ; 0 to a row of eight set pixels, and increment the
 STA (SC2),Y            ; index in Y
 INY

 BNE font3              ; If we just incremented Y back around to 0, then
 INC V+1                ; increment the high bytes of V(1 0), SC(1 0) and
 INC SC+1               ; SC2(1 0) to point to the next page in memory
 INC SC2+1

.font3

 DEX                    ; Decrement the character counter in X

 BNE font2              ; Loop back until we have copied all 95 characters to
                        ; the pattern buffers

 RTS                    ; Return from the subroutine

; ******************************************************************************
;
;       Name: DrawSystemImage
;       Type: Subroutine
;   Category: Universe
;    Summary: Draw the system image as a coloured foreground in front of a
;             greyscale background
;
; ------------------------------------------------------------------------------
;
; Arguments:
;
;   X                   The number of columns in the image (i.e. the number of
;                       tiles in each row of the image)
;
;   Y                   The number of tile rows in the image
;
; ******************************************************************************

.DrawSystemImage

                        ; The system image is made up of two layers:
                        ;
                        ;   * A greyscale background that's displayed using the
                        ;     nametable tiles, whose patterns are extracted into
                        ;     the pattern buffers by the GetSystemBack routine
                        ;
                        ;   * A colourful foreground that's displayed as a set
                        ;     of sprites, whose patterns are sent to the PPU
                        ;     by the GetSystemImage routine, from pattern 69
                        ;     onwards
                        ;
                        ; We start by drawing the background into the nametable
                        ; buffers

 STX K                  ; Set K = X, so we can pass the number of columns in the
                        ; image to DrawBackground and DrawSpriteImage below

 STY K+1                ; Set K+1 = Y, so we can pass the number of rows in the
                        ; image to DrawBackground and DrawSpriteImage below

 LDA firstFreePattern   ; Set picturePattern to the number of the next free
 STA picturePattern     ; pattern in firstFreePattern
                        ;
                        ; We use this when setting K+2 below, so the call to
                        ; DrawBackground displays the patterns at
                        ; picturePattern, and it's also used to specify where
                        ; to load the system image data when we call
                        ; GetSystemImage from SendViewToPPU when showing the
                        ; Data on System screen

 CLC                    ; Add 56 to firstFreePattern, as we are going to use 56
 ADC #56                ; patterns for the system image (7 rows of 8 tiles)
 STA firstFreePattern

 LDA picturePattern     ; Set K+2 to the value we stored above, so K+2 is the
 STA K+2                ; number of the first pattern to use for the system
                        ; image's greyscale background

 JSR DrawBackground_b3  ; Draw the background by writing the nametable buffer
                        ; entries for the greyscale part of the system image
                        ; (this is the image that is extracted into the pattern
                        ; buffers by the GetSystemBack routine)

                        ; Now that the background is drawn, we move on to the
                        ; sprite-based foreground
                        ;
                        ; We draw the foreground image from sprites with
                        ; sequential patterns, so now we configure the variables
                        ; to pass to the DrawSpriteImage routine

 LDA #69                ; Set K+2 = 69, so we draw the system image using
 STA K+2                ; pattern 69 onwards

 LDA #8                 ; Set K+3 = 8, so we build the image from sprite 8
 STA K+3                ; onwards

 LDX #0                 ; Set X and Y to zero, so we draw the system image at
 LDY #0                 ; (XC, YC), without any indents

 JSR DrawSpriteImage_b6 ; Draw the system image from sprites, using pattern 69
                        ; onwards

                        ; We now draw a frame around the system image we just
                        ; drew, so we set up the variables so the DrawImageFrame
                        ; can do just that

 DEC XC                 ; We just drew the image at (XC, YC), so decrement them
 DEC YC                 ; both so we can pass (XC, YC) to the DrawImageFrame
                        ; routine to draw a frame around the image, with the
                        ; top-left corner one block up and left from the image
                        ; corner

 INC K                  ; Increment the number of columns in K to pass to the
                        ; DrawImageFrame routine, so we draw a frame that's the
                        ; correct width (DrawImageFrame expects K to be the
                        ; frame width minus 1)

 INC K+1                ; Increment K+1 twice so the DrawImageFrame will draw a
 INC K+1                ; frame that is the height of the image, plus two rows
                        ; for the top and bottom of the frame

                        ; Fall through into DrawImageFrame to draw a frame
                        ; around the system image

; ******************************************************************************
;
;       Name: DrawImageFrame
;       Type: Subroutine
;   Category: Drawing the screen
;    Summary: Draw a frame around the system image or commander headshot
;
; ------------------------------------------------------------------------------
;
; Arguments:
;
;   XC                  The tile column for the top-left corner of the frame
;
;   YC                  The tile row for the top-left corner of the frame
;
;   K                   The number of tiles to draw, minus 1 (so we draw K - 1
;                       tiles)
;
;   K+1                 The number of rows to draw
;
;   SC(1 0)             The address in nametable buffer 0 for the start of the
;                       row, less 1 (we draw from SC(1 0) + 1 onwards)
;
;   SC2(1 0)            The address in nametable buffer 1 for the start of the
;                       row, less 1 (we draw from SC2(1 0) + 1 onwards)
;
; ******************************************************************************

.DrawImageFrame

 JSR GetNameAddress     ; Get the addresses in the nametable buffers for the
                        ; tile at text coordinate (XC, YC), as follows:
                        ;
                        ;   SC(1 0) = the address in nametable buffer 0
                        ;
                        ;   SC2(1 0) = the address in nametable buffer 1

 LDY #0                 ; Set the tile at the top-left corner of the picture
 LDA #64                ; frame to pattern 64
 STA (SC),Y
 STA (SC2),Y

 LDA #60                ; Draw the top edge of the frame using pattern 60
 JSR DrawRowOfTiles

 LDA #62                ; Set the tile at the top-right corner of the picture
 STA (SC),Y             ; frame to pattern 62
 STA (SC2),Y

 DEC K+1                ; Decrement the number of rows to draw, as we have just
                        ; drawn one

 JMP fram2              ; Jump to fram2to start drawing the sides of the frame

.fram1

 JSR SetupPPUForIconBar ; If the PPU has started drawing the icon bar, configure
                        ; the PPU to use nametable 0 and pattern table 0

 LDA #1                 ; Set the tile at the start of the row (at offset 0) to
 LDY #0                 ; pattern 1, to draw the left edge of the frame
 STA (SC),Y
 STA (SC2),Y

 LDA #2                 ; Set the tile at the end of the row (at offset K) to
 LDY K                  ; pattern 2, to draw the right edge of the frame
 STA (SC),Y
 STA (SC2),Y

.fram2

 LDA SC                 ; Set SC(1 0) = SC(1 0) + 32
 CLC                    ;
 ADC #32                ; Starting with the low bytes
 STA SC                 ;
                        ; So SC(1 0) now points at the next row down (as there
                        ; are 32 tiles on each row)

 STA SC2                ; Set SC2(1 0) = SC2(1 0) + 32
                        ;
                        ; Starting with the low bytes
                        ;
                        ; So SC2(1 0) now points at the next row down (as there
                        ; are 32 tiles on each row)

 BCC fram3              ; If the above addition overflowed, increment the high
 INC SC+1               ; high bytes of SC(1 0) and SC2(1 0) accordingly
 INC SC2+1

.fram3

 DEC K+1                ; Decrement the number of rows to draw, as we have just
                        ; moved down a row

 BNE fram1              ; Loop back to fram1 to draw the frame edges, until we
                        ; have drawn the correct number of rows (i.e. K+1 - 1)

 LDY #0                 ; Set the tile at the bottom-left corner of the picture
 LDA #65                ; frame to pattern 65
 STA (SC),Y
 STA (SC2),Y

 LDA #61                ; Draw the top edge of the frame using pattern 61
 JSR DrawRowOfTiles

 LDA #63                ; Set the tile at the bottom-right corner of the picture
 STA (SC),Y             ; frame to pattern 63
 STA (SC2),Y

 RTS                    ; Return from the subroutine

; ******************************************************************************
;
;       Name: DrawRowOfTiles
;       Type: Subroutine
;   Category: Drawing the screen
;    Summary: Draw a row of tiles into the nametable buffer
;
; ------------------------------------------------------------------------------
;
; This routine effectively draws K tiles at SC(1 0) and SC2(1 0), but omitting
; the first tile.
;
; ------------------------------------------------------------------------------
;
; Arguments:
;
;   A                   The pattern number to use for the row of tiles
;
;   K                   The number of tiles to draw, minus 1 (so we draw K - 1
;                       tiles)
;
;   SC(1 0)             The address in nametable buffer 0 for the start of the
;                       row, less 1 (we draw from SC(1 0) + 1 onwards)
;
;   SC2(1 0)            The address in nametable buffer 1 for the start of the
;                       row, less 1 (we draw from SC2(1 0) + 1 onwards)
;
; ******************************************************************************

.DrawRowOfTiles

 LDY #1                 ; We start drawing from SC(1 0) + 1, so set an index
                        ; counter in Y

.drow1

 STA (SC),Y             ; Draw the pattern in A into the Y-th nametable entry
 STA (SC2),Y            ; in both the nametable buffers

 INY                    ; Increment the index counter

 CPY K                  ; Loop back until we have drawn K - 1 tiles
 BNE drow1

 RTS                    ; Return from the subroutine

; ******************************************************************************
;
;       Name: GetNameAddress
;       Type: Subroutine
;   Category: Drawing the screen
;    Summary: Get the addresses in the nametable buffers for a given tile
;
; ------------------------------------------------------------------------------
;
; Arguments:
;
;   XC                  The tile column
;
;   YC                  The tile row
;
; ------------------------------------------------------------------------------
;
; Returns:
;
;   SC(1 0)             The address in nametable buffer 0 for the tile
;
;   SC2(1 0)            The address in nametable buffer 1 for the tile
;
; ******************************************************************************

.GetNameAddress

 JSR GetRowNameAddress  ; Get the addresses in the nametable buffers for the
                        ; start of character row YC, as follows:
                        ;
                        ;   SC(1 0) = the address in nametable buffer 0
                        ;
                        ;   SC2(1 0) = the address in nametable buffer 1

 LDA SC                 ; Set SC(1 0) = SC(1 0) + XC
 CLC                    ;
 ADC XC                 ; Starting with the low bytes
 STA SC                 ;
                        ; So SC(1 0) contains the address in nametable buffer 0
                        ; of the text character at column XC on row YC

 STA SC2                ; Set SC2(1 0) = SC2(1 0) + XC
                        ;
                        ; Starting with the low bytes
                        ;
                        ; So SC2(1 0) contains the address in nametable buffer 1
                        ; of the text character at column XC on row YC

 BCC nadd1              ; If the above addition overflowed, then increment the
 INC SC+1               ; high bytes of SC(1 0) and SC2(1 0) accordingly
 INC SC2+1

.nadd1

 RTS                    ; Return from the subroutine

; ******************************************************************************
;
;       Name: DrawSmallBox
;       Type: Subroutine
;   Category: Drawing the screen
;    Summary: Draw a small box, typically used for popups or outlines
;
; ------------------------------------------------------------------------------
;
; Arguments:
;
;   K                   The width of the box to draw in tiles
;
;   K+1                 The height of the box to draw in tiles
;
;   K+2                 The text row on which to draw the top-left corner of the
;                       small box
;
;   K+3                 The text column on which to draw the top-left corner of
;                       the small box
;
; ******************************************************************************

.DrawSmallBox

 LDA K+2                ; Set the text cursor in XC to column K+2, to pass to
 STA XC                 ; GetNameAddress below

 LDA K+3                ; Set the text cursor in YC to row K+3, to pass to
 STA YC                 ; GetNameAddress below

 JSR GetNameAddress     ; Get the addresses in the nametable buffers for the
                        ; tile at text coordinate (XC, YC), as follows:
                        ;
                        ;   SC(1 0) = the address in nametable buffer 0
                        ;
                        ;   SC2(1 0) = the address in nametable buffer 1
                        ;
                        ; So these point to the address in the nametable buffer
                        ; of the top-left corner of the box

 LDA #61                ; Draw a row of K tiles using pattern 61, which contains
 JSR DrawRowOfTiles     ; a thick horizontal line along the bottom of the
                        ; pattern, so this draws the top of the box

 LDX K+1                ; Set X to the number of rows in the box we want to draw
                        ; from K+1, to use as a counter for the height of the
                        ; box

 JMP sbox2              ; Jump into the loop below at sbox2

.sbox1

 JSR SetupPPUForIconBar ; If the PPU has started drawing the icon bar, configure
                        ; the PPU to use nametable 0 and pattern table 0

 LDA SC                 ; Add 32 to SC(1 0) to move down to the next row in
 CLC                    ; nametable buffer 0, starting with the low byte
 ADC #32
 STA SC

 STA SC2                ; Update the low byte of SC2(1 0) as well to move down
                        ; in nametable buffer 1 too

 BCC sbox2              ; If the addition overflowed, increment the high bytes
 INC SC+1               ; as well
 INC SC2+1

.sbox2

 LDA #1                 ; We draw the left edge of the box using pattern 1,
                        ; which contains a thick vertical line along the right
                        ; edge of the pattern, so set A = 1 to poke into the
                        ; nametable

 LDY #0                 ; Draw the left edge of the box at the address in
 STA (SC),Y             ; SC(1 0) and SC2(1 0), which draws it in both
 STA (SC2),Y            ; nametable buffers

 LDA #2                 ; We draw the right edge of the box using pattern 2,
                        ; which contains a thick vertical line along the left
                        ; edge of the pattern, so set A = 2 to poke into the
                        ; nametable

 LDY K                  ; Draw the left edge of the box at the address in
 STA (SC),Y             ; SC(1 0) and SC2(1 0) + K, which draws it K blocks to
 STA (SC2),Y            ; the right of the left edge in both nametable buffers

 DEX                    ; Decrement the row counter in X

 BNE sbox1              ; Loop back to draw the left and right edges for the
                        ; next row

 LDA #60                ; Draw a row of K tiles using pattern 61, which contains
 JMP DrawRowOfTiles     ; a thick horizontal line along the top of the pattern,
                        ; so this draws the bottom of the box, returning from
                        ; the subroutine using a tail call

; ******************************************************************************
;
;       Name: DrawBackground
;       Type: Subroutine
;   Category: Drawing the screen
;    Summary: Draw the background of a system or commander image into the
;             nametable buffer
;
; ------------------------------------------------------------------------------
;
; We draw an image background using patterns with incremental pattern numbers,
; as the image's patterns have already been sent to the pattern buffers one
; after the other.
;
; ------------------------------------------------------------------------------
;
; Arguments:
;
;   K                   The number of columns in the image (i.e. the number of
;                       tiles in each row of the image)
;
;   K+1                 The number of tile rows in the image
;
;   K+2                 The pattern number of the start of the image pattern
;                       data in the pattern table
;
;   K+3                 Number of the first free sprite in the sprite buffer,
;                       where we can build the sprites to make up the image
;
; ******************************************************************************

.DrawBackground

 JSR GetRowNameAddress  ; Get the addresses in the nametable buffers for the
                        ; start of character row YC, as follows:
                        ;
                        ;   SC(1 0) = the address in nametable buffer 0
                        ;
                        ;   SC2(1 0) = the address in nametable buffer 1

 LDA SC                 ; Set SC(1 0) = SC(1 0) + XC
 CLC                    ;
 ADC XC                 ; Starting with the low bytes
 STA SC                 ;
                        ; So SC(1 0) contains the address in nametable buffer 0
                        ; of the text character at column XC on row YC

 STA SC2                ; Set SC2(1 0) = SC2(1 0) + XC
                        ;
                        ; Starting with the low bytes
                        ;
                        ; So SC2(1 0) contains the address in nametable buffer 1
                        ; of the text character at column XC on row YC

 BCC back1              ; If the above addition overflowed, then increment the
 INC SC+1               ; high bytes of SC(1 0) and SC2(1 0) accordingly
 INC SC2+1

.back1

 LDX K+1                ; Set X = K+1 to use as a counter for each row in the
                        ; image

.back2

 SETUP_PPU_FOR_ICON_BAR ; If the PPU has started drawing the icon bar, configure
                        ; the PPU to use nametable 0 and pattern table 0

 LDY #0                 ; Set Y as a tile index as we work through the tiles in
                        ; the image

 LDA K+2                ; Set A to the pattern number of the first tile in K+2

.back3

 STA (SC2),Y            ; Set the Y-th nametable entry in both nametable buffers
 STA (SC),Y             ; to the pattern number in A

 CLC                    ; Increment A so we fill the background with incremental
 ADC #1                 ; pattern numbers

 INY                    ; Increment the index counter

 CPY K                  ; Loop back until we have drawn K - 1 tiles
 BNE back3

 STA K+2                ; Update K+2 to the pattern number of the next tile

 LDA SC                 ; Set SC(1 0) = SC(1 0) + 32
 CLC                    ;
 ADC #32                ; Starting with the low bytes
 STA SC                 ;
                        ; So SC(1 0) now points at the next row down (as there
                        ; are 32 tiles on each row)

 STA SC2                ; Set SC2(1 0) = SC2(1 0) + 32
                        ;
                        ; Starting with the low bytes
                        ;
                        ; So SC2(1 0) now points at the next row down (as there
                        ; are 32 tiles on each row)

 BCC back4              ; If the above addition overflowed, increment the high
 INC SC+1               ; high bytes of SC(1 0) and SC2(1 0) accordingly
 INC SC2+1

.back4

 DEX                    ; Decrement the number of rows to draw, as we have just
                        ; moved down a row

 BNE back2              ; Loop back until we have drawn all X rows in the image

 RTS                    ; Return from the subroutine

; ******************************************************************************
;
;       Name: ClearScreen
;       Type: Subroutine
;   Category: Drawing the screen
;    Summary: Clear the screen by clearing patterns 66 to 255 in both pattern
;             buffers, and clearing both nametable buffers to the background
;
; ******************************************************************************

.ClearScreen

 LDA #0                 ; Set SC(1 0) = 66 * 8
 STA SC+1               ;
 LDA #66                ; We use this to calculate the address of pattern 66 in
 ASL A                  ; the pattern buffers below
 ROL SC+1
 ASL A
 ROL SC+1
 ASL A
 ROL SC+1
 STA SC

 STA SC2                ; Set SC2(1 0) = pattBuffer1 + SC(1 0)
 LDA SC+1               ;              = pattBuffer1 + 66 * 8
 ADC #HI(pattBuffer1)   ;
 STA SC2+1              ; So SC2(1 0) contains the address of pattern 66 in
                        ; pattern buffer 1, as each pattern in the buffer
                        ; contains eight bytes

 LDA SC+1               ; Set SC(1 0) = pattBuffer0 + SC(1 0)
 ADC #HI(pattBuffer0)   ;             = pattBuffer0 + 66 * 8
 STA SC+1               ;
                        ; So SC2(1 0) contains the address of pattern 66 in
                        ; pattern buffer 0

 LDX #66                ; We want to zero pattern 66 onwards, so set a counter
                        ; in X to count the tile number, starting from 66

 LDY #0                 ; Set Y to use as a byte index as we zero 8 bytes for
                        ; each tile

.clsc1

 LDA #0                 ; We are going to zero the tiles to clear the patterns,
                        ; so set A = 0 so we can poke it into memory

                        ; We repeat the following code eight times, so it clears
                        ; one whole pattern of eight bytes

 STA (SC),Y             ; Zero the Y-th pattern byte in SC(1 0) and SC2(1 0), to
 STA (SC2),Y            ; clear both pattern buffer 0 and 1, and increment the
 INY                    ; byte counter in Y

 STA (SC),Y             ; Zero the Y-th pattern byte in SC(1 0) and SC2(1 0), to
 STA (SC2),Y            ; clear both pattern buffer 0 and 1, and increment the
 INY                    ; byte counter in Y

 STA (SC),Y             ; Zero the Y-th pattern byte in SC(1 0) and SC2(1 0), to
 STA (SC2),Y            ; clear both pattern buffer 0 and 1, and increment the
 INY                    ; byte counter in Y

 STA (SC),Y             ; Zero the Y-th pattern byte in SC(1 0) and SC2(1 0), to
 STA (SC2),Y            ; clear both pattern buffer 0 and 1, and increment the
 INY                    ; byte counter in Y

 STA (SC),Y             ; Zero the Y-th pattern byte in SC(1 0) and SC2(1 0), to
 STA (SC2),Y            ; clear both pattern buffer 0 and 1, and increment the
 INY                    ; byte counter in Y

 STA (SC),Y             ; Zero the Y-th pattern byte in SC(1 0) and SC2(1 0), to
 STA (SC2),Y            ; clear both pattern buffer 0 and 1, and increment the
 INY                    ; byte counter in Y

 STA (SC),Y             ; Zero the Y-th pattern byte in SC(1 0) and SC2(1 0), to
 STA (SC2),Y            ; clear both pattern buffer 0 and 1, and increment the
 INY                    ; byte counter in Y

 STA (SC),Y             ; Zero the Y-th pattern byte in SC(1 0) and SC2(1 0), to
 STA (SC2),Y            ; clear both pattern buffer 0 and 1, and increment the
 INY                    ; byte counter in Y

 BNE clsc2              ; If Y is non-zero then jump to clsc2 to skip the
                        ; following

 INC SC+1               ; Y just wrapped around to zero, so increment the high
 INC SC2+1              ; bytes of SC(1 0) and SC2(1 0) so that SC(1 0) + Y
                        ; and SC2(1 0) + Y continue to point to the correct
                        ; addresses in the pattern buffers

.clsc2

 SETUP_PPU_FOR_ICON_BAR ; If the PPU has started drawing the icon bar, configure
                        ; the PPU to use nametable 0 and pattern table 0

 INX                    ; Increment the tile number in X, as we just cleared a
                        ; whole pattern

 BNE clsc1              ; Loop back to clsc1 to keep clearing patterns until we
                        ; have cleared patterns 66 through 255

                        ; We have cleared the pattern buffers, so now to clear
                        ; the nametable buffers

 LDA #LO(nameBuffer0)   ; Set SC(1 0)  = nameBuffer0
 STA SC
 STA SC2
 LDA #HI(nameBuffer0)
 STA SC+1

 LDA #HI(nameBuffer1)   ; Set SC2(1 0) = nameBuffer1
 STA SC2+1

 LDX #28                ; We are going to clear 28 rows of 32 tiles, so set a
                        ; row counter in X to count down from 28

.clsc3

 LDY #32                ; We are going to clear 32 tiles on each row, so set a
                        ; tile counter in Y to count down from 32

 LDA #0                 ; We are going to zero the nametable entry so it uses
                        ; the blank background tile, so set A = 0 so we can poke
                        ; it into memory

.clsc4

 STA (SC),Y             ; Zero the Y-th nametable entry in SC(1 0), which resets
                        ; nametable 0

 STA (SC2),Y            ; Zero the Y-th nametable entry in SC2(1 0), which
                        ; resets nametable 1

 DEY                    ; Decrement the tile counter in Y

 BPL clsc4              ; Loop back until we have zeroed all 32 tiles on this
                        ; row

 SETUP_PPU_FOR_ICON_BAR ; If the PPU has started drawing the icon bar, configure
                        ; the PPU to use nametable 0 and pattern table 0

 LDA SC                 ; Add 32 to both SC(1 0) and SC2(1 0) so they point to
 CLC                    ; the next row down in the nametables, starting with the
 ADC #32                ; low bytes
 STA SC
 STA SC2

 BCC clsc5              ; And then the high bytes
 INC SC+1
 INC SC2+1

.clsc5

 DEX                    ; Decrement the row counter in X

 BNE clsc3              ; Loop back until we have cleared all 28 rows

 RTS                    ; Return from the subroutine

; ******************************************************************************
;
;       Name: viewPalettes
;       Type: Variable
;   Category: Drawing the screen
;    Summary: The palettes to use for the different views
;
; ******************************************************************************

.viewPalettes

 EQUB $0F, $2C, $0F, $2C    ; Palette 0: Space view, Game Over screen
 EQUB $0F, $28, $00, $1A
 EQUB $0F, $10, $00, $16
 EQUB $0F, $10, $00, $1C
 EQUB $0F, $38, $2A, $15
 EQUB $0F, $1C, $22, $28
 EQUB $0F, $16, $28, $27
 EQUB $0F, $15, $20, $25

 EQUB $0F, $38, $38, $38    ; Palette 1: Market Price
 EQUB $0F, $10, $06, $1A
 EQUB $0F, $22, $00, $28
 EQUB $0F, $10, $00, $1C
 EQUB $0F, $38, $10, $15
 EQUB $0F, $10, $0F, $1C
 EQUB $0F, $06, $28, $25
 EQUB $0F, $15, $20, $25

 EQUB $0F, $2C, $0F, $2C    ; Palette 2: Title screen
 EQUB $0F, $28, $00, $1A
 EQUB $0F, $10, $00, $16
 EQUB $0F, $10, $00, $3A
 EQUB $0F, $38, $10, $15
 EQUB $0F, $1C, $10, $28
 EQUB $0F, $06, $10, $27
 EQUB $0F, $00, $10, $25

 EQUB $0F, $2C, $0F, $2C    ; Palette 3: Short-range Chart
 EQUB $0F, $10, $1A, $28
 EQUB $0F, $10, $00, $16
 EQUB $0F, $10, $00, $1C
 EQUB $0F, $38, $2A, $15
 EQUB $0F, $1C, $22, $28
 EQUB $0F, $06, $28, $27
 EQUB $0F, $15, $20, $25

 EQUB $0F, $2C, $0F, $2C    ; Palette 4: Long-range Chart
 EQUB $0F, $20, $28, $25
 EQUB $0F, $10, $00, $16
 EQUB $0F, $10, $00, $1C
 EQUB $0F, $38, $2A, $15
 EQUB $0F, $1C, $22, $28
 EQUB $0F, $06, $28, $27
 EQUB $0F, $15, $20, $25

 EQUB $0F, $28, $10, $06    ; Palette 5: Equip Ship
 EQUB $0F, $10, $00, $1A
 EQUB $0F, $0C, $1C, $2C
 EQUB $0F, $10, $00, $1C
 EQUB $0F, $0C, $1C, $2C
 EQUB $0F, $18, $28, $38
 EQUB $0F, $25, $35, $25
 EQUB $0F, $15, $20, $25

 EQUB $0F, $2A, $00, $06    ; Palette 6: Data on System
 EQUB $0F, $20, $00, $2A
 EQUB $0F, $10, $00, $20
 EQUB $0F, $10, $00, $1C
 EQUB $0F, $38, $2A, $15
 EQUB $0F, $27, $28, $17
 EQUB $0F, $06, $28, $27
 EQUB $0F, $15, $20, $25

 EQUB $0F, $28, $0F, $25    ; Palette 7: Save and load
 EQUB $0F, $10, $06, $1A
 EQUB $0F, $10, $0F, $1A
 EQUB $0F, $10, $00, $1C
 EQUB $0F, $38, $2A, $15
 EQUB $0F, $18, $28, $38
 EQUB $0F, $06, $2C, $2C
 EQUB $0F, $15, $20, $25

 EQUB $0F, $1C, $10, $30    ; Palette 8: Inventory, Status Mode
 EQUB $0F, $20, $00, $2A
 EQUB $0F, $2A, $00, $06
 EQUB $0F, $10, $00, $1C
 EQUB $0F, $0F, $10, $30
 EQUB $0F, $17, $27, $37
 EQUB $0F, $0F, $28, $38
 EQUB $0F, $15, $25, $25

 EQUB $0F, $1C, $2C, $3C    ; Palette 9: Start screen
 EQUB $0F, $38, $11, $11
 EQUB $0F, $16, $00, $20
 EQUB $0F, $2B, $00, $25
 EQUB $0F, $10, $1A, $25
 EQUB $0F, $08, $18, $27
 EQUB $0F, $0F, $28, $38
 EQUB $0F, $00, $10, $30

 EQUB $0F, $2C, $0F, $2C    ; Palette 10: Mission briefings
 EQUB $0F, $10, $28, $1A
 EQUB $0F, $10, $00, $16
 EQUB $0F, $10, $00, $1C
 EQUB $0F, $38, $2A, $15
 EQUB $0F, $1C, $22, $28
 EQUB $0F, $06, $28, $27
 EQUB $0F, $15, $20, $25

; ******************************************************************************
;
;       Name: fadeColours
;       Type: Variable
;   Category: Drawing the screen
;    Summary: Lookup table that converts a NES colour to the same colour but
;             with a smaller brightness value
;  Deep dive: Views and view types in NES Elite
;
; ------------------------------------------------------------------------------
;
; Colours on the NES are stored as hue and value, using an HSV model but without
; the saturation. Specifically the hue (i.e. blue, red etc.) is stored in the
; low nibble, while the value (i.e. the brightness) is stored in bits 4 and 5
; of the high nibble. Bits 6 and 7 are unused and are always zero.
;
; This means that given a colour value in hexadecimal, it is in the form &vh
; where v is the value (brightness) and h is the hue. We can therefore alter the
; brightness of a colour by increasing or decreasing the high nibble between
; 0 and 3, with &0h being the darkest and &3h being the brightest.
;
; The NES only supports 54 of the 64 possible colours in this scheme, with
; colours &vE and &vF all being black, as well as $0D. The convention is to use
; $0F for all these variants of black.
;
; Given a colour &vh, the table entry at fadeColours + &vh contains the same
; colour but with a reduced brightness in &v. Specifically, it returns the
; colour with a brightness of &v - 1. We can therefore use this table to fade a
; colour to black, which will take up to four steps depending on the brightness
; of the starting colour. See the FadeColours routine for an example.
;
; ******************************************************************************

.fadeColours

 EQUB $0F, $0F, $0F, $0F    ; Fade colours with value &0v to black ($0F)
 EQUB $0F, $0F, $0F, $0F
 EQUB $0F, $0F, $0F, $0F
 EQUB $0F, $0F, $0F, $0F

 EQUB $00, $01, $02, $03    ; Fade colours with value &1v to &0v
 EQUB $04, $05, $06, $07
 EQUB $08, $09, $0A, $0B
 EQUB $0C, $0F, $0F, $0F

 EQUB $10, $11, $12, $13    ; Fade colours with value &2v to &1v
 EQUB $14, $15, $16, $17
 EQUB $18, $19, $1A, $1B
 EQUB $1C, $0F, $0F, $0F

 EQUB $20, $21, $22, $23    ; Fade colours with value &3v to &2v
 EQUB $24, $25, $26, $27
 EQUB $28, $29, $2A, $2B
 EQUB $2C, $0F, $0F, $0F

; ******************************************************************************
;
;       Name: GetViewPalettes
;       Type: Subroutine
;   Category: Drawing the screen
;    Summary: Get the palette for the view type in QQ11a and store it in a table
;             at XX3
;  Deep dive: Bitplanes in NES Elite
;
; ******************************************************************************

.GetViewPalettes

 LDA QQ11a              ; Set X to the old view type in the low nibble of
 AND #%00001111         ; QQ11a
 TAX

 LDA #0                 ; Set SC+1 = 0, though this is superfluous as we do the
 STA SC+1               ; the same thing just below

 LDA paletteForView,X   ; Set A to the palette number to load for view X

 LDY #0                 ; Set SC+1 = 0 for use as the high byte in the address
 STY SC+1               ; we are about to construct

 ASL A                  ; Set (SC+1 A) = A * 32
 ASL A
 ASL A
 ASL A
 ASL A
 ROL SC+1

 ADC #LO(viewPalettes)  ; Set SC(1 0) = (SC+1 A) + viewPalettes
 STA SC                 ;             = viewPalettes + 32 * A
 LDA #HI(viewPalettes)  ;
 ADC SC+1               ; As each of the palettes in the viewPalettes table
 STA SC+1               ; consists of 32 bytes, this sets SC(1 0) to the address
                        ; of the A-th palette in the table, which is the palette
                        ; that corresponds to the view type in QQ11a that we
                        ; fetched above

 LDY #32                ; We now want to copy the 32 bytes from the selected
                        ; palette into the palette table at XX3, so set an index
                        ; counter in Y

.gpal1

 LDA (SC),Y             ; Copy the Y-th byte from SC(1 0) to the Y-th byte of
 STA XX3,Y              ; the table at XX3

 DEY                    ; Decrement the index counter

 BPL gpal1              ; Loop back until we have copied all 32 bytes to XX3

 LDA QQ11a              ; If the old view type in QQ11a is $00 (Space view with
 BEQ gpal3              ; no fonts loaded), jump to gpal3 to set the visible and
                        ; hidden colours

 CMP #$98               ; If the old view type in QQ11a is $98 (Status Mode),
 BEQ SetPaletteColours  ; jump to SetPaletteColours to set the view's palette
                        ; from the entries in the XX3 palette table, returning
                        ; from the subroutine using a tail call

 CMP #$96               ; If the old view type in QQ11a is not $96 (Data on
 BNE gpal2              ; System), jump to SetPaletteColours via gpal2 to set
                        ; the view's palette from the entries in the XX3 palette
                        ; table, returning from the subroutine using a tail call

                        ; This is the Data on System view, so we set the palette
                        ; according to the system's seeds

 LDA QQ15               ; Set A to the EOR of the s0_lo, s2_hi and s1_lo seeds
 EOR QQ15+5             ; for the current system, shifted right by two places
 EOR QQ15+2             ; and with bits 2 and 3 flipped
 LSR A                  ;
 LSR A                  ; This gives us a number that varies between each system
 EOR #%00001100         ; that we can use to choose one of the eight system
                        ; palettes

 AND #%00011100         ; Restrict the result in A to multiples of 4 between 0
 TAX                    ; and 28 and set X to the result
                        ;
                        ; We can now use X as an index into the systemPalettes
                        ; table, as there are eight palettes in the table, each
                        ; of which takes up four bytes

 LDA systemPalettes,X   ; Set the four bytes at XX3+20 to the palette entry from
 STA XX3+20             ; the systemPalettes table that corresponds to the
 LDA systemPalettes+1,X ; current system
 STA XX3+21
 LDA systemPalettes+2,X
 STA XX3+22
 LDA systemPalettes+3,X
 STA XX3+23

.gpal2

 JMP SetPaletteColours  ; Jump to SetPaletteColours to set the view's palette
                        ; from the entries in the XX3 palette table, returning
                        ; from the subroutine using a tail call

.gpal3

                        ; If we get here then the old view type in QQ11a is $00
                        ; (Space view with no fonts loaded), so we now set the
                        ; hidden and visible colours

 LDA XX3                ; Set A to the background colour in the first palette
                        ; entry (which will be black)

 LDY XX3+3              ; Set Y to the foreground colour in the last palette
                        ; entry (which will be cyan)

 LDA hiddenBitplane     ; If the hidden bitplane is 1, jump to gpal4
 BNE gpal4

 STA XX3+1              ; The hidden bitplane is 0, so set the second colour to
 STY XX3+2              ; black and the third colour to cyan, so:
                        ;
                        ;   * Colour %01 (1) is the hidden colour (black)
                        ;
                        ;   * Colour %10 (2) is the visible colour (cyan)

 RTS                    ; Return from the subroutine

.gpal4

 STY XX3+1              ; The hidden bitplane is 1, so set the second colour to
 STA XX3+2              ; cyan and the third colour to black
                        ;
                        ;   * Colour %01 (1) is the visible colour (cyan)
                        ;
                        ;   * Colour %10 (2) is the hidden colour (black)

 RTS                    ; Return from the subroutine

; ******************************************************************************
;
;       Name: FadeColoursTwice
;       Type: Subroutine
;   Category: Drawing the screen
;    Summary: Fade the screen colours towards black twice
;
; ******************************************************************************

.FadeColoursTwice

 JSR FadeColours        ; Call FadeColours to fade the screen colours towards
                        ; black

                        ; Fall through into FadeColours to fade the screen
                        ; colours a second time

; ******************************************************************************
;
;       Name: FadeColours
;       Type: Subroutine
;   Category: Drawing the screen
;    Summary: Fade the screen colours towards black
;  Deep dive: Views and view types in NES Elite
;
; ******************************************************************************

.FadeColours

                        ; We are about to go through 31 entries in the colour
                        ; palette at XX3, fading each colour in turn (and
                        ; ignoring the first entry, which is already black)

 LDX #31                ; Set an index counter in X

.fade1

 LDY XX3,X              ; Set Y to the X-th colour from the palette

 LDA fadeColours,Y      ; Fetch a faded version of colour Y from the fadeColours
 STA XX3,X              ; table and store it back in the same location in XX3

 DEX                    ; Decrement the counter in X

 BNE fade1              ; Loop back until we have faded all 31 colours

                        ; Fall through into SetPaletteColours to set the view's
                        ; palette to the now-faded colours from the XX3 table

; ******************************************************************************
;
;       Name: SetPaletteColours
;       Type: Subroutine
;   Category: Drawing the screen
;    Summary: Set the view's palette from the entries in the XX3 palette table
;
; ******************************************************************************

.SetPaletteColours

 LDA #$0F               ; Set hiddenColour to $0F, which is the HSV value for
 STA hiddenColour       ; black, so this hides any pixels that use the hidden
                        ; colour in palette 0

                        ; In the following we check the view type in QQ11a,
                        ; which contains the old view (if we are changing views)
                        ; or the current view (if we aren't changing views)
                        ;
                        ; This ensures that we set the palette for the old view
                        ; so that it fades away correctly when changing views

 LDA QQ11a              ; If the old view type in QQ11a has bit 7 clear, then it
 BPL pale1              ; has a dashboard, so jump to pale1

 CMP #$C4               ; If the old view type in QQ11a is $C4 (Game Over
 BEQ pale1              ; screen), jump to pale1

 CMP #$98               ; If the old view type in QQ11a is $98 (Status Mode),
 BEQ pale2              ; jump to pale2

 LDA XX3+21             ; Set the palette to entries 21 to 23 from the XX3
 STA visibleColour      ; table, which contain the palette for the current
 LDA XX3+22             ; system (so this caters for the Data on System view)
 STA paletteColour2
 LDA XX3+23
 STA paletteColour3

 RTS                    ; Return from the subroutine

.pale1

                        ; If we get here then the view either has a dashboard or
                        ; it is the Game Over screen

 LDA XX3+3              ; Set the visible colour to entry 3 from the XX3 table,
 STA visibleColour      ; which is the visible colour for the space view and
                        ; Game Over screen

 RTS                    ; Return from the subroutine

.pale2

                        ; If we get here then the view is the Status Mode

 LDA XX3+1              ; Set the palette to entries 1 to 3 from the XX3 table,
 STA visibleColour      ; which contains the palette for the commander image (so
 LDA XX3+2              ; this caters for the Status Mode view)
 STA paletteColour2
 LDA XX3+3
 STA paletteColour3

 RTS                    ; Return from the subroutine

; ******************************************************************************
;
;       Name: FadeToBlack
;       Type: Subroutine
;   Category: Drawing the screen
;    Summary: Fade the screen to black over the next four VBlanks
;  Deep dive: Views and view types in NES Elite
;
; ******************************************************************************

.FadeToBlack

 LDA QQ11a              ; If the old view type in QQ11a is $FF (Segue screen
 CMP #$FF               ; from Title screen to Demo) then jump to ftob1 to skip
 BEQ ftob1              ; the fading process, as the screen is already faded

 LDA screenFadedToBlack ; If bit 7 of screenFadedToBlack is set then we have
 BMI ftob1              ; already faded the screen to black, so jump to ftob1 to
                        ; skip the fading process

                        ; If we get here then we want to fade the screen to
                        ; black

 JSR WaitForPPUToFinish ; Wait until both bitplanes of the screen have been
                        ; sent to the PPU, so the screen is fully updated and
                        ; there is no more data waiting to be sent to the PPU

 JSR WaitForNMI         ; Wait until the next NMI interrupt has passed (i.e. the
                        ; next VBlank)

 JSR GetViewPalettes    ; Get the palette for the view type in QQ11a and store
                        ; it in a table at XX3

 DEC updatePaletteInNMI ; Decrement updatePaletteInNMI to a non-zero value so we
                        ; do send palette data from XX3 to the PPU during NMI,
                        ; which will ensure the screen updates with the colours
                        ; as we fade to black

 JSR FadeColours        ; Fade the screen colours one step towards black

 JSR WaitFor2NMIs       ; Wait until two NMI interrupts have passed (i.e. the
                        ; next two VBlanks)

 JSR FadeColours        ; Fade the screen colours a second step towards black

 JSR WaitFor2NMIs       ; Wait until two NMI interrupts have passed (i.e. the
                        ; next two VBlanks)

 JSR FadeColours        ; Fade the screen colours a third step towards black

 JSR WaitFor2NMIs       ; Wait until two NMI interrupts have passed (i.e. the
                        ; next two VBlanks)

 JSR FadeColours        ; Fade the screen colours a fourth and final step
                        ; towards black, which is guaranteed to fade the screen
                        ; all the way to black as each colour only has four
                        ; brightness levels (stored as the value part of the
                        ; colour in bits 4 and 5)

 JSR WaitFor2NMIs       ; Wait until two NMI interrupts have passed (i.e. the
                        ; next two VBlanks)

 INC updatePaletteInNMI ; Increment updatePaletteInNMI back to the value it had
                        ; before we decremented it above

.ftob1

 LDA #$FF               ; Set bit 7 of screenFadedToBlack to indicate that we
 STA screenFadedToBlack ; have faded the screen to black

 RTS                    ; Return from the subroutine

; ******************************************************************************
;
;       Name: FadeToColour
;       Type: Subroutine
;   Category: Drawing the screen
;    Summary: Reverse-fade the screen from black to full colour over the next
;             four VBlanks
;  Deep dive: Views and view types in NES Elite
;
; ******************************************************************************

.FadeToColour

 JSR WaitForNMI         ; Wait until the next NMI interrupt has passed (i.e. the
                        ; next VBlank)

 JSR GetViewPalettes    ; Get the palette for the view type in QQ11a and store
                        ; it in a table at XX3

 JSR FadeColoursTwice   ; Fade the screen colours two steps towards black

 JSR FadeColours        ; Fade the screen colours a third step towards black, so
                        ; the palette in XX3 is now one step brighter than full
                        ; black (as it takes four steps to fully black-out the
                        ; normal palette)

 DEC updatePaletteInNMI ; Decrement updatePaletteInNMI to a non-zero value so we
                        ; do send palette data from XX3 to the PPU during NMI,
                        ; which will ensure the screen updates with the colours
                        ; as we reverse the back to full colour

 JSR WaitFor2NMIs       ; Wait until two NMI interrupts have passed (i.e. the
                        ; next two VBlanks)

 JSR GetViewPalettes    ; Get the palette for the view type in QQ11a and store
                        ; it in a table at XX3

 JSR FadeColoursTwice   ; Fade the screen colours two steps towards black, so
                        ; the palette in XX3 is now two steps brighter than full
                        ; black

 JSR WaitFor2NMIs       ; Wait until two NMI interrupts have passed (i.e. the
                        ; next two VBlanks)

 JSR GetViewPalettes    ; Get the palette for the view type in QQ11a and store
                        ; it in a table at XX3

 JSR FadeColours        ; Fade the screen colours one step towards black, so the
                        ; palette in XX3 is now three steps brighter than full
                        ; black

 JSR WaitFor2NMIs       ; Wait until two NMI interrupts have passed (i.e. the
                        ; next two VBlanks)

 JSR GetViewPalettes    ; Get the palette for the view type in QQ11a and store
                        ; it in a table at XX3

 JSR SetPaletteColours  ; Set the view's palette from the entries in the XX3
                        ; palette table, so the screen is now at full brightness
                        ; once again

 JSR WaitForNMI         ; Wait until the next NMI interrupt has passed (i.e. the
                        ; next VBlank)

 INC updatePaletteInNMI ; Increment updatePaletteInNMI back to the value it had
                        ; before we decremented it above

 LSR screenFadedToBlack ; Clear bit 7 of screenFadedToBlack to indicate that the
                        ; screen has faded back up to full colour

 RTS                    ; Return from the subroutine

; ******************************************************************************
;
;       Name: systemPalettes
;       Type: Variable
;   Category: Universe
;    Summary: Palettes for the system images
;
; ******************************************************************************

.systemPalettes

 EQUB $0F, $25, $16, $15    ; Palette 0, as used for Lave

 EQUB $0F, $35, $16, $25    ; Palette 1, as used for Diso

 EQUB $0F, $34, $04, $14    ; Palette 2, as used for Zaonce

 EQUB $0F, $27, $28, $17    ; Palette 3, as used for Leesti

 EQUB $0F, $29, $2C, $19    ; Palette 4, as used for Onrira

 EQUB $0F, $2A, $1B, $0A    ; Palette 5, as used for Reorte

 EQUB $0F, $32, $21, $02    ; Palette 6, as used for Uszaa

 EQUB $0F, $2C, $22, $1C    ; Palette 7, as used for Orerve

; ******************************************************************************
;
;       Name: viewAttrCount
;       Type: Variable
;   Category: Drawing the screen
;    Summary: The number of sets of view attributes in the viewAttrOffset table
;
; ******************************************************************************

.viewAttrCount

 EQUW 24

; ******************************************************************************
;
;       Name: viewAttrOffset
;       Type: Variable
;   Category: Drawing the screen
;    Summary: Offset to the data for each of the 24 sets of view attributes
;
; ******************************************************************************

.viewAttrOffset

 EQUW viewAttributes0 - viewAttrCount
 EQUW viewAttributes1 - viewAttrCount
 EQUW viewAttributes2 - viewAttrCount
 EQUW viewAttributes3 - viewAttrCount
 EQUW viewAttributes4 - viewAttrCount
 EQUW viewAttributes5 - viewAttrCount
 EQUW viewAttributes6 - viewAttrCount
 EQUW viewAttributes7 - viewAttrCount
 EQUW viewAttributes8 - viewAttrCount
 EQUW viewAttributes9 - viewAttrCount
 EQUW viewAttributes10 - viewAttrCount
 EQUW viewAttributes11 - viewAttrCount
 EQUW viewAttributes12 - viewAttrCount
 EQUW viewAttributes13 - viewAttrCount
 EQUW viewAttributes14 - viewAttrCount
 EQUW viewAttributes15 - viewAttrCount
 EQUW viewAttributes16 - viewAttrCount
 EQUW viewAttributes17 - viewAttrCount
 EQUW viewAttributes18 - viewAttrCount
 EQUW viewAttributes19 - viewAttrCount
 EQUW viewAttributes20 - viewAttrCount
 EQUW viewAttributes21 - viewAttrCount
 EQUW viewAttributes22 - viewAttrCount
 EQUW viewAttributes23 - viewAttrCount

; ******************************************************************************
;
;       Name: viewAttributes0
;       Type: Variable
;   Category: Drawing the screen
;    Summary: Packed view attribute data for attribute set 0
;
; ------------------------------------------------------------------------------
;
; When unpacked, the PPU attributes for this view's screen are as follows:
;
;   3F 0F 0F 0F 0F 0F 0F 0F
;   33 00 00 00 00 00 00 00
;   33 00 00 00 00 00 00 00
;   33 00 00 00 00 00 00 00
;   33 00 00 00 00 00 00 00
;   FF BF AF AF AF AB AB AE
;   77 99 AA AA AA AA AA 5A
;   07 09 0A 0A 0A 0A 0A 0F
;
; ******************************************************************************

.viewAttributes0

 EQUB $31, $3F, $27, $0F, $21, $33, $07, $21
 EQUB $33, $07, $21, $33, $07, $21, $33, $07
 EQUB $FF, $BF, $23, $AF, $22, $AB, $AE, $77
 EQUB $99, $25, $AA, $5A, $32, $07, $09, $25
 EQUB $0A, $21, $0F, $3F

; ******************************************************************************
;
;       Name: viewAttributes1
;       Type: Variable
;   Category: Drawing the screen
;    Summary: Packed view attribute data for attribute set 1
;
; ------------------------------------------------------------------------------
;
; When unpacked, the PPU attributes for this view's screen are as follows:
;
;   3F 0F 0F 0F 0F 0F 0F 0F
;   33 00 00 00 00 00 00 00
;   33 00 00 00 00 00 00 00
;   33 00 00 00 00 00 00 00
;   33 00 00 00 00 00 00 00
;   FF FF AF AF AF AF AF AF
;   77 DD AA AA AA AA AA 5A
;   07 0D 0F 0F 0F 0F 0E 05
;
; ******************************************************************************

.viewAttributes1

 EQUB $31, $3F, $27, $0F, $21, $33, $07, $21
 EQUB $33, $07, $21, $33, $07, $21, $33, $07
 EQUB $12, $26, $AF, $77, $DD, $25, $AA, $5A
 EQUB $32, $07, $0D, $24, $0F, $32, $0E, $05
 EQUB $3F

; ******************************************************************************
;
;       Name: viewAttributes2
;       Type: Variable
;   Category: Drawing the screen
;    Summary: Packed view attribute data for attribute set 2
;
; ------------------------------------------------------------------------------
;
; When unpacked, the PPU attributes for this view's screen are as follows:
;
;   FF FF FF FF FF FF FF FF
;   77 55 55 55 55 55 55 55
;   77 55 55 55 55 55 55 55
;   77 55 55 55 55 55 55 55
;   77 55 55 55 55 55 55 55
;   77 55 55 55 55 55 55 55
;   FF FF FF FF FF FF FF FF
;   0F 0F 0F 0F 0F 0F 0F 0F
;
; ******************************************************************************

.viewAttributes2

 EQUB $18, $77, $27, $55, $77, $27, $55, $77
 EQUB $27, $55, $77, $27, $55, $77, $27, $55
 EQUB $18, $28, $0F, $3F

; ******************************************************************************
;
;       Name: viewAttributes3
;       Type: Variable
;   Category: Drawing the screen
;    Summary: Packed view attribute data for attribute set 3
;
; ------------------------------------------------------------------------------
;
; When unpacked, the PPU attributes for this view's screen are as follows:
;
;   FF FF FF FF FF FF FF FF
;   77 55 55 55 55 55 55 55
;   77 55 55 55 55 55 55 55
;   77 55 55 55 55 55 55 55
;   77 55 55 55 55 55 55 55
;   77 55 55 55 55 55 55 55
;   FF FF FF FF FF BF BF EF
;   0F 0F 0F 0F 0F 0B 0B 0E
;
; ******************************************************************************

.viewAttributes3

 EQUB $18, $77, $27, $55, $77, $27, $55, $77
 EQUB $27, $55, $77, $27, $55, $77, $27, $55
 EQUB $15, $22, $BF, $EF, $25, $0F, $22, $0B
 EQUB $21, $0E, $3F

; ******************************************************************************
;
;       Name: viewAttributes4
;       Type: Variable
;   Category: Drawing the screen
;    Summary: Packed view attribute data for attribute set 4
;
; ------------------------------------------------------------------------------
;
; When unpacked, the PPU attributes for this view's screen are as follows:
;
;   3F 0F 0F 0F 0F 0F 0F 0F
;   33 00 00 00 00 00 00 00
;   73 50 50 50 50 50 50 50
;   77 55 55 55 55 55 55 55
;   77 55 55 55 55 55 55 55
;   77 55 55 55 55 55 55 55
;   F7 FD FF FF FF FF FE F5
;   0F 0F 0F 0F 0F 0F 0F 0F
;
; ******************************************************************************

.viewAttributes4

 EQUB $31, $3F, $27, $0F, $21, $33, $07, $73
 EQUB $27, $50, $77, $27, $55, $77, $27, $55
 EQUB $77, $27, $55, $F7, $FD, $14, $FE, $F5
 EQUB $28, $0F, $3F

; ******************************************************************************
;
;       Name: viewAttributes5
;       Type: Variable
;   Category: Drawing the screen
;    Summary: Packed view attribute data for attribute set 5
;
; ------------------------------------------------------------------------------
;
; When unpacked, the PPU attributes for this view's screen are as follows:
;
;   3F 0F 0F 0F 0F 0F 0F 0F
;   33 00 00 00 00 00 00 00
;   33 00 00 00 00 00 00 00
;   33 00 00 00 00 00 00 00
;   33 00 00 00 00 00 00 00
;   33 00 00 00 00 00 00 00
;   33 00 00 00 00 00 00 00
;   0F 0F 0F 0F 0F 0F 0F 0F
;
; ******************************************************************************

.viewAttributes5

 EQUB $31, $3F, $27, $0F, $21, $33, $07, $21
 EQUB $33, $07, $21, $33, $07, $21, $33, $07
 EQUB $21, $33, $07, $21, $33, $07, $28, $0F
 EQUB $3F

; ******************************************************************************
;
;       Name: viewAttributes6
;       Type: Variable
;   Category: Drawing the screen
;    Summary: Packed view attribute data for attribute set 6
;
; ------------------------------------------------------------------------------
;
; When unpacked, the PPU attributes for this view's screen are as follows:
;
;   AF AF AF AF AF AF AF AF
;   77 55 55 55 55 55 55 55
;   77 55 55 55 55 55 55 55
;   77 55 55 55 55 55 55 55
;   77 55 55 55 55 55 55 55
;   77 55 55 55 55 55 55 55
;   FF FF FF FF FF FF FF FF
;   0F 0F 0F 0F 0F 0F 0F 0F
;
; ******************************************************************************

.viewAttributes6

 EQUB $28, $AF, $77, $27, $55, $77, $27, $55
 EQUB $77, $27, $55, $77, $27, $55, $77, $27
 EQUB $55, $18, $28, $0F, $3F

; ******************************************************************************
;
;       Name: viewAttributes7
;       Type: Variable
;   Category: Drawing the screen
;    Summary: Packed view attribute data for attribute set 7
;
; ------------------------------------------------------------------------------
;
; When unpacked, the PPU attributes for this view's screen are as follows:
;
;   AF AF AF AF AF AF AF AF
;   77 5A 5A 5A 5A 5A 5A 5A
;   77 55 55 55 55 55 55 55
;   77 55 55 55 55 55 55 55
;   77 55 55 55 55 55 55 55
;   77 55 55 55 55 55 55 55
;   FF FF FF FF FF FF FF FF
;   0F 0F 0F 0F 0F 0F 0F 0F
;
; ******************************************************************************

.viewAttributes7

 EQUB $28, $AF, $77, $27, $5A, $77, $27, $55
 EQUB $77, $27, $55, $77, $27, $55, $77, $27
 EQUB $55, $18, $28, $0F, $3F

; ******************************************************************************
;
;       Name: viewAttributes8
;       Type: Variable
;   Category: Drawing the screen
;    Summary: Packed view attribute data for attribute set 8
;
; ------------------------------------------------------------------------------
;
; When unpacked, the PPU attributes for this view's screen are as follows:
;
;   AF AF AF AF AF AF AF AF
;   77 55 55 55 55 55 55 55
;   77 55 55 55 55 55 55 55
;   77 55 55 55 55 55 55 55
;   77 55 55 55 55 55 55 55
;   77 55 55 55 55 55 55 55
;   FF FF FF FF FF FF FF FF
;   0F 0F 0F 0F 0F 0F 0F 0F
;
; ******************************************************************************

.viewAttributes8

 EQUB $28, $AF, $77, $27, $55, $77, $27, $55
 EQUB $77, $27, $55, $77, $27, $55, $77, $27
 EQUB $55, $18, $28, $0F, $3F

; ******************************************************************************
;
;       Name: viewAttributes9
;       Type: Variable
;   Category: Drawing the screen
;    Summary: Packed view attribute data for attribute set 9
;
; ------------------------------------------------------------------------------
;
; When unpacked, the PPU attributes for this view's screen are as follows:
;
;   5F 5F 5F 5F 5F 5F 5F 5F
;   77 55 55 55 55 55 55 55
;   77 55 55 55 55 55 55 55
;   77 55 55 55 55 55 55 55
;   77 55 55 55 55 55 55 55
;   BB AA AA AA AA AA AA AA
;   FB FA FA FA FA FA FA FA
;   FF FF FF FF FF FF FF FF
;
; ******************************************************************************

.viewAttributes9

 EQUB $28, $5F, $77, $27, $55, $77, $27, $55
 EQUB $77, $27, $55, $77, $27, $55, $BB, $27
 EQUB $AA, $FB, $27, $FA, $18, $3F

; ******************************************************************************
;
;       Name: viewAttributes10
;       Type: Variable
;   Category: Drawing the screen
;    Summary: Packed view attribute data for attribute set 10
;
; ------------------------------------------------------------------------------
;
; When unpacked, the PPU attributes for this view's screen are as follows:
;
;   0F 0F 0F 5F 5F 5F 5F 5F
;   33 00 04 45 55 55 55 55
;   33 00 00 54 55 99 AA AA
;   33 00 04 55 55 99 AA AA
;   F7 F5 F5 F5 F5 F5 F5 F5
;   FF FF FF FF FF FF FF FF
;   FF FF FF FF FF FF FF FF
;   0F 0F 0F 0F 0F 0F 0F 0F
;
; ******************************************************************************

.viewAttributes10

 EQUB $23, $0F, $25, $5F, $21, $33, $00, $21
 EQUB $04, $45, $24, $55, $21, $33, $02, $54
 EQUB $55, $99, $22, $AA, $21, $33, $00, $21
 EQUB $04, $22, $55, $99, $22, $AA, $F7, $27
 EQUB $F5, $1F, $11, $28, $0F, $3F

; ******************************************************************************
;
;       Name: viewAttributes11
;       Type: Variable
;   Category: Drawing the screen
;    Summary: Packed view attribute data for attribute set 11
;
; ------------------------------------------------------------------------------
;
; When unpacked, the PPU attributes for this view's screen are as follows:
;
;   0F 0F 0F 4F 5F 5F 5F 5F
;   33 00 00 55 55 55 55 55
;   33 00 40 54 55 99 AA AA
;   33 00 04 45 55 99 AA AA
;   FF FF FF FF FF FF FF FF
;   FF FF FF FF FF FF FF FF
;   FF FF FF FF FF FF FF FF
;   0F 0F 0F 0F 0F 0F 0F 0F
;
; ******************************************************************************

.viewAttributes11

 EQUB $23, $0F, $4F, $24, $5F, $21, $33, $02
 EQUB $25, $55, $21, $33, $00, $40, $54, $55
 EQUB $99, $22, $AA, $21, $33, $00, $21, $04
 EQUB $45, $55, $99, $22, $AA, $1F, $19, $28
 EQUB $0F, $3F

; ******************************************************************************
;
;       Name: viewAttributes12
;       Type: Variable
;   Category: Drawing the screen
;    Summary: Packed view attribute data for attribute set 12
;
; ------------------------------------------------------------------------------
;
; When unpacked, the PPU attributes for this view's screen are as follows:
;
;   0F 0F 0F 5F 5F 5F 5F 5F
;   33 00 04 45 55 55 55 55
;   33 00 50 50 55 99 AA AA
;   33 00 04 55 55 99 AA AA
;   FF FF FF FF FF FF FF FF
;   FF FF FF FF FF FF FF FF
;   FF FF FF FF FF FF FF FF
;   FF FF FF FF FF FF FF FF
;
; ******************************************************************************

.viewAttributes12

 EQUB $23, $0F, $25, $5F, $21, $33, $00, $21
 EQUB $04, $45, $24, $55, $21, $33, $00, $22
 EQUB $50, $55, $99, $22, $AA, $21, $33, $00
 EQUB $21, $04, $22, $55, $99, $22, $AA, $1F
 EQUB $1F, $12, $3F

; ******************************************************************************
;
;       Name: viewAttributes13
;       Type: Variable
;   Category: Drawing the screen
;    Summary: Packed view attribute data for attribute set 13
;
; ------------------------------------------------------------------------------
;
; When unpacked, the PPU attributes for this view's screen are as follows:
;
;   AF AF AF 5F 5F 5F 5F 5F
;   BB AA AA 5A 5A 55 55 55
;   BB AA A5 A5 55 55 00 00
;   FB FA FA FA FA FF 00 00
;   FF FF FF FF FF FF F0 F0
;   FF FF FF FF FF FF FF FF
;   FF FF FF FF FF FF FF FF
;   FF FF FF FF FF FF FF FF
;
; ******************************************************************************

.viewAttributes13

 EQUB $23, $AF, $25, $5F, $BB, $22, $AA, $22
 EQUB $5A, $23, $55, $BB, $AA, $22, $A5, $22
 EQUB $55, $02, $FB, $24, $FA, $FF, $02, $16
 EQUB $22, $F0, $1F, $19, $3F

; ******************************************************************************
;
;       Name: viewAttributes14
;       Type: Variable
;   Category: Drawing the screen
;    Summary: Packed view attribute data for attribute set 14
;
; ------------------------------------------------------------------------------
;
; When unpacked, the PPU attributes for this view's screen are as follows:
;
;   AF AF AF AF AF 5F 5F 5F
;   BB AA 6A 5A 5A 5A 55 55
;   BB AA AA 65 55 55 00 00
;   FB FA FA FA FA FF 00 00
;   FF FF FF FF FF FF F0 F0
;   FF FF FF FF FF FF FF FF
;   FF FF FF FF FF FF FF FF
;   0F 0F 0F 0F 0F 0F 0F 0F
;
; ******************************************************************************

.viewAttributes14

 EQUB $25, $AF, $23, $5F, $BB, $AA, $6A, $23
 EQUB $5A, $22, $55, $BB, $22, $AA, $65, $22
 EQUB $55, $02, $FB, $24, $FA, $FF, $02, $16
 EQUB $22, $F0, $1F, $11, $28, $0F, $3F

; ******************************************************************************
;
;       Name: viewAttributes15
;       Type: Variable
;   Category: Drawing the screen
;    Summary: Packed view attribute data for attribute set 15
;
; ------------------------------------------------------------------------------
;
; When unpacked, the PPU attributes for this view's screen are as follows:
;
;   AF AF AF 6F 5F 5F 5F 5F
;   BB AA AA AA 5A 56 55 55
;   BB AA 6A 56 55 55 05 05
;   FB FA FA FA FA FF 00 00
;   FF FF FF FF FF FF 00 00
;   FF FF FF FF FF FF FF FF
;   FF FF FF FF FF FF FF FF
;   FF FF FF FF FF FF FF FF
;
; ******************************************************************************

.viewAttributes15

 EQUB $23, $AF, $6F, $24, $5F, $BB, $23, $AA
 EQUB $5A, $56, $22, $55, $BB, $AA, $6A, $56
 EQUB $22, $55, $22, $05, $FB, $24, $FA, $FF
 EQUB $02, $16, $02, $1F, $19, $3F

; ******************************************************************************
;
;       Name: viewAttributes16
;       Type: Variable
;   Category: Drawing the screen
;    Summary: Packed view attribute data for attribute set 16
;
; ------------------------------------------------------------------------------
;
; When unpacked, the PPU attributes for this view's screen are as follows:
;
;   FF FF FF FF FF FF FF FF
;   73 50 50 A0 A0 60 50 50
;   77 00 99 AA AA 66 55 55
;   73 50 50 AA AA 66 55 55
;   77 55 99 AA AA 66 55 55
;   37 05 09 AA AA A6 A5 A5
;   F3 F0 F0 FA FA FA FA FF
;   FF FF FF FF FF FF FF FF
;
; ******************************************************************************

.viewAttributes16

 EQUB $18, $73, $22, $50, $22, $A0, $60, $22
 EQUB $50, $77, $00, $99, $22, $AA, $66, $22
 EQUB $55, $73, $22, $50, $22, $AA, $66, $22
 EQUB $55, $77, $55, $99, $22, $AA, $66, $22
 EQUB $55, $33, $37, $05, $09, $22, $AA, $A6
 EQUB $22, $A5, $F3, $22, $F0, $24, $FA, $19
 EQUB $3F

; ******************************************************************************
;
;       Name: viewAttributes17
;       Type: Variable
;   Category: Drawing the screen
;    Summary: Packed view attribute data for attribute set 17
;
; ------------------------------------------------------------------------------
;
; When unpacked, the PPU attributes for this view's screen are as follows:
;
;   FF FF FF FF FF FF FF FF
;   73 50 50 A0 A0 60 50 50
;   77 00 99 AA AA 66 55 55
;   73 50 50 AA AA 66 55 55
;   77 55 99 AA AA 66 55 55
;   37 05 09 8A AA A6 A5 A5
;   F3 F0 F0 F8 FA FA FA FF
;   FF FF FF FF FF FF FF FF
;
; ******************************************************************************

.viewAttributes17

 EQUB $18, $73, $22, $50, $22, $A0, $60, $22
 EQUB $50, $77, $00, $99, $22, $AA, $66, $22
 EQUB $55, $73, $22, $50, $22, $AA, $66, $22
 EQUB $55, $77, $55, $99, $22, $AA, $66, $22
 EQUB $55, $33, $37, $05, $09, $8A, $AA, $A6
 EQUB $22, $A5, $F3, $22, $F0, $F8, $23, $FA
 EQUB $19, $3F

; ******************************************************************************
;
;       Name: viewAttributes18
;       Type: Variable
;   Category: Drawing the screen
;    Summary: Packed view attribute data for attribute set 18
;
; ------------------------------------------------------------------------------
;
; When unpacked, the PPU attributes for this view's screen are as follows:
;
;   FF FF FF FF FF FF FF FF
;   73 50 50 A0 A0 60 50 50
;   77 00 99 AA AA 66 55 55
;   73 50 50 AA AA 66 55 55
;   77 55 99 AA AA 66 55 55
;   37 05 09 8A AA A6 A5 A5
;   F3 F0 F0 F8 FA FA FA FF
;   FF FF FF FF FF FF FF FF
;
; ******************************************************************************

.viewAttributes18

 EQUB $18, $73, $22, $50, $22, $A0, $60, $22
 EQUB $50, $77, $00, $99, $22, $AA, $66, $22
 EQUB $55, $73, $22, $50, $22, $AA, $66, $22
 EQUB $55, $77, $55, $99, $22, $AA, $66, $22
 EQUB $55, $33, $37, $05, $09, $8A, $AA, $A6
 EQUB $22, $A5, $F3, $22, $F0, $F8, $23, $FA
 EQUB $19, $3F

; ******************************************************************************
;
;       Name: viewAttributes19
;       Type: Variable
;   Category: Drawing the screen
;    Summary: Packed view attribute data for attribute set 19
;
; ------------------------------------------------------------------------------
;
; When unpacked, the PPU attributes for this view's screen are as follows:
;
;   AF 5F 5F 5F 5F 5F 5F 5F
;   FB FA F5 F5 F5 F5 F5 F5
;   FF FF FF FF FF FF FF FF
;   FF FF FF FF FF FF FF FF
;   FF FF FF FF FF FF FF FF
;   FF FF FF FF FF FF FF FF
;   FF FF FF FF FF FF FF FF
;   0F 0F 0F 0F 0F 0F 0F 0F
;
; ******************************************************************************

.viewAttributes19

 EQUB $AF, $27, $5F, $FB, $FA, $26, $F5, $1F
 EQUB $1F, $1A, $28, $0F, $3F

; ******************************************************************************
;
;       Name: viewAttributes20
;       Type: Variable
;   Category: Drawing the screen
;    Summary: Packed view attribute data for attribute set 20
;
; ------------------------------------------------------------------------------
;
; When unpacked, the PPU attributes for this view's screen are as follows:
;
;   AF AF AF 5F 5F 5F 5F 5F
;   FB FA FA F5 F5 F5 F5 F5
;   FF FF FF FF FF FF FF FF
;   FF FF FF FF FF FF FF FF
;   FF FF FF FF FF FF FF FF
;   FF FF FF FF FF FF FF FF
;   FF FF FF FF FF FF FF FF
;   0F 0F 0F 0F 0F 0F 0F 0F
;
; ******************************************************************************

.viewAttributes20

 EQUB $23, $AF, $25, $5F, $FB, $22, $FA, $25
 EQUB $F5, $1F, $1F, $1A, $28, $0F, $3F

; ******************************************************************************
;
;       Name: viewAttributes21
;       Type: Variable
;   Category: Drawing the screen
;    Summary: Packed view attribute data for attribute set 21
;
; ------------------------------------------------------------------------------
;
; When unpacked, the PPU attributes for this view's screen are as follows:
;
;   AF AF 6F 5F 5F 5F 5F 5F
;   FB FA F6 F5 F5 F5 F5 F5
;   FF FF FF FF FF FF FF FF
;   FF FF FF FF FF FF FF FF
;   FF FF FF FF FF FF FF FF
;   FF FF FF FF FF FF FF FF
;   FF FF FF FF FF FF FF FF
;   0F 0F 0F 0F 0F 0F 0F 0F
;
; ******************************************************************************

.viewAttributes21

 EQUB $22, $AF, $6F, $25, $5F, $FB, $FA, $F6
 EQUB $25, $F5, $1F, $1F, $1A, $28, $0F, $3F

; ******************************************************************************
;
;       Name: viewAttributes22
;       Type: Variable
;   Category: Drawing the screen
;    Summary: Packed view attribute data for attribute set 22
;
; ------------------------------------------------------------------------------
;
; When unpacked, the PPU attributes for this view's screen are as follows:
;
;   3F 0F 0F 0F 0F 0F 0F 0F
;   33 00 00 00 00 00 00 00
;   33 00 00 00 00 00 00 00
;   33 00 00 00 00 00 00 00
;   33 00 00 00 00 00 00 00
;   33 00 00 00 00 00 00 00
;   FF FF FF FF FF FF FF FF
;   0F 0F 0F 0F 0F 0F 0F 0F
;
; ******************************************************************************

.viewAttributes22

 EQUB $31, $3F, $27, $0F, $21, $33, $07, $21
 EQUB $33, $07, $21, $33, $07, $21, $33, $07
 EQUB $21, $33, $07, $18, $28, $0F, $3F

; ******************************************************************************
;
;       Name: viewAttributes23
;       Type: Variable
;   Category: Drawing the screen
;    Summary: Packed view attribute data for attribute set 23
;
; ------------------------------------------------------------------------------
;
; When unpacked, the PPU attributes for this view's screen are as follows:
;
;   3F 0F 0F 0F 0F 0F 0F 0F
;   33 00 00 00 00 00 00 00
;   33 00 00 00 00 00 00 00
;   33 00 00 00 00 00 00 00
;   33 00 00 00 00 00 00 00
;   F3 F0 F0 F0 F0 F0 F0 F0
;   FB 5A 5A 5A 5A 5A 5A 5A
;   0F 0F 0F 0F 0F 0F 0F 0F
;
; ******************************************************************************

.viewAttributes23

 EQUB $31, $3F, $27, $0F, $21, $33, $07, $21
 EQUB $33, $07, $21, $33, $07, $21, $33, $07
 EQUB $F3, $27, $F0, $FB, $27, $5A, $28, $0F
 EQUB $3F

; ******************************************************************************
;
;       Name: viewAttributes_EN
;       Type: Variable
;   Category: Drawing the screen
;    Summary: The view attributes to use for each view type in English
;  Deep dive: Multi-language support in NES Elite
;
; ******************************************************************************

.viewAttributes_EN

 EQUB  0                ; 0  = Space view
 EQUB  1                ; 1  = Title screen
 EQUB 22                ; 2  = Mission 1 briefing: rotating ship
 EQUB  4                ; 3  = Mission 1 briefing: ship and text
 EQUB  5                ; 4  = Game Over screen
 EQUB  2                ; 5  = Text-based mission briefing
 EQUB 10                ; 6  = Data on System
 EQUB 19                ; 7  = Inventory
 EQUB 13                ; 8  = Status Mode
 EQUB  9                ; 9  = Equip Ship
 EQUB  6                ; 10 = Market Price
 EQUB 16                ; 11 = Save and Load
 EQUB  3                ; 12 = Short-range Chart
 EQUB  3                ; 13 = Long-range Chart
 EQUB  2                ; 14 = Unused
 EQUB 23                ; 15 = Start screen

; ******************************************************************************
;
;       Name: viewAttributes_DE
;       Type: Variable
;   Category: Drawing the screen
;    Summary: The view attributes to use for each view type in German
;  Deep dive: Multi-language support in NES Elite
;
; ******************************************************************************

.viewAttributes_DE

 EQUB  0                ; 0  = Space view
 EQUB  1                ; 1  = Title screen
 EQUB 22                ; 2  = Mission 1 briefing: rotating ship
 EQUB  4                ; 3  = Mission 1 briefing: ship and text
 EQUB  5                ; 4  = Game Over screen
 EQUB  2                ; 5  = Text-based mission briefing
 EQUB 11                ; 6  = Data on System
 EQUB 20                ; 7  = Inventory
 EQUB 14                ; 8  = Status Mode
 EQUB  9                ; 9  = Equip Ship
 EQUB  7                ; 10 = Market Price
 EQUB 17                ; 11 = Save and Load
 EQUB  3                ; 12 = Short-range Chart
 EQUB  3                ; 13 = Long-range Chart
 EQUB  2                ; 14 = Unused
 EQUB  2                ; 15 = Start screen

; ******************************************************************************
;
;       Name: viewAttributes_FR
;       Type: Variable
;   Category: Drawing the screen
;    Summary: The view attributes to use for each view type in French
;  Deep dive: Multi-language support in NES Elite
;
; ******************************************************************************

.viewAttributes_FR

 EQUB  0                ; 0  = Space view
 EQUB  1                ; 1  = Title screen
 EQUB 22                ; 2  = Mission 1 briefing: rotating ship
 EQUB  4                ; 3  = Mission 1 briefing: ship and text
 EQUB  5                ; 4  = Game Over screen
 EQUB  2                ; 5  = Text-based mission briefing
 EQUB 12                ; 6  = Data on System
 EQUB 21                ; 7  = Inventory
 EQUB 15                ; 8  = Status Mode
 EQUB  9                ; 9  = Equip Ship
 EQUB  8                ; 10 = Market Price
 EQUB 18                ; 11 = Save and Load
 EQUB  3                ; 12 = Short-range Chart
 EQUB  3                ; 13 = Long-range Chart
 EQUB  2                ; 14 = Unused
 EQUB 23                ; 15 = Start screen

; ******************************************************************************
;
;       Name: viewAttributesLo
;       Type: Variable
;   Category: Drawing the screen
;    Summary: The low byte of the view attributes lookup table for each language
;  Deep dive: Multi-language support in NES Elite
;
; ******************************************************************************

.viewAttributesLo

 EQUB LO(viewAttributes_EN)     ; English

 EQUB LO(viewAttributes_DE)     ; German

 EQUB LO(viewAttributes_FR)     ; French

 EQUB LO(viewAttributes_EN)     ; There is no fourth language, so this byte is
                                ; ignored

; ******************************************************************************
;
;       Name: viewAttributesHi
;       Type: Variable
;   Category: Drawing the screen
;    Summary: The high byte of the view attributes lookup table for each
;             language
;  Deep dive: Multi-language support in NES Elite
;
; ******************************************************************************

.viewAttributesHi

 EQUB HI(viewAttributes_EN)     ; English

 EQUB HI(viewAttributes_DE)     ; German

 EQUB HI(viewAttributes_FR)     ; French

 EQUB HI(viewAttributes_EN)     ; There is no fourth language, so this byte is
                                ; ignored

; ******************************************************************************
;
;       Name: SetViewAttrs
;       Type: Subroutine
;   Category: Drawing the screen
;    Summary: Set up attribute buffer 0 for the chosen view
;
; ******************************************************************************

.SetViewAttrs

 LDX languageIndex      ; Set X to the index of the chosen language

 LDA viewAttributesLo,X ; Set V(1 0) = viewAttributes_EN, _FR or _DE, according
 STA V                  ; to the chosen language
 LDA viewAttributesHi,X
 STA V+1

 LDA QQ11               ; Set Y to the low nibble of the view type, which is
 AND #$0F               ; the view type with the flags stripped off (so it's
 TAY                    ; in the range 0 to 15)

 LDA (V),Y              ; Set X to the Y-th entry from the viewAttributes_XX
 ASL A                  ; table for the chosen language, which contains the
 TAX                    ; number of the set of view attributes that we need to
                        ; apply to this view

 LDA viewAttrOffset,X   ; Set V(1 0) viewAttrOffset for set X + viewAttrCount
 ADC #LO(viewAttrCount) ;
 STA V                  ; So V(1 0) points to viewAttrributes0 when X = 0,
 LDA viewAttrOffset+1,X ; viewAttrributes1 when X = 1, and so on up to
 ADC #HI(viewAttrCount) ; viewAttrributes23 when X = 23
 STA V+1

 LDA #HI(attrBuffer0)   ; Set SC(1 0) to the address of attribute buffer 0
 STA SC+1
 LDA #LO(attrBuffer0)
 STA SC

 JMP UnpackToRAM        ; Unpack the data at V(1 0) into SC(1 0), updating
                        ; V(1 0) as we go
                        ;
                        ; SC(1 0) is attribute buffer 0, so this unpacks the set
                        ; of view attributes for the view in QQ11 into attribute
                        ; buffer 0
                        ;
                        ; We then return from the subroutine using a tail call

; ******************************************************************************
;
;       Name: HideSightSprites
;       Type: Subroutine
;   Category: Flight
;    Summary: Hide the sprites for the laser sights in the space view
;
; ******************************************************************************

.HideSightSprites

 LDA #240               ; Set A to the y-coordinate that's just below the bottom
                        ; of the screen, so we can hide the sight sprites by
                        ; moving them off-screen

 STA ySprite5           ; Set the y-coordinates for the five laser sight sprites
 STA ySprite6           ; to 240, to move them off-screen
 STA ySprite7
 STA ySprite8
 STA ySprite9

 RTS                    ; Return from the subroutine

; ******************************************************************************
;
;       Name: SIGHT
;       Type: Subroutine
;   Category: Flight
;    Summary: Draw the laser crosshairs
;  Deep dive: Sprite usage in NES Elite
;
; ******************************************************************************

.SIGHT

 LDY VIEW               ; Fetch the laser power for the current view
 LDA LASER,Y

 BEQ HideSightSprites   ; If it is zero (i.e. there is no laser fitted to this
                        ; view), jump to HideSightSprites to hide the sight
                        ; sprites and return from the subroutine using a tail
                        ; call

 CMP #POW+9             ; If the laser power in A is not equal to a pulse laser,
 BNE sigh1              ; jump to sigh1 to process the other laser types

 JMP sigh4              ; The laser is a pulse laser, so jump to sigh4 to draw
                        ; the sights for a pulse laser

.sigh1

 CMP #POW+128           ; If the laser power in A is not equal to a beam laser,
 BNE sigh2              ; jump to sigh2 to process the other laser types

 JMP sigh5              ; The laser is a beam laser, so jump to sigh4 to draw
                        ; the sights for a beam laser

.sigh2

 CMP #Armlas            ; If the laser power in A is not equal to a military
 BNE sigh3              ; laser, jump to sigh3 to draw the sights for a mining
                        ; laser

                        ; The laser is a military laser, so we draw the military
                        ; laser sights with a sprite for each of the left,
                        ; right, top and bottom sights

 LDA #%10000000         ; Set the attributes for sprite 8 (for the bottom sight)
 STA attrSprite8        ; as follows:
                        ;
                        ;   * Bits 0-1    = sprite palette 0
                        ;   * Bit 5 clear = show in front of background
                        ;   * Bit 6 clear = do not flip horizontally
                        ;   * Bit 7 set   = flip vertically

 LDA #%01000000         ; Set the attributes for sprite 6 (for the right sight)
 STA attrSprite6        ; as follows:
                        ;
                        ;   * Bits 0-1    = sprite palette 0
                        ;   * Bit 5 clear = show in front of background
                        ;   * Bit 6 set   = flip horizontally
                        ;   * Bit 7 clear = do not flip vertically

 LDA #%00000000         ; Set the attributes for sprites 5 and 7 (for the left
 STA attrSprite7        ; and top sights respectively) as follows:
 STA attrSprite5        ;
                        ;   * Bits 0-1    = sprite palette 0
                        ;   * Bit 5 clear = show in front of background
                        ;   * Bit 6 clear = do not flip horizontally
                        ;   * Bit 7 clear = do not flip vertically

 LDY #207               ; Set the pattern number for sprites 5 and 6 to 207,
 STY pattSprite5        ; for the left and right sights respectively
 STY pattSprite6

 INY                    ; Set the pattern number for sprites 7 and 8 to 208,
 STY pattSprite7        ; for the top and bottom sights respectively
 STY pattSprite8

 LDA #118               ; Position the sprites as follows:
 STA xSprite5           ;
 LDA #134               ;   * Sprite 5 at (118, 83) for the left sight
 STA xSprite6           ;   * Sprite 6 at (134, 83) for the right sight
 LDA #126               ;   * Sprite 7 at (126, 75) for the top sight
 STA xSprite7           ;   * Sprite 8 at (126, 91) for the bottom sight
 STA xSprite8
 LDA #83+YPAL
 STA ySprite5
 STA ySprite6
 LDA #75+YPAL
 STA ySprite7
 LDA #91+YPAL
 STA ySprite8

 RTS                    ; Return from the subroutine

.sigh3

                        ; The laser is a mining laser, so we draw the mining
                        ; laser sights with a sprite for each of the top-left,
                        ; top-right, bottom-left and bottom-right sights

 LDA #%00000011         ; Set the attributes for sprite 5 (for the top-left
 STA attrSprite5        ; sight) as follows:
                        ;
                        ;   * Bits 0-1    = sprite palette 3
                        ;   * Bit 5 clear = show in front of background
                        ;   * Bit 6 clear = do not flip horizontally
                        ;   * Bit 7 clear = do not flip vertically

 LDA #%01000011         ; Set the attributes for sprite 6 (for the top-right
 STA attrSprite6        ; sight) as follows:
                        ;
                        ;   * Bits 0-1    = sprite palette 3
                        ;   * Bit 5 clear = show in front of background
                        ;   * Bit 6 set   = flip horizontally
                        ;   * Bit 7 clear = do not flip vertically

 LDA #%10000011         ; Set the attributes for sprite 7 (for the bottom-left
 STA attrSprite7        ; sight) as follows:
                        ;
                        ;   * Bits 0-1    = sprite palette 3
                        ;   * Bit 5 clear = show in front of background
                        ;   * Bit 6 clear = do not flip horizontally
                        ;   * Bit 7 set   = flip vertically

 LDA #%11000011         ; Set the attributes for sprite 8 (for the bottom-right
 STA attrSprite8        ; sight) as follows:
                        ;
                        ;   * Bits 0-1    = sprite palette 0
                        ;   * Bit 5 clear = show in front of background
                        ;   * Bit 6 set   = flip horizontally
                        ;   * Bit 7 set   = flip vertically

 LDA #209               ; Set the pattern number for all four sprites to 209
 STA pattSprite5
 STA pattSprite6
 STA pattSprite7
 STA pattSprite8

 LDA #118               ; Position the sprites as follows:
 STA xSprite5           ;
 STA xSprite7           ;   * Sprite 5 at (118, 75) for the top-left sight
 LDA #134               ;   * Sprite 6 at (134, 75) for the top-right sight
 STA xSprite6           ;   * Sprite 7 at (118, 91) for the bottom-left sight
 STA xSprite8           ;   * Sprite 8 at (134, 91) for the bottom-right sight
 LDA #75+YPAL
 STA ySprite5
 STA ySprite6
 LDA #91+YPAL
 STA ySprite7
 STA ySprite8

 RTS                    ; Return from the subroutine

.sigh4

                        ; The laser is a pulse laser, so we draw the pulse laser
                        ; sights with a sprite for each of the left, right, top
                        ; and bottom sights

 LDA #%00000001         ; Set the attributes for all four sprites as follows:
 LDY #$CC               ;
 STA attrSprite5        ;   * Bits 0-1    = sprite palette 1
 STA attrSprite6        ;   * Bit 5 clear = show in front of background
 STA attrSprite7        ;   * Bit 6 clear = do not flip horizontally
 STA attrSprite8        ;   * Bit 7 clear = do not flip vertically

 STY pattSprite5        ; Set the pattern number for sprites 5 and 6 to 204,
 STY pattSprite6        ; for the left and right sights respectively

 INY                    ; Set the pattern number for sprites 7 and 8 to 205,
 STY pattSprite7        ; for the top and bottom sights respectively
 STY pattSprite8

 LDA #114               ; Position the sprites as follows:
 STA xSprite5           ;
 LDA #138               ;   * Sprite 5 at (118, 83) for the left sight
 STA xSprite6           ;   * Sprite 6 at (134, 83) for the right sight
 LDA #126               ;   * Sprite 7 at (126, 75) for the top sight
 STA xSprite7           ;   * Sprite 8 at (126, 91) for the bottom sight
 STA xSprite8
 LDA #83+YPAL
 STA ySprite5
 STA ySprite6
 LDA #71+YPAL
 STA ySprite7
 LDA #95+YPAL
 STA ySprite8

 RTS                    ; Return from the subroutine

.sigh5

                        ; The laser is a beam laser, so we draw the beam laser
                        ; sights with a sprite for each of the top-left,
                        ; top-right, bottom-left and bottom-right sights

 LDA #%00000010         ; Set the attributes for sprite 5 (for the top-left
 STA attrSprite5        ; sight) as follows:
                        ;
                        ;   * Bits 0-1    = sprite palette 2
                        ;   * Bit 5 clear = show in front of background
                        ;   * Bit 6 clear = do not flip horizontally
                        ;   * Bit 7 clear = do not flip vertically

 LDA #%01000010         ; Set the attributes for sprite 6 (for the top-right
 STA attrSprite6        ; sight) as follows:
                        ;
                        ;   * Bits 0-1    = sprite palette 2
                        ;   * Bit 5 clear = show in front of background
                        ;   * Bit 6 set   = flip horizontally
                        ;   * Bit 7 clear = do not flip vertically

 LDA #%10000010         ; Set the attributes for sprite 7 (for the bottom-left
 STA attrSprite7        ; sight) as follows:
                        ;
                        ;   * Bits 0-1    = sprite palette 2
                        ;   * Bit 5 clear = show in front of background
                        ;   * Bit 6 clear = do not flip horizontally
                        ;   * Bit 7 set   = flip vertically

 LDA #%11000010         ; Set the attributes for sprite 8 (for the bottom-right
 STA attrSprite8        ; sight) as follows:
                        ;
                        ;   * Bits 0-1    = sprite palette 2
                        ;   * Bit 5 clear = show in front of background
                        ;   * Bit 6 set   = flip horizontally
                        ;   * Bit 7 set   = flip vertically

 LDA #206               ; Set the pattern number for all four sprites to 206
 STA pattSprite5
 STA pattSprite6
 STA pattSprite7
 STA pattSprite8

 LDA #122               ; Position the sprites as follows:
 STA xSprite5           ;
 STA xSprite7           ;   * Sprite 5 at (122, 75) for the top-left sight
 LDA #130               ;   * Sprite 6 at (130, 75) for the top-right sight
 STA xSprite6           ;   * Sprite 7 at (122, 91) for the bottom-left sight
 STA xSprite8           ;   * Sprite 8 at (130, 91) for the bottom-right sight
 LDA #75+YPAL
 STA ySprite5
 STA ySprite6
 LDA #91+YPAL
 STA ySprite7
 STA ySprite8

 RTS                    ; Return from the subroutine

; ******************************************************************************
;
;       Name: Vectors_b3
;       Type: Variable
;   Category: Utility routines
;    Summary: Vectors and padding at the end of ROM bank 3
;  Deep dive: Splitting NES Elite across multiple ROM banks
;
; ******************************************************************************

 FOR I%, P%, $BFF9

  EQUB $FF              ; Pad out the rest of the ROM bank with $FF

 NEXT

IF _NTSC

 EQUW Interrupts_b3+$4000   ; Vector to the NMI handler in case this bank is
                            ; loaded into $C000 during start-up (the handler
                            ; contains an RTI so the interrupt is processed but
                            ; has no effect)

 EQUW ResetMMC1_b3+$4000    ; Vector to the RESET handler in case this bank is
                            ; loaded into $C000 during start-up (the handler
                            ; resets the MMC1 mapper to map bank 7 into $C000
                            ; instead)

 EQUW Interrupts_b3+$4000   ; Vector to the IRQ/BRK handler in case this bank is
                            ; loaded into $C000 during start-up (the handler
                            ; contains an RTI so the interrupt is processed but
                            ; has no effect)

ELIF _PAL

 EQUW NMI                   ; Vector to the NMI handler

 EQUW ResetMMC1_b3+$4000    ; Vector to the RESET handler in case this bank is
                            ; loaded into $C000 during start-up (the handler
                            ; resets the MMC1 mapper to map bank 7 into $C000
                            ; instead)

 EQUW IRQ                   ; Vector to the IRQ/BRK handler

ENDIF

; ******************************************************************************
;
; Save bank3.bin
;
; ******************************************************************************

 PRINT "S.bank3.bin ", ~CODE%, " ", ~P%, " ", ~LOAD%, " ", ~LOAD%
 SAVE "3-assembled-output/bank3.bin", CODE%, P%, LOAD%
