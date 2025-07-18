; ******************************************************************************
;
; NES ELITE GAME SOURCE (BANK 4)
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
; This source file contains the game code for ROM bank 4 of NES Elite.
;
; ------------------------------------------------------------------------------
;
; This source file produces the following binary file:
;
;   * bank4.bin
;
; ******************************************************************************

; ******************************************************************************
;
; ELITE BANK 4
;
; Produces the binary file bank4.bin.
;
; ******************************************************************************

 ORG CODE%              ; Set the assembly address to CODE%

; ******************************************************************************
;
;       Name: ResetMMC1_b4
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

.ResetMMC1_b4

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
;       Name: Interrupts_b4
;       Type: Subroutine
;   Category: Start and end
;    Summary: The IRQ and NMI handler while the MMC1 mapper reset routine is
;             still running
;
; ******************************************************************************

.Interrupts_b4

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
;       Name: versionNumber_b4
;       Type: Variable
;   Category: Text
;    Summary: The game's version number in bank 4
;
; ******************************************************************************

IF _NTSC

 EQUS " 5.0"

ELIF _PAL

 EQUS "<2.8>"

ENDIF

; ******************************************************************************
;
;       Name: faceCount
;       Type: Variable
;   Category: Status
;    Summary: The number of commander face images in the faceOffset table
;
; ******************************************************************************

.faceCount

 EQUW 14

; ******************************************************************************
;
;       Name: faceOffset
;       Type: Variable
;   Category: Status
;    Summary: Offset to the data for each of the 14 commander face images
;
; ******************************************************************************

.faceOffset

 EQUW faceImage0 - faceCount
 EQUW faceImage1 - faceCount
 EQUW faceImage2 - faceCount
 EQUW faceImage3 - faceCount
 EQUW faceImage4 - faceCount
 EQUW faceImage5 - faceCount
 EQUW faceImage6 - faceCount
 EQUW faceImage7 - faceCount
 EQUW faceImage8 - faceCount
 EQUW faceImage9 - faceCount
 EQUW faceImage10 - faceCount
 EQUW faceImage11 - faceCount
 EQUW faceImage12 - faceCount
 EQUW faceImage13 - faceCount

; ******************************************************************************
;
;       Name: faceImage0
;       Type: Variable
;   Category: Status
;    Summary: Packed image data for commander face image 0
;  Deep dive: Displaying two-layer images
;             Image and data compression
;
; ------------------------------------------------------------------------------
;
; Each commander image is composed of a face image and a headshot image. You can
; view the combined commander image 0 here:
;
; https://elite.bbcelite.com/images/source/nes/commanderImage0_0.png
;
; ******************************************************************************

.faceImage0

 EQUB $0F, $05, $32, $03, $19, $47, $BC, $05
 EQUB $32, $07, $38, $43, $04, $21, $2D, $5F
 EQUB $83, $57, $04, $FE, $FF, $7F, $FF, $04
 EQUB $80, $B0, $DC, $EA, $05, $C0, $E0, $F4
 EQUB $0F, $01, $33, $01, $02, $03, $04, $21
 EQUB $04, $00, $21, $01, $06, $F7, $DF, $FE
 EQUB $6B, $FF, $21, $1B, $56, $39, $0D, $08
 EQUB $20, $01, $14, $00, $04, $20, $02, $F1
 EQUB $C5, $78, $F6, $CE, $7E, $F3, $DE, $37
 EQUB $0F, $3F, $87, $09, $31, $83, $0C, $20
 EQUB $6D, $EB, $58, $A5, $54, $AB, $54, $BE
 EQUB $22, $F6, $E7, $C3, $89, $32, $1C, $36
 EQUB $7E, $00, $23, $80, $24, $C0, $09, $39
 EQUB $01, $04, $05, $03, $09, $0D, $17, $04
 EQUB $04, $23, $01, $33, $03, $1B, $0B, $7F
 EQUB $80, $C7, $E9, $D4, $F0, $C2, $B6, $02
 EQUB $E0, $D1, $B8, $22, $FC, $D8, $FA, $32
 EQUB $23, $3D, $FF, $10, $44, $54, $44, $32
 EQUB $01, $1F, $FD, $FF, $FE, $33, $28, $38
 EQUB $28, $DF, $FE, $87, $21, $2F, $57, $21
 EQUB $1F, $87, $DB, $DE, $FF, $CF, $32, $17
 EQUB $3B, $22, $7F, $21, $37, $24, $40, $80
 EQUB $20, $60, $D0, $05, $80, $B0, $A0, $36
 EQUB $0F, $17, $01, $0A, $01, $05, $02, $34
 EQUB $13, $03, $03, $01, $04, $21, $02, $80
 EQUB $7D, $D3, $FE, $55, $62, $B5, $C2, $C0
 EQUB $FE, $FC, $FF, $D7, $E3, $76, $92, $AA
 EQUB $AB, $BB, $BA, $21, $29, $10, $21, $29
 EQUB $7C, $22, $6C, $7C, $7D, $EF, $D7, $EE
 EQUB $81, $21, $03, $7D, $96, $FF, $55, $8C
 EQUB $5A, $87, $21, $07, $FF, $7F, $FE, $D6
 EQUB $8E, $DC, $E0, $50, $00, $A0, $00, $40
 EQUB $02, $90, $22, $80, $0F, $06, $AA, $54
 EQUB $E1, $B5, $FA, $B5, $37, $1F, $17, $7F
 EQUB $3E, $1E, $0E, $0F, $23, $4F, $82, $C6
 EQUB $BB, $45, $C6, $21, $39, $83, $FF, $C7
 EQUB $C6, $7C, $32, $38, $01, $C7, $12, $AA
 EQUB $54, $21, $0E, $5A, $BE, $5A, $F0, $D0
 EQUB $FC, $F8, $F0, $22, $E0, $23, $E4, $0F
 EQUB $04, $21, $01, $0C, $7F, $21, $07, $AF
 EQUB $38, $13, $16, $09, $02, $00, $0F, $2F
 EQUB $07, $87, $C2, $43, $21, $21, $00, $83
 EQUB $22, $AB, $EF, $FE, $45, $EE, $BA, $FF
 EQUB $AB, $C7, $FF, $FE, $45, $EF, $7C, $FC
 EQUB $C0, $EA, $91, $D0, $20, $80, $00, $E0
 EQUB $E8, $C0, $C2, $86, $84, $21, $08, $0F
 EQUB $0F, $0F, $0F, $0F, $0F, $07, $3F

; ******************************************************************************
;
;       Name: faceImage1
;       Type: Variable
;   Category: Status
;    Summary: Packed image data for commander face image 1
;  Deep dive: Displaying two-layer images
;             Image and data compression
;
; ------------------------------------------------------------------------------
;
; Each commander image is composed of a face image and a headshot image. You can
; view the combined commander image 1 here:
;
; https://elite.bbcelite.com/images/source/nes/commanderImage1_0.png
;
; ******************************************************************************

.faceImage1

 EQUB $0F, $05, $32, $03, $19, $47, $BC, $05
 EQUB $32, $07, $38, $43, $04, $21, $2D, $5F
 EQUB $83, $57, $04, $FE, $FF, $7F, $FF, $04
 EQUB $80, $B0, $DC, $EA, $05, $C0, $E0, $F4
 EQUB $0F, $01, $33, $01, $02, $03, $04, $21
 EQUB $04, $00, $21, $01, $06, $F7, $DF, $FE
 EQUB $6B, $FF, $21, $1B, $56, $39, $0D, $08
 EQUB $20, $01, $14, $00, $04, $20, $02, $F1
 EQUB $C5, $78, $F6, $CE, $7E, $F3, $DE, $37
 EQUB $0F, $3F, $87, $09, $31, $83, $0C, $20
 EQUB $6D, $EB, $58, $A5, $54, $AB, $54, $BE
 EQUB $22, $F6, $E7, $C3, $89, $32, $1C, $36
 EQUB $7E, $00, $23, $80, $24, $C0, $09, $39
 EQUB $01, $04, $05, $03, $09, $0D, $17, $04
 EQUB $04, $23, $01, $33, $03, $1B, $0B, $7F
 EQUB $80, $AF, $D5, $F8, $FA, $C2, $B6, $02
 EQUB $D0, $B9, $23, $FC, $D4, $FA, $32, $23
 EQUB $3D, $FF, $10, $44, $54, $44, $32, $01
 EQUB $1F, $FD, $FF, $FE, $33, $28, $38, $28
 EQUB $DF, $86, $AF, $57, $21, $3F, $BF, $87
 EQUB $DB, $DE, $CF, $97, $21, $3B, $23, $7F
 EQUB $57, $24, $40, $80, $20, $60, $D0, $05
 EQUB $80, $B0, $A0, $36, $0F, $15, $01, $0A
 EQUB $01, $05, $02, $34, $13, $03, $03, $01
 EQUB $05, $80, $7D, $D3, $FE, $55, $62, $B5
 EQUB $22, $C0, $FE, $FC, $FF, $D7, $E3, $76
 EQUB $92, $AA, $AB, $BB, $BA, $21, $29, $10
 EQUB $21, $29, $7C, $22, $6C, $7C, $7D, $EF
 EQUB $D7, $EE, $32, $01, $03, $7D, $96, $FF
 EQUB $55, $8C, $5A, $22, $07, $FF, $7F, $FE
 EQUB $D6, $8E, $DC, $E0, $50, $00, $A0, $00
 EQUB $40, $02, $90, $22, $80, $0F, $06, $AA
 EQUB $54, $E1, $B5, $FA, $B5, $37, $1F, $17
 EQUB $7F, $3E, $1E, $0E, $0F, $23, $4F, $82
 EQUB $C6, $BB, $45, $C6, $21, $39, $83, $FF
 EQUB $C7, $C6, $7C, $32, $38, $01, $C7, $12
 EQUB $AA, $54, $21, $0E, $5A, $BE, $5A, $F0
 EQUB $D0, $FC, $F8, $F0, $22, $E0, $23, $E4
 EQUB $0F, $04, $21, $01, $0C, $7C, $21, $07
 EQUB $AF, $38, $13, $16, $09, $02, $00, $0E
 EQUB $2D, $07, $87, $C2, $43, $21, $21, $00
 EQUB $82, $22, $45, $C7, $FE, $45, $EE, $BA
 EQUB $7C, $45, $83, $FF, $FE, $45, $EF, $22
 EQUB $7C, $C0, $EA, $91, $D0, $20, $80, $00
 EQUB $E0, $68, $C0, $C2, $86, $84, $21, $08
 EQUB $0F, $0F, $0F, $0F, $0F, $0F, $07, $3F

; ******************************************************************************
;
;       Name: faceImage2
;       Type: Variable
;   Category: Status
;    Summary: Packed image data for commander face image 2
;  Deep dive: Displaying two-layer images
;             Image and data compression
;
; ------------------------------------------------------------------------------
;
; Each commander image is composed of a face image and a headshot image. You can
; view the combined commander image 2 here:
;
; https://elite.bbcelite.com/images/source/nes/commanderImage2_0.png
;
; ******************************************************************************

.faceImage2

 EQUB $0F, $05, $32, $03, $19, $47, $BC, $05
 EQUB $32, $07, $38, $43, $04, $21, $2D, $5F
 EQUB $83, $57, $04, $FE, $FF, $7F, $FF, $04
 EQUB $80, $B0, $DC, $EA, $05, $C0, $E0, $F4
 EQUB $0F, $01, $33, $01, $02, $03, $04, $21
 EQUB $04, $00, $21, $01, $06, $F7, $DF, $FE
 EQUB $6B, $FF, $21, $1B, $56, $39, $0D, $08
 EQUB $20, $01, $14, $00, $04, $20, $02, $F1
 EQUB $C5, $78, $F6, $CE, $7E, $F3, $DE, $37
 EQUB $0F, $3F, $87, $09, $31, $83, $0C, $20
 EQUB $6D, $EB, $58, $A5, $54, $AB, $54, $BE
 EQUB $22, $F6, $E7, $C3, $89, $32, $1C, $36
 EQUB $7E, $00, $23, $80, $24, $C0, $09, $39
 EQUB $01, $04, $05, $03, $09, $0D, $17, $04
 EQUB $04, $23, $01, $33, $03, $1B, $0B, $7F
 EQUB $80, $C7, $F4, $FF, $4C, $D0, $7E, $02
 EQUB $F8, $F4, $FF, $83, $E0, $80, $FA, $20
 EQUB $21, $07, $BA, $BB, $C6, $22, $6C, $32
 EQUB $01, $1F, $FB, $C6, $D7, $32, $29, $28
 EQUB $10, $FF, $FE, $FF, $5F, $FF, $65, $21
 EQUB $17, $FD, $FE, $12, $5F, $FF, $83, $32
 EQUB $0F, $03, $24, $40, $80, $20, $60, $D0
 EQUB $05, $80, $B0, $A0, $36, $0F, $15, $01
 EQUB $0A, $01, $05, $02, $34, $13, $03, $03
 EQUB $01, $04, $F7, $9D, $FC, $59, $55, $62
 EQUB $B5, $AA, $F8, $E2, $22, $FE, $D7, $E3
 EQUB $76, $7F, $21, $11, $AB, $BA, $BB, $21
 EQUB $29, $10, $21, $29, $82, $7C, $6C, $22
 EQUB $7C, $EF, $D7, $EE, $C7, $DF, $73, $7F
 EQUB $21, $34, $55, $8D, $5A, $AA, $21, $3F
 EQUB $8F, $12, $D6, $8E, $DC, $FC, $E0, $50
 EQUB $00, $A0, $00, $40, $02, $90, $22, $80
 EQUB $0F, $06, $54, $E1, $B5, $FA, $B5, $22
 EQUB $1F, $35, $17, $3E, $1E, $0E, $0F, $24
 EQUB $4F, $C6, $BB, $45, $C6, $21, $39, $C7
 EQUB $12, $C6, $7C, $32, $38, $01, $C7, $13
 EQUB $54, $21, $0E, $5A, $BE, $5A, $22, $F0
 EQUB $D0, $F8, $F0, $22, $E0, $24, $E4, $0F
 EQUB $04, $21, $01, $0C, $7C, $84, $AF, $38
 EQUB $13, $16, $09, $02, $00, $0E, $2C, $07
 EQUB $87, $C2, $43, $21, $21, $00, $82, $C6
 EQUB $22, $BB, $FE, $45, $EE, $BA, $7C, $C6
 EQUB $C7, $FF, $FE, $45, $EF, $22, $7C, $42
 EQUB $EA, $91, $D0, $20, $80, $00, $E0, $68
 EQUB $C0, $C2, $86, $84, $21, $08, $0F, $0F
 EQUB $0F, $0F, $0F, $0F, $07, $3F

; ******************************************************************************
;
;       Name: faceImage3
;       Type: Variable
;   Category: Status
;    Summary: Packed image data for commander face image 3
;  Deep dive: Displaying two-layer images
;             Image and data compression
;
; ------------------------------------------------------------------------------
;
; Each commander image is composed of a face image and a headshot image. You can
; view the combined commander image 3 here:
;
; https://elite.bbcelite.com/images/source/nes/commanderImage3_0.png
;
; ******************************************************************************

.faceImage3

 EQUB $0F, $21, $01, $04, $33, $08, $02, $01
 EQUB $B9, $04, $33, $1C, $06, $33, $C9, $04
 EQUB $21, $1A, $60, $32, $04, $25, $03, $89
 EQUB $42, $46, $64, $AC, $05, $58, $40, $C6
 EQUB $05, $21, $3C, $E0, $8E, $0F, $02, $32
 EQUB $03, $02, $02, $32, $04, $02, $03, $34
 EQUB $03, $02, $00, $02, $02, $44, $21, $22
 EQUB $86, $55, $40, $B1, $6A, $FD, $6C, $21
 EQUB $24, $30, $00, $21, $1F, $71, $EA, $FD
 EQUB $FF, $21, $18, $A4, $4D, $30, $AB, $FE
 EQUB $55, $22, $AD, $21, $08, $00, $83, $D7
 EQUB $FE, $55, $10, $90, $21, $25, $52, $32
 EQUB $04, $19, $AC, $7E, $99, $20, $21, $03
 EQUB $00, $F9, $21, $1C, $AE, $7E, $04, $80
 EQUB $00, $40, $80, $02, $80, $00, $80, $02
 EQUB $40, $39, $05, $04, $01, $05, $03, $09
 EQUB $0D, $17, $00, $24, $01, $33, $03, $1B
 EQUB $0B, $F5, $FF, $E2, $A7, $49, $E4, $C4
 EQUB $AE, $F7, $FF, $FE, $C1, $B0, $22, $F8
 EQUB $D0, $BB, $45, $C6, $FF, $21, $11, $C6
 EQUB $54, $44, $BB, $FF, $C6, $FF, $FE, $33
 EQUB $28, $38, $28, $5F, $FE, $8F, $CB, $21
 EQUB $25, $4F, $47, $EB, $DE, $12, $35, $07
 EQUB $1B, $3F, $3F, $17, $00, $22, $40, $00
 EQUB $80, $20, $60, $D0, $05, $80, $B0, $A0
 EQUB $36, $0F, $15, $01, $0A, $01, $05, $02
 EQUB $34, $13, $03, $03, $01, $04, $10, $80
 EQUB $7D, $D3, $FE, $55, $62, $B5, $D2, $C0
 EQUB $FE, $FC, $FF, $D7, $E3, $76, $92, $AA
 EQUB $AB, $BB, $BA, $21, $29, $10, $21, $29
 EQUB $7C, $22, $6C, $7C, $7D, $EF, $D7, $EE
 EQUB $32, $11, $03, $7D, $96, $FF, $55, $8C
 EQUB $5A, $97, $21, $07, $FF, $7F, $FE, $D6
 EQUB $8E, $DC, $E0, $50, $00, $A0, $00, $40
 EQUB $02, $90, $22, $80, $0F, $06, $AA, $54
 EQUB $E1, $B5, $F0, $B5, $37, $12, $15, $7F
 EQUB $3E, $1E, $0E, $0F, $23, $4F, $82, $C6
 EQUB $BB, $45, $C6, $21, $39, $82, $FF, $C7
 EQUB $C6, $7C, $32, $38, $01, $C7, $12, $AA
 EQUB $54, $21, $0E, $5A, $21, $1E, $5A, $90
 EQUB $50, $FC, $F8, $F0, $22, $E0, $23, $E4
 EQUB $0F, $04, $21, $01, $0C, $73, $21, $05
 EQUB $AA, $38, $11, $16, $09, $02, $00, $0F
 EQUB $2F, $07, $87, $C3, $43, $21, $21, $00
 EQUB $55, $AB, $AA, $C7, $EE, $55, $AA, $92
 EQUB $EF, $AB, $C7, $14, $7C, $9C, $40, $AA
 EQUB $21, $11, $D0, $20, $80, $00, $E0, $E8
 EQUB $C0, $C2, $86, $84, $21, $08, $0F, $0F
 EQUB $0F, $0F, $0F, $0F, $07, $3F

; ******************************************************************************
;
;       Name: faceImage4
;       Type: Variable
;   Category: Status
;    Summary: Packed image data for commander face image 4
;  Deep dive: Displaying two-layer images
;             Image and data compression
;
; ------------------------------------------------------------------------------
;
; Each commander image is composed of a face image and a headshot image. You can
; view the combined commander image 4 here:
;
; https://elite.bbcelite.com/images/source/nes/commanderImage4_0.png
;
; ******************************************************************************

.faceImage4

 EQUB $0F, $21, $01, $04, $33, $08, $02, $01
 EQUB $B9, $04, $33, $1C, $06, $33, $C9, $04
 EQUB $21, $1A, $60, $32, $04, $25, $03, $89
 EQUB $42, $46, $64, $AC, $05, $58, $40, $C6
 EQUB $05, $21, $3C, $E0, $8E, $0F, $02, $32
 EQUB $03, $02, $02, $32, $04, $02, $03, $34
 EQUB $03, $02, $00, $02, $02, $44, $21, $22
 EQUB $86, $55, $40, $B1, $6A, $FD, $6C, $21
 EQUB $24, $30, $00, $21, $1F, $71, $EA, $FD
 EQUB $FF, $21, $18, $A4, $4D, $30, $AB, $FE
 EQUB $55, $22, $AD, $21, $08, $00, $83, $D7
 EQUB $FE, $55, $10, $90, $21, $25, $52, $32
 EQUB $04, $19, $AC, $7E, $99, $20, $21, $03
 EQUB $00, $F9, $21, $1C, $AE, $7E, $04, $80
 EQUB $00, $40, $80, $02, $80, $00, $80, $02
 EQUB $40, $39, $05, $04, $01, $05, $03, $09
 EQUB $0D, $17, $00, $24, $01, $33, $03, $1B
 EQUB $0B, $F6, $FF, $C3, $E9, $D4, $F0, $C2
 EQUB $B6, $F7, $FF, $E7, $D1, $B8, $22, $FC
 EQUB $D8, $BA, $22, $45, $FF, $10, $44, $54
 EQUB $44, $BB, $FF, $45, $FF, $FE, $33, $28
 EQUB $38, $28, $DF, $FE, $87, $21, $2F, $57
 EQUB $21, $1F, $87, $DB, $DE, $FF, $CF, $32
 EQUB $17, $3B, $22, $7F, $21, $37, $00, $22
 EQUB $40, $00, $80, $20, $60, $D0, $05, $80
 EQUB $B0, $A0, $36, $0F, $15, $01, $0A, $01
 EQUB $05, $02, $34, $13, $03, $03, $01, $04
 EQUB $21, $02, $80, $7D, $D3, $FE, $55, $62
 EQUB $B5, $C2, $C0, $FE, $FC, $FF, $D7, $E3
 EQUB $76, $92, $AA, $AB, $BB, $BA, $21, $29
 EQUB $10, $21, $29, $7C, $22, $6C, $7C, $7D
 EQUB $EF, $D7, $EE, $81, $21, $03, $7D, $96
 EQUB $FF, $55, $8C, $5A, $87, $21, $07, $FF
 EQUB $7F, $FE, $D6, $8E, $DC, $E0, $50, $00
 EQUB $A0, $00, $40, $02, $90, $22, $80, $0F
 EQUB $06, $AA, $54, $E1, $B5, $F0, $B5, $37
 EQUB $12, $17, $7F, $3E, $1E, $0E, $0F, $23
 EQUB $4F, $82, $C6, $BB, $45, $C6, $21, $39
 EQUB $82, $FF, $C7, $C6, $7C, $32, $38, $01
 EQUB $C7, $12, $AA, $54, $21, $0E, $5A, $21
 EQUB $1E, $5A, $90, $D0, $FC, $F8, $F0, $22
 EQUB $E0, $23, $E4, $0F, $04, $21, $01, $0C
 EQUB $75, $21, $07, $AB, $38, $11, $16, $09
 EQUB $02, $00, $0E, $2D, $07, $87, $C3, $43
 EQUB $21, $21, $00, $21, $39, $22, $45, $C7
 EQUB $EE, $55, $AA, $92, $C6, $45, $83, $14
 EQUB $7C, $5C, $C0, $AA, $21, $11, $D0, $20
 EQUB $80, $00, $E0, $68, $C0, $C2, $86, $84
 EQUB $21, $08, $0F, $0F, $0F, $0F, $0F, $0F
 EQUB $07, $3F

; ******************************************************************************
;
;       Name: faceImage5
;       Type: Variable
;   Category: Status
;    Summary: Packed image data for commander face image 5
;  Deep dive: Displaying two-layer images
;             Image and data compression
;
; ------------------------------------------------------------------------------
;
; Each commander image is composed of a face image and a headshot image. You can
; view the combined commander image 5 here:
;
; https://elite.bbcelite.com/images/source/nes/commanderImage5_0.png
;
; ******************************************************************************

.faceImage5

 EQUB $0F, $21, $01, $04, $33, $08, $02, $01
 EQUB $B9, $04, $33, $1C, $06, $33, $C9, $04
 EQUB $21, $1A, $60, $32, $04, $25, $03, $89
 EQUB $42, $46, $64, $AC, $05, $58, $40, $C6
 EQUB $05, $21, $3C, $E0, $8E, $0F, $02, $32
 EQUB $03, $02, $02, $32, $04, $02, $03, $34
 EQUB $03, $02, $00, $02, $02, $44, $21, $22
 EQUB $86, $55, $40, $B1, $6A, $FD, $6C, $21
 EQUB $24, $30, $00, $21, $1F, $71, $EA, $FD
 EQUB $FF, $21, $18, $A4, $4D, $30, $AB, $FE
 EQUB $55, $22, $AD, $21, $08, $00, $83, $D7
 EQUB $FE, $55, $10, $90, $21, $25, $52, $32
 EQUB $04, $19, $AC, $7E, $99, $20, $21, $03
 EQUB $00, $F9, $21, $1C, $AE, $7E, $04, $80
 EQUB $00, $40, $80, $02, $80, $00, $80, $02
 EQUB $40, $39, $05, $04, $01, $05, $03, $09
 EQUB $0D, $17, $00, $24, $01, $33, $03, $1B
 EQUB $0B, $FF, $FE, $FF, $F4, $FF, $4C, $D0
 EQUB $7E, $13, $F4, $FF, $83, $E0, $80, $BB
 EQUB $54, $C7, $BB, $B8, $C4, $22, $6C, $BB
 EQUB $FF, $BB, $C7, $D6, $22, $28, $10, $FF
 EQUB $FE, $87, $21, $2F, $57, $21, $1F, $87
 EQUB $DB, $FE, $FF, $CF, $32, $17, $3B, $22
 EQUB $7F, $57, $00, $22, $40, $00, $80, $20
 EQUB $60, $D0, $05, $80, $B0, $A0, $36, $0F
 EQUB $15, $01, $0A, $01, $05, $02, $34, $13
 EQUB $03, $03, $01, $04, $F7, $9D, $FC, $59
 EQUB $55, $62, $B5, $AA, $F8, $E2, $22, $FE
 EQUB $D7, $E3, $76, $7F, $21, $12, $AA, $BB
 EQUB $BA, $33, $28, $11, $28, $82, $7C, $6C
 EQUB $7C, $7D, $EF, $D7, $EF, $C7, $32, $01
 EQUB $03, $7D, $96, $FF, $55, $8C, $5A, $22
 EQUB $07, $FF, $7F, $FE, $D6, $8E, $DC, $E0
 EQUB $50, $00, $A0, $00, $40, $02, $90, $22
 EQUB $80, $0F, $06, $54, $E1, $B5, $F0, $B5
 EQUB $37, $12, $15, $13, $3E, $1E, $0E, $0F
 EQUB $24, $4F, $C6, $BB, $45, $C6, $21, $39
 EQUB $82, $55, $FF, $C6, $7C, $32, $38, $01
 EQUB $C7, $13, $AA, $D4, $21, $0E, $5A, $21
 EQUB $1E, $5A, $90, $D0, $7C, $78, $F0, $22
 EQUB $E0, $23, $E4, $0F, $04, $21, $01, $0C
 EQUB $74, $21, $02, $AB, $38, $11, $16, $09
 EQUB $02, $00, $0E, $2D, $07, $87, $C3, $43
 EQUB $21, $21, $00, $82, $C6, $BB, $83, $EE
 EQUB $55, $AA, $92, $7C, $22, $C7, $14, $7C
 EQUB $5C, $80, $AA, $21, $11, $D0, $20, $80
 EQUB $00, $E0, $68, $C0, $C2, $86, $84, $21
 EQUB $08, $0F, $0F, $0F, $0F, $0F, $0F, $07
 EQUB $3F

; ******************************************************************************
;
;       Name: faceImage6
;       Type: Variable
;   Category: Status
;    Summary: Packed image data for commander face image 6
;  Deep dive: Displaying two-layer images
;             Image and data compression
;
; ------------------------------------------------------------------------------
;
; Each commander image is composed of a face image and a headshot image. You can
; view the combined commander image 6 here:
;
; https://elite.bbcelite.com/images/source/nes/commanderImage6_0.png
;
; ******************************************************************************

.faceImage6

 EQUB $0F, $05, $32, $02, $14, $62, $D4, $04
 EQUB $34, $01, $0B, $1D, $2B, $04, $AA, $10
 EQUB $BA, $10, $04, $7D, $13, $04, $80, $50
 EQUB $8C, $56, $05, $A0, $70, $A8, $0F, $01
 EQUB $3C, $01, $02, $03, $02, $07, $07, $06
 EQUB $06, $00, $01, $00, $01, $04, $AA, $F1
 EQUB $AA, $D5, $4E, $B1, $6A, $FD, $55, $21
 EQUB $0E, $55, $00, $21, $3F, $71, $EA, $FD
 EQUB $AA, $21, $01, $AA, $45, $BA, $AB, $FE
 EQUB $55, $7D, $FE, $55, $10, $21, $01, $C7
 EQUB $FE, $55, $AB, $21, $1E, $AB, $56, $E5
 EQUB $21, $1B, $AC, $7E, $54, $E1, $54, $21
 EQUB $01, $F8, $21, $1C, $AE, $7E, $00, $23
 EQUB $80, $24, $C0, $08, $39, $05, $04, $05
 EQUB $05, $03, $09, $0D, $17, $00, $24, $01
 EQUB $33, $03, $1B, $0B, $FF, $F5, $FC, $FB
 EQUB $E2, $88, $44, $BC, $FF, $F7, $FC, $C7
 EQUB $81, $70, $F8, $C0, $BB, $55, $AA, $FF
 EQUB $10, $C6, $54, $44, $BB, $FF, $AA, $12
 EQUB $33, $28, $38, $28, $FF, $5E, $7F, $BF
 EQUB $8F, $21, $23, $45, $7B, $FE, $DF, $7F
 EQUB $C7, $34, $03, $1D, $3F, $07, $24, $40
 EQUB $80, $20, $60, $D0, $05, $80, $B0, $A0
 EQUB $36, $0F, $15, $01, $0A, $01, $05, $02
 EQUB $34, $13, $03, $03, $01, $04, $21, $12
 EQUB $80, $7D, $D3, $FE, $55, $62, $B5, $D0
 EQUB $C0, $FE, $FC, $FF, $D7, $E3, $76, $92
 EQUB $AA, $AB, $BB, $BA, $21, $29, $10, $21
 EQUB $29, $7C, $22, $6C, $7C, $7D, $EF, $D7
 EQUB $EE, $91, $21, $03, $7D, $96, $FF, $55
 EQUB $8C, $5A, $32, $17, $07, $FF, $7F, $FE
 EQUB $D6, $8E, $DC, $E0, $50, $00, $A0, $00
 EQUB $40, $02, $90, $22, $80, $0F, $06, $AA
 EQUB $54, $E1, $BB, $F4, $B1, $58, $21, $12
 EQUB $7F, $36, $3E, $1E, $04, $0B, $4E, $07
 EQUB $4D, $82, $C6, $BB, $45, $C6, $21, $39
 EQUB $82, $21, $28, $C7, $C6, $7C, $32, $38
 EQUB $01, $C6, $7D, $FF, $AA, $54, $21, $0E
 EQUB $BA, $5E, $32, $1A, $34, $90, $FC, $F8
 EQUB $F0, $40, $A0, $E4, $C0, $64, $0F, $04
 EQUB $21, $01, $0C, $78, $21, $04, $A8, $38
 EQUB $12, $14, $09, $02, $00, $07, $2B, $07
 EQUB $85, $C3, $42, $21, $21, $00, $21, $38
 EQUB $AA, $21, $28, $10, $44, $21, $01, $54
 EQUB $BA, $C7, $AB, $C7, $EF, $BB, $FE, $AB
 EQUB $44, $21, $3C, $40, $21, $2A, $91, $50
 EQUB $20, $80, $00, $C0, $A8, $C0, $42, $86
 EQUB $84, $21, $08, $0F, $0F, $0F, $0F, $0F
 EQUB $0F, $07, $3F

; ******************************************************************************
;
;       Name: faceImage7
;       Type: Variable
;   Category: Status
;    Summary: Packed image data for commander face image 7
;  Deep dive: Displaying two-layer images
;             Image and data compression
;
; ------------------------------------------------------------------------------
;
; Each commander image is composed of a face image and a headshot image. You can
; view the combined commander image 7 here:
;
; https://elite.bbcelite.com/images/source/nes/commanderImage7_0.png
;
; ******************************************************************************

.faceImage7

 EQUB $0F, $05, $32, $02, $14, $62, $D4, $04
 EQUB $34, $01, $0B, $1D, $2B, $04, $AA, $10
 EQUB $BA, $10, $04, $7D, $13, $04, $80, $50
 EQUB $8C, $56, $05, $A0, $70, $A8, $0F, $01
 EQUB $3C, $01, $02, $03, $02, $07, $07, $06
 EQUB $06, $00, $01, $00, $01, $04, $AA, $F1
 EQUB $AA, $D5, $4E, $B1, $6A, $FD, $55, $21
 EQUB $0E, $55, $00, $21, $3F, $71, $EA, $FD
 EQUB $AA, $21, $01, $AA, $45, $BA, $AB, $FE
 EQUB $55, $7D, $FE, $55, $10, $21, $01, $C7
 EQUB $FE, $55, $AB, $21, $1E, $AB, $56, $E5
 EQUB $21, $1B, $AC, $7E, $54, $E1, $54, $21
 EQUB $01, $F8, $21, $1C, $AE, $7E, $00, $23
 EQUB $80, $24, $C0, $08, $39, $05, $04, $05
 EQUB $05, $03, $09, $0D, $17, $00, $24, $01
 EQUB $33, $03, $1B, $0B, $F5, $FF, $E2, $A7
 EQUB $49, $E4, $C4, $AE, $F7, $FF, $FE, $C1
 EQUB $B0, $22, $F8, $D0, $BB, $45, $C6, $FF
 EQUB $21, $11, $C6, $54, $44, $BB, $FF, $C6
 EQUB $FF, $FE, $33, $28, $38, $28, $5F, $FE
 EQUB $8F, $CB, $21, $25, $4F, $47, $EB, $DE
 EQUB $12, $35, $07, $1B, $3F, $3F, $17, $24
 EQUB $40, $80, $20, $60, $D0, $05, $80, $B0
 EQUB $A0, $36, $0F, $15, $01, $0A, $01, $05
 EQUB $02, $34, $13, $03, $03, $01, $04, $10
 EQUB $80, $7D, $D3, $FE, $55, $62, $B5, $D2
 EQUB $C0, $FE, $FC, $FF, $D7, $E3, $76, $92
 EQUB $AA, $AB, $BB, $BA, $21, $29, $10, $21
 EQUB $29, $7C, $22, $6C, $7C, $7D, $EF, $D7
 EQUB $EE, $32, $11, $03, $7D, $96, $FF, $55
 EQUB $8C, $5A, $97, $21, $07, $FF, $7F, $FE
 EQUB $D6, $8E, $DC, $E0, $50, $00, $A0, $00
 EQUB $40, $02, $90, $22, $80, $0F, $06, $AA
 EQUB $54, $E1, $BB, $F4, $B1, $58, $21, $12
 EQUB $7F, $36, $3E, $1E, $04, $0B, $4E, $07
 EQUB $4D, $82, $C6, $BB, $45, $C6, $21, $39
 EQUB $82, $21, $28, $C7, $C6, $7C, $32, $38
 EQUB $01, $C6, $7D, $FF, $AA, $54, $21, $0E
 EQUB $BA, $5E, $32, $1A, $34, $90, $FC, $F8
 EQUB $F0, $40, $A0, $E4, $C0, $64, $0F, $04
 EQUB $21, $01, $0C, $78, $21, $05, $A9, $38
 EQUB $12, $14, $09, $02, $00, $07, $2A, $07
 EQUB $85, $C3, $42, $21, $21, $00, $BA, $AB
 EQUB $21, $29, $10, $44, $21, $01, $54, $BA
 EQUB $45, $AA, $C7, $EF, $BB, $FE, $AB, $44
 EQUB $21, $3C, $40, $21, $2A, $91, $50, $20
 EQUB $80, $00, $C0, $A8, $C0, $42, $86, $84
 EQUB $21, $08, $0F, $0F, $0F, $0F, $0F, $0F
 EQUB $07, $3F

; ******************************************************************************
;
;       Name: faceImage8
;       Type: Variable
;   Category: Status
;    Summary: Packed image data for commander face image 8
;  Deep dive: Displaying two-layer images
;             Image and data compression
;
; ------------------------------------------------------------------------------
;
; Each commander image is composed of a face image and a headshot image. You can
; view the combined commander image 8 here:
;
; https://elite.bbcelite.com/images/source/nes/commanderImage8_0.png
;
; ******************************************************************************

.faceImage8

 EQUB $0F, $05, $32, $02, $14, $62, $D4, $04
 EQUB $34, $01, $0B, $1D, $2B, $04, $AA, $10
 EQUB $BA, $10, $04, $7D, $13, $04, $80, $50
 EQUB $8C, $56, $05, $A0, $70, $A8, $0F, $01
 EQUB $3C, $01, $02, $03, $02, $07, $07, $06
 EQUB $06, $00, $01, $00, $01, $04, $AA, $F1
 EQUB $AA, $D5, $4E, $B1, $6A, $FD, $55, $21
 EQUB $0E, $55, $00, $21, $3F, $71, $EA, $FD
 EQUB $AA, $21, $01, $AA, $45, $BA, $AB, $FE
 EQUB $55, $7D, $FE, $55, $10, $21, $01, $C7
 EQUB $FE, $55, $AB, $21, $1E, $AB, $56, $E5
 EQUB $21, $1B, $AC, $7E, $54, $E1, $54, $21
 EQUB $01, $F8, $21, $1C, $AE, $7E, $00, $23
 EQUB $80, $24, $C0, $08, $39, $05, $04, $05
 EQUB $05, $03, $09, $0D, $17, $00, $24, $01
 EQUB $33, $03, $1B, $0B, $12, $F5, $EE, $A4
 EQUB $51, $44, $21, $3C, $12, $F7, $FE, $C3
 EQUB $80, $21, $38, $C0, $BB, $EF, $6D, $D6
 EQUB $10, $C7, $54, $44, $BB, $FF, $EF, $FE
 EQUB $FF, $33, $28, $38, $28, $FF, $FE, $5F
 EQUB $EF, $4B, $21, $15, $45, $79, $FE, $FF
 EQUB $DF, $FF, $87, $33, $03, $39, $07, $24
 EQUB $40, $80, $20, $60, $D0, $05, $80, $B0
 EQUB $A0, $36, $0F, $15, $01, $0A, $01, $05
 EQUB $02, $34, $13, $03, $03, $01, $04, $21
 EQUB $02, $80, $7D, $D3, $FE, $55, $62, $B5
 EQUB $D0, $C0, $FE, $FC, $FF, $D7, $E3, $76
 EQUB $92, $AA, $AB, $BB, $BA, $21, $29, $10
 EQUB $21, $29, $7C, $22, $6C, $7C, $7D, $EF
 EQUB $D7, $EE, $81, $21, $03, $7D, $96, $FF
 EQUB $55, $8C, $5A, $32, $17, $07, $FF, $7F
 EQUB $FE, $D6, $8E, $DC, $E0, $50, $00, $A0
 EQUB $00, $40, $02, $90, $22, $80, $0F, $06
 EQUB $AA, $54, $E1, $B5, $FA, $B5, $37, $1F
 EQUB $17, $7F, $3E, $1E, $0E, $0F, $23, $4F
 EQUB $82, $C6, $BB, $45, $C6, $21, $39, $83
 EQUB $FF, $C7, $C6, $7C, $32, $38, $01, $C7
 EQUB $12, $AA, $54, $21, $0E, $5A, $BE, $5A
 EQUB $F0, $D0, $FC, $F8, $F0, $22, $E0, $23
 EQUB $E4, $0F, $0F, $02, $7F, $3E, $07, $2F
 EQUB $13, $16, $09, $02, $00, $0F, $2F, $07
 EQUB $07, $02, $03, $01, $00, $7D, $22, $AB
 EQUB $EF, $FE, $45, $EE, $BA, $83, $AB, $C7
 EQUB $FF, $FE, $45, $EF, $7C, $FC, $C0, $E8
 EQUB $90, $D0, $20, $80, $00, $E0, $E8, $22
 EQUB $C0, $22, $80, $0F, $0F, $0F, $0F, $0F
 EQUB $0F, $08, $3F

; ******************************************************************************
;
;       Name: faceImage9
;       Type: Variable
;   Category: Status
;    Summary: Packed image data for commander face image 9
;  Deep dive: Displaying two-layer images
;             Image and data compression
;
; ------------------------------------------------------------------------------
;
; Each commander image is composed of a face image and a headshot image. You can
; view the combined commander image 9 here:
;
; https://elite.bbcelite.com/images/source/nes/commanderImage9_0.png
;
; ******************************************************************************

.faceImage9

 EQUB $0F, $21, $01, $04, $33, $08, $02, $01
 EQUB $B9, $04, $33, $1C, $06, $33, $C9, $04
 EQUB $21, $1A, $60, $32, $04, $25, $03, $89
 EQUB $42, $46, $64, $AC, $05, $58, $40, $C6
 EQUB $05, $21, $3C, $E0, $8E, $0F, $02, $32
 EQUB $03, $02, $02, $32, $04, $02, $03, $34
 EQUB $03, $02, $00, $02, $02, $44, $21, $22
 EQUB $86, $55, $4E, $B1, $6A, $F5, $6C, $21
 EQUB $24, $30, $00, $21, $3F, $71, $EA, $FD
 EQUB $FF, $21, $18, $A4, $21, $0D, $82, $AB
 EQUB $FE, $55, $22, $AD, $21, $08, $00, $21
 EQUB $01, $C7, $FE, $55, $10, $90, $21, $25
 EQUB $52, $E4, $21, $1B, $AC, $7E, $99, $20
 EQUB $21, $03, $00, $F9, $21, $1C, $AE, $7E
 EQUB $04, $80, $00, $40, $80, $02, $80, $00
 EQUB $80, $02, $40, $39, $05, $04, $01, $01
 EQUB $03, $09, $0D, $17, $00, $24, $01, $33
 EQUB $03, $1B, $0B, $EF, $D7, $B7, $DA, $73
 EQUB $21, $06, $B8, $21, $0E, $FF, $E7, $D7
 EQUB $BA, $8F, $81, $00, $70, $BB, $12, $D6
 EQUB $BB, $44, $EE, $54, $BB, $12, $FE, $FF
 EQUB $AB, $32, $28, $38, $FF, $FE, $DF, $B7
 EQUB $9B, $C1, $21, $3B, $E1, $FE, $FF, $DF
 EQUB $B7, $E7, $33, $03, $01, $1D, $00, $22
 EQUB $40, $00, $80, $20, $60, $D0, $05, $80
 EQUB $B0, $A0, $36, $0F, $15, $01, $0A, $01
 EQUB $05, $02, $34, $13, $03, $03, $01, $04
 EQUB $21, $3E, $00, $7D, $D3, $FE, $55, $62
 EQUB $B5, $22, $C0, $FE, $FC, $FF, $D7, $E3
 EQUB $76, $82, $AA, $AB, $BB, $BA, $21, $29
 EQUB $10, $21, $29, $23, $6C, $7C, $7D, $EF
 EQUB $D7, $EE, $F9, $21, $01, $7D, $96, $FF
 EQUB $55, $8C, $5A, $22, $07, $FF, $7F, $FE
 EQUB $D6, $8E, $DC, $E0, $50, $00, $A0, $00
 EQUB $40, $02, $90, $22, $80, $0F, $06, $AA
 EQUB $54, $E1, $B1, $F2, $B5, $37, $12, $15
 EQUB $7F, $3E, $1E, $0E, $0F, $23, $4F, $82
 EQUB $C6, $BB, $45, $C6, $21, $39, $82, $FF
 EQUB $C7, $C6, $7C, $32, $38, $01, $C7, $12
 EQUB $AA, $54, $32, $0E, $1A, $9E, $5A, $90
 EQUB $50, $FC, $F8, $F0, $22, $E0, $23, $E4
 EQUB $0F, $0F, $02, $72, $3E, $05, $2B, $11
 EQUB $16, $09, $02, $00, $0F, $2F, $07, $07
 EQUB $03, $03, $01, $00, $7C, $AB, $BB, $C7
 EQUB $EE, $55, $21, $28, $92, $83, $AB, $C7
 EQUB $14, $7C, $9C, $40, $A8, $10, $D0, $20
 EQUB $80, $00, $E0, $E8, $22, $C0, $22, $80
 EQUB $0F, $0F, $0F, $0F, $0F, $0F, $08, $3F

; ******************************************************************************
;
;       Name: faceImage10
;       Type: Variable
;   Category: Status
;    Summary: Packed image data for commander face image 10
;  Deep dive: Displaying two-layer images
;             Image and data compression
;
; ------------------------------------------------------------------------------
;
; Each commander image is composed of a face image and a headshot image. You can
; view the combined commander image 10 here:
;
; https://elite.bbcelite.com/images/source/nes/commanderImage10_0.png
;
; ******************************************************************************

.faceImage10

 EQUB $0F, $04, $32, $14, $02, $00, $53, $88
 EQUB $03, $34, $08, $06, $03, $21, $71, $03
 EQUB $21, $1A, $20, $44, $A5, $7C, $02, $21
 EQUB $09, $82, $46, $66, $6C, $AD, $04, $4C
 EQUB $40, $C0, $21, $0A, $04, $30, $E0, $80
 EQUB $84, $0F, $01, $21, $01, $00, $3B, $03
 EQUB $01, $02, $01, $04, $02, $00, $01, $01
 EQUB $03, $01, $02, $21, $04, $75, $DA, $AC
 EQUB $F5, $AA, $D1, $EA, $F5, $F8, $DC, $AE
 EQUB $F6, $AB, $D1, $EA, $FD, $FF, $21, $18
 EQUB $A4, $21, $0D, $82, $AB, $FE, $55, $22
 EQUB $AD, $21, $08, $00, $21, $01, $C7, $FE
 EQUB $55, $21, $11, $AE, $34, $1B, $35, $E2
 EQUB $17, $AE, $7E, $8E, $32, $1F, $3B, $75
 EQUB $E3, $21, $16, $AE, $7E, $02, $80, $00
 EQUB $80, $00, $40, $80, $03, $80, $03, $40
 EQUB $39, $01, $04, $05, $01, $03, $09, $0D
 EQUB $17, $00, $24, $01, $33, $03, $1B, $0B
 EQUB $EF, $D7, $B7, $9A, $43, $21, $06, $B0
 EQUB $21, $0C, $FF, $E7, $D7, $FA, $BF, $81
 EQUB $00, $70, $BB, $FF, $D7, $FE, $93, $44
 EQUB $EE, $54, $BB, $12, $FE, $FF, $AB, $32
 EQUB $28, $38, $FF, $FE, $DF, $B7, $8F, $C1
 EQUB $21, $1B, $61, $FE, $FF, $DF, $B7, $FF
 EQUB $33, $03, $01, $1D, $00, $22, $40, $00
 EQUB $80, $20, $60, $D0, $05, $80, $B0, $A0
 EQUB $36, $0F, $15, $01, $0A, $01, $05, $02
 EQUB $34, $13, $03, $03, $01, $04, $BE, $00
 EQUB $7D, $D3, $FE, $55, $62, $B5, $40, $C0
 EQUB $FE, $FC, $FF, $D7, $E3, $76, $22, $AA
 EQUB $AB, $BB, $BA, $21, $29, $10, $21, $29
 EQUB $23, $6C, $7C, $7D, $EF, $D7, $EE, $FB
 EQUB $21, $01, $7D, $96, $FF, $55, $8C, $5A
 EQUB $32, $05, $07, $FF, $7F, $FE, $D6, $8E
 EQUB $DC, $E0, $50, $00, $A0, $00, $40, $02
 EQUB $90, $22, $80, $0F, $06, $AA, $54, $E1
 EQUB $BB, $F0, $B5, $58, $21, $14, $7F, $36
 EQUB $3E, $1E, $04, $0F, $4A, $07, $4B, $82
 EQUB $C6, $BB, $45, $C6, $21, $39, $00, $BA
 EQUB $C7, $C6, $7C, $32, $38, $01, $C6, $12
 EQUB $AA, $54, $21, $0E, $BA, $21, $1E, $5A
 EQUB $21, $34, $50, $FC, $F8, $F0, $40, $E0
 EQUB $A4, $C0, $A4, $0F, $0F, $02, $70, $3E
 EQUB $04, $28, $12, $14, $09, $02, $00, $0F
 EQUB $2B, $07, $05, $03, $02, $01, $00, $FE
 EQUB $AA, $21, $38, $10, $82, $21, $11, $44
 EQUB $AA, $21, $01, $AB, $C7, $EF, $7D, $EE
 EQUB $BB, $54, $21, $1C, $40, $21, $28, $90
 EQUB $50, $20, $80, $00, $E0, $A8, $C0, $40
 EQUB $22, $80, $0F, $0F, $0F, $0F, $0F, $0F
 EQUB $08, $3F

; ******************************************************************************
;
;       Name: faceImage11
;       Type: Variable
;   Category: Status
;    Summary: Packed image data for commander face image 11
;  Deep dive: Displaying two-layer images
;             Image and data compression
;
; ------------------------------------------------------------------------------
;
; Each commander image is composed of a face image and a headshot image. You can
; view the combined commander image 11 here:
;
; https://elite.bbcelite.com/images/source/nes/commanderImage11_0.png
;
; ******************************************************************************

.faceImage11

 EQUB $0F, $05, $34, $02, $14, $32, $24, $04
 EQUB $33, $01, $0B, $0D, $CB, $04, $AA, $10
 EQUB $BA, $10, $04, $7D, $13, $04, $80, $50
 EQUB $98, $48, $05, $A0, $60, $A6, $0F, $02
 EQUB $39, $02, $01, $00, $05, $04, $06, $06
 EQUB $01, $01, $23, $03, $21, $01, $02, $21
 EQUB $1A, $9D, $4E, $21, $35, $7E, $F1, $6A
 EQUB $F5, $E5, $E2, $F1, $F8, $FF, $F1, $EA
 EQUB $FD, $AA, $21, $01, $AA, $45, $BA, $AB
 EQUB $FE, $55, $7D, $FE, $55, $10, $21, $01
 EQUB $C7, $FE, $55, $B0, $72, $A5, $58, $FD
 EQUB $21, $1E, $BC, $6E, $4F, $8F, $34, $1F
 EQUB $3F, $FF, $1F, $BE, $7E, $00, $80, $02
 EQUB $22, $40, $22, $C0, $02, $23, $80, $03
 EQUB $39, $05, $04, $05, $05, $03, $09, $0D
 EQUB $17, $00, $24, $01, $33, $03, $1B, $0B
 EQUB $EF, $D7, $F7, $9A, $C7, $64, $21, $01
 EQUB $C8, $FF, $E7, $D7, $FA, $BF, $83, $80
 EQUB $30, $BB, $7D, $C7, $D6, $BB, $44, $EF
 EQUB $54, $BB, $12, $FE, $D7, $AB, $32, $28
 EQUB $38, $FF, $EE, $EB, $B3, $D7, $4B, $32
 EQUB $01, $2F, $FE, $FF, $FB, $AB, $EF, $87
 EQUB $32, $03, $01, $24, $40, $80, $20, $60
 EQUB $D0, $05, $80, $B0, $A0, $36, $0F, $15
 EQUB $01, $0A, $01, $05, $02, $34, $13, $03
 EQUB $03, $01, $04, $21, $3E, $00, $7D, $D3
 EQUB $FE, $55, $62, $B5, $40, $C0, $FE, $FC
 EQUB $FF, $D7, $E3, $76, $82, $AA, $AB, $BB
 EQUB $BA, $21, $29, $10, $21, $29, $44, $22
 EQUB $6C, $7C, $7D, $EF, $D7, $EE, $F9, $21
 EQUB $01, $6D, $96, $EF, $65, $9C, $5A, $32
 EQUB $05, $07, $FF, $6F, $FE, $F6, $9E, $DC
 EQUB $E0, $50, $00, $A0, $00, $40, $02, $90
 EQUB $22, $80, $0F, $06, $AA, $54, $E1, $B5
 EQUB $FA, $B5, $37, $1F, $17, $7F, $3E, $1E
 EQUB $0E, $0F, $23, $4F, $82, $C6, $BB, $45
 EQUB $C6, $21, $39, $83, $FF, $C7, $C6, $7C
 EQUB $32, $38, $01, $C7, $12, $AA, $54, $21
 EQUB $0E, $5A, $BE, $5A, $F0, $D0, $FC, $F8
 EQUB $F0, $22, $E0, $23, $E4, $0F, $0F, $02
 EQUB $7F, $3E, $06, $2F, $13, $16, $09, $02
 EQUB $00, $0E, $2F, $07, $07, $02, $03, $01
 EQUB $00, $FF, $44, $AB, $EF, $FE, $45, $EE
 EQUB $BA, $00, $45, $C7, $FF, $FE, $45, $EF
 EQUB $7C, $FC, $C0, $E8, $90, $D0, $20, $80
 EQUB $00, $E0, $E8, $22, $C0, $22, $80, $0F
 EQUB $0F, $0F, $0F, $0F, $0F, $08, $3F

; ******************************************************************************
;
;       Name: faceImage12
;       Type: Variable
;   Category: Status
;    Summary: Packed image data for commander face image 12
;  Deep dive: Displaying two-layer images
;             Image and data compression
;
; ------------------------------------------------------------------------------
;
; Each commander image is composed of a face image and a headshot image. You can
; view the combined commander image 12 here:
;
; https://elite.bbcelite.com/images/source/nes/commanderImage12_0.png
;
; ******************************************************************************

.faceImage12

 EQUB $0F, $05, $32, $02, $14, $62, $D4, $04
 EQUB $34, $01, $0B, $1D, $2B, $04, $AA, $10
 EQUB $BA, $10, $04, $7D, $13, $04, $80, $50
 EQUB $8C, $56, $05, $A0, $70, $A8, $0F, $01
 EQUB $3C, $01, $02, $03, $02, $07, $04, $00
 EQUB $06, $00, $01, $00, $01, $04, $AA, $F1
 EQUB $AA, $D5, $4E, $B1, $6A, $F5, $55, $21
 EQUB $0E, $55, $00, $21, $3F, $71, $EA, $FD
 EQUB $AA, $21, $01, $AA, $45, $BA, $AB, $FE
 EQUB $55, $7D, $FE, $55, $10, $21, $01, $C7
 EQUB $FE, $55, $AB, $21, $1E, $AB, $56, $E5
 EQUB $21, $1A, $BC, $6E, $54, $E1, $54, $21
 EQUB $01, $F8, $21, $1C, $BE, $7E, $00, $23
 EQUB $80, $C0, $40, $00, $C0, $08, $39, $01
 EQUB $04, $01, $05, $03, $09, $0D, $17, $00
 EQUB $24, $01, $33, $03, $1B, $0B, $EF, $D5
 EQUB $FF, $8F, $B3, $32, $36, $0C, $E0, $FF
 EQUB $E7, $DF, $EF, $F3, $CE, $83, $00, $BB
 EQUB $55, $45, $FF, $BB, $C6, $6C, $21, $28
 EQUB $BB, $FF, $BB, $83, $D7, $AA, $AB, $10
 EQUB $FF, $6E, $EB, $F3, $57, $CB, $61, $21
 EQUB $0F, $FE, $FF, $FB, $EB, $6F, $E7, $83
 EQUB $21, $01, $00, $40, $00, $40, $80, $20
 EQUB $60, $D0, $05, $80, $B0, $A0, $36, $0F
 EQUB $15, $01, $0A, $01, $05, $02, $34, $13
 EQUB $03, $03, $01, $04, $32, $3C, $02, $7D
 EQUB $D3, $FE, $55, $62, $B5, $40, $C2, $FE
 EQUB $FC, $FF, $D7, $E3, $76, $82, $AA, $AB
 EQUB $BB, $10, $21, $29, $82, $C7, $44, $22
 EQUB $6C, $7C, $D7, $EF, $C7, $C6, $69, $81
 EQUB $6D, $96, $EF, $65, $9C, $5A, $21, $05
 EQUB $87, $FF, $6F, $FE, $F6, $9E, $DC, $E0
 EQUB $50, $00, $A0, $00, $40, $02, $90, $22
 EQUB $80, $0F, $06, $AA, $54, $E3, $B9, $FA
 EQUB $B5, $5A, $21, $14, $7F, $36, $3E, $1C
 EQUB $06, $05, $4A, $05, $4B, $BA, $44, $C7
 EQUB $21, $39, $40, $21, $29, $54, $AA, $7D
 EQUB $21, $38, $00, $C6, $BF, $FE, $21, $21
 EQUB $75, $AA, $54, $8E, $21, $3A, $BE, $5A
 EQUB $B4, $50, $FC, $F8, $70, $C0, $40, $A4
 EQUB $40, $A4, $0F, $0F, $02, $75, $3E, $08
 EQUB $25, $08, $12, $06, $09, $03, $0A, $27
 EQUB $0B, $07, $05, $01, $02, $00, $55, $AA
 EQUB $45, $44, $21, $38, $91, $21, $04, $59
 EQUB $20, $6D, $C7, $83, $C7, $6E, $FB, $A6
 EQUB $21, $3C, $20, $48, $A0, $10, $40, $A0
 EQUB $80, $C0, $C8, $A0, $40, $C0, $80, $0F
 EQUB $0F, $0F, $05, $BE, $07, $40, $0F, $0F
 EQUB $09, $3F

; ******************************************************************************
;
;       Name: faceImage13
;       Type: Variable
;   Category: Status
;    Summary: Packed image data for commander face image 13
;  Deep dive: Displaying two-layer images
;             Image and data compression
;
; ------------------------------------------------------------------------------
;
; Each commander image is composed of a face image and a headshot image. You can
; view the combined commander image 13 here:
;
; https://elite.bbcelite.com/images/source/nes/commanderImage13_0.png
;
; ******************************************************************************

.faceImage13

 EQUB $0F, $21, $01, $04, $33, $08, $02, $01
 EQUB $B9, $04, $33, $1C, $06, $33, $C9, $04
 EQUB $21, $1A, $60, $32, $04, $25, $03, $89
 EQUB $42, $46, $64, $AC, $05, $58, $40, $C6
 EQUB $05, $21, $3C, $E0, $8E, $0F, $02, $32
 EQUB $03, $02, $02, $33, $04, $02, $04, $02
 EQUB $38, $03, $02, $00, $02, $00, $01, $44
 EQUB $22, $86, $55, $4E, $B1, $6A, $F5, $6C
 EQUB $21, $24, $30, $00, $21, $3F, $71, $EA
 EQUB $FD, $FF, $21, $18, $A4, $21, $0D, $82
 EQUB $AB, $FE, $55, $22, $AD, $21, $08, $00
 EQUB $21, $01, $C7, $FE, $55, $10, $90, $21
 EQUB $25, $52, $E4, $21, $1B, $BC, $6E, $99
 EQUB $20, $21, $03, $00, $F9, $21, $1C, $BE
 EQUB $7F, $04, $80, $00, $C0, $40, $02, $80
 EQUB $00, $80, $02, $80, $3E, $05, $03, $01
 EQUB $07, $03, $09, $0D, $17, $03, $07, $07
 EQUB $03, $01, $03, $32, $1B, $0B, $EF, $DE
 EQUB $FF, $9F, $DA, $67, $21, $06, $D0, $FF
 EQUB $EF, $DF, $FF, $BA, $8F, $81, $20, $BB
 EQUB $D6, $21, $01, $AB, $92, $C7, $22, $6C
 EQUB $BB, $12, $D7, $FE, $22, $AB, $10, $FF
 EQUB $EF, $EB, $F3, $B7, $CB, $C1, $21, $0F
 EQUB $12, $FB, $EB, $AF, $E7, $32, $03, $01
 EQUB $80, $00, $80, $40, $80, $20, $60, $D0
 EQUB $23, $C0, $80, $00, $80, $B0, $A0, $36
 EQUB $0F, $15, $01, $0A, $01, $05, $02, $34
 EQUB $13, $03, $03, $01, $04, $21, $3C, $00
 EQUB $7D, $D3, $FE, $55, $62, $B5, $40, $C0
 EQUB $FE, $FC, $FF, $D7, $E3, $76, $82, $AA
 EQUB $AB, $BB, $BA, $32, $11, $28, $83, $44
 EQUB $22, $6C, $7C, $7D, $D7, $EF, $C6, $69
 EQUB $21, $01, $6D, $96, $EF, $65, $9C, $5A
 EQUB $32, $05, $07, $FF, $6F, $FE, $F6, $9E
 EQUB $DC, $E0, $50, $00, $A0, $00, $40, $02
 EQUB $90, $22, $80, $0F, $06, $AA, $54, $E3
 EQUB $B9, $FA, $B5, $37, $13, $14, $7F, $3E
 EQUB $1C, $06, $07, $22, $4F, $4E, $C6, $BA
 EQUB $45, $C7, $32, $38, $01, $FF, $AA, $C7
 EQUB $7C, $21, $38, $00, $C7, $12, $6C, $AA
 EQUB $54, $8E, $21, $3A, $BE, $5A, $90, $50
 EQUB $FC, $F8, $70, $22, $C0, $23, $E4, $0F
 EQUB $0F, $02, $72, $3E, $07, $2B, $11, $16
 EQUB $09, $02, $00, $0F, $2F, $07, $07, $03
 EQUB $03, $01, $00, $D6, $22, $45, $C7, $EE
 EQUB $55, $AA, $92, $21, $39, $45, $83, $14
 EQUB $7C, $9C, $C0, $A8, $10, $D0, $20, $80
 EQUB $00, $E0, $E8, $22, $C0, $22, $80, $0F
 EQUB $0F, $0F, $0F, $0F, $0F, $08, $3F

; ******************************************************************************
;
;       Name: headCount
;       Type: Variable
;   Category: Status
;    Summary: The number of commander headshot images in the headOffset table
;
; ******************************************************************************

.headCount

 EQUW 14

; ******************************************************************************
;
;       Name: headOffset
;       Type: Variable
;   Category: Status
;    Summary: Offset to the data for each of the 14 commander headshot images
;
; ******************************************************************************

.headOffset

 EQUW headImage0 - headCount
 EQUW headImage1 - headCount
 EQUW headImage2 - headCount
 EQUW headImage3 - headCount
 EQUW headImage4 - headCount
 EQUW headImage5 - headCount
 EQUW headImage6 - headCount
 EQUW headImage7 - headCount
 EQUW headImage8 - headCount
 EQUW headImage9 - headCount
 EQUW headImage10 - headCount
 EQUW headImage11 - headCount
 EQUW headImage12 - headCount
 EQUW headImage13 - headCount

; ******************************************************************************
;
;       Name: headImage0
;       Type: Variable
;   Category: Status
;    Summary: Packed image data for commander headshot image 0
;  Deep dive: Displaying two-layer images
;             Image and data compression
;
; ------------------------------------------------------------------------------
;
; Each commander image is composed of a face image and a headshot image. You can
; view the combined commander image 0 here:
;
; https://elite.bbcelite.com/images/source/nes/commanderImage0_0.png
;
; ******************************************************************************

.headImage0

 EQUB $1D, $FC, $F0, $E0, $13, $E0, $04, $13
 EQUB $32, $0F, $01, $03, $15, $7F, $32, $1F
 EQUB $0F, $1F, $11, $22, $C0, $23, $80, $0F
 EQUB $04, $22, $07, $23, $03, $21, $01, $81
 EQUB $21, $01, $1D, $FE, $22, $FC, $0D, $21
 EQUB $01, $00, $32, $01, $02, $00, $20, $05
 EQUB $25, $01, $03, $16, $22, $7F, $22, $FC
 EQUB $22, $FE, $14, $22, $01, $03, $21, $02
 EQUB $81, $C0, $00, $32, $21, $01, $02, $81
 EQUB $C2, $81, $32, $01, $09, $03, $21, $02
 EQUB $87, $21, $02, $04, $21, $01, $81, $32
 EQUB $03, $07, $22, $7F, $1E, $28, $E0, $22
 EQUB $03, $06, $22, $80, $06, $28, $0F, $1A
 EQUB $00, $A0, $D7, $13, $C0, $00, $22, $20
 EQUB $60, $22, $E0, $B0, $00, $21, $05, $02
 EQUB $10, $32, $0B, $01, $02, $40, $02, $10
 EQUB $A0, $02, $38, $07, $01, $08, $08, $0D
 EQUB $0F, $0F, $1B, $12, $00, $21, $0A, $D7
 EQUB $14, $F7, $EE, $75, $AA, $55, $21, $22
 EQUB $48, $B0, $DC, $CF, $C3, $A0, $C0, $90
 EQUB $44, $03, $E0, $7F, $21, $0F, $04, $32
 EQUB $01, $0F, $FC, $E0, $02, $21, $1B, $77
 EQUB $E6, $87, $33, $0A, $07, $12, $44, $FF
 EQUB $DF, $EF, $5D, $AA, $55, $88, $34, $25
 EQUB $02, $00, $01, $40, $04, $AA, $40, $21
 EQUB $0A, $20, $21, $0A, $04, $40, $80, $21
 EQUB $08, $A0, $00, $20, $02, $36, $04, $02
 EQUB $20, $0A, $00, $08, $00, $AA, $21, $04
 EQUB $A1, $21, $08, $A0, $03, $80, $02, $21
 EQUB $05, $04, $3F, $0F, $0F, $0F, $0F, $0F
 EQUB $0B, $80, $0F, $0F, $21, $01, $00, $32
 EQUB $01, $02, $00, $20, $0F, $0E, $22, $01
 EQUB $03, $32, $02, $01, $02, $32, $21, $01
 EQUB $02, $81, $C2, $81, $32, $01, $09, $03
 EQUB $21, $02, $87, $21, $02, $05, $80, $0F
 EQUB $0B, $22, $03, $06, $22, $80, $0F, $0A
 EQUB $15, $02, $23, $E0, $23, $F0, $00, $21
 EQUB $05, $02, $10, $32, $0B, $01, $02, $40
 EQUB $02, $10, $A0, $04, $33, $0E, $0F, $0F
 EQUB $23, $1F, $03, $1D, $F8, $FE, $12, $F7
 EQUB $FD, $12, $02, $C0, $13, $21, $1F, $F0
 EQUB $02, $21, $07, $13, $F1, $32, $1F, $3F
 EQUB $13, $DF, $7F, $1C, $EF, $F7, $FB, $F1
 EQUB $F8, $71, $15, $7F, $21, $2F, $56, $FC
 EQUB $FE, $FF, $FE, $FF, $FE, $FF, $FE, $7F
 EQUB $16, $FE, $15, $FD, $E8, $D5, $12, $EF
 EQUB $DF, $BF, $33, $1F, $3F, $1E, $3F

; ******************************************************************************
;
;       Name: headImage1
;       Type: Variable
;   Category: Status
;    Summary: Packed image data for commander headshot image 1
;  Deep dive: Displaying two-layer images
;             Image and data compression
;
; ------------------------------------------------------------------------------
;
; Each commander image is composed of a face image and a headshot image. You can
; view the combined commander image 1 here:
;
; https://elite.bbcelite.com/images/source/nes/commanderImage1_0.png
;
; ******************************************************************************

.headImage1

 EQUB $1D, $FC, $F0, $E0, $13, $E0, $04, $13
 EQUB $32, $0F, $01, $03, $15, $7F, $32, $1F
 EQUB $0F, $1F, $11, $22, $C0, $23, $80, $0F
 EQUB $04, $22, $07, $23, $03, $21, $01, $81
 EQUB $21, $01, $1D, $FE, $22, $FC, $0D, $21
 EQUB $01, $00, $81, $21, $02, $00, $20, $04
 EQUB $31, $02, $25, $01, $03, $16, $22, $7F
 EQUB $22, $FC, $22, $FE, $14, $22, $01, $03
 EQUB $21, $02, $81, $C0, $20, $32, $21, $01
 EQUB $02, $81, $C2, $81, $22, $09, $03, $21
 EQUB $02, $87, $21, $02, $04, $21, $01, $81
 EQUB $32, $03, $07, $22, $7F, $1E, $28, $E0
 EQUB $22, $03, $06, $22, $80, $06, $28, $0F
 EQUB $1A, $00, $A0, $D7, $13, $C0, $00, $22
 EQUB $20, $60, $22, $E0, $B0, $00, $21, $0B
 EQUB $02, $10, $32, $0B, $01, $02, $A0, $02
 EQUB $10, $A0, $02, $38, $07, $01, $08, $08
 EQUB $0D, $0F, $0F, $1B, $12, $00, $21, $0A
 EQUB $D7, $14, $F7, $EE, $75, $AA, $55, $21
 EQUB $22, $48, $B0, $DC, $CF, $C3, $A0, $C0
 EQUB $90, $44, $03, $E0, $7F, $21, $0F, $04
 EQUB $32, $01, $0F, $FC, $E0, $02, $21, $1B
 EQUB $77, $E6, $87, $33, $0A, $07, $12, $44
 EQUB $FF, $DF, $EF, $5D, $AA, $55, $88, $34
 EQUB $25, $02, $00, $01, $40, $04, $AA, $40
 EQUB $21, $0A, $20, $21, $0A, $04, $40, $80
 EQUB $21, $08, $A0, $00, $20, $02, $36, $04
 EQUB $02, $20, $0A, $00, $08, $00, $AA, $21
 EQUB $04, $A1, $21, $08, $A0, $03, $80, $02
 EQUB $21, $05, $04, $3F, $0F, $0F, $0F, $0F
 EQUB $0F, $0B, $80, $0F, $0F, $21, $01, $00
 EQUB $81, $21, $02, $00, $20, $04, $21, $02
 EQUB $0F, $09, $22, $01, $03, $32, $02, $01
 EQUB $00, $20, $32, $21, $01, $02, $81, $C2
 EQUB $81, $22, $09, $03, $21, $02, $87, $21
 EQUB $02, $05, $80, $0F, $0B, $22, $03, $06
 EQUB $22, $80, $0F, $0A, $15, $02, $23, $E0
 EQUB $23, $F0, $00, $21, $0B, $02, $10, $32
 EQUB $0B, $01, $02, $A0, $02, $10, $A0, $04
 EQUB $33, $0E, $0F, $0F, $23, $1F, $03, $1D
 EQUB $F8, $FE, $12, $F7, $FD, $12, $02, $C0
 EQUB $13, $21, $1F, $F0, $02, $21, $07, $13
 EQUB $F1, $32, $1F, $3F, $13, $DF, $7F, $1C
 EQUB $EF, $F7, $FB, $F1, $F8, $71, $15, $7F
 EQUB $21, $2F, $56, $FC, $FE, $FF, $FE, $FF
 EQUB $FE, $FF, $FE, $7F, $16, $FE, $15, $FD
 EQUB $E8, $D5, $12, $EF, $DF, $BF, $33, $1F
 EQUB $3F, $1E, $3F

; ******************************************************************************
;
;       Name: headImage2
;       Type: Variable
;   Category: Status
;    Summary: Packed image data for commander headshot image 2
;  Deep dive: Displaying two-layer images
;             Image and data compression
;
; ------------------------------------------------------------------------------
;
; Each commander image is composed of a face image and a headshot image. You can
; view the combined commander image 2 here:
;
; https://elite.bbcelite.com/images/source/nes/commanderImage2_0.png
;
; ******************************************************************************

.headImage2

 EQUB $1D, $FC, $F0, $E0, $13, $E0, $04, $13
 EQUB $32, $0F, $01, $03, $15, $7F, $32, $1F
 EQUB $0F, $1F, $11, $22, $C0, $23, $80, $0F
 EQUB $04, $22, $07, $23, $03, $21, $01, $81
 EQUB $21, $01, $1D, $FE, $22, $FC, $0B, $B0
 EQUB $00, $22, $01, $04, $21, $1A, $04, $25
 EQUB $01, $03, $16, $22, $7F, $22, $FC, $22
 EQUB $FE, $14, $04, $32, $02, $01, $80, $C0
 EQUB $00, $21, $01, $02, $81, $C2, $81, $21
 EQUB $03, $04, $21, $02, $87, $21, $02, $80
 EQUB $04, $81, $33, $01, $03, $07, $22, $7F
 EQUB $1E, $28, $E0, $21, $03, $07, $80, $07
 EQUB $28, $0F, $1A, $00, $A0, $D7, $13, $C0
 EQUB $00, $22, $20, $60, $22, $E0, $B0, $00
 EQUB $21, $03, $02, $10, $32, $0B, $01, $02
 EQUB $80, $02, $10, $A0, $02, $38, $07, $01
 EQUB $08, $08, $0D, $0F, $0F, $1B, $12, $00
 EQUB $21, $0A, $D7, $14, $F7, $EE, $75, $AA
 EQUB $55, $21, $22, $48, $B0, $DC, $CF, $C3
 EQUB $A0, $C0, $90, $44, $03, $E0, $7F, $21
 EQUB $0F, $04, $32, $01, $0F, $FC, $E0, $02
 EQUB $21, $1B, $77, $E6, $87, $33, $0A, $07
 EQUB $12, $44, $FF, $DF, $EF, $5D, $AA, $55
 EQUB $88, $34, $25, $02, $00, $01, $40, $04
 EQUB $AA, $40, $21, $0A, $20, $21, $0A, $04
 EQUB $40, $80, $21, $08, $A0, $00, $20, $02
 EQUB $36, $04, $02, $20, $0A, $00, $08, $00
 EQUB $AA, $21, $04, $A1, $21, $08, $A0, $03
 EQUB $80, $02, $21, $05, $04, $3F, $0F, $0F
 EQUB $0F, $0F, $0F, $0B, $80, $0F, $0D, $B0
 EQUB $00, $22, $01, $04, $21, $1A, $0F, $0F
 EQUB $02, $32, $02, $01, $03, $21, $01, $02
 EQUB $81, $C2, $81, $21, $03, $04, $21, $02
 EQUB $87, $21, $02, $80, $04, $80, $0F, $0C
 EQUB $21, $03, $07, $80, $0F, $0B, $15, $02
 EQUB $23, $E0, $23, $F0, $00, $21, $03, $02
 EQUB $10, $32, $0B, $01, $02, $80, $02, $10
 EQUB $A0, $04, $33, $0E, $0F, $0F, $23, $1F
 EQUB $03, $1D, $F8, $FE, $12, $F7, $FD, $12
 EQUB $02, $C0, $13, $21, $1F, $F0, $02, $21
 EQUB $07, $13, $F1, $32, $1F, $3F, $13, $DF
 EQUB $7F, $1C, $EF, $F7, $FB, $F1, $F8, $71
 EQUB $15, $7F, $21, $2F, $56, $FC, $FE, $FF
 EQUB $FE, $FF, $FE, $FF, $FE, $7F, $16, $FE
 EQUB $15, $FD, $E8, $D5, $12, $EF, $DF, $BF
 EQUB $33, $1F, $3F, $1E, $3F

; ******************************************************************************
;
;       Name: headImage3
;       Type: Variable
;   Category: Status
;    Summary: Packed image data for commander headshot image 3
;  Deep dive: Displaying two-layer images
;             Image and data compression
;
; ------------------------------------------------------------------------------
;
; Each commander image is composed of a face image and a headshot image. You can
; view the combined commander image 3 here:
;
; https://elite.bbcelite.com/images/source/nes/commanderImage3_0.png
;
; ******************************************************************************

.headImage3

 EQUB $1B, $FE, $22, $FC, $E0, $C0, $12, $F7
 EQUB $20, $04, $12, $6F, $21, $07, $04, $14
 EQUB $34, $3F, $1F, $1F, $0F, $1F, $11, $C0
 EQUB $24, $80, $00, $21, $01, $06, $E0, $50
 EQUB $21, $2A, $05, $35, $0E, $15, $A8, $07
 EQUB $07, $23, $03, $23, $01, $1D, $FE, $22
 EQUB $FC, $08, $84, $00, $21, $13, $02, $21
 EQUB $01, $00, $21, $01, $42, $00, $90, $05
 EQUB $25, $01, $03, $16, $22, $7F, $22, $FC
 EQUB $22, $FE, $14, $00, $21, $01, $03, $21
 EQUB $02, $81, $C0, $00, $32, $21, $01, $02
 EQUB $81, $C2, $81, $00, $21, $09, $03, $21
 EQUB $02, $87, $21, $02, $04, $21, $01, $81
 EQUB $32, $03, $07, $22, $7F, $1E, $28, $E0
 EQUB $22, $03, $06, $22, $80, $06, $28, $0F
 EQUB $18, $21, $01, $F9, $22, $F8, $FF, $FB
 EQUB $12, $C0, $02, $20, $00, $A0, $80, $B0
 EQUB $00, $21, $05, $07, $40, $06, $39, $07
 EQUB $01, $00, $08, $01, $0B, $03, $1B, $00
 EQUB $23, $3F, $FF, $BF, $12, $FB, $FF, $FA
 EQUB $F9, $FA, $F9, $F2, $E1, $A0, $CC, $CB
 EQUB $C3, $E0, $F0, $F8, $7E, $03, $60, $6F
 EQUB $21, $0F, $04, $32, $01, $0D, $EC, $E0
 EQUB $02, $21, $0B, $67, $A6, $87, $33, $0E
 EQUB $1F, $3E, $FD, $BF, $FF, $BF, $21, $3F
 EQUB $BF, $21, $3F, $9F, $34, $0F, $02, $00
 EQUB $01, $05, $BF, $57, $33, $2A, $05, $12
 EQUB $03, $80, $F0, $AA, $5D, $8A, $21, $21
 EQUB $02, $32, $03, $1F, $AA, $75, $A2, $21
 EQUB $08, $02, $FA, $D4, $A9, $40, $90, $03
 EQUB $80, $07, $3F, $0F, $0F, $0F, $0F, $02
 EQUB $21, $01, $06, $E0, $50, $21, $2A, $05
 EQUB $32, $0E, $15, $A8, $0F, $0F, $02, $84
 EQUB $00, $21, $13, $02, $21, $01, $00, $21
 EQUB $01, $42, $00, $90, $0F, $0F, $21, $01
 EQUB $03, $32, $02, $01, $02, $32, $21, $01
 EQUB $02, $81, $C2, $81, $00, $21, $09, $03
 EQUB $21, $02, $87, $21, $02, $05, $80, $0F
 EQUB $0B, $22, $03, $06, $22, $80, $0F, $08
 EQUB $22, $FC, $15, $02, $A0, $E0, $A0, $F0
 EQUB $B0, $F0, $00, $21, $05, $07, $40, $08
 EQUB $36, $0A, $0F, $0B, $1F, $1B, $1F, $00
 EQUB $22, $7F, $1A, $22, $FB, $F7, $F8, $FE
 EQUB $EF, $EB, $F3, $FD, $12, $03, $EF, $7F
 EQUB $6F, $21, $0F, $F0, $02, $21, $01, $EF
 EQUB $FD, $ED, $E1, $32, $1F, $3F, $FF, $EF
 EQUB $AF, $9F, $7F, $17, $22, $BF, $DF, $E7
 EQUB $22, $0F, $57, $FB, $F1, $F8, $F1, $15
 EQUB $7F, $21, $2F, $56, $1F, $FE, $15, $FD
 EQUB $E8, $D5, $CF, $22, $E0, $D5, $BF, $33
 EQUB $1F, $3F, $1E, $3F

; ******************************************************************************
;
;       Name: headImage4
;       Type: Variable
;   Category: Status
;    Summary: Packed image data for commander headshot image 4
;  Deep dive: Displaying two-layer images
;             Image and data compression
;
; ------------------------------------------------------------------------------
;
; Each commander image is composed of a face image and a headshot image. You can
; view the combined commander image 4 here:
;
; https://elite.bbcelite.com/images/source/nes/commanderImage4_0.png
;
; ******************************************************************************

.headImage4

 EQUB $1B, $FE, $22, $FC, $E0, $C0, $12, $F7
 EQUB $20, $04, $12, $6F, $21, $07, $04, $14
 EQUB $34, $3F, $1F, $1F, $0F, $1F, $11, $C0
 EQUB $24, $80, $00, $21, $01, $06, $E0, $50
 EQUB $21, $2A, $05, $35, $0E, $15, $A8, $07
 EQUB $07, $23, $03, $23, $01, $1D, $FE, $22
 EQUB $FC, $08, $84, $00, $21, $0B, $02, $21
 EQUB $01, $00, $21, $01, $42, $00, $A0, $05
 EQUB $25, $01, $03, $16, $22, $7F, $22, $FC
 EQUB $22, $FE, $14, $22, $01, $03, $21, $02
 EQUB $81, $C0, $00, $32, $21, $01, $02, $81
 EQUB $C2, $81, $32, $01, $09, $03, $21, $02
 EQUB $87, $21, $02, $04, $21, $01, $81, $32
 EQUB $03, $07, $22, $7F, $1E, $28, $E0, $22
 EQUB $03, $06, $22, $80, $06, $28, $0F, $18
 EQUB $21, $01, $F9, $22, $F8, $FF, $FB, $12
 EQUB $C0, $02, $20, $00, $A0, $80, $B0, $00
 EQUB $21, $0B, $07, $A0, $06, $39, $07, $01
 EQUB $00, $08, $01, $0B, $03, $1B, $00, $23
 EQUB $3F, $FF, $BF, $12, $FB, $FF, $FA, $F9
 EQUB $FA, $F9, $F2, $E1, $A0, $CC, $CB, $C3
 EQUB $E0, $F0, $F8, $7E, $03, $60, $6F, $21
 EQUB $0F, $04, $32, $01, $0D, $EC, $E0, $02
 EQUB $21, $0B, $67, $A6, $87, $33, $0E, $1F
 EQUB $3E, $FD, $BF, $FF, $BF, $21, $3F, $BF
 EQUB $21, $3F, $9F, $34, $0F, $02, $00, $01
 EQUB $05, $BF, $57, $33, $2A, $05, $12, $03
 EQUB $80, $F0, $AA, $5D, $8A, $21, $21, $02
 EQUB $32, $03, $1F, $AA, $75, $A2, $21, $08
 EQUB $02, $FA, $D4, $A9, $40, $90, $03, $80
 EQUB $07, $3F, $0F, $0F, $0F, $0F, $02, $21
 EQUB $01, $06, $E0, $50, $21, $2A, $05, $32
 EQUB $0E, $15, $A8, $0F, $0F, $02, $84, $00
 EQUB $21, $0B, $02, $21, $01, $00, $21, $01
 EQUB $42, $00, $A0, $0F, $0E, $22, $01, $03
 EQUB $32, $02, $01, $02, $32, $21, $01, $02
 EQUB $81, $C2, $81, $32, $01, $09, $03, $21
 EQUB $02, $87, $21, $02, $05, $80, $0F, $0B
 EQUB $22, $03, $06, $22, $80, $0F, $08, $22
 EQUB $FC, $15, $02, $A0, $E0, $A0, $F0, $B0
 EQUB $F0, $00, $21, $0B, $07, $A0, $08, $36
 EQUB $0A, $0F, $0B, $1F, $1B, $1F, $00, $22
 EQUB $7F, $1A, $22, $FB, $F7, $F8, $FE, $EF
 EQUB $EB, $F3, $FD, $12, $03, $EF, $7F, $6F
 EQUB $21, $0F, $F0, $02, $21, $01, $EF, $FD
 EQUB $ED, $E1, $32, $1F, $3F, $FF, $EF, $AF
 EQUB $9F, $7F, $17, $22, $BF, $DF, $E7, $22
 EQUB $0F, $57, $FB, $F1, $F8, $F1, $15, $7F
 EQUB $21, $2F, $56, $1F, $FE, $15, $FD, $E8
 EQUB $D5, $CF, $22, $E0, $D5, $BF, $33, $1F
 EQUB $3F, $1E, $3F

; ******************************************************************************
;
;       Name: headImage5
;       Type: Variable
;   Category: Status
;    Summary: Packed image data for commander headshot image 5
;  Deep dive: Displaying two-layer images
;             Image and data compression
;
; ------------------------------------------------------------------------------
;
; Each commander image is composed of a face image and a headshot image. You can
; view the combined commander image 5 here:
;
; https://elite.bbcelite.com/images/source/nes/commanderImage5_0.png
;
; ******************************************************************************

.headImage5

 EQUB $1B, $FE, $22, $FC, $E0, $C0, $12, $F7
 EQUB $20, $04, $12, $6F, $21, $07, $04, $14
 EQUB $34, $3F, $1F, $1F, $0F, $1F, $11, $C0
 EQUB $24, $80, $00, $21, $01, $06, $E0, $50
 EQUB $21, $2A, $05, $35, $0E, $15, $A8, $07
 EQUB $07, $23, $03, $23, $01, $1D, $FE, $22
 EQUB $FC, $08, $21, $04, $02, $B0, $00, $22
 EQUB $01, $00, $40, $06, $31, $02, $25, $01
 EQUB $03, $16, $22, $7F, $22, $FC, $22, $FE
 EQUB $14, $04, $32, $02, $01, $80, $C0, $00
 EQUB $21, $01, $02, $81, $C2, $81, $33, $03
 EQUB $09, $09, $03, $82, $21, $07, $82, $04
 EQUB $21, $01, $81, $32, $03, $07, $22, $7F
 EQUB $1E, $28, $E0, $21, $03, $07, $80, $07
 EQUB $28, $0F, $18, $21, $01, $F9, $22, $F8
 EQUB $FF, $FB, $12, $C0, $02, $20, $00, $A0
 EQUB $80, $B0, $00, $21, $03, $07, $80, $06
 EQUB $39, $07, $01, $00, $08, $01, $0B, $03
 EQUB $1B, $00, $23, $3F, $FF, $BF, $12, $FB
 EQUB $FF, $FA, $F9, $FA, $F9, $F2, $E1, $A0
 EQUB $CC, $CB, $C3, $E0, $F0, $F8, $7E, $03
 EQUB $60, $6F, $21, $0F, $04, $32, $01, $0D
 EQUB $EC, $E0, $02, $21, $0B, $67, $A6, $87
 EQUB $33, $0E, $1F, $3E, $FD, $BF, $FF, $BF
 EQUB $21, $3F, $BF, $21, $3F, $9F, $34, $0F
 EQUB $02, $00, $01, $05, $BF, $57, $33, $2A
 EQUB $05, $12, $03, $80, $F0, $AA, $5D, $8A
 EQUB $21, $21, $02, $32, $03, $1F, $AA, $75
 EQUB $A2, $21, $08, $02, $FA, $D4, $A9, $40
 EQUB $90, $03, $80, $07, $3F, $0F, $0F, $0F
 EQUB $0F, $02, $21, $01, $06, $E0, $50, $21
 EQUB $2A, $05, $32, $0E, $15, $A8, $0F, $0F
 EQUB $02, $21, $04, $02, $B0, $00, $22, $01
 EQUB $00, $40, $06, $21, $02, $0F, $0D, $32
 EQUB $02, $01, $03, $21, $01, $02, $81, $C2
 EQUB $81, $33, $03, $09, $09, $03, $82, $21
 EQUB $07, $82, $05, $80, $0F, $0B, $21, $03
 EQUB $07, $80, $0F, $09, $22, $FC, $15, $02
 EQUB $A0, $E0, $A0, $F0, $B0, $F0, $00, $21
 EQUB $03, $07, $80, $08, $36, $0A, $0F, $0B
 EQUB $1F, $1B, $1F, $00, $22, $7F, $1A, $22
 EQUB $FB, $F7, $F8, $FE, $EF, $EB, $F3, $FD
 EQUB $12, $03, $EF, $7F, $6F, $21, $0F, $F0
 EQUB $02, $21, $01, $EF, $FD, $ED, $E1, $32
 EQUB $1F, $3F, $FF, $EF, $AF, $9F, $7F, $17
 EQUB $22, $BF, $DF, $E7, $22, $0F, $57, $FB
 EQUB $F1, $F8, $F1, $15, $7F, $21, $2F, $56
 EQUB $1F, $FE, $15, $FD, $E8, $D5, $CF, $22
 EQUB $E0, $D5, $BF, $33, $1F, $3F, $1E, $3F

; ******************************************************************************
;
;       Name: headImage6
;       Type: Variable
;   Category: Status
;    Summary: Packed image data for commander headshot image 6
;  Deep dive: Displaying two-layer images
;             Image and data compression
;
; ------------------------------------------------------------------------------
;
; Each commander image is composed of a face image and a headshot image. You can
; view the combined commander image 6 here:
;
; https://elite.bbcelite.com/images/source/nes/commanderImage6_0.png
;
; ******************************************************************************

.headImage6

 EQUB $1D, $FC, $F0, $E0, $13, $E0, $04, $13
 EQUB $32, $0F, $01, $03, $15, $7F, $32, $1F
 EQUB $0F, $1F, $11, $22, $C0, $23, $80, $00
 EQUB $21, $01, $06, $E0, $50, $21, $2A, $05
 EQUB $35, $0E, $15, $A8, $07, $07, $23, $03
 EQUB $23, $01, $1D, $FE, $22, $FC, $08, $21
 EQUB $04, $80, $21, $35, $02, $21, $01, $00
 EQUB $21, $01, $40, $21, $02, $58, $05, $25
 EQUB $01, $03, $16, $22, $7F, $22, $FC, $22
 EQUB $FE, $14, $00, $21, $01, $03, $21, $02
 EQUB $81, $C0, $00, $32, $21, $01, $02, $81
 EQUB $C2, $81, $00, $21, $09, $03, $21, $02
 EQUB $87, $21, $02, $04, $21, $01, $81, $32
 EQUB $03, $07, $22, $7F, $1C, $21, $01, $F9
 EQUB $28, $E0, $22, $03, $06, $22, $80, $06
 EQUB $28, $0F, $16, $00, $21, $3F, $F9, $22
 EQUB $F8, $FC, $FB, $13, $C0, $02, $20, $00
 EQUB $A0, $80, $B0, $00, $21, $05, $07, $40
 EQUB $06, $21, $07, $02, $35, $08, $01, $0B
 EQUB $03, $1B, $23, $3F, $7F, $BF, $13, $FB
 EQUB $FF, $FA, $F9, $FA, $F9, $F1, $E3, $A0
 EQUB $CC, $CB, $C3, $E0, $40, $FC, $FF, $03
 EQUB $60, $6F, $21, $0F, $00, $80, $02, $32
 EQUB $01, $0D, $EC, $E0, $00, $32, $03, $0B
 EQUB $67, $A6, $87, $32, $0E, $05, $7F, $FF
 EQUB $BF, $FF, $BF, $21, $3F, $BF, $33, $3F
 EQUB $1F, $8F, $23, $07, $24, $0F, $21, $07
 EQUB $18, $FC, $23, $FE, $FF, $FE, $12, $7F
 EQUB $1F, $23, $C0, $24, $E0, $C0, $3F, $0F
 EQUB $0F, $0F, $0F, $02, $21, $01, $06, $E0
 EQUB $50, $21, $2A, $05, $32, $0E, $15, $A8
 EQUB $0F, $0F, $02, $21, $04, $80, $21, $35
 EQUB $02, $21, $01, $00, $21, $01, $40, $21
 EQUB $02, $58, $0F, $0F, $21, $01, $03, $32
 EQUB $02, $01, $02, $32, $21, $01, $02, $81
 EQUB $C2, $81, $00, $21, $09, $03, $21, $02
 EQUB $87, $21, $02, $05, $80, $0F, $02, $FC
 EQUB $08, $22, $03, $06, $22, $80, $0F, $06
 EQUB $7F, $23, $FC, $15, $02, $A0, $E0, $A0
 EQUB $F0, $B0, $F0, $00, $21, $05, $07, $40
 EQUB $08, $36, $0A, $0F, $0B, $1F, $1B, $1F
 EQUB $23, $7F, $1A, $22, $FB, $F7, $F8, $FE
 EQUB $EF, $EB, $F3, $FD, $12, $03, $EF, $7F
 EQUB $6F, $21, $0F, $F0, $02, $21, $01, $EF
 EQUB $FD, $ED, $E1, $32, $1F, $3F, $FF, $EF
 EQUB $AF, $9F, $7F, $17, $22, $BF, $DF, $E7
 EQUB $22, $0F, $4F, $24, $EF, $1F, $1F, $12
 EQUB $CF, $22, $E0, $E5, $23, $EF, $EE, $3F

; ******************************************************************************
;
;       Name: headImage7
;       Type: Variable
;   Category: Status
;    Summary: Packed image data for commander headshot image 7
;  Deep dive: Displaying two-layer images
;             Image and data compression
;
; ------------------------------------------------------------------------------
;
; Each commander image is composed of a face image and a headshot image. You can
; view the combined commander image 7 here:
;
; https://elite.bbcelite.com/images/source/nes/commanderImage7_0.png
;
; ******************************************************************************

.headImage7

 EQUB $1D, $FC, $F0, $E0, $13, $E0, $04, $13
 EQUB $32, $0F, $01, $03, $15, $7F, $32, $1F
 EQUB $0F, $1F, $11, $22, $C0, $23, $80, $00
 EQUB $21, $01, $06, $E0, $50, $21, $2A, $05
 EQUB $35, $0E, $15, $A8, $07, $07, $23, $03
 EQUB $23, $01, $1D, $FE, $22, $FC, $08, $84
 EQUB $00, $21, $13, $02, $21, $01, $00, $21
 EQUB $01, $42, $00, $90, $05, $25, $01, $03
 EQUB $16, $22, $7F, $22, $FC, $22, $FE, $14
 EQUB $00, $21, $01, $03, $21, $02, $81, $C0
 EQUB $00, $32, $21, $01, $02, $81, $C2, $81
 EQUB $00, $21, $09, $03, $21, $02, $87, $21
 EQUB $02, $04, $21, $01, $81, $32, $03, $07
 EQUB $22, $7F, $1C, $21, $01, $F9, $28, $E0
 EQUB $22, $03, $06, $22, $80, $06, $28, $0F
 EQUB $16, $00, $21, $3F, $F9, $22, $F8, $FC
 EQUB $FB, $13, $C0, $02, $20, $00, $A0, $80
 EQUB $B0, $00, $21, $05, $07, $40, $06, $21
 EQUB $07, $02, $35, $08, $01, $0B, $03, $1B
 EQUB $23, $3F, $7F, $BF, $13, $FB, $FF, $FA
 EQUB $F9, $FA, $F9, $F1, $E3, $A0, $CC, $CB
 EQUB $C3, $E0, $40, $FC, $FF, $03, $60, $6F
 EQUB $21, $0F, $00, $80, $02, $32, $01, $0D
 EQUB $EC, $E0, $00, $32, $03, $0B, $67, $A6
 EQUB $87, $32, $0E, $05, $7F, $FF, $BF, $FF
 EQUB $BF, $21, $3F, $BF, $33, $3F, $1F, $8F
 EQUB $23, $07, $24, $0F, $21, $07, $18, $FC
 EQUB $23, $FE, $FF, $FE, $12, $7F, $1F, $23
 EQUB $C0, $24, $E0, $C0, $3F, $0F, $0F, $0F
 EQUB $0F, $02, $21, $01, $06, $E0, $50, $21
 EQUB $2A, $05, $32, $0E, $15, $A8, $0F, $0F
 EQUB $02, $84, $00, $21, $13, $02, $21, $01
 EQUB $00, $21, $01, $42, $00, $90, $0F, $0F
 EQUB $21, $01, $03, $32, $02, $01, $02, $32
 EQUB $21, $01, $02, $81, $C2, $81, $00, $21
 EQUB $09, $03, $21, $02, $87, $21, $02, $05
 EQUB $80, $0F, $02, $FC, $08, $22, $03, $06
 EQUB $22, $80, $0F, $06, $7F, $23, $FC, $15
 EQUB $02, $A0, $E0, $A0, $F0, $B0, $F0, $00
 EQUB $21, $05, $07, $40, $08, $36, $0A, $0F
 EQUB $0B, $1F, $1B, $1F, $23, $7F, $1A, $22
 EQUB $FB, $F7, $F8, $FE, $EF, $EB, $F3, $FD
 EQUB $12, $03, $EF, $7F, $6F, $21, $0F, $F0
 EQUB $02, $21, $01, $EF, $FD, $ED, $E1, $32
 EQUB $1F, $3F, $FF, $EF, $AF, $9F, $7F, $17
 EQUB $22, $BF, $DF, $E7, $22, $0F, $4F, $24
 EQUB $EF, $1F, $1F, $12, $CF, $22, $E0, $E5
 EQUB $23, $EF, $EE, $3F

; ******************************************************************************
;
;       Name: headImage8
;       Type: Variable
;   Category: Status
;    Summary: Packed image data for commander headshot image 8
;  Deep dive: Displaying two-layer images
;             Image and data compression
;
; ------------------------------------------------------------------------------
;
; Each commander image is composed of a face image and a headshot image. You can
; view the combined commander image 8 here:
;
; https://elite.bbcelite.com/images/source/nes/commanderImage8_0.png
;
; ******************************************************************************

.headImage8

 EQUB $1D, $FC, $F0, $E0, $13, $E0, $04, $13
 EQUB $32, $0F, $01, $03, $15, $7F, $32, $1F
 EQUB $0F, $1F, $11, $22, $C0, $23, $80, $00
 EQUB $21, $01, $06, $E0, $50, $21, $2A, $05
 EQUB $35, $0E, $15, $A8, $07, $07, $23, $03
 EQUB $23, $01, $1D, $FE, $22, $FC, $08, $21
 EQUB $04, $00, $81, $10, $00, $21, $01, $00
 EQUB $21, $01, $40, $00, $21, $02, $10, $04
 EQUB $25, $01, $03, $16, $22, $7F, $22, $FC
 EQUB $22, $FE, $14, $00, $21, $01, $03, $21
 EQUB $02, $81, $C0, $00, $32, $21, $01, $02
 EQUB $81, $C2, $81, $00, $21, $09, $03, $21
 EQUB $02, $87, $21, $02, $04, $21, $01, $81
 EQUB $32, $03, $07, $22, $7F, $16, $00, $27
 EQUB $FE, $23, $C0, $05, $22, $03, $06, $22
 EQUB $80, $06, $23, $06, $06, $17, $28, $FE
 EQUB $09, $21, $05, $02, $10, $32, $0B, $01
 EQUB $02, $40, $02, $10, $A0, $0A, $18, $22
 EQUB $FE, $FC, $F8, $F0, $E0, $C0, $21, $01
 EQUB $02, $21, $01, $02, $78, $12, $02, $FF
 EQUB $00, $7F, $21, $01, $00, $E0, $02, $FF
 EQUB $00, $FC, $00, $32, $01, $0F, $05, $21
 EQUB $3C, $FE, $13, $7F, $38, $3F, $1F, $0F
 EQUB $07, $00, $03, $07, $07, $23, $0F, $CF
 EQUB $21, $07, $18, $FC, $23, $FE, $FF, $FE
 EQUB $12, $7F, $1F, $80, $22, $C0, $23, $E0
 EQUB $E6, $C0, $3F, $0F, $0F, $0F, $0F, $02
 EQUB $21, $01, $06, $E0, $50, $21, $2A, $05
 EQUB $32, $0E, $15, $A8, $0F, $0F, $02, $21
 EQUB $04, $00, $81, $10, $00, $21, $01, $00
 EQUB $21, $01, $40, $00, $21, $02, $10, $0F
 EQUB $0E, $21, $01, $03, $32, $02, $01, $02
 EQUB $32, $21, $01, $02, $81, $C2, $81, $00
 EQUB $21, $09, $03, $21, $02, $87, $21, $02
 EQUB $05, $80, $0B, $27, $FE, $05, $40, $E0
 EQUB $40, $22, $03, $06, $22, $80, $0B, $33
 EQUB $04, $0E, $04, $00, $17, $28, $FE, $20
 EQUB $40, $00, $10, $05, $21, $05, $02, $10
 EQUB $32, $0B, $01, $02, $40, $02, $10, $A0
 EQUB $02, $32, $08, $04, $00, $10, $04, $18
 EQUB $24, $FE, $FC, $F8, $F1, $E3, $02, $57
 EQUB $00, $21, $01, $FC, $12, $02, $FF, $21
 EQUB $3F, $FF, $57, $8B, $F1, $02, $FF, $F8
 EQUB $FF, $D4, $A3, $21, $1F, $02, $D4, $02
 EQUB $7E, $16, $7F, $32, $3F, $1F, $8F, $C7
 EQUB $23, $0F, $23, $EF, $CF, $1F, $1F, $12
 EQUB $C7, $23, $E0, $23, $EF, $E6, $3F

; ******************************************************************************
;
;       Name: headImage9
;       Type: Variable
;   Category: Status
;    Summary: Packed image data for commander headshot image 9
;  Deep dive: Displaying two-layer images
;             Image and data compression
;
; ------------------------------------------------------------------------------
;
; Each commander image is composed of a face image and a headshot image. You can
; view the combined commander image 9 here:
;
; https://elite.bbcelite.com/images/source/nes/commanderImage9_0.png
;
; ******************************************************************************

.headImage9

 EQUB $1B, $FE, $22, $FC, $E0, $C0, $12, $F7
 EQUB $20, $04, $12, $6F, $21, $03, $04, $14
 EQUB $34, $3F, $1F, $1F, $0F, $1F, $11, $C0
 EQUB $24, $80, $00, $21, $01, $06, $E0, $50
 EQUB $21, $2A, $05, $37, $0E, $15, $A8, $07
 EQUB $07, $03, $03, $24, $01, $1D, $FE, $22
 EQUB $FC, $08, $21, $04, $22, $80, $50, $00
 EQUB $22, $01, $00, $40, $00, $32, $02, $14
 EQUB $04, $23, $01, $81, $21, $01, $03, $16
 EQUB $22, $7F, $22, $FC, $22, $FE, $14, $00
 EQUB $21, $01, $03, $21, $02, $81, $C0, $33
 EQUB $01, $21, $01, $02, $81, $C2, $81, $00
 EQUB $21, $09, $03, $21, $02, $87, $21, $02
 EQUB $04, $21, $01, $81, $32, $03, $07, $22
 EQUB $7F, $16, $00, $27, $FE, $23, $C0, $05
 EQUB $22, $03, $06, $22, $80, $06, $23, $06
 EQUB $06, $17, $28, $FE, $09, $21, $05, $07
 EQUB $40, $0E, $18, $22, $FE, $FC, $F8, $F0
 EQUB $E0, $C0, $03, $21, $01, $07, $FF, $00
 EQUB $7F, $21, $01, $04, $FF, $00, $FC, $0B
 EQUB $12, $7F, $34, $3F, $1F, $0F, $07, $04
 EQUB $22, $01, $00, $C2, $02, $21, $01, $60
 EQUB $F8, $32, $04, $01, $04, $60, $32, $1F
 EQUB $03, $04, $32, $01, $0C, $F0, $80, $21
 EQUB $01, $04, $32, $0C, $3F, $41, $09, $86
 EQUB $00, $3F, $0F, $0F, $0F, $0F, $02, $21
 EQUB $01, $06, $E0, $50, $21, $2A, $05, $32
 EQUB $0E, $15, $A8, $0F, $0F, $02, $21, $04
 EQUB $22, $80, $50, $00, $22, $01, $00, $40
 EQUB $00, $32, $02, $14, $07, $80, $0F, $06
 EQUB $21, $01, $03, $36, $02, $01, $00, $01
 EQUB $21, $01, $02, $81, $C2, $81, $00, $21
 EQUB $09, $03, $21, $02, $87, $21, $02, $05
 EQUB $80, $0B, $27, $FE, $05, $40, $E0, $40
 EQUB $22, $03, $06, $22, $80, $0B, $33, $04
 EQUB $0E, $04, $00, $17, $28, $FE, $20, $40
 EQUB $00, $10, $05, $21, $05, $07, $40, $06
 EQUB $32, $08, $04, $00, $10, $04, $18, $24
 EQUB $FE, $FC, $F8, $F0, $E0, $02, $57, $00
 EQUB $32, $0B, $02, $20, $10, $02, $FF, $21
 EQUB $3F, $FF, $57, $8B, $21, $01, $02, $FF
 EQUB $F8, $FF, $D4, $A2, $03, $D4, $00, $A0
 EQUB $80, $21, $08, $10, $14, $7F, $33, $3F
 EQUB $1F, $0F, $C0, $00, $32, $01, $03, $E3
 EQUB $22, $E7, $C7, $21, $0C, $67, $FB, $FD
 EQUB $14, $00, $80, $F8, $FF, $BF, $FF, $F4
 EQUB $FE, $00, $32, $03, $3F, $FF, $FB, $FF
 EQUB $5F, $FF, $60, $CC, $BF, $7F, $14, $21
 EQUB $07, $02, $80, $8F, $22, $CF, $C6, $3F

; ******************************************************************************
;
;       Name: headImage10
;       Type: Variable
;   Category: Status
;    Summary: Packed image data for commander headshot image 10
;  Deep dive: Displaying two-layer images
;             Image and data compression
;
; ------------------------------------------------------------------------------
;
; Each commander image is composed of a face image and a headshot image. You can
; view the combined commander image 10 here:
;
; https://elite.bbcelite.com/images/source/nes/commanderImage10_0.png
;
; ******************************************************************************

.headImage10

 EQUB $1A, $FE, $22, $FC, $22, $F0, $E0, $12
 EQUB $21, $34, $05, $FF, $6F, $21, $07, $05
 EQUB $13, $31, $3F, $23, $1F, $21, $0F, $1F
 EQUB $11, $C0, $C2, $85, $80, $33, $05, $02
 EQUB $01, $04, $80, $40, $E0, $50, $21, $2A
 EQUB $04, $36, $01, $0E, $15, $A8, $07, $07
 EQUB $43, $A3, $C1, $81, $22, $01, $1D, $FE
 EQUB $22, $FC, $08, $21, $04, $22, $80, $50
 EQUB $00, $22, $01, $00, $40, $00, $32, $02
 EQUB $14, $04, $23, $01, $81, $21, $01, $03
 EQUB $16, $22, $7F, $22, $FC, $22, $FE, $14
 EQUB $00, $21, $01, $03, $21, $02, $81, $C0
 EQUB $33, $01, $21, $01, $02, $81, $C2, $81
 EQUB $00, $21, $09, $03, $21, $02, $87, $21
 EQUB $02, $04, $21, $01, $81, $32, $03, $07
 EQUB $22, $7F, $16, $00, $21, $04, $22, $FE
 EQUB $23, $04, $00, $23, $C0, $05, $22, $03
 EQUB $06, $22, $80, $06, $23, $06, $06, $40
 EQUB $12, $23, $40, $00, $21, $04, $02, $21
 EQUB $04, $0D, $21, $05, $07, $40, $0E, $40
 EQUB $02, $40, $0E, $21, $01, $07, $FF, $00
 EQUB $7F, $21, $01, $04, $FF, $00, $FC, $0F
 EQUB $07, $22, $01, $00, $21, $02, $02, $21
 EQUB $01, $60, $F8, $32, $04, $01, $04, $60
 EQUB $32, $1F, $03, $04, $32, $01, $0C, $F0
 EQUB $80, $21, $01, $04, $32, $0C, $3F, $41
 EQUB $09, $80, $00, $3F, $0F, $0F, $0F, $0C
 EQUB $36, $02, $05, $00, $05, $02, $01, $04
 EQUB $80, $40, $E0, $50, $21, $2A, $04, $33
 EQUB $01, $0E, $15, $A8, $02, $40, $A0, $C0
 EQUB $80, $0F, $0B, $21, $04, $22, $80, $50
 EQUB $00, $22, $01, $00, $40, $00, $32, $02
 EQUB $14, $07, $80, $0F, $06, $21, $01, $03
 EQUB $36, $02, $01, $00, $01, $21, $01, $02
 EQUB $81, $C2, $81, $00, $21, $09, $03, $21
 EQUB $02, $87, $21, $02, $05, $80, $0B, $27
 EQUB $FE, $05, $40, $E0, $40, $22, $03, $06
 EQUB $22, $80, $0B, $33, $04, $0E, $04, $00
 EQUB $17, $28, $FE, $20, $40, $00, $10, $05
 EQUB $21, $05, $07, $40, $06, $32, $08, $04
 EQUB $00, $10, $04, $18, $22, $FE, $F0, $C0
 EQUB $21, $06, $10, $40, $80, $02, $57, $00
 EQUB $32, $0B, $02, $20, $10, $02, $FF, $21
 EQUB $1F, $FF, $57, $8B, $21, $01, $02, $FF
 EQUB $F8, $FF, $D4, $A2, $03, $D4, $00, $A0
 EQUB $80, $21, $08, $10, $12, $32, $1F, $07
 EQUB $C1, $10, $32, $04, $02, $02, $33, $01
 EQUB $03, $03, $87, $22, $C7, $21, $0C, $67
 EQUB $FB, $FD, $14, $00, $80, $F8, $FF, $BF
 EQUB $FF, $F4, $FE, $00, $32, $03, $3F, $FF
 EQUB $FB, $FF, $5F, $FF, $60, $CC, $BF, $7F
 EQUB $14, $21, $01, $02, $22, $80, $C3, $22
 EQUB $C7, $3F

; ******************************************************************************
;
;       Name: headImage11
;       Type: Variable
;   Category: Status
;    Summary: Packed image data for commander headshot image 11
;  Deep dive: Displaying two-layer images
;             Image and data compression
;
; ------------------------------------------------------------------------------
;
; Each commander image is composed of a face image and a headshot image. You can
; view the combined commander image 11 here:
;
; https://elite.bbcelite.com/images/source/nes/commanderImage11_0.png
;
; ******************************************************************************

.headImage11

 EQUB $1D, $FC, $F0, $E0, $13, $E0, $04, $13
 EQUB $32, $0F, $01, $03, $15, $7F, $32, $1F
 EQUB $0F, $1F, $11, $22, $C0, $23, $80, $00
 EQUB $21, $01, $06, $E0, $50, $21, $2A, $05
 EQUB $35, $0E, $14, $A8, $07, $07, $23, $03
 EQUB $23, $01, $1D, $FE, $22, $FC, $08, $21
 EQUB $04, $22, $80, $50, $00, $22, $01, $00
 EQUB $40, $02, $21, $14, $04, $22, $01, $22
 EQUB $41, $21, $01, $03, $16, $22, $7F, $22
 EQUB $FC, $22, $FE, $14, $00, $21, $01, $03
 EQUB $21, $02, $81, $C0, $33, $03, $21, $01
 EQUB $02, $81, $C2, $81, $80, $21, $09, $04
 EQUB $86, $21, $02, $04, $21, $01, $81, $32
 EQUB $03, $07, $22, $7F, $16, $00, $21, $04
 EQUB $22, $FE, $23, $04, $00, $23, $C0, $05
 EQUB $22, $03, $06, $22, $80, $06, $23, $06
 EQUB $06, $40, $12, $23, $40, $00, $21, $04
 EQUB $02, $21, $04, $0D, $21, $0B, $02, $10
 EQUB $32, $0B, $01, $02, $A0, $02, $10, $A0
 EQUB $0A, $40, $02, $40, $0E, $21, $01, $07
 EQUB $FF, $00, $7F, $21, $01, $04, $FF, $00
 EQUB $FC, $0F, $0D, $21, $01, $08, $60, $32
 EQUB $1F, $03, $04, $32, $01, $0C, $F0, $80
 EQUB $0F, $04, $3F, $0F, $0F, $0F, $0F, $02
 EQUB $21, $01, $06, $E0, $50, $21, $2A, $05
 EQUB $32, $0E, $14, $A8, $0F, $0F, $02, $21
 EQUB $04, $22, $80, $50, $00, $22, $01, $00
 EQUB $40, $02, $21, $14, $06, $22, $40, $0F
 EQUB $06, $21, $01, $03, $36, $02, $01, $00
 EQUB $03, $21, $01, $02, $81, $C2, $81, $80
 EQUB $21, $09, $04, $86, $21, $02, $05, $80
 EQUB $0B, $27, $FE, $05, $40, $E0, $40, $22
 EQUB $03, $06, $22, $80, $0B, $33, $04, $0E
 EQUB $04, $00, $17, $28, $FE, $20, $40, $00
 EQUB $10, $05, $21, $0B, $02, $10, $32, $0B
 EQUB $01, $02, $A0, $02, $10, $A0, $02, $32
 EQUB $08, $04, $00, $10, $04, $18, $22, $FE
 EQUB $F0, $C0, $21, $06, $10, $40, $80, $02
 EQUB $57, $00, $32, $0B, $02, $20, $10, $02
 EQUB $FF, $21, $1F, $FF, $57, $8B, $21, $01
 EQUB $02, $FF, $F8, $FF, $D4, $A2, $03, $D4
 EQUB $00, $A0, $80, $21, $08, $10, $12, $32
 EQUB $1F, $07, $C1, $10, $32, $04, $02, $08
 EQUB $35, $0C, $07, $0B, $01, $04, $04, $80
 EQUB $F8, $7F, $BF, $21, $15, $03, $32, $03
 EQUB $3F, $FD, $FA, $50, $02, $60, $C0, $A0
 EQUB $00, $40, $03, $21, $01, $07, $3F

; ******************************************************************************
;
;       Name: headImage12
;       Type: Variable
;   Category: Status
;    Summary: Packed image data for commander headshot image 12
;  Deep dive: Displaying two-layer images
;             Image and data compression
;
; ------------------------------------------------------------------------------
;
; Each commander image is composed of a face image and a headshot image. You can
; view the combined commander image 12 here:
;
; https://elite.bbcelite.com/images/source/nes/commanderImage12_0.png
;
; ******************************************************************************

.headImage12

 EQUB $1D, $FC, $F0, $E0, $13, $E0, $04, $13
 EQUB $32, $0F, $01, $03, $15, $7F, $32, $1F
 EQUB $0F, $1F, $11, $22, $C0, $23, $80, $00
 EQUB $21, $01, $06, $E0, $50, $21, $2A, $05
 EQUB $35, $0E, $14, $A8, $07, $07, $23, $03
 EQUB $23, $01, $1D, $FE, $22, $FC, $03, $21
 EQUB $01, $04, $21, $04, $80, $02, $C0, $32
 EQUB $11, $01, $00, $40, $03, $21, $08, $10
 EQUB $02, $22, $01, $22, $41, $21, $01, $03
 EQUB $16, $22, $7F, $22, $FC, $22, $FE, $14
 EQUB $00, $21, $01, $03, $21, $02, $81, $C0
 EQUB $35, $03, $01, $01, $00, $02, $81, $C3
 EQUB $83, $80, $21, $01, $02, $80, $00, $86
 EQUB $82, $04, $21, $01, $81, $32, $03, $07
 EQUB $22, $7F, $16, $00, $D2, $02, $21, $02
 EQUB $00, $22, $02, $23, $C0, $0F, $06, $23
 EQUB $06, $06, $96, $02, $80, $00, $22, $80
 EQUB $33, $02, $06, $06, $23, $02, $00, $21
 EQUB $02, $09, $32, $01, $03, $07, $80, $0D
 EQUB $80, $22, $C0, $23, $80, $00, $80, $04
 EQUB $21, $02, $05, $21, $01, $07, $FF, $00
 EQUB $7F, $21, $01, $04, $FF, $00, $FC, $0F
 EQUB $80, $0C, $21, $01, $08, $60, $32, $1F
 EQUB $03, $04, $32, $01, $0C, $F0, $80, $0F
 EQUB $04, $3F, $0F, $0F, $0F, $0F, $01, $30
 EQUB $61, $06, $E0, $50, $21, $2A, $05, $32
 EQUB $0E, $14, $A8, $05, $32, $18, $0C, $0F
 EQUB $02, $40, $00, $40, $21, $01, $04, $21
 EQUB $04, $80, $02, $C0, $32, $11, $01, $00
 EQUB $40, $03, $21, $08, $10, $02, $21, $04
 EQUB $00, $44, $40, $0F, $06, $21, $01, $03
 EQUB $38, $02, $01, $00, $03, $01, $01, $00
 EQUB $02, $81, $C3, $83, $80, $21, $01, $02
 EQUB $80, $00, $86, $82, $05, $80, $0B, $FE
 EQUB $F6, $AA, $46, $33, $12, $06, $0E, $05
 EQUB $40, $E0, $40, $0F, $06, $33, $04, $0E
 EQUB $04, $00, $FF, $DE, $AA, $C4, $90, $C0
 EQUB $E0, $38, $06, $0E, $0E, $06, $0E, $06
 EQUB $02, $06, $20, $40, $00, $10, $05, $32
 EQUB $01, $03, $07, $80, $05, $32, $08, $04
 EQUB $00, $10, $04, $C0, $22, $E0, $C0, $E0
 EQUB $C0, $80, $C0, $24, $02, $21, $0E, $20
 EQUB $00, $80, $02, $57, $00, $32, $0B, $02
 EQUB $20, $10, $02, $FF, $21, $1F, $FF, $57
 EQUB $8B, $21, $01, $02, $FF, $F8, $FF, $D4
 EQUB $A2, $03, $D4, $00, $A0, $80, $21, $08
 EQUB $10, $24, $80, $E0, $21, $08, $00, $21
 EQUB $02, $08, $35, $0C, $07, $0B, $01, $04
 EQUB $04, $80, $F8, $7F, $BF, $21, $15, $03
 EQUB $32, $03, $3F, $FD, $FA, $50, $02, $60
 EQUB $C0, $A0, $00, $40, $0B, $3F

; ******************************************************************************
;
;       Name: headImage13
;       Type: Variable
;   Category: Status
;    Summary: Packed image data for commander headshot image 13
;  Deep dive: Displaying two-layer images
;             Image and data compression
;
; ------------------------------------------------------------------------------
;
; Each commander image is composed of a face image and a headshot image. You can
; view the combined commander image 13 here:
;
; https://elite.bbcelite.com/images/source/nes/commanderImage13_0.png
;
; ******************************************************************************

.headImage13

 EQUB $1B, $FE, $22, $FC, $E0, $C0, $12, $F7
 EQUB $20, $04, $12, $6F, $21, $03, $04, $14
 EQUB $34, $3F, $1F, $1F, $0F, $1F, $11, $C0
 EQUB $24, $80, $00, $21, $01, $06, $E0, $50
 EQUB $21, $2A, $05, $37, $0E, $14, $A8, $07
 EQUB $07, $03, $03, $24, $01, $1D, $FE, $22
 EQUB $FC, $08, $21, $04, $03, $50, $22, $01
 EQUB $00, $40, $03, $21, $14, $03, $22, $01
 EQUB $22, $41, $21, $01, $03, $16, $22, $7F
 EQUB $22, $FC, $22, $FE, $14, $00, $21, $01
 EQUB $03, $21, $02, $81, $C0, $33, $03, $21
 EQUB $01, $02, $82, $C1, $83, $80, $21, $09
 EQUB $03, $80, $21, $06, $82, $04, $21, $01
 EQUB $81, $32, $03, $07, $22, $7F, $16, $00
 EQUB $D2, $02, $21, $02, $00, $22, $02, $23
 EQUB $C0, $05, $21, $03, $06, $21, $01, $80
 EQUB $07, $23, $06, $06, $96, $02, $80, $00
 EQUB $22, $80, $33, $02, $06, $06, $23, $02
 EQUB $00, $21, $02, $09, $21, $0B, $07, $A0
 EQUB $0E, $80, $22, $C0, $23, $80, $00, $80
 EQUB $04, $21, $02, $05, $21, $01, $07, $FF
 EQUB $00, $7F, $21, $01, $04, $FF, $00, $FC
 EQUB $0F, $80, $03, $22, $04, $34, $1F, $0E
 EQUB $0A, $11, $03, $21, $01, $08, $60, $32
 EQUB $1F, $03, $04, $32, $01, $0C, $F0, $80
 EQUB $05, $21, $01, $02, $21, $01, $02, $22
 EQUB $40, $F0, $E0, $A0, $10, $02, $3F, $0F
 EQUB $0F, $0F, $0F, $02, $21, $01, $06, $E0
 EQUB $50, $21, $2A, $05, $32, $0E, $14, $A8
 EQUB $0F, $0F, $02, $21, $04, $03, $50, $22
 EQUB $01, $00, $40, $03, $21, $14, $05, $22
 EQUB $40, $0F, $06, $21, $01, $03, $36, $02
 EQUB $01, $00, $03, $21, $01, $02, $82, $C1
 EQUB $83, $80, $21, $09, $03, $80, $21, $06
 EQUB $82, $05, $80, $0B, $FE, $F6, $AA, $46
 EQUB $33, $12, $06, $0E, $05, $40, $E0, $40
 EQUB $21, $03, $06, $21, $01, $80, $0C, $33
 EQUB $04, $0E, $04, $00, $FF, $DE, $AA, $C4
 EQUB $90, $C0, $E0, $38, $06, $0E, $0E, $06
 EQUB $0E, $06, $02, $06, $20, $40, $00, $10
 EQUB $05, $21, $0B, $07, $A0, $06, $32, $08
 EQUB $04, $00, $10, $04, $C0, $22, $E0, $C0
 EQUB $E0, $C0, $80, $C0, $24, $02, $21, $0E
 EQUB $20, $00, $84, $02, $57, $00, $32, $0B
 EQUB $02, $20, $10, $02, $FF, $21, $1F, $FF
 EQUB $57, $8B, $21, $01, $02, $FF, $F8, $FF
 EQUB $D4, $A2, $03, $D4, $00, $A0, $80, $21
 EQUB $08, $10, $24, $80, $E0, $21, $08, $00
 EQUB $42, $3D, $15, $04, $3F, $0E, $1F, $11
 EQUB $04, $00, $0C, $07, $8B, $01, $04, $04
 EQUB $80, $F8, $7F, $BF, $21, $15, $03, $32
 EQUB $03, $3F, $FD, $FA, $50, $02, $61, $C0
 EQUB $A3, $00, $41, $21, $01, $02, $50, $40
 EQUB $F8, $E0, $F0, $10, $40, $00, $3F

; ******************************************************************************
;
;       Name: glassesImage
;       Type: Variable
;   Category: Status
;    Summary: Packed image data for the glasses, earrings and medallion that the
;             commander can wear
;  Deep dive: Displaying two-layer images
;             Image and data compression
;
; ------------------------------------------------------------------------------
;
; You can view the tiles that make up the glasses image here:
;
; https://elite.bbcelite.com/images/source/nes/glassesImage_ppu.png
;
; and you can see what the commander images look like with glasses, earrings and
; medallion here:
;
; https://elite.bbcelite.com/images/source/nes/allCommanderImages.png
;
; ******************************************************************************

.glassesImage

 EQUB $02, $7F, $7B, $34, $17, $1F, $1F, $0F
 EQUB $03, $32, $0C, $08, $05, $12, $22, $E3
 EQUB $41, $80, $06, $80, $03, $FF, $BF, $7C
 EQUB $FC, $F4, $F8, $03, $C0, $80, $00, $21
 EQUB $08, $00, $31, $02, $23, $07, $32, $05
 EQUB $02, $03, $24, $02, $03, $20, $23, $70
 EQUB $50, $20, $03, $24, $20, $0A, $40, $0F
 EQUB $21, $01, $09, $20, $40, $30, $34, $28
 EQUB $14, $0F, $05, $22, $40, $22, $20, $10
 EQUB $33, $08, $04, $03, $07, $FF, $09, $35
 EQUB $02, $01, $06, $0A, $14, $78, $D0, $22
 EQUB $01, $22, $02, $32, $04, $08, $10, $60
 EQUB $32, $03, $01, $07, $21, $01, $06, $63
 EQUB $D5, $77, $5D, $32, $22, $1C, $02, $DD
 EQUB $22, $36, $32, $3E, $1C, $03, $60, $C0
 EQUB $06, $80, $40, $06, $3F

; ******************************************************************************
;
;       Name: bigLogoImage
;       Type: Variable
;   Category: Start and end
;    Summary: Packed image data for the big Elite logo shown on the Start screen
;  Deep dive: Image and data compression
;
; ------------------------------------------------------------------------------
;
; You can view the tiles that make up the big logo image here:
;
; https://elite.bbcelite.com/images/source/nes/bigLogoImage_ppu.png
;
; and you can see what the big logo looks like on-screen here:
;
; https://elite.bbcelite.com/images/nes/general/start.png
;
; Note that the ball at the bottom of the logo is stored separately, at
; logoBallImage.
;
; ******************************************************************************

.bigLogoImage

 EQUB $08, $40, $90, $68, $54, $21, $26, $59
 EQUB $DA, $21, $2E, $04, $80, $40, $A0, $D0
 EQUB $03, $35, $01, $03, $0A, $00, $21, $10
 EQUB $48, $68, $D4, $B0, $40, $B4, $A4, $21
 EQUB $37, $F5, $DF, $FB, $7F, $FF, $21, $1F
 EQUB $7F, $60, $D8, $22, $FC, $12, $F7, $FB
 EQUB $05, $20, $D0, $68, $02, $21, $01, $02
 EQUB $32, $0D, $3A, $65, $76, $AA, $9B, $65
 EQUB $6D, $9B, $BF, $67, $60, $D4, $70, $BC
 EQUB $FC, $70, $F8, $F0, $37, $3F, $19, $1E
 EQUB $0D, $06, $05, $01, $00, $4D, $F6, $9A
 EQUB $ED, $21, $35, $D7, $99, $4B, $30, $D2
 EQUB $DC, $21, $2E, $EB, $57, $B1, $6E, $04
 EQUB $A0, $00, $C8, $D4, $03, $33, $06, $15
 EQUB $2A, $46, $9B, $8D, $21, $33, $5D, $66
 EQUB $BB, $DF, $EF, $BF, $7D, $B7, $BF, $FF
 EQUB $FD, $F8, $F0, $C8, $A0, $22, $C0, $80
 EQUB $04, $3A, $24, $1B, $0D, $06, $01, $04
 EQUB $05, $0E, $D6, $35, $CF, $72, $5D, $CD
 EQUB $66, $21, $3A, $62, $B8, $5E, $EB, $AD
 EQUB $B7, $DA, $6F, $04, $22, $C4, $F6, $FF
 EQUB $05, $38, $01, $02, $06, $02, $01, $0E
 EQUB $15, $2B, $FF, $7F, $FF, $DD, $6F, $F7
 EQUB $BF, $FB, $DF, $FF, $FE, $FF, $7F, $FC
 EQUB $FB, $EE, $DE, $BF, $FA, $10, $23, $80
 EQUB $04, $21, $0D, $02, $21, $18, $00, $21
 EQUB $08, $02, $36, $31, $04, $41, $04, $00
 EQUB $02, $02, $AD, $97, $21, $37, $4A, $BB
 EQUB $21, $0D, $57, $92, $FD, $7F, $F7, $FF
 EQUB $FB, $F7, $EF, $FF, $02, $80, $C0, $F0
 EQUB $F8, $D6, $7B, $05, $36, $01, $03, $07
 EQUB $03, $05, $2B, $53, $7F, $FD, $F7, $BE
 EQUB $BF, $9F, $FC, $FE, $B6, $BB, $BA, $B5
 EQUB $F6, $9B, $E9, $9C, $66, $58, $A2, $21
 EQUB $28, $FF, $61, $81, $92, $00, $81, $00
 EQUB $21, $03, $22, $80, $00, $23, $80, $02
 EQUB $31, $08, $23, $04, $33, $02, $03, $01
 EQUB $06, $21, $08, $20, $82, $38, $2B, $0D
 EQUB $43, $15, $09, $02, $04, $03, $FF, $FE
 EQUB $77, $FF, $7F, $12, $7F, $ED, $BA, $DD
 EQUB $6A, $F6, $5B, $ED, $FD, $22, $80, $C0
 EQUB $E0, $B8, $44, $B3, $51, $07, $80, $04
 EQUB $40, $60, $40, $50, $04, $22, $10, $22
 EQUB $30, $04, $37, $01, $03, $0A, $17, $04
 EQUB $0F, $3F, $F5, $9F, $6B, $6F, $7F, $EF
 EQUB $FD, $7C, $FA, $F0, $E4, $C0, $93, $32
 EQUB $35, $3A, $6A, $74, $73, $CC, $F1, $C8
 EQUB $40, $90, $40, $20, $02, $80, $37, $01
 EQUB $09, $01, $05, $0A, $0B, $26, $9E, $48
 EQUB $00, $80, $06, $50, $64, $21, $31, $10
 EQUB $33, $0E, $02, $01, $03, $21, $02, $00
 EQUB $80, $02, $80, $FF, $21, $3F, $DF, $21
 EQUB $37, $9D, $21, $2D, $4A, $21, $1B, $FB
 EQUB $7E, $FF, $BF, $FF, $E7, $FF, $7B, $AD
 EQUB $AA, $D3, $75, $DC, $EB, $FE, $F7, $22
 EQUB $C0, $40, $A8, $F0, $9E, $EF, $74, $23
 EQUB $30, $21, $12, $52, $21, $31, $20, $21
 EQUB $23, $23, $40, $23, $60, $40, $20, $03
 EQUB $23, $01, $33, $03, $0F, $3B, $72, $EE
 EQUB $F7, $BB, $21, $3F, $77, $7F, $BE, $FE
 EQUB $D9, $F4, $F0, $C0, $83, $21, $04, $47
 EQUB $33, $1B, $26, $2C, $98, $B8, $64, $D0
 EQUB $A2, $B0, $80, $C8, $20, $00, $40, $C1
 EQUB $37, $01, $0A, $05, $26, $1B, $CA, $26
 EQUB $8C, $70, $B0, $F0, $C0, $04, $40, $60
 EQUB $21, $18, $D6, $C2, $21, $01, $C0, $88
 EQUB $38, $21, $15, $08, $0A, $00, $09, $00
 EQUB $04, $FF, $BE, $DF, $D7, $7B, $21, $2F
 EQUB $B5, $21, $2B, $FD, $FF, $FE, $DF, $13
 EQUB $CF, $9B, $ED, $DF, $B3, $ED, $7B, $ED
 EQUB $F6, $23, $80, $40, $60, $C0, $E0, $60
 EQUB $D0, $F0, $E5, $73, $34, $2F, $17, $0E
 EQUB $1F, $70, $F0, $60, $30, $20, $22, $C0
 EQUB $40, $34, $1E, $0B, $2E, $13, $7F, $6D
 EQUB $32, $2F, $2B, $FE, $FC, $B9, $22, $F4
 EQUB $F0, $22, $E8, $4D, $32, $13, $36, $5D
 EQUB $68, $5B, $78, $92, $90, $69, $80, $B1
 EQUB $41, $39, $02, $0E, $04, $05, $13, $0A
 EQUB $05, $34, $16, $5D, $6D, $30, $60, $F0
 EQUB $60, $30, $78, $D0, $B8, $A0, $C1, $21
 EQUB $24, $88, $10, $40, $48, $30, $00, $32
 EQUB $02, $01, $00, $81, $00, $21, $02, $80
 EQUB $56, $35, $13, $09, $06, $81, $05, $40
 EQUB $A1, $F7, $7B, $EF, $EB, $55, $D6, $21
 EQUB $2B, $95, $DB, $22, $FD, $F7, $FE, $FB
 EQUB $BF, $FD, $70, $60, $25, $E0, $C0, $03
 EQUB $21, $0E, $04, $32, $0F, $0C, $43, $64
 EQUB $32, $13, $3B, $BB, $45, $80, $B0, $A8
 EQUB $21, $13, $F8, $F0, $D0, $00, $6F, $77
 EQUB $7F, $77, $7F, $33, $37, $2E, $1B, $F0
 EQUB $C5, $B0, $D0, $60, $98, $C2, $E8, $23
 EQUB $50, $A0, $21, $32, $61, $21, $19, $BE
 EQUB $32, $0C, $21, $58, $B2, $E5, $21, $21
 EQUB $CC, $32, $07, $36, $6A, $6F, $DD, $73
 EQUB $BE, $ED, $5B, $22, $F0, $D8, $78, $22
 EQUB $E0, $F0, $C0, $36, $34, $11, $0C, $06
 EQUB $03, $01, $03, $21, $01, $00, $40, $21
 EQUB $01, $60, $90, $48, $30, $4E, $57, $B5
 EQUB $21, $2F, $5E, $47, $21, $37, $A6, $5E
 EQUB $35, $13, $2D, $26, $15, $0B, $81, $FB
 EQUB $12, $7B, $12, $7D, $FE, $23, $80, $04
 EQUB $C0, $03, $21, $1F, $71, $36, $08, $03
 EQUB $05, $3D, $11, $04, $77, $F0, $32, $0F
 EQUB $03, $42, $20, $80, $20, $F6, $FF, $89
 EQUB $00, $40, $03, $C0, $80, $03, $22, $0B
 EQUB $36, $0F, $0D, $0B, $07, $07, $0F, $90
 EQUB $64, $D0, $D4, $A8, $E8, $44, $50, $21
 EQUB $3D, $48, $34, $18, $38, $2E, $3E, $7E
 EQUB $58, $21, $11, $4C, $21, $27, $91, $21
 EQUB $28, $4E, $32, $11, $05, $BF, $EF, $21
 EQUB $37, $DF, $BA, $B4, $68, $D0, $60, $22
 EQUB $80, $05, $3C, $38, $18, $0E, $06, $03
 EQUB $02, $07, $0A, $13, $4B, $09, $1F, $58
 EQUB $E4, $21, $26, $C6, $32, $0D, $03, $8B
 EQUB $CF, $F8, $00, $44, $FF, $BF, $7F, $FB
 EQUB $FE, $32, $0F, $1B, $9F, $CF, $60, $A2
 EQUB $B9, $FB, $46, $33, $25, $37, $37, $10
 EQUB $93, $59, $68, $DC, $F6, $BA, $EF, $8F
 EQUB $BD, $BF, $FF, $DC, $C7, $55, $21, $05
 EQUB $E1, $F1, $E2, $F2, $BF, $68, $D0, $D7
 EQUB $21, $12, $B3, $21, $02, $DB, $FF, $30
 EQUB $00, $E9, $22, $77, $5F, $FE, $83, $32
 EQUB $02, $03, $FB, $E8, $88, $61, $21, $32
 EQUB $A7, $20, $00, $21, $02, $78, $21, $3E
 EQUB $D4, $80, $FE, $02, $DA, $33, $22, $0A
 EQUB $05, $50, $C3, $42, $52, $49, $60, $C0
 EQUB $80, $06, $21, $01, $06, $21, $2A, $40
 EQUB $FB, $03, $32, $3F, $0F, $55, $80, $FF
 EQUB $03, $FF, $EB, $32, $01, $06, $80, $03
 EQUB $EC, $21, $31, $E6, $E7, $31, $27, $23
 EQUB $07, $77, $21, $17, $22, $80, $5F, $00
 EQUB $FF, $7F, $22, $80, $34, $16, $08, $F6
 EQUB $08, $E8, $EE, $37, $0C, $07, $32, $33
 EQUB $73, $3A, $3A, $BA, $22, $BB, $FF, $FE
 EQUB $F4, $02, $F7, $E0, $F8, $37, $15, $05
 EQUB $9C, $0E, $14, $96, $0E, $4E, $22, $80
 EQUB $02, $80, $00, $40, $5F, $3B, $18, $0A
 EQUB $2A, $0C, $0A, $2C, $0E, $CC, $03, $02
 EQUB $01, $02, $21, $25, $84, $F4, $10, $D4
 EQUB $94, $35, $18, $1F, $1F, $18, $1C, $92
 EQUB $00, $4D, $21, $1D, $FF, $FE, $02, $21
 EQUB $25, $5B, $7B, $02, $40, $41, $C0, $FF
 EQUB $40, $A4, $03, $9D, $00, $FF, $21, $0A
 EQUB $04, $FF, $47, $E0, $20, $10, $03, $F0
 EQUB $40, $21, $06, $07, $9D, $03, $34, $37
 EQUB $0D, $02, $01, $40, $03, $FD, $BF, $FF
 EQUB $FB, $34, $07, $03, $07, $0B, $A7, $60
 EQUB $22, $C0, $02, $13, $03, $32, $1E, $08
 EQUB $F8, $F0, $FB, $36, $02, $0C, $08, $3B
 EQUB $3C, $1F, $5F, $7F, $22, $80, $00, $F3
 EQUB $21, $0E, $13, $03, $56, $21, $06, $22
 EQUB $8E, $9E, $03, $E0, $4B, $00, $80, $96
 EQUB $21, $3F, $7F, $7E, $21, $0F, $8F, $32
 EQUB $1E, $1C, $8E, $03, $94, $FF, $02, $21
 EQUB $32, $FE, $7E, $FF, $33, $1C, $1B, $1F
 EQUB $FF, $7F, $03, $A6, $21, $2E, $13, $03
 EQUB $64, $80, $00, $40, $FF, $C1, $40, $00
 EQUB $10, $03, $FE, $21, $08, $00, $21, $04
 EQUB $03, $10, $E0, $80, $02, $80, $07, $FF
 EQUB $34, $3D, $1F, $07, $03, $03, $C0, $22
 EQUB $80, $FF, $21, $22, $90, $32, $02, $1F
 EQUB $03, $FF, $00, $21, $05, $12, $32, $0B
 EQUB $19, $10, $FF, $21, $0F, $AF, $12, $03
 EQUB $15, $03, $FC, $14, $03, $EF, $8F, $5F
 EQUB $9F, $BF, $21, $3E, $BF, $FF, $7F, $21
 EQUB $3F, $FF, $9F, $FF, $22, $01, $00, $6C
 EQUB $15, $23, $FE, $14, $03, $59, $14, $02
 EQUB $32, $01, $28, $FC, $13, $65, $D7, $BA
 EQUB $7F, $78, $F8, $22, $C0, $68, $E0, $0A
 EQUB $33, $0F, $17, $07, $05, $14, $04, $15
 EQUB $7E, $FE, $FF, $FD, $F9, $12, $21, $3F
 EQUB $7F, $12, $FD, $FF, $22, $FC, $13, $F3
 EQUB $FF, $F9, $FF, $FD, $FF, $C0, $22, $F0
 EQUB $15, $03, $15, $03, $12, $FC, $F8, $FF
 EQUB $03, $C0, $80, $02, $FF, $00, $34, $31
 EQUB $04, $00, $03, $02, $BF, $21, $1E, $CD
 EQUB $32, $26, $37, $EA, $58, $20, $E7, $FF
 EQUB $FD, $21, $25, $FF, $80, $5F, $21, $0F
 EQUB $E4, $F1, $B0, $21, $3F, $64, $4B, $5E
 EQUB $BF, $22, $7F, $81, $FF, $4A, $21, $28
 EQUB $AD, $DF, $7E, $F3, $33, $3F, $01, $02
 EQUB $FE, $C9, $F8, $E2, $00, $21, $1D, $22
 EQUB $FC, $10, $60, $40, $20, $80, $08, $22
 EQUB $01, $22, $03, $32, $07, $0F, $B3, $79
 EQUB $ED, $E4, $40, $82, $32, $1B, $1D, $B0
 EQUB $D0, $E8, $F8, $6C, $21, $3C, $DA, $4E
 EQUB $21, $0A, $07, $F7, $35, $1F, $1B, $3F
 EQUB $1F, $1E, $5F, $5D, $84, $03, $23, $80
 EQUB $C0, $21, $3E, $79, $68, $82, $21, $2D
 EQUB $5B, $32, $2C, $2D, $22, $C0, $60, $20
 EQUB $00, $80, $C0, $80, $51, $34, $38, $3F
 EQUB $11, $0B, $03, $20, $40, $00, $80, $04
 EQUB $3F, $13, $05, $30, $48, $84, $82, $81
 EQUB $80, $00, $80, $05, $80, $40, $20, $04
 EQUB $34, $01, $06, $0C, $18, $00, $30, $58
 EQUB $88, $24, $0C, $80, $05, $20, $00, $34
 EQUB $18, $04, $02, $03, $02, $32, $08, $04
 EQUB $04, $80, $C0, $20, $90, $03, $33, $03
 EQUB $06, $08, $10, $22, $20, $40, $80, $05
 EQUB $23, $0C, $22, $08, $21, $18, $10, $30
 EQUB $00, $34, $06, $01, $02, $01, $03, $B2
 EQUB $21, $09, $65, $21, $12, $CA, $21, $28
 EQUB $66, $21, $34, $CC, $34, $2C, $23, $D1
 EQUB $14, $A8, $4E, $91, $03, $80, $40, $E0
 EQUB $30, $21, $28, $00, $34, $01, $03, $04
 EQUB $08, $10, $20, $22, $40, $80, $09, $34
 EQUB $01, $03, $06, $0C, $30, $22, $60, $C0
 EQUB $80, $04, $39, $1B, $04, $02, $01, $00
 EQUB $02, $06, $05, $29, $CA, $30, $8D, $A2
 EQUB $32, $32, $19, $85, $9C, $47, $A1, $21
 EQUB $14, $52, $48, $21, $25, $90, $02, $80
 EQUB $C0, $34, $22, $32, $0A, $02, $04, $23
 EQUB $01, $35, $03, $01, $02, $04, $08, $10
 EQUB $00, $80, $08, $21, $01, $02, $32, $03
 EQUB $04, $10, $20, $42, $21, $07, $E0, $40
 EQUB $06, $31, $06, $27, $0F, $CE, $FB, $BE
 EQUB $FB, $FF, $FD, $12, $52, $68, $C8, $B5
 EQUB $44, $F2, $A8, $6D, $21, $03, $81, $21
 EQUB $08, $00, $32, $04, $08, $10, $02, $80
 EQUB $C0, $60, $30, $33, $18, $0C, $06, $06
 EQUB $36, $01, $03, $06, $0E, $1C, $38, $60
 EQUB $C0, $80, $21, $01, $22, $40, $32, $03
 EQUB $01, $49, $44, $45, $4A, $21, $09, $64
 EQUB $21, $16, $63, $99, $A7, $5D, $D7, $21
 EQUB $03, $9F, $7F, $6D, $FF, $7F, $12, $02
 EQUB $26, $80, $31, $07, $23, $03, $21, $01
 EQUB $03, $17, $7F, $D4, $F2, $BC, $EA, $F6
 EQUB $FD, $FB, $FC, $02, $88, $00, $80, $02
 EQUB $80, $32, $03, $01, $07, $C0, $60, $30
 EQUB $34, $18, $0C, $06, $03, $0E, $22, $20
 EQUB $0D, $35, $01, $07, $0C, $0E, $18, $30
 EQUB $60, $C0, $80, $03, $36, $02, $03, $05
 EQUB $0F, $1B, $3F, $6E, $CA, $C5, $95, $8B
 EQUB $8C, $33, $33, $0E, $37, $BF, $6F, $BF
 EQUB $DF, $12, $7F, $15, $22, $FE, $22, $FC
 EQUB $80, $07, $36, $3F, $1F, $0F, $0F, $03
 EQUB $01, $02, $12, $FD, $14, $7F, $00, $C0
 EQUB $20, $C8, $62, $D2, $B5, $E4, $00, $80
 EQUB $00, $40, $00, $21, $18, $00, $84, $08
 EQUB $80, $60, $30, $35, $18, $0C, $04, $02
 EQUB $03, $00, $23, $20, $21, $24, $46, $22
 EQUB $50, $23, $20, $03, $20, $40, $04, $36
 EQUB $01, $03, $07, $06, $1C, $38, $70, $E0
 EQUB $C0, $80, $02, $22, $01, $34, $06, $0B
 EQUB $0F, $3F, $7F, $FF, $BC, $FC, $F9, $F3
 EQUB $E7, $C7, $9B, $21, $2F, $5D, $4F, $7F
 EQUB $21, $37, $DF, $FF, $22, $BF, $16, $FC
 EQUB $22, $F8, $F0, $E0, $C0, $80, $03, $32
 EQUB $3F, $1F, $47, $63, $79, $FC, $12, $DE
 EQUB $EA, $F7, $F5, $FF, $F6, $FF, $FB, $00
 EQUB $41, $20, $21, $28, $84, $D0, $4A, $D4
 EQUB $03, $20, $03, $10, $21, $01, $08, $80
 EQUB $23, $C0, $22, $60, $E0, $34, $32, $12
 EQUB $12, $04, $10, $00, $21, $11, $03, $10
 EQUB $22, $40, $02, $80, $34, $0C, $1C, $18
 EQUB $38, $22, $30, $22, $70, $38, $01, $03
 EQUB $06, $0B, $0B, $0F, $17, $17, $BE, $FC
 EQUB $F9, $F2, $F7, $E4, $E7, $ED, $6F, $97
 EQUB $7F, $4F, $BF, $17, $FE, $F9, $FB, $FF
 EQUB $F0, $C0, $80, $30, $22, $F0, $F8, $F0
 EQUB $25, $7F, $22, $3F, $21, $1F, $FF, $FD
 EQUB $FE, $FF, $FE, $FF, $FD, $FF, $A9, $EC
 EQUB $F6, $F9, $7E, $FA, $BF, $5E, $21, $08
 EQUB $84, $10, $21, $14, $AA, $21, $29, $D4
 EQUB $6A, $04, $22, $01, $41, $21, $03, $25
 EQUB $E0, $23, $C0, $03, $21, $01, $05, $21
 EQUB $21, $A4, $93, $22, $7A, $7F, $21, $3F
 EQUB $02, $30, $6C, $60, $23, $E0, $23, $70
 EQUB $22, $30, $37, $18, $19, $0C, $0F, $3B
 EQUB $4F, $2F, $9F, $67, $32, $3D, $17, $23
 EQUB $EF, $FF, $EF, $FF, $22, $F7, $1F, $11
 EQUB $22, $F8, $24, $F0, $22, $E0, $22, $0F
 EQUB $33, $07, $03, $01, $03, $FF, $FE, $12
 EQUB $FE, $FF, $7F, $21, $3F, $CF, $B1, $A8
 EQUB $4A, $D0, $A1, $B8, $C8, $59, $A1, $EC
 EQUB $D2, $D9, $EA, $F4, $FE, $23, $03, $87
 EQUB $22, $03, $83, $21, $01, $C0, $27, $80
 EQUB $04, $21, $0C, $00, $21, $01, $05, $21
 EQUB $06, $00, $F8, $21, $1D, $C0, $05, $FC
 EQUB $80, $04, $70, $03, $22, $04, $00, $21
 EQUB $02, $04, $6F, $9B, $34, $2F, $2B, $57
 EQUB $17, $BB, $AF, $FB, $13, $23, $FD, $1C
 EQUB $FE, $FC, $F8, $F0, $E0, $22, $C0, $06
 EQUB $33, $0F, $07, $03, $24, $01, $21, $07
 EQUB $EC, $B4, $F6, $E0, $E7, $23, $E3, $F2
 EQUB $FC, $74, $30, $12, $BB, $00, $40, $80
 EQUB $02, $F0, $E0, $60, $00, $C0, $7F, $21
 EQUB $06, $00, $31, $38, $23, $18, $21, $01
 EQUB $00, $A0, $05, $F0, $03, $38, $1F, $0C
 EQUB $0E, $0E, $18, $08, $01, $00, $23, $0F
 EQUB $21, $08, $00, $4F, $FF, $00, $13, $32
 EQUB $1E, $18, $E0, $80, $21, $01, $FC, $FD
 EQUB $FC, $32, $04, $17, $77, $9F, $CF, $7F
 EQUB $22, $3F, $21, $3D, $FF, $F9, $FB, $14
 EQUB $21, $25, $13, $BF, $BE, $22, $BC, $BE
 EQUB $C0, $80, $0E, $32, $15, $3F, $06, $AA
 EQUB $7F, $05, $21, $14, $12, $7F, $03, $21
 EQUB $13, $CE, $23, $C3, $23, $03, $83, $E3
 EQUB $02, $80, $12, $80, $03, $21, $02, $00
 EQUB $22, $F0, $10, $21, $03, $00, $28, $1C
 EQUB $00, $32, $01, $0B, $03, $34, $1F, $07
 EQUB $0E, $0E, $24, $0F, $CF, $8F, $08, $23
 EQUB $1C, $35, $1E, $1C, $1E, $1C, $1E, $06
 EQUB $22, $03, $23, $38, $23, $3F, $22, $38
 EQUB $03, $13, $02, $7E, $22, $3F, $23, $80
 EQUB $32, $3E, $3F, $00, $12, $03, $62, $FF
 EQUB $00, $F5, $FF, $04, $B8, $00, $C0, $E0
 EQUB $04, $80, $21, $01, $07, $62, $03, $33
 EQUB $08, $02, $01, $00, $BF, $03, $21, $02
 EQUB $40, $00, $21, $04, $E3, $33, $07, $03
 EQUB $07, $40, $80, $02, $80, $13, $04, $21
 EQUB $01, $22, $F0, $F8, $31, $06, $23, $07
 EQUB $34, $1C, $1F, $3F, $3F, $04, $21, $0C
 EQUB $13, $04, $8F, $23, $CF, $04, $21, $1F
 EQUB $03, $7F, $23, $3F, $9C, $22, $1C, $21
 EQUB $3E, $04, $63, $03, $FF, $7F, $FF, $FE
 EQUB $34, $38, $3C, $3F, $3F, $05, $D1, $12
 EQUB $04, $21, $3F, $00, $22, $80, $00, $32
 EQUB $3E, $3F, $7F, $FF, $03, $21, $01, $F7
 EQUB $FE, $F8, $FF, $0F, $0C, $DD, $6F, $32
 EQUB $3F, $0F, $04, $14, $22, $06, $22, $0E
 EQUB $14, $04, $14, $04, $FE, $13, $04, $7F
 EQUB $13, $7F, $23, $7E, $FF, $BF, $FF, $DF
 EQUB $02, $22, $01, $14, $24, $FE, $14, $04
 EQUB $14, $04, $14, $23, $7F, $FE, $FC, $F0
 EQUB $E0, $80, $F0, $C0, $80, $09, $34, $1F
 EQUB $0F, $03, $01, $04, $14, $03, $21, $01
 EQUB $14, $7F, $15, $FB, $F7, $15, $FD, $12
 EQUB $22, $EF, $F7, $FF, $FB, $FF, $FD, $FE
 EQUB $C0, $22, $E0, $F0, $14, $04, $14, $04
 EQUB $12, $FE, $F8, $04, $80, $05, $32, $0F
 EQUB $03, $04, $4F, $21, $01, $12, $36, $0F
 EQUB $07, $3F, $1F, $FF, $0F, $12, $02, $A0
 EQUB $F0, $FF, $EE, $CF, $C0, $04, $FE, $FF
 EQUB $7F, $02, $35, $17, $1F, $0F, $FF, $0C
 EQUB $12, $02, $13, $00, $20, $FE, $02, $22
 EQUB $80, $F0, $0F, $35, $0C, $0E, $1E, $1F
 EQUB $3F, $7D, $E4, $E2, $04, $80, $C0, $E0
 EQUB $F0, $21, $01, $07, $21, $08, $00, $21
 EQUB $04, $00, $22, $20, $22, $60, $78, $07
 EQUB $40, $22, $80, $02, $33, $04, $1E, $1E
 EQUB $08, $21, $0C, $02, $21, $0E, $0C, $3F

; ******************************************************************************
;
;       Name: bigLogoNames
;       Type: Variable
;   Category: Start and end
;    Summary: Nametable entries for the big Elite logo on the Start screen
;
; ------------------------------------------------------------------------------
;
; This table contains nametable entries for the big logo, stored as offsets
; within the pattern data in bigLogoImage (so $01 refers to the first pattern in
; bigLogoImage, $02 the second pattern in bigLogoImage, and so on).
;
; A value of $00 indicates the background pattern.
;
; ******************************************************************************

.bigLogoNames

 EQUB $01, $02, $00, $00, $00, $00, $00, $00
 EQUB $00, $00, $00, $00, $00, $00, $00, $00
 EQUB $00, $00, $00, $00, $03, $04, $00, $00
 EQUB $05, $06, $07, $00, $00, $00, $00, $00
 EQUB $00, $00, $00, $00, $00, $00, $00, $00
 EQUB $00, $00, $00, $08, $09, $0A, $00, $00
 EQUB $0B, $0C, $0D, $0E, $00, $00, $00, $00
 EQUB $00, $00, $00, $00, $00, $00, $00, $00
 EQUB $00, $00, $0F, $10, $11, $12, $00, $00
 EQUB $00, $13, $14, $15, $16, $00, $00, $00
 EQUB $00, $00, $00, $00, $00, $00, $00, $00
 EQUB $17, $18, $19, $1A, $1B, $00, $00, $00
 EQUB $00, $1C, $1D, $1E, $1F, $20, $00, $00
 EQUB $00, $00, $00, $00, $00, $00, $00, $21
 EQUB $22, $23, $24, $25, $26, $00, $00, $00
 EQUB $00, $27, $28, $29, $2A, $2B, $2C, $2D
 EQUB $00, $00, $2E, $2F, $00, $00, $30, $31
 EQUB $32, $33, $34, $35, $36, $00, $00, $00
 EQUB $00, $00, $37, $38, $39, $3A, $3B, $3C
 EQUB $00, $00, $3D, $3E, $00, $3F, $40, $41
 EQUB $42, $43, $44, $45, $00, $00, $00, $00
 EQUB $00, $00, $00, $46, $47, $48, $49, $4A
 EQUB $4B, $00, $4C, $4D, $00, $4E, $4F, $50
 EQUB $51, $52, $53, $00, $00, $00, $00, $00
 EQUB $00, $00, $00, $54, $55, $56, $57, $58
 EQUB $59, $5A, $5B, $5C, $00, $5D, $5E, $5F
 EQUB $60, $61, $62, $00, $00, $00, $00, $00
 EQUB $00, $00, $00, $63, $64, $65, $66, $67
 EQUB $68, $69, $6A, $6B, $6C, $6D, $6E, $6F
 EQUB $70, $71, $72, $00, $00, $00, $00, $00
 EQUB $00, $00, $00, $00, $73, $74, $75, $76
 EQUB $77, $78, $79, $7A, $7B, $7C, $7D, $7E
 EQUB $7F, $80, $00, $00, $00, $00, $00, $00
 EQUB $00, $81, $82, $83, $84, $85, $86, $87
 EQUB $88, $89, $8A, $8B, $8C, $8D, $8E, $8F
 EQUB $90, $91, $92, $93, $00, $00, $00, $00
 EQUB $00, $00, $94, $95, $96, $97, $98, $99
 EQUB $9A, $9B, $9C, $9D, $9E, $9F, $A0, $A1
 EQUB $A2, $A3, $A4, $A5, $00, $00, $00, $00
 EQUB $00, $00, $00, $00, $A6, $A7, $A8, $A9
 EQUB $AA, $AB, $AC, $AD, $AE, $AF, $B0, $B1
 EQUB $B2, $B3, $00, $00, $00, $00, $00, $00
 EQUB $00, $00, $00, $00, $00, $00, $B4, $B5
 EQUB $B6, $B7, $B8, $B9, $BA, $BB, $BC, $BD
 EQUB $00, $00, $00, $00, $00, $00, $00, $00
 EQUB $00, $00, $00, $00, $00, $00, $00, $BE
 EQUB $BF, $C0, $C1, $C2, $C3, $C4, $C5, $00
 EQUB $00, $00, $00, $00, $00, $00, $00, $00
 EQUB $00, $00, $00, $00, $00, $00, $00, $00
 EQUB $00, $C6, $C7, $C8, $00, $00, $00, $00
 EQUB $00, $00, $00, $00, $00, $00, $00, $00
 EQUB $00, $00, $00, $00, $00, $00, $00, $00
 EQUB $00, $C9, $CA, $CB, $00, $00, $00, $00
 EQUB $00, $00, $00, $00, $00, $00, $00, $00
 EQUB $00, $00, $00, $00, $00, $00, $00, $00
 EQUB $00, $00, $CC, $CD, $00, $00, $00, $00
 EQUB $00, $00, $00, $00, $00, $00, $00, $00
 EQUB $00, $00, $00, $00, $00, $00, $00, $00
 EQUB $00, $00, $CE, $CF, $00, $00, $00, $00
 EQUB $00, $00, $00, $00, $00, $00, $00, $00

; ******************************************************************************
;
;       Name: smallLogoTile
;       Type: Variable
;   Category: Save and load
;    Summary: Pattern numbers in the smallLogoImage table for the sprites that
;             make up the small Elite logo on the Save and Load screen
;
; ******************************************************************************

.smallLogoTile

 EQUB $01, $00, $00, $00, $00, $02, $03, $00
 EQUB $04, $05, $00, $00, $00, $06, $07, $00
 EQUB $08, $09, $0A, $0B, $0C, $0D, $0E, $00
 EQUB $0F, $10, $11, $12, $13, $14, $00, $00
 EQUB $15, $16, $17, $18, $19, $1A, $00, $00
 EQUB $00, $1B, $1C, $1D, $1E, $1F, $00, $00
 EQUB $00, $00, $20, $21, $22, $00, $00, $00
 EQUB $00, $00, $00, $23, $00, $00, $00, $00

; ******************************************************************************
;
;       Name: cobraNames
;       Type: Variable
;   Category: Save and load
;    Summary: Nametable entries for the Cobra Mk III shown on the Equip Ship
;             screen
;
; ******************************************************************************

.cobraNames

 EQUB $00, $00, $00, $00, $45, $46, $47, $48
 EQUB $49, $00, $00, $00, $00, $00, $4A, $4B
 EQUB $4C, $4D, $4E, $4F, $50, $51, $52, $53
 EQUB $54, $55, $00, $00, $00, $56, $57, $58
 EQUB $59, $5A, $5B, $5C, $5D, $00, $00, $00
 EQUB $5E, $5F, $60, $61, $62, $63, $64, $65
 EQUB $66, $67, $68, $69, $00, $00, $6A, $6B
 EQUB $6C, $6D, $6E, $6F, $70, $71, $72, $73
 EQUB $00, $00, $00, $00, $00, $00, $00, $00
 EQUB $00, $00, $00, $00, $00, $00, $00, $74
 EQUB $75, $76, $77, $78, $79, $7A, $7B, $7C
 EQUB $7D, $7E, $7F, $00, $00, $00, $00, $00
 EQUB $00, $00, $00, $00, $00, $00, $00, $00
 EQUB $00, $80, $81, $82, $83, $84, $85, $86
 EQUB $87, $88, $89, $8A, $8B, $00, $00, $00
 EQUB $00, $00, $00, $00, $00, $00, $00, $00
 EQUB $00, $00, $00, $00, $00, $00, $00, $00
 EQUB $00, $00, $00, $00, $00, $00, $00, $00
 EQUB $00, $00, $00, $00, $00, $00

; ******************************************************************************
;
;       Name: GetHeadshotType
;       Type: Subroutine
;   Category: Status
;    Summary: Get the correct headshot number for the current combat rank and
;             status condition
;
; ------------------------------------------------------------------------------
;
; Returns:
;
;   S                   The headshot number for the current combat rank and
;                       status condition, in the range 0 to headCount - 1 (13)
;
; ******************************************************************************

.GetHeadshotType

 LDA TALLY+1            ; Fetch the high byte of the kill tally, and if it is
 BNE rank1              ; not zero, then we have more than 256 kills, so jump
                        ; to rank1 to work out whether we are Competent,
                        ; Dangerous, Deadly or Elite

 LDX TALLY              ; Set X to the low byte of the kill tally

 CPX #0                 ; Increment A if X >= 0
 ADC #0

 CPX #2                 ; Increment A if X >= 2
 ADC #0

 CPX #8                 ; Increment A if X >= 8
 ADC #0

 CPX #24                ; Increment A if X >= 24
 ADC #0

 CPX #44                ; Increment A if X >= 44
 ADC #0

 CPX #130               ; Increment A if X >= 130
 ADC #0

 TAX                    ; Set X to A, which will be as follows:
                        ;
                        ;   * 1 (Harmless)        when TALLY = 0 or 1
                        ;
                        ;   * 2 (Mostly Harmless) when TALLY = 2 to 7
                        ;
                        ;   * 3 (Poor)            when TALLY = 8 to 23
                        ;
                        ;   * 4 (Average)         when TALLY = 24 to 43
                        ;
                        ;   * 5 (Above Average)   when TALLY = 44 to 129
                        ;
                        ;   * 6 (Competent)       when TALLY = 130 to 255
                        ;
                        ; Note that the Competent range also covers kill counts
                        ; from 256 to 511, but those are covered by rank1 below

 JMP rank2              ; Jump to rank2

.rank1

                        ; We call this from above with the high byte of the
                        ; kill tally in A, which is non-zero, and want to return
                        ; with the following in X, depending on our rating:
                        ;
                        ;   Competent = 6
                        ;   Dangerous = 7
                        ;   Deadly    = 8
                        ;   Elite     = 9
                        ;
                        ; The high bytes of the top tier ratings are as follows,
                        ; so this a relatively simple calculation:
                        ;
                        ;   Competent = 1
                        ;   Dangerous = 2 to 9
                        ;   Deadly    = 10 to 24
                        ;   Elite     = 25 and up

 LDX #9                 ; Set X to 9 for an Elite rating

 CMP #25                ; If A >= 25, jump to rank2 to get the headshot, as we
 BCS rank2              ; are Elite

 DEX                    ; Decrement X to 8 for a Deadly rating

 CMP #10                ; If A >= 10, jump to rank2 to get the headshot, as we
 BCS rank2              ; are Deadly

 DEX                    ; Decrement X to 7 for a Dangerous rating

 CMP #2                 ; If A >= 2, jump to rank2 to get the headshot, as we
 BCS rank2              ; are Dangerous

 DEX                    ; Decrement X to 6 for a Competent rating

.rank2

                        ; By the time we get here, X contains our combat rank,
                        ; from 1 for Harmless to 9 for Elite

 DEX                    ; Decrement our rank in X into the range 0 to 8

 TXA                    ; Set S = X + X * 2
 STA S                  ;       = 3 * X
 ASL A                  ;       = 3 * rank
 ADC S                  ;
 STA S                  ; The addition works because the ASL A clears the C flag
                        ; as we know bit 7 of A is clear (as A <= 8)

 LDX previousCondition  ; Set X to our ship's condition (0 to 3)

 BEQ rank3              ; If our ship's status condition is non-zero, then we
 DEX                    ; are in space, so decrement X, so we get a value of X
                        ; as follows:
                        ;
                        ;   * 0 for docked and green conditions
                        ;
                        ;   * 1 for yellow
                        ;
                        ;   * 2 for red

.rank3

 TXA                    ; Set X = S + X
 CLC                    ;       = 3 * rank + condition
 ADC S                  ;
 TAX                    ; where rank is in the range 0 to 8, and condition is
                        ; in the range 0 to 2

 LDA headShotsByRank,X  ; Set A to the correct headshot for this rank and this
                        ; condition

 CMP headCount          ; If A = headCount or more, which is hard-coded to 14,
 BCC rank4              ; then set A = headCount - 1 (i.e. 13)
 LDA headCount          ;
 SBC #1                 ; The subtraction works because we know the C flag is
                        ; set as we pass through a CSS to get to the SBC

.rank4

 STA S                  ; Store the headshot number in S

 RTS                    ; Return from the subroutine

; ******************************************************************************
;
;       Name: headShotsByRank
;       Type: Variable
;   Category: Status
;    Summary: Lookup table for headshots by rank and status condition
;
; ******************************************************************************

.headShotsByRank

 EQUB  0,  1,  2        ; Harmless        (docked/green, yellow, red)
 EQUB  3,  4,  5        ; Mostly Harmless (docked/green, yellow, red)
 EQUB  6,  6,  7        ; Poor            (docked/green, yellow, red)
 EQUB  8,  8,  8        ; Average
 EQUB  9,  9,  9        ; Above Average
 EQUB 10, 10, 10        ; Competent
 EQUB 11, 11, 11        ; Dangerous
 EQUB 12, 12, 12        ; Deadly
 EQUB 13, 13, 13        ; Elite
 EQUB 14, 14, 14        ; Unused

; ******************************************************************************
;
;       Name: GetHeadshot
;       Type: Subroutine
;   Category: Status
;    Summary: Fetch the headshot image for the commander and store it in the
;             pattern buffers, starting at pattern number picturePattern
;
; ******************************************************************************

.GetHeadshot

 LDA #0                 ; Set (SC+1 A) = (0 picturePattern)
 STA SC+1               ;              = picturePattern
 LDA picturePattern

 ASL A                  ; Set SC(1 0) = (SC+1 A) * 8
 ROL SC+1               ;             = picturePattern * 8
 ASL A
 ROL SC+1
 ASL A
 ROL SC+1
 STA SC

 STA SC2                ; Set SC2(1 0) = pattBuffer1 + SC(1 0)
 LDA SC+1               ;              = pattBuffer1 + picturePattern * 8
 ADC #HI(pattBuffer1)
 STA SC2+1

 LDA SC+1               ; Set SC(1 0) = pattBuffer0 + SC(1 0)
 ADC #HI(pattBuffer0)   ;             = pattBuffer0 + picturePattern * 8
 STA SC+1

 LDA imageSentToPPU     ; The value of imageSentToPPU was set in the STATUS
 ASL A                  ; routine to %1000xxxx, where %xxxx is the headshot
 TAX                    ; number (in the range 0 to 13), so set X to this
                        ; number * 2, so we can use it as an index into the
                        ; headOffset table, which has two bytes per entry

 LDA headOffset,X       ; Set V(1 0) = headOffset for image X + headCount
 CLC                    ;
 ADC #LO(headCount)     ; So V(1 0) points to headImage0 when X = 0, headImage1
 STA V                  ; when X = 1, and so on up to headImage13 when X = 13
 LDA headOffset+1,X
 ADC #HI(headCount)
 STA V+1

 JSR UnpackToRAM        ; Unpack the data at V(1 0) into SC(1 0), updating
                        ; V(1 0) as we go
                        ;
                        ; SC(1 0) is pattBuffer0 + picturePattern * 8, so this
                        ; unpacks the headshot pattern data into pattern buffer
                        ; 0, starting from pattern picturePattern

 LDA SC2                ; Set SC(1 0) = SC2(1 0)
 STA SC                 ;             = pattBuffer1 + picturePattern * 8
 LDA SC2+1
 STA SC+1

 JSR UnpackToRAM        ; Unpack the data at V(1 0) into SC(1 0), updating
                        ; V(1 0) as we go
                        ;
                        ; SC(1 0) is pattBuffer1 + picturePattern * 8, so this
                        ; unpacks the headshot pattern data into pattern buffer
                        ; 1, starting from pattern picturePattern

 RTS                    ; Return from the subroutine

; ******************************************************************************
;
;       Name: GetCmdrImage
;       Type: Subroutine
;   Category: Status
;    Summary: Fetch the headshot image for the commander and store it in the
;             pattern buffers, and send the face and glasses images to the PPU
;
; ******************************************************************************

.GetCmdrImage

 JSR GetHeadshot        ; Fetch the headshot image for the commander and store
                        ; it in the pattern buffers, starting at pattern number
                        ; picturePattern

 LDA imageSentToPPU     ; The value of imageSentToPPU was set in the STATUS
 ASL A                  ; routine to %1000xxxx, where %xxxx is the headshot
 TAX                    ; number (in the range 0 to 13), so set X to this
                        ; number * 2, so we can use it as an index into the
                        ; faceOffset table, which has two bytes per entry

 CLC                    ; Set V(1 0) = faceOffset for image X + faceCount
 LDA faceOffset,X       ;
 ADC #LO(faceCount)     ; So V(1 0) points to faceImage0 when X = 0, faceImage1
 STA V                  ; when X = 1, and so on up to faceImage13 when X = 13
 LDA faceOffset+1,X
 ADC #HI(faceCount)
 STA V+1

 LDA #HI(16*69)         ; Set PPU_ADDR to the address of pattern 69 in pattern
 STA PPU_ADDR           ; table 0
 LDA #LO(16*69)         ;
 STA PPU_ADDR           ; So we can unpack the image data for the relevant face
                        ; image into pattern 69 onwards in pattern table 0

 JSR UnpackToPPU        ; Unpack the image data to the PPU

 LDA #HI(glassesImage)  ; Set V(1 0) = glassesImage
 STA V+1                ;
 LDA #LO(glassesImage)  ; So we can unpack the image data for the glasses into
 STA V                  ; the next few pattern bytes in pattern table 0

 JMP UnpackToPPU        ; Unpack the image data to the PPU, returning from the
                        ; subroutine using a tail call

; ******************************************************************************
;
;       Name: DrawBigLogo
;       Type: Subroutine
;   Category: Start and end
;    Summary: Set the pattern and nametable buffer entries for the big Elite
;             logo on the Start screen
;
; ******************************************************************************

.DrawBigLogo

 LDA #HI(bigLogoImage)  ; Set V(1 0) = bigLogoImage
 STA V+1                ;
 LDA #LO(bigLogoImage)  ; So we can unpack the image data for the big Elite logo
 STA V                  ; into the pattern buffers

 LDA firstFreePattern   ; Set K+2 to the next free pattern number, to send to
 TAY                    ; the DrawImageNames routine below as the pattern number
 STY K+2                ; of the start of the big logo data

 ASL A                  ; Set SC(1 0) = pattBuffer0 + firstFreePattern * 8
 STA SC                 ;
 LDA #LO(pattBuffer0)   ; So this points to the pattern in pattern buffer 0 that
 ROL A                  ; corresponds to the next free pattern in
 ASL SC                 ; firstFreePattern
 ROL A
 ASL SC
 ROL A
 ADC #HI(pattBuffer0)
 STA SC+1

 ADC #8                 ; Set SC2(1 0) = SC(1 0) + (8 0)
 STA SC2+1              ;
 LDA SC                 ; Pattern buffer 0 consists of 8 pages of memory and is
 STA SC2                ; followed by pattern buffer 1, so this sets SC2(1 0) to
                        ; the pattern in pattern buffer 1 that corresponds to
                        ; the next free pattern in firstFreePattern

 JSR UnpackToRAM        ; Unpack the data at V(1 0) into SC(1 0), updating
                        ; V(1 0) as we go
                        ;
                        ; SC(1 0) is pattBuffer0 + firstFreePattern * 8, so this
                        ; unpacks the big logo pattern data into pattern buffer
                        ; 0, starting from pattern firstFreePattern

 LDA SC2                ; Set SC(1 0) = SC2(1 0)
 STA SC                 ;             = pattBuffer1 + picturePattern * 8
 LDA SC2+1
 STA SC+1

 JSR UnpackToRAM        ; Unpack the data at V(1 0) into SC(1 0), updating
                        ; V(1 0) as we go
                        ;
                        ; SC(1 0) is pattBuffer0 + firstFreePattern * 8, so this
                        ; unpacks the big logo pattern data into pattern buffer
                        ; 0, starting from pattern firstFreePattern

 LDA #HI(bigLogoNames)  ; Set V(1 0) = bigLogoNames, so the call to
 STA V+1                ; DrawImageNames draws the big Elite logo
 LDA #LO(bigLogoNames)
 STA V

 LDA #24                ; Set K = 24 so the call to DrawImageNames draws 26
 STA K                  ; tiles in each row

 LDA #20                ; Set K+1 = 20 so the call to DrawImageNames draws 20
 STA K+1                ; rows of tiles

 LDA #1                 ; Set XC and YC so the call to DrawImageNames draws the
 STA YC                 ; big logo at text column 5 on row 1
 LDA #5
 STA XC

 JSR DrawImageNames     ; Draw the big Elite logo at text column 5 on row 1

 LDA firstFreePattern   ; The big logo takes up 208 patterns, so add 208 to the
 CLC                    ; next free pattern number in firstFreePattern, as we
 ADC #208               ; just used up that many patterns
 STA firstFreePattern

 RTS                    ; Return from the subroutine

; ******************************************************************************
;
;       Name: DrawImageNames
;       Type: Subroutine
;   Category: Drawing the screen
;    Summary: Set the nametable buffer entries for the specified image
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
;   V(1 0)              The address of the nametable entry table for the image
;
;   XC                  The text column of the top-left corner of the image
;
;   YC                  The text row of the top-left corner of the image
;
; ******************************************************************************

.DrawImageNames

 LDA #32                ; Set ZZ = 32 - K
 SEC                    ;
 SBC K                  ; As there are 32 nametable entries on each screen row,
 STA ZZ                 ; this gives us a number we can add to the address of
                        ; the nametable entry for the last tile on a row, to
                        ; give us the address of the nametable entry for the
                        ; first tile on the next row of the image

 JSR GetRowNameAddress  ; Get the addresses in the nametable buffers for the
                        ; start of character row YC, as follows:
                        ;
                        ;   SC(1 0) = the address in nametable buffer 0
                        ;
                        ;   SC2(1 0) = the address in nametable buffer 1

 LDA SC                 ; Set SC(1 0) = SC(1 0) + XC
 CLC                    ;
 ADC XC                 ; So SC(1 0) contains the address in nametable buffer 0
 STA SC                 ; of the text character at column XC on row YC, which is
                        ; where we want to draw the image

                        ; We now loop through the nametable entry table, copying
                        ; tile numbers from the table to the nametable buffers,
                        ; row by row

 LDY #0                 ; Set a tile counter in Y to increment as we draw each
                        ; tile, starting with Y = 0 for the first tile at the
                        ; start of the first row

.dimg1

 LDX K                  ; Set X to the number of tiles in each row of the image,
                        ; so we can use it as a column counter as we move along
                        ; each row

.dimg2

 LDA (V),Y              ; Fetch the Y-th byte from the nametable entry table for
                        ; the image we want to draw
                        ;
                        ; This contains the pattern number for this tile, as an
                        ; offset from the start of the pattern data for this
                        ; image, which we already stored in the pattern buffer
                        ; at pattern number K+2
                        ;
                        ; So the pattern number for this tile within the pattern
                        ; buffer will be A + K+2

 BEQ dimg3              ; If it is zero, then this is a background tile, so skip
                        ; the following two instructions to keep A as zero

 CLC                    ; Set A = A + K+2
 ADC K+2                ;
                        ; So A contains the pattern number in the pattern
                        ; buffer, which is what we want to store in the
                        ; nametable buffer

.dimg3

 STA (SC),Y             ; Store the pattern number in the Y-th entry in the
                        ; nametable buffer

 INY                    ; Increment the tile number to move to the next tile

 BNE dimg4              ; If Y increments from 255 to zero, increment the high
 INC V+1                ; bytes of V(1 0) and SC(1 0) to point to the next page
 INC SC+1               ; in memory

.dimg4

 DEX                    ; Decrement the column counter for this row

 BNE dimg2              ; Loop back to dimg2 to draw the next tile, until we
                        ; have drawn all the tiles in this row

                        ; At this point SC(1 0) + Y is the address of the last
                        ; tile on the row we just drew, so adding ZZ to this
                        ; address (which we set to 32 - K above) updates
                        ; SC(1 0) + Y to the address of the first tile on the
                        ; next row in the image

 LDA SC                 ; Set SC(1 0) = SC(1 0) + ZZ
 CLC                    ;
 ADC ZZ                 ; Starting with the low bytes
 STA SC

 BCC dimg5              ; And then the high bytes
 INC SC+1

.dimg5

 DEC K+1                ; Decrement the number of rows in K+1

 BNE dimg1              ; Loop back to dimg1 until we have drawn all the rows in
                        ; the image

 RTS                    ; Return from the subroutine

; ******************************************************************************
;
;       Name: DrawSmallLogo
;       Type: Subroutine
;   Category: Save and load
;    Summary: Set the sprite buffer entries for the small Elite logo on the Save
;             and Load screen
;
; ------------------------------------------------------------------------------
;
; Arguments:
;
;   CNT                 Offset of the first free sprite block within the sprite
;                       buffer, which we can use for drawing the logo
;
; ******************************************************************************

.DrawSmallLogo

 LDA #1                 ; Set XC = 1 so we draw the top-left corner of the logo
 STA XC                 ; at text column 1 (plus the pixel value in X that we
                        ; set below)

 ASL A                  ; Set YC = 1 so we draw the top-left corner of the logo
 STA YC                 ; on text row 2 (plus the pixel value in Y that we
                        ; set below)

 LDX #8                 ; Set K = 8 so we draw 8 tiles in each row
 STX K

 STX K+1                ; Set K+1 = 8 so we draw 8 rows in total

 LDX #6                 ; Set X = 6 so we draw the logo at a point 6 pixels
                        ; into text column 1 (i.e. on the sixth pixel along the
                        ; x-axis in the character block in column 1)

 LDY #6                 ; Set Y = 6 so we draw the logo at a point 6 pixels
                        ; into text row 2 (i.e. on the sixth pixel down the
                        ; y-axis in the character block in row 2)

 LDA #67                ; Set K+2 = 67 to use as the pattern number of the first
 STA K+2                ; pattern for the small logo

 LDA CNT                ; Set K+3 = CNT / 4, which we use below when rounding
 LSR A                  ; down the sprite buffer offset to a multiple of four
 LSR A
 STA K+3

 LDA #HI(smallLogoTile) ; Set V(1 0) = smallLogoTile so we draw the small
 STA V+1                ; Elite logo in the following
 LDA #LO(smallLogoTile)
 STA V

 LDA #%00000001         ; Set S to use as the attribute for each of the sprites
 STA S                  ; in the logo, so each sprite is set as follows:
                        ;
                        ;   * Bits 0-1    = sprite palette 1
                        ;   * Bit 5 clear = show in front of background
                        ;   * Bit 6 clear = do not flip horizontally
                        ;   * Bit 7 clear = do not flip vertically

 LDA XC                 ; Set SC = XC * 8 + X
 ASL A                  ;        = XC * 8 + 6
 ASL A                  ;
 ASL A                  ; So SC is the pixel x-coordinate of the top-left corner
 ADC #0                 ; of the logo we want to draw, as each text character in
 STA SC                 ; XC is 8 pixels wide and X contains the x-coordinate
 TXA                    ; within the character block
 ADC SC
 STA SC

 LDA YC                 ; Set SC+1 = YC * 8 + 6 + Y
 ASL A                  ;          = YC * 8 + 6 + 6
 ASL A                  ;
 ASL A                  ; So SC+1 is the pixel y-coordinate of the top-left
 ADC #6+YPAL            ; corner of the logo we want to draw, as each text row
 STA SC+1               ; in YC is 8 pixels high and Y contains the y-coordinate
 TYA                    ; within the character block
 ADC SC+1
 STA SC+1

 LDA K+3                ; Set X = K+3 * 4
 ASL A                  ;       = CNT / 4 * 4
 ASL A                  ;
 TAX                    ; So X contains the offset of the sprite's four-byte
                        ; block in the sprite buffer, as each sprite consists
                        ; of four bytes, so this is now the offset within the
                        ; sprite buffer of the first sprite we can use

 LDA K+1                ; Set T = K+1 to use as a counter for each row in the
 STA T                  ; logo

 LDY #0                 ; Set a tile counter in Y to increment as we draw each
                        ; tile, starting with Y = 0 for the first tile at the
                        ; start of the first row, and counting across and down

.drsm1

 SETUP_PPU_FOR_ICON_BAR ; If the PPU has started drawing the icon bar, configure
                        ; the PPU to use nametable 0 and pattern table 0

 LDA SC                 ; Set SC2 to the pixel x-coordinate for the start of
 STA SC2                ; each row, so we can use it to move along the row as we
                        ; draw the logo

 LDA K                  ; Set ZZ to the number of tiles in each row of the logo
 STA ZZ                 ; (in K), so we can use it as a counter as we move along
                        ; the row

.drsm2

 LDA (V),Y              ; Fetch the pattern number for the Y-th tile in the logo
                        ; from the smallLogoTile table at V(1 0), which gives us
                        ; the pattern number for this tile from the patterns
                        ; in the smallLogoImage table, which is loaded at the
                        ; pattern number in K+2

 INY                    ; Increment the tile counter to point to the next tile

 BNE drsm3              ; If we just incremented Y past a page boundary and back
 INC V+1                ; to zero, increment the high byte of V(1 0) to point to
                        ; the next page

.drsm3

 CMP #0                 ; If the pattern number is zero, then this is the
 BEQ drsm4              ; background, so jump to drsm4 to move on to the next
                        ; tile in the logo

 ADC K+2                ; Set the pattern for sprite X to A + K+2, which is the
 STA pattSprite0,X      ; pattern number in the PPU's pattern table to use for
                        ; this part of the logo

 LDA S                  ; Set the attributes for sprite X to S, which we set
 STA attrSprite0,X      ; above as follows:
                        ;
                        ;   * Bits 0-1    = sprite palette 1
                        ;   * Bit 5 clear = show in front of background
                        ;   * Bit 6 clear = do not flip horizontally
                        ;   * Bit 7 clear = do not flip vertically

 LDA SC2                ; Set the x-coordinate for sprite X to SC2
 STA xSprite0,X

 LDA SC+1               ; Set the y-coordinate for sprite X to SC+1
 STA ySprite0,X

 TXA                    ; Add 4 to the sprite number in X, to move on to the
 CLC                    ; next sprite in the sprite buffer (as each sprite
 ADC #4                 ; consists of four bytes of data)

 BCS drsm5              ; If the addition overflowed, then we have reached the
                        ; end of the sprite buffer, so jump to drsm5 to return
                        ; from the subroutine, as we have run out of sprites

 TAX                    ; Otherwise set X to the offset of the next sprite in
                        ; the sprite buffer

.drsm4

 LDA SC2                ; Set SC2 = SC2 + 8
 CLC                    ;
 ADC #8                 ; So SC2 contains the x-coordinate of the next tile
 STA SC2                ; along the row

 DEC ZZ                 ; Decrement the tile counter in ZZ as we have just drawn
                        ; a tile

 BNE drsm2              ; If ZZ is non-zero then we still have more tiles to
                        ; draw on the current row, so jump back to drsm2 to draw
                        ; the next one

 LDA SC+1               ; Otherwise we have reached the end of this row, so add
 ADC #8                 ; 8 to SC+1 to move the y-coordinate down to the next
 STA SC+1               ; tile row (as each tile row is 8 pixels high)

 DEC T                  ; Decrement the number of rows in T as we just finished
                        ; drawing a row

 BNE drsm1              ; Loop back to drsm1 until we have drawn all the rows in
                        ; the image

.drsm5

 RTS                    ; Return from the subroutine

; ******************************************************************************
;
;       Name: Vectors_b4
;       Type: Variable
;   Category: Utility routines
;    Summary: Vectors and padding at the end of ROM bank 4
;  Deep dive: Splitting NES Elite across multiple ROM banks
;
; ******************************************************************************

 FOR I%, P%, $BFF9

  EQUB $FF              ; Pad out the rest of the ROM bank with $FF

 NEXT

IF _NTSC

 EQUW Interrupts_b4+$4000   ; Vector to the NMI handler in case this bank is
                            ; loaded into $C000 during start-up (the handler
                            ; contains an RTI so the interrupt is processed but
                            ; has no effect)

 EQUW ResetMMC1_b4+$4000    ; Vector to the RESET handler in case this bank is
                            ; loaded into $C000 during start-up (the handler
                            ; resets the MMC1 mapper to map bank 7 into $C000
                            ; instead)

 EQUW Interrupts_b4+$4000   ; Vector to the IRQ/BRK handler in case this bank is
                            ; loaded into $C000 during start-up (the handler
                            ; contains an RTI so the interrupt is processed but
                            ; has no effect)

ELIF _PAL

 EQUW NMI                   ; Vector to the NMI handler

 EQUW ResetMMC1_b4+$4000    ; Vector to the RESET handler in case this bank is
                            ; loaded into $C000 during start-up (the handler
                            ; resets the MMC1 mapper to map bank 7 into $C000
                            ; instead)

 EQUW IRQ                   ; Vector to the IRQ/BRK handler

ENDIF

; ******************************************************************************
;
; Save bank4.bin
;
; ******************************************************************************

 PRINT "S.bank4.bin ", ~CODE%, " ", ~P%, " ", ~LOAD%, " ", ~LOAD%
 SAVE "3-assembled-output/bank4.bin", CODE%, P%, LOAD%
