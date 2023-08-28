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
;   * We put the same reset routine (this routine, ResetMMC1) at the start of
;     every ROM bank, so the same routine gets run, whichever ROM bank is mapped
;     to $C000.
;
; This ResetMMC1 routine is therefore called when the NES starts up, whatever
; the bank configuration ends up being. It then switches ROM bank 7 to $C000 and
; jumps into bank 7 at the game's entry point BEGIN, which starts the game.
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
;       Name: Interrupts
;       Type: Subroutine
;   Category: Start and end
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
;       Name: ChooseMusicS
;       Type: Subroutine
;   Category: Sound
;    Summary: A jump table entry at the start of bank 6 for the ChooseMusic
;             routine
;
; ******************************************************************************

.ChooseMusicS

 JMP ChooseMusic        ; Jump to the ChooseMusic routine, returning from the
                        ; subroutine using a tail call

; ******************************************************************************
;
;       Name: PlayMusicS
;       Type: Subroutine
;   Category: Sound
;    Summary: A jump table entry at the start of bank 6 for the PlayMusic
;             routine
;
; ******************************************************************************

.PlayMusicS

 JMP PlayMusic          ; Jump to the PlayMusic routine, returning from the
                        ; subroutine using a tail call

; ******************************************************************************
;
;       Name: StopMusicS
;       Type: Subroutine
;   Category: Sound
;    Summary: A jump table entry at the start of bank 6 for the StopMusic
;             routine
;
; ******************************************************************************

.StopMusicS

 JMP StopMusic          ; Jump to the StopMusic routine, returning from the
                        ; subroutine using a tail call

; ******************************************************************************
;
;       Name: subm_80E5S
;       Type: Subroutine
;   Category: Sound
;    Summary: A jump table entry at the start of bank 6 for the subm_80E5
;             routine
;
; ******************************************************************************

.subm_80E5S

 JMP subm_80E5          ; Jump to the subm_80E5 routine, returning from the
                        ; subroutine using a tail call

; ******************************************************************************
;
;       Name: subm_895AS
;       Type: Subroutine
;   Category: Sound
;    Summary: A jump table entry at the start of bank 6 for the subm_895A
;             routine
;
; ******************************************************************************

.subm_895AS

 JMP subm_895A          ; Jump to the subm_895A routine, returning from the
                        ; subroutine using a tail call

; ******************************************************************************
;
;       Name: subm_89DCS
;       Type: Subroutine
;   Category: Sound
;    Summary: A jump table entry at the start of bank 6 for the subm_89DC
;             routine
;
; ******************************************************************************

.subm_89DCS

 JMP subm_89DC          ; Jump to the subm_89DC routine, returning from the
                        ; subroutine using a tail call

; ******************************************************************************
;
;       Name: subm_8A53S
;       Type: Subroutine
;   Category: Sound
;    Summary: A jump table entry at the start of bank 6 for the subm_8A53
;             routine
;
; ******************************************************************************

.subm_8A53S

 JMP subm_8A53          ; Jump to the subm_8A53 routine, returning from the
                        ; subroutine using a tail call

; ******************************************************************************
;
;       Name: ChooseMusic
;       Type: Subroutine
;   Category: Sound
;    Summary: Set the tune for the background music
;
; ------------------------------------------------------------------------------
;
; Arguments:
;
;   A                   The number of the tune to choose
;
; ******************************************************************************

.ChooseMusic

 TAY
 JSR StopMusicS
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
 STA soundAddr
 LDA L9161,X
 STA L0311
 STA soundAddr+1
 LDA (soundAddr),Y
 STA L030E
 INY
 LDA (soundAddr),Y
 STA L030F
 LDA L9162,X
 STA L0323
 STA soundAddr
 LDA L9163,X
 STA L0324
 STA soundAddr+1
 DEY
 LDA (soundAddr),Y
 STA L0321
 INY
 LDA (soundAddr),Y
 STA L0322
 LDA L9164,X
 STA L0336
 STA soundAddr
 LDA L9165,X
 STA L0337
 STA soundAddr+1
 DEY
 LDA (soundAddr),Y
 STA L0334
 INY
 LDA (soundAddr),Y
 STA L0335
 LDA L9166,X
 STA L0349
 STA soundAddr
 LDA L9167,X
 STA L034A
 STA soundAddr+1
 DEY
 LDA (soundAddr),Y
 STA L0347
 INY
 LDA (soundAddr),Y
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
;   Category: Sound
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
;       Name: StopMusic
;       Type: Subroutine
;   Category: Sound
;    Summary: ???
;
; ******************************************************************************

.StopMusic

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
;   Category: Sound
;    Summary: Play the background music
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
;   Category: Sound
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
;   Category: Sound
;    Summary: ???
;
; ******************************************************************************

.subm_8197

 DEC L0316
 BEQ C819D
 RTS

.C819D

 LDA L030E
 STA soundAddr
 LDA L030F
 STA soundAddr+1
 LDA #0
 STA L0318
 STA L0320

.C81AF

 LDY #0
 LDA (soundAddr),Y
 TAY
 INC soundAddr
 BNE C81BA
 INC soundAddr+1

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

 LDA soundAddr
 STA L030E
 LDA soundAddr+1
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
 STA soundAddr
 LDA L0313
 ADC L0311
 STA soundAddr+1
 LDA L0312
 ADC #2
 STA L0312
 TYA
 ADC L0313
 STA L0313
 LDA (soundAddr),Y
 INY
 ORA (soundAddr),Y
 BNE C8258
 LDA L0310
 STA soundAddr
 LDA L0311
 STA soundAddr+1
 LDA #2
 STA L0312
 LDA #0
 STA L0313

.C8258

 LDA (soundAddr),Y
 TAX
 DEY
 LDA (soundAddr),Y
 STA soundAddr
 STX soundAddr+1
 JMP C81AF

.C8265

 CMP #$F6
 BNE C8277
 LDA (soundAddr),Y
 INC soundAddr
 BNE C8271
 INC soundAddr+1

.C8271

 STA L031F
 JMP C81AF

.C8277

 CMP #$F7
 BNE C828C
 LDA (soundAddr),Y
 INC soundAddr
 BNE C8283
 INC soundAddr+1

.C8283

 STA L031A
 STY L0319
 JMP C81AF

.C828C

 CMP #$FA
 BNE C829E
 LDA (soundAddr),Y
 STA L0317
 INC soundAddr
 BNE C829B
 INC soundAddr+1

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
 LDA (soundAddr),Y
 INC soundAddr
 BNE C82BD
 INC soundAddr+1

.C82BD

 STA L0318
 JMP C81AF

.C82C3

 CMP #$FB
 BNE C82D5
 LDA (soundAddr),Y
 INC soundAddr
 BNE C82CF
 INC soundAddr+1

.C82CF

 STA L030C
 JMP C81AF

.C82D5

 CMP #$FC
 BNE C82E7
 LDA (soundAddr),Y
 INC soundAddr
 BNE C82E1
 INC soundAddr+1

.C82E1

 STA L0314
 JMP C81AF

.C82E7

 CMP #$F5
 BNE C8311
 LDA (soundAddr),Y
 TAX
 STA L0310
 INY
 LDA (soundAddr),Y
 STX soundAddr
 STA soundAddr+1
 STA L0311
 LDA #2
 STA L0312
 DEY
 STY L0313
 LDA (soundAddr),Y
 TAX
 INY
 LDA (soundAddr),Y
 STA soundAddr+1
 STX soundAddr
 JMP C81AF

.C8311

 CMP #$F4
 BNE C8326
 LDA (soundAddr),Y
 INC soundAddr
 BNE C831D
 INC soundAddr+1

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
 JMP StopMusicS

.C8332

 BEQ C8332

; ******************************************************************************
;
;       Name: subm_8334
;       Type: Subroutine
;   Category: Sound
;    Summary: ???
;
; ******************************************************************************

.subm_8334

 LDA L0320
 BEQ C836A
 LDX L031F
 LDA L902C,X
 STA soundAddr
 LDA L9040,X
 STA soundAddr+1
 LDY #0
 LDA (soundAddr),Y
 STA L031D
 LDY L031C
 LDA (soundAddr),Y
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
 STA soundAddr
 LDA L9121,X
 STA soundAddr+1
 LDY L0319
 LDA (soundAddr),Y
 CMP #$80
 BNE C8387
 LDY #0
 STY L0319
 LDA (soundAddr),Y

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
;   Category: Sound
;    Summary: ???
;
; ******************************************************************************

.subm_8392

 DEC L0329
 BEQ C8398
 RTS

.C8398

 LDA L0321
 STA soundAddr
 LDA L0322
 STA soundAddr+1
 LDA #0
 STA L032B
 STA L0333

.C83AA

 LDY #0
 LDA (soundAddr),Y
 TAY
 INC soundAddr
 BNE C83B5
 INC soundAddr+1

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

 LDA soundAddr
 STA L0321
 LDA soundAddr+1
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
 STA soundAddr
 LDA L0326
 ADC L0324
 STA soundAddr+1
 LDA L0325
 ADC #2
 STA L0325
 TYA
 ADC L0326
 STA L0326
 LDA (soundAddr),Y
 INY
 ORA (soundAddr),Y
 BNE C8453
 LDA L0323
 STA soundAddr
 LDA L0324
 STA soundAddr+1
 LDA #2
 STA L0325
 LDA #0
 STA L0326

.C8453

 LDA (soundAddr),Y
 TAX
 DEY
 LDA (soundAddr),Y
 STA soundAddr
 STX soundAddr+1
 JMP C83AA

.C8460

 CMP #$F6
 BNE C8472
 LDA (soundAddr),Y
 INC soundAddr
 BNE C846C
 INC soundAddr+1

.C846C

 STA L0332
 JMP C83AA

.C8472

 CMP #$F7
 BNE C8487
 LDA (soundAddr),Y
 INC soundAddr
 BNE C847E
 INC soundAddr+1

.C847E

 STA L032D
 STY L032C
 JMP C83AA

.C8487

 CMP #$FA
 BNE C8499
 LDA (soundAddr),Y
 STA L032A
 INC soundAddr
 BNE C8496
 INC soundAddr+1

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
 LDA (soundAddr),Y
 INC soundAddr
 BNE C84B8
 INC soundAddr+1

.C84B8

 STA L032B
 JMP C83AA

.C84BE

 CMP #$FB
 BNE C84D0
 LDA (soundAddr),Y
 INC soundAddr
 BNE C84CA
 INC soundAddr+1

.C84CA

 STA L030C
 JMP C83AA

.C84D0

 CMP #$FC
 BNE C84E2
 LDA (soundAddr),Y
 INC soundAddr
 BNE C84DC
 INC soundAddr+1

.C84DC

 STA L0327
 JMP C83AA

.C84E2

 CMP #$F5
 BNE C850C
 LDA (soundAddr),Y
 TAX
 STA L0323
 INY
 LDA (soundAddr),Y
 STX soundAddr
 STA soundAddr+1
 STA L0324
 LDA #2
 STA L0325
 DEY
 STY L0326
 LDA (soundAddr),Y
 TAX
 INY
 LDA (soundAddr),Y
 STA soundAddr+1
 STX soundAddr
 JMP C83AA

.C850C

 CMP #$F4
 BNE C8521
 LDA (soundAddr),Y
 INC soundAddr
 BNE C8518
 INC soundAddr+1

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
 JMP StopMusicS

.C852D

 BEQ C852D

; ******************************************************************************
;
;       Name: subm_852F
;       Type: Subroutine
;   Category: Sound
;    Summary: ???
;
; ******************************************************************************

.subm_852F

 LDA L0333
 BEQ C8565
 LDX L0332
 LDA L902C,X
 STA soundAddr
 LDA L9040,X
 STA soundAddr+1
 LDY #0
 LDA (soundAddr),Y
 STA L0330
 LDY L032F
 LDA (soundAddr),Y
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
 STA soundAddr
 LDA L9121,X
 STA soundAddr+1
 LDY L032C
 LDA (soundAddr),Y
 CMP #$80
 BNE C8582
 LDY #0
 STY L032C
 LDA (soundAddr),Y

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
;   Category: Sound
;    Summary: ???
;
; ******************************************************************************

.subm_858D

 DEC L033C
 BEQ C8593
 RTS

.C8593

 LDA L0334
 STA soundAddr
 LDA L0335
 STA soundAddr+1

.C859D

 LDY #0
 LDA (soundAddr),Y
 TAY
 INC soundAddr
 BNE C85A8
 INC soundAddr+1

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

 LDA soundAddr
 STA L0334
 LDA soundAddr+1
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
 STA soundAddr
 LDA L0339
 ADC L0337
 STA soundAddr+1
 LDA L0338
 ADC #2
 STA L0338
 TYA
 ADC L0339
 STA L0339
 LDA (soundAddr),Y
 INY
 ORA (soundAddr),Y
 BNE C8636
 LDA L0336
 STA soundAddr
 LDA L0337
 STA soundAddr+1
 LDA #2
 STA L0338
 LDA #0
 STA L0339

.C8636

 LDA (soundAddr),Y
 TAX
 DEY
 LDA (soundAddr),Y
 STA soundAddr
 STX soundAddr+1
 JMP C859D

.C8643

 CMP #$F6
 BNE C8655
 LDA (soundAddr),Y
 INC soundAddr
 BNE C864F
 INC soundAddr+1

.C864F

 STA L0345
 JMP C859D

.C8655

 CMP #$F7
 BNE C866A
 LDA (soundAddr),Y
 INC soundAddr
 BNE C8661
 INC soundAddr+1

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
 LDA (soundAddr),Y
 INC soundAddr
 BNE C8689
 INC soundAddr+1

.C8689

 STA L030C
 JMP C859D

.C868F

 CMP #$FC
 BNE C86A1
 LDA (soundAddr),Y
 INC soundAddr
 BNE C869B
 INC soundAddr+1

.C869B

 STA L033A
 JMP C859D

.C86A1

 CMP #$F5
 BNE C86CB
 LDA (soundAddr),Y
 TAX
 STA L0336
 INY
 LDA (soundAddr),Y
 STX soundAddr
 STA soundAddr+1
 STA L0337
 LDA #2
 STA L0338
 DEY
 STY L0339
 LDA (soundAddr),Y
 TAX
 INY
 LDA (soundAddr),Y
 STA soundAddr+1
 STX soundAddr
 JMP C859D

.C86CB

 CMP #$F4
 BNE C86E0
 LDA (soundAddr),Y
 INC soundAddr
 BNE C86D7
 INC soundAddr+1

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
 JMP StopMusicS

.C86EC

 BEQ C86EC

; ******************************************************************************
;
;       Name: subm_86EE
;       Type: Subroutine
;   Category: Sound
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
 STA soundAddr
 LDA L9121,X
 STA soundAddr+1
 LDY L033F
 LDA (soundAddr),Y
 CMP #$80
 BNE C871A
 LDY #0
 STY L033F
 LDA (soundAddr),Y

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
;   Category: Sound
;    Summary: ???
;
; ******************************************************************************

.subm_8725

 DEC L034F
 BEQ C872B
 RTS

.C872B

 LDA L0347
 STA soundAddr
 LDA L0348
 STA soundAddr+1
 STA L0359

.C8738

 LDY #0
 LDA (soundAddr),Y
 TAY
 INC soundAddr
 BNE C8743
 INC soundAddr+1

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
 LDA soundAddr
 STA L0347
 LDA soundAddr+1
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
 STA soundAddr
 LDA L034C
 ADC L034A
 STA soundAddr+1
 LDA L034B
 ADC #2
 STA L034B
 TYA
 ADC L034C
 STA L034C
 LDA (soundAddr),Y
 INY
 ORA (soundAddr),Y
 BNE C87C9
 LDA L0349
 STA soundAddr
 LDA L034A
 STA soundAddr+1
 LDA #2
 STA L034B
 LDA #0
 STA L034C

.C87C9

 LDA (soundAddr),Y
 TAX
 DEY
 LDA (soundAddr),Y
 STA soundAddr
 STX soundAddr+1
 JMP C8738

.C87D6

 CMP #$F6
 BNE C87E8
 LDA (soundAddr),Y
 INC soundAddr
 BNE C87E2
 INC soundAddr+1

.C87E2

 STA L0358
 JMP C8738

.C87E8

 CMP #$F7
 BNE C87FD
 LDA (soundAddr),Y
 INC soundAddr
 BNE C87F4
 INC soundAddr+1

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
 LDA (soundAddr),Y
 TAX
 STA L0349
 INY
 LDA (soundAddr),Y
 STX soundAddr
 STA soundAddr+1
 STA L034A
 LDA #2
 STA L034B
 DEY
 STY L034C
 LDA (soundAddr),Y
 TAX
 INY
 LDA (soundAddr),Y
 STA soundAddr+1
 STX soundAddr
 JMP C8738

.C883A

 CMP #$F4
 BNE C884F
 LDA (soundAddr),Y
 INC soundAddr
 BNE C8846
 INC soundAddr+1

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
 JMP StopMusicS

.C885B

 BEQ C885B

.C885D

 LDA L0359
 BEQ C8892
 LDX L0358
 LDA L902C,X
 STA soundAddr
 LDA L9040,X
 STA soundAddr+1
 LDY #0
 LDA (soundAddr),Y
 STA L0356
 LDY L0355
 LDA (soundAddr),Y
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
 STA soundAddr
 LDA L9121,X
 STA soundAddr+1
 LDY L0352
 LDA (soundAddr),Y
 CMP #$80
 BNE C88AF
 LDY #0
 STY L0352
 LDA (soundAddr),Y

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
;   Category: Sound
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
;   Category: Sound
;    Summary: ???
;
; ******************************************************************************

.subm_895A

 ASL A
 TAY
 LDA #0
 STA L0302
 LDA L8D7A,Y
 STA soundAddr
 LDA L8D7A+1,Y
 STA soundAddr+1
 LDY #$0D

.loop_C896D

 LDA (soundAddr),Y
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
 STA soundAddr
 LDA L8F7A+1,Y
 STA L0448
 STA soundAddr+1
 LDY #0
 STY L041D
 LDA (soundAddr),Y
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
;       Name: MakeNoise
;       Type: Subroutine
;   Category: Sound
;    Summary: ???
;
; ******************************************************************************

.MakeNoise

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
;   Category: Sound
;    Summary: ???
;
; ******************************************************************************

.subm_89DC

 ASL A
 TAY
 LDA #0
 STA L0303
 LDA L8D7A,Y
 STA soundAddr
 LDA L8D7A+1,Y
 STA soundAddr+1
 LDY #$0D

.loop_C89EF

 LDA (soundAddr),Y
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
 STA soundAddr
 LDA L8F7A+1,Y
 STA L044A
 STA soundAddr+1
 LDY #0
 STY L0431
 LDA (soundAddr),Y
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
;   Category: Sound
;    Summary: ???
;
; ******************************************************************************

.subm_8A53

 ASL A
 TAY
 LDA #0
 STA L0304
 LDA L8D7A,Y
 STA soundAddr
 LDA L8D7A+1,Y
 STA soundAddr+1
 LDY #$0D

.loop_C8A66

 LDA (soundAddr),Y
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
 STA soundAddr
 LDA L8F7A+1,Y
 STA L044C
 STA soundAddr+1
 LDY #0
 STY L0445
 LDA (soundAddr),Y
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
;   Category: Sound
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
;   Category: Sound
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
 STA soundAddr
 LDA L0448
 STA soundAddr+1
 LDA (soundAddr),Y
 BPL C8B2F
 CMP #$80
 BNE C8B39
 LDY #0
 LDA (soundAddr),Y

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
;   Category: Sound
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
 STA soundAddr
 LDA L044A
 STA soundAddr+1
 LDA (soundAddr),Y
 BPL C8C16
 CMP #$80
 BNE C8C20
 LDY #0
 LDA (soundAddr),Y

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
;   Category: Sound
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
 STA soundAddr
 LDA L044C
 STA soundAddr+1
 LDA (soundAddr),Y
 BPL C8CF7
 CMP #$80
 BNE C8D01
 LDY #0
 LDA (soundAddr),Y

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
;   Category: Sound
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
;   Category: Sound
;    Summary: ???
;
; ******************************************************************************

.L8D7A

 EQUW L8D7A_1
 EQUW L8D7A_2
 EQUW L8D7A_3
 EQUW L8D7A_4
 EQUW L8D7A_5
 EQUW L8D7A_6
 EQUW L8D7A_7
 EQUW L8D7A_8
 EQUW L8D7A_9
 EQUW L8D7A_10
 EQUW L8D7A_11
 EQUW L8D7A_12
 EQUW L8D7A_13
 EQUW L8D7A_14
 EQUW L8D7A_15
 EQUW L8D7A_16
 EQUW L8D7A_17
 EQUW L8D7A_18
 EQUW L8D7A_19
 EQUW L8D7A_20
 EQUW L8D7A_21
 EQUW L8D7A_22
 EQUW L8D7A_23
 EQUW L8D7A_24
 EQUW L8D7A_25
 EQUW L8D7A_26
 EQUW L8D7A_27
 EQUW L8D7A_28
 EQUW L8D7A_29
 EQUW L8D7A_30
 EQUW L8D7A_31
 EQUW L8D7A_32

.L8D7A_1

 EQUB $3C, $03, $04, $00, $02, $00, $30, $00
 EQUB $01, $0A, $00, $05, $00, $63

.L8D7A_2

 EQUB $16, $04
 EQUB $A8, $00, $04, $00, $70, $00, $FF, $63
 EQUB $0C, $02, $00, $00

.L8D7A_3

 EQUB $19, $19, $AC, $03
 EQUB $1C, $00, $30, $00, $01, $63, $06, $02
 EQUB $FF, $00

.L8D7A_4

 EQUB $05, $63, $2C, $00, $00, $00
 EQUB $70, $00, $00, $63, $0C, $01, $00, $00

.L8D7A_5

 EQUB $09, $63, $57, $02, $02, $00, $B0, $00
 EQUB $FF, $63, $08, $01, $00, $00

.L8D7A_6

 EQUB $0A, $02
 EQUB $18, $00, $01, $00, $30, $FF, $FF, $0A
 EQUB $0C, $01, $00, $00

.L8D7A_7

 EQUB $0D, $02, $28, $00
 EQUB $01, $00, $70, $FF, $FF, $0A, $0C, $01
 EQUB $00, $00

.L8D7A_8

 EQUB $19, $1C, $00, $01, $06, $00
 EQUB $70, $00, $01, $63, $06, $02, $00, $00

.L8D7A_9

 EQUB $5A, $09, $14, $00, $01, $00, $30, $00
 EQUB $FF, $63, $00, $0B, $00, $00

.L8D7A_10

 EQUB $46, $28
 EQUB $02, $00, $01, $00, $30, $00, $FF, $00
 EQUB $08, $06, $00, $03

.L8D7A_11

 EQUB $0E, $03, $6C, $00
 EQUB $21, $00, $B0, $00, $FF, $63, $0C, $02
 EQUB $00, $00

.L8D7A_12

 EQUB $13, $0F, $08, $00, $01, $00
 EQUB $30, $00, $FF, $00, $0C, $03, $00, $02

.L8D7A_13

 EQUB $AA, $78, $1F, $00, $01, $00, $30, $00
 EQUB $01, $00, $01, $08, $00, $0A

.L8D7A_14

 EQUB $59, $02
 EQUB $4F, $00, $29, $00, $B0, $FF, $01, $FF
 EQUB $00, $09, $00, $00

.L8D7A_15

 EQUB $19, $05, $82, $01
 EQUB $29, $00, $B0, $FF, $FF, $FF, $08, $02
 EQUB $00, $00

.L8D7A_16

 EQUB $22, $05, $82, $01, $29, $00
 EQUB $B0, $FF, $FF, $FF, $08, $03, $00, $00

.L8D7A_17

 EQUB $0F, $63, $B0, $00, $20, $00, $70, $00
 EQUB $FF, $63, $08, $02, $00, $00

.L8D7A_18

 EQUB $0D, $63
 EQUB $8F, $01, $31, $00, $30, $00, $FF, $63
 EQUB $10, $02, $00, $00

.L8D7A_19

 EQUB $18, $05, $FF, $01
 EQUB $31, $00, $30, $00, $FF, $63, $10, $03
 EQUB $00, $00

.L8D7A_20

 EQUB $46, $03, $42, $03, $29, $00
 EQUB $B0, $00, $FF, $FF, $0C, $06, $00, $00

.L8D7A_21

 EQUB $0C, $02, $57, $00, $14, $00, $B0, $00
 EQUB $FF, $63, $0C, $01, $00, $00

.L8D7A_22

 EQUB $82, $46
 EQUB $0F, $00, $01, $00, $B0, $00, $01, $00
 EQUB $01, $07, $00, $05

.L8D7A_23

 EQUB $82, $46, $00, $00
 EQUB $01, $00, $B0, $00, $FF, $00, $01, $07
 EQUB $00, $05

.L8D7A_24

 EQUB $19, $05, $82, $01, $29, $00
 EQUB $B0, $FF, $FF, $FF, $0E, $02, $00, $00

.L8D7A_25

 EQUB $AA, $78, $1F, $00, $01, $00, $30, $00
 EQUB $01, $00, $01, $08, $00, $0A

.L8D7A_26

 EQUB $14, $03
 EQUB $08, $00, $01, $00, $30, $00, $FF, $FF
 EQUB $00, $02, $00, $00

.L8D7A_27

 EQUB $01, $00, $00, $00
 EQUB $00, $00, $30, $00, $00, $00, $0D, $00
 EQUB $00, $00

.L8D7A_28

 EQUB $19, $05, $82, $01, $29, $00
 EQUB $B0, $FF, $FF, $FF, $0F, $02, $00, $00

.L8D7A_29

 EQUB $0B, $04, $42, $00, $08, $00, $B0, $00
 EQUB $01, $63, $08, $01, $00, $02

.L8D7A_30

 EQUB $96, $1C
 EQUB $00, $01, $06, $00, $70, $00, $01, $63
 EQUB $06, $02, $00, $00

.L8D7A_31

 EQUB $96, $1C, $00, $01
 EQUB $06, $00, $70, $00, $01, $63, $06, $02
 EQUB $00, $00

.L8D7A_32

 EQUB $14, $02, $28, $00, $01, $00
 EQUB $70, $FF, $FF, $0A, $00, $02, $00, $00

; ******************************************************************************
;
;       Name: L8F7A
;       Type: Variable
;   Category: Sound
;    Summary: ???
;
; ******************************************************************************

.L8F7A

 EQUW L8F7A_1
 EQUW L8F7A_2
 EQUW L8F7A_3
 EQUW L8F7A_4
 EQUW L8F7A_5
 EQUW L8F7A_6
 EQUW L8F7A_7
 EQUW L8F7A_8
 EQUW L8F7A_9
 EQUW L8F7A_10
 EQUW L8F7A_11
 EQUW L8F7A_12
 EQUW L8F7A_13
 EQUW L8F7A_14
 EQUW L8F7A_15
 EQUW L8F7A_16
 EQUW L8F7A_17

.L8F7A_1

 EQUB $0F, $0D, $0B, $09, $07, $05  ; 8F9A: 1D 90 0F... ...
 EQUB $03, $01, $00, $FF

.L8F7A_2

 EQUB $03, $05, $07, $09  ; 8FA2: 03 01 00... ...
 EQUB $0A, $0C, $0E, $0E, $0E, $0C, $0C, $0A  ; 8FAA: 0A 0C 0E... ...
 EQUB $0A, $09, $09, $07, $06, $05, $04, $03  ; 8FB2: 0A 09 09... ...
 EQUB $02, $02, $01, $FF

.L8F7A_3

 EQUB $02, $06, $08, $00  ; 8FBA: 02 02 01... ...
 EQUB $FF

.L8F7A_4

 EQUB $06, $08, $0A, $0B, $0C, $0B, $0A  ; 8FC2: FF 06 08... ...
 EQUB $09, $08, $07, $06, $05, $04, $03, $02  ; 8FCA: 09 08 07... ...
 EQUB $01, $FF

.L8F7A_5

 EQUB $01, $03, $06, $08, $0C, $80  ; 8FD2: 01 FF 01... ...

.L8F7A_6

 EQUB $01, $04, $09, $0D, $80

.L8F7A_7

 EQUB $01, $04, $07  ; 8FDA: 01 04 09... ...
 EQUB $09, $FF

.L8F7A_8

 EQUB $09, $80

.L8F7A_9

 EQUB $0E, $0C, $0B, $09  ; 8FE2: 09 FF 09... ...
 EQUB $07, $05, $04, $03, $02, $01, $FF

.L8F7A_10

 EQUB $0C  ; 8FEA: 07 05 04... ...
 EQUB $00, $00, $0C, $00, $00, $FF

.L8F7A_11

 EQUB $0B, $80  ; 8FF2: 00 00 0C... ...

.L8F7A_12

 EQUB $0A, $0B, $0C, $0D, $0C, $80

.L8F7A_13

 EQUB $0C, $0A  ; 8FFA: 0A 0B 0C... ...
 EQUB $09, $07, $05, $04, $03, $02, $01, $FF  ; 9002: 09 07 05... ...

.L8F7A_14

 EQUB $00, $FF

.L8F7A_15

 EQUB $04, $05, $06, $06, $05, $04  ; 900A: 00 FF 04... ...
 EQUB $03, $02, $01, $FF

.L8F7A_16

 EQUB $06, $05, $04, $03  ; 9012: 03 02 01... ...
 EQUB $02, $01, $FF

.L8F7A_17

 EQUB $0C, $0A, $09, $07, $05  ; 901A: 02 01 FF... ...
 EQUB $05, $04, $04, $03, $03, $02, $02, $01  ; 9022: 05 04 04... ...
 EQUB $01, $FF                                ; 902A: 01 FF       ..

; ******************************************************************************
;
;       Name: L902C
;       Type: Variable
;   Category: Sound
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
;   Category: Sound
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
;   Category: Sound
;    Summary: ???
;
; ******************************************************************************

.L9119

 EQUB $29, $2B, $34, $39, $3E, $44, $4D, $56  ; 9119: 29 2B 34... )+4

; ******************************************************************************
;
;       Name: L9121
;       Type: Variable
;   Category: Sound
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
;   Category: Sound
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
;       Name: DrawGlasses
;       Type: Subroutine
;   Category: Status
;    Summary: Draw a pair of dark glasses on the commander image
;
; ******************************************************************************

.DrawGlasses

 LDA #104               ; Set the tile pattern number for sprite 8 to 104, which
 STA tileSprite8        ; is the left part of the dark glasses

 LDA #%00000000         ; Set the attributes for sprite 8 as follows:
 STA attrSprite8        ;
                        ;     * Bits 0-1    = sprite palette 0
                        ;     * Bit 5 clear = show in front of background
                        ;     * Bit 6 clear = do not flip horizontally
                        ;     * Bit 7 clear = do not flip vertically

 LDA #203               ; Set the x-coordinate for sprite 8 to 203
 STA xSprite8

 LDA languageNumber     ; If bit 2 of languageNumber is clear then the chosen
 AND #%00000100         ; language is not French, so jump to glas1 with A = 0
 BEQ glas1

 LDA #16                ; The chosen language is French, so the commander image
                        ; is 16 pixels lower down the screen, so set A = 16 to
                        ; add to the y-coordinate of the glasses

.glas1

 CLC                    ; Set the y-coordinate for sprite 8 to 90, plus the
 ADC #90+YPAL           ; margin we just set in A
 STA ySprite8

 LDA #105               ; Set the tile pattern number for sprite 9 to 105, which
 STA tileSprite9        ; is the middle part of the dark glasses

 LDA #%00000000         ; Set the attributes for sprite 9 as follows:
 STA attrSprite9        ;
                        ;     * Bits 0-1    = sprite palette 0
                        ;     * Bit 5 clear = show in front of background
                        ;     * Bit 6 clear = do not flip horizontally
                        ;     * Bit 7 clear = do not flip vertically

 LDA #211               ; Set the x-coordinate for sprite 9 to 211
 STA xSprite9

 LDA languageNumber     ; If bit 2 of languageNumber is clear then the chosen
 AND #%00000100         ; language is not French, so jump to glas2 with A = 0
 BEQ glas2

 LDA #16                ; The chosen language is French, so the commander image
                        ; is 16 pixels lower down the screen, so set A = 16 to
                        ; add to the y-coordinate of the glasses

.glas2

 CLC                    ; Set the y-coordinate for sprite 9 to 90, plus the
 ADC #90+YPAL           ; margin we just set in A
 STA ySprite9

 LDA #106               ; Set the tile pattern number for sprite 10 to 106,
 STA tileSprite10       ; which is the right part of the dark glasses

 LDA #%00000000         ; Set the attributes for sprite 10 as follows:
 STA attrSprite10       ;
                        ;     * Bits 0-1    = sprite palette 0
                        ;     * Bit 5 clear = show in front of background
                        ;     * Bit 6 clear = do not flip horizontally
                        ;     * Bit 7 clear = do not flip vertically

 LDA #219               ; Set the x-coordinate for sprite 10 to 219
 STA xSprite10

 LDA languageNumber     ; If bit 2 of languageNumber is clear then the chosen
 AND #%00000100         ; language is not French, so jump to glas3 with A = 0
 BEQ glas3

 LDA #16                ; The chosen language is French, so the commander image
                        ; is 16 pixels lower down the screen, so set A = 16 to
                        ; add to the y-coordinate of the glasses

.glas3

 CLC                    ; Set the y-coordinate for sprite 10 to 90, plus the
 ADC #90+YPAL           ; margin we just set in A
 STA ySprite10

 RTS                    ; Return from the subroutine

; ******************************************************************************
;
;       Name: DrawRightEarring
;       Type: Subroutine
;   Category: Status
;    Summary: Draw an earring in the commander's right ear (i.e. on the left
;             side of the commander image
;
; ******************************************************************************

.DrawRightEarring

 LDA #107               ; Set the tile pattern number for sprite 11 to 107,
 STA tileSprite11       ; which is the right earring

 LDA #%00000010         ; Set the attributes for sprite 11 as follows:
 STA attrSprite11       ;
                        ;     * Bits 0-1    = sprite palette 2
                        ;     * Bit 5 clear = show in front of background
                        ;     * Bit 6 clear = do not flip horizontally
                        ;     * Bit 7 clear = do not flip vertically

 LDA #195               ; Set the x-coordinate for sprite 11 to 195
 STA xSprite11

 LDA languageNumber     ; If bit 2 of languageNumber is clear then the chosen
 AND #%00000100         ; language is not French, so jump to earr1 with A = 0
 BEQ earr1

 LDA #16                ; The chosen language is French, so the commander image
                        ; is 16 pixels lower down the screen, so set A = 16 to
                        ; add to the y-coordinate of the earring

.earr1

 CLC                    ; Set the y-coordinate for sprite 11 to 98, plus the
 ADC #98+YPAL           ; margin we just set in A
 STA ySprite11

 RTS                    ; Return from the subroutine

; ******************************************************************************
;
;       Name: DrawLeftEarring
;       Type: Subroutine
;   Category: Status
;    Summary: Draw an earring in the commander's left ear (i.e. on the right
;             side of the commander image
;
; ******************************************************************************

.DrawLeftEarring

 LDA #108               ; Set the tile pattern number for sprite 12 to 108,
 STA tileSprite12       ; which is the left earring

 LDA #%00000010         ; Set the attributes for sprite 12 as follows:
 STA attrSprite12       ;
                        ;     * Bits 0-1    = sprite palette 2
                        ;     * Bit 5 clear = show in front of background
                        ;     * Bit 6 clear = do not flip horizontally
                        ;     * Bit 7 clear = do not flip vertically

 LDA #227               ; Set the x-coordinate for sprite 12 to 227
 STA xSprite12

 LDA languageNumber     ; If bit 2 of languageNumber is clear then the chosen
 AND #%00000100         ; language is not French, so jump to earl1 with A = 0
 BEQ earl1

 LDA #16                ; The chosen language is French, so the commander image
                        ; is 16 pixels lower down the screen, so set A = 16 to
                        ; add to the y-coordinate of the earring

.earl1

 CLC                    ; Set the y-coordinate for sprite 12 to 98, plus the
 ADC #98+YPAL           ; margin we just set in A
 STA ySprite12

 RTS                    ; Return from the subroutine

; ******************************************************************************
;
;       Name: DrawMedallion
;       Type: Subroutine
;   Category: Status
;    Summary: Draw a medallion on the commander image
;
; ******************************************************************************

.DrawMedallion

                        ; We draw the medallion image from sprites with
                        ; sequential patterns, so first we configure the
                        ; variables to pass to the DrawSpriteImage routine

 LDA #3                 ; Set K = 5, to pass as the number of columns in the
 STA K                  ; image to DrawSpriteImage below

 LDA #2                 ; Set K+1 = 2, to pass as the number of rows in the
 STA K+1                ; image to DrawSpriteImage below

 LDA #111               ; Set K+2 = 111, so we draw the medallion using pattern
 STA K+2                ; #111 onwards

 LDA #15                ; Set K+3 = 15, so we build the image from sprite 15
 STA K+3                ; onwards

 LDX #11                ; Set X = 11 so we draw the image 11 pixels into the
                        ; (XC, YC) character block along the x-axis

 LDY #49                ; Set Y = 49 so we draw the image 49 pixels into the
                        ; (XC, YC) character block along the y-axis

 LDA #%00000010         ; Set the attributes for the sprites we create in the
                        ; DrawSpriteImage routine as follows:
                        ;
                        ;     * Bits 0-1    = sprite palette 2
                        ;     * Bit 5 clear = show in front of background
                        ;     * Bit 6 clear = do not flip horizontally
                        ;     * Bit 7 clear = do not flip vertically

 JMP DrawSpriteImage+2  ; Draw the medallion image from sprites, using pattern
                        ; #111 onwards and the sprite attributes in A

; ******************************************************************************
;
;       Name: DrawCmdrImage
;       Type: Subroutine
;   Category: Status
;    Summary: Draw the commander image as a coloured face image in front of a
;             greyscale headshot image, with optional embellishments
;
; ******************************************************************************

.DrawCmdrImage

                        ; The commander image is made up of two layers and some
                        ; optional embellishments:
                        ;
                        ;   * A greyscale headshot (i.e. the head and shoulders)
                        ;     that's displayed as a background using the
                        ;     nametable tiles, whose patterns are extracted into
                        ;     the pattern buffers by the GetHeadshot routine
                        ;
                        ;   * A colourful face that's displayed in the
                        ;     foreground as a set of sprites, whose patterns are
                        ;     sent to the PPU by the GetCmdrImage routine, from
                        ;     pattern 69 onwards
                        ;
                        ;   * A pair of dark glasses (if we are a fugitive)
                        ;
                        ;   * Left and right earrings and a medallion, depending
                        ;     on how rich we are
                        ;
                        ; We start by drawing the background into the nametable
                        ; buffers

 LDX #6                 ; Set X = 6 to use as the number of columns in the image

 LDY #8                 ; Set Y = 8 to use as the number of rows in the image

 STX K                  ; Set K = X, so we can pass the number of columns in the
                        ; image to DrawBackground below

 STY K+1                ; Set K+1 = Y, so we can pass the number of rows in the
                        ; image to DrawBackground below

 LDA firstFreeTile      ; Set pictureTile to the number of the next free tile in
 STA pictureTile        ; firstFreeTile
                        ;
                        ; We use this when setting K+2 below, so the call to
                        ; DrawBackground displays the tiles at pictureTile, and
                        ; it's also used to specify where to load the system
                        ; image data when we call GetCmdrImage from
                        ; SendViewToPPU when showing the Status screen

 CLC                    ; Add 48 to firstFreeTile, as we are going to use 48
 ADC #48                ; tiles for the system image (8 rows of 6 tiles)
 STA firstFreeTile

 LDX pictureTile        ; Set K+2 to the value we stored above, so K+2 is the
 STX K+2                ; number of the first pattern to use for the commander
                        ; image's greyscale headshot

 JSR DrawBackground_b3  ; Draw the background by writing the the nametable
                        ; buffer entries for the greyscale part of the commander
                        ; image (this is the image that is extracted into the
                        ; pattern buffers by the GetHeadshot routine)

                        ; Now that the background is drawn, we move on to the
                        ; sprite-based foreground, which contains the face image
                        ;
                        ; We draw the face image from sprites with sequential
                        ; patterns, so now we configure the variables to pass
                        ; to the DrawSpriteImage routine

 LDA #5                 ; Set K = 5, to pass as the number of columns in the
 STA K                  ; image to DrawSpriteImage below

 LDA #7                 ; Set K+1 = 7, to pass as the number of rows in the
 STA K+1                ; image to DrawSpriteImage below

 LDA #69                ; Set K+2 = 69, so we draw the face image using
 STA K+2                ; pattern 69 onwards

 LDA #20                ; Set K+3 = 20, so we build the image from sprite 20
 STA K+3                ; onwards

 LDX #4                 ; Set X = 4 so we draw the image four pixels into the
                        ; (XC, YC) character block along the x-axis

 LDY #0                 ; Set Y = 0 so we draw the image at the top of the
                        ; (XC, YC) character block along the y-axis

 JSR DrawSpriteImage_b6 ; Draw the face image from sprites, using pattern 69
                        ; onwards

                        ; Next, we draw a pair of smooth-criminal dark glasses
                        ; in front of the face if we have got a criminal record

 LDA FIST               ; If our legal status in FIST is less than 40, then we
 CMP #40                ; are either clean or an offender, so jump to cmdr1 to
 BCC cmdr1              ; skip the following instruction, as we aren't bad
                        ; enough to wear shades

 JSR DrawGlasses        ; If we get here then we are a fugitive, so draw a pair
                        ; of dark glasses in front of the face

.cmdr1

                        ; We now embellish the commander image, depending on how
                        ; much cash we have
                        ;
                        ; Note that the CASH amount is stored as a big-endian
                        ; four-byte number with the most significant byte first,
                        ; i.e. as CASH(0 1 2 3)

 LDA CASH               ; If CASH >= &01000000 (1,677,721.6 CR), jump to cmdr2
 BNE cmdr2

 LDA CASH+1             ; If CASH >= &00990000 (1,002,700.8 CR), jump to cmdr2
 CMP #$99
 BCS cmdr2

 CMP #0                 ; If CASH >= &00010000 (6,553.6 CR), jump to cmdr3
 BNE cmdr3

 LDA CASH+2             ; If CASH >= &00004F00 (2,022.4 CR), jump to cmdr3
 CMP #$4F
 BCS cmdr3

 CMP #$28               ; If CASH < &00002800 (1,024.0 CR), jump to cmdr5
 BCC cmdr5

 BCS cmdr4              ; Jump to cmdr4 (this BCS is effectively a JMP as we
                        ; just passed through a BCC)

.cmdr2

 JSR DrawMedallion      ; If we get here then we have more than 1,002,700.8 CR,
                        ; so call DrawMedallion to draw a medallion on the
                        ; commander image

.cmdr3

 JSR DrawRightEarring   ; If we get here then we have more than 2,022.4 CR, so
                        ; call DrawLeftEarring to draw an earring in the
                        ; commander's right ear (i.e. on the left side of the
                        ; commander image

.cmdr4

 JSR DrawLeftEarring    ; If we get here then we have more than 1,024.0 CR, so
                        ; call DrawRightEarring to draw an earring in the
                        ; commander's left ear (i.e. on the right side of the
                        ; commander image
.cmdr5

 LDX XC                 ; We just drew the image at (XC, YC), so decrement them
 DEX                    ; both so we can pass (XC, YC) to the DrawImageFrame
 STX XC                 ; routine to draw a frame around the image, with the
 LDX YC                 ; top-left corner one block up and left from the image
 DEX                    ; corner
 STX YC

 LDA #7                 ; Set K = 7 to pass to the DrawImageFrame routine as the
 STA K                  ; frame width minus 1, so the frame is eight tiles wide,
                        ; to cover the image which is six tiles wide

 LDA #10                ; Set K+1 = 10 to pass to the DrawImageFrame routine as
 STA K+1                ; the frame height, so the frame is ten tiles high,
                        ; to cover the image which is eight tiles high

 JMP DrawImageFrame_b3  ; Call DrawImageFrame to draw a frame around the
                        ; commander image, returning from the subroutine using a
                        ; tail call

; ******************************************************************************
;
;       Name: DrawSpriteImage
;       Type: Subroutine
;   Category: Drawing sprites
;    Summary: Draw an image out of sprites using patterns in sequential tiles in
;             the pattern buffer
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
;   XC                  The text column of the top-left corner of the image
;
;   YC                  The text row of the top-left corner of the image
;
;   X                   The pixel x-coordinate of the top-left corner of the
;                       image within the text block at (XC, YC)
;
;   Y                   The pixel y-coordinate of the top-left corner of the
;                       image within the text block at (XC, YC)
;
; Other entry points:
;
;   DrawSpriteImage+2   Set the attributes for the sprites in the image to A
;
; ******************************************************************************

.DrawSpriteImage

 LDA #%00000001         ; Set S to use as the attribute for each of the sprites
 STA S                  ; in the image, so each sprite is set as follows:
                        ;
                        ;     * Bits 0-1    = sprite palette 1
                        ;     * Bit 5 clear = show in front of background
                        ;     * Bit 6 clear = do not flip horizontally
                        ;     * Bit 7 clear = do not flip vertically

 LDA XC                 ; Set SC = XC * 8 + X
 ASL A                  ;        = XC * 8 + 6
 ASL A                  ;
 ASL A                  ; So SC is the pixel x-coordinate of the top-left corner
 ADC #0                 ; of the image we want to draw, as each text character
 STA SC                 ; in XC is 8 pixels wide and X contains the x-coordinate
 TXA                    ; within the character block
 ADC SC
 STA SC

 LDA YC                 ; Set SC+1 = YC * 8 + 6 + Y
 ASL A                  ;          = YC * 8 + 6 + 6
 ASL A                  ;
 ASL A                  ; So SC+1 is the pixel y-coordinate of the top-left
 ADC #6+YPAL            ; corner of the image we want to draw, as each text row
 STA SC+1               ; in YC is 8 pixels high and Y contains the y-coordinate
 TYA                    ; within the character block
 ADC SC+1
 STA SC+1

 LDA K+3                ; Set Y = K+3 * 4
 ASL A                  ;
 ASL A                  ; So Y contains the offset of the first free sprite's
 TAY                    ; four-byte block in the sprite buffer, as each sprite
                        ; consists of four bytes, so this is now the offset
                        ; within the sprite buffer of the first sprite we can
                        ; use to build the sprite image

 LDA K+2                ; Set A to the pattern number of the first tile in K+2

 LDX K+1                ; Set T = K+1 to use as a counter for each row in the
 STX T                  ; image

.drsi1

 SETUP_PPU_FOR_ICON_BAR ; If the PPU has started drawing the icon bar, configure
                        ; the PPU to use nametable 0 and pattern table 0

 LDX SC                 ; Set SC2 to the pixel x-coordinate for the start of
 STX SC2                ; each row, so we can use it to move along the row as we
                        ; draw the sprite image

 LDX K                  ; Set X to the number of tiles in each row of the image
                        ; (in K), so we can use it as a counter as we move along
                        ; the row

.drsi2

 LDA K+2                ; Set the tile pattern for sprite Y to K+2, which is
 STA tileSprite0,Y      ; the pattern number in the PPU's pattern table to use
                        ; for this part of the image

 LDA S                  ; Set the attributes for sprite Y to S, which we set
 STA attrSprite0,Y      ; above as follows:
                        ;
                        ;     * Bits 0-1    = sprite palette 1
                        ;     * Bit 5 clear = show in front of background
                        ;     * Bit 6 clear = do not flip horizontally
                        ;     * Bit 7 clear = do not flip vertically

 LDA SC2                ; Set the x-coordinate for sprite Y to SC2
 STA xSprite0,Y

 CLC                    ; Set SC2 = SC2 + 8
 ADC #8                 ;
 STA SC2                ; So SC2 contains the x-coordinate of the next tile
                        ; along the row

 LDA SC+1               ; Set the y-coordinate for sprite Y to SC+1
 STA ySprite0,Y

 TYA                    ; Add 4 to the sprite number in Y, to move on to the
 CLC                    ; next sprite in the sprite buffer (as each sprite
 ADC #4                 ; consists of four bytes of data)

 BCS drsi3              ; If the addition overflowed, then we have reached the
                        ; end of the sprite buffer, so jump to drsi3 to return
                        ; from the subroutine, as we have run out of sprites

 TAY                    ; Otherwise set Y to the offset of the next sprite in
                        ; the sprite buffer

 INC K+2                ; Increment the tile counter in K+2 to point to the next
                        ; tile patterm

 DEX                    ; Decrement the tile counter in X as we have just drawn
                        ; a tile

 BNE drsi2              ; If X is non-zero then we still have more tiles to
                        ; draw on the current row, so jump back to drsi2 to draw
                        ; the next one

 LDA SC+1               ; Otherwise we have reached the end of this row, so add
 ADC #8                 ; 8 to SC+1 to move the y-coordinate down to the next
 STA SC+1               ; tile row (as each tile row is 8 pixels high)

 DEC T                  ; Decrement the number of rows in T as we just finished
                        ; drawing a row

 BNE drsi1              ; Loop back to drsi1 until we have drawn all the rows in
                        ; the image

.drsi3

 RTS                    ; Return from the subroutine

; ******************************************************************************
;
;       Name: PauseGame
;       Type: Subroutine
;   Category: Icon bar
;    Summary: ???
;
; ******************************************************************************

.PauseGame

 TYA
 PHA
 TXA
 PHA

 JSR WaitForNMI         ; Wait until the next NMI interrupt has passed (i.e. the
                        ; next VBlank)

 LDA nmiTimer
 PHA
 LDA nmiTimerLo
 PHA
 LDA nmiTimerHi
 PHA

 JSR WaitForPPUToFinish ; Wait until both bitplanes of the screen have been
                        ; sent to the PPU, so the screen is fully updated and
                        ; there is no more data waiting to be sent to the PPU

 LDA showIconBarPointer
 PHA
 LDA iconBarType
 PHA

 LDA #$FF               ; Set showIconBarPointer = $FF to indicate that we
 STA showIconBarPointer ; should show the icon bar pointer

 LDA #3
 JSR ShowIconBar_b3

.CA18B

 LDY #4                 ; Wait until four NMI interrupts have passed (i.e. the
 JSR DELAY              ; next four VBlanks)

 JSR SetKeyLogger_b6
 TXA
 CMP #80
 BNE CA1B1
 PLA
 JSR ShowIconBar_b3
 PLA
 STA showIconBarPointer

 JSR WaitForNMI         ; Wait until the next NMI interrupt has passed (i.e. the
                        ; next VBlank)

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
 LDA DNOIZ
 EOR #$FF
 STA DNOIZ
 JMP CA21D

.CA1C0

 CMP #$33
 BNE CA1E1
 LDA disableMusic
 EOR #$FF
 STA disableMusic
 BPL CA1D4
 JSR StopMusic_b6
 JMP CA21D

.CA1D4

 LDA newTune
 BEQ CA1DE
 AND #$7F
 JSR ChooseMusic_b6

.CA1DE

 JMP CA21D

.CA1E1

 CMP #$3C
 BNE CA1ED
 PLA
 PLA
 STA showIconBarPointer
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
 LDA JSTGY
 EOR #$FF
 STA JSTGY
 JMP CA21D

.CA20B

 CMP #$32
 BNE CA21A
 LDA DAMP
 EOR #$FF
 STA DAMP
 JMP CA21D

.CA21A

 JMP CA18B

.CA21D

 JSR UpdateIconBar_b3
 JMP CA18B

; ******************************************************************************
;
;       Name: DILX
;       Type: Subroutine
;   Category: Dashboard
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

.CA281

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
;   Category: Dashboard
;    Summary: ???
;
; ******************************************************************************

.DIALS

 LDA drawingBitplane
 BNE CA331

 LDA #$72               ; Set SC(1 0) = $72E2
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

 LDA FSH                ; Draw the forward shield indicator using a range of
 JSR DILX               ; 0-255, and increment SC to point to the next indicator
                        ; (the aft shield)

 LDA ASH                ; Draw the aft shield indicator using a range of 0-255,
 JSR DILX               ; and increment SC to point to the next indicator (the
                        ; fuel level)

 LDA ENERGY
 JSR DILX

 LDA #0
 STA K
 LDA #$18
 STA K+1

 LDA CABTMP             ; Draw the cabin temperature indicator using a range of
 JSR DILX               ; 0-255, and increment SC to point to the next indicator
                        ; (the laser temperature)

 LDA GNTMP              ; Draw the laser temperature indicator using a range of
 JSR DILX               ; 0-255, and increment SC to point to the next indicator
                        ; (the altitude)

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

 LDA ALTIT              ; Draw the altitude indicator using a range of 0-255
 JSR DILX

.CA331

 LDA #$BA+YPAL
 STA ySprite10
 LDA #$CE
 STA xSprite10

 JSR GetStatusCondition ; Set X to our ship's status condition (0 to 3)

 LDA conditionAttrs,X
 STA attrSprite10
 LDA conditionTiles,X
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
 JSR MSBAR_b6

.CA368

 LDA #$F0
 STA ySprite9
 RTS

.CA36E

 JSR MSBAR_b6

.CA371

 LDA #$F8
 STA tileSprite9
 LDA #1
 STA attrSprite9
 LDA #$7E
 STA xSprite9

 LDA #$53+YPAL
 STA ySprite9
 RTS

; ******************************************************************************
;
;       Name: conditionAttrs
;       Type: Variable
;   Category: Dashboard
;    Summary: Sprite attributes for the status condition indicator on the
;             dashboard
;
; ******************************************************************************

.conditionAttrs

 EQUB 33                ; Docked

 EQUB 32                ; Green

 EQUB 34                ; Yellow

 EQUB 34                ; Red

; ******************************************************************************
;
;       Name: conditionTiles
;       Type: Variable
;   Category: Dashboard
;    Summary: Sprite tile numbers attributes for the status condition indicator
;             on the dashboard
;
; ******************************************************************************

.conditionTiles

 EQUB 249               ; Docked

 EQUB 250               ; Green

 EQUB 250               ; Yellow

 EQUB 249               ; Red

; ******************************************************************************
;
;       Name: MSBAR_b6
;       Type: Subroutine
;   Category: Dashboard
;    Summary: ???
;
; ******************************************************************************

.MSBAR_b6

 TYA
 PHA
 LDY missileNames_b6,X
 PLA
 STA nameBuffer0+704,Y
 LDY #0
 RTS

; ******************************************************************************
;
;       Name: missileNames_b6
;       Type: Variable
;   Category: Dashboard
;    Summary: ???
;
; ******************************************************************************

.missileNames_b6

 EQUB $00, $5F, $5E, $3F, $3E                 ; A39A: 00 5F 5E... ._^

; ******************************************************************************
;
;       Name: SetEquipmentSprite
;       Type: Subroutine
;   Category: Equipment
;    Summary: Set up a sprite for a specific bit of equipment to show on our
;             Cobra Mk III on the Equip Ship screen
;
; ******************************************************************************

.SetEquipmentSprite

 LDA #0

; ******************************************************************************
;
;       Name: SetLaserSprite
;       Type: Subroutine
;   Category: Equipment
;    Summary: Set up a sprite for a specific laser to show on our Cobra Mk III
;             on the Equip Ship screen
;
; ******************************************************************************

.SetLaserSprite

 STA V
 STX V+1

.CA3A5

 LDA equipSprites+3,Y
 AND #$FC
 TAX
 LDA equipSprites+3,Y
 AND #3
 STA T
 LDA equipSprites,Y
 AND #$C0
 ORA T
 STA attrSprite0,X
 LDA equipSprites,Y
 AND #$3F
 CLC
 ADC #$8C
 ADC V
 STA tileSprite0,X
 LDA equipSprites+1,Y
 STA xSprite0,X
 LDA equipSprites+2,Y
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
;       Name: GetLaserSprite
;       Type: Subroutine
;   Category: Equipment
;    Summary: Calculate the offset into the equipSprites table for a specific
;             laser's sprite
;
; ******************************************************************************

.GetLaserSprite

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
;       Name: equipSprites
;       Type: Variable
;   Category: Equipment
;    Summary: Lookup table for the sprites that show the equipment fitted to our
;             Cobra Mk III on the Equip Ship screen
;
; ******************************************************************************

.equipSprites

IF _NTSC

 EQUB $1F, $55, $B6, $14, $20, $9C, $9C, $18
 EQUB $21, $9C, $A4, $1C, $07, $44, $A1, $20
 EQUB $0A, $AB, $AC, $24, $09, $14, $C6, $28
 EQUB $09, $7C, $AA, $2C, $49, $74, $C6, $30
 EQUB $49, $DC, $AA, $34, $87, $44, $CE, $74
 EQUB $15, $10, $C6, $28, $15, $79, $AA, $2C
 EQUB $55, $76, $C6, $30, $55, $DE, $AA, $34
 EQUB $1E, $A7, $B9, $3D, $5E, $AF, $B9, $41
 EQUB $1A, $4F, $C4, $AC, $1B, $4F, $C4, $B1
 EQUB $1A, $38, $C4, $44, $1B, $38, $C4, $49
 EQUB $00, $1D, $BB, $4D, $01, $D0, $B0, $51
 EQUB $40, $6C, $BB, $55, $41, $88, $B0, $59
 EQUB $00, $16, $C0, $5D, $01, $D6, $AF, $61
 EQUB $40, $73, $C0, $65, $41, $82, $AF, $69
 EQUB $17, $40, $CE, $6C, $18, $48, $CE, $70
 EQUB $19, $44, $CE, $3A, $02, $99, $B8, $78
 EQUB $42, $BC, $B8, $7C, $1C, $4F, $B2, $80
 EQUB $03, $34, $AC, $84, $04, $3C, $AC, $88
 EQUB $05, $34, $B4, $8C, $06, $3C, $B4, $90
 EQUB $44, $B2, $9C, $94, $43, $BA, $9C, $98
 EQUB $46, $B2, $A4, $9C, $45, $BA, $A4, $A0
 EQUB $1D, $40, $BE, $A6, $5D, $4A, $BE, $AA

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
;       Name: DrawEquipment
;       Type: Subroutine
;   Category: Equipment
;    Summary: Draw the currently fitted equipment onto the Cobra Mk III image on
;             the Equip Ship screen
;
; ******************************************************************************

.DrawEquipment

 JSR WaitForNMI         ; Wait until the next NMI interrupt has passed (i.e. the
                        ; next VBlank)

 LDA ECM
 BEQ CA4B4

 LDY #0
 LDX #3
 JSR SetEquipmentSprite

.CA4B4

 LDX LASER
 BEQ CA4C6
 JSR GetLaserSprite
 LDY #$0C
 LDX #2
 JSR SetLaserSprite
 JMP CA4C6

.CA4C6

 LDX LASER+1
 BEQ CA4D8
 JSR GetLaserSprite
 LDY #$24
 LDX #1
 JSR SetLaserSprite
 JMP CA4D8

.CA4D8

 LDX LASER+2
 BEQ CA4F5
 CPX #$97
 BEQ CA4EE
 JSR GetLaserSprite
 LDY #$14
 LDX #2
 JSR SetLaserSprite
 JMP CA4F5

.CA4EE

 LDY #$28
 LDX #2
 JSR SetEquipmentSprite

.CA4F5

 LDX LASER+3
 BEQ CA512
 CPX #$97
 BEQ CA50B
 JSR GetLaserSprite
 LDY #$1C
 LDX #2
 JSR SetLaserSprite
 JMP CA512

.CA50B

 LDY #$30
 LDX #2
 JSR SetEquipmentSprite

.CA512

 LDA BST
 BEQ CA51E
 LDY #$38
 LDX #2
 JSR SetEquipmentSprite

.CA51E

 LDA ENGY
 BEQ CA537
 LSR A
 BNE CA530
 LDY #$48
 LDX #2
 JSR SetEquipmentSprite
 JMP CA537

.CA530

 LDY #$40
 LDX #4
 JSR SetEquipmentSprite

.CA537

 LDA NOMSL
 BEQ CA56C
 LDY #$50
 LDX #2
 JSR SetEquipmentSprite
 LDA NOMSL
 LSR A
 BEQ CA56C
 LDY #$58
 LDX #2
 JSR SetEquipmentSprite
 LDA NOMSL
 CMP #2
 BEQ CA56C
 LDY #$60
 LDX #2
 JSR SetEquipmentSprite
 LDA NOMSL
 CMP #4
 BNE CA56C
 LDY #$68
 LDX #2
 JSR SetEquipmentSprite

.CA56C

 LDA BOMB
 BEQ CA578
 LDY #$70
 LDX #3
 JSR SetEquipmentSprite

.CA578

 LDA CRGO
 CMP #$25
 BNE CA586
 LDY #$7C
 LDX #2
 JSR SetEquipmentSprite

.CA586

 LDA ESCP
 BEQ CA592
 LDY #$84
 LDX #1
 JSR SetEquipmentSprite

.CA592

 LDA DKCMP
 BEQ CA59E
 LDY #$88
 LDX #8
 JSR SetEquipmentSprite

.CA59E

 LDA GHYP
 BEQ CA5AA
 LDY #$A8
 LDX #2
 JSR SetEquipmentSprite

.CA5AA

 RTS

; ******************************************************************************
;
;       Name: ShowScrollText
;       Type: Subroutine
;   Category: Demo
;    Summary: ???
;
; ------------------------------------------------------------------------------
;
; Arguments:
;
;   A                   If non-zero, show the scroll text but skip playing the
;                       demo afterwards
;
; ******************************************************************************

.ShowScrollText

 PHA
 LDA QQ11
 BNE CA5B6

 JSR ClearScanner       ; Remove all ships from the scanner and hide the scanner
                        ; sprites

 JMP CA614

.CA5B6

 JSR FadeToBlack_b3     ; Fade the screen to black over the next four VBlanks

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

 LDX #NOST              ; Set X to the maximum number of stardust particles, so
                        ; we loop through all the particles of stardust in the
                        ; following

 LDY #152               ; Set Y to the starting index in the sprite buffer, so
                        ; we start configuring from sprite 152 / 4 = 38 (as each
                        ; sprite in the buffer consists of four bytes)

.CA5EF

 SETUP_PPU_FOR_ICON_BAR ; If the PPU has started drawing the icon bar, configure
                        ; the PPU to use nametable 0 and pattern table 0

 LDA #210               ; Set the sprite to use pattern number 210 for the
 STA tileSprite0,Y      ; largest particle of stardust (the stardust particle
                        ; patterns run from pattern 210 to 214, decreasing in
                        ; size as the number increases)

 TXA                    ; Take the particle number, which is between 1 and 20
 LSR A                  ; (as NOST is 20), and rotate it around from %76543210
 ROR A                  ; to %10xxxxx3 (where x indicates a zero), storing the
 ROR A                  ; result as the sprite attribute
 AND #%11100001         ;
 STA attrSprite0,Y      ; This sets the flip horizontally and flip vertically
                        ; attributes to bits 0 and 1 of the particle number, and
                        ; the palette to bit 3 of the particle number, so the
                        ; reset stardust particles have a variety of reflections
                        ; and palettes

 INY                    ; Add 4 to Y so it points to the next sprite's data in
 INY                    ; the sprite buffer
 INY
 INY

 DEX                    ; Decrement the loop counter in X

 BNE CA5EF              ; Loop back until we have configured 20 sprites

 JSR STARS_b1

.CA614

 LDA #0
 STA LASER
 STA QQ12

 LDA #$10               ; Clear the screen and and set the view type in QQ11 to
 JSR ChangeToView_b0    ; $10 (Space view with font loaded in bitplane 0)

 LDA #$FF               ; Set showIconBarPointer = $FF to indicate that we
 STA showIconBarPointer ; should show the icon bar pointer

 LDA #240
 STA ySprite5
 STA ySprite6
 STA ySprite7
 STA ySprite8
 STA ySprite9
 LDA #0
 STA SC+1
 LDA firstFreeTile
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
 LDX firstFreeTile
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

 PLA                    ; Retrieve the argument that we stored on the stack at
 BNE CA6D3              ; the start of the routine, and if it is non-zero, jump
                        ; to CA6D3 to skip playing the demo

 LDX languageIndex
 LDA LACAE,X
 LDY LACB2,X
 TAX
 LDA #2
 JSR DrawScrollText

 LDA #$00               ; Set the view type in QQ11 to $00 (Space view with
 STA QQ11               ; no font loaded)

 JSR SetLinePatterns_b3 ; Load the line patterns for the new view into the
                        ; pattern buffers

 LDA #37                ; Tell the NMI handler to send pattern entries from
 STA firstPatternTile   ; pattern 37 in the buffer

 JSR subm_A761

 LDA #60                ; Tell the NMI handler to send pattern entries from
 STA firstPatternTile   ; pattern 60 in the buffer

 JMP PlayDemo_b0

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
 LDX languageIndex
 LDA LACB6,X
 LDY LACBA,X
 TAX
 LDA #6

.CA726

 JSR DrawScrollText

 JSR FadeToBlack_b3     ; Fade the screen to black over the next four VBlanks

 JMP StartGame_b0       ; Jump to StartGame to reset the stack and go to the
                        ; docking bay (i.e. show the Status Mode screen)

.CA72F

 LDX languageIndex
 LDA LACBE,X
 LDY LACC2,X
 TAX
 LDA #6
 JSR DrawScrollText

 JSR WaitForNMI         ; Wait until the next NMI interrupt has passed (i.e. the
                        ; next VBlank)

 LDX languageIndex
 LDA LACC6,X
 LDY LACCA,X
 TAX
 LDA #5
 JSR DrawScrollText

 JSR WaitForNMI         ; Wait until the next NMI interrupt has passed (i.e. the
                        ; next VBlank)

 LDX languageIndex
 LDA LACCE,X
 LDY LACD2,X
 TAX
 LDA #3
 BNE CA726

; ******************************************************************************
;
;       Name: subm_A761
;       Type: Subroutine
;   Category: Demo
;    Summary: ???
;
; ******************************************************************************

.subm_A761

 JSR WaitForPPUToFinish ; Wait until both bitplanes of the screen have been
                        ; sent to the PPU, so the screen is fully updated and
                        ; there is no more data waiting to be sent to the PPU

 LDA #254
 STA firstFreeTile

 LDA #%11001000         ; Set both bitplane flags as follows:
 STA bitplaneFlags      ;
 STA bitplaneFlags+1    ;   * Bit 2 clear = send tiles up to configured numbers
                        ;   * Bit 3 set   = clear buffers after sending data
                        ;   * Bit 4 clear = we've not started sending data yet
                        ;   * Bit 5 clear = we have not yet sent all the data
                        ;   * Bit 6 set   = send both pattern and nametable data
                        ;   * Bit 7 set   = send data to the PPU
                        ;
                        ; Bits 0 and 1 are ignored and are always clear

 RTS

; ******************************************************************************
;
;       Name: GRIDSET
;       Type: Subroutine
;   Category: Demo
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
;   Category: Demo
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
;   Category: Demo
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
;   Category: Demo
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
;       Name: DrawScrollText
;       Type: Subroutine
;   Category: Demo
;    Summary: ???
;
; ******************************************************************************

.DrawScrollText

 PHA
 JSR subm_A86C
 LDA #$28
 STA visibleColour
 LDA #0
 STA L0300
 LDA #2
 STA L0402
 JSR UpdateIconBar_b3

 LDA #40                ; Tell the NMI handler to send nametable entries from
 STA firstNametableTile ; tile 40 * 8 = 320 onwards (i.e. from the start of tile
                        ; row 10)

 LDA #$A0
 STA L03FC
 JSR subm_A96E
 PLA
 STA LASCT

.loop_CA93C

 LDA #$17
 STA L03FC
 JSR subm_A9A2
 JSR GRIDSET
 JSR subm_A96E
 DEC LASCT
 BNE loop_CA93C
 LDA #4
 STA LASCT

.loop_CA954

 LDA #$17
 STA L03FC
 JSR subm_A9A2
 JSR subm_A96E
 DEC LASCT
 BNE loop_CA954
 LDA #0
 STA L0402

 LDA #$2C               ; Set the visible colour to cyan ($2C)
 STA visibleColour

 RTS

; ******************************************************************************
;
;       Name: subm_A96E
;       Type: Subroutine
;   Category: Demo
;    Summary: ???
;
; ******************************************************************************

.subm_A96E

 LDA controller1A
 BMI CA97F
 LDA pointerButton
 CMP #$0C
 BNE CA984
 LDA #0
 STA pointerButton

.CA97F

 LDA #9
 STA L0402

.CA984

 JSR FlipDrawingPlane
 JSR subm_AAE5
 JSR DrawBitplaneInNMI
 LDA pointerButton
 BEQ CA995
 JSR CheckForPause_b0

.CA995

 LDA L03FC
 SEC
 SBC L0402
 STA L03FC
 BCS subm_A96E
 RTS

; ******************************************************************************
;
;       Name: subm_A9A2
;       Type: Subroutine
;   Category: Demo
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
;   Category: Demo
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
;   Category: Demo
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
 JSR LOIN_b1
 LDY YP
 JMP CAAEA

; ******************************************************************************
;
;       Name: LTDEF
;       Type: Variable
;   Category: Demo
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
;   Category: Demo
;    Summary: ???
;
; ******************************************************************************

.LAC6F

 EQUB 3

.LAC70

 EQUB $35

.LAC71

 EQUB $58

.LAC72

 EQUB $68

.LAC73

 EQUB $02, $17, $00, $00, $00, $28, $68, $06
 EQUB $00, $00, $27, $07, $00, $00, $00, $28
 EQUB $48, $46, $06, $00, $26, $08, $00, $00
 EQUB $00, $47, $04, $24, $00, $00, $02, $26
 EQUB $68, $00, $00

.NOFX

 EQUB 1, 2, 3, 1, 2, 3, 1, 2, 3, 1, 2, 3

.NOFY

 EQUB 0, 0, 0, 1, 1, 1, 2, 2, 2, 3, 3, 3

.LACAE

 EQUB $D6, $76, $26, $D6

.LACB2

 EQUB $AC, $AF, $AE, $AC

.LACB6

 EQUB $54, $F4, $A4, $54

.LACBA

 EQUB $AD, $AF, $AE, $AD

.LACBE

 EQUB $C6, $C6, $C6, $C6

.LACC2

 EQUB $B0, $B0, $B0, $B0

.LACC6

 EQUB $98, $98, $98, $98

.LACCA

 EQUB $B1, $B1, $B1, $B1

.LACCE

 EQUS $55, $55, $55, $55

.LACD2

 EQUB $B2, $B2, $B2, $B2

IF _NTSC

 EQUS "   NTSC EMULATION    "
 EQUS "  --- E L # T E ---  "
 EQUS "(C)BELL & BRABEN 1991"

ELIF _PAL

 EQUS " IMAGINEER PRESENTS  "
 EQUS "  --- E L # T E ---  "
 EQUS "(C)BRABEN & BELL 1991"

ENDIF

 EQUS "                     "
 EQUS "PREPARE FOR PRACTICE "
 EQUS "COMBAT SEQUENCE......"
 EQUS " CONGRATULATIONS! YOU"
 EQUS "COMPLETED  THE COMBAT"
 EQUS " IN "
 EQUB $83, $82
 EQUS "  MIN  "
 EQUB $81, $80
 EQUS " SEC. "
 EQUS "                     "
 EQUS "YOU BEGIN YOUR CAREER"
 EQUS "DOCKED AT  THE PLANET"
 EQUS "LAVE WITH 100 CREDITS"
 EQUS "3 MISSILES AND A FULL"
 EQUS "TANK OF FUEL.        "
 EQUS "GOOD LUCK, COMMANDER!"

IF _NTSC

 EQUS "   NTSC EMULATION    "
 EQUS "  --- E L # T E ---  "
 EQUS "(C)BELL & BRABEN 1991"

ELIF _PAL

 EQUS " IMAGINEER PRESENTE  "
 EQUS "  --- E L # T E ---  "
 EQUS "(C)BRABEN & BELL 1991"

ENDIF

 EQUS "                     "
 EQUS " PREPAREZ-VOUS  A  LA"
 EQUS "SIMULATION DU COMBAT!"
 EQUS " FELICITATIONS! VOTRE"
 EQUS "COMBAT EST TERMINE EN"
 EQUS "   "
 EQUB $83, $82
 EQUS "  MIN  "
 EQUB $81, $80
 EQUS " SEC.  "
 EQUS "                     "
 EQUS " VOUS COMMENCEZ VOTRE"
 EQUS "COURS  SUR LA PLANETE"
 EQUS "LAVE AVEC 100 CREDITS"
 EQUS "ET TROIS MISSILES.   "
 EQUS "     BONNE CHANCE    "
 EQUS "     COMMANDANT!     "

IF _NTSC

 EQUS "   NTSC EMULATION    "
 EQUS "  --- E L # T E ---  "
 EQUS "(C)BELL & BRABEN 1991"

ELIF _PAL

 EQUS "   IMAGINEER ZEIGT   "
 EQUS "  --- E L # T E ---  "
 EQUS "(C)BRABEN & BELL 1991"

ENDIF

 EQUS "                     "
 EQUS "RUSTEN  SIE  SICH ZUM"
 EQUS "PROBEKAMPF..........."
 EQUS " BRAVO! SIE HABEN DEN"
 EQUS "KAMPF  GEWONNEN  ZEIT"
 EQUS "  "
 EQUB $83, $82
 EQUS "  MIN  "
 EQUB $81, $80
 EQUS "  SEK.  "
 EQUS "                     "
 EQUS "  SIE  BEGINNEN  IHRE"
 EQUS "KARRIERE  IM DOCK DES"
 EQUS "PLANETS LAVE MIT DREI"
 EQUS "RAKETEN, 100 CR,  UND"
 EQUS "EINEM VOLLEN TANK.   "
 EQUS "VIEL GLUCK,COMMANDER!"

 EQUS "ORIGINAL GAME AND NES"
 EQUS "CONVERSION  BY  DAVID"
 EQUS "BRABEN  AND #AN BELL."
 EQUS "                     "
 EQUS "DEVELOPED USING  PDS."
 EQUS "HANDLED BY MARJACQ.  "
 EQUS "                     "
 EQUS "ARTWORK   BY  EUROCOM"
 EQUS "DEVELOPMENTS LTD.    "
 EQUS "                     "
 EQUS "MUSIC & SOUNDS  CODED"
 EQUS "BY  DAVID  WHITTAKER."
 EQUS "                     "
 EQUS "MUSIC BY  AIDAN  BELL"
 EQUS "AND  JOHANN  STRAUSS."
 EQUS "                     "
 EQUS "TESTERS=CHRIS JORDAN,"
 EQUS "SAM AND JADE BRIANT, "
 EQUS "R AND M CHADWICK.    "
 EQUS "ELITE LOGO DESIGN BY "
 EQUS "PHILIP CASTLE.       "
 EQUS "                     "
 EQUS "GAME TEXT TRANSLATERS"
 EQUS "UBI SOFT,            "
 EQUS "SUSANNE DIECK,       "
 EQUS "IMOGEN  RIDLER.      "

; ******************************************************************************
;
;       Name: saveHeader1_EN
;       Type: Subroutine
;   Category: Save and load
;    Summary: ???
;
; ******************************************************************************

.saveHeader1_EN

 EQUS "STORED COMMANDERS"
 EQUB $0C, $0C, $0C,   6
 EQUB 0

; ******************************************************************************
;
;       Name: saveHeader2_EN
;       Type: Subroutine
;   Category: Save and load
;    Summary: ???
;
; ******************************************************************************

.saveHeader2_EN

 EQUS "                    STORED"
 EQUB $0C
 EQUS "                    POSITIONS"
 EQUB $0C, $0C, $0C, $0C, $0C, $0C, $0C
 EQUS "CURRENT"
 EQUB $0C
 EQUS "POSITION"
 EQUB 0

; ******************************************************************************
;
;       Name: saveHeader1_DE
;       Type: Subroutine
;   Category: Save and load
;    Summary: ???
;
; ******************************************************************************

.saveHeader1_DE

 EQUS "GESPEICHERTE KOMMANDANTEN"
 EQUB $0C, $0C, $0C,   6
 EQUB 0

; ******************************************************************************
;
;       Name: saveHeader2_DE
;       Type: Subroutine
;   Category: Save and load
;    Summary: ???
;
; ******************************************************************************

.saveHeader2_DE

 EQUS "                    GESP."
 EQUB $0C
 EQUS "                   POSITIONEN"
 EQUB $0C, $0C, $0C, $0C, $0C, $0C, $0C
 EQUS "GEGENW."
 EQUB $0C
 EQUS "POSITION"
 EQUB 0

; ******************************************************************************
;
;       Name: saveHeader1_FR
;       Type: Subroutine
;   Category: Save and load
;    Summary: ???
;
; ******************************************************************************

.saveHeader1_FR

 EQUS "COMMANDANTS SAUVEGARDES"
 EQUB $0C, $0C, $0C,   6
 EQUB 0

; ******************************************************************************
;
;       Name: saveHeader2_FR
;       Type: Subroutine
;   Category: Save and load
;    Summary: ???
;
; ******************************************************************************

.saveHeader2_FR

 EQUS "                    POSITIONS"
 EQUB $0C
 EQUS "                  SAUVEGARD<ES"
 EQUB $0C, $0C, $0C, $0C, $0C, $0C, $0C
 EQUS "POSITION"
 EQUB $0C
 EQUS "ACTUELLE"
 EQUB 0

; ******************************************************************************
;
;       Name: xSaveHeader
;       Type: Variable
;   Category: Save and load
;    Summary: The text column for the save and load headers for each language
;
; ******************************************************************************

.xSaveHeader

 EQUB 8                 ; English

 EQUB 4                 ; German

 EQUB 4                 ; French

 EQUB 5                 ; There is no fourth language, so this byte is ignored

; ******************************************************************************
;
;       Name: saveHeader1Lo
;       Type: Variable
;   Category: Save and load
;    Summary: Lookup table for the low byte of the address of the saveHeader1
;             text for each language
;
; ******************************************************************************

.saveHeader1Lo

 EQUB LO(saveHeader1_EN)
 EQUB LO(saveHeader1_DE)
 EQUB LO(saveHeader1_FR)

; ******************************************************************************
;
;       Name: saveHeader1Hi
;       Type: Variable
;   Category: Save and load
;    Summary: Lookup table for the high byte of the address of the saveHeader1
;             text for each language
;
; ******************************************************************************

.saveHeader1Hi

 EQUB HI(saveHeader1_EN)
 EQUB HI(saveHeader1_DE)
 EQUB HI(saveHeader1_FR)

; ******************************************************************************
;
;       Name: saveHeader2Lo
;       Type: Variable
;   Category: Save and load
;    Summary: Lookup table for the low byte of the address of the saveHeader2
;             text for each language
;
; ******************************************************************************

.saveHeader2Lo

 EQUB LO(saveHeader2_EN)
 EQUB LO(saveHeader2_DE)
 EQUB LO(saveHeader2_FR)

; ******************************************************************************
;
;       Name: saveHeader2Hi
;       Type: Variable
;   Category: Save and load
;    Summary: Lookup table for the high byte of the address of the saveHeader2
;             text for each language
;
; ******************************************************************************

.saveHeader2Hi

 EQUB HI(saveHeader2_EN)
 EQUB HI(saveHeader2_DE)
 EQUB HI(saveHeader2_FR)

; ******************************************************************************
;
;       Name: saveBracketTiles
;       Type: Variable
;   Category: Save and load
;    Summary: ???
;
; ******************************************************************************

.saveBracketTiles

 EQUB $68, $6A, $69, $6A, $69, $6A, $69, $6A
 EQUB $6B, $6A, $69, $6A, $69, $6A, $6C, $00

; ******************************************************************************
;
;       Name: PrintSaveHeader
;       Type: Subroutine
;   Category: Save and load
;    Summary: ???
;
; ******************************************************************************

.PrintSaveHeader

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
;       Name: SVE
;       Type: Subroutine
;   Category: Save and load
;    Summary: ???
;
; ******************************************************************************

.SVE

 LDA #$BB               ; Clear the screen and and set the view type in QQ11 to
 JSR TT66_b0            ; $BB (Save and load with font loaded in both bitplanes)

 LDA #$8B               ; Set the view type in QQ11 to $8B (Save and load with
 STA QQ11               ; no font loaded)

 LDY #0
 STY autoPlayDemo
 STY QQ17
 STY YC
 LDX languageIndex
 LDA xSaveHeader,X
 STA XC
 LDA saveHeader1Lo,X
 STA V
 LDA saveHeader1Hi,X
 STA V+1
 JSR PrintSaveHeader

 LDA #$BB               ; Set the view type in QQ11 to $BB (Save and load with
 STA QQ11               ; font loaded in both bitplanes)

 LDX languageIndex
 LDA saveHeader2Lo,X
 STA V
 LDA saveHeader2Hi,X
 STA V+1
 JSR PrintSaveHeader
 JSR NLIN4

 JSR SetScreenForUpdate ; Get the screen ready for updating by hiding all
                        ; sprites, after fading the screen to black if we are
                        ; changing view

 LDY #$14

 LDA #$39+YPAL
 STA T
 LDX #0

.CB4A2

 LDA #$22
 STA attrSprite0,Y
 LDA saveBracketTiles,X
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

 STY CNT                ; Set CNT to the offset in the sprite buffer of the
                        ; next free sprite

 LDY #7

.loop_CB4CA

 TYA
 ASL A
 CLC
 ADC #6
 STA YC
 LDX #$14
 STX XC
 JSR DrawPositionMarks
 DEY
 BPL loop_CB4CA
 JSR DrawSmallLogo_b4
 LDA #0

.loop_CB4E0

 CMP #8
 BEQ CB4E7
 JSR PrintSaveName

.CB4E7

 CLC
 ADC #1
 CMP #9
 BCC loop_CB4E0
 JSR HighlightSaveName

 JSR UpdateView_b0      ; Update the view

 LDA #9                 ; ???

; ******************************************************************************
;
;       Name: MainSaveLoadLoop
;       Type: Subroutine
;   Category: Save and load
;    Summary: ???
;
; ******************************************************************************

.MainSaveLoadLoop

 JSR SetupPPUForIconBar ; If the PPU has started drawing the icon bar, configure
                        ; the PPU to use nametable 0 and pattern table 0

 LDX controller1Leftx8
 BPL CB50F
 JSR PrintSaveName
 CMP #9
 BEQ CB50A
 LDA #0
 JMP CB50C

.CB50A

 LDA #4

.CB50C

 JMP MoveSaveHighlight

.CB50F

 LDX controller1Rightx8
 BPL CB525
 JSR PrintSaveName
 CMP #9
 BEQ CB520
 LDA #0
 JMP CB522

.CB520

 LDA #4

.CB522

 JMP CB5CB

.CB525

 JSR CheckSaveLoadBar
 BCS MainSaveLoadLoop
 RTS

; ******************************************************************************
;
;       Name: CheckSaveLoadBar
;       Type: Subroutine
;   Category: Save and load
;    Summary: ???
;
; ******************************************************************************

.CheckSaveLoadBar

 LDX pointerButton
 BEQ CB53B
 PHA
 CPX #7
 BEQ CB53D
 TXA
 JSR CheckForPause_b0
 PLA
 RTS

.CB53B

 SEC
 RTS

.CB53D

 LDA COK
 BMI CB558
 LDA #0
 STA pointerButton
 JSR ChangeCmdrName_b6
 LDA pointerButton
 BEQ CB553
 CMP #7
 BEQ CB53D

.CB553

 LDA #6
 STA pointerButton

.CB558

 CLC
 PLA
 RTS

; ******************************************************************************
;
;       Name: WaitForNoDirection
;       Type: Subroutine
;   Category: Controllers
;    Summary: ???
;
; ******************************************************************************

.WaitForNoDirection

 PHA

.loop_CB55C

 JSR SetupPPUForIconBar ; If the PPU has started drawing the icon bar, configure
                        ; the PPU to use nametable 0 and pattern table 0

 LDA controller1Leftx8
 ORA controller1Rightx8
 BMI loop_CB55C
 PLA
 RTS

; ******************************************************************************
;
;       Name: MoveToCurrentCmdr
;       Type: Subroutine
;   Category: Save and load
;    Summary: ???
;
; ******************************************************************************

.MoveToCurrentCmdr

 LDA #9
 JSR HighlightSaveName
 JSR UpdateSaveScreen
 JSR WaitForNoDirection
 JMP MainSaveLoadLoop

; ******************************************************************************
;
;       Name: MoveSaveHighlight
;       Type: Subroutine
;   Category: Save and load
;    Summary: ???
;
; ******************************************************************************

.MoveSaveHighlight

 JSR HighlightSaveName
 JSR UpdateSaveScreen
 JSR WaitForNoDirection

.CB580

 JSR SetupPPUForIconBar ; If the PPU has started drawing the icon bar, configure
                        ; the PPU to use nametable 0 and pattern table 0

 LDX controller1Up
 BPL CB598
 CMP #0
 BEQ CB598
 JSR PrintSaveName
 SEC
 SBC #1
 JSR HighlightSaveName
 JSR UpdateSaveScreen

.CB598

 LDX controller1Down
 BPL CB5AD
 CMP #7
 BCS CB5AD
 JSR PrintSaveName
 CLC
 ADC #1
 JSR HighlightSaveName
 JSR UpdateSaveScreen

.CB5AD

 LDX controller1Leftx8
 BPL CB5B8
 JSR PrintSaveName
 JMP CB5CB

.CB5B8

 LDX controller1Rightx8
 BPL CB5C5
 JSR PrintSaveName
 LDA #4
 JMP MoveToCurrentCmdr

.CB5C5

 JSR CheckSaveLoadBar
 BCS CB580
 RTS

.CB5CB

 JSR PrintPositionName
 JSR UpdateSaveScreen
 JSR WaitForNoDirection

.CB5D4

 JSR SetupPPUForIconBar ; If the PPU has started drawing the icon bar, configure
                        ; the PPU to use nametable 0 and pattern table 0

 LDX controller1Up
 BPL CB5EC
 CMP #0
 BEQ CB5EC
 JSR ClearPositionName
 SEC
 SBC #1
 JSR PrintPositionName
 JSR UpdateSaveScreen

.CB5EC

 LDX controller1Down
 BPL CB601
 CMP #7
 BCS CB601
 JSR ClearPositionName
 CLC
 ADC #1
 JSR PrintPositionName
 JSR UpdateSaveScreen

.CB601

 LDX controller1Leftx8
 BPL CB618
 CMP #4
 BNE CB618
 JSR ClearPositionName
 LDA #9
 JSR SaveToSlots
 JSR UpdateIconBar_b3
 JMP MoveToCurrentCmdr

.CB618

 LDX controller1Rightx8
 BPL CB626
 JSR ClearPositionName
 JSR SaveToSlots
 JMP MoveSaveHighlight

.CB626

 JSR CheckSaveLoadBar
 BCS CB5D4
 RTS

; ******************************************************************************
;
;       Name: DrawPositionMarks
;       Type: Subroutine
;   Category: Save and load
;    Summary: ???
;
; ******************************************************************************

.DrawPositionMarks

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

 ADC #6+YPAL
 STA ySprite0,Y
 TYA
 CLC
 ADC #4
 STA CNT
 LDY YSAV2
 RTS

; ******************************************************************************
;
;       Name: PrintSaveName
;       Type: Subroutine
;   Category: Save and load
;    Summary: ???
;
; ******************************************************************************

.PrintSaveName

 JSR UpdateSaveSlot
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
;       Name: PrintBufferName
;       Type: Subroutine
;   Category: Save and load
;    Summary: ???
;
; ******************************************************************************

.PrintBufferName

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
;       Name: HighlightSaveName
;       Type: Subroutine
;   Category: Save and load
;    Summary: ???
;
; ******************************************************************************

.HighlightSaveName

 LDX #2                 ; Set the font bitplane to print in plane 2
 STX fontBitplane

 JSR PrintSaveName

 LDX #1                 ; Set the font bitplane to print in plane 1
 STX fontBitplane

 RTS

; ******************************************************************************
;
;       Name: UpdateSaveScreen
;       Type: Subroutine
;   Category: Save and load
;    Summary: ???
;
; ******************************************************************************

.UpdateSaveScreen

 PHA
 JSR DrawScreenInNMI_b0

 JSR WaitForPPUToFinish ; Wait until both bitplanes of the screen have been
                        ; sent to the PPU, so the screen is fully updated and
                        ; there is no more data waiting to be sent to the PPU

 PLA
 RTS

; ******************************************************************************
;
;       Name: PrintPositionName
;       Type: Subroutine
;   Category: Save and load
;    Summary: ???
;
; ******************************************************************************

.PrintPositionName

 LDX #2                 ; Set the font bitplane to print in plane 2
 STX fontBitplane

 LDX #$0B
 STX XC
 PHA
 ASL A
 CLC
 ADC #6
 STA YC
 PLA
 JSR PrintBufferName

 LDX #1                 ; Set the font bitplane to print in plane 1
 STX fontBitplane

 RTS

; ******************************************************************************
;
;       Name: ClearPositionName
;       Type: Subroutine
;   Category: Save and load
;    Summary: ???
;
; ******************************************************************************

.ClearPositionName

 LDX #$0B
 STX XC
 PHA
 ASL A
 CLC
 ADC #6
 STA YC

 JSR GetRowNameAddress  ; Get the addresses in the nametable buffers for the
                        ; start of character row YC, as follows:
                        ;
                        ;   SC(1 0) = the address in nametable buffer 0
                        ;
                        ;   SC2(1 0) = the address in nametable buffer 1

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
;       Name: saveChecksums
;       Type: Variable
;   Category: Save and load
;    Summary: ???
;
; ******************************************************************************

.saveChecksums

 EQUB $4A, $5A, $48, $02, $53, $B7, $00, $00  ; B708: 4A 5A 48... JZH
 EQUB $94, $B4, $90, $04, $A6, $6F, $00, $00  ; B710: 94 B4 90... ...
 EQUB $29, $69, $21, $08, $4D, $DE, $00, $00  ; B718: 29 69 21... )i!
 EQUB $52, $D2, $42, $10, $9A, $BD, $00, $00  ; B720: 52 D2 42... R.B
 EQUB $A4, $A5, $84, $20, $35, $7B, $00, $00  ; B728: A4 A5 84... ...
 EQUB $49, $4B, $09, $40, $6A, $F6, $00, $00  ; B730: 49 4B 09... IK.
 EQUB $92, $96, $12, $80, $D4, $ED, $00, $00  ; B738: 92 96 12... ...
 EQUB $25, $2D, $24, $01, $A9, $DB, $00, $00  ; B740: 25 2D 24... %-$

; ******************************************************************************
;
;       Name: positionAddr0
;       Type: Variable
;   Category: Save and load
;    Summary: The address of the first save slot for each saved position
;
; ******************************************************************************

.positionAddr0

 EQUW savedPositions0 + 0 * 73
 EQUW savedPositions0 + 1 * 73
 EQUW savedPositions0 + 2 * 73
 EQUW savedPositions0 + 3 * 73
 EQUW savedPositions0 + 4 * 73
 EQUW savedPositions0 + 5 * 73
 EQUW savedPositions0 + 6 * 73
 EQUW savedPositions0 + 7 * 73

; ******************************************************************************
;
;       Name: positionAddr1
;       Type: Variable
;   Category: Save and load
;    Summary: The address of the second save slot for each saved position
;
; ******************************************************************************

.positionAddr1

 EQUW savedPositions1 + 0 * 73
 EQUW savedPositions1 + 1 * 73
 EQUW savedPositions1 + 2 * 73
 EQUW savedPositions1 + 3 * 73
 EQUW savedPositions1 + 4 * 73
 EQUW savedPositions1 + 5 * 73
 EQUW savedPositions1 + 6 * 73
 EQUW savedPositions1 + 7 * 73

; ******************************************************************************
;
;       Name: positionAddr2
;       Type: Variable
;   Category: Save and load
;    Summary: The address of the third save slot for each saved position
;
; ******************************************************************************

.positionAddr2

 EQUW savedPositions2 + 0 * 73
 EQUW savedPositions2 + 1 * 73
 EQUW savedPositions2 + 2 * 73
 EQUW savedPositions2 + 3 * 73
 EQUW savedPositions2 + 4 * 73
 EQUW savedPositions2 + 5 * 73
 EQUW savedPositions2 + 6 * 73
 EQUW savedPositions2 + 7 * 73

; ******************************************************************************
;
;       Name: ResetSaveBuffer
;       Type: Subroutine
;   Category: Save and load
;    Summary: ???
;
; ******************************************************************************

.ResetSaveBuffer

 PHA

.loop_CB779

 LDX #78

.loop_CB77B

 LDA NA2%,X
 STA BUF,X
 DEX
 BPL loop_CB77B
 PLA
 RTS

; ******************************************************************************
;
;       Name: UpdateSaveSlot
;       Type: Subroutine
;   Category: Save and load
;    Summary: Update the save slots for a specific saved positions
;
; ------------------------------------------------------------------------------
;
; Arguments:
;
;   A                   The number of the saved position to update
;
; ******************************************************************************

.UpdateSaveSlot

 PHA

 JSR SetupPPUForIconBar ; If the PPU has started drawing the icon bar, configure
                        ; the PPU to use nametable 0 and pattern table 0

 CMP #9
 BEQ CB7E7
 CMP #8
 BEQ loop_CB779
 JSR GetSaveSlotAddress
 LDY #72

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

 LDA saveChecksums,Y
 STA BUF+73,X
 INY
 INX
 CPX #6
 BNE loop_CB7D9
 PLA
 RTS

.CB7E7

 LDA SVC
 AND #$7F
 STA SVC
 LDX #$4E

.loop_CB7F1

 LDA NAME,X
 STA currentPosition,X
 STA BUF,X
 DEX
 BPL loop_CB7F1
 PLA
 RTS

.CB7FF

 JSR ResetSaveBuffer
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
 JSR SaveToSlots
 PLA
 RTS

; ******************************************************************************
;
;       Name: ResetSaveSlots
;       Type: Subroutine
;   Category: Save and load
;    Summary: Reset the save slots for all eight saved positions
;
; ******************************************************************************

.ResetSaveSlots

 LDX #7                 ; There are eight save slots, so set a slot counter in X
                        ; to loop through them all

.rsav1

 TXA                    ; Store the slot counter on the stack, copying the slot
 PHA                    ; number into A in the process

 JSR GetSaveSlotAddress ; Set the following for saved position X:
                        ;
                        ;   SC(1 0) = address of the first save slot
                        ;
                        ;   Q(1 0) = address of the second save slot
                        ;
                        ;   S(1 0) = address of the third save slot

 LDY #10                ; We reset a saved position by writing to byte #10 in
                        ; each of the three save slots, so set Y to use as an
                        ; index

 LDA #1                 ; Set byte #10 of the first save slot to 1
 STA (SC),Y

 LDA #3                 ; Set byte #10 of the second save slot to 3
 STA (Q),Y

 LDA #7                 ; Set byte #10 of the third save slot to 7
 STA (S),Y

 PLA                    ; Retrieve the slot counter from the stack into X
 TAX

 DEX                    ; Decrement the slot counter

 BPL rsav1              ; Loop back until we have reset the three slots for all
                        ; eight saved positions

 RTS                    ; Return from the subroutine

; ******************************************************************************
;
;       Name: GetSaveSlotAddress
;       Type: Subroutine
;   Category: Save and load
;    Summary: Fetch the addresses of the three save slots for a specific saved
;             position
;
; ------------------------------------------------------------------------------
;
; Arguments:
;
;   A                   The number of the saved position
;
; ******************************************************************************

.GetSaveSlotAddress

 ASL A                  ; Set X = A * 2
 TAX                    ;
                        ; So we can use X as an index into the positionAddr
                        ; tables, which contain two-byte addresses

 LDA positionAddr0,X    ; Set the following:
 STA SC                 ;
 LDA positionAddr1,X    ;   SC(1 0) = X-th address from positionAddr0, i.e. the
 STA Q                  ;             address of the first save slot for slot X
 LDA positionAddr2,X    ;
 STA S                  ;   Q(1 0) = X-th address from positionAddr1, i.e. the
 LDA positionAddr0+1,X  ;            address of the second save slot for slot X
 STA SC+1               ;
 LDA positionAddr1+1,X  ;   S(1 0) = X-th address from positionAddr2, i.e. the
 STA Q+1                ;            address of the third save slot for slot X
 LDA positionAddr2+1,X
 STA S+1

 RTS                    ; Return from the subroutine

; ******************************************************************************
;
;       Name: SaveToSlots
;       Type: Subroutine
;   Category: Save and load
;    Summary: ???
;
; ******************************************************************************

.SaveToSlots

 PHA
 CMP #9
 BEQ CB879
 JSR GetSaveSlotAddress
 LDA BUF+7
 AND #$7F
 STA BUF+7

 LDY #72

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

 PHA

.CB879

 LDX #$4E

.loop_CB87B

 LDA BUF,X
 STA currentPosition,X
 STA NAME,X
 DEX
 BPL loop_CB87B
 JSR StartAfterLoad_b0
 PLA
 RTS

; ******************************************************************************
;
;       Name: UpdateSaveSlots
;       Type: Subroutine
;   Category: Save and load
;    Summary: Update the save slots for all eight saved positions
;
; ******************************************************************************

.UpdateSaveSlots

 LDA #7                 ; There are eight saved positions, so set a position
                        ; counter in A to loop through them all

.sabf1

 PHA                    ; Wait until the next NMI interrupt has passed (i.e. the
 JSR WaitForNMI         ; next VBlank), preserving the value in A via the stack
 PLA

 JSR UpdateSaveSlot     ; Update the save slots for saved position A

 SEC                    ; Decrement A to move on to the next saved position
 SBC #1

 BPL sabf1              ; Loop back until we have transferred all eight saved
                        ; positions

 RTS                    ; Return from the subroutine

; ******************************************************************************
;
;       Name: NA2%
;       Type: Variable
;   Category: Save and load
;    Summary: The data block for the default commander
;
; ******************************************************************************

.NA2%

 EQUS "JAMESON"         ; The current commander name, which defaults to JAMESON

 EQUB 1                 ; SVC = Save count, which is stored in the terminator
                        ; byte for the commander name

 EQUB 0                 ; TP = Mission status, #0

 EQUB 20                ; QQ0 = Current system X-coordinate (Lave), #1
 EQUB 173               ; QQ1 = Current system Y-coordinate (Lave), #2

IF Q%
 EQUD &00CA9A3B         ; CASH = Amount of cash (100,000,000 Cr), #3-6
ELSE
 EQUD &E8030000         ; CASH = Amount of cash (100 Cr), #3-6
ENDIF

 EQUB 70                ; QQ14 = Fuel level, #7

 EQUB 0                 ; COK = Competition flags, #8

 EQUB 0                 ; GCNT = Galaxy number, 0-7, #9

IF Q%
 EQUB Armlas            ; LASER = Front laser, #10
ELSE
 EQUB POW+9             ; LASER = Front laser, #10
ENDIF

 EQUB (POW+9 AND Q%)    ; LASER = Rear laser, #11

 EQUB (POW+128) AND Q%  ; LASER+2 = Left laser, #12

 EQUB Mlas AND Q%       ; LASER+3 = Right laser, #13

 EQUB 22 + (15 AND Q%)  ; CRGO = Cargo capacity, #14

 EQUB 0                 ; QQ20+0  = Amount of food in cargo hold, #15
 EQUB 0                 ; QQ20+1  = Amount of textiles in cargo hold, #16
 EQUB 0                 ; QQ20+2  = Amount of radioactives in cargo hold, #17
 EQUB 0                 ; QQ20+3  = Amount of slaves in cargo hold, #18
 EQUB 0                 ; QQ20+4  = Amount of liquor/Wines in cargo hold, #19
 EQUB 0                 ; QQ20+5  = Amount of luxuries in cargo hold, #20
 EQUB 0                 ; QQ20+6  = Amount of narcotics in cargo hold, #21
 EQUB 0                 ; QQ20+7  = Amount of computers in cargo hold, #22
 EQUB 0                 ; QQ20+8  = Amount of machinery in cargo hold, #23
 EQUB 0                 ; QQ20+9  = Amount of alloys in cargo hold, #24
 EQUB 0                 ; QQ20+10 = Amount of firearms in cargo hold, #25
 EQUB 0                 ; QQ20+11 = Amount of furs in cargo hold, #26
 EQUB 0                 ; QQ20+12 = Amount of minerals in cargo hold, #27
 EQUB 0                 ; QQ20+13 = Amount of gold in cargo hold, #28
 EQUB 0                 ; QQ20+14 = Amount of platinum in cargo hold, #29
 EQUB 0                 ; QQ20+15 = Amount of gem-stones in cargo hold, #30
 EQUB 0                 ; QQ20+16 = Amount of alien items in cargo hold, #31

 EQUB Q%                ; ECM = E.C.M. system, #32

 EQUB Q%                ; BST = Fuel scoops ("barrel status"), #33

 EQUB Q% AND 127        ; BOMB = Energy bomb, #34

 EQUB Q% AND 1          ; ENGY = Energy/shield level, #35

 EQUB Q%                ; DKCMP = Docking computer, #36

 EQUB Q%                ; GHYP = Galactic hyperdrive, #37

 EQUB Q%                ; ESCP = Escape pod, #38

 EQUW 0                 ; TRIBBLE = Number of Trumbles in the cargo hold, #39-40

 EQUB 0                 ; TALLYL = Combat rank fraction, #41

 EQUB 3 + (Q% AND 1)    ; NOMSL = Number of missiles, #42

 EQUB 0                 ; FIST = Legal status ("fugitive/innocent status"), #43

 EQUB 16                ; AVL+0  = Market availability of food, #44
 EQUB 15                ; AVL+1  = Market availability of textiles, #45
 EQUB 17                ; AVL+2  = Market availability of radioactives, #46
 EQUB 0                 ; AVL+3  = Market availability of slaves, #47
 EQUB 3                 ; AVL+4  = Market availability of liquor/Wines, #48
 EQUB 28                ; AVL+5  = Market availability of luxuries, #49
 EQUB 14                ; AVL+6  = Market availability of narcotics, #50
 EQUB 0                 ; AVL+7  = Market availability of computers, #51
 EQUB 0                 ; AVL+8  = Market availability of machinery, #52
 EQUB 10                ; AVL+9  = Market availability of alloys, #53
 EQUB 0                 ; AVL+10 = Market availability of firearms, #54
 EQUB 17                ; AVL+11 = Market availability of furs, #55
 EQUB 58                ; AVL+12 = Market availability of minerals, #56
 EQUB 7                 ; AVL+13 = Market availability of gold, #57
 EQUB 9                 ; AVL+14 = Market availability of platinum, #58
 EQUB 8                 ; AVL+15 = Market availability of gem-stones, #59
 EQUB 0                 ; AVL+16 = Market availability of alien items, #60

 EQUB 0                 ; QQ26 = Random byte that changes for each visit to a
                        ; system, for randomising market prices, #61

 EQUW 20000 AND Q%      ; TALLY = Number of kills, #62-63

 EQUB 128               ; ??? #64

 EQUW $5A4A             ; QQ21 = Seed s0 for system 0, galaxy 0 (Tibedied), #65
 EQUW $0248             ; QQ21 = Seed s1 for system 0, galaxy 0 (Tibedied), #67
 EQUW $B753             ; QQ21 = Seed s2 for system 0, galaxy 0 (Tibedied), #69

 EQUB $AA               ; ??? #71
 EQUB $27               ; ??? #72
 EQUB $03               ; ??? #73

 EQUD 0                 ; These bytes appear to be unused, #74-#85
 EQUD 0
 EQUD 0
 EQUD 0

; ******************************************************************************
;
;       Name: ResetCommander
;       Type: Subroutine
;   Category: Save and load
;    Summary: Reset the current commander and current position to the default
;             "JAMESON" commander
;
; ******************************************************************************

.ResetCommander

 JSR JAMESON            ; Set the current position to the default "JAMESON"
                        ; commander

 LDX #79                ; We want to copy 78 bytes from the current position at
                        ; currentPosition to the current commander at NAME, so
                        ; set a byte counter in X (which counts down from 79 to
                        ; 1 as we copy bytes 78 to 0)

.resc1

 LDA currentPosition-1,X    ; Copy byte X-1 from currentPosition to byte X-1 of
 STA NAME-1,X               ; NAME

 DEX                    ; Decrement the byte counter

 BNE resc1              ; Loop back until we have copied all 78 bytes

 RTS                    ; Return from the subroutine

; ******************************************************************************
;
;       Name: JAMESON
;       Type: Subroutine
;   Category: Save and load
;    Summary: Set the current position to the default "JAMESON" commander
;
; ******************************************************************************

.JAMESON

 LDY #94                ; We want to copy 94 bytes from the default commander
                        ; at NA2% to the current position at currentPosition, so
                        ; set a byte counter in Y

.jame1

 LDA NA2%,Y             ; Copy the Y-th byte of NA2% to the Y-th byte of
 STA currentPosition,Y  ; currentPosition

 DEY                    ; Decrement the byte counter

 BPL jame1              ; Loop back until we have copied all 94 bytes

 RTS                    ; Return from the subroutine

; ******************************************************************************
;
;       Name: DrawLightning
;       Type: Subroutine
;   Category: Flight
;    Summary: ???
;
; ******************************************************************************

.DrawLightning

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
 STA X1
 LDA K3
 STA Y1
 LDY #7

.CB945

 JSR DORND
 STA Q
 LDA K+1

 JSR FMLTU              ; Set A = A * Q / 256

 CLC
 ADC K3
 SEC
 SBC XX2+1
 STA Y2
 LDA X1
 CLC
 ADC STP
 STA X2
 JSR LOIN
 LDA SWAP
 BNE CB96E
 LDA X2
 STA X1
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
;   Category: Flight
;    Summary: Make the hyperspace sound and draw the hyperspace tunnel
;
; ******************************************************************************

.LL164

 JSR WaitForPPUToFinish ; Wait until both bitplanes of the screen have been
                        ; sent to the PPU, so the screen is fully updated and
                        ; there is no more data waiting to be sent to the PPU

 JSR HideStardust       ; ???

 JSR HideExplosionBurst ; Hide the four sprites that make up the explosion burst

 JSR HyperspaceSound
 LDA #$80
 STA K+2
 LDA #$48
 STA K+3
 LDA #$40
 STA XP

.CB999

 JSR CheckPauseButton
 JSR DORND
 AND #$0F
 TAX
 LDA hyperspaceColour,X
 STA visibleColour
 JSR FlipDrawingPlane
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
 LDA halfScreenHeight
 SBC K+1
 BCC CB9B9
 BEQ CB9B9
 TAY
 JSR HLOIN
 INC X2
 LDA K+1
 CLC
 ADC halfScreenHeight
 TAY
 JSR HLOIN
 INC X2
 JMP CB9B9

.CB9FB

 JSR DrawBitplaneInNMI
 DEC XP
 BNE CB999

 JMP WaitForPPUToFinish ; Wait until both bitplanes of the screen have been
                        ; sent to the PPU, so the screen is fully updated and
                        ; there is no more data waiting to be sent to the PPU,
                        ; and return from the subroutine using a tail call

; ******************************************************************************
;
;       Name: hyperspaceColour
;       Type: Variable
;   Category: Flight
;    Summary: ???
;
; ******************************************************************************

.hyperspaceColour

 EQUB $06, $0F, $38, $2A, $23, $25, $22, $11  ; BA06: 06 0F 38... ..8
 EQUB $1A, $00, $26, $2C, $20, $13, $0F, $00  ; BA0E: 1A 00 26... ..&

; ******************************************************************************
;
;       Name: DrawLaunchBoxes
;       Type: Subroutine
;   Category: Flight
;    Summary: ???
;
; ******************************************************************************

.CBA16

 RTS

.DrawLaunchBoxes

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
 JSR DrawVerticalLine
 LDA K+2
 SEC
 SBC K
 BCC CBA16
 STA XX15
 JSR DrawVerticalLine
 INC XX15
 LDY Y1
 BEQ CBA56
 JSR HLOIN
 INC X2

.CBA56

 DEC XX15
 INC X2
 LDY Y2
 CPY Yx2M1
 BCS CBA16
 JMP HLOIN

; ******************************************************************************
;
;       Name: InputName
;       Type: Subroutine
;   Category: Controllers
;    Summary: Get a name from the keyboard for searching the galaxy or changing
;             commander name
;
; ******************************************************************************

.InputName

 LDY #0

.CBA65

 LDA INWK+5,Y
 CMP #$41
 BCS CBA6E
 LDA #$41

.CBA6E

 PHA
 PLA
 JSR ChangeLetter
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

 JSR DrawMessageInNMI   ; Configure the NMI to display the message that we just
                        ; printed

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
;       Name: ChangeLetter
;       Type: Subroutine
;   Category: Keyopard
;    Summary: ???
;
; ******************************************************************************

.ChangeLetter

 TAX
 STY YSAV
 LDA fontBitplane
 PHA
 LDA QQ11
 AND #$20
 BEQ CBADB

 LDA #1                 ; Set the font bitplane to print in plane 1
 STA fontBitplane

.CBADB

 TXA

.CBADC

 PHA

 LDY #4                 ; Wait until four NMI interrupts have passed (i.e. the
 JSR DELAY              ; next four VBlanks)

 PLA
 PHA
 JSR CHPR_b2
 DEC XC

 JSR DrawMessageInNMI   ; Configure the NMI to display the message that we just
                        ; printed

 SEC
 LDA controller1A
 BMI CBB2A
 CLC
 PLA
 LDX controller1B
 BMI CBADC
 LDX pointerButton
 BNE CBB33
 LDX controller1Leftx8
 BMI CBB26
 LDX controller1Rightx8
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
 STA fontBitplane
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
;   Category: Save and load
;    Summary: ???
;
; ******************************************************************************

.ChangeCmdrName

 JSR CLYNS              ; Clear the bottom three text rows of the upper screen,
                        ; and move the text cursor to column 1 on row 21, i.e.
                        ; the start of the top row of the three bottom rows

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
 JSR InputName
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
 LDX languageIndex

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

 JSR CLYNS              ; Clear the bottom three text rows of the upper screen,
                        ; and move the text cursor to column 1 on row 21, i.e.
                        ; the start of the top row of the three bottom rows

 JMP DrawMessageInNMI   ; Configure the NMI to display the message that we just
                        ; printed, returning from the subroutine using a tail
                        ; call

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
;   Category: Controllers
;    Summary: ???
;
; ******************************************************************************

.SetKeyLogger

 TYA
 PHA
 LDX #5
 LDA #0
 STA pressedButton

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
 LDA pointerButton
 STX pointerButton
 STA pressedButton
 PLA
 TAY
 LDA pressedButton
 TAX
 RTS

; ******************************************************************************
;
;       Name: ChooseLanguage
;       Type: Subroutine
;   Category: Start and end
;    Summary: Draw the Start screen and process the language choice
;
; ------------------------------------------------------------------------------
;
; Arguments:
;
;   K%                  The value of the second counter (we start the demo on
;                       auto-play once all three counters have run down without
;                       a choice being made)
;
;   K%+1                The value of the third counter (we start the demo on
;                       auto-play once all three counters have run down without
;                       a choice being made)
;
; ******************************************************************************

.ChooseLanguage

 LDA #HI(iconBarImage0) ; Set iconBarImageHi to the high byte of the image data
 STA iconBarImageHi     ; for icon bar type 0 (docked)

 LDY #0                 ; Clear bit 7 of autoPlayDemo so we do not play the demo
 STY autoPlayDemo       ; automatically (so the player plays the demo instead)

 JSR SetLanguage        ; Set the language-related variables to language 0
                        ; (English) as Y = 0, so English is the default language

 LDA #$CF               ; Clear the screen and and set the view type in QQ11 to
 JSR TT66_b0            ; $CF (Start screen with no font loaded)

 LDA #HI(iconBarImage3) ; Set iconBarImageHi to the high byte of the image data
 STA iconBarImageHi     ; for icon bar type 3 (pause options)

 LDA #0                 ; Move the text cursor to row 0
 STA YC

 LDA #7                 ; Move the text cursor to column 7
 STA XC

 LDA #3                 ; Set A = 3 so the next instruction prints extended
                        ; token 3

IF _PAL

 JSR DETOK_b2           ; Print extended token 3 ("{sentence case}{single cap}
                        ; IMAGINEER {single cap}PRESENTS")

ENDIF

 LDA #$DF               ; Set the view type in QQ11 to $DF (Start screen with
 STA QQ11               ; font loaded in both bitplanes)

 JSR DrawBigLogo_b4     ; Set the pattern and nametable buffer entries for the
                        ; big Elite logo

 LDA #36                ; Set asciiToPattern = 36, so we add 36 to an ASCII code
 STA asciiToPattern     ; in the CHPR routine to get the pattern number in the
                        ; PPU of the corresponding character image (as the font
                        ; is at pattern 68 on the Start screen, and the font
                        ; starts with a space character, which is ASCII 32, and
                        ; 32 + 36 = 68)

 LDA #21                ; Move the text cursor to row 21
 STA YC

 LDA #10                ; Move the text cursor to column 10
 STA XC

 LDA #6                 ; Set A = 6 so the next instruction prints extended
                        ; token 6

IF _PAL

 JSR DETOK_b2           ; Print extended token 6 ("{single cap}LICENSED{cr} TO")

ENDIF

 INC YC                 ; Move the text cursor to row 22

 LDA #3                 ; Move the text cursor to column 3
 STA XC

 LDA #9                 ; Set A = 9 so the next instruction prints extended
                        ; token 9

IF _PAL

 JSR DETOK_b2           ; Print extended token 9 ("{single cap}IMAGINEER {single
                        ; cap}CO. {single cap}LTD., {single cap}JAPAN")

ENDIF

 LDA #25                ; Move the text cursor to row 25
 STA YC

 LDA #3                 ; Move the text cursor to column 3
 STA XC

 LDA #12                ; Print extended token 12 ("({single cap}C) {single cap}
 JSR DETOK_b2           ; D.{single cap}BRABEN & {sentence case}I.{single cap}
                        ; BELL 1991")

 LDA #26                ; Move the text cursor to row 26
 STA YC

 LDA #6                 ; Move the text cursor to column 6
 STA XC

 LDA #7                 ; Set A = 7 so the next instruction prints extended
                        ; token 7

IF _PAL

 JSR DETOK_b2           ; Print extended token 7 ("{single cap}LICENSED BY
                        ;  {single cap}NINTENDO")

ENDIF

                        ; We now draw the bottom of the box that goes around the
                        ; edge of the title screen, with the bottom line on tile
                        ; row 28 and an edge on either side of row 27

 LDY #2                 ; First we draw the horizontal line from tile 2 to 31 on
                        ; row 28, so set a tile index in Y

 LDA #229               ; Set A to the pattern to use for the bottom of the box,
                        ; which is in pattern 229

.clan1

 STA nameBuffer0+28*32,Y    ; Set tile Y on row 28 to pattern 229

 INY                    ; Increment the tile index

 CPY #32                ; Loop back until we have drawn from tile index 2 to 31
 BNE clan1

                        ; Next we draw the corners and the tiles above the
                        ; corners

 LDA #2                 ; Draw the bottom-right box corner and the tile above
 STA nameBuffer0+27*32
 STA nameBuffer0+28*32

 LDA #1                 ; Draw the bottom-left box corner and the tile above
 STA nameBuffer0+27*32+1
 STA nameBuffer0+28*32+1

                        ; We now display the language names so the player can
                        ; make their choice

 LDY #0                 ; We now work our way through the available languages,
                        ; starting with language 0, so set a language counter
                        ; in Y

.clan2

 JSR SetLanguage        ; Set the language-related variables to language Y

 LDA xLanguage,Y        ; Move the text cursor to the correct column for the
 STA XC                 ; language Y button, taken from the xLanguage table

 LDA yLanguage,Y        ; Move the text cursor to the correct row for the
 STA YC                 ; language Y button, taken from the yLanguage table

 LDA #%00000000         ; Set DTW8 = %00000000 (capitalise the next letter)
 STA DTW8

 LDA #4                 ; Print extended token 4, which is the language name,
 JSR DETOK_b2           ; so when Y = 0 it will be "{single cap}ENGLISH", for
                        ; example

 INC XC                 ; Move the text cursor two characters to the right
 INC XC

 INY                    ; Increment the language counter in Y

 LDA languageIndexes,Y  ; If the language index for language Y has bit 7 clear
 BPL clan2              ; then this is a valid language, so loop back to clan2
                        ; to print this language's name (language 3 has a value
                        ; of $FF in the languageIndexes table, so we only print
                        ; names for languages 0, 1 and 2)

 STY systemNumber       ; Set systemNumber = 3 ???

 LDA #HI(iconBarImage3) ; Set iconBarImageHi to the high byte of the image data
 STA iconBarImageHi     ; for icon bar type 3 (pause options)

 JSR UpdateView_b0      ; Update the view

 LDA controller1Left    ; If any of the left button, up button, Select or B are
 AND controller1Up      ; not being pressed on the controller, jump to clan3
 AND controller1Select
 AND controller1B
 BPL clan3

 LDA controller1Right   ; If any of the right button, down button, Start or A
 ORA controller1Down    ; are being pressed on the controller, jump to clan3
 ORA controller1Start
 ORA controller1A
 BMI clan3

                        ; If we get here then we are pressing the right button,
                        ; down button, Start and A, and we are not pressing any
                        ; of the other keys

 JSR ResetSaveSlots     ; Reset the save slots for all eight saved positions

.clan3

 JSR UpdateSaveSlots_b6 ; Update the save slots for all eight saved positions

                        ; We now highlight the currently selected language name
                        ; on-screen

 LDA #%10000000         ; Set bit 7 of S to indicate that the choice has not yet
 STA S                  ; been made (we will clear bit 7 when Start is pressed
                        ; and release, which makes the choice)

IF _NTSC

 LDA #25                ; Set T = 25
 STA T                  ;
                        ; This is the value of the first counter (we start the
                        ; demo on auto-play once all three counters have run
                        ; down without a choice being made)

ELIF _PAL

 LDA #250               ; Set T = 250
 STA T                  ;
                        ; This is the value of the first counter (we start the
                        ; demo on auto-play once all three counters have run
                        ; down without a choice being made)

ENDIF

 LDA K%+1               ; Set V+1 = K%+1
 STA V+1                ;
                        ; We set K%+1 to 60 in the BEGIN routine when the game
                        ; first started
                        ;
                        ; We set K%+1 to 5 if we get here after waiting at the
                        ; title screen for too long
                        ;
                        ; This is the value of the third counter (we start the
                        ; demo on auto-play once all three counters have run
                        ; down without a choice being made)

 LDA #0                 ; Set V = 0
 STA V                  ;
                        ; This is the value of the second counter (we start the
                        ; demo on auto-play once all three counters have run
                        ; down without a choice being made)
                        ;
                        ; As the counter is decremented before checking whether
                        ; it is zero, this means the second counter counts down
                        ; 256 times

 STA Q                  ; Set Q = 0 (though this value is not read, so this has
                        ; no effect)

 LDA K%                 ; Set LASCT = K%
 STA LASCT              ;
                        ; We set K% to 0 in the BEGIN routine when the game
                        ; first started
                        ;
                        ; We set K% to languageIndex if we get here after
                        ; waiting at the title screen for too long
                        ;
                        ; We use LASCT to keep a track of the currently
                        ; highlighted language, so this sets the default
                        ; highlight to English (language 0)

.clan4

 JSR WaitForNMI         ; Wait until the next NMI interrupt has passed (i.e. the
                        ; next VBlank)

                        ; We now highlight the currently selected language name
                        ; on-screen by creating eight sprites containing a white
                        ; block, initially creating them off-screen, before
                        ; moving the correct number of sprites behind the
                        ; currently selected name, so each letter in the name
                        ; is highlighted

 LDY LASCT              ; Set Y to the currently highlighted language in LASCT

 LDA xLanguage,Y        ; Set A to the column number of the button for language
                        ; Y, taken from the xLanguage table

 ASL A                  ; Set X = A * 8
 ASL A                  ;
 ASL A                  ; So X contains the pixel x-coordinate of the language
 ADC #0                 ; button, as each tile is eight pixels wide
 TAX

 CLC                    ; Clear the C flag so the addition below will work

 LDY #0                 ; We are about to set up the eight sprites that we use
                        ; to highlight the current language choice, using
                        ; sprites 5 to 12, so set an index counter in Y that we
                        ; can use to point to each sprite in the sprite buffer

.clan5

                        ; We now set the coordinates, tile and attributes for
                        ; the Y-th sprite, starting from sprite 5

 LDA #240               ; Set the sprite's y-coordinate to 240 to move it off
 STA ySprite5,Y         ; the bottom of the screen (which hides it)

 LDA #255               ; Set the sprite to tile pattern 255, which is a full
 STA tileSprite5,Y      ; white block

 LDA #%00100000         ; Set the attributes for this sprite as follows:
 STA attrSprite5,Y      ;
                        ;     * Bits 0-1    = sprite palette 0
                        ;     * Bit 5 set   = show behind background
                        ;     * Bit 6 clear = do not flip horizontally
                        ;     * Bit 7 clear = do not flip vertically

 TXA                    ; Set the sprite's x-coordinate to X, which is the
 STA xSprite5,Y         ; x-coordinate for the current letter in the
                        ; language's button

 ADC #8                 ; Set X = X + 8
 TAX                    ;
                        ; So X now contains the pixel x-coordinate of the next
                        ; letter in the language's button

 INY                    ; Set Y = Y + 4
 INY                    ;
 INY                    ; So Y now points to the next sprite in the sprite
 INY                    ; buffer, as each sprite has four bytes in the buffer

 CPY #32                ; Loop back until we have set up all eight sprites for
 BNE clan5              ; the currently highlighted language

                        ; Now that we have created the eight sprites off-screen,
                        ; we move the correct number of then on-screen so they
                        ; display behind each letter of the currently
                        ; highlighted language name

 LDX LASCT              ; Set X to the currently highlighted language in LASCT

 LDA languageLength,X   ; Set Y to the number of characters in the currently
                        ; highlighted language's name, from the languageLength
                        ; table

 ASL A                  ; Set Y = A * 4
 ASL A                  ;
 TAY                    ; So Y contains an index into the sprite buffer for the
                        ; last sprite that we need from the eight available (as
                        ; we need one sprite for each character in the name)

 LDA yLanguage,X        ; Set A to the row number of the button for language Y,
                        ; taken from the yLanguage table

 ASL A                  ; Set A = A * 8 + 6
 ASL A                  ;
 ASL A                  ; So A contains the pixel y-coordinate of the language
 ADC #6+YPAL            ; button, as each tile row is eight pixels high, plus a
                        ; margin of 6

.clan6

 STA ySprite5,Y         ; Set the sprite's y-coordinate to A

 DEY                    ; Decrement the sprite number by 4 to point to the
 DEY                    ; sprite for the previous letter in the language name
 DEY
 DEY

 BPL clan6              ; Loop back until we have moved the sprite on-screen for
                        ; the first letter of the currently highlighted
                        ; language's name

 LDA controller1Start   ; If the Start button on controller 1 was being held
 AND #%11000000         ; down (bit 6 is set) but is no longer being held down
 CMP #%01000000         ; (bit 7 is clear) then keep going, otherwise jump to
 BNE clan7              ; clan7

 LSR S                  ; The Start button has been pressed and release, so
                        ; shift S right to clear bit 7

.clan7

 LDX LASCT              ; Set X to the currently highlighted language in LASCT

 LDA controller1Left    ; If the left button on controller 1 was being held
 AND #%11000000         ; down (bit 6 is set) but is no longer being held down
 CMP #%01000000         ; (bit 7 is clear) then keep going, otherwise jump to
 BNE clan8              ; clan8

 DEX                    ; Decrement the currently highlighted language to point
                        ; to the next language to the left

 LDA K%+1               ; Set V+1 = K%+1
 STA V+1                ;
                        ; We already did this above, so this has no effect

.clan8

 LDA controller1Right   ; If the right button on controller 1 was being held
 AND #%11000000         ; down (bit 6 is set) but is no longer being held down
 CMP #%01000000         ; (bit 7 is clear) then keep going, otherwise jump to
 BNE clan9              ; clan9

 INX                    ; Increment the currently highlighted language to point
                        ; to the next language to the right

 LDA K%+1               ; Set V+1 = K%+1
 STA V+1                ;
                        ; We already did this above, so this has no effect

.clan9

 TXA                    ; Set A to the currently selected language, which may or
                        ; may not have changed

 BPL clan10             ; If A is positive, jump to clan10 to skip the following
                        ; instruction

 LDA #0                 ; Set A = 0, so the minimum value of A is 0

.clan10

 CMP #3                 ; If A < 3, then jump to clan11 to skip the following
 BCC clan11             ; instruction

 LDA #2                 ; Set A = 2, so the maximum value of A is 2

.clan11

 STA LASCT              ; Set LASCT to the currently selected language

 DEC T                  ; Decrement the first counter in T

 BEQ clan13             ; If the counter in T has reached zero, jump to clan13
                        ; to check whether a choice has been made, and if not,
                        ; to count down the second and third counters

.clan12

 JMP clan4              ; Loop back to clan4 keep checking for the selection and
                        ; moving the highlight as required, until a choice is
                        ; made

.clan13

 INC T                  ; Increment the first counter in T so we jump here again
                        ; on the next run through the clan4 loop

 LDA S                  ; If bit 7 of S is clear then Start has been pressed and
 BPL SetChosenLanguage  ; released, so jump to SetChosenLanguage to set the
                        ; language-related variables according to the chosen
                        ; language, returning from the subroutine using a tail
                        ; call

 DEC V                  ; Decrement the second counter in V, and loop back to
 BNE clan12             ; repeat the clan4 loop until it is zero

 DEC V+1                ; Decrement the third counter in V+1, and loop back to
 BNE clan12             ; repeat the clan4 loop until it is zero

                        ; If we get here then no choice has been made and we
                        ; have run down the first, second and third counters, so
                        ; we now start the demo, with the computer auto-playing
                        ; it

 JSR SetChosenLanguage  ; Call SetChosenLanguage to set the language-related
                        ; variables according to the currently selected language
                        ; on-screen

 JMP SetDemoAutoPlay_b5 ; Start the demo and auto-play it by "pressing" keys
                        ; from the relevant key table (which will be different,
                        ; depending on which language is currently highlighted)
                        ; and return from the subroutine using a tail call

; ******************************************************************************
;
;       Name: SetChosenLanguage
;       Type: Subroutine
;   Category: Start and end
;    Summary: Set the language-related variables according to the language
;             chosen on the Start screen
;
; ******************************************************************************

.SetChosenLanguage

 LDY LASCT              ; Set Y to the language choice, which gets stored in
                        ; LASCT by the ChooseLanguage routine

                        ; Fall through to set the language chosen in Y

; ******************************************************************************
;
;       Name: SetLanguage
;       Type: Subroutine
;   Category: Start and end
;    Summary: Set the language-related variables for a specific language
;
; ------------------------------------------------------------------------------
;
; Arguments:
;
;   Y                   The number of the language choice to set
;
; ******************************************************************************

.SetLanguage

 LDA tokensLo,Y         ; Set (QQ18Hi QQ18Lo) to the language's entry from the
 STA QQ18Lo             ; (tokensHi tokensLo) table
 LDA tokensHi,Y
 STA QQ18Hi

 LDA extendedTokensLo,Y ; Set (TKN1Hi TKN1Lo) to the language's entry from the
 STA TKN1Lo             ; the (extendedTokensHi extendedTokensLo) table
 LDA extendedTokensHi,Y
 STA TKN1Hi

 LDA languageIndexes,Y  ; Set languageIndex to the language's index from the
 STA languageIndex      ; languageIndexes table

 LDA languageNumbers,Y  ; Set languageNumber to the language's flags from the
 STA languageNumber     ; languageNumbers table

 LDA characterEndLang,Y ; Set characterEnd to the end of the language's
 STA characterEnd       ; character set from the characterEndLang table

 LDA decimalPointLang,Y ; Set decimalPoint to the language's decimal point
 STA decimalPoint       ; character from the decimalPointLang table

 RTS                    ; Return from the subroutine

; ******************************************************************************
;
;       Name: xLanguage
;       Type: Variable
;   Category: Start and end
;    Summary: The text column for the language buttons on the Start screen
;
; ******************************************************************************

.xLanguage

 EQUB 2                 ; English

 EQUB 12                ; German

 EQUB 22                ; French

 EQUB 17                ; There is no fourth language, so this byte is ignored

; ******************************************************************************
;
;       Name: yLanguage
;       Type: Variable
;   Category: Start and end
;    Summary: The text row for the language buttons on the Start screen
;
; ******************************************************************************

.yLanguage

 EQUB 23                ; English

 EQUB 24                ; German

 EQUB 23                ; French

 EQUB 24                ; There is no fourth language, so this byte is ignored

; ******************************************************************************
;
;       Name: characterEndLang
;       Type: Variable
;   Category: Text
;    Summary: The number of the character beyond the end of the printable
;             character set in each language
;
; ******************************************************************************

.characterEndLang

 EQUB 91                ; English

 EQUB 96                ; German

 EQUB 96                ; French

 EQUB 96                ; There is no fourth language, so this byte is ignored

; ******************************************************************************
;
;       Name: decimalPointLang
;       Type: Variable
;   Category: Text
;    Summary: The decimal point character to use for each language
;
; ******************************************************************************

.decimalPointLang

 EQUB '.'               ; English

 EQUB '.'               ; German

 EQUB ','               ; French

 EQUB '.'               ; There is no fourth language, so this byte is ignored

; ******************************************************************************
;
;       Name: languageLength
;       Type: Variable
;   Category: Text
;    Summary: The length of each language name
;
; ******************************************************************************

.languageLength

 EQUB 6                 ; English

 EQUB 6                 ; German

 EQUB 7                 ; French

; ******************************************************************************
;
;       Name: tokensLo
;       Type: Variable
;   Category: Text
;    Summary: Low byte of the text token table for each language
;
; ******************************************************************************

.tokensLo

 EQUB LO(QQ18)          ; English

 EQUB LO(QQ18_DE)       ; German

 EQUB LO(QQ18_FR)       ; French

; ******************************************************************************
;
;       Name: tokensHi
;       Type: Variable
;   Category: Text
;    Summary: High byte of the text token table for each language
;
; ******************************************************************************

.tokensHi

 EQUB HI(QQ18)          ; English

 EQUB HI(QQ18_DE)       ; German

 EQUB HI(QQ18_FR)       ; French

; ******************************************************************************
;
;       Name: extendedTokensLo
;       Type: Variable
;   Category: Text
;    Summary: Low byte of the extended text token table for each language
;
; ******************************************************************************

.extendedTokensLo

 EQUB LO(TKN1)          ; English

 EQUB LO(TKN1_DE)       ; German

 EQUB LO(TKN1_FR)       ; French

; ******************************************************************************
;
;       Name: extendedTokensHi
;       Type: Variable
;   Category: Text
;    Summary: High byte of the extended text token table for each language
;
; ******************************************************************************

.extendedTokensHi

 EQUB HI(TKN1)          ; English

 EQUB HI(TKN1_DE)       ; German

 EQUB HI(TKN1_FR)       ; French

; ******************************************************************************
;
;       Name: languageIndexes
;       Type: Variable
;   Category: Text
;    Summary: The index of the chosen language for looking up values from
;             language-indexed tables
;
; ******************************************************************************

.languageIndexes

 EQUB 0                 ; English

 EQUB 1                 ; German

 EQUB 2                 ; French

 EQUB $FF               ; There is no fourth language, so this byte is ignored

; ******************************************************************************
;
;       Name: languageNumbers
;       Type: Variable
;   Category: Text
;    Summary: The language number for each language, as a set bit within a flag
;             byte
;
; ******************************************************************************

.languageNumbers

 EQUB %00000001         ; English

 EQUB %00000010         ; German

 EQUB %00000100         ; French

; ******************************************************************************
;
;       Name: TT24
;       Type: Subroutine
;   Category: Universe
;    Summary: Calculate system data from the system seeds
;  Deep dive: Generating system data
;             Galaxy and system seeds
;
; ------------------------------------------------------------------------------
;
; Calculate system data from the seeds in QQ15 and store them in the relevant
; locations. Specifically, this routine calculates the following from the three
; 16-bit seeds in QQ15 (using only s0_hi, s1_hi and s1_lo):
;
;   QQ3 = economy (0-7)
;   QQ4 = government (0-7)
;   QQ5 = technology level (0-14)
;   QQ6 = population * 10 (1-71)
;   QQ7 = productivity (96-62480)
;
; The ranges of the various values are shown in brackets. Note that the radius
; and type of inhabitant are calculated on-the-fly in the TT25 routine when
; the system data gets displayed, so they aren't calculated here.
;
; ******************************************************************************

.TT24

 LDA QQ15+1             ; Fetch s0_hi and extract bits 0-2 to determine the
 AND #%00000111         ; system's economy, and store in QQ3
 STA QQ3

 LDA QQ15+2             ; Fetch s1_lo and extract bits 3-5 to determine the
 LSR A                  ; system's government, and store in QQ4
 LSR A
 LSR A
 AND #%00000111
 STA QQ4

 LSR A                  ; If government isn't anarchy or feudal, skip to TT77,
 BNE TT77               ; as we need to fix the economy of anarchy and feudal
                        ; systems so they can't be rich

 LDA QQ3                ; Set bit 1 of the economy in QQ3 to fix the economy
 ORA #%00000010         ; for anarchy and feudal governments
 STA QQ3

.TT77

 LDA QQ3                ; Now to work out the tech level, which we do like this:
 EOR #%00000111         ;
 CLC                    ;   flipped_economy + (s1_hi AND %11) + (government / 2)
 STA QQ5                ;
                        ; or, in terms of memory locations:
                        ;
                        ;   QQ5 = (QQ3 EOR %111) + (QQ15+3 AND %11) + (QQ4 / 2)
                        ;
                        ; We start by setting QQ5 = QQ3 EOR %111

 LDA QQ15+3             ; We then take the first 2 bits of s1_hi (QQ15+3) and
 AND #%00000011         ; add it into QQ5
 ADC QQ5
 STA QQ5

 SETUP_PPU_FOR_ICON_BAR ; If the PPU has started drawing the icon bar, configure
                        ; the PPU to use nametable 0 and pattern table 0

 LDA QQ4                ; And finally we add QQ4 / 2 and store the result in
 LSR A                  ; QQ5, using LSR then ADC to divide by 2, which rounds
 ADC QQ5                ; up the result for odd-numbered government types
 STA QQ5

 ASL A                  ; Now to work out the population, like so:
 ASL A                  ;
 ADC QQ3                ;   (tech level * 4) + economy + government + 1
 ADC QQ4                ;
 ADC #1                 ; or, in terms of memory locations:
 STA QQ6                ;
                        ;   QQ6 = (QQ5 * 4) + QQ3 + QQ4 + 1

 LDA QQ3                ; Finally, we work out productivity, like this:
 EOR #%00000111         ;
 ADC #3                 ;  (flipped_economy + 3) * (government + 4)
 STA P                  ;                        * population
 LDA QQ4                ;                        * 8
 ADC #4                 ;
 STA Q                  ; or, in terms of memory locations:
 JSR MULTU              ;
                        ;   QQ7 = (QQ3 EOR %111 + 3) * (QQ4 + 4) * QQ6 * 8
                        ;
                        ; We do the first step by setting P to the first
                        ; expression in brackets and Q to the second, and
                        ; calling MULTU, so now (A P) = P * Q. The highest this
                        ; can be is 10 * 11 (as the maximum values of economy
                        ; and government are 7), so the high byte of the result
                        ; will always be 0, so we actually have:
                        ;
                        ;   P = P * Q
                        ;     = (flipped_economy + 3) * (government + 4)

 LDA QQ6                ; We now take the result in P and multiply by the
 STA Q                  ; population to get the productivity, by setting Q to
 JSR MULTU              ; the population from QQ6 and calling MULTU again, so
                        ; now we have:
                        ;
                        ;   (A P) = P * population

 ASL P                  ; Next we multiply the result by 8, as a 16-bit number,
 ROL A                  ; so we shift both bytes to the left three times, using
 ASL P                  ; the C flag to carry bits from bit 7 of the low byte
 ROL A                  ; into bit 0 of the high byte
 ASL P
 ROL A

 STA QQ7+1              ; Finally, we store the productivity in two bytes, with
 LDA P                  ; the low byte in QQ7 and the high byte in QQ7+1
 STA QQ7

 RTS                    ; Return from the subroutine

; ******************************************************************************
;
;       Name: ClearDashEdge
;       Type: Subroutine
;   Category: Drawing the screen
;    Summary: Clear the right edge of the dashboard
;
; ******************************************************************************

.ClearDashEdge

 JSR SetupPPUForIconBar ; If the PPU has started drawing the icon bar, configure
                        ; the PPU to use nametable 0 and pattern table 0

 LDA #0                 ; Clear the right edge of the box on rows 20 to 27 in
 STA nameBuffer0+20*32  ; nametable buffer 0
 STA nameBuffer0+21*32
 STA nameBuffer0+22*32
 STA nameBuffer0+23*32
 STA nameBuffer0+24*32
 STA nameBuffer0+25*32
 STA nameBuffer0+26*32
 STA nameBuffer0+27*32

 STA nameBuffer1+20*32  ; Clear the right edge of the box on rows 20 to 27 in
 STA nameBuffer1+21*32  ; nametable buffer 1
 STA nameBuffer1+22*32
 STA nameBuffer1+23*32
 STA nameBuffer1+24*32
 STA nameBuffer1+25*32
 STA nameBuffer1+26*32
 STA nameBuffer1+27*32

 RTS                    ; Return from the subroutine

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
; Save bank6.bin
;
; ******************************************************************************

 PRINT "S.bank6.bin ", ~CODE%, " ", ~P%, " ", ~LOAD%, " ", ~LOAD%
 SAVE "3-assembled-output/bank6.bin", CODE%, P%, LOAD%
