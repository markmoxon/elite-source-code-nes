\ ******************************************************************************
\
\ Configuration variables
\
\ ******************************************************************************

 NOST = 20              \ The number of stardust particles in normal space (this
                        \ goes down to 3 in witchspace)

 NOSH = 8               \ The maximum number of ships in our local bubble of
                        \ universe

 NTY = 33               \ The number of different ship types

 MSL = 1                \ Ship type for a missile
 SST = 2                \ Ship type for a Coriolis space station
 ESC = 3                \ Ship type for an escape pod
 PLT = 4                \ Ship type for an alloy plate
 OIL = 5                \ Ship type for a cargo canister
 AST = 7                \ Ship type for an asteroid
 SPL = 8                \ Ship type for a splinter
 SHU = 9                \ Ship type for a Shuttle
 CYL = 11               \ Ship type for a Cobra Mk III
 ANA = 14               \ Ship type for an Anaconda
 HER = 15               \ Ship type for a rock hermit (asteroid)
 COPS = 16              \ Ship type for a Viper
 SH3 = 17               \ Ship type for a Sidewinder
 KRA = 19               \ Ship type for a Krait
 ADA = 20               \ Ship type for a Adder
 WRM = 23               \ Ship type for a Worm
 CYL2 = 24              \ Ship type for a Cobra Mk III (pirate)
 ASP = 25               \ Ship type for an Asp Mk II
 THG = 29               \ Ship type for a Thargoid
 TGL = 30               \ Ship type for a Thargon
 CON = 31               \ Ship type for a Constrictor
 COU = 32               \ Ship type for a Cougar
 DOD = 33               \ Ship type for a Dodecahedron ("Dodo") space station

 NI% = 42               \ The number of bytes in each ship's data block (as
                        \ stored in INWK and K%)

 Y = 72                 \ The centre y-coordinate of the space view

 VE = &57               \ The obfuscation byte used to hide the extended tokens
                        \ table from crackers viewing the binary code

 LL = 29                \ The length of lines (in characters) of justified text
                        \ in the extended tokens system

 PPU_CTRL   = &2000     \ NES PPU registers
 PPU_MASK   = &2001
 PPU_STATUS = &2002
 OAM_ADDR   = &2003
 OAM_DATA   = &2004
 PPU_SCROLL = &2005
 PPU_ADDR   = &2006
 PPU_DATA   = &2007
 OAM_DMA    = &4014

\ ******************************************************************************
\
\ Addresses in bank 7
\
\ ******************************************************************************

 S%                 = &C007
 SNE                = &C500
 ACT                = &C520
 XX21               = &C540
 SetPPUTablesTo0    = &D06D
 LD8C5              = &D8C5
 TWOS               = &D9F7
 yLookupLo          = &DA18
 yLookupHi          = &DAF8
 subm_DBD8          = &DBD8
 LOIN               = &DC0F
 LE04A              = &E04A
 LE0BA              = &E0BA
 PIXEL              = &E4F0
 subm_E909          = &E909
 LE5B0_EN           = &E5B0
 LE602_DE           = &E602
 LE653_FR           = &E653
 DELAY              = &EBA2
 SetupPPUForIconBar = &EC7D
 PAS1               = &EF7A
 DETOK_b2           = &F082
 DTS_b2             = &F09D
 C8980_b0           = &F186
 MVS5_b0            = &F1A2
 TT27_b0            = &F237
 TT66               = &F26E
 LF2BD              = &F2BD
 LF2CE              = &F2CE
 CLYNS              = &F2DE
 subm_F362          = &F362
 NLIN4              = &F473
 DORND2             = &F4AC
 DORND              = &F4AD
 PROJ               = &F4C1
 UnpackToRAM        = &F52D
 UnpackToPPU        = &F5AF
 MLS2               = &F6BA
 MLS1               = &F6C2
 MULTS              = &F6C6
 SQUA2              = &F70E
 MLU1               = &F718
 MLU2               = &F71D
 MULTU              = &F721
 FMLTU2             = &F766
 FMLTU              = &F770
 MUT2               = &F7D2
 MUT1               = &F7D6
 MULT1              = &F7DA
 MULT12             = &F83C
 MAD                = &F86F
 ADD                = &F872
 TIS1               = &F8AE
 DV42               = &F8D1
 DV41               = &F8D4
 DVID4              = &F8D8
 DVID3B2            = &F962
 LL5                = &FA55
 LL28               = &FA91
 NORM               = &FAF8

\ ******************************************************************************
\
\       Name: ZP
\       Type: Workspace
\    Address: &0000 to &00B0
\   Category: Workspaces
\    Summary: Lots of important variables are stored in the zero page workspace
\             as it is quicker and more space-efficient to access memory here
\
\ ******************************************************************************

 ORG &0000

.ZP

 SKIP 0                 \ The start of the zero page workspace

 SKIP 2                 \ These bytes appear to be unused

.RAND

 SKIP 4                 \ Four 8-bit seeds for the random number generation
                        \ system implemented in the DORND routine

.T1

 SKIP 1                 \ Temporary storage, used in a number of places

.SC

 SKIP 1                 \ Screen address (low byte)
                        \
                        \ Elite draws on-screen by poking bytes directly into
                        \ screen memory, and SC(1 0) is typically set to the
                        \ address of the character block containing the pixel

.SCH

 SKIP 1                 \ Screen address (high byte)

.XX1

 SKIP 0                 \ This is an alias for INWK that is used in the main
                        \ ship-drawing routine at LL9

.INWK

 SKIP 33                \ The zero-page internal workspace for the current ship
                        \ data block
                        \
                        \ As operations on zero page locations are faster and
                        \ have smaller opcodes than operations on the rest of
                        \ the addressable memory, Elite tends to store oft-used
                        \ data here. A lot of the routines in Elite need to
                        \ access and manipulate ship data, so to make this an
                        \ efficient exercise, the ship data is first copied from
                        \ the ship data blocks at K% into INWK (or, when new
                        \ ships are spawned, from the blueprints at XX21). See
                        \ the deep dive on "Ship data blocks" for details of
                        \ what each of the bytes in the INWK data block
                        \ represents

.L002A

 SKIP 1                 \ ???

.L002B

 SKIP 1                 \ ???

.L002C

 SKIP 1                 \ ???

.NEWB

 SKIP 1                 \ The ship's "new byte flags" (or NEWB flags)
                        \
                        \ Contains details about the ship's type and associated
                        \ behaviour, such as whether they are a trader, a bounty
                        \ hunter, a pirate, currently hostile, in the process of
                        \ docking, inside the hold having been scooped, and so
                        \ on. The default values for each ship type are taken
                        \ from the table at E%, and you can find out more detail
                        \ in the deep dive on "Advanced tactics with the NEWB
                        \ flags"

.L002E

 SKIP 1                 \ ???

.P

 SKIP 3                 \ Temporary storage, used in a number of places

.XC

 SKIP 1                 \ The x-coordinate of the text cursor (i.e. the text
                        \ column), which can be from 0 to 32
                        \
                        \ A value of 0 denotes the leftmost column and 32 the
                        \ rightmost column, but because the top part of the
                        \ screen (the space view) has a white border that
                        \ clashes with columns 0 and 32, text is only shown
                        \ in columns 1-31

.hiddenColour

 SKIP 1                 \ ???

.visibleColour

 SKIP 1                 \ ???

.paletteColour1

 SKIP 1                 \ ???

.paletteColour2

 SKIP 1                 \ ???

.L0037

 SKIP 1                 \ ???

.nmiTimer

 SKIP 1                 \ ???

.nmiTimerLo

 SKIP 1                 \ ???

.nmiTimerHi

 SKIP 1                 \ ???

.YC

 SKIP 1                 \ The y-coordinate of the text cursor (i.e. the text
                        \ row), which can be from 0 to 23
                        \
                        \ The screen actually has 31 character rows if you
                        \ include the dashboard, but the text printing routines
                        \ only work on the top part (the space view), so the
                        \ text cursor only goes up to a maximum of 23, the row
                        \ just before the screen splits
                        \
                        \ A value of 0 denotes the top row, but because the
                        \ top part of the screen has a white border that clashes
                        \ with row 0, text is always shown at row 1 or greater

.QQ17

 SKIP 1                 \ Contains a number of flags that affect how text tokens
                        \ are printed, particularly capitalisation:
                        \
                        \   * If all bits are set (255) then text printing is
                        \     disabled
                        \
                        \   * Bit 7: 0 = ALL CAPS
                        \            1 = Sentence Case, bit 6 determines the
                        \                case of the next letter to print
                        \
                        \   * Bit 6: 0 = print the next letter in upper case
                        \            1 = print the next letter in lower case
                        \
                        \   * Bits 0-5: If any of bits 0-5 are set, print in
                        \               lower case
                        \
                        \ So:
                        \
                        \   * QQ17 = 0 means case is set to ALL CAPS
                        \
                        \   * QQ17 = %10000000 means Sentence Case, currently
                        \            printing upper case
                        \
                        \   * QQ17 = %11000000 means Sentence Case, currently
                        \            printing lower case
                        \
                        \   * QQ17 = %11111111 means printing is disabled

.K3

 SKIP 0                 \ Temporary storage, used in a number of places

.XX2

 SKIP 14                \ Temporary storage, used to store the visibility of the
                        \ ship's faces during the ship-drawing routine at LL9

.K4

 SKIP 2                 \ Temporary storage, used in a number of places

.XX16

 SKIP 18                \ Temporary storage for a block of values, used in a
                        \ number of places

.XX0

 SKIP 2                 \ Temporary storage, used to store the address of a ship
                        \ blueprint. For example, it is used when we add a new
                        \ ship to the local bubble in routine NWSHP, and it
                        \ contains the address of the current ship's blueprint
                        \ as we loop through all the nearby ships in the main
                        \ flight loop

.XX19

 SKIP 0                 \ Instead of pointing XX19 to the ship heap address in
                        \ INWK(34 33), like the other versions of Elite, the NES
                        \ version points XX19 to the ship blueprint address in
                        \ INF(1 0)

.INF

 SKIP 2                 \ Temporary storage, typically used for storing the
                        \ address of a ship's data block, so it can be copied
                        \ to and from the internal workspace at INWK

.V

 SKIP 2                 \ Temporary storage, typically used for storing an
                        \ address pointer

.XX

 SKIP 2                 \ Temporary storage, typically used for storing a 16-bit
                        \ x-coordinate

.YY

 SKIP 2                 \ Temporary storage, typically used for storing a 16-bit
                        \ y-coordinate

.BETA

 SKIP 1                 \ The current pitch angle beta, which is reduced from
                        \ JSTY to a sign-magnitude value between -8 and +8
                        \
                        \ This describes how fast we are pitching our ship, and
                        \ determines how fast the universe pitches around us
                        \
                        \ The sign bit is also stored in BET2, while the
                        \ opposite sign is stored in BET2+1

.BET1

 SKIP 1                 \ The magnitude of the pitch angle beta, i.e. |beta|,
                        \ which is a positive value between 0 and 8

.QQ22

 SKIP 2                 \ The two hyperspace countdown counters
                        \
                        \ Before a hyperspace jump, both QQ22 and QQ22+1 are
                        \ set to 15
                        \
                        \ QQ22 is an internal counter that counts down by 1
                        \ each time TT102 is called, which happens every
                        \ iteration of the main game loop. When it reaches
                        \ zero, the on-screen counter in QQ22+1 gets
                        \ decremented, and QQ22 gets set to 5 and the countdown
                        \ continues (so the first tick of the hyperspace counter
                        \ takes 15 iterations to happen, but subsequent ticks
                        \ take 5 iterations each)
                        \
                        \ QQ22+1 contains the number that's shown on-screen
                        \ during the countdown. It counts down from 15 to 1, and
                        \ when it hits 0, the hyperspace engines kick in

.ECMA

 SKIP 1                 \ The E.C.M. countdown timer, which determines whether
                        \ an E.C.M. system is currently operating:
                        \
                        \   * 0 = E.C.M. is off
                        \
                        \   * Non-zero = E.C.M. is on and is counting down
                        \
                        \ The counter starts at 32 when an E.C.M. is activated,
                        \ either by us or by an opponent, and it decreases by 1
                        \ in each iteration of the main flight loop until it
                        \ reaches zero, at which point the E.C.M. switches off.
                        \ Only one E.C.M. can be active at any one time, so
                        \ there is only one counter

.ALP1

 SKIP 1                 \ Magnitude of the roll angle alpha, i.e. |alpha|,
                        \ which is a positive value between 0 and 31

.ALP2

 SKIP 2                 \ Bit 7 of ALP2 = sign of the roll angle in ALPHA
                        \
                        \ Bit 7 of ALP2+1 = opposite sign to ALP2 and ALPHA

.XX15

 SKIP 0                 \ Temporary storage, typically used for storing screen
                        \ coordinates in line-drawing routines
                        \
                        \ There are six bytes of storage, from XX15 TO XX15+5.
                        \ The first four bytes have the following aliases:
                        \
                        \   X1 = XX15
                        \   Y1 = XX15+1
                        \   X2 = XX15+2
                        \   Y2 = XX15+3
                        \
                        \ These are typically used for describing lines in terms
                        \ of screen coordinates, i.e. (X1, Y1) to (X2, Y2)
                        \
                        \ The last two bytes of XX15 do not have aliases

.X1

 SKIP 1                 \ Temporary storage, typically used for x-coordinates in
                        \ line-drawing routines

.Y1

 SKIP 1                 \ Temporary storage, typically used for y-coordinates in
                        \ line-drawing routines

.X2

 SKIP 1                 \ Temporary storage, typically used for x-coordinates in
                        \ line-drawing routines

.Y2

 SKIP 1                 \ Temporary storage, typically used for y-coordinates in
                        \ line-drawing routines

 SKIP 2                 \ The last two bytes of the XX15 block

.XX12

 SKIP 6                 \ Temporary storage for a block of values, used in a
                        \ number of places

.K

 SKIP 4                 \ Temporary storage, used in a number of places

.L0081

 SKIP 1                 \ ???

.QQ15

 SKIP 6                 \ The three 16-bit seeds for the selected system, i.e.
                        \ the one in the crosshairs in the Short-range Chart
                        \
                        \ See the deep dives on "Galaxy and system seeds" and
                        \ "Twisting the system seeds" for more details

.K5

 SKIP 0                 \ Temporary storage used to store segment coordinates
                        \ across successive calls to BLINE, the ball line
                        \ routine

.XX18

 SKIP 4                 \ Temporary storage used to store coordinates in the
                        \ LL9 ship-drawing routine

.K6

 SKIP 5                 \ Temporary storage, typically used for storing
                        \ coordinates during vector calculations

.BET2

 SKIP 2                 \ Bit 7 of BET2 = sign of the pitch angle in BETA
                        \
                        \ Bit 7 of BET2+1 = opposite sign to BET2 and BETA

.DELTA

 SKIP 1                 \ Our current speed, in the range 1-40

.DELT4

 SKIP 2                 \ Our current speed * 64 as a 16-bit value
                        \
                        \ This is stored as DELT4(1 0), so the high byte in
                        \ DELT4+1 therefore contains our current speed / 4

.U

 SKIP 1                 \ Temporary storage, used in a number of places

.Q

 SKIP 1                 \ Temporary storage, used in a number of places

.R

 SKIP 1                 \ Temporary storage, used in a number of places

.S

 SKIP 1                 \ Temporary storage, used in a number of places

.T

 SKIP 1                 \ Temporary storage, used in a number of places

.XSAV

 SKIP 1                 \ Temporary storage for saving the value of the X
                        \ register, used in a number of places

.YSAV

 SKIP 1                 \ Temporary storage for saving the value of the Y
                        \ register, used in a number of places

.XX17

 SKIP 1                 \ Temporary storage, used in BPRNT to store the number
                        \ of characters to print, and as the edge counter in the
                        \ main ship-drawing routine

.QQ11

 SKIP 1                 \ The number of the current view:
                        \
                        \   0   = Space view
                        \   1   = Title screen
                        \         Get commander name ("@", save/load commander)
                        \         In-system jump just arrived ("J")
                        \
                        \ This value is typically set by calling routine TT66

.QQ11a

 SKIP 1

.ZZ

 SKIP 1                 \ Temporary storage, typically used for distance values

.XX13

 SKIP 1                 \ Temporary storage, typically used in the line-drawing
                        \ routines

.MCNT

 SKIP 1                 \ The main loop counter
                        \
                        \ This counter determines how often certain actions are
                        \ performed within the main loop. See the deep dive on
                        \ "Scheduling tasks with the main loop counter" for more
                        \ details

.TYPE

 SKIP 1                 \ The current ship type
                        \
                        \ This is where we store the current ship type for when
                        \ we are iterating through the ships in the local bubble
                        \ as part of the main flight loop. See the table at XX21
                        \ for information about ship types

.ALPHA

 SKIP 1                 \ The current roll angle alpha, which is reduced from
                        \ JSTX to a sign-magnitude value between -31 and +31
                        \
                        \ This describes how fast we are rolling our ship, and
                        \ determines how fast the universe rolls around us
                        \
                        \ The sign bit is also stored in ALP2, while the
                        \ opposite sign is stored in ALP2+1

.QQ12

 SKIP 1                 \ Our "docked" status
                        \
                        \   * 0 = we are not docked
                        \
                        \   * &FF = we are docked

.TGT

 SKIP 1                 \ Temporary storage, typically used as a target value
                        \ for counters when drawing explosion clouds and partial
                        \ circles

.FLAG

 SKIP 1                 \ A flag that's used to define whether this is the first
                        \ call to the ball line routine in BLINE, so it knows
                        \ whether to wait for the second call before storing
                        \ segment data in the ball line heap

.CNT

 SKIP 1                 \ Temporary storage, typically used for storing the
                        \ number of iterations required when looping

.CNT2

 SKIP 1                 \ Temporary storage, used in the planet-drawing routine
                        \ to store the segment number where the arc of a partial
                        \ circle should start

.STP

 SKIP 1                 \ The step size for drawing circles
                        \
                        \ Circles in Elite are split up into 64 points, and the
                        \ step size determines how many points to skip with each
                        \ straight-line segment, so the smaller the step size,
                        \ the smoother the circle. The values used are:
                        \
                        \   * 2 for big planets and the circles on the charts
                        \   * 4 for medium planets and the launch tunnel
                        \   * 8 for small planets and the hyperspace tunnel
                        \
                        \ As the step size increases we move from smoother
                        \ circles at the top to more polygonal at the bottom.
                        \ See the CIRCLE2 routine for more details

.XX4

 SKIP 1                 \ Temporary storage, used in a number of places

.XX20

 SKIP 1                 \ Temporary storage, used in a number of places

.XX14

 SKIP 1                 \ This byte appears to be unused

.RAT

 SKIP 1                 \ Used to store different signs depending on the current
                        \ space view, for use in calculating stardust movement

.RAT2

 SKIP 1                 \ Temporary storage, used to store the pitch and roll
                        \ signs when moving objects and stardust

.widget

 SKIP 1                 \ Temporary storage, used to store the original argument
                        \ in A in the logarithmic FMLTU and LL28 routines

.Yx1M2

 SKIP 1                 \ ???

.Yx2M2

 SKIP 1                 \ ???

.Yx2M1

 SKIP 1                 \ This is used to store the number of pixel rows in the
                        \ space view, which is also the y-coordinate of the
                        \ bottom pixel row of the space view

.messXC

 SKIP 1                 \ Temporary storage, used to store the text column
                        \ of the in-flight message in MESS, so it can be erased
                        \ from the screen at the correct time

.L00B5

 SKIP 1                 \ ???

.newzp

 SKIP 1                 \ This is used by the STARS2 routine for storing the
                        \ stardust particle's delta_x value

.L00B7

 SKIP 1                 \ ???

.tileNumber

 SKIP 1                 \ ???

.pattBufferHi

 SKIP 1                 \ ???

.SC2

 SKIP 2                 \ ???

.L00BC

 SKIP 1                 \ ???

.L00BD

 SKIP 1                 \ ???

.L00BE

 SKIP 1                 \ ???

.L00BF

 SKIP 1                 \ ???

.drawingPhase

 SKIP 1                 \ ???

.tile0Phase0

 SKIP 1                 \ ???

.tile0Phase1

 SKIP 1                 \ ???

.tile1Phase0

 SKIP 1                 \ ???

.tile1Phase1

 SKIP 1                 \ ???

.tile2Phase0

 SKIP 1                 \ ???

.tile2Phase1

 SKIP 1                 \ ???

.tile3Phase0

 SKIP 1                 \ ???

.tile3Phase1

 SKIP 1                 \ ???

.L00C9

 SKIP 1                 \ ???

.L00CA

 SKIP 1                 \ ???

.L00CB

 SKIP 1                 \ ???

.L00CC

 SKIP 1                 \ ???

.L00CD

 SKIP 1                 \ ???

.L00CE

 SKIP 1                 \ ???

.L00CF

 SKIP 1                 \ ???

.tempVar

 SKIP 2                 \ ???

.L00D2

 SKIP 1                 \ ???

.L00D3

 SKIP 1                 \ ???

.addr1

 SKIP 2                 \ ???

.L00D6

 SKIP 1                 \ ???

.L00D7

 SKIP 1                 \ ???

.L00D8

 SKIP 1                 \ ???

.L00D9

 SKIP 1                 \ ???

.L00DA

 SKIP 1                 \ ???

.L00DB

 SKIP 2                \ ???

.L00DD

 SKIP 2                 \ ???

.L00DF

 SKIP 1                 \ ???

.L00E0

 SKIP 1                 \ ???

.patternBufferLo

 SKIP 1                 \ ???

.patternBufferHi

 SKIP 1                 \ ???

.ppuNametableLo

 SKIP 1                 \ ???

.ppuNametableHi

 SKIP 1                 \ ???

.drawingPhaseDebug

 SKIP 1                 \ ???

.nameBufferHi

 SKIP 1                 \ ???

.startupDebug

 SKIP 1                 \ ???

.temp1

 SKIP 1                 \ ???

.setupPPUForIconBar

 SKIP 1                 \ ???

.showUserInterface

 SKIP 1                 \ ???

.addr4

 SKIP 2                 \ ???

.addr5

 SKIP 2                 \ ???

.L00EF

 SKIP 1                 \ ???

.L00F0

 SKIP 1                 \ ???

.addr6

 SKIP 2                 \ ???

.palettePhase

 SKIP 1                 \ ???

.otherPhase

 SKIP 1                 \ ???

.ppuCtrlCopy

 SKIP 1                 \ ???

.L00F6

 SKIP 1                 \ ???

.currentBank

 SKIP 1                 \ ???

.runningSetBank

 SKIP 1                 \ ???

.L00F9

 SKIP 1                 \ ???

.addr2

 SKIP 2                 \ ???

.L00FC

 SKIP 1                 \ ???

.L00FD

 SKIP 1                 \ ???

.L00FE

 SKIP 1                 \ ???

.L00FF

 SKIP 1                 \ ???

 PRINT "Zero page variables from ", ~ZP, " to ", ~P%

\ ******************************************************************************
\
\       Name: XX3
\       Type: Workspace
\    Address: &0100 to the top of the descending stack
\   Category: Workspaces
\    Summary: Temporary storage space for complex calculations
\
\ ------------------------------------------------------------------------------
\
\ Used as heap space for storing temporary data during calculations. Shared with
\ the descending 6502 stack, which works down from &01FF.
\
\ ******************************************************************************

 ORG &0100

.XX3

 SKIP 0                 \ Temporary storage, typically used for storing tables
                        \ of values such as screen coordinates or ship data

\ ******************************************************************************
\
\       Name: Sprite buffer
\       Type: Workspace
\    Address: &0200 to &02FF
\   Category: Workspaces
\    Summary: Configuration data for sprites 0 to 63, which gets copied to the
\             PPU to update the screen
\
\ ******************************************************************************

ORG &0200

.ySprite0

 SKIP 1

.tileSprite0

 SKIP 1

.attrSprite0

 SKIP 1

.xSprite0

 SKIP 1

.ySprite1

 SKIP 1

.tileSprite1

 SKIP 1

.attrSprite1

 SKIP 1

.xSprite1

 SKIP 1

.ySprite2

 SKIP 1

.tileSprite2

 SKIP 1

.attrSprite2

 SKIP 1

.xSprite2

 SKIP 1

.ySprite3

 SKIP 1

.tileSprite3

 SKIP 1

.attrSprite3

 SKIP 1

.xSprite3

 SKIP 1

.ySprite4

 SKIP 1

.tileSprite4

 SKIP 1

.attrSprite4

 SKIP 1

.xSprite4

 SKIP 1

.ySprite5

 SKIP 1

.tileSprite5

 SKIP 1

.attrSprite5

 SKIP 1

.xSprite5

 SKIP 1

.ySprite6

 SKIP 1

.tileSprite6

 SKIP 1

.attrSprite6

 SKIP 1

.xSprite6

 SKIP 1

.ySprite7

 SKIP 1

.tileSprite7

 SKIP 1

.attrSprite7

 SKIP 1

.xSprite7

 SKIP 1

.ySprite8

 SKIP 1

.tileSprite8

 SKIP 1

.attrSprite8

 SKIP 1

.xSprite8

 SKIP 1

.ySprite9

 SKIP 1

.tileSprite9

 SKIP 1

.attrSprite9

 SKIP 1

.xSprite9

 SKIP 1

.ySprite10

 SKIP 1

.tileSprite10

 SKIP 1

.attrSprite10

 SKIP 1

.xSprite10

 SKIP 1

.ySprite11

 SKIP 1

.tileSprite11

 SKIP 1

.attrSprite11

 SKIP 1

.xSprite11

 SKIP 1

.ySprite12

 SKIP 1

.tileSprite12

 SKIP 1

.attrSprite12

 SKIP 1

.xSprite12

 SKIP 1

.ySprite13

 SKIP 1

.tileSprite13

 SKIP 1

.attrSprite13

 SKIP 1

.xSprite13

 SKIP 1

.ySprite14

 SKIP 1

.tileSprite14

 SKIP 1

.attrSprite14

 SKIP 1

.xSprite14

 SKIP 1

.ySprite15

 SKIP 1

.tileSprite15

 SKIP 1

.attrSprite15

 SKIP 1

.xSprite15

 SKIP 1

.ySprite16

 SKIP 1

.tileSprite16

 SKIP 1

.attrSprite16

 SKIP 1

.xSprite16

 SKIP 1

.ySprite17

 SKIP 1

.tileSprite17

 SKIP 1

.attrSprite17

 SKIP 1

.xSprite17

 SKIP 1

.ySprite18

 SKIP 1

.tileSprite18

 SKIP 1

.attrSprite18

 SKIP 1

.xSprite18

 SKIP 1

.ySprite19

 SKIP 1

.tileSprite19

 SKIP 1

.attrSprite19

 SKIP 1

.xSprite19

 SKIP 1

.ySprite20

 SKIP 1

.tileSprite20

 SKIP 1

.attrSprite20

 SKIP 1

.xSprite20

 SKIP 1

.ySprite21

 SKIP 1

.tileSprite21

 SKIP 1

.attrSprite21

 SKIP 1

.xSprite21

 SKIP 1

.ySprite22

 SKIP 1

.tileSprite22

 SKIP 1

.attrSprite22

 SKIP 1

.xSprite22

 SKIP 1

.ySprite23

 SKIP 1

.tileSprite23

 SKIP 1

.attrSprite23

 SKIP 1

.xSprite23

 SKIP 1

.ySprite24

 SKIP 1

.tileSprite24

 SKIP 1

.attrSprite24

 SKIP 1

.xSprite24

 SKIP 1

.ySprite25

 SKIP 1

.tileSprite25

 SKIP 1

.attrSprite25

 SKIP 1

.xSprite25

 SKIP 1

.ySprite26

 SKIP 1

.tileSprite26

 SKIP 1

.attrSprite26

 SKIP 1

.xSprite26

 SKIP 1

.ySprite27

 SKIP 1

.tileSprite27

 SKIP 1

.attrSprite27

 SKIP 1

.xSprite27

 SKIP 1

.ySprite28

 SKIP 1

.tileSprite28

 SKIP 1

.attrSprite28

 SKIP 1

.xSprite28

 SKIP 1

.ySprite29

 SKIP 1

.tileSprite29

 SKIP 1

.attrSprite29

 SKIP 1

.xSprite29

 SKIP 1

.ySprite30

 SKIP 1

.tileSprite30

 SKIP 1

.attrSprite30

 SKIP 1

.xSprite30

 SKIP 1

.ySprite31

 SKIP 1

.tileSprite31

 SKIP 1

.attrSprite31

 SKIP 1

.xSprite31

 SKIP 1

.ySprite32

 SKIP 1

.tileSprite32

 SKIP 1

.attrSprite32

 SKIP 1

.xSprite32

 SKIP 1

.ySprite33

 SKIP 1

.tileSprite33

 SKIP 1

.attrSprite33

 SKIP 1

.xSprite33

 SKIP 1

.ySprite34

 SKIP 1

.tileSprite34

 SKIP 1

.attrSprite34

 SKIP 1

.xSprite34

 SKIP 1

.ySprite35

 SKIP 1

.tileSprite35

 SKIP 1

.attrSprite35

 SKIP 1

.xSprite35

 SKIP 1

.ySprite36

 SKIP 1

.tileSprite36

 SKIP 1

.attrSprite36

 SKIP 1

.xSprite36

 SKIP 1

.ySprite37

 SKIP 1

.tileSprite37

 SKIP 1

.attrSprite37

 SKIP 1

.xSprite37

 SKIP 1

.ySprite38

 SKIP 1

.tileSprite38

 SKIP 1

.attrSprite38

 SKIP 1

.xSprite38

 SKIP 1

.ySprite39

 SKIP 1

.tileSprite39

 SKIP 1

.attrSprite39

 SKIP 1

.xSprite39

 SKIP 1

.ySprite40

 SKIP 1

.tileSprite40

 SKIP 1

.attrSprite40

 SKIP 1

.xSprite40

 SKIP 1

.ySprite41

 SKIP 1

.tileSprite41

 SKIP 1

.attrSprite41

 SKIP 1

.xSprite41

 SKIP 1

.ySprite42

 SKIP 1

.tileSprite42

 SKIP 1

.attrSprite42

 SKIP 1

.xSprite42

 SKIP 1

.ySprite43

 SKIP 1

.tileSprite43

 SKIP 1

.attrSprite43

 SKIP 1

.xSprite43

 SKIP 1

.ySprite44

 SKIP 1

.tileSprite44

 SKIP 1

.attrSprite44

 SKIP 1

.xSprite44

 SKIP 1

.ySprite45

 SKIP 1

.tileSprite45

 SKIP 1

.attrSprite45

 SKIP 1

.xSprite45

 SKIP 1

.ySprite46

 SKIP 1

.tileSprite46

 SKIP 1

.attrSprite46

 SKIP 1

.xSprite46

 SKIP 1

.ySprite47

 SKIP 1

.tileSprite47

 SKIP 1

.attrSprite47

 SKIP 1

.xSprite47

 SKIP 1

.ySprite48

 SKIP 1

.tileSprite48

 SKIP 1

.attrSprite48

 SKIP 1

.xSprite48

 SKIP 1

.ySprite49

 SKIP 1

.tileSprite49

 SKIP 1

.attrSprite49

 SKIP 1

.xSprite49

 SKIP 1

.ySprite50

 SKIP 1

.tileSprite50

 SKIP 1

.attrSprite50

 SKIP 1

.xSprite50

 SKIP 1

.ySprite51

 SKIP 1

.tileSprite51

 SKIP 1

.attrSprite51

 SKIP 1

.xSprite51

 SKIP 1

.ySprite52

 SKIP 1

.tileSprite52

 SKIP 1

.attrSprite52

 SKIP 1

.xSprite52

 SKIP 1

.ySprite53

 SKIP 1

.tileSprite53

 SKIP 1

.attrSprite53

 SKIP 1

.xSprite53

 SKIP 1

.ySprite54

 SKIP 1

.tileSprite54

 SKIP 1

.attrSprite54

 SKIP 1

.xSprite54

 SKIP 1

.ySprite55

 SKIP 1

.tileSprite55

 SKIP 1

.attrSprite55

 SKIP 1

.xSprite55

 SKIP 1

.ySprite56

 SKIP 1

.tileSprite56

 SKIP 1

.attrSprite56

 SKIP 1

.xSprite56

 SKIP 1

.ySprite57

 SKIP 1

.tileSprite57

 SKIP 1

.attrSprite57

 SKIP 1

.xSprite57

 SKIP 1

.ySprite58

 SKIP 1

.tileSprite58

 SKIP 1

.attrSprite58

 SKIP 1

.xSprite58

 SKIP 1

.ySprite59

 SKIP 1

.tileSprite59

 SKIP 1

.attrSprite59

 SKIP 1

.xSprite59

 SKIP 1

.ySprite60

 SKIP 1

.tileSprite60

 SKIP 1

.attrSprite60

 SKIP 1

.xSprite60

 SKIP 1

.ySprite61

 SKIP 1

.tileSprite61

 SKIP 1

.attrSprite61

 SKIP 1

.xSprite61

 SKIP 1

.ySprite62

 SKIP 1

.tileSprite62

 SKIP 1

.attrSprite62

 SKIP 1

.xSprite62

 SKIP 1

.ySprite63

 SKIP 1

.tileSprite63

 SKIP 1

.attrSprite63

 SKIP 1

.xSprite63

 SKIP 1

\ ******************************************************************************
\
\       Name: WP
\       Type: Workspace
\    Address: &0300 to &05FF
\   Category: Workspaces
\    Summary: Ship slots, variables
\
\ ******************************************************************************

 ORG &0300

.WP

 SKIP 0                 \ The start of the WP workspace

.L0300

 SKIP 106               \ ???

.FRIN

 SKIP NOSH + 1          \ Slots for the ships in the local bubble of universe
                        \
                        \ There are #NOSH + 1 slots, but the ship-spawning
                        \ routine at NWSHP only populates #NOSH of them, so
                        \ (the last slot is effectively used as a null
                        \ terminator when shuffling the slots down in the
                        \ KILLSHP routine)
                        \
                        \ See the deep dive on "The local bubble of universe"
                        \ for details of how Elite stores the local universe in
                        \ FRIN, UNIV and K%

.JUNK

 SKIP 1                 \ The amount of junk in the local bubble
                        \
                        \ "Junk" is defined as being one of these:
                        \
                        \   * Escape pod
                        \   * Alloy plate
                        \   * Cargo canister
                        \   * Asteroid
                        \   * Splinter
                        \   * Shuttle
                        \   * Transporter

.L0374

 SKIP 10                \ ???

.L037E

 SKIP 10                \ ???

.auto

 SKIP 1                 \ Docking computer activation status
                        \
                        \   * 0 = Docking computer is off
                        \
                        \   * Non-zero = Docking computer is running

.ECMP

 SKIP 1                 \ Our E.C.M. status
                        \
                        \   * 0 = E.C.M. is off
                        \
                        \   * Non-zero = E.C.M. is on

.MJ

 SKIP 1                 \ Are we in witchspace (i.e. have we mis-jumped)?
                        \
                        \   * 0 = no, we are in normal space
                        \
                        \   * &FF = yes, we are in witchspace

.CABTMP

 SKIP 1                 \ Cabin temperature
                        \
                        \ The ambient cabin temperature in deep space is 30,
                        \ which is displayed as one notch on the dashboard bar
                        \
                        \ We get higher temperatures closer to the sun
                        \
                        \ CABTMP shares a location with MANY, but that's OK as
                        \ MANY+0 would contain the number of ships of type 0,
                        \ and as there is no ship type 0 (they start at 1), the
                        \ byte at MANY+0 is not used for storing a ship type
                        \ and can be used for the cabin temperature instead

.LAS2

 SKIP 1                 \ Laser power for the current laser
                        \
                        \   * Bits 0-6 contain the laser power of the current
                        \     space view
                        \
                        \   * Bit 7 denotes whether or not the laser pulses:
                        \
                        \     * 0 = pulsing laser
                        \
                        \     * 1 = beam laser (i.e. always on)

.MSAR

 SKIP 1                 \ The targeting state of our leftmost missile
                        \
                        \   * 0 = missile is not looking for a target, or it
                        \     already has a target lock (indicator is not
                        \     yellow/white)
                        \
                        \   * Non-zero = missile is currently looking for a
                        \     target (indicator is yellow/white)

.VIEW

 SKIP 1                 \ The number of the current space view
                        \
                        \   * 0 = front
                        \   * 1 = rear
                        \   * 2 = left
                        \   * 3 = right

.LASCT

 SKIP 1                 \ The laser pulse count for the current laser
                        \
                        \ This is a counter that defines the gap between the
                        \ pulses of a pulse laser. It is set as follows:
                        \
                        \   * 0 for a beam laser
                        \
                        \   * 10 for a pulse laser
                        \
                        \
                        \ In comparison, beam lasers fire continuously as the
                        \ value of LASCT is always 0

.GNTMP

 SKIP 1                 \ Laser temperature (or "gun temperature")
                        \
                        \ If the laser temperature exceeds 242 then the laser
                        \ overheats and cannot be fired again until it has
                        \ cooled down

.HFX

 SKIP 1                 \ A flag that toggles the hyperspace colour effect
                        \
                        \   * 0 = no colour effect
                        \
                        \   * Non-zero = hyperspace colour effect enabled
                        \

.EV

 SKIP 1                 \ The "extra vessels" spawning counter
                        \
                        \ This counter is set to 0 on arrival in a system and
                        \ following an in-system jump, and is bumped up when we
                        \ spawn bounty hunters or pirates (i.e. "extra vessels")
                        \
                        \ It decreases by 1 each time we consider spawning more
                        \ "extra vessels" in part 4 of the main game loop, so
                        \ increasing the value of EV has the effect of delaying
                        \ the spawning of more vessels
                        \
                        \ In other words, this counter stops bounty hunters and
                        \ pirates from continually appearing, and ensures that
                        \ there's a delay between spawnings

.L0393

 SKIP 1                 \ ???

.L0394

 SKIP 1                 \ ???

.L0395

 SKIP 1                 \ ???

.NAME

 SKIP 8                 \ The current commander name
                        \
                        \ The commander name can be up to 7 characters (the DFS
                        \ limit for filenames), and is terminated by a carriage
                        \ return

.TP

 SKIP 1                 \ The current mission status
                        \
                        \   * Bits 0-1 = Mission 1 status
                        \
                        \     * %00 = Mission not started
                        \     * %01 = Mission in progress, hunting for ship
                        \     * %11 = Constrictor killed, not debriefed yet
                        \     * %10 = Mission and debrief complete
                        \
                        \   * Bits 2-3 = Mission 2 status
                        \
                        \     * %00 = Mission not started
                        \     * %01 = Mission in progress, plans not picked up
                        \     * %10 = Mission in progress, plans picked up
                        \     * %11 = Mission complete

.QQ0

 SKIP 1                 \ The current system's galactic x-coordinate (0-256)

.QQ1

 SKIP 1                 \ The current system's galactic y-coordinate (0-256)

.CASH

 SKIP 4                 \ Our current cash pot
                        \
                        \ The cash stash is stored as a 32-bit unsigned integer,
                        \ with the most significant byte in CASH and the least
                        \ significant in CASH+3. This is big-endian, which is
                        \ the opposite way round to most of the numbers used in
                        \ Elite - to use our notation for multi-byte numbers,
                        \ the amount of cash is CASH(0 1 2 3)

.QQ14

 SKIP 1                 \ Our current fuel level (0-70)
                        \
                        \ The fuel level is stored as the number of light years
                        \ multiplied by 10, so QQ14 = 1 represents 0.1 light
                        \ years, and the maximum possible value is 70, for 7.0
                        \ light years

.COK

 SKIP 1                 \ Flags used to generate the competition code
                        \
                        \ See the deep dive on "The competition code" for
                        \ details of these flags and how they are used in
                        \ generating and decoding the competition code

.GCNT

 SKIP 1                 \ The number of the current galaxy (0-7)
                        \
                        \ When this is displayed in-game, 1 is added to the
                        \ number, so we start in galaxy 1 in-game, but it's
                        \ stored as galaxy 0 internally
                        \
                        \ The galaxy number increases by one every time a
                        \ galactic hyperdrive is used, and wraps back round to
                        \ the start after eight galaxies

.LASER

 SKIP 4                 \ The specifications of the lasers fitted to each of the
                        \ four space views:
                        \
                        \
                        \ For each of the views:
                        \
                        \   * 0 = no laser is fitted to this view
                        \
                        \   * Non-zero = a laser is fitted to this view, with
                        \     the following specification:
                        \
                        \     * Bits 0-6 contain the laser's power
                        \
                        \     * Bit 7 determines whether or not the laser pulses

.CRGO

 SKIP 1                 \ Our ship's cargo capacity
                        \
                        \   * 22 = standard cargo bay of 20 tonnes
                        \
                        \   * 37 = large cargo bay of 35 tonnes
                        \
                        \ The value is two greater than the actual capacity to
                        \ make the maths in tnpr slightly more efficient

.QQ20

 SKIP 17                \ The contents of our cargo hold
                        \
                        \ The amount of market item X that we have in our hold
                        \ can be found in the X-th byte of QQ20. For example:
                        \
                        \   * QQ20 contains the amount of food (item 0)
                        \
                        \   * QQ20+7 contains the amount of computers (item 7)
                        \
                        \ See QQ23 for a list of market item numbers and their
                        \ storage units

.ECM

 SKIP 1                 \ E.C.M. system
                        \
                        \   * 0 = not fitted
                        \
                        \   * &FF = fitted

.BST

 SKIP 1                 \ Fuel scoops (BST stands for "barrel status")
                        \
                        \   * 0 = not fitted
                        \
                        \   * &FF = fitted

.BOMB

 SKIP 1                 \ Energy bomb
                        \
                        \   * 0 = not fitted
                        \
                        \   * &7F = fitted

.ENGY

 SKIP 1                 \ Energy unit
                        \
                        \   * 0 = not fitted
                        \
                        \   * Non-zero = fitted
                        \
                        \ The actual value determines the refresh rate of our
                        \ energy banks, as they refresh by ENGY+1 each time (so
                        \ our ship's energy level goes up by 2 each time if we
                        \ have an energy unit fitted, otherwise it goes up by 1)

.DKCMP

 SKIP 1                 \ Docking computer
                        \
                        \   * 0 = not fitted
                        \
                        \   * &FF = fitted

.GHYP

 SKIP 1                 \ Galactic hyperdrive
                        \
                        \   * 0 = not fitted
                        \
                        \   * &FF = fitted

.ESCP

 SKIP 1                 \ Escape pod
                        \
                        \   * 0 = not fitted
                        \
                        \   * &FF = fitted

.TRIBBLE

 SKIP 2                 \ The number of Trumbles in the cargo hold
                        \
                        \ The Master version doesn't actually have Trumbles, but
                        \ the Trumble code from the other versions was kept when
                        \ the Master version was put together

.TALLYL

 SKIP 1                 \ Combat rank fraction
                        \
                        \ Contains the fraction part of the kill count, which
                        \ together with the integer in TALLY(1 0) determines our
                        \ combat rank. The fraction is stored as the numerator
                        \ of a fraction with a denominator of 256, so a TALLYL
                        \ of 128 would represent 0.5 (i.e. 128 / 256)

.NOMSL

 SKIP 1                 \ The number of missiles we have fitted (0-4)

.FIST

 SKIP 1                 \ Our legal status (FIST stands for "fugitive/innocent
                        \ status"):
                        \
                        \   * 0 = Clean
                        \
                        \   * 1-49 = Offender
                        \
                        \   * 50+ = Fugitive
                        \
                        \ You get 64 points if you kill a cop, so that's a fast
                        \ ticket to fugitive status

.AVL

 SKIP 17                \ Market availability in the current system
                        \
                        \ The available amount of market item X is stored in
                        \ the X-th byte of AVL, so for example:
                        \
                        \   * AVL contains the amount of food (item 0)
                        \
                        \   * AVL+7 contains the amount of computers (item 7)
                        \
                        \ See QQ23 for a list of market item numbers and their
                        \ storage units, and the deep dive on "Market item
                        \ prices and availability" for details of the algorithm
                        \ used for calculating each item's availability

.QQ26

 SKIP 1                 \ A random value used to randomise market data
                        \
                        \ This value is set to a new random number for each
                        \ change of system, so we can add a random factor into
                        \ the calculations for market prices (for details of how
                        \ this is used, see the deep dive on "Market prices")

.TALLY

 SKIP 2                 \ Our combat rank
                        \
                        \ The combat rank is stored as the number of kills, in a
                        \ 16-bit number TALLY(1 0) - so the high byte is in
                        \ TALLY+1 and the low byte in TALLY
                        \
                        \ If the high byte in TALLY+1 is 0 then we have between
                        \ 0 and 255 kills, so our rank is Harmless, Mostly
                        \ Harmless, Poor, Average or Above Average, according to
                        \ the value of the low byte in TALLY:
                        \
                        \   Harmless        = %00000000 to %00000011 = 0 to 3
                        \   Mostly Harmless = %00000100 to %00000111 = 4 to 7
                        \   Poor            = %00001000 to %00001111 = 8 to 15
                        \   Average         = %00010000 to %00011111 = 16 to 31
                        \   Above Average   = %00100000 to %11111111 = 32 to 255
                        \
                        \ If the high byte in TALLY+1 is non-zero then we are
                        \ Competent, Dangerous, Deadly or Elite, according to
                        \ the high byte in TALLY+1:
                        \
                        \   Competent       = 1           = 256 to 511 kills
                        \   Dangerous       = 2 to 9      = 512 to 2559 kills
                        \   Deadly          = 10 to 24    = 2560 to 6399 kills
                        \   Elite           = 25 and up   = 6400 kills and up
                        \
                        \ You can see the rating calculation in STATUS

.L03DE

 SKIP 1                 \ ???

.QQ21

 SKIP 6                 \ The three 16-bit seeds for the current galaxy
                        \
                        \ These seeds define system 0 in the current galaxy, so
                        \ they can be used as a starting point to generate all
                        \ 256 systems in the galaxy
                        \
                        \ Using a galactic hyperdrive rotates each byte to the
                        \ left (rolling each byte within itself) to get the
                        \ seeds for the next galaxy, so after eight galactic
                        \ jumps, the seeds roll around to the first galaxy again
                        \
                        \ See the deep dives on "Galaxy and system seeds" and
                        \ "Twisting the system seeds" for more details
.NOSTM

 SKIP 1                 \ The number of stardust particles shown on screen,
                        \ which is 18 (#NOST) for normal space, and 3 for
                        \ witchspace

.L03E6

 SKIP 1                 \ ???

.L03E7

 SKIP 1                 \ ???

.L03E8

 SKIP 1                 \ ???

.L03E9

 SKIP 1                 \ ???

.L03EA

 SKIP 1                 \ ???

.L03EB

 SKIP 1                 \ ???

.L03EC

 SKIP 1                 \ ???

.L03ED

 SKIP 1                 \ ???

.L03EE

 SKIP 1                 \ ???

.L03EF

 SKIP 1                 \ ???

.L03F0

 SKIP 1                 \ ???

.frameCounter

 SKIP 1                 \ ???

.L03F2

 SKIP 1                 \ ???

\ ******************************************************************************
\
\       Name: DTW6
\       Type: Variable
\   Category: Text
\    Summary: A flag to denote whether printing in lower case is enabled for
\             extended text tokens
\  Deep dive: Extended text tokens
\
\ ------------------------------------------------------------------------------
\
\ This variable is used to indicate whether lower case is currently enabled. It
\ has two values:
\
\   * %10000000 = lower case is enabled
\
\   * %00000000 = lower case is not enabled
\
\ The default value is %00000000 (lower case is not enabled).
\
\ The flag is set to %10000000 (lower case is enabled) by jump token 13 {lower
\ case}, which calls routine MT10 to change the value of DTW6.
\
\ The flag is set to %00000000 (lower case is not enabled) by jump token 1, {all
\ caps}, and jump token 1, {sentence case}, which call routines MT1 and MT2 to
\ change the value of DTW6.
\
\ ******************************************************************************

.DTW6

 EQUB %00000000

\ ******************************************************************************
\
\       Name: DTW2
\       Type: Variable
\   Category: Text
\    Summary: A flag that indicates whether we are currently printing a word
\  Deep dive: Extended text tokens
\
\ ------------------------------------------------------------------------------
\
\ This variable is used to indicate whether we are currently printing a word. It
\ has two values:
\
\   * 0 = we are currently printing a word
\
\   * Non-zero = we are not currently printing a word
\
\ The default value is %11111111 (we are not currently printing a word).
\
\ The flag is set to %00000000 (we are currently printing a word) whenever a
\ non-terminator character is passed to DASC for printing.
\
\ The flag is set to %11111111 (we are not currently printing a word) whenever a
\ terminator character (full stop, colon, carriage return, line feed, space) is
\ passed to DASC for printing. It is also set to %11111111 by jump token 8,
\ {tab 6}, which calls routine MT8 to change the value of DTW2, and to %10000000
\ by TTX66 when we clear the screen.
\
\ ******************************************************************************

.DTW2

 EQUB %11111111

\ ******************************************************************************
\
\       Name: DTW3
\       Type: Variable
\   Category: Text
\    Summary: A flag for switching between standard and extended text tokens
\  Deep dive: Extended text tokens
\
\ ------------------------------------------------------------------------------
\
\ This variable is used to indicate whether standard or extended text tokens
\ should be printed by calls to DETOK. It allows us to mix standard tokens in
\ with extended tokens. It has two values:
\
\   * %00000000 = print extended tokens (i.e. those in TKN1 and RUTOK)
\
\   * %11111111 = print standard tokens (i.e. those in QQ18)
\
\ The default value is %00000000 (extended tokens).
\
\ Standard tokens are set by jump token {6}, which calls routine MT6 to change
\ the value of DTW3 to %11111111.
\
\ Extended tokens are set by jump token {5}, which calls routine MT5 to change
\ the value of DTW3 to %00000000.
\
\ ******************************************************************************

.DTW3

 EQUB %00000000

\ ******************************************************************************
\
\       Name: DTW4
\       Type: Variable
\   Category: Text
\    Summary: Flags that govern how justified extended text tokens are printed
\  Deep dive: Extended text tokens
\
\ ------------------------------------------------------------------------------
\
\ This variable is used to control how justified text tokens are printed as part
\ of the extended text token system. There are two bits that affect justified
\ text:
\
\   * Bit 7: 1 = justify text
\            0 = do not justify text
\
\   * Bit 6: 1 = buffer the entire token before printing, including carriage
\                returns (used for in-flight messages only)
\            0 = print the contents of the buffer whenever a carriage return
\                appears in the token
\
\ The default value is %00000000 (do not justify text, print buffer on carriage
\ return).
\
\ The flag is set to %10000000 (justify text, print buffer on carriage return)
\ by jump token 14, {justify}, which calls routine MT14 to change the value of
\ DTW4.
\
\ The flag is set to %11000000 (justify text, buffer entire token) by routine
\ MESS, which printe in-flight messages.
\
\ The flag is set to %00000000 (do not justify text, print buffer on carriage
\ return) by jump token 15, {left align}, which calls routine MT1 to change the
\ value of DTW4.
\
\ ******************************************************************************

.DTW4

 EQUB 0

\ ******************************************************************************
\
\       Name: DTW5
\       Type: Variable
\   Category: Text
\    Summary: The size of the justified text buffer at BUF
\  Deep dive: Extended text tokens
\
\ ------------------------------------------------------------------------------
\
\ When justified text is enabled by jump token 14, {justify}, during printing of
\ extended text tokens, text is fed into a buffer at BUF instead of being
\ printed straight away, so it can be padded out with spaces to justify the
\ text. DTW5 contains the size of the buffer, so BUF + DTW5 points to the first
\ free byte after the end of the buffer.
\
\ ******************************************************************************

.DTW5

 EQUB 0

\ ******************************************************************************
\
\       Name: DTW1
\       Type: Variable
\   Category: Text
\    Summary: A mask for applying the lower case part of Sentence Case to
\             extended text tokens
\  Deep dive: Extended text tokens
\
\ ------------------------------------------------------------------------------
\
\ This variable is used to change characters to lower case as part of applying
\ Sentence Case to extended text tokens. It has two values:
\
\   * %00100000 = apply lower case to the second letter of a word onwards
\
\   * %00000000 = do not change case to lower case
\
\ The default value is %00100000 (apply lower case).
\
\ The flag is set to %00100000 (apply lower case) by jump token 2, {sentence
\ case}, which calls routine MT2 to change the value of DTW1.
\
\ The flag is set to %00000000 (do not change case to lower case) by jump token
\ 1, {all caps}, which calls routine MT1 to change the value of DTW1.
\
\ The letter to print is OR'd with DTW1 in DETOK2, which lower-cases the letter
\ by setting bit 5 (if DTW1 is %00100000). However, this OR is only done if bit
\ 7 of DTW2 is clear, i.e. we are printing a word, so this doesn't affect the
\ first letter of the word, which remains capitalised.
\
\ ******************************************************************************

.DTW1

 EQUB %00100000

\ ******************************************************************************
\
\       Name: DTW8
\       Type: Variable
\   Category: Text
\    Summary: A mask for capitalising the next letter in an extended text token
\  Deep dive: Extended text tokens
\
\ ------------------------------------------------------------------------------
\
\ This variable is only used by one specific extended token, the {single cap}
\ jump token, which capitalises the next letter only. It has two values:
\
\   * %11011111 = capitalise the next letter
\
\   * %11111111 = do not change case
\
\ The default value is %11111111 (do not change case).
\
\ The flag is set to %11011111 (capitalise the next letter) by jump token 19,
\ {single cap}, which calls routine MT19 to change the value of DTW.
\
\ The flag is set to %11111111 (do not change case) at the start of DASC, after
\ the letter has been capitalised in DETOK2, so the effect is to capitalise one
\ letter only.
\
\ The letter to print is AND'd with DTW8 in DETOK2, which capitalises the letter
\ by clearing bit 5 (if DTW8 is %11011111). However, this AND is only done if at
\ least one of the following is true:
\
\   * Bit 7 of DTW2 is set (we are not currently printing a word)
\
\   * Bit 7 of DTW6 is set (lower case has been enabled by jump token 13, {lower
\     case}
\
\ In other words, we only capitalise the next letter if it's the first letter in
\ a word, or we are printing in lower case.
\
\ ******************************************************************************

.DTW8

 EQUB %11111111

.XP

 SKIP 1                 \ The x-coordinate of the current character as we
                        \ construct the lines for the Star Wars scroll text

.YP

 SKIP 1                 \ The y-coordinate of the current character as we
                        \ construct the lines for the Star Wars scroll text

.L03FC

 SKIP 1                 \ ???

.L03FD

 SKIP 1                 \ ???

.L03FE

 SKIP 1                 \ ???

.L03FF

 SKIP 1                 \ ???

.LAS

 SKIP 1                 \ Contains the laser power of the laser fitted to the
                        \ current space view (or 0 if there is no laser fitted
                        \ to the current view)
                        \
                        \ This gets set to bits 0-6 of the laser power byte from
                        \ the commander data block, which contains the laser's
                        \ power (bit 7 doesn't denote laser power, just whether
                        \ or not the laser pulses, so that is not stored here)

.MSTG

 SKIP 1                 \ The current missile lock target
                        \
                        \   * &FF = no target
                        \
                        \            missile is locked onto

.L0402

 SKIP 1

.KL

 SKIP 0                 \ The following bytes implement a key logger that
                        \ enables Elite to scan for concurrent key presses on
                        \ both controllers

.KY1

 SKIP 1                 \ "?" is being pressed
                        \
                        \   * 0 = no
                        \
                        \   * Non-zero = yes

.KY2

 SKIP 1                 \ Space is being pressed
                        \
                        \   * 0 = no
                        \
                        \   * Non-zero = yes

.KY3

 SKIP 1                 \ "<" is being pressed
                        \
                        \   * 0 = no
                        \
                        \   * Non-zero = yes

.KY4

 SKIP 1                 \ ">" is being pressed
                        \
                        \   * 0 = no
                        \
                        \   * Non-zero = yes

.KY5

 SKIP 1                 \ "X" is being pressed
                        \
                        \   * 0 = no
                        \
                        \   * Non-zero = yes

.KY6

 SKIP 1                 \ "S" is being pressed
                        \
                        \   * 0 = no
                        \
                        \   * Non-zero = yes

.KY7

 SKIP 1                 \ "A" is being pressed
                        \
                        \   * 0 = no
                        \
                        \   * Non-zero = yes

.L040A

 SKIP 1                 \ ???

.L040B

 SKIP 66                \ ???

.QQ19

 SKIP 6                 \ Temporary storage, used in a number of places

.L0453

 SKIP 6                 \ ???

.K2

 SKIP 4                 \ Temporary storage, used in a number of places

.DLY

 SKIP 1                 \ In-flight message delay
                        \
                        \ This counter is used to keep an in-flight message up
                        \ for a specified time before it gets removed. The value
                        \ in DLY is decremented each time we start another
                        \ iteration of the main game loop at TT100

.L045E

 SKIP 1                 \ ???

.L045F

 SKIP 1                 \ ???

.L0460

 SKIP 1                 \ ???

.L0461

 SKIP 1                 \ ???

.L0462

 SKIP 1                 \ ???

.L0463

 SKIP 1                 \ ???

.L0464

 SKIP 1                 \ ???

.L0465

 SKIP 1                 \ ???

.L0466

 SKIP 1                 \ ???

.L0467

 SKIP 1                 \ ???

.L0468

 SKIP 1                 \ ???

.nmiStoreA

 SKIP 1                 \ ???

.nmiStoreX

 SKIP 1                 \ ???

.nmiStoreY

 SKIP 1                 \ ???

.pictureTile

 SKIP 1                 \ ???

.L046D

 SKIP 1                 \ ???

.boxEdge1

 SKIP 1                 \ ???

.boxEdge2

 SKIP 1                 \ ???

.L0470

 SKIP 1                 \ ???

.L0471

 SKIP 1                 \ ???

.L0472

 SKIP 1                 \ ???

.L0473

 SKIP 1                 \ ???

.L0474

 SKIP 1                 \ ???

.scanController2

 SKIP 1                 \ ???

.JSTX

 SKIP 1                 \ Our current roll rate
                        \
                        \ This value is shown in the dashboard's RL indicator,
                        \ and determines the rate at which we are rolling
                        \
                        \ The value ranges from from 1 to 255 with 128 as the
                        \ centre point, so 1 means roll is decreasing at the
                        \ maximum rate, 128 means roll is not changing, and
                        \ 255 means roll is increasing at the maximum rate
                        \

.JSTY

 SKIP 1                 \ Our current pitch rate
                        \
                        \ This value is shown in the dashboard's DC indicator,
                        \ and determines the rate at which we are pitching
                        \
                        \ The value ranges from from 1 to 255 with 128 as the
                        \ centre point, so 1 means pitch is decreasing at the
                        \ maximum rate, 128 means pitch is not changing, and
                        \ 255 means pitch is increasing at the maximum rate
                        \

.L0478

 SKIP 3                 \ ???

.LASX

 SKIP 1                 \ The x-coordinate of the tip of the laser line

.LASY

 SKIP 1                 \ The y-coordinate of the tip of the laser line

.L047D

 SKIP 1                 \ ???

.ALTIT

 SKIP 1                 \ Our altitude above the surface of the planet or sun
                        \
                        \   * 255 = we are a long way above the surface
                        \
                        \   * 1-254 = our altitude as the square root of:
                        \
                        \       x_hi^2 + y_hi^2 + z_hi^2 - 6^2
                        \
                        \     where our ship is at the origin, the centre of the
                        \     planet/sun is at (x_hi, y_hi, z_hi), and the
                        \     radius of the planet/sun is 6
                        \
                        \   * 0 = we have crashed into the surface

.SWAP

 SKIP 1                 \ Temporary storage, used to store a flag that records
                        \ whether or not we had to swap a line's start and end
                        \ coordinates around when clipping the line in routine
                        \ LL145 (the flag is used in places like BLINE to swap
                        \ them back)

.L4080

 SKIP 1                 \ ???

.XSAV2

 SKIP 1                 \ Temporary storage, used for storing the value of the X
                        \ register in the TT26 routine

.YSAV2

 SKIP 1                 \ Temporary storage, used for storing the value of the Y
                        \ register in the TT26 routine

.L4083

 SKIP 1                 \ ???

.FSH

 SKIP 1                 \ Forward shield status
                        \
                        \   * 0 = empty
                        \
                        \   * &FF = full

.ASH

 SKIP 1                 \ Aft shield status
                        \
                        \   * 0 = empty
                        \
                        \   * &FF = full

.ENERGY

 SKIP 1                 \ Energy bank status
                        \
                        \   * 0 = empty
                        \
                        \   * &FF = full

.QQ24

 SKIP 1                 \ Temporary storage, used to store the current market
                        \ item's price in routine TT151

.QQ25

 SKIP 1                 \ Temporary storage, used to store the current market
                        \ item's availability in routine TT151

.QQ28

 SKIP 1                 \ The current system's economy (0-7)
                        \
                        \   * 0 = Rich Industrial
                        \   * 1 = Average Industrial
                        \   * 2 = Poor Industrial
                        \   * 3 = Mainly Industrial
                        \   * 4 = Mainly Agricultural
                        \   * 5 = Rich Agricultural
                        \   * 6 = Average Agricultural
                        \   * 7 = Poor Agricultural
                        \
                        \ See the deep dive on "Generating system data" for more
                        \ information on economies

.QQ29

 SKIP 1                 \ Temporary storage, used in a number of places

.systemFlag

 SKIP 1                 \ ???

.gov

 SKIP 1                 \ The current system's government type (0-7)
                        \
                        \ See the deep dive on "Generating system data" for
                        \ details of the various government types

.tek

 SKIP 1                 \ The current system's tech level (0-14)
                        \
                        \ See the deep dive on "Generating system data" for more
                        \ information on tech levels

.QQ2

 SKIP 6                 \ The three 16-bit seeds for the current system, i.e.
                        \ the one we are currently in
                        \
                        \ See the deep dives on "Galaxy and system seeds" and
                        \ "Twisting the system seeds" for more details

.QQ3

 SKIP 1                 \ The selected system's economy (0-7)
                        \
                        \   * 0 = Rich Industrial
                        \   * 1 = Average Industrial
                        \   * 2 = Poor Industrial
                        \   * 3 = Mainly Industrial
                        \   * 4 = Mainly Agricultural
                        \   * 5 = Rich Agricultural
                        \   * 6 = Average Agricultural
                        \   * 7 = Poor Agricultural
                        \
                        \ See the deep dive on "Generating system data" for more
                        \ information on economies

.QQ4

 SKIP 1                 \ The selected system's government (0-7)
                        \
                        \ See the deep dive on "Generating system data" for more
                        \ details of the various government types

.QQ5

 SKIP 1                 \ The selected system's tech level (0-14)
                        \
                        \ See the deep dive on "Generating system data" for more
                        \ information on tech levels

.QQ6

 SKIP 2                 \ The selected system's population in billions * 10
                        \ (1-71), so the maximum population is 7.1 billion
                        \
                        \ See the deep dive on "Generating system data" for more
                        \ details on population levels

.QQ7

 SKIP 2                 \ The selected system's productivity in M CR (96-62480)
                        \
                        \ See the deep dive on "Generating system data" for more
                        \ details about productivity levels

.QQ8

 SKIP 2                 \ The distance from the current system to the selected
                        \ system in light years * 10, stored as a 16-bit number
                        \
                        \ The distance will be 0 if the selected sysyem is the
                        \ current system
                        \
                        \ The galaxy chart is 102.4 light years wide and 51.2
                        \ light years tall (see the intra-system distance
                        \ calculations in routine TT111 for details), which
                        \ equates to 1024 x 512 in terms of QQ8

.QQ9

 SKIP 1                 \ The galactic x-coordinate of the crosshairs in the
                        \ galaxy chart (and, most of the time, the selected
                        \ system's galactic x-coordinate)

.QQ10

 SKIP 1                 \ The galactic y-coordinate of the crosshairs in the
                        \ galaxy chart (and, most of the time, the selected
                        \ system's galactic y-coordinate)

.L049F

 SKIP 2                 \ ???

.L04A1

 SKIP 1                 \ ???

.L04A2

 SKIP 1                 \ ???

.L04A3

 SKIP 1                 \ ???

.QQ18Lo

 SKIP 1                 \ ???

.QQ18Hi

 SKIP 1                 \ ???

.TKN1Lo

 SKIP 1                 \ ???

.TKN1Hi

 SKIP 1                 \ ???

.language

 SKIP 1                 \ ???

.L04A9

 SKIP 1                 \ ???

.controller1Down

 SKIP 1                 \ ???

.controller2Down

 SKIP 1                 \ ???

.controller1Up

 SKIP 1                 \ ???

.controller2Up

 SKIP 1                 \ ???

.controller1Left

 SKIP 1                 \ ???

.controller2Left

 SKIP 1                 \ ???

.controller1Right

 SKIP 1                 \ ???

.controller2Right

 SKIP 1                 \ ???

.controller1A

 SKIP 1                 \ ???

.controller2A

 SKIP 1                 \ ???

.controller1B

 SKIP 1                 \ ???

.controller2B

 SKIP 1                 \ ???

.controller1Start

 SKIP 1                 \ ???

.controller2Start

 SKIP 1                 \ ???

.controller1Select

 SKIP 1                 \ ???

.controller2Select

 SKIP 1                 \ ???

.L04BA

 SKIP 1                 \ ???

.L04BB

 SKIP 1                 \ ???

.L04BC

 SKIP 1                 \ ???

.L04BD

 SKIP 1                 \ ???

.L04BE

 SKIP 2                 \ ???

.L04C0

 SKIP 2                 \ ???

 SKIP 6                 \ ???

.SX

 SKIP NOST + 1          \ This is where we store the x_hi coordinates for all
                        \ the stardust particles

.SY

 SKIP NOST + 1          \ This is where we store the y_hi coordinates for all
                        \ the stardust particles

.SZ

 SKIP NOST + 1          \ This is where we store the z_hi coordinates for all
                        \ the stardust particles

.BUF

 SKIP 90                \ The line buffer used by DASC to print justified text

\ ******************************************************************************
\
\       Name: HANGFLAG
\       Type: Variable
\   Category: Ship hangar
\    Summary: The number of ships being displayed in the ship hangar
\
\ ******************************************************************************

.HANGFLAG

 EQUB 0

.MANY

 SKIP SST               \ The number of ships of each type in the local bubble
                        \ of universe
                        \
                        \ The number of ships of type X in the local bubble is
                        \ stored at MANY+X, so the number of Sidewinders is at
                        \ MANY+1, the number of Mambas is at MANY+2, and so on
                        \
                        \ See the deep dive on "Ship blueprints" for a list of
                        \ ship types

.SSPR

 SKIP NTY + 1 - SST     \ "Space station present" flag
                        \
                        \   * Non-zero if we are inside the space station's safe
                        \     zone
                        \
                        \   * 0 if we aren't (in which case we can show the sun)
                        \
                        \ This flag is at MANY+SST, which is no coincidence, as
                        \ MANY+SST is a count of how many space stations there
                        \ are in our local bubble, which is the same as saying
                        \ "space station present"

.L0584

 SKIP 1                 \ ???

.L0585

 SKIP 32                \ ???

.SXL

 SKIP NOST + 1          \ This is where we store the x_lo coordinates for all
                        \ the stardust particles

.SYL

 SKIP NOST + 1          \ This is where we store the y_lo coordinates for all
                        \ the stardust particles

.SZL

 SKIP NOST + 1          \ This is where we store the z_lo coordinates for all
                        \ the stardust particles

.safehouse

 SKIP 6                 \ Backup storage for the seeds for the selected system
                        \
                        \ The seeds for the current system get stored here as
                        \ soon as a hyperspace is initiated, so we can fetch
                        \ them in the hyp1 routine. This fixes a bug in an
                        \ earlier version where you could hyperspace while
                        \ docking and magically appear in your destination
                        \ station

.L05EA

 SKIP 1                 \ ???

.L05EB

 SKIP 1                 \ ???

.L05EC

 SKIP 1                 \ ???

.L05ED

 SKIP 1                 \ ???

.L05EE

 SKIP 1                 \ ???

.L05EF

 SKIP 1                 \ ???

.L05F0

 SKIP 1                 \ ???

.L05F1

 SKIP 1                 \ ???

.L05F2

 SKIP 1                 \ ???

 PRINT "WP workspace from  ", ~WP," to ", ~P%

\ ******************************************************************************
\
\       Name: K%
\       Type: Workspace
\    Address: &0600 to &07FF
\   Category: Workspaces
\    Summary: Ship data blocks
\  Deep dive: Ship data blocks
\             The local bubble of universe
\
\ ------------------------------------------------------------------------------
\
\ Contains ship data for all the ships, planets, suns and space stations in our
\ local bubble of universe.
\
\ See the deep dive on "Ship data blocks" for details on ship data blocks, and
\ the deep dive on "The local bubble of universe" for details of how Elite
\ stores the local universe in K%, FRIN and UNIV.
\
\ ******************************************************************************

 ORG &0600

.K%

 SKIP 0                 \ Ship data blocks and ship line heap

\ ******************************************************************************
\
\       Name: pattBuffer0
\       Type: Variable
\   Category: Drawing lines
\    Summary: Pattern buffer for colour 0 (1 bit per pixel)
\
\ ******************************************************************************

 ORG &6000

.pattBuffer0

 SKIP 8 * 256           \ 256 patterns, 8 bytes per pattern (8x8 pixels)

\ ******************************************************************************
\
\       Name: pattBuffer1
\       Type: Variable
\   Category: Drawing lines
\    Summary: Pattern buffer for colour 1 (1 bit per pixel)
\
\ ******************************************************************************

.pattBuffer1

 SKIP 8 * 256           \ 256 patterns, 8 bytes per pattern (8x8 pixels)

