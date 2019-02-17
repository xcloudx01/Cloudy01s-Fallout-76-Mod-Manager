# Changelog (newest to oldest):

  ## 1.152:
  - Bug fixes. (Mods wouldn't install if your username in Windows had a space in it)

  ## 1.15:
  -  Added a button to launch the game from the mod manager.
  -  Added mod uninstall feature. Right-click a mod and click Uninstall to remove it. It will be sent to the recycle bin and removed from Fallout76Custom.ini
  -  Fixed zipped mods that contained a "Data" folder not installing/compiling properly (Hairspray mod)
  -  Removed being able to set a custom Fallout76Custom.ini path - It seemed a bit redundant since the game checks in My Documents
  -  A few clarification changes and minor bug fixes.

  ## 1.143:
  -  Fixed bug where the tweak settings weren't being loaded properly between launches.

  ## 1.141:
  - Added ability to install new mods using the mod manager. .ba2, zipped .ba2, and zipped loose-file mods are supported.
  -  Added a mod compiler. Attempting to install a zipped loose-file mod will ask if you want to compile it. Mod creators can also just use the "Compile a mod" button to convert a loose-file mod to .ba2 format.
  -  Added help info when you mouse over the tweaks.

  ## 1.13:
  - Stopped mods from going to sResourceIndexFileList. Now it will either pick from sResourceStartUpArchiveList, or sResourceArchive2List (This fixes bag.ba2 and bagglow.ba2).
  - Added tweak for fixing Y mouse sensitivity automatically. It will auto-detect your current desktop aspect-ratio and select an appropriate sensitivity value, then save it to the ini file.
