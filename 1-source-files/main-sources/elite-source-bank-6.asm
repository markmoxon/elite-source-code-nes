; ******************************************************************************
;
; NES ELITE GAME SOURCE (BANK 6)
;
; NES Elite was written by Ian Bell and David Braben and is copyright D. Braben
; and I. Bell 1991/1992
;
; The sound player in this bank was written by David Whittaker
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
; This source file produces the following binary file:
;
;   * bank6.bin
;
; ******************************************************************************

; ******************************************************************************
;
; ELITE BANK 1
;
; Produces the binary file bank1.bin.
;
; ******************************************************************************

 ORG CODE%

; ******************************************************************************
;
;       Name: ResetMMC1_b6
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

.ResetMMC1_b6

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
;       Name: Interrupts_b6
;       Type: Subroutine
;   Category: Start and end
;    Summary: The IRQ and NMI handler while the MMC1 mapper reset routine is
;             still running
;
; ******************************************************************************

.Interrupts_b6

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
;       Name: versionNumber_b6
;       Type: Variable
;   Category: Text
;    Summary: The game's version number in bank 6
;
; ******************************************************************************

IF _NTSC

 EQUS " 5.0"

ELIF _PAL

 EQUS "<2.8>"

ENDIF

; ******************************************************************************
;
;       Name: ChooseMusicS
;       Type: Subroutine
;   Category: Sound
;    Summary: A jump table entry at the start of bank 6 for the ChooseMusic
;             routine
;
; ******************************************************************************

.ChooseMusicS

 JMP ChooseMusic        ; Jump to the ChooseMusic routine, returning from the
                        ; subroutine using a tail call

; ******************************************************************************
;
;       Name: MakeSoundsS
;       Type: Subroutine
;   Category: Sound
;    Summary: A jump table entry at the start of bank 6 for the MakeSounds
;             routine
;
; ******************************************************************************

.MakeSoundsS

 JMP MakeSounds         ; Jump to the MakeSounds routine, returning from the
                        ; subroutine using a tail call

; ******************************************************************************
;
;       Name: StopSoundsS
;       Type: Subroutine
;   Category: Sound
;    Summary: A jump table entry at the start of bank 6 for the StopSounds
;             routine
;
; ******************************************************************************

.StopSoundsS

 JMP StopSounds         ; Jump to the StopSounds routine, returning from the
                        ; subroutine using a tail call

; ******************************************************************************
;
;       Name: EnableSoundS
;       Type: Subroutine
;   Category: Sound
;    Summary: A jump table entry at the start of bank 6 for the EnableSound
;             routine
;
; ******************************************************************************

.EnableSoundS

 JMP EnableSound        ; Jump to the EnableSound routine, returning from the
                        ; subroutine using a tail call

; ******************************************************************************
;
;       Name: StartEffectOnSQ1S
;       Type: Subroutine
;   Category: Sound
;    Summary: A jump table entry at the start of bank 6 for the StartEffectOnSQ1
;             routine
;
; ******************************************************************************

.StartEffectOnSQ1S

 JMP StartEffectOnSQ1   ; Jump to the StartEffectOnSQ1 routine, returning from
                        ; the subroutine using a tail call

; ******************************************************************************
;
;       Name: StartEffectOnSQ2S
;       Type: Subroutine
;   Category: Sound
;    Summary: A jump table entry at the start of bank 6 for the StartEffectOnSQ2
;             routine
;
; ******************************************************************************

.StartEffectOnSQ2S

 JMP StartEffectOnSQ2   ; Jump to the StartEffectOnSQ2 routine, returning from
                        ; the subroutine using a tail call

; ******************************************************************************
;
;       Name: StartEffectOnNOISES
;       Type: Subroutine
;   Category: Sound
;    Summary: A jump table entry at the start of bank 6 for the
;             StartEffectOnNOISE routine
;
; ******************************************************************************

.StartEffectOnNOISES

 JMP StartEffectOnNOISE ; Jump to the StartEffectOnNOISE routine, returning from
                        ; the subroutine using a tail call

; ******************************************************************************
;
;       Name: ChooseMusic
;       Type: Subroutine
;   Category: Sound
;    Summary: Set the tune for the background music
;
; ------------------------------------------------------------------------------
;
; The tune numbers are as follows:
;
;   * 0 for the title music ("Elite Theme"), which is set in the TITLE routine
;       and as the default tune in the ResetMusic routine
;
;   * 1 for docking ("The Blue Danube"), which is set in the TT102 routine
;
;   * 2 for the combat demo music ("Game Theme"), though this is never set
;       directly, only via tune 4
;
;   * 3 for the scroll text music ("Assassin's Touch"), though this is never set
;       directly, only via tune 4
;
;   * 4 for the full combat demo suite ("Assassin's Touch" followed by "Game
;       Theme"), which is set in the DEATH2 routine
;
; ------------------------------------------------------------------------------
;
; Arguments:
;
;   A                   The number of the tune to choose
;
; ******************************************************************************

.ChooseMusic

 TAY                    ; Set Y to the tune number

 JSR StopSoundsS        ; Call StopSounds via StopSoundsS to stop all sounds
                        ; (both music and sound effects)
                        ;
                        ; This also sets enableSound to 0

                        ; We now calculate the offset into the tuneData table
                        ; for this tune\s data, which will be Y * 9 as there are
                        ; nine bytes for each tune at the start of the table

 LDA #0                 ; Set A = 0 so we can build the results of the
                        ; calculation by adding 9 to A, Y times

 CLC                    ; Clear the C flag for the addition below

.cmus1

 DEY                    ; Decrement the tune number in Y

 BMI cmus2              ; If the result is negative then A contains the result
                        ; of Y * 9, so jump to cmus2

 ADC #9                 ; Set A = A * 9

 BNE cmus1              ; Loop back to cmus1 to add another 9 to A (this BNE is
                        ; effectively a JMP as A is never zero)

.cmus2

 TAX                    ; Copy the result into X, so X = tune number * 9, which
                        ; we can use as the offset into the tuneData table
                        ; below

                        ; We now reset the four 19-byte blocks of memory that
                        ; are used to store the channel-specific variables, as
                        ; follows:
                        ;
                        ;   sectionDataSQ1   to applyVolumeSQ1
                        ;   sectionDataSQ2   to applyVolumeSQ2
                        ;   sectionDataTRI   to volumeEnvelopeTRI+1
                        ;   sectionDataNOISE to applyVolumeNOISE
                        ;
                        ; There is no volumeEnvelopeTRI variable but the space
                        ; is still reserved, which is why the TRI channel clears
                        ; to volumeEnvelopeTRI+1

 LDA #0                 ; Set A = 0 to use when zeroing these locations

 LDY #18                ; Set a counter in Y for the 19 bytes in each block

.cmus3

 STA sectionDataSQ1,Y   ; Zero the Y-th byte of sectionDataSQ1

 STA sectionDataSQ2,Y   ; Zero the Y-th byte of sectionDataSQ2

 STA sectionDataTRI,Y   ; Zero the Y-th byte of sectionDataTRI

 STA sectionDataNOISE,Y ; Zero the Y-th byte of sectionDataNOISE

 DEY                    ; Decrement the loop counter in Y

 BPL cmus3              ; Loop back until we have zeroed bytes 0 to 18 in all
                        ; four blocks

 TAY                    ; Set Y = 0, to use as an index when fetching addresses
                        ; from the tuneData table

 LDA tuneData,X         ; Fetch the first byte from the tune's block at
 STA tuneSpeed          ; tuneData, which contains the tune's speed, and store
 STA tuneSpeedCopy      ; it in tuneSpeed and tuneSpeedCopy
                        ;
                        ; For tune 0, this would be 47

 LDA tuneData+1,X       ; Set soundAddr(1 0) and sectionListSQ1(1 0) to the
 STA sectionListSQ1     ; first address from the tune's block at tuneData
 STA soundAddr          ;
 LDA tuneData+2,X       ; For tune 0, this would set both variables to point to
 STA sectionListSQ1+1   ; the list of tune sections at tune0Data_SQ1
 STA soundAddr+1

 LDA (soundAddr),Y      ; Fetch the address that the first address points to
 STA sectionDataSQ1     ; and put it in sectionDataSQ1(1 0), incrementing the
 INY                    ; index in Y in the process
 LDA (soundAddr),Y      ;
 STA sectionDataSQ1+1   ; For tune 0, this would set sectionDataSQ1(1 0) to the
                        ; address of tune0Data_SQ1_0

 LDA tuneData+3,X       ; Set soundAddr(1 0) and sectionListSQ2(1 0) to the
 STA sectionListSQ2     ; second address from the tune's block at tuneData
 STA soundAddr          ;
 LDA tuneData+4,X       ; For tune 0, this would set both variables to point to
 STA sectionListSQ2+1   ; the list of tune sections at tune0Data_SQ2
 STA soundAddr+1

 DEY                    ; Decrement the index in Y, so it is zero once again

 LDA (soundAddr),Y      ; Fetch the address that the second address points to
 STA sectionDataSQ2     ; and put it in sectionDataSQ2(1 0), incrementing the
 INY                    ; index in Y in the process
 LDA (soundAddr),Y      ;
 STA sectionDataSQ2+1   ; For tune 0, this would set sectionDataSQ2(1 0) to the
                        ; address of tune0Data_SQ2_0

 LDA tuneData+5,X       ; Set soundAddr(1 0) and sectionListTRI(1 0) to the
 STA sectionListTRI     ; third address from the tune's block at tuneData
 STA soundAddr          ;
 LDA tuneData+6,X       ; For tune 0, this would set both variables to point to
 STA sectionListTRI+1   ; the list of tune sections at tune0Data_TRI
 STA soundAddr+1

 DEY                    ; Decrement the index in Y, so it is zero once again

 LDA (soundAddr),Y      ; Fetch the address that the third address points to
 STA sectionDataTRI     ; and put it in sectionDataTRI(1 0), incrementing the
 INY                    ; index in Y in the process
 LDA (soundAddr),Y      ;
 STA sectionDataTRI+1   ; For tune 0, this would set sectionDataTRI(1 0) to the
                        ; address of tune0Data_TRI_0

 LDA tuneData+7,X       ; Set soundAddr(1 0) and sectionListNOISE(1 0) to the
 STA sectionListNOISE   ; fourth address from the tune's block at tuneData
 STA soundAddr          ;
 LDA tuneData+8,X       ; For tune 0, this would set both variables to point to
 STA sectionListNOISE+1 ; the list of tune sections at tune0Data_NOISE
 STA soundAddr+1

 DEY                    ; Decrement the index in Y, so it is zero once again

 LDA (soundAddr),Y      ; Fetch the address that the fourth address points to
 STA sectionDataNOISE   ; and put it in sectionDataNOISE(1 0), incrementing the
 INY                    ; index in Y in the process
 LDA (soundAddr),Y      ;
 STA sectionDataNOISE+1 ; For tune 0, this would set sectionDataNOISE(1 0) to
                        ; the address of tune0Data_NOISE_0

 STY pauseCountSQ1      ; Set pauseCountSQ1 = 1 so we start sending music to the
                        ; SQ1 channel straight away, without a pause

 STY pauseCountSQ2      ; Set pauseCountSQ2 = 1 so we start sending music to the
                        ; SQ2 channel straight away, without a pause

 STY pauseCountTRI      ; Set pauseCountTRI = 1 so we start sending music to the
                        ; TRI channel straight away, without a pause

 STY pauseCountNOISE    ; Set pauseCountNOISE = 1 so we start sending music to
                        ; the NOISE channel straight away, without a pause

 INY                    ; Increment Y to 2

 STY nextSectionSQ1     ; Set nextSectionSQ1(1 0) = 2 (the high byte was already
                        ; zeroed above), so the next section after the first on
                        ; the SQ1 channel is the second section

 STY nextSectionSQ2     ; Set nextSectionSQ2(1 0) = 2 (the high byte was already
                        ; zeroed above), so the next section after the first on
                        ; the SQ2 channel is the second section

 STY nextSectionTRI     ; Set nextSectionTRI(1 0) = 2 (the high byte was already
                        ; zeroed above), so the next section after the first on
                        ; the TRI channel is the second section

 STY nextSectionNOISE   ; Set nextSectionNOISE = 2 (the high byte was already
                        ; zeroed above), so the next section after the first on
                        ; the NOISE channel is the second section

 LDX #0                 ; Set tuningAll = 0 to set all channels to the default
 STX tuningAll          ; tuning

 DEX                    ; Decrement X to $FF

 STX tuneProgress       ; Set tuneProgress = $FF, so adding any non-zero speed
                        ; at the start of MakeMusic will overflow the progress
                        ; counter and start playing the music straight away

 STX playMusic          ; Set playMusic = $FF to enable the new tune to be
                        ; played

 INC enableSound        ; Increment enableSound to 1 to enable sound, now that
                        ; we have set up the music to play

 RTS                    ; Return from the subroutine

; ******************************************************************************
;
;       Name: EnableSound
;       Type: Subroutine
;   Category: Sound
;    Summary: Enable sounds (music and sound effects)
;
; ******************************************************************************

.EnableSound

 LDA playMusic          ; If playMusic = 0 then the music has been disabled by
 BEQ enas1              ; note command $FE, so jump to enas1 to leave the value
                        ; of enableSound alone and return from the subroutine
                        ; as only a new call to ChooseMusic can enable the music
                        ; again

 LDA enableSound        ; If enableSound is already non-zero, jump to enas1 to
 BNE enas1              ; leave it and return from the subroutine

 INC enableSound        ; Otherwise increment enableSound from 0 to 1

.enas1

 RTS                    ; Return from the subroutine

; ******************************************************************************
;
;       Name: StopSounds
;       Type: Subroutine
;   Category: Sound
;    Summary: Stop all sounds (music and sound effects)
;
; ******************************************************************************

.StopSounds

 LDA #0                 ; Set enableSound = 0 to disable all sounds (music and
 STA enableSound        ; sound effects)

 STA effectOnSQ1        ; Set effectOnSQ1 = 0 to indicate the SQ1 channel is
                        ; clear of sound effects

 STA effectOnSQ2        ; Set effectOnSQ2 = 0 to indicate the SQ2 channel is
                        ; clear of sound effects

 STA effectOnNOISE      ; Set effectOnNOISE = 0 to indicate the NOISE channel is
                        ; clear of sound effects

 TAX                    ; We now clear the 16 bytes at sq1Volume, so set X = 0
                        ; to act as an index in the following loop

.stop1

 STA sq1Volume,X        ; Zero the X-th byte of sq1Volume

 INX                    ; Increment the index counter

 CPX #16                ; Loop back until we have cleared all 16 bytes
 BNE stop1

 STA TRI_LINEAR         ; Zero the linear counter for the TRI channel, which
                        ; configures it as follows:
                        ;
                        ;   * Bit 7 clear = do not reload the linear counter
                        ;
                        ;   * Bits 0-6    = counter reload value of 0
                        ;
                        ; So this silences the TRI channel

 LDA #%00110000         ; Set the volume of the SQ1, SQ2 and NOISE channels to
 STA SQ1_VOL            ; zero as follows:
 STA SQ2_VOL            ;
 STA NOISE_VOL          ;   * Bits 6-7    = duty pulse length is 3
                        ;   * Bit 5 set   = infinite play
                        ;   * Bit 4 set   = constant volume
                        ;   * Bits 0-3    = volume is 0

 LDA #%00001111         ; Enable the sound channels by writing to the sound
 STA SND_CHN            ; status register in SND_CHN as follows:
                        ;
                        ;   Bit 4 clear = disable the DMC channel
                        ;   Bit 3 set   = enable the NOISE channel
                        ;   Bit 2 set   = enable the TRI channel
                        ;   Bit 1 set   = enable the SQ2 channel
                        ;   Bit 0 set   = enable the SQ1 channel

 RTS                    ; Return from the subroutine

; ******************************************************************************
;
;       Name: MakeSounds
;       Type: Subroutine
;   Category: Sound
;    Summary: Make the current sounds (music and sound effects)
;  Deep dive: Sound effects in NES Elite
;             Music in NES Elite
;
; ******************************************************************************

.MakeSounds

 JSR MakeMusic          ; Calculate the current music on the SQ1, SQ2, TRI and
                        ; NOISE channels

 JSR MakeSound          ; Calculate the current sound effects on the SQ1, SQ2
                        ; and NOISE channels

 LDA enableSound        ; If enableSound = 0 then sound is disabled, so jump to
 BEQ maks3              ; maks3 to return from the subroutine

 LDA effectOnSQ1        ; If effectOnSQ1 is non-zero then a sound effect is
 BNE maks1              ; being made on channel SQ1, so jump to maks1 to skip
                        ; writing the music data to the APU (so sound effects
                        ; take precedence over music)

 LDA sq1Volume          ; Send sq1Volume to the APU via SQ1_VOL
 STA SQ1_VOL

 LDA sq1Sweep           ; If sq1Sweep is non-zero then there is a sweep unit in
 BNE maks1              ; play on channel SQ1, so jump to maks1 to skip the
                        ; following as the sweep will take care of the pitch

 LDA sq1Lo              ; Otherwise send sq1Lo to the APU via SQ1_LO to set the
 STA SQ1_LO             ; pitch on channel SQ1

.maks1

 LDA effectOnSQ2        ; If effectOnSQ2 is non-zero then a sound effect is
 BNE maks2              ; being made on channel SQ2, so jump to maks2 to skip
                        ; writing the music data to the APU (so sound effects
                        ; take precedence over music)

 LDA sq2Volume          ; Send sq2Volume to the APU via SQ2_VOL
 STA SQ2_VOL

 LDA sq2Sweep           ; If sq2Sweep is non-zero then there is a sweep unit in
 BNE maks2              ; play on channel SQ2, so jump to maks2 to skip the
                        ; following as the sweep will take care of the pitch

 LDA sq2Lo              ; Otherwise send sq2Lo to the APU via SQ2_LO to set the
 STA SQ2_LO             ; pitch on channel SQ2

.maks2

 LDA triLo              ; Send triLo to the APU via TRI_LO
 STA TRI_LO

 LDA effectOnNOISE      ; If effectOnNOISE is non-zero then a sound effect is
 BNE maks3              ; being made on channel NOISE, so jump to maks3 to skip
                        ; writing the music data to the APU (so sound effects
                        ; take precedence over music)

 LDA noiseVolume        ; Send noiseVolume to the APU via NOISE_VOL
 STA NOISE_VOL

 LDA noiseLo            ; Send noiseLo to the APU via NOISE_LO
 STA NOISE_LO

.maks3

 RTS                    ; Return from the subroutine

; ******************************************************************************
;
;       Name: MakeMusic
;       Type: Subroutine
;   Category: Sound
;    Summary: Play the current music on the SQ1, SQ2, TRI and NOISE channels
;  Deep dive: Music in NES Elite
;
; ******************************************************************************

.MakeMusic

 LDA enableSound        ; If enableSound is non-zero then sound is enabled, so
 BNE makm1              ; jump to makm1 to play the current music

 RTS                    ; Otherwise sound is disabled, so return from the
                        ; subroutine

.makm1

 LDA tuneSpeed          ; Set tuneProgress = tuneProgress + tuneSpeed
 CLC                    ;
 ADC tuneProgress       ; This moves the tune along by the current speed,
 STA tuneProgress       ; setting the C flag only when the addition of this
                        ; iteration's speed overflows the addition
                        ;
                        ; This ensures that we only send music to the APU once
                        ; every 256 / tuneSpeed iterations, which keeps the
                        ; music in sync and sends the music more regularly with
                        ; higher values of tuneSpeed

 BCC makm2              ; If the addition didn't overflow, jump to makm2 to skip
                        ; playing music in this VBlank

 JSR MakeMusicOnSQ1     ; Play the current music on the SQ1 channel

 JSR MakeMusicOnSQ2     ; Play the current music on the SQ2 channel

 JSR MakeMusicOnTRI     ; Play the current music on the TRI channel

 JSR MakeMusicOnNOISE   ; Play the current music on the NOISE channel

.makm2

 JSR ApplyEnvelopeSQ1   ; Apply volume and pitch changes to the SQ1 channel

 JSR ApplyEnvelopeSQ2   ; Apply volume and pitch changes to the SQ2 channel

 JSR ApplyEnvelopeTRI   ; Apply volume and pitch changes to the TRI channel

 JMP ApplyEnvelopeNOISE ; Apply volume and pitch changes to the NOISE channel,
                        ; returning from the subroutine using a tail call

; ******************************************************************************
;
;       Name: MakeMusicOnSQ1
;       Type: Subroutine
;   Category: Sound
;    Summary: Play the current music on the SQ1 channel
;  Deep dive: Music in NES Elite
;
; ******************************************************************************

.MakeMusicOnSQ1

 DEC pauseCountSQ1      ; Decrement the sound counter for SQ1

 BEQ muso1              ; If the counter has reached zero, jump to muso1 to make
                        ; music on the SQ1 channel

 RTS                    ; Otherwise return from the subroutine

.muso1

 LDA sectionDataSQ1     ; Set soundAddr(1 0) = sectionDataSQ1(1 0)
 STA soundAddr          ;
 LDA sectionDataSQ1+1   ; So soundAddr(1 0) points to the note data for this
 STA soundAddr+1        ; part of the tune

 LDA #0                 ; Set sq1Sweep = 0
 STA sq1Sweep

 STA applyVolumeSQ1     ; Set applyVolumeSQ1 = 0 so we don't apply the volume
                        ; envelope by default (this gets changed if we process
                        ; note data below, as opposed to a command)

.muso2

 LDY #0                 ; Set Y to the next entry from the note data
 LDA (soundAddr),Y
 TAY

 INC soundAddr          ; Increment soundAddr(1 0) to point to the next entry
 BNE muso3              ; in the note data
 INC soundAddr+1

.muso3

 TYA                    ; Set A to the next entry that we just fetched from the
                        ; note data

 BMI muso8              ; If bit 7 of A is set then this is a command byte, so
                        ; jump to muso8 to process it

 CMP #$60               ; If the note data in A is less than $60, jump to muso4
 BCC muso4

 ADC #$A0               ; The note data in A is between $60 and $7F, so set the
 STA startPauseSQ1      ; following:
                        ;
                        ;    startPauseSQ1 = A - $5F
                        ;
                        ; We know the C flag is set as we just passed through a
                        ; BCC, so the ADC actually adds $A1, which is the same
                        ; as subtracting $5F
                        ;
                        ; So this sets startPauseSQ1 to a value between 1 and
                        ; 32, corresponding to note data values between $60 and
                        ; $7F

 JMP muso2              ; Jump back to muso2 to move on to the next entry from
                        ; the note data

.muso4

                        ; If we get here then the note data in A is less than
                        ; $60, which denotes a sound to send to the APU, so we
                        ; now convert the data to a frequency and send it to the
                        ; APU to make a sound on channel SQ1

 CLC                    ; Set Y = (A + tuningAll + tuningSQ1) * 2
 ADC tuningAll
 CLC
 ADC tuningSQ1
 ASL A
 TAY

 LDA noteFrequency,Y    ; Set (sq1Hi sq1Lo) the frequency for note Y
 STA sq1LoCopy          ;
 STA sq1Lo              ; Also save a copy of the low byte in sq1LoCopy
 LDA noteFrequency+1,Y
 STA sq1Hi

 LDX effectOnSQ1        ; If effectOnSQ1 is non-zero then a sound effect is
 BNE muso5              ; being made on channel SQ1, so jump to muso5 to skip
                        ; writing the music data to the APU (so sound effects
                        ; take precedence over music)

 LDX sq1Sweep           ; Send sq1Sweep to the APU via SQ1_SWEEP
 STX SQ1_SWEEP

 LDX sq1Lo              ; Send (sq1Hi sq1Lo) to the APU via SQ1_HI and SQ1_LO
 STX SQ1_LO
 STA SQ1_HI

.muso5

 LDA #1                 ; Set volumeIndexSQ1 = 1
 STA volumeIndexSQ1

 LDA volumeRepeatSQ1    ; Set volumeCounterSQ1 = volumeRepeatSQ1
 STA volumeCounterSQ1

.muso6

 LDA #$FF               ; Set applyVolumeSQ1 = $FF so we apply the volume
 STA applyVolumeSQ1     ; envelope in the next iteration

.muso7

 LDA soundAddr          ; Set sectionDataSQ1(1 0) = soundAddr(1 0)
 STA sectionDataSQ1     ;
 LDA soundAddr+1        ; This updates the pointer to the note data for the
 STA sectionDataSQ1+1   ; channel, so the next time we can pick up where we left
                        ; off

 LDA startPauseSQ1      ; Set pauseCountSQ1 = startPauseSQ1
 STA pauseCountSQ1      ;
                        ; So if startPauseSQ1 is non-zero (as set by note data
                        ; the range $60 to $7F), the next startPauseSQ1
                        ; iterations of MakeMusicOnSQ1 will do nothing

 RTS                    ; Return from the subroutine

.muso8

                        ; If we get here then bit 7 of the note data in A is
                        ; set, so this is a command byte

 LDY #0                 ; Set Y = 0, so we can use it in various commands below

 CMP #$FF               ; If A is not $FF, jump to muso10 to check for the next
 BNE muso10             ; command

                        ; If we get here then the command in A is $FF
                        ;
                        ; <$FF> moves to the next section in the current tune

 LDA nextSectionSQ1     ; Set soundAddr(1 0) to the following:
 CLC                    ;
 ADC sectionListSQ1     ;   sectionListSQ1(1 0) + nextSectionSQ1(1 0)
 STA soundAddr          ;
 LDA nextSectionSQ1+1   ; So soundAddr(1 0) points to the address of the next
 ADC sectionListSQ1+1   ; section in the current tune
 STA soundAddr+1        ;
                        ; So if we are playing tune 2 and nextSectionSQ1(1 0)
                        ; points to the second section, then soundAddr(1 0)
                        ; will now point to the second address in tune2Data_SQ1,
                        ; which itself points to the note data for the second
                        ; section at tune2Data_SQ1_1

 LDA nextSectionSQ1     ; Set nextSectionSQ1(1 0) = nextSectionSQ1(1 0) + 2
 ADC #2                 ;
 STA nextSectionSQ1     ; So nextSectionSQ1(1 0) now points to the next section,
 TYA                    ; as each section consists of two bytes in the table at
 ADC nextSectionSQ1+1   ; sectionListSQ1(1 0)
 STA nextSectionSQ1+1

 LDA (soundAddr),Y      ; If the address at soundAddr(1 0) is non-zero then it
 INY                    ; contains a valid address to the section's note data,
 ORA (soundAddr),Y      ; so jump to muso9 to skip the following
 BNE muso9              ;
                        ; This also increments the index in Y to 1

                        ; If we get here then the command is trying to move to
                        ; the next section, but that section contains value of
                        ; $0000 in the tuneData table, so there is no next
                        ; section and we have reached the end of the tune, so
                        ; instead we jump back to the start of the tune

 LDA sectionListSQ1     ; Set soundAddr(1 0) = sectionListSQ1(1 0)
 STA soundAddr          ;
 LDA sectionListSQ1+1   ; So we start again by pointing soundAddr(1 0) to the
 STA soundAddr+1        ; first entry in the section list for channel SQ1, which
                        ; contains the address of the first section's note data

 LDA #2                 ; Set nextSectionSQ1(1 0) = 2
 STA nextSectionSQ1     ;
 LDA #0                 ; So the next section after we play the first section
 STA nextSectionSQ1+1   ; will be the second section

.muso9

                        ; By this point, Y has been incremented to 1

 LDA (soundAddr),Y      ; Set soundAddr(1 0) to the address at soundAddr(1 0)
 TAX                    ;
 DEY                    ; As we pointed soundAddr(1 0) to the address of the
 LDA (soundAddr),Y      ; new section above, this fetches the first address from
 STA soundAddr          ; the new section's address list, which points to the
 STX soundAddr+1        ; new section's note data
                        ;
                        ; So soundAddr(1 0) now points to the note data for the
                        ; new section, so we're ready to start processing notes
                        ; and commands when we rejoin the muso2 loop

 JMP muso2              ; Jump back to muso2 to start processing data from the
                        ; new section

.muso10

 CMP #$F6               ; If A is not $F6, jump to muso12 to check for the next
 BNE muso12             ; command

                        ; If we get here then the command in A is $F6
                        ;
                        ; <$F6 $xx> sets the volume envelope number to $xx

 LDA (soundAddr),Y      ; Fetch the next entry in the note data into A

 INC soundAddr          ; Increment soundAddr(1 0) to point to the next entry
 BNE muso11             ; in the note data
 INC soundAddr+1

.muso11

 STA volumeEnvelopeSQ1  ; Set volumeEnvelopeSQ1 to the volume envelope number
                        ; that we just fetched

 JMP muso2              ; Jump back to muso2 to move on to the next entry from
                        ; the note data

.muso12

 CMP #$F7               ; If A is not $F7, jump to muso14 to check for the next
 BNE muso14             ; command

                        ; If we get here then the command in A is $F7
                        ;
                        ; <$F7 $xx> sets the pitch envelope number to $xx

 LDA (soundAddr),Y      ; Fetch the next entry in the note data into A

 INC soundAddr          ; Increment soundAddr(1 0) to point to the next entry
 BNE muso13             ; in the note data
 INC soundAddr+1

.muso13

 STA pitchEnvelopeSQ1   ; Set pitchEnvelopeSQ1 to the pitch envelope number that
                        ; we just fetched

 STY pitchIndexSQ1      ; Set pitchIndexSQ1 = 0 to point to the start of the
                        ; data for pitch envelope A

 JMP muso2              ; Jump back to muso2 to move on to the next entry from
                        ; the note data

.muso14

 CMP #$FA               ; If A is not $FA, jump to muso16 to check for the next
 BNE muso16             ; command

                        ; If we get here then the command in A is $FA
                        ;
                        ; <$FA %ddlc0000> configures the SQ1 channel as follows:
                        ;
                        ;   * %dd      = duty pulse length
                        ;
                        ;   * %l set   = infinite play
                        ;   * %l clear = one-shot play
                        ;
                        ;   * %c set   = constant volume
                        ;   * %c clear = envelope volume

 LDA (soundAddr),Y      ; Fetch the next entry in the note data into A

 STA dutyLoopEnvSQ1     ; Store the entry we just fetched in dutyLoopEnvSQ1, to
                        ; configure SQ1 as follows:
                        ;
                        ;   * Bits 6-7    = duty pulse length
                        ;
                        ;   * Bit 5 set   = infinite play
                        ;   * Bit 5 clear = one-shot play
                        ;
                        ;   * Bit 4 set   = constant volume
                        ;   * Bit 4 clear = envelope volume

 INC soundAddr          ; Increment soundAddr(1 0) to point to the next entry
 BNE muso15             ; in the note data
 INC soundAddr+1

.muso15

 JMP muso2              ; Jump back to muso2 to move on to the next entry from
                        ; the note data

.muso16

 CMP #$F8               ; If A is not $F8, jump to muso17 to check for the next
 BNE muso17             ; command

                        ; If we get here then the command in A is $F8
                        ;
                        ; <$F8> sets the volume of the SQ1 channel to zero

 LDA #%00110000         ; Set the volume of the SQ1 channel to zero as follows:
 STA sq1Volume          ;
                        ;   * Bits 6-7    = duty pulse length is 3
                        ;   * Bit 5 set   = infinite play
                        ;   * Bit 4 set   = constant volume
                        ;   * Bits 0-3    = volume is 0

 JMP muso7              ; Jump to muso7 to return from the subroutine, so we
                        ; continue on from the next entry from the note data in
                        ; the next iteration

.muso17

 CMP #$F9               ; If A is not $F9, jump to muso18 to check for the next
 BNE muso18             ; command

                        ; If we get here then the command in A is $F9
                        ;
                        ; <$F9> enables the volume envelope for the SQ1 channel

 JMP muso6              ; Jump to muso6 to return from the subroutine after
                        ; setting applyVolumeSQ1 to $FF, so we apply the volume
                        ; envelope, and then continue on from the next entry
                        ; from the note data in the next iteration

.muso18

 CMP #$FD               ; If A is not $FD, jump to muso20 to check for the next
 BNE muso20             ; command

                        ; If we get here then the command in A is $FD
                        ;
                        ; <$F4 $xx> sets the SQ1 sweep to $xx

 LDA (soundAddr),Y      ; Fetch the next entry in the note data into A

 INC soundAddr          ; Increment soundAddr(1 0) to point to the next entry
 BNE muso19             ; in the note data
 INC soundAddr+1

.muso19

 STA sq1Sweep           ; Store the entry we just fetched in sq1Sweep, which
                        ; gets sent to the APU via SQ1_SWEEP

 JMP muso2              ; Jump back to muso2 to move on to the next entry from
                        ; the note data

.muso20

 CMP #$FB               ; If A is not $FB, jump to muso22 to check for the next
 BNE muso22             ; command

                        ; If we get here then the command in A is $FB
                        ;
                        ; <$FB $xx> sets the tuning for all channels to $xx

 LDA (soundAddr),Y      ; Fetch the next entry in the note data into A

 INC soundAddr          ; Increment soundAddr(1 0) to point to the next entry
 BNE muso21             ; in the note data
 INC soundAddr+1

.muso21

 STA tuningAll          ; Store the entry we just fetched in tuningAll, which
                        ; sets the tuning for the SQ1, SQ2 and TRI channels (so
                        ; this value gets added to every note on those channels)

 JMP muso2              ; Jump back to muso2 to move on to the next entry from
                        ; the note data

.muso22

 CMP #$FC               ; If A is not $FC, jump to muso24 to check for the next
 BNE muso24             ; command

                        ; If we get here then the command in A is $FC
                        ;
                        ; <$FC $xx> sets the tuning for the SQ1 channel to $xx

 LDA (soundAddr),Y      ; Fetch the next entry in the note data into A

 INC soundAddr          ; Increment soundAddr(1 0) to point to the next entry
 BNE muso23             ; in the note data
 INC soundAddr+1

.muso23

 STA tuningSQ1          ; Store the entry we just fetched in tuningSQ1, which
                        ; sets the tuning for the SQ1 channel (so this value
                        ; gets added to every note on those channels)

 JMP muso2              ; Jump back to muso2 to move on to the next entry from
                        ; the note data

.muso24

 CMP #$F5               ; If A is not $F5, jump to muso25 to check for the next
 BNE muso25             ; command

                        ; If we get here then the command in A is $F5
                        ;
                        ; <$F5 $xx &yy> changes tune to the tune data at &yyxx
                        ;
                        ; It does this by setting sectionListSQ1(1 0) to &yyxx
                        ; and soundAddr(1 0) to the address stored in &yyxx
                        ;
                        ; To see why this works, consider switching to tune 2,
                        ; for which we would use this command:
                        ;
                        ;   <$F5 LO(tune2Data_SQ1) LO(tune2Data_SQ1)>
                        ;
                        ; This sets:
                        ;
                        ;   sectionListSQ1(1 0) = tune2Data_SQ1
                        ;
                        ; so from now on we fetch the addresses for each section
                        ; of the tune from the table at tune2Data_SQ1
                        ;
                        ; It also sets soundAddr(1 0) to the address in the
                        ; first two bytes of tune2Data_SQ1, to give:
                        ;
                        ;   soundAddr(1 0) = tune2Data_SQ1_0
                        ;
                        ; So from this point on, note data is fetched from the
                        ; table at tune2Data_SQ1_0, which contains notes and
                        ; commands for the first section of tune 2

 LDA (soundAddr),Y      ; Fetch the next entry in the note data into A

 TAX                    ; Set sectionListSQ1(1 0) = &yyxx
 STA sectionListSQ1     ;
 INY                    ; Also set soundAddr(1 0) to &yyxx and increment the
 LDA (soundAddr),Y      ; index in Y to 1, both of which we use below
 STX soundAddr
 STA soundAddr+1
 STA sectionListSQ1+1

 LDA #2                 ; Set nextSectionSQ1(1 0) = 2
 STA nextSectionSQ1     ;
 DEY                    ; So the next section after we play the first section
 STY nextSectionSQ1+1   ; of the new tune will be the second section
                        ;
                        ; Also decrement the index in Y back to 0

 LDA (soundAddr),Y      ; Set soundAddr(1 0) to the address stored at &yyxx
 TAX
 INY
 LDA (soundAddr),Y
 STA soundAddr+1
 STX soundAddr

 JMP muso2              ; Jump back to muso2 to move on to the next entry from
                        ; the note data

.muso25

 CMP #$F4               ; If A is not $F4, jump to muso27 to check for the next
 BNE muso27             ; command

                        ; If we get here then the command in A is $F4
                        ;
                        ; <$F4 $xx> sets the playback speed to $xx

 LDA (soundAddr),Y      ; Fetch the next entry in the note data into A, which
                        ; contains the new speed

 INC soundAddr          ; Increment soundAddr(1 0) to point to the next entry
 BNE muso26             ; in the note data
 INC soundAddr+1

.muso26

 STA tuneSpeed          ; Set tuneSpeed and tuneSpeedCopy to A, to change the
 STA tuneSpeedCopy      ; speed of the current tune to the specified speed

 JMP muso2              ; Jump back to muso2 to move on to the next entry from
                        ; the note data

.muso27

 CMP #$FE               ; If A is not $FE, jump to muso28 to check for the next
 BNE muso28             ; command

                        ; If we get here then the command in A is $FE
                        ;
                        ; <$FE> stops the music and disables sound

 STY playMusic          ; Set playMusic = 0 to stop playing the current tune, so
                        ; only a new call to ChooseMusic will start the music
                        ; again

 PLA                    ; Pull the return address from the stack, so the RTS
 PLA                    ; instruction at the end of StopSounds actually returns
                        ; from the subroutine that called MakeMusic, so we stop
                        ; the music and return to the MakeSounds routine (which
                        ; is the only routine that calls MakeMusic)

 JMP StopSoundsS        ; Jump to StopSounds via StopSoundsS to stop the music
                        ; and return to the MakeSounds routine

.muso28

 BEQ muso28             ; If we get here then bit 7 of A was set but the value
                        ; didn't match any of the checks above, so this
                        ; instruction does nothing and we fall through into
                        ; ApplyEnvelopeSQ1, ignoring the data in A
                        ;
                        ; I'm not sure why the instruction here is an infinite
                        ; loop, but luckily it isn't triggered as A is never
                        ; zero at this point

; ******************************************************************************
;
;       Name: ApplyEnvelopeSQ1
;       Type: Subroutine
;   Category: Sound
;    Summary: Apply volume and pitch changes to the SQ1 channel
;  Deep dive: Music in NES Elite
;
; ******************************************************************************

.ApplyEnvelopeSQ1

 LDA applyVolumeSQ1     ; If applyVolumeSQ1 = 0 then we do not apply the volume
 BEQ musv2              ; envelope, so jump to musv2 to move on to the pitch
                        ; envelope

 LDX volumeEnvelopeSQ1  ; Set X to the number of the volume envelope to apply

 LDA volumeEnvelopeLo,X ; Set soundAddr(1 0) to the address of the data for
 STA soundAddr          ; volume envelope X from the (i.e. volumeEnvelope0 for
 LDA volumeEnvelopeHi,X ; envelope 0, volumeEnvelope1 for envelope 1, and so on)
 STA soundAddr+1

 LDY #0                 ; Set volumeRepeatSQ1 to the first byte of envelope
 LDA (soundAddr),Y      ; data, which contains the number of times to repeat
 STA volumeRepeatSQ1    ; each entry in the envelope

 LDY volumeIndexSQ1     ; Set A to the byte of envelope data at the index in
 LDA (soundAddr),Y      ; volumeIndexSQ1, which we increment to move through the
                        ; data one byte at a time

 BMI musv1              ; If bit 7 of A is set then we just fetched the last
                        ; byte of envelope data, so jump to musv1 to skip the
                        ; following

 DEC volumeCounterSQ1   ; Decrement the counter for this envelope byte

 BPL musv1              ; If the counter is still positive, then we haven't yet
                        ; done all the repeats for this envelope byte, so jump
                        ; to musv1 to skip the following

                        ; Otherwise this is the last repeat for this byte of
                        ; envelope data, so now we reset the counter and move
                        ; on to the next byte

 LDX volumeRepeatSQ1    ; Reset the repeat counter for this envelope to the
 STX volumeCounterSQ1   ; first byte of envelope data that we fetched above,
                        ; which contains the number of times to repeat each
                        ; entry in the envelope

 INC volumeIndexSQ1     ; Increment the index into the volume envelope so we
                        ; move on to the next byte of data in the next iteration

.musv1

 AND #%00001111         ; Extract the low nibble from the envelope data, which
                        ; contains the volume level

 ORA dutyLoopEnvSQ1     ; Set the high nibble of A to dutyLoopEnvSQ1, which gets
                        ; set via command byte $FA and which contains the duty,
                        ; loop and NES envelope settings to send to the APU

 STA sq1Volume          ; Set sq1Volume to the resulting volume byte so it gets
                        ; sent to the APU via SQ1_VOL

.musv2

                        ; We now move on to the pitch envelope

 LDX pitchEnvelopeSQ1   ; Set X to the number of the pitch envelope to apply

 LDA pitchEnvelopeLo,X  ; Set soundAddr(1 0) to the address of the data for
 STA soundAddr          ; pitch envelope X from the (i.e. pitchEnvelope0 for
 LDA pitchEnvelopeHi,X  ; envelope 0, pitchEnvelope1 for envelope 1, and so on)
 STA soundAddr+1

 LDY pitchIndexSQ1      ; Set A to the byte of envelope data at the index in
 LDA (soundAddr),Y      ; pitchIndexSQ1, which we increment to move through the
                        ; data one byte at a time

 CMP #$80               ; If A is not $80 then we just fetched a valid byte of
 BNE musv3              ; envelope data, so jump to musv3 to process it

                        ; If we get here then we just fetched a $80 from the
                        ; pitch envelope, which indicates the end of the list of
                        ; envelope values, so we now loop around to the start of
                        ; the list, so it keeps repeating

 LDY #0                 ; Set pitchIndexSQ1 = 0 to point to the start of the
 STY pitchIndexSQ1      ; data for pitch envelope X

 LDA (soundAddr),Y      ; Set A to the byte of envelope data at index 0, so we
                        ; can fall through into musv3 to process it

.musv3

 INC pitchIndexSQ1      ; Increment the index into the pitch envelope so we
                        ; move on to the next byte of data in the next iteration

 CLC                    ; Set sq1Lo = sq1LoCopy + A
 ADC sq1LoCopy          ;
 STA sq1Lo              ; So this alters the low byte of the pitch that we send
                        ; to the APU via SQ1_LO, altering it by the amount in
                        ; the byte of data we just fetched from the pitch
                        ; envelope

 RTS                    ; Return from the subroutine

; ******************************************************************************
;
;       Name: MakeMusicOnSQ2
;       Type: Subroutine
;   Category: Sound
;    Summary: Play the current music on the SQ2 channel
;  Deep dive: Music in NES Elite
;
; ******************************************************************************

.MakeMusicOnSQ2

 DEC pauseCountSQ2      ; Decrement the sound counter for SQ2

 BEQ must1              ; If the counter has reached zero, jump to must1 to make
                        ; music on the SQ2 channel

 RTS                    ; Otherwise return from the subroutine

.must1

 LDA sectionDataSQ2     ; Set soundAddr(1 0) = sectionDataSQ2(1 0)
 STA soundAddr          ;
 LDA sectionDataSQ2+1   ; So soundAddr(1 0) points to the note data for this
 STA soundAddr+1        ; part of the tune

 LDA #0                 ; Set sq2Sweep = 0
 STA sq2Sweep

 STA applyVolumeSQ2     ; Set applyVolumeSQ2 = 0 so we don't apply the volume
                        ; envelope by default (this gets changed if we process
                        ; note data below, as opposed to a command)

.must2

 LDY #0                 ; Set Y to the next entry from the note data
 LDA (soundAddr),Y
 TAY

 INC soundAddr          ; Increment soundAddr(1 0) to point to the next entry
 BNE must3              ; in the note data
 INC soundAddr+1

.must3

 TYA                    ; Set A to the next entry that we just fetched from the
                        ; note data

 BMI must8              ; If bit 7 of A is set then this is a command byte, so
                        ; jump to must8 to process it

 CMP #$60               ; If the note data in A is less than $60, jump to must4
 BCC must4

 ADC #$A0               ; The note data in A is between $60 and $7F, so set the
 STA startPauseSQ2      ; following:
                        ;
                        ;    startPauseSQ2 = A - $5F
                        ;
                        ; We know the C flag is set as we just passed through a
                        ; BCC, so the ADC actually adds $A1, which is the same
                        ; as subtracting $5F
                        ;
                        ; So this sets startPauseSQ2 to a value between 1 and
                        ; 32, corresponding to note data values between $60 and
                        ; $7F

 JMP must2              ; Jump back to must2 to move on to the next entry from
                        ; the note data

.must4

                        ; If we get here then the note data in A is less than
                        ; $60, which denotes a sound to send to the APU, so we
                        ; now convert the data to a frequency and send it to the
                        ; APU to make a sound on channel SQ2

 CLC                    ; Set Y = (A + tuningAll + tuningSQ2) * 2
 ADC tuningAll
 CLC
 ADC tuningSQ2
 ASL A
 TAY

 LDA noteFrequency,Y    ; Set (sq2Hi sq2Lo) the frequency for note Y
 STA sq2LoCopy          ;
 STA sq2Lo              ; Also save a copy of the low byte in sq2LoCopy
 LDA noteFrequency+1,Y
 STA sq2Hi

 LDX effectOnSQ2        ; If effectOnSQ2 is non-zero then a sound effect is
 BNE must5              ; being made on channel SQ2, so jump to must5 to skip
                        ; writing the music data to the APU (so sound effects
                        ; take precedence over music)

 LDX sq2Sweep           ; Send sq2Sweep to the APU via SQ2_SWEEP
 STX SQ2_SWEEP

 LDX sq2Lo              ; Send (sq2Hi sq2Lo) to the APU via SQ2_HI and SQ2_LO
 STX SQ2_LO
 STA SQ2_HI

.must5

 LDA #1                 ; Set volumeIndexSQ2 = 1
 STA volumeIndexSQ2

 LDA volumeRepeatSQ2    ; Set volumeCounterSQ2 = volumeRepeatSQ2
 STA volumeCounterSQ2

.must6

 LDA #$FF               ; Set applyVolumeSQ2 = $FF so we apply the volume
 STA applyVolumeSQ2     ; envelope in the next iteration

.must7

 LDA soundAddr          ; Set sectionDataSQ2(1 0) = soundAddr(1 0)
 STA sectionDataSQ2     ;
 LDA soundAddr+1        ; This updates the pointer to the note data for the
 STA sectionDataSQ2+1   ; channel, so the next time we can pick up where we left
                        ; off

 LDA startPauseSQ2      ; Set pauseCountSQ2 = startPauseSQ2
 STA pauseCountSQ2      ;
                        ; So if startPauseSQ2 is non-zero (as set by note data
                        ; the range $60 to $7F), the next startPauseSQ2
                        ; iterations of MakeMusicOnSQ2 will do nothing

 RTS                    ; Return from the subroutine

.must8

                        ; If we get here then bit 7 of the note data in A is
                        ; set, so this is a command byte

 LDY #0                 ; Set Y = 0, so we can use it in various commands below

 CMP #$FF               ; If A is not $FF, jump to must10 to check for the next
 BNE must10             ; command

                        ; If we get here then the command in A is $FF
                        ;
                        ; <$FF> moves to the next section in the current tune

 LDA nextSectionSQ2     ; Set soundAddr(1 0) to the following:
 CLC                    ;
 ADC sectionListSQ2     ;   sectionListSQ2(1 0) + nextSectionSQ2(1 0)
 STA soundAddr          ;
 LDA nextSectionSQ2+1   ; So soundAddr(1 0) points to the address of the next
 ADC sectionListSQ2+1   ; section in the current tune
 STA soundAddr+1        ;
                        ; So if we are playing tune 2 and nextSectionSQ2(1 0)
                        ; points to the second section, then soundAddr(1 0)
                        ; will now point to the second address in tune2Data_SQ2,
                        ; which itself points to the note data for the second
                        ; section at tune2Data_SQ2_1

 LDA nextSectionSQ2     ; Set nextSectionSQ2(1 0) = nextSectionSQ2(1 0) + 2
 ADC #2                 ;
 STA nextSectionSQ2     ; So nextSectionSQ2(1 0) now points to the next section,
 TYA                    ; as each section consists of two bytes in the table at
 ADC nextSectionSQ2+1   ; sectionListSQ2(1 0)
 STA nextSectionSQ2+1

 LDA (soundAddr),Y      ; If the address at soundAddr(1 0) is non-zero then it
 INY                    ; contains a valid address to the section's note data,
 ORA (soundAddr),Y      ; so jump to must9 to skip the following
 BNE must9              ;
                        ; This also increments the index in Y to 1

                        ; If we get here then the command is trying to move to
                        ; the next section, but that section contains value of
                        ; $0000 in the tuneData table, so there is no next
                        ; section and we have reached the end of the tune, so
                        ; instead we jump back to the start of the tune

 LDA sectionListSQ2     ; Set soundAddr(1 0) = sectionListSQ2(1 0)
 STA soundAddr          ;
 LDA sectionListSQ2+1   ; So we start again by pointing soundAddr(1 0) to the
 STA soundAddr+1        ; first entry in the section list for channel SQ2, which
                        ; contains the address of the first section's note data

 LDA #2                 ; Set nextSectionSQ2(1 0) = 2
 STA nextSectionSQ2     ;
 LDA #0                 ; So the next section after we play the first section
 STA nextSectionSQ2+1   ; will be the second section

.must9

                        ; By this point, Y has been incremented to 1

 LDA (soundAddr),Y      ; Set soundAddr(1 0) to the address at soundAddr(1 0)
 TAX                    ;
 DEY                    ; As we pointed soundAddr(1 0) to the address of the
 LDA (soundAddr),Y      ; new section above, this fetches the first address from
 STA soundAddr          ; the new section's address list, which points to the
 STX soundAddr+1        ; new section's note data
                        ;
                        ; So soundAddr(1 0) now points to the note data for the
                        ; new section, so we're ready to start processing notes
                        ; and commands when we rejoin the must2 loop

 JMP must2              ; Jump back to must2 to start processing data from the
                        ; new section

.must10

 CMP #$F6               ; If A is not $F6, jump to must12 to check for the next
 BNE must12             ; command

                        ; If we get here then the command in A is $F6
                        ;
                        ; <$F6 $xx> sets the volume envelope number to $xx

 LDA (soundAddr),Y      ; Fetch the next entry in the note data into A

 INC soundAddr          ; Increment soundAddr(1 0) to point to the next entry
 BNE must11             ; in the note data
 INC soundAddr+1

.must11

 STA volumeEnvelopeSQ2  ; Set volumeEnvelopeSQ2 to the volume envelope number
                        ; that we just fetched

 JMP must2              ; Jump back to must2 to move on to the next entry from
                        ; the note data

.must12

 CMP #$F7               ; If A is not $F7, jump to must14 to check for the next
 BNE must14             ; command

                        ; If we get here then the command in A is $F7
                        ;
                        ; <$F7 $xx> sets the pitch envelope number to $xx

 LDA (soundAddr),Y      ; Fetch the next entry in the note data into A

 INC soundAddr          ; Increment soundAddr(1 0) to point to the next entry
 BNE must13             ; in the note data
 INC soundAddr+1

.must13

 STA pitchEnvelopeSQ2   ; Set pitchEnvelopeSQ2 to the pitch envelope number that
                        ; we just fetched

 STY pitchIndexSQ2      ; Set pitchIndexSQ2 = 0 to point to the start of the
                        ; data for pitch envelope A

 JMP must2              ; Jump back to must2 to move on to the next entry from
                        ; the note data

.must14

 CMP #$FA               ; If A is not $FA, jump to must16 to check for the next
 BNE must16             ; command

                        ; If we get here then the command in A is $FA
                        ;
                        ; <$FA %ddlc0000> configures the SQ2 channel as follows:
                        ;
                        ;   * %dd      = duty pulse length
                        ;
                        ;   * %l set   = infinite play
                        ;   * %l clear = one-shot play
                        ;
                        ;   * %c set   = constant volume
                        ;   * %c clear = envelope volume

 LDA (soundAddr),Y      ; Fetch the next entry in the note data into A

 STA dutyLoopEnvSQ2     ; Store the entry we just fetched in dutyLoopEnvSQ2, to
                        ; configure SQ2 as follows:
                        ;
                        ;   * Bits 6-7    = duty pulse length
                        ;
                        ;   * Bit 5 set   = infinite play
                        ;   * Bit 5 clear = one-shot play
                        ;
                        ;   * Bit 4 set   = constant volume
                        ;   * Bit 4 clear = envelope volume

 INC soundAddr          ; Increment soundAddr(1 0) to point to the next entry
 BNE must15             ; in the note data
 INC soundAddr+1

.must15

 JMP must2              ; Jump back to must2 to move on to the next entry from
                        ; the note data

.must16

 CMP #$F8               ; If A is not $F8, jump to must17 to check for the next
 BNE must17             ; command

                        ; If we get here then the command in A is $F8
                        ;
                        ; <$F8> sets the volume of the SQ2 channel to zero

 LDA #%00110000         ; Set the volume of the SQ2 channel to zero as follows:
 STA sq2Volume          ;
                        ;   * Bits 6-7    = duty pulse length is 3
                        ;   * Bit 5 set   = infinite play
                        ;   * Bit 4 set   = constant volume
                        ;   * Bits 0-3    = volume is 0

 JMP must7              ; Jump to must7 to return from the subroutine, so we
                        ; continue on from the next entry from the note data in
                        ; the next iteration

.must17

 CMP #$F9               ; If A is not $F9, jump to must18 to check for the next
 BNE must18             ; command

                        ; If we get here then the command in A is $F9
                        ;
                        ; <$F9> enables the volume envelope for the SQ2 channel

 JMP must6              ; Jump to must6 to return from the subroutine after
                        ; setting applyVolumeSQ2 to $FF, so we apply the volume
                        ; envelope, and then continue on from the next entry
                        ; from the note data in the next iteration

.must18

 CMP #$FD               ; If A is not $FD, jump to must20 to check for the next
 BNE must20             ; command

                        ; If we get here then the command in A is $FD
                        ;
                        ; <$F4 $xx> sets the SQ2 sweep to $xx

 LDA (soundAddr),Y      ; Fetch the next entry in the note data into A

 INC soundAddr          ; Increment soundAddr(1 0) to point to the next entry
 BNE must19             ; in the note data
 INC soundAddr+1

.must19

 STA sq2Sweep           ; Store the entry we just fetched in sq2Sweep, which
                        ; gets sent to the APU via SQ2_SWEEP

 JMP must2              ; Jump back to must2 to move on to the next entry from
                        ; the note data

.must20

 CMP #$FB               ; If A is not $FB, jump to must22 to check for the next
 BNE must22             ; command

                        ; If we get here then the command in A is $FB
                        ;
                        ; <$FB $xx> sets the tuning for all channels to $xx

 LDA (soundAddr),Y      ; Fetch the next entry in the note data into A

 INC soundAddr          ; Increment soundAddr(1 0) to point to the next entry
 BNE must21             ; in the note data
 INC soundAddr+1

.must21

 STA tuningAll          ; Store the entry we just fetched in tuningAll, which
                        ; sets the tuning for the SQ2, SQ2 and TRI channels (so
                        ; this value gets added to every note on those channels)

 JMP must2              ; Jump back to must2 to move on to the next entry from
                        ; the note data

.must22

 CMP #$FC               ; If A is not $FC, jump to must24 to check for the next
 BNE must24             ; command

                        ; If we get here then the command in A is $FC
                        ;
                        ; <$FC $xx> sets the tuning for the SQ2 channel to $xx

 LDA (soundAddr),Y      ; Fetch the next entry in the note data into A

 INC soundAddr          ; Increment soundAddr(1 0) to point to the next entry
 BNE must23             ; in the note data
 INC soundAddr+1

.must23

 STA tuningSQ2          ; Store the entry we just fetched in tuningSQ2, which
                        ; sets the tuning for the SQ2 channel (so this value
                        ; gets added to every note on those channels)

 JMP must2              ; Jump back to must2 to move on to the next entry from
                        ; the note data

.must24

 CMP #$F5               ; If A is not $F5, jump to must25 to check for the next
 BNE must25             ; command

                        ; If we get here then the command in A is $F5
                        ;
                        ; <$F5 $xx &yy> changes tune to the tune data at &yyxx
                        ;
                        ; It does this by setting sectionListSQ2(1 0) to &yyxx
                        ; and soundAddr(1 0) to the address stored in &yyxx
                        ;
                        ; To see why this works, consider switching to tune 2,
                        ; for which we would use this command:
                        ;
                        ;   <$F5 LO(tune2Data_SQ2) HI(tune2Data_SQ2)>
                        ;
                        ; This sets:
                        ;
                        ;   sectionListSQ2(1 0) = tune2Data_SQ2
                        ;
                        ; so from now on we fetch the addresses for each section
                        ; of the tune from the table at tune2Data_SQ2
                        ;
                        ; It also sets soundAddr(1 0) to the address in the
                        ; first two bytes of tune2Data_SQ2, to give:
                        ;
                        ;   soundAddr(1 0) = tune2Data_SQ2_0
                        ;
                        ; So from this point on, note data is fetched from the
                        ; table at tune2Data_SQ2_0, which contains notes and
                        ; commands for the first section of tune 2

 LDA (soundAddr),Y      ; Fetch the next entry in the note data into A

 TAX                    ; Set sectionListSQ2(1 0) = &yyxx
 STA sectionListSQ2     ;
 INY                    ; Also set soundAddr(1 0) to &yyxx and increment the
 LDA (soundAddr),Y      ; index in Y to 1, both of which we use below
 STX soundAddr
 STA soundAddr+1
 STA sectionListSQ2+1

 LDA #2                 ; Set nextSectionSQ2(1 0) = 2
 STA nextSectionSQ2     ;
 DEY                    ; So the next section after we play the first section
 STY nextSectionSQ2+1   ; of the new tune will be the second section
                        ;
                        ; Also decrement the index in Y back to 0

 LDA (soundAddr),Y      ; Set soundAddr(1 0) to the address stored at &yyxx
 TAX
 INY
 LDA (soundAddr),Y
 STA soundAddr+1
 STX soundAddr

 JMP must2              ; Jump back to must2 to move on to the next entry from
                        ; the note data

.must25

 CMP #$F4               ; If A is not $F4, jump to must27 to check for the next
 BNE must27             ; command

                        ; If we get here then the command in A is $F4
                        ;
                        ; <$F4 $xx> sets the playback speed to $xx

 LDA (soundAddr),Y      ; Fetch the next entry in the note data into A, which
                        ; contains the new speed

 INC soundAddr          ; Increment soundAddr(1 0) to point to the next entry
 BNE must26             ; in the note data
 INC soundAddr+1

.must26

 STA tuneSpeed          ; Set tuneSpeed and tuneSpeedCopy to A, to change the
 STA tuneSpeedCopy      ; speed of the current tune to the specified speed

 JMP must2              ; Jump back to must2 to move on to the next entry from
                        ; the note data

.must27

 CMP #$FE               ; If A is not $FE, jump to must28 to check for the next
 BNE must28             ; command

                        ; If we get here then the command in A is $FE
                        ;
                        ; <$FE> stops the music and disables sound

 STY playMusic          ; Set playMusic = 0 to stop playing the current tune, so
                        ; only a new call to ChooseMusic will start the music
                        ; again

 PLA                    ; Pull the return address from the stack, so the RTS
 PLA                    ; instruction at the end of StopSounds actually returns
                        ; from the subroutine that called MakeMusic, so we stop
                        ; the music and return to the MakeSounds routine (which
                        ; is the only routine that calls MakeMusic)

 JMP StopSoundsS        ; Jump to StopSounds via StopSoundsS to stop the music
                        ; and return to the MakeSounds routine

.must28

 BEQ must28             ; If we get here then bit 7 of A was set but the value
                        ; didn't match any of the checks above, so this
                        ; instruction does nothing and we fall through into
                        ; ApplyEnvelopeSQ2, ignoring the data in A
                        ;
                        ; I'm not sure why the instruction here is an infinite
                        ; loop, but luckily it isn't triggered as A is never
                        ; zero at this point

; ******************************************************************************
;
;       Name: ApplyEnvelopeSQ2
;       Type: Subroutine
;   Category: Sound
;    Summary: Apply volume and pitch changes to the SQ2 channel
;  Deep dive: Music in NES Elite
;
; ******************************************************************************

.ApplyEnvelopeSQ2

 LDA applyVolumeSQ2     ; If applyVolumeSQ2 = 0 then we do not apply the volume
 BEQ muss2              ; envelope, so jump to muss2 to move on to the pitch
                        ; envelope

 LDX volumeEnvelopeSQ2  ; Set X to the number of the volume envelope to apply

 LDA volumeEnvelopeLo,X ; Set soundAddr(1 0) to the address of the data for
 STA soundAddr          ; volume envelope X from the (i.e. volumeEnvelope0 for
 LDA volumeEnvelopeHi,X ; envelope 0, volumeEnvelope1 for envelope 1, and so on)
 STA soundAddr+1

 LDY #0                 ; Set volumeRepeatSQ2 to the first byte of envelope
 LDA (soundAddr),Y      ; data, which contains the number of times to repeat
 STA volumeRepeatSQ2    ; each entry in the envelope

 LDY volumeIndexSQ2     ; Set A to the byte of envelope data at the index in
 LDA (soundAddr),Y      ; volumeIndexSQ2, which we increment to move through the
                        ; data one byte at a time

 BMI muss1              ; If bit 7 of A is set then we just fetched the last
                        ; byte of envelope data, so jump to muss1 to skip the
                        ; following

 DEC volumeCounterSQ2   ; Decrement the counter for this envelope byte

 BPL muss1              ; If the counter is still positive, then we haven't yet
                        ; done all the repeats for this envelope byte, so jump
                        ; to muss1 to skip the following

                        ; Otherwise this is the last repeat for this byte of
                        ; envelope data, so now we reset the counter and move
                        ; on to the next byte

 LDX volumeRepeatSQ2    ; Reset the repeat counter for this envelope to the
 STX volumeCounterSQ2   ; first byte of envelope data that we fetched above,
                        ; which contains the number of times to repeat each
                        ; entry in the envelope

 INC volumeIndexSQ2     ; Increment the index into the volume envelope so we
                        ; move on to the next byte of data in the next iteration

.muss1

 AND #%00001111         ; Extract the low nibble from the envelope data, which
                        ; contains the volume level

 ORA dutyLoopEnvSQ2     ; Set the high nibble of A to dutyLoopEnvSQ2, which gets
                        ; set via command byte $FA and which contains the duty,
                        ; loop and NES envelope settings to send to the APU

 STA sq2Volume          ; Set sq2Volume to the resulting volume byte so it gets
                        ; sent to the APU via SQ2_VOL

.muss2

                        ; We now move on to the pitch envelope

 LDX pitchEnvelopeSQ2   ; Set X to the number of the pitch envelope to apply

 LDA pitchEnvelopeLo,X  ; Set soundAddr(1 0) to the address of the data for
 STA soundAddr          ; pitch envelope X from the (i.e. pitchEnvelope0 for
 LDA pitchEnvelopeHi,X  ; envelope 0, pitchEnvelope1 for envelope 1, and so on)
 STA soundAddr+1

 LDY pitchIndexSQ2      ; Set A to the byte of envelope data at the index in
 LDA (soundAddr),Y      ; pitchIndexSQ2, which we increment to move through the
                        ; data one byte at a time

 CMP #$80               ; If A is not $80 then we just fetched a valid byte of
 BNE muss3              ; envelope data, so jump to muss3 to process it

                        ; If we get here then we just fetched a $80 from the
                        ; pitch envelope, which indicates the end of the list of
                        ; envelope values, so we now loop around to the start of
                        ; the list, so it keeps repeating

 LDY #0                 ; Set pitchIndexSQ2 = 0 to point to the start of the
 STY pitchIndexSQ2      ; data for pitch envelope X

 LDA (soundAddr),Y      ; Set A to the byte of envelope data at index 0, so we
                        ; can fall through into muss3 to process it

.muss3

 INC pitchIndexSQ2      ; Increment the index into the pitch envelope so we
                        ; move on to the next byte of data in the next iteration

 CLC                    ; Set sq2Lo = sq2LoCopy + A
 ADC sq2LoCopy          ;
 STA sq2Lo              ; So this alters the low byte of the pitch that we send
                        ; to the APU via SQ2_LO, altering it by the amount in
                        ; the byte of data we just fetched from the pitch
                        ; envelope

 RTS                    ; Return from the subroutine

; ******************************************************************************
;
;       Name: MakeMusicOnTRI
;       Type: Subroutine
;   Category: Sound
;    Summary: Play the current music on the TRI channel
;  Deep dive: Music in NES Elite
;
; ******************************************************************************

.MakeMusicOnTRI

 DEC pauseCountTRI      ; Decrement the sound counter for TRI

 BEQ musr1              ; If the counter has reached zero, jump to musr1 to make
                        ; music on the TRI channel

 RTS                    ; Otherwise return from the subroutine

.musr1

 LDA sectionDataTRI     ; Set soundAddr(1 0) = sectionDataTRI(1 0)
 STA soundAddr          ;
 LDA sectionDataTRI+1   ; So soundAddr(1 0) points to the note data for this
 STA soundAddr+1        ; part of the tune

.musr2

 LDY #0                 ; Set Y to the next entry from the note data
 LDA (soundAddr),Y
 TAY

 INC soundAddr          ; Increment soundAddr(1 0) to point to the next entry
 BNE musr3              ; in the note data
 INC soundAddr+1

.musr3

 TYA                    ; Set A to the next entry that we just fetched from the
                        ; note data

 BMI musr6              ; If bit 7 of A is set then this is a command byte, so
                        ; jump to musr6 to process it

 CMP #$60               ; If the note data in A is less than $60, jump to musr4
 BCC musr4

 ADC #$A0               ; The note data in A is between $60 and $7F, so set the
 STA startPauseTRI      ; following:
                        ;
                        ;    startPauseTRI = A - $5F
                        ;
                        ; We know the C flag is set as we just passed through a
                        ; BCC, so the ADC actually adds $A1, which is the same
                        ; as subtracting $5F
                        ;
                        ; So this sets startPauseTRI to a value between 1 and
                        ; 32, corresponding to note data values between $60 and
                        ; $7F

 JMP musr2              ; Jump back to musr2 to move on to the next entry from
                        ; the note data

.musr4

                        ; If we get here then the note data in A is less than
                        ; $60, which denotes a sound to send to the APU, so we
                        ; now convert the data to a frequency and send it to the
                        ; APU to make a sound on channel TRI

 CLC                    ; Set Y = (A + tuningAll + tuningTRI) * 2
 ADC tuningAll
 CLC
 ADC tuningTRI
 ASL A
 TAY

 LDA noteFrequency,Y    ; Set (A triLo) the frequency for note Y
 STA triLoCopy          ;
 STA triLo              ; Also save a copy of the low byte in triLoCopy
 LDA noteFrequency+1,Y

 LDX triLo              ; Send (A triLo) to the APU via TRI_HI and TRI_LO
 STX TRI_LO
 STA TRI_HI

 STA triHi              ; Set (triHi triLo) = (A triLo), though this value is
                        ; never read again, so this has no effect

 LDA volumeEnvelopeTRI  ; Set the counter to the volume change to the value of
 STA volumeCounterTRI   ; volumeEnvelopeTRI, which gets set by the $F6 command

 LDA #%10000001         ; Configure the TRI channel as follows:
 STA TRI_LINEAR         ;
                        ;   * Bit 7 set = reload the linear counter
                        ;
                        ;   * Bits 0-6  = counter reload value of 1
                        ;
                        ; So this enables a cycling triangle wave on the TRI
                        ; channel (so the channel is enabled)

.musr5

 LDA soundAddr          ; Set sectionDataTRI(1 0) = soundAddr(1 0)
 STA sectionDataTRI     ;
 LDA soundAddr+1        ; This updates the pointer to the note data for the
 STA sectionDataTRI+1   ; channel, so the next time we can pick up where we left
                        ; off

 LDA startPauseTRI      ; Set pauseCountTRI = startPauseTRI
 STA pauseCountTRI      ;
                        ; So if startPauseTRI is non-zero (as set by note data
                        ; the range $60 to $7F), the next startPauseTRI
                        ; iterations of MakeMusicOnTRI will do nothing

 RTS                    ; Return from the subroutine

.musr6

                        ; If we get here then bit 7 of the note data in A is
                        ; set, so this is a command byte

 LDY #0                 ; Set Y = 0, so we can use it in various commands below

 CMP #$FF               ; If A is not $FF, jump to musr8 to check for the next
 BNE musr8              ; command

                        ; If we get here then the command in A is $FF
                        ;
                        ; <$FF> moves to the next section in the current tune

 LDA nextSectionTRI     ; Set soundAddr(1 0) to the following:
 CLC                    ;
 ADC sectionListTRI     ;   sectionListTRI(1 0) + nextSectionTRI(1 0)
 STA soundAddr          ;
 LDA nextSectionTRI+1   ; So soundAddr(1 0) points to the address of the next
 ADC sectionListTRI+1   ; section in the current tune
 STA soundAddr+1        ;
                        ; So if we are playing tune 2 and nextSectionTRI(1 0)
                        ; points to the second section, then soundAddr(1 0)
                        ; will now point to the second address in tune2Data_TRI,
                        ; which itself points to the note data for the second
                        ; section at tune2Data_TRI_1

 LDA nextSectionTRI     ; Set nextSectionTRI(1 0) = nextSectionTRI(1 0) + 2
 ADC #2                 ;
 STA nextSectionTRI     ; So nextSectionTRI(1 0) now points to the next section,
 TYA                    ; as each section consists of two bytes in the table at
 ADC nextSectionTRI+1   ; sectionListTRI(1 0)
 STA nextSectionTRI+1

 LDA (soundAddr),Y      ; If the address at soundAddr(1 0) is non-zero then it
 INY                    ; contains a valid address to the section's note data,
 ORA (soundAddr),Y      ; so jump to musr7 to skip the following
 BNE musr7              ;
                        ; This also increments the index in Y to 1

                        ; If we get here then the command is trying to move to
                        ; the next section, but that section contains value of
                        ; $0000 in the tuneData table, so there is no next
                        ; section and we have reached the end of the tune, so
                        ; instead we jump back to the start of the tune

 LDA sectionListTRI     ; Set soundAddr(1 0) = sectionListTRI(1 0)
 STA soundAddr          ;
 LDA sectionListTRI+1   ; So we start again by pointing soundAddr(1 0) to the
 STA soundAddr+1        ; first entry in the section list for channel TRI, which
                        ; contains the address of the first section's note data

 LDA #2                 ; Set nextSectionTRI(1 0) = 2
 STA nextSectionTRI     ;
 LDA #0                 ; So the next section after we play the first section
 STA nextSectionTRI+1   ; will be the second section

.musr7

                        ; By this point, Y has been incremented to 1

 LDA (soundAddr),Y      ; Set soundAddr(1 0) to the address at soundAddr(1 0)
 TAX                    ;
 DEY                    ; As we pointed soundAddr(1 0) to the address of the
 LDA (soundAddr),Y      ; new section above, this fetches the first address from
 STA soundAddr          ; the new section's address list, which points to the
 STX soundAddr+1        ; new section's note data
                        ;
                        ; So soundAddr(1 0) now points to the note data for the
                        ; new section, so we're ready to start processing notes
                        ; and commands when we rejoin the musr2 loop

 JMP musr2              ; Jump back to musr2 to start processing data from the
                        ; new section

.musr8

 CMP #$F6               ; If A is not $F6, jump to musr10 to check for the next
 BNE musr10             ; command

                        ; If we get here then the command in A is $F6
                        ;
                        ; <$F6 $xx> sets the volume envelope counter to $xx
                        ;
                        ; In the other channels, this command lets us choose a
                        ; volume envelope number
                        ;
                        ; In the case of the TRI channel, there isn't a volume
                        ; envelope as such, because the channel is either off or
                        ; on and doesn't have a volume setting, so instead of
                        ; this command choosing a volume envelope number, it
                        ; sets a counter that determines the number of
                        ; iterations before the channel gets silenced
                        ;
                        ; I've kept the variable names in the same format as the
                        ; other channels for consistency

 LDA (soundAddr),Y      ; Fetch the next entry in the note data into A

 INC soundAddr          ; Increment soundAddr(1 0) to point to the next entry
 BNE musr9              ; in the note data
 INC soundAddr+1

.musr9

 STA volumeEnvelopeTRI  ; Set volumeEnvelopeTRI to the volume envelope number
                        ; that we just fetched

 JMP musr2              ; Jump back to musr2 to move on to the next entry from
                        ; the note data

.musr10

 CMP #$F7               ; If A is not $F7, jump to musr12 to check for the next
 BNE musr12             ; command

                        ; If we get here then the command in A is $F7
                        ;
                        ; <$F7 $xx> sets the pitch envelope number to $xx

 LDA (soundAddr),Y      ; Fetch the next entry in the note data into A

 INC soundAddr          ; Increment soundAddr(1 0) to point to the next entry
 BNE musr11             ; in the note data
 INC soundAddr+1

.musr11

 STA pitchEnvelopeTRI   ; Set pitchEnvelopeTRI to the pitch envelope number that
                        ; we just fetched

 STY pitchIndexTRI      ; Set pitchIndexTRI = 0 to point to the start of the
                        ; data for pitch envelope A

 JMP musr2              ; Jump back to musr2 to move on to the next entry from
                        ; the note data

.musr12

 CMP #$F8               ; If A is not $F8, jump to musr13 to check for the next
 BNE musr13             ; command

                        ; If we get here then the command in A is $F8
                        ;
                        ; <$F8> sets the volume of the TRI channel to zero

 LDA #1                 ; Set the counter in volumeCounterTRI to 1, so when we
 STA volumeCounterTRI   ; return from the subroutine and call ApplyEnvelopeTRI,
                        ; the TRI channel gets silenced

 JMP musr5              ; Jump to musr5 to return from the subroutine, so we
                        ; continue on from the next entry from the note data in
                        ; the next iteration

.musr13

 CMP #$F9               ; If A is not $F9, jump to musr14 to check for the next
 BNE musr14             ; command

                        ; If we get here then the command in A is $F9
                        ;
                        ; <$F9> enables the volume envelope for the TRI channel

 JMP musr5              ; Jump to musr5 to return from the subroutine, so we
                        ; continue on from the next entry from the note data in
                        ; the next iteration

.musr14

 CMP #$FB               ; If A is not $FB, jump to musr16 to check for the next
 BNE musr16             ; command

                        ; If we get here then the command in A is $FB
                        ;
                        ; <$FB $xx> sets the tuning for all channels to $xx

 LDA (soundAddr),Y      ; Fetch the next entry in the note data into A

 INC soundAddr          ; Increment soundAddr(1 0) to point to the next entry
 BNE musr15             ; in the note data
 INC soundAddr+1

.musr15

 STA tuningAll          ; Store the entry we just fetched in tuningAll, which
                        ; sets the tuning for the TRI, TRI and TRI channels (so
                        ; this value gets added to every note on those channels)

 JMP musr2              ; Jump back to musr2 to move on to the next entry from
                        ; the note data

.musr16

 CMP #$FC               ; If A is not $FC, jump to musr18 to check for the next
 BNE musr18             ; command

                        ; If we get here then the command in A is $FC
                        ;
                        ; <$FC $xx> sets the tuning for the TRI channel to $xx

 LDA (soundAddr),Y      ; Fetch the next entry in the note data into A

 INC soundAddr          ; Increment soundAddr(1 0) to point to the next entry
 BNE musr17             ; in the note data
 INC soundAddr+1

.musr17

 STA tuningTRI          ; Store the entry we just fetched in tuningTRI, which
                        ; sets the tuning for the TRI channel (so this value
                        ; gets added to every note on those channels)

 JMP musr2              ; Jump back to musr2 to move on to the next entry from
                        ; the note data

.musr18

 CMP #$F5               ; If A is not $F5, jump to musr19 to check for the next
 BNE musr19             ; command

                        ; If we get here then the command in A is $F5
                        ;
                        ; <$F5 $xx &yy> changes tune to the tune data at &yyxx
                        ;
                        ; It does this by setting sectionListTRI(1 0) to &yyxx
                        ; and soundAddr(1 0) to the address stored in &yyxx
                        ;
                        ; To see why this works, consider switching to tune 2,
                        ; for which we would use this command:
                        ;
                        ;   <$F5 LO(tune2Data_TRI) LO(tune2Data_TRI)>
                        ;
                        ; This sets:
                        ;
                        ;   sectionListTRI(1 0) = tune2Data_TRI
                        ;
                        ; so from now on we fetch the addresses for each section
                        ; of the tune from the table at tune2Data_TRI
                        ;
                        ; It also sets soundAddr(1 0) to the address in the
                        ; first two bytes of tune2Data_TRI, to give:
                        ;
                        ;   soundAddr(1 0) = tune2Data_TRI_0
                        ;
                        ; So from this point on, note data is fetched from the
                        ; table at tune2Data_TRI_0, which contains notes and
                        ; commands for the first section of tune 2

 LDA (soundAddr),Y      ; Fetch the next entry in the note data into A

 TAX                    ; Set sectionListTRI(1 0) = &yyxx
 STA sectionListTRI     ;
 INY                    ; Also set soundAddr(1 0) to &yyxx and increment the
 LDA (soundAddr),Y      ; index in Y to 1, both of which we use below
 STX soundAddr
 STA soundAddr+1
 STA sectionListTRI+1

 LDA #2                 ; Set nextSectionTRI(1 0) = 2
 STA nextSectionTRI     ;
 DEY                    ; So the next section after we play the first section
 STY nextSectionTRI+1   ; of the new tune will be the second section
                        ;
                        ; Also decrement the index in Y back to 0

 LDA (soundAddr),Y      ; Set soundAddr(1 0) to the address stored at &yyxx
 TAX
 INY
 LDA (soundAddr),Y
 STA soundAddr+1
 STX soundAddr

 JMP musr2              ; Jump back to musr2 to move on to the next entry from
                        ; the note data

.musr19

 CMP #$F4               ; If A is not $F4, jump to musr21 to check for the next
 BNE musr21             ; command

                        ; If we get here then the command in A is $F4
                        ;
                        ; <$F4 $xx> sets the playback speed to $xx

 LDA (soundAddr),Y      ; Fetch the next entry in the note data into A, which
                        ; contains the new speed

 INC soundAddr          ; Increment soundAddr(1 0) to point to the next entry
 BNE musr20             ; in the note data
 INC soundAddr+1

.musr20

 STA tuneSpeed          ; Set tuneSpeed and tuneSpeedCopy to A, to change the
 STA tuneSpeedCopy      ; speed of the current tune to the specified speed

 JMP musr2              ; Jump back to musr2 to move on to the next entry from
                        ; the note data

.musr21

 CMP #$FE               ; If A is not $FE, jump to musr22 to check for the next
 BNE musr22             ; command

                        ; If we get here then the command in A is $FE
                        ;
                        ; <$FE> stops the music and disables sound

 STY playMusic          ; Set playMusic = 0 to stop playing the current tune, so
                        ; only a new call to ChooseMusic will start the music
                        ; again

 PLA                    ; Pull the return address from the stack, so the RTS
 PLA                    ; instruction at the end of StopSounds actually returns
                        ; from the subroutine that called MakeMusic, so we stop
                        ; the music and return to the MakeSounds routine (which
                        ; is the only routine that calls MakeMusic)

 JMP StopSoundsS        ; Jump to StopSounds via StopSoundsS to stop the music
                        ; and return to the MakeSounds routine

.musr22

 BEQ musr22             ; If we get here then bit 7 of A was set but the value
                        ; didn't match any of the checks above, so this
                        ; instruction does nothing and we fall through into
                        ; ApplyEnvelopeTRI, ignoring the data in A
                        ;
                        ; I'm not sure why the instruction here is an infinite
                        ; loop, but luckily it isn't triggered as A is never
                        ; zero at this point

; ******************************************************************************
;
;       Name: ApplyEnvelopeTRI
;       Type: Subroutine
;   Category: Sound
;    Summary: Apply volume and pitch changes to the TRI channel
;  Deep dive: Music in NES Elite
;
; ******************************************************************************

.ApplyEnvelopeTRI

 LDA volumeCounterTRI   ; If volumeCounterTRI = 0 then we are not counting down
 BEQ muse1              ; to a volume change, so jump to muse1 to move on to the
                        ; pitch envelope

 DEC volumeCounterTRI   ; Decrement the counter for the volume change

 BNE muse1              ; If the counter is still non-zero, then we haven't yet
                        ; done counted down to the volume change, so jump to
                        ; muse1 to skip the following

 LDA #%00000000         ; Configure the TRI channel as follows:
 STA TRI_LINEAR         ;
                        ;   * Bit 7 clear = do not reload the linear counter
                        ;
                        ;   * Bits 0-6    = counter reload value of 0
                        ;
                        ; So this silences the TRI channel

.muse1

                        ; We now move on to the pitch envelope

 LDX pitchEnvelopeTRI   ; Set X to the number of the pitch envelope to apply

 LDA pitchEnvelopeLo,X  ; Set soundAddr(1 0) to the address of the data for
 STA soundAddr          ; pitch envelope X from the (i.e. pitchEnvelope0 for
 LDA pitchEnvelopeHi,X  ; envelope 0, pitchEnvelope1 for envelope 1, and so on)
 STA soundAddr+1

 LDY pitchIndexTRI      ; Set A to the byte of envelope data at the index in
 LDA (soundAddr),Y      ; pitchIndexTRI, which we increment to move through the
                        ; data one byte at a time

 CMP #$80               ; If A is not $80 then we just fetched a valid byte of
 BNE muse2              ; envelope data, so jump to muse2 to process it

                        ; If we get here then we just fetched a $80 from the
                        ; pitch envelope, which indicates the end of the list of
                        ; envelope values, so we now loop around to the start of
                        ; the list, so it keeps repeating

 LDY #0                 ; Set pitchIndexTRI = 0 to point to the start of the
 STY pitchIndexTRI      ; data for pitch envelope X

 LDA (soundAddr),Y      ; Set A to the byte of envelope data at index 0, so we
                        ; can fall through into muse2 to process it

.muse2

 INC pitchIndexTRI      ; Increment the index into the pitch envelope so we
                        ; move on to the next byte of data in the next iteration

 CLC                    ; Set triLo = triLoCopy + A
 ADC triLoCopy          ;
 STA triLo              ; So this alters the low byte of the pitch that we send
                        ; to the APU via TRI_LO, altering it by the amount in
                        ; the byte of data we just fetched from the pitch
                        ; envelope

 RTS                    ; Return from the subroutine

; ******************************************************************************
;
;       Name: MakeMusicOnNOISE
;       Type: Subroutine
;   Category: Sound
;    Summary: Play the current music on the NOISE channel
;  Deep dive: Music in NES Elite
;
; ******************************************************************************

.MakeMusicOnNOISE

 DEC pauseCountNOISE    ; Decrement the sound counter for NOISE

 BEQ musf1              ; If the counter has reached zero, jump to musf1 to make
                        ; music on the NOISE channel

 RTS                    ; Otherwise return from the subroutine

.musf1

 LDA sectionDataNOISE   ; Set soundAddr(1 0) = sectionDataNOISE(1 0)
 STA soundAddr          ;
 LDA sectionDataNOISE+1 ; So soundAddr(1 0) points to the note data for this
 STA soundAddr+1        ; part of the tune

 STA applyVolumeNOISE   ; Set applyVolumeNOISE = 0 so we don't apply the volume
                        ; envelope by default (this gets changed if we process
                        ; note data below, as opposed to a command)
                        ;
                        ; I'm not entirely sure why A is zero here - in fact,
                        ; it's very unlikely to be zero - so it's possible that
                        ; there is an LDA #0 instruction missing here and that
                        ; this is a bug that applies the volume envelope of the
                        ; NOISE channel too early

.musf2

 LDY #0                 ; Set Y to the next entry from the note data
 LDA (soundAddr),Y
 TAY

 INC soundAddr          ; Increment soundAddr(1 0) to point to the next entry
 BNE musf3              ; in the note data
 INC soundAddr+1

.musf3

 TYA                    ; Set A to the next entry that we just fetched from the
                        ; note data

 BMI musf7              ; If bit 7 of A is set then this is a command byte, so
                        ; jump to musf7 to process it

 CMP #$60               ; If the note data in A is less than $60, jump to musf4
 BCC musf4

 ADC #$A0               ; The note data in A is between $60 and $7F, so set the
 STA startPauseNOISE    ; following:
                        ;
                        ;    startPauseNOISE = A - $5F
                        ;
                        ; We know the C flag is set as we just passed through a
                        ; BCC, so the ADC actually adds $A1, which is the same
                        ; as subtracting $5F
                        ;
                        ; So this sets startPauseNOISE to a value between 1 and
                        ; 32, corresponding to note data values between $60 and
                        ; $7F

 JMP musf2              ; Jump back to musf2 to move on to the next entry from
                        ; the note data

.musf4

                        ; If we get here then the note data in A is less than
                        ; $60, which denotes a sound to send to the APU, so we
                        ; now convert the data to a noise frequency (which we do
                        ; by simply taking the low nibble of the note data, as
                        ; this is just noise that doesn't need a conversion
                        ; from note to frequency like the other channels) and
                        ; send it to the APU to make a sound on channel NOISE

 AND #$0F               ; Set (Y A) to the frequency for noise note Y
 STA noiseLoCopy        ;
 STA noiseLo            ; Also save a copy of the low byte in noiseLoCopy
 LDY #0

 LDX effectOnNOISE      ; If effectOnNOISE is non-zero then a sound effect is
 BNE musf5              ; being made on channel NOISE, so jump to musf5 to skip
                        ; writing the music data to the APU (so sound effects
                        ; take precedence over music)

 STA NOISE_LO           ; Send (Y A) to the APU via NOISE_HI and NOISE_LO
 STY NOISE_HI

.musf5

 LDA #1                 ; Set volumeIndexNOISE = 1
 STA volumeIndexNOISE

 LDA volumeRepeatNOISE  ; Set volumeCounterNOISE = volumeRepeatNOISE
 STA volumeCounterNOISE

.musf6

 LDA #$FF               ; Set applyVolumeNOISE = $FF so we apply the volume
 STA applyVolumeNOISE   ; envelope in the next iteration

 LDA soundAddr          ; Set sectionDataNOISE(1 0) = soundAddr(1 0)
 STA sectionDataNOISE   ;
 LDA soundAddr+1        ; This updates the pointer to the note data for the
 STA sectionDataNOISE+1 ; channel, so the next time we can pick up where we left
                        ; off

 LDA startPauseNOISE    ; Set pauseCountNOISE = startPauseNOISE
 STA pauseCountNOISE    ;
                        ; So if startPauseNOISE is non-zero (as set by note data
                        ; the range $60 to $7F), the next startPauseNOISE
                        ; iterations of MakeMusicOnNOISE will do nothing

 RTS                    ; Return from the subroutine

.musf7

                        ; If we get here then bit 7 of the note data in A is
                        ; set, so this is a command byte

 LDY #0                 ; Set Y = 0, so we can use it in various commands below

 CMP #$FF               ; If A is not $FF, jump to musf9 to check for the next
 BNE musf9              ; command

                        ; If we get here then the command in A is $FF
                        ;
                        ; <$FF> moves to the next section in the current tune

 LDA nextSectionNOISE   ; Set soundAddr(1 0) to the following:
 CLC                    ;
 ADC sectionListNOISE   ;   sectionListNOISE(1 0) + nextSectionNOISE(1 0)
 STA soundAddr          ;
 LDA nextSectionNOISE+1 ; So soundAddr(1 0) points to the address of the next
 ADC sectionListNOISE+1 ; section in the current tune
 STA soundAddr+1        ;
                        ; So if we are playing tune 2 and nextSectionNOISE(1 0)
                        ; points to the second section, then soundAddr(1 0)
                        ; will now point to the second address in
                        ; tune2Data_NOISE, which itself points to the note data
                        ; for the second section at tune2Data_NOISE_1

 LDA nextSectionNOISE   ; Set nextSectionNOISE(1 0) = nextSectionNOISE(1 0) + 2
 ADC #2                 ;
 STA nextSectionNOISE   ; So nextSectionNOISE(1 0) now points to the next
 TYA                    ; section, as each section consists of two bytes in the
 ADC nextSectionNOISE+1 ; table at sectionListNOISE(1 0)
 STA nextSectionNOISE+1

 LDA (soundAddr),Y      ; If the address at soundAddr(1 0) is non-zero then it
 INY                    ; contains a valid address to the section's note data,
 ORA (soundAddr),Y      ; so jump to musf8 to skip the following
 BNE musf8              ;
                        ; This also increments the index in Y to 1

                        ; If we get here then the command is trying to move to
                        ; the next section, but that section contains value of
                        ; $0000 in the tuneData table, so there is no next
                        ; section and we have reached the end of the tune, so
                        ; instead we jump back to the start of the tune

 LDA sectionListNOISE   ; Set soundAddr(1 0) = sectionListNOISE(1 0)
 STA soundAddr          ;
 LDA sectionListNOISE+1 ; So we start again by pointing soundAddr(1 0) to the
 STA soundAddr+1        ; first entry in the section list for channel NOISE,
                        ; which contains the address of the first section's note
                        ; data

 LDA #2                 ; Set nextSectionNOISE(1 0) = 2
 STA nextSectionNOISE   ;
 LDA #0                 ; So the next section after we play the first section
 STA nextSectionNOISE+1 ; will be the second section

.musf8

                        ; By this point, Y has been incremented to 1

 LDA (soundAddr),Y      ; Set soundAddr(1 0) to the address at soundAddr(1 0)
 TAX                    ;
 DEY                    ; As we pointed soundAddr(1 0) to the address of the
 LDA (soundAddr),Y      ; new section above, this fetches the first address from
 STA soundAddr          ; the new section's address list, which points to the
 STX soundAddr+1        ; new section's note data
                        ;
                        ; So soundAddr(1 0) now points to the note data for the
                        ; new section, so we're ready to start processing notes
                        ; and commands when we rejoin the musf2 loop

 JMP musf2              ; Jump back to musf2 to start processing data from the
                        ; new section

.musf9

 CMP #$F6               ; If A is not $F6, jump to musf11 to check for the next
 BNE musf11             ; command

                        ; If we get here then the command in A is $F6
                        ;
                        ; <$F6 $xx> sets the volume envelope number to $xx

 LDA (soundAddr),Y      ; Fetch the next entry in the note data into A

 INC soundAddr          ; Increment soundAddr(1 0) to point to the next entry
 BNE musf10             ; in the note data
 INC soundAddr+1

.musf10

 STA volumeEnvelopeNOISE    ; Set volumeEnvelopeNOISE to the volume envelope
                            ; number that we just fetched

 JMP musf2              ; Jump back to musf2 to move on to the next entry from
                        ; the note data

.musf11

 CMP #$F7               ; If A is not $F7, jump to musf13 to check for the next
 BNE musf13             ; command

                        ; If we get here then the command in A is $F7
                        ;
                        ; <$F7 $xx> sets the pitch envelope number to $xx

 LDA (soundAddr),Y      ; Fetch the next entry in the note data into A

 INC soundAddr          ; Increment soundAddr(1 0) to point to the next entry
 BNE musf12             ; in the note data
 INC soundAddr+1

.musf12

 STA pitchEnvelopeNOISE ; Set pitchEnvelopeNOISE to the pitch envelope number
                        ; that we just fetched

 STY pitchIndexNOISE    ; Set pitchIndexNOISE = 0 to point to the start of the
                        ; data for pitch envelope A

 JMP musf2              ; Jump back to musf2 to move on to the next entry from
                        ; the note data

.musf13

 CMP #$F8               ; If A is not $F8, jump to musf14 to check for the next
 BNE musf14             ; command

                        ; If we get here then the command in A is $F8
                        ;
                        ; <$F8> sets the volume of the NOISE channel to zero

 LDA #%00110000         ; Set the volume of the NOISE channel to zero as
 STA noiseVolume        ; follows:
                        ;
                        ;   * Bits 6-7    = duty pulse length is 3
                        ;   * Bit 5 set   = infinite play
                        ;   * Bit 4 set   = constant volume
                        ;   * Bits 0-3    = volume is 0

 JMP musf6              ; Jump to musf6 to return from the subroutine after
                        ; setting applyVolumeNOISE to $FF, so we apply the
                        ; volume envelope, and then continue on from the next
                        ; entry from the note data in the next iteration

.musf14

 CMP #$F9               ; If A is not $F9, jump to musf15 to check for the next
 BNE musf15             ; command

                        ; If we get here then the command in A is $F9
                        ;
                        ; <$F9> enables the volume envelope for the NOISE
                        ; channel

 JMP musf6              ; Jump to musf6 to return from the subroutine after
                        ; setting applyVolumeNOISE to $FF, so we apply the
                        ; volume envelope, and then continue on from the next
                        ; entry from the note data in the next iteration

.musf15

 CMP #$F5               ; If A is not $F5, jump to musf16 to check for the next
 BNE musf16             ; command

                        ; If we get here then the command in A is $F5
                        ;
                        ; <$F5 $xx &yy> changes tune to the tune data at &yyxx
                        ;
                        ; It does this by setting sectionListNOISE(1 0) to &yyxx
                        ; and soundAddr(1 0) to the address stored in &yyxx
                        ;
                        ; To see why this works, consider switching to tune 2,
                        ; for which we would use this command:
                        ;
                        ;   <$F5 LO(tune2Data_NOISE) LO(tune2Data_NOISE)>
                        ;
                        ; This sets:
                        ;
                        ;   sectionListNOISE(1 0) = tune2Data_NOISE
                        ;
                        ; so from now on we fetch the addresses for each section
                        ; of the tune from the table at tune2Data_NOISE
                        ;
                        ; It also sets soundAddr(1 0) to the address in the
                        ; first two bytes of tune2Data_NOISE, to give:
                        ;
                        ;   soundAddr(1 0) = tune2Data_NOISE_0
                        ;
                        ; So from this point on, note data is fetched from the
                        ; table at tune2Data_NOISE_0, which contains notes and
                        ; commands for the first section of tune 2

 LDA (soundAddr),Y      ; Fetch the next entry in the note data into A

 TAX                    ; Set sectionListNOISE(1 0) = &yyxx
 STA sectionListNOISE   ;
 INY                    ; Also set soundAddr(1 0) to &yyxx and increment the
 LDA (soundAddr),Y      ; index in Y to 1, both of which we use below
 STX soundAddr
 STA soundAddr+1
 STA sectionListNOISE+1

 LDA #2                 ; Set nextSectionNOISE(1 0) = 2
 STA nextSectionNOISE   ;
 DEY                    ; So the next section after we play the first section
 STY nextSectionNOISE+1 ; of the new tune will be the second section
                        ;
                        ; Also decrement the index in Y back to 0

 LDA (soundAddr),Y      ; Set soundAddr(1 0) to the address stored at &yyxx
 TAX
 INY
 LDA (soundAddr),Y
 STA soundAddr+1
 STX soundAddr

 JMP musf2              ; Jump back to musf2 to move on to the next entry from
                        ; the note data

.musf16

 CMP #$F4               ; If A is not $F4, jump to musf18 to check for the next
 BNE musf18             ; command

                        ; If we get here then the command in A is $F4
                        ;
                        ; <$F4 $xx> sets the playback speed to $xx

 LDA (soundAddr),Y      ; Fetch the next entry in the note data into A, which
                        ; contains the new speed

 INC soundAddr          ; Increment soundAddr(1 0) to point to the next entry
 BNE musf17             ; in the note data
 INC soundAddr+1

.musf17

 STA tuneSpeed          ; Set tuneSpeed and tuneSpeedCopy to A, to change the
 STA tuneSpeedCopy      ; speed of the current tune to the specified speed

 JMP musf2              ; Jump back to musf2 to move on to the next entry from
                        ; the note data

.musf18

 CMP #$FE               ; If A is not $FE, jump to musf19 to check for the next
 BNE musf19             ; command

                        ; If we get here then the command in A is $FE
                        ;
                        ; <$FE> stops the music and disables sound

 STY playMusic          ; Set playMusic = 0 to stop playing the current tune, so
                        ; only a new call to ChooseMusic will start the music
                        ; again

 PLA                    ; Pull the return address from the stack, so the RTS
 PLA                    ; instruction at the end of StopSounds actually returns
                        ; from the subroutine that called MakeMusic, so we stop
                        ; the music and return to the MakeSounds routine (which
                        ; is the only routine that calls MakeMusic)

 JMP StopSoundsS        ; Jump to StopSounds via StopSoundsS to stop the music
                        ; and return to the MakeSounds routine

.musf19

 BEQ musf19             ; If we get here then bit 7 of A was set but the value
                        ; didn't match any of the checks above, so this
                        ; instruction does nothing and we fall through into
                        ; ApplyEnvelopeNOISE, ignoring the data in A
                        ;
                        ; I'm not sure why the instruction here is an infinite
                        ; loop, but luckily it isn't triggered as A is never
                        ; zero at this point

; ******************************************************************************
;
;       Name: ApplyEnvelopeNOISE
;       Type: Subroutine
;   Category: Sound
;    Summary: Apply volume and pitch changes to the NOISE channel
;  Deep dive: Music in NES Elite
;
; ******************************************************************************

.ApplyEnvelopeNOISE

 LDA applyVolumeNOISE   ; If applyVolumeNOISE = 0 then we do not apply the
 BEQ musg2              ; volume envelope, so jump to musg2 to move on to the
                        ; pitch envelope

 LDX volumeEnvelopeNOISE    ; Set X to the number of the volume envelope to
                            ; apply

 LDA volumeEnvelopeLo,X ; Set soundAddr(1 0) to the address of the data for
 STA soundAddr          ; volume envelope X from the (i.e. volumeEnvelope0 for
 LDA volumeEnvelopeHi,X ; envelope 0, volumeEnvelope1 for envelope 1, and so on)
 STA soundAddr+1

 LDY #0                 ; Set volumeRepeatNOISE to the first byte of envelope
 LDA (soundAddr),Y      ; data, which contains the number of times to repeat
 STA volumeRepeatNOISE  ; each entry in the envelope

 LDY volumeIndexNOISE   ; Set A to the byte of envelope data at the index in
 LDA (soundAddr),Y      ; volumeIndexNOISE, which we increment to move through
                        ; the data one byte at a time

 BMI musg1              ; If bit 7 of A is set then we just fetched the last
                        ; byte of envelope data, so jump to musg1 to skip the
                        ; following

 DEC volumeCounterNOISE ; Decrement the counter for this envelope byte

 BPL musg1              ; If the counter is still positive, then we haven't yet
                        ; done all the repeats for this envelope byte, so jump
                        ; to musg1 to skip the following

                        ; Otherwise this is the last repeat for this byte of
                        ; envelope data, so now we reset the counter and move
                        ; on to the next byte

 LDX volumeRepeatNOISE  ; Reset the repeat counter for this envelope to the
 STX volumeCounterNOISE ; first byte of envelope data that we fetched above,
                        ; which contains the number of times to repeat each
                        ; entry in the envelope

 INC volumeIndexNOISE   ; Increment the index into the volume envelope so we
                        ; move on to the next byte of data in the next iteration

.musg1

 AND #%00001111         ; Extract the low nibble from the envelope data, which
                        ; contains the volume level

 ORA #%00110000         ; Set bits 5 and 6 to configure the NOISE channel as
                        ; follows:
                        ;
                        ;   * Bit 5 set   = infinite play
                        ;
                        ;   * Bit 4 set   = constant volume
                        ;
                        ; Bits 6 and 7 are not used in the NOISE_VOL register

 STA noiseVolume        ; Set noiseVolume to the resulting volume byte so it
                        ; gets sent to the APU via NOISE_VOL

.musg2

                        ; We now move on to the pitch envelope

 LDX pitchEnvelopeNOISE ; Set X to the number of the pitch envelope to apply

 LDA pitchEnvelopeLo,X  ; Set soundAddr(1 0) to the address of the data for
 STA soundAddr          ; pitch envelope X from the (i.e. pitchEnvelope0 for
 LDA pitchEnvelopeHi,X  ; envelope 0, pitchEnvelope1 for envelope 1, and so on)
 STA soundAddr+1

 LDY pitchIndexNOISE    ; Set A to the byte of envelope data at the index in
 LDA (soundAddr),Y      ; pitchIndexNOISE, which we increment to move through
                        ; the data one byte at a time

 CMP #$80               ; If A is not $80 then we just fetched a valid byte of
 BNE musg3              ; envelope data, so jump to musg3 to process it

                        ; If we get here then we just fetched a $80 from the
                        ; pitch envelope, which indicates the end of the list of
                        ; envelope values, so we now loop around to the start of
                        ; the list, so it keeps repeating

 LDY #0                 ; Set pitchIndexNOISE = 0 to point to the start of the
 STY pitchIndexNOISE    ; data for pitch envelope X

 LDA (soundAddr),Y      ; Set A to the byte of envelope data at index 0, so we
                        ; can fall through into musg3 to process it

.musg3

 INC pitchIndexNOISE    ; Increment the index into the pitch envelope so we
                        ; move on to the next byte of data in the next iteration

 CLC                    ; Set noiseLo = low nibble of noiseLoCopy + A
 ADC noiseLoCopy        ;
 AND #%00001111         ; So this alters the low byte of the pitch that we send
 STA noiseLo            ; to the APU via NOISE_LO, altering it by the amount in
                        ; the byte of data we just fetched from the pitch
                        ; envelope
                        ;
                        ; We extract the low nibble because the high nibble is
                        ; ignored in NOISE_LO, except for bit 7, which we want
                        ; to clear so the period of the random noise generation
                        ; is normal and not shortened

 RTS                    ; Return from the subroutine

; ******************************************************************************
;
;       Name: noteFrequency
;       Type: Variable
;   Category: Sound
;    Summary: A table of note frequencies
;  Deep dive: Music in NES Elite
;
; ******************************************************************************

.noteFrequency

 EQUW $031A             ; The frequency for C# in octave 2
 EQUW $02EC             ; The frequency for D  in octave 2
 EQUW $02C2             ; The frequency for D# in octave 2
 EQUW $029A             ; The frequency for E  in octave 2
 EQUW $0275             ; The frequency for F  in octave 2
 EQUW $0252             ; The frequency for F# in octave 2
 EQUW $0230             ; The frequency for G  in octave 2
 EQUW $0211             ; The frequency for G# in octave 2

 EQUW $03E7             ; The frequency for C  in octave 1
 EQUW $03AF             ; The frequency for B  in octave 1
 EQUW $037A             ; The frequency for A# in octave 1
 EQUW $0348             ; The frequency for A  in octave 1
 EQUW $031A             ; The frequency for C# in octave 2
 EQUW $02EC             ; The frequency for D  in octave 2
 EQUW $02C2             ; The frequency for D# in octave 2
 EQUW $029A             ; The frequency for E  in octave 2
 EQUW $0275             ; The frequency for F  in octave 2
 EQUW $0252             ; The frequency for F# in octave 2
 EQUW $0230             ; The frequency for G  in octave 2
 EQUW $0211             ; The frequency for G# in octave 2
 EQUW $01F3             ; The frequency for A  in octave 2
 EQUW $01D7             ; The frequency for A# in octave 2
 EQUW $01BD             ; The frequency for B  in octave 2
 EQUW $01A4             ; The frequency for C  in octave 3
 EQUW $018D             ; The frequency for C# in octave 3
 EQUW $0176             ; The frequency for D  in octave 3
 EQUW $0161             ; The frequency for D# in octave 3
 EQUW $014D             ; The frequency for E  in octave 3
 EQUW $013B             ; The frequency for F  in octave 3
 EQUW $0129             ; The frequency for F# in octave 3
 EQUW $0118             ; The frequency for G  in octave 3
 EQUW $0108             ; The frequency for G# in octave 3
 EQUW $00F9             ; The frequency for A  in octave 3
 EQUW $00EB             ; The frequency for A# in octave 3
 EQUW $00DE             ; The frequency for B  in octave 3
 EQUW $00D1             ; The frequency for C  in octave 4
 EQUW $00C5             ; The frequency for C# in octave 4
 EQUW $00BB             ; The frequency for D  in octave 4
 EQUW $00B0             ; The frequency for D# in octave 4
 EQUW $00A6             ; The frequency for E  in octave 4
 EQUW $009D             ; The frequency for F  in octave 4
 EQUW $0094             ; The frequency for F# in octave 4
 EQUW $008B             ; The frequency for G  in octave 4
 EQUW $0084             ; The frequency for G# in octave 4
 EQUW $007C             ; The frequency for A  in octave 4
 EQUW $0075             ; The frequency for A# in octave 4
 EQUW $006F             ; The frequency for B  in octave 4
 EQUW $0068             ; The frequency for C  in octave 5
 EQUW $0062             ; The frequency for C# in octave 5
 EQUW $005D             ; The frequency for D  in octave 5
 EQUW $0057             ; The frequency for D# in octave 5
 EQUW $0052             ; The frequency for E  in octave 5
 EQUW $004E             ; The frequency for F  in octave 5
 EQUW $0049             ; The frequency for F# in octave 5
 EQUW $0045             ; The frequency for G  in octave 5
 EQUW $0041             ; The frequency for G# in octave 5
 EQUW $003E             ; The frequency for A  in octave 5
 EQUW $003A             ; The frequency for A# in octave 5
 EQUW $0037             ; The frequency for B  in octave 5
 EQUW $0034             ; The frequency for C  in octave 6
 EQUW $0031             ; The frequency for C# in octave 6
 EQUW $002E             ; The frequency for D  in octave 6
 EQUW $002B             ; The frequency for D# in octave 6
 EQUW $0029             ; The frequency for E  in octave 6
 EQUW $0026             ; The frequency for F  in octave 6
 EQUW $0024             ; The frequency for F# in octave 6
 EQUW $0022             ; The frequency for G  in octave 6
 EQUW $0020             ; The frequency for G# in octave 6
 EQUW $001E             ; The frequency for A  in octave 6
 EQUW $001C             ; The frequency for A# in octave 6
 EQUW $001B             ; The frequency for B  in octave 6
 EQUW $0019             ; The frequency for C  in octave 7
 EQUW $0018             ; The frequency for C# in octave 7
 EQUW $0016             ; The frequency for D  in octave 7
 EQUW $0015             ; The frequency for D# in octave 7
 EQUW $0014             ; The frequency for E  in octave 7
 EQUW $0013             ; The frequency for F  in octave 7
 EQUW $0012             ; The frequency for F# in octave 7
 EQUW $0011             ; The frequency for G  in octave 7

; ******************************************************************************
;
;       Name: StartEffectOnSQ1
;       Type: Subroutine
;   Category: Sound
;    Summary: Make a sound effect on the SQ1 channel
;  Deep dive: Sound effects in NES Elite
;
; ------------------------------------------------------------------------------
;
; Arguments:
;
;   A                   The number of the sound effect to make
;
; ******************************************************************************

.StartEffectOnSQ1

 ASL A                  ; Set Y = A * 2
 TAY                    ;
                        ; So we can use Y as an index into the soundData table,
                        ; which contains addresses of two bytes each

 LDA #0                 ; Set effectOnSQ1 = 0 to disable sound generation on the
 STA effectOnSQ1        ; SQ1 channel while we set up the sound effect (as a
                        ; value of 0 denotes that a sound effect is not being
                        ; made on this channel, so none of the sound generation
                        ; routines will do anything)
                        ;
                        ; We enable sound generation below once we have finished
                        ; setting up the sound effect

 LDA soundData,Y        ; Set soundAddr(1 0) to the address for this sound
 STA soundAddr          ; effect from the soundData table, so soundAddr(1 0)
 LDA soundData+1,Y      ; points to soundData0 for the sound data for sound
 STA soundAddr+1        ; effect 0, or to soundData1 for the sound data for
                        ; sound effect 1, and so on

                        ; There are 14 bytes of sound data for each sound effect
                        ; that we now copy to soundByteSQ1, so we can do things
                        ; like update the counters and store the current pitch
                        ; as we make the sound effect

 LDY #13                ; Set a byte counter in Y for copying all 14 bytes

.mefz1

 LDA (soundAddr),Y      ; Copy the Y-th byte of sound data for this sound effect
 STA soundByteSQ1,Y     ; to the Y-th byte of soundByteSQ1

 DEY                    ; Decrement the loop counter

 BPL mefz1              ; Loop back until we have copied all 14 bytes

 SETUP_PPU_FOR_ICON_BAR ; If the PPU has started drawing the icon bar, configure
                        ; the PPU to use nametable 0 and pattern table 0

 LDA soundByteSQ1+11    ; Set soundVolCountSQ1 = soundByteSQ1+11
 STA soundVolCountSQ1   ;
                        ; This initialises the counter in soundVolCountSQ1
                        ; with the value of byte #11, so it can be used to
                        ; control how often we apply the volume envelope to the
                        ; sound effect on channel SQ1

 LDA soundByteSQ1+13    ; Set soundPitchEnvSQ1 = soundByteSQ1+13
 STA soundPitchEnvSQ1   ;
                        ; This initialises the counter in soundPitchEnvSQ1
                        ; with the value of byte #13, so it can be used to
                        ; control how often we apply the pitch envelope to the
                        ; sound effect on channel SQ1

 LDA soundByteSQ1+1     ; Set soundPitCountSQ1 = soundByteSQ1+1
 STA soundPitCountSQ1   ;
                        ; This initialises the counter in soundPitCountSQ1
                        ; with the value of byte #1, so it can be used to
                        ; control how often we send pitch data to the APU for
                        ; the sound effect on channel SQ1

 LDA soundByteSQ1+10    ; Set Y = soundByteSQ1+10 * 2
 ASL A                  ;
 TAY                    ; So we can use Y as an index into the soundVolume
                        ; table to fetch byte #10, as the table contains
                        ; addresses of two bytes each

 LDA soundVolume,Y      ; Set soundVolumeSQ1(1 0) to the address of the volume
 STA soundVolumeSQ1     ; envelope for this sound effect, as specified in
 STA soundAddr          ; byte #10 of the sound effect's data
 LDA soundVolume+1,Y    ;
 STA soundVolumeSQ1+1   ; This also sets soundAddr(1 0) to the same address
 STA soundAddr+1

 LDY #0                 ; Set Y = 0 so we can use indirect addressing below (we
                        ; do not change the value of Y, this is just so we can
                        ; implement the non-existent LDA (soundAddr) instruction
                        ; by using LDA (soundAddr),Y instead)

 STY soundVolIndexSQ1   ; Set soundVolIndexSQ1 = 0, so we start processing the
                        ; volume envelope from the first byte

 LDA (soundAddr),Y      ; Take the first byte from the volume envelope for this
 ORA soundByteSQ1+6     ; sound effect, OR it with the sound effect's byte #6,
 STA SQ1_VOL            ; and send the result to the APU via SQ1_VOL
                        ;
                        ; Data bytes in the volume envelope data only use the
                        ; low nibble (the high nibble is only used to mark the
                        ; end of the data), and the sound effect's byte #6 only
                        ; uses the high nibble, so this sets the low nibble of
                        ; the APU byte to the volume level from the data, and
                        ; the high nibble of the APU byte to the configuration
                        ; in byte #6 (which sets the duty pulse, looping and
                        ; constant flags for the volume)

 LDA #0                 ; Send 0 to the APU via SQ1_SWEEP to disable the sweep
 STA SQ1_SWEEP          ; unit and stop the pitch from changing

 LDA soundByteSQ1+2     ; Set (soundHiSQ1 soundLoSQ1) to the 16-bit value in
 STA soundLoSQ1         ; bytes #2 and #3 of the sound data, which at this point
 STA SQ1_LO             ; contains the first pitch value to send to the APU via
 LDA soundByteSQ1+3     ; (SQ1_HI SQ1_LO)
 STA soundHiSQ1         ;
 STA SQ1_HI             ; We will be using these bytes to store the pitch bytes
                        ; to send to the APU as we keep making the sound effect,
                        ; so this just kicks off the process with the initial
                        ; pitch value

 INC effectOnSQ1        ; Increment effectOnSQ1 to 1 to denote that a sound
                        ; effect is now being generated on the SQ1 channel, so
                        ; successive calls to MakeSoundOnSQ1 will now make the
                        ; sound effect

 RTS                    ; Return from the subroutine

; ******************************************************************************
;
;       Name: StartEffect
;       Type: Subroutine
;   Category: Sound
;    Summary: Start making a sound effect on the specified channel
;  Deep dive: Sound effects in NES Elite
;
; ------------------------------------------------------------------------------
;
; Arguments:
;
;   A                   The number of the sound effect to make
;
;   X                   The sound channel on which to make the sound effect:
;
;                         * 0 = SQ1
;
;                         * 1 = SQ2
;
;                         * 2 = NOISE
;
; ******************************************************************************

.StartEffect

 DEX                    ; Decrement the channel number in X, so we can check the
                        ; value in the following tests

 BMI msef1              ; If X is now negative then the channel number must be
                        ; 0, so jump to msef1 to make the sound effect on the
                        ; SQ1 channel

 BEQ StartEffectOnSQ2   ; If X is now zero then the channel number must be 1, so
                        ; jump to StartEffectOnSQ2 to start making the sound
                        ; effect on the SQ2 channel, returning from the
                        ; subroutine using a tail call

 JMP StartEffectOnNOISE ; Otherwise the channel number must be 2, so jump to
                        ; StartEffectOnNOISE to make the sound effect on the
                        ; NOISE channel, returning from the subroutine using a
                        ; tail call

.msef1

 JMP StartEffectOnSQ1   ; Jump to StartEffectOnSQ1 to start making the sound
                        ; effect on the SQ1 channel, returning from the
                        ; subroutine using a tail call

; ******************************************************************************
;
;       Name: StartEffectOnSQ2
;       Type: Subroutine
;   Category: Sound
;    Summary: Make a sound effect on the SQ2 channel
;  Deep dive: Sound effects in NES Elite
;
; ------------------------------------------------------------------------------
;
; Arguments:
;
;   A                   The number of the sound effect to make
;
; ******************************************************************************

.StartEffectOnSQ2

 ASL A                  ; Set Y = A * 2
 TAY                    ;
                        ; So we can use Y as an index into the soundData table,
                        ; which contains addresses of two bytes each

 LDA #0                 ; Set effectOnSQ2 = 0 to disable sound generation on the
 STA effectOnSQ2        ; SQ2 channel while we set up the sound effect (as a
                        ; value of 0 denotes that a sound effect is not being
                        ; made on this channel, so none of the sound generation
                        ; routines will do anything)
                        ;
                        ; We enable sound generation below once we have finished
                        ; setting up the sound effect

 LDA soundData,Y        ; Set soundAddr(1 0) to the address for this sound
 STA soundAddr          ; effect from the soundData table, so soundAddr(1 0)
 LDA soundData+1,Y      ; points to soundData0 for the sound data for sound
 STA soundAddr+1        ; effect 0, or to soundData1 for the sound data for
                        ; sound effect 1, and so on

                        ; There are 14 bytes of sound data for each sound effect
                        ; that we now copy to soundByteSQ2, so we can do things
                        ; like update the counters and store the current pitch
                        ; as we make the sound effect

 LDY #13                ; Set a byte counter in Y for copying all 14 bytes

.mefo1

 LDA (soundAddr),Y      ; Copy the Y-th byte of sound data for this sound effect
 STA soundByteSQ2,Y     ; to the Y-th byte of soundByteSQ2

 DEY                    ; Decrement the loop counter

 BPL mefo1              ; Loop back until we have copied all 14 bytes

 SETUP_PPU_FOR_ICON_BAR ; If the PPU has started drawing the icon bar, configure
                        ; the PPU to use nametable 0 and pattern table 0

 LDA soundByteSQ2+11    ; Set soundVolCountSQ2 = soundByteSQ2+11
 STA soundVolCountSQ2   ;
                        ; This initialises the counter in soundVolCountSQ2
                        ; with the value of byte #11, so it can be used to
                        ; control how often we apply the volume envelope to the
                        ; sound effect on channel SQ2

 LDA soundByteSQ2+13    ; Set soundPitchEnvSQ2 = soundByteSQ2+13
 STA soundPitchEnvSQ2   ;
                        ; This initialises the counter in soundPitchEnvSQ2
                        ; with the value of byte #13, so it can be used to
                        ; control how often we apply the pitch envelope to the
                        ; sound effect on channel SQ2

 LDA soundByteSQ2+1     ; Set soundPitCountSQ2 = soundByteSQ2+1
 STA soundPitCountSQ2   ;
                        ; This initialises the counter in soundPitCountSQ2
                        ; with the value of byte #1, so it can be used to
                        ; control how often we send pitch data to the APU for
                        ; the sound effect on channel SQ2

 LDA soundByteSQ2+10    ; Set Y = soundByteSQ2+10 * 2
 ASL A                  ;
 TAY                    ; So we can use Y as an index into the soundVolume
                        ; table to fetch byte #10, as the table contains
                        ; addresses of two bytes each

 LDA soundVolume,Y      ; Set soundVolumeSQ2(1 0) to the address of the volume
 STA soundVolumeSQ2     ; envelope for this sound effect, as specified in
 STA soundAddr          ; byte #10 of the sound effect's data
 LDA soundVolume+1,Y    ;
 STA soundVolumeSQ2+1   ; This also sets soundAddr(1 0) to the same address
 STA soundAddr+1

 LDY #0                 ; Set Y = 0 so we can use indirect addressing below (we
                        ; do not change the value of Y, this is just so we can
                        ; implement the non-existent LDA (soundAddr) instruction
                        ; by using LDA (soundAddr),Y instead)

 STY soundVolIndexSQ2   ; Set soundVolIndexSQ2 = 0, so we start processing the
                        ; volume envelope from the first byte

 LDA (soundAddr),Y      ; Take the first byte from the volume envelope for this
 ORA soundByteSQ2+6     ; sound effect, OR it with the sound effect's byte #6,
 STA SQ2_VOL            ; and send the result to the APU via SQ2_VOL
                        ;
                        ; Data bytes in the volume envelope data only use the
                        ; low nibble (the high nibble is only used to mark the
                        ; end of the data), and the sound effect's byte #6 only
                        ; uses the high nibble, so this sets the low nibble of
                        ; the APU byte to the volume level from the data, and
                        ; the high nibble of the APU byte to the configuration
                        ; in byte #6 (which sets the duty pulse, looping and
                        ; constant flags for the volume)

 LDA #0                 ; Send 0 to the APU via SQ2_SWEEP to disable the sweep
 STA SQ2_SWEEP          ; unit and stop the pitch from changing

 LDA soundByteSQ2+2     ; Set (soundHiSQ2 soundLoSQ2) to the 16-bit value in
 STA soundLoSQ2         ; bytes #2 and #3 of the sound data, which at this point
 STA SQ2_LO             ; contains the first pitch value to send to the APU via
 LDA soundByteSQ2+3     ; (SQ2_HI SQ2_LO)
 STA soundHiSQ2         ;
 STA SQ2_HI             ; We will be using these bytes to store the pitch bytes
                        ; to send to the APU as we keep making the sound effect,
                        ; so this just kicks off the process with the initial
                        ; pitch value

 INC effectOnSQ2        ; Increment effectOnSQ2 to 1 to denote that a sound
                        ; effect is now being generated on the SQ2 channel, so
                        ; successive calls to MakeSoundOnSQ2 will now make the
                        ; sound effect

 RTS                    ; Return from the subroutine

; ******************************************************************************
;
;       Name: StartEffectOnNOISE
;       Type: Subroutine
;   Category: Sound
;    Summary: Make a sound effect on the NOISE channel
;  Deep dive: Sound effects in NES Elite
;
; ------------------------------------------------------------------------------
;
; Arguments:
;
;   A                   The number of the sound effect to make
;
; ******************************************************************************

.StartEffectOnNOISE

 ASL A                  ; Set Y = A * 2
 TAY                    ;
                        ; So we can use Y as an index into the soundData table,
                        ; which contains addresses of two bytes each

 LDA #0                 ; Set effectOnNOISE = 0 to disable sound generation on
 STA effectOnNOISE      ; the NOISE channel while we set up the sound effect (as
                        ; a value of 0 denotes that a sound effect is not being
                        ; made on this channel, so none of the sound generation
                        ; routines will do anything)
                        ;
                        ; We enable sound generation below once we have finished
                        ; setting up the sound effect

 LDA soundData,Y        ; Set soundAddr(1 0) to the address for this sound
 STA soundAddr          ; effect from the soundData table, so soundAddr(1 0)
 LDA soundData+1,Y      ; points to soundData0 for the sound data for sound
 STA soundAddr+1        ; effect 0, or to soundData1 for the sound data for
                        ; sound effect 1, and so on

                        ; There are 14 bytes of sound data for each sound effect
                        ; that we now copy to soundByteNOISE, so we can do
                        ; things like update the counters and store the current
                        ; pitch as we make the sound effect

 LDY #13                ; Set a byte counter in Y for copying all 14 bytes

.meft1

 LDA (soundAddr),Y      ; Copy the Y-th byte of sound data for this sound effect
 STA soundByteNOISE,Y   ; to the Y-th byte of soundByteNOISE

 DEY                    ; Decrement the loop counter

 BPL meft1              ; Loop back until we have copied all 14 bytes

 SETUP_PPU_FOR_ICON_BAR ; If the PPU has started drawing the icon bar, configure
                        ; the PPU to use nametable 0 and pattern table 0

 LDA soundByteNOISE+11  ; Set soundVolCountNOISE = soundByteNOISE+11
 STA soundVolCountNOISE ;
                        ; This initialises the counter in soundVolCountNOISE
                        ; with the value of byte #11, so it can be used to
                        ; control how often we apply the volume envelope to the
                        ; sound effect on channel NOISE

 LDA soundByteNOISE+13  ; Set soundPitchEnvNOISE = soundByteNOISE+13
 STA soundPitchEnvNOISE ;
                        ; This initialises the counter in soundPitchEnvNOISE
                        ; with the value of byte #13, so it can be used to
                        ; control how often we apply the pitch envelope to the
                        ; sound effect on channel NOISE

 LDA soundByteNOISE+1   ; Set soundPitCountNOISE = soundByteNOISE+1
 STA soundPitCountNOISE ;
                        ; This initialises the counter in soundPitCountNOISE
                        ; with the value of byte #1, so it can be used to
                        ; control how often we send pitch data to the APU for
                        ; the sound effect on channel NOISE

 LDA soundByteNOISE+10  ; Set Y = soundByteNOISE+10 * 2
 ASL A                  ;
 TAY                    ; So we can use Y as an index into the soundVolume
                        ; table to fetch byte #10, as the table contains
                        ; addresses of two bytes each

 LDA soundVolume,Y      ; Set soundVolumeNOISE(1 0) to the address of the volume
 STA soundVolumeNOISE   ; envelope for this sound effect, as specified in
 STA soundAddr          ; byte #10 of the sound effect's data
 LDA soundVolume+1,Y    ;
 STA soundVolumeNOISE+1 ; This also sets soundAddr(1 0) to the same address
 STA soundAddr+1

 LDY #0                 ; Set Y = 0 so we can use indirect addressing below (we
                        ; do not change the value of Y, this is just so we can
                        ; implement the non-existent LDA (soundAddr) instruction
                        ; by using LDA (soundAddr),Y instead)

 STY soundVolIndexNOISE ; Set soundVolIndexNOISE = 0, so we start processing the
                        ; volume envelope from the first byte

 LDA (soundAddr),Y      ; Take the first byte from the volume envelope for this
 ORA soundByteNOISE+6   ; sound effect, OR it with the sound effect's byte #6,
 STA NOISE_VOL          ; and send the result to the APU via NOISE_VOL
                        ;
                        ; Data bytes in the volume envelope data only use the
                        ; low nibble (the high nibble is only used to mark the
                        ; end of the data), and the sound effect's byte #6 only
                        ; uses the high nibble, so this sets the low nibble of
                        ; the APU byte to the volume level from the data, and
                        ; the high nibble of the APU byte to the configuration
                        ; in byte #6 (which sets the duty pulse, looping and
                        ; constant flags for the volume)

 LDA #0                 ; This instruction would send 0 to the APU via
 STA NOISE_VOL+1        ; NOISE_SWEEP to disable the sweep unit and stop the
                        ; pitch from changing, but the NOISE channel doesn't
                        ; have a sweep unit, so this has no effect and is
                        ; presumably left over from the same code for the SQ1
                        ; and SQ2 channels

 LDA soundByteNOISE+2   ; Set (0 soundLoNOISE) to the 8-bit value in byte #2 of
 AND #$0F               ; the sound data, which at this point contains the first
 STA soundLoNOISE       ; pitch value to send to the APU via (NOISE_HI NOISE_LO)
 STA NOISE_LO           ;
 LDA #0                 ; We ignore byte #3 as the NOISE channel only has an
 STA NOISE_HI           ; 8-bit pitch range
                        ;
                        ; We will be using soundLoNOISE to store the pitch byte
                        ; to send to the APU as we keep making the sound effect,
                        ; so this just kicks off the process with the initial
                        ; pitch value

 INC effectOnNOISE      ; Increment effectOnNOISE to 1 to denote that a sound
                        ; effect is now being generated on the NOISE channel, so
                        ; successive calls to MakeSoundOnNOISE will now make the
                        ; sound effect

 RTS                    ; Return from the subroutine

; ******************************************************************************
;
;       Name: MakeSound
;       Type: Subroutine
;   Category: Sound
;    Summary: Make the current sound effects on the SQ1, SQ2 and NOISE channels
;  Deep dive: Sound effects in NES Elite
;
; ******************************************************************************

.MakeSound

 JSR UpdateVibratoSeeds ; Update the sound seeds that are used to randomise the
                        ; vibrato effect

 JSR MakeSoundOnSQ1     ; Make the current sound effect on the SQ1 channel

 JSR MakeSoundOnSQ2     ; Make the current sound effect on the SQ2 channel

 JMP MakeSoundOnNOISE   ; Make the current sound effect on the NOISE channel,
                        ; returning from the subroutine using a tail call

; ******************************************************************************
;
;       Name: MakeSoundOnSQ1
;       Type: Subroutine
;   Category: Sound
;    Summary: Make the current sound effect on the SQ1 channel
;  Deep dive: Sound effects in NES Elite
;
; ******************************************************************************

.MakeSoundOnSQ1

 LDA effectOnSQ1        ; If effectOnSQ1 is non-zero then a sound effect is
 BNE mscz1              ; being made on channel SQ1, so jump to mscz1 to keep
                        ; making it

 RTS                    ; Otherwise return from the subroutine

.mscz1

 LDA soundByteSQ1+0     ; If the remaining number of iterations for this sound
 BNE mscz3              ; effect in sound byte #0 is non-zero, jump to mscz3 to
                        ; keep making the sound

 LDX soundByteSQ1+12    ; If byte #12 of the sound effect data is non-zero, then
 BNE mscz3              ; this sound effect keeps looping, so jump to mscz3 to
                        ; keep making the sound

 LDA enableSound        ; If enableSound = 0 then sound is disabled, so jump to
 BEQ mscz2              ; mscz2 to silence the SQ1 channel and return from the
                        ; subroutine

                        ; If we get here then we have finished making the sound
                        ; effect, so we now send the volume and pitch values for
                        ; the music to the APU, so if there is any music playing
                        ; it will pick up again, and we mark this sound channel
                        ; as clear of sound effects

 LDA sq1Volume          ; Send sq1Volume to the APU via SQ1_VOL, which is the
 STA SQ1_VOL            ; volume byte of any music that was playing when the
                        ; sound effect took precedence

 LDA sq1Lo              ; Send (sq1Hi sq1Lo) to the APU via (SQ1_HI SQ1_LO),
 STA SQ1_LO             ; which is the pitch of any music that was playing when
 LDA sq1Hi              ; the sound effect took precedence
 STA SQ1_HI

 STX effectOnSQ1        ; Set effectOnSQ1 = 0 to mark the SQL channel as clear
                        ; of sound effects, so the channel can be used for music
                        ; and is ready for the next sound effect

 RTS                    ; Return from the subroutine

.mscz2

                        ; If we get here then sound is disabled, so we need to
                        ; silence the SQ1 channel

 LDA #%00110000         ; Set the volume of the SQ1 channel to zero as follows:
 STA SQ1_VOL            ;
                        ;   * Bits 6-7    = duty pulse length is 3
                        ;   * Bit 5 set   = infinite play
                        ;   * Bit 4 set   = constant volume
                        ;   * Bits 0-3    = volume is 0

 STX effectOnSQ1        ; Set effectOnSQ1 = 0 to mark the SQL channel as clear
                        ; of sound effects, so the channel can be used for music
                        ; and is ready for the next sound effect

 RTS                    ; Return from the subroutine

.mscz3

                        ; If we get here then we need to keep making the sound
                        ; effect on channel SQ1

 DEC soundByteSQ1+0     ; Decrement the remaining length of the sound in byte #0
                        ; as we are about to make the sound for another
                        ; iteration

 DEC soundVolCountSQ1   ; Decrement the volume envelope counter so we count down
                        ; towards the point where we apply the volume envelope

 BNE mscz5              ; If the volume envelope counter has not reached zero
                        ; then jump to mscz5, as we don't apply the next entry
                        ; from the volume envelope yet

                        ; If we get here then the counter in soundVolCountSQ1
                        ; just reached zero, so we apply the next entry from the
                        ; volume envelope

 LDA soundByteSQ1+11    ; Reset the volume envelope counter to byte #11 from the
 STA soundVolCountSQ1   ; sound effect's data, which controls how often we apply
                        ; the volume envelope to the sound effect

 LDY soundVolIndexSQ1   ; Set Y to the index of the current byte in the volume
                        ; envelope

 LDA soundVolumeSQ1     ; Set soundAddr(1 0) = soundVolumeSQ1(1 0)
 STA soundAddr          ;
 LDA soundVolumeSQ1+1   ; So soundAddr(1 0) contains the address of the volume
 STA soundAddr+1        ; envelope for this sound effect

 LDA (soundAddr),Y      ; Set A to the data byte at the current index in the
                        ; volume envelope

 BPL mscz4              ; If bit 7 is clear then we just fetched a volume value
                        ; from the envelope, so jump to mscz4 to apply it

                        ; If we get here then A must be $80 or $FF, as those are
                        ; the only two valid entries in the volume envelope that
                        ; have bit 7 set
                        ;
                        ; $80 means we loop back to the start of the envelope,
                        ; while $FF means the envelope ends here

 CMP #$80               ; If A is not $80 then we must have just fetched $FF
 BNE mscz5              ; from the envelope, so jump to mscz5 to exit the
                        ; envelope

                        ; If we get here then we just fetched a $80 from the
                        ; envelope data, so we now loop around to the start of
                        ; the envelope, so it keeps repeating

 LDY #0                 ; Set Y to zero so we fetch data from the start of the
                        ; envelope again

 LDA (soundAddr),Y      ; Set A to the byte of envelope data at index 0, so we
                        ; can fall through into mscz4 to process it

.mscz4

                        ; If we get here then A contains an entry from the
                        ; volume envelope for this sound effect, so now we send
                        ; it to the APU to change the volume

 ORA soundByteSQ1+6     ; OR the envelope byte with the sound effect's byte #6,
 STA SQ1_VOL            ; and send the result to the APU via SQ1_VOL
                        ;
                        ; Data bytes in the volume envelope data only use the
                        ; low nibble (the high nibble is only used to mark the
                        ; end of the data), and the sound effect's byte #6 only
                        ; uses the high nibble, so this sets the low nibble of
                        ; the APU byte to the volume level from the data, and
                        ; the high nibble of the APU byte to the configuration
                        ; in byte #6 (which sets the duty pulse, looping and
                        ; constant flags for the volume)

 INY                    ; Increment the index of the current byte in the volume
 STY soundVolIndexSQ1   ; envelope so on the next iteration we move on to the
                        ; next byte in the envelope

.mscz5

                        ; Now that we are done with the volume envelope, it's
                        ; time to move on to the pitch of the sound effect

 LDA soundPitCountSQ1   ; If the byte #1 counter has not yet run down to zero,
 BNE mscz8              ; jump to mscz8 to skip the following, so we don't send
                        ; pitch data to the APU on this iteration

                        ; If we get here then the counter in soundPitCountSQ1
                        ; (which counts down from the value of byte #1) has run
                        ; down to zero, so we now send pitch data to the ALU if
                        ; if we haven't yet sent it all

 LDA soundByteSQ1+12    ; If byte #12 is non-zero then the sound effect loops
 BNE mscz6              ; infinitely, so jump to mscz6 to send pitch data to the
                        ; APU

 LDA soundByteSQ1+9     ; Otherwise, if the counter in byte #9 has not run down
 BNE mscz6              ; then we haven't yet sent pitch data for enough
                        ; iterations, so jump to mscz6 to send pitch data to the
                        ; APU

 RTS                    ; Return from the subroutine

.mscz6

                        ; If we get here then we are sending pitch data to the
                        ; APU on this iteration, so now we do just that

 DEC soundByteSQ1+9     ; Decrement the counter in byte #9, which contains the
                        ; number of iterations for which we send pitch data to
                        ; the APU (as that's what we are doing)

 LDA soundByteSQ1+1     ; Reset the soundPitCountSQ1 counter to the value of
 STA soundPitCountSQ1   ; byte #1 so it can start counting down again to trigger
                        ; the next pitch change after this one

 LDA soundByteSQ1+2     ; Set A to the low byte of the sound effect's current
                        ; pitch, which is in byte #2 of the sound data

 LDX soundByteSQ1+7     ; If byte #7 is zero then vibrato is disabled, so jump
 BEQ mscz7              ; to mscz7 to skip the following instruction

 ADC soundVibrato       ; Byte #7 is non-zero, so add soundVibrato to the pitch
                        ; of the sound in A to apply vibrato (this also adds the
                        ; C flag, which is not in a fixed state, so this adds an
                        ; extra level of randomness to the vibrato effect)

.mscz7

 STA soundLoSQ1         ; Store the value of A (i.e. the low byte of the sound
                        ; effect's pitch, possibly with added vibrato) in
                        ; soundLoSQ1

 STA SQ1_LO             ; Send the value of soundLoSQ1 to the APU via SQ1_LO

 LDA soundByteSQ1+3     ; Set A to the high byte of the sound effect's current
                        ; pitch, which is in byte #3 of the sound data

 STA soundHiSQ1         ; Store the value of A (i.e. the high byte of the sound
                        ; effect's pitch) in soundHiSQ1

 STA SQ1_HI             ; Send the value of soundHiSQ1 to the APU via SQ1_HI

.mscz8

 DEC soundPitCountSQ1   ; Decrement the byte #1 counter, as we have now done one
                        ; more iteration of the sound effect

 LDA soundByteSQ1+13    ; If byte #13 of the sound data is zero then we apply
 BEQ mscz9              ; pitch variation in every iteration (if enabled), so
                        ; jump to mscz9 to skip the following and move straight
                        ; to the pitch variation checks

 DEC soundPitchEnvSQ1   ; Otherwise decrement the byte #13 counter to count down
                        ; towards the point where we apply pitch variation

 BNE mscz11             ; If the counter is not yet zero, jump to mscz11 to
                        ; return from the subroutine without applying pitch
                        ; variation, as the counter has not yet reached that
                        ; point

                        ; If we get here then the byte #13 counter just ran down
                        ; to zero, so we need to apply pitch variation (if
                        ; enabled)

 STA soundPitchEnvSQ1   ; Reset the soundPitchEnvSQ1 counter to the value of
                        ; byte #13 so it can start counting down again, for the
                        ; next pitch variation after this one

.mscz9

 LDA soundByteSQ1+8     ; Set A to byte #8 of the sound data, which determines
                        ; whether pitch variation is enabled

 BEQ mscz11             ; If A is zero then pitch variation is not enabled, so
                        ; jump to mscz11 to return from the subroutine without
                        ; applying pitch variation

                        ; If we get here then pitch variation is enabled, so now
                        ; we need to apply it

 BMI mscz10             ; If A is negative then we need to add the value to the
                        ; pitch's period, so jump to mscz10

                        ; If we get here then we need to subtract the 16-bit
                        ; value in bytes #4 and #5 from the pitch's period in
                        ; (soundHiSQ1 soundLoSQ1)
                        ;
                        ; Reducing the pitch's period increases its frequency,
                        ; so this makes the note frequency higher

 LDA soundLoSQ1         ; Subtract the 16-bit value in bytes #4 and #5 of the
 SEC                    ; sound data from (soundHiSQ1 soundLoSQ1), updating
 SBC soundByteSQ1+4     ; (soundHiSQ1 soundLoSQ1) to the result, and sending
 STA soundLoSQ1         ; it to the APU via (SQ1_HI SQ1_LO)
 STA SQ1_LO             ;
 LDA soundHiSQ1         ; Note that bits 2 to 7 of the high byte are cleared so
 SBC soundByteSQ1+5     ; the length counter does not reload
 AND #%00000011
 STA soundHiSQ1
 STA SQ1_HI

 RTS                    ; Return from the subroutine

.mscz10

                        ; If we get here then we need to add the 16-bit value
                        ; in bytes #4 and #5 to the pitch's period in
                        ; (soundHiSQ1 soundLoSQ1)
                        ;
                        ; Increasing the pitch's period reduces its frequency,
                        ; so this makes the note frequency lower

 LDA soundLoSQ1         ; Add the 16-bit value in bytes #4 and #5 of the sound
 CLC                    ; data to (soundHiSQ1 soundLoSQ1), updating
 ADC soundByteSQ1+4     ; (soundHiSQ1 soundLoSQ1) to the result, and sending
 STA soundLoSQ1         ; it to the APU via (SQ1_HI SQ1_LO)
 STA SQ1_LO             ;
 LDA soundHiSQ1         ; Note that bits 2 to 7 of the high byte are cleared so
 ADC soundByteSQ1+5     ; the length counter does not reload
 AND #%00000011
 STA soundHiSQ1
 STA SQ1_HI

.mscz11

 RTS                    ; Return from the subroutine

; ******************************************************************************
;
;       Name: MakeSoundOnSQ2
;       Type: Subroutine
;   Category: Sound
;    Summary: Make the current sound effect on the SQ2 channel
;  Deep dive: Sound effects in NES Elite
;
; ******************************************************************************

.MakeSoundOnSQ2

 LDA effectOnSQ2        ; If effectOnSQ2 is non-zero then a sound effect is
 BNE msco1              ; being made on channel SQ2, so jump to msco1 to keep
                        ; making it

 RTS                    ; Otherwise return from the subroutine

.msco1

 LDA soundByteSQ2+0     ; If the remaining number of iterations for this sound
 BNE msco3              ; effect in sound byte #0 is non-zero, jump to msco3 to
                        ; keep making the sound

 LDX soundByteSQ2+12    ; If byte #12 of the sound effect data is non-zero, then
 BNE msco3              ; this sound effect keeps looping, so jump to msco3 to
                        ; keep making the sound

 LDA enableSound        ; If enableSound = 0 then sound is disabled, so jump to
 BEQ msco2              ; msco2 to silence the SQ2 channel and return from the
                        ; subroutine

                        ; If we get here then we have finished making the sound
                        ; effect, so we now send the volume and pitch values for
                        ; the music to the APU, so if there is any music playing
                        ; it will pick up again, and we mark this sound channel
                        ; as clear of sound effects

 LDA sq2Volume          ; Send sq2Volume to the APU via SQ2_VOL, which is the
 STA SQ2_VOL            ; volume byte of any music that was playing when the
                        ; sound effect took precedence

 LDA sq2Lo              ; Send (sq2Hi sq2Lo) to the APU via (SQ2_HI SQ2_LO),
 STA SQ2_LO             ; which is the pitch of any music that was playing when
 LDA sq2Hi              ; the sound effect took precedence
 STA SQ2_HI

 STX effectOnSQ2        ; Set effectOnSQ2 = 0 to mark the SQL channel as clear
                        ; of sound effects, so the channel can be used for music
                        ; and is ready for the next sound effect

 RTS                    ; Return from the subroutine

.msco2

                        ; If we get here then sound is disabled, so we need to
                        ; silence the SQ2 channel

 LDA #%00110000         ; Set the volume of the SQ2 channel to zero as follows:
 STA SQ2_VOL            ;
                        ;   * Bits 6-7    = duty pulse length is 3
                        ;   * Bit 5 set   = infinite play
                        ;   * Bit 4 set   = constant volume
                        ;   * Bits 0-3    = volume is 0

 STX effectOnSQ2        ; Set effectOnSQ2 = 0 to mark the SQL channel as clear
                        ; of sound effects, so the channel can be used for music
                        ; and is ready for the next sound effect

 RTS                    ; Return from the subroutine

.msco3

                        ; If we get here then we need to keep making the sound
                        ; effect on channel SQ2

 DEC soundByteSQ2+0     ; Decrement the remaining length of the sound in byte #0
                        ; as we are about to make the sound for another
                        ; iteration

 DEC soundVolCountSQ2   ; Decrement the volume envelope counter so we count down
                        ; towards the point where we apply the volume envelope

 BNE msco5              ; If the volume envelope counter has not reached zero
                        ; then jump to msco5, as we don't apply the next entry
                        ; from the volume envelope yet

                        ; If we get here then the counter in soundVolCountSQ2
                        ; just reached zero, so we apply the next entry from the
                        ; volume envelope

 LDA soundByteSQ2+11    ; Reset the volume envelope counter to byte #11 from the
 STA soundVolCountSQ2   ; sound effect's data, which controls how often we apply
                        ; the volume envelope to the sound effect

 LDY soundVolIndexSQ2   ; Set Y to the index of the current byte in the volume
                        ; envelope

 LDA soundVolumeSQ2     ; Set soundAddr(1 0) = soundVolumeSQ2(1 0)
 STA soundAddr          ;
 LDA soundVolumeSQ2+1   ; So soundAddr(1 0) contains the address of the volume
 STA soundAddr+1        ; envelope for this sound effect

 LDA (soundAddr),Y      ; Set A to the data byte at the current index in the
                        ; volume envelope

 BPL msco4              ; If bit 7 is clear then we just fetched a volume value
                        ; from the envelope, so jump to msco4 to apply it

                        ; If we get here then A must be $80 or $FF, as those are
                        ; the only two valid entries in the volume envelope that
                        ; have bit 7 set
                        ;
                        ; $80 means we loop back to the start of the envelope,
                        ; while $FF means the envelope ends here

 CMP #$80               ; If A is not $80 then we must have just fetched $FF
 BNE msco5              ; from the envelope, so jump to msco5 to exit the
                        ; envelope

                        ; If we get here then we just fetched a $80 from the
                        ; envelope data, so we now loop around to the start of
                        ; the envelope, so it keeps repeating

 LDY #0                 ; Set Y to zero so we fetch data from the start of the
                        ; envelope again

 LDA (soundAddr),Y      ; Set A to the byte of envelope data at index 0, so we
                        ; can fall through into msco4 to process it

.msco4

                        ; If we get here then A contains an entry from the
                        ; volume envelope for this sound effect, so now we send
                        ; it to the APU to change the volume

 ORA soundByteSQ2+6     ; OR the envelope byte with the sound effect's byte #6,
 STA SQ2_VOL            ; and send the result to the APU via SQ2_VOL
                        ;
                        ; Data bytes in the volume envelope data only use the
                        ; low nibble (the high nibble is only used to mark the
                        ; end of the data), and the sound effect's byte #6 only
                        ; uses the high nibble, so this sets the low nibble of
                        ; the APU byte to the volume level from the data, and
                        ; the high nibble of the APU byte to the configuration
                        ; in byte #6 (which sets the duty pulse, looping and
                        ; constant flags for the volume)

 INY                    ; Increment the index of the current byte in the volume
 STY soundVolIndexSQ2   ; envelope so on the next iteration we move on to the
                        ; next byte in the envelope

.msco5

                        ; Now that we are done with the volume envelope, it's
                        ; time to move on to the pitch of the sound effect

 LDA soundPitCountSQ2   ; If the byte #1 counter has not yet run down to zero,
 BNE msco8              ; jump to msco8 to skip the following, so we don't send
                        ; pitch data to the APU on this iteration

                        ; If we get here then the counter in soundPitCountSQ2
                        ; (which counts down from the value of byte #1) has run
                        ; down to zero, so we now send pitch data to the ALU if
                        ; if we haven't yet sent it all

 LDA soundByteSQ2+12    ; If byte #12 is non-zero then the sound effect loops
 BNE msco6              ; infinitely, so jump to msco6 to send pitch data to the
                        ; APU

 LDA soundByteSQ2+9     ; Otherwise, if the counter in byte #9 has not run down
 BNE msco6              ; then we haven't yet sent pitch data for enough
                        ; iterations, so jump to msco6 to send pitch data to the
                        ; APU

 RTS                    ; Return from the subroutine

.msco6

                        ; If we get here then we are sending pitch data to the
                        ; APU on this iteration, so now we do just that

 DEC soundByteSQ2+9     ; Decrement the counter in byte #9, which contains the
                        ; number of iterations for which we send pitch data to
                        ; the APU (as that's what we are doing)

 LDA soundByteSQ2+1     ; Reset the soundPitCountSQ2 counter to the value of
 STA soundPitCountSQ2   ; byte #1 so it can start counting down again to trigger
                        ; the next pitch change after this one

 LDA soundByteSQ2+2     ; Set A to the low byte of the sound effect's current
                        ; pitch, which is in byte #2 of the sound data

 LDX soundByteSQ2+7     ; If byte #7 is zero then vibrato is disabled, so jump
 BEQ msco7              ; to msco7 to skip the following instruction

 ADC soundVibrato       ; Byte #7 is non-zero, so add soundVibrato to the pitch
                        ; of the sound in A to apply vibrato (this also adds the
                        ; C flag, which is not in a fixed state, so this adds an
                        ; extra level of randomness to the vibrato effect)

.msco7

 STA soundLoSQ2         ; Store the value of A (i.e. the low byte of the sound
                        ; effect's pitch, possibly with added vibrato) in
                        ; soundLoSQ2

 STA SQ2_LO             ; Send the value of soundLoSQ2 to the APU via SQ2_LO

 LDA soundByteSQ2+3     ; Set A to the high byte of the sound effect's current
                        ; pitch, which is in byte #3 of the sound data

 STA soundHiSQ2         ; Store the value of A (i.e. the high byte of the sound
                        ; effect's pitch) in soundHiSQ2

 STA SQ2_HI             ; Send the value of soundHiSQ2 to the APU via SQ2_HI

.msco8

 DEC soundPitCountSQ2   ; Decrement the byte #1 counter, as we have now done one
                        ; more iteration of the sound effect

 LDA soundByteSQ2+13    ; If byte #13 of the sound data is zero then we apply
 BEQ msco9              ; pitch variation in every iteration (if enabled), so
                        ; jump to msco9 to skip the following and move straight
                        ; to the pitch variation checks

 DEC soundPitchEnvSQ2   ; Otherwise decrement the byte #13 counter to count down
                        ; towards the point where we apply pitch variation

 BNE msco11             ; If the counter is not yet zero, jump to msco11 to
                        ; return from the subroutine without applying pitch
                        ; variation, as the counter has not yet reached that
                        ; point

                        ; If we get here then the byte #13 counter just ran down
                        ; to zero, so we need to apply pitch variation (if
                        ; enabled)

 STA soundPitchEnvSQ2   ; Reset the soundPitchEnvSQ2 counter to the value of
                        ; byte #13 so it can start counting down again, for the
                        ; next pitch variation after this one

.msco9

 LDA soundByteSQ2+8     ; Set A to byte #8 of the sound data, which determines
                        ; whether pitch variation is enabled

 BEQ msco11             ; If A is zero then pitch variation is not enabled, so
                        ; jump to msco11 to return from the subroutine without
                        ; applying pitch variation

                        ; If we get here then pitch variation is enabled, so now
                        ; we need to apply it

 BMI msco10             ; If A is negative then we need to add the value to the
                        ; pitch's period, so jump to msco10

                        ; If we get here then we need to subtract the 16-bit
                        ; value in bytes #4 and #5 from the pitch's period in
                        ; (soundHiSQ2 soundLoSQ2)
                        ;
                        ; Reducing the pitch's period increases its frequency,
                        ; so this makes the note frequency higher

 LDA soundLoSQ2         ; Subtract the 16-bit value in bytes #4 and #5 of the
 SEC                    ; sound data from (soundHiSQ2 soundLoSQ2), updating
 SBC soundByteSQ2+4     ; (soundHiSQ2 soundLoSQ2) to the result, and sending
 STA soundLoSQ2         ; it to the APU via (SQ2_HI SQ2_LO)
 STA SQ2_LO             ;
 LDA soundHiSQ2         ; Note that bits 2 to 7 of the high byte are cleared so
 SBC soundByteSQ2+5     ; the length counter does not reload
 AND #%00000011
 STA soundHiSQ2
 STA SQ2_HI

 RTS                    ; Return from the subroutine

.msco10

                        ; If we get here then we need to add the 16-bit value
                        ; in bytes #4 and #5 to the pitch's period in
                        ; (soundHiSQ2 soundLoSQ2)
                        ;
                        ; Increasing the pitch's period reduces its frequency,
                        ; so this makes the note frequency lower

 LDA soundLoSQ2         ; Add the 16-bit value in bytes #4 and #5 of the sound
 CLC                    ; data to (soundHiSQ2 soundLoSQ2), updating
 ADC soundByteSQ2+4     ; (soundHiSQ2 soundLoSQ2) to the result, and sending
 STA soundLoSQ2         ; it to the APU via (SQ2_HI SQ2_LO)
 STA SQ2_LO             ;
 LDA soundHiSQ2         ; Note that bits 2 to 7 of the high byte are cleared so
 ADC soundByteSQ2+5     ; the length counter does not reload
 AND #%00000011
 STA soundHiSQ2
 STA SQ2_HI

.msco11

 RTS                    ; Return from the subroutine

; ******************************************************************************
;
;       Name: MakeSoundOnNOISE
;       Type: Subroutine
;   Category: Sound
;    Summary: Make the current sound effect on the NOISE channel
;  Deep dive: Sound effects in NES Elite
;
; ******************************************************************************

.MakeSoundOnNOISE

 LDA effectOnNOISE      ; If effectOnNOISE is non-zero then a sound effect is
 BNE msct1              ; being made on channel NOISE, so jump to msct1 to keep
                        ; making it

 RTS                    ; Otherwise return from the subroutine

.msct1

 LDA soundByteNOISE+0   ; If the remaining number of iterations for this sound
 BNE msct3              ; effect in sound byte #0 is non-zero, jump to msct3 to
                        ; keep making the sound

 LDX soundByteNOISE+12  ; If byte #12 of the sound effect data is non-zero, then
 BNE msct3              ; this sound effect keeps looping, so jump to msct3 to
                        ; keep making the sound

 LDA enableSound        ; If enableSound = 0 then sound is disabled, so jump to
 BEQ msct2              ; msct2 to silence the NOISE channel and return from the
                        ; subroutine

                        ; If we get here then we have finished making the sound
                        ; effect, so we now send the volume and pitch values for
                        ; the music to the APU, so if there is any music playing
                        ; it will pick up again, and we mark this sound channel
                        ; as clear of sound effects

 LDA noiseVolume        ; Send noiseVolume to the APU via NOISE_VOL, which is
 STA NOISE_VOL          ; the volume byte of any music that was playing when the
                        ; sound effect took precedence

 LDA noiseLo            ; Send (noiseHi noiseLo) to the APU via NOISE_LO, which
 STA NOISE_LO           ; is the pitch of any music that was playing when the
                        ; sound effect took precedence

 STX effectOnNOISE      ; Set effectOnNOISE = 0 to mark the SQL channel as clear
                        ; of sound effects, so the channel can be used for music
                        ; and is ready for the next sound effect

 RTS                    ; Return from the subroutine

.msct2

                        ; If we get here then sound is disabled, so we need to
                        ; silence the NOISE channel

 LDA #%00110000         ; Set the volume of the NOISE channel to zero as
 STA NOISE_VOL          ; follows:
                        ;
                        ;   * Bits 6-7    = duty pulse length is 3
                        ;   * Bit 5 set   = infinite play
                        ;   * Bit 4 set   = constant volume
                        ;   * Bits 0-3    = volume is 0

 STX effectOnNOISE      ; Set effectOnNOISE = 0 to mark the SQL channel as clear
                        ; of sound effects, so the channel can be used for music
                        ; and is ready for the next sound effect

 RTS                    ; Return from the subroutine

.msct3

                        ; If we get here then we need to keep making the sound
                        ; effect on channel NOISE

 DEC soundByteNOISE+0   ; Decrement the remaining length of the sound in byte #0
                        ; as we are about to make the sound for another
                        ; iteration

 DEC soundVolCountNOISE ; Decrement the volume envelope counter so we count down
                        ; towards the point where we apply the volume envelope

 BNE msct5              ; If the volume envelope counter has not reached zero
                        ; then jump to msct5, as we don't apply the next entry
                        ; from the volume envelope yet

                        ; If we get here then the counter in soundVolCountNOISE
                        ; just reached zero, so we apply the next entry from the
                        ; volume envelope

 LDA soundByteNOISE+11  ; Reset the volume envelope counter to byte #11 from the
 STA soundVolCountNOISE ; sound effect's data, which controls how often we apply
                        ; the volume envelope to the sound effect

 LDY soundVolIndexNOISE ; Set Y to the index of the current byte in the volume
                        ; envelope

 LDA soundVolumeNOISE   ; Set soundAddr(1 0) = soundVolumeNOISE(1 0)
 STA soundAddr          ;
 LDA soundVolumeNOISE+1 ; So soundAddr(1 0) contains the address of the volume
 STA soundAddr+1        ; envelope for this sound effect

 LDA (soundAddr),Y      ; Set A to the data byte at the current index in the
                        ; volume envelope

 BPL msct4              ; If bit 7 is clear then we just fetched a volume value
                        ; from the envelope, so jump to msct4 to apply it

                        ; If we get here then A must be $80 or $FF, as those are
                        ; the only two valid entries in the volume envelope that
                        ; have bit 7 set
                        ;
                        ; $80 means we loop back to the start of the envelope,
                        ; while $FF means the envelope ends here

 CMP #$80               ; If A is not $80 then we must have just fetched $FF
 BNE msct5              ; from the envelope, so jump to msct5 to exit the
                        ; envelope

                        ; If we get here then we just fetched a $80 from the
                        ; envelope data, so we now loop around to the start of
                        ; the envelope, so it keeps repeating

 LDY #0                 ; Set Y to zero so we fetch data from the start of the
                        ; envelope again

 LDA (soundAddr),Y      ; Set A to the byte of envelope data at index 0, so we
                        ; can fall through into msct4 to process it

.msct4

                        ; If we get here then A contains an entry from the
                        ; volume envelope for this sound effect, so now we send
                        ; it to the APU to change the volume

 ORA soundByteNOISE+6   ; OR the envelope byte with the sound effect's byte #6,
 STA NOISE_VOL          ; and send the result to the APU via NOISE_VOL
                        ;
                        ; Data bytes in the volume envelope data only use the
                        ; low nibble (the high nibble is only used to mark the
                        ; end of the data), and the sound effect's byte #6 only
                        ; uses the high nibble, so this sets the low nibble of
                        ; the APU byte to the volume level from the data, and
                        ; the high nibble of the APU byte to the configuration
                        ; in byte #6 (which sets the duty pulse, looping and
                        ; constant flags for the volume)

 INY                    ; Increment the index of the current byte in the volume
 STY soundVolIndexNOISE ; envelope so on the next iteration we move on to the
                        ; next byte in the envelope

.msct5

                        ; Now that we are done with the volume envelope, it's
                        ; time to move on to the pitch of the sound effect

 LDA soundPitCountNOISE ; If the byte #1 counter has not yet run down to zero,
 BNE msct8              ; jump to msct8 to skip the following, so we don't send
                        ; pitch data to the APU on this iteration

                        ; If we get here then the counter in soundPitCountNOISE
                        ; (which counts down from the value of byte #1) has run
                        ; down to zero, so we now send pitch data to the ALU if
                        ; if we haven't yet sent it all

 LDA soundByteNOISE+12  ; If byte #12 is non-zero then the sound effect loops
 BNE msct6              ; infinitely, so jump to msct6 to send pitch data to the
                        ; APU

 LDA soundByteNOISE+9   ; Otherwise, if the counter in byte #9 has not run down
 BNE msct6              ; then we haven't yet sent pitch data for enough
                        ; iterations, so jump to msct6 to send pitch data to the
                        ; APU

 RTS                    ; Return from the subroutine

.msct6

                        ; If we get here then we are sending pitch data to the
                        ; APU on this iteration, so now we do just that

 DEC soundByteNOISE+9   ; Decrement the counter in byte #9, which contains the
                        ; number of iterations for which we send pitch data to
                        ; the APU (as that's what we are doing)

 LDA soundByteNOISE+1   ; Reset the soundPitCountNOISE counter to the value of
 STA soundPitCountNOISE ; byte #1 so it can start counting down again to trigger
                        ; the next pitch change after this one

 LDA soundByteNOISE+2   ; Set A to the low byte of the sound effect's current
                        ; pitch, which is in byte #2 of the sound data

 LDX soundByteNOISE+7   ; If byte #7 is zero then vibrato is disabled, so jump
 BEQ msct7              ; to msct7 to skip the following instruction

 ADC soundVibrato       ; Byte #7 is non-zero, so add soundVibrato to the pitch
                        ; of the sound in A to apply vibrato (this also adds the
                        ; C flag, which is not in a fixed state, so this adds an
                        ; extra level of randomness to the vibrato effect)

 AND #%00001111         ; We extract the low nibble because the high nibble is
                        ; ignored in NOISE_LO, except for bit 7, which we want
                        ; to clear so the period of the random noise generation
                        ; is normal and not shortened

.msct7

 STA soundLoNOISE       ; Store the value of A (i.e. the low byte of the sound
                        ; effect's pitch, possibly with added vibrato) in
                        ; soundLoNOISE

 STA NOISE_LO           ; Send the value of soundLoNOISE to the APU via NOISE_LO

.msct8

 DEC soundPitCountNOISE ; Decrement the byte #1 counter, as we have now done one
                        ; more iteration of the sound effect

 LDA soundByteNOISE+13  ; If byte #13 of the sound data is zero then we apply
 BEQ msct9              ; pitch variation in every iteration (if enabled), so
                        ; jump to msct9 to skip the following and move straight
                        ; to the pitch variation checks

 DEC soundPitchEnvNOISE ; Otherwise decrement the byte #13 counter to count down
                        ; towards the point where we apply pitch variation

 BNE msct11             ; If the counter is not yet zero, jump to msct11 to
                        ; return from the subroutine without applying pitch
                        ; variation, as the counter has not yet reached that
                        ; point

                        ; If we get here then the byte #13 counter just ran down
                        ; to zero, so we need to apply pitch variation (if
                        ; enabled)

 STA soundPitchEnvNOISE ; Reset the soundPitchEnvNOISE counter to the value of
                        ; byte #13 so it can start counting down again, for the
                        ; next pitch variation after this one

.msct9

 LDA soundByteNOISE+8   ; Set A to byte #8 of the sound data, which determines
                        ; whether pitch variation is enabled

 BEQ msct11             ; If A is zero then pitch variation is not enabled, so
                        ; jump to msct11 to return from the subroutine without
                        ; applying pitch variation

                        ; If we get here then pitch variation is enabled, so now
                        ; we need to apply it

 BMI msct10             ; If A is negative then we need to add the value to the
                        ; pitch's period, so jump to msct10

                        ; If we get here then we need to subtract the 8-bit
                        ; value in byte #4 from the pitch's period in
                        ; soundLoNOISE
                        ;
                        ; Reducing the pitch's period increases its frequency,
                        ; so this makes the note frequency higher

 LDA soundLoNOISE       ; Subtract the 8-bit value in byte #4 of the sound data
 SEC                    ; from soundLoNOISE, updating soundLoNOISE to the
 SBC soundByteNOISE+4   ; result, and sending it to the APU via NOISE_LO
 AND #$0F
 STA soundLoNOISE
 STA NOISE_LO

 RTS                    ; Return from the subroutine

.msct10

                        ; If we get here then we need to add the 8-bit value in
                        ; byte #4 to the pitch's period in soundLoNOISE
                        ;
                        ; Increasing the pitch's period reduces its frequency,
                        ; so this makes the note frequency lower

 LDA soundLoNOISE       ; Add the 8-bit value in byte #4 of the sound data to
 CLC                    ; soundLoNOISE, updating soundLoNOISE to the result, and
 ADC soundByteNOISE+4   ; sending it to the APU via NOISE_LO
 AND #$0F
 STA soundLoNOISE
 STA NOISE_LO

.msct11

 RTS                    ; Return from the subroutine

; ******************************************************************************
;
;       Name: UpdateVibratoSeeds
;       Type: Subroutine
;   Category: Sound
;    Summary: Update the sound seeds that are used to randomise the vibrato
;             effect
;  Deep dive: Sound effects in NES Elite
;
; ******************************************************************************

.UpdateVibratoSeeds

 LDA soundVibrato       ; Set A to soundVibrato with all bits cleared except for
 AND #%01001000         ; bits 3 and 6

 ADC #%00111000         ; Add %00111000, so if bit 3 of A is clear, we leave
                        ; bit 6 alone, otherwise bit 6 gets flipped
                        ;
                        ; The C flag doesn't affect this calculation, as it
                        ; will only affect bit 0, which we don't care about

 ASL A                  ; Set the C flag to bit 6 of A
 ASL A                  ;
                        ; So the C flag is:
                        ;
                        ;   * Bit 6 of soundVibrato if bit 3 of soundVibrato is
                        ;     clear
                        ;
                        ;   * Bit 6 of soundVibrato flipped if bit 3 of
                        ;     soundVibrato is set
                        ;
                        ; Or, to put it another way:
                        ;
                        ;   C = bit 6 of soundVibrato EOR bit 3 of soundVibrato

 ROL soundVibrato+3     ; Rotate soundVibrato(0 1 2 3) left, inserting the C
 ROL soundVibrato+2     ; flag into bit 0 of soundVibrato+3
 ROL soundVibrato+1
 ROL soundVibrato

 RTS                    ; Return from the subroutine

; ******************************************************************************
;
;       Name: soundData
;       Type: Variable
;   Category: Sound
;    Summary: Sound data for the sound effects
;  Deep dive: Sound effects in NES Elite
;
; ******************************************************************************

.soundData

 EQUW soundData0
 EQUW soundData1
 EQUW soundData2
 EQUW soundData3
 EQUW soundData4
 EQUW soundData5
 EQUW soundData6
 EQUW soundData7
 EQUW soundData8
 EQUW soundData9
 EQUW soundData10
 EQUW soundData11
 EQUW soundData12
 EQUW soundData13
 EQUW soundData14
 EQUW soundData15
 EQUW soundData16
 EQUW soundData17
 EQUW soundData18
 EQUW soundData19
 EQUW soundData20
 EQUW soundData21
 EQUW soundData22
 EQUW soundData23
 EQUW soundData24
 EQUW soundData25
 EQUW soundData26
 EQUW soundData27
 EQUW soundData28
 EQUW soundData29
 EQUW soundData30
 EQUW soundData31

.soundData0

 EQUB $3C, $03, $04, $00, $02, $00, $30, $00
 EQUB $01, $0A, $00, $05, $00, $63

.soundData1

 EQUB $16, $04, $A8, $00, $04, $00, $70, $00
 EQUB $FF, $63, $0C, $02, $00, $00

.soundData2

 EQUB $19, $19, $AC, $03, $1C, $00, $30, $00
 EQUB $01, $63, $06, $02, $FF, $00

.soundData3

 EQUB $05, $63, $2C, $00, $00, $00, $70, $00
 EQUB $00, $63, $0C, $01, $00, $00

.soundData4

 EQUB $09, $63, $57, $02, $02, $00, $B0, $00
 EQUB $FF, $63, $08, $01, $00, $00

.soundData5

 EQUB $0A, $02, $18, $00, $01, $00, $30, $FF
 EQUB $FF, $0A, $0C, $01, $00, $00

.soundData6

 EQUB $0D, $02, $28, $00, $01, $00, $70, $FF
 EQUB $FF, $0A, $0C, $01, $00, $00

.soundData7

 EQUB $19, $1C, $00, $01, $06, $00, $70, $00
 EQUB $01, $63, $06, $02, $00, $00

.soundData8

 EQUB $5A, $09, $14, $00, $01, $00, $30, $00
 EQUB $FF, $63, $00, $0B, $00, $00

.soundData9

 EQUB $46, $28, $02, $00, $01, $00, $30, $00
 EQUB $FF, $00, $08, $06, $00, $03

.soundData10

 EQUB $0E, $03, $6C, $00, $21, $00, $B0, $00
 EQUB $FF, $63, $0C, $02, $00, $00

.soundData11

 EQUB $13, $0F, $08, $00, $01, $00, $30, $00
 EQUB $FF, $00, $0C, $03, $00, $02

.soundData12

 EQUB $AA, $78, $1F, $00, $01, $00, $30, $00
 EQUB $01, $00, $01, $08, $00, $0A

.soundData13

 EQUB $59, $02, $4F, $00, $29, $00, $B0, $FF
 EQUB $01, $FF, $00, $09, $00, $00

.soundData14

 EQUB $19, $05, $82, $01, $29, $00, $B0, $FF
 EQUB $FF, $FF, $08, $02, $00, $00

.soundData15

 EQUB $22, $05, $82, $01, $29, $00, $B0, $FF
 EQUB $FF, $FF, $08, $03, $00, $00

.soundData16

 EQUB $0F, $63, $B0, $00, $20, $00, $70, $00
 EQUB $FF, $63, $08, $02, $00, $00

.soundData17

 EQUB $0D, $63, $8F, $01, $31, $00, $30, $00
 EQUB $FF, $63, $10, $02, $00, $00

.soundData18

 EQUB $18, $05, $FF, $01, $31, $00, $30, $00
 EQUB $FF, $63, $10, $03, $00, $00

.soundData19

 EQUB $46, $03, $42, $03, $29, $00, $B0, $00
 EQUB $FF, $FF, $0C, $06, $00, $00

.soundData20

 EQUB $0C, $02, $57, $00, $14, $00, $B0, $00
 EQUB $FF, $63, $0C, $01, $00, $00

.soundData21

 EQUB $82, $46, $0F, $00, $01, $00, $B0, $00
 EQUB $01, $00, $01, $07, $00, $05

.soundData22

 EQUB $82, $46, $00, $00, $01, $00, $B0, $00
 EQUB $FF, $00, $01, $07, $00, $05

.soundData23

 EQUB $19, $05, $82, $01, $29, $00, $B0, $FF
 EQUB $FF, $FF, $0E, $02, $00, $00

.soundData24

 EQUB $AA, $78, $1F, $00, $01, $00, $30, $00
 EQUB $01, $00, $01, $08, $00, $0A

.soundData25

 EQUB $14, $03, $08, $00, $01, $00, $30, $00
 EQUB $FF, $FF, $00, $02, $00, $00

.soundData26

 EQUB $01, $00, $00, $00, $00, $00, $30, $00
 EQUB $00, $00, $0D, $00, $00, $00

.soundData27

 EQUB $19, $05, $82, $01, $29, $00, $B0, $FF
 EQUB $FF, $FF, $0F, $02, $00, $00

.soundData28

 EQUB $0B, $04, $42, $00, $08, $00, $B0, $00
 EQUB $01, $63, $08, $01, $00, $02

.soundData29

 EQUB $96, $1C, $00, $01, $06, $00, $70, $00
 EQUB $01, $63, $06, $02, $00, $00

.soundData30

 EQUB $96, $1C, $00, $01, $06, $00, $70, $00
 EQUB $01, $63, $06, $02, $00, $00

.soundData31

 EQUB $14, $02, $28, $00, $01, $00, $70, $FF
 EQUB $FF, $0A, $00, $02, $00, $00

; ******************************************************************************
;
;       Name: soundVolume
;       Type: Variable
;   Category: Sound
;    Summary: Volume envelope data for the sound effects
;  Deep dive: Sound effects in NES Elite
;
; ******************************************************************************

.soundVolume

 EQUW soundVolume0
 EQUW soundVolume1
 EQUW soundVolume2
 EQUW soundVolume3
 EQUW soundVolume4
 EQUW soundVolume5
 EQUW soundVolume6
 EQUW soundVolume7
 EQUW soundVolume8
 EQUW soundVolume9
 EQUW soundVolume10
 EQUW soundVolume11
 EQUW soundVolume12
 EQUW soundVolume13
 EQUW soundVolume14
 EQUW soundVolume15
 EQUW soundVolume16

.soundVolume0

 EQUB $0F, $0D, $0B, $09, $07, $05, $03, $01
 EQUB $00, $FF

.soundVolume1

 EQUB $03, $05, $07, $09, $0A, $0C, $0E, $0E
 EQUB $0E, $0C, $0C, $0A, $0A, $09, $09, $07
 EQUB $06, $05, $04, $03, $02, $02, $01, $FF

.soundVolume2

 EQUB $02, $06, $08, $00, $FF

.soundVolume3

 EQUB $06, $08, $0A, $0B, $0C, $0B, $0A, $09
 EQUB $08, $07, $06, $05, $04, $03, $02, $01
 EQUB $FF

.soundVolume4

 EQUB $01, $03, $06, $08, $0C, $80

.soundVolume5

 EQUB $01, $04, $09, $0D, $80

.soundVolume6

 EQUB $01, $04, $07, $09, $FF

.soundVolume7

 EQUB $09, $80

.soundVolume8

 EQUB $0E, $0C, $0B, $09, $07, $05, $04, $03
 EQUB $02, $01, $FF

.soundVolume9

 EQUB $0C, $00, $00, $0C, $00, $00, $FF

.soundVolume10

 EQUB $0B, $80

.soundVolume11

 EQUB $0A, $0B, $0C, $0D, $0C, $80

.soundVolume12

 EQUB $0C, $0A, $09, $07, $05, $04, $03, $02
 EQUB $01, $FF

.soundVolume13

 EQUB $00, $FF

.soundVolume14

 EQUB $04, $05, $06, $06, $05, $04, $03, $02
 EQUB $01, $FF

.soundVolume15

 EQUB $06, $05, $04, $03, $02, $01, $FF

.soundVolume16

 EQUB $0C, $0A, $09, $07, $05, $05, $04, $04
 EQUB $03, $03, $02, $02, $01, $01, $FF

; ******************************************************************************
;
;       Name: volumeEnvelope
;       Type: Variable
;   Category: Sound
;    Summary: Volume envelope data for the game music
;  Deep dive: Music in NES Elite
;
; ******************************************************************************

.volumeEnvelope

.volumeEnvelopeLo

 EQUB LO(volumeEnvelope0)
 EQUB LO(volumeEnvelope1)
 EQUB LO(volumeEnvelope2)
 EQUB LO(volumeEnvelope3)
 EQUB LO(volumeEnvelope4)
 EQUB LO(volumeEnvelope5)
 EQUB LO(volumeEnvelope6)
 EQUB LO(volumeEnvelope7)
 EQUB LO(volumeEnvelope8)
 EQUB LO(volumeEnvelope9)
 EQUB LO(volumeEnvelope10)
 EQUB LO(volumeEnvelope11)
 EQUB LO(volumeEnvelope12)
 EQUB LO(volumeEnvelope13)
 EQUB LO(volumeEnvelope14)
 EQUB LO(volumeEnvelope15)
 EQUB LO(volumeEnvelope16)
 EQUB LO(volumeEnvelope17)
 EQUB LO(volumeEnvelope18)
 EQUB LO(volumeEnvelope19)

.volumeEnvelopeHi

 EQUB HI(volumeEnvelope0)
 EQUB HI(volumeEnvelope1)
 EQUB HI(volumeEnvelope2)
 EQUB HI(volumeEnvelope3)
 EQUB HI(volumeEnvelope4)
 EQUB HI(volumeEnvelope5)
 EQUB HI(volumeEnvelope6)
 EQUB HI(volumeEnvelope7)
 EQUB HI(volumeEnvelope8)
 EQUB HI(volumeEnvelope9)
 EQUB HI(volumeEnvelope10)
 EQUB HI(volumeEnvelope11)
 EQUB HI(volumeEnvelope12)
 EQUB HI(volumeEnvelope13)
 EQUB HI(volumeEnvelope14)
 EQUB HI(volumeEnvelope15)
 EQUB HI(volumeEnvelope16)
 EQUB HI(volumeEnvelope17)
 EQUB HI(volumeEnvelope18)
 EQUB HI(volumeEnvelope19)

.volumeEnvelope0

 EQUB $01, $0A, $0F, $0C, $8A

.volumeEnvelope1

 EQUB $01, $0A, $0F, $0B, $09, $87

.volumeEnvelope2

 EQUB $01, $0E, $0C, $09, $07, $0B, $0A, $07
 EQUB $05, $09, $07, $05, $04, $07, $06, $04
 EQUB $03, $05, $04, $03, $02, $03, $02, $01
 EQUB $80

.volumeEnvelope3

 EQUB $01, $0E, $0D, $0B, $09, $07, $0C, $0B
 EQUB $09, $07, $05, $0A, $09, $07, $05, $03
 EQUB $08, $07, $05, $03, $02, $06, $05, $03
 EQUB $02, $80

.volumeEnvelope4

 EQUB $01, $0A, $0D, $0A, $09, $08, $07, $86

.volumeEnvelope5

 EQUB $01, $08, $0B, $09, $07, $05, $83

.volumeEnvelope6

 EQUB $01, $0A, $0D, $0C, $0B, $09, $87

.volumeEnvelope7

 EQUB $01, $06, $08, $07, $05, $03, $81

.volumeEnvelope8

 EQUB $0A, $0D, $0C, $0B, $0A, $09, $08, $07
 EQUB $06, $05, $04, $03, $02, $81

.volumeEnvelope9

 EQUB $02, $0E, $0D, $0C, $0B, $0A, $09, $08
 EQUB $07, $06, $05, $04, $03, $02, $81

.volumeEnvelope10

 EQUB $01, $0E, $0D, $0C, $0B, $0A, $09, $08
 EQUB $07, $06, $05, $04, $03, $02, $81

.volumeEnvelope11

 EQUB $01, $0E, $0C, $09, $07, $05, $04, $03
 EQUB $02, $81

.volumeEnvelope12

 EQUB $01, $0D, $0C, $0A, $07, $06, $05, $04
 EQUB $03, $02, $81

.volumeEnvelope13

 EQUB $01, $0D, $0B, $09, $07, $05, $04, $03
 EQUB $02, $81

.volumeEnvelope14

 EQUB $01, $0D, $07, $01, $80

.volumeEnvelope15

 EQUB $01, $00, $80

.volumeEnvelope16

 EQUB $01, $09, $02, $80

.volumeEnvelope17

 EQUB $01, $0A, $01, $05, $02, $01, $80

.volumeEnvelope18

 EQUB $01, $0D, $01, $07, $02, $01, $80

.volumeEnvelope19

 EQUB $01, $0F, $0D, $0B, $89

; ******************************************************************************
;
;       Name: pitchEnvelope
;       Type: Variable
;   Category: Sound
;    Summary: Pitch envelope data for the game music
;  Deep dive: Music in NES Elite
;
; ******************************************************************************

.pitchEnvelope

.pitchEnvelopeLo

 EQUB LO(pitchEnvelope0)
 EQUB LO(pitchEnvelope1)
 EQUB LO(pitchEnvelope2)
 EQUB LO(pitchEnvelope3)
 EQUB LO(pitchEnvelope4)
 EQUB LO(pitchEnvelope5)
 EQUB LO(pitchEnvelope6)
 EQUB LO(pitchEnvelope7)

.pitchEnvelopeHi

 EQUB HI(pitchEnvelope0)
 EQUB HI(pitchEnvelope1)
 EQUB HI(pitchEnvelope2)
 EQUB HI(pitchEnvelope3)
 EQUB HI(pitchEnvelope4)
 EQUB HI(pitchEnvelope5)
 EQUB HI(pitchEnvelope6)
 EQUB HI(pitchEnvelope7)

.pitchEnvelope0

 EQUB $00, $80

.pitchEnvelope1

 EQUB $00, $01, $02, $01, $00, $FF, $FE, $FF
 EQUB $80

.pitchEnvelope2

 EQUB $00, $02, $00, $FE, $80

.pitchEnvelope3

 EQUB $00, $01, $00, $FF, $80

.pitchEnvelope4

 EQUB $00, $04, $00, $04, $00, $80

.pitchEnvelope5

 EQUB $00, $02, $04, $02, $00, $FE, $FC, $FE
 EQUB $80

.pitchEnvelope6

 EQUB $00, $03, $06, $03, $00, $FD, $FA, $FD
 EQUB $80

.pitchEnvelope7

 EQUB $00, $04, $08, $04, $00, $FC, $F8, $FC
 EQUB $80

; ******************************************************************************
;
;       Name: tuneData
;       Type: Variable
;   Category: Sound
;    Summary: Data for the tunes played in the game
;  Deep dive: Music in NES Elite
;
; ******************************************************************************

.tuneData

.tune0Data

 EQUB 47
 EQUW tune0Data_SQ1
 EQUW tune0Data_SQ2
 EQUW tune0Data_TRI
 EQUW tune0Data_NOISE

.tune1Data

 EQUB 59
 EQUW tune1Data_SQ1
 EQUW tune1Data_SQ2
 EQUW tune1Data_TRI
 EQUW tune1Data_NOISE

.tune2Data

 EQUB 60
 EQUW tune2Data_SQ1
 EQUW tune2Data_SQ2
 EQUW tune2Data_TRI
 EQUW tune2Data_NOISE

.tune3Data

 EQUB 60
 EQUW tune3Data_SQ1
 EQUW tune3Data_SQ2
 EQUW tune3Data_TRI
 EQUW tune3Data_NOISE

.tune4Data

 EQUB 60
 EQUW tune4Data_SQ1
 EQUW tune4Data_SQ2
 EQUW tune4Data_TRI
 EQUW tune4Data_NOISE

.tune1Data_SQ1

 EQUW tune1Data_SQ1_0
 EQUW 0

.tune1Data_TRI

 EQUW tune1Data_TRI_0
 EQUW 0

.tune1Data_SQ2

 EQUW tune1Data_SQ2_0
 EQUW 0

.tune1Data_NOISE

 EQUW tune1Data_NOISE_0
 EQUW 0

.tune1Data_SQ1_0

 EQUB $FA, $B0, $F7, $05, $F6, $0F, $6B, $F8
 EQUB $63, $F6, $02, $0E, $F6, $07, $1E, $1E
 EQUB $F6, $02, $0E, $F6, $07, $1E, $1E, $F6
 EQUB $02, $0E, $F6, $07, $1A, $1A, $F6, $02
 EQUB $0E, $F6, $07, $1A, $1A, $F6, $02, $10
 EQUB $F6, $07, $19, $19, $F6, $02, $10, $F6
 EQUB $07, $19, $19, $F6, $02, $10, $F6, $07
 EQUB $19, $19, $F6, $02, $10, $F6, $07, $15
 EQUB $15, $F6, $02, $09, $F6, $07, $1F, $1F
 EQUB $F6, $02, $09, $F6, $07, $19, $19, $F6
 EQUB $02, $09, $F6, $07, $15, $15, $F6, $02
 EQUB $09, $F6, $07, $15, $13, $F6, $02, $0E
 EQUB $F6, $07, $1E, $1E, $F6, $02, $0E, $F6
 EQUB $07, $1E, $1E, $F6, $02, $0E, $F6, $07
 EQUB $1A, $1A, $F6, $02, $0E, $F6, $07, $1A
 EQUB $1A, $F6, $02, $12, $F6, $07, $1E, $1E
 EQUB $F6, $02, $12, $F6, $07, $1E, $1E, $F6
 EQUB $02, $12, $F6, $07, $1A, $1A, $F6, $02
 EQUB $12, $F6, $07, $15, $15, $F6, $02, $13
 EQUB $F6, $07, $1C, $1C, $F6, $02, $13, $F6
 EQUB $07, $1A, $1A, $F6, $06, $67, $10, $63
 EQUB $10, $10, $13, $61, $17, $F8, $63, $F6
 EQUB $02, $10, $F6, $07, $1C, $1C, $F6, $02
 EQUB $09, $F6, $07, $14, $15, $F6, $02, $0E
 EQUB $F6, $07, $1E, $1E, $F6, $02, $0E, $F6
 EQUB $07, $1E, $1E, $F6, $02, $6B, $10, $13
 EQUB $62, $15, $F8, $61, $15, $63, $15, $62
 EQUB $0E, $60, $F8, $F6, $05, $63, $1E, $F8
 EQUB $F6, $02, $10, $F6, $07, $1A, $1A, $F6
 EQUB $02, $10, $F6, $07, $1A, $19, $F6, $02
 EQUB $10, $F6, $07, $1A, $1A, $F6, $02, $10
 EQUB $F6, $07, $1A, $1A, $F6, $02, $09, $F6
 EQUB $07, $1C, $1C, $F6, $02, $09, $F6, $07
 EQUB $19, $19, $F6, $02, $09, $F6, $07, $15
 EQUB $15, $F6, $02, $09, $F6, $07, $19, $19
 EQUB $F6, $02, $10, $F6, $07, $1A, $1A, $F6
 EQUB $02, $10, $F6, $07, $1A, $19, $F6, $02
 EQUB $10, $F6, $07, $1A, $1A, $F6, $02, $10
 EQUB $F6, $07, $17, $17, $F6, $06, $12, $F9
 EQUB $15, $65, $17, $F8, $63, $10, $14, $10
 EQUB $65, $09, $F8, $6B, $1C, $15, $1C, $63
 EQUB $15, $F8, $F6, $04, $15, $F6, $02, $10
 EQUB $F6, $07, $19, $19, $F6, $02, $10, $F6
 EQUB $07, $19, $19, $F6, $02, $10, $F6, $07
 EQUB $19, $19, $F6, $02, $10, $F6, $07, $19
 EQUB $19, $F6, $02, $0E, $F6, $07, $1E, $1E
 EQUB $F6, $02, $0E, $F6, $07, $1E, $1E, $F6
 EQUB $02, $0E, $F6, $07, $1E, $1E, $F6, $02
 EQUB $0E, $F6, $07, $1E, $21, $F6, $02, $10
 EQUB $F6, $07, $19, $19, $F6, $02, $10, $F6
 EQUB $07, $19, $19, $F6, $02, $10, $F6, $07
 EQUB $19, $19, $F6, $02, $10, $F6, $07, $19
 EQUB $19, $F6, $04, $63, $1A, $19, $18, $F6
 EQUB $06, $67, $1B, $F6, $04, $61, $1C, $F8
 EQUB $F6, $02, $63, $09, $15, $09, $0E, $F8
 EQUB $F6, $04, $61, $0E, $F8, $63, $F6, $02
 EQUB $0A, $F6, $07, $1D, $1D, $F6, $02, $0A
 EQUB $F6, $07, $1D, $1D, $F6, $02, $0F, $F6
 EQUB $07, $18, $18, $F6, $02, $0F, $F6, $07
 EQUB $18, $18, $F6, $02, $15, $F6, $07, $1D
 EQUB $1D, $F6, $02, $11, $F6, $07, $1D, $1D
 EQUB $F6, $02, $16, $F6, $07, $1D, $1D, $F6
 EQUB $02, $11, $F6, $07, $1D, $1D, $F6, $02
 EQUB $0A, $F6, $07, $1D, $1D, $F6, $02, $0A
 EQUB $F6, $07, $1D, $1D, $F6, $02, $0F, $F6
 EQUB $07, $18, $18, $F6, $02, $10, $F6, $07
 EQUB $19, $19, $F6, $02, $0E, $F6, $07, $1A
 EQUB $1A, $F6, $02, $0E, $F6, $07, $16, $16
 EQUB $F6, $04, $15, $15, $15, $15, $15, $15
 EQUB $F6, $02, $10, $F6, $07, $19, $19, $F6
 EQUB $02, $09, $F6, $07, $19, $19, $F6, $02
 EQUB $15, $F6, $07, $19, $19, $F6, $02, $09
 EQUB $F6, $07, $19, $19, $F6, $02, $0E, $F6
 EQUB $07, $1E, $1E, $F6, $02, $0E, $F6, $07
 EQUB $1E, $1E, $F6, $02, $0E, $F6, $07, $1E
 EQUB $1E, $F6, $02, $0E, $F6, $07, $1E, $21
 EQUB $F6, $02, $10, $F6, $07, $19, $19, $F6
 EQUB $02, $09, $F6, $07, $19, $19, $F6, $02
 EQUB $15, $F6, $07, $19, $19, $F6, $02, $09
 EQUB $F6, $07, $19, $19, $F6, $04, $63, $1A
 EQUB $19, $18, $F6, $06, $67, $1B, $F6, $04
 EQUB $61, $1C, $F8, $F6, $02, $63, $09, $15
 EQUB $09, $0E, $F8, $F6, $04, $61, $1A, $F8
 EQUB $FF

.tune1Data_TRI_0

 EQUB $FC, $0C, $6B, $F8, $63, $F6, $08, $F7
 EQUB $03, $0E, $1A, $1A, $0E, $1A, $1A, $0E
 EQUB $15, $15, $0E, $15, $15, $10, $15, $15
 EQUB $10, $15, $15, $10, $15, $15, $10, $10
 EQUB $10, $09, $19, $19, $09, $13, $13, $09
 EQUB $13, $13, $09, $15, $0D, $0E, $1A, $1A
 EQUB $0E, $1A, $1A, $0E, $15, $15, $0E, $15
 EQUB $1A, $12, $1A, $1A, $12, $1A, $1A, $12
 EQUB $15, $15, $12, $0E, $0E, $13, $1A, $1A
 EQUB $13, $17, $17, $67, $0E, $63, $10, $10
 EQUB $13, $61, $17, $F8, $63, $10, $19, $19
 EQUB $09, $19, $19, $0E, $1A, $1A, $0E, $1A
 EQUB $1A, $6B, $0E, $10, $62, $12, $F8, $61
 EQUB $12, $63, $12, $62, $15, $60, $F8, $63
 EQUB $F8, $F8, $10, $14, $14, $10, $14, $13
 EQUB $10, $1C, $1C, $10, $1C, $1C, $6B, $F6
 EQUB $34, $10, $12, $13, $12, $F6, $08, $63
 EQUB $10, $1C, $1C, $10, $1C, $13, $10, $1C
 EQUB $1C, $10, $1A, $1A, $19, $F9, $15, $65
 EQUB $1A, $F8, $61, $1A, $1A, $1A, $F8, $1A
 EQUB $F8, $65, $10, $F8, $6B, $F6, $34, $1F
 EQUB $1C, $1F, $F6, $08, $63, $1C, $F8, $21
 EQUB $F7, $00, $19, $61, $2A, $2B, $63, $2D
 EQUB $19, $61, $2A, $2B, $63, $2D, $1E, $61
 EQUB $2A, $2B, $63, $2D, $2D, $1C, $15, $1E
 EQUB $61, $2A, $2B, $63, $2D, $1E, $61, $2A
 EQUB $2B, $63, $2D, $1C, $61, $2A, $2B, $63
 EQUB $2D, $2D, $1A, $15, $1F, $61, $2A, $2B
 EQUB $63, $2D, $1F, $61, $2A, $2B, $63, $2D
 EQUB $1E, $61, $2A, $2B, $63, $2D, $2D, $1C
 EQUB $13, $F7, $03, $63, $1A, $1C, $1E, $67
 EQUB $21, $63, $1F, $61, $1E, $1E, $1E, $F8
 EQUB $1C, $F8, $63, $1A, $F8, $F8, $63, $0A
 EQUB $1A, $1A, $0A, $1A, $1A, $0F, $13, $13
 EQUB $0F, $13, $13, $15, $1B, $1B, $11, $15
 EQUB $15, $16, $1A, $1A, $11, $1A, $1A, $0A
 EQUB $1A, $1A, $0A, $16, $16, $0F, $1B, $1B
 EQUB $10, $13, $13, $0E, $15, $12, $0E, $13
 EQUB $13, $15, $12, $F8, $F8, $F8, $F8, $F7
 EQUB $00, $1C, $61, $2A, $2B, $63, $2D, $15
 EQUB $61, $2A, $2B, $63, $2D, $21, $61, $2A
 EQUB $2B, $63, $2D, $15, $1C, $15, $1A, $61
 EQUB $2A, $2B, $63, $2D, $1A, $61, $2A, $2B
 EQUB $63, $2D, $1A, $61, $2A, $2B, $63, $2D
 EQUB $1A, $1A, $15, $1C, $61, $2A, $2B, $63
 EQUB $2D, $15, $61, $2A, $2B, $63, $2D, $21
 EQUB $61, $2A, $2B, $63, $2D, $15, $1C, $13
 EQUB $F7, $03, $63, $1A, $1C, $1E, $67, $21
 EQUB $61, $1F, $F8, $61, $1E, $1E, $1E, $F8
 EQUB $1C, $F8, $63, $1A, $F8, $F8, $FF

.tune1Data_SQ2_0

 EQUB $FA, $B0, $F7, $01, $F6, $04, $63, $1A
 EQUB $1E, $62, $21, $60, $F8, $67, $21, $FA
 EQUB $F0, $62, $21, $60, $F8, $67, $21, $62
 EQUB $1E, $60, $F8, $67, $1E, $FA, $B0, $62
 EQUB $1A, $60, $F8, $63, $1A, $1E, $62, $21
 EQUB $60, $F8, $67, $21, $FA, $F0, $62, $21
 EQUB $60, $F8, $67, $21, $62, $1F, $60, $F8
 EQUB $67, $1F, $FA, $B0, $62, $19, $60, $F8
 EQUB $63, $19, $1C, $62, $23, $60, $F8, $67
 EQUB $23, $FA, $F0, $62, $23, $60, $F8, $67
 EQUB $23, $62, $1F, $60, $F8, $67, $1F, $FA
 EQUB $B0, $62, $19, $60, $F8, $63, $19, $1C
 EQUB $62, $23, $60, $F8, $67, $23, $FA, $F0
 EQUB $62, $23, $60, $F8, $67, $23, $62, $1E
 EQUB $60, $F8, $67, $1E, $FA, $B0, $62, $1A
 EQUB $60, $F8, $63, $1A, $1E, $21, $67, $26
 EQUB $FA, $F0, $62, $26, $60, $F8, $67, $26
 EQUB $62, $21, $60, $F8, $67, $21, $FA, $B0
 EQUB $62, $1A, $60, $F8, $63, $1A, $1E, $21
 EQUB $67, $26, $FA, $F0, $62, $26, $60, $F8
 EQUB $67, $26, $62, $23, $60, $F8, $65, $23
 EQUB $61, $F9, $FA, $B0, $61, $1C, $F8, $63
 EQUB $1C, $1F, $61, $23, $F8, $6B, $23, $63
 EQUB $F9, $20, $21, $6B, $2A, $63, $F9, $26
 EQUB $1E, $F6, $06, $67, $1E, $61, $1C, $F8
 EQUB $67, $23, $61, $21, $F8, $62, $1A, $F8
 EQUB $61, $1A, $63, $1A, $62, $1A, $60, $F8
 EQUB $FA, $F0, $F6, $04, $63, $26, $62, $25
 EQUB $60, $F8, $F6, $06, $63, $25, $62, $23
 EQUB $60, $F8, $63, $23, $F8, $23, $62, $22
 EQUB $60, $F8, $63, $22, $62, $23, $60, $F8
 EQUB $63, $23, $F8, $1C, $1C, $1E, $F9, $1C
 EQUB $F8, $1C, $1C, $23, $F9, $21, $F8, $26
 EQUB $62, $25, $60, $F8, $63, $25, $62, $23
 EQUB $60, $F8, $63, $23, $F8, $23, $25, $28
 EQUB $26, $26, $F8, $20, $23, $23, $F9, $21
 EQUB $65, $20, $61, $1E, $1A, $17, $61, $1E
 EQUB $1E, $63, $1E, $1C, $FA, $B0, $F6, $06
 EQUB $65, $15, $F8, $F6, $07, $F7, $03, $FA
 EQUB $30, $60, $2F, $2D, $2F, $2D, $2F, $2D
 EQUB $2F, $2D, $2F, $2D, $2F, $2D, $2F, $2D
 EQUB $2F, $2D, $2F, $2D, $2F, $2D, $2F, $2D
 EQUB $2F, $2D, $2F, $2D, $2F, $2D, $2F, $2D
 EQUB $2F, $2D, $2F, $2D, $2F, $2D, $F6, $06
 EQUB $63, $2D, $F8, $F7, $01, $FA, $B0, $62
 EQUB $21, $60, $F8, $F6, $04, $67, $1F, $61
 EQUB $21, $F8, $67, $1F, $61, $21, $F8, $6B
 EQUB $2A, $63, $F8, $28, $21, $67, $1E, $61
 EQUB $21, $F8, $67, $1E, $61, $21, $F8, $6B
 EQUB $28, $63, $F8, $26, $21, $67, $1F, $61
 EQUB $21, $F8, $67, $1F, $61, $21, $F8, $6B
 EQUB $2A, $63, $F8, $28, $21, $26, $28, $2A
 EQUB $F6, $06, $67, $2D, $F6, $04, $61, $2B
 EQUB $F8, $61, $2A, $2A, $63, $2A, $28, $F6
 EQUB $06, $65, $26, $61, $F8, $F6, $04, $FA
 EQUB $F0, $61, $26, $F8, $6F, $26, $63, $27
 EQUB $26, $24, $22, $21, $69, $1F, $61, $F8
 EQUB $65, $24, $61, $F8, $65, $24, $61, $1D
 EQUB $65, $1F, $61, $1D, $F6, $06, $FA, $30
 EQUB $63, $1D, $1A, $1D, $1B, $1A, $18, $F6
 EQUB $04, $FA, $F0, $65, $26, $61, $F8, $67
 EQUB $26, $63, $27, $26, $24, $22, $21, $69
 EQUB $1F, $61, $F8, $65, $1E, $61, $F8, $67
 EQUB $1E, $65, $1F, $61, $22, $6F, $21, $63
 EQUB $F8, $FA, $B0, $F6, $06, $61, $21, $F8
 EQUB $67, $1F, $61, $21, $F8, $67, $1F, $61
 EQUB $21, $F8, $6F, $2A, $61, $28, $F8, $21
 EQUB $F8, $F6, $04, $67, $1E, $61, $21, $F8
 EQUB $67, $1E, $61, $21, $F8, $6F, $28, $61
 EQUB $26, $F8, $21, $F8, $F6, $06, $67, $1F
 EQUB $61, $21, $F8, $67, $1F, $61, $21, $F8
 EQUB $6B, $2A, $F4, $3A, $63, $F9, $61, $28
 EQUB $F8, $21, $F8, $F4, $39, $61, $26, $F8
 EQUB $28, $F8, $2A, $F8, $F4, $38, $67, $2D
 EQUB $61, $2B, $F8, $F4, $37, $2A, $2A, $2A
 EQUB $F4, $33, $F8, $28, $F8, $26, $69, $F8
 EQUB $F4, $3B, $FF

.tune0Data_SQ1

 EQUW tune0Data_SQ1_0
 EQUW tune0Data_SQ1_0
 EQUW tune0Data_SQ1_1
 EQUW tune0Data_SQ1_2
 EQUW tune0Data_SQ1_1
 EQUW tune0Data_SQ1_2
 EQUW tune0Data_SQ1_1
 EQUW tune0Data_SQ1_3
 EQUW tune0Data_SQ1_1
 EQUW tune0Data_SQ1_4
 EQUW 0

.tune0Data_TRI

 EQUW tune0Data_TRI_0
 EQUW tune0Data_TRI_0
 EQUW tune0Data_TRI_1
 EQUW tune0Data_TRI_2
 EQUW tune0Data_TRI_1
 EQUW tune0Data_TRI_2
 EQUW tune0Data_TRI_1
 EQUW tune0Data_TRI_1
 EQUW 0

.tune0Data_SQ2

 EQUW tune0Data_SQ2_0
 EQUW tune0Data_SQ2_0
 EQUW tune0Data_SQ2_1
 EQUW tune0Data_SQ2_2
 EQUW tune0Data_SQ2_1
 EQUW tune0Data_SQ2_3
 EQUW tune0Data_SQ2_1
 EQUW tune0Data_SQ2_1
 EQUW 0

.tune0Data_NOISE

 EQUW tune0Data_NOISE_0
 EQUW 0

.tune0Data_SQ1_0

 EQUB $FA, $70, $F7, $05, $F6, $09, $65, $0C
 EQUB $0C, $0C, $63, $07, $61, $07, $63, $07
 EQUB $07, $FF

.tune0Data_SQ1_1

 EQUB $FA, $70, $65, $0C, $0C, $63, $0C, $61
 EQUB $F9, $63, $07, $61, $07, $63, $07, $07
 EQUB $65, $0C, $0C, $63, $0C, $65, $07, $07
 EQUB $61, $07, $07, $65, $0C, $0C, $63, $0C
 EQUB $61, $07, $63, $05, $65, $0C, $63, $04
 EQUB $65, $02, $04, $63, $05, $07, $07, $07
 EQUB $07, $65, $00, $0C, $63, $0C, $65, $07
 EQUB $07, $63, $07, $65, $0C, $0C, $63, $0C
 EQUB $65, $0E, $0E, $61, $0E, $0E, $63, $0E
 EQUB $10, $11, $12, $61, $07, $60, $07, $07
 EQUB $61, $07, $65, $07, $63, $07, $65, $0C
 EQUB $65, $13, $63, $13, $63, $0C, $61, $13
 EQUB $0C, $F8, $0C, $0A, $09, $FF

.tune0Data_SQ1_2

 EQUB $FA, $B0, $65, $07, $F7, $07, $09, $63
 EQUB $0A, $61, $F9, $65, $F7, $05, $13, $63
 EQUB $F7, $07, $09, $0A, $65, $09, $0B, $63
 EQUB $0C, $65, $09, $09, $63, $09, $65, $F7
 EQUB $05, $07, $F7, $07, $09, $63, $0A, $61
 EQUB $F9, $65, $F7, $05, $07, $F7, $07, $63
 EQUB $09, $0A, $65, $09, $0B, $63, $0C, $65
 EQUB $09, $0B, $63, $0D, $65, $09, $0B, $63
 EQUB $0C, $61, $F9, $65, $F7, $06, $0E, $63
 EQUB $10, $12, $65, $F7, $07, $0A, $0C, $63
 EQUB $0D, $61, $F9, $65, $F7, $06, $0F, $63
 EQUB $11, $13, $65, $F7, $07, $0B, $0D, $63
 EQUB $0E, $61, $F9, $65, $F7, $06, $10, $63
 EQUB $12, $14, $65, $14, $14, $63, $14, $61
 EQUB $F9, $13, $13, $13, $13, $13, $13, $13
 EQUB $FF

.tune0Data_TRI_0

 EQUB $61, $F6, $05, $F7, $03, $28, $28, $28
 EQUB $28, $28, $28, $28, $28, $28, $29, $29
 EQUB $29, $29, $29, $29, $29, $FF

.tune0Data_TRI_1

 EQUB $28, $28, $28, $28, $28, $28, $28, $28
 EQUB $28, $29, $29, $29, $29, $29, $29, $29
 EQUB $28, $28, $28, $28, $28, $28, $28, $28
 EQUB $F8, $29, $29, $29, $29, $29, $29, $29
 EQUB $28, $28, $28, $28, $28, $28, $28, $28
 EQUB $2B, $63, $F6, $10, $29, $65, $28, $63
 EQUB $28, $F6, $05, $61, $26, $26, $26, $26
 EQUB $26, $26, $26, $26, $29, $F6, $10, $63
 EQUB $28, $24, $21, $61, $1F, $F6, $05, $28
 EQUB $28, $28, $28, $28, $28, $28, $28, $28
 EQUB $29, $29, $29, $29, $29, $29, $29, $28
 EQUB $28, $28, $28, $28, $28, $28, $28, $26
 EQUB $26, $26, $26, $26, $26, $26, $26, $29
 EQUB $29, $29, $29, $29, $29, $29, $29, $2B
 EQUB $60, $F6, $03, $2B, $2B, $67, $F6, $20
 EQUB $2B, $F6, $10, $63, $2B, $F6, $05, $61
 EQUB $28, $28, $28, $29, $29, $29, $29, $29
 EQUB $28, $28, $29, $28, $F8, $24, $22, $21
 EQUB $FF

.tune0Data_TRI_2

 EQUB $61, $F8, $29, $29, $F8, $29, $29, $F8
 EQUB $29, $29, $F8, $29, $29, $F8, $29, $F8
 EQUB $29, $F8, $28, $28, $F8, $28, $28, $F8
 EQUB $28, $28, $F8, $28, $28, $F8, $28, $F8
 EQUB $28, $F8, $29, $29, $F8, $29, $29, $F8
 EQUB $29, $29, $F8, $29, $29, $F8, $29, $F8
 EQUB $29, $F8, $28, $28, $F8, $28, $28, $F8
 EQUB $28, $28, $F8, $28, $28, $F8, $28, $F8
 EQUB $28, $F8, $26, $26, $F8, $26, $26, $F8
 EQUB $26, $26, $F8, $26, $26, $F8, $26, $F8
 EQUB $26, $F8, $27, $27, $F8, $27, $27, $F8
 EQUB $27, $27, $F8, $27, $27, $F8, $27, $F8
 EQUB $27, $F8, $28, $28, $F8, $28, $28, $F8
 EQUB $28, $28, $F8, $28, $28, $F8, $28, $F8
 EQUB $28, $29, $29, $29, $29, $29, $29, $29
 EQUB $29, $2B, $2B, $2B, $2B, $2B, $2B, $2B
 EQUB $2B, $FC, $00, $FF

.tune0Data_SQ2_0

 EQUB $FA, $70, $F7, $01, $F6, $07, $61, $18
 EQUB $18, $18, $18, $18, $18, $18, $18, $18
 EQUB $18, $18, $18, $18, $18, $18, $18, $FF

.tune0Data_SQ2_1

 EQUB $FA, $B0, $F6, $01, $F7, $01, $61, $F8
 EQUB $60, $1F, $1F, $61, $24, $28, $67, $2B
 EQUB $61, $F9, $60, $26, $26, $61, $29, $2B
 EQUB $2D, $2B, $28, $26, $28, $24, $1F, $69
 EQUB $1F, $61, $F9, $6D, $F8, $61, $F8, $60
 EQUB $1F, $1F, $61, $24, $28, $65, $2B, $60
 EQUB $2B, $2D, $61, $2E, $63, $2D, $2B, $61
 EQUB $28, $2B, $2D, $6F, $26, $6D, $F9, $61
 EQUB $F8, $F8, $60, $1F, $1F, $61, $24, $28
 EQUB $67, $2B, $61, $F9, $60, $26, $26, $61
 EQUB $29, $2B, $2D, $2B, $28, $26, $28, $24
 EQUB $1F, $65, $2B, $63, $2D, $6B, $26, $61
 EQUB $F8, $60, $26, $28, $61, $29, $63, $28
 EQUB $61, $24, $29, $63, $28, $61, $24, $61
 EQUB $2B, $60, $2B, $2B, $65, $2B, $61, $F8
 EQUB $63, $2B, $6F, $30, $67, $F9, $F8, $FA
 EQUB $70, $FF

.tune0Data_SQ2_3

 EQUB $FA, $30

.tune0Data_SQ2_2

 EQUB $61, $F8, $F6, $00, $F7, $05, $60, $0C
 EQUB $0C, $61, $0E, $11, $67, $16, $6A, $F9
 EQUB $60, $F8, $63, $16, $64, $18, $60, $F8
 EQUB $61, $15, $6B, $18, $60, $F6, $05, $F7
 EQUB $03, $39, $37, $34, $30, $2D, $2B, $28
 EQUB $24, $21, $1F, $1C, $18, $61, $F8, $F6
 EQUB $00, $F7, $05, $60, $0A, $0A, $61, $0E
 EQUB $11, $67, $16, $66, $F9, $60, $F8, $63
 EQUB $16, $18, $6F, $19, $6A, $F9, $60, $F8
 EQUB $63, $19, $67, $1A, $15, $66, $F9, $60
 EQUB $F8, $63, $15, $1A, $67, $1B, $16, $66
 EQUB $F9, $60, $F8, $63, $16, $1B, $67, $1C
 EQUB $17, $66, $F9, $60, $F8, $62, $17, $1C
 EQUB $61, $17, $6A, $1D, $60, $F8, $61, $1C
 EQUB $1D, $66, $1F, $60, $F8, $65, $1F, $60
 EQUB $1C, $1A, $FF

.tune0Data_NOISE_0

 EQUB $F6, $11, $65, $04, $04, $04, $63, $04
 EQUB $61, $04, $63, $04, $04, $65, $04, $04
 EQUB $04, $63, $04, $61, $04, $63, $04, $61
 EQUB $04, $04, $FF

.tune4Data_SQ1

 EQUW tune4Data_SQ1_0
 EQUW tune4Data_SQ1_0
 EQUW tune4Data_SQ1_1
 EQUW tune4Data_SQ1_2

.tune2Data_SQ1

 EQUW tune2Data_SQ1_0
 EQUW tune2Data_SQ1_1
 EQUW tune2Data_SQ1_2
 EQUW tune2Data_SQ1_2
 EQUW tune2Data_SQ1_2
 EQUW tune2Data_SQ1_2
 EQUW tune2Data_SQ1_2
 EQUW tune2Data_SQ1_3
 EQUW tune2Data_SQ1_3
 EQUW tune2Data_SQ1_2
 EQUW tune2Data_SQ1_2
 EQUW tune2Data_SQ1_2
 EQUW tune2Data_SQ1_2
 EQUW tune2Data_SQ1_2
 EQUW tune2Data_SQ1_2
 EQUW tune2Data_SQ1_3
 EQUW tune2Data_SQ1_3
 EQUW tune2Data_SQ1_2
 EQUW tune2Data_SQ1_2
 EQUW tune2Data_SQ1_3
 EQUW tune2Data_SQ1_3
 EQUW tune2Data_SQ1_2
 EQUW tune2Data_SQ1_2
 EQUW tune2Data_SQ1_4
 EQUW tune2Data_SQ1_3
 EQUW tune2Data_SQ1_2
 EQUW tune2Data_SQ1_2
 EQUW tune2Data_SQ1_3
 EQUW tune2Data_SQ1_3
 EQUW tune2Data_SQ1_2
 EQUW tune2Data_SQ1_2
 EQUW tune2Data_SQ1_3
 EQUW tune2Data_SQ1_3
 EQUW tune2Data_SQ1_2
 EQUW tune2Data_SQ1_2
 EQUW tune2Data_SQ1_3
 EQUW tune2Data_SQ1_3
 EQUW tune2Data_SQ1_2
 EQUW tune2Data_SQ1_2
 EQUW tune2Data_SQ1_4
 EQUW tune2Data_SQ1_3
 EQUW tune2Data_SQ1_2
 EQUW tune2Data_SQ1_2
 EQUW tune2Data_SQ1_3
 EQUW tune2Data_SQ1_3
 EQUW tune2Data_SQ1_2
 EQUW tune2Data_SQ1_2
 EQUW tune2Data_SQ1_3
 EQUW tune2Data_SQ1_3
 EQUW tune2Data_SQ1_1
 EQUW tune2Data_SQ1_2
 EQUW tune2Data_SQ1_2
 EQUW tune2Data_SQ1_2
 EQUW tune2Data_SQ1_2
 EQUW tune2Data_SQ1_2
 EQUW tune2Data_SQ1_3
 EQUW tune2Data_SQ1_3
 EQUW tune2Data_SQ1_5
 EQUW tune2Data_SQ1_2
 EQUW tune2Data_SQ1_2
 EQUW tune2Data_SQ1_2
 EQUW tune2Data_SQ1_2
 EQUW tune2Data_SQ1_2
 EQUW tune2Data_SQ1_2
 EQUW tune2Data_SQ1_3
 EQUW tune2Data_SQ1_3
 EQUW tune2Data_SQ1_2
 EQUW tune2Data_SQ1_2
 EQUW tune2Data_SQ1_3
 EQUW tune2Data_SQ1_3
 EQUW tune2Data_SQ1_2
 EQUW tune2Data_SQ1_2
 EQUW tune2Data_SQ1_4
 EQUW tune2Data_SQ1_3
 EQUW tune2Data_SQ1_2
 EQUW tune2Data_SQ1_2
 EQUW tune2Data_SQ1_3
 EQUW tune2Data_SQ1_3
 EQUW tune2Data_SQ1_2
 EQUW tune2Data_SQ1_2
 EQUW tune2Data_SQ1_3
 EQUW tune2Data_SQ1_3
 EQUW tune2Data_SQ1_2
 EQUW tune2Data_SQ1_2
 EQUW tune2Data_SQ1_3
 EQUW tune2Data_SQ1_3
 EQUW tune2Data_SQ1_2
 EQUW tune2Data_SQ1_2
 EQUW tune2Data_SQ1_4
 EQUW tune2Data_SQ1_3
 EQUW tune2Data_SQ1_2
 EQUW tune2Data_SQ1_2
 EQUW tune2Data_SQ1_3
 EQUW tune2Data_SQ1_3
 EQUW tune2Data_SQ1_2
 EQUW tune2Data_SQ1_2
 EQUW tune2Data_SQ1_3
 EQUW tune2Data_SQ1_3
 EQUW tune2Data_SQ1_0
 EQUW 0

.tune4Data_TRI

 EQUW tune4Data_TRI_0
 EQUW tune4Data_TRI_0
 EQUW tune4Data_TRI_1
 EQUW tune4Data_TRI_2

.tune2Data_TRI

 EQUW tune2Data_TRI_0
 EQUW tune2Data_TRI_1
 EQUW tune2Data_TRI_1
 EQUW 0

.tune4Data_SQ2

 EQUW tune4Data_SQ2_0
 EQUW tune4Data_SQ2_0
 EQUW tune4Data_SQ2_1
 EQUW tune4Data_SQ2_2

.tune2Data_SQ2

 EQUW tune2Data_SQ2_0
 EQUW tune2Data_SQ2_1
 EQUW tune2Data_SQ2_2
 EQUW 0

.tune4Data_NOISE

 EQUW tune4Data_NOISE_0
 EQUW tune4Data_NOISE_1
 EQUW tune4Data_NOISE_1
 EQUW tune4Data_NOISE_1
 EQUW tune4Data_NOISE_1
 EQUW tune4Data_NOISE_1
 EQUW tune4Data_NOISE_1
 EQUW tune4Data_NOISE_0
 EQUW tune4Data_NOISE_1
 EQUW tune4Data_NOISE_1
 EQUW tune4Data_NOISE_1
 EQUW tune4Data_NOISE_1
 EQUW tune4Data_NOISE_1
 EQUW tune4Data_NOISE_1
 EQUW tune4Data_NOISE_0
 EQUW tune4Data_NOISE_1
 EQUW tune4Data_NOISE_1
 EQUW tune4Data_NOISE_1
 EQUW tune4Data_NOISE_1
 EQUW tune4Data_NOISE_1
 EQUW tune4Data_NOISE_1
 EQUW tune4Data_NOISE_0
 EQUW tune4Data_NOISE_1
 EQUW tune4Data_NOISE_1
 EQUW tune4Data_NOISE_1
 EQUW tune4Data_NOISE_1
 EQUW tune4Data_NOISE_1
 EQUW tune4Data_NOISE_1
 EQUW tune4Data_NOISE_2
 EQUW tune4Data_NOISE_3

.tune2Data_NOISE

 EQUW tune2Data_NOISE_0
 EQUW 0

.tune2Data_SQ1_1

 EQUB $FA, $B0, $F7, $05, $F6, $0B, $61

.tune2Data_SQ1_2

 EQUB $0C, $0C, $0C, $0C, $0C, $0C, $0C, $07
 EQUB $FF

.tune2Data_SQ1_4

 EQUB $05, $05, $05, $05, $05, $05, $05, $07
 EQUB $FF

.tune2Data_SQ1_3

 EQUB $07, $07, $07, $07, $07, $07, $07, $13
 EQUB $FF

.tune2Data_TRI_0

 EQUB $F6, $FF, $F7, $01, $7F, $24, $22, $24
 EQUB $6F, $22, $1F, $7F, $24, $22, $24, $1F
 EQUB $FF

.tune2Data_TRI_1

 EQUB $77, $1C, $67, $1F, $77, $22, $67, $1D
 EQUB $6F, $1C, $24, $21, $23, $7F, $1C, $6F
 EQUB $1A, $1D, $7F, $1C, $6F, $1A, $26, $FF

.tune2Data_SQ2_0

 EQUB $FA, $B0, $F7, $05, $F6, $0C, $FC, $F4
 EQUB $63, $1C, $1C, $1C, $61, $1C, $13, $63
 EQUB $1C, $1C, $1C, $61, $1C, $1F, $63, $1B
 EQUB $1B, $1B, $61, $1B, $13, $63, $1B, $1B
 EQUB $1B, $61, $1B, $1F, $63, $1C, $1C, $1C
 EQUB $61, $1C, $13, $63, $1C, $1C, $1C, $61
 EQUB $1C, $1F, $63, $16, $16, $16, $61, $16
 EQUB $15, $63, $16, $16, $16, $61, $16, $13
 EQUB $63, $FC, $00, $F7, $01, $1C, $1C, $1C
 EQUB $61, $1C, $13, $63, $1C, $1C, $1C, $61
 EQUB $1C, $1F, $63, $1B, $1B, $1B, $61, $1B
 EQUB $13, $63, $1B, $1B, $1B, $61, $1B, $1F
 EQUB $63, $1C, $1C, $1C, $61, $1C, $13, $63
 EQUB $1C, $1C, $1C, $61, $1C, $1F, $63, $16
 EQUB $16, $16, $61, $16, $15, $63, $16, $16
 EQUB $16, $61, $16, $13, $FF

.tune2Data_SQ2_1

 EQUB $FA, $B0, $F7, $05, $FC, $F4

.tune2Data_SQ2_2

 EQUB $F6, $0A, $63, $24, $24, $61, $22, $65
 EQUB $21, $63, $24, $24, $61, $22, $63, $1C
 EQUB $22, $22, $21, $22, $24, $22, $21, $63
 EQUB $22, $61, $16, $63, $24, $24, $61, $22
 EQUB $65, $21, $63, $24, $24, $61, $26, $63
 EQUB $27, $F7, $01, $29, $29, $27, $29, $F6
 EQUB $08, $71, $2B, $77, $2B, $67, $2D, $77
 EQUB $2E, $67, $2D, $77, $28, $67, $2B, $6F
 EQUB $2E, $F6, $08, $22, $FA, $F0, $FF

.tune2Data_NOISE_0

 EQUB $61, $F6, $10, $08, $02, $F6, $0E, $07
 EQUB $F6, $10, $02, $FF

.tune3Data_SQ1

 EQUW tune3Data_SQ1_0
 EQUW tune3Data_SQ1_0
 EQUW tune3Data_SQ1_1
 EQUW 0

.tune3Data_TRI

 EQUW tune3Data_TRI_0
 EQUW tune3Data_TRI_0
 EQUW tune3Data_TRI_1
 EQUW 0

.tune3Data_SQ2

 EQUW tune3Data_SQ2_0
 EQUW tune3Data_SQ2_0
 EQUW tune3Data_SQ2_1
 EQUW 0

.tune3Data_NOISE

 EQUW tune3Data_NOISE_0
 EQUW tune3Data_NOISE_1
 EQUW tune3Data_NOISE_1
 EQUW tune3Data_NOISE_1
 EQUW tune3Data_NOISE_1
 EQUW tune3Data_NOISE_1
 EQUW tune3Data_NOISE_1
 EQUW tune3Data_NOISE_0
 EQUW tune3Data_NOISE_1
 EQUW tune3Data_NOISE_1
 EQUW tune3Data_NOISE_1
 EQUW tune3Data_NOISE_1
 EQUW tune3Data_NOISE_1
 EQUW tune3Data_NOISE_1
 EQUW tune3Data_NOISE_0
 EQUW tune3Data_NOISE_1
 EQUW tune3Data_NOISE_1
 EQUW tune3Data_NOISE_1
 EQUW tune3Data_NOISE_1
 EQUW tune3Data_NOISE_1
 EQUW tune3Data_NOISE_1
 EQUW tune3Data_NOISE_0
 EQUW tune3Data_NOISE_1
 EQUW tune3Data_NOISE_1
 EQUW tune3Data_NOISE_1
 EQUW tune3Data_NOISE_1
 EQUW tune3Data_NOISE_1
 EQUW tune3Data_NOISE_1
 EQUW tune3Data_NOISE_2
 EQUW 0

.tune3Data_SQ1_0
.tune4Data_SQ1_0

 EQUB $FA, $B0, $F7, $05, $F6, $0F, $63, $F8
 EQUB $F6, $08, $67, $0D, $F6, $02, $63, $0D
 EQUB $65, $11, $61, $11, $67, $11, $65, $0F
 EQUB $61, $0F, $67, $0F, $65, $11, $61, $11
 EQUB $63, $11, $61, $11, $11, $F6, $0D, $63
 EQUB $0D, $F6, $02, $67, $0D, $63, $0D, $65
 EQUB $11, $61, $11, $67, $11, $65, $0F, $61
 EQUB $0F, $67, $0F, $63, $11, $13, $14, $16
 EQUB $FF

.tune3Data_SQ1_1
.tune4Data_SQ1_1

 EQUB $65, $0C, $69, $0C, $65, $0C, $69, $0C
 EQUB $65, $0C, $69, $0C, $63, $0C, $0C, $0C
 EQUB $0C, $6F, $0C, $FF

.tune3Data_TRI_0
.tune4Data_TRI_0

 EQUB $F7, $05, $FC, $0C, $F6, $00, $63, $F8
 EQUB $F6, $28, $6A, $1B, $60, $F8, $F6, $08
 EQUB $61, $1B, $F6, $10, $63, $18, $F6, $48
 EQUB $68, $18, $60, $F8, $F6, $10, $63, $1B
 EQUB $1B, $F6, $08, $61, $1B, $F6, $10, $63
 EQUB $1B, $61, $1B, $F9, $F6, $08, $61, $1D
 EQUB $F6, $60, $6B, $1D, $63, $F8, $F6, $28
 EQUB $6A, $1B, $60, $F8, $F6, $08, $61, $1B
 EQUB $F6, $10, $63, $18, $F6, $48, $68, $18
 EQUB $60, $F8, $F6, $10, $63, $1B, $1B, $F6
 EQUB $08, $61, $1B, $F6, $10, $63, $1B, $F6
 EQUB $80, $61, $1D, $6F, $F9, $FF

.tune3Data_TRI_1
.tune4Data_TRI_1

 EQUB $6F, $F6, $80, $13, $16, $13, $10, $63
 EQUB $F9, $6B, $F8, $FC, $00, $FF

.tune3Data_SQ2_0
.tune4Data_SQ2_0

 EQUB $FA, $B0, $F7, $05, $F6, $0F, $63, $F8
 EQUB $F6, $13, $6A, $1D, $60, $F8, $61, $1D
 EQUB $63, $1D, $68, $1D, $60, $F8, $63, $1F
 EQUB $1F, $61, $1F, $63, $1F, $61, $1F, $F9
 EQUB $61, $20, $6B, $20, $63, $F8, $6A, $1D
 EQUB $60, $F8, $61, $1D, $63, $1D, $68, $1D
 EQUB $60, $F8, $63, $1F, $1F, $61, $1F, $63
 EQUB $1F, $61, $20, $6F, $F9, $FF

.tune3Data_SQ2_1
.tune4Data_SQ2_1

 EQUB $FA, $70, $6F, $F6, $05, $18, $F6, $04
 EQUB $1C, $F6, $06, $1F, $F6, $01, $22, $63
 EQUB $F9, $6B, $F8, $FF

.tune3Data_NOISE_0
.tune4Data_NOISE_0

 EQUB $F6, $0F, $63, $F8, $67, $F6, $02, $07
 EQUB $F6, $11, $63, $04, $FF

.tune3Data_NOISE_1
.tune4Data_NOISE_1

 EQUB $61, $F6, $10, $08, $02, $F6, $12, $07
 EQUB $F6, $10, $02, $FF

.tune3Data_NOISE_2
.tune4Data_NOISE_2

 EQUB $63, $F6, $11, $02, $F6, $12, $02, $F6
 EQUB $11, $02, $F6, $12, $02, $F6, $11, $02
 EQUB $F6, $12, $02, $F6, $11, $02, $F6, $12
 EQUB $02, $F6, $11, $02, $F6, $12, $02, $F6
 EQUB $11, $02, $F6, $12, $02, $F6, $12, $02
 EQUB $02, $02, $02, $6F, $04, $FF

.tune4Data_SQ1_2

 EQUB $F5
 EQUW tune2Data_SQ1

.tune4Data_TRI_2

 EQUB $F5
 EQUW tune2Data_TRI

.tune4Data_SQ2_2

 EQUB $F5
 EQUW tune2Data_SQ2

.tune4Data_NOISE_3

 EQUB $F5
 EQUW tune2Data_NOISE

.tune0Data_SQ1_4

 EQUB $FB, $00, $FF

.tune0Data_SQ1_3

 EQUB $FB, $01, $FF

.tune2Data_SQ1_0

 EQUB $FB, $03, $FF

.tune2Data_SQ1_5

 EQUB $FB, $04, $FF

.tune1Data_NOISE_0

 EQUB $7F, $F6, $0F, $F8, $FF, $EA

; ******************************************************************************
;
;       Name: DrawGlasses
;       Type: Subroutine
;   Category: Status
;    Summary: Draw a pair of dark glasses on the commander image
;
; ******************************************************************************

.DrawGlasses

 LDA #104               ; Set the pattern number for sprite 8 to 104, which is
 STA pattSprite8        ; the left part of the dark glasses

 LDA #%00000000         ; Set the attributes for sprite 8 as follows:
 STA attrSprite8        ;
                        ;   * Bits 0-1    = sprite palette 0
                        ;   * Bit 5 clear = show in front of background
                        ;   * Bit 6 clear = do not flip horizontally
                        ;   * Bit 7 clear = do not flip vertically

 LDA #203               ; Set the x-coordinate for sprite 8 to 203
 STA xSprite8

 LDA languageNumber     ; If bit 2 of languageNumber is clear then the chosen
 AND #%00000100         ; language is not French, so jump to glas1 with A = 0
 BEQ glas1

 LDA #16                ; The chosen language is French, so the commander image
                        ; is 16 pixels lower down the screen, so set A = 16 to
                        ; add to the y-coordinate of the glasses

.glas1

 CLC                    ; Set the y-coordinate for sprite 8 to 90, plus the
 ADC #90+YPAL           ; margin we just set in A
 STA ySprite8

 LDA #105               ; Set the pattern number for sprite 9 to 105, which is
 STA pattSprite9        ; the middle part of the dark glasses

 LDA #%00000000         ; Set the attributes for sprite 9 as follows:
 STA attrSprite9        ;
                        ;   * Bits 0-1    = sprite palette 0
                        ;   * Bit 5 clear = show in front of background
                        ;   * Bit 6 clear = do not flip horizontally
                        ;   * Bit 7 clear = do not flip vertically

 LDA #211               ; Set the x-coordinate for sprite 9 to 211
 STA xSprite9

 LDA languageNumber     ; If bit 2 of languageNumber is clear then the chosen
 AND #%00000100         ; language is not French, so jump to glas2 with A = 0
 BEQ glas2

 LDA #16                ; The chosen language is French, so the commander image
                        ; is 16 pixels lower down the screen, so set A = 16 to
                        ; add to the y-coordinate of the glasses

.glas2

 CLC                    ; Set the y-coordinate for sprite 9 to 90, plus the
 ADC #90+YPAL           ; margin we just set in A
 STA ySprite9

 LDA #106               ; Set the pattern number for sprite 10 to 106, which is
 STA pattSprite10       ; the right part of the dark glasses

 LDA #%00000000         ; Set the attributes for sprite 10 as follows:
 STA attrSprite10       ;
                        ;   * Bits 0-1    = sprite palette 0
                        ;   * Bit 5 clear = show in front of background
                        ;   * Bit 6 clear = do not flip horizontally
                        ;   * Bit 7 clear = do not flip vertically

 LDA #219               ; Set the x-coordinate for sprite 10 to 219
 STA xSprite10

 LDA languageNumber     ; If bit 2 of languageNumber is clear then the chosen
 AND #%00000100         ; language is not French, so jump to glas3 with A = 0
 BEQ glas3

 LDA #16                ; The chosen language is French, so the commander image
                        ; is 16 pixels lower down the screen, so set A = 16 to
                        ; add to the y-coordinate of the glasses

.glas3

 CLC                    ; Set the y-coordinate for sprite 10 to 90, plus the
 ADC #90+YPAL           ; margin we just set in A
 STA ySprite10

 RTS                    ; Return from the subroutine

; ******************************************************************************
;
;       Name: DrawRightEarring
;       Type: Subroutine
;   Category: Status
;    Summary: Draw an earring in the commander's right ear (i.e. on the left
;             side of the commander image
;
; ******************************************************************************

.DrawRightEarring

 LDA #107               ; Set the pattern number for sprite 11 to 107, which is
 STA pattSprite11       ; the right earring

 LDA #%00000010         ; Set the attributes for sprite 11 as follows:
 STA attrSprite11       ;
                        ;   * Bits 0-1    = sprite palette 2
                        ;   * Bit 5 clear = show in front of background
                        ;   * Bit 6 clear = do not flip horizontally
                        ;   * Bit 7 clear = do not flip vertically

 LDA #195               ; Set the x-coordinate for sprite 11 to 195
 STA xSprite11

 LDA languageNumber     ; If bit 2 of languageNumber is clear then the chosen
 AND #%00000100         ; language is not French, so jump to earr1 with A = 0
 BEQ earr1

 LDA #16                ; The chosen language is French, so the commander image
                        ; is 16 pixels lower down the screen, so set A = 16 to
                        ; add to the y-coordinate of the earring

.earr1

 CLC                    ; Set the y-coordinate for sprite 11 to 98, plus the
 ADC #98+YPAL           ; margin we just set in A
 STA ySprite11

 RTS                    ; Return from the subroutine

; ******************************************************************************
;
;       Name: DrawLeftEarring
;       Type: Subroutine
;   Category: Status
;    Summary: Draw an earring in the commander's left ear (i.e. on the right
;             side of the commander image
;
; ******************************************************************************

.DrawLeftEarring

 LDA #108               ; Set the pattern number for sprite 12 to 108, which is
 STA pattSprite12       ; the left earring

 LDA #%00000010         ; Set the attributes for sprite 12 as follows:
 STA attrSprite12       ;
                        ;   * Bits 0-1    = sprite palette 2
                        ;   * Bit 5 clear = show in front of background
                        ;   * Bit 6 clear = do not flip horizontally
                        ;   * Bit 7 clear = do not flip vertically

 LDA #227               ; Set the x-coordinate for sprite 12 to 227
 STA xSprite12

 LDA languageNumber     ; If bit 2 of languageNumber is clear then the chosen
 AND #%00000100         ; language is not French, so jump to earl1 with A = 0
 BEQ earl1

 LDA #16                ; The chosen language is French, so the commander image
                        ; is 16 pixels lower down the screen, so set A = 16 to
                        ; add to the y-coordinate of the earring

.earl1

 CLC                    ; Set the y-coordinate for sprite 12 to 98, plus the
 ADC #98+YPAL           ; margin we just set in A
 STA ySprite12

 RTS                    ; Return from the subroutine

; ******************************************************************************
;
;       Name: DrawMedallion
;       Type: Subroutine
;   Category: Status
;    Summary: Draw a medallion on the commander image
;
; ******************************************************************************

.DrawMedallion

                        ; We draw the medallion image from sprites with
                        ; sequential patterns, so first we configure the
                        ; variables to pass to the DrawSpriteImage routine

 LDA #3                 ; Set K = 5, to pass as the number of columns in the
 STA K                  ; image to DrawSpriteImage below

 LDA #2                 ; Set K+1 = 2, to pass as the number of rows in the
 STA K+1                ; image to DrawSpriteImage below

 LDA #111               ; Set K+2 = 111, so we draw the medallion using pattern
 STA K+2                ; #111 onwards

 LDA #15                ; Set K+3 = 15, so we build the image from sprite 15
 STA K+3                ; onwards

 LDX #11                ; Set X = 11 so we draw the image 11 pixels into the
                        ; (XC, YC) character block along the x-axis

 LDY #49                ; Set Y = 49 so we draw the image 49 pixels into the
                        ; (XC, YC) character block along the y-axis

 LDA #%00000010         ; Set the attributes for the sprites we create in the
                        ; DrawSpriteImage routine as follows:
                        ;
                        ;   * Bits 0-1    = sprite palette 2
                        ;   * Bit 5 clear = show in front of background
                        ;   * Bit 6 clear = do not flip horizontally
                        ;   * Bit 7 clear = do not flip vertically

 JMP DrawSpriteImage+2  ; Draw the medallion image from sprites, using pattern
                        ; #111 onwards and the sprite attributes in A

; ******************************************************************************
;
;       Name: DrawCmdrImage
;       Type: Subroutine
;   Category: Status
;    Summary: Draw the commander image as a coloured face image in front of a
;             greyscale headshot image, with optional embellishments
;
; ******************************************************************************

.DrawCmdrImage

                        ; The commander image is made up of two layers and some
                        ; optional embellishments:
                        ;
                        ;   * A greyscale headshot (i.e. the head and shoulders)
                        ;     that's displayed as a background using the
                        ;     nametable tiles, whose patterns are extracted into
                        ;     the pattern buffers by the GetHeadshot routine
                        ;
                        ;   * A colourful face that's displayed in the
                        ;     foreground as a set of sprites, whose patterns are
                        ;     sent to the PPU by the GetCmdrImage routine, from
                        ;     pattern 69 onwards
                        ;
                        ;   * A pair of dark glasses (if we are a fugitive)
                        ;
                        ;   * Left and right earrings and a medallion, depending
                        ;     on how rich we are
                        ;
                        ; We start by drawing the background into the nametable
                        ; buffers

 LDX #6                 ; Set X = 6 to use as the number of columns in the image

 LDY #8                 ; Set Y = 8 to use as the number of rows in the image

 STX K                  ; Set K = X, so we can pass the number of columns in the
                        ; image to DrawBackground below

 STY K+1                ; Set K+1 = Y, so we can pass the number of rows in the
                        ; image to DrawBackground below

 LDA firstFreePattern   ; Set picturePattern to the number of the next free
 STA picturePattern     ; pattern in firstFreePattern
                        ;
                        ; We use this when setting K+2 below, so the call to
                        ; DrawBackground displays the patterns at
                        ; picturePattern, and it's also used to specify where to
                        ; load the system image data when we call GetCmdrImage
                        ; from SendViewToPPU when showing the Status screen

 CLC                    ; Add 48 to firstFreePattern, as we are going to use 48
 ADC #48                ; patterns for the system image (8 rows of 6 tiles)
 STA firstFreePattern

 LDX picturePattern     ; Set K+2 to the value we stored above, so K+2 is the
 STX K+2                ; number of the first pattern to use for the commander
                        ; image's greyscale headshot

 JSR DrawBackground_b3  ; Draw the background by writing the nametable buffer
                        ; entries for the greyscale part of the commander image
                        ; (this is the image that is extracted into the pattern
                        ; buffers by the GetSystemBack routine)

                        ; Now that the background is drawn, we move on to the
                        ; sprite-based foreground, which contains the face image
                        ;
                        ; We draw the face image from sprites with sequential
                        ; patterns, so now we configure the variables to pass
                        ; to the DrawSpriteImage routine

 LDA #5                 ; Set K = 5, to pass as the number of columns in the
 STA K                  ; image to DrawSpriteImage below

 LDA #7                 ; Set K+1 = 7, to pass as the number of rows in the
 STA K+1                ; image to DrawSpriteImage below

 LDA #69                ; Set K+2 = 69, so we draw the face image using
 STA K+2                ; pattern 69 onwards

 LDA #20                ; Set K+3 = 20, so we build the image from sprite 20
 STA K+3                ; onwards

 LDX #4                 ; Set X = 4 so we draw the image four pixels into the
                        ; (XC, YC) character block along the x-axis

 LDY #0                 ; Set Y = 0 so we draw the image at the top of the
                        ; (XC, YC) character block along the y-axis

 JSR DrawSpriteImage_b6 ; Draw the face image from sprites, using pattern 69
                        ; onwards

                        ; Next, we draw a pair of smooth-criminal dark glasses
                        ; in front of the face if we have got a criminal record

 LDA FIST               ; If our legal status in FIST is less than 40, then we
 CMP #40                ; are either clean or an offender, so jump to cmdr1 to
 BCC cmdr1              ; skip the following instruction, as we aren't bad
                        ; enough to wear shades

 JSR DrawGlasses        ; If we get here then we are a fugitive, so draw a pair
                        ; of dark glasses in front of the face

.cmdr1

                        ; We now embellish the commander image, depending on how
                        ; much cash we have
                        ;
                        ; Note that the CASH amount is stored as a big-endian
                        ; four-byte number with the most significant byte first,
                        ; i.e. as CASH(0 1 2 3)

 LDA CASH               ; If CASH >= &01000000 (1,677,721.6 CR), jump to cmdr2
 BNE cmdr2

 LDA CASH+1             ; If CASH >= &00990000 (1,002,700.8 CR), jump to cmdr2
 CMP #$99
 BCS cmdr2

 CMP #0                 ; If CASH >= &00010000 (6,553.6 CR), jump to cmdr3
 BNE cmdr3

 LDA CASH+2             ; If CASH >= &00004F00 (2,022.4 CR), jump to cmdr3
 CMP #$4F
 BCS cmdr3

 CMP #$28               ; If CASH < &00002800 (1,024.0 CR), jump to cmdr5
 BCC cmdr5

 BCS cmdr4              ; Jump to cmdr4 (this BCS is effectively a JMP as we
                        ; just passed through a BCC)

.cmdr2

 JSR DrawMedallion      ; If we get here then we have more than 1,002,700.8 CR,
                        ; so call DrawMedallion to draw a medallion on the
                        ; commander image

.cmdr3

 JSR DrawRightEarring   ; If we get here then we have more than 2,022.4 CR, so
                        ; call DrawLeftEarring to draw an earring in the
                        ; commander's right ear (i.e. on the left side of the
                        ; commander image

.cmdr4

 JSR DrawLeftEarring    ; If we get here then we have more than 1,024.0 CR, so
                        ; call DrawRightEarring to draw an earring in the
                        ; commander's left ear (i.e. on the right side of the
                        ; commander image
.cmdr5

 LDX XC                 ; We just drew the image at (XC, YC), so decrement them
 DEX                    ; both so we can pass (XC, YC) to the DrawImageFrame
 STX XC                 ; routine to draw a frame around the image, with the
 LDX YC                 ; top-left corner one block up and left from the image
 DEX                    ; corner
 STX YC

 LDA #7                 ; Set K = 7 to pass to the DrawImageFrame routine as the
 STA K                  ; frame width minus 1, so the frame is eight tiles wide,
                        ; to cover the image which is six tiles wide

 LDA #10                ; Set K+1 = 10 to pass to the DrawImageFrame routine as
 STA K+1                ; the frame height, so the frame is ten tiles high,
                        ; to cover the image which is eight tiles high

 JMP DrawImageFrame_b3  ; Call DrawImageFrame to draw a frame around the
                        ; commander image, returning from the subroutine using a
                        ; tail call

; ******************************************************************************
;
;       Name: DrawSpriteImage
;       Type: Subroutine
;   Category: Drawing sprites
;    Summary: Draw an image out of sprites using patterns in sequential tiles in
;             the pattern buffer
;  Deep dive: Sprite usage in NES Elite
;
; ------------------------------------------------------------------------------
;
; Arguments:
;
;   K                   The number of columns in the image (i.e. the number of
;                       tiles in each row of the image)
;
;   K+1                 The number of tile rows in the image
;
;   K+2                 The pattern number of the start of the image pattern
;                       data in the pattern table
;
;   K+3                 Number of the first free sprite in the sprite buffer,
;                       where we can build the sprites to make up the image
;
;   XC                  The text column of the top-left corner of the image
;
;   YC                  The text row of the top-left corner of the image
;
;   X                   The pixel x-coordinate of the top-left corner of the
;                       image within the text block at (XC, YC)
;
;   Y                   The pixel y-coordinate of the top-left corner of the
;                       image within the text block at (XC, YC)
;
; ------------------------------------------------------------------------------
;
; Other entry points:
;
;   DrawSpriteImage+2   Set the attributes for the sprites in the image to A
;
; ******************************************************************************

.DrawSpriteImage

 LDA #%00000001         ; Set S to use as the attribute for each of the sprites
 STA S                  ; in the image, so each sprite is set as follows:
                        ;
                        ;   * Bits 0-1    = sprite palette 1
                        ;   * Bit 5 clear = show in front of background
                        ;   * Bit 6 clear = do not flip horizontally
                        ;   * Bit 7 clear = do not flip vertically

 LDA XC                 ; Set SC = XC * 8 + X
 ASL A                  ;        = XC * 8 + 6
 ASL A                  ;
 ASL A                  ; So SC is the pixel x-coordinate of the top-left corner
 ADC #0                 ; of the image we want to draw, as each text character
 STA SC                 ; in XC is 8 pixels wide and X contains the x-coordinate
 TXA                    ; within the character block
 ADC SC
 STA SC

 LDA YC                 ; Set SC+1 = YC * 8 + 6 + Y
 ASL A                  ;          = YC * 8 + 6 + 6
 ASL A                  ;
 ASL A                  ; So SC+1 is the pixel y-coordinate of the top-left
 ADC #6+YPAL            ; corner of the image we want to draw, as each text row
 STA SC+1               ; in YC is 8 pixels high and Y contains the y-coordinate
 TYA                    ; within the character block
 ADC SC+1
 STA SC+1

 LDA K+3                ; Set Y = K+3 * 4
 ASL A                  ;
 ASL A                  ; So Y contains the offset of the first free sprite's
 TAY                    ; four-byte block in the sprite buffer, as each sprite
                        ; consists of four bytes, so this is now the offset
                        ; within the sprite buffer of the first sprite we can
                        ; use to build the sprite image

 LDA K+2                ; Set A to the pattern number of the first tile in K+2

 LDX K+1                ; Set T = K+1 to use as a counter for each row in the
 STX T                  ; image

.drsi1

 SETUP_PPU_FOR_ICON_BAR ; If the PPU has started drawing the icon bar, configure
                        ; the PPU to use nametable 0 and pattern table 0

 LDX SC                 ; Set SC2 to the pixel x-coordinate for the start of
 STX SC2                ; each row, so we can use it to move along the row as we
                        ; draw the sprite image

 LDX K                  ; Set X to the number of tiles in each row of the image
                        ; (in K), so we can use it as a counter as we move along
                        ; the row

.drsi2

 LDA K+2                ; Set the pattern for sprite Y to K+2, which is the
 STA pattSprite0,Y      ; pattern number in the PPU's pattern table to use for
                        ; this part of the image

 LDA S                  ; Set the attributes for sprite Y to S, which we set
 STA attrSprite0,Y      ; above as follows:
                        ;
                        ;   * Bits 0-1    = sprite palette 1
                        ;   * Bit 5 clear = show in front of background
                        ;   * Bit 6 clear = do not flip horizontally
                        ;   * Bit 7 clear = do not flip vertically

 LDA SC2                ; Set the x-coordinate for sprite Y to SC2
 STA xSprite0,Y

 CLC                    ; Set SC2 = SC2 + 8
 ADC #8                 ;
 STA SC2                ; So SC2 contains the x-coordinate of the next tile
                        ; along the row

 LDA SC+1               ; Set the y-coordinate for sprite Y to SC+1
 STA ySprite0,Y

 TYA                    ; Add 4 to the sprite number in Y, to move on to the
 CLC                    ; next sprite in the sprite buffer (as each sprite
 ADC #4                 ; consists of four bytes of data)

 BCS drsi3              ; If the addition overflowed, then we have reached the
                        ; end of the sprite buffer, so jump to drsi3 to return
                        ; from the subroutine, as we have run out of sprites

 TAY                    ; Otherwise set Y to the offset of the next sprite in
                        ; the sprite buffer

 INC K+2                ; Increment the tile counter in K+2 to point to the next
                        ; pattern

 DEX                    ; Decrement the tile counter in X as we have just drawn
                        ; a tile

 BNE drsi2              ; If X is non-zero then we still have more tiles to
                        ; draw on the current row, so jump back to drsi2 to draw
                        ; the next one

 LDA SC+1               ; Otherwise we have reached the end of this row, so add
 ADC #8                 ; 8 to SC+1 to move the y-coordinate down to the next
 STA SC+1               ; tile row (as each tile row is 8 pixels high)

 DEC T                  ; Decrement the number of rows in T as we just finished
                        ; drawing a row

 BNE drsi1              ; Loop back to drsi1 until we have drawn all the rows in
                        ; the image

.drsi3

 RTS                    ; Return from the subroutine

; ******************************************************************************
;
;       Name: PauseGame
;       Type: Subroutine
;   Category: Icon bar
;    Summary: Pause the game and process choices from the pause menu until the
;             game is unpaused by another press of Start
;
; ------------------------------------------------------------------------------
;
; Returns:
;
;   X                   X is preserved
;
;   Y                   Y is preserved
;
;   nmiTimer            nmiTimer is preserved
;
;   nmiTimerHi          nmiTimerHi is preserved
;
;   nmiTimerLo          nmiTimerLo is preserved
;
;   showIconBarPointer  showIconBarPointer is preserved
;
;   iconBarType         iconBarType is preserved
;
; ******************************************************************************

.PauseGame

 TYA                    ; Store X and Y on the stack so we can retrieve them
 PHA                    ; below
 TXA
 PHA

 JSR WaitForNMI         ; Wait until the next NMI interrupt has passed (i.e. the
                        ; next VBlank)

 LDA nmiTimer           ; Store nmiTimer and (nmiTimerHi nmiTimerLo) on the
 PHA                    ; stack so we can retrieve them below
 LDA nmiTimerLo
 PHA
 LDA nmiTimerHi
 PHA

 JSR WaitForPPUToFinish ; Wait until both bitplanes of the screen have been
                        ; sent to the PPU, so the screen is fully updated and
                        ; there is no more data waiting to be sent to the PPU

 LDA showIconBarPointer ; Store showIconBarPointer on the stack so we can
 PHA                    ; retrieve it below

 LDA iconBarType        ; Store iconBarType on the stack so we can retrieve it
 PHA                    ; below

 LDA #$FF               ; Set showIconBarPointer = $FF to indicate that we
 STA showIconBarPointer ; should show the icon bar pointer

 LDA #3                 ; Show icon bar type 3 (Pause) on-screen
 JSR ShowIconBar_b3

.paug1

 LDY #4                 ; Wait until four NMI interrupts have passed (i.e. the
 JSR DELAY              ; next four VBlanks)

 JSR SetKeyLogger_b6    ; Populate the key logger table with the controller
                        ; button presses and return the button number in X
                        ; if an icon bar button has been chosen

 TXA                    ; Set A to the button number if an icon bar button has
                        ; been chosen

 CMP #80                ; If the Start button was pressed to pause the game then
 BNE paug2              ; A will be 80, so jump to paug2 to process choices from
                        ; the pause menu

                        ; Otherwise the Start button was pressed for a second
                        ; time (which returns X = 0 from SetKeyLogger), so now
                        ; we remove the pause menu

 PLA                    ; Retrieve iconBarType from the stack into A

 JSR ShowIconBar_b3     ; Show icon bar type A on-screen, so we redisplay the
                        ; icon bar that was on the screen before the game was
                        ; paused

 PLA                    ; Set showIconBarPointer to the value we stored on the
 STA showIconBarPointer ; stack above, so it is preserved

 JSR WaitForNMI         ; Wait until the next NMI interrupt has passed (i.e. the
                        ; next VBlank)

 PLA                    ; Set nmiTimer and (nmiTimerHi nmiTimerLo) to the values
 STA nmiTimerHi         ; we stored on the stack above, so they are preserved
 PLA
 STA nmiTimerLo
 PLA
 STA nmiTimer

 PLA                    ; Set X and Y to the values we stored on the stack
 TAX                    ; above, so they are preserved
 PLA
 TAY

 RTS                    ; Return from the subroutine

.paug2

                        ; If we get here then an icon bar button has been chosen
                        ; and the button number is in A

 CMP #52                ; If the Sound toggle button was not chosen, jump to
 BNE paug3              ; paug3 to keep checking

 LDA DNOIZ              ; The Sound toggle button was chosen, so flip the value
 EOR #$FF               ; of DNOIZ to toggle between sound on and sound off
 STA DNOIZ

 JMP paug11             ; Jump to paug11 to update the icon bar and loop back to
                        ; keep listening for button presses

.paug3

 CMP #51                ; If the Music toggle button was not chosen, jump to
 BNE paug6              ; paug6 to keep checking

 LDA disableMusic       ; The Music toggle button was chosen, so flip the value
 EOR #$FF               ; of disableMusic to toggle between music on and music
 STA disableMusic       ; off

 BPL paug4              ; If the toggle was flipped to 0, then music is enabled
                        ; so jump to paug4 to start the music playing (if a tune
                        ; is configured)

 JSR StopSounds_b6      ; Otherwise music has just been enabled, so call
                        ; StopSounds to stop any sounds that are being made
                        ; (music or sound effects)

 JMP paug11             ; Jump to paug11 to update the icon bar and loop back to
                        ; keep listening for button presses

.paug4

                        ; If we get here then music was just enabled

 LDA newTune            ; If newTune = 0 then no tune is configured to play, so
 BEQ paug5              ; jump to paug5 to skip the following

 AND #%01111111         ; Clear bit 7 of newTune to extract the tune number that
                        ; is configured to play

 JSR ChooseMusic_b6     ; Call ChooseMusic to start playing the tune in A

.paug5

 JMP paug11             ; Jump to paug11 to update the icon bar and loop back to
                        ; keep listening for button presses

.paug6

 CMP #60                ; If the Restart button was not chosen, jump to paug7
 BNE paug7

                        ; The Restart button was just chosen, so we now restart
                        ; the game

 PLA                    ; Retrieve iconBarType from the stack into A (and ignore
                        ; it)

 PLA                    ; Set showIconBarPointer to the value we stored on the
 STA showIconBarPointer ; stack above, so it is preserved

 JMP DEATH2_b0          ; Jump to DEATH2 to restart the game (which also resets
                        ; the stack pointer, so we can ignore all the other
                        ; values that we put on the stack above)

.paug7

 CMP #53                ; If the Number of Pilots button was not chosen, jump
 BNE paug8              ; to paug8 to keep checking

 LDA numberOfPilots     ; The Number of Pilots button was chosen, so flip the
 EOR #1                 ; value of numberOfPilots between 0 and 1 to change the
 STA numberOfPilots     ; number of pilots between 1 and 2

 JMP paug11             ; Jump to paug11 to update the icon bar and loop back to
                        ; keep listening for button presses

.paug8

 CMP #49                ; If the "Direction of y-axis" toggle button was not
 BNE paug9              ; chosen, jump to paug9 to keep checking

 LDA JSTGY              ; The "Direction of y-axis" toggle button was chosen, so
 EOR #$FF               ; flip the value of JSTGY to toggle the direction of the
 STA JSTGY              ; controller y-axis

 JMP paug11             ; Jump to paug11 to update the icon bar and loop back to
                        ; keep listening for button presses

.paug9

 CMP #50                ; If the Damping toggle button was not chosen, jump to
 BNE paug10             ; paug10 to keep checking

 LDA DAMP               ; The Damping toggle button was chosen, so flip the
 EOR #$FF               ; value of DAMP to toggle between damping on and damping
 STA DAMP               ; off

 JMP paug11             ; Jump to paug11 to update the icon bar and loop back to
                        ; keep listening for button presses

.paug10

 JMP paug1              ; Jump back to paug1 to keep listening for button
                        ; presses

.paug11

 JSR UpdateIconBar_b3   ; Update the icon bar to show updated icons for any
                        ; changed options

 JMP paug1              ; Jump back to paug1 to keep listening for button
                        ; presses

; ******************************************************************************
;
;       Name: DILX
;       Type: Subroutine
;   Category: Dashboard
;    Summary: Update a bar-based indicator on the dashboard
;
; ------------------------------------------------------------------------------
;
; The range of values shown on the indicator depends on which entry point is
; called. For the default entry point of DILX, the range is 0-255 (as the value
; passed in A is one byte). The other entry points are shown below.
;
; This routine does a similar job to the routine of the same name in the BBC
; Master version of Elite, but the code is significantly different.
;
; ------------------------------------------------------------------------------
;
; Arguments:
;
;   A                   The value to be shown on the indicator (so the larger
;                       the value, the longer the bar)
;
;   SC(1 0)             The address of the tile at the left end of the indicator
;                       in nametable buffer 0
;
;   K                   The lower end of the safe range, so safe values are in
;                       the range K <= A < K+1 (and other values are dangerous)
;
;   K+1                 The upper end of the safe range, so safe values are in
;                       the range K <= A < K+1 (and other values are dangerous)
;
; ------------------------------------------------------------------------------
;
; Returns:
;
;   SC(1 0)             The address of the tile at the left end of the next
;                       indicator down
;
; ------------------------------------------------------------------------------
;
; Other entry points:
;
;   DILX+2              The range of the indicator is 0-64 (for the fuel and
;                       speed indicators)
;
; ******************************************************************************

.DILX

 LSR A                  ; If we call DILX, we set A = A / 16, so A is 0-31
 LSR A

 LSR A                  ; If we call DILX+2, we set A = A / 4, so A is 0-31

 CMP #31                ; If A < 31 then jump to dilx1 to skip the following
 BCC dilx1              ; instruction

 LDA #30                ; Set A = 30, so the maximum value of the value to show
                        ; on the indicator in A is 30

.dilx1

 LDY #0                 ; We are going to draw the indicator as a row of tiles,
                        ; so set an index in Y to count the tiles as we work
                        ; from left to right

 CMP K                  ; If A < K then this value is lower than the lower end
 BCC dilx8              ; of the safe range, so jump to dilx8 to flash the
                        ; indicator bar between colour 4 and colour 2, to
                        ; indicate a dangerous value

 CMP K+1                ; If A >= K+1 then this value is higher than the upper
 BCS dilx8              ; end of the safe range, so jump to dilx8 to draw the
                        ; indicator bar between colour 4 and colour 2, to
                        ; indicate a dangerous value

 STA Q                  ; Store the value we want to draw on the indicator in Q

.dilx2

 LSR A                  ; Set A = A / 8
 LSR A                  ;
 LSR A                  ; Each indicator consists of four tiles that we use to
                        ; show a value from 0 to 30, so this gives us the number
                        ; of sections we need to fill with a full bar (in the
                        ; range 0 to 3, as A is in the range 0 to 30)

 BEQ dilx4              ; If the result is 0 then the value is too low to need
                        ; any full bars, so jump to dilx4 to draw the end cap of
                        ; the indicator bar and any blank space to the right

 TAX                    ; Set X to the number of sections that we need to fill
                        ; with a full bar, so we can use it as a loop counter to
                        ; draw the correct number of full bars

 LDA #236               ; Set A = 236, which is the pattern number of the fully
                        ; filled bar in colour 4 (for a safe value)

.dilx3

 STA (SC),Y             ; Set the Y-th tile of the indicator to A to show a full
                        ; bar

 INY                    ; Increment the tile number in Y to move to the next
                        ; tile in the indicator

 DEX                    ; Decrement the loop counter in X

 BNE dilx3              ; Loop back until we have drawn the correct number of
                        ; full bars

.dilx4

                        ; We now draw the correct end cap on the right end of
                        ; the indicator bar

 LDA Q                  ; Set A to the value we want to draw on the indicator,
                        ; which we stored in Q above

 AND #7                 ; Set A = A mod 8, which gives us the remaining value
                        ; once we've taken off any fully filled tiles (as each
                        ; of the four tiles that make up the indicator
                        ; represents a value of 8)

 CLC                    ; Set A = A + 237
 ADC #237               ;
                        ; The eight patterns from 237 to 244 contain the end cap
                        ; patterns in colour 4 (for a safe value), ranging
                        ; from the smallest cap to the largest, so this sets A
                        ; to the correct pattern number to use as the end cap
                        ; for displaying the remainder in A

 STA (SC),Y             ; Set the Y-th tile of the indicator to A to show the
                        ; end cap

 INY                    ; Increment the tile number in Y to move to the next
                        ; tile in the indicator

                        ; We now fill the rest of the four tiles with a blank
                        ; indicator tile, if required

 LDA #85                ; Set A = 85, which is the pattern number of an empty
                        ; tile in an indicator

.dilx5

 CPY #4                 ; If Y = 4 then we have just drawn the last tile in
 BEQ dilx6              ; the indicator, so jump to dilx6 to finish off, as we
                        ; have now drawn the entire indicator

 STA (SC),Y             ; Otherwise set the Y-th tile of the indicator to A to
                        ; fill the space to the right of the indicator bar with
                        ; the blank indicator pattern

 INY                    ; Increment the tile number in Y to move to the next
                        ; tile in the indicator

 BNE dilx5              ; Loop back to dilx5 to draw the next tile (this BNE is
                        ; effectively a JMP as Y won't ever wrap around to 0)

.dilx6

 LDA SC                 ; Set SC(1 0) = SC(1 0) + 32
 CLC                    ;
 ADC #32                ; Starting with the low bytes
 STA SC

 BCC dilx7              ; And then the high bytes
 INC SC+1               ;
                        ; This points SC(1 0) to the nametable entry for the
                        ; next indicator on the row below, as there are 32 tiles
                        ; in each row

.dilx7

 SETUP_PPU_FOR_ICON_BAR ; If the PPU has started drawing the icon bar, configure
                        ; the PPU to use nametable 0 and pattern table 0

 RTS                    ; Return from the subroutine

.dilx8

 STA Q                  ; Store the value we want to draw on the indicator in Q

 LDA MCNT               ; Fetch the main loop counter and jump to dilx10 if bit
 AND #%00001000         ; 3 is set, which will be true half of the time, with
 BNE dilx10             ; the bit being 0 for eight iterations around the main
                        ; loop, and 1 for the next eight iterations
                        ;
                        ; If we jump to dilx10 then the indicator is shown in
                        ; red, and if we don't jump it is shown in the normal
                        ; colour, so this flashes the indicator bar between red
                        ; and the normal colour, changing the colour every eight
                        ; iterations of the main loop

 LDA Q                  ; Set A to the value we want to draw on the indicator,
                        ; which we stored in Q above

 JMP dilx2              ; Jump back to dilx2 to draw the indicator in the normal
                        ; colour scheme

 LDY #0                 ; These instructions are never run and have no effect
 BEQ dilx13

.dilx10

                        ; If we get here then we show the indicator in red

 LDA Q                  ; Set A to the value we want to draw on the indicator,
                        ; which we stored in Q above

 LSR A                  ; Set A = A / 8
 LSR A                  ;
 LSR A                  ; Each indicator consists of four tiles that we use to
                        ; show a value from 0 to 30, so this gives us the number
                        ; of sections we need to fill with a full bar (in the
                        ; range 0 to 3, as A is in the range 0 to 30)

 BEQ dilx12             ; If the result is 0 then the value is too low to need
                        ; any full bars, so jump to dilx12 to draw the end cap
                        ; of the indicator bar and any blank space to the right

 TAX                    ; Set X to the number of sections that we need to fill
                        ; with a full bar, so we can use it as a loop counter to
                        ; draw the correct number of full bars

 LDA #227               ; Set A = 237, which is the pattern number of the fully
                        ; filled bar in colour 2 (for a dangerous value)

.dilx11

 STA (SC),Y             ; Set the Y-th tile of the indicator to A to show a full
                        ; bar

 INY                    ; Increment the tile number in Y to move to the next
                        ; tile in the indicator

 DEX                    ; Decrement the loop counter in X

 BNE dilx11             ; Loop back until we have drawn the correct number of
                        ; full bars

.dilx12

                        ; We now draw the correct end cap on the right end of
                        ; the indicator bar

 LDA Q                  ; Set A to the value we want to draw on the indicator,
                        ; which we stored in Q above

 AND #7                 ; Set A = A mod 8, which gives us the remaining value
                        ; once we've taken off any fully filled tiles (as each
                        ; of the four tiles that make up the indicator
                        ; represents a value of 8)

 CLC                    ; Set A = A + 228
 ADC #228               ;
                        ; The eight patterns from 228 to 235 contain the end cap
                        ; patterns in colour 2 (for a dangerous value), ranging
                        ; from the smallest cap to the largest, so this sets A
                        ; to the correct pattern number to use as the end cap
                        ; for displaying the remainder in A

 STA (SC),Y             ; Set the Y-th tile of the indicator to A to show the
                        ; end cap

 INY                    ; Increment the tile number in Y to move to the next
                        ; tile in the indicator

.dilx13

                        ; We now fill the rest of the four tiles with a blank
                        ; indicator tile, if required

 LDA #85                ; Set A = 85, which is the pattern number of an empty
                        ; tile in an indicator

.dilx14

 CPY #4                 ; If Y = 4 then we have just drawn the last tile in
 BEQ dilx15             ; the indicator, so jump to dilx6 to finish off, as we
                        ; have now drawn the entire indicator

 STA (SC),Y             ; Otherwise set the Y-th tile of the indicator to A to
                        ; fill the space to the right of the indicator bar with
                        ; the blank indicator pattern

 INY                    ; Increment the tile number in Y to move to the next
                        ; tile in the indicator

 BNE dilx14             ; Loop back to dilx14 to draw the next tile (this BNE is
                        ; effectively a JMP as Y won't ever wrap around to 0)

.dilx15

 LDA SC                 ; Set SC(1 0) = SC(1 0) + 32
 CLC                    ;
 ADC #32                ; Starting with the low bytes
 STA SC

 BCC dilx16             ; And then the high bytes
 INC SC+1               ;
                        ; This points SC(1 0) to the nametable entry for the
                        ; next indicator on the row below, as there are 32 tiles
                        ; in each row

.dilx16

 SETUP_PPU_FOR_ICON_BAR ; If the PPU has started drawing the icon bar, configure
                        ; the PPU to use nametable 0 and pattern table 0

 RTS                    ; Return from the subroutine

; ******************************************************************************
;
;       Name: DIALS
;       Type: Subroutine
;   Category: Dashboard
;    Summary: Update the dashboard
;  Deep dive: Sprite usage in NES Elite
;
; ------------------------------------------------------------------------------
;
; This routine does a similar job to the routine of the same name in the BBC
; Master version of Elite, but the code is significantly different.
;
; ******************************************************************************

.DIALS

 LDA drawingBitplane    ; If the drawing bitplane is 1, jump to dial1 so we only
 BNE dial1              ; update the bar indicators every other frame, to save
                        ; time

 LDA #HI(nameBuffer0+23*32+2)   ; Set SC(1 0) to the address of the third tile
 STA SC+1                       ; on tile row 23 in nametable buffer 0, which is
 LDA #LO(nameBuffer0+23*32+2)   ; the leftmost tile in the fuel indicator at the
 STA SC                         ; top-left corner of the dashboard

 LDA #0                 ; Set the indicator's safe range from 0 to 255 by
 STA K                  ; setting K to 0 and K+1 to 255, so all values are safe
 LDA #255
 STA K+1

 LDA QQ14               ; Draw the fuel level indicator using a range of 0-63,
 JSR DILX+2             ; and increment SC to point to the next indicator (the
                        ; forward shield)

 LDA #8                 ; Set the indicator's safe range from 8 to 255 by
 STA K                  ; setting K to 8 and K+1 to 255, so all values are safe
 LDA #255               ; except those below 8, which are dangerous
 STA K+1

 LDA FSH                ; Draw the forward shield indicator using a range of
 JSR DILX               ; 0-255, and increment SC to point to the next indicator
                        ; (the aft shield)

 LDA ASH                ; Draw the aft shield indicator using a range of 0-255,
 JSR DILX               ; and increment SC to point to the next indicator (the
                        ; energy banks)

 LDA ENERGY             ; Draw the energy bank indicator using a range of 0-255,
 JSR DILX               ; and increment SC to point to the next indicator (the
                        ; cabin temperature)

 LDA #0                 ; Set the indicator's safe range from 0 to 23 by
 STA K                  ; setting K to 0 and K+1 to 24, so values from 0 to 23
 LDA #24                ; are safe, while values of 24 or more are dangerous
 STA K+1

 LDA CABTMP             ; Draw the cabin temperature indicator using a range of
 JSR DILX               ; 0-255, and increment SC to point to the next indicator
                        ; (the laser temperature)

 LDA GNTMP              ; Draw the laser temperature indicator using a range of
 JSR DILX               ; 0-255

 LDA #HI(nameBuffer0+27*32+28)  ; Set SC(1 0) to the address of the 28th tile
 STA SC+1                       ; on tile row 27 in nametable buffer 0, which is
 LDA #LO(nameBuffer0+27*32+28)  ; the leftmost tile in the speed indicator in
 STA SC                         ; the bottom-right corner of the dashboard

 LDA #0                 ; Set the indicator's safe range from 0 to 255 by
 STA K                  ; setting K to 0 and K+1 to 255, so all values are safe
 LDA #255
 STA K+1

 LDA DELTA              ; Fetch our ship's speed into A, in the range 0-40

 LSR A                  ; Set A = A / 2 + DELTA
 ADC DELTA              ;       = 1.5 * DELTA

 JSR DILX+2             ; Draw the speed level indicator using a range of 0-63,
                        ; and increment SC to point to the next indicator
                        ; (altitude)

 LDA #8                 ; Set the indicator's safe range from 8 to 255 by
 STA K                  ; setting K to 8 and K+1 to 255, so all values are safe
 LDA #255               ; except those below 8, which are dangerous
 STA K+1

 LDA ALTIT              ; Draw the altitude indicator using a range of 0-255
 JSR DILX

.dial1

                        ; We now set up sprite 10 to use for the ship status
                        ; indicator

 LDA #186+YPAL          ; Set the y-coordinate of sprite 10 to 186
 STA ySprite10

 LDA #206               ; Set the x-coordinate of sprite 10 to 206
 STA xSprite10

 JSR GetStatusCondition ; Set X to our ship's status condition (0 to 3)

 LDA conditionAttrs,X   ; Set the sprite's attributes to the corresponding
 STA attrSprite10       ; entry from the conditionAttrs table, so the correct
                        ; colour is set for the ship's status condition

 LDA conditionPatts,X   ; Set the pattern to the corresponding entry from the
 STA pattSprite10       ; conditionPatts table, so the correct pattern is used
                        ; for the ship's status condition

                        ; And finally we update the active missile indicator
                        ; and the square targeting reticle

 LDA QQ12               ; If we are docked then QQ12 is non-zero, so jump to
 BNE dial2              ; dial2 to hide the square targeting reticle in sprite 9

 LDA MSTG               ; If MSTG does not contain $FF then the active missile
 BPL dial4              ; has a target lock (and MSTG contains a slot number),
                        ; so jump to dial4 to show the square targeting reticle
                        ; in the middle of the laser sights

 LDA MSAR               ; If MSAR = 0 then the missile is not looking for a
 BEQ dial2              ; target, so jump to dial2 to hide the square targeting
                        ; reticle in sprite 9

                        ; We now flash the active missile indicator between
                        ; black and red, and flash the square targeting reticle
                        ; in sprite 9 on and off, to indicate that the missile
                        ; is searching for a target

 LDX NOMSL              ; Fetch the current number of missiles from NOMSL into X
                        ; (which is also the number of the active missile)

 LDY #109               ; Set Y = 109 to use as the pattern for the red missile
                        ; indicator

 LDA MCNT               ; Fetch the main loop counter and jump to dial3 if bit 3
 AND #%00001000         ; is set, which will be true half of the time, with the
 BNE dial3              ; bit being 0 for eight iterations around the main loop,
                        ; and 1 for the next eight iterations
                        ;
                        ; If we jump to dial3 then the indicator is shown in
                        ; red, and if we don't jump it is shown in black, so
                        ; this flashes the missile indicator between red and
                        ; black, changing the colour every eight iterations of
                        ; the main loop

 LDY #108               ; Set the pattern for the missile indicator at position
 JSR MSBAR_b6           ; X to 108, which is a black indicator

.dial2

 LDA #240               ; Hide sprite 9 (the square targeting reticle) by moving
 STA ySprite9           ; sprite 9 to y-coordinate 240, off the bottom of the
                        ; screen

 RTS                    ; Return from the subroutine

.dial3

 JSR MSBAR_b6           ; Set the pattern for the missile indicator at position
                        ; X to pattern Y, which we set to 109 above, so this
                        ; sets the indicator to red

.dial4
                        ; If we get here then our missile is targeted, so show
                        ; the square targeting reticle in the middle of the
                        ; laser sights

 LDA #248               ; Set the pattern for sprite 9 to 248, which is a square
 STA pattSprite9        ; outline

 LDA #%00000001         ; Set the attributes for sprite 9 as follows:
 STA attrSprite9        ;
                        ;   * Bits 0-1    = sprite palette 1
                        ;   * Bit 5 clear = show in front of background
                        ;   * Bit 6 clear = do not flip horizontally
                        ;   * Bit 7 clear = do not flip vertically

 LDA #126               ; Set the x-coordinate for sprite 9 to 126
 STA xSprite9

 LDA #83+YPAL           ; Set the y-coordinate for sprite 9 to 126
 STA ySprite9

 RTS                    ; Return from the subroutine

; ******************************************************************************
;
;       Name: conditionAttrs
;       Type: Variable
;   Category: Dashboard
;    Summary: Sprite attributes for the status condition indicator on the
;             dashboard
;
; ******************************************************************************

.conditionAttrs

 EQUB %00100001         ; Attributes for sprite when condition is docked:
                        ;
                        ;   * Bits 0-1    = sprite palette 1
                        ;   * Bit 5 set   = show behind background
                        ;   * Bit 6 clear = do not flip horizontally
                        ;   * Bit 7 clear = do not flip vertically

 EQUB %00100000         ; Attributes for sprite when condition is green:
                        ;
                        ;   * Bits 0-1    = sprite palette 0
                        ;   * Bit 5 set   = show behind background
                        ;   * Bit 6 clear = do not flip horizontally
                        ;   * Bit 7 clear = do not flip vertically

 EQUB %00100010         ; Attributes for sprite when condition is yellow
                        ;
                        ;   * Bits 0-1    = sprite palette 2
                        ;   * Bit 5 set   = show behind background
                        ;   * Bit 6 clear = do not flip horizontally
                        ;   * Bit 7 clear = do not flip vertically

 EQUB %00100010         ; Attributes for sprite when condition is red
                        ;
                        ;   * Bits 0-1    = sprite palette 2
                        ;   * Bit 5 set   = show behind background
                        ;   * Bit 6 clear = do not flip horizontally
                        ;   * Bit 7 clear = do not flip vertically

; ******************************************************************************
;
;       Name: conditionPatts
;       Type: Variable
;   Category: Dashboard
;    Summary: Pattern numbers for the status condition indicator on the
;             dashboard
;
; ******************************************************************************

.conditionPatts

 EQUB 249               ; Docked

 EQUB 250               ; Green

 EQUB 250               ; Yellow

 EQUB 249               ; Red

; ******************************************************************************
;
;       Name: MSBAR_b6
;       Type: Subroutine
;   Category: Dashboard
;    Summary: Draw a specific indicator in the dashboard's missile bar
;
; ------------------------------------------------------------------------------
;
; Arguments:
;
;   X                   The number of the missile indicator to update (counting
;                       from bottom-right to bottom-left, then top-left and
;                       top-right, so indicator NOMSL is the top-right
;                       indicator)
;
;   Y                   The pattern number for the new missile indicator:
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
; ------------------------------------------------------------------------------
;
; Returns:
;
;   X                   X is preserved
;
;   Y                   Y is set to 0
;
; ******************************************************************************

.MSBAR_b6

 TYA                    ; Store the pattern number on the stack so we can
 PHA                    ; retrieve it later

 LDY missileNames_b6,X  ; Set Y to the X-th entry from the missileNames table,
                        ; so Y is the offset of missile X's indicator in the
                        ; nametable buffer, from the start of row 22

 PLA                    ; Set the nametable buffer entry to the pattern number
 STA nameBuffer0+22*32,Y

 LDY #0                 ; Set Y = 0 to return from the subroutine (so this
                        ; routine behaves like the same routine in the other
                        ; versions of Elite)

 RTS                    ; Return from the subroutine

; ******************************************************************************
;
;       Name: missileNames_b6
;       Type: Variable
;   Category: Dashboard
;    Summary: Tile numbers for the four missile indicators on the dashboard, as
;             offsets from the start of tile row 22
;
; ------------------------------------------------------------------------------
;
; The active missile (i.e. the one that is armed and fired first) is the one
; with the highest number, so missile 4 (top-left) will be armed before missile
; 3 (top-right), and so on.
;
; ******************************************************************************

.missileNames_b6

 EQUB 0                 ; Missile numbers are from 1 to 4, so this value is
                        ; never used

 EQUB 95                ; Missile 1 (bottom-right)

 EQUB 94                ; Missile 2 (bottom-left)

 EQUB 63                ; Missile 3 (top-right)

 EQUB 62                ; Missile 4 (top-left)

; ******************************************************************************
;
;       Name: SetEquipmentSprite
;       Type: Subroutine
;   Category: Equipment
;    Summary: Set up the sprites in the sprite buffer for a specific bit of
;             equipment to show on our Cobra Mk III on the Equip Ship screen
;
; ------------------------------------------------------------------------------
;
; Arguments:
;
;   X                   The number of sprites to set up for the equipment
;
;   Y                   The offset into the equipSprites table where we can find
;                       the data for the first sprite to set up for this piece
;                       of equipment (i.e. the equipment sprite number * 4)
;
; ******************************************************************************

.SetEquipmentSprite

 LDA #0                 ; Set A = 0 to set as the laser offset in SetLaserSprite
                        ; so we just draw the equipment's sprites

                        ; Fall through into SetLaserSprite to draw the sprites
                        ; for the equipment specified in Y

; ******************************************************************************
;
;       Name: SetLaserSprite
;       Type: Subroutine
;   Category: Equipment
;    Summary: Set up the sprites in the sprite buffer for a specific laser to
;             show on our Cobra Mk III on the Equip Ship screen
;
; ------------------------------------------------------------------------------
;
; Arguments:
;
;   A                   The pattern number for the first sprite for this type of
;                       laser, minus 0:
;
;                           * 0 (for pattern 140) for the mining laser
;
;                           * 4 (for pattern 144) for the beam laser
;
;                           * 8 (for pattern 148) for the pulse laser
;
;                           * 12 (for pattern 152) for the military laser
;
;                       This routine is used to set up equipment sprites for all
;                       types of equipment, so this should be set to 0 for
;                       setting up non-laser sprites
;
;   X                   The number of sprites to set up for the equipment
;
;   Y                   The offset into the equipSprites table where we can find
;                       the data for the first sprite to set up for this piece
;                       of equipment (i.e. the equipment sprite number * 4)
;
; ******************************************************************************

.SetLaserSprite

 STA V                  ; Set V to the sprite offset (which is only used for
                        ; laser sprites)

 STX V+1                ; Set V+1 to the number of sprites to set up

.slas1

 LDA equipSprites+3,Y   ; Extract the offset into the sprite buffer of the
 AND #%11111100         ; sprite we need to set up, which is in bits 2 to 7 of
 TAX                    ; byte #3 for this piece of equipment in the
                        ; equipSprites table, and store it in X
                        ;
                        ; Because bits 0 and 1 are cleared, the offset is a
                        ; multiple of four, which means we can use X as an
                        ; index into the sprite buffer as each sprite in the
                        ; sprite buffer takes up four bytes
                        ;
                        ; In other words, to set up this sprite in the sprite
                        ; buffer, we need to write the sprite's configuration
                        ; into xSprite0 + X, ySprite0 + X, pattSprite0 + X and
                        ; attrSprite0 + X

 LDA equipSprites+3,Y   ; Extract the palette number to use for this sprite,
 AND #%00000011         ; which is in bits 0 to 1 of byte #3 for this piece of
 STA T                  ; equipment in the equipSprites table

 LDA equipSprites,Y     ; Extract the vertical and horizontal flip flags from
 AND #%11000000         ; bits 7 and 6 of byte #0 for this piece of equipment
                        ; in the equipSprites table, into A

 ORA T                  ; Set bits 0 and 1 of A to the palette number that we
                        ; extracted into T above

 STA attrSprite0,X      ; Set the attributes for our sprite as follows:
                        ;
                        ;   * Bits 0-1 = sprite palette in T
                        ;   * Bit 5 clear = show in front of background
                        ;   * Bit 6 = bit 6 from byte #3 in equipSprites
                        ;   * Bit 7 = bit 7 from byte #3 in equipSprites
                        ;
                        ; So the sprite's attributes are set correctly

 LDA equipSprites,Y     ; Extract the sprite's pattern number from bits 0 to 5
 AND #%00111111         ; of byte #0 for this piece of equipment in the
 CLC                    ; equipSprites table and add 140
 ADC #140

 ADC V                  ; If this is a laser sprite then V will be the offset
                        ; that we add to 140 to get the correct pattern for the
                        ; specific laser type, so we also add this to A (if this
                        ; is not a laser then V will be 0)

 STA pattSprite0,X      ; Set the pattern number for our sprite to the result
                        ; in A

 LDA equipSprites+1,Y   ; Set our sprite's x-coordinate to byte #1 for this
 STA xSprite0,X         ; piece of equipment in the equipSprites table

 LDA equipSprites+2,Y   ; Set our sprite's y-coordinate to byte #2 for this
 STA ySprite0,X         ; piece of equipment in the equipSprites table

 INY                    ; Increment the index in Y to point to the next entry
 INY                    ; in the equipSprites table, in case there are any more
 INY                    ; sprites to set up
 INY

 DEC V+1                ; Decrement the sprite counter in V+1

 BNE slas1              ; Loop back to set up the next sprite until we have set
                        ; up V+1 sprites for this piece of equipment

 RTS                    ; Return from the subroutine

; ******************************************************************************
;
;       Name: GetLaserPattern
;       Type: Subroutine
;   Category: Equipment
;    Summary: Get the pattern number for a specific laser's equipment sprite
;
; ------------------------------------------------------------------------------
;
; Arguments:
;
;   X                   The laser power
;
; ------------------------------------------------------------------------------
;
; Returns:
;
;   A                   The pattern number for the first sprite for this type of
;                       laser, minus 140, so we return:
;
;                           * 0 (for pattern 140) for the mining laser
;
;                           * 4 (for pattern 144) for the beam laser
;
;                           * 8 (for pattern 148) for the pulse laser
;
;                           * 12 (for pattern 152) for the military laser
;
; ******************************************************************************

.GetLaserPattern

 LDA #0                 ; Set A to the return value for pattern 140 (for the
                        ; mining laser)

 CPX #Armlas            ; If the laser power in X is equal to a military laser,
 BEQ glsp3              ; jump to glsp3 to the return value for pattern 152

 CPX #POW+128           ; If the laser power in X is equal to a beam laser,
 BEQ glsp2              ; jump to glsp2 to the return value for pattern 144

 CPX #Mlas              ; If the laser power in X is equal to a mining laser,
 BNE glsp1              ; jump to glsp2 to the return value for pattern 140

 LDA #8                 ; If we get here then this must be a pulse laser, so
                        ; set A to the return value for pattern 148

.glsp1

 RTS                    ; Return from the subroutine

.glsp2

 LDA #4                 ; This is a beam laser, so set A to the return value for
                        ; pattern 145

 RTS                    ; Return from the subroutine

.glsp3

 LDA #12                ; This is a military laser, so set A to the return value
                        ; for pattern 152

 RTS                    ; Return from the subroutine

; ******************************************************************************
;
;       Name: equipSprites
;       Type: Variable
;   Category: Equipment
;    Summary: Sprite configuration data for the sprites that show the equipment
;             fitted to our Cobra Mk III on the Equip Ship screen
;  Deep dive: Sprite usage in NES Elite
;
; ------------------------------------------------------------------------------
;
; Each equipment sprite is described by four entries in the table, as follows:
;
;   * Byte #0: %vhyyyyyy, where:
;
;       * %v is the vertical flip flag (0 = no flip, 1 = flip vertically)
;
;       * %h is the horizontal flip flag (0 = no flip, 1 = flip horizontally)
;
;       * %yyyyyy is the sprite's pattern number, which is added to 140 to give
;         the final pattern number
;
;   * Byte #1: Pixel x-coordinate of the sprite's position on the Cobra Mk III
;
;   * Byte #2: Pixel y-coordinate of the sprite's position on the Cobra Mk III
;
;   * Byte #3: %xxxxxxyy, where:
;
;       * %xxxxxx00 is the offset of the sprite to use in the sprite buffer
;
;       * %yy is the sprite palette (0 to 3)
;
; ******************************************************************************

.equipSprites

                        ; Equipment sprite 0: E.C.M. (1 of 3)

 EQUB %00011111         ; v = 0, h = 0, pattern = 31
 EQUB 85                ; x-coordinate = 85
 EQUB 182 + YPAL        ; y-coordinate = 182
 EQUB %00010100         ; sprite number = 5, sprite palette = 0

                        ; Equipment sprite 1: E.C.M. (2 of 3)

 EQUB %00100000         ; v = 0, h = 0, pattern = 32
 EQUB 156               ; x-coordinate = 156
 EQUB 156 + YPAL        ; y-coordinate = 156
 EQUB %00011000         ; sprite number = 6, sprite palette = 0

                        ; Equipment sprite 2: E.C.M. (3 of 3)

 EQUB %00100001         ; v = 0, h = 0, pattern = 33
 EQUB 156               ; x-coordinate = 156
 EQUB 164 + YPAL        ; y-coordinate = 164
 EQUB %00011100         ; sprite number = 7, sprite palette = 0

                        ; Equipment sprite 3: Front laser (1 of 2)

 EQUB %00000111         ; v = 0, h = 0, pattern = 7
 EQUB 68                ; x-coordinate = 68
 EQUB 161 + YPAL        ; y-coordinate = 161
 EQUB %00100000         ; sprite number = 8, sprite palette = 0

                        ; Equipment sprite 4: Front laser (2 of 2)

 EQUB %00001010         ; v = 0, h = 0, pattern = 10
 EQUB 171               ; x-coordinate = 171
 EQUB 172 + YPAL        ; y-coordinate = 172
 EQUB %00100100         ; sprite number = 9, sprite palette = 0

                        ; Equipment sprite 5: Left laser (1 of 2), non-military

 EQUB %00001001         ; v = 0, h = 0, pattern = 9
 EQUB 20                ; x-coordinate = 20
 EQUB 198 + YPAL        ; y-coordinate = 198
 EQUB %00101000         ; sprite number = 10, sprite palette = 0

                        ; Equipment sprite 6: Left laser (2 of 2), non-military

 EQUB %00001001         ; v = 0, h = 0, pattern = 9
 EQUB 124               ; x-coordinate = 124
 EQUB 170 + YPAL        ; y-coordinate = 170
 EQUB %00101100         ; sprite number = 11, sprite palette = 0

                        ; Equipment sprite 7: Right laser (1 of 2), non-military

 EQUB %01001001         ; v = 0, h = 1, pattern = 9
 EQUB 116               ; x-coordinate = 116
 EQUB 198 + YPAL        ; y-coordinate = 198
 EQUB %00110000         ; sprite number = 12, sprite palette = 0

                        ; Equipment sprite 8: Right laser (2 of 2), non-military

 EQUB %01001001         ; v = 0, h = 1, pattern = 9
 EQUB 220               ; x-coordinate = 220
 EQUB 170 + YPAL        ; y-coordinate = 170
 EQUB %00110100         ; sprite number = 13, sprite palette = 0

                        ; Equipment sprite 9: Rear laser (1 of 1)

 EQUB %10000111         ; v = 1, h = 0, pattern = 7
 EQUB 68                ; x-coordinate = 68
 EQUB 206 + YPAL        ; y-coordinate = 206
 EQUB %01110100         ; sprite number = 29, sprite palette = 0

                        ; Equipment sprite 10: Left military laser (1 of 2)

 EQUB %00010101         ; v = 0, h = 0, pattern = 21
 EQUB 16                ; x-coordinate = 16
 EQUB 198 + YPAL        ; y-coordinate = 198
 EQUB %00101000         ; sprite number = 10, sprite palette = 0

                        ; Equipment sprite 11: Left military laser (2 of 2)

 EQUB %00010101         ; v = 0, h = 0, pattern = 21
 EQUB 121               ; x-coordinate = 121
 EQUB 170 + YPAL        ; y-coordinate = 170
 EQUB %00101100         ; sprite number = 11, sprite palette = 0

                        ; Equipment sprite 12: Right military laser (1 of 2)

 EQUB %01010101         ; v = 0, h = 1, pattern = 21
 EQUB 118               ; x-coordinate = 118
 EQUB 198 + YPAL        ; y-coordinate = 198
 EQUB %00110000         ; sprite number = 12, sprite palette = 0

                        ; Equipment sprite 13: Right military laser (2 of 2)

 EQUB %01010101         ; v = 0, h = 1, pattern = 21
 EQUB 222               ; x-coordinate = 222
 EQUB 170 + YPAL        ; y-coordinate = 170
 EQUB %00110100         ; sprite number = 13, sprite palette = 0

                        ; Equipment sprite 14: Fuel scoops (1 of 2)

 EQUB %00011110         ; v = 0, h = 0, pattern = 30
 EQUB 167               ; x-coordinate = 167
 EQUB 185 + YPAL        ; y-coordinate = 185
 EQUB %00111101         ; sprite number = 15, sprite palette = 1

                        ; Equipment sprite 15: Fuel scoops (2 of 2)

 EQUB %01011110         ; v = 0, h = 1, pattern = 30
 EQUB 175               ; x-coordinate = 175
 EQUB 185 + YPAL        ; y-coordinate = 185
 EQUB %01000001         ; sprite number = 16, sprite palette = 1

                        ; Equipment sprite 16: Naval energy unit (1 of 2)

 EQUB %00011010         ; v = 0, h = 0, pattern = 26
 EQUB 79                ; x-coordinate = 79
 EQUB 196 + YPAL        ; y-coordinate = 196
 EQUB %10101100         ; sprite number = 43, sprite palette = 0

                        ; Equipment sprite 17: Naval energy unit (2 of 2)

 EQUB %00011011         ; v = 0, h = 0, pattern = 27
 EQUB 79                ; x-coordinate = 79
 EQUB 196 + YPAL        ; y-coordinate = 196
 EQUB %10110001         ; sprite number = 44, sprite palette = 1

                        ; Equipment sprite 18: Standard energy unit (1 of 2)

 EQUB %00011010         ; v = 0, h = 0, pattern = 26
 EQUB 56                ; x-coordinate = 56
 EQUB 196 + YPAL        ; y-coordinate = 196
 EQUB %01000100         ; sprite number = 17, sprite palette = 0

                        ; Equipment sprite 19: Standard energy unit (2 of 2)

 EQUB %00011011         ; v = 0, h = 0, pattern = 27
 EQUB 56                ; x-coordinate = 56
 EQUB 196 + YPAL        ; y-coordinate = 196
 EQUB %01001001         ; sprite number = 18, sprite palette = 1

                        ; Equipment sprite 20: Missile 1 (1 of 2)

 EQUB %00000000         ; v = 0, h = 0, pattern = 0
 EQUB 29                ; x-coordinate = 29
 EQUB 187 + YPAL        ; y-coordinate = 187
 EQUB %01001101         ; sprite number = 19, sprite palette = 1

                        ; Equipment sprite 21: Missile 1 (2 of 2)

 EQUB %00000001         ; v = 0, h = 0, pattern = 1
 EQUB 208               ; x-coordinate = 208
 EQUB 176 + YPAL        ; y-coordinate = 176
 EQUB %01010001         ; sprite number = 20, sprite palette = 1

                        ; Equipment sprite 22: Missile 2 (1 of 2)

 EQUB %01000000         ; v = 0, h = 1, pattern = 0
 EQUB 108               ; x-coordinate = 108
 EQUB 187 + YPAL        ; y-coordinate = 187
 EQUB %01010101         ; sprite number = 21, sprite palette = 1

                        ; Equipment sprite 23: Missile 2 (2 of 2)

 EQUB %01000001         ; v = 0, h = 1, pattern = 1
 EQUB 136               ; x-coordinate = 136
 EQUB 176 + YPAL        ; y-coordinate = 176
 EQUB %01011001         ; sprite number = 22, sprite palette = 1

                        ; Equipment sprite 24: Missile 3 (1 of 2)

 EQUB %00000000         ; v = 0, h = 0, pattern = 0
 EQUB 22                ; x-coordinate = 22
 EQUB 192 + YPAL        ; y-coordinate = 192
 EQUB %01011101         ; sprite number = 23, sprite palette = 1

                        ; Equipment sprite 25: Missile 3 (2 of 2)

 EQUB %00000001         ; v = 0, h = 0, pattern = 1
 EQUB 214               ; x-coordinate = 214
 EQUB 175 + YPAL        ; y-coordinate = 175
 EQUB %01100001         ; sprite number = 24, sprite palette = 1

                        ; Equipment sprite 26: Missile 4 (1 of 2)

 EQUB %01000000         ; v = 0, h = 1, pattern = 0
 EQUB 115               ; x-coordinate = 115
 EQUB 192 + YPAL        ; y-coordinate = 192
 EQUB %01100101         ; sprite number = 25, sprite palette = 1

                        ; Equipment sprite 27: Missile 4 (2 of 2)

 EQUB %01000001         ; v = 0, h = 1, pattern = 1
 EQUB 130               ; x-coordinate = 130
 EQUB 175 + YPAL        ; y-coordinate = 175
 EQUB %01101001         ; sprite number = 26, sprite palette = 1

                        ; Equipment sprite 28: Energy bomb (1 of 3)

 EQUB %00010111         ; v = 0, h = 0, pattern = 23
 EQUB 64                ; x-coordinate = 64
 EQUB 206 + YPAL        ; y-coordinate = 206
 EQUB %01101100         ; sprite number = 27, sprite palette = 0

                        ; Equipment sprite 29: Energy bomb (2 of 3)

 EQUB %00011000         ; v = 0, h = 0, pattern = 24
 EQUB 72                ; x-coordinate = 72
 EQUB 206 + YPAL        ; y-coordinate = 206
 EQUB %01110000         ; sprite number = 28, sprite palette = 0

                        ; Equipment sprite 30: Energy bomb (3 of 3)

 EQUB %00011001         ; v = 0, h = 0, pattern = 25
 EQUB 68                ; x-coordinate = 68
 EQUB 206 + YPAL        ; y-coordinate = 206
 EQUB %00111010         ; sprite number = 14, sprite palette = 2

                        ; Equipment sprite 31: Large cargo bay (1 of 2)

 EQUB %00000010         ; v = 0, h = 0, pattern = 2
 EQUB 153               ; x-coordinate = 153
 EQUB 184 + YPAL        ; y-coordinate = 184
 EQUB %01111000         ; sprite number = 30, sprite palette = 0

                        ; Equipment sprite 32: Large cargo bay (2 of 2)

 EQUB %01000010         ; v = 0, h = 1, pattern = 2
 EQUB 188               ; x-coordinate = 188
 EQUB 184 + YPAL        ; y-coordinate = 184
 EQUB %01111100         ; sprite number = 31, sprite palette = 0

                        ; Equipment sprite 33: Escape pod (1 of 1)

 EQUB %00011100         ; v = 0, h = 0, pattern = 28
 EQUB 79                ; x-coordinate = 79
 EQUB 178 + YPAL        ; y-coordinate = 178
 EQUB %10000000         ; sprite number = 32, sprite palette = 0

                        ; Equipment sprite 34: Docking computer (1 of 8)

 EQUB %00000011         ; v = 0, h = 0, pattern = 3
 EQUB 52                ; x-coordinate = 52
 EQUB 172 + YPAL        ; y-coordinate = 172
 EQUB %10000100         ; sprite number = 33, sprite palette = 0

                        ; Equipment sprite 35: Docking computer (2 of 8)

 EQUB %00000100         ; v = 0, h = 0, pattern = 4
 EQUB 60                ; x-coordinate = 60
 EQUB 172 + YPAL        ; y-coordinate = 172
 EQUB %10001000         ; sprite number = 34, sprite palette = 0

                        ; Equipment sprite 36: Docking computer (3 of 8)

 EQUB %00000101         ; v = 0, h = 0, pattern = 5
 EQUB 52                ; x-coordinate = 52
 EQUB 180 + YPAL        ; y-coordinate = 180
 EQUB %10001100         ; sprite number = 35, sprite palette = 0

                        ; Equipment sprite 37: Docking computer (4 of 8)

 EQUB %00000110         ; v = 0, h = 0, pattern = 6
 EQUB 60                ; x-coordinate = 60
 EQUB 180 + YPAL        ; y-coordinate = 180
 EQUB %10010000         ; sprite number = 36, sprite palette = 0

                        ; Equipment sprite 38: Docking computer (5 of 8)

 EQUB %01000100         ; v = 0, h = 1, pattern = 4
 EQUB 178               ; x-coordinate = 178
 EQUB 156 + YPAL        ; y-coordinate = 156
 EQUB %10010100         ; sprite number = 37, sprite palette = 0

                        ; Equipment sprite 39: Docking computer (6 of 8)

 EQUB %01000011         ; v = 0, h = 1, pattern = 3
 EQUB 186               ; x-coordinate = 186
 EQUB 156 + YPAL        ; y-coordinate = 156
 EQUB %10011000         ; sprite number = 38, sprite palette = 0

                        ; Equipment sprite 40: Docking computer (7 of 8)

 EQUB %01000110         ; v = 0, h = 1, pattern = 6
 EQUB 178               ; x-coordinate = 178
 EQUB 164 + YPAL        ; y-coordinate = 164
 EQUB %10011100         ; sprite number = 39, sprite palette = 0

                        ; Equipment sprite 41: Docking computer (8 of 8)

 EQUB %01000101         ; v = 0, h = 1, pattern = 5
 EQUB 186               ; x-coordinate = 186
 EQUB 164 + YPAL        ; y-coordinate = 164
 EQUB %10100000         ; sprite number = 40, sprite palette = 0

                        ; Equipment sprite 42: Galactic hyperdrive (1 of 2)

 EQUB %00011101         ; v = 0, h = 0, pattern = 29
 EQUB 64                ; x-coordinate = 64
 EQUB 190 + YPAL        ; y-coordinate = 190
 EQUB %10100110         ; sprite number = 41, sprite palette = 2

                        ; Equipment sprite 43: Galactic hyperdrive (1 of 2)

 EQUB %01011101         ; v = 0, h = 1, pattern = 29
 EQUB 74                ; x-coordinate = 74
 EQUB 190 + YPAL        ; y-coordinate = 190
 EQUB %10101010         ; sprite number = 42, sprite palette = 2

; ******************************************************************************
;
;       Name: DrawEquipment
;       Type: Subroutine
;   Category: Equipment
;    Summary: Draw the currently fitted equipment onto the Cobra Mk III image on
;             the Equip Ship screen
;
; ******************************************************************************

.DrawEquipment

 JSR WaitForNMI         ; Wait until the next NMI interrupt has passed (i.e. the
                        ; next VBlank)

 LDA ECM                ; If we do not have E.C.M. fitted, jump to dreq1 to move
 BEQ dreq1              ; on to the next piece of equipment

 LDY #0                 ; Set Y = 0 so we set up the sprites using data from
                        ; sprite 0 onwards in the equipSprites table

 LDX #3                 ; Set X = 3 so we draw three sprites, i.e. equipment
                        ; sprites 0 to 2 from the equipSprites table

 JSR SetEquipmentSprite ; Set up the sprites in the sprite buffer to show the
                        ; E.C.M. on our Cobra Mk III

.dreq1

 LDX LASER              ; If we do not have a laser fitted to the front view,
 BEQ dreq2              ; jump to dreq2 to move on to the next piece of
                        ; equipment

 JSR GetLaserPattern    ; Set A to the pattern number of the laser's equipment
                        ; sprite for the type of laser fitted, to pass to the
                        ; SetLaserSprite routine

 LDY #3 * 4             ; Set Y = 3 * 4 so we set up the sprites using data
                        ; from sprite 3 onwards in the equipSprites table

 LDX #2                 ; Set X = 2 so we draw two sprites, i.e. equipment
                        ; sprites 3 and 4 from the equipSprites table

 JSR SetLaserSprite     ; Set up the sprites in the sprite buffer to show the
                        ; front view laser on our Cobra Mk III

 JMP dreq2              ; This instruction has no effect (presumably it is left
                        ; over from code that was later removed)

.dreq2

 LDX LASER+1            ; If we do not have a laser fitted to the rear view,
 BEQ dreq3              ; jump to dreq3 to move on to the next piece of
                        ; equipment

 JSR GetLaserPattern    ; Set A to the pattern number of the laser's equipment
                        ; sprite for the type of laser fitted, to pass to the
                        ; SetLaserSprite routine

 LDY #9 * 4             ; Set Y = 9 * 4 so we set up the sprites using data
                        ; from sprite 9 onwards in the equipSprites table

 LDX #1                 ; Set X = 1 so we draw one sprite, i.e. equipment
                        ; sprite 9 from the equipSprites table

 JSR SetLaserSprite     ; Set up the sprites in the sprite buffer to show the
                        ; rear view laser on our Cobra Mk III

 JMP dreq3              ; This instruction has no effect (presumably it is left
                        ; over from code that was later removed)

.dreq3

 LDX LASER+2            ; If we do not have a laser fitted to the left view,
 BEQ dreq5              ; jump to dreq5 to move on to the next piece of
                        ; equipment

 CPX #Armlas            ; If the laser fitted to the left view is a military
 BEQ dreq4              ; laser, jump to dreq4 to show the laser using
                        ; equipment sprites 10 and 11

 JSR GetLaserPattern    ; Set A to the pattern number of the laser's equipment
                        ; sprite for the type of laser fitted, to pass to the
                        ; SetLaserSprite routine

 LDY #5 * 4             ; Set Y = 5 * 4 so we set up the sprites using data
                        ; from sprite 5 onwards in the equipSprites table

 LDX #2                 ; Set X = 2 so we draw two sprites, i.e. equipment
                        ; sprites 5 and 6 from the equipSprites table

 JSR SetLaserSprite     ; Set up the sprites in the sprite buffer to show the
                        ; left view laser on our Cobra Mk III

 JMP dreq5              ; Jump to dreq5 to move on to the next piece of
                        ; equipment

.dreq4

 LDY #10 * 4            ; Set Y = 10 * 4 so we set up the sprites using data
                        ; from sprite 10 onwards in the equipSprites table

 LDX #2                 ; Set X = 2 so we draw two sprites, i.e. equipment
                        ; sprites 10 and 11 from the equipSprites table

 JSR SetEquipmentSprite ; Set up the sprites in the sprite buffer to show the
                        ; left view military laser on our Cobra Mk III

.dreq5

 LDX LASER+3            ; If we do not have a laser fitted to the right view,
 BEQ dreq7              ; jump to dreq7 to move on to the next piece of
                        ; equipment

 CPX #Armlas            ; If the laser fitted to the left view is a military
 BEQ dreq6              ; laser, jump to dreq6 to show the laser using
                        ; equipment sprites 12 and 13

 JSR GetLaserPattern    ; Set A to the pattern number of the laser's equipment
                        ; sprite for the type of laser fitted, to pass to the
                        ; SetLaserSprite routine

 LDY #7 * 4             ; Set Y = 7 * 4 so we set up the sprites using data
                        ; from sprite 7 onwards in the equipSprites table

 LDX #2                 ; Set X = 2 so we draw two sprites, i.e. equipment
                        ; sprites 7 and 8 from the equipSprites table

 JSR SetLaserSprite     ; Set up the sprites in the sprite buffer to show the
                        ; right view laser on our Cobra Mk III

 JMP dreq7              ; Jump to dreq7 to move on to the next piece of
                        ; equipment

.dreq6

 LDY #12 * 4            ; Set Y = 12 * 4 so we set up the sprites using data
                        ; from sprite 12 onwards in the equipSprites table

 LDX #2                 ; Set X = 2 so we draw two sprites, i.e. equipment
                        ; sprites 12 and 13 from the equipSprites table

 JSR SetEquipmentSprite ; Set up the sprites in the sprite buffer to show the
                        ; right view military laser on our Cobra Mk III

.dreq7

 LDA BST                ; If we do not have fuel scoops fitted, jump to dreq8 to
 BEQ dreq8              ; move on to the next piece of equipment

 LDY #14 * 4            ; Set Y = 14 * 4 so we set up the sprites using data
                        ; from sprite 14 onwards in the equipSprites table

 LDX #2                 ; Set X = 2 so we draw two sprites, i.e. equipment
                        ; sprites 14 and 15 from the equipSprites table

 JSR SetEquipmentSprite ; Set up the sprites in the sprite buffer to show the
                        ; fuel scoops on our Cobra Mk III

.dreq8

 LDA ENGY               ; If we do not have an energy unit fitted, jump to
 BEQ dreq10             ; dreq10 to move on to the next piece of equipment

 LSR A                  ; If ENGY is 2 or more, then we have the naval energy
 BNE dreq9              ; unit fitted, to jump to dreq9 to display the four
                        ; sprites for the naval version

 LDY #18 * 4            ; Set Y = 18 * 4 so we set up the sprites using data
                        ; from sprite 18 onwards in the equipSprites table

 LDX #2                 ; Set X = 2 so we draw two sprites, i.e. equipment
                        ; sprites 18 and 19 from the equipSprites table

 JSR SetEquipmentSprite ; Set up the sprites in the sprite buffer to show the
                        ; standard energy unit on our Cobra Mk III

 JMP dreq10             ; Jump to dreq10 to move on to the next piece of
                        ; equipment

.dreq9

                        ; The naval energy unit consists of the two sprites
                        ; for the standard energy unit (sprites 18 and 19),
                        ; plus two extra sprites (16 and 17)

 LDY #16 * 4            ; Set Y = 16 * 4 so we set up the sprites using data
                        ; from sprite 16 onwards in the equipSprites table

 LDX #4                 ; Set X = 4 so we draw four sprites, i.e. equipment
                        ; sprites 16 to 19 from the equipSprites table

 JSR SetEquipmentSprite ; Set up the sprites in the sprite buffer to show the
                        ; naval energy unit on our Cobra Mk III

.dreq10

 LDA NOMSL              ; If we do not have any missiles fitted, jump to dreq11
 BEQ dreq11             ; to move on to the next piece of equipment

                        ; We start by setting up the sprites for missile 2

 LDY #20 * 4            ; Set Y = 20 * 4 so we set up the sprites using data
                        ; from sprite 20 onwards in the equipSprites table

 LDX #2                 ; Set X = 2 so we draw two sprites, i.e. equipment
                        ; sprites 20 and 21 from the equipSprites table

 JSR SetEquipmentSprite ; Set up the sprites in the sprite buffer to show the
                        ; first missile on our Cobra Mk III

 LDA NOMSL              ; If the number of missiles in NOMSL is 1, jump to
 LSR A                  ; dreq11 to move on to the next piece of equipment
 BEQ dreq11

                        ; We now set up the sprites for missile 2

 LDY #22 * 4            ; Set Y = 22 * 4 so we set up the sprites using data
                        ; from sprite 22 onwards in the equipSprites table

 LDX #2                 ; Set X = 2 so we draw two sprites, i.e. equipment
                        ; sprites 22 and 23 from the equipSprites table

 JSR SetEquipmentSprite ; Set up the sprites in the sprite buffer to show the
                        ; second missile on our Cobra Mk III

 LDA NOMSL              ; If the number of missiles in NOMSL is 2, jump to
 CMP #2                 ; dreq11 to move on to the next piece of equipment
 BEQ dreq11

                        ; We now set up the sprites for missile 3

 LDY #24 * 4            ; Set Y = 24 * 4 so we set up the sprites using data
                        ; from sprite 24 onwards in the equipSprites table

 LDX #2                 ; Set X = 2 so we draw two sprites, i.e. equipment
                        ; sprites 24 and 25 from the equipSprites table

 JSR SetEquipmentSprite ; Set up the sprites in the sprite buffer to show the
                        ; third missile on our Cobra Mk III

 LDA NOMSL              ; If the number of missiles in NOMSL is not 4, then it
 CMP #4                 ; must be 3, so jump to dreq11 to move on to the next
 BNE dreq11             ; piece of equipment

                        ; We now set up the sprites for missile 4

 LDY #26 * 4            ; Set Y = 26 * 4 so we set up the sprites using data
                        ; from sprite 26 onwards in the equipSprites table

 LDX #2                 ; Set X = 2 so we draw two sprites, i.e. equipment
                        ; sprites 26 and 27 from the equipSprites table

 JSR SetEquipmentSprite ; Set up the sprites in the sprite buffer to show the
                        ; fourth missile on our Cobra Mk III

.dreq11

 LDA BOMB               ; If we do not have an energy bomb fitted, jump to
 BEQ dreq12             ; dreq12 to move on to the next piece of equipment

 LDY #28 * 4            ; Set Y = 28 * 4 so we set up the sprites using data
                        ; from sprite 28 onwards in the equipSprites table

 LDX #3                 ; Set X = 3 so we draw three sprites, i.e. equipment
                        ; sprites 28 to 30 from the equipSprites table

 JSR SetEquipmentSprite ; Set up the sprites in the sprite buffer to show the
                        ; energy bomb on our Cobra Mk III

.dreq12

 LDA CRGO               ; If we do not have a large cargo bay fitted (i.e. our
 CMP #37                ; cargo capacity in CRGO is not the larger capacity of
 BNE dreq13             ; 37), jump to dreq13 to move on to the next piece of
                        ; equipment

 LDY #31 * 4            ; Set Y = 31 * 4 so we set up the sprites using data
                        ; from sprite 31 onwards in the equipSprites table

 LDX #2                 ; Set X = 2 so we draw two sprites, i.e. equipment
                        ; sprites 31 and 32 from the equipSprites table

 JSR SetEquipmentSprite ; Set up the sprites in the sprite buffer to show the
                        ; large cargo bay on our Cobra Mk III

.dreq13

 LDA ESCP               ; If we do not have an escape pod fitted, jump to
 BEQ dreq14             ; dreq14 to move on to the next piece of equipment

 LDY #33 * 4            ; Set Y = 33 * 4 so we set up the sprites using data
                        ; from sprite 33 onwards in the equipSprites table

 LDX #1                 ; Set X = 1 so we draw one sprite, i.e. equipment
                        ; sprite 33 from the equipSprites table

 JSR SetEquipmentSprite ; Set up the sprites in the sprite buffer to show the
                        ; escape pod on our Cobra Mk III

.dreq14

 LDA DKCMP              ; If we do not have a docking computer fitted, jump to
 BEQ dreq15             ; dreq15 to move on to the next piece of equipment

 LDY #34 * 4            ; Set Y = 34 * 4 so we set up the sprites using data
                        ; from sprite 34 onwards in the equipSprites table

 LDX #8                 ; Set X = 8 so we draw eight sprites, i.e. equipment
                        ; sprites 34 to 41 from the equipSprites table

 JSR SetEquipmentSprite ; Set up the sprites in the sprite buffer to show the
                        ; docking computer on our Cobra Mk III

.dreq15

 LDA GHYP               ; If we do not have a galactic hyperdrive fitted, jump
 BEQ dreq16             ; to dreq16 to return from the subroutine, as we have
                        ; now drawn all our equipment

 LDY #42 * 4            ; Set Y = 42 * 4 so we set up the sprites using data
                        ; from sprite 24 onwards in the equipSprites table

 LDX #2                 ; Set X = 2 so we draw two sprites, i.e. equipment
                        ; sprites 42 and 43 from the equipSprites table

 JSR SetEquipmentSprite ; Set up the sprites in the sprite buffer to show the
                        ; galactic hyperdrive on our Cobra Mk III

.dreq16

 RTS                    ; Return from the subroutine

; ******************************************************************************
;
;       Name: ShowScrollText
;       Type: Subroutine
;   Category: Combat demo
;    Summary: Show a scroll text and start the combat demo
;  Deep dive: The NES combat demo
;
; ------------------------------------------------------------------------------
;
; Arguments:
;
;   A                   The scroll text to show:
;
;                         * 0 = show the first scroll text and start combat
;                               practice
;
;                         * 1 = show the second scroll text, including the time
;                               taken for combat practice
;
;                         * 2 = show the credits scroll text
;
; ******************************************************************************

.ShowScrollText

 PHA                    ; Store the value of A on the stack so we can retrieve
                        ; it later to check which scroll text to show

 LDA QQ11               ; If this is not the space view, then jump to scro1 to
 BNE scro1              ; set up the space view for the demo

 JSR ClearScanner       ; This is already the space view, so remove all ships
                        ; from the scanner and hide the scanner sprites

 JMP scro4              ; Jump to scro4 to move on to the scroll text part, as
                        ; the view is already set up

.scro1

                        ; If we get here then we need to set up the space view
                        ; for the demo

 JSR FadeToBlack_b3     ; Fade the screen to black over the next four VBlanks

 LDY #NOST              ; Set Y to the number of stardust particles in NOST
                        ; (which is 20 in the space view), so we can use it as a
                        ; counter as we set up the stardust below

 STY NOSTM              ; Set the number of stardust particles to NOST (which is
                        ; 20 for the normal space view)

 STY RAND+1             ; Set RAND+1 to NOST to seed the random number generator

 LDA nmiCounter         ; Set the random number seed to a fairly random state
 STA RAND               ; that's based on the NMI counter (which increments
                        ; every VBlank, so will be pretty random)

.scro2

 SETUP_PPU_FOR_ICON_BAR ; If the PPU has started drawing the icon bar, configure
                        ; the PPU to use nametable 0 and pattern table 0

                        ; We now set up the coordinates of stardust particle Y

 JSR DORND              ; Set A and X to random numbers

 ORA #8                 ; Set A so that it's at least 8

 STA SZ,Y               ; Store A in the Y-th particle's z_hi coordinate at
                        ; SZ+Y, so the particle appears in front of us

 STA ZZ                 ; Set ZZ to the particle's z_hi coordinate

 JSR DORND              ; Set A and X to random numbers

 STA SX,Y               ; Store A in the Y-th particle's x_hi coordinate at
                        ; SX+Y, so the particle appears in front of us

 JSR DORND              ; Set A and X to random numbers

 STA SY,Y               ; Store A in the Y-th particle's y_hi coordinate at
                        ; SY+Y, so the particle appears in front of us

 DEY                    ; Decrement the counter to point to the next particle of
                        ; stardust

 BNE scro2              ; Loop back to scro2 until we have randomised all the
                        ; stardust particles

 LDX #NOST              ; Set X to the maximum number of stardust particles, so
                        ; we loop through all the particles of stardust in the
                        ; following

 LDY #152               ; Set Y to the starting index in the sprite buffer, so
                        ; we start configuring from sprite 152 / 4 = 38 (as each
                        ; sprite in the buffer consists of four bytes)

.scro3

 SETUP_PPU_FOR_ICON_BAR ; If the PPU has started drawing the icon bar, configure
                        ; the PPU to use nametable 0 and pattern table 0

                        ; We now set up the sprite for stardust particle Y

 LDA #210               ; Set the sprite to use pattern number 210 for the
 STA pattSprite0,Y      ; largest particle of stardust (the stardust particle
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

 BNE scro3              ; Loop back until we have configured 20 sprites

 JSR STARS_b1           ; Call STARS1 to process the stardust for the front view

.scro4

 LDA #0                 ; Remove the laser from our ship, so we can't fire it
 STA LASER              ; during the scroll text

 STA QQ12               ; Set QQ12 = 0 to indicate that we are not docked

 LDA #$10               ; Clear the screen and set the view type in QQ11 to $10
 JSR ChangeToView_b0    ; (Space view with the normal font loaded)

 LDA #$FF               ; Set showIconBarPointer = $FF to indicate that we
 STA showIconBarPointer ; should show the icon bar pointer

 LDA #240               ; Set A to the y-coordinate that's just below the bottom
                        ; of the screen, so we can hide the sight sprites by
                        ; moving them off-screen

 STA ySprite5           ; Set the y-coordinates for the five laser sight sprites
 STA ySprite6           ; to 240, to move them off-screen
 STA ySprite7
 STA ySprite8
 STA ySprite9

                        ; We are going to draw the scroll text into the pattern
                        ; buffers, so now we calculate the addresses of the
                        ; first available tiles in the buffers

 LDA #0                 ; Set the high byte of SC(1 0) to 0
 STA SC+1

 LDA firstFreePattern   ; Set SC(1 0) = firstFreePattern * 8
 ASL A
 ROL SC+1               ; We use this to calculate the address of the pattern
 ASL A                  ; for the first free pattern in the pattern buffers
 ROL SC+1               ; below
 ASL A
 ROL SC+1
 STA SC

 STA SC2                ; Set SC2(1 0) = pattBuffer1 + SC(1 0)
 LDA SC+1               ;              = pattBuffer1 + firstFreePattern * 8
 ADC #HI(pattBuffer1)   ;
 STA SC2+1              ; So SC2(1 0) contains the address of the pattern of the
                        ; first free tile in pattern buffer 1, as each pattern
                        ; in the buffer contains eight bytes

 LDA SC+1               ; Set SC(1 0) = pattBuffer0 + SC(1 0)
 ADC #HI(pattBuffer0)   ;             = pattBuffer0 + firstFreePattern * 8
 STA SC+1               ;
                        ; So SC2(1 0) contains the address of the pattern of the
                        ; first free tile in pattern buffer 0

                        ; We now clear the patterns in both pattern buffers for
                        ; the free tile and all the other tiles to the end of
                        ; the buffers

 LDX firstFreePattern   ; Set X to the number of the first free pattern so we
                        ; start clearing patterns from this point onwards

 LDY #0                 ; Set Y to use as a byte index for zeroing the pattern
                        ; bytes in the pattern buffers

.scro5

 LDA #0                 ; Set A = 0 so we zero the pattern

 STA (SC),Y             ; Zero the Y-th pixel row of pattern X in both of the
 STA (SC2),Y            ; pattern buffers and increment the index in Y
 INY

 STA (SC),Y             ; Zero the Y-th pixel row of pattern X in both of the
 STA (SC2),Y            ; pattern buffers and increment the index in Y
 INY

 STA (SC),Y             ; Zero the Y-th pixel row of pattern X in both of the
 STA (SC2),Y            ; pattern buffers and increment the index in Y
 INY

 STA (SC),Y             ; Zero the Y-th pixel row of pattern X in both of the
 STA (SC2),Y            ; pattern buffers and increment the index in Y
 INY

 STA (SC),Y             ; Zero the Y-th pixel row of pattern X in both of the
 STA (SC2),Y            ; pattern buffers and increment the index in Y
 INY

 STA (SC),Y             ; Zero the Y-th pixel row of pattern X in both of the
 STA (SC2),Y            ; pattern buffers and increment the index in Y
 INY

 STA (SC),Y             ; Zero the Y-th pixel row of pattern X in both of the
 STA (SC2),Y            ; pattern buffers and increment the index in Y
 INY

 STA (SC),Y             ; Zero the Y-th pixel row of pattern X in both of the
 STA (SC2),Y            ; pattern buffers and increment the index in Y
 INY

 BNE scro6              ; If Y just incremented to 0, increment the high bytes
 INC SC+1               ; of SC(1 0) and SC2(1 0) so they point to the next page
 INC SC2+1              ; in memory

.scro6

 SETUP_PPU_FOR_ICON_BAR ; If the PPU has started drawing the icon bar, configure
                        ; the PPU to use nametable 0 and pattern table 0

 INX                    ; Increment the pattern number in X

 BNE scro5              ; Loop back until we have cleared all patterns up to and
                        ; including pattern 255

 LDA #0                 ; Set ALPHA and ALP1 to 0, so our roll angle is 0
 STA ALPHA
 STA ALP1

 STA DELTA              ; Set our ship's speed to zero so the scroll text stays
                        ; where it is

 LDA nmiCounter         ; Set the random number seed to a fairly random state
 CLC                    ; that's based on the NMI counter (which increments
 ADC RAND+1             ; every VBlank, so will be pretty random)
 STA RAND+1

 JSR DrawScrollInNMI    ; Configure the NMI handler to draw the scroll text
                        ; screen, which will clear the screen as we just blanked
                        ; out all the patterns in the pattern buffers

 PLA                    ; Retrieve the argument that we stored on the stack at
 BNE scro7              ; the start of the routine, which contains the scroll
                        ; text that we should be showing and if it is non-zero,
                        ; jump to scro7 to skip playing the combat part of the
                        ; demo, as we are either showing the results of combat
                        ; practice, or we are showing the credits

                        ; If we get here then A = 0 and we are show the first
                        ; scroll text before starting the combat demo

 LDX languageIndex      ; Set (Y X) to the address of the text for the first
 LDA scrollText1Lo,X    ; scroll text for the chosen language
 LDY scrollText1Hi,X
 TAX

 LDA #2                 ; Draw the first scroll text at scrollText1, which has
 JSR DrawScrollText     ; six lines (so we set A = 2, as it needs to contain
                        ; the number of lines minus 4)

                        ; We are now ready to start the combat part of the
                        ; combat demo

 LDA #$00               ; Set the view type in QQ11 to $00 (Space view with
 STA QQ11               ; no fonts loaded)

 JSR SetLinePatterns_b3 ; Load the line patterns for the new view into the
                        ; pattern buffers

 LDA #37                ; Tell the NMI handler to send pattern entries from
 STA firstPattern       ; pattern 37 in the buffer

 JSR DrawScrollInNMI    ; Configure the NMI handler to draw the scroll text
                        ; screen, which will draw the scroll text on-screen

 LDA #60                ; Tell the NMI handler to send pattern entries from
 STA firstPattern       ; pattern 60 in the buffer

 JMP PlayDemo_b0        ; Play the combat demo, returning from the subroutine
                        ; using a tail call

.scro7

 CMP #2                 ; If we called this routine with A = 2 then jump to
 BEQ scro14             ; scro14 to show the credits scroll text

                        ; Otherwise A = 1, so we show the second scroll text,
                        ; including the time taken for combat practice, so we
                        ; start by calculating the time taken and storing the
                        ; results in K5, so the GRIDSET routine can draw the
                        ; correct characters for the time taken
                        ;
                        ; Specifically, the second scroll text in scrollText2
                        ; expects the characters to be set as follows:
                        ;
                        ;   * $83 is the first digit of the minutes
                        ;
                        ;   * $82 is the second digit of the minutes
                        ;
                        ;   * $81 is the first digit of the seconds
                        ;
                        ;   * $80 is the second digit of the seconds
                        ;
                        ; while GRIDSET expect to find these values at the
                        ; following locations:
                        ;
                        ;   * Character $83 refers to location K5+3
                        ;
                        ;   * Character $82 refers to location K5+2
                        ;
                        ;   * Character $81 refers to location K5+1
                        ;
                        ;   * Character $80 refers to location K5
                        ;
                        ; Finally, the number of seconds that we need to display
                        ; is in (nmiTimerHi nmiTimerLo), so we need to convert
                        ; this into minutes and seconds, and then set the values
                        ; in K5 to the correct ASCII characters that represent
                        ; the digits of this time

 LDA #'0'               ; Set all the digits to 0 except the second digit of the
 STA K5+1               ; seconds (as we will set this later)
 STA K5+2
 STA K5+3

 LDA #100               ; Set nmiTimer = 100 so (nmiTimerHi nmiTimerLo) will not
 STA nmiTimer           ; change during the following calculation (as nmiTimer
                        ; has to tick down to zero for that to happen, so this
                        ; gives us 100 VBlanks to complete the calculation
                        ; before (nmiTimerHi nmiTimerLo) changes)

                        ; We start with the first digit of the minute count (the
                        ; "tens" digit)

 SEC                    ; Set the C flag for the following subtraction

.scro8

 LDA nmiTimerLo         ; Set (A X) = (nmiTimerHi nmiTimerLo) - $0258
 SBC #$58               ;           = (nmiTimerHi nmiTimerLo) - 600
 TAX
 LDA nmiTimerHi
 SBC #$02

 BCC scro9              ; If the subtraction underflowed then we know that
                        ; (nmiTimerHi nmiTimerLo) < 600, so jump to scro9 to
                        ; move on to the next digit

                        ; If we get here then (nmiTimerHi nmiTimerLo) >= 600,
                        ; so the time in (nmiTimerHi nmiTimerLo) is at least
                        ; ten minutes, so we increment the first digit of the
                        ; minute count in K5+3, update the time in
                        ; (nmiTimerHi nmiTimerLo) to (A X), and loop back to
                        ; try subtracting another 10 minutes

 STA nmiTimerHi         ; Set (nmiTimerHi nmiTimerLo) = (A X)
 STX nmiTimerLo         ;
                        ; So this updates (nmiTimerHi nmiTimerLo) with the new
                        ; value, which is ten minutes less than the original
                        ; value

 INC K5+3               ; Increment the first digit of the minute count in K5+3
                        ; to bump it up from, say, "0" to "1"

 BCS scro8              ; Loop back to scro8 to try subtracting another ten
                        ; minutes (this BCS is effectively a JMP as we just
                        ; passed through a BCC)

.scro9

                        ; Now for the second digit of the minute count (the
                        ; "ones" digit)

 SEC                    ; Set the C flag for the following subtraction

 LDA nmiTimerLo         ; Set (A X) = (nmiTimerHi nmiTimerLo) - $003C
 SBC #$3C               ;           = (nmiTimerHi nmiTimerLo) - 60
 TAX
 LDA nmiTimerHi
 SBC #$00

 BCC scro10             ; If the subtraction underflowed then we know that
                        ; (nmiTimerHi nmiTimerLo) < 60, so jump to scro10 to
                        ; move on to the next digit

                        ; If we get here then (nmiTimerHi nmiTimerLo) >= 60,
                        ; so the time in (nmiTimerHi nmiTimerLo) is at least
                        ; one minute, so we increment the second digit of the
                        ; minute count in K5+2, update the time in
                        ; (nmiTimerHi nmiTimerLo) to (A X), and loop back to
                        ; try subtracting another minute

 STA nmiTimerHi         ; Set (nmiTimerHi nmiTimerLo) = (A X)
 STX nmiTimerLo         ;
                        ; So this updates (nmiTimerHi nmiTimerLo) with the new
                        ; value, which is one minute less than the original
                        ; value

 INC K5+2               ; Increment the second digit of the minute count in K5+2
                        ; to bump it up from, say, "0" to "1"

 BCS scro9              ; Loop back to scro8 to try subtracting another minute
                        ; (this BCS is effectively a JMP as we just passed
                        ; through a BCC)

.scro10

                        ; Now for the first digit of the second count (the
                        ; "tens" digit)
                        ;
                        ; By this point we know that (nmiTimerHi nmiTimerLo) is
                        ; less than 60, so we can ignore the high byte as it is
                        ; zero by now

 SEC                    ; Set the C flag for the following subtraction

 LDA nmiTimerLo         ; Set A to the number of seconds we want to display

.scro11

 SBC #10                ; Set A = nmiTimerLo - 10

 BCC scro12             ; If the subtraction underflowed then we know that
                        ; nmiTimerLo < 10, so jump to scro12 to move on to the
                        ; final digit

                        ; If we get here then nmiTimerLo >= 10, so the time in
                        ; nmiTimerLo is at least ten seconds, so we increment
                        ; the first digit of the seconds count in K5+1 and loop
                        ; back to try subtracting another ten seconds

 INC K5+1               ; Increment the first digit of the seconds count in K5+1
                        ; to bump it up from, say, "0" to "1"

 BCS scro11             ; Loop back to scro8 to try subtracting another ten
                        ; seconds (this BCS is effectively a JMP as we just
                        ; passed through a BCC)

.scro12

                        ; By this point A contains the number of seconds left
                        ; after subtracting the final ten seconds, so it is
                        ; ten less than the value we want to display

 ADC #'0'+10            ; Set the character for the second digit of the seconds
 STA K5                 ; count in K5 to the value in A, plus the ten that we
                        ; subtracted before we jumped here, plus ASCII "0" to
                        ; convert it into a character

                        ; Now that the practice time is set up, we can show the
                        ; second scroll text to report the results

 LDX languageIndex      ; Set (Y X) to the address of the text for the second
 LDA scrollText2Lo,X    ; scroll text for the chosen language
 LDY scrollText2Hi,X
 TAX

 LDA #6                 ; We are now going to draw the second scroll text
                        ; at scrollText2, which has ten lines, so we set
                        ; A = 6 to pass to DrawScrollText, as it needs to
                        ; contain the number of lines minus 4

.scro13

 JSR DrawScrollText     ; Draw the scroll text at (Y X), which will either be
                        ; the second scroll text at scrollText2 or the third
                        ; credits scroll text at creditsText3, depending on how
                        ; we get here

 JSR FadeToBlack_b3     ; Fade the screen to black over the next four VBlanks

 JMP StartGame_b0       ; Jump to StartGame to reset the stack and go to the
                        ; docking bay (i.e. show the Status Mode screen)

.scro14

                        ; If we get here then we show the credits scroll text,
                        ; which is in three parts

 LDX languageIndex      ; Set (Y X) to the address of the text for the first
 LDA creditsText1Lo,X   ; credits scroll text for the chosen language
 LDY creditsText1Hi,X
 TAX

 LDA #6                 ; Draw the first credits scroll text at creditsText1,
 JSR DrawScrollText     ; which has ten lines (so we set A = 6, as it needs to
                        ; contain the number of lines minus 4)

 JSR WaitForNMI         ; Wait until the next NMI interrupt has passed (i.e. the
                        ; next VBlank)

 LDX languageIndex      ; Set (Y X) to the address of the text for the second
 LDA creditsText2Lo,X   ; credits scroll text for the chosen language
 LDY creditsText2Hi,X
 TAX

 LDA #5                 ; Draw the second credits scroll text at creditsText2,
 JSR DrawScrollText     ; which has nine lines (so we set A = 5, as it needs to
                        ; contain the number of lines minus 4)

 JSR WaitForNMI         ; Wait until the next NMI interrupt has passed (i.e. the
                        ; next VBlank)

 LDX languageIndex      ; Set (Y X) to the address of the text for the third
 LDA creditsText3Lo,X   ; credits scroll text for the chosen language
 LDY creditsText3Hi,X
 TAX

 LDA #3                 ; We are now going to draw the third credits scroll text
                        ; at creditsText3, which has seven lines, so we set
                        ; A = 3 to pass to DrawScrollText, as it needs to
                        ; contain the number of lines minus 4

 BNE scro13             ; Jump to scro13 to draw the third credits scroll text
                        ; at creditsText3 (this BNE is effectively a JMP as A is
                        ; never zero

; ******************************************************************************
;
;       Name: DrawScrollInNMI
;       Type: Subroutine
;   Category: Combat demo
;    Summary: Configure the NMI handler to draw the scroll text screen
;
; ******************************************************************************

.DrawScrollInNMI

 JSR WaitForPPUToFinish ; Wait until both bitplanes of the screen have been
                        ; sent to the PPU, so the screen is fully updated and
                        ; there is no more data waiting to be sent to the PPU

 LDA #254               ; Tell the NMI handler to send data up to pattern 254,
 STA firstFreePattern   ; so all the patterns get updated

 LDA #%11001000         ; Set both bitplane flags as follows:
 STA bitplaneFlags      ;
 STA bitplaneFlags+1    ;   * Bit 2 clear = send tiles up to configured numbers
                        ;   * Bit 3 set   = clear buffers after sending data
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

 RTS                    ; Return from the subroutine

; ******************************************************************************
;
;       Name: GRIDSET
;       Type: Subroutine
;   Category: Combat demo
;    Summary: Populate the line coordinate tables with the pixel lines for one
;             21-character line of scroll text
;  Deep dive: The 6502 Second Processor demo mode
;             The NES combat demo
;
; ------------------------------------------------------------------------------
;
; This routine populates the X-th byte in the X1TB, Y1TB and X2TB tables (the TB
; tables) with the line coordinates that make up each character in a single line
; of scroll text that we want to display (where each line of text contains 21
; characters).
;
; ------------------------------------------------------------------------------
;
; Arguments:
;
;   INF(1 0)            The contents of the scroll text to display
;
;   XC                  The offset within INF(1 0) of the 21-character line of
;                       text to display
;
; ------------------------------------------------------------------------------
;
; Other entry points:
;
;   GRIDSET+5           Use the y-coordinate in YP so the scroll text starts at
;                       (0, YP) rather than (0, 6)
;
; ******************************************************************************

.GRIDSET

 LDX #6                 ; Set YP = 6
 STX YP

 SETUP_PPU_FOR_ICON_BAR ; If the PPU has started drawing the icon bar, configure
                        ; the PPU to use nametable 0 and pattern table 0

 LDX #21                ; Each line of text in the scroll text contains 21
 STX CNT                ; characters (padded out with spaces if required), so
                        ; set CNT = 21 to use as a counter to work through the
                        ; line of text at INF(1 0) + XC

 LDX #0                 ; Set XP = 0, so we now have (XP, YP) = (0, 6)
 STX XP                 ;
                        ; (XP, YP) is the coordinate in space where we start
                        ; drawing the lines that make up the scroll text, so
                        ; this effectively moves the scroll text cursor to the
                        ; top-left corner (as these are space coordinates where
                        ; higher y-coordinates are further up the screen)

 LDY XC                 ; Set Y = XC, to act as an index into the text we want
                        ; to display, pointing to the character we are currently
                        ; processing and starting from character XC

.GSL1

 LDA (INF),Y            ; Load the Y-th character from the text we want to
                        ; display into A, so A now contains the ASCII code of
                        ; the character we want to process

 BPL grid1              ; If bit 7 of the character is clear, jump to grid1 to
                        ; slip the following

 TAX                    ; Bit 7 of the character is set, so set A to character
 LDA K5-128,X           ; X - 128 from K5
                        ;
                        ; So character $80 refers to location K5, $81 to K5+1,
                        ; $82 to K5+2 and $83 to K5+3, which is where we put the
                        ; results for the time taken in the combat demo, so this
                        ; allows us to display the time in the scroll text

.grid1

 SEC                    ; Set S = A - ASCII " ", as the table at LTDEF starts
 SBC #' '               ; with the lines needed for a space, so A now contains
 STA S                  ; the number of the entry in LTDEF for this character

 ASL A                  ; Set Y = S + 4 * A
 ASL A                  ;       = A + 4 * A
 ADC S                  ;       = 5 * A
 BCS grid2              ;
 TAY                    ; so Y now points to the offset of the definition in the
                        ; LTDEF table for the character in A, where the first
                        ; character in the table is a space and each definition
                        ; in LTDEF consists of five bytes
                        ;
                        ; If the addition overflows, jump to grid2 to do the
                        ; same as the following, but with an extra $100 added
                        ; to the addresses to cater for the overflow

 LDA LTDEF,Y            ; Call GRS1 to put the coordinates of the character's
 JSR GRS1               ; first line into the TB tables

 LDA LTDEF+1,Y          ; Call GRS1 to put the coordinates of the character's
 JSR GRS1               ; second line into the TB tables

 LDA LTDEF+2,Y          ; Call GRS1 to put the coordinates of the character's
 JSR GRS1               ; third line into the TB tables

 LDA LTDEF+3,Y          ; Call GRS1 to put the coordinates of the character's
 JSR GRS1               ; fourth line into the TB tables

 LDA LTDEF+4,Y          ; Call GRS1 to put the coordinates of the character's
 JSR GRS1               ; fifth line into the TB tables

 INC XC                 ; Increment the character index to point to the next
                        ; character in the text we want to display

 LDY XC                 ; Set Y to the updated character index

 LDA XP                 ; Set XP = XP + #W2
 CLC                    ;
 ADC #W2                ; to move the x-coordinate along by #W2 (the horizontal
 STA XP                 ; character spacing for the scroll text)

 DEC CNT                ; Decrement the loop counter in CNT

 BNE GSL1               ; Loop back to process the next character until we have
                        ; done all 21

 RTS                    ; Return from the subroutine

.grid2

                        ; If we get here then the addition overflowed when
                        ; calculating A, so we need to add an extra $100 to A
                        ; to get the correct address in LTDEF

 TAY                    ; Copy A to Y, so Y points to the offset of the
                        ; definition in the LTDEF table for the character in A

 LDA LTDEF+$100,Y       ; Call GRS1 to put the coordinates of the character's
 JSR GRS1               ; first line into the TB tables

 LDA LTDEF+$101,Y       ; Call GRS1 to put the coordinates of the character's
 JSR GRS1               ; second line into the TB tables

 LDA LTDEF+$102,Y       ; Call GRS1 to put the coordinates of the character's
 JSR GRS1               ; third line into the TB tables

 LDA LTDEF+$103,Y       ; Call GRS1 to put the coordinates of the character's
 JSR GRS1               ; fourth line into the TB tables

 LDA LTDEF+$104,Y       ; Call GRS1 to put the coordinates of the character's
 JSR GRS1               ; fifth line into the TB tables

 INC XC                 ; Increment the character index to point to the next
                        ; character in the text we want to display

 LDY XC                 ; Set Y to the updated character index

 LDA XP                 ; Set XP = XP + #W2
 CLC                    ;
 ADC #W2                ; to move the x-coordinate along by #W2 (the horizontal
 STA XP                 ; character spacing for the scroll text)

 DEC CNT                ; Decrement the loop counter in CNT

 BNE GSL1               ; Loop back to process the next character until we have
                        ; done all 21

 RTS                    ; Return from the subroutine

; ******************************************************************************
;
;       Name: GRS1
;       Type: Subroutine
;   Category: Combat demo
;    Summary: Populate the line coordinate tables with the lines for a single
;             scroll text character
;  Deep dive: The 6502 Second Processor demo mode
;
; ------------------------------------------------------------------------------
;
; This routine populates the X-th byte in the X1TB, Y1TB and X2TB tables (the TB
; tables) with the coordinates for the lines that make up the character whose
; definition is given in A.
;
; ------------------------------------------------------------------------------
;
; Arguments:
;
;   A                   The value from the LTDEF table for the character
;
;   (XP, YP)            The coordinate where we should draw this character
;
;   X                   The index of the character within the scroll text
;
; ------------------------------------------------------------------------------
;
; Returns:
;
;   X                   X gets incremented to point to the next character
;
;   Y                   Y is preserved
;
; ******************************************************************************

.GRS1

 BEQ GRR1               ; If A = 0, jump to GRR1 to return from the subroutine
                        ; as 0 denotes no line segment

 STA R                  ; Store the value from the LTDEF table in R

 STY P                  ; Store the offset in P, so we can preserve it through
                        ; calls to GRS1

 SETUP_PPU_FOR_ICON_BAR ; If the PPU has started drawing the icon bar, configure
                        ; the PPU to use nametable 0 and pattern table 0

.gris1

 LDA Y1TB,X             ; If the Y1 coordinate for character X is zero then it
 BEQ gris2              ; is empty and can be used, so jump to gris2 to get on
                        ; with the calculation

 INX                    ; Otherwise increment the byte pointer in X to check the
                        ; next entry in the coordinate table

 CPX #240               ; If X <> 240 then we have not yet reached the end of
 BNE gris1              ; the coordinate table (as each of the X1TB, X2TB and
                        ; Y1TB tables is 240 bytes long), so loop back to gris1
                        ; to check the next entry to see if it is free

 LDX #0                 ; Otherwise set X = 0 so we wrap around to the start of
                        ; the table

.gris2

 LDA R                  ; Set A to bits 0-3 of the LTDEF table value, i.e. the
 AND #%00001111         ; low nibble

 TAY                    ; Set Y = A

 LDA NOFX,Y             ; Set X1TB+X = XP + NOFX+Y
 CLC                    ;
 ADC XP                 ; so the X1 coordinate is XP + the NOFX entry given by
 STA X1TB,X             ; the low nibble of the LTDEF table value

 LDA YP                 ; Set Y1TB+X = YP - NOFY+Y
 SEC                    ;
 SBC NOFY,Y             ; so the Y1 coordinate is YP - the NOFY entry given by
 STA Y1TB,X             ; the low nibble of the LTDEF table value

 LDA R                  ; Set Y to bits 4-7 of the LTDEF table value, i.e. the
 LSR A                  ; high nibble
 LSR A
 LSR A
 LSR A
 TAY

 LDA NOFX,Y             ; Set X2TB+X = XP + NOFX+Y
 CLC                    ;
 ADC XP                 ; so the X2 coordinate is XP + the NOFX entry given by
 STA X2TB,X             ; the high nibble of the LTDEF table value

 LDA YP                 ; Set A = YP - NOFY+Y
 SEC                    ;
 SBC NOFY,Y             ; so the value in A is YP - the NOFY entry given by the
                        ; high nibble of the LTDEF table value

 ASL A                  ; Shift the result from the low nibble of A into the top
 ASL A                  ; nibble
 ASL A
 ASL A

 ORA Y1TB,X             ; Stick the result into the high nibble of Y1TB+X, so
 STA Y1TB,X             ; the Y1TB coordinate contains both y-coordinates, with
                        ; Y1 in the low nibble and Y2 in the high nibble

 LDY P                  ; Restore Y from P so it gets preserved through calls to
                        ; GRS1

.GRR1

 SETUP_PPU_FOR_ICON_BAR ; If the PPU has started drawing the icon bar, configure
                        ; the PPU to use nametable 0 and pattern table 0

 RTS                    ; Return from the subroutine

; ******************************************************************************
;
;       Name: CalculateGridLines
;       Type: Subroutine
;   Category: Combat demo
;    Summary: Reset the line coordinate tables and populate them with the
;             characters for a specified scroll text
;
; ------------------------------------------------------------------------------
;
; Arguments:
;
;   (Y X)               The content of the scroll text to display
;
; ------------------------------------------------------------------------------
;
; Returns:
;
;   INF(1 0)            The content of the scroll text to display
;
; ******************************************************************************

.CalculateGridLines

 STX INF                ; Set INF(1 0) = (Y X)
 STY INF+1

 SETUP_PPU_FOR_ICON_BAR ; If the PPU has started drawing the icon bar, configure
                        ; the PPU to use nametable 0 and pattern table 0

                        ; We start by clearing out the buffer at Y1TB

 LDY #240               ; The buffer contains 240 bytes, so set a byte counter
                        ; in Y

 LDA #0                 ; Set A = 0 so we can zero the buffer

.resg1

 STA Y1TB-1,Y           ; Zero the entry Y - 1 in Y1TB

 DEY                    ; Decrement the byte counter

 BNE resg1              ; Loop back until we have reset the whole Y1TB buffer

                        ; We now populate the grid line buffer with the lines
                        ; for the scroll text at INF(1 0)

 LDX #0                 ; Set XP = 0, so the scroll text starts at x-coordinate
 STX XP                 ; 0, on the left of the screen

 LDA #5*W2Y             ; Set YP so the scroll text starts five lines of scroll
 STA YP                 ; text down the screen (as W2Y is the height of each
                        ; line in scroll text coordinates)

 LDY #0                 ; Set XC = 0, so we start from the first character of
 STY XC                 ; INF(1 0)

 LDA #4                 ; Set LASCT = 4, so we process four lines of text in the
 STA LASCT              ; following loop

.resg2

 JSR GRIDSET+5          ; Populate the line coordinate tables with the pixel
                        ; lines for one 21-character line of scroll text,
                        ; drawing the line at (0, YP)

 LDA YP                 ; Set YP = YP - W2Y
 SEC                    ;
 SBC #W2Y               ; So YP moves down the screen by one line (as W2Y is the
 STA YP                 ; height of each line in scroll text coordinates)

 DEC LASCT              ; Decrement the loop counter in LASCT

 BNE resg2              ; Loop back until we have processed LASCT lines of
                        ; scroll text

 RTS                    ; Return from the subroutine

; ******************************************************************************
;
;       Name: GetScrollDivisions
;       Type: Subroutine
;   Category: Combat demo
;    Summary: Set up the division calculations for the scroll text
;
; ------------------------------------------------------------------------------
;
; This routine sets up a division table to use in the calculations for drawing
; the scroll text in DrawScrollFrame.
;
; ******************************************************************************

.GetScrollDivisions

 LDY #15                ; We are going to populate 16 bytes in the buffer at BUF
                        ; and another 16 in the buffer at BUF+16, so set a loop
                        ; counter in Y

.sdiv1

 SETUP_PPU_FOR_ICON_BAR ; If the PPU has started drawing the icon bar, configure
                        ; the PPU to use nametable 0 and pattern table 0

 STY T                  ; Store the loop counter in T (though we don't read this
                        ; again, so this has no effect)

 TYA                    ; Set R = Y * 2
 ASL A
 STA R

 ASL A                  ; Set S = Y * 4
 STA S

 ASL A                  ; Set the Y-th entry in BUF+16 to the following:
 ADC #31                ;
 SBC scrollProgress     ;   Y * 8 + 31 - scrollProgress
 STA BUF+16,Y           ;
                        ; We know the C flag is clear because Y is a maximum of
                        ; 15 so the three ASL A instructions will shift zeroes
                        ; into the C flag each time

 BPL sdiv4              ; If A < 128, jump to sdiv4 to set Q and A as follows,
                        ; but with both scaled up as far as possible to make the
                        ; calculation more accurate

 STA Q                  ; Set Q = A

 LDA scrollProgress     ; Set A = 37 + scrollProgress / 4 - R
 LSR A                  ;       = 37 + scrollProgress / 4 - Y * 2
 LSR A
 ADC #37
 SBC R

.sdiv2

 CMP Q                  ; If A >= Q, jump to sdiv3 to store 255 as the result
 BCS sdiv3              ; in the Y-th byte of BUF

 JSR LL28               ; Call LL28 to calculate:
                        ;
                        ;   R = 256 * A / Q
                        ;
                        ;     = 37 - Y * 2 + scrollProgress / 4
                        ;       -------------------------------
                        ;         31 + Y * 8 - scrollProgress

 LSR R                  ; Set R = R / 2
                        ;
                        ;     =  37 - Y * 2 + scrollProgress / 4
                        ;       ---------------------------------
                        ;       2 * (31 + Y * 8 - scrollProgress)

 LDA #72                ; Set the Y-th entry in BUF to 72 + R
 CLC
 ADC R
 STA BUF,Y

 DEY                    ; Decrement the loop counter in Y

 BPL sdiv1              ; Loop back until we have calculated all 16 values

 RTS                    ; Return from the subroutine

.sdiv3

 LDA #255               ; Set the Y-th entry in BUF to 255
 STA BUF,Y

 DEY                    ; Decrement the loop counter in Y

 BPL sdiv1              ; Loop back until we have calculated all 16 values

 RTS                    ; Return from the subroutine

.sdiv4

 ASL A                  ; Set A = A * 2

 BPL sdiv5              ; If A < 128, jump to sdiv5

 STA Q                  ; Set Q = A * 2

 LDA scrollProgress     ; Set A = 73 + scrollProgress / 2 - Y * 4
 LSR A
 ADC #73
 SBC S

                        ; So we have:
                        ;
                        ;   Q = A * 2
                        ;
                        ;   A = 73 + scrollProgress / 2 - Y * 4
                        ;
                        ; So when we divide them at sdiv2 above, this is the
                        ; same as having:
                        ;
                        ;   Q = A
                        ;
                        ;   A = 37 + scrollProgress / 4 - Y * 2
                        ;
                        ; but with both the numerator and denominator scaled up
                        ; by the same factor of 2

 JMP sdiv2              ; Jump to sdiv2 to continue the calculation with these
                        ; scaled up values of Q and A

.sdiv5

 ASL A                  ; Set Q = A * 4
 STA Q

 LDA scrollProgress     ; Set A = 144 + scrollProgress - Y * 2
 ADC #144
 SBC S
 SBC S

                        ; So we have:
                        ;
                        ;   Q = A * 4
                        ;
                        ;   A = 144 + scrollProgress - Y * 2
                        ;
                        ; So when we divide them at sdiv2 above, this is the
                        ; same as having:
                        ;
                        ;   Q = A
                        ;
                        ;   A = 37 + scrollProgress / 4 - Y * 2
                        ;
                        ; but with both the numerator and denominator scaled up
                        ; by the same factor of 4

 JMP sdiv2              ; Jump to sdiv2 to continue the calculation with these
                        ; scaled up values of Q and A

; ******************************************************************************
;
;       Name: DrawScrollText
;       Type: Subroutine
;   Category: Combat demo
;    Summary: Display a Star Wars scroll text
;  Deep dive: The NES combat demo
;
; ------------------------------------------------------------------------------
;
; Arguments:
;
;   A                   The number of lines in the middle part of the scroll
;                       text, which is the total number of text lines minus 4:
;
;                         * 2 for scrollText1 (6 lines)
;
;                         * 6 for scrollText2 and creditsText1 (10 lines)
;
;                         * 5 for creditsText2 (9 lines)
;
;                         * 3 for creditsText3 (7 lines)
;
; ******************************************************************************

.DrawScrollText

 PHA                    ; Store the number of lines in the scroll text on the
                        ; stack so we can retrieve it later

 JSR CalculateGridLines ; Reset the line coordinate tables and populate them
                        ; with the characters for the scroll text at (Y X),
                        ; setting INF(1 0) to the scroll text in the process

 LDA #$28               ; Set the visible colour to orange ($28) so the scroll
 STA visibleColour      ; text appears in this colour

 LDA #0                 ; Clear bits 6 and 7 of allowInSystemJump to allow
 STA allowInSystemJump  ; in-system jumps, so the call to UpdateIconBar displays
                        ; the fast-forward icon (though choosing this in the
                        ; demo doesn't do an in-system jump, but skips the rest
                        ; of the demo instead)

 LDA #2                 ; Set the scroll text speed to 2 (normal speed)
 STA scrollTextSpeed

 JSR UpdateIconBar_b3   ; Update the icon bar to show the correct buttons for
                        ; the scroll text

 LDA #40                ; Tell the NMI handler to send nametable entries from
 STA firstNameTile      ; tile 40 * 8 = 320 onwards (i.e. from the start of tile
                        ; row 10)

                        ; We now draw the scroll text and move it up the screen,
                        ; which we do in three stages
                        ;
                        ;   * Stage 1 moves the first few lines of the scroll
                        ;     text up the screen until the first line reaches
                        ;     the middle of the screen (i.e. just before it will
                        ;     start to disappear into the distance); stage 1 is
                        ;     always 81 frames long at normal speed
                        ;
                        ;  *  Stage 2 then draws the rest of the scroll text
                        ;     on-screen while moving everything up the screen,
                        ;     reusing lines in the line coordinate tables as
                        ;     they disappear into the distance; stage 2 is
                        ;     longer with longer scroll texts
                        ;
                        ;   * Stage 3 takes over when everything has been drawn,
                        ;     and just concentrates on moving the scroll text
                        ;     into the distance without drawing anything new;
                        ;     stage 3 is always 48 frames long at normal speed
                        ;
                        ; We start with stage 1

 LDA #160               ; Set the size of the scroll text to 160 to pass to
 STA scrollProgress     ; DrawScrollFrames
                        ;
                        ; This equates to 81 frames at normal speed, with each
                        ; frame taking scrollTextSpeed off the value of
                        ; scrollProgress (i.e. subtracting 2), and only
                        ; stopping when the subtraction goes past zero

 JSR DrawScrollFrames   ; Draw the frames for stage 1, so the scroll text gets
                        ; drawn and moves up the screen

                        ; We now move on to stage 2
                        ;
                        ; Stage 2 takes longer for longer scroll texts, and its
                        ; length is based on the value of A passed to the
                        ; routine (which contains the total number of text lines
                        ; minus 4)
                        ;
                        ; Specifically, stage 2 loop around A times, with each
                        ; loop taking a scrollProgress of 23 (which is 12 frames
                        ; at normal speed)
                        ;
                        ; Each loop draws an extra line of text in the scroll
                        ; text, and scrolls up by one line of text

 PLA                    ; Set LASCT to the value that we stored on the stack, so
 STA LASCT              ; LASCT contains the number of lines in the scroll text

.dscr1

 LDA #23                ; Set the size of the scroll text to 23 to pass to
 STA scrollProgress     ; DrawScrollFrames

 JSR ScrollTextUpScreen ; Scroll the scroll text up the screen by one full line
                        ; of text

 JSR GRIDSET            ; Call GRIDSET to populate the line coordinate tables at
                        ; X1TB, Y1TB and X2TB (the TB tables) with the lines for
                        ; the scroll text in INF(1 0) at offset XC

 JSR DrawScrollFrames   ; Draw the frames for stage 2, so the scroll text gets
                        ; drawn and moves up the screen by one text line

 DEC LASCT              ; Loop back until we have done LASCT loops around the
 BNE dscr1              ; above

                        ; We now move on to stage 3
                        ;
                        ; Stage 3 loops around four times, with each loop taking
                        ; a scrollProgress of 23 (which is 12 frames at normal
                        ; speed), so that's a grand total of 48 frames at normal
                        ; speed

 LDA #4                 ; Set LASCT = 4 so we do the following loop four times
 STA LASCT

.dscr2

 LDA #23                ; Set the size of the scroll text to 23 to pass to
 STA scrollProgress     ; DrawScrollFrames

 JSR ScrollTextUpScreen ; Scroll the scroll text up the screen by one full line
                        ; of text

 JSR DrawScrollFrames   ; Draw the frames for stage 3, so the scroll text moves
                        ; off-screen one text line at a time

 DEC LASCT              ; Loop back until we have done LASCT loops around the
 BNE dscr2              ; above

                        ; The scroll text is now done and is no longer on-screen

 LDA #0                 ; Reset the scroll speed to zero (though this isn't read
 STA scrollTextSpeed    ; again, so this has no effect)

 LDA #$2C               ; Set the visible colour back to cyan ($2C)
 STA visibleColour

 RTS                    ; Return from the subroutine

; ******************************************************************************
;
;       Name: DrawScrollFrames
;       Type: Subroutine
;   Category: Combat demo
;    Summary: Draw a scroll text over multiple frames
;  Deep dive: The NES combat demo
;
; ******************************************************************************

.DrawScrollFrames

 LDA controller1A       ; If the A button is being pressed on controller 1, jump
 BMI scfr1              ; to scfr1 to speed up the scroll text

 LDA iconBarChoice      ; If the fast-forward button has not been chosen on the
 CMP #12                ; icon bar, jump to scfr2 to leave the speed as it is
 BNE scfr2

 LDA #0                 ; Set iconBarChoice = 0 to clear the icon button choice
 STA iconBarChoice      ; so we don't process it again

.scfr1

                        ; If we get here then either the A button has been
                        ; pressed or the fast-forward button has been chosen on
                        ; the icon bar

 LDA #9                 ; Set the scroll text speed to 9 (fast)
 STA scrollTextSpeed

.scfr2

 JSR FlipDrawingPlane   ; Flip the drawing bitplane so we draw into the bitplane
                        ; that isn't visible on-screen

 JSR DrawScrollFrame    ; Draw one frame of the scroll text

 JSR DrawBitplaneInNMI  ; Configure the NMI to send the drawing bitplane to the
                        ; PPU after drawing the box edges and setting the next
                        ; free tile number

 LDA iconBarChoice      ; If no buttons have been pressed on the icon bar while
 BEQ scfr3              ; drawing the frame, jump to scfr3 to skip the following
                        ; instruction

 JSR CheckForPause_b0   ; If the Start button has been pressed then process the
                        ; pause menu and set the C flag, otherwise clear it

.scfr3

 LDA scrollProgress     ; Set scrollProgress = scrollProgress - scrollTextSpeed
 SEC                    ;
 SBC scrollTextSpeed    ; So we update the scroll text progress
 STA scrollProgress

 BCS DrawScrollFrames   ; If the subtraction didn't underflow then the value of
                        ; scrollProgress is still positive and there is more
                        ; scrolling to be done, so loop back to the start of
                        ; the routine to keep going

 RTS                    ; Return from the subroutine

; ******************************************************************************
;
;       Name: ScrollTextUpScreen
;       Type: Subroutine
;   Category: Combat demo
;    Summary: Go through the line y-coordinate table at Y1TB, moving each line
;             coordinate up the screen by W2Y (i.e. by one full line of text)
;
; ******************************************************************************

.ScrollTextUpScreen

 SETUP_PPU_FOR_ICON_BAR ; If the PPU has started drawing the icon bar, configure
                        ; the PPU to use nametable 0 and pattern table 0

                        ; We now work our way through every y-coordinate in the
                        ; Y1TB table (so that's the y-coordinate of each line in
                        ; the line coordinate tables), adding 51 to each of them
                        ; to move the scroll text up the screen, and removing
                        ; any lines that move off the top of the scroll text

 LDY #16                ; Set Y as a loop counter so we work our way through
                        ; the y-coordinates in Y1TB, from entry 239 down to
                        ; entry 224

.sups1

 LDA Y1TB+223,Y         ; Set A to the Y-th y-coordinate in this section of the
                        ; Y1TB table

 BEQ sups3              ; If A = 0 then this entry is already empty, so jump to
                        ; sups3 to move on to the next entry

 CLC                    ; Otherwise this is a valid y-coordinate, so add W2Y to
 ADC #(W2Y<<4 + W2Y)    ; the high nibble and W2Y to the low nibble, so we add
                        ; W2Y to both of the y-coordinates stored in this entry

 BCC sups2              ; If the addition overflowed, set A = 0 to remove this
 LDA #0                 ; entry from the table, as the line no longer fits
 CLC                    ; on-screen (we also clear the C flag, though this
                        ; doesn't appear to be necessary)

.sups2

 STA Y1TB+223,Y         ; Store the updated y-coordinate back in the Y1TB table

.sups3

 DEY                    ; Decrement the loop counter in Y

 BNE sups1              ; Loop back until we have processed all the entries in
                        ; this section of the Y1TB table

 SETUP_PPU_FOR_ICON_BAR ; If the PPU has started drawing the icon bar, configure
                        ; the PPU to use nametable 0 and pattern table 0

 LDY #32                ; Set Y as a loop counter so we work our way through
                        ; the y-coordinates in Y1TB, from entry 223 down to
                        ; entry 192

.sups4

 LDA Y1TB+191,Y         ; Set A to the Y-th y-coordinate in this section of the
                        ; Y1TB table

 BEQ sups6              ; If A = 0 then this entry is already empty, so jump to
                        ; sups6 to move on to the next entry

 CLC                    ; Otherwise this is a valid y-coordinate, so add W2Y to
 ADC #(W2Y<<4 + W2Y)    ; the high nibble and W2Y to the low nibble, so we add
                        ; W2Y to both of the y-coordinates stored in this entry

 BCC sups5              ; If the addition overflowed, set A = 0 to remove this
 LDA #0                 ; entry from the table, as the line no longer fits
 CLC                    ; on-screen (we also clear the C flag, though this
                        ; doesn't appear to be necessary)

.sups5

 STA Y1TB+191,Y         ; Store the updated y-coordinate back in the Y1TB table

.sups6

 DEY                    ; Decrement the loop counter in Y

 BNE sups4              ; Loop back until we have processed all the entries in
                        ; this section of the Y1TB table

 SETUP_PPU_FOR_ICON_BAR ; If the PPU has started drawing the icon bar, configure
                        ; the PPU to use nametable 0 and pattern table 0

 LDY #32                ; Set Y as a loop counter so we work our way through
                        ; the y-coordinates in Y1TB, from entry 191 down to
                        ; entry 160

.sups7

 LDA Y1TB+159,Y         ; Set A to the Y-th y-coordinate in this section of the
                        ; Y1TB table

 BEQ sups9              ; If A = 0 then this entry is already empty, so jump to
                        ; sups9 to move on to the next entry

 CLC                    ; Otherwise this is a valid y-coordinate, so add W2Y to
 ADC #(W2Y<<4 + W2Y)    ; the high nibble and W2Y to the low nibble, so we add
                        ; W2Y to both of the y-coordinates stored in this entry

 BCC sups8              ; If the addition overflowed, set A = 0 to remove this
 LDA #0                 ; entry from the table, as the line no longer fits
 CLC                    ; on-screen (we also clear the C flag, though this
                        ; doesn't appear to be necessary)

.sups8

 STA Y1TB+159,Y         ; Store the updated y-coordinate back in the Y1TB table

.sups9

 DEY                    ; Decrement the loop counter in Y

 BNE sups7              ; Loop back until we have processed all the entries in
                        ; this section of the Y1TB table

 SETUP_PPU_FOR_ICON_BAR ; If the PPU has started drawing the icon bar, configure
                        ; the PPU to use nametable 0 and pattern table 0

 LDY #32                ; Set Y as a loop counter so we work our way through
                        ; the y-coordinates in Y1TB, from entry 159 down to
                        ; entry 128

.sups10

 LDA Y1TB+127,Y         ; Set A to the Y-th y-coordinate in this section of the
                        ; Y1TB table

 BEQ sups12             ; If A = 0 then this entry is already empty, so jump to
                        ; sups12 to move on to the next entry

 CLC                    ; Otherwise this is a valid y-coordinate, so add W2Y to
 ADC #(W2Y<<4 + W2Y)    ; the high nibble and W2Y to the low nibble, so we add
                        ; W2Y to both of the y-coordinates stored in this entry

 BCC sups11             ; If the addition overflowed, set A = 0 to remove this
 LDA #0                 ; entry from the table, as the line no longer fits
 CLC                    ; on-screen (we also clear the C flag, though this
                        ; doesn't appear to be necessary)

.sups11

 STA Y1TB+127,Y         ; Store the updated y-coordinate back in the Y1TB table

.sups12

 DEY                    ; Decrement the loop counter in Y

 BNE sups10             ; Loop back until we have processed all the entries in
                        ; this section of the Y1TB table

 SETUP_PPU_FOR_ICON_BAR ; If the PPU has started drawing the icon bar, configure
                        ; the PPU to use nametable 0 and pattern table 0

 LDY #32                ; Set Y as a loop counter so we work our way through
                        ; the y-coordinates in Y1TB, from entry 127 down to
                        ; entry 96

.sups13

 LDA Y1TB+95,Y          ; Set A to the Y-th y-coordinate in this section of the
                        ; Y1TB table

 BEQ sups15             ; If A = 0 then this entry is already empty, so jump to
                        ; sups15 to move on to the next entry

 CLC                    ; Otherwise this is a valid y-coordinate, so add W2Y to
 ADC #(W2Y<<4 + W2Y)    ; the high nibble and W2Y to the low nibble, so we add
                        ; W2Y to both of the y-coordinates stored in this entry

 BCC sups14             ; If the addition overflowed, set A = 0 to remove this
 LDA #0                 ; entry from the table, as the line no longer fits
 CLC                    ; on-screen (we also clear the C flag, though this
                        ; doesn't appear to be necessary)
.sups14

 STA Y1TB+95,Y          ; Store the updated y-coordinate back in the Y1TB table

.sups15

 DEY                    ; Decrement the loop counter in Y

 BNE sups13             ; Loop back until we have processed all the entries in
                        ; this section of the Y1TB table

 SETUP_PPU_FOR_ICON_BAR ; If the PPU has started drawing the icon bar, configure
                        ; the PPU to use nametable 0 and pattern table 0

 LDY #32                ; Set Y as a loop counter so we work our way through
                        ; the y-coordinates in Y1TB, from entry 95 down to
                        ; entry 64

.sups16

 LDA Y1TB+63,Y          ; Set A to the Y-th y-coordinate in this section of the
                        ; Y1TB table

 BEQ sups18             ; If A = 0 then this entry is already empty, so jump to
                        ; sups18 to move on to the next entry

 CLC                    ; Otherwise this is a valid y-coordinate, so add W2Y to
 ADC #(W2Y<<4 + W2Y)    ; the high nibble and W2Y to the low nibble, so we add
                        ; W2Y to both of the y-coordinates stored in this entry

 BCC sups17             ; If the addition overflowed, set A = 0 to remove this
 LDA #0                 ; entry from the table, as the line no longer fits
 CLC                    ; on-screen (we also clear the C flag, though this
                        ; doesn't appear to be necessary)
.sups17

 STA Y1TB+63,Y          ; Store the updated y-coordinate back in the Y1TB table

.sups18

 DEY                    ; Decrement the loop counter in Y

 BNE sups16             ; Loop back until we have processed all the entries in
                        ; this section of the Y1TB table

 SETUP_PPU_FOR_ICON_BAR ; If the PPU has started drawing the icon bar, configure
                        ; the PPU to use nametable 0 and pattern table 0

 LDY #32                ; Set Y as a loop counter so we work our way through
                        ; the y-coordinates in Y1TB, from entry 63 down to
                        ; entry 32

.sups19

 LDA Y1TB+31,Y          ; Set A to the Y-th y-coordinate in this section of the
                        ; Y1TB table

 BEQ sups21             ; If A = 0 then this entry is already empty, so jump to
                        ; sups21 to move on to the next entry

 CLC                    ; Otherwise this is a valid y-coordinate, so add W2Y to
 ADC #(W2Y<<4 + W2Y)    ; the high nibble and W2Y to the low nibble, so we add
                        ; W2Y to both of the y-coordinates stored in this entry

 BCC sups20             ; If the addition overflowed, set A = 0 to remove this
 LDA #0                 ; entry from the table, as the line no longer fits
 CLC                    ; on-screen (we also clear the C flag, though this
                        ; doesn't appear to be necessary)

.sups20

 STA Y1TB+31,Y          ; Store the updated y-coordinate back in the Y1TB table

.sups21

 DEY                    ; Decrement the loop counter in Y

 BNE sups19             ; Loop back until we have processed all the entries in
                        ; this section of the Y1TB table

 SETUP_PPU_FOR_ICON_BAR ; If the PPU has started drawing the icon bar, configure
                        ; the PPU to use nametable 0 and pattern table 0

 LDY #32                ; Set Y as a loop counter so we work our way through
                        ; the y-coordinates in Y1TB, from entry 31 down to
                        ; entry 0

.sups22

 LDA Y1TB-1,Y           ; Set A to the Y-th y-coordinate in this section of the
                        ; Y1TB table

 BEQ sups24             ; If A = 0 then this entry is already empty, so jump to
                        ; sups24 to move on to the next entry

 CLC                    ; Otherwise this is a valid y-coordinate, so add W2Y to
 ADC #(W2Y<<4 + W2Y)    ; the high nibble and W2Y to the low nibble, so we add
                        ; W2Y to both of the y-coordinates stored in this entry

 BCC sups23             ; If the addition overflowed, set A = 0 to remove this
 LDA #0                 ; entry from the table, as the line no longer fits
 CLC                    ; on-screen (we also clear the C flag, though this
                        ; doesn't appear to be necessary)

.sups23

 STA Y1TB-1,Y           ; Store the updated y-coordinate back in the Y1TB table

.sups24

 DEY                    ; Decrement the loop counter in Y

 BNE sups22             ; Loop back until we have processed all the entries in
                        ; this section of the Y1TB table

 SETUP_PPU_FOR_ICON_BAR ; If the PPU has started drawing the icon bar, configure
                        ; the PPU to use nametable 0 and pattern table 0

 RTS                    ; Return from the subroutine

; ******************************************************************************
;
;       Name: ProjectScrollText
;       Type: Subroutine
;   Category: Combat demo
;    Summary: Project a scroll text coordinate onto the screen
;
; ------------------------------------------------------------------------------
;
; Calculate the following:
;
;   (A X) = 128 + 256 * (A - 32) / Q
;
; ------------------------------------------------------------------------------
;
; Arguments:
;
;   A                   The x-coordinate to project
;
; ------------------------------------------------------------------------------
;
; Other entry points:
;
;   RTS10               Contains an RTS
;
; ******************************************************************************

.ProjectScrollText

 SEC                    ; Set A = A - 32
 SBC #32

 BCS proj1              ; If the subtraction didn't underflow then the result is
                        ; positive, so jump to proj1

 EOR #$FF               ; Negate A using two's complement, so A is positive
 ADC #1

 JSR LL28               ; Call LL28 to calculate:
                        ;
                        ;   R = 256 * A / Q

 LDA #128               ; Set (A X) = 128 - R
 SEC                    ;
 SBC R                  ; Starting with the low bytes
 TAX

 LDA #0                 ; And then the high bytes
 SBC #0                 ;
                        ; This gives us the result we want, as 128 + R is the
                        ; same as 128 - (-R)

 RTS                    ; Return from the subroutine

.proj1

 JSR LL28               ; Call LL28 to calculate:
                        ;
                        ;   R = 256 * A / Q

 LDA R                  ; Set (A X) = R + 128
 CLC                    ;
 ADC #128               ; Starting with the low bytes
 TAX

 LDA #0                 ; And then the high bytes
 ADC #0

.RTS10

 RTS                    ; Return from the subroutine

; ******************************************************************************
;
;       Name: DrawScrollFrame
;       Type: Subroutine
;   Category: Combat demo
;    Summary: Draw one frame of the scroll text
;  Deep dive: The NES combat demo
;
; ------------------------------------------------------------------------------
;
; This routine draws each character on the scroll text by taking the character's
; line coordinates from the from the X1TB, X2TB and Y1TB line coordinate tables
; (i.e. X1, Y1, X2 and Y2) and projecting them onto a scroll that disappears
; into the distance, like the scroll text at the start of Star Wars.
;
; For a character line from (X1, Y1) to (X2, Y2), the calculation gives us
; coordinates of the line to draw on-screen from (x1, y1) to (x2, y2), as
; follows:
;
;                                256 * (X1 - 32)
;   x1 = XX15(1 0) = 128 + ----------------------------
;                          Y1 * 8 + 31 - scrollProgress
;
;                                256 * (X2 - 32)
;   x2 = XX15(5 4) = 128 + ----------------------------
;                          Y2 * 8 + 31 - scrollProgress
;
;                          37 - Y1 * 2 + scrollProgress / 4
;   y1 = XX15(3 2) = 72 + ----------------------------------
;                         2 * (31 + Y1 * 8 - scrollProgress)
;
;                          37 - Y2 * 2 + scrollProgress / 4
;   y2 = XX12(1 0) = 72 + ----------------------------------
;                         2 * (31 + Y2 * 8 - scrollProgress)
;
; The line then gets clipped to the screen by the CLIP_b1 routine and drawn.
;
; ******************************************************************************

.DrawScrollFrame

 JSR GetScrollDivisions ; Set up the division calculations for the scroll text
                        ; and store then in the 16 bytes at BUF and the 16 bytes
                        ; at BUF+16

 LDY #$FF               ; We are about to loop through the 240 bytes in the line
                        ; coordinate tables, so set a coordinate counter in Y
                        ; to start from 0, so set Y = -1 so the INY instruction
                        ; at the start of the loop sets Y to 0 for the first
                        ; coordinate

.drfr1

 SETUP_PPU_FOR_ICON_BAR ; If the PPU has started drawing the icon bar, configure
                        ; the PPU to use nametable 0 and pattern table 0

 INY                    ; Increment the coordinate counter in Y

 CPY #240               ; If Y = 240 then we have worked our way through all the
 BEQ RTS10              ; line coordinates, so jump to RTS10 to return from the
                        ; subroutine

 LDA Y1TB,Y             ; Set A to the y-coordinate byte that contains the start
                        ; and end y-coordinates in the bottom and high nibbles
                        ; respectively

 BEQ drfr1              ; If both y-coordinates are zero then this entry doesn't
                        ; contain a line, so jump to drfr1 to move on to the
                        ; next coordinate

                        ; We now set up the following, so we can clip the line
                        ; to the screen before drawing it:
                        ;
                        ;   XX15(1 0) = X1 as a 16-bit coordinate (x1_hi x1_lo)
                        ;
                        ;   XX15(3 2) = Y1 as a 16-bit coordinate (y1_hi y1_lo)
                        ;
                        ;   XX15(5 4) = X2 as a 16-bit coordinate (x2_hi x2_lo)
                        ;
                        ;   XX12(1 0) = Y2 as a 16-bit coordinate (y2_hi y2_lo)
                        ;
                        ; We calculate these values from the X1TB, X2TB and Y1TB
                        ; line coordinate values for the line we want to draw
                        ; (where Y1TB contains the Y1 and Y2 y-coordinates, one
                        ; in each nibble)

 AND #$0F               ; Set Y1 to the low nibble of A, which contains the
 STA Y1                 ; y-coordinate of the start of the line, i.e. Y1

 TAX                    ; Set X to the y-coordinate of the start of the line, Y1

 ASL A                  ; Set A = A * 8 - scrollProgress
 ASL A                  ;       = Y1 * 8 - scrollProgress
 ASL A
 SEC
 SBC scrollProgress

 BCC drfr1              ; If the subtraction underflowed then this coordinate is
                        ; not on-screen, so jump to drfr1 to move on to the next
                        ; coordinate

 STY YP                 ; Store the loop counter in YP, so we can retrieve it at
                        ; the end of the loop

 LDA BUF+16,X           ; Set Q to the entry from BUF+16 for the y-coordinate in
 STA Q                  ; X (which we set to Y1 above), so:
                        ;
                        ;   Q = X * 8 + 31 - scrollProgress
                        ;     = Y1 * 8 + 31 - scrollProgress

 LDA X1TB,Y             ; Set A to the x-coordinate of the start of the line, X1

 JSR ProjectScrollText  ; Set (A X) = 128 + 256 * (A - 32) / Q
                        ;           = 128 + 256 * (X1 - 32) / Q
                        ;
                        ; So (A X) is the x-coordinate of the start of the line,
                        ; projected onto the scroll text so coordinates bunch
                        ; together horizontally the further up the scroll text
                        ; they are

 STX XX15               ; Set the low byte of XX15(1 0) to X

 LDX Y1                 ; Set X = Y1, which we set to the y-coordinate of the
                        ; start of the line, i.e. Y1

 STA XX15+1             ; Set the high byte of XX15(1 0) to A, so we have:
                        ;
                        ;   XX15(1 0) = (A X)
                        ;                           256 * (X1 - 32)
                        ;             = 128 + ----------------------------
                        ;                     Y1 * 8 + 31 - scrollProgress

 LDA BUF,X              ; Set the low byte of XX15(3 2) to the entry from BUF+16
 STA XX15+2             ; for the y-coordinate in X (which we set to Y1 above)

 LDA #0                 ; Set the high byte of XX15(3 2) to 0
 STA XX15+3             ;
                        ; So we now have:
                        ;
                        ;                     37 - Y1 * 2 + scrollProgress / 4
                        ;   XX15(3 2) = 72 + ----------------------------------
                        ;                    2 * (31 + Y1 * 8 - scrollProgress)

 LDA Y1TB,Y             ; Set A to the combined y-coordinates of the start and
                        ; end of the line, Y1 and Y2, with one in each nibble

 LSR A                  ; Set the high byte of XX12(1 0) to the high nibble of
 LSR A                  ; A, which contains the y-coordinate of the end of the
 LSR A                  ; line, i.e. Y2
 LSR A
 STA XX12+1

 TAX                    ; Set X to the y-coordinate of the end of the line, Y2

 ASL A                  ; Set A = XX12+1 * 8 - scrollProgress
 ASL A                  ;       = Y2 * 8 - scrollProgress
 ASL A
 SEC
 SBC scrollProgress

 BCC drfr1              ; If the subtraction underflowed then this coordinate is
                        ; not on-screen, so jump to drfr1 to move on to the next
                        ; coordinate

 LDA BUF,X              ; Set the low byte of XX12(1 0) to the entry from BUF+16
 STA XX12               ; for the y-coordinate in X (which we set to Y2 above)

 LDA #0                 ; Set X to XX12+1, which we set to Y2 above, so X = Y2
 LDX XX12+1

 STA XX12+1             ; Set the high byte of XX12(1 0) to 0
                        ;
                        ; So we now have:
                        ;
                        ;                     37 - Y2 * 2 + scrollProgress / 4
                        ;   XX12(1 0) = 72 + ----------------------------------
                        ;                    2 * (31 + Y2 * 8 - scrollProgress)

 LDA BUF+16,X           ; Set Q to the entry from BUF+16 for the y-coordinate in
 STA Q                  ; X (which we set to Y2 above), so:
                        ;
                        ;   Q = X * 8 + 31 - scrollProgress
                        ;     = Y2 * 8 + 31 - scrollProgress

 SETUP_PPU_FOR_ICON_BAR ; If the PPU has started drawing the icon bar, configure
                        ; the PPU to use nametable 0 and pattern table 0

 LDA X2TB,Y             ; Set A to the x-coordinate of the end of the line, X2

 JSR ProjectScrollText  ; Set (A X) = 128 + 256 * (A - 32) / Q
                        ;           = 128 + 256 * (X1 - 32) / Q
                        ;
                        ; So (A X) is the x-coordinate of the end of the line,
                        ; projected onto the scroll text so coordinates bunch
                        ; together horizontally the further up the scroll text
                        ; they are

 STX XX15+4             ; Set XX15(5 4) = (A X)
 STA XX15+5             ;                           256 * (X2 - 32)
                        ;             = 128 + ----------------------------
                        ;                     Y2 * 8 + 31 - scrollProgress

 JSR CLIP_b1            ; Clip the following line to fit on-screen:
                        ;
                        ;   XX15(1 0) = x1 as a 16-bit coordinate (x1_hi x1_lo)
                        ;
                        ;   XX15(3 2) = y1 as a 16-bit coordinate (y1_hi y1_lo)
                        ;
                        ;   XX15(5 4) = x2 as a 16-bit coordinate (x2_hi x2_lo)
                        ;
                        ;   XX12(1 0) = y2 as a 16-bit coordinate (y2_hi y2_lo)
                        ;
                        ; and draw the line from (X1, Y1) to (X2, Y2) once it's
                        ; clipped

 LDY YP                 ; Set Y to the loop counter that we stored in YP above

 JMP drfr1              ; Loop back to drfr1 to process the next coordinate

; ******************************************************************************
;
;       Name: LTDEF
;       Type: Variable
;   Category: Combat demo
;    Summary: Line definitions for characters in the Star Wars scroll text
;  Deep dive: The 6502 Second Processor demo mode
;             The NES combat demo
;
; ------------------------------------------------------------------------------
;
; Characters in the scroll text are drawn using lines on a 3x6 numbered grid
; like this:
;
;   0   1   2
;   .   .   .
;   3   4   5
;   .   .   .
;   6   7   8
;   9   A   B
;
; The low nibble of each byte is the starting point for that line segment, and
; the high nibble is the end point, so a value of $28, for example, means
; "draw a line from point 8 to point 2". This table contains definitions for all
; the characters we can use in the scroll text, as lines on the above grid.
;
; See the deep dive on "the 6502 Second Processor demo mode" for details.
;
; ******************************************************************************

.LTDEF

 EQUB $00, $00, $00, $00, $00   ; Letter definition for " " (blank)
 EQUB $14, $25, $12, $45, $78   ; Letter definition for "!"
 EQUB $24, $00, $00, $00, $00   ; Letter definition for """ ("'")
 EQUB $02, $17, $68, $00, $00   ; Letter definition for "#" (serif "I")
 EQUB $35, $36, $47, $58, $00   ; Letter definition for "$" ("m")
 EQUB $47, $11, $00, $00, $00   ; Letter definition for "%" ("i")
 EQUB $17, $35, $00, $00, $00   ; Letter definition for "&" ("+")
 EQUB $36, $47, $34, $00, $00   ; Letter definition for "'" ("n")
 EQUB $12, $13, $37, $78, $00   ; Letter definition for "("
 EQUB $01, $15, $57, $67, $00   ; Letter definition for ")"
 EQUB $17, $35, $08, $26, $00   ; Letter definition for "*"
 EQUB $17, $35, $00, $00, $00   ; Letter definition for "+"
 EQUB $36, $34, $47, $67, $79   ; Letter definition for ","
 EQUB $35, $00, $00, $00, $00   ; Letter definition for "-"
 EQUB $36, $34, $47, $67, $00   ; Letter definition for "."
 EQUB $16, $00, $00, $00, $00   ; Letter definition for "/"
 EQUB $37, $13, $15, $57, $00   ; Letter definition for "0"
 EQUB $13, $17, $00, $00, $00   ; Letter definition for "1"
 EQUB $02, $25, $35, $36, $68   ; Letter definition for "2"
 EQUB $02, $28, $68, $35, $00   ; Letter definition for "3"
 EQUB $28, $23, $35, $00, $00   ; Letter definition for "4"
 EQUB $02, $03, $35, $58, $68   ; Letter definition for "5"
 EQUB $02, $06, $68, $58, $35   ; Letter definition for "6"
 EQUB $02, $28, $00, $00, $00   ; Letter definition for "7"
 EQUB $06, $02, $28, $68, $35   ; Letter definition for "8"
 EQUB $28, $02, $03, $35, $00   ; Letter definition for "9"
 EQUB $13, $34, $46, $00, $00   ; Letter definition for ":" ("s")
 EQUB $01, $06, $34, $67, $00   ; Letter definition for ";" (slim "E")
 EQUB $13, $37, $00, $00, $00   ; Letter definition for "<"
 EQUB $45, $78, $00, $00, $00   ; Letter definition for "="
 EQUB $00, $00, $00, $00, $00   ; Letter definition for ">" (blank)
 EQUB $00, $00, $00, $00, $00   ; Letter definition for "?" (blank)
 EQUB $00, $00, $00, $00, $00   ; Letter definition for "@" (blank)
 EQUB $06, $02, $28, $35, $00   ; Letter definition for "A"
 EQUB $06, $02, $28, $68, $35   ; Letter definition for "B"
 EQUB $68, $06, $02, $00, $00   ; Letter definition for "C"
 EQUB $06, $05, $56, $00, $00   ; Letter definition for "D"
 EQUB $68, $06, $02, $35, $00   ; Letter definition for "E"
 EQUB $06, $02, $35, $00, $00   ; Letter definition for "F"
 EQUB $45, $58, $68, $60, $02   ; Letter definition for "G"
 EQUB $06, $28, $35, $00, $00   ; Letter definition for "H"
 EQUB $17, $00, $00, $00, $00   ; Letter definition for "I"
 EQUB $28, $68, $36, $00, $00   ; Letter definition for "J"
 EQUB $06, $23, $38, $00, $00   ; Letter definition for "K"
 EQUB $68, $06, $00, $00, $00   ; Letter definition for "L"
 EQUB $06, $04, $24, $28, $00   ; Letter definition for "M"
 EQUB $06, $08, $28, $00, $00   ; Letter definition for "N"
 EQUB $06, $02, $28, $68, $00   ; Letter definition for "O"
 EQUB $06, $02, $25, $35, $00   ; Letter definition for "P"
 EQUB $06, $02, $28, $68, $48   ; Letter definition for "Q"
 EQUB $06, $02, $25, $35, $48   ; Letter definition for "R"
 EQUB $02, $03, $35, $58, $68   ; Letter definition for "S"
 EQUB $02, $17, $00, $00, $00   ; Letter definition for "T"
 EQUB $28, $68, $06, $00, $00   ; Letter definition for "U"
 EQUB $27, $07, $00, $00, $00   ; Letter definition for "V"
 EQUB $28, $48, $46, $06, $00   ; Letter definition for "W"
 EQUB $26, $08, $00, $00, $00   ; Letter definition for "X"
 EQUB $47, $04, $24, $00, $00   ; Letter definition for "Y"
 EQUB $02, $26, $68, $00, $00   ; Letter definition for "Z"

; ******************************************************************************
;
;       Name: NOFX
;       Type: Variable
;   Category: Combat demo
;    Summary: The x-coordinates of the scroll text letter grid
;
; ******************************************************************************

.NOFX

 EQUB 1                 ; Grid points 0-2
 EQUB 2
 EQUB 3

 EQUB 1                 ; Grid points 3-5
 EQUB 2
 EQUB 3

 EQUB 1                 ; Grid points 6-8
 EQUB 2
 EQUB 3

 EQUB 1                 ; Grid points 9-B
 EQUB 2
 EQUB 3

; ******************************************************************************
;
;       Name: NOFY
;       Type: Variable
;   Category: Combat demo
;    Summary: The y-coordinates of the scroll text letter grid
;
; ******************************************************************************

.NOFY

 EQUB 0                 ; Grid points 0-2
 EQUB 0
 EQUB 0

 EQUB WY                ; Grid points 3-5
 EQUB WY
 EQUB WY

 EQUB 2*WY              ; Grid points 6-8
 EQUB 2*WY
 EQUB 2*WY

 EQUB 3*WY              ; Grid points 9-B
 EQUB 3*WY
 EQUB 3*WY

; ******************************************************************************
;
;       Name: scrollText1Lo
;       Type: Variable
;   Category: Combat demo
;    Summary: Lookup table for the low byte of the address of the scrollText1
;             text for each language
;  Deep dive: Multi-language support in NES Elite
;
; ******************************************************************************

.scrollText1Lo

 EQUB LO(scrollText1_EN)    ; English

 EQUB LO(scrollText1_DE)    ; German

 EQUB LO(scrollText1_FR)    ; French

 EQUB LO(scrollText1_EN)    ; There is no fourth language, so this byte is
                            ; ignored

; ******************************************************************************
;
;       Name: scrollText1Hi
;       Type: Variable
;   Category: Combat demo
;    Summary: Lookup table for the high byte of the address of the scrollText1
;             text for each language
;  Deep dive: Multi-language support in NES Elite
;
; ******************************************************************************

.scrollText1Hi

 EQUB HI(scrollText1_EN)    ; English

 EQUB HI(scrollText1_DE)    ; German

 EQUB HI(scrollText1_FR)    ; French

 EQUB HI(scrollText1_EN)    ; There is no fourth language, so this byte is
                            ; ignored

; ******************************************************************************
;
;       Name: scrollText2Lo
;       Type: Variable
;   Category: Combat demo
;    Summary: Lookup table for the low byte of the address of the scrollText2
;             text for each language
;  Deep dive: Multi-language support in NES Elite
;
; ******************************************************************************

.scrollText2Lo

 EQUB LO(scrollText2_EN)    ; English

 EQUB LO(scrollText2_DE)    ; German

 EQUB LO(scrollText2_FR)    ; French

 EQUB LO(scrollText2_EN)    ; There is no fourth language, so this byte is
                            ; ignored

; ******************************************************************************
;
;       Name: scrollText2Hi
;       Type: Variable
;   Category: Combat demo
;    Summary: Lookup table for the high byte of the address of the scrollText2
;             text for each language
;  Deep dive: Multi-language support in NES Elite
;
; ******************************************************************************

.scrollText2Hi

 EQUB HI(scrollText2_EN)    ; English

 EQUB HI(scrollText2_DE)    ; German

 EQUB HI(scrollText2_FR)    ; French

 EQUB HI(scrollText2_EN)    ; There is no fourth language, so this byte is
                            ; ignored

; ******************************************************************************
;
;       Name: creditsText1Lo
;       Type: Variable
;   Category: Combat demo
;    Summary: Lookup table for the low byte of the address of the creditsText1
;             text for each language
;
; ******************************************************************************

.creditsText1Lo

 EQUB LO(creditsText1)  ; English

 EQUB LO(creditsText1)  ; German

 EQUB LO(creditsText1)  ; French

 EQUB LO(creditsText1)  ; There is no fourth language, so this byte is ignored

; ******************************************************************************
;
;       Name: creditsText1Hi
;       Type: Variable
;   Category: Combat demo
;    Summary: Lookup table for the high byte of the address of the creditsText1
;             text for each language
;
; ******************************************************************************

.creditsText1Hi

 EQUB HI(creditsText1)  ; English

 EQUB HI(creditsText1)  ; German

 EQUB HI(creditsText1)  ; French

 EQUB HI(creditsText1)  ; There is no fourth language, so this byte is ignored

; ******************************************************************************
;
;       Name: creditsText2Lo
;       Type: Variable
;   Category: Combat demo
;    Summary: Lookup table for the low byte of the address of the creditsText2
;             text for each language
;
; ******************************************************************************

.creditsText2Lo

 EQUB LO(creditsText2)  ; English

 EQUB LO(creditsText2)  ; German

 EQUB LO(creditsText2)  ; French

 EQUB LO(creditsText2)  ; There is no fourth language, so this byte is ignored

; ******************************************************************************
;
;       Name: creditsText2Hi
;       Type: Variable
;   Category: Combat demo
;    Summary: Lookup table for the high byte of the address of the creditsText2
;             text for each language
;
; ******************************************************************************

.creditsText2Hi

 EQUB HI(creditsText2)  ; English

 EQUB HI(creditsText2)  ; German

 EQUB HI(creditsText2)  ; French

 EQUB HI(creditsText2)  ; There is no fourth language, so this byte is ignored

; ******************************************************************************
;
;       Name: creditsText3Lo
;       Type: Variable
;   Category: Combat demo
;    Summary: Lookup table for the low byte of the address of the creditsText3
;             text for each language
;
; ******************************************************************************

.creditsText3Lo

 EQUB LO(creditsText3)  ; English

 EQUB LO(creditsText3)  ; German

 EQUB LO(creditsText3)  ; French

 EQUB LO(creditsText3)  ; There is no fourth language, so this byte is ignored

; ******************************************************************************
;
;       Name: creditsText3Hi
;       Type: Variable
;   Category: Combat demo
;    Summary: Lookup table for the high byte of the address of the creditsText3
;             text for each language
;
; ******************************************************************************

.creditsText3Hi

 EQUB HI(creditsText3)  ; English

 EQUB HI(creditsText3)  ; German

 EQUB HI(creditsText3)  ; French

 EQUB HI(creditsText3)  ; There is no fourth language, so this byte is ignored

; ******************************************************************************
;
;       Name: scrollText1_EN
;       Type: Variable
;   Category: Combat demo
;    Summary: Text for the first scroll text in English
;  Deep dive: Multi-language support in NES Elite
;             The NES combat demo
;
; ******************************************************************************

.scrollText1_EN

IF _NTSC

 EQUS "   NTSC EMULATION    "
 EQUS "  --- E L # T E ---  "
 EQUS "(C)BELL & BRABEN 1991"

ELIF _PAL

 EQUS " IMAGINEER PRESENTS  "
 EQUS "  --- E L # T E ---  "
 EQUS "(C)BRABEN & BELL 1991"

ENDIF

 EQUS "                     "
 EQUS "PREPARE FOR PRACTICE "
 EQUS "COMBAT SEQUENCE......"

; ******************************************************************************
;
;       Name: scrollText2_EN
;       Type: Variable
;   Category: Combat demo
;    Summary: Text for the second scroll text in English
;  Deep dive: Multi-language support in NES Elite
;             The NES combat demo
;
; ******************************************************************************

.scrollText2_EN

 EQUS " CONGRATULATIONS! YOU"
 EQUS "COMPLETED  THE COMBAT"
 EQUS " IN "
 EQUB $83, $82
 EQUS "  MIN  "
 EQUB $81, $80
 EQUS " SEC. "
 EQUS "                     "
 EQUS "YOU BEGIN YOUR CAREER"
 EQUS "DOCKED AT  THE PLANET"
 EQUS "LAVE WITH 100 CREDITS"
 EQUS "3 MISSILES AND A FULL"
 EQUS "TANK OF FUEL.        "
 EQUS "GOOD LUCK, COMMANDER!"

; ******************************************************************************
;
;       Name: scrollText1_FR
;       Type: Variable
;   Category: Combat demo
;    Summary: Text for the first scroll text in French
;  Deep dive: Multi-language support in NES Elite
;             The NES combat demo
;
; ******************************************************************************

.scrollText1_FR

IF _NTSC

 EQUS "   NTSC EMULATION    "
 EQUS "  --- E L # T E ---  "
 EQUS "(C)BELL & BRABEN 1991"

ELIF _PAL

 EQUS " IMAGINEER PRESENTE  "
 EQUS "  --- E L # T E ---  "
 EQUS "(C)BRABEN & BELL 1991"

ENDIF

 EQUS "                     "
 EQUS " PREPAREZ-VOUS  A  LA"
 EQUS "SIMULATION DU COMBAT!"

; ******************************************************************************
;
;       Name: scrollText2_FR
;       Type: Variable
;   Category: Combat demo
;    Summary: Text for the second scroll text in French
;  Deep dive: Multi-language support in NES Elite
;             The NES combat demo
;
; ******************************************************************************

.scrollText2_FR

 EQUS " FELICITATIONS! VOTRE"
 EQUS "COMBAT EST TERMINE EN"
 EQUS "   "
 EQUB $83, $82
 EQUS "  MIN  "
 EQUB $81, $80
 EQUS " SEC.  "
 EQUS "                     "
 EQUS " VOUS COMMENCEZ VOTRE"
 EQUS "COURS  SUR LA PLANETE"
 EQUS "LAVE AVEC 100 CREDITS"
 EQUS "ET TROIS MISSILES.   "
 EQUS "     BONNE CHANCE    "
 EQUS "     COMMANDANT!     "

; ******************************************************************************
;
;       Name: scrollText1_DE
;       Type: Variable
;   Category: Combat demo
;    Summary: Text for the first scroll text in German
;  Deep dive: Multi-language support in NES Elite
;             The NES combat demo
;
; ******************************************************************************

.scrollText1_DE

IF _NTSC

 EQUS "   NTSC EMULATION    "
 EQUS "  --- E L # T E ---  "
 EQUS "(C)BELL & BRABEN 1991"

ELIF _PAL

 EQUS "   IMAGINEER ZEIGT   "
 EQUS "  --- E L # T E ---  "
 EQUS "(C)BRABEN & BELL 1991"

ENDIF

 EQUS "                     "
 EQUS "RUSTEN  SIE  SICH ZUM"
 EQUS "PROBEKAMPF..........."

; ******************************************************************************
;
;       Name: scrollText2_DE
;       Type: Variable
;   Category: Combat demo
;    Summary: Text for the second scroll text in German
;  Deep dive: Multi-language support in NES Elite
;             The NES combat demo
;
; ******************************************************************************

.scrollText2_DE

 EQUS " BRAVO! SIE HABEN DEN"
 EQUS "KAMPF  GEWONNEN  ZEIT"
 EQUS "  "
 EQUB $83, $82
 EQUS "  MIN  "
 EQUB $81, $80
 EQUS "  SEK.  "
 EQUS "                     "
 EQUS "  SIE  BEGINNEN  IHRE"
 EQUS "KARRIERE  IM DOCK DES"
 EQUS "PLANETS LAVE MIT DREI"
 EQUS "RAKETEN, 100 CR,  UND"
 EQUS "EINEM VOLLEN TANK.   "
 EQUS "VIEL GLUCK,COMMANDER!"

; ******************************************************************************
;
;       Name: creditsText1
;       Type: Variable
;   Category: Combat demo
;    Summary: Text for the first part of the credits scroll text
;
; ******************************************************************************

.creditsText1

 EQUS "ORIGINAL GAME AND NES"
 EQUS "CONVERSION  BY  DAVID"
 EQUS "BRABEN  AND #AN BELL."
 EQUS "                     "
 EQUS "DEVELOPED USING  PDS."
 EQUS "HANDLED BY MARJACQ.  "
 EQUS "                     "
 EQUS "ARTWORK   BY  EUROCOM"
 EQUS "DEVELOPMENTS LTD.    "
 EQUS "                     "

; ******************************************************************************
;
;       Name: creditsText2
;       Type: Variable
;   Category: Combat demo
;    Summary: Text for the second part of the credits scroll text
;
; ******************************************************************************

.creditsText2

 EQUS "MUSIC & SOUNDS  CODED"
 EQUS "BY  DAVID  WHITTAKER."
 EQUS "                     "
 EQUS "MUSIC BY  AIDAN  BELL"
 EQUS "AND  JOHANN  STRAUSS."
 EQUS "                     "
 EQUS "TESTERS=CHRIS JORDAN,"
 EQUS "SAM AND JADE BRIANT, "
 EQUS "R AND M CHADWICK.    "

; ******************************************************************************
;
;       Name: creditsText3
;       Type: Variable
;   Category: Combat demo
;    Summary: Text for the third part of the credits scroll text
;
; ******************************************************************************

.creditsText3

 EQUS "ELITE LOGO DESIGN BY "
 EQUS "PHILIP CASTLE.       "
 EQUS "                     "
 EQUS "GAME TEXT TRANSLATERS"
 EQUS "UBI SOFT,            "
 EQUS "SUSANNE DIECK,       "
 EQUS "IMOGEN  RIDLER.      "

; ******************************************************************************
;
;       Name: saveHeader1_EN
;       Type: Subroutine
;   Category: Save and load
;    Summary: The Save and Load screen title in English
;  Deep dive: Multi-language support in NES Elite
;
; ------------------------------------------------------------------------------
;
; In the following, EQUB 12 is a newline and EQUB 6 switches to Sentence Case.
; The text is terminated by EQUB 0.
;
; ******************************************************************************

.saveHeader1_EN

 EQUS "STORED COMMANDERS"
 EQUB 12
 EQUB 12
 EQUB 12
 EQUB 6
 EQUB 0

; ******************************************************************************
;
;       Name: saveHeader2_EN
;       Type: Subroutine
;   Category: Save and load
;    Summary: The subheaders for the Save and Load screen title in English
;  Deep dive: Multi-language support in NES Elite
;
; ------------------------------------------------------------------------------
;
; In the following, EQUB 12 is a newline and the text is terminated by EQUB 0.
;
; ******************************************************************************

.saveHeader2_EN

 EQUS "                    STORED"
 EQUB 12
 EQUS "                    POSITIONS"
 EQUB 12
 EQUB 12
 EQUB 12
 EQUB 12
 EQUB 12
 EQUB 12
 EQUB 12
 EQUS "CURRENT"
 EQUB 12
 EQUS "POSITION"
 EQUB 0

; ******************************************************************************
;
;       Name: saveHeader1_DE
;       Type: Subroutine
;   Category: Save and load
;    Summary: The Save and Load screen title in German
;  Deep dive: Multi-language support in NES Elite
;
; ------------------------------------------------------------------------------
;
; In the following, EQUB 12 is a newline and EQUB 6 switches to Sentence Case.
; The text is terminated by EQUB 0.
;
; ******************************************************************************

.saveHeader1_DE

 EQUS "GESPEICHERTE KOMMANDANTEN"
 EQUB 12
 EQUB 12
 EQUB 12
 EQUB 6
 EQUB 0

; ******************************************************************************
;
;       Name: saveHeader2_DE
;       Type: Subroutine
;   Category: Save and load
;    Summary: The subheaders for the Save and Load screen title in German
;  Deep dive: Multi-language support in NES Elite
;
; ------------------------------------------------------------------------------
;
; In the following, EQUB 12 is a newline and the text is terminated by EQUB 0.
;
; ******************************************************************************

.saveHeader2_DE

 EQUS "                    GESP."
 EQUB 12
 EQUS "                   POSITIONEN"
 EQUB 12
 EQUB 12
 EQUB 12
 EQUB 12
 EQUB 12
 EQUB 12
 EQUB 12
 EQUS "GEGENW."
 EQUB 12
 EQUS "POSITION"
 EQUB 0

; ******************************************************************************
;
;       Name: saveHeader1_FR
;       Type: Subroutine
;   Category: Save and load
;    Summary: The Save and Load screen title in French
;  Deep dive: Multi-language support in NES Elite
;
; ------------------------------------------------------------------------------
;
; In the following, EQUB 12 is a newline and EQUB 6 switches to Sentence Case.
; The text is terminated by EQUB 0.
;
; ******************************************************************************

.saveHeader1_FR

 EQUS "COMMANDANTS SAUVEGARDES"
 EQUB 12
 EQUB 12
 EQUB 12
 EQUB 6
 EQUB 0

; ******************************************************************************
;
;       Name: saveHeader2_FR
;       Type: Subroutine
;   Category: Save and load
;    Summary: The subheaders for the Save and Load screen title in French
;  Deep dive: Multi-language support in NES Elite
;
; ------------------------------------------------------------------------------
;
; In the following, EQUB 12 is a newline and the text is terminated by EQUB 0.
;
; ******************************************************************************

.saveHeader2_FR

 EQUS "                    POSITIONS"
 EQUB 12
 EQUS "                  SAUVEGARD<ES"
 EQUB 12
 EQUB 12
 EQUB 12
 EQUB 12
 EQUB 12
 EQUB 12
 EQUB 12
 EQUS "POSITION"
 EQUB 12
 EQUS "ACTUELLE"
 EQUB 0

; ******************************************************************************
;
;       Name: xSaveHeader
;       Type: Variable
;   Category: Save and load
;    Summary: The text column for the Save and Load screen headers for each
;             language
;  Deep dive: Multi-language support in NES Elite
;
; ******************************************************************************

.xSaveHeader

 EQUB 8                 ; English

 EQUB 4                 ; German

 EQUB 4                 ; French

 EQUB 5                 ; There is no fourth language, so this byte is ignored

; ******************************************************************************
;
;       Name: saveHeader1Lo
;       Type: Variable
;   Category: Save and load
;    Summary: Lookup table for the low byte of the address of the saveHeader1
;             text for each language
;
; ******************************************************************************

.saveHeader1Lo

 EQUB LO(saveHeader1_EN)    ; English

 EQUB LO(saveHeader1_DE)    ; German

 EQUB LO(saveHeader1_FR)    ; French

; ******************************************************************************
;
;       Name: saveHeader1Hi
;       Type: Variable
;   Category: Save and load
;    Summary: Lookup table for the high byte of the address of the saveHeader1
;             text for each language
;
; ******************************************************************************

.saveHeader1Hi

 EQUB HI(saveHeader1_EN)    ; English

 EQUB HI(saveHeader1_DE)    ; German

 EQUB HI(saveHeader1_FR)    ; French

; ******************************************************************************
;
;       Name: saveHeader2Lo
;       Type: Variable
;   Category: Save and load
;    Summary: Lookup table for the low byte of the address of the saveHeader2
;             text for each language
;
; ******************************************************************************

.saveHeader2Lo

 EQUB LO(saveHeader2_EN)    ; English

 EQUB LO(saveHeader2_DE)    ; German

 EQUB LO(saveHeader2_FR)    ; French

; ******************************************************************************
;
;       Name: saveHeader2Hi
;       Type: Variable
;   Category: Save and load
;    Summary: Lookup table for the high byte of the address of the saveHeader2
;             text for each language
;
; ******************************************************************************

.saveHeader2Hi

 EQUB HI(saveHeader2_EN)    ; English

 EQUB HI(saveHeader2_DE)    ; German

 EQUB HI(saveHeader2_FR)    ; French

; ******************************************************************************
;
;       Name: saveBracketPatts
;       Type: Variable
;   Category: Save and load
;    Summary: Pattern numbers for the bracket on the Save and Load screen
;
; ******************************************************************************

.saveBracketPatts

 EQUB 104
 EQUB 106
 EQUB 105
 EQUB 106
 EQUB 105
 EQUB 106
 EQUB 105
 EQUB 106
 EQUB 107
 EQUB 106
 EQUB 105
 EQUB 106
 EQUB 105
 EQUB 106
 EQUB 108
 EQUB 0

; ******************************************************************************
;
;       Name: PrintSaveHeader
;       Type: Subroutine
;   Category: Save and load
;    Summary: Print header text for the Save and Load screen
;
; ------------------------------------------------------------------------------
;
; Arguments:
;
;   V(1 0)              The address of a null-terminated string to print
;
; ******************************************************************************

.PrintSaveHeader

 LDY #0                 ; Set an index in Y so we can work through the text

.stxt1

 LDA (V),Y              ; Fetch the Y-th character from V(1 0)

 BEQ stxt2              ; If A = 0 then we have reached the null terminator, so
                        ; jump to stxt2 to return from the subroutine

 JSR TT27_b2            ; Print the character in A

 INY                    ; Increment the character counter

 BNE stxt1              ; Loop back to print the next character (this BNE is
                        ; effectively a JMP as we will reach a null terminator
                        ; well before Y wraps around to zero)

.stxt2

 RTS                    ; Return from the subroutine

; ******************************************************************************
;
;       Name: SVE
;       Type: Subroutine
;   Category: Save and load
;    Summary: Display the Save and Load screen and process saving and loading of
;             commander files
;
; ------------------------------------------------------------------------------
;
; This routine does a similar job to the routine of the same name in the BBC
; Master version of Elite, but the code is significantly different.
;
; ******************************************************************************

.SVE

 LDA #$BB               ; Clear the screen and set the view type in QQ11 to $BB
 JSR TT66_b0            ; (Save and load with the normal and highlight fonts
                        ; loaded)

 LDA #$8B               ; Set the view type in QQ11 to $8B (Save and load with
 STA QQ11               ; no fonts loaded)

 LDY #0                 ; Clear bit 7 of autoPlayDemo so we do not play the demo
 STY autoPlayDemo       ; automatically while the save screen is active

 STY QQ17               ; Set QQ17 = 0 to switch to ALL CAPS

 STY YC                 ; Move the text cursor to row 0

 LDX languageIndex      ; Move the text cursor to the correct column for the
 LDA xSaveHeader,X      ; Stored Commanders title in the chosen language
 STA XC

 LDA saveHeader1Lo,X    ; Set V(1 0) to the address of the correct Stored
 STA V                  ; Commanders title for the chosen language
 LDA saveHeader1Hi,X
 STA V+1

 JSR PrintSaveHeader    ; Print the null-terminated string at V(1 0), which
                        ; prints the Stored Commanders title for the chosen
                        ; language at the top of the screen

 LDA #$BB               ; Set the view type in QQ11 to $BB (Save and load with
 STA QQ11               ; the normal and highlight fonts loaded)

 LDX languageIndex      ; Set V(1 0) to the address of the correct subheaders
 LDA saveHeader2Lo,X    ; for the Save and Load screen in the chosen language
 STA V                  ; (e.g. the "STORED POSITIONS" and "CURRENT POSITION"
 LDA saveHeader2Hi,X    ; subheaders in English)
 STA V+1

 JSR PrintSaveHeader    ; Print the null-terminated string at V(1 0), which
                        ; prints the subheaders

 JSR NLIN4              ; Draw a horizontal line on tile row 2 to box in the
                        ; title

 JSR SetScreenForUpdate ; Get the screen ready for updating by hiding all
                        ; sprites, after fading the screen to black if we are
                        ; changing view

                        ; We now draw the tall bracket image that sits between
                        ; the current and stored positions

 LDY #5*4               ; We are going to draw the bracket using sprites 5 to
                        ; 19, so set Y to the offset of sprite 5 in the sprite
                        ; buffer, where each sprite takes up four bytes

 LDA #57+YPAL           ; The top tile in the bracket is at y-coordinate 57, so
 STA T                  ; store this in T so we can use it as the y-coordinate
                        ; for each sprite as we draw the bracket downwards

 LDX #0                 ; The tile numbers are in the saveBracketPatts table, so
                        ; set X as an index to work our way through the table

.save1

 LDA #%00100010         ; Set the attributes for sprite Y / 4 as follows:
 STA attrSprite0,Y      ;
                        ;   * Bits 0-1    = sprite palette 2
                        ;   * Bit 5 set   = show behind background
                        ;   * Bit 6 clear = do not flip horizontally
                        ;   * Bit 7 clear = do not flip vertically

 LDA saveBracketPatts,X ; Set A to the X-th entry in the saveBracketPatts table

 BEQ save2              ; If A = 0 then we have reached the end of the tile
                        ; list, so jump to save2 to move on to the next stage

 STA pattSprite0,Y      ; Otherwise we have the next tile number, so set the
                        ; pattern number for sprite Y / 4 to A

 LDA #83                ; Set the x-coordinate for sprite Y / 4 to 83
 STA xSprite0,Y

 LDA T                  ; Set the x-coordinate for sprite Y / 4 to T
 STA ySprite0,Y

 CLC                    ; Set T = T + 8 so it points to the next row down (as
 ADC #8                 ; each row is eight pixels high)
 STA T

 INY                    ; Set Y = Y + 4 so it points to the next sprite in the
 INY                    ; sprite buffer (as each sprite takes up four bytes in
 INY                    ; the buffer)
 INY

 INX                    ; Increment the table index in X to point to the next
                        ; entry in the saveBracketPatts table

 JMP save1              ; Jump back to save1 to draw the next bracket tile

.save2

 STY CNT                ; Set CNT to the offset in the sprite buffer of the
                        ; next free sprite (i.e. the sprite after the last
                        ; sprite in the bracket) so we can pass it to
                        ; DrawSaveSlotMark below

                        ; We now draw dashes to the left of each of the save
                        ; slots on the right side of the screen

 LDY #7                 ; We are going to draw eight slot marks, so set a
                        ; counter in Y

.save3

 TYA                    ; Move the text cursor to row 6 + Y * 2
 ASL A                  ;
 CLC                    ; So the slot marks are printed on even rows from row 6
 ADC #6                 ; to row 20 (though we print them from bottom to top)
 STA YC

 LDX #20                ; Move the text cursor to column 20, so we print the
 STX XC                 ; slot mark in column 20

 JSR DrawSaveSlotMark   ; Draw the slot mark for save slot Y

 DEY                    ; Decrement the counter in Y

 BPL save3              ; Loop back until we have printed all eight slot marks

 JSR DrawSmallLogo_b4   ; Set the sprite buffer entries for the small Elite logo
                        ; in the top-left corner of the screen

                        ; We now work through the save slots and print their
                        ; names

 LDA #0                 ; Set A = 0 to use as the save slot number in the
                        ; following loop (the loop runs from A = 0 to 8, but we
                        ; only print the name for A = 0 to 7, and do nothing for
                        ; A = 8)

.save4

 CMP #8                 ; If A = 8, jump to save5 to skip the following
 BEQ save5              ; instruction

 JSR PrintSaveName      ; Print the name of the commander file saved in slot A

.save5

 CLC                    ; Set A = A + 1 to move on to the next save slot
 ADC #1

 CMP #9                 ; Loop back to save4 until we have processed all nine
 BCC save4              ; slots, leaving A = 9

 JSR HighlightSaveName  ; Print the name of the commander file saved in slot 9
                        ; as a highlighted name, so this prints the current
                        ; commander name on the left of the screen, under the
                        ; "CURRENT POSITION" header, in the highlight font

 JSR UpdateView_b0      ; Update the view to draw all the sprites and tiles
                        ; on-screen

 LDA #9                 ; Set A = 9, which is the slot number we use for the
                        ; current commander name on the left of the screen, so
                        ; this sets the initial position of the highlighted name
                        ; to the current commander name on the left

                        ; Fall through into MoveInLeftColumn to start iterating
                        ; around the main loop for the Save and Load screen

; ******************************************************************************
;
;       Name: MoveInLeftColumn
;       Type: Subroutine
;   Category: Save and load
;    Summary: Process moving the highlight when it's in the left column (the
;             current commander)
;
; ------------------------------------------------------------------------------
;
; Arguments:
;
;   A                   Must be set to 9, as that represents the slot number of
;                       the left column containing the current commander
;
; ******************************************************************************

.MoveInLeftColumn

 JSR SetupPPUForIconBar ; If the PPU has started drawing the icon bar, configure
                        ; the PPU to use nametable 0 and pattern table 0

 LDX controller1Left03  ; If the left button on controller 1 was not being held
 BPL mlef3              ; down four VBlanks ago or for the three VBlanks before
                        ; that, jump to mlef3 to check the right button

                        ; If we get here then the left button is being pressed,
                        ; so we need to move the highlight left from its current
                        ; position (which is given in A and is always 9) to the
                        ; right column

 JSR PrintSaveName      ; Print the name of the commander file in its current
                        ; position in A, to remove the highlight

 CMP #9                 ; If A = 9 then we have pressed the left button while
 BEQ mlef1              ; highlighting the current commander name on the left
                        ; of the screen, so we need to move the highlight to the
                        ; right column, so jump to mlef1 to do this
                        ;
                        ; This will always be the case as this routine is only
                        ; called with A = 9 (as that's the slot number we use
                        ; to represent the current commander in the left
                        ; column), so presumably this logic is left over from a
                        ; time when this routine was a bit more generic

 LDA #0                 ; Otherwise the highlight must currently be in either
                        ; the middle or right column, so set A = 0 so the
                        ; highlight moves to the top of the new column (though
                        ; again, this will never happen)

 JMP mlef2              ; Jump to mlef2 to move the highlight to the right
                        ; column

.mlef1

                        ; If we get here then we have pressed the left button
                        ; while highlighting the current commander name on the
                        ; left of the screen

 LDA #4                 ; Set A = 4 so the call to MoveInRightColumn moves the
                        ; highlight to slot 4 in the right column, which is at
                        ; the same vertical position as the current commander
                        ; name on the left

.mlef2

 JMP MoveInRightColumn  ; Move the highlight left to the specified slot number
                        ; in the right column and process any further button
                        ; presses accordingly

.mlef3

 LDX controller1Right03 ; If the right button on controller 1 was not being held
 BPL mlef6              ; down four VBlanks ago or for the three VBlanks before
                        ; that, jump to mlef6 to check the icon bar buttons

                        ; If we get here then the right button is being pressed,
                        ; so we need to move the highlight right from its
                        ; current position (which is given in A and is always 9)
                        ; to the middle column

 JSR PrintSaveName      ; Print the name of the commander file in its current
                        ; position in A, to remove the highlight

 CMP #9                 ; If A = 9 then we have pressed the right button while
 BEQ mlef4              ; highlighting the current commander name on the left of
                        ; the screen, so we need to move the highlight to the
                        ; middle column, so jump to mlef4 to do this
                        ;
                        ; This will always be the case as this routine is only
                        ; called with A = 9 (as that's the slot number we use
                        ; to represent the current commander in the left
                        ; column), so presumably this logic is left over from a
                        ; time when this routine was a bit more generic

 LDA #0                 ; Otherwise the highlight must currently be in either
                        ; the middle or right column, so set A = 0 so the
                        ; highlight moves to the top of the new column (though
                        ; again, this will never happen)

 JMP mlef5              ; Jump to mlef5 to move the highlight to the middle
                        ; column

.mlef4

                        ; If we get here then we have pressed the right button
                        ; while highlighting the current commander name on the
                        ; left of the screen

 LDA #4                 ; Set A = 4 so the call to MoveInMiddleColumn moves the
                        ; highlight to slot 4 in the middle column, which is at
                        ; the same vertical position as the current commander
                        ; name on the left

.mlef5

 JMP MoveInMiddleColumn ; Move the highlight left to the specified slot number
                        ; in the middle column and process any further button
                        ; presses accordingly

.mlef6

                        ; If we get here then neither of the left or right
                        ; buttons have been pressed, so we move on to checking
                        ; the icon bar buttons

 JSR CheckSaveLoadBar   ; Check the icon bar buttons to see if any of them have
                        ; been chosen

 BCS MoveInLeftColumn   ; The C flag will be set if we are to resume what we
                        ; were doing (so we pick up where we left off after
                        ; processing the pause menu, for example), so loop back
                        ; to the start of the routine to keep checking for left
                        ; and right button presses

                        ; If we get here then the C flag is clear and we need to
                        ; return from the SVE routine and go back to the icon
                        ; bar processing routine in TT102

 RTS                    ; Return from the subroutine

; ******************************************************************************
;
;       Name: CheckSaveLoadBar
;       Type: Subroutine
;   Category: Save and load
;    Summary: Check the icon bar buttons on the Save and Load icon bar and
;             process any choices
;
; ------------------------------------------------------------------------------
;
; Returns:
;
;   C flag              Determines the next step when we return from the
;                       routine:
;
;                         * Clear = exit from the SVE routine when we return and
;                                   go back to the icon bar processing routine
;                                   in TT102, so the button choice can be
;                                   processed there
;
;                         * Set = keep going as if nothing has happened (used to
;                                 resume from the pause menu or if nothing was
;                                 chosen, for example)
;
;   A                   A is preserved
;
; ******************************************************************************

.CheckSaveLoadBar

 LDX iconBarChoice      ; If iconBarChoice = 0 then nothing has been chosen on
 BEQ cbar1              ; the icon bar (if it had, iconBarChoice would contain
                        ; the number of the chosen icon bar button), so jump to
                        ; cbar1 to return from the subroutine with the C flag
                        ; set, so we pick up where we left off

 PHA                    ; Store the value of A on the stack so we can restore it
                        ; at the end of the subroutine

 CPX #7                 ; If the Change Commander Name button was pressed,
 BEQ cbar2              ; jump to cbar2 to process it

 TXA                    ; Otherwise set X to the button number to pass to the
                        ; CheckForPause routine

 JSR CheckForPause_b0   ; If the Start button has been pressed then process the
                        ; pause menu and set the C flag, otherwise clear it
                        ;
                        ; We now return this value of the C flag, so if we just
                        ; processed the pause menu then the C flag will be set,
                        ; so we pick up where we left off when we return,
                        ; otherwise it will be clear and we need to pass the
                        ; button choice back to TT102 to be processed there

 PLA                    ; Restore the value of A that we stored on the stack, so
                        ; A is preserved

 RTS                    ; Return from the subroutine

.cbar1

 SEC                    ; Set the C flag so that when we return from the
                        ; routine, we pick up where we left off

 RTS                    ; Return from the subroutine

.cbar2

 LDA COK                ; If bit 7 of COK is set, then cheat mode has been
 BMI cbar4              ; applied, so jump to cbar4 to return from the
                        ; subroutine with the C flag clear, as cheats can't
                        ; change their commander name

 LDA #0                 ; Set iconBarChoice = 0 to clear the icon button choice
 STA iconBarChoice      ; so we don't process it again

 JSR ChangeCmdrName_b6  ; Process changing the commander name

 LDA iconBarChoice      ; If iconBarChoice = 0 then nothing has been chosen on
 BEQ cbar3              ; the icon bar during the renaming routine (if it had,
                        ; iconBarChoice would contain the number of the chosen
                        ; icon bar button), so jump to cbar3 to force a reload
                        ; of the Save and Load screen

 CMP #7                 ; If the Change Commander Name button was pressed
 BEQ cbar2              ; during the renaming routine, jump to cbar2 to restart
                        ; the renaming process

.cbar3

 LDA #6                 ; Set iconBarChoice to the Save and Load button, so
 STA iconBarChoice      ; when we return from the routine with the C flag clear,
                        ; the TT102 routine processes this as if we had chosen
                        ; this button, and reloads the Save and Load screen

.cbar4

 CLC                    ; Clear the C flag so that when we return from the
                        ; routine, the button number in iconBarChoice is passed
                        ; to TT102 to be processed as a button choice

 PLA                    ; Restore the value of A that we stored on the stack, so
                        ; A is preserved

 RTS                    ; Return from the subroutine

; ******************************************************************************
;
;       Name: WaitForNoDirection
;       Type: Subroutine
;   Category: Controllers
;    Summary: Wait until the left and right buttons on controller 1 have been
;             released and remain released for at least four VBlanks
;
; ------------------------------------------------------------------------------
;
; Returns:
;
;   A                   A is preserved
;
; ******************************************************************************

.WaitForNoDirection

 PHA                    ; Store the value of A on the stack so we can restore it
                        ; at the end of the subroutine

.ndir1

 JSR SetupPPUForIconBar ; If the PPU has started drawing the icon bar, configure
                        ; the PPU to use nametable 0 and pattern table 0

 LDA controller1Left03  ; Keep looping back to ndir1 until both the left and
 ORA controller1Right03 ; right button on controller 1 have been released and
 BMI ndir1              ; remain released for at least four VBlanks

 PLA                    ; Restore the value of A that we stored on the stack, so
                        ; A is preserved

 RTS                    ; Return from the subroutine

; ******************************************************************************
;
;       Name: MoveToLeftColumn
;       Type: Subroutine
;   Category: Save and load
;    Summary: Move the highlight to the left column (the current commander)
;
; ******************************************************************************

.MoveToLeftColumn

 LDA #9                 ; Set A = 9 to set the position of the highlight to slot
                        ; 9, which we use to represent the current commander in
                        ; the left column

 JSR HighlightSaveName  ; Print the name of the commander file saved in slot 9
                        ; as a highlighted name, so this prints the current
                        ; commander name on the left of the screen, under the
                        ; "CURRENT POSITION" header, in the highlight font

 JSR UpdateSaveScreen   ; Update the screen

 JSR WaitForNoDirection ; Wait until the left and right buttons on controller 1
                        ; have been released and remain released for at least
                        ; four VBlanks

 JMP MoveInLeftColumn   ; Move the highlight to the current commander in the
                        ; left column and process any further button presses
                        ; accordingly

; ******************************************************************************
;
;       Name: MoveInRightColumn
;       Type: Subroutine
;   Category: Save and load
;    Summary: Process moving the highlight when it's in the right column (the
;             save slots)
;
; ------------------------------------------------------------------------------
;
; Arguments:
;
;   A                   The slot number in the right column containing the
;                       highlight (0 to 7)
;
; ******************************************************************************

.MoveInRightColumn

 JSR HighlightSaveName  ; Highlight the name of the save slot in A, so the
                        ; highlight is shown in the correct slot in the right
                        ; column

 JSR UpdateSaveScreen   ; Update the screen

 JSR WaitForNoDirection ; Wait until the left and right buttons on controller 1
                        ; have been released and remain released for at least
                        ; four VBlanks

.mrig1

 JSR SetupPPUForIconBar ; If the PPU has started drawing the icon bar, configure
                        ; the PPU to use nametable 0 and pattern table 0

 LDX controller1Up      ; If the up button on controller 1 is not being pressed,
 BPL mrig2              ; jump to mrig2 to move on to the next button

                        ; If we get here then the up button is being pressed

 CMP #0                 ; If A = 0 then we are already in the top slot in the
 BEQ mrig2              ; column, so jump to mrig2 to move on to the next button
                        ; as we can't move beyond the top of the column

 JSR PrintSaveName      ; Print the name of the commander file saved in slot A
                        ; so that it reverts to the normal font, as we are about
                        ; to move the highlight elsewhere

 SEC                    ; Set A = A - 1
 SBC #1                 ;
                        ; So A is now the slot number of the slot above

 JSR HighlightSaveName  ; Highlight the name of the save slot in A, so the
                        ; highlight moves to the new position

 JSR UpdateSaveScreen   ; Update the screen

.mrig2

 LDX controller1Down    ; If the down button on controller 1 is not being
 BPL mrig3              ; pressed, jump to mrig3 to move on to the next button

                        ; If we get here then the down button is being pressed

 CMP #7                 ; If A >= 7 then we are already in the bottom slot in
 BCS mrig3              ; the column, so jump to mrig3 to move on to the next
                        ; button as we can't move beyond the bottom of the
                        ; column

 JSR PrintSaveName      ; Print the name of the commander file saved in slot A
                        ; so that it reverts to the normal font, as we are about
                        ; to move the highlight elsewhere

 CLC                    ; Set A = A + 1
 ADC #1                 ;
                        ; So A is now the slot number of the slot below

 JSR HighlightSaveName  ; Highlight the name of the save slot in A, so the
                        ; highlight moves to the new position

 JSR UpdateSaveScreen   ; Update the screen

.mrig3

 LDX controller1Left03  ; If the left button on controller 1 was not being held
 BPL mrig4              ; down four VBlanks ago, jump to mrig4 to move on to the
                        ; next button

                        ; If we get here then the left button is being pressed

 JSR PrintSaveName      ; Print the name of the commander file saved in slot A
                        ; so that it reverts to the normal font, as we are about
                        ; to move the highlight elsewhere

 JMP MoveInMiddleColumn ; Move the highlight left to the specified slot number
                        ; in the middle column and process any further button
                        ; presses accordingly

.mrig4

 LDX controller1Right03 ; If the right button on controller 1 was not being held
 BPL mrig5              ; down four VBlanks ago, jump to mrig5 to check the icon
                        ; bar buttons

                        ; If we get here then the right button is being pressed

 JSR PrintSaveName      ; Print the name of the commander file saved in slot A
                        ; so that it reverts to the normal font, as we are about
                        ; to move the highlight elsewhere

 LDA #4                 ; This instruction has no effect as the first thing that
                        ; MoveToLeftColumn does is to set A to 9, which is the
                        ; slot number for the current commander

 JMP MoveToLeftColumn   ; Move the highlight to the left column (the current
                        ; commander) and process any further button presses
                        ; accordingly

.mrig5

                        ; If we get here then neither of the left or right
                        ; buttons have been pressed, so we move on to checking
                        ; the icon bar buttons

 JSR CheckSaveLoadBar   ; Check the icon bar buttons to see if any of them have
                        ; been chosen

 BCS mrig1              ; The C flag will be set if we are to resume what we
                        ; were doing (so we pick up where we left off after
                        ; processing the pause menu, for example, or keep going
                        ; if no button was chosen), so loop back to mrig1 to
                        ; keep checking for left and right button presses

                        ; If we get here then the C flag is clear and we need to
                        ; return from the SVE routine and go back to the icon
                        ; bar processing routine in TT102, so the button choice
                        ; can be processed there

 RTS                    ; Return from the subroutine

; ******************************************************************************
;
;       Name: MoveInMiddleColumn
;       Type: Subroutine
;   Category: Save and load
;    Summary: Process moving the highlight when it's in the middle column
;
; ------------------------------------------------------------------------------
;
; Arguments:
;
;   A                   The slot number in the middle column containing the
;                       highlight (0 to 7)
;
; ******************************************************************************

.MoveInMiddleColumn

 JSR PrintNameInMiddle  ; Print the name of the commander file in A, so the
                        ; highlight is shown in the correct slot in the middle
                        ; column

 JSR UpdateSaveScreen   ; Update the screen

 JSR WaitForNoDirection ; Wait until the left and right buttons on controller 1
                        ; have been released and remain released for at least
                        ; four VBlanks

.mmid1

 JSR SetupPPUForIconBar ; If the PPU has started drawing the icon bar, configure
                        ; the PPU to use nametable 0 and pattern table 0

 LDX controller1Up      ; If the up button on controller 1 is not being pressed,
 BPL mmid2              ; jump to mmid2 to move on to the next button

                        ; If we get here then the up button is being pressed

 CMP #0                 ; If A = 0 then we are already in the top slot in the
 BEQ mmid2              ; column, so jump to mmid2 to move on to the next button
                        ; as we can't move beyond the top of the column

 JSR ClearNameInMiddle  ; Clear the name of the commander file from slot A in
                        ; the middle column, as we are about to move the
                        ; highlight elsewhere

 SEC                    ; Set A = A - 1
 SBC #1                 ;
                        ; So A is now the slot number of the slot above

 JSR PrintNameInMiddle  ; Print the name of the commander file in slot A in the
                        ; middle column, so the highlight moves to the new
                        ; position

 JSR UpdateSaveScreen   ; Update the screen

.mmid2

 LDX controller1Down    ; If the down button on controller 1 is not being
 BPL mmid3              ; pressed, jump to mmid3 to move on to the next button

                        ; If we get here then the down button is being pressed

 CMP #7                 ; If A >= 7 then we are already in the bottom slot in
 BCS mmid3              ; the column, so jump to mmid3 to move on to the next
                        ; button as we can't move beyond the bottom of the
                        ; column

 JSR ClearNameInMiddle  ; Clear the name of the commander file from slot A in
                        ; the middle column, as we are about to move the
                        ; highlight elsewhere

 CLC                    ; Set A = A + 1
 ADC #1                 ;
                        ; So A is now the slot number of the slot below

 JSR PrintNameInMiddle  ; Print the name of the commander file in slot A in the
                        ; middle column, so the highlight moves to the new
                        ; position

 JSR UpdateSaveScreen   ; Update the screen

.mmid3

 LDX controller1Left03  ; If the left button on controller 1 was not being held
 BPL mmid4              ; down four VBlanks ago, jump to mmid4 to move on to the
                        ; next button

                        ; If we get here then the left button is being pressed

 CMP #4                 ; We can only move left from the middle column if we are
 BNE mmid4              ; at the same height as the current commander slot in
                        ; the column to the left
                        ;
                        ; The current commander slot is to the left of slot 4
                        ; in the middle column, so jump to mmid4 to move on to
                        ; the next button if we are not currently in slot 4 in
                        ; the middle column

                        ; If we get here then we are in slot 4 in the middle
                        ; column, so we can now move left

 JSR ClearNameInMiddle  ; Clear the name of the commander file from slot A in
                        ; the middle column, as we are about to move the
                        ; highlight elsewhere

 LDA #9                 ; Set A = 9 to set the position of the highlight to slot
                        ; 9, which we use to represent the current commander in
                        ; the left column

 JSR SaveLoadCommander  ; Load the chosen commander file into NAME to overwrite
                        ; the game's current commander, so this effectively
                        ; loads the chosen commander into the game

 JSR UpdateIconBar_b3   ; Update the icon bar in case we just changed the
                        ; current commander to a cheat file, in which case we
                        ; hide the button that lets you change the commander
                        ; name

 JMP MoveToLeftColumn   ; Move the highlight to the left column (the current
                        ; commander) and process any further button presses
                        ; accordingly

.mmid4

 LDX controller1Right03 ; If the right button on controller 1 was not being held
 BPL mmid5              ; down four VBlanks ago, jump to mmid5 to check the icon
                        ; bar buttons

                        ; If we get here then the right button is being pressed

 JSR ClearNameInMiddle  ; Clear the name of the commander file from slot A in
                        ; the middle column, as we are about to move the
                        ; highlight elsewhere

 JSR SaveLoadCommander  ; Save the commander into the chosen save slot by
                        ; splitting it up and saving it into three parts in
                        ; saveSlotPart1, saveSlotPart2 and saveSlotPart3

 JMP MoveInRightColumn  ; Move the highlight to the right column (the save
                        ; slots) and process any further button presses
                        ; accordingly

.mmid5

                        ; If we get here then neither of the left or right
                        ; buttons have been pressed, so we move on to checking
                        ; the icon bar buttons

 JSR CheckSaveLoadBar   ; Check the icon bar buttons to see if any of them have
                        ; been chosen

 BCS mmid1              ; The C flag will be set if we are to resume what we
                        ; were doing (so we pick up where we left off after
                        ; processing the pause menu, for example, or keep going
                        ; if no button was chosen), so loop back to mmid1 to
                        ; keep checking for left and right button presses

                        ; If we get here then the C flag is clear and we need to
                        ; return from the SVE routine and go back to the icon
                        ; bar processing routine in TT102, so the button choice
                        ; can be processed there

 RTS                    ; Return from the subroutine

; ******************************************************************************
;
;       Name: DrawSaveSlotMark
;       Type: Subroutine
;   Category: Save and load
;    Summary: Draw a slot mark (a dash) next to a saved slot
;
; ------------------------------------------------------------------------------
;
; Arguments:
;
;   Y                   The save slot number (0 to 7)
;
;   CNT                 The offset of the first free sprite in the sprite buffer
;
; ------------------------------------------------------------------------------
;
; Returns:
;
;   Y                   Y is preserved
;
; ******************************************************************************

.DrawSaveSlotMark

 STY YSAV2              ; Store Y in YSAV2 so we can retrieve it below

 LDY CNT                ; Set Y to the offset of the first free sprite in the
                        ; sprite buffer

 LDA #109               ; Set the pattern number for sprite Y to 109, which is
 STA pattSprite0,Y      ; the dash that we want to use for the slot mark

 LDA XC                 ; Set the x-coordinate for sprite Y to XC * 8
 ASL A                  ;
 ASL A                  ; As each tile is eight pixels wide, this sets the pixel
 ASL A                  ; x-coordinate to tile column XC
 ADC #0
 STA xSprite0,Y

 LDA #%00100010         ; Set the attributes for sprite Y as follows:
 STA attrSprite0,Y      ;
                        ;   * Bits 0-1    = sprite palette 2
                        ;   * Bit 5 set   = show behind background
                        ;   * Bit 6 clear = do not flip horizontally
                        ;   * Bit 7 clear = do not flip vertically

 LDA YC                 ; Set the y-coordinate for sprite Y to 6 + YC * 8
 ASL A                  ;
 ASL A                  ; As each tile is eight pixels tall, this sets the pixel
 ASL A                  ; y-coordinate to the sixth pixel line within tile row
 ADC #6+YPAL            ; YC
 STA ySprite0,Y

 TYA                    ; Set CNT = Y + 4
 CLC                    ;
 ADC #4                 ; So CNT points to the next sprite in the sprite buffer
 STA CNT                ; (as each sprite takes up four bytes in the buffer)

 LDY YSAV2              ; Restore the value of Y that we stored in YSAV2 above
                        ; so that Y is preserved

 RTS                    ; Return from the subroutine

; ******************************************************************************
;
;       Name: PrintSaveName
;       Type: Subroutine
;   Category: Save and load
;    Summary: Print the name of a specific save slot
;
; ------------------------------------------------------------------------------
;
; Arguments:
;
;   A                   The save slot number to print:
;
;                         * 0 to 7 = print the name of a specific save slot on
;                                    the right of the screen
;
;                         * 8 = print the current commander name in the middle
;                               column
;
;                         * 9 = print the current commander name in the left
;                               column
;
; ------------------------------------------------------------------------------
;
; Returns:
;
;   A                   A is preserved
;
; ******************************************************************************

.PrintSaveName

 JSR CopyCommanderToBuf ; Copy the commander file from save slot A into the
                        ; buffer at BUF, so we can access its name

 PHA                    ; Store the value of A on the stack so we can restore it
                        ; at the end of the subroutine

 CMP #8                 ; If A < 8 then this is one of the save slots on the
 BCC psav3              ; right of the screen, so jump to pav3 to print the name
                        ; in the right column

 LDX #1                 ; Move the text cursor to column 1
 STX XC

 CMP #9                 ; If A < 9 then A = 8, which represents the middle
 BCC psav2              ; column, so jump to psav2 to print the name in the
                        ; middle column

 BEQ psav1              ; If A = 9 then this represents the current commander in
                        ; the left column so jump to psav1 to print the name on
                        ; the left of the screen

                        ; If we get here then A >= 10, which is never the case,
                        ; so this code might be left over from functionality
                        ; that was later removed

 LDA #18                ; Move the text cursor to row 18
 STA YC

 JMP psav4              ; Jump to psav4 to print the name of the file in the
                        ; save slot

.psav1

                        ; If we get here then A = 9, so we need to print the
                        ; commander name in the left column

 LDA #14                ; Move the text cursor to row 14
 STA YC

 JMP psav4              ; Jump to psav4 to print the name of the file in the
                        ; save slot

.psav2

                        ; If we get here then A = 8, so we need to print the
                        ; commander name in the middle column

 LDA #6                 ; Move the text cursor to row 6
 STA YC

 JMP psav4              ; Jump to psav4 to print the name of the file in the
                        ; save slot

.psav3

                        ; If we get here then A is in the range 0 to 7, so we
                        ; need to print the commander name in the right column

 ASL A                  ; Move the text cursor to row 6 + A * 2
 CLC                    ;
 ADC #6                 ; So this is the text row for slot number A in the right
 STA YC                 ; column of the screen

 LDA #21                ; Move the text cursor to column 21 for the column of
 STA XC                 ; slot names on the right of the screen

.psav4

 PLA                    ; Restore the value of A that we stored on the stack, so
                        ; A is preserved

                        ; Fall through into PrintCommanderName to print the name
                        ; of the commander file in BUF, followed by the save
                        ; count

; ******************************************************************************
;
;       Name: PrintCommanderName
;       Type: Subroutine
;   Category: Save and load
;    Summary: Print the commander name from the commander file in BUF, with the
;             save count added to the end
;
; ------------------------------------------------------------------------------
;
; Returns:
;
;   A                   A is preserved
;
; ******************************************************************************

.PrintCommanderName

 PHA                    ; Store the value of A on the stack so we can restore it
                        ; at the end of the subroutine

 LDY #0                 ; We start by printing the commander name from the first
                        ; seven bytes of the commander file at BUF, so set a
                        ; character index in Y so we can loop though the name
                        ; one character at a time

.pnam1

 LDA BUF,Y              ; Set A to the Y-th character from the name at BUF

 JSR DASC_b2            ; Print the character

 INY                    ; Increment the character index in Y

 CPY #7                 ; Loop back until we have printed all seven characters
 BCC pnam1              ; in the BUF buffer from BUF to BUF+6

                        ; Now that the name is printed, we print the save count
                        ; after the end of the name as a one- or two-digit
                        ; decimal value

 LDX #0                 ; Set X = 0 to use as a division counter in the loop
                        ; below

 LDA BUF+7              ; Set A to the byte after the end of the name, which
                        ; contains the save counter in SVC

 AND #%01111111         ; Clear bit 7 of the save counter so we are left with
                        ; the number of saves in A

 SEC                    ; Set the C flag for the subtraction below

.pnam2

 SBC #10                ; Set A = A - 10

 INX                    ; Increment X

 BCS pnam2              ; If the subtraction didn't underflow, jump back to
                        ; pnam2 to subtract another 10

 TAY                    ; By this point X contains the number of whole tens in
                        ; the original number, plus 1 (as that extra one broke
                        ; the subtraction), while A contains the remainder, so
                        ; this instruction sets Y so the following is true:
                        ;
                        ;   SVC = 10 * (X + 1) - (10 - Y)
                        ;       = 10 * (X + 1) + (Y - 10)

 LDA #' '               ; Set A to the ASCII for space

 DEX                    ; Decrement X so this is now true:
                        ;
                        ;   SVC = 10 * X + (Y - 10)

 BEQ pnam3              ; If X = 0 then jump to pnam3 to print a space for the
                        ; first digit of the save count, as it is less than ten

 TXA                    ; Otherwise set A to the ASCII code for the digit in X
 ADC #'0'               ; so we print the correct tens digit for the save
                        ; counter

.pnam3

 JSR DASC_b2            ; Print the character in A to print the first digit of
                        ; the save counter

 TYA                    ; The remainder of the calculation above is Y - 10, so
 CLC                    ; to get the second digit in the value of SVC, we need
 ADC #'0'+10            ; to add 10 to the value in Y, before adding ASCII "0"
                        ; to convert it into a character

 JSR DASC_b2            ; Print the character in A to print the second digit of
                        ; the save counter

 PLA                    ; Restore the value of A that we stored on the stack, so
                        ; A is preserved

 RTS                    ; Return from the subroutine

; ******************************************************************************
;
;       Name: HighlightSaveName
;       Type: Subroutine
;   Category: Save and load
;    Summary: Highlight the name of a specific save slot
;
; ------------------------------------------------------------------------------
;
; Arguments:
;
;   A                   The save slot number to highlight
;
; ******************************************************************************

.HighlightSaveName

 LDX #2                 ; Set the font style to print in the highlight font
 STX fontStyle

 JSR PrintSaveName      ; Print the name of the commander file saved in slot A

 LDX #1                 ; Set the font style to print in the normal font
 STX fontStyle

 RTS                    ; Return from the subroutine

; ******************************************************************************
;
;       Name: UpdateSaveScreen
;       Type: Subroutine
;   Category: Save and load
;    Summary: Update the Save and Load screen
;
; ------------------------------------------------------------------------------
;
; Returns:
;
;   A                   A is preserved
;
; ******************************************************************************

.UpdateSaveScreen

 PHA                    ; Store the value of A on the stack so we can restore it
                        ; at the end of the subroutine

 JSR DrawScreenInNMI_b0 ; Configure the NMI handler to draw the screen

 JSR WaitForPPUToFinish ; Wait until both bitplanes of the screen have been
                        ; sent to the PPU, so the screen is fully updated and
                        ; there is no more data waiting to be sent to the PPU

 PLA                    ; Restore the value of A that we stored on the stack, so
                        ; A is preserved

 RTS                    ; Return from the subroutine

; ******************************************************************************
;
;       Name: PrintNameInMiddle
;       Type: Subroutine
;   Category: Save and load
;    Summary: Print the commander name in the middle column using the highlight
;             font
;
; ------------------------------------------------------------------------------
;
; Arguments:
;
;   A                   The slot number in which to print the commander name in
;                       the middle column (0 to 7)
;
; ------------------------------------------------------------------------------
;
; Returns:
;
;   A                   A is preserved
;
; ******************************************************************************

.PrintNameInMiddle

 LDX #2                 ; Set the font style to print in the highlight font
 STX fontStyle

 LDX #11                ; Move the text cursor to column 11, so we print the
 STX XC                 ; name in the middle column of the screen

 PHA                    ; Store the value of A on the stack so we can restore it
                        ; after the following calculation

 ASL A                  ; Move the text cursor to row 6 + A * 2
 CLC                    ;
 ADC #6                 ; So this is the text row for slot number A in the
 STA YC                 ; middle column of the screen

 PLA                    ; Restore the value of A that we stored on the stack

 JSR PrintCommanderName ; Print the commander name from the commander file in
                        ; BUF, along with the save count

 LDX #1                 ; Set the font style to print in the normal font
 STX fontStyle

 RTS                    ; Return from the subroutine

; ******************************************************************************
;
;       Name: ClearNameInMiddle
;       Type: Subroutine
;   Category: Save and load
;    Summary: Remove the commander name from the middle column
;
; ------------------------------------------------------------------------------
;
; Arguments:
;
;   A                   The slot number to clear in the middle column (0 to 7)
;
; ------------------------------------------------------------------------------
;
; Returns:
;
;   A                   A is preserved
;
; ******************************************************************************

.ClearNameInMiddle

 LDX #11                ; Move the text cursor to column 11, so we print the
 STX XC                 ; name in the middle column of the screen

 PHA                    ; Store the value of A on the stack so we can restore it
                        ; at the end of the subroutine

 ASL A                  ; Move the text cursor to row 6 + A * 2
 CLC                    ;
 ADC #6                 ; So this is the text row for slot number A in the
 STA YC                 ; middle column of the screen

 JSR GetRowNameAddress  ; Get the addresses in the nametable buffers for the
                        ; start of character row YC, as follows:
                        ;
                        ;   SC(1 0) = the address in nametable buffer 0
                        ;
                        ;   SC2(1 0) = the address in nametable buffer 1

 LDA SC                 ; Set SC(1 0) = SC(1 0) + XC
 CLC                    ;
 ADC XC                 ; So SC(1 0) is the address in nametable buffer 0 for
 STA SC                 ; the tile at cursor position (XC, YC)

 LDY #8                 ; We now want to print 8 spaces over the top of the slot
                        ; at (XC, YC), so set Y as a loop counter to count down
                        ; from 8

 LDA #0                 ; Set A = 0 to use as the pattern number for the blank
                        ; background tile

.cpos1

 STA (SC),Y             ; Set the Y-th tile of the slot in nametable buffer 0 to
                        ; the blank tile

 DEY                    ; Decrement the tile counter

 BPL cpos1              ; Loop back until we have blanked out every character
                        ; of the slot

 PLA                    ; Restore the value of A that we stored on the stack, so
                        ; A is preserved

 RTS                    ; Return from the subroutine

; ******************************************************************************
;
;       Name: galaxySeeds
;       Type: Variable
;   Category: Save and load
;    Summary: The galaxy seeds to add to a commander save file
;
; ******************************************************************************

.galaxySeeds

 EQUB $4A, $5A, $48, $02, $53, $B7, $00, $00
 EQUB $94, $B4, $90, $04, $A6, $6F, $00, $00
 EQUB $29, $69, $21, $08, $4D, $DE, $00, $00
 EQUB $52, $D2, $42, $10, $9A, $BD, $00, $00
 EQUB $A4, $A5, $84, $20, $35, $7B, $00, $00
 EQUB $49, $4B, $09, $40, $6A, $F6, $00, $00
 EQUB $92, $96, $12, $80, $D4, $ED, $00, $00
 EQUB $25, $2D, $24, $01, $A9, $DB, $00, $00

; ******************************************************************************
;
;       Name: saveSlotAddr1
;       Type: Variable
;   Category: Save and load
;    Summary: The address of the first saved part for each save slot
;
; ******************************************************************************

.saveSlotAddr1

 EQUW saveSlotPart1 + 0 * 73
 EQUW saveSlotPart1 + 1 * 73
 EQUW saveSlotPart1 + 2 * 73
 EQUW saveSlotPart1 + 3 * 73
 EQUW saveSlotPart1 + 4 * 73
 EQUW saveSlotPart1 + 5 * 73
 EQUW saveSlotPart1 + 6 * 73
 EQUW saveSlotPart1 + 7 * 73

; ******************************************************************************
;
;       Name: saveSlotAddr2
;       Type: Variable
;   Category: Save and load
;    Summary: The address of the second saved part for each save slot
;
; ******************************************************************************

.saveSlotAddr2

 EQUW saveSlotPart2 + 0 * 73
 EQUW saveSlotPart2 + 1 * 73
 EQUW saveSlotPart2 + 2 * 73
 EQUW saveSlotPart2 + 3 * 73
 EQUW saveSlotPart2 + 4 * 73
 EQUW saveSlotPart2 + 5 * 73
 EQUW saveSlotPart2 + 6 * 73
 EQUW saveSlotPart2 + 7 * 73

; ******************************************************************************
;
;       Name: saveSlotAddr3
;       Type: Variable
;   Category: Save and load
;    Summary: The address of the third saved part for each save slot
;
; ******************************************************************************

.saveSlotAddr3

 EQUW saveSlotPart3 + 0 * 73
 EQUW saveSlotPart3 + 1 * 73
 EQUW saveSlotPart3 + 2 * 73
 EQUW saveSlotPart3 + 3 * 73
 EQUW saveSlotPart3 + 4 * 73
 EQUW saveSlotPart3 + 5 * 73
 EQUW saveSlotPart3 + 6 * 73
 EQUW saveSlotPart3 + 7 * 73

; ******************************************************************************
;
;       Name: ResetSaveBuffer
;       Type: Subroutine
;   Category: Save and load
;    Summary: Reset the commander file buffer at BUF to the default commander
;
; ------------------------------------------------------------------------------
;
; Returns:
;
;   A                   A is preserved
;
; ------------------------------------------------------------------------------
;
; Other entry points:
;
;   ResetSaveBuffer+1   Omit the initial PHA (so we can jump here if the value
;                       of the preserved A is already on the stack from another
;                       routine)
;
; ******************************************************************************

.ResetSaveBuffer

 PHA                    ; Store the value of A on the stack so we can restore it
                        ; at the end of the subroutine

 LDX #78                ; We are going to copy 79 bytes, so set a counter in X

.resb1

 LDA NA2%,X             ; Copy the X-th byte of the default commander in NA2% to
 STA BUF,X              ; the X-th byte of BUF

 DEX                    ; Decrement the byte counter

 BPL resb1              ; Loop back until we have copied all 79 bytes

 PLA                    ; Restore the value of A that we stored on the stack, so
                        ; A is preserved

 RTS                    ; Return from the subroutine

; ******************************************************************************
;
;       Name: CopyCommanderToBuf
;       Type: Subroutine
;   Category: Save and load
;    Summary: Copy a commander file in the BUF buffer, either from a save slot
;             or from the currently active commander in-game
;
; ------------------------------------------------------------------------------
;
; Arguments:
;
;   A                   The slot number to process:
;
;                         * 0 to 7 = copy the commander from save slot A into
;                                    the buffer at BUF, combining all three
;                                    parts to do so
;
;                         * 8 = load the default commander into BUF
;
;                         * 9 = copy the current commander from in-game, in
;                               which case we copy the commander from NAME to
;                               BUF without having to combine separate parts
;
; ------------------------------------------------------------------------------
;
; Returns:
;
;   A                   A is preserved
;
; ******************************************************************************

.CopyCommanderToBuf

 PHA                    ; Store the value of A on the stack so we can restore it
                        ; at the end of the subroutine

 JSR SetupPPUForIconBar ; If the PPU has started drawing the icon bar, configure
                        ; the PPU to use nametable 0 and pattern table 0

 CMP #9                 ; If A = 9 then this is the current commander in the
 BEQ ctob7              ; left column, so jump to ctob7 to copy the in-game
                        ; commander to BUF

 CMP #8                 ; If A = 8 then this is the middle column, so jump to
 BEQ ResetSaveBuffer+1  ; ResetSaveBuffer+1 to load the default commander into
                        ; BUF

                        ; If we get here then this is one of the save slots on
                        ; the right of the screen and A is in the range 0 to 7,
                        ; so now we load the contents of the save slot into the
                        ; buffer at BUF
                        ;
                        ; Each save slot is split up into three parts, so we now
                        ; need to combine them to get our commander file

 JSR GetSaveAddresses   ; Set the following for save slot A:
                        ;
                        ;   SC(1 0) = address of the first saved part
                        ;
                        ;   Q(1 0) = address of the second saved part
                        ;
                        ;   S(1 0) = address of the third saved part

 LDY #72                ; We work our way through 73 bytes in each saved part,
                        ; so set an index counter in Y

.ctob1

 SETUP_PPU_FOR_ICON_BAR ; If the PPU has started drawing the icon bar, configure
                        ; the PPU to use nametable 0 and pattern table 0

 LDA (Q),Y              ; Set A to the Y-th byte of the second saved part in
                        ; Q(1 0)

IF _NTSC

 EOR #$F0               ; Set SC2+1 = A with the high nibble flipped
 STA SC2+1

 LDA (S),Y              ; Set SC2 to the Y-th byte from the third part in S(1 0)
 EOR #$0F               ; with the low nibble flipped
 STA SC2

ELIF _PAL

 LSR A                  ; Rotate A to the right, in-place
 BCC ctob2
 ORA #%10000000

.ctob2

 LSR A                  ; Rotate A to the right again, in-place
 BCC ctob3
 ORA #%10000000

.ctob3

 STA SC2+1              ; Set SC2+1 to the newly rotated value of the byte from
                        ; the second saved part

 LDA (S),Y              ; Set SC2 to the Y-th byte from the third part in S(1 0)

 LSR A                  ; Rotate A to the right, in-place
 BCC ctob4
 ORA #%10000000

.ctob4

 STA SC2                ; Set SC2 to the newly rotated value of the byte from
                        ; the third saved part

ENDIF

 LDA (SC),Y             ; Set A to the byte from the first part in SC(1 0)

 CMP SC2+1              ; If A = SC2+1 then jump to ctob5 to store A as our
 BEQ ctob5              ; commander file byte

 CMP SC2                ; If A = SC2 then jump to ctob5 to store A as our
 BEQ ctob5              ; commander file byte

 LDA SC2+1              ; Set A = SC2+1

 CMP SC2                ; If A <> SC2 then the copy protection has failed, so
 BNE ctob9              ; jump to ctob9 to reset the save file

                        ; Otherwise A = SC2, so we store A as our commander file
                        ; byte

.ctob5

 STA BUF,Y              ; Store A as the Y-th byte of our commander file in BUF

 STA (SC),Y             ; Store A as the Y-th byte of the first part in SC(1 0)

IF _NTSC

 EOR #$0F               ; Flip the low nibble of A and store it in the third
 STA (S),Y              ; part in S(1 0)

 EOR #$FF               ; Flip the whole of A and store it in the second part in
 STA (Q),Y              ; Q(1 0)

ELIF _PAL

 ASL A                  ; Set the Y-th byte of the third saved part in S(1 0) to
 ADC #0                 ; the commander file byte, rotated left in-place
 STA (S),Y

 ASL A                  ; Set the Y-th byte of the second saved part in Q(1 0)
 ADC #0                 ; the commander file byte, rotated left in-place
 STA (Q),Y

ENDIF

 DEY                    ; Decrement the byte counter in Y

 BPL ctob1              ; Loop back to ctob1 until we have fetched all 73 bytes
                        ; of the commander file from the three separate parts

                        ; If we get here then we have combined all three saved
                        ; parts into one commander file in BUF, so now we need
                        ; to set the galaxy seeds in bytes #65 to #70, as these
                        ; are not saved in the three parts (as they can easily
                        ; be reconstructed from the galaxy number in GCNT, which
                        ; is what we do now)

 LDA BUF+17             ; Set A to byte #9 of the commander file, which contains
                        ; the galaxy number (0 to 7)

 ASL A                  ; Set Y = A * 8
 ASL A                  ;
 ASL A                  ; The galaxySeeds table has eight batches of seeds with
 TAY                    ; each one taking up eight bytes (the last two in each
                        ; batch are zeroes), so we can use Y as an index into
                        ; the table to fetch the seed bytes that we need

 LDX #0                 ; We will put the first six galaxy seed bytes from the
                        ; checksum table into our commander file, so set X = 0
                        ; to act as a commander file byte index

.ctob6

 LDA galaxySeeds,Y      ; Set A to the next seed byte from batch Y

 STA BUF+73,X           ; Store the seed byte in byte #65 + X

 INY                    ; Increment the seed byte index

 INX                    ; Increment the commander file byte index

 CPX #6                 ; Loop back until we have copied all six seed bytes
 BNE ctob6

 PLA                    ; Restore the value of A that we stored on the stack, so
                        ; A is preserved

 RTS                    ; Return from the subroutine

.ctob7

                        ; If we get here then A = 9, so this is the current
                        ; commander on the left of the screen, so we load the
                        ; currently active commander from NAME (which is where
                        ; the game stores the commander we are currently
                        ; playing)

 LDA SVC                ; Clear bit 7 of the save counter so we can increment
 AND #%01111111         ; the save counter once again to record the next save
 STA SVC                ; after this one

 LDX #78                ; We now copy the current commander file to the buffer
                        ; in BUF, so set a counter in X to copy all 79 bytes of
                        ; the file

.ctob8

 LDA NAME,X             ; Copy the X-th byte of the current commander in NAME
 STA currentSlot,X      ; to the X-th byte of BUF
 STA BUF,X              ;
                        ; This also copies the file to currentSlot, but this
                        ; isn't used anywhere

 DEX                    ; Decrement the byte counter

 BPL ctob8              ; Loop back until we have copied all 79 bytes

 PLA                    ; Restore the value of A that we stored on the stack, so
                        ; A is preserved

 RTS                    ; Return from the subroutine

.ctob9

                        ; If we get here then the three parts of the save file
                        ; have failed the checksums when being combined, so we
                        ; reset the save file and its constituent parts as it
                        ; looks like this file might have been tampered with

 JSR ResetSaveBuffer    ; Reset the commander file in BUF to the default
                        ; commander

 LDA #' '               ; We now fill the commander file name with spaces, so
                        ; set A to the space character

 LDY #6                 ; Set a counter in Y to fill the seven characters in the
                        ; commander file name

.ctob10

 STA BUF,Y              ; Set the Y-th byte of BUF to a space to blank out the
                        ; name (which is seven characters long and at BUF)

 DEY                    ; Decrement the character counter

 BPL ctob10             ; Loop back until we have set the whole name to spaces

 LDA #0                 ; Set the save count in byte #7 of the save file to 0
 STA BUF+7

 PLA                    ; Set A to the save slot number from the stack (leaving
 PHA                    ; the value on the stack)

 JSR SaveLoadCommander  ; Save the commander into the chosen save slot by
                        ; splitting it up and saving it into three parts in
                        ; saveSlotPart1, saveSlotPart2 and saveSlotPart3, so the
                        ; save slot gets reset to the default commander

 PLA                    ; Restore the value of A that we stored on the stack, so
                        ; A is preserved

 RTS                    ; Return from the subroutine

; ******************************************************************************
;
;       Name: ResetSaveSlots
;       Type: Subroutine
;   Category: Save and load
;    Summary: Reset the save slots for all eight save slots, so they will fail
;             their checksums and get reset when they are next checked
;
; ******************************************************************************

.ResetSaveSlots

 LDX #7                 ; There are eight save slots, so set a slot counter in X
                        ; to loop through them all

.rsav1

 TXA                    ; Store the slot counter on the stack, copying the slot
 PHA                    ; number into A in the process

 JSR GetSaveAddresses   ; Set the following for save slot A:
                        ;
                        ;   SC(1 0) = address of the first saved part
                        ;
                        ;   Q(1 0) = address of the second saved part
                        ;
                        ;   S(1 0) = address of the third saved part

                        ; We reset the save slot by writing to byte #10 in each
                        ; of the three saved parts, so that this byte fails its
                        ; checksum, meaning the save slot will be reset the next
                        ; time it is checked in the CheckSaveSlots routine

 LDY #10                ; Set Y to use as an index to byte #10

 LDA #1                 ; Set byte #10 of the first saved part to 1
 STA (SC),Y

 LDA #3                 ; Set byte #10 of the second saved part to 3
 STA (Q),Y

 LDA #7                 ; Set byte #10 of the third saved part to 7
 STA (S),Y

 PLA                    ; Retrieve the slot counter from the stack into X
 TAX

 DEX                    ; Decrement the slot counter

 BPL rsav1              ; Loop back until we have reset the three parts for all
                        ; eight save slots

 RTS                    ; Return from the subroutine

; ******************************************************************************
;
;       Name: GetSaveAddresses
;       Type: Subroutine
;   Category: Save and load
;    Summary: Fetch the addresses of the three saved parts for a specific save
;             slot
;
; ------------------------------------------------------------------------------
;
; Arguments:
;
;   A                   The number of the save slot
;
; ******************************************************************************

.GetSaveAddresses

 ASL A                  ; Set X = A * 2
 TAX                    ;
                        ; So we can use X as an index into the saveSlotAddr
                        ; tables, which contain two-byte addresses

 LDA saveSlotAddr1,X    ; Set the following:
 STA SC                 ;
 LDA saveSlotAddr2,X    ;   SC(1 0) = X-th address from saveSlotAddr1, i.e. the
 STA Q                  ;             address of the first saved part for slot X
 LDA saveSlotAddr3,X    ;
 STA S                  ;   Q(1 0) = X-th address from saveSlotAddr2, i.e. the
 LDA saveSlotAddr1+1,X  ;            address of the second saved part for slot X
 STA SC+1               ;
 LDA saveSlotAddr2+1,X  ;   S(1 0) = X-th address from saveSlotAddr3, i.e. the
 STA Q+1                ;            address of the third saved part for slot X
 LDA saveSlotAddr3+1,X
 STA S+1

 RTS                    ; Return from the subroutine

; ******************************************************************************
;
;       Name: SaveLoadCommander
;       Type: Subroutine
;   Category: Save and load
;    Summary: Either save the commander from BUF into a save slot, or load the
;             commander from BUF into the game and start the game
;
; ------------------------------------------------------------------------------
;
; Arguments:
;
;   A                   The slot number to process:
;
;                         * 0 to 7 = save the current commander from BUF into
;                                    save slot A
;
;                         * 9 = load the current commander from BUF into the
;                               game and start the game
;
; ------------------------------------------------------------------------------
;
; Returns:
;
;   A                   A is preserved
;
; ******************************************************************************

.SaveLoadCommander

 PHA                    ; Store the value of A on the stack so we can restore it
                        ; at the end of the subroutine

 CMP #9                 ; If A = 9 then this is the current commander in the
 BEQ scom2              ; left column, so jump to scom2 to load the commander
                        ; in BUF into the game

                        ; If we get here then this is one of the save slots on
                        ; the right of the screen and A is in the range 0 to 7,
                        ; so now we save the contents of BUF into the save slot
                        ;
                        ; Each save slot is split up into three parts, so we now
                        ; need to split the commander file before saving them

 JSR GetSaveAddresses   ; Set the following for save slot A:
                        ;
                        ;   SC(1 0) = address of the first saved part
                        ;
                        ;   Q(1 0) = address of the second saved part
                        ;
                        ;   S(1 0) = address of the third saved part

 LDA BUF+7              ; Clear bit 7 of the save counter byte in the commander
 AND #%01111111         ; file at BUF so we can increment the save counter once
 STA BUF+7              ; again to record the next save after this one (the save
                        ; counter is in the byte just after the commander name,
                        ; which is seven characters long, so it's at BUF+7)

 LDY #72                ; We work our way through 73 bytes in each saved part,
                        ; so set an index counter in Y

.scom1

 LDA BUF,Y              ; Copy the Y-th byte of the commander file in BUF to the
 STA (SC),Y             ; Y-th byte of the first saved part

IF _NTSC

 EOR #$0F               ; Set the Y-th byte of the third saved part in S(1 0) to
 STA (S),Y              ; the commander file byte with the low nibble flipped

 EOR #$FF               ; Set the Y-th byte of the second saved part in Q(1 0)
 STA (Q),Y              ; to the commander file byte with both nibbles flipped

ELIF _PAL

 ASL A                  ; Set the Y-th byte of the third saved part in S(1 0) to
 ADC #0                 ; the commander file byte, rotated left in-place
 STA (S),Y

 ASL A                  ; Set the Y-th byte of the second saved part in Q(1 0)
 ADC #0                 ; the commander file byte, rotated left in-place
 STA (Q),Y

ENDIF

 DEY                    ; Decrement the byte counter in Y

 BPL scom1              ; Loop back to scom1 until we have split all 73 bytes
                        ; of the commander file into the three separate parts

 PLA                    ; Restore the value of A that we stored on the stack, so
                        ; A is preserved

 RTS                    ; Return from the subroutine

 PHA                    ; This instruction is never run, but it would allow this
                        ; part of the subroutine to be called on its own by
                        ; storing the value of A on the stack so we could
                        ; restore it at the end of the subroutine

.scom2

                        ; If we get here then A = 9, so this is the current
                        ; commander on the left of the screen, so we set the
                        ; currently active in-game commander in NAME to the
                        ; commander in BUF

 LDX #78                ; Set a counter in X to copy all 79 bytes of the file

.scom3

 LDA BUF,X              ; Copy the X-th byte of BUF to the X-th byte of the
 STA currentSlot,X      ; current commander in NAME
 STA NAME,X             ;
                        ; This also copies the file to currentSlot, but this
                        ; isn't used anywhere

 DEX                    ; Decrement the byte counter

 BPL scom3              ; Loop back until we have copied all 79 bytes

 JSR SetupAfterLoad_b0  ; Configure the game to use the newly loaded commander
                        ; file

 PLA                    ; Restore the value of A that we stored on the stack, so
                        ; A is preserved

 RTS                    ; Return from the subroutine

; ******************************************************************************
;
;       Name: CheckSaveSlots
;       Type: Subroutine
;   Category: Save and load
;    Summary: Load the commanders for all eight save slots, one after the other,
;             to check their integrity and reset any that fail their checksums
;
; ******************************************************************************

.CheckSaveSlots

 LDA #7                 ; There are eight save slots, so set a slot counter in
                        ; A to loop through them all

.sabf1

 PHA                    ; Wait until the next NMI interrupt has passed (i.e. the
 JSR WaitForNMI         ; next VBlank), preserving the value in A via the stack
 PLA

 JSR CopyCommanderToBuf ; Copy the commander file from save slot A into the
                        ; buffer at BUF, resetting the save slot if the file
                        ; fails its checksums

 SEC                    ; Decrement A to move on to the next save slot
 SBC #1

 BPL sabf1              ; Loop back until we have loaded all eight save slots

 RTS                    ; Return from the subroutine

; ******************************************************************************
;
;       Name: NA2%
;       Type: Variable
;   Category: Save and load
;    Summary: The data block for the default commander
;
; ******************************************************************************

.NA2%

 EQUS "JAMESON"         ; The current commander name, which defaults to JAMESON

 EQUB 1                 ; SVC = Save count, which is stored in the terminator
                        ; byte for the commander name

 EQUB 0                 ; TP = Mission status, #0

 EQUB 20                ; QQ0 = Current system X-coordinate (Lave), #1
 EQUB 173               ; QQ1 = Current system Y-coordinate (Lave), #2

IF Q%
 EQUD &00CA9A3B         ; CASH = Amount of cash (100,000,000 Cr), #3-6
ELSE
 EQUD &E8030000         ; CASH = Amount of cash (100 Cr), #3-6
ENDIF

 EQUB 70                ; QQ14 = Fuel level, #7

 EQUB 0                 ; COK = Competition flags, #8

 EQUB 0                 ; GCNT = Galaxy number, 0-7, #9

IF Q%
 EQUB Armlas            ; LASER = Front laser, #10
ELSE
 EQUB POW+9             ; LASER = Front laser, #10
ENDIF

 EQUB (POW+9 AND Q%)    ; LASER = Rear laser, #11

 EQUB (POW+128) AND Q%  ; LASER+2 = Left laser, #12

 EQUB Mlas AND Q%       ; LASER+3 = Right laser, #13

 EQUB 22 + (15 AND Q%)  ; CRGO = Cargo capacity, #14

 EQUB 0                 ; QQ20+0  = Amount of food in cargo hold, #15
 EQUB 0                 ; QQ20+1  = Amount of textiles in cargo hold, #16
 EQUB 0                 ; QQ20+2  = Amount of radioactives in cargo hold, #17
 EQUB 0                 ; QQ20+3  = Amount of slaves in cargo hold, #18
 EQUB 0                 ; QQ20+4  = Amount of liquor/Wines in cargo hold, #19
 EQUB 0                 ; QQ20+5  = Amount of luxuries in cargo hold, #20
 EQUB 0                 ; QQ20+6  = Amount of narcotics in cargo hold, #21
 EQUB 0                 ; QQ20+7  = Amount of computers in cargo hold, #22
 EQUB 0                 ; QQ20+8  = Amount of machinery in cargo hold, #23
 EQUB 0                 ; QQ20+9  = Amount of alloys in cargo hold, #24
 EQUB 0                 ; QQ20+10 = Amount of firearms in cargo hold, #25
 EQUB 0                 ; QQ20+11 = Amount of furs in cargo hold, #26
 EQUB 0                 ; QQ20+12 = Amount of minerals in cargo hold, #27
 EQUB 0                 ; QQ20+13 = Amount of gold in cargo hold, #28
 EQUB 0                 ; QQ20+14 = Amount of platinum in cargo hold, #29
 EQUB 0                 ; QQ20+15 = Amount of gem-stones in cargo hold, #30
 EQUB 0                 ; QQ20+16 = Amount of alien items in cargo hold, #31

 EQUB Q%                ; ECM = E.C.M. system, #32

 EQUB Q%                ; BST = Fuel scoops ("barrel status"), #33

 EQUB Q% AND 127        ; BOMB = Energy bomb, #34

 EQUB Q% AND 1          ; ENGY = Energy/shield level, #35

 EQUB Q%                ; DKCMP = Docking computer, #36

 EQUB Q%                ; GHYP = Galactic hyperdrive, #37

 EQUB Q%                ; ESCP = Escape pod, #38

 EQUW 0                 ; TRIBBLE = Number of Trumbles in the cargo hold, #39-40

 EQUB 0                 ; TALLYL = Combat rank fraction, #41

 EQUB 3 + (Q% AND 1)    ; NOMSL = Number of missiles, #42

 EQUB 0                 ; FIST = Legal status ("fugitive/innocent status"), #43

 EQUB 16                ; AVL+0  = Market availability of food, #44
 EQUB 15                ; AVL+1  = Market availability of textiles, #45
 EQUB 17                ; AVL+2  = Market availability of radioactives, #46
 EQUB 0                 ; AVL+3  = Market availability of slaves, #47
 EQUB 3                 ; AVL+4  = Market availability of liquor/Wines, #48
 EQUB 28                ; AVL+5  = Market availability of luxuries, #49
 EQUB 14                ; AVL+6  = Market availability of narcotics, #50
 EQUB 0                 ; AVL+7  = Market availability of computers, #51
 EQUB 0                 ; AVL+8  = Market availability of machinery, #52
 EQUB 10                ; AVL+9  = Market availability of alloys, #53
 EQUB 0                 ; AVL+10 = Market availability of firearms, #54
 EQUB 17                ; AVL+11 = Market availability of furs, #55
 EQUB 58                ; AVL+12 = Market availability of minerals, #56
 EQUB 7                 ; AVL+13 = Market availability of gold, #57
 EQUB 9                 ; AVL+14 = Market availability of platinum, #58
 EQUB 8                 ; AVL+15 = Market availability of gem-stones, #59
 EQUB 0                 ; AVL+16 = Market availability of alien items, #60

 EQUB 0                 ; QQ26 = Random byte that changes for each visit to a
                        ; system, for randomising market prices, #61

 EQUW 20000 AND Q%      ; TALLY = Number of kills, #62-63

 EQUB 128               ; This byte appears to be unused, #64

 EQUW $5A4A             ; QQ21 = Seed s0 for system 0, galaxy 0 (Tibedied), #65
 EQUW $0248             ; QQ21 = Seed s1 for system 0, galaxy 0 (Tibedied), #67
 EQUW $B753             ; QQ21 = Seed s2 for system 0, galaxy 0 (Tibedied), #69

 EQUB $AA               ; This byte appears to be unused, #71

 EQUB $27               ; This byte appears to be unused, #72

 EQUB $03               ; This byte appears to be unused, #73

 EQUD 0                 ; These bytes appear to be unused, #74-#85
 EQUD 0
 EQUD 0
 EQUD 0

; ******************************************************************************
;
;       Name: ResetCommander
;       Type: Subroutine
;   Category: Save and load
;    Summary: Reset the current commander to the default "JAMESON" commander
;
; ******************************************************************************

.ResetCommander

 JSR JAMESON            ; Copy the default "JAMESON" commander to the buffer at
                        ; currentSlot

 LDX #79                ; We now want to copy 78 bytes from the buffer at
                        ; currentSlot to the current commander at NAME, so
                        ; set a byte counter in X (which counts down from 79 to
                        ; 1 as we copy bytes 78 to 0)

.resc1

 LDA currentSlot-1,X    ; Copy byte X-1 from currentSlot to byte X-1 of NAME
 STA NAME-1,X

 DEX                    ; Decrement the byte counter

 BNE resc1              ; Loop back until we have copied all 78 bytes

 RTS                    ; Return from the subroutine

; ******************************************************************************
;
;       Name: JAMESON
;       Type: Subroutine
;   Category: Save and load
;    Summary: Copy the default "JAMESON" commander to the buffer at currentSlot
;
; ******************************************************************************

.JAMESON

 LDY #94                ; We want to copy 94 bytes from the default commander
                        ; at NA2% to the buffer at currentSlot, so set a byte
                        ; counter in Y

.jame1

 LDA NA2%,Y             ; Copy the Y-th byte of NA2% to the Y-th byte of
 STA currentSlot,Y      ; currentSlot

 DEY                    ; Decrement the byte counter

 BPL jame1              ; Loop back until we have copied all 94 bytes

 RTS                    ; Return from the subroutine

; ******************************************************************************
;
;       Name: DrawLightning
;       Type: Subroutine
;   Category: Flight
;    Summary: Draw a lightning effect for the launch tunnel and E.C.M. that
;             consists of two random lightning bolts, one above the other
;
; ------------------------------------------------------------------------------
;
; Arguments:
;
;   K                   Half the width of the rectangle containing the lightning
;
;   K+1                 Half the height of the rectangle containing the
;                       lightning
;
;   K+2                 The x-coordinate of the centre of the lightning
;
;   K+3                 The y-coordinate of the centre of the lightning
;
; ******************************************************************************

.DrawLightning

                        ; The rectangle is split into a top half and a bottom
                        ; half, with a bolt in the top half and a bolt in the
                        ; bottom half, and we draw each bolt in turn

 LDA K+1                ; Set XX2+1 = K+1 / 2
 LSR A                  ;
 STA XX2+1              ; So XX2+1 contains a quarter of the height of the
                        ; rectangle containing the lightning

 LDA K+3                ; Set K3 = K+3 - XX2+1 + 1
 SEC                    ;
 SBC XX2+1              ; So K3 contains the y-coordinate of the centre of the
 CLC                    ; top lightning bolt (i.e. the invisible horizontal line
 ADC #1                 ; through the centre of the top bolt)
 STA K3

 JSR lite1              ; Call lite1 below to draw the top lightning bolt along
                        ; a centre line at y-coordinate K+3

 LDA K+3                ; Set K3 = K+3 + XX2+1
 CLC                    ;
 ADC XX2+1              ; So K3 contains the y-coordinate of the centre of the
 STA K3                 ; bottom lightning bolt (i.e. the invisible horizontal
                        ; line through the centre of the bottom bolt)

                        ; Fall through into lite1 to draw the second lightning
                        ; bolt along a centre line at y-coordinate K+3

.lite1

                        ; We now draw a lightning bolt along an invisible centre
                        ; line at y-coordinate K+3

 LDA K                  ; Set STP = K / 4
 LSR A                  ;
 LSR A                  ; As K is the half-width of the rectangle containing the
 STA STP                ; lightning, this means STP is 1/8 of the width of the
                        ; lightning rectangle
                        ;
                        ; We use this value to step along the rectangle from
                        ; left to right, so we can draw the lightning bolt in
                        ; eight equal-width segments

 LDA K+2                ; Set X1 = K+2 - K
 SEC                    ;
 SBC K                  ; So X1 contains the x-coordinate of the left edge of
 STA X1                 ; the rectangle containing the lightning bolt

 LDA K3                 ; Set Y1 = K3
 STA Y1                 ;
                        ; So Y1 contains the y-coordinate of the centre of the
                        ; lightning bolt, and (X1, Y1) therefore contains the
                        ; pixel coordinate of the left end of the lightning bolt

 LDY #7                 ; We now draw eight segments of lightning, zig-zagging
                        ; above and below the invisible centre line at
                        ; y-coordinate K3

.lite2

 JSR DORND              ; Set Q to a random number in the range 0 to 255
 STA Q

 LDA K+1                ; Set A to K+1, which is half the height of the
                        ; rectangle containing the lightning, which is the same
                        ; as the full height of the rectangle containing the
                        ; lightning bolt we are drawing

 JSR FMLTU              ; Set A = A * Q / 256
                        ;       = K+1 * rand / 256
                        ;
                        ; So A is a random number in the range 0 to the maximum
                        ; height of the lightning bolt we are drawing

 CLC                    ; Set Y2 = K3 + A - XX2+1
 ADC K3                 ;
 SEC                    ; In the above, K3 is the y-coordinate of the centre of
 SBC XX2+1              ; the lightning bolt, XX2+1 contains half the height of
 STA Y2                 ; the lightning bolt, and A is a random number between 0
                        ; and the height of the lightning bolt, so this sets Y2
                        ; to a y-coordinate that is centred on the centre line
                        ; of the lightning bolt, and is a random distance above
                        ; or below the line, and which fits within the height of
                        ; the lightning bolt
                        ;
                        ; We can therefore use this as the y-coordinate of the
                        ; next point along the zig-zag of the lightning bolt

 LDA X1                 ; Set X2 = X1 + STP
 CLC                    ;
 ADC STP                ; So X2 is the x-coordinate of the next point along the
 STA X2                 ; lightning bolt, and (X2, Y2) is therefore the next
                        ; point along the lightning bolt

 JSR LOIN               ; Draw a line from (X1, Y1) to (X2, Y2) to draw the next
                        ; segment of the bolt

 LDA SWAP               ; If SWAP is non-zero then we already swapped the line
 BNE lite3              ; coordinates around during the drawing process, so we
                        ; can jump to lite3 to skip the following coordinate
                        ; swap

 LDA X2                 ; Set (X1, Y1) to (X2, Y2), so (X1, Y1) contains the new
 STA X1                 ; end coordinates of the lightning bolt, now that we
 LDA Y2                 ; just drawn another segment of the bolt
 STA Y1

.lite3

 DEY                    ; Decrement the segment counter in Y

 BNE lite2              ; Loop back to draw the next segment until we have drawn
                        ; seven of them

                        ; We finish off by drawing the final segment, which we
                        ; draw from the current end of the zig-zag to the right
                        ; end of the invisible horizontal line through the
                        ; centre of the bolt, so the bolt starts and ends at
                        ; this height

 LDA K+2                ; Set X2 = K+2 + K
 CLC                    ;
 ADC K                  ; So X2 contains the x-coordinate of the right edge of
 STA X2                 ; the rectangle containing the lightning

 LDA K3                 ; Set Y2 = K3
 STA Y2                 ;
                        ; So Y2 contains the y-coordinate of the centre of the
                        ; lightning bolt, and (X2, Y2) therefore contains the
                        ; pixel coordinate of the right end of the lightning
                        ; bolt

 JSR LOIN               ; Draw a line from (X1, Y1) to (X2, Y2) to draw the
                        ; final segment of the bolt

 RTS                    ; Return from the subroutine

; ******************************************************************************
;
;       Name: LL164
;       Type: Subroutine
;   Category: Flight
;    Summary: Make the hyperspace sound and draw the hyperspace tunnel
;
; ------------------------------------------------------------------------------
;
; This routine does a similar job to the routine of the same name in the BBC
; Master version of Elite, but the code is significantly different.
;
; ******************************************************************************

.LL164

 JSR WaitForPPUToFinish ; Wait until both bitplanes of the screen have been
                        ; sent to the PPU, so the screen is fully updated and
                        ; there is no more data waiting to be sent to the PPU

 JSR HideStardust       ; Hide the stardust sprites

 JSR HideExplosionBurst ; Hide the four sprites that make up the explosion burst

 JSR MakeHyperSound     ; Make the hyperspace sound

 LDA #128               ; This value is not used in the following, so this has
 STA K+2                ; no effect

 LDA #72                ; This value is not used in the following, so this has
 STA K+3                ; no effect

 LDA #64                ; Set XP to use as a counter for each frame of the
 STA XP                 ; hyperspace effect, so we run the following loop 64
                        ; times for an animation of 64 frames

                        ; We now draw 64 frames of hyperspace effect, looping
                        ; back to hype1 for each new frame

.hype1

 JSR CheckPauseButton   ; Check whether the pause button has been pressed or an
                        ; icon bar button has been chosen, and process pause or
                        ; unpause if a pause-related button has been pressed

 JSR DORND              ; Set X to a random number between 0 and 15
 AND #15
 TAX

 LDA hyperspaceColour,X ; Set the visible colour to entry number X from the
 STA visibleColour      ; hyperspaceColour table, so this sets the hyperspace
                        ; colour randomly to one of the colours in the table

 JSR FlipDrawingPlane   ; Flip the drawing bitplane so we draw into the bitplane
                        ; that isn't visible on-screen

 LDA XP                 ; Set STP = XP mod 32
 AND #31                ;
 STA STP                ; So over the course of the 64 iterations around the
                        ; loop, STP starts at 0, then counts down from 31 to 0,
                        ; and then counts down from 31 to 1 again
                        ;
                        ; The higher the value of STP, the closer together the
                        ; lines in the hyperspace effect, so this makes the
                        ; lines move further away as the effect progresses,
                        ; giving a feeling of moving through hyperspace

 LDA #8                 ; Set X1 = 8 so we draw horizontal lines from
 STA X1                 ; x-coordinate 8 on the left of the screen

 LDA #248               ; Set X2 = 248 so we draw horizontal lines to
 STA X2                 ; x-coordinate 248 on the right of the screen

                        ; We now draw the lines in the hyperspace effect (with
                        ; lines in the top half of the screen and the same
                        ; lines, reflected, in the bottom half), looping back
                        ; to hype2 for each new line
                        ;
                        ; STP gets incremented by 16 for each line, so STP is
                        ; set to the starting point (in the range 0 to 31), plus
                        ; 16 for the first line, plus 32 for the second line,
                        ; and so on until we get to 90, at which point we stop
                        ; drawing lines for this frame
                        ;
                        ; As STP increases, the lines get closer to the middle
                        ; of the screen, so this loop draws the lines, starting
                        ; with the lines furthest from the centre and working in
                        ; towards the centre

.hype2

 SETUP_PPU_FOR_ICON_BAR ; If the PPU has started drawing the icon bar, configure
                        ; the PPU to use nametable 0 and pattern table 0

 LDA STP                ; Set STP = STP + 16
 CLC                    ;
 ADC #16                ; And set A to the new value of STP
 STA STP

 CMP #90                ; If A >= 90, jump to hype3 to move on to the next frame
 BCS hype3              ; (so we stop drawing lines in this frame)

 STA Q                  ; Set Q to the new value of STP

                        ; We now calculate how far this horizontal line is from
                        ; the centre of the screen in a vertical direction, with
                        ; the result being lines that are closer together, the
                        ; closer they are to the centre
                        ;
                        ; We space out the lines using a reciprocal algorithm,
                        ; where the distance of line n from the centre is
                        ; proportional to 1/n, so the lines get spaced roughly
                        ; in the proportions of 1/2, 1/3, 1/4, 1/5 and so on, so
                        ; the lines bunch closer together as n increases
                        ;
                        ; STP also includes the iteration number, modded so it
                        ; runs from 31 to 0, so over the course of the animation
                        ; the lines move away from the centre line, as the
                        ; iteration decreases and the value of R below increases

 LDA #8                 ; Set A = 8 to use in the following division

 JSR LL28               ; Call LL28 to calculate:
                        ;
                        ;   R = 256 * A / Q
                        ;     = 256 * 8 / STP
                        ;
                        ; So R is the vertical distance of the current line from
                        ; the centre of the screen
                        ;
                        ; The minimum value of STP is 16 and the maximum is 89
                        ; (the latter being enforced by the comparison above),
                        ; so R ranges from 128 to 23

 LDA R                  ; Set K+1 = R - 20
 SEC                    ;
 SBC #20                ; This sets the range of values in K+1 to 108 to 3
 STA K+1

                        ; We can now use K+1 as the vertical distance of this
                        ; line from the centre of the screen, to give us an
                        ; effect where the horizontal lines spread out as they
                        ; get away from the centre, and which move away from the
                        ; centre as the animation progresses, with the movement
                        ; being bigger the further away the line
                        ;
                        ; We now draw this line twice, once above the centre and
                        ; once below the centre, so the lines in the top and
                        ; bottom parts of the screen are mirrored, and the
                        ; overall effect is of hyperspacing forwards, sandwiched
                        ; between two horizontal planes, one above and one below

 LDA halfScreenHeight   ; Set A = halfScreenHeight - K+1
 SBC K+1                ;
                        ; So A is the y-coordinate of the line in the top half
                        ; of the screen

 BCC hype2              ; If A <= 0 then the line is off the top of the screen,
 BEQ hype2              ; so jump to hype2 to move on to the next line

 TAY                    ; Set Y = A, to use as the y-coordinate for this line
                        ; in the hyperspace effect

 JSR HLOIN              ; Draw a horizontal line from (X1, Y) to (X2, Y)

 INC X2                 ; The HLOIN routine decrements X2, so increment it back
                        ; to its original value

 LDA K+1                ; Set A = halfScreenHeight + K+1
 CLC                    ;
 ADC halfScreenHeight   ; So A is the y-coordinate of the line in the bottom
                        ; half of the screen

 TAY                    ; Set Y = A, to use as the y-coordinate for this line
                        ; in the hyperspace effect

 JSR HLOIN              ; Draw a horizontal line from (X1, Y) to (X2, Y)

 INC X2                 ; The HLOIN routine decrements X2, so increment it back
                        ; to its original value

 JMP hype2              ; Loop back to hype2 to draw the next horizontal line
                        ; in this iteration

.hype3

 JSR DrawBitplaneInNMI  ; Configure the NMI to send the drawing bitplane to the
                        ; PPU after drawing the box edges and setting the next
                        ; free tile number

 DEC XP                 ; Decrement the frame counter in XP

 BNE hype1              ; Loop back to hype1 to draw the next frame of the
                        ; animation, until the frame counter runs down to 0

 JMP WaitForPPUToFinish ; Wait until both bitplanes of the screen have been
                        ; sent to the PPU, so the screen is fully updated and
                        ; there is no more data waiting to be sent to the PPU,
                        ; and return from the subroutine using a tail call

; ******************************************************************************
;
;       Name: hyperspaceColour
;       Type: Variable
;   Category: Flight
;    Summary: The different colours that can be used for the hyperspace effect
;
; ******************************************************************************

.hyperspaceColour

 EQUB $06               ; Dark red
 EQUB $0F               ; Black
 EQUB $38               ; Pale yellow
 EQUB $2A               ; Light green
 EQUB $23               ; Light violet
 EQUB $25               ; Light rose
 EQUB $22               ; Light blue
 EQUB $11               ; Medium azure
 EQUB $1A               ; Medium green
 EQUB $00               ; Dark grey
 EQUB $26               ; Light red
 EQUB $2C               ; Light cyan
 EQUB $20               ; White
 EQUB $13               ; Medium violet
 EQUB $0F               ; Black
 EQUB $00               ; Dark grey

; ******************************************************************************
;
;       Name: DrawLaunchBox
;       Type: Subroutine
;   Category: Flight
;    Summary: Draw a box as part of the launch tunnel animation
;
; ------------------------------------------------------------------------------
;
; Arguments:
;
;   K                   Half the width of the box
;
;   K+1                 Half the height of the box
;
;   K+2                 The x-coordinate of the centre of the box
;
;   K+3                 The y-coordinate of the centre of the box
;
; ******************************************************************************

.lbox1

 RTS                    ; Return from the subroutine

.DrawLaunchBox

 LDA K+2                ; Set A = K+2 + K
 CLC                    ;
 ADC K                  ; So A contains the x-coordinate of the right edge of
                        ; the box (i.e. the centre plus half the width)

 BCS lbox1              ; If the addition overflowed, then the right edge of the
                        ; box is past the right edge of the screen, so jump to
                        ; lbox1 to return from the subroutine without drawing
                        ; any lines

 STA X2                 ; Set X2 to A, to the x-coordinate of the right edge of
                        ; the box

 STA X1                 ; Set X1 to A, to the x-coordinate of the right edge of
                        ; the box

 LDA K+3                ; Set A = K+3 - K+1
 SEC                    ;
 SBC K+1                ; So A contains the y-coordinate of the top edge of the
                        ; box (i.e. the centre minus half the height)

 BCS lbox2              ; If the subtraction underflowed, then the top edge of
                        ; the box is above the top edge of the screen, so jump
                        ; to lbox2 to skip the following

 LDA #0                 ; Set A = 0 to clip the result to the top of the space
                        ; view

.lbox2

 STA Y1                 ; Set Y1 to A, so (X1, Y1) is the coordinate of the
                        ; top-right corner of the box

 LDA K+3                ; Set A = K+3 + K+1
 CLC                    ;
 ADC K+1                ; So A contains the y-coordinate of the bottom edge of
                        ; the box (i.e. the centre plus half the height)

 BCS lbox3              ; If the addition overflowed, then the y-coordinate is
                        ; off the bottom of the screen, so jump to lbox3 to skip
                        ; the following check (though this is slightly odd, as
                        ; this leaves A set to the y-coordinate of the bottom
                        ; edge, wrapped around with a mod 256, which is unlikely
                        ; to be what we want, so should this be a jump to lbox1
                        ; to return from the subroutine instead?)

 CMP Yx2M1              ; If A < Yx2M1 then the y-coordinate is within the
 BCC lbox3              ; space view (as Yx2M1 is the y-coordinate of the bottom
                        ; pixel row of the space view), so jump to lbox3 to skip
                        ; the following instruction

 LDA Yx2M1              ; Set A = Yx2M1 to clip the result to the bottom of the
                        ; space view

.lbox3

 STA Y2                 ; Set Y2 to A, so (X1, Y2) is the coordinate of the
                        ; bottom-right corner of the box

                        ; By the time we get here, (X1, Y1) is the coordinate
                        ; of the top-right corner of the box, and (X1, Y2) is
                        ; the coordinate of the bottom-right corner of the box

 JSR DrawVerticalLine   ; Draw a vertical line from (X1, Y1) to (X1, Y2), to
                        ; draw the right edge of the box

 LDA K+2                ; Set A = K+2 - K
 SEC                    ;
 SBC K                  ; So A contains the x-coordinate of the left edge of
                        ; the box (i.e. the centre minus half the width)

 BCC lbox1              ; If the subtraction underflowed, then the left edge of
                        ; the box is past the left edge of the screen, so jump
                        ; to lbox1 to return from the subroutine without drawing
                        ; any more lines

 STA X1                 ; Set X1 to A, to the x-coordinate of the left edge of
                        ; the box

                        ; By the time we get here, (X1, Y1) is the coordinate
                        ; of the top-left corner of the box, and (X1, Y2) is
                        ; the coordinate of the bottom-left corner of the box

 JSR DrawVerticalLine   ; Draw a vertical line from (X1, Y1) to (X1, Y2), to
                        ; draw the left edge of the box

                        ; We now move on to drawing the top and bottom edges

 INC X1                 ; Increment the x-coordinate in X1 so the top box edge
                        ; starts with the pixel to the right of the left edge

 LDY Y1                 ; Set Y to the y-coordinate in Y1, which is the
                        ; y-coordinate of the top edge of the box

 BEQ lbox4              ; If Y = 0 then skip the following, so we don't draw
                        ; the top edge if it's on the very top pixel line of
                        ; the screen

 JSR HLOIN              ; Draw a horizontal line from (X1, Y) to (X2, Y) to draw
                        ; the top edge of the box

 INC X2                 ; The HLOIN routine decrements X2, so increment it back
                        ; to its original value

.lbox4

 DEC X1                 ; Decrement the x-coordinate in X1 so the bottom edge
                        ; starts at the same x-coordinate as the left edge

 INC X2                 ; Increment the x-coordinate in X1 so the bottom edge
                        ; ends with the pixel to the left of the right edge

 LDY Y2                 ; Set Y to the y-coordinate in Y2, which is the
                        ; y-coordinate of the bottom edge of the box

 CPY Yx2M1              ; If Y >= Yx2M1 then the y-coordinate is below the
 BCS lbox1              ; bottom of the space view (as Yx2M1 is the y-coordinate
                        ; of the bottom pixel row of the space view), so jump to
                        ; lbox1 to return from the subroutine without drawing
                        ; the bottom edge

 JMP HLOIN              ; Draw a horizontal line from (X1, Y) to (X2, Y) to draw
                        ; the bottom edge of the box, returning from the
                        ; subroutine using a tail call

; ******************************************************************************
;
;       Name: InputName
;       Type: Subroutine
;   Category: Controllers
;    Summary: Get a name from the controller for searching the galaxy or
;             changing commander name
;
; ------------------------------------------------------------------------------
;
; Arguments:
;
;   INWK+5              The current name
;
;   inputNameSize       The maximum size of the name to fetch - 1
;
; ------------------------------------------------------------------------------
;
; Returns:
;
;   INWK+5              The entered name, terminated by ASCII 13
;
;   C flag              The status of the entered name:
;
;                         * Set = The name is empty
;
;                         * Clear = The name is not empty
;
; ******************************************************************************

.InputName

 LDY #0                 ; Set an index in Y to point to the letter within the
                        ; name that we are entering, starting with the first
                        ; letter at index 0

                        ; The currently entered name is at INWK+5, so we use
                        ; that to provide the starting point for each letter
                        ; (or we start at "A" if there is no currently entered
                        ; name)

.name1

 LDA INWK+5,Y           ; Fetch the Y-th character of the currently entered
                        ; name at INWK+5

 CMP #'A'               ; If the character is ASCII "A" or greater, jump to
 BCS name2              ; name2 to use this as the starting point for this
                        ; letter

 LDA #'A'               ; Otherwise set A to the letter "A" to use as the
                        ; starting point

.name2

 PHA                    ; These instructions together have no effect
 PLA

 JSR ChangeLetter       ; Call ChangeLetter to allow us to move up or down
                        ; through the alphabet, returning with the letter
                        ; selected in A

 BCS name4              ; If the C flag was set by ChangeLetter then the A
                        ; button was pressed, so jump to name4 to finish the
                        ; process as this means we have finished entering the
                        ; name

                        ; Otherwise we now check whether the chosen character
                        ; is valid

 CMP #27                ; If ChangeLetter returned an ASCII ESC character, jump
 BEQ name5              ; to name5 to return from the subroutine with an empty
                        ; name and the C flag set

 CMP #127               ; If ChangeLetter returned an ASCII DEL character, jump
 BEQ name6              ; to name6 to delete the character to the left

 CPY inputNameSize      ; If Y >= inputNameSize then the entered name is too
 BCS name3              ; long, so jump to name3 to give an error beep and try
                        ; again

 CMP #'!'               ; If A < ASCII "!" then it is a control character, so
 BCC name3              ; jump to name3 to give an error beep and try again

 CMP #'{'               ; If A >= ASCII "{" then it is not a valid character, so
 BCS name3              ; jump to name3 to give an error beep and try again

                        ; If we get here then the chosen character is valid

 STA INWK+5,Y           ; Store the chosen character in the Y-th position in the
                        ; string at INWK+5

 INY                    ; Increment the index in Y to point to the next letter

 INC XC                 ; Move the text cursor to the right by one place

 JMP name1              ; Loop back to name1 to fetch the next letter

.name3

                        ; If we get here then there are too many characters in
                        ; the string, or the entered character is not a valid
                        ; letter

 JSR BEEP_b7            ; Call the BEEP subroutine to make a short, high beep to
                        ; indicate an error

 LDY inputNameSize      ; Set Y to the maximum length of the string, so when we
                        ; loop back to name1, we ask for the last letter again

 JMP name1              ; Loop back to name1 to fetch the next letter

.name4

                        ; If we get here then we have finished entering the name

 STA INWK+5,Y           ; Store the chosen character in the Y-th position in the
                        ; string at INWK+5

 INY                    ; Increment the index in Y to point to the next letter

 LDA #13                ; Store the string terminator in the next letter, so the
 STA INWK+5,Y           ; entered string is terminated properly

 LDA #12                ; Print a newline
 JSR CHPR_b2

 JSR DrawMessageInNMI   ; Configure the NMI to display the message that we just
                        ; printed

 CLC                    ; Clear the C flag to indicate that a name has
                        ; successfully been entered

 RTS                    ; Return from the subroutine

.name5

 LDA #13                ; Store the string terminator in the first letter, so
 STA INWK+5             ; the returned string is empty

 SEC                    ; Set the C flag to indicate that a valid name has not
                        ; been entered

 RTS                    ; Return from the subroutine

.name6

                        ; If we get here then we need to delete the character to
                        ; the left of the current letter

 TYA                    ; If Y = 0 then we are still on the first letter, so
 BEQ name7              ; jump to name7 to given an error beep, as we can't
                        ; delete past the start of the name

 DEY                    ; Decrement the length of the current name in Y, so the
                        ; next character we enter replaces the one we are
                        ; deleting

 LDA #127               ; Print a delete character to delete the letter to the
 JSR CHPR_b2            ; left

 LDA INWK+5,Y           ; Set A to the character before the one we just deleted,
                        ; as that's the current character now

 JMP name2              ; Loop back to name2 to keep scanning for button presses

.name7

                        ; If we get here then we need to give an error beep, as
                        ; we just tried to delete past the start of the name

 JSR BEEP_b7            ; Call the BEEP subroutine to make a short, high beep to
                        ; indicate an error

 LDY #0                 ; Set Y = 0 to set the current character to the start of
                        ; the name

 BEQ name1              ; Loop back to name1 to fetch the next letter (this BEQ
                        ; is effectively a JMP, as Y is always zero)

; ******************************************************************************
;
;       Name: ChangeLetter
;       Type: Subroutine
;   Category: Controllers
;    Summary: Choose a letter using the up and down buttons
;
; ------------------------------------------------------------------------------
;
; Arguments:
;
;   A                   The letter to start on
;
; ------------------------------------------------------------------------------
;
; Returns:
;
;   A                   The chosen letter
;
;   C flag              The status of the A button:
;
;                         * Set = the A button was pressed to finish entering
;                                 the string
;
;                         * Clear = the A button was not pressed
;
; ******************************************************************************

.ChangeLetter

 TAX                    ; Set X to the starting letter

 STY YSAV               ; Store Y in YSAV so we can retrieve it below

 LDA fontStyle          ; Store the current font style on the stack, so we can
 PHA                    ; restore it when we return from the subroutine

 LDA QQ11               ; If bit 5 of the view type in QQ11 is clear, then the
 AND #%00100000         ; normal font is not loaded, so jump to lett1 to skip
 BEQ lett1              ; the following instruction

 LDA #1                 ; Set the font style to print in the normal font
 STA fontStyle

.lett1

 TXA                    ; Set A to the starting letter

.lett2

 PHA                    ; Store the current letter in A on the stack so we can
                        ; retrieve it below

 LDY #4                 ; Wait until four NMI interrupts have passed (i.e. the
 JSR DELAY              ; next four VBlanks)

 PLA                    ; Set A to the current letter, leaving a copy of it on
 PHA                    ; the stack

 JSR CHPR_b2            ; Print the character in A

 DEC XC                 ; Move the text cursor left by one character, so it is
                        ; the correct column for the letter we just printed

 JSR DrawMessageInNMI   ; Configure the NMI to display the message that we just
                        ; printed

 SEC                    ; Set the C flag to return from the subroutine if the
                        ; following check shows that the A button was pressed,
                        ; in which case we have finished entering letters

 LDA controller1A       ; If the A button on controller 1 is being pressed, jump
 BMI lett5              ; to lett5 to return from the subroutine with the C flag
                        ; set and the current letter as the chosen letter

 CLC                    ; Clear the C flag to indicate that the A button was not
                        ; pressed

 PLA                    ; Set A to the current letter, which we stored on the
                        ; stack above

 LDX controller1B       ; If the B button on controller 1 is being pressed, loop
 BMI lett2              ; back to lett2 to keep scanning for button presses, as
                        ; the arrow buttons have a different meaning when the B
                        ; button is also held down

 LDX iconBarChoice      ; If an icon has been chosen from the icon bar, jump to
 BNE lett7              ; lett7 to return from the subroutine with a value of
                        ; 27 (ESC, or escape) and the C flag clear

 LDX controller1Left03  ; If the left button on controller 1 was being held down
 BMI lett4              ; four VBlanks ago, jump to lett4 to return from the
                        ; subroutine with a value of 127 (DEL, or delete) and
                        ; the C flag clear

 LDX controller1Right03 ; If the right button on controller 1 was being held
 BMI lett6              ; down four VBlanks ago, jump to lett6 to return from
                        ; the subroutine with the C flag clear

 LDX controller1Up      ; If the up button on controller 1 is not being pressed,
 BPL lett3              ; jump to lett3 to move on to the next button

                        ; If we get here then the up button is being pressed

 CLC                    ; Increment the current character in A
 ADC #1

 CMP #'Z'+1             ; If A is still a letter in the range "A" to "Z", then
 BNE lett3              ; jump to lett3 to skip the following

 LDA #'A'               ; Set A to ASCII "A" so we wrap round to the start of
                        ; the alphabet

.lett3

 LDX controller1Down    ; If the down button on controller 1 is not being
 BPL lett2              ; pressed, loop back to lett2 to keep scanning for
                        ; button presses

                        ; If we get here then the down button is being pressed

 SEC                    ; Decrement the current character in A
 SBC #1

 CMP #'A'-1             ; If A is still a letter in the range "A" to "Z", then
 BNE lett2              ; look back to lett2 to keep scanning for button presses

 LDA #'Z'               ; Set A to ASCII "Z" so we wrap round to the end of
                        ; the alphabet

 BNE lett2              ; Loop back to lett2 to keep scanning for button presses
                        ; (this BNE is effectively a JMP as A is never zero)

.lett4

                        ; If we get here then the left button is being pressed

 LDA #127               ; Set A to the ASCII code for DEL, or delete

 BNE lett6              ; Jump to lett6 to return from the subroutine (this BNE
                        ; is effectively a JMP as A is never zero)

.lett5

 PLA                    ; Set A to the current letter, which we stored on the
                        ; stack above

.lett6

 TAX                    ; Store the chosen letter in X so we can retrieve it
                        ; below

 PLA                    ; Restore the font style that we stored on the stack
 STA fontStyle          ; so it's unchanged by the routine

 LDY YSAV               ; Retrieve the value of Y we stored above

 TXA                    ; Restore the chosen letter from X into A so we can
                        ; return it

 RTS                    ; Return from the subroutine

.lett7

                        ; If we get here then an icon bar button has been
                        ; chosen, so we need to abort the letter choosing
                        ; process

 LDA #27                ; Set A to the ASCII code for ESC, or escape

 BNE lett6              ; Jump to lett6 to return from the subroutine (this BNE
                        ; is effectively a JMP as A is never zero)

; ******************************************************************************
;
;       Name: ChangeCmdrName
;       Type: Subroutine
;   Category: Save and load
;    Summary: Process changing the commander name
;
; ******************************************************************************

.ChangeCmdrName

 JSR CLYNS              ; Clear the bottom two text rows of the upper screen,
                        ; and move the text cursor to column 1 on row 21, i.e.
                        ; the start of the top row of the two bottom rows

 INC YC                 ; Move the text cursor to row 22

 LDA #8                 ; Print extended token 8 ("{single cap}NEW NAME: ")
 JSR DETOK_b2

 LDY #6                 ; We start by copying the current commander's name from
                        ; NAME to the buffer at INWK+5, which is where the
                        ; InputName routine expects to find the current name to
                        ; edit, so set a counter in Y for seven characters

 STY inputNameSize      ; Set inputNameSize = 6 so we fetch a name with a
                        ; maximum size of 7 characters in the call to InputName
                        ; below

.cnme1

 LDA NAME,Y             ; Copy the Y-th character from NAME to the Y-th
 STA INWK+5,Y           ; character of the buffer at INWK+5

 DEY                    ; Decrement the loop counter

 BPL cnme1              ; Loop back until we have copied all seven characters
                        ; of the name

 JSR InputName          ; Get a new commander name from the controller into
                        ; INWK+5, where the name will be terminated by ASCII 13

 LDA INWK+5             ; If the first character of the entered name is ASCII 13
 CMP #13                ; then no name was entered, so jump to cnme5 to return
 BEQ cnme5              ; from the subroutine

 LDY #0                 ; Otherwise we now calculate the length of the entered
                        ; name by working along the entered string until we find
                        ; the ASCII 13 character, so set a length counter in Y
                        ; to store the name length as we loop through the name

.cnme2

 LDA INWK+5,Y           ; If the Y-th character of the name is ASCII 13 then we
 CMP #13                ; have found the end of the name, so jump to cnme6 to
 BEQ cnme6              ; pad out the rest of the name with spaces before
                        ; returning to cnme3 below

 INY                    ; Otherwise increment the counter in Y to move along by
                        ; one character

 CPY #7                 ; If Y <> 7 then we haven't gone past the seventh
 BNE cnme2              ; character yet (the commander name has a maximum length
                        ; of 7), so loop back to check the next character

 DEY                    ; Otherwise Y = 7 and we just went past the end of the
                        ; name, so decrement Y to a value of 6 so we can use it
                        ; as a counter in the following loop

                        ; We now copy the name that was entered into the current
                        ; commander file at NAME, to change the commander name

.cnme3

 LDA INWK+5,Y           ; Copy the Y-th character from INWK+5 to the Y-th
 STA NAME,Y             ; character of NAME

 DEY                    ; Decrement the loop counter

 BPL cnme3              ; Loop back until we have copied all seven characters
                        ; of the name (leaving Y with a value of -1)

                        ; We now check whether the entered name matches the
                        ; cheat commander name for the chosen language, and if
                        ; it does, we apply cheat mode

 LDA COK                ; If bit 7 of COK is set, then cheat mode has already
 BMI cnme5              ; been applied, so jump to cnme5

 INY                    ; Set Y = 0 so we can loop through the entered name,
                        ; checking each character against the cheat name

 LDX languageIndex      ; Set X to the index of the chosen language, so this is
                        ; the index of the first character of the cheat name for
                        ; the chosen language, as the table at cheatCmdrName
                        ; interleaves the characters from each of the four
                        ; languages so that the cheat name for language X starts
                        ; at cheatCmdrName + X, with each character being four
                        ; bytes on from the previous one
                        ;
                        ; Presumably this is an attempt to hide the cheat names
                        ; from anyone casually browsing through the game binary

.cnme4

 LDA NAME,Y             ; Set A to the Y-th character of the new commander name

 CMP cheatCmdrName,X    ; If the character in A does not match the X-th
 BNE cnme5              ; character of the cheat name for the chosen language,
                        ; jump to cnme5 to skip applying cheat mode

 INX                    ; Set X = X + 4
 INX                    ;
 INX                    ; So X now points to the next character of the cheat
 INX                    ; name for the chosen language

 INY                    ; Increment Y to move on to the next character in the
                        ; name

 CPY #7                 ; Loop back to check the next character until we have
 BNE cnme4              ; checked all seven characters

                        ; If we get here then the new commander name matches the
                        ; cheat name for the chosen language (so if this is
                        ; English, then the new name is "CHEATER", for example),
                        ; so now we apply cheat mode

 LDA #%10000000         ; Set bit 7 of COK to record that cheat mode has been
 STA COK                ; applied to this commander, so we can't apply it again,
                        ; and we can't change our commander name either (so once
                        ; you cheat, you have to own it)

 LDA #$A0               ; Set CASH(0 1 2 3) = CASH(0 1 2 3) + &000186A0
 CLC                    ;
 ADC CASH+3             ; So this adds 100000 to our cash reserves, giving us
 STA CASH+3             ; an extra 10,000.0 credits
 LDA #$86
 ADC CASH+2
 STA CASH+2
 LDA CASH+1
 ADC #1
 STA CASH+1
 LDA CASH
 ADC #0
 STA CASH

.cnme5

 JSR CLYNS              ; Clear the bottom two text rows of the upper screen,
                        ; and move the text cursor to column 1 on row 21, i.e.
                        ; the start of the top row of the two bottom rows

 JMP DrawMessageInNMI   ; Configure the NMI to update the in-flight message part
                        ; of the screen (which is the same as the part that the
                        ; call to CLYNS just cleared), returning from the
                        ; subroutine using a tail call

.cnme6

                        ; If we get here then the entered name does not use all
                        ; seven characters, so we pad the name out with spaces
                        ;
                        ; We get here with Y set to the index of the ASCII 13
                        ; string terminator, so we can simply fill from that
                        ; position to the end of the string

 LDA #' '               ; Set the Y-th character of the name at INWK+5 to a
 STA INWK+5,Y           ; space

 CPY #6                 ; If Y = 6 then we have reached the end of the string,
 BEQ cnme3              ; so jump to cnme3 with Y = 6 to continue processing the
                        ; new name

 INY                    ; Increment Y to point to the next character along

 BNE cnme6              ; Jump back to cnme6 to keep filling the name with
                        ; spaces (this BNE is effectively a JMP as Y is never
                        ; zero)

; ******************************************************************************
;
;       Name: cheatCmdrName
;       Type: Variable
;   Category: Save and load
;    Summary: The commander name that triggers cheat mode in each language
;
; ******************************************************************************

.cheatCmdrName

 EQUS "CBTI"            ; English = "CHEATER" (column 1)
 EQUS "HERN"            ;
 EQUS "ETIG"            ; German = "BETRUG" (column 2)
 EQUS "ARCA"            ;
 EQUS "TUHN"            ; French = "TRICHER" (column 3)
 EQUS "EGEN"            ;
 EQUS "R RO"            ; Italian = "INGANNO" (column 4)
                        ;
                        ; Italian does not appear anywhere else in the game, and
                        ; a fourth language is not supported

; ******************************************************************************
;
;       Name: SetKeyLogger
;       Type: Subroutine
;   Category: Controllers
;    Summary: Populate the key logger table with the controller button presses
;  Deep dive: Bolting NES controllers onto the key logger
;
; ------------------------------------------------------------------------------
;
; Returns:
;
;   X                   The button number of an icon bar button if an icon bar
;                       button has been chosen (0 if no icon bar button has been
;                       chosen)
;
;   Y                   Y is preserved
;
; ******************************************************************************

.SetKeyLogger

 TYA                    ; Store Y on the stack so we can restore it at the end
 PHA                    ; of the subroutine

                        ; We start by clearing the key logger table at KL

 LDX #5                 ; We want to clear the 6 key logger locations from
                        ; KY1 to KY6, so set a counter in X

 LDA #0                 ; Set A = 0 to store in the key logger table to clear it

 STA iconBarKeyPress    ; Set iconBarKeyPress = 0 as the default value to return
                        ; if an icon bar button has not been chosen

.klog1

 STA KL,X               ; Store 0 in the X-th byte of the key logger

 DEX                    ; Decrement the counter

 BPL klog1              ; Loop back for the next key, until we have cleared from
                        ; KY1 through KY6

 SETUP_PPU_FOR_ICON_BAR ; If the PPU has started drawing the icon bar, configure
                        ; the PPU to use nametable 0 and pattern table 0

 LDA numberOfPilots     ; If the game is configured for one pilot, jump to klog7
 BEQ klog7              ; to skip setting the key logger for controller 2

 LDX #$FF               ; Set X to $FF to use as the non-zero value in the key
                        ; logger to indicate that a key is being pressed

 LDA controller2Down    ; If the down button is not being pressed on controller
 BPL klog2              ; 2, jump to klog2 to skip the following instruction

 STX KY5                ; The down button is being pressed on controller 2, so
                        ; set KY5 = $FF

.klog2

 LDA controller2Up      ; If the up button is not being pressed on controller 2,
 BPL klog3              ; jump to klog3 to skip the following instruction

 STX KY6                ; The up button is being pressed on controller 2, so
                        ; set KY6 = $FF

.klog3

 LDA controller2Left    ; If the left button is not being pressed on controller
 BPL klog4              ; 2, jump to klog4 to skip the following instruction

 STX KY3                ; The left button is being pressed on controller 2, so
                        ; set KY3 = $FF

.klog4

 LDA controller2Right   ; If the right button is not being pressed on controller
 BPL klog5              ; 2, jump to klog5 to skip the following instruction

 STX KY4                ; The right button is being pressed on controller 2, so
                        ; set KY4 = $FF

.klog5

 LDA controller2A       ; If the A button is not being pressed on controller 2,
 BPL klog6              ; jump to klog6 to skip the following instruction

 STX KY2                ; The A button is being pressed on controller 2, so
                        ; set KY2 = $FF

.klog6

 LDA controller2B       ; If the B button is not being pressed on controller 2,
 BPL klog13             ; 2, jump to klog13 to scan the A button on controller 1
                        ; and return from the subroutine

 STX KY1                ; The B button is being pressed on controller 2, so
                        ; set KY1 = $FF

 BMI klog13             ; Jump to klog13 to scan the A button on controller 1
                        ; and return from the subroutine

.klog7

 LDX #$FF               ; Set X to $FF to use as the non-zero value in the key
                        ; logger to indicate that a key is being pressed

 LDA controller1B       ; If the B button is being pressed on controller 1, jump
 BMI klog11             ; to klog11 to skip recording the direction keys in KY3
                        ; to KY4, and just record the up and down buttons in KY2
                        ; and KY3

 LDA controller1Down    ; If the down button is not being pressed on controller
 BPL klog8              ; 1, jump to klog8 to skip the following instruction

 STX KY5                ; The down button is being pressed on controller 1 (and
                        ; the B button is not being pressed), so set KY5 = $FF

.klog8

 LDA controller1Up      ; If the up button is not being pressed on controller 1,
 BPL klog9              ; jump to klog9 to skip the following instruction

 STX KY6                ; The up button is being pressed on controller 1 (and
                        ; the B button is not being pressed), so set KY6 = $FF

.klog9

 LDA controller1Left    ; If the left button is not being pressed on controller
 BPL klog10             ; 1, jump to klog10 to skip the following instruction

 STX KY3                ; The left button is being pressed on controller 1 (and
                        ; the B button is not being pressed), so set KY3 = $FF

.klog10

 LDA controller1Right   ; If the right button is not being pressed on controller
 BPL klog13             ; 1, jump to klog13 to skip the following instruction

 STX KY4                ; The right button is being pressed on controller 1 (and
                        ; the B button is not being pressed), so set KY4 = $FF

 BMI klog13             ; Jump to klog13 to scan the A button on controller 1
                        ; and return from the subroutine

.klog11

 LDA controller1Up      ; If the up button is not being pressed on controller 1,
 BPL klog12             ; jump to klog12 to skip the following instruction

 STX KY2                ; The up button is being pressed on controller 2, and so
                        ; is the B button, so set KY2 = $FF

.klog12

 LDA controller1Down    ; If the down button is not being pressed on controller
 BPL klog13             ; 1, jump to klog13 to skip the following instruction

 STX KY1                ; The down button is being pressed on controller 1, and
                        ; so is the B button, so set KY1 = $FF

.klog13

 LDA controller1A       ; If the A button is being pressed on controller 1 but
 CMP #%10000000         ; wasn't being pressed before, shift a 1 into bit 7 of
 ROR KY7                ; KY7 (as A = %10000000), otherwise shift a 0

 LDX #0                 ; Copy the value of iconBarChoice to iconBarKeyPress and
 LDA iconBarChoice      ; set iconBarChoice = 0, so if an icon bar button is
 STX iconBarChoice      ; chosen then the first time it is pressed we return the
 STA iconBarKeyPress    ; button number, and if it is pressed again, we return 0
                        ;
                        ; This lets us use the Start button to toggle the pause
                        ; menu on and off, for example

 PLA                    ; Restore the value of Y that we stored on the stack, so
 TAY                    ; that Y is preserved

 LDA iconBarKeyPress    ; Set X = iconBarKeyPress to return the icon bar button
 TAX                    ; number from the subroutine, if any

 RTS                    ; Return from the subroutine

; ******************************************************************************
;
;       Name: ChooseLanguage
;       Type: Subroutine
;   Category: Start and end
;    Summary: Draw the Start screen and process the language choice
;
; ------------------------------------------------------------------------------
;
; Arguments:
;
;   K%                  The number of the language to highlight
;
;   K%+1                The value of the third counter (we start the demo on
;                       auto-play once all three counters have run down without
;                       a choice being made)
;
; ******************************************************************************

.ChooseLanguage

 LDA #HI(iconBarImage0) ; Set iconBarImageHi to the high byte of the image data
 STA iconBarImageHi     ; for icon bar type 0 (Docked)

 LDY #0                 ; Clear bit 7 of autoPlayDemo so we do not play the demo
 STY autoPlayDemo       ; automatically (so the player plays the demo instead)

 JSR SetLanguage        ; Set the language-related variables to language 0
                        ; (English) as Y = 0, so English is the default language

 LDA #$CF               ; Clear the screen and set the view type in QQ11 to $CF
 JSR TT66_b0            ; (Start screen with no fonts loaded)

 LDA #HI(iconBarImage3) ; Set iconBarImageHi to the high byte of the image data
 STA iconBarImageHi     ; for icon bar type 3 (Pause)

 LDA #0                 ; Move the text cursor to row 0
 STA YC

 LDA #7                 ; Move the text cursor to column 7
 STA XC

 LDA #3                 ; Set A = 3 so the next instruction prints extended
                        ; token 3

IF _PAL

 JSR DETOK_b2           ; Print extended token 3 ("{sentence case}{single cap}
                        ; IMAGINEER {single cap}PRESENTS")

ENDIF

 LDA #$DF               ; Set the view type in QQ11 to $DF (Start screen with
 STA QQ11               ; the normal font loaded)

 JSR DrawBigLogo_b4     ; Set the pattern and nametable buffer entries for the
                        ; big Elite logo

 LDA #36                ; Set asciiToPattern = 36, so we add 36 to an ASCII code
 STA asciiToPattern     ; in the CHPR routine to get the pattern number in the
                        ; PPU of the corresponding character image (as the font
                        ; is at pattern 68 on the Start screen, and the font
                        ; starts with a space character, which is ASCII 32, and
                        ; 32 + 36 = 68)

 LDA #21                ; Move the text cursor to row 21
 STA YC

 LDA #10                ; Move the text cursor to column 10
 STA XC

 LDA #6                 ; Set A = 6 so the next instruction prints extended
                        ; token 6

IF _PAL

 JSR DETOK_b2           ; Print extended token 6 ("{single cap}LICENSED{cr} TO")

ENDIF

 INC YC                 ; Move the text cursor to row 22

 LDA #3                 ; Move the text cursor to column 3
 STA XC

 LDA #9                 ; Set A = 9 so the next instruction prints extended
                        ; token 9

IF _PAL

 JSR DETOK_b2           ; Print extended token 9 ("{single cap}IMAGINEER {single
                        ; cap}CO. {single cap}LTD., {single cap}JAPAN")

ENDIF

 LDA #25                ; Move the text cursor to row 25
 STA YC

 LDA #3                 ; Move the text cursor to column 3
 STA XC

 LDA #12                ; Print extended token 12 ("({single cap}C) {single cap}
 JSR DETOK_b2           ; D.{single cap}BRABEN & {sentence case}I.{single cap}
                        ; BELL 1991")

 LDA #26                ; Move the text cursor to row 26
 STA YC

 LDA #6                 ; Move the text cursor to column 6
 STA XC

 LDA #7                 ; Set A = 7 so the next instruction prints extended
                        ; token 7

IF _PAL

 JSR DETOK_b2           ; Print extended token 7 ("{single cap}LICENSED BY
                        ;  {single cap}NINTENDO")

ENDIF

                        ; We now draw the bottom of the box that goes around the
                        ; edge of the title screen, with the bottom line on tile
                        ; row 28 and an edge on either side of row 27

 LDY #2                 ; First we draw the horizontal line from tile 2 to 31 on
                        ; row 28, so set a tile index in Y

 LDA #229               ; Set A to the pattern to use for the bottom of the box,
                        ; which is in pattern 229

.clan1

 STA nameBuffer0+28*32,Y    ; Set tile Y on row 28 to pattern 229

 INY                    ; Increment the tile index

 CPY #32                ; Loop back until we have drawn from tile index 2 to 31
 BNE clan1

                        ; Next we draw the corners and the tiles above the
                        ; corners

 LDA #2                 ; Draw the bottom-right box corner and the tile above
 STA nameBuffer0+27*32
 STA nameBuffer0+28*32

 LDA #1                 ; Draw the bottom-left box corner and the tile above
 STA nameBuffer0+27*32+1
 STA nameBuffer0+28*32+1

                        ; We now display the language names so the player can
                        ; make their choice

 LDY #0                 ; We now work our way through the available languages,
                        ; starting with language 0, so set a language counter
                        ; in Y

.clan2

 JSR SetLanguage        ; Set the language-related variables to language Y

 LDA xLanguage,Y        ; Move the text cursor to the correct column for the
 STA XC                 ; language Y button, taken from the xLanguage table

 LDA yLanguage,Y        ; Move the text cursor to the correct row for the
 STA YC                 ; language Y button, taken from the yLanguage table

 LDA #%00000000         ; Set DTW8 = %00000000 (capitalise the next letter)
 STA DTW8

 LDA #4                 ; Print extended token 4, which is the language name,
 JSR DETOK_b2           ; so when Y = 0 it will be "{single cap}ENGLISH", for
                        ; example

 INC XC                 ; Move the text cursor two characters to the right
 INC XC

 INY                    ; Increment the language counter in Y

 LDA languageIndexes,Y  ; If the language index for language Y has bit 7 clear
 BPL clan2              ; then this is a valid language, so loop back to clan2
                        ; to print this language's name (language 3 has a value
                        ; of $FF in the languageIndexes table, so we only print
                        ; names for languages 0, 1 and 2)

 STY systemNumber       ; Set the current system number in systemNumber to 3,
                        ; though this doesn't appear to be used anywhere (this
                        ; normally stores the current system number for use in
                        ; the PDESC routine for printing extended system
                        ; descriptions, but it gets reset before we get that
                        ; far, so this appears to have no effect)

 LDA #HI(iconBarImage3) ; Set iconBarImageHi to the high byte of the image data
 STA iconBarImageHi     ; for icon bar type 3 (Pause)

 JSR UpdateView_b0      ; Update the view

 LDA controller1Left    ; If any of the left button, up button, Select or B are
 AND controller1Up      ; not being pressed on the controller, jump to clan3
 AND controller1Select
 AND controller1B
 BPL clan3

 LDA controller1Right   ; If any of the right button, down button, Start or A
 ORA controller1Down    ; are being pressed on the controller, jump to clan3
 ORA controller1Start
 ORA controller1A
 BMI clan3

                        ; If we get here then we are pressing the right button,
                        ; down button, Start and A, and we are not pressing any
                        ; of the other keys

 JSR ResetSaveSlots     ; Reset all eight save slots so they fail their
                        ; checksums, so the following call to CheckSaveSlots
                        ; resets then all to the default commander

.clan3

 JSR CheckSaveSlots_b6  ; Load the commanders for all eight save slots, one
                        ; after the other, to check their integrity and reset
                        ; any that fail their checksums

                        ; We now highlight the currently selected language name
                        ; on-screen

 LDA #%10000000         ; Set bit 7 of S to indicate that the choice has not yet
 STA S                  ; been made (we will clear bit 7 when Start is pressed
                        ; and release, which makes the choice)

IF _NTSC

 LDA #25                ; Set T = 25
 STA T                  ;
                        ; This is the value of the first counter (we start the
                        ; demo on auto-play once all three counters have run
                        ; down without a choice being made)

ELIF _PAL

 LDA #250               ; Set T = 250
 STA T                  ;
                        ; This is the value of the first counter (we start the
                        ; demo on auto-play once all three counters have run
                        ; down without a choice being made)

ENDIF

 LDA K%+1               ; Set V+1 = K%+1
 STA V+1                ;
                        ; We set K%+1 to 60 in the BEGIN routine when the game
                        ; first started
                        ;
                        ; We set K%+1 to 5 if we get here after waiting at the
                        ; title screen for too long
                        ;
                        ; This is the value of the third counter (we start the
                        ; demo on auto-play once all three counters have run
                        ; down without a choice being made)

 LDA #0                 ; Set V = 0
 STA V                  ;
                        ; This is the value of the second counter (we start the
                        ; demo on auto-play once all three counters have run
                        ; down without a choice being made)
                        ;
                        ; As the counter is decremented before checking whether
                        ; it is zero, this means the second counter counts down
                        ; 256 times

 STA Q                  ; Set Q = 0 (though this value is not read, so this has
                        ; no effect)

 LDA K%                 ; Set LASCT = K%
 STA LASCT              ;
                        ; We set K% to 0 in the BEGIN routine when the game
                        ; first started
                        ;
                        ; We set K% to languageIndex if we get here after
                        ; waiting at the title screen for too long
                        ;
                        ; We use LASCT to keep a track of the currently
                        ; highlighted language, so this sets the default
                        ; highlight to English (language 0)

.clan4

 JSR WaitForNMI         ; Wait until the next NMI interrupt has passed (i.e. the
                        ; next VBlank)

                        ; We now highlight the currently selected language name
                        ; on-screen by creating eight sprites containing a white
                        ; block, initially creating them off-screen, before
                        ; moving the correct number of sprites behind the
                        ; currently selected name, so each letter in the name
                        ; is highlighted

 LDY LASCT              ; Set Y to the currently highlighted language in LASCT

 LDA xLanguage,Y        ; Set A to the column number of the button for language
                        ; Y, taken from the xLanguage table

 ASL A                  ; Set X = A * 8
 ASL A                  ;
 ASL A                  ; So X contains the pixel x-coordinate of the language
 ADC #0                 ; button, as each tile is eight pixels wide
 TAX

 CLC                    ; Clear the C flag so the addition below will work

 LDY #0                 ; We are about to set up the eight sprites that we use
                        ; to highlight the current language choice, using
                        ; sprites 5 to 12, so set an index counter in Y that we
                        ; can use to point to each sprite in the sprite buffer

.clan5

                        ; We now set the coordinates, tile and attributes for
                        ; the Y-th sprite, starting from sprite 5

 LDA #240               ; Set the sprite's y-coordinate to 240 to move it off
 STA ySprite5,Y         ; the bottom of the screen (which hides it)

 LDA #255               ; Set the sprite to pattern 255, which is a full white
 STA pattSprite5,Y      ; block

 LDA #%00100000         ; Set the attributes for this sprite as follows:
 STA attrSprite5,Y      ;
                        ;   * Bits 0-1    = sprite palette 0
                        ;   * Bit 5 set   = show behind background
                        ;   * Bit 6 clear = do not flip horizontally
                        ;   * Bit 7 clear = do not flip vertically

 TXA                    ; Set the sprite's x-coordinate to X, which is the
 STA xSprite5,Y         ; x-coordinate for the current letter in the
                        ; language's button

 ADC #8                 ; Set X = X + 8
 TAX                    ;
                        ; So X now contains the pixel x-coordinate of the next
                        ; letter in the language's button

 INY                    ; Set Y = Y + 4
 INY                    ;
 INY                    ; So Y now points to the next sprite in the sprite
 INY                    ; buffer, as each sprite has four bytes in the buffer

 CPY #32                ; Loop back until we have set up all eight sprites for
 BNE clan5              ; the currently highlighted language

                        ; Now that we have created the eight sprites off-screen,
                        ; we move the correct number of then on-screen so they
                        ; display behind each letter of the currently
                        ; highlighted language name

 LDX LASCT              ; Set X to the currently highlighted language in LASCT

 LDA languageLength,X   ; Set Y to the number of characters in the currently
                        ; highlighted language's name, from the languageLength
                        ; table

 ASL A                  ; Set Y = A * 4
 ASL A                  ;
 TAY                    ; So Y contains an index into the sprite buffer for the
                        ; last sprite that we need from the eight available (as
                        ; we need one sprite for each character in the name)

 LDA yLanguage,X        ; Set A to the row number of the button for language Y,
                        ; taken from the yLanguage table

 ASL A                  ; Set A = A * 8 + 6
 ASL A                  ;
 ASL A                  ; So A contains the pixel y-coordinate of the language
 ADC #6+YPAL            ; button, as each tile row is eight pixels high, plus a
                        ; margin of 6

.clan6

 STA ySprite5,Y         ; Set the sprite's y-coordinate to A

 DEY                    ; Decrement the sprite number by 4 to point to the
 DEY                    ; sprite for the previous letter in the language name
 DEY
 DEY

 BPL clan6              ; Loop back until we have moved the sprite on-screen for
                        ; the first letter of the currently highlighted
                        ; language's name

 LDA controller1Start   ; If the Start button on controller 1 was being held
 AND #%11000000         ; down (bit 6 is set) but is no longer being held down
 CMP #%01000000         ; (bit 7 is clear) then keep going, otherwise jump to
 BNE clan7              ; clan7

 LSR S                  ; The Start button has been pressed and release, so
                        ; shift S right to clear bit 7

.clan7

 LDX LASCT              ; Set X to the currently highlighted language in LASCT

 LDA controller1Left    ; If the left button on controller 1 was being held
 AND #%11000000         ; down (bit 6 is set) but is no longer being held down
 CMP #%01000000         ; (bit 7 is clear) then keep going, otherwise jump to
 BNE clan8              ; clan8

 DEX                    ; Decrement the currently highlighted language to point
                        ; to the next language to the left

 LDA K%+1               ; Set V+1 = K%+1
 STA V+1                ;
                        ; We already did this above, so this has no effect

.clan8

 LDA controller1Right   ; If the right button on controller 1 was being held
 AND #%11000000         ; down (bit 6 is set) but is no longer being held down
 CMP #%01000000         ; (bit 7 is clear) then keep going, otherwise jump to
 BNE clan9              ; clan9

 INX                    ; Increment the currently highlighted language to point
                        ; to the next language to the right

 LDA K%+1               ; Set V+1 = K%+1
 STA V+1                ;
                        ; We already did this above, so this has no effect

.clan9

 TXA                    ; Set A to the currently selected language, which may or
                        ; may not have changed

 BPL clan10             ; If A is positive, jump to clan10 to skip the following
                        ; instruction

 LDA #0                 ; Set A = 0, so the minimum value of A is 0

.clan10

 CMP #3                 ; If A < 3, then jump to clan11 to skip the following
 BCC clan11             ; instruction

 LDA #2                 ; Set A = 2, so the maximum value of A is 2

.clan11

 STA LASCT              ; Set LASCT to the currently selected language

 DEC T                  ; Decrement the first counter in T

 BEQ clan13             ; If the counter in T has reached zero, jump to clan13
                        ; to check whether a choice has been made, and if not,
                        ; to count down the second and third counters

.clan12

 JMP clan4              ; Loop back to clan4 keep checking for the selection and
                        ; moving the highlight as required, until a choice is
                        ; made

.clan13

 INC T                  ; Increment the first counter in T so we jump here again
                        ; on the next run through the clan4 loop

 LDA S                  ; If bit 7 of S is clear then Start has been pressed and
 BPL SetChosenLanguage  ; released, so jump to SetChosenLanguage to set the
                        ; language-related variables according to the chosen
                        ; language, returning from the subroutine using a tail
                        ; call

 DEC V                  ; Decrement the second counter in V, and loop back to
 BNE clan12             ; repeat the clan4 loop until it is zero

 DEC V+1                ; Decrement the third counter in V+1, and loop back to
 BNE clan12             ; repeat the clan4 loop until it is zero

                        ; If we get here then no choice has been made and we
                        ; have run down the first, second and third counters, so
                        ; we now start the demo, with the computer auto-playing
                        ; it

 JSR SetChosenLanguage  ; Call SetChosenLanguage to set the language-related
                        ; variables according to the currently selected language
                        ; on-screen

 JMP SetDemoAutoPlay_b5 ; Start the demo and auto-play it by "pressing" keys
                        ; from the relevant key table (which will be different,
                        ; depending on which language is currently highlighted)
                        ; and return from the subroutine using a tail call

; ******************************************************************************
;
;       Name: SetChosenLanguage
;       Type: Subroutine
;   Category: Start and end
;    Summary: Set the language-related variables according to the language
;             chosen on the Start screen
;
; ******************************************************************************

.SetChosenLanguage

 LDY LASCT              ; Set Y to the language choice, which gets stored in
                        ; LASCT by the ChooseLanguage routine

                        ; Fall through to set the language chosen in Y

; ******************************************************************************
;
;       Name: SetLanguage
;       Type: Subroutine
;   Category: Start and end
;    Summary: Set the language-related variables for a specific language
;
; ------------------------------------------------------------------------------
;
; Arguments:
;
;   Y                   The number of the language choice to set
;
; ******************************************************************************

.SetLanguage

 LDA tokensLo,Y         ; Set (QQ18Hi QQ18Lo) to the language's entry from the
 STA QQ18Lo             ; (tokensHi tokensLo) table
 LDA tokensHi,Y
 STA QQ18Hi

 LDA extendedTokensLo,Y ; Set (TKN1Hi TKN1Lo) to the language's entry from the
 STA TKN1Lo             ; the (extendedTokensHi extendedTokensLo) table
 LDA extendedTokensHi,Y
 STA TKN1Hi

 LDA languageIndexes,Y  ; Set languageIndex to the language's index from the
 STA languageIndex      ; languageIndexes table

 LDA languageNumbers,Y  ; Set languageNumber to the language's flags from the
 STA languageNumber     ; languageNumbers table

 LDA characterEndLang,Y ; Set characterEnd to the end of the language's
 STA characterEnd       ; character set from the characterEndLang table

 LDA decimalPointLang,Y ; Set decimalPoint to the language's decimal point
 STA decimalPoint       ; character from the decimalPointLang table

 RTS                    ; Return from the subroutine

; ******************************************************************************
;
;       Name: xLanguage
;       Type: Variable
;   Category: Start and end
;    Summary: The text column for the language buttons on the Start screen
;  Deep dive: Multi-language support in NES Elite
;
; ******************************************************************************

.xLanguage

 EQUB 2                 ; English

 EQUB 12                ; German

 EQUB 22                ; French

 EQUB 17                ; There is no fourth language, so this byte is ignored

; ******************************************************************************
;
;       Name: yLanguage
;       Type: Variable
;   Category: Start and end
;    Summary: The text row for the language buttons on the Start screen
;  Deep dive: Multi-language support in NES Elite
;
; ******************************************************************************

.yLanguage

 EQUB 23                ; English

 EQUB 24                ; German

 EQUB 23                ; French

 EQUB 24                ; There is no fourth language, so this byte is ignored

; ******************************************************************************
;
;       Name: characterEndLang
;       Type: Variable
;   Category: Text
;    Summary: The number of the character beyond the end of the printable
;             character set in each language
;  Deep dive: Multi-language support in NES Elite
;
; ******************************************************************************

.characterEndLang

 EQUB 91                ; English

 EQUB 96                ; German

 EQUB 96                ; French

 EQUB 96                ; There is no fourth language, so this byte is ignored

; ******************************************************************************
;
;       Name: decimalPointLang
;       Type: Variable
;   Category: Text
;    Summary: The decimal point character to use for each language
;  Deep dive: Multi-language support in NES Elite
;
; ******************************************************************************

.decimalPointLang

 EQUB '.'               ; English

 EQUB '.'               ; German

 EQUB ','               ; French

 EQUB '.'               ; There is no fourth language, so this byte is ignored

; ******************************************************************************
;
;       Name: languageLength
;       Type: Variable
;   Category: Text
;    Summary: The length of each language name
;
; ******************************************************************************

.languageLength

 EQUB 6                 ; English

 EQUB 6                 ; German

 EQUB 7                 ; French

; ******************************************************************************
;
;       Name: tokensLo
;       Type: Variable
;   Category: Text
;    Summary: Low byte of the text token table for each language
;  Deep dive: Multi-language support in NES Elite
;
; ******************************************************************************

.tokensLo

 EQUB LO(QQ18)          ; English

 EQUB LO(QQ18_DE)       ; German

 EQUB LO(QQ18_FR)       ; French

; ******************************************************************************
;
;       Name: tokensHi
;       Type: Variable
;   Category: Text
;    Summary: High byte of the text token table for each language
;  Deep dive: Multi-language support in NES Elite
;
; ******************************************************************************

.tokensHi

 EQUB HI(QQ18)          ; English

 EQUB HI(QQ18_DE)       ; German

 EQUB HI(QQ18_FR)       ; French

; ******************************************************************************
;
;       Name: extendedTokensLo
;       Type: Variable
;   Category: Text
;    Summary: Low byte of the extended text token table for each language
;  Deep dive: Multi-language support in NES Elite
;
; ******************************************************************************

.extendedTokensLo

 EQUB LO(TKN1)          ; English

 EQUB LO(TKN1_DE)       ; German

 EQUB LO(TKN1_FR)       ; French

; ******************************************************************************
;
;       Name: extendedTokensHi
;       Type: Variable
;   Category: Text
;    Summary: High byte of the extended text token table for each language
;  Deep dive: Multi-language support in NES Elite
;
; ******************************************************************************

.extendedTokensHi

 EQUB HI(TKN1)          ; English

 EQUB HI(TKN1_DE)       ; German

 EQUB HI(TKN1_FR)       ; French

; ******************************************************************************
;
;       Name: languageIndexes
;       Type: Variable
;   Category: Text
;    Summary: The index of the chosen language for looking up values from
;             language-indexed tables
;  Deep dive: Multi-language support in NES Elite
;
; ******************************************************************************

.languageIndexes

 EQUB 0                 ; English

 EQUB 1                 ; German

 EQUB 2                 ; French

 EQUB $FF               ; There is no fourth language, so this byte is ignored

; ******************************************************************************
;
;       Name: languageNumbers
;       Type: Variable
;   Category: Text
;    Summary: The language number for each language, as a set bit within a flag
;             byte
;  Deep dive: Multi-language support in NES Elite
;
; ******************************************************************************

.languageNumbers

 EQUB %00000001         ; English

 EQUB %00000010         ; German

 EQUB %00000100         ; French

; ******************************************************************************
;
;       Name: TT24
;       Type: Subroutine
;   Category: Universe
;    Summary: Calculate system data from the system seeds
;  Deep dive: Generating system data
;             Galaxy and system seeds
;
; ------------------------------------------------------------------------------
;
; Calculate system data from the seeds in QQ15 and store them in the relevant
; locations. Specifically, this routine calculates the following from the three
; 16-bit seeds in QQ15 (using only s0_hi, s1_hi and s1_lo):
;
;   QQ3 = economy (0-7)
;   QQ4 = government (0-7)
;   QQ5 = technology level (0-14)
;   QQ6 = population * 10 (1-71)
;   QQ7 = productivity (96-62480)
;
; The ranges of the various values are shown in brackets. Note that the radius
; and type of inhabitant are calculated on-the-fly in the TT25 routine when
; the system data gets displayed, so they aren't calculated here.
;
; ******************************************************************************

.TT24

 LDA QQ15+1             ; Fetch s0_hi and extract bits 0-2 to determine the
 AND #%00000111         ; system's economy, and store in QQ3
 STA QQ3

 LDA QQ15+2             ; Fetch s1_lo and extract bits 3-5 to determine the
 LSR A                  ; system's government, and store in QQ4
 LSR A
 LSR A
 AND #%00000111
 STA QQ4

 LSR A                  ; If government isn't anarchy or feudal, skip to TT77,
 BNE TT77               ; as we need to fix the economy of anarchy and feudal
                        ; systems so they can't be rich

 LDA QQ3                ; Set bit 1 of the economy in QQ3 to fix the economy
 ORA #%00000010         ; for anarchy and feudal governments
 STA QQ3

.TT77

 LDA QQ3                ; Now to work out the tech level, which we do like this:
 EOR #%00000111         ;
 CLC                    ;   flipped_economy + (s1_hi AND %11) + (government / 2)
 STA QQ5                ;
                        ; or, in terms of memory locations:
                        ;
                        ;   QQ5 = (QQ3 EOR %111) + (QQ15+3 AND %11) + (QQ4 / 2)
                        ;
                        ; We start by setting QQ5 = QQ3 EOR %111

 LDA QQ15+3             ; We then take the first 2 bits of s1_hi (QQ15+3) and
 AND #%00000011         ; add it into QQ5
 ADC QQ5
 STA QQ5

 SETUP_PPU_FOR_ICON_BAR ; If the PPU has started drawing the icon bar, configure
                        ; the PPU to use nametable 0 and pattern table 0

 LDA QQ4                ; And finally we add QQ4 / 2 and store the result in
 LSR A                  ; QQ5, using LSR then ADC to divide by 2, which rounds
 ADC QQ5                ; up the result for odd-numbered government types
 STA QQ5

 ASL A                  ; Now to work out the population, like so:
 ASL A                  ;
 ADC QQ3                ;   (tech level * 4) + economy + government + 1
 ADC QQ4                ;
 ADC #1                 ; or, in terms of memory locations:
 STA QQ6                ;
                        ;   QQ6 = (QQ5 * 4) + QQ3 + QQ4 + 1

 LDA QQ3                ; Finally, we work out productivity, like this:
 EOR #%00000111         ;
 ADC #3                 ;  (flipped_economy + 3) * (government + 4)
 STA P                  ;                        * population
 LDA QQ4                ;                        * 8
 ADC #4                 ;
 STA Q                  ; or, in terms of memory locations:
 JSR MULTU              ;
                        ;   QQ7 = (QQ3 EOR %111 + 3) * (QQ4 + 4) * QQ6 * 8
                        ;
                        ; We do the first step by setting P to the first
                        ; expression in brackets and Q to the second, and
                        ; calling MULTU, so now (A P) = P * Q. The highest this
                        ; can be is 10 * 11 (as the maximum values of economy
                        ; and government are 7), so the high byte of the result
                        ; will always be 0, so we actually have:
                        ;
                        ;   P = P * Q
                        ;     = (flipped_economy + 3) * (government + 4)

 LDA QQ6                ; We now take the result in P and multiply by the
 STA Q                  ; population to get the productivity, by setting Q to
 JSR MULTU              ; the population from QQ6 and calling MULTU again, so
                        ; now we have:
                        ;
                        ;   (A P) = P * population

 ASL P                  ; Next we multiply the result by 8, as a 16-bit number,
 ROL A                  ; so we shift both bytes to the left three times, using
 ASL P                  ; the C flag to carry bits from bit 7 of the low byte
 ROL A                  ; into bit 0 of the high byte
 ASL P
 ROL A

 STA QQ7+1              ; Finally, we store the productivity in two bytes, with
 LDA P                  ; the low byte in QQ7 and the high byte in QQ7+1
 STA QQ7

 RTS                    ; Return from the subroutine

; ******************************************************************************
;
;       Name: ClearDashEdge
;       Type: Subroutine
;   Category: Drawing the screen
;    Summary: Clear the right edge of the dashboard
;
; ******************************************************************************

.ClearDashEdge

 JSR SetupPPUForIconBar ; If the PPU has started drawing the icon bar, configure
                        ; the PPU to use nametable 0 and pattern table 0

 LDA #0                 ; Clear the right edge of the box on rows 20 to 27 in
 STA nameBuffer0+20*32  ; nametable buffer 0
 STA nameBuffer0+21*32
 STA nameBuffer0+22*32
 STA nameBuffer0+23*32
 STA nameBuffer0+24*32
 STA nameBuffer0+25*32
 STA nameBuffer0+26*32
 STA nameBuffer0+27*32

 STA nameBuffer1+20*32  ; Clear the right edge of the box on rows 20 to 27 in
 STA nameBuffer1+21*32  ; nametable buffer 1
 STA nameBuffer1+22*32
 STA nameBuffer1+23*32
 STA nameBuffer1+24*32
 STA nameBuffer1+25*32
 STA nameBuffer1+26*32
 STA nameBuffer1+27*32

 RTS                    ; Return from the subroutine

; ******************************************************************************
;
;       Name: Vectors_b6
;       Type: Variable
;   Category: Utility routines
;    Summary: Vectors and padding at the end of ROM bank 6
;  Deep dive: Splitting NES Elite across multiple ROM banks
;
; ******************************************************************************

 FOR I%, P%, $BFF9

  EQUB $FF              ; Pad out the rest of the ROM bank with $FF

 NEXT

IF _NTSC

 EQUW Interrupts_b6+$4000   ; Vector to the NMI handler in case this bank is
                            ; loaded into $C000 during start-up (the handler
                            ; contains an RTI so the interrupt is processed but
                            ; has no effect)

 EQUW ResetMMC1_b6+$4000    ; Vector to the RESET handler in case this bank is
                            ; loaded into $C000 during start-up (the handler
                            ; resets the MMC1 mapper to map bank 7 into $C000
                            ; instead)

 EQUW Interrupts_b6+$4000   ; Vector to the IRQ/BRK handler in case this bank is
                            ; loaded into $C000 during start-up (the handler
                            ; contains an RTI so the interrupt is processed but
                            ; has no effect)

ELIF _PAL

 EQUW NMI                   ; Vector to the NMI handler

 EQUW ResetMMC1_b6+$4000    ; Vector to the RESET handler in case this bank is
                            ; loaded into $C000 during start-up (the handler
                            ; resets the MMC1 mapper to map bank 7 into $C000
                            ; instead)

 EQUW IRQ                   ; Vector to the IRQ/BRK handler

ENDIF

; ******************************************************************************
;
; Save bank6.bin
;
; ******************************************************************************

 PRINT "S.bank6.bin ", ~CODE%, " ", ~P%, " ", ~LOAD%, " ", ~LOAD%
 SAVE "3-assembled-output/bank6.bin", CODE%, P%, LOAD%
