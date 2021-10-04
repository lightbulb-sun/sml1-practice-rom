# Prerequisites

* GNU Make
* [RGBDS](https://rgbds.gbdev.io/)
* (optional) bsdiff
* (optional) [Save state patch by Matt Currie](https://github.com/mattcurrie/gb-save-states)

# Building
1. Place a copy of the original ROM(s) in the root directory under the filenames
   `Super Mario Land (W) (V1.0) [!].gb` and/or
   `Super Mario Land (W) (V1.1) [!].gb`.
2. (optional) Copy the save state patch(es)
   `Super Mario Land (W) (V1.0) [!].gb.bsdiff` and/or
   `Super Mario Land (W) (V1.1) [!].gb.bsdiff`
   into the root directory.
3. Run `make` to build both versions,
   `make v10` to only build version v1.0, or
   `make v11` to only build version v1.1.
   The patched ROM(s)
   `sml1_practice_v10.gb` and/or
   `sml1_practice_v11.gb`
   are placed in the root directory.
