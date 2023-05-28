# Build files for the NES version of Elite

This folder contains support scripts for building the NES version of Elite.

* [crc32.py](crc32.py) calculates checksums during the verify stage and compares the results with the relevant binaries in the [4-reference-binaries](../4-reference-binaries) folder

* [unpack.py](unpack.py) extracts images and associated binaries from the game binary and saves them in the [images](../1-source-files/images) folder

It also contains the `make.exe` executable for Windows, plus the required DLL files.

---

Right on, Commanders!

_Mark Moxon_