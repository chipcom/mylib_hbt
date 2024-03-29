// ����樨 ����� ���ଠ樨 � XML-䠩�
// (�।����������, �� 䠩� 㦥 ����� � Public-���ਯ�஬ "fp")
#include 'function.ch'

Static otstup := 0, step_otstup := 1

// ��ࢠ� ��ப� XML-䠩��
Function xml_1(s)
  
  DEFAULT s TO '<?xml version="1.0" encoding="windows-1251"?>'
  add_string(dos2win(s))
  return NIL

// ��ப� ��� ��ଫ���� ��砫� ���ଠ樮����� ����� (�� �⤥�쭮� ��ப�)
Function xml_Begin(s, arr)
  // s   - ������������ �������
  // arr - ��㬥�� ���ᨢ (��� NIL)
  
  add_string(space(otstup) + '<' + dos2win(s) + xml_Put_Arr(arr) + '>')
  otstup += step_otstup
  return NIL

// ��ப� ��� ��ଫ���� ����砭�� ���ଠ樮����� ����� (�� �⤥�쭮� ��ப�)
Function xml_End(s)
  // s - ������������ �������

  otstup -= step_otstup
  add_string(space(otstup) + '</' + dos2win(s) + '>')
  return NIL

//* �뢮� ��ப� � XML-䠩�
Function xml_Stroke(s, xvalue, is_need)
  // s       - ������������ �������
  // xvalue  - ���祭�� ������� (��� ��㬥�� ���ᨢ)
  // is_need - ��易⥫쭮��� �뢮�� ������� �������
  Local stroke, fl := .t.

  DEFAULT xvalue TO '', is_need TO .t.
  if !is_need .and. empty(xvalue)
    fl := .f.
  endif
  if fl
    stroke := space(otstup) + '<' + dos2win(s)
    if empty(xvalue)
      add_string(stroke + '/>')
    elseif valtype(xvalue) == 'A'
      add_string(stroke + xml_Put_Arr(xvalue) + '/>')
    else
      add_string(stroke + '>' + dos2win(xml_Convert(xvalue)) + '</' + dos2win(s) + '>')
    endif
  endif
  return NIL

// �뢮� �ਬ�砭�� � XML-䠩�
Function xml_Prim(s)
  
  add_string(space(otstup) + '<!-- ' + dos2win(s) + ' -->')
  return NIL

// �뢮� ���ᨢ�
Static Function xml_Put_Arr(arr)
  Local i, s := ''

  if valtype(arr) == 'A'
    for i := 1 to len(arr)
      s += ' ' + dos2win(arr[i, 1]) + '="' + dos2win(xml_Convert(arr[i, 2])) + '"'
    next
  endif
  return s

// �ॢ�饭�� �� ��६����� � ��ப�
Static Function xml_Convert(xvalue)
  Local i, c, lvalue := ''

  if valtype(xvalue) == 'D'
    lvalue := full_date(xvalue)
  elseif valtype(xvalue) == 'N'
    lvalue := lstr(xvalue)
  elseif valtype(xvalue) == 'C'
    // � ��ப� ���� ��譨� �஡���
    xvalue := charone(' ', alltrim(xvalue))
    // � ��ப� �������� 㣫��� ᪮��� �� ����窨 (� ����窨 = &quot;)
    for i := 1 to len(xvalue)
      c := substr(xvalue, i, 1)
      lvalue += iif(c $ '"<>', '&quot;', c)
    next
  endif
  return lvalue