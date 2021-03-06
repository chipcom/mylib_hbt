#include "fileio.ch"
#include "error.ch"
#include "directry.ch"
#include "inkey.ch"
#include "function.ch"

Static s_key       := "        ^<F8>^ ��ࢠ�� �஢��� ⥪�饣� 䠩��, ^<Ctrl+F8>^ ��� 䠩���"
Static s_Gauge     := "Bce�� �஢�७� 䠩���"
Static s_titul     := "�����㦥�� ���०����� � ����������."
Static s_not_found := "���०����� �� �����㦥��."
Static s_anykey    := "������ ���� �������"
Static s_isend     := " �����祭�!"
Static s_verify    := "�஢�ઠ 楫��⭮�� "
Static tmp_file    := "__TMP__.DBF"

Static cBorColor := "B+/B"   // ��ப� 梥� ��� ࠬ��
Static cBoxColor := "BG+/B"  // ��ப� 梥� ��� ⥪��
Static cRunColor := "G+/B"   // ��ப� 梥� ��� ����饩 ��ப�

Static c1BorColor := "G/RB"     // ��ப� 梥� ��� ࠬ��
Static c1BoxColor := "BG+/RB"   // ��ப� 梥� ��� ⥪��
Static c1RunColor := "GR+/RB"   // ��ப� 梥� ��� ����饩 ��ப�

***** 29.11.15
Function prover_dbf(k,is_left,is_admin)
Static si := 1
/*Local mas_pmt := {"�஢�ઠ ~��� 䠩���",;
                  "�஢�ઠ ~��᪮�쪨� 䠩���",;
                  "�஢�ઠ ~������ 䠩��",;
                  "����⪠  ~६���"}
Local mas_msg := {s_verify+"��� 䠩��� DBF",;
                  s_verify+"��᪮�쪨� ��࠭��� 䠩��� DBF",;
                  s_verify+"������ 䠩�� DBF (����������� �஢�ન ��� 䠩��)",;
                  "����⪠ ६��� 䠩�� DBF �� �������� ���०������"}
Local mas_fun := {"prover_dbf(1)",;
                  "prover_dbf(2)",;
                  "prover_dbf(3)",;
                  "prover_dbf(4)"}*/
Local mas_pmt := {"�஢�ઠ ~��� 䠩���",;
                  "�஢�ઠ ~��᪮�쪨� 䠩���",;
                  "�஢�ઠ ~������ 䠩��"}
Local mas_msg := {s_verify+"��� 䠩��� DBF",;
                  s_verify+"��᪮�쪨� ��࠭��� 䠩��� DBF",;
                  s_verify+"������ 䠩�� DBF (����������� �஢�ન ��� 䠩��)"}
Local mas_fun := {"prover_dbf(1)",;
                  "prover_dbf(2)",;
                  "prover_dbf(3)"}
Local tmp_nhelp
DEFAULT k TO 0
if k == 0
  Private file_stop := .f., delta := -5, is_new_help
  DEFAULT is_left TO .t., is_admin TO .t.
  if !is_admin
    return func_error(4,"����� � ����� ०�� ࠧ��� ⮫쪮 ������������ ��⥬�")
  endif
  if !is_left
    delta := 5
  endif
  is_new_help := (type("nhelp_code") == "C")
  popup_prompt(T_ROW,T_COL+delta,si,mas_pmt,mas_msg,mas_fun,,,iif(is_new_help,"serv_cel",-1))
else
  si := k
  tmp_nhelp := ret_nhelp_code()
  do case
    case k == 1
      nhelp_code := "serv_cel1"
      prover0_dbf()
    case k == 2
      nhelp_code := "serv_cel2"
      prover1_dbf()
    case k == 3
      nhelp_code := "serv_cel3"
      prover2_dbf()
    case k == 4
      nhelp_code := "serv_cel4"
      remont_dbf()
  endcase
  nhelp_code := tmp_nhelp
endif
return NIL

*

***** �㭪�� �஢�ન 楫��⭮�� ��� �ଠ� DBF
Function prover0_dbf()
// �����頥��� ���祭�� - ������⢮ �訡��
Local buf := savescreen(), i, g1, len_gmas, t_word
close databases
if !f_Esc_Enter("�஢�ન 楫��⭮��")
  return 0
endif
Private summa_error := 0, fl_stop := .f., pov_titul := .f.
Private adirectory := directory(dir_server+"*.dbf")
del_tmp_file(adirectory)
// ����㥬 䠩�� �� ��䠢���
asort(adirectory,,,{|x,y| upper(x[1]) < upper(y[1])})
len_gmas := len(adirectory)
status_key(s_key)
g1 := GaugeNew( 16, 20, , s_Gauge, .t. )
GaugeDisplay(g1)
for i := 1 to len_gmas
  GaugeUpdate(g1,i/len_gmas)
  prover_file( dir_server+adirectory[i,F_NAME] )
  if fl_stop
    exit
  endif
next
CloseGauge(g1)
if summa_error > 0
  stat_msg(s_anykey) ; mybell(1,ERR)
  inkey(0)
else
  restscreen(buf)
  t_word := s_verify+"䠩��� ��"+s_isend
  if pov_titul
    n_message({t_word,s_titul},,c1BorColor,c1BoxColor,,,c1RunColor)
  else
    n_message({t_word,s_not_found},,cBorColor,cBoxColor,,,cRunColor)
  endif
endif
restscreen(buf)
return (summa_error)

*

*****
function prover1_dbf()
// �����頥��� ���祭�� - ������⢮ �訡��
Local buf := savescreen(), i, g1, len_gmas, t := 0, z, t_word
close databases
Private summa_error := 0, fl_stop := .f., pov_titul := .f.
Private adirectory := directory(dir_server+"*.dbf")
del_tmp_file(adirectory)
// ����㥬 䠩�� �� ��䠢���
asort(adirectory,,,{|x,y| upper(x[1]) < upper(y[1])})
len_gmas := len(adirectory)
if (adirectory := ret_arr_file()) == NIL
  return NIL
endif
for i := 1 to len_gmas
  if empty(adirectory[i,F_NAME])
    ++t
  endif
next
status_key(s_key)
g1 := GaugeNew( 16, 20, , s_Gauge, .t. )
GaugeDisplay(g1)
z := 0
for i := 1 to len_gmas
  if !empty(adirectory[i,F_NAME])
    prover_file( dir_server+adirectory[i,F_NAME] )
    GaugeUpdate(g1,++z/(len_gmas-t))
  endif
  if fl_stop
    exit
  endif
next
CloseGauge(g1)
if summa_error > 0
  stat_msg(s_anykey) ; mybell(1,ERR)
  inkey(0)
else
  restscreen(buf)
  t_word := s_verify+"��������� 䠩��� ��"+s_isend
  if pov_titul
    n_message({t_word,s_titul},,c1BorColor,c1BoxColor,,,c1RunColor)
  else
    n_message({t_word,s_not_found},,cBorColor,cBoxColor,,,cRunColor)
  endif
endif
restscreen(buf)
return (summa_error)

*

*****
function prover2_dbf()
// �����頥��� ���祭�� - ������⢮ �訡��
Local buf := savescreen(), i, g1, len_gmas, t := 0, z, smy:={0,100}
close databases
Private summa_error := 0, fl_stop := .f., pov_titul := .f.
Private adirectory := directory(dir_server+"*.dbf")
del_tmp_file(adirectory)
// ����㥬 䠩�� �� ��䠢���
asort(adirectory,,,{|x,y| upper(x[1]) < upper(y[1])})
len_gmas := len(adirectory)
if (z := input_file(T_ROW,T_COL+delta)) == 0
  return NIL
endif
if (my := input_diapazon(18,5,20,74,color8,;
       {"������ ��砫���","� �������","�窨 ��� �஢�ન 䠩�� (� %)"},;
       smy,{"99","999"}, {|x,y| iif(!between(x,0,99) .or. !between(y,1,100) .or. y <= x ,;
                                    func_error(4,"������ ����"), .t.) })) == NIL
  return NIL
endif
status_key("^<F8>^ - ��ࢠ�� �஢��� 䠩��")
prover_file(dir_server+adirectory[z,F_NAME],my[1],my[2])
if summa_error > 0
  stat_msg(s_anykey) ; mybell(1,ERR)
  inkey(0)
else
  restscreen(buf)
  if !file_stop
    if pov_titul
      n_message({s_verify+"䠩�� "+adirectory[z,F_NAME]+s_isend,;
               s_titul},,;
               c1BorColor,c1BoxColor,,,c1RunColor)
    else
      n_message({s_verify+"䠩�� "+adirectory[z,F_NAME]+s_isend,;
                 s_not_found},,;
                 cBorColor,cBoxColor,,,cRunColor)
    endif
  endif
endif
restscreen(buf)
return (summa_error)

*

***** 28.05.17
Static Function prover_file(file_name, pr_begin, pr_end)
local hh, rr, ll, len_pol := {}, num_pol := {}, priz_pol := {}, sdvig := {}, arr_field := {},;
      size, t_sdv := 0, i, i0, base_len, t_poz := " ", t_vr, fl_end := .f.
DEFAULT pr_begin to 0, pr_end to 100
if pr_end != 100
  fl_end := .t.
endif
Private str_e_beg := 0, str_e_tek := 0, fl, f_name := StripPath(file_name), mas_err_del := {}
// ��⮢�� ����� � ������� 䠩��
hGauge := GaugeNew(,,{"W+/B","gr+/b","g+/b"},"���� �訡�� � 䠩�� "+f_name,.t.)
GaugeDisplay( hGauge )
// �஡㥬 �஢���� ����⢮ ��������� 䠩��
if !prover_hider(file_name)
  pov_titul := .t.
endif
if file_stop
  return NIL
endif
// �롨����� �� �᫮�� ����
G_Use(file_name,,"__BB__")
// ��� ᨬ���� ����⪨ �� 㤠�����
aadd(len_pol,space(1))
aadd(num_pol,0)
aadd(priz_pol,-2)
aadd(sdvig,t_sdv)
aadd(arr_field,"")
t_sdv += 1
//
base_len := fcount()
for i := 1 to base_len
  size := fieldsize(i)
  if fieldtype(i) == "N"
    aadd(len_pol,space(size))
    aadd(num_pol,i)
    aadd(priz_pol,fielddeci(i))
    aadd(sdvig,t_sdv)
    aadd(arr_field,FieldName(i))
  elseif fieldtype(i) == "D"
    aadd(len_pol,space(size))
    aadd(num_pol,i)
    aadd(priz_pol,-3)
    aadd(sdvig,t_sdv)
    aadd(arr_field,FieldName(i))
  elseif fieldtype(i) == "L"
    aadd(len_pol,space(size))
    aadd(num_pol,i)
    aadd(priz_pol,-1)
    aadd(sdvig,t_sdv)
    aadd(arr_field,FieldName(i))
  endif
  t_sdv += size
next
hh := header()
rr := recsize()
ll := lastrec()
use
fp := fopen(file_name,FO_READ+FO_SHARED)
i0 := 1
if pr_begin != 0
  i0 := int((pr_begin-1)*ll/100)
endif
// ��室 �� �஢�થ ��ࢮ�� ����
for i := i0 to ll // 横� �� ������
  if i < 1000
    @ maxrow(),1 say padr(lstr(i),8) color "R+/R"
  elseif (i%100) == 0
    @ maxrow(),1 say padr(lstr(i),8) color "R+/R"
  endif
  if fl_end .and. int(pr_end*ll/100) < i
    exit
  endif
  GaugeUpdate(hGauge, i/ll)
  fl := .f.
  // �஢�ઠ �� ����⨥ ������ ���뢠��� ࠡ���
  if (t_key := inkey()) == K_CTRL_F8
    fl_stop := .t.
    exit
  elseif t_key == K_F8
    exit
  endif
  for zxz := 1 to len(len_pol) // 横� �� ����
    T_VR := len_pol[zxz]
    if LEN(T_VR) > 0
      fseek(fp,hh+(i-1)*rr+sdvig[zxz],0)
      if fread(fp,@T_VR,len(T_VR)) == len(T_VR)
        if priz_pol[zxz] == -2  // ᨬ��� �ਧ���� 㤠�����
          sim_prov := " *"         
        elseif priz_pol[zxz] == 0  // 楫� �᫠
          sim_prov := " -0123456789"
        elseif priz_pol[zxz] == -1 // �����᪨� ����
          sim_prov := " TF"
        elseif priz_pol[zxz] == -3 // ���� ���
          sim_prov := " 0123456789"
        else
          sim_prov := " -0123456789." // �᫠ � �窮�
        endif
        for j := 1 to LEN(T_VR)
          if !(substr(T_VR,j,1) $ sim_prov)
            if zxz == 1 // ᨬ��� �ਧ���� 㤠�����
              aadd(mas_err_del,{i,T_VR})
            endif
            fix_error(i,arr_field[zxz])
            fl := .t.
            exit
          endif
        next j
      endif
    endif
    if fl ; exit ; endif
  next zxz
next i
fix_error(-1)
fclose(fp)
CloseGauge( hGauge )
return NIL

***** 28.05.17
Static Function fix_error(i,_field_name)
Local j, Cmessage
if i == -1
  return NIL
endif
  str_e_beg := str_e_tek := i
  f_message({"","���������� ����������� !!!","",;
                "�ᥣ� ���०����� - "+lstr(++summa_error),;
                "��᫥���� ���०����� 䠩� - "+alltrim(f_name),;
                "��᫥���� ���०�񭭠� ������ - "+lstr(i),""},,,,6)
  if summa_error < 500              
    Cmessage := f_name+" - ���०����� � ��ப� "+lstr(i)
    if empty(_field_name)
      if len(mas_err_del) > 0
        Cmessage += ", �ਧ��� 㤠����� - ᨬ���: "+mas_err_del[1,2]+" (asc="+lstr(asc(mas_err_del[1,2]))+")"
      endif
      asize(mas_err_del,0)
    else
      Cmessage += " � ���� "+_field_name
    endif
    strfile(cMessage+eos,dir_server+"error.txt",.t.)
  endif
/*
if i == -1 .and. str_e_beg == 0
  return NIL
endif
if str_e_beg == 0
  str_e_beg := str_e_tek := i
elseif str_e_tek+1 == i
  str_e_tek++
  f_message({"","���������� ����������� !!!","",;
                "�ᥣ� ���०����� - "+lstr(summa_error+1),;
                "��᫥���� ���०����� 䠩� - "+alltrim(f_name),;
                "��᫥���� ���०����� - � "+padc(lstr(str_e_beg),8)+;
                " ����� �� "+padc(lstr(str_e_tek),8)+" ������.",""},,"GR+/B","W+/B",,6)
else
  // �뢮� � ��砫쭮� ��ப� str_e_beg �� ������� ��ப� str_e_tek
  f_message({"","���������� ����������� !!!","",;
                "�ᥣ� ���०����� - "+lstr(++summa_error),;
                "��᫥���� ���०����� 䠩� - "+alltrim(f_name),;
                "��᫥���� ���०����� - � "+padc(lstr(str_e_beg),8)+;
                " ����� �� "+padc(lstr(str_e_tek),8)+" ������.",""},,,,6)
  Cmessage := f_name+" - �����㦥�� ���०����� � "
  if str_e_beg == str_e_tek
    Cmessage += "��ப� "+lstr(str_e_beg)+iif(empty(_field_name), "", " � ���� "+_field_name)
  else
    Cmessage += "��ப�� � "+lstr(str_e_beg)+" �� "+lstr(str_e_tek)
  endif
  strfile(cMessage+eos,dir_server+"error.txt",.t.)
  str_e_beg := str_e_tek := i
  if len(mas_err_del) > 0
    if len(mas_err_del) == 1
      Cmessage := "  � ���� '�ਧ��� 㤠�����' �⮨� ������ ᨬ���:"
    else
      Cmessage := "  � ᫥����� ��ப�� � ���� '�ਧ��� 㤠�����' ���� ������ ᨬ����:"
    endif
    strfile(cMessage+eos,dir_server+"error.txt",.t.)
    for j := 1 to len(mas_err_del)
      Cmessage := "  - ��ப� "+lstr(mas_err_del[j,1])+", ᨬ���: "+mas_err_del[j,2]+;
                  " (asc="+lstr(asc(mas_err_del[j,2]))+")"+eos
      strfile(cMessage,dir_server+"error.txt",.t.)
    next
    asize(mas_err_del,0)
  endif
endif*/
return NIL

*

*****
Static Function input_file(r,c)
Static sk := 1
Local mas := {}, k, buf := savescreen(), r1 := r, r2 := 22
aeval(adirectory, {|x,i| aadd(mas,x[F_NAME])})
if (k := popup(r1,c,r2,c+15,mas,sk,,.t.)) > 0
  sk := k
endif
restscreen(buf)
return k

*

*****
Static Function ret_arr_file()
Local ll := 0, j, mas := {}, mas_o := {}, buf := savescreen()
aeval(adirectory, {|x,i| aadd(mas, " * "+x[F_NAME]), ll := max(ll,len(mas[i]))})
if (j := T_ROW+len(adirectory)+1) > 22
  j := 22
endif
status_key("^<Esc>^ - �⪠�; ^<Enter>^ - ���⢥ত����; ^<Ins,+,->^ - ᬥ�� �ਧ���� �롮� 䠩��")
if popup(T_ROW,T_COL+delta,j,T_COL+ll+10,mas,1,color0,.t.,"fmenu_reader",,;
         "���᮪ 䠩���","B/BG") == 0
  restscreen(buf)
  return NIL
endif
aeval(mas, {|x,i| if(substr(x,2,1) == "*", NIL, adirectory[i,F_NAME] := "")})
restscreen(buf)
return adirectory

*

***** 28.05.17
Static Function prover_hider(file_name,tip_prov)
Local fp, bt := " ", fl := .t., t, j, l_zap, N_pol, t_vr, fl_fox := .f.
Local test := "QWERTYUIOPASDFGHJKLZXCVBNM_0123456789"
Local kol_strok, rash_dlina, real_dlina
//
DEFAULT tip_prov to 0
//
file_stop := .f.
fp := fopen(file_name,FO_READ+FO_SHARED)
// �஢��塞 �㫥��� ����
fseek(fp,0,0)
fread(fp,@bt,1)
if !eq_any(asc(bt),cton("03",16),cton("83",16))
  fl := .f.
endif
if asc(bt) == cton("F5",16)
  Cmessage := f_name+" ᮧ��� ���� FoxPro!"+eos
  strfile(cMessage,dir_server+"error.txt",.t.)
  n_message({"����⭥� �ᥣ�, 䠩� "+f_name+" ᮧ��� ���� FoxPro!",;
             "������ ��楤�� ����ᠭ� ��� �஢�ન ���४⭮��",;
             "䠩��� DBF, ᮧ������ � ������� dBaseIII+/Clipper/Harbour.",;
             s_verify+"�஢������� �� �㤥�!"},,;
             c1BorColor,c1BoxColor,,,c1RunColor)
  file_stop := .t.
  return .t.
endif
// �஢��塞 1,2,3 �����
// ��� ��᫥���� ����䨪�樨 䠩��
if fl
  fseek(fp,1,0)
  bt :="   "
  fread(fp,@bt,3)
  t :="20"+strzero(asc(substr(bt,1,1)),2)
  t +=strzero(asc(substr(bt,2,1)),2)
  t +=strzero(asc(substr(bt,3,1)),2)
  if empty(stod(t))
    if tip_prov == 0
      fl := .f.
    else
      fl := .t.
    endif
  endif
endif
/////////////////////////////////////
// �஢��塞 ������⢮ ��ப � ����
if fl
  fseek(fp,4,0)
  bt :="    "
  fread(fp,@bt,4)
  kol_strok := asc(substr(bt,1,1))
  kol_strok += 256*asc(substr(bt,2,1))
  kol_strok += 65536*asc(substr(bt,3,1))
  // 4 ���� �� ��⠥� - �� �� ࠡ�⠥� � ������ ������ 16 000 000 - � ��祬�?
  if (asc(substr(bt,4,1)) != 0)
    if tip_prov == 0
      fl := .f.
    else
      fl := .t.
    endif
  endif
endif
//////////////////////////////////////
// ᭨���� ����� �����
if fl
  fseek(fp,10,0)
  bt := space(2)
  fread(fp,@bt,2)
  l_zap := asc(substr(bt,1,1))
  l_zap += 256*asc(substr(bt,2,1))
  //����� ������⢠ �����
  fseek(fp,8,0)
  bt :=space(2)
  fread(fp,@bt,2)
  t := asc(substr(bt,1,1))
  t += 256*asc(substr(bt,2,1))
  t -= 34
  n_pol := t/32
  if n_pol != int(t/32)                    // 
    fl := .f.
  endif
endif
// �஢��塞 ������
if fl
  fseek(fp,12,0)
  bt :=space(20)
  fread(fp,@bt,20)
  for j := 1 to 20
    if !(asc(substr(bt,j,1)) == 0)
      if j == 18 .and. asc(substr(bt,j,1)) == 103
        fl_fox := .t.
      endif
      fl := .f.
    endif
  next
endif
// ���� �� ���� � ���������
if fl
  for j := 1 to n_pol
    if fl
      fseek(fp,32+32*(j-1),0)
      bt :=space(32)
      fread(fp,@bt,32)
      T := substr(bt,1,11)
      t1 := substr(t,1,atnum(chr(0),t,1,0)-1)
      // �஢��塞 ���०����� � ������������ ����
      for i := 1 to len(t1)
        if !(substr(t1,i,1) $ test)
          fl := .f.
        endif
      next
    endif
    if fl
      // �஢��塞 ⨯ ����
      if !(substr(bt,12,1) $ "CDNML")
        fl := .f.
      endif
    endif
    // �� � ��� ����� ����� ���� ᨬ���� ��᫥ ����⮩
    // ��ப��� ����� ���� ������ 255 ᨬ�����, ���⮬�
    // ����� �������� ��� ����
    t_vr := substr(bt,12,1)
    if fl .and. EQUALANY(t_vr,"D","M","L") .and. asc(substr(bt,18,1)) != 0
      fl := .f.
    endif
    if fl .and. t_vr == "N" .and. asc(substr(bt,17,1)) < asc(substr(bt,18,1))
      fl := .f.
    endif
  next
endif
// �஢��塞 ��᫥���� ᨬ��� 蠯��
if fl
  fseek(fp,32+32*(n_pol),0)
  bt := " "
  fread(fp,@bt,1)
  if asc(bt) != cton("0D",16)
    fl := .f.
  endif
endif
//
bt := " "
fseek(fp,-1,2)
fread(fp,@bt,1)
fclose(fp)
if fl
  real_dlina := filesize(file_name)
  rash_dlina := (l_zap * kol_strok) +( 32+32*(n_pol) + 1) + 1
  if int(rash_dlina) != int(real_dlina) .and. asc(bt) != cton("26",10)
    if tip_prov == 0
      fl := .f.
    else
      fl := .t.  // �訡�� � �����
    endif
  endif
endif
if fl_fox
  Cmessage := f_name+" �।������⥫쭮 ᮧ��� ���� FoxPro !"+eos
  strfile(cMessage,dir_server+"error.txt",.t.)
  //
  n_message({"�।�०�����!",;
             "���� "+f_name+" �।������⥫쭮 ᮧ��� ���� FoxPro!"},,;
             c1BorColor,c1BoxColor,,,c1RunColor)
  fl := .t.
elseif tip_prov == 0 .and. !fl
  Cmessage := "�����㦥�� ���०����� � ��������� "+f_name+eos
  strfile(cMessage,dir_server+"error.txt",.t.)
  //
  n_message({"�����㦥�� �訡�� � ��������� 䠩�� "+f_name,;
             "���쭥��� �஢�ઠ ����� �ਢ��� � ��⥬��� �訡��!"},,;
             c1BorColor,c1BoxColor,,,c1RunColor)
elseif tip_prov == 1 .and. !fl
  n_message({"��������!",;
             "���०����� 䠩�� "+f_name+" �� ᮮ⢥������ ����������",;
             "��⮬���᪮�� ६���!"},,;
             c1BorColor,c1BoxColor,,,c1RunColor)
elseif tip_prov == 1 .and. fl
  n_message({"��������!",;
             "����� �㤥� �஢����� ����⪠ ६��� 䠩�� "+f_name+".",;
             '�� ����� ���� ��७�ᥭ� �� �६���� 䠩� "'+tmp_file+'",',;
             "����� �㤥� ��室���� � ⥪�饩 ��४�ਨ,",;
             "� ����� (��᫥ �ᯥ譮�� ६���) ��� ����室��� 㤠����!",;
             "� ������, ����� ���, ����� �� ������ ��������!"},,;
             cBorColor,cBoxColor,,,cRunColor)
endif
return fl

*

*****
function remont_dbf()
// �����頥��� ���祭�� - ������⢮ �訡��
Local buf := savescreen(), i, g1, len_gmas, t := 0, z, VR, stroki, z_t, lOldDeleted
close databases
Private summa_error := 0, fl_stop := .f.
Private adirectory := directory(dir_server+"*.dbf")
del_tmp_file(adirectory)
// ����㥬 䠩�� �� ��䠢���
asort(adirectory,,,{|x,y| upper(x[1]) < upper(y[1])})
len_gmas := len(adirectory)
if (z := input_file(T_ROW,T_COL+delta)) == 0
  return NIL
endif
IF DISKSPACE() < filesize(dir_server+adirectory[z,F_NAME])
  n_message({"��������!",;
             "�� ⥪�饬 ��᪥ �������筮 ���� ��� ᮧ�����",;
             '䠩�� "'+tmp_file+'".',;
             "�᢮����� ��� � ���஡�� �� ࠧ!"},,;
             c1BorColor,c1BoxColor,,,c1RunColor)
  return NIL
endif
Private f_name := StripPath(dir_server+adirectory[z,F_NAME])
if prover_hider(dir_server+adirectory[z,F_NAME],1) ;
                                  .and. f_Esc_Enter("६��� 䠩��",.t.)
  stroki := kol_record(dir_server+adirectory[z,F_NAME])
  lOldDeleted := SET(_SET_DELETED, .F.)
  use (dir_server+adirectory[z,F_NAME]) new alias OLD
  VR := DBSTRUCT()
  DBCREATE(tmp_file,VR)
  use (tmp_file) new alias _TMP
  select OLD
  KOL_POL := fcount()
  hGauge := GaugeNew(,,{"W+/B","gr+/b","g+/b"},;
                     "�������� �६������ 䠩�� �� 䠩�� "+f_name,.t.)
  GaugeDisplay( hGauge )
  for z_t := 1 to stroki
    GaugeUpdate(hGauge, z_t/stroki)
    select _TMP
    append blank
    for i := 1 to kol_pol
      select OLD
      vrem := fieldget(i)
      fname := field(i)
      vrem1 := &fname
      select _tmp
      if vrem1 == vrem
        fieldput(i,vrem)
      else
        if VR[i,2] == "N"
          fieldput(i,0)
        elseif VR[i,2] == "C"
          fieldput(i," ")
        elseif VR[i,2] == "L"
          fieldput(i,.f.)
        elseif VR[i,2] == "D"
          fieldput(i,ctod(""))
        endif
      endif
    next
    if recno() % 200 == 0
      Commit
    endif
    if old->(deleted())
      select _TMP
      delete
    endif
    select OLD
    skip
  next
  old->(dbCloseArea())
  _tmp->(dbCloseArea())
  CloseGauge( hGauge )
  SET(_SET_DELETED, lOldDeleted)
  n_message({"����஢���� ������ �� �६���� 䠩� �����襭�!",;
             "����� �㤥� �ந������� ������ ���०�������",;
             "䠩�� �६����."},,;
             cBorColor,cBoxColor,,,cRunColor)
  do while file(dir_server+adirectory[z,F_NAME])
    delete file (dir_server+adirectory[z,F_NAME])
  enddo
  copy file (tmp_file) to (dir_server+adirectory[z,F_NAME])
  n_message({"������ �����襭!",;
             "�஢���� ��२�������!"},,;
             cBorColor,cBoxColor,,,cRunColor)
endif
restscreen(buf)
return NIL

*

*****
Static Function kol_record(file_name)
Local fp, bt := " ", fl := .t., t, j, l_zap, N_pol, t_vr, fl_fox := .f.
Local kol_strok, rash_dlina, real_dlina, stroki,prom, n_proc_lech
//
fp := fopen(file_name,FO_READ+FO_SHARED)
// �஢��塞 ������⢮ ��ப � ����
fseek(fp,4,0)
bt :="    "
fread(fp,@bt,4)
kol_strok := asc(substr(bt,1,1))
kol_strok += 256*asc(substr(bt,2,1))
kol_strok += 65536*asc(substr(bt,3,1))
  // 4 ���� �� ��⠥� - �� �� ࠡ�⠥� � ������ ������ 16 000 000
// ᭨���� ����� �����
fseek(fp,10,0)
bt := space(2)
fread(fp,@bt,2)
l_zap := asc(substr(bt,1,1))
l_zap += 256*asc(substr(bt,2,1))
// ����� ������⢠ �����
fseek(fp,8,0)
bt :=space(2)
fread(fp,@bt,2)
t := asc(substr(bt,1,1))
t += 256*asc(substr(bt,2,1))
t -= 34
n_pol := t/32
fclose(fp)
real_dlina := filesize(file_name)
rash_dlina := (l_zap * kol_strok) +( 32+32*(n_pol) + 1) + 2
stroki := real_dlina - ( 32+32*(n_pol) + 1) + 2 //����� ��� 蠯��
n_proc_lech := 10/100  // ᪮�쪮 ��業⮢ ��⠫��� �� ��᫥���� �����
kol_strok := stroki/l_zap
stroki := int(kol_strok)  // �⮣���� ���-�� ����ᥩ
if kol_strok - stroki >= n_proc_lech
  ++stroki  // �ਡ���塞 ६����㥬�� ��ப�
endif
return stroki

*****
Static Function del_tmp_file(arr_f)
Local i, k, tmp
if (k := len(arr_f)) > 0
  for i := k to 1 step -1
    tmp := upper(arr_f[i,F_NAME])
    if "SEMAPHOR" == left(tmp,8) ;  // 䠩� ᥬ���
       .or. "BASE1" == left(tmp,5) ;    // 䠩� ��஫��
       .or. "TMP" == left(tmp,3)  // �६���� 䠩��
      adel(arr_f,i) ; k--
    endif
  next
endif
asize(arr_f,k)
return NIL
