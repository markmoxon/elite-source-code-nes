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
;   Category: Flight
;    Summary: Reset the ship's speed, hyperspace counter, laser temperature,
;             shields and energy banks
;
; ******************************************************************************

.ResetShipStatus

 LDA #0                 ; Reduce the speed to 0
 STA DELTA

 STA QQ22+1             ; Reset the on-screen hyperspace counter

 LDA #0                 ; Cool down the lasers completely
 STA GNTMP

 LDA #$FF               ; Recharge the forward and aft shields
 STA FSH
 STA ASH

 STA ENERGY             ; Recharge the energy banks

 RTS                    ; Return from the subroutine

; ******************************************************************************
;
;       Name: DOENTRY
;       Type: Subroutine
;   Category: Flight
;    Summary: Dock at the space station, show the ship hangar and work out any
;             mission progression
;
; ******************************************************************************

.DOENTRY

 LDX #$FF               ; Set the stack pointer to $01FF, which is the standard
 TXS                    ; location for the 6502 stack, so this instruction
                        ; effectively resets the stack

 JSR RES2               ; Reset a number of flight variables and workspaces

 JSR LAUN               ; Show the space station docking tunnel

 JSR ResetShipStatus    ; Reset the ship's speed, hyperspace counter, laser
                        ; temperature, shields and energy banks

 JSR HALL_b1            ; Show the ship hangar

 LDY #44                ; Wait for 44/50 of a second (0.88 seconds)
 JSR DELAY

 LDA TP                 ; Fetch bits 0 and 1 of TP, and if they are non-zero
 AND #%00000011         ; (i.e. mission 1 is either in progress or has been
 BNE EN1                ; completed), skip to EN1

 LDA TALLY+1            ; If the high byte of TALLY is zero (so we have a combat
 BEQ EN4                ; rank below Competent), jump to EN4 as we are not yet
                        ; good enough to qualify for a mission

 LDA GCNT               ; Fetch the galaxy number into A, and if any of bits 1-7
 LSR A                  ; are set (i.e. A > 1), jump to EN4 as mission 1 can
 BNE EN4                ; only be triggered in the first two galaxies

 JMP BRIEF              ; If we get here, mission 1 hasn't started, we have
                        ; reached a combat rank of Competent, and we are in
                        ; galaxy 0 or 1 (shown in-game as galaxy 1 or 2), so
                        ; it's time to start mission 1 by calling BRIEF

.EN1

                        ; If we get here then mission 1 is either in progress or
                        ; has been completed

 CMP #%00000011         ; If bits 0 and 1 are not both set, then jump to EN2
 BNE EN2

 JMP DEBRIEF            ; Bits 0 and 1 are both set, so mission 1 is both in
                        ; progress and has been completed, which means we have
                        ; only just completed it, so jump to DEBRIEF to end the
                        ; mission get our reward

.EN2

                        ; Mission 1 has been completed, so now to check for
                        ; mission 2

 LDA GCNT               ; Fetch the galaxy number into A

 CMP #2                 ; If this is not galaxy 2 (shown in-game as galaxy 3),
 BNE EN4                ; jump to EN4 as we can only start mission 2 in the
                        ; third galaxy

 LDA TP                 ; Extract bits 0-3 of TP into A
 AND #%00001111

 CMP #%00000010         ; If mission 1 is complete and no longer in progress,
 BNE EN3                ; and mission 2 is not yet started, then bits 0-3 of TP
                        ; will be %0010, so this jumps to EN3 if this is not the
                        ; case

 LDA TALLY+1            ; If the high byte of TALLY is < 5 (so we have a combat
 CMP #5                 ; rank that is less than 3/8 of the way from Dangerous
 BCC EN4                ; to Deadly), jump to EN4 as our rank isn't high enough
                        ; for mission 2

 JMP BRIEF2             ; If we get here, mission 1 is complete and no longer in
                        ; progress, mission 2 hasn't started, we have reached a
                        ; combat rank of 3/8 of the way from Dangerous to
                        ; Deadly, and we are in galaxy 2 (shown in-game as
                        ; galaxy 3), so it's time to start mission 2 by calling
                        ; BRIEF2

.EN3

 CMP #%00000110         ; If mission 1 is complete and no longer in progress,
 BNE EN5                ; and mission 2 has started but we have not yet been
                        ; briefed and picked up the plans, then bits 0-3 of TP
                        ; will be %0110, so this jumps to EN5 if this is not the
                        ; case

 LDA QQ0                ; Set A = the current system's galactic x-coordinate

 CMP #215               ; If A <> 215 then jump to EN4
 BNE EN4

 LDA QQ1                ; Set A = the current system's galactic y-coordinate

 CMP #84                ; If A <> 84 then jump to EN4
 BNE EN4

 JMP BRIEF3             ; If we get here, mission 1 is complete and no longer in
                        ; progress, mission 2 has started but we have not yet
                        ; picked up the plans, and we have just arrived at
                        ; Ceerdi at galactic coordinates (215, 84), so we jump
                        ; to BRIEF3 to get a mission brief and pick up the plans
                        ; that we need to carry to Birera

.EN5

 CMP #%00001010         ; If mission 1 is complete and no longer in progress,
 BNE EN4                ; and mission 2 has started and we have picked up the
                        ; plans, then bits 0-3 of TP will be %1010, so this
                        ; jumps to EN5 if this is not the case

 LDA QQ0                ; Set A = the current system's galactic x-coordinate

 CMP #63                ; If A <> 63 then jump to EN4
 BNE EN4

 LDA QQ1                ; Set A = the current system's galactic y-coordinate

 CMP #72                ; If A <> 72 then jump to EN4
 BNE EN4

 JMP DEBRIEF2           ; If we get here, mission 1 is complete and no longer in
                        ; progress, mission 2 has started and we have picked up
                        ; the plans, and we have just arrived at Birera at
                        ; galactic coordinates (63, 72), so we jump to DEBRIEF2
                        ; to end the mission and get our reward

.EN4

 LDA COK                ; If bit 7 of COK is set, then cheat mode has been
 BMI EN6                ; applied, so jump to EN6

 LDA CASH+1
 BEQ EN6

 LDA TP                 ; If bit 4 of TP is set, then the Tribbles mission has
 AND #%00010000         ; already been completed, so jump to EN6
 BNE EN6

 JMP TBRIEF

.EN6

 JMP BAY                ; If we get here them we didn't start or any missions,
                        ; so jump to BAY to go to the docking bay (i.e. show the
                        ; Status Mode screen)

 RTS

; ******************************************************************************
;
;       Name: Main flight loop (Part 4 of 16)
;       Type: Subroutine
;   Category: Main loop
;    Summary: For each nearby ship: Copy the ship's data block from K% to the
;             zero-page workspace at INWK
;  Deep dive: Program flow of the main game loop
;             Ship data blocks
;
; ------------------------------------------------------------------------------
;
; The main flight loop covers most of the flight-specific aspects of Elite. This
; section covers the following:
;
;   * Start looping through all the ships in the local bubble, and for each
;     one:
;
;     * Copy the ship's data block from K% to INWK
;
;     * Set XX0 to point to the ship's blueprint (if this is a ship)
;
; Other entry points:
;
;   MAL1                Marks the beginning of the ship analysis loop, so we
;                       can jump back here from part 12 of the main flight loop
;                       to work our way through each ship in the local bubble.
;                       We also jump back here when a ship is removed from the
;                       bubble, so we can continue processing from the next ship
;
; ******************************************************************************

.MAL1

 STX XSAV               ; Store the current slot number in XSAV

 STA TYPE               ; Store the ship type in TYPE

 SETUP_PPU_FOR_ICON_BAR ; If the PPU has started drawing the icon bar, configure
                        ; the PPU to use nametable 0 and pattern table 0

 JSR GINF               ; Call GINF to fetch the address of the ship data block
                        ; for the ship in slot X and store it in INF. The data
                        ; block is in the K% workspace, which is where all the
                        ; ship data blocks are stored

                        ; Next we want to copy the ship data block from INF to
                        ; the zero-page workspace at INWK, so we can process it
                        ; more efficiently

 LDY #NI%-1             ; There are NI% bytes in each ship data block (and in
                        ; the INWK workspace, so we set a counter in Y so we can
                        ; loop through them

.MAL2

 LDA (INF),Y            ; Load the Y-th byte of INF and store it in the Y-th
 STA INWK,Y             ; byte of INWK

 DEY                    ; Decrement the loop counter

 BPL MAL2               ; Loop back for the next byte until we have copied the
                        ; last byte from INF to INWK

 SETUP_PPU_FOR_ICON_BAR ; If the PPU has started drawing the icon bar, configure
                        ; the PPU to use nametable 0 and pattern table 0

 LDA TYPE               ; If the ship type is negative then this indicates a
 BMI MA21               ; planet or sun, so jump down to MA21, as the next bit
                        ; sets up a pointer to the ship blueprint, and then
                        ; checks for energy bomb damage, and neither of these
                        ; apply to planets and suns

 CMP #2                 ; ???
 BNE C80F0

 LDA L04A2
 STA XX0

 LDA L04A3
 STA XX0+1

 LDY #4
 BNE C80FC

.C80F0

 ASL A                  ; Set Y = ship type * 2
 TAY

 LDA XX21-2,Y           ; The ship blueprints at XX21 start with a lookup
 STA XX0                ; table that points to the individual ship blueprints,
                        ; so this fetches the low byte of this particular ship
                        ; type's blueprint and stores it in XX0

 LDA XX21-1,Y           ; Fetch the high byte of this particular ship type's
 STA XX0+1              ; blueprint and store it in XX0+1

.C80FC

 CPY #6
 BEQ C815B
 CPY #$3C
 BEQ C815B
 CPY #4
 BEQ C811A
 LDA INWK+32
 BPL C815B
 CPY #2
 BEQ C8114
 AND #$3E
 BEQ C815B

.C8114

 LDA INWK+31
 AND #$A0
 BNE C815B

.C811A

 LDA NEWB
 AND #4
 BEQ C815B
 ASL L0300
 SEC
 ROR L0300

.C815B

; ******************************************************************************
;
;       Name: Main flight loop (Part 5 of 16)
;       Type: Subroutine
;   Category: Main loop
;    Summary: For each nearby ship: If an energy bomb has been set off,
;             potentially kill this ship
;  Deep dive: Program flow of the main game loop
;
; ------------------------------------------------------------------------------
;
; The main flight loop covers most of the flight-specific aspects of Elite. This
; section covers the following:
;
;   * Continue looping through all the ships in the local bubble, and for each
;     one:
;
;     * If an energy bomb has been set off and this ship can be killed, kill it
;       and increase the kill tally
;
; ******************************************************************************

 LDA BOMB               ; If we set off our energy bomb (see MA24 above), then
 BPL MA21               ; BOMB is now negative, so this skips to MA21 if our
                        ; energy bomb is not going off

 CPY #2*SST             ; If the ship in Y is the space station, jump to BA21
 BEQ MA21               ; as energy bombs are useless against space stations

 CPY #2*THG             ; If the ship in Y is a Thargoid, jump to BA21 as energy
 BEQ MA21               ; bombs have no effect against Thargoids

 CPY #2*CON             ; If the ship in Y is the Constrictor, jump to BA21
 BCS MA21               ; as energy bombs are useless against the Constrictor
                        ; (the Constrictor is the target of mission 1, and it
                        ; would be too easy if it could just be blown out of
                        ; the sky with a single key press)

 LDA INWK+31            ; If the ship we are checking has bit 5 set in its ship
 AND #%00100000         ; byte #31, then it is already exploding, so jump to
 BNE MA21               ; BA21 as ships can't explode more than once

 ASL INWK+31            ; The energy bomb is killing this ship, so set bit 7 of
 SEC                    ; the ship byte #31 to indicate that it has now been
 ROR INWK+31            ; killed

 LDX TYPE               ; Set X to the type of the ship that was killed so the
                        ; following call to EXNO2 can award us the correct
                        ; number of fractional kill points

 JSR EXNO2              ; Call EXNO2 to process the fact that we have killed a
                        ; ship (so increase the kill tally, make an explosion
                        ; sound and possibly display "RIGHT ON COMMANDER!")

; ******************************************************************************
;
;       Name: Main flight loop (Part 6 of 16)
;       Type: Subroutine
;   Category: Main loop
;    Summary: For each nearby ship: Move the ship in space and copy the updated
;             INWK data block back to K%
;  Deep dive: Program flow of the main game loop
;             Program flow of the ship-moving routine
;             Ship data blocks
;
; ------------------------------------------------------------------------------
;
; The main flight loop covers most of the flight-specific aspects of Elite. This
; section covers the following:
;
;   * Continue looping through all the ships in the local bubble, and for each
;     one:
;
;     * Move the ship in space
;
;     * Copy the updated ship's data block from INWK back to K%
;
; ******************************************************************************

.MA21

 JSR MVEIT              ; Call MVEIT to move the ship we are processing in space

 SETUP_PPU_FOR_ICON_BAR ; If the PPU has started drawing the icon bar, configure
                        ; the PPU to use nametable 0 and pattern table 0

                        ; Now that we are done processing this ship, we need to
                        ; copy the ship data back from INWK to the correct place
                        ; in the K% workspace. We already set INF in part 4 to
                        ; point to the ship's data block in K%, so we can simply
                        ; do the reverse of the copy we did before, this time
                        ; copying from INWK to INF

 LDY #NI%-1             ; Set a counter in Y so we can loop through the NI%
                        ; bytes in the ship data block

.MAL3

 LDA INWK,Y             ; Load the Y-th byte of INWK and store it in the Y-th
 STA (INF),Y            ; byte of INF

 DEY                    ; Decrement the loop counter

 BPL MAL3               ; Loop back for the next byte, until we have copied the
                        ; last byte from INWK back to INF

 SETUP_PPU_FOR_ICON_BAR ; If the PPU has started drawing the icon bar, configure
                        ; the PPU to use nametable 0 and pattern table 0

; ******************************************************************************
;
;       Name: Main flight loop (Part 7 of 16)
;       Type: Subroutine
;   Category: Main loop
;    Summary: For each nearby ship: Check whether we are docking, scooping or
;             colliding with it
;  Deep dive: Program flow of the main game loop
;
; ------------------------------------------------------------------------------
;
; The main flight loop covers most of the flight-specific aspects of Elite. This
; section covers the following:
;
;   * Continue looping through all the ships in the local bubble, and for each
;     one:
;
;     * Check how close we are to this ship and work out if we are docking,
;       scooping or colliding with it
;
; ******************************************************************************

 LDA INWK+31            ; Fetch the status of this ship from bits 5 (is ship
 AND #%10100000         ; exploding?) and bit 7 (has ship been killed?) from
                        ; ship byte #31 into A

 LDX TYPE               ; If the current ship type is negative then it's either
 BMI MA65               ; a planet or a sun, so jump down to MA65 to skip the
                        ; following, as we can't dock with it or scoop it

 JSR MAS4               ; Or this value with x_hi, y_hi and z_hi

 BNE MA65               ; If this value is non-zero, then either the ship is
                        ; far away (i.e. has a non-zero high byte in at least
                        ; one of the three axes), or it is already exploding,
                        ; or has been flagged as being killed - in which case
                        ; jump to MA65 to skip the following, as we can't dock
                        ; scoop or collide with it

 LDA INWK               ; Set A = (x_lo OR y_lo OR z_lo), and if bit 7 of the
 ORA INWK+3             ; result is set, the ship is still a fair distance
 ORA INWK+6             ; away (further than 127 in at least one axis), so jump
 BMI MA65               ; to MA65 to skip the following, as it's too far away to
                        ; dock, scoop or collide with

 CPX #SST               ; If this ship is the space station, jump to ISDK to
 BEQ ISDK               ; check whether we are docking with it

 AND #%11000000         ; If bit 6 of (x_lo OR y_lo OR z_lo) is set, then the
 BNE MA65               ; ship is still a reasonable distance away (further than
                        ; 63 in at least one axis), so jump to MA65 to skip the
                        ; following, as it's too far away to dock, scoop or
                        ; collide with

 CPX #MSL               ; If this ship is a missile, jump down to MA65 to skip
 BEQ MA65               ; the following, as we can't scoop or dock with a
                        ; missile, and it has its own dedicated collision
                        ; checks in the TACTICS routine

 LDA BST                ; If we have fuel scoops fitted then BST will be $FF,
                        ; otherwise it will be 0

 AND INWK+5             ; Ship byte #5 contains the y_sign of this ship, so a
                        ; negative value here means the canister is below us,
                        ; which means the result of the AND will be negative if
                        ; the canister is below us and we have a fuel scoop
                        ; fitted

 BMI P%+5               ; If the result is negative, skip the following
                        ; instruction

 JMP MA58               ; If the result is positive, then we either have no
                        ; scoop or the canister is above us, and in both cases
                        ; this means we can't scoop the item, so jump to MA58
                        ; to process a collision

; ******************************************************************************
;
;       Name: Main flight loop (Part 8 of 16)
;       Type: Subroutine
;   Category: Main loop
;    Summary: For each nearby ship: Process us potentially scooping this item
;  Deep dive: Program flow of the main game loop
;
; ------------------------------------------------------------------------------
;
; The main flight loop covers most of the flight-specific aspects of Elite. This
; section covers the following:
;
;   * Continue looping through all the ships in the local bubble, and for each
;     one:
;
;     * Process us potentially scooping this item
;
; ******************************************************************************

 CPX #OIL               ; If this is a cargo canister, jump to oily to randomly
 BEQ oily               ; decide the canister's contents

 CPX #ESC               ; If this is an escape pod, jump to MA58 to skip all the
 BEQ MA58               ; docking and scooping checks

 LDY #0                 ; Fetch byte #0 of the ship's blueprint
 JSR GetShipBlueprint

 LSR A                  ; Shift it right four times, so A now contains the high
 LSR A                  ; nibble (i.e. bits 4-7)
 LSR A
 LSR A

 BEQ MA58               ; If A = 0, jump to MA58 to skip all the docking and
                        ; scooping checks

                        ; Only the Thargon, alloy plate, splinter and escape pod
                        ; have non-zero upper nibbles in their blueprint byte #0
                        ; so if we get here, our ship is one of those, and the
                        ; upper nibble gives the market item number of the item
                        ; when scooped, less 1

 ADC #1                 ; Add 1 to the upper nibble to get the market item
                        ; number

 BNE slvy2              ; Skip to slvy2 so we scoop the ship as a market item

.oily

 JSR DORND              ; Set A and X to random numbers and reduce A to a
 AND #7                 ; random number in the range 0-7

.slvy2

                        ; By the time we get here, we are scooping, and A
                        ; contains the type of item we are scooping (a random
                        ; number 0-7 if we are scooping a cargo canister, 3 if
                        ; we are scooping an escape pod, or 16 if we are
                        ; scooping a Thargon). These numbers correspond to the
                        ; relevant market items (see QQ23 for a list), so a
                        ; cargo canister can contain anything from food to
                        ; computers, while escape pods contain slaves, and
                        ; Thargons become alien items when scooped

 JSR tnpr1              ; Call tnpr1 with the scooped cargo type stored in A
                        ; to work out whether we have room in the hold for one
                        ; tonne of this cargo (A is set to 1 by this call, and
                        ; the C flag contains the result)

 LDY #78                ; This instruction has no effect, so presumably it used
                        ; to do something, but didn't get removed

 BCS MA59               ; If the C flag is set then we have no room in the hold
                        ; for the scooped item, so jump down to MA59 make a
                        ; sound to indicate failure, before destroying the
                        ; canister

 LDY QQ29               ; Scooping was successful, so set Y to the type of
                        ; item we just scooped, which we stored in QQ29 above

 ADC QQ20,Y             ; Add A (which we set to 1 above) to the number of items
 STA QQ20,Y             ; of type Y in the cargo hold, as we just successfully
                        ; scooped one canister of type Y

 TYA                    ; Print recursive token 48 + Y as an in-flight token,
 ADC #208               ; which will be in the range 48 ("FOOD") to 64 ("ALIEN
 JSR MESS               ; ITEMS"), so this prints the scooped item's name

 JSR subm_EBE9          ; ???

 ASL NEWB               ; The item has now been scooped, so set bit 7 of its
 SEC                    ; NEWB flags to indicate this
 ROR NEWB

.MA65

 JMP MA26               ; If we get here, then the ship we are processing was
                        ; too far away to be scooped, docked or collided with,
                        ; so jump to MA26 to skip over the collision routines
                        ; and move on to missile targeting

; ******************************************************************************
;
;       Name: Main flight loop (Part 9 of 16)
;       Type: Subroutine
;   Category: Main loop
;    Summary: For each nearby ship: If it is a space station, check whether we
;             are successfully docking with it
;  Deep dive: Program flow of the main game loop
;             Docking checks
;
; ------------------------------------------------------------------------------
;
; The main flight loop covers most of the flight-specific aspects of Elite. This
; section covers the following:
;
;   * Process docking with a space station
;
; For details on the various docking checks in this routine, see the deep dive
; on "Docking checks".
;
; Other entry points:
;
;   GOIN                We jump here from part 3 of the main flight loop if the
;                       docking computer is activated by pressing "C"
;
; ******************************************************************************

.ISDK

 LDA K%+NI%+4+36        ; 1. Fetch the NEWB flags (byte #36) of the second ship
 AND #%00000100         ; in the ship data workspace at K%, which is reserved
 BNE MA622              ; for the sun or the space station (in this case it's
                        ; the latter), and if bit 2 is set, meaning the station
                        ; is hostile, jump down to MA622 to fail docking (so
                        ; trying to dock at a station that we have annoyed does
                        ; not end well)

 LDA INWK+14            ; 2. If nosev_z_hi < 214, jump down to MA62 to fail
 CMP #214               ; docking, as the angle of approach is greater than 26
 BCC MA62               ; degrees

 JSR SPS1               ; Call SPS1 to calculate the vector to the planet and
                        ; store it in XX15

 LDA XX15+2             ; Set A to the z-axis of the vector

 CMP #89                ; 4. If z-axis < 89, jump to MA62 to fail docking, as
 BCC MA62               ; we are not in the 22.0 degree safe cone of approach

 LDA INWK+16            ; 5. If |roofv_x_hi| < 80, jump to MA62 to fail docking,
 AND #%01111111         ; as the slot is more than 36.6 degrees from horizontal
 CMP #80
 BCC MA62

.GOIN

 JSR WaitResetSound     ; ???

                        ; If we arrive here, we just docked successfully

 JMP DOENTRY            ; Go to the docking bay (i.e. show the ship hangar)

.MA62

                        ; If we arrive here, docking has just failed

 LDA auto               ; If the docking computer is engaged, ensure we dock
 BNE GOIN               ; successfully even if the approach isn't correct, as
                        ; the docking computer algorithm isn't perfect (so this
                        ; fixes the issue in the other versions of Elite where
                        ; the docking computer can kill you)

.MA622

 LDA DELTA              ; If the ship's speed is < 5, jump to MA67 to register
 CMP #5                 ; some damage, but not a huge amount
 BCC MA67

 JMP DEATH              ; Otherwise we have just crashed into the station, so
                        ; process our death

; ******************************************************************************
;
;       Name: Main flight loop (Part 10 of 16)
;       Type: Subroutine
;   Category: Main loop
;    Summary: For each nearby ship: Remove if scooped, or process collisions
;  Deep dive: Program flow of the main game loop
;
; ------------------------------------------------------------------------------
;
; The main flight loop covers most of the flight-specific aspects of Elite. This
; section covers the following:
;
;   * Continue looping through all the ships in the local bubble, and for each
;     one:
;
;     * Remove scooped item after both successful and failed scoopings
;
;     * Process collisions
;
; ******************************************************************************

.MA59

                        ; If we get here then scooping failed

 JSR EXNO3              ; Make the sound of the cargo canister being destroyed
                        ; and fall through into MA60 to remove the canister
                        ; from our local bubble

.MA60

                        ; If we get here then scooping was successful

 ASL INWK+31            ; Set bit 7 of the scooped or destroyed item, to denote
 SEC                    ; that it has been killed and should be removed from
 ROR INWK+31            ; the local bubble

.MA61

 BNE MA26               ; Jump to MA26 to skip over the collision routines and
                        ; to move on to missile targeting (this BNE is
                        ; effectively a JMP as A will never be zero)

.MA67

                        ; If we get here then we have collided with something,
                        ; but not fatally

 LDA #1                 ; Set the speed in DELTA to 1 (i.e. a sudden stop)
 STA DELTA

 LDA #5                 ; Set the amount of damage in A to 5 (a small dent) and
 BNE MA63               ; jump down to MA63 to process the damage (this BNE is
                        ; effectively a JMP as A will never be zero)

.MA58

                        ; If we get here, we have collided with something in a
                        ; potentially fatal way

 ASL INWK+31            ; Set bit 7 of the ship we just collided with, to
 SEC                    ; denote that it has been killed and should be removed
 ROR INWK+31            ; from the local bubble

 LDA INWK+35            ; Load A with the energy level of the ship we just hit

 SEC                    ; Set the amount of damage in A to 128 + A / 2, so
 ROR A                  ; this is quite a big dent, and colliding with higher
                        ; energy ships will cause more damage

.MA63

 JSR OOPS               ; The amount of damage is in A, so call OOPS to reduce
                        ; our shields, and if the shields are gone, there's a
                        ; a chance of cargo loss or even death

 JSR EXNO3              ; Make the sound of colliding with the other ship and
                        ; fall through into MA26 to try targeting a missile

; ******************************************************************************
;
;       Name: Main flight loop (Part 11 of 16)
;       Type: Subroutine
;   Category: Main loop
;    Summary: For each nearby ship: Process missile lock and firing our laser
;  Deep dive: Program flow of the main game loop
;             Flipping axes between space views
;
; ------------------------------------------------------------------------------
;
; The main flight loop covers most of the flight-specific aspects of Elite. This
; section covers the following:
;
;   * Continue looping through all the ships in the local bubble, and for each
;     one:
;
;     * If this is not the front space view, flip the axes of the ship's
;        coordinates in INWK
;
;     * Process missile lock
;
;     * Process our laser firing
;
; ******************************************************************************

.MA26

 LDA QQ11               ; If this is not a space view, jump to MA15 to skip
 BEQ P%+5               ; missile and laser locking
 JMP MA15

 JSR PLUT               ; Call PLUT to update the geometric axes in INWK to
                        ; match the view (front, rear, left, right)

 LDA LAS                ; ???
 BNE C8243
 LDA MSAR
 BEQ C8248
 LDA MSTG
 BPL C8248

.C8243

 JSR HITCH              ; Call HITCH to see if this ship is in the crosshairs,
 BCS C824B              ; in which case the C flag will be set (so if there is
                        ; no missile or laser lock, we jump to MA8 to skip the
                        ; following)

.C8248

 JMP MA8                ; Jump to MA8 to skip the following

.C824B

 LDA MSAR               ; We have missile lock, so check whether the leftmost
 BEQ MA47               ; missile is currently armed, and if not, jump to MA47
                        ; to process laser fire, as we can't lock an unarmed
                        ; missile

 LDA MSTG               ; ???
 BPL MA47

 JSR BEEP_b7            ; We have missile lock and an armed missile, so call
                        ; the BEEP subroutine to make a short, high beep

 LDX XSAV               ; Call ABORT2 to store the details of this missile
 LDY #$6D               ; lock, with the targeted ship's slot number in X
 JSR ABORT2             ; (which we stored in XSAV at the start of this ship's
                        ; loop at MAL1), and set the colour of the missile
                        ; indicator to the colour in Y ($6D) ???

.MA47

                        ; If we get here then the ship is in our sights, but
                        ; we didn't lock a missile, so let's see if we're
                        ; firing the laser

 LDA LAS                ; If we are firing the laser then LAS will contain the
 BEQ MA8                ; laser power (which we set in MA68 above), so if this
                        ; is zero, jump down to MA8 to skip the following

 LDX #15                ; We are firing our laser and the ship in INWK is in
 JSR EXNO               ; the crosshairs, so call EXNO to make the sound of
                        ; us making a laser strike on another ship

 LDA TYPE               ; Did we just hit the space station? If so, jump to
 CMP #SST               ; MA14+2 to make the station hostile, skipping the
 BEQ MA14+2             ; following as we can't destroy a space station

 CMP #8                 ; ???
 BNE C827A
 LDX LAS
 CPX #$32
 BEQ MA14+2

.C827A

 CMP #CON               ; If the ship we hit is less than #CON - i.e. it's not
 BCC BURN               ; a Constrictor, Cougar, Dodo station or the Elite logo,
                        ; jump to BURN to skip the following

 LDA LAS                ; Set A to the power of the laser we just used to hit
                        ; the ship (i.e. the laser in the current view)

 CMP #(Armlas AND 127)  ; If the laser is not a military laser, jump to MA14+2
 BNE MA14+2             ; to skip the following, as only military lasers have
                        ; any effect on the Constrictor or Cougar (or the Elite
                        ; logo, should you ever bump into one of those out there
                        ; in the black...)

 LSR LAS                ; Divide the laser power of the current view by 4, so
 LSR LAS                ; the damage inflicted on the super-ship is a quarter of
                        ; the damage our military lasers would inflict on a
                        ; normal ship

.BURN

 LDA INWK+35            ; Fetch the hit ship's energy from byte #35 and subtract
 SEC                    ; our current laser power, and if the result is greater
 SBC LAS                ; than zero, the other ship has survived the hit, so
 BCS MA14               ; jump down to MA14 to make it angry

 ASL INWK+31            ; Set bit 7 of the ship byte #31 to indicate that it has
 SEC                    ; now been killed
 ROR INWK+31

 JSR subm_F25A          ; ???

 LDA LAS                ; Did we kill the asteroid using mining lasers? If not,
 CMP #Mlas              ; jump to nosp, otherwise keep going
 BNE nosp

 LDA TYPE               ; ???
 CMP #7
 BEQ C82B5
 CMP #6
 BNE nosp
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

.nosp

 LDY #PLT               ; Randomly spawn some alloy plates
 JSR SPIN

 LDY #OIL               ; Randomly spawn some cargo canisters
 JSR SPIN

.C82CE

 LDX TYPE               ; Set X to the type of the ship that was killed so the
                        ; following call to EXNO2 can award us the correct
                        ; number of fractional kill points

 JSR EXNO2              ; Call EXNO2 to process the fact that we have killed a
                        ; ship (so increase the kill tally, make an explosion
                        ; sound and so on)

.MA14

 STA INWK+35            ; Store the hit ship's updated energy in ship byte #35

 LDA TYPE               ; Call ANGRY to make this ship hostile, now that we
 JSR ANGRY              ; have hit it

; ******************************************************************************
;
;       Name: Main flight loop (Part 12 of 16)
;       Type: Subroutine
;   Category: Main loop
;    Summary: For each nearby ship: Draw the ship, remove if killed, loop back
;  Deep dive: Program flow of the main game loop
;             Drawing ships
;
; ------------------------------------------------------------------------------
;
; The main flight loop covers most of the flight-specific aspects of Elite. This
; section covers the following:
;
;   * Continue looping through all the ships in the local bubble, and for each
;     one:
;
;     * Draw the ship
;
;     * Process removal of killed ships
;
;   * Loop back up to MAL1 to move onto the next ship in the local bubble
;
; ******************************************************************************

.MA8

 JSR LL9_b1             ; Call LL9 to draw the ship we're processing on-screen

.MA15

 LDY #35                ; Fetch the ship's energy from byte #35 and copy it to
 LDA INWK+35            ; byte #35 in INF (so the ship's data in K% gets
 STA (INF),Y            ; updated)

 LDA INWK+34
 LDY #34
 STA (INF),Y

 LDA NEWB               ; If bit 7 of the ship's NEWB flags is set, which means
 BMI KS1S               ; the ship has docked or been scooped, jump to KS1S to
                        ; skip the following, as we can't get a bounty for a
                        ; ship that's no longer around

 LDA INWK+31            ; If bit 7 of the ship's byte #31 is clear, then the
 BPL MAC1               ; ship hasn't been killed by energy bomb, collision or
                        ; laser fire, so jump to MAC1 to skip the following

 AND #%00100000         ; If bit 5 of the ship's byte #31 is clear then the
 BEQ MAC1               ; ship is no longer exploding, so jump to MAC1 to skip
                        ; the following

 LDA NEWB               ; Extract bit 6 of the ship's NEWB flags, so A = 64 if
 AND #%01000000         ; bit 6 is set, or 0 if it is clear. Bit 6 is set if
                        ; this ship is a cop, so A = 64 if we just killed a
                        ; policeman, otherwise it is 0

 ORA FIST               ; Update our FIST flag ("fugitive/innocent status") to
 STA FIST               ; at least the value in A, which will instantly make us
                        ; a fugitive if we just shot the sheriff, but won't
                        ; affect our status if the enemy wasn't a copper

 LDA MJ                 ; If we already have an in-flight message on-screen (in
 ORA DLY                ; which case DLY > 0), or we are in witchspace (in
 BNE KS1S               ; which case MJ > 0), jump to KS1S to skip showing an
                        ; on-screen bounty for this kill

 LDY #10                ; Fetch byte #10 of the ship's blueprint, which is the
 JSR GetShipBlueprint   ; low byte of the bounty awarded when this ship is
 BEQ KS1S               ; killed (in Cr * 10), and if it's zero jump to KS1S as
                        ; there is no on-screen bounty to display

 TAX                    ; Put the low byte of the bounty into X

 INY                    ; Fetch byte #11 of the ship's blueprint, which is the
 JSR GetShipBlueprint   ; high byte of the bounty awarded (in Cr * 10), and put
 TAY                    ; it into Y

 JSR MCASH              ; Call MCASH to add (Y X) to the cash pot

 LDA #0                 ; Print control code 0 (current cash, right-aligned to
 JSR MESS               ; width 9, then " CR", newline) as an in-flight message

.KS1S

 JMP KS1                ; Process the killing of this ship (which removes this
                        ; ship from its slot and shuffles all the other ships
                        ; down to close up the gap)

.MAC1

 LDA TYPE               ; If the ship we are processing is a planet or sun,
 BMI MA27               ; jump to MA27 to skip the following two instructions

 JSR FAROF              ; If the ship we are processing is a long way away (its
 BCC KS1S               ; distance in any one direction is > 224, jump to KS1S
                        ; to remove the ship from our local bubble, as it's just
                        ; left the building

.MA27

 LDY #31                ; Fetch the ship's explosion/killed state from byte #31,
 LDA INWK+31            ; clear bit 6 and copy it to byte #31 in INF (so the
 AND #%10111111         ; ship's data in K% gets updated) ???
 STA (INF),Y

 LDX XSAV               ; We're done processing this ship, so fetch the ship's
                        ; slot number, which we saved in XSAV back at the start
                        ; of the loop

 INX                    ; Increment the slot number to move on to the next slot

 RTS                    ; Return from the subroutine

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
 JMP MA16

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
 JMP MA16

.C835B

 LDA #0
 STA L0393

.MA16

 LDA ECMP               ; If our E.C.M is not on, skip to MA69, otherwise keep
 BEQ MA69               ; going to drain some energy

 JSR DENGY              ; Call DENGY to deplete our energy banks by 1

 BEQ MA70               ; If we have no energy left, jump to MA70 to turn our
                        ; E.C.M. off

.MA69

 LDA ECMA               ; If an E.C.M is going off (our's or an opponent's) then
 BEQ MA66               ; keep going, otherwise skip to MA66

 LDA #$80
 STA K+2
 LDA #$7F
 STA K
 LDA Yx1M2
 STA K+3
 STA K+1
 JSR subm_B919_b6

 DEC ECMA               ; Decrement the E.C.M. countdown timer, and if it has
 BNE MA66               ; reached zero, keep going, otherwise skip to MA66

.MA70

 JSR ECMOF              ; If we get here then either we have either run out of
                        ; energy, or the E.C.M. timer has run down, so switch
                        ; off the E.C.M.

.MA66

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
;       Name: Main flight loop (Part 13 of 16)
;       Type: Subroutine
;   Category: Main loop
;    Summary: Show energy bomb effect, charge shields and energy banks
;  Deep dive: Program flow of the main game loop
;             Scheduling tasks with the main loop counter
;
; ------------------------------------------------------------------------------
;
; The main flight loop covers most of the flight-specific aspects of Elite. This
; section covers the following:
;
;   * Show energy bomb effect (if applicable)
;
;   * Charge shields and energy banks (every 7 iterations of the main loop)
;
; ******************************************************************************

.MA18

 SETUP_PPU_FOR_ICON_BAR ; If the PPU has started drawing the icon bar, configure
                        ; the PPU to use nametable 0 and pattern table 0

 LDA BOMB               ; If we set off our energy bomb (see MA24 above), then
 BPL MA77               ; BOMB is now negative, so this skips to MA21 if our
                        ; energy bomb is not going off

 ASL BOMB               ; We set off our energy bomb, so rotate BOMB to the
                        ; left by one place. BOMB was rotated left once already
                        ; during this iteration of the main loop, back at MA24,
                        ; so if this is the first pass it will already be
                        ; %11111110, and this will shift it to %11111100 - so
                        ; if we set off an energy bomb, it stays activated
                        ; (BOMB > 0) for four iterations of the main loop

 BMI MA77               ; If the result has bit 7 set, skip the following
                        ; instruction as the bomb is still going off

 JSR subm_8790          ; ???

 JSR subm_AC5C_b3

.MA77

 LDA MCNT               ; Fetch the main loop counter and calculate MCNT mod 7,
 AND #7                 ; jumping to MA22 if it is non-zero (so the following
 BNE MA22               ; code only runs every 8 iterations of the main loop)

 JSR ChargeShields      ; Charge the shields and energy banks

; ******************************************************************************
;
;       Name: Main flight loop (Part 14 of 16)
;       Type: Subroutine
;   Category: Main loop
;    Summary: Spawn a space station if we are close enough to the planet
;  Deep dive: Program flow of the main game loop
;             Scheduling tasks with the main loop counter
;             Ship data blocks
;             The space station safe zone
;
; ------------------------------------------------------------------------------
;
; The main flight loop covers most of the flight-specific aspects of Elite. This
; section covers the following:
;
;   * Spawn a space station if we are close enough to the planet (every 32
;     iterations of the main loop)
;
; ******************************************************************************

 LDA MJ                 ; If we are in witchspace, jump down to MA23S to skip
 BNE MA23S              ; the following, as there are no space stations in
                        ; witchspace

 LDA MCNT               ; Fetch the main loop counter and calculate MCNT mod 32,
 AND #31                ; jumping to MA93 if it is on-zero (so the following
 BNE MA93               ; code only runs every 32 iterations of the main loop

 LDA SSPR               ; If we are inside the space station safe zone, jump to
 BNE MA23S              ; MA23S to skip the following, as we already have a
                        ; space station and don't need another

 TAY                    ; Set Y = A = 0 (A is 0 as we didn't branch with the
                        ; previous BNE instruction)

 JSR MAS2               ; Call MAS2 to calculate the largest distance to the
 BNE MA23S              ; planet in any of the three axes, and if it's
                        ; non-zero, jump to MA23S to skip the following, as we
                        ; are too far from the planet to bump into a space
                        ; station

                        ; We now want to spawn a space station, so first we
                        ; need to set up a ship data block for the station in
                        ; INWK that we can then pass to NWSPS to add a new
                        ; station to our bubble of universe. We do this by
                        ; copying the planet data block from K% to INWK so we
                        ; can work on it, but we only need the first 29 bytes,
                        ; as we don't need to worry about bytes #29 to #35
                        ; for planets (as they don't have rotation counters,
                        ; AI, explosions, missiles, a ship line heap or energy
                        ; levels)

 LDX #28                ; So we set a counter in X to copy 29 bytes from K%+0
                        ; to K%+28

.MAL4

 LDA K%,X               ; Load the X-th byte of K% and store in the X-th byte
 STA INWK,X             ; of the INWK workspace

 DEX                    ; Decrement the loop counter

 BPL MAL4               ; Loop back for the next byte until we have copied the
                        ; first 28 bytes of K% to INWK

                        ; We now check the distance from our ship (at the
                        ; origin) towards the point where we will spawn the
                        ; space station if we are close enough
                        ;
                        ; This point is calculated by starting at the planet's
                        ; centre and adding 2 * nosev, which takes us to a point
                        ; above the planet's surface, at an altitude that
                        ; matches the planet's radius
                        ;
                        ; This point pitches and rolls around the planet as the
                        ; nosev vector rotates with the planet, and if our ship
                        ; is within a distance of (192 0) from this point in all
                        ; three axes, then we spawn the space station at this
                        ; point, with the station's slot facing towards the
                        ; planet, along the nosev vector
                        ;
                        ; This works because in the following, we calculate the
                        ; station's coordinates one axis at a time, and store
                        ; the results in the INWK block, so by the time we have
                        ; calculated and checked all three, the ship data block
                        ; is set up with the correct spawning coordinates

 JSR SpawnSpaceStation  ; If we are close enough, add a new space station to our
                        ; local bubble of universe

 BCS MA23S              ; If we spawned the space station, jump to MA23S to skip
                        ; the following

 LDX #8                 ; ???

.loop_C83FB

 LDA K%,X
 STA INWK,X

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

 JSR SpawnSpaceStation  ; If we are close enough, add a new space station to our
                        ; local bubble of universe

.MA23S

 JMP MA23               ; Jump to MA23 to skip the following planet and sun
                        ; altitude checks

; ******************************************************************************
;
;       Name: Main flight loop (Part 15 of 16)
;       Type: Subroutine
;   Category: Main loop
;    Summary: Perform altitude checks with the planet and sun and process fuel
;             scooping if appropriate
;  Deep dive: Program flow of the main game loop
;             Scheduling tasks with the main loop counter
;
; ------------------------------------------------------------------------------
;
; The main flight loop covers most of the flight-specific aspects of Elite. This
; section covers the following:
;
;   * Perform an altitude check with the planet (every 16 iterations of the main
;     loop, on iterations 10 and 20 of each 32)
;
;   * Perform an an altitude check with the sun and process fuel scooping (every
;     32 iterations of the main loop, on iteration 20 of each 32)
;
; ******************************************************************************

.MA22

 LDA MJ                 ; If we are in witchspace, jump down to MA23S to skip
 BNE MA23S              ; the following, as there are no planets or suns to
                        ; bump into in witchspace

.MA93

 LDA DLY                ; ???
 BEQ C8436
 LDA JUNK
 CLC
 ADC MANY+1
 TAY
 LDA FRIN+2,Y
 BNE C8436
 LDA #1
 JMP subm_A5AB_b6

.C8436

 LDA MCNT               ; Fetch the main loop counter and calculate MCNT mod 32,
 AND #31                ; which tells us the position of this loop in each block
                        ; of 32 iterations

 CMP #10                ; If this is the tenth or twentieth iteration in this
 BEQ C8442              ; block of 32, do the following, otherwise jump to MA29
 CMP #20                ; to skip the planet altitude check and move on to the
 BNE MA29               ; sun distance check

.C8442

 LDA #80                ; If our energy bank status in ENERGY is >= 80, skip
 CMP ENERGY             ; printing the following message (so the message is
 BCC C8453              ; only shown if our energy is low)

 LDA #100               ; Print recursive token 100 ("ENERGY LOW{beep}") as an
 JSR MESS               ; in-flight message

 LDY #7                 ; ???
 JSR NOISE

.C8453

 JSR CheckAltitude      ; Perform an altitude check with the planet, ending the
                        ; game if we hit the ground

 JMP MA23               ; Jump to MA23 to skip to the next section

.MA28

 JMP DEATH              ; If we get here then we just crashed into the planet
                        ; or got too close to the sun, so jump to DEATH to start
                        ; the funeral preparations and return from the main
                        ; flight loop using a tail call

.MA29

 CMP #15                ; If this is the 15th iteration in this block of 32,
 BNE MA33               ; do the following, otherwise jump to MA33 to skip the
                        ; docking computer manoeuvring

 LDA auto               ; If auto is zero, then the docking computer is not
 BEQ MA23               ; activated, so jump to MA33 to skip the
                        ; docking computer manoeuvring

 LDA #123               ; Set A = 123 and jump down to MA34 to print token 123
 BNE MA34               ; ("DOCKING COMPUTERS ON") as an in-flight message

.MA33

 AND #15                ; If this is the 6th iteration in this block of 16,
 CMP #6                 ; do the following, otherwise jump to MA23 to skip the
 BNE MA23               ; sun altitude check

 LDA #30                ; Set CABTMP to 30, the cabin temperature in deep space
 STA CABTMP             ; (i.e. one notch on the dashboard bar)

 LDA SSPR               ; If we are inside the space station safe zone, jump to
 BNE MA23               ; MA23 to skip the following, as we can't have both the
                        ; sun and space station at the same time, so we clearly
                        ; can't be flying near the sun

 LDY #NI%+4             ; Set Y to NI%+4, which is the offset in K% for the
                        ; sun's data block, as the second block at K% is
                        ; reserved for the sun (or space station)

 JSR MAS2               ; Call MAS2 to calculate the largest distance to the
 BNE MA23               ; sun in any of the three axes, and if it's non-zero,
                        ; jump to MA23 to skip the following, as we are too far
                        ; from the sun for scooping or temperature changes

 JSR MAS3               ; Set A = x_hi^2 + y_hi^2 + z_hi^2, so using Pythagoras
                        ; we now know that A now contains the square of the
                        ; distance between our ship (at the origin) and the
                        ; heart of the sun at (x_hi, y_hi, z_hi)

 EOR #%11111111         ; Invert A, so A is now small if we are far from the
                        ; sun and large if we are close to the sun, in the
                        ; range 0 = far away to $FF = extremely close, ouch,
                        ; hot, hot, hot!

 ADC #30                ; Add the minimum cabin temperature of 30, so we get
                        ; one of the following:
                        ;
                        ;   * If the C flag is clear, A contains the cabin
                        ;     temperature, ranging from 30 to 255, that's hotter
                        ;     the closer we are to the sun
                        ;
                        ;   * If the C flag is set, the addition has rolled over
                        ;     and the cabin temperature is over 255

 STA CABTMP             ; Store the updated cabin temperature

 BCS MA28               ; If the C flag is set then jump to MA28 to die, as
                        ; our temperature is off the scale

 CMP #224               ; If the cabin temperature < 224 then jump to MA23 to
 BCC MA23               ; to skip fuel scooping, as we aren't close enough

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

 LDA BST                ; If we don't have fuel scoops fitted, jump to BA23 to
 BEQ MA23               ; skip fuel scooping, as we can't scoop without fuel
                        ; scoops

 LDA DELT4+1            ; We are now successfully fuel scooping, so it's time
 BEQ MA23               ; to work out how much fuel we're scooping. Fetch the
                        ; high byte of DELT4, which contains our current speed
                        ; divided by 4, and if it is zero, jump to BA23 to skip
                        ; skip fuel scooping, as we can't scoop fuel if we are
                        ; not moving

 LSR A                  ; If we are moving, halve A to get our current speed
                        ; divided by 8 (so it's now a value between 1 and 5, as
                        ; our speed is normally between 1 and 40). This gives
                        ; us the amount of fuel that's being scooped in A, so
                        ; the faster we go, the more fuel we scoop, and because
                        ; the fuel levels are stored as 10 * the fuel in light
                        ; years, that means we just scooped between 0.1 and 0.5
                        ; light years of free fuel !!!

 ADC QQ14               ; Set A = A + the current fuel level * 10 (from QQ14)

 CMP #70                ; If A > 70 then set A = 70 (as 70 is the maximum fuel
 BCC P%+4               ; level, or 7.0 light years)
 LDA #70

 STA QQ14               ; Store the updated fuel level in QQ14

 BCS MA23               ; ???

 JSR subm_EBE9

 JSR subm_9D35

 LDA #160               ; Set A to token 160 ("FUEL SCOOPS ON")

.MA34

 JSR MESS               ; Print the token in A as an in-flight message

; ******************************************************************************
;
;       Name: Main flight loop (Part 16 of 16)
;       Type: Subroutine
;   Category: Main loop
;    Summary: Call stardust routine
;  Deep dive: Program flow of the main game loop
;
; ------------------------------------------------------------------------------
;
; The main flight loop covers most of the flight-specific aspects of Elite. This
; section covers the following:
;
;   * Jump to the stardust routine if we are in a space view
;
;   * Return from the main flight loop
;
; ******************************************************************************

.MA23

 LDA QQ11               ; If this is not a space view (i.e. QQ11 is non-zero)
 BNE MA232              ; then jump to MA232 to return from the main flight loop
                        ; (as MA232 is an RTS)

 JMP STARS_b1           ; This is a space view, so jump to the STARS routine to
                        ; process the stardust, and return from the main flight
                        ; loop using a tail call

; ******************************************************************************
;
;       Name: ChargeShields
;       Type: Subroutine
;   Category: Flight
;    Summary: Charge the shields and energy banks
;
; ******************************************************************************

.ChargeShields

 SETUP_PPU_FOR_ICON_BAR ; If the PPU has started drawing the icon bar, configure
                        ; the PPU to use nametable 0 and pattern table 0

 LDX ENERGY             ; Fetch our ship's energy levels and skip to b if bit 7
 BPL b                  ; is not set, i.e. only charge the shields from the
                        ; energy banks if they are at more than 50% charge

 LDX ASH                ; Call SHD to recharge our aft shield and update the
 JSR SHD                ; shield status in ASH
 STX ASH

 LDX FSH                ; Call SHD to recharge our forward shield and update
 JSR SHD                ; the shield status in FSH
 STX FSH

.b

 SEC                    ; Set A = ENERGY + ENGY + 1, so our ship's energy
 LDA ENGY               ; level goes up by 2 if we have an energy unit fitted,
 ADC ENERGY             ; otherwise it goes up by 1

 BCS paen1              ; If the value of A did not overflow (the maximum
 STA ENERGY             ; energy level is $FF), then store A in ENERGY

.paen1

 RTS                    ; Return from the subroutine

; ******************************************************************************
;
;       Name: CheckAltitude
;       Type: Subroutine
;   Category: Flight
;    Summary: Perform an altitude check with the planet, ending the game if we
;             hit the ground
;
; ******************************************************************************

.CheckAltitude

 LDY #$FF               ; Set our altitude in ALTIT to $FF, the maximum
 STY ALTIT

 INY                    ; Set Y = 0

 JSR m                  ; Call m to calculate the maximum distance to the
                        ; planet in any of the three axes, returned in A

 BNE MA232              ; If A > 0 then we are a fair distance away from the
                        ; planet in at least one axis, so jump to MA232 to skip
                        ; the rest of the altitude check

 JSR MAS3               ; Set A = x_hi^2 + y_hi^2 + z_hi^2, so using Pythagoras
                        ; we now know that A now contains the square of the
                        ; distance between our ship (at the origin) and the
                        ; centre of the planet at (x_hi, y_hi, z_hi)

 BCS MA232              ; If the C flag was set by MAS3, then the result
                        ; overflowed (was greater than $FF) and we are still a
                        ; fair distance from the planet, so jump to MA232 as we
                        ; haven't crashed into the planet

 SBC #36                ; Subtract 36 from x_hi^2 + y_hi^2 + z_hi^2. The radius
                        ; of the planet is defined as 6 units and 6^2 = 36, so
                        ; A now contains the high byte of our altitude above
                        ; the planet surface, squared

 BCC MA282              ; If A < 0 then jump to MA282 as we have crashed into
                        ; the planet

 STA R                  ; Set (R Q) = (A Q)

 SETUP_PPU_FOR_ICON_BAR ; If the PPU has started drawing the icon bar, configure
                        ; the PPU to use nametable 0 and pattern table 0

 JSR LL5                ; We are getting close to the planet, so we need to
                        ; work out how close. We know from the above that A
                        ; contains our altitude squared, so we store A in R
                        ; and call LL5 to calculate:
                        ;
                        ;   Q = SQRT(R Q) = SQRT(A Q)
                        ;
                        ; Interestingly, Q doesn't appear to be set to 0 for
                        ; this calculation, so presumably this doesn't make a
                        ; difference

 LDA Q                  ; Store the result in ALTIT, our altitude
 STA ALTIT

 BNE MA232              ; If our altitude is non-zero then we haven't crashed,
                        ; so jump to MA232 to skip to the next section

.MA282

 JMP DEATH              ; If we get here then we just crashed into the planet
                        ; or got too close to the sun, so jump to DEATH to start
                        ; the funeral preparations and return from the main
                        ; flight loop using a tail call

.MA232

 RTS                    ; Return from the subroutine

; ******************************************************************************
;
;       Name: Main flight loop (Part 1 of 16)
;       Type: Subroutine
;   Category: Main loop
;    Summary: Seed the random number generator
;  Deep dive: Program flow of the main game loop
;             Generating random numbers
;
; ------------------------------------------------------------------------------
;
; The main flight loop covers most of the flight-specific aspects of Elite. This
; section covers the following:
;
;   * Seed the random number generator
;
; Other entry points:
;
;   M%                  The entry point for the main flight loop
;
; ******************************************************************************

.M%

 LDA QQ11
 BNE C853A
 JSR ChangeDrawingPhase

.C853A

 SETUP_PPU_FOR_ICON_BAR ; If the PPU has started drawing the icon bar, configure
                        ; the PPU to use nametable 0 and pattern table 0

 LDA K%                 ; We want to seed the random number generator with a
                        ; pretty random number, so fetch the contents of K%,
                        ; which is the x_lo coordinate of the planet. This value
                        ; will be fairly unpredictable, so it's a pretty good
                        ; candidate

 EOR nmiTimerLo         ; EOR the value of K% with the low byte of the NMI
                        ; timer, which gets updated by the NMI interrupt
                        ; routine, so this will be fairly unpredictable too

 STA RAND               ; Store the seed in the first byte of the four-byte
                        ; random number seed that's stored in RAND

; ******************************************************************************
;
;       Name: Main flight loop (Part 2 of 16)
;       Type: Subroutine
;   Category: Main loop
;    Summary: Calculate the alpha and beta angles from the current pitch and
;             roll of our ship
;  Deep dive: Program flow of the main game loop
;             Pitching and rolling
;
; ------------------------------------------------------------------------------
;
; The main flight loop covers most of the flight-specific aspects of Elite. This
; section covers the following:
;
;   * Calculate the alpha and beta angles from the current pitch and roll
;
; Here we take the current rate of pitch and roll, as set by the controller,
; and convert them into alpha and beta angles that we can use in the
; matrix functions to rotate space around our ship. The alpha angle covers
; roll, while the beta angle covers pitch (there is no yaw in this version of
; Elite). The angles are in radians, which allows us to use the small angle
; approximation when moving objects in the sky (see the MVEIT routine for more
; on this). Also, the signs of the two angles are stored separately, in both
; the sign and the flipped sign, as this makes calculations easier.
;
; ******************************************************************************

 LDA auto               ; ???
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

 LDX JSTX               ; Set X to the current rate of roll in JSTX

 LDY scanController2    ; ???

 LDA controller1Left,Y
 ORA controller1Right,Y
 ORA KY3
 ORA KY4

 BMI C858A

 LDA #$10
 JSR cntr

.C858A

                        ; The roll rate in JSTX increases if we press ">" (and
                        ; the RL indicator on the dashboard goes to the right).
                        ; This rolls our ship to the right (clockwise), but we
                        ; actually implement this by rolling everything else
                        ; to the left (anti-clockwise), so a positive roll rate
                        ; in JSTX translates to a negative roll angle alpha

 TXA                    ; Set A and Y to the roll rate but with the sign bit
 EOR #%10000000         ; flipped (i.e. set them to the sign we want for alpha)
 TAY

 AND #%10000000         ; Extract the flipped sign of the roll rate and store
 STA ALP2               ; in ALP2 (so ALP2 contains the sign of the roll angle
                        ; alpha)

 STX JSTX               ; Update JSTX with the damped value that's still in X

 EOR #%10000000         ; Extract the correct sign of the roll rate and store
 STA ALP2+1             ; in ALP2+1 (so ALP2+1 contains the flipped sign of the
                        ; roll angle alpha)

 TYA                    ; Set A to the roll rate but with the sign bit flipped

 BPL P%+7               ; If the value of A is positive, skip the following
                        ; three instructions

 EOR #%11111111         ; A is negative, so change the sign of A using two's
 CLC                    ; complement so that A is now positive and contains
 ADC #1                 ; the absolute value of the roll rate, i.e. |JSTX|

 LSR A                  ; Divide the (positive) roll rate in A by 4
 LSR A

 STA ALP1               ; Store A in ALP1, so we now have:
                        ;
                        ;   ALP1 = |JSTX| / 8    if |JSTX| < 32
                        ;
                        ;   ALP1 = |JSTX| / 4    if |JSTX| >= 32
                        ;
                        ; This means that at lower roll rates, the roll angle is
                        ; reduced closer to zero than at higher roll rates,
                        ; which gives us finer control over the ship's roll at
                        ; lower roll rates
                        ;
                        ; Because JSTX is in the range -127 to +127, ALP1 is
                        ; in the range 0 to 31

 ORA ALP2               ; Store A in ALPHA, but with the sign set to ALP2 (so
 STA ALPHA              ; ALPHA has a different sign to the actual roll rate)

 LDX JSTY               ; Set X to the current rate of pitch in JSTY

 LDY scanController2    ; ???
 LDA controller1Up,Y
 ORA controller1Down,Y
 ORA KY5
 ORA KY6
 BMI C85C2
 LDA #$0C

 JSR cntr               ; Apply keyboard damping so the pitch rate in X creeps
                        ; towards the centre by 1

.C85C2

 TXA                    ; Set A and Y to the pitch rate but with the sign bit
 EOR #%10000000         ; flipped
 TAY

 AND #%10000000         ; Extract the flipped sign of the pitch rate into A

 STX JSTY               ; Update JSTY with the damped value that's still in X

 STA BET2+1             ; Store the flipped sign of the pitch rate in BET2+1

 EOR #%10000000         ; Extract the correct sign of the pitch rate and store
 STA BET2               ; it in BET2

 TYA                    ; Set A to the pitch rate but with the sign bit flipped

 BPL P%+4               ; If the value of A is positive, skip the following
                        ; instruction

 EOR #%11111111         ; A is negative, so flip the bits

 ADC #1                 ; Add 1 to the (positive) pitch rate, so the maximum
                        ; value is now up to 128 (rather than 127)

 LSR A                  ; Divide the (positive) pitch rate in A by 8
 LSR A
 LSR A

 STA BET1               ; Store A in BET1, so we now have:
                        ;
                        ;   BET1 = |JSTY| / 32    if |JSTY| < 48
                        ;
                        ;   BET1 = |JSTY| / 16    if |JSTY| >= 48
                        ;
                        ; This means that at lower pitch rates, the pitch angle
                        ; is reduced closer to zero than at higher pitch rates,
                        ; which gives us finer control over the ship's pitch at
                        ; lower pitch rates
                        ;
                        ; Because JSTY is in the range -131 to +131, BET1 is in
                        ; the range 0 to 8

 ORA BET2               ; Store A in BETA, but with the sign set to BET2 (so
 STA BETA               ; BETA has the same sign as the actual pitch rate)

; ******************************************************************************
;
;       Name: Main flight loop (Part 3 of 16)
;       Type: Subroutine
;   Category: Main loop
;    Summary: Scan for flight keys and process the results
;  Deep dive: Program flow of the main game loop
;             The key logger
;
; ------------------------------------------------------------------------------
;
; The main flight loop covers most of the flight-specific aspects of Elite. This
; section covers the following:
;
;   * Scan for flight keys and process the results
;
; Flight keys are logged in the key logger at location KY1 onwards, with a
; non-zero value in the relevant location indicating a key press. See the deep
; dive on "The key logger" for more details.
;
; ******************************************************************************

.BS2

 LDA KY2                ; If Space is being pressed, keep going, otherwise jump
 BEQ MA17               ; down to MA17 to skip the following

 LDA DELTA              ; The "go faster" key is being pressed, so first we
 CLC                    ; add 4 to the current speed in DELTA (we also store
 ADC #4                 ; this value in DELTA, though this isn't necessary as
 STA DELTA              ; we are about to do that again)

 CMP #40                ; If the new speed in A < 40, then this is a valid
 BCC C85F3              ; speed, so jump down to C85F3 to set DELTA to this
                        ; value

 LDA #40                ; The maximum allowed speed is 40, so set A = 40

.C85F3

 STA DELTA              ; Store the updated speed in DELTA

.MA17

 SETUP_PPU_FOR_ICON_BAR ; If the PPU has started drawing the icon bar, configure
                        ; the PPU to use nametable 0 and pattern table 0

 LDA KY1                ; If "?" is being pressed, keep going, otherwise jump
 BEQ MA4                ; down to MA4 to skip the following

 LDA DELTA              ; The "slow down" key is being pressed, so subtract 4
 SEC                    ; from the speed in DELTA
 SBC #4

 BEQ C8610              ; If the result is zero, jump to C8610 to set the speed
                        ; to the minimum value of 1

 BCS C8612              ; If the subtraction didn't underflow then this is a
                        ; valid speed, so jump down to C8612 to set DELTA to
                        ; this value

.C8610

 LDA #1                 ; Set A = 1 to use as the minimum speed

.C8612

 STA DELTA              ; Store the updated speed in DELTA

.MA4

 LDA L0081              ; ???
 CMP #$18
 BNE MA25

 LDA NOMSL
 BEQ MA64S

 LDA MSAR
 EOR #$FF
 STA MSAR

 BNE MA20

 LDY #$6C               ; The "disarm missiles" key is being pressed, so call
 JSR ABORT              ; ABORT to disarm the missile and update the missile
                        ; indicators on the dashboard to green (Y = $6C) ???

 LDY #4                 ; ???

.loop_C8630

 JSR NOISE

 JMP MA64

.MA20

 LDY #$6C               ; ???
 LDX NOMSL
 JSR MSBAR

 LDY #3
 BNE loop_C8630

.MA25

 CMP #$19               ; ???
 BNE MA24

 LDA MSTG               ; If MSTG = $FF then there is no target lock, so jump to
 BMI MA64S              ; MA64 via MA64S to skip the following (also skipping the
                        ; checks for the energy bomb)

 JSR FRMIS              ; The "fire missile" key is being pressed and we have
                        ; a missile lock, so call the FRMIS routine to fire
                        ; the missile

 JSR subm_AC5C_b3       ; ???

.MA64S

 JMP MA64

.MA24

 CMP #$1A               ; ???
 BNE MA76

 LDA BOMB               ; If we already set off our energy bomb, then BOMB is
 BMI MA64S              ; negative, so this skips to MA64 via MA64S if our
                        ; energy bomb is already going off

 ASL BOMB               ; ???
 BEQ MA64S
 LDA #$28
 STA hiddenColour
 LDY #8
 JSR NOISE
 JMP MA64

.MA76

 CMP #$1B               ; ???
 BNE noescp

 LDX ESCP
 BEQ MA64

 LDA MJ                 ; If we are in witchspace, we can't launch our escape
 BNE MA64               ; pod, so jump down to MA64

 JMP ESCAPE             ; The "launch escape pod" button is being pressed and
                        ; we have an escape pod fitted, so jump to ESCAPE to
                        ; launch it, and exit the main flight loop using a tail
                        ; call

.noescp

 CMP #$0C               ; ???
 BNE C8690
 LDA L0300
 AND #$C0
 BNE MA64
 JSR WARP
 JMP MA64

.C8690

 CMP #$17
 BNE MA64

 LDA ECM
 BEQ MA64

 LDA ECMA               ; If ECMA is non-zero, that means an E.C.M. is already
 BNE MA64               ; operating and is counting down (this can be either
                        ; our E.C.M. or an opponent's), so jump down to MA64 to
                        ; skip the following (as we can't have two E.C.M.
                        ; systems operating at the same time)

 DEC ECMP               ; The "E.C.M." button is being pressed and nobody else
                        ; is operating their E.C.M., so decrease the value of
                        ; ECMP to make it non-zero, to denote that our E.C.M.
                        ; is now on

 JSR ECBLB2             ; Call ECBLB2 to light up the E.C.M. indicator bulb on
                        ; the dashboard, set the E.C.M. countdown timer to 32,
                        ; and start making the E.C.M. sound

.MA64

 JSR SetupPPUForIconBar ; If the PPU has started drawing the icon bar, configure
                        ; the PPU to use nametable 0 and pattern table 0

.MA68

 LDA #0                 ; Set LAS = 0, to switch the laser off while we do the
 STA LAS                ; following logic

 STA DELT4              ; Take the 16-bit value (DELTA 0) - i.e. a two-byte
 LDA DELTA              ; number with DELTA as the high byte and 0 as the low
 LSR A                  ; byte - and divide it by 4, storing the 16-bit result
 ROR DELT4              ; in DELT4(1 0). This has the effect of storing the
 LSR A                  ; current speed * 64 in the 16-bit location DELT4(1 0)
 ROR DELT4
 STA DELT4+1

 LDA LASCT              ; ???
 ORA QQ11
 BNE MA3

 LDA KY7                ; If "A" is being pressed, keep going, otherwise jump
 BPL MA3                ; down to MA3 to skip the following

 LDA GNTMP              ; If the laser temperature >= 242 then the laser has
 CMP #242               ; overheated, so jump down to MA3 to skip the following
 BCS MA3

 LDX VIEW               ; If the current space view has a laser fitted (i.e. the
 LDA LASER,X            ; laser power for this view is greater than zero), then
 BEQ MA3                ; keep going, otherwise jump down to MA3 to skip the
                        ; following

 BMI C86D9              ; ???
 BIT KY7
 BVS MA3

.C86D9

                        ; If we get here, then the "fire" button is being
                        ; pressed, our laser hasn't overheated and isn't already
                        ; being fired, and we actually have a laser fitted to
                        ; the current space view, so it's time to hit me with
                        ; those laser beams

 PHA                    ; Store the current view's laser power on the stack

 AND #%01111111         ; Set LAS and LAS2 to bits 0-6 of the laser power
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
 EQUB $2C

.C86F7

 LDY #$0F

.C86F9

 JSR NOISE

 JSR LASLI              ; Call LASLI to draw the laser lines

 PLA                    ; Restore the current view's laser power into A

 BPL ma1                ; If the laser power has bit 7 set, then it's an "always
                        ; on" laser rather than a pulsing laser, so keep going,
                        ; otherwise jump down to ma1 to skip the following
                        ; instruction

 LDA #0                 ; This is an "always on" laser (i.e. a beam laser,
                        ; as the cassette version of Elite doesn't have military
                        ; lasers), so set A = 0, which will be stored in LASCT
                        ; to denote that this is not a pulsing laser

.ma1

 AND #%11101111         ; LASCT will be set to 0 for beam lasers, and to the
 STA LASCT              ; laser power AND %11101111 for pulse lasers, which
                        ; comes to 10 ??? (as pulse lasers have a power of 15). See
                        ; MA23 below for more on laser pulsing and LASCT

.MA3

 JSR subm_MA23          ; ???

 LDA QQ11
 BNE C874C

 JSR SetupPPUForIconBar ; If the PPU has started drawing the icon bar, configure
                        ; the PPU to use nametable 0 and pattern table 0

 LDA drawingPhase       ; ???
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
 BPL oh
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
 BMI oh
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

.oh

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
 JSR subm_B882_b4
 LDA S
 ORA #$80
 CMP systemFlag
 STA systemFlag
 BEQ C8923
 JSR subm_EB8C

.C8923

 JSR subm_A082_b6

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
 JSR CopyNameBuffer0To1
 LDA QQ11
 CMP QQ11a
 BEQ C8976
 JSR subm_A7B7_b3

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
 JSR CopyNameBuffer0To1
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
 JSR subm_AC5C_b3
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
 JSR subm_BA63_b6
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

 JSR ZINF
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
 JSR subm_B919_b6
 PLA
 STA STP

.C93A6

 JSR subm_BA17_b6
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
 JSR subm_B919_b6
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
 JSR subm_B63D_b3

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
 JSR ZINF
 LDA #$1F
 STA TYPE
 JSR NWSHP
 JSR subm_BAF3_b1
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
;   Category: Demo
;    Summary: ???
;
; ******************************************************************************

.DemoShips

 JSR RES2
 JSR subm_B8FE_b6
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
 JSR CopyNameBuffer0To1
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
 JSR subm_BA23_b3
 LSR L0300
 JSR subm_AC5C_b3
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

 JSR ZINF
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
 JSR subm_B219_b3
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
 JSR subm_B2BC_b3
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
 JSR SetPatternBuffer
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
 JSR subm_AC5C_b3
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
 JMP subm_9D35

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
 BNE subm_9D35
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

.subm_9D35

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
 JMP subm_AC5C_b3

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
 JMP subm_BE52_b6

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
 JMP subm_AC5C_b3

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
 JSR subm_AC5C_b3
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
 JSR subm_AC5C_b3
 JSR subm_BE52_b6
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
 JSR subm_AC5C_b3
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
 JSR HideScannerSprites
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
 JSR subm_B9C1_b4
 JMP subm_A4A5_b6

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
 JSR subm_A4A5_b6
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
 JSR subm_A4A5_b6
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
 JSR subm_B2BC_b3
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
 JSR subm_A166_b6
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
 JSR ZINF
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
 JMP subm_AC5C_b3

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

 JSR ZINF
 LDA #0
 STA FRIN+1
 STA SSPR
 LDA #6
 STA INWK+5
 LDA #$81
 JSR NWSHP
 JMP subm_AC5C_b3

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
 JSR subm_BAF3_b1
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
 JMP subm_AC5C_b3

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
 JSR HideSprites59_62
 JSR HideScannerSprites

.CAE00

 JSR subm_B46B

; ******************************************************************************
;
;       Name: ZINF
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.ZINF

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
 JSR ZINF
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
 BCS subm_B039
 LSR A
 LSR A

.subm_B039

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
 JSR subm_AC5C_b3

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
 JSR subm_8021_b6
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
 JMP subm_B459_b6

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
 JSR subm_A166_b6
 SEC
 RTS

.CB1E2

 CLC
 RTS

; ******************************************************************************
;
;       Name: DEATH
;       Type: Subroutine
;   Category: Start and end
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
 JSR subm_BED2_b6
 JSR CopyNameBuffer0To1
 JSR subm_EB86
 LDA #0
 STA L045F
 LDA #$C4
 JSR subm_A7B7_b3
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
 JSR subm_BED2_b6
 LDA #$CC
 JSR subm_D977
 DEC LASCT
 BNE loop_CB2AD
 JMP DEATH2

; ******************************************************************************
;
;       Name: ShowStartScreen
;       Type: Subroutine
;   Category: Start and end
;    Summary: ???
;
; ******************************************************************************

.ShowStartScreen

 LDA #$FF
 STA L0307
 LDA #$80
 STA L0308
 LDA #$1B
 STA L0309
 LDA #$34
 STA L030A
 JSR ResetSoundL045E
 JSR subm_B906_b6
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
;       Name: DEATH2
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.DEATH2

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
 JSR subm_8021_b6
 LDA L0305
 CLC
 ADC #6
 STA L0305
 PLA
 JMP subm_A5AB_b6

.CB341

 JSR BR2_Part2
 LDA #$FF
 STA QQ11
 JSR KeepPPUTablesAt0
 LDA #4
 JSR subm_8021_b6
 LDA #2
 JMP subm_A5AB_b6

.CB355

 JSR subm_B63D_b3

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

 JSR subm_B8FE_b6
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
 JSR CopyNameBuffer0To1
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
 JSR subm_BAF3_b1
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
;       Name: SpawnSpaceStation
;       Type: Subroutine
;   Category: Universe
;    Summary: Add a space station to the local bubble of universe if we are
;             close enough to the station's orbit
;
; ******************************************************************************

.SpawnSpaceStation

                        ; We now check the distance from our ship (at the
                        ; origin) towards the point where we will spawn the
                        ; space station if we are close enough
                        ;
                        ; This point is calculated by starting at the planet's
                        ; centre and adding 2 * nosev, which takes us to a point
                        ; above the planet's surface, at an altitude that
                        ; matches the planet's radius
                        ;
                        ; This point pitches and rolls around the planet as the
                        ; nosev vector rotates with the planet, and if our ship
                        ; is within a distance of (100 0) from this point in all
                        ; three axes, then we spawn the space station at this
                        ; point, with the station's slot facing towards the
                        ; planet, along the nosev vector
                        ;
                        ; This works because in the following, we calculate the
                        ; station's coordinates one axis at a time, and store
                        ; the results in the INWK block, so by the time we have
                        ; calculated and checked all three, the ship data block
                        ; is set up with the correct spawning coordinates

 SETUP_PPU_FOR_ICON_BAR ; If the PPU has started drawing the icon bar, configure
                        ; the PPU to use nametable 0 and pattern table 0

 LDX #0                 ; Call MAS1 with X = 0, Y = 9 to do the following:
 LDY #9                 ;
 JSR MAS1               ;   (x_sign x_hi x_lo) += (nosev_x_hi nosev_x_lo) * 2
                        ;
                        ;   A = |x_sign|

 BNE MA23S2             ; If A > 0, jump to MA23S2 to skip the following, as we
                        ; are too far from the planet in the x-direction to
                        ; bump into a space station

 LDX #3                 ; Call MAS1 with X = 3, Y = 11 to do the following:
 LDY #11                ;
 JSR MAS1               ;   (y_sign y_hi y_lo) += (nosev_y_hi nosev_y_lo) * 2
                        ;
                        ;   A = |y_sign|

 BNE MA23S2             ; If A > 0, jump to MA23S2 to skip the following, as we
                        ; are too far from the planet in the y-direction to
                        ; bump into a space station

 LDX #6                 ; Call MAS1 with X = 6, Y = 13 to do the following:
 LDY #13                ;
 JSR MAS1               ;   (z_sign z_hi z_lo) += (nosev_z_hi nosev_z_lo) * 2
                        ;
                        ;   A = |z_sign|

 BNE MA23S2             ; If A > 0, jump to MA23S2 to skip the following, as we
                        ; are too far from the planet in the z-direction to
                        ; bump into a space station

 LDA #100               ; Call FAROF2 to compare x_hi, y_hi and z_hi with 100,
 JSR FAROF2             ; which will set the C flag if all three are < 100, or
                        ; clear the C flag if any of them are >= 100 ???

 BCS MA23S2             ; Jump to MA23S2 if any one of x_hi, y_hi or z_hi are
                        ; >= 100 (i.e. they must all be < 100 for us to be near
                        ; enough to the planet to bump into a space station)
                        ; ??? (this is a BCS not a BCC)

 JSR NWSPS              ; Add a new space station to our local bubble of
                        ; universe

 SEC                    ; Set the C flag to indicate that we have added the
                        ; space station

 RTS                    ; Return from the subroutine

.MA23S2

 SETUP_PPU_FOR_ICON_BAR ; If the PPU has started drawing the icon bar, configure
                        ; the PPU to use nametable 0 and pattern table 0

 CLC                    ; Clear the C flag to indicate that we have not added
                        ; the space station

 RTS                    ; Return from the subroutine

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
;       Name: WARP
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.WARP

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

 JSR CheckAltitude      ; Perform an altitude check with the planet, ending the
                        ; game if we hit the ground

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

 JSR ChargeShields
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

 JSR SetKeyLogger_b6
 LDA auto
 BNE CB6BA

.CB6B0

 LDX L0081
 CPX #$40
 BNE CB6B9
 JMP subm_A166_b6

.CB6B9

 RTS

.CB6BA

 LDA SSPR
 BNE CB6C8
 STA auto
 JSR WaitResetSound
 JMP CB6B0

.CB6C8

 JSR ZINF
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
 JMP subm_AC5C_b3

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

 JMP SetKeyLogger_b6

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
 JSR CopyNameBuffer0To1
 JSR subm_A7B7_b3
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
 JSR CopyNameBuffer0To1
 LDA #$50
 STA L00CD
 STA L00CE
 JSR subm_A9D1_b3

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
 JSR subm_BA23_b3

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
 JSR HideScannerSprites

.CBEC4

 JSR subm_D8C5
 JSR ClearTiles_b3
 LDA #$10
 STA L00B5
 LDX #0
 STX L046D
 JSR SetDrawingPhase
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
 JSR subm_AFCD_b3
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
 JSR subm_AE18_b3
 LDA QQ11a
 BPL CBF2B
 JSR subm_EB86
 JSR subm_A775_b3

.CBF2B

 JSR subm_A730_b3
 JSR msblob
 JMP CBF91

.loop_CBF34

 JMP subm_B9E2_b3

.CBF37

 TXA
 JSR subm_AE18_b3
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
 JSR subm_B0E1_b3

.CBF54

 LDA QQ11
 AND #$20
 BEQ CBF5D
 JSR subm_B18E_b3

.CBF5D

 LDA #1

 STA nameBuffer0+20*32+1
 STA nameBuffer0+21*32+1
 STA nameBuffer0+22*32+1
 STA nameBuffer0+23*32+1
 STA nameBuffer0+24*32+1
 STA nameBuffer0+25*32+1
 STA nameBuffer0+26*32+1

 LDA #2

 STA nameBuffer0+20*32
 STA nameBuffer0+21*32
 STA nameBuffer0+22*32
 STA nameBuffer0+23*32
 STA nameBuffer0+24*32
 STA nameBuffer0+25*32
 STA nameBuffer0+26*32

 LDA QQ11
 AND #$40
 BNE CBF91

.CBF91

 JSR subm_B9E2_b3
 LDA DLY
 BMI CBFA1
 LDA QQ11
 BPL CBFA1
 CMP QQ11a
 BEQ CBFA1

.CBFA1

 JSR DrawBoxTop
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
