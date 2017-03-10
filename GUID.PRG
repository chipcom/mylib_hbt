********************************************************************************
* Create a Windows-Style Random GUID
* Windows primarily uses GUIDs when it registers Class IDs for components
* and other objects, but GUIDs can be used for anything.
* Windows GUIDs are long strings of formatted hexadecimal characters,
* meaning that they use the numbers 0 through 9 and the letters A through F.
* (Microsoft Access also has a built-in Replication ID in the same format.)
* This example shows how to use code that is similar to the Create a
* Variable-Length Random GUID example code to create a GUID like a Windows GUID.
********************************************************************************
* Создать уникальный GUID (переделана из Бейсика)
********************************************************************************
Function CreateGUID()
return f1CreateGUID(8) + "-" + ;
       f1CreateGUID(4) + "-" + ;
       f1CreateGUID(4) + "-" + ;
       f1CreateGUID(4) + "-" + ;
       f1CreateGUID(12)

*****
Static Function f1CreateGUID(tmpLength)
Static strValid := "0123456789ABCDEF"
Local tmpCounter, tmpGUID := ""
For tmpCounter := 1 To tmpLength
  tmpGUID += substr(strValid, random()%16 + 1, 1)
Next
return tmpGUID
