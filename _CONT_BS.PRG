#include "function.ch"

*****
Function control_base(tip_operac,vercia,path_bs)
/*  tip_operac  - ⨯ ����樨
               1 - ����� ����� �� �� 䠩��
               2 - ���⢥न�� ࠧ�襭�� �� ४��������
               3 - ������� ��� ����� ���ᨨ ��
    vercia     - ����� ��, ᮮ⢥������� ������ ᡮથ �ணࠬ��
                 ��易⥫쭠 ��� ��ࢮ�� �맮��
    path_bs    - ���� � �����
                 ��易⥫�� ��� ��ࢮ�� �맮��
*/
Static spodtv_reconstr, svercia, spath_bs, s_is_smena
Local ret_value
DEFAULT path_bs TO dir_server, svercia TO vercia, spodtv_reconstr TO .T.,;
        s_is_smena TO .f.
private ver__base
do case
  case tip_operac == 1
    ret_value := svercia
    spath_bs := path_bs+"ver_base.mem"
    if file(spath_bs)
      restore from (spath_bs) additive
      if !(type("ver__base") == "N")
        ver__base := svercia
      endif
      ret_value := ver__base
      if svercia < ver__base
        spodtv_reconstr := .F.
      else
        s_is_smena := (svercia != ver__base)
        spodtv_reconstr := .T.
      endif
    else
      s_is_smena := .t.
    endif
  case tip_operac == 2
    if !spodtv_reconstr
      func_error("�� �����⨫� ����� ����� �ணࠬ��. ����� ����饭�!")
      f_end()
    endif
    ret_value := spodtv_reconstr
  case tip_operac == 3 .and. s_is_smena
    ver__base := svercia
    save all like ver__* to (spath_bs)
endcase
return ret_value
