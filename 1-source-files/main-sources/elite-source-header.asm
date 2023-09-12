; ******************************************************************************
;
; NES ELITE GAME SOURCE (iNES HEADER)
;
; NES Elite was written by Ian Bell and David Braben and is copyright D. Braben
; and I. Bell 1991/1992
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
;   * header.bin
;
; ******************************************************************************

 INCLUDE "1-source-files/main-sources/elite-build-options.asm"

 _NTSC = (_VARIANT = 1)
 _PAL  = (_VARIANT = 2)

; ******************************************************************************
;
; ELITE iNES HEADER
;
; Produces the binary file header.bin.
;
; ******************************************************************************

 CODE% = $8000
 LOAD% = $8000

 ORG CODE%

; ******************************************************************************
;
;       Name: iNES header
;       Type: Variable
;   Category: Start and end
;    Summary: The iNES header for running in an emulator
;
; ******************************************************************************

 EQUS "NES", $1A        ; Identification string at the start of the header

 EQUB 8                 ; Byte #4 = 8 pages of 16K ROM = 128K

 EQUB 0                 ; Byte #5 = 0 = board uses CHR RAM

 EQUB %00010010         ; Byte #6 = mapper and WRAM configuration
                        ;
                        ;   * Bit 1 set = Cartridge contains battery-backed RAM
                        ;                 at $6000 to $7FFF
                        ;
                        ;   * Bits 4-7 = mapper number, %0001 = MMC1

 EQUB 0                 ; Bytes #7 to #15 are zero and have no effect
 EQUD 0
 EQUD 0

; ******************************************************************************
;
; Save header.bin
;
; ******************************************************************************

 PRINT "S.header.bin ", ~CODE%, " ", ~P%, " ", ~LOAD%, " ", ~LOAD%
 SAVE "3-assembled-output/header.bin", CODE%, P%, LOAD%
