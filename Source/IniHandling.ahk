;Mod manager
  LoadModManagerIni(Name)
  {
    IniRead,LoadedValue,ModManagerPrefs.ini,Settings,%Name%
    if LoadedValue != ERROR
      return % LoadedValue
    else
      return
  }

  EditModManagerIni(Value,Name,Section:="Settings")
    {
      IniWrite,%Value%,ModManagerPrefs.ini,%Section%,%Name%
      return
    }

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

  ;GetGameExePath()
  ;  {
  ;    return GetGameRootPath() . "\Fallout76.exe"
  ;  }

  GetGameRootPath()
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
        return GameExePath
      }

;Fallout76Custom.ini
  EditCustomIni(Value,Name,Section)
    {
      global Fallout76CustomIni
      MakeSureFolderExistsInMyDocs()
      IniWrite,%Value%,%Fallout76CustomIni%,%Section%,%Name%
      return
    }

  DeleteFromCustomIni(Name,Section)
    {
      global Fallout76CustomIni
      IniDelete,%Fallout76CustomIni%,%Section%,%Name%
      IniRead,SectionContents,%Fallout76CustomIni%,%Section%
      if SectionContents =
        IniDelete,%Fallout76CustomIni%,%Section%
      return
    }




;Fallout76.ini
  EditPrefsIni(Value,Name,Section)
    {
      global Fallout76PrefsIni
      MakeSureFolderExistsInMyDocs()
      IniWrite,%Value%,%Fallout76PrefsIni%,%Section%,%Name%
      return
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

;GUI
  DefaultGUICheckedStatus(IniFile,Section,Key,DefaultState)
    {
      Iniread,Query,%IniFile%,%Section%,%Key%
      if DefaultState = 1
      {
        if (Query = 1 or Query = "ERROR")
          return "Checked" ;Needs to be literal string for AHK Language to be either blank or checked.
        else return
      }
      else
      {
        if (Query = 0 or Query = "ERROR")
          return
        else return "Checked"
      }
    }

  MakeSureFolderExistsInMyDocs()
  {
    global Fallout76CustomIni
    IfNotExist,Fallout76CustomIni
    FileCreateDir,% SubStr(Fallout76CustomIni,1,-20)
    return
  }

  DeleteFromModManagerIni(Section,Key)
  {
    IniDelete,ModManagerPrefs.ini,%Section%,%Key%
  }
