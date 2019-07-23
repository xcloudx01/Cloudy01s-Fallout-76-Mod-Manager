# Cloudy01's Fallout 76 Mod Manager
## Overview:

This tool makes it a snap to install new mods and manage existing ones. It also makes it easy to quickly enable/disable various tweaks.
No need to fumble around with the Fallout76Custom.ini file anymore, this takes care of it all for you, and even creates one for you if you haven't made one yet already.
The mod manager will automatically detect what kind of mod you've enabled (by scanning its contents), and assign it to the correct load order.
It will also combine multiple mods into just a few .ba2 files, so you can run as many mods as you like.

Features:
- Quickly install and uninstall mods
- Quickly enable/disable mods.
- Auto combines multiple mods into just a few .ba2 files. So you can have tons of mods enabled at once.
- Compile mods into .ba2 files.
- Quickly turn on/off various tweaks.
- Detects mods that have been updated since it was last ran.

## Initial Setup
1. Download the .exe file and run it.
2. It will attempt to detect where your game is currently installed. If it does not find your game, you will be prompted to provide the path to your Fallout76's Data folder (This is typically in a path such as: C:\Program Files\Bethesda.net Launcher\Games\Fallout76\Data)
3. It will then attempt to auto-detect where your current Fallout76Custom.ini is, if the file doesn't already exist yet, it will create a blank one for you.

## Installing mods
1. Find a mod you like, and drag it onto the Mod Manager, or click "Install a mod" and pick your file. It can be a .ba2 file, a zipped .ba2 file, or a zipped loose-file mod.
2. Simply check or un-check the mods you want to use.
4. Click the "Save Settings" button.
5. Play the game!

## Uninstalling mods
1. Right-click the mod you want to uninstall and then click the button "Uninstall" which is followed by the name of the mod. Eg "Uninstall Bag.ba2"

## Nuclear winter mode
- Before you play Nuclear Winter, just click the "Enable Nuclear Winter Mode" button. Your customini file will be disabled, and the following dll files will also be disabled: x3daudio1_7.dll, dxgi.dll, d3d11.dll. When you're done, just press the "Disable Nuclear Winter Mode" button.



## Notes
No tweaks you've manually set in the .ini file will be overwritten, unless specifically changed within the Mod Manager, such as enabling/disabling tweaks.

### Credits
- bsab tool by AlexxEG: https://github.com/AlexxEG/BSA_Browser
- The cool people at PCGW for providing tweak commands: https://pcgamingwiki.com/wiki/Fallout_76
- Archive2 tool (c) Bethesda
- 7z tool (c) Igor Pavlov: https://www.7-zip.org/

### License and Copyright
All rights on source code and libraries belong to their respective owners.
