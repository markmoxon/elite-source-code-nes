BEEBASM?=beebasm
PYTHON?=python

# You can set the variant that gets built by adding 'variant=<rel>' to
# the make command, where <rel> is one of:
#
#   ntsc
#   pal
#
# So, for example:
#
#   make encrypt verify variant=ntsc
#
# will build the NTSC variant from Ian Bell's site. If you omit the
# variant parameter, it will build the NTSC variant.

ifeq ($(variant), pal)
  variant-nes=2
  folder-nes=/pal
  suffix-nes=-pal
else
  variant-nes=1
  folder-nes=/ntsc
  suffix-nes=-ntsc
endif

.PHONY:build
build:
	echo _VERSION=7 > 1-source-files/main-sources/elite-build-options.asm
	echo _VARIANT=$(variant-nes) >> 1-source-files/main-sources/elite-build-options.asm
	echo _REMOVE_CHECKSUMS=TRUE >> 1-source-files/main-sources/elite-build-options.asm
	$(BEEBASM) -i 1-source-files/main-sources/elite-source-header.asm -v > 3-assembled-output/compile.txt
	$(BEEBASM) -i 1-source-files/main-sources/elite-source-bank-0.asm -v >> 3-assembled-output/compile.txt
	$(BEEBASM) -i 1-source-files/main-sources/elite-source-bank-1.asm -v >> 3-assembled-output/compile.txt
	$(BEEBASM) -i 1-source-files/main-sources/elite-source-bank-2.asm -v >> 3-assembled-output/compile.txt
	$(BEEBASM) -i 1-source-files/main-sources/elite-source-bank-3.asm -v >> 3-assembled-output/compile.txt
	$(BEEBASM) -i 1-source-files/main-sources/elite-source-bank-4.asm -v >> 3-assembled-output/compile.txt
	$(BEEBASM) -i 1-source-files/main-sources/elite-source-bank-5.asm -v >> 3-assembled-output/compile.txt
	$(BEEBASM) -i 1-source-files/main-sources/elite-source-bank-6.asm -v >> 3-assembled-output/compile.txt
	$(BEEBASM) -i 1-source-files/main-sources/elite-source-bank-7.asm -v >> 3-assembled-output/compile.txt
	cat 3-assembled-output/header.bin 3-assembled-output/bank0.bin 3-assembled-output/bank1.bin 3-assembled-output/bank2.bin 3-assembled-output/bank3.bin 3-assembled-output/bank4.bin 3-assembled-output/bank5.bin 3-assembled-output/bank6.bin 3-assembled-output/bank7.bin > 3-assembled-output/elite.bin
	cp 3-assembled-output/elite.bin 5-compiled-game-discs/ELITE$(suffix-nes).NES

.PHONY:encrypt
encrypt:
	echo _VERSION=7 > 1-source-files/main-sources/elite-build-options.asm
	echo _VARIANT=$(variant-nes) >> 1-source-files/main-sources/elite-build-options.asm
	echo _REMOVE_CHECKSUMS=FALSE >> 1-source-files/main-sources/elite-build-options.asm
	$(BEEBASM) -i 1-source-files/main-sources/elite-source-header.asm -v > 3-assembled-output/compile.txt
	$(BEEBASM) -i 1-source-files/main-sources/elite-source-bank-0.asm -v >> 3-assembled-output/compile.txt
	$(BEEBASM) -i 1-source-files/main-sources/elite-source-bank-1.asm -v >> 3-assembled-output/compile.txt
	$(BEEBASM) -i 1-source-files/main-sources/elite-source-bank-2.asm -v >> 3-assembled-output/compile.txt
	$(BEEBASM) -i 1-source-files/main-sources/elite-source-bank-3.asm -v >> 3-assembled-output/compile.txt
	$(BEEBASM) -i 1-source-files/main-sources/elite-source-bank-4.asm -v >> 3-assembled-output/compile.txt
	$(BEEBASM) -i 1-source-files/main-sources/elite-source-bank-5.asm -v >> 3-assembled-output/compile.txt
	$(BEEBASM) -i 1-source-files/main-sources/elite-source-bank-6.asm -v >> 3-assembled-output/compile.txt
	$(BEEBASM) -i 1-source-files/main-sources/elite-source-bank-7.asm -v >> 3-assembled-output/compile.txt
	cat 3-assembled-output/header.bin 3-assembled-output/bank0.bin 3-assembled-output/bank1.bin 3-assembled-output/bank2.bin 3-assembled-output/bank3.bin 3-assembled-output/bank4.bin 3-assembled-output/bank5.bin 3-assembled-output/bank6.bin 3-assembled-output/bank7.bin > 3-assembled-output/elite.bin
	cp 3-assembled-output/elite.bin 5-compiled-game-discs/ELITE$(suffix-nes).NES

.PHONY:verify
verify:
	@$(PYTHON) 2-build-files/crc32.py 4-reference-binaries$(folder-nes) 3-assembled-output
