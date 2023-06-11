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

 LDA K%+NIK%+36         ; 1. Fetch the NEWB flags (byte #36) of the second ship
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

 JSR HideHiddenColour   ; ???

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

 LDY #NIK%              ; Set Y to NIK%+4, which is the offset in K% for the
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

 LDA #$28               ; Set hiddenColour to $28, which is green-brown, so this
 STA hiddenColour       ; reveals pixels that use the (no-longer) hidden colour
                        ; in palette 0

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
;   Category: Universe
;    Summary: Randomly spawn cargo from a destroyed ship
;
; ------------------------------------------------------------------------------
;
; Arguments:
;
;   Y                   The type of cargo to consider spawning (typically #PLT
;                       or #OIL)
;
; Other entry points:
;
;   SPIN2               Remove any randomness: spawn cargo of a specific type
;                       (given in X), and always spawn the number given in A
;
; ******************************************************************************

.SPIN

 JSR DORND              ; Fetch a random number, and jump to oh if it is
 BPL oh                 ; positive (50% chance)

 TYA                    ; Copy the cargo type from Y into A and X
 TAX

 LDY #0                 ; Set Y = 0 to use as an index into the ship's blueprint
                        ; in the call to GetShipBlueprint

 STA CNT                ; Store the random numner in CNT

 JSR GetShipBlueprint   ; Fetch the first byte of the hit ship's blueprint,
                        ; which determines the maximum number of bits of
                        ; debris shown when the ship is destroyed

 AND CNT                ; AND with the random number we fetched above

 AND #15                ; Reduce the random number in A to the range 0-15

.SPIN2

 STA CNT                ; Store the result in CNT, so CNT contains a random
                        ; number between 0 and the maximum number of bits of
                        ; debris that this ship will release when destroyed
                        ; (to a maximum of 15 bits of debris)

.spl

 DEC CNT                ; Decrease the loop counter

 BMI oh                 ; We're going to go round a loop using CNT as a counter
                        ; so this checks whether the counter was zero and jumps
                        ; to oh when it gets there (which might be straight
                        ; away)

 LDA #0                 ; Call SFS1 to spawn the specified cargo from the now
 JSR SFS1               ; deceased parent ship, giving the spawned canister an
                        ; AI flag of 0 (no AI, no E.C.M., non-hostile)

 JMP spl                ; Loop back to spawn the next bit of random cargo

; ******************************************************************************
;
;       Name: HideHiddenColour
;       Type: Subroutine
;   Category: Drawing tiles
;    Summary: Set the hidden colour to black, so that pixels in this colour in
;             palette 0 are invisible
;
; ------------------------------------------------------------------------------
;
; Other entry points:
;
;   oh                  Contains an RTS
;
; ******************************************************************************

.HideHiddenColour

 LDA #$0F               ; Set hiddenColour to $0F, which is black, so this hides
 STA hiddenColour       ; any pixels that use the hidden colour in palette 0

.oh

 RTS                    ; Return from the subroutine

; ******************************************************************************
;
;       Name: scacol
;       Type: Variable
;   Category: Drawing ships
;    Summary: Ship colours on the scanner
;  Deep dive: The elusive Cougar
;
; ******************************************************************************

.scacol

 EQUB 0

 EQUB 3                 ; Missile
 EQUB 0                 ; Coriolis space station
 EQUB 1                 ; Escape pod
 EQUB 1                 ; Alloy plate
 EQUB 1                 ; Cargo canister
 EQUB 1                 ; Boulder
 EQUB 1                 ; Asteroid
 EQUB 1                 ; Splinter
 EQUB 2                 ; Shuttle
 EQUB 2                 ; Transporter
 EQUB 2                 ; Cobra Mk III
 EQUB 2                 ; Python
 EQUB 2                 ; Boa
 EQUB 2                 ; Anaconda
 EQUB 1                 ; Rock hermit (asteroid)
 EQUB 2                 ; Viper
 EQUB 2                 ; Sidewinder
 EQUB 2                 ; Mamba
 EQUB 2                 ; Krait
 EQUB 2                 ; Adder
 EQUB 2                 ; Gecko
 EQUB 2                 ; Cobra Mk I
 EQUB 2                 ; Worm
 EQUB 2                 ; Cobra Mk III (pirate)
 EQUB 2                 ; Asp Mk II
 EQUB 2                 ; Python (pirate)
 EQUB 2                 ; Fer-de-lance
 EQUB 2                 ; Moray
 EQUB 0                 ; Thargoid
 EQUB 3                 ; Thargon
 EQUB 2                 ; Constrictor
 EQUB 255               ; Cougar

 EQUB 0                 ; This byte appears to be unused

 EQUD 0                 ; These bytes appear to be unused

; ******************************************************************************
;
;       Name: SetAXTo15 (Unused)
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
;       Name: STATUS
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

.STATUS

 LDA #$98
 JSR ChangeViewRow0
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
 JSR PrintSpaceAndToken

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
;   Category: Moving
;    Summary: Calculate K(3 2 1) = (x_sign x_hi x_lo) + K(3 2 1)
;
; ------------------------------------------------------------------------------
;
; Add an INWK position coordinate - i.e. x, y or z - to K(3 2 1), like this:
;
;   K(3 2 1) = (x_sign x_hi x_lo) + K(3 2 1)
;
; The INWK coordinate to add to K(3 2 1) is specified by X.
;
; Arguments:
;
;   X                   The coordinate to add to K(3 2 1), as follows:
;
;                         * If X = 0, add (x_sign x_hi x_lo)
;
;                         * If X = 3, add (y_sign y_hi y_lo)
;
;                         * If X = 6, add (z_sign z_hi z_lo)
;
; Returns:
;
;   A                   Contains a copy of the high byte of the result, K+3
;
;   X                   X is preserved
;
; ******************************************************************************

.MVT3

 LDA K+3                ; Set S = K+3
 STA S

 AND #%10000000         ; Set T = sign bit of K(3 2 1)
 STA T

 EOR INWK+2,X           ; If x_sign has a different sign to K(3 2 1), jump to
 BMI MV13               ; MV13 to process the addition as a subtraction

 LDA K+1                ; Set K(3 2 1) = K(3 2 1) + (x_sign x_hi x_lo)
 CLC                    ; starting with the low bytes
 ADC INWK,X
 STA K+1

 LDA K+2                ; Then the middle bytes
 ADC INWK+1,X
 STA K+2

 LDA K+3                ; And finally the high bytes
 ADC INWK+2,X

 AND #%01111111         ; Setting the sign bit of K+3 to T, the original sign
 ORA T                  ; of K(3 2 1)
 STA K+3

 RTS                    ; Return from the subroutine

.MV13

 LDA S                  ; Set S = |K+3| (i.e. K+3 with the sign bit cleared)
 AND #%01111111
 STA S

 LDA INWK,X             ; Set K(3 2 1) = (x_sign x_hi x_lo) - K(3 2 1)
 SEC                    ; starting with the low bytes
 SBC K+1
 STA K+1

 LDA INWK+1,X           ; Then the middle bytes
 SBC K+2
 STA K+2

 LDA INWK+2,X           ; And finally the high bytes, doing A = |x_sign| - |K+3|
 AND #%01111111         ; and setting the C flag for testing below
 SBC S

 ORA #%10000000         ; Set the sign bit of K+3 to the opposite sign of T,
 EOR T                  ; i.e. the opposite sign to the original K(3 2 1)
 STA K+3

 BCS MV14               ; If the C flag is set, i.e. |x_sign| >= |K+3|, then
                        ; the sign of K(3 2 1). In this case, we want the
                        ; result to have the same sign as the largest argument,
                        ; which is (x_sign x_hi x_lo), which we know has the
                        ; opposite sign to K(3 2 1), and that's what we just set
                        ; the sign of K(3 2 1) to... so we can jump to MV14 to
                        ; return from the subroutine

 LDA #1                 ; We need to swap the sign of the result in K(3 2 1),
 SBC K+1                ; which we do by calculating 0 - K(3 2 1), which we can
 STA K+1                ; do with 1 - C - K(3 2 1), as we know the C flag is
                        ; clear. We start with the low bytes

 LDA #0                 ; Then the middle bytes
 SBC K+2
 STA K+2

 LDA #0                 ; And finally the high bytes
 SBC K+3

 AND #%01111111         ; Set the sign bit of K+3 to the same sign as T,
 ORA T                  ; i.e. the same sign as the original K(3 2 1), as
 STA K+3                ; that's the largest argument

.MV14

 RTS                    ; Return from the subroutine

; ******************************************************************************
;
;       Name: MVS5
;       Type: Subroutine
;   Category: Moving
;    Summary: Apply a 3.6 degree pitch or roll to an orientation vector
;  Deep dive: Orientation vectors
;             Pitching and rolling by a fixed angle
;
; ------------------------------------------------------------------------------
;
; Pitch or roll a ship by a small, fixed amount (1/16 radians, or 3.6 degrees),
; in a specified direction, by rotating the orientation vectors. The vectors to
; rotate are given in X and Y, and the direction of the rotation is given in
; RAT2. The calculation is as follows:
;
;   * If the direction is positive:
;
;     X = X * (1 - 1/512) + Y / 16
;     Y = Y * (1 - 1/512) - X / 16
;
;   * If the direction is negative:
;
;     X = X * (1 - 1/512) - Y / 16
;     Y = Y * (1 - 1/512) + X / 16
;
; So if X = 15 (roofv_x), Y = 21 (sidev_x) and RAT2 is positive, it does this:
;
;   roofv_x = roofv_x * (1 - 1/512)  + sidev_x / 16
;   sidev_x = sidev_x * (1 - 1/512)  - roofv_x / 16
;
; Arguments:
;
;   X                   The first vector to rotate:
;
;                         * If X = 15, rotate roofv_x
;
;                         * If X = 17, rotate roofv_y
;
;                         * If X = 19, rotate roofv_z
;
;                         * If X = 21, rotate sidev_x
;
;                         * If X = 23, rotate sidev_y
;
;                         * If X = 25, rotate sidev_z
;
;   Y                   The second vector to rotate:
;
;                         * If Y = 9,  rotate nosev_x
;
;                         * If Y = 11, rotate nosev_y
;
;                         * If Y = 13, rotate nosev_z
;
;                         * If Y = 21, rotate sidev_x
;
;                         * If Y = 23, rotate sidev_y
;
;                         * If Y = 25, rotate sidev_z
;
;   RAT2                The direction of the pitch or roll to perform, positive
;                       or negative (i.e. the sign of the roll or pitch counter
;                       in bit 7)
;
; ******************************************************************************

.MVS5

 SETUP_PPU_FOR_ICON_BAR ; If the PPU has started drawing the icon bar, configure
                        ; the PPU to use nametable 0 and pattern table 0

 LDA INWK+1,X           ; Fetch roofv_x_hi, clear the sign bit, divide by 2 and
 AND #%01111111         ; store in T, so:
 LSR A                  ;
 STA T                  ; T = |roofv_x_hi| / 2
                        ;   = |roofv_x| / 512
                        ;
                        ; The above is true because:
                        ;
                        ; |roofv_x| = |roofv_x_hi| * 256 + roofv_x_lo
                        ;
                        ; so:
                        ;
                        ; |roofv_x| / 512 = |roofv_x_hi| * 256 / 512
                        ;                    + roofv_x_lo / 512
                        ;                  = |roofv_x_hi| / 2

 LDA INWK,X             ; Now we do the following subtraction:
 SEC                    ;
 SBC T                  ; (S R) = (roofv_x_hi roofv_x_lo) - |roofv_x| / 512
 STA R                  ;       = (1 - 1/512) * roofv_x
                        ;
                        ; by doing the low bytes first

 LDA INWK+1,X           ; And then the high bytes (the high byte of the right
 SBC #0                 ; side of the subtraction being 0)
 STA S

 LDA INWK,Y             ; Set P = nosev_x_lo
 STA P

 LDA INWK+1,Y           ; Fetch the sign of nosev_x_hi (bit 7) and store in T
 AND #%10000000
 STA T

 LDA INWK+1,Y           ; Fetch nosev_x_hi into A and clear the sign bit, so
 AND #%01111111         ; A = |nosev_x_hi|

 LSR A                  ; Set (A P) = (A P) / 16
 ROR P                  ;           = |nosev_x_hi nosev_x_lo| / 16
 LSR A                  ;           = |nosev_x| / 16
 ROR P
 LSR A
 ROR P
 LSR A
 ROR P

 ORA T                  ; Set the sign of A to the sign in T (i.e. the sign of
                        ; the original nosev_x), so now:
                        ;
                        ; (A P) = nosev_x / 16

 EOR RAT2               ; Give it the sign as if we multiplied by the direction
                        ; by the pitch or roll direction

 STX Q                  ; Store the value of X so it can be restored after the
                        ; call to ADD

 JSR ADD                ; (A X) = (A P) + (S R)
                        ;       = +/-nosev_x / 16 + (1 - 1/512) * roofv_x

 STA K+1                ; Set K(1 0) = (1 - 1/512) * roofv_x +/- nosev_x / 16
 STX K

 LDX Q                  ; Restore the value of X from before the call to ADD

 LDA INWK+1,Y           ; Fetch nosev_x_hi, clear the sign bit, divide by 2 and
 AND #%01111111         ; store in T, so:
 LSR A                  ;
 STA T                  ; T = |nosev_x_hi| / 2
                        ;   = |nosev_x| / 512

 LDA INWK,Y             ; Now we do the following subtraction:
 SEC                    ;
 SBC T                  ; (S R) = (nosev_x_hi nosev_x_lo) - |nosev_x| / 512
 STA R                  ;       = (1 - 1/512) * nosev_x
                        ;
                        ; by doing the low bytes first

 LDA INWK+1,Y           ; And then the high bytes (the high byte of the right
 SBC #0                 ; side of the subtraction being 0)
 STA S

 LDA INWK,X             ; Set P = roofv_x_lo
 STA P

 LDA INWK+1,X           ; Fetch the sign of roofv_x_hi (bit 7) and store in T
 AND #%10000000
 STA T

 LDA INWK+1,X           ; Fetch roofv_x_hi into A and clear the sign bit, so
 AND #%01111111         ; A = |roofv_x_hi|

 LSR A                  ; Set (A P) = (A P) / 16
 ROR P                  ;           = |roofv_x_hi roofv_x_lo| / 16
 LSR A                  ;           = |roofv_x| / 16
 ROR P
 LSR A
 ROR P
 LSR A
 ROR P

 ORA T                  ; Set the sign of A to the opposite sign to T (i.e. the
 EOR #%10000000         ; sign of the original -roofv_x), so now:
                        ;
                        ; (A P) = -roofv_x / 16

 EOR RAT2               ; Give it the sign as if we multiplied by the direction
                        ; by the pitch or roll direction

 STX Q                  ; Store the value of X so it can be restored after the
                        ; call to ADD

 JSR ADD                ; (A X) = (A P) + (S R)
                        ;       = -/+roofv_x / 16 + (1 - 1/512) * nosev_x

 STA INWK+1,Y           ; Set nosev_x = (1-1/512) * nosev_x -/+ roofv_x / 16
 STX INWK,Y

 LDX Q                  ; Restore the value of X from before the call to ADD

 LDA K                  ; Set roofv_x = K(1 0)
 STA INWK,X             ;              = (1-1/512) * roofv_x +/- nosev_x / 16
 LDA K+1
 STA INWK+1,X

 SETUP_PPU_FOR_ICON_BAR ; If the PPU has started drawing the icon bar, configure
                        ; the PPU to use nametable 0 and pattern table 0

 RTS                    ; Return from the subroutine

; ******************************************************************************
;
;       Name: TENS
;       Type: Variable
;   Category: Text
;    Summary: A constant used when printing large numbers in BPRNT
;  Deep dive: Printing decimal numbers
;
; ------------------------------------------------------------------------------
;
; Contains the four low bytes of the value 100,000,000,000 (100 billion).
;
; The maximum number of digits that we can print with the BPRNT routine is 11,
; so the biggest number we can print is 99,999,999,999. This maximum number
; plus 1 is 100,000,000,000, which in hexadecimal is:
;
;   & 17 48 76 E8 00
;
; The TENS variable contains the lowest four bytes in this number, with the
; most significant byte first, i.e. 48 76 E8 00. This value is used in the
; BPRNT routine when working out which decimal digits to print when printing a
; number.
;
; ******************************************************************************

.TENS

 EQUD &00E87648

; ******************************************************************************
;
;       Name: pr2
;       Type: Subroutine
;   Category: Text
;    Summary: Print an 8-bit number, left-padded to 3 digits, and optional point
;
; ------------------------------------------------------------------------------
;
; Print the 8-bit number in X to 3 digits, left-padding with spaces for numbers
; with fewer than 3 digits (so numbers < 100 are right-aligned). Optionally
; include a decimal point.
;
; Arguments:
;
;   X                   The number to print
;
;   C flag              If set, include a decimal point
;
; Other entry points:
;
;   pr2+2               Print the 8-bit number in X to the number of digits in A
;
; ******************************************************************************

.pr2

 LDA #3                 ; Set A to the number of digits (3)

 LDY #0                 ; Zero the Y register, so we can fall through into TT11
                        ; to print the 16-bit number (Y X) to 3 digits, which
                        ; effectively prints X to 3 digits as the high byte is
                        ; zero

; ******************************************************************************
;
;       Name: TT11
;       Type: Subroutine
;   Category: Text
;    Summary: Print a 16-bit number, left-padded to n digits, and optional point
;
; ------------------------------------------------------------------------------
;
; Print the 16-bit number in (Y X) to a specific number of digits, left-padding
; with spaces for numbers with fewer digits (so lower numbers will be right-
; aligned). Optionally include a decimal point.
;
; Arguments:
;
;   X                   The low byte of the number to print
;
;   Y                   The high byte of the number to print
;
;   A                   The number of digits
;
;   C flag              If set, include a decimal point
;
; ******************************************************************************

.TT11

 STA U                  ; We are going to use the BPRNT routine (below) to
                        ; print this number, so we store the number of digits
                        ; in U, as that's what BPRNT takes as an argument

 LDA #0                 ; BPRNT takes a 32-bit number in K to K+3, with the
 STA K                  ; most significant byte first (big-endian), so we set
 STA K+1                ; the two most significant bytes to zero (K and K+1)
 STY K+2                ; and store (Y X) in the least two significant bytes
 STX K+3                ; (K+2 and K+3), so we are going to print the 32-bit
                        ; number (0 0 Y X)

                        ; Finally we fall through into BPRNT to print out the
                        ; number in K to K+3, which now contains (Y X), to 3
                        ; digits (as U = 3), using the same C flag as when pr2
                        ; was called to control the decimal point

; ******************************************************************************
;
;       Name: BPRNT
;       Type: Subroutine
;   Category: Text
;    Summary: Print a 32-bit number, left-padded to a specific number of digits,
;             with an optional decimal point
;  Deep dive: Printing decimal numbers
;
; ------------------------------------------------------------------------------
;
; Print the 32-bit number stored in K(0 1 2 3) to a specific number of digits,
; left-padding with spaces for numbers with fewer digits (so lower numbers are
; right-aligned). Optionally include a decimal point.
;
; See the deep dive on "Printing decimal numbers" for details of the algorithm
; used in this routine.
;
; Arguments:
;
;   K(0 1 2 3)          The number to print, stored with the most significant
;                       byte in K and the least significant in K+3 (i.e. as a
;                       big-endian number, which is the opposite way to how the
;                       6502 assembler stores addresses, for example)
;
;   U                   The maximum number of digits to print, including the
;                       decimal point (spaces will be used on the left to pad
;                       out the result to this width, so the number is right-
;                       aligned to this width). U must be 11 or less
;
;   C flag              If set, include a decimal point followed by one
;                       fractional digit (i.e. show the number to 1 decimal
;                       place). In this case, the number in K(0 1 2 3) contains
;                       10 * the number we end up printing, so to print 123.4,
;                       we would pass 1234 in K(0 1 2 3) and would set the C
;                       flag to include the decimal point
;
; ******************************************************************************

.BPRNT

 LDX #11                ; Set T to the maximum number of digits allowed (11
 STX T                  ; characters, which is the number of digits in 10
                        ; billion). We will use this as a flag when printing
                        ; characters in TT37 below

 PHP                    ; Make a copy of the status register (in particular
                        ; the C flag) so we can retrieve it later

 BCC TT30               ; If the C flag is clear, we do not want to print a
                        ; decimal point, so skip the next two instructions

 DEC T                  ; As we are going to show a decimal point, decrement
 DEC U                  ; both the number of characters and the number of
                        ; digits (as one of them is now a decimal point)

.TT30

 LDA #11                ; Set A to 11, the maximum number of digits allowed

 SEC                    ; Set the C flag so we can do subtraction without the
                        ; C flag affecting the result

 STA XX17               ; Store the maximum number of digits allowed (11) in
                        ; XX17

 SBC U                  ; Set U = 11 - U + 1, so U now contains the maximum
 STA U                  ; number of digits minus the number of digits we want
 INC U                  ; to display, plus 1 (so this is the number of digits
                        ; we should skip before starting to print the number
                        ; itself, and the plus 1 is there to ensure we print at
                        ; least one digit)

 LDY #0                 ; In the main loop below, we use Y to count the number
                        ; of times we subtract 10 billion to get the leftmost
                        ; digit, so set this to zero

 STY S                  ; In the main loop below, we use location S as an
                        ; 8-bit overflow for the 32-bit calculations, so
                        ; we need to set this to 0 before joining the loop

 JMP TT36               ; Jump to TT36 to start the process of printing this
                        ; number's digits

.TT35

                        ; This subroutine multiplies K(S 0 1 2 3) by 10 and
                        ; stores the result back in K(S 0 1 2 3), using the fact
                        ; that K * 10 = (K * 2) + (K * 2 * 2 * 2)

 ASL K+3                ; Set K(S 0 1 2 3) = K(S 0 1 2 3) * 2 by rotating left
 ROL K+2
 ROL K+1
 ROL K
 ROL S

 LDX #3                 ; Now we want to make a copy of the newly doubled K in
                        ; XX15, so we can use it for the first (K * 2) in the
                        ; equation above, so set up a counter in X for copying
                        ; four bytes, starting with the last byte in memory
                        ; (i.e. the least significant)

.tt35

 LDA K,X                ; Copy the X-th byte of K(0 1 2 3) to the X-th byte of
 STA XX15,X             ; XX15(0 1 2 3), so that XX15 will contain a copy of
                        ; K(0 1 2 3) once we've copied all four bytes

 DEX                    ; Decrement the loop counter

 BPL tt35               ; Loop back to copy the next byte until we have copied
                        ; all four

 LDA S                  ; Store the value of location S, our overflow byte, in
 STA XX15+4             ; XX15+4, so now XX15(4 0 1 2 3) contains a copy of
                        ; K(S 0 1 2 3), which is the value of (K * 2) that we
                        ; want to use in our calculation

 ASL K+3                ; Now to calculate the (K * 2 * 2 * 2) part. We still
 ROL K+2                ; have (K * 2) in K(S 0 1 2 3), so we just need to shift
 ROL K+1                ; it twice. This is the first one, so we do this:
 ROL K                  ;
 ROL S                  ;   K(S 0 1 2 3) = K(S 0 1 2 3) * 2 = K * 4

 ASL K+3                ; And then we do it again, so that means:
 ROL K+2                ;
 ROL K+1                ;   K(S 0 1 2 3) = K(S 0 1 2 3) * 2 = K * 8
 ROL K
 ROL S

 CLC                    ; Clear the C flag so we can do addition without the
                        ; C flag affecting the result

 LDX #3                 ; By now we've got (K * 2) in XX15(4 0 1 2 3) and
                        ; (K * 8) in K(S 0 1 2 3), so the final step is to add
                        ; these two 32-bit numbers together to get K * 10.
                        ; So we set a counter in X for four bytes, starting
                        ; with the last byte in memory (i.e. the least
                        ; significant)

.tt36

 LDA K,X                ; Fetch the X-th byte of K into A

 ADC XX15,X             ; Add the X-th byte of XX15 to A, with carry

 STA K,X                ; Store the result in the X-th byte of K

 DEX                    ; Decrement the loop counter

 BPL tt36               ; Loop back to add the next byte, moving from the least
                        ; significant byte to the most significant, until we
                        ; have added all four

 LDA XX15+4             ; Finally, fetch the overflow byte from XX15(4 0 1 2 3)

 ADC S                  ; And add it to the overflow byte from K(S 0 1 2 3),
                        ; with carry

 STA S                  ; And store the result in the overflow byte from
                        ; K(S 0 1 2 3), so now we have our desired result, i.e.
                        ;
                        ;   K(S 0 1 2 3) = K(S 0 1 2 3) * 10

 LDY #0                 ; In the main loop below, we use Y to count the number
                        ; of times we subtract 10 billion to get the leftmost
                        ; digit, so set this to zero so we can rejoin the main
                        ; loop for another subtraction process

.TT36

                        ; This is the main loop of our digit-printing routine.
                        ; In the following loop, we are going to count the
                        ; number of times that we can subtract 10 million and
                        ; store that count in Y, which we have already set to 0

 LDX #3                 ; Our first calculation concerns 32-bit numbers, so
                        ; set up a counter for a four-byte loop

 SEC                    ; Set the C flag so we can do subtraction without the
                        ; C flag affecting the result

.tt37

 PHP                    ; Store the flags on the stack to we can retrieve them
                        ; after the macro

 SETUP_PPU_FOR_ICON_BAR ; If the PPU has started drawing the icon bar, configure
                        ; the PPU to use nametable 0 and pattern table 0

 PLP                    ; Retrieve the flags from the stack

                        ; We now loop through each byte in turn to do this:
                        ;
                        ;   XX15(4 0 1 2 3) = K(S 0 1 2 3) - 100,000,000,000

 LDA K,X                ; Subtract the X-th byte of TENS (i.e. 10 billion) from
 SBC TENS,X             ; the X-th byte of K

 STA XX15,X             ; Store the result in the X-th byte of XX15

 DEX                    ; Decrement the loop counter

 BPL tt37               ; Loop back to subtract the next byte, moving from the
                        ; least significant byte to the most significant, until
                        ; we have subtracted all four

 LDA S                  ; Subtract the fifth byte of 10 billion (i.e. $17) from
 SBC #$17               ; the fifth (overflow) byte of K, which is S

 STA XX15+4             ; Store the result in the overflow byte of XX15

 BCC TT37               ; If subtracting 10 billion took us below zero, jump to
                        ; TT37 to print out this digit, which is now in Y

 LDX #3                 ; We now want to copy XX15(4 0 1 2 3) back into
                        ; K(S 0 1 2 3), so we can loop back up to do the next
                        ; subtraction, so set up a counter for a four-byte loop

.tt38

 LDA XX15,X             ; Copy the X-th byte of XX15(0 1 2 3) to the X-th byte
 STA K,X                ; of K(0 1 2 3), so that K(0 1 2 3) will contain a copy
                        ; of XX15(0 1 2 3) once we've copied all four bytes

 DEX                    ; Decrement the loop counter

 BPL tt38               ; Loop back to copy the next byte, until we have copied
                        ; all four

 LDA XX15+4             ; Store the value of location XX15+4, our overflow
 STA S                  ; byte in S, so now K(S 0 1 2 3) contains a copy of
                        ; XX15(4 0 1 2 3)

 INY                    ; We have now managed to subtract 10 billion from our
                        ; number, so increment Y, which is where we are keeping
                        ; a count of the number of subtractions so far

 JMP TT36               ; Jump back to TT36 to subtract the next 10 billion

.TT37

 TYA                    ; If we get here then Y contains the digit that we want
                        ; to print (as Y has now counted the total number of
                        ; subtractions of 10 billion), so transfer Y into A

 BNE TT32               ; If the digit is non-zero, jump to TT32 to print it

 LDA T                  ; Otherwise the digit is zero. If we are already
                        ; printing the number then we will want to print a 0,
                        ; but if we haven't started printing the number yet,
                        ; then we probably don't, as we don't want to print
                        ; leading zeroes unless this is the only digit before
                        ; the decimal point
                        ;
                        ; To help with this, we are going to use T as a flag
                        ; that tells us whether we have already started
                        ; printing digits:
                        ;
                        ;   * If T <> 0 we haven't printed anything yet
                        ;
                        ;   * If T = 0 then we have started printing digits
                        ;
                        ; We initially set T above to the maximum number of
                        ; characters allowed, less 1 if we are printing a
                        ; decimal point, so the first time we enter the digit
                        ; printing routine at TT37, it is definitely non-zero

 BEQ TT32               ; If T = 0, jump straight to the print routine at TT32,
                        ; as we have already started printing the number, so we
                        ; definitely want to print this digit too

 DEC U                  ; We initially set U to the number of digits we want to
 BPL TT34               ; skip before starting to print the number. If we get
                        ; here then we haven't printed any digits yet, so
                        ; decrement U to see if we have reached the point where
                        ; we should start printing the number, and if not, jump
                        ; to TT34 to set up things for the next digit

 LDA #' '               ; We haven't started printing any digits yet, but we
 BNE tt34               ; have reached the point where we should start printing
                        ; our number, so call TT26 (via tt34) to print a space
                        ; so that the number is left-padded with spaces (this
                        ; BNE is effectively a JMP as A will never be zero)

.TT32

 LDY #0                 ; We are printing an actual digit, so first set T to 0,
 STY T                  ; to denote that we have now started printing digits as
                        ; opposed to spaces

 CLC                    ; The digit value is in A, so add ASCII "0" to get the
 ADC #'0'               ; ASCII character number to print

.tt34

 JSR DASC_b2            ; Call DASC to print the character in A and fall through
                        ; into TT34 to get things ready for the next digit

.TT34

 DEC T                  ; Decrement T but keep T >= 0 (by incrementing it
 BPL P%+4               ; again if the above decrement made T negative)
 INC T

 DEC XX17               ; Decrement the total number of characters left to
                        ; print, which we stored in XX17

 BMI rT10               ; If the result is negative, we have printed all the
                        ; characters, so jump down to rT10 to return from the
                        ; subroutine

 BNE P%+11              ; If the result is positive (> 0) then we still have
                        ; characters left to print, so loop back to TT35 (via
                        ; the JMP TT35 instruction below) to print the next
                        ; digit

 PLP                    ; If we get here then we have printed the exact number
                        ; of digits that we wanted to, so restore the C flag
                        ; that we stored at the start of the routine

 BCC P%+8               ; If the C flag is clear, we don't want a decimal point,
                        ; so loop back to TT35 (via the JMP TT35 instruction
                        ; below) to print the next digit

 LDA L03FD              ; Otherwise the C flag is set, so print the decimal
 JSR DASC_b2            ; point ???

 JMP TT35               ; Loop back to TT35 to print the next digit

.rT10

 RTS                    ; Return from the subroutine

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
;   Category: Flight
;    Summary: Launch our escape pod
;
; ------------------------------------------------------------------------------
;
; This routine displays our doomed Cobra Mk III disappearing off into the ether
; before arranging our replacement ship. Called when we press ESCAPE during
; flight and have an escape pod fitted.
;
; ******************************************************************************

.ESCAPE

 JSR RES2               ; Reset a number of flight variables and workspaces

 LDY #$13               ; ???
 JSR NOISE
 LDA #0
 STA ESCP
 JSR subm_AC5C_b3
 LDA QQ11
 BNE C8BFF

 LDX #CYL               ; Set the current ship type to a Cobra Mk III, so we
 STX TYPE               ; can show our ship disappear into the distance when we
                        ; eject in our pod

 JSR FRS1               ; Call FRS1 to launch the Cobra Mk III straight ahead,
                        ; like a missile launch, but with our ship instead

 BCS ES1                ; If the Cobra was successfully added to the local
                        ; bubble, jump to ES1 to skip the following instructions

 LDX #CYL2              ; The Cobra wasn't added to the local bubble for some
 JSR FRS1               ; reason, so try launching a pirate Cobra Mk III instead

.ES1

 LDA #8                 ; Set the Cobra's byte #27 (speed) to 8
 STA INWK+27

 LDA #194               ; Set the Cobra's byte #30 (pitch counter) to 194, so it
 STA INWK+30            ; pitches as we pull away

 LDA #%00101100         ; Set the Cobra's byte #32 (AI flag) to %00101100, so it
 STA INWK+32            ; has no AI, and we can use this value as a counter to
                        ; do the following loop 44 times

.ESL1

 JSR MVEIT              ; Call MVEIT to move the Cobra in space

 JSR subm_D96F          ; ???

 DEC INWK+32            ; Decrement the counter in byte #32

 BNE ESL1               ; Loop back to keep moving the Cobra until the AI flag
                        ; is 0, which gives it time to drift away from our pod

.C8BFF

 LDA #0                 ; Set A = 0 so we can use it to zero the contents of
                        ; the cargo hold

 LDX #16                ; We lose all our cargo when using our escape pod, so
                        ; up a counter in X so we can zero the 17 cargo slots
                        ; in QQ20

.ESL2

 STA QQ20,X             ; Set the X-th byte of QQ20 to zero, so we no longer
                        ; have any of item type X in the cargo hold

 DEX                    ; Decrement the counter

 BPL ESL2               ; Loop back to ESL2 until we have emptied the entire
                        ; cargo hold

 STA FIST               ; Launching an escape pod also clears our criminal
                        ; record, so set our legal status in FIST to 0 ("clean")

 LDA TRIBBLE            ; ???
 ORA TRIBBLE+1
 BEQ nosurviv
 JSR DORND
 AND #7
 ORA #1
 STA TRIBBLE
 LDA #0
 STA TRIBBLE+1

.nosurviv

 LDA #70                ; Our replacement ship is delivered with a full tank of
 STA QQ14               ; fuel, so set the current fuel level in QQ14 to 70, or
                        ; 7.0 light years

 JMP GOIN               ; Go to the docking bay (i.e. show the ship hangar
                        ; screen) and return from the subroutine with a tail
                        ; call

; ******************************************************************************
;
;       Name: HME2
;       Type: Subroutine
;   Category: Charts
;    Summary: Search the galaxy for a system
;
; ******************************************************************************

.HME2

 JSR CLYNS              ; ???

 LDA #14                ; Print extended token 14 ("{clear bottom of screen}
 JSR DETOK_b2           ; PLANET NAME?{fetch line input from keyboard}"). The
                        ; last token calls MT26, which puts the entered search
                        ; term in INWK+5 and the term length in Y

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

 JSR TT81               ; Set the seeds in QQ15 (the selected system) to those
                        ; of system 0 in the current galaxy (i.e. copy the seeds
                        ; from QQ21 to QQ15)

 LDA #0                 ; We now loop through the galaxy's systems in order,
 STA XX20               ; until we find a match, so set XX20 to act as a system
                        ; counter, starting with system 0

.HME3

 SETUP_PPU_FOR_ICON_BAR ; If the PPU has started drawing the icon bar, configure
                        ; the PPU to use nametable 0 and pattern table 0

 LDA #$80               ; ???
 STA DTW4
 ASL A
 STA DTW5

 JSR cpl                ; Print the selected system name into the justified text
                        ; buffer

 LDX DTW5               ; Fetch DTW5 into X, so X is now equal to the length of
                        ; the selected system name

 LDA INWK+5,X           ; Fetch the X-th character from the entered search term

 CMP #13                ; If the X-th character is not a carriage return, then
 BNE HME6               ; the selected system name and the entered search term
                        ; are different lengths, so jump to HME6 to move on to
                        ; the next system

.HME4

 DEX                    ; Decrement X so it points to the last letter of the
                        ; selected system name (and, when we loop back here, it
                        ; points to the next letter to the left)

 LDA INWK+5,X           ; Set A to the X-th character of the entered search term

 ORA #%00100000         ; Set bit 5 of the character to make it lower case

 CMP BUF,X              ; If the character in A matches the X-th character of
 BEQ HME4               ; the selected system name in BUF, loop back to HME4 to
                        ; check the next letter to the left

 TXA                    ; The last comparison didn't match, so copy the letter
 BMI HME5               ; number into A, and if it's negative, that means we
                        ; managed to go past the first letters of each term
                        ; before we failed to get a match, so the terms are the
                        ; same, so jump to HME5 to process a successful search

.HME6

                        ; If we get here then the selected system name and the
                        ; entered search term did not match

 JSR subm_B831          ; ???

 JSR TT20               ; We want to move on to the next system, so call TT20
                        ; to twist the three 16-bit seeds in QQ15

 INC XX20               ; Incrememt the system counter in XX20

 BNE HME3               ; If we haven't yet checked all 256 systems in the
                        ; current galaxy, loop back to HME3 to check the next
                        ; system

                        ; If we get here then the entered search term did not
                        ; match any systems in the current galaxy

 JSR TT111              ; Select the system closest to galactic coordinates
                        ; (QQ9, QQ10), so we can put the crosshairs back where
                        ; they were before the search

 JSR BOOP               ; Call the BOOP routine to make a low, long beep to
                        ; indicate a failed search

 LDA #215               ; Print extended token 215 ("{left align} UNKNOWN
 JSR DETOK_b2           ; PLANET"), which will print on-screen as the left align
                        ; code disables justified text

 JMP subm_8980          ; ???

.HME5

                        ; If we get here then we have found a match for the
                        ; entered search

 JSR subm_B831          ; ???
 JSR CLYNS
 LDA #0
 STA DTW8

 LDA QQ15+3             ; The x-coordinate of the system described by the seeds
 STA QQ9                ; in QQ15 is in QQ15+3 (s1_hi), so we copy this to QQ9
                        ; as the x-coordinate of the search result

 LDA QQ15+1             ; The y-coordinate of the system described by the seeds
 STA QQ10               ; in QQ15 is in QQ15+1 (s0_hi), so we copy this to QQ10
                        ; as the y-coordinate of the search result

 JMP CB181              ; ???

.C8CAF

 JSR CLYNS
 JMP subm_8980

; ******************************************************************************
;
;       Name: TACTICS (Part 1 of 7)
;       Type: Subroutine
;   Category: Tactics
;    Summary: Apply tactics: Process missiles, both enemy missiles and our own
;  Deep dive: Program flow of the tactics routine
;
; ------------------------------------------------------------------------------
;
; This section implements missile tactics and is entered at TA18 from the main
; entry point below, if the current ship is a missile. Specifically:
;
;   * If E.C.M. is active, destroy the missile
;
;   * If the missile is hostile towards us, then check how close it is. If it
;     hasn't reached us, jump to part 3 so it can streak towards us, otherwise
;     we've been hit, so process a large amount of damage to our ship
;
;   * Otherwise see how close the missile is to its target. If it has not yet
;     reached its target, give the target a chance to activate its E.C.M. if it
;     has one, otherwise jump to TA19 with K3 set to the vector from the target
;     to the missile
;
;   * If it has reached its target and the target is the space station, destroy
;     the missile, potentially damaging us if we are nearby
;
;   * If it has reached its target and the target is a ship, destroy the missile
;     and the ship, potentially damaging us if we are nearby
;
; ******************************************************************************

.TA352

                        ; If we get here, the missile has been destroyed by
                        ; E.C.M. or by the space station

 LDA INWK               ; Set A = x_lo OR y_lo OR z_lo of the missile
 ORA INWK+3
 ORA INWK+6

 BNE TA872              ; If A is non-zero then the missile is not near our
                        ; ship, so skip the next two instructions to avoid
                        ; damaging our ship

 LDA #80                ; Otherwise the missile just got destroyed near us, so
 JSR OOPS               ; call OOPS to damage the ship by 80, which is nowhere
                        ; near as bad as the 250 damage from a missile slamming
                        ; straight into us, but it's still pretty nasty

.TA872

 LDX #PLT               ; Set X to the ship type for plate alloys, so we get
                        ; awarded the kill points for the missile scraps in TA87

 BNE TA353              ; Jump to TA353 to process the missile kill tally and
                        ; make an explosion sound

.TA34

                        ; If we get here, the missile is hostile

 LDA #0                 ; Set A to x_hi OR y_hi OR z_hi
 JSR MAS4

 BEQ P%+5               ; If A = 0 then the missile is very close to our ship,
                        ; so skip the following instruction

 JMP TN4                ; Jump down to part 3 to set up the vectors and skip
                        ; straight to aggressive manoeuvring

 JSR TA873              ; The missile has hit our ship, so call TA873 to set
                        ; bit 7 of the missile's byte #31, which marks the
                        ; missile as being killed

 JSR EXNO3              ; Make the sound of the missile exploding

 LDA #250               ; Call OOPS to damage the ship by 250, which is a pretty
 JMP OOPS               ; big hit, and return from the subroutine using a tail
                        ; call

.TA18

                        ; This is the entry point for missile tactics and is
                        ; called from the main TACTICS routine below

 LDA ECMA               ; If an E.C.M. is currently active (either our's or an
 BNE TA352              ; opponent's), jump to TA352 to destroy this missile

 LDA INWK+32            ; Fetch the AI flag from byte #32 and if bit 6 is set
 ASL A                  ; (i.e. missile is hostile), jump up to TA34 to check
 BMI TA34               ; whether the missile has hit us

 LSR A                  ; Otherwise shift A right again. We know bits 6 and 7
                        ; are now clear, so this leaves bits 0-5. Bits 1-5
                        ; contain the target's slot number, and bit 0 is cleared
                        ; in FRMIS when a missile is launched, so A contains
                        ; the slot number shifted left by 1 (i.e. doubled) so we
                        ; can use it as an index for the two-byte address table
                        ; at UNIV

 TAX                    ; Copy the address of the target ship's data block from
 LDA UNIV,X             ; UNIV(X+1 X) to (A V)
 STA V
 LDA UNIV+1,X

 JSR VCSUB              ; Calculate vector K3 as follows:
                        ;
                        ; K3(2 1 0) = (x_sign x_hi x_lo) - x-coordinate of
                        ; target ship
                        ;
                        ; K3(5 4 3) = (y_sign y_hi z_lo) - y-coordinate of
                        ; target ship
                        ;
                        ; K3(8 7 6) = (z_sign z_hi z_lo) - z-coordinate of
                        ; target ship

                        ; So K3 now contains the vector from the target ship to
                        ; the missile

 LDA K3+2               ; Set A = OR of all the sign and high bytes of the
 ORA K3+5               ; above, clearing bit 7 (i.e. ignore the signs)
 ORA K3+8
 AND #%01111111
 ORA K3+1
 ORA K3+4
 ORA K3+7

 BNE TA64               ; If the result is non-zero, then the missile is some
                        ; distance from the target, so jump down to TA64 see if
                        ; the target activates its E.C.M.

 LDA INWK+32            ; Fetch the AI flag from byte #32 and if only bits 7 and
 CMP #%10000010         ; 1 are set (AI is enabled and the target is slot 1, the
 BEQ TA352              ; space station), jump to TA352 to destroy this missile,
                        ; as the space station ain't kidding around

 LDY #31                ; Fetch byte #31 (the exploding flag) of the target ship
 LDA (V),Y              ; into A

 BIT M32+1              ; M32 contains an LDY #32 instruction, so M32+1 contains
                        ; 32, so this instruction tests A with %00100000, which
                        ; checks bit 5 of A (the "already exploding?" bit)

 BNE TA35               ; If the target ship is already exploding, jump to TA35
                        ; to destroy this missile

 ORA #%10000000         ; Otherwise set bit 7 of the target's byte #31 to mark
 STA (V),Y              ; the ship as having been killed, so it explodes

.TA35

 LDA INWK               ; Set A = x_lo OR y_lo OR z_lo of the missile
 ORA INWK+3
 ORA INWK+6

 BNE P%+7               ; If A is non-zero then the missile is not near our
                        ; ship, so skip the next two instructions to avoid
                        ; damaging our ship

 LDA #80                ; Otherwise the missile just got destroyed near us, so
 JSR OOPS               ; call OOPS to damage the ship by 80, which is nowhere
                        ; near as bad as the 250 damage from a missile slamming
                        ; straight into us, but it's still pretty nasty

.TA87

 LDA INWK+32            ; Set X to bits 1-6 of the missile's AI flag in ship
 AND #%01111111         ; byte #32, so bits 0-3 of X are the target's slot
 LSR A                  ; number, and bit 4 is set (as the missile is hostile)
 TAX                    ; so X is fairly random and in the range 16-31. This is
                        ; used to determine the number of kill points awarded
                        ; for the destruction of the missile

 LDA FRIN,X             ; ???
 TAX

.TA353

 JSR EXNO2              ; Call EXNO2 to process the fact that we have killed a
                        ; missile (so increase the kill tally, make an explosion
                        ; sound and so on)

.TA873

 ASL INWK+31            ; Set bit 7 of the missile's byte #31 flag to mark it as
 SEC                    ; having been killed, so it explodes
 ROR INWK+31

.TA1

 RTS                    ; Return from the subroutine

.TA64

                        ; If we get here then the missile has not reached the
                        ; target

 JSR DORND              ; Set A and X to random numbers

 CMP #16                ; If A >= 16 (94% chance), jump down to TA19S with the
 BCS TA19S              ; vector from the target to the missile in K3

.M32

 LDY #32                ; Fetch byte #32 for the target and shift bit 0 (E.C.M.)
 LDA (V),Y              ; into the C flag
 LSR A

 BCS P%+5               ; If the C flag is set then the target has E.C.M.
                        ; fitted, so skip the next instruction

.TA19S

 JMP TA19               ; The target does not have E.C.M. fitted, so jump down
                        ; to TA19 with the vector from the target to the missile
                        ; in K3

 JMP ECBLB2             ; The target has E.C.M., so jump to ECBLB2 to set it
                        ; off, returning from the subroutine using a tail call

; ******************************************************************************
;
;       Name: TACTICS (Part 2 of 7)
;       Type: Subroutine
;   Category: Tactics
;    Summary: Apply tactics: Escape pod, station, lone Thargon, safe-zone pirate
;  Deep dive: Program flow of the tactics routine
;
; ------------------------------------------------------------------------------
;
; This section contains the main entry point at TACTICS, which is called from
; part 2 of MVEIT for ships that have the AI flag set (i.e. bit 7 of byte #32).
; This part does the following:
;
;   * If this is a missile, jump up to the missile code in part 1
;
;   * If this is the space station and it is hostile, consider spawning a cop
;     (6.2% chance, up to a maximum of seven) and we're done
;
;   * If this is the space station and it is not hostile, consider spawning
;     (0.8% chance if there are no Transporters around) a Transporter or Shuttle
;     (equal odds of each type) and we're done
;
;   * If this is a rock hermit, consider spawning (22% chance) a highly
;     aggressive and hostile Sidewinder, Mamba, Krait, Adder or Gecko (equal
;     odds of each type) and we're done
;
;   * Recharge the ship's energy banks by 1
;
; Arguments:
;
;   X                   The ship type
;
; ******************************************************************************

.TACTICS

 LDA #3                 ; Set RAT = 3, which is the magnitude we set the pitch
 STA RAT                ; or roll counter to in part 7 when turning a ship
                        ; towards a vector (a higher value giving a longer
                        ; turn). This value is not changed in the TACTICS
                        ; routine, but it is set to different values by the
                        ; DOCKIT routine

 STA L05F2              ; ???

 LDA #4                 ; Set RAT2 = 4, which is the threshold below which we
 STA RAT2               ; don't apply pitch and roll to the ship (so a lower
                        ; value means we apply pitch and roll more often, and a
                        ; value of 0 means we always apply them). The value is
                        ; compared with double the high byte of sidev . XX15,
                        ; where XX15 is the vector from the ship to the enemy
                        ; or planet. This value is set to different values by
                        ; both the TACTICS and DOCKIT routines

 LDA #22                ; Set CNT2 = 22, which is the maximum angle beyond which
 STA CNT2               ; a ship will slow down to start turning towards its
                        ; prey (a lower value means a ship will start to slow
                        ; down even if its angle with the enemy ship is large,
                        ; which gives a tighter turn). This value is not changed
                        ; in the TACTICS routine, but it is set to different
                        ; values by the DOCKIT routine

 CPX #MSL               ; If this is a missile, jump up to TA18 to implement
 BEQ TA18               ; missile tactics

 CPX #SST               ; If this is not the space station, jump down to TA13
 BNE TA13

 LDA NEWB               ; This is the space station, so check whether bit 2 of
 AND #%00000100         ; the ship's NEWB flags is set, and if it is (i.e. the
 BNE TN5                ; station is hostile), jump to TN5 to spawn some cops

 LDA MANY+SHU+1         ; Set A to the number of Transporters in the vicinity

 ORA auto               ; If the docking computer is on then auto is $FF, so
                        ; this ensures that A is always non-zero when we are
                        ; auto-docking, so the following jump to TA1 will be
                        ; taken and no Transporters will be spawned from the
                        ; space station (unlike in the disc version, where you
                        ; can get smashed into space dust by a badly timed
                        ; Transporter launch when using the docking computer)

 BNE TA1                ; The station is not hostile, so check how many
                        ; Transporters there are in the vicinity, and if we
                        ; already have one, return from the subroutine (as TA1
                        ; contains an RTS)

                        ; If we get here then the station is not hostile, so we
                        ; can consider spawning a Transporter or Shuttle

 JSR DORND              ; Set A and X to random numbers

 CMP #253               ; If A < 253 (99.2% chance), return from the subroutine
 BCC TA1                ; (as TA1 contains an RTS)

 AND #1                 ; Set A = a random number that's either 0 or 1

 ADC #SHU-1             ; The C flag is set (as we didn't take the BCC above),
 TAX                    ; so this sets X to a value of either #SHU or #SHU + 1,
                        ; which is the ship type for a Shuttle or a Transporter

 BNE TN6                ; Jump to TN6 to spawn this ship type and return from
                        ; the subroutine using a tail call (this BNE is
                        ; effectively a JMP as A is never zero)

.TN5

                        ; We only call the tactics routine for the space station
                        ; when it is hostile, so if we get here then this is the
                        ; station, and we already know it's hostile, so we need
                        ; to spawn some cops

 JSR DORND              ; Set A and X to random numbers

 CMP #240               ; If A < 240 (93.8% chance), return from the subroutine
 BCC TA1                ; (as TA1 contains an RTS)

 LDA MANY+COPS          ; Check how many cops there are in the vicinity already,
 CMP #4                 ; and if there are 4 or more, return from the subroutine
 BCS TA22               ; (as TA22 contains an RTS)

 LDX #COPS              ; Set X to the ship type for a cop

.TN6

 LDA #%11110001         ; Set the AI flag to give the ship E.C.M., enable AI and
                        ; make it very aggressive (60 out of 63)

 JMP SFS1               ; Jump to SFS1 to spawn the ship, returning from the
                        ; subroutine using a tail call

.TA13

 CPX #HER               ; If this is not a rock hermit, jump down to TA17
 BNE TA17

 JSR DORND              ; Set A and X to random numbers

 CMP #200               ; If A < 200 (78% chance), return from the subroutine
 BCC TA22               ; (as TA22 contains an RTS)

 LDX #0                 ; Set byte #32 to %00000000 to disable AI, aggression
 STX INWK+32            ; and E.C.M.

 LDX #%00100100         ; Set the ship's NEWB flags to %00100100 so the ship we
 STX NEWB               ; spawn below will inherit the default values from E% as
                        ; well as having bit 2 (hostile) and bit 5 (innocent
                        ; bystander) set

 AND #3                 ; Set A = a random number that's in the range 0-3

 ADC #SH3               ; The C flag is set (as we didn't take the BCC above),
 TAX                    ; so this sets X to a random value between #SH3 + 1 and
                        ; #SH3 + 4, so that's a Sidewinder, Mamba, Krait, Adder
                        ; or Gecko

 JSR TN6                ; Call TN6 to spawn this ship with E.C.M., AI and a high
                        ; aggression (56 out of 63)

 LDA #0                 ; Set byte #32 to %00000000 to disable AI, aggression
 STA INWK+32            ; and E.C.M. (for the rock hermit)

 RTS                    ; Return from the subroutine

.TA17

 LDY #14                ; If the ship's energy is greater or equal to the
 JSR GetShipBlueprint   ; maximum value from the ship's blueprint pointed to by
 CMP INWK+35            ; XX0, then skip the next instruction
 BCC TA21
 BEQ TA21

 INC INWK+35            ; The ship's energy is not at maximum, so recharge the
                        ; energy banks by 1

; ******************************************************************************
;
;       Name: TACTICS (Part 3 of 7)
;       Type: Subroutine
;   Category: Tactics
;    Summary: Apply tactics: Calculate dot product to determine ship's aim
;  Deep dive: Program flow of the tactics routine
;
; ------------------------------------------------------------------------------
;
; This section sets up some vectors and calculates dot products. Specifically:
;
;   * If this is a lone Thargon without a mothership, set it adrift aimlessly
;     and we're done
;
;   * If this is a trader, 80% of the time we're done, 20% of the time the
;     trader performs the same checks as the bounty hunter
;
;   * If this is a bounty hunter (or one of the 20% of traders) and we have been
;     really bad (i.e. a fugitive or serious offender), the ship becomes hostile
;     (if it isn't already)
;
;   * If the ship is not hostile, then either perform docking manouevres (if
;     it's docking) or fly towards the planet (if it isn't docking) and we're
;     done
;
;   * If the ship is hostile, and a pirate, and we are within the space station
;     safe zone, stop the pirate from attacking by removing all its aggression
;
;   * Calculate the dot product of the ship's nose vector (i.e. the direction it
;     is pointing) with the vector between us and the ship. This value will help
;     us work out later on whether the enemy ship is pointing towards us, and
;     therefore whether it can hit us with its lasers.
;
; Other entry points:
;
;   GOPL                Make the ship head towards the planet
;
; ******************************************************************************

.TA21

 CPX #TGL               ; If this is not a Thargon, jump down to TA14
 BNE TA14

 LDA MANY+THG           ; If there is at least one Thargoid in the vicinity,
 BNE TA14               ; jump down to TA14

 LSR INWK+32            ; This is a Thargon but there is no Thargoid mothership,
 ASL INWK+32            ; so clear bit 0 of the AI flag to disable its E.C.M.

 LSR INWK+27            ; And halve the Thargon's speed

.TA22

 RTS                    ; Return from the subroutine

.TA14

 JSR DORND              ; Set A and X to random numbers

 LDA NEWB               ; Extract bit 0 of the ship's NEWB flags into the C flag
 LSR A                  ; and jump to TN1 if it is clear (i.e. if this is not a
 BCC TN1                ; trader)

 CPX #50                ; This is a trader, so if X >= 50 (80% chance), return
 BCS TA22               ; from the subroutine (as TA22 contains an RTS)

.TN1

 LSR A                  ; Extract bit 1 of the ship's NEWB flags into the C flag
 BCC TN2                ; and jump to TN2 if it is clear (i.e. if this is not a
                        ; bounty hunter)

 LDX FIST               ; This is a bounty hunter, so check whether our FIST
 CPX #40                ; rating is < 40 (where 50 is a fugitive), and jump to
 BCC TN2                ; TN2 if we are not 100% evil

 LDA NEWB               ; We are a fugitive or a bad offender, and this ship is
 ORA #%00000100         ; a bounty hunter, so set bit 2 of the ship's NEWB flags
 STA NEWB               ; to make it hostile

 LSR A                  ; Shift A right twice so the next test in TN2 will check
 LSR A                  ; bit 2

.TN2

 LSR A                  ; Extract bit 2 of the ship's NEWB flags into the C flag
 BCS TN3                ; and jump to TN3 if it is set (i.e. if this ship is
                        ; hostile)

 LSR A                  ; The ship is not hostile, so extract bit 4 of the
 LSR A                  ; ship's NEWB flags into the C flag, and jump to GOPL if
 BCC GOPL               ; it is clear (i.e. if this ship is not docking)

 JMP DOCKIT             ; The ship is not hostile and is docking, so jump to
                        ; DOCKIT to apply the docking algorithm to this ship

.GOPL

 JSR SPS1               ; The ship is not hostile and it is not docking, so call
                        ; SPS1 to calculate the vector to the planet and store
                        ; it in XX15

 JMP TA151              ; Jump to TA151 to make the ship head towards the planet

.TN3

 LSR A                  ; Extract bit 2 of the ship's NEWB flags into the C flag
 BCC TN4                ; and jump to TN4 if it is clear (i.e. if this ship is
                        ; not a pirate)

 LDA SSPR               ; If we are not inside the space station safe zone, jump
 BEQ TN4                ; to TN4

                        ; If we get here then this is a pirate and we are inside
                        ; the space station safe zone

 LDA INWK+32            ; Set bits 0 and 7 of the AI flag in byte #32 (has AI
 AND #%10000001         ; enabled and has an E.C.M.)
 STA INWK+32

.TN4

 LDX #8                 ; We now want to copy the ship's x, y and z coordinates
                        ; from INWK to K3, so set up a counter for 9 bytes

.TAL1

 LDA INWK,X             ; Copy the X-th byte from INWK to the X-th byte of K3
 STA K3,X

 DEX                    ; Decrement the counter

 BPL TAL1               ; Loop back until we have copied all 9 bytes

.TA19

                        ; If this is a missile that's heading for its target
                        ; (not us, one of the other ships), then the missile
                        ; routine at TA18 above jumps here after setting K3 to
                        ; the vector from the target to the missile

 JSR TAS2               ; Normalise the vector in K3 and store the normalised
                        ; version in XX15, so XX15 contains the normalised
                        ; vector from our ship to the ship we are applying AI
                        ; tactics to (or the normalised vector from the target
                        ; to the missile - in both cases it's the vector from
                        ; the potential victim to the attacker)

 LDY #10                ; Set (A X) = nosev . XX15
 JSR TAS3

 STA CNT                ; Store the high byte of the dot product in CNT. The
                        ; bigger the value, the more aligned the two ships are,
                        ; with a maximum magnitude of 36 (96 * 96 >> 8). If CNT
                        ; is positive, the ships are facing in a similar
                        ; direction, if it's negative they are facing in
                        ; opposite directions

; ******************************************************************************
;
;       Name: TACTICS (Part 4 of 7)
;       Type: Subroutine
;   Category: Tactics
;    Summary: Apply tactics: Check energy levels, maybe launch escape pod if low
;  Deep dive: Program flow of the tactics routine
;
; ------------------------------------------------------------------------------
;
; This section works out what kind of condition the ship is in. Specifically:
;
;   * If this is an Anaconda, consider spawning (22% chance) a Worm (61% of the
;     time) or a Sidewinder (39% of the time)
;
;   * Rarely (2.5% chance) roll the ship by a noticeable amount
;
;   * If the ship has at least half its energy banks full, jump to part 6 to
;     consider firing the lasers
;
;   * If the ship is not into the last 1/8th of its energy, jump to part 5 to
;     consider firing a missile
;
;   * If the ship is into the last 1/8th of its energy, and this ship type has
;     an escape pod fitted, then rarely (10% chance) the ship launches an escape
;     pod and is left drifting in space
;
; ******************************************************************************

 SETUP_PPU_FOR_ICON_BAR ; If the PPU has started drawing the icon bar, configure
                        ; the PPU to use nametable 0 and pattern table 0

 LDA TYPE               ; If this is not a missile, skip the following
 CMP #MSL               ; instruction
 BNE P%+5

 JMP TA20               ; This is a missile, so jump down to TA20 to get
                        ; straight into some aggressive manoeuvring

 CMP #ANA               ; If this is not an Anaconda, jump down to TN7 to skip
 BNE TN7                ; the following

 JSR DORND              ; Set A and X to random numbers

 CMP #200               ; If A < 200 (78% chance), jump down to TN7 to skip the
 BCC TN7                ; following

 JSR DORND              ; Set A and X to random numbers

 LDX #WRM               ; Set X to the ship type for a Worm

 CMP #100               ; If A >= 100 (61% chance), skip the following
 BCS P%+4               ; instruction

 LDX #SH3               ; Set X to the ship type for a Sidewinder

 JMP TN6                ; Jump to TN6 to spawn the Worm or Sidewinder and return
                        ; from the subroutine using a tail call

.TN7

 JSR DORND              ; Set A and X to random numbers

 CMP #250               ; If A < 250 (97.5% chance), jump down to TA7 to skip
 BCC TA7                ; the following

 JSR DORND              ; Set A and X to random numbers

 ORA #104               ; Bump A up to at least 104 and store in the roll
 STA INWK+29            ; counter, to gives the ship a noticeable roll

.TA7

 LDY #14                ; Set A = the ship's maximum energy / 2
 JSR GetShipBlueprint
 LSR A

 CMP INWK+35            ; If the ship's current energy in byte #35 > A, i.e. the
 BCC TA3                ; ship has at least half of its energy banks charged,
                        ; jump down to TA3

 LSR A                  ; If the ship's current energy in byte #35 > A / 4, i.e.
 LSR A                  ; the ship is not into the last 1/8th of its energy,
 CMP INWK+35            ; jump down to ta3 to consider firing a missile
 BCC ta3

 JSR DORND              ; Set A and X to random numbers

 CMP #230               ; If A < 230 (90% chance), jump down to ta3 to consider
 BCC ta3                ; firing a missile

 LDX TYPE               ; Fetch the ship blueprint's default NEWB flags from the
 LDY TYPE               ; table at E%, and if bit 7 is clear (i.e. this ship
 JSR GetDefaultNEWB     ; does not have an escape pod), jump to ta3 to skip the
 BPL ta3                ; spawning of an escape pod

                        ; By this point, the ship has run out of both energy and
                        ; luck, so it's time to bail

 LDA NEWB               ; Clear bits 0-3 of the NEWB flags, so the ship is no
 AND #%11110000         ; longer a trader, a bounty hunter, hostile or a pirate
 STA NEWB               ; and the escape pod we are about to spawn won't inherit
                        ; any of these traits

 LDY #36                ; Update the NEWB flags in the ship's data block
 STA (INF),Y

 LDA #0                 ; Set the AI flag to 0 to disable AI, hostility and
 STA INWK+32            ; E.C.M., so the ship's a sitting duck

 JMP SESCP              ; Jump to SESCP to spawn an escape pod from the ship,
                        ; returning from the subroutine using a tail call

; ******************************************************************************
;
;       Name: TACTICS (Part 5 of 7)
;       Type: Subroutine
;   Category: Tactics
;    Summary: Apply tactics: Consider whether to launch a missile at us
;  Deep dive: Program flow of the tactics routine
;
; ------------------------------------------------------------------------------
;
; This section considers whether to launch a missile. Specifically:
;
;   * If the ship doesn't have any missiles, skip to the next part
;
;   * If an E.C.M. is firing, skip to the next part
;
;   * Randomly decide whether to fire a missile (or, in the case of Thargoids,
;     release a Thargon), and if we do, we're done
;
; ******************************************************************************

.ta3

                        ; If we get here then the ship has less than half energy
                        ; so there may not be enough juice for lasers, but let's
                        ; see if we can fire a missile

 LDA INWK+31            ; Set A = bits 0-2 of byte #31, the number of missiles
 AND #%00000111         ; the ship has left

 BEQ TA3                ; If it doesn't have any missiles, jump to TA3

 STA T                  ; Store the number of missiles in T

 JSR DORND              ; Set A and X to random numbers

 AND #31                ; Restrict A to a random number in the range 0-31

 CMP T                  ; If A >= T, which is quite likely, though less likely
 BCS TA3                ; with higher numbers of missiles, jump to TA3 to skip
                        ; firing a missile

 LDA ECMA               ; If an E.C.M. is currently active (either our's or an
 BNE TA3                ; opponent's), jump to TA3 to skip firing a missile

 DEC INWK+31            ; We're done with the checks, so it's time to fire off a
                        ; missile, so reduce the missile count in byte #31 by 1

 LDA TYPE               ; Fetch the ship type into A

 CMP #THG               ; If this is not a Thargoid, jump down to TA16 to launch
 BNE TA16               ; a missile

 LDX #TGL               ; This is a Thargoid, so instead of launching a missile,
 LDA INWK+32            ; the mothership launches a Thargon, so call SFS1 to
 JMP SFS1               ; spawn a Thargon from the parent ship, and return from
                        ; the subroutine using a tail call

.TA16

 JMP SFRMIS             ; Jump to SFRMIS to spawn a missile as a child of the
                        ; current ship, make a noise and print a message warning
                        ; of incoming missiles, and return from the subroutine
                        ; using a tail call

; ******************************************************************************
;
;       Name: TACTICS (Part 6 of 7)
;       Type: Subroutine
;   Category: Tactics
;    Summary: Apply tactics: Consider firing a laser at us, if aim is true
;  Deep dive: Program flow of the tactics routine
;
; ------------------------------------------------------------------------------
;
; This section looks at potentially firing the ship's laser at us. Specifically:
;
;   * If the ship is not pointing at us, skip to the next part
;
;   * If the ship is pointing at us but not accurately, fire its laser at us and
;     skip to the next part
;
;   * If we are in the ship's crosshairs, register some damage to our ship, slow
;     down the attacking ship, make the noise of us being hit by laser fire, and
;     we're done
;
; ******************************************************************************

.TA3

 SETUP_PPU_FOR_ICON_BAR ; If the PPU has started drawing the icon bar, configure
                        ; the PPU to use nametable 0 and pattern table 0

                        ; If we get here then the ship either has plenty of
                        ; energy, or levels are low but it couldn't manage to
                        ; launch a missile, so maybe we can fire the laser?

 LDA #0                 ; Set A to x_hi OR y_hi OR z_hi
 JSR MAS4

 AND #%11100000         ; If any of the hi bytes have any of bits 5-7 set, then
 BNE TA4                ; jump to TA4 to skip the laser checks, as the ship is
                        ; too far away from us to hit us with a laser

 LDX CNT                ; Set X = the dot product set above in CNT. If this is
                        ; positive, this ship and our ship are facing in similar
                        ; directions, but if it's negative then we are facing
                        ; each other, so for us to be in the enemy ship's line
                        ; of fire, X needs to be negative. The value in X can
                        ; have a maximum magnitude of 36, which would mean we
                        ; were facing each other square on, so in the following
                        ; code we check X like this:
                        ;
                        ;   X = 0 to -31, we are not in the enemy ship's line
                        ;       of fire, so they can't shoot at us
                        ;
                        ;   X = -32 to -34, we are in the enemy ship's line
                        ;       of fire, so they can shoot at us, but they can't
                        ;       hit us as we're not dead in their crosshairs
                        ;
                        ;   X = -35 to -36, we are bang in the middle of the
                        ;       enemy ship's crosshairs, so they can not only
                        ;       shoot us, they can hit us

 CPX #158               ; If X < 158, i.e. X > -30, then we are not in the enemy
 BCC TA4                ; ship's line of fire, so jump to TA4 to skip the laser
                        ; checks

 LDY #19                ; Fetch the enemy ship's byte #19 from their ship's
 JSR GetShipBlueprint   ; blueprint into A

 AND #%11111000         ; Extract bits 3-7, which contain the enemy's laser
                        ; power

 BEQ TA4                ; If the enemy has no laser power, jump to TA4 to skip
                        ; the laser checks

 CPX #$A1               ; ???
 BCC C8EE4

 LDA INWK+31            ; Set bit 6 in byte #31 to denote that the ship is
 ORA #%01000000         ; firing its laser at us
 STA INWK+31

 CPX #163               ; If X >= 163, i.e. X <= -35, then we are in the enemy
 BCS C8EF3              ; ship's crosshairs, so ???

.C8EE4

 JSR TAS6               ; ???
 LDA CNT
 EOR #$80
 STA CNT
 JSR TA15
 JMP C8EFF

.C8EF3

 JSR GetShipBlueprint   ; Fetch the enemy ship's byte #19 from their ship's
                        ; blueprint into A

 LSR A                  ; Halve the enemy ship's byte #19 (which contains both
                        ; the laser power and number of missiles) to get the
                        ; amount of damage we should take

 JSR OOPS               ; Call OOPS to take some damage, which could do anything
                        ; from reducing the shields and energy, all the way to
                        ; losing cargo or dying (if the latter, we don't come
                        ; back from this subroutine)

 LDY #$0B               ; ???
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
;       Name: TACTICS (Part 7 of 7)
;       Type: Subroutine
;   Category: Tactics
;    Summary: Apply tactics: Set pitch, roll, and acceleration
;  Deep dive: Program flow of the tactics routine
;
; ------------------------------------------------------------------------------
;
; This section looks at manoeuvring the ship. Specifically:
;
;   * Work out which direction the ship should be moving, depending on the type
;     of ship, where it is, which direction it is pointing, and how aggressive
;     it is
;
;   * Set the pitch and roll counters to head in that direction
;
;   * Speed up or slow down, depending on where the ship is in relation to us
;
; Other entry points:
;
;   TA151               Make the ship head towards the planet
;
; ******************************************************************************

.TA4

 LDA INWK+7             ; If z_hi >= 3 then the ship is quite far away, so jump
 CMP #3                 ; down to TA5
 BCS TA5

 LDA INWK+1             ; Otherwise set A = x_hi OR y_hi and extract bits 1-7
 ORA INWK+4
 AND #%11111110

 BEQ C8F47              ; If A = 0 then the ship is pretty close to us, so jump
                        ; to C8F47 so it heads away from us ???

.TA5

                        ; If we get here then the ship is quite far away

 JSR DORND              ; Set A and X to random numbers

 ORA #%10000000         ; Set bit 7 of A

 CMP INWK+32            ; If A >= byte #32 (the ship's AI flag) then jump down
 BCS C8F47              ; to C8F47 so it heads away from us ???

                        ; We get here if A < byte #32, and the chances of this
                        ; being true are greater with high values of byte #32.
                        ; In other words, higher byte #32 values increase the
                        ; chances of a ship changing direction to head towards
                        ; us - or, to put it another way, ships with higher
                        ; byte #32 values are spoiling for a fight. Thargoids
                        ; have byte #32 set to 255, which explains an awful lot

 STA L05F2              ; ???

.TA20

                        ; If this is a missile we will have jumped straight
                        ; here, but we also get here if the ship is either far
                        ; away and aggressive, or not too close

 JSR TAS6               ; Call TAS6 to negate the vector in XX15 so it points in
                        ; the opposite direction

 LDA CNT                ; Change the sign of the dot product in CNT, so now it's
 EOR #%10000000         ; positive if the ships are facing each other, and
                        ; negative if they are facing the same way

.TA152

 STA CNT                ; Update CNT with the new value in A

.C8F47

 JSR TA15               ; ???
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
 BCC TA10

.C8F83

 LDA #$FF
 LDX TYPE
 CPX #1
 BNE C8F8C
 ASL A

.C8F8C

 STA INWK+28

.TA10

 RTS

.TA151

 LDY #$0A
 JSR TAS3
 CMP #$98
 BCC C8F9C
 LDX #0
 STX RAT2

.C8F9C

 JMP TA152

.TA15

                        ; If we get here, then one of the following is true:
                        ;
                        ;   * This is a trader and XX15 is pointing towards the
                        ;     planet
                        ;
                        ;   * The ship is pretty close to us, or it's just not
                        ;     very aggressive (though there is a random factor
                        ;     at play here too). XX15 is still pointing from our
                        ;     ship towards the enemy ship
                        ;
                        ;   * The ship is aggressive (though again, there's an
                        ;     element of randomness here). XX15 is pointing from
                        ;     the enemy ship towards our ship
                        ;
                        ;   * This is a missile heading for a target. XX15 is
                        ;     pointing from the missile towards the target
                        ;
                        ; We now want to move the ship in the direction of XX15,
                        ; which will make aggressive ships head towards us, and
                        ; ships that are too close turn away. Peaceful traders,
                        ; meanwhile, head off towards the planet in search of a
                        ; space station, and missiles home in on their targets

 LDY #16                ; Set (A X) = roofv . XX15
 JSR TAS3               ;
                        ; This will be positive if XX15 is pointing in the same
                        ; direction as an arrow out of the top of the ship, in
                        ; other words if the ship should pull up to head in the
                        ; direction of XX15

 TAX                    ; Copy A into X so we can retrieve it below

 EOR #%10000000         ; Give the ship's pitch counter the opposite sign to the
 AND #%10000000         ; dot product result, with a value of 0
 STA INWK+30

 SETUP_PPU_FOR_ICON_BAR ; If the PPU has started drawing the icon bar, configure
                        ; the PPU to use nametable 0 and pattern table 0

 LDA CNT                ; ???
 BPL C8FCA
 CMP #$9F
 BCC C8FCA
 LDA #7
 ORA INWK+30
 STA INWK+30
 LDA #0
 BEQ C8FF5

.C8FCA

 TXA                    ; Retrieve the original value of A from X

 ASL A                  ; Shift A left to double it and drop the sign bit

 CMP RAT2               ; If A < RAT2, skip to TA11 (so if RAT2 = 0, we always
 BCC TA11               ; set the pitch counter to RAT)

 LDA RAT                ; Set the magnitude of the ship's pitch counter to RAT
 ORA INWK+30            ; (we already set the sign above)
 STA INWK+30

.TA11

 LDA INWK+29            ; Fetch the roll counter from byte #29 into A

 ASL A                  ; Shift A left to double it and drop the sign bit

 CMP #32                ; If A >= 32 then jump to TA6, as the ship is already
 BCS TA6                ; in the process of rolling

 LDY #22                ; Set (A X) = sidev . XX15
 JSR TAS3               ;
                        ; This will be positive if XX15 is pointing in the same
                        ; direction as an arrow out of the right side of the
                        ; ship, in other words if the ship should roll right to
                        ; head in the direction of XX15

 TAX                    ; Copy A into X so we can retrieve it below

 EOR INWK+30            ; Give the ship's roll counter a positive sign if the
 AND #%10000000         ; pitch counter and dot product have different signs,
 EOR #%10000000         ; negative if they have the same sign, with a value of 0
 STA INWK+29

 TXA                    ; Retrieve the original value of A from X

 ASL A                  ; Shift A left to double it and drop the sign bit

 CMP RAT2               ; If A < RAT2, skip to TA6 (so if RAT2 = 0, we always
 BCC TA6                ; set the roll counter to RAT)

 LDA RAT                ; Set the magnitude of the ship's roll counter to RAT
 ORA INWK+29            ; (we already set the sign above)

.C8FF5

 STA INWK+29            ; Store the magnitude of the ship's roll counter

.TA6

 RTS                    ; Return from the subroutine

; ******************************************************************************
;
;       Name: DOCKIT
;       Type: Subroutine
;   Category: Flight
;    Summary: Apply docking manoeuvres to the ship in INWK
;  Deep dive: The docking computer
;
; ******************************************************************************

.DOCKIT

 LDA #6                 ; Set RAT2 = 6, which is the threshold below which we
 STA RAT2               ; don't apply pitch and roll to the ship (so a lower
                        ; value means we apply pitch and roll more often, and a
                        ; value of 0 means we always apply them). The value is
                        ; compared with double the high byte of sidev . XX15,
                        ; where XX15 is the vector from the ship to the station

 LSR A                  ; Set RAT = 2, which is the magnitude we set the pitch
 STA RAT                ; or roll counter to in part 7 when turning a ship
                        ; towards a vector (a higher value giving a longer
                        ; turn)

 LDA #29                ; Set CNT2 = 29, which is the maximum angle beyond which
 STA CNT2               ; a ship will slow down to start turning towards its
                        ; prey (a lower value means a ship will start to slow
                        ; down even if its angle with the enemy ship is large,
                        ; which gives a tighter turn)

 LDA SSPR               ; If we are inside the space station safe zone, skip the
 BNE P%+5               ; next instruction

.GOPLS

 JMP GOPL               ; Jump to GOPL to make the ship head towards the planet

 JSR VCSU1              ; If we get here then we are in the space station safe
                        ; zone, so call VCSU1 to calculate the following, where
                        ; the station is at coordinates (station_x, station_y,
                        ; station_z):
                        ;
                        ;   K3(2 1 0) = (x_sign x_hi x_lo) - station_x
                        ;
                        ;   K3(5 4 3) = (y_sign y_hi z_lo) - station_y
                        ;
                        ;   K3(8 7 6) = (z_sign z_hi z_lo) - station_z
                        ;
                        ; so K3 contains the vector from the station to the ship

 LDA K3+2               ; If any of the top bytes of the K3 results above are
 ORA K3+5               ; non-zero (after removing the sign bits), jump to GOPL
 ORA K3+8               ; via GOPLS to make the ship head towards the planet, as
 AND #%01111111         ; this will aim the ship in the general direction of the
 BNE GOPLS              ; station (it's too far away for anything more accurate)

 JSR TA2                ; Call TA2 to calculate the length of the vector in K3
                        ; (ignoring the low coordinates), returning it in Q

 LDA Q                  ; Store the value of Q in K, so K now contains the
 STA K                  ; distance between station and the ship

 JSR TAS2               ; Call TAS2 to normalise the vector in K3, returning the
                        ; normalised version in XX15, so XX15 contains the unit
                        ; vector pointing from the station to the ship

 LDY #10                ; Call TAS4 to calculate:
 JSR TAS4               ;
                        ;   (A X) = nosev . XX15
                        ;
                        ; where nosev is the nose vector of the space station,
                        ; so this is the dot product of the station to ship
                        ; vector with the station's nosev (which points straight
                        ; out into space, out of the docking slot), and because
                        ; both vectors are unit vectors, the following is also
                        ; true:
                        ;
                        ;   (A X) = cos(t)
                        ;
                        ; where t is the angle between the two vectors
                        ;
                        ; If the dot product is positive, that means the vector
                        ; from the station to the ship and the nosev sticking
                        ; out of the docking slot are facing in a broadly
                        ; similar direction (so the ship is essentially heading
                        ; for the slot, which is facing towards the ship), and
                        ; if it's negative they are facing in broadly opposite
                        ; directions (so the station slot is on the opposite
                        ; side of the station as the ship approaches)

 BMI PH1                ; If the dot product is negative, i.e. the station slot
                        ; is on the opposite side, jump to PH1 to fly towards
                        ; the ideal docking position, some way in front of the
                        ; slot

 CMP #35                ; If the dot product < 35, jump to PH1 to fly towards
 BCC PH1                ; the ideal docking position, some way in front of the
                        ; slot, as there is a large angle between the vector
                        ; from the station to the ship and the station's nosev,
                        ; so the angle of approach is not very optimal
                        ;
                        ; Specifically, as the unit vector length is 96 in our
                        ; vector system,
                        ;
                        ;   (A X) = cos(t) < 35 / 96
                        ;
                        ; so:
                        ;
                        ;   t > arccos(35 / 96) = 68.6 degrees
                        ;
                        ; so the ship is coming in from the side of the station
                        ; at an angle between 68.6 and 90 degrees off the
                        ; optimal entry angle

                        ; If we get here, the slot is on the same side as the
                        ; ship and the angle of approach is less than 68.6
                        ; degrees, so we're heading in pretty much the correct
                        ; direction for a good approach to the docking slot

 LDY #10                ; Call TAS3 to calculate:
 JSR TAS3               ;
                        ;   (A X) = nosev . XX15
                        ;
                        ; where nosev is the nose vector of the ship, so this is
                        ; the dot product of the station to ship vector with the
                        ; ship's nosev, and is a measure of how close to the
                        ; station the ship is pointing, with negative meaning it
                        ; is pointing at the station, and positive meaning it is
                        ; pointing away from the station

 CMP #$A2               ; If the dot product is in the range 0 to -34, jump to
 BCS PH3                ; PH3 to refine our approach, as we are pointing towards
                        ; the station

                        ; If we get here, then we are not pointing straight at
                        ; the station, so check how close we are

 LDA K                  ; Fetch the distance to the station into A

 CMP #157               ; If A < 157, jump to PH2 to turn away from the station,
 BCC PH2                ; as we are too close

 LDA TYPE               ; Fetch the ship type into A

 BMI PH3                ; If bit 7 is set, then that means the ship type was set
                        ; to -96 in the DOKEY routine when we switched on our
                        ; docking compter, so this is us auto-docking our Cobra,
                        ; so jump to PH3 to refine our approach. Otherwise this
                        ; is an NPC trying to dock, so turn away from the
                        ; station

.PH2

                        ; If we get here then we turn away from the station and
                        ; slow right down, effectively aborting this approach
                        ; attempt

 JSR TAS6               ; Call TAS6 to negate the vector in XX15 so it points in
                        ; the opposite direction, away from from the station and
                        ; towards the ship

 JSR TA151              ; Call TA151 to make the ship head in the direction of
                        ; XX15, which makes the ship turn away from the station

.PH22

                        ; If we get here then we slam on the brakes and slow
                        ; right down

 LDX #0                 ; Set the acceleration in byte #28 to 0
 STX INWK+28

 INX                    ; Set the speed in byte #28 to 1
 STX INWK+27

 RTS                    ; Return from the subroutine

.PH1

                        ; If we get here then the slot is on the opposite side
                        ; of the station to the ship, or it's on the same side
                        ; and the approach angle is not optimal, so we just fly
                        ; towards the station, aiming for the ideal docking
                        ; position some distance in front of the slot

 JSR VCSU1              ; Call VCSU1 to set K3 to the vector from the station to
                        ; the ship

 JSR DCS1               ; Call DCS1 twice to calculate the vector from the ideal
 JSR DCS1               ; docking position to the ship, where the ideal docking
                        ; position is straight out of the docking slot at a
                        ; distance of 8 unit vectors from the centre of the
                        ; station

 JSR TAS2               ; Call TAS2 to normalise the vector in K3, returning the
                        ; normalised version in XX15

 JSR TAS6               ; Call TAS6 to negate the vector in XX15 so it points in
                        ; the opposite direction

 JMP TA151              ; Call TA151 to make the ship head in the direction of
                        ; XX15, which makes the ship turn towards the ideal
                        ; docking position, and return from the subroutine using
                        ; a tail call

.TN11

                        ; If we get here, we accelerate and apply a full
                        ; clockwise roll (which matches the space station's
                        ; roll)

 INC INWK+28            ; Increment the acceleration in byte #28

 LDA #%01111111         ; Set the roll counter to a positive roll with no
 STA INWK+29            ; damping, to match the space station's roll

 BNE TN13               ; Jump down to TN13 (this BNE is effectively a JMP as
                        ; A will never be zero)

.PH3

 SETUP_PPU_FOR_ICON_BAR ; If the PPU has started drawing the icon bar, configure
                        ; the PPU to use nametable 0 and pattern table 0

                        ; If we get here, we refine our approach using pitch and
                        ; roll to aim for the station

 LDX #0                 ; Set RAT2 = 0
 STX RAT2

 STX INWK+30            ; Set the pitch counter to 0 to stop any pitching

 LDA TYPE               ; If this is not our ship's docking computer, but is an
 BPL PH32               ; NPC ship trying to dock, jump to PH32

                        ; In the following, ship_x and ship_y are the x and
                        ; y-coordinates of XX15, the vector from the station to
                        ; the ship

 EOR XX15               ; A is negative, so this sets the sign of A to the same
 EOR XX15+1             ; as -XX15 * XX15+1, or -ship_x * ship_y

 ASL A                  ; Shift the sign bit into the C flag, so the C flag has
                        ; the following sign:
                        ;
                        ;   * Positive if ship_x and ship_y have different signs
                        ;   * Negative if ship_x and ship_y have the same sign

 LDA #2                 ; Set A = +2 or -2, giving it the sign in the C flag,
 ROR A                  ; and store it in byte #29, the roll counter, so that
 STA INWK+29            ; the ship rolls towards the station

 LDA XX15               ; If |ship_x * 2| >= 12, i.e. |ship_x| >= 6, then jump
 ASL A                  ; to PH22 to slow right down and return from the
 CMP #12                ; subroutine, as the station is not in our sights
 BCS PH22

 LDA XX15+1             ; Set A = +2 or -2, giving it the same sign as ship_y,
 ASL A                  ; and store it in byte #30, the pitch counter, so that
 LDA #2                 ; the ship pitches towards the station
 ROR A
 STA INWK+30

 LDA XX15+1             ; If |ship_y * 2| >= 12, i.e. |ship_y| >= 6, then jump
 ASL A                  ; to PH22 to slow right down and return from the
 CMP #12                ; subroutine, as the station is not in our sights
 BCS PH22

.PH32

                        ; If we get here, we try to match the station roll

 STX INWK+29            ; Set the roll counter to 0 to stop any pitching

 LDA INWK+22            ; Set XX15 = sidev_x_hi
 STA XX15

 LDA INWK+24            ; Set XX15+1 = sidev_y_hi
 STA XX15+1

 LDA INWK+26            ; Set XX15+2 = sidev_z_hi
 STA XX15+2             ;
                        ; so XX15 contains the sidev vector of the ship

 LDY #16                ; Call TAS4 to calculate:
 JSR TAS4               ;
                        ;   (A X) = roofv . XX15
                        ;
                        ; where roofv is the roof vector of the space station.
                        ; To dock with the slot horizontal, we want roofv to be
                        ; pointing off to the side, i.e. parallel to the ship's
                        ; sidev vector, which means we want the dot product to
                        ; be large (it can be positive or negative, as roofv can
                        ; point left or right - it just needs to be parallel to
                        ; the ship's sidev)

 ASL A                  ; If |A * 2| >= 66, i.e. |A| >= 33, then the ship is
 CMP #66                ; lined up with the slot, so jump to TN11 to accelerate
 BCS TN11               ; and roll clockwise (a positive roll) before jumping
                        ; down to TN13 to check if we're docked yet

 JSR PH22               ; Call PH22 to slow right down, as we haven't yet
                        ; matched the station's roll

.TN13

                        ; If we get here, we check to see if we have docked

 LDA K3+10              ; If K3+10 is non-zero, skip to TNRTS, to return from
 BNE TNRTS              ; the subroutine
                        ;
                        ; I have to say I have no idea what K3+10 contains, as
                        ; it isn't mentioned anywhere in the whole codebase
                        ; apart from here, but it does share a location with
                        ; XX2+10, so it will sometimes be non-zero (specifically
                        ; when face #10 in the ship we're drawing is visible,
                        ; which probably happens quite a lot). This would seem
                        ; to affect whether an NPC ship can dock, as that's the
                        ; code that gets skipped if K3+10 is non-zero, but as
                        ; to what this means... that's not yet clear

 ASL NEWB               ; Set bit 7 of the ship's NEWB flags to indicate that
 SEC                    ; the ship has now docked, which only has meaning if
 ROR NEWB               ; this is an NPC trying to dock

.TNRTS

 RTS                    ; Return from the subroutine

; ******************************************************************************
;
;       Name: VCSU1
;       Type: Subroutine
;   Category: Maths (Arithmetic)
;    Summary: Calculate vector K3(8 0) = [x y z] - coordinates of the sun or
;             space station
;
; ------------------------------------------------------------------------------
;
; Calculate the following:
;
;   K3(2 1 0) = (x_sign x_hi x_lo) - x-coordinate of the sun or space station
;
;   K3(5 4 3) = (y_sign y_hi z_lo) - y-coordinate of the sun or space station
;
;   K3(8 7 6) = (z_sign z_hi z_lo) - z-coordinate of the sun or space station
;
; where the first coordinate is from the ship data block in INWK, and the second
; coordinate is from the sun or space station's ship data block which they
; share.
;
; ******************************************************************************

.VCSU1

 LDA #LO(K%+NIK%)       ; Set the low byte of V(1 0) to point to the coordinates
 STA V                  ; of the sun or space station

 LDA #HI(K%+NIK%)       ; Set A to the high byte of the address of the
                        ; coordinates of the sun or space station

                        ; Fall through into VCSUB to calculate:
                        ;
                        ;   K3(2 1 0) = (x_sign x_hi x_lo) - x-coordinate of sun
                        ;               or space station
                        ;
                        ;   K3(2 1 0) = (x_sign x_hi x_lo) - x-coordinate of sun
                        ;               or space station
                        ;
                        ;   K3(8 7 6) = (z_sign z_hi z_lo) - z-coordinate of sun
                        ;               or space station

; ******************************************************************************
;
;       Name: VCSUB
;       Type: Subroutine
;   Category: Maths (Arithmetic)
;    Summary: Calculate vector K3(8 0) = [x y z] - coordinates in (A V)
;
; ------------------------------------------------------------------------------
;
; Calculate the following:
;
;   K3(2 1 0) = (x_sign x_hi x_lo) - x-coordinate in (A V)
;
;   K3(5 4 3) = (y_sign y_hi z_lo) - y-coordinate in (A V)
;
;   K3(8 7 6) = (z_sign z_hi z_lo) - z-coordinate in (A V)
;
; where the first coordinate is from the ship data block in INWK, and the second
; coordinate is from the ship data block pointed to by (A V).
;
; ******************************************************************************

.VCSUB

 STA V+1                ; Set the low byte of V(1 0) to A, so now V(1 0) = (A V)

 LDY #2                 ; K3(2 1 0) = (x_sign x_hi x_lo) - x-coordinate in data
 JSR TAS1               ; block at V(1 0)

 LDY #5                 ; K3(5 4 3) = (y_sign y_hi z_lo) - y-coordinate of data
 JSR TAS1               ; block at V(1 0)

 LDY #8                 ; Fall through into TAS1 to calculate the final result:
                        ;
                        ; K3(8 7 6) = (z_sign z_hi z_lo) - z-coordinate of data
                        ; block at V(1 0)

; ******************************************************************************
;
;       Name: TAS1
;       Type: Subroutine
;   Category: Maths (Arithmetic)
;    Summary: Calculate K3 = (x_sign x_hi x_lo) - V(1 0)
;
; ------------------------------------------------------------------------------
;
; Calculate one of the following, depending on the value in Y:
;
;   K3(2 1 0) = (x_sign x_hi x_lo) - x-coordinate in V(1 0)
;
;   K3(5 4 3) = (y_sign y_hi z_lo) - y-coordinate in V(1 0)
;
;   K3(8 7 6) = (z_sign z_hi z_lo) - z-coordinate in V(1 0)
;
; where the first coordinate is from the ship data block in INWK, and the second
; coordinate is from the ship data block pointed to by V(1 0).
;
; Arguments:
;
;   V(1 0)              The address of the ship data block to subtract
;
;   Y                   The coordinate in the V(1 0) block to subtract:
;
;                         * If Y = 2, subtract the x-coordinate and store the
;                           result in K3(2 1 0)
;
;                         * If Y = 5, subtract the y-coordinate and store the
;                           result in K3(5 4 3)
;
;                         * If Y = 8, subtract the z-coordinate and store the
;                           result in K3(8 7 6)
;
; ******************************************************************************

.TAS1

 SETUP_PPU_FOR_ICON_BAR ; If the PPU has started drawing the icon bar, configure
                        ; the PPU to use nametable 0 and pattern table 0

 LDA (V),Y              ; Copy the sign byte of the V(1 0) coordinate into K+3,
 EOR #%10000000         ; flipping it in the process
 STA K+3

 DEY                    ; Copy the high byte of the V(1 0) coordinate into K+2
 LDA (V),Y
 STA K+2

 DEY                    ; Copy the high byte of the V(1 0) coordinate into K+1,
 LDA (V),Y              ; so now:
 STA K+1                ;
                        ;   K(3 2 1) = - coordinate in V(1 0)

 STY U                  ; Copy the index (now 0, 3 or 6) into U and X
 LDX U

 JSR MVT3               ; Call MVT3 to add the same coordinates, but this time
                        ; from INWK, so this would look like this for the
                        ; x-axis:
                        ;
                        ;   K(3 2 1) = (x_sign x_hi x_lo) + K(3 2 1)
                        ;            = (x_sign x_hi x_lo) - coordinate in V(1 0)

 LDY U                  ; Restore the index into Y, though this instruction has
                        ; no effect, as Y is not used again, either here or
                        ; following calls to this routine

 STA K3+2,X             ; Store K(3 2 1) in K3+X(2 1 0), starting with the sign
                        ; byte

 LDA K+2                ; And then doing the high byte
 STA K3+1,X

 LDA K+1                ; And finally the low byte
 STA K3,X

 RTS                    ; Return from the subroutine

; ******************************************************************************
;
;       Name: TAS4
;       Type: Subroutine
;   Category: Maths (Geometry)
;    Summary: Calculate the dot product of XX15 and one of the space station's
;             orientation vectors
;
; ------------------------------------------------------------------------------
;
; Calculate the dot product of the vector in XX15 and one of the space station's
; orientation vectors, as determined by the value of Y. If vect is the space
; station orientation vector, we calculate this:
;
;   (A X) = vect . XX15
;         = vect_x * XX15 + vect_y * XX15+1 + vect_z * XX15+2
;
; Technically speaking, this routine can also calculate the dot product between
; XX15 and the sun's orientation vectors, as the sun and space station share the
; same ship data slot (the second ship data block at K%). However, the sun
; doesn't have orientation vectors, so this only gets called when that slot is
; being used for the space station.
;
; Arguments:
;
;   Y                   The space station's orientation vector:
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

.TAS4

 LDX K%+NIK%,Y          ; Set Q = the Y-th byte of K%+NIK%, i.e. vect_x from the
 STX Q                  ; second ship data block at K%

 LDA XX15               ; Set A = XX15

 JSR MULT12             ; Set (S R) = Q * A
                        ;           = vect_x * XX15

 LDX K%+NIK%+2,Y        ; Set Q = the Y+2-th byte of K%+NIK%, i.e. vect_y
 STX Q

 LDA XX15+1             ; Set A = XX15+1

 JSR MAD                ; Set (A X) = Q * A + (S R)
                        ;           = vect_y * XX15+1 + vect_x * XX15

 STA S                  ; Set (S R) = (A X)
 STX R

 LDX K%+NIK%+4,Y        ; Set Q = the Y+2-th byte of K%+NIK%, i.e. vect_z
 STX Q

 LDA XX15+2             ; Set A = XX15+2

 JMP MAD                ; Set:
                        ;
                        ;   (A X) = Q * A + (S R)
                        ;           = vect_z * XX15+2 + vect_y * XX15+1 +
                        ;             vect_x * XX15
                        ;
                        ; and return from the subroutine using a tail call

; ******************************************************************************
;
;       Name: TAS6
;       Type: Subroutine
;   Category: Maths (Geometry)
;    Summary: Negate the vector in XX15 so it points in the opposite direction
;
; ******************************************************************************

.TAS6

 LDA XX15               ; Reverse the sign of the x-coordinate of the vector in
 EOR #%10000000         ; XX15
 STA XX15

 LDA XX15+1             ; Then reverse the sign of the y-coordinate
 EOR #%10000000
 STA XX15+1

 LDA XX15+2             ; And then the z-coordinate, so now the XX15 vector is
 EOR #%10000000         ; pointing in the opposite direction
 STA XX15+2

 RTS                    ; Return from the subroutine

; ******************************************************************************
;
;       Name: DCS1
;       Type: Subroutine
;   Category: Flight
;    Summary: Calculate the vector from the ideal docking position to the ship
;
; ------------------------------------------------------------------------------
;
; This routine is called by the docking computer routine in DOCKIT. It works out
; the vector between the ship and the ideal docking position, which is straight
; in front of the docking slot, but some distance away.
;
; Specifically, it calculates the following:
;
;   * K3(2 1 0) = K3(2 1 0) - nosev_x_hi * 4
;
;   * K3(5 4 3) = K3(5 4 3) - nosev_y_hi * 4
;
;   * K3(8 7 6) = K3(8 7 6) - nosev_x_hi * 4
;
; where K3 is the vector from the station to the ship, and nosev is the nose
; vector for the space station.
;
; The nose vector points from the centre of the station through the slot, so
; -nosev * 4 is the vector from a point in front of the docking slot, but some
; way from the station, back to the centre of the station. Adding this to the
; vector from the station to the ship gives the vector from the point in front
; of the station to the ship.
;
; In practice, this routine is called twice, so the ideal docking position is
; actually at a distance of 8 unit vectors from the centre of the station.
;
; Back in DOCKIT, we flip this vector round to get the vector from the ship to
; the point in front of the station slot.
;
; Arguments:
;
;   K3                  The vector from the station to the ship
;
; Returns:
;
;   K3                  The vector from the ship to the ideal docking position
;                       (4 unit vectors from the centre of the station for each
;                       call to DCS1, so two calls will return the vector to a
;                       point that's 8 unit vectors from the centre of the
;                       station)
;
; ******************************************************************************

.DCS1

 JSR P%+3               ; Run the following routine twice, so the subtractions
                        ; are all * 4

 LDA K%+NIK%+10         ; Set A to the space station's byte #10, nosev_x_hi

 LDX #0                 ; Set K3(2 1 0) = K3(2 1 0) - A * 2
 JSR TAS7               ;               = K3(2 1 0) - nosev_x_hi * 2

 LDA K%+NIK%+12         ; Set A to the space station's byte #12, nosev_y_hi

 LDX #3                 ; Set K3(5 4 3) = K3(5 4 3) - A * 2
 JSR TAS7               ;               = K3(5 4 3) - nosev_y_hi * 2

 LDA K%+NIK%+14         ; Set A to the space station's byte #14, nosev_z_hi

 LDX #6                 ; Set K3(8 7 6) = K3(8 7 6) - A * 2
                        ;               = K3(8 7 6) - nosev_x_hi * 2

.TAS7

                        ; This routine subtracts A * 2 from one of the K3
                        ; coordinates, as determined by the value of X:
                        ;
                        ;   * X = 0, set K3(2 1 0) = K3(2 1 0) - A * 2
                        ;
                        ;   * X = 3, set K3(5 4 3) = K3(5 4 3) - A * 2
                        ;
                        ;   * X = 6, set K3(8 7 6) = K3(8 7 6) - A * 2
                        ;
                        ; Let's document it for X = 0, i.e. K3(2 1 0)

 ASL A                  ; Shift A left one place and move the sign bit into the
                        ; C flag, so A = |A * 2|

 STA R                  ; Set R = |A * 2|

 LDA #0                 ; Rotate the sign bit of A from the C flag into the sign
 ROR A                  ; bit of A, so A is now just the sign bit from the
                        ; original value of A. This also clears the C flag

 EOR #%10000000         ; Flip the sign bit of A, so it has the sign of -A

 EOR K3+2,X             ; Give A the correct sign of K3(2 1 0) * -A

 BMI TS71               ; If the sign of K3(2 1 0) * -A is negative, jump to
                        ; TS71, as K3(2 1 0) and A have the same sign

                        ; If we get here then K3(2 1 0) and A have different
                        ; signs, so we can add them to do the subtraction

 LDA R                  ; Set K3(2 1 0) = K3(2 1 0) + R
 ADC K3,X               ;               = K3(2 1 0) + |A * 2|
 STA K3,X               ;
                        ; starting with the low bytes

 BCC TS72               ; If the above addition didn't overflow, we have the
                        ; result we want, so jump to TS72 to return from the
                        ; subroutine

 INC K3+1,X             ; The above addition overflowed, so increment the high
                        ; byte of K3(2 1 0)

.TS72

 RTS                    ; Return from the subroutine

.TS71

                        ; If we get here, then K3(2 1 0) and A have the same
                        ; sign

 LDA K3,X               ; Set K3(2 1 0) = K3(2 1 0) - R
 SEC                    ;               = K3(2 1 0) - |A * 2|
 SBC R                  ;
 STA K3,X               ; starting with the low bytes

 LDA K3+1,X             ; And then the high bytes
 SBC #0
 STA K3+1,X

 BCS TS72               ; If the subtraction didn't underflow, we have the
                        ; result we want, so jump to TS72 to return from the
                        ; subroutine

 LDA K3,X               ; Negate the result in K3(2 1 0) by flipping all the
 EOR #%11111111         ; bits and adding 1, i.e. using two's complement to
 ADC #1                 ; give it the opposite sign, starting with the low
 STA K3,X               ; bytes

 LDA K3+1,X             ; Then doing the high bytes
 EOR #%11111111
 ADC #0
 STA K3+1,X

 LDA K3+2,X             ; And finally, flipping the sign bit
 EOR #%10000000
 STA K3+2,X

 JMP TS72               ; Jump to TS72 to return from the subroutine

; ******************************************************************************
;
;       Name: HITCH
;       Type: Subroutine
;   Category: Tactics
;    Summary: Work out if the ship in INWK is in our crosshairs
;  Deep dive: In the crosshairs
;
; ------------------------------------------------------------------------------
;
; This is called by the main flight loop to see if we have laser or missile lock
; on an enemy ship.
;
; Returns:
;
;   C flag              Set if the ship is in our crosshairs, clear if it isn't
;
; Other entry points:
;
;   HI1                 Contains an RTS
;
; ******************************************************************************

.HITCH

 CLC                    ; Clear the C flag so we can return with it cleared if
                        ; our checks fail

 LDA INWK+8             ; Set A = z_sign

 BNE HI1                ; If A is non-zero then the ship is behind us and can't
                        ; be in our crosshairs, so return from the subroutine
                        ; with the C flag clear (as HI1 contains an RTS)

 LDA TYPE               ; If the ship type has bit 7 set then it is the planet
 BMI HI1                ; or sun, which we can't target or hit with lasers, so
                        ; return from the subroutine with the C flag clear (as
                        ; HI1 contains an RTS)

 LDA INWK+31            ; Fetch bit 5 of byte #31 (the exploding flag) and OR
 AND #%00100000         ; with x_hi and y_hi
 ORA INWK+1
 ORA INWK+4

 BNE HI1                ; If this value is non-zero then either the ship is
                        ; exploding (so we can't target it), or the ship is too
                        ; far away from our line of fire to be targeted, so
                        ; return from the subroutine with the C flag clear (as
                        ; HI1 contains an RTS)

 LDA INWK               ; Set A = x_lo

 JSR SQUA2              ; Set (A P) = A * A = x_lo^2

 STA S                  ; Set (S R) = (A P) = x_lo^2
 LDA P
 STA R

 LDA INWK+3             ; Set A = y_lo

 JSR SQUA2              ; Set (A P) = A * A = y_lo^2

 TAX                    ; Store the high byte in X

 LDA P                  ; Add the two low bytes, so:
 ADC R                  ;
 STA R                  ;   R = P + R

 TXA                    ; Restore the high byte into A and add S to give the
 ADC S                  ; following:
                        ;
                        ;   (A R) = (S R) + (A P) = x_lo^2 + y_lo^2

 BCS TN10               ; If the addition just overflowed then there is no way
                        ; our crosshairs are within the ship's targetable area,
                        ; so return from the subroutine with the C flag clear
                        ; (as TN10 contains a CLC then an RTS)

 STA S                  ; Set (S R) = (A P) = x_lo^2 + y_lo^2

 LDY #2                 ; Fetch the ship's blueprint and set A to the high byte
 JSR GetShipBlueprint   ; of the targetable area of the ship

 CMP S                  ; We now compare the high bytes of the targetable area
                        ; and the calculation in (S R):
                        ;
                        ;   * If A >= S then then the C flag will be set
                        ;
                        ;   * If A < S then the C flag will be C clear

 BNE HI1                ; If A <> S we have just set the C flag correctly, so
                        ; return from the subroutine (as HI1 contains an RTS)

 DEY                    ; The high bytes were identical, so now we fetch the
 JSR GetShipBlueprint   ; low byte of the targetable area into A

 CMP R                  ; We now compare the low bytes of the targetable area
                        ; and the calculation in (S R):
                        ;
                        ;   * If A >= R then the C flag will be set
                        ;
                        ;   * If A < R then the C flag will be C clear

.HI1

 RTS                    ; Return from the subroutine

.TN10

 CLC                    ; Clear the C flag to indicate the ship is not in our
                        ; crosshairs

 RTS                    ; Return from the subroutine

; ******************************************************************************
;
;       Name: FRS1
;       Type: Subroutine
;   Category: Tactics
;    Summary: Launch a ship straight ahead of us, below the laser sights
;
; ------------------------------------------------------------------------------
;
; This is used in two places:
;
;   * When we launch a missile, in which case the missile is the ship that is
;     launched ahead of us
;
;   * When we launch our escape pod, in which case it's our abandoned Cobra Mk
;     III that is launched ahead of us
;
;   * The fq1 entry point is used to launch a bunch of cargo canisters ahead of
;     us as part of the death screen
;
; Arguments:
;
;   X                   The type of ship to launch ahead of us
;
; Returns:
;
;   C flag              Set if the ship was successfully launched, clear if it
;                       wasn't (as there wasn't enough free memory)
;
; Other entry points:
;
;   fq1                 Used to add a cargo canister to the universe
;
; ******************************************************************************

.FRS1

 JSR ZINF               ; Call ZINF to reset the INWK ship workspace

 LDA #28                ; Set y_lo = 28
 STA INWK+3

 LSR A                  ; Set z_lo = 14, so the launched ship starts out
 STA INWK+6             ; ahead of us

 LDA #%10000000         ; Set y_sign to be negative, so the launched ship is
 STA INWK+5             ; launched just below our line of sight

 LDA MSTG               ; Set A to the missile lock target, shifted left so the
 ASL A                  ; slot number is in bits 1-5

 ORA #%10000000         ; Set bit 7 and store the result in byte #32, the AI
 STA INWK+32            ; flag launched ship for the launched ship. For missiles
                        ; this enables AI (bit 7), makes it friendly towards us
                        ; (bit 6), sets the target to the value of MSTG (bits
                        ; 1-5), and sets its lock status as launched (bit 0).
                        ; It doesn't matter what it does for our abandoned
                        ; Cobra, as the AI flag gets overwritten once we return
                        ; from the subroutine back to the ESCAPE routine that
                        ; called FRS1 in the first place

.fq1

 LDA #$60               ; Set byte #14 (nosev_z_hi) to 1 ($60), so the launched
 STA INWK+14            ; ship is pointing away from us

 ORA #128               ; Set byte #22 (sidev_x_hi) to -1 ($D0), so the launched
 STA INWK+22            ; ship has the same orientation as spawned ships, just
                        ; pointing away from us (if we set sidev to +1 instead,
                        ; this ship would be a mirror image of all the other
                        ; ships, which are spawned with -1 in nosev and +1 in
                        ; sidev)

 LDA DELTA              ; Set byte #27 (speed) to 2 * DELTA, so the launched
 ROL A                  ; ship flies off at twice our speed
 STA INWK+27

 TXA                    ; Add a new ship of type X to our local bubble of
 JMP NWSHP              ; universe and return from the subroutine using a tail
                        ; call

; ******************************************************************************
;
;       Name: FRMIS
;       Type: Subroutine
;   Category: Tactics
;    Summary: Fire a missile from our ship
;
; ------------------------------------------------------------------------------
;
; We fired a missile, so send it streaking away from us to unleash mayhem and
; destruction on our sworn enemies.
;
; ******************************************************************************

.FRMIS

 LDX #MSL               ; Call FRS1 to launch a missile straight ahead of us
 JSR FRS1

 BCC FR1                ; If FRS1 returns with the C flag clear, then there
                        ; isn't room in the universe for our missile, so jump
                        ; down to FR1 to display a "missile jammed" message

 LDX MSTG               ; Fetch the slot number of the missile's target

 JSR GINF               ; Get the address of the data block for the target ship
                        ; and store it in INF

 LDA FRIN,X             ; Fetch the ship type of the missile's target into A

 JSR ANGRY              ; Call ANGRY to make the target ship hostile

 LDY #$85               ; We have just launched a missile, so we need to remove
 JSR ABORT              ; missile lock and hide the leftmost indicator on the
                        ; dashboard by setting it to black (Y = $85) ???

 DEC NOMSL              ; Reduce the number of missiles we have by 1

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

 LDY #9                 ; Call the NOISE routine with Y = 9 to make the sound
 JMP NOISE              ; of a missile launch, returning from the subroutine
                        ; using a tail call ???

; ******************************************************************************
;
;       Name: ANGRY
;       Type: Subroutine
;   Category: Tactics
;    Summary: Make a ship hostile
;
; ------------------------------------------------------------------------------
;
; All this routine does is set the ship's hostile flag, start it turning and
; give it a kick of acceleration - later calls to TACTICS will make the ship
; start to attack us.
;
; Arguments:
;
;   A                   The type of ship we're going to irritate
;
;   INF                 The address of the data block for the ship we're going
;                       to infuriate
;
; ******************************************************************************

.ANGRY

 CMP #SST               ; If this is the space station, jump to AN2 to make the
 BEQ AN2                ; space station hostile

 LDY #36                ; Fetch the ship's NEWB flags from byte #36
 LDA (INF),Y

 AND #%00100000         ; If bit 5 of the ship's NEWB flags is clear, skip the
 BEQ P%+5               ; following instruction, otherwise bit 5 is set, meaning
                        ; this ship is an innocent bystander, and attacking it
                        ; will annoy the space station

 JSR AN2                ; Call AN2 to make the space station hostile

 LDY #32                ; Fetch the ship's byte #32 (AI flag)
 LDA (INF),Y

 BEQ HI1                ; If the AI flag is zero then this ship has no AI and
                        ; it can't get hostile, so return from the subroutine
                        ; (as HI1 contains an RTS)

 ORA #%10000000         ; Otherwise set bit 7 (AI enabled) to ensure AI is
 STA (INF),Y            ; definitely enabled

 LDY #28                ; Set the ship's byte #28 (acceleration) to 2, so it
 LDA #2                 ; speeds up
 STA (INF),Y

 ASL A                  ; Set the ship's byte #30 (pitch counter) to 4, so it
 LDY #30                ; starts pitching
 STA (INF),Y

 LDA TYPE               ; If the ship's type is < #CYL (i.e. a missile, Coriolis
 CMP #CYL               ; space station, escape pod, plate, cargo canister,
 BCC AN3                ; boulder, asteroid, splinter, Shuttle or Transporter),
                        ; then jump to AN3 to skip the following

 LDY #36                ; Set bit 2 of the ship's NEWB flags in byte #36 to
 LDA (INF),Y            ; make this ship hostile
 ORA #%00000100
 STA (INF),Y

.AN3

 RTS                    ; Return from the subroutine

.AN2

 LDA K%+NIK%+36         ; Set bit 2 of the NEWB flags in byte #36 of the second
 ORA #%00000100         ; ship in the ship data workspace at K%, which is
 STA K%+NIK%+36         ; reserved for the sun or the space station (in this
                        ; case it's the latter), to make it hostile

 RTS                    ; Return from the subroutine

; ******************************************************************************
;
;       Name: FR1
;       Type: Subroutine
;   Category: Tactics
;    Summary: Display the "missile jammed" message
;
; ------------------------------------------------------------------------------
;
; This is shown if there isn't room in the local bubble of universe for a new
; missile.
;
; Other entry points:
;
;   FR1-2               Clear the C flag and return from the subroutine
;
; ******************************************************************************

.FR1

 LDA #201               ; Print recursive token 41 ("MISSILE JAMMED") as an
 JMP MESS               ; in-flight message and return from the subroutine using
                        ; a tail call

; ******************************************************************************
;
;       Name: SESCP
;       Type: Subroutine
;   Category: Flight
;    Summary: Spawn an escape pod from the current (parent) ship
;
; ------------------------------------------------------------------------------
;
; This is called when an enemy ship has run out of both energy and luck, so it's
; time to bail.
;
; ******************************************************************************

.SESCP

 LDX #ESC               ; Set X to the ship type for an escape pod

 LDA #%11111110         ; Set A to an AI flag that has AI enabled, is hostile,
                        ; but has no E.C.M.

                        ; Fall through into SFS1 to spawn the escape pod

; ******************************************************************************
;
;       Name: SFS1
;       Type: Subroutine
;   Category: Universe
;    Summary: Spawn a child ship from the current (parent) ship
;
; ------------------------------------------------------------------------------
;
; If the parent is a space station then the child ship is spawned coming out of
; the slot, and if the child is a cargo canister, it is sent tumbling through
; space. Otherwise the child ship is spawned with the same ship data as the
; parent, just with damping disabled and the ship type and AI flag that are
; passed in A and X.
;
; Arguments:
;
;   A                   AI flag for the new ship (see the documentation on ship
;                       data byte #32 for details)
;
;   X                   The ship type of the child to spawn
;
;   INF                 Address of the parent's ship data block
;
;   TYPE                The type of the parent ship
;
; Returns:
;
;   C flag              Set if ship successfully added, clear if it failed
;
;   INF                 INF is preserved
;
;   XX0                 XX0 is preserved
;
;   INWK                The whole INWK workspace is preserved
;
;   X                   X is preserved
;
; Other entry points:
;
;   SFS1-2              Add a missile to the local bubble that has AI enabled,
;                       is hostile, but has no E.C.M.
;
; ******************************************************************************

.SFS1

 STA T1                 ; Store the child ship's AI flag in T1

 SETUP_PPU_FOR_ICON_BAR ; If the PPU has started drawing the icon bar, configure
                        ; the PPU to use nametable 0 and pattern table 0

                        ; Before spawning our child ship, we need to save the
                        ; INF and XX00 variables and the whole INWK workspace,
                        ; so we can restore them later when returning from the
                        ; subroutine

 TXA                    ; Store X, the ship type to spawn, on the stack so we
 PHA                    ; can preserve it through the routine

 LDA XX0                ; Store XX0(1 0) on the stack, so we can restore it
 PHA                    ; later when returning from the subroutine
 LDA XX0+1
 PHA

 LDA INF                ; Store INF(1 0) on the stack, so we can restore it
 PHA                    ; later when returning from the subroutine
 LDA INF+1
 PHA

 LDY #NI%-1             ; Now we want to store the current INWK data block in
                        ; temporary memory so we can restore it when we are
                        ; done, and we also want to copy the parent's ship data
                        ; into INWK, which we can do at the same time, so set up
                        ; a counter in Y for NI% bytes

.FRL2

 LDA INWK,Y             ; Copy the Y-th byte of INWK to the Y-th byte of
 STA XX3,Y              ; temporary memory in XX3, so we can restore it later
                        ; when returning from the subroutine

 LDA (INF),Y            ; Copy the Y-th byte of the parent ship's data block to
 STA INWK,Y             ; the Y-th byte of INWK

 DEY                    ; Decrement the loop counter

 BPL FRL2               ; Loop back to copy the next byte until we have done
                        ; them all

                        ; INWK now contains the ship data for the parent ship,
                        ; so now we need to tweak the data before creating the
                        ; new child ship (in this way, the child inherits things
                        ; like location from the parent)

 LDA TYPE               ; Fetch the ship type of the parent into A

 CMP #SST               ; If the parent is not a space station, jump to rx to
 BNE rx                 ; skip the following

                        ; The parent is a space station, so the child needs to
                        ; launch out of the space station's slot. The space
                        ; station's nosev vector points out of the station's
                        ; slot, so we want to move the ship along this vector.
                        ; We do this by taking the unit vector in nosev and
                        ; doubling it, so we spawn our ship 2 units along the
                        ; vector from the space station's centre

 TXA                    ; Store the child's ship type in X on the stack
 PHA

 LDA #32                ; Set the child's byte #27 (speed) to 32
 STA INWK+27

 LDX #0                 ; Add 2 * nosev_x_hi to (x_lo, x_hi, x_sign) to get the
 LDA INWK+10            ; child's x-coordinate
 JSR SFS2

 LDX #3                 ; Add 2 * nosev_y_hi to (y_lo, y_hi, y_sign) to get the
 LDA INWK+12            ; child's y-coordinate
 JSR SFS2

 LDX #6                 ; Add 2 * nosev_z_hi to (z_lo, z_hi, z_sign) to get the
 LDA INWK+14            ; child's z-coordinate
 JSR SFS2

 PLA                    ; Restore the child's ship type from the stack into X
 TAX

.rx

 LDA T1                 ; Restore the child ship's AI flag from T1 and store it
 STA INWK+32            ; in the child's byte #32 (AI)

 LSR INWK+29            ; Clear bit 0 of the child's byte #29 (roll counter) so
 ASL INWK+29            ; that its roll dampens (so if we are spawning from a
                        ; space station, for example, the spawned ship won't
                        ; keep rolling forever)

 TXA                    ; Copy the child's ship type from X into A

 CMP #SPL+1             ; If the type of the child we are spawning is less than
 BCS NOIL               ; #PLT or greater than #SPL - i.e. not an alloy plate,
 CMP #PLT               ; cargo canister, boulder, asteroid or splinter - then
 BCC NOIL               ; jump to NOIL to skip us setting up some pitch and roll
                        ; for it

 PHA                    ; Store the child's ship type on the stack so we can
                        ; retrieve it below

 JSR DORND              ; Set A and X to random numbers

 ASL A                  ; Set the child's byte #30 (pitch counter) to a random
 STA INWK+30            ; value, and at the same time set the C flag randomly

 TXA                    ; Set the child's byte #27 (speed) to a random value
 AND #%00001111         ; between 0 and 15
 STA INWK+27

 LDA #$FF               ; Set the child's byte #29 (roll counter) to a full
 ROR A                  ; roll, so the canister tumbles through space, with
 STA INWK+29            ; damping randomly enabled or disabled, depending on the
                        ; C flag from above

 PLA                    ; Retrieve the child's ship type from the stack

.NOIL

 JSR NWSHP              ; Add a new ship of type A to the local bubble

                        ; We have now created our child ship, so we need to
                        ; restore all the variables we saved at the start of
                        ; the routine, so they are preserved when we return
                        ; from the subroutine

 PLA                    ; Restore INF(1 0) from the stack
 STA INF+1
 PLA
 STA INF

 PHP                    ; Store the flags on the stack to we can retrieve them
                        ; after the macro

 JSR SetupPPUForIconBar ; If the PPU has started drawing the icon bar, configure
                        ; the PPU to use nametable 0 and pattern table 0

 PLP                    ; Retrieve the flags from the stack

 LDX #NI%-1             ; Now to restore the INWK workspace that we saved into
                        ; XX3 above, so set a counter in X for NI% bytes

.FRL3

 LDA XX3,X              ; Copy the Y-th byte of XX3 to the Y-th byte of INWK
 STA INWK,X

 DEX                    ; Decrement the loop counter

 BPL FRL3               ; Loop back to copy the next byte until we have done
                        ; them all

 PLA                    ; Restore XX0(1 0) from the stack
 STA XX0+1
 PLA
 STA XX0

 PLA                    ; Retrieve the ship type to spawn from the stack into X
 TAX                    ; so it is preserved through calls to this routine

 RTS                    ; Return from the subroutine

; ******************************************************************************
;
;       Name: SFS2
;       Type: Subroutine
;   Category: Moving
;    Summary: Move a ship in space along one of the coordinate axes
;
; ------------------------------------------------------------------------------
;
; Move a ship's coordinates by a certain amount in the direction of one of the
; axes, where X determines the axis. Mathematically speaking, this routine
; translates the ship along a single axis by a signed delta.
;
; Arguments:
;
;   A                   The amount of movement, i.e. the signed delta
;
;   X                   Determines which coordinate axis of INWK to move:
;
;                         * X = 0 moves the ship along the x-axis
;
;                         * X = 3 moves the ship along the y-axis
;
;                         * X = 6 moves the ship along the z-axis
;
; ******************************************************************************

.SFS2

 ASL A                  ; Set R = |A * 2|, with the C flag set to bit 7 of A
 STA R

 LDA #0                 ; Set bit 7 of A to the C flag, i.e. the sign bit from
 ROR A                  ; the original argument in A

 JMP MVT1               ; Add the delta R with sign A to (x_lo, x_hi, x_sign)
                        ; (or y or z, depending on the value in X) and return
                        ; from the subroutine using a tail call

; ******************************************************************************
;
;       Name: LAUN
;       Type: Subroutine
;   Category: Flight
;    Summary: Make the launch sound and draw the launch tunnel
;
; ------------------------------------------------------------------------------
;
; This is shown when launching from or docking with the space station.
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
;   Category: Drawing lines
;    Summary: Draw the laser lines for when we fire our lasers
;
; ------------------------------------------------------------------------------
;
; Draw the laser lines, aiming them to slightly different place each time so
; they appear to flicker and dance. Also heat up the laser temperature and drain
; some energy.
;
; Other entry points:
;
;   LASLI-1             Contains an RTS
;
; ******************************************************************************

.LASLI

 JSR DORND              ; Set A and X to random numbers

 AND #7                 ; Restrict A to a random value in the range 0 to 7

 ADC Yx1M2              ; Set LASY to two pixels above the centre of the
 SBC #2                 ; screen (Yx1M2), plus our random number, so the laser
 STA LASY               ; dances above and below the centre point

 JSR DORND              ; Set A and X to random numbers

 AND #7                 ; Restrict A to a random value in the range 0 to 7

 ADC #X-4               ; Set LASX to four pixels left of the centre of the
 STA LASX               ; screen (#X), plus our random number, so the laser
                        ; dances to the left and right of the centre point

 LDA GNTMP              ; Add 6 to the laser temperature in GNTMP
 ADC #6
 STA GNTMP

 JSR DENGY              ; Call DENGY to deplete our energy banks by 1

 LDA QQ11               ; If this is not a space view (i.e. QQ11 is non-zero)
 BNE LASLI-1            ; then jump to MA9 to return from the main flight loop
                        ; (as LASLI-1 is an RTS)

 LDA #32                ; Set A = 32 and Y = 224 for the first set of laser
 LDY #224               ; lines (the wider pair of lines)

 JSR las                ; Call las below to draw the first set of laser lines

 LDA #48                ; Fall through into las with A = 48 and Y = 208 to draw
 LDY #208               ; a second set of lines (the narrower pair)

                        ; The following routine draws two laser lines, one from
                        ; the centre point down to point A on the bottom row,
                        ; and the other from the centre point down to point Y
                        ; on the bottom row. We therefore get lines from the
                        ; centre point to points 32, 48, 208 and 224 along the
                        ; bottom row, giving us the triangular laser effect
                        ; we're after

.las

 STA X2                 ; Set X2 = A

 LDA LASX               ; Set (X1, Y1) to the random centre point we set above
 STA X1
 LDA LASY
 STA Y1

 LDA Yx2M1              ; Set Y2 to the height in pixels of the space view,
 STA Y2                 ; which is in the variable Yx2M1, so this sets Y2 to
                        ; the y-coordinate of the bottom pixel row of the space
                        ; view

 JSR LOIN               ; Draw a line from (X1, Y1) to (X2, Y2), so that's from
                        ; the centre point to (A, 191)

 LDA LASX               ; Set (X1, Y1) to the random centre point we set above
 STA X1
 LDA LASY
 STA Y1

 STY X2                 ; Set X2 = Y

 LDA Yx2M1              ; Set Y2 to the y-coordinate of the bottom pixel row
 STA Y2                 ; of the space view (as before)

 JMP LOIN               ; Draw a line from (X1, Y1) to (X2, Y2), so that's from
                        ; the centre point to (Y, 191), and return from
                        ; the subroutine using a tail call

; ******************************************************************************
;
;       Name: BRIEF2
;       Type: Subroutine
;   Category: Missions
;    Summary: Start mission 2
;
; ******************************************************************************

.BRIEF2

 LDA TP                 ; Set bit 2 of TP to indicate mission 2 is in progress
 ORA #%00000100         ; but plans have not yet been picked up
 STA TP

 LDA #11                ; Set A = 11 so the call to BRP prints extended token 11
                        ; (the initial contact at the start of mission 2, asking
                        ; us to head for Ceerdi for a mission briefing)

 JSR DETOK_b2           ; Print the extended token in A

 JSR subm_8926          ; ???

 JMP BAY                ; Jump to BAY to go to the docking bay (i.e. show the
                        ; Status Mode screen) and return from the subroutine
                        ; using a tail call

; ******************************************************************************
;
;       Name: BRP
;       Type: Subroutine
;   Category: Missions
;    Summary: Print an extended token and show the Status Mode screen
;
; ------------------------------------------------------------------------------
;
; Other entry points:
;
;   BAYSTEP             Go to the docking bay (i.e. show the Status Mode screen)
;
; ******************************************************************************

.BRP

 JSR DETOK_b2           ; Print the extended token in A

 JSR subm_B63D_b3       ; ???

.BAYSTEP

 JMP BAY                ; Jump to BAY to go to the docking bay (i.e. show the
                        ; Status Mode screen) and return from the subroutine
                        ; using a tail call

; ******************************************************************************
;
;       Name: BRIEF3
;       Type: Subroutine
;   Category: Missions
;    Summary: Receive the briefing and plans for mission 2
;
; ******************************************************************************

.BRIEF3

 LDA TP                 ; Set bits 1 and 3 of TP to indicate that mission 1 is
 AND #%11110000         ; complete, and mission 2 is in progress and the plans
 ORA #%00001010         ; have been picked up
 STA TP

 LDA #222               ; Set A = 222 so the call to BRP prints extended token
                        ; 222 (the briefing for mission 2 where we pick up the
                        ; plans we need to take to Birera)

 BNE BRP                ; Jump to BRP to print the extended token in A and show
                        ; the Status Mode screen), returning from the subroutine
                        ; using a tail call (this BNE is effectively a JMP as A
                        ; is never zero)

; ******************************************************************************
;
;       Name: DEBRIEF2
;       Type: Subroutine
;   Category: Missions
;    Summary: Finish mission 2
;
; ******************************************************************************

.DEBRIEF2

 LDA TP                 ; Set bit 2 of TP to indicate mission 2 is complete (so
 ORA #%00000100         ; both bits 2 and 3 are now set)
 STA TP

 LDA #2                 ; Set ENGY to 2 so our energy banks recharge at a faster
 STA ENGY               ; rate, as our mission reward is a special navy energy
                        ; unit that recharges at a rate of 3 units of energy on
                        ; each iteration of the main loop, compared to a rate of
                        ; 2 units of energy for the standard energy unit

 INC TALLY+1            ; Award 256 kill points for completing the mission

 LDA #223               ; Set A = 223 so the call to BRP prints extended token
                        ; 223 (the thank you message at the end of mission 2)

 BNE BRP                ; Jump to BRP to print the extended token in A and show
                        ; the Status Mode screen), returning from the subroutine
                        ; using a tail call (this BNE is effectively a JMP as A
                        ; is never zero)

; ******************************************************************************
;
;       Name: DEBRIEF
;       Type: Subroutine
;   Category: Missions
;    Summary: Finish mission 1
;
; ------------------------------------------------------------------------------
;
; Other entry points:
;
;   BRPS                Print the extended token in A, show the Status Mode
;                       screen and return from the subroutine
;
; ******************************************************************************

.DEBRIEF

 LSR TP                 ; Clear bit 0 of TP to indicate that mission 1 is no
 ASL TP                 ; longer in progress, as we have completed it

 LDX #LO(50000)         ; Increase our cash reserves by the generous mission
 LDY #HI(50000)         ; reward of 5,000 CR
 JSR MCASH

 LDA #15                ; Set A = 15 so the call to BRP prints extended token 15
                        ; (the thank you message at the end of mission 1)

.BRPS

 BNE BRP                ; Jump to BRP to print the extended token in A and show
                        ; the Status Mode screen, returning from the subroutine
                        ; using a tail call (this BNE is effectively a JMP as A
                        ; is never zero)

; ******************************************************************************
;
;       Name: TBRIEF
;       Type: Subroutine
;   Category: Missions
;    Summary: Start mission 3
;
; ******************************************************************************

.TBRIEF

 JSR ClearTiles_b3      ; ???

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
 BNE BAYSTEP

 LDY #$C3
 LDX #$50
 JSR LCASH

 INC TRIBBLE

 JMP BAY

; ******************************************************************************
;
;       Name: BRIEF
;       Type: Subroutine
;   Category: Missions
;    Summary: Start mission 1 and show the mission briefing
;
; ------------------------------------------------------------------------------
;
; This routine does the following:
;
;   * Clear the screen
;   * Display "INCOMING MESSAGE" in the middle of the screen
;   * Wait for 2 seconds
;   * Clear the screen
;   * Show the Constrictor rolling and pitching in the middle of the screen
;   * Do this for 64 loop iterations
;   * Move the ship away from us and up until it's near the top of the screen
;   * Show the mission 1 briefing in extended token 10
;
; The mission briefing ends with a "{display ship, wait for key press}" token,
; which calls the PAUSE routine. This continues to display the rotating ship,
; waiting until a key is pressed, and then removes the ship from the screen.
;
; ******************************************************************************

.BRIEF

 LSR TP                 ; Set bit 0 of TP to indicate that mission 1 is now in
 SEC                    ; progress
 ROL TP

 JSR BRIS_0             ; Call BRIS to clear the screen, display "INCOMING
                        ; MESSAGE" and wait for 2 seconds

 JSR ZINF               ; Call ZINF to reset the INWK ship workspace

 LDA #CON               ; Set the ship type in TYPE to the Constrictor
 STA TYPE

 JSR NWSHP              ; Add a new Constrictor to the local bubble (in this
                        ; case, the briefing screen)

 JSR subm_BAF3_b1       ; ???

 LDA #1                 ; Move the text cursor to column 1
 STA XC

 LDA #1                 ; This instruction has no effect, as A is already 1

 STA INWK+7             ; Set z_hi = 1, the distance at which we show the
                        ; rotating ship

 LDA #$50               ; ???
 STA INWK+6
 JSR subm_EB8C
 LDA #$92
 JSR subm_B39D

 LDA #64                ; Set the main loop counter to 64, so the ship rotates
 STA MCNT               ; for 64 iterations through MVEIT

.BRL1

 LDX #%01111111         ; Set the ship's roll counter to a positive roll that
 STX INWK+29            ; doesn't dampen

 STX INWK+30            ; Set the ship's pitch counter to a positive pitch that
                        ; doesn't dampen

 JSR subm_D96F          ; ???

 JSR MVEIT              ; Call MVEIT to rotate the ship in space

 DEC MCNT               ; Decrease the counter in MCNT

 BNE BRL1               ; Loop back to keep moving the ship until we have done
                        ; all 64 iterations

.BRL2

 LSR INWK               ; Halve x_lo so the Constrictor moves towards the centre

 INC INWK+6             ; Increment z_lo so the Constrictor moves away from us

 BEQ BR2                ; If z_lo = 0 (i.e. it just went past 255), jump to BR2
                        ; to show the briefing

 INC INWK+6             ; Increment z_lo so the Constrictor moves a bit further
                        ; away from us

 BEQ BR2                ; If z_lo = 0 (i.e. it just went past 255), jump out of
                        ; the loop to BR2 to stop moving the ship up the screen
                        ; and show the briefing

 LDX INWK+3             ; Set X = y_lo + 1
 INX

 CPX #100               ; If X < 100 then skip the next instruction
 BCC P%+4

 LDX #100               ; X is bigger than 100, so set X = 100 so that X has a
                        ; maximum value of 100

 STX INWK+3             ; Set y_lo = X
                        ;          = y_lo + 1
                        ;
                        ; so the ship moves up the screen (as space coordinates
                        ; have the y-axis going up)

 JSR subm_D96F          ; ???

 JSR MVEIT              ; Call MVEIT to move and rotate the ship in space

 DEC MCNT               ; Decrease the counter in MCNT

 JMP BRL2               ; Loop back to keep moving the ship up the screen and
                        ; away from us

.BR2

 INC INWK+7             ; Increment z_hi, to keep the ship at the same distance
                        ; as we just incremented z_lo past 255

 LDA #$93               ; ???
 JSR TT66

 LDA #10                ; Set A = 10 so the call to BRP prints extended token 10
                        ; (the briefing for mission 1 where we find out all
                        ; about the stolen Constrictor)

 JMP BRP                ; Jump to BRP to print the extended token in A and show
                        ; the Status Mode screen, returning from the subroutine
                        ; using a tail call

; ******************************************************************************
;
;       Name: BRIS_0
;       Type: Subroutine
;   Category: Missions
;    Summary: Clear the screen, display "INCOMING MESSAGE" and wait for 2
;             seconds
;
; ******************************************************************************

.BRIS_0

 LDA #216               ; Print extended token 216 ("{clear screen}{tab 6}{move
 JSR DETOK_b2           ; to row 10, white, lower case}{white}{all caps}INCOMING
                        ; MESSAGE"

 JSR subm_F2BD          ; ???

 LDY #100               ; Delay for 100 vertical syncs (100/50 = 2 seconds) and
 JMP DELAY              ; return from the subroutine using a tail call

; ******************************************************************************
;
;       Name: ping
;       Type: Subroutine
;   Category: Universe
;    Summary: Set the selected system to the current system
;
; ******************************************************************************

.ping

 LDX #1                 ; We want to copy the X- and Y-coordinates of the
                        ; current system in (QQ0, QQ1) to the selected system's
                        ; coordinates in (QQ9, QQ10), so set up a counter to
                        ; copy two bytes

.pl1

 LDA QQ0,X              ; Load byte X from the current system in QQ0/QQ1

 STA QQ9,X              ; Store byte X in the selected system in QQ9/QQ10

 DEX                    ; Decrement the loop counter

 BPL pl1                ; Loop back for the next byte to copy

 RTS                    ; Return from the subroutine

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
;   Category: Market
;    Summary: Work out if we have space for one tonne of cargo
;
; ------------------------------------------------------------------------------
;
; Given a market item, work out whether there is room in the cargo hold for one
; tonne of this item.
;
; For standard tonne canisters, the limit is given by the type of cargo hold we
; have, with a standard cargo hold having a capacity of 20t and an extended
; cargo bay being 35t.
;
; For items measured in kg (gold, platinum), g (gem-stones) and alien items,
; the individual limit on each of these is 200 units.
;
; Arguments:
;
;   A                   The type of market item (see QQ23 for a list of market
;                       item numbers)
;
; Returns:
;
;   A                   A = 1
;
;   C flag              Returns the result:
;
;                         * Set if there is no room for this item
;
;                         * Clear if there is room for this item
;
; ******************************************************************************

.tnpr1

 STA QQ29               ; Store the type of market item in QQ29

 LDA #1                 ; Set the number of units of this market item to 1

                        ; Fall through into tnpr to work out whether there is
                        ; room in the cargo hold for A tonnes of the item of
                        ; type QQ29

; ******************************************************************************
;
;       Name: tnpr
;       Type: Subroutine
;   Category: Market
;    Summary: Work out if we have space for a specific amount of cargo
;
; ------------------------------------------------------------------------------
;
; Given a market item and an amount, work out whether there is room in the
; cargo hold for this item.
;
; For standard tonne canisters, the limit is given by the type of cargo hold we
; have, with a standard cargo hold having a capacity of 20t and an extended
; cargo bay being 35t.
;
; For items measured in kg (gold, platinum), g (gem-stones) and alien items,
; the individual limit on each of these is 200 units.
;
; Arguments:
;
;   A                   The number of units of this market item
;
;   QQ29                The type of market item (see QQ23 for a list of market
;                       item numbers)
;
; Returns:
;
;   A                   A is preserved
;
;   C flag              Returns the result:
;
;                         * Set if there is no room for this item
;
;                         * Clear if there is room for this item
;
; ******************************************************************************

.tnpr

 PHA                    ; Store A on the stack

 LDX #12                ; If QQ29 > 12 then jump to kg below, as this cargo
 CPX QQ29               ; type is gold, platinum, gem-stones or alien items,
 BCC kg                 ; and they have different cargo limits to the standard
                        ; tonne canisters

.Tml

                        ; Here we count the tonne canisters we have in the hold
                        ; and add to A to see if we have enough room for A more
                        ; tonnes of cargo, using X as the loop counter, starting
                        ; with X = 12

 ADC QQ20,X             ; Set A = A + the number of tonnes we have in the hold
                        ; of market item number X. Note that the first time we
                        ; go round this loop, the C flag is set (as we didn't
                        ; branch with the BCC above, so the effect of this loop
                        ; is to count the number of tonne canisters in the hold,
                        ; and add 1

 DEX                    ; Decrement the loop counter

 BPL Tml                ; Loop back to add in the next market item in the hold,
                        ; until we have added up all market items from 12
                        ; (minerals) down to 0 (food)

 ADC TRIBBLE+1          ; Add the high byte of the number of Trumbles in the
                        ; hold, as 256 Trumbles take up one tonne of cargo space

 CMP CRGO               ; If A < CRGO then the C flag will be clear (we have
                        ; room in the hold)
                        ;
                        ; If A >= CRGO then the C flag will be set (we do not
                        ; have room in the hold)
                        ;
                        ; This works because A contains the number of canisters
                        ; plus 1, while CRGO contains our cargo capacity plus 2,
                        ; so if we actually have "a" canisters and a capacity
                        ; of "c", then:
                        ;
                        ; A < CRGO means: a+1 <  c+2
                        ;                 a   <  c+1
                        ;                 a   <= c
                        ;
                        ; So this is why the value in CRGO is 2 higher than the
                        ; actual cargo bay size, i.e. it's 22 for the standard
                        ; 20-tonne bay, and 37 for the large 35-tonne bay

 PLA                    ; Restore A from the stack

 RTS                    ; Return from the subroutine

.kg

                        ; Here we count the number of items of this type that
                        ; we already have in the hold, and add to A to see if
                        ; we have enough room for A more units

 LDY QQ29               ; Set Y to the item number we want to add

 ADC QQ20,Y             ; Set A = A + the number of units of this item that we
                        ; already have in the hold

 CMP #201               ; Is the result greater than 201 (the limit on
                        ; individual stocks of gold, platinum, gem-stones and
                        ; alien items)?
                        ;
                        ; If so, this sets the C flag (no room)
                        ;
                        ; Otherwise it is clear (we have room)

 PLA                    ; Restore A from the stack

 RTS                    ; Return from the subroutine

; ******************************************************************************
;
;       Name: ChangeViewRow0
;       Type: Subroutine
;   Category: Utility routines
;    Summary: Clear the screen, set the current view type and move the cursor to
;             row 0
;
; ------------------------------------------------------------------------------
;
; Arguments:
;
;   A                   The type of the new current view (see QQ11 for a list of
;                       view types)
;
; ******************************************************************************

.ChangeViewRow0

 JSR TT66               ; Clear the screen and set the current view type

 LDA #0                 ; Move the text cursor to row 0
 STA YC

 RTS                    ; Return from the subroutine

; ******************************************************************************
;
;       Name: TT20
;       Type: Subroutine
;   Category: Universe
;    Summary: Twist the selected system's seeds four times
;  Deep dive: Twisting the system seeds
;             Galaxy and system seeds
;
; ------------------------------------------------------------------------------
;
; Twist the three 16-bit seeds in QQ15 (selected system) four times, to
; generate the next system.
;
; ******************************************************************************

.TT20

 JSR P%+3               ; This line calls the line below as a subroutine, which
                        ; does two twists before returning here, and then we
                        ; fall through to the line below for another two
                        ; twists, so the net effect of these two consecutive
                        ; JSR calls is four twists, not counting the ones
                        ; inside your head as you try to follow this process

 JSR P%+3               ; This line calls TT54 as a subroutine to do a twist,
                        ; and then falls through into TT54 to do another twist
                        ; before returning from the subroutine

; ******************************************************************************
;
;       Name: TT54
;       Type: Subroutine
;   Category: Universe
;    Summary: Twist the selected system's seeds
;  Deep dive: Twisting the system seeds
;             Galaxy and system seeds
;
; ------------------------------------------------------------------------------
;
; This routine twists the three 16-bit seeds in QQ15 once.
;
; ******************************************************************************

.TT54

 LDA QQ15               ; X = tmp_lo = s0_lo + s1_lo
 CLC
 ADC QQ15+2
 TAX

 LDA QQ15+1             ; Y = tmp_hi = s1_hi + s1_hi + C
 ADC QQ15+3
 TAY

 LDA QQ15+2             ; s0_lo = s1_lo
 STA QQ15

 LDA QQ15+3             ; s0_hi = s1_hi
 STA QQ15+1

 LDA QQ15+5             ; s1_hi = s2_hi
 STA QQ15+3

 LDA QQ15+4             ; s1_lo = s2_lo
 STA QQ15+2

 CLC                    ; s2_lo = X + s1_lo
 TXA
 ADC QQ15+2
 STA QQ15+4

 TYA                    ; s2_hi = Y + s1_hi + C
 ADC QQ15+3
 STA QQ15+5

 RTS                    ; The twist is complete so return from the subroutine

; ******************************************************************************
;
;       Name: TT146
;       Type: Subroutine
;   Category: Text
;    Summary: Print the distance to the selected system in light years
;
; ------------------------------------------------------------------------------
;
; If it is non-zero, print the distance to the selected system in light years.
; If it is zero, just move the text cursor down a line.
;
; Specifically, if the distance in QQ8 is non-zero, print token 31 ("DISTANCE"),
; then a colon, then the distance to one decimal place, then token 35 ("LIGHT
; YEARS"). If the distance is zero, move the cursor down one line.
;
; ******************************************************************************

.TT146

 LDA QQ8                ; Take the two bytes of the 16-bit value in QQ8 and
 ORA QQ8+1              ; OR them together to check whether there are any
 BNE TT63               ; non-zero bits, and if so, jump to TT63 to print the
                        ; distance

 LDA MJ                 ; ???
 BNE TT63
 INC YC

 INC YC                 ; The distance is zero, so we just move the text cursor
 RTS                    ; in YC down by one line and return from the subroutine

.TT63

 LDA #191               ; Print recursive token 31 ("DISTANCE") followed by
 JSR TT68               ; a colon

 LDX QQ8                ; Load (Y X) from QQ8, which contains the 16-bit
 LDY QQ8+1              ; distance we want to show

 SEC                    ; Set the C flag so that the call to pr5 will include a
                        ; decimal point, and display the value as (Y X) / 10

 JSR pr5                ; Print (Y X) to 5 digits, including a decimal point

 LDA #195               ; Set A to the recursive token 35 (" LIGHT YEARS") and
                        ; fall through into TT60 to print the token followed
                        ; by a paragraph break

; ******************************************************************************
;
;       Name: TT60
;       Type: Subroutine
;   Category: Text
;    Summary: Print a text token and a paragraph break
;
; ------------------------------------------------------------------------------
;
; Print a text token (i.e. a character, control code, two-letter token or
; recursive token). Then print a paragraph break (a blank line between
; paragraphs) by moving the cursor down a line, setting Sentence Case, and then
; printing a newline.
;
; Arguments:
;
;   A                   The text token to be printed
;
; ******************************************************************************

.TT60

 JSR TT27_b2            ; Print the text token in A and fall through into TTX69
                        ; to print the paragraph break

; ******************************************************************************
;
;       Name: TTX69
;       Type: Subroutine
;   Category: Text
;    Summary: Print a paragraph break
;
; ------------------------------------------------------------------------------
;
; Print a paragraph break (a blank line between paragraphs) by moving the cursor
; down a line, setting Sentence Case, and then printing a newline.
;
; ******************************************************************************

.TTX69

 INC YC                 ; Move the text cursor down a line

                        ; Fall through into TT69 to set Sentence Case and print
                        ; a newline

; ******************************************************************************
;
;       Name: TT69
;       Type: Subroutine
;   Category: Text
;    Summary: Set Sentence Case and print a newline
;
; ******************************************************************************

.TT69

 LDA #%10000000         ; Set bit 7 of QQ17 to switch to Sentence Case
 STA QQ17

                        ; Fall through into TT67 to print a newline

; ******************************************************************************
;
;       Name: TT67
;       Type: Subroutine
;   Category: Text
;    Summary: Print a newline
;
; ******************************************************************************

.TT67

 LDA #12                ; Load a newline character into A

 JMP TT27_b2            ; Print the text token in A and return from the
                        ; subroutine using a tail call

; ******************************************************************************
;
;       Name: TT70
;       Type: Subroutine
;   Category: Text
;    Summary: Display "MAINLY " and jump to TT72
;
; ------------------------------------------------------------------------------
;
; This subroutine is called by TT25 when displaying a system's economy.
;
; ******************************************************************************

.TT70

 LDA #173               ; Print recursive token 13 ("MAINLY ")
 JSR TT27_b2

 JMP TT72               ; Jump to TT72 to continue printing system data as part
                        ; of routine TT25

; ******************************************************************************
;
;       Name: spc
;       Type: Subroutine
;   Category: Text
;    Summary: Print a text token followed by a space
;
; ------------------------------------------------------------------------------
;
; Print a text token (i.e. a character, control code, two-letter token or
; recursive token) followed by a space.
;
; Arguments:
;
;   A                   The text token to be printed
;
; ******************************************************************************

.spc

 JSR TT27_b2            ; Print the text token in A

 JMP TT162              ; Print a space and return from the subroutine using a
                        ; tail call

; ******************************************************************************
;
;       Name: PrintSpaceAndToken
;       Type: Subroutine
;   Category: Text
;    Summary: Print a space followed by a text token
;
; ------------------------------------------------------------------------------
;
; Arguments:
;
;   A                   The character to be printed
;
; ******************************************************************************

.PrintSpaceAndToken

 PHA                    ; Store the character to print on the stack

 JSR TT162              ; Print a space

 PLA                    ; Retrieve the character to print from the stack

 JMP TT27_b2            ; Print the character in A, returning from the
                        ; subroutine using a tail call

; ******************************************************************************
;
;       Name: tabDataOnSystem
;       Type: Variable
;   Category: Text
;    Summary: The column for the Data on System title for each language
;
; ******************************************************************************

.tabDataOnSystem

 EQUB 9                 ; English

 EQUB 9                 ; German

 EQUB 7                 ; French

 EQUB 9                 ; There is no fourth language, so this byte is ignored

; ******************************************************************************
;
;       Name: PrintTokenAndColon
;       Type: Subroutine
;   Category: Text
;    Summary: Print a character followed by a colon, drawing in both bit planes
;
; ------------------------------------------------------------------------------
;
; Arguments:
;
;   A                   The character to be printed
;
; ******************************************************************************

.PrintTokenAndColon

 JSR TT27_b2            ; Print the character in A

 LDA #3                 ; Set the font bit plane to print in both planes 1 and 2
 STA fontBitPlane

 LDA #':'               ; Print a colon
 JSR TT27_b2

 LDA #1                 ; Set the font bit plane to plane 1
 STA fontBitPlane

 RTS                    ; Return from the subroutine

; ******************************************************************************
;
;       Name: radiusText
;       Type: Variable
;   Category: Text
;    Summary: The text string "RADIUS" for use in the Data on System screen
;
; ******************************************************************************

.radiusText

 EQUS "RADIUS"

; ******************************************************************************
;
;       Name: TT25
;       Type: Subroutine
;   Category: Universe
;    Summary: Show the Data on System screen
;  Deep dive: Generating system data
;             Galaxy and system seeds
;
; ------------------------------------------------------------------------------
;
; Other entry points:
;
;   TT72                Used by TT70 to re-enter the routine after displaying
;                       "MAINLY" for the economy type
;
; ******************************************************************************

.TT25

 LDA #$96               ; Change to view $96 and move the text cursor to row 0
 JSR ChangeViewRow0

 JSR TT111              ; Select the system closest to galactic coordinates
                        ; (QQ9, QQ10)

 LDX language           ; Move the text cursor to the correct column for the
 LDA tabDataOnSystem,X  ; Data on System title in the chosen language
 STA XC

 LDA #163               ; Print recursive token 3 ("DATA ON {selected system
 JSR NLIN3              ; name}" and draw a horizontal line at pixel row 19
                        ; to box in the title

 JSR TTX69              ; Print a paragraph break and set Sentence Case

 JSR TT146              ; If the distance to this system is non-zero, print
                        ; "DISTANCE", then the distance, "LIGHT YEARS" and a
                        ; paragraph break, otherwise just move the cursor down
                        ; a line

 LDA L04A9              ; ???
 AND #%00000110
 BEQ dsys1

 LDA #194               ; Print recursive token 34 ("ECONOMY") followed by
 JSR PrintTokenAndColon ; colon

 JMP dsys2              ; Jump to dsys2 to print the economy type

.dsys1

 LDA #194               ; Print recursive token 34 ("ECONOMY") followed by
 JSR TT68               ; a colon

 JSR TT162              ; Print a space

.dsys2

 LDA QQ3                ; The system economy is determined by the value in QQ3,
                        ; so fetch it into A. First we work out the system's
                        ; prosperity as follows:
                        ;
                        ;   QQ3 = 0 or 5 = %000 or %101 = Rich
                        ;   QQ3 = 1 or 6 = %001 or %110 = Average
                        ;   QQ3 = 2 or 7 = %010 or %111 = Poor
                        ;   QQ3 = 3 or 4 = %011 or %100 = Mainly

 CLC                    ; If (QQ3 + 1) >> 1 = %10, i.e. if QQ3 = %011 or %100
 ADC #1                 ; (3 or 4), then call TT70, which prints "MAINLY " and
 LSR A                  ; jumps down to TT72 to print the type of economy
 CMP #%00000010
 BEQ TT70

 LDA QQ3                ; If (QQ3 + 1) >> 1 < %10, i.e. if QQ3 = %000, %001 or
 BCC TT71               ; %010 (0, 1 or 2), then jump to TT71 with A set to the
                        ; original value of QQ3

 SBC #5                 ; Here QQ3 = %101, %110 or %111 (5, 6 or 7), so subtract
 CLC                    ; 5 to bring it down to 0, 1 or 2 (the C flag is already
                        ; set so the SBC will be correct)

.TT71

 ADC #170               ; A is now 0, 1 or 2, so print recursive token 10 + A.
 JSR TT27_b2            ; This means that:
                        ;
                        ;   QQ3 = 0 or 5 prints token 10 ("RICH ")
                        ;   QQ3 = 1 or 6 prints token 11 ("AVERAGE ")
                        ;   QQ3 = 2 or 7 prints token 12 ("POOR ")

.TT72

 LDA QQ3                ; Now to work out the type of economy, which is
 LSR A                  ; determined by bit 2 of QQ3, as follows:
 LSR A                  ;
                        ;   QQ3 bit 2 = 0 = Industrial
                        ;   QQ3 bit 2 = 1 = Agricultural
                        ;
                        ; So we fetch QQ3 into A and set A = bit 2 of QQ3 using
                        ; two right shifts (which will work as QQ3 is only a
                        ; 3-bit number)

 CLC                    ; Print recursive token 8 + A, followed by a paragraph
 ADC #168               ; break and Sentence Case, so:
 JSR TT60               ;
                        ;   QQ3 bit 2 = 0 prints token 8 ("INDUSTRIAL")
                        ;   QQ3 bit 2 = 1 prints token 9 ("AGRICULTURAL")

 LDA L04A9              ; ???
 AND #%00000100
 BEQ dsys3

 LDA #162               ; Print recursive token 2 ("GOVERNMENT") followed by
 JSR PrintTokenAndColon ; colon

 JMP dsys4              ; Jump to dsys4 to print the government type

.dsys3

 LDA #162               ; Print recursive token 2 ("GOVERNMENT") followed by
 JSR TT68               ; a colon

 JSR TT162              ; Print a space

.dsys4

 LDA QQ4                ; The system's government is determined by the value in
                        ; QQ4, so fetch it into A

 CLC                    ; Print recursive token 17 + A, followed by a paragraph
 ADC #177               ; break and Sentence Case, so:
 JSR TT60               ;
                        ;   QQ4 = 0 prints token 17 ("ANARCHY")
                        ;   QQ4 = 1 prints token 18 ("FEUDAL")
                        ;   QQ4 = 2 prints token 19 ("MULTI-GOVERNMENT")
                        ;   QQ4 = 3 prints token 20 ("DICTATORSHIP")
                        ;   QQ4 = 4 prints token 21 ("COMMUNIST")
                        ;   QQ4 = 5 prints token 22 ("CONFEDERACY")
                        ;   QQ4 = 6 prints token 23 ("DEMOCRACY")
                        ;   QQ4 = 7 prints token 24 ("CORPORATE STATE")

 LDA #196               ; Print recursive token 36 ("TECH.LEVEL") followed by a
 JSR TT68               ; colon

 LDX QQ5                ; Fetch the tech level from QQ5 and increment it, as it
 INX                    ; is stored in the range 0-14 but the displayed range
                        ; should be 1-15

 CLC                    ; Call pr2 to print the technology level as a 3-digit
 JSR pr2                ; number without a decimal point (by clearing the C
                        ; flag)

 JSR TTX69              ; Print a paragraph break and set Sentence Case

 LDA #193               ; Print recursive token 33 ("TURNOVER"), followed
 JSR TT68               ; by a colon

 LDX QQ7                ; Fetch the 16-bit productivity value from QQ7 into
 LDY QQ7+1              ; (Y X)

 CLC                    ; Print (Y X) to 6 digits with no decimal point
 LDA #6
 JSR TT11

 JSR TT162              ; Print a space

 LDA #0                 ; Set QQ17 = 0 to switch to ALL CAPS
 STA QQ17

 LDA #'M'               ; Print "MCR", followed by a paragraph break and
 JSR DASC_b2            ; Sentence Case
 LDA #'C'
 JSR TT27_b2
 LDA #'R'
 JSR TT60

 LDY #0                 ; We now print the string in radiusText ("RADIUS"), so
                        ; set a character counter in Y

.dsys5

 LDA radiusText,Y       ; Print the Y-th character from radiusText
 JSR TT27_b2

 INY                    ; Increment the counter

 CPY #5                 ; Loop back until we have printed the first five letters
 BCC dsys5              ; of the string

 LDA radiusText,Y       ; Print the last letter of the string, followed by a
 JSR TT68               ; colon

 LDA QQ15+5             ; Set A = QQ15+5
 LDX QQ15+3             ; Set X = QQ15+3

 AND #%00001111         ; Set Y = (A AND %1111) + 11
 CLC
 ADC #11
 TAY

 LDA #5                 ; Print (Y X) to 5 digits, not including a decimal
 JSR TT11               ; point, as the C flag will be clear (as the maximum
                        ; radius will always fit into 16 bits)

 JSR TT162              ; Print a space

 LDA #'k'               ; Print "km"
 JSR DASC_b2
 LDA #'m'
 JSR DASC_b2

 JSR TTX69              ; Print a paragraph break and set Sentence Case

 LDA L04A9              ; ???
 AND #%00000101
 BEQ dsys6

 LDA #192               ; Print recursive token 32 ("POPULATION") followed by a
 JSR PrintTokenAndColon ; colon

 JMP dsys7              ; ; Jump to dsys7 to print the population

.dsys6

 LDA #192               ; Print recursive token 32 ("POPULATION") followed by a
 JSR TT68               ; colon

.dsys7

 LDA QQ6                ; Set X = QQ6 / 8
 LSR A                  ;
 LSR A                  ; We use this as the population figure, in billions
 LSR A
 TAX

 CLC                    ; Clear the C flag so we do not print a decimal point in
                        ; the call to pr2+2

 LDA #1                 ; Set the number of digits to 1 for the call to pr2+2

 JSR pr2+2              ; Print the population as a 1-digit number without a
                        ; decimal point

 LDA #198               ; Print recursive token 38 (" BILLION"), followed by a
 JSR TT60               ; paragraph break and Sentence Case

 LDA L04A9              ; ???
 AND #%00000010
 BNE dsys8

 LDA #'('               ; Print an opening bracket
 JSR TT27_b2

.dsys8

 LDA QQ15+4             ; Now to calculate the species, so first check bit 7 of
 BMI TT205              ; s2_lo, and if it is set, jump to TT205 as this is an
                        ; alien species

 LDA #188               ; Bit 7 of s2_lo is clear, so print recursive token 28
 JSR TT27_b2            ; ("HUMAN COLONIAL")

 JMP TT76               ; Jump to TT76 to print "S)" and a paragraph break, so
                        ; the whole species string is "(HUMAN COLONIALS)"

.TT75

 LDA QQ15+5             ; This is an alien species, so we take bits 0-1 of
 AND #%00000011         ; s2_hi, add this to the value of A that we used for
 CLC                    ; the third adjective, and take bits 0-2 of the result
 ADC QQ19
 AND #%00000111

 ADC #242               ; A = 0 to 7, so print recursive token 82 + A, so:
 JSR TT27_b2            ;
                        ;   A = 0 prints token 76 ("RODENT")
                        ;   A = 1 prints token 76 ("FROG")
                        ;   A = 2 prints token 76 ("LIZARD")
                        ;   A = 3 prints token 76 ("LOBSTER")
                        ;   A = 4 prints token 76 ("BIRD")
                        ;   A = 5 prints token 76 ("HUMANOID")
                        ;   A = 6 prints token 76 ("FELINE")
                        ;   A = 7 prints token 76 ("INSECT")

 LDA QQ15+5             ; Now for the second adjective, so shift s2_hi so we get
 LSR A                  ; A = bits 5-7 of s2_hi
 LSR A
 LSR A
 LSR A
 LSR A

 CMP #6                 ; If A >= 6, jump to dsys9 to skip the second adjective
 BCS dsys9

 ADC #230               ; Otherwise A = 0 to 5, so print a space followed by
 JSR PrintSpaceAndToken ; recursive token 70 + A, so:
                        ;
                        ;   A = 0 prints token 70 ("GREEN") and a space
                        ;   A = 1 prints token 71 ("RED") and a space
                        ;   A = 2 prints token 72 ("YELLOW") and a space
                        ;   A = 3 prints token 73 ("BLUE") and a space
                        ;   A = 4 prints token 74 ("BLACK") and a space
                        ;   A = 5 prints token 75 ("HARMLESS") and a space

.dsys9

 LDA QQ19               ; Fetch the value that we calculated for the third
                        ; adjective

 CMP #6                 ; If A >= 6, jump to TT76 to skip the third adjective
 BCS TT76

 ADC #236               ; Otherwise A = 0 to 5, so print a space followed by
 JSR PrintSpaceAndToken ; recursive token 76 + A, so:
                        ;
                        ;   A = 0 prints token 76 ("SLIMY") and a space
                        ;   A = 1 prints token 77 ("BUG-EYED") and a space
                        ;   A = 2 prints token 78 ("HORNED") and a space
                        ;   A = 3 prints token 79 ("BONY") and a space
                        ;   A = 4 prints token 80 ("FAT") and a space
                        ;   A = 5 prints token 81 ("FURRY") and a space

 JMP TT76               ; Jump to TT76 as we have finished printing the
                        ; species string

.TT205

                        ; In NES Elite, there is no first adjective (in the
                        ; other versions, the first adjective can be "Large",
                        ; "Fierce" or "Small", but this is omitted in NES Elite
                        ; as there isn't space on-screen)

 LDA QQ15+3             ; In preparation for the third adjective, EOR the high
 EOR QQ15+1             ; bytes of s0 and s1 and extract bits 0-2 of the result:
 AND #%00000111         ;
 STA QQ19               ;   A = (s0_hi EOR s1_hi) AND %111
                        ;
                        ; storing the result in QQ19 so we can use it later

 LDA L04A9              ; If bit 2 of L04A9 is set, jump to TT75 to print the
 AND #%00000100         ; species and then the third adjective, e.g. "Rodents
 BNE TT75               ; Furry"

 LDA QQ15+5             ; Now for the second adjective, so shift s2_hi so we get
 LSR A                  ; A = bits 5-7 of s2_hi
 LSR A
 LSR A
 LSR A
 LSR A

 CMP #6                 ; If A >= 6, jump to TT206 to skip the second adjective
 BCS TT206

 ADC #230               ; Otherwise A = 0 to 5, so print recursive token
 JSR spc                ; 70 + A, followed by a space, so:
                        ;
                        ;   A = 0 prints token 70 ("GREEN") and a space
                        ;   A = 1 prints token 71 ("RED") and a space
                        ;   A = 2 prints token 72 ("YELLOW") and a space
                        ;   A = 3 prints token 73 ("BLUE") and a space
                        ;   A = 4 prints token 74 ("BLACK") and a space
                        ;   A = 5 prints token 75 ("HARMLESS") and a space

.TT206

 LDA QQ19               ; Fetch the value that we calculated for the third
                        ; adjective

 CMP #6                 ; If A >= 6, jump to TT207 to skip the third adjective
 BCS TT207

 ADC #236               ; Otherwise A = 0 to 5, so print recursive token
 JSR spc                ; 76 + A, followed by a space, so:
                        ;
                        ;   A = 0 prints token 76 ("SLIMY") and a space
                        ;   A = 1 prints token 77 ("BUG-EYED") and a space
                        ;   A = 2 prints token 78 ("HORNED") and a space
                        ;   A = 3 prints token 79 ("BONY") and a space
                        ;   A = 4 prints token 80 ("FAT") and a space
                        ;   A = 5 prints token 81 ("FURRY") and a space

.TT207

 LDA QQ15+5             ; Now for the actual species, so take bits 0-1 of
 AND #%00000011         ; s2_hi, add this to the value of A that we used for
 CLC                    ; the third adjective, and take bits 0-2 of the result
 ADC QQ19
 AND #%00000111

 ADC #242               ; A = 0 to 7, so print recursive token 82 + A, so:
 JSR TT27_b2            ;
                        ;   A = 0 prints token 76 ("RODENT")
                        ;   A = 1 prints token 76 ("FROG")
                        ;   A = 2 prints token 76 ("LIZARD")
                        ;   A = 3 prints token 76 ("LOBSTER")
                        ;   A = 4 prints token 76 ("BIRD")
                        ;   A = 5 prints token 76 ("HUMANOID")
                        ;   A = 6 prints token 76 ("FELINE")
                        ;   A = 7 prints token 76 ("INSECT")

.TT76

 LDA L04A9              ; ???
 AND #%00000010
 BNE dsys10

 LDA #')'               ; Print a closing bracket
 JSR TT27_b2

.dsys10

 JSR TTX69              ; Print a paragraph break and set Sentence Case

                        ; By this point, ZZ contains the current system number
                        ; which PDESC requires. It gets put there in the TT102
                        ; routine, which calls TT111 to populate ZZ before
                        ; calling TT25 (this routine)

 JSR PDESC_b2           ; Call PDESC to print the system's extended description

 JSR subm_EB8C          ; ???

 LDA #22                ; Move the text cursor to column 22
 STA XC

 LDA #8                 ; Move the text cursor to row 8
 STA YC

 LDA #1                 ; ???
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
 JSR SetScreenHeight
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
 JSR TT103
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
 JSR ChangeViewRow0
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
;       Name: TT16
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.TT16

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
 JSR TT123
 LDA QQ19+4
 STA QQ10
 STA QQ19+1
 PLA
 STA QQ19+3
 LDA QQ9
 JSR TT123
 LDA QQ19+4
 STA QQ9
 STA QQ19

; ******************************************************************************
;
;       Name: TT103
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.TT103

 LDA QQ11
 CMP #$9C
 BEQ TT105
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
;       Name: TT123
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.TT123

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
;       Name: TT105
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.TT105

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
 JSR TT103
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
 JSR TT103
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

; ******************************************************************************
;
;       Name: hyp
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.hyp

 LDA QQ12
 BNE subm_9E3C
 LDA QQ22+1
 BEQ Ghy
 RTS

; ******************************************************************************
;
;       Name: subm_9E51
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.subm_9E51

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
 JSR ChangeViewRow0
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
 STX fontBitPlane
 CLC
 LDX language
 ADC L9FD9,X
 STA YC
 TYA
 JSR TT151
 LDX #1
 STX fontBitPlane
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
 STX fontBitPlane
 LDX XX13
 JSR subm_EQSHP3+2
 LDX #1
 STX fontBitPlane
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
;   Category: Equipment
;    Summary: ???
;
; ******************************************************************************

.EQSHP

 LDA #$B9
 JSR ChangeViewRow0
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
 STA fontBitPlane
 JSR subm_A6A8
 LDA #1
 STA fontBitPlane
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
 STA fontBitPlane
 JSR subm_A6A8
 LDA #1
 STA fontBitPlane
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
 JSR PrintTokenAndColon
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

 LDA #':'
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

 LDA fontBitPlane
 PHA
 LDA #2
 STA fontBitPlane
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
 STA fontBitPlane
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
 JSR HideHiddenColour
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
 JSR SetScreenHeight
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
;       Name: SetScreenHeight
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.SetScreenHeight

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
 JMP subm_9E51

.CB150

 CMP #$29
 BNE CB157
 JMP hyp

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

 JSR TT16

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
 JSR SetScreenHeight
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
 STA fontBitPlane
 LDX #$FF
 STX QQ11a
 TXS
 JSR RESET
 JSR StartScreen_b6

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
;       Name: TITLE
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.TITLE

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

; ******************************************************************************
;
;       Name: subm_B831
;       Type: Subroutine
;   Category: ???
;    Summary: ???
;
; ******************************************************************************

.subm_B831

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
 JSR SetScreenHeight
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
