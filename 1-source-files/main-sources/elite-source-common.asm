; ******************************************************************************
;
; NES ELITE GAME SOURCE (COMMON VARIABLES)
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
; https://elite.bbcelite.com/terminology
;
; The deep dive articles referred to in this commentary can be found at
; https://elite.bbcelite.com/deep_dives
;
; ------------------------------------------------------------------------------
;
; This source file contains variables, macros and addresses that are shared by
; all eight banks.
;
; ******************************************************************************

 INCLUDE "1-source-files/main-sources/elite-build-options.asm"

 _NTSC = (_VARIANT = 1)
 _PAL  = (_VARIANT = 2)

; ******************************************************************************
;
; Configuration variables
;
; ******************************************************************************

 CODE% = $8000          ; The address where the code will be run

 LOAD% = $8000          ; The address where the code will be loaded

 Q% = _MAX_COMMANDER    ; Set Q% to TRUE to max out the default commander, FALSE
                        ; for the standard default commander

 NOST = 20              ; The number of stardust particles in normal space (this
                        ; goes down to 3 in witchspace)

 NOSH = 8               ; The maximum number of ships in our local bubble of
                        ; universe

 NTY = 33               ; The number of different ship types

 MSL = 1                ; Ship type for a missile

 SST = 2                ; Ship type for a Coriolis space station

 ESC = 3                ; Ship type for an escape pod

 PLT = 4                ; Ship type for an alloy plate

 OIL = 5                ; Ship type for a cargo canister

 AST = 7                ; Ship type for an asteroid

 SPL = 8                ; Ship type for a splinter

 SHU = 9                ; Ship type for a Shuttle

 CYL = 11               ; Ship type for a Cobra Mk III

 ANA = 14               ; Ship type for an Anaconda

 HER = 15               ; Ship type for a rock hermit (asteroid)

 COPS = 16              ; Ship type for a Viper

 SH3 = 17               ; Ship type for a Sidewinder

 KRA = 19               ; Ship type for a Krait

 ADA = 20               ; Ship type for an Adder

 WRM = 23               ; Ship type for a Worm

 CYL2 = 24              ; Ship type for a Cobra Mk III (pirate)

 ASP = 25               ; Ship type for an Asp Mk II

 THG = 29               ; Ship type for a Thargoid

 TGL = 30               ; Ship type for a Thargon

 CON = 31               ; Ship type for a Constrictor

 COU = 32               ; Ship type for a Cougar

 DOD = 33               ; Ship type for a Dodecahedron ("Dodo") space station

 JL = ESC               ; Junk is defined as starting from the escape pod

 JH = SHU+2             ; Junk is defined as ending before the Cobra Mk III
                        ;
                        ; So junk is defined as the following: escape pod,
                        ; alloy plate, cargo canister, asteroid, splinter,
                        ; Shuttle or Transporter

 PACK = SH3             ; The first of the eight pack-hunter ships, which tend
                        ; to spawn in groups. With the default value of PACK the
                        ; pack-hunters are the Sidewinder, Mamba, Krait, Adder,
                        ; Gecko, Cobra Mk I, Worm and Cobra Mk III (pirate)

 POW = 15               ; Pulse laser power in the NES version is POW + 9,
                        ; rather than just POW in the other versions (all other
                        ; lasers are the same)

 Mlas = 50              ; Mining laser power

 Armlas = INT(128.5 + 1.5*POW)  ; Military laser power

 NI% = 38               ; The number of bytes in each ship's data block (as
                        ; stored in INWK and K%)

 NIK% = 42              ; The number of bytes in each block in K% (as each block
                        ; contains four extra bytes)

 X = 128                ; The centre x-coordinate of the space view

 Y = 72                 ; The centre y-coordinate of the space view

 RE = $3E               ; The obfuscation byte used to hide the recursive tokens
                        ; table from crackers viewing the binary code

 VE = $57               ; The obfuscation byte used to hide the extended tokens
                        ; table from crackers viewing the binary code

 LL = 29                ; The length of lines (in characters) of justified text
                        ; in the extended tokens system

 W2 = 3                 ; The horizontal character spacing in the scroll text
                        ; (i.e. the difference in x-coordinate between the
                        ; left edges of adjacent characters in words)

 WY = 1                 ; The vertical spacing between points in the scroll text
                        ; grid for each character

 W2Y = 3                ; The vertical line spacing in the scroll text (i.e. the
                        ; difference in y-coordinate between the tops of the
                        ; characters in adjacent lines)

 YPAL = 6 AND _PAL      ; A margin of 6 pixels that is applied to a number of
                        ; y-coordinates for the PAL version only (as the PAL
                        ; version has a taller screen than NTSC)

; ******************************************************************************
;
; NES PPU registers
;
; ******************************************************************************

 PPU_CTRL   = $2000     ; The PPU control register, which allows us to choose
                        ; which nametable and pattern table is being displayed,
                        ; and to toggle the NMI interrupt at VBlank

 PPU_MASK   = $2001     ; The PPU mask register, which controls how sprites and
                        ; the tile background are displayed

 PPU_STATUS = $2002     ; The PPU status register, which can be checked to see
                        ; whether VBlank has started, and whether sprite 0 has
                        ; been hit (so we can detect when the icon bar is being
                        ; drawn)

 OAM_ADDR   = $2003     ; The OAM address port (this is not used in Elite)

 OAM_DATA   = $2004     ; The OAM data port (this is not used in Elite)

 PPU_SCROLL = $2005     ; The PPU scroll position register, which is used to
                        ; scroll the leftmost tile on each row around to the
                        ; right

 PPU_ADDR   = $2006     ; The PPU address register, which is used to set the
                        ; destination address within the PPU when sending data
                        ; to the PPU

 PPU_DATA   = $2007     ; The PPU data register, which is used to send data to
                        ; the PPU, to the address specified in PPU_ADDR

 OAM_DMA    = $4014     ; The OAM DMA register, which is used to initiate a DMA
                        ; transfer of sprite data to the PPU

 PPU_PATT_0 = $0000     ; The address of pattern table 0 in the PPU

 PPU_PATT_1 = $1000     ; The address of pattern table 1 in the PPU

 PPU_NAME_0 = $2000     ; The address of nametable 0 in the PPU

 PPU_ATTR_0 = $23C0     ; The address of attribute table 0 in the PPU

 PPU_NAME_1 = $2400     ; The address of nametable 1 in the PPU

 PPU_ATTR_1 = $27C0     ; The address of attribute table 1 in the PPU

; ******************************************************************************
;
; NES CPU registers (I/O and sound)
;
; ******************************************************************************

 SQ1_VOL    = $4000     ; The APU duty cycle and volume register for square wave
                        ; channel 1

 SQ1_SWEEP  = $4001     ; The APU sweep control register for square wave channel
                        ; 1

 SQ1_LO     = $4002     ; The APU period register (low byte) for square wave
                        ; channel 1

 SQ1_HI     = $4003     ; The APU period register (high byte) for square wave
                        ; channel 1

 SQ2_VOL    = $4004     ; The APU duty cycle and volume register for square wave
                        ; channel 2

 SQ2_SWEEP  = $4005     ; The APU sweep control register for square wave channel
                        ; 2

 SQ2_LO     = $4006     ; The APU period register (low byte) for square wave
                        ; channel 2

 SQ2_HI     = $4007     ; The APU period register (high byte) for square wave
                        ; channel 2

 TRI_LINEAR = $4008     ; The APU linear counter register for the triangle wave
                        ; channel

 TRI_LO     = $400A     ; The APU period register (low byte) for the triangle
                        ; wave channel

 TRI_HI     = $400B     ; The APU period register (high byte) for the triangle
                        ; wave channel

 NOISE_VOL  = $400C     ; The APU volume register for the noise channel

 NOISE_LO   = $400E     ; The APU period register (low byte) for the noise
                        ; channel

 NOISE_HI   = $400F     ; The APU period register (high byte) for the noise
                        ; channel

 DMC_FREQ   = $4010     ; Controls the IRQ flag, loop flag and frequency of the
                        ; DMC channel (this is not used in Elite)

 DMC_RAW    = $4011     ; Controls the DAC on the DMC channel (this is not used
                        ; in Elite)

 DMC_START  = $4012     ; Controls the start adddress on the DMC channel (this
                        ; is not used in Elite)

 DMC_LEN    = $4013     ; Controls the sample length on the DMC channel (this is
                        ; not used in Elite)

 SND_CHN    = $4015     ; The APU sound channel register, which enables
                        ; individual sound channels to be enabled or disabled

 JOY1       = $4016     ; The joystick port, with controller 1 mapped to JOY1
                        ; and controller 2 mapped to JOY1 + 1

 APU_FC     = $4017     ; The APU frame counter control register, which controls
                        ; the triggering of IRQ interrupts for sound generation,
                        ; and the sequencer step mode

; ******************************************************************************
;
;       Name: ZP
;       Type: Workspace
;    Address: $0000 to $00FF
;   Category: Workspaces
;    Summary: Lots of important variables are stored in the zero page workspace
;             as it is quicker and more space-efficient to access memory here
;
; ******************************************************************************

 ORG $0000

.ZP

 SKIP 2                 ; These bytes appear to be unused

.RAND

 SKIP 4                 ; Four 8-bit seeds for the random number generation
                        ; system implemented in the DORND routine

.T1

 SKIP 1                 ; Temporary storage, used in a number of places

.SC

 SKIP 1                 ; Screen address (low byte)
                        ;
                        ; Elite draws on-screen by poking bytes directly into
                        ; screen memory, and SC(1 0) is typically set to the
                        ; address of the character block containing the pixel

.SCH

 SKIP 1                 ; Screen address (high byte)

.XX1

 SKIP 0                 ; This is an alias for INWK that is used in the main
                        ; ship-drawing routine at LL9

.INWK

 SKIP 36                ; The zero-page internal workspace for the current ship
                        ; data block
                        ;
                        ; As operations on zero page locations are faster and
                        ; have smaller opcodes than operations on the rest of
                        ; the addressable memory, Elite tends to store oft-used
                        ; data here. A lot of the routines in Elite need to
                        ; access and manipulate ship data, so to make this an
                        ; efficient exercise, the ship data is first copied from
                        ; the ship data blocks at K% into INWK (or, when new
                        ; ships are spawned, from the blueprints at XX21). See
                        ; the deep dive on "Ship data blocks" for details of
                        ; what each of the bytes in the INWK data block
                        ; represents

.NEWB

 SKIP 1                 ; The ship's "new byte flags" (or NEWB flags)
                        ;
                        ; Contains details about the ship's type and associated
                        ; behaviour, such as whether they are a trader, a bounty
                        ; hunter, a pirate, currently hostile, in the process of
                        ; docking, inside the hold having been scooped, and so
                        ; on. The default values for each ship type are taken
                        ; from the table at E%, and you can find out more detail
                        ; in the deep dive on "Advanced tactics with the NEWB
                        ; flags"

 SKIP 1                 ; This byte appears to be unused

.P

 SKIP 3                 ; Temporary storage, used in a number of places

.XC

 SKIP 1                 ; The x-coordinate of the text cursor (i.e. the text
                        ; column), which can be from 0 to 32
                        ;
                        ; A value of 0 denotes the leftmost column and 32 the
                        ; rightmost column, but because the top part of the
                        ; screen (the space view) has a border box that
                        ; clashes with columns 0 and 32, text is only shown
                        ; in columns 1-31

.hiddenColour

 SKIP 1                 ; Contains the colour to use for pixels that are hidden
                        ; in palette 0, e.g. $0F for black
                        ;
                        ; See the SetPaletteForView routine for details

.visibleColour

 SKIP 1                 ; Contains the colour to use for pixels that are visible
                        ; in palette 0, e.g. $2C for cyan
                        ;
                        ; See the SetPaletteForView routine for details

.paletteColour2

 SKIP 1                 ; Contains the colour to use for palette entry 2 in the
                        ; current (non-space) view
                        ;
                        ; See the SetPaletteForView routine for details

.paletteColour3

 SKIP 1                 ; Contains the colour to use for palette entry 3 in the
                        ; current (non-space) view
                        ;
                        ; See the SetPaletteForView routine for details

.fontStyle

 SKIP 1                 ; The font style to use when printing text:
                        ;
                        ;   * 1 = normal font
                        ;
                        ;   * 2 = highlight font
                        ;
                        ;   * 3 = green text on a black background (colour 3 on
                        ;         background colour 0)
                        ;
                        ; Style 3 is used when printing characters into 2x2
                        ; attribute blocks where printing the normal font would
                        ; result in the wrong colour text being shown

.nmiTimer

 SKIP 1                 ; A counter that gets decremented each time the NMI
                        ; interrupt is called, starting at 50 and counting down
                        ; to zero, at which point it jumps back up to 50 again
                        ; and triggers an increment of (nmiTimerHi nmiTimerLo)
                        ;
                        ; On PAL system there are 50 frames per second, so this
                        ; means nmiTimer ticks down from 50 once a second, so
                        ; (nmiTimerHi nmiTimerLo) counts up in seconds
                        ;
                        ; On NTSC there are 60 frames per second, so nmiTimer
                        ; counts down in 5/6 of a second, or 0.8333 seconds,
                        ; so (nmiTimerHi nmiTimerLo) counts up every 0.8333
                        ; seconds

.nmiTimerLo

 SKIP 1                 ; Low byte of a counter that's incremented by 1 every
                        ; time nmiTimer wraps
                        ;
                        ; On PAL systems (nmiTimerHi nmiTimerLo) counts seconds
                        ;
                        ; On NTSC it increments up every 0.8333 seconds

.nmiTimerHi

 SKIP 1                 ; High byte of a counter that's incremented by 1 every
                        ; time nmiTimer wraps
                        ;
                        ; On PAL systems (nmiTimerHi nmiTimerLo) counts seconds
                        ;
                        ; On NTSC it increments up every 0.8333 seconds

.YC

 SKIP 1                 ; The y-coordinate of the text cursor (i.e. the text
                        ; row), which can be from 0 to 23
                        ;
                        ; The screen actually has 31 character rows if you
                        ; include the dashboard, but the text printing routines
                        ; only work on the top part (the space view), so the
                        ; text cursor only goes up to a maximum of 23, the row
                        ; just before the screen splits
                        ;
                        ; A value of 0 denotes the top row, but because the
                        ; top part of the screen has a border box that clashes
                        ; with row 0, text is always shown at row 1 or greater

.QQ17

 SKIP 1                 ; Contains a number of flags that affect how text tokens
                        ; are printed, particularly capitalisation:
                        ;
                        ;   * If all bits are set (255) then text printing is
                        ;     disabled
                        ;
                        ;   * Bit 7: 0 = ALL CAPS
                        ;            1 = Sentence Case, bit 6 determines the
                        ;                case of the next letter to print
                        ;
                        ;   * Bit 6: 0 = print the next letter in upper case
                        ;            1 = print the next letter in lower case
                        ;
                        ;   * Bits 0-5: If any of bits 0-5 are set, print in
                        ;               lower case
                        ;
                        ; So:
                        ;
                        ;   * QQ17 = 0 means case is set to ALL CAPS
                        ;
                        ;   * QQ17 = %10000000 means Sentence Case, currently
                        ;            printing upper case
                        ;
                        ;   * QQ17 = %11000000 means Sentence Case, currently
                        ;            printing lower case
                        ;
                        ;   * QQ17 = %11111111 means printing is disabled

.K3

 SKIP 0                 ; Temporary storage, used in a number of places

.XX2

 SKIP 14                ; Temporary storage, used to store the visibility of the
                        ; ship's faces during the ship-drawing routine at LL9

.K4

 SKIP 2                 ; Temporary storage, used in a number of places

.XX16

 SKIP 18                ; Temporary storage for a block of values, used in a
                        ; number of places

.XX0

 SKIP 2                 ; Temporary storage, used to store the address of a ship
                        ; blueprint. For example, it is used when we add a new
                        ; ship to the local bubble in routine NWSHP, and it
                        ; contains the address of the current ship's blueprint
                        ; as we loop through all the nearby ships in the main
                        ; flight loop

.INF

 SKIP 2                 ; Temporary storage, typically used for storing the
                        ; address of a ship's data block, so it can be copied
                        ; to and from the internal workspace at INWK

.V

 SKIP 2                 ; Temporary storage, typically used for storing an
                        ; address pointer

.XX

 SKIP 2                 ; Temporary storage, typically used for storing a 16-bit
                        ; x-coordinate

.YY

 SKIP 2                 ; Temporary storage, typically used for storing a 16-bit
                        ; y-coordinate

.BETA

 SKIP 1                 ; The current pitch angle beta, which is reduced from
                        ; JSTY to a sign-magnitude value between -8 and +8
                        ;
                        ; This describes how fast we are pitching our ship, and
                        ; determines how fast the universe pitches around us
                        ;
                        ; The sign bit is also stored in BET2, while the
                        ; opposite sign is stored in BET2+1

.BET1

 SKIP 1                 ; The magnitude of the pitch angle beta, i.e. |beta|,
                        ; which is a positive value between 0 and 8

.QQ22

 SKIP 2                 ; The two hyperspace countdown counters
                        ;
                        ; Before a hyperspace jump, both QQ22 and QQ22+1 are
                        ; set to 15
                        ;
                        ; QQ22 is an internal counter that counts down by 1
                        ; each time TT102 is called, which happens every
                        ; iteration of the main game loop. When it reaches
                        ; zero, the on-screen counter in QQ22+1 gets
                        ; decremented, and QQ22 gets set to 5 and the countdown
                        ; continues (so the first tick of the hyperspace counter
                        ; takes 15 iterations to happen, but subsequent ticks
                        ; take 5 iterations each)
                        ;
                        ; QQ22+1 contains the number that's shown on-screen
                        ; during the countdown. It counts down from 15 to 1, and
                        ; when it hits 0, the hyperspace engines kick in

.ECMA

 SKIP 1                 ; The E.C.M. countdown timer, which determines whether
                        ; an E.C.M. system is currently operating:
                        ;
                        ;   * 0 = E.C.M. is off
                        ;
                        ;   * Non-zero = E.C.M. is on and is counting down
                        ;
                        ; The counter starts at 32 when an E.C.M. is activated,
                        ; either by us or by an opponent, and it decreases by 1
                        ; in each iteration of the main flight loop until it
                        ; reaches zero, at which point the E.C.M. switches off.
                        ; Only one E.C.M. can be active at any one time, so
                        ; there is only one counter

.ALP1

 SKIP 1                 ; Magnitude of the roll angle alpha, i.e. |alpha|,
                        ; which is a positive value between 0 and 31

.ALP2

 SKIP 2                 ; Bit 7 of ALP2 = sign of the roll angle in ALPHA
                        ;
                        ; Bit 7 of ALP2+1 = opposite sign to ALP2 and ALPHA

.XX15

 SKIP 0                 ; Temporary storage, typically used for storing screen
                        ; coordinates in line-drawing routines
                        ;
                        ; There are six bytes of storage, from XX15 TO XX15+5.
                        ; The first four bytes have the following aliases:
                        ;
                        ;   X1 = XX15
                        ;   Y1 = XX15+1
                        ;   X2 = XX15+2
                        ;   Y2 = XX15+3
                        ;
                        ; These are typically used for describing lines in terms
                        ; of screen coordinates, i.e. (X1, Y1) to (X2, Y2)
                        ;
                        ; The last two bytes of XX15 do not have aliases

.X1

 SKIP 1                 ; Temporary storage, typically used for x-coordinates in
                        ; line-drawing routines

.Y1

 SKIP 1                 ; Temporary storage, typically used for y-coordinates in
                        ; line-drawing routines

.X2

 SKIP 1                 ; Temporary storage, typically used for x-coordinates in
                        ; line-drawing routines

.Y2

 SKIP 1                 ; Temporary storage, typically used for y-coordinates in
                        ; line-drawing routines

 SKIP 2                 ; The last two bytes of the XX15 block

.XX12

 SKIP 6                 ; Temporary storage for a block of values, used in a
                        ; number of places

.K

 SKIP 4                 ; Temporary storage, used in a number of places

.iconBarKeyPress

 SKIP 1                 ; The button number of an icon bar button if an icon bar
                        ; button has been chosen
                        ;
                        ; This gets set along with the key logger, copying the
                        ; value from iconBarChoice (the latter gets set in the
                        ; NMI handler with the icon bar button number, so
                        ; iconBarKeyPress effectively latches the value from
                        ; iconBarChoice)

.QQ15

 SKIP 6                 ; The three 16-bit seeds for the selected system, i.e.
                        ; the one in the crosshairs in the Short-range Chart
                        ;
                        ; See the deep dives on "Galaxy and system seeds" and
                        ; "Twisting the system seeds" for more details

.K5

 SKIP 0                 ; Temporary storage used to store segment coordinates
                        ; across successive calls to BLINE, the ball line
                        ; routine

.XX18

 SKIP 4                 ; Temporary storage used to store coordinates in the
                        ; LL9 ship-drawing routine

.K6

 SKIP 5                 ; Temporary storage, typically used for storing
                        ; coordinates during vector calculations

.BET2

 SKIP 2                 ; Bit 7 of BET2 = sign of the pitch angle in BETA
                        ;
                        ; Bit 7 of BET2+1 = opposite sign to BET2 and BETA

.DELTA

 SKIP 1                 ; Our current speed, in the range 1-40

.DELT4

 SKIP 2                 ; Our current speed * 64 as a 16-bit value
                        ;
                        ; This is stored as DELT4(1 0), so the high byte in
                        ; DELT4+1 therefore contains our current speed / 4

.U

 SKIP 1                 ; Temporary storage, used in a number of places

.Q

 SKIP 1                 ; Temporary storage, used in a number of places

.R

 SKIP 1                 ; Temporary storage, used in a number of places

.S

 SKIP 1                 ; Temporary storage, used in a number of places

.T

 SKIP 1                 ; Temporary storage, used in a number of places

.XSAV

 SKIP 1                 ; Temporary storage for saving the value of the X
                        ; register, used in a number of places

.YSAV

 SKIP 1                 ; Temporary storage for saving the value of the Y
                        ; register, used in a number of places

.XX17

 SKIP 1                 ; Temporary storage, used in BPRNT to store the number
                        ; of characters to print, and as the edge counter in the
                        ; main ship-drawing routine

.QQ11

 SKIP 1                 ; This contains the type of the current view (or, if
                        ; we are changing views, the type of the view we are
                        ; changing to)
                        ;
                        ; The low nibble determines the view, as follows:
                        ;
                        ;   0  = $x0 = Space view
                        ;   1  = $x1 = Title screen
                        ;   2  = $x2 = Mission 1 briefing: rotating ship
                        ;   3  = $x3 = Mission 1 briefing: ship and text
                        ;   4  = $x4 = Game Over screen
                        ;   5  = $x5 = Text-based mission briefing
                        ;   6  = $x6 = Data on System
                        ;   7  = $x7 = Inventory
                        ;   8  = $x8 = Status Mode
                        ;   9  = $x9 = Equip Ship
                        ;   10 = $xA = Market Price
                        ;   11 = $xB = Save and Load
                        ;   12 = $xC = Short-range Chart
                        ;   13 = $xD = Long-range Chart
                        ;   14 = $xE = Unused
                        ;   15 = $xF = Start screen
                        ;
                        ; The high nibble contains four configuration bits, as
                        ; follows:
                        ;
                        ;   * Bit 4 clear = do not load the normal font
                        ;     Bit 4 set   = load the normal font into patterns
                        ;                   66 to 160 (or 68 to 162 for views
                        ;                   $9D and $DF)
                        ;
                        ;   * Bit 5 clear = do not load the highlight font
                        ;     Bit 5 set   = load the highlight font into
                        ;                   patterns 161 to 255
                        ;
                        ;   * Bit 6 clear = icon bar
                        ;     Bit 6 set   = no icon bar (rows 27-28 are blank)
                        ;
                        ;   * Bit 7 clear = dashboard (icon bar on row 20)
                        ;     Bit 7 set   = no dashboard (icon bar on row 27)
                        ;
                        ; The normal font is colour 1 on background colour 0
                        ; (typically white or cyan on black)
                        ;
                        ; The highlight font is colour 3 on background colour 1
                        ; (typically green on white)
                        ;
                        ; Most views have the same configuration every time
                        ; the view is shown, but $x0 (space view), $xB (Save and
                        ; load), $xD (Long-range Chart) and $xF (Start screen)
                        ; can have different configurations at different times
                        ;
                        ; Note that view $FF is an exception, as no fonts are
                        ; loaded for this view, despite bits 4 and 5 being set
                        ; (this view represents the blank screen between the end
                        ; of the Title screen and the start of the demo scroll
                        ; text)
                        ;
                        ; Also, view $BB (Save and load with the normal and
                        ; highlight fonts loaded) displays the normal font as
                        ; colour 1 on background colour 2 (white on red)
                        ;
                        ; Finally, views $9D (Long-range Chart) and $DF (Start
                        ; screen) load the normal font into patterns 68 to 162,
                        ; rather than 66 to 160
                        ;
                        ; The complete list of view types is therefore:
                        ;
                        ;   $00 = Space view
                        ;         No fonts loaded, dashboard
                        ;
                        ;   $10 = Space view
                        ;         Normal font loaded, dashboard
                        ;
                        ;   $01 = Title screen
                        ;         No fonts loaded, dashboard
                        ;
                        ;   $92 = Mission 1 briefing: rotating ship
                        ;         Normal font loaded, no dashboard
                        ;
                        ;   $93 = Mission 1 briefing: ship and text
                        ;         Normal font loaded, no dashboard
                        ;
                        ;   $C4 = Game Over screen
                        ;         No fonts loaded, no dashboard or icon bar
                        ;
                        ;   $95 = Text-based mission briefing
                        ;         Normal font loaded, no dashboard
                        ;
                        ;   $96 = Data on System
                        ;         Normal font loaded, no dashboard
                        ;
                        ;   $97 = Inventory
                        ;         Normal font loaded, no dashboard
                        ;
                        ;   $98 = Status Mode
                        ;         Normal font loaded, no dashboard
                        ;
                        ;   $B9 = Equip Ship
                        ;         Normal and highlight fonts loaded, no
                        ;         dashboard
                        ;
                        ;   $BA = Market Price
                        ;         Normal and highlight fonts loaded, no
                        ;         dashboard
                        ;
                        ;   $8B = Save and Load
                        ;         No fonts loaded, no dashboard
                        ;
                        ;   $BB = Save and Load
                        ;         Normal and highlight fonts loaded, special
                        ;         colours for the normal font, no dashboard
                        ;
                        ;   $9C = Short-range Chart
                        ;         Normal font loaded, no dashboard
                        ;
                        ;   $8D = Long-range Chart
                        ;         No fonts loaded, no dashboard
                        ;
                        ;   $9D = Long-range Chart
                        ;         Normal font loaded, no dashboard
                        ;
                        ;   $CF = Start screen
                        ;         No fonts loaded, no dashboard or icon bar
                        ;
                        ;   $DF = Start screen
                        ;         Normal font loaded, no dashboard or icon bar
                        ;
                        ;   $FF = Segue screen from Title screen to Demo
                        ;         No fonts loaded, no dashboard or icon bar
                        ;
                        ; In terms of fonts, then, these are the only options:
                        ;
                        ;   * No font is loaded
                        ;
                        ;   * The normal font is loaded
                        ;
                        ;   * The normal and highlight fonts are loaded
                        ;
                        ;   * The normal and highlight fonts are loaded, with
                        ;     special colours for the normal font

.QQ11a

 SKIP 1                 ; Contains the old view type when changing views
                        ;
                        ; When we change view, QQ11 gets set to the new view
                        ; number straight away while QQ11a stays set to the old
                        ; view type, only updating to the new view type once
                        ; the new view has appeared

.ZZ

 SKIP 1                 ; Temporary storage, typically used for distance values

.XX13

 SKIP 1                 ; Temporary storage, typically used in the line-drawing
                        ; routines

.MCNT

 SKIP 1                 ; The main loop counter
                        ;
                        ; This counter determines how often certain actions are
                        ; performed within the main loop. See the deep dive on
                        ; "Scheduling tasks with the main loop counter" for more
                        ; details

.TYPE

 SKIP 1                 ; The current ship type
                        ;
                        ; This is where we store the current ship type for when
                        ; we are iterating through the ships in the local bubble
                        ; as part of the main flight loop. See the table at XX21
                        ; for information about ship types

.ALPHA

 SKIP 1                 ; The current roll angle alpha, which is reduced from
                        ; JSTX to a sign-magnitude value between -31 and +31
                        ;
                        ; This describes how fast we are rolling our ship, and
                        ; determines how fast the universe rolls around us
                        ;
                        ; The sign bit is also stored in ALP2, while the
                        ; opposite sign is stored in ALP2+1

.QQ12

 SKIP 1                 ; Our "docked" status
                        ;
                        ;   * 0 = we are not docked
                        ;
                        ;   * $FF = we are docked

.TGT

 SKIP 1                 ; Temporary storage, typically used as a target value
                        ; for counters when drawing explosion clouds and partial
                        ; circles

.FLAG

 SKIP 1                 ; A flag that's used to define whether this is the first
                        ; call to the ball line routine in BLINE, so it knows
                        ; whether to wait for the second call before storing
                        ; segment data in the ball line heap

.CNT

 SKIP 1                 ; Temporary storage, typically used for storing the
                        ; number of iterations required when looping

.CNT2

 SKIP 1                 ; Temporary storage, used in the planet-drawing routine
                        ; to store the segment number where the arc of a partial
                        ; circle should start

.STP

 SKIP 1                 ; The step size for drawing circles
                        ;
                        ; Circles in Elite are split up into 64 points, and the
                        ; step size determines how many points to skip with each
                        ; straight-line segment, so the smaller the step size,
                        ; the smoother the circle. The values used are:
                        ;
                        ;   * 2 for big planets and the circles on the charts
                        ;   * 4 for medium planets and the launch tunnel
                        ;   * 8 for small planets and the hyperspace tunnel
                        ;
                        ; As the step size increases we move from smoother
                        ; circles at the top to more polygonal at the bottom.
                        ; See the CIRCLE2 routine for more details

.XX4

 SKIP 1                 ; Temporary storage, used in a number of places

.XX20

 SKIP 1                 ; Temporary storage, used in a number of places

.XX14

 SKIP 1                 ; This byte appears to be unused

.RAT

 SKIP 1                 ; Used to store different signs depending on the current
                        ; space view, for use in calculating stardust movement

.RAT2

 SKIP 1                 ; Temporary storage, used to store the pitch and roll
                        ; signs when moving objects and stardust

.widget

 SKIP 1                 ; Temporary storage, used to store the original argument
                        ; in A in the logarithmic FMLTU and LL28 routines

.halfScreenHeight

 SKIP 1                 ; Half the height of the drawable part of the screen in
                        ; pixels (can be 72, 77 or 104 pixels)

.screenHeight

 SKIP 1                 ; The height of the drawable part of the screen in
                        ; pixels (can be 144, 154 or 208 pixels)

.Yx2M1

 SKIP 1                 ; The height of the drawable part of the screen in
                        ; pixels minus 1, often used when calculating the
                        ; y-coordinate of the bottom pixel row of the space view

.messXC

 SKIP 1                 ; Temporary storage, used to store the text column
                        ; of the in-flight message in MESS, so it can be erased
                        ; from the screen at the correct time

.messYC

 SKIP 1                 ; Used to specify the text row of the in-flight message
                        ; in MESS, so it can be shown at a different positions
                        ; in different views

.newzp

 SKIP 1                 ; This is used by the STARS2 routine for storing the
                        ; stardust particle's delta_x value

.storeA

 SKIP 1                 ; Temporary storage for saving the value of the A
                        ; register, used in the bank-switching routines in
                        ; bank 7

.firstFreePattern

 SKIP 1                 ; Contains the number of the first free pattern in the
                        ; pattern buffer that we can draw into next (or 0 if
                        ; there are no free patterns)
                        ;
                        ; This variable is typically used to control the drawing
                        ; process - when we need to draw into a new tile when
                        ; drawing the space view, this is the number of the next
                        ; pattern to use for that tile

.pattBufferHiDiv8

 SKIP 1                 ; High byte of the address of the current pattern
                        ; buffer ($60 or $68) divided by 8

.SC2

 SKIP 2                 ; Temporary storage, typically used to store an address
                        ; when writing data to the PPU or into the buffers

.SC3

 SKIP 2                 ; Temporary storage, used to store an address in the
                        ; pattern buffers when drawing horizontal lines

.barButtons

 SKIP 2                 ; The address of the list of button numbers in the
                        ; iconBarButtons table for the current icon bar

.drawingBitplane

 SKIP 1                 ; Flipped manually by calling FlipDrawingPlane,
                        ; controls whether we are showing nametable/palette
                        ; buffer 0 or 1

.lastPattern

 SKIP 1                 ; The number of the last pattern entry to send from
                        ; pattern buffer 0 to bitplane 0 of the PPU pattern
                        ; table in the NMI handler

 SKIP 1                 ; The number of the last pattern entry to send from
                        ; pattern buffer 1 to bitplane 1 of the PPU pattern
                        ; table in the NMI handler

.clearingPattern

 SKIP 1                 ; The number of the first pattern to clear in pattern
                        ; buffer 0 when the NMI handler clears patterns
                        ;
                        ; This variable is saved by the NMI handler so the
                        ; buffers can be cleared across multiple VBlanks

 SKIP 1                 ; The number of the first pattern to clear in pattern
                        ; buffer 1 when the NMI handler clears patterns
                        ;
                        ; This variable is saved by the NMI handler so the
                        ; buffers can be cleared across multiple VBlanks

.clearingNameTile

 SKIP 1                 ; The number of the first tile to clear in nametable
                        ; buffer 0 when the NMI handler clears tiles, divided
                        ; by 8
                        ;
                        ; This variable is saved by the NMI handler so the
                        ; buffers can be cleared across multiple VBlanks

 SKIP 1                 ; The number of the first tile to clear in nametable
                        ; buffer 1 when the NMI handler clears tiles, divided
                        ; by 8
                        ;
                        ; This variable is saved by the NMI handler so the
                        ; buffers can be cleared across multiple VBlanks

.sendingNameTile

 SKIP 1                 ; The number of the most recent tile that was sent to
                        ; the PPU nametable by the NMI handler for bitplane
                        ; 0 (or the number of the first tile to send if none
                        ; have been sent), divided by 8
                        ;
                        ; This variable is saved by the NMI handler so the
                        ; buffers can be cleared across multiple VBlanks

 SKIP 1                 ; The number of the most recent tile that was sent to
                        ; the PPU nametable by the NMI handler for bitplane
                        ; 1 (or the number of the first tile to send if none
                        ; have been sent), divided by 8
                        ;
                        ; This variable is saved by the NMI handler so the
                        ; buffers can be cleared across multiple VBlanks

.patternCounter

 SKIP 1                 ; Counts patterns as they are written to the PPU pattern
                        ; table in the NMI handler
                        ;
                        ; This variable is used internally by the
                        ; SendPatternsToPPU routine

.sendingPattern

 SKIP 1                 ; The number of the most recent pattern that was sent to
                        ; the PPU pattern table by the NMI handler for bitplane
                        ; 0 (or the number of the first pattern to send if none
                        ; have been sent)
                        ;
                        ; This variable is saved by the NMI handler so the
                        ; buffers can be cleared across multiple VBlanks

 SKIP 1                 ; The number of the most recent pattern that was sent to
                        ; the PPU pattern table by the NMI handler for bitplane
                        ; 1 (or the number of the first pattern to send if none
                        ; have been sent)
                        ;
                        ; This variable is saved by the NMI handler so the
                        ; buffers can be cleared across multiple VBlanks

.firstNameTile

 SKIP 1                 ; The number of the first tile for which we send
                        ; nametable data to the PPU in the NMI handler
                        ; (potentially for both bitplanes, if both are
                        ; configured to be sent)

.lastNameTile

 SKIP 1                 ; The number of the last nametable buffer entry to send
                        ; to the PPU nametable table in the NMI handler for
                        ; bitplane 0, divided by 8

 SKIP 1                 ; The number of the last nametable buffer entry to send
                        ; to the PPU nametable table in the NMI handler for
                        ; bitplane 1, divided by 8

.nameTileCounter

 SKIP 1                 ; Counts tiles as they are written to the PPU nametable
                        ; in the NMI handler
                        ;
                        ; Contains the tile number divided by 8, so it counts up
                        ; 4 for every 32 tiles sent
                        ;
                        ; We divide by 8 because there are 1024 entries in each
                        ; nametable, which doesn't fit into one byte, so we
                        ; divide by 8 so the maximum counter value is 128
                        ;
                        ; This variable is used internally by the
                        ; SendNametableToPPU routine

.cycleCount

 SKIP 2                 ; Counts the number of CPU cycles left in the current
                        ; VBlank in the NMI handler

.firstPattern

 SKIP 1                 ; The number of the first pattern for which we send data
                        ; to the PPU in the NMI handler (potentially for both
                        ; bitplanes, if both are configured to be sent)

.barPatternCounter

 SKIP 1                 ; The number of icon bar nametable and pattern entries
                        ; that need to be sent to the PPU in the NMI handler
                        ;
                        ;   * 0 = send the nametable entries and the first four
                        ;         patterns in the next NMI call (and update
                        ;         barPatternCounter to 4 when done)
                        ;
                        ;   * 1-127 = counts the number of pattern bytes already
                        ;             sent to the PPU, which get sent in batches
                        ;             of four patterns (32 bytes), split across
                        ;             multiple NMI calls, until we have send all
                        ;             32 patterns and the value is 128
                        ;
                        ;   * 128 = do not send any tiles

.iconBarRow

 SKIP 2                 ; The row on which the icon bar appears
                        ;
                        ; This is stored as an offset from the start of the
                        ; nametable buffer, so it's the number of the nametable
                        ; entry for the top-left tile of the icon bar
                        ;
                        ; This can have two values:
                        ;
                        ;   * 20*32 = icon bar is on row 20 (just above the
                        ;             dashboard)
                        ;
                        ;   * 27*32 = icon bar is on tow 27 (at the bottom of
                        ;             the screen, where there is no dashboard)

.iconBarImageHi

 SKIP 1                 ; Contains the high byte of the address of the image
                        ; data for the current icon bar, i.e. HI(iconBarImage0)
                        ; through to HI(iconBarImage4)

.skipBarPatternsPPU

 SKIP 1                 ; A flag to control whether to send the icon bar's
                        ; patterns to the PPU, after sending the nametable
                        ; entries (this only applies if barPatternCounter = 0)
                        ;
                        ;   * Bit 7 set = do not send patterns
                        ;
                        ;   * Bit 7 clear = send patterns
                        ;
                        ; This means that if barPatternCounter is set to zero
                        ; and bit 7 of skipBarPatternsPPU is set, then only the
                        ; nametable entries for the icon bar will be sent to the
                        ; PPU, but if barPatternCounter is set to zero and bit 7
                        ; of skipBarPatternsPPU is clear, both the nametable
                        ; entries and patterns will be sent

.maxNameTileToClear

 SKIP 1                 ; The tile number at which the NMI handler should stop
                        ; clearing tiles in the nametable buffers during its
                        ; clearing cycle

.asciiToPattern

 SKIP 1                 ; The number to add to an ASCII code to get the pattern
                        ; number in the PPU of the corresponding character image

.updatePaletteInNMI

 SKIP 1                 ; A flag that controls whether to send the palette data
                        ; from XX3 to the PPU during NMI:
                        ;
                        ;   * 0 = do not send palette data
                        ;
                        ;   * Non-zero = do send palette data

.patternBufferLo

 SKIP 1                 ; (patternBufferHi patternBufferLo) contains the address
                        ; of the pattern buffer for the pattern we are sending
                        ; to the PPU from bitplane 0 (i.e. for pattern number
                        ; sendingPattern in bitplane 0)
                        ;
                        ; This variable is saved by the NMI handler so the
                        ; buffers can be cleared across multiple VBlanks

 SKIP 1                 ; (patternBufferHi patternBufferLo) contains the address
                        ; of the pattern buffer for the pattern we are sending
                        ; to the PPU from bitplane 1 (i.e. for pattern number
                        ; sendingPattern in bitplane 1)
                        ;
                        ; This variable is saved by the NMI handler so the
                        ; buffers can be cleared across multiple VBlanks

.nameTileBuffLo

 SKIP 1                 ; (nameTileBuffHi nameTileBuffLo) contains the address
                        ; of the nametable buffer for the tile we are sending to
                        ; the PPU from bitplane 0 (i.e. for tile number
                        ; sendingNameTile in bitplane 0)
                        ;
                        ; This variable is saved by the NMI handler so the
                        ; buffers can be cleared across multiple VBlanks

 SKIP 1                 ; (nameTileBuffHi nameTileBuffLo) contains the address
                        ; of the nametable buffer for the tile we are sending to
                        ; the PPU from bitplane 1 (i.e. for tile number
                        ; sendingNameTile in bitplane 1)
                        ;
                        ; This variable is saved by the NMI handler so the
                        ; buffers can be cleared across multiple VBlanks

.nmiBitplane8

 SKIP 1                 ; Used when sending patterns to the PPU to calculate the
                        ; address offset of bitplanes 0 and 1
                        ;
                        ; Gets set to nmiBitplane * 8 to given an offset of 0
                        ; for bitplane 0 and an offset of 8 for bitplane 1

.ppuPatternTableHi

 SKIP 1                 ; High byte of the address of the PPU pattern table to
                        ; which we send patterns
                        ;
                        ; This is set to HI(PPU_PATT_1) in ResetScreen and
                        ; doesn't change again, so it always points to pattern
                        ; table 1 in the PPU, as that's the only pattern table
                        ; we use for storing patterns

.pattBufferAddr

 SKIP 2                 ; Address of the current pattern buffer:
                        ;
                        ;   * pattBuffer0 ($6000) when drawingBitplane = 0
                        ;   * pattBuffer1 ($6800) when drawingBitplane = 1

.ppuNametableAddr

 SKIP 2                 ; Address of the current PPU nametable:
                        ;
                        ;   * PPU_NAME_0 ($2000) when drawingBitplane = 0
                        ;   * PPU_NAME_1 ($2400) when drawingBitplane = 1

.drawingPlaneDebug

 SKIP 1                 ; This variable is set to 0 whenever the drawing
                        ; bitplane changes, but it is never read, so maybe this
                        ; is part of some debug code that was left behind?

.nameBufferHi

 SKIP 1                 ; High byte of the address of the current nametable
                        ; buffer ($70 or $74)

.startupDebug

 SKIP 1                 ; This variable is set to 0 in the game's entry routine
                        ; at S%, but it is never read, so maybe this is part of
                        ; some debug code that was left behind?

.lastToSend

 SKIP 1                 ; The last tile or pattern number to send to the PPU,
                        ; potentially potentially overwritten by the flags
                        ;
                        ; This variable is used internally by the NMI handler,
                        ; and is set according to bit 3 of the bitplane flags

.setupPPUForIconBar

 SKIP 1                 ; Controls whether we force the nametable and pattern
                        ; table to 0 when the PPU starts drawing the icon bar
                        ;
                        ;   * Bit 7 clear = do nothing when the PPU starts
                        ;                   drawing the icon bar
                        ;
                        ;   * Bit 7 set = configure the PPU to display nametable
                        ;                 0 and pattern table 0 when the PPU
                        ;                 starts drawing the icon bar

.showUserInterface

 SKIP 1                 ; Bit 7 set means display the user interface (so we only
                        ; clear it for the game over screen)

.joystickDelta

 SKIP 0                 ; Used to store the amount to change the pitch and roll
                        ; rates when converting controller button presses into
                        ; joystick values

.addr

 SKIP 2                 ; Temporary storage, used in a number of places to hold
                        ; an address

.dataForPPU

 SKIP 2                 ; An address pointing to data that we send to the PPU

.clearBlockSize

 SKIP 2                 ; The size of the block of memory to clear, for example
                        ; when clearing the buffers

.clearAddress

 SKIP 2                 ; The address of a block of memory to clear, for example
                        ; when clearing the buffers

.hiddenBitplane

 SKIP 1                 ; The bitplane that is currently hidden from view in the
                        ; space view
                        ;
                        ;   * 0 = bitplane 0 is hidden, so:
                        ;         * Colour %01 (1) is the hidden colour (black)
                        ;         * Colour %10 (2) is the visible colour (cyan)
                        ;
                        ;   * 1 = bitplane 1 is hidden, so:
                        ;         * Colour %01 (1) is the visible colour (cyan)
                        ;         * Colour %10 (2) is the hidden colour (black)
                        ;
                        ; Note that bitplane 0 corresponds to bit 0 of the
                        ; colour number, while bitplane 1 corresponds to bit 1
                        ; of the colour number (as this is how the NES stores
                        ; pattern data - the first block of eight bytes in each
                        ; pattern controls bit 0 of the colour, while the second
                        ; block controls bit 1)
                        ;
                        ; In other words:
                        ;
                        ;   * Bitplane 0 = bit 0 = colour %01 = colour 1
                        ;
                        ;   * Bitplane 1 = bit 1 = colour %10 = colour 2

.nmiBitplane

 SKIP 1                 ; The number of the bitplane (0 or 1) that is currently
                        ; being processed in the NMI handler during VBlank

.ppuCtrlCopy

 SKIP 1                 ; Contains a copy of PPU_CTRL, so we can check the PPU
                        ; configuration without having to access the PPU

.enableBitplanes

 SKIP 1                 ; A flag to control whether two different bitplanes are
                        ; implemented when drawing the screen, so smooth vector
                        ; graphics can be shown
                        ;
                        ;   * 0 = bitplanes are disabled (for the Start screen)
                        ;
                        ;   * 1 = bitplanes are enabled (for the main game)

.currentBank

 SKIP 1                 ; Contains the number of the ROM bank (0 to 6) that is
                        ; currently paged into memory at $8000

.runningSetBank

 SKIP 1                 ; A flag that records whether we are in the process of
                        ; switching ROM banks in the SetBank routine when the
                        ; NMI handler is called
                        ;
                        ;   * 0 = we are not in the process of switching ROM
                        ;         banks
                        ;
                        ;   * Non-zero = we are not in the process of switching
                        ;                ROM banks
                        ;
                        ; This is used to control whether the NMI handler calls
                        ; the MakeSounds routine to make the current sounds
                        ; (music and sound effects), as this can only happen if
                        ; we are not in the middle of switching ROM banks (if
                        ; we are, then MakeSounds is only called once the
                        ; bank-switching is done - see the SetBank routine for
                        ; details)

.characterEnd

 SKIP 1                 ; The number of the character beyond the end of the
                        ; printable character set for the chosen language

.autoPlayKeys

 SKIP 2                 ; The address of the table containing the key presses to
                        ; apply when auto-playing the demo
                        ;
                        ; The address is either that of the chosen language's
                        ; autoPlayKeys1 table (for the first part of the
                        ; auto-play demo, or the autoPlayKeys2 table (for the
                        ; second part)

 SKIP 2                 ; These bytes appear to be unused

.soundAddr

 SKIP 2                 ; Temporary storage, used in a number of places in the
                        ; sound routines to hold an address

 PRINT "ZP workspace from ", ~ZP, "to ", ~P%-1, "inclusive"

; ******************************************************************************
;
;       Name: XX3
;       Type: Workspace
;    Address: $0100 to the top of the descending stack
;   Category: Workspaces
;    Summary: Temporary storage space for complex calculations
;
; ------------------------------------------------------------------------------
;
; Used as heap space for storing temporary data during calculations. Shared with
; the descending 6502 stack, which works down from $01FF.
;
; ******************************************************************************

 ORG $0100

.XX3

 SKIP 256               ; Temporary storage, typically used for storing tables
                        ; of values such as screen coordinates or ship data

; ******************************************************************************
;
;       Name: Sprite buffer
;       Type: Workspace
;    Address: $0200 to $02FF
;   Category: Workspaces
;    Summary: Configuration data for sprites 0 to 63, which gets copied to the
;             PPU to update the screen
;
; ------------------------------------------------------------------------------
;
; Each sprite has the following data associated with it:
;
;   * The sprite's screen coordinates in (x, y)
;
;   * The number of the pattern that is drawn on-screen for this sprite
;
;   * The sprite's attributes, which are:
;
;       * Bit 0-1: Palette to use when drawing the sprite (from sprite palettes
;                  0 to 3 at PPU addresses $3F11, $3F15, $3F19 and $3F1D)
;
;       * Bit 5: Priority (0 = in front of background, 1 = behind background)
;
;       * Bit 6: Flip horizontally (0 = no flip, 1 = flip)
;
;       * Bit 7: Flip vertically (0 = no flip, 1 = flip)
;
; ******************************************************************************

 ORG $0200

.ySprite0

 SKIP 1                 ; Screen y-coordinate for sprite 0

.pattSprite0

 SKIP 1                 ; Pattern number for sprite 0

.attrSprite0

 SKIP 1                 ; Attributes for sprite 0

.xSprite0

 SKIP 1                 ; Screen x-coordinate for sprite 0

.ySprite1

 SKIP 1                 ; Screen y-coordinate for sprite 1

.pattSprite1

 SKIP 1                 ; Pattern number for sprite 1

.attrSprite1

 SKIP 1                 ; Attributes for sprite 1

.xSprite1

 SKIP 1                 ; Screen x-coordinate for sprite 1

.ySprite2

 SKIP 1                 ; Screen y-coordinate for sprite 2

.pattSprite2

 SKIP 1                 ; Pattern number for sprite 2

.attrSprite2

 SKIP 1                 ; Attributes for sprite 2

.xSprite2

 SKIP 1                 ; Screen x-coordinate for sprite 2

.ySprite3

 SKIP 1                 ; Screen y-coordinate for sprite 3

.pattSprite3

 SKIP 1                 ; Pattern number for sprite 3

.attrSprite3

 SKIP 1                 ; Attributes for sprite 3

.xSprite3

 SKIP 1                 ; Screen x-coordinate for sprite 3

.ySprite4

 SKIP 1                 ; Screen y-coordinate for sprite 4

.pattSprite4

 SKIP 1                 ; Pattern number for sprite 4

.attrSprite4

 SKIP 1                 ; Attributes for sprite 4

.xSprite4

 SKIP 1                 ; Screen x-coordinate for sprite 4

.ySprite5

 SKIP 1                 ; Screen y-coordinate for sprite 5

.pattSprite5

 SKIP 1                 ; Pattern number for sprite 5

.attrSprite5

 SKIP 1                 ; Attributes for sprite 5

.xSprite5

 SKIP 1                 ; Screen x-coordinate for sprite 5

.ySprite6

 SKIP 1                 ; Screen y-coordinate for sprite 6

.pattSprite6

 SKIP 1                 ; Pattern number for sprite 6

.attrSprite6

 SKIP 1                 ; Attributes for sprite 6

.xSprite6

 SKIP 1                 ; Screen x-coordinate for sprite 6

.ySprite7

 SKIP 1                 ; Screen y-coordinate for sprite 7

.pattSprite7

 SKIP 1                 ; Pattern number for sprite 7

.attrSprite7

 SKIP 1                 ; Attributes for sprite 7

.xSprite7

 SKIP 1                 ; Screen x-coordinate for sprite 7

.ySprite8

 SKIP 1                 ; Screen y-coordinate for sprite 8

.pattSprite8

 SKIP 1                 ; Pattern number for sprite 8

.attrSprite8

 SKIP 1                 ; Attributes for sprite 8

.xSprite8

 SKIP 1                 ; Screen x-coordinate for sprite 8

.ySprite9

 SKIP 1                 ; Screen y-coordinate for sprite 9

.pattSprite9

 SKIP 1                 ; Pattern number for sprite 9

.attrSprite9

 SKIP 1                 ; Attributes for sprite 9

.xSprite9

 SKIP 1                 ; Screen x-coordinate for sprite 9

.ySprite10

 SKIP 1                 ; Screen y-coordinate for sprite 10

.pattSprite10

 SKIP 1                 ; Pattern number for sprite 10

.attrSprite10

 SKIP 1                 ; Attributes for sprite 10

.xSprite10

 SKIP 1                 ; Screen x-coordinate for sprite 10

.ySprite11

 SKIP 1                 ; Screen y-coordinate for sprite 11

.pattSprite11

 SKIP 1                 ; Pattern number for sprite 11

.attrSprite11

 SKIP 1                 ; Attributes for sprite 11

.xSprite11

 SKIP 1                 ; Screen x-coordinate for sprite 11

.ySprite12

 SKIP 1                 ; Screen y-coordinate for sprite 12

.pattSprite12

 SKIP 1                 ; Pattern number for sprite 12

.attrSprite12

 SKIP 1                 ; Attributes for sprite 12

.xSprite12

 SKIP 1                 ; Screen x-coordinate for sprite 12

.ySprite13

 SKIP 1                 ; Screen y-coordinate for sprite 13

.pattSprite13

 SKIP 1                 ; Pattern number for sprite 13

.attrSprite13

 SKIP 1                 ; Attributes for sprite 13

.xSprite13

 SKIP 1                 ; Screen x-coordinate for sprite 13

.ySprite14

 SKIP 1                 ; Screen y-coordinate for sprite 14

.pattSprite14

 SKIP 1                 ; Pattern number for sprite 14

.attrSprite14

 SKIP 1                 ; Attributes for sprite 14

.xSprite14

 SKIP 1                 ; Screen x-coordinate for sprite 14

.ySprite15

 SKIP 1                 ; Screen y-coordinate for sprite 15

.pattSprite15

 SKIP 1                 ; Pattern number for sprite 15

.attrSprite15

 SKIP 1                 ; Attributes for sprite 15

.xSprite15

 SKIP 1                 ; Screen x-coordinate for sprite 15

.ySprite16

 SKIP 1                 ; Screen y-coordinate for sprite 16

.pattSprite16

 SKIP 1                 ; Pattern number for sprite 16

.attrSprite16

 SKIP 1                 ; Attributes for sprite 16

.xSprite16

 SKIP 1                 ; Screen x-coordinate for sprite 16

.ySprite17

 SKIP 1                 ; Screen y-coordinate for sprite 17

.pattSprite17

 SKIP 1                 ; Pattern number for sprite 17

.attrSprite17

 SKIP 1                 ; Attributes for sprite 17

.xSprite17

 SKIP 1                 ; Screen x-coordinate for sprite 17

.ySprite18

 SKIP 1                 ; Screen y-coordinate for sprite 18

.pattSprite18

 SKIP 1                 ; Pattern number for sprite 18

.attrSprite18

 SKIP 1                 ; Attributes for sprite 18

.xSprite18

 SKIP 1                 ; Screen x-coordinate for sprite 18

.ySprite19

 SKIP 1                 ; Screen y-coordinate for sprite 19

.pattSprite19

 SKIP 1                 ; Pattern number for sprite 19

.attrSprite19

 SKIP 1                 ; Attributes for sprite 19

.xSprite19

 SKIP 1                 ; Screen x-coordinate for sprite 19

.ySprite20

 SKIP 1                 ; Screen y-coordinate for sprite 20

.pattSprite20

 SKIP 1                 ; Pattern number for sprite 20

.attrSprite20

 SKIP 1                 ; Attributes for sprite 20

.xSprite20

 SKIP 1                 ; Screen x-coordinate for sprite 20

.ySprite21

 SKIP 1                 ; Screen y-coordinate for sprite 21

.pattSprite21

 SKIP 1                 ; Pattern number for sprite 21

.attrSprite21

 SKIP 1                 ; Attributes for sprite 21

.xSprite21

 SKIP 1                 ; Screen x-coordinate for sprite 21

.ySprite22

 SKIP 1                 ; Screen y-coordinate for sprite 22

.pattSprite22

 SKIP 1                 ; Pattern number for sprite 22

.attrSprite22

 SKIP 1                 ; Attributes for sprite 22

.xSprite22

 SKIP 1                 ; Screen x-coordinate for sprite 22

.ySprite23

 SKIP 1                 ; Screen y-coordinate for sprite 23

.pattSprite23

 SKIP 1                 ; Pattern number for sprite 23

.attrSprite23

 SKIP 1                 ; Attributes for sprite 23

.xSprite23

 SKIP 1                 ; Screen x-coordinate for sprite 23

.ySprite24

 SKIP 1                 ; Screen y-coordinate for sprite 24

.pattSprite24

 SKIP 1                 ; Pattern number for sprite 24

.attrSprite24

 SKIP 1                 ; Attributes for sprite 24

.xSprite24

 SKIP 1                 ; Screen x-coordinate for sprite 24

.ySprite25

 SKIP 1                 ; Screen y-coordinate for sprite 25

.pattSprite25

 SKIP 1                 ; Pattern number for sprite 25

.attrSprite25

 SKIP 1                 ; Attributes for sprite 25

.xSprite25

 SKIP 1                 ; Screen x-coordinate for sprite 25

.ySprite26

 SKIP 1                 ; Screen y-coordinate for sprite 26

.pattSprite26

 SKIP 1                 ; Pattern number for sprite 26

.attrSprite26

 SKIP 1                 ; Attributes for sprite 26

.xSprite26

 SKIP 1                 ; Screen x-coordinate for sprite 26

.ySprite27

 SKIP 1                 ; Screen y-coordinate for sprite 27

.pattSprite27

 SKIP 1                 ; Pattern number for sprite 27

.attrSprite27

 SKIP 1                 ; Attributes for sprite 27

.xSprite27

 SKIP 1                 ; Screen x-coordinate for sprite 27

.ySprite28

 SKIP 1                 ; Screen y-coordinate for sprite 28

.pattSprite28

 SKIP 1                 ; Pattern number for sprite 28

.attrSprite28

 SKIP 1                 ; Attributes for sprite 28

.xSprite28

 SKIP 1                 ; Screen x-coordinate for sprite 28

.ySprite29

 SKIP 1                 ; Screen y-coordinate for sprite 29

.pattSprite29

 SKIP 1                 ; Pattern number for sprite 29

.attrSprite29

 SKIP 1                 ; Attributes for sprite 29

.xSprite29

 SKIP 1                 ; Screen x-coordinate for sprite 29

.ySprite30

 SKIP 1                 ; Screen y-coordinate for sprite 30

.pattSprite30

 SKIP 1                 ; Pattern number for sprite 30

.attrSprite30

 SKIP 1                 ; Attributes for sprite 30

.xSprite30

 SKIP 1                 ; Screen x-coordinate for sprite 30

.ySprite31

 SKIP 1                 ; Screen y-coordinate for sprite 31

.pattSprite31

 SKIP 1                 ; Pattern number for sprite 31

.attrSprite31

 SKIP 1                 ; Attributes for sprite 31

.xSprite31

 SKIP 1                 ; Screen x-coordinate for sprite 31

.ySprite32

 SKIP 1                 ; Screen y-coordinate for sprite 32

.pattSprite32

 SKIP 1                 ; Pattern number for sprite 32

.attrSprite32

 SKIP 1                 ; Attributes for sprite 32

.xSprite32

 SKIP 1                 ; Screen x-coordinate for sprite 32

.ySprite33

 SKIP 1                 ; Screen y-coordinate for sprite 33

.pattSprite33

 SKIP 1                 ; Pattern number for sprite 33

.attrSprite33

 SKIP 1                 ; Attributes for sprite 33

.xSprite33

 SKIP 1                 ; Screen x-coordinate for sprite 33

.ySprite34

 SKIP 1                 ; Screen y-coordinate for sprite 34

.pattSprite34

 SKIP 1                 ; Pattern number for sprite 34

.attrSprite34

 SKIP 1                 ; Attributes for sprite 34

.xSprite34

 SKIP 1                 ; Screen x-coordinate for sprite 34

.ySprite35

 SKIP 1                 ; Screen y-coordinate for sprite 35

.pattSprite35

 SKIP 1                 ; Pattern number for sprite 35

.attrSprite35

 SKIP 1                 ; Attributes for sprite 35

.xSprite35

 SKIP 1                 ; Screen x-coordinate for sprite 35

.ySprite36

 SKIP 1                 ; Screen y-coordinate for sprite 36

.pattSprite36

 SKIP 1                 ; Pattern number for sprite 36

.attrSprite36

 SKIP 1                 ; Attributes for sprite 36

.xSprite36

 SKIP 1                 ; Screen x-coordinate for sprite 36

.ySprite37

 SKIP 1                 ; Screen y-coordinate for sprite 37

.pattSprite37

 SKIP 1                 ; Pattern number for sprite 37

.attrSprite37

 SKIP 1                 ; Attributes for sprite 37

.xSprite37

 SKIP 1                 ; Screen x-coordinate for sprite 37

.ySprite38

 SKIP 1                 ; Screen y-coordinate for sprite 38

.pattSprite38

 SKIP 1                 ; Pattern number for sprite 38

.attrSprite38

 SKIP 1                 ; Attributes for sprite 38

.xSprite38

 SKIP 1                 ; Screen x-coordinate for sprite 38

.ySprite39

 SKIP 1                 ; Screen y-coordinate for sprite 39

.pattSprite39

 SKIP 1                 ; Pattern number for sprite 39

.attrSprite39

 SKIP 1                 ; Attributes for sprite 39

.xSprite39

 SKIP 1                 ; Screen x-coordinate for sprite 39

.ySprite40

 SKIP 1                 ; Screen y-coordinate for sprite 40

.pattSprite40

 SKIP 1                 ; Pattern number for sprite 40

.attrSprite40

 SKIP 1                 ; Attributes for sprite 40

.xSprite40

 SKIP 1                 ; Screen x-coordinate for sprite 40

.ySprite41

 SKIP 1                 ; Screen y-coordinate for sprite 41

.pattSprite41

 SKIP 1                 ; Pattern number for sprite 41

.attrSprite41

 SKIP 1                 ; Attributes for sprite 41

.xSprite41

 SKIP 1                 ; Screen x-coordinate for sprite 41

.ySprite42

 SKIP 1                 ; Screen y-coordinate for sprite 42

.pattSprite42

 SKIP 1                 ; Pattern number for sprite 42

.attrSprite42

 SKIP 1                 ; Attributes for sprite 42

.xSprite42

 SKIP 1                 ; Screen x-coordinate for sprite 42

.ySprite43

 SKIP 1                 ; Screen y-coordinate for sprite 43

.pattSprite43

 SKIP 1                 ; Pattern number for sprite 43

.attrSprite43

 SKIP 1                 ; Attributes for sprite 43

.xSprite43

 SKIP 1                 ; Screen x-coordinate for sprite 43

.ySprite44

 SKIP 1                 ; Screen y-coordinate for sprite 44

.pattSprite44

 SKIP 1                 ; Pattern number for sprite 44

.attrSprite44

 SKIP 1                 ; Attributes for sprite 44

.xSprite44

 SKIP 1                 ; Screen x-coordinate for sprite 44

.ySprite45

 SKIP 1                 ; Screen y-coordinate for sprite 45

.pattSprite45

 SKIP 1                 ; Pattern number for sprite 45

.attrSprite45

 SKIP 1                 ; Attributes for sprite 45

.xSprite45

 SKIP 1                 ; Screen x-coordinate for sprite 45

.ySprite46

 SKIP 1                 ; Screen y-coordinate for sprite 46

.pattSprite46

 SKIP 1                 ; Pattern number for sprite 46

.attrSprite46

 SKIP 1                 ; Attributes for sprite 46

.xSprite46

 SKIP 1                 ; Screen x-coordinate for sprite 46

.ySprite47

 SKIP 1                 ; Screen y-coordinate for sprite 47

.pattSprite47

 SKIP 1                 ; Pattern number for sprite 47

.attrSprite47

 SKIP 1                 ; Attributes for sprite 47

.xSprite47

 SKIP 1                 ; Screen x-coordinate for sprite 47

.ySprite48

 SKIP 1                 ; Screen y-coordinate for sprite 48

.pattSprite48

 SKIP 1                 ; Pattern number for sprite 48

.attrSprite48

 SKIP 1                 ; Attributes for sprite 48

.xSprite48

 SKIP 1                 ; Screen x-coordinate for sprite 48

.ySprite49

 SKIP 1                 ; Screen y-coordinate for sprite 49

.pattSprite49

 SKIP 1                 ; Pattern number for sprite 49

.attrSprite49

 SKIP 1                 ; Attributes for sprite 49

.xSprite49

 SKIP 1                 ; Screen x-coordinate for sprite 49

.ySprite50

 SKIP 1                 ; Screen y-coordinate for sprite 50

.pattSprite50

 SKIP 1                 ; Pattern number for sprite 50

.attrSprite50

 SKIP 1                 ; Attributes for sprite 50

.xSprite50

 SKIP 1                 ; Screen x-coordinate for sprite 50

.ySprite51

 SKIP 1                 ; Screen y-coordinate for sprite 51

.pattSprite51

 SKIP 1                 ; Pattern number for sprite 51

.attrSprite51

 SKIP 1                 ; Attributes for sprite 51

.xSprite51

 SKIP 1                 ; Screen x-coordinate for sprite 51

.ySprite52

 SKIP 1                 ; Screen y-coordinate for sprite 52

.pattSprite52

 SKIP 1                 ; Pattern number for sprite 52

.attrSprite52

 SKIP 1                 ; Attributes for sprite 52

.xSprite52

 SKIP 1                 ; Screen x-coordinate for sprite 52

.ySprite53

 SKIP 1                 ; Screen y-coordinate for sprite 53

.pattSprite53

 SKIP 1                 ; Pattern number for sprite 53

.attrSprite53

 SKIP 1                 ; Attributes for sprite 53

.xSprite53

 SKIP 1                 ; Screen x-coordinate for sprite 53

.ySprite54

 SKIP 1                 ; Screen y-coordinate for sprite 54

.pattSprite54

 SKIP 1                 ; Pattern number for sprite 54

.attrSprite54

 SKIP 1                 ; Attributes for sprite 54

.xSprite54

 SKIP 1                 ; Screen x-coordinate for sprite 54

.ySprite55

 SKIP 1                 ; Screen y-coordinate for sprite 55

.pattSprite55

 SKIP 1                 ; Pattern number for sprite 55

.attrSprite55

 SKIP 1                 ; Attributes for sprite 55

.xSprite55

 SKIP 1                 ; Screen x-coordinate for sprite 55

.ySprite56

 SKIP 1                 ; Screen y-coordinate for sprite 56

.pattSprite56

 SKIP 1                 ; Pattern number for sprite 56

.attrSprite56

 SKIP 1                 ; Attributes for sprite 56

.xSprite56

 SKIP 1                 ; Screen x-coordinate for sprite 56

.ySprite57

 SKIP 1                 ; Screen y-coordinate for sprite 57

.pattSprite57

 SKIP 1                 ; Pattern number for sprite 57

.attrSprite57

 SKIP 1                 ; Attributes for sprite 57

.xSprite57

 SKIP 1                 ; Screen x-coordinate for sprite 57

.ySprite58

 SKIP 1                 ; Screen y-coordinate for sprite 58

.pattSprite58

 SKIP 1                 ; Pattern number for sprite 58

.attrSprite58

 SKIP 1                 ; Attributes for sprite 58

.xSprite58

 SKIP 1                 ; Screen x-coordinate for sprite 58

.ySprite59

 SKIP 1                 ; Screen y-coordinate for sprite 59

.pattSprite59

 SKIP 1                 ; Pattern number for sprite 59

.attrSprite59

 SKIP 1                 ; Attributes for sprite 59

.xSprite59

 SKIP 1                 ; Screen x-coordinate for sprite 59

.ySprite60

 SKIP 1                 ; Screen y-coordinate for sprite 60

.pattSprite60

 SKIP 1                 ; Pattern number for sprite 60

.attrSprite60

 SKIP 1                 ; Attributes for sprite 60

.xSprite60

 SKIP 1                 ; Screen x-coordinate for sprite 60

.ySprite61

 SKIP 1                 ; Screen y-coordinate for sprite 61

.pattSprite61

 SKIP 1                 ; Pattern number for sprite 61

.attrSprite61

 SKIP 1                 ; Attributes for sprite 61

.xSprite61

 SKIP 1                 ; Screen x-coordinate for sprite 61

.ySprite62

 SKIP 1                 ; Screen y-coordinate for sprite 62

.pattSprite62

 SKIP 1                 ; Pattern number for sprite 62

.attrSprite62

 SKIP 1                 ; Attributes for sprite 62

.xSprite62

 SKIP 1                 ; Screen x-coordinate for sprite 62

.ySprite63

 SKIP 1                 ; Screen y-coordinate for sprite 63

.pattSprite63

 SKIP 1                 ; Pattern number for sprite 63

.attrSprite63

 SKIP 1                 ; Attributes for sprite 63

.xSprite63

 SKIP 1                 ; Screen x-coordinate for sprite 63

; ******************************************************************************
;
;       Name: WP
;       Type: Workspace
;    Address: $0300 to $05FF
;   Category: Workspaces
;    Summary: Ship slots, variables
;
; ******************************************************************************

 ORG $0300

.WP

 SKIP 0                 ; The start of the WP workspace

.allowInSystemJump

 SKIP 1                 ; Bits 6 and 7 record whether it is safe to perform an
                        ; in-system jump
                        ;
                        ; Bits are set if, for example, hostile ships are in the
                        ; vicinity, or we are too near a station, the planet or
                        ; the sun
                        ;
                        ; We can only do a jump if both bits are clear

.enableSound

 SKIP 1                 ; Controls sound effects and music in David Whittaker's
                        ; sound module
                        ;
                        ;   * 0 = sound is disabled
                        ;
                        ;   * Non-zero = sound is enabled

.effectOnSQ1

 SKIP 1                 ; Records whether a sound effect is being made on the
                        ; SQ1 channel
                        ;
                        ;   * 0 = no sound effect is being made on SQ1
                        ;
                        ;   * Non-zero = a sound effect is being made on SQ1

.effectOnSQ2

 SKIP 1                 ; Records whether a sound effect is being made on the
                        ; SQ2 channel
                        ;
                        ;   * 0 = no sound effect is being made on SQ2
                        ;
                        ;   * Non-zero = a sound effect is being made on SQ2

.effectOnNOISE

 SKIP 1                 ; Records whether a sound effect is being made on the
                        ; NOISE channel
                        ;
                        ;   * 0 = no sound effect is being made on NOISE
                        ;
                        ;   * Non-zero = a sound effect is being made on NOISE

.tuneSpeed

 SKIP 1                 ; The speed of the current tune, which can vary as the
                        ; tune plays

.tuneSpeedCopy

 SKIP 1                 ; The starting speed of the current tune, as stored in
                        ; the tune's data

.soundVibrato

 SKIP 4                 ; The four-byte seeds for adding randomised vibrato to
                        ; the current sound effect

.tuneProgress

 SKIP 1                 ; A variable for keeping track of progress while playing
                        ; the current tune, so we send data to the APU at the
                        ; correct time over multiple iterations of the MakeMusic
                        ; routine, according to the tune speed in tuneSpeed

.tuningAll

 SKIP 1                 ; The tuning value for all channels
                        ;
                        ; Gets added to each note's pitch in the SQ1, SQ2 and
                        ; TRI channels

.playMusic

 SKIP 1                 ; Controls whether to keep playing the current tune:
                        ;
                        ;   * 0 = do not keep playing the current tune
                        ;
                        ;   * $FF do keep playing the current tune
                        ;
                        ; The $FE note command stops the current tune and zeroes
                        ; this flag, and the only way to restart the music is
                        ; via the ChooseMusic routine
                        ;
                        ; A value of zero in this flag also prevents the
                        ; EnableSound routine from having any effect

.sectionDataSQ1

 SKIP 2                 ; The address of the note data for channel SQ1 of the
                        ; the current section of the current tune
                        ;
                        ; So if the current tune is tune 0 and we're playing
                        ; section 0, this would point to tune0Data_SQ1_0

.sectionListSQ1

 SKIP 2                 ; The address of the section list for channel SQ1 of
                        ; the current tune
                        ;
                        ; So if the current tune is tune 0, this would point to
                        ; tune0Data_SQ1

.nextSectionSQ1

 SKIP 2                 ; The next section for the SQ1 channel of the current
                        ; tune
                        ;
                        ; This is stored as the offset of the address of the
                        ; next section in the current tune for the SQ1 channel
                        ; (so this would be the offset within the tuneData0_SQ1
                        ; table for tune 0, for example)
                        ;
                        ; Adding 2 moves it on to the next section of the tune

.tuningSQ1

 SKIP 1                 ; The tuning value for the SQ1 channel
                        ;
                        ; Gets added to each note's pitch in the SQ1 channel

.startPauseSQ1

 SKIP 1                 ; Pause for this many iterations before starting to
                        ; process each batch of note data on channel SQ1

.pauseCountSQ1

 SKIP 1                 ; Pause for this many iterations before continuing to
                        ; process note data on channel SQ1, decrementing the
                        ; value for each paused iteration

.dutyLoopEnvSQ1

 SKIP 1                 ; The high nibble to use for SQ1_VOL, when setting the
                        ; following for the SQ1 channel:
                        ;
                        ;   * Bits 6-7    = duty pulse length
                        ;
                        ;   * Bit 5 set   = infinite play
                        ;   * Bit 5 clear = one-shot play
                        ;
                        ;   * Bit 4 set   = constant volume
                        ;   * Bit 4 clear = envelope volume

.sq1Sweep

 SKIP 1                 ; The value that we are going to send to the APU via
                        ; SQ1_SWEEP for the current tune

.pitchIndexSQ1

 SKIP 1                 ; The index of the entry within the pitch envelope to
                        ; be applied to the current tune on channel SQ1

.pitchEnvelopeSQ1

 SKIP 1                 ; The number of the pitch envelope to be applied to the
                        ; current tune on channel SQ1

.sq1LoCopy

 SKIP 1                 ; A copy of the value that we are going to send to the
                        ; APU via SQ1_LO for the current tune

.volumeIndexSQ1

 SKIP 1                 ; The index into the volume envelope data of the next
                        ; volume byte to apply to channel SQ1

.volumeRepeatSQ1

 SKIP 1                 ; The number of repeats to be applied to each byte in
                        ; the volume envelope on channel SQ1

.volumeCounterSQ1

 SKIP 1                 ; A counter for keeping track of repeated bytes from
                        ; the volume envelope on channel SQ1

.volumeEnvelopeSQ1

 SKIP 1                 ; The number of the volume envelope to be applied to the
                        ; current tune on channel SQ1

.applyVolumeSQ1

 SKIP 1                 ; A flag that determines whether to apply the volume
                        ; envelope to the SQ1 channel
                        ;
                        ;   * 0 = do not apply volume envelope
                        ;
                        ;   * $FF = apply volume envelope

.sectionDataSQ2

 SKIP 2                 ; The address of the note data for channel SQ2 of the
                        ; the current section of the current tune
                        ;
                        ; So if the current tune is tune 0 and we're playing
                        ; section 0, this would point to tune0Data_SQ2_0

.sectionListSQ2

 SKIP 2                 ; The address of the section list for channel SQ2 of
                        ; the current tune
                        ;
                        ; So if the current tune is tune 0, this would point to
                        ; tune0Data_SQ2

.nextSectionSQ2

 SKIP 2                 ; The next section for the SQ2 channel of the current
                        ; tune
                        ;
                        ; This is stored as the offset of the address of the
                        ; next section in the current tune for the SQ2 channel
                        ; (so this would be the offset within the tuneData0_SQ2
                        ; table for tune 0, for example)
                        ;
                        ; Adding 2 moves it on to the next section of the tune

.tuningSQ2

 SKIP 1                 ; The tuning value for the SQ2 channel
                        ;
                        ; Gets added to each note's pitch in the SQ2 channel

.startPauseSQ2

 SKIP 1                 ; Pause for this many iterations before starting to
                        ; process each batch of note data on channel SQ2

.pauseCountSQ2

 SKIP 1                 ; Pause for this many iterations before continuing to
                        ; process note data on channel SQ2, decrementing the
                        ; value for each paused iteration

.dutyLoopEnvSQ2

 SKIP 1                 ; The high nibble to use for SQ2_VOL, when setting the
                        ; following for the SQ2 channel:
                        ;
                        ;   * Bits 6-7    = duty pulse length
                        ;
                        ;   * Bit 5 set   = infinite play
                        ;   * Bit 5 clear = one-shot play
                        ;
                        ;   * Bit 4 set   = constant volume
                        ;   * Bit 4 clear = envelope volume

.sq2Sweep

 SKIP 1                 ; The value that we are going to send to the APU via
                        ; SQ2_SWEEP for the current tune

.pitchIndexSQ2

 SKIP 1                 ; The index of the entry within the pitch envelope to
                        ; be applied to the current tune on channel SQ2

.pitchEnvelopeSQ2

 SKIP 1                 ; The number of the pitch envelope to be applied to the
                        ; current tune on channel SQ2

.sq2LoCopy

 SKIP 1                 ; A copy of the value that we are going to send to the
                        ; APU via SQ2_LO for the current tune

.volumeIndexSQ2

 SKIP 1                 ; The index into the volume envelope data of the next
                        ; volume byte to apply to channel SQ2

.volumeRepeatSQ2

 SKIP 1                 ; The number of repeats to be applied to each byte in
                        ; the volume envelope on channel SQ2

.volumeCounterSQ2

 SKIP 1                 ; A counter for keeping track of repeated bytes from
                        ; the volume envelope on channel SQ2

.volumeEnvelopeSQ2

 SKIP 1                 ; The number of the volume envelope to be applied to the
                        ; current tune on channel SQ2

.applyVolumeSQ2

 SKIP 1                 ; A flag that determines whether to apply the volume
                        ; envelope to the SQ2 channel
                        ;
                        ;   * 0 = do not apply volume envelope
                        ;
                        ;   * $FF = apply volume envelope

.sectionDataTRI

 SKIP 2                 ; The address of the note data for channel TRI of the
                        ; the current section of the current tune
                        ;
                        ; So if the current tune is tune 0 and we're playing
                        ; section 0, this would point to tune0Data_TRI_0

.sectionListTRI

 SKIP 2                 ; The address of the section list for channel TRI of
                        ; the current tune
                        ;
                        ; So if the current tune is tune 0, this would point to
                        ; tune0Data_TRI

.nextSectionTRI

 SKIP 2                 ; The next section for the TRI channel of the current
                        ; tune
                        ;
                        ; This is stored as the offset of the address of the
                        ; next section in the current tune for the TRI channel
                        ; (so this would be the offset within the tuneData0_TRI
                        ; table for tune 0, for example)
                        ;
                        ; Adding 2 moves it on to the next section of the tune

.tuningTRI

 SKIP 1                 ; The tuning value for the TRI channel
                        ;
                        ; Gets added to each note's pitch in the TRI channel

.startPauseTRI

 SKIP 1                 ; Pause for this many iterations before starting to
                        ; process each batch of note data on channel TRI

.pauseCountTRI

 SKIP 1                 ; Pause for this many iterations before continuing to
                        ; process note data on channel TRI, decrementing the
                        ; value for each paused iteration

 SKIP 2                 ; These bytes appear to be unused

.pitchIndexTRI

 SKIP 1                 ; The index of the entry within the pitch envelope to
                        ; be applied to the current tune on channel TRI

.pitchEnvelopeTRI

 SKIP 1                 ; The number of the pitch envelope to be applied to the
                        ; current tune on channel TRI

.triLoCopy

 SKIP 1                 ; A copy of the value that we are going to send to the
                        ; APU via TRI_LO for the current tune

.volumeCounterTRI

 SKIP 1                 ; A counter for keeping track of repeated bytes from
                        ; the volume envelope on channel TRI

 SKIP 2                 ; These bytes appear to be unused

.volumeEnvelopeTRI

 SKIP 1                 ; The number of the volume envelope to be applied to the
                        ; current tune on channel TRI

 SKIP 1                 ; This byte appears to be unused

.sectionDataNOISE

 SKIP 2                 ; The address of the note data for channel NOISE of the
                        ; the current section of the current tune
                        ;
                        ; So if the current tune is tune 0 and we're playing
                        ; section 0, this would point to tune0Data_NOISE_0

.sectionListNOISE

 SKIP 2                 ; The address of the section list for channel NOISE of
                        ; the current tune
                        ;
                        ; So if the current tune is tune 0, this would point to
                        ; tune0Data_NOISE

.nextSectionNOISE

 SKIP 2                 ; The next section for the NOISE channel of the current
                        ; tune
                        ;
                        ; This is stored as the offset of the address of the
                        ; next section in the current tune for the NOISE channel
                        ; (so this would be the offset within the
                        ; tuneData0_NOISE table for tune 0, for example)
                        ;
                        ; Adding 2 moves it on to the next section of the tune

 SKIP 1                 ; This byte appears to be unused

.startPauseNOISE

 SKIP 1                 ; Pause for this many iterations before starting to
                        ; process each batch of note data on channel NOISE

.pauseCountNOISE

 SKIP 1                 ; Pause for this many iterations before continuing to
                        ; process note data on channel NOISE, decrementing the
                        ; value for each paused iteration

 SKIP 2                 ; These bytes appear to be unused

.pitchIndexNOISE

 SKIP 1                 ; The index of the entry within the pitch envelope to
                        ; be applied to the current tune on channel NOISE

.pitchEnvelopeNOISE

 SKIP 1                 ; The number of the pitch envelope to be applied to the
                        ; current tune on channel NOISE

.noiseLoCopy

 SKIP 1                 ; A copy of the value that we are going to send to the
                        ; APU via NOISE_LO for the current tune

.volumeIndexNOISE

 SKIP 1                 ; The index into the volume envelope data of the next
                        ; volume byte to apply to channel NOISE

.volumeRepeatNOISE

 SKIP 1                 ; The number of repeats to be applied to each byte in
                        ; the volume envelope on channel NOISE

.volumeCounterNOISE

 SKIP 1                 ; A counter for keeping track of repeated bytes from
                        ; the volume envelope on channel NOISE

.volumeEnvelopeNOISE

 SKIP 1                 ; The number of the volume envelope to be applied to the
                        ; current tune on channel NOISE

.applyVolumeNOISE

 SKIP 1                 ; A flag that determines whether to apply the volume
                        ; envelope to the NOISE channel
                        ;
                        ;   * 0 = do not apply volume envelope
                        ;
                        ;   * $FF = apply volume envelope

.sq1Volume

 SKIP 1                 ; The value that we are going to send to the APU via
                        ; SQ1_VOL for the current tune

 SKIP 1                 ; This byte appears to be unused

.sq1Lo

 SKIP 1                 ; The value that we are going to send to the APU via
                        ; SQ1_LO for the current tune

.sq1Hi

 SKIP 1                 ; The value that we are going to send to the APU via
                        ; SQ1_HI for the current tune

.sq2Volume

 SKIP 1                 ; The value that we are going to send to the APU via
                        ; SQ2_VOL for the current tune

 SKIP 1                 ; This byte appears to be unused

.sq2Lo

 SKIP 1                 ; The value that we are going to send to the APU via
                        ; SQ2_LO for the current tune

.sq2Hi

 SKIP 1                 ; The value that we are going to send to the APU via
                        ; SQ2_HI for the current tune

 SKIP 2                 ; These bytes appear to be unused

.triLo

 SKIP 1                 ; The value that we are going to send to the APU via
                        ; TRI_LO for the current tune

.triHi

 SKIP 1                 ; The value that we are going to send to the APU via
                        ; TRI_HI for the current tune

.noiseVolume

 SKIP 1                 ; The value that we are going to send to the APU via
                        ; NOISE_VOL for the current tune

 SKIP 1                 ; This byte appears to be unused

.noiseLo

 SKIP 1                 ; The value that we are going to send to the APU via
                        ; NOISE_LO for the current tune

 SKIP 1                 ; This byte appears to be unused

.FRIN

 SKIP NOSH + 1          ; Slots for the ships in the local bubble of universe
                        ;
                        ; There are #NOSH + 1 slots, but the ship-spawning
                        ; routine at NWSHP only populates #NOSH of them, so
                        ; there are 9 slots but only 8 are used for ships
                        ; (the last slot is effectively used as a null
                        ; terminator when shuffling the slots down in the
                        ; KILLSHP routine)
                        ;
                        ; See the deep dive on "The local bubble of universe"
                        ; for details of how Elite stores the local universe in
                        ; FRIN, UNIV and K%

.JUNK

 SKIP 1                 ; The amount of junk in the local bubble
                        ;
                        ; "Junk" is defined as being one of these:
                        ;
                        ;   * Escape pod
                        ;   * Alloy plate
                        ;   * Cargo canister
                        ;   * Asteroid
                        ;   * Splinter
                        ;   * Shuttle
                        ;   * Transporter

.scannerNumber

 SKIP 10                ; Details of which scanner numbers are allocated to
                        ; ships on the scanner
                        ;
                        ; Bytes 1 to 8 contain the following:
                        ;
                        ;   * $FF indicates that this scanner number (1 to 8)
                        ;     is allocated to a ship so that is it shown on
                        ;     the scanner (the scanner number is stored in byte
                        ;     #33 of the ship's data block)
                        ;
                        ;   * 0 indicates that this scanner number (1 to 8) is
                        ;     not yet allocated to a ship
                        ;
                        ; Bytes 0 and 9 in the table are unused

.scannerColour

 SKIP 10                ; The colour of each ship number on the scanner, stored
                        ; as the sprite palette number for that ship's three
                        ; scanner sprites
                        ;
                        ; Bytes 1 to 8 contain palettes for ships with non-zero
                        ; entries in the scannerNumber table (i.e. for ships on
                        ; the scanner)
                        ;
                        ; Bytes 0 and 9 are unused

.auto

 SKIP 1                 ; Docking computer activation status
                        ;
                        ;   * 0 = Docking computer is off
                        ;
                        ;   * Non-zero = Docking computer is running

.ECMP

 SKIP 1                 ; Our E.C.M. status
                        ;
                        ;   * 0 = E.C.M. is off
                        ;
                        ;   * Non-zero = E.C.M. is on

.MJ

 SKIP 1                 ; Are we in witchspace (i.e. have we mis-jumped)?
                        ;
                        ;   * 0 = no, we are in normal space
                        ;
                        ;   * $FF = yes, we are in witchspace

.CABTMP

 SKIP 1                 ; Cabin temperature
                        ;
                        ; The ambient cabin temperature in deep space is 30,
                        ; which is displayed as one notch on the dashboard bar
                        ;
                        ; We get higher temperatures closer to the sun

.LAS2

 SKIP 1                 ; Laser power for the current laser
                        ;
                        ;   * Bits 0-6 contain the laser power of the current
                        ;     space view
                        ;
                        ;   * Bit 7 denotes whether or not the laser pulses:
                        ;
                        ;     * 0 = pulsing laser
                        ;
                        ;     * 1 = beam laser (i.e. always on)

.MSAR

 SKIP 1                 ; The targeting state of our leftmost missile
                        ;
                        ;   * 0 = missile is not looking for a target, or it
                        ;     already has a target lock (indicator is not
                        ;     flashing red)
                        ;
                        ;   * Non-zero = missile is currently looking for a
                        ;     target (indicator is flashing red)

.VIEW

 SKIP 1                 ; The number of the current space view
                        ;
                        ;   * 0 = front
                        ;   * 1 = rear
                        ;   * 2 = left
                        ;   * 3 = right
                        ;   * 4 = generating a new space view

.LASCT

 SKIP 1                 ; The laser pulse count for the current laser
                        ;
                        ; This is a counter that defines the gap between the
                        ; pulses of a pulse laser. It is set as follows:
                        ;
                        ;   * 0 for a beam laser
                        ;
                        ;   * 10 for a pulse laser
                        ;
                        ; It gets decremented by 2 on each iteration round the
                        ; main game loop and is set to a non-zero value for
                        ; pulse lasers only
                        ;
                        ; The laser only fires when the value of LASCT hits
                        ; zero, so for pulse lasers with a value of 10, that
                        ; means the laser fires once every four iterations
                        ; round the main game loop (LASCT = 10, 6, 2, 0)
                        ;
                        ; In comparison, beam lasers fire continuously as the
                        ; value of LASCT is always 0

.GNTMP

 SKIP 1                 ; Laser temperature (or "gun temperature")
                        ;
                        ; If the laser temperature exceeds 242 then the laser
                        ; overheats and cannot be fired again until it has
                        ; cooled down

.HFX

 SKIP 1                 ; This flag is unused in this version of Elite. In the
                        ; other versions, setting HFX to a non-zero value makes
                        ; the hyperspace rings multi-coloured, but the NES
                        ; has a different hyperspace effect, so this variable is
                        ; not used

.EV

 SKIP 1                 ; The "extra vessels" spawning counter
                        ;
                        ; This counter is set to 0 on arrival in a system and
                        ; following an in-system jump, and is bumped up when we
                        ; spawn bounty hunters or pirates (i.e. "extra vessels")
                        ;
                        ; It decreases by 1 each time we consider spawning more
                        ; "extra vessels" in part 4 of the main game loop, so
                        ; increasing the value of EV has the effect of delaying
                        ; the spawning of more vessels
                        ;
                        ; In other words, this counter stops bounty hunters and
                        ; pirates from continually appearing, and ensures that
                        ; there's a delay between spawnings

.DLY

 SKIP 1                 ; In-flight message delay
                        ;
                        ; This counter is used to keep an in-flight message up
                        ; for a specified time before it gets removed. The value
                        ; in DLY is decremented each time we start another
                        ; iteration of the main game loop at TT100

.de

 SKIP 1                 ; Equipment destruction flag
                        ;
                        ;   * Bit 1 denotes whether or not the in-flight message
                        ;     about to be shown by the MESS routine is about
                        ;     destroyed equipment:
                        ;
                        ;     * 0 = the message is shown normally
                        ;
                        ;     * 1 = the string " DESTROYED" gets added to the
                        ;       end of the message

.selectedSystemFlag

 SKIP 1                 ; Flags for the currently selected system
                        ;
                        ;   * Bit 6 is set when we can hyperspace to the
                        ;     currently selected system, clear otherwise
                        ;
                        ;   * Bit 7 is set when there is a currently selected
                        ;     system, clear otherwise (such as when we are
                        ;     moving the crosshairs between systems)

.NAME

 SKIP 7                 ; The current commander name
                        ;
                        ; The commander name can be up to 7 characters long

.SVC

 SKIP 1                 ; The save count
                        ;
                        ;   * Bits 0-6 contains the save count, which gets
                        ;     incremented when buying or selling equipment or
                        ;     cargo, or launching from a station (at which point
                        ;     bit 7 also gets set, so we only increment once
                        ;     between each save)
                        ;
                        ;   * Bit 7:
                        ;
                        ;       * 0 = The save counter can be incremented
                        ;
                        ;       * 1 = We have already incremented the save
                        ;             counter for this commander but have not
                        ;             saved it yet, so do not increment it again
                        ;             until the file is saved (at which point we
                        ;             clear bit 7 again)

.TP

 SKIP 1                 ; The current mission status
                        ;
                        ;   * Bits 0-1 = Mission 1 status
                        ;
                        ;     * %00 = Mission not started
                        ;     * %01 = Mission in progress, hunting for ship
                        ;     * %11 = Constrictor killed, not debriefed yet
                        ;     * %10 = Mission and debrief complete
                        ;
                        ;   * Bits 2-3 = Mission 2 status
                        ;
                        ;     * %00 = Mission not started
                        ;     * %01 = Mission in progress, plans not picked up
                        ;     * %10 = Mission in progress, plans picked up
                        ;     * %11 = Mission complete
                        ;
                        ;   * Bit 4 = Trumble mission status
                        ;
                        ;     * %0 = Trumbles not yet offered
                        ;     * %1 = Trumbles accepted or declined

.QQ0

 SKIP 1                 ; The current system's galactic x-coordinate (0-256)

.QQ1

 SKIP 1                 ; The current system's galactic y-coordinate (0-256)

.CASH

 SKIP 4                 ; Our current cash pot
                        ;
                        ; The cash stash is stored as a 32-bit unsigned integer,
                        ; with the most significant byte in CASH and the least
                        ; significant in CASH+3. This is big-endian, which is
                        ; the opposite way round to most of the numbers used in
                        ; Elite - to use our notation for multi-byte numbers,
                        ; the amount of cash is CASH(0 1 2 3)

.QQ14

 SKIP 1                 ; Our current fuel level (0-70)
                        ;
                        ; The fuel level is stored as the number of light years
                        ; multiplied by 10, so QQ14 = 1 represents 0.1 light
                        ; years, and the maximum possible value is 70, for 7.0
                        ; light years

.COK

 SKIP 1                 ; A flag to record whether cheat mode has been applied
                        ; (by renaming the commander file to CHEATER, BETRUG or
                        ; TRICHER)
                        ;
                        ;   * Bit 7 clear = cheat mode has not been applied
                        ;
                        ;   * Bit 7 set = cheat mode has been applied

.GCNT

 SKIP 1                 ; The number of the current galaxy (0-7)
                        ;
                        ; When this is displayed in-game, 1 is added to the
                        ; number, so we start in galaxy 1 in-game, but it's
                        ; stored as galaxy 0 internally
                        ;
                        ; The galaxy number increases by one every time a
                        ; galactic hyperdrive is used, and wraps back around to
                        ; the start after eight galaxies

.LASER

 SKIP 4                 ; The specifications of the lasers fitted to each of the
                        ; four space views:
                        ;
                        ;   * Byte #0 = front view
                        ;   * Byte #1 = rear view
                        ;   * Byte #2 = left view
                        ;   * Byte #3 = right view
                        ;
                        ; For each of the views:
                        ;
                        ;   * 0 = no laser is fitted to this view
                        ;
                        ;   * Non-zero = a laser is fitted to this view, with
                        ;     the following specification:
                        ;
                        ;     * Bits 0-6 contain the laser's power
                        ;
                        ;     * Bit 7 determines whether or not the laser pulses
                        ;       (0 = pulse or mining laser) or is always on
                        ;       (1 = beam or military laser)

.CRGO

 SKIP 1                 ; Our ship's cargo capacity
                        ;
                        ;   * 22 = standard cargo bay of 20 tonnes
                        ;
                        ;   * 37 = large cargo bay of 35 tonnes
                        ;
                        ; The value is two greater than the actual capacity to
                        ; make the maths in tnpr slightly more efficient

.QQ20

 SKIP 17                ; The contents of our cargo hold
                        ;
                        ; The amount of market item X that we have in our hold
                        ; can be found in the X-th byte of QQ20. For example:
                        ;
                        ;   * QQ20 contains the amount of food (item 0)
                        ;
                        ;   * QQ20+7 contains the amount of computers (item 7)
                        ;
                        ; See QQ23 for a list of market item numbers and their
                        ; storage units

.ECM

 SKIP 1                 ; E.C.M. system
                        ;
                        ;   * 0 = not fitted
                        ;
                        ;   * $FF = fitted

.BST

 SKIP 1                 ; Fuel scoops (BST stands for "barrel status")
                        ;
                        ;   * 0 = not fitted
                        ;
                        ;   * $FF = fitted

.BOMB

 SKIP 1                 ; Energy bomb
                        ;
                        ;   * 0 = not fitted
                        ;
                        ;   * $7F = fitted

.ENGY

 SKIP 1                 ; Energy unit
                        ;
                        ;   * 0 = not fitted
                        ;
                        ;   * Non-zero = fitted
                        ;
                        ; The actual value determines the refresh rate of our
                        ; energy banks, as they refresh by ENGY+1 each time (so
                        ; our ship's energy level goes up by 2 each time if we
                        ; have an energy unit fitted, otherwise it goes up by 1)

.DKCMP

 SKIP 1                 ; Docking computer
                        ;
                        ;   * 0 = not fitted
                        ;
                        ;   * $FF = fitted

.GHYP

 SKIP 1                 ; Galactic hyperdrive
                        ;
                        ;   * 0 = not fitted
                        ;
                        ;   * $FF = fitted

.ESCP

 SKIP 1                 ; Escape pod
                        ;
                        ;   * 0 = not fitted
                        ;
                        ;   * $FF = fitted

.TRIBBLE

 SKIP 2                 ; The number of Trumbles in the cargo hold

.TALLYL

 SKIP 1                 ; Combat rank fraction
                        ;
                        ; Contains the fraction part of the kill count, which
                        ; together with the integer in TALLY(1 0) determines our
                        ; combat rank. The fraction is stored as the numerator
                        ; of a fraction with a denominator of 256, so a TALLYL
                        ; of 128 would represent 0.5 (i.e. 128 / 256)

.NOMSL

 SKIP 1                 ; The number of missiles we have fitted (0-4)

.FIST

 SKIP 1                 ; Our legal status (FIST stands for "fugitive/innocent
                        ; status"):
                        ;
                        ;   * 0 = Clean
                        ;
                        ;   * 1-49 = Offender
                        ;
                        ;   * 50+ = Fugitive
                        ;
                        ; You get 64 points if you kill a cop, so that's a fast
                        ; ticket to fugitive status

.AVL

 SKIP 17                ; Market availability in the current system
                        ;
                        ; The available amount of market item X is stored in
                        ; the X-th byte of AVL, so for example:
                        ;
                        ;   * AVL contains the amount of food (item 0)
                        ;
                        ;   * AVL+7 contains the amount of computers (item 7)
                        ;
                        ; See QQ23 for a list of market item numbers and their
                        ; storage units, and the deep dive on "Market item
                        ; prices and availability" for details of the algorithm
                        ; used for calculating each item's availability

.QQ26

 SKIP 1                 ; A random value used to randomise market data
                        ;
                        ; This value is set to a new random number for each
                        ; change of system, so we can add a random factor into
                        ; the calculations for market prices (for details of how
                        ; this is used, see the deep dive on "Market prices")

.TALLY

 SKIP 2                 ; Our combat rank
                        ;
                        ; The combat rank is stored as the number of kills, in a
                        ; 16-bit number TALLY(1 0) - so the high byte is in
                        ; TALLY+1 and the low byte in TALLY
                        ;
                        ; There is also a fractional part of the kill count,
                        ; which is stored in TALLYL
                        ;
                        ; The NES version calculates the combat rank differently
                        ; to the other versions of Elite. The combat status is
                        ; given by the number of kills in TALLY(1 0), as
                        ; follows:
                        ;
                        ;   * Harmless        when TALLY(1 0) = 0 or 1
                        ;   * Mostly Harmless when TALLY(1 0) = 2 to 7
                        ;   * Poor            when TALLY(1 0) = 8 to 23
                        ;   * Average         when TALLY(1 0) = 24 to 43
                        ;   * Above Average   when TALLY(1 0) = 44 to 129
                        ;   * Competent       when TALLY(1 0) = 130 to 511
                        ;   * Dangerous       when TALLY(1 0) = 512 to 2559
                        ;   * Deadly          when TALLY(1 0) = 2560 to 6399
                        ;   * Elite           when TALLY(1 0) = 6400 or more
                        ;
                        ; You can see the rating calculation in the
                        ; PrintCombatRank subroutine

 SKIP 1                 ; This byte appears to be unused

.QQ21

 SKIP 6                 ; The three 16-bit seeds for the current galaxy
                        ;
                        ; These seeds define system 0 in the current galaxy, so
                        ; they can be used as a starting point to generate all
                        ; 256 systems in the galaxy
                        ;
                        ; Using a galactic hyperdrive rotates each byte to the
                        ; left (rolling each byte within itself) to get the
                        ; seeds for the next galaxy, so after eight galactic
                        ; jumps, the seeds roll around to the first galaxy again
                        ;
                        ; See the deep dives on "Galaxy and system seeds" and
                        ; "Twisting the system seeds" for more details

.NOSTM

 SKIP 1                 ; The number of stardust particles shown on screen,
                        ; which is 20 (#NOST) for normal space, and 3 for
                        ; witchspace

.burstSpriteIndex

 SKIP 1                 ; The index into the sprite buffer of the explosion
                        ; burst sprite that is set up in DrawExplosionBurst

.unusedVariable

 SKIP 1                 ; This variable is zeroed in RES2 but is never read

.chargeDockingFee

 SKIP 1                 ; Records whether we have been charged a docking fee, so
                        ; we don't get charged twice:
                        ;
                        ;   * 0 = we have not been charged a docking fee
                        ;
                        ;   * Non-zero = we have been charged a docking fee
                        ;
                        ; The docking fee is 5.0 credits

.priceDebug

 SKIP 1                 ; This is only referenced by some disabled test code in
                        ; the prx routine, where it was presumably used for
                        ; testing different equipment prices

.DAMP

 SKIP 1                 ; Controller damping configuration setting
                        ;
                        ;   * 0 = damping is disabled
                        ;
                        ;   * $FF = damping is enabled (default)

.JSTGY

 SKIP 1                 ; Reverse controller y-axis configuration setting
                        ;
                        ;   * 0 = standard Y-axis (default)
                        ;
                        ;   * $FF = reversed Y-axis

.DNOIZ

 SKIP 1                 ; Sound on/off configuration setting
                        ;
                        ;   * 0 = sound is off
                        ;
                        ;   * $FF = sound is on (default)

.disableMusic

 SKIP 1                 ; Music on/off configuration setting
                        ;
                        ;   * 0 = music is on (default)
                        ;
                        ;   * Non-zero = sound is off

.autoPlayDemo

 SKIP 1                 ; Controls whether to play the demo automatically (which
                        ; happens after it is left idle for a while)
                        ;
                        ;   * Bit 7 clear = do not play the demo automatically
                        ;
                        ;   * Bit 7 set = play the demo automatically using
                        ;                 the controller key presses in the
                        ;                 autoPlayKeys table

.bitplaneFlags

 SKIP 1                 ; Flags for bitplane 0 that control the sending of data
                        ; for this bitplane to the PPU during VBlank in the NMI
                        ; handler:
                        ;
                        ;   * Bit 0 is ignored and is always clear
                        ;
                        ;   * Bit 1 is ignored and is always clear
                        ;
                        ;   * Bit 2 controls whether to override the number of
                        ;     the last tile or pattern to send to the PPU:
                        ;
                        ;     * 0 = set the last tile number to lastNameTile or
                        ;           the last pattern to lastPattern for this
                        ;           bitplane (when sending nametable and pattern
                        ;           entries respectively)
                        ;
                        ;     * 1 = set the last tile number to 128 (which means
                        ;           tile 8 * 128 = 1024)
                        ;
                        ;   * Bit 3 controls the clearing of this bitplane's
                        ;     buffer in the NMI handler, once it has been sent
                        ;     to the PPU:
                        ;
                        ;     * 0 = do not clear this bitplane's buffer
                        ;
                        ;     * 1 = clear this bitplane's buffer once it has
                        ;           been sent to the PPU
                        ;
                        ;   * Bit 4 lets us query whether a tile data transfer
                        ;     is already in progress for this bitplane:
                        ;
                        ;     * 0 = we are not currently in the process of
                        ;           sending tile data to the PPU for this
                        ;           bitplane
                        ;
                        ;     * 1 = we are in the process of sending tile data
                        ;           to the PPU for the this bitplane, possibly
                        ;           spread across multiple VBlanks
                        ;
                        ;   * Bit 5 lets us query whether we have already sent
                        ;     all the data to the PPU for this bitplane:
                        ;
                        ;     * 0 = we have not already sent all the data to the
                        ;           PPU for this bitplane
                        ;
                        ;     * 1 = we have already sent all the data to the PPU
                        ;           for this bitplane
                        ;
                        ;   * Bit 6 determines whether to send nametable data as
                        ;     well as pattern data:
                        ;
                        ;     * 0 = only send pattern data for this bitplane,
                        ;           and stop sending it if the other bitplane is
                        ;           ready to be sent
                        ;
                        ;     * 1 = send both pattern and nametable data for
                        ;           this bitplane
                        ;
                        ;   * Bit 7 determines whether we should send data to
                        ;     the PPU for this bitplane:
                        ;
                        ;     * 0 = do not send data to the PPU
                        ;
                        ;     * 1 = send data to the PPU

 SKIP 1                 ; Flags for bitplane 1 (see above)

.nmiCounter

 SKIP 1                 ; A counter that increments every VBlank at the start of
                        ; the NMI handler

.screenReset

 SKIP 1                 ; Gets set to 245 when the screen is reset, but this
                        ; value is only read once (in SetupViewInNMI) and the
                        ; value is ignored, so this doesn't have any effect

.DTW6

 SKIP 1                 ; A flag to denote whether printing in lower case is
                        ; enabled for extended text tokens
                        ;
                        ;   * %10000000 = lower case is enabled
                        ;
                        ;   * %00000000 = lower case is not enabled

.DTW2

 SKIP 1                 ; A flag that indicates whether we are currently
                        ; printing a word
                        ;
                        ;   * 0 = we are currently printing a word
                        ;
                        ;   * Non-zero = we are not currently printing a word

.DTW3

 SKIP 1                 ; A flag for switching between standard and extended
                        ; text tokens
                        ;
                        ;   * %00000000 = print extended tokens (i.e. those in
                        ;                 TKN1 and RUTOK)
                        ;
                        ;   * %11111111 = print standard tokens (i.e. those in
                        ;                 QQ18)

.DTW4

 SKIP 1                 ; Flags that govern how justified extended text tokens
                        ; are printed
                        ;
                        ;   * Bit 7: 1 = justify text
                        ;            0 = do not justify text
                        ;
                        ;   * Bit 6: 1 = buffer the entire token before
                        ;                printing, including carriage returns
                        ;                (used for in-flight messages only)
                        ;            0 = print the contents of the buffer
                        ;                whenever a carriage return appears
                        ;                in the token

.DTW5

 SKIP 1                 ; The size of the justified text buffer at BUF

.DTW1

 SKIP 1                 ; A mask for applying the lower case part of Sentence
                        ; Case to extended text tokens
                        ;
                        ;   * %10000000 = apply lower case to the second letter
                        ;                 of a word onwards
                        ;
                        ;   * %00000000 = do not change case to lower case

.DTW8

 SKIP 1                 ; A mask for capitalising the next letter in an extended
                        ; text token
                        ;
                        ;   * %00000000 = capitalise the next letter
                        ;
                        ;   * %11111111 = do not change case

.XP

 SKIP 1                 ; The x-coordinate of the current character as we
                        ; construct the lines for the Star Wars scroll text

.YP

 SKIP 1                 ; The y-coordinate of the current character as we
                        ; construct the lines for the Star Wars scroll text

.titleShip

 SKIP 0                 ; Used to store the current ship number in the title
                        ; screen

.firstBox

 SKIP 0                 ; Used to detect the first iteration of the box-drawing
                        ; loop when drawing the launch tunnel

.scrollProgress

 SKIP 1                 ; Keeps track of the progress of the demo scroll text,
                        ; starting from zero and increasing as the text scrolls
                        ; up the screen

.decimalPoint

 SKIP 1                 ; The decimal point character for the chosen language

 SKIP 2                 ; These bytes appear to be unused

.LAS

 SKIP 1                 ; Contains the laser power of the laser fitted to the
                        ; current space view (or 0 if there is no laser fitted
                        ; to the current view)
                        ;
                        ; This gets set to bits 0-6 of the laser power byte from
                        ; the commander data block, which contains the laser's
                        ; power (bit 7 doesn't denote laser power, just whether
                        ; or not the laser pulses, so that is not stored here)

.MSTG

 SKIP 1                 ; The current missile lock target
                        ;
                        ;   * $FF = no target
                        ;
                        ;   * 1-8 = the slot number of the ship that our
                        ;           missile is locked onto

.scrollTextSpeed

 SKIP 1                 ; Controls the speed of the scroll text in the demo

.KL

 SKIP 0                 ; The following bytes implement a key logger that gets
                        ; updated according to the controller button presses
                        ;
                        ; This enables code from the BBC Micro version to be
                        ; reused without rewriting the key press logic to work
                        ; with the NES controllers, as it's easier just to
                        ; populate the BBC's key logger table, so the code
                        ; thinks that keys are being pressed when they are
                        ; actually controller buttons

.KY1

 SKIP 1                 ; One pilot is configured and the down and B buttons are
                        ; both being pressed on controller 1
                        ;
                        ; Or two pilots are configured and the B button is being
                        ; pressed on controller 2
                        ;
                        ;   * 0 = no
                        ;
                        ;   * $FF = yes

.KY2

 SKIP 1                 ; One pilot is configured and the up and B buttons are
                        ; both being pressed on controller 1
                        ;
                        ; Or two pilots are configured and the A button is being
                        ; pressed on controller 2
                        ;
                        ;   * 0 = no
                        ;
                        ;   * $FF = yes

.KY3

 SKIP 1                 ; One pilot is configured and the left button is being
                        ; pressed on controller 1 (and the B button is not being
                        ; pressed)
                        ;
                        ; Or two pilots are configured and the left button is
                        ; being pressed on controller 2
                        ;
                        ;   * 0 = no
                        ;
                        ;   * $FF = yes

.KY4

 SKIP 1                 ; One pilot is configured and the right button is being
                        ; pressed on controller 1 (and the B button is not being
                        ; pressed)
                        ;
                        ; Or two pilots are configured and the right button is
                        ; being pressed on controller 2
                        ;
                        ;   * 0 = no
                        ;
                        ;   * $FF = yes

.KY5

 SKIP 1                 ; One pilot is configured and the down button is being
                        ; pressed on controller 1 (and the B button is not being
                        ; pressed)
                        ;
                        ; Or two pilots are configured and the down button is
                        ; being pressed on controller 2
                        ;
                        ;   * 0 = no
                        ;
                        ;   * $FF = yes

.KY6

 SKIP 1                 ; One pilot is configured and the up button is being
                        ; pressed on controller 1 (and the B button is not being
                        ; pressed)
                        ;
                        ; Or two pilots are configured and the up button is
                        ; being pressed on controller 2
                        ;
                        ;   * 0 = no
                        ;
                        ;   * $FF = yes

.KY7

 SKIP 1                 ; The A button is being pressed on controller 1 (fire
                        ; lasers)
                        ;
                        ;   * 0 = no
                        ;
                        ;   * Bit 7 set = yes

.cloudSize

 SKIP 1                 ; Used to store the explosion cloud size in PTCLS

.soundByteSQ1

 SKIP 14                ; The 14 sound bytes for the sound effect being made
                        ; on channel SQ1

.soundLoSQ1

 SKIP 1                 ; The value that we are going to send to the APU via
                        ; SQ1_LO for the current sound effect

.soundHiSQ1

 SKIP 1                 ; The value that we are going to send to the APU via
                        ; SQ1_HI for the current sound effect

.soundPitCountSQ1

 SKIP 1                 ; Controls how often we send pitch data to the APU for
                        ; the sound effect on channel SQ1
                        ;
                        ; Specifically, pitch data is sent every
                        ; soundPitCountSQ1 iterations

.soundPitchEnvSQ1

 SKIP 1                 ; Controls how often we apply the pitch envelope to the
                        ; sound effect on channel SQ1
                        ;
                        ; Specifically, we apply the changes in the pitch
                        ; envelope every soundPitchEnvSQ1 iterations

.soundVolIndexSQ1

 SKIP 1                 ; The index into the volume envelope data of the next
                        ; volume byte to apply to the sound effect on channel
                        ; SQ1

.soundVolCountSQ1

 SKIP 1                 ; Controls how often we apply the volume envelope to the
                        ; sound effect on channel SQ1
                        ;
                        ; Specifically, one entry from the volume envelope is
                        ; applied every soundVolCountSQ1 iterations

.soundByteSQ2

 SKIP 14                ; The 14 sound bytes for the sound effect being made
                        ; on channel SQ2

.soundLoSQ2

 SKIP 1                 ; The value that we are going to send to the APU via
                        ; SQ2_LO for the current sound effect

.soundHiSQ2

 SKIP 1                 ; The value that we are going to send to the APU via
                        ; SQ2_HI for the current sound effect

.soundPitCountSQ2

 SKIP 1                 ; Controls how often we send pitch data to the APU for
                        ; the sound effect on channel SQ2
                        ;
                        ; Specifically, pitch data is sent every
                        ; soundPitCountSQ2 iterations

.soundPitchEnvSQ2

 SKIP 1                 ; Controls how often we apply the pitch envelope to the
                        ; sound effect on channel SQ2
                        ;
                        ; Specifically, we apply the changes in the pitch
                        ; envelope every soundPitchEnvSQ2 iterations

.soundVolIndexSQ2

 SKIP 1                 ; The index into the volume envelope data of the next
                        ; volume byte to apply to the sound effect on channel
                        ; SQ2

.soundVolCountSQ2

 SKIP 1                 ; Controls how often we apply the volume envelope to the
                        ; sound effect on channel SQ2
                        ;
                        ; Specifically, one entry from the volume envelope is
                        ; applied every soundVolCountSQ2 iterations

.soundByteNOISE

 SKIP 14                ; The 14 sound bytes for the sound effect being made
                        ; on channel NOISE

.soundLoNOISE

 SKIP 1                 ; The value that we are going to send to the APU via
                        ; NOISE_LO for the current sound effect

.soundHiNOISE

 SKIP 1                 ; The value that we are going to send to the APU via
                        ; NOISE_HI for the current sound effect

.soundPitCountNOISE

 SKIP 1                 ; Controls how often we send pitch data to the APU for
                        ; the sound effect on channel NOISE
                        ;
                        ; Specifically, pitch data is sent every
                        ; soundPitCountNOISE iterations

.soundPitchEnvNOISE

 SKIP 1                 ; Controls how often we apply the pitch envelope to the
                        ; sound effect on channel NOISE
                        ;
                        ; Specifically, we apply the changes in the pitch
                        ; envelope every soundPitchEnvNOISE iterations

.soundVolIndexNOISE

 SKIP 1                 ; The index into the volume envelope data of the next
                        ; volume byte to apply to the sound effect on channel
                        ; NOISE

.soundVolCountNOISE

 SKIP 1                 ; Controls how often we apply the volume envelope to the
                        ; sound effect on channel NOISE
                        ;
                        ; Specifically, one entry from the volume envelope is
                        ; applied every soundVolCountNOISE iterations

.soundVolumeSQ1

 SKIP 2                 ; The address of the volume envelope data for the sound
                        ; effect currently being made on channel SQ1

.soundVolumeSQ2

 SKIP 2                 ; The address of the volume envelope data for the sound
                        ; effect currently being made on channel SQ2

.soundVolumeNOISE

 SKIP 2                 ; The address of the volume envelope data for the sound
                        ; effect currently being made on channel NOISE

.QQ19

 SKIP 6                 ; Temporary storage, used in a number of places

.selectedSystem

 SKIP 6                 ; The three 16-bit seeds for the selected system, i.e.
                        ; the one we most recently snapped the crosshairs to
                        ; in a chart view

.K2

 SKIP 4                 ; Temporary storage, used in a number of places

.demoInProgress

 SKIP 1                 ; A flag to determine whether we are playing the demo:
                        ;
                        ;   * 0 = we are not playing the demo
                        ;
                        ;   * Non-zero = we are initialising or playing the demo
                        ;
                        ;   * Bit 7 set = we are initialising the demo

.newTune

 SKIP 1                 ; The number of the new tune when choosing the
                        ; background music
                        ;
                        ;   * Bits 0-6 = the tune number (1-4)
                        ;                0 indicates no tune is selected
                        ;
                        ;   * Bit 7 set = we are still in the process of
                        ;                 changing to this tune

IF _PAL

.pointerTimerB

 SKIP 1                 ; A timer used in the PAL version to detect the B button
                        ; being pressed twice in quick succession (a double-tap)
                        ;
                        ; The MoveIconBarPointer routine sets pointerTimerB to 1
                        ; and pointerTimer to 40 when it detects a tap on the B
                        ; button
                        ;
                        ; In successive calls to MoveIconBarPointer, while
                        ; pointerTimerB is non-zero, the MoveIconBarPointer
                        ; routine keeps a look-out for a second tap of the B
                        ; button, and if it detects one, it's a double-tap
                        ;
                        ; When the timer in pointerTimer runs down to zero,
                        ; pointerTimerB is also zeroed, so if a second tap is
                        ; detected within 40 VBlanks, it is deemed to be a
                        ; double-tap

ENDIF

.showIconBarPointer

 SKIP 1                 ; Controls whether to show the icon bar pointer
                        ;
                        ;   * 0 = do not show the icon bar pointer
                        ;
                        ;   * $FF = show the icon bar pointer

.xIconBarPointer

 SKIP 1                 ; The x-coordinate of the icon bar pointer
                        ;
                        ; Each of the 12 buttons on the bar is positioned at an
                        ; interval of 4, so the buttons have x-coordinates of
                        ; of 0, 4, 8 and so on, up to 44 for the rightmost
                        ; button
                        ;
                        ; This value is multiplied by 5 to get the button's
                        ; pixel coordinate

.yIconBarPointer

 SKIP 1                 ; The y-coordinate of the icon bar pointer
                        ;
                        ; This is either 148 (when the dashboard is visible) or
                        ; 204 (when there is no dashboard and the icon bar is
                        ; along the bottom of the screen)

.xPointerDelta

 SKIP 1                 ; The direction in which the icon bar pointer is moving,
                        ; expressed as a delta to add to the x-coordinate of the
                        ; pointer sprites
                        ;
                        ;   * 0 = pointer is not moving
                        ;
                        ;   * 1 = pointer is moving to the right
                        ;
                        ;   * -1 = pointer is moving to the left

.pointerMoveCounter

 SKIP 1                 ; The position of the icon bar pointer as it moves
                        ; between icons, counting down from 12 (at the start of
                        ; the move) to 0 (at the end of the move)

.iconBarType

 SKIP 1                 ; The type of the current icon bar:
                        ;
                        ;   * 0 = Docked
                        ;
                        ;   * 1 = Flight
                        ;
                        ;   * 2 = Charts
                        ;
                        ;   * 3 = Pause
                        ;
                        ;   * 4 = Title screen copyright message
                        ;
                        ;   * $FF = Hide the icon bar on row 27

.iconBarChoice

 SKIP 1                 ; The number of the icon bar button that's just been
                        ; selected
                        ;
                        ;   * 0 means no button has been selected
                        ;
                        ;   * A button number from the iconBarButtons table
                        ;     means that button has been selected by pressing
                        ;     Select on that button (or the B button has been
                        ;     tapped twice)
                        ;
                        ;   * 80 means the Start has been pressed to pause the
                        ;     game
                        ;
                        ; This variable is set in the NMI handler, so the
                        ; selection is recorded in the background

 SKIP 1                 ; This byte appears to be unused

.pointerTimer

 SKIP 1                 ; A timer that counts down by 1 on each call to the
                        ; MoveIconBarPointer routine, so that a double-tap
                        ; on the B button can be interpreted as such

.pointerPressedB

 SKIP 1                 ; Controls whether the MoveIconBarPointer routine looks
                        ; for a second tap of the B button when trying to detect
                        ; a double-tap on the B button
                        ;
                        ;   * 0 = do not look for a second tap
                        ;
                        ;   * Non-zero = do look for a second tap

.nmiStoreA

 SKIP 1                 ; Temporary storage for the A register during NMI

.nmiStoreX

 SKIP 1                 ; Temporary storage for the X register during NMI

.nmiStoreY

 SKIP 1                 ; Temporary storage for the Y register during NMI

.picturePattern

 SKIP 1                 ; The number of the first free pattern where commander
                        ; and system images can be stored in the buffers

.sendDashboardToPPU

 SKIP 1                 ; A flag that controls whether we send the dashboard to
                        ; the PPU during the main loop
                        ;
                        ;   * 0 = do not send the dashboard
                        ;
                        ;   * $FF = do send the dashboard
                        ;
                        ; Flips between 0 or $FF after the screen has been drawn
                        ; in the main loop, but only if drawingBitplane = 0

.boxEdge1

 SKIP 1                 ; The tile number for drawing the left edge of a box
                        ;
                        ;   * 0 = no box, for use in the Game Over screen
                        ;
                        ;   * 1 = standard box, for use in all other screens

.boxEdge2

 SKIP 1                 ; The tile number for drawing the right edge of a box
                        ;
                        ;   * 0 = no box, for use in the Game Over screen
                        ;
                        ;   * 2 = standard box, for use in all other screens

.chartToShow

 SKIP 1                 ; Controls which chart is shown when choosing the chart
                        ; button on the icon bar (as the Long-range and
                        ; Short-range Charts share the same button)
                        ;
                        ;   * Bit 7 clear = show Short-range Chart
                        ;
                        ;   * Bit 7 clear = show Long-range Chart

.previousCondition

 SKIP 1                 ; Used to store the ship's previous status condition
                        ; (i.e. docked, green, yellow or red), so we can tell
                        ; how the situation is changing

.statusCondition

 SKIP 1                 ; Used to store the ship's current status condition
                        ; (i.e. docked, green, yellow or red)

.screenFadedToBlack

 SKIP 1                 ; Records whether the screen has been faded to black
                        ;
                        ;   * Bit 7 clear = screen is full colour
                        ;
                        ;   * Bit 7 set = screen has been faded to black

 SKIP 1                 ; This byte appears to be unused

.numberOfPilots

 SKIP 1                 ; A flag to determine whether the game is configured for
                        ; one or two pilots
                        ;
                        ;   * 0 = one pilot (using controller 1)
                        ;
                        ;   * 1 = two pilots (where controller 1 controls the
                        ;         weaponry and controller 2 steers the ship)
                        ;
                        ; This value is toggled between 0 and 1 by the "one or
                        ; two pilots" configuration icon in the pause menu

.JSTX

 SKIP 1                 ; Our current roll rate
                        ;
                        ; This value is shown in the dashboard's RL indicator,
                        ; and determines the rate at which we are rolling
                        ;
                        ; The value ranges from 1 to 255 with 128 as the centre
                        ; point, so 1 means roll is decreasing at the maximum
                        ; rate, 128 means roll is not changing, and 255 means
                        ; roll is increasing at the maximum rate

.JSTY

 SKIP 1                 ; Our current pitch rate
                        ;
                        ; This value is shown in the dashboard's DC indicator,
                        ; and determines the rate at which we are pitching
                        ;
                        ; The value ranges from 1 to 255 with 128 as the centre
                        ; point, so 1 means pitch is decreasing at the maximum
                        ; rate, 128 means pitch is not changing, and 255 means
                        ; pitch is increasing at the maximum rate

.channelPriority

 SKIP 3                 ; The priority of the sound on the current channel
                        ; (0 to 2)

.LASX

 SKIP 1                 ; The x-coordinate of the tip of the laser line

.LASY

 SKIP 1                 ; The y-coordinate of the tip of the laser line

 SKIP 1                 ; This byte appears to be unused

.ALTIT

 SKIP 1                 ; Our altitude above the surface of the planet or sun
                        ;
                        ;   * 255 = we are a long way above the surface
                        ;
                        ;   * 1-254 = our altitude as the square root of:
                        ;
                        ;       x_hi^2 + y_hi^2 + z_hi^2 - 6^2
                        ;
                        ;     where our ship is at the origin, the centre of the
                        ;     planet/sun is at (x_hi, y_hi, z_hi), and the
                        ;     radius of the planet/sun is 6
                        ;
                        ;   * 0 = we have crashed into the surface

.SWAP

 SKIP 1                 ; Temporary storage, used to store a flag that records
                        ; whether or not we had to swap a line's start and end
                        ; coordinates around when clipping the line in routine
                        ; LL145 (the flag is used in places like BLINE to swap
                        ; them back)

.distaway

 SKIP 1                 ; Used to store the nearest distance of the rotating
                        ; ship on the title screen

.XSAV2

 SKIP 1                 ; Temporary storage, used for storing the value of the X
                        ; register in the CHPR routine

.YSAV2

 SKIP 1                 ; Temporary storage, used for storing the value of the Y
                        ; register in the CHPR routine

.inputNameSize

 SKIP 1                 ; The maximum size of the name to be fetched by the
                        ; InputName routine

.FSH

 SKIP 1                 ; Forward shield status
                        ;
                        ;   * 0 = empty
                        ;
                        ;   * $FF = full

.ASH

 SKIP 1                 ; Aft shield status
                        ;
                        ;   * 0 = empty
                        ;
                        ;   * $FF = full

.ENERGY

 SKIP 1                 ; Energy bank status
                        ;
                        ;   * 0 = empty
                        ;
                        ;   * $FF = full

.QQ24

 SKIP 1                 ; Temporary storage, used to store the current market
                        ; item's price in routine TT151

.QQ25

 SKIP 1                 ; Temporary storage, used to store the current market
                        ; item's availability in routine TT151

.QQ28

 SKIP 1                 ; The current system's economy (0-7)
                        ;
                        ;   * 0 = Rich Industrial
                        ;   * 1 = Average Industrial
                        ;   * 2 = Poor Industrial
                        ;   * 3 = Mainly Industrial
                        ;   * 4 = Mainly Agricultural
                        ;   * 5 = Rich Agricultural
                        ;   * 6 = Average Agricultural
                        ;   * 7 = Poor Agricultural
                        ;
                        ; See the deep dive on "Generating system data" for more
                        ; information on economies

.QQ29

 SKIP 1                 ; Temporary storage, used in a number of places

.imageSentToPPU

 SKIP 1                 ; Records when images have been sent to the PPU or
                        ; unpacked into the buffers, so we don't repeat the
                        ; process unnecessarily
                        ;
                        ;   * 0 = dashboard image has been sent to the PPU
                        ;
                        ;   * 1 = font image has been sent to the PPU
                        ;
                        ;   * 2 = Cobra Mk III image has been sent to the PPU
                        ;         for the Equip Ship screen
                        ;
                        ;   * 3 = the small Elite logo has been sent to the PPU
                        ;         for the Save and Load screen
                        ;
                        ;   * 245 = the inventory icon image has been sent to
                        ;           the PPU for the Market Price screen
                        ;
                        ;   * %1000xxxx = the headshot image has been sent to
                        ;                 the PPU for the Status Mode screen,
                        ;                 where %xxxx is the headshot number
                        ;                 (0-13)
                        ;
                        ;   * %1100xxxx = the system background image has been
                        ;                 unpacked into the buffers for the Data
                        ;                 on System screen, where %xxxx is the
                        ;                 system image number (0-14)

.gov

 SKIP 1                 ; The current system's government type (0-7)
                        ;
                        ; See the deep dive on "Generating system data" for
                        ; details of the various government types

.tek

 SKIP 1                 ; The current system's tech level (0-14)
                        ;
                        ; See the deep dive on "Generating system data" for more
                        ; information on tech levels

.QQ2

 SKIP 6                 ; The three 16-bit seeds for the current system, i.e.
                        ; the one we are currently in
                        ;
                        ; See the deep dives on "Galaxy and system seeds" and
                        ; "Twisting the system seeds" for more details

.QQ3

 SKIP 1                 ; The selected system's economy (0-7)
                        ;
                        ;   * 0 = Rich Industrial
                        ;   * 1 = Average Industrial
                        ;   * 2 = Poor Industrial
                        ;   * 3 = Mainly Industrial
                        ;   * 4 = Mainly Agricultural
                        ;   * 5 = Rich Agricultural
                        ;   * 6 = Average Agricultural
                        ;   * 7 = Poor Agricultural
                        ;
                        ; See the deep dive on "Generating system data" for more
                        ; information on economies

.QQ4

 SKIP 1                 ; The selected system's government (0-7)
                        ;
                        ; See the deep dive on "Generating system data" for more
                        ; details of the various government types

.QQ5

 SKIP 1                 ; The selected system's tech level (0-14)
                        ;
                        ; See the deep dive on "Generating system data" for more
                        ; information on tech levels

.QQ6

 SKIP 2                 ; The selected system's population in billions * 10
                        ; (1-71), so the maximum population is 7.1 billion
                        ;
                        ; See the deep dive on "Generating system data" for more
                        ; details on population levels

.QQ7

 SKIP 2                 ; The selected system's productivity in M CR (96-62480)
                        ;
                        ; See the deep dive on "Generating system data" for more
                        ; details about productivity levels

.QQ8

 SKIP 2                 ; The distance from the current system to the selected
                        ; system in light years * 10, stored as a 16-bit number
                        ;
                        ; The distance will be 0 if the selected system is the
                        ; current system
                        ;
                        ; The galaxy chart is 102.4 light years wide and 51.2
                        ; light years tall (see the intra-system distance
                        ; calculations in routine TT111 for details), which
                        ; equates to 1024 x 512 in terms of QQ8

.QQ9

 SKIP 1                 ; The galactic x-coordinate of the crosshairs in the
                        ; galaxy chart (and, most of the time, the selected
                        ; system's galactic x-coordinate)

.QQ10

 SKIP 1                 ; The galactic y-coordinate of the crosshairs in the
                        ; galaxy chart (and, most of the time, the selected
                        ; system's galactic y-coordinate)

.systemNumber

 SKIP 1                 ; The current system number, as calculated in TT111 when
                        ; finding the nearest system in the galaxy

 SKIP 1                 ; This byte appears to be unused

.systemsOnChart

 SKIP 1                 ; A counter for the number of systems drawn on the
                        ; Short-range Chart, so it gets limited to 24 systems

.spasto

 SKIP 2                 ; Contains the address of the ship blueprint of the
                        ; space station (which can be a Coriolis or Dodo)

.QQ18Lo

 SKIP 1                 ; Gets set to the low byte of the address of the text
                        ; token table used by the ex routine (QQ18)

.QQ18Hi

 SKIP 1                 ; Gets set to the high byte of the address of the text
                        ; token table used by the ex routine (QQ18)

.TKN1Lo

 SKIP 1                 ; Gets set to the low byte of the address of the text
                        ; token table used by the DETOK routine (TKN1)

.TKN1Hi

 SKIP 1                 ; Gets set to the high byte of the address of the text
                        ; token table used by the DETOK routine (TKN1)

.languageIndex

 SKIP 1                 ; The language that was chosen on the Start screen as an
                        ; index into the various lookup tables:
                        ;
                        ;   * 0 = English
                        ;
                        ;   * 1 = German
                        ;
                        ;   * 2 = French

.languageNumber

 SKIP 1                 ; The language that was chosen on the Start screen as a
                        ; number:
                        ;
                        ;   * 1 = Bit 0 set = English
                        ;
                        ;   * 2 = Bit 1 set = German
                        ;
                        ;   * 4 = Bit 2 set = French

.controller1Down

 SKIP 1                 ; A shift register for recording presses of the down
                        ; button on controller 1
                        ;
                        ; The controller is scanned every NMI and the result is
                        ; right-shifted into bit 7, with a 1 indicating a button
                        ; press and a 0 indicating no button press

.controller2Down

 SKIP 1                 ; A shift register for recording presses of the down
                        ; button on controller 2
                        ;
                        ; The controller is scanned every NMI and the result is
                        ; right-shifted into bit 7, with a 1 indicating a button
                        ; press and a 0 indicating no button press

.controller1Up

 SKIP 1                 ; A shift register for recording presses of the up
                        ; button on controller 1
                        ;
                        ; The controller is scanned every NMI and the result is
                        ; right-shifted into bit 7, with a 1 indicating a button
                        ; press and a 0 indicating no button press

.controller2Up

 SKIP 1                 ; A shift register for recording presses of the up
                        ; button on controller 2
                        ;
                        ; The controller is scanned every NMI and the result is
                        ; right-shifted into bit 7, with a 1 indicating a button
                        ; press and a 0 indicating no button press

.controller1Left

 SKIP 1                 ; A shift register for recording presses of the left
                        ; button on controller 1
                        ;
                        ; The controller is scanned every NMI and the result is
                        ; right-shifted into bit 7, with a 1 indicating a button
                        ; press and a 0 indicating no button press

.controller2Left

 SKIP 1                 ; A shift register for recording presses of the left
                        ; button on controller 2
                        ;
                        ; The controller is scanned every NMI and the result is
                        ; right-shifted into bit 7, with a 1 indicating a button
                        ; press and a 0 indicating no button press

.controller1Right

 SKIP 1                 ; A shift register for recording presses of the right
                        ; button on controller 1
                        ;
                        ; The controller is scanned every NMI and the result is
                        ; right-shifted into bit 7, with a 1 indicating a button
                        ; press and a 0 indicating no button press

.controller2Right

 SKIP 1                 ; A shift register for recording presses of the right
                        ; button on controller 2
                        ;
                        ; The controller is scanned every NMI and the result is
                        ; right-shifted into bit 7, with a 1 indicating a button
                        ; press and a 0 indicating no button press

.controller1A

 SKIP 1                 ; A shift register for recording presses of the A button
                        ; on controller 1
                        ;
                        ; The controller is scanned every NMI and the result is
                        ; right-shifted into bit 7, with a 1 indicating a button
                        ; press and a 0 indicating no button press

.controller2A

 SKIP 1                 ; A shift register for recording presses of the A button
                        ; on controller 2
                        ;
                        ; The controller is scanned every NMI and the result is
                        ; right-shifted into bit 7, with a 1 indicating a button
                        ; press and a 0 indicating no button press

.controller1B

 SKIP 1                 ; A shift register for recording presses of the B button
                        ; on controller 1
                        ;
                        ; The controller is scanned every NMI and the result is
                        ; right-shifted into bit 7, with a 1 indicating a button
                        ; press and a 0 indicating no button press

.controller2B

 SKIP 1                 ; A shift register for recording presses of the B button
                        ; on controller 2
                        ;
                        ; The controller is scanned every NMI and the result is
                        ; right-shifted into bit 7, with a 1 indicating a button
                        ; press and a 0 indicating no button press

.controller1Start

 SKIP 1                 ; A shift register for recording presses of the Start
                        ; button on controller 1
                        ;
                        ; The controller is scanned every NMI and the result is
                        ; right-shifted into bit 7, with a 1 indicating a button
                        ; press and a 0 indicating no button press

.controller2Start

 SKIP 1                 ; A shift register for recording presses of the Start
                        ; button on controller 2
                        ;
                        ; The controller is scanned every NMI and the result is
                        ; right-shifted into bit 7, with a 1 indicating a button
                        ; press and a 0 indicating no button press

.controller1Select

 SKIP 1                 ; A shift register for recording presses of the Select
                        ; button on controller 1
                        ;
                        ; The controller is scanned every NMI and the result is
                        ; right-shifted into bit 7, with a 1 indicating a button
                        ; press and a 0 indicating no button press

.controller2Select

 SKIP 1                 ; A shift register for recording presses of the Select
                        ; button on controller 2
                        ;
                        ; The controller is scanned every NMI and the result is
                        ; right-shifted into bit 7, with a 1 indicating a button
                        ; press and a 0 indicating no button press

.controller1Left03

 SKIP 1                 ; Bits 0 to 3 of the left button controller variable
                        ;
                        ; In non-space views, this contains controller1Left but
                        ; shifted left by four places, so the high nibble
                        ; contains bits 0 to 3 of controller1Left, with zeroes
                        ; in the low nibble
                        ;
                        ; So bit 7 is the left button state from four VBlanks
                        ; ago, bit 6 is from five VBlanks ago, and so on

.controller1Right03

 SKIP 1                 ; Bits 0 to 3 of the right button controller variable
                        ;
                        ; In non-space views, this contains controller1Right but
                        ; shifted left by four places, so the high nibble
                        ; contains bits 0 to 3 of controller1Right, with zeroes
                        ; in the low nibble
                        ;
                        ; So bit 7 is the right button state from four VBlanks
                        ; ago, bit 6 is from five VBlanks ago, and so on

.autoPlayKey

 SKIP 1                 ; Stores the buttons to be automatically pressed during
                        ; auto-play
                        ;
                        ; The bits are as follows:
                        ;
                        ;   * Bit 0 = right button
                        ;   * Bit 1 = left button
                        ;   * Bit 2 = down button
                        ;   * Bit 3 = up button
                        ;   * Bit 4 = Select button
                        ;   * Bit 5 = B button
                        ;   * Bit 6 = A button
                        ;
                        ; Bit 7 is always clear

.autoPlayRepeat

 SKIP 1                 ; Stores the number of times a step should be repeated
                        ; during auto-play

.patternBufferHi

 SKIP 1                 ; (patternBufferHi patternBufferLo) contains the address
                        ; of the pattern buffer for the pattern we are sending
                        ; to the PPU from bitplane 0 (i.e. for pattern number
                        ; sendingPattern in bitplane 0)
                        ;
                        ; This variable is saved by the NMI handler so the
                        ; buffers can be cleared across multiple VBlanks

 SKIP 1                 ; (patternBufferHi patternBufferLo) contains the address
                        ; of the pattern buffer for the pattern we are sending
                        ; to the PPU from bitplane 1 (i.e. for pattern number
                        ; sendingPattern in bitplane 1)
                        ;
                        ; This variable is saved by the NMI handler so the
                        ; buffers can be cleared across multiple VBlanks

.nameTileBuffHi

 SKIP 1                 ; (nameTileBuffHi nameTileBuffLo) contains the address
                        ; of the nametable buffer for the tile we are sending to
                        ; the PPU from bitplane 0 (i.e. for tile number
                        ; sendingNameTile in bitplane 0)
                        ;
                        ; This variable is saved by the NMI handler so the
                        ; buffers can be cleared across multiple VBlanks

 SKIP 1                 ; (nameTileBuffHi nameTileBuffLo) contains the address
                        ; of the nametable buffer for the tile we are sending to
                        ; the PPU from bitplane 1 (i.e. for tile number
                        ; sendingNameTile in bitplane 1)
                        ;
                        ; This variable is saved by the NMI handler so the
                        ; buffers can be cleared across multiple VBlanks

 SKIP 4                 ; These bytes appear to be unused

.ppuToBuffNameHi

 SKIP 1                 ; A high byte that we can add to an address in nametable
                        ; buffer 0 to get the corresponding address in the PPU
                        ; nametable

 SKIP 1                 ; A high byte that we can add to an address in nametable
                        ; buffer 1 to get the corresponding address in the PPU
                        ; nametable

.SX

 SKIP NOST + 1          ; This is where we store the x_hi coordinates for all
                        ; the stardust particles

.SY

 SKIP NOST + 1          ; This is where we store the y_hi coordinates for all
                        ; the stardust particles

.SZ

 SKIP NOST + 1          ; This is where we store the z_hi coordinates for all
                        ; the stardust particles

.BUF

 SKIP 90                ; The line buffer used by DASC to print justified text

.HANGFLAG

 SKIP 1                 ; The number of ships being displayed in the ship hangar

.MANY

 SKIP SST               ; The number of ships of each type in the local bubble
                        ; of universe
                        ;
                        ; The number of ships of type X in the local bubble is
                        ; stored at MANY+X
                        ;
                        ; See the deep dive on "Ship blueprints" for a list of
                        ; ship types

.SSPR

 SKIP NTY + 1 - SST     ; "Space station present" flag
                        ;
                        ;   * Non-zero if we are inside the space station's safe
                        ;     zone
                        ;
                        ;   * 0 if we aren't (in which case we can show the sun)
                        ;
                        ; This flag is at MANY+SST, which is no coincidence, as
                        ; MANY+SST is a count of how many space stations there
                        ; are in our local bubble, which is the same as saying
                        ; "space station present"

.messageLength

 SKIP 1                 ; The length of the message stored in the message buffer

.messageBuffer

 SKIP 32                ; A buffer for the in-flight message text

.SXL

 SKIP NOST + 1          ; This is where we store the x_lo coordinates for all
                        ; the stardust particles

.SYL

 SKIP NOST + 1          ; This is where we store the y_lo coordinates for all
                        ; the stardust particles

.SZL

 SKIP NOST + 1          ; This is where we store the z_lo coordinates for all
                        ; the stardust particles

.safehouse

 SKIP 6                 ; Backup storage for the seeds for the selected system
                        ;
                        ; The seeds for the current system get stored here as
                        ; soon as a hyperspace is initiated, so we can fetch
                        ; them in the hyp1 routine. This fixes a bug in an
                        ; earlier version where you could hyperspace while
                        ; docking and magically appear in your destination
                        ; station

.sunWidth0

 SKIP 1                 ; The half-width of the sun on pixel row 0 in the tile
                        ; row that is currently being drawn

.sunWidth1

 SKIP 1                 ; The half-width of the sun on pixel row 1 in the tile
                        ; row that is currently being drawn

.sunWidth2

 SKIP 1                 ; The half-width of the sun on pixel row 2 in the tile
                        ; row that is currently being drawn

.sunWidth3

 SKIP 1                 ; The half-width of the sun on pixel row 3 in the tile
                        ; row that is currently being drawn

.sunWidth4

 SKIP 1                 ; The half-width of the sun on pixel row 4 in the tile
                        ; row that is currently being drawn

.sunWidth5

 SKIP 1                 ; The half-width of the sun on pixel row 5 in the tile
                        ; row that is currently being drawn

.sunWidth6

 SKIP 1                 ; The half-width of the sun on pixel row 6 in the tile
                        ; row that is currently being drawn

.sunWidth7

 SKIP 1                 ; The half-width of the sun on pixel row 7 in the tile
                        ; row that is currently being drawn

.shipIsAggressive

 SKIP 1                 ; A flag to record just how aggressive the current ship
                        ; is in the TACTICS routine
                        ;
                        ; Bit 7 set indicates the ship in tactics is looking
                        ; for a fight

 CLEAR BUF+32, P%       ; The following tables share space with BUF through to
 ORG BUF+32             ; K%, which we can do as the scroll text is not shown
                        ; at the same time as ships, stardust and so on

.X1TB

 SKIP 240               ; The x-coordinates of the start points for character
                        ; lines in the scroll text

.Y1TB

 SKIP 240               ; The y-coordinates of the start and end points for
                        ; character lines in the scroll text, with the start
                        ; point (Y1) in the low nibble and the end point (Y2)
                        ; in the high nibble

.X2TB

 SKIP 240               ; The x-coordinates of the end points for character
                        ; lines in the scroll text

 PRINT "WP workspace from ", ~WP, "to ", ~P%-1, "inclusive"

; ******************************************************************************
;
;       Name: K%
;       Type: Workspace
;    Address: $0600 to $074F
;   Category: Workspaces
;    Summary: Ship data blocks
;  Deep dive: Ship data blocks
;             The local bubble of universe
;
; ------------------------------------------------------------------------------
;
; Contains ship data for all the ships, planets, suns and space stations in our
; local bubble of universe.
;
; The blocks are pointed to by the lookup table at location UNIV. The first 336
; bytes of the K% workspace hold ship data on up to 8 ships, with 42 (NIK%)
; bytes per ship.
;
; See the deep dive on "Ship data blocks" for details on ship data blocks, and
; the deep dive on "The local bubble of universe" for details of how Elite
; stores the local universe in K%, FRIN and UNIV.
;
; ******************************************************************************

 ORG $0600

.K%

 CLEAR K%, $0800        ; The ship data blocks share memory with the X1TB, Y1TB
                        ; and X2TB variables (for use in the scroll text), so we
                        ; need to clear this block of memory to prevent BeebAsm
                        ; from complaining

 SKIP NOSH * NIK%       ; Ship data blocks

 PRINT "K% workspace from ", ~K%, "to ", ~P%-1, "inclusive"

; ******************************************************************************
;
;       Name: Cartridge WRAM
;       Type: Workspace
;    Address: $6000 to $7FFF
;   Category: Workspaces
;    Summary: The 8K of battery-backed RAM in the Elite cartridge, which is used
;             for the graphics buffers and storing saved commanders
;  Deep dive: The pattern and nametable buffers
;
; ******************************************************************************

 ORG $6000

.pattBuffer0

 SKIP 8 * 256           ; The pattern buffer for bitplane 0 (1 bit per pixel)
                        ; that gets sent to the PPU during VBlank
                        ;
                        ; 256 patterns, 8 bytes per pattern (8x8 pixels)

.pattBuffer1

 SKIP 8 * 256           ; The pattern buffer for bitplane 1 (1 bit per pixel)
                        ; that gets sent to the PPU during VBlank
                        ;
                        ; 256 patterns, 8 bytes per pattern (8x8 pixels)

.nameBuffer0

 SKIP 30 * 32           ; The buffer for nametable 0 that gets sent to the PPU
                        ; during VBlank
                        ;
                        ; 30 rows of 32 tile numbers

.attrBuffer0

 SKIP 8 * 8             ; The buffer for attribute table 0 that gets sent to the
                        ; PPU during VBlank
                        ;
                        ; 8 rows of 8 attribute bytes (each is a 4x4 tile block)

.nameBuffer1

 SKIP 30 * 32           ; The buffer for nametable 1 that gets sent to the PPU
                        ; during VBlank
                        ;
                        ; 30 rows of 32 tile numbers

.attrBuffer1

 SKIP 8 * 8             ; The buffer for attribute table 0 that gets sent to the
                        ; PPU during VBlank
                        ;
                        ; 8 rows of 8 attribute bytes (each is a 4x4 tile block)

.currentSlot

 SKIP 256               ; The save slot for the currently selected commander
                        ; file

.saveSlotPart1

 SKIP 8 * 73            ; The first part of each of the eight save slots, which
                        ; are split into three for checksum purposes

.saveSlotPart2

 SKIP 8 * 73            ; The second part of each of the eight save slots, which
                        ; are split into three for checksum purposes

.saveSlotPart3

 SKIP 8 * 73            ; The third part of each of the eight save slots, which
                        ; are split into three for checksum purposes

 SKIP 40                ; These bytes appear to be unused

; ******************************************************************************
;
;       Name: SETUP_PPU_FOR_ICON_BAR
;       Type: Macro
;   Category: PPU
;    Summary: If the PPU has started drawing the icon bar, configure the PPU to
;             use nametable 0 and pattern table 0
;  Deep dive: The split-screen mode in NES Elite
;
; ------------------------------------------------------------------------------
;
; The following macro is used to ensure the game switches to the correct PPU
; nametable and pattern table for drawing the icon bar:
;
;   SETUP_PPU_FOR_ICON_BAR
;
; It checks whether the PPU has started drawing the icon bar (which it does
; using sprite 0), and if it has it switches the PPU to nametable 0 and pattern
; table 0, as that's where the icon bar tiles live.
;
; If bit 7 of setupPPUForIconBar is set, it also affects the C flag as follows:
;
;   * If bit 6 of PPU_STATUS is clear (sprite 0 has not been hit) then the C
;     flag is set to bit 7 of PPU_STATUS (which is set if VBlank has started)
;
;   * If bit 6 of PPU_STATUS is set (sprite 0 has been hit) then the C flag is
;     cleared
;
; There are no arguments.
;
; ******************************************************************************

MACRO SETUP_PPU_FOR_ICON_BAR

 LDA setupPPUForIconBar ; If bit 7 of setupPPUForIconBar is clear then jump to
 BPL skip               ; skip1, so we only update the PPU if bit 7 is set
                        ;
                        ; Bit 7 of setupPPUForIconBar is set when there is an
                        ; on-screen user interface (i.e. an icon bar), and it
                        ; is only clear if we are on the game over screen, which
                        ; doesn't have an icon bar

 LDA PPU_STATUS         ; If bit 6 of PPU_STATUS is clear then jump to skip1,
 ASL A                  ; so we only update the PPU if bit 6 is set
 BPL skip               ;
                        ; Bit 6 of PPU_STATUS is the sprite 0 hit flag, which is
                        ; set when a non-transparent pixel in sprite 0 is drawn
                        ; over a non-transparent background pixel
                        ;
                        ; It gets zeroed at the start of each VBlank and set
                        ; when sprite 0 is drawn
                        ;
                        ; Sprite 0 is at the bottom-right corner of the space
                        ; view, at coordinates (248, 163), so this means bit 6
                        ; of PPU_STATUS gets set when the PPU starts drawing the
                        ; icon bar

 JSR SetPPUTablesTo0    ; If we get here then both bit 7 of setupPPUForIconBar
                        ; and bit 6 of PPU_STATUS are set, which means there is
                        ; an icon bar on-screen and the PPU has just started
                        ; drawing it, so we call SetPPUTablesTo0 to:
                        ;
                        ;   * Zero setupPPUForIconBar to disable this process
                        ;     until the next NMI interrupt at the next VBlank
                        ;
                        ;   * Clear bits 0 and 4 of PPU_CTRL, to set the base
                        ;     nametable address to $2000 (for nametable 0) and
                        ;     the pattern table to $0000 (for pattern table 0)
                        ;
                        ;   * Clear the C flag

.skip

ENDMACRO

; ******************************************************************************
;
;       Name: ITEM
;       Type: Macro
;   Category: Market
;    Summary: Macro definition for the market prices table
;  Deep dive: Market item prices and availability
;
; ------------------------------------------------------------------------------
;
; The following macro is used to build the market prices table:
;
;   ITEM price, factor, units, quantity, mask
;
; It inserts an item into the market prices table at QQ23. See the deep dive on
; "Market item prices and availability" for more information on how the market
; system works.
;
; ------------------------------------------------------------------------------
;
; Arguments:
;
;   price               Base price
;
;   factor              Economic factor
;
;   units               Units: "t", "g" or "k"
;
;   quantity            Base quantity
;
;   mask                Fluctuations mask
;
; ******************************************************************************

MACRO ITEM price, factor, units, quantity, mask

 IF factor < 0
  s = 1 << 7
 ELSE
  s = 0
 ENDIF

 IF units = 't'
  u = 0
 ELIF units = 'k'
  u = 1 << 5
 ELSE
  u = 1 << 6
 ENDIF

 e = ABS(factor)

 EQUB price
 EQUB s + u + e
 EQUB quantity
 EQUB mask

ENDMACRO

; ******************************************************************************
;
;       Name: VERTEX
;       Type: Macro
;   Category: Drawing ships
;    Summary: Macro definition for adding vertices to ship blueprints
;  Deep dive: Ship blueprints
;
; ------------------------------------------------------------------------------
;
; The following macro is used to build the ship blueprints:
;
;   VERTEX x, y, z, face1, face2, face3, face4, visibility
;
; See the deep dive on "Ship blueprints" for details of how vertices are stored
; in the ship blueprints, and the deep dive on "Drawing ships" for information
; on how vertices are used to draw 3D wireframe ships.
;
; ------------------------------------------------------------------------------
;
; Arguments:
;
;   x                   The vertex's x-coordinate
;
;   y                   The vertex's y-coordinate
;
;   z                   The vertex's z-coordinate
;
;   face1               The number of face 1 associated with this vertex
;
;   face2               The number of face 2 associated with this vertex
;
;   face3               The number of face 3 associated with this vertex
;
;   face4               The number of face 4 associated with this vertex
;
;   visibility          The visibility distance, beyond which the vertex is not
;                       shown
;
; ******************************************************************************

MACRO VERTEX x, y, z, face1, face2, face3, face4, visibility

 IF x < 0
  s_x = 1 << 7
 ELSE
  s_x = 0
 ENDIF

 IF y < 0
  s_y = 1 << 6
 ELSE
  s_y = 0
 ENDIF

 IF z < 0
  s_z = 1 << 5
 ELSE
  s_z = 0
 ENDIF

 s = s_x + s_y + s_z + visibility
 f1 = face1 + (face2 << 4)
 f2 = face3 + (face4 << 4)
 ax = ABS(x)
 ay = ABS(y)
 az = ABS(z)

 EQUB ax, ay, az, s, f1, f2

ENDMACRO

; ******************************************************************************
;
;       Name: EDGE
;       Type: Macro
;   Category: Drawing ships
;    Summary: Macro definition for adding edges to ship blueprints
;  Deep dive: Ship blueprints
;
; ------------------------------------------------------------------------------
;
; The following macro is used to build the ship blueprints:
;
;   EDGE vertex1, vertex2, face1, face2, visibility
;
; See the deep dive on "Ship blueprints" for details of how edges are stored
; in the ship blueprints, and the deep dive on "Drawing ships" for information
; on how edges are used to draw 3D wireframe ships.
;
; ------------------------------------------------------------------------------
;
; Arguments:
;
;   vertex1             The number of the vertex at the start of the edge
;
;   vertex1             The number of the vertex at the end of the edge
;
;   face1               The number of face 1 associated with this edge
;
;   face2               The number of face 2 associated with this edge
;
;   visibility          The visibility distance, beyond which the edge is not
;                       shown
;
; ******************************************************************************

MACRO EDGE vertex1, vertex2, face1, face2, visibility

 f = face1 + (face2 << 4)
 EQUB visibility, f, vertex1 << 2, vertex2 << 2

ENDMACRO

; ******************************************************************************
;
;       Name: FACE
;       Type: Macro
;   Category: Drawing ships
;    Summary: Macro definition for adding faces to ship blueprints
;  Deep dive: Ship blueprints
;
; ------------------------------------------------------------------------------
;
; The following macro is used to build the ship blueprints:
;
;   FACE normal_x, normal_y, normal_z, visibility
;
; See the deep dive on "Ship blueprints" for details of how faces are stored
; in the ship blueprints, and the deep dive on "Drawing ships" for information
; on how faces are used to draw 3D wireframe ships.
;
; ------------------------------------------------------------------------------
;
; Arguments:
;
;   normal_x            The face normal's x-coordinate
;
;   normal_y            The face normal's y-coordinate
;
;   normal_z            The face normal's z-coordinate
;
;   visibility          The visibility distance, beyond which the edge is always
;                       shown
;
; ******************************************************************************

MACRO FACE normal_x, normal_y, normal_z, visibility

 IF normal_x < 0
  s_x = 1 << 7
 ELSE
  s_x = 0
 ENDIF

 IF normal_y < 0
  s_y = 1 << 6
 ELSE
  s_y = 0
 ENDIF

 IF normal_z < 0
  s_z = 1 << 5
 ELSE
  s_z = 0
 ENDIF

 s = s_x + s_y + s_z + visibility
 ax = ABS(normal_x)
 ay = ABS(normal_y)
 az = ABS(normal_z)

 EQUB s, ax, ay, az

ENDMACRO

; ******************************************************************************
;
;       Name: EJMP
;       Type: Macro
;   Category: Text
;    Summary: Macro definition for jump tokens in the extended token table
;  Deep dive: Extended text tokens
;
; ------------------------------------------------------------------------------
;
; The following macro is used when building the extended token table:
;
;   EJMP n              Insert a jump to address n in the JMTB table
;
; See the deep dive on "Printing extended text tokens" for details on how jump
; tokens are stored in the extended token table.
;
; ------------------------------------------------------------------------------
;
; Arguments:
;
;   n                   The jump number to insert into the table
;
; ******************************************************************************

MACRO EJMP n

 EQUB n EOR VE

ENDMACRO

; ******************************************************************************
;
;       Name: ECHR
;       Type: Macro
;   Category: Text
;    Summary: Macro definition for characters in the extended token table
;  Deep dive: Extended text tokens
;
; ------------------------------------------------------------------------------
;
; The following macro is used when building the extended token table:
;
;   ECHR 'x'            Insert ASCII character "x"
;
; To include an apostrophe, use a backtick character, as in ECHR '`'.
;
; See the deep dive on "Printing extended text tokens" for details on how
; characters are stored in the extended token table.
;
; ------------------------------------------------------------------------------
;
; Arguments:
;
;   'x'                 The character to insert into the table
;
; ******************************************************************************

MACRO ECHR x

 IF x = '`'
  EQUB 39 EOR VE
 ELSE
  EQUB x EOR VE
 ENDIF

ENDMACRO

; ******************************************************************************
;
;       Name: ETOK
;       Type: Macro
;   Category: Text
;    Summary: Macro definition for recursive tokens in the extended token table
;  Deep dive: Extended text tokens
;
; ------------------------------------------------------------------------------
;
; The following macro is used when building the extended token table:
;
;   ETOK n              Insert extended recursive token [n]
;
; See the deep dive on "Printing extended text tokens" for details on how
; recursive tokens are stored in the extended token table.
;
; ------------------------------------------------------------------------------
;
; Arguments:
;
;   n                   The number of the recursive token to insert into the
;                       table, in the range 129 to 214
;
; ******************************************************************************

MACRO ETOK n

 EQUB n EOR VE

ENDMACRO

; ******************************************************************************
;
;       Name: ETWO
;       Type: Macro
;   Category: Text
;    Summary: Macro definition for two-letter tokens in the extended token table
;  Deep dive: Extended text tokens
;
; ------------------------------------------------------------------------------
;
; The following macro is used when building the extended token table:
;
;   ETWO 'x', 'y'       Insert two-letter token "xy"
;
; The newline token can be entered using ETWO '-', '-'.
;
; See the deep dive on "Printing extended text tokens" for details on how
; two-letter tokens are stored in the extended token table.
;
; ------------------------------------------------------------------------------
;
; Arguments:
;
;   'x'                 The first letter of the two-letter token to insert into
;                       the table
;
;   'y'                 The second letter of the two-letter token to insert into
;                       the table
;
; ******************************************************************************

MACRO ETWO t, k

 IF t = '-' AND k = '-'
  EQUB 215 EOR VE
 ENDIF

 IF t = 'A' AND k = 'B'
  EQUB 216 EOR VE
 ENDIF

 IF t = 'O' AND k = 'U'
  EQUB 217 EOR VE
 ENDIF

 IF t = 'S' AND k = 'E'
  EQUB 218 EOR VE
 ENDIF

 IF t = 'I' AND k = 'T'
  EQUB 219 EOR VE
 ENDIF

 IF t = 'I' AND k = 'L'
  EQUB 220 EOR VE
 ENDIF

 IF t = 'E' AND k = 'T'
  EQUB 221 EOR VE
 ENDIF

 IF t = 'S' AND k = 'T'
  EQUB 222 EOR VE
 ENDIF

 IF t = 'O' AND k = 'N'
  EQUB 223 EOR VE
 ENDIF

 IF t = 'L' AND k = 'O'
  EQUB 224 EOR VE
 ENDIF

 IF t = 'N' AND k = 'U'
  EQUB 225 EOR VE
 ENDIF

 IF t = 'T' AND k = 'H'
  EQUB 226 EOR VE
 ENDIF

 IF t = 'N' AND k = 'O'
  EQUB 227 EOR VE
 ENDIF

 IF t = 'A' AND k = 'L'
  EQUB 228 EOR VE
 ENDIF

 IF t = 'L' AND k = 'E'
  EQUB 229 EOR VE
 ENDIF

 IF t = 'X' AND k = 'E'
  EQUB 230 EOR VE
 ENDIF

 IF t = 'G' AND k = 'E'
  EQUB 231 EOR VE
 ENDIF

 IF t = 'Z' AND k = 'A'
  EQUB 232 EOR VE
 ENDIF

 IF t = 'C' AND k = 'E'
  EQUB 233 EOR VE
 ENDIF

 IF t = 'B' AND k = 'I'
  EQUB 234 EOR VE
 ENDIF

 IF t = 'S' AND k = 'O'
  EQUB 235 EOR VE
 ENDIF

 IF t = 'U' AND k = 'S'
  EQUB 236 EOR VE
 ENDIF

 IF t = 'E' AND k = 'S'
  EQUB 237 EOR VE
 ENDIF

 IF t = 'A' AND k = 'R'
  EQUB 238 EOR VE
 ENDIF

 IF t = 'M' AND k = 'A'
  EQUB 239 EOR VE
 ENDIF

 IF t = 'I' AND k = 'N'
  EQUB 240 EOR VE
 ENDIF

 IF t = 'D' AND k = 'I'
  EQUB 241 EOR VE
 ENDIF

 IF t = 'R' AND k = 'E'
  EQUB 242 EOR VE
 ENDIF

 IF t = 'A' AND k = '?'
  EQUB 243 EOR VE
 ENDIF

 IF t = 'E' AND k = 'R'
  EQUB 244 EOR VE
 ENDIF

 IF t = 'A' AND k = 'T'
  EQUB 245 EOR VE
 ENDIF

 IF t = 'E' AND k = 'N'
  EQUB 246 EOR VE
 ENDIF

 IF t = 'B' AND k = 'E'
  EQUB 247 EOR VE
 ENDIF

 IF t = 'R' AND k = 'A'
  EQUB 248 EOR VE
 ENDIF

 IF t = 'L' AND k = 'A'
  EQUB 249 EOR VE
 ENDIF

 IF t = 'V' AND k = 'E'
  EQUB 250 EOR VE
 ENDIF

 IF t = 'T' AND k = 'I'
  EQUB 251 EOR VE
 ENDIF

 IF t = 'E' AND k = 'D'
  EQUB 252 EOR VE
 ENDIF

 IF t = 'O' AND k = 'R'
  EQUB 253 EOR VE
 ENDIF

 IF t = 'Q' AND k = 'U'
  EQUB 254 EOR VE
 ENDIF

 IF t = 'A' AND k = 'N'
  EQUB 255 EOR VE
 ENDIF

ENDMACRO

; ******************************************************************************
;
;       Name: ERND
;       Type: Macro
;   Category: Text
;    Summary: Macro definition for random tokens in the extended token table
;  Deep dive: Extended text tokens
;
; ------------------------------------------------------------------------------
;
; The following macro is used when building the extended token table:
;
;   ERND n              Insert recursive token [n]
;
;                         * Tokens 0-123 get stored as n + 91
;
; See the deep dive on "Printing extended text tokens" for details on how
; random tokens are stored in the extended token table.
;
; ------------------------------------------------------------------------------
;
; Arguments:
;
;   n                   The number of the random token to insert into the
;                       table, in the range 0 to 37
;
; ******************************************************************************

MACRO ERND n

 EQUB (n + 91) EOR VE

ENDMACRO

; ******************************************************************************
;
;       Name: TOKN
;       Type: Macro
;   Category: Text
;    Summary: Macro definition for standard tokens in the extended token table
;  Deep dive: Printing text tokens
;
; ------------------------------------------------------------------------------
;
; The following macro is used when building the recursive token table:
;
;   TOKN n              Insert recursive token [n]
;
;                         * Tokens 0-95 get stored as n + 160
;
;                         * Tokens 128-145 get stored as n - 114
;
;                         * Tokens 96-127 get stored as n
;
; See the deep dive on "Printing text tokens" for details on how recursive
; tokens are stored in the recursive token table.
;
; ------------------------------------------------------------------------------
;
; Arguments:
;
;   n                   The number of the recursive token to insert into the
;                       table, in the range 0 to 145
;
; ******************************************************************************

MACRO TOKN n

 IF n >= 0 AND n <= 95
  t = n + 160
 ELIF n >= 128
  t = n - 114
 ELSE
  t = n
 ENDIF

 EQUB t EOR VE

ENDMACRO

; ******************************************************************************
;
;       Name: CHAR
;       Type: Macro
;   Category: Text
;    Summary: Macro definition for characters in the recursive token table
;  Deep dive: Printing text tokens
;
; ------------------------------------------------------------------------------
;
; The following macro is used when building the recursive token table:
;
;   CHAR 'x'            Insert ASCII character "x"
;
; To include an apostrophe, use a backtick character, as in CHAR '`'.
;
; See the deep dive on "Printing text tokens" for details on how characters are
; stored in the recursive token table.
;
; ------------------------------------------------------------------------------
;
; Arguments:
;
;   'x'                 The character to insert into the table
;
; ******************************************************************************

MACRO CHAR x

 IF x = '`'
   EQUB 39 EOR RE
 ELSE
   EQUB x EOR RE
 ENDIF

ENDMACRO

; ******************************************************************************
;
;       Name: TWOK
;       Type: Macro
;   Category: Text
;    Summary: Macro definition for two-letter tokens in the token table
;  Deep dive: Printing text tokens
;
; ------------------------------------------------------------------------------
;
; The following macro is used when building the recursive token table:
;
;   TWOK 'x', 'y'       Insert two-letter token "xy"
;
; See the deep dive on "Printing text tokens" for details on how two-letter
; tokens are stored in the recursive token table.
;
; ------------------------------------------------------------------------------
;
; Arguments:
;
;   'x'                 The first letter of the two-letter token to insert into
;                       the table
;
;   'y'                 The second letter of the two-letter token to insert into
;                       the table
;
; ******************************************************************************

MACRO TWOK t, k

 IF t = 'A' AND k = 'L'
  EQUB 128 EOR RE
 ENDIF

 IF t = 'L' AND k = 'E'
  EQUB 129 EOR RE
 ENDIF

 IF t = 'X' AND k = 'E'
  EQUB 130 EOR RE
 ENDIF

 IF t = 'G' AND k = 'E'
  EQUB 131 EOR RE
 ENDIF

 IF t = 'Z' AND k = 'A'
  EQUB 132 EOR RE
 ENDIF

 IF t = 'C' AND k = 'E'
  EQUB 133 EOR RE
 ENDIF

 IF t = 'B' AND k = 'I'
  EQUB 134 EOR RE
 ENDIF

 IF t = 'S' AND k = 'O'
  EQUB 135 EOR RE
 ENDIF

 IF t = 'U' AND k = 'S'
  EQUB 136 EOR RE
 ENDIF

 IF t = 'E' AND k = 'S'
  EQUB 137 EOR RE
 ENDIF

 IF t = 'A' AND k = 'R'
  EQUB 138 EOR RE
 ENDIF

 IF t = 'M' AND k = 'A'
  EQUB 139 EOR RE
 ENDIF

 IF t = 'I' AND k = 'N'
  EQUB 140 EOR RE
 ENDIF

 IF t = 'D' AND k = 'I'
  EQUB 141 EOR RE
 ENDIF

 IF t = 'R' AND k = 'E'
  EQUB 142 EOR RE
 ENDIF

 IF t = 'A' AND k = '?'
  EQUB 143 EOR RE
 ENDIF

 IF t = 'E' AND k = 'R'
  EQUB 144 EOR RE
 ENDIF

 IF t = 'A' AND k = 'T'
  EQUB 145 EOR RE
 ENDIF

 IF t = 'E' AND k = 'N'
  EQUB 146 EOR RE
 ENDIF

 IF t = 'B' AND k = 'E'
  EQUB 147 EOR RE
 ENDIF

 IF t = 'R' AND k = 'A'
  EQUB 148 EOR RE
 ENDIF

 IF t = 'L' AND k = 'A'
  EQUB 149 EOR RE
 ENDIF

 IF t = 'V' AND k = 'E'
  EQUB 150 EOR RE
 ENDIF

 IF t = 'T' AND k = 'I'
  EQUB 151 EOR RE
 ENDIF

 IF t = 'E' AND k = 'D'
  EQUB 152 EOR RE
 ENDIF

 IF t = 'O' AND k = 'R'
  EQUB 153 EOR RE
 ENDIF

 IF t = 'Q' AND k = 'U'
  EQUB 154 EOR RE
 ENDIF

 IF t = 'A' AND k = 'N'
  EQUB 155 EOR RE
 ENDIF

 IF t = 'T' AND k = 'E'
  EQUB 156 EOR RE
 ENDIF

 IF t = 'I' AND k = 'S'
  EQUB 157 EOR RE
 ENDIF

 IF t = 'R' AND k = 'I'
  EQUB 158 EOR RE
 ENDIF

 IF t = 'O' AND k = 'N'
  EQUB 159 EOR RE
 ENDIF

ENDMACRO

; ******************************************************************************
;
;       Name: CONT
;       Type: Macro
;   Category: Text
;    Summary: Macro definition for control codes in the recursive token table
;  Deep dive: Printing text tokens
;
; ------------------------------------------------------------------------------
;
; The following macro is used when building the recursive token table:
;
;   CONT n              Insert control code token {n}
;
; See the deep dive on "Printing text tokens" for details on how characters are
; stored in the recursive token table.
;
; ------------------------------------------------------------------------------
;
; Arguments:
;
;   n                   The control code to insert into the table
;
; ******************************************************************************

MACRO CONT n

 EQUB n EOR RE

ENDMACRO

; ******************************************************************************
;
;       Name: RTOK
;       Type: Macro
;   Category: Text
;    Summary: Macro definition for recursive tokens in the recursive token table
;  Deep dive: Printing text tokens
;
; ------------------------------------------------------------------------------
;
; The following macro is used when building the recursive token table:
;
;   RTOK n              Insert recursive token [n]
;
;                         * Tokens 0-95 get stored as n + 160
;
;                         * Tokens 128-145 get stored as n - 114
;
;                         * Tokens 96-127 get stored as n
;
; See the deep dive on "Printing text tokens" for details on how recursive
; tokens are stored in the recursive token table.
;
; ------------------------------------------------------------------------------
;
; Arguments:
;
;   n                   The number of the recursive token to insert into the
;                       table, in the range 0 to 145
;
; ******************************************************************************

MACRO RTOK n

 IF n >= 0 AND n <= 95
  t = n + 160
 ELIF n >= 128
  t = n - 114
 ELSE
  t = n
 ENDIF

 EQUB t EOR RE

ENDMACRO

; ******************************************************************************
;
;       Name: ADD_CYCLES_CLC
;       Type: Macro
;   Category: Drawing the screen
;    Summary: Add a specified number to the cycle count
;  Deep dive: Drawing vector graphics using NES tiles
;
; ------------------------------------------------------------------------------
;
; The following macro is used to add cycles to the cycle count:
;
;   ADD_CYCLES_CLC cycles
;
; The cycle count is stored in the variable cycleCount.
;
; ------------------------------------------------------------------------------
;
; Arguments:
;
;   cycles              The number of cycles to add to the cycle count
;
; ******************************************************************************

MACRO ADD_CYCLES_CLC cycles

 CLC                    ; Clear the C flag for the addition below

 LDA cycleCount         ; Add cycles to cycleCount(1 0)
 ADC #LO(cycles)
 STA cycleCount
 LDA cycleCount+1
 ADC #HI(cycles)
 STA cycleCount+1

ENDMACRO

; ******************************************************************************
;
;       Name: ADD_CYCLES
;       Type: Macro
;   Category: Drawing the screen
;    Summary: Add a specified number to the cycle count
;  Deep dive: Drawing vector graphics using NES tiles
;
; ------------------------------------------------------------------------------
;
; The following macro is used to add cycles to the cycle count:
;
;   ADD_CYCLES cycles
;
; The cycle count is stored in the variable cycleCount. This macro assumes that
; the C flag is clear.
;
; ------------------------------------------------------------------------------
;
; Arguments:
;
;   cycles              The number of cycles to add to the cycle count
;
;   C flag              Must be clear for the addition to work
;
; ******************************************************************************

MACRO ADD_CYCLES cycles

 LDA cycleCount         ; Add cycles to cycleCount(1 0)
 ADC #LO(cycles)
 STA cycleCount
 LDA cycleCount+1
 ADC #HI(cycles)
 STA cycleCount+1

ENDMACRO

; ******************************************************************************
;
;       Name: SUBTRACT_CYCLES
;       Type: Macro
;   Category: Drawing the screen
;    Summary: Subtract a specified number from the cycle count
;  Deep dive: Drawing vector graphics using NES tiles
;
; ------------------------------------------------------------------------------
;
; The following macro is used to subtract cycles from the cycle count:
;
;   SUBTRACT_CYCLES cycles
;
; The cycle count is stored in the variable cycleCount.
;
; ------------------------------------------------------------------------------
;
; Arguments:
;
;   cycles              The number of cycles to subtract from the cycle count
;
; ******************************************************************************

MACRO SUBTRACT_CYCLES cycles

 SEC                    ; Subtract cycles from cycleCount(1 0)
 LDA cycleCount
 SBC #LO(cycles)
 STA cycleCount
 LDA cycleCount+1
 SBC #HI(cycles)
 STA cycleCount+1

ENDMACRO

; ******************************************************************************
;
;       Name: FILL_MEMORY
;       Type: Macro
;   Category: Drawing the screen
;    Summary: Fill memory with the specified number of bytes
;
; ------------------------------------------------------------------------------
;
; The following macro is used to fill a block of memory with the same value:
;
;   FILL_MEMORY byte_count
;
; It writes the value A into byte_count bytes, starting at the Y-th byte of the
; memory block at address clearAddress(1 0). It also updates the index in Y to
; point to the byte after the block that is filled.
;
; ------------------------------------------------------------------------------
;
; Arguments:
;
;   byte_count          The number of bytes to fill
;
;   clearAddress(1 0)   The base address of the block of memory to fill
;
;   Y                   The index into clearAddress(1 0) from which to fill
;
;   A                   The value to fill
;
; ------------------------------------------------------------------------------
;
; Returns:
;
;   Y                   The index in Y is updated to point to the byte after the
;                       filled block
;
; ******************************************************************************

MACRO FILL_MEMORY byte_count

 FOR I%, 1, byte_count

  STA (clearAddress),Y  ; Write A to the Y-th byte of clearAddress(1 0)

  INY                   ; Increment the index in Y

                        ; Repeat the above code so that we run it byte_count
                        ; times, so write a total of byte_count bytes into
                        ; memory

 NEXT

ENDMACRO

; ******************************************************************************
;
;       Name: SEND_DATA_TO_PPU
;       Type: Macro
;   Category: Drawing the screen
;    Summary: Send a specified block of memory to the PPU
;  Deep dive: Drawing vector graphics using NES tiles
;
; ------------------------------------------------------------------------------
;
; The following macro is used to send bytes to the PPU:
;
;   SEND_DATA_TO_PPU byte_count
;
; It sends a block of byte_count bytes from memory to the PPU, starting with the
; Y-th byte of the data block at address dataForPPU(1 0). It also updates the
; index in Y to point to the byte after the block that is sent.
;
; ------------------------------------------------------------------------------
;
; Arguments:
;
;   byte_count          The number of bytes to send to the PPU
;
;   Y                   The index into dataForPPU(1 0) from which to start
;                       sending data
;
; ------------------------------------------------------------------------------
;
; Returns:
;
;   Y                   The index in Y is updated to point to the byte after the
;                       block that is sent
;
; ******************************************************************************

MACRO SEND_DATA_TO_PPU byte_count

 FOR I%, 1, byte_count

  LDA (dataForPPU),Y    ; Send the Y-th byte of dataForPPU(1 0) to the PPU
  STA PPU_DATA

  INY                   ; Increment the index in Y

                        ; Repeat the above code so that we run it byte_count
                        ; times, so we send a total of byte_count bytes from
                        ; memory to the PPU

 NEXT

ENDMACRO

; ******************************************************************************
;
; Include all ROM banks
;
; ******************************************************************************

 INCLUDE "1-source-files/main-sources/elite-source-bank-0.asm"
 CLEAR CODE%, P%

 INCLUDE "1-source-files/main-sources/elite-source-bank-1.asm"
 CLEAR CODE%, P%

 INCLUDE "1-source-files/main-sources/elite-source-bank-2.asm"
 CLEAR CODE%, P%

 INCLUDE "1-source-files/main-sources/elite-source-bank-3.asm"
 CLEAR CODE%, P%

 INCLUDE "1-source-files/main-sources/elite-source-bank-4.asm"
 CLEAR CODE%, P%

 INCLUDE "1-source-files/main-sources/elite-source-bank-5.asm"
 CLEAR CODE%, P%

 INCLUDE "1-source-files/main-sources/elite-source-bank-6.asm"
 CLEAR CODE%, P%

 INCLUDE "1-source-files/main-sources/elite-source-bank-7.asm"
