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
