
function SaveTo( cOldFileFull )
  local nResult
  local cDirR, cNameR, cExtR
  local nameFile
  local newDir

  hb_FNameSplit( cOldFileFull, @cDirR, @cNameR, @cExtR )
  nameFile := cNameR + cExtR

  newDir := manager( 5, 10, maxrow() - 2, , .t., 2, .f., , , ) // "norton" для выбора каталога
  if !empty( newDir )
    if upper( newDir ) == upper( cDirR )
      func_error(4, 'Выбран каталог, в котором уже записан целевой файл! Это недопустимо.')
    else
      if hb_FileExists(cOldFileFull)
        mywait('Копирование "' + nameFile + '" в каталог "' + newDir + '"' )
        if hb_FileExists(newDir + nameFile)
          hb_FileDelete(newDir + nameFile)
        endif
        nResult := FRename( (cOldFileFull), ( newDir + nameFile ) )
        if nResult != 0
          func_error( 4, "Ошибка создания файла " + newDir + nameFile )
        else
          n_message({'В каталоге '+ newDir +' записан файл',;
            '"' + upper(nameFile) + '".';
            },,;
            cColorSt2Msg,cColorStMsg,,,"G+/R")
        endif
      endif
    endif
  else
    n_message({'В каталоге '+ cDirR +' записан файл',;
    '"' + upper(nameFile) + '".';
    },,;
    cColorSt2Msg,cColorStMsg,,,"G+/R")
endif

return nil