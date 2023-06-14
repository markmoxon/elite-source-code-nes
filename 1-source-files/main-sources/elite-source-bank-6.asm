; ******************************************************************************
;
; NES ELITE GAME SOURCE (BANK 6)
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
;   * bank6.bin
;
; ******************************************************************************

 INCLUDE "1-source-files/main-sources/elite-build-options.asm"

 _BANK = 6

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
;       Name: subm_800C
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.subm_800C

 JMP subm_8021

; ******************************************************************************
;
;       Name: subm_800F
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.subm_800F

 JMP PlayMusic

; ******************************************************************************
;
;       Name: ResetSound
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.ResetSound

 JMP DoResetSound

; ******************************************************************************
;
;       Name: subm_8015
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.subm_8015

 JMP subm_80E5

; ******************************************************************************
;
;       Name: subm_8018
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.subm_8018

 JMP subm_895A

; ******************************************************************************
;
;       Name: subm_801B
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.subm_801B

 JMP subm_89DC

; ******************************************************************************
;
;       Name: subm_801E
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.subm_801E

 JMP subm_8A53

; ******************************************************************************
;
;       Name: subm_8021
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.subm_8021

 TAY
 JSR ResetSound
 LDA #0
 CLC

.loop_C8028

 DEY
 BMI C802F
 ADC #9
 BNE loop_C8028

.C802F

 TAX
 LDA #0
 LDY #$12

.loop_C8034

 STA L030E,Y
 STA L0321,Y
 STA L0334,Y
 STA L0347,Y
 DEY
 BPL loop_C8034
 TAY
 LDA L915F,X
 STA L0305
 STA L0306
 LDA L9160,X
 STA L0310
 STA L00FE
 LDA L9161,X
 STA L0311
 STA L00FF
 LDA (L00FE),Y
 STA L030E
 INY
 LDA (L00FE),Y
 STA L030F
 LDA L9162,X
 STA L0323
 STA L00FE
 LDA L9163,X
 STA L0324
 STA L00FF
 DEY
 LDA (L00FE),Y
 STA L0321
 INY
 LDA (L00FE),Y
 STA L0322
 LDA L9164,X
 STA L0336
 STA L00FE
 LDA L9165,X
 STA L0337
 STA L00FF
 DEY
 LDA (L00FE),Y
 STA L0334
 INY
 LDA (L00FE),Y
 STA L0335
 LDA L9166,X
 STA L0349
 STA L00FE
 LDA L9167,X
 STA L034A
 STA L00FF
 DEY
 LDA (L00FE),Y
 STA L0347
 INY
 LDA (L00FE),Y
 STA L0348
 STY L0316
 STY L0329
 STY L033C
 STY L034F
 INY
 STY L0312
 STY L0325
 STY L0338
 STY L034B
 LDX #0
 STX L030C
 DEX
 STX L030B
 STX L030D
 INC L0301
 RTS

; ******************************************************************************
;
;       Name: subm_80E5
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.subm_80E5

 LDA L030D
 BEQ C80F2
 LDA L0301
 BNE C80F2
 INC L0301

.C80F2

 RTS

; ******************************************************************************
;
;       Name: DoResetSound
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.DoResetSound

 LDA #0
 STA L0301
 STA L0302
 STA L0303
 STA L0304
 TAX

.loop_C8102

 STA L035A,X
 INX
 CPX #$10
 BNE loop_C8102
 STA TRI_LINEAR
 LDA #$30
 STA SQ1_VOL
 STA SQ2_VOL
 STA NOISE_VOL
 LDA #$0F
 STA SND_CHN
 RTS

; ******************************************************************************
;
;       Name: PlayMusic
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.PlayMusic

 JSR subm_816D
 JSR subm_8AC8
 LDA L0301
 BEQ C816C
 LDA L0302
 BNE C813F
 LDA L035A
 STA SQ1_VOL
 LDA L0318
 BNE C813F
 LDA L035C
 STA SQ1_LO

.C813F

 LDA L0303
 BNE C8155
 LDA L035E
 STA SQ2_VOL
 LDA L032B
 BNE C8155
 LDA L0360
 STA SQ2_LO

.C8155

 LDA L0364
 STA TRI_LO
 LDA L0304
 BNE C816C
 LDA L0366
 STA NOISE_VOL
 LDA L0368
 STA NOISE_LO

.C816C

 RTS

; ******************************************************************************
;
;       Name: subm_816D
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.subm_816D

 LDA L0301
 BNE C8173
 RTS

.C8173

 LDA L0305
 CLC
 ADC L030B
 STA L030B
 BCC C818B
 JSR subm_8197
 JSR subm_8392
 JSR subm_858D
 JSR subm_8725

.C818B

 JSR subm_8334
 JSR subm_852F
 JSR subm_86EE
 JMP C885D

; ******************************************************************************
;
;       Name: subm_8197
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.subm_8197

 DEC L0316
 BEQ C819D
 RTS

.C819D

 LDA L030E
 STA L00FE
 LDA L030F
 STA L00FF
 LDA #0
 STA L0318
 STA L0320

.C81AF

 LDY #0
 LDA (L00FE),Y
 TAY
 INC L00FE
 BNE C81BA
 INC L00FF

.C81BA

 TYA
 BMI C8217
 CMP #$60
 BCC C81C9
 ADC #$A0
 STA L0315
 JMP C81AF

.C81C9

 CLC
 ADC L030C
 CLC
 ADC L0314
 ASL A
 TAY
 LDA L88BC,Y
 STA L031B
 STA L035C
 LDA L88BC+1,Y
 STA L035D
 LDX L0302
 BNE C81F6
 LDX L0318
 STX SQ1_SWEEP
 LDX L035C
 STX SQ1_LO
 STA SQ1_HI

.C81F6

 LDA #1
 STA L031C
 LDA L031D
 STA L031E

.C8201

 LDA #$FF
 STA L0320

.C8206

 LDA L00FE
 STA L030E
 LDA L00FF
 STA L030F
 LDA L0315
 STA L0316
 RTS

.C8217

 LDY #0
 CMP #$FF
 BNE C8265
 LDA L0312
 CLC
 ADC L0310
 STA L00FE
 LDA L0313
 ADC L0311
 STA L00FF
 LDA L0312
 ADC #2
 STA L0312
 TYA
 ADC L0313
 STA L0313
 LDA (L00FE),Y
 INY
 ORA (L00FE),Y
 BNE C8258
 LDA L0310
 STA L00FE
 LDA L0311
 STA L00FF
 LDA #2
 STA L0312
 LDA #0
 STA L0313

.C8258

 LDA (L00FE),Y
 TAX
 DEY
 LDA (L00FE),Y
 STA L00FE
 STX L00FF
 JMP C81AF

.C8265

 CMP #$F6
 BNE C8277
 LDA (L00FE),Y
 INC L00FE
 BNE C8271
 INC L00FF

.C8271

 STA L031F
 JMP C81AF

.C8277

 CMP #$F7
 BNE C828C
 LDA (L00FE),Y
 INC L00FE
 BNE C8283
 INC L00FF

.C8283

 STA L031A
 STY L0319
 JMP C81AF

.C828C

 CMP #$FA
 BNE C829E
 LDA (L00FE),Y
 STA L0317
 INC L00FE
 BNE C829B
 INC L00FF

.C829B

 JMP C81AF

.C829E

 CMP #$F8
 BNE C82AA
 LDA #$30
 STA L035A
 JMP C8206

.C82AA

 CMP #$F9
 BNE C82B1
 JMP C8201

.C82B1

 CMP #$FD
 BNE C82C3
 LDA (L00FE),Y
 INC L00FE
 BNE C82BD
 INC L00FF

.C82BD

 STA L0318
 JMP C81AF

.C82C3

 CMP #$FB
 BNE C82D5
 LDA (L00FE),Y
 INC L00FE
 BNE C82CF
 INC L00FF

.C82CF

 STA L030C
 JMP C81AF

.C82D5

 CMP #$FC
 BNE C82E7
 LDA (L00FE),Y
 INC L00FE
 BNE C82E1
 INC L00FF

.C82E1

 STA L0314
 JMP C81AF

.C82E7

 CMP #$F5
 BNE C8311
 LDA (L00FE),Y
 TAX
 STA L0310
 INY
 LDA (L00FE),Y
 STX L00FE
 STA L00FF
 STA L0311
 LDA #2
 STA L0312
 DEY
 STY L0313
 LDA (L00FE),Y
 TAX
 INY
 LDA (L00FE),Y
 STA L00FF
 STX L00FE
 JMP C81AF

.C8311

 CMP #$F4
 BNE C8326
 LDA (L00FE),Y
 INC L00FE
 BNE C831D
 INC L00FF

.C831D

 STA L0305
 STA L0306
 JMP C81AF

.C8326

 CMP #$FE
 BNE C8332
 STY L030D
 PLA
 PLA
 JMP ResetSound

.C8332

 BEQ C8332

; ******************************************************************************
;
;       Name: subm_8334
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.subm_8334

 LDA L0320
 BEQ C836A
 LDX L031F
 LDA L902C,X
 STA L00FE
 LDA L9040,X
 STA L00FF
 LDY #0
 LDA (L00FE),Y
 STA L031D
 LDY L031C
 LDA (L00FE),Y
 BMI C8362
 DEC L031E
 BPL C8362
 LDX L031D
 STX L031E
 INC L031C

.C8362

 AND #$0F
 ORA L0317
 STA L035A

.C836A

 LDX L031A
 LDA L9119,X
 STA L00FE
 LDA L9121,X
 STA L00FF
 LDY L0319
 LDA (L00FE),Y
 CMP #$80
 BNE C8387
 LDY #0
 STY L0319
 LDA (L00FE),Y

.C8387

 INC L0319
 CLC
 ADC L031B
 STA L035C
 RTS

; ******************************************************************************
;
;       Name: subm_8392
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.subm_8392

 DEC L0329
 BEQ C8398
 RTS

.C8398

 LDA L0321
 STA L00FE
 LDA L0322
 STA L00FF
 LDA #0
 STA L032B
 STA L0333

.C83AA

 LDY #0
 LDA (L00FE),Y
 TAY
 INC L00FE
 BNE C83B5
 INC L00FF

.C83B5

 TYA
 BMI C8412
 CMP #$60
 BCC C83C4
 ADC #$A0
 STA L0328
 JMP C83AA

.C83C4

 CLC
 ADC L030C
 CLC
 ADC L0327
 ASL A
 TAY
 LDA L88BC,Y
 STA L032E
 STA L0360
 LDA L88BC+1,Y
 STA L0361
 LDX L0303
 BNE C83F1
 LDX L032B
 STX SQ2_SWEEP
 LDX L0360
 STX SQ2_LO
 STA SQ2_HI

.C83F1

 LDA #1
 STA L032F
 LDA L0330
 STA L0331

.C83FC

 LDA #$FF
 STA L0333

.C8401

 LDA L00FE
 STA L0321
 LDA L00FF
 STA L0322
 LDA L0328
 STA L0329
 RTS

.C8412

 LDY #0
 CMP #$FF
 BNE C8460
 LDA L0325
 CLC
 ADC L0323
 STA L00FE
 LDA L0326
 ADC L0324
 STA L00FF
 LDA L0325
 ADC #2
 STA L0325
 TYA
 ADC L0326
 STA L0326
 LDA (L00FE),Y
 INY
 ORA (L00FE),Y
 BNE C8453
 LDA L0323
 STA L00FE
 LDA L0324
 STA L00FF
 LDA #2
 STA L0325
 LDA #0
 STA L0326

.C8453

 LDA (L00FE),Y
 TAX
 DEY
 LDA (L00FE),Y
 STA L00FE
 STX L00FF
 JMP C83AA

.C8460

 CMP #$F6
 BNE C8472
 LDA (L00FE),Y
 INC L00FE
 BNE C846C
 INC L00FF

.C846C

 STA L0332
 JMP C83AA

.C8472

 CMP #$F7
 BNE C8487
 LDA (L00FE),Y
 INC L00FE
 BNE C847E
 INC L00FF

.C847E

 STA L032D
 STY L032C
 JMP C83AA

.C8487

 CMP #$FA
 BNE C8499
 LDA (L00FE),Y
 STA L032A
 INC L00FE
 BNE C8496
 INC L00FF

.C8496

 JMP C83AA

.C8499

 CMP #$F8
 BNE C84A5
 LDA #$30
 STA L035E
 JMP C8401

.C84A5

 CMP #$F9
 BNE C84AC
 JMP C83FC

.C84AC

 CMP #$FD
 BNE C84BE
 LDA (L00FE),Y
 INC L00FE
 BNE C84B8
 INC L00FF

.C84B8

 STA L032B
 JMP C83AA

.C84BE

 CMP #$FB
 BNE C84D0
 LDA (L00FE),Y
 INC L00FE
 BNE C84CA
 INC L00FF

.C84CA

 STA L030C
 JMP C83AA

.C84D0

 CMP #$FC
 BNE C84E2
 LDA (L00FE),Y
 INC L00FE
 BNE C84DC
 INC L00FF

.C84DC

 STA L0327
 JMP C83AA

.C84E2

 CMP #$F5
 BNE C850C
 LDA (L00FE),Y
 TAX
 STA L0323
 INY
 LDA (L00FE),Y
 STX L00FE
 STA L00FF
 STA L0324
 LDA #2
 STA L0325
 DEY
 STY L0326
 LDA (L00FE),Y
 TAX
 INY
 LDA (L00FE),Y
 STA L00FF
 STX L00FE
 JMP C83AA

.C850C

 CMP #$F4
 BNE C8521
 LDA (L00FE),Y
 INC L00FE
 BNE C8518
 INC L00FF

.C8518

 STA L0305
 STA L0306
 JMP C83AA

.C8521

 CMP #$FE
 BNE C852D
 STY L030D
 PLA
 PLA
 JMP ResetSound

.C852D

 BEQ C852D

; ******************************************************************************
;
;       Name: subm_852F
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.subm_852F

 LDA L0333
 BEQ C8565
 LDX L0332
 LDA L902C,X
 STA L00FE
 LDA L9040,X
 STA L00FF
 LDY #0
 LDA (L00FE),Y
 STA L0330
 LDY L032F
 LDA (L00FE),Y
 BMI C855D
 DEC L0331
 BPL C855D
 LDX L0330
 STX L0331
 INC L032F

.C855D

 AND #$0F
 ORA L032A
 STA L035E

.C8565

 LDX L032D
 LDA L9119,X
 STA L00FE
 LDA L9121,X
 STA L00FF
 LDY L032C
 LDA (L00FE),Y
 CMP #$80
 BNE C8582
 LDY #0
 STY L032C
 LDA (L00FE),Y

.C8582

 INC L032C
 CLC
 ADC L032E
 STA L0360
 RTS

; ******************************************************************************
;
;       Name: subm_858D
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.subm_858D

 DEC L033C
 BEQ C8593
 RTS

.C8593

 LDA L0334
 STA L00FE
 LDA L0335
 STA L00FF

.C859D

 LDY #0
 LDA (L00FE),Y
 TAY
 INC L00FE
 BNE C85A8
 INC L00FF

.C85A8

 TYA
 BMI C85F5
 CMP #$60
 BCC C85B7
 ADC #$A0
 STA L033B
 JMP C859D

.C85B7

 CLC
 ADC L030C
 CLC
 ADC L033A
 ASL A
 TAY
 LDA L88BC,Y
 STA L0341
 STA L0364
 LDA L88BC+1,Y
 LDX L0364
 STX TRI_LO
 STA TRI_HI
 STA L0365
 LDA L0345
 STA L0342
 LDA #$81
 STA TRI_LINEAR

.C85E4

 LDA L00FE
 STA L0334
 LDA L00FF
 STA L0335
 LDA L033B
 STA L033C
 RTS

.C85F5

 LDY #0
 CMP #$FF
 BNE C8643
 LDA L0338
 CLC
 ADC L0336
 STA L00FE
 LDA L0339
 ADC L0337
 STA L00FF
 LDA L0338
 ADC #2
 STA L0338
 TYA
 ADC L0339
 STA L0339
 LDA (L00FE),Y
 INY
 ORA (L00FE),Y
 BNE C8636
 LDA L0336
 STA L00FE
 LDA L0337
 STA L00FF
 LDA #2
 STA L0338
 LDA #0
 STA L0339

.C8636

 LDA (L00FE),Y
 TAX
 DEY
 LDA (L00FE),Y
 STA L00FE
 STX L00FF
 JMP C859D

.C8643

 CMP #$F6
 BNE C8655
 LDA (L00FE),Y
 INC L00FE
 BNE C864F
 INC L00FF

.C864F

 STA L0345
 JMP C859D

.C8655

 CMP #$F7
 BNE C866A
 LDA (L00FE),Y
 INC L00FE
 BNE C8661
 INC L00FF

.C8661

 STA L0340
 STY L033F
 JMP C859D

.C866A

 CMP #$F8
 BNE C8676
 LDA #1
 STA L0342
 JMP C85E4

.C8676

 CMP #$F9
 BNE C867D
 JMP C85E4

.C867D

 CMP #$FB
 BNE C868F
 LDA (L00FE),Y
 INC L00FE
 BNE C8689
 INC L00FF

.C8689

 STA L030C
 JMP C859D

.C868F

 CMP #$FC
 BNE C86A1
 LDA (L00FE),Y
 INC L00FE
 BNE C869B
 INC L00FF

.C869B

 STA L033A
 JMP C859D

.C86A1

 CMP #$F5
 BNE C86CB
 LDA (L00FE),Y
 TAX
 STA L0336
 INY
 LDA (L00FE),Y
 STX L00FE
 STA L00FF
 STA L0337
 LDA #2
 STA L0338
 DEY
 STY L0339
 LDA (L00FE),Y
 TAX
 INY
 LDA (L00FE),Y
 STA L00FF
 STX L00FE
 JMP C859D

.C86CB

 CMP #$F4
 BNE C86E0
 LDA (L00FE),Y
 INC L00FE
 BNE C86D7
 INC L00FF

.C86D7

 STA L0305
 STA L0306
 JMP C859D

.C86E0

 CMP #$FE
 BNE C86EC
 STY L030D
 PLA
 PLA
 JMP ResetSound

.C86EC

 BEQ C86EC

; ******************************************************************************
;
;       Name: subm_86EE
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.subm_86EE

 LDA L0342
 BEQ C86FD
 DEC L0342
 BNE C86FD
 LDA #0
 STA TRI_LINEAR

.C86FD

 LDX L0340
 LDA L9119,X
 STA L00FE
 LDA L9121,X
 STA L00FF
 LDY L033F
 LDA (L00FE),Y
 CMP #$80
 BNE C871A
 LDY #0
 STY L033F
 LDA (L00FE),Y

.C871A

 INC L033F
 CLC
 ADC L0341
 STA L0364
 RTS

; ******************************************************************************
;
;       Name: subm_8725
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.subm_8725

 DEC L034F
 BEQ C872B
 RTS

.C872B

 LDA L0347
 STA L00FE
 LDA L0348
 STA L00FF
 STA L0359

.C8738

 LDY #0
 LDA (L00FE),Y
 TAY
 INC L00FE
 BNE C8743
 INC L00FF

.C8743

 TYA
 BMI C8788
 CMP #$60
 BCC C8752
 ADC #$A0
 STA L034E
 JMP C8738

.C8752

 AND #$0F
 STA L0354
 STA L0368
 LDY #0
 LDX L0304
 BNE C8767
 STA NOISE_LO
 STY NOISE_HI

.C8767

 LDA #1
 STA L0355
 LDA L0356
 STA L0357

.C8772

 LDA #$FF
 STA L0359
 LDA L00FE
 STA L0347
 LDA L00FF
 STA L0348
 LDA L034E
 STA L034F
 RTS

.C8788

 LDY #0
 CMP #$FF
 BNE C87D6
 LDA L034B
 CLC
 ADC L0349
 STA L00FE
 LDA L034C
 ADC L034A
 STA L00FF
 LDA L034B
 ADC #2
 STA L034B
 TYA
 ADC L034C
 STA L034C
 LDA (L00FE),Y
 INY
 ORA (L00FE),Y
 BNE C87C9
 LDA L0349
 STA L00FE
 LDA L034A
 STA L00FF
 LDA #2
 STA L034B
 LDA #0
 STA L034C

.C87C9

 LDA (L00FE),Y
 TAX
 DEY
 LDA (L00FE),Y
 STA L00FE
 STX L00FF
 JMP C8738

.C87D6

 CMP #$F6
 BNE C87E8
 LDA (L00FE),Y
 INC L00FE
 BNE C87E2
 INC L00FF

.C87E2

 STA L0358
 JMP C8738

.C87E8

 CMP #$F7
 BNE C87FD
 LDA (L00FE),Y
 INC L00FE
 BNE C87F4
 INC L00FF

.C87F4

 STA L0353
 STY L0352
 JMP C8738

.C87FD

 CMP #$F8
 BNE C8809
 LDA #$30
 STA L0366
 JMP C8772

.C8809

 CMP #$F9
 BNE C8810
 JMP C8772

.C8810

 CMP #$F5
 BNE C883A
 LDA (L00FE),Y
 TAX
 STA L0349
 INY
 LDA (L00FE),Y
 STX L00FE
 STA L00FF
 STA L034A
 LDA #2
 STA L034B
 DEY
 STY L034C
 LDA (L00FE),Y
 TAX
 INY
 LDA (L00FE),Y
 STA L00FF
 STX L00FE
 JMP C8738

.C883A

 CMP #$F4
 BNE C884F
 LDA (L00FE),Y
 INC L00FE
 BNE C8846
 INC L00FF

.C8846

 STA L0305
 STA L0306
 JMP C8738

.C884F

 CMP #$FE
 BNE C885B
 STY L030D
 PLA
 PLA
 JMP ResetSound

.C885B

 BEQ C885B

.C885D

 LDA L0359
 BEQ C8892
 LDX L0358
 LDA L902C,X
 STA L00FE
 LDA L9040,X
 STA L00FF
 LDY #0
 LDA (L00FE),Y
 STA L0356
 LDY L0355
 LDA (L00FE),Y
 BMI C888B
 DEC L0357
 BPL C888B
 LDX L0356
 STX L0357
 INC L0355

.C888B

 AND #$0F
 ORA #$30
 STA L0366

.C8892

 LDX L0353
 LDA L9119,X
 STA L00FE
 LDA L9121,X
 STA L00FF
 LDY L0352
 LDA (L00FE),Y
 CMP #$80
 BNE C88AF
 LDY #0
 STY L0352
 LDA (L00FE),Y

.C88AF

 INC L0352
 CLC
 ADC L0354
 AND #$0F
 STA L0368
 RTS

; ******************************************************************************
;
;       Name: L88BC
;       Type: Variable
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.L88BC

 EQUB $1A, $03, $EC, $02, $C2, $02, $9A, $02  ; 88BC: 1A 03 EC... ...
 EQUB $75, $02, $52, $02, $30, $02, $11, $02  ; 88C4: 75 02 52... u.R
 EQUB $E7, $03, $AF, $03, $7A, $03, $48, $03  ; 88CC: E7 03 AF... ...
 EQUB $1A, $03, $EC, $02, $C2, $02, $9A, $02  ; 88D4: 1A 03 EC... ...
 EQUB $75, $02, $52, $02, $30, $02, $11, $02  ; 88DC: 75 02 52... u.R
 EQUB $F3, $01, $D7, $01, $BD, $01, $A4, $01  ; 88E4: F3 01 D7... ...
 EQUB $8D, $01, $76, $01, $61, $01, $4D, $01  ; 88EC: 8D 01 76... ..v
 EQUB $3B, $01, $29, $01, $18, $01, $08, $01  ; 88F4: 3B 01 29... ;.)
 EQUB $F9, $00, $EB, $00, $DE, $00, $D1, $00  ; 88FC: F9 00 EB... ...
 EQUB $C5, $00, $BB, $00, $B0, $00, $A6, $00  ; 8904: C5 00 BB... ...
 EQUB $9D, $00, $94, $00, $8B, $00, $84, $00  ; 890C: 9D 00 94... ...
 EQUB $7C, $00, $75, $00, $6F, $00, $68, $00  ; 8914: 7C 00 75... |.u
 EQUB $62, $00, $5D, $00, $57, $00, $52, $00  ; 891C: 62 00 5D... b.]
 EQUB $4E, $00, $49, $00, $45, $00, $41, $00  ; 8924: 4E 00 49... N.I
 EQUB $3E, $00, $3A, $00, $37, $00, $34, $00  ; 892C: 3E 00 3A... >.:
 EQUB $31, $00, $2E, $00, $2B, $00, $29, $00  ; 8934: 31 00 2E... 1..
 EQUB $26, $00, $24, $00, $22, $00, $20, $00  ; 893C: 26 00 24... &.$
 EQUB $1E, $00, $1C, $00, $1B, $00, $19, $00  ; 8944: 1E 00 1C... ...
 EQUB $18, $00, $16, $00, $15, $00, $14, $00  ; 894C: 18 00 16... ...
 EQUB $13, $00, $12, $00, $11, $00            ; 8954: 13 00 12... ...

; ******************************************************************************
;
;       Name: subm_895A
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.subm_895A

 ASL A
 TAY
 LDA #0
 STA L0302
 LDA L8D7A,Y
 STA L00FE
 LDA L8D7A+1,Y
 STA L00FF
 LDY #$0D

.loop_C896D

 LDA (L00FE),Y
 STA L040B,Y
 DEY
 BPL loop_C896D

 SETUP_PPU_FOR_ICON_BAR ; If the PPU has started drawing the icon bar, configure
                        ; the PPU to use nametable 0 and pattern table 0

 LDA L0416
 STA L041E
 LDA L0418
 STA L041C
 LDA L040C
 STA L041B
 LDA L0415
 ASL A
 TAY
 LDA L8F7A,Y
 STA L0447
 STA L00FE
 LDA L8F7A+1,Y
 STA L0448
 STA L00FF
 LDY #0
 STY L041D
 LDA (L00FE),Y
 ORA L0411
 STA SQ1_VOL
 LDA #0
 STA SQ1_SWEEP
 LDA L040D
 STA L0419
 STA SQ1_LO
 LDA L040E
 STA L041A
 STA SQ1_HI
 INC L0302
 RTS

; ******************************************************************************
;
;       Name: subm_89D1
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.subm_89D1

 DEX
 BMI C89D9
 BEQ subm_89DC
 JMP subm_8A53

.C89D9

 JMP subm_895A

; ******************************************************************************
;
;       Name: subm_89DC
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.subm_89DC

 ASL A
 TAY
 LDA #0
 STA L0303
 LDA L8D7A,Y
 STA L00FE
 LDA L8D7A+1,Y
 STA L00FF
 LDY #$0D

.loop_C89EF

 LDA (L00FE),Y
 STA L041F,Y
 DEY
 BPL loop_C89EF

 SETUP_PPU_FOR_ICON_BAR ; If the PPU has started drawing the icon bar, configure
                        ; the PPU to use nametable 0 and pattern table 0

 LDA L042A
 STA L0432
 LDA L042C
 STA L0430
 LDA L0420
 STA L042F
 LDA L0429
 ASL A
 TAY
 LDA L8F7A,Y
 STA L0449
 STA L00FE
 LDA L8F7A+1,Y
 STA L044A
 STA L00FF
 LDY #0
 STY L0431
 LDA (L00FE),Y
 ORA L0425
 STA SQ2_VOL
 LDA #0
 STA SQ2_SWEEP
 LDA L0421
 STA L042D
 STA SQ2_LO
 LDA L0422
 STA L042E
 STA SQ2_HI
 INC L0303
 RTS

; ******************************************************************************
;
;       Name: subm_8A53
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.subm_8A53

 ASL A
 TAY
 LDA #0
 STA L0304
 LDA L8D7A,Y
 STA L00FE
 LDA L8D7A+1,Y
 STA L00FF
 LDY #$0D

.loop_C8A66

 LDA (L00FE),Y
 STA L0433,Y
 DEY
 BPL loop_C8A66

 SETUP_PPU_FOR_ICON_BAR ; If the PPU has started drawing the icon bar, configure
                        ; the PPU to use nametable 0 and pattern table 0

 LDA L043E
 STA L0446
 LDA L0440
 STA L0444
 LDA L0434
 STA L0443
 LDA L043D
 ASL A
 TAY
 LDA L8F7A,Y
 STA L044B
 STA L00FE
 LDA L8F7A+1,Y
 STA L044C
 STA L00FF
 LDY #0
 STY L0445
 LDA (L00FE),Y
 ORA L0439
 STA NOISE_VOL
 LDA #0
 STA NOISE_VOL+1
 LDA L0435
 AND #$0F
 STA L0441
 STA NOISE_LO
 LDA #0
 STA NOISE_HI
 INC L0304
 RTS

; ******************************************************************************
;
;       Name: subm_8AC8
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.subm_8AC8

 JSR subm_8D64
 JSR subm_8AD4
 JSR subm_8BBB
 JMP subm_8CA2

; ******************************************************************************
;
;       Name: subm_8AD4
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.subm_8AD4

 LDA L0302
 BNE C8ADA
 RTS

.C8ADA

 LDA L040B
 BNE C8B08
 LDX L0417
 BNE C8B08
 LDA L0301
 BEQ C8AFF
 LDA L035A
 STA SQ1_VOL
 LDA L035C
 STA SQ1_LO
 LDA L035D
 STA SQ1_HI
 STX L0302
 RTS

.C8AFF

 LDA #$30
 STA SQ1_VOL
 STX L0302
 RTS

.C8B08

 DEC L040B
 DEC L041E
 BNE C8B39
 LDA L0416
 STA L041E
 LDY L041D
 LDA L0447
 STA L00FE
 LDA L0448
 STA L00FF
 LDA (L00FE),Y
 BPL C8B2F
 CMP #$80
 BNE C8B39
 LDY #0
 LDA (L00FE),Y

.C8B2F

 ORA L0411
 STA SQ1_VOL
 INY
 STY L041D

.C8B39

 LDA L041B
 BNE C8B6C
 LDA L0417
 BNE C8B49
 LDA L0414
 BNE C8B49
 RTS

.C8B49

 DEC L0414
 LDA L040C
 STA L041B
 LDA L040D
 LDX L0412
 BEQ C8B5D
 ADC L0307

.C8B5D

 STA L0419
 STA SQ1_LO
 LDA L040E
 STA L041A
 STA SQ1_HI

.C8B6C

 DEC L041B
 LDA L0418
 BEQ C8B7C
 DEC L041C
 BNE C8BBA
 STA L041C

.C8B7C

 LDA L0413
 BEQ C8BBA
 BMI C8B9F
 LDA L0419
 SEC
 SBC L040F
 STA L0419
 STA SQ1_LO
 LDA L041A
 SBC L0410
 AND #3
 STA L041A
 STA SQ1_HI
 RTS

.C8B9F

 LDA L0419
 CLC
 ADC L040F
 STA L0419
 STA SQ1_LO
 LDA L041A
 ADC L0410
 AND #3
 STA L041A
 STA SQ1_HI

.C8BBA

 RTS

; ******************************************************************************
;
;       Name: subm_8BBB
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.subm_8BBB

 LDA L0303
 BNE C8BC1
 RTS

.C8BC1

 LDA L041F
 BNE C8BEF
 LDX L042B
 BNE C8BEF
 LDA L0301
 BEQ C8BE6
 LDA L035E
 STA SQ2_VOL
 LDA L0360
 STA SQ2_LO
 LDA L0361
 STA SQ2_HI
 STX L0303
 RTS

.C8BE6

 LDA #$30
 STA SQ2_VOL
 STX L0303
 RTS

.C8BEF

 DEC L041F
 DEC L0432
 BNE C8C20
 LDA L042A
 STA L0432
 LDY L0431
 LDA L0449
 STA L00FE
 LDA L044A
 STA L00FF
 LDA (L00FE),Y
 BPL C8C16
 CMP #$80
 BNE C8C20
 LDY #0
 LDA (L00FE),Y

.C8C16

 ORA L0425
 STA SQ2_VOL
 INY
 STY L0431

.C8C20

 LDA L042F
 BNE C8C53
 LDA L042B
 BNE C8C30
 LDA L0428
 BNE C8C30
 RTS

.C8C30

 DEC L0428
 LDA L0420
 STA L042F
 LDA L0421
 LDX L0426
 BEQ C8C44
 ADC L0307

.C8C44

 STA L042D
 STA SQ2_LO
 LDA L0422
 STA L042E
 STA SQ2_HI

.C8C53

 DEC L042F
 LDA L042C
 BEQ C8C63
 DEC L0430
 BNE C8CA1
 STA L0430

.C8C63

 LDA L0427
 BEQ C8CA1
 BMI C8C86
 LDA L042D
 SEC
 SBC L0423
 STA L042D
 STA SQ2_LO
 LDA L042E
 SBC L0424
 AND #3
 STA L042E
 STA SQ2_HI
 RTS

.C8C86

 LDA L042D
 CLC
 ADC L0423
 STA L042D
 STA SQ2_LO
 LDA L042E
 ADC L0424
 AND #3
 STA L042E
 STA SQ2_HI

.C8CA1

 RTS

; ******************************************************************************
;
;       Name: subm_8CA2
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.subm_8CA2

 LDA L0304
 BNE C8CA8
 RTS

.C8CA8

 LDA L0433
 BNE C8CD0
 LDX L043F
 BNE C8CD0
 LDA L0301
 BEQ C8CC7
 LDA L0366
 STA NOISE_VOL
 LDA L0368
 STA NOISE_LO
 STX L0304
 RTS

.C8CC7

 LDA #$30
 STA NOISE_VOL
 STX L0304
 RTS

.C8CD0

 DEC L0433
 DEC L0446
 BNE C8D01
 LDA L043E
 STA L0446
 LDY L0445
 LDA L044B
 STA L00FE
 LDA L044C
 STA L00FF
 LDA (L00FE),Y
 BPL C8CF7
 CMP #$80
 BNE C8D01
 LDY #0
 LDA (L00FE),Y

.C8CF7

 ORA L0439
 STA NOISE_VOL
 INY
 STY L0445

.C8D01

 LDA L0443
 BNE C8D2D
 LDA L043F
 BNE C8D11
 LDA L043C
 BNE C8D11
 RTS

.C8D11

 DEC L043C
 LDA L0434
 STA L0443
 LDA L0435
 LDX L043A
 BEQ C8D27
 ADC L0307
 AND #$0F

.C8D27

 STA L0441
 STA NOISE_LO

.C8D2D

 DEC L0443
 LDA L0440
 BEQ C8D3D
 DEC L0444
 BNE C8D63
 STA L0444

.C8D3D

 LDA L043B
 BEQ C8D63
 BMI C8D54
 LDA L0441
 SEC
 SBC L0437
 AND #$0F
 STA L0441
 STA NOISE_LO
 RTS

.C8D54

 LDA L0441
 CLC
 ADC L0437
 AND #$0F
 STA L0441
 STA NOISE_LO

.C8D63

 RTS

; ******************************************************************************
;
;       Name: subm_8D64
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.subm_8D64

 LDA L0307
 AND #$48
 ADC #$38
 ASL A
 ASL A
 ROL L030A
 ROL L0309
 ROL L0308
 ROL L0307
 RTS

; ******************************************************************************
;
;       Name: L8D7A
;       Type: Variable
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.L8D7A

 EQUB $BA, $8D, $C8, $8D, $D6, $8D, $E4, $8D  ; 8D7A: BA 8D C8... ...
 EQUB $F2, $8D, $00, $8E, $0E, $8E, $1C, $8E  ; 8D82: F2 8D 00... ...
 EQUB $2A, $8E, $38, $8E, $46, $8E, $54, $8E  ; 8D8A: 2A 8E 38... *.8
 EQUB $62, $8E, $70, $8E, $7E, $8E, $8C, $8E  ; 8D92: 62 8E 70... b.p
 EQUB $9A, $8E, $A8, $8E, $B6, $8E, $C4, $8E  ; 8D9A: 9A 8E A8... ...
 EQUB $D2, $8E, $E0, $8E, $EE, $8E, $FC, $8E  ; 8DA2: D2 8E E0... ...
 EQUB $0A, $8F, $18, $8F, $26, $8F, $34, $8F  ; 8DAA: 0A 8F 18... ...
 EQUB $42, $8F, $50, $8F, $5E, $8F, $6C, $8F  ; 8DB2: 42 8F 50... B.P
 EQUB $3C, $03, $04, $00, $02, $00, $30, $00  ; 8DBA: 3C 03 04... <..
 EQUB $01, $0A, $00, $05, $00, $63, $16, $04  ; 8DC2: 01 0A 00... ...
 EQUB $A8, $00, $04, $00, $70, $00, $FF, $63  ; 8DCA: A8 00 04... ...
 EQUB $0C, $02, $00, $00, $19, $19, $AC, $03  ; 8DD2: 0C 02 00... ...
 EQUB $1C, $00, $30, $00, $01, $63, $06, $02  ; 8DDA: 1C 00 30... ..0
 EQUB $FF, $00, $05, $63, $2C, $00, $00, $00  ; 8DE2: FF 00 05... ...
 EQUB $70, $00, $00, $63, $0C, $01, $00, $00  ; 8DEA: 70 00 00... p..
 EQUB $09, $63, $57, $02, $02, $00, $B0, $00  ; 8DF2: 09 63 57... .cW
 EQUB $FF, $63, $08, $01, $00, $00, $0A, $02  ; 8DFA: FF 63 08... .c.
 EQUB $18, $00, $01, $00, $30, $FF, $FF, $0A  ; 8E02: 18 00 01... ...
 EQUB $0C, $01, $00, $00, $0D, $02, $28, $00  ; 8E0A: 0C 01 00... ...
 EQUB $01, $00, $70, $FF, $FF, $0A, $0C, $01  ; 8E12: 01 00 70... ..p
 EQUB $00, $00, $19, $1C, $00, $01, $06, $00  ; 8E1A: 00 00 19... ...
 EQUB $70, $00, $01, $63, $06, $02, $00, $00  ; 8E22: 70 00 01... p..
 EQUB $5A, $09, $14, $00, $01, $00, $30, $00  ; 8E2A: 5A 09 14... Z..
 EQUB $FF, $63, $00, $0B, $00, $00, $46, $28  ; 8E32: FF 63 00... .c.
 EQUB $02, $00, $01, $00, $30, $00, $FF, $00  ; 8E3A: 02 00 01... ...
 EQUB $08, $06, $00, $03, $0E, $03, $6C, $00  ; 8E42: 08 06 00... ...
 EQUB $21, $00, $B0, $00, $FF, $63, $0C, $02  ; 8E4A: 21 00 B0... !..
 EQUB $00, $00, $13, $0F, $08, $00, $01, $00  ; 8E52: 00 00 13... ...
 EQUB $30, $00, $FF, $00, $0C, $03, $00, $02  ; 8E5A: 30 00 FF... 0..
 EQUB $AA, $78, $1F, $00, $01, $00, $30, $00  ; 8E62: AA 78 1F... .x.
 EQUB $01, $00, $01, $08, $00, $0A, $59, $02  ; 8E6A: 01 00 01... ...
 EQUB $4F, $00, $29, $00, $B0, $FF, $01, $FF  ; 8E72: 4F 00 29... O.)
 EQUB $00, $09, $00, $00, $19, $05, $82, $01  ; 8E7A: 00 09 00... ...
 EQUB $29, $00, $B0, $FF, $FF, $FF, $08, $02  ; 8E82: 29 00 B0... )..
 EQUB $00, $00, $22, $05, $82, $01, $29, $00  ; 8E8A: 00 00 22... .."
 EQUB $B0, $FF, $FF, $FF, $08, $03, $00, $00  ; 8E92: B0 FF FF... ...
 EQUB $0F, $63, $B0, $00, $20, $00, $70, $00  ; 8E9A: 0F 63 B0... .c.
 EQUB $FF, $63, $08, $02, $00, $00, $0D, $63  ; 8EA2: FF 63 08... .c.
 EQUB $8F, $01, $31, $00, $30, $00, $FF, $63  ; 8EAA: 8F 01 31... ..1
 EQUB $10, $02, $00, $00, $18, $05, $FF, $01  ; 8EB2: 10 02 00... ...
 EQUB $31, $00, $30, $00, $FF, $63, $10, $03  ; 8EBA: 31 00 30... 1.0
 EQUB $00, $00, $46, $03, $42, $03, $29, $00  ; 8EC2: 00 00 46... ..F
 EQUB $B0, $00, $FF, $FF, $0C, $06, $00, $00  ; 8ECA: B0 00 FF... ...
 EQUB $0C, $02, $57, $00, $14, $00, $B0, $00  ; 8ED2: 0C 02 57... ..W
 EQUB $FF, $63, $0C, $01, $00, $00, $82, $46  ; 8EDA: FF 63 0C... .c.
 EQUB $0F, $00, $01, $00, $B0, $00, $01, $00  ; 8EE2: 0F 00 01... ...
 EQUB $01, $07, $00, $05, $82, $46, $00, $00  ; 8EEA: 01 07 00... ...
 EQUB $01, $00, $B0, $00, $FF, $00, $01, $07  ; 8EF2: 01 00 B0... ...
 EQUB $00, $05, $19, $05, $82, $01, $29, $00  ; 8EFA: 00 05 19... ...
 EQUB $B0, $FF, $FF, $FF, $0E, $02, $00, $00  ; 8F02: B0 FF FF... ...
 EQUB $AA, $78, $1F, $00, $01, $00, $30, $00  ; 8F0A: AA 78 1F... .x.
 EQUB $01, $00, $01, $08, $00, $0A, $14, $03  ; 8F12: 01 00 01... ...
 EQUB $08, $00, $01, $00, $30, $00, $FF, $FF  ; 8F1A: 08 00 01... ...
 EQUB $00, $02, $00, $00, $01, $00, $00, $00  ; 8F22: 00 02 00... ...
 EQUB $00, $00, $30, $00, $00, $00, $0D, $00  ; 8F2A: 00 00 30... ..0
 EQUB $00, $00, $19, $05, $82, $01, $29, $00  ; 8F32: 00 00 19... ...
 EQUB $B0, $FF, $FF, $FF, $0F, $02, $00, $00  ; 8F3A: B0 FF FF... ...
 EQUB $0B, $04, $42, $00, $08, $00, $B0, $00  ; 8F42: 0B 04 42... ..B
 EQUB $01, $63, $08, $01, $00, $02, $96, $1C  ; 8F4A: 01 63 08... .c.
 EQUB $00, $01, $06, $00, $70, $00, $01, $63  ; 8F52: 00 01 06... ...
 EQUB $06, $02, $00, $00, $96, $1C, $00, $01  ; 8F5A: 06 02 00... ...
 EQUB $06, $00, $70, $00, $01, $63, $06, $02  ; 8F62: 06 00 70... ..p
 EQUB $00, $00, $14, $02, $28, $00, $01, $00  ; 8F6A: 00 00 14... ...
 EQUB $70, $FF, $FF, $0A, $00, $02, $00, $00  ; 8F72: 70 FF FF... p..

; ******************************************************************************
;
;       Name: L8F7A
;       Type: Variable
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.L8F7A

 EQUB $9C, $8F, $A6, $8F, $BE, $8F, $C3, $8F  ; 8F7A: 9C 8F A6... ...
 EQUB $D4, $8F, $DA, $8F, $DF, $8F, $E4, $8F  ; 8F82: D4 8F DA... ...
 EQUB $E6, $8F, $F1, $8F, $F8, $8F, $FA, $8F  ; 8F8A: E6 8F F1... ...
 EQUB $00, $90, $0A, $90, $0C, $90, $16, $90  ; 8F92: 00 90 0A... ...
 EQUB $1D, $90, $0F, $0D, $0B, $09, $07, $05  ; 8F9A: 1D 90 0F... ...
 EQUB $03, $01, $00, $FF, $03, $05, $07, $09  ; 8FA2: 03 01 00... ...
 EQUB $0A, $0C, $0E, $0E, $0E, $0C, $0C, $0A  ; 8FAA: 0A 0C 0E... ...
 EQUB $0A, $09, $09, $07, $06, $05, $04, $03  ; 8FB2: 0A 09 09... ...
 EQUB $02, $02, $01, $FF, $02, $06, $08, $00  ; 8FBA: 02 02 01... ...
 EQUB $FF, $06, $08, $0A, $0B, $0C, $0B, $0A  ; 8FC2: FF 06 08... ...
 EQUB $09, $08, $07, $06, $05, $04, $03, $02  ; 8FCA: 09 08 07... ...
 EQUB $01, $FF, $01, $03, $06, $08, $0C, $80  ; 8FD2: 01 FF 01... ...
 EQUB $01, $04, $09, $0D, $80, $01, $04, $07  ; 8FDA: 01 04 09... ...
 EQUB $09, $FF, $09, $80, $0E, $0C, $0B, $09  ; 8FE2: 09 FF 09... ...
 EQUB $07, $05, $04, $03, $02, $01, $FF, $0C  ; 8FEA: 07 05 04... ...
 EQUB $00, $00, $0C, $00, $00, $FF, $0B, $80  ; 8FF2: 00 00 0C... ...
 EQUB $0A, $0B, $0C, $0D, $0C, $80, $0C, $0A  ; 8FFA: 0A 0B 0C... ...
 EQUB $09, $07, $05, $04, $03, $02, $01, $FF  ; 9002: 09 07 05... ...
 EQUB $00, $FF, $04, $05, $06, $06, $05, $04  ; 900A: 00 FF 04... ...
 EQUB $03, $02, $01, $FF, $06, $05, $04, $03  ; 9012: 03 02 01... ...
 EQUB $02, $01, $FF, $0C, $0A, $09, $07, $05  ; 901A: 02 01 FF... ...
 EQUB $05, $04, $04, $03, $03, $02, $02, $01  ; 9022: 05 04 04... ...
 EQUB $01, $FF                                ; 902A: 01 FF       ..

; ******************************************************************************
;
;       Name: L902C
;       Type: Variable
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.L902C

 EQUB $54, $59, $5F, $78, $92, $9A, $A1, $A8  ; 902C: 54 59 5F... TY_
 EQUB $AF, $BD, $CC, $DB, $E5, $F0, $FA, $FF  ; 9034: AF BD CC... ...
 EQUB $02, $06, $0D, $14                      ; 903C: 02 06 0D... ...

; ******************************************************************************
;
;       Name: L9040
;       Type: Variable
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.L9040

 EQUB $90, $90, $90, $90, $90, $90, $90, $90  ; 9040: 90 90 90... ...
 EQUB $90, $90, $90, $90, $90, $90, $90, $90  ; 9048: 90 90 90... ...
 EQUB $91, $91, $91, $91, $01, $0A, $0F, $0C  ; 9050: 91 91 91... ...
 EQUB $8A, $01, $0A, $0F, $0B, $09, $87, $01  ; 9058: 8A 01 0A... ...
 EQUB $0E, $0C, $09, $07, $0B, $0A, $07, $05  ; 9060: 0E 0C 09... ...
 EQUB $09, $07, $05, $04, $07, $06, $04, $03  ; 9068: 09 07 05... ...
 EQUB $05, $04, $03, $02, $03, $02, $01, $80  ; 9070: 05 04 03... ...
 EQUB $01, $0E, $0D, $0B, $09, $07, $0C, $0B  ; 9078: 01 0E 0D... ...
 EQUB $09, $07, $05, $0A, $09, $07, $05, $03  ; 9080: 09 07 05... ...
 EQUB $08, $07, $05, $03, $02, $06, $05, $03  ; 9088: 08 07 05... ...
 EQUB $02, $80, $01, $0A, $0D, $0A, $09, $08  ; 9090: 02 80 01... ...
 EQUB $07, $86, $01, $08, $0B, $09, $07, $05  ; 9098: 07 86 01... ...
 EQUB $83, $01, $0A, $0D, $0C, $0B, $09, $87  ; 90A0: 83 01 0A... ...
 EQUB $01, $06, $08, $07, $05, $03, $81, $0A  ; 90A8: 01 06 08... ...
 EQUB $0D, $0C, $0B, $0A, $09, $08, $07, $06  ; 90B0: 0D 0C 0B... ...
 EQUB $05, $04, $03, $02, $81, $02, $0E, $0D  ; 90B8: 05 04 03... ...
 EQUB $0C, $0B, $0A, $09, $08, $07, $06, $05  ; 90C0: 0C 0B 0A... ...
 EQUB $04, $03, $02, $81, $01, $0E, $0D, $0C  ; 90C8: 04 03 02... ...
 EQUB $0B, $0A, $09, $08, $07, $06, $05, $04  ; 90D0: 0B 0A 09... ...
 EQUB $03, $02, $81, $01, $0E, $0C, $09, $07  ; 90D8: 03 02 81... ...
 EQUB $05, $04, $03, $02, $81, $01, $0D, $0C  ; 90E0: 05 04 03... ...
 EQUB $0A, $07, $06, $05, $04, $03, $02, $81  ; 90E8: 0A 07 06... ...
 EQUB $01, $0D, $0B, $09, $07, $05, $04, $03  ; 90F0: 01 0D 0B... ...
 EQUB $02, $81, $01, $0D, $07, $01, $80, $01  ; 90F8: 02 81 01... ...
 EQUB $00, $80, $01, $09, $02, $80,   1, $0A  ; 9100: 00 80 01... ...
 EQUB   1,   5,   2,   1, $80,   1, $0D,   1  ; 9108: 01 05 02... ...
 EQUB   7,   2,   1, $80,   1, $0F, $0D, $0B  ; 9110: 07 02 01... ...
 EQUB $89                                     ; 9118: 89          .

; ******************************************************************************
;
;       Name: L9119
;       Type: Variable
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.L9119

 EQUB $29, $2B, $34, $39, $3E, $44, $4D, $56  ; 9119: 29 2B 34... )+4

; ******************************************************************************
;
;       Name: L9121
;       Type: Variable
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.L9121

 EQUB $91, $91, $91, $91, $91, $91, $91, $91  ; 9121: 91 91 91... ...
 EQUB $00, $80, $00, $01, $02, $01, $00, $FF  ; 9129: 00 80 00... ...
 EQUB $FE, $FF, $80, $00, $02, $00, $FE, $80  ; 9131: FE FF 80... ...
 EQUB $00, $01, $00, $FF, $80, $00, $04, $00  ; 9139: 00 01 00... ...
 EQUB $04, $00, $80, $00, $02, $04, $02, $00  ; 9141: 04 00 80... ...
 EQUB $FE, $FC, $FE, $80, $00, $03, $06, $03  ; 9149: FE FC FE... ...
 EQUB $00, $FD, $FA, $FD, $80, $00, $04, $08  ; 9151: 00 FD FA... ...
 EQUB $04, $00, $FC, $F8, $FC, $80            ; 9159: 04 00 FC... ...

; ******************************************************************************
;
;       Name: L915F
;       Type: Variable
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.L915F

 EQUB $2F                                     ; 915F: 2F          /

.L9160

 EQUB $27                                     ; 9160: 27          '

.L9161

 EQUB $98                                     ; 9161: 98          .

.L9162

 EQUB $4F                                     ; 9162: 4F          O

.L9163

 EQUB $98                                     ; 9163: 98          .

.L9164

 EQUB $3D                                     ; 9164: 3D          =

.L9165

 EQUB $98                                     ; 9165: 98          .

.L9166

 EQUB $61                                     ; 9166: 61          a

.L9167

 EQUB $98                                     ; 9167: 98          .
 EQUB $3B, $8C, $91, $94, $91, $90, $91, $98  ; 9168: 3B 8C 91... ;..
 EQUB $91, $3C, $BB, $9B, $9B, $9C, $8B, $9C  ; 9170: 91 3C BB... .<.
 EQUB $DF, $9C, $3C, $04, $9E, $14, $9E, $0C  ; 9178: DF 9C 3C... ..<
 EQUB $9E, $1C, $9E, $3C, $B3, $9B, $93, $9C  ; 9180: 9E 1C 9E... ...
 EQUB $83, $9C, $A3, $9C, $9C, $91, $00, $00  ; 9188: 83 9C A3... ...
 EQUB $35, $94, $00, $00, $C4, $95, $00, $00  ; 9190: 35 94 00... 5..
 EQUB $CA, $9F, $00, $00, $FA, $B0, $F7, $05  ; 9198: CA 9F 00... ...
 EQUB $F6, $0F, $6B, $F8, $63, $F6, $02, $0E  ; 91A0: F6 0F 6B... ..k
 EQUB $F6, $07, $1E, $1E, $F6, $02, $0E, $F6  ; 91A8: F6 07 1E... ...
 EQUB $07, $1E, $1E, $F6, $02, $0E, $F6, $07  ; 91B0: 07 1E 1E... ...
 EQUB $1A, $1A, $F6, $02, $0E, $F6, $07, $1A  ; 91B8: 1A 1A F6... ...
 EQUB $1A, $F6, $02, $10, $F6, $07, $19, $19  ; 91C0: 1A F6 02... ...
 EQUB $F6, $02, $10, $F6, $07, $19, $19, $F6  ; 91C8: F6 02 10... ...
 EQUB $02, $10, $F6, $07, $19, $19, $F6, $02  ; 91D0: 02 10 F6... ...
 EQUB $10, $F6, $07, $15, $15, $F6, $02, $09  ; 91D8: 10 F6 07... ...
 EQUB $F6, $07, $1F, $1F, $F6, $02, $09, $F6  ; 91E0: F6 07 1F... ...
 EQUB $07, $19, $19, $F6, $02, $09, $F6, $07  ; 91E8: 07 19 19... ...
 EQUB $15, $15, $F6, $02, $09, $F6, $07, $15  ; 91F0: 15 15 F6... ...
 EQUB $13, $F6, $02, $0E, $F6, $07, $1E, $1E  ; 91F8: 13 F6 02... ...
 EQUB $F6, $02, $0E, $F6, $07, $1E, $1E, $F6  ; 9200: F6 02 0E... ...
 EQUB $02, $0E, $F6, $07, $1A, $1A, $F6, $02  ; 9208: 02 0E F6... ...
 EQUB $0E, $F6, $07, $1A, $1A, $F6, $02, $12  ; 9210: 0E F6 07... ...
 EQUB $F6, $07, $1E, $1E, $F6, $02, $12, $F6  ; 9218: F6 07 1E... ...
 EQUB $07, $1E, $1E, $F6, $02, $12, $F6, $07  ; 9220: 07 1E 1E... ...
 EQUB $1A, $1A, $F6, $02, $12, $F6, $07, $15  ; 9228: 1A 1A F6... ...
 EQUB $15, $F6, $02, $13, $F6, $07, $1C, $1C  ; 9230: 15 F6 02... ...
 EQUB $F6, $02, $13, $F6, $07, $1A, $1A, $F6  ; 9238: F6 02 13... ...
 EQUB $06, $67, $10, $63, $10, $10, $13, $61  ; 9240: 06 67 10... .g.
 EQUB $17, $F8, $63, $F6, $02, $10, $F6, $07  ; 9248: 17 F8 63... ..c
 EQUB $1C, $1C, $F6, $02, $09, $F6, $07, $14  ; 9250: 1C 1C F6... ...
 EQUB $15, $F6, $02, $0E, $F6, $07, $1E, $1E  ; 9258: 15 F6 02... ...
 EQUB $F6, $02, $0E, $F6, $07, $1E, $1E, $F6  ; 9260: F6 02 0E... ...
 EQUB $02, $6B, $10, $13, $62, $15, $F8, $61  ; 9268: 02 6B 10... .k.
 EQUB $15, $63, $15, $62, $0E, $60, $F8, $F6  ; 9270: 15 63 15... .c.
 EQUB $05, $63, $1E, $F8, $F6, $02, $10, $F6  ; 9278: 05 63 1E... .c.
 EQUB $07, $1A, $1A, $F6, $02, $10, $F6, $07  ; 9280: 07 1A 1A... ...
 EQUB $1A, $19, $F6, $02, $10, $F6, $07, $1A  ; 9288: 1A 19 F6... ...
 EQUB $1A, $F6, $02, $10, $F6, $07, $1A, $1A  ; 9290: 1A F6 02... ...
 EQUB $F6, $02, $09, $F6, $07, $1C, $1C, $F6  ; 9298: F6 02 09... ...
 EQUB $02, $09, $F6, $07, $19, $19, $F6, $02  ; 92A0: 02 09 F6... ...
 EQUB $09, $F6, $07, $15, $15, $F6, $02, $09  ; 92A8: 09 F6 07... ...
 EQUB $F6, $07, $19, $19, $F6, $02, $10, $F6  ; 92B0: F6 07 19... ...
 EQUB $07, $1A, $1A, $F6, $02, $10, $F6, $07  ; 92B8: 07 1A 1A... ...
 EQUB $1A, $19, $F6, $02, $10, $F6, $07, $1A  ; 92C0: 1A 19 F6... ...
 EQUB $1A, $F6, $02, $10, $F6, $07, $17, $17  ; 92C8: 1A F6 02... ...
 EQUB $F6, $06, $12, $F9, $15, $65, $17, $F8  ; 92D0: F6 06 12... ...
 EQUB $63, $10, $14, $10, $65, $09, $F8, $6B  ; 92D8: 63 10 14... c..
 EQUB $1C, $15, $1C, $63, $15, $F8, $F6, $04  ; 92E0: 1C 15 1C... ...
 EQUB $15, $F6, $02, $10, $F6, $07, $19, $19  ; 92E8: 15 F6 02... ...
 EQUB $F6, $02, $10, $F6, $07, $19, $19, $F6  ; 92F0: F6 02 10... ...
 EQUB $02, $10, $F6, $07, $19, $19, $F6, $02  ; 92F8: 02 10 F6... ...
 EQUB $10, $F6, $07, $19, $19, $F6, $02, $0E  ; 9300: 10 F6 07... ...
 EQUB $F6, $07, $1E, $1E, $F6, $02, $0E, $F6  ; 9308: F6 07 1E... ...
 EQUB $07, $1E, $1E, $F6, $02, $0E, $F6, $07  ; 9310: 07 1E 1E... ...
 EQUB $1E, $1E, $F6, $02, $0E, $F6, $07, $1E  ; 9318: 1E 1E F6... ...
 EQUB $21, $F6, $02, $10, $F6, $07, $19, $19  ; 9320: 21 F6 02... !..
 EQUB $F6, $02, $10, $F6, $07, $19, $19, $F6  ; 9328: F6 02 10... ...
 EQUB $02, $10, $F6, $07, $19, $19, $F6, $02  ; 9330: 02 10 F6... ...
 EQUB $10, $F6, $07, $19, $19, $F6, $04, $63  ; 9338: 10 F6 07... ...
 EQUB $1A, $19, $18, $F6, $06, $67, $1B, $F6  ; 9340: 1A 19 18... ...
 EQUB $04, $61, $1C, $F8, $F6, $02, $63, $09  ; 9348: 04 61 1C... .a.
 EQUB $15, $09, $0E, $F8, $F6, $04, $61, $0E  ; 9350: 15 09 0E... ...
 EQUB $F8, $63, $F6, $02, $0A, $F6, $07, $1D  ; 9358: F8 63 F6... .c.
 EQUB $1D, $F6, $02, $0A, $F6, $07, $1D, $1D  ; 9360: 1D F6 02... ...
 EQUB $F6, $02, $0F, $F6, $07, $18, $18, $F6  ; 9368: F6 02 0F... ...
 EQUB $02, $0F, $F6, $07, $18, $18, $F6, $02  ; 9370: 02 0F F6... ...
 EQUB $15, $F6, $07, $1D, $1D, $F6, $02, $11  ; 9378: 15 F6 07... ...
 EQUB $F6, $07, $1D, $1D, $F6, $02, $16, $F6  ; 9380: F6 07 1D... ...
 EQUB $07, $1D, $1D, $F6, $02, $11, $F6, $07  ; 9388: 07 1D 1D... ...
 EQUB $1D, $1D, $F6, $02, $0A, $F6, $07, $1D  ; 9390: 1D 1D F6... ...
 EQUB $1D, $F6, $02, $0A, $F6, $07, $1D, $1D  ; 9398: 1D F6 02... ...
 EQUB $F6, $02, $0F, $F6, $07, $18, $18, $F6  ; 93A0: F6 02 0F... ...
 EQUB $02, $10, $F6, $07, $19, $19, $F6, $02  ; 93A8: 02 10 F6... ...
 EQUB $0E, $F6, $07, $1A, $1A, $F6, $02, $0E  ; 93B0: 0E F6 07... ...
 EQUB $F6, $07, $16, $16, $F6, $04, $15, $15  ; 93B8: F6 07 16... ...
 EQUB $15, $15, $15, $15, $F6, $02, $10, $F6  ; 93C0: 15 15 15... ...
 EQUB $07, $19, $19, $F6, $02, $09, $F6, $07  ; 93C8: 07 19 19... ...
 EQUB $19, $19, $F6, $02, $15, $F6, $07, $19  ; 93D0: 19 19 F6... ...
 EQUB $19, $F6, $02, $09, $F6, $07, $19, $19  ; 93D8: 19 F6 02... ...
 EQUB $F6, $02, $0E, $F6, $07, $1E, $1E, $F6  ; 93E0: F6 02 0E... ...
 EQUB $02, $0E, $F6, $07, $1E, $1E, $F6, $02  ; 93E8: 02 0E F6... ...
 EQUB $0E, $F6, $07, $1E, $1E, $F6, $02, $0E  ; 93F0: 0E F6 07... ...
 EQUB $F6, $07, $1E, $21, $F6, $02, $10, $F6  ; 93F8: F6 07 1E... ...
 EQUB $07, $19, $19, $F6, $02, $09, $F6, $07  ; 9400: 07 19 19... ...
 EQUB $19, $19, $F6, $02, $15, $F6, $07, $19  ; 9408: 19 19 F6... ...
 EQUB $19, $F6, $02, $09, $F6, $07, $19, $19  ; 9410: 19 F6 02... ...
 EQUB $F6, $04, $63, $1A, $19, $18, $F6, $06  ; 9418: F6 04 63... ..c
 EQUB $67, $1B, $F6, $04, $61, $1C, $F8, $F6  ; 9420: 67 1B F6... g..
 EQUB $02, $63, $09, $15, $09, $0E, $F8, $F6  ; 9428: 02 63 09... .c.
 EQUB $04, $61, $1A, $F8, $FF, $FC, $0C, $6B  ; 9430: 04 61 1A... .a.
 EQUB $F8, $63, $F6, $08, $F7, $03, $0E, $1A  ; 9438: F8 63 F6... .c.
 EQUB $1A, $0E, $1A, $1A, $0E, $15, $15, $0E  ; 9440: 1A 0E 1A... ...
 EQUB $15, $15, $10, $15, $15, $10, $15, $15  ; 9448: 15 15 10... ...
 EQUB $10, $15, $15, $10, $10, $10, $09, $19  ; 9450: 10 15 15... ...
 EQUB $19, $09, $13, $13, $09, $13, $13, $09  ; 9458: 19 09 13... ...
 EQUB $15, $0D, $0E, $1A, $1A, $0E, $1A, $1A  ; 9460: 15 0D 0E... ...
 EQUB $0E, $15, $15, $0E, $15, $1A, $12, $1A  ; 9468: 0E 15 15... ...
 EQUB $1A, $12, $1A, $1A, $12, $15, $15, $12  ; 9470: 1A 12 1A... ...
 EQUB $0E, $0E, $13, $1A, $1A, $13, $17, $17  ; 9478: 0E 0E 13... ...
 EQUB $67, $0E, $63, $10, $10, $13, $61, $17  ; 9480: 67 0E 63... g.c
 EQUB $F8, $63, $10, $19, $19, $09, $19, $19  ; 9488: F8 63 10... .c.
 EQUB $0E, $1A, $1A, $0E, $1A, $1A, $6B, $0E  ; 9490: 0E 1A 1A... ...
 EQUB $10, $62, $12, $F8, $61, $12, $63, $12  ; 9498: 10 62 12... .b.
 EQUB $62, $15, $60, $F8, $63, $F8, $F8, $10  ; 94A0: 62 15 60... b.`
 EQUB $14, $14, $10, $14, $13, $10, $1C, $1C  ; 94A8: 14 14 10... ...
 EQUB $10, $1C, $1C, $6B, $F6, $34, $10, $12  ; 94B0: 10 1C 1C... ...
 EQUB $13, $12, $F6, $08, $63, $10, $1C, $1C  ; 94B8: 13 12 F6... ...
 EQUB $10, $1C, $13, $10, $1C, $1C, $10, $1A  ; 94C0: 10 1C 13... ...
 EQUB $1A, $19, $F9, $15, $65, $1A, $F8, $61  ; 94C8: 1A 19 F9... ...
 EQUB $1A, $1A, $1A, $F8, $1A, $F8, $65, $10  ; 94D0: 1A 1A 1A... ...
 EQUB $F8, $6B, $F6, $34, $1F, $1C, $1F, $F6  ; 94D8: F8 6B F6... .k.
 EQUB $08, $63, $1C, $F8, $21, $F7, $00, $19  ; 94E0: 08 63 1C... .c.
 EQUB $61, $2A, $2B, $63, $2D, $19, $61, $2A  ; 94E8: 61 2A 2B... a*+
 EQUB $2B, $63, $2D, $1E, $61, $2A, $2B, $63  ; 94F0: 2B 63 2D... +c-
 EQUB $2D, $2D, $1C, $15, $1E, $61, $2A, $2B  ; 94F8: 2D 2D 1C... --.
 EQUB $63, $2D, $1E, $61, $2A, $2B, $63, $2D  ; 9500: 63 2D 1E... c-.
 EQUB $1C, $61, $2A, $2B, $63, $2D, $2D, $1A  ; 9508: 1C 61 2A... .a*
 EQUB $15, $1F, $61, $2A, $2B, $63, $2D, $1F  ; 9510: 15 1F 61... ..a
 EQUB $61, $2A, $2B, $63, $2D, $1E, $61, $2A  ; 9518: 61 2A 2B... a*+
 EQUB $2B, $63, $2D, $2D, $1C, $13, $F7, $03  ; 9520: 2B 63 2D... +c-
 EQUB $63, $1A, $1C, $1E, $67, $21, $63, $1F  ; 9528: 63 1A 1C... c..
 EQUB $61, $1E, $1E, $1E, $F8, $1C, $F8, $63  ; 9530: 61 1E 1E... a..
 EQUB $1A, $F8, $F8, $63, $0A, $1A, $1A, $0A  ; 9538: 1A F8 F8... ...
 EQUB $1A, $1A, $0F, $13, $13, $0F, $13, $13  ; 9540: 1A 1A 0F... ...
 EQUB $15, $1B, $1B, $11, $15, $15, $16, $1A  ; 9548: 15 1B 1B... ...
 EQUB $1A, $11, $1A, $1A, $0A, $1A, $1A, $0A  ; 9550: 1A 11 1A... ...
 EQUB $16, $16, $0F, $1B, $1B, $10, $13, $13  ; 9558: 16 16 0F... ...
 EQUB $0E, $15, $12, $0E, $13, $13, $15, $12  ; 9560: 0E 15 12... ...
 EQUB $F8, $F8, $F8, $F8, $F7, $00, $1C, $61  ; 9568: F8 F8 F8... ...
 EQUB $2A, $2B, $63, $2D, $15, $61, $2A, $2B  ; 9570: 2A 2B 63... *+c
 EQUB $63, $2D, $21, $61, $2A, $2B, $63, $2D  ; 9578: 63 2D 21... c-!
 EQUB $15, $1C, $15, $1A, $61, $2A, $2B, $63  ; 9580: 15 1C 15... ...
 EQUB $2D, $1A, $61, $2A, $2B, $63, $2D, $1A  ; 9588: 2D 1A 61... -.a
 EQUB $61, $2A, $2B, $63, $2D, $1A, $1A, $15  ; 9590: 61 2A 2B... a*+
 EQUB $1C, $61, $2A, $2B, $63, $2D, $15, $61  ; 9598: 1C 61 2A... .a*
 EQUB $2A, $2B, $63, $2D, $21, $61, $2A, $2B  ; 95A0: 2A 2B 63... *+c
 EQUB $63, $2D, $15, $1C, $13, $F7, $03, $63  ; 95A8: 63 2D 15... c-.
 EQUB $1A, $1C, $1E, $67, $21, $61, $1F, $F8  ; 95B0: 1A 1C 1E... ...
 EQUB $61, $1E, $1E, $1E, $F8, $1C, $F8, $63  ; 95B8: 61 1E 1E... a..
 EQUB $1A, $F8, $F8, $FF, $FA, $B0, $F7, $01  ; 95C0: 1A F8 F8... ...
 EQUB $F6, $04, $63, $1A, $1E, $62, $21, $60  ; 95C8: F6 04 63... ..c
 EQUB $F8, $67, $21, $FA, $F0, $62, $21, $60  ; 95D0: F8 67 21... .g!
 EQUB $F8, $67, $21, $62, $1E, $60, $F8, $67  ; 95D8: F8 67 21... .g!
 EQUB $1E, $FA, $B0, $62, $1A, $60, $F8, $63  ; 95E0: 1E FA B0... ...
 EQUB $1A, $1E, $62, $21, $60, $F8, $67, $21  ; 95E8: 1A 1E 62... ..b
 EQUB $FA, $F0, $62, $21, $60, $F8, $67, $21  ; 95F0: FA F0 62... ..b
 EQUB $62, $1F, $60, $F8, $67, $1F, $FA, $B0  ; 95F8: 62 1F 60... b.`
 EQUB $62, $19, $60, $F8, $63, $19, $1C, $62  ; 9600: 62 19 60... b.`
 EQUB $23, $60, $F8, $67, $23, $FA, $F0, $62  ; 9608: 23 60 F8... #`.
 EQUB $23, $60, $F8, $67, $23, $62, $1F, $60  ; 9610: 23 60 F8... #`.
 EQUB $F8, $67, $1F, $FA, $B0, $62, $19, $60  ; 9618: F8 67 1F... .g.
 EQUB $F8, $63, $19, $1C, $62, $23, $60, $F8  ; 9620: F8 63 19... .c.
 EQUB $67, $23, $FA, $F0, $62, $23, $60, $F8  ; 9628: 67 23 FA... g#.
 EQUB $67, $23, $62, $1E, $60, $F8, $67, $1E  ; 9630: 67 23 62... g#b
 EQUB $FA, $B0, $62, $1A, $60, $F8, $63, $1A  ; 9638: FA B0 62... ..b
 EQUB $1E, $21, $67, $26, $FA, $F0, $62, $26  ; 9640: 1E 21 67... .!g
 EQUB $60, $F8, $67, $26, $62, $21, $60, $F8  ; 9648: 60 F8 67... `.g
 EQUB $67, $21, $FA, $B0, $62, $1A, $60, $F8  ; 9650: 67 21 FA... g!.
 EQUB $63, $1A, $1E, $21, $67, $26, $FA, $F0  ; 9658: 63 1A 1E... c..
 EQUB $62, $26, $60, $F8, $67, $26, $62, $23  ; 9660: 62 26 60... b&`
 EQUB $60, $F8, $65, $23, $61, $F9, $FA, $B0  ; 9668: 60 F8 65... `.e
 EQUB $61, $1C, $F8, $63, $1C, $1F, $61, $23  ; 9670: 61 1C F8... a..
 EQUB $F8, $6B, $23, $63, $F9, $20, $21, $6B  ; 9678: F8 6B 23... .k#
 EQUB $2A, $63, $F9, $26, $1E, $F6, $06, $67  ; 9680: 2A 63 F9... *c.
 EQUB $1E, $61, $1C, $F8, $67, $23, $61, $21  ; 9688: 1E 61 1C... .a.
 EQUB $F8, $62, $1A, $F8, $61, $1A, $63, $1A  ; 9690: F8 62 1A... .b.
 EQUB $62, $1A, $60, $F8, $FA, $F0, $F6, $04  ; 9698: 62 1A 60... b.`
 EQUB $63, $26, $62, $25, $60, $F8, $F6, $06  ; 96A0: 63 26 62... c&b
 EQUB $63, $25, $62, $23, $60, $F8, $63, $23  ; 96A8: 63 25 62... c%b
 EQUB $F8, $23, $62, $22, $60, $F8, $63, $22  ; 96B0: F8 23 62... .#b
 EQUB $62, $23, $60, $F8, $63, $23, $F8, $1C  ; 96B8: 62 23 60... b#`
 EQUB $1C, $1E, $F9, $1C, $F8, $1C, $1C, $23  ; 96C0: 1C 1E F9... ...
 EQUB $F9, $21, $F8, $26, $62, $25, $60, $F8  ; 96C8: F9 21 F8... .!.
 EQUB $63, $25, $62, $23, $60, $F8, $63, $23  ; 96D0: 63 25 62... c%b
 EQUB $F8, $23, $25, $28, $26, $26, $F8, $20  ; 96D8: F8 23 25... .#%
 EQUB $23, $23, $F9, $21, $65, $20, $61, $1E  ; 96E0: 23 23 F9... ##.
 EQUB $1A, $17, $61, $1E, $1E, $63, $1E, $1C  ; 96E8: 1A 17 61... ..a
 EQUB $FA, $B0, $F6, $06, $65, $15, $F8, $F6  ; 96F0: FA B0 F6... ...
 EQUB $07, $F7, $03, $FA, $30, $60, $2F, $2D  ; 96F8: 07 F7 03... ...
 EQUB $2F, $2D, $2F, $2D, $2F, $2D, $2F, $2D  ; 9700: 2F 2D 2F... /-/
 EQUB $2F, $2D, $2F, $2D, $2F, $2D, $2F, $2D  ; 9708: 2F 2D 2F... /-/
 EQUB $2F, $2D, $2F, $2D, $2F, $2D, $2F, $2D  ; 9710: 2F 2D 2F... /-/
 EQUB $2F, $2D, $2F, $2D, $2F, $2D, $2F, $2D  ; 9718: 2F 2D 2F... /-/
 EQUB $2F, $2D, $F6, $06, $63, $2D, $F8, $F7  ; 9720: 2F 2D F6... /-.
 EQUB $01, $FA, $B0, $62, $21, $60, $F8, $F6  ; 9728: 01 FA B0... ...
 EQUB $04, $67, $1F, $61, $21, $F8, $67, $1F  ; 9730: 04 67 1F... .g.
 EQUB $61, $21, $F8, $6B, $2A, $63, $F8, $28  ; 9738: 61 21 F8... a!.
 EQUB $21, $67, $1E, $61, $21, $F8, $67, $1E  ; 9740: 21 67 1E... !g.
 EQUB $61, $21, $F8, $6B, $28, $63, $F8, $26  ; 9748: 61 21 F8... a!.
 EQUB $21, $67, $1F, $61, $21, $F8, $67, $1F  ; 9750: 21 67 1F... !g.
 EQUB $61, $21, $F8, $6B, $2A, $63, $F8, $28  ; 9758: 61 21 F8... a!.
 EQUB $21, $26, $28, $2A, $F6, $06, $67, $2D  ; 9760: 21 26 28... !&(
 EQUB $F6, $04, $61, $2B, $F8, $61, $2A, $2A  ; 9768: F6 04 61... ..a
 EQUB $63, $2A, $28, $F6, $06, $65, $26, $61  ; 9770: 63 2A 28... c*(
 EQUB $F8, $F6, $04, $FA, $F0, $61, $26, $F8  ; 9778: F8 F6 04... ...
 EQUB $6F, $26, $63, $27, $26, $24, $22, $21  ; 9780: 6F 26 63... o&c
 EQUB $69, $1F, $61, $F8, $65, $24, $61, $F8  ; 9788: 69 1F 61... i.a
 EQUB $65, $24, $61, $1D, $65, $1F, $61, $1D  ; 9790: 65 24 61... e$a
 EQUB $F6, $06, $FA, $30, $63, $1D, $1A, $1D  ; 9798: F6 06 FA... ...
 EQUB $1B, $1A, $18, $F6, $04, $FA, $F0, $65  ; 97A0: 1B 1A 18... ...
 EQUB $26, $61, $F8, $67, $26, $63, $27, $26  ; 97A8: 26 61 F8... &a.
 EQUB $24, $22, $21, $69, $1F, $61, $F8, $65  ; 97B0: 24 22 21... $"!
 EQUB $1E, $61, $F8, $67, $1E, $65, $1F, $61  ; 97B8: 1E 61 F8... .a.
 EQUB $22, $6F, $21, $63, $F8, $FA, $B0, $F6  ; 97C0: 22 6F 21... "o!
 EQUB $06, $61, $21, $F8, $67, $1F, $61, $21  ; 97C8: 06 61 21... .a!
 EQUB $F8, $67, $1F, $61, $21, $F8, $6F, $2A  ; 97D0: F8 67 1F... .g.
 EQUB $61, $28, $F8, $21, $F8, $F6, $04, $67  ; 97D8: 61 28 F8... a(.
 EQUB $1E, $61, $21, $F8, $67, $1E, $61, $21  ; 97E0: 1E 61 21... .a!
 EQUB $F8, $6F, $28, $61, $26, $F8, $21, $F8  ; 97E8: F8 6F 28... .o(
 EQUB $F6, $06, $67, $1F, $61, $21, $F8, $67  ; 97F0: F6 06 67... ..g
 EQUB $1F, $61, $21, $F8, $6B, $2A, $F4, $3A  ; 97F8: 1F 61 21... .a!
 EQUB $63, $F9, $61, $28, $F8, $21, $F8, $F4  ; 9800: 63 F9 61... c.a
 EQUB $39, $61, $26, $F8, $28, $F8, $2A, $F8  ; 9808: 39 61 26... 9a&
 EQUB $F4, $38, $67, $2D, $61, $2B, $F8, $F4  ; 9810: F4 38 67... .8g
 EQUB $37, $2A, $2A, $2A, $F4, $33, $F8, $28  ; 9818: 37 2A 2A... 7**
 EQUB $F8, $26, $69, $F8, $F4, $3B, $FF, $65  ; 9820: F8 26 69... .&i
 EQUB $98, $65, $98, $77, $98, $DD, $98, $77  ; 9828: 98 65 98... .e.
 EQUB $98, $DD, $98, $77, $98, $C1, $9F, $77  ; 9830: 98 DD 98... ...
 EQUB $98, $BE, $9F, $00, $00, $56, $99, $56  ; 9838: 98 BE 9F... ...
 EQUB $99, $6C, $99, $FD, $99, $6C, $99, $FD  ; 9840: 99 6C 99... .l.
 EQUB $99, $6C, $99, $6C, $99, $00, $00, $81  ; 9848: 99 6C 99... .l.
 EQUB $9A, $81, $9A, $99, $9A, $1D, $9B, $99  ; 9850: 9A 81 9A... ...
 EQUB $9A, $1B, $9B, $99, $9A, $99, $9A, $00  ; 9858: 9A 1B 9B... ...
 EQUB $00, $98, $9B, $00, $00, $FA, $70, $F7  ; 9860: 00 98 9B... ...
 EQUB $05, $F6, $09, $65, $0C, $0C, $0C, $63  ; 9868: 05 F6 09... ...
 EQUB $07, $61, $07, $63, $07, $07, $FF, $FA  ; 9870: 07 61 07... .a.
 EQUB $70, $65, $0C, $0C, $63, $0C, $61, $F9  ; 9878: 70 65 0C... pe.
 EQUB $63, $07, $61, $07, $63, $07, $07, $65  ; 9880: 63 07 61... c.a
 EQUB $0C, $0C, $63, $0C, $65, $07, $07, $61  ; 9888: 0C 0C 63... ..c
 EQUB $07, $07, $65, $0C, $0C, $63, $0C, $61  ; 9890: 07 07 65... ..e
 EQUB $07, $63, $05, $65, $0C, $63, $04, $65  ; 9898: 07 63 05... .c.
 EQUB $02, $04, $63, $05, $07, $07, $07, $07  ; 98A0: 02 04 63... ..c
 EQUB $65, $00, $0C, $63, $0C, $65, $07, $07  ; 98A8: 65 00 0C... e..
 EQUB $63, $07, $65, $0C, $0C, $63, $0C, $65  ; 98B0: 63 07 65... c.e
 EQUB $0E, $0E, $61, $0E, $0E, $63, $0E, $10  ; 98B8: 0E 0E 61... ..a
 EQUB $11, $12, $61, $07, $60, $07, $07, $61  ; 98C0: 11 12 61... ..a
 EQUB $07, $65, $07, $63, $07, $65, $0C, $65  ; 98C8: 07 65 07... .e.
 EQUB $13, $63, $13, $63, $0C, $61, $13, $0C  ; 98D0: 13 63 13... .c.
 EQUB $F8, $0C, $0A, $09, $FF, $FA, $B0, $65  ; 98D8: F8 0C 0A... ...
 EQUB $07, $F7, $07, $09, $63, $0A, $61, $F9  ; 98E0: 07 F7 07... ...
 EQUB $65, $F7, $05, $13, $63, $F7, $07, $09  ; 98E8: 65 F7 05... e..
 EQUB $0A, $65, $09, $0B, $63, $0C, $65, $09  ; 98F0: 0A 65 09... .e.
 EQUB $09, $63, $09, $65, $F7, $05, $07, $F7  ; 98F8: 09 63 09... .c.
 EQUB $07, $09, $63, $0A, $61, $F9, $65, $F7  ; 9900: 07 09 63... ..c
 EQUB $05, $07, $F7, $07, $63, $09, $0A, $65  ; 9908: 05 07 F7... ...
 EQUB $09, $0B, $63, $0C, $65, $09, $0B, $63  ; 9910: 09 0B 63... ..c
 EQUB $0D, $65, $09, $0B, $63, $0C, $61, $F9  ; 9918: 0D 65 09... .e.
 EQUB $65, $F7, $06, $0E, $63, $10, $12, $65  ; 9920: 65 F7 06... e..
 EQUB $F7, $07, $0A, $0C, $63, $0D, $61, $F9  ; 9928: F7 07 0A... ...
 EQUB $65, $F7, $06, $0F, $63, $11, $13, $65  ; 9930: 65 F7 06... e..
 EQUB $F7, $07, $0B, $0D, $63, $0E, $61, $F9  ; 9938: F7 07 0B... ...
 EQUB $65, $F7, $06, $10, $63, $12, $14, $65  ; 9940: 65 F7 06... e..
 EQUB $14, $14, $63, $14, $61, $F9, $13, $13  ; 9948: 14 14 63... ..c
 EQUB $13, $13, $13, $13, $13, $FF, $61, $F6  ; 9950: 13 13 13... ...
 EQUB $05, $F7, $03, $28, $28, $28, $28, $28  ; 9958: 05 F7 03... ...
 EQUB $28, $28, $28, $28, $29, $29, $29, $29  ; 9960: 28 28 28... (((
 EQUB $29, $29, $29, $FF, $28, $28, $28, $28  ; 9968: 29 29 29... )))
 EQUB $28, $28, $28, $28, $28, $29, $29, $29  ; 9970: 28 28 28... (((
 EQUB $29, $29, $29, $29, $28, $28, $28, $28  ; 9978: 29 29 29... )))
 EQUB $28, $28, $28, $28, $F8, $29, $29, $29  ; 9980: 28 28 28... (((
 EQUB $29, $29, $29, $29, $28, $28, $28, $28  ; 9988: 29 29 29... )))
 EQUB $28, $28, $28, $28, $2B, $63, $F6, $10  ; 9990: 28 28 28... (((
 EQUB $29, $65, $28, $63, $28, $F6, $05, $61  ; 9998: 29 65 28... )e(
 EQUB $26, $26, $26, $26, $26, $26, $26, $26  ; 99A0: 26 26 26... &&&
 EQUB $29, $F6, $10, $63, $28, $24, $21, $61  ; 99A8: 29 F6 10... )..
 EQUB $1F, $F6, $05, $28, $28, $28, $28, $28  ; 99B0: 1F F6 05... ...
 EQUB $28, $28, $28, $28, $29, $29, $29, $29  ; 99B8: 28 28 28... (((
 EQUB $29, $29, $29, $28, $28, $28, $28, $28  ; 99C0: 29 29 29... )))
 EQUB $28, $28, $28, $26, $26, $26, $26, $26  ; 99C8: 28 28 28... (((
 EQUB $26, $26, $26, $29, $29, $29, $29, $29  ; 99D0: 26 26 26... &&&
 EQUB $29, $29, $29, $2B, $60, $F6, $03, $2B  ; 99D8: 29 29 29... )))
 EQUB $2B, $67, $F6, $20, $2B, $F6, $10, $63  ; 99E0: 2B 67 F6... +g.
 EQUB $2B, $F6, $05, $61, $28, $28, $28, $29  ; 99E8: 2B F6 05... +..
 EQUB $29, $29, $29, $29, $28, $28, $29, $28  ; 99F0: 29 29 29... )))
 EQUB $F8, $24, $22, $21, $FF, $61, $F8, $29  ; 99F8: F8 24 22... .$"
 EQUB $29, $F8, $29, $29, $F8, $29, $29, $F8  ; 9A00: 29 F8 29... ).)
 EQUB $29, $29, $F8, $29, $F8, $29, $F8, $28  ; 9A08: 29 29 F8... )).
 EQUB $28, $F8, $28, $28, $F8, $28, $28, $F8  ; 9A10: 28 F8 28... (.(
 EQUB $28, $28, $F8, $28, $F8, $28, $F8, $29  ; 9A18: 28 28 F8... ((.
 EQUB $29, $F8, $29, $29, $F8, $29, $29, $F8  ; 9A20: 29 F8 29... ).)
 EQUB $29, $29, $F8, $29, $F8, $29, $F8, $28  ; 9A28: 29 29 F8... )).
 EQUB $28, $F8, $28, $28, $F8, $28, $28, $F8  ; 9A30: 28 F8 28... (.(
 EQUB $28, $28, $F8, $28, $F8, $28, $F8, $26  ; 9A38: 28 28 F8... ((.
 EQUB $26, $F8, $26, $26, $F8, $26, $26, $F8  ; 9A40: 26 F8 26... &.&
 EQUB $26, $26, $F8, $26, $F8, $26, $F8, $27  ; 9A48: 26 26 F8... &&.
 EQUB $27, $F8, $27, $27, $F8, $27, $27, $F8  ; 9A50: 27 F8 27... '.'
 EQUB $27, $27, $F8, $27, $F8, $27, $F8, $28  ; 9A58: 27 27 F8... ''.
 EQUB $28, $F8, $28, $28, $F8, $28, $28, $F8  ; 9A60: 28 F8 28... (.(
 EQUB $28, $28, $F8, $28, $F8, $28, $29, $29  ; 9A68: 28 28 F8... ((.
 EQUB $29, $29, $29, $29, $29, $29, $2B, $2B  ; 9A70: 29 29 29... )))
 EQUB $2B, $2B, $2B, $2B, $2B, $2B, $FC, $00  ; 9A78: 2B 2B 2B... +++
 EQUB $FF, $FA, $70, $F7, $01, $F6, $07, $61  ; 9A80: FF FA 70... ..p
 EQUB $18, $18, $18, $18, $18, $18, $18, $18  ; 9A88: 18 18 18... ...
 EQUB $18, $18, $18, $18, $18, $18, $18, $18  ; 9A90: 18 18 18... ...
 EQUB $FF, $FA, $B0, $F6, $01, $F7, $01, $61  ; 9A98: FF FA B0... ...
 EQUB $F8, $60, $1F, $1F, $61, $24, $28, $67  ; 9AA0: F8 60 1F... .`.
 EQUB $2B, $61, $F9, $60, $26, $26, $61, $29  ; 9AA8: 2B 61 F9... +a.
 EQUB $2B, $2D, $2B, $28, $26, $28, $24, $1F  ; 9AB0: 2B 2D 2B... +-+
 EQUB $69, $1F, $61, $F9, $6D, $F8, $61, $F8  ; 9AB8: 69 1F 61... i.a
 EQUB $60, $1F, $1F, $61, $24, $28, $65, $2B  ; 9AC0: 60 1F 1F... `..
 EQUB $60, $2B, $2D, $61, $2E, $63, $2D, $2B  ; 9AC8: 60 2B 2D... `+-
 EQUB $61, $28, $2B, $2D, $6F, $26, $6D, $F9  ; 9AD0: 61 28 2B... a(+
 EQUB $61, $F8, $F8, $60, $1F, $1F, $61, $24  ; 9AD8: 61 F8 F8... a..
 EQUB $28, $67, $2B, $61, $F9, $60, $26, $26  ; 9AE0: 28 67 2B... (g+
 EQUB $61, $29, $2B, $2D, $2B, $28, $26, $28  ; 9AE8: 61 29 2B... a)+
 EQUB $24, $1F, $65, $2B, $63, $2D, $6B, $26  ; 9AF0: 24 1F 65... $.e
 EQUB $61, $F8, $60, $26, $28, $61, $29, $63  ; 9AF8: 61 F8 60... a.`
 EQUB $28, $61, $24, $29, $63, $28, $61, $24  ; 9B00: 28 61 24... (a$
 EQUB $61, $2B, $60, $2B, $2B, $65, $2B, $61  ; 9B08: 61 2B 60... a+`
 EQUB $F8, $63, $2B, $6F, $30, $67, $F9, $F8  ; 9B10: F8 63 2B... .c+
 EQUB $FA, $70, $FF, $FA, $30, $61, $F8, $F6  ; 9B18: FA 70 FF... .p.
 EQUB $00, $F7, $05, $60, $0C, $0C, $61, $0E  ; 9B20: 00 F7 05... ...
 EQUB $11, $67, $16, $6A, $F9, $60, $F8, $63  ; 9B28: 11 67 16... .g.
 EQUB $16, $64, $18, $60, $F8, $61, $15, $6B  ; 9B30: 16 64 18... .d.
 EQUB $18, $60, $F6, $05, $F7, $03, $39, $37  ; 9B38: 18 60 F6... .`.
 EQUB $34, $30, $2D, $2B, $28, $24, $21, $1F  ; 9B40: 34 30 2D... 40-
 EQUB $1C, $18, $61, $F8, $F6, $00, $F7, $05  ; 9B48: 1C 18 61... ..a
 EQUB $60, $0A, $0A, $61, $0E, $11, $67, $16  ; 9B50: 60 0A 0A... `..
 EQUB $66, $F9, $60, $F8, $63, $16, $18, $6F  ; 9B58: 66 F9 60... f.`
 EQUB $19, $6A, $F9, $60, $F8, $63, $19, $67  ; 9B60: 19 6A F9... .j.
 EQUB $1A, $15, $66, $F9, $60, $F8, $63, $15  ; 9B68: 1A 15 66... ..f
 EQUB $1A, $67, $1B, $16, $66, $F9, $60, $F8  ; 9B70: 1A 67 1B... .g.
 EQUB $63, $16, $1B, $67, $1C, $17, $66, $F9  ; 9B78: 63 16 1B... c..
 EQUB $60, $F8, $62, $17, $1C, $61, $17, $6A  ; 9B80: 60 F8 62... `.b
 EQUB $1D, $60, $F8, $61, $1C, $1D, $66, $1F  ; 9B88: 1D 60 F8... .`.
 EQUB $60, $F8, $65, $1F, $60, $1C, $1A, $FF  ; 9B90: 60 F8 65... `.e
 EQUB $F6, $11, $65, $04, $04, $04, $63, $04  ; 9B98: F6 11 65... ..e
 EQUB $61, $04, $63, $04, $04, $65, $04, $04  ; 9BA0: 61 04 63... a.c
 EQUB $04, $63, $04, $61, $04, $63, $04, $61  ; 9BA8: 04 63 04... .c.
 EQUB $04, $04, $FF, $58, $9E, $58, $9E, $99  ; 9BB0: 04 04 FF... ...
 EQUB $9E, $B2, $9F, $C4, $9F, $E3, $9C, $EA  ; 9BB8: 9E B2 9F... ...
 EQUB $9C, $EA, $9C, $EA, $9C, $EA, $9C, $EA  ; 9BC0: 9C EA 9C... ...
 EQUB $9C, $FC, $9C, $FC, $9C, $EA, $9C, $EA  ; 9BC8: 9C FC 9C... ...
 EQUB $9C, $EA, $9C, $EA, $9C, $EA, $9C, $EA  ; 9BD0: 9C EA 9C... ...
 EQUB $9C, $FC, $9C, $FC, $9C, $EA, $9C, $EA  ; 9BD8: 9C FC 9C... ...
 EQUB $9C, $FC, $9C, $FC, $9C, $EA, $9C, $EA  ; 9BE0: 9C FC 9C... ...
 EQUB $9C, $F3, $9C, $FC, $9C, $EA, $9C, $EA  ; 9BE8: 9C F3 9C... ...
 EQUB $9C, $FC, $9C, $FC, $9C, $EA, $9C, $EA  ; 9BF0: 9C FC 9C... ...
 EQUB $9C, $FC, $9C, $FC, $9C, $EA, $9C, $EA  ; 9BF8: 9C FC 9C... ...
 EQUB $9C, $FC, $9C, $FC, $9C, $EA, $9C, $EA  ; 9C00: 9C FC 9C... ...
 EQUB $9C, $F3, $9C, $FC, $9C, $EA, $9C, $EA  ; 9C08: 9C F3 9C... ...
 EQUB $9C, $FC, $9C, $FC, $9C, $EA, $9C, $EA  ; 9C10: 9C FC 9C... ...
 EQUB $9C, $FC, $9C, $FC, $9C, $E3, $9C, $EA  ; 9C18: 9C FC 9C... ...
 EQUB $9C, $EA, $9C, $EA, $9C, $EA, $9C, $EA  ; 9C20: 9C EA 9C... ...
 EQUB $9C, $FC, $9C, $FC, $9C, $C7, $9F, $EA  ; 9C28: 9C FC 9C... ...
 EQUB $9C, $EA, $9C, $EA, $9C, $EA, $9C, $EA  ; 9C30: 9C EA 9C... ...
 EQUB $9C, $EA, $9C, $FC, $9C, $FC, $9C, $EA  ; 9C38: 9C EA 9C... ...
 EQUB $9C, $EA, $9C, $FC, $9C, $FC, $9C, $EA  ; 9C40: 9C EA 9C... ...
 EQUB $9C, $EA, $9C, $F3, $9C, $FC, $9C, $EA  ; 9C48: 9C EA 9C... ...
 EQUB $9C, $EA, $9C, $FC, $9C, $FC, $9C, $EA  ; 9C50: 9C EA 9C... ...
 EQUB $9C, $EA, $9C, $FC, $9C, $FC, $9C, $EA  ; 9C58: 9C EA 9C... ...
 EQUB $9C, $EA, $9C, $FC, $9C, $FC, $9C, $EA  ; 9C60: 9C EA 9C... ...
 EQUB $9C, $EA, $9C, $F3, $9C, $FC, $9C, $EA  ; 9C68: 9C EA 9C... ...
 EQUB $9C, $EA, $9C, $FC, $9C, $FC, $9C, $EA  ; 9C70: 9C EA 9C... ...
 EQUB $9C, $EA, $9C, $FC, $9C, $FC, $9C, $C4  ; 9C78: 9C EA 9C... ...
 EQUB $9F, $00, $00, $AD, $9E, $AD, $9E, $0B  ; 9C80: 9F 00 00... ...
 EQUB $9F, $B5, $9F, $05, $9D, $16, $9D, $16  ; 9C88: 9F B5 9F... ...
 EQUB $9D, $00, $00, $19, $9F, $19, $9F, $57  ; 9C90: 9D 00 00... ...
 EQUB $9F, $B8, $9F, $2E, $9D, $AB, $9D, $B1  ; 9C98: 9F B8 9F... ...
 EQUB $9D, $00, $00, $6B, $9F, $78, $9F, $78  ; 9CA0: 9D 00 00... ...
 EQUB $9F, $78, $9F, $78, $9F, $78, $9F, $78  ; 9CA8: 9F 78 9F... .x.
 EQUB $9F, $6B, $9F, $78, $9F, $78, $9F, $78  ; 9CB0: 9F 6B 9F... .k.
 EQUB $9F, $78, $9F, $78, $9F, $78, $9F, $6B  ; 9CB8: 9F 78 9F... .x.
 EQUB $9F, $78, $9F, $78, $9F, $78, $9F, $78  ; 9CC0: 9F 78 9F... .x.
 EQUB $9F, $78, $9F, $78, $9F, $6B, $9F, $78  ; 9CC8: 9F 78 9F... .x.
 EQUB $9F, $78, $9F, $78, $9F, $78, $9F, $78  ; 9CD0: 9F 78 9F... .x.
 EQUB $9F, $78, $9F, $84, $9F, $BB, $9F, $F8  ; 9CD8: 9F 78 9F... .x.
 EQUB $9D, $00, $00, $FA, $B0, $F7, $05, $F6  ; 9CE0: 9D 00 00... ...
 EQUB $0B, $61, $0C, $0C, $0C, $0C, $0C, $0C  ; 9CE8: 0B 61 0C... .a.
 EQUB $0C, $07, $FF, $05, $05, $05, $05, $05  ; 9CF0: 0C 07 FF... ...
 EQUB $05, $05, $07, $FF, $07, $07, $07, $07  ; 9CF8: 05 05 07... ...
 EQUB $07, $07, $07, $13, $FF, $F6, $FF, $F7  ; 9D00: 07 07 07... ...
 EQUB $01, $7F, $24, $22, $24, $6F, $22, $1F  ; 9D08: 01 7F 24... ..$
 EQUB $7F, $24, $22, $24, $1F, $FF, $77, $1C  ; 9D10: 7F 24 22... .$"
 EQUB $67, $1F, $77, $22, $67, $1D, $6F, $1C  ; 9D18: 67 1F 77... g.w
 EQUB $24, $21, $23, $7F, $1C, $6F, $1A, $1D  ; 9D20: 24 21 23... $!#
 EQUB $7F, $1C, $6F, $1A, $26, $FF, $FA, $B0  ; 9D28: 7F 1C 6F... ..o
 EQUB $F7, $05, $F6, $0C, $FC, $F4, $63, $1C  ; 9D30: F7 05 F6... ...
 EQUB $1C, $1C, $61, $1C, $13, $63, $1C, $1C  ; 9D38: 1C 1C 61... ..a
 EQUB $1C, $61, $1C, $1F, $63, $1B, $1B, $1B  ; 9D40: 1C 61 1C... .a.
 EQUB $61, $1B, $13, $63, $1B, $1B, $1B, $61  ; 9D48: 61 1B 13... a..
 EQUB $1B, $1F, $63, $1C, $1C, $1C, $61, $1C  ; 9D50: 1B 1F 63... ..c
 EQUB $13, $63, $1C, $1C, $1C, $61, $1C, $1F  ; 9D58: 13 63 1C... .c.
 EQUB $63, $16, $16, $16, $61, $16, $15, $63  ; 9D60: 63 16 16... c..
 EQUB $16, $16, $16, $61, $16, $13, $63, $FC  ; 9D68: 16 16 16... ...
 EQUB $00, $F7, $01, $1C, $1C, $1C, $61, $1C  ; 9D70: 00 F7 01... ...
 EQUB $13, $63, $1C, $1C, $1C, $61, $1C, $1F  ; 9D78: 13 63 1C... .c.
 EQUB $63, $1B, $1B, $1B, $61, $1B, $13, $63  ; 9D80: 63 1B 1B... c..
 EQUB $1B, $1B, $1B, $61, $1B, $1F, $63, $1C  ; 9D88: 1B 1B 1B... ...
 EQUB $1C, $1C, $61, $1C, $13, $63, $1C, $1C  ; 9D90: 1C 1C 61... ..a
 EQUB $1C, $61, $1C, $1F, $63, $16, $16, $16  ; 9D98: 1C 61 1C... .a.
 EQUB $61, $16, $15, $63, $16, $16, $16, $61  ; 9DA0: 61 16 15... a..
 EQUB $16, $13, $FF, $FA, $B0, $F7, $05, $FC  ; 9DA8: 16 13 FF... ...
 EQUB $F4, $F6, $0A, $63, $24, $24, $61, $22  ; 9DB0: F4 F6 0A... ...
 EQUB $65, $21, $63, $24, $24, $61, $22, $63  ; 9DB8: 65 21 63... e!c
 EQUB $1C, $22, $22, $21, $22, $24, $22, $21  ; 9DC0: 1C 22 22... .""
 EQUB $63, $22, $61, $16, $63, $24, $24, $61  ; 9DC8: 63 22 61... c"a
 EQUB $22, $65, $21, $63, $24, $24, $61, $26  ; 9DD0: 22 65 21... "e!
 EQUB $63, $27, $F7, $01, $29, $29, $27, $29  ; 9DD8: 63 27 F7... c'.
 EQUB $F6, $08, $71, $2B, $77, $2B, $67, $2D  ; 9DE0: F6 08 71... ..q
 EQUB $77, $2E, $67, $2D, $77, $28, $67, $2B  ; 9DE8: 77 2E 67... w.g
 EQUB $6F, $2E, $F6, $08, $22, $FA, $F0, $FF  ; 9DF0: 6F 2E F6... o..
 EQUB $61, $F6, $10, $08, $02, $F6, $0E, $07  ; 9DF8: 61 F6 10... a..
 EQUB $F6, $10, $02, $FF, $58, $9E, $58, $9E  ; 9E00: F6 10 02... ...
 EQUB $99, $9E, $00, $00, $AD, $9E, $AD, $9E  ; 9E08: 99 9E 00... ...
 EQUB $0B, $9F, $00, $00, $19, $9F, $19, $9F  ; 9E10: 0B 9F 00... ...
 EQUB $57, $9F, $00, $00, $6B, $9F, $78, $9F  ; 9E18: 57 9F 00... W..
 EQUB $78, $9F, $78, $9F, $78, $9F, $78, $9F  ; 9E20: 78 9F 78... x.x
 EQUB $78, $9F, $6B, $9F, $78, $9F, $78, $9F  ; 9E28: 78 9F 6B... x.k
 EQUB $78, $9F, $78, $9F, $78, $9F, $78, $9F  ; 9E30: 78 9F 78... x.x
 EQUB $6B, $9F, $78, $9F, $78, $9F, $78, $9F  ; 9E38: 6B 9F 78... k.x
 EQUB $78, $9F, $78, $9F, $78, $9F, $6B, $9F  ; 9E40: 78 9F 78... x.x
 EQUB $78, $9F, $78, $9F, $78, $9F, $78, $9F  ; 9E48: 78 9F 78... x.x
 EQUB $78, $9F, $78, $9F, $84, $9F, $00, $00  ; 9E50: 78 9F 78... x.x
 EQUB $FA, $B0, $F7, $05, $F6, $0F, $63, $F8  ; 9E58: FA B0 F7... ...
 EQUB $F6, $08, $67, $0D, $F6, $02, $63, $0D  ; 9E60: F6 08 67... ..g
 EQUB $65, $11, $61, $11, $67, $11, $65, $0F  ; 9E68: 65 11 61... e.a
 EQUB $61, $0F, $67, $0F, $65, $11, $61, $11  ; 9E70: 61 0F 67... a.g
 EQUB $63, $11, $61, $11, $11, $F6, $0D, $63  ; 9E78: 63 11 61... c.a
 EQUB $0D, $F6, $02, $67, $0D, $63, $0D, $65  ; 9E80: 0D F6 02... ...
 EQUB $11, $61, $11, $67, $11, $65, $0F, $61  ; 9E88: 11 61 11... .a.
 EQUB $0F, $67, $0F, $63, $11, $13, $14, $16  ; 9E90: 0F 67 0F... .g.
 EQUB $FF, $65, $0C, $69, $0C, $65, $0C, $69  ; 9E98: FF 65 0C... .e.
 EQUB $0C, $65, $0C, $69, $0C, $63, $0C, $0C  ; 9EA0: 0C 65 0C... .e.
 EQUB $0C, $0C, $6F, $0C, $FF, $F7, $05, $FC  ; 9EA8: 0C 0C 6F... ..o
 EQUB $0C, $F6, $00, $63, $F8, $F6, $28, $6A  ; 9EB0: 0C F6 00... ...
 EQUB $1B, $60, $F8, $F6, $08, $61, $1B, $F6  ; 9EB8: 1B 60 F8... .`.
 EQUB $10, $63, $18, $F6, $48, $68, $18, $60  ; 9EC0: 10 63 18... .c.
 EQUB $F8, $F6, $10, $63, $1B, $1B, $F6, $08  ; 9EC8: F8 F6 10... ...
 EQUB $61, $1B, $F6, $10, $63, $1B, $61, $1B  ; 9ED0: 61 1B F6... a..
 EQUB $F9, $F6, $08, $61, $1D, $F6, $60, $6B  ; 9ED8: F9 F6 08... ...
 EQUB $1D, $63, $F8, $F6, $28, $6A, $1B, $60  ; 9EE0: 1D 63 F8... .c.
 EQUB $F8, $F6, $08, $61, $1B, $F6, $10, $63  ; 9EE8: F8 F6 08... ...
 EQUB $18, $F6, $48, $68, $18, $60, $F8, $F6  ; 9EF0: 18 F6 48... ..H
 EQUB $10, $63, $1B, $1B, $F6, $08, $61, $1B  ; 9EF8: 10 63 1B... .c.
 EQUB $F6, $10, $63, $1B, $F6, $80, $61, $1D  ; 9F00: F6 10 63... ..c
 EQUB $6F, $F9, $FF, $6F, $F6, $80, $13, $16  ; 9F08: 6F F9 FF... o..
 EQUB $13, $10, $63, $F9, $6B, $F8, $FC, $00  ; 9F10: 13 10 63... ..c
 EQUB $FF, $FA, $B0, $F7, $05, $F6, $0F, $63  ; 9F18: FF FA B0... ...
 EQUB $F8, $F6, $13, $6A, $1D, $60, $F8, $61  ; 9F20: F8 F6 13... ...
 EQUB $1D, $63, $1D, $68, $1D, $60, $F8, $63  ; 9F28: 1D 63 1D... .c.
 EQUB $1F, $1F, $61, $1F, $63, $1F, $61, $1F  ; 9F30: 1F 1F 61... ..a
 EQUB $F9, $61, $20, $6B, $20, $63, $F8, $6A  ; 9F38: F9 61 20... .a
 EQUB $1D, $60, $F8, $61, $1D, $63, $1D, $68  ; 9F40: 1D 60 F8... .`.
 EQUB $1D, $60, $F8, $63, $1F, $1F, $61, $1F  ; 9F48: 1D 60 F8... .`.
 EQUB $63, $1F, $61, $20, $6F, $F9, $FF, $FA  ; 9F50: 63 1F 61... c.a
 EQUB $70, $6F, $F6, $05, $18, $F6, $04, $1C  ; 9F58: 70 6F F6... po.
 EQUB $F6, $06, $1F, $F6, $01, $22, $63, $F9  ; 9F60: F6 06 1F... ...
 EQUB $6B, $F8, $FF, $F6, $0F, $63, $F8, $67  ; 9F68: 6B F8 FF... k..
 EQUB $F6, $02, $07, $F6, $11, $63, $04, $FF  ; 9F70: F6 02 07... ...
 EQUB $61, $F6, $10, $08, $02, $F6, $12, $07  ; 9F78: 61 F6 10... a..
 EQUB $F6, $10, $02, $FF, $63, $F6, $11, $02  ; 9F80: F6 10 02... ...
 EQUB $F6, $12, $02, $F6, $11, $02, $F6, $12  ; 9F88: F6 12 02... ...
 EQUB $02, $F6, $11, $02, $F6, $12, $02, $F6  ; 9F90: 02 F6 11... ...
 EQUB $11, $02, $F6, $12, $02, $F6, $11, $02  ; 9F98: 11 02 F6... ...
 EQUB $F6, $12, $02, $F6, $11, $02, $F6, $12  ; 9FA0: F6 12 02... ...
 EQUB $02, $F6, $12, $02, $02, $02, $02, $6F  ; 9FA8: 02 F6 12... ...
 EQUB $04, $FF, $F5, $BB, $9B, $F5, $8B, $9C  ; 9FB0: 04 FF F5... ...
 EQUB $F5, $9B, $9C, $F5, $DF, $9C, $FB, $00  ; 9FB8: F5 9B 9C... ...
 EQUB $FF, $FB, $01, $FF, $FB, $03, $FF, $FB  ; 9FC0: FF FB 01... ...
 EQUB $04, $FF, $7F, $F6, $0F, $F8, $FF, $EA  ; 9FC8: 04 FF 7F... ...

; ******************************************************************************
;
;       Name: subm_9FD0
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.subm_9FD0

 LDA #$68
 STA tileSprite8
 LDA #0
 STA attrSprite8
 LDA #$CB
 STA xSprite8
 LDA L04A9
 AND #4
 BEQ C9FE8
 LDA #$10

.C9FE8

 CLC

IF _NTSC

 ADC #$5A

ELIF _PAL

 ADC #$60

ENDIF

 STA ySprite8
 LDA #$69
 STA tileSprite9
 LDA #0
 STA attrSprite9
 LDA #$D3
 STA xSprite9
 LDA L04A9
 AND #4
 BEQ CA006
 LDA #$10

.CA006

 CLC

IF _NTSC

 ADC #$5A

ELIF _PAL

 ADC #$60

ENDIF

 STA ySprite9
 LDA #$6A
 STA tileSprite10
 LDA #0
 STA attrSprite10
 LDA #$DB
 STA xSprite10
 LDA L04A9
 AND #4
 BEQ CA024
 LDA #$10

.CA024

 CLC

IF _NTSC

 ADC #$5A

ELIF _PAL

 ADC #$60

ENDIF

 STA ySprite10
 RTS

; ******************************************************************************
;
;       Name: subm_A02B
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.subm_A02B

 LDA #$6B
 STA tileSprite11
 LDA #2
 STA attrSprite11
 LDA #$C3
 STA xSprite11
 LDA L04A9
 AND #4
 BEQ CA043
 LDA #$10

.CA043

 CLC

IF _NTSC

 ADC #$62

ELIF _PAL

 ADC #$68

ENDIF

 STA ySprite11
 RTS

; ******************************************************************************
;
;       Name: subm_A04A
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.subm_A04A

 LDA #$6C
 STA tileSprite12
 LDA #2
 STA attrSprite12
 LDA #$E3
 STA xSprite12
 LDA L04A9
 AND #4
 BEQ CA062
 LDA #$10

.CA062

 CLC

IF _NTSC

 ADC #$62

ELIF _PAL

 ADC #$68

ENDIF

 STA ySprite12
 RTS

; ******************************************************************************
;
;       Name: subm_A069
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.subm_A069

 LDA #3
 STA K
 LDA #2
 STA K+1
 LDA #$6F
 STA K+2
 LDA #$0F
 STA K+3
 LDX #$0B
 LDY #$31
 LDA #2
 JMP CA0FA

; ******************************************************************************
;
;       Name: subm_A082
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.subm_A082

 LDX #6
 LDY #8
 STX K
 STY K+1
 LDA tileNumber
 STA pictureTile
 CLC
 ADC #$30
 STA tileNumber
 LDX pictureTile
 STX K+2
 JSR subm_B2FB_b3
 LDA #5
 STA K
 LDA #7
 STA K+1
 LDA #$45
 STA K+2
 LDA #$14
 STA K+3
 LDX #4
 LDY #0
 JSR subm_A0F8_b6
 LDA FIST
 CMP #$28
 BCC CA0BD
 JSR subm_9FD0

.CA0BD

 LDA CASH
 BNE CA0DA
 LDA CASH+1
 CMP #$99
 BCS CA0DA
 CMP #0
 BNE CA0DD
 LDA CASH+2
 CMP #$4F
 BCS CA0DD
 CMP #$28
 BCC CA0E3
 BCS CA0E0

.CA0DA

 JSR subm_A069

.CA0DD

 JSR subm_A02B

.CA0E0

 JSR subm_A04A

.CA0E3

 LDX XC
 DEX
 STX XC
 LDX YC
 DEX
 STX YC
 LDA #7
 STA K
 LDA #$0A
 STA K+1
 JMP subm_B248_b3

; ******************************************************************************
;
;       Name: subm_A0F8
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.subm_A0F8

 LDA #1

.CA0FA

 STA S
 LDA XC
 ASL A
 ASL A
 ASL A
 ADC #0
 STA SC
 TXA
 ADC SC
 STA SC
 LDA YC
 ASL A
 ASL A
 ASL A

IF _NTSC

 ADC #6

ELIF _PAL

 ADC #$C

ENDIF

 STA SC+1
 TYA
 ADC SC+1
 STA SC+1
 LDA K+3
 ASL A
 ASL A
 TAY
 LDA K+2
 LDX K+1
 STX T

.CA123

 SETUP_PPU_FOR_ICON_BAR ; If the PPU has started drawing the icon bar, configure
                        ; the PPU to use nametable 0 and pattern table 0

 LDX SC
 STX SC2
 LDX K

.CA136

 LDA K+2
 STA tileSprite0,Y
 LDA S
 STA attrSprite0,Y
 LDA SC2
 STA xSprite0,Y
 CLC
 ADC #8
 STA SC2
 LDA SC+1
 STA ySprite0,Y
 TYA
 CLC
 ADC #4
 BCS CA165
 TAY
 INC K+2
 DEX
 BNE CA136
 LDA SC+1
 ADC #8
 STA SC+1
 DEC T
 BNE CA123

.CA165

 RTS

; ******************************************************************************
;
;       Name: subm_A166
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.subm_A166

 TYA
 PHA
 TXA
 PHA
 JSR KeepPPUTablesAt0
 LDA nmiTimer
 PHA
 LDA nmiTimerLo
 PHA
 LDA nmiTimerHi
 PHA
 JSR subm_D8C5
 LDA L045F
 PHA
 LDA L0464
 PHA
 LDA #$FF
 STA L045F
 LDA #3
 JSR subm_AC1D_b3

.CA18B

 LDY #4
 JSR DELAY
 JSR SetKeyLogger_b6
 TXA
 CMP #$50
 BNE CA1B1
 PLA
 JSR subm_AC1D_b3
 PLA
 STA L045F
 JSR KeepPPUTablesAt0
 PLA
 STA nmiTimerHi
 PLA
 STA nmiTimerLo
 PLA
 STA nmiTimer
 PLA
 TAX
 PLA
 TAY
 RTS

.CA1B1

 CMP #$34
 BNE CA1C0
 LDA L03EC
 EOR #$FF
 STA L03EC
 JMP CA21D

.CA1C0

 CMP #$33
 BNE CA1E1
 LDA L03ED
 EOR #$FF
 STA L03ED
 BPL CA1D4
 JSR ResetSound_b6
 JMP CA21D

.CA1D4

 LDA L045E
 BEQ CA1DE
 AND #$7F
 JSR subm_8021_b6

.CA1DE

 JMP CA21D

.CA1E1

 CMP #$3C
 BNE CA1ED
 PLA
 PLA
 STA L045F
 JMP DEATH2_b0

.CA1ED

 CMP #$35
 BNE CA1FC
 LDA scanController2
 EOR #1
 STA scanController2
 JMP CA21D

.CA1FC

 CMP #$31
 BNE CA20B
 LDA L03EB
 EOR #$FF
 STA L03EB
 JMP CA21D

.CA20B

 CMP #$32
 BNE CA21A
 LDA L03EA
 EOR #$FF
 STA L03EA
 JMP CA21D

.CA21A

 JMP CA18B

.CA21D

 JSR subm_AC5C_b3
 JMP CA18B

; ******************************************************************************
;
;       Name: DILX
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.DILX

 LSR A
 LSR A

 LSR A
 CMP #$1F
 BCC CA22C
 LDA #$1E

.CA22C

 LDY #0
 CMP K
 BCC CA274
 CMP K+1
 BCS CA274
 STA Q

.CA238

 LSR A
 LSR A
 LSR A
 BEQ CA246
 TAX
 LDA #$EC

.loop_CA240

 STA (SC),Y
 INY
 DEX
 BNE loop_CA240

.CA246

 LDA Q
 AND #7
 CLC
 ADC #$ED
 STA (SC),Y
 INY
 LDA #$55

.loop_CA252

 CPY #4
 BEQ CA25B
 STA (SC),Y
 INY
 BNE loop_CA252

.CA25B

 LDA SC
 CLC
 ADC #$20
 STA SC
 BCC CA266
 INC SC+1

.CA266

 SETUP_PPU_FOR_ICON_BAR ; If the PPU has started drawing the icon bar, configure
                        ; the PPU to use nametable 0 and pattern table 0

 RTS

.CA274

 STA Q
 LDA MCNT
 AND #8
 BNE CA285
 LDA Q
 JMP CA238

; ******************************************************************************
;
;       Name: subm_A281
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.subm_A281

 LDY #0
 BEQ CA29F

.CA285

 LDA Q
 LSR A
 LSR A
 LSR A
 BEQ CA295
 TAX
 LDA #$E3

.loop_CA28F

 STA (SC),Y
 INY
 DEX
 BNE loop_CA28F

.CA295

 LDA Q
 AND #7
 CLC
 ADC #$E4
 STA (SC),Y
 INY

.CA29F

 LDA #$55

.loop_CA2A1

 CPY #4
 BEQ CA2AA
 STA (SC),Y
 INY
 BNE loop_CA2A1

.CA2AA

 LDA SC
 CLC
 ADC #$20
 STA SC
 BCC CA2B5
 INC SC+1

.CA2B5

 SETUP_PPU_FOR_ICON_BAR ; If the PPU has started drawing the icon bar, configure
                        ; the PPU to use nametable 0 and pattern table 0

 RTS

; ******************************************************************************
;
;       Name: DIALS
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.DIALS

 LDA drawingPhase
 BNE CA331
 LDA #$72
 STA SC+1
 LDA #$E2
 STA SC
 LDA #0
 STA K
 LDA #$FF
 STA K+1
 LDA QQ14
 JSR DILX+2
 LDA #8
 STA K
 LDA #$FF
 STA K+1
 LDA FSH
 JSR DILX
 LDA ASH
 JSR DILX
 LDA ENERGY
 JSR DILX
 LDA #0
 STA K
 LDA #$18
 STA K+1
 LDA CABTMP
 JSR DILX
 LDA GNTMP
 JSR DILX
 LDA #$73
 STA SC+1
 LDA #$7C
 STA SC
 LDA #0
 STA K
 LDA #$FF
 STA K+1
 LDA DELTA
 LSR A
 ADC DELTA
 JSR DILX+2
 LDA #8
 STA K
 LDA #$FF
 STA K+1
 LDA ALTIT
 JSR DILX

.CA331

IF _NTSC

 LDA #$BA

ELIF _PAL

 LDA #$C0

ENDIF

 STA ySprite10
 LDA #$CE
 STA xSprite10
 JSR GetStatusCondition
 LDA LA386,X
 STA attrSprite10
 LDA LA38A,X
 STA tileSprite10
 LDA QQ12
 BNE CA368
 LDA MSTG
 BPL CA371
 LDA MSAR
 BEQ CA368
 LDX NOMSL
 LDY #$6D
 LDA MCNT
 AND #8
 BNE CA36E
 LDY #$6C
 JSR subm_A38E

.CA368

 LDA #$F0
 STA ySprite9
 RTS

.CA36E

 JSR subm_A38E

.CA371

 LDA #$F8
 STA tileSprite9
 LDA #1
 STA attrSprite9
 LDA #$7E
 STA xSprite9

IF _NTSC

 LDA #$53

ELIF _PAL

 LDA #$59

ENDIF

 STA ySprite9
 RTS

; ******************************************************************************
;
;       Name: LA386
;       Type: Variable
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.LA386

 EQUB $21, $20, $22, $22                      ; A386: 21 20 22... ! "

; ******************************************************************************
;
;       Name: LA38A
;       Type: Variable
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.LA38A

 EQUB $F9, $FA, $FA, $F9                      ; A38A: F9 FA FA... ...

; ******************************************************************************
;
;       Name: subm_A38E
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.subm_A38E

 TYA
 PHA
 LDY LA39A,X
 PLA
 STA nameBuffer0+704,Y
 LDY #0
 RTS

; ******************************************************************************
;
;       Name: LA39A
;       Type: Variable
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.LA39A

 EQUB $00, $5F, $5E, $3F, $3E                 ; A39A: 00 5F 5E... ._^

; ******************************************************************************
;
;       Name: subm_A39F
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.subm_A39F

 LDA #0

; ******************************************************************************
;
;       Name: subm_A3A1
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.subm_A3A1

 STA V
 STX V+1

.CA3A5

 LDA LA3F5+3,Y
 AND #$FC
 TAX
 LDA LA3F5+3,Y
 AND #3
 STA T
 LDA LA3F5,Y
 AND #$C0
 ORA T
 STA attrSprite0,X
 LDA LA3F5,Y
 AND #$3F
 CLC
 ADC #$8C
 ADC V
 STA tileSprite0,X
 LDA LA3F5+1,Y
 STA xSprite0,X
 LDA LA3F5+2,Y
 STA ySprite0,X
 INY
 INY
 INY
 INY
 DEC V+1
 BNE CA3A5
 RTS

; ******************************************************************************
;
;       Name: subm_A3DE
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.subm_A3DE

 LDA #0
 CPX #$97
 BEQ CA3F2
 CPX #$8F
 BEQ CA3EF
 CPX #$32
 BNE CA3EE
 LDA #8

.CA3EE

 RTS

.CA3EF

 LDA #4
 RTS

.CA3F2

 LDA #$0C
 RTS

; ******************************************************************************
;
;       Name: LA3F5
;       Type: Variable
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.LA3F5

IF _NTSC

 EQUB $1F, $55, $B6, $14, $20, $9C, $9C, $18  ; A3F5: 1F 55 B6... .U.
 EQUB $21, $9C, $A4, $1C, $07, $44, $A1, $20  ; A3FD: 21 9C A4... !..
 EQUB $0A, $AB, $AC, $24, $09, $14, $C6, $28  ; A405: 0A AB AC... ...
 EQUB $09, $7C, $AA, $2C, $49, $74, $C6, $30  ; A40D: 09 7C AA... .|.
 EQUB $49, $DC, $AA, $34, $87, $44, $CE, $74  ; A415: 49 DC AA... I..
 EQUB $15, $10, $C6, $28, $15, $79, $AA, $2C  ; A41D: 15 10 C6... ...
 EQUB $55, $76, $C6, $30, $55, $DE, $AA, $34  ; A425: 55 76 C6... Uv.
 EQUB $1E, $A7, $B9, $3D, $5E, $AF, $B9, $41  ; A42D: 1E A7 B9... ...
 EQUB $1A, $4F, $C4, $AC, $1B, $4F, $C4, $B1  ; A435: 1A 4F C4... .O.
 EQUB $1A, $38, $C4, $44, $1B, $38, $C4, $49  ; A43D: 1A 38 C4... .8.
 EQUB $00, $1D, $BB, $4D, $01, $D0, $B0, $51  ; A445: 00 1D BB... ...
 EQUB $40, $6C, $BB, $55, $41, $88, $B0, $59  ; A44D: 40 6C BB... @l.
 EQUB $00, $16, $C0, $5D, $01, $D6, $AF, $61  ; A455: 00 16 C0... ...
 EQUB $40, $73, $C0, $65, $41, $82, $AF, $69  ; A45D: 40 73 C0... @s.
 EQUB $17, $40, $CE, $6C, $18, $48, $CE, $70  ; A465: 17 40 CE... .@.
 EQUB $19, $44, $CE, $3A, $02, $99, $B8, $78  ; A46D: 19 44 CE... .D.
 EQUB $42, $BC, $B8, $7C, $1C, $4F, $B2, $80  ; A475: 42 BC B8... B..
 EQUB $03, $34, $AC, $84, $04, $3C, $AC, $88  ; A47D: 03 34 AC... .4.
 EQUB $05, $34, $B4, $8C, $06, $3C, $B4, $90  ; A485: 05 34 B4... .4.
 EQUB $44, $B2, $9C, $94, $43, $BA, $9C, $98  ; A48D: 44 B2 9C... D..
 EQUB $46, $B2, $A4, $9C, $45, $BA, $A4, $A0  ; A495: 46 B2 A4... F..
 EQUB $1D, $40, $BE, $A6, $5D, $4A, $BE, $AA  ; A49D: 1D 40 BE... .@.

ELIF _PAL

 EQUB $1F, $55, $BC, $14, $20, $9C, $A2, $18
 EQUB $21, $9C, $AA, $1C, $07, $44, $A7, $20
 EQUB $0A, $AB, $B2, $24, $09, $14, $CC, $28
 EQUB $09, $7C, $B0, $2C, $49, $74, $CC, $30
 EQUB $49, $DC, $B0, $34, $87, $44, $D4, $74
 EQUB $15, $10, $CC, $28, $15, $79, $B0, $2C
 EQUB $55, $76, $CC, $30, $55, $DE, $B0, $34
 EQUB $1E, $A7, $BF, $3D, $5E, $AF, $BF, $41
 EQUB $1A, $4F, $CA, $AC, $1B, $4F, $CA, $B1
 EQUB $1A, $38, $CA, $44, $1B, $38, $CA, $49
 EQUB $00, $1D, $C1, $4D, $01, $D0, $B6, $51
 EQUB $40, $6C, $C1, $55, $41, $88, $B6, $59
 EQUB $00, $16, $C6, $5D, $01, $D6, $B5, $61
 EQUB $40, $73, $C6, $65, $41, $82, $B5, $69
 EQUB $17, $40, $D4, $6C, $18, $48, $D4, $70
 EQUB $19, $44, $D4, $3A, $02, $99, $BE, $78
 EQUB $42, $BC, $BE, $7C, $1C, $4F, $B8, $80
 EQUB $03, $34, $B2, $84, $04, $3C, $B2, $88
 EQUB $05, $34, $BA, $8C, $06, $3C, $BA, $90
 EQUB $44, $B2, $A2, $94, $43, $BA, $A2, $98
 EQUB $46, $B2, $AA, $9C, $45, $BA, $AA, $A0
 EQUB $1D, $40, $C4, $A6, $5D, $4A, $C4, $AA

ENDIF

; ******************************************************************************
;
;       Name: subm_A4A5
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.subm_A4A5

 JSR KeepPPUTablesAt0
 LDA ECM
 BEQ CA4B4

; ******************************************************************************
;
;       Name: subm_A4AD
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.subm_A4AD

 LDY #0
 LDX #3
 JSR subm_A39F

.CA4B4

 LDX LASER
 BEQ CA4C6
 JSR subm_A3DE
 LDY #$0C
 LDX #2
 JSR subm_A3A1
 JMP CA4C6

.CA4C6

 LDX LASER+1
 BEQ CA4D8
 JSR subm_A3DE
 LDY #$24
 LDX #1
 JSR subm_A3A1
 JMP CA4D8

.CA4D8

 LDX LASER+2
 BEQ CA4F5
 CPX #$97
 BEQ CA4EE
 JSR subm_A3DE
 LDY #$14
 LDX #2
 JSR subm_A3A1
 JMP CA4F5

.CA4EE

 LDY #$28
 LDX #2
 JSR subm_A39F

.CA4F5

 LDX LASER+3
 BEQ CA512
 CPX #$97
 BEQ CA50B
 JSR subm_A3DE
 LDY #$1C
 LDX #2
 JSR subm_A3A1
 JMP CA512

.CA50B

 LDY #$30
 LDX #2
 JSR subm_A39F

.CA512

 LDA BST
 BEQ CA51E
 LDY #$38
 LDX #2
 JSR subm_A39F

.CA51E

 LDA ENGY
 BEQ CA537
 LSR A
 BNE CA530
 LDY #$48
 LDX #2
 JSR subm_A39F
 JMP CA537

.CA530

 LDY #$40
 LDX #4
 JSR subm_A39F

.CA537

 LDA NOMSL
 BEQ CA56C
 LDY #$50
 LDX #2
 JSR subm_A39F
 LDA NOMSL
 LSR A
 BEQ CA56C
 LDY #$58
 LDX #2
 JSR subm_A39F
 LDA NOMSL
 CMP #2
 BEQ CA56C
 LDY #$60
 LDX #2
 JSR subm_A39F
 LDA NOMSL
 CMP #4
 BNE CA56C
 LDY #$68
 LDX #2
 JSR subm_A39F

.CA56C

 LDA BOMB
 BEQ CA578
 LDY #$70
 LDX #3
 JSR subm_A39F

.CA578

 LDA CRGO
 CMP #$25
 BNE CA586
 LDY #$7C
 LDX #2
 JSR subm_A39F

.CA586

 LDA ESCP
 BEQ CA592
 LDY #$84
 LDX #1
 JSR subm_A39F

.CA592

 LDA DKCMP
 BEQ CA59E
 LDY #$88
 LDX #8
 JSR subm_A39F

.CA59E

 LDA GHYP
 BEQ CA5AA
 LDY #$A8
 LDX #2
 JSR subm_A39F

.CA5AA

 RTS

; ******************************************************************************
;
;       Name: subm_A5AB
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.subm_A5AB

 PHA
 LDA QQ11
 BNE CA5B6
 JSR HideScannerSprites
 JMP CA614

.CA5B6

 JSR subm_B63D_b3
 LDY #$14
 STY NOSTM
 STY RAND+1
 LDA frameCounter
 STA RAND

.CA5C5

 SETUP_PPU_FOR_ICON_BAR ; If the PPU has started drawing the icon bar, configure
                        ; the PPU to use nametable 0 and pattern table 0

 JSR DORND
 ORA #8
 STA SZ,Y
 STA ZZ
 JSR DORND
 STA SX,Y
 JSR DORND
 STA SY,Y
 DEY
 BNE CA5C5
 LDX #$14
 LDY #$98

.CA5EF

 SETUP_PPU_FOR_ICON_BAR ; If the PPU has started drawing the icon bar, configure
                        ; the PPU to use nametable 0 and pattern table 0

 LDA #$D2
 STA tileSprite0,Y
 TXA
 LSR A
 ROR A
 ROR A
 AND #$E1
 STA attrSprite0,Y
 INY
 INY
 INY
 INY
 DEX
 BNE CA5EF
 JSR STARS_b1

.CA614

 LDA #0
 STA LASER
 STA QQ12
 LDA #$10
 JSR subm_B39D_b0
 LDA #$FF
 STA L045F
 LDA #$F0
 STA ySprite5
 STA ySprite6
 STA ySprite7
 STA ySprite8
 STA ySprite9
 LDA #0
 STA SC+1
 LDA tileNumber
 ASL A
 ROL SC+1
 ASL A
 ROL SC+1
 ASL A
 ROL SC+1
 STA SC
 STA SC2
 LDA SC+1
 ADC #$68
 STA SC2+1
 LDA SC+1
 ADC #$60
 STA SC+1
 LDX tileNumber
 LDY #0

.CA659

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
 BNE CA689
 INC SC+1
 INC SC2+1

.CA689

 SETUP_PPU_FOR_ICON_BAR ; If the PPU has started drawing the icon bar, configure
                        ; the PPU to use nametable 0 and pattern table 0

 INX
 BNE CA659
 LDA #0
 STA ALPHA
 STA ALP1
 STA DELTA
 LDA frameCounter
 CLC
 ADC RAND+1
 STA RAND+1
 JSR subm_A761
 PLA
 BNE CA6D3
 LDX language
 LDA LACAE,X
 LDY LACB2,X
 TAX
 LDA #2
 JSR subm_A917
 LDA #0
 STA QQ11
 JSR subm_AFCD_b3
 LDA #$25
 STA L00D2
 JSR subm_A761
 LDA #$3C
 STA L00D2
 JMP DemoShips_b0

.CA6D3

 CMP #2
 BEQ CA72F
 LDA #$30
 STA XX18+1
 STA XX18+2
 STA XX18+3
 LDA #$64
 STA nmiTimer
 SEC

.loop_CA6E4

 LDA nmiTimerLo
 SBC #$58
 TAX
 LDA nmiTimerHi
 SBC #2
 BCC CA6F7
 STA nmiTimerHi
 STX nmiTimerLo
 INC XX18+3
 BCS loop_CA6E4

.CA6F7

 SEC
 LDA nmiTimerLo
 SBC #$3C
 TAX
 LDA nmiTimerHi
 SBC #0
 BCC CA70B
 STA nmiTimerHi
 STX nmiTimerLo
 INC XX18+2
 BCS CA6F7

.CA70B

 SEC
 LDA nmiTimerLo

.loop_CA70E

 SBC #$0A
 BCC CA716
 INC XX18+1
 BCS loop_CA70E

.CA716

 ADC #$3A
 STA K5
 LDX language
 LDA LACB6,X
 LDY LACBA,X
 TAX
 LDA #6

.CA726

 JSR subm_A917
 JSR subm_B63D_b3
 JMP subm_B358_b0

.CA72F

 LDX language
 LDA LACBE,X
 LDY LACC2,X
 TAX
 LDA #6
 JSR subm_A917
 JSR KeepPPUTablesAt0
 LDX language
 LDA LACC6,X
 LDY LACCA,X
 TAX
 LDA #5
 JSR subm_A917
 JSR KeepPPUTablesAt0
 LDX language
 LDA LACCE,X
 LDY LACD2,X
 TAX
 LDA #3
 BNE CA726

; ******************************************************************************
;
;       Name: subm_A761
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.subm_A761

 JSR subm_D8C5
 LDA #$FE
 STA tileNumber
 LDA #$C8
 STA L03EF
 STA L03F0
 RTS

; ******************************************************************************
;
;       Name: GRIDSET
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ------------------------------------------------------------------------------
;
; Other entry points:
;
;   GRIDSET+5           ???
;
; ******************************************************************************

.GRIDSET

 LDX #6
 STX YP

 SETUP_PPU_FOR_ICON_BAR ; If the PPU has started drawing the icon bar, configure
                        ; the PPU to use nametable 0 and pattern table 0

 LDX #$15
 STX CNT
 LDX #0
 STX XP
 LDY XC

.CA78E

 LDA (XX19),Y
 BPL CA795
 TAX
 LDA SC+1,X

.CA795

 SEC
 SBC #$20
 STA S
 ASL A
 ASL A
 ADC S
 BCS CA7D1
 TAY
 LDA LTDEF,Y
 JSR GRS1
 LDA LAB70,Y
 JSR GRS1
 LDA LAB71,Y
 JSR GRS1
 LDA LAB72,Y
 JSR GRS1
 LDA LAB73,Y
 JSR GRS1
 INC XC
 LDY XC
 LDA XP
 CLC
 ADC #3
 STA XP
 DEC CNT
 BNE CA78E
 RTS

.CA7D1

 TAY
 LDA LAC6F,Y
 JSR GRS1
 LDA LAC70,Y
 JSR GRS1
 LDA LAC71,Y
 JSR GRS1
 LDA LAC72,Y
 JSR GRS1
 LDA LAC73,Y
 JSR GRS1
 INC XC
 LDY XC
 LDA XP
 CLC
 ADC #3
 STA XP
 DEC CNT
 BNE CA78E
 RTS

; ******************************************************************************
;
;       Name: GRS1
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.GRS1

 BEQ CA85E
 STA R
 STY P

 SETUP_PPU_FOR_ICON_BAR ; If the PPU has started drawing the icon bar, configure
                        ; the PPU to use nametable 0 and pattern table 0

.CA815

 LDA Y1TB,X
 BEQ CA821
 INX
 CPX #$F0
 BNE CA815
 LDX #0

.CA821

 LDA R
 AND #$0F
 TAY
 LDA NOFX,Y
 CLC
 ADC XP
 STA X1TB,X
 LDA YP
 SEC
 SBC NOFY,Y
 STA Y1TB,X
 LDA R
 LSR A
 LSR A
 LSR A
 LSR A
 TAY
 LDA NOFX,Y
 CLC
 ADC XP
 STA X2TB,X
 LDA YP
 SEC
 SBC NOFY,Y
 ASL A
 ASL A
 ASL A
 ASL A
 ORA Y1TB,X
 STA Y1TB,X
 LDY P

.CA85E

 SETUP_PPU_FOR_ICON_BAR ; If the PPU has started drawing the icon bar, configure
                        ; the PPU to use nametable 0 and pattern table 0

 RTS

; ******************************************************************************
;
;       Name: subm_A86C
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.subm_A86C

 STX XX19
 STY INF+1

 SETUP_PPU_FOR_ICON_BAR ; If the PPU has started drawing the icon bar, configure
                        ; the PPU to use nametable 0 and pattern table 0

 LDY #$F0
 LDA #0

.loop_CA881

 STA Y1TB-1,Y
 DEY
 BNE loop_CA881
 LDX #0
 STX XP
 LDA #$0F
 STA YP
 LDY #0
 STY XC
 LDA #4
 STA LASCT

.loop_CA89A

 JSR GRIDSET+5
 LDA YP
 SEC
 SBC #3
 STA YP
 DEC LASCT
 BNE loop_CA89A
 RTS

; ******************************************************************************
;
;       Name: subm_A8AC
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.subm_A8AC

 LDY #$0F

.CA8AE

 SETUP_PPU_FOR_ICON_BAR ; If the PPU has started drawing the icon bar, configure
                        ; the PPU to use nametable 0 and pattern table 0

 STY T
 TYA
 ASL A
 STA R
 ASL A
 STA S
 ASL A
 ADC #$1F
 SBC L03FC
 STA BUF+16,Y
 BPL CA8F8
 STA Q
 LDA L03FC
 LSR A
 LSR A
 ADC #$25
 SBC R

.CA8DA

 CMP Q
 BCS CA8EF
 JSR LL28
 LSR R
 LDA #$48
 CLC
 ADC R
 STA BUF,Y
 DEY
 BPL CA8AE
 RTS

.CA8EF

 LDA #$FF
 STA BUF,Y
 DEY
 BPL CA8AE
 RTS

.CA8F8

 ASL A
 BPL CA908
 STA Q
 LDA L03FC
 LSR A
 ADC #$49
 SBC S
 JMP CA8DA

.CA908

 ASL A
 STA Q
 LDA L03FC
 ADC #$90
 SBC S
 SBC S
 JMP CA8DA

; ******************************************************************************
;
;       Name: subm_A917
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.subm_A917

 PHA
 JSR subm_A86C
 LDA #$28
 STA visibleColour
 LDA #0
 STA L0300
 LDA #2
 STA L0402
 JSR subm_AC5C_b3
 LDA #$28
 STA L00CC
 LDA #$A0
 STA L03FC
 JSR CA96E
 PLA
 STA LASCT

.loop_CA93C

 LDA #$17
 STA L03FC
 JSR subm_A9A2
 JSR GRIDSET
 JSR CA96E
 DEC LASCT
 BNE loop_CA93C
 LDA #4
 STA LASCT

.loop_CA954

 LDA #$17
 STA L03FC
 JSR subm_A9A2
 JSR CA96E
 DEC LASCT
 BNE loop_CA954
 LDA #0
 STA L0402
 LDA #$2C
 STA visibleColour
 RTS

.CA96E

 LDA controller1A
 BMI CA97F
 LDA L0465
 CMP #$0C
 BNE CA984
 LDA #0
 STA L0465

.CA97F

 LDA #9
 STA L0402

.CA984

 JSR ChangeDrawingPhase
 JSR subm_AAE5
 JSR subm_D975
 LDA L0465
 BEQ CA995
 JSR subm_B1D4_b0

.CA995

 LDA L03FC
 SEC
 SBC L0402
 STA L03FC
 BCS CA96E
 RTS

; ******************************************************************************
;
;       Name: subm_A9A2
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.subm_A9A2

 SETUP_PPU_FOR_ICON_BAR ; If the PPU has started drawing the icon bar, configure
                        ; the PPU to use nametable 0 and pattern table 0

 LDY #$10

.loop_CA9B1

 LDA Y1TB+223,Y
 BEQ CA9C1
 CLC
 ADC #$33
 BCC CA9BE
 LDA #0
 CLC

.CA9BE

 STA Y1TB+223,Y

.CA9C1

 DEY
 BNE loop_CA9B1

 SETUP_PPU_FOR_ICON_BAR ; If the PPU has started drawing the icon bar, configure
                        ; the PPU to use nametable 0 and pattern table 0

 LDY #$20

.loop_CA9D3

 LDA Y1TB+191,Y
 BEQ CA9E3
 CLC
 ADC #$33
 BCC CA9E0
 LDA #0
 CLC

.CA9E0

 STA Y1TB+191,Y

.CA9E3

 DEY
 BNE loop_CA9D3

 SETUP_PPU_FOR_ICON_BAR ; If the PPU has started drawing the icon bar, configure
                        ; the PPU to use nametable 0 and pattern table 0

 LDY #$20

.loop_CA9F5

 LDA Y1TB+159,Y
 BEQ CAA05
 CLC
 ADC #$33
 BCC CAA02
 LDA #0
 CLC

.CAA02

 STA Y1TB+159,Y

.CAA05

 DEY
 BNE loop_CA9F5

 SETUP_PPU_FOR_ICON_BAR ; If the PPU has started drawing the icon bar, configure
                        ; the PPU to use nametable 0 and pattern table 0

 LDY #$20

.loop_CAA17

 LDA Y1TB+127,Y
 BEQ CAA27
 CLC
 ADC #$33
 BCC CAA24
 LDA #0
 CLC

.CAA24

 STA Y1TB+127,Y

.CAA27

 DEY
 BNE loop_CAA17

 SETUP_PPU_FOR_ICON_BAR ; If the PPU has started drawing the icon bar, configure
                        ; the PPU to use nametable 0 and pattern table 0

 LDY #$20

.loop_CAA39

 LDA Y1TB+95,Y
 BEQ CAA49
 CLC
 ADC #$33
 BCC CAA46
 LDA #0
 CLC

.CAA46

 STA Y1TB+95,Y

.CAA49

 DEY
 BNE loop_CAA39

 SETUP_PPU_FOR_ICON_BAR ; If the PPU has started drawing the icon bar, configure
                        ; the PPU to use nametable 0 and pattern table 0

 LDY #$20

.loop_CAA5B

 LDA Y1TB+63,Y
 BEQ CAA6B
 CLC
 ADC #$33
 BCC CAA68
 LDA #0
 CLC

.CAA68

 STA Y1TB+63,Y

.CAA6B

 DEY
 BNE loop_CAA5B

 SETUP_PPU_FOR_ICON_BAR ; If the PPU has started drawing the icon bar, configure
                        ; the PPU to use nametable 0 and pattern table 0

 LDY #$20

.loop_CAA7D

 LDA Y1TB+31,Y
 BEQ CAA8D
 CLC
 ADC #$33
 BCC CAA8A
 LDA #0
 CLC

.CAA8A

 STA Y1TB+31,Y

.CAA8D

 DEY
 BNE loop_CAA7D

 SETUP_PPU_FOR_ICON_BAR ; If the PPU has started drawing the icon bar, configure
                        ; the PPU to use nametable 0 and pattern table 0

 LDY #$20

.loop_CAA9F

 LDA Y1TB-1,Y
 BEQ CAAAF
 CLC
 ADC #$33
 BCC CAAAC
 LDA #0
 CLC

.CAAAC

 STA Y1TB-1,Y

.CAAAF

 DEY
 BNE loop_CAA9F

 SETUP_PPU_FOR_ICON_BAR ; If the PPU has started drawing the icon bar, configure
                        ; the PPU to use nametable 0 and pattern table 0

 RTS

; ******************************************************************************
;
;       Name: subm_AAC0
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.subm_AAC0

 SEC
 SBC #$20
 BCS CAAD7
 EOR #$FF
 ADC #1
 JSR LL28
 LDA #$80
 SEC
 SBC R
 TAX
 LDA #0
 SBC #0
 RTS

.CAAD7

 JSR LL28
 LDA R
 CLC
 ADC #$80
 TAX
 LDA #0
 ADC #0

.loop_CAAE4

 RTS

; ******************************************************************************
;
;       Name: subm_AAE5
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.subm_AAE5

 JSR subm_A8AC
 LDY #$FF

.CAAEA

 SETUP_PPU_FOR_ICON_BAR ; If the PPU has started drawing the icon bar, configure
                        ; the PPU to use nametable 0 and pattern table 0

 INY
 CPY #$F0
 BEQ loop_CAAE4
 LDA Y1TB,Y
 BEQ CAAEA
 AND #$0F
 STA Y1
 TAX
 ASL A
 ASL A
 ASL A
 SEC
 SBC L03FC
 BCC CAAEA
 STY YP
 LDA BUF+16,X
 STA Q
 LDA X1TB,Y
 JSR subm_AAC0
 STX XX15
 LDX Y1
 STA Y1
 LDA BUF,X
 STA X2
 LDA #0
 STA Y2
 LDA Y1TB,Y
 LSR A
 LSR A
 LSR A
 LSR A
 STA XX12+1
 TAX
 ASL A
 ASL A
 ASL A
 SEC
 SBC L03FC
 BCC CAAEA
 LDA BUF,X
 STA XX12
 LDA #0
 LDX XX12+1
 STA XX12+1
 LDA BUF+16,X
 STA Q

 SETUP_PPU_FOR_ICON_BAR ; If the PPU has started drawing the icon bar, configure
                        ; the PPU to use nametable 0 and pattern table 0

 LDA X2TB,Y
 JSR subm_AAC0
 STX XX15+4
 STA XX15+5
 JSR CLIP_b1
 LDY YP
 JMP CAAEA

; ******************************************************************************
;
;       Name: LTDEF
;       Type: Variable
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.LTDEF

 EQUB $00                                     ; AB6F: 00          .

.LAB70

 EQUB $00                                     ; AB70: 00          .

.LAB71

 EQUB $00                                     ; AB71: 00          .

.LAB72

 EQUB $00                                     ; AB72: 00          .

.LAB73

 EQUB $00, $14, $25, $12, $45, $78, $24, $00  ; AB73: 00 14 25... ..%
 EQUB $00, $00, $00, $02, $17, $68, $00, $00  ; AB7B: 00 00 00... ...
 EQUB $35, $36, $47, $58, $00, $47, $11, $00  ; AB83: 35 36 47... 56G
 EQUB $00, $00, $17, $35, $00, $00, $00, $36  ; AB8B: 00 00 17... ...
 EQUB $47, $34, $00, $00, $12, $13, $37, $78  ; AB93: 47 34 00... G4.
 EQUB $00, $01, $15, $57, $67, $00, $17, $35  ; AB9B: 00 01 15... ...
 EQUB $08, $26, $00, $17, $35, $00, $00, $00  ; ABA3: 08 26 00... .&.
 EQUB $36, $34, $47, $67, $79, $35, $00, $00  ; ABAB: 36 34 47... 64G
 EQUB $00, $00, $36, $34, $47, $67, $00, $16  ; ABB3: 00 00 36... ..6
 EQUB $00, $00, $00, $00, $37, $13, $15, $57  ; ABBB: 00 00 00... ...
 EQUB $00, $13, $17, $00, $00, $00, $02, $25  ; ABC3: 00 13 17... ...
 EQUB $35, $36, $68, $02, $28, $68, $35, $00  ; ABCB: 35 36 68... 56h
 EQUB $28, $23, $35, $00, $00, $02, $03, $35  ; ABD3: 28 23 35... (#5
 EQUB $58, $68, $02, $06, $68, $58, $35, $02  ; ABDB: 58 68 02... Xh.
 EQUB $28, $00, $00, $00, $06, $02, $28, $68  ; ABE3: 28 00 00... (..
 EQUB $35, $28, $02, $03, $35, $00, $13, $34  ; ABEB: 35 28 02... 5(.
 EQUB $46, $00, $00, $01, $06, $34, $67, $00  ; ABF3: 46 00 00... F..
 EQUB $13, $37, $00, $00, $00, $45, $78, $00  ; ABFB: 13 37 00... .7.
 EQUB $00, $00, $00, $00, $00, $00, $00, $00  ; AC03: 00 00 00... ...
 EQUB $00, $00, $00, $00, $00, $00, $00, $00  ; AC0B: 00 00 00... ...
 EQUB $00, $06, $02, $28, $35, $00, $06, $02  ; AC13: 00 06 02... ...
 EQUB $28, $68, $35, $68, $06, $02, $00, $00  ; AC1B: 28 68 35... (h5
 EQUB $06, $05, $56, $00, $00, $68, $06, $02  ; AC23: 06 05 56... ..V
 EQUB $35, $00, $06, $02, $35, $00, $00, $45  ; AC2B: 35 00 06... 5..
 EQUB $58, $68, $60, $02, $06, $28, $35, $00  ; AC33: 58 68 60... Xh`
 EQUB $00, $17, $00, $00, $00, $00, $28, $68  ; AC3B: 00 17 00... ...
 EQUB $36, $00, $00, $06, $23, $38, $00, $00  ; AC43: 36 00 00... 6..
 EQUB $68, $06, $00, $00, $00, $06, $04, $24  ; AC4B: 68 06 00... h..
 EQUB $28, $00, $06, $08, $28, $00, $00, $06  ; AC53: 28 00 06... (..
 EQUB $02, $28, $68, $00, $06, $02, $25, $35  ; AC5B: 02 28 68... .(h
 EQUB $00, $06, $02, $28, $68, $48, $06, $02  ; AC63: 00 06 02... ...
 EQUB $25, $35, $48, $02                      ; AC6B: 25 35 48... %5H

; ******************************************************************************
;
;       Name: LAC6F
;       Type: Variable
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.LAC6F

 EQUB 3                                       ; AC6F: 03          .

.LAC70

 EQUB $35                                     ; AC70: 35          5

.LAC71

 EQUB $58                                     ; AC71: 58          X

.LAC72

 EQUB $68                                     ; AC72: 68          h

.LAC73

 EQUB $02, $17, $00, $00, $00, $28, $68, $06  ; AC73: 02 17 00... ...
 EQUB $00, $00, $27, $07, $00, $00, $00, $28  ; AC7B: 00 00 27... ..'
 EQUB $48, $46, $06, $00, $26, $08, $00, $00  ; AC83: 48 46 06... HF.
 EQUB $00, $47, $04, $24, $00, $00, $02, $26  ; AC8B: 00 47 04... .G.
 EQUB $68, $00, $00                           ; AC93: 68 00 00    h..

.NOFX

 EQUB 1, 2, 3, 1, 2, 3, 1, 2, 3, 1, 2, 3      ; AC96: 01 02 03... ...

.NOFY

 EQUB 0, 0, 0, 1, 1, 1, 2, 2, 2, 3, 3, 3      ; ACA2: 00 00 00... ...

.LACAE

 EQUB $D6, $76, $26, $D6                      ; ACAE: D6 76 26... .v&

.LACB2

 EQUB $AC, $AF, $AE, $AC                      ; ACB2: AC AF AE... ...

.LACB6

 EQUB $54, $F4, $A4, $54                      ; ACB6: 54 F4 A4... T..

.LACBA

 EQUB $AD, $AF, $AE, $AD                      ; ACBA: AD AF AE... ...

.LACBE

 EQUB $C6, $C6, $C6, $C6                      ; ACBE: C6 C6 C6... ...

.LACC2

 EQUB $B0, $B0, $B0, $B0                      ; ACC2: B0 B0 B0... ...

.LACC6

 EQUB $98, $98, $98, $98                      ; ACC6: 98 98 98... ...

.LACCA

 EQUB $B1, $B1, $B1, $B1                      ; ACCA: B1 B1 B1... ...

.LACCE

 EQUS $55, $55, $55, $55                      ; ACCE: 55 55 55... UUU

.LACD2

 EQUB $B2, $B2, $B2, $B2                      ; ACD2: B2 B2 B2... ...

IF _NTSC

 EQUS "   NTSC EMULATION      --- E L # T "
 EQUS "E ---  (C)BELL & BRABEN 1991       "

ELIF _PAL

 EQUS " IMAGINEER PRESENTS    --- E L # T "
 EQUS "E ---  (C)BRABEN & BELL 1991       "

ENDIF

 EQUS "              PREPARE FOR PRACTICE "   ; AD1C: 20 20 20...
 EQUS "COMBAT SEQUENCE...... CONGRATULATIO"   ; AD3F: 43 4F 4D... COM
 EQUS "NS! YOUCOMPLETED  THE COMBAT IN "      ; AD62: 4E 53 21... NS!
 EQUB $83, $82                                ; AD82: 83 82       ..
 EQUS "  MIN  "                               ; AD84: 20 20 4D...   M
 EQUB $81, $80                                ; AD8B: 81 80       ..
 EQUS " SEC.                      YOU BEGI"   ; AD8D: 20 53 45...  SE
 EQUS "N YOUR CAREERDOCKED AT  THE PLANETL"   ; ADB0: 4E 20 59... N Y
 EQUS "AVE WITH 100 CREDITS3 MISSILES AND "   ; ADD3: 41 56 45... AVE
 EQUS "A FULLTANK OF FUEL.        GOOD LUC"   ; ADF6: 41 20 46... A F
 EQUS "K, COMMANDER!"

IF _NTSC

 EQUS "   NTSC EMULATION     "
 EQUS " --- E L # T E ---  (C)BELL & BRABE"   ; AE3C: 20 2D 2D...  --
 EQUS "N 1991                      PREPARE"   ; AE5F: 4E 20 31... N 1

ELIF _PAL

 EQUS " IMAGINEER PRESENTE   "
 EQUS " --- E L # T E ---  (C)BRABEN & BEL"   ; AE3C: 20 2D 2D...  --
 EQUS "L 1991                      PREPARE"   ; AE5F: 4E 20 31... N 1

ENDIF

 EQUS "Z-VOUS  A  LASIMULATION DU COMBAT! "   ; AE82: 5A 2D 56... Z-V
 EQUS "FELICITATIONS! VOTRECOMBAT EST TERM"   ; AEA5: 46 45 4C... FEL
 EQUS "INE EN   "                             ; AEC8: 49 4E 45... INE
 EQUB $83, $82                                ; AED1: 83 82       ..
 EQUS "  MIN  "                               ; AED3: 20 20 4D...   M
 EQUB $81, $80                                ; AEDA: 81 80       ..
 EQUS " SEC.                        VOUS C"   ; AEDC: 20 53 45...  SE
 EQUS "OMMENCEZ VOTRECOURS  SUR LA PLANETE"   ; AEFF: 4F 4D 4D... OMM
 EQUS "LAVE AVEC 100 CREDITSET TROIS MISSI"   ; AF22: 4C 41 56... LAV
 EQUS "LES.        BONNE CHANCE         CO"   ; AF45: 4C 45 53... LES
 EQUS "MMANDANT!"

IF _NTSC

 EQUS "        NTSC EMULATION    "   ; AF68: 4D 4D 41... MMA
 EQUS "  --- E L # T E ---  (C)BELL & BRAB"   ; AF8B: 20 20 2D...   -
 EQUS "EN 1991                     RUSTEN "   ; AFAE: 45 4E 20... EN

ELIF _PAL

 EQUS "        IMAGINEER ZEIGT   "   ; AF68: 4D 4D 41... MMA
 EQUS "  --- E L # T E ---  (C)BRABEN & BE"   ; AF8B: 20 20 2D...   -
 EQUS "LL 1991                     RUSTEN "   ; AFAE: 45 4E 20... EN

ENDIF

 EQUS " SIE  SICH ZUMPROBEKAMPF..........."   ; AFD1: 20 53 49...  SI
 EQUS " BRAVO! SIE HABEN DENKAMPF  GEWONNE"   ; AFF4: 20 42 52...  BR
 EQUS "N  ZEIT  "                             ; B017: 4E 20 20... N
 EQUB $83, $82                                ; B020: 83 82       ..
 EQUS "  MIN  "                               ; B022: 20 20 4D...   M
 EQUB $81, $80                                ; B029: 81 80       ..
 EQUS "  SEK.                         SIE "   ; B02B: 20 20 53...   S
 EQUS " BEGINNEN  IHREKARRIERE  IM DOCK DE"   ; B04E: 20 42 45...  BE
 EQUS "SPLANETS LAVE MIT DREIRAKETEN, 100 "   ; B071: 53 50 4C... SPL
 EQUS "CR,  UNDEINEM VOLLEN TANK.   VIEL G"   ; B094: 43 52 2C... CR,
 EQUS "LUCK,COMMANDER!ORIGINAL GAME AND NE"   ; B0B7: 4C 55 43... LUC
 EQUS "SCONVERSION  BY  DAVIDBRABEN  AND #"   ; B0DA: 53 43 4F... SCO
 EQUS "AN BELL.                     DEVELO"   ; B0FD: 41 4E 20... AN
 EQUS "PED USING  PDS.HANDLED BY MARJACQ. "   ; B120: 50 45 44... PED
 EQUS "                      ARTWORK   BY "   ; B143: 20 20 20...
 EQUS " EUROCOMDEVELOPMENTS LTD.          "   ; B166: 20 45 55...  EU
 EQUS "               MUSIC & SOUNDS  CODE"   ; B189: 20 20 20...
 EQUS "DBY  DAVID  WHITTAKER.             "   ; B1AC: 44 42 59... DBY
 EQUS "        MUSIC BY  AIDAN  BELLAND  J"   ; B1CF: 20 20 20...
 EQUS "OHANN  STRAUSS.                    "   ; B1F2: 4F 48 41... OHA
 EQUS " TESTERS=CHRIS JORDAN,SAM AND JADE "   ; B215: 20 54 45...  TE
 EQUS "BRIANT, R AND M CHADWICK.    ELITE "   ; B238: 42 52 49... BRI
 EQUS "LOGO DESIGN BY PHILIP CASTLE.      "   ; B25B: 4C 4F 47... LOG
 EQUS "                      GAME TEXT TRA"   ; B27E: 20 20 20...
 EQUS "NSLATERSUBI SOFT,            SUSANN"   ; B2A1: 4E 53 4C... NSL
 EQUS "E DIECK,       IMOGEN  RIDLER.     "   ; B2C4: 45 20 44... E D
 EQUS " STORED COMMANDERS"                    ; B2E7: 20 53 54...  ST
 EQUB $0C, $0C, $0C,   6,   0                 ; B2F9: 0C 0C 0C... ...
 EQUS "                    STORED"            ; B2FE: 20 20 20...
 EQUB $0C                                     ; B318: 0C          .
 EQUS "                    POSITIONS"         ; B319: 20 20 20...
 EQUB $0C, $0C, $0C, $0C, $0C, $0C, $0C       ; B336: 0C 0C 0C... ...
 EQUS "CURRENT"                               ; B33D: 43 55 52... CUR
 EQUB $0C                                     ; B344: 0C          .
 EQUS "POSITION"                              ; B345: 50 4F 53... POS
 EQUB 0                                       ; B34D: 00          .
 EQUS "GESPEICHERTE KOMMANDANTEN"             ; B34E: 47 45 53... GES
 EQUB $0C, $0C, $0C,   6,   0                 ; B367: 0C 0C 0C... ...
 EQUS "                    GESP."             ; B36C: 20 20 20...
 EQUB $0C                                     ; B385: 0C          .
 EQUS "                   POSITIONEN"         ; B386: 20 20 20...
 EQUB $0C, $0C, $0C, $0C, $0C, $0C, $0C       ; B3A3: 0C 0C 0C... ...
 EQUS "GEGENW."                               ; B3AA: 47 45 47... GEG
 EQUB $0C                                     ; B3B1: 0C          .
 EQUS "POSITION"                              ; B3B2: 50 4F 53... POS
 EQUB 0                                       ; B3BA: 00          .
 EQUS "COMMANDANTS SAUVEGARDES"               ; B3BB: 43 4F 4D... COM
 EQUB $0C, $0C, $0C,   6,   0                 ; B3D2: 0C 0C 0C... ...
 EQUS "                    POSITIONS"         ; B3D7: 20 20 20...
 EQUB $0C                                     ; B3F4: 0C          .
 EQUS "                  SAUVEGARD<ES"        ; B3F5: 20 20 20...
 EQUB $0C, $0C, $0C, $0C, $0C, $0C, $0C       ; B413: 0C 0C 0C... ...
 EQUS "POSITION"                              ; B41A: 50 4F 53... POS
 EQUB $0C                                     ; B422: 0C          .
 EQUS "ACTUELLE"                              ; B423: 41 43 54... ACT
 EQUB 0                                       ; B42B: 00          .

.LB42C

 EQUB 8, 4, 4, 5                              ; B42C: 08 04 04... ...

.LB430

 EQUB $E8, $4E, $BB                           ; B430: E8 4E BB    .N.

.LB433

 EQUB $B2, $B3, $B3                           ; B433: B2 B3 B3    ...

.LB436

 EQUB $FE, $6C, $D7                           ; B436: FE 6C D7    .l.

.LB439

 EQUB $B2, $B3, $B3                           ; B439: B2 B3 B3    ...

.LB43C

 EQUB $68, $6A, $69, $6A, $69, $6A, $69, $6A  ; B43C: 68 6A 69... hji
 EQUB $6B, $6A, $69, $6A, $69, $6A, $6C, $00  ; B444: 6B 6A 69... kji

; ******************************************************************************
;
;       Name: subm_B44C
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.subm_B44C

 LDY #0

.loop_CB44E

 LDA (V),Y
 BEQ CB458
 JSR TT27_b2
 INY
 BNE loop_CB44E

.CB458

 RTS

; ******************************************************************************
;
;       Name: subm_B459
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.subm_B459

 LDA #$BB
 JSR TT66_b0
 LDA #$8B
 STA QQ11
 LDY #0
 STY L03EE
 STY QQ17
 STY YC
 LDX language
 LDA LB42C,X
 STA XC
 LDA LB430,X
 STA V
 LDA LB433,X
 STA V+1
 JSR subm_B44C
 LDA #$BB
 STA QQ11
 LDX language
 LDA LB436,X
 STA V
 LDA LB439,X
 STA V+1
 JSR subm_B44C
 JSR NLIN4
 JSR subm_EB86
 LDY #$14

IF _NTSC

 LDA #$39

ELIF _PAL

 LDA #$3F

ENDIF

 STA T
 LDX #0

.CB4A2

 LDA #$22
 STA attrSprite0,Y
 LDA LB43C,X
 BEQ CB4C6
 STA tileSprite0,Y
 LDA #$53
 STA xSprite0,Y
 LDA T
 STA ySprite0,Y
 CLC
 ADC #8
 STA T
 INY
 INY
 INY
 INY
 INX
 JMP CB4A2

.CB4C6

 STY CNT
 LDY #7

.loop_CB4CA

 TYA
 ASL A
 CLC
 ADC #6
 STA YC
 LDX #$14
 STX XC
 JSR subm_B62C
 DEY
 BPL loop_CB4CA
 JSR subm_B9F9_b4
 LDA #0

.loop_CB4E0

 CMP #8
 BEQ CB4E7
 JSR subm_B659

.CB4E7

 CLC
 ADC #1
 CMP #9
 BCC loop_CB4E0
 JSR subm_B6BB
 JSR subm_8926_b0
 LDA #9

; ******************************************************************************
;
;       Name: subm_B4F6
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.subm_B4F6

 JSR SetupPPUForIconBar ; If the PPU has started drawing the icon bar, configure
                        ; the PPU to use nametable 0 and pattern table 0

 LDX L04BA
 BPL CB50F
 JSR subm_B659
 CMP #9
 BEQ CB50A
 LDA #0
 JMP CB50C

.CB50A

 LDA #4

.CB50C

 JMP subm_B577

.CB50F

 LDX L04BB
 BPL CB525
 JSR subm_B659
 CMP #9
 BEQ CB520
 LDA #0
 JMP CB522

.CB520

 LDA #4

.CB522

 JMP CB5CB

.CB525

 JSR subm_B52B
 BCS subm_B4F6
 RTS

; ******************************************************************************
;
;       Name: subm_B52B
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.subm_B52B

 LDX L0465
 BEQ CB53B
 PHA
 CPX #7
 BEQ CB53D
 TXA
 JSR subm_B1D4_b0
 PLA
 RTS

.CB53B

 SEC
 RTS

.CB53D

 LDA COK
 BMI CB558
 LDA #0
 STA L0465
 JSR ChangeCmdrName_b6
 LDA L0465
 BEQ CB553
 CMP #7
 BEQ CB53D

.CB553

 LDA #6
 STA L0465

.CB558

 CLC
 PLA
 RTS

; ******************************************************************************
;
;       Name: subm_B55B
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.subm_B55B

 PHA

.loop_CB55C

 JSR SetupPPUForIconBar ; If the PPU has started drawing the icon bar, configure
                        ; the PPU to use nametable 0 and pattern table 0

 LDA L04BA
 ORA L04BB
 BMI loop_CB55C
 PLA
 RTS

; ******************************************************************************
;
;       Name: subm_B569
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.subm_B569

 LDA #9
 JSR subm_B6BB
 JSR subm_B6C7
 JSR subm_B55B
 JMP subm_B4F6

; ******************************************************************************
;
;       Name: subm_B577
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.subm_B577

 JSR subm_B6BB
 JSR subm_B6C7
 JSR subm_B55B

.CB580

 JSR SetupPPUForIconBar ; If the PPU has started drawing the icon bar, configure
                        ; the PPU to use nametable 0 and pattern table 0

 LDX controller1Up
 BPL CB598
 CMP #0
 BEQ CB598
 JSR subm_B659
 SEC
 SBC #1
 JSR subm_B6BB
 JSR subm_B6C7

.CB598

 LDX controller1Down
 BPL CB5AD
 CMP #7
 BCS CB5AD
 JSR subm_B659
 CLC
 ADC #1
 JSR subm_B6BB
 JSR subm_B6C7

.CB5AD

 LDX L04BA
 BPL CB5B8
 JSR subm_B659
 JMP CB5CB

.CB5B8

 LDX L04BB
 BPL CB5C5
 JSR subm_B659
 LDA #4
 JMP subm_B569

.CB5C5

 JSR subm_B52B
 BCS CB580
 RTS

.CB5CB

 JSR subm_B6D0
 JSR subm_B6C7
 JSR subm_B55B

.CB5D4

 JSR SetupPPUForIconBar ; If the PPU has started drawing the icon bar, configure
                        ; the PPU to use nametable 0 and pattern table 0

 LDX controller1Up
 BPL CB5EC
 CMP #0
 BEQ CB5EC
 JSR subm_B6E8
 SEC
 SBC #1
 JSR subm_B6D0
 JSR subm_B6C7

.CB5EC

 LDX controller1Down
 BPL CB601
 CMP #7
 BCS CB601
 JSR subm_B6E8
 CLC
 ADC #1
 JSR subm_B6D0
 JSR subm_B6C7

.CB601

 LDX L04BA
 BPL CB618
 CMP #4
 BNE CB618
 JSR subm_B6E8
 LDA #9
 JSR subm_B854
 JSR subm_AC5C_b3
 JMP subm_B569

.CB618

 LDX L04BB
 BPL CB626
 JSR subm_B6E8
 JSR subm_B854
 JMP subm_B577

.CB626

 JSR subm_B52B
 BCS CB5D4
 RTS

; ******************************************************************************
;
;       Name: subm_B62C
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.subm_B62C

 STY YSAV2
 LDY CNT
 LDA #$6D
 STA tileSprite0,Y
 LDA XC
 ASL A
 ASL A
 ASL A
 ADC #0
 STA xSprite0,Y
 LDA #$22
 STA attrSprite0,Y
 LDA YC
 ASL A
 ASL A
 ASL A

IF _NTSC

 ADC #6

ELIF _PAL

 ADC #$C

ENDIF

 STA ySprite0,Y
 TYA
 CLC
 ADC #4
 STA CNT
 LDY YSAV2
 RTS

; ******************************************************************************
;
;       Name: subm_B659
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.subm_B659

 JSR subm_B786
 PHA
 CMP #8
 BCC CB680
 LDX #1
 STX XC
 CMP #9
 BCC CB679
 BEQ CB672
 LDA #$12
 STA YC
 JMP CB68A

.CB672

 LDA #$0E
 STA YC
 JMP CB68A

.CB679

 LDA #6
 STA YC
 JMP CB68A

.CB680

 ASL A
 CLC
 ADC #6
 STA YC
 LDA #$15
 STA XC

.CB68A

 PLA

; ******************************************************************************
;
;       Name: subm_B68B
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.subm_B68B

 PHA
 LDY #0

.loop_CB68E

 LDA BUF,Y
 JSR DASC_b2
 INY
 CPY #7
 BCC loop_CB68E
 LDX #0
 LDA BUF+7
 AND #$7F
 SEC

.loop_CB6A1

 SBC #$0A
 INX
 BCS loop_CB6A1
 TAY
 LDA #$20
 DEX
 BEQ CB6AF
 TXA
 ADC #$30

.CB6AF

 JSR DASC_b2
 TYA
 CLC
 ADC #$3A
 JSR DASC_b2
 PLA
 RTS

; ******************************************************************************
;
;       Name: subm_B6BB
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.subm_B6BB

 LDX #2
 STX fontBitPlane
 JSR subm_B659
 LDX #1
 STX fontBitPlane
 RTS

; ******************************************************************************
;
;       Name: subm_B6C7
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.subm_B6C7

 PHA
 JSR subm_8980_b0
 JSR subm_D8C5
 PLA
 RTS

; ******************************************************************************
;
;       Name: subm_B6D0
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.subm_B6D0

 LDX #2
 STX fontBitPlane
 LDX #$0B
 STX XC
 PHA
 ASL A
 CLC
 ADC #6
 STA YC
 PLA
 JSR subm_B68B
 LDX #1
 STX fontBitPlane
 RTS

; ******************************************************************************
;
;       Name: subm_B6E8
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.subm_B6E8

 LDX #$0B
 STX XC
 PHA
 ASL A
 CLC
 ADC #6
 STA YC
 JSR subm_DBD8
 LDA SC
 CLC
 ADC XC
 STA SC
 LDY #8
 LDA #0

.loop_CB701

 STA (SC),Y
 DEY
 BPL loop_CB701
 PLA
 RTS

; ******************************************************************************
;
;       Name: LB708
;       Type: Variable
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.LB708

 EQUB $4A, $5A, $48, $02, $53, $B7, $00, $00  ; B708: 4A 5A 48... JZH
 EQUB $94, $B4, $90, $04, $A6, $6F, $00, $00  ; B710: 94 B4 90... ...
 EQUB $29, $69, $21, $08, $4D, $DE, $00, $00  ; B718: 29 69 21... )i!
 EQUB $52, $D2, $42, $10, $9A, $BD, $00, $00  ; B720: 52 D2 42... R.B
 EQUB $A4, $A5, $84, $20, $35, $7B, $00, $00  ; B728: A4 A5 84... ...
 EQUB $49, $4B, $09, $40, $6A, $F6, $00, $00  ; B730: 49 4B 09... IK.
 EQUB $92, $96, $12, $80, $D4, $ED, $00, $00  ; B738: 92 96 12... ...
 EQUB $25, $2D, $24, $01, $A9, $DB, $00, $00  ; B740: 25 2D 24... %-$

.LB748

 EQUB 0                                       ; B748: 00          .

.LB749

 EQUB $79, $49, $79, $92, $79, $DB, $79, $24  ; B749: 79 49 79... yIy
 EQUB $7A, $6D, $7A, $B6, $7A, $FF, $7A       ; B751: 7A 6D 7A... zmz

.LB758

 EQUB $48                                     ; B758: 48          H

.LB759

 EQUB $7B, $91, $7B, $DA, $7B, $23, $7C, $6C  ; B759: 7B 91 7B... {.{
 EQUB $7C, $B5, $7C, $FE, $7C, $47, $7D       ; B761: 7C B5 7C... |.|

.LB768

 EQUB $90                                     ; B768: 90          .

.LB769

 EQUB $7D, $D9, $7D, $22, $7E, $6B, $7E, $B4  ; B769: 7D D9 7D... }.}
 EQUB $7E, $FD, $7E, $46, $7F, $8F, $7F       ; B771: 7E FD 7E... ~.~

; ******************************************************************************
;
;       Name: subm_B778
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.subm_B778

 PHA

.loop_CB779

 LDX #$4E

.loop_CB77B

 LDA LB89C,X
 STA BUF,X
 DEX
 BPL loop_CB77B
 PLA
 RTS

; ******************************************************************************
;
;       Name: subm_B786
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.subm_B786

 PHA

 JSR SetupPPUForIconBar ; If the PPU has started drawing the icon bar, configure
                        ; the PPU to use nametable 0 and pattern table 0

 CMP #9
 BEQ CB7E7
 CMP #8
 BEQ loop_CB779
 JSR subm_B833
 LDY #$48

.CB797

 SETUP_PPU_FOR_ICON_BAR ; If the PPU has started drawing the icon bar, configure
                        ; the PPU to use nametable 0 and pattern table 0

 LDA (Q),Y

IF _NTSC

 EOR #$F0
 STA SC2+1
 LDA (S),Y
 EOR #$0F
 STA SC2

ELIF _PAL

 LSR A
 BCC LB7AB
 ORA #$80
 
.LB7AB

 LSR A
 BCC LB7B0
 ORA #$80

.LB7B0

 STA SC2+1
 LDA (S),Y
 LSR A
 BCC LB7B9
 ORA #$80
 
.LB7B9

 STA SC2

ENDIF

 LDA (SC),Y
 CMP SC2+1
 BEQ CB7C0
 CMP SC2
 BEQ CB7C0
 LDA SC2+1
 CMP SC2
 BNE CB7FF

.CB7C0

 STA BUF,Y
 STA (SC),Y

IF _NTSC

 EOR #$0F
 STA (S),Y
 EOR #$FF
 STA (Q),Y

ELIF _PAL

 ASL A
 ADC #0
 STA (S),Y
 ASL A
 ADC #0
 STA (Q),Y

ENDIF

 DEY
 BPL CB797
 LDA BUF+17
 ASL A
 ASL A
 ASL A
 TAY
 LDX #0

.loop_CB7D9

 LDA LB708,Y
 STA BUF+73,X
 INY
 INX
 CPX #6
 BNE loop_CB7D9
 PLA
 RTS

.CB7E7

 LDA NAME+7
 AND #$7F
 STA NAME+7
 LDX #$4E

.loop_CB7F1

 LDA NAME,X
 STA L7800,X
 STA BUF,X
 DEX
 BPL loop_CB7F1
 PLA
 RTS

.CB7FF

 JSR subm_B778
 LDA #$20
 LDY #6

.loop_CB806

 STA BUF,Y
 DEY
 BPL loop_CB806
 LDA #0
 STA BUF+7
 PLA
 PHA
 JSR subm_B854
 PLA
 RTS

; ******************************************************************************
;
;       Name: subm_B818
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.subm_B818

 LDX #7

.loop_CB81A

 TXA
 PHA
 JSR subm_B833
 LDY #$0A
 LDA #1
 STA (SC),Y
 LDA #3
 STA (Q),Y
 LDA #7
 STA (S),Y
 PLA
 TAX
 DEX
 BPL loop_CB81A
 RTS

; ******************************************************************************
;
;       Name: subm_B833
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.subm_B833

 ASL A
 TAX
 LDA LB748,X
 STA SC
 LDA LB758,X
 STA Q
 LDA LB768,X
 STA S
 LDA LB749,X
 STA SC+1
 LDA LB759,X
 STA R
 LDA LB769,X
 STA T
 RTS

; ******************************************************************************
;
;       Name: subm_B854
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.subm_B854

 PHA
 CMP #9
 BEQ CB879
 JSR subm_B833
 LDA BUF+7
 AND #$7F
 STA BUF+7
 LDY #$48

.loop_CB866

 LDA BUF,Y
 STA (SC),Y

IF _NTSC

 EOR #$0F
 STA (S),Y
 EOR #$FF
 STA (Q),Y

ELIF _PAL

 ASL A
 ADC #0
 STA (S),Y
 ASL A
 ADC #0
 STA (Q),Y

ENDIF

 DEY
 BPL loop_CB866
 PLA
 RTS

; ******************************************************************************
;
;       Name: subm_B878
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.subm_B878

 PHA

.CB879

 LDX #$4E

.loop_CB87B

 LDA BUF,X
 STA L7800,X
 STA NAME,X
 DEX
 BPL loop_CB87B
 JSR BR1_b0
 PLA
 RTS

; ******************************************************************************
;
;       Name: subm_B88C
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.subm_B88C

 LDA #7

.loop_CB88E

 PHA
 JSR KeepPPUTablesAt0
 PLA
 JSR subm_B786
 SEC
 SBC #1
 BPL loop_CB88E
 RTS

; ******************************************************************************
;
;       Name: LB89C
;       Type: Variable
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.LB89C

 EQUB $4A, $41, $4D, $45, $53, $4F, $4E, $01  ; B89C: 4A 41 4D... JAM
 EQUB $00, $14, $AD, $00, $00, $03, $E8, $46  ; B8A4: 00 14 AD... ...
 EQUB $00, $00, $18, $00, $00, $00, $16, $00  ; B8AC: 00 00 18... ...
 EQUB $00, $00, $00, $00, $00, $00, $00, $00  ; B8B4: 00 00 00... ...
 EQUB $00, $00, $00, $00, $00, $00, $00, $00  ; B8BC: 00 00 00... ...
 EQUB $00, $00, $00, $00, $00, $00, $00, $00  ; B8C4: 00 00 00... ...
 EQUB $00, $00, $03, $00, $10, $0F, $11, $00  ; B8CC: 00 00 03... ...
 EQUB $03, $1C, $0E, $00, $00, $0A, $00, $11  ; B8D4: 03 1C 0E... ...
 EQUB $3A, $07, $09, $08, $00, $00, $00, $00  ; B8DC: 3A 07 09... :..
 EQUB $80, $4A, $5A, $48, $02, $53, $B7, $AA  ; B8E4: 80 4A 5A... .JZ
 EQUB $27, $03, $00, $00, $00, $00, $00, $00  ; B8EC: 27 03 00... '..
 EQUB $00, $00, $00, $00, $00, $00, $00, $00  ; B8F4: 00 00 00... ...
 EQUB $00, $00                                ; B8FC: 00 00       ..

; ******************************************************************************
;
;       Name: subm_B8FE
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.subm_B8FE

 JSR subm_B906
 LDX #$4F

.loop_CB903

 LDA nameBuffer1+1023,X
 STA L0395,X
 DEX
 BNE loop_CB903
 RTS

; ******************************************************************************
;
;       Name: subm_B906
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.subm_B906

 LDY #$5E

.loop_CB90F

 LDA LB89C,Y
 STA L7800,Y
 DEY
 BPL loop_CB90F
 RTS

; ******************************************************************************
;
;       Name: subm_B919
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.subm_B919

 LDA K+1
 LSR A
 STA XX2+1
 LDA K+3
 SEC
 SBC XX2+1
 CLC
 ADC #1
 STA K3
 JSR CB932
 LDA K+3
 CLC
 ADC XX2+1
 STA K3

.CB932

 LDA K
 LSR A
 LSR A
 STA STP
 LDA K+2
 SEC
 SBC K
 STA XX15
 LDA K3
 STA Y1
 LDY #7

.CB945

 JSR DORND
 STA Q
 LDA K+1
 JSR FMLTU
 CLC
 ADC K3
 SEC
 SBC XX2+1
 STA Y2
 LDA XX15
 CLC
 ADC STP
 STA X2
 JSR LOIN
 LDA SWAP
 BNE CB96E
 LDA X2
 STA XX15
 LDA Y2
 STA Y1

.CB96E

 DEY
 BNE CB945
 LDA K+2
 CLC
 ADC K
 STA X2
 LDA K3
 STA Y2
 JSR LOIN
 RTS

; ******************************************************************************
;
;       Name: LL164
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.LL164

 JSR subm_D8C5
 JSR HideStardust
 JSR HideSprites59To62
 JSR subm_EBED
 LDA #$80
 STA K+2
 LDA #$48
 STA K+3
 LDA #$40
 STA XP

.CB999

 JSR subm_ECE2
 JSR DORND
 AND #$0F
 TAX
 LDA LBA06,X
 STA visibleColour
 JSR ChangeDrawingPhase
 LDA XP
 AND #$1F
 STA STP
 LDA #8
 STA XX15
 LDA #$F8
 STA X2

.CB9B9

 SETUP_PPU_FOR_ICON_BAR ; If the PPU has started drawing the icon bar, configure
                        ; the PPU to use nametable 0 and pattern table 0

 LDA STP
 CLC
 ADC #$10
 STA STP
 CMP #$5A
 BCS CB9FB
 STA Q
 LDA #8
 JSR LL28
 LDA R
 SEC
 SBC #$14
 STA K+1
 LDA Yx1M2
 SBC K+1
 BCC CB9B9
 BEQ CB9B9
 TAY
 JSR subm_E0BA
 INC X2
 LDA K+1
 CLC
 ADC Yx1M2
 TAY
 JSR subm_E0BA
 INC X2
 JMP CB9B9

.CB9FB

 JSR subm_D975
 DEC XP
 BNE CB999
 JMP subm_D8C5

; ******************************************************************************
;
;       Name: LBA06
;       Type: Variable
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.LBA06

 EQUB $06, $0F, $38, $2A, $23, $25, $22, $11  ; BA06: 06 0F 38... ..8
 EQUB $1A, $00, $26, $2C, $20, $13, $0F, $00  ; BA0E: 1A 00 26... ..&

; ******************************************************************************
;
;       Name: subm_BA17
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.CBA16

 RTS

.subm_BA17

 LDA K+2
 CLC
 ADC K
 BCS CBA16
 STA X2
 STA XX15
 LDA K+3
 SEC
 SBC K+1
 BCS CBA2B
 LDA #0

.CBA2B

 STA Y1
 LDA K+3
 CLC
 ADC K+1
 BCS CBA3A
 CMP Yx2M1
 BCC CBA3A
 LDA Yx2M1

.CBA3A

 STA Y2
 JSR subm_E33E
 LDA K+2
 SEC
 SBC K
 BCC CBA16
 STA XX15
 JSR subm_E33E
 INC XX15
 LDY Y1
 BEQ CBA56
 JSR subm_E0BA
 INC X2

.CBA56

 DEC XX15
 INC X2
 LDY Y2
 CPY Yx2M1
 BCS CBA16
 JMP subm_E0BA

; ******************************************************************************
;
;       Name: subm_BA63
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.subm_BA63

 LDY #0

.CBA65

 LDA INWK+5,Y
 CMP #$41
 BCS CBA6E
 LDA #$41

.CBA6E

 PHA
 PLA
 JSR subm_BACB
 BCS CBA9C
 CMP #$1B
 BEQ CBAAF
 CMP #$7F
 BEQ CBAB5
 CPY L0483
 BCS CBA93
 CMP #$21
 BCC CBA93
 CMP #$7B
 BCS CBA93
 STA INWK+5,Y
 INY
 INC XC
 JMP CBA65

.CBA93

 JSR BEEP_b7
 LDY L0483
 JMP CBA65

.CBA9C

 STA INWK+5,Y
 INY
 LDA #$0D
 STA INWK+5,Y
 LDA #$0C
 JSR CHPR_b2
 JSR subm_D951
 CLC
 RTS

.CBAAF

 LDA #$0D
 STA INWK+5
 SEC
 RTS

.CBAB5

 TYA
 BEQ CBAC4
 DEY
 LDA #$7F
 JSR CHPR_b2
 LDA INWK+5,Y
 JMP CBA6E

.CBAC4

 JSR BEEP_b7
 LDY #0
 BEQ CBA65

; ******************************************************************************
;
;       Name: subm_BACB
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.subm_BACB

 TAX
 STY YSAV
 LDA fontBitPlane
 PHA
 LDA QQ11
 AND #$20
 BEQ CBADB
 LDA #1
 STA fontBitPlane

.CBADB

 TXA

.CBADC

 PHA
 LDY #4
 JSR DELAY
 PLA
 PHA
 JSR CHPR_b2
 DEC XC
 JSR subm_D951
 SEC
 LDA controller1A
 BMI CBB2A
 CLC
 PLA
 LDX controller1B
 BMI CBADC
 LDX L0465
 BNE CBB33
 LDX L04BA
 BMI CBB26
 LDX L04BB
 BMI CBB2B
 LDX controller1Up
 BPL CBB16
 CLC
 ADC #1
 CMP #$5B
 BNE CBB16
 LDA #$41

.CBB16

 LDX controller1Down
 BPL CBADC
 SEC
 SBC #1
 CMP #$40
 BNE CBADC
 LDA #$5A
 BNE CBADC

.CBB26

 LDA #$7F
 BNE CBB2B

.CBB2A

 PLA

.CBB2B

 TAX
 PLA
 STA fontBitPlane
 LDY YSAV
 TXA
 RTS

.CBB33

 LDA #$1B
 BNE CBB2B

; ******************************************************************************
;
;       Name: ChangeCmdrName
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.ChangeCmdrName

 JSR CLYNS
 INC YC
 LDA #8
 JSR DETOK_b2
 LDY #6
 STY L0483

.loop_CBB46

 LDA NAME,Y
 STA INWK+5,Y
 DEY
 BPL loop_CBB46
 JSR subm_BA63
 LDA INWK+5
 CMP #$0D
 BEQ CBBB0
 LDY #0

.loop_CBB5A

 LDA INWK+5,Y
 CMP #$0D
 BEQ CBBB6
 INY
 CPY #7
 BNE loop_CBB5A
 DEY

.CBB67

 LDA INWK+5,Y
 STA NAME,Y
 DEY
 BPL CBB67
 LDA COK
 BMI CBBB0
 INY
 LDX language

.loop_CBB79

 LDA NAME,Y
 CMP cheatCmdrName,X
 BNE CBBB0
 INX
 INX
 INX
 INX
 INY
 CPY #7
 BNE loop_CBB79
 LDA #$80
 STA COK
 LDA #$A0
 CLC
 ADC CASH+3
 STA CASH+3
 LDA #$86
 ADC CASH+2
 STA CASH+2
 LDA CASH+1
 ADC #1
 STA CASH+1
 LDA CASH
 ADC #0
 STA CASH

.CBBB0

 JSR CLYNS
 JMP subm_D951

.CBBB6

 LDA #$20
 STA INWK+5,Y
 CPY #6
 BEQ CBB67
 INY
 BNE CBBB6

; ******************************************************************************
;
;       Name: cheatCmdrName
;       Type: Variable
;   Category: Save and load
;    Summary: ???
;
; ******************************************************************************

.cheatCmdrName

 EQUS "CBTI"
 EQUS "HERN"
 EQUS "ETIG"
 EQUS "ARCA"
 EQUS "TUHN"
 EQUS "EGEN"
 EQUS "R RO"

; ******************************************************************************
;
;       Name: SetKeyLogger
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.SetKeyLogger

 TYA
 PHA
 LDX #5
 LDA #0
 STA L0081

.loop_CBBE6

 STA KL,X
 DEX
 BPL loop_CBBE6

 SETUP_PPU_FOR_ICON_BAR ; If the PPU has started drawing the icon bar, configure
                        ; the PPU to use nametable 0 and pattern table 0

 LDA scanController2
 BEQ CBC32
 LDX #$FF
 LDA controller2Down
 BPL CBC08
 STX KY5

.CBC08

 LDA controller2Up
 BPL CBC10
 STX KY6

.CBC10

 LDA controller2Left
 BPL CBC18
 STX KY3

.CBC18

 LDA controller2Right
 BPL CBC20
 STX KY4

.CBC20

 LDA controller2A
 BPL CBC28
 STX KY2

.CBC28

 LDA controller2B
 BPL CBC6B
 STX KL
 BMI CBC6B

.CBC32

 LDX #$FF
 LDA controller1B
 BMI CBC5B
 LDA controller1Down
 BPL CBC41
 STX KY5

.CBC41

 LDA controller1Up
 BPL CBC49
 STX KY6

.CBC49

 LDA controller1Left
 BPL CBC51
 STX KY3

.CBC51

 LDA controller1Right
 BPL CBC6B
 STX KY4
 BMI CBC6B

.CBC5B

 LDA controller1Up
 BPL CBC63
 STX KY2

.CBC63

 LDA controller1Down
 BPL CBC6B
 STX KL

.CBC6B

 LDA controller1A
 CMP #$80
 ROR KY7
 LDX #0
 LDA L0465
 STX L0465
 STA L0081
 PLA
 TAY
 LDA L0081
 TAX
 RTS

; ******************************************************************************
;
;       Name: StartScreen
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.StartScreen

 LDA #$81
 STA L00D6
 LDY #0
 STY L03EE
 JSR subm_BDFC
 LDA #$CF
 JSR TT66_b0
 LDA #$8D
 STA L00D6
 LDA #0
 STA YC
 LDA #7
 STA XC
 LDA #3

IF _PAL

 JSR $F0A1

ENDIF

 LDA #$DF
 STA QQ11
 JSR subm_B96B_b4
 LDA #$24
 STA L00D9
 LDA #$15
 STA YC
 LDA #$0A
 STA XC
 LDA #6

IF _PAL

 JSR $F0A1

ENDIF

 INC YC
 LDA #3
 STA XC
 LDA #9

IF _PAL

 JSR $F0A1

ENDIF

 LDA #$19
 STA YC
 LDA #3
 STA XC
 LDA #$0C
 JSR DETOK_b2
 LDA #$1A
 STA YC
 LDA #6
 STA XC
 LDA #7

IF _PAL

 JSR $F0A1

ENDIF

 LDY #2
 LDA #$E5

.loop_CBCDA

 STA nameBuffer0+896,Y
 INY
 CPY #$20
 BNE loop_CBCDA
 LDA #2
 STA nameBuffer0+864
 STA nameBuffer0+896
 LDA #1
 STA nameBuffer0+865
 STA nameBuffer0+897
 LDY #0

.loop_CBCF4

 JSR subm_BDFC
 LDA LBE2C,Y
 STA XC
 LDA LBE30,Y
 STA YC
 LDA #0
 STA DTW8
 LDA #4
 JSR DETOK_b2
 INC XC
 INC XC
 INY
 LDA LBE4B,Y
 BPL loop_CBCF4
 STY L049F
 LDA #$8D
 STA L00D6
 JSR subm_8926_b0
 LDA controller1Left
 AND controller1Up
 AND controller1Select
 AND controller1B
 BPL CBD3E
 LDA controller1Right
 ORA controller1Down
 ORA controller1Start
 ORA controller1A
 BMI CBD3E
 JSR subm_B818

.CBD3E

 JSR subm_B88C_b6
 LDA #$80
 STA S

IF _NTSC

 LDA #$19

ELIF _PAL

 LDA #$FA

ENDIF

 STA T
 LDA K%+1
 STA V+1
 LDA #0
 STA V
 STA Q
 LDA K%
 STA LASCT

.CBD5A

 JSR KeepPPUTablesAt0
 LDY LASCT
 LDA LBE2C,Y
 ASL A
 ASL A
 ASL A
 ADC #0
 TAX
 CLC
 LDY #0

.loop_CBD6C

 LDA #$F0
 STA ySprite5,Y
 LDA #$FF
 STA tileSprite5,Y
 LDA #$20
 STA attrSprite5,Y
 TXA
 STA xSprite5,Y
 ADC #8
 TAX
 INY
 INY
 INY
 INY
 CPY #$20
 BNE loop_CBD6C
 LDX LASCT
 LDA LBE3C,X
 ASL A
 ASL A
 TAY
 LDA LBE30,X
 ASL A
 ASL A
 ASL A

IF _NTSC

 ADC #6

ELIF _PAL

 ADC #$C

ENDIF

.loop_CBD9B

 STA ySprite5,Y
 DEY
 DEY
 DEY
 DEY
 BPL loop_CBD9B
 LDA controller1Start
 AND #$C0
 CMP #$40
 BNE CBDAF
 LSR S

.CBDAF

 LDX LASCT
 LDA controller1Left
 AND #$C0
 CMP #$40
 BNE CBDC1
 DEX
 LDA K%+1
 STA V+1

.CBDC1

 LDA controller1Right
 AND #$C0
 CMP #$40
 BNE CBDD0
 INX
 LDA K%+1
 STA V+1

.CBDD0

 TXA
 BPL CBDD5
 LDA #0

.CBDD5

 CMP #3
 BCC CBDDB
 LDA #2

.CBDDB

 STA LASCT
 DEC T
 BEQ CBDE5

.CBDE2

 JMP CBD5A

.CBDE5

 INC T
 LDA S
 BPL CBDF9
 DEC V
 BNE CBDE2
 DEC V+1
 BNE CBDE2
 JSR CBDF9
 JMP subm_BF41_b5

.CBDF9

 LDY LASCT

; ******************************************************************************
;
;       Name: subm_BDFC
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.subm_BDFC

 LDA LBE3F,Y
 STA QQ18Lo
 LDA LBE42,Y
 STA QQ18Hi
 LDA LBE45,Y
 STA TKN1Lo
 LDA LBE48,Y
 STA TKN1Hi
 LDA LBE4B,Y
 STA language
 LDA LBE4F,Y
 STA L04A9
 LDA LBE34,Y
 STA L00F9
 LDA LBE38,Y
 STA L03FD
 RTS

; ******************************************************************************
;
;       Name: LBE2C
;       Type: Variable
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.LBE2C

 EQUB $02, $0C, $16, $11                      ; BE2C: 02 0C 16... ...

.LBE30

 EQUB $17, $18, $17, $18                      ; BE30: 17 18 17... ...

.LBE34

 EQUB $5B, $60, $60, $60                      ; BE34: 5B 60 60... [``

.LBE38

 EQUB $2E, $2E, $2C, $2E                      ; BE38: 2E 2E 2C... ..,

.LBE3C

 EQUB $06, $06, $07                           ; BE3C: 06 06 07    ...

.LBE3F

 EQUB $CF, $9C, $4D                           ; BE3F: CF 9C 4D    ..M

.LBE42

 EQUB $A3, $A7, $AC                           ; BE42: A3 A7 AC    ...

.LBE45

 EQUB $0C, $FD, $2C                           ; BE45: 0C FD 2C    ..,

.LBE48

 EQUB $80, $8D, $9A                           ; BE48: 80 8D 9A    ...

.LBE4B

 EQUB $00, $01, $02, $FF                      ; BE4B: 00 01 02... ...

.LBE4F

 EQUB $01, $02, $04                           ; BE4F: 01 02 04    ...

; ******************************************************************************
;
;       Name: subm_BE52
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.subm_BE52

 LDA QQ15+1
 AND #7
 STA QQ3
 LDA QQ15+2
 LSR A
 LSR A
 LSR A
 AND #7
 STA QQ4
 LSR A
 BNE CBE6E
 LDA QQ3
 ORA #2
 STA QQ3

.CBE6E

 LDA QQ3
 EOR #7
 CLC
 STA QQ5
 LDA QQ15+3
 AND #3
 ADC QQ5
 STA QQ5

 SETUP_PPU_FOR_ICON_BAR ; If the PPU has started drawing the icon bar, configure
                        ; the PPU to use nametable 0 and pattern table 0

 LDA QQ4
 LSR A
 ADC QQ5
 STA QQ5
 ASL A
 ASL A
 ADC QQ3
 ADC QQ4
 ADC #1
 STA QQ6
 LDA QQ3
 EOR #7
 ADC #3
 STA P
 LDA QQ4
 ADC #4
 STA Q
 JSR MULTU
 LDA QQ6
 STA Q
 JSR MULTU
 ASL P
 ROL A
 ASL P
 ROL A
 ASL P
 ROL A
 STA QQ7+1
 LDA P
 STA QQ7
 RTS

; ******************************************************************************
;
;       Name: subm_BED2
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.subm_BED2

 JSR SetupPPUForIconBar ; If the PPU has started drawing the icon bar, configure
                        ; the PPU to use nametable 0 and pattern table 0

 LDA #0
 STA nameBuffer0+640
 STA nameBuffer0+672
 STA nameBuffer0+704
 STA nameBuffer0+736
 STA nameBuffer0+768
 STA nameBuffer0+800
 STA nameBuffer0+832
 STA nameBuffer0+864
 STA nameBuffer1+640
 STA nameBuffer1+672
 STA nameBuffer1+704
 STA nameBuffer1+736
 STA nameBuffer1+768
 STA nameBuffer1+800
 STA nameBuffer1+832
 STA nameBuffer1+864
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

IF _NTSC

 EQUW Interrupts+$4000  ; Vector to the NMI handler in case this bank is loaded
                        ; into $C000 during start-up (the handler contains an
                        ; RTI so the interrupt is processed but has no effect)

 EQUW ResetMMC1+$4000   ; Vector to the RESET handler in case this bank is
                        ; loaded into $C000 during start-up (the handler resets
                        ; the MMC1 mapper to map bank 7 into $C000 instead)

 EQUW Interrupts+$4000  ; Vector to the IRQ/BRK handler in case this bank is
                        ; loaded into $C000 during start-up (the handler contains
                        ; an RTI so the interrupt is processed but has no
                        ; effect)

ELIF _PAL

 EQUW NMI               ; Vector to the NMI handler

 EQUW ResetMMC1+$4000   ; Vector to the RESET handler in case this bank is
                        ; loaded into $C000 during start-up (the handler resets
                        ; the MMC1 mapper to map bank 7 into $C000 instead)

 EQUW IRQ               ; Vector to the IRQ/BRK handler

ENDIF

; ******************************************************************************
;
; Save bank6.bin
;
; ******************************************************************************

 PRINT "S.bank6.bin ", ~CODE%, " ", ~P%, " ", ~LOAD%, " ", ~LOAD%
 SAVE "3-assembled-output/bank6.bin", CODE%, P%, LOAD%
