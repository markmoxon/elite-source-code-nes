; ******************************************************************************
;
; NES ELITE GAME SOURCE (BANK 2)
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
;   * bank2.bin
;
; ******************************************************************************

 _BANK = 2

 INCLUDE "1-source-files/main-sources/elite-build-options.asm"

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
                        ;
                        ; Encoded as:   ""

 EJMP 19                ; Token 1:      "{single cap}YES"
 ECHR 'Y'               ;
 ETWO 'E', 'S'          ; Encoded as:   "{19}YES"
 EQUB VE

 EJMP 19                ; Token 1:      "{single cap}NO"
 ETWO 'N', 'O'          ;
 EQUB VE                ; Encoded as:   "{19}<227>"

 EJMP 2                 ; Token 3:      "{sentence case}{single cap}IMAGINEER
 EJMP 19                ;                {single cap}PRESENTS"
 ECHR 'I'               ;
 ETWO 'M', 'A'          ; Encoded as:   "{2}{19}I<239>G<240>E<244>{26}P<242>
 ECHR 'G'               ;                <218>NTS"
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

 EJMP 19                ; Token 4:      "{single cap}ENGLISH"
 ETWO 'E', 'N'          ;
 ECHR 'G'               ; Encoded as:   "{19}<246>GLISH"
 ECHR 'L'
 ECHR 'I'
 ECHR 'S'
 ECHR 'H'
 EQUB VE

 ETOK 176               ; Token 5:      "{lower case}
 ERND 18                ;                {justify}
 ETOK 202               ;                {single cap}[86-90] IS [140-144].{cr}
 ERND 19                ;                {left align}"
 ETOK 177               ;
 EQUB VE                ; Encoded as:   "[176][18?][202][19?][177]"

 EJMP 19                ; Token 6:      "{single cap}LICENSED{cr}
 ECHR 'L'               ;                 TO"
 ECHR 'I'               ;
 ETWO 'C', 'E'          ; Encoded as:   "{19}LI<233>N<218>D{13} TO"
 ECHR 'N'
 ETWO 'S', 'E'
 ECHR 'D'
 EJMP 13
 ECHR ' '
 ECHR 'T'
 ECHR 'O'
 EQUB VE

 EJMP 19                ; Token 7:      "{single cap}LICENSED BY {single 
 ECHR 'L'               ;                cap}NINTENDO"
 ECHR 'I'               ;
 ETWO 'C', 'E'          ; Encoded as:   "{19}LI<233>N<218>D BY{26}N<240>T<246>D
 ECHR 'N'               ;                O"
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

 EJMP 19                ; Token 8:      "{single cap}NEW {single cap}NAME: "
 ECHR 'N'               ;
 ECHR 'E'               ; Encoded as:   "{19}NEW{26}NAME: "
 ECHR 'W'
 EJMP 26
 ECHR 'N'
 ECHR 'A'
 ECHR 'M'
 ECHR 'E'
 ECHR ':'
 ECHR ' '
 EQUB VE

 EJMP 19                ; Token 9:      "{single cap}IMAGINEER {single cap}CO.
 ECHR 'I'               ;                {single cap}LTD., {single cap}JAPAN"
 ETWO 'M', 'A'          ;
 ECHR 'G'               ; Encoded as:   "{19}I<239>G<240>E<244>{26}CO.{26}LTD.,
 ETWO 'I', 'N'          ;                {26}JAP<255>"
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

 EJMP 23                ; Token 10:     "{move to row 9, lower case}
 EJMP 14                ;                {justify}
 EJMP 13                ;                {lower case}
 EJMP 19                ;                {single cap}GREETINGS {single 
 ECHR 'G'               ;                cap}COMMANDER {commander name}, {single
 ETWO 'R', 'E'          ;                 cap}I {lower case}AM {sentence case}
 ETWO 'E', 'T'          ;                {single cap}CAPTAIN {mission captain's
 ETWO 'I', 'N'          ;                name} OF{sentence case} HER MAJESTY'S
 ECHR 'G'               ;                SPACE NAVY{lower case} AND {single
 ECHR 'S'               ;                cap}I BEG A MOMENT OF YOUR VALUABLE
 ETOK 213               ;                TIME.{cr}
 ECHR ' '               ;                {cr}
 ETWO 'A', 'N'          ;                 {single cap}WE WOULD LIKE YOU TO DO A
 ECHR 'D'               ;                LITTLE JOB FOR US.{cr}
 EJMP 26                ;                {cr}
 ECHR 'I'               ;                 {single cap}THE SHIP YOU SEE HERE IS A
 ECHR ' '               ;                NEW MODEL, THE {single cap}CONSTRICTOR,
 ETWO 'B', 'E'          ;                EQUIPPED WITH A TOP SECRET NEW SHIELD
 ECHR 'G'               ;                GENERATOR.{cr}
 ETOK 208               ;                {cr}
 ECHR 'M'               ;                 {single cap}UNFORTUNATELY IT'S BEEN
 ECHR 'O'               ;                STOLEN.{cr}
 ECHR 'M'               ;                {cr}
 ETWO 'E', 'N'          ;                {single cap}{display ship, wait for
 ECHR 'T'               ;                key press}{single cap}IT WENT MISSING
 ECHR ' '               ;                FROM OUR SHIP YARD ON {single cap}XEER
 ECHR 'O'               ;                FIVE MONTHS AGO AND {mission 1 location
 ECHR 'F'               ;                hint}.{cr}
 ECHR ' '               ;                {cr}
 ETOK 179               ;                 {single cap}YOUR MISSION, SHOULD YOU
 ECHR 'R'               ;                DECIDE TO ACCEPT IT, IS TO SEEK AND
 ECHR ' '               ;                DESTROY THIS SHIP.{cr}
 ECHR 'V'               ;                {cr}
 ETWO 'A', 'L'          ;                 {single cap}YOU ARE CAUTIONED THAT
 ECHR 'U'               ;                ONLY {standard tokens, sentence case}
 ETWO 'A', 'B'          ;                MILITARY  LASERS{extended tokens} WILL
 ETWO 'L', 'E'          ;                GET THROUGH THE NEW SHIELDS AND THAT
 ECHR ' '               ;                THE {single cap}CONSTRICTOR IS FITTED
 ETWO 'T', 'I'          ;                WITH AN {standard tokens, sentence
 ECHR 'M'               ;                case}E.C.M.SYSTEM{extended tokens}.{cr}
 ECHR 'E'               ;                {cr}
 ETOK 204               ;                 {left align}{cr}
 ECHR 'W'               ;                {tab 6}{single cap}GOOD {single cap}
 ECHR 'E'               ;                LUCK, {single cap}COMMANDER.{cr}
 ECHR ' '               ;                 {left align}{cr}
 ECHR 'W'               ;                {tab 6}{all caps}  MESSAGE
 ETWO 'O', 'U'          ;                ENDS{display ship, wait for key press}"
 ECHR 'L'               ;
 ECHR 'D'               ; Encoded as:   "{23}{14}{13}{19}G<242><221><240>GS[213]
 ECHR ' '               ;                 AND{26}I <247>G[208]MOM<246>T OF [179]
 ECHR 'L'               ;                R V<228>U<216><229> <251>ME[204]WE W
 ECHR 'I'               ;                <217>LD LIKE [179][201]DO[208]L<219>T
 ECHR 'K'               ;                <229> JOB F<253> <236>[204][147][207]
 ECHR 'E'               ;                 [179] <218>E HE<242>[202]A[210]MODEL,
 ECHR ' '               ;                 <226>E{26}C<223><222>RICT<253>, E<254>
 ETOK 179               ;                IPP[196]W<219>H[208]TOP <218>CR<221>
 ETOK 201               ;                [210]SHIELD <231>N<244><245><253>[204]U
 ECHR 'D'               ;                NF<253>TUN<245>ELY <219>'S <247><246>
 ECHR 'O'               ;                 <222>O<229>N[204]{22}{19}<219> W<246>
 ETOK 208               ;                T MISS[195]FROM <217>R [207] Y<238>D
 ECHR 'L'               ;                 <223>{26}<230><244> FI<250> M<223>
 ETWO 'I', 'T'          ;                <226>S AGO[178]{28}[204][179]R MISSI
 ECHR 'T'               ;                <223>, SH<217>LD [179] DECIDE[201]AC
 ETWO 'L', 'E'          ;                <233>PT <219>, IS[201]<218>EK[178]DE
 ECHR ' '               ;                <222>ROY [148][207][204][179] <238>E CA
 ECHR 'J'               ;                U<251><223>[196]<226><245> <223>LY {6}
 ECHR 'O'               ;                [116]{5}S W<220>L G<221> <226>R<217>GH
 ECHR 'B'               ;                 [147]NEW SHIELDS[178]<226><245> <226>E
 ECHR ' '               ;                {26}C<223><222>RICT<253>[202]F<219>T
 ECHR 'F'               ;                [196]W<219>H <255> {6}[108]{5}[177]{8}
 ETWO 'O', 'R'          ;                {19}GOOD LUCK,{26}[154][212]{22}"
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
 TOKN 117
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
 TOKN 108
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

 EJMP 25                ; Token 11:     "{incoming message screen, wait 2s}
 EJMP 9                 ;                {clear screen}
 EJMP 23                ;                {move to row 9, lower case}
 EJMP 14                ;                {justify}
 ECHR ' '               ;                  ATTENTION {single cap}COMMANDER
 EJMP 26                ;                {commander name}, I {lower case}AM
 ETWO 'A', 'T'          ;                {sentence case} CAPTAIN {mission
 ECHR 'T'               ;                captain's name} {lower case}OF{sentence
 ETWO 'E', 'N'          ;                case} HER MAJESTY'S SPACE NAVY{lower
 ETWO 'T', 'I'          ;                case}. {single cap}WE HAVE NEED OF YOUR
 ETWO 'O', 'N'          ;                SERVICES AGAIN.{cr}
 ETOK 213               ;                {cr}
 ECHR '.'               ;                 {single cap}IF YOU WOULD BE SO GOOD AS
 EJMP 26                ;                TO GO TO {single cap}CEERDI YOU WILL BE
 ECHR 'W'               ;                BRIEFED.{cr}
 ECHR 'E'               ;                {cr}
 ECHR ' '               ;                 {single cap}IF SUCCESSFUL, YOU WILL BE
 ECHR 'H'               ;                WELL REWARDED.{cr}
 ECHR 'A'               ;                {cr}
 ETWO 'V', 'E'          ;                {left align}{cr}
 ECHR ' '               ;                {tab 6}{all caps}  MESSAGE
 ECHR 'N'               ;                ENDS{wait for key press}"
 ECHR 'E'               ;
 ETOK 196               ; Encoded as:   "{25}{9}{23}{14} {26}<245>T<246><251>
 ECHR 'O'               ;                <223>[213]. {19}WE HA<250> NE[196]OF
 ECHR 'F'               ;                 [179]R <218>RVI<233>S AGA<240>[204]
 ECHR ' '               ;                 [179] W<217>LD <247> <235> GOOD AS
 ETOK 179               ;                [201]GO TO{26}<233><244><241> [179] W
 ECHR 'R'               ;                <220>L <247> BRIEF<252>[204]IF SUC<233>
 ECHR ' '               ;                SSFUL, [179] W<220>L <247> WELL <242>W
 ETWO 'S', 'E'          ;                <238>D<252>[212]{24}"
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

 ECHR '('               ; Token 12:     "({single cap}C) {single cap}D.{single
 EJMP 19                ;                cap}BRABEN & {single cap}I.{single cap}
 ECHR 'C'               ;                BELL 1991"
 ECHR ')'               ;
 ETOK 197               ; Encoded as:   "({19}C) [191] 1991"
 ECHR ' '
 ECHR '1'
 ECHR '9'
 ECHR '9'
 ECHR '1'
 EQUB VE

 ECHR 'B'               ; Token 13:     "BY  {single cap}D.{single cap}BRABEN &
 ECHR 'Y'               ;                {single cap}I.{single cap}BELL"
 ETOK 197               ;
 EQUB VE                ; Encoded as:   "BY[197]]"

 EJMP 21                ; Token 14:     "{clear bottom of screen}
 ETOK 145               ;                PLANET {single cap}NAME? "
 ETOK 200               ;
 EQUB VE                ; Encoded as:   "{21}[145][200]"

 EJMP 25                ; Token 15:     "{incoming message screen, wait 2s}
 EJMP 9                 ;                {clear screen}
 EJMP 23                ;                {move to row 9, lower case}
 EJMP 14                ;                {justify}
 EJMP 13                ;                {lower case}  {single cap}
 ECHR ' '               ;                CONGRATULATIONS {single cap}
 EJMP 26                ;                COMMANDER!{cr}
 ECHR 'C'               ;                {cr}
 ETWO 'O', 'N'          ;                {single cap}THERE WILL ALWAYS BE A
 ECHR 'G'               ;                PLACE FOR YOU IN{sentence case} HER
 ECHR 'R'               ;                MAJESTY'S SPACE NAVY{lower case}.{cr}
 ETWO 'A', 'T'          ;                {cr}
 ECHR 'U'               ;                 {single cap}AND MAYBE SOONER THAN YOU
 ECHR 'L'               ;                THINK...{cr}
 ETWO 'A', 'T'          ;                {left align}{tab 6}{cr}
 ECHR 'I'               ;                {all caps}  MESSAGE
 ETWO 'O', 'N'          ;                ENDS{wait for key press}"
 ECHR 'S'               ;
 ECHR ' '               ; Encoded as:   "{25}{9}{23}{14}{13} {26}C<223>GR<245>UL
 ETOK 154               ;                <245>I<223>S [154]!{12}{12}{19}<226>
 ECHR '!'               ;                <244>E W<220>L <228>WAYS <247>[208]P
 EJMP 12                ;                <249><233> F<253> [179] <240>[211][204]
 EJMP 12                ;                <255>D <239>Y<247> <235><223><244>
 EJMP 19                ;                 <226><255> [179] <226><240>K..[212]
 ETWO 'T', 'H'          ;                {24}"
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

 ECHR 'F'               ; Token 16:     "FABLED"
 ETWO 'A', 'B'          ;
 ETWO 'L', 'E'          ; Encoded as:   "F<216><229>D"
 ECHR 'D'
 EQUB VE

 ETWO 'N', 'O'          ; Token 17:     "NOTABLE"
 ECHR 'T'               ;
 ETWO 'A', 'B'          ; Encoded as:   "<227>T<216><229>"
 ETWO 'L', 'E'
 EQUB VE

 ECHR 'W'               ; Token 18:     "WELL KNOWN"
 ECHR 'E'               ;
 ECHR 'L'               ; Encoded as:   "WELL K<227>WN"
 ECHR 'L'
 ECHR ' '
 ECHR 'K'
 ETWO 'N', 'O'
 ECHR 'W'
 ECHR 'N'
 EQUB VE

 ECHR 'F'               ; Token 19:     "FAMOUS"
 ECHR 'A'               ;
 ECHR 'M'               ; Encoded as:   "FAM<217>S"
 ETWO 'O', 'U'
 ECHR 'S'
 EQUB VE

 ETWO 'N', 'O'          ; Token 20:     "NOTED"
 ECHR 'T'               ;
 ETWO 'E', 'D'          ; Encoded as:   "<227>T<252>"
 EQUB VE

 ECHR 'V'               ; Token 21:     "VERY"
 ETWO 'E', 'R'          ;
 ECHR 'Y'               ; Encoded as:   "V<244>Y"
 EQUB VE

 ECHR 'M'               ; Token 22:     "MILDLY"
 ETWO 'I', 'L'          ;
 ECHR 'D'               ; Encoded as:   "M<220>DLY"
 ECHR 'L'
 ECHR 'Y'
 EQUB VE

 ECHR 'M'               ; Token 23:     "MOST"
 ECHR 'O'               ;
 ETWO 'S', 'T'          ; Encoded as:   "MO<222>"
 EQUB VE

 ETWO 'R', 'E'          ; Token 24:     "REASONABLY"
 ECHR 'A'               ;
 ECHR 'S'               ; Encoded as:   "<242>AS<223><216>LY"
 ETWO 'O', 'N'
 ETWO 'A', 'B'
 ECHR 'L'
 ECHR 'Y'
 EQUB VE

 EQUB VE                ; Token 25:     ""
                        ;
                        ; Encoded as:   ""

 ETOK 165               ; Token 26:     "ANCIENT"
 EQUB VE                ;
                        ; Encoded as:   "[165]"

 ERND 23                ; Token 27:     "[130-134]"
 EQUB VE                ;
                        ; Encoded as:   "[23?]"

 ECHR 'G'               ; Token 28:     "GREAT"
 ETWO 'R', 'E'          ;
 ETWO 'A', 'T'          ; Encoded as:   "G<242><245>"
 EQUB VE

 ECHR 'V'               ; Token 29:     "VAST"
 ECHR 'A'               ;
 ETWO 'S', 'T'          ; Encoded as:   "VA<222>"
 EQUB VE

 ECHR 'P'               ; Token 30:     "PINK"
 ETWO 'I', 'N'          ;
 ECHR 'K'               ; Encoded as:   "P<240>K"
 EQUB VE

 EJMP 2                 ; Token 31:     "{sentence case}[190-194] [185-189]
 ERND 28                ;                {lower case} PLANTATIONS"
 ECHR ' '               ;
 ERND 27                ; Encoded as:   "{2}[28?] [27?]{13} [185]<245>I<223>S"
 EJMP 13
 ECHR ' '
 ETOK 185
 ETWO 'A', 'T'
 ECHR 'I'
 ETWO 'O', 'N'
 ECHR 'S'
 EQUB VE

 ETOK 156               ; Token 32:     "MOUNTAINS"
 ECHR 'S'               ;
 EQUB VE                ; Encoded as:   "[156]S"

 ERND 26                ; Token 33:     "[180-184]"
 EQUB VE                ;
                        ; Encoded as:   "[26?]"

 ERND 37                ; Token 34:     "[125-129] FORESTS"
 ECHR ' '               ;
 ECHR 'F'               ; Encoded as:   "[37?] FO<242><222>S"
 ECHR 'O'
 ETWO 'R', 'E'
 ETWO 'S', 'T'
 ECHR 'S'
 EQUB VE

 ECHR 'O'               ; Token 35:     "OCEANS"
 ETWO 'C', 'E'          ;
 ETWO 'A', 'N'          ; Encoded as:   "O<233><255>S"
 ECHR 'S'
 EQUB VE

 ECHR 'S'               ; Token 36:     "SHYNESS"
 ECHR 'H'               ;
 ECHR 'Y'               ; Encoded as:   "SHYN<237>S"
 ECHR 'N'
 ETWO 'E', 'S'
 ECHR 'S'
 EQUB VE

 ECHR 'S'               ; Token 37:     "SILLINESS"
 ETWO 'I', 'L'          ;
 ECHR 'L'               ; Encoded as:   "S<220>L<240><237>S"
 ETWO 'I', 'N'
 ETWO 'E', 'S'
 ECHR 'S'
 EQUB VE

 ECHR 'T'               ; Token 38:     "TEA CEREMONIES"
 ECHR 'E'               ;
 ECHR 'A'               ; Encoded as:   "TEA <233><242>M<223>I<237>"
 ECHR ' '
 ETWO 'C', 'E'
 ETWO 'R', 'E'
 ECHR 'M'
 ETWO 'O', 'N'
 ECHR 'I'
 ETWO 'E', 'S'
 EQUB VE

 ETWO 'L', 'O'          ; Token 39:     "LOATHING OF [41-45]"
 ECHR 'A'               ;
 ETWO 'T', 'H'          ; Encoded as:   "<224>A<226>[195]OF [9?]"
 ETOK 195
 ECHR 'O'
 ECHR 'F'
 ECHR ' '
 ERND 9
 EQUB VE

 ETWO 'L', 'O'          ; Token 40:     "LOVE FOR [41-45]"
 ETWO 'V', 'E'          ;
 ECHR ' '               ; Encoded as:   "<224><250> F<253> [9?]"
 ECHR 'F'
 ETWO 'O', 'R'
 ECHR ' '
 ERND 9
 EQUB VE

 ECHR 'F'               ; Token 41:     "FOOD BLENDERS"
 ECHR 'O'               ;
 ECHR 'O'               ; Encoded as:   "FOOD B<229>ND<244>S"
 ECHR 'D'
 ECHR ' '
 ECHR 'B'
 ETWO 'L', 'E'
 ECHR 'N'
 ECHR 'D'
 ETWO 'E', 'R'
 ECHR 'S'
 EQUB VE

 ECHR 'T'               ; Token 42:     "TOURISTS"
 ETWO 'O', 'U'          ;
 ECHR 'R'               ; Encoded as:   "T<217>RI<222>S"
 ECHR 'I'
 ETWO 'S', 'T'
 ECHR 'S'
 EQUB VE

 ECHR 'P'               ; Token 43:     "POETRY"
 ECHR 'O'               ;
 ETWO 'E', 'T'          ; Encoded as:   "PO<221>RY"
 ECHR 'R'
 ECHR 'Y'
 EQUB VE

 ETWO 'D', 'I'          ; Token 44:     "DISCOS"
 ECHR 'S'               ;
 ECHR 'C'               ; Encoded as:   "<241>SCOS"
 ECHR 'O'
 ECHR 'S'
 EQUB VE

 ERND 17                ; Token 45:     "[81-85]"
 EQUB VE                ;
                        ; Encoded as:   "[17?]"

 ECHR 'W'               ; Token 46:     "WALKING TREE"
 ETWO 'A', 'L'          ;
 ECHR 'K'               ; Encoded as:   "W<228>K[195][158]"
 ETOK 195
 ETOK 158
 EQUB VE

 ECHR 'C'               ; Token 47:     "CRAB"
 ECHR 'R'               ;
 ETWO 'A', 'B'          ; Encoded as:   "CR<216>"
 EQUB VE

 ECHR 'B'               ; Token 48:     "BAT"
 ETWO 'A', 'T'          ;
 EQUB VE                ; Encoded as:   "B<245>"

 ETWO 'L', 'O'          ; Token 49:     "LOBST"
 ECHR 'B'               ;
 ETWO 'S', 'T'          ; Encoded as:   "<224>B<222>"
 EQUB VE

 EJMP 18                ; Token 50:     "{random 1-8 letter word}"
 EQUB VE                ;
                        ; Encoded as:   "{18}"

 ETWO 'B', 'E'          ; Token 51:     "BESET"
 ETWO 'S', 'E'          ;
 ECHR 'T'               ; Encoded as:   "<247><218>T"
 EQUB VE

 ECHR 'P'               ; Token 52:     "PLAGUED"
 ETWO 'L', 'A'          ;
 ECHR 'G'               ; Encoded as:   "P<249>GU<252>"
 ECHR 'U'
 ETWO 'E', 'D'
 EQUB VE

 ETWO 'R', 'A'          ; Token 53:     "RAVAGED"
 ECHR 'V'               ;
 ECHR 'A'               ; Encoded as:   "<248>VA<231>D"
 ETWO 'G', 'E'
 ECHR 'D'
 EQUB VE

 ECHR 'C'               ; Token 54:     "CURSED"
 ECHR 'U'               ;
 ECHR 'R'               ; Encoded as:   "CUR<218>D"
 ETWO 'S', 'E'
 ECHR 'D'
 EQUB VE

 ECHR 'S'               ; Token 55:     "SCOURGED"
 ECHR 'C'               ;
 ETWO 'O', 'U'          ; Encoded as:   "SC<217>R<231>D"
 ECHR 'R'
 ETWO 'G', 'E'
 ECHR 'D'
 EQUB VE

 ERND 22                ; Token 56:     "[135-139] CIVIL WAR"
 ECHR ' '               ;
 ECHR 'C'               ; Encoded as:   "[22?] CIV<220> W<238>"
 ECHR 'I'
 ECHR 'V'
 ETWO 'I', 'L'
 ECHR ' '
 ECHR 'W'
 ETWO 'A', 'R'
 EQUB VE

 ERND 13                ; Token 57:     "[170-174] [155-159] [160-164]S"
 ECHR ' '               ;
 ERND 4                 ; Encoded as:   "[13?] [4?] [5?]S"
 ECHR ' '
 ERND 5
 ECHR 'S'
 EQUB VE

 ECHR 'A'               ; Token 58:     "A [170-174] DISEASE"
 ECHR ' '               ;
 ERND 13                ; Encoded as:   "A [13?] <241><218>A<218>"
 ECHR ' '
 ETWO 'D', 'I'
 ETWO 'S', 'E'
 ECHR 'A'
 ETWO 'S', 'E'
 EQUB VE

 ERND 22                ; Token 59:     "[135-139] EARTHQUAKES"
 ECHR ' '               ;
 ECHR 'E'               ; Encoded as:   "[22?] E<238><226><254>AK<237>"
 ETWO 'A', 'R'
 ETWO 'T', 'H'
 ETWO 'Q', 'U'
 ECHR 'A'
 ECHR 'K'
 ETWO 'E', 'S'
 EQUB VE

 ERND 22                ; Token 60:     "[135-139] SOLAR ACTIVITY"
 ECHR ' '               ;
 ETWO 'S', 'O'          ; Encoded as:   "[22?] <235>L<238> AC<251>V<219>Y"
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

 ETOK 175               ; Token 61:     "ITS [26-30] [31-35]"
 ERND 2                 ;
 ECHR ' '               ; Encoded as:   "[175][2?] [3?]"
 ERND 3
 EQUB VE

 ETOK 147               ; Token 62:     "THE {system name adjective} [155-159]
 EJMP 17                ;                 [160-164]"
 ECHR ' '               ;
 ERND 4                 ; Encoded as:   "[147]{17} [4?] [5?]"
 ECHR ' '
 ERND 5
 EQUB VE

 ETOK 175               ; Token 63:     "ITS INHABITANTS [165-169] [36-40]"
 ETOK 193               ;
 ECHR 'S'               ; Encoded as:   "[175][193]S [7?] [8?]"
 ECHR ' '
 ERND 7
 ECHR ' '
 ERND 8
 EQUB VE

 EJMP 2                 ; Token 64:     "{sentence case}[235-239]{lower case}"
 ERND 31                ;
 EJMP 13                ; Encoded as:   "{2}[31?]{13}"
 EQUB VE

 ETOK 175               ; Token 65:     "ITS [76-80] [81-85]"
 ERND 16                ;
 ECHR ' '               ; Encoded as:   "[175][16?] [17?]"
 ERND 17
 EQUB VE

 ECHR 'J'               ; Token 66:     "JUICE"
 ECHR 'U'               ;
 ECHR 'I'               ; Encoded as:   "JUI<233>"
 ETWO 'C', 'E'
 EQUB VE

 ECHR 'D'               ; Token 67:     "DRINK"
 ECHR 'R'               ;
 ETWO 'I', 'N'          ; Encoded as:   "DR<240>K"
 ECHR 'K'
 EQUB VE

 ECHR 'W'               ; Token 68:     "WATER"
 ETWO 'A', 'T'          ;
 ETWO 'E', 'R'          ; Encoded as:   "W<245><244>"
 EQUB VE

 ECHR 'T'               ; Token 69:     "TEA"
 ECHR 'E'               ;
 ECHR 'A'               ; Encoded as:   "TEA"
 EQUB VE

 EJMP 19                ; Token 70:     "{single cap}GARGLE {single cap}
 ECHR 'G'               ;                BLASTERS"
 ETWO 'A', 'R'          ;
 ECHR 'G'               ; Encoded as:   "{19}G<238>G<229>{26}B<249><222><244>S"
 ETWO 'L', 'E'
 EJMP 26
 ECHR 'B'
 ETWO 'L', 'A'
 ETWO 'S', 'T'
 ETWO 'E', 'R'
 ECHR 'S'
 EQUB VE

 EJMP 18                ; Token 71:     "{random 1-8 letter word}"
 EQUB VE                ;
                        ; Encoded as:   "{18}"

 EJMP 17                ; Token 72:     "{system name adjective} [160-164]"
 ECHR ' '               ;
 ERND 5                 ; Encoded as:   "{17} [5?]"
 EQUB VE

 ETOK 191               ; Token 73:     "{system name adjective} {random 1-8
 EQUB VE                ;                letter word}"
                        ;
                        ; Encoded as:   "[191]"

 ETOK 192               ; Token 74:     ""{system name adjective} [170-174]"
 EQUB VE                ;
                        ; Encoded as:   "[192]"

 ERND 13                ; Token 75:     "[170-174] {random 1-8 letter word}"
 ECHR ' '               ;
 EJMP 18                ; Encoded as:   "[13?] {18}"
 EQUB VE

 ECHR 'F'               ; Token 76:     "FABULOUS"
 ETWO 'A', 'B'          ;
 ECHR 'U'               ; Encoded as:   "F<216>UL<217>S"
 ECHR 'L'
 ETWO 'O', 'U'
 ECHR 'S'
 EQUB VE

 ECHR 'E'               ; Token 77:     "EXOTIC"
 ECHR 'X'               ;
 ECHR 'O'               ; Encoded as:   "EXO<251>C"
 ETWO 'T', 'I'
 ECHR 'C'
 EQUB VE

 ECHR 'H'               ; Token 78:     "HOOPY"
 ECHR 'O'               ;
 ECHR 'O'               ; Encoded as:   "HOOPY"
 ECHR 'P'
 ECHR 'Y'
 EQUB VE

 ETOK 132               ; Token 79:     "UNUSUAL"
 EQUB VE                ;
                        ; Encoded as:   "[132]

 ECHR 'E'               ; Token 80:     "EXCITING"
 ECHR 'X'               ;
 ECHR 'C'               ; Encoded as:   "EXC<219><240>G"
 ETWO 'I', 'T'
 ETWO 'I', 'N'
 ECHR 'G'
 EQUB VE

 ECHR 'C'               ; Token 81:     "CUISINE"
 ECHR 'U'               ;
 ECHR 'I'               ; Encoded as:   "CUIS<240>E"
 ECHR 'S'
 ETWO 'I', 'N'
 ECHR 'E'
 EQUB VE

 ECHR 'N'               ; Token 82:     "NIGHT LIFE"
 ECHR 'I'               ;
 ECHR 'G'               ; Encoded as:   "NIGHT LIFE"
 ECHR 'H'
 ECHR 'T'
 ECHR ' '
 ECHR 'L'
 ECHR 'I'
 ECHR 'F'
 ECHR 'E'
 EQUB VE

 ECHR 'C'               ; Token 83:     "CASINOS"
 ECHR 'A'               ;
 ECHR 'S'               ; Encoded as:   "CASI<227>S"
 ECHR 'I'
 ETWO 'N', 'O'
 ECHR 'S'
 EQUB VE

 ECHR 'C'               ; Token 84:     "CINEMAS"
 ETWO 'I', 'N'          ;
 ECHR 'E'               ; Encoded as:   "C<240>E<239>S"
 ETWO 'M', 'A'
 ECHR 'S'
 EQUB VE

 EJMP 2                 ; Token 85:     "{sentence case}[235-239]{lower case}"
 ERND 31                ;
 EJMP 13                ; Encoded as:   "{2}[31?]{13}"
 EQUB VE

 EJMP 3                 ; Token 86:     "{selected system name}"
 EQUB VE                ;
                        ; Encoded as:   "{3}"

 ETOK 147               ; Token 87:     "THE PLANET {selected system name}"
 ETOK 145               ;
 ECHR ' '               ; Encoded as:   "[147][145] {3}"
 EJMP 3
 EQUB VE

 ETOK 147               ; Token 88:     "THE WORLD {selected system name}"
 ETOK 146               ;
 ECHR ' '               ; Encoded as:   "[147][146] {3}"
 EJMP 3
 EQUB VE

 ETOK 148               ; Token 89:     "THIS PLANET"
 ETOK 145               ;
 EQUB VE                ; Encoded as:   "[148][145]"

 ETOK 148               ; Token 90:     "THIS WORLD"
 ETOK 146               ;
 EQUB VE                ; Encoded as:   "[148][146]"

 ECHR 'S'               ; Token 91:     "SWINE"
 ECHR 'W'               ;
 ETWO 'I', 'N'          ; Encoded as:   "SE<240>E"
 ECHR 'E'
 EQUB VE

 ECHR 'S'               ; Token 92:     "SCOUNDREL"
 ECHR 'C'               ;
 ETWO 'O', 'U'          ; Encoded as:   "SC<217>ND<242>L"
 ECHR 'N'
 ECHR 'D'
 ETWO 'R', 'E'
 ECHR 'L'
 EQUB VE

 ECHR 'B'               ; Token 93:     "BLACKGUARD"
 ETWO 'L', 'A'          ;
 ECHR 'C'               ; Encoded as:   "B<249>CKGU<238>D"
 ECHR 'K'
 ECHR 'G'
 ECHR 'U'
 ETWO 'A', 'R'
 ECHR 'D'
 EQUB VE

 ECHR 'R'               ; Token 94:     "ROGUE"
 ECHR 'O'               ;
 ECHR 'G'               ; Encoded as:   "ROGUE"
 ECHR 'U'
 ECHR 'E'
 EQUB VE

 ECHR 'W'               ; Token 95:     "WRETCH"
 ECHR 'R'               ;
 ETWO 'E', 'T'          ; Encoded as:   "WR<221>CH"
 ECHR 'C'
 ECHR 'H'
 EQUB VE

 ECHR 'N'               ; Token 96:     "N UNREMARKABLE"
 ECHR ' '               ;
 ECHR 'U'               ; Encoded as:   "N UN<242>M<238>RK<216><229>"
 ECHR 'N'
 ETWO 'R', 'E'
 ECHR 'M'
 ETWO 'A', 'R'
 ECHR 'K'
 ETWO 'A', 'B'
 ETWO 'L', 'E'
 EQUB VE

 ECHR ' '               ; Token 97:     " BORING"
 ECHR 'B'               ;
 ETWO 'O', 'R'          ; Encoded as:   " B<253><240>G"
 ETWO 'I', 'N'
 ECHR 'G'
 EQUB VE

 ECHR ' '               ; Token 98:     " DULL"
 ECHR 'D'               ;
 ECHR 'U'               ; Encoded as:   " DULL"
 ECHR 'L'
 ECHR 'L'
 EQUB VE

 ECHR ' '               ; Token 99:     " TEDIOUS"
 ECHR 'T'               ;
 ECHR 'E'               ; Encoded as:   " TE<241><217>S"
 ETWO 'D', 'I'
 ETWO 'O', 'U'
 ECHR 'S'
 EQUB VE

 ECHR ' '               ; Token 100:    " REVOLTING"
 ETWO 'R', 'E'          ;
 ECHR 'V'               ; Encoded as:   " <242>VOLT<240>G"
 ECHR 'O'
 ECHR 'L'
 ECHR 'T'
 ETWO 'I', 'N'
 ECHR 'G'
 EQUB VE

 ETOK 145               ; Token 101:    "PLANET"
 EQUB VE                ;
                        ; Encoded as:   "[145]"

 ETOK 146               ; Token 102:    "WORLD"
 EQUB VE                ;
                        ; Encoded as:   "[146]"

 ECHR 'P'               ; Token 103:    "PLACE"
 ETWO 'L', 'A'          ;
 ETWO 'C', 'E'          ; Encoded as:   "P<249><233>"
 EQUB VE

 ECHR 'L'               ; Token 104:    "LITTLE PLANET"
 ETWO 'I', 'T'          ;
 ECHR 'T'               ; Encoded as:   "L<219>T<229> [145]"
 ETWO 'L', 'E'
 ECHR ' '
 ETOK 145
 EQUB VE

 ECHR 'D'               ; Token 105:    "DUMP"
 ECHR 'U'               ;
 ECHR 'M'               ; Encoded as:   "DUMP"
 ECHR 'P'
 EQUB VE

 EJMP 19                ; Token 106:    "{single cap}I HEAR A [130-134] LOOKING
 ECHR 'I'               ;                SHIP APPEARED AT ERRIUS"
 ECHR ' '               ;
 ECHR 'H'               ; Encoded as:   "{19}I HE<238>[208][23?] <224>OK[195]
 ECHR 'E'               ;                [207] APPE<238>[196]<245>[209]"
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

 EJMP 19                ;
 ECHR 'Y'               ; Token 107:    "{single cap}YEAH, I HEAR A [130-134]
 ECHR 'E'               ;                SHIP LEFT ERRIUS A  WHILE BACK"
 ECHR 'A'               ;
 ECHR 'H'               ; Encoded as:   "{19}YEAH, I HE<238>[208][23?] [207]
 ECHR ','               ;                 <229>FT[209][208] WH<220>E BACK"
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

 EJMP 19                ; Token 108:    "{single cap}GET YOUR IRON HIDE OVER TO
 ECHR 'G'               ;                ERRIUS"
 ETWO 'E', 'T'          ;
 ECHR ' '               ; Encoded as:   "{19}G<221> [179]R IR<223> HIDE OV<244>
 ETOK 179               ;                 TO[209]"
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

 ETWO 'S', 'O'          ; Token 109:    "SOME [91-95] NEW SHIP WAS SEEN AT
 ECHR 'M'               ;                ERRIUS"
 ECHR 'E'               ;
 ECHR ' '               ; Encoded as:   "<235>ME [24?][210][207] WAS <218><246>
 ERND 24                ;                 <245>[209]"
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

 ECHR 'T'               ; Token 110:    "TRY ERRIUS"
 ECHR 'R'               ;
 ECHR 'Y'               ; Encoded as:   "TRY[209]"
 ETOK 209
 EQUB VE

 ECHR ' '               ; Token 111:    " CUDDLY"
 ECHR 'C'               ;
 ECHR 'U'               ; Encoded as:   " CUDDLY"
 ECHR 'D'
 ECHR 'D'
 ECHR 'L'
 ECHR 'Y'
 EQUB VE

 ECHR ' '               ; Token 112:    " CUTE"
 ECHR 'C'               ;
 ECHR 'U'               ; Encoded as:   " CUTE"
 ECHR 'T'
 ECHR 'E'
 EQUB VE

 ECHR ' '               ; Token 113:    " FURRY"
 ECHR 'F'               ;
 ECHR 'U'               ; Encoded as:   " FURRY"
 ECHR 'R'
 ECHR 'R'
 ECHR 'Y'
 EQUB VE

 ECHR ' '               ; Token 114:    " FRIENDLY"
 ECHR 'F'               ;
 ECHR 'R'               ; Encoded as:   " FRI<246>DLY"
 ECHR 'I'
 ETWO 'E', 'N'
 ECHR 'D'
 ECHR 'L'
 ECHR 'Y'
 EQUB VE

 ECHR 'W'               ; Token 115:    "WASP"
 ECHR 'A'               ;
 ECHR 'S'               ; Encoded as:   "WASP"
 ECHR 'P'
 EQUB VE

 ECHR 'M'               ; Token 116:    "MOTH"
 ECHR 'O'               ;
 ETWO 'T', 'H'          ; Encoded as:   "MO<226>"
 EQUB VE

 ECHR 'G'               ; Token 117:    "GRUB"
 ECHR 'R'               ;
 ECHR 'U'               ; Encoded as:   "GRUB"
 ECHR 'B'
 EQUB VE

 ETWO 'A', 'N'          ; Token 118:    "ANT"
 ECHR 'T'               ;
 EQUB VE                ; Encoded as:   "<255>T"

 EJMP 18                ; Token 119:    "{random 1-8 letter word}"
 EQUB VE                ;
                        ; Encoded as:   "{18}"

 ECHR 'P'               ; Token 120:    "POET"
 ECHR 'O'               ;
 ETWO 'E', 'T'          ; Encoded as:   "PO<221>"
 EQUB VE

 ECHR 'H'               ; Token 121:    "HOG"
 ECHR 'O'               ;
 ECHR 'G'               ; Encoded as:   "HOG"
 EQUB VE

 ECHR 'Y'               ; Token 122:    "YAK"
 ECHR 'A'               ;
 ECHR 'K'               ; Encoded as:   "YAK"
 EQUB VE

 ECHR 'S'               ; Token 123:    "SNAIL"
 ECHR 'N'               ;
 ECHR 'A'               ; Encoded as:   "SNA<220>"
 ETWO 'I', 'L'
 EQUB VE

 ECHR 'S'               ; Token 124:    "SLUG"
 ECHR 'L'               ;
 ECHR 'U'               ; Encoded as:   "SLUG"
 ECHR 'G'
 EQUB VE

 ECHR 'T'               ; Token 125:    "TROPICAL"
 ECHR 'R'               ;
 ECHR 'O'               ; Encoded as:   "TROPIC<228>"
 ECHR 'P'
 ECHR 'I'
 ECHR 'C'
 ETWO 'A', 'L'
 EQUB VE

 ECHR 'D'               ; Token 126:    "DENSE"
 ETWO 'E', 'N'          ;
 ETWO 'S', 'E'          ; Encoded as:   "D<246><218>"
 EQUB VE

 ETWO 'R', 'A'          ; Token 127:    "RAIN"
 ETWO 'I', 'N'          ;
 EQUB VE                ; Encoded as:   "<248><240>"

 ECHR 'I'               ; Token 128:    "IMPENETRABLE"
 ECHR 'M'               ;
 ECHR 'P'               ; Encoded as:   "IMP<246><221>R<216><229>"
 ETWO 'E', 'N'
 ETWO 'E', 'T'
 ECHR 'R'
 ETWO 'A', 'B'
 ETWO 'L', 'E'
 EQUB VE

 ECHR 'E'               ; Token 129:    "EXUBERANT"
 ECHR 'X'               ;
 ECHR 'U'               ; Encoded as:   "EXUB<244><255>T"
 ECHR 'B'
 ETWO 'E', 'R'
 ETWO 'A', 'N'
 ECHR 'T'
 EQUB VE

 ECHR 'F'               ; Token 130:    "FUNNY"
 ECHR 'U'               ;
 ECHR 'N'               ; Encoded as:   "FUNNY"
 ECHR 'N'
 ECHR 'Y'
 EQUB VE

 ECHR 'W'               ; Token 131:    "WEIRD"
 ECHR 'E'               ;
 ECHR 'I'               ; Encoded as:   "WEIRD"
 ECHR 'R'               ;
 ECHR 'D'
 EQUB VE

 ECHR 'U'               ; Token 132:    "UNUSUAL"
 ETWO 'N', 'U'          ;
 ECHR 'S'               ; Encoded as:   "U<225>SU<228>"
 ECHR 'U'
 ETWO 'A', 'L'
 EQUB VE

 ETWO 'S', 'T'          ; Token 133:    "STRANGE"
 ETWO 'R', 'A'          ;
 ECHR 'N'               ; Encoded as:   "<222><248>N<231>"
 ETWO 'G', 'E'
 EQUB VE

 ECHR 'P'               ; Token 134:    "PECULIAR"
 ECHR 'E'               ;
 ECHR 'C'               ; Encoded as:   "PECULI<238>"
 ECHR 'U'
 ECHR 'L'
 ECHR 'I'
 ETWO 'A', 'R'
 EQUB VE

 ECHR 'F'               ; Token 135:    "FREQUENT"
 ETWO 'R', 'E'          ;
 ETWO 'Q', 'U'          ; Encoded as:   "F<242><254><246>T"
 ETWO 'E', 'N'
 ECHR 'T'
 EQUB VE

 ECHR 'O'               ; Token 136:    "OCCASIONAL"
 ECHR 'C'               ;
 ECHR 'C'               ; Encoded as:   "OCCASI<223><228>"
 ECHR 'A'
 ECHR 'S'
 ECHR 'I'
 ETWO 'O', 'N'
 ETWO 'A', 'L'
 EQUB VE

 ECHR 'U'               ; Token 137:    "UNPREDICTABLE"
 ECHR 'N'               ;
 ECHR 'P'               ; Encoded as:   "UNP<242><241>CT<216><229>"
 ETWO 'R', 'E'
 ETWO 'D', 'I'
 ECHR 'C'
 ECHR 'T'
 ETWO 'A', 'B'
 ETWO 'L', 'E'
 EQUB VE

 ECHR 'D'               ; Token 138:    "DREADFUL"
 ETWO 'R', 'E'          ;
 ECHR 'A'               ; Encoded as:   "D<242>ADFUL"
 ECHR 'D'
 ECHR 'F'
 ECHR 'U'
 ECHR 'L'
 EQUB VE

 ETOK 171               ; Token 139:    "DEADLY"
 EQUB VE                ;
                        ; Encoded as:   "[171]"

 ERND 1                 ; Token 140:    "[21-25] [16-20] FOR [61-65]"
 ECHR ' '               ;
 ERND 0                 ; Encoded as:   "[1?] [0?] F<253> [10?]"
 ECHR ' '
 ECHR 'F'
 ETWO 'O', 'R'
 ECHR ' '
 ERND 10
 EQUB VE

 ETOK 140               ; Token 141:    "[21-25] [16-20] FOR [61-65] AND
 ETOK 178               ;                [61-65]"
 ERND 10                ;
 EQUB VE                ; Encoded as:   "[140][178][10?]"

 ERND 11                ; Token 142:    "[51-55] BY [56-60]"
 ECHR ' '               ;
 ECHR 'B'               ; Encoded as:   "[11?] BY [12?]"
 ECHR 'Y'
 ECHR ' '
 ERND 12
 EQUB VE

 ETOK 140               ; Token 143:    "[21-25] [16-20] FOR [61-65] BUT [51-55]
 ECHR ' '               ;                BY [56-60]"
 ECHR 'B'               ;
 ECHR 'U'               ; Encoded as:   "[140] BUT [142]"
 ECHR 'T'
 ECHR ' '
 ETOK 142
 EQUB VE

 ECHR ' '               ; Token 144:    " A[96-100] [101-105]"
 ECHR 'A'               ;
 ERND 20                ; Encoded as:   " A[20?] [21?]"
 ECHR ' '
 ERND 21
 EQUB VE

 ECHR 'P'               ; Token 145:    "PLANET"
 ETWO 'L', 'A'          ;
 ECHR 'N'               ; Encoded as:   "P<249>N<221>"
 ETWO 'E', 'T'
 EQUB VE

 ECHR 'W'               ; Token 146:    "WORLD"
 ETWO 'O', 'R'          ;
 ECHR 'L'               ; Encoded as:   "W<253>LD"
 ECHR 'D'
 EQUB VE

 ETWO 'T', 'H'          ; Token 147:    "THE "
 ECHR 'E'               ;
 ECHR ' '               ; Encoded as:   "<226>E "
 EQUB VE

 ETWO 'T', 'H'          ; Token 148:    "THIS "
 ECHR 'I'               ;
 ECHR 'S'               ; Encoded as:   "<226>IS "
 ECHR ' '
 EQUB VE

 EQUB VE                ; Token 149:    ""
                        ;
                        ; Encoded as:   ""

 EJMP 9                 ; Token 150:    "{clear screen}
 EJMP 11                ;                {draw box around title}
 EJMP 1                 ;                {all caps}
 EJMP 8                 ;                {tab 6}"
 EQUB VE                ;
                        ; Encoded as:   "{9}{11}{1}{8}"

 EQUB VE                ; Token 151:    ""
                        ;
                        ; Encoded as:   ""

 EQUB VE                ; Token 152:    ""
                        ;
                        ; Encoded as:   ""

 ECHR 'I'               ; Token 153:    "IAN"
 ETWO 'A', 'N'          ;
 EQUB VE                ; Encoded as:   "I<255>"

 EJMP 19                ; Token 154:    "{single cap}COMMANDER"
 ECHR 'C'               ;
 ECHR 'O'               ; Encoded as:   "{19}COM<239>ND<244>"
 ECHR 'M'
 ETWO 'M', 'A'
 ECHR 'N'
 ECHR 'D'
 ETWO 'E', 'R'
 EQUB VE

 ERND 13                ; Token 155:    "[170-174]"
 EQUB VE                ;
                        ; Encoded as:   "[13?]"

 ECHR 'M'               ; Token 156:    "MOUNTAIN"
 ETWO 'O', 'U'          ;
 ECHR 'N'               ; Encoded as:   "M<217>NTA<240>"
 ECHR 'T'
 ECHR 'A'
 ETWO 'I', 'N'
 EQUB VE

 ECHR 'E'               ; Token 157:    "EDIBLE"
 ETWO 'D', 'I'          ;
 ECHR 'B'               ; Encoded as:   "E<241>B<229>"
 ETWO 'L', 'E'
 EQUB VE

 ECHR 'T'               ; Token 158:    "TREE"
 ETWO 'R', 'E'          ;
 ECHR 'E'               ; Encoded as:   "T<242>E"
 EQUB VE

 ECHR 'S'               ; Token 159:    "SPOTTED"
 ECHR 'P'               ;
 ECHR 'O'               ; Encoded as:   "SPOTT<252>"
 ECHR 'T'
 ECHR 'T'
 ETWO 'E', 'D'
 EQUB VE

 ERND 29                ; Token 160:    "[225-229]"
 EQUB VE                ;
                        ; Encoded as:   "[29?]"

 ERND 30                ; Token 161:    "[230-234]"
 EQUB VE                ;
                        ; Encoded as:   "[30?]"

 ERND 6                 ; Token 162:    "[46-50]OID"
 ECHR 'O'               ;
 ECHR 'I'               ; Encoded as:   "[6?]OID"
 ECHR 'D'
 EQUB VE

 ERND 36                ; Token 163:    "[120-124]"
 EQUB VE                ;
                        ; Encoded as:   "[36?]"

 ERND 35                ; Token 164:    "[115-119]"
 EQUB VE                ;
                        ; Encoded as:   "[35?]"

 ETWO 'A', 'N'          ; Token 165:    "ANCIENT"
 ECHR 'C'               ;
 ECHR 'I'               ; Encoded as:   "<255>CI<246>T"
 ETWO 'E', 'N'
 ECHR 'T'
 EQUB VE

 ECHR 'E'               ; Token 166:    "EXCEPTIONAL"
 ECHR 'X'               ;
 ETWO 'C', 'E'          ; Encoded as:   "EX<233>P<251><223><228>"
 ECHR 'P'
 ETWO 'T', 'I'
 ETWO 'O', 'N'
 ETWO 'A', 'L'
 EQUB VE

 ECHR 'E'               ; Token 167:    "ECCENTRIC"
 ECHR 'C'               ;
 ETWO 'C', 'E'          ; Encoded as:   "EC<233>NTRIC"
 ECHR 'N'
 ECHR 'T'
 ECHR 'R'
 ECHR 'I'
 ECHR 'C'
 EQUB VE

 ETWO 'I', 'N'          ; Token 168:    "INGRAINED"
 ECHR 'G'               ;
 ETWO 'R', 'A'          ; Encoded as:   "<240>G<248><240><252>"
 ETWO 'I', 'N'
 ETWO 'E', 'D'
 EQUB VE

 ERND 23                ; Token 169:    "[130-134]"
 EQUB VE                ;
                        ; Encoded as:   "[23?]"

 ECHR 'K'               ; Token 170:    "KILLER"
 ETWO 'I', 'L'          ;
 ETWO 'L', 'E'          ; Encoded as:   "K<220><229>R"
 ECHR 'R'
 EQUB VE

 ECHR 'D'               ; Token 171:    "DEADLY"
 ECHR 'E'               ;
 ECHR 'A'               ; Encoded as:   "DEADLY"
 ECHR 'D'
 ECHR 'L'
 ECHR 'Y'
 EQUB VE

 ECHR 'W'               ; Token 172:    "WICKED"
 ECHR 'I'               ;
 ECHR 'C'               ; Encoded as:   "WICK<252>"
 ECHR 'K'
 ETWO 'E', 'D'
 EQUB VE

 ECHR 'L'               ; Token 173:    "LETHAL"
 ETWO 'E', 'T'          ;
 ECHR 'H'               ; Encoded as:   "L<221>H<228>"
 ETWO 'A', 'L'
 EQUB VE

 ECHR 'V'               ; Token 174:    "VICIOUS"
 ECHR 'I'               ;
 ECHR 'C'               ; Encoded as:   "VICI<217>S"
 ECHR 'I'
 ETWO 'O', 'U'
 ECHR 'S'
 EQUB VE

 ETWO 'I', 'T'          ; Token 175:    "ITS "
 ECHR 'S'               ;
 ECHR ' '               ; Encoded as:   "<219>S "
 EQUB VE

 EJMP 13                ; Token 176:    "{lower case}
 EJMP 14                ;                {justify}
 EJMP 19                ;                {single cap}"
 EQUB VE                ;
                        ; Encoded as:   "{13}{14}{19}"

 ECHR '.'               ; Token 177:    ".{cr}
 EJMP 12                ;                {left align}"
 EJMP 15                ;
 EQUB VE                ; Encoded as:   ".{12}{15}"

 ECHR ' '               ; Token 178:    " AND "
 ETWO 'A', 'N'          ;
 ECHR 'D'               ; Encoded as:   " <255>D "
 ECHR ' '
 EQUB VE

 ECHR 'Y'               ; Token 179:    "YOU"
 ETWO 'O', 'U'          ;
 EQUB VE                ; Encoded as:   "Y<217>"

 ECHR 'P'               ; Token 180:    "PARKING METERS"
 ETWO 'A', 'R'          ;
 ECHR 'K'               ; Encoded as:   "P<238>K[195]M<221><244>S"
 ETOK 195
 ECHR 'M'
 ETWO 'E', 'T'
 ETWO 'E', 'R'
 ECHR 'S'
 EQUB VE

 ECHR 'D'               ; Token 181:    "DUST CLOUDS"
 ECHR 'U'               ;
 ETWO 'S', 'T'          ; Encoded as:   "DU<222> CL<217>DS"
 ECHR ' '
 ECHR 'C'
 ECHR 'L'
 ETWO 'O', 'U'
 ECHR 'D'
 ECHR 'S'
 EQUB VE

 ECHR 'I'               ; Token 182:    "ICE BERGS"
 ETWO 'C', 'E'          ;
 ECHR ' '               ; Encoded as:   "I<233> B<244>GS"
 ECHR 'B'
 ETWO 'E', 'R'
 ECHR 'G'
 ECHR 'S'
 EQUB VE

 ECHR 'R'               ; Token 183:    "ROCK FORMATIONS"
 ECHR 'O'               ;
 ECHR 'C'               ; Encoded as:   "ROCK F<253><239><251><223>S"
 ECHR 'K'
 ECHR ' '
 ECHR 'F'
 ETWO 'O', 'R'
 ETWO 'M', 'A'
 ETWO 'T', 'I'
 ETWO 'O', 'N'
 ECHR 'S'
 EQUB VE

 ECHR 'V'               ; Token 184:    "VOLCANOES"
 ECHR 'O'               ;
 ECHR 'L'               ; Encoded as:   "VOLCA<227><237>"
 ECHR 'C'
 ECHR 'A'
 ETWO 'N', 'O'
 ETWO 'E', 'S'
 EQUB VE

 ECHR 'P'               ; Token 185:    "PLANT"
 ETWO 'L', 'A'          ;
 ECHR 'N'               ; Encoded as:   "P<249>NT"
 ECHR 'T'
 EQUB VE

 ECHR 'T'               ; Token 186:    "TULIP"
 ECHR 'U'               ;
 ECHR 'L'               ; Encoded as:   "TULIP"
 ECHR 'I'
 ECHR 'P'
 EQUB VE

 ECHR 'B'               ; Token 187:    "BANANA"
 ETWO 'A', 'N'          ;
 ETWO 'A', 'N'          ; Encoded as:   "B<255><255>A"
 ECHR 'A'
 EQUB VE

 ECHR 'C'               ; Token 188:    "CORN"
 ETWO 'O', 'R'          ;
 ECHR 'N'               ; Encoded as:   "C<253>N"
 EQUB VE

 EJMP 18                ; Token 189:    "{random 1-8 letter word}WEED"
 ECHR 'W'               ;
 ECHR 'E'               ; Encoded as:   "{18}WE<252>"
 ETWO 'E', 'D'
 EQUB VE

 EJMP 18                ; Token 190:    "{random 1-8 letter word}"
 EQUB VE                ;
                        ; Encoded as:   "{18}"

 EJMP 17                ; Token 191:    "{system name adjective} {random 1-8
 ECHR ' '               ;                letter word}"
 EJMP 18                ;
 EQUB VE                ; Encoded as:   "{17} {18}"

 EJMP 17                ; Token 192:    "{system name adjective} [170-174]"
 ECHR ' '               ;
 ERND 13                ; Encoded as:   "{17} [13?]"
 EQUB VE

 ETWO 'I', 'N'          ; Token 193:    "INHABITANT"
 ECHR 'H'               ;
 ETWO 'A', 'B'          ; Encoded as:   "<240>H<216><219><255>T"
 ETWO 'I', 'T'
 ETWO 'A', 'N'
 ECHR 'T'
 EQUB VE

 ETOK 191               ; Token 194:    "{system name adjective} {random 1-8
 EQUB VE                ;                letter word}"
                        ;
                        ; Encoded as:   "[191]"

 ETWO 'I', 'N'          ; Token 195:    "ING "
 ECHR 'G'               ;
 ECHR ' '               ; Encoded as:   "<240>G "
 EQUB VE

 ETWO 'E', 'D'          ; Token 196:    "ED "
 ECHR ' '               ;
 EQUB VE                ; Encoded as:   "<252> "

 EJMP 26                ; Token 197:    " {single cap}D.{single cap}BRABEN &
 ECHR 'D'               ;                {single cap}I.{single cap}BELL"
 ECHR '.'               ;
 EJMP 19                ; Encoded as:   "{26}D.{19}BR<216><246> &{26}I.{19}<247>
 ECHR 'B'               ;                LL"
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

 ECHR ' '               ; Token 198:    " LITTLE {single cap}SQUEAKY"
 ECHR 'L'               ;
 ETWO 'I', 'T'          ; Encoded as:   " L<219>T<229>{26}S<254>EAKY"
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

 EJMP 25                ; Token 199:    "{incoming message screen, wait 2s}
 EJMP 9                 ;                {clear screen}
 EJMP 29                ;                {tab 6, lower case in words}
 EJMP 14                ;                {justify}
 EJMP 13                ;                {lower case}
 EJMP 19                ;                {single cap}GOOD DAY {single cap}
 ECHR 'G'               ;                COMMANDER {commander name}, ALLOW ME
 ECHR 'O'               ;                TO INTRODUCE MYSELF. {single cap}I AM
 ECHR 'O'               ;                 {single cap}THE {single cap}MERCHANT
 ECHR 'D'               ;                {single cap}PRINCE OF THRUN AND I
 ECHR ' '               ;                {single cap}FIND MYSELF FORCED TO SELL
 ECHR 'D'               ;                MY MOST TREASURED POSSESSION.{cr}
 ECHR 'A'               ;                {cr}
 ECHR 'Y'               ;                {single cap}{single cap}I AM OFFERING
 ECHR ' '               ;                YOU, FOR THE PALTRY SUM OF JUST 5000
 ETOK 154               ;                {single cap}C{single cap}R THE RAREST
 ECHR ' '               ;                THING IN THE {single cap}KNOWN {single
 EJMP 4                 ;                cap}UNIVERSE.{cr}
 ECHR ','               ;                {cr}
 ECHR ' '               ;                {single cap}{single cap}WILL YOU TAKE
 ETWO 'A', 'L'          ;                IT?{cr}
 ETWO 'L', 'O'          ;                {left align}{all caps}{tab 6}
 ECHR 'W'               ;
 ECHR ' '               ; Encoded as:   "{25}{9}{29}{14}{13}{19}GOOD DAY [154]
 ECHR 'M'               ;                 [4], <228><224>W ME[201]<240>TRODU
 ECHR 'E'               ;                <233> MY<218>LF.{26}I AM{26}<226>E{26}M
 ETOK 201               ;                <244>CH<255>T{26}PR<240><233> OF{26}
 ETWO 'I', 'N'          ;                <226>RUN <255>D{26}I{26}F<240>D MY<218>
 ECHR 'T'               ;                LF F<253><233>D[201]<218>LL MY MO<222>
 ECHR 'R'               ;                 T<242>ASU<242>D POS<218>SSI<223>[204]
 ECHR 'O'               ;                {19}I AM OFF<244>[195][179], F<253>
 ECHR 'D'               ;                 [147]P<228>TRY SUM OF JU<222> 4000{19}
 ECHR 'U'               ;                C{19}R [147]R<238>E<222> <226>[195]
 ETWO 'C', 'E'          ;                 <240> <226>E{26}K<227>WN{26}UNIV<244>
 ECHR ' '               ;                <218>[204]{19}W<220>L [179] TAKE <219>?
 ECHR 'M'               ;                {12}{15}{1}{8}"
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

 EJMP 26                ; Token 200:    " {single cap}NAME? "
 ECHR 'N'               ;
 ECHR 'A'               ; Encoded as:   "{26}NAME? "
 ECHR 'M'
 ECHR 'E'
 ECHR '?'
 ECHR ' '
 EQUB VE

 ECHR ' '               ; Token 201:    " TO "
 ECHR 'T'               ;
 ECHR 'O'               ; Encoded as:   " TO "
 ECHR ' '
 EQUB VE

 ECHR ' '               ; Token 202:    " IS "
 ECHR 'I'               ;
 ECHR 'S'               ; Encoded as:   " IS "
 ECHR ' '
 EQUB VE

 ECHR 'W'               ; Token 203:    "WAS LAST SEEN AT {single cap}"
 ECHR 'A'               ;
 ECHR 'S'               ; Encoded as:   "WAS <249><222> <218><246> <245> {19}"
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

 ECHR '.'               ; Token 204:    ".{cr}
 EJMP 12                ;                 {cr}
 EJMP 12                ;                 {single cap}"
 ECHR ' '               ;
 EJMP 19                ; Encoded as:   ".{12}{12} {19}"
 EQUB VE

 EJMP 19                ; Token 205:    "{single cap}DOCKED"
 ECHR 'D'               ;
 ECHR 'O'               ; Encoded as:   "{19}DOCK<252>"
 ECHR 'C'
 ECHR 'K'
 ETWO 'E', 'D'
 EQUB VE

 EQUB VE                ; Token 206:    ""
                        ;
                        ; Encoded as:   ""

 ECHR 'S'               ; Token 207:    "SHIP"
 ECHR 'H'               ;
 ECHR 'I'               ; Encoded as:   "SHIP"
 ECHR 'P'
 EQUB VE

 ECHR ' '               ; Token 208:    " A "
 ECHR 'A'               ;
 ECHR ' '               ; Encoded as:   " A "
 EQUB VE

 EJMP 26                ; Token 209:    " {single cap}ERRIUS"
 ETWO 'E', 'R'          ;
 ECHR 'R'               ; Encoded as:   "{26}<244>RI<236>"
 ECHR 'I'
 ETWO 'U', 'S'
 EQUB VE

 ECHR ' '               ; Token 210:    " NEW "
 ECHR 'N'               ;
 ECHR 'E'               ; Encoded as:   " NEW "
 ECHR 'W'
 ECHR ' '
 EQUB VE

 EJMP 26                ; Token 211:    " {single cap}HER {single cap}MAJESTY'S
 ECHR 'H'               ;                  {single cap}SPACE {single cap}NAVY"
 ETWO 'E', 'R'          ;
 EJMP 26                ; Encoded as:   "{26}H<244> <239>JE<222>Y'S{26}SPA<233>
 ETWO 'M', 'A'          ;                {26}NAVY"
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

 ETOK 177               ; Token 212:    ".{cr}
 EJMP 12                ;                {left align}{cr}
 EJMP 8                 ;                {tab 6}{all caps} {single cap}MESSAGE
 EJMP 1                 ;                {single cap}ENDS"
 ECHR ' '               ;
 EJMP 26                ; Encoded as:   "[177]{12}{8}{1} {26}M<237>SA<231>[26}
 ECHR 'M'               ;                <246>DS"
 ETWO 'E', 'S'
 ECHR 'S'
 ECHR 'A'
 ETWO 'G', 'E'
 EJMP 26
 ETWO 'E', 'N'
 ECHR 'D'
 ECHR 'S'
 EQUB VE

 ECHR ' '               ; Token 213:    " {single cap}COMMANDER {commander
 ETOK 154               ;                name}, {single cap}I {lower case}AM
 ECHR ' '               ;                {sentence case}{single cap}CAPTAIN
 EJMP 4                 ;                {mission captain's name} OF
 ECHR ','               ;                {sentence case} HER MAJESTY'S SPACE
 EJMP 26                ;                NAVY{lower case}"
 ECHR 'I'               ;
 ECHR ' '               ; Encoded as:   " [154] {4},{26}I {13}AM{26}CAPTA<240>
 EJMP 13                ;                  {27}OF[211]"
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
                        ;
                        ; Encoded as:   ""

 EJMP 15                ; Token 215:    "{left align} UNKNOWN PLANET"
 ECHR ' '               ;
 ECHR 'U'               ; Encoded as:   "{15} UNK<227>WN [145]"
 ECHR 'N'
 ECHR 'K'
 ETWO 'N', 'O'
 ECHR 'W'
 ECHR 'N'
 ECHR ' '
 ETOK 145
 EQUB VE

 EJMP 9                 ; Token 216:    "{clear screen}
 EJMP 8                 ;                {tab 6}
 EJMP 23                ;                {move to row 10, white, lower case}
 EJMP 1                 ;                {all caps}
 ECHR ' '               ;                (space)
 ETWO 'I', 'N'          ;                INCOMING MESSAGE"
 ECHR 'C'               ;
 ECHR 'O'               ; Encoded as:   "{9}{8}{23}{1} <240>COM[195]M<237>SA
 ECHR 'M'               ;                <231>"
 ETOK 195
 ECHR 'M'
 ETWO 'E', 'S'
 ECHR 'S'
 ECHR 'A'
 ETWO 'G', 'E'
 EQUB VE

 EJMP 19                ; Token 217:    "{single cap}CURRUTHERS"
 ECHR 'C'               ;
 ECHR 'U'               ; Encoded as:   "{19}CURRU<226><244>S"
 ECHR 'R'
 ECHR 'R'
 ECHR 'U'
 ETWO 'T', 'H'
 ETWO 'E', 'R'
 ECHR 'S'
 EQUB VE

 EJMP 19                ; Token 218:    "{single cap}FOSDYKE {single cap}SMYTHE"
 ECHR 'F'               ;
 ECHR 'O'               ; Encoded as:   "{19}FOSDYKE{26}SMY<226>E"
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

 EJMP 19                ; Token 219:    "{single cap}FORTESQUE"
 ECHR 'F'               ;
 ETWO 'O', 'R'          ; Encoded as:   "{19}F<253>T<237><254>E"
 ECHR 'T'
 ETWO 'E', 'S'
 ETWO 'Q', 'U'
 ECHR 'E'
 EQUB VE

 ETOK 203               ; Token 220:    "WAS LAST SEEN AT {single cap}{single
 EJMP 19                ;                cap}REESDICE"
 ETWO 'R', 'E'          ;
 ETWO 'E', 'S'          ; Encoded as:   "[203]{19{<242><237><241><233>"
 ETWO 'D', 'I'
 ETWO 'C', 'E'
 EQUB VE

 ECHR 'I'               ; Token 221:    "IS BELIEVED TO HAVE JUMPED TO THIS
 ECHR 'S'               ;                GALAXY"
 ECHR ' '               ;
 ETWO 'B', 'E'          ; Encoded as:   "IS <247>LIE<250>D[201]HA<250> JUMP[196]
 ECHR 'L'               ;                TO [148]G<228>AXY"
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

 EJMP 25                ; Token 222:    "{incoming message screen, wait 2s}
 EJMP 9                 ;                {clear screen}
 EJMP 29                ;                {tab 6, lower case in words}
 EJMP 14                ;                {justify}
 EJMP 13                ;                {lower case}
 EJMP 19                ;                {single cap}
 ECHR 'G'               ;                GOOD DAY {single cap}COMMANDER
 ECHR 'O'               ;                {commander name}.{cr}
                        ;                {cr}
 ECHR 'O'               ;                 {single cap}I{lower case} AM {single
 ECHR 'D'               ;                cap}AGENT{single cap}BLAKE OF {single
 ECHR ' '               ;                cap}NAVAL {single cap}INTELLEGENCE.{cr}
                        ;                {cr}
 ECHR 'D'               ;                 {single cap}AS YOU KNOW, THE {single
 ECHR 'A'               ;                cap}NAVY HAVE BEEN KEEPING THE {single
 ECHR 'Y'               ;                cap}THARGOIDS OFF YOUR BACK OUT IN DEEP
 ECHR ' '               ;                SPACE FOR MANY YEARS NOW. {single cap}
 ETOK 154               ;                WELL THE SITUATION HAS CHANGED.{cr}
                        ;                {cr}
 ECHR ' '               ;                 {single cap}OUR BOYS ARE READY FOR A
 EJMP 4                 ;                PUSH RIGHT TO THE HOME SYSTEM OF THOSE
 ETOK 204               ;                MURDERERS.{cr}
                        ;                {cr}
 EJMP 19                ;                 {single cap}{wait for key press}{clear
 ECHR 'I'               ;                screen}{tab 6, lower case in words}
 ECHR ' '               ;                I{lower case} HAVE OBTAINED THE DEFENCE
 ECHR 'A'               ;                PLANS FOR THEIR {single cap}HIVE{single
 ECHR 'M'               ;                cap}WORLDS.{cr}
                        ;                {cr}
                        ;                {wait for key press}
 EJMP 26                ;                {clear screen}
                        ;                {move to row 7, lower case}{single cap}
 ECHR 'A'               ;                {single cap}THE BEETLES KNOW WE'VE GOT
 ETWO 'G', 'E'          ;                SOMETHING BUT NOT WHAT.{cr}
                        ;                {cr}
 ECHR 'N'               ;                {single cap}IF {single cap}I TRANSMIT
 ECHR 'T'               ;                THE PLANS TO OUR BASE ON {single cap}
 EJMP 26                ;                BIRERA THEY'LL INTERCEPT THE
 ECHR 'B'               ;                TRANSMISSION. {single cap}I NEED A SHIP
 ETWO 'L', 'A'          ;                 TO MAKE THE RUN.{cr}
                        ;                {cr}
 ECHR 'K'               ;                 {single cap}YOU'RE ELECTED.{cr}
                        ;                {cr}
                        ;                 {single cap}THE PLANS ARE UNIPULSE
 ECHR 'E'               ;                CODED WITHIN THIS TRANSMISSION.{cr}
                        ;                {cr}
 ECHR ' '               ;                {single cap}{tab 6}
 ECHR 'O'               ;                YOU WILL BE PAID.{cr}
                        ;                {cr}
 ECHR 'F'               ;                 {single cap}    {single cap}GOOD LUCK
 EJMP 26                ;                {single cap}COMMANDER.{cr}
                        ;                {left align}{cr}
 ECHR 'N'               ;                {tab 6}{all caps}  MESSAGE ENDS
 ECHR 'A'               ;                {wait for key press}"
 ECHR 'V'               ;
 ETWO 'A', 'L'          ; Encoded as:   "{25}{9}{29}{14}{13}{19}GOOD DAY [154]
 EJMP 26                ;                 {4}[204]{19}I AM{26}A<231>NT{26}B<249>
 ETWO 'I', 'N'          ;                KE OF{26}NAV<228>{26}<240>TELLI<231>N
 ECHR 'T'               ;                <233>[204]{19}AS [179] K<227>W, <226>E
 ECHR 'E'               ;                {26}NAVY HA<250> <247><246> KEEP[195]
 ECHR 'L'               ;                <226>E{26}<226><238>GOIDS OFF [179]R BA
 ECHR 'L'               ;                CK <217>T <240>{26}DEEP{26}SPA<233> F
 ECHR 'I'               ;                <253> <239>NY YE<238>S <227>W.{26}WELL
 ETWO 'G', 'E'          ;                 [147]S<219>U<245>I<223> HAS CH<255>
 ECHR 'N'               ;                <231>D[204]{19}<217>R BOYS <238>E <242>
 ETWO 'C', 'E'          ;                ADY F<253>[208]P<236>H RIGHT[201]<226>E
 ETOK 204               ;                {26}HOME{26}SY<222>EM OF <226>O<218> MU
 EJMP 19                ;                RDE<242>RS[204]{19}I{13} HA<250> OBTA
 ECHR 'A'               ;                <240>[196][147]DEF<246><233> P<249>NS F
 ECHR 'S'               ;                <253> <226>EIR{26}HI<250>{26}[146]S
 ECHR ' '               ;                [204]{24}{9}{29}{19}[147]<247><221>
 ETOK 179               ;                <229>S K<227>W WE'<250> GOT <235>M<221>
 ECHR ' '               ;                H[195]BUT <227>T WH<245>[204]{19}IF{26}
 ECHR 'K'               ;                I T<248>NSM<219> <226>E{26}P<249>NS
 ETWO 'N', 'O'          ;                [201]<217>R BA<218> <223>{26}<234><242>
 ECHR 'W'               ;                <248> <226>EY'LL <240>T<244><233>PT
 ECHR ','               ;                 [147]T<248>NSMISSI<223>.{26}I NE[196]
 ECHR ' '               ;                A [207][201]<239>KE [147]RUN[204][179]'
 ETWO 'T', 'H'          ;                <242> E<229>CT<252>[204][147]P<249>NS
 ECHR 'E'               ;                <238>E{26}UNIPUL<218> COD[196]W<219>H
 EJMP 26                ;                <240> [148]T<248>NSMISSI<223>.{26}[179]
 ECHR 'N'               ;                 W<220>L <247> PAID[204]   {26}GOOD LUC
 ECHR 'A'               ;                K [154][212]{24}"
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

 EJMP 25                ; Token 223:    "{incoming message screen, wait 2s}
 EJMP 9                 ;                {clear screen}
 EJMP 29                ;                {tab 6, white, lower case in words}
 EJMP 8                 ;                {tab 6}
 EJMP 14                ;                {justify}
 EJMP 13                ;                {lower case}
 EJMP 19                ;                {single cap}WELL DONE {single cap}
 ECHR 'W'               ;                COMMANDER.{cr}
 ECHR 'E'               ;                {cr}
 ECHR 'L'               ;                 {single cap}YOU HAVE SERVED US WELL
 ECHR 'L'               ;                AND WE SHALL REMEMBER.{cr}
 ECHR ' '               ;                {cr}
 ECHR 'D'               ;                 {single cap}WE DID NOT EXPECT THE
 ETWO 'O', 'N'          ;                {single cap}THARGOIDS TO FIND OUT
 ECHR 'E'               ;                ABOUT YOU.{cr}
 ECHR ' '               ;                {cr}
 ETOK 154               ;                 {single cap}FOR THE MOMENT PLEASE
 ETOK 204               ;                ACCEPT THIS {single cap}NAVY {standard
 ETOK 179               ;                tokens, sentence case}EXTRA ENERGY
 ECHR ' '               ;                UNIT{extended tokens} AS PAYMENT.{cr}
 ECHR 'H'               ;                {cr}
 ECHR 'A'               ;                {left align}
 ETWO 'V', 'E'          ;                {tab 6}{all caps}  MESSAGE ENDS
 ECHR ' '               ;                {wait for key press}"
 ETWO 'S', 'E'          ;
 ECHR 'R'               ; Encoded as:   "{25}{9}{29}{8}{14}{13}{19}WELL D
 ETWO 'V', 'E'          ;                <223>E [154][204][179] HA<250> <218>R
 ECHR 'D'               ;                <250>D <236> WELL[178]WE SH<228>L <242>
 ECHR ' '               ;                MEMB<244>[204]WE <241>D <227>T EXPECT
 ETWO 'U', 'S'          ;                <226>E{26}<226><238>GOIDS[201]F<240>D
 ECHR ' '               ;                 <217>T <216><217>T [179][204]{19}F
 ECHR 'W'               ;                <253> [147]MOM<246>T P<229>A<218> AC
 ECHR 'E'               ;                <233>PT <226>{26}NAVY {6}[114]{5} A
 ECHR 'L'               ;                S PAYM<246>T[212]{24}"
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
 TOKN 114
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
                        ;
                        ; Encoded as:   ""

 ECHR 'S'               ; Token 225:    "SHREW"
 ECHR 'H'               ;
 ETWO 'R', 'E'          ; Encoded as:   "SH<242>W"
 ECHR 'W'
 EQUB VE

 ETWO 'B', 'E'          ; Token 226:    "BEAST"
 ECHR 'A'               ;
 ETWO 'S', 'T'          ; Encoded as:   "<247>A<222>"
 EQUB VE

 ECHR 'G'               ; Token 227:    "GNU"
 ETWO 'N', 'U'          ;
 EQUB VE                ; Encoded as:   "G<225>"

 ECHR 'S'               ; Token 228:    "SNAKE"
 ECHR 'N'               ;
 ECHR 'A'               ; Encoded as:   "SNAKE"
 ECHR 'K'
 ECHR 'E'
 EQUB VE

 ECHR 'D'               ; Token 229:    "DOG"
 ECHR 'O'               ;
 ECHR 'G'               ; Encoded as:   "DOG"
 EQUB VE

 ETWO 'L', 'E'          ; Token 230:    "LEOPARD"
 ECHR 'O'               ;
 ECHR 'P'               ; Encoded as:   "<229>OP<238>D"
 ETWO 'A', 'R'
 ECHR 'D'
 EQUB VE

 ECHR 'C'               ; Token 231:    "CAT"
 ETWO 'A', 'T'          ;
 EQUB VE                ; Encoded as:   "C<245>"

 ECHR 'M'               ; Token 232:    "MONKEY"
 ETWO 'O', 'N'          ;
 ECHR 'K'               ; Encoded as:   "M<223>KEY"
 ECHR 'E'
 ECHR 'Y'
 EQUB VE

 ECHR 'G'               ; Token 233:    "GOAT"
 ECHR 'O'               ;
 ETWO 'A', 'T'          ; Encoded as:   "GO<245>"
 EQUB VE

 ECHR 'C'               ; Token 234:    "CARP"
 ETWO 'A', 'R'          ;
 ECHR 'P'               ; Encoded as:   "C<238>P"
 EQUB VE

 ERND 15                ; Token 235:    "[71-75] [66-70]"
 ECHR ' '               ;
 ERND 14                ; Encoded as:   "[15?] [14?]"
 EQUB VE

 EJMP 17                ; Token 236:    "{system name adjective} [225-229]
 ECHR ' '               ;                 [240-244]"
 ERND 29                ;
 ECHR ' '               ; Encoded as:   "{17} [29?] [32?]"
 ERND 32
 EQUB VE

 ETOK 175               ; Token 237:    "ITS [76-80] [230-234] [240-244]"
 ERND 16                ;
 ECHR ' '               ; Encoded as:   "[175][16?] [30?] [32?]"
 ERND 30
 ECHR ' '
 ERND 32
 EQUB VE

 ERND 33                ; Token 238:    "[245-249] [250-254]"
 ECHR ' '               ;
 ERND 34                ; Encoded as:   "[33?] [34?]"
 EQUB VE

 ERND 15                ; Token 239:    "[71-75] [66-70]"
 ECHR ' '               ;
 ERND 14                ; Encoded as:   "[15?] [14?]"
 EQUB VE

 ECHR 'M'               ; Token 240:    "MEAT"
 ECHR 'E'               ;
 ETWO 'A', 'T'          ; Encoded as:   "ME<245>"
 EQUB VE

 ECHR 'C'               ; Token 241:    "CUTLET"
 ECHR 'U'               ;
 ECHR 'T'               ; Encoded as:   "CUTL<221>"
 ECHR 'L'
 ETWO 'E', 'T'
 EQUB VE

 ETWO 'S', 'T'          ; Token 242:    "STEAK"
 ECHR 'E'               ;
 ECHR 'A'               ; Encoded as:   "<222>EAK"
 ECHR 'K'
 EQUB VE

 ECHR 'B'               ; Token 243:    "BURGERS"
 ECHR 'U'               ;
 ECHR 'R'               ; Encoded as:   "BUR<231>RS"
 ETWO 'G', 'E'
 ECHR 'R'
 ECHR 'S'
 EQUB VE

 ECHR 'S'               ; Token 244:    "SOUP"
 ETWO 'O', 'U'
 ECHR 'P'               ; Encoded as:   "S<217>P"
 EQUB VE

 ECHR 'I'               ; Token 245:    "ICE"
 ETWO 'C', 'E'          ;
 EQUB VE                ; Encoded as:   "I<233>"

 ECHR 'M'               ; Token 246:    "MUD"
 ECHR 'U'               ;
 ECHR 'D'               ; Encoded as:   "MUD"
 EQUB VE

 ECHR 'Z'               ; Token 247:    "ZERO-{single cap}G"
 ETWO 'E', 'R'          ;
 ECHR 'O'               ; Encoded as:   "Z<244>O-{19}G"
 ECHR '-'
 EJMP 19
 ECHR 'G'
 EQUB VE

 ECHR 'V'               ; Token 248:    "VACUUM"
 ECHR 'A'               ;
 ECHR 'C'               ; Encoded as:   "VACUUM"
 ECHR 'U'
 ECHR 'U'
 ECHR 'M'
 EQUB VE

 EJMP 17                ; Token 249:    "{system name adjective} ULTRA"
 ECHR ' '               ;
 ECHR 'U'               ; Encoded as:   "{17} ULT<248>"
 ECHR 'L'
 ECHR 'T'
 ETWO 'R', 'A'
 EQUB VE

 ECHR 'H'               ; Token 250:    "HOCKEY"
 ECHR 'O'               ;
 ECHR 'C'               ; Encoded as:   "HOCKEY"
 ECHR 'K'
 ECHR 'E'
 ECHR 'Y'
 EQUB VE

 ECHR 'C'               ; Token 251:    "CRICKET"
 ECHR 'R'               ;
 ECHR 'I'               ; Encoded as:   "CRICK<221>"
 ECHR 'C'
 ECHR 'K'
 ETWO 'E', 'T'
 EQUB VE

 ECHR 'K'               ; Token 252:    "KARATE"
 ETWO 'A', 'R'          ;
 ETWO 'A', 'T'          ; Encoded as:   "K<238><245>E"
 ECHR 'E'
 EQUB VE

 ECHR 'P'               ; Token 253:    "POLO"
 ECHR 'O'               ;
 ETWO 'L', 'O'          ; Encoded as:   "PO<224>"
 EQUB VE

 ECHR 'T'               ; Token 254:    "TENNIS"
 ETWO 'E', 'N'          ;
 ECHR 'N'               ; Encoded as:   "T<246>NIS"
 ECHR 'I'
 ECHR 'S'
 EQUB VE

 EQUB VE                ; Token 255:    ""
                        ;
                        ; Encoded as:   ""

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
                        ;
                        ; Encoded as:   ""

 EJMP 19                ; Token 1:      "{single cap}THE COLONISTS HERE HAVE
 ETWO 'T', 'H'          ;                VIOLATED {single cap}INTERGALACTIC
 ECHR 'E'               ;                {single cap}CLONING {single cap}
 ECHR ' '               ;                PROTOCOL AND SHOULD BE AVOIDED"
 ECHR 'C'               ;
 ECHR 'O'               ; Encoded as:   "{19}<226>E COL<223>I<222>S HE<242> HA
 ECHR 'L'               ;                <250> VIOL<245><252>{2}<240>T<244>G
 ETWO 'O', 'N'          ;                <228>AC<251>C{26}CL<223><240>G{26}PROTO
 ECHR 'I'               ;                COL <255>D SH<217>LD <247> AVOID<252>"
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

 EJMP 19                ; Token 2:      "{single cap}THE {single cap}CONSTRICTOR
 ETWO 'T', 'H'          ;                WAS LAST SEEN AT {single cap}REESDICE,
 ECHR 'E'               ;                 {single cap}COMMANDER"
 EJMP 26                ;
 ECHR 'C'               ; Encoded as:   "{19}<226>E{26}C<223><222>RICT<253>
 ETWO 'O', 'N'          ;                 [203]{19}<242><237><241><233>, [154]"
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

 EJMP 19                ; Token 3:      "{single cap}A [130-134] LOOKING SHIP
 ECHR 'A'               ;                LEFT HERE A WHILE BACK. {single cap}
 ECHR ' '               ;                LOOKED BOUND FOR {single cap}AREXE"
 ERND 23                ;
 ECHR ' '               ; Encoded as:   "{19}A [23?] <224>OK<240>G SHIP <229>FT
 ETWO 'L', 'O'          ;                 HE<242> A WH<220>E BACK.{26}<224>OK
 ECHR 'O'               ;                <252> B<217>ND F<253>{26}<238>E<230>"
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

 EJMP 19                ; Token 4:      "{single cap}YES, A [130-134] NEW SHIP
 ECHR 'Y'               ;                HAD A {single cap}GALACTIC {single cap}
 ETWO 'E', 'S'          ;                HYPERDRIVE FITTED HERE. {single cap}
 ECHR ','               ;                USED IT TOO"
 ECHR ' '               ;
 ECHR 'A'               ; Encoded as:   "{19}Y<237>, A [23?] NEW SHIP HAD A{26}G
 ECHR ' '               ;                <228>AC<251>C{26}HYP<244>DRI<250> F
 ERND 23                ;                <219>T<252> HE<242>.{26}U<218>D <219>
 ECHR ' '               ;                 TOO"
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

 EJMP 19                ; Token 5:      "{single cap}THIS  [130-134] SHIP
 ETWO 'T', 'H'          ;                DEHYPED HERE FROM NOWHERE, {single cap}
 ECHR 'I'               ;                SUN-{single cap}SKIMMED AND JUMPED.
 ECHR 'S'               ;                {single cap}I HEAR IT WENT TO {single
 ECHR ' '               ;                cap}INBIBE"
 ECHR ' '               ;
 ERND 23                ; Encoded as:   "{19}<226>IS  [23?] SHIP DEHYP<252> HE
 ECHR ' '               ;                <242> FROM <227>WHE<242>,{26}SUN-{19}SK
 ECHR 'S'               ;                IMM<252> <255>D JUMP<252>.{26}I HE<238>
 ECHR 'H'               ;                 <219> W<246>T TO{26}<240><234><247>"
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

 ERND 24                ; Token 6:      "[91-95] SHIP WENT FOR ME AT {single
 ECHR ' '               ;                cap}AUSAR. MY LASERS DIDN'T EVEN
 ECHR 'S'               ;                SCRATCH THE [91-95]"
 ECHR 'H'               ;
 ECHR 'I'               ; Encoded as:   "[24?] SHIP W<246>T F<253> ME <245>{26}
 ECHR 'P'               ;                A<236><238>.{26}MY <249><218>RS <241>DN
 ECHR ' '               ;                'T EV<246> SCR<245>CH <226>E [24?]"
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

 EJMP 19                ; Token 7:      "{single cap}OH DEAR ME YES. A FRIGHTFUL
 ECHR 'O'               ;                ROGUE SHOT UP LOTS OF THOSE BEASTLY
 ECHR 'H'               ;                PIRATES AND WENT TO {single cap}USLERI"
 ECHR ' '               ;
 ECHR 'D'               ; Encoded as:   "{19}OH DE<238> ME Y<237>. A FRIGHTFUL R
 ECHR 'E'               ;                OGUE SHOT UP <224>TS OF <226>O<218>
 ETWO 'A', 'R'          ;                 <247>A<222>LY PIR<245><237> <255>D W
 ECHR ' '               ;                <246>T TO{26}<236><229>RI"
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

 EJMP 19                ; Token 8:      "{single cap}YOU CAN TACKLE THE
 ECHR 'Y'               ;                [170-174] [91-95] IF YOU LIKE. {single
 ETWO 'O', 'U'          ;                cap}HE'S AT {single cap}ORARRA"
 ECHR ' '               ;
 ECHR 'C'               ; Encoded as:   "{19}Y<217> C<255> TACK<229> <226>E
 ETWO 'A', 'N'          ;                 [13?] [24?] IF Y<217> LIKE.{26}HE'S
 ECHR ' '               ;                 <245>{26}<253><238><248>"
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

 ERND 25                ; Token 9:      "[106-110]"
 EQUB VE                ;
                        ; Encoded as:   "[25?]"

 ERND 25                ; Token 10:     "[106-110]"
 EQUB VE                ;
                        ; Encoded as:   "[25?]"

 ERND 25                ; Token 11:     "[106-110]"
 EQUB VE                ;
                        ; Encoded as:   "[25?]"

 ERND 25                ; Token 12:     "[106-110]"
 EQUB VE                ;
                        ; Encoded as:   "[25?]"

 ERND 25                ; Token 13:     "[106-110]"
 EQUB VE                ;
                        ; Encoded as:   "[25?]"

 ERND 25                ; Token 14:     "[106-110]"
 EQUB VE                ;
                        ; Encoded as:   "[25?]"

 ERND 25                ; Token 15:     "[106-110]"
 EQUB VE                ;
                        ; Encoded as:   "[25?]"

 ERND 25                ; Token 16:     "[106-110]"
 EQUB VE                ;
                        ; Encoded as:   "[25?]"

 ERND 25                ; Token 17:     "[106-110]"
 EQUB VE                ;
                        ; Encoded as:   "[25?]"

 ERND 25                ; Token 18:     "[106-110]"
 EQUB VE                ;
                        ; Encoded as:   "[25?]"

 ERND 25                ; Token 19:     "[106-110]"
 EQUB VE                ;
                        ; Encoded as:   "[25?]"

 ERND 25                ; Token 20:     "[106-110]"
 EQUB VE                ;
                        ; Encoded as:   "[25?]"

 ERND 25                ; Token 21:     "[106-110]"
 EQUB VE                ;
                        ; Encoded as:   "[25?]"

 EJMP 19                ; Token 22:     "{single cap}BOY ARE YOU IN THE WRONG
 ECHR 'B'               ;                 GALAXY!"
 ECHR 'O'               ;
 ECHR 'Y'               ; Encoded as:   "{19}BOY <238>E Y<217> <240> <226>E WR
 ECHR ' '               ;                <223>G{26}G"
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

 EJMP 19                ; Token 23:     "{single cap}THERE'S A REAL [91-95]
 ETWO 'T', 'H'          ;                 PIRATE OUT THERE"
 ECHR 'E'               ;
 ETWO 'R', 'E'          ; Encoded as:   "{19}<226>E<242>'S A <242><228> [24?] PI
 ECHR '`'               ;                R<245>E <217>T <226>E<242>"
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
                        ;
                        ; Encoded as:   ""

 EJMP 19                ; Token 1:      "{single cap}JA"
 ECHR 'J'               ;
 ECHR 'A'               ; Encoded as:   "{single cap}NEIN"
 EQUB VE

 EJMP 19                ; Token 2:      "{single cap}NEIN"
 ECHR 'N'               ;
 ETOK 183               ; Encoded as:   "{19}N[183]"
 EQUB VE

 EQUB VE                ; Token 3:      ""
                        ;
                        ; Encoded as:   ""

 EJMP 19                ; Token 4:      "{single cap}DEUTSCH"
 ECHR 'D'               ;
 ECHR 'E'               ; Encoded as:   "{19}DEUT[187]"
 ECHR 'U'
 ECHR 'T'
 ETOK 187
 EQUB VE

 EQUB VE                ; Token 5:      ""
                        ;
                        ; Encoded as:   ""

 EQUB VE                ; Token 6:      ""
                        ;
                        ; Encoded as:   ""

 EQUB VE                ; Token 7:      ""
                        ;
                        ; Encoded as:   ""

 EJMP 19                ; Token 8:      "{single cap}NEUER {single cap}NOME: "
 ECHR 'N'               ;
 ECHR 'E'               ; Encoded as:   "{19}NEU<244>{26}<227>ME: "
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
                        ;
                        ; Encoded as:   ""

 EJMP 23                ; Token 10:     "{move to row 9, lower case}
 EJMP 14                ;                {justify}
 EJMP 13                ;                {lower case} {single cap}SEID GEGRT
 EJMP 26                ;                {single cap} KOMMANDANT {commander
 ETWO 'S', 'E'          ;                name}. {single cap}ICH {lower case}BIN
 ECHR 'I'               ;                {single cap}KAPITN DER {single cap}
 ECHR 'D'               ;                RAUMFAHRTMARINE UNSERER {single cap}
 ECHR ' '               ;                MAJESTT. {single cap}ICH BITTE {single
 ETWO 'G', 'E'          ;                cap}SIE UM EINEN {single cap}MOMENT
 ECHR 'G'               ;                {single cap}IHRER WERTVOLLEN {single
 ECHR 'R'               ;                cap}ZEIT.{cr}
 ERND 2                 ;                {cr}
 ERND 3                 ;                 {single cap}WIR WRDEN UNS FREUEN, WENN
 ECHR 'T'               ;                {single cap}SIE EINEN KLEINEN {single
 ETOK 213               ;                cap}AUFTRAG FR UNS ERFLLEN.{cr}
 ECHR '.'               ;                {cr}
 EJMP 26                ;                 {single cap}{display ship, wait for
 ETOK 186               ;                key press}{single cap}BEI DEM {single
 ECHR ' '               ;                cap}SCHIFF, DAS {single cap}SIE HIER
 ECHR 'B'               ;                SEHEN, HANDELT ES SICH UM EIN NEUES
 ETWO 'I', 'T'          ;                {single cap}MODELL, {single cap}
 ECHR 'T'               ;                CONSTRICTOR, DAS MIT EINEM  GEHEIMEN
 ECHR 'E'               ;                NEUEN {single cap}SCHILDGENERATOR
 ETOK 179               ;                AUSGERSTET IST.{cr}
 ECHR ' '               ;                {cr}
 ECHR 'U'               ;                 {single cap}{single cap}LEIDER WURDE
 ECHR 'M'               ;                ES GESTOHLEN.{cr}
 ECHR ' '               ;                {cr}
 ETOK 183               ;                 {single cap}{single cap}ES VERSCHWAND
 ETWO 'E', 'N'          ;                VOR FNF {single cap}MONATEN VON UNSERER
 EJMP 26                ;                {single cap}WERFT AUF {single cap}XEER.
 ECHR 'M'               ;                {single cap}ES {mission 1 location
 ECHR 'O'               ;                hint}.{cr}
 ECHR 'M'               ;                {cr}
 ETWO 'E', 'N'          ;                 {single cap}{display ship, wait for
 ECHR 'T'               ;                key press}{single cap}SOLLTEN {single
 EJMP 26                ;                cap}SIE SICH DAZU ENTSCHLIEEN, IHN
 ECHR 'I'               ;                ANZUNEHMEN, SO LAUTET {single cap}IHR
 ECHR 'H'               ;                {single cap}AUFTRAG, DAS {single cap}
 ETWO 'R', 'E'          ;                SCHIFF ZU FINDEN UND ES ZU VERNICHTEN.
 ECHR 'R'               ;                {cr}
 ECHR ' '               ;                {cr}
 ECHR 'W'               ;                 {single cap}NUR VON MILITRISCHEN
 ETWO 'E', 'R'          ;                {single cap}LASERN KNNEN DIE NEUEN
 ECHR 'T'               ;                {single cap}SCHILDE DURCHDRUNGEN
 ECHR 'V'               ;                WERDEN.{cr}
 ECHR 'O'               ;                {cr}
 ECHR 'L'               ;                 {single cap}{single cap}CONSTRICTOR
 ETWO 'L', 'E'          ;                IST MIT AUSGESTATTET.{cr}
 ECHR 'N'               ;                 {left align}{tab 6}{single cap}VIEL
 EJMP 26                ;                {single cap}GLCK, {single cap}
 ECHR 'Z'               ;                KOMMANDANT.{cr}
 ECHR 'E'               ;                {left align}{cr}
 ETWO 'I', 'T'          ;                {tab 6}{all caps} {single cap}ENDE DER
 ETOK 204               ;                {single cap}NACHRICHT{display ship,
 ECHR 'W'               ;                wait for key press}
 ECHR 'I'               ;
 ECHR 'R'               ; Encoded as:   "{23}{14}{13}{26}<218>ID <231>GR[2?][3?]
 ECHR ' '               ;                T[213].{26}[186] B<219>TE[179] UM [183]
 ECHR 'W'               ;                <246>{26}MOM<246>T{26}IH<242>R W<244>TV
 ERND 2                 ;                OL<229>N{26}ZE<219>[204]WIR W[2?]RD
 ECHR 'R'               ;                <246> UNS F<242>U<246>, W<246>N[179]
 ECHR 'D'               ;                [183]<246> K<229><240><246>{26}AUFT
 ETWO 'E', 'N'          ;                <248>G F[2?]R UNS <244>F[2?]L<229>N
 ECHR ' '               ;                [204]{22}{19}<247>I DEM[182], DAS[179]
 ECHR 'U'               ;                 HI<244> <218>H<246>, H<255>DELT[161]S
 ECHR 'N'               ;                [186] UM[185]NEU<237>{26}MODELL,{26}C
 ECHR 'S'               ;                <223><222>RICT<253>, [156]M<219> [183]
 ECHR ' '               ;                EM  <231>HEIM<246> NEU<246>{26}[187]
 ECHR 'F'               ;                <220>D<231>N<244><245><253> A<236><231>
 ETWO 'R', 'E'          ;                R[2?]<222><221> I<222>[204]{19}<229>I
 ECHR 'U'               ;                [155]WURDE[161]<231><222>OH<229>N[204]
 ETWO 'E', 'N'          ;                {19}<237> V<244>[187]W<255>D [157] F
 ECHR ','               ;                [2?]NF{26}M<223><245><246> V<223> UN
 ECHR ' '               ;                <218><242>R{26}W<244>FT AUF{26}<230>
 ECHR 'W'               ;                <244>.{26}<237> {28}[204]{22}{19}<235>L
 ETWO 'E', 'N'          ;                LT<246>[179] S[186] DA[159] <246>T[187]
 ECHR 'N'               ;                LIE[3?]<246>, IHN <255>[159]NEHM<246>,
 ETOK 179               ;                 <235> <249>UT<221>{26}IHR{26}AUFT<248>
 ECHR ' '               ;                G, DAS[182][160]F<240>D<246>[178]<237>
 ETOK 183               ;                [160]V<244>[162]<246>[204]<225>R V<223>
 ETWO 'E', 'N'          ;                 M<220><219>[0?]RI[187]<246>{26}<249>
 ECHR ' '               ;                <218>RN K[1?]NN<246> [147]NEU<246>{26}
 ECHR 'K'               ;                [187]<220>DE DURCHDRUN<231>N W<244>D
 ETWO 'L', 'E'          ;                <246>[204]{19}C<223><222>RICT<253>[181]
 ETWO 'I', 'N'          ;                M<219> {6}[17?]{5} A<236><231><222>
 ETWO 'E', 'N'          ;                <245>T<221>[177]{8}{19}VIEL{26}GL[2?]CK
 EJMP 26                ;                , [154][212]{22}"
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

 EJMP 25                ; Token 11:     "{incoming message screen, wait 2s}
 EJMP 9                 ;                {clear screen}
 EJMP 29                ;                {move to row 7, lower case}
 EJMP 14                ;                {justify}
 EJMP 26                ;                 {single cap}ACHTUNG {single cap}
 ETOK 164               ;                KOMMANDANT {commander name}. {single
 ECHR 'T'               ;                cap}ICH {lower case}BIN {single cap}
 ECHR 'U'               ;                KAPITN DER {single cap}RAUMFAHRTMARINE
 ECHR 'N'               ;                UNSERER {single cap}MAJESTT. {single
 ECHR 'G'               ;                cap}IHRE {single cap}DIENSTE WERDEN
 ETOK 213               ;                WIEDER BENTIGT.{cr}
 ECHR '.'               ;                {cr}
 EJMP 26                ;                 {single cap}WENN {single cap}SIE SO
 ECHR 'I'               ;                GUT WREN, NACH {single cap}CEERDI ZU
 ECHR 'H'               ;                FAHREN, WERDEN {single cap}SIE DORT
 ETWO 'R', 'E'          ;                GENAUE {single cap}ANWEISUNGEN
 EJMP 26                ;                ERHALTEN.{cr}
 ETWO 'D', 'I'          ;                {cr}
 ETWO 'E', 'N'          ;                 {single cap}{single cap}WENN {single
 ETWO 'S', 'T'          ;                cap}SIE ERFOLGREICH SIND, SO WERDEN
 ECHR 'E'               ;                {single cap}SIE REICHLICH BELOHNT.{cr}
 ECHR ' '               ;                {left align}{cr}
 ECHR 'W'               ;                {tab 6}{all caps} {single cap}ENDE DER
 ETWO 'E', 'R'          ;                 {single cap}NACHRICHT
 ECHR 'D'               ;                {wait for key press}"
 ETWO 'E', 'N'          ;
 ECHR ' '               ; Encoded as:   "{25}{9}{29}{14}{26}[164]TUNG[213].{26}I
 ECHR 'W'               ;                H<242>{26}<241><246><222>E W<244>D<246>
 ECHR 'I'               ;                 WI<252><244> B<246>[1?]<251>GT[204]W
 ETWO 'E', 'D'          ;                <246>N[179] <235> GUT W[0?]<242>N, N
 ETWO 'E', 'R'          ;                [164]{26}<233><244><241>[160]FAH<242>N,
 ECHR ' '               ;                 W<244>D<246>[179] D<253>T <231>NAUE
 ECHR 'B'               ;                {26}<255>WEISUN<231>N <244>H<228>T<246>
 ETWO 'E', 'N'          ;                [204]{19}W<246>N[179] <244>FOLG<242>
 ERND 1                 ;                [186] S<240>D, <235> W<244>D<246>[179]
 ETWO 'T', 'I'          ;                 <242>[186]L[186] <247><224>HNT[212]
 ECHR 'G'               ;                {24}"
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
                        ;
                        ; Encoded as:   ""

 EQUB VE                ; Token 13:     ""
                        ;
                        ; Encoded as:   ""

 EJMP 21                ; Token 14:     "{clear bottom of screen}{single cap}
 ETOK 145               ;                PLANET {single cap}NAME? "
 ETOK 200               ;
 EQUB VE                ; Encoded as:   "{21}[145][200]"

 EJMP 25                ; Token 15:     "{incoming message screen, wait 2s}
 EJMP 9                 ;                {clear screen}
 EJMP 29                ;                {move to row 7, lower case}
 EJMP 14                ;                {justify}
 EJMP 13                ;                {lower case} {single cap}BRAVO {single
 EJMP 26                ;                cap}KOMMANDANT!{cr}{cr} {single cap}FR
 ECHR 'B'               ;                {single cap}SIE GIBT ES STETS EINEN
 ETWO 'R', 'A'          ;                {single cap}PLATZ IN DER  {single cap}
 ECHR 'V'               ;                RAUMFAHRTMARINE UNSERER {single cap}
 ECHR 'O'               ;                MAJESTT.{cr}
 ECHR ' '               ;                {cr}
 ETOK 154               ;                 {single cap}UND VIELLEICHT FRHER ALS
 ECHR '!'               ;                {single cap}SIE DENKEN...{cr}
 EJMP 12                ;                {left align}{cr}
 EJMP 12                ;                {tab 6}{all caps} {single cap}ENDE DER
 EJMP 26                ;                {single cap}NACHRICHT
 ECHR 'F'               ;                {wait for key press}"
 ERND 2                 ;
 ECHR 'R'               ; Encoded as:   "{25}{9}{29}{14}{13}{26}B<248>VO [154]!
 ETOK 179               ;                {12}{12}{26}F[2?]R[179] GIBT[161]<222>
 ECHR ' '               ;                <221>S [183]<246>{26}PL<245>Z[188][155]
 ECHR 'G'               ;                [211][204]UND VIEL<229>[186]T FR[2?]H
 ECHR 'I'               ;                <244> <228>S[179] D<246>K<246>..[212]
 ECHR 'B'               ;                {24}"
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
                        ;
                        ; Encoded as:   ""
                        
                        ; Encoded as:   ""

 EQUB VE                ; Token 17:     ""
                        ;
                        ; Encoded as:   ""

 EQUB VE                ; Token 18:     ""
                        ;
                        ; Encoded as:   ""

 EQUB VE                ; Token 19:     ""
                        ;
                        ; Encoded as:   ""

 EQUB VE                ; Token 20:     ""
                        ;
                        ; Encoded as:   ""

 EQUB VE                ; Token 21:     ""
                        ;
                        ; Encoded as:   ""

 EQUB VE                ; Token 22:     ""
                        ;
                        ; Encoded as:   ""

 EQUB VE                ; Token 23:     ""
                        ;
                        ; Encoded as:   ""

 EQUB VE                ; Token 24:     ""
                        ;
                        ; Encoded as:   ""

 EQUB VE                ; Token 25:     ""
                        ;
                        ; Encoded as:   ""

 EQUB VE                ; Token 26:     ""
                        ;
                        ; Encoded as:   ""

 EQUB VE                ; Token 27:     ""
                        ;
                        ; Encoded as:   ""

 EQUB VE                ; Token 28:     ""
                        ;
                        ; Encoded as:   ""

 EQUB VE                ; Token 29:     ""
                        ;
                        ; Encoded as:   ""

 EQUB VE                ; Token 30:     ""
                        ;
                        ; Encoded as:   ""

 EQUB VE                ; Token 31:     ""
                        ;
                        ; Encoded as:   ""

 EQUB VE                ; Token 32:     ""
                        ;
                        ; Encoded as:   ""

 EQUB VE                ; Token 33:     ""
                        ;
                        ; Encoded as:   ""

 EQUB VE                ; Token 34:     ""
                        ;
                        ; Encoded as:   ""

 EQUB VE                ; Token 35:     ""
                        ;
                        ; Encoded as:   ""

 EQUB VE                ; Token 36:     ""
                        ;
                        ; Encoded as:   ""

 EQUB VE                ; Token 37:     ""
                        
                        ; Encoded as:   ""

 EQUB VE                ; Token 38:     ""
                        
                        ; Encoded as:   ""

 EQUB VE                ; Token 39:     ""
                        
                        ; Encoded as:   ""

 EQUB VE                ; Token 40:     ""
                        
                        ; Encoded as:   ""

 EQUB VE                ; Token 41:     ""
                        
                        ; Encoded as:   ""

 EQUB VE                ; Token 42:     ""
                        
                        ; Encoded as:   ""

 EQUB VE                ; Token 43:     ""
                        
                        ; Encoded as:   ""

 EQUB VE                ; Token 44:     ""
                        
                        ; Encoded as:   ""

 EQUB VE                ; Token 45:     ""
                        
                        ; Encoded as:   ""

 EQUB VE                ; Token 46:     ""
                        
                        ; Encoded as:   ""

 EQUB VE                ; Token 47:     ""
                        
                        ; Encoded as:   ""

 EQUB VE                ; Token 48:     ""
                        
                        ; Encoded as:   ""

 EQUB VE                ; Token 49:     ""
                        
                        ; Encoded as:   ""

 EQUB VE                ; Token 50:     ""
                        
                        ; Encoded as:   ""

 EQUB VE                ; Token 51:     ""
                        
                        ; Encoded as:   ""

 EQUB VE                ; Token 52:     ""
                        
                        ; Encoded as:   ""

 EQUB VE                ; Token 53:     ""
                        
                        ; Encoded as:   ""

 EQUB VE                ; Token 54:     ""
                        
                        ; Encoded as:   ""

 EQUB VE                ; Token 55:     ""
                        
                        ; Encoded as:   ""

 EQUB VE                ; Token 56:     ""
                        
                        ; Encoded as:   ""

 EQUB VE                ; Token 57:     ""
                        
                        ; Encoded as:   ""

 EQUB VE                ; Token 58:     ""
                        
                        ; Encoded as:   ""

 EQUB VE                ; Token 59:     ""
                        
                        ; Encoded as:   ""

 EQUB VE                ; Token 60:     ""
                        
                        ; Encoded as:   ""

 EQUB VE                ; Token 61:     ""
                        
                        ; Encoded as:   ""

 EQUB VE                ; Token 62:     ""
                        
                        ; Encoded as:   ""

 EQUB VE                ; Token 63:     ""
                        
                        ; Encoded as:   ""

 EQUB VE                ; Token 64:     ""
                        
                        ; Encoded as:   ""

 EQUB VE                ; Token 65:     ""
                        
                        ; Encoded as:   ""

 EQUB VE                ; Token 66:     ""
                        
                        ; Encoded as:   ""

 EQUB VE                ; Token 67:     ""
                        
                        ; Encoded as:   ""

 EQUB VE                ; Token 68:     ""
                        
                        ; Encoded as:   ""

 EQUB VE                ; Token 69:     ""
                        
                        ; Encoded as:   ""

 EQUB VE                ; Token 70:     ""
                        
                        ; Encoded as:   ""

 EQUB VE                ; Token 71:     ""
                        
                        ; Encoded as:   ""

 EQUB VE                ; Token 72:     ""
                        
                        ; Encoded as:   ""

 EQUB VE                ; Token 73:     ""
                        
                        ; Encoded as:   ""

 EQUB VE                ; Token 74:     ""
                        
                        ; Encoded as:   ""

 EQUB VE                ; Token 75:     ""
                        
                        ; Encoded as:   ""

 EQUB VE                ; Token 76:     ""
                        
                        ; Encoded as:   ""

 EQUB VE                ; Token 77:     ""
                        
                        ; Encoded as:   ""

 EQUB VE                ; Token 78:     ""
                        
                        ; Encoded as:   ""

 EQUB VE                ; Token 79:     ""
                        
                        ; Encoded as:   ""

 EQUB VE                ; Token 80:     ""
                        
                        ; Encoded as:   ""

 EQUB VE                ; Token 81:     ""
                        
                        ; Encoded as:   ""

 EQUB VE                ; Token 82:     ""
                        
                        ; Encoded as:   ""

 EQUB VE                ; Token 83:     ""
                        
                        ; Encoded as:   ""

 EQUB VE                ; Token 84:     ""
                        
                        ; Encoded as:   ""

 EJMP 2                 ; Token 85:     "{sentence case}{lower case}"
 ERND 31                ;
 EJMP 13                ; Encoded as:   "{2}[31?]{13}"
 EQUB VE

 EQUB VE                ; Token 86:     ""
                        
                        ; Encoded as:   ""

 EQUB VE                ; Token 87:     ""
                        
                        ; Encoded as:   ""

 EQUB VE                ; Token 88:     ""
                        
                        ; Encoded as:   ""

 EQUB VE                ; Token 89:     ""
                        
                        ; Encoded as:   ""

 EQUB VE                ; Token 90:     ""
                        
                        ; Encoded as:   ""

 EJMP 19                ; Token 91:     "{single cap}HALUNKE"
 ECHR 'H'               ;
 ETWO 'A', 'L'          ; Encoded as:   "{19}H<228>UNKE"
 ECHR 'U'
 ECHR 'N'
 ECHR 'K'
 ECHR 'E'
 EQUB VE

 EJMP 19                ; Token 92:     "{single cap}SCHURKE"
 ETOK 187               ;
 ECHR 'U'               ; Encoded as:   "{19}[187]URKE"
 ECHR 'R'
 ECHR 'K'
 ECHR 'E'
 EQUB VE

 EJMP 19                ; Token 93:     "{single cap}LUMP"
 ECHR 'L'               ;
 ECHR 'U'               ; Encoded as:   "{19}[187]URKE"
 ECHR 'M'
 ECHR 'P'
 EQUB VE

 EJMP 19                ; Token 94:     "{single cap}GAUNER"
 ECHR 'G'               ;
 ECHR 'A'               ; Encoded as:   "{19}GAUN<244>"
 ECHR 'U'
 ECHR 'N'
 ETWO 'E', 'R'
 EQUB VE

 EJMP 19                ; Token 95:     "{single cap}SCHUFT"
 ETOK 187               ;
 ECHR 'U'               ; Encoded as:   "{19}[187]UFT"
 ECHR 'F'
 ECHR 'T'
 EQUB VE

 EQUB VE                ; Token 96:     ""
                        
                        ; Encoded as:   ""

 EQUB VE                ; Token 97:     ""
                        
                        ; Encoded as:   ""

 EQUB VE                ; Token 98:     ""
                        
                        ; Encoded as:   ""

 EQUB VE                ; Token 99:     ""
                        
                        ; Encoded as:   ""

 EQUB VE                ; Token 100:    ""
                        
                        ; Encoded as:   ""

 EQUB VE                ; Token 101:    ""
                        
                        ; Encoded as:   ""

 EQUB VE                ; Token 102:    ""
                        
                        ; Encoded as:   ""

 EQUB VE                ; Token 103:    ""
                        
                        ; Encoded as:   ""

 EQUB VE                ; Token 104:    ""
                        
                        ; Encoded as:   ""

 EQUB VE                ; Token 105:    ""
                        
                        ; Encoded as:   ""

 EJMP 19                ; Token 106:    "{single cap}ANSCHEINEND ERSCHIEN EIN
 ETWO 'A', 'N'          ;                GRIMMIG AUSSEHENDES {single cap}SCHIFF
 ETOK 187               ;                IN {single cap}ERRIUS"
 ETOK 183               ;
 ETWO 'E', 'N'          ; Encoded as:   "{19}<255>[187][183]<246>D <244>[187]I
 ECHR 'D'               ;                <246>[185]GRIMMIG A<236><218>H<246>D
 ECHR ' '               ;                <237>[182] <240>[209]"
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

 EJMP 19                ; Token 107:    "{single cap}JA, EIN UNHEIMLICHES
 ECHR 'J'               ;                {single cap}SCHIFF SOLL VOR EINIGER
 ECHR 'A'               ;                {single cap}ZEIT VON {single cap}ERRIUS
 ECHR ','               ;                ABGEFLOGEN SEIN"
 ETOK 185               ;
 ECHR 'U'               ; Encoded as:   "{19}JA,[185]UNHEIML[186]<237>[182]
 ECHR 'N'               ;                 <235>LL [157] [183]I<231>R{26}ZE<219>
 ECHR 'H'               ;                 V<223>[209] <216><231>F<224><231>N
 ECHR 'E'               ;                 <218><240>"
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

 EJMP 19                ; Token 108:    "{single cap}SETZEN {single cap}SIE
 ETWO 'S', 'E'          ;                {single cap}IHR DICKES {single cap}FELL
 ETOK 158               ;                IN {single cap}BEWEGUNG NACH {single
 ETWO 'E', 'N'          ;                cap}ERRIUS"
 ETOK 179               ;
 EJMP 26                ; Encoded as:   "{19}<218>[158]<246>[179]{26}IHR <241>CK
 ECHR 'I'               ;                <237>{26}FELL <240>{26}<247>WEGUNG N
 ECHR 'H'               ;                [164][209]"
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

 ETOK 183               ; Token 109:    "EIN [91-95] VON EINEM NEUEN {single
 ECHR ' '               ;                cap}SCHIFF WURDE IN DER {single cap}NHE
 ERND 24                ;                VON {single cap}ERRIUS GESEHEN"
 ECHR ' '               ;
 ECHR 'V'               ; Encoded as:   "[183] [24?] V<223> [183]EM NEU<246>
 ETWO 'O', 'N'          ;                [182] WURDE[188]D<244>{26}N[0?]HE V
 ECHR ' '               ;                <223>[209] <231><218>H<246>"
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

 ECHR 'F'               ; Token 110:    "FAHREN {single cap}SIE NACH {single
 ECHR 'A'               ;                cap}ERRIUS"
 ECHR 'H'               ;
 ETWO 'R', 'E'          ; Encoded as:   "FAH<242>N[179] N[164][209]"
 ECHR 'N'
 ETOK 179
 ECHR ' '
 ECHR 'N'
 ETOK 164
 ETOK 209
 EQUB VE

 ECHR ' '               ; Token 111:    " KNUDDELIG"
 ECHR 'K'               ;
 ETWO 'N', 'U'          ; Encoded as:   " K<225>DDELIG"
 ECHR 'D'
 ECHR 'D'
 ECHR 'E'
 ECHR 'L'
 ECHR 'I'
 ECHR 'G'
 EQUB VE

 ECHR ' '               ; Token 112:    " NIEDLICH"
 ECHR 'N'               ;
 ECHR 'I'               ; Encoded as:   " NI<252>L[186]"
 ETWO 'E', 'D'
 ECHR 'L'
 ETOK 186
 EQUB VE

 ECHR ' '               ; Token 113:    " PUTZIG"
 ECHR 'P'               ;
 ECHR 'U'               ; Encoded as:   " PU[158]IG"
 ETOK 158
 ECHR 'I'
 ECHR 'G'
 EQUB VE

 ECHR ' '               ; Token 114:    " FREUNDLICH"
 ECHR 'F'               ;
 ETWO 'R', 'E'          ; Encoded as:   " F<242>UNDL[186]"
 ECHR 'U'
 ECHR 'N'
 ECHR 'D'
 ECHR 'L'
 ETOK 186
 EQUB VE

 EQUB VE                ; Token 115:    ""
                        
                        ; Encoded as:   ""

 EQUB VE                ; Token 116:    ""
                        
                        ; Encoded as:   ""

 EQUB VE                ; Token 117:    ""
                        
                        ; Encoded as:   ""

 EQUB VE                ; Token 118:    ""
                        
                        ; Encoded as:   ""

 EQUB VE                ; Token 119:    ""
                        
                        ; Encoded as:   ""

 EQUB VE                ; Token 120:    ""
                        
                        ; Encoded as:   ""

 EQUB VE                ; Token 121:    ""
                        
                        ; Encoded as:   ""

 EQUB VE                ; Token 122:    ""
                        
                        ; Encoded as:   ""

 EQUB VE                ; Token 123:    ""
                        
                        ; Encoded as:   ""

 EQUB VE                ; Token 124:    ""
                        
                        ; Encoded as:   ""

 EQUB VE                ; Token 125:    ""
                        
                        ; Encoded as:   ""

 EQUB VE                ; Token 126:    ""
                        
                        ; Encoded as:   ""

 EQUB VE                ; Token 127:    ""
                        
                        ; Encoded as:   ""

 EQUB VE                ; Token 128:    ""
                        
                        ; Encoded as:   ""

 EQUB VE                ; Token 129:    ""
                        
                        ; Encoded as:   ""

 EQUB VE                ; Token 130:    ""
                        
                        ; Encoded as:   ""

 EQUB VE                ; Token 131:    ""
                        
                        ; Encoded as:   ""

 EQUB VE                ; Token 132:    ""
                        
                        ; Encoded as:   ""

 EQUB VE                ; Token 133:    ""
                        
                        ; Encoded as:   ""

 EQUB VE                ; Token 134:    ""
                        
                        ; Encoded as:   ""

 EQUB VE                ; Token 135:    ""
                        
                        ; Encoded as:   ""

 EQUB VE                ; Token 136:    ""
                        
                        ; Encoded as:   ""

 EQUB VE                ; Token 137:    ""
                        
                        ; Encoded as:   ""

 EQUB VE                ; Token 138:    ""
                        
                        ; Encoded as:   ""

 EQUB VE                ; Token 139:    ""
                        
                        ; Encoded as:   ""

 EQUB VE                ; Token 140:    ""
                        
                        ; Encoded as:   ""

 EQUB VE                ; Token 141:    ""
                        
                        ; Encoded as:   ""

 EQUB VE                ; Token 142:    ""
                        
                        ; Encoded as:   ""

 EQUB VE                ; Token 143:    ""
                        
                        ; Encoded as:   ""

 EQUB VE                ; Token 144:    ""
                        
                        ; Encoded as:   ""

 EJMP 19                ; Token 145:    "{single cap}PLANET"
 ECHR 'P'               ;
 ETWO 'L', 'A'          ; Encoded as:   "{19}P<249>N<221>"
 ECHR 'N'
 ETWO 'E', 'T'
 EQUB VE

 EJMP 19                ; Token 146:    "{single cap}WELT"
 ECHR 'W'               ;
 ECHR 'E'               ; Encoded as:   "{19}WELT"
 ECHR 'L'
 ECHR 'T'
 EQUB VE

 ETWO 'D', 'I'          ; Token 147:    "DIE "
 ECHR 'E'               ;
 ECHR ' '               ; Encoded as:   "<241>E "
 EQUB VE

 ETWO 'D', 'I'          ; Token 148:    "DIESE "
 ECHR 'E'               ;
 ETWO 'S', 'E'          ; Encoded as:   "<241>E<218> "
 ECHR ' '
 EQUB VE

 EQUB VE                ; Token 149:    ""
                        
                        ; Encoded as:   ""

 EJMP 9                 ; Token 150:    "{clear screen}
 EJMP 11                ;                {draw box around title}
 EJMP 1                 ;                {all caps}{tab 6}"
 EJMP 8                 ;
 EQUB VE                ; Encoded as:   "{9}{11}{1}{8}"

 EQUB VE                ; Token 151:    ""
                        
                        ; Encoded as:   ""

 EQUB VE                ; Token 152:    ""
                        
                        ; Encoded as:   ""

 ECHR 'I'               ; Token 153:    "IAN"
 ETWO 'A', 'N'          ;
 EQUB VE                ; Encoded as:   "I<255>"

 EJMP 19                ; Token 154:    "{single cap}KOMMANDANT"
 ECHR 'K'               ;
 ECHR 'O'               ; Encoded as:   "{19}KOM<239>ND<255>T"
 ECHR 'M'
 ETWO 'M', 'A'
 ECHR 'N'
 ECHR 'D'
 ETWO 'A', 'N'
 ECHR 'T'
 EQUB VE

 ECHR 'D'               ; Token 155:    "DER "
 ETWO 'E', 'R'          ;
 ECHR ' '               ; Encoded as:   "D<244> "
 EQUB VE

 ECHR 'D'               ; Token 156:    "DAS "
 ECHR 'A'               ;
 ECHR 'S'               ; Encoded as:   "DAS "
 ECHR ' '
 EQUB VE

 ECHR 'V'               ; Token 157:    "VOR"
 ETWO 'O', 'R'          ;
 EQUB VE                ; Encoded as:   "V<253>"

 ECHR 'T'               ; Token 158:    "TZ"
 ECHR 'Z'               ;
 EQUB VE                ; Encoded as:   "TZ"

 ECHR 'Z'               ; Token 159:    "ZU"
 ECHR 'U'               ;
 EQUB VE                ; Encoded as:   "ZU"

 ECHR ' '               ; Token 160:    " ZU "
 ETOK 159               ;
 ECHR ' '               ; Encoded as:   " [159] "
 EQUB VE

 ECHR ' '               ; Token 161:    " ES "
 ETWO 'E', 'S'          ;
 ECHR ' '               ; Encoded as:   " <237> "
 EQUB VE

 ECHR 'N'               ; Token 162:    "NICHT"
 ETOK 186               ;
 ECHR 'T'               ; Encoded as:   "N[186]T"
 EQUB VE

 ECHR 'M'               ; Token 163:    "MARINE"
 ETWO 'A', 'R'          ;
 ETWO 'I', 'N'          ; Encoded as:   "M<238><240>E"
 ECHR 'E'
 EQUB VE

 ECHR 'A'               ; Token 164:    "ACH"
 ECHR 'C'               ;
 ECHR 'H'               ; Encoded as:   "ACH"
 EQUB VE

 EQUB VE                ; Token 165:    ""
                        
                        ; Encoded as:   ""

 EQUB VE                ; Token 166:    ""
                        
                        ; Encoded as:   ""

 EQUB VE                ; Token 167:    ""
                        
                        ; Encoded as:   ""

 EQUB VE                ; Token 168:    ""
                        
                        ; Encoded as:   ""

 EQUB VE                ; Token 169:    ""
                        
                        ; Encoded as:   ""

 EQUB VE                ; Token 170:    ""
                        
                        ; Encoded as:   ""

 EQUB VE                ; Token 171:    ""
                        
                        ; Encoded as:   ""

 EQUB VE                ; Token 172:    ""
                        
                        ; Encoded as:   ""

 EQUB VE                ; Token 173:    ""
                        
                        ; Encoded as:   ""

 EQUB VE                ; Token 174:    ""
                        
                        ; Encoded as:   ""

 ETWO 'I', 'T'          ; Token 175:    "ITS "
 ECHR 'S'               ;
 ECHR ' '               ; Encoded as:   "<219>S "
 EQUB VE

 EJMP 13                ; Token 176:    "{lower case}{justify}{single cap}"
 EJMP 14                ;
 EJMP 19                ; Encoded as:   "{13}{14}{19}"
 EQUB VE

 ECHR '.'               ; Token 177:    ".{cr}
 EJMP 12                ;                {left align}"
 EJMP 15                ;
 EQUB VE                ; Encoded as:   ".{12}{15}"

 ECHR ' '               ; Token 178:    " UND "
 ECHR 'U'               ;
 ECHR 'N'               ; Encoded as:   " UND "
 ECHR 'D'
 ECHR ' '
 EQUB VE

 EJMP 26                ; Token 179:    " {single cap}SIE"
 ECHR 'S'               ;
 ECHR 'I'               ; Encoded as:   "{26}SIE"
 ECHR 'E'
 EQUB VE

 ECHR ' '               ; Token 180:    " NACH "
 ECHR 'N'               ;
 ETOK 164               ; Encoded as:   " N[164] "
 ECHR ' '
 EQUB VE

 ECHR ' '               ; Token 181:    " IST "
 ECHR 'I'               ;
 ETWO 'S', 'T'          ; Encoded as:   " I<222> "
 ECHR ' '
 EQUB VE

 EJMP 26                ; Token 182:    " {single cap}SCHIFF"
 ETOK 187               ;
 ECHR 'I'               ; Encoded as:   "{26}[187]IFF"
 ECHR 'F'
 ECHR 'F'
 EQUB VE

 ECHR 'E'               ; Token 183:    "EIN"
 ETWO 'I', 'N'          ;
 EQUB VE                ; Encoded as:   "E<240>"

 ECHR ' '               ; Token 184:    " NEUES "
 ECHR 'N'               ;
 ECHR 'E'               ; Encoded as:   " NEU<237> "
 ECHR 'U'
 ETWO 'E', 'S'
 ECHR ' '
 EQUB VE

 ECHR ' '               ; Token 185:    " EIN "
 ETOK 183               ;
 ECHR ' '               ; Encoded as:   " [183] "
 EQUB VE

 ECHR 'I'               ; Token 186:    "ICH"
 ECHR 'C'               ;
 ECHR 'H'               ; Encoded as:   "ICH"
 EQUB VE

 ECHR 'S'               ; Token 187:    "SCH"
 ECHR 'C'               ;
 ECHR 'H'               ; Encoded as:   "SCH"
 EQUB VE

 ECHR ' '               ; Token 188:    " IN "
 ETWO 'I', 'N'          ;
 ECHR ' '               ; Encoded as:   " <240> "
 EQUB VE

 EQUB VE                ; Token 189:    ""
                        
                        ; Encoded as:   ""

 EQUB VE                ; Token 190:    ""
                        
                        ; Encoded as:   ""

 EQUB VE                ; Token 191:    ""
                        
                        ; Encoded as:   ""

 EQUB VE                ; Token 192:    ""
                        
                        ; Encoded as:   ""

 EQUB VE                ; Token 193:    ""
                        
                        ; Encoded as:   ""

 EQUB VE                ; Token 194:    ""
                        
                        ; Encoded as:   ""

 ETWO 'I', 'N'          ; Token 195:    "ING "
 ECHR 'G'               ;
 ECHR ' '               ; Encoded as:   "<240>G "
 EQUB VE

 ETWO 'E', 'D'          ; Token 196:    "ED "
 ECHR ' '               ;
 EQUB VE                ; Encoded as:   "<252> "

 EQUB VE                ; Token 197:    ""
                        
                        ; Encoded as:   ""

 EJMP 26                ; Token 198:    " {single cap}SQUEAKY"
 ECHR 'S'               ;
 ETWO 'Q', 'U'          ; Encoded as:   "{26}S<254>EAKY"
 ECHR 'E'
 ECHR 'A'
 ECHR 'K'
 ECHR 'Y'
 EQUB VE

 EJMP 25                ; Token 199:    "{incoming message screen, wait 2s}
 EJMP 9                 ;                {clear screen}
 EJMP 29                ;                {move to row 7, lower case}{justify}
 EJMP 14                ;                {lower case} {single cap}GUTEN {single
 EJMP 13                ;                cap}TAG {single cap}KOMMANDANT. {single
 EJMP 26                ;                cap}DARF ICH MICH VORSTELLEN? {single
 ECHR 'G'               ;                cap}ICH BIN DER {single cap}PRINZ VON
 ECHR 'U'               ;                {single cap}THRUN. {single cap}ICH SEHE
 ECHR 'T'               ;                MICH LEIDER GEZWUNGEN, MEINEN LIEBSTEN
 ETWO 'E', 'N'          ;                {single cap}BESITZ ZU VERUERN.{cr}
 EJMP 26                ;                {cr}
 ECHR 'T'               ;                 {single cap}{single cap}FR DIE {single
 ECHR 'A'               ;                cap}KLEINIGKEIT VON 5000{single cap}CR
 ECHR 'G'               ;                BIETE ICH {single cap}IHNEN DAS {single
 EJMP 26                ;                cap}SELTENSTE DES {single cap}
 ECHR 'K'               ;                UNIVERSUMS AN.{cr}
 ECHR 'O'               ;                {cr}
 ECHR 'M'               ;                 {single cap}{single cap}NEHMEN {single
 ETWO 'M', 'A'          ;                cap}SIE ES?{cr}{left align}{all caps}
 ECHR 'N'               ;                {tab 6}"
 ECHR 'D'               ;
 ETWO 'A', 'N'          ; Encoded as:   "{25}{9}{29}{14}{13}{26}GUT<246>{26}TAG
 ECHR 'T'               ;                {26}KOM<239>ND<255>T.{26}D<238>F [186]
 ECHR '.'               ;                 M[186] [157]<222>EL<229>N?{26}[186]
 EJMP 26                ;                 <234>N D<244>{26}PR<240>Z V<223>{26}
 ECHR 'D'               ;                <226>RUN.{26}[186] <218>HE M[186] <229>
 ETWO 'A', 'R'          ;                I[155]<231>ZWUN<231>N, M[183]<246> LIEB
 ECHR 'F'               ;                <222><246>{26}B<237><219>Z[160]V<244>
 ECHR ' '               ;                [0?]U[3?]<244>N[204]{19}F[2?]R <241>E
 ETOK 186               ;                {26}K<229><240>IGKE<219> V<223> 5000
 ECHR ' '               ;                {19}CR <234><221>E [186]{26}IHN<246> DA
 ECHR 'M'               ;                S{26}<218>LT<246><222>E D<237>{26}UNIV
 ETOK 186               ;                <244>SUMS <255>[204]{19}NEHM<246>[179]
 ECHR ' '               ;                 <237>?{12}{15}{1}{8}"
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

 EJMP 26                ; Token 200:    " {single cap}NAME? "
 ECHR 'N'               ;
 ECHR 'A'               ; Encoded as:   "{26}NAME? "
 ECHR 'M'
 ECHR 'E'
 ECHR '?'
 ECHR ' '
 EQUB VE

 EQUB VE                ; Token 201:    ""
                        
                        ; Encoded as:   ""

 EQUB VE                ; Token 202:    ""
                        
                        ; Encoded as:   ""

 ECHR 'W'               ; Token 203:    "WURDE ZULETZT GESEHEN IN {single cap} "
 ECHR 'U'               ;
 ECHR 'R'               ; Encoded as:   "WURDE [159]L<221>ZT <231><218>H<246>
 ECHR 'D'               ;                [188]{19} "
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

 ECHR '.'               ; Token 204:    ".{cr}
 EJMP 12                ;                {cr}
 EJMP 12                ;                 {single cap}"
 ECHR ' '               ;
 EJMP 19                ; Encoded as:   ".{12}{12} {19}"
 EQUB VE

 EJMP 19                ; Token 205:    "{single cap}GEDOCKT"
 ETWO 'G', 'E'          ;
 ECHR 'D'               ; Encoded as:   "{19}<231>DOCKT"
 ECHR 'O'
 ECHR 'C'
 ECHR 'K'
 ECHR 'T'
 EQUB VE

 EQUB VE                ; Token 206:    ""
                        
                        ; Encoded as:   ""

 EQUB VE                ; Token 207:    ""
                        
                        ; Encoded as:   ""

 EQUB VE                ; Token 208:    ""
                        
                        ; Encoded as:   ""

 EJMP 26                ; Token 209:    " {single cap}ERRIUS"
 ETWO 'E', 'R'          ;
 ECHR 'R'               ; Encoded as:   "{26}<244>RI<236>"
 ECHR 'I'
 ETWO 'U', 'S'
 EQUB VE

 EQUB VE                ; Token 210:    ""
                        
                        ; Encoded as:   ""

 EJMP 26                ; Token 211:    " {single cap}RAUMFAHRTMARINE UNSERER
 ETWO 'R', 'A'          ;                 {single cap}MAJESTT"
 ECHR 'U'               ;
 ECHR 'M'               ; Encoded as:   "{26}<248>UMFAHRT[163] UN<218><242>R{26}
 ECHR 'F'               ;                <239>JE<222>[0?]T"
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

 ETOK 177               ; Token 212:    ".{cr}
 EJMP 12                ;                {left align}{cr}
 EJMP 8                 ;                {tab 6}{all caps} {single cap}ENDE DER
 EJMP 1                 ;                {single cap}NACHRICHT"
 EJMP 26                ;
 ETWO 'E', 'N'          ; Encoded as:   "[177]{12}{8}{1}{26}<246>DE D<244>{26}N
 ECHR 'D'               ;                [164]R[186]T"
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

 ECHR ' '               ; Token 213:    " {single cap}KOMMANDANT {commander
 ETOK 154               ;                name}. {single cap}ICH {lower case}BIN
 ECHR ' '               ;                {single cap}KAPITN {mission captain's
 EJMP 4                 ;                name} DER {single cap}RAUMFAHRTMARINE
 ECHR '.'               ;                UNSERER {single cap}MAJESTT"
 EJMP 26                ;
 ETOK 186               ; Encoded as:   " [154] {4}.{26}[186] {13}<234>N{26}KAP
 ECHR ' '               ;                <219>[0?]N {27} D<244>[211]"
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
                        
                        ; Encoded as:   ""

 EJMP 15                ; Token 215:    "{left align} {single cap}UNBEKANNTER
 EJMP 26                ;                {single cap}PLANET"
 ECHR 'U'               ;
 ECHR 'N'               ; Encoded as:   "{15}{26}UN<247>K<255>NT<244>{26}P<249>N
 ETWO 'B', 'E'          ;                <221>"
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

 EJMP 9                 ; Token 216:    "{clear screen}
 EJMP 8                 ;                {tab 6}{move to row 9,lower case}{all
 EJMP 23                ;                caps}ANKOMMENDE {single cap}NACHRICHT"
 EJMP 1                 ;
 ETWO 'A', 'N'          ; Encoded as:   "{9}{8}{23}{1}<255>KOMM<246>DE{26}N[164]
 ECHR 'K'               ;                R[186]T"
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

 EJMP 19                ; Token 217:    "{single cap}RICHTOFEN"
 ECHR 'R'               ;
 ETOK 186               ; Encoded as:   "{19}R[186]TOF<246>"
 ECHR 'T'
 ECHR 'O'
 ECHR 'F'
 ETWO 'E', 'N'
 EQUB VE

 EJMP 19                ; Token 218:    "{single cap}VANDERBILT"
 ECHR 'V'               ;
 ETWO 'A', 'N'          ; Encoded as:   "{19}V<255>D<244>B<220>T"
 ECHR 'D'
 ETWO 'E', 'R'
 ECHR 'B'
 ETWO 'I', 'L'
 ECHR 'T'
 EQUB VE

 EJMP 19                ; Token 219:    "{single cap}HABSBURG"
 ECHR 'H'               ;
 ETWO 'A', 'B'          ; Encoded as:   "{19}H<216>SBURG"
 ECHR 'S'
 ECHR 'B'
 ECHR 'U'
 ECHR 'R'
 ECHR 'G'
 EQUB VE

 ETOK 203               ; Token 220:    "WURDE ZULETZT GESEHEN IN {single cap}
 EJMP 19                ;                {single cap}REESDICE
 ETWO 'R', 'E'          ;
 ETWO 'E', 'S'          ; Encoded as:   "[203]{19}<242><237><241><233>"
 ETWO 'D', 'I'
 ETWO 'C', 'E'
 EQUB VE

 ETWO 'S', 'O'          ; Token 221:    "SOLLEN IN DIESE {single cap}GALAXIE
 ECHR 'L'               ;                GESPRUNGEN SEIN"
 ETWO 'L', 'E'          ;
 ECHR 'N'               ; Encoded as:   "<235>L<229>N[188]<241>E<218>{26}G<228>A
 ETOK 188               ;                XIE <231>SPRUN<231>N <218><240>"
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

 EJMP 25                ; Token 222:    "{incoming message screen, wait 2s}
 EJMP 9                 ;                {clear screen}
 EJMP 29                ;                {move to row 7, lower case}{justify}
 EJMP 14                ;                {lower case} {single cap}GUTEN {single
 EJMP 13                ;                cap}TAG {single cap}KOMMANDANT.{cr}
 EJMP 26                ;                {cr}
 ECHR 'G'               ;                 {single cap}{single cap}ICH BIN
 ECHR 'U'               ;                {single cap}AGENT {single cap}BLAKE DES
 ECHR 'T'               ;                {single cap}GEHEIMDIENSTES DER {single
 ETWO 'E', 'N'          ;                cap}MARINE.{cr}
 EJMP 26                ;                {cr}
 ECHR 'T'               ;                 {single cap}{single cap}WIE {single
 ECHR 'A'               ;                cap}SIE WISSEN, HAT DIE {single cap}
 ECHR 'G'               ;                MARINE DIE {single cap}THARGOIDS SEIT
 EJMP 26                ;                VIELEN {single cap}JAHREN WEIT WEG VON
 ECHR 'K'               ;                {single cap}IHNEN IM TIEFSTEN {single
 ECHR 'O'               ;                cap}WELTRAUM GEHALTEN. {single cap}
 ECHR 'M'               ;                JETZT ABER HAT DIE {single cap}LAGE
 ETWO 'M', 'A'          ;                SICH GENDERT.{cr}
 ECHR 'N'               ;                {cr}
 ECHR 'D'               ;                 {single cap}{single cap}UNSERE {single
 ETWO 'A', 'N'          ;                cap}JUNGS SIND BEREIT, BIS INS {single
 ECHR 'T'               ;                cap}GEHEIMSYSTEM DER {single cap}MRDER
 ETOK 204               ;                VORZUSTOEN.{cr}
 EJMP 19                ;                {cr}
 ETOK 186               ;                 {single cap}{wait for key press}
 ECHR ' '               ;                {clear screen}
 ETWO 'B', 'I'          ;                {move to row 7, lower case}DIE {single
 ECHR 'N'               ;                cap}VERTEIDIGUNGSPLNE DER {single cap}
 EJMP 26                ;                HIVE {single cap}WELT HABE ICH
 ECHR 'A'               ;                ERHALTEN.{cr}
 ETWO 'G', 'E'          ;                {cr}
 ECHR 'N'               ;                 {single cap}{single cap}DIE {single
 ECHR 'T'               ;                cap}KFER WISSEN, DA WIR ETWAS HABEN,
 EJMP 26                ;                ABER NICHT GENAU WAS.{cr}
 ECHR 'B'               ;                {cr}
 ETWO 'L', 'A'          ;                 {single cap}{single cap}WENN ICH DIE
 ECHR 'K'               ;                {single cap}PLNE NACH UNSERER {single
 ECHR 'E'               ;                cap}BASIS AUF {single cap}BIRERA SENDE,
 ECHR ' '               ;                WERDEN DIE {single cap}KFER SIE
 ECHR 'D'               ;                ABFANGEN. {single cap}ICH BRAUCHE EIN
 ETWO 'E', 'S'          ;                {single cap}SCHIFF, UM DIE {single cap}
 EJMP 26                ;                NACHRICHT ZU BERBRINGEN.{cr}
 ETWO 'G', 'E'          ;                {cr}
 ECHR 'H'               ;                 {single cap}{single cap}SIE WERDEN
 ECHR 'E'               ;                DAZU AUSERWHLT.{cr}
 ECHR 'I'               ;                {cr}
 ECHR 'M'               ;                 {single cap}{wait for key press}
 ETWO 'D', 'I'          ;                {clear screen}
 ETWO 'E', 'N'          ;                {move to row 7, lower case}DIE {single
 ETWO 'S', 'T'          ;                cap}PLNE SIND IN DIESER {single cap}
 ETWO 'E', 'S'          ;                SENDUNG IN {single cap}UNI{single cap}
 ECHR ' '               ;                PULSE KODIERT.{cr}
 ECHR 'D'               ;                {cr}
 ETWO 'E', 'R'          ;                 {single cap}{single cap}SIE WERDEN
 EJMP 26                ;                DAFR BEZAHLT.{cr}
 ETOK 163               ;                {cr}
 ETOK 204               ;                 {single cap}{single cap}VIEL {single
 EJMP 19                ;                cap}GLCK {single cap}KOMMANDANT.{cr}
 ECHR 'W'               ;                {left align}{cr}
 ECHR 'I'               ;                {tab 6}{all caps} {single cap}ENDE DER
 ECHR 'E'               ;                {single cap}NACHRICHT
 ETOK 179               ;                {wait for key press}"
 ECHR ' '               ;
 ECHR 'W'               ; Encoded as:   "{25}{9}{29}{14}{13}{26}GUT<246>{26}TAG
 ECHR 'I'               ;                {26}KOM<239>ND<255>T[204]{19}[186]
 ECHR 'S'               ;                <234>N{26}A<231>NT{26}B<249>KE D<237>
 ETWO 'S', 'E'          ;                {26}<231>HEIM<241><246><222><237> D
 ECHR 'N'               ;                <244>{26}[163][204]{19}WIE[179] WIS
 ECHR ','               ;                <218>N, H<245> <241>E{26}[163] <241>E
 ECHR ' '               ;                {26}<226><238>GOIDS <218><219> VIE<229>
 ECHR 'H'               ;                N{26}JAH<242>N WE<219> WEG V<223>{26}IH
 ETWO 'A', 'T'          ;                N<246> IM <251>EF<222><246>{26}WELT
 ECHR ' '               ;                <248>UM <231>H<228>T<246>.{26}J<221>ZT
 ETWO 'D', 'I'          ;                 <216><244> H<245> <241>E{26}<249><231>
 ECHR 'E'               ;                 S[186] <231>[0?]ND<244>T[204]{19}UN
 EJMP 26                ;                <218><242>{26}JUNGS S<240>D <247><242>
 ETOK 163               ;                <219>, <234>S <240>S{26}<231>HEIMSY
 ECHR ' '               ;                <222>EM D<244>{26}M[1?]R[155][157][159]
 ETWO 'D', 'I'          ;                <222>O[3?]<246>[204]{24}{9}{29}<241>E
 ECHR 'E'               ;                {26}V<244>TEI<241>GUNGSPL[0?]NE D<244>
 EJMP 26                ;                {26}HI<250>{26}WELT H<216>E [186] <244>
 ETWO 'T', 'H'          ;                H<228>T<246>[204]{19}<241>E{26}K[0?]F
 ETWO 'A', 'R'          ;                <244> WIS<218>N, DA[3?] WIR <221>WAS H
 ECHR 'G'               ;                <216><246>, <216><244> [162] <231>NAU W
 ECHR 'O'               ;                AS[204]{19}W<246>N [186] <241>E{26}PL
 ECHR 'I'               ;                [0?]NE[180]UN<218><242>R{26}BASIS AUF
 ECHR 'D'               ;                {26}<234><242><248> <218>NDE, W<244>D
 ECHR 'S'               ;                <246> <241>E{26}K[0?]F<244> SIE <216>F
 ECHR ' '               ;                <255><231>N.{26}[186] B<248>UCHE [183]
 ETWO 'S', 'E'          ;                [182], UM <241>E{26}N[164]R[186]T[160]
 ETWO 'I', 'T'          ;                [2?]B<244>BR<240><231>N[204]{19}SIE W
 ECHR ' '               ;                <244>D<246> DA[159] AU<218>RW[0?]HLT
 ECHR 'V'               ;                [204]{24}{9}{29}<241>E{26}PL[0?]NE S
 ECHR 'I'               ;                <240>D[188]<241>E<218>R{26}<218>NDUNG
 ECHR 'E'               ;                 <240>{26}UNI{19}PUL<218> KO<241><244>T
 ETWO 'L', 'E'          ;                [204]{19}SIE W<244>D<246> DAF[2?]R
 ECHR 'N'               ;                 <247><232>HLT[204]{19}VIEL{26}GL[2?]CK
 EJMP 26                ;                 [154][212]{24}"
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

 EJMP 25                ; Token 223:    "{incoming message screen, wait 2s}
 EJMP 9                 ;                {clear screen}
 EJMP 29                ;                {move to row 7, lower case}{justify}
 EJMP 14                ;                {lower case} {single cap}GUT GEMACHT
 EJMP 13                ;                {single cap}KOMMANDANT.{cr}
 EJMP 26                ;                {cr}
 ECHR 'G'               ;                 {single cap}{single cap}SIE HABEN UNS
 ECHR 'U'               ;                FLEIIG GEDIENT, UND WIR WERDEN ES NICHT
 ECHR 'T'               ;                VERGESSEN.{cr}
 ECHR ' '               ;                {cr}
 ETWO 'G', 'E'          ;                 {single cap}{single cap}WIR HABEN
 ETWO 'M', 'A'          ;                NICHT ERWARTET, DA DIE {single cap}
 ECHR 'C'               ;                THARGOIDS BER {single cap}SIE {single
 ECHR 'H'               ;                cap}BESCHEID WUTEN.{cr}
 ECHR 'T'               ;                {cr}
 ECHR ' '               ;                 {single cap}{single cap}BITTE
 ETOK 154               ;                AKZEPTIEREN {single cap}SIE DIESE
 ETOK 204               ;                {single cap}ENERGIE-{single cap}EINHEIT
 EJMP 19                ;                DER {single cap}MARINE ALS {single cap}
 ECHR 'S'               ;                BEZAHLUNG.{cr}
 ECHR 'I'               ;                {left align}{cr}
 ECHR 'E'               ;                {tab 6}{all caps} {single cap}ENDE DER
 ECHR ' '               ;                {single cap}NACHRICHT
 ECHR 'H'               ;                {wait for key press}"
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
                        
                        ; Encoded as:   ""

 EQUB VE                ; Token 225:    ""
                        
                        ; Encoded as:   ""

 EQUB VE                ; Token 226:    ""
                        
                        ; Encoded as:   ""

 EQUB VE                ; Token 227:    ""
                        
                        ; Encoded as:   ""

 EQUB VE                ; Token 228:    ""
                        
                        ; Encoded as:   ""

 EQUB VE                ; Token 229:    ""
                        
                        ; Encoded as:   ""

 EQUB VE                ; Token 230:    ""
                        
                        ; Encoded as:   ""

 EQUB VE                ; Token 231:    ""
                        
                        ; Encoded as:   ""

 EQUB VE                ; Token 232:    ""
                        
                        ; Encoded as:   ""

 EQUB VE                ; Token 233:    ""
                        
                        ; Encoded as:   ""

 EQUB VE                ; Token 234:    ""
                        
                        ; Encoded as:   ""

 EQUB VE                ; Token 235:    ""
                        
                        ; Encoded as:   ""

 EQUB VE                ; Token 236:    ""
                        
                        ; Encoded as:   ""

 EQUB VE                ; Token 237:    ""
                        
                        ; Encoded as:   ""

 EQUB VE                ; Token 238:    ""
                        
                        ; Encoded as:   ""

 EQUB VE                ; Token 239:    ""
                        
                        ; Encoded as:   ""

 EQUB VE                ; Token 240:    ""
                        
                        ; Encoded as:   ""

 EQUB VE                ; Token 241:    ""
                        
                        ; Encoded as:   ""

 EQUB VE                ; Token 242:    ""
                        
                        ; Encoded as:   ""

 EQUB VE                ; Token 243:    ""
                        
                        ; Encoded as:   ""

 EQUB VE                ; Token 244:    ""
                        
                        ; Encoded as:   ""

 EQUB VE                ; Token 245:    ""
                        
                        ; Encoded as:   ""

 EQUB VE                ; Token 246:    ""
                        
                        ; Encoded as:   ""

 EQUB VE                ; Token 247:    ""
                        
                        ; Encoded as:   ""

 EQUB VE                ; Token 248:    ""
                        
                        ; Encoded as:   ""

 EQUB VE                ; Token 249:    ""
                        
                        ; Encoded as:   ""

 EQUB VE                ; Token 250:    ""
                        
                        ; Encoded as:   ""

 EQUB VE                ; Token 251:    ""
                        
                        ; Encoded as:   ""

 EQUB VE                ; Token 252:    ""
                        
                        ; Encoded as:   ""

 EQUB VE                ; Token 253:    ""
                        
                        ; Encoded as:   ""

 EQUB VE                ; Token 254:    ""
                        
                        ; Encoded as:   ""

 EQUB VE                ; Token 255:    ""
                        
                        ; Encoded as:   ""

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
                        ;
                        ; Encoded as:   ""

 EJMP 19                ; Token 1:      "{single cap}DIE {single cap}KOLONISTEN
 ETWO 'D', 'I'          ;                HABEN GEGEN DER  {single cap}
 ECHR 'E'               ;                INTERGALAKTISCHE {single cap}KLONING
 EJMP 26                ;                {single cap}PROTOKOL VERSTOENß MAN MU
 ECHR 'K'               ;                SIE MEIDEN"
 ECHR 'O'               ;
 ECHR 'L'               ; Encoded as:   "{19}<241>E{26}KOL<223>I<222><246> H
 ETWO 'O', 'N'          ;                <216><246> <231><231>N [155]{26}<240>T
 ECHR 'I'               ;                <244>G<228>AK<251>SCHE{26}KL<223><240>G
 ETWO 'S', 'T'          ;                {26}PROTOKOL V<244><222>O[3?]<246>;
 ETWO 'E', 'N'          ;                 <239>N MU[3?] SIE MEID<246>"
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

 EJMP 19                ; Token 2:      "{single cap}CONSTRICTOR WURDE ZULETZT
 ECHR 'C'               ;                GESEHEN IN {single cap} {single cap}
 ETWO 'O', 'N'          ;                REESDICE, {single cap}KOMMANDANT"
 ETWO 'S', 'T'          ;
 ECHR 'R'               ; Encoded as:   "{19}C<223><222>RICT<253> [203]{19}<242>
 ECHR 'I'               ;                <237><241><233>, [154]"
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

 EJMP 19                ; Token 3:      "{single cap}EIN GEFHRLICH AUSSEHENDES
 ECHR 'E'               ;                {single cap}SCHIFF FLOG VOR EINER
 ETWO 'I', 'N'          ;                {single cap}WEILE VON HIER AB. {single
 ECHR ' '               ;                cap}ES SAH AUS, ALS OB ES NACH {single
 ETWO 'G', 'E'          ;                cap}AREXE FLGE"
 ECHR 'F'               ;
 ERND 0                 ; Encoded as:   "{19}E<240> <231>F[0?]HRLICH A<236><218>
 ECHR 'H'               ;                H<246>D<237>{26}SCHIFF F<224>G V<253> E
 ECHR 'R'               ;                <240><244>{26}WE<220>E V<223> HI<244>
 ECHR 'L'               ;                 <216>.{26}<237> SAH A<236>, <228>S OB
 ECHR 'I'               ;                 <237> NACH{26}<238>E<230> FL[1?]<231>"
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

 EJMP 19                ; Token 4:      "{single cap}JA, EIN SELTSAMES {single
 ECHR 'J'               ;                cap}SCHIFF BEKAM HIER EINEN
 ECHR 'A'               ;                GALAKTISCHEN {single cap}
 ECHR ','               ;                HYPERSPRUNGANTRIEB. {single cap}BENUTZT
 ECHR ' '               ;                WURDE ES AUCHZU{single cap}DIESES
 ECHR 'E'               ;                MERKWRDIGE {single cap}SCHIFF TAU ES E
 ETWO 'I', 'N'          ;                WIE AUS DEM {single cap}NI ES S AUF,
 ECHR ' '               ;                UND VERSCHWAND AUCH WIEDER GENAUSO
 ETWO 'S', 'E'          ;                SCHNELL. {single cap}MAN SAGT, ES FLGE
 ECHR 'L'               ;                NACH {single cap}INBIBE"
 ECHR 'T'               ;
 ECHR 'S'               ; Encoded as:   "{19}JA, E<240> <218>LTSAM<237>{26}SCHIF
 ECHR 'A'               ;                F <247>KAM HI<244> E<240><246> G<228>AK
 ECHR 'M'               ;                <251>SCH<246>{26}HYP<244>SPRUNG<255>TRI
 ETWO 'E', 'S'          ;                EB.{26}<247><225>TZT WURDE <237> AUCH
 EJMP 26                ;                [159]{19}<241>E<218>S M<244>KW[2?]R
 ECHR 'S'               ;                <241><231>{26}SCHIFF TAU[161]E WIE A
 ECHR 'C'               ;                <236> DEM{26}NI[161]S AUF, UND V<244>SC
 ECHR 'H'               ;                HW<255>D AUCH WI<252><244> <231>NAU
 ECHR 'I'               ;                <235> SCHNELL.{26}<239>N SAGT, <237> FL
 ECHR 'F'               ;                [1?]<231> NACH{26}<240><234><247>"
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

 EJMP 19                ; Token 5:      "{single cap}EIN MCHTIGES {single
 ECHR 'E'               ;                cap}SCHIFF GRIFF MICH VOR {single cap}
 ETWO 'I', 'N'          ;                AUSAR AN. {single cap}MEINE {single
 ECHR ' '               ;                cap}LASER KONNTEN DIESEM [91-95]N NI ES
 ECHR 'M'               ;                EINMAL EINEN {single cap}KRATZER
 ERND 0                 ;                VERPASSEN."
 ECHR 'C'               ;
 ECHR 'H'               ; Encoded as:   "{19}E<240> M[0?]CH<251><231>S{26}SCHIFF
 ETWO 'T', 'I'          ;                 GRIFF MICH V<253>{26}A<236><238> <255>
 ETWO 'G', 'E'          ;                .{26}ME<240>E{26}<249><218>R K<223>NT
 ECHR 'S'               ;                <246> <241>E<218>M [24?]N NI[161] E
 EJMP 26                ;                <240>M<228> E<240><246>{26}KR<245>Z
 ECHR 'S'               ;                <244> V<244>PAS<218>N."
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

 EJMP 19                ; Token 6:      "{single cap}ACH JA, EIN FR ES ERLICHER
 ECHR 'A'               ;                {single cap}GAUNER SCHO AUF VIELE
 ECHR 'C'               ;                DIESER SCHRECKLICHEN {single cap}
 ECHR 'H'               ;                PIRATEN UND FUHR NACHHER NACH {single
 ECHR ' '               ;                cap}USLERI"
 ECHR 'J'               ;
 ECHR 'A'               ; Encoded as:   "{19}ACH JA, E<240> F[2?]R[161]<244>LICH
 ECHR ','               ;                <244>{26}GAUN<244> SCHO[3?] AUF VIE
 ECHR ' '               ;                <229> <241>E<218>R SCH<242>CKLICH<246>
 ECHR 'E'               ;                {26}PIR<245><246> UND FUHR NACHH<244> N
 ETWO 'I', 'N'          ;                ACH{26}<236><229>RI"
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

 EJMP 19                ; Token 7:      "{single cap}SIE KNNEN SICH DEN [91-95]
 ECHR 'S'               ;                VORNEHMEN, WENN {single cap}SIE WOLLEN.
 ECHR 'I'               ;                {single cap}ER IST IN {single
 ECHR 'E'               ;                cap}ORARRA"
 ECHR ' '               ;
 ECHR 'K'               ; Encoded as:   "{19}SIE K[1?]NN<246> SICH D<246> [24?]
 ERND 1                 ;                 V<253>NEHM<246>, W<246>N{26}SIE WOL
 ECHR 'N'               ;                <229>N.{26}<244> I<222> <240>{26}<253>
 ECHR 'N'               ;                <238><248>"
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

 ERND 25                ; Token 8:      "[106-110]"
 EQUB VE                ;
                        ; Encoded as:   "[25?]"

 ERND 25                ; Token 9:      "[106-110]"
 EQUB VE                ;
                        ; Encoded as:   "[25?]"

 ERND 25                ; Token 10:     "[106-110]"
 EQUB VE                ;
                        ; Encoded as:   "[25?]"

 ERND 25                ; Token 11:     "[106-110]"
 EQUB VE                ;
                        ; Encoded as:   "[25?]"

 ERND 25                ; Token 12:     "[106-110]"
 EQUB VE                ;
                        ; Encoded as:   "[25?]"

 ERND 25                ; Token 13:     "[106-110]"
 EQUB VE                ;
                        ; Encoded as:   "[25?]"

 ERND 25                ; Token 14:     "[106-110]"
 EQUB VE                ;
                        ; Encoded as:   "[25?]"

 ERND 25                ; Token 15:     "[106-110]"
 EQUB VE                ;
                        ; Encoded as:   "[25?]"

 ERND 25                ; Token 16:     "[106-110]"
 EQUB VE                ;
                        ; Encoded as:   "[25?]"

 ERND 25                ; Token 17:     "[106-110]"
 EQUB VE                ;
                        ; Encoded as:   "[25?]"

 ERND 25                ; Token 18:     "[106-110]"
 EQUB VE                ;
                        ; Encoded as:   "[25?]"

 ERND 25                ; Token 19:     "[106-110]"
 EQUB VE                ;
                        ; Encoded as:   "[25?]"

 ERND 25                ; Token 20:     "[106-110]"
 EQUB VE                ;
                        ; Encoded as:   "[25?]"

 EJMP 19                ; Token 21:     "{single cap}DA SIND {single cap}SIE
 ECHR 'D'               ;                ABER IN DER FALSCHEN {single cap}
 ECHR 'A'               ;                GALAXIS!ZU{single cap}DA DRAUEN GIBT ES
 ECHR ' '               ;                EINEN [91-95] VON EINEM {single cap}
 ECHR 'S'               ;                PIRATENZU"
 ETWO 'I', 'N'          ;
 ECHR 'D'               ; Encoded as:   "{19}DA S<240>D{26}SIE <216><244> <240>
 EJMP 26                ;                 D<244> F<228>SCH<246>{26}G<228>AXIS!
 ECHR 'S'               ;                [159]{19}DA D<248>U[3?]<246> GIBT <237>
 ECHR 'I'               ;                 E<240><246> [24?] V<223> E<240>EM{26}
 ECHR 'E'               ;                PIR<245><246>[159]"
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
                        ;
                        ; Encoded as:   ""

 EJMP 19                ; Token 1:      "{single cap}OUI"
 ETWO 'O', 'U'          ;
 ECHR 'I'               ; Encoded as:   "{19}<217>I"
 EQUB VE

 EJMP 19                ; Token 2:      "{single cap}NON"
 ECHR 'N'               ;
 ETWO 'O', 'N'          ; Encoded as:   "{19}N<223>"
 EQUB VE

 EQUB VE                ; Token 3:      ""
                        ;
                        ; Encoded as:   ""

 EJMP 19                ; Token 4:      "{single cap}FRANÇAIS"
 ECHR 'F'               ;
 ETWO 'R', 'A'          ; Encoded as:   "{19}F<248>N@AIS"
 ECHR 'N'
 ECHR '@'
 ECHR 'A'
 ECHR 'I'
 ECHR 'S'
 EQUB VE

 EQUB VE                ; Token 5:      ""
                        ;
                        ; Encoded as:   ""

 EQUB VE                ; Token 6:      ""
                        ;
                        ; Encoded as:   ""

 EQUB VE                ; Token 7:      ""
                        ;
                        ; Encoded as:   ""

 EJMP 19                ; Token 8:      "{single cap}NOUVEAU {single cap}NOM: "
 ECHR 'N'               ;
 ETWO 'O', 'U'          ; Encoded as:   "{19}N<217><250>AU{26}<227>M: "
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
                        ;
                        ; Encoded as:   ""

 EJMP 23                ; Token 10:     "{move to row 9, lower case}
 EJMP 14                ;                {justify}
 EJMP 13                ;                {lower case}  {single cap}COMMANDANT
 ECHR ' '               ;                {commander name}, JE {lower case}SUIS
 ETOK 213               ;                LE CAPITAINE {mission captain's name}
 EJMP 26                ;                DE LA {single cap}MARINE {single cap}
 ETOK 181               ;                SPATIALE DE SA {single cap}MAJESTÉ
 ETOK 190               ;                {single cap}JE VOUS PRIE DE M'ACCORDER
 ECHR ' '               ;                QUELQUES INSTANTS.{cr}
 ECHR 'P'               ;                {cr}
 ECHR 'R'               ;                 {single cap}NOUS AIMERIONS VOUS
 ECHR 'I'               ;                CONFIER UN PETIT TRAVAIL.{cr}
 ECHR 'E'               ;                {cr}
 ETOK 179               ;                 {single cap}CE NOUVEAU MODÈLE DE
 ECHR 'M'               ;                NAVIRE LE '{single cap}CONSTRICTOR' EST
 ECHR '`'               ;                DOTÉ D'UN GÉNÉRATEUR DE BOUCLIERS TOP
 ECHR 'A'               ;                SECRET.{cr}
 ECHR 'C'               ;                {cr}
 ECHR 'C'               ;                 {single cap}{single cap}
 ETWO 'O', 'R'          ;                MALHEUREUSEMENT IL A ÉTÉ VOLÉ.{cr}
 ECHR 'D'               ;                {cr}
 ETWO 'E', 'R'          ;                 {single cap}{display ship, wait for
 ECHR ' '               ;                key press}{single cap}IL A DISPARU DU
 ETWO 'Q', 'U'          ;                CHANTIER NAVAL À {single cap}XEER IL Y
 ECHR 'E'               ;                A CINQ MOIS. {single cap}ON L'A
 ECHR 'L'               ;                {mission 1 location hint}.{cr}
 ETWO 'Q', 'U'          ;                {cr}
 ETWO 'E', 'S'          ;                 {single cap}{single cap}VOTRE MISSION
 ECHR ' '               ;                EST DE RETROUVER CE NAVIRE AFIN DE LE
 ETWO 'I', 'N'          ;                DÉTRUIRE.{cr}
 ETWO 'S', 'T'          ;                {cr}
 ETWO 'A', 'N'          ;                 {single cap}{single cap}IL N'Y A QUE
 ECHR 'T'               ;                LES LASERS MILITAIRES QUI SONT CAPABLES
 ECHR 'S'               ;                DE TRANSPERCER LES BOUCLIERS. {single
 ETOK 204               ;                cap}DE PLUS, LE CONSTRICTOR EST DOTÉ
 ECHR 'N'               ;                D'UN {standard tokens, sentence case}
 ETWO 'O', 'U'          ;                [81-85]{extended tokens}.{cr}
 ECHR 'S'               ;                {left align}{tab 6}{single cap}BONNE
 ECHR ' '               ;                CHANCE {single cap}COMMANDANT.{cr}
 ECHR 'A'               ;                {left align}{cr}{tab 6}{all caps}
 ECHR 'I'               ;                  {single cap}FIN DU MESSAGE{display
 ECHR 'M'               ;                 ship, wait for key press}"
 ETWO 'E', 'R'          ;
 ECHR 'I'               ; Encoded as:   "{23}{14}{13} [213]{26}[181][190] PRIE
 ETWO 'O', 'N'          ;                [179]M'ACC<253>D<244> <254>EL<254><237>
 ECHR 'S'               ;                 <240><222><255>TS[204]N<217>S AIM<244>
 ECHR ' '               ;                I<223>S [190] C<223>FI<244> [186]P<221>
 ETOK 190               ;                <219> T<248>VA<220>[204][188]N<217>
 ECHR ' '               ;                <250>AU MOD=[178]DE[173][178]'{19}C
 ECHR 'C'               ;                <223><222>RICT<253>' [184] DOT< D'[186]
 ETWO 'O', 'N'          ;                G<N<R<245>EUR[179]B<217>CLI<244>S TOP
 ECHR 'F'               ;                 <218>CR<221>[204]{19}M<228>HEU<242>U
 ECHR 'I'               ;                <218>M<246>T <220>[129]<T< VOL<[204]
 ETWO 'E', 'R'          ;                {22}{19}<220>[129]<241>SP<238>U DU CH
 ECHR ' '               ;                <255><251><244> NAV<228> "{26}<230>
 ETOK 186               ;                <244> <220> Y[129]C<240>Q MOIS.{26}
 ECHR 'P'               ;                <223> L'A {28}[204]{19}VOT<242> MISSI
 ETWO 'E', 'T'          ;                <223> [184][179]R<221>R<217>V<244>
 ETWO 'I', 'T'          ;                 <233>[173]AF<240>[179][178]D<TRUI<242>
 ECHR ' '               ;                [204]{19}<220> N'Y[129][192][187]<249>
 ECHR 'T'               ;                <218>RS M<220><219>AIR<237> <254>I S
 ETWO 'R', 'A'          ;                <223>T CAP<216><229>S[179]T<248>NSP
 ECHR 'V'               ;                <244><233>R [187]B<217>CLI<244>S.{26}DE
 ECHR 'A'               ;                 [196], [178]C<223><222>RICT<253> [184]
 ETWO 'I', 'L'          ;                 DOT< D'[186]{6}[17?]{5}[177]{8}{19}B
 ETOK 204               ;                <223>NE CH<255>[188][154][212]{22}"
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

 EJMP 25                ; Token 11:     "{incoming message screen, wait 2s}
 EJMP 9                 ;                {clear screen}
 EJMP 23                ;                {move to row 9, lower case}{justify}
 EJMP 14                ;                {single cap}ATTENTION  {single cap}
 ECHR ' '               ;                COMMANDANT {commander name}, JE {lower
 EJMP 26                ;                case}SUIS LE CAPITAINE {mission
 ETWO 'A', 'T'          ;                captain's name} DE LA {single cap}
 ECHR 'T'               ;                MARINE {single cap}SPATIALE DE SA
 ETWO 'E', 'N'          ;                {single cap}MAJESTÉ. {single cap}NOUS
 ETWO 'T', 'I'          ;                AVONS DE NOUVEAU RECOURS À VOUS.{cr}
 ETWO 'O', 'N'          ;                {cr}
 ECHR ' '               ;                 {single cap}{single cap}VOUS RECEVREZ
 ETOK 213               ;                DES INSTRUCTIONS SI VOUS ALLEZ JUSQU'À
 ECHR '.'               ;                {single cap}CEERDI.{cr}
 EJMP 26                ;                {cr}
 ECHR 'N'               ;                 {single cap}VOUS SEREZ RÉCOMPENSÉ SI
 ETWO 'O', 'U'          ;                VOUS RÉUSSISSEZ.{cr}
 ECHR 'S'               ;                {left align}{cr}{tab 6}{all caps}
 ECHR ' '               ;                {single cap}FIN DU MESSAGE
 ETOK 172               ;                {wait for key press}"
 ECHR 'S'               ;
 ETOK 179               ; Encoded as:   "{25}{9}{23}{14} {26}<245>T<246><251>
 ECHR 'N'               ;                <223> [213].{26}N<217>S [172]S[179]N
 ETWO 'O', 'U'          ;                <217><250>AU <242>C<217>RS[183][190]
 ETWO 'V', 'E'          ;                [204]{19}[190] <242><233>V<242>Z [195]
 ECHR 'A'               ;                <240><222>RUC<251><223>S SI [190] <228>
 ECHR 'U'               ;                <229>Z J<236><254>'"{26}<233><244><241>
 ECHR ' '               ;                [204][190] <218><242>Z R<COMP<246>S< SI
 ETWO 'R', 'E'          ;                 [190] R<<236>SIS<218>Z[212]{24}"
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
                        ;
                        ; Encoded as:   ""

 EQUB VE                ; Token 13:     ""
                        ;
                        ; Encoded as:   ""

 EJMP 21                ; Token 14:     "{clear bottom of screen}{single cap}NOM
 EJMP 19                ;                {single cap}PLANÉTE? "
 ETWO 'N', 'O'          ;
 ECHR 'M'               ; Encoded as:   "{21}{19}<227>M{26}P<249>N<TE? "
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

 EJMP 25                ; Token 15:     "{incoming message screen, wait 2s}
 EJMP 9                 ;                {clear screen}
 EJMP 23                ;                {move to row 9, lower case}{justify}
 EJMP 14                ;                {lower case}  {single cap}FÉLICITATIONS
 EJMP 13                ;                {single cap}COMMANDANT!{cr}
 ECHR ' '               ;                {cr}
 EJMP 26                ;                 {single cap}VOUS SEREZ TOUJOURS LE
 ECHR 'F'               ;                BIENVENU À  LA {single cap}MARINE
 ECHR '<'               ;                {single cap}SPATIALE DE SA {single cap}
 ECHR 'L'               ;                MAJESTÉ.{cr}
 ECHR 'I'               ;                {cr}
 ECHR 'C'               ;                 {single cap}ET PEUT-TRE PLUS TÔT QUE
 ETWO 'I', 'T'          ;                PRÉVU...{cr}
 ETWO 'A', 'T'          ;                {left align}{cr}
 ECHR 'I'               ;                {tab 6}{all caps}  {single cap}FIN DU
 ETWO 'O', 'N'          ;                MESSAGE
 ECHR 'S'               ;                {wait for key press}"
 ECHR ' '               ;
 ETOK 154               ; Encoded as:   "{25}{9}{23}{14}{13} {26}F<LIC<219><245>
 ECHR '!'               ;                I<223>S [154]!{12}{12}{26}[190] <218>
 EJMP 12                ;                <242>Z T<217>J<217>RS [178]<234><246>
 EJMP 12                ;                <250><225>[183][211][204]<221> PEUT-
 EJMP 26                ;                [193]<242> [196] T#T [192]PR<VU..[212]
 ETOK 190               ;                {24}"
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
                        ;
                        ; Encoded as:   ""

 EQUB VE                ; Token 17:     ""
                        ;
                        ; Encoded as:   ""

 EQUB VE                ; Token 18:     ""
                        ;
                        ; Encoded as:   ""

 EQUB VE                ; Token 19:     ""
                        ;
                        ; Encoded as:   ""

 EQUB VE                ; Token 20:     ""
                        ;
                        ; Encoded as:   ""

 EQUB VE                ; Token 21:     ""
                        ;
                        ; Encoded as:   ""

 EQUB VE                ; Token 22:     ""
                        ;
                        ; Encoded as:   ""

 EQUB VE                ; Token 23:     ""
                        ;
                        ; Encoded as:   ""

 EQUB VE                ; Token 24:     ""
                        ;
                        ; Encoded as:   ""

 EQUB VE                ; Token 25:     ""
                        ;
                        ; Encoded as:   ""

 EQUB VE                ; Token 26:     ""
                        ;
                        ; Encoded as:   ""

 EQUB VE                ; Token 27:     ""
                        ;
                        ; Encoded as:   ""

 EQUB VE                ; Token 28:     ""
                        ;
                        ; Encoded as:   ""

 EQUB VE                ; Token 29:     ""
                        ;
                        ; Encoded as:   ""

 EQUB VE                ; Token 30:     ""
                        ;
                        ; Encoded as:   ""

 EQUB VE                ; Token 31:     ""
                        ;
                        ; Encoded as:   ""

 EQUB VE                ; Token 32:     ""
                        ;
                        ; Encoded as:   ""

 EQUB VE                ; Token 33:     ""
                        ;
                        ; Encoded as:   ""

 EQUB VE                ; Token 34:     ""
                        ;
                        ; Encoded as:   ""

 EQUB VE                ; Token 35:     ""
                        ;
                        ; Encoded as:   ""

 EQUB VE                ; Token 36:     ""
                        ;
                        ; Encoded as:   ""

 EQUB VE                ; Token 37:     ""
                        ;
                        ; Encoded as:   ""

 EQUB VE                ; Token 38:     ""
                        ;
                        ; Encoded as:   ""

 EQUB VE                ; Token 39:     ""
                        ;
                        ; Encoded as:   ""

 EQUB VE                ; Token 40:     ""
                        ;
                        ; Encoded as:   ""

 EQUB VE                ; Token 41:     ""
                        ;
                        ; Encoded as:   ""

 EQUB VE                ; Token 42:     ""
                        ;
                        ; Encoded as:   ""

 EQUB VE                ; Token 43:     ""
                        ;
                        ; Encoded as:   ""

 EQUB VE                ; Token 44:     ""
                        ;
                        ; Encoded as:   ""

 EQUB VE                ; Token 45:     ""
                        ;
                        ; Encoded as:   ""

 EQUB VE                ; Token 46:     ""
                        ;
                        ; Encoded as:   ""

 EQUB VE                ; Token 47:     ""
                        ;
                        ; Encoded as:   ""

 EQUB VE                ; Token 48:     ""
                        ;
                        ; Encoded as:   ""

 EQUB VE                ; Token 49:     ""
                        ;
                        ; Encoded as:   ""

 EQUB VE                ; Token 50:     ""
                        ;
                        ; Encoded as:   ""

 EQUB VE                ; Token 51:     ""
                        ;
                        ; Encoded as:   ""

 EQUB VE                ; Token 52:     ""
                        ;
                        ; Encoded as:   ""

 EQUB VE                ; Token 53:     ""
                        ;
                        ; Encoded as:   ""

 EQUB VE                ; Token 54:     ""
                        ;
                        ; Encoded as:   ""

 EQUB VE                ; Token 55:     ""
                        ;
                        ; Encoded as:   ""

 EQUB VE                ; Token 56:     ""
                        ;
                        ; Encoded as:   ""

 EQUB VE                ; Token 57:     ""
                        ;
                        ; Encoded as:   ""

 EQUB VE                ; Token 58:     ""
                        ;
                        ; Encoded as:   ""

 EQUB VE                ; Token 59:     ""
                        ;
                        ; Encoded as:   ""

 EQUB VE                ; Token 60:     ""
                        ;
                        ; Encoded as:   ""

 EQUB VE                ; Token 61:     ""
                        ;
                        ; Encoded as:   ""

 EQUB VE                ; Token 62:     ""
                        ;
                        ; Encoded as:   ""

 EQUB VE                ; Token 63:     ""
                        ;
                        ; Encoded as:   ""

 EQUB VE                ; Token 64:     ""
                        ;
                        ; Encoded as:   ""

 EQUB VE                ; Token 65:     ""
                        ;
                        ; Encoded as:   ""

 EQUB VE                ; Token 66:     ""
                        ;
                        ; Encoded as:   ""

 EQUB VE                ; Token 67:     ""
                        ;
                        ; Encoded as:   ""

 EQUB VE                ; Token 68:     ""
                        ;
                        ; Encoded as:   ""

 EQUB VE                ; Token 69:     ""
                        ;
                        ; Encoded as:   ""

 EQUB VE                ; Token 70:     ""
                        ;
                        ; Encoded as:   ""

 EQUB VE                ; Token 71:     ""
                        ;
                        ; Encoded as:   ""

 EQUB VE                ; Token 72:     ""
                        ;
                        ; Encoded as:   ""

 EQUB VE                ; Token 73:     ""
                        ;
                        ; Encoded as:   ""

 EQUB VE                ; Token 74:     ""
                        ;
                        ; Encoded as:   ""

 EQUB VE                ; Token 75:     ""
                        ;
                        ; Encoded as:   ""

 EQUB VE                ; Token 76:     ""
                        ;
                        ; Encoded as:   ""

 EQUB VE                ; Token 77:     ""
                        ;
                        ; Encoded as:   ""

 EQUB VE                ; Token 78:     ""
                        ;
                        ; Encoded as:   ""

 EQUB VE                ; Token 79:     ""
                        ;
                        ; Encoded as:   ""

 EQUB VE                ; Token 80:     ""
                        ;
                        ; Encoded as:   ""

 EQUB VE                ; Token 81:     ""
                        ;
                        ; Encoded as:   ""

 EQUB VE                ; Token 82:     ""
                        ;
                        ; Encoded as:   ""

 EQUB VE                ; Token 83:     ""
                        ;
                        ; Encoded as:   ""

 EQUB VE                ; Token 84:     ""
                        ;
                        ; Encoded as:   ""

 EJMP 2                 ; Token 85:     "{sentence case}{lower case}"
 ERND 31                ;
 EJMP 13                ; Encoded as:   "{2}[31?]{13}"
 EQUB VE

 EQUB VE                ; Token 86:     ""
                        ;
                        ; Encoded as:   ""

 EQUB VE                ; Token 87:     ""
                        ;
                        ; Encoded as:   ""

 EQUB VE                ; Token 88:     ""
                        ;
                        ; Encoded as:   ""

 EQUB VE                ; Token 89:     ""
                        ;
                        ; Encoded as:   ""

 EQUB VE                ; Token 90:     ""
                        ;
                        ; Encoded as:   ""

 ECHR 'C'               ; Token 91:     "CRAPULE"
 ETWO 'R', 'A'          ;
 ECHR 'P'               ; Encoded as:   "C<248>PU<229>"
 ECHR 'U'
 ETWO 'L', 'E'
 EQUB VE

 ECHR 'V'               ; Token 92:     "VAURIEN"
 ECHR 'A'               ;
 ECHR 'U'               ; Encoded as:   "VAURI<246>"
 ECHR 'R'
 ECHR 'I'
 ETWO 'E', 'N'
 EQUB VE

 ETWO 'E', 'S'          ; Token 93:     "ESCROC"
 ECHR 'C'               ;
 ECHR 'R'               ; Encoded as:   "<237>CROC"
 ECHR 'O'
 ECHR 'C'
 EQUB VE

 ECHR 'G'               ; Token 94:     "GREDIN"
 ETWO 'R', 'E'          ;
 ECHR 'D'               ; Encoded as:   "G<242>D<240>"
 ETWO 'I', 'N'
 EQUB VE

 ECHR 'B'               ; Token 95:     "BRIGAND"
 ECHR 'R'               ;
 ECHR 'I'               ; Encoded as:   "BRIG<255>D"
 ECHR 'G'
 ETWO 'A', 'N'
 ECHR 'D'
 EQUB VE

 EQUB VE                ; Token 96:     ""
                        ;
                        ; Encoded as:   ""

 EQUB VE                ; Token 97:     ""
                        ;
                        ; Encoded as:   ""

 EQUB VE                ; Token 98:     ""
                        ;
                        ; Encoded as:   ""

 EQUB VE                ; Token 99:     ""
                        ;
                        ; Encoded as:   ""

 EQUB VE                ; Token 100:    ""
                        ;
                        ; Encoded as:   ""

 EQUB VE                ; Token 101:    ""
                        ;
                        ; Encoded as:   ""

 EQUB VE                ; Token 102:    ""
                        ;
                        ; Encoded as:   ""

 EQUB VE                ; Token 103:    ""
                        ;
                        ; Encoded as:   ""

 EQUB VE                ; Token 104:    ""
                        ;
                        ; Encoded as:   ""

 EQUB VE                ; Token 105:    ""
                        ;
                        ; Encoded as:   ""

 EJMP 19                ; Token 106:    "{single cap}UN NAVIRE REDOUTABLE SERAIT
 ECHR 'U'               ;                APPARU À {single cap}ERRIUS "
 ECHR 'N'               ;
 ETOK 173               ; Encoded as:   "{19}UN[173]<242>D<217>T<216>[178]<218>
 ETWO 'R', 'E'          ;                <248><219> APP<238>U "[209] "
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

 EJMP 19                ; Token 107:    "{single cap}OUAIS, UN NAVIRE AURAIT
 ETWO 'O', 'U'          ;                QUITTÉ {single cap}ERRIUS"
 ECHR 'A'               ;
 ECHR 'I'               ; Encoded as:   "{19}<217>AIS, UN[173]AU<248><219> <254>
 ECHR 'S'               ;                <219>T<[209]"
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

 EJMP 19                ; Token 108:    "{single cap}ALLEZ À {single cap}ERRIUS"
 ETWO 'A', 'L'          ;
 ETWO 'L', 'E'          ; Encoded as:   "{19}<228><229>Z "[209]"
 ECHR 'Z'
 ECHR ' '
 ECHR '"'
 ETOK 209
 EQUB VE

 EJMP 19                ; Token 109:    "{single cap}ON A VU UN AUTRE NAVIRE À
 ETWO 'O', 'N'          ;                {single cap}ERRIUS"
 ETOK 129               ;
 ECHR 'V'               ; Encoded as:   "{19}<223>[129]VU [186]AUT<242>[173]"
 ECHR 'U'               ;                [209]"
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

 EJMP 19                ; Token 110:    "{single cap}ESSAYEZ {single cap}ERRIUS"
 ETWO 'E', 'S'          ;
 ECHR 'S'               ; Encoded as:   "{19}<237>SAYEZ[209]"
 ECHR 'A'
 ECHR 'Y'
 ECHR 'E'
 ECHR 'Z'
 ETOK 209
 EQUB VE

 EQUB VE                ; Token 111:    ""
                        ;
                        ; Encoded as:   ""

 EQUB VE                ; Token 112:    ""
                        ;
                        ; Encoded as:   ""

 EQUB VE                ; Token 113:    ""
                        ;
                        ; Encoded as:   ""

 EQUB VE                ; Token 114:    ""
                        ;
                        ; Encoded as:   ""

 EQUB VE                ; Token 115:    ""
                        ;
                        ; Encoded as:   ""

 EQUB VE                ; Token 116:    ""
                        ;
                        ; Encoded as:   ""

 EQUB VE                ; Token 117:    ""
                        ;
                        ; Encoded as:   ""

 EQUB VE                ; Token 118:    ""
                        ;
                        ; Encoded as:   ""

 EQUB VE                ; Token 119:    ""
                        ;
                        ; Encoded as:   ""

 EQUB VE                ; Token 120:    ""
                        ;
                        ; Encoded as:   ""

 EQUB VE                ; Token 121:    ""
                        ;
                        ; Encoded as:   ""

 EQUB VE                ; Token 122:    ""
                        ;
                        ; Encoded as:   ""

 EQUB VE                ; Token 123:    ""
                        ;
                        ; Encoded as:   ""

 EQUB VE                ; Token 124:    ""
                        ;
                        ; Encoded as:   ""

 EQUB VE                ; Token 125:    ""
                        ;
                        ; Encoded as:   ""

 EQUB VE                ; Token 126:    ""
                        ;
                        ; Encoded as:   ""

 EQUB VE                ; Token 127:    ""
                        ;
                        ; Encoded as:   ""

 EQUB VE                ; Token 128:    ""
                        ;
                        ; Encoded as:   ""

 ECHR ' '               ; Token 129:    " A "
 ECHR 'A'               ;
 ECHR ' '               ; Encoded as:   " A "
 EQUB VE

 EQUB VE                ; Token 130:    ""
                        ;
                        ; Encoded as:   ""

 EQUB VE                ; Token 131:    ""
                        ;
                        ; Encoded as:   ""

 EQUB VE                ; Token 132:    ""
                        ;
                        ; Encoded as:   ""

 EQUB VE                ; Token 133:    ""
                        ;
                        ; Encoded as:   ""

 EQUB VE                ; Token 134:    ""
                        ;
                        ; Encoded as:   ""

 EQUB VE                ; Token 135:    ""
                        ;
                        ; Encoded as:   ""

 EQUB VE                ; Token 136:    ""
                        ;
                        ; Encoded as:   ""

 EQUB VE                ; Token 137:    ""
                        ;
                        ; Encoded as:   ""

 EQUB VE                ; Token 138:    ""
                        ;
                        ; Encoded as:   ""

 EQUB VE                ; Token 139:    ""
                        ;
                        ; Encoded as:   ""

 EQUB VE                ; Token 140:    ""
                        ;
                        ; Encoded as:   ""

 EQUB VE                ; Token 141:    ""
                        ;
                        ; Encoded as:   ""

 EQUB VE                ; Token 142:    ""
                        ;
                        ; Encoded as:   ""

 EQUB VE                ; Token 143:    ""
                        ;
                        ; Encoded as:   ""

 EQUB VE                ; Token 144:    ""
                        ;
                        ; Encoded as:   ""

 ECHR 'P'               ; Token 145:    "PLANÈTE"
 ETWO 'L', 'A'          ;
 ECHR 'N'               ; Encoded as:   "P<249>N=TE"
 ECHR '='
 ECHR 'T'
 ECHR 'E'
 EQUB VE

 ECHR 'M'               ; Token 146:    "MONDE"
 ETWO 'O', 'N'          ;
 ECHR 'D'               ; Encoded as:   "M<223>DE"
 ECHR 'E'
 EQUB VE

 ECHR 'E'               ; Token 147:    "EC "
 ECHR 'C'               ;
 ECHR ' '               ; Encoded as:   "EC "
 EQUB VE

 ETWO 'C', 'E'          ; Token 148:    "CECI "
 ECHR 'C'               ;
 ECHR 'I'               ; Encoded as:   "<233>CI "
 ECHR ' '
 EQUB VE

 EQUB VE                ; Token 149:    ""
                        ;
                        ; Encoded as:   ""

 EJMP 9                 ; Token 150:    "{clear screen}
 EJMP 11                ;                {draw box around title}
 EJMP 1                 ;                {all caps}{tab 6}"
 EJMP 8                 ;
 EQUB VE                ; Encoded as:   "{9}{11}{1}{8}"

 EQUB VE                ; Token 151:    ""
                        ;
                        ; Encoded as:   ""

 EQUB VE                ; Token 152:    ""
                        ;
                        ; Encoded as:   ""

 ECHR 'I'               ; Token 153:    "IAN"
 ETWO 'A', 'N'          ;
 EQUB VE                ; Encoded as:   "I<255>"

 EJMP 19                ; Token 154:    "{single cap}COMMANDANT"
 ECHR 'C'               ;
 ECHR 'O'               ; Encoded as:   "{19}COM<239>ND<255>T"
 ECHR 'M'
 ETWO 'M', 'A'
 ECHR 'N'
 ECHR 'D'
 ETWO 'A', 'N'
 ECHR 'T'
 EQUB VE

 EQUB VE                ; Token 155:    ""
                        ;
                        ; Encoded as:   ""

 EQUB VE                ; Token 156:    ""
                        ;
                        ; Encoded as:   ""

 EQUB VE                ; Token 157:    ""
                        ;
                        ; Encoded as:   ""

 EQUB VE                ; Token 158:    ""
                        ;
                        ; Encoded as:   ""

 EQUB VE                ; Token 159:    ""
                        ;
                        ; Encoded as:   ""

 EQUB VE                ; Token 160:    ""
                        ;
                        ; Encoded as:   ""

 EQUB VE                ; Token 161:    ""
                        ;
                        ; Encoded as:   ""

 EQUB VE                ; Token 162:    ""
                        ;
                        ; Encoded as:   ""

 EQUB VE                ; Token 163:    ""
                        ;
                        ; Encoded as:   ""

 EQUB VE                ; Token 164:    ""
                        ;
                        ; Encoded as:   ""

 EQUB VE                ; Token 165:    ""
                        ;
                        ; Encoded as:   ""

 EQUB VE                ; Token 166:    ""
                        ;
                        ; Encoded as:   ""

 EQUB VE                ; Token 167:    ""
                        ;
                        ; Encoded as:   ""

 EQUB VE                ; Token 168:    ""
                        ;
                        ; Encoded as:   ""

 EQUB VE                ; Token 169:    ""
                        ;
                        ; Encoded as:   ""

 EQUB VE                ; Token 170:    ""
                        ;
                        ; Encoded as:   ""

 ECHR 'S'               ; Token 171:    "SUIS "
 ECHR 'U'               ;
 ECHR 'I'               ; Encoded as:   "SUIS "
 ECHR 'S'
 ECHR ' '
 EQUB VE

 ECHR 'A'               ; Token 172:    "AVON"
 ECHR 'V'               ;
 ETWO 'O', 'N'          ; Encoded as:   "AV<223>"
 EQUB VE

 ECHR ' '               ; Token 173:    " NAVIRE "
 ECHR 'N'               ;
 ECHR 'A'               ; Encoded as:   " NAVI<242> "
 ECHR 'V'
 ECHR 'I'
 ETWO 'R', 'E'
 ECHR ' '
 EQUB VE

 ETWO 'A', 'R'          ; Token 174:    "ARINE"
 ETWO 'I', 'N'          ;
 ECHR 'E'               ; Encoded as:   "<238><240>E"
 EQUB VE

 ECHR 'P'               ; Token 175:    "POUR"
 ETWO 'O', 'U'          ;
 ECHR 'R'               ; Encoded as:   "P<217>R"
 EQUB VE

 EJMP 13                ; Token 176:    "{lower case}{justify}{single cap}"
 EJMP 14                ;
 EJMP 19                ; Encoded as:   "{13}{14}{19}"
 EQUB VE

 ECHR '.'               ; Token 177:    ".{cr}
 EJMP 12                ;                {left align}"
 EJMP 15                ;
 EQUB VE                ; Encoded as:   ".{12}{15}"

 ETWO 'L', 'E'          ; Token 178:    "LE "
 ECHR ' '               ;
 EQUB VE                ; Encoded as:   "<229> "

 ECHR ' '               ; Token 179:    " DE "
 ECHR 'D'               ;
 ECHR 'E'               ; Encoded as:   " DE 
 ECHR ' '
 EQUB VE

 ECHR ' '               ; Token 180:    " ET "
 ETWO 'E', 'T'          ;
 ECHR ' '               ; Encoded as:   " <221> "
 EQUB VE

 ECHR 'J'               ; Token 181:    "JE "
 ECHR 'E'               ;
 ECHR ' '               ; Encoded as:   "JE "
 EQUB VE

 ETWO 'L', 'A'          ; Token 182:    "LA "
 ECHR ' '               ;
 EQUB VE                ; Encoded as:   "<249> "

 ECHR ' '               ; Token 183:    " À "
 ECHR '"'               ;
 ECHR ' '               ; Encoded as:   " " "
 EQUB VE

 ECHR 'E'               ; Token 184:    "EST"
 ETWO 'S', 'T'          ;
 EQUB VE                ; Encoded as:   "E<222>"

 ETWO 'I', 'L'          ; Token 185:    "IL"
 EQUB VE                ;
                        ; Encoded as:   "<220>"

 ECHR 'U'               ; Token 186:    "UN "
 ECHR 'N'               ;
 ECHR ' '               ; Encoded as:   "UN "
 EQUB VE

 ETWO 'L', 'E'          ; Token 187:    "LES "
 ECHR 'S'               ;
 ECHR ' '               ; Encoded as:   "<229>S "
 EQUB VE

 ETWO 'C', 'E'          ; Token 188:    "CE "
 ECHR ' '               ;
 EQUB VE                ; Encoded as:   "<233> "

 ECHR 'D'               ; Token 189:    "DE LA "
 ECHR 'E'               ;
 ECHR ' '               ; Encoded as:   "DE [182]"
 ETOK 182
 EQUB VE

 ECHR 'V'               ; Token 190:    "VOUS"
 ETWO 'O', 'U'          ;
 ECHR 'S'               ; Encoded as:   "V<217>S"
 EQUB VE

 EJMP 26                ; Token 191:    " {single cap}BONJOUR "
 ECHR 'B'               ;
 ETWO 'O', 'N'          ; Encoded as:   "{26}B<223>J<217>R "
 ECHR 'J'
 ETWO 'O', 'U'
 ECHR 'R'
 ECHR ' '
 EQUB VE

 ETWO 'Q', 'U'          ; Token 192:    "QUE "
 ECHR 'E'               ;
 ECHR ' '               ; Encoded as:   "<254>E "
 EQUB VE

 ERND 4                 ; Token 193:    "T"
 ECHR 'T'               ;
 EQUB VE                ; Encoded as:   "[4?]T"

 EQUB VE                ; Token 194:    ""
                        ;
                        ; Encoded as:   ""

 ECHR 'D'               ; Token 195:    "DES "
 ETWO 'E', 'S'          ;
 ECHR ' '               ; Encoded as:   "D<237> "
 EQUB VE

 ECHR 'P'               ; Token 196:    "PLUS"
 ECHR 'L'               ;
 ETWO 'U', 'S'          ; Encoded as:   "PL<236>"
 EQUB VE

 EQUB VE                ; Token 197:    ""
                        ;
                        ; Encoded as:   ""

 EJMP 26                ; Token 198:    " {single cap}SQUEAKY"
 ECHR 'S'               ;
 ETWO 'Q', 'U'          ; Encoded as:   "{26}S<254>EAKY"
 ECHR 'E'
 ECHR 'A'
 ECHR 'K'
 ECHR 'Y'
 EQUB VE

 EJMP 25                ; Token 199:    "{incoming message screen, wait 2s}
 EJMP 9                 ;                {clear screen}
 EJMP 29                ;                {move to row 7, lower case}{justify}
 EJMP 14                ;                {lower case}  {single cap}BONJOUR
 EJMP 13                ;                {single cap}COMMANDANT {commander
 ECHR ' '               ;                name}, JE VOUDRAIS ME PRÉSENTER.
 ETOK 191               ;                {single cap}JE SUIS LE {single cap}
 ETOK 154               ;                PRINCE DE {single cap}THRUN ET JE SUIS
 ECHR ' '               ;                OBLIGÉ DE ME SÉPARER DE LA PLUPART DE
 EJMP 4                 ;                MES TRÉSORS.{cr}
 ECHR ','               ;                {cr}
 ECHR ' '               ;                 {single cap}{single cap}POUR LA JOLIE
 ETOK 181               ;                SOMME DE 5000{single cap}C{single cap}R
 ECHR 'V'               ;                JE VOUS OFFRE L'OBJET LE PLUS RARE DE
 ETWO 'O', 'U'          ;                TOUT L'UNIVERS.{cr}
 ECHR 'D'               ;                {cr}
 ETWO 'R', 'A'          ;                 {single cap}{single cap}VOULEZ-VOUS LE
 ECHR 'I'               ;                PRENDRE?{cr}
 ECHR 'S'               ;                {left align}{all caps}{tab 6}"
 ECHR ' '               ;
 ECHR 'M'               ; Encoded as:   "{25}{9}{29}{14}{13} [191][154] {4},
 ECHR 'E'               ;                 [181]V<217>D<248>IS ME PR<<218>NT<244>
 ECHR ' '               ;                .{26}[181][171]<229>{26}PR<240>[188]DE
 ECHR 'P'               ;                {26}<226>RUN[180][181][171]OBLIG<[179]M
 ECHR 'R'               ;                E S<P<238><244>[179][182]PLUP<238>T
 ECHR '<'               ;                [179]M<237> TR<<235>RS[204]{19}[175]
 ETWO 'S', 'E'          ;                 [182]JOLIE <235>MME[179]5000{19}C{19}R
 ECHR 'N'               ;                 [181][190] OFF<242> L'OBJ<221> [178]
 ECHR 'T'               ;                [196] R<238>E[179]T<217>T L'UNIV<244>S
 ETWO 'E', 'R'          ;                [204]{19}V<217><229>Z-[190] [178]P<242>
 ECHR '.'               ;                ND<242>?{12}{15}{1}{8}"
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

 EJMP 26                ; Token 200:    " {single cap}NOM? "
 ETWO 'N', 'O'          ;
 ECHR 'M'               ; Encoded as:   "{26}<227>M? "
 ECHR '?'
 ECHR ' '
 EQUB VE

 EQUB VE                ; Token 201:    ""
                        ;
                        ; Encoded as:   ""

 EQUB VE                ; Token 202:    ""
                        ;
                        ; Encoded as:   ""

 ECHR 'P'               ; Token 203:    "PERDU DE VUE À {single cap}"
 ETWO 'E', 'R'          ;
 ECHR 'D'               ; Encoded as:   "P<244>DU[179]VUE[183]{19}"
 ECHR 'U'
 ETOK 179
 ECHR 'V'
 ECHR 'U'
 ECHR 'E'
 ETOK 183
 EJMP 19
 EQUB VE

 ECHR '.'               ; Token 204:    ".{cr}
 EJMP 12                ;                {cr}
 EJMP 12                ;                 {single cap}"
 ECHR ' '               ;
 EJMP 19                ; Encoded as:   ".{12}{12} {19}"
 EQUB VE

 ECHR '"'               ; Token 205:    "À QUAI"
 ECHR ' '               ;
 ETWO 'Q', 'U'          ; Encoded as:   "" <254>AI
 ECHR 'A'
 ECHR 'I'
 EQUB VE

 EQUB VE                ; Token 206:    ""
                        ;
                        ; Encoded as:   ""

 EQUB VE                ; Token 207:    ""
                        ;
                        ; Encoded as:   ""

 EQUB VE                ; Token 208:    ""
                        ;
                        ; Encoded as:   ""

 EJMP 26                ; Token 209:    " {single cap}ERRIUS"
 ETWO 'E', 'R'          ;
 ECHR 'R'               ; Encoded as:   "{26}<244>RI<236>"
 ECHR 'I'
 ETWO 'U', 'S'
 EQUB VE

 EQUB VE                ; Token 210:    ""
                        ;
                        ; Encoded as:   ""

 ECHR ' '               ; Token 211:    " LA {single cap}MARINE {single cap}
 ETWO 'L', 'A'          ;                SPATIALE DE SA {single cap}MAJESTÉ"
 EJMP 26                ;
 ECHR 'M'               ; Encoded as:   " <249>{26}M[174]{26}SP<245>I<228>E[179]
 ETOK 174               ;                SA{26}<239>J[184]<"
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

 ETOK 177               ; Token 212:    ".{cr}
 EJMP 12                ;                {left align}{cr}
 EJMP 8                 ;                {tab 6}{all caps}  {single cap}FIN DU
 EJMP 1                 ;                MESSAGE"
 ECHR ' '               ;
 EJMP 26                ; Encoded as:   "[177]{12}{8}{1} {26}F<240> DU M<237>SA
 ECHR 'F'               ;                <231>"
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

 ECHR ' '               ; Token 213:    " {single cap}COMMANDANT {commander
 ETOK 154               ;                name}, JE {lower case}SUIS LE CAPITAINE
 ECHR ' '               ;                {mission captain's name} DE LA {single
 EJMP 4                 ;                cap}MARINE {single cap}SPATIALE DE SA
 ECHR ','               ;                {single cap}MAJESTÉ"
 ECHR ' '               ;
 ETOK 181               ; Encoded as:   " [154] {4}, [181]{13}[171][178]CAP<219>
 EJMP 13                ;                A<240>E {27} DE[211]"
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
                        ;
                        ; Encoded as:   ""

 EJMP 15                ; Token 215:    "{left align} PLANÈTE INCONNUE "
 ECHR ' '               ;
 ETOK 145               ; Encoded as:   "{15} [145] <240>C<223><225>E "
 ECHR ' '
 ETWO 'I', 'N'
 ECHR 'C'
 ETWO 'O', 'N'
 ETWO 'N', 'U'
 ECHR 'E'
 ECHR ' '
 EQUB VE

 EJMP 9                 ; Token 216:    "{clear screen}
 EJMP 8                 ;                {tab 6}{move to row 9,lower case}{all
 EJMP 23                ;                caps}  {single cap}MESSAGES REÇUS"
 EJMP 1                 ;
 ECHR ' '               ; Encoded as:   "{9}{8}{23}{1} {26}M<237>SA<231>S <242>@
 EJMP 26                ;                <236>"
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

 ECHR 'D'               ; Token 217:    "DE {single cap}REMIGNY"
 ECHR 'E'               ;
 EJMP 26                ; Encoded as:   "DE{26}<242>MIGNY"
 ETWO 'R', 'E'
 ECHR 'M'
 ECHR 'I'
 ECHR 'G'
 ECHR 'N'
 ECHR 'Y'
 EQUB VE

 ECHR 'D'               ; Token 218:    "DE {single cap}SEVIGNY"
 ECHR 'E'               ;
 EJMP 26                ; Encoded as:   "DE{26}<218>VIGNY"
 ETWO 'S', 'E'
 ECHR 'V'
 ECHR 'I'
 ECHR 'G'
 ECHR 'N'
 ECHR 'Y'
 EQUB VE

 ECHR 'D'               ; Token 219:    "DE {single cap}ROMANCHE"
 ECHR 'E'               ;
 EJMP 26                ; Encoded as:   "DE{26}RO<239>NCHE"
 ECHR 'R'
 ECHR 'O'
 ETWO 'M', 'A'
 ECHR 'N'
 ECHR 'C'
 ECHR 'H'
 ECHR 'E'
 EQUB VE

 ETOK 203               ; Token 220:    "PERDU DE VUE À {single cap}{single cap}
 EJMP 19                ;                REESDICE"
 ETWO 'R', 'E'          ;
 ETWO 'E', 'S'          ; Encoded as:   "PERDU DE VUE À {single cap}{single cap}
 ETWO 'D', 'I'          ;                REESDICE"
 ETWO 'C', 'E'
 EQUB VE

 ECHR ' '               ; Token 221:    " ON PENSE QUE SERAIT ALLÉ DANS CETTE
 ETWO 'O', 'N'          ;                GALAXIE"
 ECHR ' '               ;
 ECHR 'P'               ; Encoded as:   " <223> P<246><218> [192]<218><248><219>
 ETWO 'E', 'N'          ;                 <228>L< D<255>S C<221>TE G<228>AXIE"
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

 EJMP 25                ; Token 222:    "{incoming message screen, wait 2s}
 EJMP 9                 ;                {clear screen}
 EJMP 29                ;                {move to row 7, lower case}{justify}
 EJMP 14                ;                {lower case} {single cap}BONJOUR
 EJMP 13                ;                {single cap}COMMANDANT {commander
 ECHR ' '               ;                name}.{cr}
 ETOK 191               ;                {cr}
 ETOK 154               ;                 {single cap}JE SUIS {single cap}AGENT
 ECHR ' '               ;                {single cap}BLAKE DES SERVICES SECRETS
 EJMP 4                 ;                DE LA {single cap}MARINE {single cap}
 ETOK 204               ;                SPATIALE.{cr}
 ETOK 181               ;                {cr}
 ECHR 'S'               ;                 {single cap}{single cap}LA {single
 ECHR 'U'               ;                cap}MARINE A GARDÉ LES {single cap}
 ECHR 'I'               ;                THARGOIDS À DISTANCE PENDANT PLUSIEURS
 ECHR 'S'               ;                ANNÉES. {single cap}MAIS LA SITUATION A
 EJMP 26                ;                CHANGÉ.{cr}
 ECHR 'A'               ;                {cr}
 ETWO 'G', 'E'          ;                 {single cap}{single cap}NOS GARS SONT
 ECHR 'N'               ;                PRTS À ALLER JUSQU'À LA BASE DE CES
 ECHR 'T'               ;                ASSASSINS.{cr}
 EJMP 26                ;                {cr}
 ECHR 'B'               ;                 {single cap}{wait for key press}
 ETWO 'L', 'A'          ;                {clear screen}
 ECHR 'K'               ;                {move to row 7, lower case}{single cap}
 ECHR 'E'               ;                NOUS {lower case}AVONS OBTENU LES PLANS
 ECHR ' '               ;                DE DÉFENSE POUR LEURS MONDES ORIGINELS.
 ETOK 195               ;                {cr}
 ETWO 'S', 'E'          ;                {cr}
 ECHR 'R'               ;                 {single cap}{single cap}LES INSECTES
 ECHR 'V'               ;                IGNORENT QUE NOUS AVONS CES PLANS.{cr}
 ECHR 'I'               ;                {cr}
 ETWO 'C', 'E'          ;                 {single cap}{single cap}SI JE LES
 ECHR 'S'               ;                ENVOIE À NOTRE BASE DE {single cap}
 ECHR ' '               ;                BIRERA, ILS INTERCEPTERONT LE MESSAGE.
 ETWO 'S', 'E'          ;                {single cap}IL ME FAUT UN NAVIRE
 ECHR 'C'               ;                ÉMISSAIRE.{cr}
 ECHR 'R'               ;                {cr}
 ETWO 'E', 'T'          ;                 {single cap}{single cap}VOUS TES
 ECHR 'S'               ;                CHOISI.{cr}
 ETOK 179               ;                {cr}
 ETWO 'L', 'A'          ;                 {single cap}{wait for key press}
 EJMP 26                ;                {clear screen}
 ECHR 'M'               ;                {move to row 9, lower case}{single cap}
 ETOK 174               ;                LES PLANS SONT CODÉS POUR CETTE
 EJMP 26                ;                TRANSMISSION.{cr}
 ECHR 'S'               ;                {cr}
 ECHR 'P'               ;                 {single cap}{tab 6}VOUS SEREZ PAYÉ.
 ETWO 'A', 'T'          ;                {cr}
 ECHR 'I'               ;                {cr}
 ETWO 'A', 'L'          ;                 {single cap} {single cap}BONNE CHANCE
 ECHR 'E'               ;                {single cap}COMMANDANT.{cr}
 ETOK 204               ;                {left align}{cr}
 EJMP 19                ;                {tab 6}{all caps}  {single cap}FIN DU
 ETWO 'L', 'A'          ;                 MESSAGE{wait for key press}"
 EJMP 26                ;
 ECHR 'M'               ; Encoded as:   "{25}{9}{29}{14}{13} [191][154] {4}[204]
 ETOK 174               ;                [181]SUIS{26}A<231>NT{26}B<249>KE [195]
 ETOK 129               ;                <218>RVI<233>S <218>CR<221>S[179]<249>
 ECHR 'G'               ;                {26}M[174]{26}SP<245>I<228>E[204]{19}
 ETWO 'A', 'R'          ;                <249>{26}M[174][129]G<238>D< <229>S{26}
 ECHR 'D'               ;                <226><238>GOIDS[183]<241><222><255>
 ECHR '<'               ;                [188]P<246>D<255>T [196]IEURS <255>N<
 ECHR ' '               ;                <237>.{26}<239>IS [182]S<219>U<245>I
 ETWO 'L', 'E'          ;                <223>[129]CH<255>G<[204]{19}<227>S G
 ECHR 'S'               ;                <238>S S<223>T PR[193]S[183]<228><229>R
 EJMP 26                ;                 J<236><254>'" [182]BA<218>[179]<233>S
 ETWO 'T', 'H'          ;                 ASSASS<240>S[204]{24}{9}{29}{19}N<217>
 ETWO 'A', 'R'          ;                S {13}[172]S OBTE<225> [187]P<249>NS
 ECHR 'G'               ;                [179]D<F<246><218> [175] <229>URS M
 ECHR 'O'               ;                <223>[195]<253>IG<240>ELS[204]{19}[187]
 ECHR 'I'               ;                <240><218>CT<237> IG<227><242>NT [192]N
 ECHR 'D'               ;                <217>S [172]S <233>S P<249>NS[204]{19}S
 ECHR 'S'               ;                I [181][187]<246>VOIE[183]<227>T<242> B
 ETOK 183               ;                A<218> DE{26}<234><242><248>, <220>S
 ETWO 'D', 'I'          ;                 <240>T<244><233>PT<244><223>T [178]M
 ETWO 'S', 'T'          ;                <237>SA<231>.{26}<220> ME FAUT UN[173]<
 ETWO 'A', 'N'          ;                MISSAI<242>[204]{19}[190] [193]<237> CH
 ETOK 188               ;                OISI[204]{24}{9}{23}{19}[187]P<249>NS S
 ECHR 'P'               ;                <223>T COD<S [175] C<221>TE T<248>NSMIS
 ETWO 'E', 'N'          ;                SI<223>[204]{8}[190] <218><242>Z PAY<
 ECHR 'D'               ;                [204]{26}B<223>NE CH<255>[188][154]
 ETWO 'A', 'N'          ;                [212]{24}"
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

 EJMP 25                ; Token 223:    "{incoming message screen, wait 2s}
 EJMP 9                 ;                {clear screen}
 EJMP 29                ;                {move to row 7, lower case}{justify}
 EJMP 8                 ;                {lower case} {single cap}BRAVO {single
 EJMP 14                ;                cap}COMMANDANT.{cr}
 EJMP 13                ;                {cr}
 EJMP 26                ;                 {single cap}NOUS N'OUBLIERONS PAS CE
 ECHR 'B'               ;                QUE VOUS AVEZ FAIT POUR NOUS.{cr}
 ETWO 'R', 'A'          ;                {cr}
 ECHR 'V'               ;                 {single cap}{single cap}NOUS IGNORIONS
 ECHR 'O'               ;                QUE LES {single cap}THARGOIDS AVAIENT
 ECHR ' '               ;                CONSCIENCE DE VOTRE EXISTENCE.{cr}
 ETOK 154               ;                {cr}
 ETOK 204               ;                 {single cap}ACCEPTEZ UNE UNITÉ
 ECHR 'N'               ;                D'ÉNERGIE MARINE COMME PAIEMENT.{cr}
 ETWO 'O', 'U'          ;                {left align}{cr}{tab 6}{all caps}
 ECHR 'S'               ;                  {single cap}FIN DU MESSAGE
 ECHR ' '               ;                {wait for key press}"
 ECHR 'N'               ;
 ECHR '`'               ; Encoded as:   "{25}{9}{29}{8}{14}{13}{26}B<248>VO
 ETWO 'O', 'U'          ;                 [154][204]N<217>S N'<217>BLI<244>
 ECHR 'B'               ;                <223>S PAS [188][192][190] A<250>Z FA
 ECHR 'L'               ;                <219> [175] N<217>S[204]{19}N<217>S IG
 ECHR 'I'               ;                <227>RI<223>S [192]<229>S{26}<226><238>
 ETWO 'E', 'R'          ;                GOIDS AVAI<246>T C<223>SCI<246><233>
 ETWO 'O', 'N'          ;                [179]VOT<242> EXI<222><246><233>[204]AC
 ECHR 'S'               ;                <233>PTEZ UNE UN<219>< D'<N<244>GIE M
 ECHR ' '               ;                [174] COMME PAIEM<246>T[212]{24}
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
                        ;
                        ; Encoded as:   ""

 EQUB VE                ; Token 225:    ""
                        ;
                        ; Encoded as:   ""

 EQUB VE                ; Token 226:    ""
                        ;
                        ; Encoded as:   ""

 EQUB VE                ; Token 227:    ""
                        ;
                        ; Encoded as:   ""

 EQUB VE                ; Token 228:    ""
                        ;
                        ; Encoded as:   ""

 EQUB VE                ; Token 229:    ""
                        ;
                        ; Encoded as:   ""

 EQUB VE                ; Token 230:    ""
                        ;
                        ; Encoded as:   ""

 EQUB VE                ; Token 231:    ""
                        ;
                        ; Encoded as:   ""

 EQUB VE                ; Token 232:    ""
                        ;
                        ; Encoded as:   ""

 EQUB VE                ; Token 233:    ""
                        ;
                        ; Encoded as:   ""

 EQUB VE                ; Token 234:    ""
                        ;
                        ; Encoded as:   ""

 EQUB VE                ; Token 235:    ""
                        ;
                        ; Encoded as:   ""

 EQUB VE                ; Token 236:    ""
                        ;
                        ; Encoded as:   ""

 EQUB VE                ; Token 237:    ""
                        ;
                        ; Encoded as:   ""

 EQUB VE                ; Token 238:    ""
                        ;
                        ; Encoded as:   ""

 EQUB VE                ; Token 239:    ""
                        ;
                        ; Encoded as:   ""

 EQUB VE                ; Token 240:    ""
                        ;
                        ; Encoded as:   ""

 EQUB VE                ; Token 241:    ""
                        ;
                        ; Encoded as:   ""

 EQUB VE                ; Token 242:    ""
                        ;
                        ; Encoded as:   ""

 EQUB VE                ; Token 243:    ""
                        ;
                        ; Encoded as:   ""

 EQUB VE                ; Token 244:    ""
                        ;
                        ; Encoded as:   ""

 EQUB VE                ; Token 245:    ""
                        ;
                        ; Encoded as:   ""

 EQUB VE                ; Token 246:    ""
                        ;
                        ; Encoded as:   ""

 EQUB VE                ; Token 247:    ""
                        ;
                        ; Encoded as:   ""

 EQUB VE                ; Token 248:    ""
                        ;
                        ; Encoded as:   ""

 EQUB VE                ; Token 249:    ""
                        ;
                        ; Encoded as:   ""

 EQUB VE                ; Token 250:    ""
                        ;
                        ; Encoded as:   ""

 EQUB VE                ; Token 251:    ""
                        ;
                        ; Encoded as:   ""

 EQUB VE                ; Token 252:    ""
                        ;
                        ; Encoded as:   ""

 EQUB VE                ; Token 253:    ""
                        ;
                        ; Encoded as:   ""

 EQUB VE                ; Token 254:    ""
                        ;
                        ; Encoded as:   ""

 EQUB VE                ; Token 255:    ""
                        ;
                        ; Encoded as:   ""

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
                        ;
                        ; Encoded as:   ""

 EJMP 19                ; Token 1:      "{single cap}LES COLONISATEURS ONT VIOLÉ
 ETWO 'L', 'E'          ;                LE {single cap}PROTOCOLE {single cap}
 ECHR 'S'               ;                INTERGALACTIQUE, IL FAUT LES ÉVITER"
 ECHR ' '               ;
 ECHR 'C'               ; Encoded as:   "{19}<229>S COL<223>IS<245>EURS <223>T V
 ECHR 'O'               ;                IOL< <229>{26}PROTOCO<229>{26}<240>T
 ECHR 'L'               ;                <244>G<228>AC<251><254>E, <220> FAUT
 ETWO 'O', 'N'          ;                 <229>S <V<219><244>"
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

 EJMP 19                ; Token 2:      "{single cap}LE CONSTRICTOR PERDU DE VUE
 ETWO 'L', 'E'          ;                À {single cap}{single cap}REESDICE,
 ECHR ' '               ;                {single cap}COMMANDANT"
 ECHR 'C'               ;
 ETWO 'O', 'N'          ; Encoded as:   "{19}<229> C<223><222>RICT<253> [203]
 ETWO 'S', 'T'          ;                {19}<242><237><241><233>, [154]"
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

 EJMP 19                ; Token 3:      "{single cap}UN NAVIRE REDOUTABLE EST
 ECHR 'U'               ;                PARTI D'ICI. {single cap}IL SEMBLAIT
 ECHR 'N'               ;                ALLER À {single cap}AREXE"
 ECHR ' '               ;
 ECHR 'N'               ; Encoded as:   "{19}UN NAVI<242> <242>D<217>T<216><229>
 ECHR 'A'               ;                 E<222> P<238><251> D'ICI.{26}<220>
 ECHR 'V'               ;                 <218>MB<249><219> <228><229>R "{26}
 ECHR 'I'               ;                <238>E<230>"
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

 EJMP 19                ; Token 4:      "{single cap}OUI, CE PUISSANT NAVIRE
 ETWO 'O', 'U'          ;                AVAIT UN PROPULSEUR {single cap}
 ECHR 'I'               ;                GALACTIQUE INCORPORÉ"
 ECHR ','               ;
 ECHR ' '               ; Encoded as:   "{19}<217>I, <233> PUISS<255>T NAVI<242>
 ETWO 'C', 'E'          ;                 AVA<219> UN PROPUL<218>UR{26}G<228>AC
 ECHR ' '               ;                <251><254>E <240>C<253>P<253><"
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

 EJMP 19                ; Token 5:      "{single cap}OUI, UN NAVIRE REDOUTABLE A
 ETWO 'O', 'U'          ;                SURGI DE NULLE PART. {single cap}JE
 ECHR 'I'               ;                CROIS QU'IL ALLAIT À {single cap}
 ECHR ','               ;                INBIBE"
 ECHR ' '               ;
 ECHR 'U'               ; Encoded as:   "{19}<217>I, UN NAVI<242> <242>D<217>T
 ECHR 'N'               ;                <216><229> A SURGI DE <225>L<229> P
 ECHR ' '               ;                <238>T.{26}JE CROIS <254>'<220> <228>
 ECHR 'N'               ;                <249><219> "{26}<240><234><247>"
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

 EJMP 19                ; Token 6:      "{single cap}UN NAVIRE [91-95] M'A
 ECHR 'U'               ;                CHERCHÉ À {single cap}AUSAR. {single
 ECHR 'N'               ;                cap}MES LASERS N'ONT RIEN PU FAIRE
 ECHR ' '               ;                CONTRE CE VAURIEN"
 ECHR 'N'               ;
 ECHR 'A'               ; Encoded as:   "{19}UN NAVI<242> [24?] M'A CH<244>CH<
 ECHR 'V'               ;                 "{26}A<236><238>.{26}M<237> <249><218>
 ECHR 'I'               ;                RS N'<223>T RI<246> PU FAI<242> C<223>T
 ETWO 'R', 'E'          ;                <242> <233> VAURI<246>"
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

 EJMP 19                ; Token 7:      "{single cap}UN NAVIRE REDOUTABLE A TIRÉ
 ECHR 'U'               ;                SUR BEAUCOUP DE PIRATES, PUIS IL EST
 ECHR 'N'               ;                PARTI VERS {single cap}USLERI"
 ECHR ' '               ;
 ECHR 'N'               ; Encoded as:   "{19}UN NAVI<242> <242>D<217>T<216><229>
 ECHR 'A'               ;                 A <251>R< SUR <247>AUC<217>P DE PIR
 ECHR 'V'               ;                <245><237>, PUIS <220> E<222> P<238>
 ECHR 'I'               ;                <251> V<244>S{26}<236><229>RI"
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

 EJMP 19                ; Token 8:      "{single cap}VOUS POUVEZ ALLER VOIR CE
 ECHR 'V'               ;                VAURIEN. {single cap}IL EST À {single
 ETWO 'O', 'U'          ;                cap}ORARRA"
 ECHR 'S'               ;
 ECHR ' '               ; Encoded as:   "{19}V<217>S P<217><250>Z <228><229>R VO
 ECHR 'P'               ;                IR <233> VAURI<246>.{26}<220> E<222> "
 ETWO 'O', 'U'          ;                {26}<253><238><248>"
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

 ERND 25                ; Token 9:      "[106-110]"
 EQUB VE                ;
                        ; Encoded as:   "[25?]"

 ERND 25                ; Token 10:     "[106-110]"
 EQUB VE                ;
                        ; Encoded as:   "[25?]"

 ERND 25                ; Token 11:     "[106-110]"
 EQUB VE                ;
                        ; Encoded as:   "[25?]"

 ERND 25                ; Token 12:     "[106-110]"
 EQUB VE                ;
                        ; Encoded as:   "[25?]"

 ERND 25                ; Token 13:     "[106-110]"
 EQUB VE                ;
                        ; Encoded as:   "[25?]"

 ERND 25                ; Token 14:     "[106-110]"
 EQUB VE                ;
                        ; Encoded as:   "[25?]"

 ERND 25                ; Token 15:     "[106-110]"
 EQUB VE                ;
                        ; Encoded as:   "[25?]"

 ERND 25                ; Token 16:     "[106-110]"
 EQUB VE                ;
                        ; Encoded as:   "[25?]"

 ERND 25                ; Token 17:     "[106-110]"
 EQUB VE                ;
                        ; Encoded as:   "[25?]"

 ERND 25                ; Token 18:     "[106-110]"
 EQUB VE                ;
                        ; Encoded as:   "[25?]"

 ERND 25                ; Token 19:     "[106-110]"
 EQUB VE                ;
                        ; Encoded as:   "[25?]"

 ERND 25                ; Token 20:     "[106-110]"
 EQUB VE                ;
                        ; Encoded as:   "[25?]"

 ERND 25                ; Token 21:     "[106-110]"
 EQUB VE                ;
                        ; Encoded as:   "[25?]"

 EJMP 19                ; Token 22:     "{single cap}CE N'EST PAS LA BONNE
 ETWO 'C', 'E'          ;                GALAXIE!"
 ECHR ' '               ;
 ECHR 'N'               ; Encoded as:   "{19}<233> N'E<222> PAS [182]B<223>NE G
 ECHR '`'               ;                <228>AXIE!"
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

 EJMP 19                ; Token 23:     "{single cap}IL Y A UN PIRATE [91-95]
 ETWO 'I', 'L'          ;                CRUEL LÀ-BAS"
 ECHR ' '               ;
 ECHR 'Y'               ; Encoded as:   "{19}<220> Y A UN PIR<245>E [24?] CRUEL
 ECHR ' '               ;                 L"-BAS"
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
;  Deep dive: Printing text tokens
;
; ******************************************************************************

.QQ18

 RTOK 111               ; Token 0:      "FUEL SCOOPS ON {beep}"
 RTOK 131               ;
 CONT 7                 ; Encoded as:   "[111][131]{7}"
 EQUB 0

 CHAR ' '               ; Token 1:      " CHART"
 CHAR 'C'               ;
 CHAR 'H'               ; Encoded as:   " CH<138>T"
 TWOK 'A', 'R'
 CHAR 'T'
 EQUB 0

 CHAR 'G'               ; Token 2:      "GOVERNMENT"
 CHAR 'O'               ;
 CHAR 'V'               ; Encoded as:   "GOV<144>NM<146>T"
 TWOK 'E', 'R'
 CHAR 'N'
 CHAR 'M'
 TWOK 'E', 'N'
 CHAR 'T'
 EQUB 0

 CHAR 'D'               ; Token 3:      "DATA ON {selected system name}"
 TWOK 'A', 'T'          ;
 CHAR 'A'               ; Encoded as:   "D<145>A[131]{3}"
 RTOK 131
 CONT 3
 EQUB 0

 TWOK 'I', 'N'          ; Token 4:      "INVENTORY{cr}
 CHAR 'V'               ;               "
 TWOK 'E', 'N'          ;
 CHAR 'T'               ; Encoded as:   "<140>V<146>T<153>Y{12}"
 TWOK 'O', 'R'
 CHAR 'Y'
 CONT 12
 EQUB 0

 CHAR 'S'               ; Token 5:      "SYSTEM"
 CHAR 'Y'               ;
 CHAR 'S'               ; Encoded as:   "SYS<156>M"
 TWOK 'T', 'E'
 CHAR 'M'
 EQUB 0

 CHAR 'P'               ; Token 6:      "PRICE"
 TWOK 'R', 'I'          ;
 TWOK 'C', 'E'          ; Encoded as:   "P<158><133>"
 EQUB 0

 CONT 2                 ; Token 7:      "{current system name} MARKET PRICES"
 CHAR ' '               ;
 CHAR 'M'               ; Encoded as:   "{2} M<138>RKET [6]S"
 TWOK 'A', 'R'
 CHAR 'K'
 CHAR 'E'
 CHAR 'T'
 CHAR ' '
 RTOK 6
 CHAR 'S'
 EQUB 0

 TWOK 'I', 'N'          ; Token 8:      "INDUSTRIAL"
 CHAR 'D'               ;
 TWOK 'U', 'S'          ; Encoded as:   "<140>D<136>T<158>AL"
 CHAR 'T'
 TWOK 'R', 'I'
 CHAR 'A'
 CHAR 'L'
 EQUB 0

 CHAR 'A'               ; Token 9:      "AGRICULTURAL"
 CHAR 'G'               ;
 TWOK 'R', 'I'          ; Encoded as:   "AG<158>CULTU<148>L"
 CHAR 'C'
 CHAR 'U'
 CHAR 'L'
 CHAR 'T'
 CHAR 'U'
 TWOK 'R', 'A'
 CHAR 'L'
 EQUB 0

 TWOK 'R', 'I'          ; Token 10:     "RICH "
 CHAR 'C'               ;
 CHAR 'H'               ; Encoded as:   "<158>CH "
 CHAR ' '
 EQUB 0

 RTOK 139               ; Token 11:     "AVERAGE "
 CHAR ' '               ;
 EQUB 0                 ; Encoded as:   "[139]"

 RTOK 138               ; Token 12:     "POOR "
 CHAR ' '               ;
 EQUB 0                 ; Encoded as:   "[138]"

 TWOK 'M', 'A'          ; Token 13:     "MAINLY "
 TWOK 'I', 'N'          ;
 CHAR 'L'               ; Encoded as:   "<139><140>LY "
 CHAR 'Y'
 CHAR ' '
 EQUB 0

 CHAR 'U'               ; Token 14:     "UNIT"
 CHAR 'N'               ;
 CHAR 'I'               ; Encoded as:   "UNIT"
 CHAR 'T'
 EQUB 0

 CHAR 'V'               ; Token 15:     "VIEW "
 CHAR 'I'               ;
 CHAR 'E'               ; Encoded as:   "VIEW "
 CHAR 'W'
 CHAR ' '
 EQUB 0

 EQUB 0                 ; Token 16:     ""
                        ;
                        ; Encoded as:   ""

 TWOK 'A', 'N'          ; Token 17:     "ANARCHY"
 TWOK 'A', 'R'          ;
 CHAR 'C'               ; Encoded as:   "<155><138>CHY"
 CHAR 'H'
 CHAR 'Y'
 EQUB 0

 CHAR 'F'               ; Token 18:     "FEUDAL"
 CHAR 'E'               ;
 CHAR 'U'               ; Encoded as:   "FEUDAL"
 CHAR 'D'
 CHAR 'A'
 CHAR 'L'
 EQUB 0

 CHAR 'M'               ; Token 19:     "MULTI-{sentence case}GOVERNMENT"
 CHAR 'U'               ;
 CHAR 'L'               ; Encoded as:   "MUL<151>-{6}[2]"
 TWOK 'T', 'I'
 CHAR '-'
 CONT 6
 RTOK 2
 EQUB 0

 TWOK 'D', 'I'          ; Token 20:     "DICTATORSHIP"
 CHAR 'C'               ;
 CHAR 'T'               ; Encoded as:   "<141>CT<145><153>[25]"
 TWOK 'A', 'T'
 TWOK 'O', 'R'
 RTOK 25
 EQUB 0

 RTOK 91                ; Token 21:     "COMMUNIST"
 CHAR 'M'               ;
 CHAR 'U'               ; Encoded as:   "[91]MUN<157>T"
 CHAR 'N'
 TWOK 'I', 'S'
 CHAR 'T'
 EQUB 0

 CHAR 'C'               ; Token 22:     "CONFEDERACY"
 TWOK 'O', 'N'          ;
 CHAR 'F'               ; Encoded as:   "C<159>F<152><144>ACY"
 TWOK 'E', 'D'
 TWOK 'E', 'R'
 CHAR 'A'
 CHAR 'C'
 CHAR 'Y'
 EQUB 0

 CHAR 'D'               ; Token 23:     "DEMOCRACY"
 CHAR 'E'               ;
 CHAR 'M'               ; Encoded as:   "DEMOC<148>CY"
 CHAR 'O'
 CHAR 'C'
 TWOK 'R', 'A'
 CHAR 'C'
 CHAR 'Y'
 EQUB 0

 CHAR 'C'               ; Token 24:     "CORPORATE STATE"
 TWOK 'O', 'R'          ;
 CHAR 'P'               ; Encoded as:   "C<153>P<153><145>E [43]<145>E"
 TWOK 'O', 'R'
 TWOK 'A', 'T'
 CHAR 'E'
 CHAR ' '
 RTOK 43
 TWOK 'A', 'T'
 CHAR 'E'
 EQUB 0

 CHAR 'S'               ; Token 25:     "SHIP"
 CHAR 'H'               ;
 CHAR 'I'               ; Encoded as:   "SHIP"
 CHAR 'P'
 EQUB 0

 CHAR 'P'               ; Token 26:     "PRODUCT"
 RTOK 94                ;
 CHAR 'D'               ; Encoded as:   "P[94]]DUCT"
 CHAR 'U'
 CHAR 'C'
 CHAR 'T'
 EQUB 0

 CHAR ' '               ; Token 27:     " LASER"
 TWOK 'L', 'A'          ;
 CHAR 'S'               ; Encoded as:   " <149>S<144>"
 TWOK 'E', 'R'
 EQUB 0

 CHAR 'H'               ; Token 28:     "HUMAN COLONIALS"
 CHAR 'U'               ;
 TWOK 'M', 'A'          ; Encoded as:   "HU<139>N COL<159>IALS"
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

 CHAR 'H'               ; Token 29:     "HYPERSPACE "
 CHAR 'Y'               ;
 CHAR 'P'               ; Encoded as:   "HYP<144>SPA<133> "
 TWOK 'E', 'R'
 CHAR 'S'
 CHAR 'P'
 CHAR 'A'
 TWOK 'C', 'E'
 CHAR ' '
 EQUB 0

 CHAR 'S'               ; Token 30:     "SHORT RANGE CHART"
 CHAR 'H'               ;
 TWOK 'O', 'R'          ; Encoded as:   "SH<153>T [42][1]"
 CHAR 'T'
 CHAR ' '
 RTOK 42
 RTOK 1
 EQUB 0

 TWOK 'D', 'I'          ; Token 31:     "DISTANCE"
 RTOK 43                ;
 TWOK 'A', 'N'          ; Encoded as:   "<141>[43]<155><133>"
 TWOK 'C', 'E'
 EQUB 0

 CHAR 'P'               ; Token 32:     "POPULATION"
 CHAR 'O'               ;
 CHAR 'P'               ; Encoded as:   "POPUL<145>I<159>"
 CHAR 'U'
 CHAR 'L'
 TWOK 'A', 'T'
 CHAR 'I'
 TWOK 'O', 'N'
 EQUB 0

 CHAR 'T'               ; Token 33:     "TURNOVER"
 CHAR 'U'               ;
 CHAR 'R'               ; Encoded as:   "TUENOV<144>"
 CHAR 'N'
 CHAR 'O'
 CHAR 'V'
 TWOK 'E', 'R'
 EQUB 0

 CHAR 'E'               ; Token 34:     "ECONOMY"
 CHAR 'C'               ;
 TWOK 'O', 'N'          ; Encoded as:   "EC<159>OMY"
 CHAR 'O'
 CHAR 'M'
 CHAR 'Y'
 EQUB 0

 CHAR ' '               ; Token 35:     " LIGHT YEARS"
 CHAR 'L'               ;
 CHAR 'I'               ; Encoded as:   " LIGHT YE<138>S"
 CHAR 'G'
 CHAR 'H'
 CHAR 'T'
 CHAR ' '
 CHAR 'Y'
 CHAR 'E'
 TWOK 'A', 'R'
 CHAR 'S'
 EQUB 0

 TWOK 'T', 'E'          ; Token 36:     "TECH.LEVEL"
 CHAR 'C'               ;
 CHAR 'H'               ; Encoded as:   "<156>CH.<129><150>L"
 CHAR '.'
 TWOK 'L', 'E'
 TWOK 'V', 'E'
 CHAR 'L'
 EQUB 0

 CHAR 'C'               ; Token 37:     "CASH"
 CHAR 'A'               ;
 CHAR 'S'               ; Encoded as:   "CASH"
 CHAR 'H'
 EQUB 0

 CHAR ' '               ; Token 38:     " BILLION"
 TWOK 'B', 'I'          ;
 CHAR 'L'               ; Encoded as:   " <134>LLI<159>"
 CHAR 'L'
 CHAR 'I'
 TWOK 'O', 'N'
 EQUB 0

 RTOK 122               ; Token 39:     "GALACTIC CHART{galaxy number}"
 RTOK 1                 ;
 CONT 1                 ; Encoded as:   "[122][1]{1}"
 EQUB 0

 CHAR 'T'               ; Token 40:     "TARGET LOST"
 TWOK 'A', 'R'          ;
 TWOK 'G', 'E'          ; Encoded as:   "T<138><131>T LO[43]"
 CHAR 'T'
 CHAR ' '
 CHAR 'L'
 CHAR 'O'
 RTOK 43
 EQUB 0

 RTOK 106               ; Token 41:     "MISSILE JAMMED"
 CHAR ' '               ;
 CHAR 'J'               ; Encoded as:   "[106] JAMM<152>"
 CHAR 'A'
 CHAR 'M'
 CHAR 'M'
 TWOK 'E', 'D'
 EQUB 0

 TWOK 'R', 'A'          ; Token 42:     "RANGE"
 CHAR 'N'               ;
 TWOK 'G', 'E'          ; Encoded as:   "<148>N<131>"
 EQUB 0

 CHAR 'S'               ; Token 43:     "ST"
 CHAR 'T'               ;
 EQUB 0                 ; Encoded as:   "ST"

 EQUB 0                 ; Token 44:     ""
                        ;
                        ; Encoded as:   ""

 CHAR 'S'               ; Token 45:     "SELL"
 CHAR 'E'               ;
 CHAR 'L'               ; Encoded as:   "SELL"
 CHAR 'L'
 EQUB 0

 CHAR ' '               ; Token 46:     " CARGO{sentence case}"
 CHAR 'C'               ;
 TWOK 'A', 'R'          ; Encoded as:   " C<138>GO{6}"
 CHAR 'G'
 CHAR 'O'
 CONT 6
 EQUB 0

 CHAR 'E'               ; Token 47:     "EQUIP SHIP"
 TWOK 'Q', 'U'          ;
 CHAR 'I'               ; Encoded as:   "E<154>IP [25]"
 CHAR 'P'
 CHAR ' '
 RTOK 25
 EQUB 0

 CHAR 'F'               ; Token 48:     "FOOD"
 CHAR 'O'               ;
 CHAR 'O'               ; Encoded as:   "FOOD"
 CHAR 'D'
 EQUB 0

 TWOK 'T', 'E'          ; Token 49:     "TEXTILES"
 CHAR 'X'               ;
 TWOK 'T', 'I'          ; Encoded as:   "<156>X<151><129>S"
 TWOK 'L', 'E'
 CHAR 'S'
 EQUB 0

 TWOK 'R', 'A'          ; Token 50:     "RADIOACTIVES"
 TWOK 'D', 'I'          ;
 CHAR 'O'               ; Encoded as:   "<148><141>OAC<151>V<137>"
 CHAR 'A'
 CHAR 'C'
 TWOK 'T', 'I'
 CHAR 'V'
 TWOK 'E', 'S'
 EQUB 0

 RTOK 94                ; Token 51:     "ROBOT SLAVES"
 CHAR 'B'               ;
 CHAR 'O'               ; Encoded as:   "[94]BOT S<149>V<137>"
 CHAR 'T'
 CHAR ' '
 CHAR 'S'
 TWOK 'L', 'A'
 CHAR 'V'
 TWOK 'E', 'S'
 EQUB 0

 TWOK 'B', 'E'          ; Token 52:     "BEVERAGES"
 CHAR 'V'               ;
 TWOK 'E', 'R'          ; Encoded as:   "<147>V<144>A<131>S"
 CHAR 'A'
 TWOK 'G', 'E'
 CHAR 'S'
 EQUB 0

 CHAR 'L'               ; Token 53:     "LUXURIES"
 CHAR 'U'               ;
 CHAR 'X'               ; Encoded as:   "LUXU<158><137>"
 CHAR 'U'
 TWOK 'R', 'I'
 TWOK 'E', 'S'
 EQUB 0

 CHAR 'R'               ; Token 54:     "RARE SPECIES"
 TWOK 'A', 'R'          ;
 CHAR 'E'               ; Encoded as:   "R<138>E SPECI<137>"
 CHAR ' '
 CHAR 'S'
 CHAR 'P'
 CHAR 'E'
 CHAR 'C'
 CHAR 'I'
 TWOK 'E', 'S'
 EQUB 0

 RTOK 91                ; Token 55:     "COMPUTERS"
 CHAR 'P'               ;
 CHAR 'U'               ; Encoded as:   "[91]PUT<144>S"
 CHAR 'T'
 TWOK 'E', 'R'
 CHAR 'S'
 EQUB 0

 TWOK 'M', 'A'          ; Token 56:     "MACHINERY"
 CHAR 'C'               ;
 CHAR 'H'               ; Encoded as:   "<139>CH<140><144>Y"
 TWOK 'I', 'N'
 TWOK 'E', 'R'
 CHAR 'Y'
 EQUB 0

 RTOK 124               ; Token 57:     "ALLOYS"
 CHAR 'O'               ;
 CHAR 'Y'               ; Encoded as:   "[124]OYS"
 CHAR 'S'
 EQUB 0

 CHAR 'F'               ; Token 58:     "FIREARMS"
 CHAR 'I'               ;
 RTOK 97                ; Encoded as:   "FI[97]MS"
 CHAR 'M'
 CHAR 'S'
 EQUB 0

 CHAR 'F'               ; Token 59:     "FURS"
 CHAR 'U'               ;
 CHAR 'R'               ; Encoded as:   "FURS"
 CHAR 'S'
 EQUB 0

 CHAR 'M'               ; Token 60:     "MINERALS"
 TWOK 'I', 'N'          ;
 TWOK 'E', 'R'          ; Encoded as:   "M<140><144>ALS"
 CHAR 'A'
 CHAR 'L'
 CHAR 'S'
 EQUB 0

 CHAR 'G'               ; Token 61:     "GOLD"
 CHAR 'O'               ;
 CHAR 'L'               ; Encoded as:   "GOLD"
 CHAR 'D'
 EQUB 0

 CHAR 'P'               ; Token 62:     "PLATINUM"
 CHAR 'L'               ;
 TWOK 'A', 'T'          ; Encoded as:   "PL<145><140>UM"
 TWOK 'I', 'N'
 CHAR 'U'
 CHAR 'M'
 EQUB 0

 TWOK 'G', 'E'          ; Token 63:     "GEM-STONES"
 CHAR 'M'               ;
 CHAR '-'               ; Encoded as:   "<131>M-[43]<159><137>"
 RTOK 43
 TWOK 'O', 'N'
 TWOK 'E', 'S'
 EQUB 0

 CHAR 'A'               ; Token 64:     "ALIEN ITEMS"
 CHAR 'L'               ;
 CHAR 'I'               ; Encoded as:   "ALI<146> [127]S"
 TWOK 'E', 'N'
 CHAR ' '
 RTOK 127
 CHAR 'S'
 EQUB 0

 EQUB 0                 ; Token 65:     ""
                        ;
                        ; Encoded as:   ""

 CHAR ' '               ; Token 66:     " CR"
 CHAR 'C'               ;
 CHAR 'R'               ; Encoded as:   " CR"
 EQUB 0

 EQUB 0                 ; Token 67:     ""
                        ;
                        ; Encoded as:   ""

 EQUB 0                 ; Token 68:     ""
                        ;
                        ; Encoded as:   ""

 EQUB 0                 ; Token 69:     ""
                        ;
                        ; Encoded as:   ""

 CHAR 'G'               ; Token 70:     "GREEN"
 TWOK 'R', 'E'          ;
 TWOK 'E', 'N'          ; Encoded as:   "G<142><146>"
 EQUB 0

 TWOK 'R', 'E'          ; Token 71:     "RED"
 CHAR 'D'
 EQUB 0                 ; Encoded as:   "<142>D"

 CHAR 'Y'               ; Token 72:     "YELLOW"
 CHAR 'E'               ;
 CHAR 'L'               ; Encoded as:   "YELLOW"
 CHAR 'L'
 CHAR 'O'
 CHAR 'W'
 EQUB 0

 CHAR 'B'               ; Token 73:     "BLUE"
 CHAR 'L'               ;
 CHAR 'U'               ; Encoded as:   "BLUE"
 CHAR 'E'
 EQUB 0

 CHAR 'B'               ; Token 74:     "BLACK"
 TWOK 'L', 'A'          ;
 CHAR 'C'               ; Encoded as:   "B<149>CK"
 CHAR 'K'
 EQUB 0

 RTOK 136               ; Token 75:     "HARMLESS"
 EQUB 0                 ;
                        ; Encoded as:   "[136]"

 CHAR 'S'               ; Token 76:     "SLIMY"
 CHAR 'L'               ;
 CHAR 'I'               ; Encoded as:   "SLIMY"
 CHAR 'M'
 CHAR 'Y'
 EQUB 0

 CHAR 'B'               ; Token 77:     "BUG-EYED"
 CHAR 'U'               ;
 CHAR 'G'               ; Encoded as:   "BUG-EY<152>"
 CHAR '-'
 CHAR 'E'
 CHAR 'Y'
 TWOK 'E', 'D'
 EQUB 0

 CHAR 'H'               ; Token 78:     "HORNED"
 TWOK 'O', 'R'          ;
 CHAR 'N'               ; Encoded as:   "H<153>N<152>"
 TWOK 'E', 'D'
 EQUB 0

 CHAR 'B'               ; Token 79:     "BONY"
 TWOK 'O', 'N'          ;
 CHAR 'Y'               ; Encoded as:   "B<159>Y"
 EQUB 0

 CHAR 'F'               ; Token 80:     "FAT"
 TWOK 'A', 'T'          ;
 EQUB 0                 ; Encoded as:   "F<145>"

 CHAR 'F'               ; Token 81:     "FURRY"
 CHAR 'U'               ;
 CHAR 'R'               ; Encoded as:   "FURRY"
 CHAR 'R'
 CHAR 'Y'
 EQUB 0

 RTOK 94                ; Token 82:     "RODENTS"
 CHAR 'D'               ;
 TWOK 'E', 'N'          ; Encoded as:   "[94]D<146>TS"
 CHAR 'T'
 CHAR 'S'
 EQUB 0

 CHAR 'F'               ; Token 83:     "FROGS"
 RTOK 94                ;
 CHAR 'G'               ; Encoded as:   "F[94]GS"
 CHAR 'S'
 EQUB 0

 CHAR 'L'               ; Token 84:     "LIZARDS"
 CHAR 'I'               ;
 TWOK 'Z', 'A'          ; Encoded as:   "LI<132>RDS"
 CHAR 'R'
 CHAR 'D'
 CHAR 'S'
 EQUB 0

 CHAR 'L'               ; Token 85:     "LOBSTERS"
 CHAR 'O'               ;
 CHAR 'B'               ; Encoded as:   "LOB[43]<144>S"
 RTOK 43
 TWOK 'E', 'R'
 CHAR 'S'
 EQUB 0

 TWOK 'B', 'I'          ; Token 86:     "BIRDS"
 CHAR 'R'               ;
 CHAR 'D'               ; Encoded as:   "<134>RDS"
 CHAR 'S'
 EQUB 0

 CHAR 'H'               ; Token 87:     "HUMANOIDS"
 CHAR 'U'               ;
 TWOK 'M', 'A'          ; Encoded as:   "HU<139>NOIDS"
 CHAR 'N'
 CHAR 'O'
 CHAR 'I'
 CHAR 'D'
 CHAR 'S'
 EQUB 0

 CHAR 'F'               ; Token 88:     "FELINES"
 CHAR 'E'               ;
 CHAR 'L'               ; Encoded as:   "FEL<140><137>"
 TWOK 'I', 'N'
 TWOK 'E', 'S'
 EQUB 0

 TWOK 'I', 'N'          ; Token 89:     "INSECTS"
 CHAR 'S'               ;
 CHAR 'E'               ; Encoded as:   "<140>SECTS"
 CHAR 'C'
 CHAR 'T'
 CHAR 'S'
 EQUB 0

 TWOK 'R', 'A'          ; Token 90:     "RADIUS"
 TWOK 'D', 'I'          ;
 TWOK 'U', 'S'          ; Encoded as:   "<148><141><136>"
 EQUB 0

 CHAR 'C'               ; Token 91:     "COM"
 CHAR 'O'               ;
 CHAR 'M'               ; Encoded as:   "COM"
 EQUB 0

 RTOK 91                ; Token 92:     "COMMANDER"
 TWOK 'M', 'A'          ;
 CHAR 'N'               ; Encoded as:   "[91]<139>ND<144>"
 CHAR 'D'
 TWOK 'E', 'R'
 EQUB 0

 CHAR ' '               ; Token 93:     " DESTROYED"
 CHAR 'D'               ;
 TWOK 'E', 'S'          ; Encoded as:   " D<137>T[94]Y<152>"
 CHAR 'T'
 RTOK 94
 CHAR 'Y'
 TWOK 'E', 'D'
 EQUB 0

 CHAR 'R'               ; Token 94:     "RO"
 CHAR 'O'               ;
 EQUB 0                 ; Encoded as:   "RO"

 RTOK 26                ; Token 95:     "PRODUCT   UNIT PRICE QUANTITY"
 CHAR ' '               ;
 CHAR ' '               ; Encoded as:   "[26]   [14] [6] <154><155><151>TY"
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

 CHAR 'F'               ; Token 96:     "FRONT"
 CHAR 'R'               ;
 TWOK 'O', 'N'          ; Encoded as:   "FR<159>T"
 CHAR 'T'
 EQUB 0

 TWOK 'R', 'E'          ; Token 97:     "REAR"
 TWOK 'A', 'R'          ;
 EQUB 0                 ; Encoded as:   "<142><138>"

 TWOK 'L', 'E'          ; Token 98:     "LEFT"
 CHAR 'F'               ;
 CHAR 'T'               ; Encoded as:   "<129>FT"
 EQUB 0

 TWOK 'R', 'I'          ; Token 99:     "RIGHT"
 CHAR 'G'               ;
 CHAR 'H'               ; Encoded as:   "<158>GHT"
 CHAR 'T'
 EQUB 0

 RTOK 121               ; Token 100:    "ENERGY LOW{beep}"
 CHAR 'L'               ;
 CHAR 'O'               ; Encoded as:   "[121]LOW{7}"
 CHAR 'W'
 CONT 7
 EQUB 0

 RTOK 99                ; Token 101:    "RIGHT ON COMMANDER!"
 RTOK 131               ;
 RTOK 92                ; Encoded as:   "[99][131][92]!"
 CHAR '!'
 EQUB 0

 CHAR 'E'               ; Token 102:    "EXTRA "
 CHAR 'X'               ;
 CHAR 'T'               ; Encoded as:   "EXT<148> "
 TWOK 'R', 'A'
 CHAR ' '
 EQUB 0

 CHAR 'P'               ; Token 103:    "PULSE LASER"
 CHAR 'U'               ;
 CHAR 'L'               ; Encoded as:   "PULSE[27]"
 CHAR 'S'
 CHAR 'E'
 RTOK 27
 EQUB 0

 TWOK 'B', 'E'          ; Token 104:    "BEAM LASER"
 CHAR 'A'               ;
 CHAR 'M'               ; Encoded as:   "<147>AM[27]"
 RTOK 27
 EQUB 0

 CHAR 'F'               ; Token 105:    "FUEL"
 CHAR 'U'               ;
 CHAR 'E'               ; Encoded as:   "FUEL"
 CHAR 'L'
 EQUB 0

 CHAR 'M'               ; Token 106:    "MISSILE"
 TWOK 'I', 'S'          ;
 CHAR 'S'               ; Encoded as:   "M<157>SI<129>"
 CHAR 'I'
 TWOK 'L', 'E'
 EQUB 0

 CHAR 'L'               ; Token 107:    "LARGE CARGO BAY""
 TWOK 'A', 'R'          ;
 TWOK 'G', 'E'          ; Encoded as:   "L<138><131> C<138>GO BAY
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

 CHAR 'E'               ; Token 108:    "E.C.M.SYSTEM"
 CHAR '.'               ;
 CHAR 'C'               ; Encoded as:   "E.C.M.[5]"
 CHAR '.'
 CHAR 'M'
 CHAR '.'
 RTOK 5
 EQUB 0

 RTOK 102               ; Token 109:    "EXTRA PULSE LASERS"
 RTOK 103               ;
 CHAR 'S'               ; Encoded as:   "[102][103]S"
 EQUB 0

 RTOK 102               ; Token 110:    "EXTRA BEAM LASERS"
 RTOK 104               ;
 CHAR 'S'               ; Encoded as:   "[102][104]S"
 EQUB 0

 RTOK 105               ; Token 111:    "FUEL SCOOPS"
 CHAR ' '               ;
 CHAR 'S'               ; Encoded as:   "[105] SCOOPS"
 CHAR 'C'
 CHAR 'O'
 CHAR 'O'
 CHAR 'P'
 CHAR 'S'
 EQUB 0

 TWOK 'E', 'S'          ; Token 112:    "ESCAPE CAPSULE"
 CHAR 'C'               ;
 CHAR 'A'               ; Encoded as:   "<137>CAPE CAPSULE"
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

 RTOK 121               ; Token 113:    "ENERGY BOMB"
 CHAR 'B'               ;
 CHAR 'O'               ; Encoded as:   "[121]BOMB"
 CHAR 'M'
 CHAR 'B'
 EQUB 0

 RTOK 121               ; Token 114:    "ENERGY UNIT"
 RTOK 14                ;
 EQUB 0                 ; Encoded as:   "[121][14]"

 CHAR 'D'               ; Token 115:    "DOCKING COMPUTERS"
 CHAR 'O'               ;
 CHAR 'C'               ; Encoded as:   "DOCK<140>G [55]"
 CHAR 'K'
 TWOK 'I', 'N'
 CHAR 'G'
 CHAR ' '
 RTOK 55
 EQUB 0

 RTOK 122               ; Token 116:    "GALACTIC HYPERSPACE "
 CHAR ' '               ;
 CHAR 'H'               ; Encoded as:   "[122] HYP<144>SPA<133>"
 CHAR 'Y'
 CHAR 'P'
 TWOK 'E', 'R'
 CHAR 'S'
 CHAR 'P'
 CHAR 'A'
 TWOK 'C', 'E'
 EQUB 0

 CHAR 'M'               ; Token 117:    "MILITARY LASER"
 CHAR 'I'               ;
 CHAR 'L'               ; Encoded as:   "MILIT<138>Y[27]"
 CHAR 'I'
 CHAR 'T'
 TWOK 'A', 'R'
 CHAR 'Y'
 RTOK 27
 EQUB 0

 CHAR 'M'               ; Token 118:    "MINING LASER"
 TWOK 'I', 'N'          ;
 TWOK 'I', 'N'          ; Encoded as:   "M<140><140>G[27]"
 CHAR 'G'
 RTOK 27
 EQUB 0

 RTOK 37                ; Token 119:    "CASH:{cash} CR{cr}
 CHAR ':'               ;               "
 CONT 0                 ;
 EQUB 0                 ; Encoded as:   "[37]:{0}"

 TWOK 'I', 'N'          ; Token 120:    "INCOMING MISSILE"
 RTOK 91                ;
 TWOK 'I', 'N'          ; Encoded as:   "<140>[91]<140>G [106]"
 CHAR 'G'
 CHAR ' '
 RTOK 106
 EQUB 0

 TWOK 'E', 'N'          ; Token 121:    "ENERGY "
 TWOK 'E', 'R'          ;
 CHAR 'G'               ; Encoded as:   "<146><144>GY "
 CHAR 'Y'
 CHAR ' '
 EQUB 0

 CHAR 'G'               ; Token 122:    "GALACTIC"
 CHAR 'A'               ;
 TWOK 'L', 'A'          ; Encoded as:   "GA<149>C<151>C"
 CHAR 'C'
 TWOK 'T', 'I'
 CHAR 'C'
 EQUB 0

 RTOK 115               ; Token 123:    "DOCKING COMPUTERS ON "
 RTOK 131               ;
 EQUB 0                 ; Encoded as:   "[115][131]"

 CHAR 'A'               ; Token 124:    "ALL"
 CHAR 'L'               ;
 CHAR 'L'               ; Encoded as:   "ALL"
 EQUB 0

 TWOK 'L', 'E'          ; Token 125:    "LEGAL STATUS:"
 CHAR 'G'               ;
 CHAR 'A'               ; Encoded as:   "<129>GAL [43]<145><136>:"
 CHAR 'L'
 CHAR ' '
 RTOK 43
 TWOK 'A', 'T'
 TWOK 'U', 'S'
 CHAR ':'
 EQUB 0

 RTOK 92                ; Token 126:    "COMMANDER {commander name}{cr}
 CHAR ' '               ;                {cr}
 CONT 4                 ;                {cr}
 CONT 12                ;                {sentence case}PRESENT SYSTEM{tab to
 CONT 12                ;                column 22}:{current system name}{cr}
 CONT 12                ;                HYPERSPACE SYSTEM{tab to column 22}:
 CONT 6                 ;                {selected system name}{cr}
 CHAR 'C'               ;                CONDITION{tab to column 22}:"
 CHAR 'U'               ;
 CHAR 'R'               ; Encoded as:   "[92] {4}{12}{12}{12}{6}CUR<142>NT [5]
 TWOK 'R', 'E'          ;                {9}{2}{12}[29][5]{9}{3}{13}C<159><141>
 CHAR 'N'               ;                <151><159>{9}"
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

 CHAR 'I'               ; Token 127:    "ITEM"
 TWOK 'T', 'E'          ;
 CHAR 'M'               ; Encoded as:   "I<156>M"
 EQUB 0

 EQUB 0                 ; Token 128:    ""
                        ;
                        ; Encoded as:   ""

 CHAR 'L'               ; Token 129:    "LL"
 CHAR 'L'               ;
 EQUB 0                 ; Encoded as:   "LL"

 CHAR 'R'               ; Token 130:    "RATING"
 TWOK 'A', 'T'          ;
 TWOK 'I', 'N'          ; Encoded as:   "R<145><140>G"
 CHAR 'G'
 EQUB 0

 CHAR ' '               ; Token 131:    " ON "
 TWOK 'O', 'N'          ;
 CHAR ' '               ; Encoded as:   " <159> "
 EQUB 0

 CONT 12                ; Token 132:    "{all caps}EQUIPMENT: "
 CHAR 'E'               ;
 TWOK 'Q', 'U'          ; Encoded as:   "{12}E<154>IPM<146>T:"
 CHAR 'I'
 CHAR 'P'
 CHAR 'M'
 TWOK 'E', 'N'
 CHAR 'T'
 CHAR ':'
 EQUB 0

 CHAR 'C'               ; Token 133:    "CLEAN"
 TWOK 'L', 'E'          ;
 TWOK 'A', 'N'          ; Encoded as:   "C<129><155>"
 EQUB 0

 CHAR 'O'               ; Token 134:    "OFFENDER"
 CHAR 'F'               ;
 CHAR 'F'               ; Encoded as:   "OFF<146>D<144>"
 TWOK 'E', 'N'
 CHAR 'D'
 TWOK 'E', 'R'
 EQUB 0

 CHAR 'F'               ; Token 135:    "FUGITIVE"
 CHAR 'U'               ;
 CHAR 'G'               ; Encoded as:   "FUGI<151><150>"
 CHAR 'I'
 TWOK 'T', 'I'
 TWOK 'V', 'E'
 EQUB 0

 CHAR 'H'               ; Token 136:    "HARMLESS"
 TWOK 'A', 'R'          ;
 CHAR 'M'               ; Encoded as:   "H<138>M<129>SS"
 TWOK 'L', 'E'
 CHAR 'S'
 CHAR 'S'
 EQUB 0

 CHAR 'M'               ; Token 137:    "MOSTLY HARMLESS"
 CHAR 'O'               ;
 RTOK 43                ; Encoded as:   "MO[43]LY [136]"
 CHAR 'L'
 CHAR 'Y'
 CHAR ' '
 RTOK 136
 EQUB 0

 CHAR 'P'               ; Token 138:     "POOR"
 CHAR 'O'               ;
 TWOK 'O', 'R'          ; Encoded as:   "PO<153>"
 EQUB 0

 CHAR 'A'               ; Token 139:    "AVERAGE"
 CHAR 'V'               ;
 TWOK 'E', 'R'          ;
 CHAR 'A'               ; Encoded as:   "AV<144>A<131>"
 TWOK 'G', 'E'
 EQUB 0

 CHAR 'A'               ; Token 140:    "ABOVE AVERAGE "
 CHAR 'B'               ;
 CHAR 'O'               ; Encoded as:   "ABO<150> [139]"
 TWOK 'V', 'E'
 CHAR ' '
 RTOK 139
 EQUB 0

 RTOK 91                ; Token 141:    "COMPETENT"
 CHAR 'P'               ;
 CHAR 'E'               ; Encoded as:   "[91]PET<146>T"
 CHAR 'T'
 TWOK 'E', 'N'
 CHAR 'T'
 EQUB 0

 CHAR 'D'               ; Token 142:    "DANGEROUS"
 TWOK 'A', 'N'          ;
 TWOK 'G', 'E'          ; Encoded as:   "D<155><131>[94]<136>"
 RTOK 94
 TWOK 'U', 'S'
 EQUB 0

 CHAR 'D'               ; Token 143:    "DEADLY"
 CHAR 'E'               ;
 CHAR 'A'               ; Encoded as:   "DEADLY"
 CHAR 'D'
 CHAR 'L'
 CHAR 'Y'
 EQUB 0

 CHAR '-'               ; Token 144:    "---- E L I T E ----"
 CHAR '-'               ;
 CHAR '-'               ; Encoded as:   "---- E L I T E ----"
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

 CHAR 'P'               ; Token 145:    "PRESENT"
 CHAR 'R'               ;
 TWOK 'E', 'S'          ; Encoded as:   "PR<137><146>T"
 TWOK 'E', 'N'
 CHAR 'T'
 EQUB 0

 CONT 8                 ; Token 146:    "{all caps}GAME OVER"
 CHAR 'G'               ;
 CHAR 'A'               ; Encoded as:   "{8}GAME OV<144>"
 CHAR 'M'
 CHAR 'E'
 CHAR ' '
 CHAR 'O'
 CHAR 'V'
 TWOK 'E', 'R'
 EQUB 0

 CHAR '6'               ; Token 147:    "60 SECOND PENALTY"
 CHAR '0'               ;
 CHAR ' '               ; Encoded as:   "60 SEC<159>D P<146>ALTY"
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
                        ;
                        ; Encoded as:   ""

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

 RTOK 105               ; Token 0:      "TREIBSTOFFSCHAUFEL AN {beep}"
 CHAR 'S'               ;
 CHAR 'C'               ; Encoded as:   "[105]SCHAUFEL[131]{7}"
 CHAR 'H'
 CHAR 'A'
 CHAR 'U'
 CHAR 'F'
 CHAR 'E'
 CHAR 'L'
 RTOK 131
 CONT 7
 EQUB 0

 CHAR ' '               ; Token 1:      " KARTE"
 CHAR 'K'               ;
 TWOK 'A', 'R'          ; Encoded as:   " K<138><156>"
 TWOK 'T', 'E'
 EQUB 0

 TWOK 'R', 'E'          ; Token 2:      "REGIERUNG"
 CHAR 'G'               ;
 CHAR 'I'               ; Encoded as:   "<142>GI<144>UNG"
 TWOK 'E', 'R'
 CHAR 'U'
 CHAR 'N'
 CHAR 'G'
 EQUB 0

 CHAR 'D'               ; Token 3:      "DATEN EIN {selected system name}"
 TWOK 'A', 'T'          ;
 TWOK 'E', 'N'          ; Encoded as:   "D<145><146> E<140> {3}"
 CHAR ' '
 CHAR 'E'
 TWOK 'I', 'N'
 CHAR ' '
 CONT 3
 EQUB 0

 TWOK 'I', 'N'          ; Token 4:      "INHALT{cr}
 CHAR 'H'               ;               "
 CHAR 'A'               ;
 CHAR 'L'               ; Encoded as:   "<140>HALT{12}"
 CHAR 'T'
 CONT 12
 EQUB 0

 CONT 6                 ; Token 5:      "{sentence case}SYSTEM"
 CHAR 'S'               ;
 CHAR 'Y'               ; Encoded as:   "{6}SYS<156>M"
 CHAR 'S'
 TWOK 'T', 'E'
 CHAR 'M'
 EQUB 0

 CONT 6                 ; Token 6:      "{sentence case}PREIS"
 CHAR 'P'               ;
 TWOK 'R', 'E'          ; Encoded as:   "{6}P<142><157>"
 TWOK 'I', 'S'
 EQUB 0

 CONT 2                 ; Token 7:      "{current system name} BÖRSENPREISE "
 CHAR ' '               ;
 CHAR 'B'               ; Encoded as:   "{2} B\RS<146>P<142><157>E "
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

 TWOK 'I', 'N'          ; Token 8:      "INDUSTRIE"
 CHAR 'D'               ;
 TWOK 'U', 'S'          ; Encoded as:   "<140>D<136>T<158>E"
 CHAR 'T'
 TWOK 'R', 'I'
 CHAR 'E'
 EQUB 0

 CHAR 'A'               ; Token 9:      "AGRIKULTUR"
 CHAR 'G'               ;
 TWOK 'R', 'I'          ; Encoded as:   "AG<158>KULTUR"
 CHAR 'K'
 CHAR 'U'
 CHAR 'L'
 CHAR 'T'
 CHAR 'U'
 CHAR 'R'
 EQUB 0

 TWOK 'R', 'E'          ; Token 10:     "REICHE "
 CHAR 'I'               ;
 CHAR 'C'               ; Encoded as:   "<142>ICHE "
 CHAR 'H'
 CHAR 'E'
 CHAR ' '
 EQUB 0

 CHAR 'M'               ; Token 11:     "MITTELM "
 CHAR 'I'               ;
 CHAR 'T'               ; Encoded as:   "MIT<156>LM "
 TWOK 'T', 'E'
 CHAR 'L'
 CHAR 'M'
 CHAR ' '
 EQUB 0

 RTOK 138               ; Token 12:     "ARME "
 CHAR 'E'               ;
 CHAR ' '               ; Encoded as:   "[138]E "
 EQUB 0

 CHAR 'H'               ; Token 13:     "HAUPTS "
 CHAR 'A'               ;
 CHAR 'U'               ; Encoded as:   "HAUPTS "
 CHAR 'P'
 CHAR 'T'
 CHAR 'S'
 CHAR ' '
 EQUB 0

 CHAR 'E'               ; Token 14:     "EINHEIT"
 TWOK 'I', 'N'          ;
 CHAR 'H'               ; Encoded as:   "E<140>HEIT"
 CHAR 'E'
 CHAR 'I'
 CHAR 'T'
 EQUB 0

 TWOK 'A', 'N'          ; Token 15:     "ANSICHT"
 CHAR 'S'               ;
 CHAR 'I'               ; Encoded as:   "<155>SICHT"
 CHAR 'C'
 CHAR 'H'
 CHAR 'T'
 EQUB 0

 RTOK 44                ; Token 16:     "MENGE SEHEN "
 CHAR ' '               ;
 CHAR 'S'               ; Encoded as:   "[44] SEH<146> "
 CHAR 'E'
 CHAR 'H'
 TWOK 'E', 'N'
 CHAR ' '
 EQUB 0

 TWOK 'A', 'N'          ; Token 17:     "ANARCHIE"
 TWOK 'A', 'R'          ;
 CHAR 'C'               ; Encoded as:   "<155><138>CHIE"
 CHAR 'H'
 CHAR 'I'
 CHAR 'E'
 EQUB 0

 CHAR 'F'               ; Token 18:     "FEUDALSTAAT"
 CHAR 'E'               ;
 CHAR 'U'               ; Encoded as:   "FEUDAL[43]A<145>"
 CHAR 'D'
 CHAR 'A'
 CHAR 'L'
 RTOK 43
 CHAR 'A'
 TWOK 'A', 'T'
 EQUB 0

 CHAR 'M'               ; Token 19:     "MEHRFACHREGIERUNG"
 CHAR 'E'               ;
 CHAR 'H'               ; Encoded as:   "MEHRFACH[2]"
 CHAR 'R'
 CHAR 'F'
 CHAR 'A'
 CHAR 'C'
 CHAR 'H'
 RTOK 2
 EQUB 0

 TWOK 'D', 'I'          ; Token 20:     "DIKTATUR"
 CHAR 'K'               ;
 CHAR 'T'               ; Encoded as:   "<141>KT<145>UR"
 TWOK 'A', 'T'
 CHAR 'U'
 CHAR 'R'
 EQUB 0

 CHAR 'K'               ; Token 21:     "KOMMUNISTEN"
 CHAR 'O'               ;
 CHAR 'M'               ; Encoded as:   "KOMMUN<157>T<146>"
 CHAR 'M'
 CHAR 'U'
 CHAR 'N'
 TWOK 'I', 'S'
 CHAR 'T'
 TWOK 'E', 'N'
 EQUB 0

 CHAR 'K'               ; Token 22:     "KONFÖDERATION"
 TWOK 'O', 'N'          ;
 CHAR 'F'               ; Encoded as:   "K<159>F\D<144><145>I<159>"
 CHAR '\'
 CHAR 'D'
 TWOK 'E', 'R'
 TWOK 'A', 'T'
 CHAR 'I'
 TWOK 'O', 'N'
 EQUB 0

 CHAR 'D'               ; Token 23:     "DEMOKRATIE"
 CHAR 'E'               ;
 CHAR 'M'               ; Encoded as:   "DEMOKR<145>IE"
 CHAR 'O'
 CHAR 'K'
 CHAR 'R'
 TWOK 'A', 'T'
 CHAR 'I'
 CHAR 'E'
 EQUB 0

 CHAR 'K'               ; Token 24:     "KORPORATIVSTAAT"
 TWOK 'O', 'R'          ;
 CHAR 'P'               ; Encoded as:   "K<153>P<153><145>IV[43]A<145>"
 TWOK 'O', 'R'
 TWOK 'A', 'T'
 CHAR 'I'
 CHAR 'V'
 RTOK 43
 CHAR 'A'
 TWOK 'A', 'T'
 EQUB 0

 CHAR 'S'               ; Token 25:     "SCHIFF"
 CHAR 'C'               ;
 CHAR 'H'               ; Encoded as:   "SCHIFF"
 CHAR 'I'
 CHAR 'F'
 CHAR 'F'
 EQUB 0

 CHAR 'P'               ; Token 26:     "PRODUKT"
 RTOK 94                ;
 CHAR 'D'               ; Encoded as:   "P[94]DUKT"
 CHAR 'U'
 CHAR 'K'
 CHAR 'T'
 EQUB 0

 CHAR ' '               ; Token 27:     " LASER"
 TWOK 'L', 'A'          ;
 CHAR 'S'               ; Encoded as:   " <149>S<144>"
 TWOK 'E', 'R'
 EQUB 0

 CHAR 'M'               ; Token 28:     "MENSCHL. KOLONIST"
 TWOK 'E', 'N'          ;
 CHAR 'S'               ; Encoded as:   "M<146>SCHL. KOL<159><157>T"
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

 CHAR 'H'               ; Token 29:     "HYPERRAUM "
 CHAR 'Y'               ;
 CHAR 'P'               ; Encoded as:   "HYP<144><148>UM "
 TWOK 'E', 'R'
 TWOK 'R', 'A'
 CHAR 'U'
 CHAR 'M'
 CHAR ' '
 EQUB 0

 CHAR '\'               ; Token 30:     "ÖRTLICHE KARTE"
 CHAR 'R'               ;
 CHAR 'T'               ; Encoded as:   "\RTLICHE[1]"
 CHAR 'L'
 CHAR 'I'
 CHAR 'C'
 CHAR 'H'
 CHAR 'E'
 RTOK 1
 EQUB 0

 TWOK 'E', 'N'          ; Token 31:     "ENTFERNUNG"
 CHAR 'T'               ;
 CHAR 'F'               ; Encoded as:   "<146>TF<144>NUNG"
 TWOK 'E', 'R'
 CHAR 'N'
 CHAR 'U'
 CHAR 'N'
 CHAR 'G'
 EQUB 0

 TWOK 'B', 'E'          ; Token 32:     "BEVÖLKERUNG"
 CHAR 'V'               ;
 CHAR '\'               ; Encoded as:   "<147>V\LK<144>UNG"
 CHAR 'L'
 CHAR 'K'
 TWOK 'E', 'R'
 CHAR 'U'
 CHAR 'N'
 CHAR 'G'
 EQUB 0

 CHAR 'U'               ; Token 33:     "UMSATZ"
 CHAR 'M'               ;
 CHAR 'S'               ; Encoded as:   "UMS<145>Z"
 TWOK 'A', 'T'
 CHAR 'Z'
 EQUB 0

 CHAR 'W'               ; Token 34:     "WIRTSCHAFT"
 CHAR 'I'               ;
 CHAR 'R'               ; Encoded as:   "WIRTSCHAFT"
 CHAR 'T'
 CHAR 'S'
 CHAR 'C'
 CHAR 'H'
 CHAR 'A'
 CHAR 'F'
 CHAR 'T'
 EQUB 0

 CHAR ' '               ; Token 35:     " LICHTJ"
 CHAR 'L'               ;
 CHAR 'I'               ; Encoded as:   " LICHTJ"
 CHAR 'C'
 CHAR 'H'
 CHAR 'T'
 CHAR 'J'
 EQUB 0

 TWOK 'T', 'E'          ; Token 36:     "TECH.NIVEAU"
 CHAR 'C'               ;
 CHAR 'H'               ; Encoded as:   "<156>CH.NI<150>AU"
 CHAR '.'
 CHAR 'N'
 CHAR 'I'
 TWOK 'V', 'E'
 CHAR 'A'
 CHAR 'U'
 EQUB 0

 CHAR 'B'               ; Token 37:     "BARGELD"
 TWOK 'A', 'R'          ;
 TWOK 'G', 'E'          ; Encoded as:   "B<138><131>LD"
 CHAR 'L'
 CHAR 'D'
 EQUB 0

 CHAR ' '               ; Token 38:     " BILL."
 TWOK 'B', 'I'          ;
 CHAR 'L'               ; Encoded as:   " <134>LL."
 CHAR 'L'
 CHAR '.'
 EQUB 0

 RTOK 122               ; Token 39:     "GALAKTISCHE KARTE{galaxy number}"
 CHAR 'E'               ;
 RTOK 1                 ; Encoded as:   "[122]E[1]{1}"
 CONT 1
 EQUB 0

 CHAR 'Z'               ; Token 40:     "ZIEL VERLOREN "
 CHAR 'I'               ;
 CHAR 'E'               ; Encoded as:   "ZIEL V<144>LO<142>N "
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

 RTOK 106               ; Token 41:     "RAKETE KLEMMT "
 CHAR ' '               ;
 CHAR 'K'               ; Encoded as:   "[106] K<129>MMT "
 TWOK 'L', 'E'
 CHAR 'M'
 CHAR 'M'
 CHAR 'T'
 CHAR ' '
 EQUB 0

 RTOK 31                ; Token 42:     "ENTFERNUNG"
 EQUB 0                 ;
                        ; Encoded as:   "[31]"

 CHAR 'S'               ; Token 43:     "ST"
 CHAR 'T'               ;
 EQUB 0                 ; Encoded as:   "ST"

 CHAR 'M'               ; Token 44:     "MENGE"
 TWOK 'E', 'N'          ;
 TWOK 'G', 'E'          ; Encoded as:   "M<146><131>"
 EQUB 0

 CHAR 'V'               ; Token 45:     "VERKAUFEN À"
 TWOK 'E', 'R'          ;
 CHAR 'K'               ; Encoded as:   "V<144>KAUF<146> ""
 CHAR 'A'
 CHAR 'U'
 CHAR 'F'
 TWOK 'E', 'N'
 CHAR ' '
 CHAR '"'
 EQUB 0

 CHAR 'K'               ; Token 46:     "KARGO{sentence case}"
 TWOK 'A', 'R'          ;
 CHAR 'G'               ; Encoded as:   "K<138>GO{6}"
 CHAR 'O'
 CONT 6
 EQUB 0

 RTOK 25                ; Token 47:     "SCHIFF AUSRÜSTEN"
 CHAR ' '               ;
 CHAR 'A'               ; Encoded as:   "[25] A<136>R][43]<146>"
 TWOK 'U', 'S'
 CHAR 'R'
 CHAR ']'
 RTOK 43
 TWOK 'E', 'N'
 EQUB 0

 CHAR 'N'               ; Token 48:     "NAHRUNG"
 CHAR 'A'               ;
 CHAR 'H'               ; Encoded as:   "NAHRUNG"
 CHAR 'R'
 CHAR 'U'
 CHAR 'N'
 CHAR 'G'
 EQUB 0

 TWOK 'T', 'E'          ; Token 49:     "TEXTILIEN"
 CHAR 'X'               ;
 TWOK 'T', 'I'          ; Encoded as:   "<156>X<151>LI<146>"
 CHAR 'L'
 CHAR 'I'
 TWOK 'E', 'N'
 EQUB 0

 TWOK 'R', 'A'          ; Token 50:     "RADIOAKTIVES"
 TWOK 'D', 'I'          ;
 CHAR 'O'               ; Encoded as:   "<148><141>OAK<151>V<137>"
 CHAR 'A'
 CHAR 'K'
 TWOK 'T', 'I'
 CHAR 'V'
 TWOK 'E', 'S'
 EQUB 0

 RTOK 94                ; Token 51:     "ROBOTSKLAVEN"
 CHAR 'B'               ;
 CHAR 'O'               ; Encoded as:   "[94]BOTSK<149>V<146>"
 CHAR 'T'
 CHAR 'S'
 CHAR 'K'
 TWOK 'L', 'A'
 CHAR 'V'
 TWOK 'E', 'N'
 EQUB 0

 TWOK 'G', 'E'          ; Token 52:     "GETRÄNKE"
 CHAR 'T'               ;
 CHAR 'R'               ; Encoded as:   "<131>TR[NKE"
 CHAR '['
 CHAR 'N'
 CHAR 'K'
 CHAR 'E'
 EQUB 0

 CHAR 'L'               ; Token 53:     "LUXUSGÜTER"
 CHAR 'U'               ;
 CHAR 'X'               ; Encoded as:   "LUX<136>G]T<144>"
 TWOK 'U', 'S'
 CHAR 'G'
 CHAR ']'
 CHAR 'T'
 TWOK 'E', 'R'
 EQUB 0

 CHAR 'S'               ; Token 54:     "SELTENES"
 CHAR 'E'               ;
 CHAR 'L'               ; Encoded as:   "SELT<146><137>"
 CHAR 'T'
 TWOK 'E', 'N'
 TWOK 'E', 'S'
 EQUB 0

 RTOK 91                ; Token 55:     "COMPUTER"
 CHAR 'P'               ;
 CHAR 'U'               ; Encoded as:   "[91]PUT<144>"
 CHAR 'T'
 TWOK 'E', 'R'
 EQUB 0

 TWOK 'M', 'A'          ; Token 56:     "MASCHINEN"
 CHAR 'S'               ;
 CHAR 'C'               ; Encoded as:   "<139>SCH<140><146>"
 CHAR 'H'
 TWOK 'I', 'N'
 TWOK 'E', 'N'
 EQUB 0

 TWOK 'L', 'E'          ; Token 57:     "LEGIERUNGEN"
 CHAR 'G'               ;
 CHAR 'I'               ; Encoded as:   "<129>GI<144>UN<131>N"
 TWOK 'E', 'R'
 CHAR 'U'
 CHAR 'N'
 TWOK 'G', 'E'
 CHAR 'N'
 EQUB 0

 CHAR 'F'               ; Token 58:     "FEUERWAFFEN"
 CHAR 'E'               ;
 CHAR 'U'               ; Encoded as:   "FEU<144>WAFF<146>"
 TWOK 'E', 'R'
 CHAR 'W'
 CHAR 'A'
 CHAR 'F'
 CHAR 'F'
 TWOK 'E', 'N'
 EQUB 0

 CHAR 'P'               ; Token 59:     "PELZE"
 CHAR 'E'               ;
 CHAR 'L'               ; Encoded as:   "PELZE"
 CHAR 'Z'
 CHAR 'E'
 EQUB 0

 CHAR 'M'               ; Token 60:     "MINERALIEN"
 TWOK 'I', 'N'          ;
 TWOK 'E', 'R'          ; Encoded as:   "M<140><144>ALI<146>"
 CHAR 'A'
 CHAR 'L'
 CHAR 'I'
 TWOK 'E', 'N'
 EQUB 0

 CHAR 'G'               ; Token 61:     "GOLD"
 CHAR 'O'               ;
 CHAR 'L'               ; Encoded as:   "GOLD"
 CHAR 'D'
 EQUB 0

 CHAR 'P'               ; Token 62:     "PLATIN"
 CHAR 'L'               ;
 TWOK 'A', 'T'          ; Encoded as:   "PL<145><140>"
 TWOK 'I', 'N'
 EQUB 0

 TWOK 'E', 'D'          ; Token 63:     "EDELSTEINE"
 CHAR 'E'               ;
 CHAR 'L'               ; Encoded as:   "<152>ELS<156><140>E"
 CHAR 'S'
 TWOK 'T', 'E'
 TWOK 'I', 'N'
 CHAR 'E'
 EQUB 0

 CHAR 'F'               ; Token 64:     "FREMDWAREN"
 TWOK 'R', 'E'          ;
 CHAR 'M'               ; Encoded as:   "F<142>MDW<138><146>"
 CHAR 'D'
 CHAR 'W'
 TWOK 'A', 'R'
 TWOK 'E', 'N'
 EQUB 0

 EQUB 0                 ; Token 65:     ""
                        ;
                        ; Encoded as:   ""

 CHAR ' '               ; Token 66:     " CR"
 CHAR 'C'               ;
 CHAR 'R'               ; Encoded as:   " CR"
 EQUB 0

 CHAR 'G'               ; Token 67:     "GROßE"
 RTOK 94                ;
 CHAR '^'               ; Encoded as:   "G[94]^E"
 CHAR 'E'
 EQUB 0

 RTOK 142               ; Token 68:     "GEFÄHRLICHE"
 CHAR 'E'               ;
 EQUB 0                 ; Encoded as:   "[142]E"

 CHAR 'K'               ; Token 69:     "KLEINE"
 TWOK 'L', 'E'          ;
 TWOK 'I', 'N'          ; Encoded as:   "K<129><140>E"
 CHAR 'E'
 EQUB 0

 CHAR 'G'               ; Token 70:     "GRÜNE"
 CHAR 'R'               ;
 CHAR ']'               ; Encoded as:   "GR]NE"
 CHAR 'N'
 CHAR 'E'
 EQUB 0

 RTOK 94                ; Token 71:     "ROTE"
 TWOK 'T', 'E'          ;
 EQUB 0                 ; Encoded as:   "[94]<156>"

 TWOK 'G', 'E'          ; Token 72:     "GELBE"
 CHAR 'L'               ;
 TWOK 'B', 'E'          ; Encoded as:   "<131>L<147>"
 EQUB 0

 CHAR 'B'               ; Token 73:     "BLAUE"
 TWOK 'L', 'A'          ;
 CHAR 'U'               ; Encoded as:   "B<149>UE"
 CHAR 'E'
 EQUB 0

 CHAR 'S'               ; Token 74:     "SCHWARZE"
 CHAR 'C'               ;
 CHAR 'H'               ; Encoded as:   "SCHW<138>ZE"
 CHAR 'W'
 TWOK 'A', 'R'
 CHAR 'Z'
 CHAR 'E'
 EQUB 0

 RTOK 136               ; Token 75:     "HARMLOSE"
 CHAR 'E'               ;
 EQUB 0                 ; Encoded as:   "[136]E"

 CHAR 'G'               ; Token 76:     "GLITSCHIGE"
 CHAR 'L'               ;
 CHAR 'I'               ; Encoded as:   "GLITSCHI<131>"
 CHAR 'T'
 CHAR 'S'
 CHAR 'C'
 CHAR 'H'
 CHAR 'I'
 TWOK 'G', 'E'
 EQUB 0

 CHAR 'W'               ; Token 77:     "WANZENÄUGIGE"
 TWOK 'A', 'N'          ;
 CHAR 'Z'               ; Encoded as:   "W<155>Z<146>[UGI<131>"
 TWOK 'E', 'N'
 CHAR '['
 CHAR 'U'
 CHAR 'G'
 CHAR 'I'
 TWOK 'G', 'E'
 EQUB 0

 TWOK 'G', 'E'          ; Token 78:     "GEHÖRNTE"
 CHAR 'H'               ;
 CHAR '\'               ; Encoded as:   "<131>H\RN<156>"
 CHAR 'R'
 CHAR 'N'
 TWOK 'T', 'E'
 EQUB 0

 CHAR 'K'               ; Token 79:     "KNOCHIGE"
 CHAR 'N'               ;
 CHAR 'O'               ; Encoded as:   "KNOCHI<131>"
 CHAR 'C'
 CHAR 'H'
 CHAR 'I'
 TWOK 'G', 'E'
 EQUB 0

 TWOK 'D', 'I'          ; Token 80:     "DICKE"
 CHAR 'C'               ;
 CHAR 'K'               ; Encoded as:   "<141>CKE"
 CHAR 'E'
 EQUB 0

 CHAR 'P'               ; Token 81:     "PELZIGE"
 CHAR 'E'               ;
 CHAR 'L'               ; Encoded as:   "PELZI<131>"
 CHAR 'Z'
 CHAR 'I'
 TWOK 'G', 'E'
 EQUB 0

 CONT 6                 ; Token 82:     "{sentence case}NAGETIERE"
 CHAR 'N'               ;
 CHAR 'A'               ; Encoded as:   "{6}NA<131><151>E<142>"
 TWOK 'G', 'E'
 TWOK 'T', 'I'
 CHAR 'E'
 TWOK 'R', 'E'
 EQUB 0

 CONT 6                 ; Token 83:     "{sentence case}FRÖSCHE"
 CHAR 'F'               ;
 CHAR 'R'               ; Encoded as:   "{6}FR\SCHE)
 CHAR '\'
 CHAR 'S'
 CHAR 'C'
 CHAR 'H'
 CHAR 'E'
 EQUB 0

 CONT 6                 ; Token 84:     "{sentence case}ECHSEN"
 CHAR 'E'               ;
 CHAR 'C'               ; Encoded as:   "{6}ECHS<146>)
 CHAR 'H'
 CHAR 'S'
 TWOK 'E', 'N'
 EQUB 0

 CONT 6                 ; Token 85:     "{sentence case}HUMMER"
 CHAR 'H'               ;
 CHAR 'U'               ; Encoded as:   "{6}HUMM<144>"
 CHAR 'M'
 CHAR 'M'
 TWOK 'E', 'R'
 EQUB 0

 CONT 6                 ; Token 86:     "{sentence case}VÖGEL"
 CHAR 'V'               ;
 CHAR '\'               ; Encoded as:   "{6}V\<131>L"
 TWOK 'G', 'E'
 CHAR 'L'
 EQUB 0

 CONT 6                 ; Token 87:     "{sentence case}HUMANOIDS"
 CHAR 'H'               ;
 CHAR 'U'               ; Encoded as:   "{6}HU<139>NOIDS"
 TWOK 'M', 'A'
 CHAR 'N'
 CHAR 'O'
 CHAR 'I'
 CHAR 'D'
 CHAR 'S'
 EQUB 0

 CONT 6                 ; Token 88:     "{sentence case}KATZEN"
 CHAR 'K'               ;
 TWOK 'A', 'T'          ; Encoded as:   "{6}K<145>Z<146>"
 CHAR 'Z'
 TWOK 'E', 'N'
 EQUB 0

 CONT 6                 ; Token 89:     "{sentence case}INSEKTEN"
 TWOK 'I', 'N'          ;
 CHAR 'S'               ; Encoded as:   "{6}<140>SEKT<146>"
 CHAR 'E'
 CHAR 'K'
 CHAR 'T'
 TWOK 'E', 'N'
 EQUB 0

 TWOK 'R', 'A'          ; Token 90:     "RADIUS"
 TWOK 'D', 'I'          ;
 TWOK 'U', 'S'          ; Encoded as:   "<148><141><136>"
 EQUB 0

 CHAR 'C'               ; Token 91:     "COM"
 CHAR 'O'               ;
 CHAR 'M'               ; Encoded as:   "COM"
 EQUB 0

 CHAR 'K'               ; Token 92:     "KOMMANDANT"
 CHAR 'O'               ;
 CHAR 'M'               ; Encoded as:   "KOM<139>ND<155>T"
 TWOK 'M', 'A'
 CHAR 'N'
 CHAR 'D'
 TWOK 'A', 'N'
 CHAR 'T'
 EQUB 0

 CHAR ' '               ; Token 93:     " VERNICHTET"
 CHAR 'V'               ;
 TWOK 'E', 'R'          ; Encoded as:   " V<144>NICH<156>T"
 CHAR 'N'
 CHAR 'I'
 CHAR 'C'
 CHAR 'H'
 TWOK 'T', 'E'
 CHAR 'T'
 EQUB 0

 CHAR 'R'               ; Token 94:     "RO"
 CHAR 'O'               ;
 EQUB 0                 ; Encoded as:   "RO"

 RTOK 26                ; Token 95:     "PRODUKT        PREIS-
 CHAR ' '               ;                  MENGE                 EINHEIT"
 CHAR ' '               ;
 CHAR ' '               ; Encoded as:   "[26]        P<142><157>-  [44]
 CHAR ' '               ;                                 [14]"
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

 CHAR 'V'               ; Token 96:     "VORN"
 TWOK 'O', 'R'          ;
 CHAR 'N'               ; Encoded as:   "V<153>N"
 EQUB 0

 CHAR 'H'               ; Token 97:     "HINTEN"
 TWOK 'I', 'N'          ;
 CHAR 'T'               ; Encoded as:   "H<140>T<146>"
 TWOK 'E', 'N'
 EQUB 0

 CHAR 'L'               ; Token 98:     "LINKS"
 TWOK 'I', 'N'          ;
 CHAR 'K'               ; Encoded as:   "L<140>KS"
 CHAR 'S'
 EQUB 0

 TWOK 'R', 'E'          ; Token 99:     "RECHTS"
 CHAR 'C'               ;
 CHAR 'H'               ; Encoded as:   "<142>CHTS"
 CHAR 'T'
 CHAR 'S'
 EQUB 0

 RTOK 121               ; Token 100:    "ENERGIE NIEDRIG {beep}"
 CHAR 'N'               
 CHAR 'I'               ; Encoded as:   "[121]NI<152><158>G {7}"
 TWOK 'E', 'D'
 TWOK 'R', 'I'
 CHAR 'G'
 CHAR ' '
 CONT 7
 EQUB 0

 CHAR 'B'               ; Token 101:    "BRAVO KOMMANDANT!"
 TWOK 'R', 'A'          ;
 CHAR 'V'               ; Encoded as:   "B<148>VO [92]!"
 CHAR 'O'
 CHAR ' '
 RTOK 92
 CHAR '!'
 EQUB 0

 CHAR 'E'               ; Token 102:    "EXTRA "
 CHAR 'X'               ;
 CHAR 'T'               ; Encoded as:   "EXT<148> "
 TWOK 'R', 'A'
 CHAR ' '
 EQUB 0

 CHAR 'P'               ; Token 103:    "PULSLASER"
 CHAR 'U'               ;
 CHAR 'L'               ; Encoded as:   "PULS<149>S<144>"
 CHAR 'S'
 TWOK 'L', 'A'
 CHAR 'S'
 TWOK 'E', 'R'
 EQUB 0

 RTOK 43                ; Token 104:    "STRAHLENLASER"
 TWOK 'R', 'A'          
 CHAR 'H'               ; Encoded as:   "[43]<148>H<129>N<149>S<144>"
 TWOK 'L', 'E'
 CHAR 'N'
 TWOK 'L', 'A'
 CHAR 'S'
 TWOK 'E', 'R'
 EQUB 0

 CHAR 'T'               ; Token 105:    "TREIBSTOFF"
 TWOK 'R', 'E'          
 CHAR 'I'               ; Encoded as:   "T<142>IB[43]OFF"
 CHAR 'B'
 RTOK 43
 CHAR 'O'
 CHAR 'F'
 CHAR 'F'
 EQUB 0

 TWOK 'R', 'A'          ; Token 106:    "RAKETE"
 CHAR 'K'               
 CHAR 'E'               ; Encoded as:   "<148>KE<156>"
 TWOK 'T', 'E'
 EQUB 0

 CHAR 'G'               ; Token 107:    "GROßER KARGORAUM"
 RTOK 94                
 CHAR '^'               ; Encoded as:   "G[94]^<144> K<138>GO<148>UM"
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

 CHAR 'E'               ; Token 108:    "E.C.M.SYSTEM"
 CHAR '.'               
 CHAR 'C'               ; Encoded as:   "E.C.M.SYS<156>M"
 CHAR '.'
 CHAR 'M'
 CHAR '.'
 CHAR 'S'
 CHAR 'Y'
 CHAR 'S'
 TWOK 'T', 'E'
 CHAR 'M'
 EQUB 0

 RTOK 102               ; Token 109:    "EXTRA PULSLASER"
 RTOK 103               
 EQUB 0                 ; Encoded as:   "[102][103]"

 RTOK 102               ; Token 110:    "EXTRA STRAHLENLASER"
 RTOK 104               ;
 EQUB 0                 ; Encoded as:   "[102][104]"

 RTOK 105               ; Token 111:    "TREIBSTOFFSCHAUFELN"
 CHAR 'S'               
 CHAR 'C'               ; Encoded as:   "[105]SCHAUFELN"
 CHAR 'H'
 CHAR 'A'
 CHAR 'U'
 CHAR 'F'
 CHAR 'E'
 CHAR 'L'
 CHAR 'N'
 EQUB 0

 CHAR 'F'               ; Token 112:    "FLUCHTKAPSEL"
 CHAR 'L'               
 CHAR 'U'               ; Encoded as:   "FLUCHTKAPSEL"
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

 TWOK 'E', 'N'          ; Token 113:    "ENERGIEBOMBE"
 TWOK 'E', 'R'          ;
 CHAR 'G'               ; Encoded as:   "<146><144>GIEBOM<147>"
 CHAR 'I'
 CHAR 'E'
 CHAR 'B'
 CHAR 'O'
 CHAR 'M'
 TWOK 'B', 'E'
 EQUB 0

 TWOK 'E', 'N'          ; Token 114:    "ENERGIE-EINHEIT"
 TWOK 'E', 'R'          ;
 CHAR 'G'               ; Encoded as:   "<146><144>GIE-[14]"
 CHAR 'I'
 CHAR 'E'
 CHAR '-'
 RTOK 14
 EQUB 0

 CHAR 'D'               ; Token 115:    "DOCK COMPUTER"
 CHAR 'O'               ;
 CHAR 'C'               ; Encoded as:   "DOCK [55]"
 CHAR 'K'
 CHAR ' '
 RTOK 55
 EQUB 0

 CHAR 'G'               ; Token 116:    "GALAKT. HYPERRAUM"
 CHAR 'A'               ;
 TWOK 'L', 'A'          ; Encoded as:   "GA<149>KT. HYP<144><148>UM"
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

 CHAR 'M'               ; Token 117:    "MILIT. LASER"
 CHAR 'I'               ;
 CHAR 'L'               ; Encoded as:   "MILIT.[27]"
 CHAR 'I'
 CHAR 'T'
 CHAR '.'
 RTOK 27
 EQUB 0

 CHAR 'G'               ; Token 118:    "GRUBENLASER "
 CHAR 'R'               ;
 CHAR 'U'               ; Encoded as:   "GRUB<146><149>S<144> "
 CHAR 'B'
 TWOK 'E', 'N'
 TWOK 'L', 'A'
 CHAR 'S'
 TWOK 'E', 'R'
 CHAR ' '
 EQUB 0

 CONT 6                 ; Token 119:    "{sentence case}BARGELD:{cash} CR{cr}
 RTOK 37                ;               "
 CHAR ':'               ;
 CONT 0                 ; Encoded as:   "{6}[37]:{0}"
 EQUB 0

 TWOK 'A', 'N'          ; Token 120:    "ANKOMMENDE RAKETE"
 CHAR 'K'               ;
 CHAR 'O'               ; Encoded as:   "<155>KOMM<146>DE [106]"
 CHAR 'M'
 CHAR 'M'
 TWOK 'E', 'N'
 CHAR 'D'
 CHAR 'E'
 CHAR ' '
 RTOK 106
 EQUB 0

 TWOK 'E', 'N'          ; Token 121:    "ENERGIE "
 TWOK 'E', 'R'          ;
 CHAR 'G'               ; Encoded as:   "<146><144>GIE "
 CHAR 'I'
 CHAR 'E'
 CHAR ' '
 EQUB 0

 CHAR 'G'               ; Token 122:    "GALAKTISCH"
 CHAR 'A'               ;
 TWOK 'L', 'A'          ; Encoded as:   "GA<149>K<151>SCH"
 CHAR 'K'
 TWOK 'T', 'I'
 CHAR 'S'
 CHAR 'C'
 CHAR 'H'
 EQUB 0

 RTOK 115               ; Token 123:    "DOCK COMPUTER AN"
 CHAR ' '               ;
 TWOK 'A', 'N'          ; Encoded as:   "[115] <155>"
 EQUB 0

 CHAR 'A'               ; Token 124:    "ALLE"
 CHAR 'L'               ;
 TWOK 'L', 'E'          ; Encoded as:   "AL<129>"
 EQUB 0

 TWOK 'L', 'E'          ; Token 125:    "LEGALSTATUS:"
 CHAR 'G'               ;
 CHAR 'A'               ; Encoded as:   "<129>GAL[43]<145><136>:"
 CHAR 'L'
 RTOK 43
 TWOK 'A', 'T'
 TWOK 'U', 'S'
 CHAR ':'
 EQUB 0

 RTOK 92                ; Token 126:    "KOMMANDANT {commander name}{cr}
 CHAR ' '               ;                {cr}
 CONT 4                 ;                {cr}
 CONT 12                ;                {sentence case}{sentence case}
 CONT 12                ;                GEGENWÄRTIGES {sentence case}SYSTEM{tab
 CONT 12                ;                to column 23}:{current system name}{cr}
 CONT 6                 ;                {sentence case}HYPERRAUMSYSTEM{tab to
 CONT 6                 ;                column 23}:{selected system name}{cr}
 TWOK 'G', 'E'          ;                ZUSTAND{tab to column 23}:"
 TWOK 'G', 'E'          ;
 CHAR 'N'               ; Encoded as:   "[92] {4}{12}{12}{12}{6}{6}<131><131>NW[
 CHAR 'W'               ;                R<151><131>S [5]{9}{2}{12}{6}HYP<144>
 CHAR '['               ;                <148>UMSYS<156>M{9}{3}{12}Z<136>T<155>D
 CHAR 'R'               ;                {9}"
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

 CHAR 'W'               ; Token 127:    "WARE"
 TWOK 'A', 'R'          ;
 CHAR 'E'               ; Encoded as:   "W<138>E
 EQUB 0

 EQUB 0                 ; Token 128:    ""
                        ;
                        ; Encoded as:   ""

 CHAR 'I'               ; Token 129:    "IE"
 CHAR 'E'               ;
 EQUB 0                 ; Encoded as:   "IE"

 CHAR 'W'               ; Token 130:    "WERTUNG"
 TWOK 'E', 'R'          ;
 CHAR 'T'               ; Encoded as:   "W<144>TUNG"
 CHAR 'U'
 CHAR 'N'
 CHAR 'G'
 EQUB 0

 CHAR ' '               ; Token 131:    " AN "
 TWOK 'A', 'N'          ;
 CHAR ' '               ; Encoded as:   " <155> "
 EQUB 0

 CONT 12                ; Token 132:    "{cr}{all caps}{sentence case}
 CONT 8                 ;                AUSRÜSTUNG:{sentence case}
 CONT 6                 ;
 CHAR 'A'               ; Encoded as:   "{12}{8}{6}A<136>R][43]UNG:{6}"
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

 CHAR 'S'               ; Token 133:    "SAUBER"
 CHAR 'A'               ;
 CHAR 'U'               ; Encoded as:   "SAUB<144>"
 CHAR 'B'
 TWOK 'E', 'R'
 EQUB 0

 RTOK 43                ; Token 134:    "STRAFTÄTER"
 TWOK 'R', 'A'          ;
 CHAR 'F'               ; Encoded as:   "[43]<148>FT[T<144>"
 CHAR 'T'
 CHAR '['
 CHAR 'T'
 TWOK 'E', 'R'
 EQUB 0

 CHAR 'F'               ; Token 135:    "FLÜCHTLING"
 CHAR 'L'               ;
 CHAR ']'               ; Encoded as:   "FL]CHTL<140>G"
 CHAR 'C'
 CHAR 'H'
 CHAR 'T'
 CHAR 'L'
 TWOK 'I', 'N'
 CHAR 'G'
 EQUB 0

 CHAR 'H'               ; Token 136:    "HARMLOS"
 RTOK 138               ;
 CHAR 'L'               ; Encoded as:   "H[138]LOS"
 CHAR 'O'
 CHAR 'S'
 EQUB 0

 CHAR ']'               ; Token 137:    "ÜBERWIEGEND HARMLOS"
 CHAR 'B'               ;
 TWOK 'E', 'R'          ; Encoded as:   "]B<144>WIE<131>ND [136]"
 CHAR 'W'
 CHAR 'I'
 CHAR 'E'
 TWOK 'G', 'E'
 CHAR 'N'
 CHAR 'D'
 CHAR ' '
 RTOK 136
 EQUB 0

 TWOK 'A', 'R'          ; Token 138:    "ARM"
 CHAR 'M'               ;
 EQUB 0                 ; Encoded as:   "<138>M"

 CHAR 'D'               ; Token 139:    "DURCHSCHNITTLICH"
 CHAR 'U'               ;
 CHAR 'R'               ; Encoded as:   "DURCHSCHNITTLICH"
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

 CHAR ']'               ; Token 140:    "ÜBERDURCHSCHNITTLICH "
 CHAR 'B'               ;
 TWOK 'E', 'R'          ; Encoded as:   "]B<144>[139] "
 RTOK 139
 CHAR ' '
 EQUB 0

 CHAR 'K'               ; Token 141:    "KOMPETENT"
 CHAR 'O'               ;
 CHAR 'M'               ; Encoded as:   "KOMPET<146>T"
 CHAR 'P'
 CHAR 'E'
 CHAR 'T'
 TWOK 'E', 'N'
 CHAR 'T'
 EQUB 0

 TWOK 'G', 'E'          ; Token 142:    "GEFÄHRLICH"
 CHAR 'F'               ;
 CHAR '['               ; Encoded as:   "<131>F[HRLICH"
 CHAR 'H'
 CHAR 'R'
 CHAR 'L'
 CHAR 'I'
 CHAR 'C'
 CHAR 'H'
 EQUB 0

 CHAR 'T'               ; Token 143:    "TÖDLICH"
 CHAR '\'               ;
 CHAR 'D'               ; Encoded as:   "T\DLICH"
 CHAR 'L'
 CHAR 'I'
 CHAR 'C'
 CHAR 'H'
 EQUB 0

 CHAR '-'               ; Token 144:    "---- E L I T E ----"
 CHAR '-'               ;
 CHAR '-'               ; Encoded as:   "---- E L I T E ----"
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

 TWOK 'A', 'N'          ; Token 145:    "ANWESEND"
 CHAR 'W'               ;
 TWOK 'E', 'S'          ; Encoded as:   "<155>W<137><146>D"
 TWOK 'E', 'N'
 CHAR 'D'
 EQUB 0

 CONT 8                 ; Token 146:    "{all caps}SPIEL ZU ENDE"
 CHAR 'S'               ;
 CHAR 'P'               ; Encoded as:   "{8}SPIEL ZU <146>DE"
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

 CHAR '6'               ; Token 147:    "60 STRAFSEKUNDEN"
 CHAR '0'               ;
 CHAR ' '               ; Encoded as:   "60 [43]<148>FSEKUND<146>"
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
                        ;
                        ; Encoded as:   ""

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

 RTOK 105               ; Token 0:      "LE FUEL {beep}"
 CHAR ' '               ;
 CONT 7                 ; Encoded as:   "[105] {7}"
 EQUB 0

 CHAR ' '               ; Token 1:      " CARTE"
 CHAR 'C'               ;
 TWOK 'A', 'R'          ; Encoded as:   " C<138><156>"
 TWOK 'T', 'E'
 EQUB 0

 CHAR 'G'               ; Token 2:      "GOUVERNEMENT"
 CHAR 'O'               ;
 CHAR 'U'               ; Encoded as:   "GOUV<144>NEM<146>T"
 CHAR 'V'
 TWOK 'E', 'R'
 CHAR 'N'
 CHAR 'E'
 CHAR 'M'
 TWOK 'E', 'N'
 CHAR 'T'
 EQUB 0

 CHAR 'D'               ; Token 3:      "DONNÉES SUR {selected system name}"
 TWOK 'O', 'N'          ;
 CHAR 'N'               ; Encoded as:   "D<159>N<<137>[131]{3}"
 CHAR '<'
 TWOK 'E', 'S'
 RTOK 131
 CONT 3
 EQUB 0

 TWOK 'I', 'N'          ; Token 4:      "INVENTAIRE{cr}
 CHAR 'V'               ;               "
 TWOK 'E', 'N'          ;
 CHAR 'T'               ; Encoded as:   "<140>V<146>TAI<142>{12}"
 CHAR 'A'
 CHAR 'I'
 TWOK 'R', 'E'
 CONT 12
 EQUB 0

 CHAR 'S'               ; Token 5:      "SYSTÈME"
 CHAR 'Y'               ;
 RTOK 43                ; Encoded as:   "SY[43]=ME"
 CHAR '='
 CHAR 'M'
 CHAR 'E'
 EQUB 0

 CHAR 'P'               ; Token 6:      "PRIX"
 TWOK 'R', 'I'          ;
 CHAR 'X'               ; Encoded as:   "P<158>X"
 EQUB 0

 CONT 2                 ; Token 7:      "{current system name} PRIX DU MARCHÉ "
 CHAR ' '               ;
 RTOK 6                 ; Encoded as:   "{2} [6] DU M<138>CH< "
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

 TWOK 'I', 'N'          ; Token 8:      "INDUSTRIELLE"
 CHAR 'D'               ;
 TWOK 'U', 'S'          ; Encoded as:   "<140>D<136>T<158>EL<129>"
 CHAR 'T'
 TWOK 'R', 'I'
 CHAR 'E'
 CHAR 'L'
 TWOK 'L', 'E'
 EQUB 0

 CHAR 'A'               ; Token 9:      "AGRICOLE"
 CHAR 'G'               ;
 TWOK 'R', 'I'          ; Encoded as:   "AG<158>CO<129>)
 CHAR 'C'
 CHAR 'O'
 TWOK 'L', 'E'
 EQUB 0

 TWOK 'R', 'I'          ; Token 10:     "RICHE "
 CHAR 'C'               ;
 CHAR 'H'               ; Encoded as:   "<158>CHE "
 CHAR 'E'
 CHAR ' '
 EQUB 0

 RTOK 139               ; Token 11:     "MOYENNE "
 CHAR 'N'               ;
 CHAR 'E'               ; Encoded as:   "[139]NE )
 CHAR ' '
 EQUB 0

 CHAR 'P'               ; Token 12:     "PAUVRE "
 CHAR 'A'               ;
 CHAR 'U'               ; Encoded as:   "PAUV<142> "
 CHAR 'V'
 TWOK 'R', 'E'
 CHAR ' '
 EQUB 0

 CHAR 'S'               ; Token 13:     "SURTOUT "
 CHAR 'U'               ;
 CHAR 'R'               ; Encoded as:   "SUR[124] "
 RTOK 124
 CHAR ' '
 EQUB 0

 CHAR 'U'               ; Token 14:     "UNITE"
 CHAR 'N'               
 CHAR 'I'               ; Encoded as:   "UNI<156>"
 TWOK 'T', 'E'
 EQUB 0

 CHAR ' '               ; Token 15:     " "
 EQUB 0                 ;
                        ; Encoded as:   " "

 CHAR 'P'               ; Token 16:     "PLEIN"
 TWOK 'L', 'E'          ;
 TWOK 'I', 'N'          ; Encoded as:   "P<129><140>"
 EQUB 0

 TWOK 'A', 'N'          ; Token 17:     "ANARCHIE"
 TWOK 'A', 'R'          ;
 CHAR 'C'               ; Encoded as:   "<155><138>CHIE"
 CHAR 'H'
 CHAR 'I'
 CHAR 'E'
 EQUB 0

 CHAR 'F'               ; Token 18:     "FÉODAL"
 CHAR '<'               ;
 CHAR 'O'               ; Encoded as:   "F<ODAL"
 CHAR 'D'
 CHAR 'A'
 CHAR 'L'
 EQUB 0

 CHAR 'P'               ; Token 19:     "PLURI-GOUVER."
 CHAR 'L'               ;
 CHAR 'U'               ; Encoded as:   "PLU<158>-GOUV<144>."
 TWOK 'R', 'I'
 CHAR '-'
 CHAR 'G'
 CHAR 'O'
 CHAR 'U'
 CHAR 'V'
 TWOK 'E', 'R'
 CHAR '.'
 EQUB 0

 TWOK 'D', 'I'          ; Token 20:     "DICTATURE"
 CHAR 'C'               ;
 CHAR 'T'               ; Encoded as:   "<141>CT<145>U<142>"
 TWOK 'A', 'T'
 CHAR 'U'
 TWOK 'R', 'E'
 EQUB 0

 RTOK 91                ; Token 21:     "COMMUNISTE"
 CHAR 'M'               ;
 CHAR 'U'               ; Encoded as:   "[91]MUN<157><156>"
 CHAR 'N'
 TWOK 'I', 'S'
 TWOK 'T', 'E'
 EQUB 0

 CHAR 'C'               ; Token 22:     "CONFÉDÉRATION"
 TWOK 'O', 'N'          ;
 CHAR 'F'               ; Encoded as:   "C<159>F<D<R<145>I<159>"
 CHAR '<'
 CHAR 'D'
 CHAR '<'
 CHAR 'R'
 TWOK 'A', 'T'
 CHAR 'I'
 TWOK 'O', 'N'
 EQUB 0

 CHAR 'D'               ; Token 23:     "DÉMOCRATIE"
 CHAR '<'               
 CHAR 'M'               ; Encoded as:   "D<MOCR<145>IE"
 CHAR 'O'
 CHAR 'C'
 CHAR 'R'
 TWOK 'A', 'T'
 CHAR 'I'
 CHAR 'E'
 EQUB 0

 CHAR '<'               ; Token 24:     "ÉTAT CORPORATISTE"
 CHAR 'T'               ;
 TWOK 'A', 'T'          ; Encoded as:   "<T<145> C<153>P<153><145><157><156>"
 CHAR ' '
 CHAR 'C'
 TWOK 'O', 'R'
 CHAR 'P'
 TWOK 'O', 'R'
 TWOK 'A', 'T'
 TWOK 'I', 'S'
 TWOK 'T', 'E'
 EQUB 0

 CHAR 'N'               ; Token 25:     "NAVIRE"
 CHAR 'A'               
 CHAR 'V'               ; Encoded as:   "NAVI<142>"
 CHAR 'I'
 TWOK 'R', 'E'
 EQUB 0

 CHAR 'P'               ; Token 26:     "PRODUIT"
 CHAR 'R'               ;
 CHAR 'O'               ; Encoded as:   "PRODUIT"
 CHAR 'D'
 CHAR 'U'
 CHAR 'I'
 CHAR 'T'
 EQUB 0

 TWOK 'L', 'A'          ; Token 27:     "LASER"
 CHAR 'S'               ;
 TWOK 'E', 'R'          ; Encoded as:   "<149>S<144>"
 EQUB 0

 CHAR 'H'               ; Token 28:     "HUMAINS COLONIAUX"
 CHAR 'U'               ;
 TWOK 'M', 'A'          ; Encoded as:   "HU<139><140>S COL<159>IAUX"
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

 RTOK 116               ; Token 29:     "INTERGALACTIQUE "
 CHAR ' '               ;
 EQUB 0                 ; Encoded as:   "[116] "

 CHAR 'C'               ; Token 30:     "CARTE LOCALE"
 TWOK 'A', 'R'          ;
 TWOK 'T', 'E'          ; Encoded as:   "C<138><156> LOCA<129>"
 CHAR ' '
 CHAR 'L'
 CHAR 'O'
 CHAR 'C'
 CHAR 'A'
 TWOK 'L', 'E'
 EQUB 0

 TWOK 'D', 'I'          ; Token 31:     "DISTANCE
 RTOK 43                ;
 TWOK 'A', 'N'          ; Encoded as:   "<141>[43]<155><133>"
 TWOK 'C', 'E'
 EQUB 0

 CHAR 'P'               ; Token 32:     "POPULATION"
 CHAR 'O'               ;
 CHAR 'P'               ; Encoded as:   "POPUL<145>I<159>"
 CHAR 'U'
 CHAR 'L'
 TWOK 'A', 'T'
 CHAR 'I'
 TWOK 'O', 'N'
 EQUB 0

 CONT 6                 ; Token 33:     "{sentence case}C.{sentence case}A."
 CHAR 'C'               ;
 CHAR '.'               ; Encoded as:   "{6}C.{6}A."
 CONT 6
 CHAR 'A'
 CHAR '.'
 EQUB 0

 CHAR '<'               ; Token 34:     "ÉCONOMIE"
 CHAR 'C'               ;
 TWOK 'O', 'N'          ; Encoded as:   "<C<159>OMIE"
 CHAR 'O'
 CHAR 'M'
 CHAR 'I'
 CHAR 'E'
 EQUB 0

 CHAR ' '               ; Token 35:     " {sentence case}A.{sentence case}LUM."
 CONT 6                 ;
 CHAR 'A'               ; Encoded as:   " {6}A.{6}LUM."
 CHAR '.'
 CONT 6
 CHAR 'L'
 CHAR 'U'
 CHAR 'M'
 CHAR '.'
 EQUB 0

 CHAR 'N'               ; Token 36:     "NIVEAU TECH."
 CHAR 'I'               ;
 TWOK 'V', 'E'          ; Encoded as:   "NI<150>AU <156>CH."
 CHAR 'A'
 CHAR 'U'
 CHAR ' '
 TWOK 'T', 'E'
 CHAR 'C'
 CHAR 'H'
 CHAR '.'
 EQUB 0

 TWOK 'A', 'R'          ; Token 37:     "ARGENT"
 TWOK 'G', 'E'          ;
 CHAR 'N'               ; Encoded as:   "<138><131>NT"
 CHAR 'T'
 EQUB 0

 CHAR ' '               ; Token 38:     " BILLION"
 TWOK 'B', 'I'          ;
 CHAR 'L'               ; Encoded as:   " <134>LLI<159>"
 CHAR 'L'
 CHAR 'I'
 TWOK 'O', 'N'
 EQUB 0

 CHAR 'C'               ; Token 39:     "CARTE GALACTIQUE{galaxy number}"
 TWOK 'A', 'R'          ;
 TWOK 'T', 'E'          ; Encoded as:   "C<138><156> [122]{1}"
 CHAR ' '
 RTOK 122
 CONT 1
 EQUB 0

 CHAR 'C'               ; Token 40:     "CIBLE PERDUE "
 CHAR 'I'               ;
 CHAR 'B'               ; Encoded as:   "CIB[94]P<144>DUE "
 RTOK 94
 CHAR 'P'
 TWOK 'E', 'R'
 CHAR 'D'
 CHAR 'U'
 CHAR 'E'
 CHAR ' '
 EQUB 0

 RTOK 106               ; Token 41:     "MISSILE ENVOYEÉ "
 CHAR ' '               ;
 TWOK 'E', 'N'          ; Encoded as:   "[106] <146>VOYE< "
 CHAR 'V'
 CHAR 'O'
 CHAR 'Y'
 CHAR 'E'
 CHAR '<'
 CHAR ' '
 EQUB 0

 CHAR 'P'               ; Token 42:     "PORTÉE"
 TWOK 'O', 'R'          ;
 CHAR 'T'               ; Encoded as:   "P<153>T<E"
 CHAR '<'
 CHAR 'E'
 EQUB 0

 CHAR 'S'               ; Token 43:     "ST"
 CHAR 'T'               ;
 EQUB 0                 ; Encoded as:   "ST"

 RTOK 16                ; Token 44:     "PLEIN DE "
 CHAR ' '               ;
 CHAR 'D'               ; Encoded as:   "[16] DE "
 CHAR 'E'
 CHAR ' '
 EQUB 0

 CHAR 'S'               ; Token 45:     "SE"
 CHAR 'E'               ;
 EQUB 0                 ; Encoded as:   "SE"

 CHAR ' '               ; Token 46:     " CARGAISON{sentence case}"
 CHAR 'C'               ;
 TWOK 'A', 'R'          ; Encoded as:   " C<138>GAI<135>N{6}"
 CHAR 'G'
 CHAR 'A'
 CHAR 'I'
 TWOK 'S', 'O'
 CHAR 'N'
 CONT 6
 EQUB 0

 CHAR 'E'               ; Token 47:     "EQUIPEMENT"
 TWOK 'Q', 'U'          ;
 CHAR 'I'               ; Encoded as:   "E<154>IPEM<146>T"
 CHAR 'P'
 CHAR 'E'
 CHAR 'M'
 TWOK 'E', 'N'
 CHAR 'T'
 EQUB 0

 CHAR 'N'               ; Token 48:     "NOURRITURE"
 CHAR 'O'               ;
 CHAR 'U'               ; Encoded as:   "NOUR<158>TU<142>"
 CHAR 'R'
 TWOK 'R', 'I'
 CHAR 'T'
 CHAR 'U'
 TWOK 'R', 'E'
 EQUB 0

 TWOK 'T', 'E'          ; Token 49:     "TEXTILES"
 CHAR 'X'               ;
 TWOK 'T', 'I'          ; Encoded as:   "<156>X<151><129>S"
 TWOK 'L', 'E'
 CHAR 'S'
 EQUB 0

 TWOK 'R', 'A'          ; Token 50:     "RADIOACTIFS"
 TWOK 'D', 'I'          ;
 CHAR 'O'               ; Encoded as:   "<148><141>OAC<151>FS"
 CHAR 'A'
 CHAR 'C'
 TWOK 'T', 'I'
 CHAR 'F'
 CHAR 'S'
 EQUB 0

 TWOK 'E', 'S'          ; Token 51:     "ESCLAVE-ROBT"
 CHAR 'C'               ;
 TWOK 'L', 'A'          ; Encoded as:   "<137>C<149><150>-ROBT"
 TWOK 'V', 'E'
 CHAR '-'
 CHAR 'R'
 CHAR 'O'
 CHAR 'B'
 CHAR 'T'
 EQUB 0

 CHAR 'B'               ; Token 52:     "BOISSONS"
 CHAR 'O'               ;
 TWOK 'I', 'S'          ; Encoded as:   "BO<157><135>NS"
 TWOK 'S', 'O'
 CHAR 'N'
 CHAR 'S'
 EQUB 0

 CHAR 'P'               ; Token 53:     "PDTS DE LUXE"
 CHAR 'D'               ;
 CHAR 'T'               ; Encoded as:   "PDTS DE LU<130>"
 CHAR 'S'
 CHAR ' '
 CHAR 'D'
 CHAR 'E'
 CHAR ' '
 CHAR 'L'
 CHAR 'U'
 TWOK 'X', 'E'
 EQUB 0

 TWOK 'E', 'S'          ; Token 54:     "ESPÈCE RARE"
 CHAR 'P'               ;
 CHAR '='               ; Encoded as:   "<137>P=<133> R<138>E"
 TWOK 'C', 'E'
 CHAR ' '
 CHAR 'R'
 TWOK 'A', 'R'
 CHAR 'E'
 EQUB 0

 TWOK 'O', 'R'          ; Token 55:     "ORDINATEUR"
 CHAR 'D'               ;
 TWOK 'I', 'N'          ; Encoded as:   "<153>D<140><145>EUR"
 TWOK 'A', 'T'
 CHAR 'E'
 CHAR 'U'
 CHAR 'R'
 EQUB 0

 TWOK 'M', 'A'          ; Token 56:     "MACHINES"
 CHAR 'C'               ;
 CHAR 'H'               ; Encoded as:   "<139>CH<140><137>"
 TWOK 'I', 'N'
 TWOK 'E', 'S'
 EQUB 0

 CHAR 'A'               ; Token 57:     "ALLIAGES"
 CHAR 'L'               ;
 CHAR 'L'               ; Encoded as:   "ALLIA<131>S"
 CHAR 'I'
 CHAR 'A'
 TWOK 'G', 'E'
 CHAR 'S'
 EQUB 0

 TWOK 'A', 'R'          ; Token 58:     "ARMES"
 CHAR 'M'               ;
 TWOK 'E', 'S'          ; Encoded as:   "<138>M<137>"
 EQUB 0

 CHAR 'F'               ; Token 59:     "FOURRURES"
 CHAR 'O'               ;
 CHAR 'U'               ; Encoded as:   "FOURRUR<137>"
 CHAR 'R'
 CHAR 'R'
 CHAR 'U'
 CHAR 'R'
 TWOK 'E', 'S'
 EQUB 0

 CHAR 'M'               ; Token 60:     "MINÉRAUX"
 TWOK 'I', 'N'          ;
 CHAR '<'               ; Encoded as:   "M<140><<148>UX"
 TWOK 'R', 'A'
 CHAR 'U'
 CHAR 'X'
 EQUB 0

 TWOK 'O', 'R'          ; Token 61:     "OR"
 EQUB 0                 ;
                        ; Encoded as:   "<153>"

 CHAR 'P'               ; Token 62:     "PLATINE"
 CHAR 'L'               ;
 TWOK 'A', 'T'          ; Encoded as:   "PL<145><140>E"
 TWOK 'I', 'N'
 CHAR 'E'
 EQUB 0

 TWOK 'G', 'E'          ; Token 63:     "GEMMES"
 CHAR 'M'               ;
 CHAR 'M'               ; Encoded as:   "<131>MM<137>"
 TWOK 'E', 'S'
 EQUB 0

 RTOK 127               ; Token 64:     "OBJET E.T."
 CHAR ' '               ;
 CHAR 'E'               ; Encoded as:   "[127] E.T."
 CHAR '.'
 CHAR 'T'
 CHAR '.'
 EQUB 0

 EQUB 0                 ; Token 65:     ""
                        ;
                        ; Encoded as:   ""

 CHAR ' '               ; Token 66:     " CR"
 CHAR 'C'               ;
 CHAR 'R'               ; Encoded as:   " CR"
 EQUB 0

 CHAR 'L'               ; Token 67:     "LARGES"
 TWOK 'A', 'R'          ;
 TWOK 'G', 'E'          ; Encoded as:   "L<138><131>S"
 CHAR 'S'
 EQUB 0

 CHAR 'F'               ; Token 68:     "FÉROCES"
 CHAR '<'               ;
 CHAR 'R'               ; Encoded as:   "F<RO<133>S"
 CHAR 'O'
 TWOK 'C', 'E'
 CHAR 'S'
 EQUB 0

 CHAR 'P'               ; Token 69:     "PETITS"
 CHAR 'E'               ;
 TWOK 'T', 'I'          ; Encoded as:   "PE<151>TS"
 CHAR 'T'
 CHAR 'S'
 EQUB 0

 CHAR 'V'               ; Token 70:     "VERTS"
 TWOK 'E', 'R'          ;
 CHAR 'T'               ; Encoded as:   "V<144>TS"
 CHAR 'S'
 EQUB 0

 CHAR 'R'               ; Token 71:     "ROUGES"
 CHAR 'O'               ;
 CHAR 'U'               ; Encoded as:   "ROU<131>S"
 TWOK 'G', 'E'
 CHAR 'S'
 EQUB 0

 CHAR 'J'               ; Token 72:     "JAUNES"
 CHAR 'A'               ;
 CHAR 'U'               ; Encoded as:   "JAUN<137>"
 CHAR 'N'
 TWOK 'E', 'S'
 EQUB 0

 CHAR 'B'               ; Token 73:     "BLEUS"
 TWOK 'L', 'E'          ;
 TWOK 'U', 'S'          ; Encoded as:   "B<129><136>"
 EQUB 0

 CHAR 'N'               ; Token 74:     "NOIRS"
 CHAR 'O'               ;
 CHAR 'I'               ; Encoded as:   "NOIRS"
 CHAR 'R'
 CHAR 'S'
 EQUB 0

 RTOK 136               ; Token 75:     "INOFFENSIFS"
 CHAR 'S'               ;
 EQUB 0                 ; Encoded as:   "[136]S"

 CHAR 'V'               ; Token 76:     "VISQUEUX"
 TWOK 'I', 'S'          ;
 TWOK 'Q', 'U'          ; Encoded as:   "V<157><154>EUX"
 CHAR 'E'
 CHAR 'U'
 CHAR 'X'
 EQUB 0

 CHAR 'Y'               ; Token 77:     "YEUX EXORBITÉS"
 CHAR 'E'               ;
 CHAR 'U'               ; Encoded as:   "YEUX EX<153><134>T<S"
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

 CHAR '"'               ; Token 78:     "À CORNES"
 CHAR ' '               ;
 CHAR 'C'               ; Encoded as:   "" C<153>N<137>"
 TWOK 'O', 'R'
 CHAR 'N'
 TWOK 'E', 'S'
 EQUB 0

 TWOK 'A', 'N'          ; Token 79:     "ANGULEUX"
 CHAR 'G'               ;
 CHAR 'U'               ; Encoded as:   "<155>GU<129>UX"
 TWOK 'L', 'E'
 CHAR 'U'
 CHAR 'X'
 EQUB 0

 CHAR 'G'               ; Token 80:     "GRAS"
 TWOK 'R', 'A'          ;
 CHAR 'S'               ; Encoded as:   "G<148>S"
 EQUB 0

 CHAR '"'               ; Token 81:     "À FOURRURE"
 CHAR ' '               ;
 CHAR 'F'               ; Encoded as:   "" FOURRU<142>"
 CHAR 'O'
 CHAR 'U'
 CHAR 'R'
 CHAR 'R'
 CHAR 'U'
 TWOK 'R', 'E'
 EQUB 0

 CHAR 'R'               ; Token 82:     "RONGEURS"
 TWOK 'O', 'N'          ;
 TWOK 'G', 'E'          ; Encoded as:   "R<159><131>URS)
 CHAR 'U'
 CHAR 'R'
 CHAR 'S'
 EQUB 0

 CHAR 'G'               ; Token 83:     "GRENOUILLES"
 TWOK 'R', 'E'          ;
 CHAR 'N'               ; Encoded as:   "G<142>NOUIL<129>S"
 CHAR 'O'
 CHAR 'U'
 CHAR 'I'
 CHAR 'L'
 TWOK 'L', 'E'
 CHAR 'S'
 EQUB 0

 CHAR 'L'               ; Token 84:     "LÉZARDS"
 CHAR '<'               ;
 TWOK 'Z', 'A'          ; Encoded as:   "L<<132>RDS"
 CHAR 'R'
 CHAR 'D'
 CHAR 'S'
 EQUB 0

 CHAR 'H'               ; Token 85:     "HOMARDS"
 CHAR 'O'               ;
 CHAR 'M'               ; Encoded as:   "HOM<138>DS"
 TWOK 'A', 'R'
 CHAR 'D'
 CHAR 'S'
 EQUB 0

 CHAR 'O'               ; Token 86:     "OISEAUX"
 TWOK 'I', 'S'          ;
 CHAR 'E'               ; Encoded as:   "O<157>EAUX"
 CHAR 'A'
 CHAR 'U'
 CHAR 'X'
 EQUB 0

 CHAR 'H'               ; Token 87:     "HUMANOIDES"
 CHAR 'U'               ;
 TWOK 'M', 'A'          ; Encoded as:   "HU<139>NOID<137>"
 CHAR 'N'
 CHAR 'O'
 CHAR 'I'
 CHAR 'D'
 TWOK 'E', 'S'
 EQUB 0

 CHAR 'F'               ; Token 88:     "FÉLINS"
 CHAR '<'               ;
 CHAR 'L'               ; Encoded as:   "F<L<140>S"
 TWOK 'I', 'N'
 CHAR 'S'
 EQUB 0

 TWOK 'I', 'N'          ; Token 89:     "INSECTES"
 RTOK 45                ;
 CHAR 'C'               ; Encoded as:   "<140>[45]CT<137>"
 CHAR 'T'
 TWOK 'E', 'S'
 EQUB 0

 TWOK 'R', 'A'          ; Token 90:     "RAYON"
 CHAR 'Y'               ;
 TWOK 'O', 'N'          ; Encoded as:   "<148>Y<159>"
 EQUB 0

 CHAR 'C'               ; Token 91:     "COM"
 CHAR 'O'               ;
 CHAR 'M'               ; Encoded as:   "COM"
 EQUB 0

 RTOK 91                ; Token 92:     "COMMANDANT"
 TWOK 'M', 'A'          ;
 CHAR 'N'               ; Encoded as:   "[91]<139>ND<155>T"
 CHAR 'D'
 TWOK 'A', 'N'
 CHAR 'T'
 EQUB 0

 CHAR ' '               ; Token 93:     " DÉTRUIT"
 CHAR 'D'               ;
 CHAR '<'               ; Encoded as:   " DÉTRUIT"
 CHAR 'T'
 CHAR 'R'
 CHAR 'U'
 CHAR 'I'
 CHAR 'T'
 EQUB 0

 TWOK 'L', 'E'          ; Token 94:     "LE "
 CHAR ' '               ;
 EQUB 0                 ; Encoded as:   "LE "

 RTOK 26                ; Token 95:     "PRODUIT     QTÉ PRIX UNITAIRE"
 CHAR ' '               ;
 CHAR ' '               ; Encoded as:   "[26]     QT< [6] UNITAI<142>"
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

 CHAR 'A'               ; Token 96:     "AVANT"
 CHAR 'V'               ;
 TWOK 'A', 'N'          ; Encoded as:   "AV<155>T"
 CHAR 'T'
 EQUB 0

 TWOK 'A', 'R'          ; Token 97:     "ARRIÈRE"
 TWOK 'R', 'I'          ;
 CHAR '='               ; Encoded as:   "<138><158>=<142>"
 TWOK 'R', 'E'
 EQUB 0

 CHAR 'G'               ; Token 98:     "GAUCHE"
 CHAR 'A'               ;
 CHAR 'U'               ; Encoded as:   "GAUCHE"
 CHAR 'C'
 CHAR 'H'
 CHAR 'E'
 EQUB 0

 CHAR 'D'               ; Token 99:     "DROITE"
 CHAR 'R'               ;
 CHAR 'O'               ; Encoded as:   "DROI<156>"
 CHAR 'I'
 TWOK 'T', 'E'
 EQUB 0

 RTOK 121               ; Token 100:    "ÉNERGIEFAIBLE{beep}"
 RTOK 138               ;
 CONT 7                 ; Encoded as:   "[121][138]{7}"
 EQUB 0

 CHAR 'B'               ; Token 101:    "BRAVO COMMANDANT!"
 TWOK 'R', 'A'          ;
 CHAR 'V'               ; Encoded as:   "B<148>VO [92]!"
 CHAR 'O'
 CHAR ' '
 RTOK 92
 CHAR '!'
 EQUB 0

 TWOK 'E', 'N'          ; Token 102:    "EN PLUS "
 CHAR ' '               ;
 CHAR 'P'               ; Encoded as:   "<146> PL<136> "
 CHAR 'L'
 TWOK 'U', 'S'
 CHAR ' '
 EQUB 0

 CHAR 'C'               ; Token 103:    "CANNON LASER"
 TWOK 'A', 'N'          ;
 CHAR 'N'               ; Encoded as:   "C<155>N<159> [27]"
 TWOK 'O', 'N'
 CHAR ' '
 RTOK 27
 EQUB 0

 RTOK 90                ; Token 104:    "RAYON LASER"
 CHAR ' '               ;
 RTOK 27                ; Encoded as:   "[90] [27]"
 EQUB 0

 RTOK 94                ; Token 105:    "LE FUEL"
 CHAR 'F'               ;
 CHAR 'U'               ; Encoded as:   "[94]FUEL"
 CHAR 'E'
 CHAR 'L'
 EQUB 0

 CHAR 'M'               ; Token 106:    "MISSILE"
 TWOK 'I', 'S'          ;
 CHAR 'S'               ; Encoded as:   "M<157>SI<129>"
 CHAR 'I'
 TWOK 'L', 'E'
 EQUB 0

 CHAR 'G'               ; Token 107:    "GRANDE SOUTE"
 TWOK 'R', 'A'          ;
 CHAR 'N'               ; Encoded as:   "G<148>NDE <135>U<156>"
 CHAR 'D'
 CHAR 'E'
 CHAR ' '
 TWOK 'S', 'O'
 CHAR 'U'
 TWOK 'T', 'E'
 EQUB 0

 RTOK 5                 ; Token 108:    "SYSTÈME E.C.M."
 CHAR ' '               ;
 CHAR 'E'               ; Encoded as:   "[5] E.C.M."
 CHAR '.'
 CHAR 'C'
 CHAR '.'
 CHAR 'M'
 CHAR '.'
 EQUB 0

 CHAR 'C'               ; Token 109:    "CANON LASER"
 TWOK 'A', 'N'          ;
 TWOK 'O', 'N'          ; Encoded as:   "C<155><159> [27]"
 CHAR ' '
 RTOK 27
 EQUB 0

 RTOK 104               ; Token 110:    "RAYON LASER"
 EQUB 0                 ;
                        ; Encoded as:   "[104]"

 CHAR 'R'               ; Token 111:    "RÉCOLTEUR DE FUEL"
 CHAR '<'               ;
 CHAR 'C'               ; Encoded as:   "R<COL<156>UR DE FUEL"
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

 CHAR 'C'               ; Token 112:    "CAPSULE DE SAUVETAGE"
 CHAR 'A'               ;
 CHAR 'P'               ; Encoded as:   "CAPSU[94]DE SAU<150>TA<131>"
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

 CHAR 'B'               ; Token 113:    "BOMBE D'ÉNERGIE"
 CHAR 'O'               ;
 CHAR 'M'               ; Encoded as:   "BOM<147> D'<N<144>GIE"
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

 CHAR 'U'               ; Token 114:    "UNITÉ D'ÉNERGIE"
 CHAR 'N'               ;
 CHAR 'I'               ; Encoded as:   "UNIT< D'<N<144>GIE"
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

 TWOK 'O', 'R'          ; Token 115:    "ORD. D'ARRIMAGE"
 CHAR 'D'               ;
 CHAR '.'               ; Encoded as:   "<153>D. D'<138><158><139><131>"
 CHAR ' '
 CHAR 'D'
 CHAR '`'
 TWOK 'A', 'R'
 TWOK 'R', 'I'
 TWOK 'M', 'A'
 TWOK 'G', 'E'
 EQUB 0

 TWOK 'I', 'N'          ; Token 116:    "INTERGALACTIQUE"
 CHAR 'T'               ;
 TWOK 'E', 'R'          ; Encoded as:   "<140>T<144>[122]"
 RTOK 122
 EQUB 0

 RTOK 27                ; Token 117:    "LASER MILITAIRE"
 CHAR ' '               
 CHAR 'M'               ; Encoded as:   "[27] MILITAI<142>"
 CHAR 'I'
 CHAR 'L'
 CHAR 'I'
 CHAR 'T'
 CHAR 'A'
 CHAR 'I'
 TWOK 'R', 'E'
 EQUB 0

 RTOK 27                ; Token 118:    "LASER {sentence case}MINEUR"
 CHAR ' '               ;
 CONT 6                 ; Encoded as:   "[27] {6}M<140>EUR"
 CHAR 'M'
 TWOK 'I', 'N'
 CHAR 'E'
 CHAR 'U'
 CHAR 'R'
 EQUB 0

 RTOK 37                ; Token 119:    "ARGENT:{cash} CR{cr})
 CHAR ':'               ;
 CONT 0                 ; Encoded as:   "[37]:{0}"
 EQUB 0

 RTOK 106               ; Token 120:    "MISSILE EN VUE"
 CHAR ' '               ;
 TWOK 'E', 'N'          ; Encoded as:   "[106] <146> VUE"
 CHAR ' '
 CHAR 'V'
 CHAR 'U'
 CHAR 'E'
 EQUB 0

 CHAR '<'               ; Token 121:    "ÉNERGIE "
 CHAR 'N'               ;
 TWOK 'E', 'R'          ; Encoded as:   "<N<144>GIE "
 CHAR 'G'
 CHAR 'I'
 CHAR 'E'
 CHAR ' '
 EQUB 0

 CHAR 'G'               ; Token 122:    "GALACTIQUE"
 CHAR 'A'               ;
 TWOK 'L', 'A'          ; Encoded as:   "GA<149>C<151><154>E"
 CHAR 'C'
 TWOK 'T', 'I'
 TWOK 'Q', 'U'
 CHAR 'E'
 EQUB 0

 RTOK 115               ; Token 123:    "ORD. D'ARRIMAGE EN MARCHE"
 CHAR ' '               ;
 TWOK 'E', 'N'          ; Encoded as:   "[115] <146> M<138>CHE"
 CHAR ' '
 CHAR 'M'
 TWOK 'A', 'R'
 CHAR 'C'
 CHAR 'H'
 CHAR 'E'
 EQUB 0

 CHAR 'T'               ; Token 124:    "TOUT"
 CHAR 'O'               ;
 CHAR 'U'               ; Encoded as:   "TOUT"
 CHAR 'T'
 EQUB 0

 RTOK 43                ; Token 125:    "STATUT LÉGAL:"
 TWOK 'A', 'T'          ;
 CHAR 'U'               ; Encoded as:   "[43]<145>UT L<GAL:"
 CHAR 'T'
 CHAR ' '
 CHAR 'L'
 CHAR '<'
 CHAR 'G'
 CHAR 'A'
 CHAR 'L'
 CHAR ':'
 EQUB 0

 RTOK 92                ; Token 126:    "COMMANDANT {commander name}{cr}
 CHAR ' '               ;                {cr}
 CONT 4                 ;                {cr}
 CONT 12                ;                {sentence case}SYSTÈME ACTUEL{tab
 CONT 12                ;                to column 22}:{current system name}{cr}
 CONT 12                ;                SYSTÈME INTERGALACT{tab to column 22}:
 CONT 6                 ;                {selected system name}{cr}CONDITION{tab
 RTOK 5                 ;                to column 22}:"
 CHAR ' '               ;
 CHAR 'A'               ; Encoded as:   "[92] {4}{12}{12}{12}{6}[5] ACTUEL{9}{2}
 CHAR 'C'               ;                {12}[5] <140>T<144>GA<149>CT{9}{3}{12}C
 CHAR 'T'               ;                <159><141><151><159>{9}"
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

 CHAR 'O'               ; Token 127:    "OBJET"
 CHAR 'B'               ;
 CHAR 'J'               ; Encoded as:   "OBJET"
 CHAR 'E'
 CHAR 'T'
 EQUB 0

 EQUB 0                 ; Token 128:    ""
                        ;
                        ; Encoded as:   ""

 CHAR '"'               ; Token 129:    "À "
 CHAR ' '               ;
 EQUB 0                 ; Encoded as:   "" "

 CHAR '<'               ; Token 130:    "ÉVALUATION"
 CHAR 'V'               ;
 CHAR 'A'               ; Encoded as:   "<VALU<145>I<159>"
 CHAR 'L'
 CHAR 'U'
 TWOK 'A', 'T'
 CHAR 'I'
 TWOK 'O', 'N'
 EQUB 0

 CHAR ' '               ; Token 131:    " SUR "
 CHAR 'S'               ;
 CHAR 'U'               ; Encoded as:   " SUR "
 CHAR 'R'
 CHAR ' '
 EQUB 0

 CONT 12                ; Token 132:    "{cr}ÉQUIPEMENT:"
 CHAR '<'               ;
 TWOK 'Q', 'U'          ; Encoded as:   "{12}<<154>IPEM<146>T:"
 CHAR 'I'
 CHAR 'P'
 CHAR 'E'
 CHAR 'M'
 TWOK 'E', 'N'
 CHAR 'T'
 CHAR ':'
 EQUB 0

 CHAR 'P'               ; Token 133:    "PROPRE"
 CHAR 'R'               ;
 CHAR 'O'               ; Encoded as:   "PROP<142>"
 CHAR 'P'
 TWOK 'R', 'E'
 EQUB 0

 CHAR 'D'               ; Token 134:    "DÉLINQUANT"
 CHAR '<'               ;
 CHAR 'L'               ; Encoded as:   "D<L<140><154><155>T"
 TWOK 'I', 'N'
 TWOK 'Q', 'U'
 TWOK 'A', 'N'
 CHAR 'T'
 EQUB 0

 CHAR 'F'               ; Token 135:    "FUGITIF"
 CHAR 'U'               ;
 CHAR 'G'               ; Encoded as:   "FUGI<151>F"
 CHAR 'I'
 TWOK 'T', 'I'
 CHAR 'F'
 EQUB 0

 TWOK 'I', 'N'          ; Token 136:    "INOFFENSIF"
 CHAR 'O'               ;
 CHAR 'F'               ; Encoded as:   "<140>OFF<146>SIF"
 CHAR 'F'
 TWOK 'E', 'N'
 CHAR 'S'
 CHAR 'I'
 CHAR 'F'
 EQUB 0

 TWOK 'Q', 'U'          ; Token 137:    "QUASI INOFFENSIF"
 CHAR 'A'               ;
 CHAR 'S'               ; Encoded as:   "<154>ASI [136]"
 CHAR 'I'
 CHAR ' '
 RTOK 136
 EQUB 0

 CHAR 'F'               ; Token 138:    "FAIBLE"
 CHAR 'A'               ;
 CHAR 'I'               ; Encoded as:   "FAIB<129>"
 CHAR 'B'
 TWOK 'L', 'E'
 EQUB 0

 CHAR 'M'               ; Token 139:    "MOYEN"
 CHAR 'O'               ;
 CHAR 'Y'               ; Encoded as:   "MOY<146>"
 TWOK 'E', 'N'
 EQUB 0

 TWOK 'I', 'N'          ; Token 140:    "INTERMÉDIAIRE"
 CHAR 'T'               ;
 TWOK 'E', 'R'          ; Encoded as:   "<140>T<144>M<<141>AI<142>"
 CHAR 'M'
 CHAR '<'
 TWOK 'D', 'I'
 CHAR 'A'
 CHAR 'I'
 TWOK 'R', 'E'
 EQUB 0

 RTOK 91                ; Token 141:    "COMPÉTENT"
 CHAR 'P'               ;
 CHAR '<'               ; Encoded as:   "[91]P<T<146>T"
 CHAR 'T'
 TWOK 'E', 'N'
 CHAR 'T'
 EQUB 0

 CHAR 'D'               ; Token 142:    "DANGEREUX"
 TWOK 'A', 'N'          ;
 TWOK 'G', 'E'          ; Encoded as:   "D<155><131><142>UX"
 TWOK 'R', 'E'
 CHAR 'U'
 CHAR 'X'
 EQUB 0

 CHAR 'M'               ; Token 143:    "MORTELLEMENT"
 TWOK 'O', 'R'          ;
 TWOK 'T', 'E'          ; Encoded as:   "M<153><156>L<129>M<146>T"
 CHAR 'L'
 TWOK 'L', 'E'
 CHAR 'M'
 TWOK 'E', 'N'
 CHAR 'T'
 EQUB 0

 CHAR '-'               ; Token 144:    "--- E L I T E ---"
 CHAR '-'               ;
 CHAR '-'               ; Encoded as:   "--- E L I T E ---"
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

 CHAR 'P'               ; Token 145:    "PRÉSENT"
 CHAR 'R'               ;
 CHAR '<'               ; Encoded as:   "PR<S<146>T"
 CHAR 'S'
 TWOK 'E', 'N'
 CHAR 'T'
 EQUB 0

 CONT 8                 ; Token 146:    "{all caps}JEU TERMINÉ"
 CHAR 'J'               ;
 CHAR 'E'               ; Encoded as:   "{8}JEU T<144>M<140><"
 CHAR 'U'
 CHAR ' '
 CHAR 'T'
 TWOK 'E', 'R'
 CHAR 'M'
 TWOK 'I', 'N'
 CHAR '<'
 EQUB 0

 CHAR 'P'               ; Token 147:    "PÉNALITÉ DE 60 SEC"
 CHAR '<'               ;
 CHAR 'N'               ; Encoded as:   "P<NALIT< DE 60 [45]C"
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
                        ;
                        ; Encoded as:   ""

 EQUB $00, $00, $00     ; These bytes appear to be unused
 EQUB $00, $00, $00
 EQUB $00

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

 CMP #'?'               ; If the second letter of the token is a question mark
 BEQ DTM-1              ; then this is a one-letter token, so just return from
                        ; the subroutine without printing (as DTM-1 contains an
                        ; RTS)

.DTS

 BIT DTW1               ; If bit 7 of DTW1 is clear then DTW1 must be %00000000,
 BPL DT5                ; so we do not change the character to lower case, so
                        ; jump to DT5 to print the character in upper case

 BIT DTW6               ; If bit 7 of DTW6 is set, then lower case has been
 BMI DT10               ; enabled by jump token 13, {lower case}, so jump to
                        ; DT10 to apply the lower case and single cap masks

 BIT DTW2               ; If bit 7 of DTW2 is set, then we are not currently
 BMI DT5                ; printing a word, so jump to DT5 so we skip the setting
                        ; of lower case in Sentence Case (which we only want to
                        ; do when we are already printing a word)

.DT10

 BIT DTW8               ; If bit 7 of DTW8 is clear then DTW8 must be %0000000
 BPL DT5                ; (capitalise the next letter), so jump to DT5 to print
                        ; the character in upper case

                        ; If we get here then we know DTW8 is %11111111 (do not
                        ; change case, so we now convert the character to lower
                        ; case

 STX SC                 ; Store X in SC so we can retrieve it below

 TAX                    ; Convert the character in A into lower case by looking
 LDA lowerCase,X        ; up the lower case ASCII value from the lowerCase table

 LDX SC                 ; Restore the value of X that we stored in SC

 AND DTW8               ; This instruction has no effect, because we know that
                        ; DTW8 is %11111111
                        ;
                        ; The code is left over from the BBC Micro version, in
                        ; which DTW8 is used as a bitmask to convert a character
                        ; to upper case

.DT5

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
;   * DTW1 = %10000000 (apply lower case to the second letter of a word onwards)
;
;   * DTW6 = %00000000 (lower case is not enabled)
;
; ******************************************************************************

.MT2

 LDA #%10000000         ; Set DTW1 = %10000000
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
;    Summary: Clear the screen and set the view type for a text-based mission
;    briefing
;  Deep dive: Extended text tokens
;
; ------------------------------------------------------------------------------
;
; This routine sets the following:
;
;   * XC = 1 (tab to column 1)
;
; before calling TT66 to clear the screen and set the view type to $95.
;
; ******************************************************************************

.MT9

 LDA #1                 ; Move the text cursor to column 1
 STA XC

 LDA #$95               ; Clear the screen and and set the view type in QQ11 to
 JMP TT66_b0            ; $95 (Text-based mission briefing), returning from the
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

 JSR UpdateViewWithFade ; Update the view, fading the screen to black first if
                        ; required

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

 JSR DrawScreenInNMI_b0 ; Configure the NMI handler to draw the screen

 JSR WaitForPPUToFinish ; Wait until both bitplanes of the screen have been
                        ; sent to the PPU, so the screen is fully updated and
                        ; there is no more data waiting to be sent to the PPU

 LDA firstFreeTile      ; Tell the NMI handler to send pattern entries from the
 STA firstPatternTile   ; first free tile onwards, so we don't waste time
                        ; resending the static tiles we have already sent

 LDA #40                ; Tell the NMI handler to only clear nametable entries
 STA maxNameTileToClear ; up to tile 40 * 8 = 320 (i.e. up to the end of tile
                        ; row 10)

 LDX #8                 ; Tell the NMI handler to send nametable entries from
 STX firstNametableTile ; tile 8 * 8 = 64 onwards (i.e. from the start of tile
                        ; row 2)

.paus1

 JSR PAS1_b0            ; Call PAS1 to display the rotating ship at space
                        ; coordinates (0, 100, 256) and scan the controllers

 LDA controller1A       ; Loop back to keep displaying the rotating ship until
 ORA controller1B       ; both the A button and B button have been released on
 BPL paus1              ; controller 1

.paus2

 JSR PAS1_b0            ; Call PAS1 to display the rotating ship at space
                        ; coordinates (0, 100, 256) and scan the controllers

 LDA controller1A       ; Loop back to keep displaying the rotating ship until
 ORA controller1B       ; either the A button or B button has been pressed on
 BMI paus2              ; controller 1

 LDA #0                 ; Set the ship's AI flag to 0 (no AI) so it doesn't get
 STA INWK+31            ; any ideas of its own

 LDA #$93               ; Clear the screen and and set the view type in QQ11 to
 JSR TT66_b0            ; $93 (Mission 1 briefing: ship and text)

                        ; Fall through into MT23 to move to row 10, switch to
                        ; white text, and switch to lower case when printing
                        ; extended tokens

; ******************************************************************************
;
;       Name: MT23
;       Type: Subroutine
;   Category: Text
;    Summary: Move to row 9 and switch to lower case
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

                        ; Fall through into MT29 to move to the row in A and
                        ; switch to lower case

; ******************************************************************************
;
;       Name: MT29
;       Type: Subroutine
;   Category: Text
;    Summary: Move to row 7 and switch to lower case when
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
;   * DTW1 = %10000000 (apply lower case to the second letter of a word onwards)
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
;   Category: Controllers
;    Summary: Wait until a key is pressed, ignoring any existing key press
;
; ******************************************************************************

.PAUSE2

 JSR DrawScreenInNMI_b0 ; Configure the NMI handler to draw the screen

.paws1

 JSR SetupPPUForIconBar ; If the PPU has started drawing the icon bar, configure
                        ; the PPU to use nametable 0 and pattern table 0

 LDA controller1A       ; Keep looping back to paws1 until either the A button
 ORA controller1B       ; or the B button has been pressed and then released on
 AND #%11000000         ; controller 1
 CMP #%01000000
 BNE paws1

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
;   systemNumber        The system number (0-255)
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

 LDX languageIndex      ; Set X to the index of the chosen language

 LDA RUPLA_LO,X         ; Set SC(1 0) to the address of the RUPLA table for the
 STA SC                 ; chosen language, minus 1 (i.e. RUPLA-1, RUPLA_DE-1
 LDA RUPLA_HI,X         ; or RUPLA_FR-1)
 STA SC+1

 LDA RUGAL_LO,X         ; Set SC2(1 0) to the address of the RUGAL table for the
 STA SC2                ; chosen language, minus 1 (i.e. RUGAL-1, RUGAL_DE-1
 LDA RUGAL_HI,X         ; or RUGAL_FR-1)
 STA SC2+1

 LDY NRU,X              ; Set Y as a loop counter as we work our way through the
                        ; system numbers in RUPLA, starting at the value of NRU
                        ; for the chosen language (which is the number of
                        ; entries in RUPLA) and working our way down to 1

.PDL1

 LDA (SC),Y             ; Fetch the Y-th byte from RUPLA-1 into A (we use
                        ; RUPLA-1 because Y is looping from NRU to 1)

 CMP systemNumber       ; If A doesn't match the system whose description we
 BNE PD2                ; are printing (in systemNumber), jump to PD2 to keep
                        ; looping through the system numbers in RUPLA

                        ; If we get here we have found a match for this system
                        ; number in RUPLA

 LDA (SC2),Y            ; Fetch the Y-th byte from RUGAL-1 into A

 AND #%01111111         ; Extract bits 0-6 of A

 CMP GCNT               ; If the result does not equal the current galaxy
 BNE PD2                ; number, jump to PD2 to keep looping through the system
                        ; numbers in RUPLA

 LDA (SC2),Y            ; Fetch the Y-th byte from RUGAL-1 into A, once again

 BMI PD3                ; If bit 7 is set, jump to PD3 to print the extended
                        ; token in A from the second table in RUTOK

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

 JMP PrintCtrlCode_b0   ; We jump here from below if the character to print is
                        ; in the range 0 to 9, so jump to PrintCtrlCode to print
                        ; the control code and return from the subroutine using
                        ; a tail call

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

 CMP #10                ; If token < 10 then this is a control code, so jump to
 BCC TT27S              ; PrintCtrlCode via TT27S to print it

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
                        ; clear), so jump to TT26 via TT44 to print the
                        ; character in upper case

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
 BEQ DA8                ; then jump to DA8 to skip the following instructions
 CMP #12                ; and set bit 6 of QQ17 to print the next letter in
 BEQ DA8                ; upper case (so these characters don't act like the
 CMP #'-'               ; initial capital letter in Sentence Case, for example)
 BEQ DA8

 LDA QQ17               ; Set bit 6 of QQ17 so we print the next letter in
 ORA #%01000000         ; lower case
 STA QQ17

 INX                    ; Increment X to 0, so DTW2 gets set to %00000000 below

 BEQ dasc1              ; Jump to dasc1 to skip the following (this BEQ is
                        ; effectively a JMP as X is always zero)

.DA8

 LDA QQ17               ; Clear bit 6 of QQ17 so we print the next letter in
 AND #%10111111         ; upper case
 STA QQ17

.dasc1

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

 LDA #' '               ; Set A to the ASCII for space
                        ;
                        ; This instruction has no effect because A already
                        ; contains ASCII " ". This is because the last character
                        ; that is tested in the above loop is at position SC,
                        ; which we know contains a space, so we know A contains
                        ; a space character when the loop finishes

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
;       Name: CHPR (Part 1 of 6)
;       Type: Subroutine
;   Category: Text
;    Summary: Print a character at the text cursor by poking into screen memory
;
; ------------------------------------------------------------------------------
;
; Print a character at the text cursor (XC, YC), do a beep, print a newline,
; or delete left (backspace).
;
; If the relevant font is already loaded into the pattern buffers, then this is
; used as the tile pattern for the character, otherwise the pattern for the
; character being printed is extracted from the fontImage table and into the
; pattern buffer.
;
; For fontStyle = 3, the pattern is always extracted from the fontImage table,
; as it has different colour text (colour 3) than the normal font. This is used
; when printing characters into 2x2 attribute blocks where printing the normal
; font would result in the wrong colour text being shown.
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
;   fontStyle           Determines the font style:
;
;                         * 1 = normal font
;
;                         * 2 = highlight font
;
;                         * 3 = green text on a black background (colour 3 on
;                               background colour 0)
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

.chpr1

 JMP chpr17             ; Jump to chpr17 to restore the registers and return
                        ; from the subroutine

.chpr2

 LDA #2                 ; Move the text cursor to row 2
 STA YC

 LDA K3                 ; Set A to the character to be printed

 JMP chpr4              ; Jump to chpr4 to print the character in A

.chpr3

 JMP chpr17             ; Jump to chpr17 to restore the registers and return
                        ; from the subroutine

 LDA #12                ; This instruction is never called, but it would set A
                        ; to a carriage return character and fall through into
                        ; CHPR to print the newline

.CHPR

 STA K3                 ; Store the A register in K3 so we can retrieve it below
                        ; (so K3 contains the number of the character to print)

 SETUP_PPU_FOR_ICON_BAR ; If the PPU has started drawing the icon bar, configure
                        ; the PPU to use nametable 0 and pattern table 0

 LDA K3                 ; Store the A, X and Y registers, so we can restore
 STY YSAV2              ; them at the end (so they don't get changed by this
 STX XSAV2              ; routine)

 LDY QQ17               ; Load the QQ17 flag, which contains the text printing
                        ; flags

 CPY #255               ; If QQ17 = 255 then printing is disabled, so jump to
 BEQ chpr3              ; chpr17 (via the JMP in chpr3) to restore the registers
                        ; and return from the subroutine using a tail call

.chpr4

 CMP #7                 ; If this is a beep character (A = 7), jump to chpr1,
 BEQ chpr1              ; which will emit the beep, restore the registers and
                        ; return from the subroutine

 CMP #32                ; If this is an ASCII character (A >= 32), jump to chpr6
 BCS chpr6              ; below, which will print the character, restore the
                        ; registers and return from the subroutine

 CMP #10                ; If this is control code 10 (line feed) then jump to
 BEQ chpr5              ; chpr5, which will move down a line, restore the
                        ; registers and return from the subroutine

 LDX #1                 ; If we get here, then this is control code 11-13, of
 STX XC                 ; which only 13 is used. This code prints a newline,
                        ; which we can achieve by moving the text cursor
                        ; to the start of the line (carriage return) and down
                        ; one line (line feed). These two lines do the first
                        ; bit by setting XC = 1, and we then fall through into
                        ; the line feed routine that's used by control code 10

.chpr5

 CMP #13                ; If this is control code 13 (carriage return) then jump
 BEQ chpr3              ; to chpr17 (via the JMP in chpr3) to restore the
                        ; registers and return from the subroutine using a tail
                        ; call

 INC YC                 ; Increment the text cursor y-coordinate to move it
                        ; down one row

 BNE chpr3              ; Jump to chpr17 via chpr3 to restore the registers and
                        ; return from the subroutine using a tail call (this BNE
                        ; is effectively a JMP as Y will never be zero)

.chpr6

                        ; If we get here, then the character to print is an
                        ; ASCII character in the range 32-95

 LDX XC                 ; If the text cursor is on a column of 30 or less, then
 CPX #31                ; we have space to print the character on the current
 BCC chpr7              ; row, so jump to chpr7 to skip the following

 LDX #1                 ; The text cursor has moved off the right end of the
 STX XC                 ; current line, so move the cursor back to column 1 and
 INC YC                 ; down to the next row

.chpr7

 LDX YC                 ; If the text cursor is on row 26 or less, then the
 CPX #27                ; cursor is on-screen, so jump to chpr8 to skip the
 BCC chpr8              ; following instruction

 JMP chpr2              ; The cursor is off the bottom of the screen, so jump to
                        ; chpr2 to move the cursor up to row 2 before printing
                        ; the character

.chpr8

 CMP #127               ; If the character to print is not ASCII 127, then jump
 BNE chpr9              ; to chpr9 to skip the following instruction

 JMP chpr21             ; Jump to chpr21 to delete the character to the left of
                        ; the text cursor

; ******************************************************************************
;
;       Name: CHPR (Part 2 of 6)
;       Type: Subroutine
;   Category: Text
;    Summary: Jump to the right part of the routine depending on whether the
;             font pattern we need is already loaded
;
; ******************************************************************************

.chpr9

 INC XC                 ; Once we print the character, we want to move the text
                        ; cursor to the right, so we do this by incrementing
                        ; XC. Note that this doesn't have anything to do
                        ; with the actual printing below, we're just updating
                        ; the cursor so it's in the right position following
                        ; the print

                        ; Before printing, we need to work out whether the font
                        ; we need is already loaded into the pattern buffers,
                        ; which will depend on the view type

 LDA QQ11               ; If bits 4 and 5 of the view type are clear, then no
 AND #%00110000         ; fonts are loaded, so jump to chpr11 to print the
 BEQ chpr11             ; character by copying the relevant font pattern into
                        ; the pattern buffers

                        ; If we get here then we know that at least one of bits
                        ; 4 and 5 is set in QQ11, which means the normal font is
                        ; loaded

 LDY fontStyle          ; If fontStyle = 1, then we want to print text using the
 CPY #1                 ; normal font, so jump to chpr10 to use the normal font
 BEQ chpr10             ; in the pattern buffers, as we know the normal font is
                        ; loaded

                        ; If we get here we know that fontStyle is 2 or 3

 AND #%00100000         ; If bit 5 of the view type in QQ11 is clear, then the
 BEQ chpr11             ; highlight font is not loaded, so jump to chpr11 to
                        ; print the character by copying the relevant font
                        ; pattern into the pattern buffers

                        ; If we get here then bit 5 of the view type in QQ11
                        ; is set, so we know that both the normal and highlight
                        ; fonts are loaded
                        ;
                        ; We also know that fontStyle = 2 or 3

 CPY #2                 ; If fontStyle = 3, then we want to print the character
 BNE chpr11             ; in green text on a black background (so we can't use
                        ; the normal font as that's in colour 1 on black and we
                        ; need to print in colour 3 on black), so jump to chpr11
                        ; to print the character by copying the relevant font
                        ; pattern into the pattern buffers

                        ; If we get here then fontStyle = 2, so we want to print
                        ; text using the highlight font and we know it is
                        ; loaded, so we can go ahead and use the loaded font for
                        ; our character

 LDA K3                 ; Set A to the character to be printed

 CLC                    ; Set A = A + 95
 ADC #95                ;
                        ; The highlight font is loaded into pattern 161, which
                        ; is 95 more than the normal font at pattern 66, so this
                        ; points A to the correct character number in the
                        ; highlight font

 JMP chpr22             ; Jump to chpr22 to print the character using a font
                        ; that has already been loaded

.chpr10

                        ; If we get here then fontStyle = 1 and the highlight
                        ; font is loaded, so we can use that for our character

 LDA K3                 ; Set A to the character to be printed

 JMP chpr22             ; Jump to chpr22 to print the character using a font
                        ; that has already been loaded

; ******************************************************************************
;
;       Name: CHPR (Part 3 of 6)
;       Type: Subroutine
;   Category: Text
;    Summary: Draw a character into the pattern buffers to show the character
;             on-screen
;
; ******************************************************************************

.chpr11

                        ; If we get here then at least one of these is true:
                        ;
                        ;   * No font is loaded
                        ;
                        ;   * fontStyle = 2 (so we want to print highlighted
                        ;     text) but the highlight font is not loaded
                        ;
                        ;   * fontStyle = 3 (so we want to print text in colour
                        ;     3 on background colour 0)
                        ;
                        ; In all cases, we need to draw the pattern for the
                        ; character directly into the relevant pattern buffer,
                        ; as it isn't already available in a loaded font

 LDA K3                 ; If the character to print in K3 is not a space, jump
 CMP #' '               ; to chpr12 to skip the following instruction
 BNE chpr12

 JMP chpr17             ; We are printing a space, so jump to chpr17 to return
                        ; from the subroutine

.chpr12

 TAY                    ; Set Y to the character to print
                        ;
                        ; Let's call the character number chr

                        ; We now want to calculate the address of the pattern
                        ; data for this character in the fontImage table, which
                        ; contains the font images in ASCII order, starting from
                        ; the space character (which maps to ASCII 32)
                        ;
                        ; There are eight bytes in each character's pattern, so
                        ; the address we are after is therefore:
                        ;
                        ;   fontImage + (chr - 32) * 8
                        ;
                        ; This calculation is optimised below to take advantage
                        ; of the fact that LO(fontImage) = $E8 = 29 * 8, so:
                        ;
                        ;   fontImage + (chr - 32) * 8
                        ; = HI(fontImage) * 256 + LO(fontImage) + (chr - 32) * 8
                        ; = HI(fontImage) * 256 + (29 * 8) + (chr - 32) * 8
                        ; = HI(fontImage) * 256 + (29 + chr - 32) * 8
                        ; = HI(fontImage) * 256 + (chr - 3) * 8
                        ;
                        ; So that is what we calculate below

 CLC                    ; Set A = A - 3
 ADC #$FD               ;       = chr - 3
                        ;
                        ; This could also be done using SEC and SBC #3

 LDX #0                 ; Set P(2 1) = A * 8
 STX P+2                ;            = (chr - 3) * 8
 ASL A                  ;            = chr * 8 - 24
 ROL P+2
 ASL A
 ROL P+2
 ASL A
 ROL P+2
 ADC #0
 STA P+1

 LDA P+2                ; Set P(2 1) = P(2 1) + HI(fontImage) * 256
 ADC #HI(fontImage)     ;            = HI(fontImage) * 256 + (chr - 3) * 8
 STA P+2                ;
                        ;
                        ; So P(2 1) is the address of the pattern data for the
                        ; character that we want to print

 LDA #0                 ; Set SC+1 = 0 (though this is never used as SC+1 is
 STA SC+1               ; overwritten again before it is used)

 LDA YC                 ; If the text cursor is not on row 0, jump to chpr13 to
 BNE chpr13             ; skip the following instruction

 JMP chpr31             ; The text cursor is on row 0, so jump to chpr31 to set
                        ; SC(1 0) to the correct address in the nametable buffer
                        ; and return to chpr15 below to draw the character

.chpr13

 LDA QQ11               ; If this is not the space view (i.e. QQ11 is non-zero)
 BNE chpr14             ; then jump to chpr14 to skip the following instruction

 JMP chpr28             ; This is the space view with no fonts loaded, so jump
                        ; to chpr28 to draw the character on-screen, merging the
                        ; text with whatever is already there

.chpr14

 JSR GetRowNameAddress  ; Get the addresses in the nametable buffers for the
                        ; start of character row YC, as follows:
                        ;
                        ;   SC(1 0) = the address in nametable buffer 0
                        ;
                        ;   SC2(1 0) = the address in nametable buffer 1

 LDY XC                 ; Set Y to the column of the text cursor - 1
 DEY

 LDA (SC),Y             ; This has no effect, as chpr15 is the next label and
 BEQ chpr15             ; neither A nor the status flags are read before being
                        ; overwritten, but it checks whether the nametable entry
                        ; for the character we want to draw is empty (and then
                        ; does nothing if it is)

.chpr15

 LDA firstFreeTile      ; If firstFreeTile is zero then we have run out of tiles
 BEQ chpr17             ; to use for drawing characters, so jump to chpr17 to
                        ; return from the subroutine without printing anything

 CMP #255               ; If firstFreeTile = 255 then we have run out of tiles
 BEQ chpr17             ; to use for drawing characters, so jump to chpr17 to
                        ; return from the subroutine without printing anything

 STA (SC),Y             ; Otherwise firstFreeTile contains the number of the
 STA (SC2),Y            ; next available tile for drawing, so allocate this
                        ; tile to cover the character that we want to draw by
                        ; setting the nametable entry in both buffers to the
                        ; tile number we just fetched

 INC firstFreeTile      ; Increment firstFreeTile to point to the next available
                        ; tile for drawing, so it can be added to the nametable
                        ; the next time we need to draw into a tile

 LDY fontStyle          ; If fontStyle = 1, jump to chpr18
 DEY
 BEQ chpr18

 DEY                    ; If fontStyle = 3, jump to chpr16
 BNE chpr16

 JMP chpr19             ; Otherwise fontStyle = 2, so jump to chpr19

.chpr16

                        ; If we get here then fontStyle = 3 and we need to
                        ; copy the pattern data for this character from the
                        ; address in P(2 1) into both pattern buffers 0 and 1

 TAY                    ; Set Y to the character to print

 LDX #HI(pattBuffer0)/8 ; Set SC2(1 0) = (pattBuffer0/8 A) * 8
 STX SC2+1              ;              = (pattBufferHi 0) + A * 8
 ASL A                  ;
 ROL SC2+1              ; So SC2(1 0) is the address in the pattern buffer for
 ASL A                  ; tile number A (as each tile contains 8 bytes of
 ROL SC2+1              ; pattern data), which means SC2(1 0) points to the
 ASL A                  ; pattern data for the tile containing the character
 ROL SC2+1              ; we are drawing in pattern buffer 0
 STA SC2

 TYA                    ; Set A back to the character to print

 LDX #HI(pattBuffer1)/8 ; Set SC(1 0) = (pattBuffer1/8 A) * 8
 STX SC+1               ;             = (pattBufferHi 0) + A * 8
 ASL A                  ;
 ROL SC+1               ; So SC(1 0) is the address in the pattern buffer for
 ASL A                  ; tile number A (as each tile contains 8 bytes of
 ROL SC+1               ; pattern data), which means SC(1 0) points to the
 ASL A                  ; pattern data for the tile containing the character
 ROL SC+1               ; we are drawing in pattern buffer 1
 STA SC

                        ; We now copy the pattern data for this character from
                        ; the address in P(2 1) to the pattern buffer addresses
                        ; in SC(1 0) and SC2(1 0)

 LDY #0                 ; We want to copy eight bytes of pattern data, as each
                        ; character has eight rows of eight pixels, so set a
                        ; byte index counter in Y

                        ; We repeat the following code eight times, so it copies
                        ; one whole pattern of eight bytes

 LDA (P+1),Y            ; Copy the Y-th pattern byte from P(2 1) to the Y-th
 STA (SC),Y             ; byte of the pattern buffers in SC(1 0) and SC2(1 0),
 STA (SC2),Y            ; and increment the byte counter in Y
 INY                    

 LDA (P+1),Y            ; Copy the Y-th pattern byte from P(2 1) to the Y-th
 STA (SC),Y             ; byte of the pattern buffers in SC(1 0) and SC2(1 0),
 STA (SC2),Y            ; and increment the byte counter in Y
 INY                    

 LDA (P+1),Y            ; Copy the Y-th pattern byte from P(2 1) to the Y-th
 STA (SC),Y             ; byte of the pattern buffers in SC(1 0) and SC2(1 0),
 STA (SC2),Y            ; and increment the byte counter in Y
 INY                    

 LDA (P+1),Y            ; Copy the Y-th pattern byte from P(2 1) to the Y-th
 STA (SC),Y             ; byte of the pattern buffers in SC(1 0) and SC2(1 0),
 STA (SC2),Y            ; and increment the byte counter in Y
 INY                    

 LDA (P+1),Y            ; Copy the Y-th pattern byte from P(2 1) to the Y-th
 STA (SC),Y             ; byte of the pattern buffers in SC(1 0) and SC2(1 0),
 STA (SC2),Y            ; and increment the byte counter in Y
 INY                    

 LDA (P+1),Y            ; Copy the Y-th pattern byte from P(2 1) to the Y-th
 STA (SC),Y             ; byte of the pattern buffers in SC(1 0) and SC2(1 0),
 STA (SC2),Y            ; and increment the byte counter in Y
 INY                    

 LDA (P+1),Y            ; Copy the Y-th pattern byte from P(2 1) to the Y-th
 STA (SC),Y             ; byte of the pattern buffers in SC(1 0) and SC2(1 0),
 STA (SC2),Y            ; and increment the byte counter in Y
 INY                    

 LDA (P+1),Y            ; Copy the Y-th pattern byte from P(2 1) to the Y-th
 STA (SC2),Y            ; byte of the pattern buffers in SC(1 0) and SC2(1 0)
 STA (SC),Y           

.chpr17

 LDY YSAV2              ; We're done printing, so restore the values of the
 LDX XSAV2              ; X and Y registers that we saved above

 SETUP_PPU_FOR_ICON_BAR ; If the PPU has started drawing the icon bar, configure
                        ; the PPU to use nametable 0 and pattern table 0

 LDA K3                 ; Restore the value of the A register that we saved
                        ; above

 CLC                    ; Clear the C flag, so everything is back to how it was

 RTS                    ; Return from the subroutine

.chpr18

                        ; If we get here then fontStyle = 1 and we need to
                        ; copy the pattern data for this character from the
                        ; address in P(2 1) into pattern buffer 0

 LDX #HI(pattBuffer0)/8 ; Set SC(1 0) = (pattBuffer0/8 A) * 8
 STX SC+1               ;             = (pattBufferHi 0) + A * 8
 ASL A                  ;
 ROL SC+1               ; So SC(1 0) is the address in the pattern buffer for
 ASL A                  ; tile number A (as each tile contains 8 bytes of
 ROL SC+1               ; pattern data), which means SC(1 0) points to the
 ASL A                  ; pattern data for the tile containing the character
 ROL SC+1               ; we are drawing in pattern buffer 0
 STA SC

 JMP chpr20             ; Jump to chpr20 to draw the pattern we need for our
                        ; text character into the pattern buffer

.chpr19

                        ; If we get here then fontStyle = 2 and we need to
                        ; copy the pattern data for this character from the
                        ; address in P(2 1) into pattern buffer 1

 LDX #HI(pattBuffer1)/8 ; Set SC(1 0) = (pattBuffer1/8 A) * 8
 STX SC+1               ;             = (pattBufferHi 0) + A * 8
 ASL A                  ;
 ROL SC+1               ; So SC(1 0) is the address in the pattern buffer for
 ASL A                  ; tile number A (as each tile contains 8 bytes of
 ROL SC+1               ; pattern data), which means SC(1 0) points to the
 ASL A                  ; pattern data for the tile containing the character
 ROL SC+1               ; we are drawing in pattern buffer 1
 STA SC

.chpr20

                        ; We now copy the pattern data for this character from
                        ; the address in P(2 1) to the pattern buffer address
                        ; in SC(1 0)

 LDY #0                 ; We want to copy eight bytes of pattern data, as each
                        ; character has eight rows of eight pixels, so set a
                        ; byte index counter in Y

                        ; We repeat the following code eight times, so it copies
                        ; one whole pattern of eight bytes

 LDA (P+1),Y            ; Copy the Y-th pattern byte from P(2 1) to the Y-th
 STA (SC),Y             ; byte of the pattern buffer in SC(1 0), and increment
 INY                    ; the byte counter in Y

 LDA (P+1),Y            ; Copy the Y-th pattern byte from P(2 1) to the Y-th
 STA (SC),Y             ; byte of the pattern buffer in SC(1 0), and increment
 INY                    ; the byte counter in Y

 LDA (P+1),Y            ; Copy the Y-th pattern byte from P(2 1) to the Y-th
 STA (SC),Y             ; byte of the pattern buffer in SC(1 0), and increment
 INY                    ; the byte counter in Y

 LDA (P+1),Y            ; Copy the Y-th pattern byte from P(2 1) to the Y-th
 STA (SC),Y             ; byte of the pattern buffer in SC(1 0), and increment
 INY                    ; the byte counter in Y

 LDA (P+1),Y            ; Copy the Y-th pattern byte from P(2 1) to the Y-th
 STA (SC),Y             ; byte of the pattern buffer in SC(1 0), and increment
 INY                    ; the byte counter in Y

 LDA (P+1),Y            ; Copy the Y-th pattern byte from P(2 1) to the Y-th
 STA (SC),Y             ; byte of the pattern buffer in SC(1 0), and increment
 INY                    ; the byte counter in Y

 LDA (P+1),Y            ; Copy the Y-th pattern byte from P(2 1) to the Y-th
 STA (SC),Y             ; byte of the pattern buffer in SC(1 0), and increment
 INY                    ; the byte counter in Y

 LDA (P+1),Y            ; Copy the Y-th pattern byte from P(2 1) to the Y-th
 STA (SC),Y             ; byte of the pattern buffer in SC(1 0)

 JMP chpr17             ; Jump to chpr17 to return from the subroutine, as we
                        ; are done printing this character

; ******************************************************************************
;
;       Name: CHPR (Part 4 of 6)
;       Type: Subroutine
;   Category: Text
;    Summary: Process the delete character
;
; ******************************************************************************

.chpr21

                        ; If we get here then we are printing ASCII 127, which
                        ; is the delete character

 JSR GetRowNameAddress  ; Get the addresses in the nametable buffers for the
                        ; start of character row YC, as follows:
                        ;
                        ;   SC(1 0) = the address in nametable buffer 0
                        ;
                        ;   SC2(1 0) = the address in nametable buffer 1

 LDY XC                 ; Set Y to the text column of the text cursor, which
                        ; points to the character we want to delete (as we are
                        ; printing a delete character there)

 DEC XC                 ; Decrement XC to move the text cursor left by one
                        ; place, as we are deleting a character

 LDA #0                 ; Zero the Y-th nametable entry in nametable buffer 0
 STA (SC),Y             ; for the Y-th character on row YC, which deletes the
                        ; character that was there

 STA (SC2),Y            ; Zero the Y-th nametable entry in nametable buffer 1
                        ; for the Y-th character on row YC, which deletes the
                        ; character that was there

 JMP chpr17             ; Jump to chpr17 to return from the subroutine, as we
                        ; are done printing this character

; ******************************************************************************
;
;       Name: CHPR (Part 5 of 6)
;       Type: Subroutine
;   Category: Text
;    Summary: Print the character using a font that has already been loaded
;
; ******************************************************************************

.chpr22

                        ; If we get here then one of these is true:
                        ;
                        ;   * The normal and highlight fonts are loaded
                        ;     fontStyle = 2
                        ;     A = character number + 95
                        ;
                        ;   * The normal font is loaded
                        ;     fontStyle = 1
                        ;     A = character number

 PHA                    ; Store A on the stack to we can retrieve it after the
                        ; call to GetRowNameAddress

 JSR GetRowNameAddress  ; Get the addresses in the nametable buffers for the
                        ; start of character row YC, as follows:
                        ;
                        ;   SC(1 0) = the address in nametable buffer 0
                        ;
                        ;   SC2(1 0) = the address in nametable buffer 1

 PLA                    ; Retrieve the character number we stored on the stack
                        ; above

 CMP #' '               ; If we are printing a space, jump to chpr25
 BEQ chpr25

.chpr23

 CLC                    ; Convert the ASCII number in A to the pattern number in
 ADC asciiToPattern     ; the PPU of the corresponding character image, by
                        ; adding asciiToPattern (which gets set when the view
                        ; is set up)

.chpr24

 LDY XC                 ; Set Y to the column of the text cursor - 1
 DEY

 STA (SC),Y             ; Set the Y-th nametable entry in nametable buffer 0
                        ; for the Y-th character on row YC, to the tile pattern
                        ; number for our character from the loaded font

 STA (SC2),Y            ; Set the Y-th nametable entry in nametable buffer 1
                        ; for the Y-th character on row YC, to the tile pattern
                        ; number for our character from the loaded font

 JMP chpr17             ; Jump to chpr17 to return from the subroutine, as we
                        ; are done printing this character

.chpr25

                        ; If we get here then we are printing a space

 LDY QQ11               ; If the view type in QQ11 is $9D (Long-range Chart with
 CPY #$9D               ; the normal font loaded), jump to chpr26 to use pattern
 BEQ chpr26             ; 0 as the space character

 CPY #$DF               ; If the view type in QQ11 is not $DF (Start screen with
 BNE chpr23             ; the normal font loaded), jump to chpr23 to convert
                        ; the ASCII number in A to the pattern number

.chpr26

 LDA #0                 ; This is either view $9D (Long-range Chart) or $DF
                        ; (Start screen), and in both these views the normal
                        ; font is loaded directly into the PPU at a different
                        ; pattern number to the other views, so we set A = 0 to
                        ; use as the space character, as that is always a blank
                        ; tile

 BEQ chpr24             ; Jump up to chpr24 to draw the character (this BEQ is
                        ; effectively a JMP as A is always zero)

; ******************************************************************************
;
;       Name: CHPR (Part 6 of 6)
;       Type: Subroutine
;   Category: Text
;    Summary: Print a character in the space view when the relevant font is not
;             loaded, merging the text with whatever is already on-screen
;
; ******************************************************************************

.chpr27

                        ; We jump here from below when the tile we are drawing
                        ; into is not empty

 LDX pattBufferHiDiv8   ; Set SC(1 0) = (pattBufferHiDiv8 A) * 8
 STX SC+1               ;             = (pattBufferHi 0) + A * 8
 ASL A                  ;
 ROL SC+1               ; So SC(1 0) is the address in the pattern buffer for
 ASL A                  ; tile number A (as each tile contains 8 bytes of
 ROL SC+1               ; pattern data), which means SC(1 0) points to the
 ASL A                  ; pattern data for the tile containing the character
 ROL SC+1               ; we are drawing
 STA SC

                        ; We now copy the pattern data for this character from
                        ; the address in P(2 1) to the pattern buffer address
                        ; in SC(1 0), using OR logic to merge the character with
                        ; the existing contents of the tile

 LDY #0                 ; We want to copy eight bytes of pattern data, as each
                        ; character has eight rows of eight pixels, so set a
                        ; byte index counter in Y

                        ; We repeat the following code eight times, so it copies
                        ; one whole pattern of eight bytes

 LDA (P+1),Y            ; Copy the Y-th pattern byte from P(2 1) to the Y-th
 ORA (SC),Y             ; byte of the pattern buffer in SC(1 0), OR'ing the byte
 STA (SC),Y             ; with the existing contents of the pattern buffer, and
 INY                    ; increment the byte counter in Y

 LDA (P+1),Y            ; Copy the Y-th pattern byte from P(2 1) to the Y-th
 ORA (SC),Y             ; byte of the pattern buffer in SC(1 0), OR'ing the byte
 STA (SC),Y             ; with the existing contents of the pattern buffer, and
 INY                    ; increment the byte counter in Y

 LDA (P+1),Y            ; Copy the Y-th pattern byte from P(2 1) to the Y-th
 ORA (SC),Y             ; byte of the pattern buffer in SC(1 0), OR'ing the byte
 STA (SC),Y             ; with the existing contents of the pattern buffer, and
 INY                    ; increment the byte counter in Y

 LDA (P+1),Y            ; Copy the Y-th pattern byte from P(2 1) to the Y-th
 ORA (SC),Y             ; byte of the pattern buffer in SC(1 0), OR'ing the byte
 STA (SC),Y             ; with the existing contents of the pattern buffer, and
 INY                    ; increment the byte counter in Y

 LDA (P+1),Y            ; Copy the Y-th pattern byte from P(2 1) to the Y-th
 ORA (SC),Y             ; byte of the pattern buffer in SC(1 0), OR'ing the byte
 STA (SC),Y             ; with the existing contents of the pattern buffer, and
 INY                    ; increment the byte counter in Y

 LDA (P+1),Y            ; Copy the Y-th pattern byte from P(2 1) to the Y-th
 ORA (SC),Y             ; byte of the pattern buffer in SC(1 0), OR'ing the byte
 STA (SC),Y             ; with the existing contents of the pattern buffer, and
 INY                    ; increment the byte counter in Y

 LDA (P+1),Y            ; Copy the Y-th pattern byte from P(2 1) to the Y-th
 ORA (SC),Y             ; byte of the pattern buffer in SC(1 0), OR'ing the byte
 STA (SC),Y             ; with the existing contents of the pattern buffer, and
 INY                    ; increment the byte counter in Y

 LDA (P+1),Y            ; Copy the Y-th pattern byte from P(2 1) to the Y-th
 ORA (SC),Y             ; byte of the pattern buffer in SC(1 0), OR'ing the byte
 STA (SC),Y             ; with the existing contents of the pattern buffer

 JMP chpr17             ; Jump to chpr17 to return from the subroutine, as we
                        ; are done printing this character

.chpr28

                        ; If we get here then this is the space view with no
                        ; font loaded, and we have set up P(2 1) to point to the
                        ; pattern data for the character we want to draw

 LDA #0                 ; Set SC+1 = 0 to act as the high byte of SC(1 0) in the
 STA SC+1               ; calculation below

 LDA YC                 ; Set A to the current text cursor row

 BNE chpr29             ; If the cursor is in row 0, set A = 255 so the value
 LDA #255               ; of A + 1 is 0 in the calculation below

.chpr29

 CLC                    ; Set (SC+1 A) = (A + 1) * 16
 ADC #1
 ASL A
 ASL A
 ASL A
 ASL A
 ROL SC+1

 SEC                    ; Set SC(1 0) = (nameBufferHi 0) + (SC+1 A) * 2 + 1
 ROL A                  ;             = (nameBufferHi 0) + (A + 1) * 32 + 1
 STA SC                 ;
 LDA SC+1               ; So SC(1 0) points to the entry in the nametable buffer
 ROL A                  ; for the start of the row below the text cursor, plus 1
 ADC nameBufferHi
 STA SC+1

 LDY XC                 ; Set Y to the column of the text cursor, minus one
 DEY

                        ; So SC(1 0) + Y now points to the nametable entry of
                        ; the tile where we want to draw our character

 LDA (SC),Y             ; If the nametable entry for the tile is not empty, then
 BNE chpr27             ; jump up to chpr27 to draw our character into the
                        ; existing pattern for this tile

 LDA firstFreeTile      ; If firstFreeTile is zero then we have run out of tiles
 BEQ chpr30             ; to use for drawing characters, so jump to chpr17 via
                        ; chpr30 to return from the subroutine without printing
                        ; anything

 STA (SC),Y             ; Otherwise firstFreeTile contains the number of the
                        ; next available tile for drawing, so allocate this
                        ; tile to cover the character that we want to draw by
                        ; setting the nametable entry to the tile number we just
                        ; fetched

 INC firstFreeTile      ; Increment firstFreeTile to point to the next available
                        ; tile for drawing, so it can be added to the nametable
                        ; the next time we need to draw into a tile

 LDX pattBufferHiDiv8   ; Set SC(1 0) = (pattBufferHiDiv8 A) * 8
 STX SC+1               ;             = (pattBufferHi 0) + A * 8
 ASL A                  ;
 ROL SC+1               ; So SC(1 0) is the address in the pattern buffer for
 ASL A                  ; tile number A (as each tile contains 8 bytes of
 ROL SC+1               ; pattern data), which means SC(1 0) points to the
 ASL A                  ; pattern data for the tile containing the character
 ROL SC+1               ; we are drawing
 STA SC

                        ; We now copy the pattern data for this character from
                        ; the address in P(2 1) to the pattern buffer address
                        ; in SC(1 0)

 LDY #0                 ; We want to copy eight bytes of pattern data, as each
                        ; character has eight rows of eight pixels, so set a
                        ; byte index counter in Y

                        ; We repeat the following code eight times, so it copies
                        ; one whole pattern of eight bytes

 LDA (P+1),Y            ; Copy the Y-th pattern byte from P(2 1) to the Y-th
 STA (SC),Y             ; byte of the pattern buffer in SC(1 0), and increment
 INY                    ; the byte counter in Y

 LDA (P+1),Y            ; Copy the Y-th pattern byte from P(2 1) to the Y-th
 STA (SC),Y             ; byte of the pattern buffer in SC(1 0), and increment
 INY                    ; the byte counter in Y

 LDA (P+1),Y            ; Copy the Y-th pattern byte from P(2 1) to the Y-th
 STA (SC),Y             ; byte of the pattern buffer in SC(1 0), and increment
 INY                    ; the byte counter in Y

 LDA (P+1),Y            ; Copy the Y-th pattern byte from P(2 1) to the Y-th
 STA (SC),Y             ; byte of the pattern buffer in SC(1 0), and increment
 INY                    ; the byte counter in Y

 LDA (P+1),Y            ; Copy the Y-th pattern byte from P(2 1) to the Y-th
 STA (SC),Y             ; byte of the pattern buffer in SC(1 0), and increment
 INY                    ; the byte counter in Y

 LDA (P+1),Y            ; Copy the Y-th pattern byte from P(2 1) to the Y-th
 STA (SC),Y             ; byte of the pattern buffer in SC(1 0), and increment
 INY                    ; the byte counter in Y

 LDA (P+1),Y            ; Copy the Y-th pattern byte from P(2 1) to the Y-th
 STA (SC),Y             ; byte of the pattern buffer in SC(1 0), and increment
 INY                    ; the byte counter in Y

 LDA (P+1),Y            ; Copy the Y-th pattern byte from P(2 1) to the Y-th
 STA (SC),Y             ; byte of the pattern buffer in SC(1 0)

.chpr30

 JMP chpr17             ; Jump to chpr17 to return from the subroutine, as we
                        ; are done printing this character

.chpr31

                        ; If we get here then this is the space view and the
                        ; text cursor is on row 0

 LDA #33                ; Set SC(1 0) to the address of tile 33 in the nametable
 STA SC                 ; buffer, which is the first tile on row 1
 LDA nameBufferHi
 STA SC+1

 LDY XC                 ; Set Y to the column of the text cursor - 1
 DEY

 JMP chpr15             ; Jump up to chpr15 to continue drawing the character

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
                        ;   " to $      so that maps À to à in the game font
                        ;   # to /      so that maps Ô to ô in the game font
                        ;   < to %      so that maps É to é in the game font
                        ;   = to *      so that maps È to è in the game font
                        ;   @ to `      so that maps Ç to ç in the game font

 EQUS "abcdefghijklm"   ; Capital letters map to their lower case equivalents
 EQUS "nopqrstuvwxyz"

 EQUS "{|};+`"          ; These punctuation characters map to themselves apart
                        ; from the following (ASCII on left, NES on right):
                        ;
                        ;   [ to {      so that maps Ä to ä in the game font
                        ;   \ to |      so that maps Ö to ö in the game font
                        ;   ] to }      so that maps Ü to ü in the game font
                        ;   ^ to ;      so that maps ß to ß in the game font
                        ;   _ to +      so that maps Ê to ê in the game font

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
