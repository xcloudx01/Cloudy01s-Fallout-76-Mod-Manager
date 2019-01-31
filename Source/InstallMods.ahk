InstallMod(ModFileFullPath)
{
  fileinstall,7zip\7z.exe,%A_Temp%\FO76ModMan.temp\7z.exe ;7zip is used for unzipping files.
  fileinstall,7zip\7z.dll,%A_Temp%\FO76ModMan.temp\7z.dll
  TempUnzippingFolder := A_Temp . "\FO76ModMan.temp\UnzippedMods"
  global ModsFolder

  if (SelectedFileSubtype(ModFileFullPath) = "zipped")
  {
    fileremovedir,%TempUnzippingFolder%,1 ;Dir needs to be empty so we can double-check anything actually got extracted.
    if (ZipFileContainsMod(ModFileFullPath) = "ERROR") ;7zip gives an error if it encounters a corrupted file. So need to take that into account.
    {
      msgbox,,Error!,7zip could not open the file:`n%ModFileFullPath%`nas an archive`, it may be corrupt.`n`nTry manually extracting it`, and then either use the "Install a mod" button if it's a .ba2 mod. Or use the "Compile a mod" button if it's a loose file mod.
      return false
    }
    if !(ZipFileContainsMod(ModFileFullPath))
    {
      msgbox,,Error!,The selected zip file does not contain any .ba2 or mod files. Please make sure you've selected one that does.`n`nYou selected the file:`n`n%ModFileFullPath%
      return false
    }
    else if (ZipFileContainsMod(ModFileFullPath) = "Loose")
    {
      UnzipFile(ModFileFullPath,TempUnzippingFolder,0)
      msgbox,4,Mod Compiler,The zip file:`n%ModFileFullPath%`nappears to be a loose-file mod. It must be compiled to .ba2 in order to be used.`nWould you like to attempt to compile it?
      ifmsgbox yes
      {
        InputBox, ChosenModName, Mod Name, Please enter a name to call this mod., , 250, 150
        if (ChosenModName)
        {
          ifexist,%ModsFolder%\%ChosenModName%.ba2
          {
            msgbox,4,Conflicting Mod,A mod called "%ChosenModName%" already exists. Did you want to overwrite it?
            ifmsgbox yes
              return % CompileMod(TempUnzippingFolder,ChosenModName)
            else
              return false
          }
          else
            return % CompileMod(TempUnzippingFolder,ChosenModName)
        }
      }
      else
        return false
    }
    else
    {
      TotalBa2InZip = 0
      UnzipFile(ModFileFullPath,TempUnzippingFolder,1)
      loop,files,%TempUnzippingFolder%\*.ba2
        TotalBa2InZip ++
      if TotalBa2InZip = 1
      {
        loop,files,%TempUnzippingFolder%\*.ba2
        {
          if A_Index = 1
            return % Installba2(A_LoopFileFullPath)
        }
      }
      else
        {
          loop,files,%TempUnzippingFolder%\*.ba2
          Installba2(A_LoopFileFullPath)
          return % "Multiple mods from zip file."
        }
    }
    ;fileremovedir,%TempUnzippingFolder%,1 ;May as well tidy up now that we're done with extracting.
  }
  else if instr(ModFileFullPath,".ba2") ;Don't need an if because the GUI can only pick from .ba2 and zip files.
    return % Installba2(ModFileFullPath)
  else
      msgbox,,Error!,Attempted to install a mod that is not a .ba2 file?`nThe mod that was specified to install was:`n%ModFileFullPath%`n`nMake sure you've selected the right file and try again.
    return false
}

SelectedFileSubtype(ModFileFullPath)
{
  ValidZipTypes := [".7z",".rar",".zip"]
  loop % ValidZipTypes.Length()
    if instr(ModFileFullPath,ValidZipTypes[A_Index])
      return "zipped"
  if instr(ModFileFullPath,".ba2")
    return "ba2"
  else
    return
}

;Zipped mods
  UnzipFile(ZipFileFullPath,DestinationFullPath,FilesToSingleFolder)
  {
    if !FileExist(ZipFileFullPath)
      msgbox,,Error!,The zip file specified was not found. Please double-check that you specified the correct one and try again.`n`nThe file specified was:`n%ZipFileFullPath%
    else
    {
      if (FilesToSingleFolder)
        ExtractionType = e
      else
        ExtractionType = x
      cmd := A_Temp . "\FO76ModMan.temp\7z.exe " . ExtractionType . " """ . ZipFileFullPath . """ -o""" . DestinationFullPath . """ -y"
      ShowStatusText("Unzipping file..",6000)
      runwait, %cmd%
      while,!FileExist(DestinationFullPath)
      {
        ShowStatusText("Double-checking zip extracted correctly..",500)
        sleep,500
        if A_Index >= 15
        msgbox,,Error!,Tried to unzip the following file:`n%ZipFileFullPath%`n`nTo:`n%DestinationFullPath%`n`nBut the extraction failed.`nTry un-zipping the file manually.
      }
    }
  }

  ZipFileContainsMod(FileFullPath)
  {
    ValidModTypes := ["meshes","strings","music","sound","textures","materials","interface","geoexporter","programs","vis","scripts","misc","shadersfx"] ;So we can check to make sure the user selected the right folder. These are all the default root locations the SeventySix*.ba2 files use.
    cmd := "cmd.exe /q /c " . A_Temp . "\FO76ModMan.temp\7z.exe l """ . FileFullPath . """"
    ListOfFiles := ComObjCreate("WScript.Shell").Exec(cmd).StdOut.ReadAll()
    if instr(ListofFiles,"Can not open file as archive")
      return "ERROR"
    if instr(ListOfFiles,.ba2)
      return true
    else
    {
      loop % ValidModTypes.Length()
      {
        if instr(ListOfFiles,ValidModTypes[A_Index])
          return "Loose"
      }
    }
      return false
  }

;ba2 mods
  InstallBa2(TheModFullPath)
  {
    global ModsFolder
    ModName := GetFileNameFromPath(TheModFullPath)
    ifexist,%TheModFullPath%
    {
      if instr(ModName,".ba2")
      {
        filemove,%TheModFullPath%,%ModsFolder%\%ModName%,1
        return % ModName ;So the GUI knows about the mod to show on the status text
      }
      else
        msgbox,,Error!,Attempted to install a mod that is not a .ba2 file?`nThe mod that was specified to install was:`n%TheModFullPath%`n`nMake sure you've selected the right file and try again.
    }
    else
      msgbox,,Error!,Attempted to install a mod, but the mod file was not found. Please double-check to make sure you've selected the right file.`nAttempted to install the following mod:`n`n%TheModFullPath%
  return false
  }

  GetFileNameFromPath(FileFullPath)
  {
    FileFullPathArray := StrSplit(FileFullPath,"\")
    return FileFullPathArray[FileFullPathArray.length()] ;The last entry in the array is the filename when split by \
  }


;Loose file mods
  CompileMod(LooseFilesFolder,ModName)
  {
    global ModsFolder
    ;Error handling
      ifnotexist,%LooseFilesFolder%
      {
        msgbox,,Error!,The Folder %LooseFilesFolder% does not appear to exist.`nPlease check and try again.
        return
      }
      ifnotexist,%ModsFolder%
      {
        if (ModsFolder = "")
          ModsFolder = <BLANK>
        msgbox,,Error!,The folder that contains mods does not appear to exist. Please go back and make sure that it is correct.`n`nThe folder that was specified was:`n%ModsFolder%`n`nThe correct location should be your Fallout76's Data folder.
        return
      }

    ValidModTypes := ["meshes","strings","music","sound","textures","materials","interface","geoexporter","programs","vis","scripts","misc","shadersfx"] ;So we can check to make sure the user selected the right folder. These are all the default root locations the SeventySix*.ba2 files use.
    ;Working folder setup (It's a bit tidier to have compiler stuff in its own folder)
      ModCompilerDir = %A_Temp%\FO76ModMan.temp\ModCompiler
      ifnotexist,%ModCompilerDir%
        filecreatedir,%ModCompilerDir%
    ;Install the Archive2 tool (We need to use this to compile mods)
      Fileinstall,Archive2\Archive2.exe,%ModCompilerDir%\Archive2.exe
      Fileinstall,Archive2\Archive2Interop.dll,%ModCompilerDir%\Archive2Interop.dll
      Fileinstall,Archive2\Microsoft.WindowsAPICodePack.dll,%ModCompilerDir%\Microsoft.WindowsAPICodePack.dll
      Fileinstall,Archive2\Microsoft.WindowsAPICodePack.Shell.dll,%ModCompilerDir%\Microsoft.WindowsAPICodePack.Shell.dll

    ;Make sure the folder is actually the root folder for a mod. Archive2 needs to know the root folder so it can scan subdirs for files.
      loop,% ValidModTypes.Length()
      {
        CurrentTestingValidMod := LooseFilesFolder . "\" . ValidModTypes[A_Index]
        ifnotexist,%CurrentTestingValidMod%
          continue
        else
        {
          IsValidModDir = 1
          break
        }
      }


      if !(IsValidModDir)
      {
        loop,% ValidModTypes.Length()
          ValidModTypesHelpText := ValidModTypesHelpText . "`n" . ValidModTypes[A_Index] ;Need to get a `n delimited list of valid folders to help guide the user to pick the right folder.
        msgbox,,Error!,The provided folder does not appear to be a mod? Please make sure you selected the root folder for the mod. `n(The folder that contains a sub-folder called one of the following:`n%ValidModTypesHelpText%
        return
      }

    ;Compile the mod and install it into the mod dir.
      filedelete, %ModCompilerDir%\ModFileList.txt
        ifexist,%ModsFolder%\%ModName%.ba2
          filerecycle,%ModsFolder%\%ModName%.ba2 ;Maybe it's an old version? recycle it instead of overwriting.
      ShowStatusText("Compiling mod..",6000)
      Loop, Files, %LooseFilesFolder%\*,R ;Archive2 needs a `n delimited list of mod files to turn into a .ba2 file.
      {
        if (A_LoopFileExt = "txt" or A_LoopFileExt = "bat") ;We only need mod files in the .ba2, no need to include misc junk.
          continue
        else
          fileappend,%A_LoopFileFullPath%`n,%ModCompilerDir%\ModFileList.txt

      }
      cmd := ModCompilerDir . "\Archive2.exe -s=""" . ModCompilerDir . "\ModFileList.txt"" -c=""" . ModsFolder . "\" . ModName . ".ba2"""
      runwait,%cmd%
      ifexist,%ModsFolder%\%ModName%.ba2
      {
        ShowStatusText(ModName . ".ba2 successfully compiled!",6000)
        return % ModName . ".ba2"
      }
      else
      {
        msgbox,,Oh noes!,The mod failed to compile :(.`nYou may have to check with the mod author if they've released a .ba2 version. Or follow their instructions on how to get the loose file version to work.
          return false
      }
    }
