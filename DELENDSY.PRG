***** 㤠���� ᨬ��� "c" � ���� ��ப� "s" (�� ��� ����稨)
Function DelEndSymb(s,c)
if right((s := alltrim(s)),1) == c
  s := substr(s,1,len(s)-1)
endif
return s
