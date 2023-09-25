; ******************************************************************************
;
; NES ELITE GAME SOURCE (BANK 0)
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
;   * bank0.bin
;
; ******************************************************************************

 _BANK = 0

 INCLUDE "1-source-files/main-sources/elite-build-options.asm"

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

 LDY #44                ; Wait until 44 NMI interrupts have passed (i.e. the
 JSR DELAY              ; next 44 VBlanks)

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

 LDA CASH+1             ; If the second most significant byte of CASH(0 1 2 3)
 BEQ EN6                ; is zero then the cash amount is less than &010000
                        ; (6553.6 credits), so jump to EN6

 LDA TP                 ; If bit 4 of TP is set, then the Tribbles mission has
 AND #%00010000         ; already been completed, so jump to EN6
 BNE EN6

                        ; If we get here then cheat mode has not been applied,
                        ; we have at least 6553.6 credits and the Trumble
                        ; mission has not yet been offered, so we do that now

 JMP TBRIEF             ; Jump to TBRIEF to offer the Trumble mission, returning
                        ; from the subroutine using a tail call

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

 CMP #SST               ; ???
 BNE main32

 LDA spasto             ; Copy the address of the space station's ship blueprint
 STA XX0                ; from spasto(1 0) to XX0(1 0), which we set up in NWSPS
 LDA spasto+1           ; when calculating the correct station type (Coriolis or
 STA XX0+1              ; Dodo)

 LDY #4
 BNE main33

.main32

 ASL A                  ; Set Y = ship type * 2
 TAY

 LDA XX21-2,Y           ; The ship blueprints at XX21 start with a lookup
 STA XX0                ; table that points to the individual ship blueprints,
                        ; so this fetches the low byte of this particular ship
                        ; type's blueprint and stores it in XX0

 LDA XX21-1,Y           ; Fetch the high byte of this particular ship type's
 STA XX0+1              ; blueprint and store it in XX0+1

.main33

 CPY #6                 ; ???
 BEQ main36
 CPY #$3C
 BEQ main36
 CPY #4
 BEQ main35
 LDA INWK+32
 BPL main36
 CPY #2
 BEQ main34
 AND #$3E
 BEQ main36

.main34

 LDA INWK+31
 AND #$A0
 BNE main36

.main35

 LDA NEWB
 AND #4
 BEQ main36
 ASL allowInSystemJump
 SEC
 ROR allowInSystemJump

.main36

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
                        ; have non-zero high nibbles in their blueprint byte #0
                        ; so if we get here, our ship is one of those, and the
                        ; high nibble gives the market item number of the item
                        ; when scooped, less 1

 ADC #1                 ; Add 1 to the high nibble to get the market item
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

 JSR MakeScoopSound     ; Make the sound of the fuel scoops working

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

                        ; This version of Elite omits check 3 (which would check
                        ; the sign of the z-axis)

 CMP #89                ; 4. If z-axis < 89, jump to MA62 to fail docking, as
 BCC MA62               ; we are not in the 22.0 degree safe cone of approach

 LDA INWK+16            ; 5. If |roofv_x_hi| < 80, jump to MA62 to fail docking,
 AND #%01111111         ; as the slot is more than 36.6 degrees from horizontal
 CMP #80
 BCC MA62

.GOIN

 JSR ResetMusicAfterNMI ; Wait for the next NMI before resetting the current
                        ; tune to 0 (no tune) and stopping the music

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
;     * Remove scooped item after both successful and failed scooping attempts
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
                        ; chance of cargo loss or even death

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
 BNE main37
 LDA MSAR
 BEQ main38
 LDA MSTG
 BPL main38

.main37

 JSR HITCH              ; Call HITCH to see if this ship is in the crosshairs,
 BCS main39             ; in which case the C flag will be set and we jump to
                        ; main39 (so if there is no missile or laser lock, we
                        ; jump to MA8 to skip the following)

.main38

 JMP MA8                ; Jump to MA8 to skip the following

.main39

 LDA MSAR               ; We have missile lock, so check whether the leftmost
 BEQ MA47               ; missile is currently armed, and if not, jump to MA47
                        ; to process laser fire, as we can't lock an unarmed
                        ; missile

 LDA MSTG               ; ???
 BPL MA47

 JSR BEEP_b7            ; We have missile lock and an armed missile, so call
                        ; the BEEP subroutine to make a short, high beep

 LDX XSAV               ; Call ABORT2 to store the details of this missile
 LDY #109               ; lock, with the targeted ship's slot number in X
 JSR ABORT2             ; (which we stored in XSAV at the start of this ship's
                        ; loop at MAL1), and set the colour of the missile
                        ; indicator to the tile pattern number in Y (red
                        ; indicator = pattern 109)

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
 BNE main40
 LDX LAS
 CPX #$32
 BEQ MA14+2

.main40

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

 JSR RemoveFromScanner_b1  ; ???

 LDA LAS                ; Did we kill the asteroid using mining lasers? If not,
 CMP #Mlas              ; jump to nosp, otherwise keep going
 BNE nosp

 LDA TYPE               ; ???
 CMP #7
 BEQ main41
 CMP #6
 BNE nosp
 JSR DORND
 BPL main43
 LDA #1
 BNE main42

.main41

 JSR DORND
 ORA #1
 AND #3

.main42

 LDX #8
 JSR SPIN2
 JMP main43

.nosp

 LDY #PLT               ; Randomly spawn some alloy plates
 JSR SPIN

 LDY #OIL               ; Randomly spawn some cargo canisters
 JSR SPIN

.main43

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

 LDA MJ                 ; If we are in witchspace (in which case MJ > 0) or
 ORA demoInProgress     ; demoInProgress > 0 (in which case we are playing the
 BNE KS1S               ; demo), jump to KS1S to skip showing an on-screen
                        ; bounty for this kill

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
;       Name: Main flight loop (Part 3a of 16)
;       Type: Subroutine
;   Category: Main loop
;    Summary: Display in-flight messages, call parts 4 to 12 of the main flight
;             loop for each slot, and fall through into parts 13 to 16
;
; ******************************************************************************

.main24

 DEC DLY                ; Decrement the delay counter in DLY, which is used to
                        ; control how long flight messages remain on-screen

 BMI main27             ; If DLY is now negative, jump to main27 to set DLY to
                        ; zero and skip the following, as there is no flight
                        ; message to display

 BEQ main25             ; DLY is now zero so it must have been non-zero before
                        ; we decremented it, so jump to main25 to remove the
                        ; flight message from the screen, as its timer has run
                        ; down

                        ; DLY is non-zero, so we need to redraw any flight
                        ; messages we may have, so they remain on-screen while
                        ; DLY is still ticking down

 JSR PrintFlightMessage ; Print the current in-flight message, if there is one

 JMP main26             ; Jump to main26 to display the message we just printed
                        ; and continue with the rest of the main loop

.main25

 JSR CLYNS              ; Clear the bottom two text rows of the upper screen,
                        ; and move the text cursor to column 1 on row 21, i.e.
                        ; the start of the top row of the two bottom rows

.main26

 JSR DrawMessageInNMI   ; Configure the NMI to update the in-flight message part
                        ; of the screen (which is either the current in-flight
                        ; message, or the part of the screen that the call to
                        ; CLYNS just cleared)

 JMP MA16               ; Jump to MA16 to skip the following and continue with
                        ; the rest of the main loop

.FlightLoop4To16

 LDA QQ11               ; If this is not the space view (i.e. QQ11 is non-zero),
 BNE main24             ; jump to main24 to print the flight message for
                        ; non-space views, rejoining the main subroutine at MA16
                        ; below

 DEC DLY                ; Decrement the delay counter in DLY, which is used to
                        ; control how long flight messages remain on-screen

 BMI main27             ; If DLY is now 0 or negative, jump to main27 to set DLY
 BEQ main27             ; to zero and skip the following, as there is no flight
                        ; message to display

                        ; DLY is non-zero, so we need to redraw any flight
                        ; messages we may have, so they remain on-screen while
                        ; DLY is still ticking down

 JSR PrintFlightMessage ; Print the current flight message, if there is one

 JMP MA16               ; Jump to MA16 to skip the following and continue with
                        ; the rest of the main loop

.main27

 LDA #0                 ; Set DLY to 0 so that it doesn't decrement below zero
 STA DLY

.MA16

 LDA ECMP               ; If our E.C.M is not on, skip to MA69, otherwise keep
 BEQ MA69               ; going to drain some energy

 JSR DENGY              ; Call DENGY to deplete our energy banks by 1

 BEQ MA70               ; If we have no energy left, jump to MA70 to turn our
                        ; E.C.M. off

.MA69

 LDA ECMA               ; If an E.C.M is going off (ours or an opponent's) then
 BEQ MA66               ; keep going, otherwise skip to MA66

 LDA #128               ; Set K+2 = 128 to send to the DrawLightning routine as
 STA K+2                ; the x-coordinate of the centre of the lightning, so
                        ; it is centred on-screen

 LDA #127               ; Set K = 127 to send to the DrawLightning routine as
 STA K                  ; half the height of the lightning, so it fills the
                        ; whole screen width

 LDA halfScreenHeight   ; Set K+3 to the y-coordinate of the centre of the
 STA K+3                ; screen in halfScreenHeight, to send to the
                        ; DrawLightning routine as the y-coordinate of the
                        ; centre of the lightning, so it is centred on-screen

 STA K+1                ; Set K+1 to the y-coordinate of the centre of the
                        ; screen in halfScreenHeight, to send to the
                        ; DrawLightning routine as half the height of the
                        ; lightning, so it fills the whole screen height

 JSR DrawLightning_b6   ; Draw the lightning effect of the E.C.M. going off

 DEC ECMA               ; Decrement the E.C.M. countdown timer, and if it has
 BNE MA66               ; reached zero, keep going, otherwise skip to MA66

.MA70

 JSR ECMOF              ; If we get here then either we have either run out of
                        ; energy, or the E.C.M. timer has run down, so switch
                        ; off the E.C.M.

.MA66

 LDX #0                 ; We are about to work our way through all the ships in
                        ; the bubble, calling MAL1 (parts 4 to 12 of the main
                        ; flight loop) for each of them, so set X as a ship slot
                        ; counter

 LDA FRIN               ; If slot 0 is empty, jump to main28 to move on to the
 BEQ main28             ; next slot

 JSR MAL1               ; Call parts 4 to 12 of the main flight loop to update
                        ; the ship in slot 0

.main28

 LDX #2                 ; We deal with the sun/space station in slot 1 below, so
                        ; we now skip to slot 2 by setting X accordingly

.main29

 LDA FRIN,X             ; If slot X is empty then we have reached the last slot,
 BEQ main30             ; so jump to main30 to stop updating the slots

 JSR MAL1               ; Call parts 4 to 12 of the main flight loop to update
                        ; the ship in slot X

 JMP main29             ; Loop back until we have updated all the ship slots

.main30

 LDX #1                 ; We now process the sun/space station in slot 1, so we
                        ; set X as the slot number

 LDA FRIN+1             ; If slot 1 is empty then there is no sun or space
 BEQ MA18               ; station (which can happen in witchspace), so jump to
                        ; part 13 of the main loop as we are done updating the
                        ; ship slots

 BPL main31             ; If bit 7 of the ship type is clear, then this is the
                        ; space station rather than the sun, so jump to main31
                        ; to skip the following

 LDY #0                 ; Set the "space station present" flag to 0, as we are
 STY SSPR               ; no longer in the space station's safe zone

.main31

 JSR MAL1               ; Call parts 4 to 12 of the main flight loop to update
                        ; the sun or space station in slot 2

                        ; Fall through into part 13 to continue working through
                        ; the main flight loop

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

 JSR HideHiddenColour   ; Set the hidden colour to black, to switch off the
                        ; energy bomb effect (as the effect works by showing
                        ; hidden content instead of the visible content)

 JSR UpdateIconBar_b3   ; Update the icon bar to remove the energy bomb icon,
                        ; as it is a single-use weapon

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
 BNE MA93               ; code only runs every 32 iterations of the main loop)

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

.main44

 LDA K%,X
 STA INWK,X

 DEX

 BPL main44

 LDX #5

.main45

 LDY INWK+9,X
 LDA INWK+15,X
 STA INWK+9,X
 LDA INWK+21,X
 STA INWK+15,X
 STY INWK+21,X

 DEX

 BPL main45

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
;   * Perform an altitude check with the sun and process fuel scooping (every
;     32 iterations of the main loop, on iteration 20 of each 32)
;
; ******************************************************************************

.MA22

 LDA MJ                 ; If we are in witchspace, jump down to MA23S to skip
 BNE MA23S              ; the following, as there are no planets or suns to
                        ; bump into in witchspace

.MA93

 LDA demoInProgress     ; If the demo is not in progress, jump to main46 to skip
 BEQ main46             ; the following

                        ; If we get here then the demo is in progress, so now we
                        ; check to see if we have destroyed all the demo ships

 LDA JUNK               ; Set Y to the number of pieces of space junk (in JUNK)
 CLC                    ; plus the number of missiles (in MANY+1)
 ADC MANY+1
 TAY

 LDA FRIN+2,Y           ; There are Y non-ship items in the bubble, so if slot
 BNE main46             ; Y+2 is not empty (given that the first two slots are
                        ; the planet and sun), then this means there is at least
                        ; one ship in the bubble along with the junk and
                        ; missiles, so jump to main46 to skip the following as
                        ; we haven't yet destroyed all the ships in the combat
                        ; practice demo

 LDA #1                 ; If we get here then we have destroyed all the ships in
 JMP ShowScrollText_b6  ; the demo, so jump to ShowScrollText with A = 1 to show
                        ; the results of combat practice, returning from the
                        ; subroutine using a tail call

.main46

 LDA MCNT               ; Fetch the main loop counter and calculate MCNT mod 32,
 AND #31                ; which tells us the position of this loop in each block
                        ; of 32 iterations

 CMP #10                ; If this is the tenth or twentieth iteration in this
 BEQ main47             ; block of 32, do the following, otherwise jump to MA29
 CMP #20                ; to skip the planet altitude check and move on to the
 BNE MA29               ; sun distance check

.main47

 LDA #80                ; If our energy bank status in ENERGY is >= 80, skip
 CMP ENERGY             ; printing the following message (so the message is
 BCC main48             ; only shown if our energy is low)

 LDA #100               ; Print recursive token 100 ("ENERGY LOW{beep}") as an
 JSR MESS               ; in-flight message

 LDY #7                 ; Call the NOISE routine with Y = 7 to make a beep to
 JSR NOISE              ; indicate low energy

.main48

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
 BCC MA23               ; skip fuel scooping, as we aren't close enough

 CMP #240               ; If the cabin temperature < 240 then jump to nokilltr
 BCC nokilltr           ; as the heat isn't high enough to kill Trumbles

 LDA TRIBBLE+1          ; If TRIBBLE(1 0) = 0 then there are no Trumbles in the
 ORA TRIBBLE            ; hold, so jump to nokilltr to skip the following
 BEQ nokilltr

 LSR TRIBBLE+1          ; Halve the number of Trumbles in TRIBBLE(1 0) as the
 ROR TRIBBLE            ; cabin temperature is high enough to kill them off
                        ; (this will eventually bring the number down to zero)

 LDY #31                ; Call the NOISE routine with Y = 31 to make the sound
 JSR NOISE              ; of Trumbles being killed off by the heat of the sun

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

 BCS MA23               ; If A >= 70, jump to BA23 to skip fuel scooping, as the
                        ; fuel tanks are already full

 JSR MakeScoopSound     ; Make the sound of the fuel scoops working

 JSR SetSelectionFlags  ; Set the selected system flags for the new system and
                        ; update the icon bar if required

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

 LDA QQ11               ; If this is not the space view (i.e. QQ11 is non-zero)
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

 LDA QQ11               ; If this is not the space view, jump to main1 to skip
 BNE main1              ; the following, as we only need to flip the drawing
                        ; bitplane for animating the space view

 JSR FlipDrawingPlane   ; Flip the drawing bitplane so we draw into the bitplane
                        ; that isn't visible on-screen

.main1

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
 BEQ main2

 CLC
 BCC main5

.main2

 LDA MJ
 BEQ main3

 SEC
 BCS main5

.main3

 LDA allowInSystemJump
 BPL main4

 LDA #$B0
 JSR CheckJumpSafety+2

 JMP main5

.main4

 JSR CheckJumpSafety

.main5

 ROR allowInSystemJump

 LDX JSTX               ; Set X to the current rate of roll in JSTX

 LDY numberOfPilots     ; ???

 LDA controller1Left,Y
 ORA controller1Right,Y
 ORA KY3
 ORA KY4

 BMI main6

 LDA #16                ; Apply damping to the roll rate (if enabled), so the
 JSR cntr               ; roll rate in X creeps towards the centre by 16

.main6

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

 LDY numberOfPilots     ; ???
 LDA controller1Up,Y
 ORA controller1Down,Y
 ORA KY5
 ORA KY6
 BMI main7

 LDA #12                ; Apply damping to the pitch rate (if enabled), so the
 JSR cntr               ; pitch rate in X creeps towards the centre by 12

.main7

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
 BCC main8              ; speed, so jump down to main8 to set DELTA to this
                        ; value

 LDA #40                ; The maximum allowed speed is 40, so set A = 40

.main8

 STA DELTA              ; Store the updated speed in DELTA

.MA17

 SETUP_PPU_FOR_ICON_BAR ; If the PPU has started drawing the icon bar, configure
                        ; the PPU to use nametable 0 and pattern table 0

 LDA KY1                ; If "?" is being pressed, keep going, otherwise jump
 BEQ MA4                ; down to MA4 to skip the following

 LDA DELTA              ; The "slow down" key is being pressed, so subtract 4
 SEC                    ; from the speed in DELTA
 SBC #4

 BEQ main9              ; If the result is zero, jump to main9 to set the speed
                        ; to the minimum value of 1

 BCS main10             ; If the subtraction didn't underflow then this is a
                        ; valid speed, so jump down to main10 to set DELTA to
                        ; this value

.main9

 LDA #1                 ; Set A = 1 to use as the minimum speed

.main10

 STA DELTA              ; Store the updated speed in DELTA

.MA4

 LDA iconBarKeyPress    ; ???
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
                        ; indicators on the dashboard to the tile pattern number
                        ; in Y (black indicator = pattern 108)

 LDY #4                 ; Set Y = 4 so the call to NOISE makes a low, long beep
                        ; to indicate the missile is now disarmed

.main11

 JSR NOISE              ; Call the NOISE routine to make the sound in Y (which
                        ; will either be a low, long beep to indicate the
                        ; missile is now disarmed, or a short, high beep to
                        ; indicate that it is looking for a target)

 JMP MA64               ; Jump to MA64 to skip the following

.MA20

 LDY #108               ; Set the tile pattern for the active missile indicator
 LDX NOMSL              ; to 108 (which is a black indicator), so we can flash
 JSR MSBAR              ; it between red and black in the main loop to indicate
                        ; that it is looking for a target

 LDY #3                 ; Set Y = 3 and jump up to main11 to make a short,
 BNE main11             ; high beep to indicate that it is looking for a target
                        ; (this BNE is effectively a JMP as Y is never zero)

.MA25

 CMP #25                ; If the "Fire targetted missile" button was chosen on
 BNE MA24               ; the icon bar, keep going, otherwise jump down to MA24
                        ; to skip the following

 LDA MSTG               ; If MSTG = $FF then there is no target lock, so jump to
 BMI MA64S              ; MA64 via MA64S to skip the following (also skipping
                        ; the checks for the energy bomb)

 JSR FRMIS              ; The "fire missile" key is being pressed and we have
                        ; a missile lock, so call the FRMIS routine to fire
                        ; the missile

 JSR UpdateIconBar_b3   ; Update the icon bar to hide the fire button as we have
                        ; just fired a missile

.MA64S

 JMP MA64               ; Jump to MA64 to skip the following

.MA24

 CMP #$1A               ; ???
 BNE MA76

 LDA BOMB               ; If we already set off our energy bomb, then BOMB is
 BMI MA64S              ; negative, so this skips to MA64 via MA64S if our
                        ; energy bomb is already going off

 ASL BOMB               ; The "energy bomb" key is being pressed, so double
                        ; the value in BOMB. If we have an energy bomb fitted,
                        ; BOMB will contain $7F (%01111111) before this shift
                        ; and will contain $FE (%11111110) after the shift; if
                        ; we don't have an energy bomb fitted, BOMB will still
                        ; contain 0. The bomb explosion is dealt with in the
                        ; MAL1 routine below - this just registers the fact that
                        ; we've set the bomb ticking

 BEQ MA64S              ; If BOMB now contains 0, then the bomb is not going off
                        ; any more (or it never was), so jump to MA64 via MA64S
                        ; to skip the following

 LDA #$28               ; Set hiddenColour to $28, which is green-brown, so this
 STA hiddenColour       ; reveals pixels that use the (no-longer) hidden colour
                        ; in palette 0

 LDY #8                 ; Call the NOISE routine with Y = 8 to make the sound of
 JSR NOISE              ; the energy bomb going off

 JMP MA64               ; Jump to MA64 to skip the following

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
 BNE main12
 LDA allowInSystemJump
 AND #$C0
 BNE MA64
 JSR WARP
 JMP MA64

.main12

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

 BMI main13              ; ???
 BIT KY7
 BVS MA3

.main13

                        ; If we get here, then the "fire" button is being
                        ; pressed, our laser hasn't overheated and isn't already
                        ; being fired, and we actually have a laser fitted to
                        ; the current space view, so it's time to hit me with
                        ; those laser beams

 PHA                    ; Store the current view's laser power on the stack

 AND #%01111111         ; Set LAS and LAS2 to bits 0-6 of the laser power
 STA LAS
 STA LAS2

                        ; We now set Y to the correct sound to pass to the NOISE
                        ; routine to make the sound of the laser firing

 LDY #18                ; Set Y = 18 to use as the sound number for a pulse
                        ; laser

 PLA                    ; Set A to the current view's laser power, which we
 PHA                    ; stored on the stack above (and leave the value on
                        ; the stack

 BMI main15             ; If A >= 128, jump to main15 to check whether this is
                        ; a beam laser or a military laser

 CMP #Mlas              ; If A is not the power for a mining laser, jump to
 BNE main14             ; main14 to keep Y = 18

 LDY #16                ; This is a mining laser, so set Y = 16 to use as the
                        ; sound number

.main14

 BNE main17             ; Jump to main17 to make the sound in Y (this BNE is
                        ; effectively a JMP as Y is never zero)

.main15

                        ; If we get here then this is either a beam laser or a
                        ; military laser

 CMP #Armlas            ; If this is a military laser, jump to main16 to set
 BEQ main16             ; Y = 15 

 LDY #17                ; This is a beam laser, so set Y = 17 to use as the
                        ; sound number

 EQUB $2C               ; Skip the next instruction by turning it into
                        ; $2C $A0 $0F, or BIT $0FA0, which does nothing apart
                        ; from affect the flags

.main16

 LDY #15                ; This is a military laser, so set Y = 15 to use as the
                        ; sound number

.main17

 JSR NOISE              ; Call the NOISE routine to make the sound in Y, which
                        ; will be one of 15 (military laser), 16 (mining laser),
                        ; 17 (beam laser) or 18 (pulse laser)

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
                        ; comes to comes to ???

.MA3

 JSR FlightLoop4To16    ; Display in-flight messages, call parts 4 to 12 of the
                        ; main flight loop for each ship slot, and finish off
                        ; with parts 13 to 16 of the main flight loop

 LDA QQ11               ; ???
 BNE main20

 JSR SetupPPUForIconBar ; If the PPU has started drawing the icon bar, configure
                        ; the PPU to use nametable 0 and pattern table 0

 LDA drawingBitplane    ; ???
 BNE main18

 LDA flipEveryBitplane0
 EOR #$FF
 STA flipEveryBitplane0

 BMI main19

 LDA KL
 ORA KY2
 ROR A
 BNE main19

.main18

 JSR DrawBitplaneInNMI  ; Configure the NMI to send the drawing bitplane to the
                        ; PPU after drawing the box edges and setting the next
                        ; free tile number

 JSR COMPAS             ; Call COMPAS to update the compass

 JMP DrawPitchRollBars  ; Update the pitch and roll bars on the dashboard,
                        ; returning from the subroutine using a tail call

.main19

 LDA #%10001000         ; Set the bitplane flags for the drawing bitplane to the
 JSR SetDrawPlaneFlags  ; following:
                        ;
                        ;   * Bit 2 clear = send tiles up to configured numbers
                        ;   * Bit 3 set   = clear buffers after sending data
                        ;   * Bit 4 clear = we've not started sending data yet
                        ;   * Bit 5 clear = we have not yet sent all the data
                        ;   * Bit 6 clear = only send pattern data to the PPU
                        ;   * Bit 7 set   = send data to the PPU
                        ;
                        ; Bits 0 and 1 are ignored and are always clear
                        ;
                        ; This configures the NMI to send pattern data for the
                        ; drawing bitplane to the PPU during VBlank

 JSR COMPAS             ; Call COMPAS to update the compass

 JSR DrawPitchRollBars  ; Update the pitch and roll bars on the dashboard

 JSR DIALS_b6           ; ???

 LDX drawingBitplane

 LDA bitplaneFlags,X    ; Set bit 6 of the flags for the drawing bitplane, so
 ORA #%01000000         ; we send both nametable and pattern table data for
 STA bitplaneFlags,X    ; bitplane X to the PPU in the NMI handler

 RTS                    ; Return from the subroutine

.main20

 CMP #$98               ; ???
 BNE main23

 JSR GetStatusCondition ; Set X to our ship's status condition

 CPX previousCondition  ; If our condition hasn't changed, jump to main21 to
 BEQ main21             ; skip the following instruction

 JSR STATUS             ; Call STATUS to refresh the Status Mode screen, so our
                        ; status updates to show the new condition

.main21

 LDX previousCondition  ; Set X to the previous status condition

 CPX #3                 ; If the previous status condition was not red, jump to
 BNE main22             ; main22 to show the alert colour for the previous
                        ; condition

 LDA nmiCounter         ; If nmiCounter div 32 is odd (which will happen half
 AND #32                ; the time, and for 32 VBlanks in a row), jump to main22
 BNE main22             ; to skip the following

                        ; We get here if the previous condition was red, but
                        ; only for every other block of 32 VBlanks, so this
                        ; flashes the commander image background on and off with
                        ; a period of 32 VBlanks

 INX                    ; Increment X to 4, which will make the background of
                        ; the commander image flash between the top two alert
                        ; colours (i.e. light red and dark red)

.main22

 LDA alertColours,X     ; Change the palette so the visible colour is set to the
 STA visibleColour      ; alert colour for our status condition

.main23

 RTS                    ; Return from the subroutine

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
;   Category: Drawing the screen
;    Summary: Set the hidden colour to black, so that pixels in this colour in
;             palette 0 are invisible
;
; ------------------------------------------------------------------------------
;
; Returns:
;
;   A                   A is set to 15
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
;       Name: SetAXTo15
;       Type: Subroutine
;   Category: Utility routines
;    Summary: An unused routine that sets A and X to 15
;
; ******************************************************************************

.SetAXTo15

 LDA #15                ; Set A = 15

 TAX                    ; Set X = 15

 RTS                    ; Return from the subroutine

; ******************************************************************************
;
;       Name: PrintCombatRank
;       Type: Subroutine
;   Category: Status
;    Summary: Print the current combat rank
;
; ------------------------------------------------------------------------------
;
; This routine is based on part of the STATUS routine from the original source,
; so I have kept the original st3 and st4 labels.
;
; ******************************************************************************

.PrintCombatRank

 LDA #16                ; Print recursive token 130 ("RATING:") followed by
 JSR TT68               ; a colon

 LDA languageNumber     ; If bit 0 of languageNumber is clear then the chosen
 AND #%00000001         ; language is not English, so skip the following
 BEQ P%+5               ; instruction (as the screen has a different layout in
                        ; the other languages)

 JSR TT162              ; Print a space

 LDA TALLY+1            ; Fetch the high byte of the kill tally, and if it is
 BNE st4                ; not zero, then we have more than 256 kills, so jump
                        ; to st4 to work out whether we are Competent,
                        ; Dangerous, Deadly or Elite

                        ; Otherwise we have fewer than 256 kills, so we are one
                        ; of Harmless, Mostly Harmless, Poor, Average or Above
                        ; Average

 TAX                    ; Set X to 0 (as A is 0)

 LDX TALLY              ; Set X to the low byte of the kill tally

 CPX #0                 ; Increment A if X >= 0
 ADC #0

 CPX #2                 ; Increment A if X >= 2
 ADC #0

 CPX #8                 ; Increment A if X >= 8
 ADC #0

 CPX #24                ; Increment A if X >= 24
 ADC #0

 CPX #44                ; Increment A if X >= 44
 ADC #0

 CPX #130               ; Increment A if X >= 130
 ADC #0

 TAX                    ; Set X to A, which will be as follows:
                        ;
                        ;   * 1 (Harmless)        when TALLY = 0 or 1
                        ;
                        ;   * 2 (Mostly Harmless) when TALLY = 2 to 7
                        ;
                        ;   * 3 (Poor)            when TALLY = 8 to 23
                        ;
                        ;   * 4 (Average)         when TALLY = 24 to 43
                        ;
                        ;   * 5 (Above Average)   when TALLY = 44 to 129
                        ;
                        ;   * 6 (Competent)       when TALLY = 130 to 255
                        ;
                        ; Note that the Competent range also covers kill counts
                        ; from 256 to 511, but those are covered by st4 below

.st3

 TXA                    ; Store the combat rank in X on the stack
 PHA

 LDA languageNumber     ; If bits 0 and 2 of languageNumber are clear then the
 AND #%00000101         ; chosen language is not English or French, so skip
 BEQ P%+8               ; the following two instructions (as the screen has a
                        ; different layout in German)

 JSR TT162              ; Print two spaces
 JSR TT162

 PLA                    ; Set A to the combat rank we stored on the stack above

 CLC                    ; Print recursive token 135 + A, which will be in the
 ADC #21                ; range 136 ("HARMLESS") to 144 ("---- E L I T E ----")
 JMP plf                ; followed by a newline, returning from the subroutine
                        ; using a tail call

.st4

                        ; We call this from above with the high byte of the
                        ; kill tally in A, which is non-zero, and want to return
                        ; with the following in X, depending on our rating:
                        ;
                        ;   Competent = 6
                        ;   Dangerous = 7
                        ;   Deadly    = 8
                        ;   Elite     = 9
                        ;
                        ; The high bytes of the top tier ratings are as follows,
                        ; so this a relatively simple calculation:
                        ;
                        ;   Competent       = 1 to 2
                        ;   Dangerous       = 2 to 9
                        ;   Deadly          = 10 to 24
                        ;   Elite           = 25 and up

 LDX #9                 ; Set X to 9 for an Elite rating

 CMP #25                ; If A >= 25, jump to st3 to print out our rating, as we
 BCS st3                ; are Elite

 DEX                    ; Decrement X to 8 for a Deadly rating

 CMP #10                ; If A >= 10, jump to st3 to print out our rating, as we
 BCS st3                ; are Deadly

 DEX                    ; Decrement X to 7 for a Dangerous rating

 CMP #2                 ; If A >= 2, jump to st3 to print out our rating, as we
 BCS st3                ; are Dangerous

 DEX                    ; Decrement X to 6 for a Competent rating

 BNE st3                ; Jump to st3 to print out our rating, as we are
                        ; Competent (this BNE is effectively a JMP as A will
                        ; never be zero)

; ******************************************************************************
;
;       Name: PrintLegalStatus
;       Type: Subroutine
;   Category: Status
;    Summary: Print the current legal status (clean, offender or fugitive)
;
; ******************************************************************************

.PrintLegalStatus

 LDA #125               ; Print recursive token 125 ("LEGAL STATUS:) followed
 JSR spc                ; by a space

 LDA #19                ; Set A to token 133 ("CLEAN")

 LDY FIST               ; Fetch our legal status, and if it is 0, we are clean,
 BEQ st5                ; so jump to st5 to print "Clean"

 CPY #40                ; Set the C flag if Y >= 40, so C is set if we have
                        ; a legal status of 40+ (i.e. we are a fugitive)

 ADC #1                 ; Add 1 + C to A, so if C is not set (i.e. we have a
                        ; legal status between 1 and 49) then A is set to token
                        ; 134 ("OFFENDER"), and if C is set (i.e. we have a
                        ; legal status of 50+) then A is set to token 135
                        ; ("FUGITIVE")

.st5

 JMP plf                ; Print the text token in A (which contains our legal
                        ; status) followed by a newline, returning from the
                        ; subroutine using a tail call

; ******************************************************************************
;
;       Name: STATUS
;       Type: Subroutine
;   Category: Status
;    Summary: Show the Status Mode screen
;  Deep dive: Combat rank
;
; ******************************************************************************

.wearedocked

                        ; We call this from STATUS below if we are docked

 LDA #205               ; Print extended token 205 ("DOCKED") and return from
 JSR DETOK_b2           ; the subroutine using a tail call

 JSR TT67               ; Print a newline

 JMP st6+3              ; Jump down to st6+3, to print recursive token 125 and
                        ; continue to the rest of the Status Mode screen

.STATUS

 LDA #$98               ; Clear the screen and and set the view type in QQ11 to
 JSR SetNewViewType     ; $98 (Status Mode)

 JSR SetSelectedSystem  ; Set the selected system to the nearest system, if we
                        ; don't already have a selected system

 LDA #7                 ; Move the text cursor to column 7
 STA XC

 LDA #126               ; Print recursive token 126, which prints the top
 JSR NLIN3              ; four lines of the Status Mode screen:
                        ;
                        ;         COMMANDER {commander name}
                        ;
                        ;
                        ;   Present System      : {current system name}
                        ;   Hyperspace System   : {selected system name}
                        ;   Condition           :
                        ;
                        ; and draw a horizontal line at pixel row 19 to box
                        ; in the title

 JSR GetStatusCondition ; Set X to our ship's status condition

 STX previousCondition  ; Store the status condition in previousCondition, so
                        ; we keep an eye on changes in our condition

 LDA #230               ; Start off by setting A to token 70 ("GREEN")

 DEX                    ; If the status condition in X is 0, then we are docked,
 BMI wearedocked        ; so jump to wearedocked

 BEQ st6                ; So if X = 0, there are no ships in the vicinity, so
                        ; jump to st6 to print "Green" for our ship's condition

 LDY ENERGY             ; Otherwise we have ships in the vicinity, so we load
                        ; our energy levels into Y

 CPY #128               ; Set the C flag if Y >= 128, so C is set if we have
                        ; more than half of our energy banks charged

 ADC #1                 ; Add 1 + C to A, so if C is not set (i.e. we have low
                        ; energy levels) then A is set to token 231 ("RED"),
                        ; and if C is set (i.e. we have healthy energy levels)
                        ; then A is set to token 232 ("YELLOW")

.st6

 JSR plf                ; Print the text token in A (which contains our ship's
                        ; condition) followed by a newline

 LDA languageNumber     ; If bit 2 of languageNumber is clear then the chosen
 AND #%00000100         ; language is not French, so jump to stat1 to skip the
 BEQ stat1              ; following (as the screen has a different layout in
                        ; French)

 JSR PrintLegalStatus   ; Print the current legal status

 JSR PrintCombatRank    ; Print the current combat rank

 LDA #5                 ; Print control code 5, which prints the next
 JSR plf                ; two lines of the Status Mode screen:
                        ;
                        ;   Fuel: {fuel level} Light Years
                        ;   Cash: {cash} Cr
                        ;
                        ; followed by a newline

 JMP stat2              ; Jump to stat2 to skip the following

.stat1

 JSR PrintCombatRank    ; Print the current combat rank

 LDA #5                 ; Print control code 5, which prints the next
 JSR plf                ; two lines of the Status Mode screen:
                        ;
                        ;   Fuel: {fuel level} Light Years
                        ;   Cash: {cash} Cr
                        ;
                        ; followed by a newline

 JSR PrintLegalStatus   ; Print the current legal status

.stat2

 LDA #18                ; Print recursive token 132, which prints the next bit
 JSR PrintTokenCrTab    ; of the Status Mode screen:
                        ;
                        ;   EQUIPMENT:
                        ;
                        ; followed by a newline and the correct indent for
                        ; Status Mode entries in the chosen language

 INC YC                 ; Move the text cursor down one row

 LDA ESCP               ; If we don't have an escape pod fitted (i.e. ESCP is
 BEQ P%+7               ; zero), skip the following two instructions

 LDA #112               ; We do have an escape pod fitted, so print recursive
 JSR PrintTokenCrTab    ; token 112 ("ESCAPE POD"), followed by a newline and
                        ; the correct indent for Status Mode entries in the
                        ; chosen language

 LDA BST                ; If we don't have fuel scoops fitted, skip the
 BEQ P%+7               ; following two instructions

 LDA #111               ; We do have fuel scoops fitted, so print recursive
 JSR PrintTokenCrTab    ; token 111 ("FUEL SCOOPS"), followed by a newline and
                        ; the correct indent for Status Mode entries in the
                        ; chosen language

 LDA ECM                ; If we don't have an E.C.M. fitted, skip the following
 BEQ P%+7               ; two instructions

 LDA #108               ; We do have an E.C.M. fitted, so print recursive token
 JSR PrintTokenCrTab    ; 108 ("E.C.M.SYSTEM"), followed by a newline and the
                        ; correct indent for Status Mode entries in the chosen
                        ; language

 LDA #113               ; We now cover the four pieces of equipment whose flags
 STA XX4                ; are stored in BOMB through BOMB+3, and whose names
                        ; correspond with text tokens 113 through 116:
                        ;
                        ;   BOMB+0 = BOMB  = token 113 = Energy bomb
                        ;   BOMB+1 = ENGY  = token 114 = Energy unit
                        ;   BOMB+2 = DKCMP = token 115 = Docking computer
                        ;   BOMB+3 = GHYP  = token 116 = Galactic hyperdrive
                        ;
                        ; We can print these out using a loop, so we set XX4 to
                        ; 113 as a counter (and we also set A as well, to pass
                        ; through to plf2)

.stqv

 TAY                    ; Fetch byte BOMB+0 through BOMB+4 for values of XX4
 LDX BOMB-113,Y         ; from 113 through 117

 BEQ P%+5               ; If it is zero then we do not own that piece of
                        ; equipment, so skip the next instruction

 JSR PrintTokenCrTab    ; Print the recursive token in A from 113 ("ENERGY
                        ; BOMB") through 116 ("GALACTIC HYPERSPACE "), followed
                        ; by a newline and the correct indent for Status Mode
                        ; entries in the chosen language

 INC XX4                ; Increment the counter (and A as well)
 LDA XX4

 CMP #117               ; If A < 117, loop back up to stqv to print the next
 BCC stqv               ; piece of equipment

 LDX #0                 ; Now to print our ship's lasers, so set a counter in X
                        ; to count through the four views (0 = front, 1 = rear,
                        ; 2 = left, 3 = right)

.st

 STX CNT                ; Store the view number in CNT

 LDY LASER,X            ; Fetch the laser power for view X, and if we do not
 BEQ st1                ; have a laser fitted to that view, jump to st1 to move
                        ; on to the next one

 LDA languageNumber     ; If bit 2 of languageNumber is set then the chosen
 AND #%00000100         ; language is French, so jump to stat3 to skip the
 BNE stat3              ; following (as the screen has a different layout in
                        ; French)

 TXA                    ; Print recursive token 96 + X, which will print from 96
 CLC                    ; ("FRONT") through to 99 ("RIGHT"), followed by a space
 ADC #96
 JSR spc

.stat3

 LDA #103               ; Set A to token 103 ("PULSE LASER")

 LDX CNT                ; Retrieve the view number from CNT that we stored above

 LDY LASER,X            ; Set Y = the laser power for view X

 CPY #128+POW           ; If the laser power for view X is not #POW+128 (beam
 BNE P%+4               ; laser), skip the next LDA instruction

 LDA #104               ; This sets A = 104 if the laser in view X is a beam
                        ; laser (token 104 is "BEAM LASER")

 CPY #Armlas            ; If the laser power for view X is not #Armlas (military
 BNE P%+4               ; laser), skip the next LDA instruction

 LDA #117               ; This sets A = 117 if the laser in view X is a military
                        ; laser (token 117 is "MILITARY  LASER")

 CPY #Mlas              ; If the laser power for view X is not #Mlas (mining
 BNE P%+4               ; laser), skip the next LDA instruction

 LDA #118               ; This sets A = 118 if the laser in view X is a mining
                        ; laser (token 118 is "MINING  LASER")

 JSR TT27_b2            ; Print the text token in A (which contains our legal
                        ; status)

 LDA languageNumber     ; If bit 2 of languageNumber is clear then the chosen
 AND #%00000100         ; language is not French, so jump to stat4 to skip the
 BEQ stat4              ; following (as the screen has a different layout in
                        ; French)

 LDA CNT                ; Retrieve the view number from CNT that we stored above

 CLC                    ; Print recursive token 96 + A, which will print from 96
 ADC #96                ; ("FRONT") through to 99 ("RIGHT"), followed by a space
 JSR PrintSpaceAndToken

.stat4

 JSR PrintCrTab         ; Print a newline and the correct indent for Status Mode
                        ; entries in the chosen language

.st1

 LDX CNT                ; Increment the counter in X and CNT to point to the
 INX                    ; next view

 CPX #4                 ; If this isn't the last of the four views, jump back up
 BCC st                 ; to st to print out the next one

 LDA #24                ; Move the text cursor to column 24
 STA XC

 LDX languageIndex      ; Move the text cursor to the correct row for the
 LDA yHeadshot,X        ; commander image in the chosen language
 STA YC

 JSR GetHeadshotType_b4 ; Set S to the headshot number for the current combat
                        ; rank and status condition, in the range 0 to 13

 LDA S                  ; Set A to %1000xxxx where %xxxx is the headshot number
 ORA #%10000000         ; in the range 0 to 13

 CMP imageSentToPPU     ; Set the processor flags according to whether
                        ; imageSentToPPU already has this value

 STA imageSentToPPU     ; Set imageSentToPPU to A

 BEQ stat5              ; If imageSentToPPU already had this value then we are
                        ; already showing this image on-screen, so jump to stat5
                        ; to skip the following instruction as there's no need
                        ; to fade the screen out when the image isn't changing

 JSR FadeAndHideSprites ; Fade the screen to black and hide all sprites, so we
                        ; can update the screen while it's blacked-out

.stat5

 JSR DrawCmdrImage_b6   ; Draw the commander image as a coloured face image in
                        ; front of a greyscale headshot image, with optional
                        ; embellishments

                        ; Fall through into UpdateView to update the view

; ******************************************************************************
;
;       Name: UpdateView
;       Type: Subroutine
;   Category: Drawing the screen
;    Summary: Update the view
;
; ******************************************************************************

.UpdateView

 LDA firstFreeTile      ; If firstFreeTile = 0, set firstFreeTile = 255
 BNE upvw1              ;
 LDA #255               ; This ensures that the call to CopyNameBuffer0To1 below
 STA firstFreeTile      ; tells the NMI handler to send pattern entries up to
                        ; the first free tile, or to send tiles up to the very
                        ; end if we have run out of free tiles (which is when
                        ; firstFreeTile is zero)

.upvw1

 LDA #0                 ; Tell the NMI handler to send nametable entries from
 STA firstNametableTile ; tile 0 onwards

 LDA #108               ; Tell the NMI handler to only clear nametable entries
 STA maxNameTileToClear ; up to tile 108 * 8 = 864 (i.e. up to the end of tile
                        ; row 26)

 STA lastNameTile       ; Tell the PPU to send nametable entries up to tile
 STA lastNameTile+1     ; 108 * 8 = 864 (i.e. to the end of tile row 26) in both
                        ; bitplanes

 LDX #37                ; Set X = 37 to use as the first pattern tile for when
                        ; there is an icon bar

 LDA QQ11               ; If bit 6 of the view type is clear, then there is an
 AND #%01000000         ; icon bar, so jump to upvw2 to skip the following
 BEQ upvw2              ; instruction

 LDX #4                 ; Set X = 4 to use as the first pattern tile for when
                        ; there is no icon bar

.upvw2

 STX firstPatternTile   ; Tell the NMI handler to send pattern entries from
                        ; pattern X in the buffer (i.e. from pattern 4 if there
                        ; is no icon bar, or from pattern 37 if there is an
                        ; icon bar)

 JSR DrawBoxEdges       ; Draw the left and right edges of the box along the
                        ; sides of the screen, drawing into the nametable buffer
                        ; for the drawing bitplane

 JSR CopyNameBuffer0To1 ; Copy the contents of nametable buffer 0 to nametable
                        ; buffer and tell the NMI handler to send pattern
                        ; entries up to the first free tile

 LDA QQ11               ; If the new view in QQ11 is the same as the old view in
 CMP QQ11a              ; QQ11a, then jump to upvw6 to call UpdateScreen before
 BEQ upvw6              ; jumping back to upvw3 (which will either call
                        ; SendViewToPPU to update the view straight away, if
                        ; it's been faded to black, otherwise it will call
                        ; SetupFullViewInNMI to update the view in VBlank, to
                        ; prevent screen corruption)

 JSR SendViewToPPU_b3   ; Otherwise the view is changing, so it has already been
                        ; faded out and we can call SendViewToPPU to update the
                        ; view straight away without caring about screen
                        ; corruption

.upvw3

 LDX #$FF               ; Set X = $FF to use as the value of showIconBarPointer
                        ; below (i.e. show the icon bar pointer)

 LDA QQ11               ; If the view type in QQ11 is $95 (Trumble mission
 CMP #$95               ; briefing), jump to upvw4 to set showIconBarPointer to
 BEQ upvw4              ; 0 (i.e. hide the icon bar pointer)

 CMP #$DF               ; If the view type in QQ11 is $DF (Start screen with
 BEQ upvw4              ; the normal font loaded), jump to upvw4 to set
                        ; showIconBarPointer to 0 (i.e. hide the icon bar
                        ; pointer)

 CMP #$92               ; If the view type in QQ11 is $92 (Mission 1 rotating
 BEQ upvw4              ; ship briefing), jump to upvw4 to to set
                        ; showIconBarPointer to 0 (i.e. hide the icon bar
                        ; pointer)

 CMP #$93               ; If the view type in QQ11 is $93 (Mission 1 text
 BEQ upvw4              ; briefing), jump to upvw4 to to set showIconBarPointer
                        ; to 0 (i.e. hide the icon bar pointer)

 ASL A                  ; If bit 6 of the view type in QQ11 is clear, then there
 BPL upvw5              ; is an icon bar, so jump to upvw5 to set
                        ; showIconBarPointer to $FF (i.e. show the icon bar
                        ; pointer)

.upvw4

 LDX #0                 ; Set X = 0 to use as the value of showIconBarPointer
                        ; below (i.e. hide the icon bar pointer)

.upvw5

 STX showIconBarPointer ; Set showIconBarPointer to X, so we set it as follows:
                        ;
                        ;   * 0 if the view is a mission briefing, or the Start
                        ;     screen with the normal font loaded, or has no
                        ;     icon bar (in which case we hide the icon bar
                        ;     pointer)
                        ;
                        ;   * $FF otherwise (in which case we show the icon bar
                        ;     pointer)

 LDA firstFreeTile      ; Tell the NMI handler to send pattern entries from the
 STA firstPatternTile   ; first free tile onwards, so we don't waste time
                        ; resending the static tiles we have already sent

 RTS                    ; Return from the subroutine

.upvw6

 JSR UpdateScreen       ; Update the screen by sending data to the PPU, either
                        ; immediately or during VBlank, depending on whether
                        ; the screen is visible

 JMP upvw3              ; Jump back to upvw3 to continue updating the view

; ******************************************************************************
;
;       Name: yHeadshot
;       Type: Variable
;   Category: Status
;    Summary: The text row for the headshot on the Status Mode page
;
; ******************************************************************************

.yHeadshot

 EQUB 8                 ; English

 EQUB 8                 ; German

 EQUB 10                ; French

 EQUB 8                 ; There is no fourth language, so this byte is ignored

; ******************************************************************************
;
;       Name: DrawScreenInNMI
;       Type: Subroutine
;   Category: Drawing the screen
;    Summary: Configure the NMI handler to draw the screen
;
; ******************************************************************************

.DrawScreenInNMI

 JSR WaitForPPUToFinish ; Wait until both bitplanes of the screen have been
                        ; sent to the PPU, so the screen is fully updated and
                        ; there is no more data waiting to be sent to the PPU

 LDA #0                 ; Tell the NMI handler to send nametable entries from
 STA firstNametableTile ; tile 0 onwards

 LDA #100               ; Tell the NMI handler to only clear nametable entries
 STA maxNameTileToClear ; up to tile 100 * 8 = 800 (i.e. up to the end of tile
                        ; row 24)

 LDA #37                ; Tell the NMI handler to send pattern entries from
 STA firstPatternTile   ; pattern 37 in the buffer

 JSR SetupPPUForIconBar ; If the PPU has started drawing the icon bar, configure
                        ; the PPU to use nametable 0 and pattern table 0

 JSR DrawBoxEdges       ; Draw the left and right edges of the box along the
                        ; sides of the screen, drawing into the nametable buffer
                        ; for the drawing bitplane

 JSR CopyNameBuffer0To1 ; Copy the contents of nametable buffer 0 to nametable
                        ; buffer and tell the NMI handler to send pattern
                        ; entries up to the first free tile

 LDA #%11000100         ; Set both bitplane flags as follows:
 STA bitplaneFlags      ;
 STA bitplaneFlags+1    ;   * Bit 2 set   = send tiles up to end of the buffer
                        ;   * Bit 3 clear = don't clear buffers after sending
                        ;   * Bit 4 clear = we've not started sending data yet
                        ;   * Bit 5 clear = we have not yet sent all the data
                        ;   * Bit 6 set   = send both pattern and nametable data
                        ;   * Bit 7 set   = send data to the PPU
                        ;
                        ; Bits 0 and 1 are ignored and are always clear
                        ;
                        ; The NMI handler will now start sending data to the PPU
                        ; according to the above configuration, splitting the
                        ; process across multiple VBlanks if necessary

 LDA firstFreeTile      ; Tell the NMI handler to send pattern entries from the
 STA firstPatternTile   ; first free tile onwards, so we don't waste time
                        ; resending the static tiles we have already sent

 RTS                    ; Return from the subroutine

; ******************************************************************************
;
;       Name: PrintTokenCrTab
;       Type: Subroutine
;   Category: Text
;    Summary: Print a token, a newline and the correct indent for Status Mode
;             entries in the chosen language
;
; ******************************************************************************

.PrintTokenCrTab

 JSR TT27_b2            ; Print the token in A

                        ; Fall through into PrintCrTab to print a newline and
                        ; the correct indent for the chosen language

; ******************************************************************************
;
;       Name: PrintCrTab
;       Type: Subroutine
;   Category: Text
;    Summary: Print a newline and the correct indent for Status Mode entries in
;             the chosen language
;
; ******************************************************************************

.PrintCrTab

 JSR TT67               ; Print a newline

 LDX languageIndex      ; Move the text cursor to the correct column for the
 LDA xStatusMode,X      ; Status Mode entry in the chosen language
 STA XC

 RTS                    ; Return from the subroutine

; ******************************************************************************
;
;       Name: xStatusMode
;       Type: Variable
;   Category: Status
;    Summary: The text column for the Status Mode entries for each language
;
; ******************************************************************************

.xStatusMode

 EQUB 3                 ; English

 EQUB 3                 ; German

 EQUB 1                 ; French

 EQUB 3                 ; There is no fourth language, so this byte is ignored

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

 LDA decimalPoint       ; Otherwise the C flag is set, so print the correct
 JSR DASC_b2            ; decimal point character for the chosen language

 JMP TT35               ; Loop back to TT35 to print the next digit

.rT10

 RTS                    ; Return from the subroutine

; ******************************************************************************
;
;       Name: DrawPitchRollBars
;       Type: Subroutine
;   Category: Dashboard
;    Summary: Update the pitch and roll bars on the dashboard
;
; ------------------------------------------------------------------------------
;
; The roll indicator uses sprite 11 and the pitch indicator uses sprite 12.
;
; ******************************************************************************

.DrawPitchRollBars

                        ; We start by drawing the roll indicator

 LDA JSTX               ; Set SC2 = 216 + ~JSTX / 8
 EOR #$FF               ;         = 216 - (JSTX + 1) / 8
 LSR A                  ;
 LSR A                  ; We use this as the x-coordinate of the roll indicator
 LSR A                  ; as the centre of the indicator is at x-coordinate 232
 CLC                    ; and JSTX / 8 is in the range 0 to 31, with a value of
 ADC #216               ; 16 in the middle of the indicator, so SC2 is in the
 STA SC2                ; range 216 to 247 with a middle point of 231 (this
                        ; isn't 232 because of the + 1 in the calculation above)

 LDY #29                ; Set Y = 29 so we draw the indicator sprite on pixel
                        ; y-coordinate 170 + 29 = 199 (which is the y-coordinate
                        ; of the roll indicator)

 LDA #11                ; Set A = 11 so we draw the indicator usinmg sprite 11

 JSR piro1              ; Call piro1 below to draw the roll indicator

                        ; We now draw the pitch indicator

 LDA JSTY               ; Set SC2 = 216 + JSTY / 8
 LSR A                  ;
 LSR A                  ; We use this as the x-coordinate of the pitch indicator
 LSR A                  ; as the centre of the indicator is at x-coordinate 232
 CLC                    ; and JSTY / 8 is in the range 0 to 31, with a value of
 ADC #216               ; 16 in the middle of the indicator, so SC2 is in the
 STA SC2                ; range 216 to 247 with a middle point of 232

 LDY #37                ; Set Y = 37 so we draw the indicator sprite on pixel
                        ; y-coordinate 170 + 37 = 207 (which is the y-coordinate
                        ; of the pitch indicator)

 LDA #12                ; Set A = 11 so we draw the indicator usinmg sprite 12

.piro1

 ASL A                  ; Set X = A * 4
 ASL A                  ;
 TAX                    ; So we can use X as an index into the sprite buffer to
                        ; update the sprite data for sprite A (as each sprite
                        ; has four bytes in the buffer)

 LDA SC2                ; Set the x-coordinate of the relevant indicator's
 SEC                    ; sprite to SC2 - 4, so the centre of the eight-pixel
 SBC #4                 ; wide sprite is on x-coordinate SC2
 STA xSprite0,X

 TYA                    ; Set the y-coordinate of the relevant indicator's
 CLC                    ; sprite to 170 + Y, so it appears on the correct row
 ADC #170+YPAL
 STA ySprite0,X

 RTS                    ; Return from the subroutine

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

 LDY #19                ; Call the NOISE routine with Y = 19 to make the sound
 JSR NOISE              ; of the escape pod launching

 LDA #0                 ; The escape pod is a one-use item, so set ESCP to 0 so
 STA ESCP               ; we no longer have one fitted

 JSR UpdateIconBar_b3   ; Update the icon bar to remove the escape pod button as
                        ; we no longer have one

 LDA QQ11               ; If this is not the space view, jump to escp1 to skip
 BNE escp1              ; drawing the escape pod animation

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

 JSR DrawShipInBitplane ; Flip the drawing bitplane and draw the current ship in
                        ; the newly flipped bitplane

 DEC INWK+32            ; Decrement the counter in byte #32

 BNE ESL1               ; Loop back to keep moving the Cobra until the AI flag
                        ; is 0, which gives it time to drift away from our pod

.escp1

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

 LDA TRIBBLE            ; If there are no Trumbles in our hold, then both bytes
 ORA TRIBBLE+1          ; of TRIBBLE(1 0) will be zero, so jump to nosurviv to
 BEQ nosurviv           ; skip the following

 JSR DORND              ; Otherwise set TRIBBLE(1 0) to a random number between
 AND #7                 ; 1 and 7, to determine how many Trumbles manage to
 ORA #1                 ; hitch a ride in the escape pod (so using an escape pod
 STA TRIBBLE            ; is not a solution to the trouble with Trumbles)
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

 JSR CLYNS              ; Clear the bottom two text rows of the upper screen,
                        ; and move the text cursor to column 1 on row 21, i.e.
                        ; the start of the top row of the two bottom rows

 LDA #14                ; Print extended token 14 ("{clear bottom of screen}
 JSR DETOK_b2           ; PLANET NAME?{fetch line input from keyboard}"). The
                        ; last token calls MT26, which puts the entered search
                        ; term in INWK+5 and the term length in Y

 LDY #9                 ; We start by setting the default name to all A's in the
                        ; buffer at INWK+5, which is where the InputName routine
                        ; expects to find the default name to show, so set a
                        ; counter in Y for ten characters

 STY inputNameSize      ; Set inputNameSize = 9 so we fetch a system name with a
                        ; maximum size of 10 characters in the call to InputName
                        ; below

 LDA #'A'               ; Set A to ASCII "A" so we can fill the name buffer with
                        ; "A" characters

.sear1

 STA INWK+5,Y           ; Set the Y-th character of the name at INWK+5 with "A"

 DEY                    ; Decrement the loop counter

 BPL sear1              ; Loop back until we have filled all ten characters
                        ; of the name

 JSR InputName_b6       ; Get a system name from the controller into INWK+5,
                        ; where the name will be terminated by ASCII 13

 LDA INWK+5             ; If the first character of the entered name is ASCII 13
 CMP #13                ; then no name was entered, so jump to sear2 to return
 BEQ sear2              ; from the subroutine

 JSR TT81               ; Set the seeds in QQ15 (the selected system) to those
                        ; of system 0 in the current galaxy (i.e. copy the seeds
                        ; from QQ21 to QQ15)

 LDA #0                 ; We now loop through the galaxy's systems in order,
 STA XX20               ; until we find a match, so set XX20 to act as a system
                        ; counter, starting with system 0

.HME3

 SETUP_PPU_FOR_ICON_BAR ; If the PPU has started drawing the icon bar, configure
                        ; the PPU to use nametable 0 and pattern table 0

 LDA #%10000000         ; Set the DTW4 flag to %10000000 (justify text, print
 STA DTW4               ; the contents of the buffer whenever a carriage return
                        ; appears in the token)

 ASL A                  ; Set DTW5 = 0, which sets the size of the justified
 STA DTW5               ; text buffer at BUF to zero

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

 JSR DisableJustifyText ; Turn off justified text

 JSR TT20               ; We want to move on to the next system, so call TT20
                        ; to twist the three 16-bit seeds in QQ15

 INC XX20               ; Increment the system counter in XX20

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

 JMP DrawScreenInNMI    ; Configure the NMI handler to draw the screen,
                        ; returning from the subroutine using a tail call

.HME5

                        ; If we get here then we have found a match for the
                        ; entered search

 JSR DisableJustifyText ; Turn off justified text

 JSR CLYNS              ; Clear the bottom two text rows of the upper screen,
                        ; and move the text cursor to column 1 on row 21, i.e.
                        ; the start of the top row of the two bottom rows

 LDA #%00000000         ; Set DTW8 = %00000000 (capitalise the next letter)
 STA DTW8

 LDA QQ15+3             ; The x-coordinate of the system described by the seeds
 STA QQ9                ; in QQ15 is in QQ15+3 (s1_hi), so we copy this to QQ9
                        ; as the x-coordinate of the search result

 LDA QQ15+1             ; The y-coordinate of the system described by the seeds
 STA QQ10               ; in QQ15 is in QQ15+1 (s0_hi), so we copy this to QQ10
                        ; as the y-coordinate of the search result

 JMP ReturnFromSearch   ; Jump back into TT102 to select the found system and
                        ; return from the subroutine using a tail call

.sear2

 JSR CLYNS              ; Clear the bottom two text rows of the upper screen,
                        ; and move the text cursor to column 1 on row 21, i.e.
                        ; the start of the top row of the two bottom rows

 JMP DrawScreenInNMI    ; Configure the NMI handler to draw the screen,
                        ; returning from the subroutine using a tail call

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

 LDA ECMA               ; If an E.C.M. is currently active (either ours or an
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
 AND #%01111111         ; byte #32, so bits 0-4 of X are the target's slot
 LSR A                  ; number, and bit 5 is set (as the missile is hostile)
 TAX                    ; so X is fairly random and in the range 32-39 (as the
                        ; maximum slot number is 7)

 LDA MJ-32,X            ; Set X to entry X-32 starting from MJ table, which will
 TAX                    ; be even more random, as MJ is where we store data like
                        ; the cabin and laser temperature
                        ;
                        ; The value of X is used to determine the number of kill
                        ; points awarded for the destruction of the missile

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

 STA shipIsAggressive   ; Set shipIsAggressive = 3 so that bit 7 is clear, so
                        ; the default position is that the ship we are
                        ; processing tactics for is not looking for a fight
                        ; (though this might change, of course)

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
;   * If the ship is not hostile, then either perform docking manoeuvres (if
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

 LDA ECMA               ; If an E.C.M. is currently active (either ours or an
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

 CPX #161               ; ???
 BCC tact1

 LDA INWK+31            ; Set bit 6 in byte #31 to denote that the ship is
 ORA #%01000000         ; firing its laser at us
 STA INWK+31

 CPX #163               ; If X >= 163, i.e. X <= -35, then we are in the enemy
 BCS tact2              ; ship's crosshairs, so ???

.tact1

 JSR TAS6               ; ???
 LDA CNT
 EOR #$80
 STA CNT
 JSR TA15
 JMP tact3

.tact2

 JSR GetShipBlueprint   ; Fetch the enemy ship's byte #19 from their ship's
                        ; blueprint into A

 LSR A                  ; Halve the enemy ship's byte #19 (which contains both
                        ; the laser power and number of missiles) to get the
                        ; amount of damage we should take

 JSR OOPS               ; Call OOPS to take some damage, which could do anything
                        ; from reducing the shields and energy, all the way to
                        ; losing cargo or dying (if the latter, we don't come
                        ; back from this subroutine)

 LDY #11                ; Call the NOISE routine with Y = 11 to make the sound
 JSR NOISE              ; of us being hit by lasers

.tact3

 LDA INWK+7             ; ???
 CMP #3
 BCS tact4
 JSR DORND
 ORA #$C0
 CMP INWK+32
 BCC tact4
 JSR DORND
 AND #$87
 STA INWK+30
 JMP tact8

.tact4

 LDA INWK+1
 ORA INWK+4
 ORA INWK+7
 AND #$E0
 BEQ tact11
 BNE tact8

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

 BEQ tact5              ; If A = 0 then the ship is pretty close to us, so jump
                        ; to tact5 so it heads away from us ???

.TA5

                        ; If we get here then the ship is quite far away

 JSR DORND              ; Set A and X to random numbers

 ORA #%10000000         ; Set bit 7 of A

 CMP INWK+32            ; If A >= byte #32 (the ship's AI flag) then jump down
 BCS tact5              ; to tact5 so it heads away from us ???

                        ; We get here if A < byte #32, and the chances of this
                        ; being true are greater with high values of byte #32.
                        ; In other words, higher byte #32 values increase the
                        ; chances of a ship changing direction to head towards
                        ; us - or, to put it another way, ships with higher
                        ; byte #32 values are spoiling for a fight. Thargoids
                        ; have byte #32 set to 255, which explains an awful lot

 STA shipIsAggressive   ; Store A in shipIsAggressive, so we can check bit 7 of
                        ; the value below to judge whether this ship is spoiling
                        ; for a fight

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

.tact5

 JSR TA15               ; ???
 LDA shipIsAggressive
 BPL tact7

 LDA INWK+1             ; ???
 ORA INWK+4
 ORA INWK+7
 AND #$F8
 BNE tact7
 LDA CNT
 BMI tact6
 CMP CNT2
 BCS tact11

.tact6

 JMP tact10

.tact7

 LDA CNT
 BMI tact9
 CMP CNT2
 BCC tact10

.tact8

 LDA #3
 BNE tact12

.tact9

 AND #$7F
 CMP #6
 BCS tact11

.tact10

 LDA INWK+27
 CMP #6
 BCC tact8
 JSR DORND
 CMP #$C8
 BCC TA10

.tact11

 LDA #$FF
 LDX TYPE
 CPX #1
 BNE tact12
 ASL A

.tact12

 STA INWK+28

.TA10

 RTS

.TA151

 LDY #$0A
 JSR TAS3
 CMP #$98
 BCC tact13
 LDX #0
 STX RAT2

.tact13

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
 BPL tact14
 CMP #$9F
 BCC tact14
 LDA #7
 ORA INWK+30
 STA INWK+30
 LDA #0
 BEQ tact15

.tact14

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

.tact15

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
                        ; docking computer, so this is us auto-docking our
                        ; Cobra, so jump to PH3 to refine our approach
                        ;
                        ; Otherwise this is an NPC trying to dock, so keep going
                        ; to turn away from the station

.PH2

                        ; If we get here then we turn away from the station and
                        ; slow right down, effectively aborting this approach
                        ; attempt

 JSR TAS6               ; Call TAS6 to negate the vector in XX15 so it points in
                        ; the opposite direction, away from the station and
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

 LDY #133               ; We have just launched a missile, so we need to remove
 JSR ABORT              ; missile lock and hide the active indicator on the
                        ; dashboard by setting it to the tile pattern number
                        ; in Y (no missile indicator = pattern 133)

 DEC NOMSL              ; Reduce the number of missiles we have by 1

 LDA demoInProgress     ; If the demo is not in progress, jump to frmi1 to skip
 BEQ frmi1              ; the following

                        ; If we get here then the demo is in progress and we
                        ; just fired a missile, so we get a 60-second penalty
                        ; added to the time taken to complete the demo

 LDA #147               ; Print recursive token 146 ("60 SECOND PENALTY") in
 LDY #10                ; the middle of the screen and leave it there for 10
 JSR PrintMessage       ; ticks of the DLY counter

 LDA #25                ; Set nmiTimer = 25 to add half a second on top of the
 STA nmiTimer           ; penalty below (as 25 frames is half a second in PAL
                        ; systems)

 LDA nmiTimerLo         ; Add 60 to (nmiTimerHi nmiTimerLo) so the time recorded
 CLC                    ; to complete the combat demo is 60 seconds longer than
 ADC #60                ; it would have been if we hadn't fired the missile
 STA nmiTimerLo
 BCC frmi1
 INC nmiTimerHi

.frmi1

 LDY #9                 ; Call the NOISE routine with Y = 9 to make the sound
 JMP NOISE              ; of a missile launch, returning from the subroutine
                        ; using a tail call

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
; This routine does a similar job to the routine of the same name in the BBC
; Master version of Elite, but the code is significantly different.
;
; ******************************************************************************

.LAUN

 LDA #$00               ; Clear the screen and and set the view type in QQ11 to
 JSR ChangeToView       ; $00 (Space view with no fonts loaded)

 JSR HideMostSprites    ; Hide all sprites except for sprite 0 and the icon bar
                        ; pointer

 LDY #12                ; Call the NOISE routine with Y = 12 to make the first
 JSR NOISE              ; sound of the ship launching from the station

 LDA #128               ; Set K+2 = 128 to send to DrawLaunchBox and
 STA K+2                ; DrawLightning as the x-coordinate of the centre of the
                        ; boxes and lightning (so they are centred on-screen)

 LDA halfScreenHeight   ; Set K+3 to half the screen height to send to
 STA K+3                ; DrawLaunchBox and DrawLightning as the y-coordinate of
                        ; the centre of the boxes and lightning (so they are
                        ; centred on-screen)

 LDA #80                ; Set XP to use as a counter for the duration of the
 STA XP                 ; hyperspace effect, so we run the following loop 80
                        ; times

 LDA #112               ; Set YP to use as a counter for when we show the
 STA YP                 ; lightning effect at the end of the tunnel, which we
                        ; show when YP < 100 (so we wait until 13 frames have
                        ; passed before drawing the lightning)
                        ;
                        ; Also, at the start of each frame, we keep subtracting
                        ; 16 from STP until STP < YP, and only then do we start
                        ; drawing boxes and, possibly, the lightning

 LDY #4                 ; Wait until four NMI interrupts have passed (i.e. the
 JSR DELAY              ; next four VBlanks)

 LDY #24                ; Call the NOISE routine with Y = 24 to make the second
 JSR NOISE              ; sound of the ship launching from the station

.laun1

 JSR CheckForPause-3    ; Check whether the pause button has been pressed or an
                        ; icon bar button has been chosen, and process pause or
                        ; unpause if a pause-related button has been pressed

 JSR FlipDrawingPlane   ; Flip the drawing bitplane so we draw into the bitplane
                        ; that isn't visible on-screen

 LDA XP                 ; Set STP = 96 + (XP mod 16)
 AND #15                ;
 ORA #96                ;
 STA STP                ; So over the course of the 80 iterations around the
                        ; loop, STP starts at 96, then counts down from 112 to
                        ; 96, and keeps repeating this countdown until XP is
                        ; zero and STP is 96
                        ;
                        ; The higher the value of STP, the closer together the
                        ; lines in the tunnel, so this makes the tunnel lines
                        ; move further away as the animation progresses, giving
                        ; a feeling of moving forwards through the tunnel

 LDA #%10000000         ; Set bit 7 of firstBox so we can detect when we are on
 STA firstBox           ; the first iteration of the laun2 loop

                        ; We now draw the boxes in the launch tunnel effect,
                        ; looping back to hype2 for each new line
                        ;
                        ; STP gets decremented by 16 for each box, so STP is
                        ; set to the starting point (in the range 96 to 112),
                        ; and gets decremented by 16 for each box until it is
                        ; negative
                        ;
                        ; As STP decreases, the boxes get bigger, so this loop
                        ; draws the boxes from the smallest in the middle and
                        ; working out towards the edges

.laun2

 SETUP_PPU_FOR_ICON_BAR ; If the PPU has started drawing the icon bar, configure
                        ; the PPU to use nametable 0 and pattern table 0

 LDA STP                ; Set STP = STP + 16
 SEC                    ;
 SBC #16                ; And set A to the new value of STP

 BMI laun4              ; If STP is now negative, then jump to laun4 to move on
                        ; to the next frame, so we dtop drawing boxes in this
                        ; frame

 STA STP                ; Update STP with the new value

 CMP YP                 ; If STP >= YP, jump to laun2 to keep reducing STP until
 BCS laun2              ; STP < YP

 STA Q                  ; Set Q to the new value of STP

                        ; We now calculate how far the top edge of this box is
                        ; from the centre of the screen in a vertical direction,
                        ; with the result being boxes that are closer together,
                        ; the closer they are to the centre
                        ;
                        ; We space out the boxes using a reciprocal algorithm,
                        ; where the distance of line n from the centre is
                        ; proportional to 1/n, so the boxes get spaced roughly
                        ; in the proportions of 1/2, 1/3, 1/4, 1/5 and so on, so
                        ; the boxes bunch closer together as n increases
                        ;
                        ; STP also includes the iteration number, modded so it
                        ; runs from 15 to 0, so over the course of the animation
                        ; the boxes move away from the centre line, as the
                        ; iteration decreases and the value of R below increases

 LDA #8                 ; Set A = 8 to use in the following division

 JSR LL28               ; Call LL28 to calculate:
                        ;
                        ;   R = 256 * A / Q
                        ;     = 256 * 8 / STP
                        ;
                        ; So R is the vertical distance of the current box top
                        ; top from the centre of the screen
                        ;
                        ; The maximum value of STP is 112 - 16 = 96, and the
                        ; minimum is 0 (the latter being enforced by the
                        ; comparison above), so R ranges from 21 to 255

 LDA R                  ; Set A = R - 20
 SEC                    ;
 SBC #20                ; This sets the range of values in A to 1 to 235

                        ; We can now use A as half the height of the box to
                        ; draw, to give us an effect where the boxes are more
                        ; spread out as they get taller, and which get bigger
                        ; as the animation progesses, with the difference in
                        ; size between frames being more pronounced with the
                        ; bigger boxes

 CMP #84                ; If A >= 84, jump to laun4 to move on to the next frame
 BCS laun4              ; as the box is outside the edges of the screen (so we
                        ; can stop drawing lines in this frame as we have now
                        ; drawn them all)

 STA K+1                ; Set K+1 = A to send to DrawLaunchBox and DrawLightning
                        ; as half the height of the box/lightning

 LSR A                  ; Set K = 1.5 * K+1 to send to DrawLaunchBox and
 ADC K+1                ; DrawLightning as half the width of the box, so the box
 STA K                  ; is 50% wider than it is tall (as it's a space station
                        ; slot)

 ASL firstBox           ; Set the C flag to bit 7 of firstBox and zero firstBox
                        ; (as we know that only bit 7 of firstBox is set before
                        ; the shift)

 BCC laun3              ; If the C flag is clear then this is not the first
                        ; iteration of the laun2 loop for this frame, so jump to
                        ; laun3 to draw the box, skipping the lightning (so we
                        ; only draw the lightning on the first iteration of
                        ; laun2 for this frame

                        ; If we get here then this is the first iteration of the
                        ; laun2 loop for this frame, so we consider drawing the
                        ; lightning effect at the end of the tunnel

 LDA YP                 ; If YP >= 100, jump to laun3 to skip drawing the
 CMP #100               ; lightning as the tunnel exit is too small to contain
 BCS laun3              ; the lightning effect

 LDA K+1                ; If K+1 >= 72, jump to laun5 to draw the lightning but
 CMP #72                ; without drawing any boxes, as the first box (which is
 BCS laun5              ; the smallest) doesn't fit on-screen

 LDA STP                ; Store the value of STP on the stack so we can retrieve
 PHA                    ; it after the call to DrawLightning (as DrawLightning
                        ; corrupts the value of STP)

 JSR DrawLightning_b6   ; Call DrawLightning to draw the lightning effect at the
                        ; end of the tunnel, centred on the centre of the screen
                        ; and in a rectangle with a half-height of K and a
                        ; half-width of 1.5 * K (so it fits within the smallest
                        ; launch box)

 PLA                    ; Restore the value of STP that we stored on the stack
 STA STP

.laun3

 JSR DrawLaunchBox_b6   ; Draw a box centred on the centre of the screen, with a
                        ; half-height of K and a half-width of 1.5 * K

 JMP laun2              ; Loop back to laun2 to draw the next box

.laun4

 JSR DrawBitplaneInNMI  ; Configure the NMI to send the drawing bitplane to the
                        ; PPU after drawing the box edges and setting the next
                        ; free tile number

 DEC YP                 ; Decrement the lightning counter in YP

 DEC XP                 ; Decrement the frame counter in XP

 BNE laun1              ; Loop back to laun1 to draw the next frame of the
                        ; animation, until the frame counter runs down to 0

 LDY #23                ; Call the NOISE routine with Y = 23 to make the third
 JMP NOISE              ; sound of the ship launching from the station,
                        ; returning from the subroutine using a tail call

.laun5

                        ; We call this from the first iteration of the loop in
                        ; this frame, and when K+1 >= 72, which means that the
                        ; first box in this frame (which will be the smallest)
                        ; is too big for the screen, so we just draw the
                        ; lightning effect and don't draw any boxes

 LDA #72                ; Set K+1 = 72 to pass to DrawLightning as half the
 STA K+1                ; height of the lightning effect

 LDA STP                ; Store the value of STP on the stack so we can retrieve
 PHA                    ; it after the call to DrawLightning (as DrawLightning
                        ; corrupts the value of STP)

 JSR DrawLightning_b6   ; Call DrawLightning to draw the lightning effect at the
                        ; end of the tunnel, centred on the centre of the screen
                        ; and in a rectangle with a half-height of K and a
                        ; half-width of 1.5 * K (so it fits within the smallest
                        ; launch box)

 PLA                    ; Restore the value of STP that we stored on the stack
 STA STP

 JMP laun2              ; Loop back to laun2 to draw the next box

 RTS                    ; Return from the subroutine

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

 ADC halfScreenHeight   ; Set LASY to two pixels above the centre of the
 SBC #2                 ; screen (in halfScreenHeight), plus our random number,
 STA LASY               ; so the laser dances above and below the centre point

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

 LDA #11                ; Print extended token 11, which is the initial contact
 JSR DETOK_b2           ; at the start of mission 2, asking us to head for
                        ; Ceerdi for a mission briefing

 JSR UpdateView         ; Update the view

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

 JSR FadeToBlack_b3     ; Fade the screen to black over the next four VBlanks

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

 JSR ClearScreen_b3     ; Clear the screen by zeroing patterns 66 to 255 in
                        ; both pattern buffer, and clearing both nametable
                        ; buffers to the background tile

 LDA #$95               ; Clear the screen and and set the view type in QQ11 to
 JSR TT66               ; $95 (Text-based mission briefing)

 LDA TP                 ; Set bit 4 of TP to indicate that mission 3 has been
 ORA #%00010000         ; triggered
 STA TP

 LDA #199               ; Print extended token 199, which is the briefing for
 JSR DETOK_b2           ; the Trumbles mission

 JSR UpdateView         ; Update the view

 JSR YESNO              ; Call YESNO to wait until either "Y" or "N" is pressed

 CMP #1                 ; If "N" was pressed, then the mission was not accepted,
 BNE BAYSTEP            ; jump to BAYSTEP to go to the docking bay (i.e. show
                        ; the Status Mode screen)

 LDY #HI(50000)         ; Otherwise the mission was accepted, so subtract
 LDX #LO(50000)         ; 50,000 CR from the cash pot to pay for the Trumble
 JSR LCASH

 INC TRIBBLE            ; Increment the number of Trumbles from 0 to 1, so they
                        ; start breeding

 JMP BAY                ; Go to the docking bay (i.e. show the Status Mode
                        ; screen)

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

 JSR BRIS_b0            ; Call BRIS to clear the screen, display "INCOMING
                        ; MESSAGE" and wait for 2 seconds

 JSR ZINF               ; Call ZINF to reset the INWK ship workspace

 LDA #CON               ; Set the ship type in TYPE to the Constrictor
 STA TYPE

 JSR NWSHP              ; Add a new Constrictor to the local bubble (in this
                        ; case, the briefing screen)

 JSR HideFromScanner_b1 ; Hide the ship from the scanner

 LDA #1                 ; Move the text cursor to column 1
 STA XC

 LDA #1                 ; This instruction has no effect, as A is already 1

 STA INWK+7             ; Set z_hi = 1, the distance at which we show the
                        ; rotating ship

 LDA #80                ; Set z_lo = 80 to set the low byte of the distance at
 STA INWK+6             ; which we show the rotating ship

 JSR FadeAndHideSprites ; Fade the screen to black and hide all sprites, so we
                        ; can update the screen while it's blacked-out

 LDA #$92               ; Clear the screen and and set the view type in QQ11 to
 JSR ChangeToView       ; $92 (Mission 1 briefing: rotating ship)

 LDA #64                ; Set the main loop counter to 64, so the ship rotates
 STA MCNT               ; for 64 iterations through MVEIT

.BRL1

 LDX #%01111111         ; Set the ship's roll counter to a positive roll that
 STX INWK+29            ; doesn't dampen

 STX INWK+30            ; Set the ship's pitch counter to a positive pitch that
                        ; doesn't dampen

 JSR DrawShipInBitplane ; Flip the drawing bitplane and draw the current ship in
                        ; the newly flipped bitplane

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

 JSR DrawShipInBitplane ; Flip the drawing bitplane and draw the current ship in
                        ; the newly flipped bitplane

 JSR MVEIT              ; Call MVEIT to move and rotate the ship in space

 DEC MCNT               ; Decrease the counter in MCNT

 JMP BRL2               ; Loop back to keep moving the ship up the screen and
                        ; away from us

.BR2

 INC INWK+7             ; Increment z_hi, to keep the ship at the same distance
                        ; as we just incremented z_lo past 255

 LDA #$93               ; Clear the screen and and set the view type in QQ11 to
 JSR TT66               ; $93 (Mission 1 briefing: ship and text)

 LDA #10                ; Set A = 10 so the call to BRP prints extended token 10
                        ; (the briefing for mission 1 where we find out all
                        ; about the stolen Constrictor)

 JMP BRP                ; Jump to BRP to print the extended token in A and show
                        ; the Status Mode screen, returning from the subroutine
                        ; using a tail call

; ******************************************************************************
;
;       Name: BRIS_b0
;       Type: Subroutine
;   Category: Missions
;    Summary: Clear the screen, display "INCOMING MESSAGE" and wait for 2
;             seconds
;
; ******************************************************************************

.BRIS_b0

 LDA #216               ; Print extended token 216 ("{clear screen}{tab 6}{move
 JSR DETOK_b2           ; to row 10, white, lower case}{white}{all caps}INCOMING
                        ; MESSAGE"

 JSR UpdateViewWithFade ; Update the view, fading the screen to black first if
                        ; required

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
;       Name: PlayDemo
;       Type: Subroutine
;   Category: Combat demo
;    Summary: Play the combat demo
;
; ******************************************************************************

.PlayDemo

 JSR RES2               ; Reset a number of flight variables and workspaces

 JSR ResetCommander_b6  ; Reset the current commander to the default "JAMESON"
                        ; commander

 LDA #0                 ; Set the fuel level to zero so we can't hyperspace out
 STA QQ14               ; of the demo

 STA CASH               ; Zero the two lowest bytes of the cash reserves so no
 STA CASH+1             ; missions are triggered

 LDA #$FF               ; Give our ship an E.C.M.
 STA ECM

 LDA #1                 ; Give our ship an energy unit
 STA ENGY

 LDA #POW+128           ; Give our ship a beam laser
 STA LASER

 LDA #$FF               ; Set demoInProgress = $FF to indicate that we are
 STA demoInProgress     ; playing the demo

 JSR SOLAR              ; Set up data blocks and slots for the planet and
                        ; sun

 LDA #0                 ; Set our ship's speed to zero
 STA DELTA

 STA ALPHA              ; Set ALPHA and ALP1 to 0, so our roll angle is 0
 STA ALP1

 STA QQ12               ; Set QQ12 = 0 to indicate that we are not docked

 STA VIEW               ; Set the space view to the front view

 JSR TT66               ; Clear the screen and and set the view type in QQ11 to
                        ; $00 (Space view with no fonts loaded)

 LSR demoInProgress     ; Clear bit 7 of demoInProgress

 JSR CopyNameBuffer0To1 ; Copy the contents of nametable buffer 0 to nametable
                        ; buffer and tell the NMI handler to send pattern
                        ; entries up to the first free tile

 JSR SetupFullViewInNMI ; Configure the PPU to send tiles for the full screen
                        ; during VBlank

 JSR SetupSpaceView     ; Set up the NMI variables for the space view

 JSR FixRandomNumbers   ; Fix the random number seeds to a known value so the
                        ; random numbers generated are always the same when we
                        ; run the demo

 JSR SetupDemoShip      ; Set up the ship workspace for a new ship that's to our
                        ; upper left and in front of us, pointing into the
                        ; screen

 LDA #6                 ; Set the ship's pitch counter to 6 to make it pitch
 STA INWK+30            ; slightly in a positive direction (pitch down), so it
                        ; starts diving gently towards the middle of the screen

 LDA #24                ; Set the ship's roll counter to 24 to make it roll in
 STA INWK+29            ; a positive direction (clockwise), for just under a
                        ; quarter roll (24 * 1/16 radians = 1.5 radians = 86
                        ; degrees)

 LDA #18                ; Call NWSHP with A = 18 to add a new Mamba ship to our
 JSR NWSHP              ; local bubble of universe

 LDA #10                ; Run ten iterations of the main flight loop so the
 JSR RunDemoFlightLoop  ; Mamba flies into the screen for a while

 LDA #$92               ; Set the ship's pitch counter to -18 to make it pitch
 STA K%+2*NIK%+30       ; slightly in a negative direction (pull up), so it
                        ; starts flying gently towards the top-left of the
                        ; screen
                        ;
                        ; The ship will have been spawned in ship slot 2, so
                        ; this directly updates byte #30 in the ship's data
                        ; block in K%, where each data block is NIK% bytes long

 LDA #1                 ; Set the ship's acceleration to 1 to make it accelerate
 STA K%+2*NIK%+28       ; away from us
                        ;
                        ; The ship will have been spawned in ship slot 2, so
                        ; this directly updates byte #28 in the ship's data
                        ; block in K%, where each data block is NIK% bytes long

 JSR SetupDemoShip      ; Set up the ship workspace for a new ship that's to our
                        ; upper left and in front of us, pointing into the
                        ; screen

 LDA #6                 ; Set the ship's pitch counter to 6 to make it pitch
 STA INWK+30            ; slightly in a positive direction (pitch down), so it
                        ; starts diving gently towards the middle of the screen

 ASL INWK+2             ; Flip the sign of x_sign so the ship is now to our
                        ; upper right and in front of us

 LDA #$C0               ; Set the ship's roll counter to -64 to make it roll in
 STA INWK+29            ; a negative direction (anti-clockwise), for two-thirds
                        ; of a roll (64 * 1/16 radians = 4.0 radians = 229
                        ; degrees)

 LDA #KRA               ; Call NWSHP to add a new Krait ship to our local bubble
 JSR NWSHP              ; of universe

 LDA #6                 ; Run six iterations of the main flight loop so the
 JSR RunDemoFlightLoop  ; Krait flies into the screen for a while and the Mamba
                        ; starts to pull away from the middle of the screen

 JSR SetupDemoShip      ; Set up the ship workspace for a new ship that's to our
                        ; upper left and in front of us, pointing into the
                        ; screen

 LDA #6                 ; Set the ship's pitch counter to 6 to make it pitch
 STA INWK+30            ; slightly in a positive direction (pitch down), so it
                        ; starts diving gently towards the middle of the screen

 ASL INWK+2             ; Flip the sign of x_sign so the ship is now to our
                        ; upper right and in front of us

 LDA #0                 ; Set x_lo = 0 so the ship is directly above us
 STA INWK

 LDA #70                ; Set z_lo = 70 so the ship starts out a little further
 STA INWK+6             ; in front than the others

 LDA #SH3               ; Call NWSHP to add a new Sidewinder ship to our local
 JSR NWSHP              ; bubble of universe

 LDA #5                 ; Run five iterations of the main flight loop
 JSR RunDemoFlightLoop  ; Sidewinder flies into the screen for a while

 LDA #$C0               ; Set the ship's pitch counter to -64 to make it pitch
 STA K%+4*NIK%+30       ; strongly in a negative direction (pull up), so it
                        ; starts flying towards the top-middle of the screen
                        ;
                        ; The ship will have been spawned in ship slot 4, so
                        ; this directly updates byte #30 in the ship's data
                        ; block in K%, where each data block is NIK% bytes long

 LDA #11                ; Run 11 iterations of the main flight loop so all three
 JSR RunDemoFlightLoop  ; ships pull away from the centre of the screen

 LDA #50                ; Set the NMI timer so it starts counting down from 50,
 STA nmiTimer           ; so the (nmiTimerHi nmiTimerLo) will tick up to one
                        ; second after 50 VBlanks (which is one second on PAL
                        ; systems or 0.83 seconds on NTSC)

 LDA #0                 ; Set the NMI timer in (nmiTimerHi nmiTimerLo) to zero
 STA nmiTimerLo         ; so we can use it to count how long the combat demo
 STA nmiTimerHi         ; runs for (i.e. how long it takes for us to eliminate
                        ; all three ships)

 JSR SIGHT_b3           ; Draw the laser crosshairs

 LSR allowInSystemJump  ; Clear bit 7 of allowInSystemJump to allow in-system
                        ; jumps, so the call to UpdateIconBar displays the
                        ; fast-forward icon (though choosing this in the demo
                        ; doesn't do an in-system jump, but skips the rest of
                        ; the demo instead)

 JSR UpdateIconBar_b3   ; Update the icon bar to show the correct buttons for
                        ; the weapons we have given our ship (i.e. missiles and
                        ; E.C.M.)

 LDA soundVar06         ; Set soundVar05 = soundVar06 ???
 STA soundVar05

 LDA #16                ; Set our ship's speed to 16, so we start the demo by
 STA DELTA              ; flying forwards

 JMP MLOOP              ; Jump to MLOOP to run the main game loop for the
                        ; duration of the combat demo
                        ;
                        ; Part 15 of the main flight loop contains a check to
                        ; see whether the demo is enabled (which it is) and if
                        ; so, whether we have destroyed all three ships, in
                        ; which case it jumps to ShowScrollText with A = 1 to
                        ; show the scroll text with the results of combat
                        ; practice

; ******************************************************************************
;
;       Name: RunDemoFlightLoop
;       Type: Subroutine
;   Category: Combat demo
;    Summary: Run a fixed number of iterations of the main flight loop for the
;             combat demo
;
; ------------------------------------------------------------------------------
;
; Arguments:
;
;   A                   The number of iterations of the main flight loop to run
;
; ******************************************************************************

.RunDemoFlightLoop

 STA LASCT              ; Store the number of iterations in LASCT so we can
                        ; access it after running the main flight loop

.dlop1

 JSR FlipDrawingPlane   ; Flip the drawing bitplane so we draw into the bitplane
                        ; that isn't visible on-screen

 JSR FlightLoop4To16    ; Display in-flight messages, call parts 4 to 12 of the
                        ; main flight loop for each ship slot, and finish off
                        ; with parts 13 to 16 of the main flight loop

 JSR DrawBitplaneInNMI  ; Configure the NMI to send the drawing bitplane to the
                        ; PPU after drawing the box edges and setting the next
                        ; free tile number

 LDA iconBarChoice      ; Set A to the number of the icon bar button that has
                        ; been chosen from the icon bar (if any)

 JSR CheckForPause      ; If the Start button has been pressed then process the
                        ; pause menu and set the C flag, otherwise clear it

 DEC LASCT              ; Decrement the iteration counter in LASCT

 BNE dlop1              ; Loop back to run the main flight loop again until we
                        ; have run it the required number of times

 RTS                    ; Return from the subroutine

; ******************************************************************************
;
;       Name: SetupDemoShip
;       Type: Subroutine
;   Category: Combat demo
;    Summary: Set up the ship workspace for a new ship in the combat demo
;
; ******************************************************************************

.SetupDemoShip

 JSR ZINF               ; Call ZINF to reset the INWK ship workspace and set up
                        ; the orientation vectors so the ship is pointing
                        ; towards us, out of the screen

 LDA #96                ; Set byte #14 = nosev_z_hi = 96 = 1
 STA INWK+14            ;
                        ; So the ship is pointing into the screen

 ORA #%10000000         ; Flip the sign of A to represent a -1

 STA INWK+22            ; Set byte #22 = sidev_x_hi = -96 = -1
                        ;
                        ; So the ship doesn't get reflected in the x-axis by the
                        ; flipping of the z-coordinate, but is instead rotated
                        ; around the y-axis to point into the screen

 LDA #%11111110         ; Set the ship's byte #32 (AI flag) to %11111110, so it
 STA INWK+32            ; has no E.C.M., is hostile, highly aggressive and has
                        ; AI enabled

 LDA #32                ; Set the ship's byte #27 (speed) to 32
 STA INWK+27

                        ; We now set the ship's coordinates to (-40, 40, 60) so
                        ; it is to our upper left and in front of us

 LDA #%10000000         ; Set (x_sign x_lo) = -40
 STA INWK+2
 LDA #40
 STA INWK

 LDA #40                ; Set y_lo = 40
 STA INWK+3

 LDA #60                ; Set z_lo = 60
 STA INWK+6

 RTS                    ; Return from the subroutine

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
;       Name: SetNewViewType
;       Type: Subroutine
;   Category: Drawing the screen
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

.SetNewViewType

 JSR TT66               ; Clear the screen and set the current view type to A

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
;       Name: xDataOnSystem
;       Type: Variable
;   Category: Universe
;    Summary: The text column for the Data on System title for each language
;
; ******************************************************************************

.xDataOnSystem

 EQUB 9                 ; English

 EQUB 9                 ; German

 EQUB 7                 ; French

 EQUB 9                 ; There is no fourth language, so this byte is ignored

; ******************************************************************************
;
;       Name: PrintTokenAndColon
;       Type: Subroutine
;   Category: Text
;    Summary: Print a character followed by a colon, ensuring that the colon is
;             always drawn in colour 3 on a black background
;
; ------------------------------------------------------------------------------
;
; The colon is printed using font style 3. This draws the colon in colour 3 on
; background colour 0 (i.e. green on black), but without using the normal font.
;
; This ensures that the colon will be drawn in green when the colon's tile falls
; within a 2x2 attribute block that's set to draw white text (i.e. where colour
; 1 is white). This happens in the Status Mode screen in French, and in the Data
; on System screen in all three languages.
;
; Arguments:
;
;   A                   The character to be printed
;
; ******************************************************************************

.PrintTokenAndColon

 JSR TT27_b2            ; Print the character in A

 LDA #3                 ; Set the font style to green text on a black background
 STA fontStyle          ; (colour 3 on background colour 0)

 LDA #':'               ; Print a colon
 JSR TT27_b2

 LDA #1                 ; Set the font style to print in the normal font
 STA fontStyle

 RTS                    ; Return from the subroutine

; ******************************************************************************
;
;       Name: radiusText
;       Type: Variable
;   Category: Universe
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

 LDA #$96               ; Clear the screen and and set the view type in QQ11 to
 JSR SetNewViewType     ; $96 (Data on System)

 JSR TT111              ; Select the system closest to galactic coordinates
                        ; (QQ9, QQ10)

 LDX languageIndex      ; Move the text cursor to the correct column for the
 LDA xDataOnSystem,X    ; Data on System title in the chosen language
 STA XC

 LDA #163               ; Print recursive token 3 ("DATA ON {selected system
 JSR NLIN3              ; name}" on the top row

 JSR TTX69              ; Print a paragraph break and set Sentence Case

 JSR TT146              ; If the distance to this system is non-zero, print
                        ; "DISTANCE", then the distance, "LIGHT YEARS" and a
                        ; paragraph break, otherwise just move the cursor down
                        ; a line

 LDA languageNumber     ; If both bit 1 and bit 2 of languageNumber are clear
 AND #%00000110         ; then the chosen language is English, so jump to dsys1
 BEQ dsys1              ; to skip the following

                        ; If we get here then the chosen language is French or
                        ; German, so we need to print the system economy using
                        ; the PrintTokenAndColon routine to ensure the label is
                        ; in green

 LDA #194               ; Print recursive token 34 ("ECONOMY") followed by
 JSR PrintTokenAndColon ; colon, ensuring that the colon is printed in green
                        ; despite being in a 2x2 attribute block set for white
                        ; text

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

 LDA languageNumber     ; If bit 2 of languageNumber is clear then the chosen
 AND #%00000100         ; language is not French, so jump to dsys3 skip the
 BEQ dsys3              ; following

                        ; If we get here then the chosen language is French, so
                        ; so we need to print the system government using the
                        ; PrintTokenAndColon routine to ensure the label is in
                        ; green

 LDA #162               ; Print recursive token 2 ("GOVERNMENT") followed by
 JSR PrintTokenAndColon ; colon, ensuring that the colon is printed in green
                        ; despite being in a 2x2 attribute block set for white
                        ; text

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

 LDA languageNumber     ; If both bit 0 and bit 2 of languageNumber are clear
 AND #%00000101         ; then the chosen language is not English or German, so
 BEQ dsys6              ; jump to dsys6 skip the following

                        ; If we get here then the chosen language is Engligh or
                        ; German, so so we need to print the system population
                        ; using the PrintTokenAndColon routine to ensure the
                        ; label is in green

 LDA #192               ; Print recursive token 32 ("POPULATION") followed by a
 JSR PrintTokenAndColon ; colon, ensuring that the colon is printed in green
                        ; despite being in a 2x2 attribute block set for white
                        ; text

 JMP dsys7              ; Jump to dsys7 to print the population

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

 LDA languageNumber     ; If bit 1 of languageNumber is set then the chosen
 AND #%00000010         ; language is German, so jump to dsys8 skip the
 BNE dsys8              ; following

                        ; If we get here then the chosen language is French or
                        ; English, so we print the species in brackets

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

 LDA languageNumber     ; If bit 2 of languageNumber is set, then the chosen
 AND #%00000100         ; language is French, so jump to TT75 to print the
 BNE TT75               ; species and then the third adjective, e.g. "Rodents
                        ; Furry"

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

 LDA languageNumber     ; If bit 1 of languageNumber is set then the chosen
 AND #%00000010         ; language is German, so jump to dsys10 skip the
 BNE dsys10             ; following

                        ; If we get here then the chosen language is French or
                        ; English, so we print the species in brackets

 LDA #')'               ; Print a closing bracket
 JSR TT27_b2

.dsys10

 JSR TTX69              ; Print a paragraph break and set Sentence Case

                        ; By this point, ZZ contains the current system number
                        ; which PDESC requires. It gets put there in the TT102
                        ; routine, which calls TT111 to populate ZZ before
                        ; calling TT25 (this routine)

 JSR PDESC_b2           ; Call PDESC to print the system's extended description

 JSR FadeAndHideSprites ; Fade the screen to black and hide all sprites, so we
                        ; can update the screen while it's blacked-out

 LDA #22                ; Move the text cursor to column 22
 STA XC

 LDA #8                 ; Move the text cursor to row 8
 STA YC

 LDA #1                 ; Thess instructions have no effect as the values of K+2
 STA K+2                ; and K+3 get overwritten by the call to DrawSystemImage
 LDA #8
 STA K+3

 LDX #8                 ; Set X = 8 to pass to the call to DrawSystemImage as
                        ; the number of tile columns to draw in the system image

 LDY #7                 ; Set Y = 7 to pass to the call to DrawSystemImage as
                        ; the number of tile rows to draw in the system image

 JSR DrawSystemImage_b3 ; Call DrawSystemImage to draw the system image

 JMP UpdateView         ; Update the view, returning from the subroutine using
                        ; a tail call

; ******************************************************************************
;
;       Name: TT22
;       Type: Subroutine
;   Category: Charts
;    Summary: Show the Long-range Chart
;
; ******************************************************************************

.TT22

 LDA #$8D               ; Clear the screen and and set the view type in QQ11 to
 JSR TT66               ; $8D (Long-range Chart)

 LDA #77                ; Set the screen height variables for a screen height of
 JSR SetScreenHeight    ; 154 (i.e. 2 * 77)

 LDA #7                 ; Move the text cursor to column 7
 STA XC

 JSR TT81               ; Set the seeds in QQ15 to those of system 0 in the
                        ; current galaxy (i.e. copy the seeds from QQ21 to QQ15)

 LDA #199               ; Print recursive token 39 ("GALACTIC CHART{galaxy
 JSR NLIN3              ; number right-aligned to width 3}") on the top row

 LDA #152               ; Draw a screen-wide horizontal line at pixel row 152
 JSR NLIN2              ; for the bottom edge of the chart, so the chart itself
                        ; is 128 pixels high, starting on row 24 and ending on
                        ; row 151

 JSR FadeAndHideSprites ; Fade the screen to black and hide all sprites, so we
                        ; can update the screen while it's blacked-out

 JSR TT14               ; Call TT14 to draw a circle with crosshairs at the
                        ; current system's galactic coordinates

 LDX #0                 ; We're now going to plot each of the galaxy's systems,
                        ; so set up a counter in X for each system, starting at
                        ; 0 and looping through to 255

.TT83

 STX XSAV               ; Store the counter in XSAV

 LDA QQ15+3             ; Fetch the s1_hi seed into A, which gives us the
                        ; galactic x-coordinate of this system

 LSR A                  ; Set X = s1_hi - (A / 4) + 31
 LSR A                  ;       = s1_hi - (s1_hi / 4) + 31
 STA T1                 ;       = 31 + 0.75 * s1_hi
 LDA QQ15+3             ;
 SEC                    ; So this scales the x-coordinate from a range of 0 to
 SBC T1                 ; 255 into a range from 31 to 222, so it fits nicely
 CLC                    ; into the Long-range Chart
 ADC #31
 TAX

 LDY QQ15+4             ; Fetch the s2_lo seed and set bits 4 and 6, storing the
 TYA                    ; result in ZZ to give a random number between 80 and
 ORA #%01010000         ; (but which will always be the same for this system).
 STA ZZ                 ; We use this value to determine the size of the point
                        ; for this system on the chart by passing it as the
                        ; distance argument to the PIXEL routine below

 LDA QQ15+1             ; Fetch the s0_hi seed into A, which gives us the
                        ; galactic y-coordinate of this system

 LSR A                  ; Set A = (s0_hi - (A / 4)) / 2 + 32
 LSR A                  ;       = (s0_hi - (s0_hi / 4)) / 2 + 32
 STA T1                 ;       = 32 + 0.375 * s1_hi
 LDA QQ15+1             ;
 SEC                    ; So this scales the y-coordinate from a range of 0 to
 SBC T1                 ; 255 into a range from 32 to 127, so it fits nicely
 LSR A                  ; into the Long-range Chart
 CLC
 ADC #32

 STA Y1                 ; Store the y-coordinate in Y1 (though this gets
                        ; overwritten by the call to DrawDash, so this has no
                        ; effect)

 JSR DrawDash           ; Draw a 2-pixel dash at pixel coordinate (X, A)

 JSR TT20               ; We want to move on to the next system, so call TT20
                        ; to twist the three 16-bit seeds in QQ15

 LDX XSAV               ; Restore the loop counter from XSAV

 INX                    ; Increment the counter

 BNE TT83               ; If X > 0 then we haven't done all 256 systems yet, so
                        ; loop back up to TT83

 LDA #3                 ; Set K+2 = 3 to pass to DrawSmallBox as the text row
 STA K+2                ; on which to draw the top-left corner of the small box

 LDA #4                 ; Set K+3 = 4 to pass to DrawSmallBox as the text column
 STA K+3                ; on which to draw the top-left corner of the small box

 LDA #25                ; Set K = 25 to pass to DrawSmallBox as the width of the
 STA K                  ; small box

 LDA #14                ; Set K+1 = 14 to pass to DrawSmallBox as the height of
 STA K+1                ; the small box

 JSR DrawSmallBox_b3    ; Draw a box around the chart, with the top-left corner
                        ; at (3, 4), a height of 14 rows, and a width of 25 rows

 LDA QQ9                ; Set QQ19 to the selected system's x-coordinate
 STA QQ19

 LDA QQ10               ; Set QQ19+1 to the selected system's y-coordinate,
 LSR A                  ; halved to fit it into the chart
 STA QQ19+1

 LDA #4                 ; Set QQ19+2 to size 4 for the crosshairs size
 STA QQ19+2

 JSR TT103              ; Draw small crosshairs at coordinates (QQ9, QQ10),
                        ; which will draw the crosshairs at our current home
                        ; system

 LDA #$9D               ; Set the view type in QQ11 to $00 (Long-range Chart
 STA QQ11               ; with the normal font loaded)

 LDA #143               ; Set the number of pixel rows in the space view to 143,
 STA Yx2M1              ; so the screen height is correctly set for the
                        ; Short-range Chart in case we switch to it using the
                        ; icon in the icon bar (which toggles between the two
                        ; charts)

 JMP UpdateView         ; Update the view, returning from the subroutine using
                        ; a tail call

; ******************************************************************************
;
;       Name: TT15
;       Type: Subroutine
;   Category: Drawing lines
;    Summary: Draw a set of crosshairs
;
; ------------------------------------------------------------------------------
;
; For all views except the Short-range Chart, the centre is drawn 24 pixels to
; the right of the y-coordinate given.
;
; Arguments:
;
;   QQ19                The pixel x-coordinate of the centre of the crosshairs
;
;   QQ19+1              The pixel y-coordinate of the centre of the crosshairs
;
;   QQ19+2              The size of the crosshairs
;
; ******************************************************************************

.TT15

 LDA #24                ; Set A to 24, which we will use as the minimum
                        ; screen indent for the crosshairs (i.e. the minimum
                        ; distance from the top-left corner of the screen)

 LDX QQ11               ; If the current view is not the Short-range Chart,
 CPX #$9C               ; which is view type $9C, then jump to TT178 to skip the
 BNE TT178              ; following instruction

 LDA #0                 ; This is the Short-range Chart, so set A to 0, so the
                        ; crosshairs can go right up against the screen edges

.TT178

 STA QQ19+5             ; Set QQ19+5 to A, which now contains the correct indent
                        ; for this view

 LDA QQ19               ; Set A = crosshairs x-coordinate - crosshairs size
 SEC                    ; to get the x-coordinate of the left edge of the
 SBC QQ19+2             ; crosshairs

 BCS TT84               ; If the above subtraction didn't underflow, then A is
                        ; positive, so skip the next instruction

 LDA #0                 ; The subtraction underflowed, so set A to 0 so the
                        ; crosshairs don't spill out of the left of the screen

.TT84

                        ; In the following, the authors have used XX15 for
                        ; temporary storage. XX15 shares location with X1, Y1,
                        ; X2 and Y2, so in the following, you can consider
                        ; the variables like this:
                        ;
                        ;   XX15   is the same as X1
                        ;   XX15+1 is the same as Y1
                        ;   XX15+2 is the same as X2
                        ;   XX15+3 is the same as Y2
                        ;
                        ; Presumably this routine was written at a different
                        ; time to the line-drawing routine, before the two
                        ; workspaces were merged to save space

 STA XX15               ; Set XX15 (X1) = A (the x-coordinate of the left edge
                        ; of the crosshairs)

 LDA QQ19               ; Set A = crosshairs x-coordinate + crosshairs size
 CLC                    ; to get the x-coordinate of the right edge of the
 ADC QQ19+2             ; crosshairs

 BCC P%+4               ; If the above addition didn't overflow, then A is
                        ; correct, so skip the next instruction

 LDA #255               ; The addition overflowed, so set A to 255 so the
                        ; crosshairs don't spill out of the right of the screen
                        ; (as 255 is the x-coordinate of the rightmost pixel
                        ; on-screen)

 STA XX15+2             ; Set XX15+2 (X2) = A (the x-coordinate of the right
                        ; edge of the crosshairs)

 LDA QQ19+1             ; Set XX15+1 (Y1) = crosshairs y-coordinate + indent
 CLC                    ; to get the y-coordinate of the centre of the
 ADC QQ19+5             ; crosshairs
 STA XX15+1

 STA XX15+3             ; Set XX15+3 (Y2) = crosshairs y-coordinate + indent

 JSR LOIN               ; Draw a line from (X1, Y1) to (X2, Y2), where Y1 = Y2,
                        ; which will draw from the left edge of the crosshairs
                        ; to the right edge, through the centre of the
                        ; crosshairs

 LDA QQ19+1             ; Set A = crosshairs y-coordinate - crosshairs size
 SEC                    ; to get the y-coordinate of the top edge of the
 SBC QQ19+2             ; crosshairs

 BCS TT86               ; If the above subtraction didn't underflow, then A is
                        ; correct, so skip the next instruction

 LDA #0                 ; The subtraction underflowed, so set A to 0 so the
                        ; crosshairs don't spill out of the top of the screen

.TT86

 CLC                    ; Set XX15+1 (Y1) = A + indent to get the y-coordinate
 ADC QQ19+5             ; of the top edge of the indented crosshairs
 STA XX15+1

 LDA QQ19+1             ; Set A = crosshairs y-coordinate + crosshairs size
 CLC                    ; + indent to get the y-coordinate of the bottom edge
 ADC QQ19+2             ; of the indented crosshairs
 ADC QQ19+5

 CMP #152               ; If A < 152 then skip the following, as the crosshairs
 BCC TT87               ; won't spill out of the bottom of the screen

 LDX QQ11               ; A >= 152, so we need to check whether this will fit in
                        ; this view, so fetch the view type

 CPX #$9C               ; If this is the Short-range Chart then the y-coordinate
 BEQ TT87               ; is fine, so skip to TT87

 LDA #151               ; Otherwise this is the Long-range Chart, so we need to
                        ; clip the crosshairs at a maximum y-coordinate of 151

.TT87

 STA XX15+3             ; Set XX15+3 (Y2) = A (the y-coordinate of the bottom
                        ; edge of the crosshairs)

 LDA QQ19               ; Set XX15 (X1) = the x-coordinate of the centre of the
 STA XX15               ; crosshairs

 STA XX15+2             ; Set XX15+2 (X2) = the x-coordinate of the centre of
                        ; the crosshairs

 JMP LOIN               ; Draw a vertical line (X1, Y1) to (X2, Y2), which will
                        ; draw from the top edge of the crosshairs to the bottom
                        ; edge, through the centre of the crosshairs, returning
                        ; from the subroutine using a tail call

; ******************************************************************************
;
;       Name: TT14
;       Type: Subroutine
;   Category: Drawing circles
;    Summary: Draw a circle with crosshairs on a chart
;
; ------------------------------------------------------------------------------
;
; Draw a circle with crosshairs at the current system's galactic coordinates.
;
; ******************************************************************************

.TT126

 LDA #104               ; Set QQ19 = 104, for the x-coordinate of the centre of
 STA QQ19               ; the fixed circle on the Short-range Chart

 LDA #90                ; Set QQ19+1 = 90, for the y-coordinate of the centre of
 STA QQ19+1             ; the fixed circle on the Short-range Chart

 LDA #16                ; Set QQ19+2 = 16, the size of the crosshairs on the
 STA QQ19+2             ; Short-range Chart

 JSR TT15               ; Draw the set of crosshairs defined in QQ19, at the
                        ; exact coordinates as this is the Short-range Chart

 LDA QQ14               ; Set K = QQ14 + (QQ14 / 32)
 LSR A                  ;
 LSR A                  ; So K is the circle's radius, based on the fuel level
 LSR A                  ; in QQ14 ???
 LSR A
 LSR A
 ADC QQ14
 STA K

 JMP TT128              ; Jump to TT128 to draw a circle with the centre at the
                        ; same coordinates as the crosshairs, (QQ19, QQ19+1),
                        ; and radius K that reflects the current fuel levels,
                        ; returning from the subroutine using a tail call

.TT14

 LDA QQ11               ; If the view type in QQ11 is $9C (Short-range Chart),
 CMP #$9C               ; jump up to TT126 to draw the crosshairs and circle for
 BEQ TT126              ; that view

                        ; Otherwise this is the Long-range Chart, so we draw the
                        ; crosshairs and circle for that view instead

 LDA QQ14               ; Set K = QQ14/4 - QQ14/16
 LSR A                  ;       = 0.1875 * QQ14
 LSR A                  ;
 STA K                  ; So K scales the fuel level in QQ14 to act as the
 LSR A                  ; circle's radius, scaling the fuel level from a range
 LSR A                  ; of 0 to 70 down to a range of 0 to 13 ???
 STA T1
 LDA K
 SEC
 SBC T1
 STA K

                        ; We now set the pixel coordinates of the crosshairs in
                        ; QQ9 and QQ9+1 so they fit into the chart, with a
                        ; 31-pixel margin on the left and an 8-pixel margin at
                        ; the top (to which we will add another 24 pixels below)
                        ;
                        ; The Long-range Chart is twice as wide as it is high,
                        ; so we need to scale the y-coordinate in QQ19+1 by an
                        ; extra division by 2 when compared to the x-coordinate

 LDA QQ0                ; Set QQ19 = 31 + QQ9 - (QQ9 / 4)
 LSR A                  ;          = 31 + 0.75 * QQ9
 LSR A                  ;
 STA T1                 ; So this scales the x-coordinate from a range of 0 to
 LDA QQ0                ; 255 into a range from 31 to 222, so it fits nicely
 SEC                    ; into the Long-range Chart
 SBC T1
 CLC
 ADC #31
 STA QQ19

 LDA QQ1                ; Set QQ19+1 = 8 + (QQ10 - (QQ10 / 4)) / 2
 LSR A                  ;            = 8 + 0.375 * QQ10
 LSR A                  ;
 STA T1                 ; So this scales the y-coordinate from a range of 0 to
 LDA QQ1                ; 255 into a range from 8 to 127, so it fits nicely
 SEC                    ; into the Long-range Chart
 SBC T1
 LSR A
 CLC
 ADC #8
 STA QQ19+1

 LDA #7                 ; Set QQ19+2 = 7, the size of the crosshairs on the
 STA QQ19+2             ; Long-range Chart

 JSR TT15               ; Draw the set of crosshairs defined in QQ19, which will
                        ; be drawn 24 pixels to the right of QQ19+1

 LDA QQ19+1             ; Add 24 to the y-coordinate of the crosshairs in QQ19+1
 CLC                    ; so that the centre of the circle matches the centre
 ADC #24                ; of the crosshairs
 STA QQ19+1

                        ; Fall through into TT128 to draw a circle with the
                        ; centre at the same coordinates as the crosshairs,
                        ; (QQ19, QQ19+1), and radius K that reflects the
                        ; current fuel levels

; ******************************************************************************
;
;       Name: TT128
;       Type: Subroutine
;   Category: Drawing circles
;    Summary: Draw a circle on a chart
;  Deep dive: Drawing circles
;
; ------------------------------------------------------------------------------
;
; Draw a circle with the centre at (QQ19, QQ19+1) and radius K.
;
; Arguments:
;
;   QQ19                The x-coordinate of the centre of the circle
;
;   QQ19+1              The y-coordinate of the centre of the circle
;
;   K                   The radius of the circle
;
; ******************************************************************************

.TT128

 LDA QQ19               ; Set K3 = the x-coordinate of the centre
 STA K3

 LDA QQ19+1             ; Set K4 = the y-coordinate of the centre
 STA K4

 LDX #0                 ; Set the high bytes of K3(1 0) and K4(1 0) to 0
 STX K4+1
 STX K3+1

 LDX #2                 ; Set STP = 2, the step size for the circle
 STX STP

 LDX #1                 ; Set the high byte of the pattern buffer address
 JSR SetPatternBuffer   ; variables to that of pattern buffer 1, so the circle
                        ; gets drawn into bitplane 1 only, giving a circle of
                        ; colour %10 (2), which is green

 JMP CIRCLE2_b1         ; Jump to CIRCLE2 to draw a circle with the centre at
                        ; (K3(1 0), K4(1 0)) and radius K, returning from the
                        ; subroutine using a tail call

; ******************************************************************************
;
;       Name: TT210
;       Type: Subroutine
;   Category: Inventory
;    Summary: Show a list of current cargo in our hold, optionally to sell
;
; ------------------------------------------------------------------------------
;
; Show a list of current cargo in our hold, either with the ability to sell (the
; Sell Cargo screen) or without (the Inventory screen), depending on the current
; view.
;
; Arguments:
;
;   QQ11                The current view:
;
;                           * 4 = Sell Cargo
;
;                           * 8 = Inventory
;
; ******************************************************************************

.TT210

 LDY #0                 ; We're going to loop through all the available market
                        ; items and check whether we have any in the hold (and,
                        ; if we are in the Sell Cargo screen, whether we want
                        ; to sell any items), so we set up a counter in Y to
                        ; denote the current item and start it at 0

.TT211

 SETUP_PPU_FOR_ICON_BAR ; If the PPU has started drawing the icon bar, configure
                        ; the PPU to use nametable 0 and pattern table 0

 STY QQ29               ; Store the current item number in QQ29

 LDX QQ20,Y             ; Fetch into X the amount of the current item that we
 BEQ TT212              ; have in our cargo hold, which is stored in QQ20+Y,
                        ; and if there are no items of this type in the hold,
                        ; jump down to TT212 to skip to the next item

 TYA                    ; Set Y = Y * 4, so this will act as an index into the
 ASL A                  ; market prices table at QQ23 for this item (as there
 ASL A                  ; are four bytes per item in the table)
 TAY

 LDA QQ23+1,Y           ; Fetch byte #1 from the market prices table for the
 STA QQ19+1             ; current item and store it in QQ19+1, for use by the
                        ; call to TT152 below

 TXA                    ; Store the amount of item in the hold (in X) on the
 PHA                    ; stack

 JSR TT69               ; Call TT69 to set Sentence Case and print a newline

 CLC                    ; Print recursive token 48 + QQ29, which will be in the
 LDA QQ29               ; range 48 ("FOOD") to 64 ("ALIEN ITEMS"), so this
 ADC #208               ; prints the current item's name
 JSR TT27_b2

 LDA #14                ; Move the text cursor to column 14, for the item's
 STA XC                 ; quantity

 PLA                    ; Restore the amount of item in the hold into X
 TAX

 STA QQ25               ; Store the amount of this item in the hold in QQ25

 CLC                    ; Print the 8-bit number in X to 3 digits, without a
 JSR pr2                ; decimal point

 JSR TT152              ; Print the unit ("t", "kg" or "g") for the market item
                        ; whose byte #1 from the market prices table is in
                        ; QQ19+1 (which we set up above)

.TT212

 LDY QQ29               ; Fetch the item number from QQ29 into Y, and increment
 INY                    ; Y to point to the next item

 CPY #17                ; Loop back to TT211 to print the next item in the hold
 BCC TT211              ; until Y = 17 (at which point we have done the last
                        ; item)

 JSR TT69               ; Call TT69 to set Sentence Case and print a newline

 LDA TRIBBLE            ; If there are any Trumbles in the hold, skip the
 ORA TRIBBLE+1          ; following RTS and continue on (in the Master version,
 BNE P%+5               ; there are never any Trumbles, so this value will
                        ; always be zero)

.zebra

 JMP UpdateViewWithFade ; There are no Trumbles in the hold, so update the view,
                        ; fading the screen to black first if required, and
                        ; return from the subroutine using a tail call

                        ; If we get here then we have Trumbles in the hold, so
                        ; we print out the number of Trumbles and a random
                        ; adjective

 CLC                    ; Clear the C flag, so the call to TT11 below doesn't
                        ; include a decimal point

 LDA #0                 ; Set A = 0, for the call to TT11 below, so we don't pad
                        ; out the number of Trumbles

 LDX TRIBBLE            ; Fetch the number of Trumbles into (Y X)
 LDY TRIBBLE+1

 JSR TT11               ; Call TT11 to print the number of Trumbles in (Y X),
                        ; with no decimal point

 LDA languageNumber     ; If bit 2 of languageNumber is set then the chosen
 AND #%00000100         ; language is French, so jump to carg1 to skip printing
 BNE carg1              ; the Trumble adjectives

 JSR DORND              ; Print out a random extended token from 111 to 114,
 AND #3                 ; (" CUDDLY", " CUTE", " FURRY" or " FRIENDLY")
 CLC
 ADC #111
 JSR DETOK_b2

 LDA languageNumber     ; If bit 1 of languageNumber is clear then the chosen
 AND #%00000010         ; language is not German, so jump to carg1 to skip the
 BEQ carg1              ; following

 LDA TRIBBLE            ; If the number of Trumbles in TRIBBLE(1 0) is more than
 AND #%11111110         ; one, jump to carg1 to skip the following
 ORA TRIBBLE+1
 BEQ carg1

 LDA #'e'               ; Print an 'e' to pluralise the adjective in German
 JSR DASC_b2

.carg1

 LDA #198               ; Print extended token 198 (" LITTLE {single
 JSR DETOK_b2           ; cap}SQUEAKY"

 LDA TRIBBLE+1          ; If we have more than 256 Trumbles, skip to DOANS
 BNE DOANS

 LDX TRIBBLE            ; If we have exactly one Trumble, jump up to zebra
 DEX
 BEQ zebra

.DOANS

 LDA #'s'               ; We have more than one Trumble, so print an 's' and
 JSR DASC_b2            ; jump up to zebra
 JMP zebra

; ******************************************************************************
;
;       Name: TT213
;       Type: Subroutine
;   Category: Inventory
;    Summary: Show the Inventory screen
;
; ******************************************************************************

.TT213

 LDA #$97               ; Clear the screen and and set the view type in QQ11 to
 JSR SetNewViewType     ; $97 (Inventory)

 LDA #11                ; Move the text cursor to column 11 to print the screen
 STA XC                 ; title

 LDA #164               ; Print recursive token 4 ("INVENTORY{crlf}") followed
 JSR TT60               ; by a paragraph break and Sentence Case

 JSR NLIN4              ; Draw a horizontal line on tile row 2 to box in the
                        ; title

 JSR fwl                ; Call fwl to print the fuel and cash levels on two
                        ; separate lines

 LDA CRGO               ; If our ship's cargo capacity is < 26 (i.e. we do not
 CMP #26                ; have a cargo bay extension), jump to inve1 to skip the
 BCC inve1              ; following

 LDA #12                ; Print a newline
 JSR TT27_b2

 LDA #107               ; We do have a cargo bay extension, so print recursive
 JSR TT27_b2            ; token 107 ("LARGE CARGO{sentence case} BAY")

 JMP TT210              ; Jump to TT210 to print the contents of our cargo bay
                        ; and return from the subroutine using a tail call

.inve1

 JSR TT67               ; Print a newline

 JMP TT210              ; Jump to TT210 to print the contents of our cargo bay
                        ; and return from the subroutine using a tail call

; ******************************************************************************
;
;       Name: PrintCharacter
;       Type: Subroutine
;   Category: Text
;    Summary: An unused routine that prints a character and sets the C flag
;
; ******************************************************************************

.PrintCharacter

 JSR DASC_b2            ; Print the character in A

 SEC                    ; Set the C flag

 RTS                    ; Return from the subroutine

; ******************************************************************************
;
;       Name: TT16
;       Type: Subroutine
;   Category: Charts
;    Summary: Move the crosshairs on a chart
;
; ------------------------------------------------------------------------------
;
; Move the chart crosshairs by the amount in X and Y.
;
; Arguments:
;
;   X                   The amount to move the crosshairs in the x-axis
;
;   Y                   The amount to move the crosshairs in the y-axis
;
; ******************************************************************************

.cros1

 JMP SetSelectedSystem  ; Jump to SetSelectedSystem to update the message on
                        ; the chart that shows the current system, returning
                        ; from the subroutine using a tail call

.TT16

 LDA controller1B       ; If the B button is being pressed, jump to cros1 to
 BMI cros1              ; return from the subroutine, as the arrow buttons have
                        ; a different meaning when the B button is held down

 LDA controller1Left03  ; If none of the directional buttons have been held down
 ORA controller1Right03 ; in the last four VBlanks, jump to cros1 to return from
 ORA controller1Up      ; the subroutine, as we don't need to move the
 ORA controller1Down    ; crosshairs
 AND #%11110000
 BEQ cros1

 TXA                    ; Push the change in X onto the stack (let's call this
 PHA                    ; the x-delta)

 BNE mvcr1              ; If the x-delta is non-zero, jump to mvcr1 to update
                        ; the icon bar if required

 TYA                    ; If the y-delta is zero, then the crosshairs are not
 BEQ mvcr2              ; moving, so jump to mvcr2 to skip the following,
                        ; otherwise keep going to update the icon bar if
                        ; required

.mvcr1

                        ; If we get here then the crosshairs are on the move

 LDX #%00000000         ; Set X to use as the new value of selectedSystemFlag
                        ; below

 LDA selectedSystemFlag ; Set A to the value of selectedSystemFlag

 STX selectedSystemFlag ; Clear bits 6 and 7 of selectedSystemFlag to indicate
                        ; that there is no currently selected system

 ASL A                  ; If bit 6 of selectedSystemFlag was previously clear,
 BPL mvcr2              ; then before the crosshairs moved we weren't locked
                        ; onto a system that we could hyperspace to, so the
                        ; hyperspace button wouldn't have been showing on the
                        ; icon bar, so jump to mvcr2 to skip the following as
                        ; we don't need to update the icon bar

 TYA                    ; Update the icon bar to remove the hyperspace button
 PHA                    ; now that the crosshairs are no longer pointing to
 JSR UpdateIconBar_b3   ; that system, preserving Y across the subroutine call
 PLA
 TAY

.mvcr2

 DEY                    ; Negate the change in Y and push it onto the stack
 TYA                    ; (let's call this the y-delta)
 EOR #$FF
 PHA

 LDA QQ11               ; If the view type in QQ11 is $9C (Short-range Chart),
 CMP #$9C               ; jump to hair1 to skip the following
 BEQ hair1

                        ; This is not the Short-range Chart, so it must be the
                        ; Long-range Chart, so we double the x-delta and y-delta
                        ; so the crosshairs move twice as fast

 PLA                    ; Set X to the y-delta from the top of the stack
 TAX

 PLA                    ; Fetch the x-delta from the top of the stack, double it
 ASL A                  ; and put it back
 PHA

 TXA                    ; Double the y-delta value in X and put it back on the
 ASL A                  ; stack
 PHA

.hair1

 JSR WaitForNMI         ; Wait until the next NMI interrupt has passed (i.e. the
                        ; next VBlank)

 PLA                    ; Store the y-delta in QQ19+3 and fetch the current
 STA QQ19+3             ; y-coordinate of the crosshairs from QQ10 into A, ready
 LDA QQ10               ; for the call to TT123

 JSR TT123              ; Call TT123 to move the selected system's galactic
                        ; y-coordinate by the y-delta, putting the new value in
                        ; QQ19+4

 LDA QQ19+4             ; Store the updated y-coordinate in QQ10 (the current
 STA QQ10               ; y-coordinate of the crosshairs)

 STA QQ19+1             ; This instruction has no effect, as QQ19+1 is
                        ; overwritten below, both in TT103 and TT105

 PLA                    ; Store the x-delta in QQ19+3 and fetch the current
 STA QQ19+3             ; x-coordinate of the crosshairs from QQ10 into A, ready
 LDA QQ9                ; for the call to TT123

 JSR TT123              ; Call TT123 to move the selected system's galactic
                        ; x-coordinate by the x-delta, putting the new value in
                        ; QQ19+4

 LDA QQ19+4             ; Store the updated x-coordinate in QQ9 (the current
 STA QQ9                ; x-coordinate of the crosshairs)

 STA QQ19               ; This instruction has no effect, as QQ19 is overwritten
                        ; below, both in TT103 and TT105

                        ; Now we've updated the coordinates of the crosshairs,
                        ; fall through into TT103 to redraw them at their new
                        ; location

; ******************************************************************************
;
;       Name: TT103
;       Type: Subroutine
;   Category: Charts
;    Summary: Draw a small set of crosshairs on a chart
;
; ------------------------------------------------------------------------------
;
; Draw a small set of crosshairs on a galactic chart at the coordinates in
; (QQ9, QQ10).
;
; This routine does a similar job to the routine of the same name in the BBC
; Master version of Elite, but the code is significantly different.
;
; ******************************************************************************

.TT103

 LDA QQ11               ; Fetch the current view type into A

 CMP #$9C               ; If the view type in QQ11 is $9C (Short-range Chart),
 BEQ TT105              ; jump to TT105 to draw the correct crosshairs for that
                        ; chart

                        ; We now set the pixel coordinates of the crosshairs in
                        ; QQ9 and QQ9+1 so they fit into the chart, with a
                        ; 31-pixel margin on the left and a 32-pixel margin at
                        ; the top, for the chart title
                        ;
                        ; The Long-range Chart is twice as wide as it is high,
                        ; so we need to scale the y-coordinate in QQ19+1 by an
                        ; extra division by 2 when compared to the x-coordinate

 LDA QQ9                ; Set QQ19 = 31 + QQ9 - (QQ9 / 4)
 LSR A                  ;          = 31 + 0.75 * QQ9
 LSR A                  ;
 STA T1                 ; So this scales the x-coordinate from a range of 0 to
 LDA QQ9                ; 255 into a range from 31 to 222, so it fits nicely
 SEC                    ; into the Long-range Chart
 SBC T1
 CLC
 ADC #31
 STA QQ19

 LDA QQ10               ; Set QQ19+1 = 32 + (QQ10 - (QQ10 / 4)) / 2
 LSR A                  ;            = 32 + 0.375 * QQ10
 LSR A                  ;
 STA T1                 ; So this scales the y-coordinate from a range of 0 to
 LDA QQ10               ; 255 into a range from 8 to 127, so it fits nicely
 SEC                    ; into the Long-range Chart
 SBC T1
 LSR A
 CLC
 ADC #32
 STA QQ19+1

 LDA #4                 ; Set QQ19+2 to 4 denote crosshairs of size 4 (though
 STA QQ19+2             ; this is ignored by DrawCrosshairs, which always draws
                        ; the crosshairs as a single-tile square reticle)

 JMP DrawCrosshairs     ; Jump to TT15 to draw a square reticle at the
                        ; crosshairs coordinates, returning from the
                        ; subroutine using a tail call

; ******************************************************************************
;
;       Name: TT123
;       Type: Subroutine
;   Category: Charts
;    Summary: Move galactic coordinates by a signed delta
;
; ------------------------------------------------------------------------------
;
; Move an 8-bit galactic coordinate by a certain distance in either direction
; (i.e. a signed 8-bit delta), but only if it doesn't cause the coordinate to
; overflow. The coordinate is in a single axis, so it's either an x-coordinate
; or a y-coordinate.
;
; Arguments:
;
;   A                   The galactic coordinate to update
;
;   QQ19+3              The delta (can be positive or negative)
;
; Returns:
;
;   QQ19+4              The updated coordinate after moving by the delta (this
;                       will be 1 or 255 if moving by the delta underflows or
;                       overflows)
;
; Other entry points:
;
;   TT180               Contains an RTS
;
; ******************************************************************************

.TT123

 CLC                    ; Set A = A + QQ19+3, so A now contains the original
 ADC QQ19+3             ; coordinate, moved by the delta

 LDX QQ19+3             ; If the delta is negative, jump to TT124
 BMI TT124

 BCC TT125              ; If the C flag is clear, then the above addition didn't
                        ; overflow, so jump to TT125 to return the updated value

 LDA #255               ; Otherwise set A to 255 and jump to TT125 to return
 BNE TT125              ; this as the updated value

.TT124

 BCS TT125              ; If the C flag is set, then because the delta is
                        ; negative, this indicates the addition (which is
                        ; effectively a subtraction) didn't underflow, so jump
                        ; to TT125 to return this as the updated value

 LDA #1                 ; The subtraction underflowed, so set A to 1 to return
                        ; as the updated value

.TT125

 STA QQ19+4             ; Store the updated coordinate in QQ19+4

.TT180

 RTS                    ; Return from the subroutine

; ******************************************************************************
;
;       Name: TT105
;       Type: Subroutine
;   Category: Charts
;    Summary: Draw crosshairs on the Short-range Chart, with clipping
;
; ------------------------------------------------------------------------------
;
; Check whether the crosshairs are close enough to the current system to appear
; on the Short-range Chart, and if so, draw them.
;
; ******************************************************************************

.TT105

 LDA QQ9                ; Set A = QQ9 - QQ0, the horizontal distance between the
 SEC                    ; crosshairs (QQ9) and the current system (QQ0)
 SBC QQ0

 CMP #36                ; If the horizontal distance in A < 36, then the
 BCC TT179              ; crosshairs are close enough to the current system to
                        ; appear in the Short-range Chart, so jump to TT179 to
                        ; check the vertical distance

 CMP #233               ; If the horizontal distance in A < -23, then the
 BCC HideCrosshairs     ; crosshairs are too far from the current system to
                        ; appear in the Short-range Chart, so jump to
                        ; HideCrosshairs to hide the crosshairs and return from
                        ; the subroutine using a tail call

.TT179

 ASL A                  ; Set QQ19 = 104 + A * 4
 ASL A                  ;
 CLC                    ; 104 is the x-coordinate of the centre of the chart,
 ADC #104               ; so this sets QQ19 to the screen pixel x-coordinate
 STA QQ19               ; of the crosshairs

 LDA QQ10               ; Set A = QQ10 - QQ1, the vertical distance between the
 SEC                    ; crosshairs (QQ10) and the current system (QQ1)
 SBC QQ1

 CMP #38                ; If the vertical distance in A is < 38, then the
 BCC P%+6               ; crosshairs are close enough to the current system to
                        ; appear in the Short-range Chart, so skip the next two
                        ; instructions

 CMP #220               ; If the horizontal distance in A is < -36, then the
 BCC HideCrosshairs     ; crosshairs are too far from the current system to
                        ; appear in the Short-range Chart, so jump to
                        ; HideCrosshairs to hide the crosshairs and return from
                        ; the subroutine using a tail call

 ASL A                  ; Set QQ19+1 = 90 + A * 2
 CLC                    ;
 ADC #90                ; 90 is the y-coordinate of the centre of the chart,
 STA QQ19+1             ; so this sets QQ19+1 to the screen pixel x-coordinate
                        ; of the crosshairs

 LDA #8                 ; Set QQ19+2 to 8 denote crosshairs of size 8
 STA QQ19+2

                        ; Fall through into DrawCrosshairs to draw crosshairs of
                        ; size 8 at the crosshairs coordinates

; ******************************************************************************
;
;       Name: DrawCrosshairs
;       Type: Subroutine
;   Category: Charts
;    Summary: Draw a set of moveable crosshairs as a square reticle
;
; ------------------------------------------------------------------------------
;
; Arguments:
;
;   QQ19                The pixel x-coordinate of the centre of the crosshairs
;
;   QQ19+1              The pixel y-coordinate of the centre of the crosshairs
;
; ******************************************************************************

.DrawCrosshairs

 LDA #248               ; Set the tile pattern number for sprite 15 to 248,
 STA tileSprite15       ; which contains a one-tile square outline that we can
                        ; use as a square reticle to implement crosshairs on the
                        ; chart

 LDA #%00000001         ; Set the attributes for sprite 15 as follows:
 STA attrSprite15       ;
                        ;   * Bits 0-1    = sprite palette 1
                        ;   * Bit 5 clear = show in front of background
                        ;   * Bit 6 clear = do not flip horizontally
                        ;   * Bit 7 clear = do not flip vertically

 LDA QQ19               ; Set SC2 to the pixel x-coordinate of the centre of the
 STA SC2                ; crosshairs

 LDY QQ19+1             ; Set Y to the pixel y-coordinate of the centre of the
                        ; crosshairs

 LDA #15                ; Set X = 15 * 4, so X is the index of sprite 15 within
 ASL A                  ; the sprite buffer, as each sprite takes up four bytes
 ASL A                  ; (in other words, xSprite0 + X and ySprite0 + X are the
 TAX                    ; addresses of the x- and y-coordinates of sprite 15 in
                        ; the sprite buffer)

 LDA SC2                ; Set the pixel x-coordinate of sprite 15 to SC2 - 4
 SEC                    ;
 SBC #4                 ; So the centre of the square reticle in sprite 15 is at
 STA xSprite0,X         ; x-coordinate SC2, as the reticle is eight pixels wide

 TYA                    ; Set the pixel y-coordinate of sprite 15 to Y + 10
 CLC                    ;
 ADC #10+YPAL           ; So the reticle is drawn 10 pixels below the coordinate
 STA ySprite0,X         ; in the QQ19+1 argument (this takes the 14-pixel high
                        ; chart title into consideration, and ensures that the
                        ; centre of the reticle is over the correct coordinates
                        ; as the sprite is eight pixels high)

 RTS                    ; Return from the subroutine

; ******************************************************************************
;
;       Name: HideCrosshairs
;       Type: Subroutine
;   Category: Charts
;    Summary: Hide the moveable crosshairs (i.e. the square reticle)
;
; ******************************************************************************

.HideCrosshairs

 LDA #240               ; Set the y-coordinate of sprite 15 to 240, so it is
 STA ySprite15          ; below the bottom of the screen and is therefore hidden

 RTS                    ; Return from the subroutine

; ******************************************************************************
;
;       Name: xShortRange
;       Type: Variable
;   Category: Charts
;    Summary: The text column for the Short-range Chart title for each language
;
; ******************************************************************************

.xShortRange

 EQUB 7                 ; English

 EQUB 8                 ; German

 EQUB 10                ; French

 EQUB 8                 ; There is no fourth language, so this byte is ignored

; ******************************************************************************
;
;       Name: TT23
;       Type: Subroutine
;   Category: Charts
;    Summary: Show the Short-range Chart
;
; ******************************************************************************

.TT23

 LDA #0                 ; Set systemsOnChart = 0 so we can use it to count the
 STA systemsOnChart     ; systems as we add them to the chart

 LDA #199               ; Set the number of pixel rows in the space view to 199,
 STA Yx2M1              ; to cover the size of the chart part of the Short-range
                        ; Chart view

 LDA #$9C               ; Clear the screen and and set the view type in QQ11 to
 JSR TT66               ; $9C (Short-range Chart)

 LDX languageIndex      ; Move the text cursor to the correct column for the
 LDA xShortRange,X      ; Short-range Chart title in the chosen language
 STA XC

 LDA #190               ; Print recursive token 30 ("SHORT RANGE CHART") on the
 JSR NLIN3              ; top row

 JSR SetScreenForUpdate ; Get the screen ready for updating by hiding all
                        ; sprites, after fading the screen to black if we are
                        ; changing view

 JSR TT14               ; Call TT14 to draw a circle with crosshairs at the
                        ; current system's galactic coordinates

 JSR TT103              ; Draw small crosshairs at coordinates (QQ9, QQ10),
                        ; i.e. at the selected system

 JSR TT81               ; Set the seeds in QQ15 to those of system 0 in the
                        ; current galaxy (i.e. copy the seeds from QQ21 to QQ15)

 LDA #0                 ; Set A = 0, which we'll use below to zero out the INWK
                        ; workspace

 STA XX20               ; We're about to start working our way through each of
                        ; the galaxy's systems, so set up a counter in XX20 for
                        ; each system, starting at 0 and looping through to 255

 LDX #24                ; First, though, we need to zero out the 25 bytes at
                        ; INWK so we can use them to work out which systems have
                        ; room for a label, so set a counter in X for 25 bytes

.EE3

 STA INWK,X             ; Set the X-th byte of INWK to zero

 DEX                    ; Decrement the counter

 BPL EE3                ; Loop back to EE3 for the next byte until we've zeroed
                        ; all 25 bytes

                        ; We now loop through every single system in the galaxy
                        ; and check the distance from the current system whose
                        ; coordinates are in (QQ0, QQ1). We get the galactic
                        ; coordinates of each system from the system's seeds,
                        ; like this:
                        ;
                        ;   x = s1_hi (which is stored in QQ15+3)
                        ;   y = s0_hi (which is stored in QQ15+1)
                        ;
                        ; so the following loops through each system in the
                        ; galaxy in turn and calculates the distance between
                        ; (QQ0, QQ1) and (s1_hi, s0_hi) to find the closest one

.TT182

 SETUP_PPU_FOR_ICON_BAR ; If the PPU has started drawing the icon bar, configure
                        ; the PPU to use nametable 0 and pattern table 0

 LDA QQ15+3             ; Set A = s1_hi - QQ0, the horizontal distance between
 SEC                    ; (s1_hi, s0_hi) and (QQ0, QQ1)
 SBC QQ0

 BCS TT184              ; If a borrow didn't occur, i.e. s1_hi >= QQ0, then the
                        ; result is positive, so jump to TT184 and skip the
                        ; following two instructions

 EOR #$FF               ; Otherwise negate the result in A, so A is always
 ADC #1                 ; positive (i.e. A = |s1_hi - QQ0|)

.TT184

 CMP #20                ; If the horizontal distance in A is >= 20, then this
 BCS TT187              ; system is too far away from the current system to
                        ; appear in the Short-range Chart, so jump to TT187 to
                        ; move on to the next system

 LDA QQ15+1             ; Set A = s0_hi - QQ1, the vertical distance between
 SEC                    ; (s1_hi, s0_hi) and (QQ0, QQ1)
 SBC QQ1

 BCS TT186              ; If a borrow didn't occur, i.e. s0_hi >= QQ1, then the
                        ; result is positive, so jump to TT186 and skip the
                        ; following two instructions

 EOR #$FF               ; Otherwise negate the result in A, so A is always
 ADC #1                 ; positive (i.e. A = |s0_hi - QQ1|)

.TT186

 CMP #38                ; If the vertical distance in A is >= 38, then this
 BCS TT187              ; system is too far away from the current system to
                        ; appear in the Short-range Chart, so jump to TT187 to
                        ; move on to the next system

                        ; This system should be shown on the Short-range Chart,
                        ; so now we need to work out where the label should go,
                        ; and set up the various variables we need to draw the
                        ; system's filled circle on the chart

 LDA QQ15+3             ; Set A = s1_hi - QQ0, the horizontal distance between
 SEC                    ; this system and the current system, where |A| < 20.
 SBC QQ0                ; Let's call this the x-delta, as it's the horizontal
                        ; difference between the current system at the centre of
                        ; the chart, and this system (and this time we keep the
                        ; sign of A, so it can be negative if it's to the left
                        ; of the chart's centre, or positive if it's to the
                        ; right)

 ASL A                  ; Set XX12 = 104 + x-delta * 4
 ASL A                  ;
 ADC #104               ; 104 is the x-coordinate of the centre of the chart,
 STA XX12               ; so this sets XX12 to the centre 104 +/- 76, the pixel
                        ; x-coordinate of this system

 LSR A                  ; Move the text cursor to column x-delta / 2 + 1
 LSR A                  ; which will be in the range 1-10
 LSR A
 CLC
 ADC #1
 STA XC

 LDA QQ15+1             ; Set A = s0_hi - QQ1, the vertical distance between
 SEC                    ; this system and the current system, where |A| < 38.
 SBC QQ1                ; Let's call this the y-delta, as it's the vertical
                        ; difference between the current system at the centre of
                        ; the chart, and this system (and this time we keep the
                        ; sign of A, so it can be negative if it's above the
                        ; chart's centre, or positive if it's below)

 ASL A                  ; Set K4 = 90 + y-delta * 2
 ADC #90                ;
 STA K4                 ; 90 is the y-coordinate of the centre of the chart,
                        ; so this sets K4 to the centre 90 +/- 74, the pixel
                        ; y-coordinate of this system

 LSR A                  ; Set Y = K4 / 8, so Y contains the number of the text
 LSR A                  ; row that contains this system
 LSR A
 TAY

                        ; Now to see if there is room for this system's label.
                        ; Ideally we would print the system name on the same
                        ; text row as the system, but we only want to print one
                        ; label per row, to prevent overlap, so now we check
                        ; this system's row, and if that's already occupied,
                        ; the row above, and if that's already occupied, the
                        ; row below... and if that's already occupied, we give
                        ; up and don't print a label for this system

 LDX INWK,Y             ; If the value in INWK+Y is 0 (i.e. the text row
 BEQ EE4                ; containing this system does not already have another
                        ; system's label on it), jump to EE4 to store this
                        ; system's label on this row

 INY                    ; If the value in INWK+Y+1 is 0 (i.e. the text row below
 LDX INWK,Y             ; the one containing this system does not already have
 BEQ EE4                ; another system's label on it), jump to EE4 to store
                        ; this system's label on this row

 DEY                    ; If the value in INWK+Y-1 is 0 (i.e. the text row above
 DEY                    ; the one containing this system does not already have
 LDX INWK,Y             ; another system's label on it), fall through into to
 BNE ee1                ; EE4 to store this system's label on this row,
                        ; otherwise jump to ee1 to skip printing a label for
                        ; this system (as there simply isn't room)

.EE4

 TYA                    ; Now to print the label, so move the text cursor to row
 STA YC                 ; Y (which contains the row where we can print this
                        ; system's label)

 CPY #3                 ; If Y < 3, then the system would clash with the chart
 BCC TT187              ; title, so jump to TT187 to skip showing the system

 LDA #$FF               ; Store $FF in INWK+Y, to denote that this row is now
 STA INWK,Y             ; occupied so we don't try to print another system's
                        ; label on this row

 LDA #%10000000         ; Set bit 7 of QQ17 to switch to Sentence Case
 STA QQ17

 JSR cpl                ; Call cpl to print out the system name for the seeds
                        ; in QQ15 (which now contains the seeds for the current
                        ; system)

.ee1

 LDA #0                 ; Now to plot the star, so set the high bytes of K, K3
 STA K3+1               ; and K4 to 0
 STA K4+1
 STA K+1

 LDA XX12               ; Set the low byte of K3 to XX12, the pixel x-coordinate
 STA K3                 ; of this system

 LDA QQ15+5             ; Fetch s2_hi for this system from QQ15+5, extract bit 0
 AND #1                 ; and add 2 to get the size of the star, which we store
 ADC #2                 ; in K. This will be either 2, 3 or 4, depending on the
 STA K                  ; value of bit 0, and whether the C flag is set (which
                        ; will vary depending on what happens in the above call
                        ; to cpl). Incidentally, the planet's average radius
                        ; also uses s2_hi, bits 0-3 to be precise, but that
                        ; doesn't mean the two sizes affect each other

                        ; We now have the following:
                        ;
                        ;   K(1 0)  = radius of star (2, 3 or 4)
                        ;
                        ;   K3(1 0) = pixel x-coordinate of system
                        ;
                        ;   K4(1 0) = pixel y-coordinate of system
                        ;
                        ; which we can now pass to the DrawChartSystem routine
                        ; to draw a system on the Short-range Chart

 JSR DrawChartSystem    ; Draw the system on the chart

.TT187

 JSR TT20               ; We want to move on to the next system, so call TT20
                        ; to twist the three 16-bit seeds in QQ15

 INC XX20               ; Increment the counter

 BEQ P%+5               ; If X = 0 then we have done all 256 systems, so skip
                        ; the next instruction to return from the subroutine

 JMP TT182              ; Otherwise jump back up to TT182 to process the next
                        ; system

 LDA #143               ; Set the number of pixel rows in the space view to 143,
 STA Yx2M1              ; so the screen height is correctly set for the
                        ; Long-range Chart in case we switch to it using the
                        ; icon in the icon bar (which toggles between the two
                        ; charts)

 JMP UpdateView         ; Update the view, returning from the subroutine using
                        ; a tail call

; ******************************************************************************
;
;       Name: DrawChartSystem
;       Type: Subroutine
;   Category: Charts
;    Summary: Draw system blobs on short-range chart
;
; ------------------------------------------------------------------------------
;
; Arguments:
;
;   K(1 0)              Radius of star (2, 3 or 4)
;
;   K3(1 0)             Pixel x-coordinate of system
;
;   K4(1 0)             Pixel y-coordinate of system
;
; ******************************************************************************

.DrawChartSystem

 LDY systemsOnChart     ; Set Y to the number of this system on the chart

 CPY #24                ; If systemsOnChart >= 24 then we have already drawn the
 BCS csys1              ; maximum number of systems on the chart, so jump to
                        ; csys1 to return from the subroutine

 INY                    ; Otherwise increment systemsOnChart as we are about to
 STY systemsOnChart     ; draw a system on the chart

 TYA                    ; Set Y = Y * 4
 ASL A
 ASL A
 TAY

 LDA K3                 ; Set the x-coordinate of sprite 38 + Y to K3 - 2
 SBC #3                 ;
 STA xSprite38,Y        ; The SBC #3 subtracts 2 because we know the C flag is
                        ; clear at this point
                        ;
                        ; Y is 1 for the first system on the chart, so this sets
                        ; the x-coordinate of sprite 39 onwards, and we subtract
                        ; 2 because the star sprites have a margin of at least
                        ; two pixels along the left edge, so this aligns the
                        ; star part of the sprite to the x-coodrinate

 LDA K4                 ; Set the y-coordinate of sprite 38 + Y to K4 + 10
 CLC                    ;
 ADC #10+YPAL           ; This sets the y-coordinate of sprite 39 onwards, and
 STA ySprite38,Y        ; the 10 pixels are added to push the star sprite below
                        ; the level of the text label, so the star appears to
                        ; the bottom-left of the text

 LDA #213               ; Set the tile pattern to 213 + K
 CLC                    ;
 ADC K                  ; The patterns for the three star sizes on the chart are
 STA tileSprite38,Y     ; in patterns 215 to 217, going from small to large, so
                        ; this sets the sprite to the correct star size in K as
                        ; K is in the range 2 to 4

 LDA #%00000010         ; Set the attributes for this sprite as follows:
 STA attrSprite38,Y     ;
                        ;   * Bits 0-1    = sprite palette 2
                        ;   * Bit 5 clear = show in front of background
                        ;   * Bit 6 clear = do not flip horizontally
                        ;   * Bit 7 clear = do not flip vertically

.csys1

 RTS                    ; Return from the subroutine

; ******************************************************************************
;
;       Name: TT81
;       Type: Subroutine
;   Category: Universe
;    Summary: Set the selected system's seeds to those of system 0
;
; ------------------------------------------------------------------------------
;
; Copy the three 16-bit seeds for the current galaxy's system 0 (QQ21) into the
; seeds for the selected system (QQ15) - in other words, set the selected
; system's seeds to those of system 0.
;
; ******************************************************************************

.TT81

 LDX #5                 ; Set up a counter in X to copy six bytes (for three
                        ; 16-bit numbers)

 LDA QQ21,X             ; Copy the X-th byte in QQ21 to the X-th byte in QQ15
 STA QQ15,X

 DEX                    ; Decrement the counter

 BPL TT81+2             ; Loop back up to the LDA instruction if we still have
                        ; more bytes to copy

 RTS                    ; Return from the subroutine

; ******************************************************************************
;
;       Name: SelectNearbySystem
;       Type: Subroutine
;   Category: Universe
;    Summary: Set the current system to the nearest system and update the
;             selected system flags accordingly
;
; ******************************************************************************

.SelectNearbySystem

 JSR TT111              ; Select the system closest to galactic coordinates
                        ; (QQ9, QQ10)

 JMP SetSelectionFlags  ; Jump to SetSelectionFlags to set the selected system
                        ; flags for the new system and update the icon bar if
                        ; required

; ******************************************************************************
;
;       Name: SetSelectedSystem
;       Type: Subroutine
;   Category: Universe
;    Summary: Set the selected system to the nearest system, if we don't already
;             have a selected system
;
; ******************************************************************************

.SetSelectedSystem

 LDA selectedSystemFlag ; If bit 7 of selectedSystemFlag is set, then we already
 BMI SetCurrentSystem   ; have a selected system, so jump to SetCurrentSystem
                        ; to ensure we keep using this system as our selected
                        ; system, returning from the subroutine using a tail
                        ; call

                        ; If we get here then we do not already have a selected
                        ; system, so now we set it up

 JSR TT111              ; Select the system closest to galactic coordinates
                        ; (QQ9, QQ10)

 LDA QQ11               ; If the view in QQ11 is not %0000110x (i.e. 12 or 13,
 AND #%00001110         ; which are the Short-range Chart and Long-range Chart),
 CMP #%00001100         ; jump to pchm1 to skip the following as we don't need
 BNE pchm1              ; to update the message on the chart view

 JSR TT103              ; Draw small crosshairs at coordinates (QQ9, QQ10),
                        ; which will draw the crosshairs at our current home
                        ; system

 LDA #0                 ; Set QQ17 = 0 to switch to ALL CAPS
 STA QQ17

 JSR CLYNS              ; Clear the bottom two text rows of the upper screen,
                        ; and move the text cursor to column 1 on row 21, i.e.
                        ; the start of the top row of the two bottom rows

 JSR cpl                ; Call cpl to print out the system name for the seeds
                        ; in QQ15

 LDA #%10000000         ; Set bit 7 of QQ17 to switch standard tokens to
 STA QQ17               ; Sentence Case

 LDA #12                ; Print a newline
 JSR DASC_b2

 JSR TT146              ; If the distance to this system is non-zero, print
                        ; "DISTANCE", then the distance, "LIGHT YEARS" and a
                        ; paragraph break, otherwise just move the cursor down
                        ; a line

 JSR DrawMessageInNMI   ; Configure the NMI to display the updated message that
                        ; we just printed, showing the current system name and
                        ; distance

.pchm1

                        ; Falll through into SetSelectionFlags to set the
                        ; selected system flags for the new system

; ******************************************************************************
;
;       Name: SetSelectionFlags
;       Type: Subroutine
;   Category: Universe
;    Summary: Set the selected system flags for the currently selected system
;             and update the icon bar if required
;
; ******************************************************************************

.SetSelectionFlags

 LDA QQ8+1              ; If the high byte of the distance to the selected
 BNE ssel3              ; system in QQ18(1 0) is non-zero, then it is a long way
                        ; from us, so jump to ssel3 to set the selected system
                        ; flags to indicate we can't hyperspace there

 LDA QQ8                ; If the low byte of the distance to the selected
 BNE ssel1              ; system in QQ18(1 0) is non-zero, then jump to ssel1
                        ; to check whether we have enough fuel to hyperspace
                        ; there

                        ; If we get here then QQ18(1 0) is zero, so the selected
                        ; system is the same as the current system

 LDA MJ                 ; If MJ is zero then we are not in witchspace, so jump
 BEQ ssel3              ; to ssel3 to set the selected system flags to indicate
                        ; we can't hyperspace to the selected system (as it is
                        ; the same as the current system)

 BNE ssel2              ; MJ is non-zero so we are in witchspace, so jump to
                        ; ssel2 to set the selected system flags to indicate we
                        ; can hyperspace to the selected system (as we are in
                        ; the middle of nowhere without a current system)

.ssel1

 CMP QQ14               ; If the distance to the selected system is equal to the
 BEQ ssel2              ; fuel level in QQ14, jump to ssel2 to set the selected
                        ; system flags to indicate we can hyperspace to the
                        ; selected system

 BCS ssel3              ; If the distance to the selected system is greater than
                        ; the fuel level in QQ14, jump to ssel3 to set the
                        ; selected system flags to indicate we can't hyperspace
                        ; to the selected system (as we don't have enough fuel)

                        ; If we get here then the distance to the selected
                        ; system is less than the fuel level in QQ14, so fall
                        ; through into ssel2 to set the selected system flags to
                        ; indicate we can hyperspace to the selected system

.ssel2

 LDA #%11000000         ; Set A so we set bits 6 and 7 of the selected system
                        ; flags below to indicate that a system is selected and
                        ; we can hyperspace to it

 BNE ssel4              ; Jump to ssel4 to skip the following instruction (this
                        ; BNE is effectively a JMP as A is never zero)

.ssel3

 LDA #%10000000         ; Set A so we set bit 7 and clear bit 6 of the selected
                        ; system flags below to indicate that a system is
                        ; selected but we can't hyperspace to it

.ssel4

 TAX                    ; Copy A into X so we can set selectedSystemFlag to this
                        ; value below

 EOR selectedSystemFlag ; Flip bit 7 and possibly bit 6 in selectedSystemFlag
                        ; and keep the result in A

 STX selectedSystemFlag ; Set selectedSystemFlag to X

 ASL A                  ; If bit 6 of the EOR result in A is clear, then the
 BPL RTS6               ; state of bit 6 did not changed in the update above, so
                        ; we don't need to update the icon bar to show or hide
                        ; the hyperspave button, so return from the subroutine
                        ; (as RTS6 contains an RTS)

 JMP UpdateIconBar_b3   ; Otherwise the newly selected system has a different
                        ; "can we hyperspace here?" status to the previous
                        ; selected system, so we need to update the icon bar to
                        ; either hide or show the hyperspace button, returning
                        ; from the subroutine using a tail call

; ******************************************************************************
;
;       Name: SetCurrentSystem
;       Type: Subroutine
;   Category: Universe
;    Summary: Set the seeds for the selected system to the system that we last
;             snapped the crosshairs to
;
; ------------------------------------------------------------------------------
;
; Other entry points:
;
;   RTS6                Contains an RTS
;
; ******************************************************************************

.SetCurrentSystem

 LDX #5                 ; Set up a counter in X to copy six bytes (for three
                        ; 16-bit numbers)

.ssys1

 LDA selectedSystem,X   ; Copy the X-th byte in selectedSystem to the X-th byte
 STA QQ15,X             ; in QQ15, to set the selected system to the previous
                        ; system that we snapped the crosshairs to

 DEX                    ; Decrement the counter

 BPL ssys1              ; Loop back until we have copied all six seeds

.RTS6

 RTS                    ; Return from the subroutine

; ******************************************************************************
;
;       Name: TT111
;       Type: Subroutine
;   Category: Universe
;    Summary: Set the current system to the nearest system to a point
;
; ------------------------------------------------------------------------------
;
; Given a set of galactic coordinates in (QQ9, QQ10), find the nearest system
; to this point in the galaxy, and set this as the currently selected system.
;
; Arguments:
;
;   QQ9                 The x-coordinate near which we want to find a system
;
;   QQ10                The y-coordinate near which we want to find a system
;
; Returns:
;
;   QQ8(1 0)            The distance from the current system to the nearest
;                       system to the original coordinates
;
;   QQ9                 The x-coordinate of the nearest system to the original
;                       coordinates
;
;   QQ10                The y-coordinate of the nearest system to the original
;                       coordinates
;
;   QQ15 to QQ15+5      The three 16-bit seeds of the nearest system to the
;                       original coordinates
;
;   systemNumber        The system number of the nearest system
;
; Other entry points:
;
;   TT111-1             Contains an RTS
;
; ******************************************************************************

.TT111

 JSR TT81               ; Set the seeds in QQ15 to those of system 0 in the
                        ; current galaxy (i.e. copy the seeds from QQ21 to QQ15)

                        ; We now loop through every single system in the galaxy
                        ; and check the distance from (QQ9, QQ10). We get the
                        ; galactic coordinates of each system from the system's
                        ; seeds, like this:
                        ;
                        ;   x = s1_hi (which is stored in QQ15+3)
                        ;   y = s0_hi (which is stored in QQ15+1)
                        ;
                        ; so the following loops through each system in the
                        ; galaxy in turn and calculates the distance between
                        ; (QQ9, QQ10) and (s1_hi, s0_hi) to find the closest one

 LDY #127               ; Set Y = T = 127 to hold the shortest distance we've
 STY T                  ; found so far, which we initially set to half the
                        ; distance across the galaxy, or 127, as our coordinate
                        ; system ranges from (0,0) to (255, 255)

 LDA #0                 ; Set A = U = 0 to act as a counter for each system in
 STA U                  ; the current galaxy, which we start at system 0 and
                        ; loop through to 255, the last system

.TT130

 SETUP_PPU_FOR_ICON_BAR ; If the PPU has started drawing the icon bar, configure
                        ; the PPU to use nametable 0 and pattern table 0

 LDA QQ15+3             ; Set A = s1_hi - QQ9, the horizontal distance between
 SEC                    ; (s1_hi, s0_hi) and (QQ9, QQ10)
 SBC QQ9

 BCS TT132              ; If a borrow didn't occur, i.e. s1_hi >= QQ9, then the
                        ; result is positive, so jump to TT132 and skip the
                        ; following two instructions

 EOR #$FF               ; Otherwise negate the result in A, so A is always
 ADC #1                 ; positive (i.e. A = |s1_hi - QQ9|)

.TT132

 LSR A                  ; Set S = A / 2
 STA S                  ;       = |s1_hi - QQ9| / 2

 LDA QQ15+1             ; Set A = s0_hi - QQ10, the vertical distance between
 SEC                    ; (s1_hi, s0_hi) and (QQ9, QQ10)
 SBC QQ10

 BCS TT134              ; If a borrow didn't occur, i.e. s0_hi >= QQ10, then the
                        ; result is positive, so jump to TT134 and skip the
                        ; following two instructions

 EOR #$FF               ; Otherwise negate the result in A, so A is always
 ADC #1                 ; positive (i.e. A = |s0_hi - QQ10|)

.TT134

 LSR A                  ; Set A = S + A / 2
 CLC                    ;       = |s1_hi - QQ9| / 2 + |s0_hi - QQ10| / 2
 ADC S                  ;
                        ; So A now contains the sum of the horizontal and
                        ; vertical distances, both divided by 2 so the result
                        ; fits into one byte, and although this doesn't contain
                        ; the actual distance between the systems, it's a good
                        ; enough approximation to use for comparing distances

 CMP T                  ; If A >= T, then this system's distance is bigger than
 BCS TT135              ; our "minimum distance so far" stored in T, so it's no
                        ; closer than the systems we have already found, so
                        ; skip to TT135 to move on to the next system

 STA T                  ; This system is the closest to (QQ9, QQ10) so far, so
                        ; update T with the new "distance" approximation

 LDX #5                 ; As this system is the closest we have found yet, we
                        ; want to store the system's seeds in case it ends up
                        ; being the closest of all, so we set up a counter in X
                        ; to copy six bytes (for three 16-bit numbers)

.TT136

 LDA QQ15,X             ; Copy the X-th byte in QQ15 to the X-th byte in QQ19,
 STA QQ19,X             ; where QQ15 contains the seeds for the system we just
                        ; found to be the closest so far, and QQ19 is temporary
                        ; storage

 DEX                    ; Decrement the counter

 BPL TT136              ; Loop back to TT136 if we still have more bytes to
                        ; copy

 LDA U                  ; Store the system number U in systemNumber, so when we
 STA systemNumber       ; are done looping through all the candidates, the
                        ; winner's number will be in systemNumber

.TT135

 SETUP_PPU_FOR_ICON_BAR ; If the PPU has started drawing the icon bar, configure
                        ; the PPU to use nametable 0 and pattern table 0

 JSR TT20               ; We want to move on to the next system, so call TT20
                        ; to twist the three 16-bit seeds in QQ15

 INC U                  ; Increment the system counter in U

 BNE TT130              ; If U > 0 then we haven't done all 256 systems yet, so
                        ; loop back up to TT130

                        ; We have now finished checking all the systems in the
                        ; galaxy, and the seeds for the closest system are in
                        ; QQ19, so now we want to copy these seeds to QQ15,
                        ; to set the selected system to this closest system

 LDX #5                 ; So we set up a counter in X to copy six bytes (for
                        ; three 16-bit numbers)

.TT137

 LDA QQ19,X             ; Copy the X-th byte in QQ19 to the X-th byte in
 STA selectedSystem,X   ; selectedSystem so we can easily change the selected
                        ; system back to the system we just found

 STA QQ15,X             ; Copy the X-th byte in QQ19 to the X-th byte in QQ15

 DEX                    ; Decrement the counter

 BPL TT137              ; Loop back to TT137 if we still have more bytes to
                        ; copy

 LDA QQ15+1             ; The y-coordinate of the system described by the seeds
 STA QQ10               ; in QQ15 is in QQ15+1 (s0_hi), so we copy this to QQ10
                        ; as this is where we store the selected system's
                        ; y-coordinate

 LDA QQ15+3             ; The x-coordinate of the system described by the seeds
 STA QQ9                ; in QQ15 is in QQ15+3 (s1_hi), so we copy this to QQ9
                        ; as this is where we store the selected system's
                        ; x-coordinate

                        ; We have now found the closest system to (QQ9, QQ10)
                        ; and have set it as the selected system, so now we
                        ; need to work out the distance between the selected
                        ; system and the current system

 SEC                    ; Set A = QQ9 - QQ0, the horizontal distance between
 SBC QQ0                ; the selected system's x-coordinate (QQ9) and the
                        ; current system's x-coordinate (QQ0)

 BCS TT139              ; If a borrow didn't occur, i.e. QQ9 >= QQ0, then the
                        ; result is positive, so jump to TT139 and skip the
                        ; following two instructions

 EOR #$FF               ; Otherwise negate the result in A, so A is always
 ADC #1                 ; positive (i.e. A = |QQ9 - QQ0|)

                        ; A now contains the difference between the two
                        ; systems' x-coordinates, with the sign removed. We
                        ; will refer to this as the x-delta ("delta" means
                        ; change or difference in maths)

.TT139

 JSR SQUA2              ; Set (A P) = A * A
                        ;           = |QQ9 - QQ0| ^ 2
                        ;           = x_delta ^ 2

 STA K+1                ; Store (A P) in K(1 0)
 LDA P
 STA K

 LDA QQ10               ; Set A = QQ10 - QQ1, the vertical distance between the
 SEC                    ; selected system's y-coordinate (QQ10) and the current
 SBC QQ1                ; system's y-coordinate (QQ1)

 BCS TT141              ; If a borrow didn't occur, i.e. QQ10 >= QQ1, then the
                        ; result is positive, so jump to TT141 and skip the
                        ; following two instructions

 EOR #$FF               ; Otherwise negate the result in A, so A is always
 ADC #1                 ; positive (i.e. A = |QQ10 - QQ1|)

.TT141

 LSR A                  ; Set A = A / 2

                        ; A now contains the difference between the two
                        ; systems' y-coordinates, with the sign removed, and
                        ; halved. We halve the value because the galaxy in
                        ; in Elite is rectangular rather than square, and is
                        ; twice as wide (x-axis) as it is high (y-axis), so to
                        ; get a distance that matches the shape of the
                        ; long-range galaxy chart, we need to halve the
                        ; distance between the vertical y-coordinates. We will
                        ; refer to this as the y-delta

 JSR SQUA2              ; Set (A P) = A * A
                        ;           = (|QQ10 - QQ1| / 2) ^ 2
                        ;           = y_delta ^ 2

                        ; By this point we have the following results:
                        ;
                        ;   K(1 0) = x_delta ^ 2
                        ;    (A P) = y_delta ^ 2
                        ;
                        ; so to find the distance between the two points, we
                        ; can use Pythagoras - so first we need to add the two
                        ; results together, and then take the square root

 PHA                    ; Store the high byte of the y-axis value on the stack,
                        ; so we can use A for another purpose

 SETUP_PPU_FOR_ICON_BAR ; If the PPU has started drawing the icon bar, configure
                        ; the PPU to use nametable 0 and pattern table 0

 LDA P                  ; Set Q = P + K, which adds the low bytes of the two
 CLC                    ; calculated values
 ADC K
 STA Q

 PLA                    ; Restore the high byte of the y-axis value from the
                        ; stack into A again

 ADC K+1                ; Set A = A + K+1, which adds the high bytes of the two
                        ; calculated values

 BCC P%+4               ; If the above addition overflowed, set A = 255
 LDA #255

 STA R                  ; Store A in R, so we now have R = A + K+1, and:
                        ;
                        ;   (R Q) = K(1 0) + (A P)
                        ;         = (x_delta ^ 2) + (y_delta ^ 2)

 JSR LL5                ; Set Q = SQRT(R Q), so Q now contains the distance
                        ; between the two systems, in terms of coordinates

                        ; We now store the distance to the selected system * 4
                        ; in the two-byte location QQ8, by taking (0 Q) and
                        ; shifting it left twice, storing it in QQ8(1 0)

 LDA Q                  ; First we shift the low byte left by setting
 ASL A                  ; A = Q * 2, with bit 7 of A going into the C flag

 LDX #0                 ; Now we set the high byte in QQ8+1 to 0 and rotate
 STX QQ8+1              ; the C flag into bit 0 of QQ8+1
 ROL QQ8+1

 ASL A                  ; And then we repeat the shift left of (QQ8+1 A)
 ROL QQ8+1

 STA QQ8                ; And store A in the low byte, QQ8, so QQ8(1 0) now
                        ; contains Q * 4. Given that the width of the galaxy is
                        ; 256 in coordinate terms, the width of the galaxy
                        ; would be 1024 in the units we store in QQ8

 JMP TT24_b6            ; Call TT24 to calculate system data from the seeds in
                        ; QQ15 and store them in the relevant locations, so our
                        ; new selected system is fully set up, and return from
                        ; the subroutine using a tail call

; ******************************************************************************
;
;       Name: dockEd
;       Type: Subroutine
;   Category: Flight
;    Summary: Print a message to say there is no hyperspacing allowed inside the
;             station
;
; ------------------------------------------------------------------------------
;
; Print "Docked" at the bottom of the screen to indicate we can't hyperspace
; when docked.
;
; ******************************************************************************

.dockEd

 JSR CLYNS              ; Clear the bottom two text rows of the upper screen,
                        ; and move the text cursor to column 1 on row 21, i.e.
                        ; the start of the top row of the two bottom rows

 LDA #15                ; Move the text cursor to column 15 (the middle of the
 STA XC                 ; screen), setting A to 15 at the same time for the
                        ; following call to TT27

 LDA #205               ; Print extended token 205 ("DOCKED") and return from
 JMP DETOK_b2           ; the subroutine using a tail call

; ******************************************************************************
;
;       Name: GalacticHyperdrive
;       Type: Subroutine
;   Category: Flight
;    Summary: If we are in space and the countdown has ended, activate the
;             galactic hyperdrive
;
; ******************************************************************************

.GalacticHyperdrive

 LDA QQ12               ; If we are docked (QQ12 = $FF) then jump to dockEd to
 BNE dockEd             ; print an error message and return from the subroutine
                        ; using a tail call (as we can't hyperspace when docked)

 LDA QQ22+1             ; Fetch QQ22+1, which contains the number that's shown
                        ; on-screen during hyperspace countdown

 BEQ Ghy                ; If the countdown is zero, then the galactic hyperdrive
                        ; has been activated, so jump to Ghy to process it

 RTS                    ; Otherwise return from the subroutine

; ******************************************************************************
;
;       Name: hyp
;       Type: Subroutine
;   Category: Flight
;    Summary: Start the hyperspace process
;
; ------------------------------------------------------------------------------
;
; Called when the hyperspace icon is chosen during flight. Checks the following:
;
;   * We are in space
;
;   * We are not already in a hyperspace countdown
;
; and if all the pre-jump checks are passed, we print the destination on-screen
; and start the countdown.
;
; ******************************************************************************

.hyp

 LDA QQ12               ; If we are docked (QQ12 = $FF) then jump to dockEd to
 BNE dockEd             ; print an error message and return from the subroutine
                        ; using a tail call (as we can't hyperspace when docked)

 LDA QQ22+1             ; Fetch QQ22+1, which contains the number that's shown
                        ; on-screen during hyperspace countdown

 BEQ P%+3               ; If it is zero, skip the next instruction

 RTS                    ; The count is non-zero, so return from the subroutine

 LDA selectedSystemFlag ; If bit 6 of selectedSystemFlag is set, then we can
 ASL A                  ; hyperspace to the currently selected system, so jump
 BMI hyps1              ; to hyps1 to skip the following instruction and keep
                        ; going

 RTS                    ; Bit 6 of selectedSystemFlag is clear, so we can't
                        ; hyperspace to the currently selected system (we may
                        ; not have enough fuel, or it might be the same as the
                        ; current system), so return from the subroutine

.hyps1

 LDX #5                 ; We now want to copy those seeds into safehouse, so we
                        ; so set a counter in X to copy 6 bytes

.sob

 LDA QQ15,X             ; Copy the X-th byte of QQ15 into the X-th byte of
 STA safehouse,X        ; safehouse

 DEX                    ; Decrement the loop counter

 BPL sob                ; Loop back to copy the next byte until we have copied
                        ; all six seed bytes

; ******************************************************************************
;
;       Name: wW
;       Type: Subroutine
;   Category: Flight
;    Summary: Start a hyperspace countdown
;
; ------------------------------------------------------------------------------
;
; Start the hyperspace countdown (for both inter-system hyperspace and the
; galactic hyperdrive).
;
; Other entry points:
;
;   wW2                 Start the hyperspace countdown, starting the countdown
;                       from the value in A
;
; ******************************************************************************

.wW

 LDA #16                ; The hyperspace countdown starts from 16, so set A to
                        ; 15 so we can set the two hyperspace counters

.wW2

 STA QQ22+1             ; Set the number in QQ22+1 to A, which is the number
                        ; that's shown on-screen during the hyperspace countdown

 LDA #1                 ; Set the number in QQ22 to 11, which is the internal
 STA QQ22               ; counter that counts down by 1 each iteration of the
                        ; main game loop, and each time it reaches zero, the
                        ; on-screen counter gets decremented, and QQ22 gets set
                        ; to 5, so setting QQ22 to 1 here makes the first tick
                        ; of the hyperspace counter shorter than subsequent
                        ; ticks

 JMP UpdateIconBar_b3   ; Update the icon bar to remove the hyperspace button,
                        ; as we are now commit to our hyperspace jump, and
                        ; return from the subroutine using a tail call

; ******************************************************************************
;
;       Name: Ghy
;       Type: Subroutine
;   Category: Flight
;    Summary: Perform a galactic hyperspace jump
;  Deep dive: Twisting the system seeds
;             Galaxy and system seeds
;
; ------------------------------------------------------------------------------
;
; Engage the galactic hyperdrive. Called from the hyp routine above if CTRL-H is
; being pressed.
;
; This routine also updates the galaxy seeds to point to the next galaxy. Using
; a galactic hyperdrive rotates each seed byte to the left, rolling each byte
; left within itself like this:
;
;   01234567 -> 12345670
;
; to get the seeds for the next galaxy. So after 8 galactic jumps, the seeds
; roll round to those of the first galaxy again.
;
; We always arrive in a new galaxy at galactic coordinates (96, 96), and then
; find the nearest system and set that as our location.
;
; Other entry points:
;
;   zZ+1                Contains an RTS
;
; ******************************************************************************

.Ghy

 LDX GHYP               ; Fetch GHYP, which tells us whether we own a galactic
 BEQ hy5                ; hyperdrive, and if it is zero, which means we don't,
                        ; return from the subroutine (as hy5 contains an RTS)

 INX                    ; We own a galactic hyperdrive, so X is $FF, so this
                        ; instruction sets X = 0

 STX GHYP               ; The galactic hyperdrive is a one-use item, so set GHYP
                        ; to 0 so we no longer have one fitted

 STX FIST               ; Changing galaxy also clears our criminal record, so
                        ; set our legal status in FIST to 0 ("clean")

 JSR UpdateIconBar_b3   ; Update the icon bar to remove the galactic hyperdrive
                        ; button as we no longer have one

 LDA #1                 ; Call wW2 with A = 1 to start the hyperspace countdown,
 JSR wW2                ; but starting the countdown from 1

 LDX #5                 ; To move galaxy, we rotate the galaxy's seeds left, so
                        ; set a counter in X for the 6 seed bytes

 INC GCNT               ; Increment the current galaxy number in GCNT

 LDA GCNT               ; Clear bit 3 of GCNT, so we jump from galaxy 7 back
 AND #%11110111         ; to galaxy 0 (shown in-game as going from galaxy 8 back
 STA GCNT               ; to the starting point in galaxy 1). We also retain any
                        ; set bits in the high nibble, so if the galaxy number
                        ; is manually set to 16 or higher, it will stay high
                        ; (though the high nibble doesn't seem to get set by
                        ; the game at any point, so it isn't clear what this is
                        ; for, though Lave in galaxy 16 does show a unique
                        ; system description override, so something is going on
                        ; here...)

.G1

 LDA QQ21,X             ; Load the X-th seed byte into A

 ASL A                  ; Set the C flag to bit 7 of the seed

 ROL QQ21,X             ; Rotate the seed in memory, which will add bit 7 back
                        ; in as bit 0, so this rolls the seed around on itself

 DEX                    ; Decrement the counter

 BPL G1                 ; Loop back for the next seed byte, until we have
                        ; rotated them all

.zZ

 LDA #96                ; Set (QQ9, QQ10) to (96, 96), which is where we always
 STA QQ9                ; arrive in a new galaxy (the selected system will be
 STA QQ10               ; set to the nearest actual system later on)

 JSR TT110              ; Call TT110 to show the front space view

 JSR TT111              ; Call TT111 to set the current system to the nearest
                        ; system to (QQ9, QQ10), and put the seeds of the
                        ; nearest system into QQ15 to QQ15+5
                        ;
                        ; This call fixes a bug in the cassette version, where
                        ; the galactic hyperdrive will take us to coordinates
                        ; (96, 96) in the new galaxy, even if there isn't
                        ; actually a system there, so if we jump when we are
                        ; low on fuel, it is possible to get stuck in the
                        ; middle of nowhere when changing galaxy
                        ;
                        ; This call sets the current system correctly, so we
                        ; always arrive at the nearest system to (96, 96)

 LDX #5                 ; We now want to copy those seeds into safehouse, so we
                        ; so set a counter in X to copy 6 bytes

.dumdeedum

 LDA QQ15,X             ; Copy the X-th byte of QQ15 into the X-th byte of
 STA safehouse,X        ; safehouse

 DEX                    ; Decrement the loop counter

 BPL dumdeedum          ; Loop back to copy the next byte until we have copied
                        ; all six seed bytes

 LDX #0                 ; Set the distance to the selected system in QQ8(1 0)
 STX QQ8                ; to 0
 STX QQ8+1

 LDY #22                ; Call the NOISE routine with Y = 22 to make the
 JSR NOISE              ; galactic hyperspace sound

                        ; Fall through into jmp to set the system to the
                        ; current system and return from the subroutine there

; ******************************************************************************
;
;       Name: jmp
;       Type: Subroutine
;   Category: Universe
;    Summary: Set the current system to the selected system
;
; ------------------------------------------------------------------------------
;
; Returns:
;
;   (QQ0, QQ1)          The galactic coordinates of the new system
;
; Other entry points:
;
;   hy5                 Contains an RTS
;
; ******************************************************************************

.jmp

 LDA QQ9                ; Set the current system's galactic x-coordinate to the
 STA QQ0                ; x-coordinate of the selected system

 LDA QQ10               ; Set the current system's galactic y-coordinate to the
 STA QQ1                ; y-coordinate of the selected system

.hy5

 RTS                    ; Return from the subroutine

; ******************************************************************************
;
;       Name: pr6
;       Type: Subroutine
;   Category: Text
;    Summary: Print 16-bit number, left-padded to 5 digits, no point
;
; ------------------------------------------------------------------------------
;
; Print the 16-bit number in (Y X) to 5 digits, left-padding with spaces for
; numbers with fewer than 3 digits (so numbers < 10000 are right-aligned),
; with no decimal point.
;
; Arguments:
;
;   X                   The low byte of the number to print
;
;   Y                   The high byte of the number to print
;
; ******************************************************************************

.pr6

 CLC                    ; Do not display a decimal point when printing

                        ; Fall through into pr5 to print X to 5 digits

; ******************************************************************************
;
;       Name: pr5
;       Type: Subroutine
;   Category: Text
;    Summary: Print a 16-bit number, left-padded to 5 digits, and optional point
;
; ------------------------------------------------------------------------------
;
; Print the 16-bit number in (Y X) to 5 digits, left-padding with spaces for
; numbers with fewer than 3 digits (so numbers < 10000 are right-aligned).
; Optionally include a decimal point.
;
; Arguments:
;
;   X                   The low byte of the number to print
;
;   Y                   The high byte of the number to print
;
;   C flag              If set, include a decimal point
;
; ******************************************************************************

.pr5

 LDA #5                 ; Set the number of digits to print to 5

 JMP TT11               ; Call TT11 to print (Y X) to 5 digits and return from
                        ; the subroutine using a tail call

; ******************************************************************************
;
;       Name: TT147
;       Type: Subroutine
;   Category: Text
;    Summary: Print an error when a system is out of hyperspace range
;
; ------------------------------------------------------------------------------
;
; Print "RANGE?" for when the hyperspace distance is too far
;
; ******************************************************************************

.TT147

 JSR CLYNS              ; Clear the bottom two text rows of the upper screen,
                        ; and move the text cursor to column 1 on row 21, i.e.
                        ; the start of the top row of the two bottom rows

 LDA #189               ; Print token 29 ("HYPERSPACE ")
 JSR TT27_b2

 JSR TT162              ; Print a space

 LDA #202               ; Print token 42 ("RANGE") followed by a question mark
 JSR prq

 JMP DrawScreenInNMI    ; Configure the NMI handler to draw the screen,
                        ; returning from the subroutine using a tail call

; ******************************************************************************
;
;       Name: prq
;       Type: Subroutine
;   Category: Text
;    Summary: Print a text token followed by a question mark
;
; ------------------------------------------------------------------------------
;
; Arguments:
;
;   A                   The text token to be printed
;
; ******************************************************************************

.prq

 JSR TT27_b2            ; Print the text token in A

 LDA #'?'               ; Print a question mark and return from the
 JMP TT27_b2            ; subroutine using a tail call

; ******************************************************************************
;
;       Name: TT151
;       Type: Subroutine
;   Category: Market
;    Summary: Print the name, price and availability of a market item
;  Deep dive: Market item prices and availability
;             Galaxy and system seeds
;
; ------------------------------------------------------------------------------
;
; Arguments:
;
;   A                   The number of the market item to print, 0-16 (see QQ23
;                       for details of item numbers)
;
; Returns:
;
;   QQ19+1              Byte #1 from the market prices table for this item
;
;   QQ24                The item's price / 4
;
;   QQ25                The item's availability
;
; ******************************************************************************

.TT151q

                        ; We jump here from below if we are in witchspace

 PLA                    ; Restore the item number from the stack

 RTS                    ; Return from the subroutine

.TT151

 PHA                    ; Store the item number on the stack and in QQ19+4
 STA QQ19+4

 ASL A                  ; Store the item number * 4 in QQ19, so this will act as
 ASL A                  ; an index into the market prices table at QQ23 for this
 STA QQ19               ; item (as there are four bytes per item in the table)

 JSR SetupPPUForIconBar ; If the PPU has started drawing the icon bar, configure
                        ; the PPU to use nametable 0 and pattern table 0

 LDA MJ                 ; If we are in witchspace, we can't trade items, so jump
 BNE TT151q             ; up to TT151q to return from the subroutine

 LDA #1                 ; Move the text cursor to column 1, for the item's name
 STA XC

 LDA #%10000000         ; Set bit 7 of QQ17 to switch to Sentence Case
 STA QQ17

 PLA                    ; Restore the item number

 CLC                    ; Print recursive token 48 + A, which will be in the
 ADC #208               ; range 48 ("FOOD") to 64 ("ALIEN ITEMS"), so this
 JSR TT27_b2            ; prints the item's name

                        ; We now move the text cursor to column 14 by printing
                        ; spaces until the cursor column in XC reaches 14

.aval1

 LDA #' '               ; Print a space
 JSR TT27_b2

 LDA XC                 ; Loop back to print another space until XC = 14
 CMP #14
 BNE aval1

 LDX QQ19               ; Fetch byte #1 from the market prices table (units and
 LDA QQ23+1,X           ; economic_factor) for this item and store in QQ19+1
 STA QQ19+1

 LDA QQ26               ; Fetch the random number for this system visit and
 AND QQ23+3,X           ; AND with byte #3 from the market prices table (mask)
                        ; to give:
                        ;
                        ;   A = random AND mask

 CLC                    ; Add byte #0 from the market prices table (base_price),
 ADC QQ23,X             ; so we now have:
 STA QQ24               ;
                        ;   A = base_price + (random AND mask)

 JSR TT152              ; Call TT152 to print the item's unit ("t", "kg" or
                        ; "g"), padded to a width of two characters

 JSR var                ; Call var to set QQ19+3 = economy * |economic_factor|
                        ; (and set the availability of alien items to 0)

 LDA QQ19+1             ; Fetch the byte #1 that we stored above and jump to
 BMI TT155              ; TT155 if it is negative (i.e. if the economic_factor
                        ; is negative)

 LDA QQ24               ; Set A = QQ24 + QQ19+3
 ADC QQ19+3             ;
                        ;       = base_price + (random AND mask)
                        ;         + (economy * |economic_factor|)
                        ;
                        ; which is the result we want, as the economic_factor
                        ; is positive

 JMP TT156              ; Jump to TT156 to multiply the result by 4

.TT155

 LDA QQ24               ; Set A = QQ24 - QQ19+3
 SEC                    ;
 SBC QQ19+3             ;       = base_price + (random AND mask)
                        ;         - (economy * |economic_factor|)
                        ;
                        ; which is the result we want, as economic_factor
                        ; is negative

.TT156

 STA QQ24               ; Store the result in QQ24 and P
 STA P

 LDA #0                 ; Set A = 0 and call GC2 to calculate (Y X) = (A P) * 4,
 JSR GC2                ; which is the same as (Y X) = P * 4 because A = 0

 SEC                    ; We now have our final price, * 10, so we can call pr5
 JSR pr5                ; to print (Y X) to 5 digits, including a decimal
                        ; point, as the C flag is set

 LDY QQ19+4             ; We now move on to availability, so fetch the market
                        ; item number that we stored in QQ19+4 at the start

 LDA #3                 ; Set A to 3 so we can print the availability to 3
                        ; digits (right-padded with spaces)

 LDX AVL,Y              ; Set X to the item's availability, which is given in
                        ; the AVL table

 STX QQ25               ; Store the availability in QQ25

 CLC                    ; Clear the C flag

 BEQ TT172              ; If none are available, jump to TT172 to print a tab
                        ; and a "-"

 JSR pr2+2              ; Otherwise print the 8-bit number in X to 5 digits,
                        ; right-aligned with spaces. This works because we set
                        ; A to 5 above, and we jump into the pr2 routine just
                        ; after the first instruction, which would normally
                        ; set the number of digits to 3

 JSR TT152              ; Print the unit ("t", "kg" or "g") for the market item,
                        ; with a following space if required to make it two
                        ; characters long

 JMP PrintNumberInHold  ; Print the number of units of this item that we have in
                        ; the hold, returning from the subroutine using a tail
                        ; call

.TT172

 JSR PrintSpacedHyphen  ; Print two spaces, then a "-", and then another two
                        ; spaces

 JMP PrintNumberInHold  ; Print the number of units of this item that we have in
                        ; the hold, returning from the subroutine using a tail
                        ; call

; ******************************************************************************
;
;       Name: PrintSpacedHyphen
;       Type: Subroutine
;   Category: Text
;    Summary: Print two spaces, then a "-", and then another two spaces
;
; ******************************************************************************

.PrintSpacedHyphen

 JSR TT162              ; Print two spaces
 JSR TT162

 LDA #'-'               ; Print a "-" character
 JSR TT27_b2

 JSR TT162              ; Print two spaces, returning from the subroutine using
 JMP TT162              ; a tail call

; ******************************************************************************
;
;       Name: TT152
;       Type: Subroutine
;   Category: Market
;    Summary: Print the unit ("t", "kg" or "g") for a market item
;
; ------------------------------------------------------------------------------
;
; Print the unit ("t", "kg" or "g") for the market item whose byte #1 from the
; market prices table is in QQ19+1, right-padded with spaces to a width of two
; characters (so that's "t ", "kg" or "g ").
;
; ******************************************************************************

.TT152

 LDA QQ19+1             ; Fetch the economic_factor from QQ19+1

 AND #96                ; If bits 5 and 6 are both clear, jump to TT160 to
 BEQ TT160              ; print "t" for tonne, followed by a space, and return
                        ; from the subroutine using a tail call

 CMP #32                ; If bit 5 is set, jump to TT161 to print "kg" for
 BEQ TT161              ; kilograms, and return from the subroutine using a tail
                        ; call

 JSR TT16a              ; Otherwise call TT16a to print "g" for grams, and fall
                        ; through into TT162 to print a space and return from
                        ; the subroutine

; ******************************************************************************
;
;       Name: TT162
;       Type: Subroutine
;   Category: Text
;    Summary: Print a space
;
; ------------------------------------------------------------------------------
;
; Other entry points:
;
;   TT162+2             Jump to TT27 to print the text token in A
;
; ******************************************************************************

.TT162

 LDA #' '               ; Load a space character into A

 JMP TT27_b2            ; Print the text token in A and return from the
                        ; subroutine using a tail call

; ******************************************************************************
;
;       Name: TT160
;       Type: Subroutine
;   Category: Market
;    Summary: Print "t" (for tonne) and a space
;
; ******************************************************************************

.TT160

 LDA #'t'               ; Load a "t" character into A

 JSR DASC_b2            ; Print the character

 JMP TT162              ; Jump to TT162 to print a space and return from the
                        ; subroutine using a tail call

; ******************************************************************************
;
;       Name: TT161
;       Type: Subroutine
;   Category: Market
;    Summary: Print "kg" (for kilograms)
;
; ******************************************************************************

.TT161

 LDA #'k'               ; Load a "k" character into A

 JSR DASC_b2            ; Print the character and fall through into TT16a to
                        ; print a "g" character

; ******************************************************************************
;
;       Name: TT16a
;       Type: Subroutine
;   Category: Market
;    Summary: Print "g" (for grams)
;
; ******************************************************************************

.TT16a

 LDA #'g'               ; Load a "g" character into A

 JMP DASC_b2            ; Print the character and return from the subroutine
                        ; using a tail call

; ******************************************************************************
;
;       Name: TT163
;       Type: Subroutine
;   Category: Market
;    Summary: Print the headers for the table of market prices
;
; ------------------------------------------------------------------------------
;
; Print the column headers for the prices table in the Buy Cargo and Market
; Price screens.
;
; ******************************************************************************

.TT163

 LDA #1                 ; Move the text cursor in XC to column 1
 STA XC

 LDA #255               ; Print recursive token 95 token ("UNIT  QUANTITY
 BNE TT162+2            ; {crlf} PRODUCT   UNIT PRICE FOR SALE{crlf}{lf}") by
                        ; jumping to TT162+2, which contains JMP TT27 (this BNE
                        ; is effectively a JMP as A will never be zero), and
                        ; return from the subroutine using a tail call

; ******************************************************************************
;
;       Name: PrintNumberInHold
;       Type: Subroutine
;   Category: Market
;    Summary: Print the number of units of a specified item that we have in the
;             hold
;
; ------------------------------------------------------------------------------
;
; Arguments:
;
;   QQ29                The item number
;
; ******************************************************************************

.PrintNumberInHold

 SETUP_PPU_FOR_ICON_BAR ; If the PPU has started drawing the icon bar, configure
                        ; the PPU to use nametable 0 and pattern table 0

 LDY QQ29               ; Set Y to the current item number

 LDA #3                 ; Set A = 3 to use as the number of digits below

 LDX QQ20,Y             ; Set X to the number of units of this item that we
                        ; already have in the hold

 BEQ PrintSpacedHyphen  ; If we don't have any units of this item in the hold,
                        ; jump to PrintSpacedHyphen to print two spaces, a "-",
                        ; and two spaces

 CLC                    ; Otherwise print the 8-bit number in X to 3 digits, as
 JSR pr2+2              ; we set A to 3 above

 JMP TT152              ; Print the unit ("t", "kg" or "g") for the market item,
                        ; with a following space if required to make it two
                        ; characters long, and return from the subroutine using
                        ; a tail call

; ******************************************************************************
;
;       Name: yMarketPrice
;       Type: Variable
;   Category: Market
;    Summary: The text row for the Market Price title for each language
;
; ******************************************************************************

.yMarketPrice

 EQUB 4                 ; English

 EQUB 5                 ; German

 EQUB 4                 ; French

 EQUB 4                 ; There is no fourth language, so this byte is ignored

; ******************************************************************************
;
;       Name: TT167
;       Type: Subroutine
;   Category: Market
;    Summary: Show the Market Price screen
;
; ******************************************************************************

 JMP TT213              ; Jump to TT213 to show the Inventory screen instead of
                        ; the Market Price screen

.TT167

 LDA #$BA               ; If we are already showing the Market Price screen
 CMP QQ11               ; (i.e. QQ11 is $BA), then jump to TT213 to show the
 BEQ TT167-3            ; Inventory screen, so the icon bar button toggles
                        ; between the two

 JSR SetNewViewType     ; We are not already showing the Market Price screen,
                        ; so that's what we do now, by clearing the screen and
                        ; setting the view type in QQ11 to $BA (Market Price)

 LDA #5                 ; Move the text cursor to column 5
 STA XC

 LDA #167               ; Print recursive token 7 ("{current system name} MARKET
 JSR NLIN3              ; PRICES") on the top row

 LDA #2                 ; Move the text cursor to row 2
 STA YC

 JSR TT163              ; Print the column headers for the prices table

 LDX languageIndex      ; Move the text cursor to the correct row for the Market
 LDA yMarketPrice,X     ; Prices title in the chosen language
 STA YC

 LDA #0                 ; We're going to loop through all the available market
 STA QQ29               ; items, so we set up a counter in QQ29 to denote the
                        ; current item and start it at 0

.TT168

 JSR SetupPPUForIconBar ; If the PPU has started drawing the icon bar, configure
                        ; the PPU to use nametable 0 and pattern table 0

 JSR TT151              ; Call TT151 to print the item name, market price and
                        ; availability of the current item, and set QQ24 to the
                        ; item's price / 4, QQ25 to the quantity available and
                        ; QQ19+1 to byte #1 from the market prices table for
                        ; this item

 INC YC                 ; Move the text cursor down one row

 INC QQ29               ; Increment QQ29 to point to the next item

 LDA QQ29               ; If QQ29 >= 17 then jump to TT168 as we have done the
 CMP #17                ; last item
 BCC TT168

                        ; Fall through into BuyAndSellCargo to process the
                        ; buying and selling of cargo on the Market Price
                        ; screen

; ******************************************************************************
;
;       Name: BuyAndSellCargo
;       Type: Subroutine
;   Category: Market
;    Summary: Process the buying and selling of cargo on the Market Price screen
;
; ******************************************************************************

.BuyAndSellCargo

 LDA QQ12               ; If we are docked (QQ12 = $FF) then jump to sell3 to
 BNE sell3              ; show the buy/sell screen

.sell1

                        ; If we get here then we are in space, so we just
                        ; display the view as we can't buy or sell cargo in
                        ; space

 JSR SetScreenForUpdate ; Get the screen ready for updating by hiding all
                        ; sprites, after fading the screen to black if we are
                        ; changing view

 JSR DrawInventoryIcon  ; Draw the inventory icon on top of the second button
                        ; in the icon bar

 JMP UpdateView         ; Update the view, returning from the subroutine using
                        ; a tail call

.sell2

 JMP sell13             ; Jump to sell13 to process the left button being
                        ; pressed

.sell3

 LDA #0                 ; We're going to highlight the current market item and
 STA QQ29               ; let the player move the highlight up and down, so use
                        ; QQ29 to denote the number of the currently selected
                        ; item, starting with item 0 at the top of the list

 JSR HighlightSaleItem  ; Highlight the name, price and availability of market
                        ; item 0 on the correct row for the chosen language

 JSR PrintCash          ; Print our cash levels in the correct place for the
                        ; chosen language

 JSR sell1              ; Call sell1 above to clear the screen and update the
                        ; view

.sell4

 JSR SetupPPUForIconBar ; If the PPU has started drawing the icon bar, configure
                        ; the PPU to use nametable 0 and pattern table 0

 LDA controller1B       ; If the B button is being pressed, jump to sell6
 BMI sell6

 LDA controller1Up      ; If neither of the up or down buttons are being
 ORA controller1Down    ; pressed, jump to sell5
 BEQ sell5

 LDA controller1Left    ; If neither of the left or right buttons are being
 ORA controller1Right   ; pressed, jump to sell6
 BNE sell6

.sell5

                        ; If we get here then at least one of the direction
                        ; buttons is being pressed

 LDA controller1Up      ; If the up button is being pressed and has been held
 AND #%11110000         ; down for at least four VBlanks, jump to sell7
 CMP #%11110000
 BEQ sell7

 LDA controller1Down    ; If the down button is being pressed and has been held
 AND #%11110000         ; down for at least four VBlanks, jump to sell10
 CMP #%11110000
 BEQ sell10

 LDA controller1Left03  ; If the left button was being held down four VBlanks
 CMP #%11110000         ; ago for at least four VBlanks, jump to sell13 via 
 BEQ sell2              ; sell2

 LDA controller1Right03 ; If the right button was being held down four VBlanks
 CMP #%11110000         ; ago for at least four VBlanks, jump to sell12
 BEQ sell12

.sell6

                        ; If we get here then either the B button is being
                        ; pressed or no directional buttons are being pressed

 LDA iconBarChoice      ; If iconBarChoice = 0 then nothing has been chosen on
 BEQ sell4              ; the icon bar (if it had, iconBarChoice would contain
                        ; the number of the chosen icon bar button), so loop
                        ; back to sell4 to keep listening for button presses

                        ; If we get here then either a choice has been made on
                        ; the icon bar during NMI and the number of the icon bar
                        ; button is in iconBarChoice, or the Start button has
                        ; been pressed and iconBarChoice is 80

 JSR CheckForPause-3    ; If the Start button has been pressed then process the
                        ; pause menu and set the C flag, otherwise clear it

 BCS sell4              ; If it was the pause button, loop back to sell4 to pick
                        ; up where we left off and keep listening for button
                        ; presses

 RTS                    ; Otherwise a choice has been made from the icon bar, so
                        ; return from the subroutine

.sell7

                        ; If we get here then the up button is being pressed

 LDA QQ29               ; Set A to the number of the currently selected item in
                        ; QQ29

 JSR PrintMarketItem    ; Print the name, price and availability of market item
                        ; item A on the correct row for the chosen language, to
                        ; remove the highlight from the currrent item

 LDA QQ29               ; Set A = QQ29 - 1
 SEC                    ;
 SBC #1                 ; So A is the number of the item above the currently
                        ; selected item

 BPL sell8              ; If A is negative, set A = 0, so 0 is the minimum value
 LDA #0                 ; of A (so we can't move the highlight off the top of
                        ; the list of items)

.sell8

 STA QQ29               ; Store the updated item number in QQ29

.sell9

 LDA QQ29               ; Set A to the number of the currently selected item in
                        ; QQ29 (we do this so we can jump here)

 JSR HighlightSaleItem  ; Highlight the name, price and availability of market
                        ; item A on the correct row for the chosen language

 JSR DrawScreenInNMI    ; Configure the NMI handler to draw the screen, so the
                        ; screen gets updated

 JSR WaitForPPUToFinish ; Wait until both bitplanes of the screen have been
                        ; sent to the PPU, so the screen is fully updated and
                        ; there is no more data waiting to be sent to the PPU

 JMP sell4              ; Jump back to sell4 to keep listening for button
                        ; presses

.sell10

                        ; If we get here then the down button is being pressed

 LDA QQ29               ; Set A to the number of the currently selected item in
                        ; QQ29

 JSR PrintMarketItem    ; Print the name, price and availability of market item
                        ; item A on the correct row for the chosen language, to
                        ; remove the highlight from the currrent item

 LDA QQ29               ; Set A = QQ29 + 1
 CLC                    ;
 ADC #1                 ; So A is the number of the item below the currently
                        ; selected item

 CMP #17                ; If A = 17, set A = 16, so 16 is the maximum value of
 BNE sell11             ; A (so we can't move the highlight off the bottom of
 LDA #16                ; the list of items)

.sell11

 STA QQ29               ; Store the updated item number in QQ29

 JMP sell9              ; Jump up to sell9 to highlight the newly selected item
                        ; and go back to listening for button presses

.sell12

                        ; If we get here then the right button is being pressed,
                        ; so we process buying an item

 LDA #1                 ; Call tnpr with the selecred market item in QQ29 and
 JSR tnpr               ; A set to 1, to work out whether we have room in the
                        ; hold for the selected item (A is preserved by this
                        ; call, and the C flag contains the result)

 BCS sell14             ; If the C flag is set then we have no room in the hold
                        ; for the selected item, so jump to sell4 via sell14 to
                        ; abort the sale and keep listening for button presses

 LDY QQ29               ; Fetch the currently selected market item number from
                        ; QQ29 into Y

 LDA AVL,Y              ; Set A to the number of available units of the market
                        ; item in Y

 BEQ sell14             ; If there are no units available, jump to sell4 via
                        ; sell14 to abort the sale and keep listening for button
                        ; presses

 LDA QQ24               ; Set P to the item's price / 4
 STA P

 LDA #0                 ; Set A = 0, so (A P) contains the item's price / 4

 JSR GC2                ; Call GC2 to calculate:
                        ;
                        ;   (Y X) = (A P) * 4
                        ;
                        ; which will be the total price of this transaction, as
                        ; (A P) contains the item's price / 4

 JSR LCASH              ; Subtract (Y X) cash from the cash pot in CASH

 BCC sell14             ; If the C flag is clear, we didn't have enough cash,
                        ; so jump to sell4 via sell14 to abort the sale and keep
                        ; listening for button presses

 JSR UpdateSaveCount    ; Update the save counter for the current commander

 LDY #28                ; Call the NOISE routine with Y = 28 to make a trill
 JSR NOISE              ; noise to indicate that we have bought something

 LDY QQ29               ; Fetch the currently selected market item number from
                        ; QQ29 into Y

 LDA AVL,Y              ; Set A to the number of available units of the market
                        ; item in Y

 SEC                    ; Subtract 1 from the market availability, as we just
 SBC #1                 ; bought one unit
 STA AVL,Y

 LDA QQ20,Y             ; Set A to the number of units of this item that we
                        ; already have in the hold

 CLC                    ; Add 1 to the number of units and update the number in
 ADC #1                 ; the hold
 STA QQ20,Y

 JSR PrintCash          ; Print our cash levels in the correct place for the
                        ; chosen language

 JMP sell9              ; Jump up to sell9 to update the highlighted item with
                        ; the new availability and go back to listening for
                        ; button presses

.sell13

                        ; If we get here then the left button is being pressed,
                        ; so we process selling an item

 LDY QQ29               ; Fetch the currently selected market item number from
                        ; QQ29 into Y

 LDA AVL,Y              ; If there are 99 or more units available on the market,
 CMP #99                ; then the market is already saturated, so jump to sell4
 BCS sell14             ; via sell14 to abort the sale and keep listening for
                        ; button presses

 LDA QQ20,Y             ; Set A to the number of units of this item that we
                        ; already have in the hold

 BEQ sell14             ; If we don't have any items of this type in the hold,
                        ; jump to sell4 via sell14 to abort the sale and keep
                        ; listening for button presses

 JSR UpdateSaveCount    ; Update the save counter for the current commander

 SEC                    ; Subtract 1 from the number of units and update the
 SBC #1                 ; number in the hold
 STA QQ20,Y

 LDA AVL,Y              ; Add 1 to the market availability, as we just sold
 CLC                    ; one unit into the market
 ADC #1
 STA AVL,Y

 LDA QQ24               ; Set P to the item's price / 4
 STA P

 LDA #0                 ; Set A = 0, so (A P) contains the item's price / 4

 JSR GC2                ; Call GC2 to calculate:
                        ;
                        ;   (Y X) = (A P) * 4
                        ;
                        ; which will be the total price of this transaction, as
                        ; (A P) contains the item's price / 4

 JSR MCASH              ; Add (Y X) cash to the cash pot in CASH

 JSR PrintCash          ; Print our cash levels in the correct place for the
                        ; chosen language

 LDY #3                 ; Call the NOISE routine with Y = 3 to make a short,
 JSR NOISE              ; high beep to indicate that we have made a sale

 JMP sell9              ; Jump up to sell9 to update the highlighted item with
                        ; the new availability and go back to listening for
                        ; button presses

.sell14

 JMP sell4              ; Jump up to sell4 to keep listening for button presses

; ******************************************************************************
;
;       Name: HighlightSaleItem
;       Type: Subroutine
;   Category: Market
;    Summary: Highlight the name, price and availability of a market item on the
;             correct row for the chosen language
;
; ------------------------------------------------------------------------------
;
; Arguments:
;
;   A                   The item number of the market item to dsplay
;
; ******************************************************************************

.HighlightSaleItem

 TAY                    ; Set Y to the market item number

 LDX #2                 ; Set the font style to print in the highlight font
 STX fontStyle

 CLC                    ; Move the text cursor to the row for this market item,
 LDX languageIndex      ; starting from item 0 at the top, on the correct row
 ADC yMarketPrice,X     ; for the chosen language
 STA YC

 TYA                    ; Call TT151 to print the item name, market price and
 JSR TT151              ; availability of the current item, and set QQ24 to the
                        ; item's price / 4, QQ25 to the quantity available and
                        ; QQ19+1 to byte #1 from the market prices table for
                        ; this item

 LDX #1                 ; Set the font style to print in the normal font
 STX fontStyle

 RTS                    ; Return from the subroutine

; ******************************************************************************
;
;       Name: PrintMarketItem
;       Type: Subroutine
;   Category: Market
;    Summary: Print the name, price and availability of a market item on the
;             correct row for the chosen language
;
; ------------------------------------------------------------------------------
;
; Arguments:
;
;   A                   The item number of the market item to dsplay
;
; ******************************************************************************

.PrintMarketItem

 TAY                    ; Set Y to the market item number

 CLC                    ; Move the text cursor to the row for this market item,
 LDX languageIndex      ; starting from item 0 at the top, on the correct row
 ADC yMarketPrice,X     ; for the chosen language
 STA YC

 TYA                    ; Call TT151 to print the item name, market price and
 JMP TT151              ; availability of the current item, and set QQ24 to the
                        ; item's price / 4, QQ25 to the quantity available and
                        ; QQ19+1 to byte #1 from the market prices table for
                        ; this item
                        ;
                        ; When done, return from the subroutine using a tail
                        ; call

; ******************************************************************************
;
;       Name: PrintCash
;       Type: Subroutine
;   Category: Market
;    Summary: Print our cash levels in the correct place for the chosen language
;
; ******************************************************************************

.PrintCash

 LDA #%10000000         ; Set bit 7 of QQ17 to switch standard tokens to
 STA QQ17               ; Sentence Case

 LDX languageIndex      ; Move the text cursor to the correct row for the chosen
 LDA yCash,X            ; language, as given in the yCash table
 STA YC

 LDA xCash,X            ; Move the text cursor to the correct column for the
 STA XC                 ; chosen, as given in the xCash table

 JMP PCASH              ; Jump to PCASH to print recursive token 119
                        ; ("CASH:{cash} CR{crlf}"), followed by a space, and
                        ; return from the subroutine using a tail call

; ******************************************************************************
;
;       Name: xCash
;       Type: Variable
;   Category: Market
;    Summary: The text column for our cash levels on the Market Price page
;
; ******************************************************************************

.xCash

 EQUB 5                 ; English

 EQUB 5                 ; German

 EQUB 3                 ; French

 EQUB 5                 ; There is no fourth language, so this byte is ignored

; ******************************************************************************
;
;       Name: yCash
;       Type: Variable
;   Category: Market
;    Summary: The text row for the cash levels on the Market Price page
;
; ******************************************************************************

.yCash

 EQUB 22                ; English

 EQUB 23                ; German

 EQUB 22                ; French

 EQUB 22                ; There is no fourth language, so this byte is ignored

; ******************************************************************************
;
;       Name: var
;       Type: Subroutine
;   Category: Market
;    Summary: Calculate QQ19+3 = economy * |economic_factor|
;
; ------------------------------------------------------------------------------
;
; Set QQ19+3 = economy * |economic_factor|, given byte #1 of the market prices
; table for an item. Also sets the availability of alien items to 0.
;
; This routine forms part of the calculations for market item prices (TT151)
; and availability (GVL).
;
; Arguments:
;
;   QQ19+1              Byte #1 of the market prices table for this market item
;                       (which contains the economic_factor in bits 0-5, and the
;                       sign of the economic_factor in bit 7)
;
; ******************************************************************************

.var

 LDA QQ19+1             ; Extract bits 0-5 from QQ19+1 into A, to get the
 AND #31                ; economic_factor without its sign, in other words:
                        ;
                        ;   A = |economic_factor|

 LDY QQ28               ; Set Y to the economy byte of the current system

 STA QQ19+2             ; Store A in QQ19+2

 CLC                    ; Clear the C flag so we can do additions below

 LDA #0                 ; Set AVL+16 (availability of alien items) to 0,
 STA AVL+16             ; setting A to 0 in the process

.TT153

                        ; We now do the multiplication by doing a series of
                        ; additions in a loop, building the result in A. Each
                        ; loop adds QQ19+2 (|economic_factor|) to A, and it
                        ; loops the number of times given by the economy byte;
                        ; in other words, because A starts at 0, this sets:
                        ;
                        ;   A = economy * |economic_factor|

 DEY                    ; Decrement the economy in Y, exiting the loop when it
 BMI TT154              ; becomes negative

 ADC QQ19+2             ; Add QQ19+2 to A

 JMP TT153              ; Loop back to TT153 to do another addition

.TT154

 STA QQ19+3             ; Store the result in QQ19+3

 RTS                    ; Return from the subroutine

; ******************************************************************************
;
;       Name: hyp1
;       Type: Subroutine
;   Category: Universe
;    Summary: Process a jump to the system closest to (QQ9, QQ10)
;
; ------------------------------------------------------------------------------
;
; Do a hyperspace jump to the system closest to galactic coordinates
; (QQ9, QQ10), and set up the current system's state to those of the new system.
;
; Returns:
;
;   (QQ0, QQ1)          The galactic coordinates of the new system
;
;   QQ2 to QQ2+6        The seeds of the new system
;
;   EV                  Set to 0
;
;   QQ28                The new system's economy
;
;   tek                 The new system's tech level
;
;   gov                 The new system's government
;
; Other entry points:
;
;   hyp1+3              Jump straight to the system at (QQ9, QQ10) without
;                       first calculating which system is closest. We do this
;                       if we already know that (QQ9, QQ10) points to a system
;
; ******************************************************************************

.hyp1

 JSR jmp                ; Set the current system to the selected system

 LDX #5                 ; We now want to copy the seeds for the selected system
                        ; in QQ15 into QQ2, where we store the seeds for the
                        ; current system, so set up a counter in X for copying
                        ; 6 bytes (for three 16-bit seeds)

.TT112

 LDA safehouse,X        ; Copy the X-th byte in safehouse to the X-th byte in
 STA QQ2,X              ; QQ2

 STA QQ15,X             ; Copy the X-th byte in safehouse to the X-th byte in
                        ; QQ15 as well, to set the selected system

 DEX                    ; Decrement the counter

 BPL TT112              ; Loop back to TT112 if we still have more bytes to
                        ; copy

 INX                    ; Set X = 0 (as we ended the above loop with X = $FF)

 STX EV                 ; Set EV, the extra vessels spawning counter, to 0, as
                        ; we are entering a new system with no extra vessels
                        ; spawned

 LDA #%10000000         ; Set bit 7 and clear bit 6 of selectedSystemFlag, to
 STA selectedSystemFlag ; indicate that there is a currently selected system
                        ; but we can't hyperspace to it (because it is the same
                        ; as the currently selected system)

 JSR UpdateIconBar_b3   ; Update the icon bar to remove the hyperspace button
                        ; if present

 JSR TT24_b6            ; Call TT24 to calculate system data from the seeds in
                        ; QQ15 and store them in the relevant locations, so our
                        ; new selected system is fully set up

 LDA QQ3                ; Set the current system's economy in QQ28 to the
 STA QQ28               ; selected system's economy from QQ3

 LDA QQ5                ; Set the current system's tech level in tek to the
 STA tek                ; selected system's economy from QQ5

 LDA QQ4                ; Set the current system's government in gov to the
 STA gov                ; selected system's government from QQ4

                        ; Fall through into GVL to calculate the availability of
                        ; market items in the new system

; ******************************************************************************
;
;       Name: GVL
;       Type: Subroutine
;   Category: Universe
;    Summary: Calculate the availability of market items
;  Deep dive: Market item prices and availability
;             Galaxy and system seeds
;
; ------------------------------------------------------------------------------
;
; Calculate the availability for each market item and store it in AVL. This is
; called on arrival in a new system.
;
; Other entry points:
;
;   hyR                 Contains an RTS
;
; ******************************************************************************

.GVL

 JSR DORND              ; Set A and X to random numbers

 STA QQ26               ; Set QQ26 to the random byte that's used in the market
                        ; calculations

 LDX #0                 ; We are now going to loop through the market item
 STX XX4                ; availability table in AVL, so set a counter in XX4
                        ; (and X) for the market item number, starting with 0

.hy9

 LDA QQ23+1,X           ; Fetch byte #1 from the market prices table (units and
 STA QQ19+1             ; economic_factor) for item number X and store it in
                        ; QQ19+1

 JSR var                ; Call var to set QQ19+3 = economy * |economic_factor|
                        ; (and set the availability of alien items to 0)

 LDA QQ23+3,X           ; Fetch byte #3 from the market prices table (mask) and
 AND QQ26               ; AND with the random number for this system visit
                        ; to give:
                        ;
                        ;   A = random AND mask

 CLC                    ; Add byte #2 from the market prices table
 ADC QQ23+2,X           ; (base_quantity) so we now have:
                        ;
                        ;   A = base_quantity + (random AND mask)

 LDY QQ19+1             ; Fetch the byte #1 that we stored above and jump to
 BMI TT157              ; TT157 if it is negative (i.e. if the economic_factor
                        ; is negative)

 SEC                    ; Set A = A - QQ19+3
 SBC QQ19+3             ;
                        ;       = base_quantity + (random AND mask)
                        ;         - (economy * |economic_factor|)
                        ;
                        ; which is the result we want, as the economic_factor
                        ; is positive

 JMP TT158              ; Jump to TT158 to skip TT157

.TT157

 CLC                    ; Set A = A + QQ19+3
 ADC QQ19+3             ;
                        ;       = base_quantity + (random AND mask)
                        ;         + (economy * |economic_factor|)
                        ;
                        ; which is the result we want, as the economic_factor
                        ; is negative

.TT158

 BPL TT159              ; If A < 0, then set A = 0, so we don't have negative
 LDA #0                 ; availability

.TT159

 LDY XX4                ; Fetch the counter (the market item number) into Y

 AND #%00111111         ; Take bits 0-5 of A, i.e. A mod 64, and store this as
 STA AVL,Y              ; this item's availability in the Y=th byte of AVL, so
                        ; each item has a maximum availability of 63t

 INY                    ; Increment the counter into XX44, Y and A
 TYA
 STA XX4

 ASL A                  ; Set X = counter * 4, so that X points to the next
 ASL A                  ; item's entry in the four-byte market prices table,
 TAX                    ; ready for the next loop

 CMP #63                ; If A < 63, jump back up to hy9 to set the availability
 BCC hy9                ; for the next market item

.hyR

 RTS                    ; Return from the subroutine

; ******************************************************************************
;
;       Name: GTHG
;       Type: Subroutine
;   Category: Universe
;    Summary: Spawn a Thargoid ship and a Thargon companion
;  Deep dive: Fixing ship positions
;
; ******************************************************************************

.GTHG

 JSR Ze                 ; Call Ze to initialise INWK
                        ;
                        ; Note that because Ze uses the value of X returned by
                        ; DORND, and X contains the value of A returned by the
                        ; previous call to DORND, this does not set the new ship
                        ; to a totally random location. See the deep dive on
                        ; "Fixing ship positions" for details

 LDA #%11111111         ; Set the AI flag in byte #32 so that the ship has AI,
 STA INWK+32            ; is extremely and aggressively hostile, and has E.C.M.

 LDA #TGL               ; Call NWSHP to add a new Thargon ship to our local
 JSR NWSHP              ; bubble of universe

 JMP gthg1              ; Skip the following to add a Thargoid

                        ; We jump straight here if we call GTHG+15

 JSR Ze                 ; Call Ze to initialise INWK

 LDA #%11111001         ; Set the AI flag in byte #32 so that the ship has AI,
 STA INWK+32            ; is hostile and pretty aggressive (though not quite as
                        ; aggressive as the Thargoid we just added), and has
                        ; E.C.M.

.gthg1

 LDA #THG               ; Call NWSHP to add a new Thargoid ship to our local
 JMP NWSHP              ; bubble of universe, and return from the subroutine
                        ; using a tail call

; ******************************************************************************
;
;       Name: MJP
;       Type: Subroutine
;   Category: Flight
;    Summary: Process a mis-jump into witchspace
;
; ------------------------------------------------------------------------------
;
; Process a mis-jump into witchspace (which happens very rarely). Witchspace has
; a strange, almost dust-free aspect to it, and it is populated by hostile
; Thargoids. Using our escape pod will be fatal, and our position on the
; galactic chart is in-between systems. It is a scary place...
;
; There is a 0.78% chance that this routine is called from TT18 instead of doing
; a normal hyperspace, or we can manually trigger a mis-jump by holding down
; CTRL after first enabling the "author display" configuration option ("X") when
; paused.
;
; Other entry points:
;
; ******************************************************************************

.MJP

 LDY #29                ; Call the NOISE routine with Y = 29 to make the first
 JSR NOISE              ; sound of a mis-jump

 JSR RES2               ; Reset a number of flight variables and workspaces, as
                        ; well as setting Y to $FF

 STY MJ                 ; Set the mis-jump flag in MJ to $FF, to indicate that
                        ; we are now in witchspace

 LDA QQ1                ; Fetch the current system's galactic y-coordinate in
 EOR #%00011111         ; QQ1 and flip bits 0-5, so we end up somewhere in the
 STA QQ1                ; vicinity of our original destination, but above or
                        ; below it in the galactic chart

.MJP1

 JSR GTHG               ; Call GTHG three times to spawn three Thargoid ships
 JSR GTHG               ; and three Thargon companions
 JSR GTHG

 LDA #3                 ; Set NOSTM (the maximum number of stardust particles)
 STA NOSTM              ; to 3, so there are fewer bits of stardust in
                        ; witchspace (normal space has a maximum of 18)

 JSR SelectNearbySystem ; Set the current system to the nearest system to
                        ; (QQ9, QQ10) and update the selected system flags
                        ; accordingly

 JSR UpdateIconBar_b3   ; Update the icon bar to show the hyperspace icon

 LDY #30                ; Call the NOISE routine with Y = 30 to make the second
 JSR NOISE              ; sound of a mis-jump

 JMP RedrawCurrentView  ; Update the current view for when we arrive in a new
                        ; system, returning from the subroutine using a tail
                        ; call

; ******************************************************************************
;
;       Name: TT18
;       Type: Subroutine
;   Category: Flight
;    Summary: Try to initiate a jump into hyperspace
;
; ------------------------------------------------------------------------------
;
; Try to go through hyperspace. Called from TT102 in the main loop when the
; hyperspace countdown has finished.
;
; ******************************************************************************

.TT18

 JSR ResetMusicAfterNMI ; Wait for the next NMI before resetting the current
                        ; tune to 0 (no tune) and stopping the music

 LDA QQ14               ; Subtract the distance to the selected system (in QQ8)
 SEC                    ; from the amount of fuel in our tank (in QQ14) into A
 SBC QQ8

 BCS P%+4               ; If the subtraction didn't overflow, skip the next
                        ; instruction

 LDA #0                 ; The subtraction overflowed, so set A = 0 so we don't
                        ; end up with a negative amount of fuel

 STA QQ14               ; Store the updated fuel amount in QQ14

 LDA QQ11               ; If this is not the space view, then jump to hypr1 to
 BNE hypr1              ; skip drawing the hyperspace tunnel, but still make the
                        ; hyperspace sound

 JSR ClearScanner       ; Remove all ships from the scanner and hide the scanner
                        ; sprites

 JSR LL164_b6           ; Call LL164 to show the hyperspace tunnel and make the
                        ; hyperspace sound

 JMP hypr2              ; Jump to hypr2 to skip the following, as we already
                        ; the hyperspace sound in LL164

.hypr1

 JSR MakeHyperSound     ; Make the hyperspace sound for when we are not in the
                        ; space view

.hypr2

 LDA controller1Up      ; If either of the up or down buttons are being pressed,
 ORA controller1Down    ; then jump to MJP to force a mis-jump
 BMI MJP

.ee5

 JSR DORND              ; Set A and X to random numbers

 CMP #253               ; If A >= 253 (0.78% chance) then jump to MJP to trigger
 BCS MJP                ; a mis-jump into witchspace

 JSR hyp1               ; Jump straight to the system at (QQ9, QQ10)

 JSR WaitForNMI         ; Wait until the next NMI interrupt has passed (i.e. the
                        ; next VBlank)

 JSR RES2               ; Reset a number of flight variables and workspaces

 JSR SOLAR              ; Halve our legal status, update the missile indicators,
                        ; and set up data blocks and slots for the planet and
                        ; sun

; ******************************************************************************
;
;       Name: RedrawCurrentView
;       Type: Subroutine
;   Category: Drawing the screen
;    Summary: Update the current view when we arrive in a new system
;
; ******************************************************************************

.RedrawCurrentView

 LDA QQ11               ; If this is the space view (i.e. QQ11 is zero), jump to
 BEQ witc5              ; witc5 to set the current space view type to 4 and show
                        ; the front space view

 LDA QQ11               ; If the view in QQ11 is not %0000110x (i.e. 12 or 13,
 AND #%00001110         ; which are the Short-range Chart and Long-range Chart),
 CMP #%00001100         ; jump to witc2 to keep checking for other view types
 BNE witc2

 LDA QQ11               ; If the view type in QQ11 is not $9C (Short-range
 CMP #$9C               ; Chart), then this must be the Long-range Chart, so
 BNE witc1              ; jump to TT22 via witc1 to show the Long-range Chart

 JMP TT23               ; Otherwise this is the Short-range Chart, so jump to
                        ; TT23 to show the Short-range Chart, returning from the
                        ; subroutine using a tail call

.witc1

 JMP TT22               ; This is the Long-range Chart, so jump to TT22 to show
                        ; it, returning from the subroutine using a tail call

.witc2

 LDA QQ11               ; If the view type in QQ11 is not $97 (Inventory), then
 CMP #$97               ; jump to witc3 to keep checking for other view types
 BNE witc3

 JMP TT213              ; This is the Inventory screen, so jump to TT213 to show
                        ; it, returning from the subroutine using a tail call

.witc3

 CMP #$BA               ; If the view type in QQ11 is not $BA (Market Price),
 BNE witc4              ; then jump to witc4 to display the Status Mode screen

 LDA #$97               ; Set the view type in QQ11 to $97 (Inventory), so the
 STA QQ11               ; call to TT167 toggles this to the Market Price screen

 JMP TT167              ; Jump to TT167 to show the Market Price screen,
                        ; returning from the subroutine using a tail call

.witc4

 JMP STATUS             ; Jump to STATUS to display the Status Mode screen,
                        ; returning from the subroutine using a tail call

.witc5

 LDX #4                 ; If we get here then this is the space view, so set the
 STX VIEW               ; current space view to 4 to denote that we are
                        ; generating a new space view and fall through into
                        ; TT110 to show the front space view (at which point
                        ; VIEW will change to 0)

; ******************************************************************************
;
;       Name: TT110
;       Type: Subroutine
;   Category: Flight
;    Summary: Launch from a station or show the front space view
;
; ------------------------------------------------------------------------------
;
; Launch the ship (if we are docked), or show the front space view (if we are
; already in space).
;
; new galaxy, or after a hyperspace if the current view is a space view.
;
; ******************************************************************************

.TT110

 LDX QQ12               ; If we are not docked (QQ12 = 0) then jump to NLUNCH
 BEQ NLUNCH             ; to skip the launch tunnel and setup process

 LDA #0                 ; Set VIEW = 0 to switch to the front view
 STA VIEW

 STA QQ12               ; Set QQ12 = 0 to indicate that we are not docked

 LDA allowInSystemJump  ; Set bit 7 of allowInSystemJump to prevent us from
 ORA #%10000000         ; being able to do an in-system jump, as you can't jump
 STA allowInSystemJump  ; when you're in the space station's safe zone

 JSR ResetShipStatus    ; Reset the ship's speed, hyperspace counter, laser
                        ; temperature, shields and energy banks

 JSR NWSTARS            ; Set up a new stardust field

 JSR LAUN               ; Show the space station launch tunnel

 JSR RES2               ; Reset a number of flight variables and workspaces

 JSR UpdateSaveCount    ; Update the save counter for the current commander

 JSR WaitForNMI         ; Wait until the next NMI interrupt has passed (i.e. the
                        ; next VBlank)

 INC INWK+8             ; Increment z_sign ready for the call to SOS, so the
                        ; planet appears at a z_sign of 1 in front of us when
                        ; we launch

 JSR SOS1               ; Call SOS1 to set up the planet's data block and add it
                        ; to FRIN, where it will get put in the first slot as
                        ; it's the first one to be added to our local bubble of
                        ; universe following the call to RES2 above

 LDA #128               ; For the space station, set z_sign to $80, so it's
 STA INWK+8             ; behind us ($80 is negative)

 INC INWK+7             ; And increment z_hi, so it's only just behind us

 JSR NWSPS              ; Add a new space station to our local bubble of
                        ; universe

 LDA #12                ; Set our launch speed in DELTA to 12
 STA DELTA

 JSR BAD                ; Call BAD to work out how much illegal contraband we
                        ; are carrying in our hold (A is up to 40 for a
                        ; standard hold crammed with contraband, up to 70 for
                        ; an extended cargo hold full of narcotics and slaves)

 ORA FIST               ; OR the value in A with our legal status in FIST to
                        ; get a new value that is at least as high as both
                        ; values, to reflect the fact that launching with a
                        ; hold full of contraband can only make matters worse

 STA FIST               ; Update our legal status with the new value

 JSR NWSTARS            ; Set up a new stardust field

 JSR WaitForNMI         ; Wait until the next NMI interrupt has passed (i.e. the
                        ; next VBlank)

 LDX #4                 ; Set the current space view to 4, which indicates that
 STX VIEW               ; we are in the process of generating a new space view

.NLUNCH

 LDX #0                 ; Set QQ12 to 0 to indicate we are not docked
 STX QQ12

 JMP LOOK1              ; Jump to LOOK1 to switch to the front view (X = 0),
                        ; returning from the subroutine using a tail call

; ******************************************************************************
;
;       Name: TT114
;       Type: Subroutine
;   Category: Charts
;    Summary: Display either the Long-range or Short-range Chart
;
; ------------------------------------------------------------------------------
;
; Display either the Long-range or Short-range Chart, depending on the current
; view setting. Called from TT18 once we know the current view is one of the
; charts.
;
; Arguments:
;
;   A                   The current view, loaded from QQ11
;
; ******************************************************************************

.TT114

 CMP #$9C               ; If this is the Short-range Chart, skip to TT115 below
 BEQ TT115              ; to jump to TT23 to display the chart

 JMP TT22               ; Otherwise the current view is the Long-range Chart, so
                        ; jump to TT22 to display it

.TT115

 JMP TT23               ; Jump to TT23 to display the Short-range Chart

; ******************************************************************************
;
;       Name: LCASH
;       Type: Subroutine
;   Category: Maths (Arithmetic)
;    Summary: Subtract an amount of cash from the cash pot
;
; ------------------------------------------------------------------------------
;
; Subtract (Y X) cash from the cash pot in CASH, but only if there is enough
; cash in the pot. As CASH is a four-byte number, this calculates:
;
;   CASH(0 1 2 3) = CASH(0 1 2 3) - (0 0 Y X)
;
; Returns:
;
;   C flag              If set, there was enough cash to do the subtraction
;
;                       If clear, there was not enough cash to do the
;                       subtraction
;
; ******************************************************************************

.LCASH

 STX T1                 ; Subtract the least significant bytes:
 LDA CASH+3             ;
 SEC                    ;   CASH+3 = CASH+3 - X
 SBC T1
 STA CASH+3

 STY T1                 ; Then the second most significant bytes:
 LDA CASH+2             ;
 SBC T1                 ;   CASH+2 = CASH+2 - Y
 STA CASH+2

 LDA CASH+1             ; Then the third most significant bytes (which are 0):
 SBC #0                 ;
 STA CASH+1             ;   CASH+1 = CASH+1 - 0

 LDA CASH               ; And finally the most significant bytes (which are 0):
 SBC #0                 ;
 STA CASH               ;   CASH = CASH - 0

 BCS TT113              ; If the C flag is set then the subtraction didn't
                        ; underflow, so the value in CASH is correct and we can
                        ; jump to TT113 to return from the subroutine with the
                        ; C flag set to indicate success (as TT113 contains an
                        ; RTS)

                        ; Otherwise we didn't have enough cash in CASH to
                        ; subtract (Y X) from it, so fall through into
                        ; MCASH to reverse the sum and restore the original
                        ; value in CASH, and returning with the C flag clear

; ******************************************************************************
;
;       Name: MCASH
;       Type: Subroutine
;   Category: Maths (Arithmetic)
;    Summary: Add an amount of cash to the cash pot
;
; ------------------------------------------------------------------------------
;
; Add (Y X) cash to the cash pot in CASH. As CASH is a four-byte number, this
; calculates:
;
;   CASH(0 1 2 3) = CASH(0 1 2 3) + (Y X)
;
; Other entry points:
;
;   TT113               Contains an RTS
;
; ******************************************************************************

.MCASH

 SETUP_PPU_FOR_ICON_BAR ; If the PPU has started drawing the icon bar, configure
                        ; the PPU to use nametable 0 and pattern table 0

 TXA                    ; Add the least significant bytes:
 CLC                    ;
 ADC CASH+3             ;   CASH+3 = CASH+3 + X
 STA CASH+3

 TYA                    ; Then the second most significant bytes:
 ADC CASH+2             ;
 STA CASH+2             ;   CASH+2 = CASH+2 + Y

 LDA CASH+1             ; Then the third most significant bytes (which are 0):
 ADC #0                 ;
 STA CASH+1             ;   CASH+1 = CASH+1 + 0

 LDA CASH               ; And finally the most significant bytes (which are 0):
 ADC #0                 ;
 STA CASH               ;   CASH = CASH + 0

 CLC                    ; Clear the C flag, so if the above was done following
                        ; a failed LCASH call, the C flag correctly indicates
                        ; failure

.TT113

 RTS                    ; Return from the subroutine

; ******************************************************************************
;
;       Name: GC2
;       Type: Subroutine
;   Category: Maths (Arithmetic)
;    Summary: Calculate (Y X) = (A P) * 4
;
; ------------------------------------------------------------------------------
;
; Calculate the following multiplication of unsigned 16-bit numbers:
;
;   (Y X) = (A P) * 4
;
; ******************************************************************************

.GC2

 ASL P                  ; Set (A P) = (A P) * 4
 ROL A
 ASL P
 ROL A

 TAY                    ; Set (Y X) = (A P)
 LDX P

 RTS                    ; Return from the subroutine

; ******************************************************************************
;
;       Name: SetupAfterLoad
;       Type: Subroutine
;   Category: Start and end
;    Summary: Configure the game following a commander file load
;
; ------------------------------------------------------------------------------
;
; This routine is very similar to the BR1 routine.
;
; ******************************************************************************

.SetupAfterLoad

 JSR ping               ; Set the target system coordinates (QQ9, QQ10) to the
                        ; current system coordinates (QQ0, QQ1) we just loaded

 JSR TT111              ; Select the system closest to galactic coordinates
                        ; (QQ9, QQ10)

 JSR jmp                ; Set the current system to the selected system

 LDX #5                 ; We now want to copy the seeds for the selected system
                        ; in QQ15 into QQ2, where we store the seeds for the
                        ; current system, so set up a counter in X for copying
                        ; 6 bytes (for three 16-bit seeds)

.stal1

 LDA QQ15,X             ; Copy the X-th byte in QQ15 to the X-th byte in QQ2
 STA QQ2,X

 DEX                    ; Decrement the counter

 BPL stal1              ; Loop back to stal1 if we still have more bytes to copy

 INX                    ; Set X = 0 (as we ended the above loop with X = $FF)

 STX EV                 ; Set EV, the extra vessels spawning counter, to 0, as
                        ; we are entering a new system with no extra vessels
                        ; spawned

 LDA QQ3                ; Set the current system's economy in QQ28 to the
 STA QQ28               ; selected system's economy from QQ3

 LDA QQ5                ; Set the current system's tech level in tek to the
 STA tek                ; selected system's economy from QQ5

 LDA QQ4                ; Set the current system's government in gov to the
 STA gov                ; selected system's government from QQ4

 RTS                    ; Return from the subroutine

; ******************************************************************************
;
;       Name: DrawCobraMkIII
;       Type: Subroutine
;   Category: Equipment
;    Summary: Draw the Cobra Mk III on the Equip Ship screen
;
; ******************************************************************************

.DrawCobraMkIII

 LDA #20                ; Set XC and YC so the call to DrawImageNames draws the
 STA YC                 ; Cobra Mk III at text column 2 on row 20
 LDA #2
 STA XC

 LDA #26                ; Set K = 26 so the call to DrawImageNames draws 26
 STA K                  ; tiles in each row

 LDA #5                 ; Set K+1 = 5 so the call to DrawImageNames draws 5 rows
 STA K+1                ; of tiles

 LDA #HI(cobraNames)    ; Set V(1 0) = cobraNames, so the call to DrawImageNames
 STA V+1                ; draws the Cobra Mk III
 LDA #LO(cobraNames)
 STA V

 LDA #0                 ; Set K+2 = 0, so the call to DrawImageNames copies the
 STA K+2                ; entries directly from cobraNames to the nametable
                        ; buffer without adding an offset

 JSR DrawImageNames_b4  ; Draw the Cobra Mk III at text column 2 on row 20

 JMP DrawEquipment_b6   ; Draw the currently fitted equipment onto the Cobra Mk
                        ; III image, returning from the subroutine using a tail
                        ; call

; ******************************************************************************
;
;       Name: HighlightEquipment
;       Type: Subroutine
;   Category: Equipment
;    Summary: Highlight an item of equipment on the Equip Ship screen
;
; ******************************************************************************

.HighlightEquipment

 LDX #2                 ; Set the font style to print in the highlight font
 STX fontStyle

 LDX XX13               ; Set X to the item number to print

 JSR PrintEquipment+2   ; Print the name and price for the equipment item in X

 LDX #1                 ; Set the font style to print in the normal font
 STX fontStyle

 RTS                    ; Return from the subroutine

; ******************************************************************************
;
;       Name: PrintEquipment
;       Type: Subroutine
;   Category: Equipment
;    Summary: Print the name and price for a specified item of equipment
;
; ------------------------------------------------------------------------------
;
; Arguments:
;
;   XX13                The item number + 1 (i.e. 1 for fuel)
;
;   Q                   The highest item number on sale + 1
;
; Other entry points:
;
;   PrintEquipment+2    Print the item number in X
;
; ******************************************************************************

.PrintEquipment

 LDX XX13               ; Set X to the item number to print

 JSR SetupPPUForIconBar ; If the PPU has started drawing the icon bar, configure
                        ; the PPU to use nametable 0 and pattern table 0

 STX XX13               ; Store the item number in XX13, in case we entered the
                        ; routine at PrintEquipment+2

 TXA                    ; Set A = X + 2
 CLC                    ;
 ADC #2                 ; So the first item (item 1) will be on row 3, and so on

 LDX Q                  ; If Q >= 12, set A = A - 1 so we move everything up the
 CPX #12                ; screen by one line when the highest item number on
 BCC preq1              ; sale is at least 11
 SEC
 SBC #1

.preq1

 STA YC                 ; Move the text cursor to row A

 LDA #1                 ; Move the text cursor to column 1
 STA XC

 LDA languageNumber     ; If bit 1 of languageNumber is set then the chosen
 AND #%00000010         ; language is French, so jump to preq2 to skip the
 BNE preq2              ; following

 JSR TT162              ; Print a space

.preq2

 JSR TT162              ; Print a space

 LDA XX13               ; Print recursive token 104 + XX13, which will be in the
 CLC                    ; range 105 ("FUEL") to 116 ("GALACTIC HYPERSPACE ")
 ADC #104               ; so this prints the current item's name
 JSR TT27_b2

 JSR WaitForIconBarPPU  ; Wait until the PPU starts drawing the icon bar

 LDA XX13               ; If the current item number in XX13 is not 1, then it
 CMP #1                 ; is not the fuel level, so jump to preq3 to skip the
 BNE preq3              ; following (which prints the fuel level)

 LDA #' '               ; Print a space
 JSR TT27_b2

 LDA #'('               ; Print an open bracket
 JSR TT27_b2

 LDX QQ14               ; Set X to the current fuel level * 10

 SEC                    ; Set the C flag so the call to pr2+2 prints a decimal
                        ; point

 LDA #0                 ; Set the number of digits to 0 for the call to pr2+2,
                        ; so the number is not padded with spaces

 JSR pr2+2              ; Print the fuel level with a decimal point and no
                        ; padding

 LDA #195               ; Print recursive token 35 ("LIGHT YEARS")
 JSR TT27_b2

 LDA #')'               ; Print a closing bracket
 JSR TT27_b2

 LDA languageNumber     ; If bit 2 of languageNumber is set then the chosen
 AND #%00000100         ; language is French, so jump to preq3 to skip the
 BNE preq3              ; following (which prints the price)

                        ; Bit 2 of languageNumber is clear, so the chosen
                        ; language is English or German, so now we print the
                        ; price

 LDA XX13               ; Call prx-3 to set (Y X) to the price of the item with
 JSR prx-3              ; number XX13 - 1 (as XX13 contains the item number + 1)

 SEC                    ; Set the C flag so we will print a decimal point when
                        ; we print the price

 LDA #5                 ; Print the number in (Y X) to 5 digits, left-padding
 JSR TT11               ; with spaces and including a decimal point, which will
                        ; be the correct price for this item as (Y X) contains
                        ; the price * 10, so the trailing zero will go after the
                        ; decimal point (i.e. 5250 will be printed as 525.0)

 LDA #' '               ; Print a space
 JMP TT27_b2

.preq3

 LDA #' '               ; Print a space
 JSR TT27_b2

 LDA XC                 ; Loop back to print another space until XC = 24, so
 CMP #24                ; so this tabs the text cursor to column 24
 BNE preq3

 LDA XX13               ; Call prx-3 to set (Y X) to the price of the item with
 JSR prx-3              ; number XX13 - 1 (as XX13 contains the item number + 1)

 SEC                    ; Set the C flag so we will print a decimal point when
                        ; we print the price

 LDA #6                 ; Print the number in (Y X) to 6 digits, left-padding
 JSR TT11               ; with spaces and including a decimal point, which will
                        ; be the correct price for this item as (Y X) contains
                        ; the price * 10, so the trailing zero will go after the
                        ; decimal point (i.e. 5250 will be printed as 525.0)

 JMP TT162              ; Print a space and return from the subroutine using a
                        ; tail call

; ******************************************************************************
;
;       Name: MoveEquipmentUp
;       Type: Subroutine
;   Category: Equipment
;    Summary: Move the currently selected item up the list of equipment
;
; ******************************************************************************

.MoveEquipmentUp

 JSR PrintEquipment     ; Print the name and price for the equipment item in
                        ; XX13

 LDA XX13               ; Set A = XX13 - 1, so A contains the item number above
 SEC                    ; the currently selected item in the equipment list
 SBC #1

 BNE equp1              ; If XX13 is non-zero then we have not just tried to
                        ; move off the top of the list, so jump to equp1 to skip
                        ; the following instruction

 LDA #1                 ; Set A = 1 to set the currently selected item to the
                        ; first item in the list, so we don't go past the top
                        ; of the list

.equp1

 STA XX13               ; Store the new item number in XX13, so we move up the
                        ; equipment list

                        ; Fall through into UpdateEquipment to highlight the
                        ; newly chosen item of equipment, update the Cobra Mk
                        ; III, redraw the screen and rejoin the main EQSHP
                        ; routine to continue checking for button presses

; ******************************************************************************
;
;       Name: UpdateEquipment
;       Type: Subroutine
;   Category: Equipment
;    Summary: Highlight the newly chosen item of equipment, update the Cobra Mk
;             III, redraw the screen and rejoin the main EQSHP routine
;
; ******************************************************************************

.UpdateEquipment

 JSR HighlightEquipment ; Highlight the item of equipment in XX13

 JSR DrawEquipment_b6   ; Draw the currently fitted equipment onto the Cobra Mk
                        ; III image

 JSR DrawScreenInNMI    ; Configure the NMI handler to draw the screen, so the
                        ; screen gets updated

 JSR WaitForPPUToFinish ; Wait until both bitplanes of the screen have been
                        ; sent to the PPU, so the screen is fully updated and
                        ; there is no more data waiting to be sent to the PPU

 JMP equi1              ; Rejoin the main EQSHP routine at equi1 to continue
                        ; checking for button presses

; ******************************************************************************
;
;       Name: MoveEquipmentDown
;       Type: Subroutine
;   Category: Equipment
;    Summary: Move the currently selected item down the list of equipment
;
; ******************************************************************************

.MoveEquipmentDown

 JSR PrintEquipment     ; Print the name and price for the equipment item in
                        ; XX13

 LDA XX13               ; Set A = XX13 + 1, so A contains the item number below
 CLC                    ; the currently selected item in the equipment list
 ADC #1

 CMP Q                  ; If A has not reached Q, which contains the number of
 BNE eqdn1              ; items in the list plus 1, then we have not fallen off
                        ; the bottom of the list, so jump to eqdn1 to skip the
                        ; following

 LDA Q                  ; Set A = Q - 1 to set the currently selected item to
 SBC #1                 ; the bottom item in the list, so we don't go past the
                        ; bottom of the list (the subtraction works because we
                        ; just passed through a BNE, so the comparison was
                        ; equal which sets the C flag)

.eqdn1

 STA XX13               ; Store the new item number in XX13, so we move down the
                        ; equipment list

 JMP UpdateEquipment    ; Jump up to UpdateEquipment to highlight the newly
                        ; chosen item of equipment, update the Cobra Mk III,
                        ; redraw the screen and rejoin the main EQSHP routine to
                        ; continue checking for button presses

; ******************************************************************************
;
;       Name: xEquipShip
;       Type: Variable
;   Category: Equipment
;    Summary: The text column for the Equip Ship title for each language
;
; ******************************************************************************

.xEquipShip

 EQUB 12                ; English

 EQUB 8                 ; German

 EQUB 10                ; French

; ******************************************************************************
;
;       Name: EQSHP
;       Type: Subroutine
;   Category: Equipment
;    Summary: Show the Equip Ship screen
;
; ------------------------------------------------------------------------------
;
; Other entry points:
;
;   pres                Given an item number A with the item name in recursive
;                       token Y, show an error to say that the item is already
;                       present, refund the cost of the item, and then beep and
;                       exit to the docking bay (i.e. show the Status Mode
;                       screen)
;
;   equi1               A re-entry point into the key-pressing loop, used when
;                       processing key presses in subroutines
;
; ******************************************************************************

.EQSHP

 LDA #$B9               ; Clear the screen and and set the view type in QQ11 to
 JSR SetNewViewType     ; $B9 (Equip Ship)

 LDX languageIndex      ; Move the text cursor to the correct column for the
 LDA xEquipShip,X       ; Equip Ship title in the chosen language
 STA XC

 LDA #207               ; Print recursive token 47 ("EQUIP") on the top row
 JSR NLIN3

 LDA #%10000000         ; Set bit 7 of QQ17 to switch to Sentence Case, with the
 STA QQ17               ; next letter in capitals

 LDA tek                ; Fetch the tech level of the current system from tek
 CLC                    ; and add 3 (the tech level is stored as 0-14, so A is
 ADC #3                 ; now set to between 3 and 17)

 CMP #12                ; If A >= 12 then set A = 14, so A is now set to between
 BCC P%+4               ; 3 and 14
 LDA #14

 STA Q                  ; Set QQ25 = A (so QQ25 is in the range 3-14 and
 STA QQ25               ; represents number of the most advanced item available
 INC Q                  ; in this system, which we can pass to gnum below when
                        ; asking which item we want to buy)
                        ;
                        ; Set Q = A + 1 (so Q is in the range 4-15 and contains
                        ; QQ25 + 1, i.e. the highest item number on sale + 1)

 LDA #70                ; Set A = 70 - QQ14, where QQ14 contains the current
 SEC                    ; fuel in light years * 10, so this leaves the amount
 SBC QQ14               ; of fuel we need to fill 'er up (in light years * 10)

 LDX #1                 ; We are now going to work our way through the equipment
                        ; price list at PRXS, printing out the equipment that is
                        ; available at this station, so set a counter in X,
                        ; starting at 1, to hold the number of the current item
                        ; plus 1 (so the item number in X loops through 1-13)

.EQL1

 JSR PrintEquipment+2   ; Print the name and price for the equipment item in X

 LDX XX13               ; Increment the current item number in XX13
 INX

 CPX Q                  ; If X < Q, loop back up to print the next item on the
 BCC EQL1               ; list of equipment available at this station

 LDX #1                 ; Set XX13 = 1 to pass to the HighlightEquipment routine
 STX XX13               ; so we highlight the first item on the list (Fuel)

 JSR HighlightEquipment ; Highlight the item of equipment in XX13, i.e. Fuel

 JSR dn                 ; Print the amount of money we have left in the cash pot

 JSR SetScreenForUpdate ; Get the screen ready for updating by hiding all
                        ; sprites, after fading the screen to black if we are
                        ; changing view

 JSR DrawCobraMkIII     ; Draw the Cobra Mk III that we embellish with our
                        ; fitted equipment

 JSR UpdateView         ; Update the view

                        ; The Equip Ship view is now on-screen, so we move on to
                        ; checking for key presses

.equi1

 SETUP_PPU_FOR_ICON_BAR ; If the PPU has started drawing the icon bar, configure
                        ; the PPU to use nametable 0 and pattern table 0

 LDA controller1Up      ; If the up button has not been pressed, jump to equi2
 BPL equi2              ; to keep checking for other buttons

 JMP MoveEquipmentUp    ; Move the currently selected item up the list of
                        ; equipment and rejoin the loop by jumping up to equi1
                        ; to keep checking for other buttons

.equi2

 LDA controller1Down    ; If the down button has not been pressed, jump to equi3
 BPL equi3              ; to keep checking for other buttons

 JMP MoveEquipmentDown  ; Move the currently selected item down the list of
                        ; equipment and rejoin the loop by jumping up to equi1
                        ; to keep checking for other buttons

.equi3

 LDA controller1A       ; If the A button has been pressed, jump to equi4 to
 BMI equi4              ; process a purchase

 LDA iconBarChoice      ; If iconBarChoice = 0 then nothing has been chosen on
 BEQ equi1              ; the icon bar (if it had, iconBarChoice would contain
                        ; the number of the chosen icon bar button), so loop
                        ; back to equi1 to keep checking for button presses

                        ; If we get here then either a choice has been made on
                        ; the icon bar during NMI and the number of the icon bar
                        ; button is in iconBarChoice, or the Start button has
                        ; been pressed to pause the game and iconBarChoice is 80

 JSR CheckForPause      ; If the Start button has been pressed then process the
                        ; pause menu and set the C flag, otherwise clear it

 BCS equi1              ; If it was the pause button, loop back to equi1 to pick
                        ; up where we left off and keep checking for button
                        ; presses

 RTS                    ; Otherwise a choice has been made from the icon bar, so
                        ; return from the subroutine

.equi4

 JSR UpdateSaveCount    ; Update the save counter for the current commander

 LDA XX13               ; Set A = XX13 - 1, so A contains the item number of the
 SEC                    ; currently selected item, less 1, which will be the
 SBC #1                 ; actual number of the item we want to buy

 PHA                    ; Store the value of A on the stack, so we can retrieve
                        ; it after the call to eq

 JSR eq                 ; Call eq to subtract the price of the item we want to
                        ; buy (which is in A) from our cash pot

 BCS equi5              ; If we had enough cash to make the purchase, then the C
                        ; flag will be set by eq, so jump to equi5 with the
                        ; original value of A still on the stack

                        ; If we get here then we didn't have enough cash to make
                        ; the purchase

 PLA                    ; Retrieve the value of A from the stack, so A contains
                        ; the number of the item we couldn't afford

 JSR DrawScreenInNMI    ; Configure the NMI handler to draw the screen, so the
                        ; screen gets updated

 JMP equi1              ; Loop back up to equi1 to keep checking for button
                        ; presses 

.equi5

                        ; If we get here then we just successfully bought an
                        ; item of equipment

 PLA                    ; Retrieve the value of A from the stack, so A contains
                        ; the number of the item we just bought

 BNE et0                ; If A is not 0 (i.e. the item we've just bought is not
                        ; fuel), skip to et0

 PHA                    ; Store the value of A on the stack, so we can retrieve
                        ; it after the following calculation

 LDA QQ14               ; Fetch our current fuel level from Q114 into A

 CLC                    ; Increment our fuel level in A
 ADC #1

 CMP #71                ; If A < 71 then the tank is not overflowing, so jump to
 BCC equi6              ; equi6 to store the updated fuel level

 LDY #105               ; Set Y to recursive token 105 ("FUEL") to display as
                        ; the error in the call to pres

 PLA                    ; Restore A from the stack

 JMP pres               ; Jump to pres to show the error "Fuel Present", beep
                        ; and exit to the docking bay (i.e. show the Status Mode
                        ; screen)

.equi6

 STA QQ14               ; Update the fuel level in QQ14 to the value in A, as we
                        ; have just bought some fuel

 PLA                    ; Restore A from the stack, so it once again contains
                        ; the number of the item we are buying

.et0

 CMP #1                 ; If A is not 1 (i.e. the item we've just bought is not
 BNE et1                ; a missile), skip to et1

 LDX NOMSL              ; Fetch the current number of missiles from NOMSL into X

 INX                    ; Increment X to the new number of missiles

 LDY #124               ; Set Y to recursive token 124 ("ALL")

 CPX #5                 ; If buying this missile would give us 5 missiles, this
 BCS pres               ; is more than the maximum of 4 missiles that we can
                        ; fit, so jump to pres to show the error "All Present",
                        ; beep and exit to the docking bay (i.e. show the Status
                        ; Mode screen)

 STX NOMSL              ; Otherwise update the number of missiles in NOMSL

 LDA #1                 ; Set A to 1 as the call to msblob will have overwritten
                        ; the original value, and we still need it set
                        ; correctly so we can continue through the conditional
                        ; statements for all the other equipment

.et1

 LDY #107               ; Set Y to recursive token 107 ("LARGE CARGO{sentence
                        ; case} BAY")

 CMP #2                 ; If A is not 2 (i.e. the item we've just bought is not
 BNE et2                ; a large cargo bay), skip to et2

 LDX #37                ; If our current cargo capacity in CRGO is 37, then we
 CPX CRGO               ; already have a large cargo bay fitted, so jump to pres
 BEQ pres               ; to show the error "Large Cargo Bay Present", beep and
                        ; exit to the docking bay (i.e. show the Status Mode
                        ; screen)

 STX CRGO               ; Otherwise we just scored ourselves a large cargo bay,
                        ; so update our current cargo capacity in CRGO to 37

.et2

 CMP #3                 ; If A is not 3 (i.e. the item we've just bought is not
 BNE et3                ; an E.C.M. system), skip to et3

 INY                    ; Increment Y to recursive token 108 ("E.C.M.SYSTEM")

 LDX ECM                ; If we already have an E.C.M. fitted (i.e. ECM is
 BNE pres               ; non-zero), jump to pres to show the error "E.C.M.
                        ; System Present", beep and exit to the docking bay
                        ; (i.e. show the Status Mode screen)

 DEC ECM                ; Otherwise we just took delivery of a brand new E.C.M.
                        ; system, so set ECM to $FF (as ECM was 0 before the DEC
                        ; instruction)

.et3

 CMP #4                 ; If A is not 4 (i.e. the item we've just bought is not
 BNE et4                ; an extra pulse laser), skip to et4

 JSR qv                 ; Print a menu listing the four views, with a "View ?"
                        ; prompt, and ask for a view number, which is returned
                        ; in X (which now contains 0-3)

 LDA #POW+9             ; Call refund with A set to the power of the new pulse
 JMP refund             ; laser to install the new laser and process a refund if
                        ; we already have a laser fitted to this view
                        ;
                        ; The refund routine jumps back to EQSHP, so this also
                        ; redisplays the Equip Ship screen

 LDA #4                 ; Set A to 4 as we just overwrote the original value,
                        ; and we still need it set correctly so we can continue
                        ; through the conditional statements for all the other
                        ; equipment

.et4

 CMP #5                 ; If A is not 5 (i.e. the item we've just bought is not
 BNE et5                ; an extra beam laser), skip to et5

 JSR qv                 ; Print a menu listing the four views, with a "View ?"
                        ; prompt, and ask for a view number, which is returned
                        ; in X (which now contains 0-3)

 LDA #POW+128           ; Call refund with A set to the power of the new beam
 JMP refund             ; laser to install the new laser and process a refund if
                        ; we already have a laser fitted to this view
                        ;
                        ; The refund routine jumps back to EQSHP, so this also
                        ; redisplays the Equip Ship screen

.et5

 LDY #111               ; Set Y to recursive token 107 ("FUEL SCOOPS")

 CMP #6                 ; If A is not 6 (i.e. the item we've just bought is not
 BNE et6                ; a fuel scoop), skip to et6

 LDX BST                ; If we already have fuel scoops fitted (i.e. BST is
 BEQ ed9                ; zero), jump to ed9, otherwise fall through into pres
                        ; to show the error "Fuel Scoops Present", beep and
                        ; exit to the docking bay (i.e. show the Status Mode
                        ; screen)

.pres

                        ; If we get here we need to show an error to say that
                        ; the item whose name is in recursive token Y is already
                        ; present, and then process a refund for the cost of
                        ; item number A

 STY K                  ; Store the item's name in K

 PHA                    ; Wait until the next NMI interrupt has passed (i.e. the
 JSR WaitForNMI         ; next VBlank), preserving the value in A via the stack
 PLA

 JSR prx                ; Call prx to set (Y X) to the price of equipment item
                        ; number A

 JSR MCASH              ; Add (Y X) cash to the cash pot in CASH, as the station
                        ; already took the money for this item in the JSR eq
                        ; instruction above, but we can't fit the item, so need
                        ; our money back

 LDA #2                 ; Move the text cursor to column 2 on row 17
 STA XC
 LDA #17
 STA YC

 LDA K                  ; Print the recursive token in K (the item's name)
 JSR spc                ; followed by a space

 LDA #31                ; Print recursive token 145 ("PRESENT")
 JSR TT27_b2

.equi7

 JSR TT162              ; Print a space

 LDA XC                 ; If the text cursor is not in column 31, loop back to
 CMP #31                ; equi7 to keep printing spaces until it reaches column
 BNE equi7              ; 31 at the right end of the screen, so we clear up to
                        ; the end of the line containing the error message

 JSR BOOP               ; Call the BOOP routine to make a low, long beep to
                        ; indicate an error

 JSR DrawScreenInNMI    ; Configure the NMI handler to draw the screen, so the
                        ; screen gets updated

 LDY #40                ; Wait until 40 NMI interrupts have passed (i.e. the
 JSR DELAY              ; next 40 VBlanks)

 LDA #6                 ; Move the text cursor to column 6
 STA XC

 LDA #17                ; Move the text cursor to row 17
 STA YC

.equi8

 JSR TT162              ; Print a space

 LDA XC                 ; If the text cursor is not in column 31, loop back to
 CMP #31                ; equi8 to keep printing spaces until it reaches column
 BNE equi8              ; 31 at the right end of the screen, so we clear the
                        ; whole line containing the error message

 JSR dn                 ; Print the amount of money we have left in the cash pot

 JSR DrawEquipment_b6   ; Draw the currently fitted equipment onto the Cobra Mk
                        ; III image

 JSR DrawScreenInNMI    ; Configure the NMI handler to draw the screen, so the
                        ; screen gets updated

 JMP equi1              ; Loop back up to equi1 to keep checking for button
                        ; presses 

.equi9

 JMP pres               ; Jump to pres to show an error, beep and exit to the
                        ; docking bay (i.e. show the Status Mode screen)

 JSR DrawScreenInNMI    ; Configure the NMI handler to draw the screen, so the
                        ; screen gets updated

 JMP equi1              ; Loop back up to equi1 to keep checking for button
                        ; presses 

.ed9

 DEC BST                ; We just bought a shiny new fuel scoop, so set BST to
                        ; $FF (as BST was 0 before the jump to ed9 above)

.et6

 INY                    ; Increment Y to recursive token 112 ("E.C.M.SYSTEM")

 CMP #7                 ; If A is not 7 (i.e. the item we've just bought is not
 BNE et7                ; an escape pod), skip to et7

 LDX ESCP               ; If we already have an escape pod fitted (i.e. ESCP is
 BNE pres               ; non-zero), jump to pres to show the error "Escape Pod
                        ; Present", beep and exit to the docking bay (i.e. show
                        ; the Status Mode screen)

 DEC ESCP               ; Otherwise we just bought an escape pod, so set ESCP
                        ; to $FF (as ESCP was 0 before the DEC instruction)

.et7

 INY                    ; Increment Y to recursive token 113 ("ENERGY BOMB")

 CMP #8                 ; If A is not 8 (i.e. the item we've just bought is not
 BNE et8                ; an energy bomb), skip to et8

 LDX BOMB               ; If we already have an energy bomb fitted (i.e. BOMB
 BNE pres               ; is non-zero), jump to pres to show the error "Energy
                        ; Bomb Present", beep and exit to the docking bay (i.e.
                        ; show the Status Mode screen)

 LDX #$7F               ; Otherwise we just bought an energy bomb, so set BOMB
 STX BOMB               ; to $7F

.et8

 INY                    ; Increment Y to recursive token 114 ("ENERGY UNIT")

 CMP #9                 ; If A is not 9 (i.e. the item we've just bought is not
 BNE etA                ; an energy unit), skip to etA

 LDX ENGY               ; If we already have an energy unit fitted (i.e. ENGY is
 BNE equi9              ; non-zero), jump to pres via equi9 to show the error
                        ; "Energy Unit Present", beep and exit to the docking
                        ; bay (i.e. show the Status Mode screen)

 INC ENGY               ; Otherwise we just picked up an energy unit, so set
                        ; ENGY to 1 (as ENGY was 0 before the INC instruction)

.etA

 INY                    ; Increment Y to recursive token 115 ("DOCKING
                        ; COMPUTERS")

 CMP #10                ; If A is not 10 (i.e. the item we've just bought is not
 BNE etB                ; a docking computer), skip to etB

 LDX DKCMP              ; If we already have a docking computer fitted (i.e.
 BNE equi9              ; DKCMP is non-zero), jump to pres via equi9 to show the
                        ; error "Docking Computer Present", beep and exit to the
                        ; docking bay (i.e. show the Status Mode screen)

 DEC DKCMP              ; Otherwise we just got hold of a docking computer, so
                        ; set DKCMP to $FF (as DKCMP was 0 before the DEC
                        ; instruction)

.etB

 INY                    ; Increment Y to recursive token 116 ("GALACTIC
                        ; HYPERSPACE ")

 CMP #11                ; If A is not 11 (i.e. the item we've just bought is not
 BNE et9                ; a galactic hyperdrive), skip to et9

 LDX GHYP               ; If we already have a galactic hyperdrive fitted (i.e.
 BNE equi9              ; GHYP is non-zero), jump to pres via equi9 to show the
                        ; error "Galactic Hyperspace Present", beep and exit to
                        ; the docking bay (i.e. show the Status Mode screen)

 DEC GHYP               ; Otherwise we just splashed out on a galactic
                        ; hyperdrive, so set GHYP to $FF (as GHYP was 0 before
                        ; the DEC instruction)

.et9

 INY                    ; Increment Y to recursive token 117 ("MILITARY  LASER")

 CMP #12                ; If A is not 12 (i.e. the item we've just bought is not
 BNE et10               ; a military laser), skip to et10

 JSR qv                 ; Print a menu listing the four views, with a "View ?"
                        ; prompt, and ask for a view number, which is returned
                        ; in X (which now contains 0-3)

 LDA #Armlas            ; Call refund with A set to the power of the new
 JMP refund             ; military laser to install the new laser and process a
                        ; refund if we already have a laser fitted to this view
                        ;
                        ; The refund routine jumps back to EQSHP, so this also
                        ; redisplays the Equip Ship screen

.et10

 INY                    ; Increment Y to recursive token 118 ("MINING  LASER")

 CMP #13                ; If A is not 13 (i.e. the item we've just bought is not
 BNE et11               ; a mining laser), skip to et11

 JSR qv                 ; Print a menu listing the four views, with a "View ?"
                        ; prompt, and ask for a view number, which is returned
                        ; in X (which now contains 0-3)

 LDA #Mlas              ; Call refund with A set to the power of the new mining
 JMP refund             ; laser to install the new laser and process a refund if
                        ; we already have a laser fitted to this view
                        ;
                        ; The refund routine jumps back to EQSHP, so this also
                        ; redisplays the Equip Ship screen

.et11

 JSR equi10             ; Call equi10 below to print the amount of money we have
                        ; left and make a short, high beep to indicate that the
                        ; transaction was successful

 JMP UpdateEquipment    ; Jump up to UpdateEquipment to highlight the newly
                        ; bought item of equipment, update the Cobra Mk III,
                        ; redraw the screen and rejoin the main EQSHP routine to
                        ; continue checking for button presses

.equi10

 SETUP_PPU_FOR_ICON_BAR ; If the PPU has started drawing the icon bar, configure
                        ; the PPU to use nametable 0 and pattern table 0

 JSR dn                 ; Print the amount of money we have left in the cash pot

 JMP BEEP_b7            ; Call the BEEP subroutine to make a short, high beep
                        ; and return from the subroutine using a tail call

; ******************************************************************************
;
;       Name: dn
;       Type: Subroutine
;   Category: Text
;    Summary: Print the amount of money we have left in the cash pot
;
; ******************************************************************************

.dn

 LDA #17                ; Move the text cursor to column 2 on row 17
 STA YC
 LDA #2
 STA XC

 JMP PCASH              ; Jump to PCASH to print recursive token 119
                        ; ("CASH:{cash} CR{crlf}"), followed by a space, and
                        ; return from the subroutine using a tail call

; ******************************************************************************
;
;       Name: eq
;       Type: Subroutine
;   Category: Equipment
;    Summary: Subtract the price of equipment from the cash pot
;
; ------------------------------------------------------------------------------
;
; If we have enough cash, subtract the price of a specified piece of equipment
; from our cash pot and return from the subroutine. If we don't have enough
; cash, exit to the docking bay (i.e. show the Status Mode screen).
;
; Arguments:
;
;   A                   The item number of the piece of equipment (0-11) as
;                       shown in the table at PRXS
;
; Returns:
;
;   C flag              The status of the transaction:
;
;                         * Clear if we didn't have enough cash for the purchase
;
;                         * Set if we did have enough cash for the purchase
; ******************************************************************************

.eq

 JSR prx                ; Call prx to set (Y X) to the price of equipment item
                        ; number A

 JSR LCASH              ; Subtract (Y X) cash from the cash pot, but only if
                        ; we have enough cash

 BCS c                  ; If the C flag is set then we did have enough cash for
                        ; the transaction, so jump to c to return from the
                        ; subroutine (as c contains an RTS)

 LDA #17                ; Move the text cursor to column 2 on row 17
 STA YC
 LDA #2
 STA XC

 LDA #197               ; Otherwise we don't have enough cash to buy this piece
 JSR prq                ; of equipment, so print recursive token 37 ("CASH")
                        ; followed by a question mark

 JSR BOOP               ; Call the BOOP routine to make a low, long beep to
                        ; indicate that we don't have enough cash

 LDY #20                ; We now print 21 spaces, so set a counter in Y

.eqeq1

 JSR TT162              ; Print a space

 DEY                    ; Decrement the loop counter

 BPL eqeq1              ; Loop back until we have printed 21 spaces

 JSR DrawScreenInNMI    ; Configure the NMI handler to draw the screen, so the
                        ; screen gets updated

 LDY #40                ; Delay for 40 vertical syncs (40/50 = 0.8 seconds)
 JSR DELAY

 JSR dn                 ; Print the amount of money we have left in the cash pot

 CLC                    ; Clear the C flag to indicate that we didn't make the
                        ; purchase

 RTS                    ; Return from the subroutine

; ******************************************************************************
;
;       Name: prx
;       Type: Subroutine
;   Category: Equipment
;    Summary: Return the price of a piece of equipment
;
; ------------------------------------------------------------------------------
;
; This routine returns the price of equipment as listed in the table at PRXS.
;
; Arguments:
;
;   A                   The item number of the piece of equipment (0-13) as
;                       shown in the table at PRXS
;
; Returns:
;
;   (Y X)               The item price in Cr * 10 (Y = high byte, X = low byte)
;
; Other entry points:
;
;   prx-3               Return the price of the item with number A - 1
;
;   c                   Contains an RTS
;
; ******************************************************************************

 SEC                    ; Decrement A (for when this routine is called via
 SBC #1                 ; prx-3)

.prx

 ASL A                  ; Set Y = A * 2, so it can act as an index into the
 TAY                    ; PRXS table, which has two bytes per entry

 LDX PRXS,Y             ; Fetch the low byte of the price into X

 LDA PRXS+1,Y           ; Fetch the high byte of the price into A and transfer
 TAY                    ; it to X, so the price is now in (Y X)

.c

 RTS                    ; Return from the subroutine

 LDX priceDebug         ; This code is never run, but it looks like it might
 LDA #0                 ; have been used to override the price of equipment
 TAY                    ; during testing, as it sets (Y X) to (0 priceDebug)
 RTS                    ; before returning from the subroutine

; ******************************************************************************
;
;       Name: PrintLaserView
;       Type: Subroutine
;   Category: Equipment
;    Summary: Print the name of a laser view in the laser-buying popup, filled
;             to the right by the correct number of spaces to fill the popup
;
; ------------------------------------------------------------------------------
;
; Arguments:
;
;   Y                   The number of the laser view:
;
;                         * 0 = front
;                         * 1 = rear
;                         * 2 = left
;                         * 3 = right
;
; Returns:
;
;   Y                   Y is preserved
;
; ******************************************************************************

.PrintLaserView

 LDA #12                ; Move the text cursor to column 12
 STA XC

 TYA                    ; Store Y on the stack so we can retrieve it at the end
 PHA                    ; of the subroutine

 CLC                    ; Move the text cursor to row Y + 8, so we print the
 ADC #8                 ; view on row 8 (front) to 11 (right)
 STA YC

 JSR TT162              ; Print a space

 LDA languageNumber     ; If either bit 1 or bit 2 of languageNumber is set then
 AND #%00000110         ; the chosen language is German or French, so jump to
 BNE lasv1              ; lasv1 to skip the following

 JSR TT162              ; The chosen language is English, so print a space

.lasv1

 PLA                    ; Set A to the argument Y, which we stored on the stack
 PHA                    ; above

 CLC                    ; Print recursive token 96 + A, which will print from 96
 ADC #96                ; ("FRONT") through to 99 ("RIGHT")
 JSR TT27_b2

.lasv2

 JSR TT162              ; Print a space

 LDA XC                 ; Keep printing spaces until we reach the column given
 LDX languageIndex      ; in the xLaserView table for the chosen language, so we
 CMP xLaserView,X       ; blank out the rest of the line to the edge of the
 BNE lasv2              ; popup (so the popup covers what's underneath it)

 PLA                    ; Retrieve Y from the stack so it is unchanged by the
 TAY                    ; subroutine call

 RTS                    ; Return from the subroutine

; ******************************************************************************
;
;       Name: xLaserView
;       Type: Variable
;   Category: Equipment
;    Summary: The text column of the right edge of the laser-buying popup, so
;             the popup gets filled with spaces and covers what's underneath it
;
; ******************************************************************************

.xLaserView

 EQUB 21                ; English

 EQUB 21                ; German

 EQUB 22                ; French

 EQUB 21                ; There is no fourth language, so this byte is ignored

; ******************************************************************************
;
;       Name: HighlightLaserView
;       Type: Subroutine
;   Category: Equipment
;    Summary: Highlight 
;
; ------------------------------------------------------------------------------
;
; Arguments:
;
;   Y                   The number of the laser view:
;
;                         * 0 = front
;                         * 1 = rear
;                         * 2 = left
;                         * 3 = right
;
; Returns:
;
;   Y                   Y is preserved
;
; ******************************************************************************

.HighlightLaserView

 LDA #2                 ; Set the font style to print in the highlight font
 STA fontStyle

 JSR PrintLaserView     ; Print the name of the laser view specified in Y at the
                        ; correct on-screen position for the popup menu

 LDA #1                 ; Set the font style to print in the normal font
 STA fontStyle

 TYA                    ; Store Y on the stack so we can retrieve it at the end
 PHA                    ; of the subroutine

 JSR DrawScreenInNMI    ; Configure the NMI handler to draw the screen, so the
                        ; screen gets updated

 JSR WaitForPPUToFinish ; Wait until both bitplanes of the screen have been
                        ; sent to the PPU, so the screen is fully updated and
                        ; there is no more data waiting to be sent to the PPU

 PLA                    ; Retrieve Y from the stack so it is unchanged by the
 TAY                    ; subroutine call

 RTS                    ; Return from the subroutine

; ******************************************************************************
;
;       Name: popupWidth
;       Type: Variable
;   Category: Equipment
;    Summary: The width of the popup that shows the views available for
;             installing lasers in the Equipment screen
;
; ******************************************************************************

.popupWidth

 EQUB 10                ; English

 EQUB 10                ; German

 EQUB 11                ; French

 EQUB 10                ; There is no fourth language, so this byte is ignored

; ******************************************************************************
;
;       Name: qv
;       Type: Subroutine
;   Category: Equipment
;    Summary: Print a popup menu of the four space views, for buying lasers
;
; ------------------------------------------------------------------------------
;
; This routine does a similar job to the routine of the same name in the BBC
; Master version of Elite, but the code is significantly different.
;
; Returns:
;
;   X                   The chosen view number (0-3)
;
; ******************************************************************************

.qv

 JSR SetupPPUForIconBar ; If the PPU has started drawing the icon bar, configure
                        ; the PPU to use nametable 0 and pattern table 0

 LDA controller1Left03  ; If A button is being pressed, or the left or right
 ORA controller1Right03 ; buttons were being pressed four VBlanks ago, then
 ORA controller1A       ; loop back to qv until they are released
 BMI qv

 LDY #3                 ; We now print a popup menu showing all four views, so
                        ; set a view counter in Y, starting with view 3 (right)

.vpop1

 JSR PrintLaserView     ; Print the name of the laser view specified in Y at the
                        ; correct on-screen position for the popup menu

 DEY                    ; Decrement the view counter in Y

 BNE vpop1              ; Loop back to print the next view until we have printed
                        ; all four view names in the popup

                        ; Next, we highlight the first view (front) as by this
                        ; point Y = 0

 LDA #2                 ; Set the font style to print in the highlight font
 STA fontStyle

 JSR PrintLaserView     ; Print the name of the laser view specified in Y at the
                        ; correct on-screen position for the popup menu

 LDA #1                 ; Set the font style to print in the normal font
 STA fontStyle

                        ; We now draw a box around the list of views to make it
                        ; look like a popup menu

 LDA #11                ; Move the text cursor to column 11
 STA XC

 STA K+2                ; Set K+2 = 11 to pass to DrawSmallBox as the text row
                        ; on which to draw the top-left corner of the small box

 LDA #7                 ; Move the text cursor to row 7
 STA YC

 STA K+3                ; Set K+3 = 7 to pass to DrawSmallBox as the text column
                        ; on which to draw the top-left corner of the small box

 LDX languageIndex      ; Set K to the correct width for the laser view popup in
 LDA popupWidth,X       ; the chosen language, to pass to DrawSmallBox as the
 STA K                  ; width of the small box

 LDA #6                 ; Set K+1 = 6 to pass to DrawSmallBox as the height of
 STA K+1                ; the small box

 JSR DrawSmallBox_b3    ; Draw a box around the popup, with the top-left corner
                        ; at (7, 11), a height of 6 rows, and the correct width
                        ; for the chosen language

 JSR DrawScreenInNMI    ; Configure the NMI handler to draw the screen, so the
                        ; screen gets updated

                        ; The popup menu is now on-screen, so now we manage the
                        ; process of making a choice

 LDY #0                 ; We use Y to keep track of the highlighted view, which
                        ; we set to the front view above, so set Y = 0 to
                        ; reflect this

.vpop2

 JSR SetupPPUForIconBar ; If the PPU has started drawing the icon bar, configure
                        ; the PPU to use nametable 0 and pattern table 0

 LDA controller1Up      ; If the up button is not being pressed, jump to vpop4
 BPL vpop4              ; to move on to the next button check

                        ; If we get here then we need to move the highlight up
                        ; the menu, wrapping around if we go off the top

 JSR PrintLaserView     ; Print the name of the laser view specified in Y at the
                        ; correct on-screen position for the popup menu, to
                        ; remove the highlight from the current selection

 DEY                    ; Decrement Y to move the number of the selected view up
                        ; the menu

 BPL vpop3              ; If the view number is positive when we have not gone
                        ; off the top of the menu, so jump to vpop3 to skip the
                        ; following instruction

 LDY #3                 ; We just moved past the top of the menu, so set Y to 3
                        ; to move the selection to the bottom entry in the menu
                        ; (the right view)

.vpop3

 JSR HighlightLaserView ; Highlight the Y-th entry in the popup menu, to reflect
                        ; the new choice

.vpop4

 LDA controller1Down    ; If the down button is not being pressed, jump to vpop6
 BPL vpop6              ; to move on to the next button check

                        ; If we get here then we need to move the highlight down
                        ; the menu, wrapping around if we go off the bottom

 JSR PrintLaserView     ; Print the name of the laser view specified in Y at the
                        ; correct on-screen position for the popup menu, to
                        ; remove the highlight from the current selection

 INY                    ; Increment Y to move the number of the selected view
                        ; down the menu

 CPY #4                 ; If Y is not 4 then we have not gone off the bottom of
 BNE vpop5              ; the menu, so jump to vpop5 to skip the following
                        ; instruction

 LDY #0                 ; We just moved past the bottom of the menu, so set Y to
                        ; 0 to move the selection to the top entry in the menu
                        ; (the front view)

.vpop5

 JSR HighlightLaserView ; Highlight the Y-th entry in the popup menu, to reflect
                        ; the new choice

.vpop6

 LDA controller1A       ; If the A button is being pressed, jump to vpop7 to
 BMI vpop7              ; return the highlighted view as the chosen laser view

 LDA iconBarChoice      ; If iconBarChoice = 0 then nothing has been chosen on
 BEQ vpop2              ; the icon bar (if it had, iconBarChoice would contain
                        ; the number of the chosen icon bar button), so loop
                        ; back to vpop2 to keep processing the popup keys

                        ; If we get here then either a choice has been made on
                        ; the icon bar during NMI and the number of the icon bar
                        ; button is in iconBarChoice, or the Start button has
                        ; been pressed and iconBarChoice is 80

 CMP #80                ; If iconBarChoice = 80 then the Start button has been
 BNE vpop7              ; pressed to pause the game, so if this is not the case,
                        ; then a different icon bar option has been chosen, so
                        ; jump to vpop7 to return from the subroutine and abort
                        ; the laser purchase

                        ; If we get here then iconBarChoice = 80, which means
                        ; the Start button has been pressed to pause the game

 LDA #0                 ; Set iconBarChoice = 0 to clear the pause button press
 STA iconBarChoice      ; so we don't simply re-enter the pause menu when we
                        ; resume 

 JSR PauseGame_b6       ; Pause the game and process choices from the pause menu
                        ; until the game is unpaused by another press of Start

 JMP vpop2              ; Jump back to vpop2 to pick up where we left off and go
                        ; back to processing the popup choice

.vpop7

 TYA                    ; Copy the number of the highlighted laser view from Y
 TAX                    ; into X, so we can return the choice in X

 RTS                    ; Return from the subroutine

; ******************************************************************************
;
;       Name: refund
;       Type: Subroutine
;   Category: Equipment
;    Summary: Install a new laser, processing a refund if applicable
;
; ------------------------------------------------------------------------------
;
; Arguments:
;
;   A                   The power of the new laser to be fitted
;
;   X                   The view number for fitting the new laser (0-3)
;
; Returns:
;
;   A                   A is preserved
;
;   X                   X is preserved
;
; ******************************************************************************

.refund

 STA T1                 ; Store A in T1 so we can retrieve it later

 LDA LASER,X            ; If there is no laser in view X (i.e. the laser power
 BEQ ref3               ; is zero), jump to ref3 to skip the refund code

 LDY #4                 ; If the current laser has power #POW+9 (pulse laser),
 CMP #POW+9             ; jump to ref1 with Y = 4 (the item number of a pulse
 BEQ ref1               ; laser in the table at PRXS)

 LDY #5                 ; If the current laser has power #POW+128 (beam laser),
 CMP #POW+128           ; jump to ref1 with Y = 5 (the item number of a beam
 BEQ ref1               ; laser in the table at PRXS)

 LDY #12                ; If the current laser has power #Armlas (military
 CMP #Armlas            ; laser), jump to ref1 with Y = 12 (the item number of a
 BEQ ref1               ; military laser in the table at PRXS)

 LDY #13                ; Otherwise this is a mining laser, so fall through into
                        ; ref1 with Y = 13 (the item number of a mining laser in
                        ; the table at PRXS)

.ref1

                        ; We now want to refund the laser of type Y that we are
                        ; exchanging for the new laser

 STX ZZ                 ; Store the view number in ZZ so we can retrieve it
                        ; later

 TYA                    ; Copy the laser type to be refunded from Y to A

 JSR prx                ; Call prx to set (Y X) to the price of equipment item
                        ; number A

 JSR MCASH              ; Call MCASH to add (Y X) to the cash pot

 LDX ZZ                 ; Retrieve the view number from ZZ

.ref3

                        ; Finally, we install the new laser

 LDA T1                 ; Retrieve the new laser's power from T1 into A

 STA LASER,X            ; Set the laser view to the new laser's power

 JSR BEEP_b7            ; Call the BEEP subroutine to make a short, high beep

 JMP EQSHP              ; Jump back to the EQSHP routine (which called this
                        ; routine using a JMP), to redisplay the Equip Ship
                        ; screen

 RTS                    ; Return from the subroutine

; ******************************************************************************
;
;       Name: PRXS
;       Type: Variable
;   Category: Equipment
;    Summary: Equipment prices
;
; ------------------------------------------------------------------------------
;
; Equipment prices are stored as 10 * the actual value, so we can support prices
; with fractions of credits (0.1 Cr). This is used for the price of fuel only.
;
; ******************************************************************************

.PRXS

 EQUW 2                 ; 0  Fuel                         0.2 Cr (per 0.1 LY)
 EQUW 300               ; 1  Missile                     30.0 Cr
 EQUW 4000              ; 2  Large Cargo Bay            400.0 Cr
 EQUW 6000              ; 3  E.C.M. System              600.0 Cr
 EQUW 4000              ; 4  Extra Pulse Lasers         400.0 Cr
 EQUW 10000             ; 5  Extra Beam Lasers         1000.0 Cr
 EQUW 5250              ; 6  Fuel Scoops                525.0 Cr
 EQUW 10000             ; 7  Escape Pod                1000.0 Cr
 EQUW 9000              ; 8  Energy Bomb                900.0 Cr
 EQUW 15000             ; 9  Energy Unit               1500.0 Cr
 EQUW 2000              ; 10 Docking Computer           200.0 Cr
 EQUW 50000             ; 11 Galactic Hyperspace       5000.0 Cr
 EQUW 60000             ; 12 Extra Military Lasers     6000.0 Cr
 EQUW 8000              ; 13 Extra Mining Lasers        800.0 Cr

; ******************************************************************************
;
;       Name: SetSelectedSeeds
;       Type: Subroutine
;   Category: Universe
;    Summary: Set the seeds for the selected system in QQ15 to the seeds in the
;             safehouse
;
; ******************************************************************************

.SetSelectedSeeds

 LDX #5                 ; We now want to copy the seeds for the selected system
                        ; from safehouse into QQ15, where we store the seeds for
                        ; the selected system, so set up a counter in X for
                        ; copying six bytes (for three 16-bit seeds)

.safe1

 LDA safehouse,X        ; Copy the X-th byte in safehouse to the X-th byte in
 STA QQ15,X             ; QQ15

 DEX                    ; Decrement the counter

 BPL safe1              ; Loop back until we have copied all six bytes

; ******************************************************************************
;
;       Name: cpl
;       Type: Subroutine
;   Category: Text
;    Summary: Print the selected system name
;  Deep dive: Generating system names
;             Galaxy and system seeds
;
; ------------------------------------------------------------------------------
;
; Print control code 3 (the selected system name, i.e. the one in the crosshairs
; in the Short-range Chart).
;
; ******************************************************************************

.cpl

 LDX #5                 ; First we need to back up the seeds in QQ15, so set up
                        ; a counter in X to cover three 16-bit seeds (i.e.
                        ; 6 bytes)

.TT53

 LDA QQ15,X             ; Copy byte X from QQ15 to QQ19
 STA QQ19,X

 DEX                    ; Decrement the loop counter

 BPL TT53               ; Loop back for the next byte to back up

 LDY #3                 ; Step 1: Now that the seeds are backed up, we can
                        ; start the name-generation process. We will either
                        ; need to loop three or four times, so for now set
                        ; up a counter in Y to loop four times

 BIT QQ15               ; Check bit 6 of s0_lo, which is stored in QQ15

 BVS P%+3               ; If bit 6 is set then skip over the next instruction

 DEY                    ; Bit 6 is clear, so we only want to loop three times,
                        ; so decrement the loop counter in Y

 STY T                  ; Store the loop counter in T

.TT55

 SETUP_PPU_FOR_ICON_BAR ; If the PPU has started drawing the icon bar, configure
                        ; the PPU to use nametable 0 and pattern table 0

 LDA QQ15+5             ; Step 2: Load s2_hi, which is stored in QQ15+5, and
 AND #%00011111         ; extract bits 0-4 by AND'ing with %11111

 BEQ P%+7               ; If all those bits are zero, then skip the following
                        ; two instructions to go to step 3

 ORA #%10000000         ; We now have a number in the range 1-31, which we can
                        ; easily convert into a two-letter token, but first we
                        ; need to add 128 (or set bit 7) to get a range of
                        ; 129-159

 JSR TT27_b2            ; Print the two-letter token in A

 JSR TT54               ; Step 3: twist the seeds in QQ15

 DEC T                  ; Decrement the loop counter

 BPL TT55               ; Loop back for the next two letters

 LDX #5                 ; We have printed the system name, so we can now
                        ; restore the seeds we backed up earlier. Set up a
                        ; counter in X to cover three 16-bit seeds (i.e. 6
                        ; bytes)

.TT56

 LDA QQ19,X             ; Copy byte X from QQ19 to QQ15
 STA QQ15,X

 DEX                    ; Decrement the loop counter

 BPL TT56               ; Loop back for the next byte to restore

 RTS                    ; Once all the seeds are restored, return from the
                        ; subroutine

; ******************************************************************************
;
;       Name: cmn
;       Type: Subroutine
;   Category: Text
;    Summary: Print the commander's name
;
; ------------------------------------------------------------------------------
;
; Print control code 4 (the commander's name).
;
; Other entry points:
;
;   cmn-1               Contains an RTS
;
; ******************************************************************************

.cmn

 LDY #0                 ; Set up a counter in Y, starting from 0

.QUL4

 LDA NAME,Y             ; The commander's name is stored at NAME, so load the
                        ; Y-th character from NAME

 CMP #' '               ; If we have found a space, then we have reached the end
 BEQ ypl-1              ; of the name, return from the subroutine (ypl-1 points
                        ; to the RTS below)

 JSR DASC_b2            ; Print the character we just loaded

 INY                    ; Increment the loop counter

 CPY #7                 ; Loop back for the next character until we have either
 BNE QUL4               ; found a carriage return or have printed seven
                        ; characters

 RTS                    ; Return from the subroutine

; ******************************************************************************
;
;       Name: ypl
;       Type: Subroutine
;   Category: Text
;    Summary: Print the current system name
;
; ------------------------------------------------------------------------------
;
; Print control code 2 (the current system name).
;
; Other entry points:
;
;   ypl-1               Contains an RTS
;
; ******************************************************************************

.ypl

 BIT MJ                 ; Check the mis-jump flag at MJ, and if bit 7 is set
 BMI ypl16              ; then we are in witchspace, and witchspace doesn't have
                        ; a system name, so jump to ypl16 to return from the
                        ; subroutine

 JSR TT62               ; Call TT62 below to swap the three 16-bit seeds in
                        ; QQ2 and QQ15 (before the swap, QQ2 contains the seeds
                        ; for the current system, while QQ15 contains the seeds
                        ; for the selected system)

 JSR cpl                ; Call cpl to print out the system name for the seeds
                        ; in QQ15 (which now contains the seeds for the current
                        ; system)

                        ; Now we fall through into the TT62 subroutine, which
                        ; will swap QQ2 and QQ15 once again, so everything goes
                        ; back into the right place, and the RTS at the end of
                        ; TT62 will return from the subroutine

.TT62

 LDX #5                 ; Set up a counter in X for the three 16-bit seeds we
                        ; want to swap (i.e. 6 bytes)

.TT78

 LDA QQ15,X             ; Swap byte X between QQ2 and QQ15
 LDY QQ2,X
 STA QQ2,X
 STY QQ15,X

 DEX                    ; Decrement the loop counter

 BPL TT78               ; Loop back for the next byte to swap

.ypl16

 RTS                    ; Once all bytes are swapped, return from the
                        ; subroutine

; ******************************************************************************
;
;       Name: tal
;       Type: Subroutine
;   Category: Text
;    Summary: Print the current galaxy number
;
; ------------------------------------------------------------------------------
;
; Print control code 1 (the current galaxy number, right-aligned to width 3).
;
; ******************************************************************************

.tal

 CLC                    ; We don't want to print the galaxy number with a
                        ; decimal point, so clear the C flag for pr2 to take as
                        ; an argument

 LDX GCNT               ; Load the current galaxy number from GCNT into X

 INX                    ; Add 1 to the galaxy number, as the galaxy numbers
                        ; are 0-7 internally, but we want to display them as
                        ; galaxy 1 through 8

 JMP pr2                ; Jump to pr2, which prints the number in X to a width
                        ; of 3 figures, left-padding with spaces to a width of
                        ; 3, and return from the subroutine using a tail call

; ******************************************************************************
;
;       Name: fwl
;       Type: Subroutine
;   Category: Text
;    Summary: Print fuel and cash levels
;
; ------------------------------------------------------------------------------
;
; Print control code 5 ("FUEL: ", fuel level, " LIGHT YEARS", newline, "CASH:",
; control code 0).
;
; Other entry points:
;
;   PCASH               Print the amount of cash only
;
; ******************************************************************************

.fwl

 LDA languageNumber     ; If bit 1 of languageNumber is set then the chosen
 AND #%00000010         ; language is French, so jump to fuel3 to print the fuel
 BNE fuel3              ; and cash levels with different indents, to cater for
                        ; the difference in language

 LDA #105               ; Print recursive token 105 ("FUEL") followed by a
 JSR TT68               ; colon

 JSR Print2Spaces       ; Print two spaces

 LDA languageNumber     ; If bit 2 of languageNumber is clear then the chosen
 AND #%00000100         ; language is not French, so jump to fuel1 to skip the
 BEQ fuel1              ; following

 JSR Print2Spaces       ; Print two spaces

.fuel1

 LDX QQ14               ; Load the current fuel level from QQ14

 SEC                    ; We want to print the fuel level with a decimal point,
                        ; so set the C flag for pr2 to take as an argument

 JSR pr2                ; Call pr2, which prints the number in X to a width of
                        ; 3 figures (i.e. in the format x.x, which will always
                        ; be exactly 3 characters as the maximum fuel is 7.0)

 LDA #195               ; Print recursive token 35 ("LIGHT YEARS") followed by
 JSR plf                ; a newline

 LDA #197               ; Print recursive token 37 ("CASH") followed by a colon
 JSR TT68

 LDA languageNumber     ; If bit 2 of languageNumber is set then the chosen
 AND #%00000100         ; language is French, so jump to fuel2 to skip the
 BNE fuel2              ; following two instructions

 JSR Print2Spaces       ; Print two spaces

 JSR TT162              ; Print a space

.fuel2

 LDA #0                 ; Set A = 0 so we print recursive token 0 at fuel4,
                        ; which prints control code 0 (current amount of cash
                        ; and newline)

 BEQ fuel4              ; Jump to fuel4 to print the token in A (this BNE is
                        ; effectively a JMP as A is always zero)

.fuel3

                        ; If we get here then the chosen language is French

 LDA #105               ; Print recursive token 105 ("FUEL") followed by a
 JSR PrintTokenAndColon ; colon, ensuring that the colon is printed in green
                        ; despite being in a 2x2 attribute block set for white
                        ; text

 JSR TT162              ; Print a space

 LDX QQ14               ; Load the current fuel level from QQ14

 SEC                    ; We want to print the fuel level with a decimal point,
                        ; so set the C flag for pr2 to take as an argument

 JSR pr2                ; Call pr2, which prints the number in X to a width of
                        ; 3 figures (i.e. in the format x.x, which will always
                        ; be exactly 3 characters as the maximum fuel is 7.0)

 LDA #195               ; Print recursive token 35 ("LIGHT YEARS") followed by
 JSR plf                ; a newline

 LDA #197               ; Print recursive token 37 ("CASH") followed by a colon
 JSR TT68

 LDA #0                 ; Set A = 0 so we print recursive token 0 at fuel4,
                        ; which prints control code 0 (current amount of cash
                        ; and newline)

 BEQ fuel4              ; Jump to fuel4 to print the token in A (this BNE is
                        ; effectively a JMP as A is always zero)

.PCASH

 LDA #119               ; Set A = 119 so we print recursive token 119 below
                        ; ("CASH:" then control code 0, which prints cash
                        ; levels, then " CR" and newline)

.fuel4

 JMP spc                ; Print the recursive token in A and return from the
                        ; subroutine using a tail call

; ******************************************************************************
;
;       Name: Print4Spaces
;       Type: Subroutine
;   Category: Text
;    Summary: An unused routine that prints four spaces
;
; ******************************************************************************

.Print4Spaces

 JSR Print2Spaces       ; Print two spaces

                        ; Fall through into Print2Spaces to print another two
                        ; newlines

; ******************************************************************************
;
;       Name: Print2Spaces
;       Type: Subroutine
;   Category: Text
;    Summary: Print two spaces
;
; ******************************************************************************

.Print2Spaces

 JSR TT162              ; Print two spaces, returning from the subroutin using a
 JMP TT162              ; tail call

; ******************************************************************************
;
;       Name: ypls
;       Type: Subroutine
;   Category: Text
;    Summary: Print the current system name
;
; ******************************************************************************

.ypls

 JMP ypl                ; Jump to ypl to print the current system name and
                        ; return from the subroutine using a tail call

; ******************************************************************************
;
;       Name: csh
;       Type: Subroutine
;   Category: Text
;    Summary: Print the current amount of cash
;
; ------------------------------------------------------------------------------
;
; Print control code 0 (the current amount of cash, right-aligned to width 9,
; followed by " CR" and a newline).
;
; ******************************************************************************

.csh

 LDX #3                 ; We are going to use the BPRNT routine to print out
                        ; the current amount of cash, which is stored as a
                        ; 32-bit number at location CASH. BPRNT prints out
                        ; the 32-bit number stored in K, so before we call
                        ; BPRNT, we need to copy the four bytes from CASH into
                        ; K, so first we set up a counter in X for the 4 bytes

.pc1

 LDA CASH,X             ; Copy byte X from CASH to K
 STA K,X

 DEX                    ; Decrement the loop counter

 BPL pc1                ; Loop back for the next byte to copy

 LDA #11                ; We want to print the cash amount using up to 11 digits
 STA U                  ; (including the decimal point), so store this in U
                        ; for BRPNT to take as an argument

 SEC                    ; We want to print the cash amount with a decimal point,
                        ; so set the C flag for BRPNT to take as an argument

 JSR BPRNT              ; Print the amount of cash to 9 digits with a decimal
                        ; point

 LDA #226               ; Print recursive token 66 (" CR")
 JSR TT27_b2

 JSR TT162              ; Print two spaces and return from the subroutine using
 JMP TT162              ; a tail call

; ******************************************************************************
;
;       Name: plf
;       Type: Subroutine
;   Category: Text
;    Summary: Print a text token followed by a newline
;
; ------------------------------------------------------------------------------
;
; Arguments:
;
;   A                   The text token to be printed
;
; ******************************************************************************

.plf

 JSR TT27_b2            ; Print the text token in A

 JMP TT67               ; Jump to TT67 to print a newline and return from the
                        ; subroutine using a tail call

; ******************************************************************************
;
;       Name: TT68
;       Type: Subroutine
;   Category: Text
;    Summary: Print a text token followed by a colon
;
; ------------------------------------------------------------------------------
;
; Arguments:
;
;   A                   The text token to be printed
;
; ******************************************************************************

.TT68

 JSR TT27_b2            ; Print the text token in A and fall through into TT73
                        ; to print a colon

; ******************************************************************************
;
;       Name: TT73
;       Type: Subroutine
;   Category: Text
;    Summary: Print a colon
;
; ******************************************************************************

.TT73

 LDA #':'               ; Print a colon, returning from the subroutine using a
 JMP TT27_b2            ; tail call

; ******************************************************************************
;
;       Name: tals
;       Type: Subroutine
;   Category: Text
;    Summary: Print the current galaxy number
;
; ******************************************************************************

.tals

 JMP tal                ; Jump to tal to print the current galaxy number and
                        ; return from the subroutine using a tail call

; ******************************************************************************
;
;       Name: PrintCtrlCode
;       Type: Subroutine
;   Category: Text
;    Summary: Print a control code (in the range 0 to 9)
;
; ******************************************************************************

.PrintCtrlCode

 TXA                    ; Copy the token number from X to A. We can then keep
                        ; decrementing X and testing it against zero, while
                        ; keeping the original token number intact in A; this
                        ; effectively implements a switch statement on the
                        ; value of the token

 BEQ csh                ; If token = 0, this is control code 0 (current amount
                        ; of cash and newline), so jump to csh to print the
                        ; amount of cash and return from the subroutine using
                        ; a tail call

 DEX                    ; If token = 1, this is control code 1 (current galaxy
 BEQ tals               ; number), so jump to tal via tals to print the galaxy
                        ; number and return from the subroutine using a tail
                        ; call

 DEX                    ; If token = 2, this is control code 2 (current system
 BEQ ypls               ; name), so jump to ypl via ypls to print the current
                        ; system name  and return from the subroutine using a
                        ; tail call

 DEX                    ; If token > 3, skip the following instruction
 BNE P%+5

 JMP cpl                ; This token is control code 3 (selected system name)
                        ; so jump to cpl to print the selected system name
                        ; and return from the subroutine using a tail call

 DEX                    ; If token <> 4, skip the following instruction
 BNE P%+5

 JMP cmn                ; This token is control code 4 (commander name) so jump
                        ; to cmn to print the commander name and return from the
                        ; subroutine using a tail call

 DEX                    ; If token = 5, this is control code 5 (fuel, newline,
 BEQ fwls               ; cash, newline), so jump to fwl via fwls to print the
                        ; fuel level and return from the subroutine using a tail
                        ; call

 DEX                    ; If token > 6, skip the following three instructions
 BNE ptok2

 LDA #%10000000         ; This token is control code 6 (switch to Sentence
 STA QQ17               ; Case), so set bit 7 of QQ17 to switch to Sentence Case

.ptok1

 RTS                    ; Return from the subroutine

.ptok2

 DEX                    ; If token = 7, this is control code 7 (beep), so jump
 BEQ ptok1              ; to ptok1 to return from the subroutine

 DEX                    ; If token > 8, jump to ptok3
 BNE ptok3

 STX QQ17               ; This is control code 8, so set QQ17 = 0 to switch to
                        ; ALL CAPS (we know X is zero as we just passed through
                        ; a BNE)

 RTS                    ; Return from the subroutine

.ptok3

                        ; If we get here then token > 8, so this is control code
                        ; 9 (print a colon then tab to column 22 or 23)

 JSR TT73               ; Print a colon

 LDA languageNumber     ; If bit 1 of languageNumber is set, then the chosen
 AND #%00000010         ; language is German, so jump to ptok4 to move the text
 BNE ptok4              ; cursor to column 23

 LDA #22                ; Bit 1 of languageNumber is clear, so the chosen
 STA XC                 ; language is English or French, so move the text cursor
                        ; to column 22

 RTS                    ; Return from the subroutine

.ptok4

 LDA #23                ; Move the text cursor to column 23
 STA XC

 RTS                    ; Return from the subroutine

; ******************************************************************************
;
;       Name: fwls
;       Type: Subroutine
;   Category: Text
;    Summary: Print fuel and cash levels
;
; ******************************************************************************

.fwls

 JMP fwl                ; Jump to fwl to print the fuel and cash levels, and
                        ; return from the subroutine using a tail call

; ******************************************************************************
;
;       Name: SOS1
;       Type: Subroutine
;   Category: Universe
;    Summary: Update the missile indicators, set up the planet data block
;
; ------------------------------------------------------------------------------
;
; Update the missile indicators, and set up a data block for the planet, but
; only setting the pitch and roll counters to 127 (no damping).
;
; ******************************************************************************

.SOS1

 JSR msblob             ; Reset the dashboard's missile indicators so none of
                        ; them are targeted

 LDA #127               ; Set the pitch and roll counters to 127 (no damping
 STA INWK+29            ; so the planet's rotation doesn't slow down)
 STA INWK+30

 LDA tek                ; Set A = 128 or 130 depending on bit 1 of the system's
 AND #%00000010         ; tech level in tek
 ORA #%10000000

 JMP NWSHP              ; Add a new planet to our local bubble of universe,
                        ; with the planet type defined by A (128 is a planet
                        ; with an equator and meridian, 130 is a planet with
                        ; a crater)

; ******************************************************************************
;
;       Name: SOLAR
;       Type: Subroutine
;   Category: Universe
;    Summary: Set up various aspects of arriving in a new system
;
; ------------------------------------------------------------------------------
;
; Halve our legal status, update the missile indicators, and set up data blocks
; and slots for the planet and sun.
;
; ******************************************************************************

.SOLAR

 LDA TRIBBLE            ; If we have no Trumbles in the hold, skip to nobirths
 BEQ nobirths

                        ; If we get here then we have Trumbles in the hold, so
                        ; this is where they breed

 LDA #0                 ; Trumbles eat food during the hyperspace journey, so
 STA QQ20               ; zero the amount of food in the hold

 JSR DORND              ; Take the number of Trumbles from TRIBBLE(1 0), add a
 AND #15                ; random number between 4 and 15, and double the result,
 ADC TRIBBLE            ; storing the resulting number in TRIBBLE(1 0)
 ORA #4                 ;
 ROL A                  ; We start with the low byte
 STA TRIBBLE

 ROL TRIBBLE+1          ; And then do the high byte

 BPL P%+5               ; If bit 7 of the high byte is set, then rotate the high
 ROR TRIBBLE+1          ; byte back to the right, so the number of Trumbles is
                        ; always positive

.nobirths

 LSR FIST               ; Halve our legal status in FIST, making us less bad,
                        ; and moving bit 0 into the C flag (so every time we
                        ; arrive in a new system, our legal status improves a
                        ; bit)

 JSR ZINF               ; Call ZINF to reset the INWK ship workspace, which
                        ; doesn't affect the C flag

 LDA QQ15+1             ; Fetch s0_hi

 AND #%00000011         ; Extract bits 0-1 (which also help to determine the
                        ; economy), which will be between 0 and 3

 ADC #3                 ; Add 3 + C, to get a result between 3 and 7, clearing
                        ; the C flag in the process

 STA INWK+8             ; Store the result in z_sign in byte #6

 LDX QQ15+2             ; Set the C flag if s1_lo >= 128, otherwise clear it
 CPX #128

 ROR A                  ; Halve A and set the sign bit to the C flag, and set
 STA INWK+2             ; x_sign to the result, so this moves the planet to the
                        ; right or left of centre

 ROL A                  ; Set A to x_sign << 1, ready for us to roll in the
                        ; sign bit again for y_sign

 LDX QQ15+3             ; Set the C flag if s1_hi >= 128, otherwise clear it
 CPX #128

 ROR A                  ; Set the sign bit to the C flag and set y_sign to the
 STA INWK+5             ; result, so this moves the planet up or down from the
                        ; centre

 JSR SOS1               ; Call SOS1 to set up the planet's data block and add it
                        ; to FRIN, where it will get put in the first slot as
                        ; it's the first one to be added to our local bubble of
                        ; this new system's universe

 LDA QQ15+3             ; Fetch s1_hi, extract bits 0-2, set bits 0 and 7 and
 AND #%00000111         ; store in z_sign, so the sun is behind us at a distance
 ORA #%10000001         ; of 1 to 7
 STA INWK+8

 LDA QQ15+5             ; Fetch s2_hi, extract bits 0-1 and store in x_sign and
 AND #%00000011         ; y_sign, so the sun is either dead centre in our rear
 STA INWK+2             ; laser crosshairs, or off to the top left by a distance
 STA INWK+1             ; of 1 or 2 when we look out the back

 LDA #0                 ; Set the pitch and roll counters to 0 (no rotation)
 STA INWK+29
 STA INWK+30

 STA FRIN+1             ; Set the second slot in the FRIN table to 0, which
                        ; sets this slot to empty, so when we call NWSHP below
                        ; the new sun that gets created will go into FRIN+1

 STA SSPR               ; Set the "space station present" flag to 0, as we are
                        ; no longer in the space station's safe zone

 LDA #129               ; Set A = 129, the ship type for the sun

 JSR NWSHP              ; Call NWSHP to set up the sun's data block and add it
                        ; to FRIN, where it will get put in the second slot as
                        ; it's the second one to be added to our local bubble
                        ; of this new system's universe

; ******************************************************************************
;
;       Name: NWSTARS
;       Type: Subroutine
;   Category: Stardust
;    Summary: Initialise the stardust field
;
; ------------------------------------------------------------------------------
;
; This routine is called when the space view is initialised in routine LOOK1.
;
; ******************************************************************************

.NWSTARS

 LDA QQ11               ; If this is not a space view (in which case QQ11 > 0),
 ORA demoInProgress     ; or demoInProgress > 0 (in which case we are playing
 BNE WPSHPS             ; the demo), jump to WPSHPS to skip the initialisation
                        ; of the SX, SY and SZ tables

; ******************************************************************************
;
;       Name: nWq
;       Type: Subroutine
;   Category: Stardust
;    Summary: Create a random cloud of stardust
;
; ------------------------------------------------------------------------------
;
; Create a random cloud of stardust containing the correct number of dust
; particles, i.e. NOSTM of them, which is 3 in witchspace and 20 (#NOST) in
; normal space. Also hides ships from the screen.
;
; This is called by the DEATH routine when it displays our untimely demise.
;
; ******************************************************************************

.nWq

 LDA nmiCounter         ; Set the random number seeds to a fairly random state
 CLC                    ; that's based on the NMI counter (which increments
 ADC RAND               ; every VBlank, so will be pretty random)
 STA RAND
 LDA nmiCounter
 STA RAND+1

 LDY NOSTM              ; Set Y to the current number of stardust particles, so
                        ; we can use it as a counter through all the stardust

.SAL4

 SETUP_PPU_FOR_ICON_BAR ; If the PPU has started drawing the icon bar, configure
                        ; the PPU to use nametable 0 and pattern table 0

 JSR DORND              ; Set A and X to random numbers

 ORA #8                 ; Set A so that it's at least 8

 STA SZ,Y               ; Store A in the Y-th particle's z_hi coordinate at
                        ; SZ+Y, so the particle appears in front of us

 STA ZZ                 ; Set ZZ to the particle's z_hi coordinate

 JSR DORND              ; Set A and X to random numbers

 ORA #16                ; Set A so that it's at least 16

 AND #%11111000         ; Zero bits 0 to 2 of A so that it's a multiple of 8

 STA SX,Y               ; Store A in the Y-th particle's x_hi coordinate at
                        ; SX+Y, so the particle appears in front of us

 JSR DORND              ; Set A and X to random numbers

 STA SY,Y               ; Store A in the Y-th particle's y_hi coordinate at
                        ; SY+Y, so the particle appears in front of us

 STA SXL,Y              ; Store A in the low bytes of the Y-th particle's three
 STA SYL,Y              ; coordinates
 STA SZL,Y

 DEY                    ; Decrement the counter to point to the next particle of
                        ; stardust

 BNE SAL4               ; Loop back to SAL4 until we have randomised all the
                        ; stardust particles

                        ; Fall through into WPSHPS to hide ships from the screen

; ******************************************************************************
;
;       Name: WPSHPS
;       Type: Subroutine
;   Category: Dashboard
;    Summary: Set all ships to be hidden from the screen
;
; ******************************************************************************

.WPSHPS

 LDX #0                 ; Set up a counter in X to work our way through all the
                        ; ship slots in FRIN

.WSL1

 SETUP_PPU_FOR_ICON_BAR ; If the PPU has started drawing the icon bar, configure
                        ; the PPU to use nametable 0 and pattern table 0

 LDA FRIN,X             ; Fetch the ship type in slot X

 BEQ WS2                ; If the slot contains 0 then it is empty and we have
                        ; checked all the slots (as they are always shuffled
                        ; down in the main loop to close up and gaps), so jump
                        ; to WS2 as we are done

 BMI WS1                ; If the slot contains a ship type with bit 7 set, then
                        ; it contains the planet or the sun, so jump down to WS1
                        ; to skip this slot, as the planet and sun don't appear
                        ; on the scanner

 STA TYPE               ; Store the ship type in TYPE

 JSR GINF               ; Call GINF to get the address of the data block for
                        ; ship slot X and store it in INF

 LDY #31                ; Clear bits 3 and 6 in the ship's byte #31, which
 LDA (INF),Y            ; stops drawing the ship on-screen (bit 3), and stops
 AND #%10110111         ; any lasers firing (bit 6)
 STA (INF),Y

.WS1

 INX                    ; Increment X to point to the next ship slot

 BNE WSL1               ; Loop back up to process the next slot (this BNE is
                        ; effectively a JMP as X will never be zero)

.WS2

 LDX #0                 ; Set X = 0 (though this appears not to be used)

 RTS                    ; Return from the subroutine

; ******************************************************************************
;
;       Name: SHD
;       Type: Subroutine
;   Category: Flight
;    Summary: Charge a shield and drain some energy from the energy banks
;
; ------------------------------------------------------------------------------
;
; Charge up a shield, and if it needs charging, drain some energy from the
; energy banks.
;
; Arguments:
;
;   X                   The value of the shield to recharge
;
; ******************************************************************************

 DEX                    ; Increment the shield value so that it doesn't go past
                        ; a maximum of 255

 RTS                    ; Return from the subroutine

.SHD

 INX                    ; Increment the shield value

 BEQ SHD-2              ; If the shield value is 0 then this means it was 255
                        ; before, which is the maximum value, so jump to SHD-2
                        ; to bring it back down to 258 and return

                        ; Otherwise fall through into DENGY to drain our energy
                        ; to pay for all this shield charging

; ******************************************************************************
;
;       Name: DENGY
;       Type: Subroutine
;   Category: Flight
;    Summary: Drain some energy from the energy banks
;
; ------------------------------------------------------------------------------
;
; Returns:
;
;   Z flag              Set if we have no energy left, clear otherwise
;
; ******************************************************************************

.DENGY

 DEC ENERGY             ; Decrement the energy banks in ENERGY

 PHP                    ; Save the flags on the stack

 BNE paen2              ; If the energy levels are not yet zero, skip the
                        ; following instruction

 INC ENERGY             ; The minimum allowed energy level is 1, and we just
                        ; reached 0, so increment ENERGY back to 1

.paen2

 PLP                    ; Restore the flags from the stack, so we return with
                        ; the Z flag from the DEC instruction above

 RTS                    ; Return from the subroutine

; ******************************************************************************
;
;       Name: COMPAS
;       Type: Subroutine
;   Category: Dashboard
;    Summary: Update the compass
;
; ******************************************************************************

.comp1

 LDA #240               ; Hide sprite 13 (the compass dot) by moving it to
 STA ySprite13          ; y-coordinate 240, off the bottom of the screen

 RTS                    ; Return from the subroutine

.COMPAS

 LDA MJ                 ; If we are in witchspace (i.e. MJ is non-zero), jump up
 BNE comp1              ; to comp1 to hide the compass dot

 LDA SSPR               ; If we are inside the space station safe zone, jump to
 BNE SP1                ; SP1 to draw the space station on the compass

 JSR SPS1               ; Otherwise we need to draw the planet on the compass,
                        ; so first call SPS1 to calculate the vector to the
                        ; planet and store it in XX15

 JMP SP2                ; Jump to SP2 to draw XX15 on the compass, returning
                        ; from the subroutine using a tail call

; ******************************************************************************
;
;       Name: SP1
;       Type: Subroutine
;   Category: Dashboard
;    Summary: Draw the space station on the compass
;
; ******************************************************************************

.SP1

 JSR SPS4               ; Call SPS4 to calculate the vector to the space station
                        ; and store it in XX15

                        ; Fall through into SP2 to draw XX15 on the compass

; ******************************************************************************
;
;       Name: SP2
;       Type: Subroutine
;   Category: Dashboard
;    Summary: Draw a dot on the compass, given the planet/station vector
;
; ------------------------------------------------------------------------------
;
; Draw a dot on the compass to represent the planet or station, whose normalised
; vector is in XX15.
;
;   XX15 to XX15+2      The normalised vector to the planet or space station,
;                       stored as x in XX15, y in XX15+1 and z in XX15+2
;
; ******************************************************************************

.SP2

 LDA XX15               ; Set A to the x-coordinate of the planet or station to
                        ; show on the compass, which will be in the range -96 to
                        ; +96 as the vector has been normalised

 JSR SPS2               ; Set X = A / 16, so X will be from -6 to +6, which
                        ; is the x-offset from the centre of the compass of the
                        ; dot we want to draw. Returns with the C flag clear

 TXA                    ; Set the x-coordinate of sprite 13 (the compass dot) to
 CLC                    ; 220 + X, as 220 is the pixel x-coordinate of the
 ADC #220               ; centre of the compass, and X is in the range -6 to +6,
 STA xSprite13          ; so the dot is in the x-coordinate range 214 to 226

 LDA XX15+1             ; Set A to the y-coordinate of the planet or station to
                        ; show on the compass, which will be in the range -96 to
                        ; +96 as the vector has been normalised

 JSR SPS2               ; Set X = A / 16, so X will be from -6 to +6, which
                        ; is the x-offset from the centre of the compass of the
                        ; dot we want to draw. Returns with the C flag clear

                        ; We now set the y-coordinate of sprite 13 (the compass
                        ; dot) to 186, as 186 is the pixel y-coordinate of the
                        ; centre of the compass, and X is in the range -6 to +6,
                        ; so the dot is in the y-coordinate range 180 to 192

 STX T                  ; Set T = X for use in the calculation below

 LDA #186+YPAL          ; Set A to the pixel y-coordinate of the compass centre

 SEC                    ; Set the y-coordinate of sprite 13 to A - X
 SBC T
 STA ySprite13

 LDA #247               ; Set A to 247, which is the tile number that contains a
                        ; full dot in green, for when the planet or station in
                        ; the compass is in front of us

 LDX XX15+2             ; If the z-coordinate of the XX15 vector is positive,
 BPL P%+4               ; skip the following instruction

 LDA #246               ; The z-coordinate of XX15 is negative, so the planet or
                        ; station is behind us and the compass dot should be
                        ; hollow and yellow, so set A to 246, which is the tile
                        ; number for the hollow yellow dot

 STA tileSprite13       ; Set the tile pattern number for sprite 13 to A, so we
                        ; draw the compass dot using the correct pattern

 RTS                    ; Return from the subroutine

; ******************************************************************************
;
;       Name: SPS4
;       Type: Subroutine
;   Category: Maths (Geometry)
;    Summary: Calculate the vector to the space station
;
; ------------------------------------------------------------------------------
;
; Calculate the vector between our ship and the space station and store it in
; XX15.
;
; ******************************************************************************

.SPS4

 LDX #8                 ; First we need to copy the space station's coordinates
                        ; into K3, so set a counter to copy the first 9 bytes
                        ; (the 3-byte x, y and z coordinates) from the station's
                        ; data block at K% + NI% into K3

.SPL1

 LDA K%+NIK%,X          ; Copy the X-th byte from the station's data block at
 STA K3,X               ; K% + NIK% to the X-th byte of K3

 DEX                    ; Decrement the loop counter

 BPL SPL1               ; Loop back to SPL1 until we have copied all 9 bytes

 JMP TAS2               ; Call TAS2 to build XX15 from K3, returning from the
                        ; subroutine using a tail call

; ******************************************************************************
;
;       Name: OOPS
;       Type: Subroutine
;   Category: Flight
;    Summary: Take some damage
;
; ------------------------------------------------------------------------------
;
; We just took some damage, so reduce the shields if we have any, or reduce the
; energy levels and potentially take some damage to the cargo if we don't.
;
; Arguments:
;
;   A                   The amount of damage to take
;
;   INF                 The address of the ship block for the ship that attacked
;                       us, or the ship that we just ran into
;
; ******************************************************************************

.OOPS

 STA T                  ; Store the amount of damage in T

 LDX #0                 ; Fetch byte #8 (z_sign) for the ship attacking us, and
 LDY #8                 ; set X = 0
 LDA (INF),Y

 BMI OO1                ; If A is negative, then we got hit in the rear, so jump
                        ; to OO1 to process damage to the aft shield

 LDA FSH                ; Otherwise the forward shield was damaged, so fetch the
 SBC T                  ; shield strength from FSH and subtract the damage in T

 BCC OO2                ; If the C flag is clear then this amount of damage was
                        ; too much for the shields, so jump to OO2 to set the
                        ; shield level to 0 and start taking damage directly
                        ; from the energy banks

 STA FSH                ; Store the new value of the forward shield in FSH

 RTS                    ; Return from the subroutine

.OO2

 LDX #0                 ; Set the forward shield to 0
 STX FSH

 BCC OO3                ; Jump to OO3 to start taking damage directly from the
                        ; energy banks (this BCC is effectively a JMP as the C
                        ; flag is clear, as we jumped to OO2 with a BCC)

.OO1

 LDA ASH                ; The aft shield was damaged, so fetch the shield
 SBC T                  ; strength from ASH and subtract the damage in T

 BCC OO5                ; If the C flag is clear then this amount of damage was
                        ; too much for the shields, so jump to OO5 to set the
                        ; shield level to 0 and start taking damage directly
                        ; from the energy banks

 STA ASH                ; Store the new value of the aft shield in ASH

 RTS                    ; Return from the subroutine

.OO5

 LDX #0                 ; Set the forward shield to 0
 STX ASH

.OO3

 ADC ENERGY             ; A is negative and contains the amount by which the
 STA ENERGY             ; damage overwhelmed the shields, so this drains the
                        ; energy banks by that amount (and because the energy
                        ; banks are shown over four indicators rather than one,
                        ; but with the same value range of 0-255, energy will
                        ; appear to drain away four times faster than the
                        ; shields did)

 BEQ P%+4               ; If we have just run out of energy, skip the next
                        ; instruction to jump straight to our death

 BCS P%+5               ; If the C flag is set, then subtracting the damage from
                        ; the energy banks didn't underflow, so we had enough
                        ; energy to survive, and we can skip the next
                        ; instruction to make a sound and take some damage

 JMP DEATH              ; Otherwise our energy levels are either 0 or negative,
                        ; and in either case that means we jump to our DEATH,
                        ; returning from the subroutine using a tail call

 JSR EXNO3              ; We didn't die, so call EXNO3 to make the sound of a
                        ; collision

 JMP OUCH               ; And jump to OUCH to take damage and return from the
                        ; subroutine using a tail call

; ******************************************************************************
;
;       Name: NWSPS
;       Type: Subroutine
;   Category: Universe
;    Summary: Add a new space station to our local bubble of universe
;
; ******************************************************************************

.NWSPS

 LDX #%10000001         ; Set the AI flag in byte #32 to %10000001 (hostile,
 STX INWK+32            ; no AI, has an E.C.M.)

 LDX #0                 ; Set pitch counter to 0 (no pitch, roll only)
 STX INWK+30

 STX NEWB               ; Set NEWB to %00000000, though this gets overridden by
                        ; the default flags from E% in NWSHP below

 STX FRIN+1             ; Set the second slot in the FRIN table to 0, so when we
                        ; fall through into NWSHP below, the new station that
                        ; gets created will go into slot FRIN+1, as this will be
                        ; the first empty slot that the routine finds

 DEX                    ; Set roll counter to 255 (maximum roll with no
 STX INWK+29            ; damping)

 LDX #10                ; Call NwS1 to flip the sign of nosev_x_hi (byte #10)
 JSR NwS1

 JSR NwS1               ; And again to flip the sign of nosev_y_hi (byte #12)

 JSR NwS1               ; And again to flip the sign of nosev_z_hi (byte #14)

 LDA #SST               ; Set A to the space station type, and fall through
                        ; into NWSHP to finish adding the space station to the
                        ; universe

 JSR NWSHP              ; Call NWSHP to add the space station to the universe

 LDX XX21+2*SST-2       ; Set (Y X) to the address of the Coriolis station's
 LDY XX21+2*SST-1       ; ship blueprint

 LDA tek                ; If the system's tech level in tek is less than 10,
 CMP #10                ; jump to notadodo, so tech levels 0 to 9 have Coriolis
 BCC notadodo           ; stations, while 10 and above will have Dodo stations

 LDX XX21+2*DOD-2       ; Set (Y X) to the address of the Dodo station's ship
 LDY XX21+2*DOD-1       ; blueprint

.notadodo

 STX spasto             ; Store the address of the space station in spasto(1 0)
 STY spasto+1           ; so we spawn the correct type of station in part 4 of
                        ; the main flight loop

 JMP UpdateIconBar_b3   ; Update the icon bar so the docking computer icon gets
                        ; displayed to reflect that we are in the station's safe
                        ; zone, returning from the subroutine using a tail call

; ******************************************************************************
;
;       Name: NWSHP
;       Type: Subroutine
;   Category: Universe
;    Summary: Add a new ship to our local bubble of universe
;
; ------------------------------------------------------------------------------
;
; This creates a new block of ship data in the K% workspace, allocates a new
; block in the ship line heap at WP, adds the new ship's type into the first
; empty slot in FRIN, and adds a pointer to the ship data into UNIV. If there
; isn't enough free memory for the new ship, it isn't added.
;
; Arguments:
;
;   A                   The type of the ship to add (see variable XX21 for a
;                       list of ship types)
;
; Returns:
;
;   C flag              Set if the ship was successfully added, clear if it
;                       wasn't (as there wasn't enough free memory)
;
;   INF                 Points to the new ship's data block in K%
;
; ******************************************************************************

.NW2

 STA FRIN,X             ; Store the ship type in the X-th byte of FRIN, so the
                        ; this slot is now shown as occupied in the index table

 TAX                    ; Copy the ship type into X

 LDA #0                 ; Zero the ship's number on the scanner so that it
 STA INWK+33            ; doesn't appear on the scanner

 JMP NW8                ; Jump down to NW8 to continue setting up the new ship

.NWSHP

 STA T                  ; Store the ship type in location T

 SETUP_PPU_FOR_ICON_BAR ; If the PPU has started drawing the icon bar, configure
                        ; the PPU to use nametable 0 and pattern table 0

 LDX #0                 ; Before we can add a new ship, we need to check
                        ; whether we have an empty slot we can put it in. To do
                        ; this, we need to loop through all the slots to look
                        ; for an empty one, so set a counter in X that starts
                        ; from the first slot at 0. When ships are killed, then
                        ; the slots are shuffled down by the KILLSHP routine, so
                        ; the first empty slot will always come after the last
                        ; filled slot. This allows us to tack the new ship's
                        ; data block and ship line heap onto the end of the
                        ; existing ship data and heap, as shown in the memory
                        ; map below

.NWL1

 LDA FRIN,X             ; Load the ship type for the X-th slot

 BEQ NW1                ; If it is zero, then this slot is empty and we can use
                        ; it for our new ship, so jump down to NW1

 INX                    ; Otherwise increment X to point to the next slot

 CPX #NOSH              ; If we haven't reached the last slot yet, loop back up
 BCC NWL1               ; to NWL1 to check the next slot (note that this means
                        ; only slots from 0 to #NOSH - 1 are populated by this
                        ; routine, but there is one more slot reserved in FRIN,
                        ; which is used to identify the end of the slot list
                        ; when shuffling the slots down in the KILLSHP routine)

.NW3

 CLC                    ; Otherwise we don't have an empty slot, so we can't
 RTS                    ; add a new ship, so clear the C flag to indicate that
                        ; we have not managed to create the new ship, and return
                        ; from the subroutine

.NW1

                        ; If we get here, then we have found an empty slot at
                        ; index X, so we can go ahead and create our new ship.
                        ; We do that by creating a ship data block at INWK and,
                        ; when we are done, copying the block from INWK into
                        ; the K% workspace (specifically, to INF)

 JSR GINF               ; Get the address of the data block for ship slot X
                        ; (which is in workspace K%) and store it in INF

 LDA T                  ; If the type of ship that we want to create is
 BMI NW2                ; negative, then this indicates a planet or sun, so
                        ; jump down to NW2, as the next section sets up a ship
                        ; data block, which doesn't apply to planets and suns,
                        ; as they don't have things like shields, missiles,
                        ; vertices and edges

                        ; This is a ship, so first we need to set up various
                        ; pointers to the ship blueprint we will need. The
                        ; blueprints for each ship type in Elite are stored
                        ; in a table at location XX21, so refer to the comments
                        ; on that variable for more details on the data we're
                        ; about to access

 ASL A                  ; Set Y = ship type * 2
 TAY

 LDA XX21-1,Y           ; The ship blueprints at XX21 start with a lookup
                        ; table that points to the individual ship blueprints,
                        ; so this fetches the high byte of this particular ship
                        ; type's blueprint

 BEQ NW3                ; If the high byte is 0 then this is not a valid ship
                        ; type, so jump to NW3 to clear the C flag and return
                        ; from the subroutine

 STA XX0+1              ; This is a valid ship type, so store the high byte in
                        ; XX0+1

 LDA XX21-2,Y           ; Fetch the low byte of this particular ship type's
 STA XX0                ; blueprint and store it in XX0, so XX0(1 0) now
                        ; contains the address of this ship's blueprint

 STX SC2                ; Store the new ship's slot number in SC2 to we can
                        ; retrieve it below

 LDX T                  ; Set X to the ship type that we stored in T above

 LDA #0                 ; Zero the ship's number on the scanner so that it
 STA INWK+33            ; doesn't appear on the scanner for now

 LDA scacol,X           ; Set A to the scanner colour for this ship type from
                        ; the X-th entry in the scacol table (the colour is
                        ; actually a sprite palette number)

 BMI nwsh3              ; If bit 7 is set of the scanner colour then this ship
                        ; has a cloaking device and is not visible on the
                        ; scanner, so jump to nwsh3 to skip the following so
                        ; the ship is not configured to appear on the scanner

 TAX                    ; Set X to the scanner colour for this ship

 LDY #8                 ; We now work our way through the list of scanner
                        ; numbers to try to find a number to allocate to the
                        ; new ship, starting from 8 and working down towards
                        ; 1, so set a number counter in Y

.nwsh1

 LDA scannerNumber,Y    ; If the Y-th entry in scannerNumber is zero then this
 BEQ nwsh2              ; number is available, so jump to nwsh2 to allocate it
                        ; to our new ship

 DEY                    ; Otherwise decrement the index in Y to point to the
                        ; next number down

 BNE nwsh1              ; Loop back to check the next entry in the table until
                        ; we have found a free number, or we have checked all
                        ; numbers from 8 to 1

 BEQ nwsh3              ; We didn't find an available number for the new ship,
                        ; so jump to nwsh3 to skip the following as there isn't
                        ; room for another ship on the scanner

.nwsh2

 LDA #$FF               ; Set the scannerNumber entry for this ship to $FF to
 STA scannerNumber,Y    ; indicate that this scanner number is now being used
                        ; for our new ship

 STY INWK+33            ; Set the ship's byte #33 to the scanner number for the
                        ; new ship

 TYA                    ; Set Y = (A * 2 + A) * 4
 ASL A                  ;       = A * 3 * 4
 ADC INWK+33            ;
 ASL A                  ; This gives us the offset of the first scanner sprite
 ASL A                  ; for this ship within the sprite buffer, as each
 TAY                    ; ship has three sprites allocated to it, and there are
                        ; four bytes per sprite in the buffer
                        ;
                        ; The offset is from the first scanner sprite in the
                        ; sprite buffer, so this is the offset within the block
                        ; of scanner sprites in the buffer
                        ;
                        ; That said, this value is not used here, as Y gets
                        ; overwritten below before this value is used

 TXA                    ; Set A to the scanner colour for this ship, which we
                        ; put in X above

 LDX INWK+33            ; Set X to the scanner number for the new ship

 STA scannerColour,X    ; Set the X-th entry in the scannerColour table to the
                        ; colour of this ship on the scanner

.nwsh3

 LDX SC2                ; Set X to the new ship's slot number that we stored in
                        ; SC2 above

.NW6

 LDY #14                ; Fetch ship blueprint byte #14, which contains the
 JSR GetShipBlueprint   ; ship's energy, and store it in byte #35
 STA INWK+35

 LDY #19                ; Fetch ship blueprint byte #19, which contains the
 JSR GetShipBlueprint   ; number of missiles and laser power, and AND with %111
 AND #%00000111         ; to extract the number of missiles before storing in
 STA INWK+31            ; byte #31

 LDA T                  ; Restore the ship type we stored above

 STA FRIN,X             ; Store the ship type in the X-th byte of FRIN, so the
                        ; this slot is now shown as occupied in the index table

 TAX                    ; Copy the ship type into X

 BMI NW8                ; If the ship type is negative (planet or sun), then
                        ; jump to NW8 to skip the following instructions

 CPX #HER               ; If the ship type is a rock hermit, jump to gangbang
 BEQ gangbang           ; to increase the junk count

 CPX #JL                ; If JL <= X < JH, i.e. the type of ship we killed in X
 BCC NW7                ; is junk (escape pod, alloy plate, cargo canister,
 CPX #JH                ; asteroid, splinter, Shuttle or Transporter), then keep
 BCS NW7                ; going, otherwise jump to NW7

.gangbang

 INC JUNK               ; We're adding junk, so increase the junk counter

.NW7

 INC MANY,X             ; Increment the total number of ships of type X

 LDY T                  ; Restore the ship type we stored above

 JSR GetDefaultNEWB     ; Fetch the E% byte for this ship to get the default
                        ; settings for the ship's NEWB flags

 AND #%01101111         ; Zero bits 4 and 7 (so the new ship is not docking, has
                        ; not been scooped, and has not just docked)

 ORA NEWB               ; Apply the result to the ship's NEWB flags, which sets
 STA NEWB               ; bits 0-3 and 5-6 in NEWB if they are set in the E%
                        ; byte

 AND #%00000100         ; If bit 2 of the ship's NEWB flags is clear then the
 BEQ NW8                ; ship is not hostile, so jump to NW8 to skip the
                        ; following

 LDA allowInSystemJump  ; We are spawning a hostile ship, so set bit 7 of
 ORA #%10000000         ; allowInSystemJump to prevent us from being able to
 STA allowInSystemJump  ; perform an in-system jump

.NW8

 SETUP_PPU_FOR_ICON_BAR ; If the PPU has started drawing the icon bar, configure
                        ; the PPU to use nametable 0 and pattern table 0

 LDY #NI%-1             ; The final step is to copy the new ship's data block
                        ; from INWK to INF, so set up a counter for NI% bytes
                        ; in Y

.NWL3

 LDA INWK,Y             ; Load the Y-th byte of INWK and store in the Y-th byte
 STA (INF),Y            ; of the workspace pointed to by INF

 DEY                    ; Decrement the loop counter

 BPL NWL3               ; Loop back for the next byte until we have copied them
                        ; all over

 SETUP_PPU_FOR_ICON_BAR ; If the PPU has started drawing the icon bar, configure
                        ; the PPU to use nametable 0 and pattern table 0

 SEC                    ; We have successfully created our new ship, so set the
                        ; C flag to indicate success

 RTS                    ; Return from the subroutine

; ******************************************************************************
;
;       Name: NwS1
;       Type: Subroutine
;   Category: Universe
;    Summary: Flip the sign and double an INWK byte
;
; ------------------------------------------------------------------------------
;
; Flip the sign of the INWK byte at offset X, and increment X by 2. This is
; used by the space station creation routine at NWSPS.
;
; Arguments:
;
;   X                   The offset of the INWK byte to be flipped
;
; Returns:
;
;   X                   X is incremented by 2
;
; ******************************************************************************

.NwS1

 LDA INWK,X             ; Load the X-th byte of INWK into A and flip bit 7,
 EOR #%10000000         ; storing the result back in the X-th byte of INWK
 STA INWK,X

 INX                    ; Add 2 to X
 INX

 RTS                    ; Return from the subroutine

; ******************************************************************************
;
;       Name: KS1
;       Type: Subroutine
;   Category: Universe
;    Summary: Remove the current ship from our local bubble of universe
;
; ------------------------------------------------------------------------------
;
; Part 12 of the main flight loop calls this routine to remove the ship that is
; currently being analysed by the flight loop. Once the ship is removed, it
; jumps back to MAL1 to rejoin the main flight loop, with X pointing to the
; same slot that we just cleared (and which now contains the next ship in the
; local bubble of universe).
;
; Arguments:
;
;   XX0                 The address of the blueprint for this ship
;
;   INF                 The address of the data block for this ship
;
; Other entry points:
;
;   KS3                 Contains an RTS
;
; ******************************************************************************

.KS3

 RTS                    ; Return from the subroutine

.KS1

 LDX XSAV               ; Store the current ship's slot number in XSAV

 JSR KILLSHP            ; Call KILLSHP to remove the ship in slot X from our
                        ; local bubble of universe

 LDX XSAV               ; Restore the current ship's slot number from XSAV,
                        ; which now points to the next ship in the bubble

 RTS                    ; Return from the subroutine

; ******************************************************************************
;
;       Name: KS4
;       Type: Subroutine
;   Category: Universe
;    Summary: Remove the space station and replace it with the sun
;
; ******************************************************************************

.KS4

 JSR ZINF               ; Call ZINF to reset the INWK ship workspace

 LDA #0                 ; Set A = 0 so we can zero the following flags

 STA FRIN+1             ; Set the second slot in the FRIN table to 0, which
                        ; sets this slot to empty, so when we call NWSHP below
                        ; the new sun that gets created will go into FRIN+1

 STA SSPR               ; Set the "space station present" flag to 0, as we are
                        ; no longer in the space station's safe zone

 LDA #6                 ; Set the sun's y_sign to 6
 STA INWK+5

 LDA #129               ; Set A = 129, the ship type for the sun

 JSR NWSHP              ; Call NWSHP to set up the sun's data block and add it
                        ; to FRIN, where it will get put in the second slot as
                        ; we just cleared out the second slot, and the first
                        ; slot is already taken by the planet

 JMP UpdateIconBar_b3   ; Update the icon bar so the docking computer icon gets
                        ; removed to reflect that we are no longer in the safe
                        ; zone, returning from the subroutine using a tail call

; ******************************************************************************
;
;       Name: KS2
;       Type: Subroutine
;   Category: Universe
;    Summary: Check the local bubble for missiles with target lock
;
; ------------------------------------------------------------------------------
;
; Check the local bubble of universe to see if there are any missiles with
; target lock in the vicinity. If there are, then check their targets; if we
; just removed their target in the KILLSHP routine, then switch off their AI so
; they just drift in space, otherwise update their targets to reflect the newly
; shuffled slot numbers.
;
; This is called from KILLSHP once the slots have been shuffled down, following
; the removal of a ship.
;
; Arguments:
;
;   XX4                 The slot number of the ship we removed just before
;                       calling this routine
;
; ******************************************************************************

.KS2

 LDX #$FF               ; We want to go through the ships in our local bubble
                        ; and pick out all the missiles, so set X to $FF to
                        ; use as a counter

.KSL4

 SETUP_PPU_FOR_ICON_BAR ; If the PPU has started drawing the icon bar, configure
                        ; the PPU to use nametable 0 and pattern table 0

 INX                    ; Increment the counter (so it starts at 0 on the first
                        ; iteration)

 LDA FRIN,X             ; If slot X is empty then we have worked our way through
 BEQ KS3                ; all the slots, so jump to KS3 to stop looking

 CMP #MSL               ; If the slot does not contain a missile, loop back to
 BNE KSL4               ; KSL4 to check the next slot

                        ; We have found a slot containing a missile, so now we
                        ; want to check whether it has target lock

 TXA                    ; Set Y = X * 2 and fetch the Y-th address from UNIV
 ASL A                  ; and store it in SC and SC+1 - in other words, set
 TAY                    ; SC(1 0) to point to the missile's ship data block
 LDA UNIV,Y
 STA SC
 LDA UNIV+1,Y
 STA SC+1

 LDY #32                ; Fetch byte #32 from the missile's ship data (AI)
 LDA (SC),Y

 BPL KSL4               ; If bit 7 of byte #32 is clear, then the missile is
                        ; dumb and has no AI, so loop back to KSL4 to move on
                        ; to the next slot

 AND #%01111111         ; Otherwise this missile has AI, so clear bit 7 and
 LSR A                  ; shift right to set the C flag to the missile's "is
                        ; locked" flag, and A to the target's slot number

 CMP XX4                ; If this missile's target is less than XX4, then the
 BCC KSL4               ; target's slot isn't being shuffled down, so jump to
                        ; KSL4 to move on to the next slot

 BEQ KS6                ; If this missile was locked onto the ship that we just
                        ; removed in KILLSHP, jump to KS6 to stop the missile
                        ; from continuing to hunt it down

 SBC #1                 ; Otherwise this missile is locked and has AI enabled,
                        ; and its target will have moved down a slot, so
                        ; subtract 1 from the target number (we know C is set
                        ; from the BCC above)

 ASL A                  ; Shift the target number left by 1, so it's in bits
                        ; 1-6 once again, and also set bit 0 to 1, as the C
                        ; flag is still set, so this makes sure the missile is
                        ; still set to being locked

 ORA #%10000000         ; Set bit 7, so the missile's AI is enabled

 STA (SC),Y             ; Update the missile's AI flag to the value in A

 BNE KSL4               ; Loop back to KSL4 to move on to the next slot (this
                        ; BNE is effectively a JMP as A will never be zero)

.KS6

 LDA #0                 ; The missile's target lock just got removed, so set the
 STA (SC),Y             ; AI flag to 0 to make it dumb and not locked

 BEQ KSL4               ; Loop back to KSL4 to move on to the next slot (this
                        ; BEQ is effectively a JMP as A is always zero)

; ******************************************************************************
;
;       Name: RemoveShip
;       Type: Subroutine
;   Category: Universe
;    Summary: Fetch a ship data block and remove that ship from our local bubble
;             of universe
;
; ------------------------------------------------------------------------------
;
; Arguments:
;
;   X                   The slot number of the ship to remove
;
;   INF                 The address of the data block for the ship to remove
;
; ******************************************************************************

.RemoveShip

 JSR SetupPPUForIconBar ; If the PPU has started drawing the icon bar, configure
                        ; the PPU to use nametable 0 and pattern table 0

 LDY #NI%-1             ; There are NI% bytes in each ship data block (and in
                        ; the INWK workspace, so we set a counter in Y so we can
                        ; loop through them

.cink1

 LDA (INF),Y            ; Load the Y-th byte of INF and store it in the Y-th
 STA INWK,Y             ; byte of INWK

 DEY                    ; Decrement the loop counter

 BPL cink1              ; Loop back for the next byte until we have copied the
                        ; last byte from INF to INWK

                        ; Fall through into KILLSHP to remove the ship from our
                        ; local bubble of universe

; ******************************************************************************
;
;       Name: KILLSHP
;       Type: Subroutine
;   Category: Universe
;    Summary: Remove a ship from our local bubble of universe
;
; ------------------------------------------------------------------------------
;
; Remove the ship in slot X from our local bubble of universe. This happens
; when we kill a ship, collide with a ship and destroy it, or when a ship moves
; outside our local bubble.
;
; We also use this routine when we move out of range of the space station, in
; which case we replace it with the sun.
;
; When removing a ship, this creates a gap in the ship slots at FRIN, so we
; shuffle all the later slots down to close the gap. We also shuffle the ship
; data blocks at K% to reclaim all the memory that the removed ship used to
; occupy.
;
; Arguments:
;
;   X                   The slot number of the ship to remove
;
;   XX0                 The address of the blueprint for the ship to remove
;
;   INF                 The address of the data block for the ship to remove
;
; ******************************************************************************

.KILLSHP

 STX XX4                ; Store the slot number of the ship to remove in XX4

 JSR HideFromScanner_b1 ; Hide the ship from the scanner

 LDX XX4                ; Set X to the slot number of the ship to remove

 LDA MSTG               ; Check whether this slot matches the slot number in
 CMP XX4                ; MSTG, which is the target of our missile lock

 BNE KS5                ; If our missile is not locked on this ship, jump to KS5

 LDY #108               ; Otherwise we need to remove our missile lock, so call
 JSR ABORT              ; ABORT to disarm the missile and update the missile
                        ; indicators on the dashboard to the tile pattern number
                        ; in Y (black indicator = pattern 108)

 LDA #200               ; Print recursive token 40 ("TARGET LOST") as an
 JSR MESS               ; in-flight message

.KS5

 LDY XX4                ; Restore the slot number of the ship to remove into Y

 LDX FRIN,Y             ; Fetch the contents of the slot, which contains the
                        ; ship type

 CPX #SST               ; If this is the space station, then jump to KS4 to
 BNE kill1              ; replace the space station with the sun
 JMP KS4

.kill1

 CPX #CON               ; Did we just kill the Constrictor from mission 1? If
 BNE lll                ; not, jump to lll

 LDA TP                 ; We just killed the Constrictor from mission 1, so set
 ORA #%00000010         ; bit 1 of TP to indicate that we have successfully
 STA TP                 ; completed mission 1

 INC TALLY+1            ; Award 256 kill points for killing the Constrictor

.lll

 CPX #HER               ; Did we just kill a rock hermit? If we did, jump to
 BEQ blacksuspenders    ; blacksuspenders to decrease the junk count

 CPX #JL                ; If JL <= X < JH, i.e. the type of ship we killed in X
 BCC KS7                ; is junk (escape pod, alloy plate, cargo canister,
 CPX #JH                ; asteroid, splinter, Shuttle or Transporter), then keep
 BCS KS7                ; going, otherwise jump to KS7

.blacksuspenders

 DEC JUNK               ; We just killed junk, so decrease the junk counter

.KS7

 DEC MANY,X             ; Decrease the number of this type of ship in our little
                        ; bubble, which is stored in MANY+X (where X is the ship
                        ; type)

 LDX XX4                ; Restore the slot number of the ship to remove into X

.KSL1

 SETUP_PPU_FOR_ICON_BAR ; If the PPU has started drawing the icon bar, configure
                        ; the PPU to use nametable 0 and pattern table 0

 INX                    ; On entry, X points to the empty slot we want to
                        ; shuffle the next ship into (the destination), so
                        ; this increment points X to the next slot - i.e. the
                        ; source slot we want to shuffle down

 LDA FRIN,X             ; Copy the contents of the source slot into the
 STA FRIN-1,X           ; destination slot

 BNE P%+5               ; If the slot we just shuffled down is not empty, then
                        ; skip the following instruction

 JMP KS2                ; The source slot is empty and we are done shuffling,
                        ; so jump to KS2 to move on to processing missiles

 TXA                    ; Set Y = X * 2 so it can act as an index into the
 ASL A                  ; two-byte lookup table at UNIV, which contains the
 TAY                    ; addresses of the ship data blocks. In this case we are
                        ; multiplying X by 2, and X contains the source ship's
                        ; slot number so Y is now an index for the source ship's
                        ; entry in UNIV

 LDA UNIV,Y             ; Set SC(1 0) to the address of the data block for the
 STA SC                 ; source ship
 LDA UNIV+1,Y
 STA SC+1

 SETUP_PPU_FOR_ICON_BAR ; If the PPU has started drawing the icon bar, configure
                        ; the PPU to use nametable 0 and pattern table 0

                        ; We have now set up our variables as follows:
                        ;
                        ;   SC(1 0) points to the source's ship data block
                        ;
                        ;   INF(1 0) points to the destination's ship data block
                        ;
                        ;   P(1 0) points to the destination's line heap
                        ;
                        ; so let's start copying data from the source to the
                        ; destination

 LDY #41                ; We are going to be using Y as a counter for the 42
                        ; bytes of ship data we want to copy from the source
                        ; to the destination, so we set it to 41 to start things
                        ; off, and will decrement Y for each byte we copy

.KSL2

 LDA (SC),Y             ; Copy the Y-th byte of the source to the Y-th byte of
 STA (INF),Y            ; the destination

 DEY                    ; Decrement the counter

 BPL KSL2               ; Loop back to KSL2 to copy the next byte until we have
                        ; copied the whole block

                        ; We have now shuffled the ship's slot and the ship's
                        ; data block, so we only have the heap data itself to do

 LDA SC                 ; First, we copy SC into INF, so when we loop round
 STA INF                ; again, INF will correctly point to the destination for
 LDA SC+1               ; the next iteration
 STA INF+1

 SETUP_PPU_FOR_ICON_BAR ; If the PPU has started drawing the icon bar, configure
                        ; the PPU to use nametable 0 and pattern table 0

 JMP KSL1               ; We have now shuffled everything down one slot, so
                        ; jump back up to KSL1 to see if there is another slot
                        ; that needs shuffling down

; ******************************************************************************
;
;       Name: ABORT
;       Type: Subroutine
;   Category: Dashboard
;    Summary: Disarm missiles and update the dashboard indicators
;
; ------------------------------------------------------------------------------
;
; Arguments:
;
;   Y                   The new status of the leftmost missile indicator
;
; ******************************************************************************

.ABORT

 LDX #0                 ; Set MSAR = 0 to indicate that the leftmost missile
 STX MSAR               ; is no longer seeking a target lock

 DEX                    ; Set X to $FF, which is the value of MSTG when we have
                        ; no target lock for our missile

                        ; Fall through into ABORT2 to set the missile lock to
                        ; the value in X, which effectively disarms the missile

; ******************************************************************************
;
;       Name: ABORT2
;       Type: Subroutine
;   Category: Dashboard
;    Summary: Set/unset the lock target for a missile and update the dashboard
;
; ------------------------------------------------------------------------------
;
; Set the lock target for the active missile and update the dashboard.
;
; Arguments:
;
;   X                   The slot number of the ship to lock our missile onto, or
;                       $FF to remove missile lock
;
;   Y                   The tile pattern number for the new missile indicator:
;
;                         * 133 = no missile indicator
;
;                         * 109 = red (armed and locked)
;
;                         * 108 = black (disarmed)
;
;                       The armed missile flashes black and red, so the tile is
;                       swapped between 108 and 109 in the main loop
;
; ******************************************************************************

.ABORT2

 STX MSTG               ; Store the target of our missile lock in MSTG

 SETUP_PPU_FOR_ICON_BAR ; If the PPU has started drawing the icon bar, configure
                        ; the PPU to use nametable 0 and pattern table 0

 LDX NOMSL              ; Call MSBAR to update the active indicator in the
 JSR MSBAR              ; dashboard's missile bar, which returns with Y = 0

 JMP UpdateIconBar_b3   ; Update the icon bar so the missile button shows the
                        ; correct available option for the active missile,
                        ; returning from the subroutine using a tail call

.msbpars

 EQUB 4, 0, 0, 0, 0     ; These bytes appear to be unused (they are left over
                        ; from the 6502 Second Processor version of Elite)

; ******************************************************************************
;
;       Name: YESNO
;       Type: Subroutine
;   Category: Controllers
;    Summary: Display "YES" or "NO" and wait until one is chosen
;
; ------------------------------------------------------------------------------
;
; This routine does a similar job to the routine of the same name in the BBC
; Master version of Elite, but the code is significantly different.
;
; Returns:
;
;   A                   The result:
;
;                         * 1 if "YES" was chosen
;
;                         * 2 if "NO" was chosen
;
; ******************************************************************************

.YESNO

 LDA fontStyle          ; Store the current font style on the stack, so we can
 PHA                    ; restore it when we return from the subroutine

 LDA #2                 ; Set the font style to print in the highlight font
 STA fontStyle

 LDA #1                 ; Push a value of 1 onto the stack, so the following
 PHA                    ; prints extended token 1 ("YES")

.yeno1

 JSR CLYNS              ; Clear the bottom two text rows of the upper screen,
                        ; and move the text cursor to column 1 on row 21, i.e.
                        ; the start of the top row of the two bottom rows

 LDA #15                ; Move the text cursor to column 15
 STA XC

 PLA                    ; Print the extended token whose number is on the stack,
 PHA                    ; so this will be "YES" (token 1) or "NO" (token 2)
 JSR DETOK_b2

 JSR DrawMessageInNMI   ; Configure the NMI to display the YES/NO message that
                        ; we just printed

 LDA controller1A       ; If "A" is being pressed on the controller, jump to
 BMI yeno3              ; to record the choice

 LDA controller1Up      ; If neither the up nor down arrow is being pressed on
 ORA controller1Down    ; the controller, jump to yeno2 to pause and loop back
 BPL yeno2              ; to keep waiting for a choice to be made

                        ; If we get here then either the up or down arrow is
                        ; being pressed, so we toggle the on-screen choice
                        ; between "YES" and "NO"

 PLA                    ; Flip the value on the top of the stack between 1 and 2
 EOR #3                 ; by EOR'ing with 3, which toggles the token between
 PHA                    ; "YES" and "NO"

.yeno2

 LDY #8                 ; Wait until eight NMI interrupts have passed (i.e. the
 JSR DELAY              ; next eight VBlanks)

 JMP yeno1              ; Loop back to print "YES" or NO" and wait for a choice

.yeno3

 LDA #0                 ; Reset the key logger entry for the icon bar button
 STA iconBarKeyPress    ; choice to clear any icon bar choices that might have
                        ; been processed in the background (via the pause menu,
                        ; for example)

 STA controller1A       ; Reset the key logger for the controller "A" button as
                        ; we have consumed the key press

 PLA                    ; Set X to the value from the top of the stack, which
 TAX                    ; will be 1 for "YES" or 2 for "NO", giving us our
                        ; result to return

 PLA                    ; Restore the font style that we stored on the stack
 STA fontStyle          ; so it's unchanged by the routine

 TXA                    ; Copy X to A, so we return the result in both A and X

 RTS                    ; Return from the subroutine

; ******************************************************************************
;
;       Name: TT17
;       Type: Subroutine
;   Category: Controllers
;    Summary: Scan the key logger for the directional pad buttons
;
; ------------------------------------------------------------------------------
;
; X and Y are integers between -1 and +1 depending on which buttons are pressed.
;
; This routine does a similar job to the routine of the same name in the BBC
; Master version of Elite, but the code is significantly different.
;
; Returns:
;
;   A                   The button number, icon bar button was chosen
;
;   X                   Change in the x-coordinate according to the directional
;                       keys being pressed on controller 1
;
;   Y                   Change in the y-coordinate according to the directional
;                       keys being pressed on controller 1
;
; ******************************************************************************

.TT17

 LDA QQ11               ; If this is not the space view, jump to dpad1 to read
 BNE dpad1              ; the directional pad on controller 1

 JSR DOKEY              ; This is the space view, so populate the key logger
                        ; and apply the docking computer manoeuvring code

 TXA                    ; Transfer the value of the key pressed from X to A

 RTS                    ; Return from the subroutine

.dpad1

 JSR DOKEY              ; Populate the key logger and apply the docking computer
                        ; manoeuvring code

 LDX #0                 ; Set the initial values for the results, X = Y = 0,
 LDY #0                 ; which we now increase or decrease appropriately

 LDA controller1B       ; If the B button is being pressed on controller 1,
 BMI dpad5              ; jump to dpad5 to return from the subroutine, as the
                        ; arrow buttons act differently when B is also pressed

 LDA controller1Left03  ; If the left button on controller 1 was not being held
 BPL dpad2              ; down four VBlanks ago or for the three VBlanks before
                        ; that, jump to dpad2 to skip the following instruction

 DEX                    ; The left button has been held down for some time, so
                        ; decrement the x-delta in X

.dpad2

 LDA controller1Right03 ; If the right button on controller 1 was not being held
 BPL dpad3              ; down four VBlanks ago or for the three VBlanks before
                        ; that, jump to dpad3 to skip the following instruction

 INX                    ; The right button has been held down for some time, so
                        ; increment the x-delta in X

.dpad3

 LDA controller1Up      ; If the up button on controller 1 is not being pressed,
 BPL dpad4              ; jump to dpad4 to skip the following instruction

 INY                    ; The up button is being pressed, so increment the
                        ; y-delta in Y

.dpad4

 LDA controller1Down    ; If the down button on controller 1 is not being
 BPL dpad5              ; pressed, jump to dpad5 to skip the following
                        ; instruction

 DEY                    ; The down button is being pressed, so decrement the
                        ; y-delta in Y

.dpad5

 LDA iconBarKeyPress    ; Set A to the key logger entry for the icon bar button
                        ; press, to return from the subroutine

 RTS                    ; Return from the subroutine

; ******************************************************************************
;
;       Name: THERE
;       Type: Subroutine
;   Category: Missions
;    Summary: Check whether we are in the Constrictor's system in mission 1
;
; ------------------------------------------------------------------------------
;
; The stolen Constrictor is the target of mission 1. We finally track it down to
; the Orarra system in the second galaxy, which is at galactic coordinates
; (144, 33). This routine checks whether we are in this system and sets the C
; flag accordingly.
;
; Returns:
;
;   C flag              Set if we are in the Constrictor system, otherwise clear
;
; ******************************************************************************

.THERE

 LDX GCNT               ; Set X = GCNT - 1
 DEX

 BNE THEX               ; If X is non-zero (i.e. GCNT is not 1, so we are not in
                        ; the second galaxy), then jump to THEX

 LDA QQ0                ; Set A = the current system's galactic x-coordinate

 CMP #144               ; If A <> 144 then jump to THEX
 BNE THEX

 LDA QQ1                ; Set A = the current system's galactic y-coordinate

 CMP #33                ; If A = 33 then set the C flag

 BEQ THEX+1             ; If A = 33 then jump to THEX+1, so we return from the
                        ; subroutine with the C flag set (otherwise we clear the
                        ; C flag with the next instruction)

.THEX

 CLC                    ; Clear the C flag

 RTS                    ; Return from the subroutine

; ******************************************************************************
;
;       Name: RESET
;       Type: Subroutine
;   Category: Start and end
;    Summary: Reset most variables
;
; ------------------------------------------------------------------------------
;
; Reset our ship and various controls, recharge shields and energy, and then
; fall through into RES2 to reset the stardust and the ship workspace at INWK.
;
; In this subroutine, this means zero-filling the following locations:
;
;   * BETA to BETA+6, which covers the following:
;
;     * BETA, BET1 - Set pitch to 0
;
;     * XC, YC - Set text cursor to (0, 0)
;
;     * QQ22 - Set hyperspace counters to 0
;
;     * ECMA - Turn E.C.M. off
;
; It also sets QQ12 to $FF, to indicate we are docked, recharges the shields and
; energy banks, and then falls through into RES2.
;
; ******************************************************************************

.RESET

 JSR ZERO               ; Reset the ship slots for the local bubble of universe,
                        ; and various flight and ship status variables

 LDA #%00000000         ; Clear bits 6 and 7 of selectedSystemFlag to indicate
 STA selectedSystemFlag ; that there is no currently selected system

 LDX #6                 ; Set up a counter for zeroing BETA through BETA+6

.SAL3

 STA BETA,X             ; Zero the X-th byte after BETA

 DEX                    ; Decrement the loop counter

 BPL SAL3               ; Loop back for the next byte to zero

 TXA                    ; X is now negative - i.e. $FF - so this sets A and QQ12
 STA QQ12               ; to $FF to indicate we are docked

 LDX #2                 ; We're now going to recharge both shields and the
                        ; energy bank, which live in the three bytes at FSH,
                        ; ASH (FSH+1) and ENERGY (FSH+2), so set a loop counter
                        ; in X for 3 bytes

.REL5

 STA FSH,X              ; Set the X-th byte of FSH to $FF to charge up that
                        ; shield/bank

 DEX                    ; Decrement the loop counter

 BPL REL5               ; Loop back to REL5 until we have recharged both shields
                        ; and the energy bank

 LDA #$FF               ; Set iconBarType to $FF so no icon bar is shown
 STA iconBarType

                        ; Fall through into RES2 to reset the stardust and ship
                        ; workspace at INWK

; ******************************************************************************
;
;       Name: RES2
;       Type: Subroutine
;   Category: Start and end
;    Summary: Reset a number of flight variables and workspaces
;
; ------------------------------------------------------------------------------
;
; This is called after we launch from a space station, arrive in a new system
; after hyperspace, launch an escape pod, or die a cold, lonely death in the
; depths of space.
;
; Returns:
;
;   Y                   Y is set to $FF
;
; ******************************************************************************

.RES2

 SEI                    ; Disable interrupts from any source except NMI, as we
                        ; don't want any other interrupts to occur

 LDA #1                 ; Set enableBitplanes to 1 so the game starts to use
 STA enableBitplanes    ; two different bitplanes when displaying the screen

 LDA #1                 ; Set the tile number for the left edge of the box to
 STA boxEdge1           ; tile 1, which is the standard edge for the box

 LDA #2                 ; Set the tile number for the right edge of the box to
 STA boxEdge2           ; tile 2, which is the standard edge for the box

 LDA #80                ; Tell the PPU to send nametable entries up to tile
 STA lastNameTile       ; 80 * 8 = 640 (i.e. to the end of tile row 19) in both
 STA lastNameTile+1     ; bitplanes

 LDA BOMB               ; If the energy bomb has not been set off, jump to rese1
 BPL rese1              ; to skip the following

 JSR HideHiddenColour   ; Set the hidden colour to black, to switch off the
                        ; energy bomb effect (as the effect works by showing
                        ; hidden content instead of the visible content)

 STA BOMB               ; The call to HideHiddenColour sets A = 15, which has
                        ; bit 7 clear, so this clears bit 7 of BOMB to disable
                        ; the energy bomb explosion

.rese1

 LDA #NOST              ; Reset NOSTM, the number of stardust particles, to the
 STA NOSTM              ; maximum allowed (20)

 LDX #$FF               ; Reset MSTG, the missile target, to $FF (no target)
 STX MSTG

 LDA allowInSystemJump  ; Set bit 7 of allowInSystemJump to prevent us from
 ORA #%10000000         ; being able to perform an in-system jump, as this is
 STA allowInSystemJump  ; the default setting after launching

 LDA #128               ; Set the current pitch and roll rates to the mid-point,
 STA JSTX               ; 128
 STA JSTY

 STA ALP2               ; Reset ALP2 (roll sign) and BET2 (pitch sign)
 STA BET2               ; to negative, i.e. pitch and roll negative

 ASL A                  ; This sets A to 0

 STA demoInProgress     ; Set demoInProgress to 0 to reset the demo flag, so if
                        ; we are starting the game after playing the demo, the
                        ; flag will be set correctly

 STA BETA               ; Reset BETA (pitch angle alpha) to 0

 STA BET1               ; Reset BET1 (magnitude of the pitch angle) to 0

 STA ALP2+1             ; Reset ALP2+1 (flipped roll sign) and BET2+1 (flipped
 STA BET2+1             ; pitch sign) to positive, i.e. pitch and roll negative

 STA MCNT               ; Reset MCNT (the main loop counter) to 0

 STA LAS                ; Set LAS to 0, to switch off laser pulsing

 STA unusedVariable     ; Set unusedVariable to 0 (this is never read, so this
                        ; has no effect)

 STA chargeDockingFee   ; Set chargeDockingFee to 0 so the docking fee is marked
                        ; as being not already paid

 LDA #3                 ; Reset DELTA (speed) to 3
 STA DELTA

 STA ALPHA              ; Reset ALPHA (roll angle alpha) to 3

 STA ALP1               ; Reset ALP1 (magnitude of roll angle alpha) to 3

 LDA #72                ; Set the screen height variables for a screen height of
 JSR SetScreenHeight    ; 144 (i.e. 2 * 72)

 LDA ECMA               ; Fetch the E.C.M. status flag, and if E.C.M. is off,
 BEQ yu                 ; skip the next instruction

 JSR ECMOF              ; Turn off the E.C.M. sound

.yu

 JSR WPSHPS             ; Wipe all ships from the scanner

 LDA QQ11a              ; If bit 7 of the old view in QQ11a is set, then the old
 BMI rese2              ; view does not have a dashboard, so jump to rese2 to
                        ; skip the following, as there is no scanner to clear

 JSR HideExplosionBurst ; Hide the four sprites that make up the explosion burst

 JSR ClearScanner       ; Remove all ships from the scanner and hide the scanner
                        ; sprites

.rese2

 JSR ZERO               ; Reset the ship slots for the local bubble of universe,
                        ; and various flight and ship status variables

                        ; Finally, fall through into ZINF to reset the INWK
                        ; ship workspace

; ******************************************************************************
;
;       Name: ZINF
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

.ZINF

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

 ORA #%10000000         ; Flip the sign of A to represent a -1

 STA INWK+14            ; Set byte #14 = nosev_z_hi = -96 = -1

 RTS                    ; Return from the subroutine

; ******************************************************************************
;
;       Name: SetScreenHeight
;       Type: Subroutine
;   Category: Drawing the screen
;    Summary: Set the screen height variables to the specified height
;
; ------------------------------------------------------------------------------
;
; Arguments:
;
;   A                   The y-coordinate of the centre of the screen (i.e. half
;                       the screen height)
;
; ******************************************************************************

.SetScreenHeight

 STA halfScreenHeight   ; Store the half-screen height in halfScreenHeight

 ASL A                  ; Double the half-screen height in A to get the full
                        ; screen height, while setting the C flag to bit 7 of
                        ; the original argument
                        ;
                        ; This routine is only ever called with A set to either
                        ; 72 or 77, so the C flag is never set

 STA screenHeight       ; Store the full screen height in screenHeight

 SBC #0                 ; Set the value of Yx2M1 as follows:
 STA Yx2M1              ;
                        ;   * If the C flag is set: Yx2M1 = screenHeight
                        ;
                        ;   * If the C flag is clear: Yx2M1 = screenHeight - 1
                        ;
                        ; This routine is only ever called with A set to either
                        ; 72 or 77, so the C flag is never set, so we always set
                        ; Yx2M1 = screenHeight - 1

 RTS                    ; Return from the subroutine

; ******************************************************************************
;
;       Name: msblob
;       Type: Subroutine
;   Category: Dashboard
;    Summary: Display the dashboard's missile indicators in black or grey
;
; ------------------------------------------------------------------------------
;
; Display the dashboard's missile indicators, with all the missiles reset to
; black (i.e. not armed or locked), or grey if there is no missile.
;
; ******************************************************************************

.msblob

 LDX #4                 ; Set up a loop counter in X to count through all four
                        ; missile indicators

.ss

 CPX NOMSL              ; If the counter is equal to the number of missiles,
 BEQ SAL8               ; jump down to SAL8 to draw the remaining missiles, as
                        ; the rest of them are present and should be drawn in
                        ; black

 LDY #133               ; Set the tile pattern for the missile indicator at
 JSR MSBAR              ; position X to 133, which is the same grey as the
                        ; dashboard, so this effectively hides the indicator

 DEX                    ; Decrement the counter to point to the next missile

 BNE ss                 ; Loop back to ss if we still have missiles to draw

 RTS                    ; Return from the subroutine

.SAL8

 LDY #108               ; Set the tile pattern for the missile indicator at
 JSR MSBAR              ; position X to 108, which is a black indicator

 DEX                    ; Decrement the counter to point to the next missile

 BNE SAL8               ; Loop back to SAL8 if we still have missiles to draw

 RTS                    ; Return from the subroutine

; ******************************************************************************
;
;       Name: Main game loop (Part 1 of 6)
;       Type: Subroutine
;   Category: Main loop
;    Summary: Spawn a trader (a Cobra Mk III, Python, Boa or Anaconda)
;  Deep dive: Program flow of the main game loop
;             Ship data blocks
;
; ------------------------------------------------------------------------------
;
; This is part of the main game loop. This is where the core loop of the game
; lives, and it's in two parts. The shorter loop (just parts 5 and 6) is
; iterated when we are docked, while the entire loop from part 1 to 6 iterates
; if we are in space.
;
; This section covers the following:
;
;   * Spawn a trader, i.e. a Cobra Mk III, Python, Boa or Anaconda, with a 50%
;     chance of it having a missile, a 50% chance of it having an E.C.M., a 50%
;     chance of it docking and being aggressive if attacked, a speed between 16
;     and 31, and a gentle clockwise roll
;
; We call this from within the main loop.
;
; ******************************************************************************

.MTT4

 JSR DORND              ; Set A and X to random numbers

 LSR A                  ; Clear bit 7 of our random number in A and set the C
                        ; flag to bit 0 of A, which is random

 STA INWK+32            ; Store this in the ship's AI flag, so this ship does
                        ; not have AI

 STA INWK+29            ; Store A in the ship's roll counter, giving it a
                        ; clockwise roll (as bit 7 is clear), and a 1 in 127
                        ; chance of it having no damping

 ROL INWK+31            ; Set bit 0 of the ship's missile count randomly (as the
                        ; C flag was set), giving the ship either no missiles or
                        ; one missile

 AND #15                ; Set the ship speed to our random number, set to a
 ADC #10                ; minimum of 10 and a maximum of 26 (as the C flag is
 STA INWK+27            ; also randomly set)

 JSR DORND              ; Set A and X to random numbers, plus the C flag

 BMI nodo               ; If A is negative (50% chance), jump to nodo to skip
                        ; the following

                        ; If we get here then we are going to spawn a ship that
                        ; is minding its own business and trying to dock

 LDA INWK+32            ; Set bits 6 and 7 of the ship's AI flag, to make it
 ORA #%11000000         ; aggressive if attacked, and enable its AI
 STA INWK+32

 LDX #%00010000         ; Set bit 4 of the ship's NEWB flags, to indicate that
 STX NEWB               ; this ship is docking

.nodo

 AND #2                 ; If we jumped here with a random value of A from the
                        ; BMI above, then this reduces A to a random value of
                        ; either 0 or 2; if we didn't take the BMI and made the
                        ; ship hostile, then A will be 0

 ADC #CYL               ; Set A = A + C + #CYL
                        ;
                        ; where A is 0 or 2 and C is 0 or 1, so this gives us a
                        ; ship type from the following: Cobra Mk III, Python,
                        ; Boa or Anaconda

 CMP #HER               ; If A is not the ship type of a rock hermit, jump to
 BNE game1              ; game1 to skip the following instruction

 LDA #CYL               ; This is a rock hermit, so set A = #CYL so we spawn a
                        ; Cobra Mk III

.game1

 JSR NWSHP              ; Add a new ship of type A to the local bubble and fall
                        ; through into the main game loop again

 JMP MLOOP              ; Jump down to MLOOP to do some end-of-loop tidying and
                        ; restart the main loop

; ******************************************************************************
;
;       Name: Main game loop (Part 2 of 6)
;       Type: Subroutine
;   Category: Main loop
;    Summary: Call the main flight loop, and potentially spawn a trader, an
;             asteroid, or a cargo canister
;  Deep dive: Program flow of the main game loop
;             Ship data blocks
;             Fixing ship positions
;
; ------------------------------------------------------------------------------
;
; This section covers the following:
;
;   * Call M% to do the main flight loop
;
;   * Potentially spawn a trader, asteroid or cargo canister
;
; Other entry points:
;
;   TT100               The entry point for the start of the main game loop,
;                       which calls the main flight loop and the moves into the
;                       spawning routine
;
;   me3                 Used by me2 to jump back into the main game loop after
;                       printing an in-flight message
;
; ******************************************************************************

.TT100

 LDA nmiTimerLo         ; Store the low byte of the NMI timer (which will be
 STA RAND               ; pretty random) in the RAND seed

 LDA K%+6               ; Store the z_lo coordinate for the planet (which will
 STA RAND+1             ; be pretty random) in the RAND+1 seed

 LDA soundVar07         ; Store the soundVar07 variable (which will be pretty
 STA RAND+3             ; random) in the RAND+3 seed

 LDA QQ12               ; Fetch the docked flag from QQ12 into A

 BEQ game2              ; If we are docked, jump down to MLOOP to skip all the
 JMP MLOOP              ; the flight and spawning code in the top part of the
                        ; main loop

.game2

 JSR M%                 ; Call M% to iterate through the main flight loop

 DEC MCNT               ; Decrement the main loop counter in MCNT

 BEQ P%+5               ; If the counter has reached zero, which it will do
                        ; every 256 main loops, skip the next JMP instruction
                        ; (or to put it another way, if the counter hasn't
                        ; reached zero, jump down to MLOOP, skipping all the
                        ; following checks)

.ytq

 JMP MLOOP              ; Jump down to MLOOP to do some end-of-loop tidying and
                        ; restart the main loop

                        ; We only get here once every 256 iterations of the
                        ; main loop. If we aren't in witchspace and don't
                        ; already have 3 or more asteroids in our local bubble,
                        ; then this section has a 13% chance of spawning
                        ; something benign (the other 87% of the time we jump
                        ; down to consider spawning cops, pirates and bounty
                        ; hunters)
                        ;
                        ; If we are in that 13%, then 50% of the time this will
                        ; be a Cobra Mk III trader, and the other 50% of the
                        ; time it will either be an asteroid (98.5% chance) or,
                        ; very rarely, a cargo canister (1.5% chance)

 LDA MJ                 ; If we are in witchspace (in which case MJ > 0) or
 ORA demoInProgress     ; demoInProgress > 0 (in which case we are playing the
 BNE ytq                ; demo), jump down to MLOOP (via ytq above)

 JSR DORND              ; Set A and X to random numbers

 CMP #40                ; If A >= 40 (85% chance), jump down to MTT1 to skip
 BCS MTT1               ; the spawning of an asteroid or cargo canister and
                        ; potentially spawn something else

 LDA JUNK               ; If we already have 3 or more bits of junk in the local
 CMP #3                 ; bubble, jump down to MTT1 to skip the following and
 BCS MTT1               ; potentially spawn something else

 JSR ZINF               ; Call ZINF to reset the INWK ship workspace

 LDA #38                ; Set z_hi = 38 (far away)
 STA INWK+7

 JSR DORND              ; Set A, X and C flag to random numbers

 STA INWK               ; Set x_lo = random

 STX INWK+3             ; Set y_lo = random
                        ;
                        ; Note that because we use the value of X returned by
                        ; DORND, and X contains the value of A returned by the
                        ; previous call to DORND, this does not set the new ship
                        ; to a totally random location. See the deep dive on
                        ; "Fixing ship positions" for details

 AND #%10000000         ; Set x_sign = bit 7 of x_lo
 STA INWK+2

 TXA                    ; Set y_sign = bit 7 of y_lo
 AND #%10000000
 STA INWK+5

 ROL INWK+1             ; Set bit 1 of x_hi to the C flag, which is random, so
 ROL INWK+1             ; this randomly moves us off-centre by 512 (as if x_hi
                        ; is %00000010, then (x_hi x_lo) is 512 + x_lo)

 JSR DORND              ; Set A, X and V flag to random numbers

 AND #%00110000         ; If either of bits 4 and 5 are set (75% chance), skip
 BNE P%+5               ; the following instruction

 JMP MTT4               ; Jump up to MTT4 to spawn a trader (25% chance)

 ORA #%01101111         ; Take the random number in A and set bits 0-3 and 5-6,
 STA INWK+29            ; so the result has a 50% chance of being positive or
                        ; negative, and a 50% chance of bits 0-6 being 127.
                        ; Storing this number in the roll counter therefore
                        ; gives our new ship a fast roll speed with a 50%
                        ; chance of having no damping, plus a 50% chance of
                        ; rolling clockwise or anti-clockwise

 LDA SSPR               ; If we are inside the space station safe zone, jump
 BNE MLOOPS             ; down to MLOOPS to stop spawning

 TXA                    ; Set A to the random X we set above, which we haven't
 BCS MTT2               ; used yet, and if the C flag is set (50% chance) jump
                        ; down to MTT2 to skip the following

 AND #31                ; Set the ship speed to our random number, reduced to
 ORA #16                ; the range 16 to 31
 STA INWK+27

 BCC MTT3               ; Jump down to MTT3, skipping the following (this BCC
                        ; is effectively a JMP as we know the C flag is clear,
                        ; having passed through the BCS above)

.MTT2

 ORA #%01111111         ; Set bits 0-6 of A to 127, leaving bit 7 as random, so
 STA INWK+30            ; storing this number in the pitch counter means we have
                        ; full pitch with no damping, with a 50% chance of
                        ; pitching up or down

.MTT3

 JSR DORND              ; Set A and X to random numbers

 CMP #252               ; If random A < 252 (98.8% of the time), jump to thongs
 BCC thongs             ; to skip the following

 LDA #HER               ; Set A to #HER so we spawn a rock hermit 1.2% of the
                        ; time

 STA INWK+32            ; Set byte #32 to %00001111 to give the rock hermit an
                        ; E.C.M.

 BNE whips              ; Jump to whips (this BNE is effectively a JMP as A will
                        ; never be zero)

.thongs

 CMP #10                ; If random A >= 10 (96% of the time), set the C flag

 AND #1                 ; Reduce A to a random number that's 0 or 1

 ADC #OIL               ; Set A = #OIL + A + C, so there's a tiny chance of us
                        ; spawning a cargo canister (#OIL) and an even chance of
                        ; us spawning either a boulder (#OIL + 1) or an asteroid
                        ; (#OIL + 2)

.whips

 JSR NWSHP              ; Add our new asteroid or canister to the universe

; ******************************************************************************
;
;       Name: Main game loop (Part 3 of 6)
;       Type: Subroutine
;   Category: Main loop
;    Summary: Potentially spawn a cop, particularly if we've been bad
;  Deep dive: Program flow of the main game loop
;             Ship data blocks
;             Fixing ship positions
;
; ------------------------------------------------------------------------------
;
; This section covers the following:
;
;   * Potentially spawn a cop (in a Viper), very rarely if we have been good,
;     more often if have been naughty, and very often if we have been properly
;     bad
;
;   * Very rarely, consider spawning a Thargoid, or vanishingly rarely, a Cougar
;
; ******************************************************************************

.MLOOPS

 JMP MLOOP              ; Jump to MLOOP to skip the following

.MTT1

 LDA SSPR               ; If we are inside the space station's safe zone, jump
 BNE MLOOPS             ; to MLOOP via MLOOPS to skip the following

 JSR BAD                ; Call BAD to work out how much illegal contraband we
                        ; are carrying in our hold (A is up to 40 for a
                        ; standard hold crammed with contraband, up to 70 for
                        ; an extended cargo hold full of narcotics and slaves)

 ASL A                  ; Double A to a maximum of 80 or 140

 LDX MANY+COPS          ; If there are no cops in the local bubble, skip the
 BEQ P%+5               ; next instruction

 ORA FIST               ; There are cops in the vicinity and we've got a hold
                        ; full of jail time, so OR the value in A with FIST to
                        ; get a new value that is at least as high as both
                        ; values, to reflect the fact that they have almost
                        ; certainly scanned our ship

 STA T                  ; Store our badness level in T

 JSR Ze                 ; Call Ze to initialise INWK to a potentially hostile
                        ; ship, and set A and X to random values
                        ;
                        ; Note that because Ze uses the value of X returned by
                        ; DORND, and X contains the value of A returned by the
                        ; previous call to DORND, this does not set the new ship
                        ; to a totally random location. See the deep dive on
                        ; "Fixing ship positions" for details

 CMP #136               ; If the random number in A = 136 (0.4% chance), jump
 BNE P%+5               ; to fothg in part 4 to spawn either a Thargoid or, very
 JMP fothg              ; rarely, a Cougar

 CMP T                  ; If the random value in A >= our badness level, which
 BCS game3              ; will be the case unless we have been really, really
                        ; bad, then skip the following two instructions (so
                        ; if we are really bad, there's a higher chance of
                        ; spawning a cop, otherwise we got away with it, for
                        ; now)

 LDA NEWB               ; We are a fugitive or a bad offender, and we are about
 ORA #%00000100         ; to spawn a cop, so set bit 2 of the ship's NEWB flags
 STA NEWB               ; to make it hostile

 LDA #COPS              ; Add a new police ship to the local bubble
 JSR NWSHP

.game3

 LDA MANY+COPS          ; If we now have at least one cop in the local bubble,
 BNE MLOOPS             ; jump down to MLOOPS to stop spawning, otherwise fall
                        ; through into the next part to look at spawning
                        ; something else

; ******************************************************************************
;
;       Name: Main game loop (Part 4 of 6)
;       Type: Subroutine
;   Category: Main loop
;    Summary: Potentially spawn a lone bounty hunter, a Thargoid, or up to four
;             pirates
;  Deep dive: Program flow of the main game loop
;             Ship data blocks
;             Fixing ship positions
;             The elusive Cougar
;
; ------------------------------------------------------------------------------
;
; This section covers the following:
;
;   * Potentially spawn (35% chance) either a lone bounty hunter (a Cobra Mk
;     III, Asp Mk II, Python or Fer-de-lance), a Thargoid, or a group of up to 4
;     pirates (a mix of Sidewinders, Mambas, Kraits, Adders, Geckos, Cobras Mk I
;     and III, and Worms)
;
;   * Also potentially spawn a Constrictor if this is the mission 1 endgame, or
;     Thargoids if mission 2 is in progress
;
; ******************************************************************************

 DEC EV                 ; Decrement EV, the extra vessels spawning delay, and if
 BPL MLOOPS             ; it is still positive, jump to MLOOPS to stop spawning,
                        ; so we only do the following when the EV counter runs
                        ; down

 INC EV                 ; EV is negative, so bump it up again, setting it back
                        ; to 0

 LDA TP                 ; Fetch bits 2 and 3 of TP, which contain the status of
 AND #%00001100         ; mission 2

 CMP #%00001000         ; If bit 3 is set and bit 2 is clear, keep going to
 BNE nopl               ; spawn a Thargoid as we are transporting the plans in
                        ; mission 2 and the Thargoids are trying to stop us,
                        ; otherwise jump to nopl to skip spawning a Thargoid

 JSR DORND              ; Set A and X to random numbers

 CMP #200               ; If the random number in A < 200 (78% chance), jump to
 BCC nopl               ; nopl to skip spawning a Thargoid

.fothg2

 JSR GTHG+15            ; Call GTHG+15 to spawn a lone Thargoid, without a
                        ; Thargon companion

 JMP MLOOP              ; Jump down to MLOOP to do some end-of-loop tidying and
                        ; restart the main loop

.nopl

 JSR DORND              ; Set A and X to random numbers

 LDY gov                ; If the government of this system is 0 (anarchy), jump
 BEQ LABEL_2            ; straight to LABEL_2 to start spawning pirates or a
                        ; lone bounty hunter

 LDY JUNK               ; Set Y to the number of junk items in our local bubble
                        ; of universe (where junk is asteroids, canisters,
                        ; escape pods and so on)

 LDX FRIN+2,Y           ; The ship slots at FRIN are ordered with the first two
                        ; slots reserved for the planet and sun/space station,
                        ; and then any ships, so if the slot at FRIN+2+Y is not
                        ; empty (i.e. is non-zero), then that means the number
                        ; of non-asteroids in the vicinity is at least 1

 BEQ game4              ; So if X = 0, there are no ships in the vicinity, so
                        ; jump to game4 to skip the following and increase the
                        ; chances of spawning

 CMP #50                ; If the random number in A >= 50 (80% chance), jump to
 BCS MLOOPS             ; MLOOPS to stop spawning (so there's a 25% chance of
                        ; spawning pirates or bounty hunters)

.game4

 CMP #100               ; If the random number in A >= 100 (61% chance), jump to
 BCS MLOOPS             ; MLOOPS to stop spawning (so there's a 39% chance of
                        ; spawning pirates or bounty hunters)

 AND #7                 ; Reduce the random number in A to the range 0-7, and
 CMP gov                ; if A is less than government of this system, jump
 BCC MLOOPS             ; to MLOOPS to stop spawning (so safer governments with
                        ; larger gov numbers have a greater chance of jumping
                        ; out, which is another way of saying that more
                        ; dangerous systems spawn pirates and bounty hunters
                        ; more often)

.LABEL_2

 JSR Ze                 ; Call Ze to initialise INWK to a potentially hostile
                        ; ship, and set A and X to random values
                        ;
                        ; Note that because Ze uses the value of X returned by
                        ; DORND, and X contains the value of A returned by the
                        ; previous call to DORND, this does not set the new ship
                        ; to a totally random location. See the deep dive on
                        ; "Fixing ship positions" for details

 CMP #100               ; Set the C flag depending on whether the random number
                        ; in A >= 100, for the BCS below

 AND #15                ; Set A to our random number but in the range 16 to 31
 ORA #16

 STA INWK+27            ; Give the ship we're about to spawn a speed of between
                        ; 16 and 31

 BCS mt1                ; If the random number in A >= 100 (61% chance), jump
                        ; to mt1 to spawn pirates, otherwise keep going to
                        ; spawn a lone bounty hunter or a Thargoid

 INC EV                 ; Increase the extra vessels spawning counter, to
                        ; prevent the next attempt to spawn extra vessels

 AND #3                 ; Set A = random number in the range 0-3, which we
                        ; will now use to determine the type of ship

 ADC #CYL2              ; Add A to #CYL2 (we know the C flag is clear as we
                        ; passed through the BCS above), so A is now one of the
                        ; lone bounty hunter ships, i.e. Cobra Mk III (pirate),
                        ; Asp Mk II, Python (pirate) or Fer-de-lance

 TAY                    ; Copy the new ship type to Y

 JSR THERE              ; Call THERE to see if we are in the Constrictor's
                        ; system in mission 1

 BCC NOCON              ; If the C flag is clear then we are not in the
                        ; Constrictor's system, so skip to NOCON

 LDA #%11111001         ; Set the AI flag of this ship so that it has E.C.M.,
 STA INWK+32            ; has a very high aggression level of 28 out of 31, is
                        ; hostile, and has AI enabled - nasty stuff!

 LDA TP                 ; Fetch bits 0 and 1 of TP, which contain the status of
 AND #%00000011         ; mission 1

 LSR A                  ; Shift bit 0 into the C flag

 BCC NOCON              ; If bit 0 is clear, skip to NOCON as mission 1 is not
                        ; in progress

 ORA MANY+CON           ; Bit 0 of A now contains bit 1 of TP, so this will be
                        ; set if we have already completed mission 1, so this OR
                        ; will be non-zero if we have either completed mission
                        ; 1, or there is already a Constrictor in our local
                        ; bubble of universe (in which case MANY+CON will be
                        ; non-zero)

 BEQ YESCON             ; If A = 0 then mission 1 is in progress, we haven't
                        ; completed it yet, and there is no Constrictor in the
                        ; vicinity, so jump to YESCON to spawn the Constrictor

.NOCON

 JSR DORND              ; Set A and X to random numbers

 CMP #200               ; First, set the C flag if X >= 200 (22% chance)

 ROL A                  ; Set bit 0 of A to the C flag (i.e. there's a 22%
                        ; chance of this ship having E.C.M.)

 ORA #%11000000         ; Set bits 6 and 7 of A, so the ship is hostile (bit 6)
                        ; and has AI (bit 7)

 STA INWK+32            ; Store A in the AI flag of this ship

 TYA                    ; Set A to the new ship type in Y

 EQUB $2C               ; Skip the next instruction by turning it into
                        ; $2C $A9 $1F, or BIT $1FA9, which does nothing apart
                        ; from affect the flags

.YESCON

 LDA #CON               ; If we jump straight here, we are in the mission 1
                        ; endgame and it's time to spawn the Constrictor, so
                        ; set A to the Constrictor's type

.focoug

 JSR NWSHP              ; Spawn the new ship, whether it's a pirate, Thargoid,
                        ; Cougar or Constrictor

.mj1

 JMP MLOOP              ; Jump down to MLOOP, as we are done spawning ships

.fothg

 LDA K%+6               ; Fetch the z_lo coordinate of the first ship in the K%
 AND #%00111110         ; block (i.e. the planet) and extract bits 1-5

 BNE fothg2             ; If any of bits 1-5 are set (96.8% chance), jump up to
                        ; fothg2 to spawn a Thargoid

                        ; If we get here then we're going to spawn a Cougar, a
                        ; very rare event indeed. How rare? Well, all the
                        ; following have to happen in sequence:
                        ;
                        ;  * Main loop iteration = 0 (1 in 256 iterations)
                        ;  * Skip asteroid spawning (87% chance)
                        ;  * Skip cop spawning (0.4% chance)
                        ;  * Skip Thargoid spawning (3.2% chance)
                        ;
                        ; so the chances of spawning a Cougar on any single main
                        ; loop iteration are slim, to say the least

 LDA #18                ; Give the ship we're about to spawn a speed of 27
 STA INWK+27

 LDA #%01111001         ; Give it an E.C.M., and make it hostile and pretty
 STA INWK+32            ; aggressive (though don't give it AI)

 LDA #COU               ; Set the ship type to a Cougar and jump up to focoug
 BNE focoug             ; to spawn it

.mt1

 AND #3                 ; It's time to spawn a group of pirates, so set A to a
                        ; random number in the range 0-3, which will be the
                        ; loop counter for spawning pirates below (so we will
                        ; spawn 1-4 pirates)

 STA EV                 ; Delay further spawnings by this number

 STA XX13               ; Store the number in XX13, the pirate counter

.mt3

 LDA #%00000100         ; Set bit 2 of the NEWB flags and clear all other bits,
 STA NEWB               ; so the ship we are about to spawn is hostile

 JSR DORND              ; Set A and X to random numbers

 STA T                  ; Set T to a random number

 JSR DORND              ; Set A and X to random numbers

 AND T                  ; Set A to the AND of two random numbers, so each bit
                        ; has 25% chance of being set which makes the chances
                        ; of a smaller number higher

 AND #7                 ; Reduce A to a random number in the range 0-7, though
                        ; with a bigger chance of a smaller number in this range

 ADC #PACK              ; #PACK is set to #SH3, the ship type for a Sidewinder,
                        ; so this sets our new ship type to one of the pack
                        ; hunters, namely a Sidewinder, Mamba, Krait, Adder,
                        ; Gecko, Cobra Mk I, Worm or Cobra Mk III (pirate)

 JSR NWSHP              ; Try adding a new ship of type A to the local bubble

 DEC XX13               ; Decrement the pirate counter

 BPL mt3                ; If we need more pirates, loop back up to mt3,
                        ; otherwise we are done spawning, so fall through into
                        ; the end of the main loop at MLOOP

; ******************************************************************************
;
;       Name: Main game loop (Part 5 of 6)
;       Type: Subroutine
;   Category: Main loop
;    Summary: Cool down lasers, make calls to update the dashboard
;  Deep dive: Program flow of the main game loop
;             The dashboard indicators
;
; ------------------------------------------------------------------------------
;
; This is the first half of the minimal game loop, which we iterate when we are
; docked. This section covers the following:
;
;   * Cool down lasers
;
;   * Make calls to update the dashboard
;
; Other entry points:
;
;   MLOOP               The entry point for the main game loop. This entry point
;                       comes after the call to the main flight loop and
;                       spawning routines, so it marks the start of the main
;                       game loop for when we are docked (as we don't need to
;                       call the main flight loop or spawning routines if we
;                       aren't in space)
;
; ******************************************************************************

.MLOOP

 LDX #$FF               ; Set the stack pointer to $01FF, which is the standard
 TXS                    ; location for the 6502 stack, so this instruction
                        ; effectively resets the stack

 LDX GNTMP              ; If the laser temperature in GNTMP is non-zero,
 BEQ EE20               ; decrement it (i.e. cool it down a bit)
 DEC GNTMP

.EE20

 LDX LASCT              ; Set X to the value of LASCT, the laser pulse count

 BEQ NOLASCT            ; If X = 0 then jump to NOLASCT to skip reducing LASCT,
                        ; as it can't be reduced any further

 DEX                    ; Decrement the value of LASCT in X

 BEQ P%+3               ; If X = 0, skip the next instruction

 DEX                    ; Decrement the value of LASCT in X again

 STX LASCT              ; Store the decremented value of X in LASCT, so LASCT
                        ; gets reduced by 2, but not into negative territory

.NOLASCT

 LDA QQ11               ; If this is a space view, skip the following two
 BEQ P%+7               ; instructions (i.e. jump to JSR TT17 below)

 LDY #4                 ; Wait for 4/50 of a second (0.08 seconds), to slow the
 JSR DELAY              ; main loop down a bit

 LDA TRIBBLE+1          ; If the high byte of TRIBBLE(1 0), the number of
 BEQ game5              ; Trumbles in the hold, is zero, jump to game5 to skip
                        ; the following

                        ; We have a lot of Trumbles in the hold, so let's see if
                        ; any of them are breeding (note that Trumbles always
                        ; breed when we jump into a new system in the SOLAR
                        ; routine, but when we have lots of them, they also
                        ; breed here in the main flight loop

 JSR DORND              ; Set A and X to random numbers

 CMP #220               ; If A >= 220 then set the C flag (14% chance)

 LDA TRIBBLE            ; Add the C flag to TRIBBLE(1 0), starting with the low
 ADC #0                 ; bytes
 STA TRIBBLE

 BCC game5              ; And then the high bytes
 INC TRIBBLE+1          ;
                        ; So there is a 14% chance of a Trumble being born

 BPL game5              ; If the high byte of TRIBBLE(1 0) is now $80, then
 DEC TRIBBLE+1          ; decrement it back to $7F, so the number of Trumbles
                        ; never goes above $7FFF (32767)

.game5

 LDA TRIBBLE+1          ; If the high byte of TRIBBLE(1 0), the number of
 BEQ game7              ; Trumbles in the hold, is zero, jump to game7 to skip
                        ; the following

                        ; We have a lot of Trumbles in the hold, so they are
                        ; probably making a bit of a noise

 LDY CABTMP             ; If the cabin temperature is >= 224 then jump to game6
 CPY #224               ; to skip the following and leave the value of A as a
 BCS game6              ; high value, so the chances of the Trumbles making a
                        ; noise in hot temperature is greater (specifically,
                        ; this is the temperature at which the fuel scoop start
                        ; working)

 LSR A                  ; Set A = A / 2
 LSR A

.game6

 STA T                  ; Set T = A, which will be higher with more Trumbles and
                        ; higher temperatures

 JSR DORND              ; Set A and X to random numbers

 CMP T                  ; If A >= T then jump to game7 to skip making any noise,
 BCS game7              ; so there is a higher chance of Trumbles making noise
                        ; when there are lots of them or the cabin temperature
                        ; is hot enough for the fuel scoops to work

 AND #3                 ; Set Y to our random number reduced to the range 0 to 3
 TAY

 LDA trumbleNoises,Y    ; Set Y to the Y-th noise number from the trumbleNoises
 TAY                    ; table, so there's a 75% change of Y being set to 5,
                        ; and a 25% chance of Y being set to 6

 JSR NOISE              ; Call the NOISE routine to make the sound of the
                        ; Trumbles in Y, which will be one of 5 or 6, with 5
                        ; more likely than 6

.game7

 LDA allowInSystemJump  ; Set A to the value of allowInSystemJump, which
                        ; determines whether we are allowed to perform an
                        ; in-system jump (which is the same as saying whether
                        ; the fast-forward button is enabled)

 LDX QQ22+1             ; Fetch into X the number that's shown on-screen during
                        ; the hyperspace countdown

 BEQ game8              ; If the counter is zero then we are not counting down
                        ; to hyperspace, so jump to game8 to skip the next
                        ; instruction

 ORA #%10000000         ; Set bit 7 of A to prevent in-system jumps, as there
                        ; is a hyperspace countdown in progress

.game8

 LDX demoInProgress     ; If the demo is not in progress, jump to game9 to skip
 BEQ game9              ; the following

 AND #%01111111         ; Clear bit 7 of A to enable the fast-forward button, as
                        ; this is the combat demo and the fast-forward button
                        ; lets us skip the rest of the demo

.game9

 STA allowInSystemJump  ; Store the updated value of A in allowInSystemJump

 AND #%11000000         ; If bits 6 and 7 of allowInSystemJump are both clear
 BEQ game10             ; then in-system jumps are allowed, so jump to game10
                        ; to leave allowInSystemJump alone

 CMP #%11000000         ; If bits 6 and 7 of allowInSystemJump are both set then
 BEQ game10             ; in-system jumps are not allowed, so jump to game10 to
                        ; leave allowInSystemJump alone

 CMP #%10000000         ; If bit 7 of allowInSystemJump is set but bit 6 isn't,
                        ; then this sets the C flag, otherwise it clears the C
                        ; flag

 ROR A                  ; This updates allowInSystemJump as follows:
 STA allowInSystemJump  ;
                        ;   * %10xxxxxx rotates to %11xxxxxx
                        ;
                        ;   * %01xxxxxx rotates to %00xxxxxx
                        ;
                        ; In other words, when bit 7 of the allowInSystemJump
                        ; flag is set, then that condition will spread to both
                        ; bit 6 and 7, but if only bit 6 is set, then the flag
                        ; will clear at this point in the main game loop
                        ;
                        ; So once bit 7 is cleared, in-system jumps will be
                        ; allowed within an iteration of the main loop, assuming
                        ; no more preventative conditions appear

 JSR UpdateIconBar_b3   ; Update the icon bar to hide or show the in-system jump
                        ; icon bar button, according to the new value of the
                        ; allowInSystemJump flag

.game10

 JSR TT17               ; Scan the key logger for the directional pad buttons,
                        ; returning the cursor's delta values in X and Y and
                        ; the button pressed in A

; ******************************************************************************
;
;       Name: Main game loop (Part 6 of 6)
;       Type: Subroutine
;   Category: Main loop
;    Summary: Process non-flight key presses (icon bar selections)
;  Deep dive: Program flow of the main game loop
;
; ------------------------------------------------------------------------------
;
; This is the second half of the minimal game loop, which we iterate when we are
; docked. This section covers the following:
;
;   * Process icon bar selections
;
; It also supports joining the main loop with a key already "pressed", so we can
; jump into the main game loop to perform a specific action. In practice, this
; is used when we enter the docking bay in BAY to display the Status Mode
; screen.
;
; Other entry points:
;
;   FRCE                The entry point for the main game loop if we want to
;                       jump straight to a specific screen, by pretending to
;                       "press" a key, in which case A contains the internal key
;                       number of the key we want to "press"
;
; ******************************************************************************

.FRCE

 JSR TT102              ; Call TT102 to process the key pressed in A

 JMP TT100              ; Jump to TT100 to restart the main loop from the start

; ******************************************************************************
;
;       Name: trumbleNoises
;       Type: Variable
;   Category: Sound
;    Summary: The set of noises that the Trumbles make in the hold
;
; ******************************************************************************

.trumbleNoises

 EQUB 5, 5, 5, 6

; ******************************************************************************
;
;       Name: TT102
;       Type: Subroutine
;   Category: Icon bar
;    Summary: Process icon bar controller choices
;
; ------------------------------------------------------------------------------
;
; This routine does a similar job to the routine of the same name in the BBC
; Master version of Elite, but the code is significantly different.
;
; Arguments:
;
;   A                   The button number of the chosen icon from the icon bar
;
;   X                   The amount to move the crosshairs in the x-axis
;
;   Y                   The amount to move the crosshairs in the y-axis
;
; Other entry points:
;
;   ReturnFromSearch    Re-entry point following a system search in HME2
;
; ******************************************************************************

.TT102

 CMP #0                 ; If no icon was chosen, jump to HME1 to skip all the
 BNE P%+5               ; icon checks below
 JMP HME1

 CMP #3                 ; If the Status Mode icon was chosen, jump to STATUS to
 BNE P%+5               ; show the Status Mode screen, returning from the
 JMP STATUS             ; subroutine using a tail call

 CMP #4                 ; If the Charts icon was chosen from the docked icon
 BEQ barb1              ; bar, jump to barb1 to show the correct chart

 CMP #36                ; If the Switch chart range icon from the Charts icon
 BNE barb2              ; bar was not chosen, jump to barb2 to keep checking

 LDA chartToShow        ; The Switch chart range icon from the Charts icon bar
 EOR #%10000000         ; was chosen, so flip bit 7 of chartToShow to toggle
 STA chartToShow        ; the chart between the Long-range and Short-range
                        ; Chart

.barb1

 LDA chartToShow        ; If chartToShow = 0 then jump to TT23 to show the
 BPL P%+5               ; Short-range Chart, otherwise jump to TT22 to show the
 JMP TT22               ; Long-range Chart, in either case returning from the
 JMP TT23               ; subroutine using a tail call

.barb2

 CMP #35                ; If the Data on System icon was chosen, call the
 BNE TT92               ; SetSelectedSystem routine to set the selected system
 JSR SetSelectedSystem  ; to the nearest system, if we don't already have a
 JMP TT25               ; selected system, and then jump to TT25 to show the
                        ; Data on System screen, returning from the subroutine
                        ; using a tail call

.TT92

 CMP #8                 ; If the Inventory icon was chosen, jump to TT213 to
 BNE P%+5               ; show the Inventory screen, returning from the
 JMP TT213              ; subroutine using a tail call

 CMP #2                 ; If the Market Price icon was chosen, jump to TT167 to
 BNE P%+5               ; show the Market Price screen, returning from the
 JMP TT167              ; subroutine using a tail call

 CMP #1                 ; If the Launch icon was not chosen, jump to fvw to
 BNE fvw                ; skip the following launch code

                        ; The Launch icon was chosen, so we now attempt to
                        ; launch

 LDX QQ12               ; If QQ12 is zero then we are not docked, so jump to fvw
 BEQ fvw                ; as we can't launch from the station if we are already
                        ; in space

 JSR SelectNearbySystem ; Set the current system to the nearest system to
                        ; (QQ9, QQ10), which will be the system we are currently
                        ; docked at, and update the selected system flags
                        ; accordingly

 JMP TT110              ; Jump to TT110 to launch our ship, returning from the
                        ; subroutine using a tail call

.fvw

 CMP #17                ; If the Docking Computer icon was not chosen, jump to
 BNE barb8              ; barb8 to move on to the next icon

                        ; If we get here then the Docking Computer icon was
                        ; chosen

 LDX QQ12               ; If QQ12 is non-zero then we are docked, so jump to
 BNE barb8              ; barb8 to move on to the next icon as we can't engage
                        ; the docking computer if we aren't in space

 LDA auto               ; If the docking computer is already activated, jump
 BNE barb5              ; to barb5 to skip the docking fee calculations and
                        ; disable the docking computer (so the icon bar button
                        ; toggles it on and off)

 LDA SSPR               ; If we are not inside the space station safe zone, jump
 BEQ barb8              ; to barb8 to move on to the next icon as we can't
                        ; engage the docking computer if we aren't in the safe
                        ; zone

                        ; We now deduct a docking fee of 5.0 credits for using
                        ; the docking computer

 LDA DKCMP              ; If we have a docking computer fitted (DKCMP is
 ORA chargeDockingFee   ; non-zero) or we have already been charged a docking
 BNE barb4              ; fee (chargeDockingFee is non-zero), then jump to
                        ; barb4 to engage the docking computer without charging
                        ; a docking fee

                        ; Otherwise we do not have a docking computer fitted
                        ; or we have not yet been charged a docking fee, so
                        ; now we charge the docking fee

 LDY #0                 ; Set (Y X) = 50, so the docking fee is 5.0 credits
 LDX #50

 JSR LCASH              ; Subtract (Y X) cash from the cash pot, but only if
                        ; we have enough cash

 BCS barb3              ; If the C flag is set then we did have enough cash for
                        ; the transaction, so jump to barb3 to skip the
                        ; following instruction

                        ; If we get here then we don't have enough cash for the
                        ; docking fee, so make a beep and return from the
                        ; subroutine without engaging the docking computer

 JMP BOOP               ; Call the BOOP routine to make a long, low beep, and
                        ; return from the subroutine using a tail call

.barb3

 DEC chargeDockingFee   ; Set chargeDockingFee to $FF so we don't charge another
                        ; docking fee

 LDA #0                 ; Pring control code 0 (current amount of cash and
 JSR MESS               ; newline) as an in-flight message, to show our balance
                        ; after the docking fee has been paid

.barb4

 LDA #1                 ; Set A = 1 to pass to the ChooseMusic routine to play
                        ; the docking music (The Blue Danube)

 JSR WaitForNMI         ; Wait until the next NMI interrupt has passed (i.e. the
                        ; next VBlank)

 JSR ChooseMusic_b6     ; Select and play the docking music (The Blue Danube)

 LDA #$FF               ; Set A = $FF to set as the value of auto below, so the
                        ; docking comuter is flagged as being enabled

 BNE barb6              ; Jump to barb6 to store A in auto (this BNE is
                        ; effectively a JMP as A is never zero)

.barb5

                        ; If we get here then we need to turn off the docking
                        ; computer

 JSR ResetMusicAfterNMI ; Wait for the next NMI before resetting the current
                        ; tune to 0 (no tune) and stopping the docking music

 LDA #0                 ; Set A = 0 to set as the value of auto below, so the
                        ; docking comuter is flagged as being disabled

.barb6

 STA auto               ; Set auto to the value in A, to disable or enable the
                        ; docking computer as required

 LDA QQ11               ; If this is the space view, jump to barb7 to return
 BEQ barb7              ; from the subroutine

 JSR CLYNS              ; Clear the bottom two text rows of the upper screen,
                        ; and move the text cursor to column 1 on row 21, i.e.
                        ; the start of the top row of the two bottom rows

 JSR DrawScreenInNMI    ; Configure the NMI handler to draw the screen, so the
                        ; screen gets updated

.barb7

 RTS                    ; Return from the subroutine

.barb8

 JSR CheckForPause      ; If the Start button has been pressed then process the
                        ; pause menu and set the C flag, otherwise clear it

 CMP #21                ; If the "Front space view" icon was not chosen, jump to
 BNE barb11             ; barb11 to move on to the next icon

                        ; If we get here then the "Front space view" icon was
                        ; chosen

 LDA QQ12               ; If QQ12 is zero then we are not docked and in space,
 BPL barb9              ; so jump to barb9 to process the "Front space view"
                        ; icon

 RTS                    ; Otherwise the icon does nothing, so return from the
                        ; subroutine

.barb9

                        ; If we get here then the "Front space view" icon was
                        ; chosen and we are in space

 LDA #0                 ; Set A = 0 to use as the view number if we jump to
                        ; barb10 to show the front space view (i.e. view 0)

 LDX QQ11               ; If this is not the space view, jump to barb10 to show
 BNE barb10             ; the front space view

 LDA VIEW               ; Otherwise add 1 to the view number in VIEW and wrap it
 CLC                    ; round using mod 4, so VIEW goes from 0 to 3 and back
 ADC #1                 ; to 0 again (i.e. front, rear, left, right and back to
 AND #3                 ; front again)

.barb10

 TAX                    ; Set X to the view number to show

 JMP LOOK1              ; Jump to LOOK1 to switch to view X (front, rear, left
                        ; or right), returning from the subroutine using a tail
                        ; call

.barb11

 BIT QQ12               ; If bit 7 of QQ12 is clear (i.e. we are not docked, but
 BPL LABEL_3            ; in space), jump to LABEL_3 to skip the following
                        ; checks for the save commander file key press

 CMP #5                 ; If the Equip Ship icon was chosen, jump to TT219 to
 BNE P%+5               ; show the Equip Ship screen, returning from the
 JMP EQSHP              ; subroutine using a tail call

 CMP #6                 ; If the Save and Load icon was chosen, jump to SVE to
 BNE LABEL_3            ; show the Save and Load screen, returning from the
 JMP SVE_b6             ; subroutine using a tail call

.LABEL_3

 CMP #22                ; If the Hyperspace icon was chosen, jump to hyp to do
 BNE P%+5               ; a hyperspace jump (if we are in space), returning from
 JMP hyp                ; the subroutine using a tail call

 CMP #41                ; If the Galactic Hyperspace icon was chosen, jump to
 BNE P%+5               ; GalacticHyperdrive to dop a galactic hyperspacew jump,
 JMP GalacticHyperdrive ; returning from the subroutine using a tail call

 CMP #39                ; If the "Search for system" icon was not chosen, jump
 BNE HME1               ; to HME1 to move on to the next icon

 LDA QQ22+1             ; Fetch QQ22+1, which contains the number that's shown
                        ; on-screen during hyperspace countdown

 BNE t95                ; If it is non-zero, return from the subroutine (as t95
                        ; contains an RTS), as there is a countdown in progress

 LDA QQ11               ; If the view in QQ11 is not %0000110x (i.e. 12 or 13,
 AND #%00001110         ; which are the Short-range Chart and Long-range Chart),
 CMP #%00001100         ; jump to t95 to return from the subroutine (as t95
 BNE t95                ; contains an RTS)

 JMP HME2               ; Jump to HME2 to let us search for a system, returning
                        ; from the subroutine using a tail call

.HME1

 STA T1                 ; Store A (the key that's been pressed) in T1

 LDA QQ11               ; If the view in QQ11 is not %0000110x (i.e. 12 or 13,
 AND #%00001110         ; which are the Short-range Chart and Long-range Chart),
 CMP #%00001100         ; jump to TT107 to skip the following and move on to
 BNE TT107              ; updating the hyperspace

 LDA QQ22+1             ; If the on-screen hyperspace counter is non-zero,
 BNE TT107              ; then we are already counting down, so jump to TT107
                        ; to skip the following

 LDA T1                 ; Restore the original value of A (the key that's been
                        ; pressed) from T1

 CMP #38                ; If the "Return pointer to current system" icon was not
 BNE ee2                ; chosen, jump to ee2 to skip the following

 JSR ping               ; Set the target system to the current system (which
                        ; will move the location in (QQ9, QQ10) to the current
                        ; home system

.ReturnFromSearch

 ASL selectedSystemFlag ; Clear bit 7 of selectedSystemFlag to indicate that
 LSR selectedSystemFlag ; there is no currently selected system, so the call to
                        ; SetSelectedSystem selects the system in (QQ9, QQ10)

 JMP SetSelectedSystem  ; Jump to SetSelectedSystem to update the message on
                        ; the chart that shows the current system, returning
                        ; from the subroutine using a tail call

.ee2

 JSR TT16               ; Call TT16 to move the crosshairs by the amount in X
                        ; and Y, which were passed to this subroutine as
                        ; arguments

.TT107

 LDA QQ22+1             ; If the on-screen hyperspace counter is zero, return
 BEQ t95                ; from the subroutine (as t95 contains an RTS), as we
                        ; are not currently counting down to a hyperspace jump

 DEC QQ22               ; Decrement the internal hyperspace counter

 BNE t95                ; If the internal hyperspace counter is still non-zero,
                        ; then we are still counting down, so return from the
                        ; subroutine (as t95 contains an RTS)

                        ; If we get here then the internal hyperspace counter
                        ; has just reached zero and it wasn't zero before, so
                        ; we need to reduce the on-screen counter and update
                        ; the screen. We do this by first printing the next
                        ; number in the countdown sequence, and then printing
                        ; the old number, which will erase the old number
                        ; and display the new one because printing uses EOR
                        ; logic

 LDA #5                 ; Reset the internal hyperspace counter to 5
 STA QQ22

 DEC QQ22+1             ; Decrement the on-screen hyperspace countdown

 BEQ barb12             ; If the countdown is zero, jump to barb12 to do the
                        ; jump

 LDA #250               ; Print in-flight token 250, which is the hyperspace
 JMP MESS               ; countdown, and return from the subroutine using a
                        ; tail call

.barb12

 JMP TT18               ; The countdown has finished, so jump to TT18 to do a
                        ; hyperspace jump, returning from the subroutine using
                        ; a tail call

.t95

 RTS                    ; Return from the subroutine

; ******************************************************************************
;
;       Name: BAD
;       Type: Subroutine
;   Category: Status
;    Summary: Calculate how bad we have been
;
; ------------------------------------------------------------------------------
;
; Work out how bad we are from the amount of contraband in our hold. The
; formula is:
;
;   (slaves + narcotics) * 2 + firearms
;
; so slaves and narcotics are twice as illegal as firearms. The value in FIST
; (our legal status) is set to at least this value whenever we launch from a
; space station, and a FIST of 50 or more gives us fugitive status, so leaving a
; station carrying 25 tonnes of slaves/narcotics, or 50 tonnes of firearms
; across multiple trips, is enough to make us a fugitive.
;
; Returns:
;
;   A                   A value that determines how bad we are from the amount
;                       of contraband in our hold
;
; ******************************************************************************

.BAD

 LDA QQ20+3             ; Set A to the number of tonnes of slaves in the hold

 CLC                    ; Clear the C flag so we can do addition without the
                        ; C flag affecting the result

 ADC QQ20+6             ; Add the number of tonnes of narcotics in the hold

 ASL A                  ; Double the result and add the number of tonnes of
 ADC QQ20+10            ; firearms in the hold

 RTS                    ; Return from the subroutine

; ******************************************************************************
;
;       Name: FAROF
;       Type: Subroutine
;   Category: Maths (Geometry)
;    Summary: Compare x_hi, y_hi and z_hi with 224
;
; ------------------------------------------------------------------------------
;
; Compare x_hi, y_hi and z_hi with 224, and set the C flag if all three <= 224,
; otherwise clear the C flag.
;
; This routine does a similar job to the routine of the same name in the BBC
; Master version of Elite, but the code is significantly different.
;
; Returns:
;
;   C flag              Set if x_hi <= 224 and y_hi <= 224 and z_hi <= 224
;
;                       Clear otherwise (i.e. if any one of them are bigger than
;                       224)
;
; ******************************************************************************

.FAROF

 LDA INWK+2             ; If any of x_sign, y_sign or z_sign are non-zero
 ORA INWK+5             ; (ignoring the sign in bit 7), then jump to faro2 to
 ORA INWK+8             ; return the C flag clear, to indicate that one of x, y
 ASL A                  ; and z is greater that 224
 BNE faro2

 LDA #224               ; If x_hi > 224, jump to faro1 to return the C flag
 CMP INWK+1             ; clear
 BCC faro1

 CMP INWK+4             ; If y_hi > 224, jump to faro1 to return the C flag
 BCC faro1              ; clear

 CMP INWK+7             ; If z_hi > 224, clear the C flag, otherwise set it

.faro1

                        ; By this point the C flag is clear if any of x_hi, y_hi
                        ; or z_hi are greater than 224, otherwise all three are
                        ; less than or equal to 224 and the C flag is set

 RTS                    ; Return from the subroutine

.faro2

 CLC                    ; Clear the C flag to indicate that at least one of the
                        ; axes is greater than 224

 RTS                    ; Return from the subroutine

; ******************************************************************************
;
;       Name: MAS4
;       Type: Subroutine
;   Category: Maths (Geometry)
;    Summary: Calculate a cap on the maximum distance to a ship
;
; ------------------------------------------------------------------------------
;
; Logical OR the value in A with the high bytes of the ship's position (x_hi,
; y_hi and z_hi).
;
; Returns:
;
;   A                   A OR x_hi OR y_hi OR z_hi
;
; ******************************************************************************

.MAS4

 ORA INWK+1             ; OR A with x_hi, y_hi and z_hi
 ORA INWK+4
 ORA INWK+7

 RTS                    ; Return from the subroutine

; ******************************************************************************
;
;       Name: CheckForPause
;       Type: Subroutine
;   Category: Icon bar
;    Summary: Pause the game if the pause button (Start) is pressed
;
; ------------------------------------------------------------------------------
;
; Arguments:
;
;   A                   The button number to check to see if it is the pause
;                       button (a value of 80 indicates the pause button)
;
; Returns:
;
;   C flag              The status of the pause button:
;
;                         * Clear if the pause button is not being pressed
;
;                         * Set if the pause button is being pressed, in which
;                           case we return from the subroutine after pausing the
;                           the game, processing any choices from the icon bar,
;                           and unpausing the game when Start is pressed again
;
; Other entry points:
;
;   CheckForPause-3     Set A to the number of the icon bar button in
;                       iconBarChoice so we check whether the pause button is
;                       being pressed
;
; ******************************************************************************

 LDA iconBarChoice      ; Set A to the number of the icon bar button that has
                        ; been chosen from the icon bar (for when this routine
                        ; is called via the CheckForPause-3 entry point)

.CheckForPause

 CMP #80                ; If iconBarChoice = 80 then the Start button has been
 BNE cpse1              ; pressed to pause the game, so if this is not the case,
                        ; jump to cpse1 to return from the subroutine with the
                        ; C flag clear and without pausing

 LDA #0                 ; Set iconBarChoice = 0 to clear the pause button press
 STA iconBarChoice      ; so we don't simply re-enter the pause menu when we
                        ; resume 

 JSR PauseGame_b6       ; Pause the game and process choices from the pause menu
                        ; until the game is unpaused by another press of Start

 SEC                    ; Set the C flag to indicate that the game was paused

 RTS                    ; Return from the subroutine

.cpse1

 CLC                    ; Clear the C flag to indicate that the game was not
                        ; paused

 RTS                    ; Return from the subroutine

; ******************************************************************************
;
;       Name: DEATH
;       Type: Subroutine
;   Category: Start and end
;    Summary: Display the death screen
;
; ------------------------------------------------------------------------------
;
; We have been killed, so display the chaos of our destruction above a "GAME
; OVER" sign, and clean up the mess ready for the next attempt.
;
; ******************************************************************************

.DEATH

 JSR ResetMusicAfterNMI ; Wait for the next NMI before resetting the current
                        ; tune to 0 (no tune) and stopping the music

 JSR EXNO3              ; Make the sound of us dying

 JSR RES2               ; Reset a number of flight variables and workspaces

 ASL DELTA              ; Divide our speed in DELTA by 4
 ASL DELTA

 LDA #0                 ; Set the tile number for the left edge of the box to
 STA boxEdge1           ; the blank tile, so the box around the space view
                        ; disappears

 STA boxEdge2           ; Set the tile number for the right edge of the box to
                        ; the blank tile, so the box around the space view
                        ; disappears

 STA autoPlayDemo       ; Disable auto-play by setting autoPlayDemo to zero, in
                        ; case we die during the auto-play combat demo

 LDA #$C4               ; Clear the screen and and set the view type in QQ11 to
 JSR TT66               ; $95 (Game Over screen)

 JSR ClearDashEdge_b6   ; Clear the right edge of the dashboard

 JSR CopyNameBuffer0To1 ; Copy the contents of nametable buffer 0 to nametable
                        ; buffer and tell the NMI handler to send pattern
                        ; entries up to the first free tile

 JSR SetScreenForUpdate ; Get the screen ready for updating by hiding all
                        ; sprites, after fading the screen to black if we are
                        ; changing view

 LDA #0                 ; Set showIconBarPointer to 0 to indicate that we should
 STA showIconBarPointer ; hide the icon bar pointer

 LDA #$C4               ; Configure the PPU for view type $C4 (Game Over screen)
 JSR SendViewToPPU_b3

 LDA #$00               ; Set the view type in QQ11 to $00 (Space view with no
 STA QQ11               ; font loaded)

 STA QQ11a              ; Set the old view type in QQ11a to $00 (Space view with
                        ; no fonts loaded)

 LDA firstFreeTile      ; Tell the NMI handler to send pattern entries from the
 STA firstPatternTile   ; first free tile onwards, so we don't waste time
                        ; resending the static tiles we have already sent

 LDA #116               ; Tell the NMI handler to only clear nametable entries
 STA maxNameTileToClear ; up to tile 116 * 8 = 800 (i.e. up to the end of tile
                        ; row 28)

 LDX #8                 ; Tell the NMI handler to send nametable entries from
 STX firstNametableTile ; tile 8 * 8 = 64 onwards (i.e. from the start of tile
                        ; row 2)

 LDA #104               ; Set the screen height variables for a screen height of
 JSR SetScreenHeight    ; 208 (i.e. 2 * 104)

                        ; Next we fill the scannerNumber table with non-zero
                        ; entries so when we spawn ships for the death screen,
                        ; they don't appear on the scanner because the scanner
                        ; number table doesn't have any free slots

 LDY #8                 ; Set an index in Y to work through the eight entries
                        ; in the scannerNumber table

 LDA #1                 ; Set A = 1 to use as the value for every ship in the
                        ; scannerNumber table, which is non-zero so the NWSHP
                        ; routine will skip the scanner configuration for any
                        ; ships we spawn

.deaf1

 STA scannerNumber,Y    ; Set the Y-th scannerNumber entry to 1

 DEY                    ; Decrement the index in Y

 BNE deaf1              ; Loop back until we have set entries 1 to 8 in the
                        ; table to 1, so nothing spawns on the scanner

 JSR nWq                ; Create a cloud of stardust containing the correct
                        ; number of dust particles (i.e. NOSTM of them)

                        ; We now give our ship a random amount of roll by
                        ; setting all the various alpha angle variables

 JSR DORND              ; Set A and X to random numbers

 AND #%10000111         ; Set the roll angle in ALPHA to the random number,
 STA ALPHA              ; reduced to the range 0 to 7, and with a random sign

 AND #7                 ; Set the magnitude of roll angle alpha in ALP1 to the
 STA ALP1               ; same value, but with the sign bit cleared (so ALP1
                        ; contains the magnitude of the roll)

 LDA ALPHA              ; Set the sign of the roll angle alpha in ALP2 to the
 AND #%10000000         ; sign of ALPHA (so ALP2 contains the sign of the roll)
 STA ALP2

 EOR #%10000000         ; Set the sign of the roll angle alpha in ALP2+1 to the
 STA ALP2+1             ; flipped sign of ALPHA (so ALP2 contains the flipped
                        ; sign of the roll)

.D1

 JSR Ze                 ; Call Ze to initialise INWK to a potentially hostile
                        ; ship, and set A and X to random values

 LSR A                  ; Set A = A / 4, so A is now between 0 and 63, and
 LSR A                  ; store in byte #0 (x_lo)
 STA INWK

 LDY #$00               ; Set the view type in QQ11 to $00 (Space view with no
 STY QQ11               ; font loaded)

 STY INWK+1             ; Set the following to 0: x_hi, y_hi, z_hi and the AI
 STY INWK+4             ; flag (no AI or E.C.M. and not hostile)
 STY INWK+7
 STY INWK+32

 DEY                    ; Set Y = 255

 STY MCNT               ; Reset the main loop counter to 255, so all timer-based
                        ; calls will be stopped

 EOR #%00101010         ; Flip bits 1, 3 and 5 in A (x_lo) to get another number
 STA INWK+3             ; between 48 and 63, and store in byte #3 (y_lo)

 ORA #%01010000         ; Set bits 4 and 6 of A to bump it up to between 112 and
 STA INWK+6             ; 127, and store in byte #6 (z_lo)

 TXA                    ; Set A to the random number in X and keep bits 0-3 and
 AND #%10001111         ; the sign in bit 7 to get a number between -15 and +15,
 STA INWK+29            ; and store in byte #29 (roll counter) to give our ship
                        ; a gentle roll with damping

 LDY #64                ; Set the laser count to 64 to act as a counter in the
 STY LASCT              ; D2 loop below, so this setting determines how long the
                        ; death animation lasts (it's 64 * 2 iterations of the
                        ; main flight loop)

 SEC                    ; Set the C flag

 ROR A                  ; This sets A to a number between 0 and +7, which we
 AND #%10000111         ; store in byte #30 (the pitch counter) to give our ship
 STA INWK+30            ; a very gentle downwards pitch with damping

 LDX #OIL               ; Set X to #OIL, the ship type for a cargo canister

 LDA XX21-1+2*PLT       ; Fetch the byte from location XX21 - 1 + 2 * PLT, which
                        ; equates to XX21 + 7 (the high byte of the address of
                        ; SHIP_PLATE), which seems a bit odd. It might make more
                        ; sense to do LDA (XX21-2+2*PLT) as this would fetch the
                        ; first byte of the alloy plate's blueprint (which
                        ; determines what happens when alloys are destroyed),
                        ; but there aren't any brackets, so instead this always
                        ; returns $D0, which is never zero, so the following
                        ; BEQ is never true. (If the brackets were there, then
                        ; we could stop plates from spawning on death by setting
                        ; byte #0 of the blueprint to 0... but then scooping
                        ; plates wouldn't give us alloys, so who knows what this
                        ; is all about?)

 BEQ D3                 ; If A = 0, jump to D3 to skip the following instruction

 BCC D3                 ; If the C flag is clear, which will be random following
                        ; the above call to Ze, jump to D3 to skip the following
                        ; instruction

 DEX                    ; Decrement X, which sets it to #PLT, the ship type for
                        ; an alloy plate

.D3

 JSR fq1                ; Call fq1 with X set to #OIL or #PLT, which adds a new
                        ; cargo canister or alloy plate to our local bubble of
                        ; universe and points it away from us with double DELTA
                        ; speed (i.e. 6, as DELTA was set to 3 by the call to
                        ; RES2 above). INF is set to point to the new arrival's
                        ; ship data block in K%

 JSR DORND              ; Set A and X to random numbers and extract bit 7 from A
 AND #%10000000

 LDY #31                ; Store this in byte #31 of the ship's data block, so it
 STA (INF),Y            ; has a 50% chance of marking our new arrival as being
                        ; killed (so it will explode)

 LDA FRIN+6             ; The call we made to RES2 before we entered the loop at
 BEQ D1                 ; D1 will have reset all the ship slots at FRIN, so this
                        ; checks to see if the seventh slot is empty, and if it
                        ; is we loop back to D1 to add another canister, until
                        ; we have added seven of them

 LDA #8                 ; Set our speed in DELTA to 8, so the camera moves
 STA DELTA              ; forward slowly

 LDA #12                ; Set the text row for in-flight messages in the space
 STA messYC             ; view to row 12

 LDA #146               ; Print recursive token 146 ("{all caps}GAME OVER") in
 LDY #120               ; the middle of the screen and leave it there for 120
 JSR PrintMessage       ; ticks of the DLY counter

 JSR HideMostSprites    ; Hide all sprites except for sprite 0 and the icon bar
                        ; pointer

 LDA #30                ; Set the laser count to 30 to act as a counter in the
 STA LASCT              ; D2 loop below, so this setting determines how long the
                        ; death animation lasts

.D2

 JSR FlipDrawingPlane   ; Flip the drawing bitplane so we draw into the bitplane
                        ; that isn't visible on-screen

 JSR FlightLoop4To16    ; Display in-flight messages, call parts 4 to 12 of the
                        ; main flight loop for each ship slot, and finish off
                        ; with parts 13 to 16 of the main flight loop

 JSR ClearDashEdge_b6   ; Clear the right edge of the dashboard

 LDA #%11001100         ; Set the bitplane flags for the drawing bitplane to the
 JSR SetDrawPlaneFlags  ; following:
                        ;
                        ;   * Bit 2 set   = send tiles up to end of the buffer
                        ;   * Bit 3 set   = clear buffers after sending data
                        ;   * Bit 4 clear = we've not started sending data yet
                        ;   * Bit 5 clear = we have not yet sent all the data
                        ;   * Bit 6 set   = send both pattern and nametable data
                        ;   * Bit 7 set   = send data to the PPU
                        ;
                        ; Bits 0 and 1 are ignored and are always clear
                        ;
                        ; This configures the NMI to send nametable and pattern
                        ; data for the drawing bitplane to the PPU during VBlank

 DEC LASCT              ; Decrement the counter in LASCT, which we set above,
                        ; so for each loop around D2, we decrement LASCT by 5
                        ; (the main loop decrements it by 4, and this one makes
                        ; it 5)

 BNE D2                 ; Loop back to call the main flight loop again, until we
                        ; have called it 127 times

 JMP DEATH2             ; Jump to DEATH2 to reset and restart the game

; ******************************************************************************
;
;       Name: ShowStartScreen
;       Type: Subroutine
;   Category: Start and end
;    Summary: Show the start screen and start the game
;
; ******************************************************************************

.ShowStartScreen

 LDA #$FF               ; Set soundVar07 = $FF ???
 STA soundVar07

 LDA #$80               ; Set soundVar08 = $80 ???
 STA soundVar08

 LDA #$1B               ; Set soundVar09 = $1B ???
 STA soundVar09

 LDA #$34               ; Set soundVar0A = $34 ???
 STA soundVar0A

 JSR ResetMusic         ; Reset the current tune to 0 and stop the music

 JSR JAMESON_b6         ; Copy the default "JAMESON" commander to the buffer at
                        ; currentSaveSlot (though this isn't actually used
                        ; anywhere)

 JSR ResetOptions       ; Reset the game options to their default values

 LDA #1                 ; Set the font style to print in the normal font
 STA fontStyle

 LDX #$FF               ; Set the old view type in QQ11a to $FF (Segue screen
 STX QQ11a              ; from Title screen to Demo)

 TXS                    ; Set the stack pointer to $01FF, which is the standard
                        ; location for the 6502 stack, so this instruction
                        ; effectively resets the stack

 JSR RESET              ; Call RESET to initialise most of the game variables

 JSR ChooseLanguage_b6  ; Show the Start screen and process the language choice

                        ; Fall through into DEATH2 to show the title screen and
                        ; start the game

; ******************************************************************************
;
;       Name: DEATH2
;       Type: Subroutine
;   Category: Start and end
;    Summary: Reset most of the game and restart from the title screen
;
; ------------------------------------------------------------------------------
;
; This routine is called following death, and when the game is quit via the
; pause menu.
;
; This routine does a similar job to the routine of the same name in the BBC
; Master version of Elite, but the code is significantly different.
;
; ******************************************************************************

.DEATH2

 LDX #$FF               ; Set the stack pointer to $01FF, which is the standard
 TXS                    ; location for the 6502 stack, so this instruction
                        ; effectively resets the stack

 INX                    ; Set chartToShow = 0 so the chart button on the icon
 STX chartToShow        ; bar shows the Short-range Chart when chosen

 JSR RES2               ; Reset a number of flight variables and workspaces

 LDA #5                 ; Set the icon par pointer to button 5 (which is the
 JSR SetIconBarPointer  ; sixth button of 12, just before the halfway point)

 JSR U%                 ; Call U% to clear the key logger

 JSR DrawTitleScreen    ; Draw the title screen with the rotating ships,
                        ; returning when a key is pressed

 LDA controller1Select  ; If Select, Start, A and B are all pressed at the same
 AND controller1Start   ; time on controller 1, jump to dead2 to skip the demo
 AND controller1A       ; and show the credits scrolltext instead
 AND controller1B
 BNE dead2

 LDA controller1Select  ; If Select is pressed on either controller, jump to
 ORA controller2Select  ; dead3 to skip the demo and start the game straight
 BNE dead3              ; away

                        ; If we get here then we start the combat demo

 LDA #0                 ; Store 0 on the stack, so this can be retrieved below
 PHA                    ; to pass to ShowScrollText, so the demo gets run after
                        ; the scroll text is shown

 JSR BR1                ; Reset a number of variables, ready to start a new game

 LDA #$FF               ; Set the view type in QQ11 to $FF (Segue screen from
 STA QQ11               ; Title screen to Demo)

 LDA autoPlayDemo       ; If autoPlayDemo is zero then the demo is not being
 BEQ dead1              ; auto-played, so jump to dead1 to skip the following
                        ; instruction

 JSR SetupDemoUniverse  ; The demo is running and is being auto-played by the
                        ; computer, so call SetupDemoUniverse to set up the
                        ; local bubble for the demo

.dead1

 JSR WaitForNMI         ; Wait until the next NMI interrupt has passed (i.e. the
                        ; next VBlank)

 LDA #4                 ; Set the music to tune #4
 JSR ChooseMusic_b6

 LDA soundVar05         ; Set soundVar05 = soundVar05 + 6 ???
 CLC
 ADC #6
 STA soundVar05

 PLA                    ; Set A to the value of A that we put on the stack above
                        ; (i.e. set A = 0)

 JMP ShowScrollText_b6  ; Jump to ShowScrollText to show the scroll text and run
                        ; the demo, returning from the subroutine using a tail
                        ; call

.dead2

                        ; If we get here then we show the credits scrolltext

 JSR BR1                ; Reset a number of variables, ready to start a new game

 LDA #$FF               ; Set the view type in QQ11 to $FF (Segue screen from
 STA QQ11               ; Title screen to Demo)

 JSR WaitForNMI         ; Wait until the next NMI interrupt has passed (i.e. the
                        ; next VBlank)

 LDA #4                 ; Set the music to tune #4
 JSR ChooseMusic_b6

 LDA #2                 ; Set A = 2 to pass to ShowScrollText, so the credits
                        ; scroll text is shown instead of the demo introduction,
                        ; and to skip the demo after the scroll text

 JMP ShowScrollText_b6  ; Jump to ShowScrollText to show the scroll text and
                        ; skip the demo, returning from the subroutine using a
                        ; tail call

.dead3

                        ; If we get here then we start the game without playing
                        ; the demo

 JSR FadeToBlack_b3     ; Fade the screen to black over the next four VBlanks

                        ; Fall through into StartGame to reset the stack and go
                        ; to the docking bay (i.e. show the Status Mode screen)

; ******************************************************************************
;
;       Name: StartGame
;       Type: Subroutine
;   Category: Start and end
;    Summary: Reset the stack and game variables, and start the game by going to
;             the docking bay
;
; ******************************************************************************

.StartGame

 LDX #$FF               ; Set the stack pointer to $01FF, which is the standard
 TXS                    ; location for the 6502 stack, so this instruction
                        ; effectively resets the stack

 JSR BR1                ; Reset a number of variables, ready to start a new game

                        ; Fall through into the BAY routine to go to the docking
                        ; bay (i.e. show the Status Mode screen)

; ******************************************************************************
;
;       Name: BAY
;       Type: Subroutine
;   Category: Status
;    Summary: Go to the docking bay (i.e. show the Status Mode screen)
;
; ------------------------------------------------------------------------------
;
; We end up here after the start-up process (load commander etc.), as well as
; after a successful save, an escape pod launch, a successful docking, the end
; of a cargo sell, and various errors (such as not having enough cash, entering
; too many items when buying, trying to fit an item to your ship when you
; already have it, running out of cargo space, and so on).
;
; ******************************************************************************

.BAY

 JSR ClearScreen_b3     ; Clear the screen by zeroing patterns 66 to 255 in
                        ; both pattern buffer, and clearing both nametable
                        ; buffers to the background tile

 LDA #$FF               ; Set QQ12 = $FF (the docked flag) to indicate that we
 STA QQ12               ; are docked

 LDA #3                 ; Jump into the main loop at FRCE, setting the key
 JMP FRCE               ; that's "pressed" to the Status Mode icon bar button
                        ; so we show the Status Mode screen

; ******************************************************************************
;
;       Name: BR1
;       Type: Subroutine
;   Category: Start and end
;    Summary: Reset a number of variables, ready to start a new game
;
; ******************************************************************************

.BR1

 JSR SetupPPUForIconBar ; If the PPU has started drawing the icon bar, configure
                        ; the PPU to use nametable 0 and pattern table 0

 JSR ResetCommander_b6  ; Reset the current commander to the default "JAMESON"
                        ; commander

 JSR ResetMusicAfterNMI ; Wait for the next NMI before resetting the current
                        ; tune to 0 (no tune) and stopping the music

 JSR ping               ; Set the target system coordinates (QQ9, QQ10) to the
                        ; current system coordinates (QQ0, QQ1) we just loaded

 JSR TT111              ; Select the system closest to galactic coordinates
                        ; (QQ9, QQ10)

 JSR jmp                ; Set the current system to the selected system

 LDX #5                 ; We now want to copy the seeds for the selected system
                        ; in QQ15 into QQ2, where we store the seeds for the
                        ; current system, so set up a counter in X for copying
                        ; 6 bytes (for three 16-bit seeds)

                        ; The label below is called likeTT112 because this code
                        ; is almost identical to the TT112 loop in the hyp1
                        ; routine

.likeTT112

 LDA QQ15,X             ; Copy the X-th byte in QQ15 to the X-th byte in QQ2
 STA QQ2,X

 DEX                    ; Decrement the counter

 BPL likeTT112          ; Loop back to likeTT112 if we still have more bytes to
                        ; copy

 INX                    ; Set X = 0 (as we ended the above loop with X = $FF)

 STX EV                 ; Set EV, the extra vessels spawning counter, to 0, as
                        ; we are entering a new system with no extra vessels
                        ; spawned

 LDA QQ3                ; Set the current system's economy in QQ28 to the
 STA QQ28               ; selected system's economy from QQ3

 LDA QQ5                ; Set the current system's tech level in tek to the
 STA tek                ; selected system's economy from QQ5

 LDA QQ4                ; Set the current system's government in gov to the
 STA gov                ; selected system's government from QQ4

 RTS                    ; Return from the subroutine

; ******************************************************************************
;
;       Name: ChangeToView
;       Type: Subroutine
;   Category: Drawing the screen
;    Summary: ???
;
; ------------------------------------------------------------------------------
;
; Arguments:
;
;   A                   The type of the new view
;
; ******************************************************************************

.ChangeToView

 JSR TT66               ; Clear the screen and and set the view type in QQ11 to
                        ; the value of A

 JSR CopyNameBuffer0To1 ; Copy the contents of nametable buffer 0 to nametable
                        ; buffer and tell the NMI handler to send pattern
                        ; entries up to the first free tile

 JSR UpdateScreen       ; Update the screen by sending data to the PPU, either
                        ; immediately or during VBlank, depending on whether
                        ; the screen is visible

 LDA #$00               ; Set the view type in QQ11 to $00 (Space view with no
 STA QQ11               ; font loaded)

 STA QQ11a              ; Set the old view type in QQ11a to $00 (Space view with
                        ; no fonts loaded)

 STA showIconBarPointer ; Set showIconBarPointer to 0 to indicate that we should
                        ; hide the icon bar pointer

 LDA firstFreeTile      ; Tell the NMI handler to send pattern entries from the
 STA firstPatternTile   ; first free tile onwards, so we don't waste time
                        ; resending the static tiles we have already sent

 LDA #80                ; Tell the NMI handler to only clear nametable entries
 STA maxNameTileToClear ; up to tile 80 * 8 = 640 (i.e. up to the end of tile
                        ; row 19)

 LDX #8                 ; Tell the NMI handler to send nametable entries from
 STX firstNametableTile ; tile 8 * 8 = 64 onwards (i.e. from the start of tile
                        ; row 2)

 RTS                    ; Return from the subroutine

; ******************************************************************************
;
;       Name: TITLE
;       Type: Subroutine
;   Category: Start and end
;    Summary: Display a title screen with a rotating ship and prompt
;
; ------------------------------------------------------------------------------
;
; Display the title screen, with a selection of rotating ships.
;
; Arguments:
;
;   X                   The type of the ship to show (see variable XX21 for a
;                       list of ship types)
;
;   Y                   The distance to show the ship rotating, once it has
;                       finished moving towards us
;
; Returns:
;
;   C flag              If the A button, Start or Select was being pressed but
;                       has now been released, on either one of the controllers,
;                       then the C flag is set, otherwise it is clear
;
; ******************************************************************************

.TITLE

 STY distaway           ; Store the ship distance in distaway

 STX TYPE               ; Store the ship type in location TYPE

 JSR RESET              ; Reset our ship so we can use it for the rotating
                        ; title ship

 JSR U%                 ; Call U% to clear the key logger

 JSR SetupPPUForIconBar ; If the PPU has started drawing the icon bar, configure
                        ; the PPU to use nametable 0 and pattern table 0

 LDA #96                ; Set nosev_z hi = 96 (96 is the value of unity in the
 STA INWK+14            ; rotation vector)

 LDA #55                ; Set A = 55 as the distance that the ship starts at

 STA INWK+7             ; Set z_hi, the high byte of the ship's z-coordinate,
                        ; to 96, which is the distance at which the rotating
                        ; ship starts out before coming towards us

 LDX #127               ; Set roll counter = 127, so don't dampen the roll
 STX INWK+29

 STX INWK+30            ; Set pitch counter = 127, so don't dampen the pitch

 INX                    ; Set QQ17 to 128 (so bit 7 is set) to switch to
 STX QQ17               ; Sentence Case, with the next letter printing in upper
                        ; case

 LDA TYPE               ; Set up a new ship, using the ship type in TYPE
 JSR NWSHP

.awe

 JSR HideFromScanner_b1 ; Hide the ship from the scanner

 LDA #12                ; Set CNT2 = 12 as the outer loop counter for the loop
 STA CNT2               ; starting at TLL2

 LDA #5                 ; Set the main loop counter in MCNT to 5, to act as the
 STA MCNT               ; inner loop counter for the loop starting at TLL2

 LDY #0                 ; Set DELTA = 0 (i.e. ship speed = 0)
 STY DELTA

 LDA #$01               ; Clear the screen and and set the view type in QQ11 to
 JSR ChangeToView       ; $01 (Title screen)

 LDA #7                 ; Set YP = 7 to use as the outer loop counter for the loop
 STA YP                 ; starting at TLL2

.titl1

 LDA #25                ; Set XP = 25 to use as the inner loop counter for the
 STA XP                 ; loop starting at TLL2

.TLL2

 LDA INWK+7             ; If z_hi (the ship's distance) is 1, jump to TL1 to
 CMP #1                 ; skip the following decrement
 BEQ TL1

 DEC INWK+7             ; Decrement the ship's distance, to bring the ship
                        ; a bit closer to us

.TL1

 JSR titl5              ; Call titl5 below as a subroutine to rotate and move
                        ; the ship in space

 BCS titl3              ; If a button was been pressed during the ship drawing,
                        ; then the C flag sill be set, so jump to titl3 to
                        ; return from the subroutine with the C flag set to
                        ; indicate a button press

 DEC XP                 ; Decrement the inner loop counter in XP

 BNE TLL2               ; Loop back to keep the ship rotating, until the inner
                        ; loop counter is zero

 DEC YP                 ; Decrement the outer loop counter in YP

 BNE titl1              ; Loop back to keep the ship rotating, until the outer
                        ; loop counter is zero

.titl2

 LDA INWK+7             ; If z_hi (the ship's distance) is 55 or greater, jump
 CMP #55                ; to titl4 to return from the subroutine with the C flag
 BCS titl4              ; clear, as the ship has now come towards us and has
                        ; gone away again, all without any buttons being pressed

 INC INWK+7             ; Increment the ship's distance, to move the ship a bit
                        ; further away from us

 JSR titl5              ; Call titl5 below as a subroutine to rotate and move
                        ; the ship in space

 BCC titl2              ; If no button was pressed during the ship drawing, then
                        ; the C flag will be clear, so loop back to titl2 to
                        ; move the ship away from us

                        ; If a button was pressed, then the C flag will be set,
                        ; so we now return from the subroutine with the C flag
                        ; set

.titl3

 SEC                    ; Set the C flag to indicate that a button has been
                        ; pressed

 RTS                    ; Return from the subroutine

.titl4

 CLC                    ; Clear the C flag to indicate that a button has not
                        ; been pressed

 RTS                    ; Return from the subroutine

.titl5

                        ; We call this part of the code as a subroutine from
                        ; above

 JSR MV30               ; Call MV30 at the end of part 2 of MVEIT, so we move
                        ; the ship in space but without tidying the orientation
                        ; vectors or applying tactics (neither of which are
                        ; necessary on the title screen)

 LDX distaway           ; Set z_lo to the distance value we passed to the
 STX INWK+6             ; routine, so this is the closest the ship gets to us

 LDA MCNT               ; This has no effect - it is presumably left over from
 AND #3                 ; the other versions of Elite which only scan the
                        ; keyboard once every four loops, but that isn't the
                        ; case here as the result is not acted upon

 LDA #0                 ; Set x_lo = 0, so the ship remains in the screen centre
 STA INWK

 STA INWK+3             ; Set y_lo = 0, so the ship remains in the screen centre

 SETUP_PPU_FOR_ICON_BAR ; If the PPU has started drawing the icon bar, configure
                        ; the PPU to use nametable 0 and pattern table 0

 JSR DrawShipInBitplane ; Flip the drawing bitplane and draw the current ship in
                        ; the newly flipped bitplane

 INC MCNT               ; Increment the main loop counter

 LDA controller1A       ; If any of the A button, Start or Select are being
 ORA controller1Start   ; pressed on controller 1, jump to tite1 to check the
 ORA controller1Select  ; same buttons on controller 2, as these don't count as
 BMI tite1              ; a button press until they are released

 BNE tite3              ; If the result is non-zero, then at least one of the
                        ; A button, Start or Select were being pressed but have
                        ; now been released, so jump to tite3 to set the number
                        ; of pilots to one (as the buttons are being pressed on
                        ; controller 1), and return from the subroutine with
                        ; the C flag set, to indicate the button press

.tite1

 LDA controller2A       ; If any of the A button, Start or Select are being
 ORA controller2Start   ; pressed on controller 2, jump to tite2 to return from
 ORA controller2Select  ; the subroutine with the C flag clear, as these don't
 BMI tite2              ; count as a button press until they are released

 BNE tite4              ; If the result is non-zero, then at least one of the
                        ; A button, Start or Select were being pressed but have
                        ; now been released, so jump to tite4 to keep the number
                        ; of pilots to two (as the buttons are being pressed on
                        ; controller 2) to return from the subroutine with the
                        ; C flag set, to indicate the button press

.tite2

 CLC                    ; Clear the C flag to indicate that a button has not
                        ; been pressed

 RTS                    ; Return from the subroutine

.tite3

 LSR numberOfPilots     ; Set numberOfPilots = 0 to configure the game for one
                        ; pilot

.tite4

 SEC                    ; Set the C flag to indicate that a button has been
                        ; pressed

 RTS                    ; Return from the subroutine

; ******************************************************************************
;
;       Name: ZERO
;       Type: Subroutine
;   Category: Utility routines
;    Summary: Reset the local bubble of universe and ship status
;
; ------------------------------------------------------------------------------
;
; This resets the following workspaces to zero:
;
;   * WP workspace variables from FRIN to de, which include the ship slots for
;     the local bubble of universe, and various flight and ship status
;     variables, including the MANY block
;
; ******************************************************************************

.ZERO

 JSR SetupPPUForIconBar ; If the PPU has started drawing the icon bar, configure
                        ; the PPU to use nametable 0 and pattern table 0

 LDX #(de-FRIN+1)       ; We're going to zero the WP workspace variables from
                        ; FRIN to de, so set a counter in X for the correct
                        ; number of bytes

 LDA #0                 ; Set A = 0 so we can zero the variables

.ZEL

 STA FRIN-1,X           ; Zero byte X-1 of FRIN to de

 DEX                    ; Decrement the loop counter

 BNE ZEL                ; Loop back to zero the next variable until we have done
                        ; them all from FRIN to FRIN+42

 LDX #NTY               ; We're now going to zero the NTY bytes in the MANY
                        ; block, so set a counter in X for the correct number of
                        ; bytes

.ZEL2

 STA MANY,X             ; Zero the X-th byte of MANY

 DEX                    ; Decrement the loop counter

 BPL ZEL2               ; Loop back to zero the next variable until we have done
                        ; them all from MANY to MANY+33

 JSR SetupPPUForIconBar ; If the PPU has started drawing the icon bar, configure
                        ; the PPU to use nametable 0 and pattern table 0

 RTS                    ; Return from the subroutine

; ******************************************************************************
;
;       Name: U%
;       Type: Subroutine
;   Category: Controllers
;    Summary: Clear the key logger
;
; ------------------------------------------------------------------------------
;
; Returns:
;
;   A                   A is set to 0
;
; ******************************************************************************

.U%

 LDX #6                 ; We want to clear the 6 key logger locations from
                        ; KY1 to KY6, so set a counter in X

 LDA #0                 ; Set A to 0, as this means "key not pressed" in the
                        ; key logger at KL

 STA iconBarKeyPress    ; Reset the key logger entry for the icon bar button
                        ; choice

.DKL3

 STA KL,X               ; Store 0 in the X-th byte of the key logger

 DEX                    ; Decrement the counter

 BPL DKL3               ; Loop back for the next key, until we have cleared from
                        ; KL to KL+6 (i.e. KY1 through KY6)

 RTS                    ; Return from the subroutine

; ******************************************************************************
;
;       Name: MAS1
;       Type: Subroutine
;   Category: Maths (Geometry)
;    Summary: Add an orientation vector coordinate to an INWK coordinate
;  Deep dive: The space station safe zone
;
; ------------------------------------------------------------------------------
;
; Add a doubled nosev vector coordinate, e.g. (nosev_y_hi nosev_y_lo) * 2, to
; an INWK coordinate, e.g. (x_sign x_hi x_lo), storing the result in the INWK
; coordinate. The axes used in each side of the addition are specified by the
; arguments X and Y.
;
; In the comments below, we document the routine as if we are doing the
; following, i.e. if X = 0 and Y = 11:
;
;   (x_sign x_hi x_lo) = (x_sign x_hi x_lo) + (nosev_y_hi nosev_y_lo) * 2
;
; as that way the variable names in the comments contain "x" and "y" to match
; the registers that specify the vector axis to use.
;
; Arguments:
;
;   X                   The coordinate to add, as follows:
;
;                         * If X = 0, add (x_sign x_hi x_lo)
;                         * If X = 3, add (y_sign y_hi y_lo)
;                         * If X = 6, add (z_sign z_hi z_lo)
;
;   Y                   The vector to add, as follows:
;
;                         * If Y = 9,  add (nosev_x_hi nosev_x_lo)
;                         * If Y = 11, add (nosev_y_hi nosev_y_lo)
;                         * If Y = 13, add (nosev_z_hi nosev_z_lo)
;
; Returns:
;
;   A                   The highest byte of the result with the sign cleared
;                       (e.g. |x_sign| when X = 0, etc.)
;
; Other entry points:
;
;   MA9                 Contains an RTS
;
; ******************************************************************************

.MAS1

 LDA INWK,Y             ; Set K(2 1) = (nosev_y_hi nosev_y_lo) * 2
 ASL A
 STA K+1
 LDA INWK+1,Y
 ROL A
 STA K+2

 LDA #0                 ; Set K+3 bit 7 to the C flag, so the sign bit of the
 ROR A                  ; above result goes into K+3
 STA K+3

 JSR MVT3               ; Add (x_sign x_hi x_lo) to K(3 2 1)

 STA INWK+2,X           ; Store the sign of the result in x_sign

 LDY K+1                ; Store K(2 1) in (x_hi x_lo)
 STY INWK,X
 LDY K+2
 STY INWK+1,X

 AND #%01111111         ; Set A to the sign byte with the sign cleared,
                        ; i.e. |x_sign| when X = 0

.MA9

 RTS                    ; Return from the subroutine

; ******************************************************************************
;
;       Name: MAS2
;       Type: Subroutine
;   Category: Maths (Geometry)
;
; ------------------------------------------------------------------------------
;
; Given a value in Y that points to the start of a ship data block as an offset
; from K%, calculate the following:
;
;   A = A OR x_sign OR y_sign OR z_sign
;
; and clear the sign bit of the result. The K% workspace contains the ship data
; blocks, so the offset in Y must be 0 or a multiple of NI% (as each block in
; K% contains NI% bytes).
;
; The result effectively contains a maximum cap of the three values (though it
; might not be one of the three input values - it's just guaranteed to be
; larger than all of them).
;
; If Y = 0 and A = 0, then this calculates the maximum cap of the highest byte
; containing the distance to the planet, as K%+2 = x_sign, K%+5 = y_sign and
; K%+8 = z_sign (the first slot in the K% workspace represents the planet).
;
; Arguments:
;
;   Y                   The offset from K% for the start of the ship data block
;                       to use
;
; Returns:
;
;   A                   A OR K%+2+Y OR K%+5+Y OR K%+8+Y, with bit 7 cleared
;
; Other entry points:
;
;   m                   Do not include A in the calculation
;
; ******************************************************************************

.m

 LDA #0                 ; Set A = 0 and fall through into MAS2 to calculate the
                        ; OR of the three bytes at K%+2+Y, K%+5+Y and K%+8+Y

.MAS2

 ORA K%+2,Y             ; Set A = A OR x_sign OR y_sign OR z_sign
 ORA K%+5,Y
 ORA K%+8,Y

 AND #%01111111         ; Clear bit 7 in A

 RTS                    ; Return from the subroutine

; ******************************************************************************
;
;       Name: MAS3
;       Type: Subroutine
;   Category: Maths (Arithmetic)
;    Summary: Calculate A = x_hi^2 + y_hi^2 + z_hi^2 in the K% block
;
; ------------------------------------------------------------------------------
;
; Given a value in Y that points to the start of a ship data block as an offset
; from K%, calculate the following:
;
;   A = x_hi^2 + y_hi^2 + z_hi^2
;
; returning A = $FF if the calculation overflows a one-byte result. The K%
; workspace contains the ship data blocks, so the offset in Y must be 0 or a
; multiple of NI% (as each block in K% contains NI% bytes).
;
; Arguments:
;
;   Y                   The offset from K% for the start of the ship data block
;                       to use
;
; Returns
;
;   A                   A = x_hi^2 + y_hi^2 + z_hi^2
;
;                       A = $FF if the calculation overflows a one-byte result
;
; ******************************************************************************

.MAS3

 LDA K%+1,Y             ; Set (A P) = x_hi * x_hi
 JSR SQUA2

 STA R                  ; Store A (high byte of result) in R

 LDA K%+4,Y             ; Set (A P) = y_hi * y_hi
 JSR SQUA2

 ADC R                  ; Add A (high byte of second result) to R

 BCS MA30               ; If the addition of the two high bytes caused a carry
                        ; (i.e. they overflowed), jump to MA30 to return A = $FF

 STA R                  ; Store A (sum of the two high bytes) in R

 SETUP_PPU_FOR_ICON_BAR ; If the PPU has started drawing the icon bar, configure
                        ; the PPU to use nametable 0 and pattern table 0

 LDA K%+7,Y             ; Set (A P) = z_hi * z_hi
 JSR SQUA2

 ADC R                  ; Add A (high byte of third result) to R, so R now
                        ; contains the sum of x_hi^2 + y_hi^2 + z_hi^2

 BCC P%+4               ; If there is no carry, skip the following instruction
                        ; to return straight from the subroutine

.MA30

 LDA #$FF               ; The calculation has overflowed, so set A = $FF

 RTS                    ; Return from the subroutine

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

 LDA #100               ; Call FAROF2 to compare x, y and z with 100, which will
 JSR FAROF2             ; clear the C flag if the distance to the point is < 100
                        ; or set the C flag if it is >= 100

 BCS MA23S2             ; Jump to MA23S2 if the distance to point (x, y, z) is
                        ; >= 100 (i.e. we must be near enough to the planet to
                        ; bump into a space station)

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
;   Category: Maths (Arithmetic)
;    Summary: Calculate X = A / 16
;
; ------------------------------------------------------------------------------
;
; Calculate the following, where A is a sign-magnitude 8-bit integer and the
; result is a signed 8-bit integer:
;
;   X = A / 16
;
; Returns:
;
;   C flag              The C flag is cleared
;
; ******************************************************************************

.SPS2

 TAY                    ; Copy the argument A to Y, so we can check its sign
                        ; below

 AND #%01111111         ; Clear the sign bit of the argument A

 LSR A                  ; Set A = A / 16
 LSR A
 LSR A
 LSR A

 ADC #0                 ; Round the result up to the nearest integer by adding
                        ; the bit we just shifted off the right (which went into
                        ; the C flag)

 CPY #%10000000         ; If Y is positive (i.e. the original argument was
 BCC LL163              ; positive), jump to LL163

 EOR #$FF               ; Negate A using two's complement
 ADC #0

.LL163

 TAX                    ; Copy the result in A to X

 RTS                    ; Return from the subroutine

; ******************************************************************************
;
;       Name: SPS3
;       Type: Subroutine
;   Category: Maths (Geometry)
;    Summary: Copy a space coordinate from the K% block into K3
;
; ------------------------------------------------------------------------------
;
; Copy one of the planet's coordinates into the corresponding location in the
; temporary variable K3. The high byte and absolute value of the sign byte are
; copied into the first two K3 bytes, and the sign of the sign byte is copied
; into the highest K3 byte.
;
; The comments below are written for copying the planet's x-coordinate into
; K3(2 1 0).
;
; Arguments:
;
;   X                   Determines which coordinate to copy, and to where:
;
;                         * X = 0 copies (x_sign, x_hi) into K3(2 1 0)
;
;                         * X = 3 copies (y_sign, y_hi) into K3(5 4 3)
;
;                         * X = 6 copies (z_sign, z_hi) into K3(8 7 6)
;
; ******************************************************************************

.SPS3

 LDA K%+1,X             ; Copy x_hi into K3+X
 STA K3,X

 LDA K%+2,X             ; Set A = Y = x_sign
 TAY

 AND #%01111111         ; Set K3+1 = |x_sign|
 STA K3+1,X

 TYA                    ; Set K3+2 = the sign of x_sign
 AND #%10000000
 STA K3+2,X

 RTS                    ; Return from the subroutine

; ******************************************************************************
;
;       Name: SPS1
;       Type: Subroutine
;   Category: Maths (Geometry)
;    Summary: Calculate the vector to the planet and store it in XX15
;
; ------------------------------------------------------------------------------
;
; Other entry points:
;
;   SPS1+1              A BRK instruction
;
; ******************************************************************************

.SPS1

 LDX #0                 ; Copy the two high bytes of the planet's x-coordinate
 JSR SPS3               ; into K3(2 1 0), separating out the sign bit into K3+2

 LDX #3                 ; Copy the two high bytes of the planet's y-coordinate
 JSR SPS3               ; into K3(5 4 3), separating out the sign bit into K3+5

 LDX #6                 ; Copy the two high bytes of the planet's z-coordinate
 JSR SPS3               ; into K3(8 7 6), separating out the sign bit into K3+8

                        ; Fall through into TAS2 to build XX15 from K3

; ******************************************************************************
;
;       Name: TAS2
;       Type: Subroutine
;   Category: Maths (Geometry)
;    Summary: Normalise the three-coordinate vector in K3
;
; ------------------------------------------------------------------------------
;
; Normalise the vector in K3, which has 16-bit values and separate sign bits,
; and store the normalised version in XX15 as a signed 8-bit vector.
;
; A normalised vector (also known as a unit vector) has length 1, so this
; routine takes an existing vector in K3 and scales it so the length of the
; new vector is 1. This is used in two places: when drawing the compass, and
; when applying AI tactics to ships.
;
; We do this in two stages. This stage shifts the 16-bit vector coordinates in
; K3 to the left as far as they will go without losing any bits off the end, so
; we can then take the high bytes and use them as the most accurate 8-bit vector
; to normalise. Then the next stage (in routine NORM) does the normalisation.
;
; Arguments:
;
;   K3(2 1 0)           The 16-bit x-coordinate as (x_sign x_hi x_lo), where
;                       x_sign is just bit 7
;
;   K3(5 4 3)           The 16-bit y-coordinate as (y_sign y_hi y_lo), where
;                       y_sign is just bit 7
;
;   K3(8 7 6)           The 16-bit z-coordinate as (z_sign z_hi z_lo), where
;                       z_sign is just bit 7
;
; Returns:
;
;   XX15                The normalised vector, with:
;
;                         * The x-coordinate in XX15
;
;                         * The y-coordinate in XX15+1
;
;                         * The z-coordinate in XX15+2
;
; Other entry points:
;
;   TA2                 Calculate the length of the vector in XX15 (ignoring the
;                       low coordinates), returning it in Q
;
; ******************************************************************************

.TAS2

 SETUP_PPU_FOR_ICON_BAR ; If the PPU has started drawing the icon bar, configure
                        ; the PPU to use nametable 0 and pattern table 0

 LDA K3                 ; OR the three low bytes and 1 to get a byte that has
 ORA K3+3               ; a 1 wherever any of the three low bytes has a 1
 ORA K3+6               ; (as well as always having bit 0 set), and store in
 ORA #1                 ; K3+9
 STA K3+9

 LDA K3+1               ; OR the three high bytes to get a byte in A that has a
 ORA K3+4               ; 1 wherever any of the three high bytes has a 1
 ORA K3+7

                        ; (A K3+9) now has a 1 wherever any of the 16-bit
                        ; values in K3 has a 1
.TAL2

 ASL K3+9               ; Shift (A K3+9) to the left, so bit 7 of the high byte
 ROL A                  ; goes into the C flag

 BCS tast1              ; If the left shift pushed a 1 out of the end, then we
                        ; know that at least one of the coordinates has a 1 in
                        ; this position, so jump to TA2 as we can't shift the
                        ; values in K3 any further to the left

 ASL K3                 ; Shift K3(1 0), the x-coordinate, to the left
 ROL K3+1

 ASL K3+3               ; Shift K3(4 3), the y-coordinate, to the left
 ROL K3+4

 ASL K3+6               ; Shift K3(6 7), the z-coordinate, to the left
 ROL K3+7

 BCC TAL2               ; Jump back to TAL2 to do another shift left (this BCC
                        ; is effectively a JMP as we know bit 7 of K3+7 is not a
                        ; 1, as otherwise bit 7 of A would have been a 1 and we
                        ; would have taken the BCS above)

.tast1

 LSR K3+1               ; Shift all three high bytes right by one place to
 LSR K3+4               ; reduce the chances of overflow in the normalisation
 LSR K3+7               ; process

.TA2

 LDA K3+1               ; Fetch the high byte of the x-coordinate from our left-
 LSR A                  ; shifted K3, shift it right to clear bit 7, stick the
 ORA K3+2               ; sign bit in there from the x_sign part of K3, and
 STA XX15               ; store the resulting signed 8-bit x-coordinate in XX15

 LDA K3+4               ; Fetch the high byte of the y-coordinate from our left-
 LSR A                  ; shifted K3, shift it right to clear bit 7, stick the
 ORA K3+5               ; sign bit in there from the y_sign part of K3, and
 STA XX15+1             ; store the resulting signed 8-bit y-coordinate in
                        ; XX15+1

 LDA K3+7               ; Fetch the high byte of the z-coordinate from our left-
 LSR A                  ; shifted K3, shift it right to clear bit 7, stick the
 ORA K3+8               ; sign bit in there from the z_sign part of K3, and
 STA XX15+2             ; store the resulting signed 8-bit  z-coordinate in
                        ; XX15+2

 JMP NORM               ; Now we have a signed 8-bit version of the vector K3 in
                        ; XX15, so jump to NORM to normalise it, returning from
                        ; the subroutine using a tail call

; ******************************************************************************
;
;       Name: WARP
;       Type: Subroutine
;   Category: Flight
;    Summary: Process the fast-forward button to end the demo, dock instantly or
;             perform an in-system jump
;
; ------------------------------------------------------------------------------
;
; This routine does a similar job to the routine of the same name in the BBC
; Master version of Elite, but the code is significantly different.
;
; ******************************************************************************

.WARP

 LDA demoInProgress     ; If the demo is not in progress, jump to warp1 to skip
 BEQ warp1              ; the following

                        ; If we get here then the demo is in progress, in which
                        ; case the fast-forward icon ends the demo and starts
                        ; the game

 JSR ResetShipStatus    ; Reset the ship's speed, hyperspace counter, laser
                        ; temperature, shields and energy banks

 JMP StartGame          ; Jump to StartGame to reset the stack and go to the
                        ; docking bay (i.e. show the Status Mode screen)

.warp1

 LDA auto               ; If the docking computer is engaged (auto is non-zero)
 AND SSPR               ; and we are inside the space station safe zone (SSPR
 BEQ warp2              ; is non-zero), then this sets A to be non-zero, so if
                        ; this is not the case, jump to warp2 to skip the
                        ; following

                        ; If we get here then the docking computer is engaged
                        ; and we are in the space station safe zone, in which
                        ; case the fast-forward button docks us instantly

 JMP GOIN               ; Go to the docking bay (i.e. show the ship hangar
                        ; screen) and return from the subroutine with a tail
                        ; call

.warp2

 JSR FastForwardJump    ; Do an in-system (fast-forward) jump and run the
                        ; distance checks

 BCS warp3              ; If the C flag is set then we are too close to the
                        ; planet or sun for any more jumps, so jump to warp3
                        ; to stop jumping

 JSR FastForwardJump    ; Do a second in-system (fast-forward) jump and run the
                        ; distance checks

 BCS warp3              ; If the C flag is set then we are too close to the
                        ; planet or sun for any more jumps, so jump to warp3
                        ; to stop jumping

 JSR FastForwardJump    ; Do a third in-system (fast-forward) jump and run the
                        ; distance checks

 BCS warp3              ; If the C flag is set then we are too close to the
                        ; planet or sun for any more jumps, so jump to warp3
                        ; to stop jumping

 JSR WaitForNMI         ; Wait until the next NMI interrupt has passed (i.e. the
                        ; next VBlank)

 JSR InSystemJump       ; Do a fourth in-system jump (fast-forward) without
                        ; doing the distance checks

.warp3

 LDA #1                 ; Set the main loop counter to 1, so the next iteration
 STA MCNT               ; through the main loop will potentially spawn ships
                        ; (see part 2 of the main game loop at me3)

 LSR A                  ; Set EV, the extra vessels spawning counter, to 0
 STA EV                 ; (the LSR produces a 0 as A was previously 1)

 JSR CheckAltitude      ; Perform an altitude check with the planet, ending the
                        ; game if we hit the ground

 LDA QQ11               ; If this is not the space view, jump to warp4 to skip
 BNE warp4              ; the updating of the space view and return from the
                        ; subroutine

 LDX VIEW               ; Set X to the current view (front, rear, left or right)

 DEC VIEW               ; Decrement the view in VIEW so the call to LOOK1 thinks
                        ; the view has changed, so it will update the screen

 JMP LOOK1              ; Jump to LOOK1 to initialise the view in X, returning
                        ; from the subroutine using a tail call

.warp4

 RTS                    ; Return from the subroutine

; ******************************************************************************
;
;       Name: FastForwardJump
;       Type: Subroutine
;   Category: Flight
;    Summary: Perform an in-system jump
;
; ------------------------------------------------------------------------------
;
; Returns:
;
;   C flag              The status at the end of the jump:
;
;                         * Clear if the jump ends with us being far enough away
;                           from the planet or sun to do another jump
;
;                         * Set if the jump ends with us being too close to the
;                           planet or sun to do another jump
;
; ******************************************************************************

.FastForwardJump

 JSR WaitForNMI         ; Wait until the next NMI interrupt has passed (i.e. the
                        ; next VBlank)

 JSR InSystemJump       ; Call InSystemJump to do an in-system jump

                        ; Fall through into CheckJumpSafety to work out if we
                        ; are too close to the planet or sun to do another
                        ; in-system jump, returning the result in the C flag
                        ; accordingly

; ******************************************************************************
;
;       Name: CheckJumpSafety
;       Type: Subroutine
;   Category: Flight
;    Summary: Check whether we are far enough away from the planet and sun to be
;             able to do an in-system (fast-forward) jump
;
; ------------------------------------------------------------------------------
;
; This routine checks how far away from the planet and sun we would be if we
; were to do an in-system jump. If we are too close to either object after doing
; a jump, then the C flag is set, otherwise it is clear.
;
; The distance check is only done in the forward direction; if the planet or
; sun is behind us, then it is deemed safe to do a jump.
;
; By default, this routine checks distances against a value of 64 (which is the
; distance of an in-system jump). Arbitrary distances can be checked via the
; entry point at CheckJumpSafety+2.
;
; Returns:
;
;   C flag              Results of the safety check:
;
;                         * Clear if we are not close to the planet or sun and
;                           can do an in-system jump
;
;                         * Set if we are too close to the planet or sun to do
;                           an in-system jump
;
; Other entry points:
;
;   CheckJumpSafety+2    Check the distances against the value in A
;
; ******************************************************************************

.CheckJumpSafety

 LDA #128               ; Set A = 128, to use as the default distance to check
                        ; our proximity against

 LSR A                  ; Set T = A / 2
 STA T                  ;
                        ; So the value of T is set as follows:
                        ;
                        ;   * T = 64 if we call the routine via CheckJumpSafety
                        ;
                        ;   * T = A / 2 if we call the routine via the entry
                        ;     point at CheckJumpSafety+2
                        ;
                        ; T is the value that we check the distances against
                        ; to determine whether we are too close to the planet
                        ; or sun

 LDY #0                 ; Set Y as the offset in K% to the first ship data
                        ; block, i.e. the planet

 JSR cdis1              ; Call cdis1 below to check our distance from the planet

 BCS cdis7              ; If the C flag is set then we are deemed close to the
                        ; planet, so there is no need to check the sun, so jump
                        ; to cdis7 to return from the subroutine with the C flag
                        ; set

 LDA SSPR               ; If SSPR is non-zero then we are inside the space
 BNE cdis7              ; station's safe zone, so we can't be too close to the
                        ; sun, so jump to cdis7 return from the subroutine with
                        ; the C flag clear (we know this is the case as we just
                        ; passed through a BCS)

                        ; If we get here then we have checked the distance to
                        ; the planet and we are not close to it, so now we check
                        ; our distance from the sun

 LDY #NIK%              ; Set Y as the offset in K% to the second ship data
                        ; block, i.e. the sun (this can't be the space station
                        ; as we know we aren't in the safe zone)

.cdis1

                        ; In the following, K%+Y points to the ship data block
                        ; for the object we are measuring the distance to (i.e.
                        ; the planet or sun)
                        ;
                        ; To make things easier to follow, let's refer to this
                        ; object as the planet, with the planet's centre being
                        ; at (x, y, z), where each coordinate is of the form
                        ; (x_sign x_hi x_lo)

 LDA K%+2,Y             ; If either of x_sign or y_sign are non-zero (ignoring
 ORA K%+5,Y             ; the sign in bit 7), then jump to cdis5 to return with
 ASL A                  ; the C flag clear, as the planet is a long way away
 BNE cdis5              ; to the sides or above/below us

 LDA K%+8,Y             ; If z_sign is negative (i.e. bit 7 is set), or z_sign
 LSR A                  ; is positive and z_sign > 1, then jump to cdis5 to
 BNE cdis5              ; return with the C flag clear, as the planet is either
                        ; behind us, or it's a long way in front of us

                        ; The above sets the C flag to bit 0 of z_sign

 LDA K%+7,Y             ; Set A = (z_sign z_hi) / 2 - 32
 ROR A                  ;
 SEC                    ; This result will fit into one byte because we know
 SBC #32                ; bits 1 to 7 of z_sign are clear
                        ;
                        ; As we know the rest of z_sign is empty, let's just
                        ; simplify this to:
                        ;
                        ;   A = (z_hi / 2) - 32
                        ;     = (z_hi - 64) / 2

 BCS cdis2              ; If the above subtraction didn't underflow, jump to
                        ; cdis2 to skip the following

 EOR #$FF               ; The subtraction underflowed so A is negative, so make
 ADC #1                 ; A positive using two's complement (which will work as
                        ; we know the C flag is clear as we just passed through
                        ; a BCS)
                        ;
                        ; We therefore have A = |(z_hi - 64) / 2|

.cdis2

 STA K+2                ; Set K+2 = |(z_hi - 64) / 2|

 LDA K%+1,Y             ; Set K = x_hi / 2
 LSR A
 STA K

 LDA K%+4,Y             ; Set K+1 = y_hi / 2
 LSR A                  ;
 STA K+1                ; This also sets A = K+1

                        ; From this point on we are only working with the high
                        ; bytes, so to make things easier to follow, let's just
                        ; refer to x_hi, y_hi and z_hi as x, y and z, so:
                        ;
                        ;   K   = x / 2
                        ;   K+1 = y / 2
                        ;   K+2 = (z - 64) / 2
                        ;
                        ; The following algorithm is the same as the FAROF2
                        ; routine, so this measures the distance from our ship
                        ; to the point (x, y, z - 64), which is where (x, y, z)
                        ; will be if we jump forward by a distance of z_hi = 64
                        ;
                        ; In other words, the following checks the distance from
                        ; our ship to the planet if we were to do an in-system
                        ; jump forwards

 CMP K                  ; If A >= K, jump to cdis3 to skip the next instruction
 BCS cdis3

 LDA K                  ; Set A = K, so A = max(K, K+1)

.cdis3

 CMP K+2                ; If A >= K+2, jump to cdis4 to skip the next
 BCS cdis4              ; instruction

 LDA K+2                ; Set A = K+2, so A = max(A, K+2)
                        ;                   = max(K, K+1, K+2)

.cdis4

 STA SC                 ; Set SC = A
                        ;        = max(K, K+1, K+2)
                        ;        = max(x / 2, y / 2, z / 2)
                        ;        = max(x, y, z) / 2

 LDA K                  ; Set SC+1 = (K + K+1 + K+2 - SC) / 4
 CLC                    ;          = (x/2 + y/2 + z/2 - max(x, y, z) / 2) / 4
 ADC K+1                ;          = (x + y + z - max(x, y, z)) / 8
 ADC K+2
 SEC
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

 BCC cdis6              ; If the C flag is clear then |x y z| <  argument A,
                        ; which means we are close to the planet, so jump to
                        ; cdis6 to return with the C flag set to indicate this

                        ; Otherwise |x y z| >= argument A, which means we are
                        ; not close to the planet, so fall through into cdis5
                        ; to return with the C flag clear to indicate this

.cdis5

 CLC                    ; Set the C flag to indicate that we are not close to
                        ; the planet and can do an in-system jump

 RTS                    ; Return from the subroutine

.cdis6

 SEC                    ; Set the C flag to indicate that we are too close to
                        ; the planet to do an in-system jump

.cdis7

 RTS                    ; Return from the subroutine

; ******************************************************************************
;
;       Name: InSystemJump
;       Type: Subroutine
;   Category: Flight
;    Summary: Perform an in-system (fast-forward) jump
;
; ------------------------------------------------------------------------------
;
; This routine performs an in-system jump by subtracting 64 from z_hi for the
; planet and sun, and removing all other ships from the bubble. This is the same
; as our ship moving forwards in space by z_hi = 64, and leaving all the other
; ships behind.
;
; ******************************************************************************

.InSystemJump

 LDY #32                ; We start by charging the shields and energy banks 32
                        ; times, so set a loop counter in Y

.jump1

 JSR ChargeShields      ; Charge the shields and energy banks

 DEY                    ; Decrement the loop counter

 BNE jump1              ; Loop back to charge the shields until we have done it
                        ; 32 times

                        ; We now move the sun and planet backwards in space and
                        ; remove everything else from the ship slots, to make it
                        ; appear as if we have jumped forward, leaving
                        ; everything else behind

 LDX #0                 ; We are about to loop through the ship slots, moving
                        ; everything backwards so we appear to jump forwards in
                        ; space, so set X = 0 to use as the slot number

 STX GNTMP              ; Set GNTMP = 0 to cool the lasers down completely

.jump2

 STX XSAV               ; Store the slot number in XSAV so we can retrieve it
                        ; below

 LDA FRIN,X             ; Load the ship type for the X-th slot

 BEQ jump4              ; If the slot contains 0 then it is empty and we have
                        ; processed all the slots (as they are always shuffled
                        ; down in the main loop to close up and gaps), so jump
                        ; to jump4 as we are done

 BMI jump3              ; If the slot contains a ship type with bit 7 set, then
                        ; it contains the planet or the sun, so jump down to
                        ; jump3 to move the planet or sun in space

                        ; If we get here then this is not the planet or sun, so
                        ; we now remove this ship from our local bubble of
                        ; universe

 JSR GINF               ; Call GINF to get the address of the data block for
                        ; ship slot X and store it in INF

 JSR RemoveShip         ; Fetch the ship's data block and remove the ship from
                        ; our local bubble of universe

 LDX XSAV               ; Set X to the slot counter that we stored in XSAV above

 JMP jump2              ; Loop back to process the next slot

.jump3

 JSR GINF               ; Call GINF to get the address of the data block for
                        ; ship slot X and store it in INF

 LDA #$80               ; Set (S R) = -64
 STA S                  ;
 LSR A                  ; This is a sign-magnitude number, with bit 7 of S set
 STA R                  ; and R = 128 / 2 = 64

 LDY #7                 ; Set P = z_hi from the ship's data block
 LDA (INF),Y
 STA P

 INY                    ; Set A = z_sign from the ship's data block
 LDA (INF),Y

 JSR ADD                ; Set (A X) = (A P) + (S R)
                        ;           = (z_sign z_hi) - 64

 STA (INF),Y            ; Store the result in (z_sign z_hi) in the ship's data
 DEY                    ; block, so the object moves backwards by a distance of
 TXA                    ; z_hi = 64 (which is the distance of an in-system jump)
 STA (INF),Y

 LDX XSAV               ; Set X to the slot counter that we stored in XSAV above

 INX                    ; Increment X to point to the next ship slot

 BNE jump2              ; Loop back to process the next slot (this BNE is
                        ; effectively a JMP as we will exit the above loop well
                        ; before X wraps around to 0

.jump4

 RTS                    ; Return from the subroutine

; ******************************************************************************
;
;       Name: DOKEY
;       Type: Subroutine
;   Category: Controllers
;    Summary: Scan for the seven primary flight controls and apply the docking
;             computer manoeuvring code
;  Deep dive: The key logger
;             The docking computer
;
; ******************************************************************************

.DOKEY

 JSR SetKeyLogger_b6    ; Populate the key logger table with the controller
                        ; button presses and return the button number in X
                        ; if an icon bar button has been chosen

 LDA auto               ; If auto is non-zero, then the docking computer is
 BNE doky3              ; currently activated, so jump to doky3 to apply the
                        ; docking computer manoeuvring code below

.doky1

 LDX iconBarKeyPress    ; If the icon bar key logger entry in iconBarKeyPress
 CPX #64                ; is not 64, then jump to doky2 to skip the following
 BNE doky2              ; (interestingly, iconBarKeyPress can never contain
                        ; this value, as none of the keys in the iconBarButtons
                        ; table have this value, and the value for the Start
                        ; button is 80)

 JMP PauseGame_b6       ; Pause the game and process choices from the pause menu
                        ; until the game is unpaused by another press of Start,
                        ; returning from the subroutine using a tail call

.doky2

 RTS                    ; Return from the subroutine

.doky3

 LDA SSPR               ; If we are inside the space station safe zone, jump to
 BNE doky4              ; doky4 to run the docking computer manoeuvring code

 STA auto               ; Otherwise set auto to 0 to disable the docking
                        ; computer, so we can't engage it outside of the safe
                        ; zone

 JSR ResetMusicAfterNMI ; Wait for the next NMI before resetting the current
                        ; tune to 0 (no tune) and stopping the music

 JMP doky1              ; Loop back to doky1 to check the icon bar key logger
                        ; entry and return from the subroutine

.doky4

 JSR ZINF               ; Call ZINF to reset the INWK ship workspace

 LDA #96                ; Set nosev_z_hi = 96
 STA INWK+14

 ORA #%10000000         ; Set sidev_x_hi = -96
 STA INWK+22

 STA TYPE               ; Set the ship type to -96, so the negative value will
                        ; let us check in the DOCKIT routine whether this is our
                        ; ship that is activating its docking computer, rather
                        ; than an NPC ship docking

 LDA DELTA              ; Set the ship speed to DELTA (our speed)
 STA INWK+27

 JSR DOCKIT             ; Call DOCKIT to calculate the docking computer's moves
                        ; and update INWK with the results

                        ; We now "press" the relevant flight keys, depending on
                        ; the results from DOCKIT, starting with the pitch keys

 LDA INWK+27            ; Fetch the updated ship speed from byte #27 into A

 CMP #22                ; If A < 22, skip the next instruction
 BCC P%+4

 LDA #22                ; Set A = 22, so the maximum speed during docking is 22

 STA DELTA              ; Update DELTA to the new value in A

 LDA #$FF               ; Set A = $FF, which we can insert into the key logger
                        ; to "fake" the docking computer working the keyboard

 LDX #0                 ; Set X = 0, so we "press" KY1 below ("?", slow down)

 LDY INWK+28            ; If the updated acceleration in byte #28 is zero, skip
 BEQ DK11               ; to DK11

 BMI P%+4               ; If the updated acceleration is negative, skip the
                        ; following instruction

 LDX #1                 ; Set X = 1, so we "press" KY+1, i.e. KY2, with the
                        ; next instruction (speed up)

 STA KL,X               ; Store $FF in either KY1 or KY2 to "press" the relevant
                        ; key, depending on whether the updated acceleration is
                        ; negative (in which case we "press" KY1, "?", to slow
                        ; down) or positive (in which case we "press" KY2,
                        ; Space, to speed up)

.DK11

                        ; We now "press" the relevant roll keys, depending on
                        ; the results from DOCKIT

 LDA #128               ; Set A = 128, which indicates no change in roll when
                        ; stored in JSTX (i.e. the centre of the roll indicator)

 LDX #2                 ; Set X = 2, so we "press" KL+2, i.e. KY3 below
                        ; (left button, increase roll)

 ASL INWK+29            ; Shift ship byte #29 left, which shifts bit 7 of the
                        ; updated roll counter (i.e. the roll direction) into
                        ; the C flag

 BEQ DK12               ; If the remains of byte #29 is zero, then the updated
                        ; roll counter is zero, so jump to DK12 set JSTX to 128,
                        ; to indicate there's no change in the roll

 BCC P%+4               ; If the C flag is clear, skip the following instruction

 LDX #3                 ; The C flag is set, i.e. the direction of the updated
                        ; roll counter is negative, so set X to 3 so we
                        ; "press" KY+3. i.e. KY4, below (right button, decrease
                        ; roll)

 BIT INWK+29            ; We shifted the updated roll counter to the left above,
 BPL DK14               ; so this tests bit 6 of the original value, and if it
                        ; is clear (i.e. the magnitude is less than 64), jump to
                        ; DK14 to "press" the key and leave JSTX unchanged

 LDA #64                ; The magnitude of the updated roll is 64 or more, so
 STA JSTX               ; set JSTX to 64 (so the roll decreases at half the
                        ; maximum rate)

 LDA #0                 ; And set A = 0 so we do not "press" any keys (so if the
                        ; docking computer needs to make a serious roll, it does
                        ; so by setting JSTX directly rather than by "pressing"
                        ; a key)

.DK14

 STA KL,X               ; Store A in either KY3 or KY4, depending on whether
                        ; the updated roll rate is increasing (KY3) or
                        ; decreasing (KY4)

 LDA JSTX               ; Fetch A from JSTX so the next instruction has no
                        ; effect

.DK12

 STA JSTX               ; Store A in JSTX to update the current roll rate

                        ; We now "press" the relevant pitch keys, depending on
                        ; the results from DOCKIT

 LDA #128               ; Set A = 128, which indicates no change in pitch when
                        ; stored in JSTX (i.e. the centre of the pitch
                        ; indicator)

 LDX #4                 ; Set X = 4, so we "press" KY+4, i.e. KY5, below
                        ; (down button, decrease pitch)

 ASL INWK+30            ; Shift ship byte #30 left, which shifts bit 7 of the
                        ; updated pitch counter (i.e. the pitch direction) into
                        ; the C flag

 BEQ DK13               ; If the remains of byte #30 is zero, then the updated
                        ; pitch counter is zero, so jump to DK13 set JSTY to
                        ; 128, to indicate there's no change in the pitch

 BCS P%+4               ; If the C flag is set, skip the following instruction

 LDX #5                 ; Set X = 5, so we "press" KY+5, i.e. KY6, with the next
                        ; instruction (up button, increase pitch)

 STA KL,X               ; Store 128 in either KY5 or KY6 to "press" the relevant
                        ; key, depending on whether the pitch direction is
                        ; negative (in which case we "press" KY5, "X", to
                        ; decrease the pitch) or positive (in which case we
                        ; "press" KY6, "S", to increase the pitch)

 LDA JSTY               ; Fetch A from JSTY so the next instruction has no
                        ; effect

.DK13

 STA JSTY               ; Store A in JSTY to update the current pitch rate

 LDX JSTX               ; Set X = JSTX, the current roll rate (as shown in the
                        ; RL indicator on the dashboard)

 LDA #14                ; Set A to 14, which is the amount we want to alter the
                        ; roll rate by if the roll keys are being pressed

 LDY KY3                ; If the left button is not being pressed, skip the next
 BEQ P%+5               ; instruction

 JSR BUMP2              ; The left button is being pressed, so call the BUMP2
                        ; routine to increase the roll rate in X by A

 LDY KY4                ; If the right button is not being pressed, skip the
 BEQ P%+5               ; next instruction

 JSR REDU2              ; The right button is being pressed, so call the REDU2
                        ; routine to decrease the roll rate in X by A, taking
                        ; the keyboard auto re-centre setting into account

 STX JSTX               ; Store the updated roll rate in JSTX

 LDA #14                ; Set A to 15, which is the amount we want to alter the
                        ; roll rate by if the pitch keys are being pressed

 LDX JSTY               ; Set X = JSTY, the current pitch rate (as shown in the
                        ; DC indicator on the dashboard)

 LDY KY5                ; If the down button is not being pressed, skip the next
 BEQ P%+5               ; instruction

 JSR REDU2              ; The down button is being pressed, so call the REDU2
                        ; routine to decrease the pitch rate in X by A, taking
                        ; the keyboard auto re-centre setting into account

 LDY KY6                ; If the up button is not being pressed, skip the next
 BEQ P%+5               ; instruction

 JSR BUMP2              ; The up button is being pressed, so call the BUMP2
                        ; routine to increase the pitch rate in X by A

 STX JSTY               ; Store the updated roll rate in JSTY

 LDA auto               ; If auto is non-zero, then the docking computer is
 BNE doky6              ; currently activated, so jump up to doky1 via doky6 to
                        ; check the icon bar key logger entry and return from
                        ; the subroutine

 LDX #128

 LDA KY3                ; If either of the left or right buttons are being 
 ORA KY4                ; pressed, jump to doky5 to skip the following
 BNE doky5              ; instruction, so pressing buttons on the controller
                        ; overrides the docking computer

 STX JSTX               ; Store the updated roll rate in JSTX

.doky5

 LDA KY5                ; If either of the up or down buttons are being 
 ORA KY6                ; pressed, jump to doky6 to skip the following
 BNE doky6              ; instruction, so pressing buttons on the controller
                        ; overrides the docking computer

 STX JSTY               ; Store the updated roll rate in JSTY

.doky6

 JMP doky1              ; Loop back to doky1 to check the icon bar key logger
                        ; entry and return from the subroutine

; ******************************************************************************
;
;       Name: PrintMessage
;       Type: Subroutine
;   Category: Text
;    Summary: Print a message in the middle of the screen (used for "GAME OVER"
;             and demo missile messages only)
;
; ------------------------------------------------------------------------------
;
; Arguments:
;
;   A                   The text token to be printed
;
;   Y                   The length of time to leave the message on-screen
;
; ******************************************************************************

.PrintMessage

 PHA                    ; Store A on the stack so we can restore it after the
                        ; following

 STY DLY                ; Set the message delay in DLY to Y

 LDA #%11000000         ; Set the DTW4 flag to %11000000 (justify text, buffer
 STA DTW4               ; entire token including carriage returns)

 LDA #0                 ; Set DTW5 = 0, to reset the size of the message in the
 STA DTW5               ; text buffer at BUF

 PLA                    ; Restore A from the stack

 JSR ex_b2              ; Print the recursive token in A

 JMP StoreMessage       ; Jump to StoreMessage to copy the message from the
                        ; justified text buffer in BUF into the message buffer
                        ; at messageBuffer, returning ffom the subroutine using
                        ; a tail call

; ******************************************************************************
;
;       Name: MESS
;       Type: Subroutine
;   Category: Text
;    Summary: Display an in-flight message
;
; ------------------------------------------------------------------------------
;
; Display an in-flight message in capitals at the bottom of the space view,
; erasing any existing in-flight message first.
;
; Arguments:
;
;   A                   The text token to be printed
;
; ******************************************************************************

.MESS

 PHA                    ; Store A on the stack so we can restore it after the
                        ; following

 SETUP_PPU_FOR_ICON_BAR ; If the PPU has started drawing the icon bar, configure
                        ; the PPU to use nametable 0 and pattern table 0

 LDY #10                ; Set the message delay in DLY to 10
 STY DLY

 LDA #%11000000         ; Set the DTW4 flag to %11000000 (justify text, buffer
 STA DTW4               ; entire token including carriage returns)

 LDA #0                 ; Set DTW5 = 0, which sets the size of the justified
 STA DTW5               ; text buffer at BUF to zero

 PLA                    ; Restore A from the stack

 CMP #250               ; If this is not token 250 (the hyperspace countdown),
 BNE mess1              ; jump to mess1 to print the token in A

                        ; This is token 250, so now we print the hyperspace
                        ; countdown

 LDA #0                 ; Set QQ17 = 0 to switch to ALL CAPS
 STA QQ17

 LDA #189               ; Print recursive token 29 ("HYPERSPACE ")
 JSR TT27_b2

 LDA #'-'               ; Print a hyphen
 JSR TT27_b2

 JSR TT162              ; Print a space

 SETUP_PPU_FOR_ICON_BAR ; If the PPU has started drawing the icon bar, configure
                        ; the PPU to use nametable 0 and pattern table 0

 JSR SetSelectedSeeds   ; Set the seeds for the selected system in QQ15 to the
                        ; seeds in the safehouse

 LDA #3                 ; Set A = 3 so we print the hyperspace countdown with
                        ; three digits

 CLC                    ; Clear the C flag so we print the hyperspace countdown
                        ; without a decimal point

 LDX QQ22+1             ; Set (Y X) = QQ22+1, which contains the number that's
 LDY #0                 ; shown on-screen during hyperspace countdown

 JSR TT11               ; Print the hyperspace countdown with 3 digits and no
                        ; decimal point

 JMP mes9+3             ; Jump to mes9+3 to skip the following and not print 
                        ; the message in A, as we havealready printed it

.mess1

 PHA                    ; Store A on the stack so we can restore it after the
                        ; following

 LDA #0                 ; Set QQ17 = 0 to switch to ALL CAPS
 STA QQ17

 PLA                    ; Restore A from the stack

                        ; Fall through into mes9 to print the token in A

; ******************************************************************************
;
;       Name: mes9
;       Type: Subroutine
;   Category: Text
;    Summary: Print a text token, possibly followed by " DESTROYED"
;
; ------------------------------------------------------------------------------
;
; Print a text token, followed by " DESTROYED" if the destruction flag is set
; (for when a piece of equipment is destroyed).
;
; Other entry points:
;
;   mes9+3              Don't print the text token, just print " DESTROYED"
;                       where applicable
;
; ******************************************************************************

.mes9

 JSR TT27_b2            ; Call TT27 to print the text token in A

 LDA de                 ; If de is zero, then jump to StoreMessage to skip the
 BEQ StoreMessage       ; following, as we don't need to print " DESTROYED"

 LDA #253               ; Print recursive token 93 (" DESTROYED")
 JSR TT27_b2

                        ; Fall through into StoreMessage to copy the message
                        ; from the justified text buffer in BUF into the
                        ; message buffer at messageBuffer

; ******************************************************************************
;
;       Name: StoreMessage
;       Type: Subroutine
;   Category: Text
;    Summary: Copy a message from the justified text buffer at BUF into the
;             message buffer
;
; ******************************************************************************

.StoreMessage

 LDA #32                ; Set A = 32 - DTW5
 SEC                    ;
 SBC DTW5               ; Where DTW5 is the size of the justified text buffer at
                        ; BUF, so A contains the number of characters remaining
                        ; if we print the message buffer on one line (as each
                        ; line contains 32 characters)

 BCS smes1              ; If the subtraction didn't underflow, then the message
                        ; in the message buffer will fit on one line, so jump to
                        ; smes1 with the remaining number of characters in A

                        ; The subraction underflowed, so the message will not
                        ; fit on one line
                        ;
                        ; In this case we just print as many characters as we
                        ; can and truncate the message at the end of the line

 LDA #31                ; Set the size of the message buffer in DTW5 to 31,
 STA DTW5               ; which is the maximum size of a one-line message

 LDA #2                 ; Set A = 2 so the message will be printed in column 1
                        ; on the left of the screen

.smes1

                        ; When we get here, A contains the number of characters
                        ; remaining if we were to print the message on one line
                        ; of the screen

 LSR A                  ; Set A = A / 2
                        ;
                        ; So A now contains half the amount of free space left
                        ; if we print the message on one line, which is the
                        ; amount of space on each side of the message when it is
                        ; centred on the line
                        ;
                        ; In other words, this is the column number where we
                        ; need to print our message for it to be centred
                        ; on-screen

 STA messXC             ; Store A in messXC, so when we erase the message via
                        ; the branch to me1 above, messXC will tell us where to
                        ; print it

 SETUP_PPU_FOR_ICON_BAR ; If the PPU has started drawing the icon bar, configure
                        ; the PPU to use nametable 0 and pattern table 0

 LDX DTW5               ; Set the size of the message in the message buffer to
 STX messageLength      ; the size of the justified text buffer, as we are about
                        ; to copy from one to the other

 INX                    ; Set X as a character counter so we can loop through
                        ; message and copy it one character at a time (we
                        ; increment it so X is at least 1, to make the following
                        ; loop work)

.smes2

 LDA BUF-1,X            ; Copy the character number X - 1 from BUF into
 STA messageBuffer-1,X  ; messageBuffer

 DEX                    ; Decrement the character counter

 BNE smes2              ; Loop back until we have copied all X characters

 STX de                 ; Zero de, the flag that appends " DESTROYED" to the
                        ; end of the next text token, so that it doesn't append
                        ; it to the next message

 SETUP_PPU_FOR_ICON_BAR ; If the PPU has started drawing the icon bar, configure
                        ; the PPU to use nametable 0 and pattern table 0

                        ; Fall through into DisableJustifyText to reset DTW4 and
                        ; DTW5 to turn off justified text and reset the
                        ; justified text buffer

; ******************************************************************************
;
;       Name: DisableJustifyText
;       Type: Subroutine
;   Category: Text
;    Summary: Turn off justified text and reset the justified text buffer
;
; ------------------------------------------------------------------------------
;
; Other entry points:
;
;   RTS5                Contains an RTS
;
; ******************************************************************************

.DisableJustifyText

 LDA #0                 ; Set DTW4 = %00000000 (do not justify text, print
 STA DTW4               ; buffer on carriage return)

 STA DTW5               ; Set DTW5 = 0, to reset the size of the message in the
                        ; text buffer at BUF

.RTS5

 RTS                    ; Return from the subroutine

; ******************************************************************************
;
;       Name: PrintFlightMessage
;       Type: Subroutine
;   Category: Text
;    Summary: Print an in-flight message
;
; ******************************************************************************

.PrintFlightMessage

 LDA messYC             ; Set A to the current row for in-flight messages

 LDX QQ11               ; If this is the space view, jump to fmes1 to skip the
 BEQ fmes1              ; following and leave A with this value, so we print the
                        ; in-flight message on the row specified in messYC

 JSR CLYNS+8            ; Clear the bottom two text rows of the visible screen,
                        ; and move the text cursor to column 1 on row 21, i.e.
                        ; the start of the top row of the two bottom rows, but
                        ; without resetting the in-flight message timer

 LDA #23                ; Set A to 23, so we print the in-flight message on row
                        ; 23 for all views other than the space view

.fmes1

 STA YC                 ; Move the text cursor to the row in A

 LDX #0                 ; Set QQ17 = 0 to switch to ALL CAPS
 STX QQ17

 SETUP_PPU_FOR_ICON_BAR ; If the PPU has started drawing the icon bar, configure
                        ; the PPU to use nametable 0 and pattern table 0

 LDA messXC             ; Move the text cursor to column messXC, which we set
 STA XC                 ; to the text column of the current in-flight message
                        ; when we called MESS to display it

 LDA messXC             ; This appears to be an unnecessary duplicate of the
 STA XC                 ; above

 LDY #0                 ; We now work through the message one character at a
                        ; time, so set a character counter in Y

.fmes2

 LDA messageBuffer,Y    ; Fetch the Y-th character from the message buffer

 JSR CHPR_b2            ; Print the character

 INY                    ; Increment the character counter in Y

 CPY messageLength      ; Loop back until we have printed all the characters in
 BNE fmes2              ; the buffer, whose size is in messageLength

 LDA QQ11               ; If this is the space view, jump to RTS5 to return from
 BEQ RTS5               ; the subroutine, as the NMI handler will take care of
                        ; updating the screen when we next flip bitplanes

 JMP DrawMessageInNMI   ; Configure the NMI to display the message that we just
                        ; printed, returning from the subroutine using a tail
                        ; call

; ******************************************************************************
;
;       Name: OUCH
;       Type: Subroutine
;   Category: Flight
;    Summary: Potentially lose cargo or equipment following damage
;
; ------------------------------------------------------------------------------
;
; Our shields are dead and we are taking damage, so there is a small chance of
; losing cargo or equipment.
;
; Other entry points:
;
;   ouch1               Print the token in A as an in-flight message
;
; ******************************************************************************

.OUCH

 JSR DORND              ; Set A and X to random numbers

 BMI out                ; If A < 0 (50% chance), return from the subroutine
                        ; (as out contains an RTS)

 CPX #22                ; If X >= 22 (91% chance), return from the subroutine
 BCS out                ; (as out contains an RTS)

 LDA QQ20,X             ; If we do not have any of item QQ20+X, return from the
 BEQ out                ; subroutine (as out contains an RTS). X is in the range
                        ; 0-21, so this not only checks for cargo, but also for
                        ; E.C.M., fuel scoops, energy bomb, energy unit and
                        ; docking computer, all of which can be destroyed

 LDA DLY                ; If there is already an in-flight message on-screen,
 BNE out                ; return from the subroutine (as out contains an RTS)

 LDY #3                 ; Set bit 1 of de, the equipment destruction flag, so
 STY de                 ; that when we call MESS below, " DESTROYED" is appended
                        ; to the in-flight message

 STA QQ20,X             ; A is 0 (as we didn't branch with the BNE above), so
                        ; this sets QQ20+X to 0, which destroys any cargo or
                        ; equipment we have of that type

 CPX #17                ; If X >= 17 then we just lost a piece of equipment, so
 BCS ou1                ; jump to ou1 to print the relevant message

 TXA                    ; Print recursive token 48 + A as an in-flight token,
 ADC #208               ; which will be in the range 48 ("FOOD") to 64 ("ALIEN
 JMP MESS               ; ITEMS") as the C flag is clear, so this prints the
                        ; destroyed item's name, followed by " DESTROYED" (as we
                        ; set bit 1 of the de flag above), and returns from the
                        ; subroutine using a tail call

.ou1

 BEQ ou2                ; If X = 17, jump to ou2 to print "E.C.M.SYSTEM
                        ; DESTROYED" and return from the subroutine using a tail
                        ; call

 CPX #18                ; If X = 18, jump to ou3 to print "FUEL SCOOPS
 BEQ ou3                ; DESTROYED" and return from the subroutine using a tail
                        ; call

 TXA                    ; Otherwise X is in the range 19 to 21 and the C flag is
 ADC #113-20            ; set (as we got here via a BCS to ou1), so we set A as
                        ; follows:
                        ;
                        ;   A = 113 - 20 + X + C
                        ;     = 113 - 19 + X
                        ;     = 113 to 115

.ouch1

 JSR MESS               ; Print recursive token A ("ENERGY BOMB", "ENERGY UNIT"
                        ; or "DOCKING COMPUTERS") as an in-flight message,
                        ; followed by " DESTROYED"

 JMP UpdateIconBar_b3   ; Update the icon bar to remove icons for any equipment
                        ; that has been destroyed, returning from the subroutine
                        ; using a tail call

.out

 RTS                    ; Return from the subroutine

; ******************************************************************************
;
;       Name: ou2
;       Type: Subroutine
;   Category: Text
;    Summary: Display "E.C.M.SYSTEM DESTROYED" as an in-flight message
;
; ******************************************************************************

.ou2

 LDA #108               ; Set A to recursive token 108 ("E.C.M.SYSTEM")

 BNE ouch1              ; Jump up to ouch1 to print recursive token A as an
                        ; in-flight message, followed by " DESTROYED", and
                        ; return from the subroutine using a tail call (this
                        ; BNE is effectively a JMP as A is never zero)

; ******************************************************************************
;
;       Name: ou3
;       Type: Subroutine
;   Category: Text
;    Summary: Display "FUEL SCOOPS DESTROYED" as an in-flight message
;
; ******************************************************************************

.ou3

 LDA #111               ; Set A to recursive token 111 ("FUEL SCOOPS")

 JMP MESS               ; Print recursive token A as an in-flight message,
                        ; followed by " DESTROYED", and return from the
                        ; subroutine using a tail call

; ******************************************************************************
;
;       Name: QQ23
;       Type: Variable
;   Category: Market
;    Summary: Market prices table
;
; ------------------------------------------------------------------------------
;
; Each item has four bytes of data, like this:
;
;   Byte #0 = Base price
;   Byte #1 = Economic factor in bits 0-4, with the sign in bit 7
;             Unit in bits 5-6
;   Byte #2 = Base quantity
;   Byte #3 = Mask to control price fluctuations
;
; To make it easier for humans to follow, we've defined a macro called ITEM
; that takes the following arguments and builds the four bytes for us:
;
;   ITEM base price, economic factor, units, base quantity, mask
;
; So for food, we have the following:
;
;   * Base price = 19
;   * Economic factor = -2
;   * Unit = tonnes
;   * Base quantity = 6
;   * Mask = %00000001
;
; ******************************************************************************

.QQ23

 ITEM 19,  -2, 't',   6, %00000001   ;  0 = Food
 ITEM 20,  -1, 't',  10, %00000011   ;  1 = Textiles
 ITEM 65,  -3, 't',   2, %00000111   ;  2 = Radioactives
 ITEM 40,  -5, 't', 226, %00011111   ;  3 = Robot Slaves (Slaves in original)
 ITEM 83,  -5, 't', 251, %00001111   ;  4 = Beverages (Liquor/Wines in original)
 ITEM 196,  8, 't',  54, %00000011   ;  5 = Luxuries
 ITEM 235, 29, 't',   8, %01111000   ;  6 = Rare Species (Narcotics in original)
 ITEM 154, 14, 't',  56, %00000011   ;  7 = Computers
 ITEM 117,  6, 't',  40, %00000111   ;  8 = Machinery
 ITEM 78,   1, 't',  17, %00011111   ;  9 = Alloys
 ITEM 124, 13, 't',  29, %00000111   ; 10 = Firearms
 ITEM 176, -9, 't', 220, %00111111   ; 11 = Furs
 ITEM 32,  -1, 't',  53, %00000011   ; 12 = Minerals
 ITEM 97,  -1, 'k',  66, %00000111   ; 13 = Gold
 ITEM 171, -2, 'k',  55, %00011111   ; 14 = Platinum
 ITEM 45,  -1, 'g', 250, %00001111   ; 15 = Gem-Stones
 ITEM 53,  15, 't', 192, %00000111   ; 16 = Alien items

; ******************************************************************************
;
;       Name: PAS1
;       Type: Subroutine
;   Category: Controllers
;    Summary: Display a rotating ship at space coordinates (0, 100, 256) and
;             scan the controllers
;
; ******************************************************************************

.PAS1

 LDA #100               ; Set y_lo = 100
 STA INWK+3

 LDA #0                 ; Set x_lo = 0
 STA INWK

 STA INWK+6             ; Set z_lo = 0

 LDA #2                 ; Set z_hi = 1, so (z_hi z_lo) = 256
 STA INWK+7

 JSR DrawShipInBitplane ; Flip the drawing bitplane and draw the current ship in
                        ; the newly flipped bitplane

 INC MCNT               ; Increment the main loop counter

 JMP MVEIT              ; Call MVEIT to move and rotate the ship in space,
                        ; returning from the subroutine using a tail call

 JMP SetKeyLogger_b6    ; This instruction is never reached and has no effect
                        ; (it would populate the key logger table with the
                        ; controller button presses)

; ******************************************************************************
;
;       Name: MVEIT (Part 1 of 9)
;       Type: Subroutine
;   Category: Moving
;    Summary: Move current ship: Tidy the orientation vectors
;  Deep dive: Program flow of the ship-moving routine
;             Scheduling tasks with the main loop counter
;
; ------------------------------------------------------------------------------
;
; This routine has multiple stages. This stage does the following:
;
;   * Tidy the orientation vectors for one of the ship slots
;
; Arguments:
;
;   INWK                The current ship/planet/sun's data block
;
;   XSAV                The slot number of the current ship/planet/sun
;
;   TYPE                The type of the current ship/planet/sun
;
; ******************************************************************************

.MVEIT

 SETUP_PPU_FOR_ICON_BAR ; If the PPU has started drawing the icon bar, configure
                        ; the PPU to use nametable 0 and pattern table 0

 LDA INWK+31            ; If bits 5 or 7 of ship byte #31 are set, jump to MV30
 AND #%10100000         ; as the ship is either exploding or has been killed, so
 BNE MV30               ; we don't need to tidy its orientation vectors or apply
                        ; tactics

 LDA MCNT               ; Fetch the main loop counter

 EOR XSAV               ; Fetch the slot number of the ship we are moving, EOR
 AND #15                ; with the loop counter and apply mod 15 to the result.
 BNE MV3                ; The result will be zero when "counter mod 15" matches
                        ; the slot number, so this makes sure we call TIDY 12
                        ; times every 16 main loop iterations, like this:
                        ;
                        ;   Iteration 0, tidy the ship in slot 0
                        ;   Iteration 1, tidy the ship in slot 1
                        ;   Iteration 2, tidy the ship in slot 2
                        ;     ...
                        ;   Iteration 11, tidy the ship in slot 11
                        ;   Iteration 12, do nothing
                        ;   Iteration 13, do nothing
                        ;   Iteration 14, do nothing
                        ;   Iteration 15, do nothing
                        ;   Iteration 16, tidy the ship in slot 0
                        ;     ...
                        ;
                        ; and so on

 JSR TIDY_b1            ; Call TIDY to tidy up the orientation vectors, to
                        ; prevent the ship from getting elongated and out of
                        ; shape due to the imprecise nature of trigonometry
                        ; in assembly language

; ******************************************************************************
;
;       Name: MVEIT (Part 2 of 9)
;       Type: Subroutine
;   Category: Moving
;    Summary: Move current ship: Call tactics routine, remove ship from scanner
;  Deep dive: Scheduling tasks with the main loop counter
;
; ------------------------------------------------------------------------------
;
; This routine has multiple stages. This stage does the following:
;
;   * Apply tactics to ships with AI enabled (by calling the TACTICS routine)
;
;   * Remove the ship from the scanner, so we can move it
;
; ******************************************************************************

.MV3

 LDX TYPE               ; If the type of the ship we are moving is positive,
 BPL P%+5               ; i.e. it is not a planet (types 128 and 130) or sun
                        ; (type 129), then skip the following instruction

 JMP MV40               ; This item is the planet or sun, so jump to MV40 to
                        ; move it, which ends by jumping back into this routine
                        ; at MV45 (after all the rotation, tactics and scanner
                        ; code, which we don't need to apply to planets or suns)

 LDA INWK+32            ; Fetch the ship's byte #32 (AI flag) into A

 BPL MV30               ; If bit 7 of the AI flag is clear, then if this is a
                        ; ship or missile it is dumb and has no AI, and if this
                        ; is the space station it is not hostile, so in both
                        ; cases skip the following as it has no tactics

 CPX #MSL               ; If the ship is a missile, skip straight to MV26 to
 BEQ MV26               ; call the TACTICS routine, as we do this every
                        ; iteration of the main loop for missiles only

 LDA MCNT               ; Fetch the main loop counter

 EOR XSAV               ; Fetch the slot number of the ship we are moving, EOR
 AND #7                 ; with the loop counter and apply mod 8 to the result.
 BNE MV30               ; The result will be zero when "counter mod 8" matches
                        ; the slot number mod 8, so this makes sure we call
                        ; TACTICS 12 times every 8 main loop iterations, like
                        ; this:
                        ;
                        ;   Iteration 0, apply tactics to slots 0 and 8
                        ;   Iteration 1, apply tactics to slots 1 and 9
                        ;   Iteration 2, apply tactics to slots 2 and 10
                        ;   Iteration 3, apply tactics to slots 3 and 11
                        ;   Iteration 4, apply tactics to slot 4
                        ;   Iteration 5, apply tactics to slot 5
                        ;   Iteration 6, apply tactics to slot 6
                        ;   Iteration 7, apply tactics to slot 7
                        ;   Iteration 8, apply tactics to slots 0 and 8
                        ;     ...
                        ;
                        ; and so on

.MV26

 SETUP_PPU_FOR_ICON_BAR ; If the PPU has started drawing the icon bar, configure
                        ; the PPU to use nametable 0 and pattern table 0

 JSR TACTICS            ; Call TACTICS to apply AI tactics to this ship

.MV30

; ******************************************************************************
;
;       Name: MVEIT (Part 3 of 9)
;       Type: Subroutine
;   Category: Moving
;    Summary: Move current ship: Move ship forward according to its speed
;
; ------------------------------------------------------------------------------
;
; This routine has multiple stages. This stage does the following:
;
;   * Move the ship forward (along the vector pointing in the direction of
;     travel) according to its speed:
;
;     (x, y, z) += nosev_hi * speed / 64
;
; ******************************************************************************

 SETUP_PPU_FOR_ICON_BAR ; If the PPU has started drawing the icon bar, configure
                        ; the PPU to use nametable 0 and pattern table 0

 LDA INWK+27            ; Set Q = the ship's speed byte #27 * 4
 ASL A
 ASL A
 STA Q

 LDA INWK+10            ; Set A = |nosev_x_hi|
 AND #%01111111

 JSR FMLTU              ; Set R = A * Q / 256
 STA R                  ;       = |nosev_x_hi| * speed / 64

 LDA INWK+10            ; If nosev_x_hi is positive, then:
 LDX #0                 ;
 JSR MVT1-2             ;   (x_sign x_hi x_lo) = (x_sign x_hi x_lo) + R
                        ;
                        ; If nosev_x_hi is negative, then:
                        ;
                        ;   (x_sign x_hi x_lo) = (x_sign x_hi x_lo) - R
                        ;
                        ; So in effect, this does:
                        ;
                        ;   (x_sign x_hi x_lo) += nosev_x_hi * speed / 64

 LDA INWK+12            ; Set A = |nosev_y_hi|
 AND #%01111111

 JSR FMLTU              ; Set R = A * Q / 256
 STA R                  ;       = |nosev_y_hi| * speed / 64

 LDA INWK+12            ; If nosev_y_hi is positive, then:
 LDX #3                 ;
 JSR MVT1-2             ;   (y_sign y_hi y_lo) = (y_sign y_hi y_lo) + R
                        ;
                        ; If nosev_y_hi is negative, then:
                        ;
                        ;   (y_sign y_hi y_lo) = (y_sign y_hi y_lo) - R
                        ;
                        ; So in effect, this does:
                        ;
                        ;   (y_sign y_hi y_lo) += nosev_y_hi * speed / 64

 LDA INWK+14            ; Set A = |nosev_z_hi|
 AND #%01111111

 JSR FMLTU              ; Set R = A * Q / 256
 STA R                  ;       = |nosev_z_hi| * speed / 64

 SETUP_PPU_FOR_ICON_BAR ; If the PPU has started drawing the icon bar, configure
                        ; the PPU to use nametable 0 and pattern table 0

 LDA INWK+14            ; If nosev_y_hi is positive, then:
 LDX #6                 ;
 JSR MVT1-2             ;   (z_sign z_hi z_lo) = (z_sign z_hi z_lo) + R
                        ;
                        ; If nosev_z_hi is negative, then:
                        ;
                        ;   (z_sign z_hi z_lo) = (z_sign z_hi z_lo) - R
                        ;
                        ; So in effect, this does:
                        ;
                        ;   (z_sign z_hi z_lo) += nosev_z_hi * speed / 64

; ******************************************************************************
;
;       Name: MVEIT (Part 4 of 9)
;       Type: Subroutine
;   Category: Moving
;    Summary: Move current ship: Apply acceleration to ship's speed as a one-off
;
; ------------------------------------------------------------------------------
;
; This routine has multiple stages. This stage does the following:
;
;   * Apply acceleration to the ship's speed (if acceleration is non-zero),
;     and then zero the acceleration as it's a one-off change
;
; ******************************************************************************

 LDA INWK+27            ; Set A = the ship's speed in byte #24 + the ship's
 CLC                    ; acceleration in byte #28
 ADC INWK+28

 BPL P%+4               ; If the result is positive, skip the following
                        ; instruction

 LDA #0                 ; Set A to 0 to stop the speed from going negative

 STA INWK+27            ; Store the updated speed in byte #27

 LDY #15                ; Set A to byte #15 from the current ship blueprint,
 JSR GetShipBlueprint   ; which contains the ship's maximum speed

 CMP INWK+27            ; If A >= the ship's current speed, skip the following
 BCS P%+4               ; instruction as the speed is already in the correct
                        ; range

 STA INWK+27            ; Otherwise store the maximum speed in byte #27

 LDA #0                 ; We have added the ship's acceleration, so we now set
 STA INWK+28            ; it back to 0 in byte #28, as it's a one-off change

; ******************************************************************************
;
;       Name: MVEIT (Part 5 of 9)
;       Type: Subroutine
;   Category: Moving
;    Summary: Move current ship: Rotate ship's location by our pitch and roll
;  Deep dive: Rotating the universe
;
; ------------------------------------------------------------------------------
;
; This routine has multiple stages. This stage does the following:
;
;   * Rotate the ship's location in space by the amount of pitch and roll of
;     our ship. See below for a deeper explanation of this routine
;
; ******************************************************************************

 LDX ALP1               ; Fetch the magnitude of the current roll into X, so
                        ; if the roll angle is alpha, X contains |alpha|

 LDA INWK               ; Set P = ~x_lo (i.e. with all its bits flipped) so that
 EOR #%11111111         ; we can pass x_lo to MLTU2 below)
 STA P

 LDA INWK+1             ; Set A = x_hi

 JSR MLTU2-2            ; Set (A P+1 P) = (A ~P) * X
                        ;               = (x_hi x_lo) * alpha

 STA P+2                ; Store the high byte of the result in P+2, so we now
                        ; have:
                        ;
                        ; P(2 1 0) = (x_hi x_lo) * alpha

 LDA ALP2+1             ; Fetch the flipped sign of the current roll angle alpha
 EOR INWK+2             ; from ALP2+1 and EOR with byte #2 (x_sign), so if the
                        ; flipped roll angle and x_sign have the same sign, A
                        ; will be positive, else it will be negative. So A will
                        ; contain the sign bit of x_sign * flipped alpha sign,
                        ; which is the opposite to the sign of the above result,
                        ; so we now have:
                        ;
                        ; (A P+2 P+1) = - (x_sign x_hi x_lo) * alpha / 256

 LDX #3                 ; Set (A P+2 P+1) = (y_sign y_hi y_lo) + (A P+2 P+1)
 JSR MVT6               ;                 = y - x * alpha / 256

 STA K2+3               ; Set K2(3) = A = the sign of the result

 SETUP_PPU_FOR_ICON_BAR ; If the PPU has started drawing the icon bar, configure
                        ; the PPU to use nametable 0 and pattern table 0

 LDA P+1                ; Set K2(1) = P+1, the low byte of the result
 STA K2+1

 EOR #%11111111         ; Set P = ~K2+1 (i.e. with all its bits flipped) so
 STA P                  ; that we can pass K2+1 to MLTU2 below)

 LDA P+2                ; Set K2(2) = A = P+2
 STA K2+2

                        ; So we now have result 1 above:
                        ;
                        ; K2(3 2 1) = (A P+2 P+1)
                        ;           = y - x * alpha / 256

 LDX BET1               ; Fetch the magnitude of the current pitch into X, so
                        ; if the pitch angle is beta, X contains |beta|

 JSR MLTU2-2            ; Set (A P+1 P) = (A ~P) * X
                        ;               = K2(2 1) * beta

 STA P+2                ; Store the high byte of the result in P+2, so we now
                        ; have:
                        ;
                        ; P(2 1 0) = K2(2 1) * beta

 LDA K2+3               ; Fetch the sign of the above result in K(3 2 1) from
 EOR BET2               ; K2+3 and EOR with BET2, the sign of the current pitch
                        ; rate, so if the pitch and K(3 2 1) have the same sign,
                        ; A will be positive, else it will be negative. So A
                        ; will contain the sign bit of K(3 2 1) * beta, which is
                        ; the same as the sign of the above result, so we now
                        ; have:
                        ;
                        ; (A P+2 P+1) = K2(3 2 1) * beta / 256

 LDX #6                 ; Set (A P+2 P+1) = (z_sign z_hi z_lo) + (A P+2 P+1)
 JSR MVT6               ;                 = z + K2 * beta / 256

 STA INWK+8             ; Set z_sign = A = the sign of the result

 SETUP_PPU_FOR_ICON_BAR ; If the PPU has started drawing the icon bar, configure
                        ; the PPU to use nametable 0 and pattern table 0

 LDA P+1                ; Set z_lo = P+1, the low byte of the result
 STA INWK+6

 EOR #%11111111         ; Set P = ~z_lo (i.e. with all its bits flipped) so that
 STA P                  ; we can pass z_lo to MLTU2 below)

 LDA P+2                ; Set z_hi = P+2
 STA INWK+7

                        ; So we now have result 2 above:
                        ;
                        ; (z_sign z_hi z_lo) = (A P+2 P+1)
                        ;                    = z + K2 * beta / 256

 JSR MLTU2              ; MLTU2 doesn't change Q, and Q was set to beta in
                        ; the previous call to MLTU2, so this call does:
                        ;
                        ; (A P+1 P) = (A ~P) * Q
                        ;           = (z_hi z_lo) * beta

 STA P+2                ; Set P+2 = A = the high byte of the result, so we
                        ; now have:
                        ;
                        ; P(2 1 0) = (z_hi z_lo) * beta

 LDA K2+3               ; Set y_sign = K2+3
 STA INWK+5

 EOR BET2               ; EOR y_sign with BET2, the sign of the current pitch
 EOR INWK+8             ; rate, and z_sign. If the result is positive jump to
 BPL MV43               ; MV43, otherwise this means beta * z and y have
                        ; different signs, i.e. P(2 1) and K2(3 2 1) have
                        ; different signs, so we need to add them in order to
                        ; calculate K2(2 1) - P(2 1)

 LDA P+1                ; Set (y_hi y_lo) = K2(2 1) + P(2 1)
 ADC K2+1
 STA INWK+3
 LDA P+2
 ADC K2+2
 STA INWK+4

 JMP MV44               ; Jump to MV44 to continue the calculation

.MV43

 SETUP_PPU_FOR_ICON_BAR ; If the PPU has started drawing the icon bar, configure
                        ; the PPU to use nametable 0 and pattern table 0

 LDA K2+1               ; Reversing the logic above, we need to subtract P(2 1)
 SBC P+1                ; and K2(3 2 1) to calculate K2(2 1) - P(2 1), so this
 STA INWK+3             ; sets (y_hi y_lo) = K2(2 1) - P(2 1)
 LDA K2+2
 SBC P+2
 STA INWK+4

 BCS MV44               ; If the above subtraction did not underflow, then
                        ; jump to MV44, otherwise we need to negate the result

 LDA #1                 ; Negate (y_sign y_hi y_lo) using two's complement,
 SBC INWK+3             ; first doing the low bytes:
 STA INWK+3             ;
                        ; y_lo = 1 - y_lo

 LDA #0                 ; Then the high bytes:
 SBC INWK+4             ;
 STA INWK+4             ; y_hi = 0 - y_hi

 LDA INWK+5             ; And finally flip the sign in y_sign
 EOR #%10000000
 STA INWK+5

.MV44

 SETUP_PPU_FOR_ICON_BAR ; If the PPU has started drawing the icon bar, configure
                        ; the PPU to use nametable 0 and pattern table 0

                        ; So we now have result 3 above:
                        ;
                        ; (y_sign y_hi y_lo) = K2(2 1) - P(2 1)
                        ;                    = K2 - beta * z

 LDX ALP1               ; Fetch the magnitude of the current roll into X, so
                        ; if the roll angle is alpha, X contains |alpha|

 LDA INWK+3             ; Set P = ~y_lo (i.e. with all its bits flipped) so that
 EOR #$FF               ; we can pass y_lo to MLTU2 below)
 STA P

 LDA INWK+4             ; Set A = y_hi

 JSR MLTU2-2            ; Set (A P+1 P) = (A ~P) * X
                        ;               = (y_hi y_lo) * alpha

 STA P+2                ; Store the high byte of the result in P+2, so we now
                        ; have:
                        ;
                        ; P(2 1 0) = (y_hi y_lo) * alpha

 LDA ALP2               ; Fetch the correct sign of the current roll angle alpha
 EOR INWK+5             ; from ALP2 and EOR with byte #5 (y_sign), so if the
                        ; correct roll angle and y_sign have the same sign, A
                        ; will be positive, else it will be negative. So A will
                        ; contain the sign bit of x_sign * correct alpha sign,
                        ; which is the same as the sign of the above result,
                        ; so we now have:
                        ;
                        ; (A P+2 P+1) = (y_sign y_hi y_lo) * alpha / 256

 LDX #0                 ; Set (A P+2 P+1) = (x_sign x_hi x_lo) + (A P+2 P+1)
 JSR MVT6               ;                 = x + y * alpha / 256

 STA INWK+2             ; Set x_sign = A = the sign of the result

 LDA P+2                ; Set x_hi = P+2, the high byte of the result
 STA INWK+1

 LDA P+1                ; Set x_lo = P+1, the low byte of the result
 STA INWK

                        ; So we now have result 4 above:
                        ;
                        ; x = x + alpha * y
                        ;
                        ; and the rotation of (x, y, z) is done

; ******************************************************************************
;
;       Name: MVEIT (Part 6 of 9)
;       Type: Subroutine
;   Category: Moving
;    Summary: Move current ship: Move the ship in space according to our speed
;
; ------------------------------------------------------------------------------
;
; This routine has multiple stages. This stage does the following:
;
;   * Move the ship in space according to our speed (we already moved it
;     according to its own speed in part 3).
;
; We do this by subtracting our speed (i.e. the distance we travel in this
; iteration of the loop) from the other ship's z-coordinate. We subtract because
; they appear to be "moving" in the opposite direction to us, and the whole
; MVEIT routine is about moving the other ships rather than us (even though we
; are the one doing the moving).
;
; Other entry points:
;
;   MV45                Rejoin the MVEIT routine after the rotation, tactics and
;                       scanner code
;
; ******************************************************************************

.MV45

 SETUP_PPU_FOR_ICON_BAR ; If the PPU has started drawing the icon bar, configure
                        ; the PPU to use nametable 0 and pattern table 0

 LDA DELTA              ; Set R to our speed in DELTA
 STA R

 LDA #%10000000         ; Set A to zeroes but with bit 7 set, so that (A R) is
                        ; a 16-bit number containing -R, or -speed

 LDX #6                 ; Set X to the z-axis so the call to MVT1 does this:
 JSR MVT1               ;
                        ; (z_sign z_hi z_lo) = (z_sign z_hi z_lo) + (A R)
                        ;                    = (z_sign z_hi z_lo) - speed

 LDA TYPE               ; If the ship type is not the sun (129) then skip the
 AND #%10000001         ; next instruction, otherwise return from the subroutine
 CMP #129               ; as we don't need to rotate the sun around its origin.
 BNE P%+3               ; Having both the AND and the CMP is a little odd, as
                        ; the sun is the only ship type with bits 0 and 7 set,
                        ; so the AND has no effect and could be removed

 RTS                    ; Return from the subroutine, as the ship we are moving
                        ; is the sun and doesn't need any of the following

; ******************************************************************************
;
;       Name: MVEIT (Part 7 of 9)
;       Type: Subroutine
;   Category: Moving
;    Summary: Move current ship: Rotate ship's orientation vectors by pitch/roll
;  Deep dive: Orientation vectors
;             Pitching and rolling
;
; ------------------------------------------------------------------------------
;
; This routine has multiple stages. This stage does the following:
;
;   * Rotate the ship's orientation vectors according to our pitch and roll
;
; As with the previous step, this is all about moving the other ships rather
; than us (even though we are the one doing the moving). So we rotate the
; current ship's orientation vectors (which defines its orientation in space),
; by the angles we are "moving" the rest of the sky through (alpha and beta, our
; roll and pitch), so the ship appears to us to be stationary while we rotate.
;
; ******************************************************************************

 LDY #9                 ; Apply our pitch and roll rotations to the current
 JSR MVS4               ; ship's nosev vector

 LDY #15                ; Apply our pitch and roll rotations to the current
 JSR MVS4               ; ship's roofv vector

 LDY #21                ; Apply our pitch and roll rotations to the current
 JSR MVS4               ; ship's sidev vector

; ******************************************************************************
;
;       Name: MVEIT (Part 8 of 9)
;       Type: Subroutine
;   Category: Moving
;    Summary: Move current ship: Rotate ship about itself by its own pitch/roll
;  Deep dive: Orientation vectors
;             Pitching and rolling by a fixed angle
;
; ------------------------------------------------------------------------------
;
; This routine has multiple stages. This stage does the following:
;
;   * If the ship we are processing is rolling or pitching itself, rotate it and
;     apply damping if required
;
; ******************************************************************************

 LDA INWK+30            ; Fetch the ship's pitch counter and extract the sign
 AND #%10000000         ; into RAT2
 STA RAT2

 LDA INWK+30            ; Fetch the ship's pitch counter and extract the value
 AND #%01111111         ; without the sign bit into A

 BEQ MV8                ; If the pitch counter is 0, then jump to MV8 to skip
                        ; the following, as the ship is not pitching

 CMP #%01111111         ; If bits 0-6 are set in the pitch counter (i.e. the
                        ; ship's pitch is not damping down), then the C flag
                        ; will be set by this instruction

 SBC #0                 ; Set A = A - 0 - (1 - C), so if we are damping then we
                        ; reduce A by 1, otherwise it is unchanged

 ORA RAT2               ; Change bit 7 of A to the sign we saved in RAT2, so
                        ; the updated pitch counter in A retains its sign

 STA INWK+30            ; Store the updated pitch counter in byte #30

 LDX #15                ; Rotate (roofv_x, nosev_x) by a small angle (pitch)
 LDY #9
 JSR MVS5

 LDX #17                ; Rotate (roofv_y, nosev_y) by a small angle (pitch)
 LDY #11
 JSR MVS5

 LDX #19                ; Rotate (roofv_z, nosev_z) by a small angle (pitch)
 LDY #13
 JSR MVS5

.MV8

 SETUP_PPU_FOR_ICON_BAR ; If the PPU has started drawing the icon bar, configure
                        ; the PPU to use nametable 0 and pattern table 0

 LDA INWK+29            ; Fetch the ship's roll counter and extract the sign
 AND #%10000000         ; into RAT2
 STA RAT2

 LDA INWK+29            ; Fetch the ship's roll counter and extract the value
 AND #%01111111         ; without the sign bit into A

 BEQ MV5                ; If the roll counter is 0, then jump to MV5 to skip the
                        ; following, as the ship is not rolling

 CMP #%01111111         ; If bits 0-6 are set in the roll counter (i.e. the
                        ; ship's roll is not damping down), then the C flag
                        ; will be set by this instruction

 SBC #0                 ; Set A = A - 0 - (1 - C), so if we are damping then we
                        ; reduce A by 1, otherwise it is unchanged

 ORA RAT2               ; Change bit 7 of A to the sign we saved in RAT2, so
                        ; the updated roll counter in A retains its sign

 STA INWK+29            ; Store the updated pitch counter in byte #29

 LDX #15                ; Rotate (roofv_x, sidev_x) by a small angle (roll)
 LDY #21
 JSR MVS5

 LDX #17                ; Rotate (roofv_y, sidev_y) by a small angle (roll)
 LDY #23
 JSR MVS5

 LDX #19                ; Rotate (roofv_z, sidev_z) by a small angle (roll)
 LDY #25
 JSR MVS5

; ******************************************************************************
;
;       Name: MVEIT (Part 9 of 9)
;       Type: Subroutine
;   Category: Moving
;    Summary: Move current ship: Redraw on scanner, if it hasn't been destroyed
;
; ------------------------------------------------------------------------------
;
; This routine has multiple stages. This stage does the following:
;
;   * If the ship is exploding or being removed, hide it on the scanner
;
;   * Otherwise redraw the ship on the scanner, now that it's been moved
;
; ******************************************************************************

.MV5

 LDA INWK+31            ; Set bit 4 to keep the ship visible on the scanner
 ORA #%00010000
 STA INWK+31

 JMP SCAN_b1            ; Display the ship on the scanner, returning from the
                        ; subroutine using a tail call

; ******************************************************************************
;
;       Name: MVT1
;       Type: Subroutine
;   Category: Moving
;    Summary: Calculate (x_sign x_hi x_lo) = (x_sign x_hi x_lo) + (A R)
;
; ------------------------------------------------------------------------------
;
; Add the signed delta (A R) to a ship's coordinate, along the axis given in X.
; Mathematically speaking, this routine translates the ship along a single axis
; by a signed delta. Taking the example of X = 0, the x-axis, it does the
; following:
;
;   (x_sign x_hi x_lo) = (x_sign x_hi x_lo) + (A R)
;
; (In practice, MVT1 is only ever called directly with A = 0 or 128, otherwise
; it is always called via MVT-2, which clears A apart from the sign bit. The
; routine is written to cope with a non-zero delta_hi, so it supports a full
; 16-bit delta, but it appears that delta_hi is only ever used to hold the
; sign of the delta.)
;
; The comments below assume we are adding delta to the x-axis, though the axis
; is determined by the value of X.
;
; Arguments:
;
;   (A R)               The signed delta, so A = delta_hi and R = delta_lo
;
;   X                   Determines which coordinate axis of INWK to change:
;
;                         * X = 0 adds the delta to (x_lo, x_hi, x_sign)
;
;                         * X = 3 adds the delta to (y_lo, y_hi, y_sign)
;
;                         * X = 6 adds the delta to (z_lo, z_hi, z_sign)
;
; Other entry points:
;
;   MVT1-2              Clear bits 0-6 of A before entering MVT1
;
; ******************************************************************************

 AND #%10000000         ; Clear bits 0-6 of A

.MVT1

 ASL A                  ; Set the C flag to the sign bit of the delta, leaving
                        ; delta_hi << 1 in A

 STA S                  ; Set S = delta_hi << 1
                        ;
                        ; This also clears bit 0 of S

 LDA #0                 ; Set T = just the sign bit of delta (in bit 7)
 ROR A
 STA T

 LSR S                  ; Set S = delta_hi >> 1
                        ;       = |delta_hi|
                        ;
                        ; This also clear the C flag, as we know that bit 0 of
                        ; S was clear before the LSR

 EOR INWK+2,X           ; If T EOR x_sign has bit 7 set, then x_sign and delta
 BMI MV10               ; have different signs, so jump to MV10

                        ; At this point, we know x_sign and delta have the same
                        ; sign, that sign is in T, and S contains |delta_hi|,
                        ; so now we want to do:
                        ;
                        ;   (x_sign x_hi x_lo) = (x_sign x_hi x_lo) + (S R)
                        ;
                        ; and then set the sign of the result to the same sign
                        ; as x_sign and delta

 LDA R                  ; First we add the low bytes, so:
 ADC INWK,X             ;
 STA INWK,X             ;   x_lo = x_lo + R

 LDA S                  ; Then we add the high bytes:
 ADC INWK+1,X           ;
 STA INWK+1,X           ;   x_hi = x_hi + S

 LDA INWK+2,X           ; And finally we add any carry into x_sign, and if the
 ADC #0                 ; sign of x_sign and delta in T is negative, make sure
 ORA T                  ; the result is negative (by OR'ing with T)
 STA INWK+2,X

 RTS                    ; Return from the subroutine

.MV10

                        ; If we get here, we know x_sign and delta have
                        ; different signs, with delta's sign in T, and
                        ; |delta_hi| in S, so now we want to do:
                        ;
                        ;   (x_sign x_hi x_lo) = (x_sign x_hi x_lo) - (S R)
                        ;
                        ; and then set the sign of the result according to
                        ; the signs of x_sign and delta

 LDA INWK,X             ; First we subtract the low bytes, so:
 SEC                    ;
 SBC R                  ;   x_lo = x_lo - R
 STA INWK,X

 LDA INWK+1,X           ; Then we subtract the high bytes:
 SBC S                  ;
 STA INWK+1,X           ;   x_hi = x_hi - S

 LDA INWK+2,X           ; And finally we subtract any borrow from bits 0-6 of
 AND #%01111111         ; x_sign, and give the result the opposite sign bit to T
 SBC #0                 ; (i.e. give it the sign of the original x_sign)
 ORA #%10000000
 EOR T
 STA INWK+2,X

 BCS MV11               ; If the C flag is set by the above SBC, then our sum
                        ; above didn't underflow and is correct - to put it
                        ; another way, (x_sign x_hi x_lo) >= (S R) so the result
                        ; should indeed have the same sign as x_sign, so jump to
                        ; MV11 to return from the subroutine

                        ; Otherwise our subtraction underflowed because
                        ; (x_sign x_hi x_lo) < (S R), so we now need to flip the
                        ; subtraction around by using two's complement to this:
                        ;
                        ;   (S R) - (x_sign x_hi x_lo)
                        ;
                        ; and then we need to give the result the same sign as
                        ; (S R), the delta, as that's the dominant figure in the
                        ; sum

 LDA #1                 ; First we subtract the low bytes, so:
 SBC INWK,X             ;
 STA INWK,X             ;   x_lo = 1 - x_lo

 LDA #0                 ; Then we subtract the high bytes:
 SBC INWK+1,X           ;
 STA INWK+1,X           ;   x_hi = 0 - x_hi

 LDA #0                 ; And then we subtract the sign bytes:
 SBC INWK+2,X           ;
                        ;   x_sign = 0 - x_sign

 AND #%01111111         ; Finally, we set the sign bit to the sign in T, the
 ORA T                  ; sign of the original delta, as the delta is the
 STA INWK+2,X           ; dominant figure in the sum

.MV11

 RTS                    ; Return from the subroutine

; ******************************************************************************
;
;       Name: MVS4
;       Type: Subroutine
;   Category: Moving
;    Summary: Apply pitch and roll to an orientation vector
;  Deep dive: Orientation vectors
;             Pitching and rolling
;
; ------------------------------------------------------------------------------
;
; Apply pitch and roll angles alpha and beta to the orientation vector in Y.
;
; Specifically, this routine rotates a point (x, y, z) around the origin by
; pitch alpha and roll beta, using the small angle approximation to make the
; maths easier, and incorporating the Minsky circle algorithm to make the
; rotation more stable (though more elliptic).
;
; If that paragraph makes sense to you, then you should probably be writing
; this commentary! For the rest of us, there's a detailed explanation of all
; this in the deep dive on "Pitching and rolling".
;
; Arguments:
;
;   Y                   Determines which of the INWK orientation vectors to
;                       transform:
;
;                         * Y = 9 rotates nosev: (nosev_x, nosev_y, nosev_z)
;
;                         * Y = 15 rotates roofv: (roofv_x, roofv_y, roofv_z)
;
;                         * Y = 21 rotates sidev: (sidev_x, sidev_y, sidev_z)
;
; ******************************************************************************

.MVS4

 SETUP_PPU_FOR_ICON_BAR ; If the PPU has started drawing the icon bar, configure
                        ; the PPU to use nametable 0 and pattern table 0

 LDA ALPHA              ; Set Q = alpha (the roll angle to rotate through)
 STA Q

 LDX INWK+2,Y           ; Set (S R) = nosev_y
 STX R
 LDX INWK+3,Y
 STX S

 LDX INWK,Y             ; These instructions have no effect as MAD overwrites
 STX P                  ; X and P when called, but they set X = P = nosev_x_lo

 LDA INWK+1,Y           ; Set A = -nosev_x_hi
 EOR #%10000000

 JSR MAD                ; Set (A X) = Q * A + (S R)
 STA INWK+3,Y           ;           = alpha * -nosev_x_hi + nosev_y
 STX INWK+2,Y           ;
                        ; and store (A X) in nosev_y, so this does:
                        ;
                        ; nosev_y = nosev_y - alpha * nosev_x_hi

 STX P                  ; This instruction has no effect as MAD overwrites P,
                        ; but it sets P = nosev_y_lo

 LDX INWK,Y             ; Set (S R) = nosev_x
 STX R
 LDX INWK+1,Y
 STX S

 LDA INWK+3,Y           ; Set A = nosev_y_hi

 JSR MAD                ; Set (A X) = Q * A + (S R)
 STA INWK+1,Y           ;           = alpha * nosev_y_hi + nosev_x
 STX INWK,Y             ;
                        ; and store (A X) in nosev_x, so this does:
                        ;
                        ; nosev_x = nosev_x + alpha * nosev_y_hi

 STX P                  ; This instruction has no effect as MAD overwrites P,
                        ; but it sets P = nosev_x_lo

 SETUP_PPU_FOR_ICON_BAR ; If the PPU has started drawing the icon bar, configure
                        ; the PPU to use nametable 0 and pattern table 0

 LDA BETA               ; Set Q = beta (the pitch angle to rotate through)
 STA Q

 LDX INWK+2,Y           ; Set (S R) = nosev_y
 STX R
 LDX INWK+3,Y
 STX S
 LDX INWK+4,Y

 STX P                  ; This instruction has no effect as MAD overwrites P,
                        ; but it sets P = nosev_y

 LDA INWK+5,Y           ; Set A = -nosev_z_hi
 EOR #%10000000

 JSR MAD                ; Set (A X) = Q * A + (S R)
 STA INWK+3,Y           ;           = beta * -nosev_z_hi + nosev_y
 STX INWK+2,Y           ;
                        ; and store (A X) in nosev_y, so this does:
                        ;
                        ; nosev_y = nosev_y - beta * nosev_z_hi

 STX P                  ; This instruction has no effect as MAD overwrites P,
                        ; but it sets P = nosev_y_lo

 LDX INWK+4,Y           ; Set (S R) = nosev_z
 STX R
 LDX INWK+5,Y
 STX S

 LDA INWK+3,Y           ; Set A = nosev_y_hi

 JSR MAD                ; Set (A X) = Q * A + (S R)
 STA INWK+5,Y           ;           = beta * nosev_y_hi + nosev_z
 STX INWK+4,Y           ;
                        ; and store (A X) in nosev_z, so this does:
                        ;
                        ; nosev_z = nosev_z + beta * nosev_y_hi

 SETUP_PPU_FOR_ICON_BAR ; If the PPU has started drawing the icon bar, configure
                        ; the PPU to use nametable 0 and pattern table 0

 RTS                    ; Return from the subroutine

; ******************************************************************************
;
;       Name: MVT6
;       Type: Subroutine
;   Category: Moving
;    Summary: Calculate (A P+2 P+1) = (x_sign x_hi x_lo) + (A P+2 P+1)
;
; ------------------------------------------------------------------------------
;
; Do the following calculation, for the coordinate given by X (so this is what
; it does for the x-coordinate):
;
;   (A P+2 P+1) = (x_sign x_hi x_lo) + (A P+2 P+1)
;
; A is a sign bit and is not included in the calculation, but bits 0-6 of A are
; preserved. Bit 7 is set to the sign of the result.
;
; Arguments:
;
;   A                   The sign of P(2 1) in bit 7
;
;   P(2 1)              The 16-bit value we want to add the coordinate to
;
;   X                   The coordinate to add, as follows:
;
;                         * If X = 0, add to (x_sign x_hi x_lo)
;
;                         * If X = 3, add to (y_sign y_hi y_lo)
;
;                         * If X = 6, add to (z_sign z_hi z_lo)
;
; Returns:
;
;   A                   The sign of the result (in bit 7)
;
; ******************************************************************************

.MVT6

 TAY                    ; Store argument A into Y, for later use

 EOR INWK+2,X           ; Set A = A EOR x_sign

 BMI MV50               ; If the sign is negative, i.e. A and x_sign have
                        ; different signs, jump to MV50

                        ; The signs are the same, so we can add the two
                        ; arguments and keep the sign to get the result

 LDA P+1                ; First we add the low bytes:
 CLC                    ;
 ADC INWK,X             ;   P+1 = P+1 + x_lo
 STA P+1

 LDA P+2                ; And then the high bytes:
 ADC INWK+1,X           ;
 STA P+2                ;   P+2 = P+2 + x_hi

 TYA                    ; Restore the original A argument that we stored earlier
                        ; so that we keep the original sign

 RTS                    ; Return from the subroutine

.MV50

 LDA INWK,X             ; First we subtract the low bytes:
 SEC                    ;
 SBC P+1                ;   P+1 = x_lo - P+1
 STA P+1

 LDA INWK+1,X           ; And then the high bytes:
 SBC P+2                ;
 STA P+2                ;   P+2 = x_hi - P+2

 BCC MV51               ; If the last subtraction underflowed, then the C flag
                        ; will be clear and x_hi < P+2, so jump to MV51 to
                        ; negate the result

 TYA                    ; Restore the original A argument that we stored earlier
 EOR #%10000000         ; but flip bit 7, which flips the sign. We do this
                        ; because x_hi >= P+2 so we want the result to have the
                        ; same sign as x_hi (as it's the dominant side in this
                        ; calculation). The sign of x_hi is x_sign, and x_sign
                        ; has the opposite sign to A, so we flip the sign in A
                        ; to return the correct result

 RTS                    ; Return from the subroutine

.MV51

 LDA #1                 ; Our subtraction underflowed, so we negate the result
 SBC P+1                ; using two's complement, first with the low byte:
 STA P+1                ;
                        ;   P+1 = 1 - P+1

 LDA #0                 ; And then the high byte:
 SBC P+2                ;
 STA P+2                ;   P+2 = 0 - P+2

 TYA                    ; Restore the original A argument that we stored earlier
                        ; as this is the correct sign for the result. This is
                        ; because x_hi < P+2, so we want to return the same sign
                        ; as P+2, the dominant side

 RTS                    ; Return from the subroutine

; ******************************************************************************
;
;       Name: MV40
;       Type: Subroutine
;   Category: Moving
;
; ------------------------------------------------------------------------------
;
; We implement this using the same equations as in part 5 of MVEIT, where we
; rotated the current ship's location by our pitch and roll. Specifically, the
; calculation is as follows:
;
;   1. K2 = y - alpha * x
;   2. z = z + beta * K2
;   3. y = K2 - beta * z
;   4. x = x + alpha * y
;
; See the deep dive on "Rotating the universe" for more details on the above.
;
; ******************************************************************************

.MV40

 LDA ALPHA              ; Set Q = -ALPHA, so Q contains the angle we want to
 EOR #%10000000         ; roll the planet through (i.e. in the opposite
 STA Q                  ; direction to our ship's roll angle alpha)

 LDA INWK               ; Set P(1 0) = (x_hi x_lo)
 STA P
 LDA INWK+1
 STA P+1

 LDA INWK+2             ; Set A = x_sign

 JSR MULT3              ; Set K(3 2 1 0) = (A P+1 P) * Q
                        ;
                        ; which also means:
                        ;
                        ;   K(3 2 1) = (A P+1 P) * Q / 256
                        ;            = x * -alpha / 256
                        ;            = - alpha * x / 256

 LDX #3                 ; Set K(3 2 1) = (y_sign y_hi y_lo) + K(3 2 1)
 JSR MVT3               ;              = y - alpha * x / 256

 LDA K+1                ; Set K2(2 1) = P(1 0) = K(2 1)
 STA K2+1
 STA P

 LDA K+2                ; Set K2+2 = K+2
 STA K2+2

 STA P+1                ; Set P+1 = K+2

 LDA BETA               ; Set Q = beta, the pitch angle of our ship
 STA Q

 LDA K+3                ; Set K+3 to K2+3, so now we have result 1 above:
 STA K2+3               ;
                        ;   K2(3 2 1) = K(3 2 1)
                        ;             = y - alpha * x / 256

                        ; We also have:
                        ;
                        ;   A = K+3
                        ;
                        ;   P(1 0) = K(2 1)
                        ;
                        ; so combined, these mean:
                        ;
                        ;   (A P+1 P) = K(3 2 1)
                        ;             = K2(3 2 1)

 JSR MULT3              ; Set K(3 2 1 0) = (A P+1 P) * Q
                        ;
                        ; which also means:
                        ;
                        ;   K(3 2 1) = (A P+1 P) * Q / 256
                        ;            = K2(3 2 1) * beta / 256
                        ;            = beta * K2 / 256

 LDX #6                 ; K(3 2 1) = (z_sign z_hi z_lo) + K(3 2 1)
 JSR MVT3               ;          = z + beta * K2 / 256

 LDA K+1                ; Set P = K+1
 STA P

 STA INWK+6             ; Set z_lo = K+1

 LDA K+2                ; Set P+1 = K+2
 STA P+1

 STA INWK+7             ; Set z_hi = K+2

 LDA K+3                ; Set A = z_sign = K+3, so now we have:
 STA INWK+8             ;
                        ;   (z_sign z_hi z_lo) = K(3 2 1)
                        ;                      = z + beta * K2 / 256

                        ; So we now have result 2 above:
                        ;
                        ;   z = z + beta * K2

 EOR #%10000000         ; Flip the sign bit of A to give A = -z_sign

 JSR MULT3              ; Set K(3 2 1 0) = (A P+1 P) * Q
                        ;                = (-z_sign z_hi z_lo) * beta
                        ;                = -z * beta

 LDA K+3                ; Set T to the sign bit of K(3 2 1 0), i.e. to the sign
 AND #%10000000         ; bit of -z * beta
 STA T

 EOR K2+3               ; If K2(3 2 1 0) has a different sign to K(3 2 1 0),
 BMI MV1                ; then EOR'ing them will produce a 1 in bit 7, so jump
                        ; to MV1 to take this into account

                        ; If we get here, K and K2 have the same sign, so we can
                        ; add them together to get the result we're after, and
                        ; then set the sign afterwards

 LDA K                  ; We now do the following sum:
 CLC                    ;
 ADC K2                 ;   (A y_hi y_lo -) = K(3 2 1 0) + K2(3 2 1 0)
                        ;
                        ; starting with the low bytes (which we don't keep)
                        ;
                        ; The CLC has no effect because MULT3 clears the C
                        ; flag, so this instruction could be removed (as it is
                        ; in the cassette version, for example)

 LDA K+1                ; We then do the middle bytes, which go into y_lo
 ADC K2+1
 STA INWK+3

 LDA K+2                ; And then the high bytes, which go into y_hi
 ADC K2+2
 STA INWK+4

 LDA K+3                ; And then the sign bytes into A, so overall we have the
 ADC K2+3               ; following, if we drop the low bytes from the result:
                        ;
                        ;   (A y_hi y_lo) = (K + K2) / 256

 JMP MV2                ; Jump to MV2 to skip the calculation for when K and K2
                        ; have different signs

.MV1

 LDA K                  ; If we get here then K2 and K have different signs, so
 SEC                    ; instead of adding, we need to subtract to get the
 SBC K2                 ; result we want, like this:
                        ;
                        ;   (A y_hi y_lo -) = K(3 2 1 0) - K2(3 2 1 0)
                        ;
                        ; starting with the low bytes (which we don't keep)

 LDA K+1                ; We then do the middle bytes, which go into y_lo
 SBC K2+1
 STA INWK+3

 LDA K+2                ; And then the high bytes, which go into y_hi
 SBC K2+2
 STA INWK+4

 LDA K2+3               ; Now for the sign bytes, so first we extract the sign
 AND #%01111111         ; byte from K2 without the sign bit, so P = |K2+3|
 STA P

 LDA K+3                ; And then we extract the sign byte from K without the
 AND #%01111111         ; sign bit, so A = |K+3|

 SBC P                  ; And finally we subtract the sign bytes, so P = A - P
 STA P

                        ; By now we have the following, if we drop the low bytes
                        ; from the result:
                        ;
                        ;   (A y_hi y_lo) = (K - K2) / 256
                        ;
                        ; so now we just need to make sure the sign of the
                        ; result is correct

 BCS MV2                ; If the C flag is set, then the last subtraction above
                        ; didn't underflow and the result is correct, so jump to
                        ; MV2 as we are done with this particular stage

 LDA #1                 ; Otherwise the subtraction above underflowed, as K2 is
 SBC INWK+3             ; the dominant part of the subtraction, so we need to
 STA INWK+3             ; negate the result using two's complement, starting
                        ; with the low bytes:
                        ;
                        ;   y_lo = 1 - y_lo

 LDA #0                 ; And then the high bytes:
 SBC INWK+4             ;
 STA INWK+4             ;   y_hi = 0 - y_hi

 LDA #0                 ; And finally the sign bytes:
 SBC P                  ;
                        ;   A = 0 - P

 ORA #%10000000         ; We now force the sign bit to be negative, so that the
                        ; final result below gets the opposite sign to K, which
                        ; we want as K2 is the dominant part of the sum

.MV2

 EOR T                  ; T contains the sign bit of K, so if K is negative,
                        ; this flips the sign of A

 STA INWK+5             ; Store A in y_sign

                        ; So we now have result 3 above:
                        ;
                        ;   y = K2 + K
                        ;     = K2 - beta * z

 LDA ALPHA              ; Set A = alpha
 STA Q

 LDA INWK+3             ; Set P(1 0) = (y_hi y_lo)
 STA P
 LDA INWK+4
 STA P+1

 LDA INWK+5             ; Set A = y_sign

 JSR MULT3              ; Set K(3 2 1 0) = (A P+1 P) * Q
                        ;                = (y_sign y_hi y_lo) * alpha
                        ;                = y * alpha

 LDX #0                 ; Set K(3 2 1) = (x_sign x_hi x_lo) + K(3 2 1)
 JSR MVT3               ;              = x + y * alpha / 256

 LDA K+1                ; Set (x_sign x_hi x_lo) = K(3 2 1)
 STA INWK               ;                        = x + y * alpha / 256
 LDA K+2
 STA INWK+1
 LDA K+3
 STA INWK+2

                        ; So we now have result 4 above:
                        ;
                        ;   x = x + y * alpha

 JMP MV45               ; We have now finished rotating the planet or sun by
                        ; our pitch and roll, so jump back into the MVEIT
                        ; routine at MV45 to apply all the other movements

; ******************************************************************************
;
;       Name: PLUT
;       Type: Subroutine
;   Category: Flight
;    Summary: Flip the coordinate axes for the four different views
;  Deep dive: Flipping axes between space views
;
; ------------------------------------------------------------------------------
;
; This routine flips the relevant geometric axes in INWK depending on which
; view we are looking through (front, rear, left, right).
;
; ******************************************************************************

.PLUT

 LDX VIEW               ; Load the current view into X:
                        ;
                        ;   0 = front
                        ;   1 = rear
                        ;   2 = left
                        ;   3 = right

 BEQ PU2-1              ; If the current view is the front view, return from the
                        ; subroutine (PU2-1 contains an RTS), as the geometry in
                        ; INWK is already correct

.PU1

 DEX                    ; Decrement the view, so now:
                        ;
                        ;   0 = rear
                        ;   1 = left
                        ;   2 = right

 BNE PU2                ; If the current view is left or right, jump to PU2,
                        ; otherwise this is the rear view, so continue on

 LDA INWK+2             ; Flip the sign of x_sign
 EOR #%10000000
 STA INWK+2

 LDA INWK+8             ; Flip the sign of z_sign
 EOR #%10000000
 STA INWK+8

 LDA INWK+10            ; Flip the sign of nosev_x_hi
 EOR #%10000000
 STA INWK+10

 LDA INWK+14            ; Flip the sign of nosev_z_hi
 EOR #%10000000
 STA INWK+14

 LDA INWK+16            ; Flip the sign of roofv_x_hi
 EOR #%10000000
 STA INWK+16

 LDA INWK+20            ; Flip the sign of roofv_z_hi
 EOR #%10000000
 STA INWK+20

 LDA INWK+22            ; Flip the sign of sidev_x_hi
 EOR #%10000000
 STA INWK+22

 LDA INWK+26            ; Flip the sign of roofv_z_hi
 EOR #%10000000
 STA INWK+26

 RTS                    ; Return from the subroutine

.PU2

                        ; We enter this with X set to the view, as follows:
                        ;
                        ;   1 = left
                        ;   2 = right

 LDA #0                 ; Set RAT2 = 0 (left view) or -1 (right view)
 CPX #2
 ROR A
 STA RAT2

 EOR #%10000000         ; Set RAT = -1 (left view) or 0 (right view)
 STA RAT

 LDA INWK               ; Swap x_lo and z_lo
 LDX INWK+6
 STA INWK+6
 STX INWK

 LDA INWK+1             ; Swap x_hi and z_hi
 LDX INWK+7
 STA INWK+7
 STX INWK+1

 LDA INWK+2             ; Swap x_sign and z_sign
 EOR RAT                ; If left view, flip sign of new z_sign
 TAX                    ; If right view, flip sign of new x_sign
 LDA INWK+8
 EOR RAT2
 STA INWK+2
 STX INWK+8

 LDY #9                 ; Swap nosev_x_lo and nosev_z_lo
 JSR PUS1               ; Swap nosev_x_hi and nosev_z_hi
                        ; If left view, flip sign of new nosev_z_hi
                        ; If right view, flip sign of new nosev_x_hi

 LDY #15                ; Swap roofv_x_lo and roofv_z_lo
 JSR PUS1               ; Swap roofv_x_hi and roofv_z_hi
                        ; If left view, flip sign of new roofv_z_hi
                        ; If right view, flip sign of new roofv_x_hi

 LDY #21                ; Swap sidev_x_lo and sidev_z_lo
                        ; Swap sidev_x_hi and sidev_z_hi
                        ; If left view, flip sign of new sidev_z_hi
                        ; If right view, flip sign of new sidev_x_hi

.PUS1

 LDA INWK,Y             ; Swap the low x and z bytes for the vector in Y:
 LDX INWK+4,Y           ;
 STA INWK+4,Y           ;   * For Y =  9 swap nosev_x_lo and nosev_z_lo
 STX INWK,Y             ;   * For Y = 15 swap roofv_x_lo and roofv_z_lo
                        ;   * For Y = 21 swap sidev_x_lo and sidev_z_lo

 LDA INWK+1,Y           ; Swap the high x and z bytes for the offset in Y:
 EOR RAT                ;
 TAX                    ;   * If left view, flip sign of new z-coordinate
 LDA INWK+5,Y           ;   * If right view, flip sign of new x-coordinate
 EOR RAT2
 STA INWK+1,Y
 STX INWK+5,Y

                        ; Fall through into LOOK1 to return from the subroutine

; ******************************************************************************
;
;       Name: LOOK1
;       Type: Subroutine
;   Category: Flight
;    Summary: Initialise the space view
;
; ------------------------------------------------------------------------------
;
; Initialise the space view, with the direction of view given in X. This clears
; the upper screen and draws the laser crosshairs, if the view in X has lasers
; fitted. It also wipes all the ships from the scanner, so we can recalculate
; ship positions for the new view (they get put back in the main flight loop).
;
; Arguments:
;
;   X                   The space view to set:
;
;                         * 0 = front
;                         * 1 = rear
;                         * 2 = left
;                         * 3 = right
;
; Other entry points:
;
;   LO2                 Contains an RTS
;
; ******************************************************************************

.LO2

 RTS                    ; Return from the subroutine

.LQ

 JSR SendSpaceViewToPPU ; ???

 JMP NWSTARS            ; Set up a new stardust field and return from the
                        ; subroutine using a tail call

.LOOK1

 LDA #0                 ; Set A = 0, the type number of a space view

 LDY QQ11               ; If the current view is not a space view, jump up to LQ
 BNE LQ                 ; to set up a new space view

 CPX VIEW               ; If the current view is already of type X, jump to LO2
 BEQ LO2                ; to return from the subroutine (as LO2 contains an RTS)

 JSR SetSpaceViewInNMI  ; ???

 JSR FLIP               ; Swap the x- and y-coordinates of all the stardust
                        ; particles and redraw the stardust field

 JMP WaitForNMI         ; ???

; ******************************************************************************
;
;       Name: FLIP
;       Type: Subroutine
;   Category: Stardust
;    Summary: Reflect the stardust particles in the screen diagonal
;
; ------------------------------------------------------------------------------
;
; Swap the x- and y-coordinates of all the stardust particles. Called by LOOK1
; when we switch views.
;
; This is a quick way of making the stardust field in the new view feel
; different without having to generate a whole new field. If you look carefully
; at the stardust field when you switch views, you can just about see that the
; new field is a reflection of the previous field in the screen diagonal, i.e.
; in the line from bottom left to top right. This is the line where x = y when
; the origin is in the middle of the screen, and positive x and y are right and
; up, which is the coordinate system we use for stardust).
;
; ******************************************************************************

.FLIP

 LDY NOSTM              ; Set Y to the current number of stardust particles, so
                        ; we can use it as a counter through all the stardust

.FLL1

 SETUP_PPU_FOR_ICON_BAR ; If the PPU has started drawing the icon bar, configure
                        ; the PPU to use nametable 0 and pattern table 0

 LDX SY,Y               ; Copy the Y-th particle's y-coordinate from SY+Y into X

 LDA SX,Y               ; Copy the Y-th particle's x-coordinate from SX+Y into
 STA SY,Y               ; the particle's y-coordinate

 TXA                    ; Copy the Y-th particle's original y-coordinate into
 STA SX,Y               ; the particle's x-coordinate, so the x- and
                        ; y-coordinates are now swapped

 LDA SZ,Y               ; Fetch the Y-th particle's distance from SZ+Y into ZZ
 STA ZZ

 DEY                    ; Decrement the counter to point to the next particle of
                        ; stardust

 BNE FLL1               ; Loop back to FLL1 until we have moved all the stardust
                        ; particles

 RTS                    ; Return from the subroutine

; ******************************************************************************
;
;       Name: SendSpaceViewToPPU
;       Type: Subroutine
;   Category: PPU
;    Summary: ???
;
; ------------------------------------------------------------------------------
;
; Arguments:
;
;   X                   The space view to set:
;
;                         * 0 = front
;
;                         * 1 = rear
;
;                         * 2 = left
;
;                         * 3 = right
;
;                         * 4 = generating a new space view
;
; ******************************************************************************

.SendSpaceViewToPPU

 LDA #72                ; Set the screen height variables for a screen height of
 JSR SetScreenHeight    ; 144 (i.e. 2 * 72)

 STX VIEW               ; Set the current space view to X

 LDA #$00               ; Clear the screen and and set the view type in QQ11 to
 JSR TT66               ; $00 (Space view with no fonts loaded)

 JSR CopyNameBuffer0To1 ; Copy the contents of nametable buffer 0 to nametable
                        ; buffer and tell the NMI handler to send pattern
                        ; entries up to the first free tile

 JSR SendViewToPPU_b3   ; Configure the PPU for the view type in QQ11

 JMP ResetStardust      ; Hide the sprites for the stardust and return from the
                        ; subroutine using a tail call

; ******************************************************************************
;
;       Name: SetSpaceViewInNMI
;       Type: Subroutine
;   Category: Drawing the screen
;    Summary: Set the current space view and configure the NMI to send both
;             bitplanes to the PPU during VBlank
;
; ------------------------------------------------------------------------------
;
; Arguments:
;
;   X                   The space view to set:
;
;                         * 0 = front
;
;                         * 1 = rear
;
;                         * 2 = left
;
;                         * 3 = right
;
;                         * 4 = generating a new space view
;
; ******************************************************************************

.SetSpaceViewInNMI

 STX VIEW               ; Set the current space view to X

 LDA #$00               ; Clear the screen and and set the view type in QQ11 to
 JSR TT66               ; $00 (Space view with no fonts loaded)

 JSR CopyNameBuffer0To1 ; Copy the contents of nametable buffer 0 to nametable
                        ; buffer and tell the NMI handler to send pattern
                        ; entries up to the first free tile

 LDA #80                ; Tell the PPU to send nametable entries up to tile
 STA lastNameTile       ; 80 * 8 = 640 (i.e. to the end of tile row 19) in both
 STA lastNameTile+1     ; bitplanes

 JSR SetupViewInNMI_b3  ; Setup the view and configure the NMI to send both
                        ; bitplanes to the PPU during VBlank

                        ; Fall through into ResetStardust to hide the sprites
                        ; for the stardust

; ******************************************************************************
;
;       Name: ResetStardust
;       Type: Subroutine
;   Category: Stardust
;    Summary: Hide the sprites for the stardust
;
; ******************************************************************************

.ResetStardust

 LDX #NOST              ; Set X to the maximum number of stardust particles, so
                        ; we loop through all the particles of stardust in the
                        ; following, hiding them all

 LDY #152               ; Set Y to the starting index in the sprite buffer, so
                        ; we start hiding from sprite 152 / 4 = 38 (as each
                        ; sprite in the buffer consists of four bytes)

.rest1

 SETUP_PPU_FOR_ICON_BAR ; If the PPU has started drawing the icon bar, configure
                        ; the PPU to use nametable 0 and pattern table 0

 LDA #240               ; Set A to the y-coordinate that's just below the bottom
                        ; of the screen, so we can hide the required sprites by
                        ; moving them off-screen

 STA ySprite0,Y         ; Set the y-coordinate for sprite Y / 4 to 240 to hide
                        ; it (the division by four is because each sprite in the
                        ; sprite buffer has four bytes of data)

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

 BNE rest1              ; Loop back until we have hidden X sprites

 JSR WaitForNMI         ; Wait until the next NMI interrupt has passed (i.e. the
                        ; next VBlank)

 JSR SIGHT_b3           ; Draw the laser crosshairs

                        ; Fall through into SetupSpaceView to finish setting up
                        ; the space view's NMI configuration

; ******************************************************************************
;
;       Name: SetupSpaceView
;       Type: Subroutine
;   Category: Drawing the screen
;    Summary: Set up the NMI variables for the space view
;
; ******************************************************************************

.SetupSpaceView

 LDA #$FF               ; Set showIconBarPointer = $FF to indicate that we
 STA showIconBarPointer ; should show the icon bar pointer

 LDA #$2C               ; Set the visible colour to cyan ($2C)
 STA visibleColour

 LDA firstFreeTile      ; Tell the NMI handler to send pattern entries from the
 STA firstPatternTile   ; first free tile onwards, so we don't waste time
                        ; resending the static tiles we have already sent

 LDA #80                ; Tell the NMI handler to only clear nametable entries
 STA maxNameTileToClear ; up to tile 80 * 8 = 640 (i.e. up to the end of tile
                        ; row 19)

 LDX #8                 ; Tell the NMI handler to send nametable entries from
 STX firstNametableTile ; tile 8 * 8 = 64 onwards (i.e. from the start of tile
                        ; row 2)

 LDA #116               ; Tell the NMI handler to send nametable entries up to
 STA lastNameTile       ; tile 116 * 8 = 800 (i.e. up to the end of tile row 28)
                        ; in bitplane 0

 RTS                    ; Return from the subroutine

; ******************************************************************************
;
;       Name: ECMOF
;       Type: Subroutine
;   Category: Sound
;    Summary: Switch off the E.C.M.
;
; ------------------------------------------------------------------------------
;
; Switch the E.C.M. off, turn off the dashboard bulb and make the sound of the
; E.C.M. switching off).
;
; ******************************************************************************

.ECMOF

 LDA #0                 ; Set ECMA and ECMP to 0 to indicate that no E.C.M. is
 STA ECMA               ; currently running
 STA ECMP

 LDY #2                 ; Flush the sound channels for sound Y = 2 to stop the
 JMP FlushSpecificSound ; sound of the E.C.M. and return from the subroutine
                        ; using a tail call

; ******************************************************************************
;
;       Name: SFRMIS
;       Type: Subroutine
;   Category: Tactics
;    Summary: Add an enemy missile to our local bubble of universe
;
; ------------------------------------------------------------------------------
;
; An enemy has fired a missile, so add the missile to our universe if there is
; room, and if there is, make the appropriate warnings and noises.
;
; ******************************************************************************

.SFRMIS

 LDX #MSL               ; Set X to the ship type of a missile, and call SFS1-2
 JSR SFS1-2             ; to add the missile to our universe with an AI flag
                        ; of %11111110 (AI enabled, hostile, no E.C.M.)

 BCC sfrm1              ; The C flag will be set if the call to SFS1-2 was a
                        ; success, so if it's clear, jump to sfrm1 to return
                        ; from the subroutine

 LDA #120               ; Print recursive token 120 ("INCOMING MISSILE") as an
 JSR MESS               ; in-flight message

 LDY #9                 ; Call the NOISE routine with Y = 9 to make the sound
 JMP NOISE              ; of the missile being launched and return from the
                        ; subroutine using a tail call

.sfrm1

 RTS                    ; Return from the subroutine

; ******************************************************************************
;
;       Name: EXNO2
;       Type: Subroutine
;   Category: Status
;    Summary: Process us making a kill
;  Deep dive: Combat rank
;
; ------------------------------------------------------------------------------
;
; We have killed a ship, so increase the kill tally, displaying an iconic
; message of encouragement if the kill total is a multiple of 256, and then
; make a nearby explosion sound.
;
;
; ******************************************************************************

.EXNO2

 JSR IncreaseTally      ; Add double the fractional kill count to the fractional
                        ; and low bytes of our tally, setting the C flag if the
                        ; addition overflowed

 BCC davidscockup       ; If there is no carry, jump straight to EXNO3 to skip
                        ; the following three instructions

 INC TALLY+1            ; Increment the high byte of the kill count in TALLY

 LDA #101               ; The kill total is a multiple of 256, so it's time
 JSR MESS               ; for a pat on the back, so print recursive token 101
                        ; ("RIGHT ON COMMANDER!") as an in-flight message

.davidscockup

 LDA INWK+7             ; Fetch z_hi, the distance of the ship being hit in
                        ; terms of the z-axis (in and out of the screen)

 LDX #0                 ; We now set X to a number between 0 and 4 depending on
                        ; the z-axis distance to the exploding ship, with 0
                        ; for distant ships and 4 for close ships

 CMP #16                ; If z_hi >= 16, jump to exno1 with X = 0
 BCS exno1

 INX                    ; Increment X to 1

 CMP #8                 ; If z_hi >= 8, jump to exno1 with X = 1
 BCS exno1

 INX                    ; Increment X to 2

 CMP #6                 ; If z_hi >= 6, jump to exno1 with X = 2
 BCS exno1

 INX                    ; Increment X to 3

 CMP #3                 ; If z_hi >= 3, jump to exno1 with X = 3
 BCS exno1

 INX                    ; Increment X to 4

.exno1

 LDY explosionNoises,X  ; Set Y to the X-th noise number from the table of
                        ; explosion noise numbers

 JMP NOISE              ; Call the NOISE routine to make the sound in Y, which
                        ; will be the sound of a ship exploding at the specified
                        ; distance, returning from the subroutine using a tail
                        ; call

; ******************************************************************************
;
;       Name: explosionNoises
;       Type: Variable
;   Category: Sound
;    Summary: Sound numbers for explosions at different distances from our ship
;
; ******************************************************************************

.explosionNoises

 EQUB 27                ; Ship explosion at a distance of z_hi >= 16

 EQUB 23                ; Ship explosion at a distance of z_hi >=8

 EQUB 14                ; Ship explosion at a distance of z_hi >= 6

 EQUB 13                ; Ship explosion at a distance of z_hi >= 3

 EQUB 13                ; Nearby ship explosion

; ******************************************************************************
;
;       Name: EXNO
;       Type: Subroutine
;   Category: Sound
;    Summary: Make the sound of a laser strike or ship explosion
;
; ------------------------------------------------------------------------------
;
; Make the two-part explosion sound of us making a laser strike, or of another
; ship exploding.
;
; Other entry points:
;
;   EXNO-2              Set X = 7 and fall through into EXNO to make the sound
;                       of a ship exploding
;
; ******************************************************************************

.EXNO

 LDY #10                ; Call the NOISE routine with Y = 10 to make the sound
 JMP NOISE              ; of us making a hit or kill and return from the
                        ; subroutine using a tail call

; ******************************************************************************
;
;       Name: TT66
;       Type: Subroutine
;   Category: Drawing the screen
;    Summary: Clear the screen and set the new view type
;
; ------------------------------------------------------------------------------
;
; This routine does a similar job to the routine of the same name in the BBC
; Master version of Elite, but the code is significantly different.
;
; Arguments:
;
;   A                   The type of the new view (see QQ11 for a list of view
;                       types)
;
; ******************************************************************************

.TT66

 STA QQ11               ; Set the new view type in QQ11 to A

 LDA QQ11a              ; If bit 7 is set in either QQ11 or QQ11a, then either
 ORA QQ11               ; there is no dashboard in either view, or it is being
 BMI scrn1              ; added or removed, so jump to scrn1 to skip clearing
                        ; the existing scanner, as we don't need to worry about
                        ; preserving it

 LDA QQ11               ; If bit 7 of QQ11 is clear, then bit 7 must be clear in
 BPL scrn1              ; both QQ11 and QQ11a as we didn't take the branch
                        ; above, so we are switching between views that both
                        ; have dashboards, so jump to scrn1 to skip clearing the
                        ; scanner as we want to retain it

                        ; Strangely, we can never get here, as we take the first
                        ; branch above when bit 7 of QQ11 is set, and we take
                        ; the second branch when bit 7 of QQ11 is clear

 JSR ClearScanner       ; Remove all ships from the scanner and hide the scanner
                        ; sprites

.scrn1

 JSR WaitForPPUToFinish ; Wait until both bitplanes of the screen have been
                        ; sent to the PPU, so the screen is fully updated and
                        ; there is no more data waiting to be sent to the PPU

 JSR ClearScreen_b3     ; Clear the screen by zeroing patterns 66 to 255 in
                        ; both pattern buffer, and clearing both nametable
                        ; buffers to the background tile

 LDA #16                ; Set the text row for in-flight messages in the space
 STA messYC             ; view to row 16

 LDX #0                 ; Set flipEveryBitplane0 = 0 ???
 STX flipEveryBitplane0

 JSR SetDrawingBitplane ; Set the drawing bitplane to bitplane 0

 LDA #%10000000         ; Set bit 7 of QQ17 to switch to Sentence Case
 STA QQ17

 STA DTW2               ; Set bit 7 of DTW2 to indicate we are not currently
                        ; printing a word

 STA DTW1               ; Set bit 7 of DTW1 to indicate that we do not change
                        ; case to lower case

 LDA #%00000000         ; Set DTW6 = %00000000 to disable lower case
 STA DTW6

 STA LAS2               ; Set LAS2 = 0 to stop any laser pulsing

 STA DLY                ; Set the delay in DLY to 0, to indicate that we are
                        ; no longer showing an in-flight message, so any new
                        ; in-flight messages will be shown instantly

 STA de                 ; Clear de, the flag that appends " DESTROYED" to the
                        ; end of the next text token, so that it doesn't

 LDA #1                 ; Move the text cursor to column 1 on row 1
 STA XC
 STA YC

 JSR SetLinePatterns_b3 ; Load the line patterns for the new view into the
                        ; pattern buffers

                        ; We now set X to the type of icon bar to show in the
                        ; new view

 LDA QQ11               ; If bit 6 of the new view in QQ11 is set then it
 LDX #$FF               ; doesn't have an icon bar, so jump to scrn2 with
 AND #%01000000         ; X = $FF to hide the icon bar on row 27
 BNE scrn2

 LDX #4                 ; If the new view in QQ11 is 1, then we are on the title
 LDA QQ11               ; screen, so jump to scrn2 with X = 4 so we show the
 CMP #1                 ; copyright message in the icon bar
 BEQ scrn2

 LDX #2                 ; If the new view in QQ11 is %0000110x (i.e. 12 or 13,
 LDA QQ11               ; which are the Short-range Chart and Long-range Chart),
 AND #%00001110         ; jump to scrn2 with X = 2 to show the icon bar for the
 CMP #%00001100         ; charts
 BEQ scrn2

 LDX #1                 ; If we are not docked (QQ12 = 0), jump to scrn2 with
 LDA QQ12               ; X = 1 to show the flight icon bar
 BEQ scrn2

 LDX #0                 ; Otherwise fall through into scrn2 with X = 0 to show
                        ; the docked icon bar

.scrn2

 LDA QQ11               ; If bit 7 of the new view in QQ11 is set then there is
 BMI scrn5              ; no dashboard, so jump to scrn5 to show the icon bar
                        ; type with type X on row 27

                        ; If we get here then the new view has the dashboard, so
                        ; we initialise it if required

 TXA                    ; Show the icon bar with type X
 JSR SetupIconBar_b3

 LDA QQ11a              ; If bit 7 of the old view in QQ11a is clear, then the
 BPL scrn3              ; old view has a dashboard, so jump to scrn3 to skip the
                        ; following two instructions, as we don't need to
                        ; initialise the dashboard

 JSR SetScreenForUpdate ; Get the screen ready for updating by hiding all
                        ; sprites, after fading the screen to black if we are
                        ; changing view

 JSR ResetScanner_b3    ; Reset the sprites used for drawing ships on the
                        ; scanner

.scrn3

 JSR DrawDashNames_b3   ; Draw the dashboard into the nametable buffers for
                        ; both bitplanes

 JSR msblob             ; Display the dashboard's missile indicators in black

 JMP scrn8              ; Jump to scrn8 to continue setting up the view

.scrn4

 JMP SetViewAttrs_b3    ; Set up attribute buffer 0 for the chosen view,
                        ; returning from the subroutine using a tail call

.scrn5

                        ; If we get here then there is no dashboard in the new
                        ; view

 TXA                    ; Show the icon bar with type X
 JSR SetupIconBar_b3

                        ; The next two comparisons aren't necessary as both $C4
                        ; and $8D have bit 4 clear, so they would be caught by
                        ; the AND #%00010000 below anyway, but there's no harm
                        ; in being explicit, I guess

 LDA QQ11               ; If the view type in QQ11 is $C4 (Game Over screen),
 CMP #$C4               ; jump to scrn4 to set up attribute buffer 0 and
 BEQ scrn4              ; return from the subroutine

 LDA QQ11               ; If the view type in QQ11 is $8D (Long-range Chart),
 CMP #$8D               ; jump to scrn6 to skip loading the font into pattern
 BEQ scrn6              ; buffer 0

 CMP #$CF               ; If the view type in QQ11 is $CF (Start screen with
 BEQ scrn6              ; no fonts loaded), jump to scrn6 to skip loading
                        ; the font into pattern buffer 0

 AND #%00010000         ; If bit 4 of the new view in QQ11 is clear, jump to
 BEQ scrn6              ; scrn6 to skip loading the font into pattern buffer 0

                        ; If we get here then the new view we are setting up is
                        ; not the Game Over screen, the Long-range Chart or the
                        ; Start screen, and bit 4 of QQ11 is set

 LDA #66                ; Load the font into pattern buffer 0, and a set of
 JSR LoadNormalFont_b3  ; filled blocks into pattern buffer 1, from pattern 66
                        ; to 160
                        ;
                        ; If the view type in QQ11 is $BB (Save and load with
                        ; the normal and highlight fonts loaded), then this also
                        ; loads an inverted font into pattern buffer 1, from
                        ; pattern 66 to 160

.scrn6

 LDA QQ11               ; If bit 5 of the new view in QQ11 is clear, jump to
 AND #%00100000         ; scrn7 to skip loading the normal font
 BEQ scrn7

 JSR LoadHighFont_b3    ; Load the font into pattern buffer 1, and a set of
                        ; filled blocks into pattern buffer 0, from pattern 161
                        ; to 255

.scrn7

                        ; The new view doesn't have a dashboard, so now we draw
                        ; the left and right edges of the box on the rows where
                        ; the dashboard would be, overwriting the edges of the
                        ; dashboard from the old view (if it had one)

 LDA #1                 ; Draw the left edge of the box on rows 20 to 26
 STA nameBuffer0+20*32+1
 STA nameBuffer0+21*32+1
 STA nameBuffer0+22*32+1
 STA nameBuffer0+23*32+1
 STA nameBuffer0+24*32+1
 STA nameBuffer0+25*32+1
 STA nameBuffer0+26*32+1

 LDA #2                 ; Draw the right edge of the box on rows 20 to 26
 STA nameBuffer0+20*32
 STA nameBuffer0+21*32
 STA nameBuffer0+22*32
 STA nameBuffer0+23*32
 STA nameBuffer0+24*32
 STA nameBuffer0+25*32
 STA nameBuffer0+26*32

 LDA QQ11               ; If bit 6 of the new view in QQ11 is set, then there is
 AND #%01000000         ; no icon bar, so jump to scrn8... which has no effect,
 BNE scrn8              ; as that's the next instruction anyway, so presumably
                        ; this was left behind after deleting the code that
                        ; would be skipped

.scrn8

 JSR SetViewAttrs_b3    ; Set up attribute buffer 0 for the chosen view

                        ; The six instructions between here and scrn9 have no
                        ; effect, as we always end up at scrn9 and don't take
                        ; any notice of the flags

 LDA demoInProgress     ; If bit 7 of demoInProgress is set then we are
 BMI scrn9              ; initialising the demo, so jump to scrn9

 LDA QQ11               ; If bit 7 of the new view in QQ11 is clear, jump to
 BPL scrn9              ; scrn9

 CMP QQ11a              ; If the view we are switching from in QQ11a is 0 (the
 BEQ scrn9              ; space view), jump to scrn9... which has no effect,
                        ; as that's the next instruction anyway, so presumably
                        ; this was left behind after deleting the code that
                        ; would be skipped

.scrn9

 JSR DrawBoxTop         ; Draw the top edge of the box along the top of the
                        ; screen in nametable buffer 0

 LDX languageIndex      ; Set X to the index of the chosen language

 LDA QQ11               ; If this is the space view (QQ11 = 0), jump to scrn10
 BEQ scrn10             ; to print the view name at the top of the screen

 CMP #1                 ; If this is not the title screen (QQ11 = 1), jump to
 BNE scrn12             ; scrn12 to skip printing a title at the top of the
                        ; screen

                        ; If we get here then the new view is the title screen

 LDA #0                 ; Move the text cursor to row 0
 STA YC

 LDX languageIndex      ; Move the text cursor to the correct column for the
 LDA xTitleScreen,X     ; title screen in the chosen language
 STA XC

 LDA #30                ; Set A = 30 so we print recursive token 144 when we
                        ; jump to scrn11 ("--- E L I T E ---")

 BNE scrn11             ; Jump to scrn11 to print ("--- E L I T E ---") at the
                        ; top of the screen (this BNE is effectively a JMP as
                        ; A is never zero)

.scrn10

                        ; If we get here then the new view is the space view
                        ; and we jumped here with A = 0

 STA YC                 ; Move the text cursor to row 0

 LDA xSpaceView,X       ; Move the text cursor to the correct column for the
 STA XC                 ; space view name in the chosen language

 LDA languageNumber     ; If bit 1 of languageNumber is set, then the chosen
 AND #%00000010         ; language is Geman, so jump to scrn13 to print the view
 BNE scrn13             ; name after the view noun (so we print "ANSICHT VORN"
                        ; and "ANSICHT HINTEN" instead of "FRONT VIEW" and "REAR
                        ; VIEW", for example)

 JSR PrintSpaceViewName ; Print the name of the current space view (i.e.
                        ; "FRONT", "REAR", "LEFT" or "RIGHT")

 JSR TT162              ; Print a space

 LDA #175               ; Set A = 175 so the next instruction prints recursive
                        ; token 15 ("VIEW ")

.scrn11

 JSR TT27_b2            ; Print the text token in A

.scrn12

 LDX #1                 ; Move the text cursor to column 1 on row 1
 STX XC
 STX YC

 DEX                    ; Set QQ17 = 0 to switch to ALL CAPS
 STX QQ17

 RTS                    ; Return from the subroutine

.scrn13

                        ; If we get here then we want to print the view name
                        ; after the view noun

 LDA #175               ; Print recursive token 15 ("VIEW ") followed by a space
 JSR spc

 JSR PrintSpaceViewName ; Print the name of the current space view (i.e.
                        ; "FRONT", "REAR", "LEFT" or "RIGHT")

 JMP scrn12             ; Jump back to scrn12 to finish off

; ******************************************************************************
;
;       Name: PrintSpaceViewName
;       Type: Subroutine
;   Category: Text
;    Summary: Print the name of the current space view
;
; ******************************************************************************

.PrintSpaceViewName

 LDA VIEW               ; Load the current view into A:
                        ;
                        ;   0 = front
                        ;   1 = rear
                        ;   2 = left
                        ;   3 = right

 ORA #$60               ; OR with $60 so we get a value of $60 to $63 (96 to 99)

 JMP TT27_b2            ; Print recursive token 96 to 99, which will be in the
                        ; range "FRONT" to "RIGHT", returning from the
                        ; subroutine using a tail call

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
; Save bank0.bin
;
; ******************************************************************************

 PRINT "S.bank0.bin ", ~CODE%, " ", ~P%, " ", ~LOAD%, " ", ~LOAD%
 SAVE "3-assembled-output/bank0.bin", CODE%, P%, LOAD%
