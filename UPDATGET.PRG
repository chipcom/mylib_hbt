#include 'function.ch'

// �᫨ ���� �맮� ��� �㪢� 's' �� ����
Function update_get(mname, k1)
  return update_gets(mname, k1)

// �������� ���� GET � ������ mname (��� ��ࠬ��஢ �������� �� GET'�)
Function update_gets(mname, k1)
  Local i

  if mname == NIL
    aeval(GetList, {|x| x:display() })
  elseif valtype(mname) == 'C'
    if k1 == NIL  // ���� ��६�����
      if (i := ascan(GetList, {|x| upper(x:name) == upper(mname) })) > 0
        GetList[i]:display()
      endif
    else          // ������� ������୮�� ���ᨢ�
      if (i := ascan(GetList, {|x| upper(x:name) == upper(mname) .and. ;
                                 x:subscript[1] == k1 })) > 0
        GetList[i]:display()
      endif
    endif
  endif
  return .t.
