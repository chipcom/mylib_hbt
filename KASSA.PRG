#include "inkey.ch"
#include "edit_spr.ch"
#include "function.ch"
#include "kassa.ch"

Static str_err := "!!! ������ !!! "

//  17 - ������ ���ﭨ�
//  ++18 - �뢮� ��ப� (�� 18 ᨬ�����)
//  ++19 - �㤮�
//  20 - ��⠭���� ��ࠬ��஢ ������
//  21 - �⥭�� ��ࠬ��஢ ������
//  ++23 - �뢮� ��ப� (�� 40 ᨬ�����)
//  ++33 - ��⠭���� �६���
//  ++34 � 35 - �ணࠬ��஢���� ����
//  ++37 - ��१�� �����
//  ++41 - ���寧�
//  ++64 - ��⨥ ���� ��� ��襭��
//  ++65 - ��⨥ ���� � ��襭���
// ++128 - �த���
// ++130 - ������ �த���
// ++133 - �����⨥ 祪�
// ++136 - ��㫨஢���� 祪� �� �������
// ++176 - �த������� ����
// 06.07.14 FRCH_d_registr(n_port,registr) -����� ��������� ॣ����

*

***** �����頥� ⥪�騩 ����� 祪�
//Function FR_ret_chek(n_port)
//Local num_chek := 0, tt := FR_ret_dan(n_port)
//if !empty(tt)
//  num_chek := tt[FR_R_NOMER]
//endif
//return num_chek

*

***** �����頥� ���ﭨ�
Function FR_ret_error(n_port)
// n_port - ����� ����
* ������
// 0 �� � ���浪�
// 1 �����稢����� ����஫쭠� ����
// 2 �����稢����� 祪���� ����
Local num_error := 0, sost, tt := FR_ret_dan(n_port), ar := {"�������� !!!",""}
if !empty(tt)
  sost := tt[FR_R_FLAG]
  if !isbit(sost,9)
    ar[2] := "�����稢����� ����������� ����."
    FR_gudok(1)
    n_message(ar,,cColorStMsg,cColorStMsg,,,cColorSt2Msg)
    num_error := 1
  endif
  if !isbit(sost,10)
    ar[2] := "�����稢����� ������� ����."
    FR_gudok(1)
    n_message(ar,,cColorStMsg,cColorStMsg,,,cColorSt2Msg)
    num_error := 2
  endif
endif
return num_error


*

***** �����頥� � ���� ���ᨢ� ���ﭨ� ��
//Function FR_ret_dan(n_port)
// 11H - 17
/*Local t, t2, vozvrat := space(60), mas_vozvr := {}, i, vr1, vr2, vr3,;
      buf := save_maxrow()
mywait()
t2 := FR_slovo(chr(17)+FR_10_2_value(oper_parol,4))
if FR_w_read(n_port,t2,@vozvrat,1) != 0
  rest_box(buf)
  return ""
endif
if !(left(vozvrat,1) == chr(17))
  rest_box(buf)
  return ""
endif
for i := 1 to FR_R_LEN
  do case
    case i == FR_R_ERROR
      t := ""
    case i == FR_R_KASSIR
      t := ""
    case i == FR_R_VERSIAFR
      t := ""
    case i == FR_R_SBORKAFR
      t := ""
    case i == FR_R_POFR_DATE
      t := ""
    case i == FR_R_ZAL_NOM
      t := ""
    case i == FR_R_NOMER
      t2 := iif(old_version(), 11, 12)
      t := FR_2_10_value(substr(vozvrat,t2,2))  // �뫮 11
    case i == FR_R_FLAG
      t2 := iif(old_version(), 13, 14)
      t := FR_2_10_value(substr(vozvrat,t2,2))  // �뫮 13
    case i == FR_R_REGIM
      t := ""
    case i == FR_R_PODREGIM
      t := ""
    case i == FR_R_PORT
      t := ""
    case i == FR_R_VERSIAFP
      t := ""
    case i == FR_R_SBORKAFP
      t := ""
    case i == FR_R_POFP_DATE
      t := ""
    case i == FR_R_DATE
      vr1 := FR_2_10_value(substr(vozvrat,26,1))
      vr2 := FR_2_10_value(substr(vozvrat,27,1))
      vr3 := FR_2_10_value(substr(vozvrat,28,1))
      t := lstr(vr1)+"-"+lstr(vr2)+"-"+lstr(2000+vr3)
      t := ctod(t)
    case i == FR_R_TIME
      vr1 := lstr(FR_2_10_value(substr(vozvrat,29,1)))
      if len(vr1) == 1
        vr1 := "0"+vr1
      endif
      vr2 := lstr(FR_2_10_value(substr(vozvrat,30,1)))
      if len(vr2) == 1
        vr2 := "0"+vr2
      endif
      vr3 := lstr(FR_2_10_value(substr(vozvrat,31,1)))
      if len(vr3) == 1
        vr3 := "0"+vr3
      endif
      t := vr1+":"+vr2+":"+vr3
    case i == FR_R_FLAGFP
      t := ""
    case i == FR_R_ZAVNOMER
      t := ""
    case i == FR_R_SMEN_NOM
      t := ""
    case i == FR_R_FREE_FP
      t := ""
    case i == FR_R_KOL_FISK
      t := ""
    case i == FR_R_FREE_FISK
      t := ""
    case i == FR_R_INN
      t := ""
  endcase
  aadd(mas_vozvr,t)
next
rest_box(buf)
return mas_vozvr
*/

*

***** ��⠭���� ��ࠬ��஢ ������
function FR_wspeed(n_port,fr_port,speed,time_out)
/* 14H - 20
   n_port - ����� ����
   fr_port - ���� �᪠�쭮�� ॣ������ �� 㬮�砭�� 0
*/
local t1 := space(5), t2, t3, t4
DEFAULT fr_port TO 0, time_out to 50
t2 := chr(20)+FR_10_2_value(oper_parol,4)+chr(fr_port)+;
      chr(speed)+chr(time_out)
return FR_work(n_port,t2,@t1)

*

***** �⥭�� ��ࠬ��஢ ������
function FR_rspeed(n_port,fr_port)
/* 15H - 21
   n_port - ����� ����
   fr_port - ���� �᪠�쭮�� ॣ������ �� 㬮�砭�� 0
   �����頥� ��� ᪮��� ����
   mas_sp := {2400,4800,9600,19200,38400,57600,115200}
*/
local t1 := space(5), t2, t3, t4, t5
DEFAULT fr_port TO 0
t2 := chr(21)+FR_10_2_value(oper_parol,4)+chr(fr_port)
t5 := FR_work(n_port,t2,@t1)
if len(t5) == 0
  t3 := asc(substr(t1,3,1))
//  t4 := asc(substr(t1,4,1))
  return t3
endif
return t5

*

***** ��⠭���� �६���
//function FR_set_time(n_port,time)
/*  21H - 33
    n_prot - ����� ����
    time   - �६� � �ଠ� ��:��:��
*/
//local t1 := space(3), t2, v1, v2, v3
//v1 := int(val(substr(time,1,2)))
//v2 := int(val(substr(time,4,2)))
//v3 := int(val(substr(time,7,2)))
//t2 := chr(33)+FR_10_2_value(oper_parol,4)+;
//          FR_10_2_value(v1,1)+;
//          FR_10_2_value(v2,1)+;
//          FR_10_2_value(v3,1)
//return FR_work(n_port,t2,@t1)

*

***** �ணࠬ��஢���� ���� (���⢥ত���� �ணࠬ��஢���� ����)
//Function FR_set_date(n_port,ldate)
/*  22H - 34 � 23H -35
    n_prot - ����� ����
    ldate  - ��� � �ଠ� ����
*/
//local t1 := space(3), t2, v1, v2, v3, t
//t := dtos(ldate)
//v1 := int(val(substr(t,3,2)))
//v2 := int(val(substr(t,5,2)))
//v3 := int(val(substr(t,7,2)))
//t2 := chr(34)+FR_10_2_value(oper_parol,4)+;
//          FR_10_2_value(v3,1)+;
//          FR_10_2_value(v2,1)+;
//          FR_10_2_value(v1,1)
//t := FR_work(n_port,t2,@t1)
//if !empty(t)
//  return t
//endif
//t2 := chr(35)+FR_10_2_value(oper_parol,4)+;
//          FR_10_2_value(v3,1)+;
//          FR_10_2_value(v2,1)+;
//          FR_10_2_value(v1,1)
//return FR_work(n_port,t2,@t1)

*

***** ��१�� 祪���� �����
//function FR_otrezka(n_port,flag,timeout)
/* 25H - 37
   n_port - ����� ����
   flag - 0 ������ ��१��
          1 ����� ��१
*/
//Local t, t2 := space(4)
//DEFAULT timeout TO 0
//if timeout > 0
//  waitperiod(timeout)
//  do while waitperiod()
    //
//  enddo
//endif
//t := chr(37)+FR_10_2_value(oper_parol,4)+chr(flag)
//return FR_work(n_port,t,@t2)

*

***** ���寧�
//function FR_progon(n_port,flag,kol_str)
/*  29H - 41
    n_prot - ����� ����
    flag - 0 ����஫쭠� ����
           1 祪���� ����
           2 ��� �����
    kol_str ������⢮ �ண��塞�� ��ப
    0 ��� - ����஫쭠� ����
    1 ��� - 祪���� ����
*/
//local t1 := space(3), t2, flag1
//if flag == 0
//  flag1 := chr(1)
//elseif flag == 1
//  flag1 := chr(2)
//else
//  flag1 := chr(3)
//endif
//t2 := chr(41)+FR_10_2_value(oper_parol,4)+flag1+chr(kol_str)
//return FR_work(n_port,t2,@t1)

*

***** ���⨥ ���筮�� ����
//Function FR_normgach(n_port,flag)
/*
    n_prot - ����� ����
    flag == 0 - ��� ��襭�� 40H - 64
            1   c ��襭���   41H - 65
*/
//local t1 := space(3), t2
//t2 := iif(flag==1,chr(65),chr(64))+FR_10_2_value(oper_parol,4)
//return FR_work(n_port,t2,@t1)

*

***** �த��� ⮢��
//function FRCH_registr(n_port,cena,kol_vo,sekcia,name,t_nds)
/*  80H - 128
    n_prot - ����� ����
    cena   - 業� ⮢�� � �㡫��
    kol_vo - ������⢮ ⮢��
    sekcia - ����� ᥪ樨
    name   - ������������ ⮢��
*/
//local t1 := space(3), t2, t3 := 0
//@ 10,10 say "kod_NDS"
//@ 11,10 get t3
//myread()
//t2 := chr(128)+FR_10_2_value(oper_parol,4)+;
//      FR_10_2_value(round_5(kol_vo*1000.0,0),5)+;
//      FR_10_2_value(round_5(cena*100.0,0),5)+;
//      chr(sekcia)+chr(t_nds)+replicate(chr(0),3)+;
//      padr(FR_asckkm(upper(name),1),40)
//return FR_work(n_port,t2,@t1)

*

***** ������ �த��� (��� ���㫨஢���� 祪�)
//function FRCH_vozvrat(n_port,cena,kol_vo,sekcia,name)
/*  82H - 130
    n_prot - ����� ����
    cena   - 業� ⮢�� � �㡫��
    kol_vo - ������⢮ ⮢��
    sekcia - ����� ᥪ樨
    name   - ������������ ⮢��
*/
/*local t1 := space(3), t2
DEFAULT kol_vo TO 1, sekcia TO 1, name TO ""
t2 := chr(130)+FR_10_2_value(oper_parol,4)+;
      FR_10_2_value(round_5(kol_vo*1000.0,0),5)+;
      FR_10_2_value(round_5(cena*100.0,0),5)+;
      chr(sekcia)+replicate(chr(0),4)+;
      padr(FR_asckkm(upper(name),1),40)
return FR_work(n_port,t2,@t1)
  */
*

***** �����⨥ 祪�
//function FRCH_close(n_port,summa,summa1,name,t_nds)
/*  85H - 133
    n_port - ����� ����
    summa  - �㬬� �������
    summa1 - �� �।�⭮� ����
    name   - ⥪��
*/
//local t1 := space(8), t2
//DEFAULT name TO " "
//t2 := chr(133)+FR_10_2_value(oper_parol,4)+;
//      FR_10_2_value(round_5(summa*100.0,0),5)+;
//     replicate(chr(0),5)+;
//      replicate(chr(0),5)+;
//      FR_10_2_value(round_5(summa1*100.0,0),5)+;
//      replicate(chr(0),2)+;
//      chr(t_nds)+;
//      replicate(chr(0),3)+;
//      padr(FR_asckkm(upper(name),1),40)
//return FR_work(n_port,t2,@t1)

*

***** ���㫨஢���� �ᥣ� 祪� �� ��� �������
//function FRCH_annul(n_port)
/*  88H - 136
    n_prot - ����� ����
    1 - ���㫨஢���� ��㤠筮
    0 - ���㫨஢���� 㤠筮 �����襭�
*/
/*local t1 := space(32), t2, i, t, ret := 1
t2 := FR_slovo(chr(136)+FR_10_2_value(oper_parol,4))
t := FR_w_read(n_port,t2,@t1,1)
if t == 0    // �ᯥ譮
  ret := 0
endif
return ret
  */
*

***** �த������� ����
//function FR_prodol(n_port)
// B0H  -  176
// n_port - ����� ����
/*local t, t2 := space(4)
t := chr(176)+FR_10_2_value(oper_parol,4)
return FR_work(n_port,t,@t2)
  */
*

***** ��४���஢�� �� ���ᮢ�� ����� � ASCII (� �������)
Function FR_asckkm(stroka,kuda)
/* stroka - ��४����㥬�� ��ப�
   kuda   - 1 �� ASCII � ��
          - 2 �� �� � ASCII
*/
Static key_tran := ;
  {{"�",192},{"�",193},{"�",194},{"�",195},{"�",196},{"�",197},{"�",198},;
   {"�",199},{"�",200},{"�",201},{"�",202},{"�",203},{"�",204},{"�",205},;
   {"�",206},{"�",207},{"�",208},{"�",209},{"�",210},{"�",211},{"�",212},;
   {"�",213},{"�",214},{"�",215},{"�",216},{"�",217},{"�",218},{"�",219},;
   {"�",220},{"�",221},{"�",222},{"�",223};
  }
local i, j, itog := "",t
DEFAULT kuda TO 2
if kuda == 1  // �� ASCII � ��
  for i := 1 to len(stroka)
    t := substr(stroka,i,1)
    if (j := ascan(key_tran, {|x| t == x[1] } )) > 0
      itog += chr(key_tran[j,2])
    else
      itog += t
    endif
  next
else  // �� �� � ASCII
  for i := 1 to len(stroka)
    t := substr(stroka,i,1)
    if (j := ascan(key_tran, {|x| asc(t) == x[2] } )) > 0
      itog += key_tran[j,1]
    else
      itog += t
    endif
  next
endif
return itog

*

***** ��ࠡ�⪠ ��।�� � ������ ������
Function FR_work(n_port,out_data,in_data)
/*
   n_port - ����� ����
   out_data - ��ࠢ�塞� �����
   in_data - �����頥�� �����
*/
local t, t2
DEFAULT out_data TO space(9)
t2 := FR_slovo(out_data)
t := FR_w_read(n_port,t2,@in_data,1)
if t != 0
  to_log_file(str_err+FR_funcerr(0,t))
  return FR_funcerr(0,t)
endif
kod_err := asc(substr(in_data,2,1))
if substr(in_data,1,1) != substr(out_data,1,1)
  to_log_file(str_err+FR_funcerr(0,700))
  return FR_funcerr(0,700)
endif
if kod_err == 0
  return ""
endif
to_log_file(str_err+FR_funcerr(kod_err,0))
return FR_funcerr(kod_err,0)

*

***** �����⮢�� ���� �� ��ப�
function FR_slovo(vh_slovo)
local vih_slovo := "", i, t3, mas_vr := {}
vih_slovo := chr(len(vh_slovo)) + vh_slovo
// ������뢠�� CRC
for i := 1 to len(vih_slovo)
  aadd(mas_vr,asc(substr(vih_slovo,i,1)))
next
t3 := numxor(mas_vr[1],mas_vr[2])
for i := 3 to len(mas_vr)
  t3 := numxor(t3,mas_vr[i])
next
// ������塞 � ��砫� STX � � ����� CRC
vih_slovo := FR_COM_STX + vih_slovo + chr(t3)
return vih_slovo

*

***** �㦥���� �㭪�� ����஢�� ��ப�
function FR_sslovo(vh_slovo,vih_slovo)
/* vh_slovo - ��襤訩 ����
   vih_slovo - ������ �� ��뫪� ����஢����� ��ப�
   �����頥�
   .T. - �� ������⢨� �訡�� � ��襤襬 ����
   .F. - �� ����稨 �訡�� � ��襤襬 ����
   �㭪�� ���⭠� FR_slovo
*/
local crc, slovo, vrem, i, mas_vr := {}, t3, kol_vo
// �뤥�塞 � ���� CRC
// � 㤠�塞 ��� �� ��ப�
vrem  := len(vh_slovo)
crc   := right(vh_slovo,1)
slovo := substr(vh_slovo,1,(vrem-1))
// ����塞 �� ��砫� STX
slovo := substr(slovo,2,100)
// ������뢠�� CRC
for i := 1 to len(slovo)
  aadd(mas_vr,asc(substr(slovo,i,1)))
next
// �뤥�塞 ���� � ���-��� ᨬ�����
kol_vo := substr(slovo,1,1)
if (len(slovo)-1) != asc(kol_vo)
  return .F.
endif
t3 := numxor(mas_vr[1],mas_vr[2])
for i := 3 to len(mas_vr)
  t3 := numxor(t3,mas_vr[i])
next
if !(chr(t3) == crc)
  return .F.
endif
// ����塞 ���� � ���-��� ᨬ�����
vrem := len(slovo)
vih_slovo := substr(slovo,2,(vrem-1))
return .T.


*

***** ��ࠢ�塞 ����� � ���� � ����砥� ���⭮
function FR_w_read(n_port,FR_slovo,in_data)
local vozvr, FR_ERROR := 900, ii, priem := "", t_simv, kol_vo, i, tt, ti
local fl_read := 1
//     fl_read  - 1 �믮����� �⥭��
//                0 ���믮����� �⥭��
//  �������� !!! FR_LOG_FLAG ������ ���� ���ᠭ ���
//  T - ������� LOG 䠨�
//  F - �� ������� LOG 䠨�
/*
     n_port   - ����� ����
     FR_slovo - ��ࠢ�塞� ���� ������
     in_data  - ��ࠬ��� �� ��뫪� ����� ��襤訥 �� �����
                �����頥��� ���祭��
     �����頥��� ���祭��
     0 - ����� ��ࠢ����
     ��⠫쭮� ���� �訡�� (900)
*/
Private time_chek
time_chek := seconds()
to_log_file(time()+"  << "+lstr(asc(substr(FR_slovo,3,1)))+" >>"+replicate("-",10)+;
            " ����� ������� "+replicate("-",10)+" "+lstr(seconds()-time_chek))
// ᭠砫� ���訢��� �� �� ������� �⢥��� �� �।����� �������
// ���� �� �� �ਭ�����
for ii := 1 to 11
  if ii == 11
    com_send(n_port,FR_COM_EOT)
    to_log_file("�� 㤠���� ��⠭����� ��� � 10 ����⮪ => ����뢠�� ᥠ��"+" "+lstr(seconds()-time_chek))
    return FR_ERROR+1
  endif
  // ��頥� ���� �ਥ��
  com_flush(n_port)
  // ���뫠�� ����� � ��⮢���� � �裡 ENQ
  to_log_file(space(ii-1)+"1�� -> ��    FR_COM_ENQ"+" "+lstr(seconds()-time_chek))
  if com_send(n_port,FR_COM_ENQ) == 0
    waitperiod(FR_TIME_1)
    // ������� �⢥�  ACK ��� NAK
    // NAK - �� ������� ��।��� �������
    // ACK - �� ��⮢�� �⢥⭮� ᮮ�饭��
    do while waitperiod() .and. com_count(n_port) == 0
      //
    enddo
    // �஢��塞 �� ����稫� �᫨ ����稫�
    if com_count(n_port) != 0
      vozvr := com_read(n_port,1)
      to_log_file(space(ii-1)+"1�� -> ��    "+chr_16(vozvr)+" "+lstr(seconds()-time_chek))
      if vozvr == FR_COM_NAK // ��室�� �� �ਥ�� � ���� ��筥� ��।���
        to_log_file(space(ii-1)+"1�� -> �� (NAK)"+" "+lstr(seconds()-time_chek))
        EXIT
      elseif vozvr == FR_COM_ACK
        to_log_file(space(ii-1)+"1�� -> �� (ACK)"+" "+lstr(seconds()-time_chek))
        // ���� ᠬ� ��-� ��।��� - �ਭ����� � ��頥�
        waitperiod(FR_TIME_1)
        do while waitperiod() .and. com_count(n_port) == 0
          //
        enddo
        vozvr := com_read(n_port,1)
        to_log_file(space(ii-1)+"1�� -> �� (ACK)"+ chr_16(vozvr)+" "+lstr(seconds()-time_chek))
        if vozvr == FR_COM_STX //��।����� ��ଠ��� �����
          waitperiod(FR_TIME_1)
          do while waitperiod() .and. com_count(n_port) == 0
            //
          enddo
          vozvr := com_read(n_port,1)
          kol_vo := asc(vozvr)
         // to_log_file(space(ii-1)+"�� -> �� (ACK) ���-�� "+ str(kol_vo))
          for i := 1 to kol_vo+1
            waitperiod(FR_TIME_1)
            do while waitperiod() .and. com_count(n_port) == 0
              //
            enddo
            vozvr += com_read(n_port,1)
          next
          to_log_file(space(ii-1)+"1�� -> �� (ACK)"+chr_16(vozvr)+" "+lstr(seconds()-time_chek))
          com_send(n_port,FR_COM_ACK)
          to_log_file(space(ii-1)+"1�� -> ��   FR_COM_ACK"+" "+lstr(seconds()-time_chek))
        else
          to_log_file("1�� -> �� (STX-�訡��)"+chr_16(vozvr)+" "+lstr(seconds()-time_chek))
        endif
      endif
    endif
  else
    to_log_file("1�� -> ��    ����� �� �諨 !!!"+" "+lstr(seconds()-time_chek))
    waitperiod(FR_TIME_1)  // �� ������� ����প� �� �⠢��
    do while waitperiod()
      //
    enddo
  endif
next
/////////////////////////////////////////////////////////////////////////
// ��।�� ������ � �����
priem := "" //09.07.08
for ii := 1 to 11
  if ii == 11
    to_log_file("2�� 㤠���� ��।��� ����� � 10 ����⮪ => ����뢠�� ᥠ��"+" "+lstr(seconds()-time_chek))
    return FR_ERROR+5
  endif
  vozvr := ""
  // ��।��� ����� � ��
  to_log_file(space(ii-1)+"2����� � ����� - "+chr_16(FR_slovo)+" "+lstr(seconds()-time_chek))
  tt := 0
  if (tt :=com_send(n_port,FR_slovo)) > 0
   // to_log_file("2�� -> ��    ����� �� �諨 !!!("+lstr(tt)+")  "+lstr(seconds()-time_chek))
  //  return FR_ERROR+5
  endif
  // ����������
  ti := 0 //������⢮ 横���
  FR1_slovo := FR_slovo
  do while tt > 0
    to_log_file("2�� -> ��    ����� �� �諨 !!!("+lstr(tt)+")  "+lstr(seconds()-time_chek))
    ti++
    if ti > 50
      return FR_ERROR+5
    endif
    FR1_slovo := right(FR1_slovo,tt)
    tt :=com_send(n_port,FR1_slovo)
  enddo
  // ������� �⢥�  ACK
  waitperiod(FR_TIME_1)
  do while waitperiod() .and. com_count(n_port) == 0
    //
  enddo
  // �஢��塞 �� ����稫�
  // � �᫨ ACK ������祭 ��� ����祭� ������⭮ -
  // �� � ��⠥� �� ����祭 NAK
  if com_count(n_port) != 0
    vozvr := com_read(n_port,1)
    to_log_file("2�� -> ��   ���⢥ত���� ������� ��।�� ��->�� "+chr_16(vozvr)+" "+lstr(seconds()-time_chek))
    //vozvr := iif(len(vozvr) == 1,vozvr,substr(vozvr,1,1))
    if vozvr == FR_COM_ACK
      // ����뢠�� ���
      exit
    endif
  endif
next
///////////////////////////////////////////////////////////////
// �ਥ� �⢥� �� �����
for ii := 1 to 11
  if ii == 11
    to_log_file("3�� �ਭ�� �⢥� �� ����� � 10 ����⮪ => ����뢠�� ᥠ��"+" "+lstr(seconds()-time_chek))
    return FR_ERROR+60
  endif
  priem := ""
  // �롨ࠥ� ����� �� ����
  waitperiod(FR_TIME_1)
  do while waitperiod() .and. com_count(n_port) == 0
    //
  enddo
  priem := com_read(n_port,1)
  to_log_file(space(ii-1)+"3�� -> �� (ACK)"+ chr_16(priem)+" "+lstr(seconds()-time_chek))
  if priem == FR_COM_STX //��।����� ��ଠ��� �����
    waitperiod(FR_TIME_1)
    do while waitperiod() .and. com_count(n_port) == 0
      //
    enddo
    kol_vo := com_read(n_port,1)
    priem += kol_vo
    kol_vo := asc(kol_vo)
//    to_log_file(space(ii-1)+"�� -> �� (ACK) ���-�� "+ str(kol_vo))
    for i := 1 to kol_vo+1
      waitperiod(FR_TIME_1)
      do while waitperiod() .and. com_count(n_port) == 0
        //
      enddo
      priem += com_read(n_port,1)
    next
    to_log_file(space(ii-1)+"3�� -> �� (ACK)"+chr_16(priem)+" "+lstr(seconds()-time_chek))
 //   com_send(n_port,FR_COM_NAK)
 //   to_log_file(space(ii-1)+"�� -> ��   FR_COM_NAK")
  endif
  // �ਥ� ������ �����祭
  // �஢��塞 CRC
//  to_log_file(space(ii-1)+"����� �� ����� - "+chr_16(priem))
  if FR_sslovo(priem,@in_data)
    exit
  else
    // ��ࠢ�塞 NAK
    if ii > 1
      to_log_file("3�� -> ��    FR_COM_ENQ"+" "+lstr(seconds()-time_chek))
      if com_send(n_port,FR_COM_ENQ) > 0
        to_log_file("3�� -> ��    ����� �� �諨 !!!"+" "+lstr(seconds()-time_chek))
        return FR_ERROR+60
      endif
    else
      to_log_file("3�� -> ��    FR_COM_NAK"+" "+lstr(seconds()-time_chek))
      if com_send(n_port,FR_COM_NAK) > 0
        to_log_file("3�� -> ��    ����� �� �諨 !!!"+" "+lstr(seconds()-time_chek))
        return FR_ERROR+60
      endif
    endif
  endif
next
// �����⨥ �裡
// ��ࠢ�塞 ���
to_log_file("3�� -> ��    FR_COM_ACK"+" "+lstr(seconds()-time_chek))
if com_send(n_port,FR_COM_ACK) > 0
  to_log_file("3�� -> ��    ����� �� �諨 !!!"+" "+lstr(seconds()-time_chek))
  return FR_ERROR+50
endif
//waitperiod(FR_TIME_4)
// ������� �⢥� EOT
/*do while waitperiod() .and. com_count(n_port) == 0
  //
enddo
vozvr := com_read(n_port)
to_log_file("�� -> ��    "+chr_16(vozvr))
*/
// ����뢠�� ����
//com_close(n_port)
return 0

*

***** ������ COM-����
//function FR_open(n_port,speed)
/*  �㭪�� ����砥� ���� ����� N_PORT � ᪮����� speed
    � ��࠭�� �ய�ᠭ�묨 ��ࠬ�⠬�
    �����頥� .T. �᫨ ����⨥ 㤠筮 ���� .F.
*/
/*local vr := .f., buf := save_maxrow(), ret := .f.
DEFAULT speed TO meS_speed
com_flush(n_port)  // ���⨫� ����
if com_dtr() .and. !com_rts()
  if com_init(n_port,speed,"N",8,1)
    rest_box(buf)
    return .T.
  endif
endif
*/waitperiod(50)
// ����⪠ ������ ���� � �祭�� 0.5 ᥪ㭤
// �६� �ந����쭮�
/*do while waitperiod() // � 横�� �஡㥬 ������ � �㦭묨 ��ࠬ��ࠬ�
  if com_open(n_port,500,500)
     // ������ ���� ����� n_port
     // � ����直� ��稩 ��頥� ���� �ਥ��
    if com_init(n_port,speed,"N",8,1)
      // ���樠����㥬 ��ࠬ���� ���� � �஢�મ�
      // �� �-�� ��ࠬ���� ��⠭�������
      // 1 - ����� ����
      // 2 - ᪮���� ����
      // 3 - ����஫� ��।�� - "N" - ��� �஢�ન �� �⭮���
      // 4 - ���-�� ��⮢ ������ - 8
      // 1 - ���-�� �⮯���� ��� - 1
      if com_dtr()
        com_rts(n_port,.F.)
        // ��⠭����� RTS
        // 1 - ����� ����
        // 2 - ���砭�� RTS - 1(.T.), 0(.F.)
        ret := .T. ; exit
      else
        waitperiod(50) // �६� �ந����쭮
        do while !(vr := com_dtr(n_port,.T.)) .and. waitperiod()
          // ��⠭�������� DTR
          // 1 - ����� ����
          // 2 - ���祭�� DTR - 1(.T.), 0(.F.)
        enddo
        if vr
          com_rts(n_port,.F.)
          // ��⠭����� RTS
          // 1 - ����� ����
          // 2 - ���砭�� RTS - 1(.T.), 0(.F.)
          ret := .T. ; exit
        endif
      endif
    endif
  endif
enddo
rest_box(buf)
return ret
*/
*

***** ������ ��ப� � �訡���
Function FR_funcerr(err_kas,err_my)
// err_kas - ��� �訡�� ���ᮢ��� ������
// err_my  - ��� ��襩 �訡��
Static mm_err_1 := {;  // ��� �訡��
  {"�������⭠� �訡�� � ����"                                , 700 },;
  {"�� 㤠���� ��⠭����� ��� W"                             , 901 },;
  {"����� �� ��ࠢ���� W"                                    , 905 },;
  {"��� ����� �� ����� R"                                    , 910 },;
  {"�� ��ࠢ���� ���⢥ত���� �� �ਥ� R"                    , 930 },;
  {"����� �� ����祭� R"                                      , 940 },;
  {"�� ��ࠢ���� ���⢥ত���� �ਥ�� R"                      , 950 },;
  {"�� ��ࠢ��� ����� ����� R"                             , 960 };
 }
Local mm_err_2 := {;  // ��� �� ����
  {"��� �訡��"                                                ,   0 },;
  {"����ࠢ�� ������⥫� ��1, ��2 ��� ���"                   ,   1 },;
  {"��������� ��1"                                           ,   2 },;
  {"��������� ��1"                                           ,   3 },;
  {"�����४�� ��ࠬ���� � ������� ���饭�� � ��"           ,   4 },;
  {"��� ����襭��� ������ � ��"                               ,   5 },;
  {"�� � ०��� ��室� ������"                                 ,   6 },;
  {"�����४�� ��ࠬ���� � ������� ��� ������ ॠ����樨 ��" ,   7 },;
  {"������� �� �����ন������ � ������ ॠ����樨 ��"          ,   8 },;
  {"�����४⭠� ����� ������� ��"                             ,   9 },;
  {"�� ������� ��業���"                                       ,  17 },;
  {"�����᪮� ����� 㦥 ������"                                ,  18 },;
  {"������ ��� ����� ���� ��᫥���� ����� � ��"            ,  19 },;
  {"������ ᬥ���� �⮣�� �� ��९������"                     ,  20 },;
  {"����� 㦥 �����"                                         ,  21 },;
  {"����� �� �����"                                          ,  22 },;
  {"����� ��ࢮ� ᬥ�� ����� ����� ��᫥���� ᬥ��"          ,  23 },;
  {"��� ��ࢮ� ᬥ�� ����� ���� ��᫥���� ᬥ��"              ,  24 },;
  {"��� ������ � ��"                                           ,  25 },;
  {"�����᪮� ����� �� ������"                                 ,  27 },;
  {"� �������� ��������� ���� ���०������ ������"             ,  28 },;
  {"���०���� ��᫥���� ������ ᬥ���� �⮣��"                ,  29 },;
  {"������� ���ॣ����樨 � �� ��९������"                  ,  30 },;
  {"��९������� ��������� ॣ���� �� ����������"            ,  32 },;
  {"���⠥��� �㬬� ����� ᮤ�ন���� ��������� ॣ����"    ,  33 }}
Local mm_err_21 := {;  // ��� �� ����
  {"����ୠ� ���"                                             ,  34 },;
  {"���ᨬ�� �����⮬ �㬬� ����� �㬬� 祪�"                 ,  38 },;
  {"���������� �⬥���� �।����� �������"                    ,  43 },;
  {"���㫥���� ���� (����୮� ��襭�� ����������)"           ,  44 },;
  {"�㬬� 祪� �� ᥪ樨 ����� �㬬� ��୮"                  ,  45 },;
  {"� �� ��� ����� ��� �믫���"                                ,  46 },;
  {"�� �������஢��, ���� ����� ��஫� ���������� ��ᯥ���"  ,  48 },;
  {"�ॡ���� �믮������ ��饣� ��襭��"                       ,  50 },;
  {"�����४�� ��ࠬ���� � �������"                          ,  51 },;
  {"��� ������"                                                ,  52 },;
  {"����४�� ��ࠬ��� �� ������ ����ன���"                ,  53 },;
  {"�����४�� ��ࠬ���� � ������� ��� ������ ॠ����樨 ��" ,  54 },;
  {"������� �� �����ন������ � ������ ॠ����樨 ��"          ,  55 },;
  {"�訡�� � ���"                                              ,  56 },;
  {"����७��� �訡�� �� ��"                                   ,  57 },;
  {"��९������� ���������� �� ��������� � ᬥ��"              ,  58 },;
  {"��९������� ���������� � ᬥ��"                           ,  59 },;
  {"����� ����� - ������ ����������"                       ,  60 },;
  {"����� �� ����� - ������ ����������"                    ,  61 },;
  {"��९������� �⮣� 祪�"                                   ,  72 },;
  {"������ ���������� � ����⮬ 祪� ������� ⨯�"          ,  73 },;
  {"����� 祪 - ������ ����������"                          ,  74 },;
  {"���� 祪� ��९�����"                                     ,  75 },;
  {"���ᨬ�� �������筮� ����⮩ �㬬� ����� �㬬� 祪�"      ,  77 },;
  {"����� �ॢ�ᨫ� 24 ��"                                   ,  78 },;
  {"������ ��஫�"                                           ,  79 },;
  {"���� ����� �।��饩 �������"                            ,  80 },;
  {"��� ������ - ������ ����������"                          ,  85 },;
  {"�������� ������� �த������� ����"                       ,  88 },;
  {"���㬥�� ����� ��㣨� �����஬"                         ,  89 },;
  {"������ �ॢ�蠥� ���������� � 祪�"                        ,  90 },;
  {"������ �� ��।�����"                                     ,  93 },;
  {"�� ���������"                                            , 100 },;
  {"�訡�� �裡 � ��"                                         , 103 },;
  {"��� 祪���� �����"                                         , 107 },;
  {"��� ����஫쭮� �����"                                     , 108 },;
  {"��९������� ��"                                           , 112 },;
  {"�訡�� ��१稪� �㬠��"                                   , 113 },;
  {"������� �� �����ন������ � ������ ���०���"              , 114 },;
  {"������� �� �����ন������ � ������ ०���"                 , 115 },;
  {"�訡�� ����⨢��� ����� ��"                              , 116 }}
Local s1 := "", s2 := "", s := "", i, k
if err_my > 0
  if (k := ascan(mm_err_1, {|x| x[2] == err_my } )) > 0
    s1 := alltrim(mm_err_1[k,1])
  else
    s1 := "�������⭠� �訡�� ��।�� ����� "+lstr(err_my)
  endif
endif
if err_kas > 0
  aeval(mm_err_21, {|x| aadd(mm_err_2, x) } )
  if (k := ascan(mm_err_2, {|x| x[2] == err_kas } )) > 0
    s2 := alltrim(mm_err_2[k,1])
  else
    s2 := "�������⭠� �訡�� �� ����� "+lstr(err_kas)
  endif
endif
if !empty(s1)
  s := s1
  if !empty(s2)
    s += " / "
  endif
endif
if !empty(s2)
  s += s2
endif
return s

*

***** ��ॢ�� �᫠ � ������� ��⥬� ��᫥���
Function FR_10_2_value(Price,out_len)
// Price   - �८�ࠧ㥬�� �᫮
// out_len - �����, � ���ன �ਢ������ �᫮
// �������㥬 ���� 4 ���� 4.300.000.000
local sout := "", sout1 := "", temp, t1,t2
local mas := {16777216,65536,256,1}
for i := 1 to 4
  if i == 4
    sout += chr(price)
  else
    if price >= mas[i]
       t1 := int(price/mas[i])
       sout += chr(t1)
       price := price-int(t1*mas[i])
    else
      sout += chr(0)
    endif
  endif
next
// ��ॢ��稢���
for i := 4 to 1 step -1
  sout1 += substr(sout,i,1)
next
sout1 := padr(sout1,out_len,chr(0))
return sout1

*

***** ��ॢ�� �᫠ �� ����筮� ��⥬� ��᫥���
Function FR_2_10_value(Price)
// Price - �८�ࠧ㥬�� �᫮ (��ப�)
Local in_len := len(Price), sout := 0
local mas := {1,256,65536,16777216,0,0}
for i := 1 to in_len
  sout += mas[i]*asc(substr(Price,i,1))
next
return sout

*

*****
Static Function to_log_file(s)
if type("FR_LOG_FLAG") == "L" .and. FR_LOG_FLAG
//  s := s+" "+lstr(seconds()-time_chek)
  strfile(s+eos,"__kassa_.log",.t.)
endif
return NIL

*****
Static Function chr_16(t2)
local i, t := ""
for i:= 1 to len(t2)
  t += lstr(asc(substr(t2,i,1)))+" "
next
return t+"("+FR_asckkm(t2,2)+")"

*****
Static Function old_version()
Static is_old
if is_old == NIL
  is_old := (type("yes_fr_old")=="L" .and. yes_fr_old)
endif
return is_old

*

***** ����� ��������� ॣ����
//function FRCH_d_registr(n_port,registr)
/*  1AH - 26
    n_prot  - ����� ����
    registr - ����� ॣ����
*/
//local t1 := space(8), t2, t3 := 0
//t2 := chr(26)+FR_10_2_value(oper_parol,4)+;
//      FR_10_2_value(registr,1)

//t := FR_work(n_port,t2,@t1)
//return FR_2_10_value(substr(t1,4,6))/100
