; ******************************************************************************
;
; NES ELITE GAME SOURCE (COMMON VARIABLES)
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
; This source file contains variables, macros and addresses that are shared by
; all eight banks.
;
; ******************************************************************************

 _NTSC = (_VARIANT = 1)
 _PAL  = (_VARIANT = 2)

; ******************************************************************************
;
; Configuration variables
;
; ******************************************************************************

 Q% = _REMOVE_CHECKSUMS ; Set Q% to TRUE to max out the default commander, FALSE
                        ; for the standard default commander (this is set to
                        ; TRUE if checksums are disabled, just for convenience)

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

 Armlas = INT(128.5+1.5*POW)  ; Military laser power

 NI% = 38               ; The number of bytes in each ship's data block (as
                        ; stored in INWK and K%)

 NIK% = NI% + 4         ; The number of bytes in each block in K% (as each block
                        ; contains four extra bytes)

 X = 128                ; The centre x-coordinate of the space view
 Y = 72                 ; The centre y-coordinate of the space view

 RE = $3E               ; The obfuscation byte used to hide the recursive tokens
                        ; table from crackers viewing the binary code

 VE = $57               ; The obfuscation byte used to hide the extended tokens
                        ; table from crackers viewing the binary code

 LL = 29                ; The length of lines (in characters) of justified text
                        ; in the extended tokens system

 YPAL = 6 AND _PAL      ; A margin of 6 pixels that is applied to a number of
                        ; y-coordinates for the PAL version only (as the PAL
                        ; version has a taller screen than NTSC)

; ******************************************************************************
;
; NES PPU registers
;
; See https://www.nesdev.org/wiki/PPU_registers
;
; ******************************************************************************

 PPU_CTRL   = $2000
 PPU_MASK   = $2001
 PPU_STATUS = $2002
 OAM_ADDR   = $2003
 OAM_DATA   = $2004
 PPU_SCROLL = $2005
 PPU_ADDR   = $2006
 PPU_DATA   = $2007
 OAM_DMA    = $4014

 PPU_PATT_0 = $0000
 PPU_PATT_1 = $1000
 PPU_NAME_0 = $2000
 PPU_ATTR_0 = $23C0
 PPU_NAME_1 = $2400
 PPU_ATTR_1 = $27C0

; ******************************************************************************
;
; NES 2A03 CPU registers (I/O and sound)
;
; See https://www.nesdev.org/wiki/2A03
;
; ******************************************************************************

 SQ1_VOL    = $4000
 SQ1_SWEEP  = $4001
 SQ1_LO     = $4002
 SQ1_HI     = $4003
 SQ2_VOL    = $4004
 SQ2_SWEEP  = $4005
 SQ2_LO     = $4006
 SQ2_HI     = $4007
 TRI_LINEAR = $4008
 TRI_LO     = $400A
 TRI_HI     = $400B
 NOISE_VOL  = $400C
 NOISE_LO   = $400E
 NOISE_HI   = $400F
 DMC_FREQ   = $4010
 DMC_RAW    = $4011
 DMC_START  = $4012
 DMC_LEN    = $4013
 SND_CHN    = $4015
 JOY1       = $4016
 JOY2       = $4017

; ******************************************************************************
;
; Exported addresses from bank 0
;
; ******************************************************************************

IF NOT(_BANK = 0)

 UpdateView         = $8926
 DrawScreenInNMI    = $8980
 MVS5               = $8A14
 PlayDemo           = $9522
 StartAfterLoad     = $A379
 PrintCtrlCode      = $A8D9
 ZINF               = $AE03
 MAS4               = $B1CA
 CheckForPause      = $B1D4
 ShowStartScreen    = $B2C3
 DEATH2             = $B2EF
 StartGame          = $B358
 ChangeToView       = $B39D
 TITLE              = $B3BC
 PAS1               = $B8F7
 TT66               = $BEB5

ENDIF

; ******************************************************************************
;
; Exported addresses from bank 1
;
; ******************************************************************************

IF NOT(_BANK = 1)

 E%                 = $8042
 KWL%               = $8063
 KWH%               = $8084
 SHIP_MISSILE       = $80A5
 SHIP_CORIOLIS      = $81A3
 SHIP_ESCAPE_POD    = $82BF
 SHIP_PLATE         = $8313
 SHIP_CANISTER      = $8353
 SHIP_BOULDER       = $83FB
 SHIP_ASTEROID      = $849D
 SHIP_SPLINTER      = $8573
 SHIP_SHUTTLE       = $85AF
 SHIP_TRANSPORTER   = $86E1
 SHIP_COBRA_MK_3    = $88C3
 SHIP_PYTHON        = $8A4B
 SHIP_BOA           = $8B3D
 SHIP_ANACONDA      = $8C33
 SHIP_ROCK_HERMIT   = $8D35
 SHIP_VIPER         = $8E0B
 SHIP_SIDEWINDER    = $8EE5
 SHIP_MAMBA         = $8F8D
 SHIP_KRAIT         = $90BB
 SHIP_ADDER         = $91A1
 SHIP_GECKO         = $92D1
 SHIP_COBRA_MK_1    = $9395
 SHIP_WORM          = $945B
 SHIP_COBRA_MK_3_P  = $950B
 SHIP_ASP_MK_2      = $9693
 SHIP_PYTHON_P      = $97BD
 SHIP_FER_DE_LANCE  = $98AF
 SHIP_MORAY         = $99C9
 SHIP_THARGOID      = $9AA1
 SHIP_THARGON       = $9BBD
 SHIP_CONSTRICTOR   = $9C29
 SHIP_COUGAR        = $9D2B
 SHIP_DODO          = $9E2D
 LL9                = $A070
 CLIP               = $A65D
 CIRCLE2            = $AF9D
 SUN                = $AC25
 STARS              = $B1BE
 HALL               = $B738
 TIDY               = $B85C
 SCAN               = $B975
 HideFromScanner    = $BAF3

ENDIF

; ******************************************************************************
;
; Exported addresses from bank 2
;
; ******************************************************************************

IF NOT(_BANK = 2)

 TKN1               = $800C
 TKN1_DE            = $8DFD
 TKN1_FR            = $9A2C
 QQ18               = $A3CF
 QQ18_DE            = $A79C
 QQ18_FR            = $AC4D
 DETOK              = $B0EF
 DTS                = $B187
 PDESC              = $B3E8
 TT27               = $B44F
 ex                 = $B4AA
 DASC               = $B4F5
 CHPR               = $B635

ENDIF

; ******************************************************************************
;
; Exported addresses from bank 3
;
; ******************************************************************************

IF NOT(_BANK = 3)

 iconBarImage0      = $8100
 iconBarImage1      = $8500
 iconBarImage2      = $8900
 iconBarImage3      = $8D00
 iconBarImage4      = $9100
 DrawDashNames      = $A730
 ResetScanner       = $A775
 SendViewToPPU      = $A7B7
 SendBitplaneToPPU  = $A972
 SetupViewInNMI     = $A9D1
 ResetScreen        = $AABC
 ShowIconBar        = $AC1D
 UpdateIconBar      = $AC5C
 SetupIconBar       = $AE18
 SetLinePatterns    = $AFCD
 LoadFontPlane0     = $B0E1
 LoadFontPlane1     = $B18E
 DrawSystemImage    = $B219
 DrawImageFrame     = $B248
 DrawSmallBox       = $B2BC
 DrawBackground     = $B2FB
 ClearScreen        = $B341
 FadeToBlack        = $B63D
 FadeToColour       = $B673
 SetViewAttrs       = $B9E2
 SIGHT              = $BA23

ENDIF

; ******************************************************************************
;
; Exported addresses from bank 4
;
; ******************************************************************************

IF NOT(_BANK = 4)

 cobraNames         = $B7EC
 GetHeadshotType    = $B882
 GetHeadshot        = $B8F9
 GetCmdrImage       = $B93C
 DrawBigLogo        = $B96B
 DrawImageNames     = $B9C1
 DrawSmallLogo      = $B9F9

ENDIF

; ******************************************************************************
;
; Exported addresses from bank 5
;
; ******************************************************************************

IF NOT(_BANK = 5)

 GetSystemImage     = $BED7
 GetSystemBack      = $BEEA
 SetDemoAutoPlay    = $BF41

ENDIF

; ******************************************************************************
;
; Exported addresses from bank 6
;
; ******************************************************************************

IF NOT(_BANK = 6)

 StopMusicS         = $8012
 ChooseMusic        = $8021
 PlayMusic          = $811E
 MakeNoise          = $89D1
 DrawCmdrImage      = $A082
 DrawSpriteImage    = $A0F8
 PauseGame          = $A166
 DIALS              = $A2C3
 DrawEquipment      = $A4A5
 ShowScrollText     = $A5AB
 SVE                = $B459

 IF _NTSC

  UpdateSaveSlots   = $B88C
  ResetCommander    = $B8FE
  JAMESON           = $B90D
  DrawLightning     = $B919
  LL164             = $B980
  DrawLaunchBoxes   = $BA17
  InputName         = $BA63
  ChangeCmdrName    = $BB37
  SetKeyLogger      = $BBDE
  ChooseLanguage    = $BC83
  TT24              = $BE52
  ClearDashEdge     = $BED2

 ELIF _PAL

  UpdateSaveSlots   = $B89B
  ResetCommander    = $B90D
  JAMESON           = $B91C
  DrawLightning     = $B928
  LL164             = $B98F
  DrawLaunchBoxes   = $BA26
  InputName         = $BA72
  ChangeCmdrName    = $BB46
  SetKeyLogger      = $BBED
  ChooseLanguage    = $BC92
  TT24              = $BE6D
  ClearDashEdge     = $BEED

 ENDIF

ENDIF

; ******************************************************************************
;
;       Name: ZP
;       Type: Workspace
;    Address: $0000 to $00B0
;   Category: Workspaces
;    Summary: Lots of important variables are stored in the zero page workspace
;             as it is quicker and more space-efficient to access memory here
;
; ******************************************************************************

 ORG $0000

.ZP

 SKIP 0                 ; The start of the zero page workspace

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
                        ; screen (the space view) has a white border that
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

.fontBitplane

 SKIP 1                 ; When printing a character in CHPR, this defines which
                        ; bitplanes to draw from the font images in fontImage,
                        ; as each character in the font contains two separate
                        ; characters
                        ;
                        ;   * %01 = draw in bitplane 1 (monochrome)
                        ;
                        ;   * %10 = draw in bitplane 2 (monochrome)
                        ;
                        ;   * %11 = draw both bitplanes (four-colour)

.nmiTimer

 SKIP 1                 ; A counter that gets decremented each time the NMI
                        ; interrupt is called, starting at 50 and counting down
                        ; to zero, at which point it jumps back up to 50 again
                        ; and triggers and increment of (nmiTimerHi nmiTimerLo)

.nmiTimerLo

 SKIP 1                 ; Low byte of a counter that's incremented by 1 every
                        ; time nmiTimer wraps

.nmiTimerHi

 SKIP 1                 ; High byte of a counter that's incremented by 1 every
                        ; time nmiTimer wraps

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
                        ; top part of the screen has a white border that clashes
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

.XX19

 SKIP 0                 ; Instead of pointing XX19 to the ship heap address in
                        ; INWK(34 33), like the other versions of Elite, the NES
                        ; version points XX19 to the ship blueprint address in
                        ; INF(1 0)

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

.pressedButton

 SKIP 1                 ; The button number of the icon bar button that has been
                        ; pressed, or 0 if nothing has been pressed

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

 SKIP 1                 ; This contains the number of the current view (or, if
                        ; we are changing views, the number of the view we are
                        ; changing to)
                        ;
                        ; The low nibble contains the view type, as follows:
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
                        ;   11 = $xB = Save and load
                        ;   12 = $xC = Short-range Chart
                        ;   13 = $xD = Long-range Chart
                        ;   14 = $xE = Unused
                        ;   15 = $xF = Start screen
                        ;
                        ; The high nibble contains four configuration bits, as
                        ; follows:
                        ;
                        ;   * Bit 4 clear = do not load the font into bitplane 0
                        ;     Bit 4 set   = load the font into bitplane 0 from
                        ;                   pattern 66 to 160 (or 68 to 162 for
                        ;                   views $9D and $DF)
                        ;
                        ;   * Bit 5 clear = do not load the font into bitplane 1
                        ;     Bit 5 set   = load the font into bitplane 1 from
                        ;                   pattern 161 to 255
                        ;
                        ;   * Bit 6 clear = icon bar
                        ;     Bit 6 set   = no icon bar (rows 27-28 are blank)
                        ;
                        ;   * Bit 7 clear = dashboard (icon bar on row 20)
                        ;     Bit 7 set   = no dashboard (icon bar on row 27)
                        ;
                        ; Most views have the same configuration every time
                        ; the view is shown, but $x0 (space view), $xB (Save and
                        ; load), $xD (Long-range Chart) and $xF (Start screen)
                        ; can have different configurations at different times
                        ;
                        ; Note that view $FF is an exception, as no fonts are
                        ; loaded for this view (it represents the blank view
                        ; between the end of the Title screen and the start of
                        ; the demo scroll text)
                        ;
                        ; Also, view $BB (Save and load with font loaded in both
                        ; bitplanes) loads an inverted font into bitplane 1 from
                        ; pattern 66 to 160, as well as the normal fonts, and
                        ; views $9D (Long-range Chart) and $DF (Start screen)
                        ; load the bitplane 0 font at pattern 68 onmwards,
                        ; rather than 66
                        ;
                        ; The complete list of view types is therefore:
                        ;
                        ;   $00 = Space view
                        ;         No font loaded, dashboard
                        ;
                        ;   $10 = Space view
                        ;         Font loaded in bitplane 0, dashboard
                        ;
                        ;   $01 = Title screen
                        ;         No font loaded, dashboard
                        ;
                        ;   $92 = Mission 1 briefing: rotating ship
                        ;         Font loaded in bitplane 0, no dashboard
                        ;
                        ;   $93 = Mission 1 briefing: ship and text
                        ;         Font loaded in bitplane 0, no dashboard
                        ;
                        ;   $C4 = Game Over screen
                        ;         No font loaded, no dashboard or icon bar
                        ;
                        ;   $95 = Text-based mission briefing
                        ;         Font loaded in bitplane 0, no dashboard
                        ;
                        ;   $96 = Data on System
                        ;         Font loaded in bitplane 0, no dashboard
                        ;
                        ;   $97 = Inventory
                        ;         Font loaded in bitplane 0, no dashboard
                        ;
                        ;   $98 = Status Mode
                        ;         Font loaded in bitplane 0, no dashboard
                        ;
                        ;   $B9 = Equip Ship
                        ;         Font loaded in both bitplanes, no dashboard
                        ;
                        ;   $BA = Market Price
                        ;         Font loaded in both bitplanes, no dashboard
                        ;
                        ;   $8B = Save and load
                        ;         No font loaded, no dashboard
                        ;
                        ;   $BB = Save and load
                        ;         Font loaded in both bitplanes, inverted font
                        ;         loaded in bitplane 1, no dashboard
                        ;
                        ;   $9C = Short-range Chart
                        ;         Font loaded in bitplane 0, no dashboard
                        ;
                        ;   $8D = Long-range Chart
                        ;         No font loaded, no dashboard
                        ;
                        ;   $9D = Long-range Chart
                        ;         Font loaded in bitplane 0, no dashboard
                        ;
                        ;   $CF = Start screen
                        ;         No font loaded, no dashboard or icon bar
                        ;
                        ;   $DF = Start screen
                        ;         Font loaded in bitplane 0, no dashboard or
                        ;         icon bar
                        ;
                        ;   $FF = Segue screen from Title screen to Demo
                        ;         No font loaded, no dashboard or icon bar

.QQ11a

 SKIP 1                 ; Contains the old view number when changing views
                        ;
                        ; When we change view, QQ11 gets set to the new view
                        ; number straight away while QQ11a stays set to the old
                        ; view number, only updating to the new view number once
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

.ASAV

 SKIP 1                 ; Temporary storage for saving the value of the A
                        ; register, used in the bank-switching routines in
                        ; bank 7

.firstFreeTile

 SKIP 1                 ; Contains the number of the first free tile that we can
                        ; draw into next (or 0 if there are no free tiles)
                        ;
                        ; This variable is typically used to control the
                        ; drawing process into dynamic tiles - when we need a
                        ; new tile when drawing the space view, this is the
                        ; number of the next tile to use

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

.lastPatternTile

 SKIP 1                 ; The number of the last pattern entry to send from
                        ; pattern buffer 0 to bitplane 0 of the PPU pattern
                        ; table in the NMI handler

 SKIP 1                 ; The number of the last pattern entry to send from
                        ; pattern buffer 1 to bitplane 1 of the PPU pattern
                        ; table in the NMI handler

.clearingPattTile

 SKIP 1                 ; The number of the first tile to clear in pattern
                        ; buffer 0 when the NMI handler clears tiles
                        ;
                        ; This variable is saved by the NMI handler so the
                        ; buffers can be cleared across multiple VBlanks

 SKIP 1                 ; The number of the first tile to clear in pattern
                        ; buffer 1 when the NMI handler clears tiles
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

.pattTileCounter

 SKIP 1                 ; Counts tiles as they are written to the PPU pattern
                        ; table in the NMI handler
                        ;
                        ; This variable is used internally by the
                        ; SendPatternsToPPU routine

.sendingPattTile

 SKIP 1                 ; The number of the most recent tile that was sent to
                        ; the PPU pattern table by the NMI handler for bitplane
                        ; 0 (or the number of the first tile to send if none
                        ; have been sent)
                        ;
                        ; This variable is saved by the NMI handler so the
                        ; buffers can be cleared across multiple VBlanks

 SKIP 1                 ; The number of the most recent tile that was sent to
                        ; the PPU pattern table by the NMI handler for bitplane
                        ; 1 (or the number of the first tile to send if none
                        ; have been sent)
                        ;
                        ; This variable is saved by the NMI handler so the
                        ; buffers can be cleared across multiple VBlanks

.firstNametableTile

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

.firstPatternTile

 SKIP 1                 ; The number of the first tile for which we send pattern
                        ; data to the PPU in the NMI handler (potentially for
                        ; both bitplanes, if both are configured to be sent)

.barPatternCounter

 SKIP 1                 ; The number of icon bar nametable and pattern entries
                        ; that need to be sent to the PPU in the NMI handler
                        ;
                        ;   * 0 = send the nametable entries and the first four
                        ;         tile pattern in the next NMI call (and update
                        ;         barPatternCounter to 4 when done)
                        ;
                        ;   * 1-127 = counts the number of pattern bytes already
                        ;             sent to the PPU, which get sent in batches
                        ;             of four patterns (32 bytes), split across
                        ;             multiple NMI calls, until we have send all
                        ;             32 tile patterns and the value is 128
                        ;
                        ;   * 128 = do not send any tiles

.iconBarOffset

 SKIP 2                 ; The offset from the start of the nametable buffer of
                        ; the icon bar (i.e. the number of the nametable entry
                        ; for the top-left tile of the icon bar)
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

 SKIP 1                 ; A flag to control whether to send the icon bar's tile
                        ; patterns to the PPU, after sending the nametable
                        ; entries (this only applies if barPatternCounter = 0)
                        ;
                        ;   * Bit 7 set = do not send tile patterns
                        ;
                        ;   * Bit 7 clear = send tile patterns
                        ;
                        ; This means that if barPatternCounter is set to zero
                        ; and bit 7 of skipBarPatternsPPU is set, then only the
                        ; nametable entries for the icon bar will be sent to the
                        ; PPU, but if barPatternCounter is set to zero and bit 7
                        ; of skipBarPatternsPPU is clear, both the nametable
                        ; entries and tile patterns will be sent

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

.pattTileBuffLo

 SKIP 1                 ; (pattTileBuffHi pattTileBuffLo) contains the address
                        ; of the pattern buffer for the tile we are sending to
                        ; the PPU from bitplane 0 (i.e. for tile number
                        ; sendingPattTile in bitplane 0)

 SKIP 1                 ; (pattTileBuffHi pattTileBuffLo) contains the address
                        ; of the pattern buffer for the tile we are sending to
                        ; the PPU from bitplane 1 (i.e. for tile number
                        ; sendingPattTile in bitplane 1)

.nameTileBuffLo

 SKIP 1                 ; (nameTileBuffHi nameTileBuffLo) contains the address
                        ; of the nametable buffer for the tile we are sending to
                        ; the PPU from bitplane 0 (i.e. for tile number
                        ; sendingNameTile in bitplane 0)

 SKIP 1                 ; (nameTileBuffHi nameTileBuffLo) contains the address
                        ; of the nametable buffer for the tile we are sending to
                        ; the PPU from bitplane 1 (i.e. for tile number
                        ; sendingNameTile in bitplane 1)

.nmiBitplane8

 SKIP 1                 ; Used when sending patterns to the PPU to calculate the
                        ; address offset of bitplanes 0 and 1
                        ;
                        ; Gets set to nmiBitplane * 8 to given an offset of 0
                        ; for bitplane 0 and an offset of 8 for bitplane 1

.ppuPatternTableHi

 SKIP 1                 ; High byte of the address of the PPU pattern table to
                        ; which we send dynamic tile patterns
                        ;
                        ; This is set to HI(PPU_PATT_1) in ResetScreen and
                        ; doesn't change again, so it always points to pattern
                        ; table 1 in the PPU, as that's the only pattern table
                        ; we use for storing dynamic tiles

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

.lastTile

 SKIP 1                 ; The last tile number to send to the PPU, potentially
                        ; potentially overwritten by the flags
                        ;
                        ; This variable is used internally by the NMI handler,
                        ; and is set as follows in SendNametableToPPU:
                        ;
                        ;   lastTile
                        ;       = (bitplaneFlag 3 set) ? 128 : lastNameTile
                        ;
                        ; and like this in SendPatternsToPPU:
                        ;
                        ;   lastTile
                        ;       = (bitplaneFlag 3 set) ? 128 : lastPatternTile

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
                        ; the PlayMusic routine to play the background music, as
                        ; this can only happen if we are not in the middle of
                        ; switching ROM banks (if we are, then PlayMusic is
                        ; called once the bank-switching is done - see the
                        ; SetBank routine for details)

.characterEnd

 SKIP 1                 ; The number of the character beyond the end of the
                        ; printable character set for the chosen language

.autoplayKeys

 SKIP 2                 ; The address of the table containing the key presses to
                        ; apply when auto-playing the demo
                        ;
                        ; The address is taken from the chosen languages's
                        ; (autoplayKeysHi autoplayKeysLo) variable 

 SKIP 2                 ; These bytes appear to be unused

.soundAddr

 SKIP 2                 ; Temporary storage, used in a number of places in the
                        ; sound routines to hold an address

 PRINT "Zero page variables from ", ~ZP, " to ", ~P%

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

 SKIP 0                 ; Temporary storage, typically used for storing tables
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
;   * The number of the tile pattern that is drawn on-screen for this sprite
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

.tileSprite0

 SKIP 1                 ; Tile pattern number for sprite 0

.attrSprite0

 SKIP 1                 ; Attributes for sprite 0

.xSprite0

 SKIP 1                 ; Screen x-coordinate for sprite 0

.ySprite1

 SKIP 1                 ; Screen y-coordinate for sprite 1

.tileSprite1

 SKIP 1                 ; Tile pattern number for sprite 1

.attrSprite1

 SKIP 1                 ; Attributes for sprite 1

.xSprite1

 SKIP 1                 ; Screen x-coordinate for sprite 1

.ySprite2

 SKIP 1                 ; Screen y-coordinate for sprite 2

.tileSprite2

 SKIP 1                 ; Tile pattern number for sprite 2

.attrSprite2

 SKIP 1                 ; Attributes for sprite 2

.xSprite2

 SKIP 1                 ; Screen x-coordinate for sprite 2

.ySprite3

 SKIP 1                 ; Screen y-coordinate for sprite 3

.tileSprite3

 SKIP 1                 ; Tile pattern number for sprite 3

.attrSprite3

 SKIP 1                 ; Attributes for sprite 3

.xSprite3

 SKIP 1                 ; Screen x-coordinate for sprite 3

.ySprite4

 SKIP 1                 ; Screen y-coordinate for sprite 4

.tileSprite4

 SKIP 1                 ; Tile pattern number for sprite 4

.attrSprite4

 SKIP 1                 ; Attributes for sprite 4

.xSprite4

 SKIP 1                 ; Screen x-coordinate for sprite 4

.ySprite5

 SKIP 1                 ; Screen y-coordinate for sprite 5

.tileSprite5

 SKIP 1                 ; Tile pattern number for sprite 5

.attrSprite5

 SKIP 1                 ; Attributes for sprite 5

.xSprite5

 SKIP 1                 ; Screen x-coordinate for sprite 5

.ySprite6

 SKIP 1                 ; Screen y-coordinate for sprite 6

.tileSprite6

 SKIP 1                 ; Tile pattern number for sprite 6

.attrSprite6

 SKIP 1                 ; Attributes for sprite 6

.xSprite6

 SKIP 1                 ; Screen x-coordinate for sprite 6

.ySprite7

 SKIP 1                 ; Screen y-coordinate for sprite 7

.tileSprite7

 SKIP 1                 ; Tile pattern number for sprite 7

.attrSprite7

 SKIP 1                 ; Attributes for sprite 7

.xSprite7

 SKIP 1                 ; Screen x-coordinate for sprite 7

.ySprite8

 SKIP 1                 ; Screen y-coordinate for sprite 8

.tileSprite8

 SKIP 1                 ; Tile pattern number for sprite 8

.attrSprite8

 SKIP 1                 ; Attributes for sprite 8

.xSprite8

 SKIP 1                 ; Screen x-coordinate for sprite 8

.ySprite9

 SKIP 1                 ; Screen y-coordinate for sprite 9

.tileSprite9

 SKIP 1                 ; Tile pattern number for sprite 9

.attrSprite9

 SKIP 1                 ; Attributes for sprite 9

.xSprite9

 SKIP 1                 ; Screen x-coordinate for sprite 9

.ySprite10

 SKIP 1                 ; Screen y-coordinate for sprite 10

.tileSprite10

 SKIP 1                 ; Tile pattern number for sprite 10

.attrSprite10

 SKIP 1                 ; Attributes for sprite 10

.xSprite10

 SKIP 1                 ; Screen x-coordinate for sprite 10

.ySprite11

 SKIP 1                 ; Screen y-coordinate for sprite 11

.tileSprite11

 SKIP 1                 ; Tile pattern number for sprite 11

.attrSprite11

 SKIP 1                 ; Attributes for sprite 11

.xSprite11

 SKIP 1                 ; Screen x-coordinate for sprite 11

.ySprite12

 SKIP 1                 ; Screen y-coordinate for sprite 12

.tileSprite12

 SKIP 1                 ; Tile pattern number for sprite 12

.attrSprite12

 SKIP 1                 ; Attributes for sprite 12

.xSprite12

 SKIP 1                 ; Screen x-coordinate for sprite 12

.ySprite13

 SKIP 1                 ; Screen y-coordinate for sprite 13

.tileSprite13

 SKIP 1                 ; Tile pattern number for sprite 13

.attrSprite13

 SKIP 1                 ; Attributes for sprite 13

.xSprite13

 SKIP 1                 ; Screen x-coordinate for sprite 13

.ySprite14

 SKIP 1                 ; Screen y-coordinate for sprite 14

.tileSprite14

 SKIP 1                 ; Tile pattern number for sprite 14

.attrSprite14

 SKIP 1                 ; Attributes for sprite 14

.xSprite14

 SKIP 1                 ; Screen x-coordinate for sprite 14

.ySprite15

 SKIP 1                 ; Screen y-coordinate for sprite 15

.tileSprite15

 SKIP 1                 ; Tile pattern number for sprite 15

.attrSprite15

 SKIP 1                 ; Attributes for sprite 15

.xSprite15

 SKIP 1                 ; Screen x-coordinate for sprite 15

.ySprite16

 SKIP 1                 ; Screen y-coordinate for sprite 16

.tileSprite16

 SKIP 1                 ; Tile pattern number for sprite 16

.attrSprite16

 SKIP 1                 ; Attributes for sprite 16

.xSprite16

 SKIP 1                 ; Screen x-coordinate for sprite 16

.ySprite17

 SKIP 1                 ; Screen y-coordinate for sprite 17

.tileSprite17

 SKIP 1                 ; Tile pattern number for sprite 17

.attrSprite17

 SKIP 1                 ; Attributes for sprite 17

.xSprite17

 SKIP 1                 ; Screen x-coordinate for sprite 17

.ySprite18

 SKIP 1                 ; Screen y-coordinate for sprite 18

.tileSprite18

 SKIP 1                 ; Tile pattern number for sprite 18

.attrSprite18

 SKIP 1                 ; Attributes for sprite 18

.xSprite18

 SKIP 1                 ; Screen x-coordinate for sprite 18

.ySprite19

 SKIP 1                 ; Screen y-coordinate for sprite 19

.tileSprite19

 SKIP 1                 ; Tile pattern number for sprite 19

.attrSprite19

 SKIP 1                 ; Attributes for sprite 19

.xSprite19

 SKIP 1                 ; Screen x-coordinate for sprite 19

.ySprite20

 SKIP 1                 ; Screen y-coordinate for sprite 20

.tileSprite20

 SKIP 1                 ; Tile pattern number for sprite 20

.attrSprite20

 SKIP 1                 ; Attributes for sprite 20

.xSprite20

 SKIP 1                 ; Screen x-coordinate for sprite 20

.ySprite21

 SKIP 1                 ; Screen y-coordinate for sprite 21

.tileSprite21

 SKIP 1                 ; Tile pattern number for sprite 21

.attrSprite21

 SKIP 1                 ; Attributes for sprite 21

.xSprite21

 SKIP 1                 ; Screen x-coordinate for sprite 21

.ySprite22

 SKIP 1                 ; Screen y-coordinate for sprite 22

.tileSprite22

 SKIP 1                 ; Tile pattern number for sprite 22

.attrSprite22

 SKIP 1                 ; Attributes for sprite 22

.xSprite22

 SKIP 1                 ; Screen x-coordinate for sprite 22

.ySprite23

 SKIP 1                 ; Screen y-coordinate for sprite 23

.tileSprite23

 SKIP 1                 ; Tile pattern number for sprite 23

.attrSprite23

 SKIP 1                 ; Attributes for sprite 23

.xSprite23

 SKIP 1                 ; Screen x-coordinate for sprite 23

.ySprite24

 SKIP 1                 ; Screen y-coordinate for sprite 24

.tileSprite24

 SKIP 1                 ; Tile pattern number for sprite 24

.attrSprite24

 SKIP 1                 ; Attributes for sprite 24

.xSprite24

 SKIP 1                 ; Screen x-coordinate for sprite 24

.ySprite25

 SKIP 1                 ; Screen y-coordinate for sprite 25

.tileSprite25

 SKIP 1                 ; Tile pattern number for sprite 25

.attrSprite25

 SKIP 1                 ; Attributes for sprite 25

.xSprite25

 SKIP 1                 ; Screen x-coordinate for sprite 25

.ySprite26

 SKIP 1                 ; Screen y-coordinate for sprite 26

.tileSprite26

 SKIP 1                 ; Tile pattern number for sprite 26

.attrSprite26

 SKIP 1                 ; Attributes for sprite 26

.xSprite26

 SKIP 1                 ; Screen x-coordinate for sprite 26

.ySprite27

 SKIP 1                 ; Screen y-coordinate for sprite 27

.tileSprite27

 SKIP 1                 ; Tile pattern number for sprite 27

.attrSprite27

 SKIP 1                 ; Attributes for sprite 27

.xSprite27

 SKIP 1                 ; Screen x-coordinate for sprite 27

.ySprite28

 SKIP 1                 ; Screen y-coordinate for sprite 28

.tileSprite28

 SKIP 1                 ; Tile pattern number for sprite 28

.attrSprite28

 SKIP 1                 ; Attributes for sprite 28

.xSprite28

 SKIP 1                 ; Screen x-coordinate for sprite 28

.ySprite29

 SKIP 1                 ; Screen y-coordinate for sprite 29

.tileSprite29

 SKIP 1                 ; Tile pattern number for sprite 29

.attrSprite29

 SKIP 1                 ; Attributes for sprite 29

.xSprite29

 SKIP 1                 ; Screen x-coordinate for sprite 29

.ySprite30

 SKIP 1                 ; Screen y-coordinate for sprite 30

.tileSprite30

 SKIP 1                 ; Tile pattern number for sprite 30

.attrSprite30

 SKIP 1                 ; Attributes for sprite 30

.xSprite30

 SKIP 1                 ; Screen x-coordinate for sprite 30

.ySprite31

 SKIP 1                 ; Screen y-coordinate for sprite 31

.tileSprite31

 SKIP 1                 ; Tile pattern number for sprite 31

.attrSprite31

 SKIP 1                 ; Attributes for sprite 31

.xSprite31

 SKIP 1                 ; Screen x-coordinate for sprite 31

.ySprite32

 SKIP 1                 ; Screen y-coordinate for sprite 32

.tileSprite32

 SKIP 1                 ; Tile pattern number for sprite 32

.attrSprite32

 SKIP 1                 ; Attributes for sprite 32

.xSprite32

 SKIP 1                 ; Screen x-coordinate for sprite 32

.ySprite33

 SKIP 1                 ; Screen y-coordinate for sprite 33

.tileSprite33

 SKIP 1                 ; Tile pattern number for sprite 33

.attrSprite33

 SKIP 1                 ; Attributes for sprite 33

.xSprite33

 SKIP 1                 ; Screen x-coordinate for sprite 33

.ySprite34

 SKIP 1                 ; Screen y-coordinate for sprite 34

.tileSprite34

 SKIP 1                 ; Tile pattern number for sprite 34

.attrSprite34

 SKIP 1                 ; Attributes for sprite 34

.xSprite34

 SKIP 1                 ; Screen x-coordinate for sprite 34

.ySprite35

 SKIP 1                 ; Screen y-coordinate for sprite 35

.tileSprite35

 SKIP 1                 ; Tile pattern number for sprite 35

.attrSprite35

 SKIP 1                 ; Attributes for sprite 35

.xSprite35

 SKIP 1                 ; Screen x-coordinate for sprite 35

.ySprite36

 SKIP 1                 ; Screen y-coordinate for sprite 36

.tileSprite36

 SKIP 1                 ; Tile pattern number for sprite 36

.attrSprite36

 SKIP 1                 ; Attributes for sprite 36

.xSprite36

 SKIP 1                 ; Screen x-coordinate for sprite 36

.ySprite37

 SKIP 1                 ; Screen y-coordinate for sprite 37

.tileSprite37

 SKIP 1                 ; Tile pattern number for sprite 37

.attrSprite37

 SKIP 1                 ; Attributes for sprite 37

.xSprite37

 SKIP 1                 ; Screen x-coordinate for sprite 37

.ySprite38

 SKIP 1                 ; Screen y-coordinate for sprite 38

.tileSprite38

 SKIP 1                 ; Tile pattern number for sprite 38

.attrSprite38

 SKIP 1                 ; Attributes for sprite 38

.xSprite38

 SKIP 1                 ; Screen x-coordinate for sprite 38

.ySprite39

 SKIP 1                 ; Screen y-coordinate for sprite 39

.tileSprite39

 SKIP 1                 ; Tile pattern number for sprite 39

.attrSprite39

 SKIP 1                 ; Attributes for sprite 39

.xSprite39

 SKIP 1                 ; Screen x-coordinate for sprite 39

.ySprite40

 SKIP 1                 ; Screen y-coordinate for sprite 40

.tileSprite40

 SKIP 1                 ; Tile pattern number for sprite 40

.attrSprite40

 SKIP 1                 ; Attributes for sprite 40

.xSprite40

 SKIP 1                 ; Screen x-coordinate for sprite 40

.ySprite41

 SKIP 1                 ; Screen y-coordinate for sprite 41

.tileSprite41

 SKIP 1                 ; Tile pattern number for sprite 41

.attrSprite41

 SKIP 1                 ; Attributes for sprite 41

.xSprite41

 SKIP 1                 ; Screen x-coordinate for sprite 41

.ySprite42

 SKIP 1                 ; Screen y-coordinate for sprite 42

.tileSprite42

 SKIP 1                 ; Tile pattern number for sprite 42

.attrSprite42

 SKIP 1                 ; Attributes for sprite 42

.xSprite42

 SKIP 1                 ; Screen x-coordinate for sprite 42

.ySprite43

 SKIP 1                 ; Screen y-coordinate for sprite 43

.tileSprite43

 SKIP 1                 ; Tile pattern number for sprite 43

.attrSprite43

 SKIP 1                 ; Attributes for sprite 43

.xSprite43

 SKIP 1                 ; Screen x-coordinate for sprite 43

.ySprite44

 SKIP 1                 ; Screen y-coordinate for sprite 44

.tileSprite44

 SKIP 1                 ; Tile pattern number for sprite 44

.attrSprite44

 SKIP 1                 ; Attributes for sprite 44

.xSprite44

 SKIP 1                 ; Screen x-coordinate for sprite 44

.ySprite45

 SKIP 1                 ; Screen y-coordinate for sprite 45

.tileSprite45

 SKIP 1                 ; Tile pattern number for sprite 45

.attrSprite45

 SKIP 1                 ; Attributes for sprite 45

.xSprite45

 SKIP 1                 ; Screen x-coordinate for sprite 45

.ySprite46

 SKIP 1                 ; Screen y-coordinate for sprite 46

.tileSprite46

 SKIP 1                 ; Tile pattern number for sprite 46

.attrSprite46

 SKIP 1                 ; Attributes for sprite 46

.xSprite46

 SKIP 1                 ; Screen x-coordinate for sprite 46

.ySprite47

 SKIP 1                 ; Screen y-coordinate for sprite 47

.tileSprite47

 SKIP 1                 ; Tile pattern number for sprite 47

.attrSprite47

 SKIP 1                 ; Attributes for sprite 47

.xSprite47

 SKIP 1                 ; Screen x-coordinate for sprite 47

.ySprite48

 SKIP 1                 ; Screen y-coordinate for sprite 48

.tileSprite48

 SKIP 1                 ; Tile pattern number for sprite 48

.attrSprite48

 SKIP 1                 ; Attributes for sprite 48

.xSprite48

 SKIP 1                 ; Screen x-coordinate for sprite 48

.ySprite49

 SKIP 1                 ; Screen y-coordinate for sprite 49

.tileSprite49

 SKIP 1                 ; Tile pattern number for sprite 49

.attrSprite49

 SKIP 1                 ; Attributes for sprite 49

.xSprite49

 SKIP 1                 ; Screen x-coordinate for sprite 49

.ySprite50

 SKIP 1                 ; Screen y-coordinate for sprite 50

.tileSprite50

 SKIP 1                 ; Tile pattern number for sprite 50

.attrSprite50

 SKIP 1                 ; Attributes for sprite 50

.xSprite50

 SKIP 1                 ; Screen x-coordinate for sprite 50

.ySprite51

 SKIP 1                 ; Screen y-coordinate for sprite 51

.tileSprite51

 SKIP 1                 ; Tile pattern number for sprite 51

.attrSprite51

 SKIP 1                 ; Attributes for sprite 51

.xSprite51

 SKIP 1                 ; Screen x-coordinate for sprite 51

.ySprite52

 SKIP 1                 ; Screen y-coordinate for sprite 52

.tileSprite52

 SKIP 1                 ; Tile pattern number for sprite 52

.attrSprite52

 SKIP 1                 ; Attributes for sprite 52

.xSprite52

 SKIP 1                 ; Screen x-coordinate for sprite 52

.ySprite53

 SKIP 1                 ; Screen y-coordinate for sprite 53

.tileSprite53

 SKIP 1                 ; Tile pattern number for sprite 53

.attrSprite53

 SKIP 1                 ; Attributes for sprite 53

.xSprite53

 SKIP 1                 ; Screen x-coordinate for sprite 53

.ySprite54

 SKIP 1                 ; Screen y-coordinate for sprite 54

.tileSprite54

 SKIP 1                 ; Tile pattern number for sprite 54

.attrSprite54

 SKIP 1                 ; Attributes for sprite 54

.xSprite54

 SKIP 1                 ; Screen x-coordinate for sprite 54

.ySprite55

 SKIP 1                 ; Screen y-coordinate for sprite 55

.tileSprite55

 SKIP 1                 ; Tile pattern number for sprite 55

.attrSprite55

 SKIP 1                 ; Attributes for sprite 55

.xSprite55

 SKIP 1                 ; Screen x-coordinate for sprite 55

.ySprite56

 SKIP 1                 ; Screen y-coordinate for sprite 56

.tileSprite56

 SKIP 1                 ; Tile pattern number for sprite 56

.attrSprite56

 SKIP 1                 ; Attributes for sprite 56

.xSprite56

 SKIP 1                 ; Screen x-coordinate for sprite 56

.ySprite57

 SKIP 1                 ; Screen y-coordinate for sprite 57

.tileSprite57

 SKIP 1                 ; Tile pattern number for sprite 57

.attrSprite57

 SKIP 1                 ; Attributes for sprite 57

.xSprite57

 SKIP 1                 ; Screen x-coordinate for sprite 57

.ySprite58

 SKIP 1                 ; Screen y-coordinate for sprite 58

.tileSprite58

 SKIP 1                 ; Tile pattern number for sprite 58

.attrSprite58

 SKIP 1                 ; Attributes for sprite 58

.xSprite58

 SKIP 1                 ; Screen x-coordinate for sprite 58

.ySprite59

 SKIP 1                 ; Screen y-coordinate for sprite 59

.tileSprite59

 SKIP 1                 ; Tile pattern number for sprite 59

.attrSprite59

 SKIP 1                 ; Attributes for sprite 59

.xSprite59

 SKIP 1                 ; Screen x-coordinate for sprite 59

.ySprite60

 SKIP 1                 ; Screen y-coordinate for sprite 60

.tileSprite60

 SKIP 1                 ; Tile pattern number for sprite 60

.attrSprite60

 SKIP 1                 ; Attributes for sprite 60

.xSprite60

 SKIP 1                 ; Screen x-coordinate for sprite 60

.ySprite61

 SKIP 1                 ; Screen y-coordinate for sprite 61

.tileSprite61

 SKIP 1                 ; Tile pattern number for sprite 61

.attrSprite61

 SKIP 1                 ; Attributes for sprite 61

.xSprite61

 SKIP 1                 ; Screen x-coordinate for sprite 61

.ySprite62

 SKIP 1                 ; Screen y-coordinate for sprite 62

.tileSprite62

 SKIP 1                 ; Tile pattern number for sprite 62

.attrSprite62

 SKIP 1                 ; Attributes for sprite 62

.xSprite62

 SKIP 1                 ; Screen x-coordinate for sprite 62

.ySprite63

 SKIP 1                 ; Screen y-coordinate for sprite 63

.tileSprite63

 SKIP 1                 ; Tile pattern number for sprite 63

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

.L0300

 SKIP 1                 ; ???

.L0301

 SKIP 1                 ; ???

.L0302

 SKIP 1                 ; ???

.L0303

 SKIP 1                 ; ???

.L0304

 SKIP 1                 ; ???

.L0305

 SKIP 1                 ; ???

.L0306

 SKIP 1                 ; ???

.L0307

 SKIP 1                 ; ???

.L0308

 SKIP 1                 ; ???

.L0309

 SKIP 1                 ; ???

.L030A

 SKIP 1                 ; ???

.L030B

 SKIP 1                 ; ???

.L030C

 SKIP 1                 ; ???

.L030D

 SKIP 1                 ; ???

.L030E

 SKIP 1                 ; ???

.L030F

 SKIP 1                 ; ???

.L0310

 SKIP 1                 ; ???

.L0311

 SKIP 1                 ; ???

.L0312

 SKIP 1                 ; ???

.L0313

 SKIP 1                 ; ???

.L0314

 SKIP 1                 ; ???

.L0315

 SKIP 1                 ; ???

.L0316

 SKIP 1                 ; ???

.L0317

 SKIP 1                 ; ???

.L0318

 SKIP 1                 ; ???

.L0319

 SKIP 1                 ; ???

.L031A

 SKIP 1                 ; ???

.L031B

 SKIP 1                 ; ???

.L031C

 SKIP 1                 ; ???

.L031D

 SKIP 1                 ; ???

.L031E

 SKIP 1                 ; ???

.L031F

 SKIP 1                 ; ???

.L0320

 SKIP 1                 ; ???

.L0321

 SKIP 1                 ; ???

.L0322

 SKIP 1                 ; ???

.L0323

 SKIP 1                 ; ???

.L0324

 SKIP 1                 ; ???

.L0325

 SKIP 1                 ; ???

.L0326

 SKIP 1                 ; ???

.L0327

 SKIP 1                 ; ???

.L0328

 SKIP 1                 ; ???

.L0329

 SKIP 1                 ; ???

.L032A

 SKIP 1                 ; ???

.L032B

 SKIP 1                 ; ???

.L032C

 SKIP 1                 ; ???

.L032D

 SKIP 1                 ; ???

.L032E

 SKIP 1                 ; ???

.L032F

 SKIP 1                 ; ???

.L0330

 SKIP 1                 ; ???

.L0331

 SKIP 1                 ; ???

.L0332

 SKIP 1                 ; ???

.L0333

 SKIP 1                 ; ???

.L0334

 SKIP 1                 ; ???

.L0335

 SKIP 1                 ; ???

.L0336

 SKIP 1                 ; ???

.L0337

 SKIP 1                 ; ???

.L0338

 SKIP 1                 ; ???

.L0339

 SKIP 1                 ; ???

.L033A

 SKIP 1                 ; ???

.L033B

 SKIP 1                 ; ???

.L033C

 SKIP 1                 ; ???

.L033D

 SKIP 1                 ; ???

.L033E

 SKIP 1                 ; ???

.L033F

 SKIP 1                 ; ???

.L0340

 SKIP 1                 ; ???

.L0341

 SKIP 1                 ; ???

.L0342

 SKIP 1                 ; ???

.L0343

 SKIP 1                 ; ???

.L0344

 SKIP 1                 ; ???

.L0345

 SKIP 1                 ; ???

.L0346

 SKIP 1                 ; ???

.L0347

 SKIP 1                 ; ???

.L0348

 SKIP 1                 ; ???

.L0349

 SKIP 1                 ; ???

.L034A

 SKIP 1                 ; ???

.L034B

 SKIP 1                 ; ???

.L034C

 SKIP 1                 ; ???

.L034D

 SKIP 1                 ; ???

.L034E

 SKIP 1                 ; ???

.L034F

 SKIP 1                 ; ???

.L0350

 SKIP 1                 ; ???

.L0351

 SKIP 1                 ; ???

.L0352

 SKIP 1                 ; ???

.L0353

 SKIP 1                 ; ???

.L0354

 SKIP 1                 ; ???

.L0355

 SKIP 1                 ; ???

.L0356

 SKIP 1                 ; ???

.L0357

 SKIP 1                 ; ???

.L0358

 SKIP 1                 ; ???

.L0359

 SKIP 1                 ; ???

.L035A

 SKIP 1                 ; ???

.L035B

 SKIP 1                 ; ???

.L035C

 SKIP 1                 ; ???

.L035D

 SKIP 1                 ; ???

.L035E

 SKIP 1                 ; ???

.L035F

 SKIP 1                 ; ???

.L0360

 SKIP 1                 ; ???

.L0361

 SKIP 1                 ; ???

.L0362

 SKIP 1                 ; ???

.L0363

 SKIP 1                 ; ???

.L0364

 SKIP 1                 ; ???

.L0365

 SKIP 1                 ; ???

.L0366

 SKIP 1                 ; ???

.L0367

 SKIP 1                 ; ???

.L0368

 SKIP 1                 ; ???

.L0369

 SKIP 1                 ; ???

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

.scannerFlags

 SKIP 10                ; ??? Bytes 1-8 contain flags for ships on scanner
                        ; Bytes 0 and 9 are unused

.scannerAttrs

 SKIP 10                ; ??? Bytes 1-8 contain attributes for ships on scanner
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
                        ;
                        ; CABTMP shares a location with MANY, but that's OK as
                        ; MANY+0 would contain the number of ships of type 0,
                        ; and as there is no ship type 0 (they start at 1), the
                        ; byte at MANY+0 is not used for storing a ship type
                        ; and can be used for the cabin temperature instead

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
                        ;     yellow/white)
                        ;
                        ;   * Non-zero = missile is currently looking for a
                        ;     target (indicator is yellow/white)

.VIEW

 SKIP 1                 ; The number of the current space view
                        ;
                        ;   * 0 = front
                        ;   * 1 = rear
                        ;   * 2 = left
                        ;   * 3 = right
                        ;   * 4 = witchspace (for a mis-jump)

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

 SKIP 1                 ; A flag that toggles the hyperspace colour effect
                        ;
                        ;   * 0 = no colour effect
                        ;
                        ;   * Non-zero = hyperspace colour effect enabled
                        ;

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
                        ;   * Bit 7 is set when when there is a currently
                        ;     selected system, clear otherwise (such as when we
                        ;     are moving the crosshairs between systems)

.NAME

 SKIP 7                 ; The current commander name
                        ;
                        ; The commander name can be up to 7 characters long

.SVC

 SKIP 1                 ; The save count
                        ;
                        ; This is not used in the NES version of Elite (it is
                        ; used to keep track of the number of saves in the
                        ; original version)

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
                        ; If the high byte in TALLY+1 is 0 then we have between
                        ; 0 and 255 kills, so our rank is Harmless, Mostly
                        ; Harmless, Poor, Average or Above Average, according to
                        ; the value of the low byte in TALLY:
                        ;
                        ;   Harmless        = %00000000 to %00000011 = 0 to 3
                        ;   Mostly Harmless = %00000100 to %00000111 = 4 to 7
                        ;   Poor            = %00001000 to %00001111 = 8 to 15
                        ;   Average         = %00010000 to %00011111 = 16 to 31
                        ;   Above Average   = %00100000 to %11111111 = 32 to 255
                        ;
                        ; If the high byte in TALLY+1 is non-zero then we are
                        ; Competent, Dangerous, Deadly or Elite, according to
                        ; the high byte in TALLY+1:
                        ;
                        ;   Competent       = 1           = 256 to 511 kills
                        ;   Dangerous       = 2 to 9      = 512 to 2559 kills
                        ;   Deadly          = 10 to 24    = 2560 to 6399 kills
                        ;   Elite           = 25 and up   = 6400 kills and up
                        ;
                        ; You can see the rating calculation in STATUS

 SKIP 1                 ; ???

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
                        ; which is 18 (#NOST) for normal space, and 3 for
                        ; witchspace

.L03E6

 SKIP 1                 ; ???

.L03E7

 SKIP 1                 ; ???

.L03E8

 SKIP 1                 ; ???

.L03E9

 SKIP 1                 ; ??? Unused?

.DAMP

 SKIP 1                 ; Keyboard damping configuration setting
                        ;
                        ;   * 0 = damping is disabled
                        ;
                        ;   * $FF = damping is enabled (default)

.JSTGY

 SKIP 1                 ; Reverse joystick Y-channel configuration setting
                        ;
                        ;   * 0 = standard Y-channel (default)
                        ;
                        ;   * $FF = reversed Y-channel

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
                        ;                 autoplayKeys table

.bitplaneFlags

 SKIP 1                 ; Flags for bitplane 0 that control the sending of data
                        ; for this bitplane to the PPU during VBlank in the NMI
                        ; handler:
                        ;
                        ;   * Bit 0 is ignored and is always clear
                        ;
                        ;   * Bit 1 is ignored and is always clear
                        ;
                        ;   * Bit 2 overrides the number of the last tile to
                        ;     send to the PPU nametable in SendBuffersToPPU:
                        ;
                        ;     * 0 = set the last tile number to lastNameTile or
                        ;           lastPatternTile for this bitplane (when
                        ;           sending nametable and pattern entries
                        ;           respectively)
                        ;
                        ;     * 1 = set the last tile number to 128 (which means
                        ;           tile 8 * 128 = 1024)
                        ;
                        ;   * Bit 3 controls the clearing of this bitplane's
                        ;     buffer in NMI handler, once it has been sent to
                        ;
                        ;     * 0 = do not clear this bitplane's buffer
                        ;
                        ;     * 1 = clear this bitplane's buffer once it has
                        ;           been sent to the PPU
                        ;
                        ;   * Bit 4 determines whether a tile data transfer is
                        ;     already in progress for this bitplane:
                        ;
                        ;     * 0 = we are not currently in the process of
                        ;           sending tile data to the PPU for this
                        ;           bitplane
                        ;
                        ;     * 1 = we are in the process of sending tile data
                        ;           to the PPU for the this bitplane, possibly
                        ;           spread across multiple VBlanks
                        ;
                        ;   * Bit 5 determines whether we have already sent all
                        ;     the data to the PPU for this bitplane:
                        ;
                        ;     * 0 = we have not already sent all the data to the
                        ;           PPU for this bitplane
                        ;
                        ;     * 1 = we have already sent all the data to the PPU
                        ;           for this bitplane
                        ;
                        ;   * Bit 6 determines whether to send nametable data as
                        ;     well as pattern data
                        ;
                        ;     * 0 = only send pattern data for this bitplane,
                        ;           and stop sending it if the other bitplane is
                        ;           ready to be sent
                        ;
                        ;     * 1 = send both pattern and nametable data for
                        ;           this bitplane
                        ;
                        ;   * Bit 7 determines whether we should send data to
                        ;     the PPU for this bitplane
                        ;
                        ;     * 0 = do not send data to the PPU
                        ;
                        ;     * 1 = send data to the PPU

 SKIP 1                 ; Flags for bitplane 1 (see above)

.frameCounter

 SKIP 1                 ; Increments every VBlank ???

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
                        ;   * %00100000 = apply lower case to the second letter
                        ;                 of a word onwards
                        ;
                        ;   * %00000000 = do not change case to lower case

.DTW8

 SKIP 1                 ; A mask for capitalising the next letter in an extended
                        ; text token
                        ;
                        ;   * %11011111 = capitalise the next letter
                        ;
                        ;   * %11111111 = do not change case

.XP

 SKIP 1                 ; The x-coordinate of the current character as we
                        ; construct the lines for the Star Wars scroll text

.YP

 SKIP 1                 ; The y-coordinate of the current character as we
                        ; construct the lines for the Star Wars scroll text

.L03FC

 SKIP 1                 ; ???

.decimalPoint

 SKIP 1                 ; The decimal point character for the chosen language

.L03FE

 SKIP 1                 ; ???

.L03FF

 SKIP 1                 ; ???

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

.L0402

 SKIP 1

.KL

 SKIP 0                 ; The following bytes implement a key logger that
                        ; enables Elite to scan for concurrent key presses on
                        ; both controllers

.KY1

 SKIP 1                 ; "?" is being pressed
                        ;
                        ;   * 0 = no
                        ;
                        ;   * Non-zero = yes

.KY2

 SKIP 1                 ; Space is being pressed
                        ;
                        ;   * 0 = no
                        ;
                        ;   * Non-zero = yes

.KY3

 SKIP 1                 ; "<" is being pressed
                        ;
                        ;   * 0 = no
                        ;
                        ;   * Non-zero = yes

.KY4

 SKIP 1                 ; ">" is being pressed
                        ;
                        ;   * 0 = no
                        ;
                        ;   * Non-zero = yes

.KY5

 SKIP 1                 ; "X" is being pressed
                        ;
                        ;   * 0 = no
                        ;
                        ;   * Non-zero = yes

.KY6

 SKIP 1                 ; "S" is being pressed
                        ;
                        ;   * 0 = no
                        ;
                        ;   * Non-zero = yes

.KY7

 SKIP 1                 ; "A" is being pressed
                        ;
                        ;   * 0 = no
                        ;
                        ;   * Non-zero = yes

.L040A

 SKIP 1                 ; ???

.L040B

 SKIP 1                 ; ???

.L040C

 SKIP 1                 ; ???

.L040D

 SKIP 1                 ; ???

.L040E

 SKIP 1                 ; ???

.L040F

 SKIP 1                 ; ???

.L0410

 SKIP 1                 ; ???

.L0411

 SKIP 1                 ; ???

.L0412

 SKIP 1                 ; ???

.L0413

 SKIP 1                 ; ???

.L0414

 SKIP 1                 ; ???

.L0415

 SKIP 1                 ; ???

.L0416

 SKIP 1                 ; ???

.L0417

 SKIP 1                 ; ???

.L0418

 SKIP 1                 ; ???

.L0419

 SKIP 1                 ; ???

.L041A

 SKIP 1                 ; ???

.L041B

 SKIP 1                 ; ???

.L041C

 SKIP 1                 ; ???

.L041D

 SKIP 1                 ; ???

.L041E

 SKIP 1                 ; ???

.L041F

 SKIP 1                 ; ???

.L0420

 SKIP 1                 ; ???

.L0421

 SKIP 1                 ; ???

.L0422

 SKIP 1                 ; ???

.L0423

 SKIP 1                 ; ???

.L0424

 SKIP 1                 ; ???

.L0425

 SKIP 1                 ; ???

.L0426

 SKIP 1                 ; ???

.L0427

 SKIP 1                 ; ???

.L0428

 SKIP 1                 ; ???

.L0429

 SKIP 1                 ; ???

.L042A

 SKIP 1                 ; ???

.L042B

 SKIP 1                 ; ???

.L042C

 SKIP 1                 ; ???

.L042D

 SKIP 1                 ; ???

.L042E

 SKIP 1                 ; ???

.L042F

 SKIP 1                 ; ???

.L0430

 SKIP 1                 ; ???

.L0431

 SKIP 1                 ; ???

.L0432

 SKIP 1                 ; ???

.L0433

 SKIP 1                 ; ???

.L0434

 SKIP 1                 ; ???

.L0435

 SKIP 1                 ; ???

.L0436

 SKIP 1                 ; ???

.L0437

 SKIP 1                 ; ???

.L0438

 SKIP 1                 ; ???

.L0439

 SKIP 1                 ; ???

.L043A

 SKIP 1                 ; ???

.L043B

 SKIP 1                 ; ???

.L043C

 SKIP 1                 ; ???

.L043D

 SKIP 1                 ; ???

.L043E

 SKIP 1                 ; ???

.L043F

 SKIP 1                 ; ???

.L0440

 SKIP 1                 ; ???

.L0441

 SKIP 1                 ; ???

.L0442

 SKIP 1                 ; ???

.L0443

 SKIP 1                 ; ???

.L0444

 SKIP 1                 ; ???

.L0445

 SKIP 1                 ; ???

.L0446

 SKIP 1                 ; ???

.L0447

 SKIP 1                 ; ???

.L0448

 SKIP 1                 ; ???

.L0449

 SKIP 1                 ; ???

.L044A

 SKIP 1                 ; ???

.L044B

 SKIP 1                 ; ???

.L044C

 SKIP 1                 ; ???

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

.pointerTimerOn

 SKIP 1                 ; A flag to denote whether pointerTimer is non-zero:
                        ;
                        ;   * 0 = pointerTimer is zero
                        ;
                        ;   * 1 = pointerTimer is non-zero

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

.yIconBarPointer

 SKIP 1                 ; The y-coordinate of the icon bar pointer
                        ;
                        ; This is either 148 (when the dashboard is visible) or
                        ; 204 (when there is no dashboard and the icon bar is
                        ; along the bottom of the screen)

.pointerDirection

 SKIP 1                 ; The direction in which the icon bar pointer is moving:
                        ;
                        ;   * 0 = pointer is not moving
                        ;
                        ;   * 1 = pointer is moving to the right
                        ;
                        ;   * $FF = pointer is moving to the left

.pointerPosition

 SKIP 1                 ; The position of the icon bar pointer as it moves
                        ; between icons, counting down from 12 (at the start of
                        ; the move) to 0 (at the end of the move)

.iconBarType

 SKIP 1                 ; The type of the current icon bar:
                        ;
                        ;   * 0 = docked
                        ;   * 1 = flight
                        ;   * 2 = charts
                        ;   * 3 = pause options
                        ;   * 4 = title screen copyright message

.pointerButton

 SKIP 1                 ; The button number from the iconBarButtons table for
                        ; the button under the icon bar pointer
                        ;
                        ; Set to 80 if Start is pressed to pause the game

.L0466

 SKIP 1                 ; ??? Unused

.pointerTimer

 SKIP 1                 ; A timer that starts counting down when B is released
                        ; when moving the icon bar pointer, so that a double-tap
                        ; on B can be interpreted as a selection

.L0468

 SKIP 1                 ; ???

.nmiStoreA

 SKIP 1                 ; Temporary storage for the A register during NMI

.nmiStoreX

 SKIP 1                 ; Temporary storage for the X register during NMI

.nmiStoreY

 SKIP 1                 ; Temporary storage for the Y register during NMI

.pictureTile

 SKIP 1                 ; The number of the first tile where system pictures
                        ; are stored ???

.L046D

 SKIP 1                 ; ???

.boxEdge1

 SKIP 1                 ; Tile number for drawing box edge ???

.boxEdge2

 SKIP 1                 ; Tile number for drawing box edge ???

.L0470

 SKIP 1                 ; ???

.previousCondition

 SKIP 1                 ; ???

.statusCondition

 SKIP 1                 ; ???

.screenFadedToBlack

 SKIP 1                 ; Records whether the screen has been faded to black
                        ;
                        ;   * Bit 7 clear = screen is full colour
                        ;
                        ;   * Bit 7 set = screen has been faded to black

.L0474

 SKIP 1                 ; ???

.scanController2

 SKIP 1                 ; If non-zero, scan controller 2 ???
                        ;
                        ; Toggled between 0 and 1 by the "one or two pilots"
                        ; configuration icon

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

.soundPriority

 SKIP 3                 ; ???

.LASX

 SKIP 1                 ; The x-coordinate of the tip of the laser line

.LASY

 SKIP 1                 ; The y-coordinate of the tip of the laser line

.L047D

 SKIP 1                 ; ???

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

.L0483

 SKIP 1                 ; ???

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
                        ;         for the Save and load screen
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

.L04A0

 SKIP 1                 ; ???

.L04A1

 SKIP 1                 ; ???

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

 SKIP 1                 ; ???

.controller2Down

 SKIP 1                 ; ???

.controller1Up

 SKIP 1                 ; ???

.controller2Up

 SKIP 1                 ; ???

.controller1Left

 SKIP 1                 ; ???

.controller2Left

 SKIP 1                 ; ???

.controller1Right

 SKIP 1                 ; ???

.controller2Right

 SKIP 1                 ; ???

.controller1A

 SKIP 1                 ; ???

.controller2A

 SKIP 1                 ; ???

.controller1B

 SKIP 1                 ; ???

.controller2B

 SKIP 1                 ; ???

.controller1Start

 SKIP 1                 ; ???

.controller2Start

 SKIP 1                 ; ???

.controller1Select

 SKIP 1                 ; ???

.controller2Select

 SKIP 1                 ; ???

.controller1Leftx8

 SKIP 1                 ; ???

.controller1Rightx8

 SKIP 1                 ; ???

.autoplayKey

 SKIP 1                 ; ???

.demoLoopCounter

 SKIP 1                 ; ???

.pattTileBuffHi

 SKIP 1                 ; (pattTileBuffHi pattTileBuffLo) contains the address
                        ; of the pattern buffer for the tile we are sending to
                        ; the PPU from bitplane 0 (i.e. for tile number
                        ; sendingPattTile in bitplane 0)

 SKIP 1                 ; (pattTileBuffHi pattTileBuffLo) contains the address
                        ; of the pattern buffer for the tile we are sending to
                        ; the PPU from bitplane 1 (i.e. for tile number
                        ; sendingPattTile in bitplane 1)

.nameTileBuffHi

 SKIP 1                 ; (nameTileBuffHi nameTileBuffLo) contains the address
                        ; of the nametable buffer for the tile we are sending to
                        ; the PPU from bitplane 0 (i.e. for tile number
                        ; sendingNameTile in bitplane 0)

 SKIP 1                 ; (nameTileBuffHi nameTileBuffLo) contains the address
                        ; of the nametable buffer for the tile we are sending to
                        ; the PPU from bitplane 1 (i.e. for tile number
                        ; sendingNameTile in bitplane 1)

.L04C2

 SKIP 4                 ; ???

.ppuToBuffNameHi

 SKIP 1                 ; Add this to a nametable buffer address to get the
                        ; corresponding PPU nametable address (high byte) in
                        ; bitplane 0 ???

 SKIP 1                 ; Add this to a nametable buffer address to get the
                        ; corresponding PPU nametable address (high byte) in
                        ; bitplane 1 ???

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
                        ; stored at MANY+X, so the number of Sidewinders is at
                        ; MANY+1, the number of Mambas is at MANY+2, and so on
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

.L0584

 SKIP 1                 ; ???

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

.L05EA

 SKIP 1                 ; ???

.L05EB

 SKIP 1                 ; ???

.L05EC

 SKIP 1                 ; ???

.L05ED

 SKIP 1                 ; ???

.L05EE

 SKIP 1                 ; ???

.L05EF

 SKIP 1                 ; ???

.L05F0

 SKIP 1                 ; ???

.L05F1

 SKIP 1                 ; ???

.L05F2

 SKIP 1                 ; ???

 CLEAR BUF+32, P%       ; The following tables share space with BUF through to
 ORG BUF+32             ; K%, which we can do as the scroll text is not shown
                        ; at the same time as ships, stardust and so on

.X1TB

 SKIP 240               ; The x-coordinates of the start points for character
                        ; lines in the scroll text

.Y1TB

 SKIP 240               ; The y-coordinates of the start points for character
                        ; lines in the scroll text

.X2TB

 SKIP 240               ; The x-coordinates of the end points for character
                        ; lines in the scroll text

 PRINT "WP workspace from  ", ~WP," to ", ~P%

; ******************************************************************************
;
;       Name: K%
;       Type: Workspace
;    Address: $0600 to $07FF
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
; See the deep dive on "Ship data blocks" for details on ship data blocks, and
; the deep dive on "The local bubble of universe" for details of how Elite
; stores the local universe in K%, FRIN and UNIV.
;
; ******************************************************************************

 ORG $0600

.K%

 SKIP 0                 ; Ship data blocks and ship line heap

; ******************************************************************************
;
;       Name: pattBuffer0
;       Type: Variable
;   Category: Drawing the screen
;    Summary: Pattern buffer for colour 0 (1 bit per pixel)
;
; ******************************************************************************

 ORG $6000

.pattBuffer0

 SKIP 8 * 256           ; 256 patterns, 8 bytes per pattern (8x8 pixels)

; ******************************************************************************
;
;       Name: pattBuffer1
;       Type: Variable
;   Category: Drawing the screen
;    Summary: Pattern buffer for colour 1 (1 bit per pixel)
;
; ******************************************************************************

.pattBuffer1

 SKIP 8 * 256           ; 256 patterns, 8 bytes per pattern (8x8 pixels)

; ******************************************************************************
;
;       Name: nameBuffer0
;       Type: Variable
;   Category: Drawing the screen
;    Summary: Buffer for nametable 0
;
; ******************************************************************************

.nameBuffer0

 SKIP 30 * 32           ; 30 rows of 32 tile numbers

; ******************************************************************************
;
;       Name: attrBuffer0
;       Type: Variable
;   Category: Drawing the screen
;    Summary: Buffer for attribute table 0
;
; ******************************************************************************

.attrBuffer0

 SKIP 8 * 8             ; 8 rows of 8 attribute bytes (each is a 2x2 tile block)

; ******************************************************************************
;
;       Name: nameBuffer1
;       Type: Variable
;   Category: Drawing the screen
;    Summary: Buffer for nametable and attribute table 1
;
; ******************************************************************************

.nameBuffer1

 SKIP 30 * 32           ; 30 rows of 32 tile numbers

; ******************************************************************************
;
;       Name: attrBuffer1
;       Type: Variable
;   Category: Drawing the screen
;    Summary: Buffer for attribute table 1
;
; ******************************************************************************

.attrBuffer1

 SKIP 8 * 8             ; 8 rows of 8 attribute bytes (each is a 2x2 tile block)

; ******************************************************************************
;
;       Name: currentPosition
;       Type: Variable
;   Category: Save and load
;    Summary: The current commander file (or "position")
;
; ******************************************************************************

.currentPosition

 SKIP 256

; ******************************************************************************
;
;       Name: savedPositions0
;       Type: Variable
;   Category: Save and load
;    Summary: The eight slots for saving positions, split into three for copy
;             protection (this is the first part)
;
; ******************************************************************************

.savedPositions0

 SKIP 8 * 73

; ******************************************************************************
;
;       Name: savedPositions1
;       Type: Variable
;   Category: Save and load
;    Summary: The eight slots for saving positions, split into three for copy
;             protection (this is the second part)
;
; ******************************************************************************

.savedPositions1

 SKIP 8 * 73

; ******************************************************************************
;
;       Name: savedPositions2
;       Type: Variable
;   Category: Save and load
;    Summary: The eight slots for saving positions, split into three for copy
;             protection (this is the third part)
;
; ******************************************************************************

.savedPositions2

 SKIP 8 * 73

 SKIP 40                ; These bytes appear to be unused

; ******************************************************************************
;
;       Name: SETUP_PPU_FOR_ICON_BAR
;       Type: Macro
;   Category: PPU
;    Summary: If the PPU has started drawing the icon bar, configure the PPU to
;             use nametable 0 and pattern table 0
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
                        ; It gets zeroed at the start of each frame and set when
                        ; sprite 0 is drawn
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

 IF t = '-' AND k = '-' : EQUB 215 EOR VE : ENDIF
 IF t = 'A' AND k = 'B' : EQUB 216 EOR VE : ENDIF
 IF t = 'O' AND k = 'U' : EQUB 217 EOR VE : ENDIF
 IF t = 'S' AND k = 'E' : EQUB 218 EOR VE : ENDIF
 IF t = 'I' AND k = 'T' : EQUB 219 EOR VE : ENDIF
 IF t = 'I' AND k = 'L' : EQUB 220 EOR VE : ENDIF
 IF t = 'E' AND k = 'T' : EQUB 221 EOR VE : ENDIF
 IF t = 'S' AND k = 'T' : EQUB 222 EOR VE : ENDIF
 IF t = 'O' AND k = 'N' : EQUB 223 EOR VE : ENDIF
 IF t = 'L' AND k = 'O' : EQUB 224 EOR VE : ENDIF
 IF t = 'N' AND k = 'U' : EQUB 225 EOR VE : ENDIF
 IF t = 'T' AND k = 'H' : EQUB 226 EOR VE : ENDIF
 IF t = 'N' AND k = 'O' : EQUB 227 EOR VE : ENDIF

 IF t = 'A' AND k = 'L' : EQUB 228 EOR VE : ENDIF
 IF t = 'L' AND k = 'E' : EQUB 229 EOR VE : ENDIF
 IF t = 'X' AND k = 'E' : EQUB 230 EOR VE : ENDIF
 IF t = 'G' AND k = 'E' : EQUB 231 EOR VE : ENDIF
 IF t = 'Z' AND k = 'A' : EQUB 232 EOR VE : ENDIF
 IF t = 'C' AND k = 'E' : EQUB 233 EOR VE : ENDIF
 IF t = 'B' AND k = 'I' : EQUB 234 EOR VE : ENDIF
 IF t = 'S' AND k = 'O' : EQUB 235 EOR VE : ENDIF
 IF t = 'U' AND k = 'S' : EQUB 236 EOR VE : ENDIF
 IF t = 'E' AND k = 'S' : EQUB 237 EOR VE : ENDIF
 IF t = 'A' AND k = 'R' : EQUB 238 EOR VE : ENDIF
 IF t = 'M' AND k = 'A' : EQUB 239 EOR VE : ENDIF
 IF t = 'I' AND k = 'N' : EQUB 240 EOR VE : ENDIF
 IF t = 'D' AND k = 'I' : EQUB 241 EOR VE : ENDIF
 IF t = 'R' AND k = 'E' : EQUB 242 EOR VE : ENDIF
 IF t = 'A' AND k = '?' : EQUB 243 EOR VE : ENDIF
 IF t = 'E' AND k = 'R' : EQUB 244 EOR VE : ENDIF
 IF t = 'A' AND k = 'T' : EQUB 245 EOR VE : ENDIF
 IF t = 'E' AND k = 'N' : EQUB 246 EOR VE : ENDIF
 IF t = 'B' AND k = 'E' : EQUB 247 EOR VE : ENDIF
 IF t = 'R' AND k = 'A' : EQUB 248 EOR VE : ENDIF
 IF t = 'L' AND k = 'A' : EQUB 249 EOR VE : ENDIF
 IF t = 'V' AND k = 'E' : EQUB 250 EOR VE : ENDIF
 IF t = 'T' AND k = 'I' : EQUB 251 EOR VE : ENDIF
 IF t = 'E' AND k = 'D' : EQUB 252 EOR VE : ENDIF
 IF t = 'O' AND k = 'R' : EQUB 253 EOR VE : ENDIF
 IF t = 'Q' AND k = 'U' : EQUB 254 EOR VE : ENDIF
 IF t = 'A' AND k = 'N' : EQUB 255 EOR VE : ENDIF

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

 IF t = 'A' AND k = 'L' : EQUB 128 EOR RE : ENDIF
 IF t = 'L' AND k = 'E' : EQUB 129 EOR RE : ENDIF
 IF t = 'X' AND k = 'E' : EQUB 130 EOR RE : ENDIF
 IF t = 'G' AND k = 'E' : EQUB 131 EOR RE : ENDIF
 IF t = 'Z' AND k = 'A' : EQUB 132 EOR RE : ENDIF
 IF t = 'C' AND k = 'E' : EQUB 133 EOR RE : ENDIF
 IF t = 'B' AND k = 'I' : EQUB 134 EOR RE : ENDIF
 IF t = 'S' AND k = 'O' : EQUB 135 EOR RE : ENDIF
 IF t = 'U' AND k = 'S' : EQUB 136 EOR RE : ENDIF
 IF t = 'E' AND k = 'S' : EQUB 137 EOR RE : ENDIF
 IF t = 'A' AND k = 'R' : EQUB 138 EOR RE : ENDIF
 IF t = 'M' AND k = 'A' : EQUB 139 EOR RE : ENDIF
 IF t = 'I' AND k = 'N' : EQUB 140 EOR RE : ENDIF
 IF t = 'D' AND k = 'I' : EQUB 141 EOR RE : ENDIF
 IF t = 'R' AND k = 'E' : EQUB 142 EOR RE : ENDIF
 IF t = 'A' AND k = '?' : EQUB 143 EOR RE : ENDIF
 IF t = 'E' AND k = 'R' : EQUB 144 EOR RE : ENDIF
 IF t = 'A' AND k = 'T' : EQUB 145 EOR RE : ENDIF
 IF t = 'E' AND k = 'N' : EQUB 146 EOR RE : ENDIF
 IF t = 'B' AND k = 'E' : EQUB 147 EOR RE : ENDIF
 IF t = 'R' AND k = 'A' : EQUB 148 EOR RE : ENDIF
 IF t = 'L' AND k = 'A' : EQUB 149 EOR RE : ENDIF
 IF t = 'V' AND k = 'E' : EQUB 150 EOR RE : ENDIF
 IF t = 'T' AND k = 'I' : EQUB 151 EOR RE : ENDIF
 IF t = 'E' AND k = 'D' : EQUB 152 EOR RE : ENDIF
 IF t = 'O' AND k = 'R' : EQUB 153 EOR RE : ENDIF
 IF t = 'Q' AND k = 'U' : EQUB 154 EOR RE : ENDIF
 IF t = 'A' AND k = 'N' : EQUB 155 EOR RE : ENDIF
 IF t = 'T' AND k = 'E' : EQUB 156 EOR RE : ENDIF
 IF t = 'I' AND k = 'S' : EQUB 157 EOR RE : ENDIF
 IF t = 'R' AND k = 'I' : EQUB 158 EOR RE : ENDIF
 IF t = 'O' AND k = 'N' : EQUB 159 EOR RE : ENDIF

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
;    Summary: Add a specifed number to the cycle count
;
; ------------------------------------------------------------------------------
;
; The following macro is used to add cycles to the cycle count:
;
;   ADD_CYCLES_CLC cycles
;
; The cycle count is stored in the variable cycleCount.
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
;    Summary: Add a specifed number to the cycle count
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
;    Summary: Subtract a specifed number from the cycle count
;
; ------------------------------------------------------------------------------
;
; The following macro is used to subtract cycles from the cycle count:
;
;   SUBTRACT_CYCLES cycles
;
; The cycle count is stored in the variable cycleCount.
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
; memory block at addresss clearAddress(1 0). It also updates the index in Y to
; point to the byte after the block that is filled.
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
; Arguments:
;
;   byte_count          The number of bytes to send to the PPU
;
;   Y                   The index into dataForPPU(1 0) from which to start
;                       sending data
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

