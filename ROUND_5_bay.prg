***** попытаться исправить ошибку Microsoft C v.5.1 при округлении
Function round_5(_val,_dec)
// Local n, s, _k := 20, _d := 7
// n := round(_val,_dec+_d)
// s := str(n,_k+_d-1,_dec+_d)
// s := left(s,_k)
// if right(s,1) == "5"
  // n := val(left(s,_k-1)+"6")
// endif
return round(_val,_dec)
