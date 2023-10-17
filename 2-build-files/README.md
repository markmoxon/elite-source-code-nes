# Build files for the NES version of Elite

This folder contains support scripts for building the NES version of Elite.

* [crc32.py](crc32.py) calculates checksums during the verify stage and compares the results with the relevant binaries in the [4-reference-binaries](../4-reference-binaries) folder

* [unpack-data.py](unpack-data.py) extracts images and other packed data from the game binary and saves them in the [images](../1-source-files/images) folder

* [combine-images.py](combine-images.py) combines background and foreground images for the system and commander images and saves the results in the [commander-images](../1-source-files/images/commander-images) and [system-images](../1-source-files/images/system-images) folders

It also contains the `make.exe` executable for Windows, plus the required DLL files.

---

Right on, Commanders!

_Mark Moxon_