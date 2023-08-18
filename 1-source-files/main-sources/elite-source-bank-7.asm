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
; jumps into bank 7 at the game's entry point BEGIN, which starts the game.
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
;       Name: BEGIN
;       Type: Subroutine
;   Category: Start and end
;    Summary: Run through the NES initialisation process, reset the variables
;             and start the game
;
; ******************************************************************************

.BEGIN

 SEI                    ; Disable interrupts

 CLD                    ; Clear the decimal flag, so we're not in decimal mode
                        ; (this has no effect on the NES, as BCD mode is
                        ; disabled in the 2A03 CPU, but we do this to ensure
                        ; compatibility with 6502-based debuggers)

 LDX #$FF               ; Set the stack pointer to $01FF, which is the standard
 TXS                    ; location for the 6502 stack, so this instruction
                        ; effectively resets the stack

 LDX #0                 ; Set startupDebug = 0 (though this value is never read,
 STX startupDebug       ; so this has no effect)

 LDA #%00010000         ; Configure the PPU by setting PPU_CTRL as follows:
 STA PPU_CTRL           ;
                        ;   * Bits 0-1    = base nametable address %00 ($2000)
                        ;   * Bit 2 clear = increment PPU_ADDR by 1 each time
                        ;   * Bit 3 clear = sprite pattern table is at $0000
                        ;   * Bit 4 set   = background pattern table is at $1000
                        ;   * Bit 5 clear = sprites are 8x8 pixels
                        ;   * Bit 6 clear = use PPU 0 (the only option on a NES)
                        ;   * Bit 7 clear = disable VBlank NMI generation

 STA ppuCtrlCopy        ; Store the new value of PPU_CTRL in ppuCtrlCopy so we
                        ; can check its value without having to access the PPU

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

                        ; We now wait for three VBlanks to pass to ensure that 
                        ; the PPU has stabilised after starting up

.sper1

 LDA PPU_STATUS         ; Wait for the first VBlank to pass, which will set bit
 BPL sper1              ; 7 of PPU_STATUS (and reading PPU_STATUS clears bit 7,
                        ; ready for the next VBlank)

.sper2

 LDA PPU_STATUS         ; Wait for the second VBlank to pass
 BPL sper2

.sper3

 LDA PPU_STATUS         ; Wait for the third VBlank to pass
 BPL sper3

 LDA #0                 ; Set K% = 0 (English) to set as the default highlighted
 STA K%                 ; language on the Start screen (see the ChooseLanguage
                        ; routine)

 LDA #60                ; Set K%+1 = 60 to use as the value of the third counter
 STA K%+1               ; when deciding how long to wait on the Start screen
                        ; before auto-playing the demo (see the ChooseLanguage
                        ; routine)

.CC035

 LDX #$FF               ; Set the stack pointer to $01FF, which is the standard
 TXS                    ; location for the 6502 stack, so this instruction
                        ; effectively resets the stack

 JSR ResetVariables     ; Reset all the RAM (in both the NES and cartridge), as
                        ; it is in an undefined state when the NES is switched
                        ; on, initialise all the game's variables, and switch to
                        ; ROM bank 0

 JMP ShowStartScreen    ; Jump to ShowStartScreen in bank 0 to show the start
                        ; screen and start the game

; ******************************************************************************
;
;       Name: ResetVariables
;       Type: Subroutine
;   Category: Start and end
;    Summary: Reset all the RAM (in both the NES and cartridge), initialise all
;             the game's variables, and switch to ROM bank 0
;
; ******************************************************************************

.ResetVariables

 LDA #%00000000         ; Configure the PPU by setting PPU_CTRL as follows:
 STA PPU_CTRL           ;
                        ;   * Bits 0-1    = base nametable address %00 ($2000)
                        ;   * Bit 2 clear = increment PPU_ADDR by 1 each time
                        ;   * Bit 3 clear = sprite pattern table is at $0000
                        ;   * Bit 4 clear = background pattern table is at $0000
                        ;   * Bit 5 clear = sprites are 8x8 pixels
                        ;   * Bit 6 clear = use PPU 0 (the only option on a NES)
                        ;   * Bit 7 clear = disable VBlank NMI generation

 STA ppuCtrlCopy        ; Store the new value of PPU_CTRL in ppuCtrlCopy so we
                        ; can check its value without having to access the PPU

 STA PPU_MASK           ; Configure the PPU by setting PPU_MASK as follows:
                        ;
                        ;   * Bit 0 clear = normal colour (not monochrome)
                        ;   * Bit 1 clear = hide leftmost 8 pixels of background
                        ;   * Bit 2 clear = hide sprites in leftmost 8 pixels
                        ;   * Bit 3 clear = hide background
                        ;   * Bit 4 clear = hide sprites
                        ;   * Bit 5 clear = do not intensify greens
                        ;   * Bit 6 clear = do not intensify blues
                        ;   * Bit 7 clear = do not intensify reds

 STA setupPPUForIconBar ; Clear bit 7 of setupPPUForIconBar so we do nothing
                        ; when the PPU starts drawing the icon bar

 LDA #%01000000         ; ???
 STA JOY2

 INC $C006              ; Reset the MMC1 mapper, which we can do by writing a
                        ; value with bit 7 set into any address in ROM space
                        ; (i.e. any address from $8000 to $FFFF)
                        ;
                        ; The INC instruction does this in a more efficient
                        ; manner than an LDA/STA pair, as it:
                        ;
                        ;   * Fetches the contents of address $C006, which
                        ;     contains the high byte of the JMP destination
                        ;     in the JMP BEGIN instruction, i.e. the high byte
                        ;     of BEGIN, which is $C0
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

 LDA PPU_STATUS         ; Read the PPU_STATUS register, which clear the VBlank
                        ; latch in bit 7, so the following loops will wait for
                        ; three VBlanks in total

.resv1

 LDA PPU_STATUS         ; Wait for the first VBlank to pass, which will set bit
 BPL resv1              ; 7 of PPU_STATUS (and reading PPU_STATUS clears bit 7,
                        ; ready for the next VBlank)

.resv2

 LDA PPU_STATUS         ; Wait for the second VBlank to pass
 BPL resv2

.resv3

 LDA PPU_STATUS         ; Wait for the third VBlank to pass
 BPL resv3

                        ; We now zero the RAM in the NES, as follows:
                        ;
                        ;   * Zero page from $0000 to $00FF
                        ;
                        ;   * The rest of RAM from $0300 to $05FF
                        ;
                        ; This clears all of the NES's built-in RAM except for
                        ; page 1, which is used for the stack

 LDA #0                 ; Set A to zero so we can poke it into memory

 TAX                    ; Set X to 0 to use as an index counter as we loop
                        ; through zero page

.resv4

 STA ZP,X               ; Zero the X-th byte of zero page at ZP

 INX                    ; Increment the byte counter

 BNE resv4              ; Loop back until we have zeroed the whole of zero page
                        ; from $0000 to $00FF

 LDA #$03               ; Set SC(1 0) = $0300
 STA SC+1
 LDA #$00
 STA SC

 TXA                    ; Set A = 0 once again so we can poke it into memory

 LDX #3                 ; We now zero three pages of memory at $0300, $0400 and
                        ; $0500, so set a page counter in X

 TAY                    ; Set Y = 0 to use as an index counter for each page of
                        ; memory

.resv5

 STA (SC),Y             ; Zero the Y-th byte of the page at SC(1 0)

 INY                    ; Increment the byte counter

 BNE resv5              ; Loop back until we have zeroed the whole page of
                        ; memory at SC(1 0)

 INC SC+1               ; Increment the high byte of SC(1 0) so it points at the
                        ; next page of memory

 DEX                    ; Decrement the page counter

 BNE resv5              ; Loop back until we have zeroed three pages of memory
                        ; from $0300 to $05FF

 JSR SetupMMC1          ; Configure the MMC1 mapper and page ROM bank 0 into
                        ; memory at $8000

 JSR ResetMusic         ; ???

 LDA #%10000000         ; Set A = 0 and set the C flag
 ASL A

 JSR ResetScreen_b3     ; Reset the screen by clearing down the PPU, setting
                        ; all colours to black, and resetting the screen-related
                        ; variables

 JSR SetDrawingPlaneTo0 ; Set the drawing bitplane to 0

 JSR ResetBuffers       ; Reset the pattern and nametable buffers

 LDA #00000000          ; Set DTW6 = %00000000 so lower case is not enabled
 STA DTW6

 LDA #%11111111         ; Set DTW2 = %11111111 to denote that we are not
 STA DTW2               ; currently printing a word

 LDA #%11111111         ; Set DTW8 = %11111111 to denote ???
 STA DTW8

; ******************************************************************************
;
;       Name: SetBank0
;       Type: Subroutine
;   Category: Utility routines
;    Summary: Page ROM bank 0 into memory at $8000
;
; ******************************************************************************

.SetBank0

 LDA #0                 ; Page ROM bank 0 into memory at $8000 and return from
 JMP SetBank            ; the subroutine using a tail call

; ******************************************************************************
;
;       Name: SetNonZeroBank
;       Type: Subroutine
;   Category: Utility routines
;    Summary: Page a specified ROM bank into memory at $8000, but only if it is
;             non-zero
;
; ------------------------------------------------------------------------------
;
; Arguments:
;
;   A                   The number of the ROM bank to page into memory at $8000
;
; ******************************************************************************

.SetNonZeroBank

 CMP currentBank        ; If the ROM bank number in A is non-zero, jump to
 BNE SetBank            ; SetBank to page bank A into memory, returning from the
                        ; subroutine using a tail call

 RTS                    ; Otherwise return from the subroutine

; ******************************************************************************
;
;       Name: ResetBank
;       Type: Subroutine
;   Category: Utility routines
;    Summary: Retrieve a ROM bank number from the stack and page that bank into
;             memory at $8000
;
; ------------------------------------------------------------------------------
;
; Arguments:
;
;   Stack               The number of the ROM bank to page into memory at $8000
;
; ******************************************************************************

.ResetBank

 PLA                    ; Retrieve the ROM bank number from the stack into A

                        ; Fall through into SetBank to page ROM bank A into
                        ; memory at $8000

; ******************************************************************************
;
;       Name: SetBank
;       Type: Subroutine
;   Category: Utility routines
;    Summary: Page a specified ROM bank into memory at $8000
;
; ------------------------------------------------------------------------------
;
; Arguments:
;
;   A                   The number of the ROM bank to page into memory at $8000
;
; ******************************************************************************

.SetBank

 DEC runningSetBank     ; Decrement runningSetBank from 0 to $FF to denote that
                        ; we are in the process of switching ROM banks
                        ;
                        ; This will disable the call to PlayMusic in the NMI
                        ; handler, which instead will increment runningSetBank
                        ; each time it is called

 STA currentBank        ; Store the number of the new ROM bank in currentBank

 STA $FFFF              ; Set the MMC1 PRG bank register (which is mapped to
 LSR A                  ; $C000-$DFFF) to the ROM bank number in A, to map the
 STA $FFFF              ; specified ROM bank into memory at $8000
 LSR A                  ;
 STA $FFFF              ; Bit 4 of the ROM bank number will be zero, as A is in
 LSR A                  ; the range 0 to 7, which also ensures that CHR-RAM is
 STA $FFFF              ; enabled
 LSR A
 STA $FFFF

 INC runningSetBank     ; Increment runningSetBank again

 BNE sban1              ; If runningSetBank is non-zero, then this means the NMI
                        ; handler was called while we were switching the ROM
                        ; bank, in which case PlayMusic won't have been called
                        ; in the NMI handler, so jump to sban1 to call the
                        ; PlayMusic routine now instead

 RTS                    ; Return from the subroutine

.sban1

 LDA #0                 ; Set runningSetBank = 0 so the NMI handler knows we are
 STA runningSetBank     ; no longer switching ROM banks

 LDA currentBank        ; Fetch the number of the ROM bank that is currently
 PHA                    ; paged into memory at $8000 and store it on the stack

 TXA                    ; Store X and Y on the stack
 PHA
 TYA
 PHA

 JSR PlayMusic_b6       ; Call the PlayMusic routine to play the background
                        ; music

 PLA                    ; Retrieve X and Y from the stack
 TAY
 PLA
 TAX

 JMP ResetBank          ; Fetch the previous ROM bank number from the stack and
                        ; page that bank back into memory at $8000, returning
                        ; from the subroutine using a tail call

; ******************************************************************************
;
;       Name: xTitleScreen
;       Type: Variable
;   Category: Text
;    Summary: The text column for the title screen's title for each language
;
; ******************************************************************************

.xTitleScreen

 EQUB 6                 ; English

 EQUB 6                 ; German

 EQUB 7                 ; French

 EQUB 7                 ; There is no fourth language, so this byte is ignored

; ******************************************************************************
;
;       Name: xSpaceView
;       Type: Variable
;   Category: Text
;    Summary: The text column for the space view name for each language
;
; ******************************************************************************

.xSpaceView

 EQUB 11                ; English

 EQUB 9                 ; German

 EQUB 13                ; French

 EQUB 10                ; There is no fourth language, so this byte is ignored

IF _NTSC

 EQUB $20, $20, $20     ; These bytes appear to be unused
 EQUB $20, $10, $00
 EQUB $C4, $ED, $5E
 EQUB $E5, $22, $E5
 EQUB $22, $00, $00
 EQUB $ED, $5E, $E5
 EQUB $22, $09, $68
 EQUB $00, $00, $00
 EQUB $00

ELIF _PAL

 EQUB $FF, $FF, $FF     ; These bytes appear to be unused
 EQUB $FF, $FF, $FF
 EQUB $FF, $FF, $FF
 EQUB $FF, $FF, $FF
 EQUB $FF, $FF, $FF
 EQUB $FF, $FF, $FF
 EQUB $FF, $FF, $FF
 EQUB $FF, $FF, $FF
 EQUB $FF

ENDIF

; ******************************************************************************
;
;       Name: log
;       Type: Variable
;   Category: Maths (Arithmetic)
;    Summary: Binary logarithm table (high byte)
;
; ------------------------------------------------------------------------------
;
; At byte n, the table contains the high byte of:
;
;   $2000 * log10(n) / log10(2) = 32 * 256 * log10(n) / log10(2)
;
; where log10 is the logarithm to base 10. The change-of-base formula says that:
;
;   log2(n) = log10(n) / log10(2)
;
; so byte n contains the high byte of:
;
;   32 * log2(n) * 256
;
; ******************************************************************************

.log

IF _MATCH_ORIGINAL_BINARIES

 INCBIN "4-reference-binaries/workspaces/BANK7-log.bin"

ELSE

 SKIP 1

 FOR I%, 1, 255

  B% = INT($2000 * LOG(I%) / LOG(2) + 0.5)

  EQUB B% DIV 256

 NEXT

ENDIF

; ******************************************************************************
;
;       Name: logL
;       Type: Variable
;   Category: Maths (Arithmetic)
;    Summary: Binary logarithm table (low byte)
;
; ------------------------------------------------------------------------------
;
; Byte n contains the low byte of:
;
;   32 * log2(n) * 256
;
; ******************************************************************************

.logL

IF _MATCH_ORIGINAL_BINARIES

 INCBIN "4-reference-binaries/workspaces/BANK7-logL.bin"

ELSE

 SKIP 1

 FOR I%, 1, 255

  B% = INT($2000 * LOG(I%) / LOG(2) + 0.5)

  EQUB B% MOD 256

 NEXT

ENDIF

; ******************************************************************************
;
;       Name: antilog
;       Type: Variable
;   Category: Maths (Arithmetic)
;    Summary: Binary antilogarithm table
;
; ------------------------------------------------------------------------------
;
; At byte n, the table contains:
;
;   2^((n / 2 + 128) / 16) / 256
;
; which equals:
;
;   2^(n / 32 + 8) / 256
;
; ******************************************************************************

.antilog

IF _MATCH_ORIGINAL_BINARIES

 INCBIN "4-reference-binaries/workspaces/BANK7-antilog.bin"

ELSE

 FOR I%, 0, 255

  B% = INT(2^((I% / 2 + 128) / 16) + 0.5) DIV 256

  IF B% = 256
   N% = B%+1
  ELSE
   N% = B%
  ENDIF

  EQUB N%

 NEXT

ENDIF

; ******************************************************************************
;
;       Name: antilogODD
;       Type: Variable
;   Category: Maths (Arithmetic)
;    Summary: Binary antilogarithm table
;
; ------------------------------------------------------------------------------
;
; At byte n, the table contains:
;
;   2^((n / 2 + 128.25) / 16) / 256
;
; which equals:
;
;   2^(n / 32 + 8.015625) / 256 = 2^(n / 32 + 8) * 2^(.015625) / 256
;                               = (2^(n / 32 + 8) + 1) / 256
;
; ******************************************************************************

.antilogODD

IF _MATCH_ORIGINAL_BINARIES

 INCBIN "4-reference-binaries/workspaces/BANK7-antilogODD.bin"

ELSE

 FOR I%, 0, 255

  B% = INT(2^((I% / 2 + 128.25) / 16) + 0.5) DIV 256

  IF B% = 256
   N% = B%+1
  ELSE
   N% = B%
  ENDIF

  EQUB N%

 NEXT

ENDIF

; ******************************************************************************
;
;       Name: SNE
;       Type: Variable
;   Category: Maths (Geometry)
;    Summary: Sine/cosine table
;  Deep dive: The sine, cosine and arctan tables
;             Drawing circles
;             Drawing ellipses
;
; ------------------------------------------------------------------------------
;
; This lookup table contains sine values for the first half of a circle, from 0
; to 180 degrees (0 to PI radians). In terms of circle or ellipse line segments,
; there are 64 segments in a circle, so this contains sine values for segments
; 0 to 31.
;
; In terms of segments, to calculate the sine of the angle at segment x, we look
; up the value in SNE + x, and to calculate the cosine of the angle we look up
; the value in SNE + ((x + 16) mod 32).
;
; In terms of radians, to calculate the following:
;
;   sin(theta) * 256
;
; where theta is in radians, we look up the value in:
;
;   SNE + (theta * 10)
;
; To calculate the following:
;
;   cos(theta) * 256
;
; where theta is in radians, look up the value in:
;
;   SNE + ((theta * 10) + 16) mod 32
;
; Theta must be between 0 and 3.1 radians, so theta * 10 is between 0 and 31.
;
; ******************************************************************************

.SNE

 FOR I%, 0, 31

  N = ABS(SIN((I% / 64) * 2 * PI))

  IF N >= 1
   B% = 255
  ELSE
   B% = INT(256 * N + 0.5)
  ENDIF

  EQUB B%

 NEXT

; ******************************************************************************
;
;       Name: ACT
;       Type: Variable
;   Category: Maths (Geometry)
;    Summary: Arctan table
;  Deep dive: The sine, cosine and arctan tables
;
; ------------------------------------------------------------------------------
;
; This table contains lookup values for arctangent calculations involving angles
; in the range 0 to 45 degrees (or 0 to PI / 4 radians).
;
; To calculate the value of theta in the following:
;
;   theta = arctan(t)
;
; where 0 <= t < 1, we look up the value in:
;
;   ACT + (t * 32)
;
; The result will be an integer representing the angle in radians, where 256
; represents a full circle of 360 degrees (2 * PI radians). The result of the
; lookup will therefore be an integer in the range 0 to 31, as this represents
; 0 to 45 degrees (0 to PI / 4 radians).
;
; The table does not support values of t >= 1 or t < 0 directly, so if we need
; to calculate the arctangent for an angle greater than 45 degrees, we can apply
; the following calculation to the result from the table:
;
;   * For t > 1, arctan(t) = 64 - arctan(1 / t)
;
; For negative values of t where -1 < t < 0, we can apply the following
; calculation to the result from the table:
;
;   * For t < 0, arctan(-t) = 128 - arctan(t)
;
; Finally, if t < -1, we can do the first calculation to get arctan(|t|), and
; the second to get arctan(-|t|).
;
; ******************************************************************************

.ACT

 FOR I%, 0, 31

  EQUB INT((128 / PI) * ATN(I% / 32) + 0.5)

 NEXT

; ******************************************************************************
;
;       Name: XX21
;       Type: Variable
;   Category: Drawing ships
;    Summary: Ship blueprints lookup table
;  Deep dive: Ship blueprints
;
; ******************************************************************************

.XX21

 EQUW SHIP_MISSILE      ; MSL  =  1 = Missile
 EQUW SHIP_CORIOLIS     ; SST  =  2 = Coriolis space station
 EQUW SHIP_ESCAPE_POD   ; ESC  =  3 = Escape pod
 EQUW SHIP_PLATE        ; PLT  =  4 = Alloy plate
 EQUW SHIP_CANISTER     ; OIL  =  5 = Cargo canister
 EQUW SHIP_BOULDER      ;         6 = Boulder
 EQUW SHIP_ASTEROID     ; AST  =  7 = Asteroid
 EQUW SHIP_SPLINTER     ; SPL  =  8 = Splinter
 EQUW SHIP_SHUTTLE      ; SHU  =  9 = Shuttle
 EQUW SHIP_TRANSPORTER  ;        10 = Transporter
 EQUW SHIP_COBRA_MK_3   ; CYL  = 11 = Cobra Mk III
 EQUW SHIP_PYTHON       ;        12 = Python
 EQUW SHIP_BOA          ;        13 = Boa
 EQUW SHIP_ANACONDA     ; ANA  = 14 = Anaconda
 EQUW SHIP_ROCK_HERMIT  ; HER  = 15 = Rock hermit (asteroid)
 EQUW SHIP_VIPER        ; COPS = 16 = Viper
 EQUW SHIP_SIDEWINDER   ; SH3  = 17 = Sidewinder
 EQUW SHIP_MAMBA        ;        18 = Mamba
 EQUW SHIP_KRAIT        ; KRA  = 19 = Krait
 EQUW SHIP_ADDER        ; ADA  = 20 = Adder
 EQUW SHIP_GECKO        ;        21 = Gecko
 EQUW SHIP_COBRA_MK_1   ;        22 = Cobra Mk I
 EQUW SHIP_WORM         ; WRM  = 23 = Worm
 EQUW SHIP_COBRA_MK_3_P ; CYL2 = 24 = Cobra Mk III (pirate)
 EQUW SHIP_ASP_MK_2     ; ASP  = 25 = Asp Mk II
 EQUW SHIP_PYTHON_P     ;        26 = Python (pirate)
 EQUW SHIP_FER_DE_LANCE ;        27 = Fer-de-lance
 EQUW SHIP_MORAY        ;        28 = Moray
 EQUW SHIP_THARGOID     ; THG  = 29 = Thargoid
 EQUW SHIP_THARGON      ; TGL  = 30 = Thargon
 EQUW SHIP_CONSTRICTOR  ; CON  = 31 = Constrictor
 EQUW SHIP_COUGAR       ; COU  = 32 = Cougar
 EQUW SHIP_DODO         ; DOD  = 33 = Dodecahedron ("Dodo") space station

; ******************************************************************************
;
;       Name: SendBarNamesToPPU
;       Type: Subroutine
;   Category: Drawing the screen
;    Summary: Send the nametable entries for the icon bar to the PPU
;
; ------------------------------------------------------------------------------
;
; Nametable data for the icon bar is sent to PPU nametables 0 and 1.
;
; ******************************************************************************

.SendBarNamesToPPU

 SUBTRACT_CYCLES 2131   ; Subtract 2131 from the cycle count

 LDX iconBarOffset      ; Set X to the low byte of iconBarOffset(1 0), to use in
                        ; the following calculations

 STX dataForPPU         ; Set dataForPPU(1 0) = nameBuffer0 + iconBarOffset(1 0)
 LDA iconBarOffset+1    ;
 CLC                    ; So dataForPPU(1 0) points to the entry in nametable
 ADC #HI(nameBuffer0)   ; buffer 0 for the start of the icon bar (the addition
 STA dataForPPU+1       ; works because the low byte of nameBuffer0 is 0)

 LDA iconBarOffset+1    ; Set (A X) = PPU_NAME_0 + iconBarOffset(1 0)
 ADC #HI(PPU_NAME_0)    ;
                        ; The addition works because the low byte of PPU_NAME_0
                        ; is 0

 STA PPU_ADDR           ; Set PPU_ADDR = (A X)
 STX PPU_ADDR           ;              = PPU_NAME_0 + iconBarOffset(1 0)
                        ;
                        ; So PPU_ADDR points to the tile entry in the PPU's
                        ; nametable 0 for the start of the icon bar

 LDY #0                 ; We now send the nametable entries for the icon bar to
                        ; the PPU's nametable 0, so set a counter in Y

.ibar1

 LDA (dataForPPU),Y     ; Send the Y-th nametable entry from dataForPPU(1 0) to
 STA PPU_DATA           ; the PPU

 INY                    ; Increment the loop counter

 CPY #2*32              ; Loop back until we have sent 2 rows of 32 tiles
 BNE ibar1

 LDA iconBarOffset+1    ; Set (A X) = PPU_NAME_1 + iconBarOffset(1 0)
 ADC #HI(PPU_NAME_1-1)  ;
                        ; The addition works because the low byte of PPU_NAME_1
                        ; is 0 and because the C flag is set (as we just passed
                        ; through the BNE above)

 STA PPU_ADDR           ; Set PPU_ADDR = (A X)
 STX PPU_ADDR           ;              = PPU_NAME_1 + iconBarOffset(1 0)
                        ;
                        ; So PPU_ADDR points to the tile entry in the PPU's
                        ; nametable 1 for the start of the icon bar

 LDY #0                 ; We now send the nametable entries for the icon bar to
                        ; the PPU's nametable 1, so set a counter in Y

.ibar2

 LDA (dataForPPU),Y     ; Send the Y-th nametable entry from dataForPPU(1 0) to
 STA PPU_DATA           ; the PPU

 INY                    ; Increment the loop counter

 CPY #2*32              ; Loop back until we have sent 2 rows of 32 tiles
 BNE ibar2

 LDA skipBarPatternsPPU ; If bit 7 of skipBarPatternsPPU is set, we do not send
 BMI ibar3              ; the pattern data to the PPU, so jump to ibar3 to skip
                        ; the following

 JMP SendBarPattsToPPU  ; Bit 7 of skipBarPatternsPPU is clear, we do want to
                        ; send the icon bar's pattern data to the PPU, so jump
                        ; to SendBarPattsToPPU to do just that, returning from
                        ; the subroutine using a tail call

.ibar3

 STA barPatternCounter  ; Set barPatternCounter = 128 so the NMI handler does
                        ; not send any more icon bar data to the PPU

 JMP ConsiderSendTiles  ; Jump to ConsiderSendTiles to start sending tiles to
                        ; the PPU, but only if there are enough free cycles

; ******************************************************************************
;
;       Name: SendBarPatts2ToPPU
;       Type: Subroutine
;   Category: Drawing the screen
;    Summary: Send pattern data for tiles 64-127 for the icon bar to the PPU,
;             split across multiple calls to the NMI handler if required
;
; ------------------------------------------------------------------------------
;
; Pattern data for icon bar patterns 64 to 127 is sent to PPU pattern table 0
; only.
;
; ******************************************************************************

.SendBarPatts2ToPPU

 SUBTRACT_CYCLES 666    ; Subtract 666 from the cycle count

 BMI patt1              ; If the result is negative, jump to patt1 to stop
                        ; sending patterns in this VBlank, as we have run out of
                        ; cycles (we will pick up where we left off in the next
                        ; VBlank)

 JMP patt2              ; The result is positive, so we have enough cycles to
                        ; keep sending PPU data in this VBlank, so jump to patt2
                        ; to send the patterns

.patt1

 ADD_CYCLES 623         ; Add 623 to the cycle count

 JMP RTS1               ; Return from the subroutine (as RTS1 contains an RTS)

.patt2

 LDA #0                 ; Set the low byte of dataForPPU(1 0) to 0
 STA dataForPPU

 LDA barPatternCounter  ; Set Y = (barPatternCounter mod 64) * 8
 ASL A                  ;
 ASL A                  ; And set the C flag to the overflow bit
 ASL A                  ;
 TAY                    ; The mod 64 part comes from the fact that we shift bits
                        ; 7 and 6 left out of A and discard them, so this is the
                        ; same as (barPatternCounter AND %00111111) * 8

 LDA #%00000001         ; Set addr = %0000001C
 ROL A                  ;
 STA addr               ; And clear the C flag (as it gets set to bit 7 of A)
                        ;
                        ; So we now have the following:
                        ;
                        ;   (addr Y) = (2 0) + (barPatternCounter mod 64) * 8
                        ;            = $0200 + (barPatternCounter mod 64) * 8
                        ;            = 64 * 8 + (barPatternCounter mod 64) * 8
                        ;            = (64 + barPatternCounter mod 64) * 8
                        ;
                        ; We only call this routine when this is true:
                        ;
                        ;   64 < barPatternCounter < 128
                        ;
                        ; in which case we know that:
                        ;
                        ;   64 + barPatternCounter mod 64 = barPatternCounter
                        ;
                        ; So we if we substitute this into the above, we get:
                        ;
                        ;   (addr Y) = (10 + 64 + barPatternCounter mod 64) * 8
                        ;            = barPatternCounter * 8

 TYA                    ; Set (A X) = (addr Y) + PPU_PATT_0 + $50
 ADC #$50               ;           = PPU_PATT_0 + $50 + barPatternCounter * 8
 TAX                    ;
                        ; Starting with the low bytes

 LDA addr               ; And then the high bytes (this works because we know
 ADC #HI(PPU_PATT_0)    ; the low byte of PPU_PATT_0 is 0)

 STA PPU_ADDR           ; Set PPU_ADDR = (A X)
 STX PPU_ADDR           ;           = PPU_PATT_0 + $50 + barPatternCounter * 8
                        ;           = PPU_PATT_0 + (10 + barPatternCounter) * 8
                        ;
                        ; So PPU_ADDR points to a pattern in PPU pattern table
                        ; 0, which is at address PPU_PATT_0 in the PPU
                        ;
                        ; So it points to pattern 10 when barPatternCounter = 0,
                        ; and points to patterns 10 to 137 as barPatternCounter
                        ; increments from 0 to 127

 LDA iconBarImageHi     ; Set dataForPPU(1 0) = (iconBarImageHi 0) + (addr 0)
 ADC addr               ;
 STA dataForPPU+1       ; We know from above that:
                        ;
                        ;   (addr Y) = $0200 + (barPatternCounter mod 64) * 8
                        ;            = 64 * 8 + (barPatternCounter mod 64) * 8
                        ;            = (64 + barPatternCounter mod 64) * 8
                        ;            = barPatternCounter * 8
                        ;
                        ; So this means that:
                        ;
                        ;   dataForPPU(1 0) + Y
                        ;           = (iconBarImageHi 0) + (addr 0) + Y
                        ;           = (iconBarImageHi 0) + (addr Y)
                        ;           = (iconBarImageHi 0) + barPatternCounter * 8
                        ;
                        ; We know that (iconBarImageHi 0) points to the current
                        ; icon bar's image data  aticonBarImage0, iconBarImage1,
                        ; iconBarImage2, iconBarImage3 or iconBarImage4
                        ;
                        ; So dataForPPU(1 0) + Y points to the pattern within
                        ; the icon bar's image data that corresponds to pattern
                        ; number barPatternCounter, so this is the data that we
                        ; want to send to the PPU

 LDX #32                ; We now send 32 bytes to the PPU, which equates to four
                        ; tile patterns (as each tile pattern contains eight
                        ; bytes)
                        ;
                        ; We send 32 pattern bytes, starting from the Y-th byte
                        ; of dataForPPU(1 0), which corresponds to pattern
                        ; number barPatternCounter in dataForPPU(1 0)

.patt3

 LDA (dataForPPU),Y     ; Send the Y-th byte from dataForPPU(1 0) to the PPU
 STA PPU_DATA

 INY                    ; Increment the index in Y to point to the next byte
                        ; from dataForPPU(1 0)

 DEX                    ; Decrement the loop counter

 BEQ patt4              ; If the loop counter is now zero, jump to patt4 to exit
                        ; the loop

 JMP patt3              ; Loop back to send the next byte

.patt4

 LDA barPatternCounter  ; Add 4 to barPatternCounter, as we just sent four tile
 CLC                    ; patterns
 ADC #4
 STA barPatternCounter

 BPL SendBarPatts2ToPPU ; If barPatternCounter < 128, loop back to the start of
                        ; the routine to send another four pattern tiles

 JMP ConsiderSendTiles  ; Jump to ConsiderSendTiles to start sending tiles to
                        ; the PPU, but only if there are enough free cycles

; ******************************************************************************
;
;       Name: SendBarPattsToPPU
;       Type: Subroutine
;   Category: Drawing the screen
;    Summary: Send pattern data for tiles 0-127 for the icon bar to the PPU,
;             split across multiple calls to the NMI handler if required
;
; ------------------------------------------------------------------------------
;
; Pattern data for icon bar patterns 0 to 63 is sent to both pattern table 0 and
; 1 in the PPU, while pattern data for icon bar patterns 64 to 127 is sent to
; pattern table 0 only (the latter is done via the SendBarPatts2ToPPU routine).
;
; Arguments:
;
;   A                   A counter for the icon bar tile patterns to send to the
;                       PPU, which works its way from 0 to 128 as pattern data
;                       is sent to the PPU over successive calls to the NMI
;                       handler
;
; ******************************************************************************

.SendBarPattsToPPU

 ASL A                  ; If bit 6 of A is set, then 64 < A < 128, so jump to
 BMI SendBarPatts2ToPPU ; SendBarPatts2ToPPU to send patterns 64 to 127 to
                        ; pattern table 0 in the PPU

                        ; If we get here then both bit 6 and bit 7 of A are
                        ; clear, so 0 < A < 64, so we now send patterns 0 to 63
                        ; to pattern table 0 and 1 in the PPU

 SUBTRACT_CYCLES 1297   ; Subtract 1297 from the cycle count

 BMI patn1              ; If the result is negative, jump to patn1 to stop
                        ; sending patterns in this VBlank, as we have run out of
                        ; cycles (we will pick up where we left off in the next
                        ; VBlank)

 JMP patn2              ; The result is positive, so we have enough cycles to
                        ; keep sending PPU data in this VBlank, so jump to patn2
                        ; to send the patterns

.patn1

 ADD_CYCLES 1251        ; Add 1251 to the cycle count

 JMP RTS1               ; Return from the subroutine (as RTS1 contains an RTS)

.patn2

 LDA #0                 ; Set the low byte of dataForPPU(1 0) to 0
 STA dataForPPU

 LDA barPatternCounter  ; Set Y = barPatternCounter * 8
 ASL A                  ;
 ASL A                  ; And set the C flag to the overflow bit
 ASL A                  ;
 TAY                    ; Note that in the above we shift bits 7 and 6 left out
                        ; out of A and discard them, but because we know that
                        ; 0 < barPatternCounter < 64, this has no effect

 LDA #%00000000         ; Set addr = %0000000C
 ROL A                  ;
 STA addr               ; And clear the C flag (as it gets set to bit 7 of A)
                        ;
                        ; So we now have the following:
                        ;
                        ;   (addr Y) = barPatternCounter * 8

 TYA                    ; Set (A X) = (addr Y) + PPU_PATT_0 + $50
 ADC #$50               ;           = PPU_PATT_0 + $50 + barPatternCounter * 8
 TAX                    ;
                        ; Starting with the low bytes

 LDA addr               ; And then the high bytes (this works because we know
 ADC #HI(PPU_PATT_0)    ; the low byte of PPU_PATT_0 is 0)

 STA PPU_ADDR           ; Set PPU_ADDR = (A X)
 STX PPU_ADDR           ;           = PPU_PATT_0 + $50 + barPatternCounter * 8
                        ;           = PPU_PATT_0 + (10 + barPatternCounter) * 8
                        ;
                        ; So PPU_ADDR points to a pattern in PPU pattern table
                        ; 0, which is at address PPU_PATT_0 in the PPU
                        ;
                        ; So it points to pattern 10 when barPatternCounter = 0,
                        ; and points to patterns 10 to 137 as barPatternCounter
                        ; increments from 0 to 127

 LDA iconBarImageHi     ; Set dataForPPU(1 0) = (iconBarImageHi 0) + (addr 0)
 ADC addr               ;
 STA dataForPPU+1       ; This means that:
                        ;
                        ;   dataForPPU(1 0) + Y
                        ;           = (iconBarImageHi 0) + (addr 0) + Y
                        ;           = (iconBarImageHi 0) + (addr Y)
                        ;           = (iconBarImageHi 0) + barPatternCounter * 8
                        ;
                        ; We know that (iconBarImageHi 0) points to the current
                        ; icon bar's image data  aticonBarImage0, iconBarImage1,
                        ; iconBarImage2, iconBarImage3 or iconBarImage4
                        ;
                        ; So dataForPPU(1 0) + Y points to the pattern within
                        ; the icon bar's image data that corresponds to pattern
                        ; number barPatternCounter, so this is the data that we
                        ; want to send to the PPU

 LDX #32                ; We now send 32 bytes to the PPU, which equates to four
                        ; tile patterns (as each tile pattern contains eight
                        ; bytes)
                        ;
                        ; We send 32 pattern bytes, starting from the Y-th byte
                        ; of dataForPPU(1 0), which corresponds to pattern
                        ; number barPatternCounter in dataForPPU(1 0)

.patn3

 LDA (dataForPPU),Y     ; Send the Y-th byte from dataForPPU(1 0) to the PPU
 STA PPU_DATA

 INY                    ; Increment the index in Y to point to the next byte
                        ; from dataForPPU(1 0)

 DEX                    ; Decrement the loop counter

 BEQ patn4              ; If the loop counter is now zero, jump to patn4 to exit
                        ; the loop

 JMP patn3              ; Loop back to send the next byte

.patn4

 LDA #0                 ; Set the low byte of dataForPPU(1 0) to 0
 STA dataForPPU

 LDA barPatternCounter  ; Set Y = barPatternCounter * 8
 ASL A                  ;
 ASL A                  ; And set the C flag to the overflow bit
 ASL A                  ;
 TAY                    ; Note that in the above we shift bits 7 and 6 left out
                        ; out of A and discard them, but because we know that
                        ; 0 < barPatternCounter < 64, this has no effect

 LDA #%00000000         ; Set addr = %0000000C
 ROL A                  ;
 STA addr               ; And clear the C flag (as it gets set to bit 7 of A)
                        ;
                        ; So we now have the following:
                        ;
                        ;   (addr Y) = barPatternCounter * 8

 TYA                    ; Set (A X) = (addr Y) + PPU_PATT_1 + $50
 ADC #$50               ;           = PPU_PATT_1 + $50 + barPatternCounter * 8
 TAX                    ;
                        ; Starting with the low bytes

 LDA addr               ; And then the high bytes (this works because we know
 ADC #HI(PPU_PATT_1)    ; the low byte of PPU_PATT_1 is 0)

 STA PPU_ADDR           ; Set PPU_ADDR = (A X)
 STX PPU_ADDR           ;           = PPU_PATT_1 + $50 + barPatternCounter * 8
                        ;           = PPU_PATT_1 + (10 + barPatternCounter) * 8
                        ;
                        ; So PPU_ADDR points to a pattern in PPU pattern table
                        ; 1, which is at address PPU_PATT_1 in the PPU
                        ;
                        ; So it points to pattern 10 when barPatternCounter = 0,
                        ; and points to patterns 10 to 137 as barPatternCounter
                        ; increments from 0 to 127

 LDA iconBarImageHi     ; Set dataForPPU(1 0) = (iconBarImageHi 0) + (addr 0)
 ADC addr               ;
 STA dataForPPU+1       ; This means that:
                        ;
                        ;   dataForPPU(1 0) + Y
                        ;           = (iconBarImageHi 0) + (addr 0) + Y
                        ;           = (iconBarImageHi 0) + (addr Y)
                        ;           = (iconBarImageHi 0) + barPatternCounter * 8
                        ;
                        ; We know that (iconBarImageHi 0) points to the current
                        ; icon bar's image data  aticonBarImage0, iconBarImage1,
                        ; iconBarImage2, iconBarImage3 or iconBarImage4
                        ;
                        ; So dataForPPU(1 0) + Y points to the pattern within
                        ; the icon bar's image data that corresponds to pattern
                        ; number barPatternCounter, so this is the data that we
                        ; want to send to the PPU

 LDX #32                ; We now send 32 bytes to the PPU, which equates to four
                        ; tile patterns (as each tile pattern contains eight
                        ; bytes)
                        ;
                        ; We send 32 pattern bytes, starting from the Y-th byte
                        ; of dataForPPU(1 0), which corresponds to pattern
                        ; number barPatternCounter in dataForPPU(1 0)

.patn5

 LDA (dataForPPU),Y     ; Send the Y-th byte from dataForPPU(1 0) to the PPU
 STA PPU_DATA

 INY                    ; Increment the index in Y to point to the next byte
                        ; from dataForPPU(1 0)

 DEX                    ; Decrement the loop counter

 BEQ patn6              ; If the loop counter is now zero, jump to patn6 to exit
                        ; the loop

 JMP patn5              ; Loop back to send the next byte

.patn6

 LDA barPatternCounter  ; Add 4 to barPatternCounter, as we just sent four tile
 CLC                    ; patterns
 ADC #4
 STA barPatternCounter

 JMP SendBarPattsToPPU  ; Loop back to the start of the routine to send another
                        ; four pattern tiles to both PPU pattern tables

; ******************************************************************************
;
;       Name: SendBarPattsToPPUS
;       Type: Subroutine
;   Category: Drawing the screen
;    Summary: Send the tile pattern data for the icon bar to the PPU (this is a
;             jump so we can call this routine using a branch instruction)
;
; ******************************************************************************

.SendBarPattsToPPUS

 JMP SendBarPattsToPPU  ; Jump to SendBarPattsToPPU to send the tile pattern
                        ; data for the icon bar to the PPU, returning from the
                        ; subroutine using a tail call

; ******************************************************************************
;
;       Name: SendBarNamesToPPUS
;       Type: Subroutine
;   Category: Drawing the screen
;    Summary: Send the nametable entries for the icon bar to the PPU (this is a
;             jump so we can call this routine using a branch instruction)
;
; ******************************************************************************

.SendBarNamesToPPUS

 JMP SendBarNamesToPPU  ; Jump to SendBarNamesToPPU to send the nametable
                        ; entries for the icon bar to the PPU, returning from
                        ; the subroutine using a tail call

; ******************************************************************************
;
;       Name: ConsiderSendTiles
;       Type: Subroutine
;   Category: Drawing the screen
;    Summary: If there are enough free cycles, move on to the next stage of
;             sending tile patterns to the PPU
;
; ------------------------------------------------------------------------------
;
; Other entry points:
;
;   RTS1                Contains an RTS
;
; ******************************************************************************

.ConsiderSendTiles

 LDX nmiBitplane        ; Set X to the current NMI bitplane (i.e. the bitplane
                        ; for which we are sending data to the PPU in the NMI
                        ; handler)

 LDA bitplaneFlags,X    ; Set A to the bitplane flags for the NMI bitplane

 AND #%00010000         ; If bit 4 of A is clear, then we are not currently in
 BEQ RTS1               ; the process of sending tile data to the PPU for this
                        ; bitplane, so return from the subroutine (as RTS1
                        ; contains an RTS)

 SUBTRACT_CYCLES 42     ; Subtract 42 from the cycle count

 BMI next1              ; If the result is negative, jump to next1 to stop
                        ; sending patterns in this VBlank, as we have run out of
                        ; cycles (we will pick up where we left off in the next
                        ; VBlank)

 JMP next2              ; The result is positive, so we have enough cycles to
                        ; keep sending PPU data in this VBlank, so jump to
                        ; SendPatternsToPPU via next2 to move on to the next
                        ; stage of sending tile patterns to the PPU

.next1

 ADD_CYCLES 65521       ; Add 65521 to the cycle count (i.e. subtract 15) ???

 JMP RTS1               ; Return from the subroutine (as RTS1 contains an RTS)

.next2

 JMP SendPatternsToPPU  ; Jump to SendPatternsToPPU to move on to the next stage
                        ; of sending tile patterns to the PPU

.RTS1

 RTS                    ; Return from the subroutine

; ******************************************************************************
;
;       Name: SendBuffersToPPU (Part 1 of 3)
;       Type: Subroutine
;   Category: Drawing the screen
;    Summary: Send the icon bar nametable and palette data to the PPU, if it has
;             changed, before moving on to tile data in part 2
;
; ******************************************************************************

.SendBuffersToPPU

 LDA barPatternCounter  ; If barPatternCounter = 0, then we need to send the
 BEQ SendBarNamesToPPUS ; nametable entries for the icon bar to the PPU, so
                        ; jump to SendBarNamesToPPU via SendBarNamesToPPUS,
                        ; returning from the subroutine using a tail call

 BPL SendBarPattsToPPUS ; If 0 < barPatternCounter < 128, then we need to send
                        ; the pattern data for the icon bar to the PPU, so
                        ; jump to SendBarPattsToPPU via SendBarPattsToPPUS,
                        ; returning from the subroutine using a tail call

                        ; If we get here then barPatternCounter >= 128, so we
                        ; do not need to send any icon bar data to the PPU

                        ; Fall through into part 2 to look at sending tile data
                        ; to the PPU for the rest of the screen

; ******************************************************************************
;
;       Name: SendBuffersToPPU (Part 2 of 3)
;       Type: Subroutine
;   Category: Drawing the screen
;    Summary: If we are already sending tile data to the PPU, pick up where we
;             left off, otherwise jump to part 3 to check for new data to send
;
; ******************************************************************************

 LDX nmiBitplane        ; Set X to the current NMI bitplane (i.e. the bitplane
                        ; for which we are sending data to the PPU in the NMI
                        ; handler)

 LDA bitplaneFlags,X    ; Set A to the bitplane flags for the NMI bitplane

 AND #%00010000         ; If bit 4 of A is clear, then we are not currently in
 BEQ sbuf7              ; the process of sending tile data to the PPU for this
                        ; bitplane, so jump to sbuf7 in part 3 to start sending
                        ; tile data

                        ; If we get here then we are already in the process of
                        ; sending tile data to the PPU, split across multiple
                        ; calls to the NMI handler, so before we can consider
                        ; sending data data for anything else, we need to finish
                        ; the job that we already started

 SUBTRACT_CYCLES 56     ; Subtract 56 from the cycle count

 TXA                    ; Set Y to the inverse of X, so Y is the opposite
 EOR #1                 ; bitplane to the NMI bitplane
 TAY

 LDA bitplaneFlags,Y    ; Set A to the bitplane flags for the opposite plane
                        ; to the NMI bitplane

 AND #%10100000         ; If bitplanes are enabled then enableBitplanes = 1, so
 ORA enableBitplanes    ; this jumps to sbuf2 if any of the following are true
 CMP #%10000001         ; for the opposite bitplane:
 BNE sbuf2              ;
                        ;   * Bitplanes are disabled
                        ;
                        ;   * Bit 5 is set (we have already sent all the data
                        ;     to the PPU for the opposite bitplane)
                        ;
                        ;   * Bit 7 is clear (do not send data to the PPU for
                        ;     the opposite bitplane)
                        ;
                        ; If any of these are true, we jump to SendPatternsToPPU
                        ; via sbuf2 to continue sending tiles to the PPU for the
                        ; current bitplane

                        ; If we get here then the following are true:
                        ;
                        ;   * Bitplanes are enabled
                        ;
                        ;   * We have not sent all the data for the opposite
                        ;     bitplane to the PPU
                        ;
                        ;   * The opposite bitplane is configured to be sent to
                        ;     the PPU

 LDA nextTileNumber,X   ; Set A to the next free tile number for this bitplane

 BNE sbuf1              ; If it it zero (i.e. we have no free tiles), then set
 LDA #255               ; A to 255, so we can use A as an upper limit

.sbuf1

 CMP sendingPattTile,X  ; If A >= sendingPattTile, then the number of the last
 BEQ sbuf3              ; free tile is bigger than the number of the tile for
 BCS sbuf3              ; which we are currently sending pattern data to the PPU
                        ; for this bitplane, which means there is still some
                        ; pattern data to send before we have processed all the
                        ; tiles, so jump to sbuf3
                        ;
                        ; Ths BEQ appears to be superfluous here as BCS will
                        ; catch an equality

                        ; If we get here then we have finished sending pattern
                        ; data to the PPU, so we now move on to the next stage
                        ; by jumping to SendPatternsToPPU after adjusting the
                        ; cycle count

 SUBTRACT_CYCLES 32     ; Subtract 32 from the cycle count

.sbuf2

 JMP SendPatternsToPPU  ; Jump to SendPatternsToPPU to continue sending tile
                        ; data to the PPU

.sbuf3

                        ; If we get here then the following are true:
                        ;
                        ;   * Bitplanes are enabled
                        ;
                        ;   * We have not sent all the data for the opposite
                        ;     bitplane to the PPU
                        ;
                        ;   * The opposite bitplane is configured to be sent to
                        ;     the PPU
                        ;
                        ;   * We are in the process of sending data for the
                        ;     current bitplane to the PPU
                        ;
                        ;   * We still have pattern data to send to the PPU for
                        ;     this bitplane

 LDA bitplaneFlags,X    ; Set A to the bitplane flags for the NMI bitplane

 ASL A                  ; Shift A left by one place, so bit 7 becomes bit 6 of
                        ; the original flags, and so on

 BPL RTS1               ; If bit 6 of the bitplane flags is clear, then this
                        ; bitplane is only configured to send pattern data and
                        ; not nametable data, and to stop sending the pattern
                        ; data if the other bitplane is ready to be sent
                        ;
                        ; This is is the case here as we only jump to sbuf3 if
                        ; the other bitplane is configured to send data to the
                        ; PPU, so we stop sending the pattern data for this
                        ; bitplane by returning from the subroutine (as RTS1
                        ; contains an RTS)

 LDY lastTileNumber,X   ; Set Y to the number of the last tile we need to send
                        ; for this bitplane, divided by 8

 AND #%00001000         ; If bit 2 of the bitplane flags is set (as A was
 BEQ sbuf4              ; shifted left above), set Y = 128 to override the last
 LDY #128               ; tile number with 128, which means send all tiles (as
                        ; 128 * 8 = 1024 and 1024 is the buffer size)

.sbuf4

 TYA                    ; Set A = Y - sendingNameTile
 SEC                    ;       = lastTileNumber - sendingNameTile
 SBC sendingNameTile,X  ;
                        ; So this is the number of tiles for which we still have
                        ; to send nametable entries, as sendingNameTile is the
                        ; number of the tile for which we are currently sending
                        ; nametable entries to the PPU, divided by 8

 CMP #48                ; If A < 48, then we have fewer than 48 * 8 = 384
 BCC sbuf6              ; nametable entries to send, so jump to sbuf6 to swap
                        ; the hidden and visible bitplanes before sending the
                        ; next batch of tiles ???

 SUBTRACT_CYCLES 60     ; Subtract 60 from the cycle count

.sbuf5

 JMP SendPatternsToPPU  ; Jump to SendPatternsToPPU to continue sending tile
                        ; data to the PPU

.sbuf6

 LDA ppuCtrlCopy        ; If ppuCtrlCopy is zero then we are not worried about
 BEQ sbuf5              ; keeping PPU writes within VBlank, so jump to sbuf5 to
                        ; skip the following bitplane flip and crack on with
                        ; sending data to the PPU

 SUBTRACT_CYCLES 134    ; Subtract 134 from the cycle count

 LDA enableBitplanes    ; If bitplanes are enabled then enableBitplanes will be
 EOR hiddenBitPlane     ; 1, so this flips hiddenBitPlane between 0 and 1 when
 STA hiddenBitPlane     ; bitplanes are enabled, and does nothing when they
                        ; aren't (so it effectively swaps the hidden and visible
                        ; bitplanes)

 JSR SetPaletteForView  ; Set the correct background and sprite palettes for
                        ; the current view and (if this is the space view) the
                        ; hidden bit plane

 JMP SendPatternsToPPU  ; Jump to SendPatternsToPPU to continue sending tile
                        ; data to the PPU

; ******************************************************************************
;
;       Name: SendBuffersToPPU (Part 3 of 3)
;       Type: Subroutine
;   Category: Drawing the screen
;    Summary: If we need to send tile nametable and pattern data to the PPU for
;             either bitplane, start doing just that
;
; ******************************************************************************

.sbuf7

                        ; If we get here then we are not currently sending tile
                        ; data to the PPU, so now we check which bitplane is
                        ; configured to be sent, configure the NMI handler to
                        ; send data for that bitplane to the PPU (over multiple
                        ; calls to the NMI handler, if required), and we also
                        ; hide the bitplane we are updating from the screen, so
                        ; we don't corrupt the screen while updating it

 SUBTRACT_CYCLES 298    ; Subtract 298 from the cycle count

 LDA bitplaneFlags      ; Set A to the bitplane flags for bitplane 0

 AND #%10100000         ; This jumps to sbuf8 if any of the following are true
 CMP #%10000000         ; for bitplane 0:
 BNE sbuf8              ;
                        ;   * Bit 5 is set (we have already sent all the data
                        ;     to the PPU for bitplane 0)
                        ;
                        ;   * Bit 7 is clear (do not send data to the PPU for
                        ;     bitplane 0)
                        ;
                        ; If any of these are true, we jump to sbuf8 to consider
                        ; sending bitplane 1 instead

                        ; If we get here then we have not already send all the
                        ; data to the PPU for bitplane 0, and bitplane 0 is
                        ; configured to be sent, so we start sending data for
                        ; bitplane 0 to the PPU

 NOP                    ; This looks like code that has been removed
 NOP
 NOP
 NOP
 NOP

 LDX #0                 ; Set X = 0 and jump to sbuf11 to start sending tile
 JMP sbuf11             ; data to the PPU for bitplane 0

.sbuf8

 LDA bitplaneFlags+1    ; Set A to the bitplane flags for bitplane 1

 AND #%10100000         ; This jumps to sbuf10 if both of the following are true
 CMP #%10000000         ; for bitplane 1:
 BEQ sbuf10             ;
                        ;   * Bit 5 is clear (we have not already sent all the
                        ;     data to the PPU for bitplane 1)
                        ;
                        ;   * Bit 7 is set (send data to the PPU for bitplane 1)
                        ;
                        ; If both of these are true then jump to sbuf10 to start
                        ; sending data for bitplane 1 to the PPU

                        ; If we get here then we don't need to send either
                        ; bitplane to the PPU, so we update the cycle count and
                        ; return from the subroutine

 ADD_CYCLES_CLC 223     ; Add 223 to the cycle count

 RTS                    ; Return from the subroutine

.sbuf9

 ADD_CYCLES_CLC 45      ; Add 45 to the cycle count

 JMP SetupTilesForPPU   ; Jump to SetupTilesForPPU to set up the variables for
                        ; sending tile data to the PPU

.sbuf10

 LDX #1                 ; Set X = 1 so we start sending tile data to the PPU
                        ; for bitplane 1

.sbuf11

                        ; If we get here then we are about to start sending tile
                        ; data to the PPU for bitplane X, so we set nmiBitplane
                        ; to X (so the NMI handler sends data to the PPU for
                        ; that bitplane), and we also set hiddenBitPlane to X,
                        ; so that the bitplane we are updating is hidden from
                        ; view (and the other bitplane is shown on-screen)
                        ;
                        ; So this is the part of the code that swaps animation
                        ; frames when drawing the space view

 STX nmiBitplane        ; Set the NMI bitplane to the value in X, which will
                        ; be 0 or 1 depending on the value of the bitplane flags
                        ; we tested above

 LDA enableBitplanes    ; If enableBitplanes = 0 then bitplanes are not enabled
 BEQ sbuf9              ; (we must be on the Start screen), so jump to sbuf9 to
                        ; update the cycle count and skip the following two
                        ; instructions

 STX hiddenBitPlane     ; Set the hidden bitplane to be the same as the NMI
                        ; bitplane, so the rest of the NMI handler update the
                        ; hidden bitplane (we only want to update the hidden
                        ; bitplane, to avoid messing up the screen)

 JSR SetPaletteForView  ; Set the correct background and sprite palettes for
                        ; the current view and (if this is the space view) the
                        ; hidden bitplane

                        ; Fall through into SetupTilesForPPU to set up the
                        ; variables for sending tile data to the PPU

; ******************************************************************************
;
;       Name: SetupTilesForPPU
;       Type: Subroutine
;   Category: Drawing the screen
;    Summary: Set up the variables needed to send the tile nametable and pattern
;             data to the PPU
;
; ------------------------------------------------------------------------------
;
; Arguments:
;
;   X                   The current value of nmiBitplane
;
; ******************************************************************************

.SetupTilesForPPU

 TXA                    ; Set nmiBitplane8 = X << 3
 ASL A                  ;                  = nmiBitplane * 8
 ASL A                  ;
 ASL A                  ; So nmiBitplane has the following values:
 STA nmiBitplane8       ;
                        ;   * 0 when nmiBitplane is 0
                        ;
                        ;   * 8 when nmiBitplane is 1

 LSR A                  ; Set A = nmiBitplane << 2
                        ;
                        ; So A has the following values:
                        ;
                        ;   * 0 when nmiBitplane is 0
                        ;
                        ;   * 4 when nmiBitplane is 1

 ORA #HI(PPU_NAME_0)    ; Set the high byte of ppuNametableAddr(1 0) to
 STA ppuNametableAddr+1 ; HI(PPU_NAME_0) + A, which will be:
                        ;
                        ;   * HI(PPU_NAME_0)         when nmiBitplane is 0
                        ;
                        ;   * HI(PPU_NAME_0) + $04   when nmiBitplane is 1

 LDA #HI(PPU_PATT_1)    ; Set ppuPatternTableHi to point to the high byte of
 STA ppuPatternTableHi  ; pattern table 1 in the PPU

 LDA #0                 ; Zero the low byte of ppuNametableAddr(1 0), so we end
 STA ppuNametableAddr   ; up with ppuNametableAddr(1 0) set to:
                        ;
                        ;   * PPU_NAME_0 ($2000)     when nmiBitplane = 0
                        ;
                        ;   * PPU_NAME_1 ($2400)     when nmiBitplane = 1
                        ;
                        ; So ppuNametableAddr(1 0) points to the correct PPU
                        ; nametable address for this bitplane

 LDA firstNametableTile ; Set sendingNameTile for this bitplane to the value of
 STA sendingNameTile,X  ; firstNametableTile, which contains the number of the
                        ; first tile to send to the PPU nametable

 STA clearingNameTile,X ; Set clearingNameTile for this bitplane to the same
                        ; value, so we start to clear tiles from the same point
                        ; once they have been sent to the PPU nametable

 LDA firstPatternTile   ; Set sendingPattTile for this bitplane to the value of
 STA sendingPattTile,X  ; firstPatternTile, which contains the number of the
                        ; first tile to send to the PPU pattern table

 STA clearingPattTile,X ; Set clearingPattTile for this bitplane to the same
                        ; value, so we start to clear tiles from the same point
                        ; once they have been sent to the PPU pattern table

 LDA bitplaneFlags,X    ; Set bit 4 in the bitplane flags to indicate that we
 ORA #%00010000         ; are now sending tile data to the PPU in the NMI
 STA bitplaneFlags,X    ; handler (so we can detect this in the next VBlank if
                        ; we have to split the process across multiple VBlanks)

 LDA #0                 ; Set (addr A) to sendingPattTile for this bitplane,
 STA addr               ; which we just set to the number of the first tile to
 LDA sendingPattTile,X  ; send to the PPU pattern table

 ASL A                  ; Set (addr A) = (pattBufferHiAddr 0) + (addr A) * 8
 ROL addr               ;              = pattBufferX + sendingPattTile * 8
 ASL A                  ;
 ROL addr               ; Starting with the low bytes
 ASL A                  ;
                        ; In the above, pattBufferX is either pattBuffer0 or
                        ; pattBuffer1, depending on the bitplane in X, as these
                        ; are the values stored in the pattBufferHiAddr variable

 STA pattTileBuffLo,X   ; Store the low byte in pattTileBuffLo for this bitplane

 LDA addr               ; We now add the high bytes, storing the result in
 ROL A                  ; pattTileBuffHi for this bitplane
 ADC pattBufferHiAddr,X ;
 STA pattTileBuffHi,X   ; So we now have the following for this bitplane:
                        ;
                        ;   (pattTileBuffHi pattTileBuffLo) =
                        ;                      pattBufferX + sendingPattTile * 8
                        ;
                        ; which points to the data for tile sendingPattTile in
                        ; the pattern buffer for bitplane X

 LDA #0                 ; Set (addr A) to sendingNameTile for this bitplane,
 STA addr               ; which we just set to the number of the first tile to
 LDA sendingNameTile,X  ; send to the PPU nametable

 ASL A                  ; Set (addr A) = (nameBufferHiAddr 0) + (addr A) * 8
 ROL addr               ;              = nameBufferX + sendingNameTile * 8
 ASL A                  ;
 ROL addr               ; Starting with the low bytes
 ASL A                  ;
                        ; In the above, pattBufferX is either pattBuffer0 or
                        ; pattBuffer1, depending on the bitplane in X, as these
                        ; are the values stored in the pattBufferHiAddr variable

 STA nameTileBuffLo,X   ; Store the low byte in nameTileBuffLo for this bitplane

 ROL addr               ; We now add the high bytes, storing the result in
 LDA addr               ; nameTileBuffHi for this bitplane
 ADC nameBufferHiAddr,X ;
 STA nameTileBuffHi,X   ; So we now have the following for this bitplane:
                        ;
                        ;   (nameTileBuffHi nameTileBuffLo) =
                        ;                      nameBufferX + sendingNameTile * 8
                        ;
                        ; which points to the data for tile sendingNameTile in
                        ; the nametable buffer for bitplane X

 LDA ppuNametableAddr+1 ; Set the high byte of the following calculation:
 SEC                    ;
 SBC nameBufferHiAddr,X ;   (ppuToBuffNameHi 0) = (ppuNametableAddr+1 0)
 STA ppuToBuffNameHi,X  ;                          - (nameBufferHiAddr 0)
                        ;
                        ; So ppuToBuffNameHi for this bitplane contains a high
                        ; byte that we can add to a nametable buffer address to
                        ; get the corresponding address in the PPU nametable

 JMP SendPatternsToPPU  ; Now that we have set up all the variables needed, we
                        ; can jump to SendPatternsToPPU to move on to the next
                        ; stage of sending tile patterns to the PPU

; ******************************************************************************
;
;       Name: SendPatternsToPPU (Part 1 of 6)
;       Type: Subroutine
;   Category: Drawing the screen
;    Summary: Calculate how many tile patterns we need to send and jump to the
;             most efficient routine for sending them
;
; ******************************************************************************

.spat1

 ADD_CYCLES_CLC 4       ; Add 4 to the cycle count

 JMP SendNametableNow   ; Jump to SendNametableNow to start sending nametable
                        ; entries to the PPU immediately

.spat2

 JMP spat21             ; Jump down to part 4 to start sending pattern data
                        ; until we run out of cycles

.SendPatternsToPPU

 SUBTRACT_CYCLES 182    ; Subtract 182 from the cycle count

 BMI spat3              ; If the result is negative, jump to spat3 to stop
                        ; sending PPU data in this VBlank, as we have run out of
                        ; cycles (we will pick up where we left off in the next
                        ; VBlank)

 JMP spat4              ; The result is positive, so we have enough cycles to
                        ; keep sending PPU data in this VBlank, so jump to spat4
                        ; to start sending tile pattern data to the PPU

.spat3

 ADD_CYCLES 141         ; Add 141 to the cycle count

 JMP RTS1               ; Return from the subroutine (as RTS1 contains an RTS)

.spat4

 LDA nextTileNumber,X   ; Set A to the next free tile number for the current
                        ; bitplane, which is effectively the number of the first
                        ; unused tile as we have stopped drawing into new tiles
                        ; at this point

 BNE spat5              ; If it it zero (i.e. we have no free tiles), then set
 LDA #255               ; A to 255, so we can use A as an upper limit

.spat5

 STA lastTile           ; Store the result in lastTile, as we want to stop
                        ; sending tiles once we have reached the unused tiles

 LDA ppuNametableAddr+1 ; Set the high byte of the following calculation:
 SEC                    ;
 SBC nameBufferHiAddr,X ;   (ppuToBuffNameHi 0) = (ppuNametableAddr+1 0)
 STA ppuToBuffNameHi,X  ;                          - (nameBufferHiAddr 0)
                        ;
                        ; So ppuToBuffNameHi for this bitplane contains a high
                        ; byte that we can add to a PPU nametable addredd to get
                        ; the corresponding address in the nametable buffer

 LDY pattTileBuffLo,X   ; Set Y to the low byte of the address of the pattern
                        ; buffer for sendingPattTile in bitplane X (i.e. the
                        ; address of the next tile we want to send)
                        ;
                        ; We can use this as an index when copying data from
                        ; the pattern buffer, as we know the pattern buffers
                        ; start on page boundaries, so the low byte of the
                        ; address of the the start of each buffer is zero

 LDA pattTileBuffHi,X   ; Set the high byte of dataForPPU(1 0) to the high byte
 STA dataForPPU+1       ; of the pattern buffer for this bitplane, as we want
                        ; to copy data from the pattern buffer to the PPU

 LDA sendingPattTile,X  ; Set A to the number of the next tile we want to send
                        ; from the pattern buffer for this bitplane

 STA pattTileCounter    ; Store the number in pattTileCounter, so we can keep
                        ; track of which tile we are sending

 SEC                    ; Set A = A - lastTile
 SBC lastTile           ;       = pattTileCounter - lastTile

 BCS spat1              ; If pattTileCounter >= lastTile then we have already
                        ; sent all the tile patterns (right up to the last
                        ; tile), so jump to spat1 to move on to sending the
                        ; nametable entries

 LDX ppuCtrlCopy        ; If ppuCtrlCopy is zero then we are not worried about
 BEQ spat6              ; keeping PPU writes within VBlank, so jump to spat6 to
                        ; skip the following and crack on with sending as much
                        ; pattern data as we can to the PPU

                        ; The above subtraction underflowed, as it cleared the C
                        ; flag, so the result in A is a negative number and we
                        ; should interpret $BF in the following as a signed
                        ; integer, -65

 CMP #$BF               ; If A < $BF
 BCC spat2              ;
                        ; i.e. pattTileCounter - lastTile < -65
                        ;      lastTile - pattTileCounter > 65
                        ;
                        ; Then we have 65 or more patterns to sent to the PPU,
                        ; so jump to part 4 (via spat2) to send them until we
                        ; run out of cycles, without bothering to check for the
                        ; last tile (as we have more tiles to send than we can
                        ; fit into one VBlank)
                        ;
                        ; Otherwise we have 64 or fewer tile patterns to send,
                        ; so fall through into part 2 to send them one tile at a
                        ; time, checking each one is the last tile yo see if
                        ; it's the last tile

; ******************************************************************************
;
;       Name: SendPatternsToPPU (Part 2 of 6)
;       Type: Subroutine
;   Category: Drawing the screen
;    Summary: Configure variables for sending data to the PPU one tile at a time
;             with checks
;
; ******************************************************************************

.spat6

 LDA pattTileCounter    ; Set (addr A) = pattTileCounter
 LDX #0
 STX addr

 STX dataForPPU         ; Zero the low byte of dataForPPU(1 0)
                        ;
                        ; We set the high byte in part 1, so dataForPPU(1 0) now
                        ; contains the address of the pattern buffer for this
                        ; bitplane

 ASL A                  ; Set (addr X) = (addr A) << 4
 ROL addr               ;              = pattTileCounter * 16
 ASL A
 ROL addr
 ASL A
 ROL addr
 ASL A
 TAX

 LDA addr               ; Set (A X) = (ppuPatternTableHi 0) + (addr X)
 ROL A                  ;         = (ppuPatternTableHi 0) + pattTileCounter * 16
 ADC ppuPatternTableHi  ;
                        ; ppuPatternTableHi contains the high byte of the
                        ; address of the PPU pattern table to which we send
                        ; dynamic tile patterns; it contains HI(PPU_PATT_1),
                        ; so (A X) now contains the address in PPU pattern
                        ; table 1 for tile number pattTileCounter (as there are
                        ; 16 bytes in the pattern table for each tile)

                        ; We now set both PPU_ADDR and addr(1 0) to the
                        ; following:
                        ;
                        ;   * (A X)         when nmiBitplane is 0
                        ;
                        ;   * (A X) + 8     when nmiBitplane is 1
                        ;
                        ; We add 8 in the second example to point the address to
                        ; bitplane 1, as the PPU interleaves each tile pattern
                        ; as 8 bytes of one bitplane followed by 8 bytes of the
                        ; other bitplane, so bitplane 1's data always appears 8
                        ; bytes after the corresponding bitplane 0 data

 STA PPU_ADDR           ; Set the high byte of PPU_ADDR to A

 STA addr+1             ; Set the high byte of addr to A

 TXA                    ; Set A = X + nmiBitplane8
 ADC nmiBitplane8       ;       = X + nmiBitplane * 8
                        ;
                        ; So we add 8 to the low byte when we are writing to
                        ; bit plane 1, otherwise we leave the low byte alone

 STA PPU_ADDR           ; Set the low byte of PPU_ADDR to A

 STA addr               ; Set the high byte of addr to A

                        ; So PPU_ADDR and addr(1 0) both contain the PPU
                        ; address to which we should send our pattern data for
                        ; this bitplane

 JMP spat9              ; Jump into part 3 to send pattern data to the PPU

; ******************************************************************************
;
;       Name: SendPatternsToPPU (Part 3 of 6)
;       Type: Subroutine
;   Category: Drawing the screen
;    Summary: Send pattern data to the PPU for one tile at a time, checking
;             after each one to see if is the last tile
;
; ******************************************************************************

.spat7

 INC dataForPPU+1       ; Increment the high byte of dataForPPU(1 0) to point to
                        ; the start of the next page in memory

 SUBTRACT_CYCLES 27     ; Subtract 27 from the cycle count

 JMP spat13             ; Jump down to spat13 to continue sending data to the
                        ; PPU

.spat8

 JMP spat17             ; Jump down to spat17 to move on to sending nametable
                        ; entries to the PPU

.spat9

                        ; This is the entry point for part 3

 LDX pattTileCounter    ; We will now work our way through tiles, sending data
                        ; each one, so set a counter in X that starts with the
                        ; number of the next tile to send to the PPU

.spat10

 SUBTRACT_CYCLES 400    ; Subtract 400 from the cycle count

 BMI spat11             ; If the result is negative, jump to spat11 to stop
                        ; sending PPU data in this VBlank, as we have run out of
                        ; cycles (we will pick up where we left off in the next
                        ; VBlank)

 JMP spat12             ; The result is positive, so we have enough cycles to
                        ; keep sending PPU data in this VBlank, so jump to
                        ; spat12 to send pattern data to the PPU

.spat11

 ADD_CYCLES 359         ; Add 359 to the cycle count

 JMP spat30             ; Jump to part 6 to save progress for use in the next
                        ; VBlank and return from the subroutine

.spat12

                        ; If we get here then we send pattern data to the PPU

 SEND_DATA_TO_PPU 8     ; Send 8 bytes from dataForPPU to the PPU, starting at
                        ; index Y and updating Y to point to the byte after the
                        ; block that is sent

 BEQ spat7              ; If Y = 0 then the next byte is in the next page in
                        ; memory, so jump to spat7 to point dataForPPU(1 0) at
                        ; the start of this next page, before returning here

.spat13

 LDA addr               ; Set the following:
 CLC                    ;
 ADC #16                ;   PPU_ADDR = addr(1 0) + 16
 STA addr               ;
 LDA addr+1             ;   addr(1 0) = addr(1 0) + 16
 ADC #0                 ;
 STA addr+1             ; So PPU_ADDR and addr(1 0) both point to the next
 STA PPU_ADDR           ; tile's pattern in the PPU for this bitplane, as each
 LDA addr               ; tile has 16 bytes of pattern data (8 in each bitplane)
 STA PPU_ADDR

 INX                    ; Increment the tile number in X

 CPX lastTile           ; If we have reached the last tile, jump to spat19 (via
 BCS spat8              ; spat8 and spat17) to move on to sending the nametable
                        ; entries

 SEND_DATA_TO_PPU 8     ; Send 8 bytes from dataForPPU to the PPU, starting at
                        ; index Y and updating Y to point to the byte after the
                        ; block that is sent

 BEQ spat16             ; If Y = 0 then the next byte is in the next page in
                        ; memory, so jump to spat16 to point dataForPPU(1 0) at
                        ; the start of this next page, before returning here
                        ; with the C flag clear, ready for the next addition

.spat14

 LDA addr               ; Set the following:
 ADC #16                ;
 STA addr               ;   PPU_ADDR = addr(1 0) + 16
 LDA addr+1             ;
 ADC #0                 ;   addr(1 0) = addr(1 0) + 16
 STA addr+1             ;
 STA PPU_ADDR           ; The addition works because the C flag is clear, either
 LDA addr               ; because we passed through the BCS above, or because we
 STA PPU_ADDR           ; jumped to spat16 and back
                        ;
                        ; So PPU_ADDR and addr(1 0) both point to the next
                        ; tile's pattern in the PPU for this bitplane, as each
                        ; tile has 16 bytes of pattern data (8 in each bitplane)

 INX                    ; Increment the tile number in X

 CPX lastTile           ; If we have reached the last tile, jump to spat19 (via
 BCS spat18             ; spat18) to move on to sending the nametable entries

 SEND_DATA_TO_PPU 8     ; Send 8 bytes from dataForPPU to the PPU, starting at
                        ; index Y and updating Y to point to the byte after the
                        ; block that is sent

 BEQ spat20             ; If Y = 0 then the next byte is in the next page in
                        ; memory, so jump to spat20 to point dataForPPU(1 0) at
                        ; the start of this next page, before returning here
                        ; with the C flag clear, ready for the next addition

.spat15

 LDA addr               ; Set the following:
 ADC #16                ;
 STA addr               ;   PPU_ADDR = addr(1 0) + 16
 LDA addr+1             ;
 ADC #0                 ;   addr(1 0) = addr(1 0) + 16
 STA addr+1             ;
 STA PPU_ADDR           ; The addition works because the C flag is clear, either
 LDA addr               ; because we passed through the BCS above, or because we
 STA PPU_ADDR           ; jumped to spat20 and back
                        ;
                        ; So PPU_ADDR and addr(1 0) both point to the next
                        ; tile's pattern in the PPU for this bitplane, as each
                        ; tile has 16 bytes of pattern data (8 in each bitplane)

 INX                    ; Increment the tile number in X

 CPX lastTile           ; If we have reached the last tile, jump to spat19 to
 BCS spat19             ; move on to sending the nametable entries

 JMP spat10             ; Otherwise we still have patterns to send, so jump back
                        ; to spat10 to check the cycle count and potentially
                        ; send the next batch

.spat16

 INC dataForPPU+1       ; Increment the high byte of dataForPPU(1 0) to point to
                        ; the start of the next page in memory

 SUBTRACT_CYCLES 29     ; Subtract 29 from the cycle count

 CLC                    ; Clear the C flag so the addition works at spat14

 JMP spat14             ; Jump up to spat14 to continue sending data to the PPU

.spat17

 ADD_CYCLES_CLC 224     ; Add 224 to the cycle count

 JMP spat19             ; Jump to spat19 to move on to sending nametable entries
                        ; to the PPU

.spat18

 ADD_CYCLES_CLC 109     ; Add 109 to the cycle count

.spat19

                        ; If we get here then we have sent the last tile's
                        ; pattern data, so we now move on to sending the
                        ; nametable entries to the PPU
                        ;
                        ; Before jumping to SendNametableToPPU, we need to store
                        ; the following variables, so they can be picked up by
                        ; the new routine:
                        ;
                        ;   * (pattTileBuffHi pattTileBuffLo)
                        ;
                        ;   * sendingPattTile
                        ;
                        ; Incidentally, these are the same variables that we
                        ; save when storing progress for the next VBlank, which
                        ; makes sense

 STX pattTileCounter    ; Store X in pattTileCounter to use below

 NOP                    ; This looks like code that has been removed

 LDX nmiBitplane        ; Set (pattTileBuffHi pattTileBuffLo) for this bitplane
 STY pattTileBuffLo,X   ; to dataForPPU(1 0) + Y (which is the address of the
 LDA dataForPPU+1       ; next byte of data to be sent from the pattern buffer)
 STA pattTileBuffHi,X

 LDA pattTileCounter    ; Set sendingPattTile for this bitplane to the value of
 STA sendingPattTile,X  ; X we stored above (which is the number / 8 of the next
                        ; tile to be sent from the pattern buffer)

 JMP SendNametableToPPU ; Jump to SendNametableToPPU to start sending the tile
                        ; nametable to the PPU

.spat20

 INC dataForPPU+1       ; Increment the high byte of dataForPPU(1 0) to point to
                        ; the start of the next page in memory

 SUBTRACT_CYCLES 29     ; Subtract 29 from the cycle count

 CLC                    ; Clear the C flag so the addition works at spat15

 JMP spat15             ; Jump up to spat14 to continue sending data to the PPU

; ******************************************************************************
;
;       Name: SendPatternsToPPU (Part 4 of 6)
;       Type: Subroutine
;   Category: Drawing the screen
;    Summary: Configure variables for sending data to the PPU until we run out
;             of cycles
;
; ******************************************************************************

.spat21

 LDA pattTileCounter    ; Set (addr A) = pattTileCounter
 LDX #0
 STX addr

 STX dataForPPU         ; Zero the low byte of dataForPPU(1 0)
                        ;
                        ; We set the high byte in part 1, so dataForPPU(1 0) now
                        ; contains the address of the pattern buffer for this
                        ; bitplane

 ASL A                  ; Set (addr X) = (addr A) << 4
 ROL addr               ;              = pattTileCounter * 16
 ASL A
 ROL addr
 ASL A
 ROL addr
 ASL A
 TAX

 LDA addr               ; Set (A X) = (ppuPatternTableHi 0) + (addr X)
 ROL A                  ;         = (ppuPatternTableHi 0) + pattTileCounter * 16
 ADC ppuPatternTableHi  ;
                        ; ppuPatternTableHi contains the high byte of the
                        ; address of the PPU pattern table to which we send
                        ; dynamic tile patterns; it contains HI(PPU_PATT_1),
                        ; so (A X) now contains the address in PPU pattern
                        ; table 1 for tile number pattTileCounter (as there are
                        ; 16 bytes in the pattern table for each tile)

                        ; We now set both PPU_ADDR and addr(1 0) to the
                        ; following:
                        ;
                        ;   * (A X)         when nmiBitplane is 0
                        ;
                        ;   * (A X) + 8     when nmiBitplane is 1
                        ;
                        ; We add 8 in the second example to point the address to
                        ; bitplane 1, as the PPU interleaves each tile pattern
                        ; as 8 bytes of one bitplane followed by 8 bytes of the
                        ; other bitplane, so bitplane 1's data always appears 8
                        ; bytes after the corresponding bitplane 0 data

 STA PPU_ADDR           ; Set the high byte of PPU_ADDR to A

 STA addr+1             ; Set the high byte of addr to A

 TXA                    ; Set A = X + nmiBitplane8
 ADC nmiBitplane8       ;       = X + nmiBitplane * 8
                        ;
                        ; So we add 8 to the low byte when we are writing to
                        ; bit plane 1, otherwise we leave the low byte alone

 STA PPU_ADDR           ; Set the low byte of PPU_ADDR to A

 STA addr               ; Set the high byte of addr to A

                        ; So PPU_ADDR and addr(1 0) both contain the PPU
                        ; address to which we should send our pattern data for
                        ; this bitplane

 JMP spat23             ; Jump into part 5 to send pattern data to the PPU

; ******************************************************************************
;
;       Name: SendPatternsToPPU (Part 5 of 6)
;       Type: Subroutine
;   Category: Drawing the screen
;    Summary: Send pattern data to the PPU for two tiles at a time, until we run
;             out of cycles (and without checking for the last tile)
;
; ******************************************************************************

.spat22

 INC dataForPPU+1       ; Increment the high byte of dataForPPU(1 0) to point to
                        ; the start of the next page in memory

 SUBTRACT_CYCLES 27     ; Subtract 27 from the cycle count

 JMP spat27             ; Jump down to spat27 to continue sending data to the
                        ; PPU

.spat23

                        ; This is the entry point for part 5

 LDX pattTileCounter    ; We will now work our way through tiles, sending data
                        ; each one, so set a counter in X that starts with the
                        ; number of the next tile to send to the PPU

.spat24

 SUBTRACT_CYCLES 266    ; Subtract 266 from the cycle count

 BMI spat25             ; If the result is negative, jump to spat25 to stop
                        ; sending PPU data in this VBlank, as we have run out of
                        ; cycles (we will pick up where we left off in the next
                        ; VBlank)

 JMP spat26             ; The result is positive, so we have enough cycles to
                        ; keep sending PPU data in this VBlank, so jump to
                        ; spat26 to send pattern data to the PPU

.spat25

 ADD_CYCLES 225         ; Add 225 to the cycle count

 JMP spat30             ; Jump to part 6 to save progress for use in the next
                        ; VBlank and return from the subroutine

.spat26

                        ; If we get here then we send pattern data to the PPU

 SEND_DATA_TO_PPU 8     ; Send 8 bytes from dataForPPU to the PPU, starting at
                        ; index Y and updating Y to point to the byte after the
                        ; block that is sent

 BEQ spat22             ; If Y = 0 then the next byte is in the next page in
                        ; memory, so jump to spat22 to point dataForPPU(1 0) at
                        ; the start of this next page, before returning here

.spat27

 LDA addr               ; Set the following:
 CLC                    ;
 ADC #16                ;   PPU_ADDR = addr(1 0) + 16
 STA addr               ;
 LDA addr+1             ;   addr(1 0) = addr(1 0) + 16
 ADC #0                 ;
 STA addr+1             ; So PPU_ADDR and addr(1 0) both point to the next
 STA PPU_ADDR           ; tile's pattern in the PPU for this bitplane, as each
 LDA addr               ; tile has 16 bytes of pattern data (8 in each bitplane)
 STA PPU_ADDR

 SEND_DATA_TO_PPU 8     ; Send 8 bytes from dataForPPU to the PPU, starting at
                        ; index Y and updating Y to point to the byte after the
                        ; block that is sent

 BEQ spat29             ; If Y = 0 then the next byte is in the next page in
                        ; memory, so jump to spat29 to point dataForPPU(1 0) at
                        ; the start of this next page, before returning here
                        ; with the C flag clear, ready for the next addition

.spat28

 LDA addr               ; Set the following:
 ADC #16                ;
 STA addr               ;   PPU_ADDR = addr(1 0) + 16
 LDA addr+1             ;
 ADC #0                 ;   addr(1 0) = addr(1 0) + 16
 STA addr+1             ;
 STA PPU_ADDR           ; The addition works because the C flag is clear, either
 LDA addr               ; because we passed through the BCS above, or because we
 STA PPU_ADDR           ; jumped to spat29 and back
                        ;
                        ; So PPU_ADDR and addr(1 0) both point to the next
                        ; tile's pattern in the PPU for this bitplane, as each
                        ; tile has 16 bytes of pattern data (8 in each bitplane)

 INX                    ; Increment the tile number in X twice, as we just sent
 INX                    ; data for two tiles

 JMP spat24             ; Loop back to spat24 to check the cycle count and
                        ; potentially send the next batch

.spat29

 INC dataForPPU+1       ; Increment the high byte of dataForPPU(1 0) to point to
                        ; the start of the next page in memory

 SUBTRACT_CYCLES 29     ; Subtract 29 from the cycle count

 CLC                    ; Clear the C flag so the addition works at spat15

 JMP spat28             ; Jump up to spat28 to continue sending data to the PPU

; ******************************************************************************
;
;       Name: SendPatternsToPPU (Part 6 of 6)
;       Type: Subroutine
;   Category: Drawing the screen
;    Summary: Save progress for use in the next VBlank and return from the
;             subroutine
;
; ******************************************************************************

.spat30

                        ; We now store the following variables, so they can be
                        ; picked up when we return in the next VBlank:
                        ;
                        ;   * (pattTileBuffHi pattTileBuffLo)
                        ;
                        ;   * sendingPattTile

 STX pattTileCounter    ; Store X in pattTileCounter to use below

 LDX nmiBitplane        ; Set (pattTileBuffHi pattTileBuffLo) for this bitplane
 STY pattTileBuffLo,X   ; to dataForPPU(1 0) + Y (which is the address of the
 LDA dataForPPU+1       ; next byte of data to be sent from the pattern buffer
 STA pattTileBuffHi,X   ; in the next VBlank)

 LDA pattTileCounter    ; Set sendingPattTile for this bitplane to the value of
 STA sendingPattTile,X  ; X we stored above (which is the number / 8 of the next
                        ; tile to be sent from the pattern buffer in the next
                        ; VBlank)

 JMP RTS1               ; Return from the subroutine (as RTS1 contains an RTS)

; ******************************************************************************
;
;       Name: SendOtherBitplane
;       Type: Subroutine
;   Category: Drawing the screen
;    Summary: Check whether we should send another bitplane to the PPU
;
; ******************************************************************************

.SendOtherBitplane

 LDX nmiBitplane        ; Set X to the current NMI bitplane (i.e. the bitplane
                        ; for which we have been sending data to the PPU)

 LDA #%00100000         ; Set the NMI bitplane flags as follows:
 STA bitplaneFlags,X    ;
                        ;   * Bit 2 clear = last tile to send is lastTileNumber
                        ;   * Bit 3 clear = don't clear buffers after sending
                        ;   * Bit 4 clear = we've not started sending data yet
                        ;   * Bit 5 set   = we have already sent all the data
                        ;   * Bit 6 clear = only send pattern data to the PPU
                        ;   * Bit 7 clear = do not send data to the PPU
                        ;
                        ; Bits 0 and 1 are ignored and are always clear
                        ;
                        ; So this indicates that we have finished sending data
                        ; to the PPU for this bitplane

 SUBTRACT_CYCLES 227    ; Subtract 227 from the cycle count

 BMI obit1              ; If the result is negative, jump to obit1 to stop
                        ; sending PPU data in this VBlank, as we have run out of
                        ; cycles (we will pick up where we left off in the next
                        ; VBlank)

 JMP obit2              ; The result is positive, so we have enough cycles to
                        ; keep sending PPU data in this VBlank, so jump to obit2
                        ; to check whether we should send this bitplane to the
                        ; PPU

.obit1

 ADD_CYCLES 176         ; Add 176 to the cycle count

 JMP RTS1               ; Return from the subroutine (as RTS1 contains an RTS)

.obit2

 TXA                    ; Flip the NMI bitplane between 0 and 1, to it's the
 EOR #1                 ; opposite bitplane to the one we just sent
 STA nmiBitplane

 CMP hiddenBitPlane     ; If the NMI bitplane is now different to the hidden
 BNE obit4              ; bitplane, jump to obit4 to update the cycle count
                        ; and return from the subroutine, as we already sent
                        ; the bitplane that's hidden (we only want to update
                        ; the hidden bitplane, to avoid messing up the screen)

                        ; If we get here then the new NMI bitplane is the same
                        ; as the bitplane that's hidden, so we should send it
                        ; to the PPU (this might happen if the value of
                        ; hiddenBitPlane changes while we are still sending
                        ; data to the PPU across multiple calls to the NMI
                        ; handler) ???

 TAX                    ; Set X to the newly flipped NMI bitplane

 LDA bitplaneFlags,X    ; Set A to the bitplane flags for the newly flipped NMI
                        ; bitplane

 AND #%10100000         ; This jumps to obit3 if both of the following are true
 CMP #%10000000         ; for bitplane 1:
 BEQ obit3              ;
                        ;   * Bit 5 is clear (we have not already sent all the
                        ;     data to the PPU for the bitplane)
                        ;
                        ;   * Bit 7 is set (send data to the PPU for the
                        ;     bitplane)
                        ;
                        ; If both of these are true then jump to obit3 to update
                        ; the cycle count and return from the subroutine without
                        ; sending any more tile data to the PPU in this VBlank

                        ; If we get here then the new bitplane is not configured
                        ; to be sent to the PPU, so we send it now ???

 JMP SetupTilesForPPU   ; Jump to SetupTilesForPPU to set up the variables for
                        ; sending tile data to the PPU

.obit3

 ADD_CYCLES_CLC 151     ; Add 151 to the cycle count

 RTS                    ; Return from the subroutine

.obit4

 ADD_CYCLES_CLC 163     ; Add 163 to the cycle count

 RTS                    ; Return from the subroutine

; ******************************************************************************
;
;       Name: SendNametableToPPU
;       Type: Subroutine
;   Category: Drawing the screen
;    Summary: Send the tile nametable to the PPU if there are enough cycles left
;             in the current VBlank
;
; ------------------------------------------------------------------------------
;
; Other entry points:
;
;   SendNametableNow    Send the nametable without checking the cycle count
;
; ******************************************************************************

.snam1

 ADD_CYCLES_CLC 58      ; Add 58 to the cycle count

 JMP RTS1               ; Return from the subroutine (as RTS1 contains an RTS)

.snam2

 ADD_CYCLES_CLC 53      ; Add 53 to the cycle count

 JMP SendOtherBitplane  ; Jump to SendOtherBitplane to consider sending the
                        ; other bitplane to the PPU, if required

.SendNametableToPPU

 SUBTRACT_CYCLES 109    ; Subtract 109 from the cycle count

 BMI snam3              ; If the result is negative, jump to snam3 to stop
                        ; sending PPU data in this VBlank, as we have run out of
                        ; cycles (we will pick up where we left off in the next
                        ; VBlank)

 JMP SendNametableNow   ; The result is positive, so we have enough cycles to
                        ; keep sending PPU data in this VBlank, so jump to
                        ; SendNametableNow to start sending nametable data to
                        ; the PPU

.snam3

 ADD_CYCLES 68          ; Add 68 to the cycle count

 JMP RTS1               ; Return from the subroutine (as RTS1 contains an RTS)

.SendNametableNow

 LDX nmiBitplane        ; Set X to the current NMI bitplane (i.e. the bitplane
                        ; for which we are sending data to the PPU in the NMI
                        ; handler)

 LDA bitplaneFlags,X    ; Set A to the bitplane flags for the NMI bitplane

 ASL A                  ; Shift A left by one place, so bit 7 becomes bit 6 of
                        ; the original flags, and so on

 BPL snam1              ; If bit 6 of the bitplane flags is clear, then this
                        ; bitplane is only configured to send pattern data and
                        ; not nametable data, so jump to snam1 to return from
                        ; the subroutine

 LDY lastTileNumber,X   ; Set Y to the number of the last tile we need to send
                        ; for this bitplane, divided by 8

 AND #%00001000         ; If bit 2 of the bitplane flags is set (as A was
 BEQ snam4              ; shifted left above), set Y = 128 to override the last
 LDY #128               ; tile number with 128, which means send all tiles (as
                        ; 128 * 8 = 1024 and 1024 is the buffer size)

.snam4

 STY lastTile           ; Store Y in lastTile, as we want to stop sending
                        ; nametable entries when we reach this tile

 LDA sendingNameTile,X  ; Set A to the number of the next tile we want to send
                        ; from the nametable buffer for this bitplane, divided
                        ; by 8 (we divide by 8 because there are 1024 entries in
                        ; each nametable, which doesn't fit into one byte, so we
                        ; divide by 8 so the maximum counter value is 128)

 STA nameTileCounter    ; Store the number in nameTileCounter, so we can keep
                        ; track of which tile we are sending (so nameTileCounter
                        ; contains the current tile number, divided by 8)

 SEC                    ; Set A = A - lastTile
 SBC lastTile           ;       = nameTileCounter - lastTile

 BCS snam2              ; If nameTileCounter >= lastTile then we have already
                        ; sent all the nametable entries (right up to the last
                        ; tile), so jump to snam2 to consider sending the other
                        ; bitplane

 LDY nameTileBuffLo,X   ; Set Y to the low byte of the address of the nametable
                        ; buffer for sendingNameTile in bitplane X (i.e. the
                        ; address of the next tile we want to send)
                        ;
                        ; We can use this as an index when copying data from
                        ; the nametable buffer, as we know the nametable buffers
                        ; start on page boundaries, so the low byte of the
                        ; address of the the start of each buffer is zero

 LDA nameTileBuffHi,X   ; Set the high byte of dataForPPU(1 0) to the high byte
 STA dataForPPU+1       ; of the nametable buffer for this bitplane, as we want
                        ; to copy data from the nametable buffer to the PPU

 CLC                    ; Set the high byte of the following calculation:
 ADC ppuToBuffNameHi,X  ;
                        ;   (A 0) = (nameTileBuffHi 0) + (ppuToBuffNameHi 0)
                        ;
                        ; (ppuToBuffNameHi 0) for this bitplane contains a high
                        ; byte that we can add to a nametable buffer address to
                        ; get the corresponding address in the PPU nametable, so
                        ; this sets (A 0) to the high byte of the correct PPU
                        ; nametable address for this tile
                        ;
                        ; We already set Y as the low byte above, so we now have
                        ; the full PPU address in (A Y)

 STA PPU_ADDR           ; Set PPU_ADDR = (A Y)
 STY PPU_ADDR           ;
                        ; So PPU_ADDR points to the address in the PPU to which
                        ; we send the nametable data

 LDA #0                 ; Set the low byte of dataForPPU(1 0) to 0, so that
 STA dataForPPU         ; dataForPPU(1 0) points to the start of the nametable
                        ; buffer, and dataForPPU(1 0) + Y therefore points to
                        ; the nametable entry for tile sendingNameTile

.snam5

 SUBTRACT_CYCLES 393    ; Subtract 393 from the cycle count

 BMI snam6              ; If the result is negative, jump to snam6 to stop
                        ; sending PPU data in this VBlank, as we have run out of
                        ; cycles (we will pick up where we left off in the next
                        ; VBlank)

                        ; If we get here then the result is positive, so the C
                        ; flag will be set as the subtraction didn't underflow

 JMP snam7              ; The result is positive, so we have enough cycles to
                        ; keep sending PPU data in this VBlank, so jump to snam7
                        ; to do just that

.snam6

 ADD_CYCLES 349         ; Add 349 to the cycle count

 JMP snam10             ; Jump to snam10 to save progress for use in the next
                        ; VBlank and return from the subroutine

.snam7

 SEND_DATA_TO_PPU 32    ; Send 32 bytes from dataForPPU to the PPU, starting at
                        ; index Y and updating Y to point to the byte after the
                        ; block that is sent

 BEQ snam9              ; If Y = 0 then the next byte is in the next page in
                        ; memory, so jump to snam9 to point dataForPPU(1 0) at
                        ; the start of this next page, before looping back to
                        ; snam5 to potentially send the next batch

                        ; We got here by jumping to snam7 from above, which we
                        ; did with the C flag set, so the ADC #3 below actually
                        ; adds 4

 LDA nameTileCounter    ; Add 4 to nameTileCounter, as we just sent 4 * 8 = 32
 ADC #3                 ; nametable entries (and nameTileCounter counts the tile
 STA nameTileCounter    ; number, divided by 8)

 CMP lastTile           ; If nameTileCounter >= lastTile then we have reached
 BCS snam8              ; the last tile, so jump to snam8 to update the
                        ; variables and jump to SendOtherBitplane to consider
                        ; sending the other bitplane

 JMP snam5              ; Otherwise we still have nametable entries to send, so
                        ; loop back to snam5 to check the cycles and send the
                        ; next batch

.snam8

                        ; If we get here then we have sent the last nametable
                        ; entry, so we now move on to considering whether to
                        ; send the other bitplane to the PPU, if required
                        ;
                        ; Before jumping to SendOtherBitplane, we need to store
                        ; the following variables, so they can be picked up by
                        ; the new routine:
                        ;
                        ;   * (nameTileBuffHi nameTileBuffLo)
                        ;
                        ;   * sendingNameTile
                        ;
                        ; Incidentally, these are the same variables that we
                        ; save when storing progress for the next VBlank, which
                        ; makes sense

 STA sendingNameTile,X  ; Set sendingNameTile for this bitplane to the value of
                        ; nameTileCounter, which we stored in A before jumping
                        ; here

 STY nameTileBuffLo,X   ; Set (nameTileBuffHi nameTileBuffLo) for this bitplane
 LDA dataForPPU+1       ; to dataForPPU(1 0) + Y (which is the address of the
 STA nameTileBuffHi,X   ; next byte of data to be sent from the nametable
                        ; buffer)

 JMP SendOtherBitplane  ; Jump to SendOtherBitplane to consider sending the
                        ; other bitplane to the PPU, if required

.snam9

 INC dataForPPU+1       ; Increment the high byte of dataForPPU(1 0) to point to
                        ; the start of the next page in memory

 SUBTRACT_CYCLES 26     ; Subtract 26 from the cycle count

 LDA nameTileCounter    ; Add 4 to nameTileCounter, as we just sent 4 * 8 = 32
 CLC                    ; nametable entries (and nameTileCounter counts the tile
 ADC #4                 ; number, divided by 8)
 STA nameTileCounter

 CMP lastTile           ; If nameTileCounter >= lastTile then we have reached
 BCS snam8              ; the last tile, so jump to snam8 to update the
                        ; variables and jump to SendOtherBitplane to consider
                        ; sending the other bitplane

 JMP snam5              ; Otherwise we still have nametable entries to send, so
                        ; loop back to snam5 to check the cycles and send the
                        ; next batch

.snam10

                        ; We now store the following variables, so they can be
                        ; picked up when we return in the next VBlank:
                        ;
                        ;   * (nameTileBuffHi nameTileBuffLo)
                        ;
                        ;   * sendingNameTile

 LDA nameTileCounter    ; Set sendingNameTile for this bitplane to the number
 STA sendingNameTile,X  ; of the tile to send next, in nameTileCounter

 STY nameTileBuffLo,X   ; Set (nameTileBuffHi nameTileBuffLo) for this bitplane
 LDA dataForPPU+1       ; to dataForPPU(1 0) + Y (which is the address of the
 STA nameTileBuffHi,X   ; next byte of data to be sent from the nametable
                        ; buffer)

 JMP RTS1               ; Return from the subroutine (as RTS1 contains an RTS)

; ******************************************************************************
;
;       Name: CopyNameBuffer0To1
;       Type: Subroutine
;   Category: Drawing the screen
;    Summary: Copy the contents of nametable buffer 0 to nametable buffer 1
;             and set the next free tile number for both bitplanes
;
; ******************************************************************************

.CopyNameBuffer0To1

 LDY #0                 ; Set Y = 0 so we can use it as an index starting at 0,
                        ; and then counting down from 255 to 0

 LDX #16                ; The following loop also updates a counter in X that
                        ; counts down from 16 to 1 and back to 16 again, but it
                        ; isn't used anywhere, so presumably this is left over
                        ; from some functionality that was later removed

.copy1

 LDA nameBuffer0,Y      ; Copy the Y-th byte of nametable buffer 0 to nametable
 STA nameBuffer1,Y      ; buffer 1, so this copies the first 256 bytes as Y
                        ; counts down

 LDA nameBuffer0+256,Y  ; Copy byte 256, and bytes 511 to 255 into nametable
 STA nameBuffer1+256,Y  ; buffer 1 as Y counts down

 LDA nameBuffer0+512,Y  ; Copy byte 512, and bytes 767 to 511 into nametable
 STA nameBuffer1+512,Y  ; buffer 1 as Y counts down

 LDA nameBuffer0+768,Y  ; Copy byte 768, and bytes 1023 to 769 into nametable
 STA nameBuffer1+768,Y  ; buffer 1 as Y counts down

 JSR SetupPPUForIconBar ; If the PPU has started drawing the icon bar, configure
                        ; the PPU to use nametable 0 and pattern table 0

 DEX                    ; Decrement the counter in X, wrapping it back up to 16
 BNE copy2              ; when it reaches 0
 LDX #16

.copy2

 DEY                    ; Decrement the index counter in Y

 BNE copy1              ; Loop back to copy1 to copy the next four bytes, until
                        ; we have copied the whole buffer

 LDA tileNumber         ; Set the next free tile number for both bitplanes to
 STA nextTileNumber     ; the current value of tileNumber ???
 STA nextTileNumber+1

 RTS                    ; Return from the subroutine

; ******************************************************************************
;
;       Name: DrawBoxTop
;       Type: Subroutine
;   Category: Drawing the screen
;    Summary: Draw the top edge of the box along the top of the screen in
;             nametable buffer 0
;
; ******************************************************************************

.DrawBoxTop

 LDY #1                 ; Set Y as an index into the nametable, as we want to
                        ; draw the top bar from column 1 to 31

 LDA #3                 ; Set A = 3 as the tile number to use for the top of the
                        ; box (it's a three-pixel high horizontal bar)

.boxt1

 STA nameBuffer0,Y      ; Set the Y-th entry in nametable 0 to tile 3

 INY                    ; Increment the column counter

 CPY #32                ; Loop back until we have drawn in columns 1 through 31
 BNE boxt1

 RTS                    ; Return from the subroutine

; ******************************************************************************
;
;       Name: DrawBoxEdges
;       Type: Subroutine
;   Category: Drawing the screen
;    Summary: Draw the left and right edges of the box along the sides of the
;             screen, drawing into the nametable buffer for the drawing bitplane
;
; ******************************************************************************

.DrawBoxEdges

 LDX drawingBitplane    ; If the drawing bitplane is set to 1, jump to boxe1 to
 BNE boxe1              ; draw the box edges in bitplane 1

                        ; Otherwise we draw the box edges in bitplane 0

 LDA boxEdge1           ; Set A to the tile number for the left edge of the box,
                        ; which will either be tile 1 for the normal view (a
                        ; three-pixel wide vertical bar along the right edge of
                        ; the tile), or tile 0 (blank) for the death screen

 STA nameBuffer0+1      ; Write this tile into column 1 on rows 0 to 19 in
 STA nameBuffer0+1*32+1 ; nametable buffer 0 to draw the left edge of the box
 STA nameBuffer0+2*32+1 ; (column 1 is the left edge because the screen is
 STA nameBuffer0+3*32+1 ; scrolled horizontally by one block)
 STA nameBuffer0+4*32+1
 STA nameBuffer0+5*32+1
 STA nameBuffer0+6*32+1
 STA nameBuffer0+7*32+1
 STA nameBuffer0+8*32+1
 STA nameBuffer0+9*32+1
 STA nameBuffer0+10*32+1
 STA nameBuffer0+11*32+1
 STA nameBuffer0+12*32+1
 STA nameBuffer0+13*32+1
 STA nameBuffer0+14*32+1
 STA nameBuffer0+15*32+1
 STA nameBuffer0+16*32+1
 STA nameBuffer0+17*32+1
 STA nameBuffer0+18*32+1
 STA nameBuffer0+19*32+1

 LDA boxEdge2           ; Set A to the tile number for the right edge of the
                        ; box, which will either be tile 2 for the normal view
                        ; (a three-pixel wide vertical bar along the left edge
                        ; of the tile), or tile 0 (blank) for the death screen

 STA nameBuffer0        ; Write this tile into column 0 on rows 0 to 19 in
 STA nameBuffer0+1*32   ; nametable buffer 0 to draw the right edge of the box
 STA nameBuffer0+2*32   ; (column 0 is the right edge because the screen is
 STA nameBuffer0+3*32   ; scrolled horizontally by one block)
 STA nameBuffer0+4*32
 STA nameBuffer0+5*32
 STA nameBuffer0+6*32
 STA nameBuffer0+7*32
 STA nameBuffer0+8*32
 STA nameBuffer0+9*32
 STA nameBuffer0+10*32
 STA nameBuffer0+11*32
 STA nameBuffer0+12*32
 STA nameBuffer0+13*32
 STA nameBuffer0+14*32
 STA nameBuffer0+15*32
 STA nameBuffer0+16*32
 STA nameBuffer0+17*32
 STA nameBuffer0+18*32
 STA nameBuffer0+19*32

 RTS                    ; Return from the subroutine

.boxe1

 LDA boxEdge1           ; Set A to the tile number for the left edge of the box,
                        ; which will either be tile 1 for the normal view (a
                        ; three-pixel wide vertical bar along the right edge of
                        ; the tile), or tile 0 (blank) for the death screen

 STA nameBuffer1+1      ; Write this tile into column 1 on rows 0 to 19 in
 STA nameBuffer1+1*32+1 ; nametable buffer 1 to draw the left edge of the box
 STA nameBuffer1+2*32+1 ; (column 1 is the left edge because the screen is
 STA nameBuffer1+3*32+1 ; scrolled horizontally by one block)
 STA nameBuffer1+4*32+1
 STA nameBuffer1+5*32+1
 STA nameBuffer1+6*32+1
 STA nameBuffer1+7*32+1
 STA nameBuffer1+8*32+1
 STA nameBuffer1+9*32+1
 STA nameBuffer1+10*32+1
 STA nameBuffer1+11*32+1
 STA nameBuffer1+12*32+1
 STA nameBuffer1+13*32+1
 STA nameBuffer1+14*32+1
 STA nameBuffer1+15*32+1
 STA nameBuffer1+16*32+1
 STA nameBuffer1+17*32+1
 STA nameBuffer1+18*32+1
 STA nameBuffer1+19*32+1

 LDA boxEdge2           ; Set A to the tile number for the right edge of the
                        ; box, which will either be tile 2 for the normal view
                        ; (a three-pixel wide vertical bar along the left edge
                        ; of the tile), or tile 0 (blank) for the death screen

 STA nameBuffer1        ; Write this tile into column 0 on rows 0 to 19 in
 STA nameBuffer1+1*32   ; nametable buffer 1 to draw the right edge of the box
 STA nameBuffer1+2*32   ; (column 0 is the right edge because the screen is
 STA nameBuffer1+3*32   ; scrolled horizontally by one block)
 STA nameBuffer1+4*32
 STA nameBuffer1+5*32
 STA nameBuffer1+6*32
 STA nameBuffer1+7*32
 STA nameBuffer1+8*32
 STA nameBuffer1+9*32
 STA nameBuffer1+10*32
 STA nameBuffer1+11*32
 STA nameBuffer1+12*32
 STA nameBuffer1+13*32
 STA nameBuffer1+14*32
 STA nameBuffer1+15*32
 STA nameBuffer1+16*32
 STA nameBuffer1+17*32
 STA nameBuffer1+18*32
 STA nameBuffer1+19*32

 SETUP_PPU_FOR_ICON_BAR ; If the PPU has started drawing the icon bar, configure
                        ; the PPU to use nametable 0 and pattern table 0

 RTS                    ; Return from the subroutine

; ******************************************************************************
;
;       Name: UNIV
;       Type: Variable
;   Category: Universe
;    Summary: Table of pointers to the local universe's ship data blocks
;  Deep dive: The local bubble of universe
;
; ------------------------------------------------------------------------------
;
; See the deep dive on "Ship data blocks" for details on ship data blocks, and
; the deep dive on "The local bubble of universe" for details of how Elite
; stores the local universe in K%, FRIN and UNIV.
;
; Note that in the NES version, there are four extra bytes at the end of each K%
; block that don't form part of the core ship block, so each ship in K% contains
; NIK% = NI% + 4 bytes, rather than NI%.
;
; ******************************************************************************

.UNIV

 FOR I%, 0, NOSH

  EQUW K% + I% * NIK%   ; Address of block no. I%, of size NIK%, in workspace K%

 NEXT

; ******************************************************************************
;
;       Name: GINF
;       Type: Subroutine
;   Category: Universe
;    Summary: Fetch the address of a ship's data block into INF
;
; ------------------------------------------------------------------------------
;
; Get the address of the data block for ship slot X and store it in INF. This
; address is fetched from the UNIV table, which stores the addresses of the 13
; ship data blocks in workspace K%.
;
; Arguments:
;
;   X                   The ship slot number for which we want the data block
;                       address
;
; ******************************************************************************

.GINF

 TXA                    ; Set Y = X * 2
 ASL A
 TAY

 LDA UNIV,Y             ; Get the high byte of the address of the X-th ship
 STA INF                ; from UNIV and store it in INF

 LDA UNIV+1,Y           ; Get the low byte of the address of the X-th ship
 STA INF+1              ; from UNIV and store it in INF

 RTS                    ; Return from the subroutine

; ******************************************************************************
;
;       Name: HideExplosionBurst
;       Type: Subroutine
;   Category: Drawing ships
;    Summary: Hide the four sprites that make up the explosion burst that
;             flashes up when a ship explodes
;
; ******************************************************************************

.HideExplosionBurst

 LDX #4                 ; Set X = 4 so we hide four sprites

 LDY #236               ; Set Y so we start hiding from sprite 236 / 4 = 59

 JMP HideSprites        ; Jump to HideSprites to hide four sprites from sprite
                        ; 59 onwards (i.e. 59 to 62), returning from the
                        ; subroutine using a tail call

; ******************************************************************************
;
;       Name: ClearScanner
;       Type: Subroutine
;   Category: Dashboard
;    Summary: Remove all ships from the scanner and hide the scanner sprites
;
; ******************************************************************************

.ClearScanner

 LDX #0                 ; Set up a counter in X to work our way through all the
                        ; ship slots in FRIN

.csca1

 LDA FRIN,X             ; Fetch the ship type in slot X

 BEQ csca3              ; If the slot contains 0 then it is empty and we have
                        ; checked all the slots (as they are always shuffled
                        ; down in the main loop to close up and gaps), so jump
                        ; to csca3WS2 as we are done

 BMI csca2              ; If the slot contains a ship type with bit 7 set, then
                        ; it contains the planet or the sun, so jump down to
                        ; csca2 to skip this slot, as the planet and sun don't
                        ; appear on the scanner

 JSR GINF               ; Call GINF to get the address of the data block for
                        ; ship slot X and store it in INF

 LDY #31                ; Clear bit 4 in the ship's byte #31, which hides it
 LDA (INF),Y            ; from the scanner
 AND #%11101111
 STA (INF),Y

.csca2

 INX                    ; Increment X to point to the next ship slot

 BNE csca1              ; Loop back up to process the next slot (this BNE is
                        ; effectively a JMP as X will never be zero)

.csca3

 LDY #44                ; Set Y so we start hiding from sprite 44 / 4 = 11

 LDX #27                ; Set X = 27 so we hide 27 sprites

                        ; Fall through into HideSprites to hide 27 sprites
                        ; from sprite 11 onwards (i.e. the scanner sprites from
                        ; 11 to 37)

; ******************************************************************************
;
;       Name: HideSprites
;       Type: Subroutine
;   Category: Drawing sprites
;    Summary: Hide X sprites from sprite Y / 4 onwards
;
; ------------------------------------------------------------------------------
;
; Arguments:
;
;   X                   The number of sprites to hide
;
;   Y                   The number of the first sprite to hide * 4
;
; ******************************************************************************

.HideSprites

 LDA #240               ; Set A to the y-coordinate that's just below the bottom
                        ; of the screen, so we can hide the required sprites by
                        ; moving them off-screen

.hspr1

 STA ySprite0,Y         ; Set the y-coordinate for sprite Y / 4 to 240 to hide
                        ; it (the division by four is because each sprite in the
                        ; sprite buffer has four bytes of data)

 INY                    ; Add 4 to Y so it points to the next sprite's data in
 INY                    ; the sprite buffer
 INY
 INY

 DEX                    ; Decrement the loop counter in X

 BNE hspr1              ; Loop back until we have hidden X sprites

 RTS                    ; Return from the subroutine

 EQUB $0C, $20, $1F     ; These bytes appear to be unused

; ******************************************************************************
;
;       Name: nameBufferHiAddr
;       Type: Variable
;   Category: Drawing the screen
;    Summary: The high bytes of the addresses of the two nametable buffers
;
; ******************************************************************************

.nameBufferHiAddr

 EQUB HI(nameBuffer0)
 EQUB HI(nameBuffer1)

; ******************************************************************************
;
;       Name: pattBufferHiAddr
;       Type: Variable
;   Category: Drawing the screen
;    Summary: The high bytes of the addresses of the two pattern buffers
;
; ******************************************************************************

.pattBufferHiAddr

 EQUB HI(pattBuffer0)
 EQUB HI(pattBuffer1)

; ******************************************************************************
;
;       Name: IRQ
;       Type: Subroutine
;   Category: Utility routines
;    Summary: Handle IRQ interrupts by doing nothing
;
; ******************************************************************************

.IRQ

 RTI                    ; Return from the interrupt handler

; ******************************************************************************
;
;       Name: NMI
;       Type: Subroutine
;   Category: Utility routines
;    Summary: The NMI interrupt handler that gets called every VBlank and which
;             updates the screen, reads the controllers and plays music
;
; ******************************************************************************

.NMI

 JSR SendPaletteSprites ; Send the current palette and sprite data to the PPU

 LDA showUserInterface  ; Set the value of setupPPUForIconBar so that if there
 STA setupPPUForIconBar ; is an on-screen user interface (which there will be if
                        ; this isn't the game over screen), then the calls to
                        ; the SETUP_PPU_FOR_ICON_BAR macro sprinkled throughout
                        ; the codebase will make sure we set nametable 0 and
                        ; palette table 0 when the PPU starts drawing the icon
                        ; bar

IF _NTSC

 LDA #HI(6797)          ; Set cycleCount = 6797
 STA cycleCount+1       ;
 LDA #LO(6797)          ; We use this to keep track of how many cycles we have
 STA cycleCount         ; left in the current VBlank, so we only send data to
                        ; the PPU when VBlank is in progress, splitting up the
                        ; larger PPU operations across multiple VBlanks

ELIF _PAL

 LDA #HI(7433)          ; Set cycleCount = 7433
 STA cycleCount+1       ;
 LDA #LO(7433)          ; We use this to keep track of how many cycles we have
 STA cycleCount         ; left in the current VBlank, so we only send data to
                        ; the PPU when VBlank is in progress, splitting up the
                        ; larger PPU operations across multiple VBlanks

ENDIF

 JSR UpdateScreen       ; Update the screen by copying the nametable and pattern
                        ; data for the relevant tiles to the PPU

 JSR ReadControllers    ; Read the buttons on the controllers

 LDA autoPlayDemo       ; If bit 7 of autoPlayDemo is clear then the demo is not
 BPL inmi1              ; being played automatically, so jump to inmi1 to skip
                        ; the following

 JSR AutoPlayDemo       ; Bit 7 of autoPlayDemo is set, so call AutoPlayDemo to
                        ; automatically play the demo using the controller key
                        ; presses in the autoplayKeys tables

.inmi1

 JSR MoveIconBarPointer ; Move the sprites that make up the icon bar pointer

 JSR UpdateJoystick     ; Update the values of JSTX and JSTY with the values
                        ; from the controller

 JSR UpdateNMITimer     ; Update the NMI timer, which we can use in place of
                        ; hardware timers (which the NES does not support)

 LDA runningSetBank     ; If the NMI handler was called from within the SetBank
 BNE inmi2              ; routine, then runningSetBank will be $FF, so jump to
                        ; inmi2 to skip the call to PlayMusic

 JSR PlayMusic_b6       ; Call the PlayMusic routine to play the background
                        ; music

 LDA nmiStoreA          ; Restore the values of A, X and Y that we stored at
 LDX nmiStoreX          ; the start of the NMI handler
 LDY nmiStoreY

 RTI                    ; Return from the interrupt handler

.inmi2

 INC runningSetBank     ; Increment runningSetBank

 LDA nmiStoreA          ; Restore the values of A, X and Y that we stored at
 LDX nmiStoreX          ; the start of the NMI handler
 LDY nmiStoreY

 RTI                    ; Return from the interrupt handler

; ******************************************************************************
;
;       Name: UpdateNMITimer
;       Type: Subroutine
;   Category: Utility routines
;    Summary: Update the NMI timer, which we can use in place of hardware
;             timers (which the NES does not support)
;
; ******************************************************************************

.UpdateNMITimer

 DEC nmiTimer           ; Decrement the NMI timer counter, so that it counts
                        ; each NMI interrupt

 BNE nmit1              ; If it hsn't reached zero yet, jump to nmit1 to return
                        ; from the subroutine

 LDA #50                ; Wrap the NMI timer round to start counting down from
 STA nmiTimer           ; 50 once again, as it just reached zero

 LDA nmiTimerLo         ; Increment (nmiTimerHi nmiTimerLo)
 CLC
 ADC #1
 STA nmiTimerLo
 LDA nmiTimerHi
 ADC #0
 STA nmiTimerHi

.nmit1

 RTS                    ; Return from the subroutine

; ******************************************************************************
;
;       Name: SendPaletteSprites
;       Type: Subroutine
;   Category: Drawing sprites
;    Summary: Send the current palette and sprite data to the PPU
;
; ******************************************************************************

.SendPaletteSprites

 STA nmiStoreA          ; Store the values of A, X and Y so we can retrieve them
 STX nmiStoreX          ; at the end of the NMI handler
 STY nmiStoreY

 LDA PPU_STATUS         ; Read from PPU_STATUS to clear bit 7 of PPU_STATUS and
                        ; reset the VBlank start flag

 INC frameCounter       ; Increment the frame counter

 LDA #0                 ; Write 0 to OAM_ADDR so we can use OAM_DMA to send
 STA OAM_ADDR           ; sprite data to the PPU

 LDA #$02               ; Write $02 to OAM_DMA to upload 256 bytes of sprite
 STA OAM_DMA            ; data from the sprite buffer at $02xx into the PPU

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

                        ; Fall through into SetPaletteForView to set the correct
                        ; palette for the current view

; ******************************************************************************
;
;       Name: SetPaletteForView
;       Type: Subroutine
;   Category: Drawing the screen
;    Summary: Set the correct background and sprite palettes for the current
;             view and (if this is the space view) the hidden bit plane
;
; ******************************************************************************

.SetPaletteForView

 LDA QQ11a              ; Set A to the current view (or the old view that is
                        ; still being shown, if we are in the process of
                        ; changing view)

 BNE palv2              ; If this is not the space view, jump to palv2

                        ; If we get here then this is the space view

 LDY visibleColour      ; Set Y to the colour to use for visible pixels

 LDA hiddenBitPlane     ; If hiddenBitPlane is non-zero (i.e. 1), jump to palv1
 BNE palv1              ; to hide pixels in bitplane 1

                        ; If we get here then hiddenBitPlane = 0, so now we hide
                        ; pixels in bitplane 0 and show pixels in bitplane 1

 LDA #$3F               ; Set PPU_ADDR = $3F01, so it points to background
 STA PPU_ADDR           ; palette 0 in the PPU
 LDA #$01
 STA PPU_ADDR

 LDA hiddenColour       ; Set A to the colour to use for hidden pixels

 STA PPU_DATA           ; Set palette 0 to the following:
 STY PPU_DATA           ;
 STY PPU_DATA           ;   * Colour 0 = background (black)
                        ;
                        ;   * Colour 1 = hidden colour (bitplane 0)
                        ;
                        ;   * Colour 2 = visible colour (bitplane 1)
                        ;
                        ;   * Colour 3 = visible colour
                        ;
                        ; So pixels in bitplane 0 will be hidden, while
                        ; pixels in bitplane 1 will be visible
                        ;
                        ; i.e. pixels in the hiddenBitPlane will be hidden

 LDA #$00               ; Change the PPU address away from the palette entries
 STA PPU_ADDR           ; to prevent the palette being corrupted
 LDA #$00
 STA PPU_ADDR

 RTS                    ; Return from the subroutine

.palv1

                        ; If we get here then hiddenBitPlane = 1, so now we hide
                        ; pixels in bitplane 1 and show pixels in bitplane 0

 LDA #$3F               ; Set PPU_ADDR = $3F01, so it points to background
 STA PPU_ADDR           ; palette 0 in the PPU
 LDA #$01
 STA PPU_ADDR

 LDA hiddenColour       ; Set A to the colour to use for hidden pixels

 STY PPU_DATA           ; Set palette 0 to the following:
 STA PPU_DATA           ;
 STY PPU_DATA           ;   * Colour 0 = background (black)
                        ;
                        ;   * Colour 1 = visible colour (bitplane 0)
                        ;
                        ;   * Colour 2 = hidden colour (bitplane 1)
                        ;
                        ;   * Colour 3 = visible colour
                        ;
                        ; So pixels in bitplane 0 will be visible, while
                        ; pixels in bitplane 1 will be hidden
                        ;
                        ; i.e. pixels in the hiddenBitPlane will be hidden

 LDA #$00               ; Change the PPU address away from the palette entries
 STA PPU_ADDR           ; to prevent the palette being corrupted
 LDA #$00
 STA PPU_ADDR

 RTS                    ; Return from the subroutine

.palv2

                        ; If we get here then this is not the space view

 CMP #$98               ; If this is the Status Mode screen, jump to palv3
 BEQ palv3

                        ; If we get here then this is not the space view or the
                        ; Status Mode screen

 LDA #$3F               ; Set PPU_ADDR = $3F15, so it points to sprite palette 1
 STA PPU_ADDR           ; in the PPU
 LDA #$15
 STA PPU_ADDR

 LDA visibleColour      ; Set palette 0 to the following:
 STA PPU_DATA           ;
 LDA paletteColour2     ;   * Colour 0 = background (black)
 STA PPU_DATA           ;
 LDA paletteColour3     ;   * Colour 1 = visible colour
 STA PPU_DATA           ;
                        ;   * Colour 2 = paletteColour2
                        ;
                        ;   * Colour 3 = paletteColour3

 LDA #$00               ; Change the PPU address away from the palette entries
 STA PPU_ADDR           ; to prevent the palette being corrupted
 LDA #$00
 STA PPU_ADDR

 RTS                    ; Return from the subroutine

.palv3

                        ; If we get here then this is the Status Mode screen

 LDA #$3F               ; Set PPU_ADDR = $3F01, so it points to background
 STA PPU_ADDR           ; palette 0 in the PPU
 LDA #$01
 STA PPU_ADDR

 LDA visibleColour      ; Set palette 0 to the following:
 STA PPU_DATA           ;
 LDA paletteColour2     ;   * Colour 0 = background (black)
 STA PPU_DATA           ;
 LDA paletteColour3     ;   * Colour 1 = visible colour
 STA PPU_DATA           ;
                        ;   * Colour 2 = paletteColour2
                        ;
                        ;   * Colour 3 = paletteColour3

 LDA #$00               ; Change the PPU address away from the palette entries
 STA PPU_ADDR           ; to prevent the palette being corrupted
 LDA #$00
 STA PPU_ADDR

 RTS                    ; Return from the subroutine

; ******************************************************************************
;
;       Name: SendPalettesToPPU
;       Type: Subroutine
;   Category: Drawing the screen
;    Summary: Send the palette data from XX3 to the PPU
;
; ******************************************************************************

.SendPalettesToPPU

 LDA #$3F               ; Set PPU_ADDR = $3F01, so it points to background
 STA PPU_ADDR           ; palette 0 in the PPU
 LDA #$01
 STA PPU_ADDR

 LDX #1                 ; We are about to send the palette data from XX3 to
                        ; the PPU, so set an index counter in X so we send the
                        ; following:
                        ;
                        ;   XX3+1 goes to $3F01
                        ;   XX3+2 goes to $3F02
                        ;   ...
                        ;   XX3+$30 goes to $3F30
                        ;   XX3+$31 goes to $3F31
                        ;
                        ; So the following loop sends data for the four
                        ; background palettes and the four sprite palettes

.sepa1

 LDA XX3,X              ; Set A to the X-th entry in XX3

 AND #%00111111         ; Clear bits 6 and 7

 STA PPU_DATA           ; Send the palette entry to the PPU

 INX                    ; Increment the loop counter

 CPX #$20               ; Loop back until we have sent XX3+1 through XX3+$1F
 BNE sepa1

 SUBTRACT_CYCLES 559    ; Subtract 559 from the cycle count

 JMP UpdateScreen+4     ; Return to UpdateScreen to continue with the next
                        ; instruction following the call to this routine

; ******************************************************************************
;
;       Name: UpdateScreen
;       Type: Subroutine
;   Category: Drawing the screen
;    Summary: Update the screen with the contents of the buffers
;
; ------------------------------------------------------------------------------
;
; Other entry points:
;
;   UpdateScreen+4      Re-entry point following the call to SendPalettesToPPU
;                       at the start of the routine
;
; ******************************************************************************

.UpdateScreen

 LDA updatePaletteInNMI ; If updatePaletteInNMI is non-zero, then jump up to
 BNE SendPalettesToPPU  ; SendPalettesToPPU to send the palette data in XX3 to
                        ; the PPU, before continuing with the next instruction

 JSR SendBuffersToPPU   ; Send the contents of the nametable and pattern buffers
                        ; to the PPU to update the screen

 JSR SetPPURegisters    ; Set PPU_CTRL, PPU_ADDR and PPU_SCROLL for the current
                        ; hidden bitplane

 LDA cycleCount         ; Add 100 ($0064) to cycleCount
 CLC
 ADC #$64
 STA cycleCount
 LDA cycleCount+1
 ADC #$00
 STA cycleCount+1

 BMI upsc1              ; If the result is negative, jump to upsc1 to stop
                        ; sending PPU data in this VBlank, as we have run out of
                        ; cycles (we will pick up where we left off in the next
                        ; VBlank)

 JSR ClearBuffers       ; The result is positive, so we have enough cycles to
                        ; keep sending PPU data in this VBlank, so call
                        ; ClearBuffers to reset the buffers for both bitplanes

.upsc1

 LDA #%00011110         ; Configure the PPU by setting PPU_MASK as follows:
 STA PPU_MASK           ;
                        ;   * Bit 0 clear = normal colour (i.e. not monochrome)
                        ;   * Bit 1 set   = show leftmost 8 pixels of background
                        ;   * Bit 2 set   = show sprites in leftmost 8 pixels
                        ;   * Bit 3 set   = show background
                        ;   * Bit 4 set   = show sprites
                        ;   * Bit 5 clear = do not intensify greens
                        ;   * Bit 6 clear = do not intensify blues
                        ;   * Bit 7 clear = do not intensify reds

 RTS                    ; Return from the subroutine

; ******************************************************************************
;
;       Name: SetPPURegisters
;       Type: Subroutine
;   Category: Drawing the screen
;    Summary: Set PPU_CTRL, PPU_ADDR and PPU_SCROLL for the current palette
;             bitplane
;
; ******************************************************************************

.SetPPURegisters

 LDX #%10010000         ; Set X to use as the value of PPU_CTRL for when
                        ; hiddenBitPlane is 1:
                        ;
                        ;   * Bits 0-1    = base nametable address %00 ($2000)
                        ;   * Bit 2 clear = increment PPU_ADDR by 1 each time
                        ;   * Bit 3 clear = sprite pattern table is at $0000
                        ;   * Bit 4 set   = background pattern table is at $1000
                        ;   * Bit 5 clear = sprites are 8x8 pixels
                        ;   * Bit 6 clear = use PPU 0 (the only option on a NES)
                        ;   * Bit 7 set   = enable VBlank NMI generation

 LDA hiddenBitPlane     ; If hiddenBitPlane is non-zero (i.e. 1), skip the
 BNE resp1              ; following

 LDX #%10010001         ; Set X to use as the value of PPU_CTRL for when
                        ; hiddenBitPlane is 0:
                        ;
                        ;   * Bits 0-1    = base nametable address %01 ($2400)
                        ;   * Bit 2 clear = increment PPU_ADDR by 1 each time
                        ;   * Bit 3 clear = sprite pattern table is at $0000
                        ;   * Bit 4 set   = background pattern table is at $1000
                        ;   * Bit 5 clear = sprites are 8x8 pixels
                        ;   * Bit 6 clear = use PPU 0 (the only option on a NES)
                        ;   * Bit 7 set   = enable VBlank NMI generation

.resp1

 STX PPU_CTRL           ; Configure the PPU with the above value of PPU_CTRL,
                        ; according to the hidden bitplane, so we set:
                        ;
                        ;   * Nametable 0 when hiddenBitPlane = 1
                        ;
                        ;   * Nametable 1 when hiddenBitPlane = 0
                        ;
                        ; This makes sure that the screen shows the nametable
                        ; for the visible bitplane, and not the hidden bitplane

 STX ppuCtrlCopy        ; Store the new value of PPU_CTRL in ppuCtrlCopy so we
                        ; can check its value without having to access the PPU

 LDA #$20               ; If hiddenBitPlane = 0 then set A = $24, otherwise set
 LDX hiddenBitPlane     ; A = $20, to use as the high byte of the PPU_ADDR
 BNE resp2              ; address
 LDA #$24

.resp2

 STA PPU_ADDR           ; Set PPU_ADDR to point to the nametable address that we
 LDA #$00               ; just configured:
 STA PPU_ADDR           ;
                        ;   * $2000 (nametable 0) when hiddenBitPlane = 1
                        ;
                        ;   * $2400 (nametable 1) when hiddenBitPlane = 0
                        ;
                        ; So we now flush the pipeline for the nametable that we
                        ; are showing on-screen, to avoid any corruption

 LDA PPU_DATA           ; Read from PPU_DATA eight times to clear the pipeline
 LDA PPU_DATA           ; and reset the internal PPU read buffer
 LDA PPU_DATA
 LDA PPU_DATA
 LDA PPU_DATA
 LDA PPU_DATA
 LDA PPU_DATA
 LDA PPU_DATA

 LDA #8                 ; Set the horizontal scroll to 8, so the leftmost tile
 STA PPU_SCROLL         ; on each row is scrolled around to the right side
                        ;
                        ; This means that in terms of tiles, column 1 is the
                        ; left edge of the screen, then columns 2 to 31 form the
                        ; body of the screen, and column 0 is the right edge of
                        ; the screen

 LDA #0                 ; Set the vertical scroll to 0
 STA PPU_SCROLL

 RTS                    ; Return from the subroutine

; ******************************************************************************
;
;       Name: SetPPUTablesTo0
;       Type: Subroutine
;   Category: Drawing the screen
;    Summary: Set nametable 0 and pattern table 0 for drawing the icon bar
;
; ******************************************************************************

.SetPPUTablesTo0

 LDA #0                 ; Clear bit 7 of setupPPUForIconBar, so this routine
 STA setupPPUForIconBar ; doesn't get called again until the next NMI interrupt
                        ; at the next VBlank (as the SETUP_PPU_FOR_ICON_BAR
                        ; macro and SetupPPUForIconBar routine only update the
                        ; PPU when bit 7 is set)

 LDA ppuCtrlCopy        ; Set A to the current value of PPU_CTRL

 AND #%11101110         ; Clear bits 0 and 4, which will set the base nametable
                        ; address to $2000 (for nametable 0) and the pattern
                        ; table address to $0000 (for pattern table 0)

 STA PPU_CTRL           ; Update PPU_CTRL to set nametable 0 and pattern table 0

 STA ppuCtrlCopy        ; Store the new value of PPU_CTRL in ppuCtrlCopy so we
                        ; can check its value without having to access the PPU

 CLC                    ; Clear the C flag

 RTS                    ; Return from the subroutine

; ******************************************************************************
;
;       Name: ClearBuffers
;       Type: Subroutine
;   Category: Drawing the screen
;    Summary: If there are enough free cycles, clear down the nametable and
;             pattern buffers for both bitplanes
;
; ******************************************************************************

.ClearBuffers

 LDA cycleCount+1       ; If the high byte of cycleCount(1 0) is zero, then the
 BEQ cbuf3              ; cycle count is 255 or less, so jump to cbuf3 to skip
                        ; the buffer clearing, as we have run out of cycles (we
                        ; will pick up where we left off in the next VBlank)

 SUBTRACT_CYCLES 363    ; Subtract 363 from the cycle count

 BMI cbuf1              ; If the result is negative, jump to cbuf1 to skip the
                        ; buffer clearing, as we have run out of cycles (we
                        ; will pick up where we left off in the next VBlank)

 JMP cbuf2              ; The result is positive, so we have enough cycles to
                        ; clear the buffers, so jump to cbuf2 to do just that

.cbuf1

 ADD_CYCLES 318         ; Add 318 to the cycle count

 JMP cbuf3              ; Jump to cbuf3 to skip the buffer clearing and return
                        ; from the subroutine

.cbuf2

 LDA clearBlockSize     ; Store clearBlockSize(1 0) and clearAddress(1 0) on the
 PHA                    ; stack, so we can use them in the ClearPlaneBuffers
 LDA clearBlockSize+1   ; routine and can restore them to their original values
 PHA                    ; afterwards (in case the NMI handler was called while
 LDA clearAddress       ; these variables are being used)
 PHA
 LDA clearAddress+1
 PHA

 LDX #0                 ; Call ClearPlaneBuffers with X = 0 to clear the buffers
 JSR ClearPlaneBuffers  ; for bitplane 0

 LDX #1                 ; Call ClearPlaneBuffers with X = 1 to clear the buffers
 JSR ClearPlaneBuffers  ; for bitplane 1

 PLA                    ; Retore clearBlockSize(1 0) and clearAddress(1 0) from
 STA clearAddress+1     ; the stack
 PLA
 STA clearAddress
 PLA
 STA clearBlockSize+1
 PLA
 STA clearBlockSize

 ADD_CYCLES_CLC 238     ; Add 238 to the cycle count

.cbuf3

                        ; This part of the routine repeats the code in cbuf5
                        ; until we run out of cycles, though as cbuf5 only
                        ; contains NOPs, this doesn't achieve anything other
                        ; than running down the cycle counter (perhaps it's
                        ; designed to even out each call to the NMI handler,
                        ; or is just left over from development)

 SUBTRACT_CYCLES 32     ; Subtract 32 from the cycle count

 BMI cbuf4              ; If the result is negative, jump to cbuf4 to return
                        ; from the subroutine, as we have run out of cycles

 JMP cbuf5              ; The result is positive, so we have enough cycles to
                        ; continue, so jump to cbuf5

.cbuf4

 ADD_CYCLES 65527       ; Add 65527 to the cycle count (i.e. subtract 9) ???

 JMP cbuf6              ; Jump to cbuf6 to return from the subroutine

.cbuf5

 NOP                    ; This looks like code that has been removed
 NOP
 NOP

 JMP cbuf3              ; Jump back to cbuf3 to check the cycle count and keep
                        ; running the above until the cycle count runs out

.cbuf6

 RTS                    ; Return from the subroutine

; ******************************************************************************
;
;       Name: ReadControllers
;       Type: Subroutine
;   Category: Keyboard
;    Summary: ???
;
; ******************************************************************************

.ReadControllers

 LDA #1
 STA JOY1
 LSR A
 STA JOY1
 TAX
 JSR ScanButtons

 LDX scanController2
 BEQ RTS3

; ******************************************************************************
;
;       Name: ScanButtons
;       Type: Subroutine
;   Category: Keyboard
;    Summary: ???
;
; ------------------------------------------------------------------------------
;
; Other entry points:
;
;   RTS3                Contains an RTS
;
; ******************************************************************************

.ScanButtons

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

.RTS3

 RTS

; ******************************************************************************
;
;       Name: WaitForNextFrame
;       Type: Subroutine
;   Category: Utility routines
;    Summary: Wait until the frame counter increments (i.e. the next VBlank)
;
; ******************************************************************************

.WaitForNextFrame

 LDA frameCounter       ; Set A to the frame counter, which increments with each
                        ; call to the NMI handler

.wfrm1

 CMP frameCounter       ; Loop back to wfrm1 until the frame counter changes,
 BEQ wfrm1              ; which will happen when the NMI handler has been called
                        ; again (i.e. at the next VBlank)

 RTS                    ; Return from the subroutine

; ******************************************************************************
;
;       Name: WaitFor2NMIs
;       Type: Subroutine
;   Category: Utility routines
;    Summary: Wait until two NMI interrupts have passed (i.e. the next two
;             VBlanks)
;
; ------------------------------------------------------------------------------
;
; Returns:
;
;   A                   A is preserved
;
; ******************************************************************************

.WaitFor2NMIs

 JSR WaitForNMI         ; Wait until the next NMI interrupt has passed (i.e. the
                        ; next VBlank)

                        ; Fall through into WaitForNMI to wait for the second
                        ; NMI interrupt

; ******************************************************************************
;
;       Name: WaitForNMI
;       Type: Subroutine
;   Category: Utility routines
;    Summary: Wait until the next NMI interrupt has passed (i.e. the next
;             VBlank)
;
; ------------------------------------------------------------------------------
;
; Returns:
;
;   A                   A is preserved
;
; ******************************************************************************

.WaitForNMI

 PHA                    ; Store A on the stack to preserve it

 LDX frameCounter       ; Set X to the frame counter, which increments with each
                        ; call to the NMI handler

.wnmi1

 SETUP_PPU_FOR_ICON_BAR ; If the PPU has started drawing the icon bar, configure
                        ; the PPU to use nametable 0 and pattern table 0

 CPX frameCounter       ; Loop back to wnmi1 until the frame counter changes,
 BEQ wnmi1              ; which will happen when the NMI handler has been called
                        ; again (i.e. at the next VBlank)

 PLA                    ; Retrieve A from the stack so that it's preserved

 RTS                    ; Return from the subroutine

; ******************************************************************************
;
;       Name: WaitForIconBarPPU
;       Type: Subroutine
;   Category: Drawing the screen
;    Summary: Wait until the PPU starts drawing the icon bar
;
; ******************************************************************************

.WaitForIconBarPPU

 LDA setupPPUForIconBar ; Loop back to the start until setupPPUForIconBar is
 BEQ WaitForIconBarPPU  ; non-zero, at which point the SETUP_PPU_FOR_ICON_BAR
                        ; macro and SetupPPUForIconBar routine are checking to
                        ; see whether the icon bar is being drawn by the PPU

.wbar1

 SETUP_PPU_FOR_ICON_BAR ; If the PPU has started drawing the icon bar, configure
                        ; the PPU to use nametable 0 and pattern table 0

 LDA setupPPUForIconBar ; Loop back until setupPPUForIconBar is zero, at which
 BNE wbar1              ; point the icon bar is being drawn by the PPU

 RTS                    ; Return from the subroutine

; ******************************************************************************
;
;       Name: ClearDrawingPlane (Part 1 of 3)
;       Type: Subroutine
;   Category: Drawing the screen
;    Summary: Clear the nametable and pattern buffers for the newly flipped
;             drawing plane
;
; ------------------------------------------------------------------------------
;
; This routine is only called when we have just flipped the drawing plane
; between 0 and 1 in the FlipDrawingPlane routine.
;
; Arguments:
;
;   X                   The drawing bitplane to clear
;
; ******************************************************************************

 LDX #0                 ; This code is never called, but it provides an entry
 JSR ClearDrawingPlane  ; point for clearing both bitplanes, which would have
 LDX #1                 ; been useful during development

.ClearDrawingPlane

 SETUP_PPU_FOR_ICON_BAR ; If the PPU has started drawing the icon bar, configure
                        ; the PPU to use nametable 0 and pattern table 0

 LDA bitplaneFlags,X    ; If the flags for the new drawing bitplane are zero
 BEQ cdra2              ; then the bitplane's buffers are already clear (as we
                        ; will have zeroed the flags in cdra1 following a
                        ; successful clearance), so jump to cdra2 to return
                        ; from the subroutine

 AND #%00100000         ; If bit 5 of the bitplane flags is set, then we have
 BNE cdra1              ; already sent all the data to the PPU for this
                        ; bitplane, so jump to cdra1 to clear the buffers in
                        ; their entirety

 JSR cdra3              ; If we get here then bit 5 of the bitplane flags is
                        ; clear, which means we have not already sent all the
                        ; data to the PPU for this bitplane, so call cdra3 below
                        ; to clear out as much buffer space as we can for now

 JMP ClearDrawingPlane  ; Jump back to the start of the routine so we keep
                        ; clearing as much buffer space as we can until all the
                        ; data has been sent to the PPU (at which point bit 5
                        ; will be set and we will take the cdra1 branch instead)

.cdra1

 JSR cdra3              ; If we get here then bit 5 of the bitplane flags is
                        ; set, which means we have already sent all the data to
                        ; the PPU for this bitplane, so call cdra3 below to
                        ; clear out all remaining buffer space for this bitplane

 LDA #0                 ; Set the new drawing bitplane flags as follows:
 STA bitplaneFlags,X    ;
                        ;   * Bit 2 clear = last tile to send is lastTileNumber
                        ;   * Bit 3 clear = don't clear buffers after sending
                        ;   * Bit 4 clear = we've not started sending data yet
                        ;   * Bit 5 clear = we have not yet sent all the data
                        ;   * Bit 6 clear = only send pattern data to the PPU
                        ;   * Bit 7 clear = do not send data to the PPU
                        ;
                        ; Bits 0 and 1 are ignored and are always clear

 LDA firstPatternTile   ; Set the next free tile number in tileNumber to the
 STA tileNumber         ; value of firstPatternTile, which contains the number
                        ; of the first tile we just cleared, so it's also the
                        ; tile we can start drawing into when we next start
                        ; drawing into tiles

 JMP DrawBoxTop         ; Draw the top of the box into the new drawing bitplane,
                        ; returning from the subroutine using a tail call

.cdra2

 RTS                    ; Return from the subroutine

; ******************************************************************************
;
;       Name: ClearDrawingPlane (Part 2 of 3)
;       Type: Subroutine
;   Category: Drawing the screen
;    Summary: Clear the nametable buffers for the newly flipped drawing plane
;
; ******************************************************************************

.cdra3

 LDY frameCounter       ; Set Y to the frame counter, which is incremented every
                        ; VBlank by the NMI handler

 LDA sendingNameTile,X  ; Set SC to sendingNameTile for this bitplane, which
 STA SC                 ; contains number of the last tile that was sent to the
                        ; PPU nametable by the NMI handler, divided by 8
                        ;
                        ; So this contains the number of the last tile we need
                        ; to clear in the nametable buffer, divided by 8

 LDA clearingNameTile,X ; Set A to clearingNameTile for this bitplane, which
                        ; contains the number of the first tile that was sent
                        ; to the PPU nametable by the NMI handler, divided by 8
                        ;
                        ; So this contains the number of the first tile we need
                        ; to clear in the nametable buffer, divided by 8

 CPY frameCounter       ; If the frame counter has incremented since we fetched
 BNE cdra3              ; it above, then the tile numbers we just fetched might
                        ; already be out of date (as the NMI handler runs at
                        ; every VBlank, so it may have been run between now and
                        ; the frameCounter fetch above), so jump back to cdra3
                        ; to fetch them all again

 LDY SC                 ; Set Y to the number of the last tile divided by 8,
                        ; which we fetched above

 CPY maxTileNumber      ; If Y >= maxTileNumber then set Y = maxTileNumber, so
 BCC cdra4              ; Y has a maximum value of maxTileNumber
 LDY maxTileNumber

.cdra4

 STY SC                 ; Set SC to the number of the last tile, capped by the
                        ; maximum value in maxTileNumber

 CMP SC                 ; If A >= SC then the first tile we need to clear is
 BCS cdra6              ; after the last tile we need to clear, which means
                        ; there are no nametable tiles to clear, so jump to
                        ; to cdra6 to move on to clearing the pattern buffer
                        ; in part 3

 STY clearingNameTile,X ; Set clearingNameTile to the number of the last tile
                        ; to clear, if we don't clear the whole buffer here
                        ; (which will be the case if the buffer is still being
                        ; sent to the PPU), then we can pick it up again from
                        ; the tile after the batch we are about to clear

 LDY #0                 ; Set clearAddress(1 0) = (nameBufferHiAddr 0) + A * 8
 STY clearAddress+1     ;                  = (nameBufferHiAddr 0) + first tile
 ASL A                  ;
 ROL clearAddress+1     ; So clearAddress(1 0) contains the address in this
 ASL A                  ; bitplane's nametable buffer of the first tile we sent 
 ROL clearAddress+1
 ASL A
 STA clearAddress
 LDA clearAddress+1
 ROL A
 ADC nameBufferHiAddr,X
 STA clearAddress+1

 LDA #0                 ; Set SC(1 0) = (0 SC) * 8 + (nameBufferHiAddr 0)
 ASL SC                 ;
 ROL A                  ; So SC(1 0) contains the address in this bitplane's
 ASL SC                 ; nametable buffer of the last tile we sent
 ROL A
 ASL SC
 ROL A
 ADC nameBufferHiAddr,X
 STA SC+1

.cdra5

 SETUP_PPU_FOR_ICON_BAR ; If the PPU has started drawing the icon bar, configure
                        ; the PPU to use nametable 0 and pattern table 0

 LDA SC                 ; Set clearBlockSize(1 0) = SC(1 0) - clearAddress(1 0)
 SEC                    ;
 SBC clearAddress       ; So clearBlockSize(1 0) contains the number of tiles we
 STA clearBlockSize     ; already sent from this bitplane's nametable buffer
 LDA SC+1               ;
 SBC clearAddress+1     ; If the subtraction underflows, then there are no tiles
 BCC cdra6              ; to send, so jump to cdra6 to move on to clearing the
 STA clearBlockSize+1   ; pattern buffer in part 3

                        ; By this point, clearBlockSize(1 0) contains the number
                        ; of tiles we sent from this bitplane's nametable
                        ; buffer, so it contains the number of nametable entries
                        ; we need to clear
                        ;
                        ; Also, clearAddress(1 0) contains the address of the
                        ; first tile we sent from this bitplane's nametable
                        ; buffer

 ORA clearBlockSize     ; If both the high and low bytes of clearBlockSize(1 0)
 BEQ cdra6              ; are zero, then there are no tiles to clear, so jump to
                        ; cdra6 to clear the pattern buffer

 LDA #HI(790)           ; Set cycleCount = 790, so the call to ClearMemory
 STA cycleCount+1       ; doesn't run out of cycles and quit early (we are not
 LDA #LO(790)           ; in the NMI handler, so we don't need to count cycles,
 STA cycleCount         ; so this just ensures that the cycle-counting checks
                        ; are not triggered)

 JSR ClearMemory        ; Call ClearMemory to zero clearBlockSize(1 0) nametable
                        ; entries from address clearAddress(1 0) onwards

 JMP cdra5              ; The above should clear the whole block, but if the NMI
                        ; handler is called at VBlank while we are doing this,
                        ; then cycleCount may end up ticking down to zero while
                        ; we are still clearing memory, which would abort the
                        ; call to ClearMemory early, so we now loop back to
                        ; cdra5 to pick up where we left off, eventually exiting
                        ; the loop via the BCC cdra6 instruction above (at which
                        ; point we know for sure that we have cleared the whole
                        ; block)

; ******************************************************************************
;
;       Name: ClearDrawingPlane (Part 3 of 3)
;       Type: Subroutine
;   Category: Drawing the screen
;    Summary: Clear the nametable buffers for the newly flipped drawing plane
;
; ******************************************************************************

.cdra6

 LDY frameCounter       ; Set Y to the frame counter, which is incremented every
                        ; VBlank by the NMI handler

 LDA sendingPattTile,X  ; Set SC to sendingPattTile for this bitplane, which
 STA SC                 ; contains number of the last tile that was sent to the
                        ; PPU pattern table by the NMI handler
                        ;
                        ; So this contains the number of the last tile we need
                        ; to clear in the pattern buffer

 LDA clearingPattTile,X ; Set A to clearingPattTile for this bitplane, which
                        ; contains the number of the first tile that was sent
                        ; to the PPU pattern table by the NMI handler
                        ;
                        ; So this contains the number of the first tile we need
                        ; to clear in the pattern buffer

 CPY frameCounter       ; If the frame counter has incremented since we fetched
 BNE cdra6              ; it above, then the tile numbers we just fetched might
                        ; already be out of date (as the NMI handler runs at
                        ; every VBlank, so it may have been run between now and
                        ; the frameCounter fetch above), so jump back to cdra6
                        ; to fetch them all again

 LDY SC                 ; Set Y to the number of the last tile, which we fetched
                        ; above

 CMP SC                 ; If A >= SC then the first tile we need to clear is
 BCS cdra8              ; after the last tile we need to clear, which means
                        ; there are no pattern entries to clear, so jump to
                        ; to cdra8 to return from the subroutine as we are done

 STY clearingPattTile,X ; Set clearingPattTile to the number of the last tile
                        ; to clear, if we don't clear the whole buffer here
                        ; (which will be the case if the buffer is still being
                        ; sent to the PPU), then we can pick it up again from
                        ; the tile after the batch we are about to clear

 LDY #0                 ; Set clearAddress(1 0) = (pattBufferHiAddr 0) + A * 8
 STY clearAddress+1     ;                  = (pattBufferHiAddr 0) + first tile
 ASL A                  ;
 ROL clearAddress+1     ; So clearAddress(1 0) contains the address in this
 ASL A                  ; bitplane's pattern buffer of the first tile we sent 
 ROL clearAddress+1
 ASL A
 STA clearAddress
 LDA clearAddress+1
 ROL A
 ADC pattBufferHiAddr,X
 STA clearAddress+1

 LDA #0                 ; Set SC(1 0) = (0 SC) * 8 + (pattBufferHiAddr 0)
 ASL SC                 ;
 ROL A                  ; So SC(1 0) contains the address in this bitplane's
 ASL SC                 ; pattern buffer of the last tile we sent
 ROL A
 ASL SC
 ROL A
 ADC pattBufferHiAddr,X
 STA SC+1

.cdra7

 SETUP_PPU_FOR_ICON_BAR ; If the PPU has started drawing the icon bar, configure
                        ; the PPU to use nametable 0 and pattern table 0

 LDA SC                 ; Set clearBlockSize(1 0) = SC(1 0) - clearAddress(1 0)
 SEC                    ;
 SBC clearAddress       ; So clearBlockSize(1 0) contains the number of tiles we
 STA clearBlockSize     ; already sent from this bitplane's pattern buffer
 LDA SC+1               ;
 SBC clearAddress+1     ; If the subtraction underflows, then there are no tiles
 BCC cdra6              ; to send, so jump to cdra6 to make sure we have cleared
 STA clearBlockSize+1   ; the whole pattern buffer

                        ; By this point, clearBlockSize(1 0) contains the number
                        ; of tiles we sent from this bitplane's pattern buffer,
                        ; so it contains the number of pattern entries we need
                        ; to clear
                        ;
                        ; Also, clearAddress(1 0) contains the address of the
                        ; first tile we sent from this bitplane's pattern buffer

 ORA clearBlockSize     ; If both the high and low bytes of clearBlockSize(1 0)
 BEQ cdra8              ; are zero, then there are no tiles to clear, so jump to
                        ; cdra8 to return from the subroutine, as we are done

 LDA #HI(790)           ; Set cycleCount = 790, so the call to ClearMemory
 STA cycleCount+1       ; doesn't run out of cycles and quit early (we are not
 LDA #LO(790)           ; in the NMI handler, so we don't need to count cycles,
 STA cycleCount         ; so this just ensures that the cycle-counting checks
                        ; are not triggered)

 JSR ClearMemory        ; Call ClearMemory to zero clearBlockSize(1 0) nametable
                        ; entries from address clearAddress(1 0) onwards

 JMP cdra7              ; The above should clear the whole block, but if the NMI
                        ; handler is called at VBlank while we are doing this,
                        ; then cycleCount may end up ticking down to zero while
                        ; we are still clearing memory, which would abort the
                        ; call to ClearMemory early, so we now loop back to
                        ; cdra7 to pick up where we left off, eventually exiting
                        ; the loop via the BCC cdra6 instruction above (at which
                        ; point we know for sure that we have cleared the whole
                        ; block)

.cdra8

 RTS                    ; Return from the subroutine

; ******************************************************************************
;
;       Name: flagsForClearing
;       Type: Variable
;   Category: Drawing the screen
;    Summary: A bitplane mask to control how bitplane buffer clearing works in
;             the ClearPlaneBuffers routine
;
; ******************************************************************************

.flagsForClearing

 EQUB %00110000         ; The bitplane flags with ones in this byte must be
                        ; clear for the clearing process in ClearPlaneBuffers
                        ; to be activated
                        ;
                        ; So this configuration means that clearing will only be
                        ; attempted on bitplanes where:
                        ;
                        ;   * We are in the process of sending this bitplane's
                        ;     data to the PPU (bit 4 is set)
                        ;
                        ;   * We have already sent all the data to the PPU for
                        ;     this bitplane (bit 5 is set)
                        ;
                        ; If both bitplane flags are clear, then the buffers are
                        ; not cleared
                        ;
                        ; Note that this is separate from bit 3, which controls
                        ; whether clearing is enabled and which overrides the
                        ; above (bit 2 must be set for any clearing to take
                        ; place)

; ******************************************************************************
;
;       Name: ClearPlaneBuffers (Part 1 of 2)
;       Type: Subroutine
;   Category: Drawing the screen
;    Summary: Clear the nametable and pattern buffers of data that has already
;             been sent to the PPU, starting with the nametable buffer
;
; ------------------------------------------------------------------------------
;
; Arguments:
;
;   X                   The bitplane to clear
;
; ******************************************************************************

.pbuf1

 NOP                    ; This looks like code that has been removed
 NOP

.pbuf2

 SUBTRACT_CYCLES 39     ; Subtract 39 from the cycle count

.pbuf3

 RTS                    ; Return from the subroutine

.pbuf4

 ADD_CYCLES_CLC 126     ; Add 126 to the cycle count

 JMP pbuf13             ; Jump to pbuf13 in part 2 to consider clearing the
                        ; pattern buffer

.ClearPlaneBuffers

 LDA cycleCount+1       ; If the high byte of cycleCount(1 0) is zero, then the
 BEQ pbuf3              ; cycle count is 255 or less, so jump to pbuf3 to skip
                        ; the buffer clearing, as we have run out of cycles (we
                        ; will pick up where we left off in the next VBlank)

 LDA bitplaneFlags,X    ; If both bits 4 and 5 of the current bitplane flags are
 BIT flagsForClearing   ; clear, then this means:
 BEQ pbuf1              ; 
                        ;   * Bit 4 clear = we've not started sending data yet
                        ;   * Bit 5 clear = we have not yet sent all the data
                        ;
                        ; So we are not currently sending tile data to the PPU
                        ; for this bitplane, and we have not already sent the
                        ; data, so we do not need to clear this bitplane as we
                        ; only do so after sending its data to the PPU, which
                        ; we are not currently doing

 AND #%00001000         ; If bit 3 of the of the current bitplane flags is
 BEQ pbuf2              ; clear, then this bitplane is configured not to be
                        ; cleared after it has been sent to the PPU, so jump to
                        ; pbuf2 to return from the subroutine withough clearing
                        ; the buffers

                        ; If we get here then we are either in the process of
                        ; sending this bitplane's data to the PPU, or we have
                        ; already sent it, and the bitplane is configured to be
                        ; cleared
                        ;
                        ; If we have already sent the data to the PPU, then we
                        ; no longer need it, so we need to clear the buffers so
                        ; they are blank and ready to be drawn for the next
                        ; frame
                        ;
                        ; If we are still in the process of sending this
                        ; bitplane's data to the PPU, then we can clear the
                        ; buffers up to the point where we have sent the data,
                        ; as we don't need to keep any data that we have sent
                        ;
                        ; The following routine clears the buffers from the
                        ; first tile we sent, up to the tile numbers given by
                        ; sendingNameTile and sendingPattTile, which will work
                        ; in both cases, whether or not we have finished sending
                        ; all the data to the PPU

 SUBTRACT_CYCLES 213    ; Subtract 213 from the cycle count

 BMI pbuf5              ; If the result is negative, jump to pbuf5 to skip the
                        ; buffer clearing, as we have run out of cycles (we
                        ; will pick up where we left off in the next VBlank)

 JMP pbuf6              ; The result is positive, so we have enough cycles to
                        ; clear the buffers, so jump to pbuf6 to do just that

.pbuf5

 ADD_CYCLES 153         ; Add 153 to the cycle count

 JMP pbuf3              ; Jump to pbuf3 to skip the buffer clearing and return
                        ; from the subroutine

.pbuf6

 LDA clearingNameTile,X ; Set A to clearingNameTile for this bitplane, which we
                        ; set to the original value of firstNametableTile back
                        ; in SetupTilesForPPU, so A now contains the number of
                        ; the first tile, divided by 8, that we sent to the PPU
                        ; nametable for this bitplane
                        ;
                        ; So this contains the number of the first tile we need
                        ; to clear in the nametable buffer, divided by 8

 LDY sendingNameTile,X  ; Set Y to sendingNameTile for this bitplane, which we
                        ; used in SendNametableToPPU to keep track of the
                        ; current tile number as we sent them to the PPU
                        ; nametable, so this contains the number of the last
                        ; tile, divided by 8, that we sent to the PPU nametable
                        ; for this bitplane
                        ;
                        ; So this contains the number of the last tile we need
                        ; to clear in the nametable buffer, divided by 8

 CPY maxTileNumber      ; If Y >= maxTileNumber then set Y = maxTileNumber, so
 BCC pbuf7              ; Y has a maximum value of maxTileNumber
 LDY maxTileNumber

.pbuf7

 STY clearBlockSize     ; Set clearBlockSize to the number of the last tile we
                        ; need to clear, divided by 8

 CMP clearBlockSize     ; If A >= clearBlockSize, then the first tile we need to
 BCS pbuf4              ; clear is after the last tile we need to clear, which
                        ; means there are no nametable tiles to clear, so jump
                        ; to pbuf4 to move on to clearing the pattern buffer in
                        ; part 2

 LDY #0                 ; Set clearAddress(1 0) = (nameBufferHiAddr 0) + A * 8
 STY clearAddress+1     ;                  = (nameBufferHiAddr 0) + first tile
 ASL A                  ;
 ROL clearAddress+1     ; So clearAddress(1 0) contains the address of the first
 ASL A                  ; tile we sent in this bitplane's nametable buffer
 ROL clearAddress+1
 ASL A
 STA clearAddress
 LDA clearAddress+1
 ROL A
 ADC nameBufferHiAddr,X
 STA clearAddress+1

 LDA #0                 ; Set clearBlockSize(1 0) = (0 clearBlockSize) * 8
 ASL clearBlockSize     ;                           + (nameBufferHiAddr 0)
 ROL A                  ;                  = (nameBufferHiAddr 0) + last tile
 ASL clearBlockSize     ;
 ROL A                  ; So clearBlockSize(1 0) points to the address of the
 ASL clearBlockSize     ; last tile we sent in this bitplane's nametable buffer
 ROL A
 ADC nameBufferHiAddr,X
 STA clearBlockSize+1

 LDA clearBlockSize     ; Set clearBlockSize(1 0)
 SEC                    ;        = clearBlockSize(1 0) - clearAddress(1 0)
 SBC clearAddress       ;
 STA clearBlockSize     ; So clearBlockSize(1 0) contains the number of tiles we
 LDA clearBlockSize+1   ; already sent from this bitplane's nametable buffer
 SBC clearAddress+1     ;
 BCC pbuf8              ; If the subtraction underflows, then there are no tiles
 STA clearBlockSize+1   ; to send, so jump to pbuf8 to move on to clearing the
                        ; pattern buffer in part 2

                        ; By this point, clearBlockSize(1 0) contains the number
                        ; of tiles we sent from this bitplane's nametable
                        ; buffer, so it contains the number of nametable entries
                        ; we need to clear
                        ;
                        ; Also, clearAddress(1 0) contains the address of the
                        ; first tile we sent from this bitplane's nametable
                        ; buffer

 ORA clearBlockSize     ; If both the high and low bytes of clearBlockSize(1 0)
 BEQ pbuf9              ; are zero, then there are no tiles to clear, so jump to
                        ; pbuf9 and on to part 2 to consider clearing the
                        ; pattern buffer

 JSR ClearMemory        ; Call ClearMemory to zero clearBlockSize(1 0) nametable
                        ; entries from address clearAddress(1 0) onwards
                        ;
                        ; If we run out of cycles in the current VBlank, then
                        ; this may not clear the whole block, so it updates
                        ; clearBlockSize(1 0) and clearAddress(1 0) as it clears
                        ; so we can pick it up in the next VBlank

 LDA clearAddress+1     ; Set (A clearAddress)
 SEC                    ;     = clearAddress(1 0) - (nameBufferHiAddr 0)
 SBC nameBufferHiAddr,X

 LSR A                  ; Set A to the bottom byte of (A clearAddress) / 8
 ROR clearAddress       ;
 LSR A                  ; This effectively reverses the calculation we did
 ROR clearAddress       ; above, so A contains the number of the next tile
 LSR A                  ; we need to clear, as returned by ClearMemory, divided
 LDA clearAddress       ; by 8
 ROR A                  ;
                        ; We only need to take the low byte, as we know the high
                        ; byte will be zero after this many shifts, as that's
                        ; how we built the value of clearAddress(1 0) above

 CMP clearingNameTile,X ; If A >= clearingNameTile then we did manage to clear
 BCC pbuf12             ; some nametable entries in ClearMemory, so update the
 STA clearingNameTile,X ; value of clearingNameTile with the new first tile
                        ; number so the next call to this routine will pick up
                        ; where we left off

 JMP pbuf13             ; Jump to pbuf13 in part 2 to consider clearing the
                        ; pattern buffer

.pbuf8

 NOP                    ; This looks like code that has been removed
 NOP
 NOP
 NOP

.pbuf9

 ADD_CYCLES_CLC 28      ; Add 28 to the cycle count

 JMP pbuf13             ; Jump to pbuf13 in part 2 to consider clearing the
                        ; pattern buffer

.pbuf10

 ADD_CYCLES_CLC 126     ; Add 126 to the cycle count

.pbuf11

 RTS                    ; Return from the subroutine

; ******************************************************************************
;
;       Name: ClearPlaneBuffers (Part 2 of 2)
;       Type: Subroutine
;   Category: Drawing the screen
;    Summary: Clear the pattern buffer of data that has already been sent to the
;             PPU for the current bitplane
;
; ******************************************************************************

.pbuf12

 NOP                    ; This looks like code that has been removed
 NOP
 NOP

.pbuf13

 SUBTRACT_CYCLES 187    ; Subtract 187 from the cycle count

 BMI pbuf14             ; If the result is negative, jump to pbuf14 to skip the
                        ; pattern buffer clearing, as we have run out of cycles
                        ; (we will pick up where we left off in the next VBlank)

 JMP pbuf15             ; The result is positive, so we have enough cycles to
                        ; clear the pattern buffer, so jump to pbuf15 to do just
                        ; that

.pbuf14

 ADD_CYCLES 146         ; Add 146 to the cycle count

 JMP pbuf11             ; Jump to pbuf11 to return from the subroutine

.pbuf15

 LDA clearingPattTile,X ; Set A to clearingPattTile for this bitplane, which we
                        ; set to the original value of firstPatternTile back in
                        ; SetupTilesForPPU, so A now contains the number of the
                        ; first tile, that we sent to the PPU pattern table for
                        ; this bitplane
                        ;
                        ; So this contains the number of the first tile we need
                        ; to clear in the pattern buffer

 LDY sendingPattTile,X  ; Set Y to sendingPattTile for this bitplane, which we
                        ; used in SendPatternsToPPU to keep track of the current
                        ; tile number as we sent them to the PPU pattern table,
                        ; so this contains the number of the last tile that we
                        ; sent to the PPU pattern table for this bitplane
                        ;
                        ; So this contains the number of the last tile we need
                        ; to clear in the nametable buffer

 STY clearBlockSize     ; Set clearBlockSize to the number of the last tile we
                        ; need to clear

 CMP clearBlockSize     ; If A >= clearBlockSize, then the first tile we need to
 BCS pbuf10             ; clear is after the last tile we need to clear, which
                        ; means there are no nametable tiles to clear, so jump
                        ; to pbuf10 to return from the subroutine

 NOP                    ; This looks like code that has been removed

 LDY #0                 ; Set clearAddress(1 0) = (pattBufferHiAddr 0) + A * 8
 STY clearAddress+1     ;                  = (pattBufferHiAddr 0) + first tile
 ASL A                  ;
 ROL clearAddress+1     ; So clearAddress(1 0) contains the address of the first
 ASL A                  ; tile we sent in this bitplane's pattern buffer
 ROL clearAddress+1
 ASL A
 STA clearAddress
 LDA clearAddress+1
 ROL A
 ADC pattBufferHiAddr,X
 STA clearAddress+1

 LDA #0                 ; Set clearBlockSize(1 0) = (0 clearBlockSize) * 8
 ASL clearBlockSize     ;                           + (pattBufferHiAddr 0)
 ROL A                  ;                  = (pattBufferHiAddr 0) + last tile
 ASL clearBlockSize     ;
 ROL A                  ; So clearBlockSize(1 0) points to the address of the
 ASL clearBlockSize     ; last tile we sent in this bitplane's pattern buffer
 ROL A
 ADC pattBufferHiAddr,X
 STA clearBlockSize+1

 LDA clearBlockSize     ; Set clearBlockSize(1 0)
 SEC                    ;        = clearBlockSize(1 0) - clearAddress(1 0)
 SBC clearAddress       ;
 STA clearBlockSize     ; So clearBlockSize(1 0) contains the number of tiles we
 LDA clearBlockSize+1   ; already sent from this bitplane's pattern buffer
 SBC clearAddress+1
 BCC pbuf16
 STA clearBlockSize+1
 ORA clearBlockSize
 BEQ pbuf17

 JSR ClearMemory        ; Call ClearMemory to zero clearBlockSize(1 0) pattern
                        ; buffer bytes from address clearAddress(1 0) onwards

 LDA clearAddress+1     ; Set (A clearAddress)
 SEC                    ;     = clearAddress(1 0) - (pattBufferHiAddr 0)
 SBC pattBufferHiAddr,X

 LSR A                  ; Set A to the bottom byte of (A clearAddress) / 8
 ROR clearAddress       ;
 LSR A                  ; This effectively reverses the calculation we did
 ROR clearAddress       ; above, so A contains the number of the next tile
 LSR A                  ; we need to clear, as returned by ClearMemory, divided
 LDA clearAddress       ; by 8
 ROR A                  ;
                        ; We only need to take the low byte, as we know the high
                        ; byte will be zero after this many shifts, as that's
                        ; how we built the value of clearAddress(1 0) above

 CMP clearingPattTile,X ; If A >= clearingPattTile then we did manage to clear
 BCC pbuf16             ; some pattern bytes in ClearMemory, so update the
 STA clearingPattTile,X ; value of clearingPattTile with the new first tile
                        ; number so the next call to this routine will pick up
                        ; where we left off

 RTS                    ; Return from the subroutine

.pbuf16

 NOP                    ; This looks like code that has been removed
 NOP
 NOP
 NOP

 RTS                    ; Return from the subroutine

.pbuf17

 ADD_CYCLES_CLC 35      ; Add 35 to the cycle count

 RTS                    ; Return from the subroutine

; ******************************************************************************
;
;       Name: FillMemory
;       Type: Subroutine
;   Category: Utility routines
;    Summary: Fill a block of memory with a specified value
;
; ------------------------------------------------------------------------------
;
; When called directly, this routine fills a whole page of memory (256 bytes)
; with the value in A.
;
; It can also be called at an arbitrary entry point to fill a specified number
; of locations, anywhere from 0 to 255 bytes. The entry point is calculated as
; as an offset backwards from the end of the FillMemory32Bytes routine (which
; ends at ClearMemory), such that jumping to this entry point will fill the
; required number of bytes. Each FILL_MEMORY macro call takes up three bytes
; (two bytes for the STA (clearAddress),Y and one for the INY), so the
; calculation is essentially:
;
;   ClearMemory - 1 - (3 * clearBlockSize)
;
; where clearBlockSize is the size of the block to clear, in bytes. See the
; ClearMemory routine for an example of this calculation in action.
;
; Arguments:
;
;   clearAddress(1 0)   The base address of the block of memory to fill
;
;   Y                   The index into clearAddress(1 0) from which to fill
;
;   A                   The value to fill
;
; Returns:
;
;   Y                   The index in Y is updated to point to the byte after the
;                       filled block
;
; ******************************************************************************

.FillMemory

 FILL_MEMORY 224        ; Fill 224 bytes at clearAddress(1 0) + Y with A

                        ; Falling through into FillMemory32Bytes to fill another
                        ; 32 bytes, bringing the total to 256

; ******************************************************************************
;
;       Name: FillMemory32Bytes
;       Type: Subroutine
;   Category: Utility routines
;    Summary: Fill a 32-byte block of memory with a specified value
;
; ------------------------------------------------------------------------------
;
; Arguments:
;
;   clearAddress(1 0)   The base address of the block of memory to fill
;
;   Y                   The index into clearAddress(1 0) from which to fill
;
;   A                   The value to fill
;
; Returns:
;
;   Y                   The index in Y is updated to point to the byte after the
;                       filled block
;
; ******************************************************************************

.FillMemory32Bytes

 FILL_MEMORY 32         ; Fill 32 bytes at clearAddress(1 0) + Y with A

 RTS                    ; Return from the subroutine

; ******************************************************************************
;
;       Name: ClearMemory
;       Type: Subroutine
;   Category: Utility routines
;    Summary: Clear a block of memory, split across multiple calls if required
;
; ------------------------------------------------------------------------------
;
; This routine clears a block of memory, but only if there are enough cycles in
; the cycle count. If it runs out of cycles, it will pick up where it left off
; when called again.
;
; Arguments:
;
;   clearAddress        The address of the block to clear
;
;   clearBlockSize      The size of the block to clear as a 16-bit number, must
;                       be a multiple of 8 bytes
;
; Returns:
;
;   clearAddress        The address of the next byte to clear in the block,
;                       ready for the next call (if the whole block was not
;                       cleared)
;
;   clearBlockSize      The size of the block, reduced by the number of bytes
;                       cleared in the current call, so it's ready for the next
;                       call (this will be 0 if this call cleared the whole
;                       block)
;
; ******************************************************************************

.ClearMemory

 LDA clearBlockSize+1   ; If the high byte of the block size is zero, then jump
 BEQ cmem8              ; to cmem8 to clear a block of fewer than 256 bytes

                        ; If we get here then the high byte of the block size is
                        ; non-zero, so the block we need to clear consists of
                        ; one or more page-sized blocks (i.e. 256-byte blocks),
                        ; as well as one block with fewer than 256 bytes
                        ;
                        ; We now concentrate on clearing the page-sized blocks,
                        ; leaving the block with fewer than 256 bytes for the
                        ; next VBlank

                        ; First we consider whether we can clear a block of 256
                        ; bytes

 SUBTRACT_CYCLES 2105   ; Subtract 2105 from the cycle count

 BMI cmem1              ; If the result is negative, jump to cmem1 to consider
                        ; clearing a 32-byte block in this VBlank, as we don't
                        ; have enough cycles for a 256-byte block

 JMP cmem2              ; The result is positive, so we have enough cycles to
                        ; clear a 256-byte block in this VBlank, so jump to
                        ; cmem2 to do just that

.cmem1

 ADD_CYCLES 2059        ; Add 2059 to the cycle count

 JMP cmem3              ; Jump to cmem3 to consider clearing the block with
                        ; fewer than 256 bytes

.cmem2

 LDA #0                 ; Set A = 0 so the call to FillMemory zeroes the memory
                        ; block

 LDY #0                 ; Set an index in Y to pass to FillMemory, so we start
                        ; clearing memory from clearAddress(1 0) onwards

 JSR FillMemory         ; Call FillMemory to clear a whole 256-byte block of
                        ; memory at clearAddress(1 0)

 DEC clearBlockSize+1   ; Decrement the high byte of clearBlockSize(1 0), which
                        ; is the same as subtracting 256, as we just cleared 256
                        ; bytes of memory

 INC clearAddress+1     ; Increment the high byte of clearAddress(1 0) to point
                        ; at the next 256-byte block of memory after the block
                        ; we just cleared, so we clear that next

 JMP ClearMemory        ; Jump back to ClearMemory to consider clearing the next
                        ; 256 bytes of memory

.cmem3

                        ; If we get here then we did not have enough cycles to
                        ; send a 256-byte block

                        ; Now we consider whether we can clear a block of 32
                        ; bytes

 SUBTRACT_CYCLES 318    ; Subtract 318 from the cycle count

 BMI cmem4              ; If the result is negative, jump to cmem4 to skip
                        ; clearing the next 32-byte block in this VBlank, as we
                        ; have run out of cycles (we will pick up where we left
                        ; off in the next VBlank)

 JMP cmem5              ; The result is positive, so we have enough cycles to
                        ; clear the next 32-byte block in this VBlank, so jump
                        ; to cmem5 to do just that

.cmem4

 ADD_CYCLES 277         ; Add 277 to the cycle count

 JMP cmem7              ; Jump to cmem7 to return from the subroutine

.cmem5

 LDA #0                 ; Set A = 0 so the call to FillMemory zeroes the memory
                        ; block

 LDY #0                 ; Set an index in Y to pass to FillMemory, so we start
                        ; clearing memory from clearAddress(1 0) onwards

 JSR FillMemory32Bytes  ; Call FillMemory to clear 32 bytes of memory from
                        ; clearAddress(1 0) to clearAddress(1 0) + 31

 LDA clearAddress       ; Set clearAddress(1 0) = clearAddress(1 0) + 32
 CLC                    ;
 ADC #32                ; So it points at the next memory location to clear
 STA clearAddress       ; after the block we just cleared
 LDA clearAddress+1
 ADC #0
 STA clearAddress+1

 JMP cmem3              ; Jump back to cmem3 to consider clearing the next 32
                        ; bytes of memory, which we can keep doing until we run
                        ; out of cycles because we only get here if we don't
                        ; have enough cycles for a 256-byte block, so the cycles
                        ; will run out before we manage to clear eight blocks of
                        ; 32 bytes

.cmem6

 ADD_CYCLES_CLC 132     ; Add 132 to the cycle count

.cmem7

 RTS                    ; Return from the subroutine

.cmem8

                        ; If we get here then we need to clear a block of fewer
                        ; than 256 bytes

 SUBTRACT_CYCLES 186    ; Subtract 186 from the cycle count

 BMI cmem9              ; If the result is negative, jump to cmem9 to skip
                        ; clearing the block in this VBlank, as we have run out
                        ; of cycles (we will pick up where we left off in the
                        ; next VBlank)

 JMP cmem10             ; The result is positive, so we have enough cycles to
                        ; clear the block in this VBlank, so jump to cmem10
                        ; to do just that

.cmem9

 ADD_CYCLES 138         ; Add 138 to the cycle count

 JMP cmem7              ; Jump to cmem7 to return from the subroutine

.cmem10

 LDA clearBlockSize     ; Set A to the size of the block we need to clear, which
                        ; is in the low byte of clearBlockSize(1 0) (as we only
                        ; get here when the high byte of clearBlockSize(1 0) is
                        ; zero)

 BEQ cmem6              ; If the block size is zero, then there are no bytes to
                        ; clear, so jump to cmem6 to return from the subroutine

 LSR A                  ; Set A = clearBlockSize / 16
 LSR A
 LSR A
 LSR A

 CMP cycleCount+1       ; If A >= high byte of cycleCount(1 0), then:
 BCS cmem12             ;
                        ;   clearBlockSize / 16 >= cycleCount(1 0) / 256
                        ;
                        ; so:
                        ;
                        ;   clearBlockSize >= cycleCount(1 0) / 16
                        ;
                        ; If clearing each byte takes up to 16 cycles, then this
                        ; means we can't clear the whole block in this VBlank,
                        ; as we don't have enough cycles, so jump to cmem12 to
                        ; consider clearing it in blocks of 32 bytes rather than
                        ; all at once
                        ;
                        ; (I don't know why this calculation counts 16 cycles
                        ; per byte, as it only takes 8 cycles for FILL_MEMORY
                        ; to clear a byte; perhaps it's an overestimation to be
                        ; safe and cater for all this extra logic code?) ???

                        ; If we get here then we can clear the block of memory
                        ; in one go

                        ; First we subtract the number of cycles that we need to
                        ; clear the memory block from the cycle count
                        ;
                        ; Each call to the FILL_MEMORY macro takes 8 cycles (6
                        ; for the STA (clearAddress),Y instruction and 2 for the
                        ; INY instruction), so the total number of cycles we
                        ; will take will be clearBlockSize(1 0) * 8, so that's
                        ; what we subtract from the cycle count

 LDA #0                 ; Set the high byte of clearBlockSize(1 0) = 0 (though
 STA clearBlockSize+1   ; this should already be the case)

 LDA clearBlockSize     ; Set (A clearBlockSize+1) = clearBlockSize(1 0)

 ASL A                  ; Set (A clearBlockSize+1) = (A clearBlockSize+1) * 8
 ROL clearBlockSize+1   ;                          = clearBlockSize(1 0) * 8
 ASL A
 ROL clearBlockSize+1
 ASL A
 ROL clearBlockSize+1

 EOR #$FF               ; Set cycleCount(1 0) = cycleCount(1 0)
 SEC                    ;                        + ~(A clearBlockSize+1) + 1
 ADC cycleCount         ;
 STA cycleCount         ;   = cycleCount(1 0) - (A clearBlockSize+1)
 LDA clearBlockSize+1   ;   = cycleCount(1 0) - clearBlockSize(1 0) * 8
 EOR #$FF
 ADC cycleCount+1
 STA cycleCount+1

                        ; Next we calculate the entry point into the FillMemory
                        ; routine that will fill clearBlockSize(1 0) bytes of
                        ; memory
                        ;
                        ; FillMemory consists of 256 sequential FILL_MEMORY
                        ; macros, each of which fills one byte, as follows:
                        ;
                        ;   STA (clearAddress),Y
                        ;   INY
                        ;
                        ; The first instruction takes up two bytes while the INY
                        ; takes up one, so each byte that FillMemory fills takes
                        ; up three bytes of instruction memory
                        ;
                        ; The FillMemory routine ends with an RTS, and is
                        ; followed by the ClearMemory routine, so we can work
                        ; out the entry point for filling clearBlockSize bytes
                        ; as follows:
                        ;
                        ;   ClearMemory - 1 - (3 * clearBlockSize)
                        ;
                        ; The 1 is for the RTS, and each of the byte fills has
                        ; three instructions
                        ;
                        ; So this is what we calculate next

 LDY #0                 ; Set an index in Y to pass to FillMemory (which we call
                        ; via the JMP (clearBlockSize) instruction below, so we
                        ; start clearing memory from clearAddress(1 0) onwards

 STY clearBlockSize+1   ; Set the high byte of clearBlockSize(1 0) = 0 

 LDA clearBlockSize     ; Store the size of the memory block that we want to
 PHA                    ; clear on the stack, so we can retrieve it below

 ASL A                  ; Set clearBlockSize(1 0)
 ROL clearBlockSize+1   ;        = clearBlockSize(1 0) * 2 + clearBlockSize(1 0)
 ADC clearBlockSize     ;        = clearBlockSize(1 0) * 3
 STA clearBlockSize     ;
 LDA clearBlockSize+1   ; So clearBlockSize(1 0) contains the block size * 3
 ADC #0
 STA clearBlockSize+1

                        ; At this point the C flag is clear, as the high byte
                        ; addition will never overflow, so this means the SBC
                        ; in the following will subtract an extra 1

 LDA #LO(ClearMemory)   ; Set clearBlockSize(1 0)
 SBC clearBlockSize     ;        = ClearMemory - clearBlockSize(1 0) - 1
 STA clearBlockSize     ;        = ClearMemory - (block size * 3) - 1
 LDA #HI(ClearMemory)   ;
 SBC clearBlockSize+1   ; So clearBlockSize(1 0) is the address of the entry
 STA clearBlockSize+1   ; point in FillMemory that fills clearBlockSize(1 0)
                        ; bytes with zero, and we can now call it with this
                        ; instruction:
                        ;
                        ;   JMP (clearBlockSize)
                        ;
                        ; So calling cmem11 below will fill memory with the
                        ; value of A, for clearBlockSize(1 0) bytes from
                        ; clearAddress(1 0) + Y onwards
                        ;
                        ; We already set Y to 0 above, so it will start filling
                        ; from clearAddress(1 0) onwards

 LDA #0                 ; Set A = 0 so the call to FillMemory via the
                        ; JMP (clearBlockSize) instruction zeroes the memory
                        ; block

 JSR cmem11             ; Jump to cmem11 to call the correct entry point in
                        ; FillMemory to clear the memory block, returning here
                        ; when it's done

 PLA                    ; Set A to the size of the memory block that we want to
                        ; clear, which we stored on the stack above

 CLC                    ; Set clearAddress(1 0) = clearAddress(1 0) + A
 ADC clearAddress       ;
 STA clearAddress       ; So it points at the next memory location to clear
 LDA clearAddress+1     ; after the block we just cleared
 ADC #0
 STA clearAddress+1

 RTS                    ; Return from the subroutine

.cmem11

 JMP (clearBlockSize)   ; We set up clearBlockSize(1 0) to point to the entry
                        ; point in FillMemory that will fill the correct number
                        ; of bytes with zero, so this clears our memory block
                        ; and returns to the PLA above using a tail call

.cmem12

                        ; If we get here then we need to consider clearing the
                        ; memory in blocks of 32 bytes rather than all at once

 ADD_CYCLES_CLC 118     ; Add 118 to the cycle count

.cmem13

 SUBTRACT_CYCLES 321    ; Subtract 321 from the cycle count

 BMI cmem14             ; If the result is negative, jump to cmem14 to skip
                        ; clearing the block in this VBlank, as we have run out
                        ; of cycles (we will pick up where we left off in the
                        ; next VBlank)

 JMP cmem15             ; The result is positive, so we have enough cycles to
                        ; clear the block in this VBlank, so jump to cmem15
                        ; to do just that

.cmem14

 ADD_CYCLES 280         ; Add 280 to the cycle count

 JMP cmem16             ; Jump to cmem16 to return from the subroutine

.cmem15

 LDA clearBlockSize     ; Set A = clearBlockSize - 32
 SEC
 SBC #32

 BCC cmem17             ; If the subtraction underflowed, then we need to clear
                        ; fewer than 32 bytes (as clearBlockSize < 32), so jump
                        ; to cmem17 to do just that

 STA clearBlockSize     ; Set clearBlockSize - 32 = A
                        ;                         = clearBlockSize - 32
                        ;
                        ; So clearBlockSize(1 0) is updated with the new block
                        ; size, as we are about to clear 32 bytes

 LDA #0                 ; Set A = 0 so the call to FillMemory32Bytes zeroes the
                        ; memory block

 LDY #0                 ; Set an index in Y to pass to FillMemory32Bytes, so we
                        ; start clearing memory from clearAddress(1 0) onwards

 JSR FillMemory32Bytes  ; Call FillMemory32Bytes to clear a 32-byte block of
                        ; memory at clearAddress(1 0)

 LDA clearAddress       ; Set clearAddress(1 0) = clearAddress(1 0) + 32
 CLC                    ;
 ADC #32                ; So it points at the next memory location to clear
 STA clearAddress       ; after the block we just cleared
 BCC cmem13
 INC clearAddress+1

 JMP cmem13             ; Jump back to cmem13 to consider clearing the next 32
                        ; bytes of memory

.cmem16

 RTS                    ; Return from the subroutine

.cmem17

                        ; If we get here then we need to clear fewer than 32
                        ; bytes of memory

 ADD_CYCLES_CLC 269     ; Add 269 to the cycle count

.cmem18

 SUBTRACT_CYCLES 119    ; Subtract 119 from the cycle count

 BMI cmem19             ; If the result is negative, jump to cmem19 to skip
                        ; clearing the block in this VBlank, as we have run out
                        ; of cycles (we will pick up where we left off in the
                        ; next VBlank)

 JMP cmem20             ; The result is positive, so we have enough cycles to
                        ; clear the block in this VBlank, so jump to cmem20
                        ; to do just that

.cmem19

 ADD_CYCLES 78          ; Add 78 to the cycle count

 JMP cmem16             ; Jump to cmem16 to return from the subroutine

.cmem20

 LDA clearBlockSize     ; Set A = clearBlockSize - 8
 SEC
 SBC #8

 BCC cmem22             ; If the subtraction underflowed, then we need to clear
                        ; fewer than 8 bytes (as clearBlockSize < 8), so jump
                        ; to cmem22 to return from the subroutine, as this means
                        ; we have filled the whole block (as we only clear
                        ; memory blocks in multiples of 8 bytes)

 STA clearBlockSize     ; Set clearBlockSize - 8 = A
                        ;                         = clearBlockSize - 8
                        ;
                        ; So clearBlockSize(1 0) is updated with the new block
                        ; size, as we are about to clear 8 bytes

 LDA #0                 ; Set A = 0 so the FILL_MEMORY macro zeroes the memory
                        ; block

 LDY #0                 ; Set an index in Y to pass to the FILL_MEMORY macro, so
                        ; we start clearing memory from clearAddress(1 0)
                        ; onwards

 FILL_MEMORY 8          ; Fill eight bytes at clearAddress(1 0) + Y with A, so
                        ; this zeroes eight bytes at clearAddress(1 0) and
                        ; increments the index counter in Y

 LDA clearAddress       ; Set clearAddress(1 0) = clearAddress(1 0) + 8
 CLC                    ;
 ADC #8                 ; So it points at the next memory location to clear
 STA clearAddress       ; after the block we just cleared
 BCC cmem21
 INC clearAddress+1

.cmem21

 JMP cmem18             ; Jump back to cmem18 to consider clearing the next 8
                        ; bytes of memory

.cmem22

 ADD_CYCLES_CLC 66      ; Add 66 to the cycle count

 RTS                    ; Return from the subroutine

; ******************************************************************************
;
;       Name: WaitForPPUToFinish
;       Type: Subroutine
;   Category: Drawing the screen
;    Summary: Wait until the NMI handler has finished updating both bitplanes,
;             so the screen is no longer refreshing
;
; ******************************************************************************

.WaitForPPUToFinish

 SETUP_PPU_FOR_ICON_BAR ; If the PPU has started drawing the icon bar, configure
                        ; the PPU to use nametable 0 and pattern table 0

 LDA bitplaneFlags      ; Keep looping back to the start of the routine until
 AND #%01000000         ; bit 6 of the bitplane flags for bitplane 0 is clear
 BNE WaitForPPUToFinish

 LDA bitplaneFlags+1    ; Do the same for bitplane 1
 AND #%01000000
 BNE WaitForPPUToFinish

                        ; We get here when both bitplanes have bit 6 clear,
                        ; which means neither bitplane is configured to send
                        ; nametable data to the PPU
                        ;
                        ; This means the screen has finished refreshing and
                        ; there is no longer any nametable data that needs
                        ; sending to the PPU, so we can return from the
                        ; subroutine

 RTS                    ; Return from the subroutine

; ******************************************************************************
;
;       Name: FlipDrawingPlane
;       Type: Subroutine
;   Category: Drawing the screen
;    Summary: Flip the drawing bitplane
;
; ******************************************************************************

.FlipDrawingPlane

 LDA drawingBitplane    ; Set X to the opposite bitplane to the current drawing
 EOR #1                 ; bitplane
 TAX

 JSR SetDrawingBitplane ; Set X as the new drawing bitplane, so this effectively
                        ; flips the drawing bitplane between 0 and 1

 JMP ClearDrawingPlane  ; Jump to ClearDrawingPlane to clear the buffers for the
                        ; new drawing bitplane, returning from the subroutine
                        ; using a tail call

; ******************************************************************************
;
;       Name: SetDrawingBitplane
;       Type: Subroutine
;   Category: Drawing the screen
;    Summary: Set the drawing bitplane to a specified value
;
; ------------------------------------------------------------------------------
;
; Arguments:
;
;   X                   The new value of the drawing bitplane
;
; ******************************************************************************

.SetDrawingBitplane

 STX drawingBitplane    ; Set the drawing bitplane to X

 LDA nextTileNumber,X   ; Set the next free tile number in tileNumber to the
 STA tileNumber         ; next free tile number for the new bitplane

 LDA nameBufferHiAddr,X ; Set the high byte of the nametable buffer for the new
 STA nameBufferHi       ; bitplane in nameBufferHiAddr

 LDA #0                 ; Set the low byte of pattBufferAddr(1 0) to zero (we
 STA pattBufferAddr     ; will set the high byte in SetPatternBuffer below

 STA drawingPlaneDebug  ; Set drawingPlaneDebug = 0 (though this value is never
                        ; read, so this has no effect)

                        ; Fall through into SetPatternBuffer to set the high
                        ; bytes of the patten buffer address variables

; ******************************************************************************
;
;       Name: SetPatternBuffer
;       Type: Subroutine
;   Category: Drawing the screen
;    Summary: Set the high byte of the pattern buffer address variables
;
; ------------------------------------------------------------------------------
;
; Arguments:
;
;   X                   The bitplane whose pattern address we should use
;
; ******************************************************************************

.SetPatternBuffer

 LDA pattBufferHiAddr,X ; Set the high byte of pattBufferAddr(1 0) to the
 STA pattBufferAddr+1   ; correct address for the pattern buffer for bitplane X

 LSR A                  ; Set pattBufferHiDiv8 to the high byte of the pattern
 LSR A                  ; buffer address, divided by 8
 LSR A
 STA pattBufferHiDiv8

 RTS                    ; Return from the subroutine

; ******************************************************************************
;
;       Name: CopySmallBlock
;       Type: Subroutine
;   Category: Utility routines
;    Summary: Copy a small number of pages in memory
;
; ------------------------------------------------------------------------------
;
; Arguments:
;
;   V(1 0)              Source address
;
;   SC(1 0)             Destination address
;
;   X                   Number of pages of memory to copy
;
; ******************************************************************************

.CopySmallBlock

 LDY #0                 ; Set an index counter in Y

.cops1

 LDA (V),Y              ; Copy the Y-th byte from V(1 0) to SC(1 0)
 STA (SC),Y

 DEY                    ; Decrement the index counter

 BNE cops1              ; Loop back until we have copied a whole page of bytes

 INC V+1                ; Increment the high bytes of V(1 0) and SC(1 0) to
 INC SC+1               ; point to the next page in memory

 DEX                    ; Decrement the page counter

 BNE cops1              ; Loop back until we have copied X pages of memory

 RTS                    ; Return from the subroutine

; ******************************************************************************
;
;       Name: CopyLargeBlock
;       Type: Subroutine
;   Category: Utility routines
;    Summary: Copy a large number of pages in memory
;
; ------------------------------------------------------------------------------
;
; Arguments:
;
;   SC2(1 0)            Source address
;
;   SC(1 0)             Destination address
;
;   V                   The number of pages top copy in each set
;
;   V+1                 The number of sets, so we copy V * V+1 pages
;
;   X                   Number of pages of memory to copy
;
; ******************************************************************************

.CopyLargeBlock

 LDY #0                 ; Set an index counter in Y

 INC V                  ; Increment the page counter in V so we can use a BNE
                        ; below to copy V pages

 INC V+1                ; Increment the page counter in V+1 so we can use a BNE
                        ; below to copy V+1 sets of V pages

.copl1

 LDA (SC2),Y            ; Copy the Y-th byte from SC2(1 0) to SC(1 0)
 STA (SC),Y

 INY                    ; Increment the index counter

 BNE copl2              ; If we haven't reached the end of the page, jump to
                        ; copl2 to skip the following

 INC SC+1               ; Increment the high bytes of SC(1 0) and SC2(1 0) to
 INC SC2+1              ; point to the next page in memory

.copl2

 DEC V                  ; Loop back to repeat the above until we have copied V
 BNE copl1              ; pages

 DEC V+1                ; Loop back to repeat the above until we have copied V+1
 BNE copl1              ; sets of V pages

 RTS                    ; Return from the subroutine

; ******************************************************************************
;
;       Name: WaitFor3xVBlank
;       Type: Subroutine
;   Category: Utility routines
;    Summary: Wait for three VBlanks to pass
;
; ******************************************************************************

.WaitFor3xVBlank

 LDA PPU_STATUS         ; Read the PPU_STATUS register, which clear the VBlank
                        ; latch in bit 7, so the following loops will wait for
                        ; three VBlanks in total

.wait1

 LDA PPU_STATUS         ; Wait for the first VBlank to pass, which will set bit
 BPL wait1              ; 7 of PPU_STATUS (and reading PPU_STATUS clears bit 7,
                        ; ready for the next VBlank)

.wait2

 LDA PPU_STATUS         ; Wait for the second VBlank to pass
 BPL wait2

                        ; Fall through into WaitForVBlank to wait for the third
                        ; VBlank before returning from the subroutine

; ******************************************************************************
;
;       Name: WaitForVBlank
;       Type: Subroutine
;   Category: Utility routines
;    Summary: Wait for the next VBlank to pass
;
; ******************************************************************************

.WaitForVBlank

 LDA PPU_STATUS         ; Wait for the next VBlank to pass
 BPL WaitForVBlank

 RTS                    ; Return from the subroutine

; ******************************************************************************
;
;       Name: PlayMusicAtVBlank
;       Type: Subroutine
;   Category: Sound
;    Summary: Wait for the next VBlank and play the background music
;
; ------------------------------------------------------------------------------
;
; Returns:
;
;   X                   X is preserved
;
; ******************************************************************************

.PlayMusicAtVBlank

 TXA                    ; Store X on the stack, so we can retrieve it below
 PHA

 JSR WaitForVBlank      ; Wait for the next VBlank to pass

 JSR PlayMusic_b6       ; Call the PlayMusic routine to play the background
                        ; music

 PLA                    ; Restore X from the stack so it is unchanged
 TAX

 RTS                    ; Return from the subroutine

; ******************************************************************************
;
;       Name: DrawMessageInNMI
;       Type: Subroutine
;   Category: Drawing the screen
;    Summary: Configure the NMI to send the portion of the screen that contains
;             the in-flight message to the PPU (i.e. tile rows 22 to 24)
;
; ******************************************************************************

.DrawMessageInNMI

 JSR WaitForPPUToFinish ; Wait until both bitplanes of the screen have been
                        ; sent to the PPU, so the screen is fully updated and
                        ; there is no more data waiting to be sent to the PPU

 LDA tileNumber         ; Set nextTileNumber to the number of the next free tile
 STA nextTileNumber     ; for use in the NMI handler
 STA nextTileNumber+1

 LDA #88                ; Tell the PPU to start sending nametable entries from
 STA firstNametableTile ; tile 88 * 8 = 704 onwards (i.e. from the start of row
                        ; tile row 22)

 LDA #100               ; Tell the PPU to send nametable entries up to tile
 STA lastTileNumber     ; 100 * 8 = 800 (i.e. to the end of tile row 24)
 STA lastTileNumber+1

 LDA #%11000100         ; Set both bitplane flags as follows:
 STA bitplaneFlags      ;
 STA bitplaneFlags+1    ;   * Bit 2 set   = send tiles until the end of buffer
                        ;   * Bit 3 clear = don't clear buffers after sending
                        ;   * Bit 4 clear = we've not started sending data yet
                        ;   * Bit 5 clear = we have not yet sent all the data
                        ;   * Bit 6 set   = send both pattern and nametable data
                        ;   * Bit 7 set   = send data to the PPU
                        ;
                        ; Bits 0 and 1 are ignored and are always clear

 JMP WaitForPPUToFinish ; Wait until both bitplanes of the screen have been
                        ; sent to the PPU, so the screen is fully updated and
                        ; there is no more data waiting to be sent to the PPU,
                        ; and return from the subroutine using a tail call

; ******************************************************************************
;
;       Name: DrawShipInBitplane
;       Type: Subroutine
;   Category: Drawing ships
;    Summary: Flip the drawing bitplane and draw the current ship in the newly
;             flipped bitplane
;
; ******************************************************************************

.DrawShipInBitplane

 JSR FlipDrawingPlane   ; Flip the drawing bitplane

 JSR LL9_b1             ; Draw the current ship into the newly flipped drawing
                        ; bitplane

                        ; Fall through into DrawBitplaneInNMI to configure the
                        ; NMI to send the drawing bitplane to the PPU

; ******************************************************************************
;
;       Name: DrawBitplaneInNMI
;       Type: Subroutine
;   Category: Drawing the screen
;    Summary: Configure the NMI to send the drawing bitplane to the PPU after
;             drawing the box edges and setting the next free tile number
;
; ******************************************************************************

.DrawBitplaneInNMI

 LDA #%11001000         ; Set A so we set the drawing bitplane flags in
                        ; SetDrawPlaneFlags as follows:
                        ;
                        ;   * Bit 2 clear = last tile to send is lastTileNumber
                        ;   * Bit 3 set   = clear buffers after sending data
                        ;   * Bit 4 clear = we've not started sending data yet
                        ;   * Bit 5 clear = we have not yet sent all the data
                        ;   * Bit 6 set   = send both pattern and nametable data
                        ;   * Bit 7 set   = send data to the PPU
                        ;
                        ; Bits 0 and 1 are ignored and are always clear

                        ; Fall through into SetDrawPlaneFlags to set the
                        ; bitplane flags, draw the box edges and set the next
                        ; free tile number

; ******************************************************************************
;
;       Name: SetDrawPlaneFlags
;       Type: Subroutine
;   Category: Drawing the screen
;    Summary: Set the drawing bitplane flags to the specified value, draw the
;             box edges and set the next free tile number
;
; ******************************************************************************

.SetDrawPlaneFlags

 PHA                    ; Store A on the stack, so we can retrieve them below
                        ; when setting the new drawing bitplane flags

 JSR DrawBoxEdges       ; Draw the left and right edges of the box along the
                        ; sides of the screen, drawing into the nametable buffer
                        ; for the drawing bitplane

 LDX drawingBitplane    ; Set X to the drawing bitplane

 LDA tileNumber         ; Set the next free tile number for the drawing bitplane
 STA nextTileNumber,X   ; to the next free tile number in tileNumber

 PLA                    ; Retrieve A from the stack and set it as the value of
 STA bitplaneFlags,X    ; the drawing bitplane flags

 RTS                    ; Return from the subroutine

; ******************************************************************************
;
;       Name: SendMissilesToPPU
;       Type: Subroutine
;   Category: Drawing the screen
;    Summary: Send X batches of 16 bytes from SC(1 0) to the PPU
;
; ------------------------------------------------------------------------------
;
; Arguments:
;
;   X                   The number of batches of 16 bytes to send to the PPU
;
;   SC(1 0)             The address of the data to send
;
; ******************************************************************************

.SendMissilesToPPU

 LDY #0                 ; Set Y as an index counter for the following block,
                        ; which sends 16 bytes of data from SC(1 0) to the PPU,
                        ; using Y as an index that starts at 0 and increments
                        ; after each byte
                        ;
                        ; We repeat this process for X iterations

                        ; We repeat the following code 16 times, so it sends
                        ; one whole pattern of 16 bytes to the PPU (eight bytes
                        ; for each bitplane)

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

 LDA SC                 ; Set SC(1 0) = SC(1 0) + 16
 CLC                    ;
 ADC #16                ; Starting with the low bytes
 STA SC

 BCC smis1              ; And then the high bytes
 INC SC+1

.smis1

 DEX                    ; Decrement the block counter in X

 BNE SendMissilesToPPU  ; Loop back to the start of the subroutine until we have
                        ; sent X batches of 16 bytes

 RTS                    ; Return from the subroutine

; ******************************************************************************
;
;       Name: TWOS
;       Type: Variable
;   Category: Drawing pixels
;    Summary: Ready-made single-pixel character row bytes for mode 4
;  Deep dive: Drawing monochrome pixels in mode 4
;
; ------------------------------------------------------------------------------
;
; Ready-made bytes for plotting one-pixel points in mode 4 (the top part of the
; split screen). See the PIXEL routine for details.
;
; ******************************************************************************

.TWOS

 EQUB %10000000
 EQUB %01000000
 EQUB %00100000
 EQUB %00010000
 EQUB %00001000
 EQUB %00000100
 EQUB %00000010
 EQUB %00000001
 EQUB %10000000
 EQUB %01000000

; ******************************************************************************
;
;       Name: TWOS2
;       Type: Variable
;   Category: Drawing pixels
;    Summary: Ready-made double-pixel character row bytes for mode 4
;  Deep dive: Drawing monochrome pixels in mode 4
;
; ------------------------------------------------------------------------------
;
; Ready-made bytes for plotting two-pixel dashes in mode 4 (the top part of the
; split screen). See the PIXEL routine for details.
;
; ******************************************************************************

.TWOS2

 EQUB %11000000
 EQUB %11000000
 EQUB %01100000
 EQUB %00110000
 EQUB %00011000
 EQUB %00001100
 EQUB %00000110
 EQUB %00000011

; ******************************************************************************
;
;       Name: TWFL
;       Type: Variable
;   Category: Drawing lines
;    Summary: Ready-made character rows for the left end of a horizontal line in
;             mode 4
;
; ------------------------------------------------------------------------------
;
; Ready-made bytes for plotting horizontal line end caps in mode 4 (the top part
; of the split screen). This table provides a byte with pixels at the left end,
; which is used for the right end of the line.
;
; See the HLOIN routine for details.
;
; ******************************************************************************

.TWFL

 EQUB %10000000
 EQUB %11000000
 EQUB %11100000
 EQUB %11110000
 EQUB %11111000
 EQUB %11111100
 EQUB %11111110

; ******************************************************************************
;
;       Name: TWFR
;       Type: Variable
;   Category: Drawing lines
;    Summary: Ready-made character rows for the right end of a horizontal line
;             in mode 4
;
; ------------------------------------------------------------------------------
;
; Ready-made bytes for plotting horizontal line end caps in mode 4 (the top part
; of the split screen). This table provides a byte with pixels at the right end,
; which is used for the left end of the line.
;
; See the HLOIN routine for details.
;
; ******************************************************************************

.TWFR

 EQUB %11111111
 EQUB %01111111
 EQUB %00111111
 EQUB %00011111
 EQUB %00001111
 EQUB %00000111
 EQUB %00000011
 EQUB %00000001

; ******************************************************************************
;
;       Name: yLookupLo
;       Type: Variable
;   Category: Drawing pixels
;    Summary: Lookup table for converting pixel y-coordinate to tile number
;             (low byte)
;
; ------------------------------------------------------------------------------
;
; The NES screen mode is made up of 8x8-pixel tiles, with 32 tiles (256 pixels)
; across the screen, and either 30 tiles (240 pixels) or 28 tiles (224 pixels)
; vertically, for PAL or NTSC.
;
; This lookup table converts a pixel y-coordinate into the number of the first
; tile on the row containing the pixel, if we assume tiles are numbered from 1
; at the top-left, and counting across and then down.
;
; ******************************************************************************

.yLookupLo

 FOR I%, 16, 239

  EQUB LO((I% DIV 8) * 32 + 1)

 NEXT

; ******************************************************************************
;
;       Name: yLookupHi
;       Type: Variable
;   Category: Drawing pixels
;    Summary: Lookup table for converting pixel y-coordinate to tile number
;             (high byte)
;
; ------------------------------------------------------------------------------
;
; The NES screen mode is made up of 8x8-pixel tiles, with 32 tiles (256 pixels)
; across the screen, and either 30 tiles (240 pixels) or 28 tiles (224 pixels)
; vertically, for PAL or NTSC.
;
; This lookup table converts a pixel y-coordinate into the number of the first
; tile on the row containing the pixel, if we assume tiles are numbered from 1
; at the top-left, and counting across and then down.
;
; ******************************************************************************

.yLookupHi

 FOR I%, 16, 239

  EQUB HI((I% DIV 8) * 32 + 1)

 NEXT

; ******************************************************************************
;
;       Name: GetRowNameAddress
;       Type: Subroutine
;   Category: Drawing the screen
;    Summary: Get the addresses in the nametable buffers for the start of a
;             given character row
;
; ------------------------------------------------------------------------------
;
; This routine returns the index of the start of a text row in the nametable
; buffers. Character row 0 (i.e. YC = 0) is mapped to the second row on-screen,
; as the first row is taken up by the box edge.
;
; It's also worth noting that the first column in the nametable is column 1, not
; column 0, as the screen has a horizontal scroll of 8, so the leftmost tile
; on each row is scrolled around to the right side. This means that in terms of
; tiles, column 1 is the left edge of the screen, then columns 2 to 31 form the
; body of the screen, and column 0 is the right edge of the screen.
;
; Arguments:
;
;   YC                  The text row
;
;
; Returns:
;
;   SC(1 0)             The address in nametable buffer 0 for the start of the
;                       row
;
;   SC2(1 0)            The address in nametable buffer 1 for the start of the
;                       row
;
; ******************************************************************************

.GetRowNameAddress

 LDA #0                 ; Set SC+1 = 0, for use at the top byte of SC(1 0) in
 STA SC+1               ; the calculation below

 LDA YC                 ; If YC = 0, then we need to return the address of the
 BEQ grow1              ; start of the top character row (i.e. the second row
                        ; on-screen), so jump to grow1

 LDA YC                 ; Set A = YC + 1
 CLC                    ;
 ADC #1                 ; So this is the nametable row number for text row YC,
                        ; as nametable row 0 is taken up by the top box edge

 ASL A                  ; Set SC(1 0) = (SC+1 A) << 5 + 1
 ASL A                  ;             = (0 A) << 5 + 1
 ASL A                  ;             = (YC + 1) * 32 + 1
 ASL A                  ;
 ROL SC+1               ; This sets SC(1 0) to the offset within the nametable
 SEC                    ; of the start of the relevant row, as there are 32
 ROL A                  ; tiles on each row
 ROL SC+1               ;
 STA SC                 ; The YC + 1 part skips the top on-screen row to start
                        ; just below the top box edge, and the final + 1 takes
                        ; care of the horizontal scrolling, which makes the
                        ; first column number 1 rather than 0
                        ;
                        ; The final ROL SC+1 also clears the C flag, as we know
                        ; bits 1 to 7 of SC+1 were clear before the rotation

 STA SC2                ; Set the low byte of SC2(1 0) to the low byte of
                        ; SC(1 0), as the the addresses of the two nametable
                        ; buffers only differ in the high bytes

 LDA SC+1               ; Set SC(1 0) = SC(1 0) + nameBuffer0
 ADC #HI(nameBuffer0)   ;
 STA SC+1               ; So SC(1 0) now points to the row's address in
                        ; nametable buffer 0 (this addition works because we
                        ; know that the C flag is clear and the low byte of
                        ; nameBuffer0 is zero)
                        ;
                        ; This addition will never overflow, as we know SC+1 is
                        ; in the range 0 to 3, so this also clears the C flag

                        ; Each nametable buffer is 1024 bytes in size, which is
                        ; four pages of 256 bytes, and nametable buffer 1 is
                        ; straight after nametable buffer 0 in memory, so we can
                        ; calculate the row's address in nametable buffer 1 in
                        ; SC2(1 0) by simply adding 4 to the high byte

 ADC #4                 ; Set SC2(1 0) = SC(1 0) + (4 0)
 STA SC2+1              ;
                        ; So SC2(1 0) now points to the row's address in
                        ; nametable buffer 1 (this addition works because we
                        ; know that the C flag is clear

 RTS                    ; Return from the subroutine

.grow1

                        ; If we get here then we want to return the address of
                        ; the top character row (as YC = ), which is actually
                        ; the second on-screen row (row 1), as the first row is
                        ; taken up by the top of the box

 LDA #HI(nameBuffer0+1*32+1)    ; Set SC(1 0) to the address of the tile in
 STA SC+1                       ; column 1 on tile row 1 in nametable buffer 0
 LDA #LO(nameBuffer0+1*32+1)
 STA SC

 LDA #HI(nameBuffer1+1*32+1)    ; Set SC(1 0) to the address of the tile in
 STA SC2+1                      ; column 1 on tile row 1 in nametable buffer 1
 LDA #LO(nameBuffer1+1*32+1)
 STA SC2

 RTS                    ; Return from the subroutine

; ******************************************************************************
;
;       Name: LOIN (Part 1 of 7)
;       Type: Subroutine
;   Category: Drawing lines
;    Summary: Draw a line: Calculate the line gradient in the form of deltas
;  Deep dive: Bresenham's line algorithm
;
; ------------------------------------------------------------------------------
;
; This routine draws a line from (X1, Y1) to (X2, Y2). It has multiple stages.
; This stage calculates the line deltas.
;
; Arguments:
;
;   X1                  The screen x-coordinate of the start of the line
;
;   Y1                  The screen y-coordinate of the start of the line
;
;   X2                  The screen x-coordinate of the end of the line
;
;   Y2                  The screen y-coordinate of the end of the line
;
; ******************************************************************************

.LOIN

 STY YSAV               ; Store Y into YSAV, so we can preserve it across the
                        ; call to this subroutine

 SETUP_PPU_FOR_ICON_BAR ; If the PPU has started drawing the icon bar, configure
                        ; the PPU to use nametable 0 and pattern table 0

 LDA #128               ; Set S = 128, which is the starting point for the
 STA S                  ; slope error (representing half a pixel)

 ASL A                  ; Set SWAP = 0, as %10000000 << 1 = 0
 STA SWAP

 LDA X2                 ; Set A = X2 - X1
 SBC X1                 ;       = delta_x
                        ;
                        ; This subtraction works as the ASL A above sets the C
                        ; flag

 BCS LI1                ; If X2 > X1 then A is already positive and we can skip
                        ; the next three instructions

 EOR #%11111111         ; Negate the result in A by flipping all the bits and
 ADC #1                 ; adding 1, i.e. using two's complement to make it
                        ; positive

.LI1

 STA P                  ; Store A in P, so P = |X2 - X1|, or |delta_x|

 SEC                    ; Set the C flag, ready for the subtraction below

 LDA Y2                 ; Set A = Y2 - Y1
 SBC Y1                 ;       = delta_y
                        ;
                        ; This subtraction works as we either set the C flag
                        ; above, or we skipped that SEC instruction with a BCS

 BCS LI2                ; If Y2 > Y1 then A is already positive and we can skip
                        ; the next two instructions

 EOR #%11111111         ; Negate the result in A by flipping all the bits and
 ADC #1                 ; adding 1, i.e. using two's complement to make it
                        ; positive

.LI2

 STA Q                  ; Store A in Q, so Q = |Y2 - Y1|, or |delta_y|

 CMP P                  ; If Q < P, jump to STPX to step along the x-axis, as
 BCC STPX               ; the line is closer to being horizontal than vertical

 JMP STPY               ; Otherwise Q >= P so jump to STPY to step along the
                        ; y-axis, as the line is closer to being vertical than
                        ; horizontal

; ******************************************************************************
;
;       Name: LOIN (Part 2 of 7)
;       Type: Subroutine
;   Category: Drawing lines
;    Summary: Draw a line: Line has a shallow gradient, step right along x-axis
;  Deep dive: Bresenham's line algorithm
;
; ------------------------------------------------------------------------------
;
; This routine draws a line from (X1, Y1) to (X2, Y2). It has multiple stages.
; If we get here, then:
;
;   * |delta_y| < |delta_x|
;
;   * The line is closer to being horizontal than vertical
;
;   * We are going to step right along the x-axis
;
;   * We potentially swap coordinates to make sure X1 < X2
;
; ******************************************************************************

.STPX

 LDX X1                 ; Set X = X1

 CPX X2                 ; If X1 < X2, jump down to LI3, as the coordinates are
 BCC LI3                ; already in the order that we want

 DEC SWAP               ; Otherwise decrement SWAP from 0 to $FF, to denote that
                        ; we are swapping the coordinates around (though note
                        ; that we don't use this value anywhere, as in the
                        ; original versions of Elite it is used to omit the
                        ; first pixel of each line, which we don't have to do
                        ; in the NES version as it doesn't use EOR plotting)

 LDA X2                 ; Swap the values of X1 and X2
 STA X1
 STX X2

 TAX                    ; Set X = X1

 LDA Y2                 ; Swap the values of Y1 and Y2
 LDY Y1
 STA Y1
 STY Y2

.LI3

                        ; By this point we know the line is horizontal-ish and
                        ; X1 < X2, so we're going from left to right as we go
                        ; from X1 to X2

                        ; The following section calculates:
                        ;
                        ;   Q = Q / P
                        ;     = |delta_y| / |delta_x|
                        ;
                        ; using the log tables at logL and log to calculate:
                        ;
                        ;   A = log(Q) - log(P)
                        ;     = log(|delta_y|) - log(|delta_x|)
                        ;
                        ; by first subtracting the low bytes of the logarithms
                        ; from the table at LogL, and then subtracting the high
                        ; bytes from the table at log, before applying the
                        ; antilog to get the result of the division and putting
                        ; it in Q

 LDX Q                  ; Set X = |delta_y|

 BEQ LIlog7             ; If |delta_y| = 0, jump to LIlog7 to return 0 as the
                        ; result of the division

 LDA logL,X             ; Set A = log(Q) - log(P)
 LDX P                  ;       = log(|delta_y|) - log(|delta_x|)
 SEC                    ;
 SBC logL,X             ; by first subtracting the low bytes of log(Q) - log(P)

 BMI LIlog4             ; If A > 127, jump to LIlog4

 LDX Q                  ; And then subtracting the high bytes of log(Q) - log(P)
 LDA log,X              ; so now A contains the high byte of log(Q) - log(P)
 LDX P
 SBC log,X

 BCS LIlog5             ; If the subtraction fitted into one byte and didn't
                        ; underflow, then log(Q) - log(P) < 256, so we jump to
                        ; LIlog5 to return a result of 255

 TAX                    ; Otherwise we set A to the A-th entry from the antilog
 LDA antilog,X          ; table so the result of the division is now in A

 JMP LIlog6             ; Jump to LIlog6 to return the result

.LIlog5

 LDA #255               ; The division is very close to 1, so set A to the
 BNE LIlog6             ; closest possible answer to 256, i.e. 255, and jump to
                        ; LIlog6 to return the result (this BNE is effectively a
                        ; JMP as A is never zero)

.LIlog7

 LDA #0                 ; The numerator in the division is 0, so set A to 0 and
 BEQ LIlog6             ; jump to LIlog6 to return the result (this BEQ is
                        ; effectively a JMP as A is always zero)

.LIlog4

 LDX Q                  ; Subtract the high bytes of log(Q) - log(P) so now A
 LDA log,X              ; contains the high byte of log(Q) - log(P)
 LDX P
 SBC log,X

 BCS LIlog5             ; If the subtraction fitted into one byte and didn't
                        ; underflow, then log(Q) - log(P) < 256, so we jump to
                        ; LIlog5 to return a result of 255

 TAX                    ; Otherwise we set A to the A-th entry from the
 LDA antilogODD,X       ; antilogODD so the result of the division is now in A

.LIlog6

 STA Q                  ; Store the result of the division in Q, so we have:
                        ;
                        ;   Q = |delta_y| / |delta_x|

 LDA P                  ; Set P = P + 1
 CLC                    ;      = |delta_x| + 1
 ADC #1                 ;
 STA P                  ; We will use P as the x-axis counter, and we add 1 to
                        ; ensure we include the pixel at each end

 LDY Y1                 ; If Y1 >= Y2, skip the following instruction
 CPY Y2
 BCS P%+5

 JMP DOWN               ; Y1 < Y2, so jump to DOWN, as we need to draw the line
                        ; to the right and down

; ******************************************************************************
;
;       Name: LOIN (Part 3 of 7)
;       Type: Subroutine
;   Category: Drawing lines
;    Summary: Draw a shallow line going right and up or left and down
;  Deep dive: Bresenham's line algorithm
;
; ------------------------------------------------------------------------------
;
; This routine draws a line from (X1, Y1) to (X2, Y2). It has multiple stages.
; If we get here, then:
;
;   * The line is going right and up (no swap) or left and down (swap)
;
;   * X1 < X2 and Y1 > Y2
;
;   * Draw from (X1, Y1) at bottom left to (X2, Y2) at top right
;
; ******************************************************************************

 LDA X1                 ; Set SC2(1 0) = (nameBufferHi 0) + yLookup(Y) + X1 * 8
 LSR A                  ;
 LSR A                  ; where yLookup(Y) uses the (yLookupHi yLookupLo) table
 LSR A                  ; to convert the pixel y-coordinate in Y into the number
 CLC                    ; of the first tile on the row containing the pixel
 ADC yLookupLo,Y        ;
 STA SC2                ; Adding nameBufferHi and X1 * 8 therefore sets SC2(1 0)
 LDA nameBufferHi       ; to the address of the entry in the nametable buffer
 ADC yLookupHi,Y        ; that contains the tile number for the tile containing
 STA SC2+1              ; the pixel at (X1, Y), i.e. the line we are drawing

 TYA                    ; Set Y = Y mod 8, which is the pixel row within the
 AND #7                 ; character block at which we want to draw the start of
 TAY                    ; our line (as each character block has 8 rows)

 LDA X1                 ; Set X = X1 mod 8, which is the horizontal pixel number
 AND #7                 ; within the character block where the line starts (as
 TAX                    ; each pixel line in the character block is 8 pixels
                        ; wide)

 LDA TWOS,X             ; Fetch a 1-pixel byte from TWOS where pixel X is set

.loin1

 STA R                  ; Store the pixel byte in R

.loin2

 SETUP_PPU_FOR_ICON_BAR ; If the PPU has started drawing the icon bar, configure
                        ; the PPU to use nametable 0 and pattern table 0

 LDX #0                 ; If the nametable buffer entry is non-zero for the tile
 LDA (SC2,X)            ; containing the pixel that we want to draw, then a tile
 BNE loin3              ; has already been allocated to this entry, so skip the
                        ; following

 LDA tileNumber         ; If tileNumber is zero then we have run out of tiles to
 BEQ loin7              ; use for drawing lines and pixels, so jump to loin7 to
                        ; move on to the next pixel in the line

 STA (SC2,X)            ; Otherwise tileNumber contains the number of the next
                        ; available tile for drawing, so allocate this tile to
                        ; cover the pixel that we want to draw by setting the
                        ; nametable entry to the tile number we just fetched

 INC tileNumber         ; Increment tileNumber to point to the next available
                        ; tile for drawing, so it can be added to the nametable
                        ; the next time we need to draw lines or pixels into a
                        ; tile

.loin3

 LDX pattBufferHiDiv8   ; Set SC(1 0) = (pattBufferHiDiv8 A) * 8
 STX SC+1               ;             = (pattBufferHi 0) + A * 8
 ASL A                  ;
 ROL SC+1               ; So SC(1 0) is the address in the pattern buffer for
 ASL A                  ; tile number A (as each tile contains 8 bytes of
 ROL SC+1               ; pattern data), which means SC(1 0) points to the
 ASL A                  ; pattern data for the tile containing the line we are
 ROL SC+1               ; drawing
 STA SC

 CLC                    ; Clear the C flag for the additions below

.loin4

                        ; We now loop along the line from left to right, using P
                        ; as a decreasing counter, and at each count we plot a
                        ; single pixel using the pixel mask in R

 LDA R                  ; Fetch the pixel byte from R

 ORA (SC),Y             ; Store R into screen memory at SC(1 0), using OR logic
 STA (SC),Y             ; so it merges with whatever is already on-screen

 DEC P                  ; Decrement the x-axis counter in P

 BEQ loin9              ; If we have just reached the end of the line along the
                        ; x-axis, jump to loin9 to return from the subroutine

 LDA S                  ; Set S = S + Q to update the slope error
 ADC Q
 STA S

 BCC loin5              ; If the addition didn't overflow, jump to loin5 to skip
                        ; the following

 DEY                    ; Otherwise we just overflowed, so decrement Y to move
                        ; to the pixel line above

 BMI loin6              ; If Y is negative we need to move up into the character
                        ; block above, so jump to loin6 to decrement the screen
                        ; address accordingly (jumping back to loin1 afterwards)

.loin5

 LSR R                  ; Shift the single pixel in R to the right to step along
                        ; the x-axis, so the next pixel we plot will be at the
                        ; next x-coordinate along

 BNE loin4              ; If the pixel didn't fall out of the right end of R,
                        ; then the pixel byte is still non-zero, so loop back
                        ; to loin4

 LDA #%10000000         ; Set a pixel byte in A with the leftmost pixel set, as
                        ; we need to move to the next character block along

 INC SC2                ; Increment SC2(1 0) to point to the next tile number to
 BNE loin1              ; the right in the nametable buffer and jump up to loin1
 INC SC2+1              ; to fetch the tile details for the new nametable entry
 BNE loin1

.loin6

 LDA SC2                ; If we get here then we need to move up into the
 SBC #32                ; character block above, so we subtract 32 from SC2(1 0)
 STA SC2                ; to get the tile number on the row above (as there are
 BCS P%+4               ; 32 tiles on each row)
 DEC SC2+1

 LDY #7                 ; Set the pixel line in Y to the last line in the new
                        ; character block

 LSR R                  ; Shift the single pixel in R to the right to step along
                        ; the x-axis, so the next pixel we plot will be at the
                        ; next x-coordinate along

 BNE loin2              ; If the pixel didn't fall out of the right end of R,
                        ; then the pixel byte is still non-zero, so loop back
                        ; to loin2

 LDA #%10000000         ; Set a pixel byte in A with the leftmost pixel set, as
                        ; we need to move to the next character block along

 INC SC2                ; Increment SC2(1 0) to point to the next tile number to
 BNE loin1              ; the right in the nametable buffer and jump up to loin1
 INC SC2+1              ; to fetch the tile details for the new nametable entry
 BNE loin1              ; (this BNE is effectively a JMP as the high byte of
                        ; SC2(1 0) will never be zero as the nametable buffers
                        ; start at address $7000, so the high byte is always at
                        ; least $70)

.loin7

 DEC P                  ; Decrement the x-axis counter in P

 BEQ loin9              ; If we have just reached the end of the line along the
                        ; x-axis, jump to loin9 to return from the subroutine

 CLC                    ; Set S = S + Q to update the slope error
 LDA S
 ADC Q
 STA S

 BCC loin8              ; If the addition didn't overflow, jump to loin8 to skip
                        ; the following

 DEY                    ; Otherwise we just overflowed, so decrement Y to move
                        ; to the pixel line above

 BMI loin6              ; If Y is negative we need to move up into the character
                        ; block above, so jump to loin6 to move to the previous
                        ; row of nametable entries (jumping back to loin1
                        ; afterwards)

.loin8

 LSR R                  ; Shift the single pixel in R to the right to step along
                        ; the x-axis, so the next pixel we plot will be at the
                        ; next x-coordinate along

 BNE loin7              ; If the pixel didn't fall out of the right end of R,
                        ; then the pixel byte is still non-zero, so loop back
                        ; to loin7

 LDA #%10000000         ; Set a pixel byte in A with the leftmost pixel set, as
                        ; we need to move to the next character block along

 INC SC2                ; Increment SC2(1 0) to point to the next tile number to
 BNE P%+4               ; the right in the nametable buffer and jump up to loin1
 INC SC2+1              ; to fetch the tile details for the new nametable entry
 JMP loin1

.loin9

 LDY YSAV               ; Restore Y from YSAV, so that it's preserved

 SETUP_PPU_FOR_ICON_BAR ; If the PPU has started drawing the icon bar, configure
                        ; the PPU to use nametable 0 and pattern table 0

 CLC                    ; Clear the C flag for the routine to return

 RTS                    ; Return from the subroutine

; ******************************************************************************
;
;       Name: LOIN (Part 4 of 7)
;       Type: Subroutine
;   Category: Drawing lines
;    Summary: Draw a shallow line going right and down or left and up
;  Deep dive: Bresenham's line algorithm
;
; ------------------------------------------------------------------------------
;
; This routine draws a line from (X1, Y1) to (X2, Y2). It has multiple stages.
; If we get here, then:
;
;   * The line is going right and down (no swap) or left and up (swap)
;
;   * X1 < X2 and Y1 <= Y2
;
;   * Draw from (X1, Y1) at top left to (X2, Y2) at bottom right
;
; ******************************************************************************

.DOWN

 LDA X1                 ; Set SC2(1 0) = (nameBufferHi 0) + yLookup(Y) + X1 * 8
 LSR A                  ;
 LSR A                  ; where yLookup(Y) uses the (yLookupHi yLookupLo) table
 LSR A                  ; to convert the pixel y-coordinate in Y into the number
 CLC                    ; of the first tile on the row containing the pixel
 ADC yLookupLo,Y        ;
 STA SC2                ; Adding nameBufferHi and X1 * 8 therefore sets SC2(1 0)
 LDA nameBufferHi       ; to the address of the entry in the nametable buffer
 ADC yLookupHi,Y        ; that contains the tile number for the tile containing
 STA SC2+1              ; the pixel at (X1, Y), i.e. the line we are drawing

 TYA                    ; Set Y = Y mod 8, which is the pixel row within the
 AND #7                 ; character block at which we want to draw the start of
 TAY                    ; our line (as each character block has 8 rows)

 LDA X1                 ; Set X = X1 mod 8, which is the horizontal pixel number
 AND #7                 ; within the character block where the line starts (as
 TAX                    ; each pixel line in the character block is 8 pixels
                        ; wide)

 LDA TWOS,X             ; Fetch a 1-pixel byte from TWOS where pixel X is set

.loin10

 STA R                  ; Store the pixel byte in R

.loin11

 SETUP_PPU_FOR_ICON_BAR ; If the PPU has started drawing the icon bar, configure
                        ; the PPU to use nametable 0 and pattern table 0

 LDX #0                 ; If the nametable buffer entry is non-zero for the tile
 LDA (SC2,X)            ; containing the pixel that we want to draw, then a tile
 BNE loin12             ; has already been allocated to this entry, so skip the
                        ; following

 LDA tileNumber         ; If tileNumber is zero then we have run out of tiles to
 BEQ loin16             ; use for drawing lines and pixels, so jump to loin16 to
                        ; move on to the next pixel in the line

 STA (SC2,X)            ; Otherwise tileNumber contains the number of the next
                        ; available tile for drawing, so allocate this tile to
                        ; cover the pixel that we want to draw by setting the
                        ; nametable entry to the tile number we just fetched

 INC tileNumber         ; Increment tileNumber to point to the next available
                        ; tile for drawing, so it can be added to the nametable
                        ; the next time we need to draw lines or pixels into a
                        ; tile

.loin12

 LDX pattBufferHiDiv8   ; Set SC(1 0) = (pattBufferHiDiv8 A) * 8
 STX SC+1               ;             = (pattBufferHi 0) + A * 8
 ASL A                  ;
 ROL SC+1               ; So SC(1 0) is the address in the pattern buffer for
 ASL A                  ; tile number A (as each tile contains 8 bytes of
 ROL SC+1               ; pattern data), which means SC(1 0) points to the
 ASL A                  ; pattern data for the tile containing the line we are
 ROL SC+1               ; drawing
 STA SC

 CLC                    ; Clear the C flag for the additions below

.loin13

                        ; We now loop along the line from left to right, using P
                        ; as a decreasing counter, and at each count we plot a
                        ; single pixel using the pixel mask in R

 LDA R                  ; Fetch the pixel byte from R

 ORA (SC),Y             ; Store R into screen memory at SC(1 0), using OR logic
 STA (SC),Y             ; so it merges with whatever is already on-screen

 DEC P                  ; Decrement the x-axis counter in P

 BEQ loin9              ; If we have just reached the end of the line along the
                        ; x-axis, jump to loin9 to return from the subroutine

 LDA S                  ; Set S = S + Q to update the slope error
 ADC Q
 STA S

 BCC loin14             ; If the addition didn't overflow, jump to loin14 to
                        ; skip the following

 INY                    ; Otherwise we just overflowed, so increment Y to move
                        ; to the pixel line below

 CPY #8                 ; If Y = 8 then we have just gone past the bottom of the
 BEQ loin15             ; character block, so jump to loin15 to move to the next
                        ; row of nametable entries (jumping back to loin10
                        ; afterwards)

.loin14

 LSR R                  ; Shift the single pixel in R to the right to step along
                        ; the x-axis, so the next pixel we plot will be at the
                        ; next x-coordinate along

 BNE loin13             ; If the pixel didn't fall out of the right end of R,
                        ; then the pixel byte is still non-zero, so loop back
                        ; to loin13

 LDA #%10000000         ; Set a pixel byte in A with the leftmost pixel set, as
                        ; we need to move to the next character block along

 INC SC2                ; Increment SC2(1 0) to point to the next tile number to
 BNE loin10             ; the right in the nametable buffer and jump up to
 INC SC2+1              ; loin10 to fetch the tile details for the new nametable
 JMP loin10             ; entry

.loin15

                        ; If we get here then we have just gone past the bottom
                        ; of the character block
                        ;
                        ; At this point the C flag is set, as we jumped here
                        ; using a BEQ, so the ADC #31 below actually adds 32

 LDA SC2                ; If we get here then we need to move down into the
 ADC #31                ; character block above, so we add 32 to SC2(1 0)
 STA SC2                ; to get the tile number on the row above (as there are
 BCC P%+4               ; 32 tiles on each row)
 INC SC2+1

 LDY #0                 ; Set the pixel line in Y to the first line in the new
                        ; character block

 LSR R                  ; Shift the single pixel in R to the right to step along
                        ; the x-axis, so the next pixel we plot will be at the
                        ; next x-coordinate along

 BNE loin11             ; If the pixel didn't fall out of the right end of R,
                        ; then the pixel byte is still non-zero, so loop back
                        ; to loin11

 LDA #%10000000         ; Set a pixel byte in A with the leftmost pixel set, as
                        ; we need to move to the next character block along

 INC SC2                ; Increment SC2(1 0) to point to the next tile number to
 BNE loin10             ; the right in the nametable buffer and jump up to
 INC SC2+1              ; loin10 to fetch the tile details for the new nametable
 JMP loin10             ; entry

.loin16

                        ; If we get here then we have run out of tiles to
                        ; allocate to the line drawing, so we continue with the
                        ; same calculations, but don't actually draw anything in
                        ; this character block

 DEC P                  ; Decrement the x-axis counter in P

 BEQ loin19

 CLC                    ; Set S = S + Q to update the slope error
 LDA S
 ADC Q
 STA S

 BCC loin17             ; If the addition didn't overflow, jump to loin17 to
                        ; skip the following

 INY                    ; Otherwise we just overflowed, so increment Y to move
                        ; to the pixel line below

 CPY #8                 ; If Y = 8 then we have just gone past the bottom of the
 BEQ loin15             ; character block, so jump to loin15 to move to the next
                        ; row of nametable entries (jumping back to loin10
                        ; afterwards)

.loin17

 LSR R                  ; Shift the single pixel in R to the right to step along
                        ; the x-axis, so the next pixel we plot will be at the
                        ; next x-coordinate along

 BNE loin16             ; If the pixel didn't fall out of the right end of R,
                        ; then the pixel byte is still non-zero, so loop back
                        ; to loin16

 LDA #%10000000         ; Set a pixel byte in A with the leftmost pixel set, as
                        ; we need to move to the next character block along

 INC SC2                ; Increment SC2(1 0) to point to the next tile number to
 BNE P%+4               ; the right in the nametable buffer and jump up to
 INC SC2+1              ; loin10 to fetch the tile details for the new nametable
 JMP loin10             ; entry

.loin18

 SETUP_PPU_FOR_ICON_BAR ; If the PPU has started drawing the icon bar, configure
                        ; the PPU to use nametable 0 and pattern table 0

.loin19

 LDY YSAV               ; Restore Y from YSAV, so that it's preserved

 CLC                    ; Clear the C flag for the routine to return

 RTS                    ; Return from the subroutine

; ******************************************************************************
;
;       Name: LOIN (Part 5 of 7)
;       Type: Subroutine
;   Category: Drawing lines
;    Summary: Draw a line: Line has a steep gradient, step up along y-axis
;  Deep dive: Bresenham's line algorithm
;
; ------------------------------------------------------------------------------
;
; This routine draws a line from (X1, Y1) to (X2, Y2). It has multiple stages.
; If we get here, then:
;
;   * |delta_y| >= |delta_x|
;
;   * The line is closer to being vertical than horizontal
;
;   * We are going to step up along the y-axis
;
;   * We potentially swap coordinates to make sure Y1 >= Y2
;
; ******************************************************************************

.STPY

 LDY Y1                 ; Set A = Y = Y1
 TYA

 LDX X1                 ; Set X = X1

 CPY Y2                 ; If Y1 = Y2, jump up to loin18 to return from the
 BEQ loin18              ; subroutine as there is no line to draw

 BCS LI15               ; If Y1 > Y2, jump down to LI15, as the coordinates are
                        ; already in the order that we want

 DEC SWAP               ; Otherwise decrement SWAP from 0 to $FF, to denote that
                        ; we are swapping the coordinates around (though note
                        ; that we don't use this value anywhere, as in the
                        ; original versions of Elite it is used to omit the
                        ; first pixel of each line, which we don't have to do
                        ; in the NES version as it doesn't use EOR plotting)

 LDA X2                 ; Swap the values of X1 and X2
 STA X1
 STX X2

 TAX                    ; Set X = X1

 LDA Y2                 ; Swap the values of Y1 and Y2
 STA Y1
 STY Y2

 TAY                    ; Set Y = A = Y1

.LI15

                        ; By this point we know the line is vertical-ish and
                        ; Y1 >= Y2, so we're going from top to bottom as we go
                        ; from Y1 to Y2

                        ; The following section calculates:
                        ;
                        ;   P = P / Q
                        ;     = |delta_x| / |delta_y|
                        ;
                        ; using the log tables at logL and log to calculate:
                        ;
                        ;   A = log(P) - log(Q)
                        ;     = log(|delta_x|) - log(|delta_y|)
                        ;
                        ; by first subtracting the low bytes of the logarithms
                        ; from the table at LogL, and then subtracting the high
                        ; bytes from the table at log, before applying the
                        ; antilog to get the result of the division and putting
                        ; it in P

 LDX P                  ; Set X = |delta_x|

 BEQ LIfudge            ; If |delta_x| = 0, jump to LIfudge to return 0 as the
                        ; result of the division

 LDA logL,X             ; Set A = log(P) - log(Q)
 LDX Q                  ;       = log(|delta_x|) - log(|delta_y|)
 SEC                    ;
 SBC logL,X             ; by first subtracting the low bytes of log(P) - log(Q)

 BMI LIloG              ; If A > 127, jump to LIloG

 LDX P                  ; And then subtracting the high bytes of log(P) - log(Q)
 LDA log,X              ; so now A contains the high byte of log(P) - log(Q)
 LDX Q
 SBC log,X

 BCS LIlog3             ; If the subtraction fitted into one byte and didn't
                        ; underflow, then log(P) - log(Q) < 256, so we jump to
                        ; LIlog3 to return a result of 255

 TAX                    ; Otherwise we set A to the A-th entry from the antilog
 LDA antilog,X          ; table so the result of the division is now in A

 JMP LIlog2             ; Jump to LIlog2 to return the result

.LIlog3

 LDA #255               ; The division is very close to 1, so set A to the
 BNE LIlog2             ; closest possible answer to 256, i.e. 255, and jump to
                        ; LIlog2 to return the result (this BNE is effectively a
                        ; JMP as A is never zero)

.LIfudge

 LDA #0                 ; Set A = 0 and jump to LIlog2 to return 0 as the result
 BEQ LIlog2             ; (this BNE is effectively a JMP as A is always zero)

.LIloG

 LDX P                  ; Subtract the high bytes of log(P) - log(Q) so now A
 LDA log,X              ; contains the high byte of log(P) - log(Q)
 LDX Q
 SBC log,X

 BCS LIlog3             ; If the subtraction fitted into one byte and didn't
                        ; underflow, then log(P) - log(Q) < 256, so we jump to
                        ; LIlog3 to return a result of 255

 TAX                    ; Otherwise we set A to the A-th entry from the
 LDA antilogODD,X       ; antilogODD so the result of the division is now in A

.LIlog2

 STA P                  ; Store the result of the division in P, so we have:
                        ;
                        ;   P = |delta_x| / |delta_y|

 LDA X1                 ; Set SC2(1 0) = (nameBufferHi 0) + yLookup(Y) + X1 * 8
 LSR A                  ;
 LSR A                  ; where yLookup(Y) uses the (yLookupHi yLookupLo) table
 LSR A                  ; to convert the pixel y-coordinate in Y into the number
 CLC                    ; of the first tile on the row containing the pixel
 ADC yLookupLo,Y        ;
 STA SC2                ; Adding nameBufferHi and X1 * 8 therefore sets SC2(1 0)
 LDA nameBufferHi       ; to the address of the entry in the nametable buffer
 ADC yLookupHi,Y        ; that contains the tile number for the tile containing
 STA SC2+1              ; the pixel at (X1, Y), i.e. the line we are drawing

 TYA                    ; Set Y = Y mod 8, which is the pixel row within the
 AND #7                 ; character block at which we want to draw the start of
 TAY                    ; our line (as each character block has 8 rows)

 SEC                    ; Set A = X2 - X1
 LDA X2                 ;
 SBC X1                 ; This sets the C flag when X1 <= X2

 LDA X1                 ; Set X = X1 mod 8, which is the horizontal pixel number
 AND #7                 ; within the character block where the line starts (as
 TAX                    ; each pixel line in the character block is 8 pixels
                        ; wide)

 LDA TWOS,X             ; Fetch a 1-pixel byte from TWOS where pixel X is set

 STA R                  ; Store the pixel byte in R

 LDX Q                  ; Set X = Q + 1
 INX                    ;       = |delta_y| + 1
                        ;
                        ; We will use Q as the y-axis counter, and we add 1 to
                        ; ensure we include the pixel at each end

 BCS loin24             ; If X1 <= X2 (which we calculated above) then jump to
                        ; loin24 to draw the line to the left and up

 JMP loin36             ; If we get here then X1 > X2, so jump to loin36, as we
                        ; need to draw the line to the left and down

; ******************************************************************************
;
;       Name: LOIN (Part 6 of 7)
;       Type: Subroutine
;   Category: Drawing lines
;    Summary: Draw a steep line going up and left or down and right
;  Deep dive: Bresenham's line algorithm
;
; ------------------------------------------------------------------------------
;
; This routine draws a line from (X1, Y1) to (X2, Y2). It has multiple stages.
; If we get here, then:
;
;   * The line is going up and left (no swap) or down and right (swap)
;
;   * X1 < X2 and Y1 >= Y2
;
;   * Draw from (X1, Y1) at top left to (X2, Y2) at bottom right
;
; ******************************************************************************

.loin20

 LDY YSAV               ; Restore Y from YSAV, so that it's preserved

 CLC                    ; Clear the C flag for the routine to return

 RTS                    ; Return from the subroutine

.loin21

                        ; If we get here then we are drawing our line in a new
                        ; tile in the nametable buffer, so it won't contain any
                        ; pre-existing content

 LDX pattBufferHiDiv8   ; Set SC(1 0) = (pattBufferHiDiv8 A) * 8
 STX SC+1               ;             = (pattBufferHi 0) + A * 8
 ASL A                  ;
 ROL SC+1               ; So SC(1 0) is the address in the pattern buffer for
 ASL A                  ; tile number A (as each tile contains 8 bytes of
 ROL SC+1               ; pattern data), which means SC(1 0) points to the
 ASL A                  ; pattern data for the tile containing the line we are
 ROL SC+1               ; drawing
 STA SC

 CLC                    ; Clear the C flag for the additions below

 LDX Q                  ; Set X to the value of the x-axis counter

.loin22

 LDA R                  ; Fetch the pixel byte from R

 STA (SC),Y             ; Store R into screen memory at SC(1 0) - we don't need
                        ; to merge it with whatever is there, as we just started
                        ; drawing in a new tile

 DEX                    ; Decrement the y-coordinate counter in X

 BEQ loin20             ; If we have just reached the end of the line along the
                        ; y-axis, jump to loin20 to return from the subroutine

 LDA S                  ; Set S = S + P to update the slope error
 ADC P
 STA S

 BCC loin23             ; If the addition didn't overflow, jump to loin23 to
                        ; skip the following

 LSR R                  ; Shift the single pixel in R to the right to step along
                        ; the x-axis, so the next pixel we plot will be at the
                        ; next x-coordinate along

 BCS loin28             ; If the pixel fell out of the right end of R into the
                        ; C flag, then jump to loin28 to rotate it into the left
                        ; end and move right by a character block

.loin23

 DEY                    ; Decrement Y to point to move to the pixel line above

 BPL loin22             ; If Y is still positive then we have not yet gone past
                        ; the top of the character block, so jump to loin22 to
                        ; draw the next pixel

                        ; Otherwise we just gone past the top of the current
                        ; character block, so we need to move up into the
                        ; character block above by setting Y and SC2(1 0)

 LDY #7                 ; Set Y to point to the bottom pixel row of the block
                        ; above

                        ; If we get here then the C flag is clear, as we either
                        ; jumped to loin23 using a BCC, or we passed through a
                        ; BCS to get to loin23, so the SBC #31 below actually
                        ; subtracts 32

 LDA SC2                ; Subtract 32 from SC2(1 0) to get the tile number on
 SBC #31                ; the row above (as there are 32 tiles on each row)
 STA SC2
 BCS loin24
 DEC SC2+1

                        ; Fall through into loin24 to fetch the correct tile
                        ; number for the new character block and continue
                        ; drawing

.loin24

                        ; This is the entry point for this part (we jump here
                        ; from part 5 when the line is steep and X1 <= X2)
                        ;
                        ; We jump here with X containing the y-axis counter,
                        ; i.e. the number of steps we need to take along the
                        ; y-axis when drawing the line

 STX Q                  ; Store the updated y-axis counter in Q

 SETUP_PPU_FOR_ICON_BAR ; If the PPU has started drawing the icon bar, configure
                        ; the PPU to use nametable 0 and pattern table 0

 LDX #0                 ; If the nametable buffer entry is non-zero for the tile
 LDA (SC2,X)            ; containing the pixel that we want to draw, then a tile
 BNE loin25             ; has already been allocated to this entry, so skip the
                        ; following

 LDA tileNumber         ; If tileNumber is zero then we have run out of tiles to
 BEQ loin29             ; use for drawing lines and pixels, so jump to loin29 to
                        ; keep going with the line-drawing calculations, but
                        ; without drawing anything in this tile

 STA (SC2,X)            ; Otherwise tileNumber contains the number of the next
                        ; available tile for drawing, so allocate this tile to
                        ; cover the pixel that we want to draw by setting the
                        ; nametable entry to the tile number we just fetched

 INC tileNumber         ; Increment tileNumber to point to the next available
                        ; tile for drawing, so it can be added to the nametable
                        ; the next time we need to draw lines or pixels into a
                        ; tile

 JMP loin21             ; Jump to loin21 to calculate the pattern buffer address
                        ; for the new tile and continue drawing

.loin25

                        ; If we get here then we are drawing our line in a tile
                        ; that was already in the nametable buffer, so it might
                        ; contain pre-existing content

 LDX pattBufferHiDiv8   ; Set SC(1 0) = (pattBufferHiDiv8 A) * 8
 STX SC+1               ;             = (pattBufferHi 0) + A * 8
 ASL A                  ;
 ROL SC+1               ; So SC(1 0) is the address in the pattern buffer for
 ASL A                  ; tile number A (as each tile contains 8 bytes of
 ROL SC+1               ; pattern data), which means SC(1 0) points to the
 ASL A                  ; pattern data for the tile containing the line we are
 ROL SC+1               ; drawing
 STA SC

 CLC                    ; Clear the C flag for the additions below

 LDX Q                  ; Set X to the value of the x-axis counter

.loin26

                        ; We now loop along the line from left to right, using P
                        ; as a decreasing counter, and at each count we plot a
                        ; single pixel using the pixel mask in R

 LDA R                  ; Fetch the pixel byte from R

 ORA (SC),Y             ; Store R into screen memory at SC(1 0), using OR logic
 STA (SC),Y             ; so it merges with whatever is already on-screen

 DEX                    ; Decrement the y-coordinate counter in X

 BEQ loin20             ; If we have just reached the end of the line along the
                        ; y-axis, jump to loin20 to return from the subroutine

 LDA S                  ; Set S = S + P to update the slope error
 ADC P
 STA S

 BCC loin27             ; If the addition didn't overflow, jump to loin27 to
                        ; skip the following

 LSR R                  ; Shift the single pixel in R to the right to step along
                        ; the x-axis, so the next pixel we plot will be at the
                        ; next x-coordinate along

 BCS loin28             ; If the pixel fell out of the right end of R into the
                        ; C flag, then jump to loin28 to rotate it into the left
                        ; end and move right by a character block

.loin27

 DEY                    ; Decrement Y to point to move to the pixel line above

 BPL loin26             ; If Y is still positive then we have not yet gone past
                        ; the top of the character block, so jump to loin26 to
                        ; draw the next pixel

                        ; Otherwise we just gone past the top of the current
                        ; character block, so we need to move up into the
                        ; character block above by setting Y and SC2(1 0)

 LDY #7                 ; Set Y to point to the bottom pixel row of the block
                        ; above

                        ; If we get here then the C flag is clear, as we either
                        ; jumped to loin27 using a BCC, or we passed through a
                        ; BCS to get to loin27, so the SBC #31 below actually
                        ; subtracts 32

 LDA SC2                ; Subtract 32 from SC2(1 0) to get the tile number on
 SBC #31                ; the row above (as there are 32 tiles on each row) and
 STA SC2                ; jump to loin24 to fetch the correct tile number for
 BCS loin24             ; the new character block and continue drawing (this
 DEC SC2+1              ; BNE is effectively a JMP as the high byte of SC2(1 0)
 BNE loin24             ; will never be zero (the nametable buffers start at
                        ; address $7000, so the high byte is at least $70)

.loin28

                        ; If we get here, then we just shifted the pixel out of
                        ; the right end of R, so we now need to put it back into
                        ; the left end of R and move to the right by one
                        ; character block

 ROR R                  ; We only reach here via a BCS, so this rotates a 1 into
                        ; the left end of R and clears the C flag

 INC SC2                ; Increment SC2(1 0) to point to the next tile number to
 BNE P%+4               ; the right in the nametable buffer
 INC SC2+1

 DEY                    ; Decrement Y to point to move to the pixel line above

 BPL loin24             ; If Y is still positive then we have not yet gone past
                        ; the top of the character block, so jump to loin24 to
                        ; draw the next pixel

 LDY #7                 ; Set Y to point to the bottom pixel row of the block
                        ; above

 LDA SC2                ; Subtract 32 from SC2(1 0) to get the tile number on
 SBC #31                ; the row above (as there are 32 tiles on each row) and
 STA SC2                ; jump to loin24 to fetch the correct tile number for
 BCS loin24             ; the new character block and continue drawing
 DEC SC2+1
 JMP loin24

.loin29

                        ; If we get here then we have run out of tiles to
                        ; allocate to the line drawing, so we continue with the
                        ; same calculations, but don't actually draw anything in
                        ; this character block

 LDX Q                  ; Set X to the value of the x-axis counter

.loin30

 DEX                    ; Decrement the x-axis counter in X

 BEQ loin32             ; If we have just reached the end of the line along the
                        ; x-axis, jump to loin32 to return from the subroutine

 LDA S                  ; Set S = S + P to update the slope error
 ADC P
 STA S

 BCC loin31             ; If the addition didn't overflow, jump to loin31 to
                        ; skip the following

 LSR R                  ; Shift the single pixel in R to the right to step along
                        ; the x-axis, so the next pixel we plot will be at the
                        ; next x-coordinate along

 BCS loin28             ; If the pixel fell out of the right end of R into the
                        ; C flag, then jump to loin28 to rotate it into the left
                        ; end and move right by a character block

.loin31

 DEY                    ; Decrement Y to point to move to the pixel line above

 BPL loin30             ; If Y is still positive then we have not yet gone past
                        ; the top of the character block, so jump to loin30 to
                        ; draw the next pixel

                        ; Otherwise we just gone past the top of the current
                        ; character block, so we need to move up into the
                        ; character block above by setting Y and SC2(1 0)

 LDY #7                 ; Set Y to point to the bottom pixel row of the block
                        ; above

                        ; If we get here then the C flag is clear, as we either
                        ; jumped to loin31 using a BCC, or we passed through a
                        ; BCS to get to loin31, so the SBC #31 below actually
                        ; subtracts 32

 LDA SC2                ; Subtract 32 from SC2(1 0) to get the tile number on
 SBC #31                ; the row above (as there are 32 tiles on each row)
 STA SC2
 BCS P%+4
 DEC SC2+1

 JMP loin24             ; Jump to loin24 to fetch the correct tile number for
                        ; the new character block and continue drawing

.loin32

 LDY YSAV               ; Restore Y from YSAV, so that it's preserved

 CLC                    ; Clear the C flag for the routine to return

 RTS                    ; Return from the subroutine

; ******************************************************************************
;
;       Name: LOIN (Part 7 of 7)
;       Type: Subroutine
;   Category: Drawing lines
;    Summary: Draw a steep line going up and right or down and left
;  Deep dive: Bresenham's line algorithm
;
; ------------------------------------------------------------------------------
;
; This routine draws a line from (X1, Y1) to (X2, Y2). It has multiple stages.
; If we get here, then:
;
;   * The line is going up and right (no swap) or down and left (swap)
;
;   * X1 >= X2 and Y1 >= Y2
;
;   * Draw from (X1, Y1) at bottom left to (X2, Y2) at top right
;
; ******************************************************************************

.loin33

 LDX pattBufferHiDiv8   ; Set SC(1 0) = (pattBufferHiDiv8 A) * 8
 STX SC+1               ;             = (pattBufferHi 0) + A * 8
 ASL A                  ;
 ROL SC+1               ; So SC(1 0) is the address in the pattern buffer for
 ASL A                  ; tile number A (as each tile contains 8 bytes of
 ROL SC+1               ; pattern data), which means SC(1 0) points to the
 ASL A                  ; pattern data for the tile containing the line we are
 ROL SC+1               ; drawing
 STA SC

 CLC                    ; Clear the C flag for the additions below

 LDX Q                  ; Set X to the value of the x-axis counter

.loin34

 LDA R                  ; Fetch the pixel byte from R

 STA (SC),Y             ; Store R into screen memory at SC(1 0) - we don't need
                        ; to merge it with whatever is there, as we just started
                        ; drawing in a new tile

 DEX                    ; Decrement the y-coordinate counter in X

 BEQ loin32             ; If we have just reached the end of the line along the
                        ; y-axis, jump to loin32 to return from the subroutine

 LDA S                  ; Set S = S + P to update the slope error
 ADC P
 STA S

 BCC loin35             ; If the addition didn't overflow, jump to loin35 to
                        ; skip the following

 ASL R                  ; Shift the single pixel in R to the left to step along
                        ; the x-axis, so the next pixel we plot will be at the
                        ; next x-coordinate along

 BCS loin40             ; If the pixel fell out of the left end of R into the
                        ; C flag, then jump to loin40 to rotate it into the
                        ; left end and move left by a character block

.loin35

 DEY                    ; Decrement Y to point to move to the pixel line above

 BPL loin34             ; If Y is still positive then we have not yet gone past
                        ; the top of the character block, so jump to loin34 to
                        ; draw the next pixel

                        ; Otherwise we just gone past the top of the current
                        ; character block, so we need to move up into the
                        ; character block above by setting Y and SC2(1 0)

 LDY #7                 ; Set Y to point to the bottom pixel row of the block
                        ; above

                        ; If we get here then the C flag is clear, as we either
                        ; jumped to loin35 using a BCC, or we passed through a
                        ; BCS to get to loin35, so the SBC #31 below actually
                        ; subtracts 32

 LDA SC2                ; Subtract 32 from SC2(1 0) to get the tile number on
 SBC #31                ; the row above (as there are 32 tiles on each row)
 STA SC2
 BCS loin36
 DEC SC2+1

                        ; Fall through into loin36 to fetch the correct tile
                        ; number for the new character block and continue
                        ; drawing

.loin36

                        ; This is the entry point for this part (we jump here
                        ; from part 5 when the line is steep and X1 > X2)
                        ;
                        ; We jump here with X containing the y-axis counter,
                        ; i.e. the number of steps we need to take along the
                        ; y-axis when drawing the line

 STX Q                  ; Store the updated y-axis counter in Q

 SETUP_PPU_FOR_ICON_BAR ; If the PPU has started drawing the icon bar, configure
                        ; the PPU to use nametable 0 and pattern table 0

 LDX #0                 ; If the nametable buffer entry is non-zero for the tile
 LDA (SC2,X)            ; containing the pixel that we want to draw, then a tile
 BNE loin37             ; has already been allocated to this entry, so skip the
                        ; following

 LDA tileNumber         ; If tileNumber is zero then we have run out of tiles to
 BEQ loin41             ; use for drawing lines and pixels, so jump to loin41 to
                        ; keep going with the line-drawing calculations, but
                        ; without drawing anything in this tile

 STA (SC2,X)            ; Otherwise tileNumber contains the number of the next
                        ; available tile for drawing, so allocate this tile to
                        ; cover the pixel that we want to draw by setting the
                        ; nametable entry to the tile number we just fetched

 INC tileNumber         ; Increment tileNumber to point to the next available
                        ; tile for drawing, so it can be added to the nametable
                        ; the next time we need to draw lines or pixels into a
                        ; tile

 JMP loin33             ; Jump to loin33 to calculate the pattern buffer address
                        ; for the new tile and continue drawing

.loin37

                        ; If we get here then we are drawing our line in a tile
                        ; that was already in the nametable buffer, so it might
                        ; contain pre-existing content

 LDX pattBufferHiDiv8   ; Set SC(1 0) = (pattBufferHiDiv8 A) * 8
 STX SC+1               ;             = (pattBufferHi 0) + A * 8
 ASL A                  ;
 ROL SC+1               ; So SC(1 0) is the address in the pattern buffer for
 ASL A                  ; tile number A (as each tile contains 8 bytes of
 ROL SC+1               ; pattern data), which means SC(1 0) points to the
 ASL A                  ; pattern data for the tile containing the line we are
 ROL SC+1               ; drawing
 STA SC

 CLC                    ; Clear the C flag for the additions below

 LDX Q                  ; Set X to the value of the x-axis counter

.loin38

                        ; We now loop along the line from right to left, using P
                        ; as a decreasing counter, and at each count we plot a
                        ; single pixel using the pixel mask in R

 LDA R                  ; Fetch the pixel byte from R

 ORA (SC),Y             ; Store R into screen memory at SC(1 0), using OR logic
 STA (SC),Y             ; so it merges with whatever is already on-screen

 DEX                    ; Decrement the y-coordinate counter in X

 BEQ loin45             ; If we have just reached the end of the line along the
                        ; y-axis, jump to loin45 to return from the subroutine

 LDA S                  ; Set S = S + P to update the slope error
 ADC P
 STA S

 BCC loin39             ; If the addition didn't overflow, jump to loin39 to
                        ; skip the following

 ASL R                  ; Shift the single pixel in R to the left to step along
                        ; the x-axis, so the next pixel we plot will be at the
                        ; next x-coordinate along

 BCS loin40             ; If the pixel fell out of the left end of R into the
                        ; C flag, then jump to loin40 to rotate it into the
                        ; left end and move left by a character block

.loin39

 DEY                    ; Decrement Y to point to move to the pixel line above

 BPL loin38             ; If Y is still positive then we have not yet gone past
                        ; the top of the character block, so jump to loin38 to
                        ; draw the next pixel

                        ; Otherwise we just gone past the top of the current
                        ; character block, so we need to move up into the
                        ; character block above by setting Y and SC2(1 0)

 LDY #7                 ; Set Y to point to the bottom pixel row of the block
                        ; above

                        ; If we get here then the C flag is clear, as we either
                        ; jumped to loin39 using a BCC, or we passed through a
                        ; BCS to get to loin39, so the SBC #31 below actually
                        ; subtracts 32

 LDA SC2                ; Subtract 32 from SC2(1 0) to get the tile number on
 SBC #31                ; the row above (as there are 32 tiles on each row) and
 STA SC2                ; jump to loin36 to fetch the correct tile number for
 BCS loin36             ; the new character block and continue drawing
 DEC SC2+1
 JMP loin36

.loin40

                        ; If we get here, then we just shifted the pixel out of
                        ; the left end of R, so we now need to put it back into
                        ; the right end of R and move to the left by one
                        ; character block

 ROL R                  ; We only reach here via a BCS, so this rotates a 1 into
                        ; the right end of R and clears the C flag

 LDA SC2                ; Decrement SC2(1 0) to point to the next tile number to
 BNE P%+4               ; the left in the nametable buffer
 DEC SC2+1
 DEC SC2

 DEY                    ; Decrement Y to point to move to the pixel line above

 BPL loin36             ; If Y is still positive then we have not yet gone past
                        ; the top of the character block, so jump to loin36 to
                        ; draw the next pixel

 LDY #7                 ; Set Y to point to the bottom pixel row of the block
                        ; above

 LDA SC2                ; Subtract 32 from SC2(1 0) to get the tile number on
 SBC #31                ; the row above (as there are 32 tiles on each row) and
 STA SC2                ; jump to loin36 to fetch the correct tile number for
 BCS loin36             ; the new character block and continue drawing
 DEC SC2+1
 JMP loin36

.loin41

                        ; If we get here then we have run out of tiles to
                        ; allocate to the line drawing, so we continue with the
                        ; same calculations, but don't actually draw anything in
                        ; this character block

 LDX Q

.loin42

 DEX                    ; Decrement the x-axis counter in X

 BEQ loin44             ; If we have just reached the end of the line along the
                        ; x-axis, jump to loin44 to return from the subroutine

 LDA S                  ; Set S = S + P to update the slope error
 ADC P
 STA S

 BCC loin43             ; If the addition didn't overflow, jump to loin43 to
                        ; skip the following

 ASL R                  ; Shift the single pixel in R to the left to step along
                        ; the x-axis, so the next pixel we plot will be at the
                        ; next x-coordinate along

 BCS loin40             ; If the pixel fell out of the left end of R into the
                        ; C flag, then jump to loin40 to rotate it into the
                        ; left end and move left by a character block

.loin43

 DEY                    ; Decrement Y to point to move to the pixel line above

 BPL loin42             ; If Y is still positive then we have not yet gone past
                        ; the top of the character block, so jump to loin42 to
                        ; draw the next pixel

                        ; Otherwise we just gone past the top of the current
                        ; character block, so we need to move up into the
                        ; character block above by setting Y and SC2(1 0)

 LDY #7                 ; Set Y to point to the bottom pixel row of the block
                        ; above

                        ; If we get here then the C flag is clear, as we either
                        ; jumped to loin43 using a BCC, or we passed through a
                        ; BCS to get to loin43, so the SBC #31 below actually
                        ; subtracts 32

 LDA SC2                ; Subtract 32 from SC2(1 0) to get the tile number on
 SBC #31                ; the row above (as there are 32 tiles on each row)
 STA SC2
 BCS P%+4
 DEC SC2+1

 JMP loin36             ; Jump to loin36 to fetch the correct tile number for
                        ; the new character block and continue drawing

.loin44

 LDY YSAV               ; Restore Y from YSAV, so that it's preserved

 CLC                    ; Clear the C flag for the routine to return

 RTS                    ; Return from the subroutine

.loin45

 LDY YSAV               ; Restore Y from YSAV, so that it's preserved

 CLC                    ; Clear the C flag for the routine to return

 RTS                    ; Return from the subroutine

; ******************************************************************************
;
;       Name: DrawSunRowOfBlocks
;       Type: Subroutine
;   Category: Drawing suns
;    Summary: Draw a row of character blocks that contain sunlight, silhouetting
;             any existing content against the sun
;
; ------------------------------------------------------------------------------
;
; This routine fills a row of whole character blocks with sunlight, turning any
; existing content into a black silhouette on the cyan sun. It effectively fills
; the character blocks containing the horizontal pixel line (P, Y) to (P+1, Y).
;
; Arguments:
;
;   P                   A pixel x-coordinate in the character block from which
;                       we start the fill
;
;   P+1                 A pixel x-coordinate in the character block where we
;                       finish the fill
;
;   Y                   A pixel y-coordinate on the character row to fill
;
; Returns:
;
;   Y                   Y is preserved
;
; ******************************************************************************

.DrawSunRowOfBlocks

 SETUP_PPU_FOR_ICON_BAR ; If the PPU has started drawing the icon bar, configure
                        ; the PPU to use nametable 0 and pattern table 0

 STY YSAV               ; Store Y in YSAV so we can retrieve it below

 LDA P                  ; Set SC2(1 0) = (nameBufferHi 0) + yLookup(Y) + P * 8
 LSR A                  ;
 LSR A                  ; where yLookup(Y) uses the (yLookupHi yLookupLo) table
 LSR A                  ; to convert the pixel y-coordinate in Y into the number
 CLC                    ; of the first tile on the row containing the pixel
 ADC yLookupLo,Y        ;
 STA SC2                ; Adding nameBufferHi and P * 8 therefore sets SC2(1 0)
 LDA nameBufferHi       ; to the address of the entry in the nametable buffer
 ADC yLookupHi,Y        ; that contains the tile number for the tile containing
 STA SC2+1              ; the pixel at (P, Y)

 LDA P+1                ; Set Y = (P+1 - P) * 8 - 1
 SEC                    ;
 SBC P                  ; So Y is the number of tiles we need to fill in the row
 LSR A
 LSR A
 LSR A
 TAY
 DEY

.fill1

 LDA (SC2),Y            ; If the nametable entry for the Y-th tile is non-zero,
 BNE fill2              ; then there is already something there, so jump to
                        ; fill2 to fill this tile using EOR logic (so the pixels
                        ; that are already there are still visible against the
                        ; sun, as black pixels on the sun's cyan background)

 LDA #51                ; Otherwise the nametable entry is zero, which is just
 STA (SC2),Y            ; the background, so set this tile to pattern 51

 DEY                    ; Decrement the tile counter in Y

 BPL fill1              ; Loop back until we have filled the entire row of tiles

 LDY YSAV               ; Retrieve the value of Y we stored above

 RTS                    ; Return from the subroutine

.fill2

                        ; If we get here then A contains the pattern number of
                        ; the non-empty tile that we want to fill, so we now
                        ; need to fill that pattern in the pattern buffer while
                        ; keeping the existing content

 STY T                  ; Store Y in T so we can retrieve it below

 LDY pattBufferHiDiv8   ; Set SC(1 0) = (pattBufferHiDiv8 A) * 8
 STY SC+1               ;             = (pattBufferHiAddr A*8)
 ASL A                  ;
 ROL SC+1               ; This is the address of pattern number A in the current
 ASL A                  ; pattern buffer, as each pattern in the buffer consists
 ROL SC+1               ; of eight bytes
 ASL A                  ;
 ROL SC+1               ; So this is the address of the pattern for the tile
 STA SC                 ; that we want to fill, so now to fill it

 SETUP_PPU_FOR_ICON_BAR ; If the PPU has started drawing the icon bar, configure
                        ; the PPU to use nametable 0 and pattern table 0

 LDY #7                 ; We now loop through each pixel row within this tile's
                        ; pattern, filling the whole pattern with cyan, but
                        ; EOR'ing with the pattern that is already there so it
                        ; is still visible against the sun, as black pixels on
                        ; the sun's cyan background

.fill3

 LDA #%11111111         ; Invert the Y-th pixel row by EOR'ing with %11111111
 EOR (SC),Y
 STA (SC),Y

 DEY                    ; Decrement Y to point to the pixel line above

 BPL fill3              ; Loop back until we have filled all 8 pixel lines in
                        ; the pattern

 LDY T                  ; Retrieve the value of Y we stored above, so it now
                        ; contains the tile counter from the loop at fill1

 DEY                    ; Decrement the tile counter in Y, as we just filled a
                        ; tile

 BPL fill1              ; If there are still more tiles to fill on this row,
                        ; loop back to fill1 to continue filling them

 LDY YSAV               ; Retrieve the value of Y we stored above

 RTS                    ; Return from the subroutine

; ******************************************************************************
;
;       Name: HLOIN (Part 1 of 5)
;       Type: Subroutine
;   Category: Drawing lines
;    Summary: Draw a horizontal line from (X1, Y1) to (X2, Y1)
;
; ------------------------------------------------------------------------------
;
; Returns:
;
;   Y                   Y is preserved
;
; ******************************************************************************

.hlin1

 JMP hlin23             ; Jump to hlin23 to ???

 LDY YSAV               ; Restore Y from YSAV, so that it's preserved

.hlin2

 RTS                    ; Return from the subroutine

.HLOIN

 SETUP_PPU_FOR_ICON_BAR ; If the PPU has started drawing the icon bar, configure
                        ; the PPU to use nametable 0 and pattern table 0

 STY YSAV               ; Store Y into YSAV, so we can preserve it across the
                        ; call to this subroutine

 LDX X1                 ; Set X = X1

 CPX X2                 ; If X1 = X2 then the start and end points are the same,
 BEQ hlin2              ; so return from the subroutine (as hlin2 contains
                        ; an RTS)

 BCC hlin3              ; If X1 < X2, jump to hlin3 to skip the following code,
                        ; as (X1, Y1) is already the left point

 LDA X2                 ; Swap the values of X1 and X2, so we know that (X1, Y1)
 STA X1                 ; is on the left and (X2, Y1) is on the right
 STX X2

 TAX                    ; Set X = X1

.hlin3

 DEC X2                 ; Decrement X2 so we do not draw a pixel at the end
                        ; point

 TXA                    ; Set SC2(1 0) = (nameBufferHi 0) + yLookup(Y) + X1 * 8
 LSR A                  ;
 LSR A                  ; where yLookup(Y) uses the (yLookupHi yLookupLo) table
 LSR A                  ; to convert the pixel y-coordinate in Y into the number
 CLC                    ; of the first tile on the row containing the pixel
 ADC yLookupLo,Y        ;
 STA SC2                ; Adding nameBufferHi and X1 * 8 therefore sets SC2(1 0)
 LDA nameBufferHi       ; to the address of the entry in the nametable buffer
 ADC yLookupHi,Y        ; that contains the tile number for the tile containing
 STA SC2+1              ; the pixel at (X1, Y), i.e. the line we are drawing

 TYA                    ; Set Y = Y mod 8, which is the pixel row within the
 AND #7                 ; character block at which we want to draw the start of
 TAY                    ; our line (as each character block has 8 rows)
                        ;
                        ; As we are drawing a horizontal line, we do not need to
                        ; vary the value of Y, as we will always want to draw on
                        ; the same pixel row within each character block

 TXA                    ; Set T = X1 with bits 0-2 cleared
 AND #%11111000         ;
 STA T                  ; Each character block contains 8 pixel rows, so to get
                        ; the address of the first byte in the character block
                        ; that we need to draw into, as an offset from the start
                        ; of the row, we clear bits 0-2
                        ;
                        ; T is therefore the offset within the row of the start
                        ; of the line at x-coordinate X1

 LDA X2                 ; Set A = X2 with bits 0-2 cleared
 AND #%11111000         ;
 SEC                    ; A is therefore the offset within the row of the end
                        ; of the line at x-coordinate X2

 SBC T                  ; Set A = A - T
                        ;
                        ; So A contains the width of the line in terms of pixel
                        ; bytes (which is the same as the number of character
                        ; blocks that the line spans, less 1 and multiplied by
                        ; 8)

 BEQ hlin1              ; If the line starts and ends in the same character
                        ; block then A will be zero, so jump to hlin23 via hlin1
                        ; to ???

 LSR A                  ; Otherwise set R = A / 8
 LSR A                  ;
 LSR A                  ; So R contains the number of character blocks that the
 STA R                  ; line spans, less 1 (so R = 0 means it spans one block,
                        ; R = 1 means it spans two blocks, and so on)

; ******************************************************************************
;
;       Name: HLOIN (Part 2 of 5)
;       Type: Subroutine
;   Category: Drawing lines
;    Summary: Draw the left end of the line
;
; ******************************************************************************

                        ; We now start the drawing process, beginning with the
                        ; left end of the line, whose nametable entry is in
                        ; SC2(1 0)

 SETUP_PPU_FOR_ICON_BAR ; If the PPU has started drawing the icon bar, configure
                        ; the PPU to use nametable 0 and pattern table 0

 LDX #0                 ; If the nametable buffer entry is non-zero for the tile
 LDA (SC2,X)            ; containing the pixels that we want to draw, then a
 BNE hlin5              ; tile has already been allocated to this entry, so skip
                        ; the following

 LDA tileNumber         ; If tileNumber is zero then we have run out of tiles to
 BEQ hlin4              ; use for drawing lines and pixels, so jump to hlin9 via
                        ; hlin4 to move on to the next character block to the
                        ; right, as we don't have enough dynamic tiles to draw
                        ; the left end of the line

 STA (SC2,X)            ; Otherwise tileNumber contains the number of the next
                        ; available tile for drawing, so allocate this tile to
                        ; cover the pixels that we want to draw by setting the
                        ; nametable entry to the tile number we just fetched

 INC tileNumber         ; Increment tileNumber to point to the next available
                        ; dynamic tile for drawing, so it can be used the next
                        ; time we need to draw lines or pixels into a tile

 JMP hlin7              ; Jump to hlin7 to draw the line, starting by drawing
                        ; the left end into the newly allocated tile number in A

.hlin4

 JMP hlin9              ; Jump to hlin9 to move right by one character block
                        ; without drawing anything

.hlin5

                        ; If we get here then A contains the tile number that's
                        ; already allocated to this part of the line in the
                        ; nametable buffer

 CMP #60                ; If A >= 60, then the tile that's already allocated is
 BCS hlin7              ; one of the tiles we have reserved for dynamic drawing,
                        ; so jump to hlin7 to draw the line, starting by drawing
                        ; the left end into the tile number in A

 CMP #37                ; If A < 37, then the tile that's already allocated is
 BCC hlin4              ; one of the icon bar tiles, so jump to hlin9 via hlin4
                        ; to move right by one character block without drawing
                        ; anything, as we can't draw on the icon bar

                        ; If we get here then 37 <= A <= 59, so the tile that's
                        ; already allocated is one of the pre-rendered tiles
                        ; containing horizontal and vertical line patterns
                        ;
                        ; We don't want to draw over the top of the pre-rendered
                        ; patterns as that will break them, so instead we make a
                        ; copy of the pre-rendered tile's pattern in a newly
                        ; allocated dynamic tile, and then draw our line into
                        ; the dynamic tile, thus preserving what's already shown
                        ; on-screen while still drawing our new line

 LDX pattBufferHiDiv8   ; Set SC3(1 0) = (pattBufferHiDiv8 A) * 8
 STX SC3+1              ;              = (pattBufferHi A) + A * 8
 ASL A                  ;
 ROL SC3+1              ; So SC3(1 0) is the address in the pattern buffer for
 ASL A                  ; tile number A (as each tile contains 8 bytes of
 ROL SC3+1              ; pattern data), which means SC3(1 0) points to the
 ASL A                  ; pattern data for the tile containing the pre-rendered
 ROL SC3+1              ; pattern that we want to copy
 STA SC3

 LDA tileNumber         ; If tileNumber is zero then we have run out of dynamic
 BEQ hlin4              ; tiles for drawing lines and pixels, so jump to hlin9
                        ; via hlin4 to move right by one character block without
                        ; drawing anything, as we don't have enough dynamic
                        ; tiles to draw the left end of the line

 LDX #0                 ; Otherwise tileNumber contains the number of the next
 STA (SC2,X)            ; available tile for drawing, so allocate this tile to
                        ; contain the pre-rendered tile that we want to copy by
                        ; setting the nametable entry to the tile number we just
                        ; fetched

 INC tileNumber         ; Increment tileNumber to point to the next available
                        ; dynamic tile for drawing, so it can be used the next
                        ; time we need to draw lines or pixels into a tile

 LDX pattBufferHiDiv8   ; Set SC(1 0) = (pattBufferHiDiv8 A) * 8
 STX SC+1               ;             = (pattBufferHi 0) + A * 8
 ASL A                  ;
 ROL SC+1               ; So SC(1 0) is the address in the pattern buffer for
 ASL A                  ; tile number A (as each tile contains 8 bytes of
 ROL SC+1               ; pattern data), which means SC(1 0) points to the
 ASL A                  ; pattern data for the dynamic tile we just fetched
 ROL SC+1
 STA SC

                        ; We now have a new dynamic tile in SC(1 0) into which
                        ; we can draw the left end of our line, so we now need
                        ; to copy the pattern of the pre-rendered tile that we
                        ; want to draw on top of
                        ;
                        ; Each pattern is made up of eight bytes, so we simply
                        ; need to copy eight bytes from SC3(1 0) to SC(1 0)

 STY T                  ; Store Y in T so we can retrieve it after the following
                        ; loop

 LDY #7                 ; We now copy eight bytes from SC3(1 0) to SC(1 0), so
                        ; set a counter in Y

.hlin6

 LDA (SC3),Y            ; Copy the Y-th byte of SC3(1 0) to the Y-th byte of
 STA (SC),Y             ; SC(1 0)

 DEY                    ; Decrement the counter

 BPL hlin6              ; Loop back until we have copied all eight bytes

 LDY T                  ; Restore the value of Y from before the loop, so it
                        ; once again contains the pixel row offset within the
                        ; each character block for the line we are drawing

 JMP hlin8              ; Jump to hlin8 to draw the left end of the line into
                        ; the tile that we just copied

.hlin7

                        ; If we get here then we have either allocated a new
                        ; tile number for the line, or the tile number already
                        ; allocated to this part of the line is >= 60, which is
                        ; a dynamic tile into which we can draw
                        ;
                        ; In either case the tile number is in A

 LDX pattBufferHiDiv8   ; Set SC(1 0) = (pattBufferHiDiv8 A) * 8
 STX SC+1               ;             = (pattBufferHi 0) + A * 8
 ASL A                  ;
 ROL SC+1               ; So SC(1 0) is the address in the pattern buffer for
 ASL A                  ; tile number A (as each tile contains 8 bytes of
 ROL SC+1               ; pattern data), which means SC(1 0) points to the
 ASL A                  ; pattern data for the tile containing the line we are
 ROL SC+1               ; drawing
 STA SC

.hlin8

                        ; We now draw the left end of our horizontal line

 LDA X1                 ; Set X = X1 mod 8, which is the horizontal pixel number
 AND #7                 ; within the character block where the line starts (as
 TAX                    ; each pixel line in the character block is 8 pixels
                        ; wide)

 LDA TWFR,X             ; Fetch a ready-made byte with X pixels filled in at the
                        ; right end of the byte (so the filled pixels start at
                        ; point X and go all the way to the end of the byte),
                        ; which is the shape we want for the left end of the
                        ; line

 EOR (SC),Y             ; Store this into the pattern buffer at SC(1 0), using
 STA (SC),Y             ; EOR logic so it merges with whatever is already
                        ; on-screen, so we have now drawn the line's left cap

.hlin9

 INC SC2                ; Increment SC2(1 0) to point to the next tile number to
 BNE P%+4               ; the right in the nametable buffer
 INC SC2+1

 LDX R                  ; Fetch the number of character blocks in which we need
                        ; to draw, which we stored in R above

 DEX                    ; If R = 1, then we only have the right cap to draw, so
 BNE hlin10             ; jump to hlin17 to draw the right end of the line
 JMP hlin17

.hlin10

 STX R                  ; Otherwise we haven't reached the right end of the line
                        ; yet, so decrement R as we have just drawn one block

; ******************************************************************************
;
;       Name: HLOIN (Part 3 of 5)
;       Type: Subroutine
;   Category: Drawing lines
;    Summary: Draw the middle part of the line
;
; ******************************************************************************

                        ; We now draw the middle part of the line (i.e. the part
                        ; between the left and right caps)

.hlin11

 SETUP_PPU_FOR_ICON_BAR ; If the PPU has started drawing the icon bar, configure
                        ; the PPU to use nametable 0 and pattern table 0

 LDX #0                 ; If the nametable buffer entry is zero for the tile
 LDA (SC2,X)            ; containing the pixels that we want to draw, then a
 BEQ hlin13             ; tile has not yet been allocated to this entry, so jump
                        ; to hlin13 to allocate a new dynamic tile

                        ; If we get here then A contains the tile number that's
                        ; already allocated to this part of the line in the
                        ; nametable buffer

 CMP #60                ; If A < 60, then the tile that's already allocated is
 BCC hlin15             ; either an icon bar tile, or one of the pre-rendered
                        ; tiles containing horizontal and vertical line
                        ; patterns, so jump to hlin15 to process drawing on top
                        ; off the pre-rendered tile

                        ; If we get here then the tile number already allocated
                        ; to this part of the line is >= 60, which is a dynamic
                        ; tile into which we can draw
                        ;
                        ; The tile number is in A

 LDX pattBufferHiDiv8   ; Set SC(1 0) = (pattBufferHiDiv8 A) * 8
 STX SC+1               ;             = (pattBufferHi 0) + A * 8
 ASL A                  ;
 ROL SC+1               ; So SC(1 0) is the address in the pattern buffer for
 ASL A                  ; tile number A (as each tile contains 8 bytes of
 ROL SC+1               ; pattern data), which means SC(1 0) points to the
 ASL A                  ; pattern data for the tile containing the line we are
 ROL SC+1               ; drawing
 STA SC

 LDA #%11111111         ; Set A to a pixel byte containing eight pixels in a row

 EOR (SC),Y             ; Store this into the pattern buffer at SC(1 0), using
 STA (SC),Y             ; EOR logic so it merges with whatever is already
                        ; on-screen, so we have now drawn one character block
                        ; of the middle portion of the line

.hlin12

 INC SC2                ; Increment SC2(1 0) to point to the next tile number to
 BNE P%+4               ; the right in the nametable buffer
 INC SC2+1

 DEC R                  ; Decrement the number of character blocks in which we
                        ; need to draw, as we have just drawn one block

 BNE hlin11             ; If there are still more character blocks to draw, loop
                        ; back to hlin11 to draw the next one

 JMP hlin17             ; Otherwise we have finished drawing the middle portion
                        ; of the line, so jump to hlin17 to draw the right end
                        ; of the line

.hlin13

                        ; If we get here then there is no dynamic tile allocated
                        ; to the part of the line we want to draw, so we can use
                        ; one of the pre-rendered tiles that contains an 8-pixel
                        ; horizontal line on the correct pixel row
                        ;
                        ; We jump here with X = 0

 TYA                    ; Set A = Y + 37
 CLC                    ;
 ADC #37                ; Tiles 37 to 44 contain pre-rendered patterns as
                        ; follows:
                        ;
                        ;   * Tile 37 has a horizontal line on pixel row 0
                        ;   * Tile 38 has a horizontal line on pixel row 1
                        ;     ...
                        ;   * Tile 43 has a horizontal line on pixel row 6
                        ;   * Tile 44 has a horizontal line on pixel row 7
                        ;
                        ; So A contains the pre-rendered tile number that
                        ; contains an 8-pixel line on pixel row Y, and as Y
                        ; contains the offset of the pixel row for the line we
                        ; are drawing, this means A contains the correct tile
                        ; number for this part of the line

 STA (SC2,X)            ; Display the pre-rendered tile on-screen by setting
                        ; the nametable entry to A

 JMP hlin12             ; Jump up to hlin12 to move on to the next character
                        ; block to the right

.hlin14

                        ; If we get here then A + Y = 50, which means we can
                        ; alter the current pre-rendered tile to draw our line
                        ;
                        ; This is how it works. Tiles 44 to 51 contain
                        ; pre-rendered patterns as follows:
                        ;
                        ;   * Tile 44 has a horizontal line on pixel row 7
                        ;   * Tile 45 is filled from pixel row 7 to pixel row 6
                        ;   * Tile 46 is filled from pixel row 7 to pixel row 5
                        ;     ...
                        ;   * Tile 50 is filled from pixel row 7 to pixel row 1
                        ;   * Tile 51 is filled from pixel row 7 to pixel row 0
                        ;
                        ; Y contains the number of the pixel row for the line we
                        ; are drawing, so if A + Y = 50, this means:
                        ;
                        ;   * We want to draw pixel row 0 on top of tile 50
                        ;   * We want to draw pixel row 1 on top of tile 49
                        ;     ...
                        ;   * We want to draw pixel row 5 on top of tile 45
                        ;   * We want to draw pixel row 6 on top of tile 44
                        ;
                        ; In other words, if A + Y = 50, then we want to draw
                        ; the pixel row just above the rows that are already
                        ; filled in the pre-rendered pattern, which means we
                        ; can simply swap the pre-rendered pattern to the next
                        ; one in the list (e.g. going from four filled lines to
                        ; five filled lines, for example)
                        ;
                        ; We jump here with a BEQ, so the C flag is set for the
                        ; following addition, so the C flag can be used as the
                        ; plus 1 in the two's complement calculation

 TYA                    ; Set A = 51 + C + ~Y
 EOR #$FF               ;       = 51 + (1 + ~Y)
 ADC #51                ;       = 51 - Y
                        ;
                        ; So A contains the number of the pre-rendered tile that
                        ; has our horizontal line drawn on pixel row Y, and all
                        ; the lines below that filled, which is what we want

 STA (SC2,X)            ; Display the pre-rendered tile on-screen by setting
                        ; the nametable entry to A

 INC SC2                ; Increment SC2(1 0) to point to the next tile number to
 BNE P%+4               ; the right in the nametable buffer
 INC SC2+1

 DEC R                  ; Decrement the number of character blocks in which we
                        ; need to draw, as we have just drawn one block

 BNE hlin11             ; If there are still more character blocks to draw, loop
                        ; back to hlin11 to draw the next one

 JMP hlin17             ; Otherwise we have finished drawing the middle portion
                        ; of the line, so jump to hlin17 to draw the right end
                        ; of the line

.hlin15

                        ; If we get here then A <= 59, so the tile that's
                        ; already allocated is either an icon bar tile, or one
                        ; of the pre-rendered tiles containing horizontal and
                        ; vertical line patterns
                        ;
                        ; We jump here with the C flag clear, so the addition
                        ; below will work correctly, and with X = 0, so the
                        ; write to (SC2,X) will also work properly

 STA SC                 ; Set SC to the number of the tile that is already
                        ; allocated to this part of the screen, so we can
                        ; retrieve it later

 TYA                    ; If A + Y = 50, then we are drawing our line just
 ADC SC                 ; above the top line of a pre-rendered tile that is
 CMP #50                ; filled from the bottom row to the row just below Y,
 BEQ hlin14             ; so jump to hlin14 to switch this tile to another
                        ; pre-rendered tile that contains the line we want to
                        ; draw (see hlin14 for a full explanation of this logic)

                        ; If we get here then 37 <= A <= 59, so the tile that's
                        ; already allocated is one of the pre-rendered tiles
                        ; containing horizontal and vertical line patterns, but
                        ; isn't a tile we can simply replace with another
                        ; pre-rendered tile
                        ;
                        ; We don't want to draw over the top of the pre-rendered
                        ; patterns as that will break them, so instead we make a
                        ; copy of the pre-rendered tile's pattern in a newly
                        ; allocated dynamic tile, and then draw our line into
                        ; the dynamic tile, thus preserving what's already shown
                        ; on-screen while still drawing our new line

 LDA tileNumber         ; If tileNumber is zero then we have run out of dynamic
 BEQ hlin12             ; tiles for drawing lines and pixels, so jump to hlin12
                        ; to move right by one character block without drawing
                        ; anything, as we don't have enough dynamic tiles to
                        ; draw this part of the line

 INC tileNumber         ; Increment tileNumber to point to the next available
                        ; dynamic tile for drawing, so it can be used the next
                        ; time we need to draw lines or pixels into a tile

 STA (SC2,X)            ; Otherwise tileNumber contains the number of the next
                        ; available tile for drawing, so allocate this tile to
                        ; contain the pre-rendered tile that we want to copy by
                        ; setting the nametable entry to the tile number we just
                        ; fetched

 LDX pattBufferHiDiv8   ; Set SC3(1 0) = (pattBufferHiDiv8 A) * 8
 STX SC3+1              ;              = (pattBufferHi A) + A * 8
 ASL A                  ;
 ROL SC3+1              ; So SC3(1 0) is the address in the pattern buffer for
 ASL A                  ; tile number A (as each tile contains 8 bytes of
 ROL SC3+1              ; pattern data), which means SC3(1 0) points to the
 ASL A                  ; pattern data for the dynamic tile we just fetched
 ROL SC3+1
 STA SC3

 LDA SC                 ; Set A to the the number of the tile that is already
                        ; allocated to this part of the screen, which we stored
                        ; in SC above

 LDX pattBufferHiDiv8   ; Set SC(1 0) = (pattBufferHiDiv8 A) * 8
 STX SC+1               ;             = (pattBufferHi 0) + A * 8
 ASL A                  ;
 ROL SC+1               ; So SC(1 0) is the address in the pattern buffer for
 ASL A                  ; tile number A (as each tile contains 8 bytes of
 ROL SC+1               ; pattern data), which means SC(1 0) points to the
 ASL A                  ; pattern data for the tile containing the pre-rendered
 ROL SC+1               ; pattern that we want to copy
 STA SC

                        ; We now have a new dynamic tile in SC3(1 0) into which
                        ; we can draw the left end of our line, so we now need
                        ; to copy the pattern of the pre-rendered tile that we
                        ; want to draw on top of
                        ;
                        ; Each pattern is made up of eight bytes, so we simply
                        ; need to copy eight bytes from SC(1 0) to SC3(1 0)

 STY T                  ; Store Y in T so we can retrieve it after the following
                        ; loop

 LDY #7                 ; We now copy eight bytes from SC(1 0) to SC3(1 0), so
                        ; set a counter in Y

.hlin16

 LDA (SC),Y             ; Copy the Y-th byte of SC(1 0) to the Y-th byte of
 STA (SC3),Y            ; SC3(1 0)

 DEY                    ; Decrement the counter

 BPL hlin16             ; Loop back until we have copied all eight bytes

 LDY T                  ; Restore the value of Y from before the loop, so it
                        ; once again contains the pixel row offset within the
                        ; each character block for the line we are drawing

 LDA #%11111111         ; Set A to a pixel byte containing eight pixels in a row

 EOR (SC3),Y            ; Store this into the pattern buffer at SC3(1 0), using
 STA (SC3),Y            ; EOR logic so it merges with whatever is already
                        ; on-screen, so we have now drawn one character block
                        ; of the middle portion of the line

 JMP hlin12             ; Loop back to hlin12 to continue drawing  the line in
                        ; the next character block to the right

; ******************************************************************************
;
;       Name: HLOIN (Part 4 of 5)
;       Type: Subroutine
;   Category: Drawing lines
;    Summary: Draw the right end of the line
;
; ******************************************************************************

.hlin17

                        ; We now finish off the drawing process with the right
                        ; end of the line

 SETUP_PPU_FOR_ICON_BAR ; If the PPU has started drawing the icon bar, configure
                        ; the PPU to use nametable 0 and pattern table 0

 LDX #0                 ; If the nametable buffer entry is non-zero for the tile
 LDA (SC2,X)            ; containing the pixels that we want to draw, then a
 BNE hlin19             ; tile has already been allocated to this entry, so skip
                        ; the following

 LDA tileNumber         ; If tileNumber is zero then we have run out of tiles to
 BEQ hlin18             ; use for drawing lines and pixels, so jump to hlin30
                        ; via hlin18 to return from the subroutine, as we don't
                        ; have enough dynamic tiles to draw the right end of the
                        ; line

 STA (SC2,X)            ; Otherwise tileNumber contains the number of the next
                        ; available tile for drawing, so allocate this tile to
                        ; cover the pixels that we want to draw by setting the
                        ; nametable entry to the tile number we just fetched

 INC tileNumber         ; Increment tileNumber to point to the next available
                        ; dynamic tile for drawing, so it can be used the next
                        ; time we need to draw lines or pixels into a tile

 JMP hlin21             ; Jump to hlin21 to draw the right end of the line into
                        ; the newly allocated tile number in A

.hlin18

 JMP hlin30             ; Jump to hlin30 to return from the subroutine

.hlin19

                        ; If we get here then A contains the tile number that's
                        ; already allocated to this part of the line in the
                        ; nametable buffer

 CMP #60                ; If A >= 60, then the tile that's already allocated is
 BCS hlin21             ; oneof the tiles we have reserved for dynamic drawing,
                        ; so jump to hlin21 to draw the right end of the line

 CMP #37                ; If A < 37, then the tile that's already allocated is
 BCC hlin18             ; one of the icon bar tiles, so jump to hlin30 via
                        ; hlin18 to return from the subroutine, as we can't draw
                        ; on the icon bar

                        ; If we get here then 37 <= A <= 59, so the tile that's
                        ; already allocated is one of the pre-rendered tiles
                        ; containing horizontal and vertical line patterns
                        ;
                        ; We don't want to draw over the top of the pre-rendered
                        ; patterns as that will break them, so instead we make a
                        ; copy of the pre-rendered tile's pattern in a newly
                        ; allocated dynamic tile, and then draw our line into
                        ; the dynamic tile, thus preserving what's already shown
                        ; on-screen while still drawing our new line

 LDX pattBufferHiDiv8   ; Set SC3(1 0) = (pattBufferHiDiv8 A) * 8
 STX SC3+1              ;              = (pattBufferHi A) + A * 8
 ASL A                  ;
 ROL SC3+1              ; So SC3(1 0) is the address in the pattern buffer for
 ASL A                  ; tile number A (as each tile contains 8 bytes of
 ROL SC3+1              ; pattern data), which means SC3(1 0) points to the
 ASL A                  ; pattern data for the tile containing the pre-rendered
 ROL SC3+1              ; pattern that we want to copy
 STA SC3

 LDA tileNumber         ; If tileNumber is zero then we have run out of dynamic
 BEQ hlin18             ; tiles for drawing lines and pixels, so jump to hlin30
                        ; via hlin18 to return from the subroutine, as we don't
                        ; have enough dynamic tiles to draw the right end of the
                        ; line

 LDX #0                 ; Otherwise tileNumber contains the number of the next
 STA (SC2,X)            ; available tile for drawing, so allocate this tile to
                        ; contain the pre-rendered tile that we want to copy by
                        ; setting the nametable entry to the tile number we just
                        ; fetched

 INC tileNumber         ; Increment tileNumber to point to the next available
                        ; dynamic tile for drawing, so it can be used the next
                        ; time we need to draw lines or pixels into a tile

 LDX pattBufferHiDiv8   ; Set SC(1 0) = (pattBufferHiDiv8 A) * 8
 STX SC+1               ;             = (pattBufferHi 0) + A * 8
 ASL A                  ;
 ROL SC+1               ; So SC(1 0) is the address in the pattern buffer for
 ASL A                  ; tile number A (as each tile contains 8 bytes of
 ROL SC+1               ; pattern data), which means SC(1 0) points to the
 ASL A                  ; pattern data for the dynamic tile we just fetched
 ROL SC+1
 STA SC

                        ; We now have a new dynamic tile in SC(1 0) into which
                        ; we can draw the right end of our line, so we now need
                        ; to copy the pattern of the pre-rendered tile that we
                        ; want to draw on top of
                        ;
                        ; Each pattern is made up of eight bytes, so we simply
                        ; need to copy eight bytes from SC3(1 0) to SC(1 0)

 STY T                  ; Store Y in T so we can retrieve it after the following
                        ; loop

 LDY #7                 ; We now copy eight bytes from SC3(1 0) to SC(1 0), so
                        ; set a counter in Y

.hlin20

 LDA (SC3),Y            ; Copy the Y-th byte of SC3(1 0) to the Y-th byte of
 STA (SC),Y             ; SC(1 0)

 DEY                    ; Decrement the counter

 BPL hlin20             ; Loop back until we have copied all eight bytes

 LDY T                  ; Restore the value of Y from before the loop, so it
                        ; once again contains the pixel row offset within the
                        ; each character block for the line we are drawing

 JMP hlin22             ; Jump to hlin22 to draw the right end of the line into
                        ; the tile that we just copied

.hlin21

                        ; If we get here then we have either allocated a new
                        ; tile number for the line, or the tile number already
                        ; allocated to this part of the line is >= 60, which is
                        ; a dynamic tile into which we can draw
                        ;
                        ; In either case the tile number is in A

 LDX pattBufferHiDiv8   ; Set SC(1 0) = (pattBufferHiDiv8 A) * 8
 STX SC+1               ;             = (pattBufferHi 0) + A * 8
 ASL A                  ;
 ROL SC+1               ; So SC(1 0) is the address in the pattern buffer for
 ASL A                  ; tile number A (as each tile contains 8 bytes of
 ROL SC+1               ; pattern data), which means SC(1 0) points to the
 ASL A                  ; pattern data for the tile containing the line we are
 ROL SC+1               ; drawing
 STA SC

.hlin22

                        ; We now draw the right end of our horizontal line

 LDA X2                 ; Set X = X2 mod 8, which is the horizontal pixel number
 AND #7                 ; within the character block where the line ends (as
 TAX                    ; each pixel line in the character block is 8 pixels
                        ; wide)

 LDA TWFL,X             ; Fetch a ready-made byte with X pixels filled in at the
                        ; left end of the byte (so the filled pixels start at
                        ; the left edge and go up to point X), which is the
                        ; shape we want for the right end of the line

 JMP hlin29             ; Jump to hlin29 to poke the pixel byte into the pattern
                        ; buffer

; ******************************************************************************
;
;       Name: HLOIN (Part 5 of 5)
;       Type: Subroutine
;   Category: Drawing lines
;    Summary: Draw the line when it's all within one character block
;
; ******************************************************************************

.hlin23

                        ; If we get here then the line starts and ends in the
                        ; same character block

 SETUP_PPU_FOR_ICON_BAR ; If the PPU has started drawing the icon bar, configure
                        ; the PPU to use nametable 0 and pattern table 0

 LDX #0                 ; If the nametable buffer entry is non-zero for the tile
 LDA (SC2,X)            ; containing the pixels that we want to draw, then a
 BNE hlin25             ; tile has already been allocated to this entry, so skip
                        ; the following

 LDA tileNumber         ; If tileNumber is zero then we have run out of tiles to
 BEQ hlin24             ; use for drawing lines and pixels, so jump to hlin30
                        ; via hlin24 to return from the subroutine, as we don't
                        ; have enough dynamic tiles to draw the line

 STA (SC2,X)            ; Otherwise tileNumber contains the number of the next
                        ; available tile for drawing, so allocate this tile to
                        ; cover the pixels that we want to draw by setting the
                        ; nametable entry to the tile number we just fetched

 INC tileNumber         ; Increment tileNumber to point to the next available
                        ; dynamic tile for drawing, so it can be used the next
                        ; time we need to draw lines or pixels into a tile

 JMP hlin27             ; Jump to hlin27 to draw the line into the newly
                        ; allocated tile number in A

.hlin24

 JMP hlin30             ; Jump to hlin30 to return from the subroutine

.hlin25

                        ; If we get here then A contains the tile number that's
                        ; already allocated to this part of the line in the
                        ; nametable buffer

 CMP #60                ; If A >= 60, then the tile that's already allocated is
 BCS hlin27             ; one of the tiles we have reserved for dynamic drawing,
                        ; so jump to hlin27 to draw the line into the tile
                        ; number in A

 CMP #37                ; If A < 37, then the tile that's already allocated is
 BCC hlin24             ; one of the icon bar tiles, so jump to hlin30 via
                        ; hlin24 to return from the subroutine, as we can't draw
                        ; on the icon bar

                        ; If we get here then 37 <= A <= 59, so the tile that's
                        ; already allocated is one of the pre-rendered tiles
                        ; containing horizontal and vertical line patterns
                        ;
                        ; We don't want to draw over the top of the pre-rendered
                        ; patterns as that will break them, so instead we make a
                        ; copy of the pre-rendered tile's pattern in a newly
                        ; allocated dynamic tile, and then draw our line into
                        ; the dynamic tile, thus preserving what's already shown
                        ; on-screen while still drawing our new line

 LDX pattBufferHiDiv8   ; Set SC3(1 0) = (pattBufferHiDiv8 A) * 8
 STX SC3+1              ;              = (pattBufferHi A) + A * 8
 ASL A                  ;
 ROL SC3+1              ; So SC3(1 0) is the address in the pattern buffer for
 ASL A                  ; tile number A (as each tile contains 8 bytes of
 ROL SC3+1              ; pattern data), which means SC3(1 0) points to the
 ASL A                  ; pattern data for the tile containing the pre-rendered
 ROL SC3+1              ; pattern that we want to copy
 STA SC3

 LDA tileNumber         ; If tileNumber is zero then we have run out of dynamic
 BEQ hlin24             ; tiles for drawing lines and pixels, so jump to hlin30
                        ; via hlin24 to return from the subroutine, as we don't
                        ; have enough dynamic tiles to draw the line

 LDX #0                 ; Otherwise tileNumber contains the number of the next
 STA (SC2,X)            ; available tile for drawing, so allocate this tile to
                        ; contain the pre-rendered tile that we want to copy by
                        ; setting the nametable entry to the tile number we just
                        ; fetched

 INC tileNumber         ; Increment tileNumber to point to the next available
                        ; dynamic tile for drawing, so it can be used the next
                        ; time we need to draw lines or pixels into a tile

 LDX pattBufferHiDiv8   ; Set SC(1 0) = (pattBufferHiDiv8 A) * 8
 STX SC+1               ;             = (pattBufferHi 0) + A * 8
 ASL A                  ;
 ROL SC+1               ; So SC(1 0) is the address in the pattern buffer for
 ASL A                  ; tile number A (as each tile contains 8 bytes of
 ROL SC+1               ; pattern data), which means SC(1 0) points to the
 ASL A                  ; pattern data for the dynamic tile we just fetched
 ROL SC+1
 STA SC

                        ; We now have a new dynamic tile in SC(1 0) into which
                        ; we can draw our line, so we now need to copy the
                        ; pattern of the pre-rendered tile that we want to draw
                        ; on top of
                        ;
                        ; Each pattern is made up of eight bytes, so we simply
                        ; need to copy eight bytes from SC3(1 0) to SC(1 0)

 STY T                  ; Store Y in T so we can retrieve it after the following
                        ; loop

 LDY #7                 ; We now copy eight bytes from SC3(1 0) to SC(1 0), so
                        ; set a counter in Y

.hlin26

 LDA (SC3),Y            ; Copy the Y-th byte of SC3(1 0) to the Y-th byte of
 STA (SC),Y             ; SC(1 0)

 DEY                    ; Decrement the counter

 BPL hlin26             ; Loop back until we have copied all eight bytes

 LDY T                  ; Restore the value of Y from before the loop, so it
                        ; once again contains the pixel row offset within the
                        ; each character block for the line we are drawing

 JMP hlin28             ; Jump to hlin28 to draw the line into the tile that
                        ; we just copied

.hlin27

                        ; If we get here then we have either allocated a new
                        ; tile number for the line, or the tile number already
                        ; allocated to this part of the line is >= 60, which is
                        ; a dynamic tile into which we can draw
                        ;
                        ; In either case the tile number is in A

 LDX pattBufferHiDiv8   ; Set SC(1 0) = (pattBufferHiDiv8 A) * 8
 STX SC+1               ;             = (pattBufferHi 0) + A * 8
 ASL A                  ;
 ROL SC+1               ; So SC(1 0) is the address in the pattern buffer for
 ASL A                  ; tile number A (as each tile contains 8 bytes of
 ROL SC+1               ; pattern data), which means SC(1 0) points to the
 ASL A                  ; pattern data for the tile containing the line we are
 ROL SC+1               ; drawing
 STA SC

.hlin28

                        ; We now draw our horizontal line into the relevant
                        ; character block

 LDA X1                 ; Set X = X1 mod 8, which is the horizontal pixel number
 AND #7                 ; within the character block where the line starts (as
 TAX                    ; each pixel line in the character block is 8 pixels
                        ; wide)

 LDA TWFR,X             ; Fetch a ready-made byte with X pixels filled in at the
                        ; right end of the byte (so the filled pixels start at
                        ; point X and go all the way to the end of the byte),
                        ; which is the shape we want for the left end of the
                        ; line

 STA T                  ; Store the pixel shape for the right end of the line in
                        ; T

 LDA X2                 ; Set X = X2 mod 8, which is the horizontal pixel number
 AND #7                 ; within the character block where the line ends (as
 TAX                    ; each pixel line in the character block is 8 pixels
                        ; wide)

 LDA TWFL,X             ; Fetch a ready-made byte with X pixels filled in at the
                        ; left end of the byte (so the filled pixels start at
                        ; the left edge and go up to point X), which is the
                        ; shape we want for the right end of the line

 AND T                  ; Set A to the overlap of the pixel byte for the left
                        ; end of the line (in T) and the right end of the line
                        ; (in A) by AND'ing them together, which gives us the
                        ; pixels that are in the horizontal line we want to draw

.hlin29

 EOR (SC),Y             ; Store this into the pattern buffer at SC(1 0), using
 STA (SC),Y             ; EOR logic so it merges with whatever is already
                        ; on-screen, so we have now drawn our entire horizontal
                        ; line within this one character block

.hlin30

 SETUP_PPU_FOR_ICON_BAR ; If the PPU has started drawing the icon bar, configure
                        ; the PPU to use nametable 0 and pattern table 0

 LDY YSAV               ; Restore Y from YSAV, so that it's preserved

 RTS                    ; Return from the subroutine

; ******************************************************************************
;
;       Name: DrawVerticalLine
;       Type: Subroutine
;   Category: Drawing lines
;    Summary: ???
;
; ******************************************************************************

.DrawVerticalLine

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

 CMP #60
 BCS CE3F7
 CMP #37
 BCC CE3B4
 LDX pattBufferHiDiv8
 STX SC3+1
 ASL A
 ROL SC3+1
 ASL A
 ROL SC3+1
 ASL A
 ROL SC3+1
 STA SC3
 LDA tileNumber
 BEQ CE3B4
 LDX #0
 STA (SC2,X)
 INC tileNumber
 LDX pattBufferHiDiv8
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

 LDA (SC3),Y
 STA (SC),Y
 DEY
 BPL loop_CE3EB
 LDY T
 JMP CE406

.CE3F7

 LDX pattBufferHiDiv8
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
 CMP #60
 BCC CE4B4
 LDX pattBufferHiDiv8
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

 LDA (SC),Y             ; Draw a pixel at x-coordinate X into the Y-th byte
 ORA TWOS,X             ; of SC(1 0)
 STA (SC),Y

 INY                    ; Increment the index in Y

 LDA (SC),Y             ; Draw a pixel at x-coordinate X into the Y-th byte
 ORA TWOS,X             ; of SC(1 0)
 STA (SC),Y

 INY                    ; Increment the index in Y

 LDA (SC),Y             ; Draw a pixel at x-coordinate X into the Y-th byte
 ORA TWOS,X             ; of SC(1 0)
 STA (SC),Y

 INY                    ; Increment the index in Y

 LDA (SC),Y             ; Draw a pixel at x-coordinate X into the Y-th byte
 ORA TWOS,X             ; of SC(1 0)
 STA (SC),Y

 INY                    ; Increment the index in Y

 LDA (SC),Y             ; Draw a pixel at x-coordinate X into the Y-th byte
 ORA TWOS,X             ; of SC(1 0)
 STA (SC),Y

 INY                    ; Increment the index in Y

 LDA (SC),Y             ; Draw a pixel at x-coordinate X into the Y-th byte
 ORA TWOS,X             ; of SC(1 0)
 STA (SC),Y

 INY                    ; Increment the index in Y

 LDA (SC),Y             ; Draw a pixel at x-coordinate X into the Y-th byte
 ORA TWOS,X             ; of SC(1 0)
 STA (SC),Y

 INY                    ; Increment the index in Y

 LDA (SC),Y             ; Draw a pixel at x-coordinate X into the Y-th byte
 ORA TWOS,X             ; of SC(1 0)
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
 LDX pattBufferHiDiv8
 STX SC3+1
 ASL A
 ROL SC3+1
 ASL A
 ROL SC3+1
 ASL A
 ROL SC3+1
 STA SC3
 LDA SC
 LDX pattBufferHiDiv8
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
 STA (SC3),Y
 DEY
 BPL loop_CE4E4
 BMI CE4B1

; ******************************************************************************
;
;       Name: PIXEL
;       Type: Subroutine
;   Category: Drawing pixels
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

 LDX pattBufferHiDiv8
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
;   Category: Drawing pixels
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
;   Category: Dashboard
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
;   Category: Dashboard
;    Summary: ???
;
; ******************************************************************************

.MSBAR

 TYA
 PHA
 LDY missileNames,X
 PLA
 STA nameBuffer0+22*32,Y
 LDY #0
 RTS

; ******************************************************************************
;
;       Name: missileNames
;       Type: Variable
;   Category: Dashboard
;    Summary: ???
;
; ******************************************************************************

.missileNames

 EQUB $00, $5F, $5E, $3F, $3E

; ******************************************************************************
;
;       Name: autoplayKeys_EN
;       Type: Variable
;   Category: Demo
;    Summary: ???
;
; ******************************************************************************

.autoplayKeys_EN

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
;       Name: autoplayKeys_DE
;       Type: Variable
;   Category: Demo
;    Summary: ???
;
; ******************************************************************************

.autoplayKeys_DE

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
;       Name: autoplayKeys_FR
;       Type: Variable
;   Category: Demo
;    Summary: ???
;
; ******************************************************************************

.autoplayKeys_FR

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
;       Name: autoplayKeys_ALL
;       Type: Variable
;   Category: Demo
;    Summary: ???
;
; ******************************************************************************

.autoplayKeys_ALL

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
;       Name: AutoPlayDemo
;       Type: Subroutine
;   Category: Demo
;    Summary: Automatically play the demo using the key presses from the
;             autoplayKeys tables
;
; ******************************************************************************

.AutoPlayDemo

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
 STA autoPlayDemo
 RTS

.CE822

 LDX L04BD
 BNE CE83F
 LDY #0
 LDA (autoplayKeys),Y
 BMI CE878
 STA L04BC
 INY
 LDA (autoplayKeys),Y
 SEC
 TAX

.CE835

 LDA #1

.CE837

 ADC autoplayKeys
 STA autoplayKeys
 BCC CE83F
 INC autoplayKeys+1

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
 LDA (autoplayKeys),Y
 STA L04BC
 INY
 LDA (autoplayKeys),Y
 STA addr
 INY
 LDA (autoplayKeys),Y
 STA addr+1
 LDY #0
 LDX #1
 PLA
 CMP #8
 BCS CE8AC
 LDA (addr),Y
 BNE CE83F

.CE8A7

 LDA #4
 CLC
 BCC CE837

.CE8AC

 BNE CE8B4
 LDA (addr),Y
 BEQ CE83F
 BNE CE8A7

.CE8B4

 CMP #$10
 BCS CE8BE
 LDA (addr),Y
 BMI CE83F
 BPL CE8A7

.CE8BE

 BNE CE8C7
 LDA (addr),Y
 BMI CE8A7
 JMP CE83F

.CE8C7

 LDA #$C0
 STA controller1Start
 LDX #$16
 CLC
 BCC CE87F

.CE8D1

 LDA #HI(autoplayKeys_ALL)
 STA autoplayKeys+1
 LDA #LO(autoplayKeys_ALL)
 STA autoplayKeys
 RTS

.CE8DA

 STA autoPlayDemo
 RTS

; ******************************************************************************
;
;       Name: SetPointerButton
;       Type: Subroutine
;   Category: Icon bar
;    Summary: ???
;
; ******************************************************************************

.SetPointerButton

 LDA controller1Start   ; If the Start button on controller 1 was being held
 AND #%11000000         ; down (bit 6 is set) but is no longer being held down
 CMP #%01000000         ; (bit 7 is clear) then keep going, otherwise jump to
 BNE CE8EE              ; CE8EE

 LDA #80
 STA pointerButton
 BNE CE8FA

.CE8EE

 LDA pointerButton
 CMP #80
 BEQ CE8FA

.CE8F5

 LDA #0
 STA pointerButton

.CE8FA

 LDA #240               ; Set A to the y-coordinate that's just below the bottom
                        ; of the screen, so we can hide the icon bar pointer
                        ; sprites by moving them off-screen

 STA ySprite1           ; Set the y-coordinates for the four icon bar pointer
 STA ySprite2           ; sprites to 240, to move them off-screen
 STA ySprite3
 STA ySprite4

 RTS                    ; Return from the subroutine

; ******************************************************************************
;
;       Name: SetIconBarPointer
;       Type: Subroutine
;   Category: Icon bar
;    Summary: Set the icon bar pointer to a specific position
;
; ------------------------------------------------------------------------------
;
; Arguments:
;
;   A                   The button number on which to position the pointer
;
; ******************************************************************************

.SetIconBarPointer

 ASL A                  ; Set xIconBarPointer =  A * 4
 ASL A                  ;
 STA xIconBarPointer    ; As xIconBarPointer contains the x-coordinate of the
                        ; icon bar pointer, incrementing by 4 for each button

 LDX #0                 ; Zero all the pointer timer and movement variables so
 STX pointerPosition    ; the pointer is static and in the correct position
 STX pointerDirection
 STX L0468
 STX pointerTimer

IF _PAL

 STX pointerTimerOn     ; Zero the PAL-specific pointer timer variable

ENDIF

 RTS                    ; Return from the subroutine

; ******************************************************************************
;
;       Name: MoveIconBarPointer
;       Type: Subroutine
;   Category: Icon bar
;    Summary: Move the sprites that make up the icon bar pointer
;
; ******************************************************************************

.MoveIconBarPointer

 DEC pointerTimer

IF _PAL

 BNE CE928
 LSR pointerTimerOn

.CE928

ENDIF

 BPL CE925
 INC pointerTimer

.CE925

 DEC pointerPosition
 BPL CE92D
 INC pointerPosition

.CE92D

 LDA L0473
 BMI CE8F5

 LDA L045F
 BEQ SetPointerButton

 LDA pointerDirection
 CLC
 ADC xIconBarPointer
 STA xIconBarPointer

 AND #3
 BNE CE98D

 LDA #0
 STA pointerDirection

 LDA pointerPosition
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

 CPX #%10000000
 BNE CE96F

 LDX #12
 STX pointerPosition

.CE96F

 STA pointerDirection

.CE972

 LDX controller1Right
 BMI CE97F

 LDA #0
 STA controller1Right

 JMP CE98D

.CE97F

 LDA #1

 CPX #%10000000
 BNE CE98A

 LDX #12
 STX pointerPosition

.CE98A

 STA pointerDirection

.CE98D

 LDA xIconBarPointer
 BPL CE999

 LDA #0
 STA pointerDirection

 BEQ CE9A4

.CE999

 CMP #45
 BCC CE9A4

 LDA #0
 STA pointerDirection

 LDA #44

.CE9A4

 STA xIconBarPointer

 LDA xIconBarPointer
 AND #3
 ORA pointerDirection
 BNE CEA04

 LDA controller1B
 BMI CEA04

 LDA controller1B
 BMI CEA04

 LDA controller1Select
 BNE CEA04

 LDA #251
 STA tileSprite1
 STA tileSprite2

 LDA yIconBarPointer
 CLC

 ADC #11+YPAL
 STA ySprite1
 STA ySprite2

 LDA xIconBarPointer
 ASL A
 ASL A
 ADC xIconBarPointer
 ADC #6
 STA xSprite4

 ADC #1
 STA xSprite1

 ADC #13
 STA xSprite2

 ADC #1
 STA xSprite3

 LDA yIconBarPointer
 CLC
 ADC #19+YPAL
 STA ySprite4
 STA ySprite3

 LDA xIconBarPointer
 BNE CEA40

 JMP CEA40

.CEA04

 LDA #252
 STA tileSprite1
 STA tileSprite2

 LDA yIconBarPointer
 CLC

 ADC #8+YPAL
 STA ySprite1
 STA ySprite2

 LDA xIconBarPointer
 ASL A
 ASL A
 ADC xIconBarPointer
 ADC #6
 STA xSprite4

 ADC #1
 STA xSprite1

 ADC #13
 STA xSprite2

 ADC #1
 STA xSprite3

 LDA yIconBarPointer
 CLC
 ADC #16+YPAL
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
 AND #%11110000
 CMP #%10000000
 BEQ CEA73

 LDA controller1B
 AND #%11000000
 CMP #%10000000
 BNE CEA6A

 LDA #30
 STA L0468

.CEA6A

 CMP #%01000000
 BNE CEA7E

IF _NTSC

 LDA L0468
 BEQ CEA7E

.CEA73

ELIF _PAL

 LDA L0468
 BNE CEA80

 STA pointerTimerOn
 BEQ CEA7E

.CEA80

 LDA #40
 STA pointerTimer

 LDA pointerTimerOn
 BNE CEA73

 INC pointerTimerOn
 BNE CEA7E

.CEA73

 LSR pointerTimerOn

ENDIF

 LDA xIconBarPointer    ; Set Y to the button number that the icon bar pointer
 LSR A                  ; is over
 LSR A
 TAY

 LDA (barButtons),Y     ; Set pointerButton to the Y-th entry from the button
 STA pointerButton      ; table for this icon bar

.CEA7E

 LDA controller1Start   ; If the Start button on controller 1 was being held
 AND #%11000000         ; down (bit 6 is set) but is no longer being held down
 CMP #%01000000         ; (bit 7 is clear) then keep going, otherwise jump to
 BNE CEA8C              ; CEA8C

 LDA #80
 STA pointerButton

.CEA8C

 RTS

; ******************************************************************************
;
;       Name: ScaleController
;       Type: Subroutine
;   Category: Keyboard
;    Summary: ???
;
; ******************************************************************************

.ScaleController

 LDA controller1B
 BNE CEAA7

 LDA controller1Left
 ASL A
 ASL A
 ASL A
 ASL A
 STA controller1Leftx8

 LDA controller1Right
 ASL A
 ASL A
 ASL A
 ASL A
 STA controller1Rightx8

 RTS

.CEAA7

 LDA #0
 STA controller1Leftx8
 STA controller1Rightx8

 RTS

; ******************************************************************************
;
;       Name: UpdateJoystick
;       Type: Subroutine
;   Category: Keyboard
;    Summary: Update the values of JSTX and JSTY with the values from the
;             controller
;
; ******************************************************************************

.UpdateJoystick

 LDA QQ11a
 BNE ScaleController
 LDX JSTX
 LDA #8
 STA addr
 LDY scanController2
 BNE CEAC5
 LDA controller1B
 BMI CEB0C

.CEAC5

 LDA controller1Right,Y
 BPL CEACD
 JSR DecreaseX

.CEACD

 LDA controller1Left,Y
 BPL CEAD5
 JSR IncreaseX

.CEAD5

 STX JSTX
 TYA
 BNE CEADB

.CEADB

 LDA #4
 STA addr
 LDX JSTY
 LDA JSTGY
 BMI CEAFB
 LDA controller1Down,Y
 BPL CEAEF
 JSR DecreaseX

.CEAEF

 LDA controller1Up,Y
 BPL CEAF7

.loop_CEAF4

 JSR IncreaseX

.CEAF7

 STX JSTY
 RTS

.CEAFB

 LDA controller1Up,Y
 BPL CEB03
 JSR DecreaseX

.CEB03

 LDA controller1Down,Y
 BMI loop_CEAF4
 STX JSTY
 RTS

.CEB0C

 RTS

; ******************************************************************************
;
;       Name: IncreaseX
;       Type: Subroutine
;   Category: Keyboard
;    Summary: ???
;
; ******************************************************************************

.IncreaseX

 TXA
 CLC
 ADC addr
 TAX
 BCC CEB16
 LDX #$FF

.CEB16

 BPL CEB24
 RTS

; ******************************************************************************
;
;       Name: DecreaseX
;       Type: Subroutine
;   Category: Keyboard
;    Summary: ???
;
; ******************************************************************************

.DecreaseX

 TXA
 SEC
 SBC addr
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
;       Name: iconBarButtons
;       Type: Variable
;   Category: Icon bar
;    Summary: A list of button numbers for each icon bar type
;
; ******************************************************************************

.iconBarButtons

                        ; Icon bar 0 (docked)

 EQUB  1                ; Launch
 EQUB  2                ; Market Price
 EQUB  3                ; Status Mode
 EQUB  4                ; Charts
 EQUB  5                ; Equip Ship
 EQUB  6                ; Save and load
 EQUB  7                ; Change commander name (only on save screen)
 EQUB 35                ; Data on System
 EQUB  8                ; Inventory
 EQUB  0                ; (blank)
 EQUB  0                ; (blank)
 EQUB 12                ; Fast forward

 EQUD  0

                        ; Icon bar 1 (flight)

 EQUB 17                ; Docking computer
 EQUB  2                ; Market Price
 EQUB  3                ; Status Mode
 EQUB  4                ; Charts
 EQUB 21                ; Front space view (and rear, left, right)
 EQUB 22                ; Hyperspace (only when system is selected)
 EQUB 23                ; E.C.M. (if fitted)
 EQUB 24                ; Target missile
 EQUB 25                ; Fire targetted missile
 EQUB 26                ; Energy bomb (if fitted)
 EQUB 27                ; Escape capsule (if fitted)
 EQUB 12                ; Fast forward

 EQUD  0

                        ; Icon bar 2 (charts)

 EQUB  1                ; Launch
 EQUB  2                ; Market Price
 EQUB 36                ; Switch chart range (long, short)
 EQUB 35                ; Data on System
 EQUB 21                ; Front space view (only in flight)
 EQUB 38                ; Return pointer to current system
 EQUB 39                ; Search for system
 EQUB 22                ; Hyperspace (only when system is selected)
 EQUB 41                ; Galactic Hyperspace (if fitted)
 EQUB 23                ; E.C.M. (if fitted)
 EQUB 27                ; Escape capsule (if fitted)
 EQUB 12                ; Fast forward

 EQUD  0

                        ; Icon bar 3 (pause options)

 EQUB 49                ; Direction of y-axis
 EQUB 50                ; Damping toggle
 EQUB 51                ; Music toggle
 EQUB 52                ; Sound toggle
 EQUB 53                ; Number of pilots
 EQUB  0                ; (blank)
 EQUB  0                ; (blank)
 EQUB  0                ; (blank)
 EQUB  0                ; (blank)
 EQUB  0                ; (blank)
 EQUB  0                ; (blank)
 EQUB 60                ; Restart

 EQUD  0

; ******************************************************************************
;
;       Name: HideStardust
;       Type: Subroutine
;   Category: Stardust
;    Summary: Hide the stardust sprites
;
; ******************************************************************************

.HideStardust

 SETUP_PPU_FOR_ICON_BAR ; If the PPU has started drawing the icon bar, configure
                        ; the PPU to use nametable 0 and pattern table 0

 LDX NOSTM              ; Set X = NOSTM so we hide NOSTM+1 sprites

 LDY #152               ; Set Y so we start hiding from sprite 152 / 4 = 38

                        ; Fall through into HideSpritesPlus1 to hide NOSTM+1
                        ; sprites from sprite 38 onwards (i.e. 38 to 58 in
                        ; normal space when NOSTM is 20, or 38 to 41 in
                        ; witchspace when NOSTM is 3)

; ******************************************************************************
;
;       Name: HideSpritesPlus1
;       Type: Subroutine
;   Category: Drawing sprites
;    Summary: Hide X + 1 sprites from sprite Y / 4 onwards
;
; ------------------------------------------------------------------------------
;
; This routine is similar to HideSprites, except it hides X + 1 sprites rather
; than X sprites.
;
; Arguments:
;
;   X                   The number of sprites to hide (we hide X + 1)
;
;   Y                   The number of the first sprite to hide * 4
;
; ******************************************************************************

.HideSpritesPlus1

 LDA #240               ; Set A to the y-coordinate that's just below the bottom
                        ; of the screen, so we can hide the required sprites by
                        ; moving them off-screen

.hisp1

 STA ySprite0,Y         ; Set the y-coordinate for sprite Y / 4 to 240 to hide
                        ; it (the division by four is because each sprite in the
                        ; sprite buffer has four bytes of data)

 INY                    ; Add 4 to Y so it points to the next sprite's data in
 INY                    ; the sprite buffer
 INY
 INY

 DEX                    ; Decrement the loop counter in X

 BPL hisp1              ; Loop back until we have hidden X + 1 sprites

 RTS                    ; Return from the subroutine

; ******************************************************************************
;
;       Name: HideMostSprites1
;       Type: Subroutine
;   Category: Drawing sprites
;    Summary: Fetch the palettes if we are changing view and hide all sprites
;
; ******************************************************************************

.HideMostSprites1

 LDA QQ11a              ; If QQ11 = QQ11a, then we are not currently changing
 CMP QQ11               ; view, so jump to HideMostSprites to hide all sprites
 BEQ HideMostSprites    ; except for sprite 0 and the icon bar pointer

                        ; Otherwise fall through into HideMostSprites2 to fetch
                        ; the palettes and then hide all the sprites ???

; ******************************************************************************
;
;       Name: HideMostSprites2
;       Type: Subroutine
;   Category: Drawing sprites
;    Summary: Fetch the palettes and hide all sprites
;
; ******************************************************************************

.HideMostSprites2

 JSR FetchPalettes1_b3  ; ???

; ******************************************************************************
;
;       Name: HideMostSprites
;       Type: Subroutine
;   Category: Drawing sprites
;    Summary: Hide all sprites except for sprite 0 and the icon bar pointer
;
; ******************************************************************************

.HideMostSprites

 SETUP_PPU_FOR_ICON_BAR ; If the PPU has started drawing the icon bar, configure
                        ; the PPU to use nametable 0 and pattern table 0

 LDX #58                ; Set X = 58 so we hide 59 sprites

 LDY #20                ; Set Y so we start hiding from sprite 20 / 4 = 5

 BNE HideSpritesPlus1   ; Jump to HideSpritesPlus1 to hide 59 sprites from
                        ; sprite 5 onwards (i.e. sprites 5 to 63, which only
                        ; leaves sprite 0 and the icon bar pointer sprites 1 to
                        ; 4)
                        ;
                        ; We return from the subroutine using a tail call

; ******************************************************************************
;
;       Name: DELAY
;       Type: Subroutine
;   Category: Utility routines
;    Summary: Wait until a specified number of NMI interrupts have passed (i.e.
;             a specified number of VBlanks)
;
; ------------------------------------------------------------------------------
;
; Arguments:
;
;   Y                   The number of NMI interrupts to wait for
;
; ******************************************************************************

.DELAY

 JSR WaitForNMI         ; Wait until the next NMI interrupt has passed (i.e. the
                        ; next VBlank)

 DEY                    ; Decrement the counter in Y

 BNE DELAY              ; If Y isn't yet at zero, jump back to DELAY to wait
                        ; for another NMI interrupt

 RTS                    ; Return from the subroutine

; ******************************************************************************
;
;       Name: BEEP
;       Type: Subroutine
;   Category: Sound
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
;   Category: Sound
;    Summary: ???
;
; ******************************************************************************

.EXNO3

 LDY #13
 BNE NOISE

; ******************************************************************************
;
;       Name: FlushSoundChannels
;       Type: Subroutine
;   Category: Sound
;    Summary: ???
;
; ******************************************************************************

.FlushSoundChannels

 LDX #0
 JSR FlushSoundChannel

.loop_CEBB6

 LDX #1
 JSR FlushSoundChannel

 LDX #2
 BNE FlushSoundChannel

; ******************************************************************************
;
;       Name: ECBLB
;       Type: Subroutine
;   Category: Dashboard
;    Summary: ???
;
; ******************************************************************************

.ECBLB

 LDX soundLookup1,Y

 CPX #3
 BCC FlushSoundChannel

 BNE loop_CEBB6

 LDX #0
 JSR FlushSoundChannel

 LDX #2

; ******************************************************************************
;
;       Name: FlushSoundChannel
;       Type: Subroutine
;   Category: Sound
;    Summary: ???
;
; ******************************************************************************

.FlushSoundChannel

 SETUP_PPU_FOR_ICON_BAR ; If the PPU has started drawing the icon bar, configure
                        ; the PPU to use nametable 0 and pattern table 0

 LDA #0
 STA soundPriority,X

 LDA #26
 BNE CEC2B

; ******************************************************************************
;
;       Name: BOOP
;       Type: Subroutine
;   Category: Sound
;    Summary: ???
;
; ******************************************************************************

.BOOP

 LDY #4
 BNE NOISE

; ******************************************************************************
;
;       Name: MakeScoopSound
;       Type: Subroutine
;   Category: Sound
;    Summary: ???
;
; ******************************************************************************

.MakeScoopSound

 LDY #1
 BNE NOISE

; ******************************************************************************
;
;       Name: HyperspaceSound
;       Type: Subroutine
;   Category: Sound
;    Summary: Make the hyperspace sound
;
; ******************************************************************************

.HyperspaceSound

 JSR FlushSoundChannels

 LDY #21

; ******************************************************************************
;
;       Name: NOISE
;       Type: Subroutine
;   Category: Sound
;    Summary: ???
;
; ******************************************************************************

.NOISE

 LDA DNOIZ
 BPL CEC2E
 LDX soundLookup1,Y
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
 LDA soundLookup2,Y
 CMP soundPriority,X
 BCC CEC2E

.CEC17

 LDA soundLookup2,Y
 STA soundPriority,X

 SETUP_PPU_FOR_ICON_BAR ; If the PPU has started drawing the icon bar, configure
                        ; the PPU to use nametable 0 and pattern table 0

 TYA

.CEC2B

 JSR MakeNoise_b6

.CEC2E

 SETUP_PPU_FOR_ICON_BAR ; If the PPU has started drawing the icon bar, configure
                        ; the PPU to use nametable 0 and pattern table 0

 RTS

; ******************************************************************************
;
;       Name: soundLookup1
;       Type: Variable
;   Category: Sound
;    Summary: ???
;
; ******************************************************************************

.soundLookup1

 EQUB 2, 1, 1, 1, 1, 0, 0, 1, 2, 2, 2, 2, 3   ; EC3C: 02 01 01... ...
 EQUB 2, 2, 0, 0, 0, 0, 0, 2, 3, 3, 2, 1, 2   ; EC49: 02 02 00... ...
 EQUB 0, 2, 0, 1, 0, 0                        ; EC56: 00 02 00... ...

; ******************************************************************************
;
;       Name: soundLookup2
;       Type: Variable
;   Category: Sound
;    Summary: ???
;
; ******************************************************************************

.soundLookup2

 EQUB $80, $82, $C0, $21, $21, $10, $10, $41  ; EC5C: 80 82 C0... ...
 EQUB $82, $32, $84, $20, $C0, $60, $40, $80  ; EC64: 82 32 84... .2.
 EQUB $80, $80, $80, $90, $84, $33, $33, $20  ; EC6C: 80 80 80... ...
 EQUB $C0, $18, $10, $10, $10, $10, $10, $60  ; EC74: C0 18 10... ...
 EQUB $60                                     ; EC7C: 60          `

; ******************************************************************************
;
;       Name: SetupPPUForIconBar
;       Type: Subroutine
;   Category: Icon bar
;    Summary: If the PPU has started drawing the icon bar, configure the PPU to
;             use nametable 0 and pattern table 0, while preserving A
;
; ******************************************************************************

.SetupPPUForIconBar

 PHA                    ; Store the value of A on the stack so we can retrieve
                        ; it below

 SETUP_PPU_FOR_ICON_BAR ; If the PPU has started drawing the icon bar, configure
                        ; the PPU to use nametable 0 and pattern table 0

 PLA                    ; Retrieve the value of A from the stack so it is
                        ; unchanged

 RTS                    ; Return from the subroutine

; ******************************************************************************
;
;       Name: GetShipBlueprint
;       Type: Subroutine
;   Category: Drawing ships
;    Summary: Fetch a specified byte from the current ship blueprint
;
; ------------------------------------------------------------------------------
;
; Arguments:
;
;   Y                   The offset of the byte to return from the blueprint
;
; Returns:
;
;   A                   The Y-th byte of the current ship blueprint
;
; ******************************************************************************

.GetShipBlueprint

 LDA currentBank        ; Fetch the number of the ROM bank that is currently
 PHA                    ; paged into memory at $8000 and store it on the stack

 LDA #1                 ; Page ROM bank 1 into memory at $8000
 JSR SetBank

 LDA (XX0),Y            ; Set A to the Y-th byte of the current ship blueprint

                        ; Fall through into ResetBankA to retrieve the bank
                        ; number we stored above and page it back into memory

; ******************************************************************************
;
;       Name: ResetBankA
;       Type: Subroutine
;   Category: Utility routines
;    Summary: Page a specified bank into memory at $8000 while preserving the
;             value of A
;
; ------------------------------------------------------------------------------
;
; Arguments:
;
;   Stack               The number of the bank to page into memory at $8000
;
; ******************************************************************************

.ResetBankA

 STA ASAV               ; Store the value of A so we can retrieve it below

 PLA                    ; Fetch the ROM bank number from the stack

 JSR SetBank            ; Page bank A into memory at $8000

 LDA ASAV               ; Restore the value of A that we stored above

 RTS                    ; Return from the subroutine

; ******************************************************************************
;
;       Name: GetDefaultNEWB
;       Type: Subroutine
;   Category: Drawing ships
;    Summary: Fetch the default NEWB flags for a specified ship type
;
; ------------------------------------------------------------------------------
;
; Arguments:
;
;   Y                   The ship type
;
; Returns:
;
;   A                   The default NEWB flags for ship type Y
;
; ******************************************************************************

.GetDefaultNEWB

 LDA currentBank        ; Fetch the number of the ROM bank that is currently
 PHA                    ; paged into memory at $8000 and store it on the stack

 LDA #1                 ; Page ROM bank 1 into memory at $8000
 JSR SetBank

 LDA E%-1,Y             ; Set A to the default NEWB flags for ship type Y

 JMP ResetBankA         ; Jump to ResetBankA to retrieve the bank number we
                        ; stored above and page it back into memory, returning
                        ; from the subroutine using a tail call

; ******************************************************************************
;
;       Name: IncreaseTally
;       Type: Subroutine
;   Category: Status
;    Summary: Add the kill count to the fractional and low bytes of our combat
;             rank tally following a kill
;
; ------------------------------------------------------------------------------
;
; Arguments:
;
;   X                   The type of the ship that was killed
;
;
; Returns:
;
;   C flag              If set, the addition overflowed
;
; ******************************************************************************

.IncreaseTally

 SETUP_PPU_FOR_ICON_BAR ; If the PPU has started drawing the icon bar, configure
                        ; the PPU to use nametable 0 and pattern table 0

 LDA currentBank        ; Fetch the number of the ROM bank that is currently
 PHA                    ; paged into memory at $8000 and store it on the stack

 LDA #1                 ; Page ROM bank 1 into memory at $8000
 JSR SetBank

                        ; Ihe fractional kill count is taken from the KWL%
                        ; table, according to the ship's type (we look up the
                        ; X-1-th value from KWL% because ship types start at 1
                        ; rather than 0)

 LDA KWL%-1,X           ; Double the fractional kill count and push the low byte
 ASL A                  ; onto the stack
 PHA

 LDA KWH%-1,X           ; Double the integer kill count and put the high byte
 ROL A                  ; in Y
 TAY

 PLA                    ; Add the doubled fractional kill count to our tally,
 ADC TALLYL             ; starting by adding the fractional bytes:
 STA TALLYL             ;
                        ;   TALLYL = TALLYL + fractional kill count

 TYA                    ; And then we add the low byte of TALLY(1 0):
 ADC TALLY              ;
 STA TALLY              ;   TALLY = TALLY + carry + integer kill count

                        ; Fall through into ResetBankP to reset the ROM bank to
                        ; the value we stored on the stack

; ******************************************************************************
;
;       Name: ResetBankP
;       Type: Subroutine
;   Category: Utility routines
;    Summary: Page a specified bank into memory at $8000 while preserving the
;             value of A and the processor flags
;
; ------------------------------------------------------------------------------
;
; Arguments:
;
;   Stack               The number of the bank to page into memory at $8000
;
; Other entry points:
;
;   RTS4                Contains an RTS
;
; ******************************************************************************

.ResetBankP

 PLA                    ; Fetch the ROM bank number from the stack

 PHP                    ; Store the processor flags on the stack so we can
                        ; retrieve them below

 JSR SetBank            ; Page bank A into memory at $8000

 PLP                    ; Restore the processor flags, so we return the correct
                        ; Z and N flags for the value of A

.RTS4

 RTS                    ; Return from the subroutine

; ******************************************************************************
;
;       Name: CheckPauseButton
;       Type: Subroutine
;   Category: Keyboard
;    Summary: Pause the game if the icon bar pointer is not over a blank button
;             and the pause button is pressed
;
; ******************************************************************************

.CheckPauseButton

 LDA pointerButton      ; If pointerButton = 0 then the icon bar pointer is over
 BEQ RTS4               ; a blank button, so jump to RTS4 to return from the
                        ; subroutine

                        ; Otherwise fall through into CheckForPause_b0 to pause
                        ; the game if the pause button is pressed

; ******************************************************************************
;
;       Name: CheckForPause_b0
;       Type: Subroutine
;   Category: Keyboard
;    Summary: Call the CheckForPause routine in ROM bank 0
;
; ------------------------------------------------------------------------------
;
; Returns:
;
;   N, Z flags          Set according to the value of A passed to the routine
;
; ******************************************************************************

.CheckForPause_b0

 STA ASAV               ; Store the value of A so we can retrieve it below

 LDA currentBank        ; Fetch the number of the ROM bank that is currently
 PHA                    ; paged into memory at $8000 and store it on the stack

 LDA #0                 ; Page ROM bank 0 into memory at $8000
 JSR SetBank

 LDA ASAV               ; Restore the value of A that we stored above

 JSR CheckForPause      ; Call CheckForPause, now that it is paged into memory

 JMP ResetBankP         ; Jump to ResetBankP to retrieve the bank number we
                        ; stored above, page it back into memory and set the
                        ; processor flags according to the value of A, returning
                        ; from the subroutine using a tail call

; ******************************************************************************
;
;       Name: DrawInventoryIcon
;       Type: Subroutine
;   Category: Icon bar
;    Summary: Draw the inventory icon on top of the second button in the icon
;             bar
;
; ******************************************************************************

.DrawInventoryIcon

                        ; We draw the inventory icon image from sprites with
                        ; sequential patterns, so first we configure the
                        ; variables to pass to the DrawSpriteImage routine

 LDA #2                 ; Set K = 2, to pass as the number of columns in the
 STA K                  ; image to DrawSpriteImage below

 STA K+1                ; Set K+1 = 2, to pass as the number of rows in the
                        ; image to DrawSpriteImage below

 LDA #69                ; Set K+2 = 69, so we draw the face image using
 STA K+2                ; pattern #69 onwards

 LDA #8                 ; Set K+3 = 8, so we build the image from sprite 8
 STA K+3                ; onwards

 LDA #3                 ; Set XC = 3 so we draw the image with the top-left
 STA XC                 ; corner in tile column 3

 LDA #25                ; Set YC = 25 so we draw the image with the top-left
 STA YC                 ; corner on tile row 25

 LDX #7                 ; Set X = 7 so we draw the image seven pixels into the
                        ; (XC, YC) character block along the x-axis

 LDY #7                 ; Set Y = 7 so we draw the image seven pixels into the
                        ; (XC, YC) character block along the y-axis

 JMP DrawSpriteImage_b6 ; Draw the inventory icon from sprites, using pattern
                        ; #69 onwards, returning from the subroutine using a
                        ; tail call

; ******************************************************************************
;
;       Name: PlayMusic_b6
;       Type: Subroutine
;   Category: Sound
;    Summary: Call the PlayMusic routine in ROM bank 6
;
; ******************************************************************************

.PlayMusic_b6

 LDA currentBank        ; Fetch the number of the ROM bank that is currently
 PHA                    ; paged into memory at $8000 and store it on the stack

 LDA #6                 ; Page ROM bank 6 into memory at $8000
 JSR SetBank

 JSR PlayMusic          ; Call PlayMusic, now that it is paged into memory

 JMP ResetBank          ; Fetch the previous ROM bank number from the stack and
                        ; page that bank back into memory at $8000, returning
                        ; from the subroutine using a tail call

; ******************************************************************************
;
;       Name: ChooseMusic_b6
;       Type: Subroutine
;   Category: Sound
;    Summary: Call the ChooseMusic routine in ROM bank 6
;
; ******************************************************************************

.ChooseMusic_b6

 PHA                    ; Wait until the next NMI interrupt has passed (i.e. the
 JSR WaitForNMI         ; next VBlank), preserving the value in A via the stack
 PLA

 ORA #$80
 STA L045E

 AND #$7F

 LDX disableMusic
 BMI RTS4

 STA ASAV               ; Store the value of A so we can retrieve it below

 LDA currentBank        ; If ROM bank 6 is already paged into memory, jump to
 CMP #6                 ; bank1
 BEQ bank1

 PHA                    ; Otherwise store the current bank number on the stack

 LDA #6                 ; Page ROM bank 6 into memory at $8000
 JSR SetBank

 LDA ASAV               ; Restore the value of A that we stored above

 JSR ChooseMusic        ; Call ChooseMusic, now that it is paged into memory

 JMP ResetBank          ; Fetch the previous ROM bank number from the stack and
                        ; page that bank back into memory at $8000, returning
                        ; from the subroutine using a tail call

.bank1

 LDA ASAV               ; Restore the value of A that we stored above

 JMP ChooseMusic        ; Call ChooseMusic, which is already paged into memory,
                        ; and return from the subroutine using a tail call

; ******************************************************************************
;
;       Name: MakeNoise_b6
;       Type: Subroutine
;   Category: Sound
;    Summary: Call the MakeNoise routine in ROM bank 6
;
; ******************************************************************************

.MakeNoise_b6

 STA ASAV               ; Store the value of A so we can retrieve it below

 LDA currentBank        ; If ROM bank 6 is already paged into memory, jump to
 CMP #6                 ; bank2
 BEQ bank2

 PHA                    ; Otherwise store the current bank number on the stack

 LDA #6                 ; Page ROM bank 6 into memory at $8000
 JSR SetBank

 LDA ASAV               ; Restore the value of A that we stored above

 JSR MakeNoise          ; Call MakeNoise, now that it is paged into memory

 JMP ResetBank          ; Fetch the previous ROM bank number from the stack and
                        ; page that bank back into memory at $8000, returning
                        ; from the subroutine using a tail call

.bank2

 LDA ASAV               ; Restore the value of A that we stored above

 JMP MakeNoise          ; Call MakeNoise, which is already paged into memory,
                        ; and return from the subroutine using a tail call

; ******************************************************************************
;
;       Name: ResetMusicAfterNMI
;       Type: Subroutine
;   Category: Sound
;    Summary: ???
;
; ******************************************************************************

.ResetMusicAfterNMI

 JSR WaitForNMI         ; Wait until the next NMI interrupt has passed (i.e. the
                        ; next VBlank)

; ******************************************************************************
;
;       Name: ResetMusic
;       Type: Subroutine
;   Category: Sound
;    Summary: ???
;
; ******************************************************************************

.ResetMusic

 LDA #0
 STA L045E

; ******************************************************************************
;
;       Name: StopMusic_b6
;       Type: Subroutine
;   Category: Sound
;    Summary: Call the StopMusic routine in ROM bank 6
;
; ******************************************************************************

.StopMusic_b6

 LDA currentBank        ; Fetch the number of the ROM bank that is currently
 PHA                    ; paged into memory at $8000 and store it on the stack

 LDA #6                 ; Page ROM bank 6 into memory at $8000
 JSR SetBank

 JSR StopMusicS         ; Call StopMusic via StopMusicS, now that it is paged
                        ; into memory

 JMP ResetBank          ; Fetch the previous ROM bank number from the stack and
                        ; page that bank back into memory at $8000, returning
                        ; from the subroutine using a tail call

; ******************************************************************************
;
;       Name: SetDemoAutoPlay_b5
;       Type: Subroutine
;   Category: Demo
;    Summary: Call the SetDemoAutoPlay routine in ROM bank 5
;
; ******************************************************************************

.SetDemoAutoPlay_b5

 LDA currentBank        ; Fetch the number of the ROM bank that is currently
 PHA                    ; paged into memory at $8000 and store it on the stack

 LDA #5                 ; Page ROM bank 5 into memory at $8000
 JSR SetBank

 JSR SetDemoAutoPlay    ; Call SetDemoAutoPlay, now that it is paged into memory

 JMP ResetBank          ; Fetch the previous ROM bank number from the stack and
                        ; page that bank back into memory at $8000, returning
                        ; from the subroutine using a tail call

; ******************************************************************************
;
;       Name: DrawSmallLogo_b4
;       Type: Subroutine
;   Category: Start and end
;    Summary: Call the DrawSmallLogo routine in ROM bank 4
;
; ******************************************************************************

.DrawSmallLogo_b4

 LDA currentBank        ; Fetch the number of the ROM bank that is currently
 PHA                    ; paged into memory at $8000 and store it on the stack

 LDA #4                 ; Page ROM bank 4 into memory at $8000
 JSR SetBank

 JSR DrawSmallLogo      ; Call DrawSmallLogo, now that it is paged into memory

 JMP ResetBank          ; Fetch the previous ROM bank number from the stack and
                        ; page that bank back into memory at $8000, returning
                        ; from the subroutine using a tail call

; ******************************************************************************
;
;       Name: DrawBigLogo_b4
;       Type: Subroutine
;   Category: Start and end
;    Summary: Call the DrawBigLogo routine in ROM bank 4
;
; ******************************************************************************

.DrawBigLogo_b4

 LDA currentBank        ; Fetch the number of the ROM bank that is currently
 PHA                    ; paged into memory at $8000 and store it on the stack

 LDA #4                 ; Page ROM bank 4 into memory at $8000
 JSR SetBank

 JSR DrawBigLogo        ; Call DrawBigLogo, now that it is paged into memory

 JMP ResetBank          ; Fetch the previous ROM bank number from the stack and
                        ; page that bank back into memory at $8000, returning
                        ; from the subroutine using a tail call

; ******************************************************************************
;
;       Name: FetchPalettes1_b3
;       Type: Subroutine
;   Category: Drawing the screen
;    Summary: Call the FetchPalettes1 routine in ROM bank 3
;
; ******************************************************************************

.FetchPalettes1_b3

 LDA currentBank        ; Fetch the number of the ROM bank that is currently
 PHA                    ; paged into memory at $8000 and store it on the stack

 LDA #3                 ; Page ROM bank 3 into memory at $8000
 JSR SetBank

 JSR FetchPalettes1     ; Call FetchPalettes1, now that it is paged into memory

 JMP ResetBank          ; Fetch the previous ROM bank number from the stack and
                        ; page that bank back into memory at $8000, returning
                        ; from the subroutine using a tail call

; ******************************************************************************
;
;       Name: UpdateSaveSlots_b6
;       Type: Subroutine
;   Category: Save and load
;    Summary: Call the UpdateSaveSlots routine in ROM bank 6
;
; ******************************************************************************

.UpdateSaveSlots_b6

 LDA currentBank        ; Fetch the number of the ROM bank that is currently
 PHA                    ; paged into memory at $8000 and store it on the stack

 LDA #6                 ; Page ROM bank 6 into memory at $8000
 JSR SetBank

 JSR UpdateSaveSlots    ; Call UpdateSaveSlots, now that it is paged into memory

 JMP ResetBank          ; Fetch the previous ROM bank number from the stack and
                        ; page that bank back into memory at $8000, returning
                        ; from the subroutine using a tail call

; ******************************************************************************
;
;       Name: LL9_b1
;       Type: Subroutine
;   Category: Drawing ships
;    Summary: Call the LL9 routine in ROM bank 1
;
; ******************************************************************************

.LL9_b1

 LDA currentBank        ; If ROM bank 1 is already paged into memory, jump to
 CMP #1                 ; bank3
 BEQ bank3

 PHA                    ; Otherwise store the current bank number on the stack

 LDA #1                 ; Page ROM bank 1 into memory at $8000
 JSR SetBank

 JSR LL9                ; Call LL9, now that it is paged into memory

 JMP ResetBank          ; Fetch the previous ROM bank number from the stack and
                        ; page that bank back into memory at $8000, returning
                        ; from the subroutine using a tail call

.bank3

 JMP LL9                ; Call LL9, which is already paged into memory, and
                        ; return from the subroutine using a tail call

; ******************************************************************************
;
;       Name: SIGHT_b3
;       Type: Subroutine
;   Category: Flight
;    Summary: Call the SIGHT routine in ROM bank 3
;
; ******************************************************************************

.SIGHT_b3

 LDA currentBank        ; Fetch the number of the ROM bank that is currently
 PHA                    ; paged into memory at $8000 and store it on the stack

 LDA #3                 ; Page ROM bank 3 into memory at $8000
 JSR SetBank

 JSR SIGHT              ; Call SIGHT, now that it is paged into memory

 JMP ResetBank          ; Fetch the previous ROM bank number from the stack and
                        ; page that bank back into memory at $8000, returning
                        ; from the subroutine using a tail call

; ******************************************************************************
;
;       Name: TIDY_b1
;       Type: Subroutine
;   Category: Maths (Geometry)
;    Summary: Call the TIDY routine in ROM bank 1
;
; ******************************************************************************

.TIDY_b1

 LDA currentBank        ; If ROM bank 1 is already paged into memory, jump to
 CMP #1                 ; bank4
 BEQ bank4

 PHA                    ; Otherwise store the current bank number on the stack

 LDA #1                 ; Page ROM bank 1 into memory at $8000
 JSR SetBank

 JSR TIDY               ; Call TIDY, now that it is paged into memory

 JMP ResetBank          ; Fetch the previous ROM bank number from the stack and
                        ; page that bank back into memory at $8000, returning
                        ; from the subroutine using a tail call

.bank4

 JMP TIDY               ; Call TIDY, which is already paged into memory, and
                        ; return from the subroutine using a tail call

; ******************************************************************************
;
;       Name: ChooseLanguage_b6
;       Type: Subroutine
;   Category: Start and end
;    Summary: Call the ChooseLanguage routine in ROM bank 6
;
; ******************************************************************************

.ChooseLanguage_b6

 LDA currentBank        ; Fetch the number of the ROM bank that is currently
 PHA                    ; paged into memory at $8000 and store it on the stack

 LDA #6                 ; Page ROM bank 6 into memory at $8000
 JSR SetBank

 JSR ChooseLanguage     ; Call ChooseLanguage, now that it is paged into memory

 JMP ResetBank          ; Fetch the previous ROM bank number from the stack and
                        ; page that bank back into memory at $8000, returning
                        ; from the subroutine using a tail call

; ******************************************************************************
;
;       Name: PlayDemo_b0
;       Type: Subroutine
;   Category: Demo
;    Summary: Call the PlayDemo routine in ROM bank 0
;
; ******************************************************************************

.PlayDemo_b0

 LDA #0                 ; Page ROM bank 0 into memory at $8000
 JSR SetBank

 JMP PlayDemo           ; Call PlayDemo, which is already paged into memory, and
                        ; return from the subroutine using a tail call

; ******************************************************************************
;
;       Name: STARS_b1
;       Type: Subroutine
;   Category: Stardust
;    Summary: Call the STARS routine in ROM bank 1
;
; ******************************************************************************

.STARS_b1

 LDA currentBank        ; If ROM bank 1 is already paged into memory, jump to
 CMP #1                 ; bank5
 BEQ bank5

 PHA                    ; Otherwise store the current bank number on the stack

 LDA #1                 ; Page ROM bank 1 into memory at $8000
 JSR SetBank

 JSR STARS              ; Call STARS, now that it is paged into memory

 JMP ResetBank          ; Fetch the previous ROM bank number from the stack and
                        ; page that bank back into memory at $8000, returning
                        ; from the subroutine using a tail call

.bank5

 JMP STARS              ; Call STARS, which is already paged into memory, and
                        ; return from the subroutine using a tail call

; ******************************************************************************
;
;       Name: CIRCLE2_b1
;       Type: Subroutine
;   Category: Drawing circles
;    Summary: Call the CIRCLE2 routine in ROM bank 1
;
; ******************************************************************************

.CIRCLE2_b1

 LDA currentBank        ; If ROM bank 1 is already paged into memory, jump to
 CMP #1                 ; bank6
 BEQ bank6

 PHA                    ; Otherwise store the current bank number on the stack

 LDA #1                 ; Page ROM bank 1 into memory at $8000
 JSR SetBank

 JSR CIRCLE2            ; Call CIRCLE2, now that it is paged into memory

 JMP ResetBank          ; Fetch the previous ROM bank number from the stack and
                        ; page that bank back into memory at $8000, returning
                        ; from the subroutine using a tail call

.bank6

 JMP CIRCLE2            ; Call CIRCLE2, which is already paged into memory, and
                        ; return from the subroutine using a tail call

; ******************************************************************************
;
;       Name: SUN_b1
;       Type: Subroutine
;   Category: Drawing suns
;    Summary: Call the SUN routine in ROM bank 1
;
; ******************************************************************************

.SUN_b1

 LDA currentBank        ; If ROM bank 1 is already paged into memory, jump to
 CMP #1                 ; bank7
 BEQ bank7

 PHA                    ; Otherwise store the current bank number on the stack

 LDA #1                 ; Page ROM bank 1 into memory at $8000
 JSR SetBank

 JSR SUN                ; Call SUN, now that it is paged into memory

 JMP ResetBank          ; Fetch the previous ROM bank number from the stack and
                        ; page that bank back into memory at $8000, returning
                        ; from the subroutine using a tail call

.bank7

 JMP SUN                ; Call SUN, which is already paged into memory, and
                        ; return from the subroutine using a tail call

; ******************************************************************************
;
;       Name: DrawBackground_b3
;       Type: Subroutine
;   Category: Drawing the screen
;    Summary: Call the DrawBackground routine in ROM bank 3
;
; ******************************************************************************

.DrawBackground_b3

 LDA currentBank        ; Fetch the number of the ROM bank that is currently
 PHA                    ; paged into memory at $8000 and store it on the stack

 LDA #3                 ; Page ROM bank 3 into memory at $8000
 JSR SetBank

 JSR DrawBackground     ; Call DrawBackground, now that it is paged into memory

 JMP ResetBank          ; Fetch the previous ROM bank number from the stack and
                        ; page that bank back into memory at $8000, returning
                        ; from the subroutine using a tail call

; ******************************************************************************
;
;       Name: DrawSystemImage_b3
;       Type: Subroutine
;   Category: Universe
;    Summary: Call the DrawSystemImage routine in ROM bank 3
;
; ******************************************************************************

.DrawSystemImage_b3

 STA ASAV               ; Store the value of A so we can retrieve it below

 LDA currentBank        ; If ROM bank 3 is already paged into memory, jump to
 CMP #3                 ; bank8
 BEQ bank8

 PHA                    ; Otherwise store the current bank number on the stack

 LDA #3                 ; Page ROM bank 3 into memory at $8000
 JSR SetBank

 LDA ASAV               ; Restore the value of A that we stored above

 JSR DrawSystemImage    ; Call DrawSystemImage, now that it is paged into memory

 JMP ResetBank          ; Fetch the previous ROM bank number from the stack and
                        ; page that bank back into memory at $8000, returning
                        ; from the subroutine using a tail call

.bank8

 LDA ASAV               ; Restore the value of A that we stored above

 JMP DrawSystemImage    ; Call DrawSystemImage, which is already paged into
                        ; memory, and return from the subroutine using a tail
                        ; call

; ******************************************************************************
;
;       Name: DrawImageNames_b4
;       Type: Subroutine
;   Category: Drawing the screen
;    Summary: Call the DrawImageNames routine in ROM bank 4
;
; ******************************************************************************

.DrawImageNames_b4

 LDA currentBank        ; Fetch the number of the ROM bank that is currently
 PHA                    ; paged into memory at $8000 and store it on the stack

 LDA #4                 ; Page ROM bank 4 into memory at $8000
 JSR SetBank

 JSR DrawImageNames     ; Call DrawImageNames, now that it is paged into memory

 JMP ResetBank          ; Fetch the previous ROM bank number from the stack and
                        ; page that bank back into memory at $8000, returning
                        ; from the subroutine using a tail call

; ******************************************************************************
;
;       Name: DrawCmdrImage_b6
;       Type: Subroutine
;   Category: Status
;    Summary: Call the DrawCmdrImage routine in ROM bank 6
;
; ******************************************************************************

.DrawCmdrImage_b6

 LDA currentBank        ; Fetch the number of the ROM bank that is currently
 PHA                    ; paged into memory at $8000 and store it on the stack

 LDA #6                 ; Page ROM bank 6 into memory at $8000
 JSR SetBank

 JSR DrawCmdrImage      ; Call DrawCmdrImage, now that it is paged into memory

 JMP ResetBank          ; Fetch the previous ROM bank number from the stack and
                        ; page that bank back into memory at $8000, returning
                        ; from the subroutine using a tail call

; ******************************************************************************
;
;       Name: DrawSpriteImage_b6
;       Type: Subroutine
;   Category: Drawing sprites
;    Summary: Call the DrawSpriteImage routine in ROM bank 6
;
; ******************************************************************************

.DrawSpriteImage_b6

 LDA currentBank        ; Fetch the number of the ROM bank that is currently
 PHA                    ; paged into memory at $8000 and store it on the stack

 LDA #6                 ; Page ROM bank 6 into memory at $8000
 JSR SetBank

 JSR DrawSpriteImage    ; Call DrawSpriteImage, now that it is paged into memory

 JMP ResetBank          ; Fetch the previous ROM bank number from the stack and
                        ; page that bank back into memory at $8000, returning
                        ; from the subroutine using a tail call

; ******************************************************************************
;
;       Name: GetHeadshotType_b4
;       Type: Subroutine
;   Category: Status
;    Summary: Call the GetHeadshotType routine in ROM bank 4
;
; ******************************************************************************

.GetHeadshotType_b4

 LDA currentBank        ; Fetch the number of the ROM bank that is currently
 PHA                    ; paged into memory at $8000 and store it on the stack

 LDA #4                 ; Page ROM bank 4 into memory at $8000
 JSR SetBank

 JSR GetHeadshotType    ; Call GetHeadshotType, now that it is paged into memory

 JMP ResetBank          ; Fetch the previous ROM bank number from the stack and
                        ; page that bank back into memory at $8000, returning
                        ; from the subroutine using a tail call

; ******************************************************************************
;
;       Name: DrawEquipment_b6
;       Type: Subroutine
;   Category: Equipment
;    Summary: Call the DrawEquipment routine in ROM bank 6
;
; ******************************************************************************

.DrawEquipment_b6

 LDA currentBank        ; Fetch the number of the ROM bank that is currently
 PHA                    ; paged into memory at $8000 and store it on the stack

 LDA #6                 ; Page ROM bank 6 into memory at $8000
 JSR SetBank

 JSR DrawEquipment      ; Call DrawEquipment, now that it is paged into memory

 JMP ResetBank          ; Fetch the previous ROM bank number from the stack and
                        ; page that bank back into memory at $8000, returning
                        ; from the subroutine using a tail call

; ******************************************************************************
;
;       Name: DEATH2_b0
;       Type: Subroutine
;   Category: Start and end
;    Summary: Switch to ROM bank 0 and call the DEATH2 routine
;
; ******************************************************************************

.DEATH2_b0

 LDA #0                 ; Page ROM bank 0 into memory at $8000
 JSR SetBank

 JMP DEATH2             ; Call DEATH2, which is now paged into memory, and
                        ; return from the subroutine using a tail call

; ******************************************************************************
;
;       Name: StartGame_b0
;       Type: Subroutine
;   Category: Start and end
;    Summary: Switch to ROM bank 0 and call the StartGame routine
;
; ******************************************************************************

.StartGame_b0

 LDA #0                 ; Page ROM bank 0 into memory at $8000
 JSR SetBank

 JMP StartGame          ; Call StartGame, which is now paged into memory, and
                        ; return from the subroutine using a tail call

; ******************************************************************************
;
;       Name: SetViewAttrs_b3
;       Type: Subroutine
;   Category: Drawing the screen
;    Summary: Call the SetViewAttrs routine in ROM bank 3
;
; ******************************************************************************

.SetViewAttrs_b3

 LDA currentBank        ; If ROM bank 3 is already paged into memory, jump to
 CMP #3                 ; bank9
 BEQ bank9

 PHA                    ; Otherwise store the current bank number on the stack

 LDA #3                 ; Page ROM bank 3 into memory at $8000
 JSR SetBank

 JSR SetViewAttrs       ; Call SetViewAttrs, now that it is paged into memory

 JMP ResetBank          ; Fetch the previous ROM bank number from the stack and
                        ; page that bank back into memory at $8000, returning
                        ; from the subroutine using a tail call

.bank9

 JMP SetViewAttrs       ; Call SetViewAttrs, which is already paged into memory,
                        ; and return from the subroutine using a tail call

; ******************************************************************************
;
;       Name: FetchPalettes2_b3
;       Type: Subroutine
;   Category: Drawing the screen
;    Summary: Call the FetchPalettes2 routine in ROM bank 3
;
; ******************************************************************************

.FetchPalettes2_b3

 LDA currentBank        ; Fetch the number of the ROM bank that is currently
 PHA                    ; paged into memory at $8000 and store it on the stack

 LDA #3                 ; Page ROM bank 3 into memory at $8000
 JSR SetBank

 JSR FetchPalettes2     ; Call FetchPalettes2, now that it is paged into memory

 JMP ResetBank          ; Fetch the previous ROM bank number from the stack and
                        ; page that bank back into memory at $8000, returning
                        ; from the subroutine using a tail call

; ******************************************************************************
;
;       Name: DrawPopupBox_b3
;       Type: Subroutine
;   Category: Drawing the screen
;    Summary: Call the DrawPopupBox routine in ROM bank 3
;
; ******************************************************************************

.DrawPopupBox_b3

 LDA currentBank        ; Fetch the number of the ROM bank that is currently
 PHA                    ; paged into memory at $8000 and store it on the stack

 LDA #3                 ; Page ROM bank 3 into memory at $8000
 JSR SetBank

 JSR DrawPopupBox       ; Call DrawPopupBox, now that it is paged into memory

 JMP ResetBank          ; Fetch the previous ROM bank number from the stack and
                        ; page that bank back into memory at $8000, returning
                        ; from the subroutine using a tail call

; ******************************************************************************
;
;       Name: DrawImageFrame_b3
;       Type: Subroutine
;   Category: Drawing the screen
;    Summary: Call the DrawImageFrame routine in ROM bank 3
;
; ******************************************************************************

.DrawImageFrame_b3

 LDA currentBank        ; Fetch the number of the ROM bank that is currently
 PHA                    ; paged into memory at $8000 and store it on the stack

 LDA #3                 ; Page ROM bank 3 into memory at $8000
 JSR SetBank

 JSR DrawImageFrame     ; Call DrawImageFrame, now that it is paged into memory

 JMP ResetBank          ; Fetch the previous ROM bank number from the stack and
                        ; page that bank back into memory at $8000, returning
                        ; from the subroutine using a tail call

; ******************************************************************************
;
;       Name: DrawLaunchBoxes_b6
;       Type: Subroutine
;   Category: Flight
;    Summary: Call the DrawLaunchBoxes routine in ROM bank 6
;
; ******************************************************************************

.DrawLaunchBoxes_b6

 LDA currentBank        ; Fetch the number of the ROM bank that is currently
 PHA                    ; paged into memory at $8000 and store it on the stack

 LDA #6                 ; Page ROM bank 6 into memory at $8000
 JSR SetBank

 JSR DrawLaunchBoxes    ; Call DrawLaunchBoxes, now that it is paged into memory

 JMP ResetBank          ; Fetch the previous ROM bank number from the stack and
                        ; page that bank back into memory at $8000, returning
                        ; from the subroutine using a tail call

; ******************************************************************************
;
;       Name: SetViewPatterns_b3
;       Type: Subroutine
;   Category: Drawing the screen
;    Summary: Call the SetViewPatterns routine in ROM bank 3
;
; ******************************************************************************

.SetViewPatterns_b3

 LDA currentBank        ; If ROM bank 3 is already paged into memory, jump to
 CMP #3                 ; bank10
 BEQ bank10

 PHA                    ; Otherwise store the current bank number on the stack

 LDA #3                 ; Page ROM bank 3 into memory at $8000
 JSR SetBank

 JSR SetViewPatterns    ; Call SetViewPatterns, now that it is paged into memory

 JMP ResetBank          ; Fetch the previous ROM bank number from the stack and
                        ; page that bank back into memory at $8000, returning
                        ; from the subroutine using a tail call

.bank10

 JMP SetViewPatterns    ; Call SetViewPatterns, which is already paged into
                        ; memory, and return from the subroutine using a tail
                        ; call

; ******************************************************************************
;
;       Name: TT24_b6
;       Type: Subroutine
;   Category: Universe
;    Summary: Call the TT24 routine in ROM bank 6
;
; ******************************************************************************

.TT24_b6

 LDA currentBank        ; Fetch the number of the ROM bank that is currently
 PHA                    ; paged into memory at $8000 and store it on the stack

 LDA #6                 ; Page ROM bank 6 into memory at $8000
 JSR SetBank

 JSR TT24               ; Call TT24, now that it is paged into memory

 JMP ResetBank          ; Fetch the previous ROM bank number from the stack and
                        ; page that bank back into memory at $8000, returning
                        ; from the subroutine using a tail call

; ******************************************************************************
;
;       Name: ClearDashEdge_b6
;       Type: Subroutine
;   Category: Drawing the screen
;    Summary: Call the ClearDashEdge routine in ROM bank 6
;
; ******************************************************************************

.ClearDashEdge_b6

 LDA currentBank        ; Fetch the number of the ROM bank that is currently
 PHA                    ; paged into memory at $8000 and store it on the stack

 LDA #6                 ; Page ROM bank 6 into memory at $8000
 JSR SetBank

 JSR ClearDashEdge      ; Call ClearDashEdge, now that it is paged into memory

 JMP ResetBank          ; Fetch the previous ROM bank number from the stack and
                        ; page that bank back into memory at $8000, returning
                        ; from the subroutine using a tail call

; ******************************************************************************
;
;       Name: SetInvertedFont_b3
;       Type: Subroutine
;   Category: Text
;    Summary: Call the SetInvertedFont routine in ROM bank 3
;
; ******************************************************************************

.SetInvertedFont_b3

 STA ASAV               ; Store the value of A so we can retrieve it below

 LDA currentBank        ; If ROM bank 3 is already paged into memory, jump to
 CMP #3                 ; bank11
 BEQ bank11

 PHA                    ; Otherwise store the current bank number on the stack

 LDA #3                 ; Page ROM bank 3 into memory at $8000
 JSR SetBank

 LDA ASAV               ; Restore the value of A that we stored above

 JSR SetInvertedFont    ; Call SetInvertedFont, now that it is paged into memory

 JMP ResetBank          ; Fetch the previous ROM bank number from the stack and
                        ; page that bank back into memory at $8000, returning
                        ; from the subroutine using a tail call

.bank11

 LDA ASAV               ; Restore the value of A that we stored above

 JMP SetInvertedFont    ; Call SetInvertedFont, which is already paged into
                        ; memory, and return from the subroutine using a tail call

; ******************************************************************************
;
;       Name: SetFont_b3
;       Type: Subroutine
;   Category: Text
;    Summary: Call the SetFont routine in ROM bank 3
;
; ******************************************************************************

.SetFont_b3

 LDA currentBank        ; Fetch the number of the ROM bank that is currently
 PHA                    ; paged into memory at $8000 and store it on the stack

 LDA #3                 ; Page ROM bank 3 into memory at $8000
 JSR SetBank

 JSR SetFont            ; Call SetFont, now that it is paged into memory

 JMP ResetBank          ; Fetch the previous ROM bank number from the stack and
                        ; page that bank back into memory at $8000, returning
                        ; from the subroutine using a tail call

; ******************************************************************************
;
;       Name: PAS1_b0
;       Type: Subroutine
;   Category: Keyboard
;    Summary: Call the PAS1 routine in ROM bank 0
;
; ******************************************************************************

.PAS1_b0

 LDA currentBank        ; Fetch the number of the ROM bank that is currently
 PHA                    ; paged into memory at $8000 and store it on the stack

 LDA #0                 ; Page ROM bank 0 into memory at $8000
 JSR SetBank

 JSR PAS1               ; Call PAS1, now that it is paged into memory

 JMP ResetBank          ; Fetch the previous ROM bank number from the stack and
                        ; page that bank back into memory at $8000, returning
                        ; from the subroutine using a tail call

; ******************************************************************************
;
;       Name: GetSystemImage_b5
;       Type: Subroutine
;   Category: Universe
;    Summary: Call the GetSystemImage routine in ROM bank 5
;
; ******************************************************************************

.GetSystemImage_b5

 LDA currentBank        ; Fetch the number of the ROM bank that is currently
 PHA                    ; paged into memory at $8000 and store it on the stack

 LDA #5                 ; Page ROM bank 5 into memory at $8000
 JSR SetBank

 JSR GetSystemImage     ; Call GetSystemImage, now that it is paged into memory

 JMP ResetBank          ; Fetch the previous ROM bank number from the stack and
                        ; page that bank back into memory at $8000, returning
                        ; from the subroutine using a tail call

; ******************************************************************************
;
;       Name: GetSystemBack_b5
;       Type: Subroutine
;   Category: Universe
;    Summary: Call the GetSystemBack routine in ROM bank 5
;
; ******************************************************************************

.GetSystemBack_b5

 LDA currentBank        ; Fetch the number of the ROM bank that is currently
 PHA                    ; paged into memory at $8000 and store it on the stack

 LDA #5                 ; Page ROM bank 5 into memory at $8000
 JSR SetBank

 JSR GetSystemBack      ; Call GetSystemBack, now that it is paged into memory

 JMP ResetBank          ; Fetch the previous ROM bank number from the stack and
                        ; page that bank back into memory at $8000, returning
                        ; from the subroutine using a tail call

; ******************************************************************************
;
;       Name: GetCmdrImage_b4
;       Type: Subroutine
;   Category: Status
;    Summary: Call the GetCmdrImage routine in ROM bank 4
;
; ******************************************************************************

.GetCmdrImage_b4

 LDA currentBank        ; Fetch the number of the ROM bank that is currently
 PHA                    ; paged into memory at $8000 and store it on the stack

 LDA #4                 ; Page ROM bank 4 into memory at $8000
 JSR SetBank

 JSR GetCmdrImage       ; Call GetCmdrImage, now that it is paged into memory

 JMP ResetBank          ; Fetch the previous ROM bank number from the stack and
                        ; page that bank back into memory at $8000, returning
                        ; from the subroutine using a tail call

; ******************************************************************************
;
;       Name: GetHeadshot_b4
;       Type: Subroutine
;   Category: Status
;    Summary: Call the GetHeadshot routine in ROM bank 4
;
; ******************************************************************************

.GetHeadshot_b4

 LDA currentBank        ; Fetch the number of the ROM bank that is currently
 PHA                    ; paged into memory at $8000 and store it on the stack

 LDA #4                 ; Page ROM bank 4 into memory at $8000
 JSR SetBank

 JSR GetHeadshot        ; Call GetHeadshot, now that it is paged into memory

 JMP ResetBank          ; Fetch the previous ROM bank number from the stack and
                        ; page that bank back into memory at $8000, returning
                        ; from the subroutine using a tail call

; ******************************************************************************
;
;       Name: DIALS_b6
;       Type: Subroutine
;   Category: Dashboard
;    Summary: Call the DIALS routine in ROM bank 6
;
; ******************************************************************************

.DIALS_b6

 LDA currentBank        ; Fetch the number of the ROM bank that is currently
 PHA                    ; paged into memory at $8000 and store it on the stack

 LDA #6                 ; Page ROM bank 6 into memory at $8000
 JSR SetBank

 JSR DIALS              ; Call DIALS, now that it is paged into memory

 JMP ResetBank          ; Fetch the previous ROM bank number from the stack and
                        ; page that bank back into memory at $8000, returning
                        ; from the subroutine using a tail call

; ******************************************************************************
;
;       Name: GetName_b6
;       Type: Subroutine
;   Category: Keyboard
;    Summary: Call the GetName routine in ROM bank 6
;
; ******************************************************************************

.GetName_b6

 LDA currentBank        ; Fetch the number of the ROM bank that is currently
 PHA                    ; paged into memory at $8000 and store it on the stack

 LDA #6                 ; Page ROM bank 6 into memory at $8000
 JSR SetBank

 JSR GetName            ; Call GetName, now that it is paged into memory

 JMP ResetBank          ; Fetch the previous ROM bank number from the stack and
                        ; page that bank back into memory at $8000, returning
                        ; from the subroutine using a tail call

; ******************************************************************************
;
;       Name: SetViewInPPUNMI_b0
;       Type: Subroutine
;   Category: Drawing the screen
;    Summary: Call the SetViewInPPUNMI routine in ROM bank 0
;
; ******************************************************************************

.SetViewInPPUNMI_b0

 STA ASAV               ; Store the value of A so we can retrieve it below

 LDA currentBank        ; If ROM bank 0 is already paged into memory, jump to
 CMP #0                 ; bank12
 BEQ bank12

 PHA                    ; Otherwise store the current bank number on the stack

 LDA #0                 ; Page ROM bank 0 into memory at $8000
 JSR SetBank

 LDA ASAV               ; Restore the value of A that we stored above

 JSR SetViewInPPUNMI    ; Call SetViewInPPUNMI, now that it is paged into memory

 JMP ResetBank          ; Fetch the previous ROM bank number from the stack and
                        ; page that bank back into memory at $8000, returning
                        ; from the subroutine using a tail call

.bank12

 LDA ASAV               ; Restore the value of A that we stored above

 JMP SetViewInPPUNMI    ; Call SetViewInPPUNMI, which is already paged into
                        ; memory, and return from the subroutine using a tail
                        ; call

; ******************************************************************************
;
;       Name: LL164_b6
;       Type: Subroutine
;   Category: Drawing circles
;    Summary: Call the LL164 routine in ROM bank 6
;
; ******************************************************************************

.LL164_b6

 LDA currentBank        ; Fetch the number of the ROM bank that is currently
 PHA                    ; paged into memory at $8000 and store it on the stack

 LDA #6                 ; Page ROM bank 6 into memory at $8000
 JSR SetBank

 JSR LL164              ; Call LL164, now that it is paged into memory

 JMP ResetBank          ; Fetch the previous ROM bank number from the stack and
                        ; page that bank back into memory at $8000, returning
                        ; from the subroutine using a tail call

; ******************************************************************************
;
;       Name: DrawLightning_b6
;       Type: Subroutine
;   Category: Flight
;    Summary: Call the DrawLightning routine in ROM bank 6
;
; ******************************************************************************

.DrawLightning_b6

 LDA currentBank        ; Fetch the number of the ROM bank that is currently
 PHA                    ; paged into memory at $8000 and store it on the stack

 LDA #6                 ; Page ROM bank 6 into memory at $8000
 JSR SetBank

 JSR DrawLightning      ; Call DrawLightning, now that it is paged into memory

 JMP ResetBank          ; Fetch the previous ROM bank number from the stack and
                        ; page that bank back into memory at $8000, returning
                        ; from the subroutine using a tail call

; ******************************************************************************
;
;       Name: PauseGame_b6
;       Type: Subroutine
;   Category: Keyboard
;    Summary: Call the PauseGame routine in ROM bank 6
;
; ******************************************************************************

.PauseGame_b6

 LDA currentBank        ; Fetch the number of the ROM bank that is currently
 PHA                    ; paged into memory at $8000 and store it on the stack

 LDA #6                 ; Page ROM bank 6 into memory at $8000
 JSR SetBank

 JSR PauseGame          ; Call PauseGame, now that it is paged into memory

 JMP ResetBank          ; Fetch the previous ROM bank number from the stack and
                        ; page that bank back into memory at $8000, returning
                        ; from the subroutine using a tail call

; ******************************************************************************
;
;       Name: SetKeyLogger_b6
;       Type: Subroutine
;   Category: Keyboard
;    Summary: Call the SetKeyLogger routine in ROM bank 6
;
; ******************************************************************************

.SetKeyLogger_b6

 LDA currentBank        ; Fetch the number of the ROM bank that is currently
 PHA                    ; paged into memory at $8000 and store it on the stack

 LDA #6                 ; Page ROM bank 6 into memory at $8000
 JSR SetBank

 JSR SetKeyLogger       ; Call SetKeyLogger, now that it is paged into memory

 JMP ResetBank          ; Fetch the previous ROM bank number from the stack and
                        ; page that bank back into memory at $8000, returning
                        ; from the subroutine using a tail call

; ******************************************************************************
;
;       Name: ChangeCmdrName_b6
;       Type: Subroutine
;   Category: Save and load
;    Summary: Call the ChangeCmdrName routine in ROM bank 6
;
; ******************************************************************************

.ChangeCmdrName_b6

 LDA currentBank        ; Fetch the number of the ROM bank that is currently
 PHA                    ; paged into memory at $8000 and store it on the stack

 LDA #6                 ; Page ROM bank 6 into memory at $8000
 JSR SetBank

 JSR ChangeCmdrName     ; Call ChangeCmdrName, now that it is paged into memory

 JMP ResetBank          ; Fetch the previous ROM bank number from the stack and
                        ; page that bank back into memory at $8000, returning
                        ; from the subroutine using a tail call

; ******************************************************************************
;
;       Name: ResetCommander_b6
;       Type: Subroutine
;   Category: Save and load
;    Summary: Call the ResetCommander routine in ROM bank 6
;
; ******************************************************************************

.ResetCommander_b6

 LDA currentBank        ; Fetch the number of the ROM bank that is currently
 PHA                    ; paged into memory at $8000 and store it on the stack

 LDA #6                 ; Page ROM bank 6 into memory at $8000
 JSR SetBank

 JSR ResetCommander     ; Call ResetCommander, now that it is paged into memory

 JMP ResetBank          ; Fetch the previous ROM bank number from the stack and
                        ; page that bank back into memory at $8000, returning
                        ; from the subroutine using a tail call

; ******************************************************************************
;
;       Name: JAMESON_b6
;       Type: Subroutine
;   Category: Save and load
;    Summary: Call the JAMESON routine in ROM bank 6
;
; ******************************************************************************

.JAMESON_b6

 LDA currentBank        ; Fetch the number of the ROM bank that is currently
 PHA                    ; paged into memory at $8000 and store it on the stack

 LDA #6                 ; Page ROM bank 6 into memory at $8000
 JSR SetBank

 JSR JAMESON            ; Call JAMESON, now that it is paged into memory

 JMP ResetBank          ; Fetch the previous ROM bank number from the stack and
                        ; page that bank back into memory at $8000, returning
                        ; from the subroutine using a tail call

; ******************************************************************************
;
;       Name: ShowScrollText_b6
;       Type: Subroutine
;   Category: Demo
;    Summary: Call the ShowScrollText routine in ROM bank 6
;
; ******************************************************************************

.ShowScrollText_b6

 STA ASAV               ; Store the value of A so we can retrieve it below

 LDA currentBank        ; If ROM bank 6 is already paged into memory, jump to
 CMP #6                 ; bank13
 BEQ bank13

 PHA                    ; Otherwise store the current bank number on the stack

 LDA #6                 ; Page ROM bank 6 into memory at $8000
 JSR SetBank

 LDA ASAV               ; Restore the value of A that we stored above

 JSR ShowScrollText     ; Call ShowScrollText, now that it is paged into memory

 JMP ResetBank          ; Fetch the previous ROM bank number from the stack and
                        ; page that bank back into memory at $8000, returning
                        ; from the subroutine using a tail call

.bank13

 LDA ASAV               ; Restore the value of A that we stored above

 JMP ShowScrollText     ; Call ShowScrollText, which is already paged into
                        ; memory, and return from the subroutine using a tail
                        ; call

; ******************************************************************************
;
;       Name: BEEP_b7
;       Type: Subroutine
;   Category: Sound
;    Summary: Call the BEEP routine in ROM bank 7
;
; ******************************************************************************

.BEEP_b7

 LDA currentBank        ; Fetch the number of the ROM bank that is currently
 PHA                    ; paged into memory at $8000 and store it on the stack

 LDA #0                 ; Page ROM bank 0 into memory at $8000
 JSR SetBank

 JSR BEEP               ; Call BEEP, now that it is paged into memory

 JMP ResetBank          ; Fetch the previous ROM bank number from the stack and
                        ; page that bank back into memory at $8000, returning
                        ; from the subroutine using a tail call

; ******************************************************************************
;
;       Name: DETOK_b2
;       Type: Subroutine
;   Category: Text
;    Summary: Call the DETOK routine in ROM bank 2
;
; ******************************************************************************

.DETOK_b2

 STA ASAV               ; Store the value of A so we can retrieve it below

 LDA currentBank        ; If ROM bank 2 is already paged into memory, jump to
 CMP #2                 ; bank14
 BEQ bank14

 PHA                    ; Otherwise store the current bank number on the stack

 LDA #2                 ; Page ROM bank 2 into memory at $8000
 JSR SetBank

 LDA ASAV               ; Restore the value of A that we stored above

 JSR DETOK              ; Call DETOK, now that it is paged into memory

 JMP ResetBank          ; Fetch the previous ROM bank number from the stack and
                        ; page that bank back into memory at $8000, returning
                        ; from the subroutine using a tail call

.bank14

 LDA ASAV               ; Restore the value of A that we stored above

 JMP DETOK              ; Call DETOK, which is already paged into memory, and
                        ; return from the subroutine using a tail call

; ******************************************************************************
;
;       Name: DTS_b2
;       Type: Subroutine
;   Category: Text
;    Summary: Call the DTS routine in ROM bank 2
;
; ******************************************************************************

.DTS_b2

 STA ASAV               ; Store the value of A so we can retrieve it below

 LDA currentBank        ; If ROM bank 2 is already paged into memory, jump to
 CMP #2                 ; bank15
 BEQ bank15

 PHA                    ; Otherwise store the current bank number on the stack

 LDA #2                 ; Page ROM bank 2 into memory at $8000
 JSR SetBank

 LDA ASAV               ; Restore the value of A that we stored above

 JSR DTS                ; Call DTS, now that it is paged into memory

 JMP ResetBank          ; Fetch the previous ROM bank number from the stack and
                        ; page that bank back into memory at $8000, returning
                        ; from the subroutine using a tail call

.bank15

 LDA ASAV               ; Restore the value of A that we stored above

 JMP DTS                ; Call DTS, which is already paged into memory, and
                        ; return from the subroutine using a tail call

; ******************************************************************************
;
;       Name: PDESC_b2
;       Type: Subroutine
;   Category: Text
;    Summary: Call the PDESC routine in ROM bank 2
;
; ******************************************************************************

.PDESC_b2

 LDA currentBank        ; Fetch the number of the ROM bank that is currently
 PHA                    ; paged into memory at $8000 and store it on the stack

 LDA #2                 ; Page ROM bank 2 into memory at $8000
 JSR SetBank

 JSR PDESC              ; Call PDESC, now that it is paged into memory

 JMP ResetBank          ; Fetch the previous ROM bank number from the stack and
                        ; page that bank back into memory at $8000, returning
                        ; from the subroutine using a tail call

; ******************************************************************************
;
;       Name: SetupIconBar_b3
;       Type: Subroutine
;   Category: Icon bar
;    Summary: Call the SetupIconBar routine in ROM bank 3
;
; ******************************************************************************

.SetupIconBar_b3

 STA ASAV               ; Store the value of A so we can retrieve it below

 LDA currentBank        ; If ROM bank 3 is already paged into memory, jump to
 CMP #3                 ; bank16
 BEQ bank16

 PHA                    ; Otherwise store the current bank number on the stack

 LDA #3                 ; Page ROM bank 3 into memory at $8000
 JSR SetBank

 LDA ASAV               ; Restore the value of A that we stored above

 JSR SetupIconBar       ; Call SetupIconBar, now that it is paged into memory

 JMP ResetBank          ; Fetch the previous ROM bank number from the stack and
                        ; page that bank back into memory at $8000, returning
                        ; from the subroutine using a tail call

.bank16

 LDA ASAV               ; Restore the value of A that we stored above

 JMP SetupIconBar       ; Call SetupIconBar, which is already paged into memory,
                        ; and return from the subroutine using a tail call

; ******************************************************************************
;
;       Name: ShowIconBar_b3
;       Type: Subroutine
;   Category: Icon bar
;    Summary: Call the ShowIconBar routine in ROM bank 3
;
; ******************************************************************************

.ShowIconBar_b3

 STA ASAV               ; Store the value of A so we can retrieve it below

 LDA currentBank        ; If ROM bank 3 is already paged into memory, jump to
 CMP #3                 ; bank17
 BEQ bank17

 PHA                    ; Otherwise store the current bank number on the stack

 LDA #3                 ; Page ROM bank 3 into memory at $8000
 JSR SetBank

 LDA ASAV               ; Restore the value of A that we stored above

 JSR ShowIconBar        ; Call ShowIconBar, now that it is paged into memory

 JMP ResetBank          ; Fetch the previous ROM bank number from the stack and
                        ; page that bank back into memory at $8000, returning
                        ; from the subroutine using a tail call

.bank17

 LDA ASAV               ; Restore the value of A that we stored above

 JMP ShowIconBar          ; Call ShowIconBar, which is already paged into memory,
                        ; and return from the subroutine using a tail call

; ******************************************************************************
;
;       Name: DrawDashNames_b3
;       Type: Subroutine
;   Category: Dashboard
;    Summary: Call the DrawDashNames routine in ROM bank 3
;
; ******************************************************************************

.DrawDashNames_b3

 LDA currentBank        ; Fetch the number of the ROM bank that is currently
 PHA                    ; paged into memory at $8000 and store it on the stack

 LDA #3                 ; Page ROM bank 3 into memory at $8000
 JSR SetBank

 JSR DrawDashNames      ; Call DrawDashNames, now that it is paged into memory

 JMP ResetBank          ; Fetch the previous ROM bank number from the stack and
                        ; page that bank back into memory at $8000, returning
                        ; from the subroutine using a tail call

; ******************************************************************************
;
;       Name: ResetScanner_b3
;       Type: Subroutine
;   Category: Dashboard
;    Summary: Call the ResetScanner routine in ROM bank 3
;
; ******************************************************************************

.ResetScanner_b3

 LDA currentBank        ; Fetch the number of the ROM bank that is currently
 PHA                    ; paged into memory at $8000 and store it on the stack

 LDA #3                 ; Page ROM bank 3 into memory at $8000
 JSR SetBank

 JSR ResetScanner       ; Call ResetScanner, now that it is paged into memory

 JMP ResetBank          ; Fetch the previous ROM bank number from the stack and
                        ; page that bank back into memory at $8000, returning
                        ; from the subroutine using a tail call

; ******************************************************************************
;
;       Name: ResetScreen_b3
;       Type: Subroutine
;   Category: Start and end
;    Summary: Call the ResetScreen routine in ROM bank 3
;
; ******************************************************************************

.ResetScreen_b3

 LDA currentBank        ; Fetch the number of the ROM bank that is currently
 PHA                    ; paged into memory at $8000 and store it on the stack

 LDA #3                 ; Page ROM bank 3 into memory at $8000
 JSR SetBank

 JSR ResetScreen        ; Call ResetScreen, now that it is paged into memory

 JMP ResetBank          ; Fetch the previous ROM bank number from the stack and
                        ; page that bank back into memory at $8000, returning
                        ; from the subroutine using a tail call

; ******************************************************************************
;
;       Name: SetupViewInPPU2
;       Type: Subroutine
;   Category: Drawing the screen
;    Summary: ???
;
; ******************************************************************************

.SetupViewInPPU2

 LDA L0473
 BPL SetupViewInNMI2

; ******************************************************************************
;
;       Name: SetupViewInPPU_b3
;       Type: Subroutine
;   Category: Drawing the screen
;    Summary: Call the SetupViewInPPU routine in ROM bank 3
;
; ******************************************************************************

.SetupViewInPPU_b3

 LDA currentBank        ; Fetch the number of the ROM bank that is currently
 PHA                    ; paged into memory at $8000 and store it on the stack

 LDA #3                 ; Page ROM bank 3 into memory at $8000
 JSR SetBank

 JSR SetupViewInPPU     ; Call SetupViewInPPU, now that it is paged into memory

 JMP ResetBank          ; Fetch the previous ROM bank number from the stack and
                        ; page that bank back into memory at $8000, returning
                        ; from the subroutine using a tail call

; ******************************************************************************
;
;       Name: SetupViewInNMI2
;       Type: Subroutine
;   Category: Drawing the screen
;    Summary: ???
;
; ******************************************************************************

.SetupViewInNMI2

 LDA #116
 STA lastTileNumber
 STA lastTileNumber+1

; ******************************************************************************
;
;       Name: SetupViewInNMI_b3
;       Type: Subroutine
;   Category: Drawing the screen
;    Summary: Call the SetupViewInNMI routine in ROM bank 3
;
; ******************************************************************************

.SetupViewInNMI_b3

 LDA #$C0               ; Set A = $C0 ???

 STA ASAV               ; Store the value of A so we can retrieve it below

 LDA currentBank        ; If ROM bank 3 is already paged into memory, jump to
 CMP #3                 ; bank18
 BEQ bank18

 PHA                    ; Otherwise store the current bank number on the stack

 LDA #3                 ; Page ROM bank 3 into memory at $8000
 JSR SetBank

 LDA ASAV               ; Restore the value of A that we stored above

 JSR SetupViewInNMI     ; Call SetupViewInNMI, now that it is paged into memory

 JMP ResetBank          ; Fetch the previous ROM bank number from the stack and
                        ; page that bank back into memory at $8000, returning
                        ; from the subroutine using a tail call

.bank18

 LDA ASAV               ; Restore the value of A that we stored above

 JMP SetupViewInNMI     ; Call SetupViewInNMI, which is already paged into
                        ; memory, and return from the subroutine using a tail
                        ; call

; ******************************************************************************
;
;       Name: SendBitplaneToPPU_b3
;       Type: Subroutine
;   Category: Drawing the screen
;    Summary: Call the SendBitplaneToPPU routine in ROM bank 3
;
; ******************************************************************************

.SendBitplaneToPPU_b3

 LDA currentBank        ; If ROM bank 3 is already paged into memory, jump to
 CMP #3                 ; bank19
 BEQ bank19

 PHA                    ; Otherwise store the current bank number on the stack

 LDA #3                 ; Page ROM bank 3 into memory at $8000
 JSR SetBank

 JSR SendBitplaneToPPU  ; Call SendBitplaneToPPU, now that it is paged into
                        ; memory

 JMP ResetBank          ; Fetch the previous ROM bank number from the stack and
                        ; page that bank back into memory at $8000, returning
                        ; from the subroutine using a tail call

.bank19

 JMP SendBitplaneToPPU  ; Call SendBitplaneToPPU, which is already paged into
                        ; memory, and return from the subroutine using a tail
                        ; call

; ******************************************************************************
;
;       Name: UpdateIconBar_b3
;       Type: Subroutine
;   Category: Icon bar
;    Summary: Call the UpdateIconBar routine in ROM bank 3
;
; ******************************************************************************

.UpdateIconBar_b3

 LDA currentBank        ; If ROM bank 3 is already paged into memory, jump to
 CMP #3                 ; bank20
 BEQ bank20

 PHA                    ; Otherwise store the current bank number on the stack

 LDA #3                 ; Page ROM bank 3 into memory at $8000
 JSR SetBank

 JSR UpdateIconBar          ; Call UpdateIconBar, now that it is paged into memory

 JMP ResetBank          ; Fetch the previous ROM bank number from the stack and
                        ; page that bank back into memory at $8000, returning
                        ; from the subroutine using a tail call

.bank20

 JMP UpdateIconBar          ; Call UpdateIconBar, which is already paged into memory,
                        ; and return from the subroutine using a tail call

; ******************************************************************************
;
;       Name: DrawScreenInNMI_b0
;       Type: Subroutine
;   Category: Drawing the screen
;    Summary: Call the DrawScreenInNMI routine in ROM bank 0
;
; ******************************************************************************

.DrawScreenInNMI_b0

 LDA currentBank        ; Fetch the number of the ROM bank that is currently
 PHA                    ; paged into memory at $8000 and store it on the stack

 LDA #0                 ; Page ROM bank 0 into memory at $8000
 JSR SetBank

 JSR DrawScreenInNMI    ; Call DrawScreenInNMI, now that it is paged into memory

 JMP ResetBank          ; Fetch the previous ROM bank number from the stack and
                        ; page that bank back into memory at $8000, returning
                        ; from the subroutine using a tail call

; ******************************************************************************
;
;       Name: SVE_b6
;       Type: Subroutine
;   Category: Save and load
;    Summary: Call the SVE routine in ROM bank 6
;
; ******************************************************************************

.SVE_b6

 LDA currentBank        ; Fetch the number of the ROM bank that is currently
 PHA                    ; paged into memory at $8000 and store it on the stack

 LDA #6                 ; Page ROM bank 6 into memory at $8000
 JSR SetBank

 JSR SVE                ; Call SVE, now that it is paged into memory

 JMP ResetBank          ; Fetch the previous ROM bank number from the stack and
                        ; page that bank back into memory at $8000, returning
                        ; from the subroutine using a tail call

; ******************************************************************************
;
;       Name: MVS5_b0
;       Type: Subroutine
;   Category: Moving
;    Summary: Call the MVS5 routine in ROM bank 0
;
; ******************************************************************************

.MVS5_b0

 STA ASAV               ; Store the value of A so we can retrieve it below

 LDA currentBank        ; If ROM bank 0 is already paged into memory, jump to
 CMP #0                 ; bank21
 BEQ bank21

 PHA                    ; Otherwise store the current bank number on the stack

 LDA #0                 ; Page ROM bank 0 into memory at $8000
 JSR SetBank

 LDA ASAV               ; Restore the value of A that we stored above

 JSR MVS5               ; Call MVS5, now that it is paged into memory

 JMP ResetBank          ; Fetch the previous ROM bank number from the stack and
                        ; page that bank back into memory at $8000, returning
                        ; from the subroutine using a tail call

.bank21

 LDA ASAV               ; Restore the value of A that we stored above

 JMP MVS5               ; Call MVS5, which is already paged into memory, and
                        ; return from the subroutine using a tail call

; ******************************************************************************
;
;       Name: HALL_b1
;       Type: Subroutine
;   Category: Ship hangar
;    Summary: Call the HALL routine in ROM bank 1
;
; ******************************************************************************

.HALL_b1

 LDA currentBank        ; Fetch the number of the ROM bank that is currently
 PHA                    ; paged into memory at $8000 and store it on the stack

 LDA #1                 ; Page ROM bank 1 into memory at $8000
 JSR SetBank

 JSR HALL               ; Call HALL, now that it is paged into memory

 JMP ResetBank          ; Fetch the previous ROM bank number from the stack and
                        ; page that bank back into memory at $8000, returning
                        ; from the subroutine using a tail call

; ******************************************************************************
;
;       Name: CHPR_b2
;       Type: Subroutine
;   Category: Text
;    Summary: Call the CHPR routine in ROM bank 2
;
; ******************************************************************************

.CHPR_b2

 STA ASAV               ; Store the value of A so we can retrieve it below

 LDA currentBank        ; If ROM bank 2 is already paged into memory, jump to
 CMP #2                 ; bank22
 BEQ bank22

 PHA                    ; Otherwise store the current bank number on the stack

 LDA #2                 ; Page ROM bank 2 into memory at $8000
 JSR SetBank

 LDA ASAV               ; Restore the value of A that we stored above

 JSR CHPR               ; Call CHPR, now that it is paged into memory

 JMP ResetBank          ; Fetch the previous ROM bank number from the stack and
                        ; page that bank back into memory at $8000, returning
                        ; from the subroutine using a tail call

.bank22

 LDA ASAV               ; Restore the value of A that we stored above

 JMP CHPR               ; Call CHPR, which is already paged into memory, and
                        ; return from the subroutine using a tail call

; ******************************************************************************
;
;       Name: DASC_b2
;       Type: Subroutine
;   Category: Text
;    Summary: Call the DASC routine in ROM bank 2
;
; ******************************************************************************

.DASC_b2

 STA ASAV               ; Store the value of A so we can retrieve it below

 LDA currentBank        ; If ROM bank 2 is already paged into memory, jump to
 CMP #2                 ; bank23
 BEQ bank23

 PHA                    ; Otherwise store the current bank number on the stack

 LDA #2                 ; Page ROM bank 2 into memory at $8000
 JSR SetBank

 LDA ASAV               ; Restore the value of A that we stored above

 JSR DASC               ; Call DASC, now that it is paged into memory

 JMP ResetBank          ; Fetch the previous ROM bank number from the stack and
                        ; page that bank back into memory at $8000, returning
                        ; from the subroutine using a tail call

.bank23

 LDA ASAV               ; Restore the value of A that we stored above

 JMP DASC               ; Call DASC, which is already paged into memory, and
                        ; return from the subroutine using a tail call

; ******************************************************************************
;
;       Name: TT27_b2
;       Type: Subroutine
;   Category: Text
;    Summary: Call the TT27 routine in ROM bank 2
;
; ******************************************************************************

.TT27_b2

 STA ASAV               ; Store the value of A so we can retrieve it below

 LDA currentBank        ; If ROM bank 2 is already paged into memory, jump to
 CMP #2                 ; bank24
 BEQ bank24

 PHA                    ; Otherwise store the current bank number on the stack

 LDA #2                 ; Page ROM bank 2 into memory at $8000
 JSR SetBank

 LDA ASAV               ; Restore the value of A that we stored above

 JSR TT27               ; Call TT27, now that it is paged into memory

 JMP ResetBank          ; Fetch the previous ROM bank number from the stack and
                        ; page that bank back into memory at $8000, returning
                        ; from the subroutine using a tail call

.bank24

 LDA ASAV               ; Restore the value of A that we stored above

 JMP TT27               ; Call TT27, which is already paged into memory, and
                        ; return from the subroutine using a tail call

; ******************************************************************************
;
;       Name: ex_b2
;       Type: Subroutine
;   Category: Text
;    Summary: Call the ex routine in ROM bank 2
;
; ******************************************************************************

.ex_b2

 STA ASAV               ; Store the value of A so we can retrieve it below

 LDA currentBank        ; If ROM bank 2 is already paged into memory, jump to
 CMP #2                 ; bank25
 BEQ bank25

 PHA                    ; Otherwise store the current bank number on the stack

 LDA #2                 ; Page ROM bank 2 into memory at $8000
 JSR SetBank

 LDA ASAV               ; Restore the value of A that we stored above

 JSR ex                 ; Call ex, now that it is paged into memory

 JMP ResetBank          ; Fetch the previous ROM bank number from the stack and
                        ; page that bank back into memory at $8000, returning
                        ; from the subroutine using a tail call

.bank25

 LDA ASAV               ; Restore the value of A that we stored above

 JMP ex                 ; Call ex, which is already paged into memory, and
                        ; return from the subroutine using a tail call

; ******************************************************************************
;
;       Name: PrintCtrlCode_b0
;       Type: Subroutine
;   Category: Text
;    Summary: Call the PrintCtrlCode routine in ROM bank 0
;
; ******************************************************************************

.PrintCtrlCode_b0

 LDA currentBank        ; Fetch the number of the ROM bank that is currently
 PHA                    ; paged into memory at $8000 and store it on the stack

 LDA #0                 ; Page ROM bank 0 into memory at $8000
 JSR SetBank

 JSR PrintCtrlCode      ; Call PrintCtrlCode, now that it is paged into memory

 JMP ResetBank          ; Fetch the previous ROM bank number from the stack and
                        ; page that bank back into memory at $8000, returning
                        ; from the subroutine using a tail call

; ******************************************************************************
;
;       Name: StartAfterLoad_b0
;       Type: Subroutine
;   Category: Start and end
;    Summary: Call the StartAfterLoad routine in ROM bank 0
;
; ******************************************************************************

.StartAfterLoad_b0

 LDA currentBank        ; If ROM bank 0 is already paged into memory, jump to
 CMP #0                 ; bank26
 BEQ bank26

 PHA                    ; Otherwise store the current bank number on the stack

 LDA #0                 ; Page ROM bank 0 into memory at $8000
 JSR SetBank

 JSR StartAfterLoad     ; Call StartAfterLoad, now that it is paged into memory

 JMP ResetBank          ; Fetch the previous ROM bank number from the stack and
                        ; page that bank back into memory at $8000, returning
                        ; from the subroutine using a tail call

.bank26

 JMP StartAfterLoad     ; Call StartAfterLoad, which is already paged into
                        ; memory, and return from the subroutine using a tail
                        ; call

; ******************************************************************************
;
;       Name: RemoveFromScanner_b1
;       Type: Subroutine
;   Category: Dashboard
;    Summary: Remove a ship from the scanner
;
; ******************************************************************************

.RemoveFromScanner_b1

 LDA #0                 ; Zero byte #33 in the current ship's data block at K%,
 LDY #33                ; so it is not shown on the scanner (a non-zero byte #33
 STA (INF),Y            ; represents the ship's number on the scanner, with a
                        ; ship number of zero indicating that the ship is not
                        ; shown on the scanner)

                        ; Fall through into HideFromScanner to hide the scanner
                        ; sprites for this ship and reset byte #33 in the INWK
                        ; workspace

; ******************************************************************************
;
;       Name: HideFromScanner_b1
;       Type: Subroutine
;   Category: Dashboard
;    Summary: Call the HideFromScanner routine in ROM bank 1
;
; ******************************************************************************

.HideFromScanner_b1

 LDA currentBank        ; Fetch the number of the ROM bank that is currently
 PHA                    ; paged into memory at $8000 and store it on the stack

 LDA #1                 ; Page ROM bank 1 into memory at $8000
 JSR SetBank

 JSR HideFromScanner    ; Call HideFromScanner, now that it is paged into memory

 JMP ResetBank          ; Fetch the previous ROM bank number from the stack and
                        ; page that bank back into memory at $8000, returning
                        ; from the subroutine using a tail call

; ******************************************************************************
;
;       Name: TT66_b0
;       Type: Subroutine
;   Category: Drawing the screen
;    Summary: Call the TT66 routine in ROM bank 0
;
; ******************************************************************************

.TT66_b0

 STA ASAV               ; Store the value of A so we can retrieve it below

 LDA currentBank        ; Fetch the number of the ROM bank that is currently
 PHA                    ; paged into memory at $8000 and store it on the stack

 LDA #0                 ; Page ROM bank 0 into memory at $8000
 JSR SetBank

 LDA ASAV               ; Restore the value of A that we stored above

 JSR TT66               ; Call TT66, now that it is paged into memory

 JMP ResetBank          ; Fetch the previous ROM bank number from the stack and
                        ; page that bank back into memory at $8000, returning
                        ; from the subroutine using a tail call

; ******************************************************************************
;
;       Name: CLIP_LOIN_b1
;       Type: Subroutine
;   Category: Drawing lines
;    Summary: Call the CLIP routine in ROM bank 1, drawing the clipped line if
;             it fits on-screen
;
; ******************************************************************************

.CLIP_LOIN_b1

 LDA currentBank        ; Fetch the number of the ROM bank that is currently
 PHA                    ; paged into memory at $8000 and store it on the stack

 LDA #1                 ; Page ROM bank 1 into memory at $8000
 JSR SetBank

 JSR CLIP               ; Call CLIP, now that it is paged into memory

 BCS P%+5               ; If the C flag is set then the clipped line does not
                        ; fit on-screen, so skip the next instruction

 JSR LOIN               ; The clipped line fits on-screen, so draw it

 JMP ResetBank          ; Fetch the previous ROM bank number from the stack and
                        ; page that bank back into memory at $8000, returning
                        ; from the subroutine using a tail call

; ******************************************************************************
;
;       Name: ClearScreen_b3
;       Type: Subroutine
;   Category: Drawing the screen
;    Summary: Call the ClearScreen routine in ROM bank 3
;
; ******************************************************************************

.ClearScreen_b3

 LDA currentBank        ; If ROM bank 3 is already paged into memory, jump to
 CMP #3                 ; bank27
 BEQ bank27

 PHA                    ; Otherwise store the current bank number on the stack

 LDA #3                 ; Page ROM bank 3 into memory at $8000
 JSR SetBank

 JSR ClearScreen        ; Call ClearScreen, now that it is paged into memory

 JMP ResetBank          ; Fetch the previous ROM bank number from the stack and
                        ; page that bank back into memory at $8000, returning
                        ; from the subroutine using a tail call

.bank27

 JMP ClearScreen        ; Call ClearScreen, which is already paged into memory,
                        ; and return from the subroutine using a tail call

; ******************************************************************************
;
;       Name: SCAN_b1
;       Type: Subroutine
;   Category: Dashboard
;    Summary: Call the SCAN routine in ROM bank 1
;
; ******************************************************************************

.SCAN_b1

 LDA currentBank        ; If ROM bank 1 is already paged into memory, jump to
 CMP #1                 ; bank28
 BEQ bank28

 PHA                    ; Otherwise store the current bank number on the stack

 LDA #1                 ; Page ROM bank 1 into memory at $8000
 JSR SetBank

 JSR SCAN               ; Call SCAN, now that it is paged into memory

 JMP ResetBank          ; Fetch the previous ROM bank number from the stack and
                        ; page that bank back into memory at $8000, returning
                        ; from the subroutine using a tail call

.bank28

 JMP SCAN               ; Call SCAN, which is already paged into memory, and
                        ; return from the subroutine using a tail call

; ******************************************************************************
;
;       Name: DrawViewInNMI2
;       Type: Subroutine
;   Category: Drawing the screen
;    Summary: ???
;
; ******************************************************************************

.DrawViewInNMI2

 JSR HideMostSprites1

; ******************************************************************************
;
;       Name: DrawViewInNMI_b0
;       Type: Subroutine
;   Category: Drawing the screen
;    Summary: Call the DrawViewInNMI routine in ROM bank 0
;
; ******************************************************************************

.DrawViewInNMI_b0

 LDA currentBank        ; Fetch the number of the ROM bank that is currently
 PHA                    ; paged into memory at $8000 and store it on the stack

 LDA #0                 ; Page ROM bank 0 into memory at $8000
 JSR SetBank

 JSR DrawViewInNMI      ; Call DrawViewInNMI, now that it is paged into memory

 JMP ResetBank          ; Fetch the previous ROM bank number from the stack and
                        ; page that bank back into memory at $8000, returning
                        ; from the subroutine using a tail call

; ******************************************************************************
;
;       Name: SetupHangarInPPU
;       Type: Subroutine
;   Category: Drawing the screen
;    Summary: ???
;
; ******************************************************************************

.SetupHangarInPPU

 LDA #0                 ; Page ROM bank 0 into memory at $8000
 JSR SetBank

 JSR CopyNameBuffer0To1

 JSR SetupViewInPPU2    ; Call SetupViewInPPU2, now that it is paged into memory

 LDX #1
 STX hiddenBitPlane
 RTS

; ******************************************************************************
;
;       Name: CLYNS
;       Type: Subroutine
;   Category: Drawing the screen
;    Summary: ???
;
; ------------------------------------------------------------------------------
;
; Other entry points:
;
;   CLYNS+8             Don't zero DLY and de
;
; ******************************************************************************

.CLYNS

 LDA #0
 STA DLY
 STA de

 LDA #$FF
 STA DTW2
 LDA #$80
 STA QQ17
 LDA #$16
 STA YC
 LDA #1
 STA XC
 LDA firstPatternTile
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
;       Name: alertColours
;       Type: Variable
;   Category: Status
;    Summary: Colours for the background of the commander image to show the
;             status condition when we are not looking at the space view
;
; ******************************************************************************

.alertColours

 EQUB $1C               ; Colour for condition Docked (blue-green)

 EQUB $1A               ; Colour for condition Green (green)

 EQUB $28               ; Colour for condition Yellow (orange)

 EQUB $16               ; Colour for condition Red (light red)

 EQUB $06               ; Flash with this colour (dark red) for condition Red

; ******************************************************************************
;
;       Name: GetStatusCondition
;       Type: Subroutine
;   Category: Status
;    Summary: Calculate our ship's status condition
;
; ------------------------------------------------------------------------------
;
; Returns:
;
;   statusCondition     Our ship's status condition:
;
;                         * 0 = Docked
;
;                         * 1 = Green
;
;                         * 2 = Yellow
;
;                         * 3 = Red
;
;   X                   Also contains the status condition
;
; ******************************************************************************

.GetStatusCondition

 LDX #0                 ; We start with a status condition of 0, which means
                        ; there is nothing to worry about

 LDY QQ12               ; Fetch the docked status from QQ12, and if we are
 BNE cond2              ; docked, jump to cond2 to return 0 ("Docked") as our
                        ; status condition

 INX                    ; We are in space, so increment X to 1 ("Green")

 LDY JUNK               ; Set Y to the number of junk items in our local bubble
                        ; of universe (where junk is asteroids, canisters,
                        ; escape pods and so on)

 LDA FRIN+2,Y           ; The ship slots at FRIN are ordered with the first two
                        ; slots reserved for the planet and sun/space station,
                        ; and then any ships, so if the slot at FRIN+2+Y is not
                        ; empty (i.e. is non-zero), then that means the number
                        ; of non-asteroids in the vicinity is at least 1

 BEQ cond2              ; So if X = 0, there are no ships in the vicinity, so
                        ; jump to cond2 to store 1 ("Green") as our status
                        ; condition

 INX                    ; Otherwise there are non-asteroids in the vicinity, so
                        ; increment X to 2 ("Yellow")

 LDY statusCondition    ; If the previous condition in statusCondition was 3
 CPY #3                 ; ("Red"), then jump to cond3
 BEQ cond3

 LDA ENERGY             ; If our energy levels are 128 or greater, jump to cond2
 BMI cond2              ; to store 2 ("Yellow") as our status condition

.cond1

                        ; If we get here then either our energy levels are less
                        ; than 128, or our previous condition was "Red" and our
                        ; energy levels are less than 160
                        ;
                        ; So once our energy levels are low enough to trigger a
                        ; "Red" status, it stays that way until our energy
                        ; levels recover to a higher level

 INX                    ; Increment X to 3 ("Red")

.cond2

 STX statusCondition    ; Store our new status condition in statusCondition

 RTS                    ; Return from the subroutine

.cond3

 LDA ENERGY             ; If our energy levels are less than 160, jump to cond1
 CMP #160               ; to return a "Red" status condition
 BCC cond1

 BCS cond2              ; Jump to cond2 to return a "Yellow" status condition
                        ; (this BCS is effectively a JMP as we just passed
                        ; through a BCC)

; ******************************************************************************
;
;       Name: SetupDemoUniverse
;       Type: Subroutine
;   Category: Demo
;    Summary: Initialise the local bubble of univers for the demo
;
; ******************************************************************************

.SetupDemoUniverse

 LDY #12                ; Wait until 12 NMI interrupts have passed (i.e. the
 JSR DELAY              ; next 12 VBlanks)

 LDA #0                 ; Set A = 0
 CLC                    ;
 ADC #0                 ; The ADC has no effect, so presumably it was left over
                        ; from a previous version of the code

 STA frameCounter       ; Reset the frame counter to zero

 STA nmiTimer           ; Set the NMI timer to zero
 STA nmiTimerLo
 STA nmiTimerHi

 STA hiddenBitPlane     ; Set the hidden, NMI and drawing bitplanes to 0
 STA nmiBitplane
 STA drawingBitplane

 LDA #$FF               ; Set L0307 = $FF ???
 STA L0307

 LDA #$80               ; Set L0308 = $80 ???
 STA L0308

 LDA #$1B               ; Set L0309 = $1B ???
 STA L0309

 LDA #$34               ; Set L030A = $34 ???
 STA L030A

 JSR ResetOptions       ; Reset the game options to their default values

 LDA #0                 ; Set K%+6 = 0 ???
 STA K%+6

 STA K%                 ; Set K% = 0 ???

                        ; Fall through into FixRandomNumbers to set the random
                        ; number seeds to a known state

; ******************************************************************************
;
;       Name: FixRandomNumbers
;       Type: Subroutine
;   Category: Demo
;    Summary: Fix the random number seeds to a known value so the random numbers
;             generated are always the same when we run the demo
;
; ******************************************************************************

.FixRandomNumbers

 LDA #$75               ; Set the random number seeds to a known state, so the
 STA RAND               ; demo plays out in the same way every time
 LDA #$0A
 STA RAND+1
 LDA #$2A
 STA RAND+2
 LDX #$E6
 STX RAND+3

 RTS                    ; Return from the subroutine

; ******************************************************************************
;
;       Name: ResetOptions
;       Type: Subroutine
;   Category: Start and end
;    Summary: Reset the game options to their default values
;
; ******************************************************************************

.ResetOptions

 LDA #0                 ; Configure the joystick Y-channel to the default
 STA JSTGY              ; direction (i.e. not reversed) by setting JSTGY to 0

 STA disableMusic       ; Configure music to be enabled by default by setting
                        ; disableMusic to 0

 LDA #$FF               ; Configure damping to be enabled by default by setting
 STA DAMP               ; DAMP to $FF

 STA DNOIZ              ; Configure sound to be enabled by default by setting
                        ; DNOIZ to $FF

 RTS                    ; Return from the subroutine

; ******************************************************************************
;
;       Name: DrawTitleScreen
;       Type: Subroutine
;   Category: Start and end
;    Summary: ???
;
; ******************************************************************************

.DrawTitleScreen

 JSR FetchPalettes1_b3
 LDA #0
 JSR ChooseMusic_b6

 JSR HideMostSprites    ; Hide all sprites except for sprite 0 and the icon bar
                        ; pointer

 LDA #$FF               ; Set the old view type in QQ11a to $FF (Start screen
 STA QQ11a              ; both fonts loaded)

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
 LDA titleShipType,Y
 BEQ loop_CF3DA
 TAX
 LDA titleShipDist,Y
 TAY
 LDA #6
 JSR TITLE
 BCS CF411
 LDY L03FC
 INY
 LDA nmiTimerHi
 CMP #1
 BCC loop_CF3DC
 LSR scanController2
 JSR ResetMusicAfterNMI
 JSR FetchPalettes1_b3
 LDA languageIndex
 STA K%
 LDA #5
 STA K%+1
 JMP CC035

.CF411

 JSR ResetMusicAfterNMI
 RTS

; ******************************************************************************
;
;       Name: titleShipType
;       Type: Variable
;   Category: Start and end
;    Summary: ???
;
; ******************************************************************************

.titleShipType

 EQUB $0B, $13, $14, $19, $1D, $15, $12, $1B
 EQUB $0A,   1, $11, $10,   0

; ******************************************************************************
;
;       Name: titleShipDist
;       Type: Variable
;   Category: Start and end
;    Summary: ???
;
; ******************************************************************************

.titleShipDist

 EQUB $64, $0A, $0A, $1E, $B4, $0A, $28, $5A
 EQUB $0A, $46, $28, $0A

; ******************************************************************************
;
;       Name: Ze
;       Type: Subroutine
;   Category: Universe
;    Summary: Initialise the INWK workspace to a hostile ship
;  Deep dive: Fixing ship positions
;
; ------------------------------------------------------------------------------
;
; Specifically, this routine does the following:
;
;   * Reset the INWK ship workspace
;
;   * Set the ship to a fair distance away in all axes, in front of us but
;     randomly up or down, left or right
;
;   * Give the ship a 4% chance of having E.C.M.
;
;   * Set the ship to hostile, with AI enabled
;
; This routine also sets A, X, T1 and the C flag to random values.
;
; Note that because this routine uses the value of X returned by DORND, and X
; contains the value of A returned by the previous call to DORND, this routine
; does not necessarily set the new ship to a totally random location. See the
; deep dive on "Fixing ship positions" for details.
;
; ******************************************************************************

.Ze

 JSR ZINF               ; Call ZINF to reset the INWK ship workspace

 JSR DORND              ; Set A and X to random numbers

 STA T1                 ; Store A in T1

 AND #%10000000         ; Extract the sign of A and store in x_sign
 STA INWK+2

 JSR DORND              ; Set A and X to random numbers

 AND #%10000000         ; Extract the sign of A and store in y_sign
 STA INWK+5

 LDA #25                ; Set x_hi = y_hi = z_hi = 25, a fair distance away
 STA INWK+1
 STA INWK+4
 STA INWK+7

 TXA                    ; Set the C flag if X >= 245 (4% chance)
 CMP #245

 ROL A                  ; Set bit 0 of A to the C flag (i.e. there's a 4%
                        ; chance of this ship having E.C.M.)

 ORA #%11000000         ; Set bits 6 and 7 of A, so the ship is hostile (bit 6
                        ; and has AI (bit 7)

 STA INWK+32            ; Store A in the AI flag of this ship

 JMP DORND2             ; Jump to DORND2 to set A, X and the C flag randomly,
                        ; returning from the subroutine using a tail call

; ******************************************************************************
;
;       Name: UpdateSaveCount
;       Type: Subroutine
;   Category: Save and load
;    Summary: Update the save counter for the current commander
;
; ------------------------------------------------------------------------------
;
; Returns:
;
;   A                   A is preserved
;
; ******************************************************************************

.UpdateSaveCount

 PHA                    ; Store A on the stack so we can retrieve it below

 LDA SVC                ; If bit 7 of SVC is set, then we have already
 BMI scnt1              ; incremented the save counter for the current
                        ; commander, so jump to scnt1 to skip the following and
                        ; leave SVC alone

 CLC                    ; Set A = A + 1, to increment the save counter
 ADC #1

 CMP #100               ; If A < 100, skip the following instruction
 BCC scnt1

 LDA #0                 ; Set A = 0, so the save counter goes from zero to 100
                        ; and around back to zero again

.scnt1

 ORA #%10000000         ; Set bit 7 of A to flag the save counter as increments,
                        ; so the next call to this routine does nothing

 STA SVC                ; Store the updated save counter in SVC

 PLA                    ; Retrieve the value of A we stored on the stack above

 RTS                    ; Return from the subroutine

; ******************************************************************************
;
;       Name: NLIN3
;       Type: Subroutine
;   Category: Drawing lines
;    Summary: Print a title and draw a screen-wide horizontal line on tile row 2
;             to box it in
;
; ******************************************************************************

.NLIN3

 PHA                    ; Move the text cursor to row 0
 LDA #0
 STA YC
 PLA

 JSR TT27_b2            ; Print the text token in A

                        ; Fall through into NLIN4 to draw a horizontal line at
                        ; pixel row 19

; ******************************************************************************
;
;       Name: NLIN4
;       Type: Subroutine
;   Category: Drawing lines
;    Summary: Draw a horizontal line on tile row 2 to box in a title
;
; ******************************************************************************

.NLIN4

 LDA #4                 ; Set A = 4, though this has no effect other than making
                        ; the BNE work, as NLIN2 overwrites this value

 BNE NLIN2              ; Jump to NLIN2 to draw the line, (this BNE is
                        ; effectively a JMP as A is never zero)

 LDA #1                 ; These instructions appear to be unused
 STA YC
 LDA #4

; ******************************************************************************
;
;       Name: NLIN2
;       Type: Subroutine
;   Category: Drawing lines
;    Summary: Draw a horizontal line on tile row 2 to box in a title
;
; ******************************************************************************

.NLIN2

 JSR SetupPPUForIconBar ; If the PPU has started drawing the icon bar, configure
                        ; the PPU to use nametable 0 and pattern table 0

 LDY #1                 ; We now draw a horizontal line into the nametable
                        ; buffer starting at column 1, so set Y as a counter for
                        ; the column number

 LDA #3                 ; Set A to tile 3 so we draw the line as a horizontal
                        ; line that's three pixels thick

.nlin1

 STA nameBuffer0+2*32,Y ; Set the Y-th tile on row 2 of nametable buffer 0 to
                        ; to tile 3

 INY                    ; Increment the column counter

 CPY #32                ; Keep drawing tile 3 along row 2 until we have drawn
 BNE nlin1              ; column 31

 RTS                    ; Return from the subroutine

; ******************************************************************************
;
;       Name: SetDrawingPlaneTo0
;       Type: Subroutine
;   Category: Drawing the screen
;    Summary: Set the drawing bitplane to 0
;
; ******************************************************************************

.SetDrawingPlaneTo0

 LDX #0                 ; Set the drawing bitplane to 0
 JSR SetDrawingBitplane

 RTS                    ; Return from the subroutine

; ******************************************************************************
;
;       Name: ResetBuffers
;       Type: Subroutine
;   Category: Drawing the screen
;    Summary: Reset the pattern and nametable buffers
;
; ------------------------------------------------------------------------------
;
; The pattern buffers are in a continuous block of memory as follows:
;
;   * pattBuffer0 ($6000 to $67FF)
;   * pattBuffer1 ($6800 to $6FFF)
;   * nameBuffer0 ($7000 to $73BF)
;   * attrBuffer0 ($73C0 to $73FF)
;   * nameBuffer1 ($7400 to $77BF)
;   * attrBuffer1 ($77C0 to $77FF)
;
; This covers $1800 bytes (24 pages of memory), and this routine zeroes the
; whole lot.
;
; ******************************************************************************

.ResetBuffers

 LDA #HI(pattBuffer0)   ; Set SC2(1 0) to pattBuffer0, the address of the first
 STA SC2+1              ; of the buffers we want to clear
 LDA #Lo(pattBuffer0)
 STA SC2

 LDY #0                 ; Set Y as a byte counter that we can use as an index
                        ; into each page of memory as we clear them

 LDX #$18               ; We want to zero memory from $6000 to $7800, so set a
                        ; page counter in X to count each page of memory as we
                        ; clear them

 LDA #0                 ; We are going to clear the buffers by filling them with
                        ; zeroes, so set A = 0 so we can poke it into memory

.rbuf1

 STA (SC2),Y            ; Zero the Y-th byte of SC2(1 0)

 INY                    ; Increment the byte counter

 BNE rbuf1              ; Loop back until we have zeroed a full page of memory

 INC SC2+1              ; Increment the high byte of SC2(1 0) so it points to
                        ; the next page in memory

 DEX                    ; Decrement the page counter in X

 BNE rbuf1              ; Loop back until we have zeroed all X pages of memory

 RTS                    ; Return from the subroutine

; ******************************************************************************
;
;       Name: DORND
;       Type: Subroutine
;   Category: Utility routines
;    Summary: Generate random numbers
;  Deep dive: Generating random numbers
;             Fixing ship positions
;
; ------------------------------------------------------------------------------
;
; Set A and X to random numbers (though note that X is set to the random number
; that was returned in A the last time DORND was called).
;
; The C and V flags are also set randomly.
;
; If we want to generate a repeatable sequence of random numbers, when
; generating explosion clouds, for example, then we call DORND2 to ensure that
; the value of the C flag on entry doesn't affect the outcome, as otherwise we
; might not get the same sequence of numbers if the C flag changes.
;
; Other entry points:
;
;   DORND2              Make sure the C flag doesn't affect the outcome
;
; ******************************************************************************

.DORND2

 CLC                    ; Clear the C flag so the value of the C flag on entry
                        ; doesn't affect the outcome

.DORND

 LDA RAND               ; Calculate the next two values f2 and f3 in the feeder
 ROL A                  ; sequence:
 TAX                    ;
 ADC RAND+2             ;   * f2 = (f1 << 1) mod 256 + C flag on entry
 STA RAND               ;   * f3 = f0 + f2 + (1 if bit 7 of f1 is set)
 STX RAND+2             ;   * C flag is set according to the f3 calculation

 LDA RAND+1             ; Calculate the next value m2 in the main sequence:
 TAX                    ;
 ADC RAND+3             ;   * A = m2 = m0 + m1 + C flag from feeder calculation
 STA RAND+1             ;   * X = m1
 STX RAND+3             ;   * C and V flags set according to the m2 calculation

 RTS                    ; Return from the subroutine

; ******************************************************************************
;
;       Name: PROJ
;       Type: Subroutine
;   Category: Drawing ships
;    Summary: Project the current ship onto the screen
;  Deep dive: Extended screen coordinates
;
; ------------------------------------------------------------------------------
;
; Project the current ship's location onto the screen, either returning the
; screen coordinates of the projection (if it's on-screen), or returning an
; error via the C flag.
;
; In this context, "on-screen" means that the point is projected into the
; following range:
;
;   centre of screen - 1024 < x < centre of screen + 1024
;   centre of screen - 1024 < y < centre of screen + 1024
;
; This is to cater for ships (and, more likely, planets and suns) whose centres
; are off-screen but whose edges may still be visible.
;
; The projection calculation is:
;
;   K3(1 0) = #X + x / z
;   K4(1 0) = #Y + y / z
;
; where #X and #Y are the pixel x-coordinate and y-coordinate of the centre of
; the screen.
;
; Arguments:
;
;   INWK                The ship data block for the ship to project on-screen
;
; Returns:
;
;   K3(1 0)             The x-coordinate of the ship's projection on-screen
;
;   K4(1 0)             The y-coordinate of the ship's projection on-screen
;
;   C flag              Set if the ship's projection doesn't fit on the screen,
;                       clear if it does project onto the screen
;
;   A                   Contains K4+1, the high byte of the y-coordinate
;
; ******************************************************************************

.PROJ

 LDA INWK               ; Set P(1 0) = (x_hi x_lo)
 STA P                  ;            = x
 LDA INWK+1
 STA P+1

 LDA INWK+2             ; Set A = x_sign

 JSR PLS6               ; Call PLS6 to calculate:
                        ;
                        ;   (X K) = (A P) / (z_sign z_hi z_lo)
                        ;         = (x_sign x_hi x_lo) / (z_sign z_hi z_lo)
                        ;         = x / z

 BCS PL21S-1            ; If the C flag is set then the result overflowed and
                        ; the coordinate doesn't fit on the screen, so return
                        ; from the subroutine with the C flag set (as PL21S-1
                        ; contains an RTS)

 LDA K                  ; Set K3(1 0) = (X K) + #X
 ADC #X                 ;             = #X + x / z
 STA K3                 ;
                        ; first doing the low bytes

 TXA                    ; And then the high bytes. #X is the x-coordinate of
 ADC #0                 ; the centre of the space view, so this converts the
 STA K3+1               ; space x-coordinate into a screen x-coordinate

 LDA INWK+3             ; Set P(1 0) = (y_hi y_lo)
 STA P
 LDA INWK+4
 STA P+1

 LDA INWK+5             ; Set A = -y_sign
 EOR #%10000000

 JSR PLS6               ; Call PLS6 to calculate:
                        ;
                        ;   (X K) = (A P) / (z_sign z_hi z_lo)
                        ;         = -(y_sign y_hi y_lo) / (z_sign z_hi z_lo)
                        ;         = -y / z

 BCS PL21S-1            ; If the C flag is set then the result overflowed and
                        ; the coordinate doesn't fit on the screen, so return
                        ; from the subroutine with the C flag set (as PL21S-1
                        ; contains an RTS)

 LDA K                  ; Set K4(1 0) = (X K) + Yx1M2
 ADC Yx1M2              ;             = Yx1M2 - y / z
 STA K4                 ;
                        ; first doing the low bytes

 TXA                    ; And then the high bytes. Yx1M2 is the y-coordinate of
 ADC #0                 ; the centre of the space view, so this converts the
 STA K4+1               ; space x-coordinate into a screen y-coordinate

 CLC                    ; Clear the C flag to indicate success

 RTS                    ; Return from the subroutine

; ******************************************************************************
;
;       Name: PLS6
;       Type: Subroutine
;   Category: Drawing planets
;    Summary: Calculate (X K) = (A P) / (z_sign z_hi z_lo)
;
; ------------------------------------------------------------------------------
;
; Calculate the following:
;
;   (X K) = (A P) / (z_sign z_hi z_lo)
;
; returning an overflow in the C flag if the result is >= 1024.
;
; Arguments:
;
;   INWK                The planet or sun's ship data block
;
; Returns:
;
;   C flag              Set if the result >= 1024, clear otherwise
;
; ******************************************************************************

.PL21S

 SEC                    ; Set the C flag to indicate an overflow

 RTS                    ; Return from the subroutine

.PLS6

 JSR DVID3B2            ; Call DVID3B2 to calculate:
                        ;
                        ;   K(3 2 1 0) = (A P+1 P) / (z_sign z_hi z_lo)

 SETUP_PPU_FOR_ICON_BAR ; If the PPU has started drawing the icon bar, configure
                        ; the PPU to use nametable 0 and pattern table 0

 LDA K+3                ; Set A = |K+3| OR K+2
 AND #%01111111
 ORA K+2

 BNE PL21S              ; If A is non-zero then the two high bytes of K(3 2 1 0)
                        ; are non-zero, so jump to PL21S to set the C flag and
                        ; return from the subroutine

                        ; We can now just consider K(1 0), as we know the top
                        ; two bytes of K(3 2 1 0) are both 0

 LDX K+1                ; Set X = K+1, so now (X K) contains the result in
                        ; K(1 0), which is the format we want to return the
                        ; result in

 CPX #4                 ; If the high byte of K(1 0) >= 4 then the result is
 BCS PL6                ; >= 1024, so return from the subroutine with the C flag
                        ; set to indicate an overflow (as PL6 contains an RTS)

 LDA K+3                ; Fetch the sign of the result from K+3 (which we know
                        ; has zeroes in bits 0-6, so this just fetches the sign)

 BPL PL6                ; If the sign bit is clear and the result is positive,
                        ; then the result is already correct, so return from
                        ; the subroutine with the C flag clear to indicate
                        ; success (as PL6 contains an RTS)

 LDA K                  ; Otherwise we need to negate the result, which we do
 EOR #%11111111         ; using two's complement, starting with the low byte:
 ADC #1                 ;
 STA K                  ;   K = ~K + 1

 TXA                    ; And then the high byte:
 EOR #%11111111         ;
 ADC #0                 ;   X = ~X
 TAX

 CLC                    ; Clear the C flag to indicate success

.PL6

 RTS                    ; Return from the subroutine

; ******************************************************************************
;
;       Name: UnpackToRAM
;       Type: Subroutine
;   Category: Utility routines
;    Summary: Unpack compressed image data to RAM
;
; ------------------------------------------------------------------------------
;
; This routine unpacks compressed data into RAM. The data is typically nametable
; or pattern data that is unpacked into the nametable or pattern buffers.
;
; UnpackToRAM reads packed data from V(1 0) and writes unpacked data to SC(1 0)
; by fetching bytes one at a time from V(1 0), incrementing V(1 0) after each
; fetch, and unpacking and writing the data to SC(1 0) as it goes.
;
; If we fetch byte $xx from V(1 0), then we unpack it as follows:
;
;   * If $xx >= $40, output byte $xx as it is and move on to the next byte
;
;   * If $xx = $x0, output byte $x0 as it is and move on to the next byte
;
;   * If $xx = $3F, stop and return from the subroutine, as we have finished
;
;   * If $xx >= $20, jump to upac6 to do the following:
;
;     * If $xx >= $30, jump to upac7 to output the next $0x bytes from V(1 0) as
;                      they are, incrementing V(1 0) as we go
;
;     * If $xx >= $20, fetch the next byte from V(1 0), increment V(1 0), and
;                      output the fetched byte for $0x bytes
;
;   * If $xx >= $10, jump to upac5 to output $FF for $0x bytes
;
;   * If $xx < $10, output 0 for $0x bytes
;
; In summary, this is how each byte gets unpacked:
;
;   $00 = unchanged
;   $0x = output 0 for $0x bytes
;   $10 = unchanged
;   $1x = output $FF for $0x bytes
;   $20 = unchanged
;   $2x = output the next byte for $0x bytes
;   $30 = unchanged
;   $3x = output the next $0x bytes unchanged
;   $40 and above = unchanged
;
; ******************************************************************************

.UnpackToRAM

 LDY #0                 ; We work our way through the packed data at SC(1 0), so
                        ; set an index counter in Y, starting from the first
                        ; data byte at offset zero

.upac1

 SETUP_PPU_FOR_ICON_BAR ; If the PPU has started drawing the icon bar, configure
                        ; the PPU to use nametable 0 and pattern table 0

 LDX #0                 ; Set X = 0, so we can use a LDA (V,X) instruction below
                        ; to fetch the next data byte from V(1 0), as the 6502
                        ; doesn't have a LDA (V) instruction

 LDA (V,X)              ; Set A to the byte of packed data at V(1 0), which is
                        ; the next byte of data to unpack
                        ;
                        ; As X = 0, this instruction is effectively LDA (V),
                        ; which isn't a valid 6502 instruction on its own

 INC V                  ; Increment V(1 0) to point to the next byte of packed
 BNE upac2              ; data
 INC V+1

.upac2

 CMP #$40               ; If A >= $40, jump to unpac12 to output the data in A
 BCS upac12             ; as it is, and move on to the next byte

                        ; If we get here then we know that the data byte in A is
                        ; of the form $0x, $1x, $2x or $3x

 TAX                    ; Store the packed data byte in X so we can retrieve it
                        ; below

 AND #$0F               ; If the data byte in A is in the format $x0, jump to
 BEQ upac11             ; upac11 to output the data in X as it is, and move on
                        ; to the next byte

 CPX #$3F               ; If the data byte in X is $3F, then this indicates we
 BEQ upac13             ; have reached the end of the packed data, so jump to
                        ; upac13 to return from the subroutine, as we are done

 TXA                    ; Set A back to the unpacked data byte, which we stored
                        ; in X above

 CMP #$20               ; If A >= $20, jump to upac6 to process values of $2x
 BCS upac6              ; and $3x (as we already processed values above $40)

                        ; If we get here then we know that the data byte in A is
                        ; of the form $0x or $1x (and not $x0)

 CMP #$10               ; If A >= $10, set the C flag

 AND #$0F               ; Set X to the lower nibble of A, so it contains the
 TAX                    ; number of zeroes or $FF bytes that we need to output
                        ; when the data byte is $0x or $1x

 BCS upac5              ; If the data byte in A was >= $10, then we know that A
                        ; is of the form $1x, so jump to upac5 to output the
                        ; number of $FF bytes specified in X

                        ; If we get here then we know that A is of the form
                        ; $0x, so we need to output the number of zero bytes
                        ; specified in X

 LDA #0                 ; Set A as the byte to write to SC(1 0), so we output
                        ; zeroes

.upac3

                        ; This loop writes byte A to SC(1 0), X times

 STA (SC),Y             ; Write the byte in A to SC(1 0)

 INY                    ; Increment Y to point to the next data byte

 BNE upac4              ; If Y has now wrapped round to zero, loop back to upac1
                        ; to unpack the next data byte

 INC SC+1               ; Otherwise Y is now zero, so increment the high byte of
                        ; SC(1 0) to point to the next page, so that SC(1 0) + Y
                        ; still points to the next data byte

.upac4

 DEX                    ; Decrement the byte counter in X

 BNE upac3              ; Loop back to upac3 to write the byte in A again, until
                        ; we have written it X times

 JMP upac1              ; Jump back to upac1 to unpack the next byte

.upac5

                        ; If we get here then we know that A is of the form
                        ; $1x, so we need to output the number of $FF bytes
                        ; specified in X

 LDA #$FF               ; Set A as the byte to write to SC(1 0), so we output
                        ; $FF

 BNE upac3              ; Jump to the loop at upac3 to output $FF to SC(1 0),
                        ; X times (this BNE is effectively a JMP as A is never
                        ; zero)

.upac6

                        ; If we get here then we know that the data byte in A is
                        ; of the form $2x or $3x (and not $x0)

 LDX #0                 ; Set X = 0, so we can use a LDA (V,X) instruction below
                        ; to fetch the next data byte from V(1 0), as the 6502
                        ; doesn't have a LDA (V) instruction

 CMP #$30               ; If A >= $30 then jump to upac7 to process bytes in the
 BCS upac7              ; for $3x

                        ; If we get here then we know that the data byte in A is
                        ; of the form $2x (and not $x0)

 AND #$0F               ; Set T to the lower nibble of A, so it contains the
 STA T                  ; number of times that we need to output the byte
                        ; following the $2x data byte

 LDA (V,X)              ; Set A to the byte of packed data at V(1 0), which is
                        ; the next byte of data to unpack, i.e. the byte that we
                        ; need to write X times
                        ;
                        ; As X = 0, this instruction is effectively LDA (V),
                        ; which isn't a valid 6502 instruction on its own

 LDX T                  ; Set X to the number of times we need to output the
                        ; byte in A

 INC V                  ; Increment V(1 0) to point to the next data byte (as we
 BNE upac3              ; just read the one after the $2x data byte), and jump
 INC V+1                ; to the loop in upac3 to output the byte in A, X times
 JMP upac3

.upac7

                        ; If we get here then we know that the data byte in A is
                        ; of the form $3x (and not $x0), and we jump here with
                        ; X set to 0

 AND #$0F               ; Set T to the lower nibble of A, so it contains the
 STA T                  ; number of unchanged bytes that we need to output
                        ; following the $3x data byte

.upac8

 LDA (V,X)              ; Set A to the byte of packed data at V(1 0), which is
                        ; the next byte of data to unpack
                        ;
                        ; As X = 0, this instruction is effectively LDA (V),
                        ; which isn't a valid 6502 instruction on its own

 INC V                  ; Increment V(1 0) to point to the next data byte (as we
 BNE upac9              ; just read the one after the $2x data byte)
 INC V+1

                        ; We now loop T times, outputting the next data byte on
                        ; each iteration, so we end up writing the next T bytes
                        ; unchanged

.upac9

 STA (SC),Y             ; Write the unpacked data in A to the Y-th byte of
                        ; SC(1 0)

 INY                    ; Increment Y to point to the next data byte

 BNE upac10             ; If Y has now wrapped round to zero, increment the
 INC SC+1               ; high byte of SC(1 0) to point to the next page, so
                        ; that SC(1 0) + Y still points to the next data byte

.upac10

 DEC T                  ; Decrement the loop counter in T

 BNE upac8              ; Loop back until we have copied the next T bytes
                        ; unchanged from V(1 0) to SC(1 0)

 JMP upac1              ; Jump back to upac1 to unpack the next byte

.upac11

 TXA                    ; Set A back to the unpacked data byte, which we stored
                        ; in X before jumping here

.upac12

 STA (SC),Y             ; Write the unpacked data in A to the Y-th byte of
                        ; SC(1 0)

 INY                    ; Increment Y to point to the next data byte

 BNE upac1              ; If Y has now wrapped round to zero, loop back to upac1
                        ; to unpack the next data byte

 INC SC+1               ; Otherwise Y is now zero, so increment the high byte of
 JMP upac1              ; SC(1 0) to point to the next page, so that SC(1 0) + Y
                        ; still points to the next data byte

.upac13

 RTS                    ; Return from the subroutine

; ******************************************************************************
;
;       Name: UnpackToPPU
;       Type: Subroutine
;   Category: Utility routines
;    Summary: Unpack compressed image data and send it to the PPU
;
; ------------------------------------------------------------------------------
;
; This routine unpacks compressed data and sends it straight to the PPU. The
; data is typically nametable or pattern data that is unpacked into the PPU's
; nametable or pattern tables.
;
; The algorithm is described in the UnpackToRAM routine.
;
; ******************************************************************************

.UnpackToPPU

 LDY #0                 ; We work our way through the packed data at SC(1 0), so
                        ; set an index counter in Y, starting from the first
                        ; data byte at offset zero

.upak1

 LDA (V),Y              ; Set A to the Y-th byte of packed data at V(1 0), which
                        ; is the next byte of data to unpack

 INY                    ; Increment Y to point to the next byte of packed data

 BNE upak2              ; If Y has now wrapped round to zero, increment the
 INC V+1                ; high byte of V(1 0) to point to the next page, so
                        ; that V(1 0) + Y still points to the next data byte

.upak2

 CMP #$40               ; If A >= $40, jump to upak10 to send the data in A
 BCS upak10             ; as it is, and move on to the next byte

 TAX                    ; Store the packed data byte in X so we can retrieve it
                        ; below

 AND #$0F               ; If the data byte in A is in the format $x0, jump to
 BEQ upak9              ; upak9 to send the data in X as it is, and move on
                        ; to the next byte

 CPX #$3F               ; If the data byte in X is $3F, then this indicates we
 BEQ upak11             ; have reached the end of the packed data, so jump to
                        ; upak11 to return from the subroutine, as we are done

 TXA                    ; Set A back to the unpacked data byte, which we stored
                        ; in X above

 CMP #$20               ; If A >= $20, jump to upak5 to process values of $2x
 BCS upak5              ; and $3x (as we already processed values above $40)

                        ; If we get here then we know that the data byte in A is
                        ; of the form $0x or $1x (and not $x0)

 CMP #$10               ; If A >= $10, set the C flag

 AND #$0F               ; Set X to the lower nibble of A, so it contains the
 TAX                    ; number of zeroes or $FF bytes that we need to send
                        ; when the data byte is $0x or $1x

 BCS upak4              ; If the data byte in A was >= $10, then we know that A
                        ; is of the form $1x, so jump to upak4 to send the
                        ; number of $FF bytes specified in X

                        ; If we get here then we know that A is of the form
                        ; $0x, so we need to send the number of zero bytes
                        ; specified in X

 LDA #0                 ; Set A as the byte to write to the PPU, so we send
                        ; zeroes

.upak3

                        ; This loop sends byte A to the PPU, X times

 STA PPU_DATA           ; Send the byte in A to the PPU

 DEX                    ; Decrement the byte counter in X

 BNE upak3              ; Loop back to upak3 to send the byte in A again, until
                        ; we have sent it X times

 JMP upak1              ; Jump back to upak1 to unpack the next byte

.upak4

                        ; If we get here then we know that A is of the form
                        ; $1x, so we need to send the number of $FF bytes
                        ; specified in X

 LDA #$FF               ; Set A as the byte to send to the PPU

 BNE upak3              ; Jump to the loop at upak3 to send $FF to the PPU,
                        ; X times (this BNE is effectively a JMP as A is never
                        ; zero)

.upak5

                        ; If we get here then we know that the data byte in A is
                        ; of the form $2x or $3x (and not $x0)

 CMP #$30               ; If A >= $30 then jump to upak6 to process bytes in the
 BCS upak6              ; for $3x

 AND #$0F               ; Set X to the lower nibble of A, so it contains the
 TAX                    ; number of times that we need to send the byte
                        ; following the $2x data byte

 LDA (V),Y              ; Set A to the Y-th byte of packed data at V(1 0), which
                        ; is the next byte of data to unpack, i.e. the byte that
                        ; we need to write X times

 INY                    ; Increment Y to point to the next byte of packed data

 BNE upak3              ; If Y has now wrapped round to zero, increment the
 INC V+1                ; high byte of V(1 0) to point to the next page, so
 JMP upak3              ; that V(1 0) + Y still points to the next data byte,
                        ; and jump to the loop in upak3 to send the byte in A,
                        ; X times

.upak6

                        ; If we get here then we know that the data byte in A is
                        ; of the form $3x (and not $x0), and we jump here with
                        ; X set to 0

 AND #$0F               ; Set X to the lower nibble of A, so it contains the
 TAX                    ; number of unchanged bytes that we need to send
                        ; following the $3x data byte

.upak7

 LDA (V),Y              ; Set A to the Y-th byte of packed data at V(1 0), which
                        ; is the next byte of data to unpack

 INY                    ; Increment Y to point to the next byte of packed data

 BNE upak8              ; If Y has now wrapped round to zero, increment the
 INC V+1                ; high byte of V(1 0) to point to the next page, so
                        ; that V(1 0) + Y still points to the next data byte

.upak8

 STA PPU_DATA           ; Send the unpacked data in A to the PPU

 DEX                    ; Decrement the byte counter in X

 BNE upak7              ; Loop back to upak7 to send the next byte, until we
                        ; have sent the next X bytes

 JMP upak1              ; Jump back to upak1 to unpack the next byte

.upak9

 TXA                    ; Set A back to the unpacked data byte, which we stored
                        ; in X before jumping here

.upak10

 STA PPU_DATA           ; Send the byte in A to the PPU

 JMP upak1              ; Jump back to upak1 to unpack the next byte

.upak11

 RTS                    ; Return from the subroutine

; ******************************************************************************
;
;       Name: CalculateDistance
;       Type: Subroutine
;   Category: Maths (Geometry)
;    Summary: Compare x_hi, y_hi and z_hi with A
;
; ------------------------------------------------------------------------------
;
; Calculate the distance from the origin to the point (x, y, z) and compare it
; with the argument A, clearing the C flag if the distance is < A, or setting
; the C flag if the distance is >= A.
;
; Returns:
;
;   C flag              Clear if the distance to (x, y, z) < A
;
;                       Set if the distance to (x, y, z) >= A
;
; ******************************************************************************

.CalculateDistance

 STA T                  ; Store the value that we want to compare x, y z with
                        ; in T

 SETUP_PPU_FOR_ICON_BAR ; If the PPU has started drawing the icon bar, configure
                        ; the PPU to use nametable 0 and pattern table 0

 LDA INWK+2             ; If any of x_sign, y_sign or z_sign are non-zero
 ORA INWK+5             ; (ignoring the sign in bit 7), then jump to farr3 to
 ORA INWK+8             ; return the C flag set, to indicate that A is smaller
 ASL A                  ; than x, y, z
 BNE farr3

 LDA INWK+7             ; Set K+2 = z_hi / 2
 LSR A
 STA K+2

 LDA INWK+1             ; Set K = x_hi / 2
 LSR A
 STA K

 LDA INWK+4             ; Set K+1 = y_hi / 2
 LSR A                  ;
 STA K+1                ; This also sets A = K+1

                        ; From this point on we are only working with the high
                        ; bytes, so to make things easier to follow, let's just
                        ; refer to x_hi, y_hi and z_hi as x, y and z, so:
                        ;
                        ;   K   = x / 2
                        ;   K+1 = y / 2
                        ;   K+2 = z / 2

 CMP K                  ; If A >= K, jump to farr1 to skip the next instruction
 BCS farr1

 LDA K                  ; Set A = K, so A = max(K, K+1)

.farr1

 CMP K+2                ; If A >= K+2, jump to farr2 to skip the next
 BCS farr2              ; instruction

 LDA K+2                ; Set A = K+2, so A = max(A, K+2)
                        ;                   = max(K, K+1, K+2)

.farr2

 STA SC                 ; Set SC = A
                        ;        = max(K, K+1, K+2)
                        ;        = max(x / 2, y / 2, z / 2)
                        ;        = max(x, y, z) / 2

 LDA K                  ; Set SC+1 = (K + K+1 + K+2 - SC) / 4
 CLC                    ;          = (x/2 + y/2 + z/2 - max(x, y, z) / 2) / 4
 ADC K+1                ;          = (x + y + z - max(x, y, z)) / 8
 ADC K+2                ;
 SEC                    ; 
 SBC SC
 LSR A
 LSR A
 STA SC+1

 LSR A                  ; Set A = (SC+1 / 4) + SC+1 + SC
 LSR A                  ;       = 5/4 * SC+1 + SC
 ADC SC+1               ;       = 5 * (x + y + z - max(x, y, z)) / (8 * 4)
 ADC SC                 ;          + max(x, y, z) / 2
                        ;
                        ; If h is the longest of x, y, z, and a and b are the
                        ; other two sides, then we have:
                        ;
                        ;   max(x, y, z) = h
                        ;
                        ;   x + y + z - max(x, y, z) = a + b + h - h
                        ;                            = a + b
                        ;
                        ; So:
                        ;
                        ;   A = 5 * (a + b) / (8 * 4) + h / 2
                        ;     = 5/32 * a + 5/32 * b + 1/2 * h
                        ;
                        ; Presumably this estimates the length of the (x, y, z),
                        ; i.e. |x y z|, in some way, though I don't understand
                        ; how

 CMP T                  ; If A < T, C will be clear, otherwise C will be set
                        ;
                        ; So the C flag is clear if |x y z| <  argument A
                        ;                  set   if |x y z| >= argument A

 RTS                    ; Return from the subroutine

.farr3

 SEC                    ; Set the C flag to indicate A < x and A < y and A < z

 RTS                    ; Return from the subroutine

; ******************************************************************************
;
;       Name: MU5
;       Type: Subroutine
;   Category: Maths (Arithmetic)
;    Summary: Set K(3 2 1 0) = (A A A A) and clear the C flag
;
; ------------------------------------------------------------------------------
;
; In practice this is only called via a BEQ following an AND instruction, in
; which case A = 0, so this routine effectively does this:
;
;   K(3 2 1 0) = 0
;
; ******************************************************************************

.MU5

 STA K                  ; Set K(3 2 1 0) to (A A A A)
 STA K+1
 STA K+2
 STA K+3

 CLC                    ; Clear the C flag

 RTS                    ; Return from the subroutine

; ******************************************************************************
;
;       Name: MULT3
;       Type: Subroutine
;   Category: Maths (Arithmetic)
;    Summary: Calculate K(3 2 1 0) = (A P+1 P) * Q
;  Deep dive: Shift-and-add multiplication
;
; ------------------------------------------------------------------------------
;
; Calculate the following multiplication between a signed 24-bit number and a
; signed 8-bit number, returning the result as a signed 32-bit number:
;
;   K(3 2 1 0) = (A P+1 P) * Q
;
; The algorithm is the same shift-and-add algorithm as in routine MULT1, but
; extended to cope with more bits.
;
; Returns:
;
;   C flag              The C flag is cleared
;
; ******************************************************************************

.MULT3

 STA R                  ; Store the high byte of (A P+1 P) in R

 AND #%01111111         ; Set K+2 to |A|, the high byte of K(2 1 0)
 STA K+2

 LDA Q                  ; Set A to bits 0-6 of Q, so A = |Q|
 AND #%01111111

 BEQ MU5                ; If |Q| = 0, jump to MU5 to set K(3 2 1 0) to 0,
                        ; returning from the subroutine using a tail call

 SEC                    ; Set T = |Q| - 1
 SBC #1
 STA T

                        ; We now use the same shift-and-add algorithm as MULT1
                        ; to calculate the following:
                        ;
                        ; K(2 1 0) = K(2 1 0) * |Q|
                        ;
                        ; so we start with the first shift right, in which we
                        ; take (K+2 P+1 P) and shift it right, storing the
                        ; result in K(2 1 0), ready for the multiplication loop
                        ; (so the multiplication loop actually calculates
                        ; (|A| P+1 P) * |Q|, as the following sets K(2 1 0) to
                        ; (|A| P+1 P) shifted right)

 LDA P+1                ; Set A = P+1

 LSR K+2                ; Shift the high byte in K+2 to the right

 ROR A                  ; Shift the middle byte in A to the right and store in
 STA K+1                ; K+1 (so K+1 contains P+1 shifted right)

 LDA P                  ; Shift the middle byte in P to the right and store in
 ROR A                  ; K, so K(2 1 0) now contains (|A| P+1 P) shifted right
 STA K

 SETUP_PPU_FOR_ICON_BAR ; If the PPU has started drawing the icon bar, configure
                        ; the PPU to use nametable 0 and pattern table 0

                        ; We now use the same shift-and-add algorithm as MULT1
                        ; to calculate the following:
                        ;
                        ; K(2 1 0) = K(2 1 0) * |Q|

 LDA #0                 ; Set A = 0 so we can start building the answer in A

 LDX #24                ; Set up a counter in X to count the 24 bits in K(2 1 0)

.MUL2

 BCC P%+4               ; If C (i.e. the next bit from K) is set, do the
 ADC T                  ; addition for this bit of K:
                        ;
                        ;   A = A + T + C
                        ;     = A + |Q| - 1 + 1
                        ;     = A + |Q|

 ROR A                  ; Shift A right by one place to catch the next digit
 ROR K+2                ; next digit of our result in the left end of K(2 1 0),
 ROR K+1                ; while also shifting K(2 1 0) right to fetch the next
 ROR K                  ; bit for the calculation into the C flag
                        ;
                        ; On the last iteration of this loop, the bit falling
                        ; off the end of K will be bit 0 of the original A, as
                        ; we did one shift before the loop and we are doing 24
                        ; iterations. We set A to 0 before looping, so this
                        ; means the loop exits with the C flag clear

 DEX                    ; Decrement the loop counter

 BNE MUL2               ; Loop back for the next bit until K(2 1 0) has been
                        ; rotated all the way

                        ; The result (|A| P+1 P) * |Q| is now in (A K+2 K+1 K),
                        ; but it is positive and doesn't have the correct sign
                        ; of the final result yet

 STA T                  ; Save the high byte of the result into T

 SETUP_PPU_FOR_ICON_BAR ; If the PPU has started drawing the icon bar, configure
                        ; the PPU to use nametable 0 and pattern table 0

 LDA R                  ; Fetch the sign byte from the original (A P+1 P)
                        ; argument that we stored in R

 EOR Q                  ; EOR with Q so the sign bit is the same as that of
                        ; (A P+1 P) * Q

 AND #%10000000         ; Extract the sign bit

 ORA T                  ; Apply this to the high byte of the result in T, so
                        ; that A now has the correct sign for the result, and
                        ; (A K+2 K+1 K) therefore contains the correctly signed
                        ; result

 STA K+3                ; Store A in K+3, so K(3 2 1 0) now contains the result

 RTS                    ; Return from the subroutine

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
                        ; OR'ing the result with the sign bit from argument A
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
                        ; right way round (i.e. that we subtracted the smaller
                        ; absolute value from the larger absolute value)

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
 SBC U                  ; subtraction with the C flag clear

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
;       Name: cntr
;       Type: Subroutine
;   Category: Dashboard
;    Summary: Apply damping to the pitch or roll dashboard indicator
;
; ******************************************************************************

.CFA13

 LDX #$80

.loop_CFA15

 RTS

.cntr

 STA T
 LDA auto
 BNE CFA22
 LDA DAMP
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
;   Category: Utility routines
;    Summary: Configure the MMC1 mapper and page ROM bank 0 into memory at $8000
;
; ******************************************************************************

.SetupMMC1

 LDA #%00001110         ; Set the MMC1 Control register (which is mapped to
 STA $9FFF              ; $8000-$9FFF) as follows:
 LSR A                  ;
 STA $9FFF              ;   * Bit 0 clear, Bit 1 set = Vertical mirroring (which
 LSR A                  ;     overrides the horizontal mirroring set in the iNES
 STA $9FFF              ;     header)
 LSR A                  ;
 STA $9FFF              ;   * Bits 2,3 set = PRG ROM bank mode 3 = fix ROM bank
 LSR A                  ;     7 at $C000 and switch 16K ROM banks at $8000
 STA $9FFF              ;
                        ;   * Bit 4 clear = CHR ROM bank mode 0 = switch 8K at
                        ;     a time

 LDA #0                 ; Set the MMC1 CHR bank 0 register (which is mapped to
 STA $BFFF              ; $A000-$BFFF) to map CHR-ROM to $0000, though this has
 LSR A                  ; no effect as we have no CHR-ROM (we have CHR-RAM
 STA $BFFF              ; instead, which is always mapped to $6000-$7FFF)
 LSR A
 STA $BFFF
 LSR A
 STA $BFFF
 LSR A
 STA $BFFF

 LDA #0                 ; Set the MMC1 CHR bank 1 register (which is mapped to
 STA $DFFF              ; $C000-$DFFF) to map CHR-ROM to $1000, though this has
 LSR A                  ; no effect as we have no CHR-ROM (we have CHR-RAM
 STA $DFFF              ; instead, which is always mapped to $6000-$7FFF)
 LSR A
 STA $DFFF
 LSR A
 STA $DFFF
 LSR A
 STA $DFFF

 JMP SetBank0           ; Page ROM bank 0 into memory at $8000, returning from
                        ; the subroutine using a tail call

IF _NTSC

 EQUB $F5, $F5, $F5     ; These bytes appear to be unused
 EQUB $F5, $F6, $F6
 EQUB $F6, $F6, $F7
 EQUB $F7, $F7, $F7
 EQUB $F7, $F8, $F8
 EQUB $F8, $F8, $F9
 EQUB $F9, $F9, $F9
 EQUB $F9, $FA, $FA
 EQUB $FA, $FA, $FA
 EQUB $FB, $FB, $FB
 EQUB $FB, $FB, $FC
 EQUB $FC, $FC, $FC
 EQUB $FC, $FD, $FD
 EQUB $FD, $FD, $FD
 EQUB $FD, $FE, $FE
 EQUB $FE, $FE, $FE
 EQUB $FF, $FF, $FF
 EQUB $FF, $FF

ELIF _PAL

 EQUB $FF, $FF, $FF     ; These bytes appear to be unused
 EQUB $FF, $FF, $FF
 EQUB $FF, $FF, $FF
 EQUB $FF, $FF, $FF
 EQUB $FF, $FF, $FF
 EQUB $FF, $FF, $FF
 EQUB $FF, $FF, $FF
 EQUB $FF

ENDIF

; ******************************************************************************
;
;       Name: lineImage
;       Type: Variable
;   Category: Drawing lines
;    Summary: Image data for the horizontal line, vertical line and block images
;
; ******************************************************************************

.lineImage

 EQUB $FF, $00, $00, $00, $00, $00, $00, $00
 EQUB $00, $FF, $00, $00, $00, $00, $00, $00
 EQUB $00, $00, $FF, $00, $00, $00, $00, $00
 EQUB $00, $00, $00, $FF, $00, $00, $00, $00
 EQUB $00, $00, $00, $00, $FF, $00, $00, $00
 EQUB $00, $00, $00, $00, $00, $FF, $00, $00
 EQUB $00, $00, $00, $00, $00, $00, $FF, $00
 EQUB $00, $00, $00, $00, $00, $00, $00, $FF
 EQUB $00, $00, $00, $00, $00, $00, $FF, $FF
 EQUB $00, $00, $00, $00, $00, $FF, $FF, $FF
 EQUB $00, $00, $00, $00, $FF, $FF, $FF, $FF
 EQUB $00, $00, $00, $FF, $FF, $FF, $FF, $FF
 EQUB $00, $00, $FF, $FF, $FF, $FF, $FF, $FF
 EQUB $00, $FF, $FF, $FF, $FF, $FF, $FF, $FF
 EQUB $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
 EQUB $80, $80, $80, $80, $80, $80, $80, $80
 EQUB $40, $40, $40, $40, $40, $40, $40, $40
 EQUB $20, $20, $20, $20, $20, $20, $20, $20
 EQUB $10, $10, $10, $10, $10, $10, $10, $10
 EQUB $08, $08, $08, $08, $08, $08, $08, $08
 EQUB $04, $04, $04, $04, $04, $04, $04, $04
 EQUB $02, $02, $02, $02, $02, $02, $02, $02
 EQUB $01, $01, $01, $01, $01, $01, $01, $01
 EQUB $00, $00, $00, $00, $00, $FF, $FF, $FF
 EQUB $FF, $FF, $FF, $00, $00, $00, $00, $00
 EQUB $00, $00, $00, $00, $00, $C0, $C0, $C0
 EQUB $C0, $C0, $C0, $00, $00, $00, $00, $00
 EQUB $00, $00, $00, $00, $00, $03, $03, $03
 EQUB $03, $03, $03, $00, $00, $00, $00, $00

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

 EQUB $00, $8D, $06     ; These bytes appear to be unused
 EQUB $20, $A9, $4C
 EQUB $00, $C0, $45
 EQUB $4C, $20, $20
 EQUB $20, $20, $20
 EQUB $20, $20, $20
 EQUB $20, $20, $20
 EQUB $20, $20, $20
 EQUB $00, $00, $00
 EQUB $00, $38, $04
 EQUB $01, $07, $9C
 EQUB $2A

ELIF _PAL

 EQUB $FF, $FF, $FF     ; These bytes appear to be unused
 EQUB $FF, $FF, $4C
 EQUB $00, $C0, $45
 EQUB $4C, $20, $20
 EQUB $20, $20, $20
 EQUB $20, $20, $20
 EQUB $20, $20, $20
 EQUB $20, $20, $20
 EQUB $00, $00, $00
 EQUB $00, $38, $04
 EQUB $01, $07, $9C
 EQUB $2A

ENDIF

; ******************************************************************************
;
;       Name: Vectors
;       Type: Variable
;   Category: Utility routines
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
