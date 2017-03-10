#define  FUNC__NAME   1
#define  FUNC_BEG     2
#define  FUNC_END     3
//
//    структура описания строк
//
#define S__LINE       1
#define S__TYPE       2
#define S__CONT       3
#define S__NEXT       4
#define S__JUMP       5
//
//   Типы операторов
//
#define T__STM        0
#define T__DEF        1
#define T__DO         2
#define T__ENDDO      3
#define T__EXIT       4
#define T__LOOP       5
#define T__IF         6
#define T__ELIF       7
#define T__ELSE       8
#define T__ENDIF      9
#define T__RET       10
#define T__FUNC      11
#define T__GO        12  // пустышка перед ELSEIF и ELSE для перехода за ENDIF
//
//    Коды ошибок
//
#define ERR__NO       0     // нет ошибок
#define ERR__CTRL     1     // преждевременное появление FUNCTION
#define ERR__ENDDO    2     // преждевременное появление ENDDO
#define ERR__ENDIF    3     // преждевременное появление ELSE, ELSEIF, ENDIF
#define ERR__LIB      4     // ошибка записи в файл библиотеки
#define ERR__FUNC     5     // нет FUNCTION
#define ERR__NAME     6     // повторное имя функции

*
* Массив состоит из следующих элементов:
*
*   mas[1,i,FUNC__NAME] - имя функции
*   mas[1,i,FUNC_BEG]   - начальная строка функции
*   mas[1,i,FUNC_END]   - конечная строка функции
* ---------------------------------------
*   mas[2,i] - описание каждой i-той функции
*   mas[2,i,S__LINE] - номер строки в исходном файле
*   mas[2,i,S__TYPE] - тип оператора (do while, exit, if и т.д.)
*                         T__STM    - просто исполняемый оператор
*                         T__DEF    - объявления переменных
*                         T__DO     - do while
*                         T__ENDDO  - enddo
*                         T__EXIT   - exit
*                         T__LOOP   - loop
*                         T__IF     - if
*                         T__ELSE   - elseif или else
*                         T__ENDIF  - endif
*                         T__RET    - return
*   mas[2,i,S__CONT] - значимая часть строки,
*                          - для объявления переменных - массив имен;
*                          - для исполняемых операторов - вся строка;
*                          - для операторов цикла и переходов - условие.
*   mas[2,i,S__NEXT] - для операторов - след. исполняемый оператор,
*                          - для операторов цикла и переходов - по .t.
*   mas[2,i,S__JUMP] - только для операторов цикла и переходов - по .f.
*
