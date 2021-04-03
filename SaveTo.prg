
function SaveTo( cOldFileFull )
  local nResult
  local cDirR, cNameR, cExtR
  local nameFile
  local newDir

  hb_FNameSplit( cOldFileFull, @cDirR, @cNameR, @cExtR )
  nameFile := cNameR + cExtR

  newDir := manager( 5, 10, maxrow() - 2, , .t., 2, .f., , , ) // "norton" ��� �롮� ��⠫���
  if !empty( newDir )
    if upper( newDir ) == upper( cDirR )
      func_error(4, '��࠭ ��⠫��, � ���஬ 㦥 ����ᠭ 楫���� 䠩�! �� �������⨬�.')
    else
      if hb_FileExists(cOldFileFull)
        mywait('����஢���� "' + nameFile + '" � ��⠫�� "' + newDir + '"' )
        if hb_FileExists(newDir + nameFile)
          hb_FileDelete(newDir + nameFile)
        endif
        nResult := FRename( (cOldFileFull), ( newDir + nameFile ) )
        if nResult != 0
          func_error( 4, "�訡�� ᮧ����� 䠩�� " + newDir + nameFile )
        else
          n_message({'� ��⠫��� '+ newDir +' ����ᠭ 䠩�',;
            '"' + upper(nameFile) + '".';
            },,;
            cColorSt2Msg,cColorStMsg,,,"G+/R")
        endif
      endif
    endif
  else
    n_message({'� ��⠫��� '+ cDirR +' ����ᠭ 䠩�',;
    '"' + upper(nameFile) + '".';
    },,;
    cColorSt2Msg,cColorStMsg,,,"G+/R")
endif

return nil