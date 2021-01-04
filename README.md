# thug-pro-reshade

Enhance/tweak THUG Pro's graphics with Reshade.

![Visual comparison of before/after](comparison.gif)
(Screenshots by AK)

_**Note:** You can apply many more crazy effects that aren't shown here._

## To install:

Copy the contents of this repository's `THUG Pro` directory into your computer's `THUG Pro` directory (check `%appdata%/Local/THUG Pro`).

## Usage

When you open the game, the effects will be loaded.

Open the reshade menu with the Home key to enable/edit/disable shaders.

You can save presets and swap between them through the menu.

Most effects can be temporarily disabled by pressing the Scroll Lock key.

## To uninstall:

Delete these files from your THUG Pro folder:
* `dinput8.dll`
* `d3d11.asi`
* `reshade-shaders` (folder)

Alternatively, temporarily rename `dinput8.dll` to something arbitrary (like `dinput8.dll.old`) to stop reshade from loading. Restoring the file name will enable reshade again.

## Special Thanks:
* Edem (for sending me his reshade configuration and helping me recover lost files)
* Rav (for getting the DLL injection to work when upgrading to reshade 3)
* AK (for providing updated screenshots)
