#include 'function.ch'

// 16.08.14
Function val_top_bot(k, r, t, b)
  // ��業��஢��� ���� ������ k ��-⮢ �� ��࠭� ���⨪��쭮
  // �⭮�⥫쭮 ��ப� r (� ��⮬ ࠬ��).
  // Min ������ ��ப� - t, � max ������ - b.
  // �����頥� ���ᨢ �� ���� ��-⮢ - {������ ��ப�,������ ��ப�}
  Local r1, r2

  //DEFAULT r TO 12, t TO 1, b TO 22
  DEFAULT r TO int(maxrow() / 2), t TO 1, b TO maxrow() - 3
  r1 := int(r - (k + 1) / 2)
  if (r2 := r1 + k + 1) > b
    r2 := b
  endif
  if (r1 := r2 - k - 1) < t
    r1 := t
  endif
  return {r1, r2}
