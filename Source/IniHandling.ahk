DeleteFromCustomIni(Name,Section)
{
  global Fallout76CustomIni
  IniDelete,%Fallout76CustomIni%,%Section%,%Name%
  IniRead,SectionContents,%Fallout76CustomIni%,%Section%
  if SectionContents =
    IniDelete,%Fallout76CustomIni%,%Section%
  return
}

EditCustomIni(Value,Name,Section)
{
  global Fallout76CustomIni
  IniWrite,%Value%,%Fallout76CustomIni%,%Section%,%Name%
  return
}

EditModManagerIni(Value,Name,Section)
{
 IniWrite,%Value%,ModManagerPrefs.ini,%Section%,%Name%
 return
}

EditPrefsIni(Value,Name,Section)
{
  global Fallout76PrefsIni
  IniWrite,%Value%,%Fallout76PrefsIni%,%Section%,%Name%
  return
}

DefaultCheckedStatus(IniFile,Section,Key,DefaultState)
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
