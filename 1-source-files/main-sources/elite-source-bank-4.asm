\ ******************************************************************************
\
\ NES ELITE GAME SOURCE (BANK 4)
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
\   * bank4.bin
\
\ ******************************************************************************

 INCLUDE "1-source-files/main-sources/elite-build-options.asm"

 _NTSC                  = (_VARIANT = 1)
 _PAL                   = (_VARIANT = 2)

\ ******************************************************************************
\
\ Configuration variables
\
\ ******************************************************************************

 S% = &C007             \ The game's main entry point in bank 7

 PPU_CTRL   = &2000     \ NES PPU registers
 PPU_MASK   = &2001
 PPU_STATUS = &2002
 OAM_ADDR   = &2003
 OAM_DATA   = &2004
 PPU_SCROLL = &2005
 PPU_ADDR   = &2006
 PPU_DATA   = &2007
 OAM_DMA    = &4014

subm_DBD8         = &DBD8
UnpackToRAM       = &F52D
UnpackToPPU       = &F5AF
SwitchTablesTo0   = &D06D
pattBuffer0       = &6000
pattBuffer1       = &6800

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

.L0033

 SKIP 1                 \ ???

.L0034

 SKIP 1                 \ ???

.L0035

 SKIP 1                 \ ???

.L0036

 SKIP 1                 \ ???

.L0037

 SKIP 1                 \ ???

.L0038

 SKIP 1                 \ ???

.L0039

 SKIP 1                 \ ???

.L003A

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

.W

 SKIP 1                 \ Temporary storage, used in a number of places

.QQ11

 SKIP 1                 \ The number of the current view:
                        \
                        \   0   = Space view
                        \   1   = Title screen
                        \         Get commander name ("@", save/load commander)
                        \         In-system jump just arrived ("J")
                        \
                        \ This value is typically set by calling routine TT66

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

.patternTableHi

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

.L00C0

 SKIP 1                 \ ???

.L00C1

 SKIP 1                 \ ???

.L00C2

 SKIP 1                 \ ???

.L00C3

 SKIP 1                 \ ???

.L00C4

 SKIP 1                 \ ???

.L00C5

 SKIP 1                 \ ???

.L00C6

 SKIP 1                 \ ???

.L00C7

 SKIP 1                 \ ???

.L00C8

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

.L00D0

 SKIP 1                 \ ???

.L00D1

 SKIP 1                 \ ???

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

 SKIP 11                \ ???

.nametableHi

 SKIP 1                 \ ???

.L00E7

 SKIP 1                 \ ???

.L00E8

 SKIP 1                 \ ???

.dashboardSwitch

 SKIP 1                 \ ???

.L00EA

 SKIP 1                 \ ???

.L00EB

 SKIP 1                 \ ???

.L00EC

 SKIP 1                 \ ???

.L00ED

 SKIP 1                 \ ???

.L00EE

 SKIP 1                 \ ???

.L00EF

 SKIP 1                 \ ???

.L00F0

 SKIP 1                 \ ???

.addr6

 SKIP 2                 \ ???

.L00F3

 SKIP 1                 \ ???

.L00F4

 SKIP 1                 \ ???

.ppuCtrlCopy

 SKIP 1                 \ ???

.L00F6

 SKIP 1                 \ ???

.currentBank

 SKIP 1                 \ ???

.L00F8

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
\       Name: SPR
\       Type: Workspace
\    Address: &0200 to &02FF
\   Category: Workspaces
\    Summary: Configuration data for sprites 0 to 63, which gets copied to the
\             PPU to update the screen
\
\ ******************************************************************************

 SPR_00_Y    = &0200
 SPR_00_TILE = &0201
 SPR_00_ATTR = &0202
 SPR_00_X    = &0203

 SPR_01_Y    = &0204
 SPR_01_TILE = &0205
 SPR_01_ATTR = &0206
 SPR_01_X    = &0207

 SPR_02_Y    = &0208
 SPR_02_TILE = &0209
 SPR_02_ATTR = &020A
 SPR_02_X    = &020B

 SPR_03_Y    = &020C
 SPR_03_TILE = &020D
 SPR_03_ATTR = &020E
 SPR_03_X    = &020F

 SPR_04_Y    = &0210
 SPR_04_TILE = &0211
 SPR_04_ATTR = &0212
 SPR_04_X    = &0213

 SPR_05_Y    = &0214
 SPR_05_TILE = &0215
 SPR_05_ATTR = &0216
 SPR_05_X    = &0217

 SPR_06_Y    = &0218
 SPR_06_TILE = &0219
 SPR_06_ATTR = &021A
 SPR_06_X    = &021B

 SPR_07_Y    = &021C
 SPR_07_TILE = &021D
 SPR_07_ATTR = &021E
 SPR_07_X    = &021F

 SPR_08_Y    = &0220
 SPR_08_TILE = &0221
 SPR_08_ATTR = &0222
 SPR_08_X    = &0223

 SPR_09_Y    = &0224
 SPR_09_TILE = &0225
 SPR_09_ATTR = &0226
 SPR_09_X    = &0227

 SPR_10_Y    = &0228
 SPR_10_TILE = &0229
 SPR_10_ATTR = &022A
 SPR_10_X    = &022B

 SPR_11_Y    = &022C
 SPR_11_TILE = &022D
 SPR_11_ATTR = &022E
 SPR_11_X    = &022F

 SPR_12_Y    = &0230
 SPR_12_TILE = &0231
 SPR_12_ATTR = &0232
 SPR_12_X    = &0233

 SPR_13_Y    = &0234
 SPR_13_TILE = &0235
 SPR_13_ATTR = &0236
 SPR_13_X    = &0237

 SPR_14_Y    = &0238
 SPR_14_TILE = &0239
 SPR_14_ATTR = &023A
 SPR_14_X    = &023B

 SPR_15_Y    = &023C
 SPR_15_TILE = &023D
 SPR_15_ATTR = &023E
 SPR_15_X    = &023F

 SPR_16_Y    = &0240
 SPR_16_TILE = &0241
 SPR_16_ATTR = &0242
 SPR_16_X    = &0243

 SPR_17_Y    = &0244
 SPR_17_TILE = &0245
 SPR_17_ATTR = &0246
 SPR_17_X    = &0247

 SPR_18_Y    = &0248
 SPR_18_TILE = &0249
 SPR_18_ATTR = &024A
 SPR_18_X    = &024B

 SPR_19_Y    = &024C
 SPR_19_TILE = &024D
 SPR_19_ATTR = &024E
 SPR_19_X    = &024F

 SPR_20_Y    = &0250
 SPR_20_TILE = &0251
 SPR_20_ATTR = &0252
 SPR_20_X    = &0253

 SPR_21_Y    = &0254
 SPR_21_TILE = &0255
 SPR_21_ATTR = &0256
 SPR_21_X    = &0257

 SPR_22_Y    = &0258
 SPR_22_TILE = &0259
 SPR_22_ATTR = &025A
 SPR_22_X    = &025B

 SPR_23_Y    = &025C
 SPR_23_TILE = &025D
 SPR_23_ATTR = &025E
 SPR_23_X    = &025F

 SPR_24_Y    = &0260
 SPR_24_TILE = &0261
 SPR_24_ATTR = &0262
 SPR_24_X    = &0263

 SPR_25_Y    = &0264
 SPR_25_TILE = &0265
 SPR_25_ATTR = &0266
 SPR_25_X    = &0267

 SPR_26_Y    = &0268
 SPR_26_TILE = &0269
 SPR_26_ATTR = &026A
 SPR_26_X    = &026B

 SPR_27_Y    = &026C
 SPR_27_TILE = &026D
 SPR_27_ATTR = &026E
 SPR_27_X    = &026F

 SPR_28_Y    = &0270
 SPR_28_TILE = &0271
 SPR_28_ATTR = &0272
 SPR_28_X    = &0273

 SPR_29_Y    = &0274
 SPR_29_TILE = &0275
 SPR_29_ATTR = &0276
 SPR_29_X    = &0277

 SPR_30_Y    = &0278
 SPR_30_TILE = &0279
 SPR_30_ATTR = &027A
 SPR_30_X    = &027B

 SPR_31_Y    = &027C
 SPR_31_TILE = &027D
 SPR_31_ATTR = &027E
 SPR_31_X    = &027F

 SPR_32_Y    = &0280
 SPR_32_TILE = &0281
 SPR_32_ATTR = &0282
 SPR_32_X    = &0283

 SPR_33_Y    = &0284
 SPR_33_TILE = &0285
 SPR_33_ATTR = &0286
 SPR_33_X    = &0287

 SPR_34_Y    = &0288
 SPR_34_TILE = &0289
 SPR_34_ATTR = &028A
 SPR_34_X    = &028B

 SPR_35_Y    = &028C
 SPR_35_TILE = &028D
 SPR_35_ATTR = &028E
 SPR_35_X    = &028F

 SPR_36_Y    = &0290
 SPR_36_TILE = &0291
 SPR_36_ATTR = &0292
 SPR_36_X    = &0293

 SPR_37_Y    = &0294
 SPR_37_TILE = &0295
 SPR_37_ATTR = &0296
 SPR_37_X    = &0297

 SPR_38_Y    = &0298
 SPR_38_TILE = &0299
 SPR_38_ATTR = &029A
 SPR_38_X    = &029B

 SPR_39_Y    = &029C
 SPR_39_TILE = &029D
 SPR_39_ATTR = &029E
 SPR_39_X    = &029F

 SPR_40_Y    = &02A0
 SPR_40_TILE = &02A1
 SPR_40_ATTR = &02A2
 SPR_40_X    = &02A3

 SPR_41_Y    = &02A4
 SPR_41_TILE = &02A5
 SPR_41_ATTR = &02A6
 SPR_41_X    = &02A7

 SPR_42_Y    = &02A8
 SPR_42_TILE = &02A9
 SPR_42_ATTR = &02AA
 SPR_42_X    = &02AB

 SPR_43_Y    = &02AC
 SPR_43_TILE = &02AD
 SPR_43_ATTR = &02AE
 SPR_43_X    = &02AF

 SPR_44_Y    = &02B0
 SPR_44_TILE = &02B1
 SPR_44_ATTR = &02B2
 SPR_44_X    = &02B3

 SPR_45_Y    = &02B4
 SPR_45_TILE = &02B5
 SPR_45_ATTR = &02B6
 SPR_45_X    = &02B7

 SPR_46_Y    = &02B8
 SPR_46_TILE = &02B9
 SPR_46_ATTR = &02BA
 SPR_46_X    = &02BB

 SPR_47_Y    = &02BC
 SPR_47_TILE = &02BD
 SPR_47_ATTR = &02BE
 SPR_47_X    = &02BF

 SPR_48_Y    = &02C0
 SPR_48_TILE = &02C1
 SPR_48_ATTR = &02C2
 SPR_48_X    = &02C3

 SPR_49_Y    = &02C4
 SPR_49_TILE = &02C5
 SPR_49_ATTR = &02C6
 SPR_49_X    = &02C7

 SPR_50_Y    = &02C8
 SPR_50_TILE = &02C9
 SPR_50_ATTR = &02CA
 SPR_50_X    = &02CB

 SPR_51_Y    = &02CC
 SPR_51_TILE = &02CD
 SPR_51_ATTR = &02CE
 SPR_51_X    = &02CF

 SPR_52_Y    = &02D0
 SPR_52_TILE = &02D1
 SPR_52_ATTR = &02D2
 SPR_52_X    = &02D3

 SPR_53_Y    = &02D4
 SPR_53_TILE = &02D5
 SPR_53_ATTR = &02D6
 SPR_53_X    = &02D7

 SPR_54_Y    = &02D8
 SPR_54_TILE = &02D9
 SPR_54_ATTR = &02DA
 SPR_54_X    = &02DB

 SPR_55_Y    = &02DC
 SPR_55_TILE = &02DD
 SPR_55_ATTR = &02DE
 SPR_55_X    = &02DF

 SPR_56_Y    = &02E0
 SPR_56_TILE = &02E1
 SPR_56_ATTR = &02E2
 SPR_56_X    = &02E3

 SPR_57_Y    = &02E4
 SPR_57_TILE = &02E5
 SPR_57_ATTR = &02E6
 SPR_57_X    = &02E7

 SPR_58_Y    = &02E8
 SPR_58_TILE = &02E9
 SPR_58_ATTR = &02EA
 SPR_58_X    = &02EB

 SPR_59_Y    = &02EC
 SPR_59_TILE = &02ED
 SPR_59_ATTR = &02EE
 SPR_59_X    = &02EF

 SPR_60_Y    = &02F0
 SPR_60_TILE = &02F1
 SPR_60_ATTR = &02F2
 SPR_60_X    = &02F3

 SPR_61_Y    = &02F4
 SPR_61_TILE = &02F5
 SPR_61_ATTR = &02F6
 SPR_61_X    = &02F7

 SPR_62_Y    = &02F8
 SPR_62_TILE = &02F9
 SPR_62_ATTR = &02FA
 SPR_62_X    = &02FB

 SPR_63_Y    = &02FC
 SPR_63_TILE = &02FD
 SPR_63_ATTR = &02FE
 SPR_63_X    = &02FF

\ ******************************************************************************
\
\       Name: WP
\       Type: Workspace
\    Address: &0300 to &05FF
\   Category: Workspaces
\    Summary: Ship slots, variables
\
\ ******************************************************************************

FRIN              = &036A
JUNK              = &0373
ECMP              = &0389
MJ                = &038A
CABTMP            = &038B
LAS2              = &038C
VIEW              = &038E
LASCT             = &038F
GNTMP             = &0390
EV                = &0392
NAME              = &0396
TP                = &039E
QQ0               = &039F
QQ1               = &03A0
CASH              = &03A1
QQ14              = &03A5
GCNT              = &03A7
LASER             = &03A8
CRGO              = &03AC
QQ20              = &03AD
BST               = &03BF
BOMB              = &03C0
ENGY              = &03C1
DKCMP             = &03C2
GHYP              = &03C3
ESCP              = &03C4
TRIBBLE           = &03C5
TRIBBLE_1         = &03C6
NOMSL             = &03C8
FIST              = &03C9
AVL               = &03CA
QQ26              = &03DB
TALLY             = &03DC
TALLY_1           = &03DD
QQ21              = &03DF
NOSTM             = &03E5
frameCounter      = &03F1
DTW6              = &03F3
DTW2              = &03F4
DTW3              = &03F5
DTW4              = &03F6
DTW5              = &03F7
DTW1              = &03F8
DTW8              = &03F9
XP                = &03FA
YP                = &03FB
LAS               = &0400
MSTG              = &0401
KL                = &0403
KY1               = &0403
KY2               = &0404
KY3               = &0405
KY4               = &0406
KY5               = &0407
KY6               = &0408
KY7               = &0409
QQ19              = &044D
QQ19_1            = &044E
QQ19_2            = &044F
QQ19_3            = &0450
QQ19_4            = &0450
K2                = &0459
K2_1              = &045A
K2_2              = &045B
K2_3              = &045C
DLY               = &045D
pictureTile       = &046C
boxEdge1          = &046E
boxEdge2          = &046F
scanController2   = &0475
JSTX              = &0476
JSTY              = &0477
LASX              = &047B
LASY              = &047C
ALTIT             = &047E
SWAP              = &047F
XSAV2             = &0481
YSAV2             = &0482
FSH               = &0484
ASH               = &0485
ENERGY            = &0486
QQ24              = &0487
QQ25              = &0488
QQ28              = &0489
QQ29              = &048A
systemFlag        = &048B
gov               = &048C
tek               = &048D
QQ2               = &048E
QQ3               = &0494
QQ4               = &0495
QQ5               = &0496
QQ8               = &049B
QQ8_1             = &049C
QQ9               = &049D
QQ10              = &049E
QQ18Lo            = &04A4
QQ18Hi            = &04A5
TKN1Lo            = &04A6
TKN1Hi            = &04A7
language          = &04A8
controller1Down   = &04AA
controller2Down   = &04AB
controller1Up     = &04AC
controller2Up     = &04AD
controller1Left   = &04AE
controller2Left   = &04AF
controller1Right  = &04B0
controller2Right  = &04B1
controller1A      = &04B2
controller2A      = &04B3
controller1B      = &04B4
controller2B      = &04B5
controller1Start  = &04B6
controller2Start  = &04B7
controller1Select = &04B8
controller2Select = &04B9
SX                = &04C8
SY                = &04DD
SZ                = &04F2
BUFm1             = &0506
BUF               = &0507
BUF_1             = &0508
HANGFLAG          = &0561
MANY              = &0562
SSPR              = &0564
SXL               = &05A5
SYL               = &05BA
SZL               = &05CF
safehouse         = &05E4

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
\ ELITE BANK 4
\
\ Produces the binary file bank4.bin.
\
\ ******************************************************************************

 CODE% = &8000
 LOAD% = &8000

 ORG CODE%

\ ******************************************************************************
\
\       Name: ResetMMC1
\       Type: Variable
\   Category: Start and end
\    Summary: The MMC1 mapper reset routine at the start of the ROM bank
\
\ ------------------------------------------------------------------------------
\
\ When the NES is switched on, it is hardwired to perform a JMP (&FFFC). At this
\ point, there is no guarantee as to which ROM banks are mapped to &8000 and
\ &C000, so to ensure that the game starts up correctly, we put the same code
\ in each ROM at the following locations:
\
\   * We put &C000 in address &FFFC in every ROM bank, so the NES always jumps
\     to &C000 when it starts up via the JMP (&FFFC), irrespective of which
\     ROM bank is mapped to &C000.
\
\   * We put the same RESET routine at the start of every ROM bank, so the same
\     routine gets run, whichever ROM bank is mapped to &C000.
\
\ This RESET routine is therefore called when the NES starts up, whatever the
\ bank configuration ends up being. It then switches ROM bank 7 to &C000 and
\ jumps into bank 7 at the game's entry point S%, which starts the game.
\
\ ******************************************************************************

.ResetMMC1

 SEI                    \ Disable interrupts

 INC &C006              \ Reset the MMC1 mapper, which we can do by writing a
                        \ value with bit 7 set into any address in ROM space
                        \ (i.e. any address from &8000 to &FFFF)
                        \
                        \ The INC instruction does this in a more efficient
                        \ manner than an LDA/STA pair, as it:
                        \
                        \   * Fetches the contents of address &C006, which
                        \     contains the high byte of the JMP destination
                        \     below, i.e. the high byte of S%, which is &C0
                        \
                        \   * Adds 1, to give &C1
                        \
                        \   * Writes the value &C1 back to address &C006
                        \
                        \ &C006 is in the ROM space and &C1 has bit 7 set, so
                        \ the INC does all that is required to reset the mapper,
                        \ in fewer cycles and bytes than an LDA/STA pair
                        \
                        \ Resetting MMC1 maps bank 7 to &C000 and enables the
                        \ bank at &8000 to be switched, so this instruction
                        \ ensures that bank 7 is present

 JMP S%                 \ Jump to S% in bank 7 to start the game

\ ******************************************************************************
\
\       Name: Interrupts
\       Type: Subroutine
\   Category: Text
\    Summary: The IRQ and NMI handler while the MMC1 mapper reset routine is
\             still running
\
\ ******************************************************************************

.Interrupts

 RTI                    \ Return from the IRQ interrupt without doing anything
                        \
                        \ This ensures that while the system is starting up and
                        \ the ROM banks are in an unknown configuration, any IRQ
                        \ interrupts that go via the vector at &FFFE and any NMI
                        \ interrupts that go via the vector at &FFFA will end up
                        \ here and be dealt with
                        \
                        \ Once bank 7 is switched into &C000 by the ResetMMC1
                        \ routine, the vector is overwritten with the last two
                        \ bytes of bank 7, which point to the IRQ routine

\ ******************************************************************************
\
\       Name: Version number
\       Type: Variable
\   Category: Text
\    Summary: The game's version number
\
\ ******************************************************************************

 EQUS " 5.0"

\ ******************************************************************************
\
\       Name: CHECK_DASHBOARD
\       Type: Macro
\   Category: Screen mode
\    Summary: If the PPU has started drawing the dashboard, switch to nametable
\             0 (&2000) and pattern table 0 (&0000)
\
\ ******************************************************************************

MACRO CHECK_DASHBOARD

 LDA dashboardSwitch    \ If bit 7 of dashboardSwitch and bit 6 of PPU_STATUS
 BPL skip               \ are set, then call SwitchTablesTo0 to:
 LDA PPU_STATUS         \
 ASL A                  \   * Zero dashboardSwitch to disable this process
 BPL skip               \     until both conditions are met once again
 JSR SwitchTablesTo0    \
                        \   * Clear bits 0 and 4 of PPU_CTRL and PPU_CTRL_COPY,
                        \     to set the base nametable address to &2000 (for
                        \     nametable 0) or &2800 (which is a mirror of &2000)
                        \
                        \   * Clear the C flag
 
.skip

ENDMACRO

\ ******************************************************************************
\
\       Name: image1Count
\       Type: Variable
\   Category: Drawing images
\    Summary: The number of images in group 1, as listed in the image1Offset
\             table
\
\ ******************************************************************************

.image1Count

 EQUW 14

\ ******************************************************************************
\
\       Name: image1Offset
\       Type: Variable
\   Category: Drawing images
\    Summary: Offset to the data for each of the 14 images in group 1
\
\ ******************************************************************************

.image1Offset

 EQUW image0_1 - image1Count
 EQUW image1_1 - image1Count
 EQUW image2_1 - image1Count
 EQUW image3_1 - image1Count
 EQUW image4_1 - image1Count
 EQUW image5_1 - image1Count
 EQUW image6_1 - image1Count
 EQUW image7_1 - image1Count
 EQUW image8_1 - image1Count
 EQUW image9_1 - image1Count
 EQUW image10_1 - image1Count
 EQUW image11_1 - image1Count
 EQUW image12_1 - image1Count
 EQUW image13_1 - image1Count

\ ******************************************************************************
\
\       Name: image0_1
\       Type: Variable
\   Category: Drawing images
\    Summary: Data for image 0 in group 1
\
\ ******************************************************************************

.image0_1

 EQUB &0F, &05, &32, &03, &19, &47, &BC, &05
 EQUB &32, &07, &38, &43, &04, &21, &2D, &5F
 EQUB &83, &57, &04, &FE, &FF, &7F, &FF, &04
 EQUB &80, &B0, &DC, &EA, &05, &C0, &E0, &F4
 EQUB &0F, &01, &33, &01, &02, &03, &04, &21
 EQUB &04, &00, &21, &01, &06, &F7, &DF, &FE
 EQUB &6B, &FF, &21, &1B, &56, &39, &0D, &08
 EQUB &20, &01, &14, &00, &04, &20, &02, &F1
 EQUB &C5, &78, &F6, &CE, &7E, &F3, &DE, &37
 EQUB &0F, &3F, &87, &09, &31, &83, &0C, &20
 EQUB &6D, &EB, &58, &A5, &54, &AB, &54, &BE
 EQUB &22, &F6, &E7, &C3, &89, &32, &1C, &36
 EQUB &7E, &00, &23, &80, &24, &C0, &09, &39
 EQUB &01, &04, &05, &03, &09, &0D, &17, &04
 EQUB &04, &23, &01, &33, &03, &1B, &0B, &7F
 EQUB &80, &C7, &E9, &D4, &F0, &C2, &B6, &02
 EQUB &E0, &D1, &B8, &22, &FC, &D8, &FA, &32
 EQUB &23, &3D, &FF, &10, &44, &54, &44, &32
 EQUB &01, &1F, &FD, &FF, &FE, &33, &28, &38
 EQUB &28, &DF, &FE, &87, &21, &2F, &57, &21
 EQUB &1F, &87, &DB, &DE, &FF, &CF, &32, &17
 EQUB &3B, &22, &7F, &21, &37, &24, &40, &80
 EQUB &20, &60, &D0, &05, &80, &B0, &A0, &36
 EQUB &0F, &17, &01, &0A, &01, &05, &02, &34
 EQUB &13, &03, &03, &01, &04, &21, &02, &80
 EQUB &7D, &D3, &FE, &55, &62, &B5, &C2, &C0
 EQUB &FE, &FC, &FF, &D7, &E3, &76, &92, &AA
 EQUB &AB, &BB, &BA, &21, &29, &10, &21, &29
 EQUB &7C, &22, &6C, &7C, &7D, &EF, &D7, &EE
 EQUB &81, &21, &03, &7D, &96, &FF, &55, &8C
 EQUB &5A, &87, &21, &07, &FF, &7F, &FE, &D6
 EQUB &8E, &DC, &E0, &50, &00, &A0, &00, &40
 EQUB &02, &90, &22, &80, &0F, &06, &AA, &54
 EQUB &E1, &B5, &FA, &B5, &37, &1F, &17, &7F
 EQUB &3E, &1E, &0E, &0F, &23, &4F, &82, &C6
 EQUB &BB, &45, &C6, &21, &39, &83, &FF, &C7
 EQUB &C6, &7C, &32, &38, &01, &C7, &12, &AA
 EQUB &54, &21, &0E, &5A, &BE, &5A, &F0, &D0
 EQUB &FC, &F8, &F0, &22, &E0, &23, &E4, &0F
 EQUB &04, &21, &01, &0C, &7F, &21, &07, &AF
 EQUB &38, &13, &16, &09, &02, &00, &0F, &2F
 EQUB &07, &87, &C2, &43, &21, &21, &00, &83
 EQUB &22, &AB, &EF, &FE, &45, &EE, &BA, &FF
 EQUB &AB, &C7, &FF, &FE, &45, &EF, &7C, &FC
 EQUB &C0, &EA, &91, &D0, &20, &80, &00, &E0
 EQUB &E8, &C0, &C2, &86, &84, &21, &08, &0F
 EQUB &0F, &0F, &0F, &0F, &0F, &07, &3F

\ ******************************************************************************
\
\       Name: image1_1
\       Type: Variable
\   Category: Drawing images
\    Summary: Data for image 1 in group 1
\
\ ******************************************************************************

.image1_1

 EQUB &0F, &05, &32, &03, &19, &47, &BC, &05
 EQUB &32, &07, &38, &43, &04, &21, &2D, &5F
 EQUB &83, &57, &04, &FE, &FF, &7F, &FF, &04
 EQUB &80, &B0, &DC, &EA, &05, &C0, &E0, &F4
 EQUB &0F, &01, &33, &01, &02, &03, &04, &21
 EQUB &04, &00, &21, &01, &06, &F7, &DF, &FE
 EQUB &6B, &FF, &21, &1B, &56, &39, &0D, &08
 EQUB &20, &01, &14, &00, &04, &20, &02, &F1
 EQUB &C5, &78, &F6, &CE, &7E, &F3, &DE, &37
 EQUB &0F, &3F, &87, &09, &31, &83, &0C, &20
 EQUB &6D, &EB, &58, &A5, &54, &AB, &54, &BE
 EQUB &22, &F6, &E7, &C3, &89, &32, &1C, &36
 EQUB &7E, &00, &23, &80, &24, &C0, &09, &39
 EQUB &01, &04, &05, &03, &09, &0D, &17, &04
 EQUB &04, &23, &01, &33, &03, &1B, &0B, &7F
 EQUB &80, &AF, &D5, &F8, &FA, &C2, &B6, &02
 EQUB &D0, &B9, &23, &FC, &D4, &FA, &32, &23
 EQUB &3D, &FF, &10, &44, &54, &44, &32, &01
 EQUB &1F, &FD, &FF, &FE, &33, &28, &38, &28
 EQUB &DF, &86, &AF, &57, &21, &3F, &BF, &87
 EQUB &DB, &DE, &CF, &97, &21, &3B, &23, &7F
 EQUB &57, &24, &40, &80, &20, &60, &D0, &05
 EQUB &80, &B0, &A0, &36, &0F, &15, &01, &0A
 EQUB &01, &05, &02, &34, &13, &03, &03, &01
 EQUB &05, &80, &7D, &D3, &FE, &55, &62, &B5
 EQUB &22, &C0, &FE, &FC, &FF, &D7, &E3, &76
 EQUB &92, &AA, &AB, &BB, &BA, &21, &29, &10
 EQUB &21, &29, &7C, &22, &6C, &7C, &7D, &EF
 EQUB &D7, &EE, &32, &01, &03, &7D, &96, &FF
 EQUB &55, &8C, &5A, &22, &07, &FF, &7F, &FE
 EQUB &D6, &8E, &DC, &E0, &50, &00, &A0, &00
 EQUB &40, &02, &90, &22, &80, &0F, &06, &AA
 EQUB &54, &E1, &B5, &FA, &B5, &37, &1F, &17
 EQUB &7F, &3E, &1E, &0E, &0F, &23, &4F, &82
 EQUB &C6, &BB, &45, &C6, &21, &39, &83, &FF
 EQUB &C7, &C6, &7C, &32, &38, &01, &C7, &12
 EQUB &AA, &54, &21, &0E, &5A, &BE, &5A, &F0
 EQUB &D0, &FC, &F8, &F0, &22, &E0, &23, &E4
 EQUB &0F, &04, &21, &01, &0C, &7C, &21, &07
 EQUB &AF, &38, &13, &16, &09, &02, &00, &0E
 EQUB &2D, &07, &87, &C2, &43, &21, &21, &00
 EQUB &82, &22, &45, &C7, &FE, &45, &EE, &BA
 EQUB &7C, &45, &83, &FF, &FE, &45, &EF, &22
 EQUB &7C, &C0, &EA, &91, &D0, &20, &80, &00
 EQUB &E0, &68, &C0, &C2, &86, &84, &21, &08
 EQUB &0F, &0F, &0F, &0F, &0F, &0F, &07, &3F

\ ******************************************************************************
\
\       Name: image2_1
\       Type: Variable
\   Category: Drawing images
\    Summary: Data for image 2 in group 1
\
\ ******************************************************************************

.image2_1

 EQUB &0F, &05, &32, &03, &19, &47, &BC, &05
 EQUB &32, &07, &38, &43, &04, &21, &2D, &5F
 EQUB &83, &57, &04, &FE, &FF, &7F, &FF, &04
 EQUB &80, &B0, &DC, &EA, &05, &C0, &E0, &F4
 EQUB &0F, &01, &33, &01, &02, &03, &04, &21
 EQUB &04, &00, &21, &01, &06, &F7, &DF, &FE
 EQUB &6B, &FF, &21, &1B, &56, &39, &0D, &08
 EQUB &20, &01, &14, &00, &04, &20, &02, &F1
 EQUB &C5, &78, &F6, &CE, &7E, &F3, &DE, &37
 EQUB &0F, &3F, &87, &09, &31, &83, &0C, &20
 EQUB &6D, &EB, &58, &A5, &54, &AB, &54, &BE
 EQUB &22, &F6, &E7, &C3, &89, &32, &1C, &36
 EQUB &7E, &00, &23, &80, &24, &C0, &09, &39
 EQUB &01, &04, &05, &03, &09, &0D, &17, &04
 EQUB &04, &23, &01, &33, &03, &1B, &0B, &7F
 EQUB &80, &C7, &F4, &FF, &4C, &D0, &7E, &02
 EQUB &F8, &F4, &FF, &83, &E0, &80, &FA, &20
 EQUB &21, &07, &BA, &BB, &C6, &22, &6C, &32
 EQUB &01, &1F, &FB, &C6, &D7, &32, &29, &28
 EQUB &10, &FF, &FE, &FF, &5F, &FF, &65, &21
 EQUB &17, &FD, &FE, &12, &5F, &FF, &83, &32
 EQUB &0F, &03, &24, &40, &80, &20, &60, &D0
 EQUB &05, &80, &B0, &A0, &36, &0F, &15, &01
 EQUB &0A, &01, &05, &02, &34, &13, &03, &03
 EQUB &01, &04, &F7, &9D, &FC, &59, &55, &62
 EQUB &B5, &AA, &F8, &E2, &22, &FE, &D7, &E3
 EQUB &76, &7F, &21, &11, &AB, &BA, &BB, &21
 EQUB &29, &10, &21, &29, &82, &7C, &6C, &22
 EQUB &7C, &EF, &D7, &EE, &C7, &DF, &73, &7F
 EQUB &21, &34, &55, &8D, &5A, &AA, &21, &3F
 EQUB &8F, &12, &D6, &8E, &DC, &FC, &E0, &50
 EQUB &00, &A0, &00, &40, &02, &90, &22, &80
 EQUB &0F, &06, &54, &E1, &B5, &FA, &B5, &22
 EQUB &1F, &35, &17, &3E, &1E, &0E, &0F, &24
 EQUB &4F, &C6, &BB, &45, &C6, &21, &39, &C7
 EQUB &12, &C6, &7C, &32, &38, &01, &C7, &13
 EQUB &54, &21, &0E, &5A, &BE, &5A, &22, &F0
 EQUB &D0, &F8, &F0, &22, &E0, &24, &E4, &0F
 EQUB &04, &21, &01, &0C, &7C, &84, &AF, &38
 EQUB &13, &16, &09, &02, &00, &0E, &2C, &07
 EQUB &87, &C2, &43, &21, &21, &00, &82, &C6
 EQUB &22, &BB, &FE, &45, &EE, &BA, &7C, &C6
 EQUB &C7, &FF, &FE, &45, &EF, &22, &7C, &42
 EQUB &EA, &91, &D0, &20, &80, &00, &E0, &68
 EQUB &C0, &C2, &86, &84, &21, &08, &0F, &0F
 EQUB &0F, &0F, &0F, &0F, &07, &3F

\ ******************************************************************************
\
\       Name: image3_1
\       Type: Variable
\   Category: Drawing images
\    Summary: Data for image 3 in group 1
\
\ ******************************************************************************

.image3_1

 EQUB &0F, &21, &01, &04, &33, &08, &02, &01
 EQUB &B9, &04, &33, &1C, &06, &33, &C9, &04
 EQUB &21, &1A, &60, &32, &04, &25, &03, &89
 EQUB &42, &46, &64, &AC, &05, &58, &40, &C6
 EQUB &05, &21, &3C, &E0, &8E, &0F, &02, &32
 EQUB &03, &02, &02, &32, &04, &02, &03, &34
 EQUB &03, &02, &00, &02, &02, &44, &21, &22
 EQUB &86, &55, &40, &B1, &6A, &FD, &6C, &21
 EQUB &24, &30, &00, &21, &1F, &71, &EA, &FD
 EQUB &FF, &21, &18, &A4, &4D, &30, &AB, &FE
 EQUB &55, &22, &AD, &21, &08, &00, &83, &D7
 EQUB &FE, &55, &10, &90, &21, &25, &52, &32
 EQUB &04, &19, &AC, &7E, &99, &20, &21, &03
 EQUB &00, &F9, &21, &1C, &AE, &7E, &04, &80
 EQUB &00, &40, &80, &02, &80, &00, &80, &02
 EQUB &40, &39, &05, &04, &01, &05, &03, &09
 EQUB &0D, &17, &00, &24, &01, &33, &03, &1B
 EQUB &0B, &F5, &FF, &E2, &A7, &49, &E4, &C4
 EQUB &AE, &F7, &FF, &FE, &C1, &B0, &22, &F8
 EQUB &D0, &BB, &45, &C6, &FF, &21, &11, &C6
 EQUB &54, &44, &BB, &FF, &C6, &FF, &FE, &33
 EQUB &28, &38, &28, &5F, &FE, &8F, &CB, &21
 EQUB &25, &4F, &47, &EB, &DE, &12, &35, &07
 EQUB &1B, &3F, &3F, &17, &00, &22, &40, &00
 EQUB &80, &20, &60, &D0, &05, &80, &B0, &A0
 EQUB &36, &0F, &15, &01, &0A, &01, &05, &02
 EQUB &34, &13, &03, &03, &01, &04, &10, &80
 EQUB &7D, &D3, &FE, &55, &62, &B5, &D2, &C0
 EQUB &FE, &FC, &FF, &D7, &E3, &76, &92, &AA
 EQUB &AB, &BB, &BA, &21, &29, &10, &21, &29
 EQUB &7C, &22, &6C, &7C, &7D, &EF, &D7, &EE
 EQUB &32, &11, &03, &7D, &96, &FF, &55, &8C
 EQUB &5A, &97, &21, &07, &FF, &7F, &FE, &D6
 EQUB &8E, &DC, &E0, &50, &00, &A0, &00, &40
 EQUB &02, &90, &22, &80, &0F, &06, &AA, &54
 EQUB &E1, &B5, &F0, &B5, &37, &12, &15, &7F
 EQUB &3E, &1E, &0E, &0F, &23, &4F, &82, &C6
 EQUB &BB, &45, &C6, &21, &39, &82, &FF, &C7
 EQUB &C6, &7C, &32, &38, &01, &C7, &12, &AA
 EQUB &54, &21, &0E, &5A, &21, &1E, &5A, &90
 EQUB &50, &FC, &F8, &F0, &22, &E0, &23, &E4
 EQUB &0F, &04, &21, &01, &0C, &73, &21, &05
 EQUB &AA, &38, &11, &16, &09, &02, &00, &0F
 EQUB &2F, &07, &87, &C3, &43, &21, &21, &00
 EQUB &55, &AB, &AA, &C7, &EE, &55, &AA, &92
 EQUB &EF, &AB, &C7, &14, &7C, &9C, &40, &AA
 EQUB &21, &11, &D0, &20, &80, &00, &E0, &E8
 EQUB &C0, &C2, &86, &84, &21, &08, &0F, &0F
 EQUB &0F, &0F, &0F, &0F, &07, &3F

\ ******************************************************************************
\
\       Name: image4_1
\       Type: Variable
\   Category: Drawing images
\    Summary: Data for image 4 in group 1
\
\ ******************************************************************************

.image4_1

 EQUB &0F, &21, &01, &04, &33, &08, &02, &01
 EQUB &B9, &04, &33, &1C, &06, &33, &C9, &04
 EQUB &21, &1A, &60, &32, &04, &25, &03, &89
 EQUB &42, &46, &64, &AC, &05, &58, &40, &C6
 EQUB &05, &21, &3C, &E0, &8E, &0F, &02, &32
 EQUB &03, &02, &02, &32, &04, &02, &03, &34
 EQUB &03, &02, &00, &02, &02, &44, &21, &22
 EQUB &86, &55, &40, &B1, &6A, &FD, &6C, &21
 EQUB &24, &30, &00, &21, &1F, &71, &EA, &FD
 EQUB &FF, &21, &18, &A4, &4D, &30, &AB, &FE
 EQUB &55, &22, &AD, &21, &08, &00, &83, &D7
 EQUB &FE, &55, &10, &90, &21, &25, &52, &32
 EQUB &04, &19, &AC, &7E, &99, &20, &21, &03
 EQUB &00, &F9, &21, &1C, &AE, &7E, &04, &80
 EQUB &00, &40, &80, &02, &80, &00, &80, &02
 EQUB &40, &39, &05, &04, &01, &05, &03, &09
 EQUB &0D, &17, &00, &24, &01, &33, &03, &1B
 EQUB &0B, &F6, &FF, &C3, &E9, &D4, &F0, &C2
 EQUB &B6, &F7, &FF, &E7, &D1, &B8, &22, &FC
 EQUB &D8, &BA, &22, &45, &FF, &10, &44, &54
 EQUB &44, &BB, &FF, &45, &FF, &FE, &33, &28
 EQUB &38, &28, &DF, &FE, &87, &21, &2F, &57
 EQUB &21, &1F, &87, &DB, &DE, &FF, &CF, &32
 EQUB &17, &3B, &22, &7F, &21, &37, &00, &22
 EQUB &40, &00, &80, &20, &60, &D0, &05, &80
 EQUB &B0, &A0, &36, &0F, &15, &01, &0A, &01
 EQUB &05, &02, &34, &13, &03, &03, &01, &04
 EQUB &21, &02, &80, &7D, &D3, &FE, &55, &62
 EQUB &B5, &C2, &C0, &FE, &FC, &FF, &D7, &E3
 EQUB &76, &92, &AA, &AB, &BB, &BA, &21, &29
 EQUB &10, &21, &29, &7C, &22, &6C, &7C, &7D
 EQUB &EF, &D7, &EE, &81, &21, &03, &7D, &96
 EQUB &FF, &55, &8C, &5A, &87, &21, &07, &FF
 EQUB &7F, &FE, &D6, &8E, &DC, &E0, &50, &00
 EQUB &A0, &00, &40, &02, &90, &22, &80, &0F
 EQUB &06, &AA, &54, &E1, &B5, &F0, &B5, &37
 EQUB &12, &17, &7F, &3E, &1E, &0E, &0F, &23
 EQUB &4F, &82, &C6, &BB, &45, &C6, &21, &39
 EQUB &82, &FF, &C7, &C6, &7C, &32, &38, &01
 EQUB &C7, &12, &AA, &54, &21, &0E, &5A, &21
 EQUB &1E, &5A, &90, &D0, &FC, &F8, &F0, &22
 EQUB &E0, &23, &E4, &0F, &04, &21, &01, &0C
 EQUB &75, &21, &07, &AB, &38, &11, &16, &09
 EQUB &02, &00, &0E, &2D, &07, &87, &C3, &43
 EQUB &21, &21, &00, &21, &39, &22, &45, &C7
 EQUB &EE, &55, &AA, &92, &C6, &45, &83, &14
 EQUB &7C, &5C, &C0, &AA, &21, &11, &D0, &20
 EQUB &80, &00, &E0, &68, &C0, &C2, &86, &84
 EQUB &21, &08, &0F, &0F, &0F, &0F, &0F, &0F
 EQUB &07, &3F

\ ******************************************************************************
\
\       Name: image5_1
\       Type: Variable
\   Category: Drawing images
\    Summary: Data for image 5 in group 1
\
\ ******************************************************************************

.image5_1

 EQUB &0F, &21, &01, &04, &33, &08, &02, &01
 EQUB &B9, &04, &33, &1C, &06, &33, &C9, &04
 EQUB &21, &1A, &60, &32, &04, &25, &03, &89
 EQUB &42, &46, &64, &AC, &05, &58, &40, &C6
 EQUB &05, &21, &3C, &E0, &8E, &0F, &02, &32
 EQUB &03, &02, &02, &32, &04, &02, &03, &34
 EQUB &03, &02, &00, &02, &02, &44, &21, &22
 EQUB &86, &55, &40, &B1, &6A, &FD, &6C, &21
 EQUB &24, &30, &00, &21, &1F, &71, &EA, &FD
 EQUB &FF, &21, &18, &A4, &4D, &30, &AB, &FE
 EQUB &55, &22, &AD, &21, &08, &00, &83, &D7
 EQUB &FE, &55, &10, &90, &21, &25, &52, &32
 EQUB &04, &19, &AC, &7E, &99, &20, &21, &03
 EQUB &00, &F9, &21, &1C, &AE, &7E, &04, &80
 EQUB &00, &40, &80, &02, &80, &00, &80, &02
 EQUB &40, &39, &05, &04, &01, &05, &03, &09
 EQUB &0D, &17, &00, &24, &01, &33, &03, &1B
 EQUB &0B, &FF, &FE, &FF, &F4, &FF, &4C, &D0
 EQUB &7E, &13, &F4, &FF, &83, &E0, &80, &BB
 EQUB &54, &C7, &BB, &B8, &C4, &22, &6C, &BB
 EQUB &FF, &BB, &C7, &D6, &22, &28, &10, &FF
 EQUB &FE, &87, &21, &2F, &57, &21, &1F, &87
 EQUB &DB, &FE, &FF, &CF, &32, &17, &3B, &22
 EQUB &7F, &57, &00, &22, &40, &00, &80, &20
 EQUB &60, &D0, &05, &80, &B0, &A0, &36, &0F
 EQUB &15, &01, &0A, &01, &05, &02, &34, &13
 EQUB &03, &03, &01, &04, &F7, &9D, &FC, &59
 EQUB &55, &62, &B5, &AA, &F8, &E2, &22, &FE
 EQUB &D7, &E3, &76, &7F, &21, &12, &AA, &BB
 EQUB &BA, &33, &28, &11, &28, &82, &7C, &6C
 EQUB &7C, &7D, &EF, &D7, &EF, &C7, &32, &01
 EQUB &03, &7D, &96, &FF, &55, &8C, &5A, &22
 EQUB &07, &FF, &7F, &FE, &D6, &8E, &DC, &E0
 EQUB &50, &00, &A0, &00, &40, &02, &90, &22
 EQUB &80, &0F, &06, &54, &E1, &B5, &F0, &B5
 EQUB &37, &12, &15, &13, &3E, &1E, &0E, &0F
 EQUB &24, &4F, &C6, &BB, &45, &C6, &21, &39
 EQUB &82, &55, &FF, &C6, &7C, &32, &38, &01
 EQUB &C7, &13, &AA, &D4, &21, &0E, &5A, &21
 EQUB &1E, &5A, &90, &D0, &7C, &78, &F0, &22
 EQUB &E0, &23, &E4, &0F, &04, &21, &01, &0C
 EQUB &74, &21, &02, &AB, &38, &11, &16, &09
 EQUB &02, &00, &0E, &2D, &07, &87, &C3, &43
 EQUB &21, &21, &00, &82, &C6, &BB, &83, &EE
 EQUB &55, &AA, &92, &7C, &22, &C7, &14, &7C
 EQUB &5C, &80, &AA, &21, &11, &D0, &20, &80
 EQUB &00, &E0, &68, &C0, &C2, &86, &84, &21
 EQUB &08, &0F, &0F, &0F, &0F, &0F, &0F, &07
 EQUB &3F

\ ******************************************************************************
\
\       Name: image6_1
\       Type: Variable
\   Category: Drawing images
\    Summary: Data for image 6 in group 1
\
\ ******************************************************************************

.image6_1

 EQUB &0F, &05, &32, &02, &14, &62, &D4, &04
 EQUB &34, &01, &0B, &1D, &2B, &04, &AA, &10
 EQUB &BA, &10, &04, &7D, &13, &04, &80, &50
 EQUB &8C, &56, &05, &A0, &70, &A8, &0F, &01
 EQUB &3C, &01, &02, &03, &02, &07, &07, &06
 EQUB &06, &00, &01, &00, &01, &04, &AA, &F1
 EQUB &AA, &D5, &4E, &B1, &6A, &FD, &55, &21
 EQUB &0E, &55, &00, &21, &3F, &71, &EA, &FD
 EQUB &AA, &21, &01, &AA, &45, &BA, &AB, &FE
 EQUB &55, &7D, &FE, &55, &10, &21, &01, &C7
 EQUB &FE, &55, &AB, &21, &1E, &AB, &56, &E5
 EQUB &21, &1B, &AC, &7E, &54, &E1, &54, &21
 EQUB &01, &F8, &21, &1C, &AE, &7E, &00, &23
 EQUB &80, &24, &C0, &08, &39, &05, &04, &05
 EQUB &05, &03, &09, &0D, &17, &00, &24, &01
 EQUB &33, &03, &1B, &0B, &FF, &F5, &FC, &FB
 EQUB &E2, &88, &44, &BC, &FF, &F7, &FC, &C7
 EQUB &81, &70, &F8, &C0, &BB, &55, &AA, &FF
 EQUB &10, &C6, &54, &44, &BB, &FF, &AA, &12
 EQUB &33, &28, &38, &28, &FF, &5E, &7F, &BF
 EQUB &8F, &21, &23, &45, &7B, &FE, &DF, &7F
 EQUB &C7, &34, &03, &1D, &3F, &07, &24, &40
 EQUB &80, &20, &60, &D0, &05, &80, &B0, &A0
 EQUB &36, &0F, &15, &01, &0A, &01, &05, &02
 EQUB &34, &13, &03, &03, &01, &04, &21, &12
 EQUB &80, &7D, &D3, &FE, &55, &62, &B5, &D0
 EQUB &C0, &FE, &FC, &FF, &D7, &E3, &76, &92
 EQUB &AA, &AB, &BB, &BA, &21, &29, &10, &21
 EQUB &29, &7C, &22, &6C, &7C, &7D, &EF, &D7
 EQUB &EE, &91, &21, &03, &7D, &96, &FF, &55
 EQUB &8C, &5A, &32, &17, &07, &FF, &7F, &FE
 EQUB &D6, &8E, &DC, &E0, &50, &00, &A0, &00
 EQUB &40, &02, &90, &22, &80, &0F, &06, &AA
 EQUB &54, &E1, &BB, &F4, &B1, &58, &21, &12
 EQUB &7F, &36, &3E, &1E, &04, &0B, &4E, &07
 EQUB &4D, &82, &C6, &BB, &45, &C6, &21, &39
 EQUB &82, &21, &28, &C7, &C6, &7C, &32, &38
 EQUB &01, &C6, &7D, &FF, &AA, &54, &21, &0E
 EQUB &BA, &5E, &32, &1A, &34, &90, &FC, &F8
 EQUB &F0, &40, &A0, &E4, &C0, &64, &0F, &04
 EQUB &21, &01, &0C, &78, &21, &04, &A8, &38
 EQUB &12, &14, &09, &02, &00, &07, &2B, &07
 EQUB &85, &C3, &42, &21, &21, &00, &21, &38
 EQUB &AA, &21, &28, &10, &44, &21, &01, &54
 EQUB &BA, &C7, &AB, &C7, &EF, &BB, &FE, &AB
 EQUB &44, &21, &3C, &40, &21, &2A, &91, &50
 EQUB &20, &80, &00, &C0, &A8, &C0, &42, &86
 EQUB &84, &21, &08, &0F, &0F, &0F, &0F, &0F
 EQUB &0F, &07, &3F

\ ******************************************************************************
\
\       Name: image7_1
\       Type: Variable
\   Category: Drawing images
\    Summary: Data for image 7 in group 1
\
\ ******************************************************************************

.image7_1

 EQUB &0F, &05, &32, &02, &14, &62, &D4, &04
 EQUB &34, &01, &0B, &1D, &2B, &04, &AA, &10
 EQUB &BA, &10, &04, &7D, &13, &04, &80, &50
 EQUB &8C, &56, &05, &A0, &70, &A8, &0F, &01
 EQUB &3C, &01, &02, &03, &02, &07, &07, &06
 EQUB &06, &00, &01, &00, &01, &04, &AA, &F1
 EQUB &AA, &D5, &4E, &B1, &6A, &FD, &55, &21
 EQUB &0E, &55, &00, &21, &3F, &71, &EA, &FD
 EQUB &AA, &21, &01, &AA, &45, &BA, &AB, &FE
 EQUB &55, &7D, &FE, &55, &10, &21, &01, &C7
 EQUB &FE, &55, &AB, &21, &1E, &AB, &56, &E5
 EQUB &21, &1B, &AC, &7E, &54, &E1, &54, &21
 EQUB &01, &F8, &21, &1C, &AE, &7E, &00, &23
 EQUB &80, &24, &C0, &08, &39, &05, &04, &05
 EQUB &05, &03, &09, &0D, &17, &00, &24, &01
 EQUB &33, &03, &1B, &0B, &F5, &FF, &E2, &A7
 EQUB &49, &E4, &C4, &AE, &F7, &FF, &FE, &C1
 EQUB &B0, &22, &F8, &D0, &BB, &45, &C6, &FF
 EQUB &21, &11, &C6, &54, &44, &BB, &FF, &C6
 EQUB &FF, &FE, &33, &28, &38, &28, &5F, &FE
 EQUB &8F, &CB, &21, &25, &4F, &47, &EB, &DE
 EQUB &12, &35, &07, &1B, &3F, &3F, &17, &24
 EQUB &40, &80, &20, &60, &D0, &05, &80, &B0
 EQUB &A0, &36, &0F, &15, &01, &0A, &01, &05
 EQUB &02, &34, &13, &03, &03, &01, &04, &10
 EQUB &80, &7D, &D3, &FE, &55, &62, &B5, &D2
 EQUB &C0, &FE, &FC, &FF, &D7, &E3, &76, &92
 EQUB &AA, &AB, &BB, &BA, &21, &29, &10, &21
 EQUB &29, &7C, &22, &6C, &7C, &7D, &EF, &D7
 EQUB &EE, &32, &11, &03, &7D, &96, &FF, &55
 EQUB &8C, &5A, &97, &21, &07, &FF, &7F, &FE
 EQUB &D6, &8E, &DC, &E0, &50, &00, &A0, &00
 EQUB &40, &02, &90, &22, &80, &0F, &06, &AA
 EQUB &54, &E1, &BB, &F4, &B1, &58, &21, &12
 EQUB &7F, &36, &3E, &1E, &04, &0B, &4E, &07
 EQUB &4D, &82, &C6, &BB, &45, &C6, &21, &39
 EQUB &82, &21, &28, &C7, &C6, &7C, &32, &38
 EQUB &01, &C6, &7D, &FF, &AA, &54, &21, &0E
 EQUB &BA, &5E, &32, &1A, &34, &90, &FC, &F8
 EQUB &F0, &40, &A0, &E4, &C0, &64, &0F, &04
 EQUB &21, &01, &0C, &78, &21, &05, &A9, &38
 EQUB &12, &14, &09, &02, &00, &07, &2A, &07
 EQUB &85, &C3, &42, &21, &21, &00, &BA, &AB
 EQUB &21, &29, &10, &44, &21, &01, &54, &BA
 EQUB &45, &AA, &C7, &EF, &BB, &FE, &AB, &44
 EQUB &21, &3C, &40, &21, &2A, &91, &50, &20
 EQUB &80, &00, &C0, &A8, &C0, &42, &86, &84
 EQUB &21, &08, &0F, &0F, &0F, &0F, &0F, &0F
 EQUB &07, &3F

\ ******************************************************************************
\
\       Name: image8_1
\       Type: Variable
\   Category: Drawing images
\    Summary: Data for image 8 in group 1
\
\ ******************************************************************************

.image8_1

 EQUB &0F, &05, &32, &02, &14, &62, &D4, &04
 EQUB &34, &01, &0B, &1D, &2B, &04, &AA, &10
 EQUB &BA, &10, &04, &7D, &13, &04, &80, &50
 EQUB &8C, &56, &05, &A0, &70, &A8, &0F, &01
 EQUB &3C, &01, &02, &03, &02, &07, &07, &06
 EQUB &06, &00, &01, &00, &01, &04, &AA, &F1
 EQUB &AA, &D5, &4E, &B1, &6A, &FD, &55, &21
 EQUB &0E, &55, &00, &21, &3F, &71, &EA, &FD
 EQUB &AA, &21, &01, &AA, &45, &BA, &AB, &FE
 EQUB &55, &7D, &FE, &55, &10, &21, &01, &C7
 EQUB &FE, &55, &AB, &21, &1E, &AB, &56, &E5
 EQUB &21, &1B, &AC, &7E, &54, &E1, &54, &21
 EQUB &01, &F8, &21, &1C, &AE, &7E, &00, &23
 EQUB &80, &24, &C0, &08, &39, &05, &04, &05
 EQUB &05, &03, &09, &0D, &17, &00, &24, &01
 EQUB &33, &03, &1B, &0B, &12, &F5, &EE, &A4
 EQUB &51, &44, &21, &3C, &12, &F7, &FE, &C3
 EQUB &80, &21, &38, &C0, &BB, &EF, &6D, &D6
 EQUB &10, &C7, &54, &44, &BB, &FF, &EF, &FE
 EQUB &FF, &33, &28, &38, &28, &FF, &FE, &5F
 EQUB &EF, &4B, &21, &15, &45, &79, &FE, &FF
 EQUB &DF, &FF, &87, &33, &03, &39, &07, &24
 EQUB &40, &80, &20, &60, &D0, &05, &80, &B0
 EQUB &A0, &36, &0F, &15, &01, &0A, &01, &05
 EQUB &02, &34, &13, &03, &03, &01, &04, &21
 EQUB &02, &80, &7D, &D3, &FE, &55, &62, &B5
 EQUB &D0, &C0, &FE, &FC, &FF, &D7, &E3, &76
 EQUB &92, &AA, &AB, &BB, &BA, &21, &29, &10
 EQUB &21, &29, &7C, &22, &6C, &7C, &7D, &EF
 EQUB &D7, &EE, &81, &21, &03, &7D, &96, &FF
 EQUB &55, &8C, &5A, &32, &17, &07, &FF, &7F
 EQUB &FE, &D6, &8E, &DC, &E0, &50, &00, &A0
 EQUB &00, &40, &02, &90, &22, &80, &0F, &06
 EQUB &AA, &54, &E1, &B5, &FA, &B5, &37, &1F
 EQUB &17, &7F, &3E, &1E, &0E, &0F, &23, &4F
 EQUB &82, &C6, &BB, &45, &C6, &21, &39, &83
 EQUB &FF, &C7, &C6, &7C, &32, &38, &01, &C7
 EQUB &12, &AA, &54, &21, &0E, &5A, &BE, &5A
 EQUB &F0, &D0, &FC, &F8, &F0, &22, &E0, &23
 EQUB &E4, &0F, &0F, &02, &7F, &3E, &07, &2F
 EQUB &13, &16, &09, &02, &00, &0F, &2F, &07
 EQUB &07, &02, &03, &01, &00, &7D, &22, &AB
 EQUB &EF, &FE, &45, &EE, &BA, &83, &AB, &C7
 EQUB &FF, &FE, &45, &EF, &7C, &FC, &C0, &E8
 EQUB &90, &D0, &20, &80, &00, &E0, &E8, &22
 EQUB &C0, &22, &80, &0F, &0F, &0F, &0F, &0F
 EQUB &0F, &08, &3F

\ ******************************************************************************
\
\       Name: image9_1
\       Type: Variable
\   Category: Drawing images
\    Summary: Data for image 9 in group 1
\
\ ******************************************************************************

.image9_1

 EQUB &0F, &21, &01, &04, &33, &08, &02, &01
 EQUB &B9, &04, &33, &1C, &06, &33, &C9, &04
 EQUB &21, &1A, &60, &32, &04, &25, &03, &89
 EQUB &42, &46, &64, &AC, &05, &58, &40, &C6
 EQUB &05, &21, &3C, &E0, &8E, &0F, &02, &32
 EQUB &03, &02, &02, &32, &04, &02, &03, &34
 EQUB &03, &02, &00, &02, &02, &44, &21, &22
 EQUB &86, &55, &4E, &B1, &6A, &F5, &6C, &21
 EQUB &24, &30, &00, &21, &3F, &71, &EA, &FD
 EQUB &FF, &21, &18, &A4, &21, &0D, &82, &AB
 EQUB &FE, &55, &22, &AD, &21, &08, &00, &21
 EQUB &01, &C7, &FE, &55, &10, &90, &21, &25
 EQUB &52, &E4, &21, &1B, &AC, &7E, &99, &20
 EQUB &21, &03, &00, &F9, &21, &1C, &AE, &7E
 EQUB &04, &80, &00, &40, &80, &02, &80, &00
 EQUB &80, &02, &40, &39, &05, &04, &01, &01
 EQUB &03, &09, &0D, &17, &00, &24, &01, &33
 EQUB &03, &1B, &0B, &EF, &D7, &B7, &DA, &73
 EQUB &21, &06, &B8, &21, &0E, &FF, &E7, &D7
 EQUB &BA, &8F, &81, &00, &70, &BB, &12, &D6
 EQUB &BB, &44, &EE, &54, &BB, &12, &FE, &FF
 EQUB &AB, &32, &28, &38, &FF, &FE, &DF, &B7
 EQUB &9B, &C1, &21, &3B, &E1, &FE, &FF, &DF
 EQUB &B7, &E7, &33, &03, &01, &1D, &00, &22
 EQUB &40, &00, &80, &20, &60, &D0, &05, &80
 EQUB &B0, &A0, &36, &0F, &15, &01, &0A, &01
 EQUB &05, &02, &34, &13, &03, &03, &01, &04
 EQUB &21, &3E, &00, &7D, &D3, &FE, &55, &62
 EQUB &B5, &22, &C0, &FE, &FC, &FF, &D7, &E3
 EQUB &76, &82, &AA, &AB, &BB, &BA, &21, &29
 EQUB &10, &21, &29, &23, &6C, &7C, &7D, &EF
 EQUB &D7, &EE, &F9, &21, &01, &7D, &96, &FF
 EQUB &55, &8C, &5A, &22, &07, &FF, &7F, &FE
 EQUB &D6, &8E, &DC, &E0, &50, &00, &A0, &00
 EQUB &40, &02, &90, &22, &80, &0F, &06, &AA
 EQUB &54, &E1, &B1, &F2, &B5, &37, &12, &15
 EQUB &7F, &3E, &1E, &0E, &0F, &23, &4F, &82
 EQUB &C6, &BB, &45, &C6, &21, &39, &82, &FF
 EQUB &C7, &C6, &7C, &32, &38, &01, &C7, &12
 EQUB &AA, &54, &32, &0E, &1A, &9E, &5A, &90
 EQUB &50, &FC, &F8, &F0, &22, &E0, &23, &E4
 EQUB &0F, &0F, &02, &72, &3E, &05, &2B, &11
 EQUB &16, &09, &02, &00, &0F, &2F, &07, &07
 EQUB &03, &03, &01, &00, &7C, &AB, &BB, &C7
 EQUB &EE, &55, &21, &28, &92, &83, &AB, &C7
 EQUB &14, &7C, &9C, &40, &A8, &10, &D0, &20
 EQUB &80, &00, &E0, &E8, &22, &C0, &22, &80
 EQUB &0F, &0F, &0F, &0F, &0F, &0F, &08, &3F

\ ******************************************************************************
\
\       Name: image10_1
\       Type: Variable
\   Category: Drawing images
\    Summary: Data for image 10 in group 1
\
\ ******************************************************************************

.image10_1

 EQUB &0F, &04, &32, &14, &02, &00, &53, &88
 EQUB &03, &34, &08, &06, &03, &21, &71, &03
 EQUB &21, &1A, &20, &44, &A5, &7C, &02, &21
 EQUB &09, &82, &46, &66, &6C, &AD, &04, &4C
 EQUB &40, &C0, &21, &0A, &04, &30, &E0, &80
 EQUB &84, &0F, &01, &21, &01, &00, &3B, &03
 EQUB &01, &02, &01, &04, &02, &00, &01, &01
 EQUB &03, &01, &02, &21, &04, &75, &DA, &AC
 EQUB &F5, &AA, &D1, &EA, &F5, &F8, &DC, &AE
 EQUB &F6, &AB, &D1, &EA, &FD, &FF, &21, &18
 EQUB &A4, &21, &0D, &82, &AB, &FE, &55, &22
 EQUB &AD, &21, &08, &00, &21, &01, &C7, &FE
 EQUB &55, &21, &11, &AE, &34, &1B, &35, &E2
 EQUB &17, &AE, &7E, &8E, &32, &1F, &3B, &75
 EQUB &E3, &21, &16, &AE, &7E, &02, &80, &00
 EQUB &80, &00, &40, &80, &03, &80, &03, &40
 EQUB &39, &01, &04, &05, &01, &03, &09, &0D
 EQUB &17, &00, &24, &01, &33, &03, &1B, &0B
 EQUB &EF, &D7, &B7, &9A, &43, &21, &06, &B0
 EQUB &21, &0C, &FF, &E7, &D7, &FA, &BF, &81
 EQUB &00, &70, &BB, &FF, &D7, &FE, &93, &44
 EQUB &EE, &54, &BB, &12, &FE, &FF, &AB, &32
 EQUB &28, &38, &FF, &FE, &DF, &B7, &8F, &C1
 EQUB &21, &1B, &61, &FE, &FF, &DF, &B7, &FF
 EQUB &33, &03, &01, &1D, &00, &22, &40, &00
 EQUB &80, &20, &60, &D0, &05, &80, &B0, &A0
 EQUB &36, &0F, &15, &01, &0A, &01, &05, &02
 EQUB &34, &13, &03, &03, &01, &04, &BE, &00
 EQUB &7D, &D3, &FE, &55, &62, &B5, &40, &C0
 EQUB &FE, &FC, &FF, &D7, &E3, &76, &22, &AA
 EQUB &AB, &BB, &BA, &21, &29, &10, &21, &29
 EQUB &23, &6C, &7C, &7D, &EF, &D7, &EE, &FB
 EQUB &21, &01, &7D, &96, &FF, &55, &8C, &5A
 EQUB &32, &05, &07, &FF, &7F, &FE, &D6, &8E
 EQUB &DC, &E0, &50, &00, &A0, &00, &40, &02
 EQUB &90, &22, &80, &0F, &06, &AA, &54, &E1
 EQUB &BB, &F0, &B5, &58, &21, &14, &7F, &36
 EQUB &3E, &1E, &04, &0F, &4A, &07, &4B, &82
 EQUB &C6, &BB, &45, &C6, &21, &39, &00, &BA
 EQUB &C7, &C6, &7C, &32, &38, &01, &C6, &12
 EQUB &AA, &54, &21, &0E, &BA, &21, &1E, &5A
 EQUB &21, &34, &50, &FC, &F8, &F0, &40, &E0
 EQUB &A4, &C0, &A4, &0F, &0F, &02, &70, &3E
 EQUB &04, &28, &12, &14, &09, &02, &00, &0F
 EQUB &2B, &07, &05, &03, &02, &01, &00, &FE
 EQUB &AA, &21, &38, &10, &82, &21, &11, &44
 EQUB &AA, &21, &01, &AB, &C7, &EF, &7D, &EE
 EQUB &BB, &54, &21, &1C, &40, &21, &28, &90
 EQUB &50, &20, &80, &00, &E0, &A8, &C0, &40
 EQUB &22, &80, &0F, &0F, &0F, &0F, &0F, &0F
 EQUB &08, &3F

\ ******************************************************************************
\
\       Name: image11_1
\       Type: Variable
\   Category: Drawing images
\    Summary: Data for image 11 in group 1
\
\ ******************************************************************************

.image11_1

 EQUB &0F, &05, &34, &02, &14, &32, &24, &04
 EQUB &33, &01, &0B, &0D, &CB, &04, &AA, &10
 EQUB &BA, &10, &04, &7D, &13, &04, &80, &50
 EQUB &98, &48, &05, &A0, &60, &A6, &0F, &02
 EQUB &39, &02, &01, &00, &05, &04, &06, &06
 EQUB &01, &01, &23, &03, &21, &01, &02, &21
 EQUB &1A, &9D, &4E, &21, &35, &7E, &F1, &6A
 EQUB &F5, &E5, &E2, &F1, &F8, &FF, &F1, &EA
 EQUB &FD, &AA, &21, &01, &AA, &45, &BA, &AB
 EQUB &FE, &55, &7D, &FE, &55, &10, &21, &01
 EQUB &C7, &FE, &55, &B0, &72, &A5, &58, &FD
 EQUB &21, &1E, &BC, &6E, &4F, &8F, &34, &1F
 EQUB &3F, &FF, &1F, &BE, &7E, &00, &80, &02
 EQUB &22, &40, &22, &C0, &02, &23, &80, &03
 EQUB &39, &05, &04, &05, &05, &03, &09, &0D
 EQUB &17, &00, &24, &01, &33, &03, &1B, &0B
 EQUB &EF, &D7, &F7, &9A, &C7, &64, &21, &01
 EQUB &C8, &FF, &E7, &D7, &FA, &BF, &83, &80
 EQUB &30, &BB, &7D, &C7, &D6, &BB, &44, &EF
 EQUB &54, &BB, &12, &FE, &D7, &AB, &32, &28
 EQUB &38, &FF, &EE, &EB, &B3, &D7, &4B, &32
 EQUB &01, &2F, &FE, &FF, &FB, &AB, &EF, &87
 EQUB &32, &03, &01, &24, &40, &80, &20, &60
 EQUB &D0, &05, &80, &B0, &A0, &36, &0F, &15
 EQUB &01, &0A, &01, &05, &02, &34, &13, &03
 EQUB &03, &01, &04, &21, &3E, &00, &7D, &D3
 EQUB &FE, &55, &62, &B5, &40, &C0, &FE, &FC
 EQUB &FF, &D7, &E3, &76, &82, &AA, &AB, &BB
 EQUB &BA, &21, &29, &10, &21, &29, &44, &22
 EQUB &6C, &7C, &7D, &EF, &D7, &EE, &F9, &21
 EQUB &01, &6D, &96, &EF, &65, &9C, &5A, &32
 EQUB &05, &07, &FF, &6F, &FE, &F6, &9E, &DC
 EQUB &E0, &50, &00, &A0, &00, &40, &02, &90
 EQUB &22, &80, &0F, &06, &AA, &54, &E1, &B5
 EQUB &FA, &B5, &37, &1F, &17, &7F, &3E, &1E
 EQUB &0E, &0F, &23, &4F, &82, &C6, &BB, &45
 EQUB &C6, &21, &39, &83, &FF, &C7, &C6, &7C
 EQUB &32, &38, &01, &C7, &12, &AA, &54, &21
 EQUB &0E, &5A, &BE, &5A, &F0, &D0, &FC, &F8
 EQUB &F0, &22, &E0, &23, &E4, &0F, &0F, &02
 EQUB &7F, &3E, &06, &2F, &13, &16, &09, &02
 EQUB &00, &0E, &2F, &07, &07, &02, &03, &01
 EQUB &00, &FF, &44, &AB, &EF, &FE, &45, &EE
 EQUB &BA, &00, &45, &C7, &FF, &FE, &45, &EF
 EQUB &7C, &FC, &C0, &E8, &90, &D0, &20, &80
 EQUB &00, &E0, &E8, &22, &C0, &22, &80, &0F
 EQUB &0F, &0F, &0F, &0F, &0F, &08, &3F

\ ******************************************************************************
\
\       Name: image12_1
\       Type: Variable
\   Category: Drawing images
\    Summary: Data for image 12 in group 1
\
\ ******************************************************************************

.image12_1

 EQUB &0F, &05, &32, &02, &14, &62, &D4, &04
 EQUB &34, &01, &0B, &1D, &2B, &04, &AA, &10
 EQUB &BA, &10, &04, &7D, &13, &04, &80, &50
 EQUB &8C, &56, &05, &A0, &70, &A8, &0F, &01
 EQUB &3C, &01, &02, &03, &02, &07, &04, &00
 EQUB &06, &00, &01, &00, &01, &04, &AA, &F1
 EQUB &AA, &D5, &4E, &B1, &6A, &F5, &55, &21
 EQUB &0E, &55, &00, &21, &3F, &71, &EA, &FD
 EQUB &AA, &21, &01, &AA, &45, &BA, &AB, &FE
 EQUB &55, &7D, &FE, &55, &10, &21, &01, &C7
 EQUB &FE, &55, &AB, &21, &1E, &AB, &56, &E5
 EQUB &21, &1A, &BC, &6E, &54, &E1, &54, &21
 EQUB &01, &F8, &21, &1C, &BE, &7E, &00, &23
 EQUB &80, &C0, &40, &00, &C0, &08, &39, &01
 EQUB &04, &01, &05, &03, &09, &0D, &17, &00
 EQUB &24, &01, &33, &03, &1B, &0B, &EF, &D5
 EQUB &FF, &8F, &B3, &32, &36, &0C, &E0, &FF
 EQUB &E7, &DF, &EF, &F3, &CE, &83, &00, &BB
 EQUB &55, &45, &FF, &BB, &C6, &6C, &21, &28
 EQUB &BB, &FF, &BB, &83, &D7, &AA, &AB, &10
 EQUB &FF, &6E, &EB, &F3, &57, &CB, &61, &21
 EQUB &0F, &FE, &FF, &FB, &EB, &6F, &E7, &83
 EQUB &21, &01, &00, &40, &00, &40, &80, &20
 EQUB &60, &D0, &05, &80, &B0, &A0, &36, &0F
 EQUB &15, &01, &0A, &01, &05, &02, &34, &13
 EQUB &03, &03, &01, &04, &32, &3C, &02, &7D
 EQUB &D3, &FE, &55, &62, &B5, &40, &C2, &FE
 EQUB &FC, &FF, &D7, &E3, &76, &82, &AA, &AB
 EQUB &BB, &10, &21, &29, &82, &C7, &44, &22
 EQUB &6C, &7C, &D7, &EF, &C7, &C6, &69, &81
 EQUB &6D, &96, &EF, &65, &9C, &5A, &21, &05
 EQUB &87, &FF, &6F, &FE, &F6, &9E, &DC, &E0
 EQUB &50, &00, &A0, &00, &40, &02, &90, &22
 EQUB &80, &0F, &06, &AA, &54, &E3, &B9, &FA
 EQUB &B5, &5A, &21, &14, &7F, &36, &3E, &1C
 EQUB &06, &05, &4A, &05, &4B, &BA, &44, &C7
 EQUB &21, &39, &40, &21, &29, &54, &AA, &7D
 EQUB &21, &38, &00, &C6, &BF, &FE, &21, &21
 EQUB &75, &AA, &54, &8E, &21, &3A, &BE, &5A
 EQUB &B4, &50, &FC, &F8, &70, &C0, &40, &A4
 EQUB &40, &A4, &0F, &0F, &02, &75, &3E, &08
 EQUB &25, &08, &12, &06, &09, &03, &0A, &27
 EQUB &0B, &07, &05, &01, &02, &00, &55, &AA
 EQUB &45, &44, &21, &38, &91, &21, &04, &59
 EQUB &20, &6D, &C7, &83, &C7, &6E, &FB, &A6
 EQUB &21, &3C, &20, &48, &A0, &10, &40, &A0
 EQUB &80, &C0, &C8, &A0, &40, &C0, &80, &0F
 EQUB &0F, &0F, &05, &BE, &07, &40, &0F, &0F
 EQUB &09, &3F

\ ******************************************************************************
\
\       Name: image13_1
\       Type: Variable
\   Category: Drawing images
\    Summary: Data for image 13 in group 1
\
\ ******************************************************************************

.image13_1

 EQUB &0F, &21, &01, &04, &33, &08, &02, &01
 EQUB &B9, &04, &33, &1C, &06, &33, &C9, &04
 EQUB &21, &1A, &60, &32, &04, &25, &03, &89
 EQUB &42, &46, &64, &AC, &05, &58, &40, &C6
 EQUB &05, &21, &3C, &E0, &8E, &0F, &02, &32
 EQUB &03, &02, &02, &33, &04, &02, &04, &02
 EQUB &38, &03, &02, &00, &02, &00, &01, &44
 EQUB &22, &86, &55, &4E, &B1, &6A, &F5, &6C
 EQUB &21, &24, &30, &00, &21, &3F, &71, &EA
 EQUB &FD, &FF, &21, &18, &A4, &21, &0D, &82
 EQUB &AB, &FE, &55, &22, &AD, &21, &08, &00
 EQUB &21, &01, &C7, &FE, &55, &10, &90, &21
 EQUB &25, &52, &E4, &21, &1B, &BC, &6E, &99
 EQUB &20, &21, &03, &00, &F9, &21, &1C, &BE
 EQUB &7F, &04, &80, &00, &C0, &40, &02, &80
 EQUB &00, &80, &02, &80, &3E, &05, &03, &01
 EQUB &07, &03, &09, &0D, &17, &03, &07, &07
 EQUB &03, &01, &03, &32, &1B, &0B, &EF, &DE
 EQUB &FF, &9F, &DA, &67, &21, &06, &D0, &FF
 EQUB &EF, &DF, &FF, &BA, &8F, &81, &20, &BB
 EQUB &D6, &21, &01, &AB, &92, &C7, &22, &6C
 EQUB &BB, &12, &D7, &FE, &22, &AB, &10, &FF
 EQUB &EF, &EB, &F3, &B7, &CB, &C1, &21, &0F
 EQUB &12, &FB, &EB, &AF, &E7, &32, &03, &01
 EQUB &80, &00, &80, &40, &80, &20, &60, &D0
 EQUB &23, &C0, &80, &00, &80, &B0, &A0, &36
 EQUB &0F, &15, &01, &0A, &01, &05, &02, &34
 EQUB &13, &03, &03, &01, &04, &21, &3C, &00
 EQUB &7D, &D3, &FE, &55, &62, &B5, &40, &C0
 EQUB &FE, &FC, &FF, &D7, &E3, &76, &82, &AA
 EQUB &AB, &BB, &BA, &32, &11, &28, &83, &44
 EQUB &22, &6C, &7C, &7D, &D7, &EF, &C6, &69
 EQUB &21, &01, &6D, &96, &EF, &65, &9C, &5A
 EQUB &32, &05, &07, &FF, &6F, &FE, &F6, &9E
 EQUB &DC, &E0, &50, &00, &A0, &00, &40, &02
 EQUB &90, &22, &80, &0F, &06, &AA, &54, &E3
 EQUB &B9, &FA, &B5, &37, &13, &14, &7F, &3E
 EQUB &1C, &06, &07, &22, &4F, &4E, &C6, &BA
 EQUB &45, &C7, &32, &38, &01, &FF, &AA, &C7
 EQUB &7C, &21, &38, &00, &C7, &12, &6C, &AA
 EQUB &54, &8E, &21, &3A, &BE, &5A, &90, &50
 EQUB &FC, &F8, &70, &22, &C0, &23, &E4, &0F
 EQUB &0F, &02, &72, &3E, &07, &2B, &11, &16
 EQUB &09, &02, &00, &0F, &2F, &07, &07, &03
 EQUB &03, &01, &00, &D6, &22, &45, &C7, &EE
 EQUB &55, &AA, &92, &21, &39, &45, &83, &14
 EQUB &7C, &9C, &C0, &A8, &10, &D0, &20, &80
 EQUB &00, &E0, &E8, &22, &C0, &22, &80, &0F
 EQUB &0F, &0F, &0F, &0F, &0F, &08, &3F

\ ******************************************************************************
\
\       Name: image2Count
\       Type: Variable
\   Category: Drawing images
\    Summary: The number of images in group 2, as listed in the image2Offset
\             table
\
\ ******************************************************************************

.image2Count

 EQUW 14

\ ******************************************************************************
\
\       Name: image2Offset
\       Type: Variable
\   Category: Drawing images
\    Summary: Offset to the data for each of the 14 images in group 2
\
\ ******************************************************************************

.image2Offset

 EQUW image0_2 - image2Count
 EQUW image1_2 - image2Count
 EQUW image2_2 - image2Count
 EQUW image3_2 - image2Count
 EQUW image4_2 - image2Count
 EQUW image5_2 - image2Count
 EQUW image6_2 - image2Count
 EQUW image7_2 - image2Count
 EQUW image8_2 - image2Count
 EQUW image9_2 - image2Count
 EQUW image10_2 - image2Count
 EQUW image11_2 - image2Count
 EQUW image12_2 - image2Count
 EQUW image13_2 - image2Count

\ ******************************************************************************
\
\       Name: image0_2
\       Type: Variable
\   Category: Drawing images
\    Summary: Data for image 0 in group 2
\
\ ******************************************************************************

.image0_2

 EQUB &1D, &FC, &F0, &E0, &13, &E0, &04, &13
 EQUB &32, &0F, &01, &03, &15, &7F, &32, &1F
 EQUB &0F, &1F, &11, &22, &C0, &23, &80, &0F
 EQUB &04, &22, &07, &23, &03, &21, &01, &81
 EQUB &21, &01, &1D, &FE, &22, &FC, &0D, &21
 EQUB &01, &00, &32, &01, &02, &00, &20, &05
 EQUB &25, &01, &03, &16, &22, &7F, &22, &FC
 EQUB &22, &FE, &14, &22, &01, &03, &21, &02
 EQUB &81, &C0, &00, &32, &21, &01, &02, &81
 EQUB &C2, &81, &32, &01, &09, &03, &21, &02
 EQUB &87, &21, &02, &04, &21, &01, &81, &32
 EQUB &03, &07, &22, &7F, &1E, &28, &E0, &22
 EQUB &03, &06, &22, &80, &06, &28, &0F, &1A
 EQUB &00, &A0, &D7, &13, &C0, &00, &22, &20
 EQUB &60, &22, &E0, &B0, &00, &21, &05, &02
 EQUB &10, &32, &0B, &01, &02, &40, &02, &10
 EQUB &A0, &02, &38, &07, &01, &08, &08, &0D
 EQUB &0F, &0F, &1B, &12, &00, &21, &0A, &D7
 EQUB &14, &F7, &EE, &75, &AA, &55, &21, &22
 EQUB &48, &B0, &DC, &CF, &C3, &A0, &C0, &90
 EQUB &44, &03, &E0, &7F, &21, &0F, &04, &32
 EQUB &01, &0F, &FC, &E0, &02, &21, &1B, &77
 EQUB &E6, &87, &33, &0A, &07, &12, &44, &FF
 EQUB &DF, &EF, &5D, &AA, &55, &88, &34, &25
 EQUB &02, &00, &01, &40, &04, &AA, &40, &21
 EQUB &0A, &20, &21, &0A, &04, &40, &80, &21
 EQUB &08, &A0, &00, &20, &02, &36, &04, &02
 EQUB &20, &0A, &00, &08, &00, &AA, &21, &04
 EQUB &A1, &21, &08, &A0, &03, &80, &02, &21
 EQUB &05, &04, &3F, &0F, &0F, &0F, &0F, &0F
 EQUB &0B, &80, &0F, &0F, &21, &01, &00, &32
 EQUB &01, &02, &00, &20, &0F, &0E, &22, &01
 EQUB &03, &32, &02, &01, &02, &32, &21, &01
 EQUB &02, &81, &C2, &81, &32, &01, &09, &03
 EQUB &21, &02, &87, &21, &02, &05, &80, &0F
 EQUB &0B, &22, &03, &06, &22, &80, &0F, &0A
 EQUB &15, &02, &23, &E0, &23, &F0, &00, &21
 EQUB &05, &02, &10, &32, &0B, &01, &02, &40
 EQUB &02, &10, &A0, &04, &33, &0E, &0F, &0F
 EQUB &23, &1F, &03, &1D, &F8, &FE, &12, &F7
 EQUB &FD, &12, &02, &C0, &13, &21, &1F, &F0
 EQUB &02, &21, &07, &13, &F1, &32, &1F, &3F
 EQUB &13, &DF, &7F, &1C, &EF, &F7, &FB, &F1
 EQUB &F8, &71, &15, &7F, &21, &2F, &56, &FC
 EQUB &FE, &FF, &FE, &FF, &FE, &FF, &FE, &7F
 EQUB &16, &FE, &15, &FD, &E8, &D5, &12, &EF
 EQUB &DF, &BF, &33, &1F, &3F, &1E, &3F

\ ******************************************************************************
\
\       Name: image1_2
\       Type: Variable
\   Category: Drawing images
\    Summary: Data for image 1 in group 2
\
\ ******************************************************************************

.image1_2

 EQUB &1D, &FC, &F0, &E0, &13, &E0, &04, &13
 EQUB &32, &0F, &01, &03, &15, &7F, &32, &1F
 EQUB &0F, &1F, &11, &22, &C0, &23, &80, &0F
 EQUB &04, &22, &07, &23, &03, &21, &01, &81
 EQUB &21, &01, &1D, &FE, &22, &FC, &0D, &21
 EQUB &01, &00, &81, &21, &02, &00, &20, &04
 EQUB &31, &02, &25, &01, &03, &16, &22, &7F
 EQUB &22, &FC, &22, &FE, &14, &22, &01, &03
 EQUB &21, &02, &81, &C0, &20, &32, &21, &01
 EQUB &02, &81, &C2, &81, &22, &09, &03, &21
 EQUB &02, &87, &21, &02, &04, &21, &01, &81
 EQUB &32, &03, &07, &22, &7F, &1E, &28, &E0
 EQUB &22, &03, &06, &22, &80, &06, &28, &0F
 EQUB &1A, &00, &A0, &D7, &13, &C0, &00, &22
 EQUB &20, &60, &22, &E0, &B0, &00, &21, &0B
 EQUB &02, &10, &32, &0B, &01, &02, &A0, &02
 EQUB &10, &A0, &02, &38, &07, &01, &08, &08
 EQUB &0D, &0F, &0F, &1B, &12, &00, &21, &0A
 EQUB &D7, &14, &F7, &EE, &75, &AA, &55, &21
 EQUB &22, &48, &B0, &DC, &CF, &C3, &A0, &C0
 EQUB &90, &44, &03, &E0, &7F, &21, &0F, &04
 EQUB &32, &01, &0F, &FC, &E0, &02, &21, &1B
 EQUB &77, &E6, &87, &33, &0A, &07, &12, &44
 EQUB &FF, &DF, &EF, &5D, &AA, &55, &88, &34
 EQUB &25, &02, &00, &01, &40, &04, &AA, &40
 EQUB &21, &0A, &20, &21, &0A, &04, &40, &80
 EQUB &21, &08, &A0, &00, &20, &02, &36, &04
 EQUB &02, &20, &0A, &00, &08, &00, &AA, &21
 EQUB &04, &A1, &21, &08, &A0, &03, &80, &02
 EQUB &21, &05, &04, &3F, &0F, &0F, &0F, &0F
 EQUB &0F, &0B, &80, &0F, &0F, &21, &01, &00
 EQUB &81, &21, &02, &00, &20, &04, &21, &02
 EQUB &0F, &09, &22, &01, &03, &32, &02, &01
 EQUB &00, &20, &32, &21, &01, &02, &81, &C2
 EQUB &81, &22, &09, &03, &21, &02, &87, &21
 EQUB &02, &05, &80, &0F, &0B, &22, &03, &06
 EQUB &22, &80, &0F, &0A, &15, &02, &23, &E0
 EQUB &23, &F0, &00, &21, &0B, &02, &10, &32
 EQUB &0B, &01, &02, &A0, &02, &10, &A0, &04
 EQUB &33, &0E, &0F, &0F, &23, &1F, &03, &1D
 EQUB &F8, &FE, &12, &F7, &FD, &12, &02, &C0
 EQUB &13, &21, &1F, &F0, &02, &21, &07, &13
 EQUB &F1, &32, &1F, &3F, &13, &DF, &7F, &1C
 EQUB &EF, &F7, &FB, &F1, &F8, &71, &15, &7F
 EQUB &21, &2F, &56, &FC, &FE, &FF, &FE, &FF
 EQUB &FE, &FF, &FE, &7F, &16, &FE, &15, &FD
 EQUB &E8, &D5, &12, &EF, &DF, &BF, &33, &1F
 EQUB &3F, &1E, &3F

\ ******************************************************************************
\
\       Name: image2_2
\       Type: Variable
\   Category: Drawing images
\    Summary: Data for image 2 in group 2
\
\ ******************************************************************************

.image2_2

 EQUB &1D, &FC, &F0, &E0, &13, &E0, &04, &13
 EQUB &32, &0F, &01, &03, &15, &7F, &32, &1F
 EQUB &0F, &1F, &11, &22, &C0, &23, &80, &0F
 EQUB &04, &22, &07, &23, &03, &21, &01, &81
 EQUB &21, &01, &1D, &FE, &22, &FC, &0B, &B0
 EQUB &00, &22, &01, &04, &21, &1A, &04, &25
 EQUB &01, &03, &16, &22, &7F, &22, &FC, &22
 EQUB &FE, &14, &04, &32, &02, &01, &80, &C0
 EQUB &00, &21, &01, &02, &81, &C2, &81, &21
 EQUB &03, &04, &21, &02, &87, &21, &02, &80
 EQUB &04, &81, &33, &01, &03, &07, &22, &7F
 EQUB &1E, &28, &E0, &21, &03, &07, &80, &07
 EQUB &28, &0F, &1A, &00, &A0, &D7, &13, &C0
 EQUB &00, &22, &20, &60, &22, &E0, &B0, &00
 EQUB &21, &03, &02, &10, &32, &0B, &01, &02
 EQUB &80, &02, &10, &A0, &02, &38, &07, &01
 EQUB &08, &08, &0D, &0F, &0F, &1B, &12, &00
 EQUB &21, &0A, &D7, &14, &F7, &EE, &75, &AA
 EQUB &55, &21, &22, &48, &B0, &DC, &CF, &C3
 EQUB &A0, &C0, &90, &44, &03, &E0, &7F, &21
 EQUB &0F, &04, &32, &01, &0F, &FC, &E0, &02
 EQUB &21, &1B, &77, &E6, &87, &33, &0A, &07
 EQUB &12, &44, &FF, &DF, &EF, &5D, &AA, &55
 EQUB &88, &34, &25, &02, &00, &01, &40, &04
 EQUB &AA, &40, &21, &0A, &20, &21, &0A, &04
 EQUB &40, &80, &21, &08, &A0, &00, &20, &02
 EQUB &36, &04, &02, &20, &0A, &00, &08, &00
 EQUB &AA, &21, &04, &A1, &21, &08, &A0, &03
 EQUB &80, &02, &21, &05, &04, &3F, &0F, &0F
 EQUB &0F, &0F, &0F, &0B, &80, &0F, &0D, &B0
 EQUB &00, &22, &01, &04, &21, &1A, &0F, &0F
 EQUB &02, &32, &02, &01, &03, &21, &01, &02
 EQUB &81, &C2, &81, &21, &03, &04, &21, &02
 EQUB &87, &21, &02, &80, &04, &80, &0F, &0C
 EQUB &21, &03, &07, &80, &0F, &0B, &15, &02
 EQUB &23, &E0, &23, &F0, &00, &21, &03, &02
 EQUB &10, &32, &0B, &01, &02, &80, &02, &10
 EQUB &A0, &04, &33, &0E, &0F, &0F, &23, &1F
 EQUB &03, &1D, &F8, &FE, &12, &F7, &FD, &12
 EQUB &02, &C0, &13, &21, &1F, &F0, &02, &21
 EQUB &07, &13, &F1, &32, &1F, &3F, &13, &DF
 EQUB &7F, &1C, &EF, &F7, &FB, &F1, &F8, &71
 EQUB &15, &7F, &21, &2F, &56, &FC, &FE, &FF
 EQUB &FE, &FF, &FE, &FF, &FE, &7F, &16, &FE
 EQUB &15, &FD, &E8, &D5, &12, &EF, &DF, &BF
 EQUB &33, &1F, &3F, &1E, &3F

\ ******************************************************************************
\
\       Name: image3_2
\       Type: Variable
\   Category: Drawing images
\    Summary: Data for image 3 in group 2
\
\ ******************************************************************************

.image3_2

 EQUB &1B, &FE, &22, &FC, &E0, &C0, &12, &F7
 EQUB &20, &04, &12, &6F, &21, &07, &04, &14
 EQUB &34, &3F, &1F, &1F, &0F, &1F, &11, &C0
 EQUB &24, &80, &00, &21, &01, &06, &E0, &50
 EQUB &21, &2A, &05, &35, &0E, &15, &A8, &07
 EQUB &07, &23, &03, &23, &01, &1D, &FE, &22
 EQUB &FC, &08, &84, &00, &21, &13, &02, &21
 EQUB &01, &00, &21, &01, &42, &00, &90, &05
 EQUB &25, &01, &03, &16, &22, &7F, &22, &FC
 EQUB &22, &FE, &14, &00, &21, &01, &03, &21
 EQUB &02, &81, &C0, &00, &32, &21, &01, &02
 EQUB &81, &C2, &81, &00, &21, &09, &03, &21
 EQUB &02, &87, &21, &02, &04, &21, &01, &81
 EQUB &32, &03, &07, &22, &7F, &1E, &28, &E0
 EQUB &22, &03, &06, &22, &80, &06, &28, &0F
 EQUB &18, &21, &01, &F9, &22, &F8, &FF, &FB
 EQUB &12, &C0, &02, &20, &00, &A0, &80, &B0
 EQUB &00, &21, &05, &07, &40, &06, &39, &07
 EQUB &01, &00, &08, &01, &0B, &03, &1B, &00
 EQUB &23, &3F, &FF, &BF, &12, &FB, &FF, &FA
 EQUB &F9, &FA, &F9, &F2, &E1, &A0, &CC, &CB
 EQUB &C3, &E0, &F0, &F8, &7E, &03, &60, &6F
 EQUB &21, &0F, &04, &32, &01, &0D, &EC, &E0
 EQUB &02, &21, &0B, &67, &A6, &87, &33, &0E
 EQUB &1F, &3E, &FD, &BF, &FF, &BF, &21, &3F
 EQUB &BF, &21, &3F, &9F, &34, &0F, &02, &00
 EQUB &01, &05, &BF, &57, &33, &2A, &05, &12
 EQUB &03, &80, &F0, &AA, &5D, &8A, &21, &21
 EQUB &02, &32, &03, &1F, &AA, &75, &A2, &21
 EQUB &08, &02, &FA, &D4, &A9, &40, &90, &03
 EQUB &80, &07, &3F, &0F, &0F, &0F, &0F, &02
 EQUB &21, &01, &06, &E0, &50, &21, &2A, &05
 EQUB &32, &0E, &15, &A8, &0F, &0F, &02, &84
 EQUB &00, &21, &13, &02, &21, &01, &00, &21
 EQUB &01, &42, &00, &90, &0F, &0F, &21, &01
 EQUB &03, &32, &02, &01, &02, &32, &21, &01
 EQUB &02, &81, &C2, &81, &00, &21, &09, &03
 EQUB &21, &02, &87, &21, &02, &05, &80, &0F
 EQUB &0B, &22, &03, &06, &22, &80, &0F, &08
 EQUB &22, &FC, &15, &02, &A0, &E0, &A0, &F0
 EQUB &B0, &F0, &00, &21, &05, &07, &40, &08
 EQUB &36, &0A, &0F, &0B, &1F, &1B, &1F, &00
 EQUB &22, &7F, &1A, &22, &FB, &F7, &F8, &FE
 EQUB &EF, &EB, &F3, &FD, &12, &03, &EF, &7F
 EQUB &6F, &21, &0F, &F0, &02, &21, &01, &EF
 EQUB &FD, &ED, &E1, &32, &1F, &3F, &FF, &EF
 EQUB &AF, &9F, &7F, &17, &22, &BF, &DF, &E7
 EQUB &22, &0F, &57, &FB, &F1, &F8, &F1, &15
 EQUB &7F, &21, &2F, &56, &1F, &FE, &15, &FD
 EQUB &E8, &D5, &CF, &22, &E0, &D5, &BF, &33
 EQUB &1F, &3F, &1E, &3F

\ ******************************************************************************
\
\       Name: image4_2
\       Type: Variable
\   Category: Drawing images
\    Summary: Data for image 4 in group 2
\
\ ******************************************************************************

.image4_2

 EQUB &1B, &FE, &22, &FC, &E0, &C0, &12, &F7
 EQUB &20, &04, &12, &6F, &21, &07, &04, &14
 EQUB &34, &3F, &1F, &1F, &0F, &1F, &11, &C0
 EQUB &24, &80, &00, &21, &01, &06, &E0, &50
 EQUB &21, &2A, &05, &35, &0E, &15, &A8, &07
 EQUB &07, &23, &03, &23, &01, &1D, &FE, &22
 EQUB &FC, &08, &84, &00, &21, &0B, &02, &21
 EQUB &01, &00, &21, &01, &42, &00, &A0, &05
 EQUB &25, &01, &03, &16, &22, &7F, &22, &FC
 EQUB &22, &FE, &14, &22, &01, &03, &21, &02
 EQUB &81, &C0, &00, &32, &21, &01, &02, &81
 EQUB &C2, &81, &32, &01, &09, &03, &21, &02
 EQUB &87, &21, &02, &04, &21, &01, &81, &32
 EQUB &03, &07, &22, &7F, &1E, &28, &E0, &22
 EQUB &03, &06, &22, &80, &06, &28, &0F, &18
 EQUB &21, &01, &F9, &22, &F8, &FF, &FB, &12
 EQUB &C0, &02, &20, &00, &A0, &80, &B0, &00
 EQUB &21, &0B, &07, &A0, &06, &39, &07, &01
 EQUB &00, &08, &01, &0B, &03, &1B, &00, &23
 EQUB &3F, &FF, &BF, &12, &FB, &FF, &FA, &F9
 EQUB &FA, &F9, &F2, &E1, &A0, &CC, &CB, &C3
 EQUB &E0, &F0, &F8, &7E, &03, &60, &6F, &21
 EQUB &0F, &04, &32, &01, &0D, &EC, &E0, &02
 EQUB &21, &0B, &67, &A6, &87, &33, &0E, &1F
 EQUB &3E, &FD, &BF, &FF, &BF, &21, &3F, &BF
 EQUB &21, &3F, &9F, &34, &0F, &02, &00, &01
 EQUB &05, &BF, &57, &33, &2A, &05, &12, &03
 EQUB &80, &F0, &AA, &5D, &8A, &21, &21, &02
 EQUB &32, &03, &1F, &AA, &75, &A2, &21, &08
 EQUB &02, &FA, &D4, &A9, &40, &90, &03, &80
 EQUB &07, &3F, &0F, &0F, &0F, &0F, &02, &21
 EQUB &01, &06, &E0, &50, &21, &2A, &05, &32
 EQUB &0E, &15, &A8, &0F, &0F, &02, &84, &00
 EQUB &21, &0B, &02, &21, &01, &00, &21, &01
 EQUB &42, &00, &A0, &0F, &0E, &22, &01, &03
 EQUB &32, &02, &01, &02, &32, &21, &01, &02
 EQUB &81, &C2, &81, &32, &01, &09, &03, &21
 EQUB &02, &87, &21, &02, &05, &80, &0F, &0B
 EQUB &22, &03, &06, &22, &80, &0F, &08, &22
 EQUB &FC, &15, &02, &A0, &E0, &A0, &F0, &B0
 EQUB &F0, &00, &21, &0B, &07, &A0, &08, &36
 EQUB &0A, &0F, &0B, &1F, &1B, &1F, &00, &22
 EQUB &7F, &1A, &22, &FB, &F7, &F8, &FE, &EF
 EQUB &EB, &F3, &FD, &12, &03, &EF, &7F, &6F
 EQUB &21, &0F, &F0, &02, &21, &01, &EF, &FD
 EQUB &ED, &E1, &32, &1F, &3F, &FF, &EF, &AF
 EQUB &9F, &7F, &17, &22, &BF, &DF, &E7, &22
 EQUB &0F, &57, &FB, &F1, &F8, &F1, &15, &7F
 EQUB &21, &2F, &56, &1F, &FE, &15, &FD, &E8
 EQUB &D5, &CF, &22, &E0, &D5, &BF, &33, &1F
 EQUB &3F, &1E, &3F

\ ******************************************************************************
\
\       Name: image5_2
\       Type: Variable
\   Category: Drawing images
\    Summary: Data for image 5 in group 2
\
\ ******************************************************************************

.image5_2

 EQUB &1B, &FE, &22, &FC, &E0, &C0, &12, &F7
 EQUB &20, &04, &12, &6F, &21, &07, &04, &14
 EQUB &34, &3F, &1F, &1F, &0F, &1F, &11, &C0
 EQUB &24, &80, &00, &21, &01, &06, &E0, &50
 EQUB &21, &2A, &05, &35, &0E, &15, &A8, &07
 EQUB &07, &23, &03, &23, &01, &1D, &FE, &22
 EQUB &FC, &08, &21, &04, &02, &B0, &00, &22
 EQUB &01, &00, &40, &06, &31, &02, &25, &01
 EQUB &03, &16, &22, &7F, &22, &FC, &22, &FE
 EQUB &14, &04, &32, &02, &01, &80, &C0, &00
 EQUB &21, &01, &02, &81, &C2, &81, &33, &03
 EQUB &09, &09, &03, &82, &21, &07, &82, &04
 EQUB &21, &01, &81, &32, &03, &07, &22, &7F
 EQUB &1E, &28, &E0, &21, &03, &07, &80, &07
 EQUB &28, &0F, &18, &21, &01, &F9, &22, &F8
 EQUB &FF, &FB, &12, &C0, &02, &20, &00, &A0
 EQUB &80, &B0, &00, &21, &03, &07, &80, &06
 EQUB &39, &07, &01, &00, &08, &01, &0B, &03
 EQUB &1B, &00, &23, &3F, &FF, &BF, &12, &FB
 EQUB &FF, &FA, &F9, &FA, &F9, &F2, &E1, &A0
 EQUB &CC, &CB, &C3, &E0, &F0, &F8, &7E, &03
 EQUB &60, &6F, &21, &0F, &04, &32, &01, &0D
 EQUB &EC, &E0, &02, &21, &0B, &67, &A6, &87
 EQUB &33, &0E, &1F, &3E, &FD, &BF, &FF, &BF
 EQUB &21, &3F, &BF, &21, &3F, &9F, &34, &0F
 EQUB &02, &00, &01, &05, &BF, &57, &33, &2A
 EQUB &05, &12, &03, &80, &F0, &AA, &5D, &8A
 EQUB &21, &21, &02, &32, &03, &1F, &AA, &75
 EQUB &A2, &21, &08, &02, &FA, &D4, &A9, &40
 EQUB &90, &03, &80, &07, &3F, &0F, &0F, &0F
 EQUB &0F, &02, &21, &01, &06, &E0, &50, &21
 EQUB &2A, &05, &32, &0E, &15, &A8, &0F, &0F
 EQUB &02, &21, &04, &02, &B0, &00, &22, &01
 EQUB &00, &40, &06, &21, &02, &0F, &0D, &32
 EQUB &02, &01, &03, &21, &01, &02, &81, &C2
 EQUB &81, &33, &03, &09, &09, &03, &82, &21
 EQUB &07, &82, &05, &80, &0F, &0B, &21, &03
 EQUB &07, &80, &0F, &09, &22, &FC, &15, &02
 EQUB &A0, &E0, &A0, &F0, &B0, &F0, &00, &21
 EQUB &03, &07, &80, &08, &36, &0A, &0F, &0B
 EQUB &1F, &1B, &1F, &00, &22, &7F, &1A, &22
 EQUB &FB, &F7, &F8, &FE, &EF, &EB, &F3, &FD
 EQUB &12, &03, &EF, &7F, &6F, &21, &0F, &F0
 EQUB &02, &21, &01, &EF, &FD, &ED, &E1, &32
 EQUB &1F, &3F, &FF, &EF, &AF, &9F, &7F, &17
 EQUB &22, &BF, &DF, &E7, &22, &0F, &57, &FB
 EQUB &F1, &F8, &F1, &15, &7F, &21, &2F, &56
 EQUB &1F, &FE, &15, &FD, &E8, &D5, &CF, &22
 EQUB &E0, &D5, &BF, &33, &1F, &3F, &1E, &3F

\ ******************************************************************************
\
\       Name: image6_2
\       Type: Variable
\   Category: Drawing images
\    Summary: Data for image 6 in group 2
\
\ ******************************************************************************

.image6_2

 EQUB &1D, &FC, &F0, &E0, &13, &E0, &04, &13
 EQUB &32, &0F, &01, &03, &15, &7F, &32, &1F
 EQUB &0F, &1F, &11, &22, &C0, &23, &80, &00
 EQUB &21, &01, &06, &E0, &50, &21, &2A, &05
 EQUB &35, &0E, &15, &A8, &07, &07, &23, &03
 EQUB &23, &01, &1D, &FE, &22, &FC, &08, &21
 EQUB &04, &80, &21, &35, &02, &21, &01, &00
 EQUB &21, &01, &40, &21, &02, &58, &05, &25
 EQUB &01, &03, &16, &22, &7F, &22, &FC, &22
 EQUB &FE, &14, &00, &21, &01, &03, &21, &02
 EQUB &81, &C0, &00, &32, &21, &01, &02, &81
 EQUB &C2, &81, &00, &21, &09, &03, &21, &02
 EQUB &87, &21, &02, &04, &21, &01, &81, &32
 EQUB &03, &07, &22, &7F, &1C, &21, &01, &F9
 EQUB &28, &E0, &22, &03, &06, &22, &80, &06
 EQUB &28, &0F, &16, &00, &21, &3F, &F9, &22
 EQUB &F8, &FC, &FB, &13, &C0, &02, &20, &00
 EQUB &A0, &80, &B0, &00, &21, &05, &07, &40
 EQUB &06, &21, &07, &02, &35, &08, &01, &0B
 EQUB &03, &1B, &23, &3F, &7F, &BF, &13, &FB
 EQUB &FF, &FA, &F9, &FA, &F9, &F1, &E3, &A0
 EQUB &CC, &CB, &C3, &E0, &40, &FC, &FF, &03
 EQUB &60, &6F, &21, &0F, &00, &80, &02, &32
 EQUB &01, &0D, &EC, &E0, &00, &32, &03, &0B
 EQUB &67, &A6, &87, &32, &0E, &05, &7F, &FF
 EQUB &BF, &FF, &BF, &21, &3F, &BF, &33, &3F
 EQUB &1F, &8F, &23, &07, &24, &0F, &21, &07
 EQUB &18, &FC, &23, &FE, &FF, &FE, &12, &7F
 EQUB &1F, &23, &C0, &24, &E0, &C0, &3F, &0F
 EQUB &0F, &0F, &0F, &02, &21, &01, &06, &E0
 EQUB &50, &21, &2A, &05, &32, &0E, &15, &A8
 EQUB &0F, &0F, &02, &21, &04, &80, &21, &35
 EQUB &02, &21, &01, &00, &21, &01, &40, &21
 EQUB &02, &58, &0F, &0F, &21, &01, &03, &32
 EQUB &02, &01, &02, &32, &21, &01, &02, &81
 EQUB &C2, &81, &00, &21, &09, &03, &21, &02
 EQUB &87, &21, &02, &05, &80, &0F, &02, &FC
 EQUB &08, &22, &03, &06, &22, &80, &0F, &06
 EQUB &7F, &23, &FC, &15, &02, &A0, &E0, &A0
 EQUB &F0, &B0, &F0, &00, &21, &05, &07, &40
 EQUB &08, &36, &0A, &0F, &0B, &1F, &1B, &1F
 EQUB &23, &7F, &1A, &22, &FB, &F7, &F8, &FE
 EQUB &EF, &EB, &F3, &FD, &12, &03, &EF, &7F
 EQUB &6F, &21, &0F, &F0, &02, &21, &01, &EF
 EQUB &FD, &ED, &E1, &32, &1F, &3F, &FF, &EF
 EQUB &AF, &9F, &7F, &17, &22, &BF, &DF, &E7
 EQUB &22, &0F, &4F, &24, &EF, &1F, &1F, &12
 EQUB &CF, &22, &E0, &E5, &23, &EF, &EE, &3F

\ ******************************************************************************
\
\       Name: image7_2
\       Type: Variable
\   Category: Drawing images
\    Summary: Data for image 7 in group 2
\
\ ******************************************************************************

.image7_2

 EQUB &1D, &FC, &F0, &E0, &13, &E0, &04, &13
 EQUB &32, &0F, &01, &03, &15, &7F, &32, &1F
 EQUB &0F, &1F, &11, &22, &C0, &23, &80, &00
 EQUB &21, &01, &06, &E0, &50, &21, &2A, &05
 EQUB &35, &0E, &15, &A8, &07, &07, &23, &03
 EQUB &23, &01, &1D, &FE, &22, &FC, &08, &84
 EQUB &00, &21, &13, &02, &21, &01, &00, &21
 EQUB &01, &42, &00, &90, &05, &25, &01, &03
 EQUB &16, &22, &7F, &22, &FC, &22, &FE, &14
 EQUB &00, &21, &01, &03, &21, &02, &81, &C0
 EQUB &00, &32, &21, &01, &02, &81, &C2, &81
 EQUB &00, &21, &09, &03, &21, &02, &87, &21
 EQUB &02, &04, &21, &01, &81, &32, &03, &07
 EQUB &22, &7F, &1C, &21, &01, &F9, &28, &E0
 EQUB &22, &03, &06, &22, &80, &06, &28, &0F
 EQUB &16, &00, &21, &3F, &F9, &22, &F8, &FC
 EQUB &FB, &13, &C0, &02, &20, &00, &A0, &80
 EQUB &B0, &00, &21, &05, &07, &40, &06, &21
 EQUB &07, &02, &35, &08, &01, &0B, &03, &1B
 EQUB &23, &3F, &7F, &BF, &13, &FB, &FF, &FA
 EQUB &F9, &FA, &F9, &F1, &E3, &A0, &CC, &CB
 EQUB &C3, &E0, &40, &FC, &FF, &03, &60, &6F
 EQUB &21, &0F, &00, &80, &02, &32, &01, &0D
 EQUB &EC, &E0, &00, &32, &03, &0B, &67, &A6
 EQUB &87, &32, &0E, &05, &7F, &FF, &BF, &FF
 EQUB &BF, &21, &3F, &BF, &33, &3F, &1F, &8F
 EQUB &23, &07, &24, &0F, &21, &07, &18, &FC
 EQUB &23, &FE, &FF, &FE, &12, &7F, &1F, &23
 EQUB &C0, &24, &E0, &C0, &3F, &0F, &0F, &0F
 EQUB &0F, &02, &21, &01, &06, &E0, &50, &21
 EQUB &2A, &05, &32, &0E, &15, &A8, &0F, &0F
 EQUB &02, &84, &00, &21, &13, &02, &21, &01
 EQUB &00, &21, &01, &42, &00, &90, &0F, &0F
 EQUB &21, &01, &03, &32, &02, &01, &02, &32
 EQUB &21, &01, &02, &81, &C2, &81, &00, &21
 EQUB &09, &03, &21, &02, &87, &21, &02, &05
 EQUB &80, &0F, &02, &FC, &08, &22, &03, &06
 EQUB &22, &80, &0F, &06, &7F, &23, &FC, &15
 EQUB &02, &A0, &E0, &A0, &F0, &B0, &F0, &00
 EQUB &21, &05, &07, &40, &08, &36, &0A, &0F
 EQUB &0B, &1F, &1B, &1F, &23, &7F, &1A, &22
 EQUB &FB, &F7, &F8, &FE, &EF, &EB, &F3, &FD
 EQUB &12, &03, &EF, &7F, &6F, &21, &0F, &F0
 EQUB &02, &21, &01, &EF, &FD, &ED, &E1, &32
 EQUB &1F, &3F, &FF, &EF, &AF, &9F, &7F, &17
 EQUB &22, &BF, &DF, &E7, &22, &0F, &4F, &24
 EQUB &EF, &1F, &1F, &12, &CF, &22, &E0, &E5
 EQUB &23, &EF, &EE, &3F

\ ******************************************************************************
\
\       Name: image8_2
\       Type: Variable
\   Category: Drawing images
\    Summary: Data for image 8 in group 2
\
\ ******************************************************************************

.image8_2

 EQUB &1D, &FC, &F0, &E0, &13, &E0, &04, &13
 EQUB &32, &0F, &01, &03, &15, &7F, &32, &1F
 EQUB &0F, &1F, &11, &22, &C0, &23, &80, &00
 EQUB &21, &01, &06, &E0, &50, &21, &2A, &05
 EQUB &35, &0E, &15, &A8, &07, &07, &23, &03
 EQUB &23, &01, &1D, &FE, &22, &FC, &08, &21
 EQUB &04, &00, &81, &10, &00, &21, &01, &00
 EQUB &21, &01, &40, &00, &21, &02, &10, &04
 EQUB &25, &01, &03, &16, &22, &7F, &22, &FC
 EQUB &22, &FE, &14, &00, &21, &01, &03, &21
 EQUB &02, &81, &C0, &00, &32, &21, &01, &02
 EQUB &81, &C2, &81, &00, &21, &09, &03, &21
 EQUB &02, &87, &21, &02, &04, &21, &01, &81
 EQUB &32, &03, &07, &22, &7F, &16, &00, &27
 EQUB &FE, &23, &C0, &05, &22, &03, &06, &22
 EQUB &80, &06, &23, &06, &06, &17, &28, &FE
 EQUB &09, &21, &05, &02, &10, &32, &0B, &01
 EQUB &02, &40, &02, &10, &A0, &0A, &18, &22
 EQUB &FE, &FC, &F8, &F0, &E0, &C0, &21, &01
 EQUB &02, &21, &01, &02, &78, &12, &02, &FF
 EQUB &00, &7F, &21, &01, &00, &E0, &02, &FF
 EQUB &00, &FC, &00, &32, &01, &0F, &05, &21
 EQUB &3C, &FE, &13, &7F, &38, &3F, &1F, &0F
 EQUB &07, &00, &03, &07, &07, &23, &0F, &CF
 EQUB &21, &07, &18, &FC, &23, &FE, &FF, &FE
 EQUB &12, &7F, &1F, &80, &22, &C0, &23, &E0
 EQUB &E6, &C0, &3F, &0F, &0F, &0F, &0F, &02
 EQUB &21, &01, &06, &E0, &50, &21, &2A, &05
 EQUB &32, &0E, &15, &A8, &0F, &0F, &02, &21
 EQUB &04, &00, &81, &10, &00, &21, &01, &00
 EQUB &21, &01, &40, &00, &21, &02, &10, &0F
 EQUB &0E, &21, &01, &03, &32, &02, &01, &02
 EQUB &32, &21, &01, &02, &81, &C2, &81, &00
 EQUB &21, &09, &03, &21, &02, &87, &21, &02
 EQUB &05, &80, &0B, &27, &FE, &05, &40, &E0
 EQUB &40, &22, &03, &06, &22, &80, &0B, &33
 EQUB &04, &0E, &04, &00, &17, &28, &FE, &20
 EQUB &40, &00, &10, &05, &21, &05, &02, &10
 EQUB &32, &0B, &01, &02, &40, &02, &10, &A0
 EQUB &02, &32, &08, &04, &00, &10, &04, &18
 EQUB &24, &FE, &FC, &F8, &F1, &E3, &02, &57
 EQUB &00, &21, &01, &FC, &12, &02, &FF, &21
 EQUB &3F, &FF, &57, &8B, &F1, &02, &FF, &F8
 EQUB &FF, &D4, &A3, &21, &1F, &02, &D4, &02
 EQUB &7E, &16, &7F, &32, &3F, &1F, &8F, &C7
 EQUB &23, &0F, &23, &EF, &CF, &1F, &1F, &12
 EQUB &C7, &23, &E0, &23, &EF, &E6, &3F

\ ******************************************************************************
\
\       Name: image9_2
\       Type: Variable
\   Category: Drawing images
\    Summary: Data for image 9 in group 2
\
\ ******************************************************************************

.image9_2

 EQUB &1B, &FE, &22, &FC, &E0, &C0, &12, &F7
 EQUB &20, &04, &12, &6F, &21, &03, &04, &14
 EQUB &34, &3F, &1F, &1F, &0F, &1F, &11, &C0
 EQUB &24, &80, &00, &21, &01, &06, &E0, &50
 EQUB &21, &2A, &05, &37, &0E, &15, &A8, &07
 EQUB &07, &03, &03, &24, &01, &1D, &FE, &22
 EQUB &FC, &08, &21, &04, &22, &80, &50, &00
 EQUB &22, &01, &00, &40, &00, &32, &02, &14
 EQUB &04, &23, &01, &81, &21, &01, &03, &16
 EQUB &22, &7F, &22, &FC, &22, &FE, &14, &00
 EQUB &21, &01, &03, &21, &02, &81, &C0, &33
 EQUB &01, &21, &01, &02, &81, &C2, &81, &00
 EQUB &21, &09, &03, &21, &02, &87, &21, &02
 EQUB &04, &21, &01, &81, &32, &03, &07, &22
 EQUB &7F, &16, &00, &27, &FE, &23, &C0, &05
 EQUB &22, &03, &06, &22, &80, &06, &23, &06
 EQUB &06, &17, &28, &FE, &09, &21, &05, &07
 EQUB &40, &0E, &18, &22, &FE, &FC, &F8, &F0
 EQUB &E0, &C0, &03, &21, &01, &07, &FF, &00
 EQUB &7F, &21, &01, &04, &FF, &00, &FC, &0B
 EQUB &12, &7F, &34, &3F, &1F, &0F, &07, &04
 EQUB &22, &01, &00, &C2, &02, &21, &01, &60
 EQUB &F8, &32, &04, &01, &04, &60, &32, &1F
 EQUB &03, &04, &32, &01, &0C, &F0, &80, &21
 EQUB &01, &04, &32, &0C, &3F, &41, &09, &86
 EQUB &00, &3F, &0F, &0F, &0F, &0F, &02, &21
 EQUB &01, &06, &E0, &50, &21, &2A, &05, &32
 EQUB &0E, &15, &A8, &0F, &0F, &02, &21, &04
 EQUB &22, &80, &50, &00, &22, &01, &00, &40
 EQUB &00, &32, &02, &14, &07, &80, &0F, &06
 EQUB &21, &01, &03, &36, &02, &01, &00, &01
 EQUB &21, &01, &02, &81, &C2, &81, &00, &21
 EQUB &09, &03, &21, &02, &87, &21, &02, &05
 EQUB &80, &0B, &27, &FE, &05, &40, &E0, &40
 EQUB &22, &03, &06, &22, &80, &0B, &33, &04
 EQUB &0E, &04, &00, &17, &28, &FE, &20, &40
 EQUB &00, &10, &05, &21, &05, &07, &40, &06
 EQUB &32, &08, &04, &00, &10, &04, &18, &24
 EQUB &FE, &FC, &F8, &F0, &E0, &02, &57, &00
 EQUB &32, &0B, &02, &20, &10, &02, &FF, &21
 EQUB &3F, &FF, &57, &8B, &21, &01, &02, &FF
 EQUB &F8, &FF, &D4, &A2, &03, &D4, &00, &A0
 EQUB &80, &21, &08, &10, &14, &7F, &33, &3F
 EQUB &1F, &0F, &C0, &00, &32, &01, &03, &E3
 EQUB &22, &E7, &C7, &21, &0C, &67, &FB, &FD
 EQUB &14, &00, &80, &F8, &FF, &BF, &FF, &F4
 EQUB &FE, &00, &32, &03, &3F, &FF, &FB, &FF
 EQUB &5F, &FF, &60, &CC, &BF, &7F, &14, &21
 EQUB &07, &02, &80, &8F, &22, &CF, &C6, &3F

\ ******************************************************************************
\
\       Name: image10_2
\       Type: Variable
\   Category: Drawing images
\    Summary: Data for image 10 in group 2
\
\ ******************************************************************************

.image10_2

 EQUB &1A, &FE, &22, &FC, &22, &F0, &E0, &12
 EQUB &21, &34, &05, &FF, &6F, &21, &07, &05
 EQUB &13, &31, &3F, &23, &1F, &21, &0F, &1F
 EQUB &11, &C0, &C2, &85, &80, &33, &05, &02
 EQUB &01, &04, &80, &40, &E0, &50, &21, &2A
 EQUB &04, &36, &01, &0E, &15, &A8, &07, &07
 EQUB &43, &A3, &C1, &81, &22, &01, &1D, &FE
 EQUB &22, &FC, &08, &21, &04, &22, &80, &50
 EQUB &00, &22, &01, &00, &40, &00, &32, &02
 EQUB &14, &04, &23, &01, &81, &21, &01, &03
 EQUB &16, &22, &7F, &22, &FC, &22, &FE, &14
 EQUB &00, &21, &01, &03, &21, &02, &81, &C0
 EQUB &33, &01, &21, &01, &02, &81, &C2, &81
 EQUB &00, &21, &09, &03, &21, &02, &87, &21
 EQUB &02, &04, &21, &01, &81, &32, &03, &07
 EQUB &22, &7F, &16, &00, &21, &04, &22, &FE
 EQUB &23, &04, &00, &23, &C0, &05, &22, &03
 EQUB &06, &22, &80, &06, &23, &06, &06, &40
 EQUB &12, &23, &40, &00, &21, &04, &02, &21
 EQUB &04, &0D, &21, &05, &07, &40, &0E, &40
 EQUB &02, &40, &0E, &21, &01, &07, &FF, &00
 EQUB &7F, &21, &01, &04, &FF, &00, &FC, &0F
 EQUB &07, &22, &01, &00, &21, &02, &02, &21
 EQUB &01, &60, &F8, &32, &04, &01, &04, &60
 EQUB &32, &1F, &03, &04, &32, &01, &0C, &F0
 EQUB &80, &21, &01, &04, &32, &0C, &3F, &41
 EQUB &09, &80, &00, &3F, &0F, &0F, &0F, &0C
 EQUB &36, &02, &05, &00, &05, &02, &01, &04
 EQUB &80, &40, &E0, &50, &21, &2A, &04, &33
 EQUB &01, &0E, &15, &A8, &02, &40, &A0, &C0
 EQUB &80, &0F, &0B, &21, &04, &22, &80, &50
 EQUB &00, &22, &01, &00, &40, &00, &32, &02
 EQUB &14, &07, &80, &0F, &06, &21, &01, &03
 EQUB &36, &02, &01, &00, &01, &21, &01, &02
 EQUB &81, &C2, &81, &00, &21, &09, &03, &21
 EQUB &02, &87, &21, &02, &05, &80, &0B, &27
 EQUB &FE, &05, &40, &E0, &40, &22, &03, &06
 EQUB &22, &80, &0B, &33, &04, &0E, &04, &00
 EQUB &17, &28, &FE, &20, &40, &00, &10, &05
 EQUB &21, &05, &07, &40, &06, &32, &08, &04
 EQUB &00, &10, &04, &18, &22, &FE, &F0, &C0
 EQUB &21, &06, &10, &40, &80, &02, &57, &00
 EQUB &32, &0B, &02, &20, &10, &02, &FF, &21
 EQUB &1F, &FF, &57, &8B, &21, &01, &02, &FF
 EQUB &F8, &FF, &D4, &A2, &03, &D4, &00, &A0
 EQUB &80, &21, &08, &10, &12, &32, &1F, &07
 EQUB &C1, &10, &32, &04, &02, &02, &33, &01
 EQUB &03, &03, &87, &22, &C7, &21, &0C, &67
 EQUB &FB, &FD, &14, &00, &80, &F8, &FF, &BF
 EQUB &FF, &F4, &FE, &00, &32, &03, &3F, &FF
 EQUB &FB, &FF, &5F, &FF, &60, &CC, &BF, &7F
 EQUB &14, &21, &01, &02, &22, &80, &C3, &22
 EQUB &C7, &3F

\ ******************************************************************************
\
\       Name: image11_2
\       Type: Variable
\   Category: Drawing images
\    Summary: Data for image 11 in group 2
\
\ ******************************************************************************

.image11_2

 EQUB &1D, &FC, &F0, &E0, &13, &E0, &04, &13
 EQUB &32, &0F, &01, &03, &15, &7F, &32, &1F
 EQUB &0F, &1F, &11, &22, &C0, &23, &80, &00
 EQUB &21, &01, &06, &E0, &50, &21, &2A, &05
 EQUB &35, &0E, &14, &A8, &07, &07, &23, &03
 EQUB &23, &01, &1D, &FE, &22, &FC, &08, &21
 EQUB &04, &22, &80, &50, &00, &22, &01, &00
 EQUB &40, &02, &21, &14, &04, &22, &01, &22
 EQUB &41, &21, &01, &03, &16, &22, &7F, &22
 EQUB &FC, &22, &FE, &14, &00, &21, &01, &03
 EQUB &21, &02, &81, &C0, &33, &03, &21, &01
 EQUB &02, &81, &C2, &81, &80, &21, &09, &04
 EQUB &86, &21, &02, &04, &21, &01, &81, &32
 EQUB &03, &07, &22, &7F, &16, &00, &21, &04
 EQUB &22, &FE, &23, &04, &00, &23, &C0, &05
 EQUB &22, &03, &06, &22, &80, &06, &23, &06
 EQUB &06, &40, &12, &23, &40, &00, &21, &04
 EQUB &02, &21, &04, &0D, &21, &0B, &02, &10
 EQUB &32, &0B, &01, &02, &A0, &02, &10, &A0
 EQUB &0A, &40, &02, &40, &0E, &21, &01, &07
 EQUB &FF, &00, &7F, &21, &01, &04, &FF, &00
 EQUB &FC, &0F, &0D, &21, &01, &08, &60, &32
 EQUB &1F, &03, &04, &32, &01, &0C, &F0, &80
 EQUB &0F, &04, &3F, &0F, &0F, &0F, &0F, &02
 EQUB &21, &01, &06, &E0, &50, &21, &2A, &05
 EQUB &32, &0E, &14, &A8, &0F, &0F, &02, &21
 EQUB &04, &22, &80, &50, &00, &22, &01, &00
 EQUB &40, &02, &21, &14, &06, &22, &40, &0F
 EQUB &06, &21, &01, &03, &36, &02, &01, &00
 EQUB &03, &21, &01, &02, &81, &C2, &81, &80
 EQUB &21, &09, &04, &86, &21, &02, &05, &80
 EQUB &0B, &27, &FE, &05, &40, &E0, &40, &22
 EQUB &03, &06, &22, &80, &0B, &33, &04, &0E
 EQUB &04, &00, &17, &28, &FE, &20, &40, &00
 EQUB &10, &05, &21, &0B, &02, &10, &32, &0B
 EQUB &01, &02, &A0, &02, &10, &A0, &02, &32
 EQUB &08, &04, &00, &10, &04, &18, &22, &FE
 EQUB &F0, &C0, &21, &06, &10, &40, &80, &02
 EQUB &57, &00, &32, &0B, &02, &20, &10, &02
 EQUB &FF, &21, &1F, &FF, &57, &8B, &21, &01
 EQUB &02, &FF, &F8, &FF, &D4, &A2, &03, &D4
 EQUB &00, &A0, &80, &21, &08, &10, &12, &32
 EQUB &1F, &07, &C1, &10, &32, &04, &02, &08
 EQUB &35, &0C, &07, &0B, &01, &04, &04, &80
 EQUB &F8, &7F, &BF, &21, &15, &03, &32, &03
 EQUB &3F, &FD, &FA, &50, &02, &60, &C0, &A0
 EQUB &00, &40, &03, &21, &01, &07, &3F

\ ******************************************************************************
\
\       Name: image12_2
\       Type: Variable
\   Category: Drawing images
\    Summary: Data for image 12 in group 2
\
\ ******************************************************************************

.image12_2

 EQUB &1D, &FC, &F0, &E0, &13, &E0, &04, &13
 EQUB &32, &0F, &01, &03, &15, &7F, &32, &1F
 EQUB &0F, &1F, &11, &22, &C0, &23, &80, &00
 EQUB &21, &01, &06, &E0, &50, &21, &2A, &05
 EQUB &35, &0E, &14, &A8, &07, &07, &23, &03
 EQUB &23, &01, &1D, &FE, &22, &FC, &03, &21
 EQUB &01, &04, &21, &04, &80, &02, &C0, &32
 EQUB &11, &01, &00, &40, &03, &21, &08, &10
 EQUB &02, &22, &01, &22, &41, &21, &01, &03
 EQUB &16, &22, &7F, &22, &FC, &22, &FE, &14
 EQUB &00, &21, &01, &03, &21, &02, &81, &C0
 EQUB &35, &03, &01, &01, &00, &02, &81, &C3
 EQUB &83, &80, &21, &01, &02, &80, &00, &86
 EQUB &82, &04, &21, &01, &81, &32, &03, &07
 EQUB &22, &7F, &16, &00, &D2, &02, &21, &02
 EQUB &00, &22, &02, &23, &C0, &0F, &06, &23
 EQUB &06, &06, &96, &02, &80, &00, &22, &80
 EQUB &33, &02, &06, &06, &23, &02, &00, &21
 EQUB &02, &09, &32, &01, &03, &07, &80, &0D
 EQUB &80, &22, &C0, &23, &80, &00, &80, &04
 EQUB &21, &02, &05, &21, &01, &07, &FF, &00
 EQUB &7F, &21, &01, &04, &FF, &00, &FC, &0F
 EQUB &80, &0C, &21, &01, &08, &60, &32, &1F
 EQUB &03, &04, &32, &01, &0C, &F0, &80, &0F
 EQUB &04, &3F, &0F, &0F, &0F, &0F, &01, &30
 EQUB &61, &06, &E0, &50, &21, &2A, &05, &32
 EQUB &0E, &14, &A8, &05, &32, &18, &0C, &0F
 EQUB &02, &40, &00, &40, &21, &01, &04, &21
 EQUB &04, &80, &02, &C0, &32, &11, &01, &00
 EQUB &40, &03, &21, &08, &10, &02, &21, &04
 EQUB &00, &44, &40, &0F, &06, &21, &01, &03
 EQUB &38, &02, &01, &00, &03, &01, &01, &00
 EQUB &02, &81, &C3, &83, &80, &21, &01, &02
 EQUB &80, &00, &86, &82, &05, &80, &0B, &FE
 EQUB &F6, &AA, &46, &33, &12, &06, &0E, &05
 EQUB &40, &E0, &40, &0F, &06, &33, &04, &0E
 EQUB &04, &00, &FF, &DE, &AA, &C4, &90, &C0
 EQUB &E0, &38, &06, &0E, &0E, &06, &0E, &06
 EQUB &02, &06, &20, &40, &00, &10, &05, &32
 EQUB &01, &03, &07, &80, &05, &32, &08, &04
 EQUB &00, &10, &04, &C0, &22, &E0, &C0, &E0
 EQUB &C0, &80, &C0, &24, &02, &21, &0E, &20
 EQUB &00, &80, &02, &57, &00, &32, &0B, &02
 EQUB &20, &10, &02, &FF, &21, &1F, &FF, &57
 EQUB &8B, &21, &01, &02, &FF, &F8, &FF, &D4
 EQUB &A2, &03, &D4, &00, &A0, &80, &21, &08
 EQUB &10, &24, &80, &E0, &21, &08, &00, &21
 EQUB &02, &08, &35, &0C, &07, &0B, &01, &04
 EQUB &04, &80, &F8, &7F, &BF, &21, &15, &03
 EQUB &32, &03, &3F, &FD, &FA, &50, &02, &60
 EQUB &C0, &A0, &00, &40, &0B, &3F

\ ******************************************************************************
\
\       Name: image13_2
\       Type: Variable
\   Category: Drawing images
\    Summary: Data for image 13 in group 2
\
\ ******************************************************************************

.image13_2

 EQUB &1B, &FE, &22, &FC, &E0, &C0, &12, &F7
 EQUB &20, &04, &12, &6F, &21, &03, &04, &14
 EQUB &34, &3F, &1F, &1F, &0F, &1F, &11, &C0
 EQUB &24, &80, &00, &21, &01, &06, &E0, &50
 EQUB &21, &2A, &05, &37, &0E, &14, &A8, &07
 EQUB &07, &03, &03, &24, &01, &1D, &FE, &22
 EQUB &FC, &08, &21, &04, &03, &50, &22, &01
 EQUB &00, &40, &03, &21, &14, &03, &22, &01
 EQUB &22, &41, &21, &01, &03, &16, &22, &7F
 EQUB &22, &FC, &22, &FE, &14, &00, &21, &01
 EQUB &03, &21, &02, &81, &C0, &33, &03, &21
 EQUB &01, &02, &82, &C1, &83, &80, &21, &09
 EQUB &03, &80, &21, &06, &82, &04, &21, &01
 EQUB &81, &32, &03, &07, &22, &7F, &16, &00
 EQUB &D2, &02, &21, &02, &00, &22, &02, &23
 EQUB &C0, &05, &21, &03, &06, &21, &01, &80
 EQUB &07, &23, &06, &06, &96, &02, &80, &00
 EQUB &22, &80, &33, &02, &06, &06, &23, &02
 EQUB &00, &21, &02, &09, &21, &0B, &07, &A0
 EQUB &0E, &80, &22, &C0, &23, &80, &00, &80
 EQUB &04, &21, &02, &05, &21, &01, &07, &FF
 EQUB &00, &7F, &21, &01, &04, &FF, &00, &FC
 EQUB &0F, &80, &03, &22, &04, &34, &1F, &0E
 EQUB &0A, &11, &03, &21, &01, &08, &60, &32
 EQUB &1F, &03, &04, &32, &01, &0C, &F0, &80
 EQUB &05, &21, &01, &02, &21, &01, &02, &22
 EQUB &40, &F0, &E0, &A0, &10, &02, &3F, &0F
 EQUB &0F, &0F, &0F, &02, &21, &01, &06, &E0
 EQUB &50, &21, &2A, &05, &32, &0E, &14, &A8
 EQUB &0F, &0F, &02, &21, &04, &03, &50, &22
 EQUB &01, &00, &40, &03, &21, &14, &05, &22
 EQUB &40, &0F, &06, &21, &01, &03, &36, &02
 EQUB &01, &00, &03, &21, &01, &02, &82, &C1
 EQUB &83, &80, &21, &09, &03, &80, &21, &06
 EQUB &82, &05, &80, &0B, &FE, &F6, &AA, &46
 EQUB &33, &12, &06, &0E, &05, &40, &E0, &40
 EQUB &21, &03, &06, &21, &01, &80, &0C, &33
 EQUB &04, &0E, &04, &00, &FF, &DE, &AA, &C4
 EQUB &90, &C0, &E0, &38, &06, &0E, &0E, &06
 EQUB &0E, &06, &02, &06, &20, &40, &00, &10
 EQUB &05, &21, &0B, &07, &A0, &06, &32, &08
 EQUB &04, &00, &10, &04, &C0, &22, &E0, &C0
 EQUB &E0, &C0, &80, &C0, &24, &02, &21, &0E
 EQUB &20, &00, &84, &02, &57, &00, &32, &0B
 EQUB &02, &20, &10, &02, &FF, &21, &1F, &FF
 EQUB &57, &8B, &21, &01, &02, &FF, &F8, &FF
 EQUB &D4, &A2, &03, &D4, &00, &A0, &80, &21
 EQUB &08, &10, &24, &80, &E0, &21, &08, &00
 EQUB &42, &3D, &15, &04, &3F, &0E, &1F, &11
 EQUB &04, &00, &0C, &07, &8B, &01, &04, &04
 EQUB &80, &F8, &7F, &BF, &21, &15, &03, &32
 EQUB &03, &3F, &FD, &FA, &50, &02, &61, &C0
 EQUB &A3, &00, &41, &21, &01, &02, &50, &40
 EQUB &F8, &E0, &F0, &10, &40, &00, &3F

\ ******************************************************************************
\
\       Name: LAA9F
\       Type: Variable
\   Category: Drawing images
\    Summary: ???
\
\ ******************************************************************************

.LAA9F

 EQUB &02, &7F, &7B, &34, &17, &1F, &1F, &0F
 EQUB &03, &32, &0C, &08, &05, &12, &22, &E3
 EQUB &41, &80, &06, &80, &03, &FF, &BF, &7C
 EQUB &FC, &F4, &F8, &03, &C0, &80, &00, &21
 EQUB &08, &00, &31, &02, &23, &07, &32, &05
 EQUB &02, &03, &24, &02, &03, &20, &23, &70
 EQUB &50, &20, &03, &24, &20, &0A, &40, &0F
 EQUB &21, &01, &09, &20, &40, &30, &34, &28
 EQUB &14, &0F, &05, &22, &40, &22, &20, &10
 EQUB &33, &08, &04, &03, &07, &FF, &09, &35
 EQUB &02, &01, &06, &0A, &14, &78, &D0, &22
 EQUB &01, &22, &02, &32, &04, &08, &10, &60
 EQUB &32, &03, &01, &07, &21, &01, &06, &63
 EQUB &D5, &77, &5D, &32, &22, &1C, &02, &DD
 EQUB &22, &36, &32, &3E, &1C, &03, &60, &C0
 EQUB &06, &80, &40, &06, &3F

\ ******************************************************************************
\
\       Name: LAB1C
\       Type: Variable
\   Category: Drawing images
\    Summary: ???
\
\ ******************************************************************************

.LAB1C

 EQUB &08, &40, &90, &68, &54, &21, &26, &59
 EQUB &DA, &21, &2E, &04, &80, &40, &A0, &D0
 EQUB &03, &35, &01, &03, &0A, &00, &21, &10
 EQUB &48, &68, &D4, &B0, &40, &B4, &A4, &21
 EQUB &37, &F5, &DF, &FB, &7F, &FF, &21, &1F
 EQUB &7F, &60, &D8, &22, &FC, &12, &F7, &FB
 EQUB &05, &20, &D0, &68, &02, &21, &01, &02
 EQUB &32, &0D, &3A, &65, &76, &AA, &9B, &65
 EQUB &6D, &9B, &BF, &67, &60, &D4, &70, &BC
 EQUB &FC, &70, &F8, &F0, &37, &3F, &19, &1E
 EQUB &0D, &06, &05, &01, &00, &4D, &F6, &9A
 EQUB &ED, &21, &35, &D7, &99, &4B, &30, &D2
 EQUB &DC, &21, &2E, &EB, &57, &B1, &6E, &04
 EQUB &A0, &00, &C8, &D4, &03, &33, &06, &15
 EQUB &2A, &46, &9B, &8D, &21, &33, &5D, &66
 EQUB &BB, &DF, &EF, &BF, &7D, &B7, &BF, &FF
 EQUB &FD, &F8, &F0, &C8, &A0, &22, &C0, &80
 EQUB &04, &3A, &24, &1B, &0D, &06, &01, &04
 EQUB &05, &0E, &D6, &35, &CF, &72, &5D, &CD
 EQUB &66, &21, &3A, &62, &B8, &5E, &EB, &AD
 EQUB &B7, &DA, &6F, &04, &22, &C4, &F6, &FF
 EQUB &05, &38, &01, &02, &06, &02, &01, &0E
 EQUB &15, &2B, &FF, &7F, &FF, &DD, &6F, &F7
 EQUB &BF, &FB, &DF, &FF, &FE, &FF, &7F, &FC
 EQUB &FB, &EE, &DE, &BF, &FA, &10, &23, &80
 EQUB &04, &21, &0D, &02, &21, &18, &00, &21
 EQUB &08, &02, &36, &31, &04, &41, &04, &00
 EQUB &02, &02, &AD, &97, &21, &37, &4A, &BB
 EQUB &21, &0D, &57, &92, &FD, &7F, &F7, &FF
 EQUB &FB, &F7, &EF, &FF, &02, &80, &C0, &F0
 EQUB &F8, &D6, &7B, &05, &36, &01, &03, &07
 EQUB &03, &05, &2B, &53, &7F, &FD, &F7, &BE
 EQUB &BF, &9F, &FC, &FE, &B6, &BB, &BA, &B5
 EQUB &F6, &9B, &E9, &9C, &66, &58, &A2, &21
 EQUB &28, &FF, &61, &81, &92, &00, &81, &00
 EQUB &21, &03, &22, &80, &00, &23, &80, &02
 EQUB &31, &08, &23, &04, &33, &02, &03, &01
 EQUB &06, &21, &08, &20, &82, &38, &2B, &0D
 EQUB &43, &15, &09, &02, &04, &03, &FF, &FE
 EQUB &77, &FF, &7F, &12, &7F, &ED, &BA, &DD
 EQUB &6A, &F6, &5B, &ED, &FD, &22, &80, &C0
 EQUB &E0, &B8, &44, &B3, &51, &07, &80, &04
 EQUB &40, &60, &40, &50, &04, &22, &10, &22
 EQUB &30, &04, &37, &01, &03, &0A, &17, &04
 EQUB &0F, &3F, &F5, &9F, &6B, &6F, &7F, &EF
 EQUB &FD, &7C, &FA, &F0, &E4, &C0, &93, &32
 EQUB &35, &3A, &6A, &74, &73, &CC, &F1, &C8
 EQUB &40, &90, &40, &20, &02, &80, &37, &01
 EQUB &09, &01, &05, &0A, &0B, &26, &9E, &48
 EQUB &00, &80, &06, &50, &64, &21, &31, &10
 EQUB &33, &0E, &02, &01, &03, &21, &02, &00
 EQUB &80, &02, &80, &FF, &21, &3F, &DF, &21
 EQUB &37, &9D, &21, &2D, &4A, &21, &1B, &FB
 EQUB &7E, &FF, &BF, &FF, &E7, &FF, &7B, &AD
 EQUB &AA, &D3, &75, &DC, &EB, &FE, &F7, &22
 EQUB &C0, &40, &A8, &F0, &9E, &EF, &74, &23
 EQUB &30, &21, &12, &52, &21, &31, &20, &21
 EQUB &23, &23, &40, &23, &60, &40, &20, &03
 EQUB &23, &01, &33, &03, &0F, &3B, &72, &EE
 EQUB &F7, &BB, &21, &3F, &77, &7F, &BE, &FE
 EQUB &D9, &F4, &F0, &C0, &83, &21, &04, &47
 EQUB &33, &1B, &26, &2C, &98, &B8, &64, &D0
 EQUB &A2, &B0, &80, &C8, &20, &00, &40, &C1
 EQUB &37, &01, &0A, &05, &26, &1B, &CA, &26
 EQUB &8C, &70, &B0, &F0, &C0, &04, &40, &60
 EQUB &21, &18, &D6, &C2, &21, &01, &C0, &88
 EQUB &38, &21, &15, &08, &0A, &00, &09, &00
 EQUB &04, &FF, &BE, &DF, &D7, &7B, &21, &2F
 EQUB &B5, &21, &2B, &FD, &FF, &FE, &DF, &13
 EQUB &CF, &9B, &ED, &DF, &B3, &ED, &7B, &ED
 EQUB &F6, &23, &80, &40, &60, &C0, &E0, &60
 EQUB &D0, &F0, &E5, &73, &34, &2F, &17, &0E
 EQUB &1F, &70, &F0, &60, &30, &20, &22, &C0
 EQUB &40, &34, &1E, &0B, &2E, &13, &7F, &6D
 EQUB &32, &2F, &2B, &FE, &FC, &B9, &22, &F4
 EQUB &F0, &22, &E8, &4D, &32, &13, &36, &5D
 EQUB &68, &5B, &78, &92, &90, &69, &80, &B1
 EQUB &41, &39, &02, &0E, &04, &05, &13, &0A
 EQUB &05, &34, &16, &5D, &6D, &30, &60, &F0
 EQUB &60, &30, &78, &D0, &B8, &A0, &C1, &21
 EQUB &24, &88, &10, &40, &48, &30, &00, &32
 EQUB &02, &01, &00, &81, &00, &21, &02, &80
 EQUB &56, &35, &13, &09, &06, &81, &05, &40
 EQUB &A1, &F7, &7B, &EF, &EB, &55, &D6, &21
 EQUB &2B, &95, &DB, &22, &FD, &F7, &FE, &FB
 EQUB &BF, &FD, &70, &60, &25, &E0, &C0, &03
 EQUB &21, &0E, &04, &32, &0F, &0C, &43, &64
 EQUB &32, &13, &3B, &BB, &45, &80, &B0, &A8
 EQUB &21, &13, &F8, &F0, &D0, &00, &6F, &77
 EQUB &7F, &77, &7F, &33, &37, &2E, &1B, &F0
 EQUB &C5, &B0, &D0, &60, &98, &C2, &E8, &23
 EQUB &50, &A0, &21, &32, &61, &21, &19, &BE
 EQUB &32, &0C, &21, &58, &B2, &E5, &21, &21
 EQUB &CC, &32, &07, &36, &6A, &6F, &DD, &73
 EQUB &BE, &ED, &5B, &22, &F0, &D8, &78, &22
 EQUB &E0, &F0, &C0, &36, &34, &11, &0C, &06
 EQUB &03, &01, &03, &21, &01, &00, &40, &21
 EQUB &01, &60, &90, &48, &30, &4E, &57, &B5
 EQUB &21, &2F, &5E, &47, &21, &37, &A6, &5E
 EQUB &35, &13, &2D, &26, &15, &0B, &81, &FB
 EQUB &12, &7B, &12, &7D, &FE, &23, &80, &04
 EQUB &C0, &03, &21, &1F, &71, &36, &08, &03
 EQUB &05, &3D, &11, &04, &77, &F0, &32, &0F
 EQUB &03, &42, &20, &80, &20, &F6, &FF, &89
 EQUB &00, &40, &03, &C0, &80, &03, &22, &0B
 EQUB &36, &0F, &0D, &0B, &07, &07, &0F, &90
 EQUB &64, &D0, &D4, &A8, &E8, &44, &50, &21
 EQUB &3D, &48, &34, &18, &38, &2E, &3E, &7E
 EQUB &58, &21, &11, &4C, &21, &27, &91, &21
 EQUB &28, &4E, &32, &11, &05, &BF, &EF, &21
 EQUB &37, &DF, &BA, &B4, &68, &D0, &60, &22
 EQUB &80, &05, &3C, &38, &18, &0E, &06, &03
 EQUB &02, &07, &0A, &13, &4B, &09, &1F, &58
 EQUB &E4, &21, &26, &C6, &32, &0D, &03, &8B
 EQUB &CF, &F8, &00, &44, &FF, &BF, &7F, &FB
 EQUB &FE, &32, &0F, &1B, &9F, &CF, &60, &A2
 EQUB &B9, &FB, &46, &33, &25, &37, &37, &10
 EQUB &93, &59, &68, &DC, &F6, &BA, &EF, &8F
 EQUB &BD, &BF, &FF, &DC, &C7, &55, &21, &05
 EQUB &E1, &F1, &E2, &F2, &BF, &68, &D0, &D7
 EQUB &21, &12, &B3, &21, &02, &DB, &FF, &30
 EQUB &00, &E9, &22, &77, &5F, &FE, &83, &32
 EQUB &02, &03, &FB, &E8, &88, &61, &21, &32
 EQUB &A7, &20, &00, &21, &02, &78, &21, &3E
 EQUB &D4, &80, &FE, &02, &DA, &33, &22, &0A
 EQUB &05, &50, &C3, &42, &52, &49, &60, &C0
 EQUB &80, &06, &21, &01, &06, &21, &2A, &40
 EQUB &FB, &03, &32, &3F, &0F, &55, &80, &FF
 EQUB &03, &FF, &EB, &32, &01, &06, &80, &03
 EQUB &EC, &21, &31, &E6, &E7, &31, &27, &23
 EQUB &07, &77, &21, &17, &22, &80, &5F, &00
 EQUB &FF, &7F, &22, &80, &34, &16, &08, &F6
 EQUB &08, &E8, &EE, &37, &0C, &07, &32, &33
 EQUB &73, &3A, &3A, &BA, &22, &BB, &FF, &FE
 EQUB &F4, &02, &F7, &E0, &F8, &37, &15, &05
 EQUB &9C, &0E, &14, &96, &0E, &4E, &22, &80
 EQUB &02, &80, &00, &40, &5F, &3B, &18, &0A
 EQUB &2A, &0C, &0A, &2C, &0E, &CC, &03, &02
 EQUB &01, &02, &21, &25, &84, &F4, &10, &D4
 EQUB &94, &35, &18, &1F, &1F, &18, &1C, &92
 EQUB &00, &4D, &21, &1D, &FF, &FE, &02, &21
 EQUB &25, &5B, &7B, &02, &40, &41, &C0, &FF
 EQUB &40, &A4, &03, &9D, &00, &FF, &21, &0A
 EQUB &04, &FF, &47, &E0, &20, &10, &03, &F0
 EQUB &40, &21, &06, &07, &9D, &03, &34, &37
 EQUB &0D, &02, &01, &40, &03, &FD, &BF, &FF
 EQUB &FB, &34, &07, &03, &07, &0B, &A7, &60
 EQUB &22, &C0, &02, &13, &03, &32, &1E, &08
 EQUB &F8, &F0, &FB, &36, &02, &0C, &08, &3B
 EQUB &3C, &1F, &5F, &7F, &22, &80, &00, &F3
 EQUB &21, &0E, &13, &03, &56, &21, &06, &22
 EQUB &8E, &9E, &03, &E0, &4B, &00, &80, &96
 EQUB &21, &3F, &7F, &7E, &21, &0F, &8F, &32
 EQUB &1E, &1C, &8E, &03, &94, &FF, &02, &21
 EQUB &32, &FE, &7E, &FF, &33, &1C, &1B, &1F
 EQUB &FF, &7F, &03, &A6, &21, &2E, &13, &03
 EQUB &64, &80, &00, &40, &FF, &C1, &40, &00
 EQUB &10, &03, &FE, &21, &08, &00, &21, &04
 EQUB &03, &10, &E0, &80, &02, &80, &07, &FF
 EQUB &34, &3D, &1F, &07, &03, &03, &C0, &22
 EQUB &80, &FF, &21, &22, &90, &32, &02, &1F
 EQUB &03, &FF, &00, &21, &05, &12, &32, &0B
 EQUB &19, &10, &FF, &21, &0F, &AF, &12, &03
 EQUB &15, &03, &FC, &14, &03, &EF, &8F, &5F
 EQUB &9F, &BF, &21, &3E, &BF, &FF, &7F, &21
 EQUB &3F, &FF, &9F, &FF, &22, &01, &00, &6C
 EQUB &15, &23, &FE, &14, &03, &59, &14, &02
 EQUB &32, &01, &28, &FC, &13, &65, &D7, &BA
 EQUB &7F, &78, &F8, &22, &C0, &68, &E0, &0A
 EQUB &33, &0F, &17, &07, &05, &14, &04, &15
 EQUB &7E, &FE, &FF, &FD, &F9, &12, &21, &3F
 EQUB &7F, &12, &FD, &FF, &22, &FC, &13, &F3
 EQUB &FF, &F9, &FF, &FD, &FF, &C0, &22, &F0
 EQUB &15, &03, &15, &03, &12, &FC, &F8, &FF
 EQUB &03, &C0, &80, &02, &FF, &00, &34, &31
 EQUB &04, &00, &03, &02, &BF, &21, &1E, &CD
 EQUB &32, &26, &37, &EA, &58, &20, &E7, &FF
 EQUB &FD, &21, &25, &FF, &80, &5F, &21, &0F
 EQUB &E4, &F1, &B0, &21, &3F, &64, &4B, &5E
 EQUB &BF, &22, &7F, &81, &FF, &4A, &21, &28
 EQUB &AD, &DF, &7E, &F3, &33, &3F, &01, &02
 EQUB &FE, &C9, &F8, &E2, &00, &21, &1D, &22
 EQUB &FC, &10, &60, &40, &20, &80, &08, &22
 EQUB &01, &22, &03, &32, &07, &0F, &B3, &79
 EQUB &ED, &E4, &40, &82, &32, &1B, &1D, &B0
 EQUB &D0, &E8, &F8, &6C, &21, &3C, &DA, &4E
 EQUB &21, &0A, &07, &F7, &35, &1F, &1B, &3F
 EQUB &1F, &1E, &5F, &5D, &84, &03, &23, &80
 EQUB &C0, &21, &3E, &79, &68, &82, &21, &2D
 EQUB &5B, &32, &2C, &2D, &22, &C0, &60, &20
 EQUB &00, &80, &C0, &80, &51, &34, &38, &3F
 EQUB &11, &0B, &03, &20, &40, &00, &80, &04
 EQUB &3F, &13, &05, &30, &48, &84, &82, &81
 EQUB &80, &00, &80, &05, &80, &40, &20, &04
 EQUB &34, &01, &06, &0C, &18, &00, &30, &58
 EQUB &88, &24, &0C, &80, &05, &20, &00, &34
 EQUB &18, &04, &02, &03, &02, &32, &08, &04
 EQUB &04, &80, &C0, &20, &90, &03, &33, &03
 EQUB &06, &08, &10, &22, &20, &40, &80, &05
 EQUB &23, &0C, &22, &08, &21, &18, &10, &30
 EQUB &00, &34, &06, &01, &02, &01, &03, &B2
 EQUB &21, &09, &65, &21, &12, &CA, &21, &28
 EQUB &66, &21, &34, &CC, &34, &2C, &23, &D1
 EQUB &14, &A8, &4E, &91, &03, &80, &40, &E0
 EQUB &30, &21, &28, &00, &34, &01, &03, &04
 EQUB &08, &10, &20, &22, &40, &80, &09, &34
 EQUB &01, &03, &06, &0C, &30, &22, &60, &C0
 EQUB &80, &04, &39, &1B, &04, &02, &01, &00
 EQUB &02, &06, &05, &29, &CA, &30, &8D, &A2
 EQUB &32, &32, &19, &85, &9C, &47, &A1, &21
 EQUB &14, &52, &48, &21, &25, &90, &02, &80
 EQUB &C0, &34, &22, &32, &0A, &02, &04, &23
 EQUB &01, &35, &03, &01, &02, &04, &08, &10
 EQUB &00, &80, &08, &21, &01, &02, &32, &03
 EQUB &04, &10, &20, &42, &21, &07, &E0, &40
 EQUB &06, &31, &06, &27, &0F, &CE, &FB, &BE
 EQUB &FB, &FF, &FD, &12, &52, &68, &C8, &B5
 EQUB &44, &F2, &A8, &6D, &21, &03, &81, &21
 EQUB &08, &00, &32, &04, &08, &10, &02, &80
 EQUB &C0, &60, &30, &33, &18, &0C, &06, &06
 EQUB &36, &01, &03, &06, &0E, &1C, &38, &60
 EQUB &C0, &80, &21, &01, &22, &40, &32, &03
 EQUB &01, &49, &44, &45, &4A, &21, &09, &64
 EQUB &21, &16, &63, &99, &A7, &5D, &D7, &21
 EQUB &03, &9F, &7F, &6D, &FF, &7F, &12, &02
 EQUB &26, &80, &31, &07, &23, &03, &21, &01
 EQUB &03, &17, &7F, &D4, &F2, &BC, &EA, &F6
 EQUB &FD, &FB, &FC, &02, &88, &00, &80, &02
 EQUB &80, &32, &03, &01, &07, &C0, &60, &30
 EQUB &34, &18, &0C, &06, &03, &0E, &22, &20
 EQUB &0D, &35, &01, &07, &0C, &0E, &18, &30
 EQUB &60, &C0, &80, &03, &36, &02, &03, &05
 EQUB &0F, &1B, &3F, &6E, &CA, &C5, &95, &8B
 EQUB &8C, &33, &33, &0E, &37, &BF, &6F, &BF
 EQUB &DF, &12, &7F, &15, &22, &FE, &22, &FC
 EQUB &80, &07, &36, &3F, &1F, &0F, &0F, &03
 EQUB &01, &02, &12, &FD, &14, &7F, &00, &C0
 EQUB &20, &C8, &62, &D2, &B5, &E4, &00, &80
 EQUB &00, &40, &00, &21, &18, &00, &84, &08
 EQUB &80, &60, &30, &35, &18, &0C, &04, &02
 EQUB &03, &00, &23, &20, &21, &24, &46, &22
 EQUB &50, &23, &20, &03, &20, &40, &04, &36
 EQUB &01, &03, &07, &06, &1C, &38, &70, &E0
 EQUB &C0, &80, &02, &22, &01, &34, &06, &0B
 EQUB &0F, &3F, &7F, &FF, &BC, &FC, &F9, &F3
 EQUB &E7, &C7, &9B, &21, &2F, &5D, &4F, &7F
 EQUB &21, &37, &DF, &FF, &22, &BF, &16, &FC
 EQUB &22, &F8, &F0, &E0, &C0, &80, &03, &32
 EQUB &3F, &1F, &47, &63, &79, &FC, &12, &DE
 EQUB &EA, &F7, &F5, &FF, &F6, &FF, &FB, &00
 EQUB &41, &20, &21, &28, &84, &D0, &4A, &D4
 EQUB &03, &20, &03, &10, &21, &01, &08, &80
 EQUB &23, &C0, &22, &60, &E0, &34, &32, &12
 EQUB &12, &04, &10, &00, &21, &11, &03, &10
 EQUB &22, &40, &02, &80, &34, &0C, &1C, &18
 EQUB &38, &22, &30, &22, &70, &38, &01, &03
 EQUB &06, &0B, &0B, &0F, &17, &17, &BE, &FC
 EQUB &F9, &F2, &F7, &E4, &E7, &ED, &6F, &97
 EQUB &7F, &4F, &BF, &17, &FE, &F9, &FB, &FF
 EQUB &F0, &C0, &80, &30, &22, &F0, &F8, &F0
 EQUB &25, &7F, &22, &3F, &21, &1F, &FF, &FD
 EQUB &FE, &FF, &FE, &FF, &FD, &FF, &A9, &EC
 EQUB &F6, &F9, &7E, &FA, &BF, &5E, &21, &08
 EQUB &84, &10, &21, &14, &AA, &21, &29, &D4
 EQUB &6A, &04, &22, &01, &41, &21, &03, &25
 EQUB &E0, &23, &C0, &03, &21, &01, &05, &21
 EQUB &21, &A4, &93, &22, &7A, &7F, &21, &3F
 EQUB &02, &30, &6C, &60, &23, &E0, &23, &70
 EQUB &22, &30, &37, &18, &19, &0C, &0F, &3B
 EQUB &4F, &2F, &9F, &67, &32, &3D, &17, &23
 EQUB &EF, &FF, &EF, &FF, &22, &F7, &1F, &11
 EQUB &22, &F8, &24, &F0, &22, &E0, &22, &0F
 EQUB &33, &07, &03, &01, &03, &FF, &FE, &12
 EQUB &FE, &FF, &7F, &21, &3F, &CF, &B1, &A8
 EQUB &4A, &D0, &A1, &B8, &C8, &59, &A1, &EC
 EQUB &D2, &D9, &EA, &F4, &FE, &23, &03, &87
 EQUB &22, &03, &83, &21, &01, &C0, &27, &80
 EQUB &04, &21, &0C, &00, &21, &01, &05, &21
 EQUB &06, &00, &F8, &21, &1D, &C0, &05, &FC
 EQUB &80, &04, &70, &03, &22, &04, &00, &21
 EQUB &02, &04, &6F, &9B, &34, &2F, &2B, &57
 EQUB &17, &BB, &AF, &FB, &13, &23, &FD, &1C
 EQUB &FE, &FC, &F8, &F0, &E0, &22, &C0, &06
 EQUB &33, &0F, &07, &03, &24, &01, &21, &07
 EQUB &EC, &B4, &F6, &E0, &E7, &23, &E3, &F2
 EQUB &FC, &74, &30, &12, &BB, &00, &40, &80
 EQUB &02, &F0, &E0, &60, &00, &C0, &7F, &21
 EQUB &06, &00, &31, &38, &23, &18, &21, &01
 EQUB &00, &A0, &05, &F0, &03, &38, &1F, &0C
 EQUB &0E, &0E, &18, &08, &01, &00, &23, &0F
 EQUB &21, &08, &00, &4F, &FF, &00, &13, &32
 EQUB &1E, &18, &E0, &80, &21, &01, &FC, &FD
 EQUB &FC, &32, &04, &17, &77, &9F, &CF, &7F
 EQUB &22, &3F, &21, &3D, &FF, &F9, &FB, &14
 EQUB &21, &25, &13, &BF, &BE, &22, &BC, &BE
 EQUB &C0, &80, &0E, &32, &15, &3F, &06, &AA
 EQUB &7F, &05, &21, &14, &12, &7F, &03, &21
 EQUB &13, &CE, &23, &C3, &23, &03, &83, &E3
 EQUB &02, &80, &12, &80, &03, &21, &02, &00
 EQUB &22, &F0, &10, &21, &03, &00, &28, &1C
 EQUB &00, &32, &01, &0B, &03, &34, &1F, &07
 EQUB &0E, &0E, &24, &0F, &CF, &8F, &08, &23
 EQUB &1C, &35, &1E, &1C, &1E, &1C, &1E, &06
 EQUB &22, &03, &23, &38, &23, &3F, &22, &38
 EQUB &03, &13, &02, &7E, &22, &3F, &23, &80
 EQUB &32, &3E, &3F, &00, &12, &03, &62, &FF
 EQUB &00, &F5, &FF, &04, &B8, &00, &C0, &E0
 EQUB &04, &80, &21, &01, &07, &62, &03, &33
 EQUB &08, &02, &01, &00, &BF, &03, &21, &02
 EQUB &40, &00, &21, &04, &E3, &33, &07, &03
 EQUB &07, &40, &80, &02, &80, &13, &04, &21
 EQUB &01, &22, &F0, &F8, &31, &06, &23, &07
 EQUB &34, &1C, &1F, &3F, &3F, &04, &21, &0C
 EQUB &13, &04, &8F, &23, &CF, &04, &21, &1F
 EQUB &03, &7F, &23, &3F, &9C, &22, &1C, &21
 EQUB &3E, &04, &63, &03, &FF, &7F, &FF, &FE
 EQUB &34, &38, &3C, &3F, &3F, &05, &D1, &12
 EQUB &04, &21, &3F, &00, &22, &80, &00, &32
 EQUB &3E, &3F, &7F, &FF, &03, &21, &01, &F7
 EQUB &FE, &F8, &FF, &0F, &0C, &DD, &6F, &32
 EQUB &3F, &0F, &04, &14, &22, &06, &22, &0E
 EQUB &14, &04, &14, &04, &FE, &13, &04, &7F
 EQUB &13, &7F, &23, &7E, &FF, &BF, &FF, &DF
 EQUB &02, &22, &01, &14, &24, &FE, &14, &04
 EQUB &14, &04, &14, &23, &7F, &FE, &FC, &F0
 EQUB &E0, &80, &F0, &C0, &80, &09, &34, &1F
 EQUB &0F, &03, &01, &04, &14, &03, &21, &01
 EQUB &14, &7F, &15, &FB, &F7, &15, &FD, &12
 EQUB &22, &EF, &F7, &FF, &FB, &FF, &FD, &FE
 EQUB &C0, &22, &E0, &F0, &14, &04, &14, &04
 EQUB &12, &FE, &F8, &04, &80, &05, &32, &0F
 EQUB &03, &04, &4F, &21, &01, &12, &36, &0F
 EQUB &07, &3F, &1F, &FF, &0F, &12, &02, &A0
 EQUB &F0, &FF, &EE, &CF, &C0, &04, &FE, &FF
 EQUB &7F, &02, &35, &17, &1F, &0F, &FF, &0C
 EQUB &12, &02, &13, &00, &20, &FE, &02, &22
 EQUB &80, &F0, &0F, &35, &0C, &0E, &1E, &1F
 EQUB &3F, &7D, &E4, &E2, &04, &80, &C0, &E0
 EQUB &F0, &21, &01, &07, &21, &08, &00, &21
 EQUB &04, &00, &22, &20, &22, &60, &78, &07
 EQUB &40, &22, &80, &02, &33, &04, &1E, &1E
 EQUB &08, &21, &0C, &02, &21, &0E, &0C, &3F

\ ******************************************************************************
\
\       Name: LB5CC
\       Type: Variable
\   Category: Drawing images
\    Summary: ???
\
\ ******************************************************************************

.LB5CC

 EQUB &01, &02, &00, &00, &00, &00, &00, &00
 EQUB &00, &00, &00, &00, &00, &00, &00, &00
 EQUB &00, &00, &00, &00, &03, &04, &00, &00
 EQUB &05, &06, &07, &00, &00, &00, &00, &00
 EQUB &00, &00, &00, &00, &00, &00, &00, &00
 EQUB &00, &00, &00, &08, &09, &0A, &00, &00
 EQUB &0B, &0C, &0D, &0E, &00, &00, &00, &00
 EQUB &00, &00, &00, &00, &00, &00, &00, &00
 EQUB &00, &00, &0F, &10, &11, &12, &00, &00
 EQUB &00, &13, &14, &15, &16, &00, &00, &00
 EQUB &00, &00, &00, &00, &00, &00, &00, &00
 EQUB &17, &18, &19, &1A, &1B, &00, &00, &00
 EQUB &00, &1C, &1D, &1E, &1F, &20, &00, &00
 EQUB &00, &00, &00, &00, &00, &00, &00, &21
 EQUB &22, &23, &24, &25, &26, &00, &00, &00
 EQUB &00, &27, &28, &29, &2A, &2B, &2C, &2D
 EQUB &00, &00, &2E, &2F, &00, &00, &30, &31
 EQUB &32, &33, &34, &35, &36, &00, &00, &00
 EQUB &00, &00, &37, &38, &39, &3A, &3B, &3C
 EQUB &00, &00, &3D, &3E, &00, &3F, &40, &41
 EQUB &42, &43, &44, &45, &00, &00, &00, &00
 EQUB &00, &00, &00, &46, &47, &48, &49, &4A
 EQUB &4B, &00, &4C, &4D, &00, &4E, &4F, &50
 EQUB &51, &52, &53, &00, &00, &00, &00, &00
 EQUB &00, &00, &00, &54, &55, &56, &57, &58
 EQUB &59, &5A, &5B, &5C, &00, &5D, &5E, &5F
 EQUB &60, &61, &62, &00, &00, &00, &00, &00
 EQUB &00, &00, &00, &63, &64, &65, &66, &67
 EQUB &68, &69, &6A, &6B, &6C, &6D, &6E, &6F
 EQUB &70, &71, &72, &00, &00, &00, &00, &00
 EQUB &00, &00, &00, &00, &73, &74, &75, &76
 EQUB &77, &78, &79, &7A, &7B, &7C, &7D, &7E
 EQUB &7F, &80, &00, &00, &00, &00, &00, &00
 EQUB &00, &81, &82, &83, &84, &85, &86, &87
 EQUB &88, &89, &8A, &8B, &8C, &8D, &8E, &8F
 EQUB &90, &91, &92, &93, &00, &00, &00, &00
 EQUB &00, &00, &94, &95, &96, &97, &98, &99
 EQUB &9A, &9B, &9C, &9D, &9E, &9F, &A0, &A1
 EQUB &A2, &A3, &A4, &A5, &00, &00, &00, &00
 EQUB &00, &00, &00, &00, &A6, &A7, &A8, &A9
 EQUB &AA, &AB, &AC, &AD, &AE, &AF, &B0, &B1
 EQUB &B2, &B3, &00, &00, &00, &00, &00, &00
 EQUB &00, &00, &00, &00, &00, &00, &B4, &B5
 EQUB &B6, &B7, &B8, &B9, &BA, &BB, &BC, &BD
 EQUB &00, &00, &00, &00, &00, &00, &00, &00
 EQUB &00, &00, &00, &00, &00, &00, &00, &BE
 EQUB &BF, &C0, &C1, &C2, &C3, &C4, &C5, &00
 EQUB &00, &00, &00, &00, &00, &00, &00, &00
 EQUB &00, &00, &00, &00, &00, &00, &00, &00
 EQUB &00, &C6, &C7, &C8, &00, &00, &00, &00
 EQUB &00, &00, &00, &00, &00, &00, &00, &00
 EQUB &00, &00, &00, &00, &00, &00, &00, &00
 EQUB &00, &C9, &CA, &CB, &00, &00, &00, &00
 EQUB &00, &00, &00, &00, &00, &00, &00, &00
 EQUB &00, &00, &00, &00, &00, &00, &00, &00
 EQUB &00, &00, &CC, &CD, &00, &00, &00, &00
 EQUB &00, &00, &00, &00, &00, &00, &00, &00
 EQUB &00, &00, &00, &00, &00, &00, &00, &00
 EQUB &00, &00, &CE, &CF, &00, &00, &00, &00
 EQUB &00, &00, &00, &00, &00, &00, &00, &00

\ ******************************************************************************
\
\       Name: LB7AC
\       Type: Variable
\   Category: Drawing images
\    Summary: ???
\
\ ******************************************************************************

.LB7AC

 EQUB &01, &00, &00, &00, &00, &02, &03, &00
 EQUB &04, &05, &00, &00, &00, &06, &07, &00
 EQUB &08, &09, &0A, &0B, &0C, &0D, &0E, &00
 EQUB &0F, &10, &11, &12, &13, &14, &00, &00
 EQUB &15, &16, &17, &18, &19, &1A, &00, &00
 EQUB &00, &1B, &1C, &1D, &1E, &1F, &00, &00
 EQUB &00, &00, &20, &21, &22, &00, &00, &00
 EQUB &00, &00, &00, &23, &00, &00, &00, &00
 EQUB &00, &00, &00, &00, &45, &46, &47, &48
 EQUB &49, &00, &00, &00, &00, &00, &4A, &4B
 EQUB &4C, &4D, &4E, &4F, &50, &51, &52, &53
 EQUB &54, &55, &00, &00, &00, &56, &57, &58
 EQUB &59, &5A, &5B, &5C, &5D, &00, &00, &00
 EQUB &5E, &5F, &60, &61, &62, &63, &64, &65
 EQUB &66, &67, &68, &69, &00, &00, &6A, &6B
 EQUB &6C, &6D, &6E, &6F, &70, &71, &72, &73
 EQUB &00, &00, &00, &00, &00, &00, &00, &00
 EQUB &00, &00, &00, &00, &00, &00, &00, &74
 EQUB &75, &76, &77, &78, &79, &7A, &7B, &7C
 EQUB &7D, &7E, &7F, &00, &00, &00, &00, &00
 EQUB &00, &00, &00, &00, &00, &00, &00, &00
 EQUB &00, &80, &81, &82, &83, &84, &85, &86
 EQUB &87, &88, &89, &8A, &8B, &00, &00, &00
 EQUB &00, &00, &00, &00, &00, &00, &00, &00
 EQUB &00, &00, &00, &00, &00, &00, &00, &00
 EQUB &00, &00, &00, &00, &00, &00, &00, &00
 EQUB &00, &00, &00, &00, &00, &00, &AD, &DD
 EQUB &03, &D0, &1F, &AE, &DC, &03, &E0, &00
 EQUB &69, &00, &E0, &02, &69, &00, &E0, &08
 EQUB &69, &00, &E0, &18, &69, &00, &E0, &2C
 EQUB &69, &00, &E0, &82, &69, &00, &AA, &4C
 EQUB &B7, &B8, &A2, &09, &C9, &19, &B0, &0B
 EQUB &CA, &C9, &0A, &B0, &06, &CA, &C9, &02
 EQUB &B0, &01, &CA, &CA, &8A, &85, &99, &0A
 EQUB &65, &99, &85, &99, &AE, &71, &04, &F0
 EQUB &01, &CA, &8A, &18, &65, &99, &AA, &BD
 EQUB &DB, &B8, &CD, &1A, &95, &90, &05, &AD
 EQUB &1A, &95, &E9, &01, &85, &99, &60, &00
 EQUB &01, &02, &03, &04, &05, &06, &06, &07
 EQUB &08, &08, &08, &09, &09, &09, &0A, &0A
 EQUB &0A, &0B, &0B, &0B, &0C, &0C, &0C, &0D
 EQUB &0D, &0D, &0E, &0E, &0E

\ ******************************************************************************
\
\       Name: GetSystemImage2
\       Type: Subroutine
\   Category: Drawing images
\    Summary: Fetch the group 2 image for the current system and store it in the
\             pattern buffers
\
\ ******************************************************************************

.GetSystemImage2

 LDA #0                 \ Set (SC+1 A) = (0 pictureTile)
 STA SC+1               \              = pictureTile
 LDA pictureTile

 ASL A                  \ Set SC(1 0) = (SC+1 A) * 8
 ROL SC+1               \             = pictureTile * 8
 ASL A
 ROL SC+1
 ASL A
 ROL SC+1
 STA SC

 STA SC2                \ Set SC2(1 0) = pattBuffer1 + SC(1 0)
 LDA SC+1               \              = pattBuffer1 + pictureTile * 8
 ADC #HI(pattBuffer1)
 STA SC2+1

 LDA SC+1               \ Set SC(1 0) = pattBuffer0 + SC(1 0)
 ADC #HI(pattBuffer0)   \             = pattBuffer0 + pictureTile * 8
 STA SC+1

 LDA systemFlag         \ ???
 ASL A
 TAX

 LDA image2Offset,X     \ Set V(1 0) = image2Offset for image X + image2Count
 CLC                    \
 ADC #LO(image2Count)   \ So V(1 0) points to image0_2 when X = 0, image1_2 when
 STA V                  \ when X = 1, and so on up to image13_2 when X = 13
 LDA image2Offset+1,X
 ADC #HI(image2Count)
 STA V+1

 JSR UnpackToRAM        \ Unpack the data at V(1 0) into SC(1 0), updating
                        \ V(1 0) as we go
                        \
                        \ SC(1 0) is pattBuffer0 + pictureTile * 8, so this
                        \ unpacks the data from tile number pictureTile in
                        \ into pattern buffer 0

 LDA SC2                \ Set SC(1 0) = SC2(1 0)
 STA SC                 \             = pattBuffer1 + pictureTile * 8
 LDA SC2+1
 STA SC+1

 JSR UnpackToRAM        \ Unpack the data at V(1 0) into SC(1 0), updating
                        \ V(1 0) as we go
                        \
                        \ SC(1 0) is pattBuffer1 + pictureTile * 8, so this
                        \ unpacks the data from tile number pictureTile in
                        \ into pattern buffer 1

 RTS                    \ Return from the subroutine

\ ******************************************************************************
\
\       Name: SetSystemImage2
\       Type: Subroutine
\   Category: Drawing images
\    Summary: ???
\
\ ******************************************************************************

.SetSystemImage2

 JSR GetSystemImage2    \ Fetch the group 2 image for the current system and
                        \ store it in the pattern buffers, starting at tile
                        \ number pictureTile

 LDA systemFlag         \ ???
 ASL A
 TAX

 CLC                    \ Set V(1 0) = image1Offset for image X + image1Count
 LDA image1Offset,X     \
 ADC #LO(image1Count)   \ So V(1 0) points to image0_1 when X = 0, image1_1 when
 STA V                  \ X = 1, and so on up to image13_1 when X = 13
 LDA image1Offset+1,X
 ADC #HI(image1Count)
 STA V+1

 LDA #HI(16*69)         \ Set PPU_ADDR to the address of pattern #69 in pattern
 STA PPU_ADDR           \ table 0
 LDA #LO(16*69)
 STA PPU_ADDR

 JSR UnpackToPPU        \ Unpack the rest of the image data to the PPU ???

 LDA #HI(LAA9F)         \ Set V(1 0) = LAA9F
 STA V+1
 LDA #LO(LAA9F)
 STA V

 JMP UnpackToPPU        \ Unpack the image data to the PPU, ???
                        \ returning from the subroutine using a tail call

\ ******************************************************************************
\
\       Name: subm_B96B
\       Type: Subroutine
\   Category: Drawing images
\    Summary: ???
\
\ ******************************************************************************

.subm_B96B

 LDA #HI(LAB1C)
 STA V+1
 LDA #LO(LAB1C)
 STA V

 LDA tileNumber
 TAY
 STY K+2

 ASL A
 STA SC

 LDA #0
 ROL A
 ASL SC
 ROL A
 ASL SC
 ROL A
 ADC #&60
 STA SC+1

 ADC #8
 STA SC2+1

 LDA SC
 STA SC2

 JSR UnpackToRAM

 LDA SC2
 STA SC
 LDA SC2+1
 STA SC+1

 JSR UnpackToRAM

 LDA #HI(LB5CC)
 STA V+1
 LDA #LO(LB5CC)
 STA V

 LDA #&18
 STA K
 LDA #&14
 STA K+1

 LDA #1
 STA YC
 LDA #5
 STA XC

 JSR subm_B9C1

 LDA tileNumber
 CLC
 ADC #&D0
 STA tileNumber

 RTS

\ ******************************************************************************
\
\       Name: subm_B9C1
\       Type: Subroutine
\   Category: Drawing images
\    Summary: ???
\
\ ******************************************************************************

.subm_B9C1

 LDA #&20
 SEC
 SBC K
 STA ZZ

 JSR subm_DBD8

 LDA SC
 CLC
 ADC XC
 STA SC

 LDY #0

.CB9D4

 LDX K

.loop_CB9D6

 LDA (V),Y
 BEQ CB9DD

 CLC
 ADC K+2

.CB9DD

 STA (SC),Y

 INY

 BNE CB9E6

 INC V+1

 INC SC+1

.CB9E6

 DEX

 BNE loop_CB9D6

 LDA SC
 CLC
 ADC ZZ
 STA SC

 BCC CB9F4

 INC SC+1

.CB9F4

 DEC K+1

 BNE CB9D4

 RTS

\ ******************************************************************************
\
\       Name: subm_B9F9
\       Type: Subroutine
\   Category: Drawing images
\    Summary: ???
\
\ ******************************************************************************

.subm_B9F9

 LDA #1
 STA XC

 ASL A
 STA YC

 LDX #8
 STX K
 STX K+1

 LDX #6
 LDY #6

 LDA #&43
 STA K+2

 LDA CNT
 LSR A
 LSR A
 STA K+3

 LDA #HI(LB7AC)
 STA V+1
 LDA #LO(LB7AC)
 STA V

 LDA #1
 STA S

 LDA XC
 ASL A
 ASL A
 ASL A
 ADC #0
 STA SC
 TXA
 ADC SC
 STA SC

 LDA YC
 ASL A
 ASL A
 ASL A
 ADC #6
 STA SC+1
 TYA
 ADC SC+1
 STA SC+1

 LDA K+3
 ASL A
 ASL A
 TAX

 LDA K+1
 STA T

 LDY #0

.CBA47

 CHECK_DASHBOARD        \ If the PPU has started drawing the dashboard, switch
                        \ to nametable 0 (&2000) and pattern table 0 (&0000)

 LDA SC
 STA SC2

 LDA K
 STA ZZ

.CBA5C

 LDA (V),Y

 INY

 BNE CBA63

 INC V+1

.CBA63

 CMP #0
 BEQ CBA82

 ADC K+2

 STA SPR_00_TILE,X

 LDA S
 STA SPR_00_ATTR,X

 LDA SC2
 STA SPR_00_X,X

 LDA SC+1
 STA SPR_00_Y,X

 TXA
 CLC
 ADC #4

 BCS CBA97

 TAX

.CBA82

 LDA SC2
 CLC
 ADC #8
 STA SC2

 DEC ZZ

 BNE CBA5C

 LDA SC+1
 ADC #8
 STA SC+1

 DEC T

 BNE CBA47

.CBA97

 RTS

\ ******************************************************************************
\
\       Name: Vectors
\       Type: Variable
\   Category: Text
\    Summary: Vectors and padding at the end of the ROM bank
\
\ ******************************************************************************

 FOR I%, P%, &BFF9

  EQUB &FF              \ Pad out the rest of the ROM bank with &FF

 NEXT

 EQUW Interrupts+&4000  \ Vector to the NMI handler in case this bank is loaded
                        \ into &C000 during startup (the handler contains an RTI
                        \ so the interrupt is processed but has no effect)

 EQUW ResetMMC1+&4000   \ Vector to the RESET handler in case this bank is
                        \ loaded into &C000 during startup (the handler resets
                        \ the MMC1 mapper to map bank 7 into &C000 instead)

 EQUW Interrupts+&4000  \ Vector to the IRQ/BRK handler in case this bank is
                        \ loaded into &C000 during startup (the handler contains
                        \ an RTI so the interrupt is processed but has no
                        \ effect)

\ ******************************************************************************
\
\ Save bank4.bin
\
\ ******************************************************************************

 PRINT "S.bank4.bin ", ~CODE%, " ", ~P%, " ", ~LOAD%, " ", ~LOAD%
 SAVE "3-assembled-output/bank4.bin", CODE%, P%, LOAD%
