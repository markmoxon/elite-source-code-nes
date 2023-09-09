# Annotated source code for the NES version of Elite

This folder contains the annotated source code for the NES version of Elite.

* [elite-source-bank-0.asm](elite-source-bank-0.asm) contains the source for ROM bank 0 (main game loop, main flight loop, core game code)

* [elite-source-bank-1.asm](elite-source-bank-1.asm) contains the source for ROM bank 1 (ship blueprints, drawing ships, planets, suns and stardust)

* [elite-source-bank-2.asm](elite-source-bank-2.asm) contains the source for ROM bank 2 (game text in three languages, text routines)

* [elite-source-bank-3.asm](elite-source-bank-3.asm) contains the source for ROM bank 3 (icon bar images and routines, fonts, palettes, views, other images)

* [elite-source-bank-4.asm](elite-source-bank-4.asm) contains the source for ROM bank 4 (commander images, associated routines)

* [elite-source-bank-5.asm](elite-source-bank-5.asm) contains the source for ROM bank 5 (system images, associated routines)

* [elite-source-bank-6.asm](elite-source-bank-6.asm) contains the source for ROM bank 6 (sound, music, scroll text, save and load)

* [elite-source-bank-7.asm](elite-source-bank-7.asm) contains the source for ROM bank 7 (NMI handler, PPU routines, drawing lines and pixels, bank 7 switchyard, core maths routines)

* [elite-source-common.asm](elite-source-common.asm) contains common source code that is shared across all eight banks (variables, workspaces and macros)

* [elite-source-header.asm](elite-source-header.asm) contains the iNES header for the game

It also contains the following files that are generated during the build process:

* [elite-bank-options.asm](elite-bank-options.asm) stores the current bank number during the build

* [elite-build-options.asm](elite-build-options.asm) stores the make options in BeebAsm format so they can be included in the assembly process

---

Right on, Commanders!

_Mark Moxon_