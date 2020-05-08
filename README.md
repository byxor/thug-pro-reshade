# thug-pro-reshade

Reshade Settings for THUG Pro.

## Preview

![Before/After Picture](comparison.png)
![Preview of Reshade Effects](preview.png)

_Note: This preview is outdated, but you get the idea._

You can enable some much cooler effects.

## Installation

Copy the contents of this repository's `THUG Pro` directory into your computer's `THUG Pro` directory (check `%appdata%/Local/THUG Pro`).

### Alternatively

If you have bash, run:

```bash
$ ./reshade install <windowsUsername>
```

## Usage

When you open the game, the effects will be loaded.

You can tweak the effects by modifying the `.cfg` files in the `THUG Pro/scripts/ReShade/Presets/thugpro` directory.

When you export effects, the game will load the effects without needing to restart.

Play around and see what effects you can achieve!

Most effects can be disabled by pressing the Scroll Lock key.

## Importing effects to Repository

(Requires bash)

```bash
$ ./reshade import <windowsUsername>
```

## Exporting effects to THUG Pro

(Requires bash)

```bash
$ ./reshade export <windowsUsername>
```

## Credits

Shaders by:
* Alo81
* bacondither
* CeeJay
* Ganossa
* IDDQD
* Ioxa
* JPulowsky
* MartyMcFly
* Otis

Special Thanks:
* Edem (for sending me his reshade configuration and helping me recover lost files)
* Rav (for getting the DLL injection to work when upgrading to reshade 3)
