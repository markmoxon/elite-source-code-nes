; ******************************************************************************
;
; NES ELITE GAME SOURCE (BANK 0)
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
;   * bank0.bin
;
; ******************************************************************************

 INCLUDE "1-source-files/main-sources/elite-build-options.asm"

 _BANK = 0

 INCLUDE "1-source-files/main-sources/elite-source-common.asm"

 INCLUDE "1-source-files/main-sources/elite-source-bank-7.asm"

; ******************************************************************************
;
; ELITE BANK 0
;
; Produces the binary file bank0.bin.
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
;       Name: ResetShipStatus
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.ResetShipStatus

 LDA #0
 STA DELTA
 STA QQ22+1
 LDA #0
 STA GNTMP
 LDA #$FF
 STA FSH
 STA ASH
 STA ENERGY
 RTS

; ******************************************************************************
;
;       Name: DOENTRY
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.DOENTRY

 LDX #$FF
 TXS
 JSR RES2
 JSR LAUN
 JSR ResetShipStatus
 JSR HALL_b1
 LDY #$2C
 JSR DELAY
 LDA TP
 AND #3
 BNE C804C
 LDA TALLY+1
 BEQ C8097
 LDA GCNT
 LSR A
 BNE C8097
 JMP BRIEF

.C804C

 CMP #3
 BNE C8053
 JMP DEBRIEF

.C8053

 LDA GCNT
 CMP #2
 BNE C8097
 LDA TP
 AND #$0F
 CMP #2
 BNE C806D
 LDA TALLY+1
 CMP #5
 BCC C8097
 JMP BRIEF2

.C806D

 CMP #6
 BNE C8082
 LDA QQ0
 CMP #$D7
 BNE C8097
 LDA QQ1
 CMP #$54
 BNE C8097
 JMP BRIEF3

.C8082

 CMP #$0A
 BNE C8097
 LDA QQ0
 CMP #$3F
 BNE C8097
 LDA QQ1
 CMP #$48
 BNE C8097
 JMP DEBRIEF2

.C8097

 LDA COK
 BMI C80AB
 LDA CASH+1
 BEQ C80AB
 LDA TP
 AND #$10
 BNE C80AB
 JMP TBRIEF

.C80AB

 JMP BAY

 RTS

; ******************************************************************************
;
;       Name: MAL1
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.MAL1

 STX XSAV
 STA TYPE

 SETUP_PPU_FOR_ICON_BAR ; If the PPU has started drawing the icon bar, configure
                        ; the PPU to use nametable 0 and pattern table 0

 JSR GINF
 LDY #$25

.loop_C80C5

 LDA (XX19),Y
 STA XX1,Y
 DEY
 BPL loop_C80C5

 SETUP_PPU_FOR_ICON_BAR ; If the PPU has started drawing the icon bar, configure
                        ; the PPU to use nametable 0 and pattern table 0

 LDA TYPE
 BMI MA21
 CMP #2
 BNE C80F0
 LDA L04A2
 STA XX0
 LDA L04A3
 STA XX0+1
 LDY #4
 BNE C80FC

.C80F0

 ASL A
 TAY
 LDA XX21-2,Y
 STA XX0
 LDA XX21-1,Y
 STA XX0+1

.C80FC

 CPY #6
 BEQ MainFlight5
 CPY #$3C
 BEQ MainFlight5
 CPY #4
 BEQ C811A
 LDA INWK+32
 BPL MainFlight5
 CPY #2
 BEQ C8114
 AND #$3E
 BEQ MainFlight5

.C8114

 LDA INWK+31
 AND #$A0
 BNE MainFlight5

.C811A

 LDA NEWB
 AND #4
 BEQ MainFlight5
 ASL L0300
 SEC
 ROR L0300

; ******************************************************************************
;
;       Name: MainFlight5
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.MainFlight5

 LDA BOMB
 BPL MA21
 CPY #4
 BEQ MA21
 CPY #$3A
 BEQ MA21
 CPY #$3E
 BCS MA21
 LDA INWK+31
 AND #$20
 BNE MA21
 ASL INWK+31
 SEC
 ROR INWK+31
 LDX TYPE
 JSR EXNO2

; ******************************************************************************
;
;       Name: MA21
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.MA21

 JSR MVEIT

 SETUP_PPU_FOR_ICON_BAR ; If the PPU has started drawing the icon bar, configure
                        ; the PPU to use nametable 0 and pattern table 0

 LDY #$25

.loop_C815A

 LDA XX1,Y
 STA (XX19),Y
 DEY
 BPL loop_C815A

 SETUP_PPU_FOR_ICON_BAR ; If the PPU has started drawing the icon bar, configure
                        ; the PPU to use nametable 0 and pattern table 0

; ******************************************************************************
;
;       Name: MainFlight7
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.MainFlight7

 LDA INWK+31
 AND #$A0
 LDX TYPE
 BMI C81D4
 JSR MAS4
 BNE C81D4
 LDA XX1
 ORA INWK+3
 ORA INWK+6
 BMI C81D4
 CPX #2
 BEQ ISDK
 AND #$C0
 BNE C81D4
 CPX #1
 BEQ C81D4
 LDA BST
 AND INWK+5
 BMI MainFlight8
 JMP C821B

; ******************************************************************************
;
;       Name: MainFlight8
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.MainFlight8

 CPX #5
 BEQ C81B1
 CPX #3
 BEQ C821B
 LDY #0
 JSR GetShipBlueprint   ; Set A to the Y-th byte from the current ship blueprint
 LSR A
 LSR A
 LSR A
 LSR A
 BEQ C821B
 ADC #1
 BNE slvy2

.C81B1

 JSR DORND
 AND #7

.slvy2

 JSR tnpr1
 LDY #$4E
 BCS MA59
 LDY QQ29
 ADC QQ20,Y
 STA QQ20,Y
 TYA
 ADC #$D0
 JSR MESS
 JSR subm_EBE9
 ASL NEWB
 SEC
 ROR NEWB

.C81D4

 JMP C822A

; ******************************************************************************
;
;       Name: ISDK
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.ISDK

 LDA K%+78
 AND #4
 BNE C8200
 LDA INWK+14
 CMP #$D6
 BCC MA62
 JSR SPS1
 LDA X2
 CMP #$59
 BCC MA62
 LDA INWK+16
 AND #$7F
 CMP #$50
 BCC MA62

; ******************************************************************************
;
;       Name: GOIN
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.GOIN

 JSR WaitResetSound
 JMP DOENTRY

.MA62

 LDA auto
 BNE GOIN

.C8200

 LDA DELTA
 CMP #5
 BCC MA67
 JMP DEATH

; ******************************************************************************
;
;       Name: MA59
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.MA59

 JSR EXNO3
 ASL INWK+31
 SEC
 ROR INWK+31
 BNE C822A

.MA67

 LDA #1
 STA DELTA
 LDA #5
 BNE C8224

.C821B

 ASL INWK+31
 SEC
 ROR INWK+31
 LDA INWK+35
 SEC
 ROR A

.C8224

 JSR OOPS
 JSR EXNO3

.C822A

 LDA QQ11
 BEQ MA26
 JMP MA15

; ******************************************************************************
;
;       Name: MA26
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.MA26

 JSR PLUT
 LDA LAS
 BNE C8243
 LDA MSAR
 BEQ C8248
 LDA MSTG
 BPL C8248

.C8243

 JSR HITCH
 BCS C824B

.C8248

 JMP MA8

.C824B

 LDA MSAR
 BEQ C825F
 LDA MSTG
 BPL C825F
 JSR BEEP_b7
 LDX XSAV
 LDY #$6D
 JSR ABORT2

.C825F

 LDA LAS
 BEQ MA8
 LDX #$0F
 JSR EXNO
 LDA TYPE
 CMP #2
 BEQ C82D5
 CMP #8
 BNE C827A
 LDX LAS
 CPX #$32
 BEQ C82D5

.C827A

 CMP #$1F
 BCC BURN
 LDA LAS
 CMP #$17
 BNE C82D5
 LSR LAS
 LSR LAS

.BURN

 LDA INWK+35
 SEC
 SBC LAS
 BCS C82D3
 ASL INWK+31
 SEC
 ROR INWK+31
 JSR subm_F25A
 LDA LAS
 CMP #$32
 BNE C82C4
 LDA TYPE
 CMP #7
 BEQ C82B5
 CMP #6
 BNE C82C4
 JSR DORND
 BPL C82CE
 LDA #1
 BNE C82BC

.C82B5

 JSR DORND
 ORA #1
 AND #3

.C82BC

 LDX #8
 JSR SPIN2
 JMP C82CE

.C82C4

 LDY #4
 JSR SPIN
 LDY #5
 JSR SPIN

.C82CE

 LDX TYPE
 JSR EXNO2

.C82D3

 STA INWK+35

.C82D5

 LDA TYPE
 JSR ANGRY

; ******************************************************************************
;
;       Name: MA8
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.MA8

 JSR LL9_b1

.MA15

 LDY #$23
 LDA INWK+35
 STA (XX19),Y
 LDA INWK+34
 LDY #$22
 STA (XX19),Y
 LDA NEWB
 BMI C831C
 LDA INWK+31
 BPL C831F
 AND #$20
 BEQ C831F
 LDA NEWB
 AND #$40
 ORA FIST
 STA FIST
 LDA MJ
 ORA DLY
 BNE C831C
 LDY #$0A
 JSR GetShipBlueprint   ; Set A to the Y-th byte from the current ship blueprint
 BEQ C831C
 TAX
 INY
 JSR GetShipBlueprint   ; Set A to the Y-th byte from the current ship blueprint
 TAY
 JSR MCASH
 LDA #0
 JSR MESS

.C831C

 JMP KS1

.C831F

 LDA TYPE
 BMI C8328
 JSR FAROF
 BCC C831C

.C8328

 LDY #$1F
 LDA INWK+31
 AND #$BF
 STA (XX19),Y
 LDX XSAV
 INX
 RTS

; ******************************************************************************
;
;       Name: subm_8334
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.subm_8334

 DEC L0393
 BMI C835B
 BEQ C8341
 JSR LASLI2
 JMP C8344

.C8341

 JSR CLYNS

.C8344

 JSR subm_D951
 JMP C8360

; ******************************************************************************
;
;       Name: subm_MA23
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.subm_MA23

 LDA QQ11
 BNE subm_8334
 DEC L0393
 BMI C835B
 BEQ C835B
 JSR LASLI2
 JMP C8360

.C835B

 LDA #0
 STA L0393

.C8360

 LDA ECMP
 BEQ C836A
 JSR DENGY
 BEQ C8383

.C836A

 LDA ECMA
 BEQ C8386
 LDA #$80
 STA K+2
 LDA #$7F
 STA K
 LDA Yx1M2
 STA K+3
 STA K+1
 JSR CB919_b6
 DEC ECMA
 BNE C8386

.C8383

 JSR ECMOF

.C8386

 LDX #0
 LDA FRIN
 BEQ C8390
 JSR MAL1

.C8390

 LDX #2

.loop_C8392

 LDA FRIN,X
 BEQ C839D
 JSR MAL1
 JMP loop_C8392

.C839D

 LDX #1
 LDA FRIN+1
 BEQ MA18
 BPL C83AB
 LDY #0
 STY SSPR

.C83AB

 JSR MAL1

; ******************************************************************************
;
;       Name: MA18
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.MA18

 SETUP_PPU_FOR_ICON_BAR ; If the PPU has started drawing the icon bar, configure
                        ; the PPU to use nametable 0 and pattern table 0

 LDA BOMB
 BPL C83CB
 ASL BOMB
 BMI C83CB
 JSR subm_8790
 JSR CAC5C_b3

.C83CB

 LDA MCNT
 AND #7
 BNE MA22
 JSR subm_MainFlight13

; ******************************************************************************
;
;       Name: MainFlight14
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.MainFlight14

 LDA MJ
 BNE C8417
 LDA MCNT
 AND #$1F
 BNE C841F
 LDA SSPR
 BNE C8417
 TAY
 JSR MAS2
 BNE C8417
 LDX #$1C

.loop_C83EC

 LDA K%,X
 STA XX1,X
 DEX
 BPL loop_C83EC
 JSR subm_MainFlight14
 BCS C8417
 LDX #8

.loop_C83FB

 LDA K%,X
 STA XX1,X
 DEX
 BPL loop_C83FB
 LDX #5

.loop_C8405

 LDY INWK+9,X
 LDA INWK+15,X
 STA INWK+9,X
 LDA INWK+21,X
 STA INWK+15,X
 STY INWK+21,X
 DEX
 BPL loop_C8405
 JSR subm_MainFlight14

.C8417

 JMP MA23

; ******************************************************************************
;
;       Name: MA22
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.MA22

 LDA MJ
 BNE C8417

.C841F

 LDA DLY
 BEQ C8436
 LDA JUNK
 CLC
 ADC MANY+1
 TAY
 LDA FRIN+2,Y
 BNE C8436
 LDA #1
 JMP CA5AB_b6

.C8436

 LDA MCNT
 AND #$1F
 CMP #$0A
 BEQ C8442
 CMP #$14
 BNE MA29

.C8442

 LDA #$50
 CMP ENERGY
 BCC C8453
 LDA #$64
 JSR MESS
 LDY #7
 JSR NOISE

.C8453

 JSR subm_MainFlight15
 JMP MA23

.MA28

 JMP DEATH

.MA29

 CMP #$0F
 BNE C8469
 LDA auto
 BEQ MA23
 LDA #$7B
 BNE C84C7

.C8469

 AND #$0F
 CMP #6
 BNE MA23
 LDA #$1E
 STA CABTMP
 LDA SSPR
 BNE MA23
 LDY #$2A
 JSR MAS2
 BNE MA23
 JSR MAS3
 EOR #$FF
 ADC #$1E
 STA CABTMP
 BCS MA28
 CMP #$E0
 BCC MA23
 CMP #$F0
 BCC nokilltr
 LDA TRIBBLE+1
 ORA TRIBBLE
 BEQ nokilltr
 LSR TRIBBLE+1
 ROR TRIBBLE
 LDY #$1F
 JSR NOISE

.nokilltr

 LDA BST
 BEQ MA23
 LDA DELT4+1
 BEQ MA23
 LSR A
 ADC QQ14
 CMP #$46
 BCC C84BA
 LDA #$46

.C84BA

 STA QQ14
 BCS MA23
 JSR subm_EBE9
 JSR C9D35
 LDA #$A0

.C84C7

 JSR MESS

; ******************************************************************************
;
;       Name: MA23
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.MA23

 LDA QQ11
 BNE C8532
 JMP STARS_b1

; ******************************************************************************
;
;       Name: subm_MainFlight13
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.subm_MainFlight13

 SETUP_PPU_FOR_ICON_BAR ; If the PPU has started drawing the icon bar, configure
                        ; the PPU to use nametable 0 and pattern table 0

 LDX ENERGY
 BPL C84F5
 LDX ASH
 JSR SHD
 STX ASH
 LDX FSH
 JSR SHD
 STX FSH

.C84F5

 SEC
 LDA ENGY
 ADC ENERGY
 BCS C8501
 STA ENERGY

.C8501

 RTS

; ******************************************************************************
;
;       Name: subm_MainFlight15
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.subm_MainFlight15

 LDY #$FF
 STY ALTIT
 INY
 JSR m
 BNE C8532
 JSR MAS3
 BCS C8532
 SBC #$24
 BCC C852F
 STA R

 SETUP_PPU_FOR_ICON_BAR ; If the PPU has started drawing the icon bar, configure
                        ; the PPU to use nametable 0 and pattern table 0

 JSR LL5
 LDA Q
 STA ALTIT
 BNE C8532

.C852F

 JMP DEATH

.C8532

 RTS

; ******************************************************************************
;
;       Name: M%
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.M%

 LDA QQ11
 BNE C853A
 JSR ChangeDrawingPhase

.C853A

 SETUP_PPU_FOR_ICON_BAR ; If the PPU has started drawing the icon bar, configure
                        ; the PPU to use nametable 0 and pattern table 0

 LDA K%
 EOR nmiTimerLo
 STA RAND
 LDA auto
 BEQ C8556
 CLC
 BCC C856E

.C8556

 LDA MJ
 BEQ C855E
 SEC
 BCS C856E

.C855E

 LDA L0300
 BPL C856B
 LDA #$B0
 JSR subm_B5FE+2
 JMP C856E

.C856B

 JSR subm_B5FE

.C856E

 ROR L0300
 LDX JSTX
 LDY scanController2
 LDA controller1Left,Y
 ORA controller1Right,Y
 ORA KY3
 ORA KY4
 BMI C858A
 LDA #$10
 JSR subm_FA16

.C858A

 TXA
 EOR #$80
 TAY
 AND #$80
 STA ALP2
 STX JSTX
 EOR #$80
 STA ALP2+1
 TYA
 BPL C85A1
 EOR #$FF
 CLC
 ADC #1

.C85A1

 LSR A
 LSR A
 STA ALP1
 ORA ALP2
 STA ALPHA
 LDX JSTY
 LDY scanController2
 LDA controller1Up,Y
 ORA controller1Down,Y
 ORA KY5
 ORA KY6
 BMI C85C2
 LDA #$0C
 JSR subm_FA16

.C85C2

 TXA
 EOR #$80
 TAY
 AND #$80
 STX JSTY
 STA BET2+1
 EOR #$80
 STA BET2
 TYA
 BPL C85D6
 EOR #$FF

.C85D6

 ADC #1
 LSR A
 LSR A
 LSR A
 STA BET1
 ORA BET2
 STA BETA

; ******************************************************************************
;
;       Name: BS2
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.BS2

 LDA KY2
 BEQ C85F5
 LDA DELTA
 CLC
 ADC #4
 STA DELTA
 CMP #$28
 BCC C85F3
 LDA #$28

.C85F3

 STA DELTA

.C85F5

 SETUP_PPU_FOR_ICON_BAR ; If the PPU has started drawing the icon bar, configure
                        ; the PPU to use nametable 0 and pattern table 0

 LDA KL
 BEQ C8614
 LDA DELTA
 SEC
 SBC #4
 BEQ C8610
 BCS C8612

.C8610

 LDA #1

.C8612

 STA DELTA

.C8614

 LDA L0081
 CMP #$18
 BNE C8642
 LDA NOMSL
 BEQ C8651
 LDA MSAR
 EOR #$FF
 STA MSAR
 BNE C8636
 LDY #$6C
 JSR ABORT
 LDY #4

.loop_C8630

 JSR NOISE
 JMP MA68

.C8636

 LDY #$6C
 LDX NOMSL
 JSR MSBAR
 LDY #3
 BNE loop_C8630

.C8642

 CMP #$19
 BNE C8654
 LDA MSTG
 BMI C8651
 JSR FRMIS
 JSR CAC5C_b3

.C8651

 JMP MA68

.C8654

 CMP #$1A
 BNE C866E
 LDA BOMB
 BMI C8651
 ASL BOMB
 BEQ C8651
 LDA #$28
 STA hiddenColour
 LDY #8
 JSR NOISE
 JMP MA68

.C866E

 CMP #$1B
 BNE C867F
 LDX ESCP
 BEQ MA68
 LDA MJ
 BNE MA68
 JMP ESCAPE

.C867F

 CMP #$0C
 BNE C8690
 LDA L0300
 AND #$C0
 BNE MA68
 JSR subm_B5B4
 JMP MA68

.C8690

 CMP #$17
 BNE MA68
 LDA ECM
 BEQ MA68
 LDA ECMA
 BNE MA68
 DEC ECMP
 JSR ECBLB2

.MA68

 JSR SetupPPUForIconBar ; If the PPU has started drawing the icon bar, configure
                        ; the PPU to use nametable 0 and pattern table 0

 LDA #0
 STA LAS
 STA DELT4
 LDA DELTA
 LSR A
 ROR DELT4
 LSR A
 ROR DELT4
 STA DELT4+1
 LDA LASCT
 ORA QQ11
 BNE MA3
 LDA KY7
 BPL MA3
 LDA GNTMP
 CMP #$F2
 BCS MA3
 LDX VIEW
 LDA LASER,X
 BEQ MA3
 BMI C86D9
 BIT KY7
 BVS MA3

.C86D9

 PHA
 AND #$7F
 STA LAS
 STA LAS2
 LDY #$12
 PLA
 PHA
 BMI C86F0
 CMP #$32
 BNE C86EE
 LDY #$10

.C86EE

 BNE C86F9

.C86F0

 CMP #$97
 BEQ C86F7
 LDY #$11
; overlapping:  L0FA0                         ; 86F6: 2C A0 0F    ,..
 EQUB $2C                                     ; 86F6: 2C          ,

.C86F7

 LDY #$0F

.C86F9

 JSR NOISE
 JSR LASLI
 PLA
 BPL C8704
 LDA #0

.C8704

 AND #$EF
 STA LASCT

; ******************************************************************************
;
;       Name: MA3
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.MA3

 JSR subm_MA23
 LDA QQ11
 BNE C874C

 JSR SetupPPUForIconBar ; If the PPU has started drawing the icon bar, configure
                        ; the PPU to use nametable 0 and pattern table 0

 LDA drawingPhase
 BNE C872A
 LDA L046D
 EOR #$FF
 STA L046D
 BMI C8733
 LDA KL
 ORA KY2
 ROR A
 BNE C8733

.C872A

 JSR subm_D975
 JSR COMPAS
 JMP DrawPitchRollBars

.C8733

 LDA #$88
 JSR subm_D977
 JSR COMPAS
 JSR DrawPitchRollBars
 JSR DIALS_b6
 LDX drawingPhase
 LDA L03EF,X
 ORA #$40
 STA L03EF,X
 RTS

.C874C

 CMP #$98
 BNE C876F
 JSR GetStatusCondition
 CPX L0471
 BEQ C875B
 JSR STATUS

.C875B

 LDX L0471
 CPX #3
 BNE C876A
 LDA frameCounter
 AND #$20
 BNE C876A
 INX

.C876A

 LDA LF333,X
 STA visibleColour

.C876F

 RTS

; ******************************************************************************
;
;       Name: SPIN
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.SPIN

 JSR DORND
 BPL C8794
 TYA
 TAX
 LDY #0
 STA CNT
 JSR GetShipBlueprint   ; Set A to the Y-th byte from the current ship blueprint
 AND CNT
 AND #$0F

.SPIN2

 STA CNT

.loop_C8784

 DEC CNT
 BMI C8794
 LDA #0
 JSR SFS1
 JMP loop_C8784

; ******************************************************************************
;
;       Name: subm_8790
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.subm_8790

 LDA #$0F
 STA hiddenColour

.C8794

 RTS

; ******************************************************************************
;
;       Name: scacol
;       Type: Variable
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.scacol

 EQUB   0,   3,   0,   1,   1,   1,   1,   1  ; 8795: 00 03 00... ...
 EQUB   1,   2,   2,   2,   2,   2,   2,   1  ; 879D: 01 02 02... ...
 EQUB   2,   2,   2,   2,   2,   2,   2,   2  ; 87A5: 02 02 02... ...
 EQUB   2,   2,   2,   2,   2,   0,   3,   2  ; 87AD: 02 02 02... ...
 EQUB $FF,   0,   0,   0,   0,   0            ; 87B5: FF 00 00... ...

; ******************************************************************************
;
;       Name: SetAXTo15
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.SetAXTo15

 LDA #$0F
 TAX
 RTS

; ******************************************************************************
;
;       Name: PrintCombatRank
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.PrintCombatRank

 LDA #$10
 JSR TT68
 LDA L04A9
 AND #1
 BEQ C87CE
 JSR TT162

.C87CE

 LDA TALLY+1
 BNE C8806
 TAX
 LDX TALLY
 CPX #0
 ADC #0
 CPX #2
 ADC #0
 CPX #8
 ADC #0
 CPX #$18
 ADC #0
 CPX #$2C
 ADC #0
 CPX #$82
 ADC #0
 TAX

.C87F0

 TXA
 PHA
 LDA L04A9
 AND #5
 BEQ C87FF
 JSR TT162
 JSR TT162

.C87FF

 PLA
 CLC
 ADC #$15
 JMP plf

.C8806

 LDX #9
 CMP #$19
 BCS C87F0
 DEX
 CMP #$0A
 BCS C87F0
 DEX
 CMP #2
 BCS C87F0
 DEX
 BNE C87F0

; ******************************************************************************
;
;       Name: subm_8819
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.subm_8819

 LDA #$7D
 JSR spc
 LDA #$13
 LDY FIST
 BEQ C8829
 CPY #$28
 ADC #1

.C8829

 JMP plf

; ******************************************************************************
;
;       Name: wearedocked
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.wearedocked

 LDA #$CD
 JSR DETOK_b2
 JSR TT67
 JMP C885F

; ******************************************************************************
;
;       Name: STATUS
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.STATUS

 LDA #$98
 JSR subm_9645
 JSR subm_9D09
 LDA #7
 STA XC
 LDA #$7E
 JSR NLIN3
 JSR GetStatusCondition
 STX L0471
 LDA #$E6
 DEX
 BMI wearedocked
 BEQ C885C
 LDY ENERGY
 CPY #$80
 ADC #1

.C885C

 JSR plf

.C885F

 LDA L04A9
 AND #4
 BEQ C8874
 JSR subm_8819
 JSR PrintCombatRank
 LDA #5
 JSR plf
 JMP C887F

.C8874

 JSR PrintCombatRank
 LDA #5
 JSR plf
 JSR subm_8819

.C887F

 LDA #$12
 JSR PrintTokenCrTab
 INC YC
 LDA ESCP
 BEQ C8890
 LDA #$70
 JSR PrintTokenCrTab

.C8890

 LDA BST
 BEQ C889A
 LDA #$6F
 JSR PrintTokenCrTab

.C889A

 LDA ECM
 BEQ C88A4
 LDA #$6C
 JSR PrintTokenCrTab

.C88A4

 LDA #$71
 STA XX4

.loop_C88A8

 TAY
 LDX L034F,Y
 BEQ C88B1
 JSR PrintTokenCrTab

.C88B1

 INC XX4
 LDA XX4
 CMP #$75
 BCC loop_C88A8
 LDX #0

.C88BB

 STX CNT
 LDY LASER,X
 BEQ C88FE
 LDA L04A9
 AND #4
 BNE C88D0
 TXA
 CLC
 ADC #$60
 JSR spc

.C88D0

 LDA #$67
 LDX CNT
 LDY LASER,X
 CPY #$8F
 BNE C88DD
 LDA #$68

.C88DD

 CPY #$97
 BNE C88E3
 LDA #$75

.C88E3

 CPY #$32
 BNE C88E9
 LDA #$76

.C88E9

 JSR TT27_b2
 LDA L04A9
 AND #4
 BEQ C88FB
 LDA CNT
 CLC
 ADC #$60
 JSR subm_96B9

.C88FB

 JSR PrintCrTab

.C88FE

 LDX CNT
 INX
 CPX #4
 BCC C88BB
 LDA #$18
 STA XC
 LDX language
 LDA C897C,X
 STA YC
 JSR CB882_b4
 LDA S
 ORA #$80
 CMP systemFlag
 STA systemFlag
 BEQ C8923
 JSR subm_EB8C

.C8923

 JSR CA082_b6

; ******************************************************************************
;
;       Name: subm_8926
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.subm_8926

 LDA tileNumber
 BNE C892E
 LDA #$FF
 STA tileNumber

.C892E

 LDA #0
 STA L00CC
 LDA #$6C
 STA L00D8
 STA L00CD
 STA L00CE
 LDX #$25
 LDA QQ11
 AND #$40
 BEQ C8944
 LDX #4

.C8944

 STX L00D2
 JSR DrawBoxEdges
 JSR CopyNametable0To1
 LDA QQ11
 CMP QQ11a
 BEQ C8976
 JSR CA7B7_b3

.C8955

 LDX #$FF
 LDA QQ11
 CMP #$95
 BEQ C896C
 CMP #$DF
 BEQ C896C
 CMP #$92
 BEQ C896C
 CMP #$93
 BEQ C896C
 ASL A
 BPL C896E

.C896C

 LDX #0

.C896E

 STX L045F
 LDA tileNumber
 STA L00D2
 RTS

.C8976

 JSR subm_F126
 JMP C8955

.C897C

 PHP
 PHP
 ASL A
 PHP

; ******************************************************************************
;
;       Name: subm_8980
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.subm_8980

 JSR subm_D8C5
 LDA #0
 STA L00CC
 LDA #$64
 STA L00D8
 LDA #$25
 STA L00D2

 JSR SetupPPUForIconBar ; If the PPU has started drawing the icon bar, configure
                        ; the PPU to use nametable 0 and pattern table 0

 JSR DrawBoxEdges
 JSR CopyNametable0To1
 LDA #$C4
 STA L03EF
 STA L03F0
 LDA tileNumber
 STA L00D2
 RTS

; ******************************************************************************
;
;       Name: PrintTokenCrTab
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.PrintTokenCrTab

 JSR TT27_b2

; ******************************************************************************
;
;       Name: PrintCrTab
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.PrintCrTab

 JSR TT67
 LDX language
 LDA L89B4,X
 STA XC
 RTS

; ******************************************************************************
;
;       Name: L89B4
;       Type: Variable
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.L89B4

 EQUB 3, 3, 1, 3                              ; 89B4: 03 03 01... ...

; ******************************************************************************
;
;       Name: MVT3
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.MVT3

 LDA K+3
 STA S
 AND #$80
 STA T
 EOR INWK+2,X
 BMI C89DC
 LDA K+1
 CLC
 ADC XX1,X
 STA K+1
 LDA K+2
 ADC INWK+1,X
 STA K+2
 LDA K+3
 ADC INWK+2,X
 AND #$7F
 ORA T
 STA K+3
 RTS

.C89DC

 LDA S
 AND #$7F
 STA S
 LDA XX1,X
 SEC
 SBC K+1
 STA K+1
 LDA INWK+1,X
 SBC K+2
 STA K+2
 LDA INWK+2,X
 AND #$7F
 SBC S
 ORA #$80
 EOR T
 STA K+3
 BCS C8A13
 LDA #1
 SBC K+1
 STA K+1
 LDA #0
 SBC K+2
 STA K+2
 LDA #0
 SBC K+3
 AND #$7F
 ORA T
 STA K+3

.C8A13

 RTS

; ******************************************************************************
;
;       Name: MVS5
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.MVS5

 SETUP_PPU_FOR_ICON_BAR ; If the PPU has started drawing the icon bar, configure
                        ; the PPU to use nametable 0 and pattern table 0

 LDA INWK+1,X
 AND #$7F
 LSR A
 STA T
 LDA XX1,X
 SEC
 SBC T
 STA R
 LDA INWK+1,X
 SBC #0
 STA S
 LDA XX1,Y
 STA P
 LDA INWK+1,Y
 AND #$80
 STA T
 LDA INWK+1,Y
 AND #$7F
 LSR A
 ROR P
 LSR A
 ROR P
 LSR A
 ROR P
 LSR A
 ROR P
 ORA T
 EOR RAT2
 STX Q
 JSR ADD
 STA K+1
 STX K
 LDX Q
 LDA INWK+1,Y
 AND #$7F
 LSR A
 STA T
 LDA XX1,Y
 SEC
 SBC T
 STA R
 LDA INWK+1,Y
 SBC #0
 STA S
 LDA XX1,X
 STA P
 LDA INWK+1,X
 AND #$80
 STA T
 LDA INWK+1,X
 AND #$7F
 LSR A
 ROR P
 LSR A
 ROR P
 LSR A
 ROR P
 LSR A
 ROR P
 ORA T
 EOR #$80
 EOR RAT2
 STX Q
 JSR ADD
 STA INWK+1,Y
 STX XX1,Y
 LDX Q
 LDA K
 STA XX1,X
 LDA K+1
 STA INWK+1,X

 SETUP_PPU_FOR_ICON_BAR ; If the PPU has started drawing the icon bar, configure
                        ; the PPU to use nametable 0 and pattern table 0

 RTS

; ******************************************************************************
;
;       Name: TENS
;       Type: Variable
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.TENS

 EQUB $48, $76, $E8,   0                      ; 8ABA: 48 76 E8... Hv.

; ******************************************************************************
;
;       Name: pr2
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.pr2

 LDA #3

 LDY #0

; ******************************************************************************
;
;       Name: TT11
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.TT11

 STA U
 LDA #0
 STA K
 STA K+1
 STY K+2
 STX K+3

; ******************************************************************************
;
;       Name: BPRNT
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.BPRNT

 LDX #$0B
 STX T
 PHP
 BCC C8AD9
 DEC T
 DEC U

.C8AD9

 LDA #$0B
 SEC
 STA XX17
 SBC U
 STA U
 INC U
 LDY #0
 STY S
 JMP C8B2A

.C8AEB

 ASL K+3
 ROL K+2
 ROL K+1
 ROL K
 ROL S
 LDX #3

.loop_C8AF7

 LDA K,X
 STA XX15,X
 DEX
 BPL loop_C8AF7
 LDA S
 STA XX15+4
 ASL K+3
 ROL K+2
 ROL K+1
 ROL K
 ROL S
 ASL K+3
 ROL K+2
 ROL K+1
 ROL K
 ROL S
 CLC
 LDX #3

.loop_C8B19

 LDA K,X
 ADC XX15,X
 STA K,X
 DEX
 BPL loop_C8B19
 LDA XX15+4
 ADC S
 STA S
 LDY #0

.C8B2A

 LDX #3
 SEC

.loop_C8B2D

 PHP

 SETUP_PPU_FOR_ICON_BAR ; If the PPU has started drawing the icon bar, configure
                        ; the PPU to use nametable 0 and pattern table 0

 PLP
 LDA K,X
 SBC TENS,X
 STA XX15,X
 DEX
 BPL loop_C8B2D
 LDA S
 SBC #$17
 STA XX15+4
 BCC C8B5F
 LDX #3

.loop_C8B50

 LDA XX15,X
 STA K,X
 DEX
 BPL loop_C8B50
 LDA XX15+4
 STA S
 INY
 JMP C8B2A

.C8B5F

 TYA
 BNE C8B6E
 LDA T
 BEQ C8B6E
 DEC U
 BPL C8B78
 LDA #$20
 BNE C8B75

.C8B6E

 LDY #0
 STY T
 CLC
 ADC #$30

.C8B75

 JSR DASC_b2

.C8B78

 DEC T
 BPL C8B7E
 INC T

.C8B7E

 DEC XX17
 BMI C8B90
 BNE C8B8D
 PLP
 BCC C8B8D
 LDA L03FD
 JSR DASC_b2

.C8B8D

 JMP C8AEB

.C8B90

 RTS

; ******************************************************************************
;
;       Name: DrawPitchRollBars
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ------------------------------------------------------------------------------
;
; Moves sprite 11 to coord (JSTX, 29)
;              12 to coord (JSTY, 37)
;
; ******************************************************************************

.DrawPitchRollBars

 LDA JSTX
 EOR #$FF
 LSR A
 LSR A
 LSR A
 CLC
 ADC #$D8
 STA SC2
 LDY #$1D
 LDA #$0B
 JSR C8BB4
 LDA JSTY
 LSR A
 LSR A
 LSR A
 CLC
 ADC #$D8
 STA SC2
 LDY #$25
 LDA #$0C

.C8BB4

 ASL A
 ASL A
 TAX
 LDA SC2
 SEC
 SBC #4
 STA xSprite0,X
 TYA
 CLC

IF _NTSC

 ADC #$AA

ELIF _PAL

 ADC #$B0

ENDIF

 STA ySprite0,X
 RTS

; ******************************************************************************
;
;       Name: ESCAPE
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.ESCAPE

 JSR RES2
 LDY #$13
 JSR NOISE
 LDA #0
 STA ESCP
 JSR CAC5C_b3
 LDA QQ11
 BNE C8BFF
 LDX #$0B
 STX TYPE
 JSR FRS1
 BCS C8BE9
 LDX #$18
 JSR FRS1

.C8BE9

 LDA #8
 STA INWK+27
 LDA #$C2
 STA INWK+30
 LDA #$2C
 STA INWK+32

.loop_C8BF5

 JSR MVEIT
 JSR subm_D96F
 DEC INWK+32
 BNE loop_C8BF5

.C8BFF

 LDA #0
 LDX #$10

.loop_C8C03

 STA QQ20,X
 DEX
 BPL loop_C8C03
 STA FIST
 LDA TRIBBLE
 ORA TRIBBLE+1
 BEQ C8C23
 JSR DORND
 AND #7
 ORA #1
 STA TRIBBLE
 LDA #0
 STA TRIBBLE+1

.C8C23

 LDA #$46
 STA QQ14
 JMP GOIN

; ******************************************************************************
;
;       Name: HME2
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.HME2

 JSR CLYNS
 LDA #$0E
 JSR DETOK_b2
 LDY #9
 STY L0483
 LDA #$41

.loop_C8C3A

 STA INWK+5,Y
 DEY
 BPL loop_C8C3A
 JSR CBA63_b6
 LDA INWK+5
 CMP #$0D
 BEQ C8CAF
 JSR TT81
 LDA #0
 STA XX20

.C8C50

 SETUP_PPU_FOR_ICON_BAR ; If the PPU has started drawing the icon bar, configure
                        ; the PPU to use nametable 0 and pattern table 0

 LDA #$80
 STA DTW4
 ASL A
 STA DTW5
 JSR cpl
 LDX DTW5
 LDA INWK+5,X
 CMP #$0D
 BNE C8C7F

.loop_C8C72

 DEX
 LDA INWK+5,X
 ORA #$20
 CMP BUF,X
 BEQ loop_C8C72
 TXA
 BMI C8C97

.C8C7F

 JSR CB831
 JSR TT20
 INC XX20
 BNE C8C50
 JSR TT111
 JSR BOOP
 LDA #$D7
 JSR DETOK_b2
 JMP subm_8980

.C8C97

 JSR CB831
 JSR CLYNS
 LDA #0
 STA DTW8
 LDA QQ15+3
 STA QQ9
 LDA QQ15+1
 STA QQ10
 JMP CB181

.C8CAF

 JSR CLYNS
 JMP subm_8980

; ******************************************************************************
;
;       Name: TA352
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.TA352

 LDA XX1
 ORA INWK+3
 ORA INWK+6
 BNE C8CC2
 LDA #$50
 JSR OOPS

.C8CC2

 LDX #4
 BNE C8D2B

.loop_C8CC6

 LDA #0
 JSR MAS4
 BEQ C8CD0
 JMP TN4

.C8CD0

 JSR TA873
 JSR EXNO3
 LDA #$FA
 JMP OOPS

.C8CDB

 LDA ECMA
 BNE TA352
 LDA INWK+32
 ASL A
 BMI loop_C8CC6
 LSR A
 TAX
 LDA UNIV,X
 STA V
 LDA UNIV+1,X
 JSR VCSUB
 LDA XX2+2
 ORA XX2+5
 ORA XX2+8
 AND #$7F
 ORA XX2+1
 ORA XX2+4
 ORA XX2+7
 BNE C8D34
 LDA INWK+32
 CMP #$82
 BEQ TA352
 LDY #$1F
 LDA (V),Y
 BIT M32+1
 BNE C8D14
 ORA #$80
 STA (V),Y

.C8D14

 LDA XX1
 ORA INWK+3
 ORA INWK+6
 BNE C8D21
 LDA #$50
 JSR OOPS

.C8D21

 LDA INWK+32
 AND #$7F
 LSR A
 TAX
 LDA FRIN,X
 TAX

.C8D2B

 JSR EXNO2

; ******************************************************************************
;
;       Name: TA873
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.TA873

 ASL INWK+31
 SEC
 ROR INWK+31

.C8D33

 RTS

.C8D34

 JSR DORND
 CMP #$10
 BCS C8D42

.M32

 LDY #$20
 LDA (V),Y
 LSR A
 BCS C8D45

.C8D42

 JMP TA19

.C8D45

 JMP ECBLB2

; ******************************************************************************
;
;       Name: TACTICS
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.TACTICS

 LDA #3
 STA RAT
 STA L05F2
 LDA #4
 STA RAT2
 LDA #$16
 STA CNT2
 CPX #1
 BEQ C8CDB
 CPX #2
 BNE C8D90
 LDA NEWB
 AND #4
 BNE C8D7B
 LDA MANY+10
 ORA auto
 BNE C8D33
 JSR DORND
 CMP #$FD
 BCC C8D33
 AND #1
 ADC #8
 TAX
 BNE TN6

.C8D7B

 JSR DORND
 CMP #$F0
 BCC C8D33
 LDA MANY+16
 CMP #4
 BCS C8DCC
 LDX #$10

.TN6

 LDA #$F1
 JMP SFS1

.C8D90

 CPX #$0F
 BNE C8DB0
 JSR DORND
 CMP #$C8
 BCC C8DCC
 LDX #0
 STX INWK+32
 LDX #$24
 STX NEWB
 AND #3
 ADC #$11
 TAX
 JSR TN6
 LDA #0
 STA INWK+32
 RTS

.C8DB0

 LDY #$0E
 JSR GetShipBlueprint   ; Set A to the Y-th byte from the current ship blueprint
 CMP INWK+35
 BCC TA21
 BEQ TA21
 INC INWK+35

; ******************************************************************************
;
;       Name: TA21
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.TA21

 CPX #$1E
 BNE C8DCD
 LDA MANY+29
 BNE C8DCD
 LSR INWK+32
 ASL INWK+32
 LSR INWK+27

.C8DCC

 RTS

.C8DCD

 JSR DORND
 LDA NEWB
 LSR A
 BCC C8DD9
 CPX #$32
 BCS C8DCC

.C8DD9

 LSR A
 BCC C8DEB
 LDX FIST
 CPX #$28
 BCC C8DEB
 LDA NEWB
 ORA #4
 STA NEWB
 LSR A
 LSR A

.C8DEB

 LSR A
 BCS C8DFB
 LSR A
 LSR A
 BCC GOPL
 JMP DOCKIT

.GOPL

 JSR SPS1
 JMP TA151

.C8DFB

 LSR A
 BCC TN4
 LDA SSPR
 BEQ TN4
 LDA INWK+32
 AND #$81
 STA INWK+32

.TN4

 LDX #8

.loop_C8E0B

 LDA XX1,X
 STA K3,X
 DEX
 BPL loop_C8E0B

.TA19

 JSR TAS2
 LDY #$0A
 JSR TAS3
 STA CNT

 SETUP_PPU_FOR_ICON_BAR ; If the PPU has started drawing the icon bar, configure
                        ; the PPU to use nametable 0 and pattern table 0

 LDA TYPE
 CMP #1
 BNE C8E32
 JMP TA20

.C8E32

 CMP #$0E
 BNE C8E4B
 JSR DORND
 CMP #$C8
 BCC C8E4B
 JSR DORND
 LDX #$17
 CMP #$64
 BCS C8E48
 LDX #$11

.C8E48

 JMP TN6

.C8E4B

 JSR DORND
 CMP #$FA
 BCC C8E59
 JSR DORND
 ORA #$68
 STA INWK+29

.C8E59

 LDY #$0E
 JSR GetShipBlueprint   ; Set A to the Y-th byte from the current ship blueprint
 LSR A
 CMP INWK+35
 BCC TA3
 LSR A
 LSR A
 CMP INWK+35
 BCC ta3
 JSR DORND
 CMP #$E6
 BCC ta3
 LDX TYPE
 LDY TYPE
 JSR GetDefaultNEWB     ; Set A to the default NEWB flags for ship type Y
 BPL ta3
 LDA NEWB
 AND #$F0
 STA NEWB
 LDY #$24
 STA (XX19),Y
 LDA #0
 STA INWK+32
 JMP SESCP

; ******************************************************************************
;
;       Name: ta3
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.ta3

 LDA INWK+31
 AND #7
 BEQ TA3
 STA T
 JSR DORND
 AND #$1F
 CMP T
 BCS TA3
 LDA ECMA
 BNE TA3
 DEC INWK+31
 LDA TYPE
 CMP #$1D
 BNE C8EAE
 LDX #$1E
 LDA INWK+32
 JMP SFS1

.C8EAE

 JMP SFRMIS

; ******************************************************************************
;
;       Name: TA3
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.TA3

 SETUP_PPU_FOR_ICON_BAR ; If the PPU has started drawing the icon bar, configure
                        ; the PPU to use nametable 0 and pattern table 0

 LDA #0
 JSR MAS4
 AND #$E0
 BNE TA4
 LDX CNT
 CPX #$9E
 BCC TA4
 LDY #$13
 JSR GetShipBlueprint   ; Set A to the Y-th byte from the current ship blueprint
 AND #$F8
 BEQ TA4
 CPX #$A1
 BCC C8EE4
 LDA INWK+31
 ORA #$40
 STA INWK+31
 CPX #$A3
 BCS C8EF3

.C8EE4

 JSR TAS6
 LDA CNT
 EOR #$80
 STA CNT
 JSR TA15
 JMP C8EFF

.C8EF3

 JSR GetShipBlueprint   ; Set A to the Y-th byte from the current ship blueprint
 LSR A
 JSR OOPS
 LDY #$0B
 JSR NOISE

.C8EFF

 LDA INWK+7
 CMP #3
 BCS C8F18
 JSR DORND
 ORA #$C0
 CMP INWK+32
 BCC C8F18
 JSR DORND
 AND #$87
 STA INWK+30
 JMP C8F6C

.C8F18

 LDA INWK+1
 ORA INWK+4
 ORA INWK+7
 AND #$E0
 BEQ C8F83
 BNE C8F6C

; ******************************************************************************
;
;       Name: TA4
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.TA4

 LDA INWK+7
 CMP #3
 BCS C8F32
 LDA INWK+1
 ORA INWK+4
 AND #$FE
 BEQ C8F47

.C8F32

 JSR DORND
 ORA #$80
 CMP INWK+32
 BCS C8F47
 STA L05F2

.TA20

 JSR TAS6
 LDA CNT
 EOR #$80

.C8F45

 STA CNT

.C8F47

 JSR TA15
 LDA L05F2
 BPL C8F64
 LDA INWK+1
 ORA INWK+4
 ORA INWK+7
 AND #$F8
 BNE C8F64
 LDA CNT
 BMI C8F61
 CMP CNT2
 BCS C8F83

.C8F61

 JMP C8F76

.C8F64

 LDA CNT
 BMI C8F70
 CMP CNT2
 BCC C8F76

.C8F6C

 LDA #3
 BNE C8F8C

.C8F70

 AND #$7F
 CMP #6
 BCS C8F83

.C8F76

 LDA INWK+27
 CMP #6
 BCC C8F6C
 JSR DORND
 CMP #$C8
 BCC C8F8E

.C8F83

 LDA #$FF
 LDX TYPE
 CPX #1
 BNE C8F8C
 ASL A

.C8F8C

 STA INWK+28

.C8F8E

 RTS

.TA151

 LDY #$0A
 JSR TAS3
 CMP #$98
 BCC C8F9C
 LDX #0
 STX RAT2

.C8F9C

 JMP C8F45

.TA15

 LDY #$10
 JSR TAS3
 TAX
 EOR #$80
 AND #$80
 STA INWK+30

 SETUP_PPU_FOR_ICON_BAR ; If the PPU has started drawing the icon bar, configure
                        ; the PPU to use nametable 0 and pattern table 0

 LDA CNT
 BPL C8FCA
 CMP #$9F
 BCC C8FCA
 LDA #7
 ORA INWK+30
 STA INWK+30
 LDA #0
 BEQ C8FF5

.C8FCA

 TXA
 ASL A
 CMP RAT2
 BCC C8FD6
 LDA RAT
 ORA INWK+30
 STA INWK+30

.C8FD6

 LDA INWK+29
 ASL A
 CMP #$20
 BCS C8FF7
 LDY #$16
 JSR TAS3
 TAX
 EOR INWK+30
 AND #$80
 EOR #$80
 STA INWK+29
 TXA
 ASL A
 CMP RAT2
 BCC C8FF7
 LDA RAT
 ORA INWK+29

.C8FF5

 STA INWK+29

.C8FF7

 RTS

; ******************************************************************************
;
;       Name: DOCKIT
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.DOCKIT

 LDA #6
 STA RAT2
 LSR A
 STA RAT
 LDA #$1D
 STA CNT2
 LDA SSPR
 BNE C900B

.loop_C9008

 JMP GOPL

.C900B

 JSR VCSU1
 LDA XX2+2
 ORA XX2+5
 ORA XX2+8
 AND #$7F
 BNE loop_C9008
 JSR TA2
 LDA Q
 STA K
 JSR TAS2
 LDY #$0A
 JSR TAS4
 BMI C904E
 CMP #$23
 BCC C904E
 LDY #$0A
 JSR TAS3
 CMP #$A2
 BCS C9068
 LDA K
 CMP #$9D
 BCC C9040
 LDA TYPE
 BMI C9068

.C9040

 JSR TAS6
 JSR TA151

.C9046

 LDX #0
 STX INWK+28
 INX
 STX INWK+27
 RTS

.C904E

 JSR VCSU1
 JSR DCS1
 JSR DCS1
 JSR TAS2
 JSR TAS6
 JMP TA151

.C9060

 INC INWK+28
 LDA #$7F
 STA INWK+29
 BNE C90BA

.C9068

 SETUP_PPU_FOR_ICON_BAR ; If the PPU has started drawing the icon bar, configure
                        ; the PPU to use nametable 0 and pattern table 0

 LDX #0
 STX RAT2
 STX INWK+30
 LDA TYPE
 BPL C909F
 EOR XX15
 EOR Y1
 ASL A
 LDA #2
 ROR A
 STA INWK+29
 LDA XX15
 ASL A
 CMP #$0C
 BCS C9046
 LDA Y1
 ASL A
 LDA #2
 ROR A
 STA INWK+30
 LDA Y1
 ASL A
 CMP #$0C
 BCS C9046

.C909F

 STX INWK+29
 LDA INWK+22
 STA XX15
 LDA INWK+24
 STA Y1
 LDA INWK+26
 STA X2
 LDY #$10
 JSR TAS4
 ASL A
 CMP #$42
 BCS C9060
 JSR C9046

.C90BA

 LDA XX2+10
 BNE C90C3
 ASL NEWB
 SEC
 ROR NEWB

.C90C3

 RTS

; ******************************************************************************
;
;       Name: VCSU1
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.VCSU1

 LDA #$2A
 STA V
 LDA #6

; ******************************************************************************
;
;       Name: VCSUB
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.VCSUB

 STA V+1
 LDY #2
 JSR TAS1
 LDY #5
 JSR TAS1
 LDY #8

; ******************************************************************************
;
;       Name: TAS1
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.TAS1

 SETUP_PPU_FOR_ICON_BAR ; If the PPU has started drawing the icon bar, configure
                        ; the PPU to use nametable 0 and pattern table 0

 LDA (V),Y
 EOR #$80
 STA K+3
 DEY
 LDA (V),Y
 STA K+2
 DEY
 LDA (V),Y
 STA K+1
 STY U
 LDX U
 JSR MVT3
 LDY U
 STA XX2+2,X
 LDA K+2
 STA XX2+1,X
 LDA K+1
 STA K3,X
 RTS

; ******************************************************************************
;
;       Name: TAS4
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.TAS4

 LDX K%+42,Y
 STX Q
 LDA XX15
 JSR MULT12
 LDX K%+44,Y
 STX Q
 LDA Y1
 JSR MAD
 STA S
 STX R
 LDX K%+46,Y
 STX Q
 LDA X2
 JMP MAD

; ******************************************************************************
;
;       Name: TAS6
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.TAS6

 LDA XX15
 EOR #$80
 STA XX15
 LDA Y1
 EOR #$80
 STA Y1
 LDA X2
 EOR #$80
 STA X2
 RTS

; ******************************************************************************
;
;       Name: DCS1
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.DCS1

 JSR C9141

.C9141

 LDA K%+52
 LDX #0
 JSR C9156
 LDA K%+54
 LDX #3
 JSR C9156
 LDA K%+56
 LDX #6

.C9156

 ASL A
 STA R
 LDA #0
 ROR A
 EOR #$80
 EOR XX2+2,X
 BMI C916D
 LDA R
 ADC K3,X
 STA K3,X
 BCC C916C
 INC XX2+1,X

.C916C

 RTS

.C916D

 LDA K3,X
 SEC
 SBC R
 STA K3,X
 LDA XX2+1,X
 SBC #0
 STA XX2+1,X
 BCS C916C
 LDA K3,X
 EOR #$FF
 ADC #1
 STA K3,X
 LDA XX2+1,X
 EOR #$FF
 ADC #0
 STA XX2+1,X
 LDA XX2+2,X
 EOR #$80
 STA XX2+2,X
 JMP C916C

; ******************************************************************************
;
;       Name: HITCH
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.HITCH

 CLC
 LDA INWK+8
 BNE C91D5
 LDA TYPE
 BMI C91D5
 LDA INWK+31
 AND #$20
 ORA INWK+1
 ORA INWK+4
 BNE C91D5
 LDA XX1
 JSR SQUA2
 STA S
 LDA P
 STA R
 LDA INWK+3
 JSR SQUA2
 TAX
 LDA P
 ADC R
 STA R
 TXA
 ADC S
 BCS C91D6
 STA S
 LDY #2
 JSR GetShipBlueprint   ; Set A to the Y-th byte from the current ship blueprint
 CMP S
 BNE C91D5
 DEY
 JSR GetShipBlueprint   ; Set A to the Y-th byte from the current ship blueprint
 CMP R

.C91D5

 RTS

.C91D6

 CLC
 RTS

; ******************************************************************************
;
;       Name: FRS1
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.FRS1

 JSR ZINF_0
 LDA #$1C
 STA INWK+3
 LSR A
 STA INWK+6
 LDA #$80
 STA INWK+5
 LDA MSTG
 ASL A
 ORA #$80
 STA INWK+32

.fq1

 LDA #$60
 STA INWK+14
 ORA #$80
 STA INWK+22
 LDA DELTA
 ROL A
 STA INWK+27
 TXA
 JMP NWSHP

; ******************************************************************************
;
;       Name: FRMIS
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.FRMIS

 LDX #1
 JSR FRS1
 BCC FR1
 LDX MSTG
 JSR GINF
 LDA FRIN,X
 JSR ANGRY
 LDY #$85
 JSR ABORT
 DEC NOMSL
 LDA DLY
 BEQ C9235
 LDA #$93
 LDY #$0A
 JSR subm_B77A
 LDA #$19
 STA nmiTimer
 LDA nmiTimerLo
 CLC
 ADC #$3C
 STA nmiTimerLo
 BCC C9235
 INC nmiTimerHi

.C9235

 LDY #9
 JMP NOISE

; ******************************************************************************
;
;       Name: ANGRY
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.ANGRY

 CMP #2
 BEQ C926D
 LDY #$24
 LDA (XX19),Y
 AND #$20
 BEQ C9249
 JSR C926D

.C9249

 LDY #$20
 LDA (XX19),Y
 BEQ C91D5
 ORA #$80
 STA (XX19),Y
 LDY #$1C
 LDA #2
 STA (XX19),Y
 ASL A
 LDY #$1E
 STA (XX19),Y
 LDA TYPE
 CMP #$0B
 BCC C926C
 LDY #$24
 LDA (XX19),Y
 ORA #4
 STA (XX19),Y

.C926C

 RTS

.C926D

 LDA K%+78
 ORA #4
 STA K%+78
 RTS

; ******************************************************************************
;
;       Name: FR1
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.FR1

 LDA #$C9
 JMP MESS

; ******************************************************************************
;
;       Name: SESCP
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.SESCP

 LDX #3

; ******************************************************************************
;
;       Name: SFS1
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

 LDA #$FE

.SFS1

 STA T1

 SETUP_PPU_FOR_ICON_BAR ; If the PPU has started drawing the icon bar, configure
                        ; the PPU to use nametable 0 and pattern table 0

 TXA
 PHA
 LDA XX0
 PHA
 LDA XX0+1
 PHA
 LDA XX19
 PHA
 LDA INF+1
 PHA
 LDY #$25

.loop_C929E

 LDA XX1,Y
 STA XX3,Y
 LDA (XX19),Y
 STA XX1,Y
 DEY
 BPL loop_C929E
 LDA TYPE
 CMP #2
 BNE C92CF
 TXA
 PHA
 LDA #$20
 STA INWK+27
 LDX #0
 LDA INWK+10
 JSR SFS2
 LDX #3
 LDA INWK+12
 JSR SFS2
 LDX #6
 LDA INWK+14
 JSR SFS2
 PLA
 TAX

.C92CF

 LDA T1
 STA INWK+32
 LSR INWK+29
 ASL INWK+29
 TXA
 CMP #9
 BCS C92F2
 CMP #4
 BCC C92F2
 PHA
 JSR DORND
 ASL A
 STA INWK+30
 TXA
 AND #$0F
 STA INWK+27
 LDA #$FF
 ROR A
 STA INWK+29
 PLA

.C92F2

 JSR NWSHP
 PLA
 STA INF+1
 PLA
 STA XX19
 PHP

 JSR SetupPPUForIconBar ; If the PPU has started drawing the icon bar, configure
                        ; the PPU to use nametable 0 and pattern table 0

 PLP
 LDX #$25

.loop_C9302

 LDA XX3,X
 STA XX1,X
 DEX
 BPL loop_C9302
 PLA
 STA XX0+1
 PLA
 STA XX0
 PLA
 TAX
 RTS

; ******************************************************************************
;
;       Name: SFS2
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.SFS2

 ASL A
 STA R
 LDA #0
 ROR A
 JMP MVT1

; ******************************************************************************
;
;       Name: LAUN
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.LAUN

 LDA #0
 JSR subm_B39D
 JSR subm_EB8F
 LDY #$0C
 JSR NOISE
 LDA #$80
 STA K+2
 LDA Yx1M2
 STA K+3
 LDA #$50
 STA XP
 LDA #$70
 STA YP
 LDY #4
 JSR DELAY
 LDY #$18
 JSR NOISE

.C9345

 JSR subm_B1D1
 JSR ChangeDrawingPhase
 LDA XP
 AND #$0F
 ORA #$60
 STA STP
 LDA #$80
 STA L03FC

.C9359

 SETUP_PPU_FOR_ICON_BAR ; If the PPU has started drawing the icon bar, configure
                        ; the PPU to use nametable 0 and pattern table 0

 LDA STP
 SEC
 SBC #$10
 BMI C93AC
 STA STP
 CMP YP
 BCS C9359
 STA Q
 LDA #8
 JSR LL28
 LDA R
 SEC
 SBC #$14
 CMP #$54
 BCS C93AC
 STA K+1
 LSR A
 ADC K+1
 STA K
 ASL L03FC
 BCC C93A6
 LDA YP
 CMP #$64
 BCS C93A6
 LDA K+1
 CMP #$48
 BCS C93BC
 LDA STP
 PHA
 JSR CB919_b6
 PLA
 STA STP

.C93A6

 JSR CBA17_b6
 JMP C9359

.C93AC

 JSR subm_D975
 DEC YP
 DEC XP
 BNE C9345
 LDY #$17
 JMP NOISE

.C93BC

 LDA #$48
 STA K+1
 LDA STP
 PHA
 JSR CB919_b6
 PLA
 STA STP
 JMP C9359

.C93CC

 RTS

; ******************************************************************************
;
;       Name: LASLI
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.LASLI

 JSR DORND
 AND #7
 ADC Yx1M2
 SBC #2
 STA LASY
 JSR DORND
 AND #7
 ADC #$7C
 STA LASX
 LDA GNTMP
 ADC #6
 STA GNTMP
 JSR DENGY
 LDA QQ11
 BNE C93CC
 LDA #$20
 LDY #$E0
 JSR las
 LDA #$30
 LDY #$D0

.las

 STA X2
 LDA LASX
 STA XX15
 LDA LASY
 STA Y1
 LDA Yx2M1
 STA Y2
 JSR LOIN
 LDA LASX
 STA XX15
 LDA LASY
 STA Y1
 STY X2
 LDA Yx2M1
 STA Y2
 JMP LOIN

; ******************************************************************************
;
;       Name: BRIEF2
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.BRIEF2

 LDA TP
 ORA #4
 STA TP
 LDA #$0B
 JSR DETOK_b2
 JSR subm_8926
 JMP BAY

; ******************************************************************************
;
;       Name: BRP
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.BRP

 JSR DETOK_b2
 JSR CB63D_b3

.C943C

 JMP BAY

; ******************************************************************************
;
;       Name: BRIEF3
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.BRIEF3

 LDA TP
 AND #$F0
 ORA #$0A
 STA TP
 LDA #$DE
 BNE BRP

; ******************************************************************************
;
;       Name: DEBRIEF2
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.DEBRIEF2

 LDA TP
 ORA #4
 STA TP
 LDA #2
 STA ENGY
 INC TALLY+1
 LDA #$DF
 BNE BRP

; ******************************************************************************
;
;       Name: DEBRIEF
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.DEBRIEF

 LSR TP
 ASL TP
 LDX #$50
 LDY #$C3
 JSR MCASH
 LDA #$0F
 BNE BRP

; ******************************************************************************
;
;       Name: TBRIEF
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.TBRIEF

 JSR ClearTiles_b3
 LDA #$95
 JSR TT66
 LDA TP
 ORA #$10
 STA TP
 LDA #$C7
 JSR DETOK_b2
 JSR subm_8926
 JSR YESNO
 CMP #1
 BNE C943C
 LDY #$C3
 LDX #$50
 JSR LCASH
 INC TRIBBLE
 JMP BAY

; ******************************************************************************
;
;       Name: BRIEF
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.BRIEF

 LSR TP
 SEC
 ROL TP
 JSR BRIS
 JSR ZINF_0
 LDA #$1F
 STA TYPE
 JSR NWSHP
 JSR CBAF3_b1
 LDA #1
 STA XC
 LDA #1
 STA INWK+7
 LDA #$50
 STA INWK+6
 JSR subm_EB8C
 LDA #$92
 JSR subm_B39D
 LDA #$40
 STA MCNT

.loop_C94CD

 LDX #$7F
 STX INWK+29
 STX INWK+30
 JSR subm_D96F
 JSR MVEIT
 DEC MCNT
 BNE loop_C94CD

.loop_C94DD

 LSR XX1
 INC INWK+6
 BEQ C94FD
 INC INWK+6
 BEQ C94FD
 LDX INWK+3
 INX
 CPX #$64
 BCC C94F0
 LDX #$64

.C94F0

 STX INWK+3
 JSR subm_D96F
 JSR MVEIT
 DEC MCNT
 JMP loop_C94DD

.C94FD

 INC INWK+7
 LDA #$93
 JSR TT66
 LDA #$0A
 JMP BRP

; ******************************************************************************
;
;       Name: BRIS
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.BRIS

 LDA #$D8
 JSR DETOK_b2
 JSR subm_F2BD
 LDY #$64
 JMP DELAY

; ******************************************************************************
;
;       Name: ping
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.ping

 LDX #1

.loop_C9518

 LDA QQ0,X
 STA QQ9,X
 DEX
 BPL loop_C9518
 RTS

; ******************************************************************************
;
;       Name: DemoShips
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.DemoShips

 JSR RES2
 JSR CB8FE_b6
 LDA #0
 STA QQ14
 STA CASH
 STA CASH+1
 LDA #$FF
 STA ECM
 LDA #1
 STA ENGY
 LDA #$8F
 STA LASER
 LDA #$FF
 STA DLY
 JSR SOLAR
 LDA #0
 STA DELTA
 STA ALPHA
 STA ALP1
 STA QQ12
 STA VIEW
 JSR TT66
 LSR DLY
 JSR CopyNametable0To1
 JSR subm_F139
 JSR subm_BE48
 JSR subm_F39A
 JSR subm_95FC
 LDA #6
 STA INWK+30
 LDA #$18
 STA INWK+29
 LDA #$12
 JSR NWSHP
 LDA #$0A
 JSR subm_95E4
 LDA #$92
 STA K%+114
 LDA #1
 STA K%+112
 JSR subm_95FC
 LDA #6
 STA INWK+30
 ASL INWK+2
 LDA #$C0
 STA INWK+29
 LDA #$13
 JSR NWSHP
 LDA #6
 JSR subm_95E4
 JSR subm_95FC
 LDA #6
 STA INWK+30
 ASL INWK+2
 LDA #0
 STA XX1
 LDA #$46
 STA INWK+6
 LDA #$11
 JSR NWSHP
 LDA #5
 JSR subm_95E4
 LDA #$C0
 STA K%+198
 LDA #$0B
 JSR subm_95E4
 LDA #$32
 STA nmiTimer
 LDA #0
 STA nmiTimerLo
 STA nmiTimerHi
 JSR CBA23_b3
 LSR L0300
 JSR CAC5C_b3
 LDA L0306
 STA L0305
 LDA #$10
 STA DELTA
 JMP MLOOP

; ******************************************************************************
;
;       Name: subm_95E4
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.subm_95E4

 STA LASCT

.loop_C95E7

 JSR ChangeDrawingPhase
 JSR subm_MA23
 JSR subm_D975
 LDA L0465
 JSR subm_B1D4
 DEC LASCT
 BNE loop_C95E7
 RTS

; ******************************************************************************
;
;       Name: subm_95FC
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.subm_95FC

 JSR ZINF_0
 LDA #$60
 STA INWK+14
 ORA #$80
 STA INWK+22
 LDA #$FE
 STA INWK+32
 LDA #$20
 STA INWK+27
 LDA #$80
 STA INWK+2
 LDA #$28
 STA XX1
 LDA #$28
 STA INWK+3
 LDA #$3C
 STA INWK+6
 RTS

; ******************************************************************************
;
;       Name: tnpr1
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.tnpr1

 STA QQ29
 LDA #1

.tnpr

 PHA
 LDX #$0C
 CPX QQ29
 BCC C963B

.loop_C962D

 ADC QQ20,X
 DEX
 BPL loop_C962D
 ADC TRIBBLE+1
 CMP CRGO
 PLA
 RTS

.C963B

 LDY QQ29
 ADC QQ20,Y
 CMP #$C9
 PLA
 RTS

; ******************************************************************************
;
;       Name: subm_9645
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.subm_9645

 JSR TT66
 LDA #0
 STA YC
 RTS

; ******************************************************************************
;
;       Name: TT20
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.TT20

 JSR C9650

.C9650

 JSR TT54

; ******************************************************************************
;
;       Name: TT54
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.TT54

 LDA QQ15
 CLC
 ADC QQ15+2
 TAX
 LDA QQ15+1
 ADC QQ15+3
 TAY
 LDA QQ15+2
 STA QQ15
 LDA QQ15+3
 STA QQ15+1
 LDA QQ15+5
 STA QQ15+3
 LDA QQ15+4
 STA QQ15+2
 CLC
 TXA
 ADC QQ15+2
 STA QQ15+4
 TYA
 ADC QQ15+3
 STA QQ15+5
 RTS

; ******************************************************************************
;
;       Name: TT146
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.TT146

 LDA QQ8
 ORA QQ8+1
 BNE C968C
 LDA MJ
 BNE C968C
 INC YC
 INC YC
 RTS

.C968C

 LDA #$BF
 JSR TT68
 LDX QQ8
 LDY QQ8+1
 SEC
 JSR pr5
 LDA #$C3

; ******************************************************************************
;
;       Name: TT60
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.TT60

 JSR TT27_b2

; ******************************************************************************
;
;       Name: TTX69
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.TTX69

 INC YC

; ******************************************************************************
;
;       Name: TT69
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.TT69

 LDA #$80
 STA QQ17

; ******************************************************************************
;
;       Name: TT67
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.TT67

 LDA #$0C
 JMP TT27_b2

; ******************************************************************************
;
;       Name: TT70
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.TT70

 LDA #$AD
 JSR TT27_b2
 JMP TT72

; ******************************************************************************
;
;       Name: spc
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.spc

 JSR TT27_b2
 JMP TT162

; ******************************************************************************
;
;       Name: subm_96B9
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.subm_96B9

 PHA
 JSR TT162
 PLA
 JMP TT27_b2

; ******************************************************************************
;
;       Name: L96C1
;       Type: Variable
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.L96C1

 EQUB 9, 9, 7, 9                              ; 96C1: 09 09 07... ...

; ******************************************************************************
;
;       Name: subm_96C5
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.subm_96C5

 JSR TT27_b2
 LDA #3
 STA L0037
 LDA #$3A
 JSR TT27_b2
 LDA #1
 STA L0037
 RTS

; ******************************************************************************
;
;       Name: L96D6
;       Type: Variable
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.L96D6

 EQUS "RADIUS"                                ; 96D6: 52 41 44... RAD

; ******************************************************************************
;
;       Name: TT25
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.TT25

 LDA #$96
 JSR subm_9645
 JSR TT111
 LDX language
 LDA L96C1,X
 STA XC
 LDA #$A3
 JSR NLIN3
 JSR TTX69
 JSR TT146
 LDA L04A9
 AND #6
 BEQ C9706
 LDA #$C2
 JSR subm_96C5
 JMP C970E

.C9706

 LDA #$C2
 JSR TT68
 JSR TT162

.C970E

 LDA QQ3
 CLC
 ADC #1
 LSR A
 CMP #2
 BEQ TT70
 LDA QQ3
 BCC C9721
 SBC #5
 CLC

.C9721

 ADC #$AA
 JSR TT27_b2

; ******************************************************************************
;
;       Name: TT72
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.TT72

 LDA QQ3
 LSR A
 LSR A
 CLC
 ADC #$A8
 JSR TT60
 LDA L04A9
 AND #4
 BEQ C9740
 LDA #$A2
 JSR subm_96C5
 JMP C9748

.C9740

 LDA #$A2
 JSR TT68
 JSR TT162

.C9748

 LDA QQ4
 CLC
 ADC #$B1
 JSR TT60
 LDA #$C4
 JSR TT68
 LDX QQ5
 INX
 CLC
 JSR pr2
 JSR TTX69
 LDA #$C1
 JSR TT68
 LDX QQ7
 LDY QQ7+1
 CLC
 LDA #6
 JSR TT11
 JSR TT162
 LDA #0
 STA QQ17
 LDA #$4D
 JSR DASC_b2
 LDA #$43
 JSR TT27_b2
 LDA #$52
 JSR TT60
 LDY #0

.loop_C978A

 LDA L96D6,Y
 JSR TT27_b2
 INY
 CPY #5
 BCC loop_C978A
 LDA L96D6,Y
 JSR TT68
 LDA QQ15+5
 LDX QQ15+3
 AND #$0F
 CLC
 ADC #$0B
 TAY
 LDA #5
 JSR TT11
 JSR TT162
 LDA #$6B
 JSR DASC_b2
 LDA #$6D
 JSR DASC_b2
 JSR TTX69
 LDA L04A9
 AND #5
 BEQ C97C9
 LDA #$C0
 JSR subm_96C5
 JMP C97CE

.C97C9

 LDA #$C0
 JSR TT68

.C97CE

 LDA QQ6
 LSR A
 LSR A
 LSR A
 TAX
 CLC
 LDA #1
 JSR pr2+2
 LDA #$C6
 JSR TT60
 LDA L04A9
 AND #2
 BNE C97EC
 LDA #$28
 JSR TT27_b2

.C97EC

 LDA QQ15+4
 BMI C9826
 LDA #$BC
 JSR TT27_b2
 JMP C9861

.TT207

 LDA QQ15+5
 AND #3
 CLC
 ADC QQ19
 AND #7
 ADC #$F2
 JSR TT27_b2
 LDA QQ15+5
 LSR A
 LSR A
 LSR A
 LSR A
 LSR A
 CMP #6
 BCS C9817
 ADC #$E6
 JSR subm_96B9

.C9817

 LDA QQ19
 CMP #6
 BCS C9861
 ADC #$EC
 JSR subm_96B9
 JMP C9861

.C9826

 LDA QQ15+3
 EOR QQ15+1
 AND #7
 STA QQ19
 LDA L04A9
 AND #4
 BNE TT207
 LDA QQ15+5
 LSR A
 LSR A
 LSR A
 LSR A
 LSR A
 CMP #6
 BCS C9846
 ADC #$E6
 JSR spc

.C9846

 LDA QQ19
 CMP #6
 BCS C9852
 ADC #$EC
 JSR spc

.C9852

 LDA QQ15+5
 AND #3
 CLC
 ADC QQ19
 AND #7
 ADC #$F2
 JSR TT27_b2

.C9861

 LDA L04A9
 AND #2
 BNE C986D
 LDA #$29
 JSR TT27_b2

.C986D

 JSR TTX69
 JSR PDESC_b2
 JSR subm_EB8C
 LDA #$16
 STA XC
 LDA #8
 STA YC
 LDA #1
 STA K+2
 LDA #8
 STA K+3
 LDX #8
 LDY #7
 JSR CB219_b3
 JMP subm_8926

; ******************************************************************************
;
;       Name: TT22
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.TT22

 LDA #$8D
 JSR TT66
 LDA #$4D
 JSR subm_AE32
 LDA #7
 STA XC
 JSR TT81
 LDA #$C7
 JSR NLIN3
 LDA #$98
 JSR subm_F47D
 JSR subm_EB8C
 JSR TT14
 LDX #0

.C98B3

 STX XSAV
 LDA QQ15+3
 LSR A
 LSR A
 STA T1
 LDA QQ15+3
 SEC
 SBC T1
 CLC
 ADC #$1F
 TAX
 LDY QQ15+4
 TYA
 ORA #$50
 STA ZZ
 LDA QQ15+1
 LSR A
 LSR A
 STA T1
 LDA QQ15+1
 SEC
 SBC T1
 LSR A
 CLC
 ADC #$20
 STA Y1
 JSR DrawDash
 JSR TT20
 LDX XSAV
 INX
 BNE C98B3
 LDA #3
 STA K+2
 LDA #4
 STA K+3
 LDA #$19
 STA K
 LDA #$0E
 STA K+1
 JSR CB2BC_b3
 LDA QQ9
 STA QQ19
 LDA QQ10
 LSR A
 STA QQ19+1
 LDA #4
 STA QQ19+2
 JSR subm_9B51
 LDA #$9D
 STA QQ11
 LDA #$8F
 STA Yx2M1
 JMP subm_8926

; ******************************************************************************
;
;       Name: TT15
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.TT15

 LDA #$18
 LDX QQ11
 CPX #$9C
 BNE C9924
 LDA #0

.C9924

 STA QQ19+5
 LDA QQ19
 SEC
 SBC QQ19+2
 BCS C9932
 LDA #0

.C9932

 STA XX15
 LDA QQ19
 CLC
 ADC QQ19+2
 BCC C993F
 LDA #$FF

.C993F

 STA X2
 LDA QQ19+1
 CLC
 ADC QQ19+5
 STA Y1
 STA Y2
 JSR LOIN
 LDA QQ19+1
 SEC
 SBC QQ19+2
 BCS C995A
 LDA #0

.C995A

 CLC
 ADC QQ19+5
 STA Y1
 LDA QQ19+1
 CLC
 ADC QQ19+2
 ADC QQ19+5
 CMP #$98
 BCC C9976
 LDX QQ11
 CPX #$9C
 BEQ C9976
 LDA #$97

.C9976

 STA Y2
 LDA QQ19
 STA XX15
 STA X2
 JMP LOIN

; ******************************************************************************
;
;       Name: TT126
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.TT126

 LDA #$68
 STA QQ19
 LDA #$5A
 STA QQ19+1
 LDA #$10
 STA QQ19+2
 JSR TT15
 LDA QQ14
 LSR A
 LSR A
 LSR A
 LSR A
 LSR A
 ADC QQ14
 STA K
 JMP TT128

.TT14

 LDA QQ11
 CMP #$9C
 BEQ TT126
 LDA QQ14
 LSR A
 LSR A
 STA K
 LSR A
 LSR A
 STA T1
 LDA K
 SEC
 SBC T1
 STA K
 LDA QQ0
 LSR A
 LSR A
 STA T1
 LDA QQ0
 SEC
 SBC T1
 CLC
 ADC #$1F
 STA QQ19
 LDA QQ1
 LSR A
 LSR A
 STA T1
 LDA QQ1
 SEC
 SBC T1
 LSR A
 CLC
 ADC #8
 STA QQ19+1
 LDA #7
 STA QQ19+2
 JSR TT15
 LDA QQ19+1
 CLC
 ADC #$18
 STA QQ19+1

; ******************************************************************************
;
;       Name: TT128
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.TT128

 LDA QQ19
 STA K3
 LDA QQ19+1
 STA K4
 LDX #0
 STX K4+1
 STX XX2+1
 LDX #2
 STX STP
 LDX #1
 JSR subm_D8FD
 JMP CIRCLE2_b1

; ******************************************************************************
;
;       Name: TT210
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.TT210

 LDY #0

.C9A12

 SETUP_PPU_FOR_ICON_BAR ; If the PPU has started drawing the icon bar, configure
                        ; the PPU to use nametable 0 and pattern table 0

 STY QQ29
 LDX QQ20,Y
 BEQ C9A4F
 TYA
 ASL A
 ASL A
 TAY
 LDA QQ23+1,Y
 STA QQ19+1
 TXA
 PHA
 JSR TT69
 CLC
 LDA QQ29
 ADC #$D0
 JSR TT27_b2
 LDA #$0E
 STA XC
 PLA
 TAX
 STA QQ25
 CLC
 JSR pr2
 JSR TT152

.C9A4F

 LDY QQ29
 INY
 CPY #$11
 BCC C9A12
 JSR TT69
 LDA TRIBBLE
 ORA TRIBBLE+1
 BNE C9A65

.C9A62

 JMP subm_F2BD

.C9A65

 CLC
 LDA #0
 LDX TRIBBLE
 LDY TRIBBLE+1
 JSR TT11
 LDA L04A9
 AND #4
 BNE C9A99
 JSR DORND
 AND #3
 CLC
 ADC #$6F
 JSR DETOK_b2
 LDA L04A9
 AND #2
 BEQ C9A99
 LDA TRIBBLE
 AND #$FE
 ORA TRIBBLE+1
 BEQ C9A99
 LDA #$65
 JSR DASC_b2

.C9A99

 LDA #$C6
 JSR DETOK_b2
 LDA TRIBBLE+1
 BNE C9AA9
 LDX TRIBBLE
 DEX
 BEQ C9A62

.C9AA9

 LDA #$73
 JSR DASC_b2
 JMP C9A62

; ******************************************************************************
;
;       Name: TT213
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.TT213

 LDA #$97
 JSR subm_9645
 LDA #$0B
 STA XC
 LDA #$A4
 JSR TT60
 JSR NLIN4
 JSR fwl
 LDA CRGO
 CMP #$1A
 BCC C9AD9
 LDA #$0C
 JSR TT27_b2
 LDA #$6B
 JSR TT27_b2
 JMP TT210

.C9AD9

 JSR TT67
 JMP TT210

; ******************************************************************************
;
;       Name: subm_9ADF
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.subm_9ADF

 JSR DASC_b2
 SEC
 RTS

.C9AE4

 JMP subm_9D09

; ******************************************************************************
;
;       Name: subm_9AE7
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.subm_9AE7

 LDA controller1B
 BMI C9AE4
 LDA L04BA
 ORA L04BB
 ORA controller1Up
 ORA controller1Down
 AND #$F0
 BEQ C9AE4
 TXA
 PHA
 BNE C9B03
 TYA
 BEQ C9B15

.C9B03

 LDX #0
 LDA L0395
 STX L0395
 ASL A
 BPL C9B15
 TYA
 PHA
 JSR CAC5C_b3
 PLA
 TAY

.C9B15

 DEY
 TYA
 EOR #$FF
 PHA
 LDA QQ11
 CMP #$9C
 BEQ C9B28
 PLA
 TAX
 PLA
 ASL A
 PHA
 TXA
 ASL A
 PHA

.C9B28

 JSR KeepPPUTablesAt0
 PLA
 STA QQ19+3
 LDA QQ10
 JSR subm_9B86
 LDA QQ19+4
 STA QQ10
 STA QQ19+1
 PLA
 STA QQ19+3
 LDA QQ9
 JSR subm_9B86
 LDA QQ19+4
 STA QQ9
 STA QQ19

; ******************************************************************************
;
;       Name: subm_9B51
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.subm_9B51

 LDA QQ11
 CMP #$9C
 BEQ subm_9B9D
 LDA QQ9
 LSR A
 LSR A
 STA T1
 LDA QQ9
 SEC
 SBC T1
 CLC
 ADC #$1F
 STA QQ19
 LDA QQ10
 LSR A
 LSR A
 STA T1
 LDA QQ10
 SEC
 SBC T1
 LSR A
 CLC
 ADC #$20
 STA QQ19+1
 LDA #4
 STA QQ19+2
 JMP C9BCF

; ******************************************************************************
;
;       Name: subm_9B86
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.subm_9B86

 CLC
 ADC QQ19+3
 LDX QQ19+3
 BMI C9B95
 BCC C9B99
 LDA #$FF
 BNE C9B99

.C9B95

 BCS C9B99
 LDA #1

.C9B99

 STA QQ19+4
 RTS

; ******************************************************************************
;
;       Name: subm_9B9D
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.subm_9B9D

 LDA QQ9
 SEC
 SBC QQ0
 CMP #$24
 BCC C9BAC
 CMP #$E9
 BCC C9BF6

.C9BAC

 ASL A
 ASL A
 CLC
 ADC #$68
 STA QQ19
 LDA QQ10
 SEC
 SBC QQ1
 CMP #$26
 BCC C9BC3
 CMP #$DC
 BCC C9BF6

.C9BC3

 ASL A
 CLC
 ADC #$5A
 STA QQ19+1
 LDA #8
 STA QQ19+2

.C9BCF

 LDA #$F8
 STA tileSprite15
 LDA #1
 STA attrSprite15
 LDA QQ19
 STA SC2
 LDY QQ19+1
 LDA #$0F
 ASL A
 ASL A
 TAX
 LDA SC2
 SEC
 SBC #4
 STA xSprite0,X
 TYA
 CLC

IF _NTSC

 ADC #$0A

ELIF _PAL

 ADC #$10

ENDIF

 STA ySprite0,X
 RTS

.C9BF6

 LDA #$F0
 STA ySprite15
 RTS

; ******************************************************************************
;
;       Name: L9BFC
;       Type: Variable
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.L9BFC

 EQUB   7,   8, $0A,   8                      ; 9BFC: 07 08 0A... ...

; ******************************************************************************
;
;       Name: TT23
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.TT23

 LDA #0
 STA L04A1
 LDA #$C7
 STA Yx2M1
 LDA #$9C
 JSR TT66
 LDX language
 LDA L9BFC,X
 STA XC
 LDA #$BE
 JSR NLIN3
 JSR subm_EB86
 JSR TT14
 JSR subm_9B51
 JSR TT81
 LDA #0
 STA XX20
 LDX #$18

.loop_C9C2D

 STA XX1,X
 DEX
 BPL loop_C9C2D

.C9C32

 SETUP_PPU_FOR_ICON_BAR ; If the PPU has started drawing the icon bar, configure
                        ; the PPU to use nametable 0 and pattern table 0

 LDA QQ15+3
 SEC
 SBC QQ0
 BCS C9C4B
 EOR #$FF
 ADC #1

.C9C4B

 CMP #$14
 BCS C9CBB
 LDA QQ15+1
 SEC
 SBC QQ1
 BCS C9C5B
 EOR #$FF
 ADC #1

.C9C5B

 CMP #$26
 BCS C9CBB
 LDA QQ15+3
 SEC
 SBC QQ0
 ASL A
 ASL A
 ADC #$68
 STA XX12
 LSR A
 LSR A
 LSR A
 CLC
 ADC #1
 STA XC
 LDA QQ15+1
 SEC
 SBC QQ1
 ASL A
 ADC #$5A
 STA K4
 LSR A
 LSR A
 LSR A
 TAY
 LDX XX1,Y
 BEQ C9C91
 INY
 LDX XX1,Y
 BEQ C9C91
 DEY
 DEY
 LDX XX1,Y
 BNE C9CA4

.C9C91

 TYA
 STA YC
 CPY #3
 BCC C9CBB
 LDA #$FF
 STA XX1,Y
 LDA #$80
 STA QQ17
 JSR cpl

.C9CA4

 LDA #0
 STA XX2+1
 STA K4+1
 STA K+1
 LDA XX12
 STA K3
 LDA QQ15+5
 AND #1
 ADC #2
 STA K
 JSR DrawChartSystems

.C9CBB

 JSR TT20
 INC XX20
 BEQ C9CC5
 JMP C9C32

.C9CC5

 LDA #$8F
 STA Yx2M1
 JMP subm_8926

; ******************************************************************************
;
;       Name: DrawChartSystems
;       Type: Subroutine
;   Category: ???
;    Summary: Draw system blobs on short-range chart
;
; ------------------------------------------------------------------------------
;
; Increments L04A1
; Sets sprite L04A1 to tile 213+K at (K3-4, K4+10)
; K = 2 or 3 or 4 -> 215-217
;
; ******************************************************************************

.DrawChartSystems

 LDY L04A1
 CPY #$18
 BCS C9CF7
 INY
 STY L04A1
 TYA
 ASL A
 ASL A
 TAY
 LDA K3
 SBC #3
 STA xSprite38,Y
 LDA K4
 CLC

IF _NTSC

 ADC #$0A

ELIF _PAL

 ADC #$10

ENDIF

 STA ySprite38,Y
 LDA #$D5
 CLC
 ADC K
 STA tileSprite38,Y
 LDA #2
 STA attrSprite38,Y

.C9CF7

 RTS

; ******************************************************************************
;
;       Name: TT81
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.TT81

 LDX #5

.loop_C9CFA

 LDA QQ21,X
 STA QQ15,X
 DEX
 BPL loop_C9CFA
 RTS

; ******************************************************************************
;
;       Name: subm_9D03
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.subm_9D03

 JSR TT111
 JMP C9D35

; ******************************************************************************
;
;       Name: subm_9D09
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.subm_9D09

 LDA L0395
 BMI C9D60
 JSR TT111
 LDA QQ11
 AND #$0E
 CMP #$0C
 BNE C9D35
 JSR subm_9B51
 LDA #0
 STA QQ17
 JSR CLYNS
 JSR cpl
 LDA #$80
 STA QQ17
 LDA #$0C
 JSR DASC_b2
 JSR TT146
 JSR subm_D951

.C9D35

 LDA QQ8+1
 BNE C9D51
 LDA QQ8
 BNE C9D46
 LDA MJ
 BEQ C9D51
 BNE C9D4D

.C9D46

 CMP QQ14
 BEQ C9D4D
 BCS C9D51

.C9D4D

 LDA #$C0
 BNE C9D53

.C9D51

 LDA #$80

.C9D53

 TAX
 EOR L0395
 STX L0395
 ASL A
 BPL C9D6A
 JMP CAC5C_b3

.C9D60

 LDX #5

.loop_C9D62

 LDA L0453,X
 STA QQ15,X
 DEX
 BPL loop_C9D62

.C9D6A

 RTS

; ******************************************************************************
;
;       Name: TT111
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.TT111

 JSR TT81
 LDY #$7F
 STY T
 LDA #0
 STA U

.C9D76

 SETUP_PPU_FOR_ICON_BAR ; If the PPU has started drawing the icon bar, configure
                        ; the PPU to use nametable 0 and pattern table 0

 LDA QQ15+3
 SEC
 SBC QQ9
 BCS C9D8F
 EOR #$FF
 ADC #1

.C9D8F

 LSR A
 STA S
 LDA QQ15+1
 SEC
 SBC QQ10
 BCS C9D9E
 EOR #$FF
 ADC #1

.C9D9E

 LSR A
 CLC
 ADC S
 CMP T
 BCS C9DB7
 STA T
 LDX #5

.loop_C9DAA

 LDA QQ15,X
 STA QQ19,X
 DEX
 BPL loop_C9DAA
 LDA U
 STA L049F

.C9DB7

 SETUP_PPU_FOR_ICON_BAR ; If the PPU has started drawing the icon bar, configure
                        ; the PPU to use nametable 0 and pattern table 0

 JSR TT20
 INC U
 BNE C9D76
 LDX #5

.loop_C9DCD

 LDA QQ19,X
 STA L0453,X
 STA QQ15,X
 DEX
 BPL loop_C9DCD
 LDA QQ15+1
 STA QQ10
 LDA QQ15+3
 STA QQ9
 SEC
 SBC QQ0
 BCS C9DEC
 EOR #$FF
 ADC #1

.C9DEC

 JSR SQUA2
 STA K+1
 LDA P
 STA K
 LDA QQ10
 SEC
 SBC QQ1
 BCS C9E02
 EOR #$FF
 ADC #1

.C9E02

 LSR A
 JSR SQUA2
 PHA

 SETUP_PPU_FOR_ICON_BAR ; If the PPU has started drawing the icon bar, configure
                        ; the PPU to use nametable 0 and pattern table 0

 LDA P
 CLC
 ADC K
 STA Q
 PLA
 ADC K+1
 BCC C9E22
 LDA #$FF

.C9E22

 STA R
 JSR LL5
 LDA Q
 ASL A
 LDX #0
 STX QQ8+1
 ROL QQ8+1
 ASL A
 ROL QQ8+1
 STA QQ8
 JMP CBE52_b6

; ******************************************************************************
;
;       Name: subm_9E3C
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.subm_9E3C

 JSR CLYNS
 LDA #$0F
 STA XC
 LDA #$CD
 JMP DETOK_b2

.C9E48

 LDA QQ12
 BNE subm_9E3C
 LDA QQ22+1
 BEQ Ghy
 RTS

.C9E51

 LDA QQ12
 BNE subm_9E3C
 LDA QQ22+1
 BEQ C9E5A
 RTS

.C9E5A

 LDA L0395
 ASL A
 BMI C9E61
 RTS

.C9E61

 LDX #5

.loop_C9E63

 LDA QQ15,X
 STA safehouse,X
 DEX
 BPL loop_C9E63

; ******************************************************************************
;
;       Name: wW
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.wW

 LDA #$10

.wW2

 STA QQ22+1
 LDA #1
 STA QQ22
 JMP CAC5C_b3

; ******************************************************************************
;
;       Name: Ghy
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.Ghy

 LDX GHYP
 BEQ hy5
 INX
 STX GHYP
 STX FIST
 JSR CAC5C_b3
 LDA #1
 JSR wW2
 LDX #5
 INC GCNT
 LDA GCNT
 AND #$F7
 STA GCNT

.loop_C9E97

 LDA QQ21,X
 ASL A
 ROL QQ21,X
 DEX
 BPL loop_C9E97

.zZ

 LDA #$60
 STA QQ9
 STA QQ10
 JSR TT110
 JSR TT111
 LDX #5

.loop_C9EB1

 LDA QQ15,X
 STA safehouse,X
 DEX
 BPL loop_C9EB1
 LDX #0
 STX QQ8
 STX QQ8+1
 LDY #$16
 JSR NOISE

; ******************************************************************************
;
;       Name: jmp
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.jmp

 LDA QQ9
 STA QQ0
 LDA QQ10
 STA QQ1

.hy5

 RTS

; ******************************************************************************
;
;       Name: pr6
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.pr6

 CLC

; ******************************************************************************
;
;       Name: pr5
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.pr5

 LDA #5
 JMP TT11

; ******************************************************************************
;
;       Name: TT147
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.TT147

 JSR CLYNS
 LDA #$BD
 JSR TT27_b2
 JSR TT162
 LDA #$CA
 JSR prq
 JMP subm_8980

; ******************************************************************************
;
;       Name: prq
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.prq

 JSR TT27_b2
 LDA #$3F
 JMP TT27_b2

.loop_C9EF4

 PLA
 RTS

; ******************************************************************************
;
;       Name: TT151
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.TT151

 PHA
 STA QQ19+4
 ASL A
 ASL A
 STA QQ19

 JSR SetupPPUForIconBar ; If the PPU has started drawing the icon bar, configure
                        ; the PPU to use nametable 0 and pattern table 0

 LDA MJ
 BNE loop_C9EF4
 LDA #1
 STA XC
 LDA #$80
 STA QQ17
 PLA
 CLC
 ADC #$D0
 JSR TT27_b2

.loop_C9F16

 LDA #$20
 JSR TT27_b2
 LDA XC
 CMP #$0E
 BNE loop_C9F16
 LDX QQ19
 LDA QQ23+1,X
 STA QQ19+1
 LDA QQ26
 AND QQ23+3,X
 CLC
 ADC QQ23,X
 STA QQ24
 JSR TT152
 JSR var
 LDA QQ19+1
 BMI C9F4B
 LDA QQ24
 ADC QQ19+3
 JMP C9F52

.C9F4B

 LDA QQ24
 SEC
 SBC QQ19+3

.C9F52

 STA QQ24
 STA P
 LDA #0
 JSR GC2
 SEC
 JSR pr5
 LDY QQ19+4
 LDA #3
 LDX AVL,Y
 STX QQ25
 CLC
 BEQ C9F77
 JSR pr2+2
 JSR TT152
 JMP C9FBB

.C9F77

 JSR TT172
 JMP C9FBB

.TT172

 JSR TT162
 JSR TT162
 LDA #$2D
 JSR TT27_b2
 JSR TT162
 JMP TT162

; ******************************************************************************
;
;       Name: TT152
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.TT152

 LDA QQ19+1
 AND #$60
 BEQ TT160
 CMP #$20
 BEQ TT161
 JSR TT16a

; ******************************************************************************
;
;       Name: TT162
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.TT162

 LDA #$20

 JMP TT27_b2

; ******************************************************************************
;
;       Name: TT160
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.TT160

 LDA #$74
 JSR DASC_b2
 JMP TT162

; ******************************************************************************
;
;       Name: TT161
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.TT161

 LDA #$6B
 JSR DASC_b2

; ******************************************************************************
;
;       Name: TT16a
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.TT16a

 LDA #$67
 JMP DASC_b2

; ******************************************************************************
;
;       Name: TT163
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.TT163

 LDA #1
 STA XC
 LDA #$FF
 BNE TT162+2

.C9FBB

 SETUP_PPU_FOR_ICON_BAR ; If the PPU has started drawing the icon bar, configure
                        ; the PPU to use nametable 0 and pattern table 0

 LDY QQ29
 LDA #3
 LDX QQ20,Y
 BEQ TT172
 CLC
 JSR pr2+2
 JMP TT152

; ******************************************************************************
;
;       Name: L9FD9
;       Type: Variable
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.L9FD9

 EQUB 4, 5, 4, 4                              ; 9FD9: 04 05 04... ...

; ******************************************************************************
;
;       Name: subm_9FE0
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.loop_C9FDD

 JMP TT213

.subm_9FE0

 LDA #$BA
 CMP QQ11
 BEQ loop_C9FDD
 JSR subm_9645
 LDA #5
 STA XC
 LDA #$A7
 JSR NLIN3
 LDA #2
 STA YC
 JSR TT163
 LDX language
 LDA L9FD9,X
 STA YC
 LDA #0
 STA QQ29

.loop_CA006

 JSR SetupPPUForIconBar ; If the PPU has started drawing the icon bar, configure
                        ; the PPU to use nametable 0 and pattern table 0

 JSR TT151
 INC YC
 INC QQ29
 LDA QQ29
 CMP #$11
 BCC loop_CA006
 LDA QQ12
 BNE CA028

.CA01C

 JSR subm_EB86
 JSR Set_K_K3_XC_YC
 JMP subm_8926

.CA025

 JMP CA0F4

.CA028

 LDA #0
 STA QQ29
 JSR subm_A130
 JSR subm_A155
 JSR CA01C

.CA036

 JSR SetupPPUForIconBar ; If the PPU has started drawing the icon bar, configure
                        ; the PPU to use nametable 0 and pattern table 0

 LDA controller1B
 BMI CA06E
 LDA controller1Up
 ORA controller1Down
 BEQ CA04E
 LDA controller1Left
 ORA controller1Right
 BNE CA06E

.CA04E

 LDA controller1Up
 AND #$F0
 CMP #$F0
 BEQ CA079
 LDA controller1Down
 AND #$F0
 CMP #$F0
 BEQ CA09B
 LDA L04BA
 CMP #$F0
 BEQ CA025
 LDA L04BB
 CMP #$F0
 BEQ CA0B3

.CA06E

 LDA L0465
 BEQ CA036
 JSR subm_B1D1
 BCS CA036
 RTS

.CA079

 LDA QQ29
 JSR subm_A147
 LDA QQ29
 SEC
 SBC #1
 BPL CA089
 LDA #0

.CA089

 STA QQ29

.CA08C

 LDA QQ29
 JSR subm_A130
 JSR subm_8980
 JSR subm_D8C5
 JMP CA036

.CA09B

 LDA QQ29
 JSR subm_A147
 LDA QQ29
 CLC
 ADC #1
 CMP #$11
 BNE CA0AD
 LDA #$10

.CA0AD

 STA QQ29
 JMP CA08C

.CA0B3

 LDA #1
 JSR tnpr
 BCS CA12D
 LDY QQ29
 LDA AVL,Y
 BEQ CA12D
 LDA QQ24
 STA P
 LDA #0
 JSR GC2
 JSR LCASH
 BCC CA12D
 JSR subm_F454
 LDY #$1C
 JSR NOISE
 LDY QQ29
 LDA AVL,Y
 SEC
 SBC #1
 STA AVL,Y
 LDA QQ20,Y
 CLC
 ADC #1
 STA QQ20,Y
 JSR subm_A155
 JMP CA08C

.CA0F4

 LDY QQ29
 LDA AVL,Y
 CMP #$63
 BCS CA12D
 LDA QQ20,Y
 BEQ CA12D
 JSR subm_F454
 SEC
 SBC #1
 STA QQ20,Y
 LDA AVL,Y
 CLC
 ADC #1
 STA AVL,Y
 LDA QQ24
 STA P
 LDA #0
 JSR GC2
 JSR MCASH
 JSR subm_A155
 LDY #3
 JSR NOISE
 JMP CA08C

.CA12D

 JMP CA036

; ******************************************************************************
;
;       Name: subm_A130
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.subm_A130

 TAY
 LDX #2
 STX L0037
 CLC
 LDX language
 ADC L9FD9,X
 STA YC
 TYA
 JSR TT151
 LDX #1
 STX L0037
 RTS

; ******************************************************************************
;
;       Name: subm_A147
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.subm_A147

 TAY
 CLC
 LDX language
 ADC L9FD9,X
 STA YC
 TYA
 JMP TT151

; ******************************************************************************
;
;       Name: subm_A155
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.subm_A155

 LDA #$80
 STA QQ17
 LDX language
 LDA LA16D,X
 STA YC
 LDA LA169,X
 STA XC
 JMP CA89A

; ******************************************************************************
;
;       Name: LA169
;       Type: Variable
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.LA169

 EQUB 5, 5, 3, 5                              ; A169: 05 05 03... ...

; ******************************************************************************
;
;       Name: LA16D
;       Type: Variable
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.LA16D

 EQUB $16, $17, $16, $16                      ; A16D: 16 17 16... ...

; ******************************************************************************
;
;       Name: var
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.var

 LDA QQ19+1
 AND #$1F
 LDY QQ28
 STA QQ19+2
 CLC
 LDA #0
 STA AVL+16

.loop_CA182

 DEY
 BMI CA18B
 ADC QQ19+2
 JMP loop_CA182

.CA18B

 STA QQ19+3
 RTS

; ******************************************************************************
;
;       Name: hyp1
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.hyp1

 JSR jmp
 LDX #5

.loop_CA194

 LDA safehouse,X
 STA QQ2,X
 STA QQ15,X
 DEX
 BPL loop_CA194
 INX
 STX EV
 LDA #$80
 STA L0395
 JSR CAC5C_b3
 JSR CBE52_b6
 LDA QQ3
 STA QQ28
 LDA QQ5
 STA tek
 LDA QQ4
 STA gov

; ******************************************************************************
;
;       Name: GVL
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.GVL

 JSR DORND
 STA QQ26
 LDX #0
 STX XX4

.CA1CA

 LDA QQ23+1,X
 STA QQ19+1
 JSR var
 LDA QQ23+3,X
 AND QQ26
 CLC
 ADC QQ23+2,X
 LDY QQ19+1
 BMI CA1E9
 SEC
 SBC QQ19+3
 JMP CA1ED

.CA1E9

 CLC
 ADC QQ19+3

.CA1ED

 BPL CA1F1
 LDA #0

.CA1F1

 LDY XX4
 AND #$3F
 STA AVL,Y
 INY
 TYA
 STA XX4
 ASL A
 ASL A
 TAX
 CMP #$3F
 BCC CA1CA

.hyR

 RTS

; ******************************************************************************
;
;       Name: GTHG
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.GTHG

 JSR Ze
 LDA #$FF
 STA INWK+32
 LDA #$1E
 JSR NWSHP
 JMP CA21A

; ******************************************************************************
;
;       Name: SpawnThargoid
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.SpawnThargoid

 JSR Ze
 LDA #$F9
 STA INWK+32

.CA21A

 LDA #$1D
 JMP NWSHP

; ******************************************************************************
;
;       Name: MJP
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.MJP

 LDY #$1D
 JSR NOISE
 JSR RES2
 STY MJ
 LDA QQ1
 EOR #$1F
 STA QQ1
 JSR GTHG
 JSR GTHG
 JSR GTHG
 LDA #3
 STA NOSTM
 JSR subm_9D03
 JSR CAC5C_b3
 LDY #$1E
 JSR NOISE
 JMP CA28A

; ******************************************************************************
;
;       Name: TT18
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.TT18

 JSR WaitResetSound
 LDA QQ14
 SEC
 SBC QQ8
 BCS CA25C
 LDA #0

.CA25C

 STA QQ14
 LDA QQ11
 BNE CA26C
 JSR subm_CEA5
 JSR LL164_b6
 JMP CA26F

.CA26C

 JSR subm_EBED

.CA26F

 LDA controller1Up
 ORA controller1Down
 BMI MJP
 JSR DORND
 CMP #$FD
 BCS MJP
 JSR hyp1
 JSR KeepPPUTablesAt0
 JSR RES2
 JSR SOLAR

.CA28A

 LDA QQ11
 BEQ CA2B9
 LDA QQ11
 AND #$0E
 CMP #$0C
 BNE CA2A2
 LDA QQ11
 CMP #$9C
 BNE CA29F
 JMP TT23

.CA29F

 JMP TT22

.CA2A2

 LDA QQ11
 CMP #$97
 BNE CA2AB
 JMP TT213

.CA2AB

 CMP #$BA
 BNE CA2B6
 LDA #$97
 STA QQ11
 JMP subm_9FE0

.CA2B6

 JMP STATUS

.CA2B9

 LDX #4
 STX VIEW

; ******************************************************************************
;
;       Name: TT110
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.TT110

 LDX QQ12
 BEQ CA309
 LDA #0
 STA VIEW
 STA QQ12
 LDA L0300
 ORA #$80
 STA L0300
 JSR ResetShipStatus
 JSR NWSTARS
 JSR LAUN
 JSR RES2
 JSR subm_F454
 JSR KeepPPUTablesAt0
 INC INWK+8
 JSR SOS1
 LDA #$80
 STA INWK+8
 INC INWK+7
 JSR NWSPS
 LDA #$0C
 STA DELTA
 JSR BAD
 ORA FIST
 STA FIST
 JSR NWSTARS
 JSR KeepPPUTablesAt0
 LDX #4
 STX VIEW

.CA309

 LDX #0
 STX QQ12
 JMP LOOK1

; ******************************************************************************
;
;       Name: TT114
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.TT114

 CMP #$9C
 BEQ CA317
 JMP TT22

.CA317

 JMP TT23

; ******************************************************************************
;
;       Name: LCASH
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.LCASH

 STX T1
 LDA CASH+3
 SEC
 SBC T1
 STA CASH+3
 STY T1
 LDA CASH+2
 SBC T1
 STA CASH+2
 LDA CASH+1
 SBC #0
 STA CASH+1
 LDA CASH
 SBC #0
 STA CASH
 BCS TT113

; ******************************************************************************
;
;       Name: MCASH
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.MCASH

 SETUP_PPU_FOR_ICON_BAR ; If the PPU has started drawing the icon bar, configure
                        ; the PPU to use nametable 0 and pattern table 0

 TXA
 CLC
 ADC CASH+3
 STA CASH+3
 TYA
 ADC CASH+2
 STA CASH+2
 LDA CASH+1
 ADC #0
 STA CASH+1
 LDA CASH
 ADC #0
 STA CASH
 CLC

.TT113

 RTS

; ******************************************************************************
;
;       Name: GC2
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.GC2

 ASL P
 ROL A
 ASL P
 ROL A
 TAY
 LDX P
 RTS

; ******************************************************************************
;
;       Name: BR1
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.BR1

 JSR ping
 JSR TT111
 JSR jmp
 LDX #5

.loop_CA384

 LDA QQ15,X
 STA QQ2,X
 DEX
 BPL loop_CA384
 INX
 STX EV
 LDA QQ3
 STA QQ28
 LDA QQ5
 STA tek
 LDA QQ4
 STA gov
 RTS

; ******************************************************************************
;
;       Name: subm_EQSHP1
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.subm_EQSHP1

 LDA #$14
 STA YC
 LDA #2
 STA XC
 LDA #$1A
 STA K
 LDA #5
 STA K+1
 LDA #$B7
 STA V+1
 LDA #$EC
 STA V
 LDA #0
 STA K+2
 JSR CB9C1_b4
 JMP CA4A5_b6

; ******************************************************************************
;
;       Name: subm_EQSHP2
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.subm_EQSHP2

 LDX #2
 STX L0037
 LDX XX13
 JSR subm_EQSHP3+2
 LDX #1
 STX L0037
 RTS

; ******************************************************************************
;
;       Name: subm_EQSHP3
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.subm_EQSHP3

 LDX XX13

 JSR SetupPPUForIconBar ; If the PPU has started drawing the icon bar, configure
                        ; the PPU to use nametable 0 and pattern table 0

 STX XX13
 TXA
 CLC
 ADC #2
 LDX Q
 CPX #$0C
 BCC CA3E7
 SEC
 SBC #1

.CA3E7

 STA YC
 LDA #1
 STA XC
 LDA L04A9
 AND #2
 BNE CA3F7
 JSR TT162

.CA3F7

 JSR TT162
 LDA XX13
 CLC
 ADC #$68
 JSR TT27_b2
 JSR subm_D17F
 LDA XX13
 CMP #1
 BNE CA43F
 LDA #$20
 JSR TT27_b2
 LDA #$28
 JSR TT27_b2
 LDX QQ14
 SEC
 LDA #0
 JSR pr2+2
 LDA #$C3
 JSR TT27_b2
 LDA #$29
 JSR TT27_b2
 LDA L04A9
 AND #4
 BNE CA43F
 LDA XX13
 JSR prxm3
 SEC
 LDA #5
 JSR TT11
 LDA #$20
 JMP TT27_b2

.CA43F

 LDA #$20
 JSR TT27_b2
 LDA XC
 CMP #$18
 BNE CA43F
 LDA XX13
 JSR prxm3
 SEC
 LDA #6
 JSR TT11
 JMP TT162

; ******************************************************************************
;
;       Name: subm_EQSHP4
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.subm_EQSHP4

 JSR subm_EQSHP3
 LDA XX13
 SEC
 SBC #1
 BNE CA464
 LDA #1

.CA464

 STA XX13

.CA466

 JSR subm_EQSHP2
 JSR CA4A5_b6
 JSR subm_8980
 JSR subm_D8C5
 JMP CA4DB

; ******************************************************************************
;
;       Name: subm_EQSHP5
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.subm_EQSHP5

 JSR subm_EQSHP3
 LDA XX13
 CLC
 ADC #1
 CMP Q
 BNE CA485
 LDA Q
 SBC #1

.CA485

 STA XX13
 JMP CA466

; ******************************************************************************
;
;       Name: LA48A
;       Type: Variable
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.LA48A

 EQUB $0C,   8, $0A                           ; A48A: 0C 08 0A    ...

; ******************************************************************************
;
;       Name: EQSHP
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.EQSHP

 LDA #$B9
 JSR subm_9645
 LDX language
 LDA LA48A,X
 STA XC
 LDA #$CF
 JSR NLIN3
 LDA #$80
 STA QQ17
 LDA tek
 CLC
 ADC #3
 CMP #$0C
 BCC CA4AF
 LDA #$0E

.CA4AF

 STA Q
 STA QQ25
 INC Q
 LDA #$46
 SEC
 SBC QQ14
 LDX #1

.loop_CA4BE

 JSR subm_EQSHP3+2
 LDX XX13
 INX
 CPX Q
 BCC loop_CA4BE
 LDX #1
 STX XX13
 JSR subm_EQSHP2
 JSR dn
 JSR subm_EB86
 JSR subm_EQSHP1
 JSR subm_8926

.CA4DB

 SETUP_PPU_FOR_ICON_BAR ; If the PPU has started drawing the icon bar, configure
                        ; the PPU to use nametable 0 and pattern table 0

 LDA controller1Up
 BPL CA4F0
 JMP subm_EQSHP4

.CA4F0

 LDA controller1Down
 BPL CA4F8
 JMP subm_EQSHP5

.CA4F8

 LDA controller1A
 BMI CA508
 LDA L0465
 BEQ CA4DB
 JSR subm_B1D4
 BCS CA4DB
 RTS

.CA508

 JSR subm_F454
 LDA XX13
 SEC
 SBC #1
 PHA
 JSR eq
 BCS CA51D
 PLA
 JSR subm_8980
 JMP CA4DB

.CA51D

 PLA
 BNE et0
 PHA
 LDA QQ14
 CLC
 ADC #1
 CMP #$47
 BCC CA531
 LDY #$69
 PLA
 JMP CA58A

.CA531

 STA QQ14
 PLA

.et0

 CMP #1
 BNE CA548
 LDX NOMSL
 INX
 LDY #$7C
 CPX #5
 BCS CA58A
 STX NOMSL
 LDA #1

.CA548

 LDY #$6B
 CMP #2
 BNE CA558
 LDX #$25
 CPX CRGO
 BEQ CA58A
 STX CRGO

.CA558

 CMP #3
 BNE CA565
 INY
 LDX ECM
 BNE CA58A
 DEC ECM

.CA565

 CMP #4
 BNE CA573
 JSR qv
 LDA #$18
 JMP refund

 LDA #4

.CA573

 CMP #5
 BNE CA57F
 JSR qv
 LDA #$8F
 JMP refund

.CA57F

 LDY #$6F
 CMP #6
 BNE CA5E6
 LDX BST
 BEQ ed9

.CA58A

 STY K
 PHA
 JSR KeepPPUTablesAt0
 PLA
 JSR prx
 JSR MCASH
 LDA #2
 STA XC
 LDA #$11
 STA YC
 LDA K
 JSR spc
 LDA #$1F
 JSR TT27_b2

.loop_CA5A9

 JSR TT162
 LDA XC
 CMP #$1F
 BNE loop_CA5A9
 JSR BOOP
 JSR subm_8980
 LDY #$28
 JSR DELAY
 LDA #6
 STA XC
 LDA #$11
 STA YC

.loop_CA5C5

 JSR TT162
 LDA XC
 CMP #$1F
 BNE loop_CA5C5
 JSR dn
 JSR CA4A5_b6
 JSR subm_8980
 JMP CA4DB

.CA5DA

 JMP CA58A

 JSR subm_8980
 JMP CA4DB

.ed9

 DEC BST

.CA5E6

 INY
 CMP #7
 BNE CA5F3
 LDX ESCP
 BNE CA58A
 DEC ESCP

.CA5F3

 INY
 CMP #8
 BNE CA602
 LDX BOMB
 BNE CA58A
 LDX #$7F
 STX BOMB

.CA602

 INY
 CMP #9
 BNE CA60F
 LDX ENGY
 BNE CA5DA
 INC ENGY

.CA60F

 INY
 CMP #$0A
 BNE CA61C
 LDX DKCMP
 BNE CA5DA
 DEC DKCMP

.CA61C

 INY
 CMP #$0B
 BNE CA629
 LDX GHYP
 BNE CA5DA
 DEC GHYP

.CA629

 INY
 CMP #$0C
 BNE CA636
 JSR qv
 LDA #$97
 JMP refund

.CA636

 INY
 CMP #$0D
 BNE CA643
 JSR qv
 LDA #$32
 JMP refund

.CA643

 JSR CA649
 JMP CA466

.CA649

 SETUP_PPU_FOR_ICON_BAR ; If the PPU has started drawing the icon bar, configure
                        ; the PPU to use nametable 0 and pattern table 0

 JSR dn
 JMP BEEP_b7

; ******************************************************************************
;
;       Name: dn
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.dn

 LDA #$11
 STA YC
 LDA #2
 STA XC
 JMP CA89A

; ******************************************************************************
;
;       Name: eq
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.eq

 JSR prx
 JSR LCASH
 BCS c
 LDA #$11
 STA YC
 LDA #2
 STA XC
 LDA #$C5
 JSR prq
 JSR BOOP
 LDY #$14

.loop_CA681

 JSR TT162
 DEY
 BPL loop_CA681
 JSR subm_8980
 LDY #$28
 JSR DELAY
 JSR dn
 CLC
 RTS

; ******************************************************************************
;
;       Name: prxm3
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.prxm3

 SEC
 SBC #1

; ******************************************************************************
;
;       Name: prx
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.prx

 ASL A
 TAY
 LDX PRXS,Y
 LDA PRXS+1,Y
 TAY

.c

 RTS

; ******************************************************************************
;
;       Name: subm_A6A1
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.subm_A6A1

 LDX L03E9
 LDA #0
 TAY
 RTS

; ******************************************************************************
;
;       Name: subm_A6A8
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.subm_A6A8

 LDA #$0C
 STA XC
 TYA
 PHA
 CLC
 ADC #8
 STA YC
 JSR TT162
 LDA L04A9
 AND #6
 BNE CA6C0
 JSR TT162

.CA6C0

 PLA
 PHA
 CLC
 ADC #$60
 JSR TT27_b2

.loop_CA6C8

 JSR TT162
 LDA XC
 LDX language
 CMP LA6D8,X
 BNE loop_CA6C8
 PLA
 TAY
 RTS

; ******************************************************************************
;
;       Name: LA6D8
;       Type: Variable
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.LA6D8

 EQUB $15, $15, $16, $15                      ; A6D8: 15 15 16... ...

; ******************************************************************************
;
;       Name: subm_A6DC
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.subm_A6DC

 LDA #2
 STA L0037
 JSR subm_A6A8
 LDA #1
 STA L0037
 TYA
 PHA
 JSR subm_8980
 JSR subm_D8C5
 PLA
 TAY
 RTS

; ******************************************************************************
;
;       Name: LA6F2
;       Type: Variable
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.LA6F2

 EQUB $0A, $0A, $0B, $0A                      ; A6F2: 0A 0A 0B... ...

; ******************************************************************************
;
;       Name: qv
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.qv

 JSR SetupPPUForIconBar ; If the PPU has started drawing the icon bar, configure
                        ; the PPU to use nametable 0 and pattern table 0

 LDA L04BA
 ORA L04BB
 ORA controller1A
 BMI qv
 LDY #3

.loop_CA706

 JSR subm_A6A8
 DEY
 BNE loop_CA706
 LDA #2
 STA L0037
 JSR subm_A6A8
 LDA #1
 STA L0037
 LDA #$0B
 STA XC
 STA K+2
 LDA #7
 STA YC
 STA K+3
 LDX language
 LDA LA6F2,X
 STA K
 LDA #6
 STA K+1
 JSR CB2BC_b3
 JSR subm_8980
 LDY #0

.CA737

 JSR SetupPPUForIconBar ; If the PPU has started drawing the icon bar, configure
                        ; the PPU to use nametable 0 and pattern table 0

 LDA controller1Up
 BPL CA74A
 JSR subm_A6A8
 DEY
 BPL CA747
 LDY #3

.CA747

 JSR subm_A6DC

.CA74A

 LDA controller1Down
 BPL CA75C
 JSR subm_A6A8
 INY
 CPY #4
 BNE CA759
 LDY #0

.CA759

 JSR subm_A6DC

.CA75C

 LDA controller1A
 BMI CA775
 LDA L0465
 BEQ CA737
 CMP #$50
 BNE CA775
 LDA #0
 STA L0465
 JSR CA166_b6
 JMP CA737

.CA775

 TYA
 TAX
 RTS

; ******************************************************************************
;
;       Name: refund
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.refund

 STA T1
 LDA LASER,X
 BEQ CA79E
 LDY #4
 CMP #$18
 BEQ CA793
 LDY #5
 CMP #$8F
 BEQ CA793
 LDY #$0C
 CMP #$97
 BEQ CA793
 LDY #$0D

.CA793

 STX ZZ
 TYA
 JSR prx
 JSR MCASH
 LDX ZZ

.CA79E

 LDA T1
 STA LASER,X
 JSR BEEP_b7
 JMP EQSHP

 RTS

; ******************************************************************************
;
;       Name: PRXS
;       Type: Variable
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.PRXS

 EQUB 2                                       ; A7AA: 02          .
 EQUB   0, $2C,   1, $A0, $0F, $70, $17, $A0  ; A7AB: 00 2C 01... .,.
 EQUB $0F, $10, $27, $82, $14, $10            ; A7B3: 0F 10 27... ..'
 EQUB $27, $28, $23                           ; A7B9: 27 28 23    '(#
 EQUB $98, $3A, $D0,   7, $50, $C3, $60, $EA  ; A7BC: 98 3A D0... .:.
 EQUB $40, $1F                                ; A7C4: 40 1F       @.

; ******************************************************************************
;
;       Name: hyp1_cpl
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.hyp1_cpl

 LDX #5

.loop_CA7C8

 LDA safehouse,X
 STA QQ15,X
 DEX
 BPL loop_CA7C8

; ******************************************************************************
;
;       Name: cpl
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.cpl

 LDX #5

.loop_CA7D2

 LDA QQ15,X
 STA QQ19,X
 DEX
 BPL loop_CA7D2
 LDY #3
 BIT QQ15
 BVS CA7E1
 DEY

.CA7E1

 STY T

.loop_CA7E3

 SETUP_PPU_FOR_ICON_BAR ; If the PPU has started drawing the icon bar, configure
                        ; the PPU to use nametable 0 and pattern table 0

 LDA QQ15+5
 AND #$1F
 BEQ CA7FB
 ORA #$80
 JSR TT27_b2

.CA7FB

 JSR TT54
 DEC T
 BPL loop_CA7E3
 LDX #5

.loop_CA804

 LDA QQ19,X
 STA QQ15,X
 DEX
 BPL loop_CA804
 RTS

; ******************************************************************************
;
;       Name: cmn
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.cmn

 LDY #0

.loop_CA80F

 LDA NAME,Y
 CMP #$20
 BEQ CA81E
 JSR DASC_b2
 INY
 CPY #7
 BNE loop_CA80F

.CA81E

 RTS

; ******************************************************************************
;
;       Name: ypl
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.ypl

 BIT MJ
 BMI CA839
 JSR TT62
 JSR cpl

.TT62

 LDX #5

.loop_CA82C

 LDA QQ15,X
 LDY QQ2,X
 STA QQ2,X
 STY QQ15,X
 DEX
 BPL loop_CA82C

.CA839

 RTS

; ******************************************************************************
;
;       Name: tal
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.tal

 CLC
 LDX GCNT
 INX
 JMP pr2

; ******************************************************************************
;
;       Name: fwl
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.fwl

 LDA L04A9
 AND #2
 BNE CA87D
 LDA #$69
 JSR TT68
 JSR subm_A8A2
 LDA L04A9
 AND #4
 BEQ CA85B
 JSR subm_A8A2

.CA85B

 LDX QQ14
 SEC
 JSR pr2
 LDA #$C3
 JSR plf
 LDA #$C5
 JSR TT68
 LDA L04A9
 AND #4
 BNE CA879
 JSR subm_A8A2
 JSR TT162

.CA879

 LDA #0
 BEQ CA89C

.CA87D

 LDA #$69
 JSR subm_96C5
 JSR TT162
 LDX QQ14
 SEC
 JSR pr2
 LDA #$C3
 JSR plf
 LDA #$C5
 JSR TT68
 LDA #0
 BEQ CA89C

.CA89A

 LDA #$77

.CA89C

 JMP spc

; ******************************************************************************
;
;       Name: subm_A89F
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.subm_A89F

 JSR subm_A8A2

; ******************************************************************************
;
;       Name: subm_A8A2
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.subm_A8A2

 JSR TT162
 JMP TT162

; ******************************************************************************
;
;       Name: ypls
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.ypls

 JMP ypl

; ******************************************************************************
;
;       Name: csh
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.csh

 LDX #3

.loop_CA8AD

 LDA CASH,X
 STA K,X
 DEX
 BPL loop_CA8AD
 LDA #$0B
 STA U
 SEC
 JSR BPRNT
 LDA #$E2
 JSR TT27_b2
 JSR TT162
 JMP TT162

; ******************************************************************************
;
;       Name: plf
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.plf

 JSR TT27_b2
 JMP TT67

; ******************************************************************************
;
;       Name: TT68
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.TT68

 JSR TT27_b2

; ******************************************************************************
;
;       Name: TT73
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.TT73

 LDA #$3A
 JMP TT27_b2

; ******************************************************************************
;
;       Name: tals
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.tals

 JMP tal

; ******************************************************************************
;
;       Name: TT27_0
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.TT27_0

 TXA
 BEQ csh
 DEX
 BEQ tals
 DEX
 BEQ ypls
 DEX
 BNE CA8E8
 JMP cpl

.CA8E8

 DEX
 BNE CA8EE
 JMP cmn

.CA8EE

 DEX
 BEQ fwls
 DEX
 BNE CA8F9
 LDA #$80
 STA QQ17

.loop_CA8F8

 RTS

.CA8F9

 DEX
 BEQ loop_CA8F8
 DEX
 BNE CA902
 STX QQ17
 RTS

.CA902

 JSR TT73
 LDA L04A9
 AND #2
 BNE CA911
 LDA #$16
 STA XC
 RTS

.CA911

 LDA #$17
 STA XC
 RTS

; ******************************************************************************
;
;       Name: fwls
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.fwls

 JMP fwl

; ******************************************************************************
;
;       Name: SOS1
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.SOS1

 JSR msblob
 LDA #$7F
 STA INWK+29
 STA INWK+30
 LDA tek
 AND #2
 ORA #$80
 JMP NWSHP

; ******************************************************************************
;
;       Name: SOLAR
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.SOLAR

 LDA TRIBBLE
 BEQ CA94C
 LDA #0
 STA QQ20
 JSR DORND
 AND #$0F
 ADC TRIBBLE
 ORA #4
 ROL A
 STA TRIBBLE
 ROL TRIBBLE+1
 BPL CA94C
 ROR TRIBBLE+1

.CA94C

 LSR FIST
 JSR ZINF_0
 LDA QQ15+1
 AND #3
 ADC #3
 STA INWK+8
 LDX QQ15+2
 CPX #$80
 ROR A
 STA INWK+2
 ROL A
 LDX QQ15+3
 CPX #$80
 ROR A
 STA INWK+5
 JSR SOS1
 LDA QQ15+3
 AND #7
 ORA #$81
 STA INWK+8
 LDA QQ15+5
 AND #3
 STA INWK+2
 STA INWK+1
 LDA #0
 STA INWK+29
 STA INWK+30
 STA FRIN+1
 STA SSPR
 LDA #$81
 JSR NWSHP

; ******************************************************************************
;
;       Name: NWSTARS
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.NWSTARS

 LDA QQ11
 ORA DLY
 BNE WPSHPS

; ******************************************************************************
;
;       Name: nWq
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.nWq

 LDA frameCounter
 CLC
 ADC RAND
 STA RAND
 LDA frameCounter
 STA RAND+1
 LDY NOSTM

.CA9A4

 SETUP_PPU_FOR_ICON_BAR ; If the PPU has started drawing the icon bar, configure
                        ; the PPU to use nametable 0 and pattern table 0

 JSR DORND
 ORA #8
 STA SZ,Y
 STA ZZ
 JSR DORND
 ORA #$10
 AND #$F8
 STA SX,Y
 JSR DORND
 STA SY,Y
 STA SXL,Y
 STA SYL,Y
 STA SZL,Y
 DEY
 BNE CA9A4

; ******************************************************************************
;
;       Name: WPSHPS
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.WPSHPS

 LDX #0

.CA9D9

 SETUP_PPU_FOR_ICON_BAR ; If the PPU has started drawing the icon bar, configure
                        ; the PPU to use nametable 0 and pattern table 0

 LDA FRIN,X
 BEQ CA9FD
 BMI CA9FA
 STA TYPE
 JSR GINF
 LDY #$1F
 LDA (XX19),Y
 AND #$B7
 STA (XX19),Y

.CA9FA

 INX
 BNE CA9D9

.CA9FD

 LDX #0
 RTS

.loop_CAA00

 DEX
 RTS

; ******************************************************************************
;
;       Name: SHD
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.SHD

 INX
 BEQ loop_CAA00

; ******************************************************************************
;
;       Name: DENGY
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.DENGY

 DEC ENERGY
 PHP
 BNE CAA0E
 INC ENERGY

.CAA0E

 PLP
 RTS

.loop_CAA10

 LDA #$F0
 STA ySprite13
 RTS

; ******************************************************************************
;
;       Name: COMPAS
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.COMPAS

 LDA MJ
 BNE loop_CAA10
 LDA SSPR
 BNE SP1
 JSR SPS1
 JMP SP2

; ******************************************************************************
;
;       Name: SP1
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.SP1

 JSR SPS4

; ******************************************************************************
;
;       Name: SP2
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.SP2

 LDA XX15
 JSR SPS2
 TXA
 CLC
 ADC #$DC
 STA xSprite13
 LDA Y1
 JSR SPS2
 STX T

IF _NTSC

 LDA #$BA

ELIF _PAL

 LDA #$C0

ENDIF

 SEC
 SBC T
 STA ySprite13
 LDA #$F7
 LDX X2
 BPL CAA4C
 LDA #$F6

.CAA4C

 STA tileSprite13
 RTS

; ******************************************************************************
;
;       Name: SPS4
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.SPS4

 LDX #8

.loop_CAA52

 LDA K%+42,X
 STA K3,X
 DEX
 BPL loop_CAA52
 JMP TAS2

; ******************************************************************************
;
;       Name: OOPS
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.OOPS

 STA T
 LDX #0
 LDY #8
 LDA (XX19),Y
 BMI CAA79
 LDA FSH
 SBC T
 BCC CAA72
 STA FSH
 RTS

.CAA72

 LDX #0
 STX FSH
 BCC CAA89

.CAA79

 LDA ASH
 SBC T
 BCC CAA84
 STA ASH
 RTS

.CAA84

 LDX #0
 STX ASH

.CAA89

 ADC ENERGY
 STA ENERGY
 BEQ CAA93
 BCS CAA96

.CAA93

 JMP DEATH

.CAA96

 JSR EXNO3
 JMP OUCH

; ******************************************************************************
;
;       Name: NWSPS
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.NWSPS

 LDX #$81
 STX INWK+32
 LDX #0
 STX INWK+30
 STX NEWB
 STX FRIN+1
 DEX
 STX INWK+29
 LDX #$0A
 JSR NwS1
 JSR NwS1
 JSR NwS1
 LDA #2
 JSR NWSHP
 LDX XX21+2
 LDY XX21+3
 LDA tek
 CMP #$0A
 BCC CAACF
 LDX XX21+64
 LDY XX21+65

.CAACF

 STX L04A2
 STY L04A3
 JMP CAC5C_b3

; ******************************************************************************
;
;       Name: NW2
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.NW2

 STA FRIN,X
 TAX
 LDA #0
 STA INWK+33
 JMP CAB86

; ******************************************************************************
;
;       Name: NWSHP
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.NWSHP

 STA T

 SETUP_PPU_FOR_ICON_BAR ; If the PPU has started drawing the icon bar, configure
                        ; the PPU to use nametable 0 and pattern table 0

 LDX #0

.loop_CAAF4

 LDA FRIN,X
 BEQ CAB00
 INX
 CPX #8
 BCC loop_CAAF4

.loop_CAAFE

 CLC
 RTS

.CAB00

 JSR GINF
 LDA T
 BMI NW2
 ASL A
 TAY
 LDA XX21-1,Y
 BEQ loop_CAAFE
 STA XX0+1
 LDA XX21-2,Y
 STA XX0
 STX SC2
 LDX T
 LDA #0
 STA INWK+33
 LDA scacol,X
 BMI CAB43
 TAX
 LDY #8

.loop_CAB25

 LDA L0374,Y
 BEQ CAB2F
 DEY
 BNE loop_CAB25
 BEQ CAB43

.CAB2F

 LDA #$FF
 STA L0374,Y
 STY INWK+33
 TYA
 ASL A
 ADC INWK+33
 ASL A
 ASL A
 TAY
 TXA
 LDX INWK+33
 STA L037E,X

.CAB43

 LDX SC2

.NW6

 LDY #$0E
 JSR GetShipBlueprint   ; Set A to the Y-th byte from the current ship blueprint
 STA INWK+35
 LDY #$13
 JSR GetShipBlueprint   ; Set A to the Y-th byte from the current ship blueprint
 AND #7
 STA INWK+31
 LDA T
 STA FRIN,X
 TAX
 BMI CAB86
 CPX #$0F
 BEQ gangbang
 CPX #3
 BCC NW7
 CPX #$0B
 BCS NW7

.gangbang

 INC JUNK

.NW7

 INC MANY,X
 LDY T
 JSR GetDefaultNEWB     ; Set A to the default NEWB flags for ship type Y
 AND #$6F
 ORA NEWB
 STA NEWB
 AND #4
 BEQ CAB86
 LDA L0300
 ORA #$80
 STA L0300

.CAB86

 SETUP_PPU_FOR_ICON_BAR ; If the PPU has started drawing the icon bar, configure
                        ; the PPU to use nametable 0 and pattern table 0

 LDY #$25

.loop_CAB95

 LDA XX1,Y
 STA (XX19),Y
 DEY
 BPL loop_CAB95

 SETUP_PPU_FOR_ICON_BAR ; If the PPU has started drawing the icon bar, configure
                        ; the PPU to use nametable 0 and pattern table 0

 SEC
 RTS

; ******************************************************************************
;
;       Name: NwS1
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.NwS1

 LDA XX1,X
 EOR #$80
 STA XX1,X
 INX
 INX
 RTS

; ******************************************************************************
;
;       Name: KS3
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.KS3

 RTS

; ******************************************************************************
;
;       Name: KS1
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.KS1

 LDX XSAV
 JSR KILLSHP
 LDX XSAV
 RTS

; ******************************************************************************
;
;       Name: KS4
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.KS4

 JSR ZINF_0
 LDA #0
 STA FRIN+1
 STA SSPR
 LDA #6
 STA INWK+5
 LDA #$81
 JSR NWSHP
 JMP CAC5C_b3

; ******************************************************************************
;
;       Name: KS2
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.KS2

 LDX #$FF

.CABD7

 SETUP_PPU_FOR_ICON_BAR ; If the PPU has started drawing the icon bar, configure
                        ; the PPU to use nametable 0 and pattern table 0

 INX
 LDA FRIN,X
 BEQ KS3
 CMP #1
 BNE CABD7
 TXA
 ASL A
 TAY
 LDA UNIV,Y
 STA SC
 LDA UNIV+1,Y
 STA SC+1
 LDY #$20
 LDA (SC),Y
 BPL CABD7
 AND #$7F
 LSR A
 CMP XX4
 BCC CABD7
 BEQ CAC13
 SBC #1
 ASL A
 ORA #$80
 STA (SC),Y
 BNE CABD7

.CAC13

 LDA #0
 STA (SC),Y
 BEQ CABD7

; ******************************************************************************
;
;       Name: subm_AC19
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.subm_AC19

 JSR SetupPPUForIconBar ; If the PPU has started drawing the icon bar, configure
                        ; the PPU to use nametable 0 and pattern table 0

 LDY #$25

.loop_CAC1E

 LDA (XX19),Y
 STA XX1,Y
 DEY
 BPL loop_CAC1E

; ******************************************************************************
;
;       Name: KILLSHP
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.KILLSHP

 STX XX4
 JSR CBAF3_b1
 LDX XX4
 LDA MSTG
 CMP XX4
 BNE CAC3E
 LDY #$6C
 JSR ABORT
 LDA #$C8
 JSR MESS

.CAC3E

 LDY XX4
 LDX FRIN,Y
 CPX #2
 BNE CAC4A
 JMP KS4

.CAC4A

 CPX #$1F
 BNE CAC59
 LDA TP
 ORA #2
 STA TP
 INC TALLY+1

.CAC59

 CPX #$0F
 BEQ blacksuspenders
 CPX #3
 BCC CAC68
 CPX #$0B
 BCS CAC68

.blacksuspenders

 DEC JUNK

.CAC68

 DEC MANY,X
 LDX XX4

.KSL1

 SETUP_PPU_FOR_ICON_BAR ; If the PPU has started drawing the icon bar, configure
                        ; the PPU to use nametable 0 and pattern table 0

 INX
 LDA FRIN,X
 STA L0369,X
 BNE CAC86
 JMP KS2

.CAC86

 TXA
 ASL A
 TAY
 LDA UNIV,Y
 STA SC
 LDA UNIV+1,Y
 STA SC+1

 SETUP_PPU_FOR_ICON_BAR ; If the PPU has started drawing the icon bar, configure
                        ; the PPU to use nametable 0 and pattern table 0

 LDY #$29

.loop_CACA2

 LDA (SC),Y
 STA (XX19),Y
 DEY
 BPL loop_CACA2
 LDA SC
 STA XX19
 LDA SC+1
 STA INF+1

 SETUP_PPU_FOR_ICON_BAR ; If the PPU has started drawing the icon bar, configure
                        ; the PPU to use nametable 0 and pattern table 0

 JMP KSL1

; ******************************************************************************
;
;       Name: ABORT
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.ABORT

 LDX #0
 STX MSAR
 DEX

; ******************************************************************************
;
;       Name: ABORT2
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.ABORT2

 STX MSTG

 SETUP_PPU_FOR_ICON_BAR ; If the PPU has started drawing the icon bar, configure
                        ; the PPU to use nametable 0 and pattern table 0

 LDX NOMSL
 JSR MSBAR
 JMP CAC5C_b3

; ******************************************************************************
;
;       Name: msbpars
;       Type: Variable
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.msbpars

 EQUB 4, 0, 0, 0, 0                           ; ACE0: 04 00 00... ...

; ******************************************************************************
;
;       Name: YESNO
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.YESNO

 LDA L0037
 PHA
 LDA #2
 STA L0037
 LDA #1
 PHA

.CACEF

 JSR CLYNS
 LDA #$0F
 STA XC
 PLA
 PHA
 JSR DETOK_b2
 JSR subm_D951
 LDA controller1A
 BMI CAD17
 LDA controller1Up
 ORA controller1Down
 BPL CAD0F
 PLA
 EOR #3
 PHA

.CAD0F

 LDY #8
 JSR DELAY
 JMP CACEF

.CAD17

 LDA #0
 STA L0081
 STA controller1A
 PLA
 TAX
 PLA
 STA L0037
 TXA
 RTS

; ******************************************************************************
;
;       Name: subm_AD25
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.subm_AD25

 LDA QQ11
 BNE CAD2E
 JSR DOKEY
 TXA
 RTS

.CAD2E

 JSR DOKEY
 LDX #0
 LDY #0
 LDA controller1B
 BMI CAD52
 LDA L04BA
 BPL CAD40
 DEX

.CAD40

 LDA L04BB
 BPL CAD46
 INX

.CAD46

 LDA controller1Up
 BPL CAD4C
 INY

.CAD4C

 LDA controller1Down
 BPL CAD52
 DEY

.CAD52

 LDA L0081
 RTS

; ******************************************************************************
;
;       Name: THERE
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.THERE

 LDX GCNT
 DEX
 BNE CAD69
 LDA QQ0
 CMP #$90
 BNE CAD69
 LDA QQ1
 CMP #$21
 BEQ CAD6A

.CAD69

 CLC

.CAD6A

 RTS

; ******************************************************************************
;
;       Name: RESET
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.RESET

 JSR subm_B46B
 LDA #0
 STA L0395
 LDX #6

.loop_CAD75

 STA BETA,X
 DEX
 BPL loop_CAD75
 TXA
 STA QQ12
 LDX #2

.loop_CAD7F

 STA FSH,X
 DEX
 BPL loop_CAD7F
 LDA #$FF
 STA L0464

; ******************************************************************************
;
;       Name: RES2
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.RES2

 SEI
 LDA #1
 STA L00F6
 LDA #1
 STA boxEdge1
 LDA #2
 STA boxEdge2
 LDA #$50
 STA L00CD
 STA L00CE
 LDA BOMB
 BPL CADAA
 JSR subm_8790
 STA BOMB

.CADAA

 LDA #$14
 STA NOSTM
 LDX #$FF
 STX MSTG
 LDA L0300
 ORA #$80
 STA L0300
 LDA #$80
 STA JSTX
 STA JSTY
 STA ALP2
 STA BET2
 ASL A
 STA DLY
 STA BETA
 STA BET1
 STA ALP2+1
 STA BET2+1
 STA MCNT
 STA LAS
 STA L03E7
 STA L03E8
 LDA #3
 STA DELTA
 STA ALPHA
 STA ALP1
 LDA #$48
 JSR subm_AE32
 LDA ECMA
 BEQ CADF3
 JSR ECMOF

.CADF3

 JSR WPSHPS
 LDA QQ11a
 BMI CAE00
 JSR subm_CE9E
 JSR subm_CEA5

.CAE00

 JSR subm_B46B

; ******************************************************************************
;
;       Name: ZINF_0
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.ZINF_0

 SETUP_PPU_FOR_ICON_BAR ; If the PPU has started drawing the icon bar, configure
                        ; the PPU to use nametable 0 and pattern table 0

 LDY #$25
 LDA #0

.loop_CAE14

 STA XX1,Y
 DEY
 BPL loop_CAE14

 SETUP_PPU_FOR_ICON_BAR ; If the PPU has started drawing the icon bar, configure
                        ; the PPU to use nametable 0 and pattern table 0

 LDA #$60
 STA INWK+18
 STA INWK+22
 ORA #$80
 STA INWK+14
 RTS

; ******************************************************************************
;
;       Name: subm_AE32
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.subm_AE32

 STA Yx1M2
 ASL A
 STA Yx2M2
 SBC #0
 STA Yx2M1
 RTS

; ******************************************************************************
;
;       Name: msblob
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.msblob

 LDX #4

.loop_CAE3E

 CPX NOMSL
 BEQ CAE4C
 LDY #$85
 JSR MSBAR
 DEX
 BNE loop_CAE3E
 RTS

.CAE4C

 LDY #$6C
 JSR MSBAR
 DEX
 BNE CAE4C
 RTS

; ******************************************************************************
;
;       Name: MTT4
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.MTT4

 JSR DORND
 LSR A
 STA INWK+32
 STA INWK+29
 ROL INWK+31
 AND #$0F
 ADC #$0A
 STA INWK+27
 JSR DORND
 BMI CAE74
 LDA INWK+32
 ORA #$C0
 STA INWK+32
 LDX #$10
 STX NEWB

.CAE74

 AND #2
 ADC #$0B
 CMP #$0F
 BNE CAE7E
 LDA #$0B

.CAE7E

 JSR NWSHP
 JMP MLOOP

; ******************************************************************************
;
;       Name: subm_AE84
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.subm_AE84

 LDA nmiTimerLo
 STA RAND
 LDA K%+6
 STA RAND+1
 LDA L0307
 STA RAND+3
 LDA QQ12
 BEQ TT100
 JMP MLOOP

; ******************************************************************************
;
;       Name: TT100
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.TT100

 JSR M%
 DEC MCNT
 BEQ CAEA3

.loop_CAEA0

 JMP MLOOP

.CAEA3

 LDA MJ
 ORA DLY
 BNE loop_CAEA0
 JSR DORND
 CMP #$28
 BCS MTT1
 LDA JUNK
 CMP #3
 BCS MTT1
 JSR ZINF_0
 LDA #$26
 STA INWK+7
 JSR DORND
 STA XX1
 STX INWK+3
 AND #$80
 STA INWK+2
 TXA
 AND #$80
 STA INWK+5
 ROL INWK+1
 ROL INWK+1
 JSR DORND
 AND #$30
 BNE CAEDE
 JMP MTT4

.CAEDE

 ORA #$6F
 STA INWK+29
 LDA SSPR
 BNE MLOOPS
 TXA
 BCS CAEF2
 AND #$1F
 ORA #$10
 STA INWK+27
 BCC CAEF6

.CAEF2

 ORA #$7F
 STA INWK+30

.CAEF6

 JSR DORND
 CMP #$FC
 BCC CAF03
 LDA #$0F
 STA INWK+32
 BNE CAF09

.CAF03

 CMP #$0A
 AND #1
 ADC #5

.CAF09

 JSR NWSHP

.MLOOPS

 JMP MLOOP

; ******************************************************************************
;
;       Name: MTT1
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.MTT1

 LDA SSPR
 BNE MLOOPS
 JSR BAD
 ASL A
 LDX MANY+16
 BEQ CAF20
 ORA FIST

.CAF20

 STA T
 JSR Ze
 CMP #$88
 BNE CAF2C
 JMP fothg

.CAF2C

 CMP T
 BCS CAF3B
 LDA NEWB
 ORA #4
 STA NEWB
 LDA #$10
 JSR NWSHP

.CAF3B

 LDA MANY+16
 BNE MLOOPS

; ******************************************************************************
;
;       Name: MainLoop4
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.MainLoop4

 DEC EV
 BPL MLOOPS
 INC EV
 LDA TP
 AND #$0C
 CMP #8
 BNE nopl
 JSR DORND
 CMP #$C8
 BCC nopl

.CAF58

 JSR SpawnThargoid
 JMP MLOOP

.nopl

 JSR DORND
 LDY gov
 BEQ LABEL_2
 LDY JUNK
 LDX FRIN+2,Y
 BEQ CAF72
 CMP #$32
 BCS MLOOPS

.CAF72

 CMP #$64
 BCS MLOOPS
 AND #7
 CMP gov
 BCC MLOOPS

.LABEL_2

 JSR Ze
 CMP #$64
 AND #$0F
 ORA #$10
 STA INWK+27
 BCS CAFCF
 INC EV
 AND #3
 ADC #$18
 TAY
 JSR THERE
 BCC CAFA8
 LDA #$F9
 STA INWK+32
 LDA TP
 AND #3
 LSR A
 BCC CAFA8
 ORA MANY+31
 BEQ LAFB4

.CAFA8

 JSR DORND
 CMP #$C8
 ROL A
 ORA #$C0
 STA INWK+32
 TYA

 EQUB $2C

.LAFB4

 LDA #$1F

.loop_CAFB6

 JSR NWSHP
 JMP MLOOP

.fothg

 LDA K%+6
 AND #$3E
 BNE CAF58
 LDA #$12
 STA INWK+27
 LDA #$79
 STA INWK+32
 LDA #$20
 BNE loop_CAFB6

.CAFCF

 AND #3
 STA EV
 STA XX13

.loop_CAFD6

 LDA #4
 STA NEWB
 JSR DORND
 STA T
 JSR DORND
 AND T
 AND #7
 ADC #$11
 JSR NWSHP
 DEC XX13
 BPL loop_CAFD6

; ******************************************************************************
;
;       Name: MLOOP
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.MLOOP

 LDX #$FF
 TXS
 LDX GNTMP
 BEQ CAFFA
 DEC GNTMP

.CAFFA

 LDX LASCT
 BEQ CB006
 DEX
 BEQ CB003
 DEX

.CB003

 STX LASCT

.CB006

 LDA QQ11
 BEQ CB00F
 LDY #4
 JSR DELAY

.CB00F

 LDA TRIBBLE+1
 BEQ CB02B
 JSR DORND
 CMP #$DC
 LDA TRIBBLE
 ADC #0
 STA TRIBBLE
 BCC CB02B
 INC TRIBBLE+1
 BPL CB02B
 DEC TRIBBLE+1

.CB02B

 LDA TRIBBLE+1
 BEQ CB04C
 LDY CABTMP
 CPY #$E0
 BCS CB039
 LSR A
 LSR A

.CB039

 STA T
 JSR DORND
 CMP T
 BCS CB04C
 AND #3
 TAY
 LDA LB079,Y
 TAY
 JSR NOISE

.CB04C

 LDA L0300
 LDX QQ22+1
 BEQ CB055
 ORA #$80

.CB055

 LDX DLY
 BEQ CB05C
 AND #$7F

.CB05C

 STA L0300
 AND #$C0
 BEQ CB070
 CMP #$C0
 BEQ CB070
 CMP #$80
 ROR A
 STA L0300
 JSR CAC5C_b3

.CB070

 JSR subm_AD25

.CB073

 JSR TT102
 JMP subm_AE84

; ******************************************************************************
;
;       Name: LB079
;       Type: Variable
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.LB079

 EQUB 5, 5, 5, 6                              ; B079: 05 05 05... ...

; ******************************************************************************
;
;       Name: TT102
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.TT102

 CMP #0
 BNE CB084
 JMP CB16A

.CB084

 CMP #3
 BNE CB08B
 JMP STATUS

.CB08B

 CMP #4
 BEQ CB09B
 CMP #$24
 BNE CB0A6
 LDA L0470
 EOR #$80
 STA L0470

.CB09B

 LDA L0470
 BPL CB0A3
 JMP TT22

.CB0A3

 JMP TT23

.CB0A6

 CMP #$23
 BNE CB0B0
 JSR subm_9D09
 JMP TT25

.CB0B0

 CMP #8
 BNE CB0B7
 JMP TT213

.CB0B7

 CMP #2
 BNE CB0BE
 JMP subm_9FE0

.CB0BE

 CMP #1
 BNE CB0CC
 LDX QQ12
 BEQ CB0CC
 JSR subm_9D03
 JMP TT110

.CB0CC

 CMP #$11
 BNE CB119
 LDX QQ12
 BNE CB119
 LDA auto
 BNE CB106
 LDA SSPR
 BEQ CB119
 LDA DKCMP
 ORA L03E8
 BNE CB0FA
 LDY #0
 LDX #$32
 JSR LCASH
 BCS CB0F2
 JMP BOOP

.CB0F2

 DEC L03E8
 LDA #0
 JSR MESS

.CB0FA

 LDA #1
 JSR KeepPPUTablesAt0
 JSR C8021_b6
 LDA #$FF
 BNE CB10B

.CB106

 JSR WaitResetSound
 LDA #0

.CB10B

 STA auto
 LDA QQ11
 BEQ CB118
 JSR CLYNS
 JSR subm_8980

.CB118

 RTS

.CB119

 JSR subm_B1D4
 CMP #$15
 BNE CB137
 LDA QQ12
 BPL CB125
 RTS

.CB125

 LDA #0
 LDX QQ11
 BNE CB133
 LDA VIEW
 CLC
 ADC #1
 AND #3

.CB133

 TAX
 JMP LOOK1

.CB137

 BIT QQ12
 BPL CB149
 CMP #5
 BNE CB142
 JMP EQSHP

.CB142

 CMP #6
 BNE CB149
 JMP CB459_b6

.CB149

 CMP #$16
 BNE CB150
 JMP C9E51

.CB150

 CMP #$29
 BNE CB157
 JMP C9E48

.CB157

 CMP #$27
 BNE CB16A
 LDA QQ22+1
 BNE CB1A5
 LDA QQ11
 AND #$0E
 CMP #$0C
 BNE CB1A5
 JMP HME2

.CB16A

 STA T1
 LDA QQ11
 AND #$0E
 CMP #$0C
 BNE CB18D
 LDA QQ22+1
 BNE CB18D
 LDA T1
 CMP #$26
 BNE CB18A
 JSR ping

.CB181

 ASL L0395
 LSR L0395
 JMP subm_9D09

.CB18A

 JSR subm_9AE7

.CB18D

 LDA QQ22+1
 BEQ CB1A5
 DEC QQ22
 BNE CB1A5
 LDA #5
 STA QQ22
 DEC QQ22+1
 BEQ CB1A2
 LDA #$FA
 JMP MESS

.CB1A2

 JMP TT18

.CB1A5

 RTS

; ******************************************************************************
;
;       Name: BAD
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.BAD

 LDA QQ20+3
 CLC
 ADC QQ20+6
 ASL A
 ADC QQ20+10
 RTS

; ******************************************************************************
;
;       Name: FAROF
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.FAROF

 LDA INWK+2
 ORA INWK+5
 ORA INWK+8
 ASL A
 BNE CB1C8
 LDA #$E0
 CMP INWK+1
 BCC CB1C7
 CMP INWK+4
 BCC CB1C7
 CMP INWK+7

.CB1C7

 RTS

.CB1C8

 CLC
 RTS

; ******************************************************************************
;
;       Name: MAS4
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.MAS4

 ORA INWK+1
 ORA INWK+4
 ORA INWK+7
 RTS

; ******************************************************************************
;
;       Name: subm_B1D1
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.subm_B1D1

 LDA L0465

; ******************************************************************************
;
;       Name: subm_B1D4
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.subm_B1D4

 CMP #$50
 BNE CB1E2
 LDA #0
 STA L0465
 JSR CA166_b6
 SEC
 RTS

.CB1E2

 CLC
 RTS

; ******************************************************************************
;
;       Name: DEATH
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.DEATH

 JSR WaitResetSound
 JSR EXNO3
 JSR RES2
 ASL DELTA
 ASL DELTA
 LDA #0
 STA boxEdge1
 STA boxEdge2
 STA L03EE
 LDA #$C4
 JSR TT66
 JSR CBED2_b6
 JSR CopyNametable0To1
 JSR subm_EB86
 LDA #0
 STA L045F
 LDA #$C4
 JSR CA7B7_b3
 LDA #0
 STA QQ11
 STA QQ11a
 LDA tileNumber
 STA L00D2
 LDA #$74
 STA L00D8
 LDX #8
 STX L00CC
 LDA #$68
 JSR subm_AE32
 LDY #8
 LDA #1

.loop_CB22F

 STA L0374,Y
 DEY
 BNE loop_CB22F
 JSR nWq
 JSR DORND
 AND #$87
 STA ALPHA
 AND #7
 STA ALP1
 LDA ALPHA
 AND #$80
 STA ALP2
 EOR #$80
 STA ALP2+1

.CB24D

 JSR Ze
 LSR A
 LSR A
 STA XX1
 LDY #0
 STY QQ11
 STY INWK+1
 STY INWK+4
 STY INWK+7
 STY INWK+32
 DEY
 STY MCNT
 EOR #$2A
 STA INWK+3
 ORA #$50
 STA INWK+6
 TXA
 AND #$8F
 STA INWK+29
 LDY #$40
 STY LASCT
 SEC
 ROR A
 AND #$87
 STA INWK+30
 LDX #5
 LDA XX21+7
 BEQ CB285
 BCC CB285
 DEX

.CB285

 JSR fq1
 JSR DORND
 AND #$80
 LDY #$1F
 STA (XX19),Y
 LDA FRIN+6
 BEQ CB24D
 LDA #8
 STA DELTA
 LDA #$0C
 STA L00B5
 LDA #$92
 LDY #$78
 JSR subm_B77A
 JSR subm_EB8F
 LDA #$1E
 STA LASCT

.loop_CB2AD

 JSR ChangeDrawingPhase
 JSR subm_MA23
 JSR CBED2_b6
 LDA #$CC
 JSR subm_D977
 DEC LASCT
 BNE loop_CB2AD
 JMP subm_B2EF

; ******************************************************************************
;
;       Name: subm_B2C3
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.subm_B2C3

 LDA #$FF
 STA L0307
 LDA #$80
 STA L0308
 LDA #$1B
 STA L0309
 LDA #$34
 STA L030A
 JSR ResetSoundL045E
 JSR CB90D_b6
 JSR subm_F3AB
 LDA #1
 STA L0037
 LDX #$FF
 STX QQ11a
 TXS
 JSR RESET
 JSR TITLE_b6

; ******************************************************************************
;
;       Name: subm_B2EF
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.subm_B2EF

 LDX #$FF
 TXS
 INX
 STX L0470
 JSR RES2
 LDA #5
 JSR subm_E909
 JSR ResetKeyLogger
 JSR subm_F3BC
 LDA controller1Select
 AND controller1Start
 AND controller1A
 AND controller1B
 BNE CB341
 LDA controller1Select
 ORA controller2Select
 BNE CB355
 LDA #0
 PHA
 JSR BR2_Part2
 LDA #$FF
 STA QQ11
 LDA L03EE
 BEQ CB32C
 JSR subm_F362

.CB32C

 JSR KeepPPUTablesAt0
 LDA #4
 JSR C8021_b6
 LDA L0305
 CLC
 ADC #6
 STA L0305
 PLA
 JMP CA5AB_b6

.CB341

 JSR BR2_Part2
 LDA #$FF
 STA QQ11
 JSR KeepPPUTablesAt0
 LDA #4
 JSR C8021_b6
 LDA #2
 JMP CA5AB_b6

.CB355

 JSR CB63D_b3

; ******************************************************************************
;
;       Name: subm_B358
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.subm_B358

 LDX #$FF
 TXS
 JSR BR2_Part2

; ******************************************************************************
;
;       Name: BAY
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.BAY

 JSR ClearTiles_b3
 LDA #$FF
 STA QQ12
 LDA #3
 JMP CB073

; ******************************************************************************
;
;       Name: BR2_Part2
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.BR2_Part2

 JSR SetupPPUForIconBar ; If the PPU has started drawing the icon bar, configure
                        ; the PPU to use nametable 0 and pattern table 0

 JSR CB8FE_b6
 JSR WaitResetSound
 JSR ping
 JSR TT111
 JSR jmp
 LDX #5

.loop_CB37E

 LDA QQ15,X
 STA QQ2,X
 DEX
 BPL loop_CB37E
 INX
 STX EV
 LDA QQ3
 STA QQ28
 LDA QQ5
 STA tek
 LDA QQ4
 STA gov
 RTS

; ******************************************************************************
;
;       Name: subm_B39D
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.subm_B39D

 JSR TT66
 JSR CopyNametable0To1
 JSR subm_F126
 LDA #0
 STA QQ11
 STA QQ11a
 STA L045F
 LDA tileNumber
 STA L00D2
 LDA #$50
 STA L00D8
 LDX #8
 STX L00CC
 RTS

; ******************************************************************************
;
;       Name: subm_B3BC
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.subm_B3BC

 STY L0480
 STX TYPE
 JSR RESET
 JSR ResetKeyLogger

 JSR SetupPPUForIconBar ; If the PPU has started drawing the icon bar, configure
                        ; the PPU to use nametable 0 and pattern table 0

 LDA #$60
 STA INWK+14
 LDA #$37
 STA INWK+7
 LDX #$7F
 STX INWK+29
 STX INWK+30
 INX
 STX QQ17
 LDA TYPE
 JSR NWSHP
 JSR CBAF3_b1
 LDA #$0C
 STA CNT2
 LDA #5
 STA MCNT
 LDY #0
 STY DELTA
 LDA #1
 JSR subm_B39D
 LDA #7
 STA YP

.loop_CB3F9

 LDA #$19
 STA XP

.loop_CB3FE

 LDA INWK+7
 CMP #1
 BEQ CB406
 DEC INWK+7

.CB406

 JSR subm_B426
 BCS CB422
 DEC XP
 BNE loop_CB3FE
 DEC YP
 BNE loop_CB3F9

.loop_CB415

 LDA INWK+7
 CMP #$37
 BCS CB424
 INC INWK+7
 JSR subm_B426
 BCC loop_CB415

.CB422

 SEC
 RTS

.CB424

 CLC
 RTS

; ******************************************************************************
;
;       Name: subm_B426
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.subm_B426

 JSR MVEIT3
 LDX L0480
 STX INWK+6
 LDA MCNT
 AND #3
 LDA #0
 STA XX1
 STA INWK+3

 SETUP_PPU_FOR_ICON_BAR ; If the PPU has started drawing the icon bar, configure
                        ; the PPU to use nametable 0 and pattern table 0

 JSR subm_D96F
 INC MCNT
 LDA controller1A
 ORA controller1Start
 ORA controller1Select
 BMI CB457
 BNE CB466

.CB457

 LDA controller2A
 ORA controller2Start
 ORA controller2Select
 BMI CB464
 BNE CB469

.CB464

 CLC
 RTS

.CB466

 LSR scanController2

.CB469

 SEC
 RTS

; ******************************************************************************
;
;       Name: subm_B46B
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.subm_B46B

 JSR SetupPPUForIconBar ; If the PPU has started drawing the icon bar, configure
                        ; the PPU to use nametable 0 and pattern table 0

 LDX #$2B
 LDA #0

.loop_CB472

 STA L0369,X
 DEX
 BNE loop_CB472
 LDX #$21

.loop_CB47A

 STA MANY,X
 DEX
 BPL loop_CB47A

 JSR SetupPPUForIconBar ; If the PPU has started drawing the icon bar, configure
                        ; the PPU to use nametable 0 and pattern table 0

 RTS

; ******************************************************************************
;
;       Name: ResetKeyLogger
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.ResetKeyLogger

 LDX #6
 LDA #0
 STA L0081

.loop_CB48A

 STA KL,X
 DEX
 BPL loop_CB48A
 RTS

; ******************************************************************************
;
;       Name: MAS1
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.MAS1

 LDA XX1,Y
 ASL A
 STA K+1
 LDA INWK+1,Y
 ROL A
 STA K+2
 LDA #0
 ROR A
 STA K+3
 JSR MVT3
 STA INWK+2,X
 LDY K+1
 STY XX1,X
 LDY K+2
 STY INWK+1,X
 AND #$7F
 RTS

; ******************************************************************************
;
;       Name: m
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.m

 LDA #0

; ******************************************************************************
;
;       Name: MAS2
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.MAS2

 ORA K%+2,Y
 ORA K%+5,Y
 ORA K%+8,Y
 AND #$7F
 RTS

; ******************************************************************************
;
;       Name: MAS3
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.MAS3

 LDA K%+1,Y
 JSR SQUA2
 STA R
 LDA K%+4,Y
 JSR SQUA2
 ADC R
 BCS CB4EB
 STA R

 SETUP_PPU_FOR_ICON_BAR ; If the PPU has started drawing the icon bar, configure
                        ; the PPU to use nametable 0 and pattern table 0

 LDA K%+7,Y
 JSR SQUA2
 ADC R
 BCC CB4ED

.CB4EB

 LDA #$FF

.CB4ED

 RTS

; ******************************************************************************
;
;       Name: subm_MainFlight14
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.subm_MainFlight14

 SETUP_PPU_FOR_ICON_BAR ; If the PPU has started drawing the icon bar, configure
                        ; the PPU to use nametable 0 and pattern table 0

 LDX #0
 LDY #9
 JSR MAS1
 BNE MA23S
 LDX #3
 LDY #$0B
 JSR MAS1
 BNE MA23S
 LDX #6
 LDY #$0D
 JSR MAS1
 BNE MA23S
 LDA #$64
 JSR FAROF2
 BCS MA23S
 JSR NWSPS
 SEC
 RTS

.MA23S

 SETUP_PPU_FOR_ICON_BAR ; If the PPU has started drawing the icon bar, configure
                        ; the PPU to use nametable 0 and pattern table 0

 CLC
 RTS

; ******************************************************************************
;
;       Name: SPS2
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.SPS2

 TAY
 AND #$7F
 LSR A
 LSR A
 LSR A
 LSR A
 ADC #0
 CPY #$80
 BCC CB542
 EOR #$FF
 ADC #0

.CB542

 TAX
 RTS

; ******************************************************************************
;
;       Name: subm_B544
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.subm_B544

 LDA K%+1,X
 STA K3,X
 LDA K%+2,X
 TAY
 AND #$7F
 STA XX2+1,X
 TYA
 AND #$80
 STA XX2+2,X
 RTS

; ******************************************************************************
;
;       Name: SPS1
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.SPS1

 LDX #0
 JSR subm_B544
 LDX #3
 JSR subm_B544
 LDX #6
 JSR subm_B544

; ******************************************************************************
;
;       Name: TAS2
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.TAS2

 SETUP_PPU_FOR_ICON_BAR ; If the PPU has started drawing the icon bar, configure
                        ; the PPU to use nametable 0 and pattern table 0

 LDA K3
 ORA XX2+3
 ORA XX2+6
 ORA #1
 STA XX2+9
 LDA XX2+1
 ORA XX2+4
 ORA XX2+7

.loop_CB583

 ASL XX2+9
 ROL A
 BCS CB596
 ASL K3
 ROL XX2+1
 ASL XX2+3
 ROL XX2+4
 ASL XX2+6
 ROL XX2+7
 BCC loop_CB583

.CB596

 LSR XX2+1
 LSR XX2+4
 LSR XX2+7

.TA2

 LDA XX2+1
 LSR A
 ORA XX2+2
 STA XX15
 LDA XX2+4
 LSR A
 ORA XX2+5
 STA Y1
 LDA XX2+7
 LSR A
 ORA XX2+8
 STA X2
 JMP NORM

; ******************************************************************************
;
;       Name: subm_B5B4
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.subm_B5B4

 LDA DLY
 BEQ CB5BF
 JSR ResetShipStatus
 JMP subm_B358

.CB5BF

 LDA auto
 AND SSPR
 BEQ CB5CA
 JMP GOIN

.CB5CA

 JSR subm_B5F8
 BCS CB5DF
 JSR subm_B5F8
 BCS CB5DF
 JSR subm_B5F8
 BCS CB5DF
 JSR KeepPPUTablesAt0
 JSR subm_B665

.CB5DF

 LDA #1
 STA MCNT
 LSR A
 STA EV
 JSR subm_MainFlight15
 LDA QQ11
 BNE CB5F7
 LDX VIEW
 DEC VIEW
 JMP LOOK1

.CB5F7

 RTS

; ******************************************************************************
;
;       Name: subm_B5F8
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.subm_B5F8

 JSR KeepPPUTablesAt0
 JSR subm_B665

; ******************************************************************************
;
;       Name: subm_B5FE
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.subm_B5FE

 LDA #$80

 LSR A
 STA T
 LDY #0
 JSR CB611
 BCS CB664
 LDA SSPR
 BNE CB664
 LDY #$2A

.CB611

 LDA K%+2,Y
 ORA K%+5,Y
 ASL A
 BNE CB661
 LDA K%+8,Y
 LSR A
 BNE CB661
 LDA K%+7,Y
 ROR A
 SEC
 SBC #$20
 BCS CB62D
 EOR #$FF
 ADC #1

.CB62D

 STA K+2
 LDA K%+1,Y
 LSR A
 STA K
 LDA K%+4,Y
 LSR A
 STA K+1
 CMP K
 BCS CB641
 LDA K

.CB641

 CMP K+2
 BCS CB647
 LDA K+2

.CB647

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
 BCC CB663

.CB661

 CLC
 RTS

.CB663

 SEC

.CB664

 RTS

; ******************************************************************************
;
;       Name: subm_B665
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.subm_B665

 LDY #$20

.loop_CB667

 JSR subm_MainFlight13
 DEY
 BNE loop_CB667
 LDX #0
 STX GNTMP

.CB672

 STX XSAV
 LDA FRIN,X
 BEQ CB6A7
 BMI CB686
 JSR GINF
 JSR subm_AC19
 LDX XSAV
 JMP CB672

.CB686

 JSR GINF
 LDA #$80
 STA S
 LSR A
 STA R
 LDY #7
 LDA (XX19),Y
 STA P
 INY
 LDA (XX19),Y
 JSR ADD
 STA (XX19),Y
 DEY
 TXA
 STA (XX19),Y
 LDX XSAV
 INX
 BNE CB672

.CB6A7

 RTS

; ******************************************************************************
;
;       Name: DOKEY
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.DOKEY

 JSR CBBDE_b6
 LDA auto
 BNE CB6BA

.CB6B0

 LDX L0081
 CPX #$40
 BNE CB6B9
 JMP CA166_b6

.CB6B9

 RTS

.CB6BA

 LDA SSPR
 BNE CB6C8
 STA auto
 JSR WaitResetSound
 JMP CB6B0

.CB6C8

 JSR ZINF_0
 LDA #$60
 STA INWK+14
 ORA #$80
 STA INWK+22
 STA TYPE
 LDA DELTA
 STA INWK+27
 JSR DOCKIT
 LDA INWK+27
 CMP #$16
 BCC CB6E4
 LDA #$16

.CB6E4

 STA DELTA
 LDA #$FF
 LDX #0
 LDY INWK+28
 BEQ CB6F5
 BMI CB6F2
 LDX #1

.CB6F2

 STA KL,X

.CB6F5

 LDA #$80
 LDX #2
 ASL INWK+29
 BEQ CB712
 BCC CB701
 LDX #3

.CB701

 BIT INWK+29
 BPL CB70C
 LDA #$40
 STA JSTX
 LDA #0

.CB70C

 STA KL,X
 LDA JSTX

.CB712

 STA JSTX
 LDA #$80
 LDX #4
 ASL INWK+30
 BEQ CB727
 BCS CB721
 LDX #5

.CB721

 STA KL,X
 LDA JSTY

.CB727

 STA JSTY
 LDX JSTX
 LDA #$0E
 LDY KY3
 BEQ CB737
 JSR BUMP2

.CB737

 LDY KY4
 BEQ CB73F
 JSR REDU2

.CB73F

 STX JSTX
 LDA #$0E
 LDX JSTY
 LDY KY5
 BEQ CB74F
 JSR REDU2

.CB74F

 LDY KY6
 BEQ CB757
 JSR BUMP2

.CB757

 STX JSTY
 LDA auto
 BNE CB777
 LDX #$80
 LDA KY3
 ORA KY4
 BNE CB76C
 STX JSTX

.CB76C

 LDA KY5
 ORA KY6
 BNE CB777
 STX JSTY

.CB777

 JMP CB6B0

; ******************************************************************************
;
;       Name: subm_B77A
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.subm_B77A

 PHA
 STY L0393
 LDA #$C0
 STA DTW4
 LDA #0
 STA DTW5
 PLA
 JSR ex_b2
 JMP CB7F2

; ******************************************************************************
;
;       Name: MESS
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.MESS

 PHA

 SETUP_PPU_FOR_ICON_BAR ; If the PPU has started drawing the icon bar, configure
                        ; the PPU to use nametable 0 and pattern table 0

 LDY #$0A
 STY L0393
 LDA #$C0
 STA DTW4
 LDA #0
 STA DTW5
 PLA
 CMP #$FA
 BNE CB7DF
 LDA #0
 STA QQ17
 LDA #$BD
 JSR TT27_b2
 LDA #$2D
 JSR TT27_b2
 JSR TT162

 SETUP_PPU_FOR_ICON_BAR ; If the PPU has started drawing the icon bar, configure
                        ; the PPU to use nametable 0 and pattern table 0

 JSR hyp1_cpl
 LDA #3
 CLC
 LDX QQ22+1
 LDY #0
 JSR TT11
 JMP CB7E8

.CB7DF

 PHA
 LDA #0
 STA QQ17
 PLA
 JSR TT27_b2

.CB7E8

 LDA L0394
 BEQ CB7F2
 LDA #$FD
 JSR TT27_b2

.CB7F2

 LDA #$20
 SEC
 SBC DTW5
 BCS CB801
 LDA #$1F
 STA DTW5
 LDA #2

.CB801

 LSR A
 STA messXC

 SETUP_PPU_FOR_ICON_BAR ; If the PPU has started drawing the icon bar, configure
                        ; the PPU to use nametable 0 and pattern table 0

 LDX DTW5
 STX L0584
 INX

.loop_CB818

 LDA BUF-1,X
 STA L0584,X
 DEX
 BNE loop_CB818
 STX L0394

 SETUP_PPU_FOR_ICON_BAR ; If the PPU has started drawing the icon bar, configure
                        ; the PPU to use nametable 0 and pattern table 0

.CB831

 LDA #0
 STA DTW4
 STA DTW5

.CB839

 RTS

; ******************************************************************************
;
;       Name: LASLI2
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.LASLI2

 LDA L00B5
 LDX QQ11
 BEQ CB845
 JSR CLYNS+8
 LDA #$17

.CB845

 STA YC
 LDX #0
 STX QQ17

 SETUP_PPU_FOR_ICON_BAR ; If the PPU has started drawing the icon bar, configure
                        ; the PPU to use nametable 0 and pattern table 0

 LDA messXC
 STA XC
 LDA messXC
 STA XC
 LDY #0

.loop_CB862

 LDA L0585,Y
 JSR CHPR_b2
 INY
 CPY L0584
 BNE loop_CB862
 LDA QQ11
 BEQ CB839
 JMP subm_D951

; ******************************************************************************
;
;       Name: OUCH
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.OUCH

 JSR DORND
 BMI CB8A9
 CPX #$16
 BCS CB8A9
 LDA QQ20,X
 BEQ CB8A9
 LDA L0393
 BNE CB8A9
 LDY #3
 STY L0394
 STA QQ20,X
 CPX #$11
 BCS CB89A
 TXA
 ADC #$D0
 JMP MESS

.CB89A

 BEQ CB8AA
 CPX #$12
 BEQ CB8AE
 TXA
 ADC #$5D

.loop_CB8A3

 JSR MESS
 JMP CAC5C_b3

.CB8A9

 RTS

.CB8AA

 LDA #$6C
 BNE loop_CB8A3

.CB8AE

 LDA #$6F
 JMP MESS

; ******************************************************************************
;
;       Name: QQ23
;       Type: Variable
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.QQ23

 EQUB $13                                     ; B8B3: 13          .
 EQUB $82                                     ; B8B4: 82          .
 EQUB 6                                       ; B8B5: 06          .
 EQUB   1, $14, $81, $0A,   3, $41, $83,   2  ; B8B6: 01 14 81... ...
 EQUB   7, $28, $85, $E2, $1F, $53, $85, $FB  ; B8BE: 07 28 85... .(.
 EQUB $0F, $C4,   8, $36,   3, $EB, $1D,   8  ; B8C6: 0F C4 08... ...
 EQUB $78, $9A, $0E, $38,   3, $75,   6, $28  ; B8CE: 78 9A 0E... x..
 EQUB   7, $4E,   1, $11, $1F, $7C, $0D, $1D  ; B8D6: 07 4E 01... .N.
 EQUB   7, $B0, $89, $DC, $3F, $20, $81, $35  ; B8DE: 07 B0 89... ...
 EQUB   3, $61, $A1, $42,   7, $AB, $A2, $37  ; B8E6: 03 61 A1... .a.
 EQUB $1F, $2D, $C1, $FA, $0F, $35, $0F, $C0  ; B8EE: 1F 2D C1... .-.
 EQUB   7                                     ; B8F6: 07          .

; ******************************************************************************
;
;       Name: PAS1
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.PAS1

 LDA #$64
 STA INWK+3
 LDA #0
 STA XX1
 STA INWK+6
 LDA #2
 STA INWK+7
 JSR subm_D96F
 INC MCNT
 JMP MVEIT

; ******************************************************************************
;
;       Name: subm_B90D
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.subm_B90D

 JMP CBBDE_b6

; ******************************************************************************
;
;       Name: MVEIT
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.MVEIT

 SETUP_PPU_FOR_ICON_BAR ; If the PPU has started drawing the icon bar, configure
                        ; the PPU to use nametable 0 and pattern table 0

 LDA INWK+31
 AND #$A0
 BNE MVEIT3
 LDA MCNT
 EOR XSAV
 AND #$0F
 BNE MV3
 JSR TIDY_b1

; ******************************************************************************
;
;       Name: MV3
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.MV3

 LDX TYPE
 BPL CB935
 JMP MV40

.CB935

 LDA INWK+32
 BPL MVEIT3
 CPX #1
 BEQ CB945
 LDA MCNT
 EOR XSAV
 AND #7
 BNE MVEIT3

.CB945

 SETUP_PPU_FOR_ICON_BAR ; If the PPU has started drawing the icon bar, configure
                        ; the PPU to use nametable 0 and pattern table 0

 JSR TACTICS

; ******************************************************************************
;
;       Name: MVEIT3
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.MVEIT3

 SETUP_PPU_FOR_ICON_BAR ; If the PPU has started drawing the icon bar, configure
                        ; the PPU to use nametable 0 and pattern table 0

 LDA INWK+27
 ASL A
 ASL A
 STA Q
 LDA INWK+10
 AND #$7F
 JSR FMLTU
 STA R
 LDA INWK+10
 LDX #0
 JSR MVT1m2
 LDA INWK+12
 AND #$7F
 JSR FMLTU
 STA R
 LDA INWK+12
 LDX #3
 JSR MVT1m2
 LDA INWK+14
 AND #$7F
 JSR FMLTU
 STA R

 SETUP_PPU_FOR_ICON_BAR ; If the PPU has started drawing the icon bar, configure
                        ; the PPU to use nametable 0 and pattern table 0

 LDA INWK+14
 LDX #6
 JSR MVT1m2

; ******************************************************************************
;
;       Name: MVEIT4
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.MVEIT4

 LDA INWK+27
 CLC
 ADC INWK+28
 BPL CB9AE
 LDA #0

.CB9AE

 STA INWK+27
 LDY #$0F
 JSR GetShipBlueprint   ; Set A to the Y-th byte from the current ship blueprint
 CMP INWK+27
 BCS CB9BB
 STA INWK+27

.CB9BB

 LDA #0
 STA INWK+28

; ******************************************************************************
;
;       Name: MVEIT5
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.MVEIT5

 LDX ALP1
 LDA XX1
 EOR #$FF
 STA P
 LDA INWK+1
 JSR MLTU2-2
 STA P+2
 LDA ALP2+1
 EOR INWK+2
 LDX #3
 JSR MVT6
 STA K2+3

 SETUP_PPU_FOR_ICON_BAR ; If the PPU has started drawing the icon bar, configure
                        ; the PPU to use nametable 0 and pattern table 0

 LDA P+1
 STA K2+1
 EOR #$FF
 STA P
 LDA P+2
 STA K2+2
 LDX BET1
 JSR MLTU2-2
 STA P+2
 LDA K2+3
 EOR BET2
 LDX #6
 JSR MVT6
 STA INWK+8

 SETUP_PPU_FOR_ICON_BAR ; If the PPU has started drawing the icon bar, configure
                        ; the PPU to use nametable 0 and pattern table 0

 LDA P+1
 STA INWK+6
 EOR #$FF
 STA P
 LDA P+2
 STA INWK+7
 JSR MLTU2
 STA P+2
 LDA K2+3
 STA INWK+5
 EOR BET2
 EOR INWK+8
 BPL CBA42
 LDA P+1
 ADC K2+1
 STA INWK+3
 LDA P+2
 ADC K2+2
 STA INWK+4
 JMP CBA71

.CBA42

 SETUP_PPU_FOR_ICON_BAR ; If the PPU has started drawing the icon bar, configure
                        ; the PPU to use nametable 0 and pattern table 0

 LDA K2+1
 SBC P+1
 STA INWK+3
 LDA K2+2
 SBC P+2
 STA INWK+4
 BCS CBA71
 LDA #1
 SBC INWK+3
 STA INWK+3
 LDA #0
 SBC INWK+4
 STA INWK+4
 LDA INWK+5
 EOR #$80
 STA INWK+5

.CBA71

 SETUP_PPU_FOR_ICON_BAR ; If the PPU has started drawing the icon bar, configure
                        ; the PPU to use nametable 0 and pattern table 0

 LDX ALP1
 LDA INWK+3
 EOR #$FF
 STA P
 LDA INWK+4
 JSR MLTU2-2
 STA P+2
 LDA ALP2
 EOR INWK+5
 LDX #0
 JSR MVT6
 STA INWK+2
 LDA P+2
 STA INWK+1
 LDA P+1
 STA XX1

; ******************************************************************************
;
;       Name: MV45
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.MV45

 SETUP_PPU_FOR_ICON_BAR ; If the PPU has started drawing the icon bar, configure
                        ; the PPU to use nametable 0 and pattern table 0

 LDA DELTA
 STA R
 LDA #$80
 LDX #6
 JSR MVT1
 LDA TYPE
 AND #$81
 CMP #$81
 BNE CBAC1
 RTS

.CBAC1

 LDY #9
 JSR MVS4
 LDY #$0F
 JSR MVS4
 LDY #$15
 JSR MVS4
 LDA INWK+30
 AND #$80
 STA RAT2
 LDA INWK+30
 AND #$7F
 BEQ CBAF9
 CMP #$7F
 SBC #0
 ORA RAT2
 STA INWK+30
 LDX #$0F
 LDY #9
 JSR MVS5
 LDX #$11
 LDY #$0B
 JSR MVS5
 LDX #$13
 LDY #$0D
 JSR MVS5

.CBAF9

 SETUP_PPU_FOR_ICON_BAR ; If the PPU has started drawing the icon bar, configure
                        ; the PPU to use nametable 0 and pattern table 0

 LDA INWK+29
 AND #$80
 STA RAT2
 LDA INWK+29
 AND #$7F
 BEQ MV5
 CMP #$7F
 SBC #0
 ORA RAT2
 STA INWK+29
 LDX #$0F
 LDY #$15
 JSR MVS5
 LDX #$11
 LDY #$17
 JSR MVS5
 LDX #$13
 LDY #$19
 JSR MVS5

; ******************************************************************************
;
;       Name: MV5
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.MV5

 LDA INWK+31
 ORA #$10
 STA INWK+31
 JMP SCAN_b1

; ******************************************************************************
;
;       Name: MVT1m2
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.MVT1m2

 AND #$80

; ******************************************************************************
;
;       Name: MVT1
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.MVT1

 ASL A
 STA S
 LDA #0
 ROR A
 STA T
 LSR S
 EOR INWK+2,X
 BMI CBB5D
 LDA R
 ADC XX1,X
 STA XX1,X
 LDA S
 ADC INWK+1,X
 STA INWK+1,X
 LDA INWK+2,X
 ADC #0
 ORA T
 STA INWK+2,X
 RTS

.CBB5D

 LDA XX1,X
 SEC
 SBC R
 STA XX1,X
 LDA INWK+1,X
 SBC S
 STA INWK+1,X
 LDA INWK+2,X
 AND #$7F
 SBC #0
 ORA #$80
 EOR T
 STA INWK+2,X
 BCS CBB8E
 LDA #1
 SBC XX1,X
 STA XX1,X
 LDA #0
 SBC INWK+1,X
 STA INWK+1,X
 LDA #0
 SBC INWK+2,X
 AND #$7F
 ORA T
 STA INWK+2,X

.CBB8E

 RTS

; ******************************************************************************
;
;       Name: MVS4
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.MVS4

 SETUP_PPU_FOR_ICON_BAR ; If the PPU has started drawing the icon bar, configure
                        ; the PPU to use nametable 0 and pattern table 0

 LDA ALPHA
 STA Q
 LDX INWK+2,Y
 STX R
 LDX INWK+3,Y
 STX S
 LDX XX1,Y
 STX P
 LDA INWK+1,Y
 EOR #$80
 JSR MAD
 STA INWK+3,Y
 STX INWK+2,Y
 STX P
 LDX XX1,Y
 STX R
 LDX INWK+1,Y
 STX S
 LDA INWK+3,Y
 JSR MAD
 STA INWK+1,Y
 STX XX1,Y
 STX P

 SETUP_PPU_FOR_ICON_BAR ; If the PPU has started drawing the icon bar, configure
                        ; the PPU to use nametable 0 and pattern table 0

 LDA BETA
 STA Q
 LDX INWK+2,Y
 STX R
 LDX INWK+3,Y
 STX S
 LDX INWK+4,Y
 STX P
 LDA INWK+5,Y
 EOR #$80
 JSR MAD
 STA INWK+3,Y
 STX INWK+2,Y
 STX P
 LDX INWK+4,Y
 STX R
 LDX INWK+5,Y
 STX S
 LDA INWK+3,Y
 JSR MAD
 STA INWK+5,Y
 STX INWK+4,Y

 SETUP_PPU_FOR_ICON_BAR ; If the PPU has started drawing the icon bar, configure
                        ; the PPU to use nametable 0 and pattern table 0

 RTS

; ******************************************************************************
;
;       Name: MVT6
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.MVT6

 TAY
 EOR INWK+2,X
 BMI CBC31
 LDA P+1
 CLC
 ADC XX1,X
 STA P+1
 LDA P+2
 ADC INWK+1,X
 STA P+2
 TYA
 RTS

.CBC31

 LDA XX1,X
 SEC
 SBC P+1
 STA P+1
 LDA INWK+1,X
 SBC P+2
 STA P+2
 BCC CBC44
 TYA
 EOR #$80
 RTS

.CBC44

 LDA #1
 SBC P+1
 STA P+1
 LDA #0
 SBC P+2
 STA P+2
 TYA
 RTS

; ******************************************************************************
;
;       Name: MV40
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.MV40

 LDA ALPHA
 EOR #$80
 STA Q
 LDA XX1
 STA P
 LDA INWK+1
 STA P+1
 LDA INWK+2
 JSR MULT3
 LDX #3
 JSR MVT3
 LDA K+1
 STA K2+1
 STA P
 LDA K+2
 STA K2+2
 STA P+1
 LDA BETA
 STA Q
 LDA K+3
 STA K2+3
 JSR MULT3
 LDX #6
 JSR MVT3
 LDA K+1
 STA P
 STA INWK+6
 LDA K+2
 STA P+1
 STA INWK+7
 LDA K+3
 STA INWK+8
 EOR #$80
 JSR MULT3
 LDA K+3
 AND #$80
 STA T
 EOR K2+3
 BMI CBCC5
 LDA K
 CLC
 ADC K2
 LDA K+1
 ADC K2+1
 STA INWK+3
 LDA K+2
 ADC K2+2
 STA INWK+4
 LDA K+3
 ADC K2+3
 JMP CBCFC

.CBCC5

 LDA K
 SEC
 SBC K2
 LDA K+1
 SBC K2+1
 STA INWK+3
 LDA K+2
 SBC K2+2
 STA INWK+4
 LDA K2+3
 AND #$7F
 STA P
 LDA K+3
 AND #$7F
 SBC P
 STA P
 BCS CBCFC
 LDA #1
 SBC INWK+3
 STA INWK+3
 LDA #0
 SBC INWK+4
 STA INWK+4
 LDA #0
 SBC P
 ORA #$80

.CBCFC

 EOR T
 STA INWK+5
 LDA ALPHA
 STA Q
 LDA INWK+3
 STA P
 LDA INWK+4
 STA P+1
 LDA INWK+5
 JSR MULT3
 LDX #0
 JSR MVT3
 LDA K+1
 STA XX1
 LDA K+2
 STA INWK+1
 LDA K+3
 STA INWK+2
 JMP MV45

; ******************************************************************************
;
;       Name: PLUT
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.PLUT

 LDX VIEW
 BEQ CBD5D
 DEX
 BNE CBD5E
 LDA INWK+2
 EOR #$80
 STA INWK+2
 LDA INWK+8
 EOR #$80
 STA INWK+8
 LDA INWK+10
 EOR #$80
 STA INWK+10
 LDA INWK+14
 EOR #$80
 STA INWK+14
 LDA INWK+16
 EOR #$80
 STA INWK+16
 LDA INWK+20
 EOR #$80
 STA INWK+20
 LDA INWK+22
 EOR #$80
 STA INWK+22
 LDA INWK+26
 EOR #$80
 STA INWK+26

.CBD5D

 RTS

.CBD5E

 LDA #0
 CPX #2
 ROR A
 STA RAT2
 EOR #$80
 STA RAT
 LDA XX1
 LDX INWK+6
 STA INWK+6
 STX XX1
 LDA INWK+1
 LDX INWK+7
 STA INWK+7
 STX INWK+1
 LDA INWK+2
 EOR RAT
 TAX
 LDA INWK+8
 EOR RAT2
 STA INWK+2
 STX INWK+8
 LDY #9
 JSR CBD92
 LDY #$0F
 JSR CBD92
 LDY #$15

.CBD92

 LDA XX1,Y
 LDX INWK+4,Y
 STA INWK+4,Y
 STX XX1,Y
 LDA INWK+1,Y
 EOR RAT
 TAX
 LDA INWK+5,Y
 EOR RAT2
 STA INWK+1,Y
 STX INWK+5,Y

.LO2

 RTS

.LQ

 JSR subm_BDED
 JMP NWSTARS

; ******************************************************************************
;
;       Name: LOOK1
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.LOOK1

 LDA #0
 LDY QQ11
 BNE LQ
 CPX VIEW
 BEQ LO2
 JSR ResetStardust
 JSR FLIP
 JMP KeepPPUTablesAt0

; ******************************************************************************
;
;       Name: FLIP
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.FLIP

 LDY NOSTM

.CBDCA

 SETUP_PPU_FOR_ICON_BAR ; If the PPU has started drawing the icon bar, configure
                        ; the PPU to use nametable 0 and pattern table 0

 LDX SY,Y
 LDA SX,Y
 STA SY,Y
 TXA
 STA SX,Y
 LDA SZ,Y
 STA ZZ
 DEY
 BNE CBDCA
 RTS

; ******************************************************************************
;
;       Name: subm_BDED
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.subm_BDED

 LDA #$48
 JSR subm_AE32
 STX VIEW
 LDA #0
 JSR TT66
 JSR CopyNametable0To1
 JSR CA7B7_b3
 JMP CBE17

; ******************************************************************************
;
;       Name: ResetStardust
;       Type: Subroutine
;   Category: ???
;    Summary: Draws sprites for stardust
;
; ------------------------------------------------------------------------------
;
; writes to the 20 sprites from 38 onwards, tile = 210, y = $F0
; attr is based on sprite number
;
; ******************************************************************************

.ResetStardust

 STX VIEW
 LDA #0
 JSR TT66
 JSR CopyNametable0To1
 LDA #$50
 STA L00CD
 STA L00CE
 JSR CA9D1_b3

.CBE17

 LDX #$14
 LDY #$98

.CBE1B

 SETUP_PPU_FOR_ICON_BAR ; If the PPU has started drawing the icon bar, configure
                        ; the PPU to use nametable 0 and pattern table 0

 LDA #$F0
 STA ySprite0,Y
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
 BNE CBE1B
 JSR KeepPPUTablesAt0
 JSR CBA23_b3

; ******************************************************************************
;
;       Name: subm_BE48
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.subm_BE48

 LDA #$FF
 STA L045F
 LDA #$2C
 STA visibleColour
 LDA tileNumber
 STA L00D2
 LDA #$50
 STA L00D8
 LDX #8
 STX L00CC
 LDA #$74
 STA L00CD
 RTS

; ******************************************************************************
;
;       Name: ECMOF
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.ECMOF

 LDA #0
 STA ECMA
 STA ECMP
 LDY #2
 JMP ECBLB

; ******************************************************************************
;
;       Name: SFRMIS
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.SFRMIS

 LDX #1
 JSR SFS1-2
 BCC CBE7F
 LDA #$78
 JSR MESS
 LDY #9
 JMP NOISE

.CBE7F

 RTS

; ******************************************************************************
;
;       Name: EXNO2
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.EXNO2

 JSR IncreaseTally
 BCC CBE8D
 INC TALLY+1
 LDA #$65
 JSR MESS

.CBE8D

 LDA INWK+7
 LDX #0
 CMP #$10
 BCS CBEA5
 INX
 CMP #8
 BCS CBEA5
 INX
 CMP #6
 BCS CBEA5
 INX
 CMP #3
 BCS CBEA5
 INX

.CBEA5

 LDY LBEAB,X
 JMP NOISE

; ******************************************************************************
;
;       Name: LBEAB
;       Type: Variable
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.LBEAB

 EQUB $1B, $17, $0E, $0D, $0D                 ; BEAB: 1B 17 0E... ...

; ******************************************************************************
;
;       Name: EXNO
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.EXNO

 LDY #$0A
 JMP NOISE

; ******************************************************************************
;
;       Name: TT66
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.TT66

 STA QQ11
 LDA QQ11a
 ORA QQ11
 BMI CBEC4
 LDA QQ11
 BPL CBEC4
 JSR subm_CEA5

.CBEC4

 JSR subm_D8C5
 JSR ClearTiles_b3
 LDA #$10
 STA L00B5
 LDX #0
 STX L046D
 JSR subm_D8EC
 LDA #$80
 STA QQ17
 STA DTW2
 STA DTW1
 LDA #0
 STA DTW6
 STA LAS2
 STA L0393
 STA L0394
 LDA #1
 STA XC
 STA YC
 JSR CAFCD_b3
 LDA QQ11
 LDX #$FF
 AND #$40
 BNE CBF19
 LDX #4
 LDA QQ11
 CMP #1
 BEQ CBF19
 LDX #2
 LDA QQ11
 AND #$0E
 CMP #$0C
 BEQ CBF19
 LDX #1
 LDA QQ12
 BEQ CBF19
 LDX #0

.CBF19

 LDA QQ11
 BMI CBF37
 TXA
 JSR CAE18_b3
 LDA QQ11a
 BPL CBF2B
 JSR subm_EB86
 JSR CA775_b3

.CBF2B

 JSR CA730_b3
 JSR msblob
 JMP CBF91

.loop_CBF34

 JMP CB9E2_b3

.CBF37

 TXA
 JSR CAE18_b3
 LDA QQ11
 CMP #$C4
 BEQ loop_CBF34
 LDA QQ11
 CMP #$8D
 BEQ CBF54
 CMP #$CF
 BEQ CBF54
 AND #$10
 BEQ CBF54
 LDA #$42
 JSR CB0E1_b3

.CBF54

 LDA QQ11
 AND #$20
 BEQ CBF5D
 JSR CB18E_b3

.CBF5D

 LDA #1
 STA nameBuffer0+641
 STA nameBuffer0+673
 STA nameBuffer0+705
 STA nameBuffer0+737
 STA nameBuffer0+769
 STA nameBuffer0+801
 STA nameBuffer0+833
 LDA #2
 STA nameBuffer0+640
 STA nameBuffer0+672
 STA nameBuffer0+704
 STA nameBuffer0+736
 STA nameBuffer0+768
 STA nameBuffer0+800
 STA nameBuffer0+832
 LDA QQ11
 AND #$40
 BNE CBF91

.CBF91

 JSR CB9E2_b3
 LDA DLY
 BMI CBFA1
 LDA QQ11
 BPL CBFA1
 CMP QQ11a
 BEQ CBFA1

.CBFA1

 JSR subm_CD62
 LDX language
 LDA QQ11
 BEQ CBFBF
 CMP #1
 BNE CBFD8
 LDA #0
 STA YC
 LDX language
 LDA LC0DF,X
 STA XC
 LDA #$1E
 BNE CBFD5

.CBFBF

 STA YC
 LDA LC0E3,X
 STA XC
 LDA L04A9
 AND #2
 BNE CBFE2
 JSR subm_BFED
 JSR TT162
 LDA #$AF

.CBFD5

 JSR TT27_b2

.CBFD8

 LDX #1
 STX XC
 STX YC
 DEX
 STX QQ17
 RTS

.CBFE2

 LDA #$AF
 JSR spc
 JSR subm_BFED
 JMP CBFD8

; ******************************************************************************
;
;       Name: subm_BFED
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.subm_BFED

 LDA VIEW
 ORA #$60
 JMP TT27_b2

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
                        ; into $C000 during startup (the handler contains an RTI
                        ; so the interrupt is processed but has no effect)

 EQUW ResetMMC1+$4000   ; Vector to the RESET handler in case this bank is
                        ; loaded into $C000 during startup (the handler resets
                        ; the MMC1 mapper to map bank 7 into $C000 instead)

 EQUW Interrupts+$4000  ; Vector to the IRQ/BRK handler in case this bank is
                        ; loaded into $C000 during startup (the handler contains
                        ; an RTI so the interrupt is processed but has no
                        ; effect)

ELIF _PAL

 EQUW NMI               ; Vector to the NMI handler

 EQUW ResetMMC1+$4000   ; Vector to the RESET handler in case this bank is
                        ; loaded into $C000 during startup (the handler resets
                        ; the MMC1 mapper to map bank 7 into $C000 instead)

 EQUW IRQ               ; Vector to the IRQ/BRK handler

ENDIF

; ******************************************************************************
;
; Save bank0.bin
;
; ******************************************************************************

 PRINT "S.bank0.bin ", ~CODE%, " ", ~P%, " ", ~LOAD%, " ", ~LOAD%
 SAVE "3-assembled-output/bank0.bin", CODE%, P%, LOAD%
