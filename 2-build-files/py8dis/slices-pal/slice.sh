# Slice the main Elite binary into the different memory banks

dd if=ELITE.NES of=header.bin bs=1 skip=0 count=16
dd if=ELITE.NES of=bank0.bin bs=1 skip=16 count=16384
dd if=ELITE.NES of=bank1.bin bs=1 skip=16400 count=16384
dd if=ELITE.NES of=bank2.bin bs=1 skip=32784 count=16384
dd if=ELITE.NES of=bank3.bin bs=1 skip=49168 count=16384
dd if=ELITE.NES of=bank4.bin bs=1 skip=65552 count=16384
dd if=ELITE.NES of=bank5.bin bs=1 skip=81936 count=16384
dd if=ELITE.NES of=bank6.bin bs=1 skip=98320 count=16384
dd if=ELITE.NES of=bank7.bin bs=1 skip=114704 count=16384

# Drop the last byte from bank 7 as py8dis can't handle $FFFF being populated

dd if=ELITE.NES of=bank7_first.bin bs=1 skip=114704 count=16383
dd if=ELITE.NES of=bank7_last.bin bs=1 skip=131087 count=1


# Confirm that the slices match the original binary when reassembled

cat header.bin bank0.bin bank1.bin bank2.bin bank3.bin bank4.bin bank5.bin bank6.bin bank7.bin | diff ELITE.NES -
