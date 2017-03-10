***** вернуть значение переменной "nhelp_code", если она существует
Function ret_nhelp_code()
Local ret := ""
if type("nhelp_code") == "C"
  ret := nhelp_code
endif
return ret
