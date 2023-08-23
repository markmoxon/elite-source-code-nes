; ******************************************************************************
;
; NES ELITE GAME SOURCE (BANK 2)
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
;   * bank2.bin
;
; ******************************************************************************

 INCLUDE "1-source-files/main-sources/elite-build-options.asm"

 _BANK = 2

 INCLUDE "1-source-files/main-sources/elite-source-common.asm"

 INCLUDE "1-source-files/main-sources/elite-source-bank-7.asm"

; ******************************************************************************
;
; ELITE BANK 2
;
; Produces the binary file bank2.bin.
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
;       Name: TKN1
;       Type: Variable
;   Category: Text
;    Summary: The first extended token table for recursive tokens 0-255 (DETOK)
;  Deep dive: Extended text tokens
;
; ******************************************************************************

.TKN1

 EQUB VE                ; Token 0:      ""

 EJMP 19                ; Token 1:      ""
 ECHR 'Y'
 ETWO 'E', 'S'
 EQUB VE

 EJMP 19                ; Token 2:      ""
 ETWO 'N', 'O'
 EQUB VE

 EJMP 2                 ; Token 3:      ""
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

 EJMP 19                ; Token 4:      ""
 ETWO 'E', 'N'
 ECHR 'G'
 ECHR 'L'
 ECHR 'I'
 ECHR 'S'
 ECHR 'H'
 EQUB VE

 ETOK 176               ; Token 5:      ""
 ERND 18
 ETOK 202
 ERND 19
 ETOK 177
 EQUB VE

 EJMP 19                ; Token 6:      ""
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

 EJMP 19                ; Token 7:      ""
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

 EJMP 19                ; Token 8:      ""
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

 EJMP 19                ; Token 9:      ""
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

 EJMP 23                ; Token 10:     ""
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

 EJMP 25                ; Token 11:     ""
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

 ECHR '('               ; Token 12:     ""
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

 ECHR 'B'               ; Token 13:     ""
 ECHR 'Y'
 ETOK 197
 EQUB VE

 EJMP 21                ; Token 14:     ""
 ETOK 145
 ETOK 200
 EQUB VE

 EJMP 25                ; Token 15:     ""
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

 ECHR 'F'               ; Token 16:     ""
 ETWO 'A', 'B'
 ETWO 'L', 'E'
 ECHR 'D'
 EQUB VE

 ETWO 'N', 'O'          ; Token 17:     ""
 ECHR 'T'
 ETWO 'A', 'B'
 ETWO 'L', 'E'
 EQUB VE

 ECHR 'W'               ; Token 18:     ""
 ECHR 'E'
 ECHR 'L'
 ECHR 'L'
 ECHR ' '
 ECHR 'K'
 ETWO 'N', 'O'
 ECHR 'W'
 ECHR 'N'
 EQUB VE

 ECHR 'F'               ; Token 19:     ""
 ECHR 'A'
 ECHR 'M'
 ETWO 'O', 'U'
 ECHR 'S'
 EQUB VE

 ETWO 'N', 'O'          ; Token 20:     ""
 ECHR 'T'
 ETWO 'E', 'D'
 EQUB VE

 ECHR 'V'               ; Token 21:     ""
 ETWO 'E', 'R'
 ECHR 'Y'
 EQUB VE

 ECHR 'M'               ; Token 22:     ""
 ETWO 'I', 'L'
 ECHR 'D'
 ECHR 'L'
 ECHR 'Y'
 EQUB VE

 ECHR 'M'               ; Token 23:     ""
 ECHR 'O'
 ETWO 'S', 'T'
 EQUB VE

 ETWO 'R', 'E'          ; Token 24:     ""
 ECHR 'A'
 ECHR 'S'
 ETWO 'O', 'N'
 ETWO 'A', 'B'
 ECHR 'L'
 ECHR 'Y'
 EQUB VE

 EQUB VE                ; Token 25:     ""

 ETOK 165               ; Token 26:     ""
 EQUB VE

 ERND 23                ; Token 27:     ""
 EQUB VE

 ECHR 'G'               ; Token 28:     ""
 ETWO 'R', 'E'
 ETWO 'A', 'T'
 EQUB VE

 ECHR 'V'               ; Token 29:     ""
 ECHR 'A'
 ETWO 'S', 'T'
 EQUB VE

 ECHR 'P'               ; Token 30:     ""
 ETWO 'I', 'N'
 ECHR 'K'
 EQUB VE

 EJMP 2                 ; Token 31:     ""
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

 ETOK 156               ; Token 32:     ""
 ECHR 'S'
 EQUB VE

 ERND 26                ; Token 33:     ""
 EQUB VE

 ERND 37                ; Token 34:     ""
 ECHR ' '
 ECHR 'F'
 ECHR 'O'
 ETWO 'R', 'E'
 ETWO 'S', 'T'
 ECHR 'S'
 EQUB VE

 ECHR 'O'               ; Token 35:     ""
 ETWO 'C', 'E'
 ETWO 'A', 'N'
 ECHR 'S'
 EQUB VE

 ECHR 'S'               ; Token 36:     ""
 ECHR 'H'
 ECHR 'Y'
 ECHR 'N'
 ETWO 'E', 'S'
 ECHR 'S'
 EQUB VE

 ECHR 'S'               ; Token 37:     ""
 ETWO 'I', 'L'
 ECHR 'L'
 ETWO 'I', 'N'
 ETWO 'E', 'S'
 ECHR 'S'
 EQUB VE

 ECHR 'T'               ; Token 38:     ""
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

 ETWO 'L', 'O'          ; Token 39:     ""
 ECHR 'A'
 ETWO 'T', 'H'
 ETOK 195
 ECHR 'O'
 ECHR 'F'
 ECHR ' '
 ERND 9
 EQUB VE

 ETWO 'L', 'O'          ; Token 40:     ""
 ETWO 'V', 'E'
 ECHR ' '
 ECHR 'F'
 ETWO 'O', 'R'
 ECHR ' '
 ERND 9
 EQUB VE

 ECHR 'F'               ; Token 41:     ""
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

 ECHR 'T'               ; Token 42:     ""
 ETWO 'O', 'U'
 ECHR 'R'
 ECHR 'I'
 ETWO 'S', 'T'
 ECHR 'S'
 EQUB VE

 ECHR 'P'               ; Token 43:     ""
 ECHR 'O'
 ETWO 'E', 'T'
 ECHR 'R'
 ECHR 'Y'
 EQUB VE

 ETWO 'D', 'I'          ; Token 44:     ""
 ECHR 'S'
 ECHR 'C'
 ECHR 'O'
 ECHR 'S'
 EQUB VE

 ERND 17                ; Token 45:     ""
 EQUB VE

 ECHR 'W'               ; Token 46:     ""
 ETWO 'A', 'L'
 ECHR 'K'
 ETOK 195
 ETOK 158
 EQUB VE

 ECHR 'C'               ; Token 47:     ""
 ECHR 'R'
 ETWO 'A', 'B'
 EQUB VE

 ECHR 'B'               ; Token 48:     ""
 ETWO 'A', 'T'
 EQUB VE

 ETWO 'L', 'O'          ; Token 49:     ""
 ECHR 'B'
 ETWO 'S', 'T'
 EQUB VE

 EJMP 18                ; Token 50:     ""
 EQUB VE

 ETWO 'B', 'E'          ; Token 51:     ""
 ETWO 'S', 'E'
 ECHR 'T'
 EQUB VE

 ECHR 'P'               ; Token 52:     ""
 ETWO 'L', 'A'
 ECHR 'G'
 ECHR 'U'
 ETWO 'E', 'D'
 EQUB VE

 ETWO 'R', 'A'          ; Token 53:     ""
 ECHR 'V'
 ECHR 'A'
 ETWO 'G', 'E'
 ECHR 'D'
 EQUB VE

 ECHR 'C'               ; Token 54:     ""
 ECHR 'U'
 ECHR 'R'
 ETWO 'S', 'E'
 ECHR 'D'
 EQUB VE

 ECHR 'S'               ; Token 55:     ""
 ECHR 'C'
 ETWO 'O', 'U'
 ECHR 'R'
 ETWO 'G', 'E'
 ECHR 'D'
 EQUB VE

 ERND 22                ; Token 56:     ""
 ECHR ' '
 ECHR 'C'
 ECHR 'I'
 ECHR 'V'
 ETWO 'I', 'L'
 ECHR ' '
 ECHR 'W'
 ETWO 'A', 'R'
 EQUB VE

 ERND 13                ; Token 57:     ""
 ECHR ' '
 ERND 4
 ECHR ' '
 ERND 5
 ECHR 'S'
 EQUB VE

 ECHR 'A'               ; Token 58:     ""
 ECHR ' '
 ERND 13
 ECHR ' '
 ETWO 'D', 'I'
 ETWO 'S', 'E'
 ECHR 'A'
 ETWO 'S', 'E'
 EQUB VE

 ERND 22                ; Token 59:     ""
 ECHR ' '
 ECHR 'E'
 ETWO 'A', 'R'
 ETWO 'T', 'H'
 ETWO 'Q', 'U'
 ECHR 'A'
 ECHR 'K'
 ETWO 'E', 'S'
 EQUB VE

 ERND 22                ; Token 60:     ""
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

 ETOK 175               ; Token 61:     ""
 ERND 2
 ECHR ' '
 ERND 3
 EQUB VE

 ETOK 147               ; Token 62:     ""
 EJMP 17
 ECHR ' '
 ERND 4
 ECHR ' '
 ERND 5
 EQUB VE

 ETOK 175               ; Token 63:     ""
 ETOK 193
 ECHR 'S'
 ECHR ' '
 ERND 7
 ECHR ' '
 ERND 8
 EQUB VE

 EJMP 2                 ; Token 64:     ""
 ERND 31
 EJMP 13
 EQUB VE

 ETOK 175               ; Token 65:     ""
 ERND 16
 ECHR ' '
 ERND 17
 EQUB VE

 ECHR 'J'               ; Token 66:     ""
 ECHR 'U'
 ECHR 'I'
 ETWO 'C', 'E'
 EQUB VE

 ECHR 'D'               ; Token 67:     ""
 ECHR 'R'
 ETWO 'I', 'N'
 ECHR 'K'
 EQUB VE

 ECHR 'W'               ; Token 68:     ""
 ETWO 'A', 'T'
 ETWO 'E', 'R'
 EQUB VE

 ECHR 'T'               ; Token 69:     ""
 ECHR 'E'
 ECHR 'A'
 EQUB VE

 EJMP 19                ; Token 70:     ""
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

 EJMP 18                ; Token 71:     ""
 EQUB VE

 EJMP 17                ; Token 72:     ""
 ECHR ' '
 ERND 5
 EQUB VE

 ETOK 191               ; Token 73:     ""
 EQUB VE

 ETOK 192               ; Token 74:     ""
 EQUB VE

 ERND 13                ; Token 75:     ""
 ECHR ' '
 EJMP 18
 EQUB VE

 ECHR 'F'               ; Token 76:     ""
 ETWO 'A', 'B'
 ECHR 'U'
 ECHR 'L'
 ETWO 'O', 'U'
 ECHR 'S'
 EQUB VE

 ECHR 'E'               ; Token 77:     ""
 ECHR 'X'
 ECHR 'O'
 ETWO 'T', 'I'
 ECHR 'C'
 EQUB VE

 ECHR 'H'               ; Token 78:     ""
 ECHR 'O'
 ECHR 'O'
 ECHR 'P'
 ECHR 'Y'
 EQUB VE

 ETOK 132               ; Token 79:     ""
 EQUB VE

 ECHR 'E'               ; Token 80:     ""
 ECHR 'X'
 ECHR 'C'
 ETWO 'I', 'T'
 ETWO 'I', 'N'
 ECHR 'G'
 EQUB VE

 ECHR 'C'               ; Token 81:     ""
 ECHR 'U'
 ECHR 'I'
 ECHR 'S'
 ETWO 'I', 'N'
 ECHR 'E'
 EQUB VE

 ECHR 'N'               ; Token 82:     ""
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

 ECHR 'C'               ; Token 83:     ""
 ECHR 'A'
 ECHR 'S'
 ECHR 'I'
 ETWO 'N', 'O'
 ECHR 'S'
 EQUB VE

 ECHR 'C'               ; Token 84:     ""
 ETWO 'I', 'N'
 ECHR 'E'
 ETWO 'M', 'A'
 ECHR 'S'
 EQUB VE

 EJMP 2                 ; Token 85:     ""
 ERND 31
 EJMP 13
 EQUB VE

 EJMP 3                 ; Token 86:     ""
 EQUB VE

 ETOK 147               ; Token 87:     ""
 ETOK 145
 ECHR ' '
 EJMP 3
 EQUB VE

 ETOK 147               ; Token 88:     ""
 ETOK 146
 ECHR ' '
 EJMP 3
 EQUB VE

 ETOK 148               ; Token 89:     ""
 ETOK 145
 EQUB VE

 ETOK 148               ; Token 90:     ""
 ETOK 146
 EQUB VE

 ECHR 'S'               ; Token 91:     ""
 ECHR 'W'
 ETWO 'I', 'N'
 ECHR 'E'
 EQUB VE

 ECHR 'S'               ; Token 92:     ""
 ECHR 'C'
 ETWO 'O', 'U'
 ECHR 'N'
 ECHR 'D'
 ETWO 'R', 'E'
 ECHR 'L'
 EQUB VE

 ECHR 'B'               ; Token 93:     ""
 ETWO 'L', 'A'
 ECHR 'C'
 ECHR 'K'
 ECHR 'G'
 ECHR 'U'
 ETWO 'A', 'R'
 ECHR 'D'
 EQUB VE

 ECHR 'R'               ; Token 94:     ""
 ECHR 'O'
 ECHR 'G'
 ECHR 'U'
 ECHR 'E'
 EQUB VE

 ECHR 'W'               ; Token 95:     ""
 ECHR 'R'
 ETWO 'E', 'T'
 ECHR 'C'
 ECHR 'H'
 EQUB VE

 ECHR 'N'               ; Token 96:     ""
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

 ECHR ' '               ; Token 97:     ""
 ECHR 'B'
 ETWO 'O', 'R'
 ETWO 'I', 'N'
 ECHR 'G'
 EQUB VE

 ECHR ' '               ; Token 98:     ""
 ECHR 'D'
 ECHR 'U'
 ECHR 'L'
 ECHR 'L'
 EQUB VE

 ECHR ' '               ; Token 99:     ""
 ECHR 'T'
 ECHR 'E'
 ETWO 'D', 'I'
 ETWO 'O', 'U'
 ECHR 'S'
 EQUB VE

 ECHR ' '               ; Token 100:    ""
 ETWO 'R', 'E'
 ECHR 'V'
 ECHR 'O'
 ECHR 'L'
 ECHR 'T'
 ETWO 'I', 'N'
 ECHR 'G'
 EQUB VE

 ETOK 145               ; Token 101:    ""
 EQUB VE

 ETOK 146               ; Token 102:    ""
 EQUB VE

 ECHR 'P'               ; Token 103:    ""
 ETWO 'L', 'A'
 ETWO 'C', 'E'
 EQUB VE

 ECHR 'L'               ; Token 104:    ""
 ETWO 'I', 'T'
 ECHR 'T'
 ETWO 'L', 'E'
 ECHR ' '
 ETOK 145
 EQUB VE

 ECHR 'D'               ; Token 105:    ""
 ECHR 'U'
 ECHR 'M'
 ECHR 'P'
 EQUB VE

 EJMP 19                ; Token 106:    ""
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

 EJMP 19                ; Token 107:    ""
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

 EJMP 19                ; Token 108:    ""
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

 ETWO 'S', 'O'          ; Token 109:    ""
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

 ECHR 'T'               ; Token 110:    ""
 ECHR 'R'
 ECHR 'Y'
 ETOK 209
 EQUB VE

 ECHR ' '               ; Token 111:    ""
 ECHR 'C'
 ECHR 'U'
 ECHR 'D'
 ECHR 'D'
 ECHR 'L'
 ECHR 'Y'
 EQUB VE

 ECHR ' '               ; Token 112:    ""
 ECHR 'C'
 ECHR 'U'
 ECHR 'T'
 ECHR 'E'
 EQUB VE

 ECHR ' '               ; Token 113:    ""
 ECHR 'F'
 ECHR 'U'
 ECHR 'R'
 ECHR 'R'
 ECHR 'Y'
 EQUB VE

 ECHR ' '               ; Token 114:    ""
 ECHR 'F'
 ECHR 'R'
 ECHR 'I'
 ETWO 'E', 'N'
 ECHR 'D'
 ECHR 'L'
 ECHR 'Y'
 EQUB VE

 ECHR 'W'               ; Token 115:    ""
 ECHR 'A'
 ECHR 'S'
 ECHR 'P'
 EQUB VE

 ECHR 'M'               ; Token 116:    ""
 ECHR 'O'
 ETWO 'T', 'H'
 EQUB VE

 ECHR 'G'               ; Token 117:    ""
 ECHR 'R'
 ECHR 'U'
 ECHR 'B'
 EQUB VE

 ETWO 'A', 'N'          ; Token 118:    ""
 ECHR 'T'
 EQUB VE

 EJMP 18                ; Token 119:    ""
 EQUB VE

 ECHR 'P'               ; Token 120:    ""
 ECHR 'O'
 ETWO 'E', 'T'
 EQUB VE

 ECHR 'H'               ; Token 121:    ""
 ECHR 'O'
 ECHR 'G'
 EQUB VE

 ECHR 'Y'               ; Token 122:    ""
 ECHR 'A'
 ECHR 'K'
 EQUB VE

 ECHR 'S'               ; Token 123:    ""
 ECHR 'N'
 ECHR 'A'
 ETWO 'I', 'L'
 EQUB VE

 ECHR 'S'               ; Token 124:    ""
 ECHR 'L'
 ECHR 'U'
 ECHR 'G'
 EQUB VE

 ECHR 'T'               ; Token 125:    ""
 ECHR 'R'
 ECHR 'O'
 ECHR 'P'
 ECHR 'I'
 ECHR 'C'
 ETWO 'A', 'L'
 EQUB VE

 ECHR 'D'               ; Token 126:    ""
 ETWO 'E', 'N'
 ETWO 'S', 'E'
 EQUB VE

 ETWO 'R', 'A'          ; Token 127:    ""
 ETWO 'I', 'N'
 EQUB VE

 ECHR 'I'               ; Token 128:    ""
 ECHR 'M'
 ECHR 'P'
 ETWO 'E', 'N'
 ETWO 'E', 'T'
 ECHR 'R'
 ETWO 'A', 'B'
 ETWO 'L', 'E'
 EQUB VE

 ECHR 'E'               ; Token 129:    ""
 ECHR 'X'
 ECHR 'U'
 ECHR 'B'
 ETWO 'E', 'R'
 ETWO 'A', 'N'
 ECHR 'T'
 EQUB VE

 ECHR 'F'               ; Token 130:    ""
 ECHR 'U'
 ECHR 'N'
 ECHR 'N'
 ECHR 'Y'
 EQUB VE

 ECHR 'W'               ; Token 131:    ""
 ECHR 'E'
 ECHR 'I'
 ECHR 'R'
 ECHR 'D'
 EQUB VE

 ECHR 'U'               ; Token 132:    ""
 ETWO 'N', 'U'
 ECHR 'S'
 ECHR 'U'
 ETWO 'A', 'L'
 EQUB VE

 ETWO 'S', 'T'          ; Token 133:    ""
 ETWO 'R', 'A'
 ECHR 'N'
 ETWO 'G', 'E'
 EQUB VE

 ECHR 'P'               ; Token 134:    ""
 ECHR 'E'
 ECHR 'C'
 ECHR 'U'
 ECHR 'L'
 ECHR 'I'
 ETWO 'A', 'R'
 EQUB VE

 ECHR 'F'               ; Token 135:    ""
 ETWO 'R', 'E'
 ETWO 'Q', 'U'
 ETWO 'E', 'N'
 ECHR 'T'
 EQUB VE

 ECHR 'O'               ; Token 136:    ""
 ECHR 'C'
 ECHR 'C'
 ECHR 'A'
 ECHR 'S'
 ECHR 'I'
 ETWO 'O', 'N'
 ETWO 'A', 'L'
 EQUB VE

 ECHR 'U'               ; Token 137:    ""
 ECHR 'N'
 ECHR 'P'
 ETWO 'R', 'E'
 ETWO 'D', 'I'
 ECHR 'C'
 ECHR 'T'
 ETWO 'A', 'B'
 ETWO 'L', 'E'
 EQUB VE

 ECHR 'D'               ; Token 138:    ""
 ETWO 'R', 'E'
 ECHR 'A'
 ECHR 'D'
 ECHR 'F'
 ECHR 'U'
 ECHR 'L'
 EQUB VE

 ETOK 171               ; Token 139:    ""
 EQUB VE

 ERND 1                 ; Token 140:    ""
 ECHR ' '
 ERND 0
 ECHR ' '
 ECHR 'F'
 ETWO 'O', 'R'
 ECHR ' '
 ERND 10
 EQUB VE

 ETOK 140               ; Token 141:    ""
 ETOK 178
 ERND 10
 EQUB VE

 ERND 11                ; Token 142:    ""
 ECHR ' '
 ECHR 'B'
 ECHR 'Y'
 ECHR ' '
 ERND 12
 EQUB VE

 ETOK 140               ; Token 143:    ""
 ECHR ' '
 ECHR 'B'
 ECHR 'U'
 ECHR 'T'
 ECHR ' '
 ETOK 142
 EQUB VE

 ECHR ' '               ; Token 144:    ""
 ECHR 'A'
 ERND 20
 ECHR ' '
 ERND 21
 EQUB VE

 ECHR 'P'               ; Token 145:    ""
 ETWO 'L', 'A'
 ECHR 'N'
 ETWO 'E', 'T'
 EQUB VE

 ECHR 'W'               ; Token 146:    ""
 ETWO 'O', 'R'
 ECHR 'L'
 ECHR 'D'
 EQUB VE

 ETWO 'T', 'H'          ; Token 147:    ""
 ECHR 'E'
 ECHR ' '
 EQUB VE

 ETWO 'T', 'H'          ; Token 148:    ""
 ECHR 'I'
 ECHR 'S'
 ECHR ' '
 EQUB VE

 EQUB VE                ; Token 149:    ""

 EJMP 9                 ; Token 150:    ""
 EJMP 11
 EJMP 1
 EJMP 8
 EQUB VE

 EQUB VE                ; Token 151:    ""

 EQUB VE                ; Token 152:    ""

 ECHR 'I'               ; Token 153:    ""
 ETWO 'A', 'N'
 EQUB VE

 EJMP 19                ; Token 154:    ""
 ECHR 'C'
 ECHR 'O'
 ECHR 'M'
 ETWO 'M', 'A'
 ECHR 'N'
 ECHR 'D'
 ETWO 'E', 'R'
 EQUB VE

 ERND 13                ; Token 155:    ""
 EQUB VE

 ECHR 'M'               ; Token 156:    ""
 ETWO 'O', 'U'
 ECHR 'N'
 ECHR 'T'
 ECHR 'A'
 ETWO 'I', 'N'
 EQUB VE

 ECHR 'E'               ; Token 157:    ""
 ETWO 'D', 'I'
 ECHR 'B'
 ETWO 'L', 'E'
 EQUB VE

 ECHR 'T'               ; Token 158:    ""
 ETWO 'R', 'E'
 ECHR 'E'
 EQUB VE

 ECHR 'S'               ; Token 159:    ""
 ECHR 'P'
 ECHR 'O'
 ECHR 'T'
 ECHR 'T'
 ETWO 'E', 'D'
 EQUB VE

 ERND 29                ; Token 160:    ""
 EQUB VE

 ERND 30                ; Token 161:    ""
 EQUB VE

 ERND 6                 ; Token 162:    ""
 ECHR 'O'
 ECHR 'I'
 ECHR 'D'
 EQUB VE

 ERND 36                ; Token 163:    ""
 EQUB VE

 ERND 35                ; Token 164:    ""
 EQUB VE

 ETWO 'A', 'N'          ; Token 165:    ""
 ECHR 'C'
 ECHR 'I'
 ETWO 'E', 'N'
 ECHR 'T'
 EQUB VE

 ECHR 'E'               ; Token 166:    ""
 ECHR 'X'
 ETWO 'C', 'E'
 ECHR 'P'
 ETWO 'T', 'I'
 ETWO 'O', 'N'
 ETWO 'A', 'L'
 EQUB VE

 ECHR 'E'               ; Token 167:    ""
 ECHR 'C'
 ETWO 'C', 'E'
 ECHR 'N'
 ECHR 'T'
 ECHR 'R'
 ECHR 'I'
 ECHR 'C'
 EQUB VE

 ETWO 'I', 'N'          ; Token 168:    ""
 ECHR 'G'
 ETWO 'R', 'A'
 ETWO 'I', 'N'
 ETWO 'E', 'D'
 EQUB VE

 ERND 23                ; Token 169:    ""
 EQUB VE

 ECHR 'K'               ; Token 170:    ""
 ETWO 'I', 'L'
 ETWO 'L', 'E'
 ECHR 'R'
 EQUB VE

 ECHR 'D'               ; Token 171:    ""
 ECHR 'E'
 ECHR 'A'
 ECHR 'D'
 ECHR 'L'
 ECHR 'Y'
 EQUB VE

 ECHR 'W'               ; Token 172:    ""
 ECHR 'I'
 ECHR 'C'
 ECHR 'K'
 ETWO 'E', 'D'
 EQUB VE

 ECHR 'L'               ; Token 173:    ""
 ETWO 'E', 'T'
 ECHR 'H'
 ETWO 'A', 'L'
 EQUB VE

 ECHR 'V'               ; Token 174:    ""
 ECHR 'I'
 ECHR 'C'
 ECHR 'I'
 ETWO 'O', 'U'
 ECHR 'S'
 EQUB VE

 ETWO 'I', 'T'          ; Token 175:    ""
 ECHR 'S'
 ECHR ' '
 EQUB VE

 EJMP 13                ; Token 176:    ""
 EJMP 14
 EJMP 19
 EQUB VE

 ECHR '.'               ; Token 177:    ""
 EJMP 12
 EJMP 15
 EQUB VE

 ECHR ' '               ; Token 178:    ""
 ETWO 'A', 'N'
 ECHR 'D'
 ECHR ' '
 EQUB VE

 ECHR 'Y'               ; Token 179:    ""
 ETWO 'O', 'U'
 EQUB VE

 ECHR 'P'               ; Token 180:    ""
 ETWO 'A', 'R'
 ECHR 'K'
 ETOK 195
 ECHR 'M'
 ETWO 'E', 'T'
 ETWO 'E', 'R'
 ECHR 'S'
 EQUB VE

 ECHR 'D'               ; Token 181:    ""
 ECHR 'U'
 ETWO 'S', 'T'
 ECHR ' '
 ECHR 'C'
 ECHR 'L'
 ETWO 'O', 'U'
 ECHR 'D'
 ECHR 'S'
 EQUB VE

 ECHR 'I'               ; Token 182:    ""
 ETWO 'C', 'E'
 ECHR ' '
 ECHR 'B'
 ETWO 'E', 'R'
 ECHR 'G'
 ECHR 'S'
 EQUB VE

 ECHR 'R'               ; Token 183:    ""
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

 ECHR 'V'               ; Token 184:    ""
 ECHR 'O'
 ECHR 'L'
 ECHR 'C'
 ECHR 'A'
 ETWO 'N', 'O'
 ETWO 'E', 'S'
 EQUB VE

 ECHR 'P'               ; Token 185:    ""
 ETWO 'L', 'A'
 ECHR 'N'
 ECHR 'T'
 EQUB VE

 ECHR 'T'               ; Token 186:    ""
 ECHR 'U'
 ECHR 'L'
 ECHR 'I'
 ECHR 'P'
 EQUB VE

 ECHR 'B'               ; Token 187:    ""
 ETWO 'A', 'N'
 ETWO 'A', 'N'
 ECHR 'A'
 EQUB VE

 ECHR 'C'               ; Token 188:    ""
 ETWO 'O', 'R'
 ECHR 'N'
 EQUB VE

 EJMP 18                ; Token 189:    ""
 ECHR 'W'
 ECHR 'E'
 ETWO 'E', 'D'
 EQUB VE

 EJMP 18                ; Token 190:    ""
 EQUB VE

 EJMP 17                ; Token 191:    ""
 ECHR ' '
 EJMP 18
 EQUB VE

 EJMP 17                ; Token 192:    ""
 ECHR ' '
 ERND 13
 EQUB VE

 ETWO 'I', 'N'          ; Token 193:    ""
 ECHR 'H'
 ETWO 'A', 'B'
 ETWO 'I', 'T'
 ETWO 'A', 'N'
 ECHR 'T'
 EQUB VE

 ETOK 191               ; Token 194:    ""
 EQUB VE

 ETWO 'I', 'N'          ; Token 195:    ""
 ECHR 'G'
 ECHR ' '
 EQUB VE

 ETWO 'E', 'D'          ; Token 196:    ""
 ECHR ' '
 EQUB VE

 EJMP 26                ; Token 197:    ""
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

 ECHR ' '               ; Token 198:    ""
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

 EJMP 25                ; Token 199:    ""
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

 EJMP 26                ; Token 200:    ""
 ECHR 'N'
 ECHR 'A'
 ECHR 'M'
 ECHR 'E'
 ECHR '?'
 ECHR ' '
 EQUB VE

 ECHR ' '               ; Token 201:    ""
 ECHR 'T'
 ECHR 'O'
 ECHR ' '
 EQUB VE

 ECHR ' '               ; Token 202:    ""
 ECHR 'I'
 ECHR 'S'
 ECHR ' '
 EQUB VE

 ECHR 'W'               ; Token 203:    ""
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

 ECHR '.'               ; Token 204:    ""
 EJMP 12
 EJMP 12
 ECHR ' '
 EJMP 19
 EQUB VE

 EJMP 19                ; Token 205:    ""
 ECHR 'D'
 ECHR 'O'
 ECHR 'C'
 ECHR 'K'
 ETWO 'E', 'D'
 EQUB VE

 EQUB VE                ; Token 206:    ""

 ECHR 'S'               ; Token 207:    ""
 ECHR 'H'
 ECHR 'I'
 ECHR 'P'
 EQUB VE

 ECHR ' '               ; Token 208:    ""
 ECHR 'A'
 ECHR ' '
 EQUB VE

 EJMP 26                ; Token 209:    ""
 ETWO 'E', 'R'
 ECHR 'R'
 ECHR 'I'
 ETWO 'U', 'S'
 EQUB VE

 ECHR ' '               ; Token 210:    ""
 ECHR 'N'
 ECHR 'E'
 ECHR 'W'
 ECHR ' '
 EQUB VE

 EJMP 26                ; Token 211:    ""
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

 ETOK 177               ; Token 212:    ""
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

 ECHR ' '               ; Token 213:    ""
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

 EQUB VE                ; Token 214:    ""

 EJMP 15                ; Token 215:    ""
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

 EJMP 9                 ; Token 216:    ""
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

 EJMP 19                ; Token 217:    ""
 ECHR 'C'
 ECHR 'U'
 ECHR 'R'
 ECHR 'R'
 ECHR 'U'
 ETWO 'T', 'H'
 ETWO 'E', 'R'
 ECHR 'S'
 EQUB VE

 EJMP 19                ; Token 218:    ""
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

 EJMP 19                ; Token 219:    ""
 ECHR 'F'
 ETWO 'O', 'R'
 ECHR 'T'
 ETWO 'E', 'S'
 ETWO 'Q', 'U'
 ECHR 'E'
 EQUB VE

 ETOK 203               ; Token 220:    ""
 EJMP 19
 ETWO 'R', 'E'
 ETWO 'E', 'S'
 ETWO 'D', 'I'
 ETWO 'C', 'E'
 EQUB VE

 ECHR 'I'               ; Token 221:    ""
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

 EJMP 25                ; Token 222:    ""
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

 EJMP 25                ; Token 223:    ""
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

 EQUB VE                ; Token 224:    ""

 ECHR 'S'               ; Token 225:    ""
 ECHR 'H'
 ETWO 'R', 'E'
 ECHR 'W'
 EQUB VE

 ETWO 'B', 'E'          ; Token 226:    ""
 ECHR 'A'
 ETWO 'S', 'T'
 EQUB VE

 ECHR 'G'               ; Token 227:    ""
 ETWO 'N', 'U'
 EQUB VE

 ECHR 'S'               ; Token 228:    ""
 ECHR 'N'
 ECHR 'A'
 ECHR 'K'
 ECHR 'E'
 EQUB VE

 ECHR 'D'               ; Token 229:    ""
 ECHR 'O'
 ECHR 'G'
 EQUB VE

 ETWO 'L', 'E'          ; Token 230:    ""
 ECHR 'O'
 ECHR 'P'
 ETWO 'A', 'R'
 ECHR 'D'
 EQUB VE

 ECHR 'C'               ; Token 231:    ""
 ETWO 'A', 'T'
 EQUB VE

 ECHR 'M'               ; Token 232:    ""
 ETWO 'O', 'N'
 ECHR 'K'
 ECHR 'E'
 ECHR 'Y'
 EQUB VE

 ECHR 'G'               ; Token 233:    ""
 ECHR 'O'
 ETWO 'A', 'T'
 EQUB VE

 ECHR 'C'               ; Token 234:    ""
 ETWO 'A', 'R'
 ECHR 'P'
 EQUB VE

 ERND 15                ; Token 235:    ""
 ECHR ' '
 ERND 14
 EQUB VE

 EJMP 17                ; Token 236:    ""
 ECHR ' '
 ERND 29
 ECHR ' '
 ERND 32
 EQUB VE

 ETOK 175               ; Token 237:    ""
 ERND 16
 ECHR ' '
 ERND 30
 ECHR ' '
 ERND 32
 EQUB VE

 ERND 33                ; Token 238:    ""
 ECHR ' '
 ERND 34
 EQUB VE

 ERND 15                ; Token 239:    ""
 ECHR ' '
 ERND 14
 EQUB VE

 ECHR 'M'               ; Token 240:    ""
 ECHR 'E'
 ETWO 'A', 'T'
 EQUB VE

 ECHR 'C'               ; Token 241:    ""
 ECHR 'U'
 ECHR 'T'
 ECHR 'L'
 ETWO 'E', 'T'
 EQUB VE

 ETWO 'S', 'T'          ; Token 242:    ""
 ECHR 'E'
 ECHR 'A'
 ECHR 'K'
 EQUB VE

 ECHR 'B'               ; Token 243:    ""
 ECHR 'U'
 ECHR 'R'
 ETWO 'G', 'E'
 ECHR 'R'
 ECHR 'S'
 EQUB VE

 ECHR 'S'               ; Token 244:    ""
 ETWO 'O', 'U'
 ECHR 'P'
 EQUB VE

 ECHR 'I'               ; Token 245:    ""
 ETWO 'C', 'E'
 EQUB VE

 ECHR 'M'               ; Token 246:    ""
 ECHR 'U'
 ECHR 'D'
 EQUB VE

 ECHR 'Z'               ; Token 247:    ""
 ETWO 'E', 'R'
 ECHR 'O'
 ECHR '-'
 EJMP 19
 ECHR 'G'
 EQUB VE

 ECHR 'V'               ; Token 248:    ""
 ECHR 'A'
 ECHR 'C'
 ECHR 'U'
 ECHR 'U'
 ECHR 'M'
 EQUB VE

 EJMP 17                ; Token 249:    ""
 ECHR ' '
 ECHR 'U'
 ECHR 'L'
 ECHR 'T'
 ETWO 'R', 'A'
 EQUB VE

 ECHR 'H'               ; Token 250:    ""
 ECHR 'O'
 ECHR 'C'
 ECHR 'K'
 ECHR 'E'
 ECHR 'Y'
 EQUB VE

 ECHR 'C'               ; Token 251:    ""
 ECHR 'R'
 ECHR 'I'
 ECHR 'C'
 ECHR 'K'
 ETWO 'E', 'T'
 EQUB VE

 ECHR 'K'               ; Token 252:    ""
 ETWO 'A', 'R'
 ETWO 'A', 'T'
 ECHR 'E'
 EQUB VE

 ECHR 'P'               ; Token 253:    ""
 ECHR 'O'
 ETWO 'L', 'O'
 EQUB VE

 ECHR 'T'               ; Token 254:    ""
 ETWO 'E', 'N'
 ECHR 'N'
 ECHR 'I'
 ECHR 'S'
 EQUB VE

 EQUB VE                ; Token 255:    ""

; ******************************************************************************
;
;       Name: RUPLA
;       Type: Variable
;   Category: Text
;    Summary: System numbers that have extended description overrides
;  Deep dive: Extended system descriptions
;             Extended text tokens
;
; ------------------------------------------------------------------------------
;
; This table contains the extended token numbers to show as the specified
; system's extended description, if the criteria in the RUGAL table are met.
;
; The three variables work as follows:
;
;   * The RUPLA table contains the system numbers
;
;   * The RUGAL table contains the galaxy numbers and mission criteria
;
;   * The RUTOK table contains the extended token to display instead of the
;     normal extended description if the criteria in RUPLA and RUGAL are met
;
; See the PDESC routine for details of how extended system descriptions work.
;
; ******************************************************************************

.RUPLA

 EQUB 211               ; System 211, Galaxy 0                 Teorge = Token  1
 EQUB 150               ; System 150, Galaxy 0, Mission 1        Xeer = Token  2
 EQUB 36                ; System  36, Galaxy 0, Mission 1    Reesdice = Token  3
 EQUB 28                ; System  28, Galaxy 0, Mission 1       Arexe = Token  4
 EQUB 253               ; System 253, Galaxy 1, Mission 1      Errius = Token  5
 EQUB 79                ; System  79, Galaxy 1, Mission 1      Inbibe = Token  6
 EQUB 53                ; System  53, Galaxy 1, Mission 1       Ausar = Token  7
 EQUB 118               ; System 118, Galaxy 1, Mission 1      Usleri = Token  8
 EQUB 32                ; System  32, Galaxy 1, Mission 1      Bebege = Token 10
 EQUB 68                ; System  68, Galaxy 1, Mission 1      Cearso = Token 11
 EQUB 164               ; System 164, Galaxy 1, Mission 1      Dicela = Token 12
 EQUB 220               ; System 220, Galaxy 1, Mission 1      Eringe = Token 13
 EQUB 106               ; System 106, Galaxy 1, Mission 1      Gexein = Token 14
 EQUB 16                ; System  16, Galaxy 1, Mission 1      Isarin = Token 15
 EQUB 162               ; System 162, Galaxy 1, Mission 1    Letibema = Token 16
 EQUB 3                 ; System   3, Galaxy 1, Mission 1      Maisso = Token 17
 EQUB 107               ; System 107, Galaxy 1, Mission 1        Onen = Token 18
 EQUB 26                ; System  26, Galaxy 1, Mission 1      Ramaza = Token 19
 EQUB 192               ; System 192, Galaxy 1, Mission 1      Sosole = Token 20
 EQUB 184               ; System 184, Galaxy 1, Mission 1      Tivere = Token 21
 EQUB 5                 ; System   5, Galaxy 1, Mission 1      Veriar = Token 22
 EQUB 101               ; System 101, Galaxy 2, Mission 1      Xeveon = Token 23
 EQUB 193               ; System 193, Galaxy 1, Mission 1      Orarra = Token 24

; ******************************************************************************
;
;       Name: RUGAL
;       Type: Variable
;   Category: Text
;    Summary: The criteria for systems with extended description overrides
;  Deep dive: Extended system descriptions
;             Extended text tokens
;
; ------------------------------------------------------------------------------
;
; This table contains the criteria for printing an extended description override
; for a system. The galaxy number is in bits 0-6, while bit 7 determines whether
; to show this token during mission 1 only (bit 7 is clear, i.e. a value of $0x
; in the table below), or all of the time (bit 7 is set, i.e. a value of $8x in
; the table below).
;
; In other words, Teorge, Arredi, Anreer and Lave have extended description
; overrides that are always shown, while the rest only appear when mission 1 is
; in progress.
;
; The three variables work as follows:
;
;   * The RUPLA table contains the system numbers
;
;   * The RUGAL table contains the galaxy numbers and mission criteria
;
;   * The RUTOK table contains the extended token to display instead of the
;     normal extended description if the criteria in RUPLA and RUGAL are met
;
; See the PDESC routine for details of how extended system descriptions work.
;
; ******************************************************************************

.RUGAL

 EQUB $80               ; System 211, Galaxy 0                 Teorge = Token  1
 EQUB $00               ; System 150, Galaxy 0, Mission 1        Xeer = Token  2
 EQUB $00               ; System  36, Galaxy 0, Mission 1    Reesdice = Token  3
 EQUB $00               ; System  28, Galaxy 0, Mission 1       Arexe = Token  4
 EQUB $01               ; System 253, Galaxy 1, Mission 1      Errius = Token  5
 EQUB $01               ; System  79, Galaxy 1, Mission 1      Inbibe = Token  6
 EQUB $01               ; System  53, Galaxy 1, Mission 1       Ausar = Token  7
 EQUB $01               ; System 118, Galaxy 1, Mission 1      Usleri = Token  8
 EQUB $01               ; System  32, Galaxy 1, Mission 1      Bebege = Token 10
 EQUB $01               ; System  68, Galaxy 1, Mission 1      Cearso = Token 11
 EQUB $01               ; System 164, Galaxy 1, Mission 1      Dicela = Token 12
 EQUB $01               ; System 220, Galaxy 1, Mission 1      Eringe = Token 13
 EQUB $01               ; System 106, Galaxy 1, Mission 1      Gexein = Token 14
 EQUB $01               ; System  16, Galaxy 1, Mission 1      Isarin = Token 15
 EQUB $01               ; System 162, Galaxy 1, Mission 1    Letibema = Token 16
 EQUB $01               ; System   3, Galaxy 1, Mission 1      Maisso = Token 17
 EQUB $01               ; System 107, Galaxy 1, Mission 1        Onen = Token 18
 EQUB $01               ; System  26, Galaxy 1, Mission 1      Ramaza = Token 19
 EQUB $01               ; System 192, Galaxy 1, Mission 1      Sosole = Token 20
 EQUB $01               ; System 184, Galaxy 1, Mission 1      Tivere = Token 21
 EQUB $01               ; System   5, Galaxy 1, Mission 1      Veriar = Token 22
 EQUB $02               ; System 101, Galaxy 2, Mission 1      Xeveon = Token 23
 EQUB $01               ; System 193, Galaxy 1, Mission 1      Orarra = Token 24

; ******************************************************************************
;
;       Name: RUTOK
;       Type: Variable
;   Category: Text
;    Summary: The second extended token table for recursive tokens 0-26 (DETOK3)
;  Deep dive: Extended system descriptions
;             Extended text tokens
;
; ------------------------------------------------------------------------------
;
; Contains the tokens for extended description overrides of systems that match
; the system number in RUPLA and the conditions in RUGAL.
;
; The three variables work as follows:
;
;   * The RUPLA table contains the system numbers
;
;   * The RUGAL table contains the galaxy numbers and mission criteria
;
;   * The RUTOK table contains the extended token to display instead of the
;     normal extended description if the criteria in RUPLA and RUGAL are met
;
; See the PDESC routine for details of how extended system descriptions work.
;
; ******************************************************************************

.RUTOK

 EQUB VE                ; Token 0:      ""

 EJMP 19                ; Token 1:      ""
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

 EJMP 19                ; Token 2:      ""
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

 EJMP 19                ; Token 3:      ""
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

 EJMP 19                ; Token 4:      ""
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

 EJMP 19                ; Token 5:      ""
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

 ERND 24                ; Token 6:      ""
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

 EJMP 19                ; Token 7:      ""
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

 EJMP 19                ; Token 8:      ""
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

 ERND 25                ; Token 9:      ""
 EQUB VE

 ERND 25                ; Token 10:     ""
 EQUB VE

 ERND 25                ; Token 11:     ""
 EQUB VE

 ERND 25                ; Token 12:     ""
 EQUB VE

 ERND 25                ; Token 13:     ""
 EQUB VE

 ERND 25                ; Token 14:     ""
 EQUB VE

 ERND 25                ; Token 15:     ""
 EQUB VE

 ERND 25                ; Token 16:     ""
 EQUB VE

 ERND 25                ; Token 17:     ""
 EQUB VE

 ERND 25                ; Token 18:     ""
 EQUB VE

 ERND 25                ; Token 19:     ""
 EQUB VE

 ERND 25                ; Token 20:     ""
 EQUB VE

 ERND 25                ; Token 21:     ""
 EQUB VE

 EJMP 19                ; Token 22:     ""
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

 EJMP 19                ; Token 23:     ""
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

; ******************************************************************************
;
;       Name: TKN1_DE
;       Type: Variable
;   Category: Text
;    Summary: The first extended token table for recursive tokens 0-255 (DETOK)
;             (German)
;  Deep dive: Extended text tokens
;
; ******************************************************************************

.TKN1_DE

 EQUB VE                ; Token 0:      ""

 EJMP 19                ; Token 1:      ""
 ECHR 'J'
 ECHR 'A'
 EQUB VE

 EJMP 19                ; Token 2:      ""
 ECHR 'N'
 ETOK 183
 EQUB VE

 EQUB VE                ; Token 3:      ""

 EJMP 19                ; Token 4:      ""
 ECHR 'D'
 ECHR 'E'
 ECHR 'U'
 ECHR 'T'
 ETOK 187
 EQUB VE

 EQUB VE                ; Token 5:      ""

 EQUB VE                ; Token 6:      ""

 EQUB VE                ; Token 7:      ""

 EJMP 19                ; Token 8:      ""
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

 EQUB VE                ; Token 9:      ""

 EJMP 23                ; Token 10:     ""
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

 EJMP 25                ; Token 11:     ""
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

 EQUB VE                ; Token 12:     ""

 EQUB VE                ; Token 13:     ""

 EJMP 21                ; Token 14:     ""
 ETOK 145
 ETOK 200
 EQUB VE

 EJMP 25                ; Token 15:     ""
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

 EQUB VE                ; Token 16:     ""

 EQUB VE                ; Token 17:     ""

 EQUB VE                ; Token 18:     ""

 EQUB VE                ; Token 19:     ""

 EQUB VE                ; Token 20:     ""

 EQUB VE                ; Token 21:     ""

 EQUB VE                ; Token 22:     ""

 EQUB VE                ; Token 23:     ""

 EQUB VE                ; Token 24:     ""

 EQUB VE                ; Token 25:     ""

 EQUB VE                ; Token 26:     ""

 EQUB VE                ; Token 27:     ""

 EQUB VE                ; Token 28:     ""

 EQUB VE                ; Token 29:     ""

 EQUB VE                ; Token 30:     ""

 EQUB VE                ; Token 31:     ""

 EQUB VE                ; Token 32:     ""

 EQUB VE                ; Token 33:     ""

 EQUB VE                ; Token 34:     ""

 EQUB VE                ; Token 35:     ""

 EQUB VE                ; Token 36:     ""

 EQUB VE                ; Token 37:     ""

 EQUB VE                ; Token 38:     ""

 EQUB VE                ; Token 39:     ""

 EQUB VE                ; Token 40:     ""

 EQUB VE                ; Token 41:     ""

 EQUB VE                ; Token 42:     ""

 EQUB VE                ; Token 43:     ""

 EQUB VE                ; Token 44:     ""

 EQUB VE                ; Token 45:     ""

 EQUB VE                ; Token 46:     ""

 EQUB VE                ; Token 47:     ""

 EQUB VE                ; Token 48:     ""

 EQUB VE                ; Token 49:     ""

 EQUB VE                ; Token 50:     ""

 EQUB VE                ; Token 51:     ""

 EQUB VE                ; Token 52:     ""

 EQUB VE                ; Token 53:     ""

 EQUB VE                ; Token 54:     ""

 EQUB VE                ; Token 55:     ""

 EQUB VE                ; Token 56:     ""

 EQUB VE                ; Token 57:     ""

 EQUB VE                ; Token 58:     ""

 EQUB VE                ; Token 59:     ""

 EQUB VE                ; Token 60:     ""

 EQUB VE                ; Token 61:     ""

 EQUB VE                ; Token 62:     ""

 EQUB VE                ; Token 63:     ""

 EQUB VE                ; Token 64:     ""

 EQUB VE                ; Token 65:     ""

 EQUB VE                ; Token 66:     ""

 EQUB VE                ; Token 67:     ""

 EQUB VE                ; Token 68:     ""

 EQUB VE                ; Token 69:     ""

 EQUB VE                ; Token 70:     ""

 EQUB VE                ; Token 71:     ""

 EQUB VE                ; Token 72:     ""

 EQUB VE                ; Token 73:     ""

 EQUB VE                ; Token 74:     ""

 EQUB VE                ; Token 75:     ""

 EQUB VE                ; Token 76:     ""

 EQUB VE                ; Token 77:     ""

 EQUB VE                ; Token 78:     ""

 EQUB VE                ; Token 79:     ""

 EQUB VE                ; Token 80:     ""

 EQUB VE                ; Token 81:     ""

 EQUB VE                ; Token 82:     ""

 EQUB VE                ; Token 83:     ""

 EQUB VE                ; Token 84:     ""

 EJMP 2                 ; Token 85:     ""
 ERND 31
 EJMP 13
 EQUB VE

 EQUB VE                ; Token 86:     ""

 EQUB VE                ; Token 87:     ""

 EQUB VE                ; Token 88:     ""

 EQUB VE                ; Token 89:     ""

 EQUB VE                ; Token 90:     ""

 EJMP 19                ; Token 91:     ""
 ECHR 'H'
 ETWO 'A', 'L'
 ECHR 'U'
 ECHR 'N'
 ECHR 'K'
 ECHR 'E'
 EQUB VE

 EJMP 19                ; Token 92:     ""
 ETOK 187
 ECHR 'U'
 ECHR 'R'
 ECHR 'K'
 ECHR 'E'
 EQUB VE

 EJMP 19                ; Token 93:     ""
 ECHR 'L'
 ECHR 'U'
 ECHR 'M'
 ECHR 'P'
 EQUB VE

 EJMP 19                ; Token 94:     ""
 ECHR 'G'
 ECHR 'A'
 ECHR 'U'
 ECHR 'N'
 ETWO 'E', 'R'
 EQUB VE

 EJMP 19                ; Token 95:     ""
 ETOK 187
 ECHR 'U'
 ECHR 'F'
 ECHR 'T'
 EQUB VE

 EQUB VE                ; Token 96:     ""

 EQUB VE                ; Token 97:     ""

 EQUB VE                ; Token 98:     ""

 EQUB VE                ; Token 99:     ""

 EQUB VE                ; Token 100:    ""

 EQUB VE                ; Token 101:    ""

 EQUB VE                ; Token 102:    ""

 EQUB VE                ; Token 103:    ""

 EQUB VE                ; Token 104:    ""

 EQUB VE                ; Token 105:    ""

 EJMP 19                ; Token 106:    ""
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

 EJMP 19                ; Token 107:    ""
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

 EJMP 19                ; Token 108:    ""
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

 ETOK 183               ; Token 109:    ""
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

 ECHR 'F'               ; Token 110:    ""
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

 ECHR ' '               ; Token 111:    ""
 ECHR 'K'
 ETWO 'N', 'U'
 ECHR 'D'
 ECHR 'D'
 ECHR 'E'
 ECHR 'L'
 ECHR 'I'
 ECHR 'G'
 EQUB VE

 ECHR ' '               ; Token 112:    ""
 ECHR 'N'
 ECHR 'I'
 ETWO 'E', 'D'
 ECHR 'L'
 ETOK 186
 EQUB VE

 ECHR ' '               ; Token 113:    ""
 ECHR 'P'
 ECHR 'U'
 ETOK 158
 ECHR 'I'
 ECHR 'G'
 EQUB VE

 ECHR ' '               ; Token 114:    ""
 ECHR 'F'
 ETWO 'R', 'E'
 ECHR 'U'
 ECHR 'N'
 ECHR 'D'
 ECHR 'L'
 ETOK 186
 EQUB VE

 EQUB VE                ; Token 115:    ""

 EQUB VE                ; Token 116:    ""

 EQUB VE                ; Token 117:    ""

 EQUB VE                ; Token 118:    ""

 EQUB VE                ; Token 119:    ""

 EQUB VE                ; Token 120:    ""

 EQUB VE                ; Token 121:    ""

 EQUB VE                ; Token 122:    ""

 EQUB VE                ; Token 123:    ""

 EQUB VE                ; Token 124:    ""

 EQUB VE                ; Token 125:    ""

 EQUB VE                ; Token 126:    ""

 EQUB VE                ; Token 127:    ""

 EQUB VE                ; Token 128:    ""

 EQUB VE                ; Token 129:    ""

 EQUB VE                ; Token 130:    ""

 EQUB VE                ; Token 131:    ""

 EQUB VE                ; Token 132:    ""

 EQUB VE                ; Token 133:    ""

 EQUB VE                ; Token 134:    ""

 EQUB VE                ; Token 135:    ""

 EQUB VE                ; Token 136:    ""

 EQUB VE                ; Token 137:    ""

 EQUB VE                ; Token 138:    ""

 EQUB VE                ; Token 139:    ""

 EQUB VE                ; Token 140:    ""

 EQUB VE                ; Token 141:    ""

 EQUB VE                ; Token 142:    ""

 EQUB VE                ; Token 143:    ""

 EQUB VE                ; Token 144:    ""

 EJMP 19                ; Token 145:    ""
 ECHR 'P'
 ETWO 'L', 'A'
 ECHR 'N'
 ETWO 'E', 'T'
 EQUB VE

 EJMP 19                ; Token 146:    ""
 ECHR 'W'
 ECHR 'E'
 ECHR 'L'
 ECHR 'T'
 EQUB VE

 ETWO 'D', 'I'          ; Token 147:    ""
 ECHR 'E'
 ECHR ' '
 EQUB VE

 ETWO 'D', 'I'          ; Token 148:    ""
 ECHR 'E'
 ETWO 'S', 'E'
 ECHR ' '
 EQUB VE

 EQUB VE                ; Token 149:    ""

 EJMP 9                 ; Token 150:    ""
 EJMP 11
 EJMP 1
 EJMP 8
 EQUB VE

 EQUB VE                ; Token 151:    ""

 EQUB VE                ; Token 152:    ""

 ECHR 'I'               ; Token 153:    ""
 ETWO 'A', 'N'
 EQUB VE

 EJMP 19                ; Token 154:    ""
 ECHR 'K'
 ECHR 'O'
 ECHR 'M'
 ETWO 'M', 'A'
 ECHR 'N'
 ECHR 'D'
 ETWO 'A', 'N'
 ECHR 'T'
 EQUB VE

 ECHR 'D'               ; Token 155:    ""
 ETWO 'E', 'R'
 ECHR ' '
 EQUB VE

 ECHR 'D'               ; Token 156:    ""
 ECHR 'A'
 ECHR 'S'
 ECHR ' '
 EQUB VE

 ECHR 'V'               ; Token 157:    ""
 ETWO 'O', 'R'
 EQUB VE

 ECHR 'T'               ; Token 158:    ""
 ECHR 'Z'
 EQUB VE

 ECHR 'Z'               ; Token 159:    ""
 ECHR 'U'
 EQUB VE

 ECHR ' '               ; Token 160:    ""
 ETOK 159
 ECHR ' '
 EQUB VE

 ECHR ' '               ; Token 161:    ""
 ETWO 'E', 'S'
 ECHR ' '
 EQUB VE

 ECHR 'N'               ; Token 162:    ""
 ETOK 186
 ECHR 'T'
 EQUB VE

 ECHR 'M'               ; Token 163:    ""
 ETWO 'A', 'R'
 ETWO 'I', 'N'
 ECHR 'E'
 EQUB VE

 ECHR 'A'               ; Token 164:    ""
 ECHR 'C'
 ECHR 'H'
 EQUB VE

 EQUB VE                ; Token 165:    ""

 EQUB VE                ; Token 166:    ""

 EQUB VE                ; Token 167:    ""

 EQUB VE                ; Token 168:    ""

 EQUB VE                ; Token 169:    ""

 EQUB VE                ; Token 170:    ""

 EQUB VE                ; Token 171:    ""

 EQUB VE                ; Token 172:    ""

 EQUB VE                ; Token 173:    ""

 EQUB VE                ; Token 174:    ""

 ETWO 'I', 'T'          ; Token 175:    ""
 ECHR 'S'
 ECHR ' '
 EQUB VE

 EJMP 13                ; Token 176:    ""
 EJMP 14
 EJMP 19
 EQUB VE

 ECHR '.'               ; Token 177:    ""
 EJMP 12
 EJMP 15
 EQUB VE

 ECHR ' '               ; Token 178:    ""
 ECHR 'U'
 ECHR 'N'
 ECHR 'D'
 ECHR ' '
 EQUB VE

 EJMP 26                ; Token 179:    ""
 ECHR 'S'
 ECHR 'I'
 ECHR 'E'
 EQUB VE

 ECHR ' '               ; Token 180:    ""
 ECHR 'N'
 ETOK 164
 ECHR ' '
 EQUB VE

 ECHR ' '               ; Token 181:    ""
 ECHR 'I'
 ETWO 'S', 'T'
 ECHR ' '
 EQUB VE

 EJMP 26                ; Token 182:    ""
 ETOK 187
 ECHR 'I'
 ECHR 'F'
 ECHR 'F'
 EQUB VE

 ECHR 'E'               ; Token 183:    ""
 ETWO 'I', 'N'
 EQUB VE

 ECHR ' '               ; Token 184:    ""
 ECHR 'N'
 ECHR 'E'
 ECHR 'U'
 ETWO 'E', 'S'
 ECHR ' '
 EQUB VE

 ECHR ' '               ; Token 185:    ""
 ETOK 183
 ECHR ' '
 EQUB VE

 ECHR 'I'               ; Token 186:    ""
 ECHR 'C'
 ECHR 'H'
 EQUB VE

 ECHR 'S'               ; Token 187:    ""
 ECHR 'C'
 ECHR 'H'
 EQUB VE

 ECHR ' '               ; Token 188:    ""
 ETWO 'I', 'N'
 ECHR ' '
 EQUB VE

 EQUB VE                ; Token 189:    ""

 EQUB VE                ; Token 190:    ""

 EQUB VE                ; Token 191:    ""

 EQUB VE                ; Token 192:    ""

 EQUB VE                ; Token 193:    ""

 EQUB VE                ; Token 194:    ""

 ETWO 'I', 'N'          ; Token 195:    ""
 ECHR 'G'
 ECHR ' '
 EQUB VE

 ETWO 'E', 'D'          ; Token 196:    ""
 ECHR ' '
 EQUB VE

 EQUB VE                ; Token 197:    ""

 EJMP 26                ; Token 198:    ""
 ECHR 'S'
 ETWO 'Q', 'U'
 ECHR 'E'
 ECHR 'A'
 ECHR 'K'
 ECHR 'Y'
 EQUB VE

 EJMP 25                ; Token 199:    ""
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

 EJMP 26                ; Token 200:    ""
 ECHR 'N'
 ECHR 'A'
 ECHR 'M'
 ECHR 'E'
 ECHR '?'
 ECHR ' '
 EQUB VE

 EQUB VE                ; Token 201:    ""

 EQUB VE                ; Token 202:    ""

 ECHR 'W'               ; Token 203:    ""
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

 ECHR '.'               ; Token 204:    ""
 EJMP 12
 EJMP 12
 ECHR ' '
 EJMP 19
 EQUB VE

 EJMP 19                ; Token 205:    ""
 ETWO 'G', 'E'
 ECHR 'D'
 ECHR 'O'
 ECHR 'C'
 ECHR 'K'
 ECHR 'T'
 EQUB VE

 EQUB VE                ; Token 206:    ""

 EQUB VE                ; Token 207:    ""

 EQUB VE                ; Token 208:    ""

 EJMP 26                ; Token 209:    ""
 ETWO 'E', 'R'
 ECHR 'R'
 ECHR 'I'
 ETWO 'U', 'S'
 EQUB VE

 EQUB VE                ; Token 210:    ""

 EJMP 26                ; Token 211:    ""
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

 ETOK 177               ; Token 212:    ""
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

 ECHR ' '               ; Token 213:    ""
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

 EQUB VE                ; Token 214:    ""

 EJMP 15                ; Token 215:    ""
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

 EJMP 9                 ; Token 216:    ""
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

 EJMP 19                ; Token 217:    ""
 ECHR 'R'
 ETOK 186
 ECHR 'T'
 ECHR 'O'
 ECHR 'F'
 ETWO 'E', 'N'
 EQUB VE

 EJMP 19                ; Token 218:    ""
 ECHR 'V'
 ETWO 'A', 'N'
 ECHR 'D'
 ETWO 'E', 'R'
 ECHR 'B'
 ETWO 'I', 'L'
 ECHR 'T'
 EQUB VE

 EJMP 19                ; Token 219:    ""
 ECHR 'H'
 ETWO 'A', 'B'
 ECHR 'S'
 ECHR 'B'
 ECHR 'U'
 ECHR 'R'
 ECHR 'G'
 EQUB VE

 ETOK 203               ; Token 220:    ""
 EJMP 19
 ETWO 'R', 'E'
 ETWO 'E', 'S'
 ETWO 'D', 'I'
 ETWO 'C', 'E'
 EQUB VE

 ETWO 'S', 'O'          ; Token 221:    ""
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

 EJMP 25                ; Token 222:    ""
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

 EJMP 25                ; Token 223:    ""
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

 EQUB VE                ; Token 224:    ""

 EQUB VE                ; Token 225:    ""

 EQUB VE                ; Token 226:    ""

 EQUB VE                ; Token 227:    ""

 EQUB VE                ; Token 228:    ""

 EQUB VE                ; Token 229:    ""

 EQUB VE                ; Token 230:    ""

 EQUB VE                ; Token 231:    ""

 EQUB VE                ; Token 232:    ""

 EQUB VE                ; Token 233:    ""

 EQUB VE                ; Token 234:    ""

 EQUB VE                ; Token 235:    ""

 EQUB VE                ; Token 236:    ""

 EQUB VE                ; Token 237:    ""

 EQUB VE                ; Token 238:    ""

 EQUB VE                ; Token 239:    ""

 EQUB VE                ; Token 240:    ""

 EQUB VE                ; Token 241:    ""

 EQUB VE                ; Token 242:    ""

 EQUB VE                ; Token 243:    ""

 EQUB VE                ; Token 244:    ""

 EQUB VE                ; Token 245:    ""

 EQUB VE                ; Token 246:    ""

 EQUB VE                ; Token 247:    ""

 EQUB VE                ; Token 248:    ""

 EQUB VE                ; Token 249:    ""

 EQUB VE                ; Token 250:    ""

 EQUB VE                ; Token 251:    ""

 EQUB VE                ; Token 252:    ""

 EQUB VE                ; Token 253:    ""

 EQUB VE                ; Token 254:    ""

 EQUB VE                ; Token 255:    ""

; ******************************************************************************
;
;       Name: RUPLA_DE
;       Type: Variable
;   Category: Text
;    Summary: System numbers that have extended description overrides (German)
;  Deep dive: Extended system descriptions
;             Extended text tokens
;
; ------------------------------------------------------------------------------
;
; This table contains the extended token numbers to show as the specified
; system's extended description, if the criteria in the RUGAL_DE table are met.
;
; The three variables work as follows:
;
;   * The RUPLA_DE table contains the system numbers
;
;   * The RUGAL_DE table contains the galaxy numbers and mission criteria
;
;   * The RUTOK_DE table contains the extended token to display instead of the
;     normal extended description if the criteria in RUPLA_DE and RUGAL_DE are
;     met
;
; See the PDESC routine for details of how extended system descriptions work.
;
; ******************************************************************************

.RUPLA_DE

 EQUB 211               ; System 211, Galaxy 0                 Teorge = Token  1
 EQUB 150               ; System 150, Galaxy 0, Mission 1        Xeer = Token  2
 EQUB 36                ; System  36, Galaxy 0, Mission 1    Reesdice = Token  3
 EQUB 28                ; System  28, Galaxy 0, Mission 1       Arexe = Token  4
 EQUB 253               ; System 253, Galaxy 1, Mission 1      Errius = Token  5
 EQUB 79                ; System  79, Galaxy 1, Mission 1      Inbibe = Token  6
 EQUB 53                ; System  53, Galaxy 1, Mission 1       Ausar = Token  7
 EQUB 118               ; System 118, Galaxy 1, Mission 1      Usleri = Token  8
 EQUB 32                ; System  32, Galaxy 1, Mission 1      Bebege = Token  9
 EQUB 68                ; System  68, Galaxy 1, Mission 1      Cearso = Token 10
 EQUB 164               ; System 164, Galaxy 1, Mission 1      Dicela = Token 11
 EQUB 220               ; System 220, Galaxy 1, Mission 1      Eringe = Token 12
 EQUB 106               ; System 106, Galaxy 1, Mission 1      Gexein = Token 13
 EQUB 16                ; System  16, Galaxy 1, Mission 1      Isarin = Token 14
 EQUB 162               ; System 162, Galaxy 1, Mission 1    Letibema = Token 15
 EQUB 3                 ; System   3, Galaxy 1, Mission 1      Maisso = Token 16
 EQUB 107               ; System 107, Galaxy 1, Mission 1        Onen = Token 17
 EQUB 26                ; System  26, Galaxy 1, Mission 1      Ramaza = Token 18
 EQUB 192               ; System 192, Galaxy 1, Mission 1      Sosole = Token 19
 EQUB 184               ; System 184, Galaxy 1, Mission 1      Tivere = Token 20
 EQUB 5                 ; System   5, Galaxy 1, Mission 1      Veriar = Token 21
 EQUB 101               ; System 101, Galaxy 2, Mission 1      Xeveon = Token 22
 EQUB 193               ; System 193, Galaxy 1, Mission 1      Orarra = Token 23

; ******************************************************************************
;
;       Name: RUGAL_DE
;       Type: Variable
;   Category: Text
;    Summary: The criteria for systems with extended description overrides
;             (German)
;  Deep dive: Extended system descriptions
;             Extended text tokens
;
; ------------------------------------------------------------------------------
;
; This table contains the criteria for printing an extended description override
; for a system. The galaxy number is in bits 0-6, while bit 7 determines whether
; to show this token during mission 1 only (bit 7 is clear, i.e. a value of $0x
; in the table below), or all of the time (bit 7 is set, i.e. a value of $8x in
; the table below).
;
; In other words, Teorge has an extended description override description that
; is always shown, while the rest only appear when mission 1 is in progress.
;
; The three variables work as follows:
;
;   * The RUPLA_DE table contains the system numbers
;
;   * The RUGAL_DE table contains the galaxy numbers and mission criteria
;
;   * The RUTOK_DE table contains the extended token to display instead of the
;     normal extended description if the criteria in RUPLA_DE and RUGAL_DE are
;     met
;
; See the PDESC routine for details of how extended system descriptions work.
;
; ******************************************************************************

.RUGAL_DE

 EQUB $80               ; System 211, Galaxy 0                 Teorge = Token  1
 EQUB $00               ; System 150, Galaxy 0, Mission 1        Xeer = Token  2
 EQUB $00               ; System  36, Galaxy 0, Mission 1    Reesdice = Token  3
 EQUB $00               ; System  28, Galaxy 0, Mission 1       Arexe = Token  4
 EQUB $01               ; System 253, Galaxy 1, Mission 1      Errius = Token  5
 EQUB $01               ; System  79, Galaxy 1, Mission 1      Inbibe = Token  6
 EQUB $01               ; System  53, Galaxy 1, Mission 1       Ausar = Token  7
 EQUB $01               ; System 118, Galaxy 1, Mission 1      Usleri = Token  8
 EQUB $01               ; System  32, Galaxy 1, Mission 1      Bebege = Token  9
 EQUB $01               ; System  68, Galaxy 1, Mission 1      Cearso = Token 10
 EQUB $01               ; System 164, Galaxy 1, Mission 1      Dicela = Token 11
 EQUB $01               ; System 220, Galaxy 1, Mission 1      Eringe = Token 12
 EQUB $01               ; System 106, Galaxy 1, Mission 1      Gexein = Token 13
 EQUB $01               ; System  16, Galaxy 1, Mission 1      Isarin = Token 14
 EQUB $01               ; System 162, Galaxy 1, Mission 1    Letibema = Token 15
 EQUB $01               ; System   3, Galaxy 1, Mission 1      Maisso = Token 16
 EQUB $01               ; System 107, Galaxy 1, Mission 1        Onen = Token 17
 EQUB $01               ; System  26, Galaxy 1, Mission 1      Ramaza = Token 18
 EQUB $01               ; System 192, Galaxy 1, Mission 1      Sosole = Token 19
 EQUB $01               ; System 184, Galaxy 1, Mission 1      Tivere = Token 20
 EQUB $01               ; System   5, Galaxy 1, Mission 1      Veriar = Token 21
 EQUB $02               ; System 101, Galaxy 2, Mission 1      Xeveon = Token 22
 EQUB $01               ; System 193, Galaxy 1, Mission 1      Orarra = Token 23

; ******************************************************************************
;
;       Name: RUTOK_DE
;       Type: Variable
;   Category: Text
;    Summary: The second extended token table for recursive tokens 0-26 (DETOK3)
;             (German)
;  Deep dive: Extended system descriptions
;             Extended text tokens
;
; ------------------------------------------------------------------------------
;
; Contains the tokens for extended description overrides of systems that match
; the system number in RUPLA_DE and the conditions in RUGAL_DE.
;
; The three variables work as follows:
;
;   * The RUPLA_DE table contains the system numbers
;
;   * The RUGAL_DE table contains the galaxy numbers and mission criteria
;
;   * The RUTOK_DE table contains the extended token to display instead of the
;     normal extended description if the criteria in RUPLA_DE and RUGAL_DE are
;     met
;
; See the PDESC routine for details of how extended system descriptions work.
;
; ******************************************************************************

.RUTOK_DE

 EQUB VE                ; Token 0:      ""

 EJMP 19                ; Token 1:      ""
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

 EJMP 19                ; Token 2:      ""
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

 EJMP 19                ; Token 3:      ""
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

 EJMP 19                ; Token 4:      ""
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

 EJMP 19                ; Token 5:      ""
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

 EJMP 19                ; Token 6:      ""
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

 EJMP 19                ; Token 7:      ""
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

 ERND 25                ; Token 8:      ""
 EQUB VE

 ERND 25                ; Token 9:      ""
 EQUB VE

 ERND 25                ; Token 10:     ""
 EQUB VE

 ERND 25                ; Token 11:     ""
 EQUB VE

 ERND 25                ; Token 12:     ""
 EQUB VE

 ERND 25                ; Token 13:     ""
 EQUB VE

 ERND 25                ; Token 14:     ""
 EQUB VE

 ERND 25                ; Token 15:     ""
 EQUB VE

 ERND 25                ; Token 16:     ""
 EQUB VE

 ERND 25                ; Token 17:     ""
 EQUB VE

 ERND 25                ; Token 18:     ""
 EQUB VE

 ERND 25                ; Token 19:     ""
 EQUB VE

 ERND 25                ; Token 20:     ""
 EQUB VE

 EJMP 19                ; Token 21:     ""
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

; ******************************************************************************
;
;       Name: TKN1_FR
;       Type: Variable
;   Category: Text
;    Summary: The first extended token table for recursive tokens 0-255 (DETOK)
;             (French)
;  Deep dive: Extended text tokens
;
; ******************************************************************************

.TKN1_FR

 EQUB VE                ; Token 0:      ""

 EJMP 19                ; Token 1:      ""
 ETWO 'O', 'U'
 ECHR 'I'
 EQUB VE

 EJMP 19                ; Token 2:      ""
 ECHR 'N'
 ETWO 'O', 'N'
 EQUB VE

 EQUB VE                ; Token 3:      ""

 EJMP 19                ; Token 4:      ""
 ECHR 'F'
 ETWO 'R', 'A'
 ECHR 'N'
 ECHR '@'
 ECHR 'A'
 ECHR 'I'
 ECHR 'S'
 EQUB VE

 EQUB VE                ; Token 5:      ""

 EQUB VE                ; Token 6:      ""

 EQUB VE                ; Token 7:      ""

 EJMP 19                ; Token 8:      ""
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

 EQUB VE                ; Token 9:      ""

 EJMP 23                ; Token 10:     ""
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

 EJMP 25                ; Token 11:     ""
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

 EQUB VE                ; Token 12:     ""

 EQUB VE                ; Token 13:     ""

 EJMP 21                ; Token 14:     ""
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

 EJMP 25                ; Token 15:     ""
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

 EQUB VE                ; Token 16:     ""

 EQUB VE                ; Token 17:     ""

 EQUB VE                ; Token 18:     ""

 EQUB VE                ; Token 19:     ""

 EQUB VE                ; Token 20:     ""

 EQUB VE                ; Token 21:     ""

 EQUB VE                ; Token 22:     ""

 EQUB VE                ; Token 23:     ""

 EQUB VE                ; Token 24:     ""

 EQUB VE                ; Token 25:     ""

 EQUB VE                ; Token 26:     ""

 EQUB VE                ; Token 27:     ""

 EQUB VE                ; Token 28:     ""

 EQUB VE                ; Token 29:     ""

 EQUB VE                ; Token 30:     ""

 EQUB VE                ; Token 31:     ""

 EQUB VE                ; Token 32:     ""

 EQUB VE                ; Token 33:     ""

 EQUB VE                ; Token 34:     ""

 EQUB VE                ; Token 35:     ""

 EQUB VE                ; Token 36:     ""

 EQUB VE                ; Token 37:     ""

 EQUB VE                ; Token 38:     ""

 EQUB VE                ; Token 39:     ""

 EQUB VE                ; Token 40:     ""

 EQUB VE                ; Token 41:     ""

 EQUB VE                ; Token 42:     ""

 EQUB VE                ; Token 43:     ""

 EQUB VE                ; Token 44:     ""

 EQUB VE                ; Token 45:     ""

 EQUB VE                ; Token 46:     ""

 EQUB VE                ; Token 47:     ""

 EQUB VE                ; Token 48:     ""

 EQUB VE                ; Token 49:     ""

 EQUB VE                ; Token 50:     ""

 EQUB VE                ; Token 51:     ""

 EQUB VE                ; Token 52:     ""

 EQUB VE                ; Token 53:     ""

 EQUB VE                ; Token 54:     ""

 EQUB VE                ; Token 55:     ""

 EQUB VE                ; Token 56:     ""

 EQUB VE                ; Token 57:     ""

 EQUB VE                ; Token 58:     ""

 EQUB VE                ; Token 59:     ""

 EQUB VE                ; Token 60:     ""

 EQUB VE                ; Token 61:     ""

 EQUB VE                ; Token 62:     ""

 EQUB VE                ; Token 63:     ""

 EQUB VE                ; Token 64:     ""

 EQUB VE                ; Token 65:     ""

 EQUB VE                ; Token 66:     ""

 EQUB VE                ; Token 67:     ""

 EQUB VE                ; Token 68:     ""

 EQUB VE                ; Token 69:     ""

 EQUB VE                ; Token 70:     ""

 EQUB VE                ; Token 71:     ""

 EQUB VE                ; Token 72:     ""

 EQUB VE                ; Token 73:     ""

 EQUB VE                ; Token 74:     ""

 EQUB VE                ; Token 75:     ""

 EQUB VE                ; Token 76:     ""

 EQUB VE                ; Token 77:     ""

 EQUB VE                ; Token 78:     ""

 EQUB VE                ; Token 79:     ""

 EQUB VE                ; Token 80:     ""

 EQUB VE                ; Token 81:     ""

 EQUB VE                ; Token 82:     ""

 EQUB VE                ; Token 83:     ""

 EQUB VE                ; Token 84:     ""

 EJMP 2                 ; Token 85:     ""
 ERND 31
 EJMP 13
 EQUB VE

 EQUB VE                ; Token 86:     ""

 EQUB VE                ; Token 87:     ""

 EQUB VE                ; Token 88:     ""

 EQUB VE                ; Token 89:     ""

 EQUB VE                ; Token 90:     ""

 ECHR 'C'               ; Token 91:     ""
 ETWO 'R', 'A'
 ECHR 'P'
 ECHR 'U'
 ETWO 'L', 'E'
 EQUB VE

 ECHR 'V'               ; Token 92:     ""
 ECHR 'A'
 ECHR 'U'
 ECHR 'R'
 ECHR 'I'
 ETWO 'E', 'N'
 EQUB VE

 ETWO 'E', 'S'          ; Token 93:     ""
 ECHR 'C'
 ECHR 'R'
 ECHR 'O'
 ECHR 'C'
 EQUB VE

 ECHR 'G'               ; Token 94:     ""
 ETWO 'R', 'E'
 ECHR 'D'
 ETWO 'I', 'N'
 EQUB VE

 ECHR 'B'               ; Token 95:     ""
 ECHR 'R'
 ECHR 'I'
 ECHR 'G'
 ETWO 'A', 'N'
 ECHR 'D'
 EQUB VE

 EQUB VE                ; Token 96:     ""

 EQUB VE                ; Token 97:     ""

 EQUB VE                ; Token 98:     ""

 EQUB VE                ; Token 99:     ""

 EQUB VE                ; Token 100:    ""

 EQUB VE                ; Token 101:    ""

 EQUB VE                ; Token 102:    ""

 EQUB VE                ; Token 103:    ""

 EQUB VE                ; Token 104:    ""

 EQUB VE                ; Token 105:    ""

 EJMP 19                ; Token 106:    ""
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

 EJMP 19                ; Token 107:    ""
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

 EJMP 19                ; Token 108:    ""
 ETWO 'A', 'L'
 ETWO 'L', 'E'
 ECHR 'Z'
 ECHR ' '
 ECHR '"'
 ETOK 209
 EQUB VE

 EJMP 19                ; Token 109:    ""
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

 EJMP 19                ; Token 110:    ""
 ETWO 'E', 'S'
 ECHR 'S'
 ECHR 'A'
 ECHR 'Y'
 ECHR 'E'
 ECHR 'Z'
 ETOK 209
 EQUB VE

 EQUB VE                ; Token 111:    ""

 EQUB VE                ; Token 112:    ""

 EQUB VE                ; Token 113:    ""

 EQUB VE                ; Token 114:    ""

 EQUB VE                ; Token 115:    ""

 EQUB VE                ; Token 116:    ""

 EQUB VE                ; Token 117:    ""

 EQUB VE                ; Token 118:    ""

 EQUB VE                ; Token 119:    ""

 EQUB VE                ; Token 120:    ""

 EQUB VE                ; Token 121:    ""

 EQUB VE                ; Token 122:    ""

 EQUB VE                ; Token 123:    ""

 EQUB VE                ; Token 124:    ""

 EQUB VE                ; Token 125:    ""

 EQUB VE                ; Token 126:    ""

 EQUB VE                ; Token 127:    ""

 EQUB VE                ; Token 128:    ""

 ECHR ' '               ; Token 129:    ""
 ECHR 'A'
 ECHR ' '
 EQUB VE

 EQUB VE                ; Token 130:    ""

 EQUB VE                ; Token 131:    ""

 EQUB VE                ; Token 132:    ""

 EQUB VE                ; Token 133:    ""

 EQUB VE                ; Token 134:    ""

 EQUB VE                ; Token 135:    ""

 EQUB VE                ; Token 136:    ""

 EQUB VE                ; Token 137:    ""

 EQUB VE                ; Token 138:    ""

 EQUB VE                ; Token 139:    ""

 EQUB VE                ; Token 140:    ""

 EQUB VE                ; Token 141:    ""

 EQUB VE                ; Token 142:    ""

 EQUB VE                ; Token 143:    ""

 EQUB VE                ; Token 144:    ""

 ECHR 'P'               ; Token 145:    ""
 ETWO 'L', 'A'
 ECHR 'N'
 ECHR '='
 ECHR 'T'
 ECHR 'E'
 EQUB VE

 ECHR 'M'               ; Token 146:    ""
 ETWO 'O', 'N'
 ECHR 'D'
 ECHR 'E'
 EQUB VE

 ECHR 'E'               ; Token 147:    ""
 ECHR 'C'
 ECHR ' '
 EQUB VE

 ETWO 'C', 'E'          ; Token 148:    ""
 ECHR 'C'
 ECHR 'I'
 ECHR ' '
 EQUB VE

 EQUB VE                ; Token 149:    ""

 EJMP 9                 ; Token 150:    ""
 EJMP 11
 EJMP 1
 EJMP 8
 EQUB VE

 EQUB VE                ; Token 151:    ""

 EQUB VE                ; Token 152:    ""

 ECHR 'I'               ; Token 153:    ""
 ETWO 'A', 'N'
 EQUB VE

 EJMP 19                ; Token 154:    ""
 ECHR 'C'
 ECHR 'O'
 ECHR 'M'
 ETWO 'M', 'A'
 ECHR 'N'
 ECHR 'D'
 ETWO 'A', 'N'
 ECHR 'T'
 EQUB VE

 EQUB VE                ; Token 155:    ""

 EQUB VE                ; Token 156:    ""

 EQUB VE                ; Token 157:    ""

 EQUB VE                ; Token 158:    ""

 EQUB VE                ; Token 159:    ""

 EQUB VE                ; Token 160:    ""

 EQUB VE                ; Token 161:    ""

 EQUB VE                ; Token 162:    ""

 EQUB VE                ; Token 163:    ""

 EQUB VE                ; Token 164:    ""

 EQUB VE                ; Token 165:    ""

 EQUB VE                ; Token 166:    ""

 EQUB VE                ; Token 167:    ""

 EQUB VE                ; Token 168:    ""

 EQUB VE                ; Token 169:    ""

 EQUB VE                ; Token 170:    ""

 ECHR 'S'               ; Token 171:    ""
 ECHR 'U'
 ECHR 'I'
 ECHR 'S'
 ECHR ' '
 EQUB VE

 ECHR 'A'               ; Token 172:    ""
 ECHR 'V'
 ETWO 'O', 'N'
 EQUB VE

 ECHR ' '               ; Token 173:    ""
 ECHR 'N'
 ECHR 'A'
 ECHR 'V'
 ECHR 'I'
 ETWO 'R', 'E'
 ECHR ' '
 EQUB VE

 ETWO 'A', 'R'          ; Token 174:    ""
 ETWO 'I', 'N'
 ECHR 'E'
 EQUB VE

 ECHR 'P'               ; Token 175:    ""
 ETWO 'O', 'U'
 ECHR 'R'
 EQUB VE

 EJMP 13                ; Token 176:    ""
 EJMP 14
 EJMP 19
 EQUB VE

 ECHR '.'               ; Token 177:    ""
 EJMP 12
 EJMP 15
 EQUB VE

 ETWO 'L', 'E'          ; Token 178:    ""
 ECHR ' '
 EQUB VE

 ECHR ' '               ; Token 179:    ""
 ECHR 'D'
 ECHR 'E'
 ECHR ' '
 EQUB VE

 ECHR ' '               ; Token 180:    ""
 ETWO 'E', 'T'
 ECHR ' '
 EQUB VE

 ECHR 'J'               ; Token 181:    ""
 ECHR 'E'
 ECHR ' '
 EQUB VE

 ETWO 'L', 'A'          ; Token 182:    ""
 ECHR ' '
 EQUB VE

 ECHR ' '               ; Token 183:    ""
 ECHR '"'
 ECHR ' '
 EQUB VE

 ECHR 'E'               ; Token 184:    ""
 ETWO 'S', 'T'
 EQUB VE

 ETWO 'I', 'L'          ; Token 185:    ""
 EQUB VE

 ECHR 'U'               ; Token 186:    ""
 ECHR 'N'
 ECHR ' '
 EQUB VE

 ETWO 'L', 'E'          ; Token 187:    ""
 ECHR 'S'
 ECHR ' '
 EQUB VE

 ETWO 'C', 'E'          ; Token 188:    ""
 ECHR ' '
 EQUB VE

 ECHR 'D'               ; Token 189:    ""
 ECHR 'E'
 ECHR ' '
 ETOK 182
 EQUB VE

 ECHR 'V'               ; Token 190:    ""
 ETWO 'O', 'U'
 ECHR 'S'
 EQUB VE

 EJMP 26                ; Token 191:    ""
 ECHR 'B'
 ETWO 'O', 'N'
 ECHR 'J'
 ETWO 'O', 'U'
 ECHR 'R'
 ECHR ' '
 EQUB VE

 ETWO 'Q', 'U'          ; Token 192:    ""
 ECHR 'E'
 ECHR ' '
 EQUB VE

 ERND 4                 ; Token 193:    ""
 ECHR 'T'
 EQUB VE

 EQUB VE                ; Token 194:    ""

 ECHR 'D'               ; Token 195:    ""
 ETWO 'E', 'S'
 ECHR ' '
 EQUB VE

 ECHR 'P'               ; Token 196:    ""
 ECHR 'L'
 ETWO 'U', 'S'
 EQUB VE

 EQUB VE                ; Token 197:    ""

 EJMP 26                ; Token 198:    ""
 ECHR 'S'
 ETWO 'Q', 'U'
 ECHR 'E'
 ECHR 'A'
 ECHR 'K'
 ECHR 'Y'
 EQUB VE

 EJMP 25                ; Token 199:    ""
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

 EJMP 26                ; Token 200:    ""
 ETWO 'N', 'O'
 ECHR 'M'
 ECHR '?'
 ECHR ' '
 EQUB VE

 EQUB VE                ; Token 201:    ""

 EQUB VE                ; Token 202:    ""

 ECHR 'P'               ; Token 203:    ""
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

 ECHR '.'               ; Token 204:    ""
 EJMP 12
 EJMP 12
 ECHR ' '
 EJMP 19
 EQUB VE

 ECHR '"'               ; Token 205:    ""
 ECHR ' '
 ETWO 'Q', 'U'
 ECHR 'A'
 ECHR 'I'
 EQUB VE

 EQUB VE                ; Token 206:    ""

 EQUB VE                ; Token 207:    ""

 EQUB VE                ; Token 208:    ""

 EJMP 26                ; Token 209:    ""
 ETWO 'E', 'R'
 ECHR 'R'
 ECHR 'I'
 ETWO 'U', 'S'
 EQUB VE

 EQUB VE                ; Token 210:    ""

 ECHR ' '               ; Token 211:    ""
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

 ETOK 177               ; Token 212:    ""
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

 ECHR ' '               ; Token 213:    ""
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

 EQUB VE                ; Token 214:    ""

 EJMP 15                ; Token 215:    ""
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

 EJMP 9                 ; Token 216:    ""
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

 ECHR 'D'               ; Token 217:    ""
 ECHR 'E'
 EJMP 26
 ETWO 'R', 'E'
 ECHR 'M'
 ECHR 'I'
 ECHR 'G'
 ECHR 'N'
 ECHR 'Y'
 EQUB VE

 ECHR 'D'               ; Token 218:    ""
 ECHR 'E'
 EJMP 26
 ETWO 'S', 'E'
 ECHR 'V'
 ECHR 'I'
 ECHR 'G'
 ECHR 'N'
 ECHR 'Y'
 EQUB VE

 ECHR 'D'               ; Token 219:    ""
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

 ETOK 203               ; Token 220:    ""
 EJMP 19
 ETWO 'R', 'E'
 ETWO 'E', 'S'
 ETWO 'D', 'I'
 ETWO 'C', 'E'
 EQUB VE

 ECHR ' '               ; Token 221:    ""
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

 EJMP 25                ; Token 222:    ""
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

 EJMP 25                ; Token 223:    ""
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

 EQUB VE                ; Token 224:    ""

 EQUB VE                ; Token 225:    ""

 EQUB VE                ; Token 226:    ""

 EQUB VE                ; Token 227:    ""

 EQUB VE                ; Token 228:    ""

 EQUB VE                ; Token 229:    ""

 EQUB VE                ; Token 230:    ""

 EQUB VE                ; Token 231:    ""

 EQUB VE                ; Token 232:    ""

 EQUB VE                ; Token 233:    ""

 EQUB VE                ; Token 234:    ""

 EQUB VE                ; Token 235:    ""

 EQUB VE                ; Token 236:    ""

 EQUB VE                ; Token 237:    ""

 EQUB VE                ; Token 238:    ""

 EQUB VE                ; Token 239:    ""

 EQUB VE                ; Token 240:    ""

 EQUB VE                ; Token 241:    ""

 EQUB VE                ; Token 242:    ""

 EQUB VE                ; Token 243:    ""

 EQUB VE                ; Token 244:    ""

 EQUB VE                ; Token 245:    ""

 EQUB VE                ; Token 246:    ""

 EQUB VE                ; Token 247:    ""

 EQUB VE                ; Token 248:    ""

 EQUB VE                ; Token 249:    ""

 EQUB VE                ; Token 250:    ""

 EQUB VE                ; Token 251:    ""

 EQUB VE                ; Token 252:    ""

 EQUB VE                ; Token 253:    ""

 EQUB VE                ; Token 254:    ""

 EQUB VE                ; Token 255:    ""

; ******************************************************************************
;
;       Name: RUPLA_FR
;       Type: Variable
;   Category: Text
;    Summary: System numbers that have extended description overrides (French)
;  Deep dive: Extended system descriptions
;             Extended text tokens
;
; ------------------------------------------------------------------------------
;
; This table contains the extended token numbers to show as the specified
; system's extended description, if the criteria in the RUGAL_FR table are met.
;
; The three variables work as follows:
;
;   * The RUPLA_FR table contains the system numbers
;
;   * The RUGAL_FR table contains the galaxy numbers and mission criteria
;
;   * The RUTOK_FR table contains the extended token to display instead of the
;     normal extended description if the criteria in RUPLA_FR and RUGAL_FR are
;     met
;
; See the PDESC routine for details of how extended system descriptions work.
;
; ******************************************************************************

.RUPLA_FR

 EQUB 211               ; System 211, Galaxy 0                 Teorge = Token  1
 EQUB 150               ; System 150, Galaxy 0, Mission 1        Xeer = Token  2
 EQUB 36                ; System  36, Galaxy 0, Mission 1    Reesdice = Token  3
 EQUB 28                ; System  28, Galaxy 0, Mission 1       Arexe = Token  4
 EQUB 253               ; System 253, Galaxy 1, Mission 1      Errius = Token  5
 EQUB 79                ; System  79, Galaxy 1, Mission 1      Inbibe = Token  6
 EQUB 53                ; System  53, Galaxy 1, Mission 1       Ausar = Token  7
 EQUB 118               ; System 118, Galaxy 1, Mission 1      Usleri = Token  8
 EQUB 32                ; System  32, Galaxy 1, Mission 1      Bebege = Token  9
 EQUB 68                ; System  68, Galaxy 1, Mission 1      Cearso = Token 10
 EQUB 164               ; System 164, Galaxy 1, Mission 1      Dicela = Token 11
 EQUB 220               ; System 220, Galaxy 1, Mission 1      Eringe = Token 12
 EQUB 106               ; System 106, Galaxy 1, Mission 1      Gexein = Token 13
 EQUB 16                ; System  16, Galaxy 1, Mission 1      Isarin = Token 14
 EQUB 162               ; System 162, Galaxy 1, Mission 1    Letibema = Token 15
 EQUB 3                 ; System   3, Galaxy 1, Mission 1      Maisso = Token 16
 EQUB 107               ; System 107, Galaxy 1, Mission 1        Onen = Token 17
 EQUB 26                ; System  26, Galaxy 1, Mission 1      Ramaza = Token 18
 EQUB 192               ; System 192, Galaxy 1, Mission 1      Sosole = Token 19
 EQUB 184               ; System 184, Galaxy 1, Mission 1      Tivere = Token 20
 EQUB 5                 ; System   5, Galaxy 1, Mission 1      Veriar = Token 21
 EQUB 101               ; System 101, Galaxy 2, Mission 1      Xeveon = Token 22
 EQUB 193               ; System 193, Galaxy 1, Mission 1      Orarra = Token 23

; ******************************************************************************
;
;       Name: RUGAL_FR
;       Type: Variable
;   Category: Text
;    Summary: The criteria for systems with extended description overrides
;             (French)
;  Deep dive: Extended system descriptions
;             Extended text tokens
;
; ------------------------------------------------------------------------------
;
; This table contains the criteria for printing an extended description override
; for a system. The galaxy number is in bits 0-6, while bit 7 determines whether
; to show this token during mission 1 only (bit 7 is clear, i.e. a value of $0x
; in the table below), or all of the time (bit 7 is set, i.e. a value of $8x in
; the table below).
;
; In other words, Teorge has an extended description override description that
; is always shown, while the rest only appear when mission 1 is in progress.
;
; The three variables work as follows:
;
;   * The RUPLA_FR table contains the system numbers
;
;   * The RUGAL_FR table contains the galaxy numbers and mission criteria
;
;   * The RUTOK_FR table contains the extended token to display instead of the
;     normal extended description if the criteria in RUPLA_FR and RUGAL_FR are
;     met
;
; See the PDESC routine for details of how extended system descriptions work.
;
; ******************************************************************************

.RUGAL_FR

 EQUB $80               ; System 211, Galaxy 0                 Teorge = Token  1
 EQUB $00               ; System 150, Galaxy 0, Mission 1        Xeer = Token  2
 EQUB $00               ; System  36, Galaxy 0, Mission 1    Reesdice = Token  3
 EQUB $00               ; System  28, Galaxy 0, Mission 1       Arexe = Token  4
 EQUB $01               ; System 253, Galaxy 1, Mission 1      Errius = Token  5
 EQUB $01               ; System  79, Galaxy 1, Mission 1      Inbibe = Token  6
 EQUB $01               ; System  53, Galaxy 1, Mission 1       Ausar = Token  7
 EQUB $01               ; System 118, Galaxy 1, Mission 1      Usleri = Token  8
 EQUB $01               ; System  32, Galaxy 1, Mission 1      Bebege = Token  9
 EQUB $01               ; System  68, Galaxy 1, Mission 1      Cearso = Token 10
 EQUB $01               ; System 164, Galaxy 1, Mission 1      Dicela = Token 11
 EQUB $01               ; System 220, Galaxy 1, Mission 1      Eringe = Token 12
 EQUB $01               ; System 106, Galaxy 1, Mission 1      Gexein = Token 13
 EQUB $01               ; System  16, Galaxy 1, Mission 1      Isarin = Token 14
 EQUB $01               ; System 162, Galaxy 1, Mission 1    Letibema = Token 15
 EQUB $01               ; System   3, Galaxy 1, Mission 1      Maisso = Token 16
 EQUB $01               ; System 107, Galaxy 1, Mission 1        Onen = Token 17
 EQUB $01               ; System  26, Galaxy 1, Mission 1      Ramaza = Token 18
 EQUB $01               ; System 192, Galaxy 1, Mission 1      Sosole = Token 19
 EQUB $01               ; System 184, Galaxy 1, Mission 1      Tivere = Token 20
 EQUB $01               ; System   5, Galaxy 1, Mission 1      Veriar = Token 21
 EQUB $02               ; System 101, Galaxy 2, Mission 1      Xeveon = Token 22
 EQUB $01               ; System 193, Galaxy 1, Mission 1      Orarra = Token 23

; ******************************************************************************
;
;       Name: RUTOK_FR
;       Type: Variable
;   Category: Text
;    Summary: The second extended token table for recursive tokens 0-26 (DETOK3)
;             (French)
;  Deep dive: Extended system descriptions
;             Extended text tokens
;
; ------------------------------------------------------------------------------
;
; Contains the tokens for extended description overrides of systems that match
; the system number in RUPLA_FR and the conditions in RUGAL_FR.
;
; The three variables work as follows:
;
;   * The RUPLA_FR table contains the system numbers
;
;   * The RUGAL_FR table contains the galaxy numbers and mission criteria
;
;   * The RUTOK_FR table contains the extended token to display instead of the
;     normal extended description if the criteria in RUPLA_FR and RUGAL_FR are
;     met
;
; See the PDESC routine for details of how extended system descriptions work.
;
; ******************************************************************************

.RUTOK_FR

 EQUB VE                ; Token 0:      ""

 EJMP 19                ; Token 1:      ""
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

 EJMP 19                ; Token 2:      ""
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

 EJMP 19                ; Token 3:      ""
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

 EJMP 19                ; Token 4:      ""
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

 EJMP 19                ; Token 5:      ""
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

 EJMP 19                ; Token 6:      ""
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

 EJMP 19                ; Token 7:      ""
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

 EJMP 19                ; Token 8:      ""
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

 ERND 25                ; Token 9:      ""
 EQUB VE

 ERND 25                ; Token 10:     ""
 EQUB VE

 ERND 25                ; Token 11:     ""
 EQUB VE

 ERND 25                ; Token 12:     ""
 EQUB VE

 ERND 25                ; Token 13:     ""
 EQUB VE

 ERND 25                ; Token 14:     ""
 EQUB VE

 ERND 25                ; Token 15:     ""
 EQUB VE

 ERND 25                ; Token 16:     ""
 EQUB VE

 ERND 25                ; Token 17:     ""
 EQUB VE

 ERND 25                ; Token 18:     ""
 EQUB VE

 ERND 25                ; Token 19:     ""
 EQUB VE

 ERND 25                ; Token 20:     ""
 EQUB VE

 ERND 25                ; Token 21:     ""
 EQUB VE

 EJMP 19                ; Token 22:     ""
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

 EJMP 19                ; Token 23:     ""
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

; ******************************************************************************
;
;       Name: QQ18
;       Type: Variable
;   Category: Text
;    Summary: The recursive token table for tokens 0-148
;
; ******************************************************************************

.QQ18

 RTOK 111               ; Token 0:      ""
 RTOK 131
 CONT 7
 EQUB 0

 CHAR ' '               ; Token 1:      ""
 CHAR 'C'
 CHAR 'H'
 TWOK 'A', 'R'
 CHAR 'T'
 EQUB 0

 CHAR 'G'               ; Token 2:      ""
 CHAR 'O'
 CHAR 'V'
 TWOK 'E', 'R'
 CHAR 'N'
 CHAR 'M'
 TWOK 'E', 'N'
 CHAR 'T'
 EQUB 0

 CHAR 'D'               ; Token 3:      ""
 TWOK 'A', 'T'
 CHAR 'A'
 RTOK 131
 CONT 3
 EQUB 0

 TWOK 'I', 'N'          ; Token 4:      ""
 CHAR 'V'
 TWOK 'E', 'N'
 CHAR 'T'
 TWOK 'O', 'R'
 CHAR 'Y'
 CONT 12
 EQUB 0

 CHAR 'S'               ; Token 5:      ""
 CHAR 'Y'
 CHAR 'S'
 TWOK 'T', 'E'
 CHAR 'M'
 EQUB 0

 CHAR 'P'               ; Token 6:      ""
 TWOK 'R', 'I'
 TWOK 'C', 'E'
 EQUB 0

 CONT 2                 ; Token 7:      ""
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

 TWOK 'I', 'N'          ; Token 8:      ""
 CHAR 'D'
 TWOK 'U', 'S'
 CHAR 'T'
 TWOK 'R', 'I'
 CHAR 'A'
 CHAR 'L'
 EQUB 0

 CHAR 'A'               ; Token 9:      ""
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

 TWOK 'R', 'I'          ; Token 10:     ""
 CHAR 'C'
 CHAR 'H'
 CHAR ' '
 EQUB 0

 RTOK 139               ; Token 11:     ""
 CHAR ' '
 EQUB 0

 RTOK 138               ; Token 12:     ""
 CHAR ' '
 EQUB 0

 TWOK 'M', 'A'          ; Token 13:     ""
 TWOK 'I', 'N'
 CHAR 'L'
 CHAR 'Y'
 CHAR ' '
 EQUB 0

 CHAR 'U'               ; Token 14:     ""
 CHAR 'N'
 CHAR 'I'
 CHAR 'T'
 EQUB 0

 CHAR 'V'               ; Token 15:     ""
 CHAR 'I'
 CHAR 'E'
 CHAR 'W'
 CHAR ' '
 EQUB 0

 EQUB 0                 ; Token 16:     ""

 TWOK 'A', 'N'          ; Token 17:     ""
 TWOK 'A', 'R'
 CHAR 'C'
 CHAR 'H'
 CHAR 'Y'
 EQUB 0

 CHAR 'F'               ; Token 18:     ""
 CHAR 'E'
 CHAR 'U'
 CHAR 'D'
 CHAR 'A'
 CHAR 'L'
 EQUB 0

 CHAR 'M'               ; Token 19:     ""
 CHAR 'U'
 CHAR 'L'
 TWOK 'T', 'I'
 CHAR '-'
 CONT 6
 RTOK 2
 EQUB 0

 TWOK 'D', 'I'          ; Token 20:     ""
 CHAR 'C'
 CHAR 'T'
 TWOK 'A', 'T'
 TWOK 'O', 'R'
 RTOK 25
 EQUB 0

 RTOK 91                ; Token 21:     ""
 CHAR 'M'
 CHAR 'U'
 CHAR 'N'
 TWOK 'I', 'S'
 CHAR 'T'
 EQUB 0

 CHAR 'C'               ; Token 22:     ""
 TWOK 'O', 'N'
 CHAR 'F'
 TWOK 'E', 'D'
 TWOK 'E', 'R'
 CHAR 'A'
 CHAR 'C'
 CHAR 'Y'
 EQUB 0

 CHAR 'D'               ; Token 23:     ""
 CHAR 'E'
 CHAR 'M'
 CHAR 'O'
 CHAR 'C'
 TWOK 'R', 'A'
 CHAR 'C'
 CHAR 'Y'
 EQUB 0

 CHAR 'C'               ; Token 24:     ""
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

 CHAR 'S'               ; Token 25:     ""
 CHAR 'H'
 CHAR 'I'
 CHAR 'P'
 EQUB 0

 CHAR 'P'               ; Token 26:     ""
 RTOK 94
 CHAR 'D'
 CHAR 'U'
 CHAR 'C'
 CHAR 'T'
 EQUB 0

 CHAR ' '               ; Token 27:     ""
 TWOK 'L', 'A'
 CHAR 'S'
 TWOK 'E', 'R'
 EQUB 0

 CHAR 'H'               ; Token 28:     ""
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

 CHAR 'H'               ; Token 29:     ""
 CHAR 'Y'
 CHAR 'P'
 TWOK 'E', 'R'
 CHAR 'S'
 CHAR 'P'
 CHAR 'A'
 TWOK 'C', 'E'
 CHAR ' '
 EQUB 0

 CHAR 'S'               ; Token 30:     ""
 CHAR 'H'
 TWOK 'O', 'R'
 CHAR 'T'
 CHAR ' '
 RTOK 42
 RTOK 1
 EQUB 0

 TWOK 'D', 'I'          ; Token 31:     ""
 RTOK 43
 TWOK 'A', 'N'
 TWOK 'C', 'E'
 EQUB 0

 CHAR 'P'               ; Token 32:     ""
 CHAR 'O'
 CHAR 'P'
 CHAR 'U'
 CHAR 'L'
 TWOK 'A', 'T'
 CHAR 'I'
 TWOK 'O', 'N'
 EQUB 0

 CHAR 'T'               ; Token 33:     ""
 CHAR 'U'
 CHAR 'R'
 CHAR 'N'
 CHAR 'O'
 CHAR 'V'
 TWOK 'E', 'R'
 EQUB 0

 CHAR 'E'               ; Token 34:     ""
 CHAR 'C'
 TWOK 'O', 'N'
 CHAR 'O'
 CHAR 'M'
 CHAR 'Y'
 EQUB 0

 CHAR ' '               ; Token 35:     ""
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

 TWOK 'T', 'E'          ; Token 36:     ""
 CHAR 'C'
 CHAR 'H'
 CHAR '.'
 TWOK 'L', 'E'
 TWOK 'V', 'E'
 CHAR 'L'
 EQUB 0

 CHAR 'C'               ; Token 37:     ""
 CHAR 'A'
 CHAR 'S'
 CHAR 'H'
 EQUB 0

 CHAR ' '               ; Token 38:     ""
 TWOK 'B', 'I'
 CHAR 'L'
 CHAR 'L'
 CHAR 'I'
 TWOK 'O', 'N'
 EQUB 0

 RTOK 122               ; Token 39:     ""
 RTOK 1
 CONT 1
 EQUB 0

 CHAR 'T'               ; Token 40:     ""
 TWOK 'A', 'R'
 TWOK 'G', 'E'
 CHAR 'T'
 CHAR ' '
 CHAR 'L'
 CHAR 'O'
 RTOK 43
 EQUB 0

 RTOK 106               ; Token 41:     ""
 CHAR ' '
 CHAR 'J'
 CHAR 'A'
 CHAR 'M'
 CHAR 'M'
 TWOK 'E', 'D'
 EQUB 0

 TWOK 'R', 'A'          ; Token 42:     ""
 CHAR 'N'
 TWOK 'G', 'E'
 EQUB 0

 CHAR 'S'               ; Token 43:     ""
 CHAR 'T'
 EQUB 0

 EQUB 0                 ; Token 44:     ""

 CHAR 'S'               ; Token 45:     ""
 CHAR 'E'
 CHAR 'L'
 CHAR 'L'
 EQUB 0

 CHAR ' '               ; Token 46:     ""
 CHAR 'C'
 TWOK 'A', 'R'
 CHAR 'G'
 CHAR 'O'
 CONT 6
 EQUB 0

 CHAR 'E'               ; Token 47:     ""
 TWOK 'Q', 'U'
 CHAR 'I'
 CHAR 'P'
 CHAR ' '
 RTOK 25
 EQUB 0

 CHAR 'F'               ; Token 48:     ""
 CHAR 'O'
 CHAR 'O'
 CHAR 'D'
 EQUB 0

 TWOK 'T', 'E'          ; Token 49:     ""
 CHAR 'X'
 TWOK 'T', 'I'
 TWOK 'L', 'E'
 CHAR 'S'
 EQUB 0

 TWOK 'R', 'A'          ; Token 50:     ""
 TWOK 'D', 'I'
 CHAR 'O'
 CHAR 'A'
 CHAR 'C'
 TWOK 'T', 'I'
 CHAR 'V'
 TWOK 'E', 'S'
 EQUB 0

 RTOK 94                ; Token 51:     ""
 CHAR 'B'
 CHAR 'O'
 CHAR 'T'
 CHAR ' '
 CHAR 'S'
 TWOK 'L', 'A'
 CHAR 'V'
 TWOK 'E', 'S'
 EQUB 0

 TWOK 'B', 'E'          ; Token 52:     ""
 CHAR 'V'
 TWOK 'E', 'R'
 CHAR 'A'
 TWOK 'G', 'E'
 CHAR 'S'
 EQUB 0

 CHAR 'L'               ; Token 53:     ""
 CHAR 'U'
 CHAR 'X'
 CHAR 'U'
 TWOK 'R', 'I'
 TWOK 'E', 'S'
 EQUB 0

 CHAR 'R'               ; Token 54:     ""
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

 RTOK 91                ; Token 55:     ""
 CHAR 'P'
 CHAR 'U'
 CHAR 'T'
 TWOK 'E', 'R'
 CHAR 'S'
 EQUB 0

 TWOK 'M', 'A'          ; Token 56:     ""
 CHAR 'C'
 CHAR 'H'
 TWOK 'I', 'N'
 TWOK 'E', 'R'
 CHAR 'Y'
 EQUB 0

 RTOK 124               ; Token 57:     ""
 CHAR 'O'
 CHAR 'Y'
 CHAR 'S'
 EQUB 0

 CHAR 'F'               ; Token 58:     ""
 CHAR 'I'
 RTOK 97
 CHAR 'M'
 CHAR 'S'
 EQUB 0

 CHAR 'F'               ; Token 59:     ""
 CHAR 'U'
 CHAR 'R'
 CHAR 'S'
 EQUB 0

 CHAR 'M'               ; Token 60:     ""
 TWOK 'I', 'N'
 TWOK 'E', 'R'
 CHAR 'A'
 CHAR 'L'
 CHAR 'S'
 EQUB 0

 CHAR 'G'               ; Token 61:     ""
 CHAR 'O'
 CHAR 'L'
 CHAR 'D'
 EQUB 0

 CHAR 'P'               ; Token 62:     ""
 CHAR 'L'
 TWOK 'A', 'T'
 TWOK 'I', 'N'
 CHAR 'U'
 CHAR 'M'
 EQUB 0

 TWOK 'G', 'E'          ; Token 63:     ""
 CHAR 'M'
 CHAR '-'
 RTOK 43
 TWOK 'O', 'N'
 TWOK 'E', 'S'
 EQUB 0

 CHAR 'A'               ; Token 64:     ""
 CHAR 'L'
 CHAR 'I'
 TWOK 'E', 'N'
 CHAR ' '
 RTOK 127
 CHAR 'S'
 EQUB 0

 EQUB 0                 ; Token 65:     ""

 CHAR ' '               ; Token 66:     ""
 CHAR 'C'
 CHAR 'R'
 EQUB 0

 EQUB 0                 ; Token 67:     ""

 EQUB 0                 ; Token 68:     ""

 EQUB 0                 ; Token 69:     ""

 CHAR 'G'               ; Token 70:     ""
 TWOK 'R', 'E'
 TWOK 'E', 'N'
 EQUB 0

 TWOK 'R', 'E'          ; Token 71:     ""
 CHAR 'D'
 EQUB 0

 CHAR 'Y'               ; Token 72:     ""
 CHAR 'E'
 CHAR 'L'
 CHAR 'L'
 CHAR 'O'
 CHAR 'W'
 EQUB 0

 CHAR 'B'               ; Token 73:     ""
 CHAR 'L'
 CHAR 'U'
 CHAR 'E'
 EQUB 0

 CHAR 'B'               ; Token 74:     ""
 TWOK 'L', 'A'
 CHAR 'C'
 CHAR 'K'
 EQUB 0

 RTOK 136               ; Token 75:     ""
 EQUB 0

 CHAR 'S'               ; Token 76:     ""
 CHAR 'L'
 CHAR 'I'
 CHAR 'M'
 CHAR 'Y'
 EQUB 0

 CHAR 'B'               ; Token 77:     ""
 CHAR 'U'
 CHAR 'G'
 CHAR '-'
 CHAR 'E'
 CHAR 'Y'
 TWOK 'E', 'D'
 EQUB 0

 CHAR 'H'               ; Token 78:     ""
 TWOK 'O', 'R'
 CHAR 'N'
 TWOK 'E', 'D'
 EQUB 0

 CHAR 'B'               ; Token 79:     ""
 TWOK 'O', 'N'
 CHAR 'Y'
 EQUB 0

 CHAR 'F'               ; Token 80:     ""
 TWOK 'A', 'T'
 EQUB 0

 CHAR 'F'               ; Token 81:     ""
 CHAR 'U'
 CHAR 'R'
 CHAR 'R'
 CHAR 'Y'
 EQUB 0

 RTOK 94                ; Token 82:     ""
 CHAR 'D'
 TWOK 'E', 'N'
 CHAR 'T'
 CHAR 'S'
 EQUB 0

 CHAR 'F'               ; Token 83:     ""
 RTOK 94
 CHAR 'G'
 CHAR 'S'
 EQUB 0

 CHAR 'L'               ; Token 84:     ""
 CHAR 'I'
 TWOK 'Z', 'A'
 CHAR 'R'
 CHAR 'D'
 CHAR 'S'
 EQUB 0

 CHAR 'L'               ; Token 85:     ""
 CHAR 'O'
 CHAR 'B'
 RTOK 43
 TWOK 'E', 'R'
 CHAR 'S'
 EQUB 0

 TWOK 'B', 'I'          ; Token 86:     ""
 CHAR 'R'
 CHAR 'D'
 CHAR 'S'
 EQUB 0

 CHAR 'H'               ; Token 87:     ""
 CHAR 'U'
 TWOK 'M', 'A'
 CHAR 'N'
 CHAR 'O'
 CHAR 'I'
 CHAR 'D'
 CHAR 'S'
 EQUB 0

 CHAR 'F'               ; Token 88:     ""
 CHAR 'E'
 CHAR 'L'
 TWOK 'I', 'N'
 TWOK 'E', 'S'
 EQUB 0

 TWOK 'I', 'N'          ; Token 89:     ""
 CHAR 'S'
 CHAR 'E'
 CHAR 'C'
 CHAR 'T'
 CHAR 'S'
 EQUB 0

 TWOK 'R', 'A'          ; Token 90:     ""
 TWOK 'D', 'I'
 TWOK 'U', 'S'
 EQUB 0

 CHAR 'C'               ; Token 91:     ""
 CHAR 'O'
 CHAR 'M'
 EQUB 0

 RTOK 91                ; Token 92:     ""
 TWOK 'M', 'A'
 CHAR 'N'
 CHAR 'D'
 TWOK 'E', 'R'
 EQUB 0

 CHAR ' '               ; Token 93:     ""
 CHAR 'D'
 TWOK 'E', 'S'
 CHAR 'T'
 RTOK 94
 CHAR 'Y'
 TWOK 'E', 'D'
 EQUB 0

 CHAR 'R'               ; Token 94:     ""
 CHAR 'O'
 EQUB 0

 RTOK 26                ; Token 95:     ""
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

 CHAR 'F'               ; Token 96:     ""
 CHAR 'R'
 TWOK 'O', 'N'
 CHAR 'T'
 EQUB 0

 TWOK 'R', 'E'          ; Token 97:     ""
 TWOK 'A', 'R'
 EQUB 0

 TWOK 'L', 'E'          ; Token 98:     ""
 CHAR 'F'
 CHAR 'T'
 EQUB 0

 TWOK 'R', 'I'          ; Token 99:     ""
 CHAR 'G'
 CHAR 'H'
 CHAR 'T'
 EQUB 0

 RTOK 121               ; Token 100:    ""
 CHAR 'L'
 CHAR 'O'
 CHAR 'W'
 CONT 7
 EQUB 0

 RTOK 99                ; Token 101:    ""
 RTOK 131
 RTOK 92
 CHAR '!'
 EQUB 0

 CHAR 'E'               ; Token 102:    ""
 CHAR 'X'
 CHAR 'T'
 TWOK 'R', 'A'
 CHAR ' '
 EQUB 0

 CHAR 'P'               ; Token 103:    ""
 CHAR 'U'
 CHAR 'L'
 CHAR 'S'
 CHAR 'E'
 RTOK 27
 EQUB 0

 TWOK 'B', 'E'          ; Token 104:    ""
 CHAR 'A'
 CHAR 'M'
 RTOK 27
 EQUB 0

 CHAR 'F'               ; Token 105:    ""
 CHAR 'U'
 CHAR 'E'
 CHAR 'L'
 EQUB 0

 CHAR 'M'               ; Token 106:    ""
 TWOK 'I', 'S'
 CHAR 'S'
 CHAR 'I'
 TWOK 'L', 'E'
 EQUB 0

 CHAR 'L'               ; Token 107:    ""
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

 CHAR 'E'               ; Token 108:    ""
 CHAR '.'
 CHAR 'C'
 CHAR '.'
 CHAR 'M'
 CHAR '.'
 RTOK 5
 EQUB 0

 RTOK 102               ; Token 109:    ""
 RTOK 103
 CHAR 'S'
 EQUB 0

 RTOK 102               ; Token 110:    ""
 RTOK 104
 CHAR 'S'
 EQUB 0

 RTOK 105               ; Token 111:    ""
 CHAR ' '
 CHAR 'S'
 CHAR 'C'
 CHAR 'O'
 CHAR 'O'
 CHAR 'P'
 CHAR 'S'
 EQUB 0

 TWOK 'E', 'S'          ; Token 112:    ""
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

 RTOK 121               ; Token 113:    ""
 CHAR 'B'
 CHAR 'O'
 CHAR 'M'
 CHAR 'B'
 EQUB 0

 RTOK 121               ; Token 114:    ""
 RTOK 14
 EQUB 0

 CHAR 'D'               ; Token 115:    ""
 CHAR 'O'
 CHAR 'C'
 CHAR 'K'
 TWOK 'I', 'N'
 CHAR 'G'
 CHAR ' '
 RTOK 55
 EQUB 0

 RTOK 122               ; Token 116:    ""
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

 CHAR 'M'               ; Token 117:    ""
 CHAR 'I'
 CHAR 'L'
 CHAR 'I'
 CHAR 'T'
 TWOK 'A', 'R'
 CHAR 'Y'
 RTOK 27
 EQUB 0

 CHAR 'M'               ; Token 118:    ""
 TWOK 'I', 'N'
 TWOK 'I', 'N'
 CHAR 'G'
 RTOK 27
 EQUB 0

 RTOK 37                ; Token 119:    ""
 CHAR ':'
 CONT 0
 EQUB 0

 TWOK 'I', 'N'          ; Token 120:    ""
 RTOK 91
 TWOK 'I', 'N'
 CHAR 'G'
 CHAR ' '
 RTOK 106
 EQUB 0

 TWOK 'E', 'N'          ; Token 121:    ""
 TWOK 'E', 'R'
 CHAR 'G'
 CHAR 'Y'
 CHAR ' '
 EQUB 0

 CHAR 'G'               ; Token 122:    ""
 CHAR 'A'
 TWOK 'L', 'A'
 CHAR 'C'
 TWOK 'T', 'I'
 CHAR 'C'
 EQUB 0

 RTOK 115               ; Token 123:    ""
 RTOK 131
 EQUB 0

 CHAR 'A'               ; Token 124:    ""
 CHAR 'L'
 CHAR 'L'
 EQUB 0

 TWOK 'L', 'E'          ; Token 125:    ""
 CHAR 'G'
 CHAR 'A'
 CHAR 'L'
 CHAR ' '
 RTOK 43
 TWOK 'A', 'T'
 TWOK 'U', 'S'
 CHAR ':'
 EQUB 0

 RTOK 92                ; Token 126:    ""
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

 CHAR 'I'               ; Token 127:    ""
 TWOK 'T', 'E'
 CHAR 'M'
 EQUB 0

 EQUB 0                 ; Token 128:    ""

 CHAR 'L'               ; Token 129:    ""
 CHAR 'L'
 EQUB 0

 CHAR 'R'               ; Token 130:    ""
 TWOK 'A', 'T'
 TWOK 'I', 'N'
 CHAR 'G'
 EQUB 0

 CHAR ' '               ; Token 131:    ""
 TWOK 'O', 'N'
 CHAR ' '
 EQUB 0

 CONT 12                ; Token 132:    ""
 CHAR 'E'
 TWOK 'Q', 'U'
 CHAR 'I'
 CHAR 'P'
 CHAR 'M'
 TWOK 'E', 'N'
 CHAR 'T'
 CHAR ':'
 EQUB 0

 CHAR 'C'               ; Token 133:    ""
 TWOK 'L', 'E'
 TWOK 'A', 'N'
 EQUB 0

 CHAR 'O'               ; Token 134:    ""
 CHAR 'F'
 CHAR 'F'
 TWOK 'E', 'N'
 CHAR 'D'
 TWOK 'E', 'R'
 EQUB 0

 CHAR 'F'               ; Token 135:    ""
 CHAR 'U'
 CHAR 'G'
 CHAR 'I'
 TWOK 'T', 'I'
 TWOK 'V', 'E'
 EQUB 0

 CHAR 'H'               ; Token 136:    ""
 TWOK 'A', 'R'
 CHAR 'M'
 TWOK 'L', 'E'
 CHAR 'S'
 CHAR 'S'
 EQUB 0

 CHAR 'M'               ; Token 137:    ""
 CHAR 'O'
 RTOK 43
 CHAR 'L'
 CHAR 'Y'
 CHAR ' '
 RTOK 136
 EQUB 0

 CHAR 'P'               ; Token 138:    ""
 CHAR 'O'
 TWOK 'O', 'R'
 EQUB 0

 CHAR 'A'               ; Token 139:    ""
 CHAR 'V'
 TWOK 'E', 'R'
 CHAR 'A'
 TWOK 'G', 'E'
 EQUB 0

 CHAR 'A'               ; Token 140:    ""
 CHAR 'B'
 CHAR 'O'
 TWOK 'V', 'E'
 CHAR ' '
 RTOK 139
 EQUB 0

 RTOK 91                ; Token 141:    ""
 CHAR 'P'
 CHAR 'E'
 CHAR 'T'
 TWOK 'E', 'N'
 CHAR 'T'
 EQUB 0

 CHAR 'D'               ; Token 142:    ""
 TWOK 'A', 'N'
 TWOK 'G', 'E'
 RTOK 94
 TWOK 'U', 'S'
 EQUB 0

 CHAR 'D'               ; Token 143:    ""
 CHAR 'E'
 CHAR 'A'
 CHAR 'D'
 CHAR 'L'
 CHAR 'Y'
 EQUB 0

 CHAR '-'               ; Token 144:    ""
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

 CHAR 'P'               ; Token 145:    ""
 CHAR 'R'
 TWOK 'E', 'S'
 TWOK 'E', 'N'
 CHAR 'T'
 EQUB 0

 CONT 8                 ; Token 146:    ""
 CHAR 'G'
 CHAR 'A'
 CHAR 'M'
 CHAR 'E'
 CHAR ' '
 CHAR 'O'
 CHAR 'V'
 TWOK 'E', 'R'
 EQUB 0

 CHAR '6'               ; Token 147:    ""
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

 EQUB 0                 ; Token 148:    ""

; ******************************************************************************
;
;       Name: QQ18_DE
;       Type: Variable
;   Category: Text
;    Summary: The recursive token table for tokens 0-148 (German)
;  Deep dive: Printing text tokens
;
; ******************************************************************************

.QQ18_DE

 RTOK 105               ; Token 0:      ""
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

 CHAR ' '               ; Token 1:      ""
 CHAR 'K'
 TWOK 'A', 'R'
 TWOK 'T', 'E'
 EQUB 0

 TWOK 'R', 'E'          ; Token 2:      ""
 CHAR 'G'
 CHAR 'I'
 TWOK 'E', 'R'
 CHAR 'U'
 CHAR 'N'
 CHAR 'G'
 EQUB 0

 CHAR 'D'               ; Token 3:      ""
 TWOK 'A', 'T'
 TWOK 'E', 'N'
 CHAR ' '
 CHAR 'E'
 TWOK 'I', 'N'
 CHAR ' '
 CONT 3
 EQUB 0

 TWOK 'I', 'N'          ; Token 4:      ""
 CHAR 'H'
 CHAR 'A'
 CHAR 'L'
 CHAR 'T'
 CONT 12
 EQUB 0

 CONT 6                 ; Token 5:      ""
 CHAR 'S'
 CHAR 'Y'
 CHAR 'S'
 TWOK 'T', 'E'
 CHAR 'M'
 EQUB 0

 CONT 6                 ; Token 6:      ""
 CHAR 'P'
 TWOK 'R', 'E'
 TWOK 'I', 'S'
 EQUB 0

 CONT 2                 ; Token 7:      ""
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

 TWOK 'I', 'N'          ; Token 8:      ""
 CHAR 'D'
 TWOK 'U', 'S'
 CHAR 'T'
 TWOK 'R', 'I'
 CHAR 'E'
 EQUB 0

 CHAR 'A'               ; Token 9:      ""
 CHAR 'G'
 TWOK 'R', 'I'
 CHAR 'K'
 CHAR 'U'
 CHAR 'L'
 CHAR 'T'
 CHAR 'U'
 CHAR 'R'
 EQUB 0

 TWOK 'R', 'E'          ; Token 10:     ""
 CHAR 'I'
 CHAR 'C'
 CHAR 'H'
 CHAR 'E'
 CHAR ' '
 EQUB 0

 CHAR 'M'               ; Token 11:     ""
 CHAR 'I'
 CHAR 'T'
 TWOK 'T', 'E'
 CHAR 'L'
 CHAR 'M'
 CHAR ' '
 EQUB 0

 RTOK 138               ; Token 12:     ""
 CHAR 'E'
 CHAR ' '
 EQUB 0

 CHAR 'H'               ; Token 13:     ""
 CHAR 'A'
 CHAR 'U'
 CHAR 'P'
 CHAR 'T'
 CHAR 'S'
 CHAR ' '
 EQUB 0

 CHAR 'E'               ; Token 14:     ""
 TWOK 'I', 'N'
 CHAR 'H'
 CHAR 'E'
 CHAR 'I'
 CHAR 'T'
 EQUB 0

 TWOK 'A', 'N'          ; Token 15:     ""
 CHAR 'S'
 CHAR 'I'
 CHAR 'C'
 CHAR 'H'
 CHAR 'T'
 EQUB 0

 RTOK 44                ; Token 16:     ""
 CHAR ' '
 CHAR 'S'
 CHAR 'E'
 CHAR 'H'
 TWOK 'E', 'N'
 CHAR ' '
 EQUB 0

 TWOK 'A', 'N'          ; Token 17:     ""
 TWOK 'A', 'R'
 CHAR 'C'
 CHAR 'H'
 CHAR 'I'
 CHAR 'E'
 EQUB 0

 CHAR 'F'               ; Token 18:     ""
 CHAR 'E'
 CHAR 'U'
 CHAR 'D'
 CHAR 'A'
 CHAR 'L'
 RTOK 43
 CHAR 'A'
 TWOK 'A', 'T'
 EQUB 0

 CHAR 'M'               ; Token 19:     ""
 CHAR 'E'
 CHAR 'H'
 CHAR 'R'
 CHAR 'F'
 CHAR 'A'
 CHAR 'C'
 CHAR 'H'
 RTOK 2
 EQUB 0

 TWOK 'D', 'I'          ; Token 21:     ""
 CHAR 'K'
 CHAR 'T'
 TWOK 'A', 'T'
 CHAR 'U'
 CHAR 'R'
 EQUB 0

 CHAR 'K'               ; Token 22:     ""
 CHAR 'O'
 CHAR 'M'
 CHAR 'M'
 CHAR 'U'
 CHAR 'N'
 TWOK 'I', 'S'
 CHAR 'T'
 TWOK 'E', 'N'
 EQUB 0

 CHAR 'K'               ; Token 2x:     ""
 TWOK 'O', 'N'
 CHAR 'F'
 CHAR '\'
 CHAR 'D'
 TWOK 'E', 'R'
 TWOK 'A', 'T'
 CHAR 'I'
 TWOK 'O', 'N'
 EQUB 0

 CHAR 'D'               ; Token 23:     ""
 CHAR 'E'
 CHAR 'M'
 CHAR 'O'
 CHAR 'K'
 CHAR 'R'
 TWOK 'A', 'T'
 CHAR 'I'
 CHAR 'E'
 EQUB 0

 CHAR 'K'               ; Token 24:     ""
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

 CHAR 'S'               ; Token 25:     ""
 CHAR 'C'
 CHAR 'H'
 CHAR 'I'
 CHAR 'F'
 CHAR 'F'
 EQUB 0

 CHAR 'P'               ; Token 26:     ""
 RTOK 94
 CHAR 'D'
 CHAR 'U'
 CHAR 'K'
 CHAR 'T'
 EQUB 0

 CHAR ' '               ; Token 27:     ""
 TWOK 'L', 'A'
 CHAR 'S'
 TWOK 'E', 'R'
 EQUB 0

 CHAR 'M'               ; Token 28:     ""
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

 CHAR 'H'               ; Token 29:     ""
 CHAR 'Y'
 CHAR 'P'
 TWOK 'E', 'R'
 TWOK 'R', 'A'
 CHAR 'U'
 CHAR 'M'
 CHAR ' '
 EQUB 0

 CHAR '\'               ; Token 30:     ""
 CHAR 'R'
 CHAR 'T'
 CHAR 'L'
 CHAR 'I'
 CHAR 'C'
 CHAR 'H'
 CHAR 'E'
 RTOK 1
 EQUB 0

 TWOK 'E', 'N'          ; Token 31:     ""
 CHAR 'T'
 CHAR 'F'
 TWOK 'E', 'R'
 CHAR 'N'
 CHAR 'U'
 CHAR 'N'
 CHAR 'G'
 EQUB 0

 TWOK 'B', 'E'          ; Token 32:     ""
 CHAR 'V'
 CHAR '\'
 CHAR 'L'
 CHAR 'K'
 TWOK 'E', 'R'
 CHAR 'U'
 CHAR 'N'
 CHAR 'G'
 EQUB 0

 CHAR 'U'               ; Token 33:     ""
 CHAR 'M'
 CHAR 'S'
 TWOK 'A', 'T'
 CHAR 'Z'
 EQUB 0

 CHAR 'W'               ; Token 34:     ""
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

 CHAR ' '               ; Token 35:     ""
 CHAR 'L'
 CHAR 'I'
 CHAR 'C'
 CHAR 'H'
 CHAR 'T'
 CHAR 'J'
 EQUB 0

 TWOK 'T', 'E'          ; Token 36:     ""
 CHAR 'C'
 CHAR 'H'
 CHAR '.'
 CHAR 'N'
 CHAR 'I'
 TWOK 'V', 'E'
 CHAR 'A'
 CHAR 'U'
 EQUB 0

 CHAR 'B'               ; Token 37:     ""
 TWOK 'A', 'R'
 TWOK 'G', 'E'
 CHAR 'L'
 CHAR 'D'
 EQUB 0

 CHAR ' '               ; Token 38:     ""
 TWOK 'B', 'I'
 CHAR 'L'
 CHAR 'L'
 CHAR '.'
 EQUB 0

 RTOK 122               ; Token 39:     ""
 CHAR 'E'
 RTOK 1
 CONT 1
 EQUB 0

 CHAR 'Z'               ; Token 40:     ""
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

 RTOK 106               ; Token 41:     ""
 CHAR ' '
 CHAR 'K'
 TWOK 'L', 'E'
 CHAR 'M'
 CHAR 'M'
 CHAR 'T'
 CHAR ' '
 EQUB 0

 RTOK 31                ; Token 42:     ""
 EQUB 0

 CHAR 'S'               ; Token 43:     ""
 CHAR 'T'
 EQUB 0

 CHAR 'M'               ; Token 44:     ""
 TWOK 'E', 'N'
 TWOK 'G', 'E'
 EQUB 0

 CHAR 'V'               ; Token 45:     ""
 TWOK 'E', 'R'
 CHAR 'K'
 CHAR 'A'
 CHAR 'U'
 CHAR 'F'
 TWOK 'E', 'N'
 CHAR ' '
 CHAR '"'
 EQUB 0

 CHAR 'K'               ; Token 46:     ""
 TWOK 'A', 'R'
 CHAR 'G'
 CHAR 'O'
 CONT 6
 EQUB 0

 RTOK 25                ; Token 47:     ""
 CHAR ' '
 CHAR 'A'
 TWOK 'U', 'S'
 CHAR 'R'
 CHAR ']'
 RTOK 43
 TWOK 'E', 'N'
 EQUB 0

 CHAR 'N'               ; Token 48:     ""
 CHAR 'A'
 CHAR 'H'
 CHAR 'R'
 CHAR 'U'
 CHAR 'N'
 CHAR 'G'
 EQUB 0

 TWOK 'T', 'E'          ; Token 49:     ""
 CHAR 'X'
 TWOK 'T', 'I'
 CHAR 'L'
 CHAR 'I'
 TWOK 'E', 'N'
 EQUB 0

 TWOK 'R', 'A'          ; Token 50:     ""
 TWOK 'D', 'I'
 CHAR 'O'
 CHAR 'A'
 CHAR 'K'
 TWOK 'T', 'I'
 CHAR 'V'
 TWOK 'E', 'S'
 EQUB 0

 RTOK 94                ; Token 51:     ""
 CHAR 'B'
 CHAR 'O'
 CHAR 'T'
 CHAR 'S'
 CHAR 'K'
 TWOK 'L', 'A'
 CHAR 'V'
 TWOK 'E', 'N'
 EQUB 0

 TWOK 'G', 'E'          ; Token 52:     ""
 CHAR 'T'
 CHAR 'R'
 CHAR '['
 CHAR 'N'
 CHAR 'K'
 CHAR 'E'
 EQUB 0

 CHAR 'L'               ; Token 53:     ""
 CHAR 'U'
 CHAR 'X'
 TWOK 'U', 'S'
 CHAR 'G'
 CHAR ']'
 CHAR 'T'
 TWOK 'E', 'R'
 EQUB 0

 CHAR 'S'               ; Token 54:     ""
 CHAR 'E'
 CHAR 'L'
 CHAR 'T'
 TWOK 'E', 'N'
 TWOK 'E', 'S'
 EQUB 0

 RTOK 91                ; Token 55:     ""
 CHAR 'P'
 CHAR 'U'
 CHAR 'T'
 TWOK 'E', 'R'
 EQUB 0

 TWOK 'M', 'A'          ; Token 56:     ""
 CHAR 'S'
 CHAR 'C'
 CHAR 'H'
 TWOK 'I', 'N'
 TWOK 'E', 'N'
 EQUB 0

 TWOK 'L', 'E'          ; Token 57:     ""
 CHAR 'G'
 CHAR 'I'
 TWOK 'E', 'R'
 CHAR 'U'
 CHAR 'N'
 TWOK 'G', 'E'
 CHAR 'N'
 EQUB 0

 CHAR 'F'               ; Token 58:     ""
 CHAR 'E'
 CHAR 'U'
 TWOK 'E', 'R'
 CHAR 'W'
 CHAR 'A'
 CHAR 'F'
 CHAR 'F'
 TWOK 'E', 'N'
 EQUB 0

 CHAR 'P'               ; Token 59:     ""
 CHAR 'E'
 CHAR 'L'
 CHAR 'Z'
 CHAR 'E'
 EQUB 0

 CHAR 'M'               ; Token 60:     ""
 TWOK 'I', 'N'
 TWOK 'E', 'R'
 CHAR 'A'
 CHAR 'L'
 CHAR 'I'
 TWOK 'E', 'N'
 EQUB 0

 CHAR 'G'               ; Token 61:     ""
 CHAR 'O'
 CHAR 'L'
 CHAR 'D'
 EQUB 0

 CHAR 'P'               ; Token 62:     ""
 CHAR 'L'
 TWOK 'A', 'T'
 TWOK 'I', 'N'
 EQUB 0

 TWOK 'E', 'D'          ; Token 63:     ""
 CHAR 'E'
 CHAR 'L'
 CHAR 'S'
 TWOK 'T', 'E'
 TWOK 'I', 'N'
 CHAR 'E'
 EQUB 0

 CHAR 'F'               ; Token 64:     ""
 TWOK 'R', 'E'
 CHAR 'M'
 CHAR 'D'
 CHAR 'W'
 TWOK 'A', 'R'
 TWOK 'E', 'N'
 EQUB 0

 EQUB 0                 ; Token 65:     ""

 CHAR ' '               ; Token 66:     ""
 CHAR 'C'
 CHAR 'R'
 EQUB 0

 CHAR 'G'               ; Token 67:     ""
 RTOK 94
 CHAR '^'
 CHAR 'E'
 EQUB 0

 RTOK 142               ; Token 68:     ""
 CHAR 'E'
 EQUB 0

 CHAR 'K'               ; Token 69:     ""
 TWOK 'L', 'E'
 TWOK 'I', 'N'
 CHAR 'E'
 EQUB 0

 CHAR 'G'               ; Token 70:     ""
 CHAR 'R'
 CHAR ']'
 CHAR 'N'
 CHAR 'E'
 EQUB 0

 RTOK 94                ; Token 71:     ""
 TWOK 'T', 'E'
 EQUB 0

 TWOK 'G', 'E'          ; Token 72:     ""
 CHAR 'L'
 TWOK 'B', 'E'
 EQUB 0

 CHAR 'B'               ; Token 73:     ""
 TWOK 'L', 'A'
 CHAR 'U'
 CHAR 'E'
 EQUB 0

 CHAR 'S'               ; Token 74:     ""
 CHAR 'C'
 CHAR 'H'
 CHAR 'W'
 TWOK 'A', 'R'
 CHAR 'Z'
 CHAR 'E'
 EQUB 0

 RTOK 136               ; Token 75:     ""
 CHAR 'E'
 EQUB 0

 CHAR 'G'               ; Token 76:     ""
 CHAR 'L'
 CHAR 'I'
 CHAR 'T'
 CHAR 'S'
 CHAR 'C'
 CHAR 'H'
 CHAR 'I'
 TWOK 'G', 'E'
 EQUB 0

 CHAR 'W'               ; Token 77:     ""
 TWOK 'A', 'N'
 CHAR 'Z'
 TWOK 'E', 'N'
 CHAR '['
 CHAR 'U'
 CHAR 'G'
 CHAR 'I'
 TWOK 'G', 'E'
 EQUB 0

 TWOK 'G', 'E'          ; Token 78:     ""
 CHAR 'H'
 CHAR '\'
 CHAR 'R'
 CHAR 'N'
 TWOK 'T', 'E'
 EQUB 0

 CHAR 'K'               ; Token 79:     ""
 CHAR 'N'
 CHAR 'O'
 CHAR 'C'
 CHAR 'H'
 CHAR 'I'
 TWOK 'G', 'E'
 EQUB 0

 TWOK 'D', 'I'          ; Token 80:     ""
 CHAR 'C'
 CHAR 'K'
 CHAR 'E'
 EQUB 0

 CHAR 'P'               ; Token 81:     ""
 CHAR 'E'
 CHAR 'L'
 CHAR 'Z'
 CHAR 'I'
 TWOK 'G', 'E'
 EQUB 0

 CONT 6                 ; Token 82:     ""
 CHAR 'N'
 CHAR 'A'
 TWOK 'G', 'E'
 TWOK 'T', 'I'
 CHAR 'E'
 TWOK 'R', 'E'
 EQUB 0

 CONT 6                 ; Token 83:     ""
 CHAR 'F'
 CHAR 'R'
 CHAR '\'
 CHAR 'S'
 CHAR 'C'
 CHAR 'H'
 CHAR 'E'
 EQUB 0

 CONT 6                 ; Token 84:     ""
 CHAR 'E'
 CHAR 'C'
 CHAR 'H'
 CHAR 'S'
 TWOK 'E', 'N'
 EQUB 0

 CONT 6                 ; Token 85:     ""
 CHAR 'H'
 CHAR 'U'
 CHAR 'M'
 CHAR 'M'
 TWOK 'E', 'R'
 EQUB 0

 CONT 6                 ; Token 86:     ""
 CHAR 'V'
 CHAR '\'
 TWOK 'G', 'E'
 CHAR 'L'
 EQUB 0

 CONT 6                 ; Token 87:     ""
 CHAR 'H'
 CHAR 'U'
 TWOK 'M', 'A'
 CHAR 'N'
 CHAR 'O'
 CHAR 'I'
 CHAR 'D'
 CHAR 'S'
 EQUB 0

 CONT 6                 ; Token 88:     ""
 CHAR 'K'
 TWOK 'A', 'T'
 CHAR 'Z'
 TWOK 'E', 'N'
 EQUB 0

 CONT 6                 ; Token 89:     ""
 TWOK 'I', 'N'
 CHAR 'S'
 CHAR 'E'
 CHAR 'K'
 CHAR 'T'
 TWOK 'E', 'N'
 EQUB 0

 TWOK 'R', 'A'          ; Token 90:     ""
 TWOK 'D', 'I'
 TWOK 'U', 'S'
 EQUB 0

 CHAR 'C'               ; Token 91:     ""
 CHAR 'O'
 CHAR 'M'
 EQUB 0

 CHAR 'K'               ; Token 92:     ""
 CHAR 'O'
 CHAR 'M'
 TWOK 'M', 'A'
 CHAR 'N'
 CHAR 'D'
 TWOK 'A', 'N'
 CHAR 'T'
 EQUB 0

 CHAR ' '               ; Token 93:     ""
 CHAR 'V'
 TWOK 'E', 'R'
 CHAR 'N'
 CHAR 'I'
 CHAR 'C'
 CHAR 'H'
 TWOK 'T', 'E'
 CHAR 'T'
 EQUB 0

 CHAR 'R'               ; Token 94:     ""
 CHAR 'O'
 EQUB 0

 RTOK 26                ; Token 95:     ""
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

 CHAR 'V'               ; Token 96:     ""
 TWOK 'O', 'R'
 CHAR 'N'
 EQUB 0

 CHAR 'H'               ; Token 97:     ""
 TWOK 'I', 'N'
 CHAR 'T'
 TWOK 'E', 'N'
 EQUB 0

 CHAR 'L'               ; Token 98:     ""
 TWOK 'I', 'N'
 CHAR 'K'
 CHAR 'S'
 EQUB 0

 TWOK 'R', 'E'          ; Token 99:     ""
 CHAR 'C'
 CHAR 'H'
 CHAR 'T'
 CHAR 'S'
 EQUB 0

 RTOK 121               ; Token 100:    ""
 CHAR 'N'
 CHAR 'I'
 TWOK 'E', 'D'
 TWOK 'R', 'I'
 CHAR 'G'
 CHAR ' '
 CONT 7
 EQUB 0

 CHAR 'B'               ; Token 101:    ""
 TWOK 'R', 'A'
 CHAR 'V'
 CHAR 'O'
 CHAR ' '
 RTOK 92
 CHAR '!'
 EQUB 0

 CHAR 'E'               ; Token 102:    ""
 CHAR 'X'
 CHAR 'T'
 TWOK 'R', 'A'
 CHAR ' '
 EQUB 0

 CHAR 'P'               ; Token 103:    ""
 CHAR 'U'
 CHAR 'L'
 CHAR 'S'
 TWOK 'L', 'A'
 CHAR 'S'
 TWOK 'E', 'R'
 EQUB 0

 RTOK 43                ; Token 104:    ""
 TWOK 'R', 'A'
 CHAR 'H'
 TWOK 'L', 'E'
 CHAR 'N'
 TWOK 'L', 'A'
 CHAR 'S'
 TWOK 'E', 'R'
 EQUB 0

 CHAR 'T'               ; Token 105:    ""
 TWOK 'R', 'E'
 CHAR 'I'
 CHAR 'B'
 RTOK 43
 CHAR 'O'
 CHAR 'F'
 CHAR 'F'
 EQUB 0

 TWOK 'R', 'A'          ; Token 106:    ""
 CHAR 'K'
 CHAR 'E'
 TWOK 'T', 'E'
 EQUB 0

 CHAR 'G'               ; Token 107:    ""
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

 CHAR 'E'               ; Token 108:    ""
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

 RTOK 102               ; Token 109:    ""
 RTOK 103
 EQUB 0

 RTOK 102               ; Token 110:    ""
 RTOK 104
 EQUB 0

 RTOK 105               ; Token 111:    ""
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

 CHAR 'F'               ; Token 112:    ""
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

 TWOK 'E', 'N'          ; Token 113:    ""
 TWOK 'E', 'R'
 CHAR 'G'
 CHAR 'I'
 CHAR 'E'
 CHAR 'B'
 CHAR 'O'
 CHAR 'M'
 TWOK 'B', 'E'
 EQUB 0

 TWOK 'E', 'N'          ; Token 114:    ""
 TWOK 'E', 'R'
 CHAR 'G'
 CHAR 'I'
 CHAR 'E'
 CHAR '-'
 RTOK 14
 EQUB 0

 CHAR 'D'               ; Token 115:    ""
 CHAR 'O'
 CHAR 'C'
 CHAR 'K'
 CHAR ' '
 RTOK 55
 EQUB 0

 CHAR 'G'               ; Token 116:    ""
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

 CHAR 'M'               ; Token 117:    ""
 CHAR 'I'
 CHAR 'L'
 CHAR 'I'
 CHAR 'T'
 CHAR '.'
 RTOK 27
 EQUB 0

 CHAR 'G'               ; Token 118:    ""
 CHAR 'R'
 CHAR 'U'
 CHAR 'B'
 TWOK 'E', 'N'
 TWOK 'L', 'A'
 CHAR 'S'
 TWOK 'E', 'R'
 CHAR ' '
 EQUB 0

 CONT 6                 ; Token 119:    ""
 RTOK 37
 CHAR ':'
 CONT 0
 EQUB 0

 TWOK 'A', 'N'          ; Token 120:    ""
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

 TWOK 'E', 'N'          ; Token 121:    ""
 TWOK 'E', 'R'
 CHAR 'G'
 CHAR 'I'
 CHAR 'E'
 CHAR ' '
 EQUB 0

 CHAR 'G'               ; Token 122:    ""
 CHAR 'A'
 TWOK 'L', 'A'
 CHAR 'K'
 TWOK 'T', 'I'
 CHAR 'S'
 CHAR 'C'
 CHAR 'H'
 EQUB 0

 RTOK 115               ; Token 123:    ""
 CHAR ' '
 TWOK 'A', 'N'
 EQUB 0

 CHAR 'A'               ; Token 124:    ""
 CHAR 'L'
 TWOK 'L', 'E'
 EQUB 0

 TWOK 'L', 'E'          ; Token 125:    ""
 CHAR 'G'
 CHAR 'A'
 CHAR 'L'
 RTOK 43
 TWOK 'A', 'T'
 TWOK 'U', 'S'
 CHAR ':'
 EQUB 0

 RTOK 92                ; Token 126:    ""
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

 CHAR 'W'               ; Token 127:    ""
 TWOK 'A', 'R'
 CHAR 'E'
 EQUB 0

 EQUB 0                 ; Token 128:    ""

 CHAR 'I'               ; Token 129:    ""
 CHAR 'E'
 EQUB 0

 CHAR 'W'               ; Token 130:    ""
 TWOK 'E', 'R'
 CHAR 'T'
 CHAR 'U'
 CHAR 'N'
 CHAR 'G'
 EQUB 0

 CHAR ' '               ; Token 131:    ""
 TWOK 'A', 'N'
 CHAR ' '
 EQUB 0

 CONT 12                ; Token 132:    ""
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

 CHAR 'S'               ; Token 133:    ""
 CHAR 'A'
 CHAR 'U'
 CHAR 'B'
 TWOK 'E', 'R'
 EQUB 0

 RTOK 43                ; Token 134:    ""
 TWOK 'R', 'A'
 CHAR 'F'
 CHAR 'T'
 CHAR '['
 CHAR 'T'
 TWOK 'E', 'R'
 EQUB 0

 CHAR 'F'               ; Token 135:    ""
 CHAR 'L'
 CHAR ']'
 CHAR 'C'
 CHAR 'H'
 CHAR 'T'
 CHAR 'L'
 TWOK 'I', 'N'
 CHAR 'G'
 EQUB 0

 CHAR 'H'               ; Token 136:    ""
 RTOK 138
 CHAR 'L'
 CHAR 'O'
 CHAR 'S'
 EQUB 0

 CHAR ']'               ; Token 137:    ""
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

 TWOK 'A', 'R'          ; Token 138:    ""
 CHAR 'M'
 EQUB 0

 CHAR 'D'               ; Token 139:    ""
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

 CHAR ']'               ; Token 140:    ""
 CHAR 'B'
 TWOK 'E', 'R'
 RTOK 139
 CHAR ' '
 EQUB 0

 CHAR 'K'               ; Token 141:    ""
 CHAR 'O'
 CHAR 'M'
 CHAR 'P'
 CHAR 'E'
 CHAR 'T'
 TWOK 'E', 'N'
 CHAR 'T'
 EQUB 0

 TWOK 'G', 'E'          ; Token 142:    ""
 CHAR 'F'
 CHAR '['
 CHAR 'H'
 CHAR 'R'
 CHAR 'L'
 CHAR 'I'
 CHAR 'C'
 CHAR 'H'
 EQUB 0

 CHAR 'T'               ; Token 143:    ""
 CHAR '\'
 CHAR 'D'
 CHAR 'L'
 CHAR 'I'
 CHAR 'C'
 CHAR 'H'
 EQUB 0

 CHAR '-'               ; Token 144:    ""
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

 TWOK 'A', 'N'          ; Token 145:    ""
 CHAR 'W'
 TWOK 'E', 'S'
 TWOK 'E', 'N'
 CHAR 'D'
 EQUB 0

 CONT 8                 ; Token 146:    ""
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

 CHAR '6'               ; Token 147:    ""
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

 EQUB 0                 ; Token 148:    ""

; ******************************************************************************
;
;       Name: QQ18_FR
;       Type: Variable
;   Category: Text
;    Summary: The recursive token table for tokens 0-148 (French)
;  Deep dive: Printing text tokens
;
; ******************************************************************************

.QQ18_FR

 RTOK 105               ; Token 0:      ""
 CHAR ' '
 CONT 7
 EQUB 0

 CHAR ' '               ; Token 1:      ""
 CHAR 'C'
 TWOK 'A', 'R'
 TWOK 'T', 'E'
 EQUB 0

 CHAR 'G'               ; Token 2:      ""
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

 CHAR 'D'               ; Token 3:      ""
 TWOK 'O', 'N'
 CHAR 'N'
 CHAR '<'
 TWOK 'E', 'S'
 RTOK 131
 CONT 3
 EQUB 0

 TWOK 'I', 'N'          ; Token 4:      ""
 CHAR 'V'
 TWOK 'E', 'N'
 CHAR 'T'
 CHAR 'A'
 CHAR 'I'
 TWOK 'R', 'E'
 CONT 12
 EQUB 0

 CHAR 'S'               ; Token 5:      ""
 CHAR 'Y'
 RTOK 43
 CHAR '='
 CHAR 'M'
 CHAR 'E'
 EQUB 0

 CHAR 'P'               ; Token 6:      ""
 TWOK 'R', 'I'
 CHAR 'X'
 EQUB 0

 CONT 2                 ; Token 7:      ""
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

 TWOK 'I', 'N'          ; Token 8:      ""
 CHAR 'D'
 TWOK 'U', 'S'
 CHAR 'T'
 TWOK 'R', 'I'
 CHAR 'E'
 CHAR 'L'
 TWOK 'L', 'E'
 EQUB 0

 CHAR 'A'               ; Token 9:      ""
 CHAR 'G'
 TWOK 'R', 'I'
 CHAR 'C'
 CHAR 'O'
 TWOK 'L', 'E'
 EQUB 0

 TWOK 'R', 'I'          ; Token 10:     ""
 CHAR 'C'
 CHAR 'H'
 CHAR 'E'
 CHAR ' '
 EQUB 0

 RTOK 139               ; Token 11:     ""
 CHAR 'N'
 CHAR 'E'
 CHAR ' '
 EQUB 0

 CHAR 'P'               ; Token 12:     ""
 CHAR 'A'
 CHAR 'U'
 CHAR 'V'
 TWOK 'R', 'E'
 CHAR ' '
 EQUB 0

 CHAR 'S'               ; Token 13:     ""
 CHAR 'U'
 CHAR 'R'
 RTOK 124
 CHAR ' '
 EQUB 0

 CHAR 'U'               ; Token 14:     ""
 CHAR 'N'
 CHAR 'I'
 TWOK 'T', 'E'
 EQUB 0

 CHAR ' '               ; Token 15:     ""
 EQUB 0

 CHAR 'P'               ; Token 16:     ""
 TWOK 'L', 'E'
 TWOK 'I', 'N'
 EQUB 0

 TWOK 'A', 'N'          ; Token 17:     ""
 TWOK 'A', 'R'
 CHAR 'C'
 CHAR 'H'
 CHAR 'I'
 CHAR 'E'
 EQUB 0

 CHAR 'F'               ; Token 18:     ""
 CHAR '<'
 CHAR 'O'
 CHAR 'D'
 CHAR 'A'
 CHAR 'L'
 EQUB 0

 CHAR 'P'               ; Token 19:     ""
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

 TWOK 'D', 'I'          ; Token 20:     ""
 CHAR 'C'
 CHAR 'T'
 TWOK 'A', 'T'
 CHAR 'U'
 TWOK 'R', 'E'
 EQUB 0

 RTOK 91                ; Token 21:     ""
 CHAR 'M'
 CHAR 'U'
 CHAR 'N'
 TWOK 'I', 'S'
 TWOK 'T', 'E'
 EQUB 0

 CHAR 'C'               ; Token 22:     ""
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

 CHAR 'D'               ; Token 23:     ""
 CHAR '<'
 CHAR 'M'
 CHAR 'O'
 CHAR 'C'
 CHAR 'R'
 TWOK 'A', 'T'
 CHAR 'I'
 CHAR 'E'
 EQUB 0

 CHAR '<'               ; Token 24:     ""
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

 CHAR 'N'               ; Token 25:     ""
 CHAR 'A'
 CHAR 'V'
 CHAR 'I'
 TWOK 'R', 'E'
 EQUB 0

 CHAR 'P'               ; Token 26:     ""
 CHAR 'R'
 CHAR 'O'
 CHAR 'D'
 CHAR 'U'
 CHAR 'I'
 CHAR 'T'
 EQUB 0

 TWOK 'L', 'A'          ; Token 27:     ""
 CHAR 'S'
 TWOK 'E', 'R'
 EQUB 0

 CHAR 'H'               ; Token 28:     ""
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

 RTOK 116               ; Token 29:     ""
 CHAR ' '
 EQUB 0

 CHAR 'C'               ; Token 30:     ""
 TWOK 'A', 'R'
 TWOK 'T', 'E'
 CHAR ' '
 CHAR 'L'
 CHAR 'O'
 CHAR 'C'
 CHAR 'A'
 TWOK 'L', 'E'
 EQUB 0

 TWOK 'D', 'I'          ; Token 31:     ""
 RTOK 43
 TWOK 'A', 'N'
 TWOK 'C', 'E'
 EQUB 0

 CHAR 'P'               ; Token 32:     ""
 CHAR 'O'
 CHAR 'P'
 CHAR 'U'
 CHAR 'L'
 TWOK 'A', 'T'
 CHAR 'I'
 TWOK 'O', 'N'
 EQUB 0

 CONT 6                 ; Token 33:     ""
 CHAR 'C'
 CHAR '.'
 CONT 6
 CHAR 'A'
 CHAR '.'
 EQUB 0

 CHAR '<'               ; Token 34:     ""
 CHAR 'C'
 TWOK 'O', 'N'
 CHAR 'O'
 CHAR 'M'
 CHAR 'I'
 CHAR 'E'
 EQUB 0

 CHAR ' '               ; Token 35:     ""
 CONT 6
 CHAR 'A'
 CHAR '.'
 CONT 6
 CHAR 'L'
 CHAR 'U'
 CHAR 'M'
 CHAR '.'
 EQUB 0

 CHAR 'N'               ; Token 36:     ""
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

 TWOK 'A', 'R'          ; Token 37:     ""
 TWOK 'G', 'E'
 CHAR 'N'
 CHAR 'T'
 EQUB 0

 CHAR ' '               ; Token 38:     ""
 TWOK 'B', 'I'
 CHAR 'L'
 CHAR 'L'
 CHAR 'I'
 TWOK 'O', 'N'
 EQUB 0

 CHAR 'C'               ; Token 39:     ""
 TWOK 'A', 'R'
 TWOK 'T', 'E'
 CHAR ' '
 RTOK 122
 CONT 1
 EQUB 0

 CHAR 'C'               ; Token 40:     ""
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

 RTOK 106               ; Token 41:     ""
 CHAR ' '
 TWOK 'E', 'N'
 CHAR 'V'
 CHAR 'O'
 CHAR 'Y'
 CHAR 'E'
 CHAR '<'
 CHAR ' '
 EQUB 0

 CHAR 'P'               ; Token 42:     ""
 TWOK 'O', 'R'
 CHAR 'T'
 CHAR '<'
 CHAR 'E'
 EQUB 0

 CHAR 'S'               ; Token 43:     ""
 CHAR 'T'
 EQUB 0

 RTOK 16                ; Token 44:     ""
 CHAR ' '
 CHAR 'D'
 CHAR 'E'
 CHAR ' '
 EQUB 0

 CHAR 'S'               ; Token 45:     ""
 CHAR 'E'
 EQUB 0

 CHAR ' '               ; Token 46:     ""
 CHAR 'C'
 TWOK 'A', 'R'
 CHAR 'G'
 CHAR 'A'
 CHAR 'I'
 TWOK 'S', 'O'
 CHAR 'N'
 CONT 6
 EQUB 0

 CHAR 'E'               ; Token 47:     ""
 TWOK 'Q', 'U'
 CHAR 'I'
 CHAR 'P'
 CHAR 'E'
 CHAR 'M'
 TWOK 'E', 'N'
 CHAR 'T'
 EQUB 0

 CHAR 'N'               ; Token 48:     ""
 CHAR 'O'
 CHAR 'U'
 CHAR 'R'
 TWOK 'R', 'I'
 CHAR 'T'
 CHAR 'U'
 TWOK 'R', 'E'
 EQUB 0

 TWOK 'T', 'E'          ; Token 49:     ""
 CHAR 'X'
 TWOK 'T', 'I'
 TWOK 'L', 'E'
 CHAR 'S'
 EQUB 0

 TWOK 'R', 'A'          ; Token 50:     ""
 TWOK 'D', 'I'
 CHAR 'O'
 CHAR 'A'
 CHAR 'C'
 TWOK 'T', 'I'
 CHAR 'F'
 CHAR 'S'
 EQUB 0

 TWOK 'E', 'S'          ; Token 51:     ""
 CHAR 'C'
 TWOK 'L', 'A'
 TWOK 'V', 'E'
 CHAR '-'
 CHAR 'R'
 CHAR 'O'
 CHAR 'B'
 CHAR 'T'
 EQUB 0

 CHAR 'B'               ; Token 52:     ""
 CHAR 'O'
 TWOK 'I', 'S'
 TWOK 'S', 'O'
 CHAR 'N'
 CHAR 'S'
 EQUB 0

 CHAR 'P'               ; Token 53:     ""
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

 TWOK 'E', 'S'          ; Token 54:     ""
 CHAR 'P'
 CHAR '='
 TWOK 'C', 'E'
 CHAR ' '
 CHAR 'R'
 TWOK 'A', 'R'
 CHAR 'E'
 EQUB 0

 TWOK 'O', 'R'          ; Token 55:     ""
 CHAR 'D'
 TWOK 'I', 'N'
 TWOK 'A', 'T'
 CHAR 'E'
 CHAR 'U'
 CHAR 'R'
 EQUB 0

 TWOK 'M', 'A'          ; Token 56:     ""
 CHAR 'C'
 CHAR 'H'
 TWOK 'I', 'N'
 TWOK 'E', 'S'
 EQUB 0

 CHAR 'A'               ; Token 57:     ""
 CHAR 'L'
 CHAR 'L'
 CHAR 'I'
 CHAR 'A'
 TWOK 'G', 'E'
 CHAR 'S'
 EQUB 0

 TWOK 'A', 'R'          ; Token 58:     ""
 CHAR 'M'
 TWOK 'E', 'S'
 EQUB 0

 CHAR 'F'               ; Token 59:     ""
 CHAR 'O'
 CHAR 'U'
 CHAR 'R'
 CHAR 'R'
 CHAR 'U'
 CHAR 'R'
 TWOK 'E', 'S'
 EQUB 0

 CHAR 'M'               ; Token 60:     ""
 TWOK 'I', 'N'
 CHAR '<'
 TWOK 'R', 'A'
 CHAR 'U'
 CHAR 'X'
 EQUB 0

 TWOK 'O', 'R'          ; Token 61:     ""
 EQUB 0

 CHAR 'P'               ; Token 62:     ""
 CHAR 'L'
 TWOK 'A', 'T'
 TWOK 'I', 'N'
 CHAR 'E'
 EQUB 0

 TWOK 'G', 'E'          ; Token 63:     ""
 CHAR 'M'
 CHAR 'M'
 TWOK 'E', 'S'
 EQUB 0

 RTOK 127               ; Token 64:     ""
 CHAR ' '
 CHAR 'E'
 CHAR '.'
 CHAR 'T'
 CHAR '.'
 EQUB 0

 EQUB 0                 ; Token 65:     ""

 CHAR ' '               ; Token 66:     ""
 CHAR 'C'
 CHAR 'R'
 EQUB 0

 CHAR 'L'               ; Token 67:     ""
 TWOK 'A', 'R'
 TWOK 'G', 'E'
 CHAR 'S'
 EQUB 0

 CHAR 'F'               ; Token 68:     ""
 CHAR '<'
 CHAR 'R'
 CHAR 'O'
 TWOK 'C', 'E'
 CHAR 'S'
 EQUB 0

 CHAR 'P'               ; Token 69:     ""
 CHAR 'E'
 TWOK 'T', 'I'
 CHAR 'T'
 CHAR 'S'
 EQUB 0

 CHAR 'V'               ; Token 70:     ""
 TWOK 'E', 'R'
 CHAR 'T'
 CHAR 'S'
 EQUB 0

 CHAR 'R'               ; Token 71:     ""
 CHAR 'O'
 CHAR 'U'
 TWOK 'G', 'E'
 CHAR 'S'
 EQUB 0

 CHAR 'J'               ; Token 72:     ""
 CHAR 'A'
 CHAR 'U'
 CHAR 'N'
 TWOK 'E', 'S'
 EQUB 0

 CHAR 'B'               ; Token 73:     ""
 TWOK 'L', 'E'
 TWOK 'U', 'S'
 EQUB 0

 CHAR 'N'               ; Token 74:     ""
 CHAR 'O'
 CHAR 'I'
 CHAR 'R'
 CHAR 'S'
 EQUB 0

 RTOK 136               ; Token 75:     ""
 CHAR 'S'
 EQUB 0

 CHAR 'V'               ; Token 76:     ""
 TWOK 'I', 'S'
 TWOK 'Q', 'U'
 CHAR 'E'
 CHAR 'U'
 CHAR 'X'
 EQUB 0

 CHAR 'Y'               ; Token 77:     ""
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

 CHAR '"'               ; Token 78:     ""
 CHAR ' '
 CHAR 'C'
 TWOK 'O', 'R'
 CHAR 'N'
 TWOK 'E', 'S'
 EQUB 0

 TWOK 'A', 'N'          ; Token 79:     ""
 CHAR 'G'
 CHAR 'U'
 TWOK 'L', 'E'
 CHAR 'U'
 CHAR 'X'
 EQUB 0

 CHAR 'G'               ; Token 80:     ""
 TWOK 'R', 'A'
 CHAR 'S'
 EQUB 0

 CHAR '"'               ; Token 81:     ""
 CHAR ' '
 CHAR 'F'
 CHAR 'O'
 CHAR 'U'
 CHAR 'R'
 CHAR 'R'
 CHAR 'U'
 TWOK 'R', 'E'
 EQUB 0

 CHAR 'R'               ; Token 82:     ""
 TWOK 'O', 'N'
 TWOK 'G', 'E'
 CHAR 'U'
 CHAR 'R'
 CHAR 'S'
 EQUB 0

 CHAR 'G'               ; Token 83:     ""
 TWOK 'R', 'E'
 CHAR 'N'
 CHAR 'O'
 CHAR 'U'
 CHAR 'I'
 CHAR 'L'
 TWOK 'L', 'E'
 CHAR 'S'
 EQUB 0

 CHAR 'L'               ; Token 84:     ""
 CHAR '<'
 TWOK 'Z', 'A'
 CHAR 'R'
 CHAR 'D'
 CHAR 'S'
 EQUB 0

 CHAR 'H'               ; Token 85:     ""
 CHAR 'O'
 CHAR 'M'
 TWOK 'A', 'R'
 CHAR 'D'
 CHAR 'S'
 EQUB 0

 CHAR 'O'               ; Token 86:     ""
 TWOK 'I', 'S'
 CHAR 'E'
 CHAR 'A'
 CHAR 'U'
 CHAR 'X'
 EQUB 0

 CHAR 'H'               ; Token 87:     ""
 CHAR 'U'
 TWOK 'M', 'A'
 CHAR 'N'
 CHAR 'O'
 CHAR 'I'
 CHAR 'D'
 TWOK 'E', 'S'
 EQUB 0

 CHAR 'F'               ; Token 88:     ""
 CHAR '<'
 CHAR 'L'
 TWOK 'I', 'N'
 CHAR 'S'
 EQUB 0

 TWOK 'I', 'N'          ; Token 89:     ""
 RTOK 45
 CHAR 'C'
 CHAR 'T'
 TWOK 'E', 'S'
 EQUB 0

 TWOK 'R', 'A'          ; Token 90:     ""
 CHAR 'Y'
 TWOK 'O', 'N'
 EQUB 0

 CHAR 'C'               ; Token 91:     ""
 CHAR 'O'
 CHAR 'M'
 EQUB 0

 RTOK 91                ; Token 92:     ""
 TWOK 'M', 'A'
 CHAR 'N'
 CHAR 'D'
 TWOK 'A', 'N'
 CHAR 'T'
 EQUB 0

 CHAR ' '               ; Token 93:     ""
 CHAR 'D'
 CHAR '<'
 CHAR 'T'
 CHAR 'R'
 CHAR 'U'
 CHAR 'I'
 CHAR 'T'
 EQUB 0

 TWOK 'L', 'E'          ; Token 94:     ""
 CHAR ' '
 EQUB 0

 RTOK 26                ; Token 95:     ""
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

 CHAR 'A'               ; Token 96:     ""
 CHAR 'V'
 TWOK 'A', 'N'
 CHAR 'T'
 EQUB 0

 TWOK 'A', 'R'          ; Token 97:     ""
 TWOK 'R', 'I'
 CHAR '='
 TWOK 'R', 'E'
 EQUB 0

 CHAR 'G'               ; Token 98:     ""
 CHAR 'A'
 CHAR 'U'
 CHAR 'C'
 CHAR 'H'
 CHAR 'E'
 EQUB 0

 CHAR 'D'               ; Token 99:     ""
 CHAR 'R'
 CHAR 'O'
 CHAR 'I'
 TWOK 'T', 'E'
 EQUB 0

 RTOK 121               ; Token 100:    ""
 RTOK 138
 CONT 7
 EQUB 0

 CHAR 'B'               ; Token 101:    ""
 TWOK 'R', 'A'
 CHAR 'V'
 CHAR 'O'
 CHAR ' '
 RTOK 92
 CHAR '!'
 EQUB 0

 TWOK 'E', 'N'          ; Token 102:    ""
 CHAR ' '
 CHAR 'P'
 CHAR 'L'
 TWOK 'U', 'S'
 CHAR ' '
 EQUB 0

 CHAR 'C'               ; Token 103:    ""
 TWOK 'A', 'N'
 CHAR 'N'
 TWOK 'O', 'N'
 CHAR ' '
 RTOK 27
 EQUB 0

 RTOK 90                ; Token 104:    ""
 CHAR ' '
 RTOK 27
 EQUB 0

 RTOK 94                ; Token 105:    ""
 CHAR 'F'
 CHAR 'U'
 CHAR 'E'
 CHAR 'L'
 EQUB 0

 CHAR 'M'               ; Token 106:    ""
 TWOK 'I', 'S'
 CHAR 'S'
 CHAR 'I'
 TWOK 'L', 'E'
 EQUB 0

 CHAR 'G'               ; Token 107:    ""
 TWOK 'R', 'A'
 CHAR 'N'
 CHAR 'D'
 CHAR 'E'
 CHAR ' '
 TWOK 'S', 'O'
 CHAR 'U'
 TWOK 'T', 'E'
 EQUB 0

 RTOK 5                 ; Token 108:    ""
 CHAR ' '
 CHAR 'E'
 CHAR '.'
 CHAR 'C'
 CHAR '.'
 CHAR 'M'
 CHAR '.'
 EQUB 0

 CHAR 'C'               ; Token 109:    ""
 TWOK 'A', 'N'
 TWOK 'O', 'N'
 CHAR ' '
 RTOK 27
 EQUB 0

 RTOK 104               ; Token 110:    ""
 EQUB 0

 CHAR 'R'               ; Token 111:    ""
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

 CHAR 'C'               ; Token 112:    ""
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

 CHAR 'B'               ; Token 113:    ""
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

 CHAR 'U'               ; Token 114:    ""
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

 TWOK 'O', 'R'          ; Token 115:    ""
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

 TWOK 'I', 'N'          ; Token 116:    ""
 CHAR 'T'
 TWOK 'E', 'R'
 RTOK 122
 EQUB 0

 RTOK 27                ; Token 117:    ""
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

 RTOK 27                ; Token 118:    ""
 CHAR ' '
 CONT 6
 CHAR 'M'
 TWOK 'I', 'N'
 CHAR 'E'
 CHAR 'U'
 CHAR 'R'
 EQUB 0

 RTOK 37                ; Token 119:    ""
 CHAR ':'
 CONT 0
 EQUB 0

 RTOK 106               ; Token 120:    ""
 CHAR ' '
 TWOK 'E', 'N'
 CHAR ' '
 CHAR 'V'
 CHAR 'U'
 CHAR 'E'
 EQUB 0

 CHAR '<'               ; Token 121:    ""
 CHAR 'N'
 TWOK 'E', 'R'
 CHAR 'G'
 CHAR 'I'
 CHAR 'E'
 CHAR ' '
 EQUB 0

 CHAR 'G'               ; Token 122:    ""
 CHAR 'A'
 TWOK 'L', 'A'
 CHAR 'C'
 TWOK 'T', 'I'
 TWOK 'Q', 'U'
 CHAR 'E'
 EQUB 0

 RTOK 115               ; Token 123:    ""
 CHAR ' '
 TWOK 'E', 'N'
 CHAR ' '
 CHAR 'M'
 TWOK 'A', 'R'
 CHAR 'C'
 CHAR 'H'
 CHAR 'E'
 EQUB 0

 CHAR 'T'               ; Token 124:    ""
 CHAR 'O'
 CHAR 'U'
 CHAR 'T'
 EQUB 0

 RTOK 43                ; Token 125:    ""
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

 RTOK 92                ; Token 126:    ""
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

 CHAR 'O'               ; Token 127:    ""
 CHAR 'B'
 CHAR 'J'
 CHAR 'E'
 CHAR 'T'
 EQUB 0

 EQUB 0                 ; Token 128:    ""

 CHAR '"'               ; Token 129:    ""
 CHAR ' '
 EQUB 0

 CHAR '<'               ; Token 130:    ""
 CHAR 'V'
 CHAR 'A'
 CHAR 'L'
 CHAR 'U'
 TWOK 'A', 'T'
 CHAR 'I'
 TWOK 'O', 'N'
 EQUB 0

 CHAR ' '               ; Token 131:    ""
 CHAR 'S'
 CHAR 'U'
 CHAR 'R'
 CHAR ' '
 EQUB 0

 CONT 12                ; Token 132:    ""
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

 CHAR 'P'               ; Token 133:    ""
 CHAR 'R'
 CHAR 'O'
 CHAR 'P'
 TWOK 'R', 'E'
 EQUB 0

 CHAR 'D'               ; Token 134:    ""
 CHAR '<'
 CHAR 'L'
 TWOK 'I', 'N'
 TWOK 'Q', 'U'
 TWOK 'A', 'N'
 CHAR 'T'
 EQUB 0

 CHAR 'F'               ; Token 135:    ""
 CHAR 'U'
 CHAR 'G'
 CHAR 'I'
 TWOK 'T', 'I'
 CHAR 'F'
 EQUB 0

 TWOK 'I', 'N'          ; Token 136:    ""
 CHAR 'O'
 CHAR 'F'
 CHAR 'F'
 TWOK 'E', 'N'
 CHAR 'S'
 CHAR 'I'
 CHAR 'F'
 EQUB 0

 TWOK 'Q', 'U'          ; Token 137:    ""
 CHAR 'A'
 CHAR 'S'
 CHAR 'I'
 CHAR ' '
 RTOK 136
 EQUB 0

 CHAR 'F'               ; Token 138:    ""
 CHAR 'A'
 CHAR 'I'
 CHAR 'B'
 TWOK 'L', 'E'
 EQUB 0

 CHAR 'M'               ; Token 139:    ""
 CHAR 'O'
 CHAR 'Y'
 TWOK 'E', 'N'
 EQUB 0

 TWOK 'I', 'N'          ; Token 140:    ""
 CHAR 'T'
 TWOK 'E', 'R'
 CHAR 'M'
 CHAR '<'
 TWOK 'D', 'I'
 CHAR 'A'
 CHAR 'I'
 TWOK 'R', 'E'
 EQUB 0

 RTOK 91                ; Token 141:    ""
 CHAR 'P'
 CHAR '<'
 CHAR 'T'
 TWOK 'E', 'N'
 CHAR 'T'
 EQUB 0

 CHAR 'D'               ; Token 142:    ""
 TWOK 'A', 'N'
 TWOK 'G', 'E'
 TWOK 'R', 'E'
 CHAR 'U'
 CHAR 'X'
 EQUB 0

 CHAR 'M'               ; Token 143:    ""
 TWOK 'O', 'R'
 TWOK 'T', 'E'
 CHAR 'L'
 TWOK 'L', 'E'
 CHAR 'M'
 TWOK 'E', 'N'
 CHAR 'T'
 EQUB 0

 CHAR '-'               ; Token 144:    ""
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

 CHAR 'P'               ; Token 145:    ""
 CHAR 'R'
 CHAR '<'
 CHAR 'S'
 TWOK 'E', 'N'
 CHAR 'T'
 EQUB 0

 CONT 8                 ; Token 146:    ""
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

 CHAR 'P'               ; Token 147:    ""
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

 EQUB 0                 ; Token 148:    ""

 EQUB 0, 0, 0, 0
 EQUB 0, 0, 0

; ******************************************************************************
;
;       Name: RUTOK_LO
;       Type: Variable
;   Category: Text
;    Summary: Address lookup table for the RUTOK text token table in three
;             different languages (low byte)
;
; ******************************************************************************

.RUTOK_LO

 EQUB LO(RUTOK)         ; English

 EQUB LO(RUTOK_DE)      ; German

 EQUB LO(RUTOK_FR)      ; French

 EQUB $72               ; There is no fourth language, so this byte is ignored

; ******************************************************************************
;
;       Name: RUTOK_HI
;       Type: Variable
;   Category: Text
;    Summary: Address lookup table for the RUTOK text token table in three
;             different languages (high byte)
;
; ******************************************************************************

.RUTOK_HI

 EQUB HI(RUTOK)         ; English

 EQUB HI(RUTOK_DE)      ; German

 EQUB HI(RUTOK_FR)      ; French

 EQUB $AB               ; There is no fourth language, so this byte is ignored

; ******************************************************************************
;
;       Name: DETOK3
;       Type: Subroutine
;   Category: Text
;    Summary: Print an extended recursive token from the RUTOK token table
;  Deep dive: Extended system descriptions
;             Extended text tokens
;
; ------------------------------------------------------------------------------
;
; Arguments:
;
;   A                   The recursive token to be printed, in the range 0-255
;
; Returns:
;
;   A                   A is preserved
;
;   Y                   Y is preserved
;
;   V(1 0)              V(1 0) is preserved
;
; ******************************************************************************

.DETOK3

 PHA                    ; Store A on the stack, so we can retrieve it later

 TAX                    ; Copy the token number from A into X

 TYA                    ; Store Y on the stack
 PHA

 LDA V                  ; Store V(1 0) on the stack
 PHA
 LDA V+1
 PHA

 LDY languageIndex      ; Set Y to the chosen language

 LDA RUTOK_LO,Y         ; Set V(1 0) to the address of the RUTOK table for ths
 STA V                  ; chosen language
 LDA RUTOK_HI,Y
 STA V+1

 BNE DTEN               ; Call DTEN to print token number X from the RUTOK
                        ; table and restore the values of A, Y and V(1 0) from
                        ; the stack, returning from the subroutine using a tail
                        ; call (this BNE is effectively a JMP as A is never
                        ; zero)

; ******************************************************************************
;
;       Name: DETOK
;       Type: Subroutine
;   Category: Text
;    Summary: Print an extended recursive token from the TKN1 token table
;  Deep dive: Extended text tokens
;
; ------------------------------------------------------------------------------
;
; Arguments:
;
;   A                   The recursive token to be printed, in the range 1-255
;
; Returns:
;
;   A                   A is preserved
;
;   Y                   Y is preserved
;
;   V(1 0)              V(1 0) is preserved
;
; Other entry points:
;
;   DTEN                Print recursive token number X from the token table
;                       pointed to by (A V), used to print tokens from the RUTOK
;                       table via calls to DETOK3
;
; ******************************************************************************

.DETOK

 TAX                    ; Copy the token number from A into X

 SETUP_PPU_FOR_ICON_BAR ; If the PPU has started drawing the icon bar, configure
                        ; the PPU to use nametable 0 and pattern table 0

 TXA                    ; Copy the token number from X into A

 PHA                    ; Store A on the stack, so we can retrieve it later

 TYA                    ; Store Y on the stack
 PHA

 LDA V                  ; Store V(1 0) on the stack
 PHA
 LDA V+1
 PHA

 LDA TKN1Lo             ; Set V(1 0) to the address of the TKN1 table for ths
 STA V                  ; chosen language
 LDA TKN1Hi
 STA V+1

.DTEN

 LDY #0                 ; First, we need to work our way through the table until
                        ; we get to the token that we want to print. Tokens are
                        ; delimited by #VE, and VE EOR VE = 0, so we work our
                        ; way through the table in, counting #VE delimiters
                        ; until we have passed X of them, at which point we jump
                        ; down to DTL2 to do the actual printing. So first, we
                        ; set a counter Y to point to the character offset as we
                        ; scan through the table

.DTL1

 SETUP_PPU_FOR_ICON_BAR ; If the PPU has started drawing the icon bar, configure
                        ; the PPU to use nametable 0 and pattern table 0

 LDA (V),Y              ; Load the character at offset Y in the token table,
                        ; which is the next character from the token table

 EOR #VE                ; Tokens are stored in memory having been EOR'd with
                        ; #VE, so we repeat the EOR to get the actual character
                        ; in this token

 BNE DT1                ; If the result is non-zero, then this is a character
                        ; in a token rather than the delimiter (which is #VE),
                        ; so jump to DT1

 DEX                    ; We have just scanned the end of a token, so decrement
                        ; X, which contains the token number we are looking for

 BEQ DTL2               ; If X has now reached zero then we have found the token
                        ; we are looking for, so jump down to DTL2 to print it

.DT1

 INY                    ; Otherwise this isn't the token we are looking for, so
                        ; increment the character pointer

 BNE DTL1               ; If Y hasn't just wrapped around to 0, loop back to
                        ; DTL1 to process the next character

 INC V+1                ; We have just crossed into a new page, so increment
                        ; V+1 so that V points to the start of the new page

 BNE DTL1               ; Jump back to DTL1 to process the next character (this
                        ; BNE is effectively a JMP as V+1 won't reach zero
                        ; before we reach the end of the token table)

.DTL2

 INY                    ; We just detected the delimiter byte before the token
                        ; that we want to print, so increment the character
                        ; pointer to point to the first character of the token,
                        ; rather than the delimiter

 BNE P%+4               ; If Y hasn't just wrapped around to 0, skip the next
                        ; instruction

 INC V+1                ; We have just crossed into a new page, so increment
                        ; V+1 so that V points to the start of the new page

 LDA (V),Y              ; Load the character at offset Y in the token table,
                        ; which is the next character from the token we want to
                        ; print

 EOR #VE                ; Tokens are stored in memory having been EOR'd with
                        ; #VE, so we repeat the EOR to get the actual character
                        ; in this token

 BEQ DTEX               ; If the result is zero, then this is the delimiter at
                        ; the end of the token to print (which is #VE), so jump
                        ; to DTEX to return from the subroutine, as we are done
                        ; printing

 JSR DETOK2             ; Otherwise call DETOK2 to print this part of the token

 JMP DTL2               ; Jump back to DTL2 to process the next character

.DTEX

 PLA                    ; Restore V(1 0) from the stack, so it is preserved
 STA V+1                ; through calls to this routine
 PLA
 STA V

 PLA                    ; Restore Y from the stack, so it is preserved through
 TAY                    ; calls to this routine

 PLA                    ; Restore A from the stack, so it is preserved through
                        ; calls to this routine

 RTS                    ; Return from the subroutine

; ******************************************************************************
;
;       Name: DETOK2
;       Type: Subroutine
;   Category: Text
;    Summary: Print an extended text token (1-255)
;  Deep dive: Extended text tokens
;
; ------------------------------------------------------------------------------
;
; Arguments:
;
;   A                   The token to be printed (1-255)
;
; Returns:
;
;   A                   A is preserved
;
;   Y                   Y is preserved
;
;   V(1 0)              V(1 0) is preserved
;
; Other entry points:
;
;   DTS                 Print a single letter in the correct case
;
; ******************************************************************************

.DETOK2

 CMP #32                ; If A < 32 then this is a jump token, so skip to DT3 to
 BCC DT3                ; process it

 BIT DTW3               ; If bit 7 of DTW3 is clear, then extended tokens are
 BPL DT8                ; enabled, so jump to DT8 to process them

                        ; If we get there then this is not a jump token and
                        ; extended tokens are not enabled, so we can call the
                        ; standard text token routine at TT27 to print the token

 TAX                    ; Copy the token number from A into X

 TYA                    ; Store Y on the stack
 PHA

 LDA V                  ; Store V(1 0) on the stack
 PHA
 LDA V+1
 PHA

 TXA                    ; Copy the token number from X back into A

 JSR TT27               ; Call TT27 to print the text token

 JMP DT7                ; Jump to DT7 to restore V(1 0) and Y from the stack and
                        ; return from the subroutine

.DT8

                        ; If we get here then this is not a jump token and
                        ; extended tokens are enabled

 CMP characterEnd       ; If A < characterEnd then this is a printable character
 BCC DTS                ; in the chosen language, so jump down to DTS to print
                        ; it

 CMP #129               ; If A < 129, so A is in the range 91-128, jump down to
 BCC DT6                ; DT6 to print a randomised token from the MTIN table

 CMP #215               ; If A < 215, so A is in the range 129-214, jump to
 BCS P%+5               ; DETOK as this is a recursive token, returning from the
 JMP DETOK              ; subroutine using a tail call

                        ; If we get here then A >= 215, so this is a two-letter
                        ; token from the extended TKN2/QQ16 table

 SBC #215               ; Subtract 215 to get a token number in the range 0-12
                        ; (the C flag is set as we passed through the BCC above,
                        ; so this subtraction is correct)

 ASL A                  ; Set A = A * 2, so it can be used as a pointer into the
                        ; two-letter token tables at TKN2 and QQ16

 PHA                    ; Store A on the stack, so we can restore it for the
                        ; second letter below

 TAX                    ; Fetch the first letter of the two-letter token from
 LDA TKN2,X             ; TKN2, which is at TKN2 + X

 JSR DTS                ; Call DTS to print it

 PLA                    ; Restore A from the stack and transfer it into X
 TAX

 LDA TKN2+1,X           ; Fetch the second letter of the two-letter token from
                        ; TKN2, which is at TKN2 + X + 1, and fall through into
                        ; DTS to print it

 CMP #$3F               ; ???
 BEQ DTM-1

.DTS

 BIT DTW1               ; ???
 BPL DT5

 BIT DTW6               ; If bit 7 of DTW6 is set, then lower case has been
 BMI DT10               ; enabled by jump token 13, {lower case}, so jump to
                        ; DT10 to apply the lower case and single cap masks

 BIT DTW2               ; If bit 7 of DTW2 is set, then we are not currently
 BMI DT5                ; printing a word, so jump to DT5 so we skip the setting
                        ; of lower case in Sentence Case (which we only want to
                        ; do when we are already printing a word)

.DT10

 BIT DTW8               ; ???
 BPL DT5
 STX SC
 TAX
 LDA $B8B4,X
 LDX SC
 AND DTW8

.DT5

.DT9

 JMP DASC               ; Jump to DASC to print the ASCII character in A,
                        ; returning from the routine using a tail call

.DT3

                        ; If we get here then the token number in A is in the
                        ; range 1 to 32, so this is a jump token that should
                        ; call the corresponding address in the jump table at
                        ; JMTB

 TAX                    ; Copy the token number from A into X

 TYA                    ; Store Y on the stack
 PHA

 LDA V                  ; Store V(1 0) on the stack
 PHA
 LDA V+1
 PHA

 TXA                    ; Copy the token number from X back into A

 ASL A                  ; Set A = A * 2, so it can be used as a pointer into the
                        ; jump table at JMTB, though because the original range
                        ; of values is 1-32, so the doubled range is 2-64, we
                        ; need to take the offset into the jump table from
                        ; JMTB-2 rather than JMTB

 TAX                    ; Copy the doubled token number from A into X

 LDA JMTB-2,X           ; Set V(1 0) to the X-th address from the table at
 STA V                  ; JTM-2, so the JMP (V) instruction at label DTM below
 LDA JMTB-1,X           ; calls the subroutine at the relevant address from the
 STA V+1                ; JMTB table

 TXA                    ; Copy the doubled token number from X back into A

 LSR A                  ; Halve A to get the original token number

 JSR DTM                ; Call DTM to call the relevant JMTB subroutine in
                        ; V(1 0)

.DT7

 PLA                    ; Restore V(1 0) from the stack, so it is preserved
 STA V+1                ; through calls to this routine
 PLA
 STA V

 PLA                    ; Restore Y from the stack, so it is preserved through
 TAY                    ; calls to this routine

 RTS                    ; Return from the subroutine

.DTM

 JMP (V)                ; Call the relevant JMTB subroutine, as V(1 0) points
                        ; to the relevant address

.DT6

                        ; If we get here then the token number in A is in the
                        ; range 91-128, which means we print a randomly picked
                        ; token from the token range given in the corresponding
                        ; entry in the MTIN table

 STA SC                 ; Store the token number in SC

 SETUP_PPU_FOR_ICON_BAR ; If the PPU has started drawing the icon bar, configure
                        ; the PPU to use nametable 0 and pattern table 0

 TYA                    ; Store Y on the stack
 PHA

 LDA V                  ; Store V(1 0) on the stack
 PHA
 LDA V+1
 PHA

 JSR DORND              ; Set X to a random number
 TAX

 LDA #0                 ; Set A to 0, so we can build a random number from 0 to
                        ; 4 in A plus the C flag, with each number being equally
                        ; likely

 CPX #51                ; Add 1 to A if X >= 51
 ADC #0

 CPX #102               ; Add 1 to A if X >= 102
 ADC #0

 CPX #153               ; Add 1 to A if X >= 153
 ADC #0

 CPX #204               ; Set the C flag if X >= 204

 LDX SC                 ; Fetch the token number from SC into X, so X is now in
                        ; the range 91-128

 ADC MTIN-91,X          ; Set A = MTIN-91 + token number (91-128) + random (0-4)
                        ;       = MTIN + token number (0-37) + random (0-4)

 JSR DETOK              ; Call DETOK to print the extended recursive token in A

 JMP DT7                ; Jump to DT7 to restore V(1 0) and Y from the stack and
                        ; return from the subroutine using a tail call

; ******************************************************************************
;
;       Name: JMTB
;       Type: Variable
;   Category: Text
;    Summary: The extended token table for jump tokens 1-32 (DETOK)
;  Deep dive: Extended text tokens
;
; ******************************************************************************

.JMTB

 EQUW MT1               ; Token  1: Switch to ALL CAPS
 EQUW MT2               ; Token  2: Switch to Sentence Case
 EQUW TT27              ; Token  3: Print the selected system name
 EQUW TT27              ; Token  4: Print the commander's name
 EQUW MT5               ; Token  5: Switch to extended tokens
 EQUW MT6               ; Token  6: Switch to standard tokens, in Sentence Case
 EQUW DASC              ; Token  7: Beep
 EQUW MT8               ; Token  8: Tab to column 6
 EQUW MT9               ; Token  9: Clear screen, tab to column 1, view type = 1
 EQUW DASC              ; Token 10: Line feed
 EQUW NLIN4             ; Token 11: Draw box around title (line at pixel row 19)
 EQUW DASC              ; Token 12: Carriage return
 EQUW MT13              ; Token 13: Switch to lower case
 EQUW MT14              ; Token 14: Switch to justified text
 EQUW MT15              ; Token 15: Switch to left-aligned text
 EQUW MT16              ; Token 16: Print the character in DTW7 (drive number)
 EQUW MT17              ; Token 17: Print system name adjective in Sentence Case
 EQUW MT18              ; Token 18: Randomly print 1 to 4 two-letter tokens
 EQUW MT19              ; Token 19: Capitalise first letter of next word only
 EQUW DASC              ; Token 20: Unused
 EQUW CLYNS             ; Token 21: Clear the bottom few lines of the space view
 EQUW PAUSE             ; Token 22: Display ship and wait for key press
 EQUW MT23              ; Token 23: Move to row 10, white text, set lower case
 EQUW PAUSE2            ; Token 24: Wait for a key press
 EQUW BRIS              ; Token 25: Show incoming message screen, wait 2 seconds
 EQUW MT26              ; Token 26: Print a space and capitalise the next letter
 EQUW MT27              ; Token 27: Print mission captain's name (217-219)
 EQUW MT28              ; Token 28: Print mission 1 location hint (220-221)
 EQUW MT29              ; Token 29: Column 6, white text, lower case in words
 EQUW FILEPR            ; Token 30: Display currently selected media (disc/tape)
 EQUW OTHERFILEPR       ; Token 31: Display the non-selected media (disc/tape)
 EQUW DASC              ; Token 32: Unused

; ******************************************************************************
;
;       Name: MTIN
;       Type: Variable
;   Category: Text
;    Summary: Lookup table for random tokens in the extended token table (0-37)
;  Deep dive: Extended text tokens
;
; ------------------------------------------------------------------------------
;
; The ERND token type, which is part of the extended token system, takes an
; argument between 0 and 37, and returns a randomly chosen token in the range
; specified in this table. This is used to generate the extended description of
; each system.
;
; For example, the entry at position 13 in this table (counting from 0) is 66,
; so ERND 14 will expand into a random token in the range 66-70, i.e. one of
; "JUICE", "BRANDY", "WATER", "BREW" and "GARGLE BLASTERS".
;
; ******************************************************************************

.MTIN

 EQUB 16                ; Token  0: a random extended token between 16 and 20
 EQUB 21                ; Token  1: a random extended token between 21 and 25
 EQUB 26                ; Token  2: a random extended token between 26 and 30
 EQUB 31                ; Token  3: a random extended token between 31 and 35
 EQUB 155               ; Token  4: a random extended token between 155 and 159
 EQUB 160               ; Token  5: a random extended token between 160 and 164
 EQUB 46                ; Token  6: a random extended token between 46 and 50
 EQUB 165               ; Token  7: a random extended token between 165 and 169
 EQUB 36                ; Token  8: a random extended token between 36 and 40
 EQUB 41                ; Token  9: a random extended token between 41 and 45
 EQUB 61                ; Token 10: a random extended token between 61 and 65
 EQUB 51                ; Token 11: a random extended token between 51 and 55
 EQUB 56                ; Token 12: a random extended token between 56 and 60
 EQUB 170               ; Token 13: a random extended token between 170 and 174
 EQUB 66                ; Token 14: a random extended token between 66 and 70
 EQUB 71                ; Token 15: a random extended token between 71 and 75
 EQUB 76                ; Token 16: a random extended token between 76 and 80
 EQUB 81                ; Token 17: a random extended token between 81 and 85
 EQUB 86                ; Token 18: a random extended token between 86 and 90
 EQUB 140               ; Token 19: a random extended token between 140 and 144
 EQUB 96                ; Token 20: a random extended token between 96 and 100
 EQUB 101               ; Token 21: a random extended token between 101 and 105
 EQUB 135               ; Token 22: a random extended token between 135 and 139
 EQUB 130               ; Token 23: a random extended token between 130 and 134
 EQUB 91                ; Token 24: a random extended token between 91 and 95
 EQUB 106               ; Token 25: a random extended token between 106 and 110
 EQUB 180               ; Token 26: a random extended token between 180 and 184
 EQUB 185               ; Token 27: a random extended token between 185 and 189
 EQUB 190               ; Token 28: a random extended token between 190 and 194
 EQUB 225               ; Token 29: a random extended token between 225 and 229
 EQUB 230               ; Token 30: a random extended token between 230 and 234
 EQUB 235               ; Token 31: a random extended token between 235 and 239
 EQUB 240               ; Token 32: a random extended token between 240 and 244
 EQUB 245               ; Token 33: a random extended token between 245 and 249
 EQUB 250               ; Token 34: a random extended token between 250 and 254
 EQUB 115               ; Token 35: a random extended token between 115 and 119
 EQUB 120               ; Token 36: a random extended token between 120 and 124
 EQUB 125               ; Token 37: a random extended token between 125 and 129

; ******************************************************************************
;
;       Name: MT27
;       Type: Subroutine
;   Category: Text
;    Summary: Print the captain's name during mission briefings
;  Deep dive: Extended text tokens
;
; ------------------------------------------------------------------------------
;
; This routine prints the following tokens, depending on the galaxy number:
;
;   * Token 217 ("CURRUTHERS") in galaxy 0
;
;   * Token 218 ("FOSDYKE SMYTHE") in galaxy 1
;
;   * Token 219 ("FORTESQUE") in galaxy 2
;
; This is used when printing extended token 213 as part of the mission
; briefings, which looks like this when printed:
;
;   Commander {commander name}, I am Captain {mission captain's name} of Her
;   Majesty's Space Navy
;
; where {mission captain's name} is replaced by one of the names above.
;
; ******************************************************************************

.MT27

 LDA #217               ; Set A = 217, so when we fall through into MT28, the
                        ; 217 gets added to the current galaxy number, so the
                        ; extended token that is printed is 217-219 (as this is
                        ; only called in galaxies 0 through 2)

 BNE P%+4               ; Skip the next instruction

; ******************************************************************************
;
;       Name: MT28
;       Type: Subroutine
;   Category: Text
;    Summary: Print the location hint during the mission 1 briefing
;  Deep dive: Extended text tokens
;
; ------------------------------------------------------------------------------
;
; This routine prints the following tokens, depending on the galaxy number:
;
;   * Token 220 ("WAS LAST SEEN AT {single cap}REESDICE") in galaxy 0
;
;   * Token 221 ("IS BELIEVED TO HAVE JUMPED TO THIS GALAXY") in galaxy 1
;
; This is used when printing extended token 10 as part of the mission 1
; briefing, which looks like this when printed:
;
;   It went missing from our ship yard on Xeer five months ago and {mission 1
;   location hint}
;
; where {mission 1 location hint} is replaced by one of the names above.
;
; ******************************************************************************

.MT28

 LDA #220               ; Set A = galaxy number in GCNT + 220, which is in the
 CLC                    ; range 220-221, as this is only called in galaxies 0
 ADC GCNT               ; and 1

 JMP DETOK_b2           ; Jump to DETOK to print extended token 220-221,
                        ; returning from the subroutine using a tail call (this
                        ; BNE is effectively a JMP as A is never zero)

; ******************************************************************************
;
;       Name: MT1
;       Type: Subroutine
;   Category: Text
;    Summary: Switch to ALL CAPS when printing extended tokens
;  Deep dive: Extended text tokens
;
; ------------------------------------------------------------------------------
;
; This routine sets the following:
;
;   * DTW1 = %00000000 (do not change case to lower case)
;
;   * DTW6 = %00000000 (lower case is not enabled)
;
; ******************************************************************************

.MT1

 LDA #%00000000         ; Set A = %00000000, so when we fall through into MT2,
                        ; both DTW1 and DTW6 get set to %00000000

 EQUB $2C               ; Skip the next instruction by turning it into
                        ; $2C $A9 $20, or BIT $20A9, which does nothing apart
                        ; from affect the flags

; ******************************************************************************
;
;       Name: MT2
;       Type: Subroutine
;   Category: Text
;    Summary: Switch to Sentence Case when printing extended tokens
;  Deep dive: Extended text tokens
;
; ------------------------------------------------------------------------------
;
; This routine sets the following:
;
;   * DTW1 = %10000000 (apply ???)
;
;   * DTW6 = %00000000 (lower case is not enabled)
;
; ******************************************************************************

.MT2

 LDA #%10000000         ; Set DTW1 = %10000000 ???
 STA DTW1

 LDA #00000000          ; Set DTW6 = %00000000
 STA DTW6

 RTS                    ; Return from the subroutine

; ******************************************************************************
;
;       Name: MT8
;       Type: Subroutine
;   Category: Text
;    Summary: Tab to column 6 and start a new word when printing extended tokens
;  Deep dive: Extended text tokens
;
; ------------------------------------------------------------------------------
;
; This routine sets the following:
;
;   * XC = 6 (tab to column 6)
;
;   * DTW2 = %11111111 (we are not currently printing a word)
;
; ******************************************************************************

.MT8

 LDA #6                 ; Move the text cursor to column 6
 STA XC

 LDA #%11111111         ; Set all the bits in DTW2
 STA DTW2

 RTS                    ; Return from the subroutine

; ******************************************************************************
;
;       Name: MT16
;       Type: Subroutine
;   Category: Text
;    Summary: Print the character in variable DTW7
;  Deep dive: Extended text tokens
;
; ******************************************************************************

.MT16

                        ; Fall through into FILEPR to return from the
                        ; subroutine, as MT16 does nothing in the NES version

; ******************************************************************************
;
;       Name: FILEPR
;       Type: Subroutine
;   Category: Text
;    Summary: Display the currently selected media (disc or tape)
;  Deep dive: Extended text tokens
;
; ******************************************************************************

.FILEPR

                        ; Fall through into OTHERFILEPR to return from the
                        ; subroutine, as FILEPR does nothing in the NES version

; ******************************************************************************
;
;       Name: OTHERFILEPR
;       Type: Subroutine
;   Category: Text
;    Summary: Display the non-selected media (disc or tape)
;  Deep dive: Extended text tokens
;
; ******************************************************************************

.OTHERFILEPR

 RTS                    ; Return from the subroutine, as OTHERFILEPR does
                        ; nothing in the NES version

; ******************************************************************************
;
;       Name: MT9
;       Type: Subroutine
;   Category: Text
;    Summary: Clear the screen and show the Trumble mission briefing
;  Deep dive: Extended text tokens
;
; ------------------------------------------------------------------------------
;
; This routine sets the following:
;
;   * XC = 1 (tab to column 1)
;
; before calling TT66 to clear the screen and set the view type to 1.
;
; ******************************************************************************

.MT9

 LDA #1                 ; Move the text cursor to column 1
 STA XC

 LDA #$95               ; Clear the screen and and set the view type in QQ11 to
 JMP TT66_b0            ; $95 (Trumble mission briefing), returning from the
                        ; subroutine using a tail call

; ******************************************************************************
;
;       Name: MT6
;       Type: Subroutine
;   Category: Text
;    Summary: Switch to standard tokens in Sentence Case
;  Deep dive: Extended text tokens
;
; ------------------------------------------------------------------------------
;
; This routine sets the following:
;
;   * QQ17 = %10000000 (set Sentence Case for standard tokens)
;
;   * DTW3 = %11111111 (print standard tokens)
;
; ******************************************************************************

.MT6

 LDA #%10000000         ; Set bit 7 of QQ17 to switch standard tokens to
 STA QQ17               ; Sentence Case

 LDA #%11111111         ; Set A = %11111111, so when we fall through into MT5,
                        ; DTW3 gets set to %11111111 and calls to DETOK print
                        ; standard tokens

 EQUB $2C               ; Skip the next instruction by turning it into
                        ; $2C $A9 $00, or BIT $00A9, which does nothing apart
                        ; from affect the flags

; ******************************************************************************
;
;       Name: MT5
;       Type: Subroutine
;   Category: Text
;    Summary: Switch to extended tokens
;  Deep dive: Extended text tokens
;
; ------------------------------------------------------------------------------
;
; This routine sets the following:
;
;   * DTW3 = %00000000 (print extended tokens)
;
; ******************************************************************************

.MT5

 LDA #%00000000         ; Set DTW3 = %00000000, so that calls to DETOK print
 STA DTW3               ; extended tokens

 RTS                    ; Return from the subroutine

; ******************************************************************************
;
;       Name: MT14
;       Type: Subroutine
;   Category: Text
;    Summary: Switch to justified text when printing extended tokens
;  Deep dive: Extended text tokens
;
; ------------------------------------------------------------------------------
;
; This routine sets the following:
;
;   * DTW4 = %10000000 (justify text, print buffer on carriage return)
;
;   * DTW5 = 0 (reset line buffer size)
;
; ******************************************************************************

.MT14

 LDA #%10000000         ; Set A = %10000000, so when we fall through into MT15,
                        ; DTW4 gets set to %10000000

 EQUB $2C               ; Skip the next instruction by turning it into
                        ; $2C $A9 $00, or BIT $00A9, which does nothing apart
                        ; from affect the flags

; ******************************************************************************
;
;       Name: MT15
;       Type: Subroutine
;   Category: Text
;    Summary: Switch to left-aligned text when printing extended tokens
;  Deep dive: Extended text tokens
;
; ------------------------------------------------------------------------------
;
; This routine sets the following:
;
;   * DTW4 = %00000000 (do not justify text, print buffer on carriage return)
;
;   * DTW5 = 0 (reset line buffer size)
;
; ******************************************************************************

.MT15

 LDA #0                 ; Set DTW4 = %00000000
 STA DTW4

 ASL A                  ; Set DTW5 = 0 (even when we fall through from MT14 with
 STA DTW5               ; A set to %10000000)

 RTS                    ; Return from the subroutine

; ******************************************************************************
;
;       Name: MT17
;       Type: Subroutine
;   Category: Text
;    Summary: Print the selected system's adjective, e.g. Lavian for Lave
;  Deep dive: Extended text tokens
;
; ------------------------------------------------------------------------------
;
; The adjective for the current system is generated by taking the system name,
; removing the last character if it is a vowel, and adding "-ian" to the end,
; so:
;
;   * Lave gives Lavian (as in "Lavian tree grub")
;
;   * Leesti gives Leestian (as in "Leestian Evil Juice")
;
; This routine is called by jump token 17, {system name adjective}, and it can
; only be used when justified text is being printed - i.e. following jump token
; 14, {justify} - because the routine needs to use the line buffer to work.
;
; ******************************************************************************

.MT17

 LDA QQ17               ; Set QQ17 = %10111111 to switch to Sentence Case
 AND #%10111111
 STA QQ17

 LDA #3                 ; Print control code 3 (selected system name) into the
 JSR TT27               ; line buffer

 LDX DTW5               ; Load the last character of the line buffer BUF into A
 LDA BUF-1,X            ; (as DTW5 contains the buffer size, so character DTW5-1
                        ; is the last character in the buffer BUF)

 JSR VOWEL              ; Test whether the character is a vowel, in which case
                        ; this will set the C flag

 BCC MT171              ; If the character is not a vowel, skip the following
                        ; instruction

 DEC DTW5               ; The character is a vowel, so decrement DTW5, which
                        ; removes the last character from the line buffer (i.e.
                        ; it removes the trailing vowel from the system name)

.MT171

 LDA #153               ; Print extended token 153 ("IAN"), returning from the
 JMP DETOK_b2           ; subroutine using a tail call

; ******************************************************************************
;
;       Name: MT18
;       Type: Subroutine
;   Category: Text
;    Summary: Print a random 1-8 letter word in Sentence Case
;  Deep dive: Extended text tokens
;
; ******************************************************************************

.MT18

 JSR MT19               ; Call MT19 to capitalise the next letter (i.e. set
                        ; Sentence Case for this word only)

 JSR DORND              ; Set A and X to random numbers and reduce A to a
 AND #3                 ; random number in the range 0-3

 TAY                    ; Copy the random number into Y, so we can use Y as a
                        ; loop counter to print 1-4 words (i.e. Y+1 words)

.MT18L

 JSR DORND              ; Set A and X to random numbers and reduce A to an even
 AND #62                ; random number in the range 0-62 (as bit 0 of 62 is 0)

 TAX                    ; Copy the random number into X, so X contains the table
                        ; offset of a random extended two-letter token from 0-31
                        ; which we can now use to pick a token from the combined
                        ; tables at TKN2+2 and QQ16 (we intentionally exclude
                        ; the first token in TKN2, which contains a newline)

 LDA TKN2+2,X           ; Print the first letter of the token at TKN2+2 + X
 JSR DTS_b2

 LDA TKN2+3,X           ; Fetch the second letter of the token from TKN2+2 + X

 CMP #'?'               ; If the second letter is a question mark, skip the
 BEQ P%+5               ; following instruction (as ? indicates a single-letter
                        ; token)

 JSR DTS_b2             ; Print the second letter of the token at TKN2+2 + X

 DEY                    ; Decrement the loop counter

 BPL MT18L              ; Loop back to MT18L to print another two-letter token
                        ; until we have printed Y+1 of them

 RTS                    ; Return from the subroutine

; ******************************************************************************
;
;       Name: MT26
;       Type: Subroutine
;   Category: Text
;    Summary: Print a space and capitalise the next letter
;  Deep dive: Extended text tokens
;
; ******************************************************************************

.MT26

 LDA #' '               ; Print a space
 JSR DASC

                        ; Fall through into MT19 to capitalise the next letter

; ******************************************************************************
;
;       Name: MT19
;       Type: Subroutine
;   Category: Text
;    Summary: Capitalise the next letter
;  Deep dive: Extended text tokens
;
; ------------------------------------------------------------------------------
;
; This routine sets the following:
;
;   * DTW8 = %00000000 (capitalise the next letter)
;
; ******************************************************************************

.MT19

 LDA #%00000000         ; Set DTW8 = %00000000
 STA DTW8

 RTS                    ; Return from the subroutine

; ******************************************************************************
;
;       Name: VOWEL
;       Type: Subroutine
;   Category: Text
;    Summary: Test whether a character is a vowel
;
; ------------------------------------------------------------------------------
;
; Arguments:
;
;   A                   The character to be tested
;
; Returns:
;
;   C flag              The C flag is set if the character is a vowel, otherwise
;                       it is clear
;
; ******************************************************************************

.VOWEL

 ORA #%00100000         ; Set bit 5 of the character to make it lower case

 CMP #'a'               ; If the letter is a vowel, jump to VRTS to return from
 BEQ VRTS               ; the subroutine with the C flag set (as the CMP will
 CMP #'e'               ; set the C flag if the comparison is equal)
 BEQ VRTS
 CMP #'i'
 BEQ VRTS
 CMP #'o'
 BEQ VRTS
 CMP #'u'
 BEQ VRTS

 CLC                    ; The character is not a vowel, so clear the C flag

.VRTS

 RTS                    ; Return from the subroutine

; ******************************************************************************
;
;       Name: TKN2
;       Type: Variable
;   Category: Text
;    Summary: The extended two-letter token lookup table
;  Deep dive: Extended text tokens
;
; ------------------------------------------------------------------------------
;
; Two-letter token lookup table for extended tokens 215-227.
;
; ******************************************************************************

.TKN2

 EQUB 12, 10            ; Token 215 = {crlf}
 EQUS "AB"              ; Token 216
 EQUS "OU"              ; Token 217
 EQUS "SE"              ; Token 218
 EQUS "IT"              ; Token 219
 EQUS "IL"              ; Token 220
 EQUS "ET"              ; Token 221
 EQUS "ST"              ; Token 222
 EQUS "ON"              ; Token 223
 EQUS "LO"              ; Token 224
 EQUS "NU"              ; Token 225
 EQUS "TH"              ; Token 226
 EQUS "NO"              ; Token 227

; ******************************************************************************
;
;       Name: QQ16
;       Type: Variable
;   Category: Text
;    Summary: The two-letter token lookup table
;  Deep dive: Printing text tokens
;
; ------------------------------------------------------------------------------
;
; Two-letter token lookup table for tokens 128-159. See the deep dive on
; "Printing text tokens" for details of how the two-letter token system works.
;
; ******************************************************************************

.QQ16

 EQUS "AL"              ; Token 128
 EQUS "LE"              ; Token 129
 EQUS "XE"              ; Token 130
 EQUS "GE"              ; Token 131
 EQUS "ZA"              ; Token 132
 EQUS "CE"              ; Token 133
 EQUS "BI"              ; Token 134
 EQUS "SO"              ; Token 135
 EQUS "US"              ; Token 136
 EQUS "ES"              ; Token 137
 EQUS "AR"              ; Token 138
 EQUS "MA"              ; Token 139
 EQUS "IN"              ; Token 140
 EQUS "DI"              ; Token 141
 EQUS "RE"              ; Token 142
 EQUS "A?"              ; Token 143
 EQUS "ER"              ; Token 144
 EQUS "AT"              ; Token 145
 EQUS "EN"              ; Token 146
 EQUS "BE"              ; Token 147
 EQUS "RA"              ; Token 148
 EQUS "LA"              ; Token 149
 EQUS "VE"              ; Token 150
 EQUS "TI"              ; Token 151
 EQUS "ED"              ; Token 152
 EQUS "OR"              ; Token 153
 EQUS "QU"              ; Token 154
 EQUS "AN"              ; Token 155
 EQUS "TE"              ; Token 156
 EQUS "IS"              ; Token 157
 EQUS "RI"              ; Token 158
 EQUS "ON"              ; Token 159

; ******************************************************************************
;
;       Name: BRIS
;       Type: Subroutine
;   Category: Missions
;    Summary: Clear the screen, display "INCOMING MESSAGE" and wait for 2
;             seconds
;
; ******************************************************************************

.BRIS

 LDA #216               ; Print extended token 216 ("{clear screen}{tab 6}{move
 JSR DETOK              ; to row 10, white, lower case}{white}{all caps}INCOMING
                        ; MESSAGE"

 JSR DrawViewInNMI2     ; ???

 LDY #100               ; Delay for 100 vertical syncs (100/50 = 2 seconds) and
 JMP DELAY              ; return from the subroutine using a tail call

; ******************************************************************************
;
;       Name: PAUSE
;       Type: Subroutine
;   Category: Keyboard
;    Summary: Display a rotating ship, waiting until a key is pressed, then
;             remove the ship from the screen
;
; ******************************************************************************

.PAUSE

 JSR DrawScreenInNMI_b0 ; ???

 JSR WaitForPPUToFinish ; Wait until both bitplanes of the screen have been
                        ; sent to the PPU, so the screen is fully updated and
                        ; there is no more data waiting to be sent to the PPU

 LDA tileNumber         ; ???
 STA firstPatternTile
 LDA #40
 STA maxTileNumber
 LDX #8
 STX firstNametableTile

.loop_CB392

 JSR PAS1_b0
 LDA controller1A
 ORA controller1B
 BPL loop_CB392

.loop_CB39D

 JSR PAS1_b0
 LDA controller1A
 ORA controller1B
 BMI loop_CB39D

 LDA #0                 ; Set the ship's AI flag to 0 (no AI) so it doesn't get
 STA INWK+31            ; any ideas of its own

 LDA #$93               ; Clear the screen and and set the view type in QQ11 to
 JSR TT66_b0            ; $93 (Mission 1 text briefing)

                        ; Fall through into MT23 to move to row 10, switch to
                        ; white text, and switch to lower case when printing
                        ; extended tokens

; ******************************************************************************
;
;       Name: MT23
;       Type: Subroutine
;   Category: Text
;    Summary: Move to row 9, switch to white text, and switch to lower case
;             when printing extended tokens
;  Deep dive: Extended text tokens
;
; ******************************************************************************

.MT23

 LDA #9                 ; Set A = 9, so when we fall through into MT29, the
                        ; text cursor gets moved to row 9

 EQUB $2C               ; Skip the next instruction by turning it into
                        ; $2C $A9 $06, or BIT $06A9, which does nothing apart
                        ; from affect the flags

                        ; Fall through into MT29 to move to the row in A, switch
                        ; to white text, and switch to lower case

; ******************************************************************************
;
;       Name: MT29
;       Type: Subroutine
;   Category: Text
;    Summary: Move to row 7, switch to white text, and switch to lower case when
;             printing extended tokens
;  Deep dive: Extended text tokens
;
; ******************************************************************************

.MT29

 LDA #7                 ; Move the text cursor to row 7
 STA YC

                        ; Fall through into MT13 to set bit 7 of DTW6 and bit 5
                        ; of DTW1

; ******************************************************************************
;
;       Name: MT13
;       Type: Subroutine
;   Category: Text
;    Summary: Switch to lower case when printing extended tokens
;  Deep dive: Extended text tokens
;
; ------------------------------------------------------------------------------
;
; This routine sets the following:
;
;   * DTW1 = %10000000 (???)
;
;   * DTW6 = %10000000 (lower case is enabled)
;
; ******************************************************************************

.MT13

 LDA #%10000000         ; Set DTW1 = %10000000
 STA DTW1

 STA DTW6               ; Set DTW6 = %10000000

 RTS                    ; Return from the subroutine

; ******************************************************************************
;
;       Name: PAUSE2
;       Type: Subroutine
;   Category: Keyboard
;    Summary: Wait until a key is pressed, ignoring any existing key press
;
; ------------------------------------------------------------------------------
;
; Returns:
;
;
; ******************************************************************************

.PAUSE2

 JSR DrawScreenInNMI_b0 ; ???

.loop_CB3C4

 JSR SetupPPUForIconBar ; If the PPU has started drawing the icon bar, configure
                        ; the PPU to use nametable 0 and pattern table 0

 LDA controller1A
 ORA controller1B
 AND #$C0
 CMP #$40
 BNE loop_CB3C4

 RTS                    ; Return from the subroutine

; ******************************************************************************
;
;       Name: RUPLA_LO
;       Type: Variable
;   Category: Text
;    Summary: Address lookup table for the RUPLA text token table in three
;             different languages (low byte)
;
; ******************************************************************************

.RUPLA_LO

 EQUB LO(RUPLA - 1)     ; English

 EQUB LO(RUPLA_DE - 1)  ; German

 EQUB LO(RUPLA_FR - 1)  ; French

 EQUB $43               ; There is no fourth language, so this byte is ignored

; ******************************************************************************
;
;       Name: RUPLA_HI
;       Type: Variable
;   Category: Text
;    Summary: Address lookup table for the RUPLA text token table in three
;             different languages (high byte)
;
; ******************************************************************************

.RUPLA_HI

 EQUB HI(RUPLA - 1)     ; English

 EQUB HI(RUPLA_DE - 1)  ; German

 EQUB HI(RUPLA_FR - 1)  ; French

 EQUB $AB               ; There is no fourth language, so this byte is ignored

; ******************************************************************************
;
;       Name: RUGAL_LO
;       Type: Variable
;   Category: Text
;    Summary: Address lookup table for the RUGAL text token table in three
;             different languages (low byte)
;
; ******************************************************************************

.RUGAL_LO

 EQUB LO(RUGAL - 1)     ; English

 EQUB LO(RUGAL_DE - 1)  ; German

 EQUB LO(RUGAL_FR - 1)  ; French

 EQUB $5A               ; There is no fourth language, so this byte is ignored

; ******************************************************************************
;
;       Name: RUGAL_HI
;       Type: Variable
;   Category: Text
;    Summary: Address lookup table for the RUGAL text token table in three
;             different languages (high byte)
;
; ******************************************************************************

.RUGAL_HI

 EQUB HI(RUGAL - 1)     ; English

 EQUB HI(RUGAL_DE - 1)  ; German

 EQUB HI(RUGAL_FR - 1)  ; French

 EQUB $AB               ; There is no fourth language, so this byte is ignored

; ******************************************************************************
;
;       Name: NRU
;       Type: Variable
;   Category: Text
;    Summary: The number of planetary systems with extended system description
;             overrides in the RUTOK table (NRU%) in three different languages
;
; ******************************************************************************

.NRU

 EQUB 23                ; English

 EQUB 23                ; German

 EQUB 23                ; French

 EQUB 23                ; There is no fourth language, so this byte is ignored

; ******************************************************************************
;
;       Name: PDESC
;       Type: Subroutine
;   Category: Text
;    Summary: Print the system's extended description or a mission 1 directive
;  Deep dive: Extended system descriptions
;             Extended text tokens
;
; ------------------------------------------------------------------------------
;
; This prints a specific system's extended description. This is called the "pink
; volcanoes string" in a comment in the original source, and the "goat soup"
; recipe by Ian Bell on his website (where he also refers to the species string
; as the "pink felines" string).
;
; For some special systems, when you are docked at them, the procedurally
; generated extended description is overridden and a text token from the RUTOK
; table is shown instead. If mission 1 is in progress, then a number of systems
; along the route of that mission's story will show custom mission-related
; directives in place of that system's normal "goat soup" phrase.
;
; Arguments:
;
;   ZZ                  The system number (0-255)
;
; ******************************************************************************

.PDESC

 LDA QQ8                ; If either byte in QQ18(1 0) is non-zero, meaning that
 ORA QQ8+1              ; the distance from the current system to the selected
 BNE PD1                ; is non-zero, jump to PD1 to show the standard "goat
                        ; soup" description

 LDA QQ12               ; If QQ12 does not have bit 7 set, which means we are
 BPL PD1                ; not docked, jump to PD1 to show the standard "goat
                        ; soup" description

 LDX languageIndex      ; ???
 LDA RUPLA_LO,X
 STA SC
 LDA RUPLA_HI,X
 STA SC+1
 LDA RUGAL_LO,X
 STA SC2
 LDA RUGAL_HI,X
 STA SC2+1

 LDY NRU,X

.PDL1

 LDA (SC),Y
 CMP systemNumber
 BNE PD2
 LDA (SC2),Y

 AND #%01111111         ; Extract bits 0-6 of A

 CMP GCNT               ; If the result does not equal the current galaxy
 BNE PD2                ; number, jump to PD2 to keep looping through the system
                        ; numbers in RUPLA

 LDA (SC2),Y            ; ???
 BMI PD3

 LDA TP                 ; Fetch bit 0 of TP into the C flag, and skip to PD1 if
 LSR A                  ; it is clear (i.e. if mission 1 is not in progress) to
 BCC PD1                ; print the "goat soup" extended description

                        ; If we get here then mission 1 is in progress, so we
                        ; print out the corresponding token from RUTOK

 JSR MT14               ; Call MT14 to switch to justified text

 LDA #1                 ; Set A = 1 so that extended token 1 (an empty string)
                        ; gets printed below instead of token 176, followed by
                        ; the Y-th token in RUTOK

 EQUB $2C               ; Skip the next instruction by turning it into
                        ; $2C $A9 $B0, or BIT $B0A9, which does nothing apart
                        ; from affect the flags

.PD3

 LDA #176               ; Print extended token 176 ("{lower case}{justify}
 JSR DETOK2             ; {single cap}")

 TYA                    ; Print the extended token in Y from the second table
 JSR DETOK3             ; in RUTOK

 LDA #177               ; Set A = 177 so when we jump to PD4 in the next
                        ; instruction, we print token 177 (".{cr}{left align}")

 BNE PD4                ; Jump to PD4 to print the extended token in A and
                        ; return from the subroutine using a tail call

.PD2

 DEY                    ; Decrement the byte counter in Y

 BNE PDL1               ; Loop back to check the next byte in RUPLA until we
                        ; either find a match for the system in ZZ, or we fall
                        ; through into the "goat soup" extended description
                        ; routine

.PD1

                        ; We now print the "goat soup" extended description

 LDX #3                 ; We now want to seed the random number generator with
                        ; the s1 and s2 16-bit seeds from the current system, so
                        ; we get the same extended description for each system
                        ; every time we call PDESC, so set a counter in X for
                        ; copying 4 bytes

{
.PDL1                   ; This label is a duplicate of the label above (which is
                        ; why we need to surround it with braces, as BeebAsm
                        ; doesn't allow us to redefine labels, unlike BBC BASIC)

 LDA QQ15+2,X           ; Copy QQ15+2 to QQ15+5 (s1 and s2) to RAND to RAND+3
 STA RAND,X

 DEX                    ; Decrement the loop counter

 BPL PDL1               ; Loop back to PDL1 until we have copied all

 LDA #5                 ; Set A = 5, so we print extended token 5 in the next
                        ; instruction ("{lower case}{justify}{single cap}[86-90]
                        ; IS [140-144].{cr}{left align}"
}

.PD4

 JMP DETOK              ; Print the extended token given in A, and return from
                        ; the subroutine using a tail call

; ******************************************************************************
;
;       Name: TT27
;       Type: Subroutine
;   Category: Text
;    Summary: Print a text token
;  Deep dive: Printing text tokens
;
; ------------------------------------------------------------------------------
;
; Print a text token (i.e. a character, control code, two-letter token or
; recursive token).
;
; Arguments:
;
;   A                   The text token to be printed
;
; ******************************************************************************

.TT27S

 JMP PrintCtrlCode_b0   ; ???

.TT27

 PHA                    ; Store A on the stack, so we can retrieve it below

 SETUP_PPU_FOR_ICON_BAR ; If the PPU has started drawing the icon bar, configure
                        ; the PPU to use nametable 0 and pattern table 0

 PLA                    ; Restore A from the stack

 TAX                    ; Copy the token number from A to X. We can then keep
                        ; decrementing X and testing it against zero, while
                        ; keeping the original token number intact in A; this
                        ; effectively implements a switch statement on the
                        ; value of the token

 BMI TT43               ; If token > 127, this is either a two-letter token
                        ; (128-159) or a recursive token (160-255), so jump
                        ; to TT43 to process tokens

 CMP #$0A
 BCC TT27S

 CMP #96                ; By this point, token is either 7, or in 10-127.
 BCS ex                 ; Check token number in A and if token >= 96, then the
                        ; token is in 96-127, which is a recursive token, so
                        ; jump to ex, which prints recursive tokens in this
                        ; range (i.e. where the recursive token number is
                        ; correct and doesn't need correcting)

 CMP #14                ; If token < 14, skip the following two instructions
 BCC P%+6

 CMP #32                ; If token < 32, then this means token is in 14-31, so
 BCC qw                 ; this is a recursive token that needs 114 adding to it
                        ; to get the recursive token number, so jump to qw
                        ; which will do this

                        ; By this point, token is either 7 (beep) or in 10-13
                        ; (line feeds and carriage returns), or in 32-95
                        ; (ASCII letters, numbers and punctuation)

 LDX QQ17               ; Fetch QQ17, which controls letter case, into X

 BEQ TT44               ; If QQ17 = 0, then ALL CAPS is set, so jump to TT44
                        ; to print this character as is (i.e. as a capital)

 BMI TT41               ; If QQ17 has bit 7 set, then we are using Sentence
                        ; Case, so jump to TT41, which will print the
                        ; character in upper or lower case, depending on
                        ; whether this is the first letter in a word

 BIT QQ17               ; If we get here, QQ17 is not 0 and bit 7 is clear, so
 BVS TT44               ; either it is bit 6 that is set, or some other flag in
                        ; QQ17 is set (bits 0-5). So check whether bit 6 is set.
                        ; If it is, then ALL CAPS has been set (as bit 7 is
                        ; clear) but bit 6 is still indicating that the next
                        ; character should be printed in lower case, so we need
                        ; to fix this. We do this with a jump to TT44, which
                        ; will print this character in upper case and clear bit
                        ; 6, so the flags are consistent with ALL CAPS going
                        ; forward ???

                        ; If we get here, some other flag is set in QQ17 (one
                        ; of bits 0-5 is set), which shouldn't happen in this
                        ; version of Elite. If this were the case, then we
                        ; would fall through into TT42 to print in lower case,
                        ; which is how printing all words in lower case could
                        ; be supported (by setting QQ17 to 1, say)

; ******************************************************************************
;
;       Name: TT42
;       Type: Subroutine
;   Category: Text
;    Summary: Print a letter in lower case
;
; ------------------------------------------------------------------------------
;
; Arguments:
;
;   A                   The character to be printed. Can be one of the
;                       following:
;
;                         * 7 (beep)
;
;                         * 10-13 (line feeds and carriage returns)
;
;                         * 32-95 (ASCII capital letters, numbers and
;                           punctuation)
;
; Other entry points:
;
;   TT44                Jumps to TT26 to print the character in A (used to
;                       enable us to use a branch instruction to jump to TT26)
;
; ******************************************************************************

.TT42

 TAX                    ; Convert the character in A into lower case by looking
 LDA lowerCase,X        ; up the lower case ASCII value from the lowerCase table

.TT44

 JMP TT26               ; Print the character in A

; ******************************************************************************
;
;       Name: TT41
;       Type: Subroutine
;   Category: Text
;    Summary: Print a letter according to Sentence Case
;
; ------------------------------------------------------------------------------
;
; The rules for printing in Sentence Case are as follows:
;
;   * If QQ17 bit 6 is set, print lower case (via TT45)
;
;   * If QQ17 bit 6 is clear, then:
;
;       * If character is punctuation, just print it
;
;       * If character is a letter, set QQ17 bit 6 and print letter as a capital
;
; Arguments:
;
;   A                   The character to be printed. Can be one of the
;                       following:
;
;                         * 7 (beep)
;
;                         * 10-13 (line feeds and carriage returns)
;
;                         * 32-95 (ASCII capital letters, numbers and
;                           punctuation)
;
;   X                   Contains the current value of QQ17
;
;   QQ17                Bit 7 is set
;
; ******************************************************************************

.TT41

                        ; If we get here, then QQ17 has bit 7 set, so we are in
                        ; Sentence Case

 BIT QQ17               ; If QQ17 also has bit 6 set, jump to TT45 to print
 BVS TT45               ; this character in lower case

                        ; If we get here, then QQ17 has bit 6 clear and bit 7
                        ; set, so we are in Sentence Case and we need to print
                        ; the next letter in upper case

 JMP DASC               ; Jump to DASC to print the character in A

; ******************************************************************************
;
;       Name: qw
;       Type: Subroutine
;   Category: Text
;    Summary: Print a recursive token in the range 128-145
;
; ------------------------------------------------------------------------------
;
; Print a recursive token where the token number is in 128-145 (so the value
; passed to TT27 is in the range 14-31).
;
; Arguments:
;
;   A                   A value from 128-145, which refers to a recursive token
;                       in the range 14-31
;
; ******************************************************************************

.qw

 ADC #114               ; This is a recursive token in the range 0-95, so add
 BNE ex                 ; 114 to the argument to get the token number 128-145
                        ; and jump to ex to print it

; ******************************************************************************
;
;       Name: TT45
;       Type: Subroutine
;   Category: Text
;    Summary: Print a letter in lower case
;
; ------------------------------------------------------------------------------
;
; This routine prints a letter in lower case. Specifically:
;
;   * If QQ17 = 255, abort printing this character as printing is disabled
;
;   * If this is a letter then print in lower case
;
;   * Otherwise this is punctuation, so clear bit 6 in QQ17 and print
;
; Arguments:
;
;   A                   The character to be printed. Can be one of the
;                       following:
;
;                         * 7 (beep)
;
;                         * 10-13 (line feeds and carriage returns)
;
;                         * 32-95 (ASCII capital letters, numbers and
;                           punctuation)
;
;   X                   Contains the current value of QQ17
;
;   QQ17                Bits 6 and 7 are set
;
; ******************************************************************************

.TT45

                        ; If we get here, then QQ17 has bit 6 and 7 set, so we
                        ; are in Sentence Case and we need to print the next
                        ; letter in lower case

 CPX #255               ; If QQ17 = 255 then printing is disabled, so if it
 BNE TT42               ; isn't disabled, jump to TT42 to print the character

 RTS                    ; Printing is disables, so return from the subroutine

; ******************************************************************************
;
;       Name: TT43
;       Type: Subroutine
;   Category: Text
;    Summary: Print a two-letter token or recursive token 0-95
;
; ------------------------------------------------------------------------------
;
; Print a two-letter token, or a recursive token where the token number is in
; 0-95 (so the value passed to TT27 is in the range 160-255).
;
; Arguments:
;
;   A                   One of the following:
;
;                         * 128-159 (two-letter token)
;
;                         * 160-255 (the argument to TT27 that refers to a
;                           recursive token in the range 0-95)
;
; ******************************************************************************

.TT43

 CMP #160               ; If token >= 160, then this is a recursive token, so
 BCS TT47               ; jump to TT47 below to process it

 AND #127               ; This is a two-letter token with number 128-159. The
 ASL A                  ; set of two-letter tokens is stored in a lookup table
                        ; at QQ16, with each token taking up two bytes, so to
                        ; convert this into the token's position in the table,
                        ; we subtract 128 (or just clear bit 7) and multiply
                        ; by 2 (or shift left)

 TAY                    ; Transfer the token's position into Y so we can look
                        ; up the token using absolute indexed mode

 LDA QQ16,Y             ; Get the first letter of the token and print it
 JSR TT27

 LDA QQ16+1,Y           ; Get the second letter of the token

 CMP #'?'               ; If the second letter of the token is a question mark
 BNE TT27               ; then this is a one-letter token, so if it isn't a
                        ; question mark, jump to TT27 to print the second letter

 RTS                    ; The second letter is a question mark, so return from
                        ; the subroutine without printing it

.TT47

 SBC #160               ; This is a recursive token in the range 160-255, so
                        ; subtract 160 from the argument to get the token
                        ; number 0-95 and fall through into ex to print it

; ******************************************************************************
;
;       Name: ex
;       Type: Subroutine
;   Category: Text
;    Summary: Print a recursive token
;  Deep dive: Printing text tokens
;
; ------------------------------------------------------------------------------
;
; This routine works its way through the recursive text tokens that are stored
; in tokenised form in the table at QQ18, and when it finds token number A,
; it prints it. Tokens are null-terminated in memory and fill three pages,
; but there is no lookup table as that would consume too much memory, so the
; only way to find the correct token is to start at the beginning and look
; through the table byte by byte, counting tokens as we go until we are in the
; right place. This approach might not be terribly speed efficient, but it is
; certainly memory-efficient.
;
; Arguments:
;
;   A                   The recursive token to be printed, in the range 0-148
;
; Other entry points:
;
;   TT48                Contains an RTS
;
; ******************************************************************************

.ex

 TAX                    ; Copy the token number into X

 LDA QQ18Lo             ; Set V(1 0) to point to the recursive token table at
 STA V                  ; location QQ18
 LDA QQ18Hi
 STA V+1

 LDY #0                 ; Set a counter Y to point to the character offset
                        ; as we scan through the table

 TXA                    ; Copy the token number back into A, so both A and X
                        ; now contain the token number we want to print

 BEQ TT50               ; If the token number we want is 0, then we have
                        ; already found the token we are looking for, so jump
                        ; to TT50, otherwise start working our way through the
                        ; null-terminated token table until we find the X-th
                        ; token

.TT51

 LDA (V),Y              ; Fetch the Y-th character from the token table page
                        ; we are currently scanning

 BEQ TT49               ; If the character is null, we've reached the end of
                        ; this token, so jump to TT49

 INY                    ; Increment character pointer and loop back around for
 BNE TT51               ; the next character in this token, assuming Y hasn't
                        ; yet wrapped around to 0

 INC V+1                ; If it has wrapped round to 0, we have just crossed
 BNE TT51               ; into a new page, so increment V+1 so that V points
                        ; to the start of the new page

.TT49

 SETUP_PPU_FOR_ICON_BAR ; If the PPU has started drawing the icon bar, configure
                        ; the PPU to use nametable 0 and pattern table 0

 INY                    ; Increment the character pointer

 BNE TT59               ; If Y hasn't just wrapped around to 0, skip the next
                        ; instruction

 INC V+1                ; We have just crossed into a new page, so increment
                        ; V+1 so that V points to the start of the new page

.TT59

 DEX                    ; We have just reached a new token, so decrement the
                        ; token number we are looking for

 BNE TT51               ; Assuming we haven't yet reached the token number in
                        ; X, look back up to keep fetching characters

.TT50

                        ; We have now reached the correct token in the token
                        ; table, with Y pointing to the start of the token as
                        ; an offset within the page pointed to by V, so let's
                        ; print the recursive token. Because recursive tokens
                        ; can contain other recursive tokens, we need to store
                        ; our current state on the stack, so we can retrieve
                        ; it after printing each character in this token

 TYA                    ; Store the offset in Y on the stack
 PHA

 LDA V+1                ; Store the high byte of V (the page containing the
 PHA                    ; token we have found) on the stack, so the stack now
                        ; contains the address of the start of this token

 LDA (V),Y              ; Load the character at offset Y in the token table,
                        ; which is the next character of this token that we
                        ; want to print

 EOR #RE                ; Tokens are stored in memory having been EOR'd with the
                        ; value of RE - which is 35 for all versions of Elite
                        ; except for NES, where RE is 62 - so we repeat the
                        ; EOR to get the actual character to print

 JSR TT27               ; Print the text token in A, which could be a letter,
                        ; number, control code, two-letter token or another
                        ; recursive token

 PLA                    ; Restore the high byte of V (the page containing the
 STA V+1                ; token we have found) into V+1

 PLA                    ; Restore the offset into Y
 TAY

 INY                    ; Increment Y to point to the next character in the
                        ; token we are printing

 BNE P%+4               ; If Y is zero then we have just crossed into a new
 INC V+1                ; page, so increment V+1 so that V points to the start
                        ; of the new page

 LDA (V),Y              ; Load the next character we want to print into A

 BNE TT50               ; If this is not the null character at the end of the
                        ; token, jump back up to TT50 to print the next
                        ; character, otherwise we are done printing

.TT48

 RTS                    ; Return from the subroutine

; ******************************************************************************
;
;       Name: TT26
;       Type: Subroutine
;   Category: Text
;    Summary: Print a character at the text cursor, with support for verified
;             text in extended tokens
;  Deep dive: Extended text tokens
;
; ------------------------------------------------------------------------------
;
; Arguments:
;
;   A                   The character to print
;
; Returns:
;
;   X                   X is preserved
;
;   C flag              The C flag is cleared
;
; Other entry points:
;
;   DASC                DASC does exactly the same as TT26 and prints a
;                       character at the text cursor, with support for verified
;                       text in extended tokens
;
; ******************************************************************************

.DASC

.TT26

 STA SC+1               ; Store A in SC+1, so we can retrieve it later

 SETUP_PPU_FOR_ICON_BAR ; If the PPU has started drawing the icon bar, configure
                        ; the PPU to use nametable 0 and pattern table 0

 LDA SC+1               ; Restore A from SC+1

 STX SC                 ; Store X in SC, so we can retrieve it below

 LDX #%11111111         ; Set DTW8 = %11111111, to disable the effect of {19} if
 STX DTW8               ; it was set (as {19} capitalises one character only)

 CMP #' '               ; If the character in A is one of the following:
 BEQ DA8                ;
 CMP #'.'               ;   * Space
 BEQ DA8                ;   * Full stop
 CMP #':'               ;   * Colon
 BEQ DA8                ;   * Apostrophe (ASCII 39)
 CMP #39                ;   * Open bracket
 BEQ DA8                ;   * Line feed
 CMP #'('               ;   * Carriage return
 BEQ DA8                ;   * Hyphen
 CMP #10                ;
 BEQ DA8                ; then skip the following instructions
 CMP #12
 BEQ DA8
 CMP #'-'
 BEQ DA8

 LDA QQ17               ; ???
 ORA #$40
 STA QQ17

 INX                    ; Increment X to 0, so DTW2 gets set to %00000000 below

 BEQ CB53C

.DA8

 LDA QQ17               ; ???
 AND #$BF
 STA QQ17

.CB53C

 STX DTW2               ; Store X in DTW2, so DTW2 is now:
                        ;
                        ;   * %00000000 if this character is a word terminator
                        ;
                        ;   * %11111111 if it isn't
                        ;
                        ; so DTW2 indicates whether or not we are currently
                        ; printing a word

 LDX SC                 ; Retrieve the original value of X from SC

 LDA SC+1               ; Retrieve the original value of A from SC+1 (i.e. the
                        ; character to print)

 BIT DTW4               ; If bit 7 of DTW4 is set then we are currently printing
 BMI P%+5               ; justified text, so skip the next instruction

 JMP CHPR               ; Bit 7 of DTW4 is clear, so jump down to CHPR to print
                        ; this character, as we are not printing justified text

                        ; If we get here then we are printing justified text, so
                        ; we need to buffer the text until we reach the end of
                        ; the paragraph, so we can then pad it out with spaces

 BIT DTW4               ; If bit 6 of DTW4 is set, then this is an in-flight
 BVS P%+6               ; message and we should buffer the carriage return
                        ; character {12}, so skip the following two instructions

 CMP #12                ; If the character in A is a carriage return, then we
 BEQ DA1                ; have reached the end of the paragraph, so jump down to
                        ; DA1 to print out the contents of the buffer,
                        ; justifying it as we go

                        ; If we get here then we need to buffer this character
                        ; in the line buffer at BUF

 LDX DTW5               ; DTW5 contains the current size of the buffer, so this
 STA BUF,X              ; stores the character in A at BUF + DTW5, the next free
                        ; space in the buffer

 LDX SC                 ; Retrieve the original value of X from SC so we can
                        ; preserve it through this subroutine call

 INC DTW5               ; Increment the size of the BUF buffer that is stored in
                        ; DTW5

 SETUP_PPU_FOR_ICON_BAR ; If the PPU has started drawing the icon bar, configure
                        ; the PPU to use nametable 0 and pattern table 0

 CLC                    ; Clear the C flag

 RTS                    ; Return from the subroutine

.DA63S

 JMP DA6+3              ; Jump down to DA6+3 (this is used by the branch
                        ; instruction below as it's too far to branch directly)

.DA6S

 JMP DA6                ; Jump down to DA6 (this is used by the branch
                        ; instruction below as it's too far to branch directly)

.DA1

                        ; If we get here then we are justifying text and we have
                        ; reached the end of the paragraph, so we need to print
                        ; out the contents of the buffer, justifying it as we go

 TXA                    ; Store X and Y on the stack
 PHA
 TYA
 PHA

.DA5

 LDX DTW5               ; Set X = DTW5, which contains the size of the buffer

 BEQ DA63S              ; If X = 0 then the buffer is empty, so jump down to
                        ; DA6+3 via DA63S to print a newline

 CPX #(LL+1)            ; If X < LL+1, i.e. X <= LL, then the buffer contains
 BCC DA6S               ; fewer than LL characters, which is less than a line
                        ; length, so jump down to DA6 via DA6S to print the
                        ; contents of BUF followed by a newline, as we don't
                        ; justify the last line of the paragraph

                        ; Otherwise X > LL, so the buffer does not fit into one
                        ; line, and we therefore need to justify the text, which
                        ; we do one line at a time

 LSR SC+1               ; Shift SC+1 to the right, which clears bit 7 of SC+1,
                        ; so we pass through the following comparison on the
                        ; first iteration of the loop and set SC+1 to %01000000

.DA11

 LDA SC+1               ; If bit 7 of SC+1 is set, skip the following two
 BMI P%+6               ; instructions

 LDA #%01000000         ; Set SC+1 = %01000000
 STA SC+1

 LDY #(LL-1)            ; Set Y = line length, so we can loop backwards from the
                        ; end of the first line in the buffer using Y as the
                        ; loop counter

.DAL1

 LDA BUF+LL             ; If the LL-th byte in BUF is a space, jump down to DA2
 CMP #' '               ; to print out the first line from the buffer, as it
 BEQ DA2                ; fits the line width exactly (i.e. it's justified)

                        ; We now want to find the last space character in the
                        ; first line in the buffer, so we loop through the line
                        ; using Y as a counter

.DAL2

 SETUP_PPU_FOR_ICON_BAR ; If the PPU has started drawing the icon bar, configure
                        ; the PPU to use nametable 0 and pattern table 0

 DEY                    ; Decrement the loop counter in Y

 BMI DA11               ; If Y <= 0, loop back to DA11, as we have now looped
 BEQ DA11               ; through the whole line

 LDA BUF,Y              ; If the Y-th byte in BUF is not a space, loop back up
 CMP #' '               ; to DAL2 to check the next character
 BNE DAL2

                        ; Y now points to a space character in the line buffer

 ASL SC+1               ; Shift SC+1 to the left

 BMI DAL2               ; If bit 7 of SC+1 is set, jump to DAL2 to find the next
                        ; space character

                        ; We now want to insert a space into the line buffer at
                        ; position Y, which we do by shifting every character
                        ; after position Y along by 1, and then inserting the
                        ; space

 STY SC                 ; Store Y in SC, so we want to insert the space at
                        ; position SC

 LDY DTW5               ; Fetch the buffer size from DTW5 into Y, to act as a
                        ; loop counter for moving the line buffer along by 1

.DAL6

 SETUP_PPU_FOR_ICON_BAR ; If the PPU has started drawing the icon bar, configure
                        ; the PPU to use nametable 0 and pattern table 0

 LDA BUF,Y              ; Copy the Y-th character from BUF into the Y+1-th
 STA BUF+1,Y            ; position

 DEY                    ; Decrement the loop counter in Y

 CPY SC                 ; Loop back to shift the next character along, until we
 BCS DAL6               ; have moved the SC-th character (i.e. Y < SC)

 INC DTW5               ; Increment the buffer size in DTW5

 LDA #' '               ; ???

                        ; We've now shifted the line to the right by 1 from
                        ; position SC onwards, so SC and SC+1 both contain
                        ; spaces, and Y is now SC-1 as we did a DEY just before
                        ; the end of the loop - in other words, we have inserted
                        ; a space at position SC, and Y points to the character
                        ; before the newly inserted space

                        ; We now want to move the pointer Y left to find the
                        ; next space in the line buffer, before looping back to
                        ; check whether we are done, and if not, insert another
                        ; space

.DAL3

 CMP BUF,Y              ; If the character at position Y is not a space, jump to
 BNE DAL1               ; DAL1 to see whether we have now justified the line

 DEY                    ; Decrement the loop counter in Y

 BPL DAL3               ; Loop back to check the next character to the left,
                        ; until we have found a space

 BMI DA11               ; Jump back to DA11 (this BMI is effectively a JMP as
                        ; we already passed through a BPL to get here)

.DA2

                        ; This subroutine prints out a full line of characters
                        ; from the start of the line buffer in BUF, followed by
                        ; a newline. It then removes that line from the buffer,
                        ; shuffling the rest of the buffer contents down

 LDX #LL                ; Call DAS1 to print out the first LL characters from
 JSR DAS1               ; the line buffer in BUF

 LDA #12                ; Print a newline
 JSR CHPR

 LDA DTW5               ; Subtract #LL from the end-of-buffer pointer in DTW5
 SBC #LL                ;
 STA DTW5               ; The subtraction works as CHPR clears the C flag

 TAX                    ; Copy the new value of DTW5 into X

 BEQ DA6+3              ; If DTW5 = 0 then jump down to DA6+3 to print a newline
                        ; as the buffer is now empty

                        ; If we get here then we have printed our line but there
                        ; is more in the buffer, so we now want to remove the
                        ; line we just printed from the start of BUF

 LDY #0                 ; Set Y = 0 to count through the characters in BUF

 INX                    ; Increment X, so it now contains the number of
                        ; characters in the buffer (as DTW5 is a zero-based
                        ; pointer and is therefore equal to the number of
                        ; characters minus 1)

 JSR SetupPPUForIconBar ; If the PPU has started drawing the icon bar, configure
                        ; the PPU to use nametable 0 and pattern table 0

.DAL4

 LDA BUF+LL+1,Y         ; Copy the Y-th character from BUF+LL to BUF
 STA BUF,Y

 INY                    ; Increment the character pointer

 DEX                    ; Decrement the character count

 BNE DAL4               ; Loop back to copy the next character until we have
                        ; shuffled down the whole buffer

 JMP DA5                ; Jump back to DA5

.DAS1

                        ; This subroutine prints out X characters from BUF,
                        ; returning with X = 0

 LDY #0                 ; Set Y = 0 to point to the first character in BUF

.DAL5

 LDA BUF,Y              ; Print the Y-th character in BUF using CHPR, which also
 JSR CHPR               ; clears the C flag for when we return from the
                        ; subroutine below

 INY                    ; Increment Y to point to the next character

 DEX                    ; Decrement the loop counter

 BNE DAL5               ; Loop back for the next character until we have printed
                        ; X characters from BUF

 RTS                    ; Return from the subroutine

.DA6

 JSR DAS1               ; Call DAS1 to print X characters from BUF, returning
                        ; with X = 0

 STX DTW5               ; Set the buffer size in DTW5 to 0, as the buffer is now
                        ; empty

 PLA                    ; Restore Y and X from the stack
 TAY
 PLA
 TAX

 LDA #12                ; Set A = 12, so when we skip BELL and fall through into
                        ; CHPR, we print character 12, which is a newline

.DA7

 EQUB $2C               ; Skip the next instruction by turning it into
                        ; $2C $A9 $07, or BIT $07A9, which does nothing apart
                        ; from affect the flags

                        ; Fall through into CHPR (skipping BELL) to print the
                        ; character and return with the C flag cleared

; ******************************************************************************
;
;       Name: BELL
;       Type: Subroutine
;   Category: Sound
;    Summary: Make a standard system beep
;
; ------------------------------------------------------------------------------
;
; This is the standard system beep, as made by the ASCII 7 "BELL" control code.
;
; ******************************************************************************

.BELL

 LDA #7                 ; Control code 7 makes a beep, so load this into A

 JMP CHPR               ; Call the CHPR print routine to actually make the sound

; ******************************************************************************
;
;       Name: CHPR
;       Type: Subroutine
;   Category: Text
;    Summary: Print a character at the text cursor by poking into screen memory
;
; ------------------------------------------------------------------------------
;
; Print a character at the text cursor (XC, YC), do a beep, print a newline,
; or delete left (backspace).
;
; Arguments:
;
;   A                   The character to be printed. Can be one of the
;                       following:
;
;                         * 7 (beep)
;
;                         * 10-13 (line feeds and carriage returns)
;
;                         * 32-95 (ASCII capital letters, numbers and
;                           punctuation)
;
;                         * 127 (delete the character to the left of the text
;                           cursor and move the cursor to the left)
;
;   XC                  Contains the text column to print at (the x-coordinate)
;
;   YC                  Contains the line number to print on (the y-coordinate)
;
; Returns:
;
;   A                   A is preserved
;
;   X                   X is preserved
;
;   Y                   Y is preserved
;
;   C flag              The C flag is cleared
;
; ******************************************************************************

.R5

 JMP CB75B

.CB627

 LDA #2
 STA YC
 LDA K3
 JMP CB652

.RR4S

 JMP CB75B

.TT67X

 LDA #12                ; Set A to a carriage return character

                        ; Fall through into CHPR to print the newline

.CHPR

 STA K3                 ; Store the A register in K3 so we can retrieve it below

 SETUP_PPU_FOR_ICON_BAR ; If the PPU has started drawing the icon bar, configure
                        ; the PPU to use nametable 0 and pattern table 0

 LDA K3                 ; Store the A, X and Y registers, so we can restore
 STY YSAV2              ; them at the end (so they don't get changed by this
 STX XSAV2              ; routine)

 LDY QQ17               ; Load the QQ17 flag, which contains the text printing
                        ; flags

 CPY #255               ; If QQ17 = 255 then printing is disabled, so jump to
 BEQ RR4S               ; RR4S (via the JMP in RR4S) to restore the registers
                        ; and return from the subroutine using a tail call

.CB652

 CMP #7                 ; If this is a beep character (A = 7), jump to R5,
 BEQ R5                 ; which will emit the beep, restore the registers and
                        ; return from the subroutine

 CMP #32                ; If this is an ASCII character (A >= 32), jump to RR1
 BCS RR1                ; below, which will print the character, restore the
                        ; registers and return from the subroutine

 CMP #10                ; If this is control code 10 (line feed) then jump to
 BEQ RRX1               ; RRX1, which will move down a line, restore the
                        ; registers and return from the subroutine

 LDX #1                 ; If we get here, then this is control code 11-13, of
 STX XC                 ; which only 13 is used. This code prints a newline,
                        ; which we can achieve by moving the text cursor
                        ; to the start of the line (carriage return) and down
                        ; one line (line feed). These two lines do the first
                        ; bit by setting XC = 1, and we then fall through into
                        ; the line feed routine that's used by control code 10

.RRX1

 CMP #13                ; If this is control code 13 (carriage return) then jump
 BEQ RR4S               ; to RR4 (via the JMP in RR4S) to restore the registers
                        ; and return from the subroutine using a tail call

 INC YC                 ; Increment the text cursor y-coordinate to move it
                        ; down one row

 BNE RR4S               ; Jump to RR4 to restore the registers and return from
                        ; the subroutine using a tail call (this BNE is
                        ; effectively a JMP as Y will never be zero)

.RR1

                        ; If we get here, then the character to print is an
                        ; ASCII character in the range 32-95

 LDX XC
 CPX #$1F
 BCC CB676
 LDX #1
 STX XC
 INC YC

.CB676

 LDX YC
 CPX #$1B
 BCC CB67F
 JMP CB627

.CB67F

 CMP #$7F
 BNE CB686
 JMP CB7BF

.CB686

 INC XC

 LDA QQ11               ; If bits 4 and 5 of the view number are clear, jump to
 AND #%00110000         ; CB6A9
 BEQ CB6A9

 LDY fontBitplane       ; If we are drawing in bitplane 1 only, jump to CB6A4
 CPY #1
 BEQ CB6A4

 AND #%00100000         ; If bit 5 of the view number is clear, jump to CB6A9
 BEQ CB6A9

                        ; If we get here then bit 5 of the view number is set
                        ; and we are not drawing in bitplane 1 only (i.e. we
                        ; are definitely drawing in bitplane 0)

 CPY #2                 ; If we are drawing in both bitplanes (as Y is neither
 BNE CB6A9              ; 1 or 2), jump to CB6A9

                        ; If we get here then we are drawing in bitplane 0 only

 LDA K3
 CLC
 ADC #$5F

 JMP CB7CF

.CB6A4

                        ; If we get here then we are drawing in bitplane 1 only
                        ; and bit 4 and/or 5 of the view number is set

 LDA K3
 JMP CB7CF

.CB6A9

                        ; If we get here then either bit 5 or bit 6 of the view
                        ; number are clear, or we are drawing in both bitplanes

 LDA K3                 ; If the character to print in K3 is not a space, jump
 CMP #' '               ; to CB6B2 with the character in A
 BNE CB6B2

 JMP CB75B              ; We are printing a space, so jump to CB75B to return
                        ; from the subroutine

.CB6B2

 TAY                    ; Set Y to the character to print

 CLC
 ADC #$FD

 LDX #0
 STX P+2
 ASL A
 ROL P+2
 ASL A
 ROL P+2
 ASL A
 ROL P+2
 ADC #0
 STA P+1
 LDA P+2
 ADC #$FC
 STA P+2

 LDA #0
 STA SC+1

 LDA YC
 BNE CB6D8

 JMP CB8A6

.CB6D8

 LDA QQ11               ; If this is not the space view (i.e. QQ11 is non-zero)
 BNE CB6DF              ; then jump to CB6DF to skip the following instruction

 JMP CB83E

.CB6DF

 JSR GetRowNameAddress  ; Get the addresses in the nametable buffers for the
                        ; start of character row YC, as follows:
                        ;
                        ;   SC(1 0) = the address in nametable buffer 0
                        ;
                        ;   SC2(1 0) = the address in nametable buffer 1

 LDY XC
 DEY
 LDA (SC),Y
 BEQ CB6E9

.CB6E9

 LDA tileNumber
 BEQ CB75B
 CMP #$FF
 BEQ CB75B
 STA (SC),Y
 STA (SC2),Y
 INC tileNumber
 LDY fontBitplane
 DEY
 BEQ CB772
 DEY
 BNE CB702
 JMP CB784

.CB702

 TAY
 LDX #$0C
 STX SC2+1
 ASL A
 ROL SC2+1
 ASL A
 ROL SC2+1
 ASL A
 ROL SC2+1
 STA SC2
 TYA
 LDX #$0D
 STX SC+1
 ASL A
 ROL SC+1
 ASL A
 ROL SC+1
 ASL A
 ROL SC+1
 STA SC
 LDY #0
 LDA (P+1),Y
 STA (SC),Y
 STA (SC2),Y
 INY
 LDA (P+1),Y
 STA (SC),Y
 STA (SC2),Y
 INY
 LDA (P+1),Y
 STA (SC),Y
 STA (SC2),Y
 INY
 LDA (P+1),Y
 STA (SC),Y
 STA (SC2),Y
 INY
 LDA (P+1),Y
 STA (SC),Y
 STA (SC2),Y
 INY
 LDA (P+1),Y
 STA (SC),Y
 STA (SC2),Y
 INY
 LDA (P+1),Y
 STA (SC),Y
 STA (SC2),Y
 INY
 LDA (P+1),Y
 STA (SC2),Y
 STA (SC),Y

.CB75B

 LDY YSAV2
 LDX XSAV2

 SETUP_PPU_FOR_ICON_BAR ; If the PPU has started drawing the icon bar, configure
                        ; the PPU to use nametable 0 and pattern table 0

 LDA K3
 CLC
 RTS

.CB772

 LDX #$0C
 STX SC+1
 ASL A
 ROL SC+1
 ASL A
 ROL SC+1
 ASL A
 ROL SC+1
 STA SC
 JMP CB793

.CB784

 LDX #$0D
 STX SC+1
 ASL A
 ROL SC+1
 ASL A
 ROL SC+1
 ASL A
 ROL SC+1
 STA SC

.CB793

 LDY #0
 LDA (P+1),Y
 STA (SC),Y
 INY
 LDA (P+1),Y
 STA (SC),Y
 INY
 LDA (P+1),Y
 STA (SC),Y
 INY
 LDA (P+1),Y
 STA (SC),Y
 INY
 LDA (P+1),Y
 STA (SC),Y
 INY
 LDA (P+1),Y
 STA (SC),Y
 INY
 LDA (P+1),Y
 STA (SC),Y
 INY
 LDA (P+1),Y
 STA (SC),Y
 JMP CB75B

.CB7BF

 JSR GetRowNameAddress  ; Get the addresses in the nametable buffers for the
                        ; start of character row YC, as follows:
                        ;
                        ;   SC(1 0) = the address in nametable buffer 0
                        ;
                        ;   SC2(1 0) = the address in nametable buffer 1

 LDY XC
 DEC XC
 LDA #0
 STA (SC),Y
 STA (SC2),Y
 JMP CB75B

.CB7CF

 PHA

 JSR GetRowNameAddress  ; Get the addresses in the nametable buffers for the
                        ; start of character row YC, as follows:
                        ;
                        ;   SC(1 0) = the address in nametable buffer 0
                        ;
                        ;   SC2(1 0) = the address in nametable buffer 1

 PLA
 CMP #$20
 BEQ CB7E5

.loop_CB7D8

 CLC
 ADC L00D9

.loop_CB7DB

 LDY XC
 DEY
 STA (SC),Y
 STA (SC2),Y
 JMP CB75B

.CB7E5

 LDY QQ11
 CPY #$9D
 BEQ CB7EF
 CPY #$DF
 BNE loop_CB7D8

.CB7EF

 LDA #0
 BEQ loop_CB7DB

.CB7F3

 LDX pattBufferHiDiv8
 STX SC+1
 ASL A
 ROL SC+1
 ASL A
 ROL SC+1
 ASL A
 ROL SC+1
 STA SC
 LDY #0
 LDA (P+1),Y
 ORA (SC),Y
 STA (SC),Y
 INY
 LDA (P+1),Y
 ORA (SC),Y
 STA (SC),Y
 INY
 LDA (P+1),Y
 ORA (SC),Y
 STA (SC),Y
 INY
 LDA (P+1),Y
 ORA (SC),Y
 STA (SC),Y
 INY
 LDA (P+1),Y
 ORA (SC),Y
 STA (SC),Y
 INY
 LDA (P+1),Y
 ORA (SC),Y
 STA (SC),Y
 INY
 LDA (P+1),Y
 ORA (SC),Y
 STA (SC),Y
 INY
 LDA (P+1),Y
 ORA (SC),Y
 STA (SC),Y
 JMP CB75B

.CB83E

 LDA #0
 STA SC+1
 LDA YC
 BNE CB848
 LDA #$FF

.CB848

 CLC
 ADC #1
 ASL A
 ASL A
 ASL A
 ASL A
 ROL SC+1
 SEC
 ROL A
 STA SC
 LDA SC+1
 ROL A
 ADC nameBufferHi
 STA SC+1
 LDY XC
 DEY
 LDA (SC),Y
 BNE CB7F3
 LDA tileNumber
 BEQ CB8A3
 STA (SC),Y
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
 LDY #0
 LDA (P+1),Y
 STA (SC),Y
 INY
 LDA (P+1),Y
 STA (SC),Y
 INY
 LDA (P+1),Y
 STA (SC),Y
 INY
 LDA (P+1),Y
 STA (SC),Y
 INY
 LDA (P+1),Y
 STA (SC),Y
 INY
 LDA (P+1),Y
 STA (SC),Y
 INY
 LDA (P+1),Y
 STA (SC),Y
 INY
 LDA (P+1),Y
 STA (SC),Y

.CB8A3

 JMP CB75B

.CB8A6

 LDA #$21
 STA SC
 LDA nameBufferHi
 STA SC+1
 LDY XC
 DEY
 JMP CB6E9

; ******************************************************************************
;
;       Name: lowerCase
;       Type: Variable
;   Category: Text
;    Summary: Lookup table for converting ASCII characters to lower case
;             characters in the game's text font
;
; ******************************************************************************

.lowerCase

 EQUB  0,  1,  2,  3    ; Control codes map to themselves
 EQUB  4,  5,  6,  7
 EQUB  8,  9, 10, 11
 EQUB 12, 13, 14, 15
 EQUB 16, 17, 18, 19
 EQUB 20, 21, 22, 23
 EQUB 24, 25, 26, 27
 EQUB 28, 29, 30, 31

 EQUS " !$/$%&'()*+,"   ; These punctuation characters map to themselves apart
 EQUS "-./0123456789"   ; from the following (ASCII on left, NES on right):
 EQUS ":;%*>?`"         ;
                        ;   " -> $
                        ;   # -> /
                        ;   < -> %
                        ;   = -> *
                        ;   @ -> `

 EQUS "abcdefghijklm"   ; Capital letters map to their lower case equivalents
 EQUS "nopqrstuvwxyz"

 EQUS "{|};+`"          ; These punctuation characters map to themselves apart
                        ; from the following (ASCII on left, NES on right):
                        ;
                        ;   [ -> {
                        ;   ; -> |
                        ;   ] -> }
                        ;   ^ to ;
                        ;   _ to +

 EQUS "abcdefghijklm"   ; Lower case characters map to themselves
 EQUS "nopqrstuvwxyz"

 EQUS "{|}~"            ; These punctuation characters map to themselves

 EQUB 127               ; Control codes map to themselves

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
; Save bank2.bin
;
; ******************************************************************************

 PRINT "S.bank2.bin ", ~CODE%, " ", ~P%, " ", ~LOAD%, " ", ~LOAD%
 SAVE "3-assembled-output/bank2.bin", CODE%, P%, LOAD%
