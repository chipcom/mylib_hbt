#include 'function.ch'

// ������ �-�� MEMOLINE
Function textline(s, n)
  // s - ⥪�� (ᮤ�ন��� 䠩��, ��ப� ࠧ������ �१ EOS)
  // n - ����� ��ப�, ������ ����室��� "�����" �� s
  
  s := token(s, chr(10), n)
  return charrem(chr(13), s)  // 㤠���� �� ��ப� chr(13)

// ������ �-�� MLCOUNT
Function textcount(s)
  // s - ⥪�� (ᮤ�ন��� 䠩��, ��ப� ࠧ������ �१ EOS)
  return numtoken(s, chr(10))
