# Super Mario Land practice ROM

This patch adds the following features to the
Game Boy game Super Mario Land:
* Select world, level, powerup and checkpoint from title screen
* Toggle between Normal/Hard modes with `[Select]` on title screen
* [Save states](https://github.com/mattcurrie/gb-save-states)
  (`[Start]+[↓]/[↑]` or `[Select]+[A]/[B]`)
* Adds short delay after pressing `[Start]` on title screen to make creation of initial save state easier
* Fixes bug in original ROM that sometimes causes console to lock up after star invincibility runs out

## Download
The latest release can be found on the
[releases page](https://github.com/lightbulb-sun/sml1-practice-rom/releases).
Patch the original ROM with one of the `.bsdiff` or `.ips` files
to create the practice ROM.

## Building
See BUILDING.md.

## License
Distributed under the MIT License. See LICENSE for more information.
