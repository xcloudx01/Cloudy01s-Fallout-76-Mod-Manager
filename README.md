# Fallout 76 Mod Manager
## Overview:

This tool makes it a snap to install new mods and manage existing ones. It also makes it easy to quickly enable/disable various tweaks.
No need to fumble around with the Fallout76Custom.ini file anymore, this takes care of it all for you, and even creates one for you if you haven't made one yet already.
The mod manager will automatically detect what kind of mod you've enabled (by scanning its contents), and assign it to the correct load order. (sResourceStartUpArchiveList, sResourceIndexFileList, sResourceArchive2List)

Features:
- Quickly enable/disable mods.
- Automatic load order assigning.
- Quickly turn on/off intro videos, motion blur, fps cap, depth of field.

## Initial Setup
1. Download the .exe file and run it.
2. It will attempt to detect where your game is currently installed. If it does not find your game, you will be prompted to provide the path to your Fallout76's Data folder (This is typically in a path such as: C:\Program Files\Bethesda.net Launcher\Games\Fallout76\Data)
3. It will then attempt to auto-detect where your current Fallout76Custom.ini is, if the file doesn't already exist yet, it will create a blank one for you.

## Installing mods
1. Find a mod you like and copy its .ba2 mod file to your Fallout76's Data folder.
2. Run the Fallout 76 Mod Manager. If it's already running, click "Re-scan for new mods"
3. Simply check or un-check the mods you want to use.
4. Click the "Save Settings" button.
5. Play the game!

## Notes
The manager assigns mods in each category to load in alphabetical order. The ability to change it to a custom order could possibly be added if there is demand to add this feature.

If a mod is found to be enabled in the .ini file but its .ba2 file is missing, it will be auto-removed from the .ini file.

No tweaks you've manually set in the .ini file will be overwritten, unless specifically changed within the Mod Manager, such as enabling/disabling tweaks.

### Credits
- bsab tool by [AlexxEG](https://github.com/AlexxEG/BSA_Browser)
- The cool people at [PCGW](https://pcgamingwiki.com/wiki/Fallout_76) for providing tweak commands.

### License and Copyright
[Fallout Mod Manager](https://sourceforge.net/projects/fomm/) is licensed under GPLv3.

All rights on source code and libraries belong to their respective owners.
