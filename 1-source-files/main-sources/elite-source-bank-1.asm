; ******************************************************************************
;
; NES ELITE GAME SOURCE (BANK 1)
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
;   * bank1.bin
;
; ******************************************************************************

 _BANK = 1

 INCLUDE "1-source-files/main-sources/elite-build-options.asm"

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
;       Name: Unused copy of XX21
;       Type: Variable
;   Category: Drawing ships
;    Summary: Remnants of an unused copy of the XX21 ship blueprints lookup
;             table
;
; ******************************************************************************

 EQUW SHIP_ASTEROID     ; These bytes appear to be unused
 EQUW SHIP_SPLINTER     ;
 EQUW SHIP_SHUTTLE      ; This is a truncated copy of XX21, the table of ship
 EQUW SHIP_TRANSPORTER  ; blueprint addresses. This version only contains the
 EQUW SHIP_COBRA_MK_3   ; asteroid onwards, and it is not used anywhere, so it
 EQUW SHIP_PYTHON       ; looks like this is all that remains of a copy of XX21
 EQUW SHIP_BOA          ; that was assembled at address $8000, and then
 EQUW SHIP_ANACONDA     ; partially overwritten
 EQUW SHIP_ROCK_HERMIT
 EQUW SHIP_VIPER
 EQUW SHIP_SIDEWINDER
 EQUW SHIP_MAMBA
 EQUW SHIP_KRAIT
 EQUW SHIP_ADDER
 EQUW SHIP_GECKO
 EQUW SHIP_COBRA_MK_1
 EQUW SHIP_WORM
 EQUW SHIP_COBRA_MK_3_P
 EQUW SHIP_ASP_MK_2
 EQUW SHIP_PYTHON_P
 EQUW SHIP_FER_DE_LANCE
 EQUW SHIP_MORAY
 EQUW SHIP_THARGOID
 EQUW SHIP_THARGON
 EQUW SHIP_CONSTRICTOR
 EQUW SHIP_COUGAR
 EQUW SHIP_DODO

; ******************************************************************************
;
;       Name: E%
;       Type: Variable
;   Category: Drawing ships
;    Summary: Ship blueprints default NEWB flags
;  Deep dive: Ship blueprints
;             Advanced tactics with the NEWB flags
;
; ------------------------------------------------------------------------------
;
; When spawning a new ship, the bits from this table are applied to the new
; ship's NEWB flags in byte #36 (i.e. a set bit in this table will set that bit
; in the NEWB flags). In other words, if a ship blueprint is set to one of the
; following, then all spawned ships of that type will be too: trader, bounty
; hunter, hostile, pirate, innocent, cop.
;
; The NEWB flags are as follows:
;
;   * Bit 0: Trader flag (0 = not a trader, 1 = trader)
;   * Bit 1: Bounty hunter flag (0 = not a bounty hunter, 1 = bounty hunter)
;   * Bit 2: Hostile flag (0 = not hostile, 1 = hostile)
;   * Bit 3: Pirate flag (0 = not a pirate, 1 = pirate)
;   * Bit 4: Docking flag (0 = not docking, 1 = docking)
;   * Bit 5: Innocent bystander (0 = normal, 1 = innocent bystander)
;   * Bit 6: Cop flag (0 = not a cop, 1 = cop)
;   * Bit 7: For spawned ships: ship been scooped or has docked
;             For blueprints: this ship type has an escape pod fitted
;
; See the deep dive on "Advanced tactics with the NEWB flags" for details of
; how this works.
;
; ******************************************************************************

.E%

 EQUB %00000000         ; Missile
 EQUB %00000000         ; Coriolis space station
 EQUB %00000001         ; Escape pod                                      Trader
 EQUB %00000000         ; Alloy plate
 EQUB %00000000         ; Cargo canister
 EQUB %00000000         ; Boulder
 EQUB %00000000         ; Asteroid
 EQUB %00000000         ; Splinter
 EQUB %00100001         ; Shuttle                               Trader, innocent
 EQUB %01100001         ; Transporter                      Trader, innocent, cop
 EQUB %10100000         ; Cobra Mk III                      Innocent, escape pod
 EQUB %10100000         ; Python                            Innocent, escape pod
 EQUB %10100000         ; Boa                               Innocent, escape pod
 EQUB %10100001         ; Anaconda                  Trader, innocent, escape pod
 EQUB %10100001         ; Rock hermit (asteroid)    Trader, innocent, escape pod
 EQUB %11000010         ; Viper                   Bounty hunter, cop, escape pod
 EQUB %00001100         ; Sidewinder                             Hostile, pirate
 EQUB %10001100         ; Mamba                      Hostile, pirate, escape pod
 EQUB %10001100         ; Krait                      Hostile, pirate, escape pod
 EQUB %10001100         ; Adder                      Hostile, pirate, escape pod
 EQUB %00001100         ; Gecko                                  Hostile, pirate
 EQUB %10001100         ; Cobra Mk I                 Hostile, pirate, escape pod
 EQUB %00000101         ; Worm                                   Hostile, trader
 EQUB %10001100         ; Cobra Mk III (pirate)      Hostile, pirate, escape pod
 EQUB %10001100         ; Asp Mk II                  Hostile, pirate, escape pod
 EQUB %10001100         ; Python (pirate)            Hostile, pirate, escape pod
 EQUB %10000010         ; Fer-de-lance                 Bounty hunter, escape pod
 EQUB %00001100         ; Moray                                  Hostile, pirate
 EQUB %00001100         ; Thargoid                               Hostile, pirate
 EQUB %00000100         ; Thargon                                        Hostile
 EQUB %00000100         ; Constrictor                                    Hostile
 EQUB %00100000         ; Cougar                                        Innocent

 EQUB 0                 ; This byte appears to be unused

; ******************************************************************************
;
;       Name: KWL%
;       Type: Variable
;   Category: Status
;    Summary: Fractional number of kills awarded for destroying each type of
;             ship
;
; ------------------------------------------------------------------------------
;
; This figure contains the fractional part of the points that are added to the
; combat rank in TALLY when destroying a ship of this type. This is different to
; the original BBC Micro versions, where you always get a single combat point
; for everything you kill; in the Master version, it's more sophisticated.
;
; The integral part is stored in the KWH% table.
;
; Each fraction is stored as the numerator in a fraction with a denominator of
; 256, so 149 represents 149 / 256 = 0.58203125 points.
;
; Note that in the NES version, the kill count is doubled before it is added to
; the kill tally.
;
; ******************************************************************************

.KWL%

 EQUB 149               ; Missile                               0.58203125
 EQUB 0                 ; Coriolis space station                0.0
 EQUB 16                ; Escape pod                            0.0625
 EQUB 10                ; Alloy plate                           0.0390625
 EQUB 10                ; Cargo canister                        0.0390625
 EQUB 6                 ; Boulder                               0.0234375
 EQUB 8                 ; Asteroid                              0.03125
 EQUB 10                ; Splinter                              0.0390625
 EQUB 16                ; Shuttle                               0.0625
 EQUB 17                ; Transporter                           0.06640625
 EQUB 234               ; Cobra Mk III                          0.9140625
 EQUB 170               ; Python                                0.6640625
 EQUB 213               ; Boa                                   0.83203125
 EQUB 0                 ; Anaconda                              1.0
 EQUB 85                ; Rock hermit (asteroid)                0.33203125
 EQUB 26                ; Viper                                 0.1015625
 EQUB 85                ; Sidewinder                            0.33203125
 EQUB 128               ; Mamba                                 0.5
 EQUB 85                ; Krait                                 0.33203125
 EQUB 90                ; Adder                                 0.3515625
 EQUB 85                ; Gecko                                 0.33203125
 EQUB 170               ; Cobra Mk I                            0.6640625
 EQUB 50                ; Worm                                  0.1953125
 EQUB 42                ; Cobra Mk III (pirate)                 1.1640625
 EQUB 21                ; Asp Mk II                             1.08203125
 EQUB 42                ; Python (pirate)                       1.1640625
 EQUB 64                ; Fer-de-lance                          1.25
 EQUB 192               ; Moray                                 0.75
 EQUB 170               ; Thargoid                              2.6640625
 EQUB 33                ; Thargon                               0.12890625
 EQUB 85                ; Constrictor                           5.33203125
 EQUB 85                ; Cougar                                5.33203125
 EQUB 0                 ; Dodecahedron ("Dodo") space station   0.0

; ******************************************************************************
;
;       Name: KWH%
;       Type: Variable
;   Category: Status
;    Summary: Integer number of kills awarded for destroying each type of ship
;
; ------------------------------------------------------------------------------
;
; This figure contains the integer part of the points that are added to the
; combat rank in TALLY when destroying a ship of this type. This is different to
; the original BBC Micro versions, where you always get a single combat point
; for everything you kill; in the Master version, it's more sophisticated.
;
; The fractional part is stored in the KWL% table.
;
; Note that in the NES version, the kill count is doubled before it is added to
; the kill tally.
;
; ******************************************************************************

.KWH%

 EQUB 0                 ; Missile                               0.58203125
 EQUB 0                 ; Coriolis space station                0.0
 EQUB 0                 ; Escape pod                            0.0625
 EQUB 0                 ; Alloy plate                           0.0390625
 EQUB 0                 ; Cargo canister                        0.0390625
 EQUB 0                 ; Boulder                               0.0234375
 EQUB 0                 ; Asteroid                              0.03125
 EQUB 0                 ; Splinter                              0.0390625
 EQUB 0                 ; Shuttle                               0.0625
 EQUB 0                 ; Transporter                           0.06640625
 EQUB 0                 ; Cobra Mk III                          0.9140625
 EQUB 0                 ; Python                                0.6640625
 EQUB 0                 ; Boa                                   0.83203125
 EQUB 1                 ; Anaconda                              1.0
 EQUB 0                 ; Rock hermit (asteroid)                0.33203125
 EQUB 0                 ; Viper                                 0.1015625
 EQUB 0                 ; Sidewinder                            0.33203125
 EQUB 0                 ; Mamba                                 0.5
 EQUB 0                 ; Krait                                 0.33203125
 EQUB 0                 ; Adder                                 0.3515625
 EQUB 0                 ; Gecko                                 0.33203125
 EQUB 0                 ; Cobra Mk I                            0.6640625
 EQUB 0                 ; Worm                                  0.1953125
 EQUB 1                 ; Cobra Mk III (pirate)                 1.1640625
 EQUB 1                 ; Asp Mk II                             1.08203125
 EQUB 1                 ; Python (pirate)                       1.1640625
 EQUB 1                 ; Fer-de-lance                          1.25
 EQUB 0                 ; Moray                                 0.75
 EQUB 2                 ; Thargoid                              2.6640625
 EQUB 0                 ; Thargon                               0.12890625
 EQUB 5                 ; Constrictor                           5.33203125
 EQUB 5                 ; Cougar                                5.33203125
 EQUB 0                 ; Dodecahedron ("Dodo") space station   0.0

; ******************************************************************************
;
;       Name: SHIP_MISSILE
;       Type: Variable
;   Category: Drawing ships
;    Summary: Ship blueprint for a missile
;  Deep dive: Ship blueprints
;
; ******************************************************************************

.SHIP_MISSILE

 EQUB 0                 ; Max. canisters on demise = 0
 EQUW 40 * 40           ; Targetable area          = 40 * 40

 EQUB LO(SHIP_MISSILE_EDGES - SHIP_MISSILE)        ; Edges data offset (low)
 EQUB LO(SHIP_MISSILE_FACES - SHIP_MISSILE)        ; Faces data offset (low)

 EQUB 85                ; Max. edge count          = (85 - 1) / 4 = 21
 EQUB 0                 ; Gun vertex               = 0
 EQUB 10                ; Explosion count          = 1, as (4 * n) + 6 = 10
 EQUB 102               ; Number of vertices       = 102 / 6 = 17
 EQUB 24                ; Number of edges          = 24
 EQUW 0                 ; Bounty                   = 0
 EQUB 36                ; Number of faces          = 36 / 4 = 9
 EQUB 14                ; Visibility distance      = 14
 EQUB 2                 ; Max. energy              = 2
 EQUB 44                ; Max. speed               = 44

 EQUB HI(SHIP_MISSILE_EDGES - SHIP_MISSILE)        ; Edges data offset (high)
 EQUB HI(SHIP_MISSILE_FACES - SHIP_MISSILE)        ; Faces data offset (high)

 EQUB 2                 ; Normals are scaled by    = 2^2 = 4
 EQUB %00000000         ; Laser power              = 0
                        ; Missiles                 = 0

.SHIP_MISSILE_VERTICES

      ;    x,    y,    z, face1, face2, face3, face4, visibility
 VERTEX    0,    0,   68,     0,      1,    2,     3,         31    ; Vertex 0
 VERTEX    8,   -8,   36,     1,      2,    4,     5,         31    ; Vertex 1
 VERTEX    8,    8,   36,     2,      3,    4,     7,         31    ; Vertex 2
 VERTEX   -8,    8,   36,     0,      3,    6,     7,         31    ; Vertex 3
 VERTEX   -8,   -8,   36,     0,      1,    5,     6,         31    ; Vertex 4
 VERTEX    8,    8,  -44,     4,      7,    8,     8,         31    ; Vertex 5
 VERTEX    8,   -8,  -44,     4,      5,    8,     8,         31    ; Vertex 6
 VERTEX   -8,   -8,  -44,     5,      6,    8,     8,         31    ; Vertex 7
 VERTEX   -8,    8,  -44,     6,      7,    8,     8,         31    ; Vertex 8
 VERTEX   12,   12,  -44,     4,      7,    8,     8,          8    ; Vertex 9
 VERTEX   12,  -12,  -44,     4,      5,    8,     8,          8    ; Vertex 10
 VERTEX  -12,  -12,  -44,     5,      6,    8,     8,          8    ; Vertex 11
 VERTEX  -12,   12,  -44,     6,      7,    8,     8,          8    ; Vertex 12
 VERTEX   -8,    8,  -12,     6,      7,    7,     7,          8    ; Vertex 13
 VERTEX   -8,   -8,  -12,     5,      6,    6,     6,          8    ; Vertex 14
 VERTEX    8,    8,  -12,     4,      7,    7,     7,          8    ; Vertex 15
 VERTEX    8,   -8,  -12,     4,      5,    5,     5,          8    ; Vertex 16

.SHIP_MISSILE_EDGES

    ; vertex1, vertex2, face1, face2, visibility
 EDGE       0,       1,     1,     2,         31    ; Edge 0
 EDGE       0,       2,     2,     3,         31    ; Edge 1
 EDGE       0,       3,     0,     3,         31    ; Edge 2
 EDGE       0,       4,     0,     1,         31    ; Edge 3
 EDGE       1,       2,     4,     2,         31    ; Edge 4
 EDGE       1,       4,     1,     5,         31    ; Edge 5
 EDGE       3,       4,     0,     6,         31    ; Edge 6
 EDGE       2,       3,     3,     7,         31    ; Edge 7
 EDGE       2,       5,     4,     7,         31    ; Edge 8
 EDGE       1,       6,     4,     5,         31    ; Edge 9
 EDGE       4,       7,     5,     6,         31    ; Edge 10
 EDGE       3,       8,     6,     7,         31    ; Edge 11
 EDGE       7,       8,     6,     8,         31    ; Edge 12
 EDGE       5,       8,     7,     8,         31    ; Edge 13
 EDGE       5,       6,     4,     8,         31    ; Edge 14
 EDGE       6,       7,     5,     8,         31    ; Edge 15
 EDGE       6,      10,     5,     8,          8    ; Edge 16
 EDGE       5,       9,     7,     8,          8    ; Edge 17
 EDGE       8,      12,     7,     8,          8    ; Edge 18
 EDGE       7,      11,     5,     8,          8    ; Edge 19
 EDGE       9,      15,     4,     7,          8    ; Edge 20
 EDGE      10,      16,     4,     5,          8    ; Edge 21
 EDGE      12,      13,     6,     7,          8    ; Edge 22
 EDGE      11,      14,     5,     6,          8    ; Edge 23

.SHIP_MISSILE_FACES

    ; normal_x, normal_y, normal_z, visibility
 FACE      -64,        0,       16,         31    ; Face 0
 FACE        0,      -64,       16,         31    ; Face 1
 FACE       64,        0,       16,         31    ; Face 2
 FACE        0,       64,       16,         31    ; Face 3
 FACE       32,        0,        0,         31    ; Face 4
 FACE        0,      -32,        0,         31    ; Face 5
 FACE      -32,        0,        0,         31    ; Face 6
 FACE        0,       32,        0,         31    ; Face 7
 FACE        0,        0,     -176,         31    ; Face 8

; ******************************************************************************
;
;       Name: SHIP_CORIOLIS
;       Type: Variable
;   Category: Drawing ships
;    Summary: Ship blueprint for a Coriolis space station
;  Deep dive: Ship blueprints
;
; ******************************************************************************

.SHIP_CORIOLIS

 EQUB 0                 ; Max. canisters on demise = 0
 EQUW 160 * 160         ; Targetable area          = 160 * 160

 EQUB LO(SHIP_CORIOLIS_EDGES - SHIP_CORIOLIS)      ; Edges data offset (low)
 EQUB LO(SHIP_CORIOLIS_FACES - SHIP_CORIOLIS)      ; Faces data offset (low)

 EQUB 89                ; Max. edge count          = (89 - 1) / 4 = 22
 EQUB 0                 ; Gun vertex               = 0
 EQUB 6                 ; Explosion count          = 0, as (4 * n) + 6 = 6
 EQUB 96                ; Number of vertices       = 96 / 6 = 16
 EQUB 28                ; Number of edges          = 28
 EQUW 0                 ; Bounty                   = 0
 EQUB 56                ; Number of faces          = 56 / 4 = 14
 EQUB 120               ; Visibility distance      = 120
 EQUB 240               ; Max. energy              = 240
 EQUB 0                 ; Max. speed               = 0

 EQUB HI(SHIP_CORIOLIS_EDGES - SHIP_CORIOLIS)      ; Edges data offset (high)
 EQUB HI(SHIP_CORIOLIS_FACES - SHIP_CORIOLIS)      ; Faces data offset (high)

 EQUB 0                 ; Normals are scaled by    = 2^0 = 1
 EQUB %00000110         ; Laser power              = 0
                        ; Missiles                 = 6

.SHIP_CORIOLIS_VERTICES

      ;    x,    y,    z, face1, face2, face3, face4, visibility
 VERTEX  160,    0,  160,     0,      1,    2,     6,         31    ; Vertex 0
 VERTEX    0,  160,  160,     0,      2,    3,     8,         31    ; Vertex 1
 VERTEX -160,    0,  160,     0,      3,    4,     7,         31    ; Vertex 2
 VERTEX    0, -160,  160,     0,      1,    4,     5,         31    ; Vertex 3
 VERTEX  160, -160,    0,     1,      5,    6,    10,         31    ; Vertex 4
 VERTEX  160,  160,    0,     2,      6,    8,    11,         31    ; Vertex 5
 VERTEX -160,  160,    0,     3,      7,    8,    12,         31    ; Vertex 6
 VERTEX -160, -160,    0,     4,      5,    7,     9,         31    ; Vertex 7
 VERTEX  160,    0, -160,     6,     10,   11,    13,         31    ; Vertex 8
 VERTEX    0,  160, -160,     8,     11,   12,    13,         31    ; Vertex 9
 VERTEX -160,    0, -160,     7,      9,   12,    13,         31    ; Vertex 10
 VERTEX    0, -160, -160,     5,      9,   10,    13,         31    ; Vertex 11
 VERTEX   10,  -30,  160,     0,      0,    0,     0,         30    ; Vertex 12
 VERTEX   10,   30,  160,     0,      0,    0,     0,         30    ; Vertex 13
 VERTEX  -10,   30,  160,     0,      0,    0,     0,         30    ; Vertex 14
 VERTEX  -10,  -30,  160,     0,      0,    0,     0,         30    ; Vertex 15

.SHIP_CORIOLIS_EDGES

    ; vertex1, vertex2, face1, face2, visibility
 EDGE       0,       3,     0,     1,         31    ; Edge 0
 EDGE       0,       1,     0,     2,         31    ; Edge 1
 EDGE       1,       2,     0,     3,         31    ; Edge 2
 EDGE       2,       3,     0,     4,         31    ; Edge 3
 EDGE       3,       4,     1,     5,         31    ; Edge 4
 EDGE       0,       4,     1,     6,         31    ; Edge 5
 EDGE       0,       5,     2,     6,         31    ; Edge 6
 EDGE       5,       1,     2,     8,         31    ; Edge 7
 EDGE       1,       6,     3,     8,         31    ; Edge 8
 EDGE       2,       6,     3,     7,         31    ; Edge 9
 EDGE       2,       7,     4,     7,         31    ; Edge 10
 EDGE       3,       7,     4,     5,         31    ; Edge 11
 EDGE       8,      11,    10,    13,         31    ; Edge 12
 EDGE       8,       9,    11,    13,         31    ; Edge 13
 EDGE       9,      10,    12,    13,         31    ; Edge 14
 EDGE      10,      11,     9,    13,         31    ; Edge 15
 EDGE       4,      11,     5,    10,         31    ; Edge 16
 EDGE       4,       8,     6,    10,         31    ; Edge 17
 EDGE       5,       8,     6,    11,         31    ; Edge 18
 EDGE       5,       9,     8,    11,         31    ; Edge 19
 EDGE       6,       9,     8,    12,         31    ; Edge 20
 EDGE       6,      10,     7,    12,         31    ; Edge 21
 EDGE       7,      10,     7,     9,         31    ; Edge 22
 EDGE       7,      11,     5,     9,         31    ; Edge 23
 EDGE      12,      13,     0,     0,         30    ; Edge 24
 EDGE      13,      14,     0,     0,         30    ; Edge 25
 EDGE      14,      15,     0,     0,         30    ; Edge 26
 EDGE      15,      12,     0,     0,         30    ; Edge 27

.SHIP_CORIOLIS_FACES

    ; normal_x, normal_y, normal_z, visibility
 FACE        0,        0,      160,         31    ; Face 0
 FACE      107,     -107,      107,         31    ; Face 1
 FACE      107,      107,      107,         31    ; Face 2
 FACE     -107,      107,      107,         31    ; Face 3
 FACE     -107,     -107,      107,         31    ; Face 4
 FACE        0,     -160,        0,         31    ; Face 5
 FACE      160,        0,        0,         31    ; Face 6
 FACE     -160,        0,        0,         31    ; Face 7
 FACE        0,      160,        0,         31    ; Face 8
 FACE     -107,     -107,     -107,         31    ; Face 9
 FACE      107,     -107,     -107,         31    ; Face 10
 FACE      107,      107,     -107,         31    ; Face 11
 FACE     -107,      107,     -107,         31    ; Face 12
 FACE        0,        0,     -160,         31    ; Face 13

; ******************************************************************************
;
;       Name: SHIP_ESCAPE_POD
;       Type: Variable
;   Category: Drawing ships
;    Summary: Ship blueprint for an escape pod
;  Deep dive: Ship blueprints
;
; ******************************************************************************

.SHIP_ESCAPE_POD

 EQUB 0 + (2 << 4)      ; Max. canisters on demise = 0
                        ; Market item when scooped = 2 + 1 = 3 (slaves)
 EQUW 16 * 16           ; Targetable area          = 16 * 16

 EQUB LO(SHIP_ESCAPE_POD_EDGES - SHIP_ESCAPE_POD)  ; Edges data offset (low)
 EQUB LO(SHIP_ESCAPE_POD_FACES - SHIP_ESCAPE_POD)  ; Faces data offset (low)

 EQUB 29                ; Max. edge count          = (29 - 1) / 4 = 7
 EQUB 0                 ; Gun vertex               = 0
 EQUB 22                ; Explosion count          = 4, as (4 * n) + 6 = 22
 EQUB 24                ; Number of vertices       = 24 / 6 = 4
 EQUB 6                 ; Number of edges          = 6
 EQUW 0                 ; Bounty                   = 0
 EQUB 16                ; Number of faces          = 16 / 4 = 4
 EQUB 8                 ; Visibility distance      = 8
 EQUB 17                ; Max. energy              = 17
 EQUB 8                 ; Max. speed               = 8

 EQUB HI(SHIP_ESCAPE_POD_EDGES - SHIP_ESCAPE_POD)  ; Edges data offset (high)
 EQUB HI(SHIP_ESCAPE_POD_FACES - SHIP_ESCAPE_POD)  ; Faces data offset (high)

 EQUB 4                 ; Normals are scaled by    =  2^4 = 16
 EQUB %00000000         ; Laser power              = 0
                        ; Missiles                 = 0

.SHIP_ESCAPE_POD_VERTICES

      ;    x,    y,    z, face1, face2, face3, face4, visibility
 VERTEX   -7,    0,   36,     2,      1,    3,     3,         31    ; Vertex 0
 VERTEX   -7,  -14,  -12,     2,      0,    3,     3,         31    ; Vertex 1
 VERTEX   -7,   14,  -12,     1,      0,    3,     3,         31    ; Vertex 2
 VERTEX   21,    0,    0,     1,      0,    2,     2,         31    ; Vertex 3

.SHIP_ESCAPE_POD_EDGES

    ; vertex1, vertex2, face1, face2, visibility
 EDGE       0,       1,     3,     2,         31    ; Edge 0
 EDGE       1,       2,     3,     0,         31    ; Edge 1
 EDGE       2,       3,     1,     0,         31    ; Edge 2
 EDGE       3,       0,     2,     1,         31    ; Edge 3
 EDGE       0,       2,     3,     1,         31    ; Edge 4
 EDGE       3,       1,     2,     0,         31    ; Edge 5

.SHIP_ESCAPE_POD_FACES

    ; normal_x, normal_y, normal_z, visibility
 FACE       52,        0,     -122,         31    ; Face 0
 FACE       39,      103,       30,         31    ; Face 1
 FACE       39,     -103,       30,         31    ; Face 2
 FACE     -112,        0,        0,         31    ; Face 3

; ******************************************************************************
;
;       Name: SHIP_PLATE
;       Type: Variable
;   Category: Drawing ships
;    Summary: Ship blueprint for an alloy plate
;  Deep dive: Ship blueprints
;
; ******************************************************************************

.SHIP_PLATE

 EQUB 0 + (8 << 4)      ; Max. canisters on demise = 0
                        ; Market item when scooped = 8 + 1 = 9 (Alloys)
 EQUW 10 * 10           ; Targetable area          = 10 * 10

 EQUB LO(SHIP_PLATE_EDGES - SHIP_PLATE)            ; Edges data offset (low)
 EQUB LO(SHIP_PLATE_FACES - SHIP_PLATE)            ; Faces data offset (low)

 EQUB 21                ; Max. edge count          = (21 - 1) / 4 = 5
 EQUB 0                 ; Gun vertex               = 0
 EQUB 10                ; Explosion count          = 1, as (4 * n) + 6 = 10
 EQUB 24                ; Number of vertices       = 24 / 6 = 4
 EQUB 4                 ; Number of edges          = 4
 EQUW 0                 ; Bounty                   = 0
 EQUB 4                 ; Number of faces          = 4 / 4 = 1
 EQUB 5                 ; Visibility distance      = 5
 EQUB 16                ; Max. energy              = 16
 EQUB 16                ; Max. speed               = 16

 EQUB HI(SHIP_PLATE_EDGES - SHIP_PLATE)            ; Edges data offset (high)
 EQUB HI(SHIP_PLATE_FACES - SHIP_PLATE)            ; Faces data offset (high)

 EQUB 3                 ; Normals are scaled by    = 2^3 = 8
 EQUB %00000000         ; Laser power              = 0
                        ; Missiles                 = 0

.SHIP_PLATE_VERTICES

      ;    x,    y,    z, face1, face2, face3, face4, visibility
 VERTEX  -15,  -22,   -9,    15,     15,   15,    15,         31    ; Vertex 0
 VERTEX  -15,   38,   -9,    15,     15,   15,    15,         31    ; Vertex 1
 VERTEX   19,   32,   11,    15,     15,   15,    15,         20    ; Vertex 2
 VERTEX   10,  -46,    6,    15,     15,   15,    15,         20    ; Vertex 3

.SHIP_PLATE_EDGES

    ; vertex1, vertex2, face1, face2, visibility
 EDGE       0,       1,    15,    15,         31    ; Edge 0
 EDGE       1,       2,    15,    15,         16    ; Edge 1
 EDGE       2,       3,    15,    15,         20    ; Edge 2
 EDGE       3,       0,    15,    15,         16    ; Edge 3

.SHIP_PLATE_FACES

    ; normal_x, normal_y, normal_z, visibility
 FACE        0,        0,        0,          0    ; Face 0

; ******************************************************************************
;
;       Name: SHIP_CANISTER
;       Type: Variable
;   Category: Drawing ships
;    Summary: Ship blueprint for a cargo canister
;  Deep dive: Ship blueprints
;
; ******************************************************************************

.SHIP_CANISTER

 EQUB 0                 ; Max. canisters on demise = 0
 EQUW 20 * 20           ; Targetable area          = 20 * 20

 EQUB LO(SHIP_CANISTER_EDGES - SHIP_CANISTER)      ; Edges data offset (low)
 EQUB LO(SHIP_CANISTER_FACES - SHIP_CANISTER)      ; Faces data offset (low)

 EQUB 53                ; Max. edge count          = (53 - 1) / 4 = 13
 EQUB 0                 ; Gun vertex               = 0
 EQUB 18                ; Explosion count          = 3, as (4 * n) + 6 = 18
 EQUB 60                ; Number of vertices       = 60 / 6 = 10
 EQUB 15                ; Number of edges          = 15
 EQUW 0                 ; Bounty                   = 0
 EQUB 28                ; Number of faces          = 28 / 4 = 7
 EQUB 12                ; Visibility distance      = 12
 EQUB 17                ; Max. energy              = 17
 EQUB 15                ; Max. speed               = 15

 EQUB HI(SHIP_CANISTER_EDGES - SHIP_CANISTER)      ; Edges data offset (high)
 EQUB HI(SHIP_CANISTER_FACES - SHIP_CANISTER)      ; Faces data offset (high)

 EQUB 2                 ; Normals are scaled by    = 2^2 = 4
 EQUB %00000000         ; Laser power              = 0
                        ; Missiles                 = 0

.SHIP_CANISTER_VERTICES

      ;    x,    y,    z, face1, face2, face3, face4, visibility
 VERTEX   24,   16,    0,     0,      1,    5,     5,         31    ; Vertex 0
 VERTEX   24,    5,   15,     0,      1,    2,     2,         31    ; Vertex 1
 VERTEX   24,  -13,    9,     0,      2,    3,     3,         31    ; Vertex 2
 VERTEX   24,  -13,   -9,     0,      3,    4,     4,         31    ; Vertex 3
 VERTEX   24,    5,  -15,     0,      4,    5,     5,         31    ; Vertex 4
 VERTEX  -24,   16,    0,     1,      5,    6,     6,         31    ; Vertex 5
 VERTEX  -24,    5,   15,     1,      2,    6,     6,         31    ; Vertex 6
 VERTEX  -24,  -13,    9,     2,      3,    6,     6,         31    ; Vertex 7
 VERTEX  -24,  -13,   -9,     3,      4,    6,     6,         31    ; Vertex 8
 VERTEX  -24,    5,  -15,     4,      5,    6,     6,         31    ; Vertex 9

.SHIP_CANISTER_EDGES

    ; vertex1, vertex2, face1, face2, visibility
 EDGE       0,       1,     0,     1,         31    ; Edge 0
 EDGE       1,       2,     0,     2,         31    ; Edge 1
 EDGE       2,       3,     0,     3,         31    ; Edge 2
 EDGE       3,       4,     0,     4,         31    ; Edge 3
 EDGE       0,       4,     0,     5,         31    ; Edge 4
 EDGE       0,       5,     1,     5,         31    ; Edge 5
 EDGE       1,       6,     1,     2,         31    ; Edge 6
 EDGE       2,       7,     2,     3,         31    ; Edge 7
 EDGE       3,       8,     3,     4,         31    ; Edge 8
 EDGE       4,       9,     4,     5,         31    ; Edge 9
 EDGE       5,       6,     1,     6,         31    ; Edge 10
 EDGE       6,       7,     2,     6,         31    ; Edge 11
 EDGE       7,       8,     3,     6,         31    ; Edge 12
 EDGE       8,       9,     4,     6,         31    ; Edge 13
 EDGE       9,       5,     5,     6,         31    ; Edge 14

.SHIP_CANISTER_FACES

    ; normal_x, normal_y, normal_z, visibility
 FACE       96,        0,        0,         31    ; Face 0
 FACE        0,       41,       30,         31    ; Face 1
 FACE        0,      -18,       48,         31    ; Face 2
 FACE        0,      -51,        0,         31    ; Face 3
 FACE        0,      -18,      -48,         31    ; Face 4
 FACE        0,       41,      -30,         31    ; Face 5
 FACE      -96,        0,        0,         31    ; Face 6

; ******************************************************************************
;
;       Name: SHIP_BOULDER
;       Type: Variable
;   Category: Drawing ships
;    Summary: Ship blueprint for a boulder
;  Deep dive: Ship blueprints
;
; ******************************************************************************

.SHIP_BOULDER

 EQUB 0                 ; Max. canisters on demise = 0
 EQUW 30 * 30           ; Targetable area          = 30 * 30

 EQUB LO(SHIP_BOULDER_EDGES - SHIP_BOULDER)        ; Edges data offset (low)
 EQUB LO(SHIP_BOULDER_FACES - SHIP_BOULDER)        ; Faces data offset (low)

 EQUB 49                ; Max. edge count          = (49 - 1) / 4 = 12
 EQUB 0                 ; Gun vertex               = 0
 EQUB 14                ; Explosion count          = 2, as (4 * n) + 6 = 14
 EQUB 42                ; Number of vertices       = 42 / 6 = 7
 EQUB 15                ; Number of edges          = 15
 EQUW 1                 ; Bounty                   = 1
 EQUB 40                ; Number of faces          = 40 / 4 = 10
 EQUB 20                ; Visibility distance      = 20
 EQUB 20                ; Max. energy              = 20
 EQUB 30                ; Max. speed               = 30

 EQUB HI(SHIP_BOULDER_EDGES - SHIP_BOULDER)        ; Edges data offset (high)
 EQUB HI(SHIP_BOULDER_FACES - SHIP_BOULDER)        ; Faces data offset (high)

 EQUB 2                 ; Normals are scaled by    = 2^2 = 4
 EQUB %00000000         ; Laser power              = 0
                        ; Missiles                 = 0

.SHIP_BOULDER_VERTICES

      ;    x,    y,    z, face1, face2, face3, face4, visibility
 VERTEX  -18,   37,  -11,     1,      0,    9,     5,         31    ; Vertex 0
 VERTEX   30,    7,   12,     2,      1,    6,     5,         31    ; Vertex 1
 VERTEX   28,   -7,  -12,     3,      2,    7,     6,         31    ; Vertex 2
 VERTEX    2,    0,  -39,     4,      3,    8,     7,         31    ; Vertex 3
 VERTEX  -28,   34,  -30,     4,      0,    9,     8,         31    ; Vertex 4
 VERTEX    5,  -10,   13,    15,     15,   15,    15,         31    ; Vertex 5
 VERTEX   20,   17,  -30,    15,     15,   15,    15,         31    ; Vertex 6

.SHIP_BOULDER_EDGES

    ; vertex1, vertex2, face1, face2, visibility
 EDGE       0,       1,     5,     1,         31    ; Edge 0
 EDGE       1,       2,     6,     2,         31    ; Edge 1
 EDGE       2,       3,     7,     3,         31    ; Edge 2
 EDGE       3,       4,     8,     4,         31    ; Edge 3
 EDGE       4,       0,     9,     0,         31    ; Edge 4
 EDGE       0,       5,     1,     0,         31    ; Edge 5
 EDGE       1,       5,     2,     1,         31    ; Edge 6
 EDGE       2,       5,     3,     2,         31    ; Edge 7
 EDGE       3,       5,     4,     3,         31    ; Edge 8
 EDGE       4,       5,     4,     0,         31    ; Edge 9
 EDGE       0,       6,     9,     5,         31    ; Edge 10
 EDGE       1,       6,     6,     5,         31    ; Edge 11
 EDGE       2,       6,     7,     6,         31    ; Edge 12
 EDGE       3,       6,     8,     7,         31    ; Edge 13
 EDGE       4,       6,     9,     8,         31    ; Edge 14

.SHIP_BOULDER_FACES

    ; normal_x, normal_y, normal_z, visibility
 FACE      -15,       -3,        8,         31    ; Face 0
 FACE       -7,       12,       30,         31    ; Face 1
 FACE       32,      -47,       24,         31    ; Face 2
 FACE       -3,      -39,       -7,         31    ; Face 3
 FACE       -5,       -4,       -1,         31    ; Face 4
 FACE       49,       84,        8,         31    ; Face 5
 FACE      112,       21,      -21,         31    ; Face 6
 FACE       76,      -35,      -82,         31    ; Face 7
 FACE       22,       56,     -137,         31    ; Face 8
 FACE       40,      110,      -38,         31    ; Face 9

; ******************************************************************************
;
;       Name: SHIP_ASTEROID
;       Type: Variable
;   Category: Drawing ships
;    Summary: Ship blueprint for an asteroid
;  Deep dive: Ship blueprints
;
; ******************************************************************************

.SHIP_ASTEROID

 EQUB 0                 ; Max. canisters on demise = 0
 EQUW 80 * 80           ; Targetable area          = 80 * 80

 EQUB LO(SHIP_ASTEROID_EDGES - SHIP_ASTEROID)      ; Edges data offset (low)
 EQUB LO(SHIP_ASTEROID_FACES - SHIP_ASTEROID)      ; Faces data offset (low)

 EQUB 69                ; Max. edge count          = (69 - 1) / 4 = 17
 EQUB 0                 ; Gun vertex               = 0
 EQUB 34                ; Explosion count          = 7, as (4 * n) + 6 = 34
 EQUB 54                ; Number of vertices       = 54 / 6 = 9
 EQUB 21                ; Number of edges          = 21
 EQUW 5                 ; Bounty                   = 5
 EQUB 56                ; Number of faces          = 56 / 4 = 14
 EQUB 50                ; Visibility distance      = 50
 EQUB 60                ; Max. energy              = 60
 EQUB 30                ; Max. speed               = 30

 EQUB HI(SHIP_ASTEROID_EDGES - SHIP_ASTEROID)      ; Edges data offset (high)
 EQUB HI(SHIP_ASTEROID_FACES - SHIP_ASTEROID)      ; Faces data offset (high)

 EQUB 1                 ; Normals are scaled by    = 2^1 = 2
 EQUB %00000000         ; Laser power              = 0
                        ; Missiles                 = 0

.SHIP_ASTEROID_VERTICES

      ;    x,    y,    z, face1, face2, face3, face4, visibility
 VERTEX    0,   80,    0,    15,     15,   15,    15,         31    ; Vertex 0
 VERTEX  -80,  -10,    0,    15,     15,   15,    15,         31    ; Vertex 1
 VERTEX    0,  -80,    0,    15,     15,   15,    15,         31    ; Vertex 2
 VERTEX   70,  -40,    0,    15,     15,   15,    15,         31    ; Vertex 3
 VERTEX   60,   50,    0,     5,      6,   12,    13,         31    ; Vertex 4
 VERTEX   50,    0,   60,    15,     15,   15,    15,         31    ; Vertex 5
 VERTEX  -40,    0,   70,     0,      1,    2,     3,         31    ; Vertex 6
 VERTEX    0,   30,  -75,    15,     15,   15,    15,         31    ; Vertex 7
 VERTEX    0,  -50,  -60,     8,      9,   10,    11,         31    ; Vertex 8

.SHIP_ASTEROID_EDGES

    ; vertex1, vertex2, face1, face2, visibility
 EDGE       0,       1,     2,     7,         31    ; Edge 0
 EDGE       0,       4,     6,    13,         31    ; Edge 1
 EDGE       3,       4,     5,    12,         31    ; Edge 2
 EDGE       2,       3,     4,    11,         31    ; Edge 3
 EDGE       1,       2,     3,    10,         31    ; Edge 4
 EDGE       1,       6,     2,     3,         31    ; Edge 5
 EDGE       2,       6,     1,     3,         31    ; Edge 6
 EDGE       2,       5,     1,     4,         31    ; Edge 7
 EDGE       5,       6,     0,     1,         31    ; Edge 8
 EDGE       0,       5,     0,     6,         31    ; Edge 9
 EDGE       3,       5,     4,     5,         31    ; Edge 10
 EDGE       0,       6,     0,     2,         31    ; Edge 11
 EDGE       4,       5,     5,     6,         31    ; Edge 12
 EDGE       1,       8,     8,    10,         31    ; Edge 13
 EDGE       1,       7,     7,     8,         31    ; Edge 14
 EDGE       0,       7,     7,    13,         31    ; Edge 15
 EDGE       4,       7,    12,    13,         31    ; Edge 16
 EDGE       3,       7,     9,    12,         31    ; Edge 17
 EDGE       3,       8,     9,    11,         31    ; Edge 18
 EDGE       2,       8,    10,    11,         31    ; Edge 19
 EDGE       7,       8,     8,     9,         31    ; Edge 20

.SHIP_ASTEROID_FACES

    ; normal_x, normal_y, normal_z, visibility
 FACE        9,       66,       81,         31    ; Face 0
 FACE        9,      -66,       81,         31    ; Face 1
 FACE      -72,       64,       31,         31    ; Face 2
 FACE      -64,      -73,       47,         31    ; Face 3
 FACE       45,      -79,       65,         31    ; Face 4
 FACE      135,       15,       35,         31    ; Face 5
 FACE       38,       76,       70,         31    ; Face 6
 FACE      -66,       59,      -39,         31    ; Face 7
 FACE      -67,      -15,      -80,         31    ; Face 8
 FACE       66,      -14,      -75,         31    ; Face 9
 FACE      -70,      -80,      -40,         31    ; Face 10
 FACE       58,     -102,      -51,         31    ; Face 11
 FACE       81,        9,      -67,         31    ; Face 12
 FACE       47,       94,      -63,         31    ; Face 13

; ******************************************************************************
;
;       Name: SHIP_SPLINTER
;       Type: Variable
;   Category: Drawing ships
;    Summary: Ship blueprint for a splinter
;  Deep dive: Ship blueprints
;
; ------------------------------------------------------------------------------
;
; The ship blueprint for the splinter reuses the edges data from the escape pod,
; so the edges data offset is negative.
;
; ******************************************************************************

.SHIP_SPLINTER

 EQUB 0 + (11 << 4)     ; Max. canisters on demise = 0
                        ; Market item when scooped = 11 + 1 = 12 (Minerals)
 EQUW 16 * 16           ; Targetable area          = 16 * 16

 EQUB LO(SHIP_ESCAPE_POD_EDGES - SHIP_SPLINTER)    ; Edges from escape pod
 EQUB LO(SHIP_SPLINTER_FACES - SHIP_SPLINTER) + 24 ; Faces data offset (low)

 EQUB 29                ; Max. edge count          = (29 - 1) / 4 = 7
 EQUB 0                 ; Gun vertex               = 0
 EQUB 22                ; Explosion count          = 4, as (4 * n) + 6 = 22
 EQUB 24                ; Number of vertices       = 24 / 6 = 4
 EQUB 6                 ; Number of edges          = 6
 EQUW 0                 ; Bounty                   = 0
 EQUB 16                ; Number of faces          = 16 / 4 = 4
 EQUB 8                 ; Visibility distance      = 8
 EQUB 20                ; Max. energy              = 20
 EQUB 10                ; Max. speed               = 10

 EQUB HI(SHIP_ESCAPE_POD_EDGES - SHIP_SPLINTER)    ; Edges from escape pod
 EQUB HI(SHIP_SPLINTER_FACES - SHIP_SPLINTER)      ; Faces data offset (low)

 EQUB 5                 ; Normals are scaled by    = 2^5 = 32
 EQUB %00000000         ; Laser power              = 0
                        ; Missiles                 = 0

.SHIP_SPLINTER_VERTICES

      ;    x,    y,    z, face1, face2, face3, face4, visibility
 VERTEX  -24,  -25,   16,     2,      1,    3,     3,         31    ; Vertex 0
 VERTEX    0,   12,  -10,     2,      0,    3,     3,         31    ; Vertex 1
 VERTEX   11,   -6,    2,     1,      0,    3,     3,         31    ; Vertex 2
 VERTEX   12,   42,    7,     1,      0,    2,     2,         31    ; Vertex 3

.SHIP_SPLINTER_FACES

    ; normal_x, normal_y, normal_z, visibility
 FACE       35,        0,        4,         31    ; Face 0
 FACE        3,        4,        8,         31    ; Face 1
 FACE        1,        8,       12,         31    ; Face 2
 FACE       18,       12,        0,         31    ; Face 3

; ******************************************************************************
;
;       Name: SHIP_SHUTTLE
;       Type: Variable
;   Category: Drawing ships
;    Summary: Ship blueprint for a Shuttle
;  Deep dive: Ship blueprints
;
; ******************************************************************************

.SHIP_SHUTTLE

 EQUB 15                ; Max. canisters on demise = 15
 EQUW 50 * 50           ; Targetable area          = 50 * 50

 EQUB LO(SHIP_SHUTTLE_EDGES - SHIP_SHUTTLE)        ; Edges data offset (low)
 EQUB LO(SHIP_SHUTTLE_FACES - SHIP_SHUTTLE)        ; Faces data offset (low)

 EQUB 113               ; Max. edge count          = (113 - 1) / 4 = 28
 EQUB 0                 ; Gun vertex               = 0
 EQUB 38                ; Explosion count          = 8, as (4 * n) + 6 = 38
 EQUB 114               ; Number of vertices       = 114 / 6 = 19
 EQUB 30                ; Number of edges          = 30
 EQUW 0                 ; Bounty                   = 0
 EQUB 52                ; Number of faces          = 52 / 4 = 13
 EQUB 22                ; Visibility distance      = 22
 EQUB 32                ; Max. energy              = 32
 EQUB 8                 ; Max. speed               = 8

 EQUB HI(SHIP_SHUTTLE_EDGES - SHIP_SHUTTLE)        ; Edges data offset (high)
 EQUB HI(SHIP_SHUTTLE_FACES - SHIP_SHUTTLE)        ; Faces data offset (high)

 EQUB 2                 ; Normals are scaled by    = 2^2 = 4
 EQUB %00000000         ; Laser power              = 0
                        ; Missiles                 = 0

.SHIP_SHUTTLE_VERTICES

      ;    x,    y,    z, face1, face2, face3, face4, visibility
 VERTEX    0,  -17,   23,    15,     15,   15,    15,         31    ; Vertex 0
 VERTEX  -17,    0,   23,    15,     15,   15,    15,         31    ; Vertex 1
 VERTEX    0,   18,   23,    15,     15,   15,    15,         31    ; Vertex 2
 VERTEX   18,    0,   23,    15,     15,   15,    15,         31    ; Vertex 3
 VERTEX  -20,  -20,  -27,     2,      1,    9,     3,         31    ; Vertex 4
 VERTEX  -20,   20,  -27,     4,      3,    9,     5,         31    ; Vertex 5
 VERTEX   20,   20,  -27,     6,      5,    9,     7,         31    ; Vertex 6
 VERTEX   20,  -20,  -27,     7,      1,    9,     8,         31    ; Vertex 7
 VERTEX    5,    0,  -27,     9,      9,    9,     9,         16    ; Vertex 8
 VERTEX    0,   -2,  -27,     9,      9,    9,     9,         16    ; Vertex 9
 VERTEX   -5,    0,  -27,     9,      9,    9,     9,          9    ; Vertex 10
 VERTEX    0,    3,  -27,     9,      9,    9,     9,          9    ; Vertex 11
 VERTEX    0,   -9,   35,    10,      0,   12,    11,         16    ; Vertex 12
 VERTEX    3,   -1,   31,    15,     15,    2,     0,          7    ; Vertex 13
 VERTEX    4,   11,   25,     1,      0,    4,    15,          8    ; Vertex 14
 VERTEX   11,    4,   25,     1,     10,   15,     3,          8    ; Vertex 15
 VERTEX   -3,   -1,   31,    11,      6,    3,     2,          7    ; Vertex 16
 VERTEX   -3,   11,   25,     8,     15,    0,    12,          8    ; Vertex 17
 VERTEX  -10,    4,   25,    15,      4,    8,     1,          8    ; Vertex 18

.SHIP_SHUTTLE_EDGES

    ; vertex1, vertex2, face1, face2, visibility
 EDGE       0,       1,     2,     0,         31    ; Edge 0
 EDGE       1,       2,    10,     4,         31    ; Edge 1
 EDGE       2,       3,    11,     6,         31    ; Edge 2
 EDGE       0,       3,    12,     8,         31    ; Edge 3
 EDGE       0,       7,     8,     1,         31    ; Edge 4
 EDGE       0,       4,     2,     1,         24    ; Edge 5
 EDGE       1,       4,     3,     2,         31    ; Edge 6
 EDGE       1,       5,     4,     3,         24    ; Edge 7
 EDGE       2,       5,     5,     4,         31    ; Edge 8
 EDGE       2,       6,     6,     5,         12    ; Edge 9
 EDGE       3,       6,     7,     6,         31    ; Edge 10
 EDGE       3,       7,     8,     7,         24    ; Edge 11
 EDGE       4,       5,     9,     3,         31    ; Edge 12
 EDGE       5,       6,     9,     5,         31    ; Edge 13
 EDGE       6,       7,     9,     7,         31    ; Edge 14
 EDGE       4,       7,     9,     1,         31    ; Edge 15
 EDGE       0,      12,    12,     0,         16    ; Edge 16
 EDGE       1,      12,    10,     0,         16    ; Edge 17
 EDGE       2,      12,    11,    10,         16    ; Edge 18
 EDGE       3,      12,    12,    11,         16    ; Edge 19
 EDGE       8,       9,     9,     9,         16    ; Edge 20
 EDGE       9,      10,     9,     9,          7    ; Edge 21
 EDGE      10,      11,     9,     9,          9    ; Edge 22
 EDGE       8,      11,     9,     9,          7    ; Edge 23
 EDGE      13,      14,    11,    11,          5    ; Edge 24
 EDGE      14,      15,    11,    11,          8    ; Edge 25
 EDGE      13,      15,    11,    11,          7    ; Edge 26
 EDGE      16,      17,    10,    10,          5    ; Edge 27
 EDGE      17,      18,    10,    10,          8    ; Edge 28
 EDGE      16,      18,    10,    10,          7    ; Edge 29

.SHIP_SHUTTLE_FACES

    ; normal_x, normal_y, normal_z, visibility
 FACE      -55,      -55,       40,         31    ; Face 0
 FACE        0,      -74,        4,         31    ; Face 1
 FACE      -51,      -51,       23,         31    ; Face 2
 FACE      -74,        0,        4,         31    ; Face 3
 FACE      -51,       51,       23,         31    ; Face 4
 FACE        0,       74,        4,         31    ; Face 5
 FACE       51,       51,       23,         31    ; Face 6
 FACE       74,        0,        4,         31    ; Face 7
 FACE       51,      -51,       23,         31    ; Face 8
 FACE        0,        0,     -107,         31    ; Face 9
 FACE      -41,       41,       90,         31    ; Face 10
 FACE       41,       41,       90,         31    ; Face 11
 FACE       55,      -55,       40,         31    ; Face 12

; ******************************************************************************
;
;       Name: SHIP_TRANSPORTER
;       Type: Variable
;   Category: Drawing ships
;    Summary: Ship blueprint for a Transporter
;  Deep dive: Ship blueprints
;
; ******************************************************************************

.SHIP_TRANSPORTER

 EQUB 0                 ; Max. canisters on demise = 0
 EQUW 50 * 50           ; Targetable area          = 50 * 50

 EQUB LO(SHIP_TRANSPORTER_EDGES - SHIP_TRANSPORTER)   ; Edges data offset (low)
 EQUB LO(SHIP_TRANSPORTER_FACES - SHIP_TRANSPORTER)   ; Faces data offset (low)

 EQUB 149               ; Max. edge count          = (149 - 1) / 4 = 37
 EQUB 48                ; Gun vertex               = 48 / 4 = 12
 EQUB 26                ; Explosion count          = 5, as (4 * n) + 6 = 26
 EQUB 222               ; Number of vertices       = 222 / 6 = 37
 EQUB 46                ; Number of edges          = 46
 EQUW 0                 ; Bounty                   = 0
 EQUB 56                ; Number of faces          = 56 / 4 = 14
 EQUB 16                ; Visibility distance      = 16
 EQUB 32                ; Max. energy              = 32
 EQUB 10                ; Max. speed               = 10

 EQUB HI(SHIP_TRANSPORTER_EDGES - SHIP_TRANSPORTER)   ; Edges data offset (high)
 EQUB HI(SHIP_TRANSPORTER_FACES - SHIP_TRANSPORTER)   ; Faces data offset (high)

 EQUB 2                 ; Normals are scaled by    = 2^2 = 4
 EQUB %00000000         ; Laser power              = 0
                        ; Missiles                 = 0

.SHIP_TRANSPORTER_VERTICES

      ;    x,    y,    z, face1, face2, face3, face4, visibility
 VERTEX    0,   10,  -26,     6,      0,    7,     7,         31    ; Vertex 0
 VERTEX  -25,    4,  -26,     1,      0,    7,     7,         31    ; Vertex 1
 VERTEX  -28,   -3,  -26,     1,      0,    2,     2,         31    ; Vertex 2
 VERTEX  -25,   -8,  -26,     2,      0,    3,     3,         31    ; Vertex 3
 VERTEX   26,   -8,  -26,     3,      0,    4,     4,         31    ; Vertex 4
 VERTEX   29,   -3,  -26,     4,      0,    5,     5,         31    ; Vertex 5
 VERTEX   26,    4,  -26,     5,      0,    6,     6,         31    ; Vertex 6
 VERTEX    0,    6,   12,    15,     15,   15,    15,         19    ; Vertex 7
 VERTEX  -30,   -1,   12,     7,      1,    9,     8,         31    ; Vertex 8
 VERTEX  -33,   -8,   12,     2,      1,    9,     3,         31    ; Vertex 9
 VERTEX   33,   -8,   12,     4,      3,   10,     5,         31    ; Vertex 10
 VERTEX   30,   -1,   12,     6,      5,   11,    10,         31    ; Vertex 11
 VERTEX  -11,   -2,   30,     9,      8,   13,    12,         31    ; Vertex 12
 VERTEX  -13,   -8,   30,     9,      3,   13,    13,         31    ; Vertex 13
 VERTEX   14,   -8,   30,    10,      3,   13,    13,         31    ; Vertex 14
 VERTEX   11,   -2,   30,    11,     10,   13,    12,         31    ; Vertex 15
 VERTEX   -5,    6,    2,     7,      7,    7,     7,          7    ; Vertex 16
 VERTEX  -18,    3,    2,     7,      7,    7,     7,          7    ; Vertex 17
 VERTEX   -5,    7,   -7,     7,      7,    7,     7,          7    ; Vertex 18
 VERTEX  -18,    4,   -7,     7,      7,    7,     7,          7    ; Vertex 19
 VERTEX  -11,    6,  -14,     7,      7,    7,     7,          7    ; Vertex 20
 VERTEX  -11,    5,   -7,     7,      7,    7,     7,          7    ; Vertex 21
 VERTEX    5,    7,  -14,     6,      6,    6,     6,          7    ; Vertex 22
 VERTEX   18,    4,  -14,     6,      6,    6,     6,          7    ; Vertex 23
 VERTEX   11,    5,   -7,     6,      6,    6,     6,          7    ; Vertex 24
 VERTEX    5,    6,   -3,     6,      6,    6,     6,          7    ; Vertex 25
 VERTEX   18,    3,   -3,     6,      6,    6,     6,          7    ; Vertex 26
 VERTEX   11,    4,    8,     6,      6,    6,     6,          7    ; Vertex 27
 VERTEX   11,    5,   -3,     6,      6,    6,     6,          7    ; Vertex 28
 VERTEX  -16,   -8,  -13,     3,      3,    3,     3,          6    ; Vertex 29
 VERTEX  -16,   -8,   16,     3,      3,    3,     3,          6    ; Vertex 30
 VERTEX   17,   -8,  -13,     3,      3,    3,     3,          6    ; Vertex 31
 VERTEX   17,   -8,   16,     3,      3,    3,     3,          6    ; Vertex 32
 VERTEX  -13,   -3,  -26,     0,      0,    0,     0,          8    ; Vertex 33
 VERTEX   13,   -3,  -26,     0,      0,    0,     0,          8    ; Vertex 34
 VERTEX    9,    3,  -26,     0,      0,    0,     0,          5    ; Vertex 35
 VERTEX   -8,    3,  -26,     0,      0,    0,     0,          5    ; Vertex 36

.SHIP_TRANSPORTER_EDGES

    ; vertex1, vertex2, face1, face2, visibility
 EDGE       0,       1,     7,     0,         31    ; Edge 0
 EDGE       1,       2,     1,     0,         31    ; Edge 1
 EDGE       2,       3,     2,     0,         31    ; Edge 2
 EDGE       3,       4,     3,     0,         31    ; Edge 3
 EDGE       4,       5,     4,     0,         31    ; Edge 4
 EDGE       5,       6,     5,     0,         31    ; Edge 5
 EDGE       0,       6,     6,     0,         31    ; Edge 6
 EDGE       0,       7,     7,     6,         16    ; Edge 7
 EDGE       1,       8,     7,     1,         31    ; Edge 8
 EDGE       2,       9,     2,     1,         11    ; Edge 9
 EDGE       3,       9,     3,     2,         31    ; Edge 10
 EDGE       4,      10,     4,     3,         31    ; Edge 11
 EDGE       5,      10,     5,     4,         11    ; Edge 12
 EDGE       6,      11,     6,     5,         31    ; Edge 13
 EDGE       7,       8,     8,     7,         17    ; Edge 14
 EDGE       8,       9,     9,     1,         17    ; Edge 15
 EDGE      10,      11,    10,     5,         17    ; Edge 16
 EDGE       7,      11,    11,     6,         17    ; Edge 17
 EDGE       7,      15,    12,    11,         19    ; Edge 18
 EDGE       7,      12,    12,     8,         19    ; Edge 19
 EDGE       8,      12,     9,     8,         16    ; Edge 20
 EDGE       9,      13,     9,     3,         31    ; Edge 21
 EDGE      10,      14,    10,     3,         31    ; Edge 22
 EDGE      11,      15,    11,    10,         16    ; Edge 23
 EDGE      12,      13,    13,     9,         31    ; Edge 24
 EDGE      13,      14,    13,     3,         31    ; Edge 25
 EDGE      14,      15,    13,    10,         31    ; Edge 26
 EDGE      12,      15,    13,    12,         31    ; Edge 27
 EDGE      16,      17,     7,     7,          7    ; Edge 28
 EDGE      18,      19,     7,     7,          7    ; Edge 29
 EDGE      19,      20,     7,     7,          7    ; Edge 30
 EDGE      18,      20,     7,     7,          7    ; Edge 31
 EDGE      20,      21,     7,     7,          7    ; Edge 32
 EDGE      22,      23,     6,     6,          7    ; Edge 33
 EDGE      23,      24,     6,     6,          7    ; Edge 34
 EDGE      24,      22,     6,     6,          7    ; Edge 35
 EDGE      25,      26,     6,     6,          7    ; Edge 36
 EDGE      26,      27,     6,     6,          7    ; Edge 37
 EDGE      25,      27,     6,     6,          7    ; Edge 38
 EDGE      27,      28,     6,     6,          7    ; Edge 39
 EDGE      29,      30,     3,     3,          6    ; Edge 40
 EDGE      31,      32,     3,     3,          6    ; Edge 41
 EDGE      33,      34,     0,     0,          8    ; Edge 42
 EDGE      34,      35,     0,     0,          5    ; Edge 43
 EDGE      35,      36,     0,     0,          5    ; Edge 44
 EDGE      36,      33,     0,     0,          5    ; Edge 45

.SHIP_TRANSPORTER_FACES

    ; normal_x, normal_y, normal_z, visibility
 FACE        0,        0,     -103,         31    ; Face 0
 FACE     -111,       48,       -7,         31    ; Face 1
 FACE     -105,      -63,      -21,         31    ; Face 2
 FACE        0,      -34,        0,         31    ; Face 3
 FACE      105,      -63,      -21,         31    ; Face 4
 FACE      111,       48,       -7,         31    ; Face 5
 FACE        8,       32,        3,         31    ; Face 6
 FACE       -8,       32,        3,         31    ; Face 7
 FACE       -8,       34,       11,         19    ; Face 8
 FACE      -75,       32,       79,         31    ; Face 9
 FACE       75,       32,       79,         31    ; Face 10
 FACE        8,       34,       11,         19    ; Face 11
 FACE        0,       38,       17,         31    ; Face 12
 FACE        0,        0,      121,         31    ; Face 13

; ******************************************************************************
;
;       Name: SHIP_COBRA_MK_3
;       Type: Variable
;   Category: Drawing ships
;    Summary: Ship blueprint for a Cobra Mk III
;  Deep dive: Ship blueprints
;
; ******************************************************************************

.SHIP_COBRA_MK_3

 EQUB 3                 ; Max. canisters on demise = 3
 EQUW 95 * 95           ; Targetable area          = 95 * 95

 EQUB LO(SHIP_COBRA_MK_3_EDGES - SHIP_COBRA_MK_3)  ; Edges data offset (low)
 EQUB LO(SHIP_COBRA_MK_3_FACES - SHIP_COBRA_MK_3)  ; Faces data offset (low)

 EQUB 157               ; Max. edge count          = (157 - 1) / 4 = 39
 EQUB 84                ; Gun vertex               = 84 / 4 = 21
 EQUB 42                ; Explosion count          = 9, as (4 * n) + 6 = 42
 EQUB 168               ; Number of vertices       = 168 / 6 = 28
 EQUB 38                ; Number of edges          = 38
 EQUW 0                 ; Bounty                   = 0
 EQUB 52                ; Number of faces          = 52 / 4 = 13
 EQUB 50                ; Visibility distance      = 50
 EQUB 150               ; Max. energy              = 150
 EQUB 28                ; Max. speed               = 28

 EQUB HI(SHIP_COBRA_MK_3_EDGES - SHIP_COBRA_MK_3)  ; Edges data offset (low)
 EQUB HI(SHIP_COBRA_MK_3_FACES - SHIP_COBRA_MK_3)  ; Faces data offset (low)

 EQUB 1                 ; Normals are scaled by    = 2^1 = 2
 EQUB %00010011         ; Laser power              = 2
                        ; Missiles                 = 3

.SHIP_COBRA_MK_3_VERTICES

      ;    x,    y,    z, face1, face2, face3, face4, visibility
 VERTEX   32,    0,   76,    15,     15,   15,    15,         31    ; Vertex 0
 VERTEX  -32,    0,   76,    15,     15,   15,    15,         31    ; Vertex 1
 VERTEX    0,   26,   24,    15,     15,   15,    15,         31    ; Vertex 2
 VERTEX -120,   -3,   -8,     3,      7,   10,    10,         31    ; Vertex 3
 VERTEX  120,   -3,   -8,     4,      8,   12,    12,         31    ; Vertex 4
 VERTEX  -88,   16,  -40,    15,     15,   15,    15,         31    ; Vertex 5
 VERTEX   88,   16,  -40,    15,     15,   15,    15,         31    ; Vertex 6
 VERTEX  128,   -8,  -40,     8,      9,   12,    12,         31    ; Vertex 7
 VERTEX -128,   -8,  -40,     7,      9,   10,    10,         31    ; Vertex 8
 VERTEX    0,   26,  -40,     5,      6,    9,     9,         31    ; Vertex 9
 VERTEX  -32,  -24,  -40,     9,     10,   11,    11,         31    ; Vertex 10
 VERTEX   32,  -24,  -40,     9,     11,   12,    12,         31    ; Vertex 11
 VERTEX  -36,    8,  -40,     9,      9,    9,     9,         20    ; Vertex 12
 VERTEX   -8,   12,  -40,     9,      9,    9,     9,         20    ; Vertex 13
 VERTEX    8,   12,  -40,     9,      9,    9,     9,         20    ; Vertex 14
 VERTEX   36,    8,  -40,     9,      9,    9,     9,         20    ; Vertex 15
 VERTEX   36,  -12,  -40,     9,      9,    9,     9,         20    ; Vertex 16
 VERTEX    8,  -16,  -40,     9,      9,    9,     9,         20    ; Vertex 17
 VERTEX   -8,  -16,  -40,     9,      9,    9,     9,         20    ; Vertex 18
 VERTEX  -36,  -12,  -40,     9,      9,    9,     9,         20    ; Vertex 19
 VERTEX    0,    0,   76,     0,     11,   11,    11,          6    ; Vertex 20
 VERTEX    0,    0,   90,     0,     11,   11,    11,         31    ; Vertex 21
 VERTEX  -80,   -6,  -40,     9,      9,    9,     9,          8    ; Vertex 22
 VERTEX  -80,    6,  -40,     9,      9,    9,     9,          8    ; Vertex 23
 VERTEX  -88,    0,  -40,     9,      9,    9,     9,          6    ; Vertex 24
 VERTEX   80,    6,  -40,     9,      9,    9,     9,          8    ; Vertex 25
 VERTEX   88,    0,  -40,     9,      9,    9,     9,          6    ; Vertex 26
 VERTEX   80,   -6,  -40,     9,      9,    9,     9,          8    ; Vertex 27

.SHIP_COBRA_MK_3_EDGES

    ; vertex1, vertex2, face1, face2, visibility
 EDGE       0,       1,     0,    11,         31    ; Edge 0
 EDGE       0,       4,     4,    12,         31    ; Edge 1
 EDGE       1,       3,     3,    10,         31    ; Edge 2
 EDGE       3,       8,     7,    10,         31    ; Edge 3
 EDGE       4,       7,     8,    12,         31    ; Edge 4
 EDGE       6,       7,     8,     9,         31    ; Edge 5
 EDGE       6,       9,     6,     9,         31    ; Edge 6
 EDGE       5,       9,     5,     9,         31    ; Edge 7
 EDGE       5,       8,     7,     9,         31    ; Edge 8
 EDGE       2,       5,     1,     5,         31    ; Edge 9
 EDGE       2,       6,     2,     6,         31    ; Edge 10
 EDGE       3,       5,     3,     7,         31    ; Edge 11
 EDGE       4,       6,     4,     8,         31    ; Edge 12
 EDGE       1,       2,     0,     1,         31    ; Edge 13
 EDGE       0,       2,     0,     2,         31    ; Edge 14
 EDGE       8,      10,     9,    10,         31    ; Edge 15
 EDGE      10,      11,     9,    11,         31    ; Edge 16
 EDGE       7,      11,     9,    12,         31    ; Edge 17
 EDGE       1,      10,    10,    11,         31    ; Edge 18
 EDGE       0,      11,    11,    12,         31    ; Edge 19
 EDGE       1,       5,     1,     3,         29    ; Edge 20
 EDGE       0,       6,     2,     4,         29    ; Edge 21
 EDGE      20,      21,     0,    11,          6    ; Edge 22
 EDGE      12,      13,     9,     9,         20    ; Edge 23
 EDGE      18,      19,     9,     9,         20    ; Edge 24
 EDGE      14,      15,     9,     9,         20    ; Edge 25
 EDGE      16,      17,     9,     9,         20    ; Edge 26
 EDGE      15,      16,     9,     9,         19    ; Edge 27
 EDGE      14,      17,     9,     9,         17    ; Edge 28
 EDGE      13,      18,     9,     9,         19    ; Edge 29
 EDGE      12,      19,     9,     9,         19    ; Edge 30
 EDGE       2,       9,     5,     6,         30    ; Edge 31
 EDGE      22,      24,     9,     9,          6    ; Edge 32
 EDGE      23,      24,     9,     9,          6    ; Edge 33
 EDGE      22,      23,     9,     9,          8    ; Edge 34
 EDGE      25,      26,     9,     9,          6    ; Edge 35
 EDGE      26,      27,     9,     9,          6    ; Edge 36
 EDGE      25,      27,     9,     9,          8    ; Edge 37

.SHIP_COBRA_MK_3_FACES

    ; normal_x, normal_y, normal_z, visibility
 FACE        0,       62,       31,         31    ; Face 0
 FACE      -18,       55,       16,         31    ; Face 1
 FACE       18,       55,       16,         31    ; Face 2
 FACE      -16,       52,       14,         31    ; Face 3
 FACE       16,       52,       14,         31    ; Face 4
 FACE      -14,       47,        0,         31    ; Face 5
 FACE       14,       47,        0,         31    ; Face 6
 FACE      -61,      102,        0,         31    ; Face 7
 FACE       61,      102,        0,         31    ; Face 8
 FACE        0,        0,      -80,         31    ; Face 9
 FACE       -7,      -42,        9,         31    ; Face 10
 FACE        0,      -30,        6,         31    ; Face 11
 FACE        7,      -42,        9,         31    ; Face 12

; ******************************************************************************
;
;       Name: SHIP_PYTHON
;       Type: Variable
;   Category: Drawing ships
;    Summary: Ship blueprint for a Python
;  Deep dive: Ship blueprints
;
; ******************************************************************************

.SHIP_PYTHON

 EQUB 5                 ; Max. canisters on demise = 5
 EQUW 80 * 80           ; Targetable area          = 80 * 80

 EQUB LO(SHIP_PYTHON_EDGES - SHIP_PYTHON)          ; Edges data offset (low)
 EQUB LO(SHIP_PYTHON_FACES - SHIP_PYTHON)          ; Faces data offset (low)

 EQUB 89                ; Max. edge count          = (89 - 1) / 4 = 22
 EQUB 0                 ; Gun vertex               = 0
 EQUB 42                ; Explosion count          = 9, as (4 * n) + 6 = 42
 EQUB 66                ; Number of vertices       = 66 / 6 = 11
 EQUB 26                ; Number of edges          = 26
 EQUW 0                 ; Bounty                   = 0
 EQUB 52                ; Number of faces          = 52 / 4 = 13
 EQUB 40                ; Visibility distance      = 40
 EQUB 250               ; Max. energy              = 250
 EQUB 20                ; Max. speed               = 20

 EQUB HI(SHIP_PYTHON_EDGES - SHIP_PYTHON)          ; Edges data offset (high)
 EQUB HI(SHIP_PYTHON_FACES - SHIP_PYTHON)          ; Faces data offset (high)

 EQUB 0                 ; Normals are scaled by    = 2^0 = 1
 EQUB %00011011         ; Laser power              = 3
                        ; Missiles                 = 3

.SHIP_PYTHON_VERTICES

      ;    x,    y,    z, face1, face2, face3, face4, visibility
 VERTEX    0,    0,  224,     0,      1,    2,     3,         31    ; Vertex 0
 VERTEX    0,   48,   48,     0,      1,    4,     5,         31    ; Vertex 1
 VERTEX   96,    0,  -16,    15,     15,   15,    15,         31    ; Vertex 2
 VERTEX  -96,    0,  -16,    15,     15,   15,    15,         31    ; Vertex 3
 VERTEX    0,   48,  -32,     4,      5,    8,     9,         31    ; Vertex 4
 VERTEX    0,   24, -112,     9,      8,   12,    12,         31    ; Vertex 5
 VERTEX  -48,    0, -112,     8,     11,   12,    12,         31    ; Vertex 6
 VERTEX   48,    0, -112,     9,     10,   12,    12,         31    ; Vertex 7
 VERTEX    0,  -48,   48,     2,      3,    6,     7,         31    ; Vertex 8
 VERTEX    0,  -48,  -32,     6,      7,   10,    11,         31    ; Vertex 9
 VERTEX    0,  -24, -112,    10,     11,   12,    12,         31    ; Vertex 10

.SHIP_PYTHON_EDGES

    ; vertex1, vertex2, face1, face2, visibility
 EDGE       0,       8,     2,     3,         31    ; Edge 0
 EDGE       0,       3,     0,     2,         31    ; Edge 1
 EDGE       0,       2,     1,     3,         31    ; Edge 2
 EDGE       0,       1,     0,     1,         31    ; Edge 3
 EDGE       2,       4,     9,     5,         31    ; Edge 4
 EDGE       1,       2,     1,     5,         31    ; Edge 5
 EDGE       2,       8,     7,     3,         31    ; Edge 6
 EDGE       1,       3,     0,     4,         31    ; Edge 7
 EDGE       3,       8,     2,     6,         31    ; Edge 8
 EDGE       2,       9,     7,    10,         31    ; Edge 9
 EDGE       3,       4,     4,     8,         31    ; Edge 10
 EDGE       3,       9,     6,    11,         31    ; Edge 11
 EDGE       3,       5,     8,     8,          7    ; Edge 12
 EDGE       3,      10,    11,    11,          7    ; Edge 13
 EDGE       2,       5,     9,     9,          7    ; Edge 14
 EDGE       2,      10,    10,    10,          7    ; Edge 15
 EDGE       2,       7,     9,    10,         31    ; Edge 16
 EDGE       3,       6,     8,    11,         31    ; Edge 17
 EDGE       5,       6,     8,    12,         31    ; Edge 18
 EDGE       5,       7,     9,    12,         31    ; Edge 19
 EDGE       7,      10,    12,    10,         31    ; Edge 20
 EDGE       6,      10,    11,    12,         31    ; Edge 21
 EDGE       4,       5,     8,     9,         31    ; Edge 22
 EDGE       9,      10,    10,    11,         31    ; Edge 23
 EDGE       1,       4,     4,     5,         31    ; Edge 24
 EDGE       8,       9,     6,     7,         31    ; Edge 25

.SHIP_PYTHON_FACES

    ; normal_x, normal_y, normal_z, visibility
 FACE      -27,       40,       11,        31    ; Face 0
 FACE       27,       40,       11,        31    ; Face 1
 FACE      -27,      -40,       11,        31    ; Face 2
 FACE       27,      -40,       11,        31    ; Face 3
 FACE      -19,       38,        0,        31    ; Face 4
 FACE       19,       38,        0,        31    ; Face 5
 FACE      -19,      -38,        0,        31    ; Face 6
 FACE       19,      -38,        0,        31    ; Face 7
 FACE      -25,       37,      -11,        31    ; Face 8
 FACE       25,       37,      -11,        31    ; Face 9
 FACE       25,      -37,      -11,        31    ; Face 10
 FACE      -25,      -37,      -11,        31    ; Face 11
 FACE        0,        0,     -112,        31    ; Face 12

; ******************************************************************************
;
;       Name: SHIP_BOA
;       Type: Variable
;   Category: Drawing ships
;    Summary: Ship blueprint for a Boa
;  Deep dive: Ship blueprints
;
; ******************************************************************************

.SHIP_BOA

 EQUB 5                 ; Max. canisters on demise = 5
 EQUW 70 * 70           ; Targetable area          = 70 * 70

 EQUB LO(SHIP_BOA_EDGES - SHIP_BOA)                ; Edges data offset (low)
 EQUB LO(SHIP_BOA_FACES - SHIP_BOA)                ; Faces data offset (low)

 EQUB 93                ; Max. edge count          = (93 - 1) / 4 = 23
 EQUB 0                 ; Gun vertex               = 0
 EQUB 38                ; Explosion count          = 8, as (4 * n) + 6 = 38
 EQUB 78                ; Number of vertices       = 78 / 6 = 13
 EQUB 24                ; Number of edges          = 24
 EQUW 0                 ; Bounty                   = 0
 EQUB 52                ; Number of faces          = 52 / 4 = 13
 EQUB 40                ; Visibility distance      = 40
 EQUB 250               ; Max. energy              = 250
 EQUB 24                ; Max. speed               = 24

 EQUB HI(SHIP_BOA_EDGES - SHIP_BOA)                ; Edges data offset (high)
 EQUB HI(SHIP_BOA_FACES - SHIP_BOA)                ; Faces data offset (high)

 EQUB 0                 ; Normals are scaled by    = 2^0 = 1
 EQUB %00011100         ; Laser power              = 3
                        ; Missiles                 = 4

.SHIP_BOA_VERTICES

      ;    x,    y,    z, face1, face2, face3, face4, visibility
 VERTEX    0,    0,   93,    15,     15,   15,    15,         31    ; Vertex 0
 VERTEX    0,   40,  -87,     2,      0,    3,     3,         24    ; Vertex 1
 VERTEX   38,  -25,  -99,     1,      0,    4,     4,         24    ; Vertex 2
 VERTEX  -38,  -25,  -99,     2,      1,    5,     5,         24    ; Vertex 3
 VERTEX  -38,   40,  -59,     3,      2,    9,     6,         31    ; Vertex 4
 VERTEX   38,   40,  -59,     3,      0,   11,     6,         31    ; Vertex 5
 VERTEX   62,    0,  -67,     4,      0,   11,     8,         31    ; Vertex 6
 VERTEX   24,  -65,  -79,     4,      1,   10,     8,         31    ; Vertex 7
 VERTEX  -24,  -65,  -79,     5,      1,   10,     7,         31    ; Vertex 8
 VERTEX  -62,    0,  -67,     5,      2,    9,     7,         31    ; Vertex 9
 VERTEX    0,    7, -107,     2,      0,   10,    10,         22    ; Vertex 10
 VERTEX   13,   -9, -107,     1,      0,   10,    10,         22    ; Vertex 11
 VERTEX  -13,   -9, -107,     2,      1,   12,    12,         22    ; Vertex 12

.SHIP_BOA_EDGES

    ; vertex1, vertex2, face1, face2, visibility
 EDGE       0,       5,    11,     6,         31    ; Edge 0
 EDGE       0,       7,    10,     8,         31    ; Edge 1
 EDGE       0,       9,     9,     7,         31    ; Edge 2
 EDGE       0,       4,     9,     6,         29    ; Edge 3
 EDGE       0,       6,    11,     8,         29    ; Edge 4
 EDGE       0,       8,    10,     7,         29    ; Edge 5
 EDGE       4,       5,     6,     3,         31    ; Edge 6
 EDGE       5,       6,    11,     0,         31    ; Edge 7
 EDGE       6,       7,     8,     4,         31    ; Edge 8
 EDGE       7,       8,    10,     1,         31    ; Edge 9
 EDGE       8,       9,     7,     5,         31    ; Edge 10
 EDGE       4,       9,     9,     2,         31    ; Edge 11
 EDGE       1,       4,     3,     2,         24    ; Edge 12
 EDGE       1,       5,     3,     0,         24    ; Edge 13
 EDGE       3,       9,     5,     2,         24    ; Edge 14
 EDGE       3,       8,     5,     1,         24    ; Edge 15
 EDGE       2,       6,     4,     0,         24    ; Edge 16
 EDGE       2,       7,     4,     1,         24    ; Edge 17
 EDGE       1,      10,     2,     0,         22    ; Edge 18
 EDGE       2,      11,     1,     0,         22    ; Edge 19
 EDGE       3,      12,     2,     1,         22    ; Edge 20
 EDGE      10,      11,    12,     0,         14    ; Edge 21
 EDGE      11,      12,    12,     1,         14    ; Edge 22
 EDGE      12,      10,    12,     2,         14    ; Edge 23

.SHIP_BOA_FACES

    ; normal_x, normal_y, normal_z, visibility
 FACE       43,       37,      -60,         31    ; Face 0
 FACE        0,      -45,      -89,         31    ; Face 1
 FACE      -43,       37,      -60,         31    ; Face 2
 FACE        0,       40,        0,         31    ; Face 3
 FACE       62,      -32,      -20,         31    ; Face 4
 FACE      -62,      -32,      -20,         31    ; Face 5
 FACE        0,       23,        6,         31    ; Face 6
 FACE      -23,      -15,        9,         31    ; Face 7
 FACE       23,      -15,        9,         31    ; Face 8
 FACE      -26,       13,       10,         31    ; Face 9
 FACE        0,      -31,       12,         31    ; Face 10
 FACE       26,       13,       10,         31    ; Face 11
 FACE        0,        0,     -107,         14    ; Face 12

; ******************************************************************************
;
;       Name: SHIP_ANACONDA
;       Type: Variable
;   Category: Drawing ships
;    Summary: Ship blueprint for an Anaconda
;  Deep dive: Ship blueprints
;
; ******************************************************************************

.SHIP_ANACONDA

 EQUB 7                 ; Max. canisters on demise = 7
 EQUW 100 * 100         ; Targetable area          = 100 * 100

 EQUB LO(SHIP_ANACONDA_EDGES - SHIP_ANACONDA)      ; Edges data offset (low)
 EQUB LO(SHIP_ANACONDA_FACES - SHIP_ANACONDA)      ; Faces data offset (low)

 EQUB 93                ; Max. edge count          = (93 - 1) / 4 = 23
 EQUB 48                ; Gun vertex               = 48 / 4 = 12
 EQUB 46                ; Explosion count          = 10, as (4 * n) + 6 = 46
 EQUB 90                ; Number of vertices       = 90 / 6 = 15
 EQUB 25                ; Number of edges          = 25
 EQUW 0                 ; Bounty                   = 0
 EQUB 48                ; Number of faces          = 48 / 4 = 12
 EQUB 36                ; Visibility distance      = 36
 EQUB 252               ; Max. energy              = 252
 EQUB 14                ; Max. speed               = 14

 EQUB HI(SHIP_ANACONDA_EDGES - SHIP_ANACONDA)      ; Edges data offset (high)
 EQUB HI(SHIP_ANACONDA_FACES - SHIP_ANACONDA)      ; Faces data offset (high)

 EQUB 1                 ; Normals are scaled by    = 2^1 = 2
 EQUB %00111111         ; Laser power              = 7
                        ; Missiles                 = 7

.SHIP_ANACONDA_VERTICES

      ;    x,    y,    z, face1, face2, face3, face4, visibility
 VERTEX    0,    7,  -58,     1,      0,    5,     5,         30    ; Vertex 0
 VERTEX  -43,  -13,  -37,     1,      0,    2,     2,         30    ; Vertex 1
 VERTEX  -26,  -47,   -3,     2,      0,    3,     3,         30    ; Vertex 2
 VERTEX   26,  -47,   -3,     3,      0,    4,     4,         30    ; Vertex 3
 VERTEX   43,  -13,  -37,     4,      0,    5,     5,         30    ; Vertex 4
 VERTEX    0,   48,  -49,     5,      1,    6,     6,         30    ; Vertex 5
 VERTEX  -69,   15,  -15,     2,      1,    7,     7,         30    ; Vertex 6
 VERTEX  -43,  -39,   40,     3,      2,    8,     8,         31    ; Vertex 7
 VERTEX   43,  -39,   40,     4,      3,    9,     9,         31    ; Vertex 8
 VERTEX   69,   15,  -15,     5,      4,   10,    10,         30    ; Vertex 9
 VERTEX  -43,   53,  -23,    15,     15,   15,    15,         31    ; Vertex 10
 VERTEX  -69,   -1,   32,     7,      2,    8,     8,         31    ; Vertex 11
 VERTEX    0,    0,  254,    15,     15,   15,    15,         31    ; Vertex 12
 VERTEX   69,   -1,   32,     9,      4,   10,    10,         31    ; Vertex 13
 VERTEX   43,   53,  -23,    15,     15,   15,    15,         31    ; Vertex 14

.SHIP_ANACONDA_EDGES

    ; vertex1, vertex2, face1, face2, visibility
 EDGE       0,       1,     1,     0,         30    ; Edge 0
 EDGE       1,       2,     2,     0,         30    ; Edge 1
 EDGE       2,       3,     3,     0,         30    ; Edge 2
 EDGE       3,       4,     4,     0,         30    ; Edge 3
 EDGE       0,       4,     5,     0,         30    ; Edge 4
 EDGE       0,       5,     5,     1,         29    ; Edge 5
 EDGE       1,       6,     2,     1,         29    ; Edge 6
 EDGE       2,       7,     3,     2,         29    ; Edge 7
 EDGE       3,       8,     4,     3,         29    ; Edge 8
 EDGE       4,       9,     5,     4,         29    ; Edge 9
 EDGE       5,      10,     6,     1,         30    ; Edge 10
 EDGE       6,      10,     7,     1,         30    ; Edge 11
 EDGE       6,      11,     7,     2,         30    ; Edge 12
 EDGE       7,      11,     8,     2,         30    ; Edge 13
 EDGE       7,      12,     8,     3,         31    ; Edge 14
 EDGE       8,      12,     9,     3,         31    ; Edge 15
 EDGE       8,      13,     9,     4,         30    ; Edge 16
 EDGE       9,      13,    10,     4,         30    ; Edge 17
 EDGE       9,      14,    10,     5,         30    ; Edge 18
 EDGE       5,      14,     6,     5,         30    ; Edge 19
 EDGE      10,      14,    11,     6,         30    ; Edge 20
 EDGE      10,      12,    11,     7,         31    ; Edge 21
 EDGE      11,      12,     8,     7,         31    ; Edge 22
 EDGE      12,      13,    10,     9,         31    ; Edge 23
 EDGE      12,      14,    11,    10,         31    ; Edge 24

.SHIP_ANACONDA_FACES

    ; normal_x, normal_y, normal_z, visibility
 FACE        0,      -51,      -49,         30    ; Face 0
 FACE      -51,       18,      -87,         30    ; Face 1
 FACE      -77,      -57,      -19,         30    ; Face 2
 FACE        0,      -90,       16,         31    ; Face 3
 FACE       77,      -57,      -19,         30    ; Face 4
 FACE       51,       18,      -87,         30    ; Face 5
 FACE        0,      111,      -20,         30    ; Face 6
 FACE      -97,       72,       24,         31    ; Face 7
 FACE     -108,      -68,       34,         31    ; Face 8
 FACE      108,      -68,       34,         31    ; Face 9
 FACE       97,       72,       24,         31    ; Face 10
 FACE        0,       94,       18,         31    ; Face 11

; ******************************************************************************
;
;       Name: SHIP_ROCK_HERMIT
;       Type: Variable
;   Category: Drawing ships
;    Summary: Ship blueprint for a rock hermit (asteroid)
;  Deep dive: Ship blueprints
;
; ------------------------------------------------------------------------------
;
; The ship blueprint for the rock hermit reuses the edges and faces data from
; the asteroid, so the edges and faces data offsets are negative.
;
; ******************************************************************************

.SHIP_ROCK_HERMIT

 EQUB 7                 ; Max. canisters on demise = 7
 EQUW 80 * 80           ; Targetable area          = 80 * 80

 EQUB LO(SHIP_ROCK_HERMIT_EDGES - SHIP_ROCK_HERMIT)   ; Edges data offset (low)
 EQUB LO(SHIP_ROCK_HERMIT_FACES - SHIP_ROCK_HERMIT)   ; Faces data offset (low)

 EQUB 69                ; Max. edge count          = (69 - 1) / 4 = 17
 EQUB 0                 ; Gun vertex               = 0
 EQUB 50                ; Explosion count          = 11, as (4 * n) + 6 = 50
 EQUB 54                ; Number of vertices       = 54 / 6 = 9
 EQUB 21                ; Number of edges          = 21
 EQUW 0                 ; Bounty                   = 0
 EQUB 56                ; Number of faces          = 56 / 4 = 14
 EQUB 50                ; Visibility distance      = 50
 EQUB 180               ; Max. energy              = 180
 EQUB 30                ; Max. speed               = 30

 EQUB HI(SHIP_ROCK_HERMIT_EDGES - SHIP_ROCK_HERMIT)   ; Edges data offset (high)
 EQUB HI(SHIP_ROCK_HERMIT_FACES - SHIP_ROCK_HERMIT)   ; Faces data offset (high)

 EQUB 1                 ; Normals are scaled by    = 2^1 = 2
 EQUB %00000010         ; Laser power              = 0
                        ; Missiles                 = 2

.SHIP_ROCK_HERMIT_VERTICES

      ;    x,    y,    z, face1, face2, face3, face4, visibility
 VERTEX    0,   80,    0,    15,     15,   15,    15,         31    ; Vertex 0
 VERTEX  -80,  -10,    0,    15,     15,   15,    15,         31    ; Vertex 1
 VERTEX    0,  -80,    0,    15,     15,   15,    15,         31    ; Vertex 2
 VERTEX   70,  -40,    0,    15,     15,   15,    15,         31    ; Vertex 3
 VERTEX   60,   50,    0,     5,      6,   12,    13,         31    ; Vertex 4
 VERTEX   50,    0,   60,    15,     15,   15,    15,         31    ; Vertex 5
 VERTEX  -40,    0,   70,     0,      1,    2,     3,         31    ; Vertex 6
 VERTEX    0,   30,  -75,    15,     15,   15,    15,         31    ; Vertex 7
 VERTEX    0,  -50,  -60,     8,      9,   10,    11,         31    ; Vertex 8

.SHIP_ROCK_HERMIT_EDGES

    ; vertex1, vertex2, face1, face2, visibility
 EDGE       0,       1,     2,     7,         31    ; Edge 0
 EDGE       0,       4,     6,    13,         31    ; Edge 1
 EDGE       3,       4,     5,    12,         31    ; Edge 2
 EDGE       2,       3,     4,    11,         31    ; Edge 3
 EDGE       1,       2,     3,    10,         31    ; Edge 4
 EDGE       1,       6,     2,     3,         31    ; Edge 5
 EDGE       2,       6,     1,     3,         31    ; Edge 6
 EDGE       2,       5,     1,     4,         31    ; Edge 7
 EDGE       5,       6,     0,     1,         31    ; Edge 8
 EDGE       0,       5,     0,     6,         31    ; Edge 9
 EDGE       3,       5,     4,     5,         31    ; Edge 10
 EDGE       0,       6,     0,     2,         31    ; Edge 11
 EDGE       4,       5,     5,     6,         31    ; Edge 12
 EDGE       1,       8,     8,    10,         31    ; Edge 13
 EDGE       1,       7,     7,     8,         31    ; Edge 14
 EDGE       0,       7,     7,    13,         31    ; Edge 15
 EDGE       4,       7,    12,    13,         31    ; Edge 16
 EDGE       3,       7,     9,    12,         31    ; Edge 17
 EDGE       3,       8,     9,    11,         31    ; Edge 18
 EDGE       2,       8,    10,    11,         31    ; Edge 19
 EDGE       7,       8,     8,     9,         31    ; Edge 20

.SHIP_ROCK_HERMIT_FACES

    ; normal_x, normal_y, normal_z, visibility
 FACE        9,       66,       81,         31    ; Face 0
 FACE        9,      -66,       81,         31    ; Face 1
 FACE      -72,       64,       31,         31    ; Face 2
 FACE      -64,      -73,       47,         31    ; Face 3
 FACE       45,      -79,       65,         31    ; Face 4
 FACE      135,       15,       35,         31    ; Face 5
 FACE       38,       76,       70,         31    ; Face 6
 FACE      -66,       59,      -39,         31    ; Face 7
 FACE      -67,      -15,      -80,         31    ; Face 8
 FACE       66,      -14,      -75,         31    ; Face 9
 FACE      -70,      -80,      -40,         31    ; Face 10
 FACE       58,     -102,      -51,         31    ; Face 11
 FACE       81,        9,      -67,         31    ; Face 12
 FACE       47,       94,      -63,         31    ; Face 13

; ******************************************************************************
;
;       Name: SHIP_VIPER
;       Type: Variable
;   Category: Drawing ships
;    Summary: Ship blueprint for a Viper
;  Deep dive: Ship blueprints
;
; ******************************************************************************

.SHIP_VIPER

 EQUB 0                 ; Max. canisters on demise = 0
 EQUW 75 * 75           ; Targetable area          = 75 * 75

 EQUB LO(SHIP_VIPER_EDGES - SHIP_VIPER)            ; Edges data offset (low)
 EQUB LO(SHIP_VIPER_FACES - SHIP_VIPER)            ; Faces data offset (low)

 EQUB 81                ; Max. edge count          = (81 - 1) / 4 = 20
 EQUB 0                 ; Gun vertex               = 0
 EQUB 42                ; Explosion count          = 9, as (4 * n) + 6 = 42
 EQUB 90                ; Number of vertices       = 90 / 6 = 15
 EQUB 20                ; Number of edges          = 20
 EQUW 0                 ; Bounty                   = 0
 EQUB 28                ; Number of faces          = 28 / 4 = 7
 EQUB 23                ; Visibility distance      = 23
 EQUB 140               ; Max. energy              = 140
 EQUB 32                ; Max. speed               = 32

 EQUB HI(SHIP_VIPER_EDGES - SHIP_VIPER)            ; Edges data offset (high)
 EQUB HI(SHIP_VIPER_FACES - SHIP_VIPER)            ; Faces data offset (high)

 EQUB 1                 ; Normals are scaled by    = 2^1 = 2
 EQUB %00010001         ; Laser power              = 2
                        ; Missiles                 = 1

.SHIP_VIPER_VERTICES

      ;    x,    y,    z, face1, face2, face3, face4, visibility
 VERTEX    0,    0,   72,     1,      2,    3,     4,         31    ; Vertex 0
 VERTEX    0,   16,   24,     0,      1,    2,     2,         30    ; Vertex 1
 VERTEX    0,  -16,   24,     3,      4,    5,     5,         30    ; Vertex 2
 VERTEX   48,    0,  -24,     2,      4,    6,     6,         31    ; Vertex 3
 VERTEX  -48,    0,  -24,     1,      3,    6,     6,         31    ; Vertex 4
 VERTEX   24,  -16,  -24,     4,      5,    6,     6,         30    ; Vertex 5
 VERTEX  -24,  -16,  -24,     5,      3,    6,     6,         30    ; Vertex 6
 VERTEX   24,   16,  -24,     0,      2,    6,     6,         31    ; Vertex 7
 VERTEX  -24,   16,  -24,     0,      1,    6,     6,         31    ; Vertex 8
 VERTEX  -32,    0,  -24,     6,      6,    6,     6,         19    ; Vertex 9
 VERTEX   32,    0,  -24,     6,      6,    6,     6,         19    ; Vertex 10
 VERTEX    8,    8,  -24,     6,      6,    6,     6,         19    ; Vertex 11
 VERTEX   -8,    8,  -24,     6,      6,    6,     6,         19    ; Vertex 12
 VERTEX   -8,   -8,  -24,     6,      6,    6,     6,         18    ; Vertex 13
 VERTEX    8,   -8,  -24,     6,      6,    6,     6,         18    ; Vertex 14

.SHIP_VIPER_EDGES

    ; vertex1, vertex2, face1, face2, visibility
 EDGE       0,       3,     2,     4,         31    ; Edge 0
 EDGE       0,       1,     1,     2,         30    ; Edge 1
 EDGE       0,       2,     3,     4,         30    ; Edge 2
 EDGE       0,       4,     1,     3,         31    ; Edge 3
 EDGE       1,       7,     0,     2,         30    ; Edge 4
 EDGE       1,       8,     0,     1,         30    ; Edge 5
 EDGE       2,       5,     4,     5,         30    ; Edge 6
 EDGE       2,       6,     3,     5,         30    ; Edge 7
 EDGE       7,       8,     0,     6,         31    ; Edge 8
 EDGE       5,       6,     5,     6,         30    ; Edge 9
 EDGE       4,       8,     1,     6,         31    ; Edge 10
 EDGE       4,       6,     3,     6,         30    ; Edge 11
 EDGE       3,       7,     2,     6,         31    ; Edge 12
 EDGE       3,       5,     6,     4,         30    ; Edge 13
 EDGE       9,      12,     6,     6,         19    ; Edge 14
 EDGE       9,      13,     6,     6,         18    ; Edge 15
 EDGE      10,      11,     6,     6,         19    ; Edge 16
 EDGE      10,      14,     6,     6,         18    ; Edge 17
 EDGE      11,      14,     6,     6,         16    ; Edge 18
 EDGE      12,      13,     6,     6,         16    ; Edge 19

.SHIP_VIPER_FACES

    ; normal_x, normal_y, normal_z, visibility
 FACE        0,       32,        0,         31    ; Face 0
 FACE      -22,       33,       11,         31    ; Face 1
 FACE       22,       33,       11,         31    ; Face 2
 FACE      -22,      -33,       11,         31    ; Face 3
 FACE       22,      -33,       11,         31    ; Face 4
 FACE        0,      -32,        0,         31    ; Face 5
 FACE        0,        0,      -48,         31    ; Face 6

; ******************************************************************************
;
;       Name: SHIP_SIDEWINDER
;       Type: Variable
;   Category: Drawing ships
;    Summary: Ship blueprint for a Sidewinder
;  Deep dive: Ship blueprints
;
; ******************************************************************************

.SHIP_SIDEWINDER

 EQUB 0                 ; Max. canisters on demise = 0
 EQUW 65 * 65           ; Targetable area          = 65 * 65

 EQUB LO(SHIP_SIDEWINDER_EDGES - SHIP_SIDEWINDER)  ; Edges data offset (low)
 EQUB LO(SHIP_SIDEWINDER_FACES - SHIP_SIDEWINDER)  ; Faces data offset (low)

 EQUB 65                ; Max. edge count          = (65 - 1) / 4 = 16
 EQUB 0                 ; Gun vertex               = 0
 EQUB 30                ; Explosion count          = 6, as (4 * n) + 6 = 30
 EQUB 60                ; Number of vertices       = 60 / 6 = 10
 EQUB 15                ; Number of edges          = 15
 EQUW 50                ; Bounty                   = 50
 EQUB 28                ; Number of faces          = 28 / 4 = 7
 EQUB 20                ; Visibility distance      = 20
 EQUB 70                ; Max. energy              = 70
 EQUB 37                ; Max. speed               = 37

 EQUB HI(SHIP_SIDEWINDER_EDGES - SHIP_SIDEWINDER)  ; Edges data offset (high)
 EQUB HI(SHIP_SIDEWINDER_FACES - SHIP_SIDEWINDER)  ; Faces data offset (high)

 EQUB 2                 ; Normals are scaled by    = 2^2 = 4
 EQUB %00010000         ; Laser power              = 2
                        ; Missiles                 = 0

.SHIP_SIDEWINDER_VERTICES

      ;    x,    y,    z, face1, face2, face3, face4, visibility
 VERTEX  -32,    0,   36,     0,      1,    4,     5,         31    ; Vertex 0
 VERTEX   32,    0,   36,     0,      2,    5,     6,         31    ; Vertex 1
 VERTEX   64,    0,  -28,     2,      3,    6,     6,         31    ; Vertex 2
 VERTEX  -64,    0,  -28,     1,      3,    4,     4,         31    ; Vertex 3
 VERTEX    0,   16,  -28,     0,      1,    2,     3,         31    ; Vertex 4
 VERTEX    0,  -16,  -28,     3,      4,    5,     6,         31    ; Vertex 5
 VERTEX  -12,    6,  -28,     3,      3,    3,     3,         15    ; Vertex 6
 VERTEX   12,    6,  -28,     3,      3,    3,     3,         15    ; Vertex 7
 VERTEX   12,   -6,  -28,     3,      3,    3,     3,         12    ; Vertex 8
 VERTEX  -12,   -6,  -28,     3,      3,    3,     3,         12    ; Vertex 9

.SHIP_SIDEWINDER_EDGES

    ; vertex1, vertex2, face1, face2, visibility
 EDGE       0,       1,     0,     5,         31    ; Edge 0
 EDGE       1,       2,     2,     6,         31    ; Edge 1
 EDGE       1,       4,     0,     2,         31    ; Edge 2
 EDGE       0,       4,     0,     1,         31    ; Edge 3
 EDGE       0,       3,     1,     4,         31    ; Edge 4
 EDGE       3,       4,     1,     3,         31    ; Edge 5
 EDGE       2,       4,     2,     3,         31    ; Edge 6
 EDGE       3,       5,     3,     4,         31    ; Edge 7
 EDGE       2,       5,     3,     6,         31    ; Edge 8
 EDGE       1,       5,     5,     6,         31    ; Edge 9
 EDGE       0,       5,     4,     5,         31    ; Edge 10
 EDGE       6,       7,     3,     3,         15    ; Edge 11
 EDGE       7,       8,     3,     3,         12    ; Edge 12
 EDGE       6,       9,     3,     3,         12    ; Edge 13
 EDGE       8,       9,     3,     3,         12    ; Edge 14

.SHIP_SIDEWINDER_FACES

    ; normal_x, normal_y, normal_z, visibility
 FACE        0,       32,        8,         31    ; Face 0
 FACE      -12,       47,        6,         31    ; Face 1
 FACE       12,       47,        6,         31    ; Face 2
 FACE        0,        0,     -112,         31    ; Face 3
 FACE      -12,      -47,        6,         31    ; Face 4
 FACE        0,      -32,        8,         31    ; Face 5
 FACE       12,      -47,        6,         31    ; Face 6

; ******************************************************************************
;
;       Name: SHIP_MAMBA
;       Type: Variable
;   Category: Drawing ships
;    Summary: Ship blueprint for a Mamba
;  Deep dive: Ship blueprints
;
; ******************************************************************************

.SHIP_MAMBA

 EQUB 1                 ; Max. canisters on demise = 1
 EQUW 70 * 70           ; Targetable area          = 70 * 70

 EQUB LO(SHIP_MAMBA_EDGES - SHIP_MAMBA)            ; Edges data offset (low)
 EQUB LO(SHIP_MAMBA_FACES - SHIP_MAMBA)            ; Faces data offset (low)

 EQUB 97                ; Max. edge count          = (97 - 1) / 4 = 24
 EQUB 0                 ; Gun vertex               = 0
 EQUB 34                ; Explosion count          = 7, as (4 * n) + 6 = 34
 EQUB 150               ; Number of vertices       = 150 / 6 = 25
 EQUB 28                ; Number of edges          = 28
 EQUW 150               ; Bounty                   = 150
 EQUB 20                ; Number of faces          = 20 / 4 = 5
 EQUB 25                ; Visibility distance      = 25
 EQUB 90                ; Max. energy              = 90
 EQUB 30                ; Max. speed               = 30

 EQUB HI(SHIP_MAMBA_EDGES - SHIP_MAMBA)            ; Edges data offset (high)
 EQUB HI(SHIP_MAMBA_FACES - SHIP_MAMBA)            ; Faces data offset (high)

 EQUB 2                 ; Normals are scaled by    = 2^2 = 4
 EQUB %00010010         ; Laser power              = 2
                        ; Missiles                 = 2

.SHIP_MAMBA_VERTICES

      ;    x,    y,    z, face1, face2, face3, face4, visibility
 VERTEX    0,    0,   64,     0,      1,    2,     3,         31    ; Vertex 0
 VERTEX  -64,   -8,  -32,     0,      2,    4,     4,         31    ; Vertex 1
 VERTEX  -32,    8,  -32,     1,      2,    4,     4,         30    ; Vertex 2
 VERTEX   32,    8,  -32,     1,      3,    4,     4,         30    ; Vertex 3
 VERTEX   64,   -8,  -32,     0,      3,    4,     4,         31    ; Vertex 4
 VERTEX   -4,    4,   16,     1,      1,    1,     1,         14    ; Vertex 5
 VERTEX    4,    4,   16,     1,      1,    1,     1,         14    ; Vertex 6
 VERTEX    8,    3,   28,     1,      1,    1,     1,         13    ; Vertex 7
 VERTEX   -8,    3,   28,     1,      1,    1,     1,         13    ; Vertex 8
 VERTEX  -20,   -4,   16,     0,      0,    0,     0,         20    ; Vertex 9
 VERTEX   20,   -4,   16,     0,      0,    0,     0,         20    ; Vertex 10
 VERTEX  -24,   -7,  -20,     0,      0,    0,     0,         20    ; Vertex 11
 VERTEX  -16,   -7,  -20,     0,      0,    0,     0,         16    ; Vertex 12
 VERTEX   16,   -7,  -20,     0,      0,    0,     0,         16    ; Vertex 13
 VERTEX   24,   -7,  -20,     0,      0,    0,     0,         20    ; Vertex 14
 VERTEX   -8,    4,  -32,     4,      4,    4,     4,         13    ; Vertex 15
 VERTEX    8,    4,  -32,     4,      4,    4,     4,         13    ; Vertex 16
 VERTEX    8,   -4,  -32,     4,      4,    4,     4,         14    ; Vertex 17
 VERTEX   -8,   -4,  -32,     4,      4,    4,     4,         14    ; Vertex 18
 VERTEX  -32,    4,  -32,     4,      4,    4,     4,          7    ; Vertex 19
 VERTEX   32,    4,  -32,     4,      4,    4,     4,          7    ; Vertex 20
 VERTEX   36,   -4,  -32,     4,      4,    4,     4,          7    ; Vertex 21
 VERTEX  -36,   -4,  -32,     4,      4,    4,     4,          7    ; Vertex 22
 VERTEX  -38,    0,  -32,     4,      4,    4,     4,          5    ; Vertex 23
 VERTEX   38,    0,  -32,     4,      4,    4,     4,          5    ; Vertex 24

.SHIP_MAMBA_EDGES

    ; vertex1, vertex2, face1, face2, visibility
 EDGE       0,       1,     0,     2,         31    ; Edge 0
 EDGE       0,       4,     0,     3,         31    ; Edge 1
 EDGE       1,       4,     0,     4,         31    ; Edge 2
 EDGE       1,       2,     2,     4,         30    ; Edge 3
 EDGE       2,       3,     1,     4,         30    ; Edge 4
 EDGE       3,       4,     3,     4,         30    ; Edge 5
 EDGE       5,       6,     1,     1,         14    ; Edge 6
 EDGE       6,       7,     1,     1,         12    ; Edge 7
 EDGE       7,       8,     1,     1,         13    ; Edge 8
 EDGE       5,       8,     1,     1,         12    ; Edge 9
 EDGE       9,      11,     0,     0,         20    ; Edge 10
 EDGE       9,      12,     0,     0,         16    ; Edge 11
 EDGE      10,      13,     0,     0,         16    ; Edge 12
 EDGE      10,      14,     0,     0,         20    ; Edge 13
 EDGE      13,      14,     0,     0,         14    ; Edge 14
 EDGE      11,      12,     0,     0,         14    ; Edge 15
 EDGE      15,      16,     4,     4,         13    ; Edge 16
 EDGE      17,      18,     4,     4,         14    ; Edge 17
 EDGE      15,      18,     4,     4,         12    ; Edge 18
 EDGE      16,      17,     4,     4,         12    ; Edge 19
 EDGE      20,      21,     4,     4,          7    ; Edge 20
 EDGE      20,      24,     4,     4,          5    ; Edge 21
 EDGE      21,      24,     4,     4,          5    ; Edge 22
 EDGE      19,      22,     4,     4,          7    ; Edge 23
 EDGE      19,      23,     4,     4,          5    ; Edge 24
 EDGE      22,      23,     4,     4,          5    ; Edge 25
 EDGE       0,       2,     1,     2,         30    ; Edge 26
 EDGE       0,       3,     1,     3,         30    ; Edge 27

.SHIP_MAMBA_FACES

    ; normal_x, normal_y, normal_z, visibility
 FACE        0,      -24,        2,         30    ; Face 0
 FACE        0,       24,        2,         30    ; Face 1
 FACE      -32,       64,       16,         30    ; Face 2
 FACE       32,       64,       16,         30    ; Face 3
 FACE        0,        0,     -127,         30    ; Face 4

; ******************************************************************************
;
;       Name: SHIP_KRAIT
;       Type: Variable
;   Category: Drawing ships
;    Summary: Ship blueprint for a Krait
;  Deep dive: Ship blueprints
;
; ******************************************************************************

.SHIP_KRAIT

 EQUB 1                 ; Max. canisters on demise = 1
 EQUW 60 * 60           ; Targetable area          = 60 * 60

 EQUB LO(SHIP_KRAIT_EDGES - SHIP_KRAIT)            ; Edges data offset (low)
 EQUB LO(SHIP_KRAIT_FACES - SHIP_KRAIT)            ; Faces data offset (low)

 EQUB 89                ; Max. edge count          = (89 - 1) / 4 = 22
 EQUB 0                 ; Gun vertex               = 0
 EQUB 18                ; Explosion count          = 3, as (4 * n) + 6 = 18
 EQUB 102               ; Number of vertices       = 102 / 6 = 17
 EQUB 21                ; Number of edges          = 21
 EQUW 100               ; Bounty                   = 100
 EQUB 24                ; Number of faces          = 24 / 4 = 6
 EQUB 20                ; Visibility distance      = 20
 EQUB 80                ; Max. energy              = 80
 EQUB 30                ; Max. speed               = 30

 EQUB HI(SHIP_KRAIT_EDGES - SHIP_KRAIT)            ; Edges data offset (high)
 EQUB HI(SHIP_KRAIT_FACES - SHIP_KRAIT)            ; Faces data offset (high)

 EQUB 1                 ; Normals are scaled by    = 2^1 = 2
 EQUB %00010000         ; Laser power              = 2
                        ; Missiles                 = 0

.SHIP_KRAIT_VERTICES

      ;    x,    y,    z, face1, face2, face3, face4, visibility
 VERTEX    0,    0,   96,     1,      0,    3,     2,         31    ; Vertex 0
 VERTEX    0,   18,  -48,     3,      0,    5,     4,         31    ; Vertex 1
 VERTEX    0,  -18,  -48,     2,      1,    5,     4,         31    ; Vertex 2
 VERTEX   90,    0,   -3,     1,      0,    4,     4,         31    ; Vertex 3
 VERTEX  -90,    0,   -3,     3,      2,    5,     5,         31    ; Vertex 4
 VERTEX   90,    0,   87,     1,      0,    1,     1,         30    ; Vertex 5
 VERTEX  -90,    0,   87,     3,      2,    3,     3,         30    ; Vertex 6
 VERTEX    0,    5,   53,     0,      0,    3,     3,          9    ; Vertex 7
 VERTEX    0,    7,   38,     0,      0,    3,     3,          6    ; Vertex 8
 VERTEX  -18,    7,   19,     3,      3,    3,     3,          9    ; Vertex 9
 VERTEX   18,    7,   19,     0,      0,    0,     0,          9    ; Vertex 10
 VERTEX   18,   11,  -39,     4,      4,    4,     4,          8    ; Vertex 11
 VERTEX   18,  -11,  -39,     4,      4,    4,     4,          8    ; Vertex 12
 VERTEX   36,    0,  -30,     4,      4,    4,     4,          8    ; Vertex 13
 VERTEX  -18,   11,  -39,     5,      5,    5,     5,          8    ; Vertex 14
 VERTEX  -18,  -11,  -39,     5,      5,    5,     5,          8    ; Vertex 15
 VERTEX  -36,    0,  -30,     5,      5,    5,     5,          8    ; Vertex 16

.SHIP_KRAIT_EDGES

    ; vertex1, vertex2, face1, face2, visibility
 EDGE       0,       1,     3,     0,         31    ; Edge 0
 EDGE       0,       2,     2,     1,         31    ; Edge 1
 EDGE       0,       3,     1,     0,         31    ; Edge 2
 EDGE       0,       4,     3,     2,         31    ; Edge 3
 EDGE       1,       4,     5,     3,         31    ; Edge 4
 EDGE       4,       2,     5,     2,         31    ; Edge 5
 EDGE       2,       3,     4,     1,         31    ; Edge 6
 EDGE       3,       1,     4,     0,         31    ; Edge 7
 EDGE       3,       5,     1,     0,         30    ; Edge 8
 EDGE       4,       6,     3,     2,         30    ; Edge 9
 EDGE       1,       2,     5,     4,          8    ; Edge 10
 EDGE       7,      10,     0,     0,          9    ; Edge 11
 EDGE       8,      10,     0,     0,          6    ; Edge 12
 EDGE       7,       9,     3,     3,          9    ; Edge 13
 EDGE       8,       9,     3,     3,          6    ; Edge 14
 EDGE      11,      13,     4,     4,          8    ; Edge 15
 EDGE      13,      12,     4,     4,          8    ; Edge 16
 EDGE      12,      11,     4,     4,          7    ; Edge 17
 EDGE      14,      15,     5,     5,          7    ; Edge 18
 EDGE      15,      16,     5,     5,          8    ; Edge 19
 EDGE      16,      14,     5,     5,          8    ; Edge 20

.SHIP_KRAIT_FACES

    ; normal_x, normal_y, normal_z, visibility
 FACE        3,       24,        3,         31    ; Face 0
 FACE        3,      -24,        3,         31    ; Face 1
 FACE       -3,      -24,        3,         31    ; Face 2
 FACE       -3,       24,        3,         31    ; Face 3
 FACE       38,        0,      -77,         31    ; Face 4
 FACE      -38,        0,      -77,         31    ; Face 5

; ******************************************************************************
;
;       Name: SHIP_ADDER
;       Type: Variable
;   Category: Drawing ships
;    Summary: Ship blueprint for an Adder
;  Deep dive: Ship blueprints
;
; ******************************************************************************

.SHIP_ADDER

 EQUB 0                 ; Max. canisters on demise = 0
 EQUW 50 * 50           ; Targetable area          = 50 * 50

 EQUB LO(SHIP_ADDER_EDGES - SHIP_ADDER)            ; Edges data offset (low)
 EQUB LO(SHIP_ADDER_FACES - SHIP_ADDER)            ; Faces data offset (low)

 EQUB 101               ; Max. edge count          = (101 - 1) / 4 = 25
 EQUB 0                 ; Gun vertex               = 0
 EQUB 22                ; Explosion count          = 4, as (4 * n) + 6 = 22
 EQUB 108               ; Number of vertices       = 108 / 6 = 18
 EQUB 29                ; Number of edges          = 29
 EQUW 40                ; Bounty                   = 40
 EQUB 60                ; Number of faces          = 60 / 4 = 15
 EQUB 20                ; Visibility distance      = 20
 EQUB 85                ; Max. energy              = 85
 EQUB 24                ; Max. speed               = 24

 EQUB HI(SHIP_ADDER_EDGES - SHIP_ADDER)            ; Edges data offset (high)
 EQUB HI(SHIP_ADDER_FACES - SHIP_ADDER)            ; Faces data offset (high)

 EQUB 2                 ; Normals are scaled by    = 2^2 = 4
 EQUB %00010000         ; Laser power              = 2
                        ; Missiles                 = 0

.SHIP_ADDER_VERTICES

      ;    x,    y,    z, face1, face2, face3, face4, visibility
 VERTEX  -18,    0,   40,     1,      0,   12,    11,         31    ; Vertex 0
 VERTEX   18,    0,   40,     1,      0,    3,     2,         31    ; Vertex 1
 VERTEX   30,    0,  -24,     3,      2,    5,     4,         31    ; Vertex 2
 VERTEX   30,    0,  -40,     5,      4,    6,     6,         31    ; Vertex 3
 VERTEX   18,   -7,  -40,     6,      5,   14,     7,         31    ; Vertex 4
 VERTEX  -18,   -7,  -40,     8,      7,   14,    10,         31    ; Vertex 5
 VERTEX  -30,    0,  -40,     9,      8,   10,    10,         31    ; Vertex 6
 VERTEX  -30,    0,  -24,    10,      9,   12,    11,         31    ; Vertex 7
 VERTEX  -18,    7,  -40,     8,      7,   13,     9,         31    ; Vertex 8
 VERTEX   18,    7,  -40,     6,      4,   13,     7,         31    ; Vertex 9
 VERTEX  -18,    7,   13,     9,      0,   13,    11,         31    ; Vertex 10
 VERTEX   18,    7,   13,     2,      0,   13,     4,         31    ; Vertex 11
 VERTEX  -18,   -7,   13,    10,      1,   14,    12,         31    ; Vertex 12
 VERTEX   18,   -7,   13,     3,      1,   14,     5,         31    ; Vertex 13
 VERTEX  -11,    3,   29,     0,      0,    0,     0,          5    ; Vertex 14
 VERTEX   11,    3,   29,     0,      0,    0,     0,          5    ; Vertex 15
 VERTEX   11,    4,   24,     0,      0,    0,     0,          4    ; Vertex 16
 VERTEX  -11,    4,   24,     0,      0,    0,     0,          4    ; Vertex 17

.SHIP_ADDER_EDGES

    ; vertex1, vertex2, face1, face2, visibility
 EDGE       0,       1,     1,     0,         31    ; Edge 0
 EDGE       1,       2,     3,     2,          7    ; Edge 1
 EDGE       2,       3,     5,     4,         31    ; Edge 2
 EDGE       3,       4,     6,     5,         31    ; Edge 3
 EDGE       4,       5,    14,     7,         31    ; Edge 4
 EDGE       5,       6,    10,     8,         31    ; Edge 5
 EDGE       6,       7,    10,     9,         31    ; Edge 6
 EDGE       7,       0,    12,    11,          7    ; Edge 7
 EDGE       3,       9,     6,     4,         31    ; Edge 8
 EDGE       9,       8,    13,     7,         31    ; Edge 9
 EDGE       8,       6,     9,     8,         31    ; Edge 10
 EDGE       0,      10,    11,     0,         31    ; Edge 11
 EDGE       7,      10,    11,     9,         31    ; Edge 12
 EDGE       1,      11,     2,     0,         31    ; Edge 13
 EDGE       2,      11,     4,     2,         31    ; Edge 14
 EDGE       0,      12,    12,     1,         31    ; Edge 15
 EDGE       7,      12,    12,    10,         31    ; Edge 16
 EDGE       1,      13,     3,     1,         31    ; Edge 17
 EDGE       2,      13,     5,     3,         31    ; Edge 18
 EDGE      10,      11,    13,     0,         31    ; Edge 19
 EDGE      12,      13,    14,     1,         31    ; Edge 20
 EDGE       8,      10,    13,     9,         31    ; Edge 21
 EDGE       9,      11,    13,     4,         31    ; Edge 22
 EDGE       5,      12,    14,    10,         31    ; Edge 23
 EDGE       4,      13,    14,     5,         31    ; Edge 24
 EDGE      14,      15,     0,     0,          5    ; Edge 25
 EDGE      15,      16,     0,     0,          3    ; Edge 26
 EDGE      16,      17,     0,     0,          4    ; Edge 27
 EDGE      17,      14,     0,     0,          3    ; Edge 28

.SHIP_ADDER_FACES

    ; normal_x, normal_y, normal_z, visibility
 FACE        0,       39,       10,         31    ; Face 0
 FACE        0,      -39,       10,         31    ; Face 1
 FACE       69,       50,       13,         31    ; Face 2
 FACE       69,      -50,       13,         31    ; Face 3
 FACE       30,       52,        0,         31    ; Face 4
 FACE       30,      -52,        0,         31    ; Face 5
 FACE        0,        0,     -160,         31    ; Face 6
 FACE        0,        0,     -160,         31    ; Face 7
 FACE        0,        0,     -160,         31    ; Face 8
 FACE      -30,       52,        0,         31    ; Face 9
 FACE      -30,      -52,        0,         31    ; Face 10
 FACE      -69,       50,       13,         31    ; Face 11
 FACE      -69,      -50,       13,         31    ; Face 12
 FACE        0,       28,        0,         31    ; Face 13
 FACE        0,      -28,        0,         31    ; Face 14

; ******************************************************************************
;
;       Name: SHIP_GECKO
;       Type: Variable
;   Category: Drawing ships
;    Summary: Ship blueprint for a Gecko
;  Deep dive: Ship blueprints
;
; ******************************************************************************

.SHIP_GECKO

 EQUB 0                 ; Max. canisters on demise = 0
 EQUW 99 * 99           ; Targetable area          = 99 * 99

 EQUB LO(SHIP_GECKO_EDGES - SHIP_GECKO)            ; Edges data offset (low)
 EQUB LO(SHIP_GECKO_FACES - SHIP_GECKO)            ; Faces data offset (low)

 EQUB 69                ; Max. edge count          = (69 - 1) / 4 = 17
 EQUB 0                 ; Gun vertex               = 0
 EQUB 26                ; Explosion count          = 5, as (4 * n) + 6 = 26
 EQUB 72                ; Number of vertices       = 72 / 6 = 12
 EQUB 17                ; Number of edges          = 17
 EQUW 55                ; Bounty                   = 55
 EQUB 36                ; Number of faces          = 36 / 4 = 9
 EQUB 18                ; Visibility distance      = 18
 EQUB 70                ; Max. energy              = 70
 EQUB 30                ; Max. speed               = 30

 EQUB HI(SHIP_GECKO_EDGES - SHIP_GECKO)            ; Edges data offset (high)
 EQUB HI(SHIP_GECKO_FACES - SHIP_GECKO)            ; Faces data offset (high)

 EQUB 3                 ; Normals are scaled by    = 2^3 = 8
 EQUB %00010000         ; Laser power              = 2
                        ; Missiles                 = 0

.SHIP_GECKO_VERTICES

      ;    x,    y,    z, face1, face2, face3, face4, visibility
 VERTEX  -10,   -4,   47,     3,      0,    5,     4,         31    ; Vertex 0
 VERTEX   10,   -4,   47,     1,      0,    3,     2,         31    ; Vertex 1
 VERTEX  -16,    8,  -23,     5,      0,    7,     6,         31    ; Vertex 2
 VERTEX   16,    8,  -23,     1,      0,    8,     7,         31    ; Vertex 3
 VERTEX  -66,    0,   -3,     5,      4,    6,     6,         31    ; Vertex 4
 VERTEX   66,    0,   -3,     2,      1,    8,     8,         31    ; Vertex 5
 VERTEX  -20,  -14,  -23,     4,      3,    7,     6,         31    ; Vertex 6
 VERTEX   20,  -14,  -23,     3,      2,    8,     7,         31    ; Vertex 7
 VERTEX   -8,   -6,   33,     3,      3,    3,     3,         16    ; Vertex 8
 VERTEX    8,   -6,   33,     3,      3,    3,     3,         17    ; Vertex 9
 VERTEX   -8,  -13,  -16,     3,      3,    3,     3,         16    ; Vertex 10
 VERTEX    8,  -13,  -16,     3,      3,    3,     3,         17    ; Vertex 11

.SHIP_GECKO_EDGES

    ; vertex1, vertex2, face1, face2, visibility
 EDGE       0,       1,     3,     0,         31    ; Edge 0
 EDGE       1,       5,     2,     1,         31    ; Edge 1
 EDGE       5,       3,     8,     1,         31    ; Edge 2
 EDGE       3,       2,     7,     0,         31    ; Edge 3
 EDGE       2,       4,     6,     5,         31    ; Edge 4
 EDGE       4,       0,     5,     4,         31    ; Edge 5
 EDGE       5,       7,     8,     2,         31    ; Edge 6
 EDGE       7,       6,     7,     3,         31    ; Edge 7
 EDGE       6,       4,     6,     4,         31    ; Edge 8
 EDGE       0,       2,     5,     0,         29    ; Edge 9
 EDGE       1,       3,     1,     0,         30    ; Edge 10
 EDGE       0,       6,     4,     3,         29    ; Edge 11
 EDGE       1,       7,     3,     2,         30    ; Edge 12
 EDGE       2,       6,     7,     6,         20    ; Edge 13
 EDGE       3,       7,     8,     7,         20    ; Edge 14
 EDGE       8,      10,     3,     3,         16    ; Edge 15
 EDGE       9,      11,     3,     3,         17    ; Edge 16

.SHIP_GECKO_FACES

    ; normal_x, normal_y, normal_z, visibility
 FACE        0,       31,        5,         31    ; Face 0
 FACE        4,       45,        8,         31    ; Face 1
 FACE       25,     -108,       19,         31    ; Face 2
 FACE        0,      -84,       12,         31    ; Face 3
 FACE      -25,     -108,       19,         31    ; Face 4
 FACE       -4,       45,        8,         31    ; Face 5
 FACE      -88,       16,     -214,         31    ; Face 6
 FACE        0,        0,     -187,         31    ; Face 7
 FACE       88,       16,     -214,         31    ; Face 8

; ******************************************************************************
;
;       Name: SHIP_COBRA_MK_1
;       Type: Variable
;   Category: Drawing ships
;    Summary: Ship blueprint for a Cobra Mk I
;  Deep dive: Ship blueprints
;
; ******************************************************************************

.SHIP_COBRA_MK_1

 EQUB 3                 ; Max. canisters on demise = 3
 EQUW 99 * 99           ; Targetable area          = 99 * 99

 EQUB LO(SHIP_COBRA_MK_1_EDGES - SHIP_COBRA_MK_1)  ; Edges data offset (low)
 EQUB LO(SHIP_COBRA_MK_1_FACES - SHIP_COBRA_MK_1)  ; Faces data offset (low)

 EQUB 73                ; Max. edge count          = (73 - 1) / 4 = 18
 EQUB 40                ; Gun vertex               = 40 / 4 = 10
 EQUB 26                ; Explosion count          = 5, as (4 * n) + 6 = 26
 EQUB 66                ; Number of vertices       = 66 / 6 = 11
 EQUB 18                ; Number of edges          = 18
 EQUW 75                ; Bounty                   = 75
 EQUB 40                ; Number of faces          = 40 / 4 = 10
 EQUB 19                ; Visibility distance      = 19
 EQUB 90                ; Max. energy              = 90
 EQUB 26                ; Max. speed               = 26

 EQUB HI(SHIP_COBRA_MK_1_EDGES - SHIP_COBRA_MK_1)  ; Edges data offset (high)
 EQUB HI(SHIP_COBRA_MK_1_FACES - SHIP_COBRA_MK_1)  ; Faces data offset (high)

 EQUB 2                 ; Normals are scaled by    = 2^2 = 4
 EQUB %00010010         ; Laser power              = 2
                        ; Missiles                 = 2

.SHIP_COBRA_MK_1_VERTICES

      ;    x,    y,    z, face1, face2, face3, face4, visibility
 VERTEX  -18,   -1,   50,     1,      0,    3,     2,         31    ; Vertex 0
 VERTEX   18,   -1,   50,     1,      0,    5,     4,         31    ; Vertex 1
 VERTEX  -66,    0,    7,     3,      2,    8,     8,         31    ; Vertex 2
 VERTEX   66,    0,    7,     5,      4,    9,     9,         31    ; Vertex 3
 VERTEX  -32,   12,  -38,     6,      2,    8,     7,         31    ; Vertex 4
 VERTEX   32,   12,  -38,     6,      4,    9,     7,         31    ; Vertex 5
 VERTEX  -54,  -12,  -38,     3,      1,    8,     7,         31    ; Vertex 6
 VERTEX   54,  -12,  -38,     5,      1,    9,     7,         31    ; Vertex 7
 VERTEX    0,   12,   -6,     2,      0,    6,     4,         20    ; Vertex 8
 VERTEX    0,   -1,   50,     1,      0,    1,     1,          2    ; Vertex 9
 VERTEX    0,   -1,   60,     1,      0,    1,     1,         31    ; Vertex 10

.SHIP_COBRA_MK_1_EDGES

    ; vertex1, vertex2, face1, face2, visibility
 EDGE       1,       0,     1,     0,         31    ; Edge 0
 EDGE       0,       2,     3,     2,         31    ; Edge 1
 EDGE       2,       6,     8,     3,         31    ; Edge 2
 EDGE       6,       7,     7,     1,         31    ; Edge 3
 EDGE       7,       3,     9,     5,         31    ; Edge 4
 EDGE       3,       1,     5,     4,         31    ; Edge 5
 EDGE       2,       4,     8,     2,         31    ; Edge 6
 EDGE       4,       5,     7,     6,         31    ; Edge 7
 EDGE       5,       3,     9,     4,         31    ; Edge 8
 EDGE       0,       8,     2,     0,         20    ; Edge 9
 EDGE       8,       1,     4,     0,         20    ; Edge 10
 EDGE       4,       8,     6,     2,         16    ; Edge 11
 EDGE       8,       5,     6,     4,         16    ; Edge 12
 EDGE       4,       6,     8,     7,         31    ; Edge 13
 EDGE       5,       7,     9,     7,         31    ; Edge 14
 EDGE       0,       6,     3,     1,         20    ; Edge 15
 EDGE       1,       7,     5,     1,         20    ; Edge 16
 EDGE      10,       9,     1,     0,          2    ; Edge 17

.SHIP_COBRA_MK_1_FACES

    ; normal_x, normal_y, normal_z, visibility
 FACE        0,       41,       10,         31    ; Face 0
 FACE        0,      -27,        3,         31    ; Face 1
 FACE       -8,       46,        8,         31    ; Face 2
 FACE      -12,      -57,       12,         31    ; Face 3
 FACE        8,       46,        8,         31    ; Face 4
 FACE       12,      -57,       12,         31    ; Face 5
 FACE        0,       49,        0,         31    ; Face 6
 FACE        0,        0,     -154,         31    ; Face 7
 FACE     -121,      111,      -62,         31    ; Face 8
 FACE      121,      111,      -62,         31    ; Face 9

; ******************************************************************************
;
;       Name: SHIP_WORM
;       Type: Variable
;   Category: Drawing ships
;    Summary: Ship blueprint for a Worm
;  Deep dive: Ship blueprints
;
; ******************************************************************************

.SHIP_WORM

 EQUB 0                 ; Max. canisters on demise = 0
 EQUW 99 * 99           ; Targetable area          = 99 * 99

 EQUB LO(SHIP_WORM_EDGES - SHIP_WORM)              ; Edges data offset (low)
 EQUB LO(SHIP_WORM_FACES - SHIP_WORM)              ; Faces data offset (low)

 EQUB 77                ; Max. edge count          = (77 - 1) / 4 = 19
 EQUB 0                 ; Gun vertex               = 0
 EQUB 18                ; Explosion count          = 3, as (4 * n) + 6 = 18
 EQUB 60                ; Number of vertices       = 60 / 6 = 10
 EQUB 16                ; Number of edges          = 16
 EQUW 0                 ; Bounty                   = 0
 EQUB 32                ; Number of faces          = 32 / 4 = 8
 EQUB 19                ; Visibility distance      = 19
 EQUB 30                ; Max. energy              = 30
 EQUB 23                ; Max. speed               = 23

 EQUB HI(SHIP_WORM_EDGES - SHIP_WORM)              ; Edges data offset (high)
 EQUB HI(SHIP_WORM_FACES - SHIP_WORM)              ; Faces data offset (high)

 EQUB 3                 ; Normals are scaled by    = 2^3 = 8
 EQUB %00001000         ; Laser power              = 1
                        ; Missiles                 = 0

.SHIP_WORM_VERTICES

      ;    x,    y,    z, face1, face2, face3, face4, visibility
 VERTEX   10,  -10,   35,     2,      0,    7,     7,         31    ; Vertex 0
 VERTEX  -10,  -10,   35,     3,      0,    7,     7,         31    ; Vertex 1
 VERTEX    5,    6,   15,     1,      0,    4,     2,         31    ; Vertex 2
 VERTEX   -5,    6,   15,     1,      0,    5,     3,         31    ; Vertex 3
 VERTEX   15,  -10,   25,     4,      2,    7,     7,         31    ; Vertex 4
 VERTEX  -15,  -10,   25,     5,      3,    7,     7,         31    ; Vertex 5
 VERTEX   26,  -10,  -25,     6,      4,    7,     7,         31    ; Vertex 6
 VERTEX  -26,  -10,  -25,     6,      5,    7,     7,         31    ; Vertex 7
 VERTEX    8,   14,  -25,     4,      1,    6,     6,         31    ; Vertex 8
 VERTEX   -8,   14,  -25,     5,      1,    6,     6,         31    ; Vertex 9

.SHIP_WORM_EDGES

    ; vertex1, vertex2, face1, face2, visibility
 EDGE       0,       1,     7,     0,         31    ; Edge 0
 EDGE       1,       5,     7,     3,         31    ; Edge 1
 EDGE       5,       7,     7,     5,         31    ; Edge 2
 EDGE       7,       6,     7,     6,         31    ; Edge 3
 EDGE       6,       4,     7,     4,         31    ; Edge 4
 EDGE       4,       0,     7,     2,         31    ; Edge 5
 EDGE       0,       2,     2,     0,         31    ; Edge 6
 EDGE       1,       3,     3,     0,         31    ; Edge 7
 EDGE       4,       2,     4,     2,         31    ; Edge 8
 EDGE       5,       3,     5,     3,         31    ; Edge 9
 EDGE       2,       8,     4,     1,         31    ; Edge 10
 EDGE       8,       6,     6,     4,         31    ; Edge 11
 EDGE       3,       9,     5,     1,         31    ; Edge 12
 EDGE       9,       7,     6,     5,         31    ; Edge 13
 EDGE       2,       3,     1,     0,         31    ; Edge 14
 EDGE       8,       9,     6,     1,         31    ; Edge 15

.SHIP_WORM_FACES

    ; normal_x, normal_y, normal_z, visibility
 FACE        0,       88,       70,         31    ; Face 0
 FACE        0,       69,       14,         31    ; Face 1
 FACE       70,       66,       35,         31    ; Face 2
 FACE      -70,       66,       35,         31    ; Face 3
 FACE       64,       49,       14,         31    ; Face 4
 FACE      -64,       49,       14,         31    ; Face 5
 FACE        0,        0,     -200,         31    ; Face 6
 FACE        0,      -80,        0,         31    ; Face 7

; ******************************************************************************
;
;       Name: SHIP_COBRA_MK_3_P
;       Type: Variable
;   Category: Drawing ships
;    Summary: Ship blueprint for a Cobra Mk III (pirate)
;  Deep dive: Ship blueprints
;
; ******************************************************************************

.SHIP_COBRA_MK_3_P

 EQUB 1                 ; Max. canisters on demise = 1
 EQUW 95 * 95           ; Targetable area          = 95 * 95

 EQUB LO(SHIP_COBRA_MK_3_P_EDGES - SHIP_COBRA_MK_3_P) ; Edges data offset (low)
 EQUB LO(SHIP_COBRA_MK_3_P_FACES - SHIP_COBRA_MK_3_P) ; Faces data offset (low)

 EQUB 157               ; Max. edge count          = (157 - 1) / 4 = 39
 EQUB 84                ; Gun vertex               = 84 / 4 = 21
 EQUB 42                ; Explosion count          = 9, as (4 * n) + 6 = 42
 EQUB 168               ; Number of vertices       = 168 / 6 = 28
 EQUB 38                ; Number of edges          = 38
 EQUW 175               ; Bounty                   = 175
 EQUB 52                ; Number of faces          = 52 / 4 = 13
 EQUB 50                ; Visibility distance      = 50
 EQUB 150               ; Max. energy              = 150
 EQUB 28                ; Max. speed               = 28

 EQUB HI(SHIP_COBRA_MK_3_P_EDGES - SHIP_COBRA_MK_3_P) ; Edges data offset (high)
 EQUB HI(SHIP_COBRA_MK_3_P_FACES - SHIP_COBRA_MK_3_P) ; Faces data offset (high)

 EQUB 1                 ; Normals are scaled by    = 2^1 = 2
 EQUB %00010010         ; Laser power              = 2
                        ; Missiles                 = 2

.SHIP_COBRA_MK_3_P_VERTICES

      ;    x,    y,    z, face1, face2, face3, face4, visibility
 VERTEX   32,    0,   76,    15,     15,   15,    15,         31    ; Vertex 0
 VERTEX  -32,    0,   76,    15,     15,   15,    15,         31    ; Vertex 1
 VERTEX    0,   26,   24,    15,     15,   15,    15,         31    ; Vertex 2
 VERTEX -120,   -3,   -8,     3,      7,   10,    10,         31    ; Vertex 3
 VERTEX  120,   -3,   -8,     4,      8,   12,    12,         31    ; Vertex 4
 VERTEX  -88,   16,  -40,    15,     15,   15,    15,         31    ; Vertex 5
 VERTEX   88,   16,  -40,    15,     15,   15,    15,         31    ; Vertex 6
 VERTEX  128,   -8,  -40,     8,      9,   12,    12,         31    ; Vertex 7
 VERTEX -128,   -8,  -40,     7,      9,   10,    10,         31    ; Vertex 8
 VERTEX    0,   26,  -40,     5,      6,    9,     9,         31    ; Vertex 9
 VERTEX  -32,  -24,  -40,     9,     10,   11,    11,         31    ; Vertex 10
 VERTEX   32,  -24,  -40,     9,     11,   12,    12,         31    ; Vertex 11
 VERTEX  -36,    8,  -40,     9,      9,    9,     9,         20    ; Vertex 12
 VERTEX   -8,   12,  -40,     9,      9,    9,     9,         20    ; Vertex 13
 VERTEX    8,   12,  -40,     9,      9,    9,     9,         20    ; Vertex 14
 VERTEX   36,    8,  -40,     9,      9,    9,     9,         20    ; Vertex 15
 VERTEX   36,  -12,  -40,     9,      9,    9,     9,         20    ; Vertex 16
 VERTEX    8,  -16,  -40,     9,      9,    9,     9,         20    ; Vertex 17
 VERTEX   -8,  -16,  -40,     9,      9,    9,     9,         20    ; Vertex 18
 VERTEX  -36,  -12,  -40,     9,      9,    9,     9,         20    ; Vertex 19
 VERTEX    0,    0,   76,     0,     11,   11,    11,          6    ; Vertex 20
 VERTEX    0,    0,   90,     0,     11,   11,    11,         31    ; Vertex 21
 VERTEX  -80,   -6,  -40,     9,      9,    9,     9,          8    ; Vertex 22
 VERTEX  -80,    6,  -40,     9,      9,    9,     9,          8    ; Vertex 23
 VERTEX  -88,    0,  -40,     9,      9,    9,     9,          6    ; Vertex 24
 VERTEX   80,    6,  -40,     9,      9,    9,     9,          8    ; Vertex 25
 VERTEX   88,    0,  -40,     9,      9,    9,     9,          6    ; Vertex 26
 VERTEX   80,   -6,  -40,     9,      9,    9,     9,          8    ; Vertex 27

.SHIP_COBRA_MK_3_P_EDGES

    ; vertex1, vertex2, face1, face2, visibility
 EDGE       0,       1,     0,    11,         31    ; Edge 0
 EDGE       0,       4,     4,    12,         31    ; Edge 1
 EDGE       1,       3,     3,    10,         31    ; Edge 2
 EDGE       3,       8,     7,    10,         31    ; Edge 3
 EDGE       4,       7,     8,    12,         31    ; Edge 4
 EDGE       6,       7,     8,     9,         31    ; Edge 5
 EDGE       6,       9,     6,     9,         31    ; Edge 6
 EDGE       5,       9,     5,     9,         31    ; Edge 7
 EDGE       5,       8,     7,     9,         31    ; Edge 8
 EDGE       2,       5,     1,     5,         31    ; Edge 9
 EDGE       2,       6,     2,     6,         31    ; Edge 10
 EDGE       3,       5,     3,     7,         31    ; Edge 11
 EDGE       4,       6,     4,     8,         31    ; Edge 12
 EDGE       1,       2,     0,     1,         31    ; Edge 13
 EDGE       0,       2,     0,     2,         31    ; Edge 14
 EDGE       8,      10,     9,    10,         31    ; Edge 15
 EDGE      10,      11,     9,    11,         31    ; Edge 16
 EDGE       7,      11,     9,    12,         31    ; Edge 17
 EDGE       1,      10,    10,    11,         31    ; Edge 18
 EDGE       0,      11,    11,    12,         31    ; Edge 19
 EDGE       1,       5,     1,     3,         29    ; Edge 20
 EDGE       0,       6,     2,     4,         29    ; Edge 21
 EDGE      20,      21,     0,    11,          6    ; Edge 22
 EDGE      12,      13,     9,     9,         20    ; Edge 23
 EDGE      18,      19,     9,     9,         20    ; Edge 24
 EDGE      14,      15,     9,     9,         20    ; Edge 25
 EDGE      16,      17,     9,     9,         20    ; Edge 26
 EDGE      15,      16,     9,     9,         19    ; Edge 27
 EDGE      14,      17,     9,     9,         17    ; Edge 28
 EDGE      13,      18,     9,     9,         19    ; Edge 29
 EDGE      12,      19,     9,     9,         19    ; Edge 30
 EDGE       2,       9,     5,     6,         30    ; Edge 31
 EDGE      22,      24,     9,     9,          6    ; Edge 32
 EDGE      23,      24,     9,     9,          6    ; Edge 33
 EDGE      22,      23,     9,     9,          8    ; Edge 34
 EDGE      25,      26,     9,     9,          6    ; Edge 35
 EDGE      26,      27,     9,     9,          6    ; Edge 36
 EDGE      25,      27,     9,     9,          8    ; Edge 37

.SHIP_COBRA_MK_3_P_FACES

    ; normal_x, normal_y, normal_z, visibility
 FACE        0,       62,       31,         31    ; Face 0
 FACE      -18,       55,       16,         31    ; Face 1
 FACE       18,       55,       16,         31    ; Face 2
 FACE      -16,       52,       14,         31    ; Face 3
 FACE       16,       52,       14,         31    ; Face 4
 FACE      -14,       47,        0,         31    ; Face 5
 FACE       14,       47,        0,         31    ; Face 6
 FACE      -61,      102,        0,         31    ; Face 7
 FACE       61,      102,        0,         31    ; Face 8
 FACE        0,        0,      -80,         31    ; Face 9
 FACE       -7,      -42,        9,         31    ; Face 10
 FACE        0,      -30,        6,         31    ; Face 11
 FACE        7,      -42,        9,         31    ; Face 12

; ******************************************************************************
;
;       Name: SHIP_ASP_MK_2
;       Type: Variable
;   Category: Drawing ships
;    Summary: Ship blueprint for an Asp Mk II
;  Deep dive: Ship blueprints
;
; ******************************************************************************

.SHIP_ASP_MK_2

 EQUB 0                 ; Max. canisters on demise = 0
 EQUW 60 * 60           ; Targetable area          = 60 * 60

 EQUB LO(SHIP_ASP_MK_2_EDGES - SHIP_ASP_MK_2)      ; Edges data offset (low)
 EQUB LO(SHIP_ASP_MK_2_FACES - SHIP_ASP_MK_2)      ; Faces data offset (low)

 EQUB 105               ; Max. edge count          = (105 - 1) / 4 = 26
 EQUB 32                ; Gun vertex               = 32 / 4 = 8
 EQUB 26                ; Explosion count          = 5, as (4 * n) + 6 = 26
 EQUB 114               ; Number of vertices       = 114 / 6 = 19
 EQUB 28                ; Number of edges          = 28
 EQUW 200               ; Bounty                   = 200
 EQUB 48                ; Number of faces          = 48 / 4 = 12
 EQUB 40                ; Visibility distance      = 40
 EQUB 150               ; Max. energy              = 150
 EQUB 40                ; Max. speed               = 40

 EQUB HI(SHIP_ASP_MK_2_EDGES - SHIP_ASP_MK_2)      ; Edges data offset (high)
 EQUB HI(SHIP_ASP_MK_2_FACES - SHIP_ASP_MK_2)      ; Faces data offset (high)

 EQUB 1                 ; Normals are scaled by    = 2^1 = 2
 EQUB %00101001         ; Laser power              = 5
                        ; Missiles                 = 1

.SHIP_ASP_MK_2_VERTICES

      ;    x,    y,    z, face1, face2, face3, face4, visibility
 VERTEX    0,  -18,    0,     1,      0,    2,     2,         22    ; Vertex 0
 VERTEX    0,   -9,  -45,     2,      1,   11,    11,         31    ; Vertex 1
 VERTEX   43,    0,  -45,     6,      1,   11,    11,         31    ; Vertex 2
 VERTEX   69,   -3,    0,     6,      1,    9,     7,         31    ; Vertex 3
 VERTEX   43,  -14,   28,     1,      0,    7,     7,         31    ; Vertex 4
 VERTEX  -43,    0,  -45,     5,      2,   11,    11,         31    ; Vertex 5
 VERTEX  -69,   -3,    0,     5,      2,   10,     8,         31    ; Vertex 6
 VERTEX  -43,  -14,   28,     2,      0,    8,     8,         31    ; Vertex 7
 VERTEX   26,   -7,   73,     4,      0,    9,     7,         31    ; Vertex 8
 VERTEX  -26,   -7,   73,     4,      0,   10,     8,         31    ; Vertex 9
 VERTEX   43,   14,   28,     4,      3,    9,     6,         31    ; Vertex 10
 VERTEX  -43,   14,   28,     4,      3,   10,     5,         31    ; Vertex 11
 VERTEX    0,    9,  -45,     5,      3,   11,     6,         31    ; Vertex 12
 VERTEX  -17,    0,  -45,    11,     11,   11,    11,         10    ; Vertex 13
 VERTEX   17,    0,  -45,    11,     11,   11,    11,          9    ; Vertex 14
 VERTEX    0,   -4,  -45,    11,     11,   11,    11,         10    ; Vertex 15
 VERTEX    0,    4,  -45,    11,     11,   11,    11,          8    ; Vertex 16
 VERTEX    0,   -7,   73,     4,      0,    4,     0,         10    ; Vertex 17
 VERTEX    0,   -7,   83,     4,      0,    4,     0,         10    ; Vertex 18

.SHIP_ASP_MK_2_EDGES

    ; vertex1, vertex2, face1, face2, visibility
 EDGE       0,       1,     2,     1,         22    ; Edge 0
 EDGE       0,       4,     1,     0,         22    ; Edge 1
 EDGE       0,       7,     2,     0,         22    ; Edge 2
 EDGE       1,       2,    11,     1,         31    ; Edge 3
 EDGE       2,       3,     6,     1,         31    ; Edge 4
 EDGE       3,       8,     9,     7,         16    ; Edge 5
 EDGE       8,       9,     4,     0,         31    ; Edge 6
 EDGE       6,       9,    10,     8,         16    ; Edge 7
 EDGE       5,       6,     5,     2,         31    ; Edge 8
 EDGE       1,       5,    11,     2,         31    ; Edge 9
 EDGE       3,       4,     7,     1,         31    ; Edge 10
 EDGE       4,       8,     7,     0,         31    ; Edge 11
 EDGE       6,       7,     8,     2,         31    ; Edge 12
 EDGE       7,       9,     8,     0,         31    ; Edge 13
 EDGE       2,      12,    11,     6,         31    ; Edge 14
 EDGE       5,      12,    11,     5,         31    ; Edge 15
 EDGE      10,      12,     6,     3,         22    ; Edge 16
 EDGE      11,      12,     5,     3,         22    ; Edge 17
 EDGE      10,      11,     4,     3,         22    ; Edge 18
 EDGE       6,      11,    10,     5,         31    ; Edge 19
 EDGE       9,      11,    10,     4,         31    ; Edge 20
 EDGE       3,      10,     9,     6,         31    ; Edge 21
 EDGE       8,      10,     9,     4,         31    ; Edge 22
 EDGE      13,      15,    11,    11,         10    ; Edge 23
 EDGE      15,      14,    11,    11,          9    ; Edge 24
 EDGE      14,      16,    11,    11,          8    ; Edge 25
 EDGE      16,      13,    11,    11,          8    ; Edge 26
 EDGE      18,      17,     4,     0,         10    ; Edge 27

.SHIP_ASP_MK_2_FACES

    ; normal_x, normal_y, normal_z, visibility
 FACE        0,      -35,        5,         31    ; Face 0
 FACE        8,      -38,       -7,         31    ; Face 1
 FACE       -8,      -38,       -7,         31    ; Face 2
 FACE        0,       24,       -1,         22    ; Face 3
 FACE        0,       43,       19,         31    ; Face 4
 FACE       -6,       28,       -2,         31    ; Face 5
 FACE        6,       28,       -2,         31    ; Face 6
 FACE       59,      -64,       31,         31    ; Face 7
 FACE      -59,      -64,       31,         31    ; Face 8
 FACE       80,       46,       50,         31    ; Face 9
 FACE      -80,       46,       50,         31    ; Face 10
 FACE        0,        0,      -90,         31    ; Face 11

 EQUB $00, $FF          ; These bytes appear to be unused
 EQUB $FF, $00

; ******************************************************************************
;
;       Name: SHIP_PYTHON_P
;       Type: Variable
;   Category: Drawing ships
;    Summary: Ship blueprint for a Python (pirate)
;  Deep dive: Ship blueprints
;
; ******************************************************************************

.SHIP_PYTHON_P

 EQUB 2                 ; Max. canisters on demise = 2
 EQUW 80 * 80           ; Targetable area          = 80 * 80

 EQUB LO(SHIP_PYTHON_P_EDGES - SHIP_PYTHON_P)      ; Edges data offset (low)
 EQUB LO(SHIP_PYTHON_P_FACES - SHIP_PYTHON_P)      ; Faces data offset (low)

 EQUB 89                ; Max. edge count          = (89 - 1) / 4 = 22
 EQUB 0                 ; Gun vertex               = 0
 EQUB 42                ; Explosion count          = 9, as (4 * n) + 6 = 42
 EQUB 66                ; Number of vertices       = 66 / 6 = 11
 EQUB 26                ; Number of edges          = 26
 EQUW 200               ; Bounty                   = 200
 EQUB 52                ; Number of faces          = 52 / 4 = 13
 EQUB 40                ; Visibility distance      = 40
 EQUB 250               ; Max. energy              = 250
 EQUB 20                ; Max. speed               = 20

 EQUB HI(SHIP_PYTHON_P_EDGES - SHIP_PYTHON_P)      ; Edges data offset (high)
 EQUB HI(SHIP_PYTHON_P_FACES - SHIP_PYTHON_P)      ; Faces data offset (high)

 EQUB 0                 ; Normals are scaled by    = 2^0 = 1
 EQUB %00011011         ; Laser power              = 3
                        ; Missiles                 = 3

.SHIP_PYTHON_P_VERTICES

      ;    x,    y,    z, face1, face2, face3, face4, visibility
 VERTEX    0,    0,  224,     0,      1,    2,     3,         31    ; Vertex 0
 VERTEX    0,   48,   48,     0,      1,    4,     5,         31    ; Vertex 1
 VERTEX   96,    0,  -16,    15,     15,   15,    15,         31    ; Vertex 2
 VERTEX  -96,    0,  -16,    15,     15,   15,    15,         31    ; Vertex 3
 VERTEX    0,   48,  -32,     4,      5,    8,     9,         31    ; Vertex 4
 VERTEX    0,   24, -112,     9,      8,   12,    12,         31    ; Vertex 5
 VERTEX  -48,    0, -112,     8,     11,   12,    12,         31    ; Vertex 6
 VERTEX   48,    0, -112,     9,     10,   12,    12,         31    ; Vertex 7
 VERTEX    0,  -48,   48,     2,      3,    6,     7,         31    ; Vertex 8
 VERTEX    0,  -48,  -32,     6,      7,   10,    11,         31    ; Vertex 9
 VERTEX    0,  -24, -112,    10,     11,   12,    12,         31    ; Vertex 10

.SHIP_PYTHON_P_EDGES

    ; vertex1, vertex2, face1, face2, visibility
 EDGE       0,       8,     2,     3,         31    ; Edge 0
 EDGE       0,       3,     0,     2,         31    ; Edge 1
 EDGE       0,       2,     1,     3,         31    ; Edge 2
 EDGE       0,       1,     0,     1,         31    ; Edge 3
 EDGE       2,       4,     9,     5,         31    ; Edge 4
 EDGE       1,       2,     1,     5,         31    ; Edge 5
 EDGE       2,       8,     7,     3,         31    ; Edge 6
 EDGE       1,       3,     0,     4,         31    ; Edge 7
 EDGE       3,       8,     2,     6,         31    ; Edge 8
 EDGE       2,       9,     7,    10,         31    ; Edge 9
 EDGE       3,       4,     4,     8,         31    ; Edge 10
 EDGE       3,       9,     6,    11,         31    ; Edge 11
 EDGE       3,       5,     8,     8,          7    ; Edge 12
 EDGE       3,      10,    11,    11,          7    ; Edge 13
 EDGE       2,       5,     9,     9,          7    ; Edge 14
 EDGE       2,      10,    10,    10,          7    ; Edge 15
 EDGE       2,       7,     9,    10,         31    ; Edge 16
 EDGE       3,       6,     8,    11,         31    ; Edge 17
 EDGE       5,       6,     8,    12,         31    ; Edge 18
 EDGE       5,       7,     9,    12,         31    ; Edge 19
 EDGE       7,      10,    12,    10,         31    ; Edge 20
 EDGE       6,      10,    11,    12,         31    ; Edge 21
 EDGE       4,       5,     8,     9,         31    ; Edge 22
 EDGE       9,      10,    10,    11,         31    ; Edge 23
 EDGE       1,       4,     4,     5,         31    ; Edge 24
 EDGE       8,       9,     6,     7,         31    ; Edge 25

.SHIP_PYTHON_P_FACES

    ; normal_x, normal_y, normal_z, visibility
 FACE      -27,       40,       11,         31    ; Face 0
 FACE       27,       40,       11,         31    ; Face 1
 FACE      -27,      -40,       11,         31    ; Face 2
 FACE       27,      -40,       11,         31    ; Face 3
 FACE      -19,       38,        0,         31    ; Face 4
 FACE       19,       38,        0,         31    ; Face 5
 FACE      -19,      -38,        0,         31    ; Face 6
 FACE       19,      -38,        0,         31    ; Face 7
 FACE      -25,       37,      -11,         31    ; Face 8
 FACE       25,       37,      -11,         31    ; Face 9
 FACE       25,      -37,      -11,         31    ; Face 10
 FACE      -25,      -37,      -11,         31    ; Face 11
 FACE        0,        0,     -112,         31    ; Face 12

; ******************************************************************************
;
;       Name: SHIP_FER_DE_LANCE
;       Type: Variable
;   Category: Drawing ships
;    Summary: Ship blueprint for a Fer-de-Lance
;  Deep dive: Ship blueprints
;
; ******************************************************************************

.SHIP_FER_DE_LANCE

 EQUB 0                 ; Max. canisters on demise = 0
 EQUW 40 * 40           ; Targetable area          = 40 * 40

 EQUB LO(SHIP_FER_DE_LANCE_EDGES - SHIP_FER_DE_LANCE) ; Edges data offset (low)
 EQUB LO(SHIP_FER_DE_LANCE_FACES - SHIP_FER_DE_LANCE) ; Faces data offset (low)

 EQUB 109               ; Max. edge count          = (109 - 1) / 4 = 27
 EQUB 0                 ; Gun vertex               = 0
 EQUB 26                ; Explosion count          = 5, as (4 * n) + 6 = 26
 EQUB 114               ; Number of vertices       = 114 / 6 = 19
 EQUB 27                ; Number of edges          = 27
 EQUW 0                 ; Bounty                   = 0
 EQUB 40                ; Number of faces          = 40 / 4 = 10
 EQUB 40                ; Visibility distance      = 40
 EQUB 160               ; Max. energy              = 160
 EQUB 30                ; Max. speed               = 30

 EQUB HI(SHIP_FER_DE_LANCE_EDGES - SHIP_FER_DE_LANCE) ; Edges data offset (high)
 EQUB HI(SHIP_FER_DE_LANCE_FACES - SHIP_FER_DE_LANCE) ; Faces data offset (high)

 EQUB 1                 ; Normals are scaled by    = 2^1 = 2
 EQUB %00010010         ; Laser power              = 2
                        ; Missiles                 = 2

.SHIP_FER_DE_LANCE_VERTICES

      ;    x,    y,    z, face1, face2, face3, face4, visibility
 VERTEX    0,  -14,  108,     1,      0,    9,     5,         31    ; Vertex 0
 VERTEX  -40,  -14,   -4,     2,      1,    9,     9,         31    ; Vertex 1
 VERTEX  -12,  -14,  -52,     3,      2,    9,     9,         31    ; Vertex 2
 VERTEX   12,  -14,  -52,     4,      3,    9,     9,         31    ; Vertex 3
 VERTEX   40,  -14,   -4,     5,      4,    9,     9,         31    ; Vertex 4
 VERTEX  -40,   14,   -4,     1,      0,    6,     2,         28    ; Vertex 5
 VERTEX  -12,    2,  -52,     3,      2,    7,     6,         28    ; Vertex 6
 VERTEX   12,    2,  -52,     4,      3,    8,     7,         28    ; Vertex 7
 VERTEX   40,   14,   -4,     4,      0,    8,     5,         28    ; Vertex 8
 VERTEX    0,   18,  -20,     6,      0,    8,     7,         15    ; Vertex 9
 VERTEX   -3,  -11,   97,     0,      0,    0,     0,         11    ; Vertex 10
 VERTEX  -26,    8,   18,     0,      0,    0,     0,          9    ; Vertex 11
 VERTEX  -16,   14,   -4,     0,      0,    0,     0,         11    ; Vertex 12
 VERTEX    3,  -11,   97,     0,      0,    0,     0,         11    ; Vertex 13
 VERTEX   26,    8,   18,     0,      0,    0,     0,          9    ; Vertex 14
 VERTEX   16,   14,   -4,     0,      0,    0,     0,         11    ; Vertex 15
 VERTEX    0,  -14,  -20,     9,      9,    9,     9,         12    ; Vertex 16
 VERTEX  -14,  -14,   44,     9,      9,    9,     9,         12    ; Vertex 17
 VERTEX   14,  -14,   44,     9,      9,    9,     9,         12    ; Vertex 18

.SHIP_FER_DE_LANCE_EDGES

    ; vertex1, vertex2, face1, face2, visibility
 EDGE       0,       1,     9,     1,         31    ; Edge 0
 EDGE       1,       2,     9,     2,         31    ; Edge 1
 EDGE       2,       3,     9,     3,         31    ; Edge 2
 EDGE       3,       4,     9,     4,         31    ; Edge 3
 EDGE       0,       4,     9,     5,         31    ; Edge 4
 EDGE       0,       5,     1,     0,         28    ; Edge 5
 EDGE       5,       6,     6,     2,         28    ; Edge 6
 EDGE       6,       7,     7,     3,         28    ; Edge 7
 EDGE       7,       8,     8,     4,         28    ; Edge 8
 EDGE       0,       8,     5,     0,         28    ; Edge 9
 EDGE       5,       9,     6,     0,         15    ; Edge 10
 EDGE       6,       9,     7,     6,         11    ; Edge 11
 EDGE       7,       9,     8,     7,         11    ; Edge 12
 EDGE       8,       9,     8,     0,         15    ; Edge 13
 EDGE       1,       5,     2,     1,         14    ; Edge 14
 EDGE       2,       6,     3,     2,         14    ; Edge 15
 EDGE       3,       7,     4,     3,         14    ; Edge 16
 EDGE       4,       8,     5,     4,         14    ; Edge 17
 EDGE      10,      11,     0,     0,          8    ; Edge 18
 EDGE      11,      12,     0,     0,          9    ; Edge 19
 EDGE      10,      12,     0,     0,         11    ; Edge 20
 EDGE      13,      14,     0,     0,          8    ; Edge 21
 EDGE      14,      15,     0,     0,          9    ; Edge 22
 EDGE      13,      15,     0,     0,         11    ; Edge 23
 EDGE      16,      17,     9,     9,         12    ; Edge 24
 EDGE      16,      18,     9,     9,         12    ; Edge 25
 EDGE      17,      18,     9,     9,          8    ; Edge 26

.SHIP_FER_DE_LANCE_FACES

    ; normal_x, normal_y, normal_z, visibility
 FACE        0,       24,        6,         28    ; Face 0
 FACE      -68,        0,       24,         31    ; Face 1
 FACE      -63,        0,      -37,         31    ; Face 2
 FACE        0,        0,     -104,         31    ; Face 3
 FACE       63,        0,      -37,         31    ; Face 4
 FACE       68,        0,       24,         31    ; Face 5
 FACE      -12,       46,      -19,         28    ; Face 6
 FACE        0,       45,      -22,         28    ; Face 7
 FACE       12,       46,      -19,         28    ; Face 8
 FACE        0,      -28,        0,         31    ; Face 9

; ******************************************************************************
;
;       Name: SHIP_MORAY
;       Type: Variable
;   Category: Drawing ships
;    Summary: Ship blueprint for a Moray
;  Deep dive: Ship blueprints
;
; ******************************************************************************

.SHIP_MORAY

 EQUB 1                 ; Max. canisters on demise = 1
 EQUW 30 * 30           ; Targetable area          = 30 * 30

 EQUB LO(SHIP_MORAY_EDGES - SHIP_MORAY)            ; Edges data offset (low)
 EQUB LO(SHIP_MORAY_FACES - SHIP_MORAY)            ; Faces data offset (low)

 EQUB 73                ; Max. edge count          = (73 - 1) / 4 = 18
 EQUB 0                 ; Gun vertex               = 0
 EQUB 26                ; Explosion count          = 5, as (4 * n) + 6 = 26
 EQUB 84                ; Number of vertices       = 84 / 6 = 14
 EQUB 19                ; Number of edges          = 19
 EQUW 50                ; Bounty                   = 50
 EQUB 36                ; Number of faces          = 36 / 4 = 9
 EQUB 40                ; Visibility distance      = 40
 EQUB 100               ; Max. energy              = 100
 EQUB 25                ; Max. speed               = 25

 EQUB HI(SHIP_MORAY_EDGES - SHIP_MORAY)            ; Edges data offset (high)
 EQUB HI(SHIP_MORAY_FACES - SHIP_MORAY)            ; Faces data offset (high)

 EQUB 2                 ; Normals are scaled by    = 2^2 = 4
 EQUB %00010000         ; Laser power              = 2
                        ; Missiles                 = 0

.SHIP_MORAY_VERTICES

      ;    x,    y,    z, face1, face2, face3, face4, visibility
 VERTEX   15,    0,   65,     2,      0,    8,     7,         31    ; Vertex 0
 VERTEX  -15,    0,   65,     1,      0,    7,     6,         31    ; Vertex 1
 VERTEX    0,   18,  -40,    15,     15,   15,    15,         17    ; Vertex 2
 VERTEX  -60,    0,    0,     3,      1,    6,     6,         31    ; Vertex 3
 VERTEX   60,    0,    0,     5,      2,    8,     8,         31    ; Vertex 4
 VERTEX   30,  -27,  -10,     5,      4,    8,     7,         24    ; Vertex 5
 VERTEX  -30,  -27,  -10,     4,      3,    7,     6,         24    ; Vertex 6
 VERTEX   -9,   -4,  -25,     4,      4,    4,     4,          7    ; Vertex 7
 VERTEX    9,   -4,  -25,     4,      4,    4,     4,          7    ; Vertex 8
 VERTEX    0,  -18,  -16,     4,      4,    4,     4,          7    ; Vertex 9
 VERTEX   13,    3,   49,     0,      0,    0,     0,          5    ; Vertex 10
 VERTEX    6,    0,   65,     0,      0,    0,     0,          5    ; Vertex 11
 VERTEX  -13,    3,   49,     0,      0,    0,     0,          5    ; Vertex 12
 VERTEX   -6,    0,   65,     0,      0,    0,     0,          5    ; Vertex 13

.SHIP_MORAY_EDGES

    ; vertex1, vertex2, face1, face2, visibility
 EDGE       0,       1,     7,     0,         31    ; Edge 0
 EDGE       1,       3,     6,     1,         31    ; Edge 1
 EDGE       3,       6,     6,     3,         24    ; Edge 2
 EDGE       5,       6,     7,     4,         24    ; Edge 3
 EDGE       4,       5,     8,     5,         24    ; Edge 4
 EDGE       0,       4,     8,     2,         31    ; Edge 5
 EDGE       1,       6,     7,     6,         15    ; Edge 6
 EDGE       0,       5,     8,     7,         15    ; Edge 7
 EDGE       0,       2,     2,     0,         15    ; Edge 8
 EDGE       1,       2,     1,     0,         15    ; Edge 9
 EDGE       2,       3,     3,     1,         17    ; Edge 10
 EDGE       2,       4,     5,     2,         17    ; Edge 11
 EDGE       2,       5,     5,     4,         13    ; Edge 12
 EDGE       2,       6,     4,     3,         13    ; Edge 13
 EDGE       7,       8,     4,     4,          5    ; Edge 14
 EDGE       7,       9,     4,     4,          7    ; Edge 15
 EDGE       8,       9,     4,     4,          7    ; Edge 16
 EDGE      10,      11,     0,     0,          5    ; Edge 17
 EDGE      12,      13,     0,     0,          5    ; Edge 18

.SHIP_MORAY_FACES

    ; normal_x, normal_y, normal_z, visibility
 FACE        0,       43,        7,         31    ; Face 0
 FACE      -10,       49,        7,         31    ; Face 1
 FACE       10,       49,        7,         31    ; Face 2
 FACE      -59,      -28,     -101,         24    ; Face 3
 FACE        0,      -52,      -78,         24    ; Face 4
 FACE       59,      -28,     -101,         24    ; Face 5
 FACE      -72,      -99,       50,         31    ; Face 6
 FACE        0,      -83,       30,         31    ; Face 7
 FACE       72,      -99,       50,         31    ; Face 8

; ******************************************************************************
;
;       Name: SHIP_THARGOID
;       Type: Variable
;   Category: Drawing ships
;    Summary: Ship blueprint for a Thargoid mothership
;  Deep dive: Ship blueprints
;
; ******************************************************************************

.SHIP_THARGOID

 EQUB 0                 ; Max. canisters on demise = 0
 EQUW 99 * 99           ; Targetable area          = 99 * 99

 EQUB LO(SHIP_THARGOID_EDGES - SHIP_THARGOID)      ; Edges data offset (low)
 EQUB LO(SHIP_THARGOID_FACES - SHIP_THARGOID)      ; Faces data offset (low)

 EQUB 105               ; Max. edge count          = (105 - 1) / 4 = 26
 EQUB 60                ; Gun vertex               = 60 / 4 = 15
 EQUB 38                ; Explosion count          = 8, as (4 * n) + 6 = 38
 EQUB 120               ; Number of vertices       = 120 / 6 = 20
 EQUB 26                ; Number of edges          = 26
 EQUW 500               ; Bounty                   = 500
 EQUB 40                ; Number of faces          = 40 / 4 = 10
 EQUB 55                ; Visibility distance      = 55
 EQUB 240               ; Max. energy              = 240
 EQUB 39                ; Max. speed               = 39

 EQUB HI(SHIP_THARGOID_EDGES - SHIP_THARGOID)      ; Edges data offset (high)
 EQUB HI(SHIP_THARGOID_FACES - SHIP_THARGOID)      ; Faces data offset (high)

 EQUB 2                 ; Normals are scaled by    = 2^2 = 4
 EQUB %00010110         ; Laser power              = 2
                        ; Missiles                 = 6

.SHIP_THARGOID_VERTICES

      ;    x,    y,    z, face1, face2, face3, face4, visibility
 VERTEX   32,  -48,   48,     0,      4,    8,     8,         31    ; Vertex 0
 VERTEX   32,  -68,    0,     0,      1,    4,     4,         31    ; Vertex 1
 VERTEX   32,  -48,  -48,     1,      2,    4,     4,         31    ; Vertex 2
 VERTEX   32,    0,  -68,     2,      3,    4,     4,         31    ; Vertex 3
 VERTEX   32,   48,  -48,     3,      4,    5,     5,         31    ; Vertex 4
 VERTEX   32,   68,    0,     4,      5,    6,     6,         31    ; Vertex 5
 VERTEX   32,   48,   48,     4,      6,    7,     7,         31    ; Vertex 6
 VERTEX   32,    0,   68,     4,      7,    8,     8,         31    ; Vertex 7
 VERTEX  -24, -116,  116,     0,      8,    9,     9,         31    ; Vertex 8
 VERTEX  -24, -164,    0,     0,      1,    9,     9,         31    ; Vertex 9
 VERTEX  -24, -116, -116,     1,      2,    9,     9,         31    ; Vertex 10
 VERTEX  -24,    0, -164,     2,      3,    9,     9,         31    ; Vertex 11
 VERTEX  -24,  116, -116,     3,      5,    9,     9,         31    ; Vertex 12
 VERTEX  -24,  164,    0,     5,      6,    9,     9,         31    ; Vertex 13
 VERTEX  -24,  116,  116,     6,      7,    9,     9,         31    ; Vertex 14
 VERTEX  -24,    0,  164,     7,      8,    9,     9,         31    ; Vertex 15
 VERTEX  -24,   64,   80,     9,      9,    9,     9,         30    ; Vertex 16
 VERTEX  -24,   64,  -80,     9,      9,    9,     9,         30    ; Vertex 17
 VERTEX  -24,  -64,  -80,     9,      9,    9,     9,         30    ; Vertex 18
 VERTEX  -24,  -64,   80,     9,      9,    9,     9,         30    ; Vertex 19

.SHIP_THARGOID_EDGES

    ; vertex1, vertex2, face1, face2, visibility
 EDGE       0,       7,     4,     8,         31    ; Edge 0
 EDGE       0,       1,     0,     4,         31    ; Edge 1
 EDGE       1,       2,     1,     4,         31    ; Edge 2
 EDGE       2,       3,     2,     4,         31    ; Edge 3
 EDGE       3,       4,     3,     4,         31    ; Edge 4
 EDGE       4,       5,     4,     5,         31    ; Edge 5
 EDGE       5,       6,     4,     6,         31    ; Edge 6
 EDGE       6,       7,     4,     7,         31    ; Edge 7
 EDGE       0,       8,     0,     8,         31    ; Edge 8
 EDGE       1,       9,     0,     1,         31    ; Edge 9
 EDGE       2,      10,     1,     2,         31    ; Edge 10
 EDGE       3,      11,     2,     3,         31    ; Edge 11
 EDGE       4,      12,     3,     5,         31    ; Edge 12
 EDGE       5,      13,     5,     6,         31    ; Edge 13
 EDGE       6,      14,     6,     7,         31    ; Edge 14
 EDGE       7,      15,     7,     8,         31    ; Edge 15
 EDGE       8,      15,     8,     9,         31    ; Edge 16
 EDGE       8,       9,     0,     9,         31    ; Edge 17
 EDGE       9,      10,     1,     9,         31    ; Edge 18
 EDGE      10,      11,     2,     9,         31    ; Edge 19
 EDGE      11,      12,     3,     9,         31    ; Edge 20
 EDGE      12,      13,     5,     9,         31    ; Edge 21
 EDGE      13,      14,     6,     9,         31    ; Edge 22
 EDGE      14,      15,     7,     9,         31    ; Edge 23
 EDGE      16,      17,     9,     9,         30    ; Edge 24
 EDGE      18,      19,     9,     9,         30    ; Edge 25

.SHIP_THARGOID_FACES

    ; normal_x, normal_y, normal_z, visibility
 FACE      103,      -60,       25,         31    ; Face 0
 FACE      103,      -60,      -25,         31    ; Face 1
 FACE      103,      -25,      -60,         31    ; Face 2
 FACE      103,       25,      -60,         31    ; Face 3
 FACE       64,        0,        0,         31    ; Face 4
 FACE      103,       60,      -25,         31    ; Face 5
 FACE      103,       60,       25,         31    ; Face 6
 FACE      103,       25,       60,         31    ; Face 7
 FACE      103,      -25,       60,         31    ; Face 8
 FACE      -48,        0,        0,         31    ; Face 9

; ******************************************************************************
;
;       Name: SHIP_THARGON
;       Type: Variable
;   Category: Drawing ships
;    Summary: Ship blueprint for a Thargon
;  Deep dive: Ship blueprints
;
; ------------------------------------------------------------------------------
;
; The ship blueprint for the Thargon reuses the edges data from the cargo
; canister, so the edges data offset is negative.
;
; ******************************************************************************

.SHIP_THARGON

 EQUB 0 + (15 << 4)     ; Max. canisters on demise = 0
                        ; Market item when scooped = 15 + 1 = 16 (alien items)
 EQUW 40 * 40           ; Targetable area          = 40 * 40

 EQUB LO(SHIP_CANISTER_EDGES - SHIP_THARGON)       ; Edges from canister
 EQUB LO(SHIP_THARGON_FACES - SHIP_THARGON)        ; Faces data offset (low)

 EQUB 69                ; Max. edge count          = (69 - 1) / 4 = 17
 EQUB 0                 ; Gun vertex               = 0
 EQUB 18                ; Explosion count          = 3, as (4 * n) + 6 = 18
 EQUB 60                ; Number of vertices       = 60 / 6 = 10
 EQUB 15                ; Number of edges          = 15
 EQUW 50                ; Bounty                   = 50
 EQUB 28                ; Number of faces          = 28 / 4 = 7
 EQUB 20                ; Visibility distance      = 20
 EQUB 20                ; Max. energy              = 20
 EQUB 30                ; Max. speed               = 30

 EQUB HI(SHIP_CANISTER_EDGES - SHIP_THARGON)       ; Edges from canister
 EQUB HI(SHIP_THARGON_FACES - SHIP_THARGON)        ; Faces data offset (high)

 EQUB 2                 ; Normals are scaled by    = 2^2 = 4
 EQUB %00010000         ; Laser power              = 2
                        ; Missiles                 = 0

.SHIP_THARGON_VERTICES

      ;    x,    y,    z, face1, face2, face3, face4, visibility
 VERTEX   -9,    0,   40,     1,      0,    5,     5,         31    ; Vertex 0
 VERTEX   -9,  -38,   12,     1,      0,    2,     2,         31    ; Vertex 1
 VERTEX   -9,  -24,  -32,     2,      0,    3,     3,         31    ; Vertex 2
 VERTEX   -9,   24,  -32,     3,      0,    4,     4,         31    ; Vertex 3
 VERTEX   -9,   38,   12,     4,      0,    5,     5,         31    ; Vertex 4
 VERTEX    9,    0,   -8,     5,      1,    6,     6,         31    ; Vertex 5
 VERTEX    9,  -10,  -15,     2,      1,    6,     6,         31    ; Vertex 6
 VERTEX    9,   -6,  -26,     3,      2,    6,     6,         31    ; Vertex 7
 VERTEX    9,    6,  -26,     4,      3,    6,     6,         31    ; Vertex 8
 VERTEX    9,   10,  -15,     5,      4,    6,     6,         31    ; Vertex 9

.SHIP_THARGON_FACES

    ; normal_x, normal_y, normal_z, visibility
 FACE      -36,        0,        0,         31    ; Face 0
 FACE       20,       -5,        7,         31    ; Face 1
 FACE       46,      -42,      -14,         31    ; Face 2
 FACE       36,        0,     -104,         31    ; Face 3
 FACE       46,       42,      -14,         31    ; Face 4
 FACE       20,        5,        7,         31    ; Face 5
 FACE       36,        0,        0,         31    ; Face 6

; ******************************************************************************
;
;       Name: SHIP_CONSTRICTOR
;       Type: Variable
;   Category: Drawing ships
;    Summary: Ship blueprint for a Constrictor
;  Deep dive: Ship blueprints
;
; ******************************************************************************

.SHIP_CONSTRICTOR

 EQUB 3                 ; Max. canisters on demise = 3
 EQUW 65 * 65           ; Targetable area          = 65 * 65

 EQUB LO(SHIP_CONSTRICTOR_EDGES - SHIP_CONSTRICTOR)   ; Edges data offset (low)
 EQUB LO(SHIP_CONSTRICTOR_FACES - SHIP_CONSTRICTOR)   ; Faces data offset (low)

 EQUB 81                ; Max. edge count          = (81 - 1) / 4 = 20
 EQUB 0                 ; Gun vertex               = 0
 EQUB 46                ; Explosion count          = 10, as (4 * n) + 6 = 46
 EQUB 102               ; Number of vertices       = 102 / 6 = 17
 EQUB 24                ; Number of edges          = 24
 EQUW 0                 ; Bounty                   = 0
 EQUB 40                ; Number of faces          = 40 / 4 = 10
 EQUB 45                ; Visibility distance      = 45
 EQUB 252               ; Max. energy              = 252
 EQUB 36                ; Max. speed               = 36

 EQUB HI(SHIP_CONSTRICTOR_EDGES - SHIP_CONSTRICTOR)   ; Edges data offset (high)
 EQUB HI(SHIP_CONSTRICTOR_FACES - SHIP_CONSTRICTOR)   ; Faces data offset (high)

 EQUB 2                 ; Normals are scaled by    = 2^2 = 4
 EQUB %00110100         ; Laser power              = 6
                        ; Missiles                 = 4

.SHIP_CONSTRICTOR_VERTICES

      ;    x,    y,    z, face1, face2, face3, face4, visibility
 VERTEX   20,   -7,   80,     2,      0,    9,     9,         31    ; Vertex 0
 VERTEX  -20,   -7,   80,     1,      0,    9,     9,         31    ; Vertex 1
 VERTEX  -54,   -7,   40,     4,      1,    9,     9,         31    ; Vertex 2
 VERTEX  -54,   -7,  -40,     5,      4,    9,     8,         31    ; Vertex 3
 VERTEX  -20,   13,  -40,     6,      5,    8,     8,         31    ; Vertex 4
 VERTEX   20,   13,  -40,     7,      6,    8,     8,         31    ; Vertex 5
 VERTEX   54,   -7,  -40,     7,      3,    9,     8,         31    ; Vertex 6
 VERTEX   54,   -7,   40,     3,      2,    9,     9,         31    ; Vertex 7
 VERTEX   20,   13,    5,    15,     15,   15,    15,         31    ; Vertex 8
 VERTEX  -20,   13,    5,    15,     15,   15,    15,         31    ; Vertex 9
 VERTEX   20,   -7,   62,     9,      9,    9,     9,         18    ; Vertex 10
 VERTEX  -20,   -7,   62,     9,      9,    9,     9,         18    ; Vertex 11
 VERTEX   25,   -7,  -25,     9,      9,    9,     9,         18    ; Vertex 12
 VERTEX  -25,   -7,  -25,     9,      9,    9,     9,         18    ; Vertex 13
 VERTEX   15,   -7,  -15,     9,      9,    9,     9,         10    ; Vertex 14
 VERTEX  -15,   -7,  -15,     9,      9,    9,     9,         10    ; Vertex 15
 VERTEX    0,   -7,    0,    15,      9,    1,     0,          0    ; Vertex 16

.SHIP_CONSTRICTOR_EDGES

    ; vertex1, vertex2, face1, face2, visibility
 EDGE       0,       1,     9,     0,         31    ; Edge 0
 EDGE       1,       2,     9,     1,         31    ; Edge 1
 EDGE       1,       9,     1,     0,         31    ; Edge 2
 EDGE       0,       8,     2,     0,         31    ; Edge 3
 EDGE       0,       7,     9,     2,         31    ; Edge 4
 EDGE       7,       8,     3,     2,         31    ; Edge 5
 EDGE       2,       9,     4,     1,         31    ; Edge 6
 EDGE       2,       3,     9,     4,         31    ; Edge 7
 EDGE       6,       7,     9,     3,         31    ; Edge 8
 EDGE       6,       8,     7,     3,         31    ; Edge 9
 EDGE       5,       8,     7,     6,         31    ; Edge 10
 EDGE       4,       9,     6,     5,         31    ; Edge 11
 EDGE       3,       9,     5,     4,         31    ; Edge 12
 EDGE       3,       4,     8,     5,         31    ; Edge 13
 EDGE       4,       5,     8,     6,         31    ; Edge 14
 EDGE       5,       6,     8,     7,         31    ; Edge 15
 EDGE       3,       6,     9,     8,         31    ; Edge 16
 EDGE       8,       9,     6,     0,         31    ; Edge 17
 EDGE      10,      12,     9,     9,         18    ; Edge 18
 EDGE      12,      14,     9,     9,          5    ; Edge 19
 EDGE      14,      10,     9,     9,         10    ; Edge 20
 EDGE      11,      15,     9,     9,         10    ; Edge 21
 EDGE      13,      15,     9,     9,          5    ; Edge 22
 EDGE      11,      13,     9,     9,         18    ; Edge 23

.SHIP_CONSTRICTOR_FACES

    ; normal_x, normal_y, normal_z, visibility
 FACE        0,       55,       15,         31    ; Face 0
 FACE      -24,       75,       20,         31    ; Face 1
 FACE       24,       75,       20,         31    ; Face 2
 FACE       44,       75,        0,         31    ; Face 3
 FACE      -44,       75,        0,         31    ; Face 4
 FACE      -44,       75,        0,         31    ; Face 5
 FACE        0,       53,        0,         31    ; Face 6
 FACE       44,       75,        0,         31    ; Face 7
 FACE        0,        0,     -160,         31    ; Face 8
 FACE        0,      -27,        0,         31    ; Face 9

; ******************************************************************************
;
;       Name: SHIP_COUGAR
;       Type: Variable
;   Category: Drawing ships
;    Summary: Ship blueprint for a Cougar
;  Deep dive: Ship blueprints
;             The elusive Cougar
;
; ******************************************************************************

.SHIP_COUGAR

 EQUB 3                 ; Max. canisters on demise = 3
 EQUW 70 * 70           ; Targetable area          = 70 * 70

 EQUB LO(SHIP_COUGAR_EDGES - SHIP_COUGAR)          ; Edges data offset (low)
 EQUB LO(SHIP_COUGAR_FACES - SHIP_COUGAR)          ; Faces data offset (low)

 EQUB 105               ; Max. edge count          = (105 - 1) / 4 = 26
 EQUB 0                 ; Gun vertex               = 0
 EQUB 42                ; Explosion count          = 9, as (4 * n) + 6 = 42
 EQUB 114               ; Number of vertices       = 114 / 6 = 19
 EQUB 25                ; Number of edges          = 25
 EQUW 0                 ; Bounty                   = 0
 EQUB 24                ; Number of faces          = 24 / 4 = 6
 EQUB 34                ; Visibility distance      = 34
 EQUB 252               ; Max. energy              = 252
 EQUB 40                ; Max. speed               = 40

 EQUB HI(SHIP_COUGAR_EDGES - SHIP_COUGAR)          ; Edges data offset (high)
 EQUB HI(SHIP_COUGAR_FACES - SHIP_COUGAR)          ; Faces data offset (high)

 EQUB 2                 ; Normals are scaled by    = 2^2 = 4
 EQUB %00110100         ; Laser power              = 6
                        ; Missiles                 = 4

.SHIP_COUGAR_VERTICES

      ;    x,    y,    z, face1, face2, face3, face4, visibility
 VERTEX    0,    5,   67,     2,      0,    4,     4,         31    ; Vertex 0
 VERTEX  -20,    0,   40,     1,      0,    2,     2,         31    ; Vertex 1
 VERTEX  -40,    0,  -40,     1,      0,    5,     5,         31    ; Vertex 2
 VERTEX    0,   14,  -40,     4,      0,    5,     5,         30    ; Vertex 3
 VERTEX    0,  -14,  -40,     2,      1,    5,     3,         30    ; Vertex 4
 VERTEX   20,    0,   40,     3,      2,    4,     4,         31    ; Vertex 5
 VERTEX   40,    0,  -40,     4,      3,    5,     5,         31    ; Vertex 6
 VERTEX  -36,    0,   56,     1,      0,    1,     1,         31    ; Vertex 7
 VERTEX  -60,    0,  -20,     1,      0,    1,     1,         31    ; Vertex 8
 VERTEX   36,    0,   56,     4,      3,    4,     4,         31    ; Vertex 9
 VERTEX   60,    0,  -20,     4,      3,    4,     4,         31    ; Vertex 10
 VERTEX    0,    7,   35,     0,      0,    4,     4,         18    ; Vertex 11
 VERTEX    0,    8,   25,     0,      0,    4,     4,         20    ; Vertex 12
 VERTEX  -12,    2,   45,     0,      0,    0,     0,         20    ; Vertex 13
 VERTEX   12,    2,   45,     4,      4,    4,     4,         20    ; Vertex 14
 VERTEX  -10,    6,  -40,     5,      5,    5,     5,         20    ; Vertex 15
 VERTEX  -10,   -6,  -40,     5,      5,    5,     5,         20    ; Vertex 16
 VERTEX   10,   -6,  -40,     5,      5,    5,     5,         20    ; Vertex 17
 VERTEX   10,    6,  -40,     5,      5,    5,     5,         20    ; Vertex 18

.SHIP_COUGAR_EDGES

    ; vertex1, vertex2, face1, face2, visibility
 EDGE       0,       1,     2,     0,         31    ; Edge 0
 EDGE       1,       7,     1,     0,         31    ; Edge 1
 EDGE       7,       8,     1,     0,         31    ; Edge 2
 EDGE       8,       2,     1,     0,         31    ; Edge 3
 EDGE       2,       3,     5,     0,         30    ; Edge 4
 EDGE       3,       6,     5,     4,         30    ; Edge 5
 EDGE       2,       4,     5,     1,         30    ; Edge 6
 EDGE       4,       6,     5,     3,         30    ; Edge 7
 EDGE       6,      10,     4,     3,         31    ; Edge 8
 EDGE      10,       9,     4,     3,         31    ; Edge 9
 EDGE       9,       5,     4,     3,         31    ; Edge 10
 EDGE       5,       0,     4,     2,         31    ; Edge 11
 EDGE       0,       3,     4,     0,         27    ; Edge 12
 EDGE       1,       4,     2,     1,         27    ; Edge 13
 EDGE       5,       4,     3,     2,         27    ; Edge 14
 EDGE       1,       2,     1,     0,         26    ; Edge 15
 EDGE       5,       6,     4,     3,         26    ; Edge 16
 EDGE      12,      13,     0,     0,         20    ; Edge 17
 EDGE      13,      11,     0,     0,         18    ; Edge 18
 EDGE      11,      14,     4,     4,         18    ; Edge 19
 EDGE      14,      12,     4,     4,         20    ; Edge 20
 EDGE      15,      16,     5,     5,         18    ; Edge 21
 EDGE      16,      18,     5,     5,         20    ; Edge 22
 EDGE      18,      17,     5,     5,         18    ; Edge 23
 EDGE      17,      15,     5,     5,         20    ; Edge 24

.SHIP_COUGAR_FACES

    ; normal_x, normal_y, normal_z, visibility
 FACE      -16,       46,        4,         31    ; Face 0
 FACE      -16,      -46,        4,         31    ; Face 1
 FACE        0,      -27,        5,         31    ; Face 2
 FACE       16,      -46,        4,         31    ; Face 3
 FACE       16,       46,        4,         31    ; Face 4
 FACE        0,        0,     -160,         30    ; Face 5

; ******************************************************************************
;
;       Name: SHIP_DODO
;       Type: Variable
;   Category: Drawing ships
;    Summary: Ship blueprint for a Dodecahedron ("Dodo") space station
;  Deep dive: Ship blueprints
;
; ******************************************************************************

.SHIP_DODO

 EQUB 0                 ; Max. canisters on demise = 0
 EQUW 180 * 180         ; Targetable area          = 180 * 180

 EQUB LO(SHIP_DODO_EDGES - SHIP_DODO)              ; Edges data offset (low)
 EQUB LO(SHIP_DODO_FACES - SHIP_DODO)              ; Faces data offset (low)

 EQUB 101               ; Max. edge count          = (101 - 1) / 4 = 25
 EQUB 0                 ; Gun vertex               = 0
 EQUB 6                 ; Explosion count          = 0, as (4 * n) + 6 = 6
 EQUB 144               ; Number of vertices       = 144 / 6 = 24
 EQUB 34                ; Number of edges          = 34
 EQUW 0                 ; Bounty                   = 0
 EQUB 48                ; Number of faces          = 48 / 4 = 12
 EQUB 125               ; Visibility distance      = 125
 EQUB 240               ; Max. energy              = 240
 EQUB 0                 ; Max. speed               = 0

 EQUB HI(SHIP_DODO_EDGES - SHIP_DODO)              ; Edges data offset (high)
 EQUB HI(SHIP_DODO_FACES - SHIP_DODO)              ; Faces data offset (high)

 EQUB 0                 ; Normals are scaled by    = 2^0 = 1
 EQUB %00000000         ; Laser power              = 0
                        ; Missiles                 = 0

.SHIP_DODO_VERTICES

      ;    x,    y,    z, face1, face2, face3, face4, visibility
 VERTEX    0,  150,  196,     1,      0,    5,     5,         31    ; Vertex 0
 VERTEX  143,   46,  196,     1,      0,    2,     2,         31    ; Vertex 1
 VERTEX   88, -121,  196,     2,      0,    3,     3,         31    ; Vertex 2
 VERTEX  -88, -121,  196,     3,      0,    4,     4,         31    ; Vertex 3
 VERTEX -143,   46,  196,     4,      0,    5,     5,         31    ; Vertex 4
 VERTEX    0,  243,   46,     5,      1,    6,     6,         31    ; Vertex 5
 VERTEX  231,   75,   46,     2,      1,    7,     7,         31    ; Vertex 6
 VERTEX  143, -196,   46,     3,      2,    8,     8,         31    ; Vertex 7
 VERTEX -143, -196,   46,     4,      3,    9,     9,         31    ; Vertex 8
 VERTEX -231,   75,   46,     5,      4,   10,    10,         31    ; Vertex 9
 VERTEX  143,  196,  -46,     6,      1,    7,     7,         31    ; Vertex 10
 VERTEX  231,  -75,  -46,     7,      2,    8,     8,         31    ; Vertex 11
 VERTEX    0, -243,  -46,     8,      3,    9,     9,         31    ; Vertex 12
 VERTEX -231,  -75,  -46,     9,      4,   10,    10,         31    ; Vertex 13
 VERTEX -143,  196,  -46,     6,      5,   10,    10,         31    ; Vertex 14
 VERTEX   88,  121, -196,     7,      6,   11,    11,         31    ; Vertex 15
 VERTEX  143,  -46, -196,     8,      7,   11,    11,         31    ; Vertex 16
 VERTEX    0, -150, -196,     9,      8,   11,    11,         31    ; Vertex 17
 VERTEX -143,  -46, -196,    10,      9,   11,    11,         31    ; Vertex 18
 VERTEX  -88,  121, -196,    10,      6,   11,    11,         31    ; Vertex 19
 VERTEX  -16,   32,  196,     0,      0,    0,     0,         30    ; Vertex 20
 VERTEX  -16,  -32,  196,     0,      0,    0,     0,         30    ; Vertex 21
 VERTEX   16,   32,  196,     0,      0,    0,     0,         23    ; Vertex 22
 VERTEX   16,  -32,  196,     0,      0,    0,     0,         23    ; Vertex 23

.SHIP_DODO_EDGES

    ; vertex1, vertex2, face1, face2, visibility
 EDGE       0,       1,     1,     0,         31    ; Edge 0
 EDGE       1,       2,     2,     0,         31    ; Edge 1
 EDGE       2,       3,     3,     0,         31    ; Edge 2
 EDGE       3,       4,     4,     0,         31    ; Edge 3
 EDGE       4,       0,     5,     0,         31    ; Edge 4
 EDGE       5,      10,     6,     1,         31    ; Edge 5
 EDGE      10,       6,     7,     1,         31    ; Edge 6
 EDGE       6,      11,     7,     2,         31    ; Edge 7
 EDGE      11,       7,     8,     2,         31    ; Edge 8
 EDGE       7,      12,     8,     3,         31    ; Edge 9
 EDGE      12,       8,     9,     3,         31    ; Edge 10
 EDGE       8,      13,     9,     4,         31    ; Edge 11
 EDGE      13,       9,    10,     4,         31    ; Edge 12
 EDGE       9,      14,    10,     5,         31    ; Edge 13
 EDGE      14,       5,     6,     5,         31    ; Edge 14
 EDGE      15,      16,    11,     7,         31    ; Edge 15
 EDGE      16,      17,    11,     8,         31    ; Edge 16
 EDGE      17,      18,    11,     9,         31    ; Edge 17
 EDGE      18,      19,    11,    10,         31    ; Edge 18
 EDGE      19,      15,    11,     6,         31    ; Edge 19
 EDGE       0,       5,     5,     1,         31    ; Edge 20
 EDGE       1,       6,     2,     1,         31    ; Edge 21
 EDGE       2,       7,     3,     2,         31    ; Edge 22
 EDGE       3,       8,     4,     3,         31    ; Edge 23
 EDGE       4,       9,     5,     4,         31    ; Edge 24
 EDGE      10,      15,     7,     6,         31    ; Edge 25
 EDGE      11,      16,     8,     7,         31    ; Edge 26
 EDGE      12,      17,     9,     8,         31    ; Edge 27
 EDGE      13,      18,    10,     9,         31    ; Edge 28
 EDGE      14,      19,    10,     6,         31    ; Edge 29
 EDGE      20,      21,     0,     0,         30    ; Edge 30
 EDGE      21,      23,     0,     0,         20    ; Edge 31
 EDGE      23,      22,     0,     0,         23    ; Edge 32
 EDGE      22,      20,     0,     0,         20    ; Edge 33

.SHIP_DODO_FACES

    ; normal_x, normal_y, normal_z, visibility
 FACE        0,        0,      196,         31    ; Face 0
 FACE      103,      142,       88,         31    ; Face 1
 FACE      169,      -55,       89,         31    ; Face 2
 FACE        0,     -176,       88,         31    ; Face 3
 FACE     -169,      -55,       89,         31    ; Face 4
 FACE     -103,      142,       88,         31    ; Face 5
 FACE        0,      176,      -88,         31    ; Face 6
 FACE      169,       55,      -89,         31    ; Face 7
 FACE      103,     -142,      -88,         31    ; Face 8
 FACE     -103,     -142,      -88,         31    ; Face 9
 FACE     -169,       55,      -89,         31    ; Face 10
 FACE        0,        0,     -196,         31    ; Face 11

 EQUB $00, $FF          ; These bytes appear to be unused
 EQUB $FF, $00

; ******************************************************************************
;
;       Name: SHPPT
;       Type: Subroutine
;   Category: Drawing ships
;    Summary: Draw a distant ship as a point rather than a full wireframe
;
; ******************************************************************************

.SHPPT

 JSR PROJ               ; Project the ship onto the screen, returning:
                        ;
                        ;   * K3(1 0) = the screen x-coordinate
                        ;   * K4(1 0) = the screen y-coordinate
                        ;   * A = K4+1

 ORA K3+1               ; If either of the high bytes of the screen coordinates
 BNE nono               ; are non-zero, jump to nono as the ship is off-screen

 LDY K4                 ; Set Y = the y-coordinate of the dot

 CPY #Y*2-2             ; If the y-coordinate is bigger than the y-coordinate of
 BCS nono               ; the bottom of the screen, jump to nono as the ship's
                        ; dot is off the bottom of the space view

                        ; The C flag is clear at this point as we just passed
                        ; through a BCS, so we call Shpt with the C flag clear

 JSR Shpt               ; Call Shpt to draw a horizontal 4-pixel dash for the
                        ; first row of the dot (i.e. a four-pixel dash)

 INY                    ; Increment Y to the next row (so this is the second row
                        ; of the two-pixel-high dot)

 CLC                    ; Cleat the C flag to pass to Shpt

 JSR Shpt               ; Call Shpt to draw a horizontal 4-pixel dash for the
                        ; second row of the dot (i.e. a four-pixel dash)

 BIT XX1+31             ; If bit 6 of the ship's byte #31 is clear, then there
 BVC nono               ; are no lasers firing, so jump to nono to record that
                        ; we didn't draw anything and return from the subroutine

 LDA XX1+31             ; Clear 6 in the ship's byte #31 to denote that there
 AND #%10111111         ; are no lasers firing (bit 6), as we are about to draw
 STA XX1+31             ; the laser line and this will ensure it flickers off in
                        ; the next iteration

                        ; We now draw the laser line, from the ship dot at
                        ; (X1, Y1), as set in the call to Shpt, to a point on
                        ; the edge of the screen

 LDX #1                 ; Set X = 1 to use as the x-coordinate for the end of
                        ; the laser line for when z_lo < 128 (so the ship fires
                        ; to our left)

 LDA XX1+6              ; Set A = z_lo

 BPL shpt1              ; If z_lo < 128, jump to shpt1 to leave X = 1

 LDX #255               ; Set X = 255 to use as the x-coordinate for the end of
                        ; the laser line for when z_lo >= 128 (so the ship fires
                        ; to our left)
                        ;
                        ; This makes the ship fire to our left and right as it
                        ; gets closer to us, as z_lo reduces from 255 to 0 for
                        ; each reduction in z_hi

.shpt1

 STX X2                 ; Set X2 to the x-coordinate of the end of the laser
                        ; line

 AND #63                ; Set Y2 = z_lo, reduced to the range 0 to 63, plus 32
 ADC #32                ;
 STA Y2                 ; So the end of the laser line moves up and down the
                        ; edge of the screen (between y-coordinate 32 and 95) as
                        ; the ship gets closer to us, as z_lo reduces from 255
                        ; to 0 for each reduction in z_hi

 JSR LOIN               ; Draw the laser line from (X1, Y1) to (X2, Y2)

.nono

 LDA #%11110111         ; Clear bit 3 of the ship's byte #31 to record that
 AND XX1+31             ; nothing is being drawn on-screen for this ship
 STA XX1+31

 RTS                    ; Return from the subroutine

.Shpt

                        ; This routine draws a horizontal 4-pixel dash, for
                        ; either the top or the bottom of the ship's dot
                        ;
                        ; We always call this routine with the C flag clear

 LDA K3                 ; Set A = screen x-coordinate of the ship dot

 STA X1                 ; Set X1 to the screen x-coordinate of the ship dot

 ADC #3                 ; Set A = screen x-coordinate of the ship dot + 3
                        ; (this works because we know the C flag is clear)

 BCS shpt2              ; If the addition overflowed, jump to shpt2 to return
                        ; from the subroutine without drawing the dash

 STA X2                 ; Store the x-coordinate of the ship dot in X1, as this
                        ; is where the dash starts

 STY Y1                 ; Store Y in both y-coordinates, as this is a horizontal
 STY Y2                 ; dash at y-coordinate Y

 JMP LOIN               ; Draw the dash from (X1, Y1) to (X2, Y2), returning
                        ; from the subroutine using a tail call

.shpt2

 PLA                    ; Pull the return address from the stack, so the RTS
 PLA                    ; below actually returns from the subroutine that called
                        ; LL9 (as we called SHPPT from LL9 with a JMP)

 JMP nono               ; Jump to nono to record that we didn't draw anything
                        ; and return from the subroutine

; ******************************************************************************
;
;       Name: LL38
;       Type: Subroutine
;   Category: Maths (Arithmetic)
;    Summary: Calculate (S A) = (S R) + (A Q)
;
; ------------------------------------------------------------------------------
;
; Calculate the following between sign-magnitude numbers:
;
;   (S A) = (S R) + (A Q)
;
; where the sign bytes only contain the sign bits, not magnitudes.
;
; Returns:
;
;   C flag              Set if the addition overflowed, clear otherwise
;
; ******************************************************************************

.LL38

 EOR S                  ; If the sign of A * S is negative, skip to LL35, as
 BMI LL39               ; A and S have different signs so we need to subtract

 LDA Q                  ; Otherwise set A = R + Q, which is the result we need,
 CLC                    ; as S already contains the correct sign
 ADC R

 RTS                    ; Return from the subroutine

.LL39

 LDA R                  ; Set A = R - Q
 SEC
 SBC Q

 BCC P%+4               ; If the subtraction underflowed, skip the next two
                        ; instructions so we can negate the result

 CLC                    ; Otherwise the result is correct, and S contains the
                        ; correct sign of the result as R is the dominant side
                        ; of the subtraction, so clear the C flag

 RTS                    ; And return from the subroutine

                        ; If we get here we need to negate both the result and
                        ; the sign in S, as both are the wrong sign

.LL40

 PHA                    ; Store the result of the subtraction on the stack

 LDA S                  ; Flip the sign of S
 EOR #%10000000
 STA S

 PLA                    ; Restore the subtraction result into A

 EOR #%11111111         ; Negate the result in A using two's complement, i.e.
 ADC #1                 ; set A = ~A + 1

 RTS                    ; Return from the subroutine

; ******************************************************************************
;
;       Name: LL51
;       Type: Subroutine
;   Category: Maths (Geometry)
;    Summary: Calculate the dot product of XX15 and XX16
;
; ------------------------------------------------------------------------------
;
; Calculate the following dot products:
;
;   XX12(1 0) = XX15(5 0) . XX16(5 0)
;   XX12(3 2) = XX15(5 0) . XX16(11 6)
;   XX12(5 4) = XX15(5 0) . XX16(12 17)
;
; storing the results as sign-magnitude numbers in XX12 through XX12+5.
;
; When called from part 5 of LL9, XX12 contains the vector [x y z] to the ship
; we're drawing, and XX16 contains the orientation vectors, so it returns:
;
;   [ x ]   [ sidev_x ]         [ x ]   [ roofv_x ]         [ x ]   [ nosev_x ]
;   [ y ] . [ sidev_y ]         [ y ] . [ roofv_y ]         [ y ] . [ nosev_y ]
;   [ z ]   [ sidev_z ]         [ z ]   [ roofv_z ]         [ z ]   [ nosev_z ]
;
; When called from part 6 of LL9, XX12 contains the vector [x y z] of the vertex
; we're analysing, and XX16 contains the transposed orientation vectors with
; each of them containing the x, y and z elements of the original vectors, so it
; returns:
;
;   [ x ]   [ sidev_x ]         [ x ]   [ sidev_y ]         [ x ]   [ sidev_z ]
;   [ y ] . [ roofv_x ]         [ y ] . [ roofv_y ]         [ y ] . [ roofv_z ]
;   [ z ]   [ nosev_x ]         [ z ]   [ nosev_y ]         [ z ]   [ nosev_z ]
;
; Arguments:
;
;   XX15(1 0)           The ship (or vertex)'s x-coordinate as (x_sign x_lo)
;
;   XX15(3 2)           The ship (or vertex)'s y-coordinate as (y_sign y_lo)
;
;   XX15(5 4)           The ship (or vertex)'s z-coordinate as (z_sign z_lo)
;
;   XX16 to XX16+5      The scaled sidev (or _x) vector, with:
;
;                         * x, y, z magnitudes in XX16, XX16+2, XX16+4
;
;                         * x, y, z signs in XX16+1, XX16+3, XX16+5
;
;   XX16+6 to XX16+11   The scaled roofv (or _y) vector, with:
;
;                         * x, y, z magnitudes in XX16+6, XX16+8, XX16+10
;
;                         * x, y, z signs in XX16+7, XX16+9, XX16+11
;
;   XX16+12 to XX16+17  The scaled nosev (or _z) vector, with:
;
;                         * x, y, z magnitudes in XX16+12, XX16+14, XX16+16
;
;                         * x, y, z signs in XX16+13, XX16+15, XX16+17
;
; Returns:
;
;   XX12(1 0)           The dot product of [x y z] vector with the sidev (or _x)
;                       vector, with the sign in XX12+1 and magnitude in XX12
;
;   XX12(3 2)           The dot product of [x y z] vector with the roofv (or _y)
;                       vector, with the sign in XX12+3 and magnitude in XX12+2
;
;   XX12(5 4)           The dot product of [x y z] vector with the nosev (or _z)
;                       vector, with the sign in XX12+5 and magnitude in XX12+4
;
; ******************************************************************************

.LL51

 SETUP_PPU_FOR_ICON_BAR ; If the PPU has started drawing the icon bar, configure
                        ; the PPU to use nametable 0 and pattern table 0

 LDX #0                 ; Set X = 0, which will contain the offset of the vector
                        ; to use in the calculation, increasing by 6 for each
                        ; new vector

 LDY #0                 ; Set Y = 0, which will contain the offset of the
                        ; result bytes in XX12, increasing by 2 for each new
                        ; result

.ll51

 LDA XX15               ; Set Q = x_lo
 STA Q

 LDA XX16,X             ; Set A = |sidev_x|

 JSR FMLTU              ; Set T = A * Q / 256
 STA T                  ;       = |sidev_x| * x_lo / 256

 LDA XX15+1             ; Set S to the sign of x_sign * sidev_x
 EOR XX16+1,X
 STA S

 LDA XX15+2             ; Set Q = y_lo
 STA Q

 LDA XX16+2,X           ; Set A = |sidev_y|

 JSR FMLTU              ; Set Q = A * Q / 256
 STA Q                  ;       = |sidev_y| * y_lo / 256

 LDA T                  ; Set R = T
 STA R                  ;       = |sidev_x| * x_lo / 256

 LDA XX15+3             ; Set A to the sign of y_sign * sidev_y
 EOR XX16+3,X

 JSR LL38               ; Set (S T) = (S R) + (A Q)
 STA T                  ;           = |sidev_x| * x_lo + |sidev_y| * y_lo

 LDA XX15+4             ; Set Q = z_lo
 STA Q

 LDA XX16+4,X           ; Set A = |sidev_z|

 JSR FMLTU              ; Set Q = A * Q / 256
 STA Q                  ;       = |sidev_z| * z_lo / 256

 LDA T                  ; Set R = T
 STA R                  ;       = |sidev_x| * x_lo + |sidev_y| * y_lo

 LDA XX15+5             ; Set A to the sign of z_sign * sidev_z
 EOR XX16+5,X

 JSR LL38               ; Set (S A) = (S R) + (A Q)
                        ;           = |sidev_x| * x_lo + |sidev_y| * y_lo
                        ;             + |sidev_z| * z_lo

 STA XX12,Y             ; Store the result in XX12+Y(1 0), starting with the low
                        ; byte

 SETUP_PPU_FOR_ICON_BAR ; If the PPU has started drawing the icon bar, configure
                        ; the PPU to use nametable 0 and pattern table 0

 LDA S                  ; And then the high byte
 STA XX12+1,Y

 INY                    ; Set Y = Y + 2
 INY

 TXA                    ; Set X = X + 6
 CLC
 ADC #6
 TAX

 CMP #17                ; If X < 17, loop back to ll51 for the next vector
 BCC ll51

 RTS                    ; Return from the subroutine

; ******************************************************************************
;
;       Name: LL9 (Part 1 of 12)
;       Type: Subroutine
;   Category: Drawing ships
;    Summary: Draw ship: Check if ship is exploding, check if ship is in front
;  Deep dive: Drawing ships
;
; ------------------------------------------------------------------------------
;
; This routine draws the current ship on the screen. This part checks to see if
; the ship is exploding, or if it should start exploding, and if it does it sets
; things up accordingly.
;
; In this code, XX1 is used to point to the current ship's data block at INWK
; (the two labels are interchangeable).
;
; Arguments:
;
;   XX1                 XX1 shares its location with INWK, which contains the
;                       zero-page copy of the data block for this ship from the
;                       K% workspace
;
;   INF                 The address of the data block for this ship in workspace
;                       K%
;
;   XX0                 The address of the blueprint for this ship
;
; Other entry points:
;
;   EE51                Remove the current ship from the screen, called from
;                       SHPPT before drawing the ship as a point
;
; ******************************************************************************

.LL25

 JMP PLANET             ; Jump to the PLANET routine, returning from the
                        ; subroutine using a tail call

.LL9

 SETUP_PPU_FOR_ICON_BAR ; If the PPU has started drawing the icon bar, configure
                        ; the PPU to use nametable 0 and pattern table 0

 LDA TYPE               ; If the ship type is negative then this indicates a
 BMI LL25               ; planet or sun, so jump to PLANET via LL25 above

 LDA #31                ; Set XX4 = 31 to store the ship's distance for later
 STA XX4                ; comparison with the visibility distance. We will
                        ; update this value below with the actual ship's
                        ; distance if it turns out to be visible on-screen

 LDA NEWB               ; If bit 7 of the ship's NEWB flags is set, then the
 BMI EE51               ; ship has been scooped or has docked, so jump down to
                        ; EE51 to skip drawing the ship so it doesn't appear
                        ; on-screen

 LDA #%00100000         ; If bit 5 of the ship's byte #31 is set, then the ship
 BIT XX1+31             ; is currently exploding, so jump down to EE28
 BNE EE28

 BPL EE28               ; If bit 7 of the ship's byte #31 is clear then the ship
                        ; has not just been killed, so jump down to EE28

                        ; Otherwise bit 5 is clear and bit 7 is set, so the ship
                        ; is not yet exploding but it has been killed, so we
                        ; need to start an explosion

 ORA XX1+31             ; Clear bits 6 and 7 of the ship's byte #31, to stop the
 AND #%00111111         ; ship from firing its laser and to mark it as no longer
 STA XX1+31             ; having just been killed

 LDA #0                 ; Set the ship's acceleration in byte #31 to 0, updating
 LDY #28                ; the byte in the workspace K% data block so we don't
 STA (INF),Y            ; have to copy it back from INWK later

 LDY #30                ; Set the ship's pitch counter in byte #30 to 0, to stop
 STA (INF),Y            ; the ship from pitching

 JSR HideShip           ; Update the ship so it is no longer shown on the
                        ; scanner

 LDA #18                ; Set the explosion cloud counter in INWK+34 to 18 so we
 STA INWK+34            ; can use it in DOEXP when drawing the explosion cloud

 LDY #37                ; Set byte #37 of the ship's data block to a random
 JSR DORND              ; number to use as a random number seed value for
 STA (INF),Y            ; generating the explosion cloud

 INY                    ; Set byte #38 of the ship's data block to a random
 JSR DORND              ; number to use as a random number seed value for
 STA (INF),Y            ; generating the explosion cloud

 INY                    ; Set byte #39 of the ship's data block to a random
 JSR DORND              ; number to use as a random number seed value for
 STA (INF),Y            ; generating the explosion cloud

 INY                    ; Set byte #40 of the ship's data block to a random
 JSR DORND              ; number to use as a random number seed value for
 STA (INF),Y            ; generating the explosion cloud

 SETUP_PPU_FOR_ICON_BAR ; If the PPU has started drawing the icon bar, configure
                        ; the PPU to use nametable 0 and pattern table 0

.EE28

 LDA XX1+8              ; Set A = z_sign

.EE49

 BPL LL10               ; If A is positive, i.e. the ship is in front of us,
                        ; jump down to LL10

.LL14

                        ; If we get here then we do not draw the ship on-screen,
                        ; for example when the ship is no longer on-screen, or
                        ; is too far away to be fully drawn, and so on

 LDA XX1+31             ; If bit 5 of the ship's byte #31 is clear, then the
 AND #%00100000         ; ship is not currently exploding, so jump down to EE51
 BEQ EE51               ; to skip drawing the ship

 LDA XX1+31             ; The ship is exploding, so clear bit 3 of the ship's
 AND #%11110111         ; byte #31 to denote that the ship is no longer being
 STA XX1+31             ; drawn on-screen

 JMP DOEXP              ; Jump to DOEXP to remove the explosion burst sprites
                        ; from the screen (if they are visible), returning from
                        ; the subroutine using a tail call

.EE51

 LDA XX1+31             ; Clear bits 3 and 6 in the ship's byte #31, which stops
 AND #%10110111         ; drawing the ship on-screen (bit 3), and denotes that
 STA XX1+31             ; the explosion has not been drawn and there are no
                        ; lasers firing (bit 6)

 RTS                    ; Return from the subroutine

; ******************************************************************************
;
;       Name: LL9 (Part 2 of 12)
;       Type: Subroutine
;   Category: Drawing ships
;    Summary: Draw ship: Check if ship is in field of view, close enough to draw
;  Deep dive: Drawing ships
;
; ------------------------------------------------------------------------------
;
; This part checks whether the ship is in our field of view, and whether it is
; close enough to be fully drawn (if not, we jump to SHPPT to draw it as a dot).
;
; Other entry points:
;
;   LL10-1              Contains an RTS
;
; ******************************************************************************

.LL10

 LDA XX1+7              ; Set A = z_hi

 CMP #192               ; If A >= 192 then the ship is a long way away, so jump
 BCS LL14               ; to LL14 to remove the ship from the screen

 LDA XX1                ; If x_lo >= z_lo, set the C flag, otherwise clear it
 CMP XX1+6

 LDA XX1+1              ; Set A = x_hi - z_hi using the carry from the low
 SBC XX1+7              ; bytes, which sets the C flag as if we had done a full
                        ; two-byte subtraction (x_hi x_lo) - (z_hi z_lo)

 BCS LL14               ; If the C flag is set then x >= z, so the ship is
                        ; further to the side than it is in front of us, so it's
                        ; outside our viewing angle of 45 degrees, and we jump
                        ; to LL14 to remove it from the screen

 LDA XX1+3              ; If y_lo >= z_lo, set the C flag, otherwise clear it
 CMP XX1+6

 LDA XX1+4              ; Set A = y_hi - z_hi using the carry from the low
 SBC XX1+7              ; bytes, which sets the C flag as if we had done a full
                        ; two-byte subtraction (y_hi y_lo) - (z_hi z_lo)

 BCS LL14               ; If the C flag is set then y >= z, so the ship is
                        ; further above us than it is in front of us, so it's
                        ; outside our viewing angle of 45 degrees, and we jump
                        ; to LL14 to remove it from the screen

 LDY #6                 ; Fetch byte #6 from the ship's blueprint into X, which
 LDA (XX0),Y            ; is the number * 4 of the vertex used for the ship's
 TAX                    ; laser

 LDA #255               ; Set bytes X and X+1 of the XX3 heap to 255. We're
 STA XX3,X              ; going to use XX3 to store the screen coordinates of
 STA XX3+1,X            ; all the visible vertices of this ship, so setting the
                        ; laser vertex to 255 means that if we don't update this
                        ; vertex with its screen coordinates in parts 6 and 7,
                        ; this vertex's entry in the XX3 heap will still be 255,
                        ; which we can check in part 9 to see if the laser
                        ; vertex is visible (and therefore whether we should
                        ; draw laser lines if the ship is firing on us)

 LDA XX1+6              ; Set (A T) = (z_hi z_lo)
 STA T
 LDA XX1+7

 LSR A                  ; Set (A T) = (A T) / 8
 ROR T
 LSR A
 ROR T
 LSR A
 ROR T

 LSR A                  ; If A >> 4 is non-zero, i.e. z_hi >= 16, jump to LL13
 BNE LL13               ; as the ship is possibly far away enough to be shown as
                        ; a dot

 LDA T                  ; Otherwise the C flag contains the previous bit 0 of A,
 ROR A                  ; which could have been set, so rotate A right four
 LSR A                  ; times so it's in the form %000xxxxx, i.e. z_hi reduced
 LSR A                  ; to a maximum value of 31
 LSR A

 STA XX4                ; Store A in XX4, which is now the distance of the ship
                        ; we can use for visibility testing

 BPL LL17               ; Jump down to LL17 (this BPL is effectively a JMP as we
                        ; know bit 7 of A is definitely clear)

.LL13

                        ; If we get here then the ship is possibly far enough
                        ; away to be shown as a dot

 LDY #13                ; Fetch byte #13 from the ship's blueprint, which gives
 LDA (XX0),Y            ; the ship's visibility distance, beyond which we show
                        ; the ship as a dot

 CMP XX1+7              ; If z_hi <= the visibility distance, skip to LL17 to
 BCS LL17               ; draw the ship fully, rather than as a dot, as it is
                        ; closer than the visibility distance

 LDA #%00100000         ; If bit 5 of the ship's byte #31 is set, then the
 AND XX1+31             ; ship is currently exploding, so skip to LL17 to draw
 BNE LL17               ; the ship's explosion cloud

 JMP SHPPT              ; Otherwise jump to SHPPT to draw the ship as a dot,
                        ; returning from the subroutine using a tail call

; ******************************************************************************
;
;       Name: LL9 (Part 3 of 12)
;       Type: Subroutine
;   Category: Drawing ships
;    Summary: Draw ship: Set up orientation vector, ship coordinate variables
;  Deep dive: Drawing ships
;
; ------------------------------------------------------------------------------
;
; This part sets up the following variable blocks:
;
;   * XX16 contains the orientation vectors, divided to normalise them
;
;   * XX18 contains the ship's x, y and z coordinates in space
;
; ******************************************************************************

.LL17

 LDX #5                 ; First we copy the three orientation vectors into XX16,
                        ; so set up a counter in X for the 6 bytes in each
                        ; vector

.LL15

 LDA XX1+21,X           ; Copy the X-th byte of sidev to the X-th byte of XX16
 STA XX16,X

 LDA XX1+15,X           ; Copy the X-th byte of roofv to XX16+6 to the X-th byte
 STA XX16+6,X           ; of XX16+6

 LDA XX1+9,X            ; Copy the X-th byte of nosev to XX16+12 to the X-th
 STA XX16+12,X          ; byte of XX16+12

 DEX                    ; Decrement the counter

 BPL LL15               ; Loop back to copy the next byte of each vector, until
                        ; we have the following:
                        ;
                        ;   * XX16(1 0) = sidev_x
                        ;   * XX16(3 2) = sidev_y
                        ;   * XX16(5 4) = sidev_z
                        ;
                        ;   * XX16(7 6) = roofv_x
                        ;   * XX16(9 8) = roofv_y
                        ;   * XX16(11 10) = roofv_z
                        ;
                        ;   * XX16(13 12) = nosev_x
                        ;   * XX16(15 14) = nosev_y
                        ;   * XX16(17 16) = nosev_z

 LDA #197               ; Set Q = 197
 STA Q

 LDY #16                ; Set Y to be a counter that counts down by 2 each time,
                        ; starting with 16, then 14, 12 and so on. We use this
                        ; to work through each of the coordinates in each of the
                        ; orientation vectors

.LL21

 SETUP_PPU_FOR_ICON_BAR ; If the PPU has started drawing the icon bar, configure
                        ; the PPU to use nametable 0 and pattern table 0

 LDA XX16,Y             ; Set A = the low byte of the vector coordinate, e.g.
                        ; nosev_z_lo when Y = 16

 ASL A                  ; Shift bit 7 into the C flag

 LDA XX16+1,Y           ; Set A = the high byte of the vector coordinate, e.g.
                        ; nosev_z_hi when Y = 16

 ROL A                  ; Rotate A left, incorporating the C flag, so A now
                        ; contains the original high byte, doubled, and without
                        ; a sign bit, e.g. A = |nosev_z_hi| * 2

 JSR LL28               ; Call LL28 to calculate:
                        ;
                        ;   R = 256 * A / Q
                        ;
                        ; so, for nosev, this would be:
                        ;
                        ;   R = 256 * |nosev_z_hi| * 2 / 197
                        ;     = 2.6 * |nosev_z_hi|

 LDX R                  ; Store R in the low byte's location, so we can keep the
 STX XX16,Y             ; old, unscaled high byte intact for the sign

 DEY                    ; Decrement the loop counter twice
 DEY

 BPL LL21               ; Loop back for the next vector coordinate until we have
                        ; divided them all

                        ; By this point, the vectors have been turned into
                        ; scaled magnitudes, so we have the following:
                        ;
                        ;   * XX16   = scaled |sidev_x|
                        ;   * XX16+2 = scaled |sidev_y|
                        ;   * XX16+4 = scaled |sidev_z|
                        ;
                        ;   * XX16+6  = scaled |roofv_x|
                        ;   * XX16+8  = scaled |roofv_y|
                        ;   * XX16+10 = scaled |roofv_z|
                        ;
                        ;   * XX16+12 = scaled |nosev_x|
                        ;   * XX16+14 = scaled |nosev_y|
                        ;   * XX16+16 = scaled |nosev_z|

 LDX #8                 ; Next we copy the ship's coordinates into XX18, so set
                        ; up a counter in X for 9 bytes

.ll91

 LDA XX1,X              ; Copy the X-th byte from XX1 to XX18
 STA XX18,X

 DEX                    ; Decrement the loop counter

 BPL ll91               ; Loop back for the next byte until we have copied all
                        ; three coordinates

                        ; So we now have the following:
                        ;
                        ;   * XX18(2 1 0) = (x_sign x_hi x_lo)
                        ;
                        ;   * XX18(5 4 3) = (y_sign y_hi y_lo)
                        ;
                        ;   * XX18(8 7 6) = (z_sign z_hi z_lo)

 LDA #255               ; Set the 15th byte of XX2 to 255, so that face 15 is
 STA XX2+15             ; always visible. No ship definitions actually have this
                        ; number of faces, but this allows us to force a vertex
                        ; to always be visible by associating it with face 15
                        ; (see the ship blueprints for the Cobra Mk III at
                        ; SHIP_COBRA_MK_3 and the asteroid at SHIP_ASTEROID for
                        ; examples of vertices that are associated with face 15)

 LDY #12                ; Set Y = 12 to point to the ship blueprint byte #12,

 LDA XX1+31             ; If bit 5 of the ship's byte #31 is clear, then the
 AND #%00100000         ; ship is not currently exploding, so jump down to EE29
 BEQ EE29               ; to skip the following

                        ; Otherwise we fall through to set up the visibility
                        ; block for an exploding ship

; ******************************************************************************
;
;       Name: LL9 (Part 4 of 12)
;       Type: Subroutine
;   Category: Drawing ships
;    Summary: Draw ship: Set visibility for exploding ship (all faces visible)
;  Deep dive: Drawing ships
;
; ------------------------------------------------------------------------------
;
; This part sets up the visibility block in XX2 for a ship that is exploding.
;
; The XX2 block consists of one byte for each face in the ship's blueprint,
; which holds the visibility of that face. Because the ship is exploding, we
; want to set all the faces to be visible. A value of 255 in the visibility
; table means the face is visible, so the following code sets each face to 255
; and then skips over the face visibility calculations that we would apply to a
; non-exploding ship.
;
; ******************************************************************************

 LDA (XX0),Y            ; Fetch byte #12 of the ship's blueprint, which contains
                        ; the number of faces * 4

 LSR A                  ; Set X = A / 4
 LSR A                  ;       = the number of faces
 TAX

 LDA #255               ; Set A = 255

.EE30

 STA XX2,X              ; Set the X-th byte of XX2 to 255

 DEX                    ; Decrement the loop counter

 BPL EE30               ; Loop back for the next byte until there is one byte
                        ; set to 255 for each face

 INX                    ; Set XX4 = 0 for the distance value we use to test
 STX XX4                ; for visibility, so we always shows everything

.LL41

 JMP LL42               ; Jump to LL42 to skip the face visibility calculations
                        ; as we don't need to do them now we've set up the XX2
                        ; block for the explosion

; ******************************************************************************
;
;       Name: LL9 (Part 5 of 12)
;       Type: Subroutine
;   Category: Drawing ships
;    Summary: Draw ship: Calculate the visibility of each of the ship's faces
;  Deep dive: Drawing ships
;             Back-face culling
;
; ******************************************************************************

.EE29

 LDA (XX0),Y            ; We set Y to 12 above before jumping down to EE29, so
                        ; this fetches byte #12 of the ship's blueprint, which
                        ; contains the number of faces * 4

 BEQ LL41               ; If there are no faces in this ship, jump to LL42 (via
                        ; LL41) to skip the face visibility calculations

 STA XX20               ; Set A = the number of faces * 4

 LDY #18                ; Fetch byte #18 of the ship's blueprint, which contains
 LDA (XX0),Y            ; the factor by which we scale the face normals, into X
 TAX

 LDA XX18+7             ; Set A = z_hi

.LL90

 TAY                    ; Set Y = z_hi

 BEQ LL91               ; If z_hi = 0 then jump to LL91

                        ; The following is a loop that jumps back to LL90+3,
                        ; i.e. here. LL90 is only used for this loop, so it's a
                        ; bit of a strange use of the label here

 INX                    ; Increment the scale factor in X

 LSR XX18+4             ; Divide (y_hi y_lo) by 2
 ROR XX18+3

 LSR XX18+1             ; Divide (x_hi x_lo) by 2
 ROR XX18

 LSR A                  ; Divide (z_hi z_lo) by 2 (as A contains z_hi)
 ROR XX18+6

 TAY                    ; Set Y = z_hi

 BNE LL90+3             ; If Y is non-zero, loop back to LL90+3 to divide the
                        ; three coordinates until z_hi is 0

.LL91

                        ; By this point z_hi is 0 and X contains the number of
                        ; right shifts we had to do, plus the scale factor from
                        ; the blueprint

 STX XX17               ; Store the updated scale factor in XX17

 LDA XX18+8             ; Set XX15+5 = z_sign
 STA XX15+5

 LDA XX18               ; Set XX15(1 0) = (x_sign x_lo)
 STA XX15
 LDA XX18+2
 STA XX15+1

 LDA XX18+3             ; Set XX15(3 2) = (y_sign y_lo)
 STA XX15+2
 LDA XX18+5
 STA XX15+3

 LDA XX18+6             ; Set XX15+4 = z_lo, so now XX15(5 4) = (z_sign z_lo)
 STA XX15+4

 JSR LL51               ; Call LL51 to set XX12 to the dot products of XX15 and
                        ; XX16, which we'll call dot_sidev, dot_roofv and
                        ; dot_nosev:
                        ;
                        ;   XX12(1 0) = [x y z] . sidev
                        ;             = (dot_sidev_sign dot_sidev_lo)
                        ;             = dot_sidev
                        ;
                        ;   XX12(3 2) = [x y z] . roofv
                        ;             = (dot_roofv_sign dot_roofv_lo)
                        ;             = dot_roofv
                        ;
                        ;   XX12(5 4) = [x y z] . nosev
                        ;             = (dot_nosev_sign dot_nosev_lo)
                        ;             = dot_nosev

 LDA XX12               ; Set XX18(2 0) = dot_sidev
 STA XX18
 LDA XX12+1
 STA XX18+2

 LDA XX12+2             ; Set XX18(5 3) = dot_roofv
 STA XX18+3
 LDA XX12+3
 STA XX18+5

 LDA XX12+4             ; Set XX18(8 6) = dot_nosev
 STA XX18+6
 LDA XX12+5
 STA XX18+8

 LDY #4                 ; Fetch byte #4 of the ship's blueprint, which contains
 LDA (XX0),Y            ; the low byte of the offset to the faces data

 CLC                    ; Set V = low byte faces offset + XX0
 ADC XX0
 STA V

 LDY #17                ; Fetch byte #17 of the ship's blueprint, which contains
 LDA (XX0),Y            ; the high byte of the offset to the faces data

 ADC XX0+1              ; Set V+1 = high byte faces offset + XX0+1
 STA V+1                ;
                        ; So V(1 0) now points to the start of the faces data
                        ; for this ship

 LDY #0                 ; We're now going to loop through all the faces for this
                        ; ship, so set a counter in Y, starting from 0, which we
                        ; will increment by 4 each loop to step through the
                        ; four bytes of data for each face

.LL86

 SETUP_PPU_FOR_ICON_BAR ; If the PPU has started drawing the icon bar, configure
                        ; the PPU to use nametable 0 and pattern table 0

 LDA (V),Y              ; Fetch byte #0 for this face into A, so:
                        ;
                        ;   A = %xyz vvvvv, where:
                        ;
                        ;     * Bits 0-4 = visibility distance, beyond which the
                        ;       face is always shown
                        ;
                        ;     * Bits 7-5 = the sign bits of normal_x, normal_y
                        ;       and normal_z

 STA XX12+1             ; Store byte #0 in XX12+1, so XX12+1 now has the sign of
                        ; normal_x

 AND #%00011111         ; Extract bits 0-4 to give the visibility distance

 CMP XX4                ; If XX4 <= the visibility distance, where XX4 contains
 BCS LL87               ; the ship's z-distance reduced to 0-31 (which we set in
                        ; part 2), skip to LL87 as this face is close enough
                        ; that we have to test its visibility using the face
                        ; normals

                        ; Otherwise this face is within range and is therefore
                        ; always shown

 TYA                    ; Set X = Y / 4
 LSR A                  ;       = the number of this face * 4 /4
 LSR A                  ;       = the number of this face
 TAX

 LDA #255               ; Set the X-th byte of XX2 to 255 to denote that this
 STA XX2,X              ; face is visible

 TYA                    ; Set Y = Y + 4 to point to the next face
 ADC #4
 TAY

 JMP LL88               ; Jump down to LL88 to skip the following, as we don't
                        ; need to test the face normals

.LL87

 LDA XX12+1             ; Fetch byte #0 for this face into A

 ASL A                  ; Shift A left and store it, so XX12+3 now has the sign
 STA XX12+3             ; of normal_y

 ASL A                  ; Shift A left and store it, so XX12+5 now has the sign
 STA XX12+5             ; of normal_z

 INY                    ; Increment Y to point to byte #1

 LDA (V),Y              ; Fetch byte #1 for this face and store in XX12, so
 STA XX12               ; XX12 = normal_x

 INY                    ; Increment Y to point to byte #2

 LDA (V),Y              ; Fetch byte #2 for this face and store in XX12+2, so
 STA XX12+2             ; XX12+2 = normal_y

 INY                    ; Increment Y to point to byte #3

 LDA (V),Y              ; Fetch byte #3 for this face and store in XX12+4, so
 STA XX12+4             ; XX12+4 = normal_z

                        ; So we now have:
                        ;
                        ;   XX12(1 0) = (normal_x_sign normal_x)
                        ;
                        ;   XX12(3 2) = (normal_y_sign normal_y)
                        ;
                        ;   XX12(5 4) = (normal_z_sign normal_z)

 LDX XX17               ; If XX17 < 4 then jump to LL92, otherwise we stored a
 CPX #4                 ; larger scale factor above
 BCC LL92

.LL143

 LDA XX18               ; Set XX15(1 0) = XX18(2 0)
 STA XX15               ;               = dot_sidev
 LDA XX18+2
 STA XX15+1

 LDA XX18+3             ; Set XX15(3 2) = XX18(5 3)
 STA XX15+2             ;               = dot_roofv
 LDA XX18+5
 STA XX15+3

 LDA XX18+6             ; Set XX15(5 4) = XX18(8 6)
 STA XX15+4             ;               = dot_nosev
 LDA XX18+8
 STA XX15+5

 JMP LL89               ; Jump down to LL89

.ovflw

                        ; If we get here then the addition below overflowed, so
                        ; we halve the dot products and normal vector

 SETUP_PPU_FOR_ICON_BAR ; If the PPU has started drawing the icon bar, configure
                        ; the PPU to use nametable 0 and pattern table 0

 LSR XX18               ; Divide dot_sidev_lo by 2, so dot_sidev = dot_sidev / 2

 LSR XX18+6             ; Divide dot_nosev_lo by 2, so dot_nosev = dot_nosev / 2

 LSR XX18+3             ; Divide dot_roofv_lo by 2, so dot_roofv = dot_roofv / 2

 LDX #1                 ; Set X = 1 so when we fall through into LL92, we divide
                        ; the normal vector by 2 as well

.LL92

                        ; We jump here from above with the scale factor in X,
                        ; and now we apply it by scaling the normal vector down
                        ; by a factor of 2^X (i.e. divide by 2^X)

 LDA XX12               ; Set XX15 = normal_x
 STA XX15

 LDA XX12+2             ; Set XX15+2 = normal_y
 STA XX15+2

 LDA XX12+4             ; Set A = normal_z

.LL93

 DEX                    ; Decrement the scale factor in X

 BMI LL94               ; If X was 0 before the decrement, there is no scaling
                        ; to do, so jump to LL94 to exit the loop

 LSR XX15               ; Set XX15 = XX15 / 2
                        ;          = normal_x / 2

 LSR XX15+2             ; Set XX15+2 = XX15+2 / 2
                        ;            = normal_y / 2

 LSR A                  ; Set A = A / 2
                        ;       = normal_z / 2

 DEX                    ; Decrement the scale factor in X

 BPL LL93+3             ; If we have more scaling to do, loop back up to the
                        ; first LSR above until the normal vector is scaled down

.LL94

 STA R                  ; Set R = normal_z

 LDA XX12+5             ; Set S = normal_z_sign
 STA S

 LDA XX18+6             ; Set Q = dot_nosev_lo
 STA Q

 LDA XX18+8             ; Set A = dot_nosev_sign

 JSR LL38               ; Set (S A) = (S R) + (A Q)
                        ;           = normal_z + dot_nosev
                        ;
                        ; setting the sign of the result in S

 BCS ovflw              ; If the addition overflowed, jump up to ovflw to divide
                        ; both the normal vector and dot products by 2 and try
                        ; again

 STA XX15+4             ; Set XX15(5 4) = (S A)
 LDA S                  ;               = normal_z + dot_nosev
 STA XX15+5

 LDA XX15               ; Set R = normal_x
 STA R

 LDA XX12+1             ; Set S = normal_x_sign
 STA S

 LDA XX18               ; Set Q = dot_sidev_lo
 STA Q

 LDA XX18+2             ; Set A = dot_sidev_sign

 JSR LL38               ; Set (S A) = (S R) + (A Q)
                        ;           = normal_x + dot_sidev
                        ;
                        ; setting the sign of the result in S

 BCS ovflw              ; If the addition overflowed, jump up to ovflw to divide
                        ; both the normal vector and dot products by 2 and try
                        ; again

 STA XX15               ; Set XX15(1 0) = (S A)
 LDA S                  ;               = normal_x + dot_sidev
 STA XX15+1

 LDA XX15+2             ; Set R = normal_y
 STA R

 LDA XX12+3             ; Set S = normal_y_sign
 STA S

 LDA XX18+3             ; Set Q = dot_roofv_lo
 STA Q

 LDA XX18+5             ; Set A = dot_roofv_sign

 JSR LL38               ; Set (S A) = (S R) + (A Q)
                        ;           = normal_y + dot_roofv

 BCS ovflw              ; If the addition overflowed, jump up to ovflw to divide
                        ; both the normal vector and dot products by 2 and try
                        ; again

 STA XX15+2             ; Set XX15(3 2) = (S A)
 LDA S                  ;               = normal_y + dot_roofv
 STA XX15+3

.LL89

                        ; When we get here, we have set up the following:
                        ;
                        ;   XX15(1 0) = normal_x + dot_sidev
                        ;             = normal_x + [x y z] . sidev
                        ;
                        ;   XX15(3 2) = normal_y + dot_roofv
                        ;             = normal_y + [x y z] . roofv
                        ;
                        ;   XX15(5 4) = normal_z + dot_nosev
                        ;             = normal_z + [x y z] . nosev
                        ;
                        ; and:
                        ;
                        ;   XX12(1 0) = (normal_x_sign normal_x)
                        ;
                        ;   XX12(3 2) = (normal_y_sign normal_y)
                        ;
                        ;   XX12(5 4) = (normal_z_sign normal_z)
                        ;
                        ; We now calculate the dot product XX12 . XX15 to tell
                        ; us whether or not this face is visible

 LDA XX12               ; Set Q = XX12
 STA Q

 SETUP_PPU_FOR_ICON_BAR ; If the PPU has started drawing the icon bar, configure
                        ; the PPU to use nametable 0 and pattern table 0

 LDA XX15               ; Set A = XX15

 JSR FMLTU              ; Set T = A * Q / 256
 STA T                  ;       = XX15 * XX12 / 256

 LDA XX12+1             ; Set S = sign of XX15(1 0) * XX12(1 0), so:
 EOR XX15+1             ;
 STA S                  ;   (S T) = XX15(1 0) * XX12(1 0) / 256

 LDA XX12+2             ; Set Q = XX12+2
 STA Q

 LDA XX15+2             ; Set A = XX15+2

 JSR FMLTU              ; Set Q = A * Q
 STA Q                  ;       = XX15+2 * XX12+2 / 256

 LDA T                  ; Set T = R, so now:
 STA R                  ;
                        ;   (S R) = XX15(1 0) * XX12(1 0) / 256

 LDA XX12+3             ; Set A = sign of XX15+3 * XX12+3, so:
 EOR XX15+3             ;
                        ;   (A Q) = XX15(3 2) * XX12(3 2) / 256

 JSR LL38               ; Set (S T) = (S R) + (A Q)
 STA T                  ;           =   XX15(1 0) * XX12(1 0) / 256
                        ;             + XX15(3 2) * XX12(3 2) / 256

 LDA XX12+4             ; Set Q = XX12+4
 STA Q

 LDA XX15+4             ; Set A = XX15+4

 JSR FMLTU              ; Set Q = A * Q
 STA Q                  ;       = XX15+4 * XX12+4 / 256

 LDA T                  ; Set T = R, so now:
 STA R                  ;
                        ;   (S R) =   XX15(1 0) * XX12(1 0) / 256
                        ;           + XX15(3 2) * XX12(3 2) / 256

 LDA XX15+5             ; Set A = sign of XX15+5 * XX12+5, so:
 EOR XX12+5             ;
                        ;   (A Q) = XX15(5 4) * XX12(5 4) / 256

 JSR LL38               ; Set (S A) = (S R) + (A Q)
                        ;           =   XX15(1 0) * XX12(1 0) / 256
                        ;             + XX15(3 2) * XX12(3 2) / 256
                        ;             + XX15(5 4) * XX12(5 4) / 256

 PHA                    ; Push the result A onto the stack, so the stack now
                        ; contains the dot product XX12 . XX15

 TYA                    ; Set X = Y / 4
 LSR A                  ;       = the number of this face * 4 /4
 LSR A                  ;       = the number of this face
 TAX

 PLA                    ; Pull the dot product off the stack into A

 BIT S                  ; If bit 7 of S is set, i.e. the dot product is
 BMI P%+4               ; negative, then this face is visible as its normal is
                        ; pointing towards us, so skip the following instruction

 LDA #0                 ; Otherwise the face is not visible, so set A = 0 so we
                        ; can store this to mean "not visible"

 STA XX2,X              ; Store the face's visibility in the X-th byte of XX2

 INY                    ; Above we incremented Y to point to byte #3, so this
                        ; increments Y to point to byte #4, i.e. byte #0 of the
                        ; next face

.LL88

 CPY XX20               ; If Y >= XX20, the number of faces * 4, jump down to
 BCS LL42               ; LL42 to move on to the

 JMP LL86               ; Otherwise loop back to LL86 to work out the visibility
                        ; of the next face

; ******************************************************************************
;
;       Name: LL9 (Part 6 of 12)
;       Type: Subroutine
;   Category: Drawing ships
;    Summary: Draw ship: Calculate the visibility of each of the ship's vertices
;  Deep dive: Drawing ships
;             Calculating vertex coordinates
;
; ------------------------------------------------------------------------------
;
; This section calculates the visibility of each of the ship's vertices, and for
; those that are visible, it starts the process of calculating the screen
; coordinates of each vertex
;
; ******************************************************************************

.LL42

                        ; The first task is to set up the inverse matrix, ready
                        ; for us to send to the dot product routine at LL51.
                        ; Back up in part 3, we set up the following variables:
                        ;
                        ;   * XX16(1 0) = sidev_x
                        ;   * XX16(3 2) = sidev_y
                        ;   * XX16(5 4) = sidev_z
                        ;
                        ;   * XX16(7 6) = roofv_x
                        ;   * XX16(9 8) = roofv_y
                        ;   * XX16(11 10) = roofv_z
                        ;
                        ;   * XX16(13 12) = nosev_x
                        ;   * XX16(15 14) = nosev_y
                        ;   * XX16(17 16) = nosev_z
                        ;
                        ; and we then scaled the vectors to give the following:
                        ;
                        ;   * XX16   = scaled |sidev_x|
                        ;   * XX16+2 = scaled |sidev_y|
                        ;   * XX16+4 = scaled |sidev_z|
                        ;
                        ;   * XX16+6  = scaled |roofv_x|
                        ;   * XX16+8  = scaled |roofv_y|
                        ;   * XX16+10 = scaled |roofv_z|
                        ;
                        ;   * XX16+12 = scaled |nosev_x|
                        ;   * XX16+14 = scaled |nosev_y|
                        ;   * XX16+16 = scaled |nosev_z|
                        ;
                        ; We now need to rearrange these locations so they
                        ; effectively transpose the matrix into its inverse

 LDY XX16+2             ; Set XX16+2 = XX16+6 = scaled |roofv_x|
 LDX XX16+3             ; Set XX16+3 = XX16+7 = roofv_x_hi
 LDA XX16+6             ; Set XX16+6 = XX16+2 = scaled |sidev_y|
 STA XX16+2             ; Set XX16+7 = XX16+3 = sidev_y_hi
 LDA XX16+7
 STA XX16+3
 STY XX16+6
 STX XX16+7

 LDY XX16+4             ; Set XX16+4 = XX16+12 = scaled |nosev_x|
 LDX XX16+5             ; Set XX16+5 = XX16+13 = nosev_x_hi
 LDA XX16+12            ; Set XX16+12 = XX16+4 = scaled |sidev_z|
 STA XX16+4             ; Set XX16+13 = XX16+5 = sidev_z_hi
 LDA XX16+13
 STA XX16+5
 STY XX16+12
 STX XX16+13

 LDY XX16+10            ; Set XX16+10 = XX16+14 = scaled |nosev_y|
 LDX XX16+11            ; Set XX16+11 = XX16+15 = nosev_y_hi
 LDA XX16+14            ; Set XX16+14 = XX16+10 = scaled |roofv_z|
 STA XX16+10            ; Set XX16+15 = XX16+11 = roofv_z
 LDA XX16+15
 STA XX16+11
 STY XX16+14
 STX XX16+15

                        ; So now we have the following sign-magnitude variables
                        ; containing parts of the scaled orientation vectors:
                        ;
                        ;   XX16(1 0)   = scaled sidev_x
                        ;   XX16(3 2)   = scaled roofv_x
                        ;   XX16(5 4)   = scaled nosev_x
                        ;
                        ;   XX16(7 6)   = scaled sidev_y
                        ;   XX16(9 8)   = scaled roofv_y
                        ;   XX16(11 10) = scaled nosev_y
                        ;
                        ;   XX16(13 12) = scaled sidev_z
                        ;   XX16(15 14) = scaled roofv_z
                        ;   XX16(17 16) = scaled nosev_z
                        ;
                        ; which is what we want, as the various vectors are now
                        ; arranged so we can use LL51 to multiply by the
                        ; transpose (i.e. the inverse of the matrix)

 LDY #8                 ; Fetch byte #8 of the ship's blueprint, which is the
 LDA (XX0),Y            ; number of vertices * 8, and store it in XX20
 STA XX20

                        ; We now set V(1 0) = XX0(1 0) + 20, so V(1 0) points
                        ; to byte #20 of the ship's blueprint, which is always
                        ; where the vertex data starts (i.e. just after the 20
                        ; byte block that define the ship's characteristics)

 LDA XX0                ; We start with the low bytes
 CLC
 ADC #20
 STA V

 LDA XX0+1              ; And then do the high bytes
 ADC #0
 STA V+1

 LDY #0                 ; We are about to step through all the vertices, using
                        ; Y as a counter. There are six data bytes for each
                        ; vertex, so we will increment Y by 6 for each iteration
                        ; so it can act as an offset from V(1 0) to the current
                        ; vertex's data

 STY CNT                ; Set CNT = 0, which we will use as a pointer to the
                        ; heap at XX3, starting it at zero so the heap starts
                        ; out empty

.LL48

 SETUP_PPU_FOR_ICON_BAR ; If the PPU has started drawing the icon bar, configure
                        ; the PPU to use nametable 0 and pattern table 0

 STY XX17               ; Set XX17 = Y, so XX17 now contains the offset of the
                        ; current vertex's data

 LDA (V),Y              ; Fetch byte #0 for this vertex into XX15, so:
 STA XX15               ;
                        ;   XX15 = magnitude of the vertex's x-coordinate

 INY                    ; Increment Y to point to byte #1

 LDA (V),Y              ; Fetch byte #1 for this vertex into XX15+2, so:
 STA XX15+2             ;
                        ;   XX15+2 = magnitude of the vertex's y-coordinate

 INY                    ; Increment Y to point to byte #2

 LDA (V),Y              ; Fetch byte #2 for this vertex into XX15+4, so:
 STA XX15+4             ;
                        ;   XX15+4 = magnitude of the vertex's z-coordinate

 INY                    ; Increment Y to point to byte #3

 LDA (V),Y              ; Fetch byte #3 for this vertex into T, so:
 STA T                  ;
                        ;   T = %xyz vvvvv, where:
                        ;
                        ;     * Bits 0-4 = visibility distance, beyond which the
                        ;                  vertex is not shown
                        ;
                        ;     * Bits 7-5 = the sign bits of x, y and z

 AND #%00011111         ; Extract bits 0-4 to get the visibility distance

 CMP XX4                ; If XX4 > the visibility distance, where XX4 contains
 BCC LL49-3             ; the ship's z-distance reduced to 0-31 (which we set in
                        ; part 2), then this vertex is too far away to be
                        ; visible, so jump down to LL50 (via the JMP instruction
                        ; in LL49-3) to move on to the next vertex

 INY                    ; Increment Y to point to byte #4

 LDA (V),Y              ; Fetch byte #4 for this vertex into P, so:
 STA P                  ;
                        ;  P = %ffff ffff, where:
                        ;
                        ;    * Bits 0-3 = the number of face 1
                        ;
                        ;    * Bits 4-7 = the number of face 2

 AND #%00001111         ; Extract the number of face 1 into X
 TAX

 LDA XX2,X              ; If XX2+X is non-zero then we decided in part 5 that
 BNE LL49               ; face 1 is visible, so jump to LL49

 LDA P                  ; Fetch byte #4 for this vertex into A

 LSR A                  ; Shift right four times to extract the number of face 2
 LSR A                  ; from bits 4-7 into X
 LSR A
 LSR A
 TAX

 LDA XX2,X              ; If XX2+X is non-zero then we decided in part 5 that
 BNE LL49               ; face 2 is visible, so jump to LL49

 INY                    ; Increment Y to point to byte #5

 LDA (V),Y              ; Fetch byte #5 for this vertex into P, so:
 STA P                  ;
                        ;  P = %ffff ffff, where:
                        ;
                        ;    * Bits 0-3 = the number of face 3
                        ;
                        ;    * Bits 4-7 = the number of face 4

 AND #%00001111         ; Extract the number of face 1 into X
 TAX

 LDA XX2,X              ; If XX2+X is non-zero then we decided in part 5 that
 BNE LL49               ; face 3 is visible, so jump to LL49

 LDA P                  ; Fetch byte #5 for this vertex into A

 LSR A                  ; Shift right four times to extract the number of face 4
 LSR A                  ; from bits 4-7 into X
 LSR A
 LSR A
 TAX

 LDA XX2,X              ; If XX2+X is non-zero then we decided in part 5 that
 BNE LL49               ; face 4 is visible, so jump to LL49

 JMP LL50               ; If we get here then none of the four faces associated
                        ; with this vertex are visible, so this vertex is also
                        ; not visible, so jump to LL50 to move on to the next
                        ; vertex

.LL49

 LDA T                  ; Fetch byte #5 for this vertex into A and store it, so
 STA XX15+1             ; XX15+1 now has the sign of the vertex's x-coordinate

 ASL A                  ; Shift A left and store it, so XX15+3 now has the sign
 STA XX15+3             ; of the vertex's y-coordinate

 ASL A                  ; Shift A left and store it, so XX15+5 now has the sign
 STA XX15+5             ; of the vertex's z-coordinate

                        ; By this point we have the following:
                        ;
                        ;   XX15(1 0) = vertex x-coordinate
                        ;   XX15(3 2) = vertex y-coordinate
                        ;   XX15(5 4) = vertex z-coordinate
                        ;
                        ;   XX16(1 0)   = scaled sidev_x
                        ;   XX16(3 2)   = scaled roofv_x
                        ;   XX16(5 4)   = scaled nosev_x
                        ;
                        ;   XX16(7 6)   = scaled sidev_y
                        ;   XX16(9 8)   = scaled roofv_y
                        ;   XX16(11 10) = scaled nosev_y
                        ;
                        ;   XX16(13 12) = scaled sidev_z
                        ;   XX16(15 14) = scaled roofv_z
                        ;   XX16(17 16) = scaled nosev_z

 JSR LL51               ; Call LL51 to set XX12 to the dot products of XX15 and
                        ; XX16, as follows:
                        ;
                        ;   XX12(1 0) = [ x y z ] . [ sidev_x roofv_x nosev_x ]
                        ;
                        ;   XX12(3 2) = [ x y z ] . [ sidev_y roofv_y nosev_y ]
                        ;
                        ;   XX12(5 4) = [ x y z ] . [ sidev_z roofv_z nosev_z ]
                        ;
                        ; XX12 contains the vector from the ship's centre to
                        ; the vertex, transformed from the orientation vector
                        ; space to the universe orientated around our ship. So
                        ; we can refer to this vector below, let's call it
                        ; vertv, so:
                        ;
                        ;   vertv_x = [ x y z ] . [ sidev_x roofv_x nosev_x ]
                        ;
                        ;   vertv_y = [ x y z ] . [ sidev_y roofv_y nosev_y ]
                        ;
                        ;   vertv_z = [ x y z ] . [ sidev_z roofv_z nosev_z ]
                        ;
                        ; To finish the calculation, we now want to calculate:
                        ;
                        ;   vertv + [ x y z ]
                        ;
                        ; So let's start with the vertv_x + x

 LDA XX1+2              ; Set A = x_sign of the ship's location

 STA XX15+2             ; Set XX15+2 = x_sign

 EOR XX12+1             ; If the sign of x_sign * the sign of vertv_x is
 BMI LL52               ; negative (i.e. they have different signs), skip to
                        ; LL52

 CLC                    ; Set XX15(2 1 0) = XX1(2 1 0) + XX12(1 0)
 LDA XX12               ;                 = (x_sign x_hi x_lo) + vertv_x
 ADC XX1                ;
 STA XX15               ; Starting with the low bytes

 LDA XX1+1              ; And then doing the high bytes (we can add 0 here as
 ADC #0                 ; we know the sign byte of vertv_x is 0)
 STA XX15+1

 JMP LL53               ; We've added the x-coordinates, so jump to LL53 to do
                        ; the y-coordinates

.LL52

                        ; If we get here then x_sign and vertv_x have different
                        ; signs, so we need to subtract them to get the result

 LDA XX1                ; Set XX15(2 1 0) = XX1(2 1 0) - XX12(1 0)
 SEC                    ;                 = (x_sign x_hi x_lo) - vertv_x
 SBC XX12               ;
 STA XX15               ; Starting with the low bytes

 LDA XX1+1              ; And then doing the high bytes (we can subtract 0 here
 SBC #0                 ; as we know the sign byte of vertv_x is 0)
 STA XX15+1

 BCS LL53               ; If the subtraction didn't underflow, then the sign of
                        ; the result is the same sign as x_sign, and that's what
                        ; we want, so we can jump down to LL53 to do the
                        ; y-coordinates

 EOR #%11111111         ; Otherwise we need to negate the result using two's
 STA XX15+1             ; complement, so first we flip the bits of the high byte

 LDA #1                 ; And then subtract the low byte from 1
 SBC XX15
 STA XX15

 BCC P%+4               ; If the above subtraction underflowed then we need to
 INC XX15+1             ; bump the high byte of the result up by 1

 LDA XX15+2             ; And now we flip the sign of the result to get the
 EOR #%10000000         ; correct result
 STA XX15+2

.LL53

                        ; Now for the y-coordinates, vertv_y + y

 LDA XX1+5              ; Set A = y_sign of the ship's location

 STA XX15+5             ; Set XX15+5 = y_sign

 EOR XX12+3             ; If the sign of y_sign * the sign of vertv_y is
 BMI LL54               ; negative (i.e. they have different signs), skip to
                        ; LL54

 CLC                    ; Set XX15(5 4 3) = XX1(5 4 3) + XX12(3 2)
 LDA XX12+2             ;                 = (y_sign y_hi y_lo) + vertv_y
 ADC XX1+3              ;
 STA XX15+3             ; Starting with the low bytes

 LDA XX1+4              ; And then doing the high bytes (we can add 0 here as
 ADC #0                 ; we know the sign byte of vertv_y is 0)
 STA XX15+4

 JMP LL55               ; We've added the y-coordinates, so jump to LL55 to do
                        ; the z-coordinates

.LL54

                        ; If we get here then y_sign and vertv_y have different
                        ; signs, so we need to subtract them to get the result

 LDA XX1+3              ; Set XX15(5 4 3) = XX1(5 4 3) - XX12(3 2)
 SEC                    ;                 = (y_sign y_hi y_lo) - vertv_y
 SBC XX12+2             ;
 STA XX15+3             ; Starting with the low bytes

 LDA XX1+4              ; And then doing the high bytes (we can subtract 0 here
 SBC #0                 ; as we know the sign byte of vertv_z is 0)
 STA XX15+4

 BCS LL55               ; If the subtraction didn't underflow, then the sign of
                        ; the result is the same sign as y_sign, and that's what
                        ; we want, so we can jump down to LL55 to do the
                        ; z-coordinates

 EOR #%11111111         ; Otherwise we need to negate the result using two's
 STA XX15+4             ; complement, so first we flip the bits of the high byte

 LDA XX15+3             ; And then flip the bits of the low byte and add 1
 EOR #%11111111
 ADC #1
 STA XX15+3

 LDA XX15+5             ; And now we flip the sign of the result to get the
 EOR #%10000000         ; correct result
 STA XX15+5

 BCC LL55               ; If the above subtraction underflowed then we need to
 INC XX15+4             ; bump the high byte of the result up by 1

.LL55

                        ; Now for the z-coordinates, vertv_z + z

 LDA XX12+5             ; If vertv_z_hi is negative, jump down to LL56
 BMI LL56

 LDA XX12+4             ; Set (U T) = XX1(7 6) + XX12(5 4)
 CLC                    ;           = (z_hi z_lo) + vertv_z
 ADC XX1+6              ;
 STA T                  ; Starting with the low bytes

 LDA XX1+7              ; And then doing the high bytes (we can add 0 here as
 ADC #0                 ; we know the sign byte of vertv_y is 0)
 STA U

 JMP LL57               ; We've added the z-coordinates, so jump to LL57

                        ; The adding process is continued in part 7, after a
                        ; couple of subroutines that we don't need quite yet

; ******************************************************************************
;
;       Name: LL61
;       Type: Subroutine
;   Category: Maths (Arithmetic)
;    Summary: Calculate (U R) = 256 * A / Q
;
; ------------------------------------------------------------------------------
;
; Calculate the following, where A >= Q:
;
;   (U R) = 256 * A / Q
;
; This is a sister routine to LL28, which does the division when A < Q.
;
; ******************************************************************************

.LL61

 LDX Q                  ; If Q = 0, jump down to LL84 to return a division
 BEQ LL84               ; error

                        ; The LL28 routine returns A / Q, but only if A < Q. In
                        ; our case A >= Q, but we still want to use the LL28
                        ; routine, so we halve A until it's less than Q, call
                        ; the division routine, and then double A by the same
                        ; number of times

 LDX #0                 ; Set X = 0 to count the number of times we halve A

.LL63

 LSR A                  ; Halve A by shifting right

 INX                    ; Increment X

 CMP Q                  ; If A >= Q, loop back to LL63 to halve it again
 BCS LL63

 STX S                  ; Otherwise store the number of times we halved A in S

 JSR LL28               ; Call LL28 to calculate:
                        ;
                        ;   R = 256 * A / Q
                        ;
                        ; which we can do now as A < Q

 LDX S                  ; Otherwise restore the number of times we halved A
                        ; above into X

 LDA R                  ; Set A = our division result

.LL64

 ASL A                  ; Double (U A) by shifting left
 ROL U

 BMI LL84               ; If bit 7 of U is set, the doubling has overflowed, so
                        ; jump to LL84 to return a division error

 DEX                    ; Decrement X

 BNE LL64               ; If X is not yet zero then we haven't done as many
                        ; doublings as we did halvings earlier, so loop back for
                        ; another doubling

 STA R                  ; Store the low byte of the division result in R

 RTS                    ; Return from the subroutine

.LL84

 LDA #50                ; If we get here then either we tried to divide by 0, or
 STA R                  ; the result overflowed, so we set U and R to 50
 STA U

 RTS                    ; Return from the subroutine

; ******************************************************************************
;
;       Name: LL62
;       Type: Subroutine
;   Category: Maths (Arithmetic)
;    Summary: Calculate 128 - (U R)
;
; ------------------------------------------------------------------------------
;
; Calculate the following for a positive sign-magnitude number (U R):
;
;   128 - (U R)
;
; and then store the result, low byte then high byte, on the end of the heap at
; XX3, where X points to the first free byte on the heap. Return by jumping down
; to LL66.
;
; Returns:
;
;   X                   X is incremented by 1
;
; ******************************************************************************

.LL62

 LDA #128               ; Calculate 128 - (U R), starting with the low bytes
 SEC
 SBC R

 STA XX3,X              ; Store the low byte of the result in the X-th byte of
                        ; the heap at XX3

 INX                    ; Increment the heap pointer in X to point to the next
                        ; byte

 LDA #0                 ; And then subtract the high bytes
 SBC U

 STA XX3,X              ; Store the low byte of the result in the X-th byte of
                        ; the heap at XX3

 JMP LL66               ; Jump down to LL66

; ******************************************************************************
;
;       Name: LL9 (Part 7 of 12)
;       Type: Subroutine
;   Category: Drawing ships
;    Summary: Draw ship: Calculate the visibility of each of the ship's vertices
;  Deep dive: Drawing ships
;             Calculating vertex coordinates
;
; ------------------------------------------------------------------------------
;
; This section continues the coordinate adding from part 6 by finishing off the
; calculation that we started above:
;
;                      [ sidev_x roofv_x nosev_x ]   [ x ]   [ x ]
;   vector to vertex = [ sidev_y roofv_y nosev_y ] . [ y ] + [ y ]
;                      [ sidev_z roofv_z nosev_z ]   [ z ]   [ z ]
;
; The gets stored as follows, in sign-magnitude values with the magnitudes
; fitting into the low bytes:
;
;   XX15(2 0)           [ x y z ] . [ sidev_x roofv_x nosev_x ] + [ x y z ]
;
;   XX15(5 3)           [ x y z ] . [ sidev_y roofv_y nosev_y ] + [ x y z ]
;
;   (U T)               [ x y z ] . [ sidev_z roofv_z nosev_z ] + [ x y z ]
;
; Finally, because this vector is from our ship to the vertex, and we are at the
; origin, this vector is the same as the coordinates of the vertex. In other
; words, we have just worked out:
;
;   XX15(2 0)           x-coordinate of the current vertex
;
;   XX15(5 3)           y-coordinate of the current vertex
;
;   (U T)               z-coordinate of the current vertex
;
; ******************************************************************************

.LL56

 LDA XX1+6              ; Set (U T) = XX1(7 6) - XX12(5 4)
 SEC                    ;           = (z_hi z_lo) - vertv_z
 SBC XX12+4             ;
 STA T                  ; Starting with the low bytes

 LDA XX1+7              ; And then doing the high bytes (we can subtract 0 here
 SBC #0                 ; as we know the sign byte of vertv_z is 0)
 STA U

 BCC LL140              ; If the subtraction just underflowed, skip to LL140 to
                        ; set (U T) to the minimum value of 4

 BNE LL57               ; If U is non-zero, jump down to LL57

 LDA T                  ; If T >= 4, jump down to LL57
 CMP #4
 BCS LL57

.LL140

 LDA #0                 ; If we get here then either (U T) < 4 or the
 STA U                  ; subtraction underflowed, so set (U T) = 4
 LDA #4
 STA T

.LL57

                        ; By this point we have our results, so now to scale
                        ; the 16-bit results down into 8-bit values

 LDA U                  ; If the high bytes of the result are all zero, we are
 ORA XX15+1             ; done, so jump down to LL60 for the next stage
 ORA XX15+4
 BEQ LL60

 LSR XX15+1             ; Shift XX15(1 0) to the right
 ROR XX15

 LSR XX15+4             ; Shift XX15(4 3) to the right
 ROR XX15+3

 LSR U                  ; Shift (U T) to the right
 ROR T

 JMP LL57               ; Jump back to LL57 to see if we can shift the result
                        ; any more

; ******************************************************************************
;
;       Name: LL9 (Part 8 of 12)
;       Type: Subroutine
;   Category: Drawing ships
;    Summary: Draw ship: Calculate the screen coordinates of visible vertices
;  Deep dive: Drawing ships
;
; ------------------------------------------------------------------------------
;
; This section projects the coordinate of the vertex into screen coordinates and
; stores them on the XX3 heap. By the end of this part, the XX3 heap contains
; four bytes containing the 16-bit screen coordinates of the current vertex, in
; the order: x_lo, x_hi, y_lo, y_hi.
;
; When we reach here, we are looping through the vertices, and we've just worked
; out the coordinates of the vertex in our normal coordinate system, as follows
;
;   XX15(2 0)           (x_sign x_lo) = x-coordinate of the current vertex
;
;   XX15(5 3)           (y_sign y_lo) = y-coordinate of the current vertex
;
;   (U T)               (z_sign z_lo) = z-coordinate of the current vertex
;
; Note that U is always zero when we get to this point, as the vertex is always
; in front of us (so it has a positive z-coordinate, into the screen).
;
; Other entry points:
;
;   LL70+1              Contains an RTS (as the first byte of an LDA
;                       instruction)
;
;   LL66                A re-entry point into the ship-drawing routine, used by
;                       the LL62 routine to store 128 - (U R) on the XX3 heap
;
; ******************************************************************************

.LL60

 LDA T                  ; Set Q = z_lo
 STA Q

 LDA XX15               ; Set A = x_lo

 CMP Q                  ; If x_lo < z_lo jump to LL69
 BCC LL69

 JSR LL61               ; Call LL61 to calculate:
                        ;
                        ;   (U R) = 256 * A / Q
                        ;         = 256 * x / z
                        ;
                        ; which we can do as x >= z

 JMP LL69+3             ; Jump over the next instruction to skip the division
                        ; for x_lo < z_lo

.LL69

 JSR LL28               ; Call LL28 to calculate:
                        ;
                        ;   R = 256 * A / Q
                        ;     = 256 * x / z
                        ;
                        ; Because x < z, the result fits into one byte, and we
                        ; also know that U = 0, so (U R) also contains the
                        ; result

                        ; At this point we have:
                        ;
                        ;   (U R) = x / z
                        ;
                        ; so (U R) contains the vertex's x-coordinate projected
                        ; on screen
                        ;
                        ; The next task is to convert (U R) to a pixel screen
                        ; coordinate and stick it on the XX3 heap.
                        ;
                        ; We start with the x-coordinate. To convert the
                        ; x-coordinate to a screen pixel we add 128, the
                        ; x-coordinate of the centre of the screen, because the
                        ; projected value is relative to an origin at the centre
                        ; of the screen, but the origin of the screen pixels is
                        ; at the top-left of the screen

 LDX CNT                ; Fetch the pointer to the end of the XX3 heap from CNT
                        ; into X

 SETUP_PPU_FOR_ICON_BAR ; If the PPU has started drawing the icon bar, configure
                        ; the PPU to use nametable 0 and pattern table 0

 LDA XX15+2             ; If x_sign is negative, jump up to LL62, which will
 BMI LL62               ; store 128 - (U R) on the XX3 heap and return by
                        ; jumping down to LL66 below

 LDA R                  ; Calculate 128 + (U R), starting with the low bytes
 CLC
 ADC #128

 STA XX3,X              ; Store the low byte of the result in the X-th byte of
                        ; the heap at XX3

 INX                    ; Increment the heap pointer in X to point to the next
                        ; byte

 LDA U                  ; And then add the high bytes
 ADC #0

 STA XX3,X              ; Store the high byte of the result in the X-th byte of
                        ; the heap at XX3

.LL66

                        ; We've just stored the screen x-coordinate of the
                        ; vertex on the XX3 heap, so now for the y-coordinate

 TXA                    ; Store the heap pointer in X on the stack (at this
 PHA                    ; it points to the last entry on the heap, not the first
                        ; free byte)

 LDA #0                 ; Set U = 0
 STA U

 LDA T                  ; Set Q = z_lo
 STA Q

 LDA XX15+3             ; Set A = y_lo

 CMP Q                  ; If y_lo < z_lo jump to LL67
 BCC LL67

 JSR LL61               ; Call LL61 to calculate:
                        ;
                        ;   (U R) = 256 * A / Q
                        ;         = 256 * y / z
                        ;
                        ; which we can do as y >= z

 JMP LL68               ; Jump to LL68 to skip the division for y_lo < z_lo

.LL70

                        ; This gets called from below when y_sign is negative

 LDA halfScreenHeight   ; Calculate halfScreenHeight + (U R), starting with the
 CLC                    ; low bytes
 ADC R

 STA XX3,X              ; Store the low byte of the result in the X-th byte of
                        ; the heap at XX3

 INX                    ; Increment the heap pointer in X to point to the next
                        ; byte

 LDA #0                 ; And then add the high bytes
 ADC U

 STA XX3,X              ; Store the high byte of the result in the X-th byte of
                        ; the heap at XX3

 JMP LL50               ; Jump to LL50 to move on to the next vertex

.LL67

 JSR LL28               ; Call LL28 to calculate:
                        ;
                        ;   R = 256 * A / Q
                        ;     = 256 * y / z
                        ;
                        ; Because y < z, the result fits into one byte, and we
                        ; also know that U = 0, so (U R) also contains the
                        ; result

.LL68

                        ; At this point we have:
                        ;
                        ;   (U R) = y / z
                        ;
                        ; so (U R) contains the vertex's y-coordinate projected
                        ; on screen
                        ;
                        ; We now want to convert this to a screen y-coordinate
                        ; and stick it on the XX3 heap, much like we did with
                        ; the x-coordinate above. Again, we convert the
                        ; coordinate by adding or subtracting the y-coordinate
                        ; of the centre of the screen, which is in the variable
                        ; halfScreenHeight, but this time we do the opposite, as
                        ; a positive projected y-coordinate, i.e. up the space
                        ; y-axis and up the screen, converts to a low
                        ; y-coordinate, which is the opposite way round to the
                        ; x-coordinates

 PLA                    ; Restore the heap pointer from the stack into X
 TAX

 INX                    ; When we stored the heap pointer, it pointed to the
                        ; last entry on the heap, not the first free byte, so we
                        ; increment it so it does point to the next free byte

 LDA XX15+5             ; If y_sign is negative, jump up to LL70, which will
 BMI LL70               ; store halfScreenHeight + (U R) on the XX3 heap and
                        ; return by jumping down to LL50 below

 LDA halfScreenHeight   ; Calculate halfScreenHeight - (U R), starting with the
 SEC                    ; low bytes
 SBC R

 STA XX3,X              ; Store the low byte of the result in the X-th byte of
                        ; the heap at XX3

 INX                    ; Increment the heap pointer in X to point to the next
                        ; byte

 LDA #0                 ; And then subtract the high bytes
 SBC U

 STA XX3,X              ; Store the high byte of the result in the X-th byte of
                        ; the heap at XX3

.LL50

                        ; By the time we get here, the XX3 heap contains four
                        ; bytes containing the screen coordinates of the current
                        ; vertex, in the order: x_lo, x_hi, y_lo, y_hi

 CLC                    ; Set CNT = CNT + 4, so the heap pointer points to the
 LDA CNT                ; next free byte on the heap
 ADC #4
 STA CNT

 LDA XX17               ; Set A to the offset of the current vertex's data,
                        ; which we set in part 6

 ADC #6                 ; Set Y = A + 6, so Y now points to the data for the
 TAY                    ; next vertex

 BCS LL72               ; If the addition just overflowed, meaning we just tried
                        ; to access vertex #43, jump to LL72, as the maximum
                        ; number of vertices allowed is 42

 CMP XX20               ; If Y >= number of vertices * 6 (which we stored in
 BCS LL72               ; XX20 in part 6), jump to LL72, as we have processed
                        ; all the vertices for this ship

 JMP LL48               ; Loop back to LL48 in part 6 to calculate visibility
                        ; and screen coordinates for the next vertex

; ******************************************************************************
;
;       Name: LL9 (Part 9 of 12)
;       Type: Subroutine
;   Category: Drawing ships
;    Summary: Draw ship: Draw laser beams if the ship is firing its laser at us
;  Deep dive: Drawing ships
;
; ------------------------------------------------------------------------------
;
; This part sets things up so we can loop through the edges in the next part. It
; also draws a laser line if the ship is firing at us.
;
; When we get here, the heap at XX3 contains all the visible vertex screen
; coordinates.
;
; ******************************************************************************

.LL72

 LDA XX1+31             ; If bit 5 of the ship's byte #31 is clear, then the
 AND #%00100000         ; ship is not currently exploding, so jump down to EE31
 BEQ EE31

 LDA XX1+31             ; The ship is exploding, so set bit 3 of the ship's byte
 ORA #%00001000         ; #31 to denote that we are drawing something on-screen
 STA XX1+31             ; for this ship

 JMP DOEXP              ; Jump to DOEXP to display the explosion cloud,
                        ; returning from the subroutine using a tail call

.EE31

 LDA #%00001000         ; If bit 3 of the ship's byte #31 is clear, then there
 BIT XX1+31             ; is nothing already being shown for this ship, so skip
 BEQ LL74               ; to LL74 as we don't need to erase anything from the
                        ; screen

 LDA #%00001000         ; Set bit 3 of A so the next instruction sets bit 3 of
                        ; the ship's byte #31 to denote that we are drawing
                        ; something on-screen for this ship

.LL74

 ORA XX1+31             ; Apply bit 3 of A to the ship's byte #31, so if there
 STA XX1+31             ; was no ship already on screen, the bit is clear,
                        ; otherwise it is set

 LDY #9                 ; Fetch byte #9 of the ship's blueprint, which is the
 LDA (XX0),Y            ; number of edges, and store it in XX20
 STA XX20

 LDY #0                 ; We are about to step through all the edges, using Y
                        ; as a counter

 STY U                  ; Set U = 0 (though we increment it to 1 below)

 STY XX17               ; Set XX17 = 0, which we are going to use as a counter
                        ; for stepping through the ship's edges

 INC U                  ; We are going to start calculating the lines we need to
                        ; draw for this ship, and will store them in the ship
                        ; line heap, using U to point to the end of the heap, so
                        ; we start by setting U = 1

 BIT XX1+31             ; If bit 6 of the ship's byte #31 is clear, then the
 BVC LL170              ; ship is not firing its lasers, so jump to LL170 to
                        ; skip the drawing of laser lines

                        ; The ship is firing its laser at us, so we need to draw
                        ; the laser lines

 LDA XX1+31             ; Clear bit 6 of the ship's byte #31 so the ship doesn't
 AND #%10111111         ; keep firing endlessly
 STA XX1+31

 LDY #6                 ; Fetch byte #6 of the ship's blueprint, which is the
 LDA (XX0),Y            ; number * 4 of the vertex where the ship has its lasers

 TAY                    ; Put the vertex number into Y, where it can act as an
                        ; index into list of vertex screen coordinates we added
                        ; to the XX3 heap

 LDX XX3,Y              ; Fetch the x_lo coordinate of the laser vertex from the
 STX XX15               ; XX3 heap into XX15

 INX                    ; If X = 255 then the laser vertex is not visible, as
 BEQ LL170              ; the value we stored in part 2 wasn't overwritten by
                        ; the vertex calculation in part 6 and 7, so jump to
                        ; LL170 to skip drawing the laser lines

                        ; We now build a laser beam from the ship's laser vertex
                        ; towards our ship, as follows:
                        ;
                        ;   XX15(1 0) = laser vertex x-coordinate
                        ;
                        ;   XX15(3 2) = laser vertex y-coordinate
                        ;
                        ;   XX15(5 4) = x-coordinate of the end of the beam
                        ;
                        ;   XX12(1 0) = y-coordinate of the end of the beam
                        ;
                        ; The end of the laser beam will be set positioned to
                        ; look good, rather than being directly aimed at us, as
                        ; otherwise we would only see a flashing point of light
                        ; as they unleashed their attack

 LDX XX3+1,Y            ; Fetch the x_hi coordinate of the laser vertex from the
 STX XX15+1             ; XX3 heap into XX15+1

 INX                    ; If X = 255 then the laser vertex is not visible, as
 BEQ LL170              ; the value we stored in part 2 wasn't overwritten by
                        ; a vertex calculation in part 6 and 7, so jump to LL170
                        ; to skip drawing the laser beam

 LDX XX3+2,Y            ; Fetch the y_lo coordinate of the laser vertex from the
 STX XX15+2             ; XX3 heap into XX15+2

 LDX XX3+3,Y            ; Fetch the y_hi coordinate of the laser vertex from the
 STX XX15+3             ; XX3 heap into XX15+3

 LDA #0                 ; Set XX15(5 4) = 0, so their laser beam fires to the
 STA XX15+4             ; left edge of the screen
 STA XX15+5

 STA XX12+1             ; Set XX12(1 0) = the ship's z_lo coordinate, which will
 LDA XX1+6              ; effectively make the vertical position of the end of
 STA XX12               ; the laser beam move around as the ship moves in space

 LDA XX1+2              ; If the ship's x_sign is positive, skip the next
 BPL P%+4               ; instruction

 DEC XX15+4             ; The ship's x_sign is negative (i.e. it's on the left
                        ; side of the screen), so switch the laser beam so it
                        ; goes to the right edge of the screen by decrementing
                        ; XX15(5 4) to 255

 JSR CLIP               ; Call CLIP to see if the laser beam needs to be
                        ; clipped to fit on-screen, returning the clipped line's
                        ; end-points in (X1, Y1) and (X2, Y2)

 BCS LL170              ; If the C flag is set then the line is not visible on
                        ; screen, so jump to LL170 so we don't draw this line

 LDY U                  ; This instruction is left over from the other versions
                        ; of Elite and has no effect
                        ;
                        ; It would fetch the ship line heap pointer from U, but
                        ; the NES version does not have a ship line heap as the
                        ; screen is redrawn for every frame

 JSR LOIN               ; Draw the laser line

; ******************************************************************************
;
;       Name: LL9 (Part 10 of 12)
;       Type: Subroutine
;   Category: Drawing ships
;    Summary: Draw ship: Calculate the visibility of each of the ship's edges
;  Deep dive: Drawing ships
;
; ------------------------------------------------------------------------------
;
; This part calculates which edges are visible - in other words, which lines we
; should draw - and clips them to fit on the screen.
;
; When we get here, the heap at XX3 contains all the visible vertex screen
; coordinates.
;
; ******************************************************************************

.LL170

 LDY #3                 ; Fetch byte #3 of the ship's blueprint, which contains
 CLC                    ; the low byte of the offset to the edges data
 LDA (XX0),Y

 ADC XX0                ; Set V = low byte edges offset + XX0
 STA V

 LDY #16                ; Fetch byte #16 of the ship's blueprint, which contains
 LDA (XX0),Y            ; the high byte of the offset to the edges data

 ADC XX0+1              ; Set V+1 = high byte edges offset + XX0+1
 STA V+1                ;
                        ; So V(1 0) now points to the start of the edges data
                        ; for this ship

 LDY #5                 ; Fetch byte #5 of the ship's blueprint, which contains
 LDA (XX0),Y            ; the maximum heap size for plotting the ship (which is
 STA T1                 ; 1 + 4 * the maximum number of visible edges) and store
                        ; it in T1

 LDY XX17               ; Set Y to the edge counter in XX17

.LL75

 SETUP_PPU_FOR_ICON_BAR ; If the PPU has started drawing the icon bar, configure
                        ; the PPU to use nametable 0 and pattern table 0

 LDA (V),Y              ; Fetch byte #0 for this edge, which contains the
                        ; visibility distance for this edge, beyond which the
                        ; edge is not shown

 CMP XX4                ; If XX4 > the visibility distance, where XX4 contains
 BCC LL79-3             ; the ship's z-distance reduced to 0-31 (which we set in
                        ; part 2), then this edge is too far away to be visible,
                        ; so jump down to LL78 (via LL79-3) to move on to the
                        ; next edge

 INY                    ; Increment Y to point to byte #1

 LDA (V),Y              ; Fetch byte #1 for this edge into A, so:
                        ;
                        ;   A = %ffff ffff, where:
                        ;
                        ;     * Bits 0-3 = the number of face 1
                        ;
                        ;     * Bits 4-7 = the number of face 2

 INY                    ; Increment Y to point to byte #2

 STA P                  ; Store byte #1 into P

 AND #%00001111         ; Extract the number of face 1 into X
 TAX

 LDA XX2,X              ; If XX2+X is non-zero then we decided in part 5 that
 BNE LL79               ; face 1 is visible, so jump to LL79

 LDA P                  ; Fetch byte #1 for this edge into A

 LSR A                  ; Shift right four times to extract the number of face 2
 LSR A                  ; from bits 4-7 into X
 LSR A
 LSR A
 TAX

 LDA XX2,X              ; If XX2+X is non-zero then we decided in part 5 that
 BNE LL79               ; face 2 is visible, so skip the following instruction

 JMP LL78               ; Face 2 is hidden, so jump to LL78

.LL79

                        ; We now build the screen line for this edge, as
                        ; follows:
                        ;
                        ;   XX15(1 0) = start x-coordinate
                        ;
                        ;   XX15(3 2) = start y-coordinate
                        ;
                        ;   XX15(5 4) = end x-coordinate
                        ;
                        ;   XX12(1 0) = end y-coordinate
                        ;
                        ; We can then pass this to the line clipping routine
                        ; before storing the resulting line in the ship line
                        ; heap

 LDA (V),Y              ; Fetch byte #2 for this edge into X, which contains
 TAX                    ; the number of the vertex at the start of the edge

 INY                    ; Increment Y to point to byte #3

 LDA (V),Y              ; Fetch byte #3 for this edge into Q, which contains
 STA Q                  ; the number of the vertex at the end of the edge

 LDA XX3+1,X            ; Fetch the x_hi coordinate of the edge's start vertex
 STA XX15+1             ; from the XX3 heap into XX15+1

 LDA XX3,X              ; Fetch the x_lo coordinate of the edge's start vertex
 STA XX15               ; from the XX3 heap into XX15

 LDA XX3+2,X            ; Fetch the y_lo coordinate of the edge's start vertex
 STA XX15+2             ; from the XX3 heap into XX15+2

 LDA XX3+3,X            ; Fetch the y_hi coordinate of the edge's start vertex
 STA XX15+3             ; from the XX3 heap into XX15+3

 LDX Q                  ; Set X to the number of the vertex at the end of the
                        ; edge, which we stored in Q

 LDA XX3,X              ; Fetch the x_lo coordinate of the edge's end vertex
 STA XX15+4             ; from the XX3 heap into XX15+4

 LDA XX3+3,X            ; Fetch the y_hi coordinate of the edge's end vertex
 STA XX12+1             ; from the XX3 heap into XX11+1

 LDA XX3+2,X            ; Fetch the y_lo coordinate of the edge's end vertex
 STA XX12               ; from the XX3 heap into XX12

 LDA XX3+1,X            ; Fetch the x_hi coordinate of the edge's end vertex
 STA XX15+5             ; from the XX3 heap into XX15+5

 JSR CLIP2              ; Call CLIP2 to see if the new line segment needs to be
                        ; clipped to fit on-screen, returning the clipped line's
                        ; end-points in (X1, Y1) and (X2, Y2)

 BCS LL79-3             ; If the C flag is set then the line is not visible on
                        ; screen, so jump to LL78 (via LL79-3) so we don't draw
                        ; this line

 JSR LOIN               ; Draw this edge

 JMP LL78               ; Jump down to part 11 to skip to the next edge

; ******************************************************************************
;
;       Name: LL145 (Part 1 of 4)
;       Type: Subroutine
;   Category: Drawing lines
;    Summary: Clip line: Work out which end-points are on-screen, if any
;  Deep dive: Line-clipping
;             Extended screen coordinates
;
; ------------------------------------------------------------------------------
;
; This routine clips the line from (x1, y1) to (x2, y2) so it fits on-screen, or
; returns an error if it can't be clipped to fit. The arguments are 16-bit
; coordinates, and the clipped line is returned using 8-bit screen coordinates.
;
; This part sets XX13 to reflect which of the two points are on-screen and
; off-screen.
;
; Arguments:
;
;   XX15(1 0)           x1 as a 16-bit coordinate (x1_hi x1_lo)
;
;   XX15(3 2)           y1 as a 16-bit coordinate (y1_hi y1_lo)
;
;   XX15(5 4)           x2 as a 16-bit coordinate (x2_hi x2_lo)
;
;   XX12(1 0)           y2 as a 16-bit coordinate (y2_hi y2_lo)
;
; Returns:
;
;   (X1, Y1)            Screen coordinate of the start of the clipped line
;
;   (X2, Y2)            Screen coordinate of the end of the clipped line
;
;   C flag              Clear if the clipped line fits on-screen, set if it
;                       doesn't
;
;   XX13                The state of the original coordinates on-screen:
;
;                         * 0   = (x2, y2) on-screen
;
;                         * 127 = (x1, y1) on-screen,  (x2, y2) off-screen
;
;                         * 255 = (x1, y1) off-screen, (x2, y2) off-screen
;
;                       So XX13 is non-zero if the end of the line was clipped,
;                       meaning the next line sent to BLINE can't join onto the
;                       end but has to start a new segment
;
;   SWAP                The swap status of the returned coordinates:
;
;                         * $FF if we swapped the values of (x1, y1) and
;                           (x2, y2) as part of the clipping process
;
;                         * 0 if the coordinates are still in the same order
;
;   Y                   Y is preserved
;
; Other entry points:
;
;   CLIP                Another name for LL145
;
;   CLIP2               Don't initialise the values in SWAP or A
;
; ******************************************************************************

.LL145

.CLIP

 LDA #0                 ; Set SWAP = 0
 STA SWAP

 LDA XX15+5             ; Set A = x2_hi

.CLIP2

 LDX #255               ; Set X = 255, the highest y-coordinate possible, beyond
                        ; the bottom of the screen

 ORA XX12+1             ; If one or both of x2_hi and y2_hi are non-zero, jump
 BNE LL107              ; to LL107 to skip the following, leaving X at 255

 LDA Yx2M1              ; If y2_lo > the y-coordinate of the bottom of screen
 CMP XX12               ; (which is in the variable Yx2M1), then (x2, y2) is off
 BCC LL107              ; the bottom of the screen, so skip the following
                        ; instruction, leaving X at 255

 LDX #0                 ; Set X = 0

.LL107

 STX XX13               ; Set XX13 = X, so we have:
                        ;
                        ;   * XX13 = 0 if x2_hi = y2_hi = 0, y2_lo is on-screen
                        ;
                        ;   * XX13 = 255 if x2_hi or y2_hi are non-zero or y2_lo
                        ;            is off the bottom of the screen
                        ;
                        ; In other words, XX13 is 255 if (x2, y2) is off-screen,
                        ; otherwise it is 0

 LDA XX15+1             ; If one or both of x1_hi and y1_hi are non-zero, jump
 ORA XX15+3             ; to LL83
 BNE LL83

 LDA Yx2M1              ; If y1_lo > the y-coordinate of the bottom of screen
 CMP XX15+2             ; (which is in the variable Yx2M1),  then (x1, y1) is
 BCC LL83               ; off the bottom of the screen, so jump to LL83

                        ; If we get here, (x1, y1) is on-screen

 LDA XX13               ; If XX13 is non-zero, i.e. (x2, y2) is off-screen, jump
 BNE LL108              ; to LL108 to halve it before continuing at LL83

                        ; If we get here, the high bytes are all zero, which
                        ; means the x-coordinates are < 256 and therefore fit on
                        ; screen, and neither coordinate is off the bottom of
                        ; the screen. That means both coordinates are already on
                        ; screen, so we don't need to do any clipping, all we
                        ; need to do is move the low bytes into (X1, Y1) and
                        ; X2, Y2) and return

.LL146

                        ; If we get here then we have clipped our line to the
                        ; (if we had to clip it at all), so we move the low
                        ; bytes from (x1, y1) and (x2, y2) into (X1, Y1) and
                        ; (X2, Y2), remembering that they share locations with
                        ; XX15:
                        ;
                        ;   X1 = XX15
                        ;   Y1 = XX15+1
                        ;   X2 = XX15+2
                        ;   Y2 = XX15+3
                        ;
                        ; X1 already contains x1_lo, so now we do the rest

 LDA XX15+2             ; Set Y1 (aka XX15+1) = y1_lo
 STA XX15+1

 LDA XX15+4             ; Set X2 (aka XX15+2) = x2_lo
 STA XX15+2

 LDA XX12               ; Set Y2 (aka XX15+3) = y2_lo
 STA XX15+3

 CLC                    ; Clear the C flag as the clipped line fits on-screen

 RTS                    ; Return from the subroutine

.LL109

 SEC                    ; Set the C flag to indicate the clipped line does not
                        ; fit on-screen

 RTS                    ; Return from the subroutine

.LL108

 LSR XX13               ; If we get here then (x2, y2) is off-screen and XX13 is
                        ; 255, so shift XX13 right to halve it to 127

; ******************************************************************************
;
;       Name: LL145 (Part 2 of 4)
;       Type: Subroutine
;   Category: Drawing lines
;    Summary: Clip line: Work out if any part of the line is on-screen
;  Deep dive: Line-clipping
;             Extended screen coordinates
;
; ------------------------------------------------------------------------------
;
; This part does a number of tests to see if the line is on or off the screen.
;
; If we get here then at least one of (x1, y1) and (x2, y2) is off-screen, with
; XX13 set as follows:
;
;   * 0   = (x1, y1) off-screen, (x2, y2) on-screen
;
;   * 127 = (x1, y1) on-screen,  (x2, y2) off-screen
;
;   * 255 = (x1, y1) off-screen, (x2, y2) off-screen
;
; where "off-screen" is defined as having a non-zero high byte in one of the
; coordinates, or in the case of y-coordinates, having a low byte > Yx2M1, the
; y-coordinate of the bottom of the space view.
;
; ******************************************************************************

.LL83

 LDA XX13               ; If XX13 < 128 then only one of the points is on-screen
 BPL LL115              ; so jump down to LL115 to skip the checks of whether
                        ; both points are in the strips to the right or bottom
                        ; of the screen

                        ; If we get here, both points are off-screen

 LDA XX15+1             ; If both x1_hi and x2_hi have bit 7 set, jump to LL109
 AND XX15+5             ; to return from the subroutine with the C flag set, as
 BMI LL109              ; the entire line is above the top of the screen

 LDA XX15+3             ; If both y1_hi and y2_hi have bit 7 set, jump to LL109
 AND XX12+1             ; to return from the subroutine with the C flag set, as
 BMI LL109              ; the entire line is to the left of the screen

 LDX XX15+1             ; Set A = X = x1_hi - 1
 DEX
 TXA

 LDX XX15+5             ; Set XX12+2 = x2_hi - 1
 DEX
 STX XX12+2

 ORA XX12+2             ; If neither (x1_hi - 1) or (x2_hi - 1) have bit 7 set,
 BPL LL109              ; jump to LL109 to return from the subroutine with the C
                        ; flag set, as the line doesn't fit on-screen

 LDA XX15+2             ; If y1_lo < y-coordinate of screen bottom (which is in
 CMP screenHeight       ; the variable screenHeight), clear the C flag,
                        ; otherwise set it

 LDA XX15+3             ; Set XX12+2 = y1_hi - (1 - C), so:
 SBC #0                 ;
 STA XX12+2             ;  * Set XX12+2 = y1_hi - 1 if y1_lo is on-screen
                        ;  * Set XX12+2 = y1_hi     otherwise
                        ;
                        ; We do this subtraction because we are only interested
                        ; in trying to move the points up by a screen if that
                        ; might move the point into the space view portion of
                        ; the screen, i.e. if y1_lo is on-screen

 LDA XX12               ; If y2_lo < y-coordinate of screen bottom (which is in
 CMP screenHeight       ; the variable screenHeight), clear the C flag,
                        ; otherwise set it

 LDA XX12+1             ; Set XX12+2 = y2_hi - (1 - C), so:
 SBC #0                 ;
                        ;  * Set XX12+1 = y2_hi - 1 if y2_lo is on-screen
                        ;  * Set XX12+1 = y2_hi     otherwise
                        ;
                        ; We do this subtraction because we are only interested
                        ; in trying to move the points up by a screen if that
                        ; might move the point into the space view portion of
                        ; the screen, i.e. if y1_lo is on-screen

 ORA XX12+2             ; If neither XX12+1 or XX12+2 have bit 7 set, jump to
 BPL LL109              ; LL109 to return from the subroutine with the C flag
                        ; set, as the line doesn't fit on-screen

; ******************************************************************************
;
;       Name: LL145 (Part 3 of 4)
;       Type: Subroutine
;   Category: Drawing lines
;    Summary: Clip line: Calculate the line's gradient
;  Deep dive: Line-clipping
;             Extended screen coordinates
;
; ******************************************************************************

.LL115

 TYA                    ; Store Y on the stack so we can preserve it through the
 PHA                    ; call to this subroutine

 LDA XX15+4             ; Set XX12+2 = x2_lo - x1_lo
 SEC
 SBC XX15
 STA XX12+2

 LDA XX15+5             ; Set XX12+3 = x2_hi - x1_hi
 SBC XX15+1
 STA XX12+3

 LDA XX12               ; Set XX12+4 = y2_lo - y1_lo
 SEC
 SBC XX15+2
 STA XX12+4

 LDA XX12+1             ; Set XX12+5 = y2_hi - y1_hi
 SBC XX15+3
 STA XX12+5

                        ; So we now have:
                        ;
                        ;   delta_x in XX12(3 2)
                        ;   delta_y in XX12(5 4)
                        ;
                        ; where the delta is (x1, y1) - (x2, y2))

 EOR XX12+3             ; Set S = the sign of delta_x * the sign of delta_y, so
 STA S                  ; if bit 7 of S is set, the deltas have different signs

 LDA XX12+5             ; If delta_y_hi is positive, jump down to LL110 to skip
 BPL LL110              ; the following

 LDA #0                 ; Otherwise flip the sign of delta_y to make it
 SEC                    ; positive, starting with the low bytes
 SBC XX12+4
 STA XX12+4

 LDA #0                 ; And then doing the high bytes, so now:
 SBC XX12+5             ;
 STA XX12+5             ;   XX12(5 4) = |delta_y|

.LL110

 LDA XX12+3             ; If delta_x_hi is positive, jump down to LL111 to skip
 BPL LL111              ; the following

 SEC                    ; Otherwise flip the sign of delta_x to make it
 LDA #0                 ; positive, starting with the low bytes
 SBC XX12+2
 STA XX12+2

 LDA #0                 ; And then doing the high bytes, so now:
 SBC XX12+3             ;
                        ;   (A XX12+2) = |delta_x|

.LL111

                        ; We now keep halving |delta_x| and |delta_y| until
                        ; both of them have zero in their high bytes

 TAX                    ; If |delta_x_hi| is non-zero, skip the following
 BNE LL112

 LDX XX12+5             ; If |delta_y_hi| = 0, jump down to LL113 (as both
 BEQ LL113              ; |delta_x_hi| and |delta_y_hi| are 0)

.LL112

 LSR A                  ; Halve the value of delta_x in (A XX12+2)
 ROR XX12+2

 LSR XX12+5             ; Halve the value of delta_y XX12(5 4)
 ROR XX12+4

 JMP LL111              ; Loop back to LL111

.LL113

                        ; By now, the high bytes of both |delta_x| and |delta_y|
                        ; are zero

 STX T                  ; We know that X = 0 as that's what we tested with a BEQ
                        ; above, so this sets T = 0

 LDA XX12+2             ; If delta_x_lo < delta_y_lo, so our line is more
 CMP XX12+4             ; vertical than horizontal, jump to LL114
 BCC LL114

                        ; If we get here then our line is more horizontal than
                        ; vertical, so it is a shallow slope

 STA Q                  ; Set Q = delta_x_lo

 LDA XX12+4             ; Set A = delta_y_lo

 JSR LL28               ; Call LL28 to calculate:
                        ;
                        ;   R = 256 * A / Q
                        ;     = 256 * delta_y_lo / delta_x_lo

 JMP LL116              ; Jump to LL116, as we now have the line's gradient in R

.LL114

                        ; If we get here then our line is more vertical than
                        ; horizontal, so it is a steep slope

 LDA XX12+4             ; Set Q = delta_y_lo
 STA Q
 LDA XX12+2             ; Set A = delta_x_lo

 JSR LL28               ; Call LL28 to calculate:
                        ;
                        ;   R = 256 * A / Q
                        ;     = 256 * delta_x_lo / delta_y_lo

 DEC T                  ; T was set to 0 above, so this sets T = $FF when our
                        ; line is steep

; ******************************************************************************
;
;       Name: LL145 (Part 4 of 4)
;       Type: Subroutine
;   Category: Drawing lines
;    Summary: Clip line: Call the routine in LL188 to do the actual clipping
;  Deep dive: Line-clipping
;             Extended screen coordinates
;
; ------------------------------------------------------------------------------
;
; This part sets things up to call the routine in LL188, which does the actual
; clipping.
;
; If we get here, then R has been set to the gradient of the line (x1, y1) to
; (x2, y2), with T indicating the gradient of slope:
;
;   * 0   = shallow slope (more horizontal than vertical)
;
;   * $FF = steep slope (more vertical than horizontal)
;
; and XX13 has been set as follows:
;
;   * 0   = (x1, y1) off-screen, (x2, y2) on-screen
;
;   * 127 = (x1, y1) on-screen,  (x2, y2) off-screen
;
;   * 255 = (x1, y1) off-screen, (x2, y2) off-screen
;
; ******************************************************************************

.LL116

 STA XX12+2             ; Store the gradient in XX12+2 (as the call to LL28 in
                        ; part 3 returns the gradient in both A and R)

 SETUP_PPU_FOR_ICON_BAR ; If the PPU has started drawing the icon bar, configure
                        ; the PPU to use nametable 0 and pattern table 0

 LDA S                  ; Store the type of slope in XX12+3, bit 7 clear means
 STA XX12+3             ; top left to bottom right, bit 7 set means top right to
                        ; bottom left

 LDA XX13               ; If XX13 = 0, skip the following instruction
 BEQ LL138

 BPL LLX117             ; If XX13 is positive, it must be 127. This means
                        ; (x1, y1) is on-screen but (x2, y2) isn't, so we jump
                        ; to LLX117 to swap the (x1, y1) and (x2, y2)
                        ; coordinates around before doing the actual clipping,
                        ; because we need to clip (x2, y2) but the clipping
                        ; routine at LL118 only clips (x1, y1)

.LL138

                        ; If we get here, XX13 = 0 or 255, so (x1, y1) is
                        ; off-screen and needs clipping

 JSR LL118              ; Call LL118 to move (x1, y1) along the line onto the
                        ; screen, i.e. clip the line at the (x1, y1) end

 LDA XX13               ; If XX13 = 255, i.e. (x2, y2) is off-screen, jump down
 BMI LL117              ; down to LL117 to skip the following

 PLA                    ; Restore Y from the stack so it gets preserved through
 TAY                    ; the call to this subroutine

 JMP LL146              ; Jump up to LL146 to move the low bytes of (x1, y1) and
                        ; (x2, y2) into (X1, Y1) and (X2, Y2), and return from
                        ; the subroutine with a successfully clipped line

.LL117

                        ; If we get here, XX13 = 255 (both coordinates are
                        ; off-screen)

 LDA XX15+1             ; If either of x1_hi or y1_hi are non-zero, jump to
 ORA XX15+3             ; LL137 to return from the subroutine with the C flag
 BNE LL137              ; set, as the line doesn't fit on-screen

 LDA XX15+2             ; If y1_lo > y-coordinate of the bottom of the screen
 CMP screenHeight       ; (which is in the variable screenHeight), jump to LL137
 BCS LL137              ; to return from the subroutine with the C flag set, as
                        ; the line doesn't fit on-screen

.LLX117

                        ; If we get here, XX13 = 127 or 255, and in both cases
                        ; (x2, y2) is off-screen, so we now need to swap the
                        ; (x1, y1) and (x2, y2) coordinates around before doing
                        ; the actual clipping, because we need to clip (x2, y2)
                        ; but the clipping routine at LL118 only clips (x1, y1)

 LDX XX15               ; Swap x1_lo = x2_lo
 LDA XX15+4
 STA XX15
 STX XX15+4

 LDA XX15+5             ; Swap x2_lo = x1_lo
 LDX XX15+1
 STX XX15+5
 STA XX15+1

 LDX XX15+2             ; Swap y1_lo = y2_lo
 LDA XX12
 STA XX15+2
 STX XX12

 LDA XX12+1             ; Swap y2_lo = y1_lo
 LDX XX15+3
 STX XX12+1
 STA XX15+3

 JSR LL118              ; Call LL118 to move (x1, y1) along the line onto the
                        ; screen, i.e. clip the line at the (x1, y1) end

 LDA XX15+1             ; If either of x1_hi or y1_hi are non-zero, jump to
 ORA XX15+3             ; LL137 to return from the subroutine with the C flag
 BNE LL137              ; set, as the line doesn't fit on-screen

 DEC SWAP               ; Set SWAP = $FF to indicate that we just clipped the
                        ; line at the (x2, y2) end by swapping the coordinates
                        ; (the DEC does this as we set SWAP to 0 at the start of
                        ; this subroutine)

.LL124

 PLA                    ; Restore Y from the stack so it gets preserved through
 TAY                    ; the call to this subroutine

                        ; If we get here then we have clipped our line to the
                        ; (if we had to clip it at all), so we move the low
                        ; bytes from (x1, y1) and (x2, y2) into (X1, Y1) and
                        ; (X2, Y2), remembering that they share locations with
                        ; XX15:
                        ;
                        ;   X1 = XX15
                        ;   Y1 = XX15+1
                        ;   X2 = XX15+2
                        ;   Y2 = XX15+3
                        ;
                        ; X1 already contains x1_lo, so now we do the rest

 LDA XX15+2             ; Set A = y1_lo

 CMP screenHeight       ; If A >= screenHeight then jump down to clip2 to clip
 BCS clip2              ; the coordinate to the screen before jumping back to
                        ; clip1

.clip1

 STA XX15+1             ; Set Y1 (aka XX15+1) = y1_lo

 LDA XX15+4             ; Set X2 (aka XX15+2) = x2_lo
 STA XX15+2

 LDA XX12               ; Set Y2 (aka XX15+3) = y2_lo
 STA XX15+3

 CLC                    ; Clear the C flag as the clipped line fits on-screen

 RTS                    ; Return from the subroutine

.clip2

 LDA Yx2M1              ; Set A = Yx2M1, which contains the height in pixels of
                        ; the space view

 BNE clip1              ; Jump to clip1 to continue setting the clipped line's
                        ; coordinates (this BNE is effectively a JMP as A is
                        ; never zero)

.LL137

 PLA                    ; Restore Y from the stack so it gets preserved through
 TAY                    ; the call to this subroutine

 SEC                    ; Set the C flag to indicate the clipped line does not
                        ; fit on-screen

 RTS                    ; Return from the subroutine

; ******************************************************************************
;
;       Name: LL9 (Part 11 of 12)
;       Type: Subroutine
;   Category: Drawing ships
;    Summary: Draw ship: Loop back for the next edge
;  Deep dive: Drawing ships
;
; ******************************************************************************

.LL78

 INC XX17               ; Increment the edge counter to point to the next edge

 LDY XX17               ; If Y >= XX20, which contains the number of edges in
 CPY XX20               ; the blueprint, jump to LL81 as we have processed all
 BCS LL81               ; the edges and don't need to loop back for the next one

 LDY #0                 ; Set Y to point to byte #0 again, ready for the next
                        ; edge

 LDA V                  ; Increment V by 4 so V(1 0) points to the data for the
 ADC #4                 ; next edge
 STA V

 BCC ll81               ; If the above addition didn't overflow, jump to ll81 to
                        ; skip the following instruction

 INC V+1                ; Otherwise increment the high byte of V(1 0), as we
                        ; just moved the V(1 0) pointer past a page boundary

.ll81

 JMP LL75               ; Loop back to LL75 to process the next edge

.LL81

 LDA U                  ; This instruction is left over from the other versions
                        ; of Elite and has no effect
                        ;
                        ; It would fetch the ship line heap pointer from U, but
                        ; the NES version does not have a ship line heap as the
                        ; screen is redrawn for every frame

; ******************************************************************************
;
;       Name: LL9 (Part 12 of 12)
;       Type: Subroutine
;   Category: Drawing ships
;    Summary: Does nothing in the NES version
;  Deep dive: Drawing ships
;
; ------------------------------------------------------------------------------
;
; The NES version does not have a ship line heap as the screen is redrawn for
; every frame, so this part of LL9 does nothing (in the other versions it draws
; all the visible edges from the ship line heap).
;
; ******************************************************************************

 RTS                    ; Return from the subroutine

; ******************************************************************************
;
;       Name: LL118
;       Type: Subroutine
;   Category: Drawing lines
;    Summary: Move a point along a line until it is on-screen
;  Deep dive: Line-clipping
;
; ------------------------------------------------------------------------------
;
; Given a point (x1, y1), a gradient and a direction of slope, move the point
; along the line until it is on-screen, so this effectively clips the (x1, y1)
; end of a line to be on the screen.
;
; See the deep dive on "Line-clipping" for more details.
;
; Arguments:
;
;   XX15(1 0)           x1 as a 16-bit coordinate (x1_hi x1_lo)
;
;   XX15(3 2)           y1 as a 16-bit coordinate (y1_hi y1_lo)
;
;   XX12+2              The line's gradient * 256 (so 1.0 = 256)
;
;   XX12+3              The direction of slope:
;
;                         * Positive (bit 7 clear) = top left to bottom right
;
;                         * Negative (bit 7 set) = top right to bottom left
;
;   T                   The gradient of slope:
;
;                         * 0 if it's a shallow slope
;
;                         * $FF if it's a steep slope
;
; Returns:
;
;   XX15                x1 as an 8-bit coordinate
;
;   XX15+2              y1 as an 8-bit coordinate
;
; Other entry points:
;
;   LL118-1             Contains an RTS
;
; ******************************************************************************

.LL118

 SETUP_PPU_FOR_ICON_BAR ; If the PPU has started drawing the icon bar, configure
                        ; the PPU to use nametable 0 and pattern table 0

 LDA XX15+1             ; Set S = x1_hi
 STA S

 BPL LL119              ; If x1_hi is positive, jump down to LL119 to skip the
                        ; following

 JSR LL120              ; Call LL120 to calculate:
                        ;
                        ;   (Y X) = (S x1_lo) * XX12+2      if T = 0
                        ;         = x1 * gradient
                        ;
                        ;   (Y X) = (S x1_lo) / XX12+2      if T <> 0
                        ;         = x1 / gradient
                        ;
                        ; with the sign of (Y X) set to the opposite of the
                        ; line's direction of slope

 TXA                    ; Set y1 = y1 + (Y X)
 CLC                    ;
 ADC XX15+2             ; starting with the low bytes
 STA XX15+2

 TYA                    ; And then adding the high bytes
 ADC XX15+3
 STA XX15+3

 LDA #0                 ; Set x1 = 0
 STA XX15
 STA XX15+1

 TAX                    ; Set X = 0 so the next instruction becomes a JMP

 BEQ LL134S             ; If x1_hi = 0 then jump down to LL134S to skip the
                        ; following, as the x-coordinate is already on-screen
                        ; (as 0 <= (x_hi x_lo) <= 255)

.LL119

 BEQ LL134              ; If x1_hi = 0 then jump down to LL134 to skip the
                        ; following, as the x-coordinate is already on-screen
                        ; (as 0 <= (x_hi x_lo) <= 255)

 DEC S                  ; Otherwise x1_hi is positive, i.e. x1 >= 256 and off
                        ; the right side of the screen, so set:
                        ;
                        ;   S = S - 1
                        ;     = x1_hi - 1

 JSR LL120              ; Call LL120 to calculate:
                        ;
                        ;   (Y X) = (S x1_lo) * XX12+2      if T = 0
                        ;         = (x1 - 256) * gradient
                        ;
                        ;   (Y X) = (S x1_lo) / XX12+2      if T <> 0
                        ;         = (x1 - 256) / gradient
                        ;
                        ; with the sign of (Y X) set to the opposite of the
                        ; line's direction of slope

 TXA                    ; Set y1 = y1 + (Y X)
 CLC                    ;
 ADC XX15+2             ; starting with the low bytes
 STA XX15+2

 TYA                    ; And then adding the high bytes
 ADC XX15+3
 STA XX15+3

 LDX #255               ; Set x1 = 255
 STX XX15
 INX
 STX XX15+1

.LL134S

 SETUP_PPU_FOR_ICON_BAR ; If the PPU has started drawing the icon bar, configure
                        ; the PPU to use nametable 0 and pattern table 0

.LL134

                        ; We have moved the point so the x-coordinate is on
                        ; screen (i.e. in the range 0-255), so now for the
                        ; y-coordinate

 LDA XX15+3             ; If y1_hi is positive, jump down to LL119 to skip
 BPL LL135              ; the following

 STA S                  ; Otherwise y1_hi is negative, i.e. off the top of the
                        ; screen, so set S = y1_hi

 LDA XX15+2             ; Set R = y1_lo
 STA R

 JSR LL123              ; Call LL123 to calculate:
                        ;
                        ;   (Y X) = (S R) / XX12+2      if T = 0
                        ;         = y1 / gradient
                        ;
                        ;   (Y X) = (S R) * XX12+2      if T <> 0
                        ;         = y1 * gradient
                        ;
                        ; with the sign of (Y X) set to the opposite of the
                        ; line's direction of slope

 TXA                    ; Set x1 = x1 + (Y X)
 CLC                    ;
 ADC XX15               ; starting with the low bytes
 STA XX15

 TYA                    ; And then adding the high bytes
 ADC XX15+1
 STA XX15+1

 LDA #0                 ; Set y1 = 0
 STA XX15+2
 STA XX15+3

.LL135

 LDA XX15+2             ; Set (S R) = (y1_hi y1_lo) - screen height
 SEC                    ;
 SBC screenHeight       ; starting with the low bytes
 STA R

 LDA XX15+3             ; And then subtracting the high bytes
 SBC #0
 STA S

 BCC LL136              ; If the subtraction underflowed, i.e. if y1 < screen
                        ; height, then y1 is already on-screen, so jump to LL136
                        ; to return from the subroutine, as we are done

.LL139

                        ; If we get here then y1 >= screen height, i.e. off the
                        ; bottom of the screen

 JSR LL123              ; Call LL123 to calculate:
                        ;
                        ;   (Y X) = (S R) / XX12+2      if T = 0
                        ;         = (y1 - screen height) / gradient
                        ;
                        ;   (Y X) = (S R) * XX12+2      if T <> 0
                        ;         = (y1 - screen height) * gradient
                        ;
                        ; with the sign of (Y X) set to the opposite of the
                        ; line's direction of slope

 TXA                    ; Set x1 = x1 + (Y X)
 CLC                    ;
 ADC XX15               ; starting with the low bytes
 STA XX15

 TYA                    ; And then adding the high bytes
 ADC XX15+1
 STA XX15+1

 LDA Yx2M1              ; Set y1 = 2 * Yx2M1. The variable Yx2M1 is the
 STA XX15+2             ; y-coordinate of the mid-point of the space view, so
 LDA #0                 ; this sets Y2 to y-coordinate of the bottom pixel
 STA XX15+3             ; row of the space view

.LL136

 SETUP_PPU_FOR_ICON_BAR ; If the PPU has started drawing the icon bar, configure
                        ; the PPU to use nametable 0 and pattern table 0

 RTS                    ; Return from the subroutine

; ******************************************************************************
;
;       Name: LL120
;       Type: Subroutine
;   Category: Maths (Arithmetic)
;    Summary: Calculate (Y X) = (S x1_lo) * XX12+2 or (S x1_lo) / XX12+2
;
; ------------------------------------------------------------------------------
;
; Calculate the following:
;
;   * If T = 0, this is a shallow slope, so calculate (Y X) = (S x1_lo) * XX12+2
;
;   * If T <> 0, this is a steep slope, so calculate (Y X) = (S x1_lo) / XX12+2
;
; giving (Y X) the opposite sign to the slope direction in XX12+3.
;
; Arguments:
;
;   T                   The gradient of slope:
;
;                         * 0 if it's a shallow slope
;
;                         * $FF if it's a steep slope
;
; Other entry points:
;
;   LL122               Calculate (Y X) = (S R) * Q and set the sign to the
;                       opposite of the top byte on the stack
;
; ******************************************************************************

.LL120

 LDA XX15               ; Set R = x1_lo
 STA R

 JSR LL129              ; Call LL129 to do the following:
                        ;
                        ;   Q = XX12+2
                        ;     = line gradient
                        ;
                        ;   A = S EOR XX12+3
                        ;     = S EOR slope direction
                        ;
                        ;   (S R) = |S R|
                        ;
                        ; So A contains the sign of S * slope direction

 PHA                    ; Store A on the stack so we can use it later

 LDX T                  ; If T is non-zero, then it's a steep slope, so jump
 BNE LL121              ; down to LL121 to calculate this instead:
                        ;
                        ;   (Y X) = (S R) / Q

.LL122

                        ; The following calculates:
                        ;
                        ;   (Y X) = (S R) * Q
                        ;
                        ; using the same shift-and-add algorithm that's
                        ; documented in MULT1

 LDA #0                 ; Set A = 0

 TAX                    ; Set (Y X) = 0 so we can start building the answer here
 TAY

 LSR S                  ; Shift (S R) to the right, so we extract bit 0 of (S R)
 ROR R                  ; into the C flag

 ASL Q                  ; Shift Q to the left, catching bit 7 in the C flag

 BCC LL126              ; If C (i.e. the next bit from Q) is clear, do not do
                        ; the addition for this bit of Q, and instead skip to
                        ; LL126 to just do the shifts

.LL125

 TXA                    ; Set (Y X) = (Y X) + (S R)
 CLC                    ;
 ADC R                  ; starting with the low bytes
 TAX

 TYA                    ; And then doing the high bytes
 ADC S
 TAY

.LL126

 LSR S                  ; Shift (S R) to the right
 ROR R

 ASL Q                  ; Shift Q to the left, catching bit 7 in the C flag

 BCS LL125              ; If C (i.e. the next bit from Q) is set, loop back to
                        ; LL125 to do the addition for this bit of Q

 BNE LL126              ; If Q has not yet run out of set bits, loop back to
                        ; LL126 to do the "shift" part of shift-and-add until
                        ; we have done additions for all the set bits in Q, to
                        ; give us our multiplication result

 PLA                    ; Restore A, which we calculated above, from the stack

 BPL LL133              ; If A is positive jump to LL133 to negate (Y X) and
                        ; return from the subroutine using a tail call

 RTS                    ; Return from the subroutine

; ******************************************************************************
;
;       Name: LL123
;       Type: Subroutine
;   Category: Maths (Arithmetic)
;    Summary: Calculate (Y X) = (S R) / XX12+2 or (S R) * XX12+2
;
; ------------------------------------------------------------------------------
;
; Calculate the following:
;
;   * If T = 0, this is a shallow slope, so calculate (Y X) = (S R) / XX12+2
;
;   * If T <> 0, this is a steep slope, so calculate (Y X) = (S R) * XX12+2
;
; giving (Y X) the opposite sign to the slope direction in XX12+3.
;
; Arguments:
;
;   XX12+2              The line's gradient * 256 (so 1.0 = 256)
;
;   XX12+3              The direction of slope:
;
;                         * Bit 7 clear means top left to bottom right
;
;                         * Bit 7 set means top right to bottom left
;
;   T                   The gradient of slope:
;
;                         * 0 if it's a shallow slope
;
;                         * $FF if it's a steep slope
;
; Other entry points:
;
;   LL121               Calculate (Y X) = (S R) / Q and set the sign to the
;                       opposite of the top byte on the stack
;
;   LL133               Negate (Y X) and return from the subroutine
;
;   LL128               Contains an RTS
;
; ******************************************************************************

.LL123

 JSR LL129              ; Call LL129 to do the following:
                        ;
                        ;   Q = XX12+2
                        ;     = line gradient
                        ;
                        ;   A = S EOR XX12+3
                        ;     = S EOR slope direction
                        ;
                        ;   (S R) = |S R|
                        ;
                        ; So A contains the sign of S * slope direction

 PHA                    ; Store A on the stack so we can use it later

 LDX T                  ; If T is non-zero, then it's a steep slope, so jump up
 BNE LL122              ; to LL122 to calculate this instead:
                        ;
                        ;   (Y X) = (S R) * Q

.LL121

                        ; The following calculates:
                        ;
                        ;   (Y X) = (S R) / Q
                        ;
                        ; using the same shift-and-subtract algorithm that's
                        ; documented in TIS2

 LDA #%11111111         ; Set Y = %11111111
 TAY

 ASL A                  ; Set X = %11111110
 TAX

                        ; This sets (Y X) = %1111111111111110, so we can rotate
                        ; through 15 loop iterations, getting a 1 each time, and
                        ; then getting a 0 on the 16th iteration... and we can
                        ; also use it to catch our result bits into bit 0 each
                        ; time

.LL130

 ASL R                  ; Shift (S R) to the left
 ROL S

 LDA S                  ; Set A = S

 BCS LL131              ; If bit 7 of S was set, then jump straight to the
                        ; subtraction

 CMP Q                  ; If A < Q (i.e. S < Q), skip the following subtractions
 BCC LL132

.LL131

 SBC Q                  ; A >= Q (i.e. S >= Q) so set:
 STA S                  ;
                        ;   S = (A R) - Q
                        ;     = (S R) - Q
                        ;
                        ; starting with the low bytes (we know the C flag is
                        ; set so the subtraction will be correct)

 LDA R                  ; And then doing the high bytes
 SBC #0
 STA R

 SEC                    ; Set the C flag to rotate into the result in (Y X)

.LL132

 TXA                    ; Rotate the counter in (Y X) to the left, and catch the
 ROL A                  ; result bit into bit 0 (which will be a 0 if we didn't
 TAX                    ; do the subtraction, or 1 if we did)
 TYA
 ROL A
 TAY

 BCS LL130              ; If we still have set bits in (Y X), loop back to LL130
                        ; to do the next iteration of 15, until we have done the
                        ; whole division

 PLA                    ; Restore A, which we calculated above, from the stack

 BMI LL128              ; If A is negative jump to LL128 to return from the
                        ; subroutine with (Y X) as is

.LL133

 TXA                    ; Otherwise negate (Y X) using two's complement by first
 EOR #%11111111         ; setting the low byte to ~X + 1
 ADC #1                 ;
 TAX                    ; The addition works as we know the C flag is clear from
                        ; when we passed through the BCS above

 TYA                    ; Then set the high byte to ~Y + C
 EOR #%11111111
 ADC #0
 TAY

.LL128

 RTS                    ; Return from the subroutine

; ******************************************************************************
;
;       Name: LL129
;       Type: Subroutine
;   Category: Maths (Arithmetic)
;    Summary: Calculate Q = XX12+2, A = S EOR XX12+3 and (S R) = |S R|
;
; ------------------------------------------------------------------------------
;
; Do the following, in this order:
;
;   Q = XX12+2
;
;   A = S EOR XX12+3
;
;   (S R) = |S R|
;
; This sets up the variables required above to calculate (S R) / XX12+2 and give
; the result the opposite sign to XX13+3.
;
; ******************************************************************************

.LL129

 LDX XX12+2             ; Set Q = XX12+2
 STX Q

 LDA S                  ; If S is positive, jump to LL127
 BPL LL127

 LDA #0                 ; Otherwise set R = -R
 SEC
 SBC R
 STA R

 LDA S                  ; Push S onto the stack
 PHA

 EOR #%11111111         ; Set S = ~S + 1 + C
 ADC #0
 STA S

 PLA                    ; Pull the original, negative S from the stack into A

.LL127

 EOR XX12+3             ; Set A = original argument S EOR'd with XX12+3

 RTS                    ; Return from the subroutine

; ******************************************************************************
;
;       Name: DOEXP
;       Type: Subroutine
;   Category: Drawing ships
;    Summary: Draw an exploding ship
;  Deep dive: Drawing explosion clouds
;             Generating random numbers
;
; ------------------------------------------------------------------------------
;
; Other entry points:
;
;   EXS1                Set (A X) = (A R) +/- random * cloud size
;
; ******************************************************************************

.EX2

 LDA INWK+31            ; Set bits 5 and 7 of the ship's byte #31 to denote that
 ORA #%10100000         ; the ship is exploding and has been killed
 STA INWK+31

.dexp1

 JMP HideExplosionBurst ; Hide the four sprites that make up the explosion burst
                        ; and return from the subroutine using a tail call

 EQUB $00, $02          ; These bytes appear to be unused

.DOEXP

 SETUP_PPU_FOR_ICON_BAR ; If the PPU has started drawing the icon bar, configure
                        ; the PPU to use nametable 0 and pattern table 0

 LDA INWK+6             ; Set T = z_lo
 STA T

 LDA INWK+7             ; Set A = z_hi, so (A T) = z

 CMP #32                ; If z_hi < 32, skip the next two instructions
 BCC P%+6

 LDA #$FE               ; Set A = 254 and jump to yy (this BNE is effectively a
 BNE yy                 ; JMP, as A is never zero)

 ASL T                  ; Shift (A T) left twice
 ROL A
 ASL T
 ROL A

 SEC                    ; And then shift A left once more, inserting a 1 into
 ROL A                  ; bit 0

                        ; Overall, the above multiplies A by 8 and makes sure it
                        ; is at least 1, to leave a one-byte distance in A. We
                        ; can use this as the distance for our cloud, to ensure
                        ; that the explosion cloud is visible even for ships
                        ; that blow up a long way away

.yy

 STA Q                  ; Store the distance to the explosion in Q

 LDA INWK+34            ; Set A to the cloud counter from byte #34 of the ship's
                        ; data block

 ADC #4                 ; Add 4 to the cloud counter, so it ticks onwards every
                        ; we redraw it

 BCS EX2                ; If the addition overflowed, jump up to EX2 to update
                        ; the explosion flags and return from the subroutine

 STA INWK+34            ; Store the updated cloud counter in byte #34 of the
                        ; ship data block

 JSR DVID4              ; Calculate the following:
                        ;
                        ;   (P R) = 256 * A / Q
                        ;         = 256 * cloud counter / distance
                        ;
                        ; We are going to use this as our cloud size, so the
                        ; further away the cloud, the smaller it is, and as the
                        ; cloud counter ticks onward, the cloud expands

 SETUP_PPU_FOR_ICON_BAR ; If the PPU has started drawing the icon bar, configure
                        ; the PPU to use nametable 0 and pattern table 0

 LDA P                  ; Set A = P, so we now have:
                        ;
                        ;   (A R) = 256 * cloud counter / distance

 CMP #$1C               ; If A < 28, skip the next two instructions
 BCC P%+6

 LDA #$FE               ; Set A = 254 and skip the following (this BNE is
 BNE LABEL_1            ; effectively a JMP as A is never zero)

 ASL R                  ; Shift (A R) left three times to multiply by 8
 ROL A
 ASL R
 ROL A
 ASL R
 ROL A

                        ; Overall, the above multiplies (A R) by 8 to leave a
                        ; one-byte cloud size in A, given by the following:
                        ;
                        ;   A = 8 * cloud counter / distance

.LABEL_1

 STA cloudSize          ; Store the cloud size in cloudSize so we can access it
                        ; later

 LDA INWK+31            ; Clear bit 6 of the ship's byte #31 to denote that the
 AND #%10111111         ; explosion has not yet been drawn
 STA INWK+31

 AND #%00001000         ; If bit 3 of the ship's byte #31 is clear, then nothing
 BEQ dexp1              ; is being drawn on-screen for this ship anyway, so
                        ; return from the subroutine

 LDA INWK+7             ; If z_hi = 0 then jump to PTCLS to draw the explosion
 BEQ PTCLS              ; cloud (but not the explosion burst, as the ship is too
                        ; close for the burst sprites to look good)

 LDY INWK+34            ; Fetch byte #34 of the ship data block, which contains
                        ; the cloud counter

 CPY #24                ; If Y >= 24 then jump to PTCLS to draw the explosion
 BCS PTCLS              ; cloud (but not the explosion burst as the explosion is
                        ; already past that point)

                        ; If we get here then the exploding ship is not too
                        ; close and we haven't yet counted past the initial part
                        ; of the explosion, so we can show the explosion burst
                        ; using the explosion sprites

 JMP DrawExplosionBurst ; Draw the exploding ship along with an explosion burst,
                        ; returning from the subroutine using a tail call

.PTCLS

                        ; This part of the routine actually draws the explosion
                        ; cloud

 JSR HideExplosionBurst ; Hide the four sprites that make up the explosion burst

 LDA cloudSize          ; Fetch the cloud size that we stored above, and store
 STA Q                  ; it in Q

 LDA INWK+34            ; Fetch byte #34 of the ship data block, which contains
                        ; the cloud counter

 BPL P%+4               ; If the cloud counter < 128, then we are in the first
                        ; half of the cloud's existence, so skip the next
                        ; instruction

 EOR #$FF               ; Flip the value of A so that in the second half of the
                        ; cloud's existence, A counts down instead of up

 LSR A                  ; Divide A by 16 so that is has a maximum value of 7
 LSR A
 LSR A
 LSR A

 ORA #1                 ; Make sure A is at least 1 and store it in U, to
 STA U                  ; give us the number of particles in the explosion for
                        ; each vertex

 LDY #7                 ; Fetch byte #7 of the ship blueprint, which contains
 LDA (XX0),Y            ; the explosion count for this ship (i.e. the number of
 STA TGT                ; vertices used as origins for explosion clouds) and
                        ; store it in TGT

 LDA RAND+1             ; Fetch the current random number seed in RAND+1 and
 PHA                    ; store it on the stack, so we can re-randomise the
                        ; seeds when we are done

 LDY #6                 ; Set Y = 6 to point to the byte before the first vertex
                        ; coordinate we stored on the XX3 heap above (we
                        ; increment it below so it points to the first vertex)

.EXL5

 LDX #3                 ; We are about to fetch a pair of coordinates from the
                        ; XX3 heap, so set a counter in X for 4 bytes

.dexp2

 INY                    ; Increment the index in Y so it points to the next byte
                        ; from the coordinate we are copying

 LDA XX3-7,Y            ; Copy byte Y-7 from the XX3 heap to the X-th byte of K3
 STA K3,X

 DEX                    ; Decrement the loop counter

 BPL dexp2              ; Keep copying vertex coordinates into K3 until we have
                        ; copied all six coordinates

                        ; The above loop copies the vertex coordinates from the
                        ; XX3 heap to K3, reversing them as we go, so it sets
                        ; the following:
                        ;
                        ;   K3+3 = x_lo
                        ;   K3+2 = x_hi
                        ;   K3+1 = y_lo
                        ;   K3+0 = y_hi

 STY CNT                ; Set CNT to the index that points to the next vertex on
                        ; the XX3 heap

                        ; This next part copies bytes #37 to #40 from the ship
                        ; data block into the four random number seeds in RAND
                        ; to RAND+3, EOR'ing them with the vertex index so they
                        ; are different for every vertex. This enables us to
                        ; generate random numbers for drawing each vertex that
                        ; are random but repeatable, which we need when we
                        ; redraw the cloud to remove it
                        ;
                        ; We set the values of bytes #37 to #40 randomly in the
                        ; LL9 routine before calling DOEXP, so the explosion
                        ; cloud is random but repeatable

 LDY #37                ; Set Y to act as an index into the ship data block for
                        ; byte #37

 LDA (INF),Y            ; Set the seed at RAND to byte #37, EOR'd with the
 EOR CNT                ; vertex index, so the seeds are different for each
 STA RAND               ; vertex

 INY                    ; Increment Y to point to byte #38

 LDA (INF),Y            ; Set the seed at RAND+1 to byte #38, EOR'd with the
 EOR CNT                ; vertex index, so the seeds are different for each
 STA RAND+1             ; vertex

 INY                    ; Increment Y to point to byte #39

 LDA (INF),Y            ; Set the seed at RAND+2 to byte #39, EOR'd with the
 EOR CNT                ; vertex index, so the seeds are different for each
 STA RAND+2             ; vertex

 INY                    ; Increment Y to point to byte #40

 LDA (INF),Y            ; Set the seed at RAND+3 to byte #49, EOR'd with the
 EOR CNT                ; vertex index, so the seeds are different for each
 STA RAND+3             ; vertex

 LDY U                  ; Set Y to the number of particles in the explosion for
                        ; each vertex, which we stored in U above. We will now
                        ; use this as a loop counter to iterate through all the
                        ; particles in the explosion

.EXL4

 SETUP_PPU_FOR_ICON_BAR ; If the PPU has started drawing the icon bar, configure
                        ; the PPU to use nametable 0 and pattern table 0

 CLC                    ; This contains the code from the DORND2 routine, so
 LDA RAND               ; this section is exactly equivalent to a JSR DORND2
 ROL A                  ; call, but is slightly faster as it's been inlined
 TAX                    ; (so it sets A and X to random values, making sure
 ADC RAND+2             ; the C flag doesn't affect the outcome)
 STA RAND
 STX RAND+2
 LDA RAND+1
 TAX
 ADC RAND+3
 STA RAND+1
 STX RAND+3

 STA ZZ                 ; Set ZZ to a random number

 LDA K3+1               ; Set (A R) = (y_hi y_lo)
 STA R                  ;           = y
 LDA K3

 JSR EXS1               ; Set (A X) = (A R) +/- random * cloud size
                        ;           = y +/- random * cloud size

 BNE EX11               ; If A is non-zero, the particle is off-screen as the
                        ; coordinate is bigger than 255), so jump to EX11 to do
                        ; the next particle

 CPX Yx2M1              ; If X > the y-coordinate of the bottom of the screen
 BCS EX11               ; (which is in Yx2M1) then the particle is off the
                        ; bottom of the screen, so jump to EX11 to do the next
                        ; particle

                        ; Otherwise X contains a random y-coordinate within the
                        ; cloud

 STX Y1                 ; Set Y1 = our random y-coordinate within the cloud

 LDA K3+3               ; Set (A R) = (x_hi x_lo)
 STA R
 LDA K3+2

 JSR EXS1               ; Set (A X) = (A R) +/- random * cloud size
                        ;           = x +/- random * cloud size

 BNE EX4                ; If A is non-zero, the particle is off-screen as the
                        ; coordinate is bigger than 255), so jump to EX11 to do
                        ; the next particle

                        ; Otherwise X contains a random x-coordinate within the
                        ; cloud

 LDA Y1                 ; Set A = our random y-coordinate within the cloud

 JSR PIXEL              ; Draw a point at screen coordinate (X, A) with the
                        ; point size determined by the distance in ZZ

.EX4

 DEY                    ; Decrement the loop counter for the next particle

 BPL EXL4               ; Loop back to EXL4 until we have done all the particles
                        ; in the cloud

 LDY CNT                ; Set Y to the index that points to the next vertex on
                        ; the XX3 heap

 CPY TGT                ; If Y < TGT, which we set to the explosion count for
 BCC EXL5               ; this ship (i.e. the number of vertices used as origins
                        ; for explosion clouds), loop back to EXL5 to do a cloud
                        ; for the next vertex

 PLA                    ; Restore the current random number seed to RAND+1 that
 STA RAND+1             ; we stored at the start of the routine

 LDA K%+6               ; Store the z_lo coordinate for the planet (which will
 STA RAND+3             ; be pretty random) in the RAND+3 seed

 RTS                    ; Return from the subroutine

.EX11

 CLC                    ; This contains the code from the DORND2 routine, so
 LDA RAND               ; this section is exactly equivalent to a JSR DORND2
 ROL A                  ; call, but is slightly faster as it's been inlined
 TAX                    ; (so it sets A and X to random values, making sure
 ADC RAND+2             ; the C flag doesn't affect the outcome)
 STA RAND
 STX RAND+2
 LDA RAND+1
 TAX
 ADC RAND+3
 STA RAND+1
 STX RAND+3

 JMP EX4                ; We just skipped a particle, so jump up to EX4 to do
                        ; the next one

.EXS1

                        ; This routine calculates the following:
                        ;
                        ;   (A X) = (A R) +/- random * cloud size
                        ;
                        ; returning with the flags set for the high byte in A

 STA S                  ; Store A in S so we can use it later

 CLC                    ; This contains the code from the DORND2 routine, so
 LDA RAND               ; this section is exactly equivalent to a JSR DORND2
 ROL A                  ; call, but is slightly faster as it's been inlined
 TAX                    ; (so it sets A and X to random values, making sure
 ADC RAND+2             ; the C flag doesn't affect the outcome)
 STA RAND
 STX RAND+2
 LDA RAND+1
 TAX
 ADC RAND+3
 STA RAND+1
 STX RAND+3

 ROL A                  ; Set A = A * 2

 BCS EX5                ; If bit 7 of A was set (50% chance), jump to EX5

 JSR FMLTU              ; Set A = A * Q / 256
                        ;       = random << 1 * projected cloud size / 256

 ADC R                  ; Set (A X) = (S R) + A
 TAX                    ;           = (S R) + random * projected cloud size
                        ;
                        ; where S contains the argument A, starting with the low
                        ; bytes

 LDA S                  ; And then the high bytes
 ADC #0

 RTS                    ; Return from the subroutine

.EX5

 JSR FMLTU              ; Set T = A * Q / 256
 STA T                  ;       = random << 1 * projected cloud size / 256

 LDA R                  ; Set (A X) = (S R) - T
 SBC T                  ;
 TAX                    ; where S contains the argument A, starting with the low
                        ; bytes

 LDA S                  ; And then the high bytes
 SBC #0

 RTS                    ; Return from the subroutine

; ******************************************************************************
;
;       Name: PLANET
;       Type: Subroutine
;   Category: Drawing planets
;    Summary: Draw the planet or sun
;
; ------------------------------------------------------------------------------
;
; Arguments:
;
;   INWK                The planet or sun's ship data block
;
; ******************************************************************************

.PL2

 RTS                    ; Return from the subroutine

.PLANET

 LDA INWK+8             ; Set A = z_sign (the highest byte in the planet/sun's
                        ; coordinates)

 CMP #48                ; If A >= 48 then the planet/sun is too far away to be
 BCS PL2                ; seen, so jump to PL2 to remove it from the screen,
                        ; returning from the subroutine using a tail call

 ORA INWK+7             ; Set A to 0 if both z_sign and z_hi are 0

 BEQ PL2                ; If both z_sign and z_hi are 0, then the planet/sun is
                        ; too close to be shown, so jump to PL2 to remove it
                        ; from the screen, returning from the subroutine using a
                        ; tail call

 JSR PROJ               ; Project the planet/sun onto the screen, returning the
                        ; centre's coordinates in K3(1 0) and K4(1 0)

 BCS PL2                ; If the C flag is set by PROJ then the planet/sun is
                        ; not visible on-screen, so jump to PL2 to remove it
                        ; from the screen, returning from the subroutine using
                        ; a tail call

 LDA #96                ; Set (A P+1 P) = (0 96 0) = 24576
 STA P+1                ;
 LDA #0                 ; This represents the planet/sun's radius at a distance
 STA P                  ; of z = 1

 JSR DVID3B2            ; Call DVID3B2 to calculate:
                        ;
                        ;   K(3 2 1 0) = (A P+1 P) / (z_sign z_hi z_lo)
                        ;              = (0 96 0) / z
                        ;              = 24576 / z
                        ;
                        ; so K now contains the planet/sun's radius, reduced by
                        ; the actual distance to the planet/sun. We know that
                        ; K+3 and K+2 will be 0, as the number we are dividing,
                        ; (0 96 0), fits into the two bottom bytes, so the
                        ; result is actually in K(1 0)

 LDA K+1                ; If the high byte of the reduced radius is zero, jump
 BEQ PL82               ; to PL82, as K contains the radius on its own

 LDA #248               ; Otherwise set K = 248, to round up the radius in
 STA K                  ; K(1 0) to the nearest integer (if we consider the low
                        ; byte to be the fractional part)

.PL82

 LDA TYPE               ; If the planet/sun's type has bit 0 clear, then it's
 LSR A                  ; either 128 or 130, which is a planet (the sun has type
 BCC PL9                ; 129, which has bit 0 set). So jump to PL9 to draw the
                        ; planet with radius K, returning from the subroutine
                        ; using a tail call

 JMP SUN                ; Otherwise jump to SUN to draw the sun with radius K,
                        ; returning from the subroutine using a tail call

; ******************************************************************************
;
;       Name: PL9 (Part 1 of 3)
;       Type: Subroutine
;   Category: Drawing planets
;    Summary: Draw the planet, with either an equator and meridian, or a crater
;
; ------------------------------------------------------------------------------
;
; Draw the planet with radius K at pixel coordinate (K3, K4), and with either an
; equator and meridian, or a crater.
;
; Arguments:
;
;   K(1 0)              The planet's radius
;
;   K3(1 0)             Pixel x-coordinate of the centre of the planet
;
;   K4(1 0)             Pixel y-coordinate of the centre of the planet
;
;   INWK                The planet's ship data block
;
; ******************************************************************************

.PL9

 JSR CIRCLE             ; Call CIRCLE to draw the planet's new circle

 BCS PL20               ; If the call to CIRCLE returned with the C flag set,
                        ; then the circle does not fit on-screen, so jump to
                        ; PL20 to return from the subroutine

 LDA K+1                ; If K+1 is zero, jump to PL25 as K(1 0) < 256, so the
 BEQ PL25               ; planet fits on the screen and we can draw meridians or
                        ; craters

.PL20

 RTS                    ; The planet doesn't fit on-screen, so return from the
                        ; subroutine

.PL25

 LDA TYPE               ; If the planet type is 128 then it has an equator and
 CMP #128               ; a meridian, so this jumps to PL26 if this is not a
 BNE PL26               ; planet with an equator - in other words, if it is a
                        ; planet with a crater

                        ; Otherwise this is a planet with an equator and
                        ; meridian, so fall through into the following to draw
                        ; them

; ******************************************************************************
;
;       Name: PL9 (Part 2 of 3)
;       Type: Subroutine
;   Category: Drawing planets
;    Summary: Draw the planet's equator and meridian
;  Deep dive: Drawing meridians and equators
;
; ------------------------------------------------------------------------------
;
; Draw the planet's equator and meridian.
;
; Arguments:
;
;   K(1 0)              The planet's radius
;
;   K3(1 0)             Pixel x-coordinate of the centre of the planet
;
;   K4(1 0)             Pixel y-coordinate of the centre of the planet
;
;   INWK                The planet's ship data block
;
; ******************************************************************************

 LDA K                  ; If the planet's radius is less than 6, the planet is
 CMP #6                 ; too small to show a meridian, so jump to PL20 to
 BCC PL20               ; return from the subroutine

 LDA INWK+14            ; Set P = -nosev_z_hi
 EOR #%10000000
 STA P

 LDA INWK+20            ; Set A = roofv_z_hi

 JSR PLS4               ; Call PLS4 to calculate the following:
                        ;
                        ;   CNT2 = arctan(P / A) / 4
                        ;        = arctan(-nosev_z_hi / roofv_z_hi) / 4
                        ;
                        ; and do the following if nosev_z_hi >= 0:
                        ;
                        ;   CNT2 = CNT2 + PI

 LDX #9                 ; Set X to 9 so the call to PLS1 divides nosev_x

 JSR PLS1               ; Call PLS1 to calculate the following:
 STA K2                 ;
 STY XX16               ;   (XX16 K2) = nosev_x / z
                        ;
                        ; and increment X to point to nosev_y for the next call

 JSR PLS1               ; Call PLS1 to calculate the following:
 STA K2+1               ;
 STY XX16+1             ;   (XX16+1 K2+1) = nosev_y / z

 LDX #15                ; Set X to 15 so the call to PLS5 divides roofv_x

 JSR PLS5               ; Call PLS5 to calculate the following:
                        ;
                        ;   (XX16+2 K2+2) = roofv_x / z
                        ;
                        ;   (XX16+3 K2+3) = roofv_y / z

 JSR PLS2               ; Call PLS2 to draw the first meridian

 LDA INWK+14            ; Set P = -nosev_z_hi
 EOR #%10000000
 STA P

 LDA INWK+26            ; Set A = sidev_z_hi, so the second meridian will be at
                        ; 90 degrees to the first

 JSR PLS4               ; Call PLS4 to calculate the following:
                        ;
                        ;   CNT2 = arctan(P / A) / 4
                        ;        = arctan(-nosev_z_hi / sidev_z_hi) / 4
                        ;
                        ; and do the following if nosev_z_hi >= 0:
                        ;
                        ;   CNT2 = CNT2 + PI

 LDX #21                ; Set X to 21 so the call to PLS5 divides sidev_x

 JSR PLS5               ; Call PLS5 to calculate the following:
                        ;
                        ;   (XX16+2 K2+2) = sidev_x / z
                        ;
                        ;   (XX16+3 K2+3) = sidev_y / z

 JMP PLS2               ; Jump to PLS2 to draw the second meridian, returning
                        ; from the subroutine using a tail call

; ******************************************************************************
;
;       Name: PL9 (Part 3 of 3)
;       Type: Subroutine
;   Category: Drawing planets
;    Summary: Draw the planet's crater
;  Deep dive: Drawing craters
;
; ------------------------------------------------------------------------------
;
; Draw the planet's crater.
;
; Arguments:
;
;   K(1 0)              The planet's radius
;
;   K3(1 0)             Pixel x-coordinate of the centre of the planet
;
;   K4(1 0)             Pixel y-coordinate of the centre of the planet
;
;   INWK                The planet's ship data block
;
; ******************************************************************************

.PL26

 LDA INWK+20            ; Set A = roofv_z_hi

 BMI PL20               ; If A is negative, the crater is on the far side of the
                        ; planet, so return from the subroutine (as PL2
                        ; contains an RTS)

 LDX #15                ; Set X = 15, so the following call to PLS3 operates on
                        ; roofv

 JSR PLS3               ; Call PLS3 to calculate:
                        ;
                        ;   (Y A P) = 222 * roofv_x / z
                        ;
                        ; to give the x-coordinate of the crater offset and
                        ; increment X to point to roofv_y for the next call

 CLC                    ; Calculate:
 ADC K3                 ;
 STA K3                 ;   K3(1 0) = (Y A) + K3(1 0)
                        ;           = 222 * roofv_x / z + x-coordinate of planet
                        ;             centre
                        ;
                        ; starting with the high bytes

 TYA                    ; And then doing the low bytes, so now K3(1 0) contains
 ADC K3+1               ; the x-coordinate of the crater offset plus the planet
 STA K3+1               ; centre to give the x-coordinate of the crater's centre

 JSR PLS3               ; Call PLS3 to calculate:
                        ;
                        ;   (Y A P) = 222 * roofv_y / z
                        ;
                        ; to give the y-coordinate of the crater offset

 STA P                  ; Calculate:
 LDA K4                 ;
 SEC                    ;   K4(1 0) = K4(1 0) - (Y A)
 SBC P                  ;           = 222 * roofv_y / z - y-coordinate of planet
 STA K4                 ;             centre
                        ;
                        ; starting with the low bytes

 STY P                  ; And then doing the low bytes, so now K4(1 0) contains
 LDA K4+1               ; the y-coordinate of the crater offset plus the planet
 SBC P                  ; centre to give the y-coordinate of the crater's centre
 STA K4+1

 LDX #9                 ; Set X = 9, so the following call to PLS1 operates on
                        ; nosev

 JSR PLS1               ; Call PLS1 to calculate the following:
                        ;
                        ;   (Y A) = nosev_x / z
                        ;
                        ; and increment X to point to nosev_y for the next call

 LSR A                  ; Set (XX16 K2) = (Y A) / 2
 STA K2
 STY XX16

 JSR PLS1               ; Call PLS1 to calculate the following:
                        ;
                        ;   (Y A) = nosev_y / z
                        ;
                        ; and increment X to point to nosev_z for the next call

 LSR A                  ; Set (XX16+1 K2+1) = (Y A) / 2
 STA K2+1
 STY XX16+1

 LDX #21                ; Set X = 21, so the following call to PLS1 operates on
                        ; sidev

 JSR PLS1               ; Call PLS1 to calculate the following:
                        ;
                        ;   (Y A) = sidev_x / z
                        ;
                        ; and increment X to point to sidev_y for the next call

 LSR A                  ; Set (XX16+2 K2+2) = (Y A) / 2
 STA K2+2
 STY XX16+2

 JSR PLS1               ; Call PLS1 to calculate the following:
                        ;
                        ;   (Y A) = sidev_y / z
                        ;
                        ; and increment X to point to sidev_z for the next call

 LSR A                  ; Set (XX16+3 K2+3) = (Y A) / 2
 STA K2+3
 STY XX16+3

 LDA #64                ; Set TGT = 64, so we draw a full ellipse in the call to
 STA TGT                ; PLS22 below

 LDA #0                 ; Set CNT2 = 0 as we are drawing a full ellipse, so we
 STA CNT2               ; don't need to apply an offset

 JMP PLS22              ; Jump to PLS22 to draw the crater, returning from the
                        ; subroutine using a tail call

; ******************************************************************************
;
;       Name: PLS1
;       Type: Subroutine
;   Category: Drawing planets
;    Summary: Calculate (Y A) = nosev_x / z
;
; ------------------------------------------------------------------------------
;
; Calculate the following division of a specified value from one of the
; orientation vectors (in this example, nosev_x):
;
;   (Y A) = nosev_x / z
;
; where z is the z-coordinate of the planet from INWK. The result is an 8-bit
; magnitude in A, with maximum value 254, and just a sign bit (bit 7) in Y.
;
; Arguments:
;
;   X                   Determines which of the INWK orientation vectors to
;                       divide:
;
;                         * X = 9, 11, 13: divides nosev_x, nosev_y, nosev_z
;
;                         * X = 15, 17, 19: divides roofv_x, roofv_y, roofv_z
;
;                         * X = 21, 23, 25: divides sidev_x, sidev_y, sidev_z
;
;   INWK                The planet's ship data block
;
; Returns:
;
;   A                   The result as an 8-bit magnitude with maximum value 254
;
;   Y                   The sign of the result in bit 7
;
;   K+3                 Also the sign of the result in bit 7
;
;   X                   X gets incremented by 2 so it points to the next
;                       coordinate in this orientation vector (so consecutive
;                       calls to the routine will start with x, then move onto y
;                       and then z)
;
; ******************************************************************************

.PLS1

 LDA INWK,X             ; Set P = nosev_x_lo
 STA P

 LDA INWK+1,X           ; Set P+1 = |nosev_x_hi|
 AND #%01111111
 STA P+1

 LDA INWK+1,X           ; Set A = sign bit of nosev_x_lo
 AND #%10000000

 JSR DVID3B2            ; Call DVID3B2 to calculate:
                        ;
                        ;   K(3 2 1 0) = (A P+1 P) / (z_sign z_hi z_lo)

 LDA K                  ; Fetch the lowest byte of the result into A

 LDY K+1                ; Fetch the second byte of the result into Y

 BEQ P%+4               ; If the second byte is 0, skip the next instruction

 LDA #254               ; The second byte is non-zero, so the result won't fit
                        ; into one byte, so set A = 254 as our maximum one-byte
                        ; value to return

 LDY K+3                ; Fetch the sign of the result from K+3 into Y

 INX                    ; Add 2 to X so the index points to the next coordinate
 INX                    ; in this orientation vector (so consecutive calls to
                        ; the routine will start with x, then move onto y and z)

 RTS                    ; Return from the subroutine

; ******************************************************************************
;
;       Name: PLS2
;       Type: Subroutine
;   Category: Drawing planets
;    Summary: Draw a half-ellipse
;  Deep dive: Drawing ellipses
;             Drawing meridians and equators
;
; ------------------------------------------------------------------------------
;
; Draw a half-ellipse, used for the planet's equator and meridian.
;
; ******************************************************************************

.PLS2

 LDA #31                ; Set TGT = 31, so we only draw half an ellipse
 STA TGT

                        ; Fall through into PLS22 to draw the half-ellipse

; ******************************************************************************
;
;       Name: PLS22
;       Type: Subroutine
;   Category: Drawing planets
;    Summary: Draw an ellipse or half-ellipse
;  Deep dive: Drawing ellipses
;             Drawing meridians and equators
;             Drawing craters
;
; ------------------------------------------------------------------------------
;
; Draw an ellipse or half-ellipse, to be used for the planet's equator and
; meridian (in which case we draw half an ellipse), or crater (in which case we
; draw a full ellipse).
;
; The ellipse is defined by a centre point, plus two conjugate radius vectors,
; u and v, where:
;
;   u = [ u_x ]       v = [ v_x ]
;       [ u_y ]           [ v_y ]
;
; The individual components of these 2D vectors (i.e. u_x, u_y etc.) are 16-bit
; sign-magnitude numbers, where the high bytes contain only the sign bit (in
; bit 7), with bits 0 to 6 being clear. This means that as we store u_x as
; (XX16 K2), for example, we know that |u_x| = K2.
;
; This routine calls BLINE to draw each line segment in the ellipse, passing the
; coordinates as follows:
;
;   K6(1 0) = K3(1 0) + u_x * cos(CNT2) + v_x * sin(CNT2)
;
;   K6(3 2) = K4(1 0) - u_y * cos(CNT2) - v_y * sin(CNT2)
;
; The y-coordinates are negated because BLINE expects pixel coordinates but the
; u and v vectors are extracted from the orientation vector. The y-axis runs
; in the opposite direction in 3D space to that on the screen, so we need to
; negate the 3D space coordinates before we can combine them with the ellipse's
; centre coordinates.
;
; Arguments:
;
;   K(1 0)              The planet's radius
;
;   K3(1 0)             The pixel x-coordinate of the centre of the ellipse
;
;   K4(1 0)             The pixel y-coordinate of the centre of the ellipse
;
;   (XX16 K2)           The x-component of u (i.e. u_x), where XX16 contains
;                       just the sign of the sign-magnitude number
;
;   (XX16+1 K2+1)       The y-component of u (i.e. u_y), where XX16+1 contains
;                       just the sign of the sign-magnitude number
;
;   (XX16+2 K2+2)       The x-component of v (i.e. v_x), where XX16+2 contains
;                       just the sign of the sign-magnitude number
;
;   (XX16+3 K2+3)       The y-component of v (i.e. v_y), where XX16+3 contains
;                       just the sign of the sign-magnitude number
;
;   TGT                 The number of segments to draw:
;
;                         * 32 for a half ellipse (a meridian)
;
;                         * 64 for a full ellipse (a crater)
;
;   CNT2                The starting segment for drawing the half-ellipse
;
; Other entry points:
;
;   PL40                Contains an RTS
;
; ******************************************************************************

.PLS22

 LDX #0                 ; Set CNT = 0
 STX CNT

 DEX                    ; Set FLAG = $FF to reset the ball line heap in the call
 STX FLAG               ; to the BLINE routine below

.PLL4

 LDA CNT2               ; Set X = CNT2 mod 32
 AND #31                ;
 TAX                    ; So X is the starting segment, reduced to the range 0
                        ; to 32, so as there are 64 segments in the circle, this
                        ; reduces the starting angle to 0 to 180 degrees, so we
                        ; can use X as an index into the sine table (which only
                        ; contains values for segments 0 to 31)
                        ;
                        ; Also, because CNT2 mod 32 is in the range 0 to 180
                        ; degrees, we know that sin(CNT2 mod 32) is always
                        ; positive, or to put it another way:
                        ;
                        ;   sin(CNT2 mod 32) = |sin(CNT2)|

 LDA SNE,X              ; Set Q = sin(X)
 STA Q                  ;       = sin(CNT2 mod 32)
                        ;       = |sin(CNT2)|

 LDA K2+2               ; Set A = K2+2
                        ;       = |v_x|

 JSR FMLTU              ; Set R = A * Q / 256
 STA R                  ;       = |v_x| * |sin(CNT2)|

 LDA K2+3               ; Set A = K2+3
                        ;       = |v_y|

 JSR FMLTU              ; Set K = A * Q / 256
 STA K                  ;       = |v_y| * |sin(CNT2)|

 LDX CNT2               ; If CNT2 >= 33 then this sets the C flag, otherwise
 CPX #33                ; it's clear, so this means that:
                        ;
                        ;   * C is clear if the segment starts in the first half
                        ;     of the circle, 0 to 180 degrees
                        ;
                        ;   * C is set if the segment starts in the second half
                        ;     of the circle, 180 to 360 degrees
                        ;
                        ; In other words, the C flag contains the sign bit for
                        ; sin(CNT2), which is positive for 0 to 180 degrees
                        ; and negative for 180 to 360 degrees

 LDA #0                 ; Shift the C flag into the sign bit of XX16+5, so
 ROR A                  ; XX16+5 has the correct sign for sin(CNT2)
 STA XX16+5             ;
                        ; Because we set the following above:
                        ;
                        ;   K = |v_y| * |sin(CNT2)|
                        ;   R = |v_x| * |sin(CNT2)|
                        ;
                        ; we can add XX16+5 as the high byte to give us the
                        ; following:
                        ;
                        ;   (XX16+5 K) = |v_y| * sin(CNT2)
                        ;   (XX16+5 R) = |v_x| * sin(CNT2)

 LDA CNT2               ; Set X = (CNT2 + 16) mod 32
 CLC                    ;
 ADC #16                ; So we can use X as a lookup index into the SNE table
 AND #31                ; to get the cosine (as there are 16 segments in a
 TAX                    ; quarter-circle)
                        ;
                        ; Also, because the sine table only contains positive
                        ; values, we know that sin((CNT2 + 16) mod 32) will
                        ; always be positive, or to put it another way:
                        ;
                        ;   sin((CNT2 + 16) mod 32) = |cos(CNT2)|

 LDA SNE,X              ; Set Q = sin(X)
 STA Q                  ;       = sin((CNT2 + 16) mod 32)
                        ;       = |cos(CNT2)|

 LDA K2+1               ; Set A = K2+1
                        ;       = |u_y|

 JSR FMLTU              ; Set K+2 = A * Q / 256
 STA K+2                ;         = |u_y| * |cos(CNT2)|

 LDA K2                 ; Set A = K2
                        ;       = |u_x|

 JSR FMLTU              ; Set P = A * Q / 256
 STA P                  ;       = |u_x| * |cos(CNT2)|
                        ;
                        ; The call to FMLTU also sets the C flag, so in the
                        ; following, ADC #15 adds 16 rather than 15

 LDA CNT2               ; If (CNT2 + 16) mod 64 >= 33 then this sets the C flag,
 ADC #15                ; otherwise it's clear, so this means that:
 AND #63                ;
 CMP #33                ;   * C is clear if the segment starts in the first or
                        ;     last quarter of the circle, 0 to 90 degrees or 270
                        ;     to 360 degrees
                        ;
                        ;   * C is set if the segment starts in the second or
                        ;     third quarter of the circle, 90 to 270 degrees
                        ;
                        ; In other words, the C flag contains the sign bit for
                        ; cos(CNT2), which is positive for 0 to 90 degrees or
                        ; 270 to 360 degrees, and negative for 90 to 270 degrees

 LDA #0                 ; Shift the C flag into the sign bit of XX16+4, so:
 ROR A                  ; XX16+4 has the correct sign for cos(CNT2)
 STA XX16+4             ;
                        ; Because we set the following above:
                        ;
                        ;   K+2 = |u_y| * |cos(CNT2)|
                        ;   P   = |u_x| * |cos(CNT2)|
                        ;
                        ; we can add XX16+4 as the high byte to give us the
                        ; following:
                        ;
                        ;   (XX16+4 K+2) = |u_y| * cos(CNT2)
                        ;   (XX16+4 P)   = |u_x| * cos(CNT2)

 LDA XX16+5             ; Set S = the sign of XX16+2 * XX16+5
 EOR XX16+2             ;       = the sign of v_x * XX16+5
 STA S                  ;
                        ; So because we set this above:
                        ;
                        ;   (XX16+5 R) = |v_x| * sin(CNT2)
                        ;
                        ; we now have this:
                        ;
                        ;   (S R) = v_x * sin(CNT2)

 LDA XX16+4             ; Set A = the sign of XX16 * XX16+4
 EOR XX16               ;       = the sign of u_x * XX16+4
                        ;
                        ; So because we set this above:
                        ;
                        ;   (XX16+4 P)   = |u_x| * cos(CNT2)
                        ;
                        ; we now have this:
                        ;
                        ;   (A P) = u_x * cos(CNT2)

 JSR ADD                ; Set (A X) = (A P) + (S R)
                        ;           = u_x * cos(CNT2) + v_x * sin(CNT2)

 STA T                  ; Store the high byte in T, so the result is now:
                        ;
                        ;   (T X) = u_x * cos(CNT2) + v_x * sin(CNT2)

 BPL PL42               ; If the result is positive, jump down to PL42

 TXA                    ; The result is negative, so we need to negate the
 EOR #%11111111         ; magnitude using two's complement, first doing the low
 CLC                    ; byte in X
 ADC #1
 TAX

 LDA T                  ; And then the high byte in T, making sure to leave the
 EOR #%01111111         ; sign bit alone
 ADC #0
 STA T

.PL42

 SETUP_PPU_FOR_ICON_BAR ; If the PPU has started drawing the icon bar, configure
                        ; the PPU to use nametable 0 and pattern table 0

 TXA                    ; Set K6(1 0) = K3(1 0) + (T X)
 ADC K3                 ;
 STA K6                 ; starting with the low bytes

 LDA T                  ; And then doing the high bytes, so we now get:
 ADC K3+1               ;
 STA K6+1               ;   K6(1 0) = K3(1 0) + (T X)
                        ;           = K3(1 0) + u_x * cos(CNT2)
                        ;                     + v_x * sin(CNT2)
                        ;
                        ; K3(1 0) is the x-coordinate of the centre of the
                        ; ellipse, so we now have the correct x-coordinate for
                        ; our ellipse segment that we can pass to BLINE below

 LDA K                  ; Set R = K = |v_y| * sin(CNT2)
 STA R

 LDA XX16+5             ; Set S = the sign of XX16+3 * XX16+5
 EOR XX16+3             ;       = the sign of v_y * XX16+5
 STA S                  ;
                        ; So because we set this above:
                        ;
                        ;   (XX16+5 K) = |v_y| * sin(CNT2)
                        ;
                        ; and we just set R = K, we now have this:
                        ;
                        ;   (S R) = v_y * sin(CNT2)

 LDA K+2                ; Set P = K+2 = |u_y| * cos(CNT2)
 STA P

 LDA XX16+4             ; Set A = the sign of XX16+1 * XX16+4
 EOR XX16+1             ;       = the sign of u_y * XX16+4
                        ;
                        ; So because we set this above:
                        ;
                        ;   (XX16+4 K+2) = |u_y| * cos(CNT2)
                        ;
                        ; and we just set P = K+2, we now have this:
                        ;
                        ;   (A P) = u_y * cos(CNT2)

 JSR ADD                ; Set (A X) = (A P) + (S R)
                        ;           =  u_y * cos(CNT2) + v_y * sin(CNT2)

 EOR #%10000000         ; Store the negated high byte in T, so the result is
 STA T                  ; now:
                        ;
                        ;   (T X) = - u_y * cos(CNT2) - v_y * sin(CNT2)
                        ;
                        ; This negation is necessary because BLINE expects us
                        ; to pass pixel coordinates, where y-coordinates get
                        ; larger as we go down the screen; u_y and v_y, on the
                        ; other hand, are extracted from the orientation
                        ; vectors, where y-coordinates get larger as we go up
                        ; in space, so to rectify this we need to negate the
                        ; result in (T X) before we can add it to the
                        ; y-coordinate of the ellipse's centre in BLINE

 BPL PL43               ; If the result is positive, jump down to PL43

 TXA                    ; The result is negative, so we need to negate the
 EOR #%11111111         ; magnitude using two's complement, first doing the low
 CLC                    ; byte in X
 ADC #1
 TAX

 LDA T                  ; And then the high byte in T, making sure to leave the
 EOR #%01111111         ; sign bit alone
 ADC #0
 STA T

.PL43

                        ; We now call BLINE to draw the ellipse line segment
                        ;
                        ; The first few instructions of BLINE do the following:
                        ;
                        ;   K6(3 2) = K4(1 0) + (T X)
                        ;
                        ; which gives:
                        ;
                        ;   K6(3 2) = K4(1 0) - u_y * cos(CNT2)
                        ;                     - v_y * sin(CNT2)
                        ;
                        ; K4(1 0) is the pixel y-coordinate of the centre of the
                        ; ellipse, so this gives us the correct y-coordinate for
                        ; our ellipse segment (we already calculated the
                        ; x-coordinate in K3(1 0) above)

 JSR BLINE              ; Call BLINE to draw this segment, which also returns
                        ; the updated value of CNT in A

 CMP TGT                ; If CNT > TGT then jump to PL40 to stop drawing the
 BEQ P%+4               ; ellipse (which is how we draw half-ellipses)
 BCS PL40

 LDA CNT2               ; Set CNT2 = (CNT2 + STP) mod 64
 CLC
 ADC STP
 AND #63
 STA CNT2

 JMP PLL4               ; Jump back to PLL4 to draw the next segment

.PL40

 RTS                    ; Return from the subroutine

; ******************************************************************************
;
;       Name: SUN (Part 1 of 2)
;       Type: Subroutine
;   Category: Drawing suns
;    Summary: Draw the sun: Set up all the variables needed to draw the sun
;  Deep dive: Drawing the sun
;
; ------------------------------------------------------------------------------
;
; Draw a new sun with radius K at pixel coordinate (K3, K4), removing the old
; sun if there is one. This routine is used to draw the sun, as well as the
; star systems on the Short-range Chart.
;
; The first part sets up all the variables needed to draw the new sun.
;
; Arguments:
;
;   K                   The new sun's radius
;
;   K3(1 0)             Pixel x-coordinate of the centre of the new sun
;
;   K4(1 0)             Pixel y-coordinate of the centre of the new sun
;
;   SUNX(1 0)           The x-coordinate of the vertical centre axis of the old
;                       sun (the one currently on-screen)
;
; ******************************************************************************

.PLF3

                        ; This is called from below to negate X and set A to
                        ; $FF, for when the new sun's centre is off the bottom
                        ; of the screen (so we don't need to draw its bottom
                        ; half)
                        ;
                        ; This happens when the y-coordinate of the centre of
                        ; the sun is bigger than the y-coordinate of the bottom
                        ; of the space view

 TXA                    ; Negate X using two's complement, so A = ~X + 1
 EOR #%11111111
 CLC
 ADC #1

 CMP K                  ; If A >= K then the centre of the sun is further
 BCS PL40               ; off-screen than the radius of the sun in K, which
                        ; means the sun is too far away from the screen to be
                        ; visible and there is nothing to draw, to jump to PL40
                        ; to return from the subroutine

 TAX                    ; Set X to the negated value in A, so X = ~X + 1

.PLF17

                        ; This is called from below to set A to $FF, for when
                        ; the new sun's centre is right on the bottom of the
                        ; screen (so we don't need to draw its bottom half)

 LDA #$FF               ; Set A = $FF

 JMP PLF5               ; Jump to PLF5

.SUN

 LDA nmiCounter         ; Set the random number seed to a fairly random state
 STA RAND               ; that's based on the NMI counter (which increments
                        ; every VBlank, so will be pretty random)

 JSR CHKON              ; Call CHKON to check whether any part of the new sun's
                        ; circle appears on-screen, and if it does, set P(2 1)
                        ; to the maximum y-coordinate of the new sun on-screen

 BCS PL40               ; If CHKON set the C flag then the new sun's circle does
                        ; not appear on-screen, which means there is nothing to
                        ; draw, so jump to PL40 to return from the subroutine

 LDA #0                 ; Set A = 0

 LDX K                  ; Set X = K = radius of the new sun

 BEQ PL40               ; If the radius of the new sun is zero then there is
                        ; nothing to draw, so jump to PL40 to return from the
                        ; subroutine

 CPX #96                ; If X >= 96, set the C flag and rotate it into bit 0
 ROL A                  ; of A, otherwise rotate a 0 into bit 0

 CPX #40                ; If X >= 40, set the C flag and rotate it into bit 0
 ROL A                  ; of A, otherwise rotate a 0 into bit 0

 CPX #16                ; If X >= 16, set the C flag and rotate it into bit 0
 ROL A                  ; of A, otherwise rotate a 0 into bit 0

                        ; By now, A contains the following:
                        ;
                        ;   * If radius is 96-255 then A = %111 = 7
                        ;
                        ;   * If radius is 40-95  then A = %11  = 3
                        ;
                        ;   * If radius is 16-39  then A = %1   = 1
                        ;
                        ;   * If radius is 0-15   then A = %0   = 0
                        ;
                        ; The value of A determines the size of the new sun's
                        ; ragged fringes - the bigger the sun, the bigger the
                        ; fringes

.PLF18

 STA CNT                ; Store the fringe size in CNT

                        ; We now calculate the highest pixel y-coordinate of the
                        ; new sun, given that P(2 1) contains the 16-bit maximum
                        ; y-coordinate of the new sun on-screen

 LDA Yx2M1              ; Set Y to the y-coordinate of the bottom of the space
                        ; view

 LDX P+2                ; If P+2 is non-zero, the maximum y-coordinate is off
 BNE PLF2               ; the bottom of the screen, so skip to PLF2 with A set
                        ; to the y-coordinate of the bottom of the space view

 CMP P+1                ; If A < P+1, the maximum y-coordinate is underneath the
 BCC PLF2               ; dashboard, so skip to PLF2 with A set to the
                        ; y-coordinate of the bottom of the space view

 LDA P+1                ; Set A = P+1, the low byte of the maximum y-coordinate
                        ; of the sun on-screen

 BNE PLF2               ; If A is non-zero, skip to PLF2 as it contains the
                        ; value we are after

 LDA #1                 ; Otherwise set A = 1, the top line of the screen

.PLF2

 STA TGT                ; Set TGT to A, the maximum y-coordinate of the sun on
                        ; screen

                        ; We now calculate the number of lines we need to draw
                        ; and the direction in which we need to draw them, both
                        ; from the centre of the new sun

 LDA Yx2M1              ; Set (A X) = y-coordinate of bottom of screen - K4(1 0)
 SEC                    ;
 SBC K4                 ; Starting with the low bytes
 TAX

 LDA #0                 ; And then doing the high bytes, so (A X) now contains
 SBC K4+1               ; the number of lines between the centre of the sun and
                        ; the bottom of the screen. If it is positive then the
                        ; centre of the sun is above the bottom of the screen,
                        ; if it is negative then the centre of the sun is below
                        ; the bottom of the screen

 BMI PLF3               ; If A < 0, then this means the new sun's centre is off
                        ; the bottom of the screen, so jump up to PLF3 to negate
                        ; the height in X (so it becomes positive), set A to $FF
                        ; and jump down to PLF5

 BNE PLF4               ; If A > 0, then the new sun's centre is at least a full
                        ; screen above the bottom of the space view, so jump
                        ; down to PLF4 to set X = radius and A = 0

 INX                    ; Set the flags depending on the value of X
 DEX

 BEQ PLF17              ; If X = 0 (we already know A = 0 by this point) then
                        ; jump up to PLF17 to set A to $FF before jumping down
                        ; to PLF5

 CPX K                  ; If X < the radius in K, jump down to PLF5, so if
 BCC PLF5               ; X >= the radius in K, we set X = radius and A = 0

.PLF4

 LDX K                  ; Set X to the radius

 LDA #0                 ; Set A = 0

.PLF5

 STX V                  ; Store the height in V

 STA V+1                ; Store the direction in V+1

 LDA K                  ; Set (A P) = K * K
 JSR SQUA2

 STA K2+1               ; Set K2(1 0) = (A P) = K * K
 LDA P
 STA K2

                        ; By the time we get here, the variables should be set
                        ; up as shown in the header for the PLFL subroutine

; ******************************************************************************
;
;       Name: SUN (Part 2 of 2)
;       Type: Subroutine
;   Category: Drawing suns
;    Summary: Draw the sun: Starting from the bottom of the sun, draw the new
;             sun line by line
;  Deep dive: Drawing the sun
;
; ------------------------------------------------------------------------------
;
; This part erases the old sun, starting at the bottom of the screen and working
; upwards until we reach the bottom of the new sun.
;
; ******************************************************************************

 LDA K3                 ; Set YY(1 0) to the pixel x-coordinate of the centre
 STA YY                 ; of the new sun, from K3(1 0)
 LDA K3+1
 STA YY+1

 LDY TGT                ; Set Y to the maximum y-coordinate of the sun on the
                        ; screen (i.e. the bottom of the sun), which we set up
                        ; in part 1

 LDA #0                 ; Set the sub width variables to zero, so we can use
 STA sunWidth1          ; them below to store the widths of the sun on each
 STA sunWidth2          ; pixel row within each tile row
 STA sunWidth3
 STA sunWidth4
 STA sunWidth5
 STA sunWidth6
 STA sunWidth7

 TYA                    ; Set A to the maximum y-coordinate of the sun, so we
                        ; can apply the first AND below

 TAX                    ; Set X to the maximum y-coordinate of the sun, so we
                        ; can apply the second AND below

 AND #%11111000         ; Each tile row contains 8 pixel rows, so to get the
 TAY                    ; y-coordinate of the first row of pixels in the tile
                        ; row, we clear bits 0-2, so Y now contains the pixel
                        ; y-coordinate of the top pixel row in the tile row
                        ; containing the bottom of the sun

 LDA V+1                ; If V+1 is non-zero then we are doing the top half of
 BNE dsun11             ; the new sun, so jump down to dsun11 to work our way
                        ; upwards from the centre towards the top of the sun

                        ; If we get here then we are drawing the bottom half of
                        ; of the sun, so we work our way up from the bottom by
                        ; decrementing V for each pixel line, as V contains the
                        ; vertical distance between the line we're drawing and
                        ; the centre of the new sun, and it starts out pointing
                        ; to the bottom of the sun

 TXA                    ; Set A = X mod 8, which is the pixel row within the
 AND #7                 ; tile row of the bottom of the sun

 BEQ dsun8              ; If A = 0 then the bottom of the sun is only in the top
                        ; pixel row of the tile row, so jump to dsun8 to
                        ; calculate the sun's width on one pixel row

 CMP #2                 ; If A = 1, jump to dsun7 to calculate the sun's width
 BCC dsun7              ; on two pixel rows

 BEQ dsun6              ; If A = 2, jump to dsun6 to calculate the sun's width
                        ; on three pixel rows

 CMP #4                 ; If A = 3, jump to dsun5 to calculate the sun's width
 BCC dsun5              ; on four pixel rows

 BEQ dsun4              ; If A = 4, jump to dsun4 to calculate the sun's width
                        ; on five pixel rows

 CMP #6                 ; If A = 5, jump to dsun3 to calculate the sun's width
 BCC dsun3              ; on six pixel rows

 BEQ dsun2              ; If A = 6, jump to dsun2 to calculate the sun's width
                        ; on seven pixel rows

                        ; If we get here then A = 7, so keep going to calculate
                        ; the sun's width on all eight pixel rows, starting from
                        ; row 7 at the bottom of the tile row, all the way up to
                        ; pixel row 0 at the top of the tile row

.dsun1

 JSR PLFL               ; Call PLFL to set A to the half-width of the new sun on
                        ; the sun line given in V

 STA sunWidth7          ; Store the half-width of pixel row 7 in sunWidth7

 DEC V                  ; Decrement V, the height of the sun that we use to work
                        ; out the width, so this makes the line get wider, as we
                        ; move up towards the sun's centre

 BEQ dsun12             ; If V is zero then we have reached the centre, so jump
                        ; to dsun12 to start working our way up from the centre,
                        ; incrementing V instead

.dsun2

 JSR PLFL               ; Call PLFL to set A to the half-width of the new sun on
                        ; the sun line given in V

 STA sunWidth6          ; Store the half-width of pixel row 6 in sunWidth6

 DEC V                  ; Decrement V, the height of the sun that we use to work
                        ; out the width, so this makes the line get wider, as we
                        ; move up towards the sun's centre

 BEQ dsun13             ; If V is zero then we have reached the centre, so jump
                        ; to dsun13 to start working our way up from the centre,
                        ; incrementing V for the rest of this tile row

.dsun3

 JSR PLFL               ; Call PLFL to set A to the half-width of the new sun on
                        ; the sun line given in V

 STA sunWidth5          ; Store the half-width of pixel row 5 in sunWidth5

 DEC V                  ; Decrement V, the height of the sun that we use to work
                        ; out the width, so this makes the line get wider, as we
                        ; move up towards the sun's centre

 BEQ dsun14             ; If V is zero then we have reached the centre, so jump
                        ; to dsun14 to start working our way up from the centre,
                        ; incrementing V for the rest of this tile row

.dsun4

 JSR PLFL               ; Call PLFL to set A to the half-width of the new sun on
                        ; the sun line given in V

 STA sunWidth4          ; Store the half-width of pixel row 4 in sunWidth4

 DEC V                  ; Decrement V, the height of the sun that we use to work
                        ; out the width, so this makes the line get wider, as we
                        ; move up towards the sun's centre

 BEQ dsun15             ; If V is zero then we have reached the centre, so jump
                        ; to dsun15 to start working our way up from the centre,
                        ; incrementing V for the rest of this tile row

.dsun5

 JSR PLFL               ; Call PLFL to set A to the half-width of the new sun on
                        ; the sun line given in V

 STA sunWidth3          ; Store the half-width of pixel row 3 in sunWidth3

 DEC V                  ; Decrement V, the height of the sun that we use to work
                        ; out the width, so this makes the line get wider, as we
                        ; move up towards the sun's centre

 BEQ dsun16             ; If V is zero then we have reached the centre, so jump
                        ; to dsun16 to start working our way up from the centre,
                        ; incrementing V for the rest of this tile row

.dsun6

 JSR PLFL               ; Call PLFL to set A to the half-width of the new sun on
                        ; the sun line given in V

 STA sunWidth2          ; Store the half-width of pixel row 2 in sunWidth2

 DEC V                  ; Decrement V, the height of the sun that we use to work
                        ; out the width, so this makes the line get wider, as we
                        ; move up towards the sun's centre

 BEQ dsun17             ; If V is zero then we have reached the centre, so jump
                        ; to dsun17 to start working our way up from the centre,
                        ; incrementing V for the rest of this tile row

.dsun7

 JSR PLFL               ; Call PLFL to set A to the half-width of the new sun on
                        ; the sun line given in V

 STA sunWidth1          ; Store the half-width of pixel row 1 in sunWidth1

 DEC V                  ; Decrement V, the height of the sun that we use to work
                        ; out the width, so this makes the line get wider, as we
                        ; move up towards the sun's centre

 BEQ dsun10             ; If V is zero then we have reached the centre, so jump
                        ; to dsun18 via dsun10 to start working our way up from
                        ; the centre, incrementing V for the rest of this tile
                        ; row

.dsun8

 JSR PLFL               ; Call PLFL to set A to the half-width of the new sun on
                        ; the sun line given in V

 STA sunWidth0          ; Store the half-width of pixel row 0 in sunWidth0

 DEC V                  ; Decrement V, the height of the sun that we use to work
                        ; out the width, so this makes the line get wider, as we
                        ; move up towards the sun's centre

 BEQ dsun9              ; If V is zero then we have reached the centre, so jump
                        ; to dsun19 via dsun9 to start working our way up from
                        ; the centre, incrementing V for the rest of this tile
                        ; row

 JSR dsun28             ; Call dsun28 to draw all eight lines for this tile row

 TYA                    ; Set Y = Y - 8 to move up a tile row
 SEC
 SBC #8
 TAY

 BCS dsun1              ; If the subtraction didn't underflow, then Y is still
                        ; positive and is therefore still on-screen, so loop
                        ; back to dsun1 to keep drawing pixel rows

 RTS                    ; Otherwise we have reached the top of the screen, so
                        ; return from the subroutine as we are done drawing

.dsun9

 BEQ dsun19             ; Jump down to dsun19 (this is only used to enable us to
                        ; use a BEQ dsun9 above)

.dsun10

 BEQ dsun18             ; Jump down to dsun18 (this is only used to enable us to
                        ; use a BEQ dsun10 above)

.dsun11

                        ; If we get here then we are drawing the top half of the
                        ; sun, so we increment V for each pixel line as we move
                        ; up the screen

 JSR PLFL               ; Call PLFL to set A to the half-width of the new sun on
                        ; the sun line given in V

 STA sunWidth7          ; Store the half-width of pixel row 7 in sunWidth7

 LDX V                  ; Increment V, the height of the sun that we use to work
 INX                    ; out the width, so this makes the line get less wide,
 STX V                  ; as we move up and away from the sun's centre

 CPX K                  ; If V >= K then we have reached the top of the sun (as
 BCS dsun21             ; K is the sun's radius, so there are K pixel lines in
                        ; each half of the sun), so jump to dsun21 to draw the
                        ; lines that we have calculated so far for this tile row

.dsun12

 JSR PLFL               ; Call PLFL to set A to the half-width of the new sun on
                        ; the sun line given in V

 STA sunWidth6          ; Store the half-width of pixel row 6 in sunWidth6

 LDX V                  ; Increment V, the height of the sun that we use to work
 INX                    ; out the width, so this makes the line get less wide,
 STX V                  ; as we move up and away from the sun's centre

 CPX K                  ; If V >= K then we have reached the top of the sun (as
 BCS dsun22             ; K is the sun's radius, so there are K pixel lines in
                        ; each half of the sun), so jump to dsun22 to draw the
                        ; lines that we have calculated so far for this tile row

.dsun13

 JSR PLFL               ; Call PLFL to set A to the half-width of the new sun on
                        ; the sun line given in V

 STA sunWidth5          ; Store the half-width of pixel row 5 in sunWidth5

 LDX V                  ; Increment V, the height of the sun that we use to work
 INX                    ; out the width, so this makes the line get less wide,
 STX V                  ; as we move up and away from the sun's centre

 CPX K                  ; If V >= K then we have reached the top of the sun (as
 BCS dsun23             ; K is the sun's radius, so there are K pixel lines in
                        ; each half of the sun), so jump to dsun23 to draw the
                        ; lines that we have calculated so far for this tile row

.dsun14

 JSR PLFL               ; Call PLFL to set A to the half-width of the new sun on
                        ; the sun line given in V

 STA sunWidth4          ; Store the half-width of pixel row 4 in sunWidth4

 LDX V                  ; Increment V, the height of the sun that we use to work
 INX                    ; out the width, so this makes the line get less wide,
 STX V                  ; as we move up and away from the sun's centre

 CPX K                  ; If V >= K then we have reached the top of the sun (as
 BCS dsun24             ; K is the sun's radius, so there are K pixel lines in
                        ; each half of the sun), so jump to dsun24 to draw the
                        ; lines that we have calculated so far for this tile row

.dsun15

 JSR PLFL               ; Call PLFL to set A to the half-width of the new sun on
                        ; the sun line given in V

 STA sunWidth3          ; Store the half-width of pixel row 3 in sunWidth3

 LDX V                  ; Increment V, the height of the sun that we use to work
 INX                    ; out the width, so this makes the line get less wide,
 STX V                  ; as we move up and away from the sun's centre

 CPX K                  ; If V >= K then we have reached the top of the sun (as
 BCS dsun25             ; K is the sun's radius, so there are K pixel lines in
                        ; each half of the sun), so jump to dsun25 to draw the
                        ; lines that we have calculated so far for this tile row

.dsun16

 JSR PLFL               ; Call PLFL to set A to the half-width of the new sun on
                        ; the sun line given in V

 STA sunWidth2          ; Store the half-width of pixel row 2 in sunWidth2

 LDX V                  ; Increment V, the height of the sun that we use to work
 INX                    ; out the width, so this makes the line get less wide,
 STX V                  ; as we move up and away from the sun's centre

 CPX K                  ; If V >= K then we have reached the top of the sun (as
 BCS dsun26             ; K is the sun's radius, so there are K pixel lines in
                        ; each half of the sun), so jump to dsun26 to draw the
                        ; lines that we have calculated so far for this tile row

.dsun17

 JSR PLFL               ; Call PLFL to set A to the half-width of the new sun on
                        ; the sun line given in V

 STA sunWidth1          ; Store the half-width of pixel row 1 in sunWidth1

 LDX V                  ; Increment V, the height of the sun that we use to work
 INX                    ; out the width, so this makes the line get less wide,
 STX V                  ; as we move up and away from the sun's centre

 CPX K                  ; If V >= K then we have reached the top of the sun (as
 BCS dsun27             ; K is the sun's radius, so there are K pixel lines in
                        ; each half of the sun), so jump to dsun27 to draw the
                        ; lines that we have calculated so far for this tile row

.dsun18

 JSR PLFL               ; Call PLFL to set A to the half-width of the new sun on
                        ; the sun line given in V

 STA sunWidth0          ; Store the half-width of pixel row 0 in sunWidth0

 LDX V                  ; Increment V, the height of the sun that we use to work
 INX                    ; out the width, so this makes the line get less wide,
 STX V                  ; as we move up and away from the sun's centre

 CPX K                  ; If V >= K then we have reached the top of the sun (as
 BCS dsun28             ; K is the sun's radius, so there are K pixel lines in
                        ; each half of the sun), so jump to dsun28 to draw the
                        ; lines that we have calculated so far for this tile row

.dsun19

 JSR dsun28             ; Call dsun28 to draw all eight lines for this tile row

 TYA                    ; Set Y = Y - 8 to move up a tile row
 SEC
 SBC #8
 TAY

 BCC dsun20             ; If the subtraction underflowed, then Y is negative
                        ; and is therefore off the top of the screen, so jump to
                        ; dsun20 to return from the subroutine

 JMP dsun11             ; Otherwise we still have work to do, so jump up to
                        ; dsun11 to keep working our way up the top half of the
                        ; sun

.dsun20

 RTS                    ; Return from the subroutine

.dsun21

                        ; If we jump here then we have reached the top of the
                        ; sun and only need to draw pixel row 7 in the current
                        ; tile row, so we zero sunWidth0 through sunWidth6

 LDA #0                 ; Zero sunWidth6
 STA sunWidth6

.dsun22

                        ; If we jump here then we have reached the top of the
                        ; sun and need to draw pixel rows 6 and 7 in the current
                        ; tile row, so we zero sunWidth0 through sunWidth5

 LDA #0                 ; Zero sunWidth5
 STA sunWidth5

.dsun23

                        ; If we jump here then we have reached the top of the
                        ; sun and need to draw pixel rows 5 to 7 in the current
                        ; tile row, so we zero sunWidth0 through sunWidth4

 LDA #0                 ; Zero sunWidth4
 STA sunWidth4

.dsun24

                        ; If we jump here then we have reached the top of the
                        ; sun and need to draw pixel rows 4 to 7 in the current
                        ; tile row, so we zero sunWidth0 through sunWidth3

 LDA #0                 ; Zero sunWidth3
 STA sunWidth3

.dsun25

                        ; If we jump here then we have reached the top of the
                        ; sun and need to draw pixel rows 3 to 7 in the current
                        ; tile row, so we zero sunWidth0 through sunWidth2

 LDA #0                 ; Zero sunWidth2
 STA sunWidth2

.dsun26

                        ; If we jump here then we have reached the top of the
                        ; sun and need to draw pixel rows 2 to 7 in the current
                        ; tile row, so we zero sunWidth0 through sunWidth1

 LDA #0                 ; Zero sunWidth1
 STA sunWidth1

.dsun27

                        ; If we jump here then we have reached the top of the
                        ; sun and need to draw pixel rows 1 to 7 in the current
                        ; tile row, so we zero sunWidth0

 LDA #0                 ; Zero sunWidth0
 STA sunWidth0

                        ; So by this point sunWidth0 through sunWidth7 are set
                        ; up with the correct widths that we need to draw on
                        ; each pixel row of the current tile row, with some of
                        ; them possibly set to zero

                        ; We now fall through into dsun28 to draw these eight
                        ; pixel rows and return from the subroutine

.dsun28

                        ; If we jump here with a branch instruction or fall
                        ; through from above, then we have reached the top of
                        ; the sun and need to draw pixel rows 0 to 7 in the
                        ; current tile row, and then we are done drawing
                        ;
                        ; If we call this code as a subroutine using JSR dsun28
                        ; then we need to draw pixel rows 0 to 7 in the current
                        ; tile row, and when we return from the call we keep
                        ; drawing rows
                        ;
                        ; In either case, we now need to draw all eight rows
                        ; before returning from the subroutine
                        ;
                        ; We start by finding the smallest width out of
                        ; sunWidth0 through sunWidth7

 LDA sunWidth0          ; Set A to sunWidth0 as our starting point

 CMP sunWidth1          ; If A >= sunWidth1 then set A = sunWidth1, so this sets
 BCC dsun29             ; A = min(A, sunWidth1)
 LDA sunWidth1

.dsun29

 CMP sunWidth2          ; If A >= sunWidth2 then set A = sunWidth2, so this sets
 BCC dsun30             ; A = min(A, sunWidth2)
 LDA sunWidth2

.dsun30

 CMP sunWidth3          ; If A >= sunWidth3 then set A = sunWidth3, so this sets
 BCC dsun31             ; A = min(A, sunWidth3)
 LDA sunWidth2

.dsun31

 CMP sunWidth4          ; If A >= sunWidth4 then set A = sunWidth4, so this sets
 BCC dsun32             ; A = min(A, sunWidth4)
 LDA sunWidth4

.dsun32

 CMP sunWidth5          ; If A >= sunWidth5 then set A = sunWidth5, so this sets
 BCC dsun33             ; A = min(A, sunWidth5)
 LDA sunWidth5

.dsun33

 CMP sunWidth6          ; If A >= sunWidth6 then set A = sunWidth6, so this sets
 BCC dsun34             ; A = min(A, sunWidth6)
 LDA sunWidth6

.dsun34

 CMP sunWidth7          ; If A >= sunWidth7 then set A = sunWidth7, so this sets
 BCC dsun35             ; A = min(A, sunWidth7)
 LDA sunWidth7

                        ; So by this point A = min(sunWidth0 to sunWidth7), and
                        ; we can now check to see if we can save time by drawing
                        ; a portion of this tile row out of filled blocks

 BEQ dsun37             ; If A = 0 then at least one of the pixel rows needs to
                        ; be left blank, so we can't draw the row using filled
                        ; blocks, so jump to dsun37 to draw the tile row one
                        ; pixel row at a time

.dsun35

 JSR EDGES              ; Call EDGES to calculate X1 and X2 for the horizontal
                        ; line centred on YY(1 0) and with half-width A, clipped
                        ; to fit on-screen if necessary, so this gives us the
                        ; coordinates of the smallest pixel row in the tile row
                        ; that we want to draw

 BCS dsun37             ; If the C flag is set, then the smallest pixel row
                        ; is off-screen, so jump to dsun37 to draw the tile row
                        ; one pixel row at a time, as there is at least one
                        ; pixel row in the tile row that doesn't need drawing

                        ; If we get here then every pixel row in the tile row
                        ; fits on-screen and contains some sun pixels, so we
                        ; can now work out how to draw this row using filled
                        ; tiles where possible
                        ;
                        ; We do this by breaking the line up into a tile at the
                        ; left end of the row, a tile at the right end of the
                        ; row, and a set of filled tiles in the middle
                        ;
                        ; We set P and P+1 to the pixel coordinates of the block
                        ; of filled tiles in the middle

 LDA X2                 ; Set P+1 to the x-coordinate of the right end of the
 AND #%11111000         ; smallest sun line by clearing bits 0-2 of X2, giving
 STA P+1                ; P+1 = (X2 div 8) * 8
                        ;
                        ; This gives us what we want as each tile is 8 pixels
                        ; wide

 LDA X1                 ; Now to calculate the x-coordinate of the left end of
 ADC #7                 ; the filled tiles, so set A = X1 + 7 (we know the C
                        ; flag is clear for the addition as we just passed
                        ; through a BCS)

 BCS dsun37             ; If the addition overflowed, then this addition pushes
                        ; us past the right edge of the screen, so jump to
                        ; dsun37 to draw the tile row one pixel row at a time as
                        ; there isn't any room for filled tiles

 AND #%11111000         ; Clear bits 0-2 of A to give us the x-coordinate of the
                        ; left end of the set of filled tiles

 CMP P+1                ; If A >= P+1 then there is no room for any filled as
 BCS dsun37             ; the entire line fits into one tile, so jump to dsun37
                        ; to draw the tile row one pixel row at a time

 STA P                  ; Otherwise we now have valid values for the
                        ; x-coordinate range of the filled blocks in the
                        ; middle of the row, so store A in P so the coordinate
                        ; range is from P to P+1

 CMP #248               ; If A >= 248 then we only have room for one block on
 BCS dsun36             ; this row, and it's at the right edge of the screen,
                        ; so jump to dsun36 to skip the right and middle tiles
                        ; and just draw the tile at the left end of the row

 JSR dsun47             ; Call dsun47 to draw the tile at the right end of this
                        ; tile row

 JSR DrawSunRowOfBlocks ; Draw the tiles containing the horizontal line (P, Y)
                        ; to (P+1, Y) with filled blocks, silhouetting any
                        ; existing content against the sun

.dsun36

 JMP dsun46             ; Jump to dsun46 to draw the tile at the left end of
                        ; this tile row, returning from the subroutine using a
                        ; tail call as we have now drawn the middle of the row,
                        ; plus both ends

.dsun37

                        ; If we get here then we draw the current tile row one
                        ; pixel row at a time

 SETUP_PPU_FOR_ICON_BAR ; If the PPU has started drawing the icon bar, configure
                        ; the PPU to use nametable 0 and pattern table 0

 TYA                    ; Set Y = Y + 7
 CLC                    ;
 ADC #7                 ; We draw the lines from row 7 up the screen to row 0,
 TAY                    ; so this sets Y to the pixel y-coordinate of row 7

 LDA sunWidth7          ; Call EDGES-2 to calculate X1 and X2 for the horizontal
 JSR EDGES-2            ; line centred on YY(1 0) and with half-width sunWidth7,
                        ; which is the pixel line for row 7 in the tile row
                        ;
                        ; Calling EDGES-2 will set the C flag if A = 0, which
                        ; isn't the case for a straight call to EDGES

 BCS dsun38             ; If the C flag is set then either A = 0 (in which case
                        ; there is no sun line on this pixel row), or the line
                        ; does not fit on-screen, so in either case skip the
                        ; following instruction and move on to the next pixel
                        ; row

 JSR HLOIN              ; Draw a horizontal line from (X1, Y) to (X2, Y) to draw
                        ; pixel row 7 of the sun on this tile row, using EOR
                        ; logic so anything already on-screen appears as a
                        ; silhouette in front of the sun

.dsun38

 DEY                    ; Decrement the pixel y-coordinate in Y to row 6 in the
                        ; tile row

 LDA sunWidth6          ; Call EDGES-2 to calculate X1 and X2 for the horizontal
 JSR EDGES-2            ; line centred on YY(1 0) and with half-width sunWidth6,
                        ; which is the pixel line for row 6 in the tile row
                        ;
                        ; Calling EDGES-2 will set the C flag if A = 0, which
                        ; isn't the case for a straight call to EDGES

 BCS dsun39             ; If the C flag is set then either A = 0 (in which case
                        ; there is no sun line on this pixel row), or the line
                        ; does not fit on-screen, so in either case skip the
                        ; following instruction and move on to the next pixel
                        ; row

 JSR HLOIN              ; Draw a horizontal line from (X1, Y) to (X2, Y) to draw
                        ; pixel row 6 of the sun on this tile row, using EOR
                        ; logic so anything already on-screen appears as a
                        ; silhouette in front of the sun

.dsun39

 DEY                    ; Decrement the pixel y-coordinate in Y to row 5 in the
                        ; tile row

 LDA sunWidth5          ; Call EDGES-2 to calculate X1 and X2 for the horizontal
 JSR EDGES-2            ; line centred on YY(1 0) and with half-width sunWidth5,
                        ; which is the pixel line for row 5 in the tile row
                        ;
                        ; Calling EDGES-2 will set the C flag if A = 0, which
                        ; isn't the case for a straight call to EDGES
 BCS dsun40             ; If the C flag is set then either A = 0 (in which case
                        ; there is no sun line on this pixel row), or the line
                        ; does not fit on-screen, so in either case skip the
                        ; following instruction and move on to the next pixel
                        ; row

 JSR HLOIN              ; Draw a horizontal line from (X1, Y) to (X2, Y) to draw
                        ; pixel row 5 of the sun on this tile row, using EOR
                        ; logic so anything already on-screen appears as a
                        ; silhouette in front of the sun

.dsun40

 DEY                    ; Decrement the pixel y-coordinate in Y to row 4 in the
                        ; tile row

 LDA sunWidth4          ; Call EDGES-2 to calculate X1 and X2 for the horizontal
 JSR EDGES-2            ; line centred on YY(1 0) and with half-width sunWidth4,
                        ; which is the pixel line for row 4 in the tile row
                        ;
                        ; Calling EDGES-2 will set the C flag if A = 0, which
                        ; isn't the case for a straight call to EDGES
 BCS dsun41             ; If the C flag is set then either A = 0 (in which case
                        ; there is no sun line on this pixel row), or the line
                        ; does not fit on-screen, so in either case skip the
                        ; following instruction and move on to the next pixel
                        ; row

 JSR HLOIN              ; Draw a horizontal line from (X1, Y) to (X2, Y) to draw
                        ; pixel row 4 of the sun on this tile row, using EOR
                        ; logic so anything already on-screen appears as a
                        ; silhouette in front of the sun

.dsun41

 DEY                    ; Decrement the pixel y-coordinate in Y to row 3 in the
                        ; tile row

 LDA sunWidth3          ; Call EDGES-2 to calculate X1 and X2 for the horizontal
 JSR EDGES-2            ; line centred on YY(1 0) and with half-width sunWidth3,
                        ; which is the pixel line for row 3 in the tile row
                        ;
                        ; Calling EDGES-2 will set the C flag if A = 0, which
                        ; isn't the case for a straight call to EDGES
 BCS dsun42             ; If the C flag is set then either A = 0 (in which case
                        ; there is no sun line on this pixel row), or the line
                        ; does not fit on-screen, so in either case skip the
                        ; following instruction and move on to the next pixel
                        ; row

 JSR HLOIN              ; Draw a horizontal line from (X1, Y) to (X2, Y) to draw
                        ; pixel row 3 of the sun on this tile row, using EOR
                        ; logic so anything already on-screen appears as a
                        ; silhouette in front of the sun

.dsun42

 DEY                    ; Decrement the pixel y-coordinate in Y to row 2 in the
                        ; tile row

 LDA sunWidth2          ; Call EDGES-2 to calculate X1 and X2 for the horizontal
 JSR EDGES-2            ; line centred on YY(1 0) and with half-width sunWidth2,
                        ; which is the pixel line for row 2 in the tile row
                        ;
                        ; Calling EDGES-2 will set the C flag if A = 0, which
                        ; isn't the case for a straight call to EDGES
 BCS dsun43             ; If the C flag is set then either A = 0 (in which case
                        ; there is no sun line on this pixel row), or the line
                        ; does not fit on-screen, so in either case skip the
                        ; following instruction and move on to the next pixel
                        ; row

 JSR HLOIN              ; Draw a horizontal line from (X1, Y) to (X2, Y) to draw
                        ; pixel row 2 of the sun on this tile row, using EOR
                        ; logic so anything already on-screen appears as a
                        ; silhouette in front of the sun

.dsun43

 DEY                    ; Decrement the pixel y-coordinate in Y to row 1 in the
                        ; tile row

 LDA sunWidth1          ; Call EDGES-2 to calculate X1 and X2 for the horizontal
 JSR EDGES-2            ; line centred on YY(1 0) and with half-width sunWidth1,
                        ; which is the pixel line for row 1 in the tile row
                        ;
                        ; Calling EDGES-2 will set the C flag if A = 0, which
                        ; isn't the case for a straight call to EDGES
 BCS dsun44             ; If the C flag is set then either A = 0 (in which case
                        ; there is no sun line on this pixel row), or the line
                        ; does not fit on-screen, so in either case skip the
                        ; following instruction and move on to the next pixel
                        ; row

 JSR HLOIN              ; Draw a horizontal line from (X1, Y) to (X2, Y) to draw
                        ; pixel row 1 of the sun on this tile row, using EOR
                        ; logic so anything already on-screen appears as a
                        ; silhouette in front of the sun

.dsun44

 DEY                    ; Decrement the pixel y-coordinate in Y to row 0 in the
                        ; tile row

 LDA sunWidth0          ; Call EDGES-2 to calculate X1 and X2 for the horizontal
 JSR EDGES-2            ; line centred on YY(1 0) and with half-width sunWidth0,
                        ; which is the pixel line for row 0 in the tile row
                        ;
                        ; Calling EDGES-2 will set the C flag if A = 0, which
                        ; isn't the case for a straight call to EDGES
 BCS dsun45             ; If the C flag is set then either A = 0 (in which case
                        ; there is no sun line on this pixel row), or the line
                        ; does not fit on-screen, so in either case skip the
                        ; following instruction and return from the subroutine
                        ; as we are done

 JMP HLOIN              ; Draw a horizontal line from (X1, Y) to (X2, Y) to draw
                        ; pixel row 0 of the sun on this tile row, using EOR
                        ; logic so anything already on-screen appears as a
                        ; silhouette in front of the sun, and return from the
                        ; subroutine using a tail call as we have now drawn all
                        ; the lines in this row

.dsun45

 RTS                    ; Return from the subroutine

.dsun46

                        ; If we get here then we need to draw the tile at the
                        ; left end of the current tile row

 SETUP_PPU_FOR_ICON_BAR ; If the PPU has started drawing the icon bar, configure
                        ; the PPU to use nametable 0 and pattern table 0

 LDX P                  ; Set X to P, the x-coordinate of the left end of the
                        ; middle part of the sun row (which is the same as the
                        ; x-coordinate just to the right of the leftmost tile)

 BEQ dsun45             ; If X = 0 then the leftmost tile is off the left of the
                        ; screen, so jump to dsun45 to return from the
                        ; subroutine

 TYA                    ; Set Y = Y + 7
 CLC                    ;
 ADC #7                 ; We draw the lines from row 7 up the screen to row 0,
 TAY                    ; so this sets Y to the pixel y-coordinate of row 7

 LDA sunWidth7          ; Draw a pixel byte for the left edge of the sun at the
 JSR DrawSunEdgeLeft    ; left end of pixel row 7

 DEY                    ; Decrement the pixel y-coordinate in Y to row 6 in the
                        ; tile row

 LDA sunWidth6          ; Draw a pixel byte for the left edge of the sun at the
 JSR DrawSunEdgeLeft    ; left end of pixel row 6

 DEY                    ; Decrement the pixel y-coordinate in Y to row 5 in the
                        ; tile row

 LDA sunWidth5          ; Draw a pixel byte for the left edge of the sun at the
 JSR DrawSunEdgeLeft    ; left end of pixel row 5

 DEY                    ; Decrement the pixel y-coordinate in Y to row 4 in the
                        ; tile row

 LDA sunWidth4          ; Draw a pixel byte for the left edge of the sun at the
 JSR DrawSunEdgeLeft    ; left end of pixel row 4

 DEY                    ; Decrement the pixel y-coordinate in Y to row 3 in the
                        ; tile row

 LDA sunWidth3          ; Draw a pixel byte for the left edge of the sun at the
 JSR DrawSunEdgeLeft    ; left end of pixel row 3

 DEY                    ; Decrement the pixel y-coordinate in Y to row 2 in the
                        ; tile row

 LDA sunWidth2          ; Draw a pixel byte for the left edge of the sun at the
 JSR DrawSunEdgeLeft    ; left end of pixel row 2

 DEY                    ; Decrement the pixel y-coordinate in Y to row 1 in the
                        ; tile row

 LDA sunWidth1          ; Draw a pixel byte for the left edge of the sun at the
 JSR DrawSunEdgeLeft    ; left end of pixel row 1

 DEY                    ; Decrement the pixel y-coordinate in Y to row 0 in the
                        ; tile row

 LDA sunWidth0          ; Draw a pixel byte for the left edge of the sun at the
 JMP DrawSunEdgeLeft    ; left end of pixel row 0 and return from the subroutine
                        ; using a tail call

.dsun47

                        ; If we get here then we need to draw the tile at the
                        ; right end of the current tile row

 SETUP_PPU_FOR_ICON_BAR ; If the PPU has started drawing the icon bar, configure
                        ; the PPU to use nametable 0 and pattern table 0

 LDX P+1                ; Set X1 to P+1, the x-coordinate of the right end of
 STX X1                 ; the middle part of the sun row (which is the same as
                        ; x-coordinate of the left end of the rightmost tile)

 TYA                    ; Set Y = Y + 7
 CLC                    ;
 ADC #7                 ; We draw the lines from row 7 up the screen to row 0,
 TAY                    ; so this sets Y to the pixel y-coordinate of row 7

 LDA sunWidth7          ; Draw a pixel byte for the right edge of the sun at the
 JSR DrawSunEdgeRight   ; right end of pixel row 7

 DEY                    ; Decrement the pixel y-coordinate in Y to row 6 in the
                        ; tile row

 LDA sunWidth6          ; Draw a pixel byte for the right edge of the sun at the
 JSR DrawSunEdgeRight   ; right end of pixel row 6

 DEY                    ; Decrement the pixel y-coordinate in Y to row 5 in the
                        ; tile row

 LDA sunWidth5          ; Draw a pixel byte for the right edge of the sun at the
 JSR DrawSunEdgeRight   ; right end of pixel row 5

 DEY                    ; Decrement the pixel y-coordinate in Y to row 4 in the
                        ; tile row

 LDA sunWidth4          ; Draw a pixel byte for the right edge of the sun at the
 JSR DrawSunEdgeRight   ; right end of pixel row 4

 DEY                    ; Decrement the pixel y-coordinate in Y to row 3 in the
                        ; tile row

 LDA sunWidth3          ; Draw a pixel byte for the right edge of the sun at the
 JSR DrawSunEdgeRight   ; right end of pixel row 3

 DEY                    ; Decrement the pixel y-coordinate in Y to row 2 in the
                        ; tile row

 LDA sunWidth1          ; Draw a pixel byte for the right edge of the sun at the
 JSR DrawSunEdgeRight   ; right end of pixel row 2
                        ;
                        ; This appears to be a bug (though one you would be
                        ; hard-pressed to detect from looking at the screen), as
                        ; we should probably be loading sunWidth2 here, not
                        ; sunWidth1
                        ;
                        ; As it stands, on each tile row of the sun, the right
                        ; edge always has matching lines on pixel rows 1 and 2

 DEY                    ; Decrement the pixel y-coordinate in Y to row 1 in the
                        ; tile row

 LDA sunWidth1          ; Draw a pixel byte for the right edge of the sun at the
 JSR DrawSunEdgeRight   ; right end of pixel row 1

 DEY                    ; Decrement the pixel y-coordinate in Y to row 0 in the
                        ; tile row

 LDA sunWidth0          ; Draw a pixel byte for the right edge of the sun at the
 JMP DrawSunEdgeRight   ; right end of pixel row 0 and return from the
                        ; subroutine using a tail call

; ******************************************************************************
;
;       Name: PLFL
;       Type: Subroutine
;   Category: Drawing suns
;    Summary: Calculate the sun's width on a given pixel row
;  Deep dive: Drawing the sun
;
; ------------------------------------------------------------------------------
;
; This part calculate the sun's width on a given pixel row.
;
; Arguments:
;
;   V                   As we draw lines for the new sun, V contains the
;                       vertical distance between the line we're drawing and the
;                       centre of the new sun. As we draw lines and move up the
;                       screen, we either decrement (bottom half) or increment
;                       (top half) this value. See the deep dive on "Drawing the
;                       sun" to see a diagram that shows V in action
;
;   V+1                 This determines which half of the new sun we are drawing
;                       as we work our way up the screen, line by line:
;
;                         * 0 means we are drawing the bottom half, so the lines
;                           get wider as we work our way up towards the centre,
;                           at which point we will move into the top half, and
;                           V+1 will switch to $FF
;
;                         * $FF means we are drawing the top half, so the lines
;                           get smaller as we work our way up, away from the
;                           centre
;
;   TGT                 The maximum y-coordinate of the new sun on-screen (i.e.
;                       the screen y-coordinate of the bottom row of the new
;                       sun)
;
;   CNT                 The fringe size of the new sun
;
;   K2(1 0)             The new sun's radius squared, i.e. K^2
;
;   Y                   The y-coordinate of the bottom row of the new sun
;
; Returns:
;
;   A                   The half-width of the sun on the line specified in V
;
; Other entry points:
;
;   RTS2                Contains an RTS
;
; ******************************************************************************

.PLFL

 SETUP_PPU_FOR_ICON_BAR ; If the PPU has started drawing the icon bar, configure
                        ; the PPU to use nametable 0 and pattern table 0

 STY Y1                 ; Store Y in Y1, so we can restore it after the call to
                        ; LL5

 LDA V                  ; Set (T P) = V * V
 JSR SQUA2              ;           = V^2
 STA T

 LDA K2                 ; Set (R Q) = K^2 - V^2
 SEC                    ;
 SBC P                  ; First calculating the low bytes
 STA Q

 LDA K2+1               ; And then doing the high bytes
 SBC T
 STA R

 JSR LL5                ; Set Q = SQRT(R Q)
                        ;       = SQRT(K^2 - V^2)
                        ;
                        ; So Q contains the half-width of the new sun's line at
                        ; height V from the sun's centre - in other words, it
                        ; contains the half-width of the sun's line on the
                        ; current pixel row Y

 LDY Y1                 ; Restore Y from Y1

 SETUP_PPU_FOR_ICON_BAR ; If the PPU has started drawing the icon bar, configure
                        ; the PPU to use nametable 0 and pattern table 0

 JSR DORND              ; Set A and X to random numbers

 AND CNT                ; Reduce A to a random number in the range 0 to CNT,
                        ; where CNT is the fringe size of the new sun

 LDY Y1                 ; Restore Y from Y1

 CLC                    ; Set A = A + Q
 ADC Q                  ;
                        ; So A now contains the half-width of the sun on row
                        ; V, plus a random variation based on the fringe size

 BCC RTS2               ; If the above addition did not overflow then

 LDA #255               ; The above overflowed, so set the value of A to 255

                        ; So A contains the half-width of the new sun on pixel
                        ; line Y, changed by a random amount within the size of
                        ; the sun's fringe

.RTS2

 RTS                    ; Return from the subroutine

; ******************************************************************************
;
;       Name: CIRCLE
;       Type: Subroutine
;   Category: Drawing circles
;    Summary: Draw a circle for the planet
;  Deep dive: Drawing circles
;
; ------------------------------------------------------------------------------
;
; Draw a circle with the centre at (K3, K4) and radius K. Used to draw the
; planet's main outline.
;
; Arguments:
;
;   K                   The planet's radius
;
;   K3(1 0)             Pixel x-coordinate of the centre of the planet
;
;   K4(1 0)             Pixel y-coordinate of the centre of the planet
;
; ******************************************************************************

.CIRCLE

 SETUP_PPU_FOR_ICON_BAR ; If the PPU has started drawing the icon bar, configure
                        ; the PPU to use nametable 0 and pattern table 0

 JSR CHKON              ; Call CHKON to check whether the circle fits on-screen

 BCS RTS2               ; If CHKON set the C flag then the circle does not fit
                        ; on-screen, so return from the subroutine (as RTS2
                        ; contains an RTS)

 LDX K                  ; Set X = K = radius

 LDA #8                 ; Set A = 8

 CPX #8                 ; If the radius < 8, skip to PL89
 BCC PL89

 LSR A                  ; Halve A so A = 4

 CPX #60                ; If the radius < 60, skip to PL89
 BCC PL89

 LSR A                  ; Halve A so A = 2

.PL89

 STA STP                ; Set STP = A. STP is the step size for the circle, so
                        ; the above sets a smaller step size for bigger circles

                        ; Fall through into CIRCLE2 to draw the circle with the
                        ; correct step size

; ******************************************************************************
;
;       Name: CIRCLE2
;       Type: Subroutine
;   Category: Drawing circles
;    Summary: Draw a circle (for the planet or chart)
;  Deep dive: Drawing circles
;
; ------------------------------------------------------------------------------
;
; Draw a circle with the centre at (K3, K4) and radius K. Used to draw the
; planet and the chart circles.
;
; Arguments:
;
;   STP                 The step size for the circle
;
;   K                   The circle's radius
;
;   K3(1 0)             Pixel x-coordinate of the centre of the circle
;
;   K4(1 0)             Pixel y-coordinate of the centre of the circle
;
; Returns:
;
;   C flag              The C flag is cleared
;
; ******************************************************************************

.CIRCLE2

 LDX #$FF               ; Set FLAG = $FF to reset the ball line heap in the call
 STX FLAG               ; to the BLINE routine below

 INX                    ; Set CNT = 0, our counter that goes up to 64, counting
 STX CNT                ; segments in our circle

.PLL3

 LDA CNT                ; Set A = CNT

 JSR FMLTU2             ; Call FMLTU2 to calculate:
                        ;
                        ;   A = K * sin(A)
                        ;     = K * sin(CNT)

 LDX #0                 ; Set T = 0, so we have the following:
 STX T                  ;
                        ;   (T A) = K * sin(CNT)
                        ;
                        ; which is the x-coordinate of the circle for this count

 LDX CNT                ; If CNT < 33 then jump to PL37, as this is the right
 CPX #33                ; half of the circle and the sign of the x-coordinate is
 BCC PL37               ; correct

 EOR #%11111111         ; This is the left half of the circle, so we want to
 ADC #0                 ; flip the sign of the x-coordinate in (T A) using two's
 TAX                    ; complement, so we start with the low byte and store it
                        ; in X (the ADC adds 1 as we know the C flag is set)

 LDA #$FF               ; And then we flip the high byte in T
 ADC #0
 STA T

 TXA                    ; Finally, we restore the low byte from X, so we have
                        ; now negated the x-coordinate in (T A)

 CLC                    ; Clear the C flag so we can do some more addition below

.PL37

 ADC K3                 ; We now calculate the following:
 STA K6                 ;
                        ;   K6(1 0) = (T A) + K3(1 0)
                        ;
                        ; to add the coordinates of the centre to our circle
                        ; point, starting with the low bytes

 LDA K3+1               ; And then doing the high bytes, so we now have:
 ADC T                  ;
 STA K6+1               ;   K6(1 0) = K * sin(CNT) + K3(1 0)
                        ;
                        ; which is the result we want for the x-coordinate

 LDA CNT                ; Set A = CNT + 16
 CLC
 ADC #16

 JSR FMLTU2             ; Call FMLTU2 to calculate:
                        ;
                        ;   A = K * sin(A)
                        ;     = K * sin(CNT + 16)
                        ;     = K * cos(CNT)

 TAX                    ; Set X = A
                        ;       = K * cos(CNT)

 LDA #0                 ; Set T = 0, so we have the following:
 STA T                  ;
                        ;   (T X) = K * cos(CNT)
                        ;
                        ; which is the y-coordinate of the circle for this count

 LDA CNT                ; Set A = (CNT + 15) mod 64
 CLC
 ADC #15
 AND #63

 CMP #33                ; If A < 33 (i.e. CNT is 0-16 or 48-64) then jump to
 BCC PL38               ; PL38, as this is the bottom half of the circle and the
                        ; sign of the y-coordinate is correct

 TXA                    ; This is the top half of the circle, so we want to
 EOR #%11111111         ; flip the sign of the y-coordinate in (T X) using two's
 ADC #0                 ; complement, so we start with the low byte in X (the
 TAX                    ; ADC adds 1 as we know the C flag is set)

 LDA #$FF               ; And then we flip the high byte in T, so we have
 ADC #0                 ; now negated the y-coordinate in (T X)
 STA T

 CLC                    ; Clear the C flag so we can do some more addition below

.PL38

 JSR BLINE              ; Call BLINE to draw this segment, which also increases
                        ; CNT by STP, the step size

 CMP #65                ; If CNT >= 65 then skip the next instruction
 BCS P%+5

 JMP PLL3               ; Jump back for the next segment

 CLC                    ; Clear the C flag to indicate success

 RTS                    ; Return from the subroutine

; ******************************************************************************
;
;       Name: EDGES
;       Type: Subroutine
;   Category: Drawing lines
;    Summary: Draw a horizontal line given a centre and a half-width
;
; ------------------------------------------------------------------------------
;
; Set X1 and X2 to the x-coordinates of the ends of the horizontal line with
; centre x-coordinate YY(1 0), and length A in either direction from the centre
; (so a total line length of 2 * A). In other words, this line:
;
;   X1             YY(1 0)             X2
;   +-----------------+-----------------+
;         <- A ->           <- A ->
;
; The resulting line gets clipped to the edges of the screen, if needed. If the
; calculation doesn't overflow, we return with the C flag clear, otherwise the C
; flag gets set to indicate failure.
;
; Arguments:
;
;   A                   The half-length of the line
;
;   YY(1 0)             The centre x-coordinate
;
; Returns:
;
;   C flag              Clear if the line fits on-screen, set if it doesn't
;
;   X1, X2              The x-coordinates of the clipped line
;
;   Y                   Y is preserved
;
; Other entry points:
;
;   EDGES-2             Return the C flag set if argument A is 0
;
; ******************************************************************************

.ED3

 BPL ED1                ; We jump here with the status flags set to the result
                        ; of the high byte of this subtraction, and only if the
                        ; high byte is non-zero:
                        ;
                        ;   (A X1) = YY(1 0) - argument A
                        ;
                        ; If the result of the subtraction is positive and
                        ; non-zero then the coordinate is not on-screen, so jump
                        ; to ED1 to return the C flag set

 LDA #0                 ; The result of the subtraction is negative, so we have
 STA X1                 ; have gone past the left edge of the screen, so we clip
                        ; the x-coordinate in X1 to 0

 CLC                    ; Clear the C flag to indicate that the clipped line
                        ; fits on-screen

 RTS                    ; Return from the subroutine

.ED1

 SETUP_PPU_FOR_ICON_BAR ; If the PPU has started drawing the icon bar, configure
                        ; the PPU to use nametable 0 and pattern table 0

 SEC                    ; Set the C flag to indicate that the line does not fit
                        ; on-screen

 RTS                    ; Return from the subroutine

 BEQ ED1                ; If we call the routine at EDGES-2, this checks whether
                        ; the argument in A is zero, and if it is, it jumps to
                        ; ED1 to return the C flag set

.EDGES

 STA T                  ; Set T to the line's half-length in argument A

 CLC                    ; We now calculate:
 ADC YY                 ;
 STA X2                 ;  (A X2) = YY(1 0) + A
                        ;
                        ; to set X2 to the x-coordinate of the right end of the
                        ; line, starting with the low bytes

 LDA YY+1               ; And then adding the high bytes
 ADC #0

 BMI ED1                ; If the addition is negative then the calculation has
                        ; overflowed, so jump to ED1 to return a failure

 BEQ P%+6               ; If the high byte A from the result is 0, skip the
                        ; next two instructions, as the result already fits on
                        ; the screen

 LDA #253               ; The high byte is positive and non-zero, so we went
 STA X2                 ; past the right edge of the screen, so clip X2 to the
                        ; x-coordinate of the right edge of the screen

 LDA YY                 ; We now calculate:
 SEC                    ;
 SBC T                  ;   (A X1) = YY(1 0) - argument A
 STA X1                 ;
                        ; to set X1 to the x-coordinate of the left end of the
                        ; line, starting with the low bytes

 LDA YY+1               ; And then subtracting the high bytes
 SBC #0

 BNE ED3                ; If the high byte of the subtraction is non-zero, then
                        ; jump to ED3 to return a failure if the subtraction has
                        ; taken us off the left edge of the screen

 LDA X1                 ; Set the C flag if X1 >= X2, clear it if X1 < X2
 CMP X2                 ;
                        ; So this sets the C flag if the line doesn't fit on
                        ; the screen

 RTS                    ; Return from the subroutine

; ******************************************************************************
;
;       Name: DrawSunEdgeLeft
;       Type: Subroutine
;   Category: Drawing suns
;    Summary: Draw a sun line in the tile on the left end of a sun row
;
; ------------------------------------------------------------------------------
;
; Arguments:
;
;   A                   The half-width of the sun line
;
;   Y                   The number of the pixel row of the sun line within the
;                       tile row (0-7)
;
;   P                   The pixel x-coordinate of the start of the middle
;                       section of the sun line (i.e. the x-coordinate just to
;                       the right of the leftmost tile)
;
;   YY(1 0)             The centre x-coordinate of the sun
;
; Other entry points:
;
;   RTS7                Contains an RTS
;
;   DrawSunEdge         Draw a sun line from (X1, Y) to (X2, Y)
;
; ******************************************************************************

.DrawSunEdgeLeft

 LDX P                  ; Set X2 to P, which contains the x-coordinate just to
 STX X2                 ; the right of the leftmost tile
                        ;
                        ; We can use this as the x-coordinate of the right end
                        ; of the line that we want to draw in the leftmost tile

 EOR #$FF               ; Use two's complement to set X1 = YY(1 0) - A
 SEC                    ;
 ADC YY                 ; So X1 contains the x-coordinate of the left end of the
 STA X1                 ; sun line
 LDA YY+1
 ADC #$FF

 BEQ DrawSunEdge        ; If the high byte of the result is zero, then the left
                        ; end of the line is on-screen, so jump to DrawSunEdge
                        ; to draw the sun line from (X1, Y) to (X2, Y)

 BMI sunl1              ; If the high byte of the result is negative, then the
                        ; left end of the line is off the left edge of the
                        ; screen, so jump to sunl1 to draw a clipped sun line
                        ; from (0, Y) to (X2, Y)

                        ; Otherwise the line is off-screen, so return from the
                        ; subroutine without drawing anything

.RTS7

 RTS                    ; Return from the subroutine

.DrawSunEdge

 LDA X1                 ; If X1 >= X2 then the left end of the line is to the
 CMP X2                 ; right of the right end of the line, so these are not
 BCS RTS7               ; valid line coordinates and we jump to RTS7 to return
                        ; from the subroutine without drawing anything

 JMP HLOIN              ; Otherwise draw the sun line from (X1, Y) to (X2, Y)
                        ; and return from the subroutine using a tail call

.sunl1

                        ; If we get here then we need to clip the left end of
                        ; the line to fit on-screen

 LDA #0                 ; Draw a clipped the sun line from (0, Y) to (X2, Y)
 STA X1                 ; and return from the subroutine using a tail call
 JMP HLOIN

; ******************************************************************************
;
;       Name: DrawSunEdgeRight
;       Type: Subroutine
;   Category: Drawing suns
;    Summary: Draw a sun line in the tile on the right end of a sun row
;
; ------------------------------------------------------------------------------
;
; Arguments:
;
;   A                   The half-width of the sun line
;
;   Y                   The number of the pixel row of the sun line within the
;                       tile row (0-7)
;
;   X1                  The pixel x-coordinate of the rightmost tile on the sun
;                       line
;
;   YY(1 0)             The centre x-coordinate of the sun
;
; ******************************************************************************

.DrawSunEdgeRight

 CLC                    ; Set X1 = YY(1 0) + A
 ADC YY                 ;
 STA X2                 ; So X2 contains the x-coordinate of the right end of
 LDA YY+1               ; the sun line
 ADC #0

                        ; X1 is already set to the x-coordinate of the rightmost
                        ; tile, so the line we need to draw is from (X1, Y) to
                        ; (X2, Y)

 BEQ DrawSunEdge        ; If the high byte of the result is zero, then the right
                        ; end of the line is on-screen, so jump to DrawSunEdge
                        ; to draw the sun line from (X1, Y) to (X2, Y)

 BMI RTS7               ; If the high byte of the result is negative, then the
                        ; right end of the line is off the left edge of the
                        ; screen, so the line is not on-screen and we jump to
                        ; RTS7 to return from the subroutine (as RTS7 contains
                        ; an RTS)

                        ; If we get here then the right end of the line is past
                        ; the right edge of the screen, so we need to clip the
                        ; right end of the line to fit on-screen

 LDA #253               ; Set X2 = 253 so the line is clipped to the right edge
 STA X2                 ; of the screen

 CMP X1                 ; If X2 <= X1 then the right end of the line is to the
 BEQ RTS7               ; left of the left end of the line, so these are not
 BCC RTS7               ; valid line coordinates and we jump to RTS7 to return
                        ; from the subroutine without drawing anything

 JMP HLOIN              ; Otherwise draw the sun line from (X1, Y) to (X2, Y)
                        ; and return from the subroutine using a tail call

; ******************************************************************************
;
;       Name: CHKON
;       Type: Subroutine
;   Category: Drawing circles
;    Summary: Check whether any part of a circle appears on the extended screen
;
; ------------------------------------------------------------------------------
;
; Arguments:
;
;   K                   The circle's radius
;
;   K3(1 0)             Pixel x-coordinate of the centre of the circle
;
;   K4(1 0)             Pixel y-coordinate of the centre of the circle
;
; Returns:
;
;   C flag              Clear if any part of the circle appears on-screen, set
;                       if none of the circle appears on-screen
;
;   (A X)               Minimum y-coordinate of the circle on-screen (i.e. the
;                       y-coordinate of the top edge of the circle)
;
;   P(2 1)              Maximum y-coordinate of the circle on-screen (i.e. the
;                       y-coordinate of the bottom edge of the circle)
;
; ******************************************************************************

.CHKON

 LDA K3                 ; Set A = K3 + K
 CLC
 ADC K

 LDA K3+1               ; Set A = K3+1 + 0 + any carry from above, so this
 ADC #0                 ; effectively sets A to the high byte of K3(1 0) + K:
                        ;
                        ;   (A ?) = K3(1 0) + K
                        ;
                        ; so A is the high byte of the x-coordinate of the right
                        ; edge of the circle

 BMI PL21               ; If A is negative then the right edge of the circle is
                        ; to the left of the screen, so jump to PL21 to set the
                        ; C flag and return from the subroutine, as the whole
                        ; circle is off-screen to the left

 LDA K3                 ; Set A = K3 - K
 SEC
 SBC K

 LDA K3+1               ; Set A = K3+1 - 0 - any carry from above, so this
 SBC #0                 ; effectively sets A to the high byte of K3(1 0) - K:
                        ;
                        ;   (A ?) = K3(1 0) - K
                        ;
                        ; so A is the high byte of the x-coordinate of the left
                        ; edge of the circle

 BMI PL31               ; If A is negative then the left edge of the circle is
                        ; to the left of the screen, and we already know the
                        ; right edge is either on-screen or off-screen to the
                        ; right, so skip to PL31 to move on to the y-coordinate
                        ; checks, as at least part of the circle is on-screen in
                        ; terms of the x-axis

 BNE PL21               ; If A is non-zero, then the left edge of the circle is
                        ; to the right of the screen, so jump to PL21 to set the
                        ; C flag and return from the subroutine, as the whole
                        ; circle is off-screen to the right

.PL31

 LDA K4                 ; Set P+1 = K4 + K
 CLC
 ADC K
 STA P+1

 LDA K4+1               ; Set A = K4+1 + 0 + any carry from above, so this
 ADC #0                 ; does the following:
                        ;
                        ;   (A P+1) = K4(1 0) + K
                        ;
                        ; so A is the high byte of the y-coordinate of the
                        ; bottom edge of the circle

 BMI PL21               ; If A is negative then the bottom edge of the circle is
                        ; above the top of the screen, so jump to PL21 to set
                        ; the C flag and return from the subroutine, as the
                        ; whole circle is off-screen to the top

 STA P+2                ; Store the high byte in P+2, so now we have:
                        ;
                        ;   P(2 1) = K4(1 0) + K
                        ;
                        ; i.e. the maximum y-coordinate of the circle on-screen
                        ; (which we return)

 LDA K4                 ; Set X = K4 - K
 SEC
 SBC K
 TAX

 LDA K4+1               ; Set A = K4+1 - 0 - any carry from above, so this
 SBC #0                 ; does the following:
                        ;
                        ;   (A X) = K4(1 0) - K
                        ;
                        ; so A is the high byte of the y-coordinate of the top
                        ; edge of the circle

 BMI PL44               ; If A is negative then the top edge of the circle is
                        ; above the top of the screen, and we already know the
                        ; bottom edge is either on-screen or below the bottom
                        ; of the screen, so skip to PL44 to clear the C flag and
                        ; return from the subroutine using a tail call, as part
                        ; of the circle definitely appears on-screen

 BNE PL21               ; If A is non-zero, then the top edge of the circle is
                        ; below the bottom of the screen, so jump to PL21 to set
                        ; the C flag and return from the subroutine, as the
                        ; whole circle is off-screen to the bottom

 CPX Yx2M1              ; If we get here then A is zero, which means the top
                        ; edge of the circle is within the screen boundary, so
                        ; now we need to check whether it is in the space view
                        ; (in which case it is on-screen) or the dashboard (in
                        ; which case the top of the circle is hidden by the
                        ; dashboard, so the circle isn't on-screen). We do this
                        ; by checking the low byte of the result in X against
                        ; Yx2M1, and returning the C flag from this comparison.
                        ; The value in Yx2M1 is the y-coordinate of the bottom
                        ; pixel row of the space view, so this does the
                        ; following:
                        ;
                        ;   * The C flag is set if coordinate (A X) is below the
                        ;     bottom row of the space view, i.e. the top edge of
                        ;     the circle is hidden by the dashboard
                        ;
                        ;   * The C flag is clear if coordinate (A X) is above
                        ;     the bottom row of the space view, i.e. the top
                        ;     edge of the circle is on-screen

 RTS                    ; Return from the subroutine

; ******************************************************************************
;
;       Name: PL21
;       Type: Subroutine
;   Category: Drawing planets
;    Summary: Return from a planet/sun-drawing routine with a failure flag
;
; ------------------------------------------------------------------------------
;
; Set the C flag and return from the subroutine. This is used to return from a
; planet- or sun-drawing routine with the C flag indicating an overflow in the
; calculation.
;
; ******************************************************************************

.PL21

 SEC                    ; Set the C flag to indicate an overflow

 RTS                    ; Return from the subroutine

; ******************************************************************************
;
;       Name: PL44
;       Type: Subroutine
;   Category: Drawing planets
;    Summary: Return from a planet/sun-drawing routine with a success flag
;
; ------------------------------------------------------------------------------
;
; Clear the C flag and return from the subroutine. This is used to return from a
; planet- or sun-drawing routine with the C flag indicating an overflow in the
; calculation.
;
; ******************************************************************************

.PL44

 CLC                    ; Clear the C flag to indicate success

 RTS                    ; Return from the subroutine

; ******************************************************************************
;
;       Name: PLS3
;       Type: Subroutine
;   Category: Drawing planets
;    Summary: Calculate (Y A P) = 222 * roofv_x / z
;
; ------------------------------------------------------------------------------
;
; Calculate the following, with X determining the vector to use:
;
;   (Y A P) = 222 * roofv_x / z
;
; though in reality only (Y A) is used.
;
; Although the code below supports a range of values of X, in practice the
; routine is only called with X = 15, and then again after X has been
; incremented to 17. So the values calculated by PLS1 use roofv_x first, then
; roofv_y. The comments below refer to roofv_x, for the first call.
;
; Arguments:
;
;   X                   Determines which of the INWK orientation vectors to
;                       divide:
;
;                         * X = 15: divides roofv_x
;
;                         * X = 17: divides roofv_y
;
; Returns:
;
;   X                   X gets incremented by 2 so it points to the next
;                       coordinate in this orientation vector (so consecutive
;                       calls to the routine will start with x, then move onto y
;                       and then z)
;
; ******************************************************************************

.PLS3

 JSR PLS1               ; Call PLS1 to calculate the following:
 STA P                  ;
                        ;   P = |roofv_x / z|
                        ;   K+3 = sign of roofv_x / z
                        ;
                        ; and increment X to point to roofv_y for the next call

 LDA #222               ; Set Q = 222, the offset to the crater
 STA Q

 STX U                  ; Store the vector index X in U for retrieval after the
                        ; call to MULTU

 JSR MULTU              ; Call MULTU to calculate
                        ;
                        ;   (A P) = P * Q
                        ;         = 222 * |roofv_x / z|

 LDX U                  ; Restore the vector index from U into X

 LDY K+3                ; If the sign of the result in K+3 is positive, skip to
 BPL PL12               ; PL12 to return with Y = 0

 EOR #$FF               ; Otherwise the result should be negative, so negate the
 CLC                    ; high byte of the result using two's complement with
 ADC #1                 ; A = ~A + 1

 BEQ PL12               ; If A = 0, jump to PL12 to return with (Y A) = 0

 LDY #$FF               ; Set Y = $FF to be a negative high byte

 RTS                    ; Return from the subroutine

.PL12

 LDY #0                 ; Set Y = 0 to be a positive high byte

 RTS                    ; Return from the subroutine

; ******************************************************************************
;
;       Name: PLS4
;       Type: Subroutine
;   Category: Drawing planets
;    Summary: Calculate CNT2 = arctan(P / A) / 4
;
; ------------------------------------------------------------------------------
;
; Calculate the following:
;
;   CNT2 = arctan(P / A) / 4
;
; and do the following if nosev_z_hi >= 0:
;
;   CNT2 = CNT2 + 32
;
; which is the equivalent of adding 180 degrees to the result (or PI radians),
; as there are 64 segments in a full circle.
;
; This routine is called with the following arguments when calculating the
; equator and meridian for planets:
;
;   * A = roofv_z_hi, P = -nosev_z_hi
;
;   * A = sidev_z_hi, P = -nosev_z_hi
;
; So it calculates the angle between the planet's orientation vectors, in the
; z-axis.
;
; ******************************************************************************

.PLS4

 STA Q                  ; Set Q = A

 JSR ARCTAN             ; Call ARCTAN to calculate:
                        ;
                        ;   A = arctan(P / Q)
                        ;       arctan(P / A)
                        ;
                        ; The result in A will be in the range 0 to 128, which
                        ; represents an angle of 0 to 180 degrees (or 0 to PI
                        ; radians)

 LDX INWK+14            ; If nosev_z_hi is negative, skip the following
 BMI P%+4               ; instruction to leave the angle in A as a positive
                        ; integer in the range 0 to 128 (so when we calculate
                        ; CNT2 below, it will be in the right half of the
                        ; anti-clockwise arc that we describe when drawing
                        ; circles, i.e. from 6 o'clock, through 3 o'clock and
                        ; on to 12 o'clock)

 EOR #%10000000         ; If we get here then nosev_z_hi is positive, so flip
                        ; bit 7 of the angle in A, which is the same as adding
                        ; 128 to give a result in the range 129 to 256 (i.e. 129
                        ; to 0), or 180 to 360 degrees (so when we calculate
                        ; CNT2 below, it will be in the left half of the
                        ; anti-clockwise arc that we describe when drawing
                        ; circles, i.e. from 12 o'clock, through 9 o'clock and
                        ; on to 6 o'clock)

 LSR A                  ; Set CNT2 = A / 4
 LSR A
 STA CNT2

 RTS                    ; Return from the subroutine

; ******************************************************************************
;
;       Name: PLS5
;       Type: Subroutine
;   Category: Drawing planets
;    Summary: Calculate roofv_x / z and roofv_y / z
;
; ------------------------------------------------------------------------------
;
; Calculate the following divisions of a specified value from one of the
; orientation vectors (in this example, roofv):
;
;   (XX16+2 K2+2) = roofv_x / z
;
;   (XX16+3 K2+3) = roofv_y / z
;
; Arguments:
;
;   X                   Determines which of the INWK orientation vectors to
;                       divide:
;
;                         * X = 15: divides roofv_x and roofv_y
;
;                         * X = 21: divides sidev_x and sidev_y
;
;   INWK                The planet's ship data block
;
; ******************************************************************************

.PLS5

 JSR PLS1               ; Call PLS1 to calculate the following:
 STA K2+2               ;
 STY XX16+2             ;   K+2    = |roofv_x / z|
                        ;   XX16+2 = sign of roofv_x / z
                        ;
                        ; i.e. (XX16+2 K2+2) = roofv_x / z
                        ;
                        ; and increment X to point to roofv_y for the next call

 JSR PLS1               ; Call PLS1 to calculate the following:
 STA K2+3               ;
 STY XX16+3             ;   K+3    = |roofv_y / z|
                        ;   XX16+3 = sign of roofv_y / z
                        ;
                        ; i.e. (XX16+3 K2+3) = roofv_y / z
                        ;
                        ; and increment X to point to roofv_z for the next call

 RTS                    ; Return from the subroutine

; ******************************************************************************
;
;       Name: ARCTAN
;       Type: Subroutine
;   Category: Maths (Geometry)
;    Summary: Calculate A = arctan(P / Q)
;  Deep dive: The sine, cosine and arctan tables
;
; ------------------------------------------------------------------------------
;
; Calculate the following:
;
;   A = arctan(P / Q)
;
; In other words, this finds the angle in the right-angled triangle where the
; opposite side to angle A is length P and the adjacent side to angle A has
; length Q, so:
;
;   tan(A) = P / Q
;
; The result in A is an integer representing the angle in radians. The routine
; returns values in the range 0 to 128, which covers 0 to 180 degrees (or 0 to
; PI radians).
;
; ******************************************************************************

.ARCTAN

 LDA P                  ; Set T1 = P EOR Q, which will have the sign of P * Q
 EOR Q
 STA T1

 LDA Q                  ; If Q = 0, jump to AR2 to return a right angle
 BEQ AR2

 ASL A                  ; Set Q = |Q| * 2 (this is a quick way of clearing the
 STA Q                  ; sign bit, and we don't need to shift right again as we
                        ; only ever use this value in the division with |P| * 2,
                        ; which we set next)

 LDA P                  ; Set A = |P| * 2
 ASL A

 CMP Q                  ; If A >= Q, i.e. |P| > |Q|, jump to AR1 to swap P
 BCS AR1                ; and Q around, so we can still use the lookup table

 JSR ARS1               ; Call ARS1 to set the following from the lookup table:
                        ;
                        ;   A = arctan(A / Q)
                        ;     = arctan(|P / Q|)

 SEC                    ; Set the C flag so the SBC instruction in AR3 will be
                        ; correct, should we jump there

.AR4

 LDX T1                 ; If T1 is negative, i.e. P and Q have different signs,
 BMI AR3                ; jump down to AR3 to return arctan(-|P / Q|)

 RTS                    ; Otherwise P and Q have the same sign, so our result is
                        ; correct and we can return from the subroutine

.AR1

                        ; We want to calculate arctan(t) where |t| > 1, so we
                        ; can use the calculation described in the documentation
                        ; for the ACT table, i.e. 64 - arctan(1 / t)

 LDX Q                  ; Swap the values in Q and P, using the fact that we
 STA Q                  ; called AR1 with A = P
 STX P                  ;
 TXA                    ; This also sets A = P (which now contains the original
                        ; argument |Q|)

 JSR ARS1               ; Call ARS1 to set the following from the lookup table:
                        ;
                        ;   A = arctan(A / Q)
                        ;     = arctan(|Q / P|)
                        ;     = arctan(1 / |P / Q|)

 STA T                  ; Set T = 64 - T
 LDA #64
 SBC T

 BCS AR4                ; Jump to AR4 to continue the calculation (this BCS is
                        ; effectively a JMP as the subtraction will never
                        ; underflow, as ARS1 returns values in the range 0-31)

.AR2

                        ; If we get here then Q = 0, so tan(A) = infinity and
                        ; A is a right angle, or 0.25 of a circle. We allocate
                        ; 255 to a full circle, so we should return 63 for a
                        ; right angle

 LDA #63                ; Set A to 63, to represent a right angle

 RTS                    ; Return from the subroutine

.AR3

                        ; A contains arctan(|P / Q|) but P and Q have different
                        ; signs, so we need to return arctan(-|P / Q|), using
                        ; the calculation described in the documentation for the
                        ; ACT table, i.e. 128 - A

 STA T                  ; Set A = 128 - A
 LDA #128               ;
 SBC T                  ; The subtraction will work because we did a SEC before
                        ; calling AR3

 RTS                    ; Return from the subroutine

.ARS1

                        ; This routine fetches arctan(A / Q) from the ACT table,
                        ; so A will be set to an integer in the range 0 to 31
                        ; that represents an angle from 0 to 45 degrees (or 0 to
                        ; PI / 4 radians)

 JSR LL28               ; Call LL28 to calculate:
                        ;
                        ;   R = 256 * A / Q

 LDA R                  ; Set X = R / 8
 LSR A                  ;       = 32 * A / Q
 LSR A                  ;
 LSR A                  ; so X has the value t * 32 where t = A / Q, which is
 TAX                    ; what we need to look up values in the ACT table

 LDA ACT,X              ; Fetch ACT+X from the ACT table into A, so now:
                        ;
                        ;   A = value in ACT + X
                        ;     = value in ACT + (32 * A / Q)
                        ;     = arctan(A / Q)

 RTS                    ; Return from the subroutine

; ******************************************************************************
;
;       Name: BLINE
;       Type: Subroutine
;   Category: Drawing circles
;    Summary: Draw a circle segment and add it to the ball line heap
;  Deep dive: The ball line heap
;             Drawing circles
;
; ------------------------------------------------------------------------------
;
; Draw a single segment of a circle, adding the point to the ball line heap.
;
; Arguments:
;
;   CNT                 The number of this segment
;
;   STP                 The step size for the circle
;
;   K6(1 0)             The x-coordinate of the new point on the circle, as
;                       a screen coordinate
;
;   (T X)               The y-coordinate of the new point on the circle, as
;                       an offset from the centre of the circle
;
;   FLAG                Set to $FF for the first call, so it sets up the first
;                       point in the heap but waits until the second call before
;                       drawing anything (as we need two points, i.e. two calls,
;                       before we can draw a line)
;
;   K                   The circle's radius
;
;   K3(1 0)             Pixel x-coordinate of the centre of the circle
;
;   K4(1 0)             Pixel y-coordinate of the centre of the circle
;
;   K5(1 0)             Screen x-coordinate of the previous point added to the
;                       ball line heap (if this is not the first point)
;
;   K5(3 2)             Screen y-coordinate of the previous point added to the
;                       ball line heap (if this is not the first point)
;
;   SWAP                If non-zero, we swap (X1, Y1) and (X2, Y2)
;
; Returns:
;
;   CNT                 CNT is updated to CNT + STP
;
;   A                   The new value of CNT
;
;   K5(1 0)             Screen x-coordinate of the point that we just added to
;                       the ball line heap
;
;   K5(3 2)             Screen y-coordinate of the point that we just added to
;                       the ball line heap
;
;   FLAG                Set to 0
;
; ******************************************************************************

.BLINE

 SETUP_PPU_FOR_ICON_BAR ; If the PPU has started drawing the icon bar, configure
                        ; the PPU to use nametable 0 and pattern table 0

 TXA                    ; Set K6(3 2) = (T X) + K4(1 0)
 ADC K4                 ;             = y-coord of centre + y-coord of new point
 STA K6+2               ;
 LDA K4+1               ; so K6(3 2) now contains the y-coordinate of the new
 ADC T                  ; point on the circle but as a screen coordinate, to go
 STA K6+3               ; along with the screen y-coordinate in K6(1 0)

 LDA FLAG               ; If FLAG = 0, jump down to BL1
 BEQ BL1

 INC FLAG               ; Flag is $FF so this is the first call to BLINE, so
                        ; increment FLAG to set it to 0, as then the next time
                        ; we call BLINE it can draw the first line, from this
                        ; point to the next

 JMP BL5                ; This is the first call to BLINE, so we don't need to
                        ; copy the previous point to XX15 as there isn't one,
                        ; so we jump to BL5 to tidy up and return from the
                        ; subroutine

.BL1

 LDA K5                 ; Set XX15 = K5 = x_lo of previous point
 STA XX15

 LDA K5+1               ; Set XX15+1 = K5+1 = x_hi of previous point
 STA XX15+1

 LDA K5+2               ; Set XX15+2 = K5+2 = y_lo of previous point
 STA XX15+2

 LDA K5+3               ; Set XX15+3 = K5+3 = y_hi of previous point
 STA XX15+3

 LDA K6                 ; Set XX15+4 = x_lo of new point
 STA XX15+4

 LDA K6+1               ; Set XX15+5 = x_hi of new point
 STA XX15+5

 LDA K6+2               ; Set XX12 = y_lo of new point
 STA XX12

 LDA K6+3               ; Set XX12+1 = y_hi of new point
 STA XX12+1

 SETUP_PPU_FOR_ICON_BAR ; If the PPU has started drawing the icon bar, configure
                        ; the PPU to use nametable 0 and pattern table 0

 JSR CLIP               ; Call CLIP to see if the new line segment needs to be
                        ; clipped to fit on-screen, returning the clipped line's
                        ; end-points in (X1, Y1) and (X2, Y2)

 BCS BL5                ; If the C flag is set then the line is not visible on
                        ; screen anyway, so jump to BL5, to avoid drawing and
                        ; storing this line

 LDA SWAP               ; If SWAP = 0, then we didn't have to swap the line
 BEQ BL9                ; coordinates around during the clipping process, so
                        ; jump to BL9 to skip the following swap

 LDA X1                 ; Otherwise the coordinates were swapped by the call to
 LDY X2                 ; LL145 above, so we swap (X1, Y1) and (X2, Y2) back
 STA X2                 ; again
 STY X1
 LDA Y1
 LDY Y2
 STA Y2
 STY Y1

.BL9

 JSR LOIN               ; Draw a line from (X1, Y1) to (X2, Y2)

.BL5

 LDA K6                 ; Copy the data for this step point from K6(3 2 1 0)
 STA K5                 ; into K5(3 2 1 0), for use in the next call to BLINE:
 LDA K6+1               ;
 STA K5+1               ;   * K5(1 0) = screen x-coordinate of this point
 LDA K6+2               ;
 STA K5+2               ;   * K5(3 2) = screen y-coordinate of this point
 LDA K6+3               ;
 STA K5+3               ; They now become the "previous point" in the next call

 LDA CNT                ; Set CNT = CNT + STP
 CLC
 ADC STP
 STA CNT

 RTS                    ; Return from the subroutine

; ******************************************************************************
;
;       Name: STARS
;       Type: Subroutine
;   Category: Stardust
;    Summary: The main routine for processing the stardust
;  Deep dive: Sprite usage in NES Elite
;
; ------------------------------------------------------------------------------
;
; Called at the very end of the main flight loop.
;
; ******************************************************************************

.STARS

 LDX VIEW               ; Load the current view into X:
                        ;
                        ;   0 = front
                        ;   1 = rear
                        ;   2 = left
                        ;   3 = right

 BEQ STARS1             ; If this 0, jump to STARS1 to process the stardust for
                        ; the front view

 DEX                    ; If this is view 2 or 3, jump to STARS2 (via ST11) to
 BNE ST11               ; process the stardust for the left or right views

 JMP STARS6             ; Otherwise this is the rear view, so jump to STARS6 to
                        ; process the stardust for the rear view

.ST11

 JMP STARS2             ; Jump to STARS2 for the left or right views, as it's
                        ; too far for the branch instruction above

; ******************************************************************************
;
;       Name: STARS1
;       Type: Subroutine
;   Category: Stardust
;    Summary: Process the stardust for the front view
;  Deep dive: Stardust in the front view
;  Deep dive: Sprite usage in NES Elite
;
; ------------------------------------------------------------------------------
;
; This moves the stardust towards us according to our speed (so the dust rushes
; past us), and applies our current pitch and roll to each particle of dust, so
; the stardust moves correctly when we steer our ship.
;
; When a stardust particle rushes past us and falls off the side of the screen,
; its memory is recycled as a new particle that's positioned randomly on-screen.
;
; These are the calculations referred to in the commentary:
;
;   1. q = 64 * speed / z_hi
;   2. z = z - speed * 64
;   3. y = y + |y_hi| * q
;   4. x = x + |x_hi| * q
;
;   5. y = y + alpha * x / 256
;   6. x = x - alpha * y / 256
;
;   7. x = x + 2 * (beta * y / 256) ^ 2
;   8. y = y - beta * 256
;
; For more information see the deep dive on "Stardust in the front view".
;
; ******************************************************************************

.STARS1

 LDY NOSTM              ; Set Y to the current number of stardust particles, so
                        ; we can use it as a counter through all the stardust

                        ; In the following, we're going to refer to the 16-bit
                        ; space coordinates of the current particle of stardust
                        ; (i.e. the Y-th particle) like this:
                        ;
                        ;   x = (x_hi x_lo)
                        ;   y = (y_hi y_lo)
                        ;   z = (z_hi z_lo)
                        ;
                        ; These values are stored in (SX+Y SXL+Y), (SY+Y SYL+Y)
                        ; and (SZ+Y SZL+Y) respectively

.STL1

 SETUP_PPU_FOR_ICON_BAR ; If the PPU has started drawing the icon bar, configure
                        ; the PPU to use nametable 0 and pattern table 0

 JSR DV42               ; Call DV42 to set the following:
                        ;
                        ;   (P R) = 256 * DELTA / z_hi
                        ;         = 256 * speed / z_hi
                        ;
                        ; The maximum value returned is P = 2 and R = 128 (see
                        ; DV42 for an explanation)

 LDA R                  ; Set A = R, so now:
                        ;
                        ;   (P A) = 256 * speed / z_hi

 LSR P                  ; Rotate (P A) right by 2 places, which sets P = 0 (as P
 ROR A                  ; has a maximum value of 2) and leaves:
 LSR P                  ;
 ROR A                  ;   A = 64 * speed / z_hi

 ORA #1                 ; Make sure A is at least 1, and store it in Q, so we
 STA Q                  ; now have result 1 above:
                        ;
                        ;   Q = 64 * speed / z_hi

 LDA SZL,Y              ; We now calculate the following:
 SBC DELT4              ;
 STA SZL,Y              ;  (z_hi z_lo) = (z_hi z_lo) - DELT4(1 0)
                        ;
                        ; starting with the low bytes

 LDA SZ,Y               ; And then we do the high bytes
 STA ZZ                 ;
 SBC DELT4+1            ; We also set ZZ to the original value of z_hi, which we
 STA SZ,Y               ; use below to remove the existing particle
                        ;
                        ; So now we have result 2 above:
                        ;
                        ;   z = z - DELT4(1 0)
                        ;     = z - speed * 64

 JSR MLU1               ; Call MLU1 to set:
                        ;
                        ;   Y1 = y_hi
                        ;
                        ;   (A P) = |y_hi| * Q
                        ;
                        ; So Y1 contains the original value of y_hi, which we
                        ; use below to remove the existing particle

                        ; We now calculate:
                        ;
                        ;   (S R) = YY(1 0) = (A P) + y

 STA YY+1               ; First we do the low bytes with:
 LDA P                  ;
 ADC SYL,Y              ;   YY+1 = A
 STA YY                 ;   R = YY = P + y_lo
 STA R                  ;
                        ; so we get this:
                        ;
                        ;   (? R) = YY(1 0) = (A P) + y_lo

 LDA Y1                 ; And then we do the high bytes with:
 ADC YY+1               ;
 STA YY+1               ;   S = YY+1 = y_hi + YY+1
 STA S                  ;
                        ; so we get our result:
                        ;
                        ;   (S R) = YY(1 0) = (A P) + (y_hi y_lo)
                        ;                   = |y_hi| * Q + y
                        ;
                        ; which is result 3 above, and (S R) is set to the new
                        ; value of y

 LDA SX,Y               ; Set X1 = A = x_hi
 STA X1                 ;
                        ; So X1 contains the original value of x_hi, which we
                        ; use below to remove the existing particle

 JSR MLU2               ; Set (A P) = |x_hi| * Q

                        ; We now calculate:
                        ;
                        ;   XX(1 0) = (A P) + x

 STA XX+1               ; First we store the high byte A in XX+1

 SETUP_PPU_FOR_ICON_BAR ; If the PPU has started drawing the icon bar, configure
                        ; the PPU to use nametable 0 and pattern table 0

 LDA P                  ; Then we do the low bytes:
 ADC SXL,Y              ;
 STA XX                 ;   XX(1 0) = (A P) + x_lo

 LDA X1                 ; And then we do the high bytes:
 ADC XX+1               ;
 STA XX+1               ;   XX(1 0) = XX(1 0) + (x_hi 0)
                        ;
                        ; so we get our result:
                        ;
                        ;   XX(1 0) = (A P) + x
                        ;           = |x_hi| * Q + x
                        ;
                        ; which is result 4 above, and we also have:
                        ;
                        ;   A = XX+1 = (|x_hi| * Q + x) / 256
                        ;
                        ; i.e. A is the new value of x, divided by 256

 EOR ALP2+1             ; EOR with the flipped sign of the roll angle alpha, so
                        ; A has the opposite sign to the flipped roll angle
                        ; alpha, i.e. it gets the same sign as alpha

 JSR MLS1               ; Call MLS1 to calculate:
                        ;
                        ;   (A P) = A * ALP1
                        ;         = (x / 256) * alpha

 JSR ADD                ; Call ADD to calculate:
                        ;
                        ;   (A X) = (A P) + (S R)
                        ;         = (x / 256) * alpha + y
                        ;         = y + alpha * x / 256

 STA YY+1               ; Set YY(1 0) = (A X) to give:
 STX YY                 ;
                        ;   YY(1 0) = y + alpha * x / 256
                        ;
                        ; which is result 5 above, and we also have:
                        ;
                        ;   A = YY+1 = y + alpha * x / 256
                        ;
                        ; i.e. A is the new value of y, divided by 256

 EOR ALP2               ; EOR A with the correct sign of the roll angle alpha,
                        ; so A has the opposite sign to the roll angle alpha

 JSR MLS2               ; Call MLS2 to calculate:
                        ;
                        ;   (S R) = XX(1 0)
                        ;         = x
                        ;
                        ;   (A P) = A * ALP1
                        ;         = -y / 256 * alpha

 JSR ADD                ; Call ADD to calculate:
                        ;
                        ;   (A X) = (A P) + (S R)
                        ;         = -y / 256 * alpha + x

 STA XX+1               ; Set XX(1 0) = (A X), which gives us result 6 above:
 STX XX                 ;
                        ;   x = x - alpha * y / 256

 SETUP_PPU_FOR_ICON_BAR ; If the PPU has started drawing the icon bar, configure
                        ; the PPU to use nametable 0 and pattern table 0

 LDX BET1               ; Fetch the pitch magnitude into X

 LDA YY+1               ; Set A to y_hi and set it to the flipped sign of beta
 EOR BET2+1

 JSR MULTS-2            ; Call MULTS-2 to calculate:
                        ;
                        ;   (A P) = X * A
                        ;         = -beta * y_hi

 STA Q                  ; Store the high byte of the result in Q, so:
                        ;
                        ;   Q = -beta * y_hi / 256

 JSR MUT2               ; Call MUT2 to calculate:
                        ;
                        ;   (S R) = XX(1 0) = x
                        ;
                        ;   (A P) = Q * A
                        ;         = (-beta * y_hi / 256) * (-beta * y_hi / 256)
                        ;         = (beta * y / 256) ^ 2

 ASL P                  ; Double (A P), store the top byte in A and set the C
 ROL A                  ; flag to bit 7 of the original A, so this does:
 STA T                  ;
                        ;   (T P) = (A P) << 1
                        ;         = 2 * (beta * y / 256) ^ 2

 LDA #0                 ; Set bit 7 in A to the sign bit from the A in the
 ROR A                  ; calculation above and apply it to T, so we now have:
 ORA T                  ;
                        ;   (A P) = (A P) * 2
                        ;         = 2 * (beta * y / 256) ^ 2
                        ;
                        ; with the doubling retaining the sign of (A P)

 JSR ADD                ; Call ADD to calculate:
                        ;
                        ;   (A X) = (A P) + (S R)
                        ;         = 2 * (beta * y / 256) ^ 2 + x

 STA XX+1               ; Store the high byte A in XX+1

 TXA                    ; Store the low byte X in x_lo
 STA SXL,Y

                        ; So (XX+1 x_lo) now contains:
                        ;
                        ;   x = x + 2 * (beta * y / 256) ^ 2
                        ;
                        ; which is result 7 above

 LDA YY                 ; Set (S R) = YY(1 0) = y
 STA R
 LDA YY+1
 STA S

 LDA #0                 ; Set P = 0
 STA P

 SETUP_PPU_FOR_ICON_BAR ; If the PPU has started drawing the icon bar, configure
                        ; the PPU to use nametable 0 and pattern table 0

 LDA BETA               ; Set A = -beta, so:
 EOR #%10000000         ;
                        ;   (A P) = (-beta 0)
                        ;         = -beta * 256

                        ; Calculate the following:
                        ;
                        ;   (YY+1 y_lo) = (A P) + (S R)
                        ;               = -beta * 256 + y
                        ;
                        ; i.e. y = y - beta * 256, which is result 8 above

 JSR ADD                ; Set (A X) = (A P) + (S R)

 STA YY+1               ; Set YY+1 to A, the high byte of the result

 TXA                    ; Set SYL+Y to X, the low byte of the result
 STA SYL,Y

                        ; We now have our newly moved stardust particle at
                        ; x-coordinate (XX+1 x_lo) and y-coordinate (YY+1 y_lo)
                        ; and distance z_hi, so we draw it if it's still on
                        ; screen, otherwise we recycle it as a new bit of
                        ; stardust and draw that

 LDA XX+1               ; Set X1 and x_hi to the high byte of XX in XX+1, so
 STA X1                 ; the new x-coordinate is in (x_hi x_lo) and the high
 STA SX,Y               ; byte is in X1

 AND #%01111111         ; If |x_hi| >= 120 then jump to KILL1 to recycle this
 CMP #120               ; particle, as it's gone off the side of the screen,
 BCS KILL1              ; and rejoin at STC1 with the new particle

 LDA YY+1               ; Set Y1 and y_hi to the high byte of YY in YY+1, so
 STA SY,Y               ; the new x-coordinate is in (y_hi y_lo) and the high
 STA Y1                 ; byte is in Y1

 AND #%01111111         ; If |y_hi| >= 120 then jump to KILL1 to recycle this
 CMP #120               ; particle, as it's gone off the top or bottom of the
 BCS KILL1              ; screen, and rejoin at STC1 with the new particle

 LDA SZ,Y               ; If z_hi < 16 then jump to KILL1 to recycle this
 CMP #16                ; particle, as it's so close that it's effectively gone
 BCC KILL1              ; past us, and rejoin at STC1 with the new particle

 STA ZZ                 ; Set ZZ to the z-coordinate in z_hi

.STC1

 JSR PIXEL2             ; Draw a stardust particle at (X1,Y1) with distance ZZ,
                        ; i.e. draw the newly moved particle at (x_hi, y_hi)
                        ; with distance z_hi

 DEY                    ; Decrement the loop counter to point to the next
                        ; stardust particle

 BEQ P%+5               ; If we have just done the last particle, skip the next
                        ; instruction to return from the subroutine

 JMP STL1               ; We have more stardust to process, so jump back up to
                        ; STL1 for the next particle

 RTS                    ; Return from the subroutine

.KILL1

                        ; Our particle of stardust just flew past us, so let's
                        ; recycle that particle, starting it at a random
                        ; position that isn't too close to the centre point

 JSR DORND              ; Set A and X to random numbers

 ORA #4                 ; Make sure A is at least 4 and store it in Y1 and y_hi,
 STA Y1                 ; so the new particle starts at least 4 pixels above or
 STA SY,Y               ; below the centre of the screen

 JSR DORND              ; Set A and X to random numbers

 ORA #16                ; Make sure A is at least 16 and is a multiple of 16 and
 AND #%11110000         ; store it in X1 and x_hi, so the new particle starts at
 STA X1                 ; least 16 pixels either side of the centre of the
 STA SX,Y               ; screen and on a spaced-out grid that's 16 pixels wide

 JSR DORND              ; Set A and X to random numbers

 ORA #144               ; Make sure A is at least 144 and store it in ZZ and
 STA SZ,Y               ; z_hi so the new particle starts in the far distance
 STA ZZ

 SETUP_PPU_FOR_ICON_BAR ; If the PPU has started drawing the icon bar, configure
                        ; the PPU to use nametable 0 and pattern table 0

 LDA Y1                 ; Set A to the new value of y_hi. This has no effect as
                        ; STC1 starts with a jump to PIXEL2, which starts with a
                        ; LDA instruction

 JMP STC1               ; Jump up to STC1 to draw this new particle

; ******************************************************************************
;
;       Name: STARS6
;       Type: Subroutine
;   Category: Stardust
;    Summary: Process the stardust for the rear view
;  Deep dive: Sprite usage in NES Elite
;
; ------------------------------------------------------------------------------
;
; This routine is very similar to STARS1, which processes stardust for the front
; view. The main difference is that the direction of travel is reversed, so the
; signs in the calculations are different, as well as the order of the first
; batch of calculations.
;
; When a stardust particle falls away into the far distance, it is removed from
; the screen and its memory is recycled as a new particle, positioned randomly
; along one of the four edges of the screen.
;
; These are the calculations referred to in the commentary:
;
;   1. q = 64 * speed / z_hi
;   2. z = z - speed * 64
;   3. y = y + |y_hi| * q
;   4. x = x + |x_hi| * q
;
;   5. y = y + alpha * x / 256
;   6. x = x - alpha * y / 256
;
;   7. x = x + 2 * (beta * y / 256) ^ 2
;   8. y = y - beta * 256
;
; For more information see the deep dive on "Stardust in the front view".
;
; ******************************************************************************

.STARS6

 LDY NOSTM              ; Set Y to the current number of stardust particles, so
                        ; we can use it as a counter through all the stardust

.STL6

 SETUP_PPU_FOR_ICON_BAR ; If the PPU has started drawing the icon bar, configure
                        ; the PPU to use nametable 0 and pattern table 0

 JSR DV42               ; Call DV42 to set the following:
                        ;
                        ;   (P R) = 256 * DELTA / z_hi
                        ;         = 256 * speed / z_hi
                        ;
                        ; The maximum value returned is P = 2 and R = 128 (see
                        ; DV42 for an explanation)

 LDA R                  ; Set A = R, so now:
                        ;
                        ;   (P A) = 256 * speed / z_hi

 LSR P                  ; Rotate (P A) right by 2 places, which sets P = 0 (as P
 ROR A                  ; has a maximum value of 2) and leaves:
 LSR P                  ;
 ROR A                  ;   A = 64 * speed / z_hi

 ORA #1                 ; Make sure A is at least 1, and store it in Q, so we
 STA Q                  ; now have result 1 above:
                        ;
                        ;   Q = 64 * speed / z_hi

 LDA SX,Y               ; Set X1 = A = x_hi
 STA X1                 ;
                        ; So X1 contains the original value of x_hi, which we
                        ; use below to remove the existing particle

 JSR MLU2               ; Set (A P) = |x_hi| * Q

                        ; We now calculate:
                        ;
                        ;   XX(1 0) = x - (A P)

 STA XX+1               ; First we do the low bytes:
 LDA SXL,Y              ;
 SBC P                  ;   XX(1 0) = x_lo - (A P)
 STA XX

 LDA X1                 ; And then we do the high bytes:
 SBC XX+1               ;
 STA XX+1               ;   XX(1 0) = (x_hi 0) - XX(1 0)
                        ;
                        ; so we get our result:
                        ;
                        ;   XX(1 0) = x - (A P)
                        ;           = x - |x_hi| * Q
                        ;
                        ; which is result 2 above, and we also have:

 JSR MLU1               ; Call MLU1 to set:
                        ;
                        ;   Y1 = y_hi
                        ;
                        ;   (A P) = |y_hi| * Q
                        ;
                        ; So Y1 contains the original value of y_hi, which we
                        ; use below to remove the existing particle

                        ; We now calculate:
                        ;
                        ;   (S R) = YY(1 0) = y - (A P)

 STA YY+1               ; First we store the high byte A in YY+1

 SETUP_PPU_FOR_ICON_BAR ; If the PPU has started drawing the icon bar, configure
                        ; the PPU to use nametable 0 and pattern table 0

 LDA SYL,Y              ; Then we do the low bytes with:
 SBC P                  ;
 STA YY                 ;   YY+1 = A
 STA R                  ;   R = YY = y_lo - P
                        ;
                        ; so we get this:
                        ;
                        ;   (? R) = YY(1 0) = y_lo - (A P)

 LDA Y1                 ; And then we do the high bytes with:
 SBC YY+1               ;
 STA YY+1               ;   S = YY+1 = y_hi - YY+1
 STA S                  ;
                        ; so we get our result:
                        ;
                        ;   (S R) = YY(1 0) = (y_hi y_lo) - (A P)
                        ;                   = y - |y_hi| * Q
                        ;
                        ; which is result 3 above, and (S R) is set to the new
                        ; value of y

 LDA SZL,Y              ; We now calculate the following:
 ADC DELT4              ;
 STA SZL,Y              ;  (z_hi z_lo) = (z_hi z_lo) + DELT4(1 0)
                        ;
                        ; starting with the low bytes

 LDA SZ,Y               ; And then we do the high bytes
 STA ZZ                 ;
 ADC DELT4+1            ; We also set ZZ to the original value of z_hi, which we
 STA SZ,Y               ; use below to remove the existing particle
                        ;
                        ; So now we have result 4 above:
                        ;
                        ;   z = z + DELT4(1 0)
                        ;     = z + speed * 64

 LDA XX+1               ; EOR x with the correct sign of the roll angle alpha,
 EOR ALP2               ; so A has the opposite sign to the roll angle alpha

 JSR MLS1               ; Call MLS1 to calculate:
                        ;
                        ;   (A P) = A * ALP1
                        ;         = (-x / 256) * alpha

 JSR ADD                ; Call ADD to calculate:
                        ;
                        ;   (A X) = (A P) + (S R)
                        ;         = (-x / 256) * alpha + y
                        ;         = y - alpha * x / 256

 STA YY+1               ; Set YY(1 0) = (A X) to give:
 STX YY                 ;
                        ;   YY(1 0) = y - alpha * x / 256
                        ;
                        ; which is result 5 above, and we also have:
                        ;
                        ;   A = YY+1 = y - alpha * x / 256
                        ;
                        ; i.e. A is the new value of y, divided by 256

 EOR ALP2+1             ; EOR with the flipped sign of the roll angle alpha, so
                        ; A has the opposite sign to the flipped roll angle
                        ; alpha, i.e. it gets the same sign as alpha

 JSR MLS2               ; Call MLS2 to calculate:
                        ;
                        ;   (S R) = XX(1 0)
                        ;         = x
                        ;
                        ;   (A P) = A * ALP1
                        ;         = y / 256 * alpha

 JSR ADD                ; Call ADD to calculate:
                        ;
                        ;   (A X) = (A P) + (S R)
                        ;         = y / 256 * alpha + x

 STA XX+1               ; Set XX(1 0) = (A X), which gives us result 6 above:
 STX XX                 ;
                        ;   x = x + alpha * y / 256

 LDA YY+1               ; Set A to y_hi and set it to the flipped sign of beta
 EOR BET2+1

 LDX BET1               ; Fetch the pitch magnitude into X

 JSR MULTS-2            ; Call MULTS-2 to calculate:
                        ;
                        ;   (A P) = X * A
                        ;         = beta * y_hi

 STA Q                  ; Store the high byte of the result in Q, so:
                        ;
                        ;   Q = beta * y_hi / 256

 LDA XX+1               ; Set S = x_hi
 STA S

 EOR #%10000000         ; Flip the sign of A, so A now contains -x

 JSR MUT1               ; Call MUT1 to calculate:
                        ;
                        ;   R = XX = x_lo
                        ;
                        ;   (A P) = Q * A
                        ;         = (beta * y_hi / 256) * (-beta * y_hi / 256)
                        ;         = (-beta * y / 256) ^ 2

 ASL P                  ; Double (A P), store the top byte in A and set the C
 ROL A                  ; flag to bit 7 of the original A, so this does:
 STA T                  ;
                        ;   (T P) = (A P) << 1
                        ;         = 2 * (-beta * y / 256) ^ 2

 LDA #0                 ; Set bit 7 in A to the sign bit from the A in the
 ROR A                  ; calculation above and apply it to T, so we now have:
 ORA T                  ;
                        ;   (A P) = -2 * (beta * y / 256) ^ 2
                        ;
                        ; with the doubling retaining the sign of (A P)

 JSR ADD                ; Call ADD to calculate:
                        ;
                        ;   (A X) = (A P) + (S R)
                        ;         = -2 * (beta * y / 256) ^ 2 + x

 STA XX+1               ; Store the high byte A in XX+1

 TXA                    ; Store the low byte X in x_lo
 STA SXL,Y

                        ; So (XX+1 x_lo) now contains:
                        ;
                        ;   x = x - 2 * (beta * y / 256) ^ 2
                        ;
                        ; which is result 7 above

 LDA YY                 ; Set (S R) = YY(1 0) = y (low byte)
 STA R

 SETUP_PPU_FOR_ICON_BAR ; If the PPU has started drawing the icon bar, configure
                        ; the PPU to use nametable 0 and pattern table 0

 LDA YY+1               ; Set (S R) = YY(1 0) = y (high byte)
 STA S

 LDA #0                 ; Set P = 0
 STA P

 LDA BETA               ; Set A = beta, so (A P) = (beta 0) = beta * 256

                        ; Calculate the following:
                        ;
                        ;   (YY+1 y_lo) = (A P) + (S R)
                        ;               = -beta * 256 + y
                        ;
                        ; i.e. y = y - beta * 256, which is result 8 above

 JSR ADD                ; Set (A X) = (A P) + (S R)

 STA YY+1               ; Set YY+1 to A, the high byte of the result

 TXA                    ; Set SYL+Y to X, the low byte of the result
 STA SYL,Y

                        ; We now have our newly moved stardust particle at
                        ; x-coordinate (XX+1 x_lo) and y-coordinate (YY+1 y_lo)
                        ; and distance z_hi, so we draw it if it's still on
                        ; screen, otherwise we recycle it as a new bit of
                        ; stardust and draw that

 LDA XX+1               ; Set X1 and x_hi to the high byte of XX in XX+1, so
 STA X1                 ; the new x-coordinate is in (x_hi x_lo) and the high
 STA SX,Y               ; byte is in X1

 LDA YY+1               ; Set Y1 and y_hi to the high byte of YY in YY+1, so
 STA SY,Y               ; the new x-coordinate is in (y_hi y_lo) and the high
 STA Y1                 ; byte is in Y1

 AND #%01111111         ; If |y_hi| >= 110 then jump to KILL6 to recycle this
 CMP #110               ; particle, as it's gone off the top or bottom of the
 BCS KILL6              ; screen, and rejoin at STC6 with the new particle

 LDA SZ,Y               ; If z_hi >= 160 then jump to star1 to recycle this
 CMP #160               ; particle, as it's so far away that it's too far to
 BCS star1              ; see, and rejoin at STC1 with the new particle

 STA ZZ                 ; Set ZZ to the z-coordinate in z_hi

.STC6

 JSR PIXEL2             ; Draw a stardust particle at (X1,Y1) with distance ZZ,
                        ; i.e. draw the newly moved particle at (x_hi, y_hi)
                        ; with distance z_hi

 DEY                    ; Decrement the loop counter to point to the next
                        ; stardust particle

 BEQ ST3                ; If we have just done the last particle, skip the next
                        ; instruction to return from the subroutine

 JMP STL6               ; We have more stardust to process, so jump back up to
                        ; STL6 for the next particle

.ST3

 RTS                    ; Return from the subroutine

.KILL6

 JSR DORND              ; Set A and X to random numbers

 AND #31                ; Clear the sign bit of A and set it to a random number
                        ; in the range 0 to 31

 ADC #10                ; Make sure A is at least 10 and store it in z_hi and
 STA SZ,Y               ; ZZ, so the new particle starts close to us
 STA ZZ

 LSR A                  ; Divide A by 2 and randomly set the C flag

 BCS ST4                ; Jump to ST4 half the time

 LSR A                  ; Randomly set the C flag again

 LDA #224               ; Set A to either +112 or -112 (224 >> 1) depending on
 ROR A                  ; the C flag, as this is a sign-magnitude number with
                        ; the C flag rotated into its sign bit

 STA X1                 ; Set x_hi and X1 to A, so this particle starts on
 STA SX,Y               ; either the left or right edge of the screen

 JSR DORND              ; Set A and X to random numbers

 AND #%10111111         ; Clear bit 6 of A so A is in the range -63 to +63

 STA Y1                 ; Set y_hi and Y1 to random numbers, so the particle
 STA SY,Y               ; starts anywhere along either the left or right edge

 JMP STC6               ; Jump up to STC6 to draw this new particle

.star1

 JSR DORND              ; Set A and X to random numbers

 AND #%01111111         ; Clear the sign bit of A to get |A|

 ADC #10                ; Make sure A is at least 10 and store it in z_hi and
 STA SZ,Y               ; ZZ, so the new particle starts close to us
 STA ZZ

.ST4

 JSR DORND              ; Set A and X to random numbers

 AND #%11111001         ; Clear bits 1 and 2 of A so A is a random multiple of 8
                        ; in the range -120 to +120, randomly minus or plus 1

 STA X1                 ; Set x_hi and X1 to random numbers, so the particle
 STA SX,Y               ; starts anywhere along the x-axis

 LSR A                  ; Randomly set the C flag

 LDA #216               ; Set A to either +108 or -108 (216 >> 1) depending on
 ROR A                  ; the C flag, as this is a sign-magnitude number with
                        ; the C flag rotated into its sign bit

 STA Y1                 ; Set y_hi and Y1 to A, so the particle starts anywhere
 STA SY,Y               ; along either the top or bottom edge of the screen

 BNE STC6               ; Jump up to STC6 to draw this new particle (this BNE is
                        ; effectively a JMP as A will never be zero)

; ******************************************************************************
;
;       Name: STARS2
;       Type: Subroutine
;   Category: Stardust
;    Summary: Process the stardust for the left or right view
;  Deep dive: Stardust in the side views
;             Sprite usage in NES Elite
;
; ------------------------------------------------------------------------------
;
; This moves the stardust sideways according to our speed and which side we are
; looking out of, and applies our current pitch and roll to each particle of
; dust, so the stardust moves correctly when we steer our ship.
;
; These are the calculations referred to in the commentary:
;
;   1. delta_x = 8 * 256 * speed / z_hi
;   2. x = x + delta_x
;
;   3. x = x + beta * y
;   4. y = y - beta * x
;
;   5. x = x - alpha * x * y
;   6. y = y + alpha * y * y + alpha
;
; For more information see the deep dive on "Stardust in the side views".
;
; Arguments:
;
;   X                   The view to process:
;
;                         * X = 1 for left view
;
;                         * X = 2 for right view
;
; ******************************************************************************

.STARS2

 LDA #0                 ; Set A to 0 so we can use it to capture a sign bit

 CPX #2                 ; If X >= 2 then the C flag is set

 ROR A                  ; Roll the C flag into the sign bit of A and store in
 STA RAT                ; RAT, so:
                        ;
                        ;   * Left view, C is clear so RAT = 0 (positive)
                        ;
                        ;   * Right view, C is set so RAT = 128 (negative)
                        ;
                        ; RAT represents the end of the x-axis where we want new
                        ; stardust particles to come from: positive for the left
                        ; view where new particles come in from the right,
                        ; negative for the right view where new particles come
                        ; in from the left

 EOR #%10000000         ; Set RAT2 to the opposite sign, so:
 STA RAT2               ;
                        ;   * Left view, RAT2 = 128 (negative)
                        ;
                        ;   * Right view, RAT2 = 0 (positive)
                        ;
                        ; RAT2 represents the direction in which stardust
                        ; particles should move along the x-axis: negative for
                        ; the left view where particles go from right to left,
                        ; positive for the right view where particles go from
                        ; left to right

 JSR ST2                ; Call ST2 to flip the signs of the following if this is
                        ; the right view: ALPHA, ALP2, ALP2+1, BET2 and BET2+1

 LDY NOSTM              ; Set Y to the current number of stardust particles, so
                        ; we can use it as a counter through all the stardust

.STL2

 SETUP_PPU_FOR_ICON_BAR ; If the PPU has started drawing the icon bar, configure
                        ; the PPU to use nametable 0 and pattern table 0

 LDA SZ,Y               ; Set A = ZZ = z_hi

 STA ZZ                 ; We also set ZZ to the original value of z_hi, which we
                        ; use below to remove the existing particle

 LSR A                  ; Set A = z_hi / 8
 LSR A
 LSR A

 JSR DV41               ; Call DV41 to set the following:
                        ;
                        ;   (P R) = 256 * DELTA / A
                        ;         = 256 * speed / (z_hi / 8)
                        ;         = 8 * 256 * speed / z_hi
                        ;
                        ; This represents the distance we should move this
                        ; particle along the x-axis, let's call it delta_x

 LDA P                  ; Store the high byte of delta_x in newzp
 STA newzp

 EOR RAT2               ; Set S = P but with the sign from RAT2, so we now have
 STA S                  ; the distance delta_x with the correct sign in (S R):
                        ;
                        ;   (S R) = delta_x
                        ;         = 8 * 256 * speed / z_hi
                        ;
                        ; So (S R) is the delta, signed to match the direction
                        ; the stardust should move in, which is result 1 above

 LDA SXL,Y              ; Set (A P) = (x_hi x_lo)
 STA P                  ;           = x
 LDA SX,Y

 STA X1                 ; Set X1 = A, so X1 contains the original value of x_hi,
                        ; which we use below to remove the existing particle

 JSR ADD                ; Call ADD to calculate:
                        ;
                        ;   (A X) = (A P) + (S R)
                        ;         = x + delta_x

 STA S                  ; Set (S R) = (A X)
 STX R                  ;           = x + delta_x

 SETUP_PPU_FOR_ICON_BAR ; If the PPU has started drawing the icon bar, configure
                        ; the PPU to use nametable 0 and pattern table 0

 LDA SY,Y               ; Set A = y_hi

 STA Y1                 ; Set Y1 = A, so Y1 contains the original value of y_hi,
                        ; which we use below to remove the existing particle

 EOR BET2               ; Give A the correct sign of A * beta, i.e. y_hi * beta

 LDX BET1               ; Fetch |beta| from BET1, the pitch angle

 JSR MULTS-2            ; Call MULTS-2 to calculate:
                        ;
                        ;   (A P) = X * A
                        ;         = beta * y_hi

 JSR ADD                ; Call ADD to calculate:
                        ;
                        ;   (A X) = (A P) + (S R)
                        ;         = beta * y + x + delta_x

 STX XX                 ; Set XX(1 0) = (A X), which gives us results 2 and 3
 STA XX+1               ; above, done at the same time:
                        ;
                        ;   x = x + delta_x + beta * y

 LDX SYL,Y              ; Set (S R) = (y_hi y_lo)
 STX R                  ;           = y
 LDX Y1
 STX S

 LDX BET1               ; Fetch |beta| from BET1, the pitch angle

 EOR BET2+1             ; Give A the opposite sign to x * beta

 JSR MULTS-2            ; Call MULTS-2 to calculate:
                        ;
                        ;   (A P) = X * A
                        ;         = -beta * x

 JSR ADD                ; Call ADD to calculate:
                        ;
                        ;   (A X) = (A P) + (S R)
                        ;         = -beta * x + y

 STX YY                 ; Set YY(1 0) = (A X), which gives us result 4 above:
 STA YY+1               ;
                        ;   y = y - beta * x

 LDX ALP1               ; Set X = |alpha| from ALP2, the roll angle

 EOR ALP2               ; Give A the correct sign of A * alpha, i.e. y_hi *
                        ; alpha

 JSR MULTS-2            ; Call MULTS-2 to calculate:
                        ;
                        ;   (A P) = X * A
                        ;         = alpha * y

 STA Q                  ; Set Q = high byte of alpha * y

 LDA XX                 ; Set (S R) = XX(1 0)
 STA R                  ;           = x
 LDA XX+1               ;
 STA S                  ; and set A = y_hi at the same time

 EOR #%10000000         ; Flip the sign of A = -x_hi

 JSR MAD                ; Call MAD to calculate:
                        ;
                        ;   (A X) = Q * A + (S R)
                        ;         = alpha * y * -x + x

 STA XX+1               ; Store the high byte A in XX+1

 TXA                    ; Store the low byte X in x_lo
 STA SXL,Y

                        ; So (XX+1 x_lo) now contains result 5 above:
                        ;
                        ;   x = x - alpha * x * y

 SETUP_PPU_FOR_ICON_BAR ; If the PPU has started drawing the icon bar, configure
                        ; the PPU to use nametable 0 and pattern table 0

 LDA YY                 ; Set (S R) = YY(1 0)
 STA R                  ;           = y
 LDA YY+1               ;
 STA S                  ; and set A = y_hi at the same time

 JSR MAD                ; Call MAD to calculate:
                        ;
                        ;   (A X) = Q * A + (S R)
                        ;         = alpha * y * y_hi + y

 STA S                  ; Set (S R) = (A X)
 STX R                  ;           = y + alpha * y * y

 LDA #0                 ; Set P = 0
 STA P

 LDA ALPHA              ; Set A = alpha, so:
                        ;
                        ;   (A P) = (alpha 0)
                        ;         = alpha / 256

                        ; Calculate the following:
                        ;
                        ;   (YY+1 y_lo) = (A P) + (S R)
                        ;               = alpha * 256 + y + alpha * y * y
                        ;
                        ; i.e. y = y + alpha / 256 + alpha * y^2, which is
                        ; result 6 above

 JSR ADD                ; Set (A X) = (A P) + (S R)

 STA YY+1               ; Set YY+1 to A, the high byte of the result

 TXA                    ; Set SYL+Y to X, the low byte of the result
 STA SYL,Y

                        ; We now have our newly moved stardust particle at
                        ; x-coordinate (XX+1 x_lo) and y-coordinate (YY+1 y_lo)
                        ; and distance z_hi, so we draw it if it's still on
                        ; screen, otherwise we recycle it as a new bit of
                        ; stardust and draw that

 LDA XX+1               ; Set X1 and x_hi to the high byte of XX in XX+1, so
 STA SX,Y               ; the new x-coordinate is in (x_hi x_lo) and the high
 STA X1                 ; byte is in X1

 AND #%01111111         ; Set A = |x_hi|

 CMP #120               ; If |x_hi| >= 120 then jump to KILL2 to recycle this
 BCS KILL2              ; particle, as it's gone off the side of the screen,
                        ; and rejoin at STC2 with the new particle

 EOR #%01111111         ; Set A = ~|x_hi|, which is the same as -(x_hi + 1)
                        ; using two's complement

 CMP newzp              ; If newzp <= -(x_hi + 1), then the particle has been
 BCC KILL2              ; moved off the side of the screen and has wrapped
 BEQ KILL2              ; round to the other side, jump to KILL2 to recycle this
                        ; particle and rejoin at STC2 with the new particle
                        ;
                        ; In the original BBC Micro versions, this test simply
                        ; checks whether |x_hi| >= 116, but this version using
                        ; newzp doesn't hard-code the screen width, so this is
                        ; presumably a change that was introduced to support
                        ; the different screen sizes of the other platforms

 LDA YY+1               ; Set Y1 and y_hi to the high byte of YY in YY+1, so
 STA SY,Y               ; the new x-coordinate is in (y_hi y_lo) and the high
 STA Y1                 ; byte is in Y1

 AND #%01111111         ; If |y_hi| >= 116 then jump to ST5 to recycle this
 CMP #116               ; particle, as it's gone off the top or bottom of the
 BCS ST5                ; screen, and rejoin at STC2 with the new particle

.STC2

 JSR PIXEL2             ; Draw a stardust particle at (X1,Y1) with distance ZZ,
                        ; i.e. draw the newly moved particle at (x_hi, y_hi)
                        ; with distance z_hi

 DEY                    ; Decrement the loop counter to point to the next
                        ; stardust particle

 BEQ ST2                ; If we have just done the last particle, skip the next
                        ; instruction to return from the subroutine

 JMP STL2               ; We have more stardust to process, so jump back up to
                        ; STL2 for the next particle

                        ; Fall through into ST2 to restore the signs of the
                        ; following if this is the right view: ALPHA, ALP2,
                        ; ALP2+1, BET2 and BET2+1

.ST2

 LDA ALPHA              ; If this is the right view, flip the sign of ALPHA
 EOR RAT
 STA ALPHA

 LDA ALP2               ; If this is the right view, flip the sign of ALP2
 EOR RAT
 STA ALP2

 EOR #%10000000         ; If this is the right view, flip the sign of ALP2+1
 STA ALP2+1

 LDA BET2               ; If this is the right view, flip the sign of BET2
 EOR RAT
 STA BET2

 EOR #%10000000         ; If this is the right view, flip the sign of BET2+1
 STA BET2+1

 RTS                    ; Return from the subroutine

.KILL2

 JSR DORND              ; Set A and X to random numbers

 STA Y1                 ; Set y_hi and Y1 to random numbers, so the particle
 STA SY,Y               ; starts anywhere along the y-axis

 LDA #115               ; Make sure A is at least 115 and has the sign in RAT
 ORA RAT

 STA X1                 ; Set x_hi and X1 to A, so this particle starts on the
 STA SX,Y               ; correct edge of the screen for new particles

 BNE STF1               ; Jump down to STF1 to set the z-coordinate (this BNE is
                        ; effectively a JMP as A will never be zero)

.ST5

 JSR DORND              ; Set A and X to random numbers

 STA X1                 ; Set x_hi and X1 to random numbers, so the particle
 STA SX,Y               ; starts anywhere along the x-axis

 LDA #126               ; Make sure A is at least 126 and has the sign in AL2+1,
 ORA ALP2+1             ; the flipped sign of the roll angle alpha

 STA Y1                 ; Set y_hi and Y1 to A, so the particle starts at the
 STA SY,Y               ; top or bottom edge, depending on the current roll
                        ; angle alpha

.STF1

 JSR DORND              ; Set A and X to random numbers

 ORA #8                 ; Make sure A is at least 8 and store it in z_hi and
 STA ZZ                 ; ZZ, so the new particle starts at any distance from
 STA SZ,Y               ; us, but not too close

 BNE STC2               ; Jump up to STC2 to draw this new particle (this BNE is
                        ; effectively a JMP as A will never be zero)

; ******************************************************************************
;
;       Name: yHangarFloor
;       Type: Variable
;   Category: Ship hangar
;    Summary: Pixel y-coordinates for the four horizontal lines that make up the
;             floor of the ship hangar
;
; ******************************************************************************

.yHangarFloor

 EQUB 80
 EQUB 88
 EQUB 98
 EQUB 120

; ******************************************************************************
;
;       Name: HANGER
;       Type: Subroutine
;   Category: Ship hangar
;    Summary: Display the ship hangar
;
; ------------------------------------------------------------------------------
;
; This routine is called after the ships in the hangar have been drawn, so all
; it has to do is draw the hangar's background.
;
; The hangar background is made up of two parts:
;
;   * The hangar floor consists of four screen-wide horizontal lines at the
;     y-coordinates given in the yHangarFloor table, which are close together at
;     the horizon and further apart as the eye moves down and towards us, giving
;     the hangar a simple sense of perspective
;
;   * The back wall of the hangar consists of equally spaced vertical lines
;     that join the horizon to the top of the screen
;
; The ships in the hangar have already been drawn by this point, so the lines
; are drawn so they don't overlap anything that's already there, which makes
; them look like they are behind and below the ships. This is achieved by
; drawing the lines in from the screen edges until they bump into something
; already on-screen. For the horizontal lines, when there are multiple ships in
; the hangar, this also means drawing lines between the ships, as well as in
; from each side.
;
; This routine does a similar job to the routine of the same name in the BBC
; Master version of Elite, but the code is significantly different.
;
; ******************************************************************************

.HANGER

                        ; We start by drawing the floor

 LDX #0                 ; We are going to work our way through the four lines in
                        ; the hangar floor, so

.hang1

 STX TGT                ; Store the line number in TGT so we can retrieve it
                        ; later

 LDA yHangarFloor,X     ; Set Y to the pixel y-coordinate of the line, from the
 TAY                    ; yHangarFloor table

 LDA #8                 ; Set A = 8 so the call to HAL3 draws a horizontal line
                        ; that starts at pixel x-coordinate 8 (i.e. just inside
                        ; the left box edge surrounding the view)

 LDX #28                ; Set X = 28 so the call to HAL3 draws a horizontal line
                        ; of up to 28 blocks (i.e. almost the full screen width)

 JSR HAL3               ; Call HAL3 to draw a line from the left edge of the
                        ; screen, going right until we bump into something
                        ; already on-screen, at which point it stops drawing

 LDA #240               ; Set A = 240 so the call to HAS3 draws a horizontal
                        ; line that starts at pixel x-coordinate 240 (i.e. just
                        ; inside the right box edge surrounding the view)

 LDX #28                ; Set X = 28 so the call to HAS3 draws a horizontal line
                        ; of up to 28 blocks (i.e. almost the full screen width)

 JSR HAS3               ; Draw a horizontal line from the right edge of the
                        ; screen, going left until we bump into something
                        ; already on-screen, at which point stop drawing

 LDA HANGFLAG           ; Fetch the value of HANGFLAG, which gets set to 0 in
                        ; the HALL routine above if there is only one ship

 BEQ hang2              ; If HANGFLAG is zero, jump to hang2 to skip the
                        ; following as there is only one ship in the hangar

                        ; If we get here then there are multiple ships in the
                        ; hangar, so we also need to draw the horizontal line in
                        ; the gap between the ships

 LDA #128               ; Set A = 128 so the call to HAL3 draws a horizontal
                        ; line that starts at pixel x-coordinate 128 (i.e.
                        ; from halfway across the screen)

 LDX #12                ; Set X = 12 so the call to HAL3 draws a horizontal line
                        ; of up to 12 blocks, which will be enough to draw
                        ; between the ships

 JSR HAL3               ; Call HAL3 to draw a line from the halfway point across
                        ; the right half of the screen, going right until we
                        ; bump into something already on-screen, at which point
                        ; it stops drawing

 LDA #127               ; Set A = 127 so the call to HAS3 draws a horizontal
                        ; line that starts at pixel x-coordinate 127 (i.e.
                        ; just before the halfway point)

 LDX #12                ; Set X = 12 so the call to HAL3 draws a horizontal line
                        ; of up to 12 blocks, which will be enough to draw
                        ; between the ships

 JSR HAS3               ; Draw a horizontal line from the right edge of the
                        ; screen, going left until we bump into something
                        ; already on-screen, at which point stop drawing

.hang2

                        ; We have finished threading our horizontal line behind
                        ; the ships already on-screen, so now for the next line

 LDX TGT                ; Set X to the number of the floor line we are drawing

 INX                    ; Increment X to move on to the next floor line

 CPX #4                 ; Loop back to hang1 to draw the next floor line until
 BNE hang1              ; we have drawn all four

                        ; The floor is done, so now we move on to the back wall

 JSR DORND              ; Set A to a random number between 0 and 7, with bit 2
 AND #7                 ; set, to give a random number in the range 4 to 7,
 ORA #4                 ; which we use as the x-coordinate of the first vertical
                        ; line in the hangar wall

 LDY #0                 ; Set Y = 0 so the call to DrawHangarWallLine starts
                        ; drawing the wall lines in the first tile of the screen
                        ; row, at the left edge of the screen

.hang3

 JSR DrawHangarWallLine ; Draw a vertical wall line at x-coordinate A

 CLC                    ; Add 10 to A
 ADC #10

 BCS hang4              ; If adding 10 made the addition overflow then we have
                        ; fallen off the right edge of the screen, so jump to
                        ; hang4 to return from the subroutine

 CMP #248               ; Loop back until we have drawn lines all the way to the
 BCC hang3              ; right edge of the screen, not going further than an
                        ; x-coordinate of 247

.hang4

 RTS                    ; Return from the subroutine

; ******************************************************************************
;
;       Name: DrawHangarWallLine
;       Type: Subroutine
;   Category: Ship hangar
;    Summary: Draw a vertical hangar wall line from top to bottom, stopping when
;             it bumps into existing on-screen content
;
; ******************************************************************************

.DrawHangarWallLine

 STA S                  ; Store A in S so we can retrieve it when returning
                        ; from the subroutine

 STY YSAV               ; Store Y in YSAV so we can retrieve it when returning
                        ; from the subroutine

 LSR A                  ; Set SC2(1 0) = (nameBufferHi 0) + yLookup(Y) + A / 8
 LSR A                  ;
 LSR A                  ; where yLookup(Y) uses the (yLookupHi yLookupLo) table
 CLC                    ; to convert the pixel y-coordinate in Y into the number
 ADC yLookupLo,Y        ; of the first tile on the row containing the pixel
 STA SC2                ;
 LDA nameBufferHi       ; Adding nameBufferHi and A / 8 therefore sets SC2(1 0)
 ADC yLookupHi,Y        ; to the address of the entry in the nametable buffer
 STA SC2+1              ; that contains the tile number for the tile containing
                        ; the pixel at (A, Y), i.e. the start of the line we are
                        ; drawing

 LDA S                  ; Set T = S mod 8, which is the pixel column within the
 AND #7                 ; character block at which we want to draw the start of
 STA T                  ; our line (as each character block has 8 columns)
                        ;
                        ; As we are drawing a vertical line, we do not need to
                        ; vary the value of T, as we will always want to draw on
                        ; the same pixel column within each character block

.hanw1

 SETUP_PPU_FOR_ICON_BAR ; If the PPU has started drawing the icon bar, configure
                        ; the PPU to use nametable 0 and pattern table 0

 LDX #0                 ; If the nametable buffer entry is zero for the tile
 LDA (SC2,X)            ; containing the pixels that we want to draw, then a
 BEQ hanw3              ; pattern has not yet been allocated to this entry, so
                        ; jump to hanw3 to allocate a new pattern

 LDX pattBufferHiDiv8   ; Set SC(1 0) = (pattBufferHiDiv8 A) * 8
 STX SC+1               ;             = (pattBufferHi 0) + A * 8
 ASL A                  ;
 ROL SC+1               ; So SC(1 0) is the address in the pattern buffer for
 ASL A                  ; pattern number A (as each pattern contains 8 bytes of
 ROL SC+1               ; pattern data), which means SC(1 0) points to the
 ASL A                  ; pattern data for the tile containing the line we are
 ROL SC+1               ; drawing
 STA SC

 LDY #0                 ; We want to start drawing the line from the top pixel
                        ; line in the next character row, so set Y = 0 to use as
                        ; the pixel row number

 LDX T                  ; Set X to the pixel column within the character block
                        ; at which we want to draw our line, which we stored in
                        ; T above

.hanw2

 LDA (SC),Y             ; We now work out whether the pixel in column X would
 AND TWOS,X             ; overlap with the top edge of the on-screen ship, which
                        ; we do by AND'ing the pixel pattern with the on-screen
                        ; pixel pattern in SC+Y, so if there are any pixels in
                        ; both the pixel pattern and on-screen, they will be set
                        ; in the result

 BNE hanw5              ; If the result is non-zero then our pixel in column X
                        ; does indeed overlap with the on-screen ship, so we
                        ; need to stop drawing our well line, so jump to hanw5
                        ; to return from the subroutine

                        ; If we get here then our pixel in column X does not
                        ; overlap with the on-screen ship, so we can draw it

 LDA (SC),Y             ; Draw a pixel at x-coordinate X into the Y-th byte
 ORA TWOS,X             ; of SC(1 0)
 STA (SC),Y

 INY                    ; Increment the y-coordinate in Y so we move down the
                        ; line by one pixel

 CPY #8                 ; If Y <> 8, loop back to hanw2 draw the next pixel as
 BNE hanw2              ; we haven't yet reached the bottom of the character
                        ; block containing the line's top end

 JMP hanw4              ; Otherwise we have finished drawing the vertical line
                        ; in this character row, so jump to hanw4 to move down
                        ; to the next row

.hanw3

 LDA T                  ; Set A to the pixel column within the character block
                        ; at which we want to draw our line, which we stored in
                        ; T above

 CLC                    ; Patterns 52 to 59 contain pre-rendered patterns as
 ADC #52                ; follows:
                        ;
                        ;   * Pattern 52 has a vertical line in pixel column 0
                        ;   * Pattern 53 has a vertical line in pixel column 1
                        ;     ...
                        ;   * Pattern 58 has a vertical line in pixel column 6
                        ;   * Pattern 59 has a vertical line in pixel column 7
                        ;
                        ; So A contains the pre-rendered pattern number that
                        ; contains an 8-pixel line in pixel column T, and as T
                        ; contains the offset of the pixel column for the line
                        ; we are drawing, this means A contains the correct
                        ; pattern number for this part of the line

 STA (SC2,X)            ; Display the pre-rendered pattern on-screen by setting
                        ; the nametable entry to A

.hanw4

                        ; Next, we update SC2(1 0) to the address of the next
                        ; row down in the nametable buffer, which we can do by
                        ; adding 32 as there are 32 tiles in each row

 LDA SC2                ; Set SC2(1 0) = SC2(1 0) + 32
 CLC                    ;
 ADC #32                ; Starting with the low bytes
 STA SC2

 BCC hanw1              ; And then the high bytes, jumping to hanw1 when we are
 INC SC2+1              ; done to draw the vertical line on the next row
 JMP hanw1

.hanw5

 LDA S                  ; Retrieve the value of A we stored above, so A is
                        ; preserved

 LDY YSAV               ; Retrieve the value of Y we stored above, so Y is
                        ; preserved

 RTS                    ; Return from the subroutine

; ******************************************************************************
;
;       Name: HAL3
;       Type: Subroutine
;   Category: Ship hangar
;    Summary: Draw a hangar background line from left to right, stopping when it
;             bumps into existing on-screen content
;
; ------------------------------------------------------------------------------
;
; This routine does a similar job to the routine of the same name in the BBC
; Master version of Elite, but the code is significantly different.
;
; ******************************************************************************

.HAL3

 STX R                  ; Set R to the line length in X

 STY YSAV               ; Store Y in YSAV so we can retrieve it below

 LSR A                  ; Set SC2(1 0) = (nameBufferHi 0) + yLookup(Y) + A / 8
 LSR A                  ;
 LSR A                  ; where yLookup(Y) uses the (yLookupHi yLookupLo) table
 CLC                    ; to convert the pixel y-coordinate in Y into the number
 ADC yLookupLo,Y        ; of the first tile on the row containing the pixel
 STA SC2                ;
 LDA nameBufferHi       ; Adding nameBufferHi and A / 8 therefore sets SC2(1 0)
 ADC yLookupHi,Y        ; to the address of the entry in the nametable buffer
 STA SC2+1              ; that contains the tile number for the tile containing
                        ; the pixel at (A, Y), i.e. the start of the line we are
                        ; drawing

 TYA                    ; Set Y = Y mod 8, which is the pixel row within the
 AND #7                 ; character block at which we want to draw the start of
 TAY                    ; our line (as each character block has 8 rows)
                        ;
                        ; As we are drawing a horizontal line, we do not need to
                        ; vary the value of Y, as we will always want to draw on
                        ; the same pixel row within each character block

.hanl1

 SETUP_PPU_FOR_ICON_BAR ; If the PPU has started drawing the icon bar, configure
                        ; the PPU to use nametable 0 and pattern table 0

 LDX #0                 ; If the nametable buffer entry is zero for the tile
 LDA (SC2,X)            ; containing the pixels that we want to draw, then a
 BEQ hanl7              ; pattern has not yet been allocated to this entry, so
                        ; jump to hanl7 to allocate a new pattern

 LDX pattBufferHiDiv8   ; Set SC(1 0) = (pattBufferHiDiv8 A) * 8
 STX SC+1               ;             = (pattBufferHi 0) + A * 8
 ASL A                  ;
 ROL SC+1               ; So SC(1 0) is the address in the pattern buffer for
 ASL A                  ; pattern number A (as each pattern contains 8 bytes of
 ROL SC+1               ; pattern data), which means SC(1 0) points to the
 ASL A                  ; pattern data for the tile containing the line we are
 ROL SC+1               ; drawing
 STA SC

 LDA (SC),Y             ; If the pattern data where we want to draw the line is
 BEQ hanl4              ; zero, then there is nothing currently on-screen at
                        ; this point, so jump to hanl4 to draw a full 8-pixel
                        ; line into the pattern data for this tile

                        ; There is something on-screen where we want to draw our
                        ; line, so we now draw the line until it bumps into
                        ; what's already on-screen, so the floor line goes right
                        ; up to the edge of the ship in the hangar

 LDA #%10000000         ; Set A to a pixel byte containing one set pixel at the
                        ; left end of the 8-pixel row, which we can extend to
                        ; the right by one pixel each time until it meets the
                        ; edge of the on-screen ship

.hanl2

 STA T                  ; Store the current pixel pattern in T

 AND (SC),Y             ; We now work out whether the pixel pattern in A would
                        ; overlap with the edge of the on-screen ship, which we
                        ; do by AND'ing the pixel pattern with the on-screen
                        ; pixel pattern in SC+Y, so if there are any pixels in
                        ; both the pixel pattern and on-screen, they will be set
                        ; in the result

 BNE hanl3              ; If the result is non-zero then our pixel pattern in A
                        ; does indeed overlap with the on-screen ship, so this
                        ; is the pattern we want, so jump to hanl3 to draw it

                        ; If we get here then our pixel pattern in A does not
                        ; overlap with the on-screen ship, so we need to extend
                        ; our pattern to the right by one pixel and try again

 LDA T                  ; Shift the whole pixel pattern to the right by one
 SEC                    ; pixel, shifting a set pixel into the left end (bit 7)
 ROR A

 JMP hanl2              ; Jump back to hanl2 to check whether our extended pixel
                        ; pattern has reached the edge of the ship yet

.hanl3

 LDA T                  ; Draw our pixel pattern into the pattern buffer, using
 ORA (SC),Y             ; OR logic so it overwrites what's already there and
 STA (SC),Y             ; merges into the existing ship edge

 LDY YSAV               ; Retrieve the value of Y we stored above, so Y is
                        ; preserved

 RTS                    ; Return from the subroutine

.hanl4

                        ; If we get here then we can draw a full 8-pixel wide
                        ; horizontal line into the pattern data for the current
                        ; tile, as there is nothing there already

 LDA #%11111111         ; Set A to a pixel byte containing eight pixels in a row

 STA (SC),Y             ; Store the 8-pixel line in the Y-th entry in the
                        ; pattern buffer

.hanl5

 DEC R                  ; Decrement the line length in R

 BEQ hanl6              ; If we have drawn all R blocks, jump to hanl6 to return
                        ; from the subroutine

 INC SC2                ; Increment SC2(1 0) to point to the next nametable
 BNE hanl1              ; entry to the right, starting with the low byte, and
                        ; if the increment didn't wrap the low byte round to
                        ; zero, jump back to hanl1 to draw the next block of the
                        ; horizontal line

 INC SC2+1              ; The low byte of SC2(1 0) incremented round to zero, so
 JMP hanl1              ; we also need to increment the high byte before jumping
                        ; back to hanl1 to draw the next block of the horizontal
                        ; line

.hanl6

 LDY YSAV               ; Retrieve the value of Y we stored above, so Y is
                        ; preserved

 RTS                    ; Return from the subroutine

.hanl7

                        ; If we get here then there is no pattern allocated to
                        ; the part of the line we want to draw, so we can use
                        ; one of the pre-rendered patterns that contains an
                        ; 8-pixel horizontal line on the correct pixel row
                        ;
                        ; We jump here with X = 0

 TYA                    ; Set A = Y + 37
 CLC                    ;
 ADC #37                ; Patterns 37 to 44 contain pre-rendered patterns as
                        ; follows:
                        ;
                        ;   * Pattern 37 has a horizontal line on pixel row 0
                        ;   * Pattern 38 has a horizontal line on pixel row 1
                        ;     ...
                        ;   * Pattern 43 has a horizontal line on pixel row 6
                        ;   * Pattern 44 has a horizontal line on pixel row 7
                        ;
                        ; So A contains the pre-rendered pattern number that
                        ; contains an 8-pixel line on pixel row Y, and as Y
                        ; contains the offset of the pixel row for the line we
                        ; are drawing, this means A contains the correct pattern
                        ; number for this part of the line

 STA (SC2,X)            ; Display the pre-rendered pattern on-screen by setting
                        ; the nametable entry to A

 JMP hanl5              ; Jump up to hanl5 to move on to the next character
                        ; block to the right

; ******************************************************************************
;
;       Name: HAS3
;       Type: Subroutine
;   Category: Ship hangar
;    Summary: Draw a hangar background line from right to left
;
; ------------------------------------------------------------------------------
;
; This routine does a similar job to the routine of the same name in the BBC
; Master version of Elite, but the code is significantly different.
;
; ******************************************************************************

.HAS3

 STX R                  ; Set R to the line length in X

 STY YSAV               ; Store Y in YSAV so we can retrieve it below

 LSR A                  ; Set SC2(1 0) = (nameBufferHi 0) + yLookup(Y) + A / 8
 LSR A                  ;
 LSR A                  ; where yLookup(Y) uses the (yLookupHi yLookupLo) table
 CLC                    ; to convert the pixel y-coordinate in Y into the number
 ADC yLookupLo,Y        ; of the first tile on the row containing the pixel
 STA SC2                ;
 LDA nameBufferHi       ; Adding nameBufferHi and A / 8 therefore sets SC2(1 0)
 ADC yLookupHi,Y        ; to the address of the entry in the nametable buffer
 STA SC2+1              ; that contains the tile number for the tile containing
                        ; the pixel at (A, Y), i.e. the start of the line we are
                        ; drawing

 TYA                    ; Set Y = Y mod 8, which is the pixel row within the
 AND #7                 ; character block at which we want to draw the start of
 TAY                    ; our line (as each character block has 8 rows)
                        ;
                        ; As we are drawing a horizontal line, we do not need to
                        ; vary the value of Y, as we will always want to draw on
                        ; the same pixel row within each character block

.hanr1

 SETUP_PPU_FOR_ICON_BAR ; If the PPU has started drawing the icon bar, configure
                        ; the PPU to use nametable 0 and pattern table 0

 LDX #0                 ; If the nametable buffer entry is zero for the tile
 LDA (SC2,X)            ; containing the pixels that we want to draw, then a
 BEQ hanr8              ; pattern has not yet been allocated to this entry, so
                        ; jump to hanr8 to allocate a new pattern

 LDX pattBufferHiDiv8   ; Set SC(1 0) = (pattBufferHiDiv8 A) * 8
 STX SC+1               ;             = (pattBufferHi 0) + A * 8
 ASL A                  ;
 ROL SC+1               ; So SC(1 0) is the address in the pattern buffer for
 ASL A                  ; pattern number A (as each pattern contains 8 bytes of
 ROL SC+1               ; pattern data), which means SC(1 0) points to the
 ASL A                  ; pattern data for the tile containing the line we are
 ROL SC+1               ; drawing
 STA SC

 LDA (SC),Y             ; If the pattern data where we want to draw the line is
 BEQ hanr5              ; zero, then there is nothing currently on-screen at
                        ; this point, so jump to hanr5 to draw a full 8-pixel
                        ; line into the pattern data for this tile

                        ; There is something on-screen where we want to draw our
                        ; line, so we now draw the line until it bumps into
                        ; what's already on-screen, so the floor line goes right
                        ; up to the edge of the ship in the hangar

 LDA #%00000001         ; Set A to a pixel byte containing one set pixel at the
                        ; right end of the 8-pixel row, which we can extend to
                        ; the left by one pixel each time until it meets the
                        ; edge of the on-screen ship

.hanr2

 STA T                  ; Store the current pixel pattern in T

 AND (SC),Y             ; We now work out whether the pixel pattern in A would
                        ; overlap with the edge of the on-screen ship, which we
                        ; do by AND'ing the pixel pattern with the on-screen
                        ; pixel pattern in SC+Y, so if there are any pixels in
                        ; both the pixel pattern and on-screen, they will be set
                        ; in the result

 BNE hanr3              ; If the result is non-zero then our pixel pattern in A
                        ; does indeed overlap with the on-screen ship, so this
                        ; is the pattern we want, so jump to hanr3 to draw it

                        ; If we get here then our pixel pattern in A does not
                        ; overlap with the on-screen ship, so we need to extend
                        ; our pattern to the left by one pixel and try again

 LDA T                  ; Shift the whole pixel pattern to the left by one
 SEC                    ; pixel, shifting a set pixel into the right end (bit 0)
 ROL A

 JMP hanr2              ; Jump back to hanr2 to check whether our extended pixel
                        ; pattern has reached the edge of the ship yet

.hanr3

 LDA T                  ; Draw our pixel pattern into the pattern buffer, using
 ORA (SC),Y             ; OR logic so it overwrites what's already there and
 STA (SC),Y             ; merges into the existing ship edge

.hanr4

 LDY YSAV               ; Retrieve the value of Y we stored above, so Y is
                        ; preserved

 RTS                    ; Return from the subroutine

.hanr5

                        ; If we get here then we can draw a full 8-pixel wide
                        ; horizontal line into the pattern data for the current
                        ; tile, as there is nothing there already

 LDA #%11111111         ; Set A to a pixel byte containing eight pixels in a row

 STA (SC),Y             ; Store the 8-pixel line in the Y-th entry in the
                        ; pattern buffer

.hanr6

 DEC R                  ; Decrement the line length in R

 BEQ hanr4              ; If we have drawn all R blocks, jump to hanr4 to return
                        ; from the subroutine

 LDA SC2                ; We now decrement SC2(1 0) to point to the next
 BNE hanr7              ; nametable entry to the left, so check whether the low
                        ; byte of SC2(1 0) is non-zero, and if so jump to hanr7
                        ; to decrement it

 DEC SC2+1              ; Otherwise we also need to decrement the high byte
                        ; before decrementing the low byte round to $FF

.hanr7

 DEC SC2                ; Decrement the low byte of SC2(1 0)

 JMP hanr1              ; Jump back to hanr1 to draw the next block of the
                        ; horizontal line

.hanr8

                        ; If we get here then there is no pattern allocated to
                        ; the part of the line we want to draw, so we can use
                        ; one of the pre-rendered patterns that contains an
                        ; 8-pixel horizontal line on the correct pixel row
                        ;
                        ; We jump here with X = 0

 TYA                    ; Set A = Y + 37
 CLC                    ;
 ADC #37                ; Patterns 37 to 44 contain pre-rendered patterns as
                        ; follows:
                        ;
                        ;   * Pattern 37 has a horizontal line on pixel row 0
                        ;   * Pattern 38 has a horizontal line on pixel row 1
                        ;     ...
                        ;   * Pattern 43 has a horizontal line on pixel row 6
                        ;   * Pattern 44 has a horizontal line on pixel row 7
                        ;
                        ; So A contains the pre-rendered pattern number that
                        ; contains an 8-pixel line on pixel row Y, and as Y
                        ; contains the offset of the pixel row for the line we
                        ; are drawing, this means A contains the correct pattern
                        ; number for this part of the line

 STA (SC2,X)            ; Display the pre-rendered pattern on-screen by setting
                        ; the nametable entry to A

 JMP hanr6              ; Jump up to hanr6 to move on to the next character
                        ; block to the left

; ******************************************************************************
;
;       Name: HATB
;       Type: Variable
;   Category: Ship hangar
;    Summary: Ship hangar group table
;
; ------------------------------------------------------------------------------
;
; This table contains groups of ships to show in the ship hangar. A group of
; ships is shown half the time (the other half shows a solo ship), and each of
; the four groups is equally likely.
;
; The bytes for each ship in the group contain the following information:
;
;   Byte #0             Non-zero = Ship type to draw
;                       0        = don't draw anything
;
;   Byte #1             Bits 0-7 = Ship's x_hi
;                       Bit 0    = Ship's z_hi (1 if clear, or 2 if set)
;
;   Byte #2             Bits 0-7 = Ship's z_lo
;                       Bit 0    = Ship's x_sign
;
; The ship's y-coordinate is calculated in the has1 routine from the size of
; its targetable area. Ships of type 0 are not shown.
;
; ******************************************************************************

.HATB

                        ; Hangar group for X = 0
                        ;
                        ; Shuttle (left) and Transporter (right)

 EQUB 9                 ; Ship type = 9 = Shuttle
 EQUB %01010100         ; x_hi = %01010100 = 84, z_hi   = 1     -> x = -84
 EQUB %00111011         ; z_lo = %00111011 = 59, x_sign = 1        z = +315

 EQUB 10                ; Ship type = 10 = Transporter
 EQUB %10000010         ; x_hi = %10000010 = 130, z_hi   = 1    -> x = +130
 EQUB %10110000         ; z_lo = %10110000 = 176, x_sign = 0       z = +432

 EQUB 0                 ; No third ship
 EQUB 0
 EQUB 0

                        ; Hangar group for X = 9
                        ;
                        ; Three cargo canisters (left, far right and forward,
                        ; right)

 EQUB OIL               ; Ship type = OIL = Cargo canister
 EQUB %01010000         ; x_hi = %01010000 = 80, z_hi   = 1     -> x = -80
 EQUB %00010001         ; z_lo = %00010001 = 17, x_sign = 1        z = +273

 EQUB OIL               ; Ship type = OIL = Cargo canister
 EQUB %11010001         ; x_hi = %11010001 = 209, z_hi = 2      -> x = +209
 EQUB %00101000         ; z_lo = %00101000 =  40, x_sign = 0       z = +552

 EQUB OIL               ; Ship type = OIL = Cargo canister
 EQUB %01000000         ; x_hi = %01000000 = 64, z_hi   = 1     -> x = +64
 EQUB %00000110         ; z_lo = %00000110 = 6,  x_sign = 0        z = +262

                        ; Hangar group for X = 18
                        ;
                        ; Viper (right) and Krait (left)

 EQUB COPS              ; Ship type = COPS = Viper
 EQUB %01100000         ; x_hi = %01100000 =  96, z_hi   = 1    -> x = +96
 EQUB %10010000         ; z_lo = %10010000 = 144, x_sign = 0       z = +400

 EQUB KRA               ; Ship type = KRA = Krait
 EQUB %00010000         ; x_hi = %00010000 =  16, z_hi   = 1    -> x = -16
 EQUB %11010001         ; z_lo = %11010001 = 209, x_sign = 1       z = +465

 EQUB 0                 ; No third ship
 EQUB 0
 EQUB 0

                        ; Hangar group for X = 27
                        ;
                        ; Viper (right and forward) and Krait (left)

 EQUB 16                ; Ship type = 16 = Viper
 EQUB %01010001         ; x_hi = %01010001 =  81, z_hi  = 2     -> x = +81
 EQUB %11111000         ; z_lo = %11111000 = 248, x_sign = 0       z = +760

 EQUB 19                ; Ship type = 19 = Krait
 EQUB %01100000         ; x_hi = %01100000 = 96,  z_hi   = 1    -> x = -96
 EQUB %01110101         ; z_lo = %01110101 = 117, x_sign = 1       z = +373

 EQUB 0                 ; No third ship
 EQUB 0
 EQUB 0

; ******************************************************************************
;
;       Name: HALL
;       Type: Subroutine
;   Category: Ship hangar
;    Summary: Draw the ships in the ship hangar, then draw the hangar
;
; ------------------------------------------------------------------------------
;
; Half the time this will draw one of the four pre-defined ship hangar groups in
; HATB, and half the time this will draw a solitary Sidewinder, Mamba, Krait or
; Adder on a random position. In all cases, the ships will be randomly spun
; around on the ground so they can face in any direction, and larger ships are
; drawn higher up off the ground than smaller ships.
;
; ******************************************************************************

.HALL

 LDA #$00               ; Clear the screen and set the view type in QQ11 to $00
 JSR TT66_b0            ; (Space view with no fonts loaded)

 LDA nmiCounter         ; Set the random number seeds to a fairly random state
 STA RAND+1             ; that's based on the NMI counter (which increments
 LDA #$86               ; every VBlank, so will be pretty random), the current
 STA RAND+3             ; system's galactic x-coordinate (QQ0), the high byte
 LDA QQ0                ; of our combat rank (TALLY+1), and a fixed number $86
 STA RAND
 LDA TALLY+1
 STA RAND+2

 JSR DORND              ; Set A and X to random numbers

 BPL HA7                ; Jump to HA7 if A is positive (50% chance)

 AND #3                 ; Reduce A to a random number in the range 0-3

 STA T                  ; Set X = A * 8 + A
 ASL A                  ;       = 9 * A
 ASL A                  ;
 ASL A                  ; so X is a random number, either 0, 9, 18 or 27
 ADC T
 TAX

                        ; The following double loop calls the HAS1 routine three
                        ; times to display three ships on screen. For each call,
                        ; the values passed to HAS1 in XX15+2 to XX15 are taken
                        ; from the HATB table, depending on the value in X, as
                        ; follows:
                        ;
                        ;   * If X = 0,  pass bytes #0 to #2 of HATB to HAS1
                        ;                then bytes #3 to #5
                        ;                then bytes #6 to #8
                        ;
                        ;   * If X = 9,  pass bytes  #9 to #11 of HATB to HAS1
                        ;                then bytes #12 to #14
                        ;                then bytes #15 to #17
                        ;
                        ;   * If X = 18, pass bytes #18 to #20 of HATB to HAS1
                        ;                then bytes #21 to #23
                        ;                then bytes #24 to #26
                        ;
                        ;   * If X = 27, pass bytes #27 to #29 of HATB to HAS1
                        ;                then bytes #30 to #32
                        ;                then bytes #33 to #35
                        ;
                        ; Note that the values are passed in reverse, so for the
                        ; first call, for example, where we pass bytes #0 to #2
                        ; of HATB to HAS1, we call HAS1 with:
                        ;
                        ;   XX15   = HATB+2
                        ;   XX15+1 = HATB+1
                        ;   XX15+2 = HATB

 LDY #3                 ; Set CNT2 = 3 to act as an outer loop counter going
 STY CNT2               ; from 3 to 1, so the HAL8 loop is run 3 times

.HAL8

 LDY #2                 ; Set Y = 2 to act as an inner loop counter going from
                        ; 2 to 0

.HAL9

 LDA HATB,X             ; Copy the X-th byte of HATB to the Y-th byte of XX15,
 STA XX15,Y             ; as described above

 INX                    ; Increment X to point to the next byte in HATB

 DEY                    ; Decrement Y to point to the previous byte in XX15

 BPL HAL9               ; Loop back to copy the next byte until we have copied
                        ; three of them (i.e. Y was 3 before the DEY)

 TXA                    ; Store X on the stack so we can retrieve it after the
 PHA                    ; call to HAS1 (as it contains the index of the next
                        ; byte in HATB

 JSR HAS1               ; Call HAS1 to draw this ship in the hangar

 PLA                    ; Restore the value of X, so X points to the next byte
 TAX                    ; in HATB after the three bytes we copied into XX15

 DEC CNT2               ; Decrement the outer loop counter in CNT2

 BNE HAL8               ; Loop back to HAL8 to do it 3 times, once for each ship
                        ; in the HATB table

 LDY #128               ; Set Y = 128 to send as byte #2 of the parameter block
                        ; to the OSWORD 248 command below, to tell the I/O
                        ; processor that there are multiple ships in the hangar

 BNE HA9                ; Jump to HA9 to display the ship hangar (this BNE is
                        ; effectively a JMP as Y is never zero)

.HA7

                        ; If we get here, A is a positive random number in the
                        ; range 0-127

 LSR A                  ; Set XX15+1 = A / 2 (random number 0-63)
 STA XX15+1

 JSR DORND              ; Set XX15 = random number 0-255
 STA XX15

 JSR DORND              ; Set XX15+2 = #SH3 + random number 0-3
 AND #3                 ;
 ADC #SH3               ; which is the ship type of a Sidewinder, Mamba, Krait
 STA XX15+2             ; or Adder

 JSR HAS1               ; Call HAS1 to draw this ship in the hangar, with the
                        ; following properties:
                        ;
                        ;   * Random x-coordinate from -63 to +63
                        ;
                        ;   * Randomly chosen Sidewinder, Mamba, Krait or Adder
                        ;
                        ;   * Random z-coordinate from +256 to +639

 LDY #0                 ; Set Y = 0 to use in the following instruction, to tell
                        ; the hangar-drawing routine that there is just one ship
                        ; in the hangar, so it knows not to draw between the
                        ; ships

.HA9

 STY HANGFLAG           ; Store Y in HANGFLAG to specify whether there are
                        ; multiple ships in the hangar

 JSR HANGER             ; Call HANGER to draw the hangar background

 LDA #0                 ; Tell the NMI handler to send pattern entries from
 STA firstPattern       ; pattern 0 in the buffer

 LDA #80                ; Tell the NMI handler to only clear nametable entries
 STA maxNameTileToClear ; up to tile 80 * 8 = 640 (i.e. up to the end of tile
                        ; row 19)

 JMP UpdateHangarView   ; Update the hangar view on-screen by sending the data
                        ; to the PPU, returning from the subroutine using a tail
                        ; call

; ******************************************************************************
;
;       Name: ZINF_b1
;       Type: Subroutine
;   Category: Universe
;    Summary: Reset the INWK workspace and orientation vectors
;  Deep dive: Orientation vectors
;
; ------------------------------------------------------------------------------
;
; Zero-fill the INWK ship workspace and reset the orientation vectors, with
; nosev pointing out of the screen, towards us.
;
; Returns:
;
;   Y                   Y is set to $FF
;
; ******************************************************************************

.ZINF_b1

 SETUP_PPU_FOR_ICON_BAR ; If the PPU has started drawing the icon bar, configure
                        ; the PPU to use nametable 0 and pattern table 0

 LDY #NI%-1             ; There are NI% bytes in the INWK workspace, so set a
                        ; counter in Y so we can loop through them

 LDA #0                 ; Set A to 0 so we can zero-fill the workspace

.ZI1

 STA INWK,Y             ; Zero the Y-th byte of the INWK workspace

 DEY                    ; Decrement the loop counter

 BPL ZI1                ; Loop back for the next byte, ending when we have
                        ; zero-filled the last byte at INWK, which leaves Y
                        ; with a value of $FF

                        ; Finally, we reset the orientation vectors as follows:
                        ;
                        ;   sidev = (1,  0,  0)
                        ;   roofv = (0,  1,  0)
                        ;   nosev = (0,  0, -1)
                        ;
                        ; 96 * 256 ($6000) represents 1 in the orientation
                        ; vectors, while -96 * 256 ($E000) represents -1. We
                        ; already set the vectors to zero above, so we just
                        ; need to set up the high bytes of the diagonal values
                        ; and we're done. The negative nosev makes the ship
                        ; point towards us, as the z-axis points into the screen

 SETUP_PPU_FOR_ICON_BAR ; If the PPU has started drawing the icon bar, configure
                        ; the PPU to use nametable 0 and pattern table 0

 LDA #96                ; Set A to represent a 1 (in vector terms)

 STA INWK+18            ; Set byte #18 = roofv_y_hi = 96 = 1

 STA INWK+22            ; Set byte #22 = sidev_x_hi = 96 = 1

 ORA #128               ; Flip the sign of A to represent a -1

 STA INWK+14            ; Set byte #14 = nosev_z_hi = -96 = -1

 RTS                    ; Return from the subroutine

; ******************************************************************************
;
;       Name: HAS1
;       Type: Subroutine
;   Category: Ship hangar
;    Summary: Draw a ship in the ship hangar
;
; ------------------------------------------------------------------------------
;
; The ship's position within the hangar is determined by the arguments and the
; size of the ship's targetable area, as follows:
;
;   * The x-coordinate is (x_sign x_hi 0) from the arguments, so the ship can be
;     left of centre or right of centre
;
;   * The y-coordinate is negative and is lower down the screen for smaller
;     ships, so smaller ships are drawn closer to the ground (because they are)
;
;   * The z-coordinate is positive, with both z_hi (which is 1 or 2) and z_lo
;     coming from the arguments
;
; Arguments:
;
;   XX15                Bits 0-7 = Ship's z_lo
;                       Bit 0    = Ship's x_sign
;
;   XX15+1              Bits 0-7 = Ship's x_hi
;                       Bit 0    = Ship's z_hi (1 if clear, or 2 if set)
;
;   XX15+2              Non-zero = Ship type to draw
;                       0        = Don't draw anything
;
; ******************************************************************************

.HAS1

 JSR ZINF_b1            ; Call ZINF to reset the INWK ship workspace and reset
                        ; the orientation vectors, with nosev pointing out of
                        ; the screen, so this puts the ship flat on the
                        ; horizontal deck (the y = 0 plane) with its nose
                        ; pointing towards us

 LDA XX15               ; Set z_lo = XX15
 STA INWK+6

 LSR A                  ; Set the sign bit of x_sign to bit 0 of A
 ROR INWK+2

 LDA XX15+1             ; Set x_hi = XX15+1
 STA INWK

 LSR A                  ; Set z_hi = 1 + bit 0 of XX15+1
 LDA #1
 ADC #0
 STA INWK+7

 LDA #%10000000         ; Set bit 7 of y_sign, so y is negative
 STA INWK+5

 STA RAT2               ; Set RAT2 = %10000000, so the yaw calls in HAL5 below
                        ; are negative

 LDA #$B                ; This instruction is left over from the other versions
 STA INWK+34            ; of Elite, which store the ship line heap pointer in
                        ; INWK(34 33), but the NES version doesn't have a ship
                        ; line heap, so this instruction has no effect (INWK+34
                        ; is reused in NES Elite for the ship's explosion cloud
                        ; counter, but that is ignored by the hangar code)

 JSR DORND              ; We now perform a random number of small angle (3.6
 STA XSAV               ; degree) rotations to spin the ship on the deck while
                        ; keeping it flat on the deck (a bit like spinning a
                        ; bottle), so we set XSAV to a random number between 0
                        ; and 255 for the number of small yaw rotations to
                        ; perform, so the ship could be pointing in any
                        ; direction by the time we're done

.HAL5

 LDX #21                ; Rotate (sidev_x, nosev_x) by a small angle (yaw)
 LDY #9
 JSR MVS5_b0

 LDX #23                ; Rotate (sidev_y, nosev_y) by a small angle (yaw)
 LDY #11
 JSR MVS5_b0

 LDX #25                ; Rotate (sidev_z, nosev_z) by a small angle (yaw)
 LDY #13
 JSR MVS5_b0

 DEC XSAV               ; Decrement the yaw counter in XSAV

 BNE HAL5               ; Loop back to yaw a little more until we have yawed
                        ; by the number of times in XSAV

 LDY XX15+2             ; Set Y = XX15+2, the ship type of the ship we need to
                        ; draw

 BEQ HA1                ; If Y = 0, return from the subroutine (as HA1 contains
                        ; an RTS)

 TYA                    ; Set X = 2 * Y
 ASL A
 TAX

 LDA XX21-2,X           ; Set XX0(1 0) to the X-th address in the ship blueprint
 STA XX0                ; address lookup table at XX21, so XX0(1 0) now points
 LDA XX21-1,X           ; to the blueprint for the ship we need to draw
 STA XX0+1

 BEQ HA1                ; If the high byte of the blueprint address is 0, then
                        ; this is not a valid blueprint address, so return from
                        ; the subroutine (as HA1 contains an RTS)

 LDY #1                 ; Set Q = ship byte #1
 LDA (XX0),Y
 STA Q

 INY                    ; Set R = ship byte #2
 LDA (XX0),Y            ;
 STA R                  ; so (R Q) contains the ship's targetable area, which is
                        ; a square number

 JSR LL5                ; Set Q = SQRT(R Q)

 LDA #100               ; Set y_lo = (100 - Q) / 2
 SBC Q                  ;
 LSR A                  ; so the bigger the ship's targetable area, the smaller
 STA INWK+3             ; the magnitude of the y-coordinate, so because we set
                        ; y_sign to be negative above, this means smaller ships
                        ; are drawn lower down, i.e. closer to the ground, while
                        ; larger ships are drawn higher up, as you would expect

 JSR TIDY               ; Call TIDY to tidy up the orientation vectors, to
                        ; prevent the ship from getting elongated and out of
                        ; shape due to the imprecise nature of trigonometry
                        ; in assembly language

 JMP LL9                ; Jump to LL9 to display the ship and return from the
                        ; subroutine using a tail call

.HA1

 RTS                    ; Return from the subroutine

; ******************************************************************************
;
;       Name: TIDY
;       Type: Subroutine
;   Category: Maths (Geometry)
;    Summary: Orthonormalise the orientation vectors for a ship
;  Deep dive: Tidying orthonormal vectors
;             Orientation vectors
;
; ------------------------------------------------------------------------------
;
; This routine orthonormalises the orientation vectors for a ship. This means
; making the three orientation vectors orthogonal (perpendicular to each other),
; and normal (so each of the vectors has length 1).
;
; We do this because we use the small angle approximation to rotate these
; vectors in space. It is not completely accurate, so the three vectors tend
; to get stretched over time, so periodically we tidy the vectors with this
; routine to ensure they remain as orthonormal as possible.
;
; ******************************************************************************

.TI2

                        ; Called from below with A = 0, X = 0, Y = 4 when
                        ; nosev_x and nosev_y are small, so we assume that
                        ; nosev_z is big

 TYA                    ; A = Y = 4
 LDY #2
 JSR TIS3               ; Call TIS3 with X = 0, Y = 2, A = 4, to set roofv_z =
 STA INWK+20            ; -(nosev_x * roofv_x + nosev_y * roofv_y) / nosev_z

 JMP TI3                ; Jump to TI3 to keep tidying

.TI1

                        ; Called from below with A = 0, Y = 4 when nosev_x is
                        ; small

 TAX                    ; Set X = A = 0

 LDA XX15+1             ; Set A = nosev_y, and if the top two magnitude bits
 AND #%01100000         ; are both clear, jump to TI2 with A = 0, X = 0, Y = 4
 BEQ TI2

 LDA #2                 ; Otherwise nosev_y is big, so set up the index values
                        ; to pass to TIS3

 JSR TIS3               ; Call TIS3 with X = 0, Y = 4, A = 2, to set roofv_y =
 STA INWK+18            ; -(nosev_x * roofv_x + nosev_z * roofv_z) / nosev_y

 JMP TI3                ; Jump to TI3 to keep tidying

.TIDY

 SETUP_PPU_FOR_ICON_BAR ; If the PPU has started drawing the icon bar, configure
                        ; the PPU to use nametable 0 and pattern table 0

 LDA INWK+10            ; Set (XX15, XX15+1, XX15+2) = nosev
 STA XX15
 LDA INWK+12
 STA XX15+1
 LDA INWK+14
 STA XX15+2

 JSR NORM               ; Call NORM to normalise the vector in XX15, i.e. nosev

 LDA XX15               ; Set nosev = (XX15, XX15+1, XX15+2)
 STA INWK+10
 LDA XX15+1
 STA INWK+12
 LDA XX15+2
 STA INWK+14

 LDY #4                 ; Set Y = 4

 LDA XX15               ; Set A = nosev_x, and if the top two magnitude bits
 AND #%01100000         ; are both clear, jump to TI1 with A = 0, Y = 4
 BEQ TI1

 LDX #2                 ; Otherwise nosev_x is big, so set up the index values
 LDA #0                 ; to pass to TIS3

 JSR TIS3               ; Call TIS3 with X = 2, Y = 4, A = 0, to set roofv_x =
 STA INWK+16            ; -(nosev_y * roofv_y + nosev_z * roofv_z) / nosev_x

.TI3

 SETUP_PPU_FOR_ICON_BAR ; If the PPU has started drawing the icon bar, configure
                        ; the PPU to use nametable 0 and pattern table 0

 LDA INWK+16            ; Set (XX15, XX15+1, XX15+2) = roofv
 STA XX15
 LDA INWK+18
 STA XX15+1
 LDA INWK+20
 STA XX15+2

 JSR NORM               ; Call NORM to normalise the vector in XX15, i.e. roofv

 LDA XX15               ; Set roofv = (XX15, XX15+1, XX15+2)
 STA INWK+16
 LDA XX15+1
 STA INWK+18
 LDA XX15+2
 STA INWK+20

 LDA INWK+12            ; Set Q = nosev_y
 STA Q

 LDA INWK+20            ; Set A = roofv_z

 JSR MULT12             ; Set (S R) = Q * A = nosev_y * roofv_z

 LDX INWK+14            ; Set X = nosev_z

 LDA INWK+18            ; Set A = roofv_y

 JSR TIS1               ; Set (A ?) = (-X * A + (S R)) / 96
                        ;        = (-nosev_z * roofv_y + nosev_y * roofv_z) / 96
                        ;
                        ; This also sets Q = nosev_z

 EOR #%10000000         ; Set sidev_x = -A
 STA INWK+22            ;        = (nosev_z * roofv_y - nosev_y * roofv_z) / 96

 SETUP_PPU_FOR_ICON_BAR ; If the PPU has started drawing the icon bar, configure
                        ; the PPU to use nametable 0 and pattern table 0

 LDA INWK+16            ; Set A = roofv_x

 JSR MULT12             ; Set (S R) = Q * A = nosev_z * roofv_x

 LDX INWK+10            ; Set X = nosev_x

 LDA INWK+20            ; Set A = roofv_z

 JSR TIS1               ; Set (A ?) = (-X * A + (S R)) / 96
                        ;        = (-nosev_x * roofv_z + nosev_z * roofv_x) / 96
                        ;
                        ; This also sets Q = nosev_x

 EOR #%10000000         ; Set sidev_y = -A
 STA INWK+24            ;        = (nosev_x * roofv_z - nosev_z * roofv_x) / 96

 SETUP_PPU_FOR_ICON_BAR ; If the PPU has started drawing the icon bar, configure
                        ; the PPU to use nametable 0 and pattern table 0

 LDA INWK+18            ; Set A = roofv_y

 JSR MULT12             ; Set (S R) = Q * A = nosev_x * roofv_y

 LDX INWK+12            ; Set X = nosev_y

 LDA INWK+16            ; Set A = roofv_x

 JSR TIS1               ; Set (A ?) = (-X * A + (S R)) / 96
                        ;        = (-nosev_y * roofv_x + nosev_x * roofv_y) / 96

 EOR #%10000000         ; Set sidev_z = -A
 STA INWK+26            ;        = (nosev_y * roofv_x - nosev_x * roofv_y) / 96

 SETUP_PPU_FOR_ICON_BAR ; If the PPU has started drawing the icon bar, configure
                        ; the PPU to use nametable 0 and pattern table 0

 LDA #0                 ; Set A = 0 so we can clear the low bytes of the
                        ; orientation vectors

 LDX #14                ; We want to clear the low bytes, so start from sidev_y
                        ; at byte #9+14 (we clear all except sidev_z_lo, though
                        ; I suspect this is in error and that X should be 16)

.TIL1

 STA INWK+9,X           ; Set the low byte in byte #9+X to zero

 DEX                    ; Set X = X - 2 to jump down to the next low byte
 DEX

 BPL TIL1               ; Loop back until we have zeroed all the low bytes

 RTS                    ; Return from the subroutine

; ******************************************************************************
;
;       Name: TIS3
;       Type: Subroutine
;   Category: Maths (Arithmetic)
;    Summary: Calculate -(nosev_1 * roofv_1 + nosev_2 * roofv_2) / nosev_3
;
; ------------------------------------------------------------------------------
;
; Calculate the following expression:
;
;   A = -(nosev_1 * roofv_1 + nosev_2 * roofv_2) / nosev_3
;
; where 1, 2 and 3 are x, y, or z, depending on the values of X, Y and A. This
; routine is called with the following values:
;
;   X = 0, Y = 2, A = 4 ->
;         A = -(nosev_x * roofv_x + nosev_y * roofv_y) / nosev_z
;
;   X = 0, Y = 4, A = 2 ->
;         A = -(nosev_x * roofv_x + nosev_z * roofv_z) / nosev_y
;
;   X = 2, Y = 4, A = 0 ->
;         A = -(nosev_y * roofv_y + nosev_z * roofv_z) / nosev_x
;
; Arguments:
;
;   X                   Index 1 (0 = x, 2 = y, 4 = z)
;
;   Y                   Index 2 (0 = x, 2 = y, 4 = z)
;
;   A                   Index 3 (0 = x, 2 = y, 4 = z)
;
; ******************************************************************************

.TIS3

 STA P+2                ; Store P+2 in A for later

 LDA INWK+10,X          ; Set Q = nosev_x_hi (plus X)
 STA Q

 LDA INWK+16,X          ; Set A = roofv_x_hi (plus X)

 JSR MULT12             ; Set (S R) = Q * A
                        ;           = nosev_x_hi * roofv_x_hi

 LDX INWK+10,Y          ; Set Q = nosev_x_hi (plus Y)
 STX Q

 LDA INWK+16,Y          ; Set A = roofv_x_hi (plus Y)

 JSR MAD                ; Set (A X) = Q * A + (S R)
                        ;           = (nosev_x,X * roofv_x,X) +
                        ;             (nosev_x,Y * roofv_x,Y)

 STX P                  ; Store low byte of result in P, so result is now in
                        ; (A P)

 LDY P+2                ; Set Q = roofv_x_hi (plus argument A)
 LDX INWK+10,Y
 STX Q

 EOR #%10000000         ; Flip the sign of A

                        ; Fall through into DIVDT to do:
                        ;
                        ;   (P+1 A) = (A P) / Q
                        ;
                        ;     = -((nosev_x,X * roofv_x,X) +
                        ;         (nosev_x,Y * roofv_x,Y))
                        ;       / nosev_x,A

; ******************************************************************************
;
;       Name: DVIDT
;       Type: Subroutine
;   Category: Maths (Arithmetic)
;    Summary: Calculate (P+1 A) = (A P) / Q
;
; ------------------------------------------------------------------------------
;
; Calculate the following integer division between sign-magnitude numbers:
;
;   (P+1 A) = (A P) / Q
;
; This uses the same shift-and-subtract algorithm as TIS2.
;
; ******************************************************************************

.DVIDT

 STA P+1                ; Set P+1 = A, so P(1 0) = (A P)

 EOR Q                  ; Set T = the sign bit of A EOR Q, so it's 1 if A and Q
 AND #%10000000         ; have different signs, i.e. it's the sign of the result
 STA T                  ; of A / Q

 LDA #0                 ; Set A = 0 for us to build a result

 LDX #16                ; Set a counter in X to count the 16 bits in P(1 0)

 ASL P                  ; Shift P(1 0) left
 ROL P+1

 ASL Q                  ; Clear the sign bit of Q the C flag at the same time
 LSR Q

.DVL2

 ROL A                  ; Shift A to the left

 CMP Q                  ; If A < Q skip the following subtraction
 BCC P%+4

 SBC Q                  ; Set A = A - Q
                        ;
                        ; Going into this subtraction we know the C flag is
                        ; set as we passed through the BCC above, and we also
                        ; know that A >= Q, so the C flag will still be set once
                        ; we are done

 ROL P                  ; Rotate P(1 0) to the left, and catch the result bit
 ROL P+1                ; into the C flag (which will be a 0 if we didn't
                        ; do the subtraction, or 1 if we did)

 DEX                    ; Decrement the loop counter

 BNE DVL2               ; Loop back for the next bit until we have done all 16
                        ; bits of P(1 0)

 LDA P                  ; Set A = P so the low byte is in the result in A

 ORA T                  ; Set A to the correct sign bit that we set in T above

 RTS                    ; Return from the subroutine

; ******************************************************************************
;
;       Name: SCAN
;       Type: Subroutine
;   Category: Dashboard
;    Summary: Display the current ship on the scanner
;  Deep dive: Sprite usage in NES Elite
;
; ------------------------------------------------------------------------------
;
; This routine does a similar job to the routine of the same name in the BBC
; Master version of Elite, but the code is significantly different.
;
; Arguments:
;
;   INWK                The ship's data block
;
; ******************************************************************************

.scan1

                        ; If we jump here, Y is set to the offset of the first
                        ; sprite for this ship on the scanner, so the three
                        ; sprites are at addresses ySprite0 + Y, ySprite1 + Y
                        ; and ySprite2 + Y

 LDA #240               ; Hide sprites Y to Y+2 in the sprite buffer by setting
 STA ySprite0,Y         ; their y-coordinates to 240, which is off the bottom
 STA ySprite1,Y         ; of the screen
 STA ySprite2,Y         ;
                        ; So this removes the ship's scanner sprites from the
                        ; scanner

.scan2

 RTS                    ; Return from the subroutine

.SCAN

 LDA QQ11               ; If this is not the space view (i.e. QQ11 is non-zero)
 BNE scan2              ; then jump to scan2 to return from the subroutine as
                        ; there is no scanner to update

 LDX TYPE               ; Fetch the ship's type from TYPE into X

 BMI scan2              ; If this is the planet or the sun, then the type will
                        ; have bit 7 set and we don't want to display it on the
                        ; scanner, so jump to scan2 to return from the
                        ; subroutine as there is nothing to draw

 LDA INWK+33            ; Set A to ship byte #33, which contains the number of
                        ; this ship on the scanner

 BEQ scan2              ; If A = 0 then this ship is not being shown on the
                        ; scanner, so jump to scan2 to return from the
                        ; subroutine as there is nothing to draw

 TAX                    ; Set X to the number of this ship on the scanner

 ASL A                  ; Set Y = (A * 2 + A) * 4 + 44
 ADC INWK+33            ;       = 44 + A * 3 * 4
 ASL A                  ;
 ASL A                  ; This gives us the offset of the first sprite for this
 ADC #44                ; ship on the scanner within the sprite buffer, as each
 TAY                    ; ship has three sprites allocated to it, and there are
                        ; four bytes per sprite in the buffer, and the first
                        ; scanner sprite is sprite 11 (which is at offset 44 in
                        ; the buffer)
                        ;
                        ; We will refer to the sprites that we will use to draw
                        ; the ship on the scanner as sprites Y, Y+1 and Y+2,
                        ; just to keep things simple

 LDA scannerColour,X    ; Set A to the scanner colour for this ship, which was
                        ; set to a sprite palette number in the NWSHP routine
                        ; when the ship was added to the local bubble of
                        ; universe

 STA attrSprite0,Y      ; Set the attributes for sprite Y to the value in A,
                        ; so the sprite's attributes are:
                        ;
                        ;   * Bits 0-1    = sprite palette number in A
                        ;   * Bit 5 clear = show in front of background
                        ;   * Bit 6 clear = do not flip horizontally
                        ;   * Bit 7 clear = do not flip vertically
                        ;
                        ; This ensures that the ship appears on the scanner in
                        ; the correct colour for the ship type
                        ;
                        ; We will copy these attributes for use in the other two
                        ; sprites later

                        ; The following algorithm is the same as the FAROF2
                        ; routine, which calculates the distance from our ship
                        ; to the point (x_hi, y_hi, z_hi) to see if the ship is
                        ; close enough to be visible on the scanner
                        ;
                        ; Note that it actually calculates half the distance to
                        ; the point (i.e. 0.5 * |x y z|) as this will ensure the
                        ; result fits into one byte

 LDA INWK+1             ; If x_hi >= y_hi, jump to scan3 to skip the following
 CMP INWK+4             ; instruction, leaving A containing the higher of the
 BCS scan3              ; two values

 LDA INWK+4             ; Set A = y_hi, which is the higher of the two values,
                        ; so by this point we have:
                        ;
                        ;   A = max(x_hi, y_hi)

.scan3

 CMP INWK+7             ; If A >= z_hi, jump to scan4 to skip the following
 BCS scan4              ; instruction, leaving A containing the higher of the
                        ; two values

 LDA INWK+7             ; Set A = z_hi, which is the higher of the two values,
                        ; so by this point we have:
                        ;
                        ;   A = max(x_hi, y_hi, z_hi)

.scan4

 CMP #64                ; If A >= 64 then at least one of x_hi, y_hi and z_hi is
 BCS scan1              ; greater or equal to 64, so jump to scan1 to hide the
                        ; ship's scanner sprites and return from the subroutine,
                        ; as the ship is too far away to appear on the scanner

 STA SC2                ; Otherwise set SC2 = max(x_hi, y_hi, z_hi)
                        ;
                        ; Let's call this max(x, y, z)

 LDA INWK+1             ; Set A = x_hi + y_hi + z_hi
 ADC INWK+4             ;
 ADC INWK+7             ; Let's call this x + y + z
                        ;
                        ; There is a risk that the addition will overflow here,
                        ; but presumably this isn't an issue

 BCS scan1              ; If the addition overflowed then A > 255, so jump to
                        ; scan1 to hide the ship's scanner sprites and return
                        ; from the subroutine, as the ship is too far away to
                        ; appear on the scanner

 SEC                    ; Set SC2+1 = A - SC2 / 4
 SBC SC2                ;         = (x + y + z - max(x, y, z)) / 4
 LSR A
 LSR A
 STA SC2+1

 LSR A                  ; Set A = (SC2+1 / 4) + SC2+1 + SC2
 LSR A                  ;       = 5/4 * SC2+1 + SC2
 ADC SC2+1              ;       = 5 * (x + y + z - max(x, y, z)) / (8 * 4)
 ADC SC2                ;          + max(x, y, z) / 2
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
                        ; This estimates half the length of the (x, y, z)
                        ; vector, i.e. 0.5 * |x y z|, using an approximation
                        ; that estimates the length within 8% of the correct
                        ; value, and without having to do any multiplication
                        ; or take any square roots

 CMP #64                ; If A >= 64 then jump to scan1 to hide the ship's
 BCS scan1              ; scanner sprites and return from the subroutine, as the
                        ; ship is too far away to appear on the scanner

                        ; We now calculate the position of the ship on the
                        ; scanner, starting with the x-coordinate (see the deep
                        ; dive on "The 3D scanner" for an explanation of the
                        ; following)

 LDA INWK+1             ; Set A = x_hi

 CLC                    ; Clear the C flag so we can do addition below

 LDX INWK+2             ; Set X = x_sign

 BPL scan5              ; If x_sign is positive, skip the following

 EOR #%11111111         ; x_sign is negative, so flip the bits in A and add
 ADC #1                 ; 1 to make it a negative number

.scan5

 ADC #124               ; Set SC2 = 124 + (x_sign x_hi)
 STA SC2                ;
                        ; So this gives us the x-coordinate of the ship on the
                        ; scanner

                        ; Next, we convert the z_hi coordinate of the ship into
                        ; the y-coordinate of the base of the ship's stick,
                        ; like this:
                        ;
                        ;   SC2+1 = 199 - (z_sign z_hi) / 4

 LDA INWK+7             ; Set A = z_hi / 4
 LSR A
 LSR A

 CLC                    ; Clear the C flag for the addition below

 LDX INWK+8             ; Set X = z_sign

 BMI scan6              ; If z_sign is negative, skip the following so we add
                        ; the magnitude of x_hi (which is the same as
                        ; subtracting a negative x_hi)

 EOR #%11111111         ; z_sign is positive, so flip the bits in A and set the
 SEC                    ; C flag. This makes A negative using two's complement,
                        ; and as we are about to do an ADC, the SEC effectively
                        ; add the 1 we need, giving A = -x_hi

.scan6

 ADC #199+YPAL          ; Set SC2+1 = 199 + A to give us the y-coordinate of the
 STA SC2+1              ; base of the ship's stick

                        ; Finally, we calculate Y1 to represent the height of
                        ; stick as:
                        ;
                        ;   Y1 = min(y_hi, 47)

 LDA INWK+4             ; Set A = y_hi

 CMP #48                ; If A < 48, jump to scan7 to skip the following
 BCC scan7              ; instruction

 LDA #47                ; Set A = 47, so A contains y_hi capped to a maximum
                        ; value of 47, i.e. A = min(y_hi, 47)

.scan7

 LSR A                  ; Set Y1 = A = min(y_hi, 47)
 STA Y1

 CLC                    ; Clear the C flag (though this has no effect)

                        ; We now have the following data:
                        ;
                        ;   * SC2 is the x-coordinate of the ship on the scanner
                        ;
                        ;   * SC2+1 is the y-coordinate of the base of the
                        ;     ship's stick
                        ;
                        ;   * Y1 is the height of the stick
                        ;
                        ; So now we draw the ship on the scanner, with the first
                        ; step being to work out whether we should draw the ship
                        ; above or below the 3D ellipse (and therefore in front
                        ; of or behind the background tiles that make up the 3D
                        ; ellipse on-screen)

 BEQ scan8              ; If A = 0 then y_hi must be 0, so the ship is exactly
                        ; on the 3D ellipse on the scanner (not above or below
                        ; it), so jump to scan8 to draw the ship in front of
                        ; the ellipse background

 LDX INWK+5             ; If y_sign is positive then the ship is above the 3D
 BPL scan8              ; ellipse on the scanner, so jump to scan8 to draw the
                        ; ship in front of the ellipse background

 JMP scan12             ; Otherwise the ship is below the 3D ellipse on the
                        ; scanner, so jump to scan12 to draw the ship behind
                        ; the ellipse background

.scan8

                        ; If we get here then we draw the ship in front of the
                        ; 3D ellipse

 LDA SC2+1              ; Set SC2+1 = SC2+1 - 8
 SEC                    ;
 SBC #8                 ; This subtracts 8 from the y-coordinate of the bottom
 STA SC2+1              ; of the stick, and ensures that the bottom of the stick
                        ; looks as if it is touching the 3D ellipse

                        ; The ship is drawn on the scanner using up to three
                        ; sprites - sprites Y, Y+1 and Y+2
                        ;
                        ; Sprite Y is the end of the stick that's furthest from
                        ; the ship dot (i.e. the "bottom" of the stick which
                        ; appears to touch the 3D ellipse)
                        ;
                        ; Sprite Y+1 is the middle part of the stick
                        ;
                        ; Sprite Y+2 is the big ship dot at the end of the stick
                        ; (i.e. the "top" of the stick)
                        ;
                        ; If a stick is full height, then we show all three
                        ; sprites, if a stick is medium height we display
                        ; sprites Y+1 and Y+2, and if a stick is small we only
                        ; display sprite Y+2
                        ;
                        ; We always draw sprite Y+2, so first we concentrate on
                        ; drawing sprites Y and Y+1, if required

 LDA Y1                 ; If Y1 < 16 then the stick is either medium or small,
 CMP #16                ; so jump to scan9 to skip the following
 BCC scan9

                        ; If we get here then the stick is full height, so we
                        ; draw both sprite Y and sprite Y+1

 LDA SC2                ; Set the x-coordinate of sprite Y to SC2
 STA xSprite0,Y

 STA xSprite1,Y         ; Set the x-coordinate of sprite Y+1 to SC2

 LDA SC2+1              ; Set the y-coordinate of sprite Y to SC2+1, as SC2+1
 STA ySprite0,Y         ; contains the y-coordinate of the bottom of the stick

 SEC                    ; Set the y-coordinate of sprite Y+1 to SC2+1 - 8, which
 SBC #8                 ; is eight pixels higher up the screen then sprite Y
 STA ySprite1,Y         ;
                        ; This stacks the sprites one above the other, as each
                        ; sprite is eight pixels

 LDA attrSprite0,Y      ; Clear bits 2 to 7 of the attributes for sprite Y to
 AND #%00000011         ; ensure that the following attributes are set:
 STA attrSprite0,Y      ;
                        ;   * Bit 5 clear = show in front of background
                        ;   * Bit 6 clear = do not flip horizontally
                        ;   * Bit 7 clear = do not flip vertically
                        ;
                        ; This makes sure we display the sprite in front of the
                        ; 3D ellipse, as the ship is above the ellipse in space

 STA attrSprite1,Y      ; Set the attributes for sprite Y+1 to the same as those
                        ; for sprite Y

 LDA SC2+1              ; Set SC2+1 = SC2+1 - 16
 SBC #16                ;
 STA SC2+1              ; This subtracts 16 from the y-coordinate of the bottom
                        ; of the stick to give us the y-coordinate of the top
                        ; sprite in the stick

 BNE scan11             ; Jump to scan11 to draw sprite Y+2 at the top of the
                        ; stick (this BNE is effectively a JMP as A is never
                        ; zero)

.scan9

                        ; If we get here then the stick is either medium or
                        ; small height

 CMP #8                 ; If Y1 < 8 then the stick is small, so jump to scan10
 BCC scan10             ; to skip the following

                        ; If we get here then the stick is medium height, so we
                        ; draw sprite Y+1 and hide sprite Y

 LDA #240               ; Hide sprite Y by setting its y-coordinate to 240,
 STA ySprite0,Y         ; which moves it off the bottom of the screen

 LDA SC2                ; Set the x-coordinate of sprite Y+1 to SC2
 STA xSprite1,Y

 LDA SC2+1              ; Set the y-coordinate of sprite Y+1 to SC2+1, as SC2+1
 STA ySprite1,Y         ; contains the y-coordinate of the bottom of the stick
                        ; (which is the middle sprite in a medium height stick)

 LDA attrSprite0,Y      ; Clear bits 2 to 7 of the attributes for sprite Y+1 to
 AND #%00000011         ; ensure that the following attributes are set:
 STA attrSprite1,Y      ;
                        ;   * Bit 5 clear = show in front of background
                        ;   * Bit 6 clear = do not flip horizontally
                        ;   * Bit 7 clear = do not flip vertically
                        ;
                        ; This makes sure we display the sprite in front of the
                        ; 3D ellipse, as the ship is above the ellipse in space
                        ;
                        ; Note that we do this by copying the attributes we set
                        ; up for sprite Y into sprite Y+1, clearing the bits as
                        ; we do so

 LDA SC2+1              ; Set SC2+1 = SC2+1 - 8
 SBC #8                 ;
 STA SC2+1              ; This subtracts 8 from the y-coordinate of the bottom
                        ; of the stick to give us the y-coordinate of the top
                        ; sprite in the stick

 BNE scan11             ; Jump to scan11 to draw sprite Y+2 at the top of the
                        ; stick (this BNE is effectively a JMP as A is never
                        ; zero)

.scan10

                        ; If we get here then the stick is small, so we hide
                        ; sprites Y and Y+1, leaving just sprite Y+2 visible on
                        ; the scanner

 LDA #240               ; Hide sprites Y and Y+1 from the scanner by setting
 STA ySprite0,Y         ; their y-coordinates to 240, which moves them off the
 STA ySprite1,Y         ; bottom of the screen

.scan11

                        ; We now draw sprite Y+2, which contains the ship dot at
                        ; the end of the stick

 LDA Y1                 ; Set A = Y1 mod 8
 AND #7                 ;
                        ; This gives us the height of the top part of the stick,
                        ; as there are eight pixels in each sprite making up the
                        ; stick, so this is the remainder after sprites Y and
                        ; Y+1 are taken away

 CLC                    ; Set the pattern number for sprite Y+2 to 219 + A
 ADC #219               ;
 STA pattSprite2,Y      ; Sprites 219 to 226 contain ship dots with trailing
                        ; sticks, starting with the dot at the bottom of the
                        ; pattern (in pattern 219) up to the dot at the top of
                        ; the pattern (in pattern 226), so this sets the tile
                        ; pattern for sprite Y+2 to the dot height given in A,
                        ; which is the correct pattern for the top of the ship's
                        ; stick

 LDA attrSprite0,Y      ; Clear bits 2 to 7 of the attributes for sprite Y+1 to
 AND #%00000011         ; ensure that the following attributes are set:
 STA attrSprite2,Y      ;
                        ;   * Bit 5 clear = show in front of background
                        ;   * Bit 6 clear = do not flip horizontally
                        ;   * Bit 7 clear = do not flip vertically
                        ;
                        ; This makes sure we display the sprite in front of the
                        ; 3D ellipse, as the ship is above the ellipse in space
                        ;
                        ; Note that we do this by copying the attributes we set
                        ; up for sprite Y into sprite Y+2, clearing the bits as
                        ; we do so

 LDA SC2                ; Set the x-coordinate of sprite Y+2 to SC2
 STA xSprite2,Y

 LDA SC2+1              ; Set the y-coordinate of sprite Y+2 to SC2+1, which by
 STA ySprite2,Y         ; now contains the y-coordinate of the top of the stick,

 RTS                    ; Return from the subroutine

.scan12

                        ; If we get here then we draw the ship behind the 3D
                        ; ellipse
                        ;
                        ; We jump here with A set to Y1, the height of the
                        ; stick, which we now need to clip to ensure it doesn't
                        ; fall off the bottom of the screen

 CLC                    ; Set A = Y1 + SC2+1
 ADC SC2+1

 CMP #220+YPAL          ; If A < 220, jump to scan13 to skip the following
 BCC scan13             ; instruction

 LDA #220+YPAL          ; Set A = 220, so A is a maximum of 220

.scan13

 SEC                    ; Set Y1 = A - SC2+1
 SBC SC2+1              ;
 STA Y1                 ; So this leaves Y1 alone unless Y1 + SC2+1 >= 220, in
                        ; which case Y1 is clipped so that Y1 + SC2+1 = 220 (so
                        ; this moves the "top" of the stick so that the ship dot
                        ; doesn't go off the bottom of the screen)

                        ; The ship is drawn on the scanner using up to three
                        ; sprites - sprites Y, Y+1 and Y+2
                        ;
                        ; Sprite Y is the end of the stick that's furthest from
                        ; the ship dot (i.e. the "bottom" of the stick which
                        ; appears to touch the 3D ellipse, though as we are
                        ; drawing the stick below the ellipse, this is the part
                        ; of the stick that is highest up the screen)
                        ;
                        ; Sprite Y+1 is the middle part of the stick
                        ;
                        ; Sprite Y+2 is the big ship dot at the end of the stick
                        ; (i.e. the "top" of the stick, though as we are
                        ; drawing the stick below the ellipse, this is the part
                        ; of the stick that is furthest down the screen)
                        ;
                        ; If a stick is full height, then we show all three
                        ; sprites, if a stick is medium height we display
                        ; sprites Y+1 and Y+2, and if a stick is small we only
                        ; display sprite Y+2
                        ;
                        ; We always draw sprite Y+2, so first we concentrate on
                        ; drawing sprites Y and Y+1, if required

 CMP #16                ; If Y1 < 16 then the stick is either medium or small,
 BCC scan14             ; so jump to scan14 to skip the following

                        ; If we get here then the stick is full height, so we
                        ; draw both sprite Y and sprite Y+1

 LDA SC2                ; Set the x-coordinate of sprite Y to SC2
 STA xSprite0,Y

 STA xSprite1,Y         ; Set the x-coordinate of sprite Y+1 to SC2

 LDA SC2+1              ; Set the y-coordinate of sprite Y to SC2+1, as SC2+1
 STA ySprite0,Y         ; contains the y-coordinate of the "bottom" of the stick

 CLC                    ; Set the y-coordinate of sprite Y+1 to SC2+1 + 8, which
 ADC #8                 ; is eight pixels lower down the screen then sprite Y
 STA ySprite1,Y         ;
                        ; This stacks the sprites one below the other, as each
                        ; sprite is eight pixels

 LDA attrSprite0,Y      ; Set bit 5 of the attributes for sprite Y to ensure
 ORA #%00100000         ; that the following attribute is set:
 STA attrSprite0,Y      ;
                        ;   * Bit 5 set   = show behind background
                        ;
                        ; This makes sure we display the sprite behind the
                        ; 3D ellipse, as the ship is below the ellipse in space

 STA attrSprite1,Y      ; Set the attributes for sprite Y+1 to the same as those
                        ; for sprite Y

 LDA SC2+1              ; Set SC2+1 = SC2+1 + 16
 CLC                    ;
 ADC #16                ; This adds 16 to the y-coordinate of the "bottom" of
 STA SC2+1              ; the stick to give us the y-coordinate of the "top"
                        ; sprite in the stick

 BNE scan16             ; Jump to scan16 to draw sprite Y+2 at the "top" of the
                        ; stick (this BNE is effectively a JMP as A is never
                        ; zero)

.scan14

                        ; If we get here then the stick is either medium or
                        ; small height

 CMP #8                 ; If Y1 < 8 then the stick is small, so jump to scan15
 BCC scan15             ; to skip the following

                        ; If we get here then the stick is medium height, so we
                        ; draw sprite Y+1 and hide sprite Y

 LDA #240               ; Hide sprite Y by setting its y-coordinate to 240,
 STA ySprite0,Y         ; which moves it off the bottom of the screen

 LDA SC2                ; Set the x-coordinate of sprite Y+1 to SC2
 STA xSprite1,Y

 LDA SC2+1              ; Set the y-coordinate of sprite Y+1 to SC2+1, as SC2+1
 STA ySprite1,Y         ; contains the y-coordinate of the bottom of the stick
                        ; (which is the middle sprite in a medium height stick)

 LDA attrSprite0,Y      ; Set bit 5 of the attributes for sprite Y to ensure
 ORA #%00100000         ; that the following attribute is set:
 STA attrSprite1,Y      ;
                        ;   * Bit 5 set   = show behind background
                        ;
                        ; This makes sure we display the sprite behind the
                        ; 3D ellipse, as the ship is below the ellipse in space
                        ;
                        ; Note that we do this by copying the attributes we set
                        ; up for sprite Y into sprite Y+1, clearing the bits as
                        ; we do so

 LDA SC2+1              ; Set SC2+1 = SC2+1 + 8
 ADC #7                 ;
 STA SC2+1              ; This adds 8 to the y-coordinate of the "bottom" of the
                        ; stick to give us the y-coordinate of the "top" sprite
                        ; in the stick
                        ;
                        ; The addition works as we know the C flag is set, as we
                        ; passed through a BCS above, so the ADC #7 actually
                        ; adds 8

 BNE scan16             ; Jump to scan16 to draw sprite Y+2 at the "top" of the
                        ; stick (this BNE is effectively a JMP as A is never
                        ; zero)

.scan15

                        ; If we get here then the stick is small, so we hide
                        ; sprites Y and Y+1, leaving just sprite Y+2 visible on
                        ; the scanner

 LDA #240               ; Hide sprites Y and Y+1 from the scanner by setting
 STA ySprite0,Y         ; their y-coordinates to 240, which moves them off the
 STA ySprite1,Y         ; bottom of the screen

.scan16

                        ; We now draw sprite Y+2, which contains the ship dot at
                        ; the end of the stick

 LDA Y1                 ; Set A = Y1 mod 8
 AND #7                 ;
                        ; This gives us the height of the top part of the stick,
                        ; as there are eight pixels in each sprite making up the
                        ; stick, so this is the remainder after sprites Y and
                        ; Y+1 are taken away

 CLC                    ; Set the pattern number for sprite Y+2 to 219 + A
 ADC #219               ;
 STA pattSprite2,Y      ; Sprites 219 to 226 contain ship dots with trailing
                        ; sticks, starting with the dot at the bottom of the
                        ; pattern (in pattern 219) up to the dot at the top of
                        ; the pattern (in pattern 226), so this sets the tile
                        ; pattern for sprite Y+2 to the dot height given in A,
                        ; which is the correct pattern for the top of the ship's
                        ; stick

 LDA attrSprite0,Y      ; Set bits 5 to 7 of the attributes for sprite Y to
 ORA #%11100000         ; ensure that the following attributes are set:
 STA attrSprite2,Y      ;
                        ;   * Bit 5 set   = show behind background
                        ;   * Bit 6 set   = flip horizontally
                        ;   * Bit 7 set   = flip vertically
                        ;
                        ; This makes sure we display the sprite behind the
                        ; 3D ellipse, as the ship is below the ellipse in space,
                        ; and that the dot end of the stick is at the bottom of
                        ; the sprite, not the top
                        ;
                        ; Note that we do this by copying the attributes we set
                        ; up for sprite Y into sprite Y+1, clearing the bits as
                        ; we do so

 LDA SC2                ; Set the x-coordinate of sprite Y+2 to SC2
 STA xSprite2,Y

 LDA SC2+1              ; Set the y-coordinate of sprite Y+2 to SC2+1, which by
 STA ySprite2,Y         ; now contains the y-coordinate of the top of the stick,

 RTS                    ; Return from the subroutine

; ******************************************************************************
;
;       Name: HideShip
;       Type: Subroutine
;   Category: Dashboard
;    Summary: Update the current ship so it is no longer shown on the scanner
;
; ******************************************************************************

.HideShip

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
;       Name: HideFromScanner
;       Type: Subroutine
;   Category: Dashboard
;    Summary: Hide the current ship from the scanner
;
; ******************************************************************************

.HideFromScanner

 SETUP_PPU_FOR_ICON_BAR ; If the PPU has started drawing the icon bar, configure
                        ; the PPU to use nametable 0 and pattern table 0

 LDX INWK+33            ; Set X to the number of the current ship on the
                        ; scanner, which is in ship data byte #33

 BEQ hide2              ; If byte #33 for the current ship is zero, then the
                        ; ship doesn't appear on the scanner, so jump to hide2
                        ; to return from the subroutine as there is nothing to
                        ; hide

 LDA #0                 ; Otherwise we need to hide this ship, so we start by
 STA scannerNumber,X    ; zeroing the scannerNumber entry for ship number X, so
                        ; it no longer has an allocated scanner number

                        ; We now hide the three sprites used to show this ship
                        ; on the scanner
                        ;
                        ; There are four data bytes for each sprite in the
                        ; sprite buffer, and there are three sprites used to
                        ; display each ship on the scanner, so we start by
                        ; calculating the offset of the sprite data for this
                        ; ship's scanner sprites

 TXA                    ; Set X = (X * 2 + X) * 4
 ASL A                  ;       = (3 * X) * 4
 ADC INWK+33            ;
 ASL A                  ; So X is the index of the sprite buffer data for the
 ASL A                  ; three sprites for ship number X on the scanner
 TAX

 LDA QQ11               ; If this is not the space view, jump to hide1 as the
 BNE hide1              ; dashboard is only shown in the space view

 LDA #240               ; Set A to the y-coordinate that's just below the bottom
                        ; of the screen, so we can hide the required sprites by
                        ; moving them off-screen

 STA ySprite11,X        ; Hide the three scanner sprites for ship number X, so
 STA ySprite12,X        ; the current ship is no longer shown on the scanner
 STA ySprite13,X        ; (the first ship on the scanner, ship number 1, uses
                        ; the three sprites at 14, 15 and 16 in the buffer, and
                        ; each sprite has four bytes in the buffer, so we can
                        ; get the sprite numbers by adding X, which contains the
                        ; offset within the sprite buffer, to the addresses of
                        ; sprites 11, 12 and 13)

.hide1

 LDA #0                 ; Zero the current ship's byte #33 in INWK, so that it
 STA INWK+33            ; no longer has a ship number on the scanner (a non-zero
                        ; byte #33 represents the ship's number on the scanner,
                        ; but a ship number of zero indicates that the ship is
                        ; not shown on the scanner)

.hide2

 RTS                    ; Return from the subroutine

; ******************************************************************************
;
;       Name: DrawExplosionBurst
;       Type: Subroutine
;   Category: Drawing ships
;    Summary: Draw an exploding ship along with an explosion burst made up of
;             colourful sprites
;
; ******************************************************************************

.DrawExplosionBurst

 LDY #0                 ; Set burstSpriteIndex = 0 to use as an index into the
 STY burstSpriteIndex   ; sprite buffer when drawing the four explosion sprites
                        ; below

 LDA cloudSize          ; Fetch the cloud size that we stored above, and store
 STA Q                  ; it in Q

 LDA INWK+34            ; Fetch byte #34 of the ship data block, which contains
                        ; the cloud counter

 BPL P%+4               ; If the cloud counter < 128, then we are in the first
                        ; half of the cloud's existence, so skip the next
                        ; instruction

 EOR #$FF               ; Flip the value of A so that in the second half of the
                        ; cloud's existence, A counts down instead of up

 LSR A                  ; Divide A by 16 so that is has a maximum value of 7
 LSR A
 LSR A
 LSR A

 ORA #1                 ; Make sure A is at least 1 and store it in U, to
 STA U                  ; give us the number of particles in the explosion for
                        ; each vertex

 LDY #7                 ; Fetch byte #7 of the ship blueprint, which contains
 LDA (XX0),Y            ; the explosion count for this ship (i.e. the number of
 STA TGT                ; vertices used as origins for explosion clouds) and
                        ; store it in TGT

 LDA RAND+1             ; Fetch the current random number seed in RAND+1 and
 PHA                    ; store it on the stack, so we can re-randomise the
                        ; seeds when we are done

 LDY #6                 ; Set Y = 6 to point to the byte before the first vertex
                        ; coordinate we stored on the XX3 heap above (we
                        ; increment it below so it points to the first vertex)

.burs1

 LDX #3                 ; We are about to fetch a pair of coordinates from the
                        ; XX3 heap, so set a counter in X for 4 bytes

.burs2

 INY                    ; Increment the index in Y so it points to the next byte
                        ; from the coordinate we are copying

 LDA XX3-7,Y            ; Copy byte Y-7 from the XX3 heap to the X-th byte of K3
 STA K3,X

 DEX                    ; Decrement the loop counter

 BPL burs2              ; Keep copying vertex coordinates into K3 until we have
                        ; copied all six coordinates

                        ; The above loop copies the vertex coordinates from the
                        ; XX3 heap to K3, reversing them as we go, so it sets
                        ; the following:
                        ;
                        ;   K3+3 = x_lo
                        ;   K3+2 = x_hi
                        ;   K3+1 = y_lo
                        ;   K3+0 = y_hi

 STY CNT                ; Set CNT to the index that points to the next vertex on
                        ; the XX3 heap

                        ; We now draw the explosion burst, which consists of
                        ; four colourful sprites that appear for the first part
                        ; of the explosion only
                        ;
                        ; We use sprites 59 to 62 for the explosion burst

 LDA burstSpriteIndex   ; Set burstSpriteIndex = burstSpriteIndex + 4
 CLC                    ;
 ADC #4                 ; So it points to the next sprite in the sprite buffer
                        ; (as each sprite takes up four bytes)

 CMP #16                ; If burstSpriteIndex >= 16 then we have already
 BCS burs5              ; processed all four sprites, so jump to burs5 to move
                        ; on to drawing the explosion cloud

 STA burstSpriteIndex   ; Update burstSpriteIndex to the new value

 TAY                    ; Set Y to the burst sprite index so we can use it as an
                        ; index into the sprite buffer

 LDA K3                 ; If either of y_hi or x_hi are non-zero, jump to burs3
 ORA K3+2               ; to hide this explosion sprite, as the explosion is off
 BNE burs3              ; the sides of the screen

 LDA K3+3               ; Set A = x_lo - 4
 SBC #3                 ;
                        ; As each explosion burst sprite is eight pixels wide,
                        ; this calculates the x-coordinate of the centre of the
                        ; sprite
                        ;
                        ; The SBC #3 actually subtracts 4 as we know the C flag
                        ; is clear, as we passed through a BCS above

 BCC burs3              ; If the subtraction underflowed then the centre of the
                        ; sprite is off the top of the screen, so jump to burs3
                        ; to hide this explosion sprite

 STA xSprite58,Y        ; Set the x-coordinate for the explosion burst sprite
                        ; to A (starting from sprite 59, as Y is a minimum of 4)

 LDA #%00000010         ; Set the attributes for the sprite as follows:
 STA attrSprite58,Y     ;
                        ;   * Bits 0-1    = sprite palette 2
                        ;   * Bit 5 clear = show in front of background
                        ;   * Bit 6 clear = do not flip horizontally
                        ;   * Bit 7 clear = do not flip vertically

 LDA K3+1               ; Set A = y_lo

 CMP #128               ; If A < 128 then the sprite is within the space view,
 BCC burs4              ; so jump to burs4 to configure the rest of the sprite

                        ; Otherwise the sprite is not in the space view, so fall
                        ; through into burs3 to hide this explosion sprite

.burs3

 LDA #240               ; Hide this explosion burst sprite by setting its
 STA ySprite58,Y        ; y-coordinate to 240, which is off the bottom of the
                        ; screen

 BNE burs5              ; Jump to burs5 to move on to drawing the explosion
                        ; cloud (this BNE is effectively a JMP as A is never
                        ; zero)

.burs4

 ADC #10+YPAL           ; Set the pixel y-coordinate of the explosion sprite to
 STA ySprite58,Y        ; A + 10

 LDA #245               ; Set the sprite's pattern number to 245, which is a
 STA pattSprite58,Y     ; fairly messy explosion pattern

.burs5

                        ; This next part copies bytes #37 to #40 from the ship
                        ; data block into the four random number seeds in RAND
                        ; to RAND+3, EOR'ing them with the vertex index so they
                        ; are different for every vertex. This enables us to
                        ; generate random numbers for drawing each vertex that
                        ; are random but repeatable, which we need when we
                        ; redraw the cloud to remove it
                        ;
                        ; We set the values of bytes #37 to #40 randomly in the
                        ; LL9 routine before calling DOEXP, so the explosion
                        ; cloud is random but repeatable

 LDY #37                ; Set Y to act as an index into the ship data block for
                        ; byte #37

 LDA (INF),Y            ; Set the seed at RAND to byte #37, EOR'd with the
 EOR CNT                ; vertex index, so the seeds are different for each
 STA RAND               ; vertex

 INY                    ; Increment Y to point to byte #38

 LDA (INF),Y            ; Set the seed at RAND+1 to byte #38, EOR'd with the
 EOR CNT                ; vertex index, so the seeds are different for each
 STA RAND+1             ; vertex

 INY                    ; Increment Y to point to byte #39

 LDA (INF),Y            ; Set the seed at RAND+2 to byte #39, EOR'd with the
 EOR CNT                ; vertex index, so the seeds are different for each
 STA RAND+2             ; vertex

 INY                    ; Increment Y to point to byte #40

 LDA (INF),Y            ; Set the seed at RAND+3 to byte #49, EOR'd with the
 EOR CNT                ; vertex index, so the seeds are different for each
 STA RAND+3             ; vertex

 LDY U                  ; Set Y to the number of particles in the explosion for
                        ; each vertex, which we stored in U above. We will now
                        ; use this as a loop counter to iterate through all the
                        ; particles in the explosion

.burs6

 SETUP_PPU_FOR_ICON_BAR ; If the PPU has started drawing the icon bar, configure
                        ; the PPU to use nametable 0 and pattern table 0

 JSR DORND2             ; Set ZZ to a random number, making sure the C flag
 STA ZZ                 ; doesn't affect the outcome

 LDA K3+1               ; Set (A R) = (y_hi y_lo)
 STA R                  ;           = y
 LDA K3

 JSR EXS1               ; Set (A X) = (A R) +/- random * cloud size
                        ;           = y +/- random * cloud size

 BNE burs8              ; If A is non-zero, the particle is off-screen as the
                        ; coordinate is bigger than 255), so jump to burs8 to do
                        ; the next particle

 CPX Yx2M1              ; If X > the y-coordinate of the bottom of the screen
 BCS burs8              ; (which is in Yx2M1) then the particle is off the
                        ; bottom of the screen, so jump to burs8 to do the next
                        ; particle

                        ; Otherwise X contains a random y-coordinate within the
                        ; cloud

 STX Y1                 ; Set Y1 = our random y-coordinate within the cloud

 LDA K3+3               ; Set (A R) = (x_hi x_lo)
 STA R
 LDA K3+2

 JSR EXS1               ; Set (A X) = (A R) +/- random * cloud size
                        ;           = x +/- random * cloud size

 BNE burs7              ; If A is non-zero, the particle is off-screen as the
                        ; coordinate is bigger than 255), so jump to burs8 to do
                        ; the next particle

                        ; Otherwise X contains a random x-coordinate within the
                        ; cloud

 LDA Y1                 ; Set A = our random y-coordinate within the cloud

 JSR PIXEL              ; Draw a point at screen coordinate (X, A) with the
                        ; point size determined by the distance in ZZ

.burs7

 DEY                    ; Decrement the loop counter for the next particle

 BPL burs6              ; Loop back to burs6 until we have done all the
                        ; particles in the cloud

 LDY CNT                ; Set Y to the index that points to the next vertex on
                        ; the XX3 heap

 CPY TGT                ; If Y < TGT, which we set to the explosion count for
 BCS P%+5               ; this ship (i.e. the number of vertices used as origins
 JMP burs1              ; for explosion clouds), loop back to burs1 to do a
                        ; cloud for the next vertex

 PLA                    ; Restore the current random number seed to RAND+1 that
 STA RAND+1             ; we stored at the start of the routine

 LDA K%+6               ; Store the z_lo coordinate for the planet (which will
 STA RAND+3             ; be pretty random) in the RAND+3 seed

 RTS                    ; Return from the subroutine

.burs8

 JSR DORND2             ; Set A and X to random numbers, making sure the C flag
                        ; doesn't affect the outcome

 JMP burs7              ; Jump up to burs7 to move on to the next particle

; ******************************************************************************
;
;       Name: PIXEL2
;       Type: Subroutine
;   Category: Drawing pixels
;    Summary: Draw a stardust particle relative to the screen centre
;  Deep dive: Sprite usage in NES Elite
;
; ------------------------------------------------------------------------------
;
; Draw a stardust particle sprite at point (X1, Y1) from the middle of the
; screen with a size determined by a distance value.
;
; Arguments:
;
;   X1                  The x-coordinate offset
;
;   Y1                  The y-coordinate offset (positive means up the screen
;                       from the centre, negative means down the screen)
;
;   ZZ                  The distance of the point (further away = smaller point)
;
;   Y                   The number of the stardust particle (1 to 20)
;
; ******************************************************************************

.PIXEL2

 STY T1                 ; Store Y in T1 so we can retrieve it at the end of the
                        ; subroutine

 TYA                    ; Set Y = Y * 4
 ASL A                  ;
 ASL A                  ; So Y can be used as an index into the sprite buffer,
 TAY                    ; starting with sprite 38 for stardust particle 1, up to
                        ; sprite 57 for stardust particle 20

 LDA #210               ; Set A = 210 to use as the pattern number for the
                        ; largest particle of stardust (the stardust particle
                        ; patterns run from pattern 210 to 214, decreasing in
                        ; size as the number increases)

 LDX ZZ                 ; If ZZ >= 24, increment A
 CPX #24
 ADC #0

 CPX #48                ; If ZZ >= 48, increment A
 ADC #0

 CPX #112               ; If ZZ >= 112, increment A
 ADC #0

 CPX #144               ; If ZZ >= 144, increment A
 ADC #0

                        ; So by this point A is 210 for the closest stardust,
                        ; then 211, 212, 213 or 214 for smaller and smaller
                        ; particles as they move further away

                        ; The C flag is clear at this point, which affects the
                        ; SBC #3 below

 STA pattSprite37,Y     ; By this point A is the correct pattern number for the
                        ; distance of the stardust particle, so set the tile
                        ; pattern number for sprite 37 + Y to this pattern

 LDA X1                 ; Fetch the x-coordinate offset into A

 BPL PX21               ; If the x-coordinate offset is positive, jump to PX21
                        ; to skip the following negation

 EOR #%01111111         ; The x-coordinate offset is negative, so flip all the
 CLC                    ; bits apart from the sign bit and add 1, to convert it
 ADC #1                 ; from a sign-magnitude number to a signed number

.PX21

 EOR #%10000000         ; Set A = X1 + 128 - 4
 SBC #3                 ;
                        ; So X is now the offset converted to an x-coordinate,
                        ; centred on x-coordinate 128, less a margin of 4
                        ;
                        ; We know that the C flag is clear at this point, so the
                        ; SBC #3 actually subtracts 4

 CMP #244               ; If A >= 244 then the stardust particle is off-screen,
 BCS stpx1              ; so jump to stpx1 to hide the particle's sprite and
                        ; return from the subroutine

 STA xSprite37,Y        ; Set the stardust particle's sprite x-coordinate to A

 LDA Y1                 ; Fetch the y-coordinate offset into A and clear the
 AND #%01111111         ; sign bit, so A = |Y1|

 CMP halfScreenHeight   ; If A >= halfScreenHeight then the stardust particle
 BCS stpx1              ; is off the screen, so jump to stpx1 to hide the
                        ; particle's sprite and return from the subroutine

 LDA Y1                 ; Fetch the y-coordinate offset into A

 BPL PX22               ; If the y-coordinate offset is positive, jump to PX22
                        ; to skip the following negation

 EOR #%01111111         ; The y-coordinate offset is negative, so flip all the
 ADC #1                 ; bits apart from the sign bit and add 1, to convert it
                        ; from a sign-magnitude number to a signed number

.PX22

 STA T                  ; Set A = halfScreenHeight - Y1 + 10
 LDA halfScreenHeight   ;
 SBC T                  ; So if Y is positive we display the point up from the
 ADC #10+YPAL           ; centre at y-coordinate halfScreenHeight, while a
                        ; negative Y means down from the centre

 STA ySprite37,Y        ; Set the stardust particle's sprite y-coordinate to A

 LDY T1                 ; Restore the value of Y from T1 so it is preserved

 RTS                    ; Return from the subroutine

.stpx1

                        ; If we get here then we do not want to show the
                        ; stardust particle on-screen

 LDA #240               ; Hide the stardust particle's sprite by setting its
 STA ySprite37,Y        ; y-coordinate to 240, which is off the bottom of the
                        ; screen

 LDY T1                 ; Restore the value of Y from T1 so it is preserved

 RTS                    ; Return from the subroutine

; ******************************************************************************
;
;       Name: Vectors
;       Type: Variable
;   Category: Utility routines
;    Summary: Vectors and padding at the end of the ROM bank
;  Deep dive: Splitting NES Elite across multiple ROM banks
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
; Save bank1.bin
;
; ******************************************************************************

 PRINT "S.bank1.bin ", ~CODE%, " ", ~P%, " ", ~LOAD%, " ", ~LOAD%
 SAVE "3-assembled-output/bank1.bin", CODE%, P%, LOAD%
