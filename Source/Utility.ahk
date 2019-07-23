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

  HiddenCommandPrompt(cmd)
    {
      runwait,%cmd%,,Hide
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

    GetFileNameFromPath(FileFullPath)
    {
      FileFullPathArray := StrSplit(FileFullPath,"\")
      return FileFullPathArray[FileFullPathArray.length()] ;The last entry in the array is the filename when split by \
    }

    fileHasContent(TheFile)
      {
        fileread,FileContents,%TheFile%
        if !(FileContents)
          return false
        else
          return true
      }
