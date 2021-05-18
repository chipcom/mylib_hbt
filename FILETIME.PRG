#include "Directry.ch"

**** 18.05.21
**** возвращает .t., если время первого файла больше времени второго
FUNCTION files_time(file1, file2)
  local afile1, afile2
  local tsDateTimeFile1, tsDateTimeFile2

  // if !file(file1)
  if ! HB_VFEXISTS( file1 )
    return .f.     // нет первого файла
  endif
  // if !file(file2)
  if ! HB_VFEXISTS( file2 )
    return .t.     // нет второго файла
  endif

  HB_VFTIMEGET( file1, @tsDateTimeFile1 )
  HB_VFTIMEGET( file2, @tsDateTimeFile2 )

  if tsDateTimeFile1 > tsDateTimeFile2
    return .t.
  endif

  // afile1 := directory(file1)
  // afile2 := directory(file2)
  // if afile1[1,F_DATE] > afile2[1,F_DATE]  // проверка на дату
  //   return .t.
  // elseif afile1[1,F_DATE] == afile2[1,F_DATE]
  //   if afile1[1,F_TIME] > afile2[1,F_TIME]    // проверка на время
  //     return .t.
  //   endif
  // endif
  return .f.
