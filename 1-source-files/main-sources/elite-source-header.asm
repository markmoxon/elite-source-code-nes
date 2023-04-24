\ ******************************************************************************
\
\ NES ELITE GAME SOURCE (HEADER)
\
\ NES Elite was written by Ian Bell and David Braben and is copyright D. Braben
\ and I. Bell 1992
\
\ The code on this site has been reconstructed from a disassembly of the version
\ released on Ian Bell's personal website at http://www.elitehomepage.org/
\
\ The commentary is copyright Mark Moxon, and any misunderstandings or mistakes
\ in the documentation are entirely my fault
\
\ The terminology and notations used in this commentary are explained at
\ https://www.bbcelite.com/about_site/terminology_used_in_this_commentary.html
\
\ The deep dive articles referred to in this commentary can be found at
\ https://www.bbcelite.com/deep_dives
\
\ ------------------------------------------------------------------------------
\
\ This source file produces the following binary file:
\
\   * header.bin
\
\ ******************************************************************************

CODE% = $8000
LOAD% = $8000

ORG CODE%

EQUS "NES"
EQUB $1A

EQUB $08, $00, $12, $00
EQUD 0
EQUD 0

\ ******************************************************************************
\
\ Save header.bin
\
\ ******************************************************************************

\PRINT "S.header.bin ", ~CODE%, " ", ~P%, " ", ~LOAD%, " ", ~LOAD%
 SAVE "3-assembled-output/header.bin", CODE%, P%, LOAD%
