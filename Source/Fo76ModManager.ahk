;;;;;;;;;;;;;;;;;;;;;;
;Pre-run
;;;;;;;;;;;;;;;;;;;;;;
  ;Temp files
    ifnotexist,%A_Temp%\FO76ModMan.temp
      filecreatedir,%A_Temp%\FO76ModMan.temp
    FileInstall, bsab.exe, %A_Temp%\FO76ModMan.temp\bsab.exe,1

  ;System vars
    #NoEnv
    #SingleInstance Force
    #NoTrayIcon
    VersionNumber = 1.2
    AppName = Cloudy01's Fallout 76 Mod Manager Ver %VersionNumber%
    debug("Program not working correctly? Copy-paste this into a comment or forum post on https://www.nexusmods.com/fallout76/mods/221 to aid in debugging.`n`nOutput log file:`nVersion: " . VersionNumber) ;Should format the top of the log file to aid users.
    Fallout76PrefsIni = %A_MyDocuments%\My Games\Fallout 76\Fallout76Prefs.ini

  ;Includes
    #include InstallMods.ahk
    #Include IniHandling.ahk

  ;Help info that appears in multiple places.
    ;IniFileHelp = This typically is in your my documents folder\My Games\Fallout 76`n`nEg: C:\Users\USERNAME\Documents\My Games\Fallout 76`n`nIf you don't have a Fallout76Custom.ini file, then copy Fallout76.ini and rename it to Fallout76Custom.ini, and then use Notepad to make the file empty.
    ModFolderHelp = This should be the data folder in Fallout76`n`nEg: C:\Program Files (x86)\Bethesda.net Launcher\Games\Fallout76\Data

  ;Check for the settings file, do a first time setup if not found (We need to know what folder the mods are in so we can populate the GUI with them.)
    ifnotexist,ModManagerPrefs.ini
    {
      debug("ModManagerPrefs.ini wasn't found.")
      ModsFolder := GetFileFromPossibleLocations(["Program Files","Program Files (x86)","Games"],"Bethesda.net Launcher\Games\Fallout76\Data")
      if !(ModsFolder) ;Auto-detect wasn't able to successfully find the right folder. Ask user to do it manually.
      {
        debug("Couldn't auto-detect where the mods folder is.")
        msgbox,,Welcome!,Welcome to the mod manager. In order to use it, please select the folder where your mods are installed.`n`n%ModFolderHelp%
        SetupSelectModFolder:
          FileSelectFolder,ModsFolder,,2
          IfNotExist,%ModsFolder%\*.ba2
          {
            debug("The user provided ModsFolder: " . ModsFolder . " But it didn't contain any .ba2 files")
            msgbox,5,Error!,The folder you selected does not contain any .ba2 mod files. Please try again by selecting the folder where mods are installed.`n`n%ModFolderHelp%
            ifMsgBox Retry
              goto,SetupSelectModFolder
            else
              Exitapp
          }
      }
      Fallout76CustomIni = %A_MyDocuments%\My Games\Fallout 76\Fallout76Custom.ini
      BethesdaLauncherExeFile := GetBethesdaLauncherLocation()
      gosub,SaveSettingsFile
    }
    else
      gosub,LoadSettingsFile

  ;Get the list of currently enabled mods. The GUI needs this to default mods to on/off
    Iniread,sResourceArchive2List,%Fallout76CustomIni%,Archive,sResourceArchive2List
    Iniread,sResourceStartUpArchiveList,%Fallout76CustomIni%,Archive,sResourceStartUpArchiveList
    Iniread,sResourceIndexFileList,%Fallout76CustomIni%,Archive,sResourceIndexFileList

  ;Handle scrolling the UI
    OnMessage(0x115, "OnScroll") ; WM_VSCROLL
    OnMessage(0x114, "OnScroll") ; WM_HSCROLL
    Gui, +Resize +0x300000 ; WS_VSCROLL | WS_HSCROLL

    ;Install Archive2 (We need it to compile mods.)
      ModCompilerDir = %A_Temp%\FO76ModMan.temp\ModCompiler
      ifnotexist,%ModCompilerDir%
        filecreatedir,%ModCompilerDir%
      Ifnotexist,%ModCompilerDir%\Archive2.exe
        Fileinstall,Archive2\Archive2.exe,%ModCompilerDir%\Archive2.exe
      IfNotExist,%ModCompilerDir%\Archive2Interop.dll
        Fileinstall,Archive2\Archive2Interop.dll,%ModCompilerDir%\Archive2Interop.dll
      IfNotExist,%ModCompilerDir%\Microsoft.WindowsAPICodePack.dll
        Fileinstall,Archive2\Microsoft.WindowsAPICodePack.dll,%ModCompilerDir%\Microsoft.WindowsAPICodePack.dll
      IfNotExist,%ModCompilerDir%\Microsoft.WindowsAPICodePack.Shell.dll
        Fileinstall,Archive2\Microsoft.WindowsAPICodePack.Shell.dll,%ModCompilerDir%\Microsoft.WindowsAPICodePack.Shell.dll

;;;;;;;;;;;;;
;GUI
;;;;;;;;;;;;;
  CreateGUI:
    debug("Making GUI..")
    DesiredGUIHeight = 205 ;Default height if zero mods are found. Height is added later on on a per mod found basis.

    ;We should find which settings need to be pre-filled on the GUI if they have saved settings for these already defined.
      IntroCheckbox := DefaultGUICheckedStatus(Fallout76CustomIni,"General","sIntroSequence",1) ;These need to be either blank or "Checked" in AHK Language so the GUI can create them accordingly.
      DOFCheckbox := DefaultGUICheckedStatus(Fallout76CustomIni,"ImageSpace","bDynamicDepthOfField",1)
      MotionBlurCheckbox := DefaultGUICheckedStatus(Fallout76CustomIni,"ImageSpace","bMBEnable",1)
      VSyncCheckbox := DefaultGUICheckedStatus(Fallout76PrefsIni,"Display","iPresentInterval",1)
      GrassCheckbox := DefaultGUICheckedStatus(Fallout76CustomIni,"Grass","bAllowCreateGrass",1)
      MouseSensitivityTweakCheckbox := DefaultGUICheckedStatus(Fallout76CustomIni,"Controls","fMouseHeadingYScale",0)
      MouseAccelCheckbox := DefaultGUICheckedStatus(Fallout76CustomIni,"Controls","bMouseAcceleration",1)

    Gui, Add, Text, x22 y15 w150 h20 , Fallout76 Data Folder:
    Gui, Add, Edit, x135 y9 w340 h20 vModsFolder ReadOnly,%ModsFolder% ;Has to be read-only otherwise the user could type in a value and not save it, then the script assumes it hasn't been changed. Just helps avoid user confusion
    Gui, Add, Button, x478 y9 w30 h20 gSelectModFolderButton, ..
    ;Gui, Add, Text, x22 y37 w150 h20 , Fallout76Custom.ini:
    ;Gui, Add, Edit, x122 y30 w330 h20 vFallout76CustomIni,%Fallout76CustomIni%
    gui,font,Bold
    Gui, Add, Text, x20 y34 w450 h20 vStatusText
    gui,font,
    ;Gui, Add, Button, x455 y30 w30 h20 gSelectIniFileButton, .. ;Define ini file button
    Gui, Add, Text, w1 h1 x340 y55,
    Gui, Add, Button,gInstallModButton, Install a mod
    Gui, Add, Button,gSaveCustomIniButton, Save Settings
    Gui, Add, Button,gLaunchGameButton, Launch Fallout 76!
    Gui, Add, Text, w1 h1, ;vertical padding
    Gui, Add, Text, w150 h20, Graphics Tweaks:
    Gui, Add, CheckBox, w100 h15 vIntroVideosStatus %IntroCheckbox%, Intro videos
    Gui, Add, CheckBox, w150 h15 vMotionBlurStatus %MotionblurCheckbox%, Motion blur effects
    Gui, Add, CheckBox, w150 h15 vDOFStatus %DOFCheckbox%, Depth of field effects
    Gui, Add, CheckBox, w150 h15 vVsyncStatus %VSyncCheckbox%, Capped FPS (Vsync)
    Gui, Add, CheckBox, w150 h15 vGrassStatus %GrassCheckbox%, Grass
    Gui, Add, Text, w1 h1, ;vertical padding
    Gui, Add, Text, w150 h20, Control Tweaks:
    Gui, Add, CheckBox, w150 h15 vMouseSensitivityTweakStatus %MouseSensitivityTweakCheckbox%, Fix mouse Y sensitivity
    Gui, Add, CheckBox, w150 h15 vMouseAccelStatus %MouseAccelCheckbox%, Mouse Acceleration
    Gui, Add, Text, w1 h1, ;vertical padding
    Gui, Add, Text, w120 h20, Developer Tools:
    Gui, Add, Button,gCompileModButton, Compile a mod
    Gui, Add, Button,gOutputDebugButton, Output debug log
    Gui, Add, Text,
    Gui, Add, Picture, gDonateButton, Donate.png
    Gui, Add, CheckBox, x65 y55 gToggleAllMods vToggleAllModsCheckbox, Check/Uncheck all mods.
    Gui, Add, Text, x22 y55 w30 h20, Mods:

    ;Look for mods and add them to the GUI
      CurrentModNumber = 0 ;Used to create an array of mods with the corresponding values. eg: Mod2 = glow.ba2 (This is used so when writing the fallout65custom.ini we know which mods are enabled.)
      Loop Files, %ModsFolder%\*.ba2 ;Look at all the potential mod files
      {
        ifinstring,A_LoopFileName,SeventySix - ;Skip default game files. Only interested in mods.
          continue
        ifinstring,A_LoopFileName,MM_ ;Skip Mod Manager files
            continue
        CurrentModNumber ++
        ModName%CurrentModNumber% := A_LoopFileName ;Add this mod and its value to the mod array. Eg Mod2 = glow.ba2
        UIFriendlyName := StrSplit(A_LoopFileName,".ba2")
        if ModAlreadyEnabled(A_LoopFileName) ;Default the checkboxes to on/off depending on if they're already enabled in the ini file.
        {
          Gui, Add, CheckBox, w250 h15 vModStatus%CurrentModNumber% Checked, % UIFriendlyName[1]
          ModStatus%CurrentModNumber% = 1 ;Without these I can't fetch the value without using a gui,submit in the AllModsAreEnabled() Function.
        }
        else
        {
          Gui, Add, CheckBox, w250 h15 vModStatus%CurrentModNumber%, % UIFriendlyName[1]
          ModStatus%CurrentModNumber% = 0
        }
        DesiredGUIHeight := DesiredGUIHeight + 17 ;Expand the GUI to fit the current mod in it.
      }
      TotalNumberOfMods := CurrentModNumber ;Used by the save button to determine loop count when saving each mod.
      if TotalNumberOfMods = 0
      {
        if (AutoDetectedModsFolder)
          msgbox,,Error!,The mods folder was auto-detected, but didn't seem to contain any mods.`nPlease make sure the mods folder is correct in the mod manager.
        else if !(FileExist(ModsFolder . "\SeventySix - Textures01.ba2")) ;Need to check if the folder actually contains mods.
          msgbox,,Error!,No mods were found! Did you pick the correct folder that holds the .ba2 files?`n%ModFolderHelp%
      }

      ;Check/Unchecking functionality
      If !AllModsAreEnabled()
        ShouldTickAllMods = 1 ;Makes clicking the "CHeck/Uncheck all mods" button default to checking all when it's first clicked and gets checked. Saves me having to use a gui,submit to read the checked value.
      Else
      {
        GuiControl,,ToggleAllModsCheckbox,1
        ShouldTickAllMods = 0
      }


    ;Show the GUI
      if (DesiredGUIHeight / A_ScreenHeight * 100) >= 75 ;Cap the height from going too tall and off the monitor. Capped it at 75%
        DesiredGUIHeight := 0.5 * A_ScreenHeight
      if  DesiredGUIHeight <= 475 ;User has little/no mods. So we should at least make the GUI a decent size to show all the buttons.
        DesiredGUIHeight = 475
      Gui, Show, H%DesiredGUIHeight% W510,%AppName%

    ;Mouse-over tooltip functionality
      Gui, +LastFound
      GroupAdd, MyGui, % "ahk_id " . WinExist()
      OnMessage(0x200, "HoverOverElementHelp")
  return


;;;;;;;;;;;;;;;;
;Subroutines
;;;;;;;;;;;;;;;;

  ;GUI
    GuiSize:
      UpdateScrollBars(A_Gui, A_GuiWidth * 1.5, A_GuiHeight)
      return

    GuiClose:
      ExitApp

    RemoveStatusText: ;Used by ShowStatusText(), so we don't have to sleep and bog down the main thread to remove text when done waiting X seconds.
      SetTimer, RemoveStatusText, Off
      guicontrol,,StatusText,
      return

    ReScanForMods:
      debug("ReScanForMods sub-routine starting")
      gui,destroy
      gosub,CreateGUI
      return

    GuiContextMenu: ;What gets called when you right-click on the GUI. Can't change the function name because of how AutoHotKey works
      if instr(A_GuiControl,"ModStatus")
      {
        RightClickID := StrReplace(A_GuiControl,"ModStatus")
        RightClickID := ModName%RightClickID% ;Need to fetch contents from Modname5 or similiar variable.
        ;Reset the menu to be blank
          Menu, MyMenu, Add, Uninstall, RightClickMenu_ClickedButton ;FFF AHK doesn't have an if check for menus, so gotta just make something exist first then delete it to make sure the menu is empty.
          Menu, MyMenu, DeleteAll
        Menu, MyMenu, Add, Uninstall %RightClickID%, RightClickMenu_ClickedButton
        Menu, MyMenu, Show,  %A_GuiX%, %A_GuiY%
      }
      return

      RightClickMenu_ClickedButton:
        UninstallModName := strreplace(A_ThisMenuItem,"Uninstall ")
        gui,hide ;Without this the user can accidentally invoke the tooltips that hover over the msgbox and get in the way.
        MsgBox,4,Warning,The following mod will be uninstalled and sent to the recycle bin:`n%UninstallModName%`n`nAre you sure?
        ifmsgbox yes
        {
          debug("Uninstalling the mod: " . UninstallModName)
          filerecycle,% ModsFolder . "\" . strreplace(A_ThisMenuItem,"Uninstall ")
          if ModAlreadyEnabled(UninstallModName)
          {
            MsgBox, 4,, For the changes to be applied ingame, the mods will need to be re-combined.`n`nWould you like to do this now?`n`n`n* Note: If you're trying to uninstall multiple mods at once, disable them first in the mod manager then click "Save Settings" to avoid this warning message.
            IfMsgBox Yes
            {
              Gui,Show
              DeleteFromModManagerIni("Mod Enabled",UninstallModName)
              gosub SaveCustomIniButton
            }
          }
          gosub,SaveTweaksToCustomIni
          goto,ReScanForMods
        }
        gui,show
        return

      ToggleAllMods:
        Loop % TotalNumberOfMods
        If !(ShouldTickAllMods)
          GuiControl,,ModStatus%A_Index%,0
        Else
          GuiControl,,ModStatus%A_Index%,1
        Toggle(ShouldTickAllMods)
        return

  ;INI Files
    SaveSettingsFile:
      if (BethesdaLauncherExeFile) ;Only should save values that exist. BethesdaLauncherExeFile can be false if the function GetBethesdaLauncherLocation() didn't find where the exe is.
        EditModManagerIni(BethesdaLauncherExeFile,"BethesdaLauncherExeFile")
      if (ModsFolder)
        EditModManagerIni(ModsFolder,"ModsFolder")
      if (Fallout76CustomIni)
        EditModManagerIni(Fallout76CustomIni,"Fallout76CustomIni")
    return

    LoadSettingsFile:
      debug("LoadSettingsFile sub-routine starting")
      ifexist,ModManagerPrefs.ini
      {
        ModsFolder := LoadModManagerIni("ModsFolder")
        Fallout76CustomIni := LoadModManagerIni("Fallout76CustomIni")
        BethesdaLauncherExeFile := LoadModManagerIni("BethesdaLauncherExeFile") ;If it's not found, it'll just be blank. So we can use "if BethesdaLauncherExeFile = false" statements if we want.
      }
    return

    SaveTweaksToCustomIni: ;This is two seperate functions so when deleting a mod we can just save the currently checked tweaks without having to re-scan for mod changes.
      debug("SaveTweaksToCustomIni sub-routine starting")
      gui,submit,NoHide
      SavedChanges = 1 ;So the Launch button knows it shouldn't nag the user anymore about clicking save.

      ;Goodies
        if IntroVideosStatus = 0
        {
          EditCustomIni(IntroVideosStatus,"sIntroSequence","General")
          EditCustomIni(IntroVideosStatus,"uMainMenuDelayBeforeAllowSkip","General")
        }
        else
        {
          DeleteFromCustomIni("sIntroSequence","General")
          DeleteFromCustomIni("uMainMenuDelayBeforeAllowSkip","General")
        }
        if MotionBlurStatus = 0
          EditCustomIni(MotionBlurStatus,"bMBEnable","ImageSpace")
        else
          DeleteFromCustomIni("bMBEnable","ImageSpace")
        if DOFStatus = 0
        {
          EditCustomIni(DOFStatus,"bDynamicDepthOfField","ImageSpace")
          EditCustomIni(0,"fDOFBlendRatio","Display")
          EditCustomIni(999999,"fDOFMinFocalCoefDist","Display")
          EditCustomIni(99999999,"fDOFMaxFocalCoefDist","Display")
          EditCustomIni(99999999,"fDOFDynamicFarRang","Display")
          EditCustomIni(0,"fDOFCenterWeightInt","Display")
          EditCustomIni(99999999,"fDOFFarDistance","Display")
        }
        else
        {
          DeleteFromCustomIni("bDynamicDepthOfField","ImageSpace")
          DeleteFromCustomIni("fDOFBlendRatio","Display")
          DeleteFromCustomIni("fDOFMinFocalCoefDist","Display")
          DeleteFromCustomIni("fDOFMaxFocalCoefDist","Display")
          DeleteFromCustomIni("fDOFDynamicFarRang","Display")
          DeleteFromCustomIni("fDOFCenterWeightInt","Display")
          DeleteFromCustomIni("fDOFFarDistance","Display")
        }
        if VSyncStatus = 1
          EditPrefsIni(1,"iPresentInterval","Display")
        else
          EditPrefsIni(0,"iPresentInterval","Display")
        if GrassStatus = 0
        {
          EditCustomIni(0,"bAllowCreateGrass","Grass")
          ;EditCustomIni(1,"iMinGrassSize","Grass") ; - BorderXer said this isn't needed?
        }
        else
        {
          DeleteFromCustomIni("bAllowCreateGrass","Grass")
          ;DeleteFromCustomIni("iMinGrassSize","Grass")
        }

      ;Mouse
        if MouseSensitivityTweakStatus = 1
        {
          EditCustomIni(0.021,"fMouseHeadingXScale","Controls")
          EditCustomIni(GetMouseYRatio(),"fMouseHeadingYScale","Controls")
        }
        else
        {
          DeleteFromCustomIni("fMouseHeadingXScale","Controls")
          DeleteFromCustomIni("fMouseHeadingYScale","Controls")
        }
        if MouseAccelStatus = 0
        {
          EditCustomIni(0,"bMouseAcceleration","Controls")
        }
        else
          DeleteFromCustomIni("bMouseAcceleration","Controls")
      return

    SaveModListToCustomIni:
        gui,submit,NoHide
        debug("SaveModListToCustomIni subroutine running.")

        ;Files we'll need to use tomerge mods into each .ba2 file, so the fallout76custom.ini has as little characters as possible.
          StartupArchiveFileList := A_Temp . "\FO76ModMan.temp\StartupArchiveFileList.txt"
          Archive2FileList := A_Temp . "\FO76ModMan.temp\Archive2FileList.txt"
          Archive2TexturesList := A_Temp . "\FO76ModMan.temp\Archive2TextureFileList.txt"
          FileDelete, %StartupArchiveFileList%
          FileDelete, %Archive2FileList%
          FileDelete, %Archive2TexturesList%

        TotalNumberOfActiveMods := 0
        loop %TotalNumberOfMods%
        {
          if ModStatus%A_Index% = 1
            TotalNumberOfActiveMods ++
        }

        loop %TotalNumberOfMods%
        {
          EditModManagerIni(ModStatus%A_Index%,ModName%A_Index%,"Mod Enabled")
          if ModStatus%A_Index% = 1
          {
            ModExtractionPath := A_Temp . "\FO76ModMan.temp\Mods\" . ModName%A_Index% . "\Data"
            ifNotExist,%ModExtractionPath%
            {
              ShowStatusText("Extracting " . TotalNumberOfActiveMods . " mods.. Please wait.",30000)
              ExtractMod(ModName%A_Index%,ModExtractionPath)
              Debug("Extracting " . ModName%A_Index% . " to " . ModExtractionPath)
            }

              loop, Files, %ModExtractionPath%\*.*,R
              {
                If A_LoopFileExt = txt
                  continue
                If Instr(A_LoopFileFullPath,"Textures")
                  FileAppend,%A_LoopFileFullPath%`n, %Archive2TexturesList%
                else If InStr(A_LoopFileFullPath,"Strings")
                  FileAppend,%A_LoopFileFullPath%`n, %StartupArchiveFileList%
                else
                  FileAppend,%A_LoopFileFullPath%`n, %Archive2FileList%
              }
            CurrentEnabledModNumber ++
          }
        }

        FileDelete,%ModsFolder%\MM_Arc2.ba2
        FileDelete,%ModsFolder%\MM_StUp.ba2
        FileDelete,%ModsFolder%\MM_Tex.ba2
        IfExist, %Archive2FileList%
        {
          ShowStatusText("Combining Archive2 mods together... Please wait.",6000)
          Debug("Combining Archive2 mods together.")
          CombineMods(Archive2FileList,"MM_Arc2.ba2")
        }
        IfExist, %StartupArchiveFileList%
        {
          ShowStatusText("Combining Startup mods together... Please wait.",6000)
          Debug("Combining Startup mods together.")
          CombineMods(StartupArchiveFileList,"MM_StUp.ba2")
        }
        IfExist, %Archive2TexturesList%
        {
          ShowStatusText("Combining Texture mods together... Please wait.",6000)
          Debug("Combining Texture mods together.")
          CombineMods(Archive2TexturesList,"MM_Tex.ba2","DDS")
        }

        EditCustomIni("MM_StUp.ba2","sResourceStartUpArchiveList","Archive")
        EditCustomIni("MM_Arc2.ba2,MM_Tex.ba2","sResourceArchive2List","Archive")

      ShowStatusText("Successfully saved. You may now start Fallout 76.",6000)
    return



;;;;;;;;;;;;;;;;;
;GUI Buttons
;;;;;;;;;;;;;;;;;

  DonateButton:
  run, https://www.ko-fi.com/xcloudx01
  return

  LaunchGameButton:
    if !(SavedChanges)
    {
      msgbox,3,Notice,No changes were saved.`n`nWould you like to save your settings before launching the game?
      ifmsgbox yes
        gosub,SaveCustomIniButton
      else ifmsgbox cancel
        return
    }
    ifnotexist,%BethesdaLauncherExeFile%
    {
      debug("LaunchGameButton - Attempting detection of BethesdaLauncher exe")
      BethesdaLauncherExeFile := GetBethesdaLauncherLocation() ;This is only auto-detected if the settings file didn't exist at all. So for people using an older version of the manager, they need this re-checked.
      ifnotexist,%BethesdaLauncherExeFile%
      {
        debug("LaunchGameButton - Wasn't able to auto-detect launcher location")
        msgbox,,Setup,Please select your BethesdaNetLauncher.exe file. This should typically be in a folder such as:`nC:\Program Files (x86)\Bethesda.net Launcher\
        FileSelectFile,BethesdaLauncherExeFile,3,,Please select your BethesdaNetLauncher.exe file,BethesdaNetLauncher.exe
        ifexist,%BethesdaLauncherExeFile%
          EditModManagerIni(BethesdaLauncherExeFile,"BethesdaLauncherExe")
      }
    }
    ifnotexist,%BethesdaLauncherExeFile%
    {
      debug("LaunchGameButton - ERROR The launcher doesn't exist in: " . BethesdaLauncherExeFile)
      msgbox,,Error!,Something went wrong trying to launch the game.`nThe BethesdaNetLauncher.exe file could not be found? Attempted to load it from:`n`n%BethesdaLauncherExeFile%
    }
    else
    {
      debug("LaunchGameButton - Launching " . BethesdaLauncherExeFile)
      run,%BethesdaLauncherExeFile% bethesdanet://run/20
    }
    Process, Exist, BethesdaNetLauncher.exe
      Winactivate, ahk_pid %ErrorLevel%

    ;GUI Stuff
      errorlevel = 0
      while (errorlevel = 0) and (A_Index < 10)
      {
        ShowStatusText("Launching game",1000)
        sleep,500
        ShowStatusText("Launching game.",1000)
        sleep,500
        ShowStatusText("Launching game..",1000)
        sleep,500
        ShowStatusText("Launching game...",1000)
        sleep,500
        process,exist,Fallout76.exe
      }
      if (errorlevel = 0)
      {
        debug("LaunchGameButton - The game didn't appear to launch in a reasonable time.")
        ShowStatusText("Game did not start in a reasonable time. Check the Bethesda Launcher.",15000)
      }
      else
        debug("LaunchGameButton - The game launched successfully.")
      return

  SaveCustomIniButton:
    gosub,SaveTweaksToCustomIni ;This is two seperate functions so when deleting a mod we can just save the currently checked tweaks.
    gosub,SaveModListToCustomIni
    return

  ;Mod Management
    InstallModButton:
      debug("InstallModButton sub-routine starting.")
      FileSelectFile,SelectedFilesToInstall,M3,,Please select a .ba2 mod file`,or a zipped mod containing either a .ba2 file or a loose-files mod.,Mods (*.ba2;*.zip;*.7z;*.rar)
      if (SelectedFilesToInstall)
      {
        SelectedModsArray := strsplit(SelectedFilesToInstall,"`n")
        loop % SelectedModsArray.length()
        if A_Index = 1
          continue
        else
        {
          FileToInstall := SelectedModsArray[1] . "\" . SelectedModsArray[A_Index]
          NewlyInstalledMod := InstallMod(FileToInstall)
          if (NewlyInstalledMod) ;A mod succeeded so the GUI needs to be updated to reflect the change.
            ShouldUpdateGUI = 1
        }
        if ShouldUpdateGUI ;GUI needs to be updated to show the new mod if it was installed successfully.
        {
          gosub,ReScanForMods
          guicontrol,,StatusText,Successfully installed: %NewlyInstalledMod%
        }
      }
      return

    CompileModButton:
      msgbox,,Help Info,Please select the ROOT folder that contains all the mod's files and folders.
      fileselectfolder,SelectedModToCompileFolder,1,,Please select the ROOT folder that contains all the mods files and folders.
      if (SelectedModToCompileFolder)
      {
        InputBox, ChosenModName, Mod Name,Please enter a name to call this mod.`n`nYour mod will be saved to the following folder:`n%ModsFolder%, , 450, 200
        if (ChosenModName)
        {
          ifexist,%ModsFolder%\%ChosenModName%.ba2
          {
            msgbox,4,Conflicting Mod,A mod called "%ChosenModName%" already exists. Did you want to overwrite it?
            ifmsgbox yes
              CompileMod(SelectedModToCompileFolder,ChosenModName) ;No need to re-create the GUI because there won't be anything new to add to it..
          }
          else
          {
            CompileMod(SelectedModToCompileFolder,ChosenModName)
            gosub,ReScanForMods
          }
        }
      }
      return

    SelectModFolderButton:
      debug("SelectModFolderButton sub-routine starting")
      FileSelectFolder,NewModsFolder,,2
      if NewModsFolder !=
      {
        ModsFolder := NewModsFolder
        GuiControl,,ModsFolder,%ModsFolder%
        gosub,SaveSettingsFile
        gosub,ReScanForMods ;We need to re-scan for mods because the user defined a new mod folder.
      }
      return

  OutputDebugButton:
    FileDelete,%A_Temp%\FO76ModMan.temp\DebugOutput.txt
    ifexist,%Fallout76CustomIni%
      fileread,DebugTextFallout76Custom,%Fallout76CustomIni%
    FileAppend,%DebugText% `n`nFallout76Custom:`n%DebugTextFallout76Custom%,%A_Temp%\FO76ModMan.temp\DebugOutput.txt
    run,%A_Temp%\FO76ModMan.temp\DebugOutput.txt
    return

  return




;;;;;;;;;;;;;;;;;;;;;
;Functions
;;;;;;;;;;;;;;;;;;;;;
CombineMods(FileList,FileName,Format:="")
{
  if (Format)
    Format := " -format=" . Format
  global ModsFolder
  HiddenCommandPrompt("""" A_Temp . "\FO76ModMan.temp\ModCompiler\Archive2.exe"" -s=""" . FileList . """" . Format . " -c=""" . ModsFolder . "\" . FileName)
}

HiddenCommandPrompt(cmd)
{
  runwait,%cmd%,,Hide
}

  GetFallout76Ini()
    {
    global ModsFolder
    Debug("Attempting to find Fallout76.ini in game folder.")
    If !(ModsFolder)
    {
      Debug("ModsFolder was not defined.")
      return
    }
    FO76IniFile := SubStr(ModsFolder,1,-5) . "\Fallout76.ini"
    IfNotExist,%FO76IniFile%
    {
      Debug("Couldn't find the ini file, tried looking here:" . FO76IniFile)
      msgbox, Fallout76.ini was not found in your Fallout76 folder. You may encounter glitches as a result.`n`n Please use the Bethesda Launcher to verify your game files, then re-launch this mod manager.
      return
    }
    Debug("The default Fallout76ini file was found: " . FO76IniFile)
    return % FO76IniFile
    }

;Game exe functions
  GetBethesdaLauncherLocation()
    {
      global ModsFolder
      LauncherExeFile := "BethesdaNetLauncher.exe"
      if (ModsFolder) ;Launcher is likely 2-steps above the data folder. So we should check there.
      {
        ModsFolderArray := strsplit(ModsFolder,"\")
        Loop % ModsFolderArray.length() - 3 ;Want the root folder to check for bethesda launcher
        {
          if A_Index = 1
            GameParentFolder := ModsFolderArray[A_Index]
          else
            GameParentFolder := GameParentFolder . "\" . ModsFolderArray[A_Index]
        }
      }
      LauncherLocation := GetFileFromPossibleLocations([GameParentFolder,"Program Files (x86)\Bethesda.net Launcher","Program Files\Bethesda.net Launcher","Games\Bethesda.net Launcher"], LauncherExeFile)
      if !(LauncherLocation)
        return
      else
        return % LauncherLocation
    }

  GetGameExePath()
    {
      global ModsFolder
      ModsFolderArray := strsplit(ModsFolder,"\")
      loop % ModsFolderArray.Length() - 1
      {
        if A_Index = 1
          GameExePath := ModsFolderArray[A_Index]
        else
          GameExePath := GameExePath . "\" . ModsFolderArray[A_Index]
      }
      return GameExePath . "\Fallout76.exe"
    }

;GUI
  GuiDropFiles(GuiHwnd, FileArray, CtrlHwnd, X, Y)
    {
      for i, file in FileArray
        NewlyInstalledMod := InstallMod(file)
      if NewlyInstalledMod ;GUI needs to be updated to show the new mod if it was installed successfully.
      {
        gosub,ReScanForMods
        guicontrol,,StatusText,Successfully installed: %NewlyInstalledMod%
      }
    }

    AllModsAreEnabled()
    {
      Global
      Loop % TotalNumberOfMods
      {
        If ModStatus%A_Index% != 1
          return false
      }
      return true
    }

  HoverOverElementHelp(wParam, lParam, Msg)
    {
      MouseGetPos,,,, OutputVarControl
      ;Folders
        global ModFolderHelp
        IfEqual, OutputVarControl, Edit1
          Help := "This is where your mods are currently installed.`n`n" . ModFolderHelp
        ;else IfEqual, OutputVarControl, Edit2
        ;    Help := "This is where your Fallout76Custom.ini is stored. Typically in your 'My documents folder\My Games\Fallout 76'`n`nEg: C:\Users\USERNAME\Documents\My Games\Fallout 76`n`nIf you don't have a Fallout76Custom.ini file, when you click 'Save settings' we'll create one for you."

      ;Tweaks
        else IfEqual, OutputVarControl, Button3
          Help := "Mods are currently set to load in alphabetical/numerical order.`nIf this causes issues, rename the mod you want to have higher priority to have a 1 infront of it.`n`nEg: PerkLoadoutManager > 1PerkLoadoutManager`n`nThis will be made automatic in a future update, but for now this is a work-around."
        else IfEqual, OutputVarControl, Button5
        	Help := "Unchecking this will make the game start up instantly, without having to watch the Bethesda logo movie."
        else IfEqual, OutputVarControl, Button6
        	Help := "Unchecking this will disable any motion blur.`n`n(May improve FPS)"
        else IfEqual, OutputVarControl, Button7
        	Help := "Unchecking this disables all depth of field effects.`n`n(Will improve FPS)"
        else IfEqual, OutputVarControl, Button8
        	Help := "Unchecking this allows the FPS to run as high as possible.`n(Improves FPS on powerful machines. Improves input lag)`n`n*Leave this checked if you experience screen tearing"
        else IfEqual, OutputVarControl, Button9
          Help := "Unchecking this will remove the grass ingame.`n`n(Improves FPS, may improve visibility)"
        else IfEqual, OutputVarControl, Button10
        	Help := "The game reads up/down mouse movement at a different speed than left/right movement, which can throw off your aim.`nChecking this makes mouse movement consistent.`n`n*Your mouse movement may be increased too much whilst standing still, but works fine while you're moving."
        else IfEqual, OutputVarControl, Button11
        	Help := "The faster you move your mouse, the further your aim goes.`nPersonal preference if you like this on or off."
        else IfEqual, OutputVarControl, Static11
          DllCall("SetCursor","UInt",DllCall("LoadCursor","UInt",NULL,"Int",32649,"UInt")) ;Change to hand icon
      tooltip % Help
      ;tooltip % OutputVarControl ; Debug
    }

  ;GUI Scrolling
    #IfWinActive ahk_group MyGui
    WheelUp::
    WheelDown::
    +WheelUp::
    +WheelDown::
      ; SB_LINEDOWN=1, SB_LINEUP=0, WM_HSCROLL=0x114, WM_VSCROLL=0x115
      OnScroll(InStr(A_ThisHotkey,"Down") ? 1 : 0, 0, GetKeyState("Shift") ? 0x114 : 0x115, WinExist())
      return
    #IfWinActive

    UpdateScrollBars(GuiNum, GuiWidth, GuiHeight)
      {
        static SIF_RANGE=0x1, SIF_PAGE=0x2, SIF_DISABLENOSCROLL=0x8, SB_HORZ=0, SB_VERT=1

        Gui, %GuiNum%:Default
        Gui, +LastFound

        ; Calculate scrolling area.
        Left := Top := 9999
        Right := Bottom := 0
        WinGet, ControlList, ControlList
        Loop, Parse, ControlList, `n
        {
            GuiControlGet, c, Pos, %A_LoopField%
            if (cX < Left)
                Left := cX
            if (cY < Top)
                Top := cY
            if (cX + cW > Right)
                Right := cX + cW
            if (cY + cH > Bottom)
                Bottom := cY + cH
        }
        Left -= 8
        Top -= 8
        Right += 8
        Bottom += 8
        ScrollWidth := Right-Left
        ScrollHeight := Bottom-Top

        ; Initialize SCROLLINFO.
        VarSetCapacity(si, 28, 0)
        NumPut(28, si, 0, "uint") ; cbSize
        NumPut(SIF_RANGE | SIF_PAGE, si, 4, "uint") ; fMask

        ; Update horizontal scroll bar.
        NumPut(ScrollWidth, si, 12, "int") ; nMax
        NumPut(GuiWidth, si, 16, "uint") ; nPage
        DllCall("SetScrollInfo", "ptr", WinExist(), "int", SB_HORZ, "ptr", &si, "int", 1)

        ; Update vertical scroll bar.
         ;NumPut(SIF_RANGE | SIF_PAGE | SIF_DISABLENOSCROLL, si, 4, "uint") ; fMask
        NumPut(ScrollHeight, si, 12, "int") ; nMax
        NumPut(GuiHeight, si, 16, "uint") ; nPage
        DllCall("SetScrollInfo", "ptr", WinExist(), "int", SB_VERT, "ptr", &si, "int", 1)

        if (Left < 0 && Right < GuiWidth)
            x := Abs(Left) > GuiWidth-Right ? GuiWidth-Right : Abs(Left)
        if (Top < 0 && Bottom < GuiHeight)
            y := Abs(Top) > GuiHeight-Bottom ? GuiHeight-Bottom : Abs(Top)
        if (x || y)
            DllCall("ScrollWindow", "ptr", WinExist(), "int", x, "int", y, "ptr", 0, "ptr", 0)
      }

    OnScroll(wParam, lParam, msg, hwnd)
      {
        static SIF_ALL=0x17, SCROLL_STEP=10

        bar := msg=0x115 ; SB_HORZ=0, SB_VERT=1

        VarSetCapacity(si, 28, 0)
        NumPut(28, si, 0, "uint") ; cbSize
        NumPut(SIF_ALL, si, 4, "uint") ; fMask
        if !DllCall("GetScrollInfo", "ptr", hwnd, "int", bar, "ptr", &si)
            return

        VarSetCapacity(rect, 16)
        DllCall("GetClientRect", "ptr", hwnd, "ptr", &rect)

        new_pos := NumGet(si, 20, "int") ; nPos

        action := wParam & 0xFFFF
        if action = 0 ; SB_LINEUP
            new_pos -= SCROLL_STEP
        else if action = 1 ; SB_LINEDOWN
            new_pos += SCROLL_STEP
        else if action = 2 ; SB_PAGEUP
            new_pos -= NumGet(rect, 12, "int") - SCROLL_STEP
        else if action = 3 ; SB_PAGEDOWN
            new_pos += NumGet(rect, 12, "int") - SCROLL_STEP
        else if (action = 5 || action = 4) ; SB_THUMBTRACK || SB_THUMBPOSITION
            new_pos := wParam>>16
        else if action = 6 ; SB_TOP
            new_pos := NumGet(si, 8, "int") ; nMin
        else if action = 7 ; SB_BOTTOM
            new_pos := NumGet(si, 12, "int") ; nMax
        else
            return

        min := NumGet(si, 8, "int") ; nMin
        max := NumGet(si, 12, "int") - NumGet(si, 16, "uint") ; nMax-nPage
        new_pos := new_pos > max ? max : new_pos
        new_pos := new_pos < min ? min : new_pos

        old_pos := NumGet(si, 20, "int") ; nPos

        x := y := 0
        if bar = 0 ; SB_HORZ
            x := old_pos-new_pos
        else
            y := old_pos-new_pos
        ; Scroll contents of window and invalidate uncovered area.
        DllCall("ScrollWindow", "ptr", hwnd, "int", x, "int", y, "ptr", 0, "ptr", 0)

        ; Update scroll bar.
        NumPut(new_pos, si, 20, "int") ; nPos
        DllCall("SetScrollInfo", "ptr", hwnd, "int", bar, "ptr", &si, "int", 1)
      }

;Mod Management

  ExtractMod(TheMod,ModExtractionPath)
    {
    global ModsFolder
      ifnotexist,%ModExtractionPath%
        FileCreateDir,%ModExtractionPath%
      else
      {
        FileRecycle,%ModExtractionPath%
        FileCreateDir,%ModExtractionPath%
      }
      HiddenCommandPrompt("""" . A_Temp . "\FO76ModMan.temp\bsab.exe"" /e """ . ModsFolder . "\" . TheMod . """" . " """ . ModExtractionPath . """")
    return
    }

  fileHasContent(TheFile)
    {
      fileread,FileContents,%TheFile%
      if !(FileContents)
        return false
      else
        return true
    }

  HasBeenModified(TheMod)
    {
      global ModsFolder

      FileGetTime,CurrentModifiedDate,%ModsFolder%\%TheMod%
      Iniread,OldModifiedDate,%A_Temp%\FO76ModMan.temp\ModModifiedDateDatabase.ini,ModifiedDates,%TheMod%

      if CurrentModifiedDate = %OldModifiedDate%
        return false
      else
      {
        IniWrite,%CurrentModifiedDate%,%A_Temp%\FO76ModMan.temp\ModModifiedDateDatabase.ini,ModifiedDates,%TheMod%
        return true
      }
    }

  ModAlreadyEnabled(Query)
    {
      Iniread, Value,ModManagerPrefs.ini,Mod Enabled,%Query%
      return Value
    }

;Utility
  Debug(InputString)
    {
      global DebugText
      DebugText := DebugText . "`n" . InputString
      return
    }

    Toggle(ByRef Var)
    {
      var:=!var
    }

  GetFileFromPossibleLocations(PossibleLocationsArray,GoalFileOrPath)
    {
      ;Scan exact paths first. eg C:\Folder\SubFolder
        loop % PossibleLocationsArray.Length()
          if instr(PossibleLocationsArray[A_Index],":\")
          {
            FileFolderOfInterest := PossibleLocationsArray[A_Index] . "\" . GoalFileOrPath
            if FileExist(FileFolderOfInterest)
              return FileFolderOfInterest
          }

      ;Scan all drives
        DriveGet,DriveLetters,List
        DriveLettersArray := StrSplit(DriveLetters)
        loop % DriveLettersArray.Length()
        {
          CurrentDrive := DriveLettersArray[A_Index]
          loop % PossibleLocationsArray.Length()
          {
            if !PossibleLocationsArray[A_Index] ;This is needed because we can pass a variable into the array. But if that variable was blank, we can skip scanning it.
              continue
            FileFolderOfInterest := CurrentDrive . ":\" . PossibleLocationsArray[A_Index] . "\" . GoalFileOrPath
            if FileExist(FileFolderOfInterest)
              return FileFolderOfInterest
          }
        }
        return false
    }

  ShowStatusText(Text,Duration)
    {
      SetTimer, RemoveStatusText, %Duration%
      GuiControl,, StatusText, Status: %Text%
      return
    }

  ArrayContainsValue(haystack, needle) ; Thanks Blauhirn for this function
    {
      if(!isObject(haystack))
          return false
      if(haystack.Length()==0)
          return false
      for k,v in haystack
          if(v==needle)
              return true
      return false
    }

  GetMouseYRatio()
    {
      AspectRatio := Round(A_ScreenWidth / A_ScreenHeight,2)
      If AspectRatio = 1.78 ;16:9
        return 0.03738
      else if AspectRatio = 1.33 ;4:3
        return 0.028
      else if AspectRatio = 1.60 ;16:10
        return 0.0336
      else if AspectRatio = 2.39 ;21:9
        return 0.042
      else
        return Round(AspectRatio / 4.761904761904762,5) ;User is using some crazy resolution, try guessing the correct value. (Correct values are on PCGW. Eg: 1920x1080 / X = 0.3738. Find X by dividing the divisor by quotient)"
    }
