# thug-pro-reshade

Reshade Settings for THUG Pro.

## Preview

![Preview of Reshade Effects](preview.png)

## Installation

### If you have bash, run:

```bash
$ ./reshade install <windowsUsername>
```

### Otherwise:

Copy the contents of the `THUG Pro` directory into the `THUG Pro` game directory (`%appdata%/Local/THUG Pro`).

Now when you open the game, the effects will be loaded.

## Usage

You can tweak the effects by modifying the `.cfg` files in the `THUG Pro/scripts/ReShade/Presets/thugpro` directory.

Play around and see what effects you can achieve!

Most shaders can be disabled by pressing the Scroll Lock key.

## Importing configs to Repository

(Requires bash)

```bash
$ ./reshade import <windowsUsername>
```

## Exporting configs to THUG Pro

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
* Edem (for sending me his reshade configuration, and helping me recover lost files)
