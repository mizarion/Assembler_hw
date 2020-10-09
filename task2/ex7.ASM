format PE console
entry start

include 'win32a.inc'

section '.data' data readable writable

        strVecSize   db 'size of vector = ', 0
        strIncorSize db 'Incorrect size of vector = %d', 10, 0
        strVecElemI  db 'vector[%d] =  ', 0
        strScanInt   db '%d', 0
        strSumValue  db 'Summa = %d', 10, 0
        strVecElemOut  db '[%d] = %d', 10, 0

        vec_size     dd 0
        vec2_size    dd 0 ; размер второго вектора
        positive_count dd 0 ; НУ ТУТ ВСЕ ПОНЯТНО
        i            dd ?
        j            dd ? ;резервируем указатель на vec2
        tmp          dd ?
        value        dd 0
        vec          rd 100
        vec2         rd 100 ;резервируем память для новго вектора
        index        dd 0

section '.code' code readable executable writable


start:
; 1) vector input
        push strVecSize
        call [printf]

        push vec_size
        push strScanInt
        call [scanf]

; if (vec.size > 0) jamp to getVector
        mov eax, [vec_size]
        cmp eax, 0
        jg  getVector
; else
; fail size - кидаем ошибку и выходим из программы
        push vec_size
        push strIncorSize
        call [printf]
        jmp finish
; continue...
getVector:
        xor ecx, ecx            ; ecx = 0 - сбрасываем счетчик ecx
        mov eax, vec            ; ebx = &vec
        mov ebx, vec
getVecLoop:
        mov [tmp], ebx  ; Записываем в tmp текущее значение вектора

        ; if ecx >= vec_size {endInputVector} else {input}
        cmp ecx, [vec_size]
        jge endInputVector       ; to end of loop

        ; input element
        ; вывод 'vector[ecx] =  '
        mov [i], ecx
        push ecx
        push strVecElemI
        call [printf]

        ; записываем в ebx значение текущего элемента
        push ebx
        push strScanInt
        call [scanf]


        mov eax, 0
        cmp eax, [ebx]
        jge itsFalse

        ;ЕСЛИ ЧИСЛО ПОЛОЖИТЕЛЬНОЕ
        ;УВЕЛИЧИВАЕМ count



        ;ДОБАВЛЯЕМ ЭЛЕМЕНТ В МАССИВ

       mov ebx, vec2
       mov eax, [positive_count]

       imul eax, 4

       add ebx, eax
       mov eax, [index]
       mov dword [ebx], eax

        mov eax, [positive_count]
        add eax, 1
        mov [positive_count], eax






itsFalse:
        ; увеличиваем счетчик на 1
        mov ecx, [i]
        inc ecx

        ; переходим к следующему элементу (сдвигаем указатель на 4 байта вправо)
        mov ebx, [tmp]
        add ebx, 4
       ; inc [index]
       mov eax, [index]
       add eax, 1
       mov [index], eax

        jmp getVecLoop ; заново
endInputVector:

        push dword [positive_count]
        push strIncorSize
        call [printf]


; 1 Подсчет кол-ва положительных чисел


; 2 Создать динамический массив vec2
; 3 Пройтись по массиву vec1 и записать его индексы в vec2
; 4) test vector out








printVector2:
        xor ecx, ecx            ; ecx = 0
        mov ebx, vec2            ; ebx = &vec
printVecLoop2:
        mov [tmp], ebx
        cmp ecx, [positive_count]
        je printVecLoop2      ; to end of loop
        mov [i], ecx

        ; output element
        push dword [ebx]
        push ecx
        push strVecElemOut
        call [printf]

        mov ecx, [i]
        inc ecx
        mov ebx, [tmp]
        add ebx, 4
        jmp printVecLoop2
endPrintVector2:




finish:
                call [getch]

                push 0
                call [ExitProcess]


                                

;-------------------------------third act - including HeapApi--------------------------
                                                 
section '.idata' import data readable
    library kernel, 'kernel32.dll',\
            msvcrt, 'msvcrt.dll',\
            user32,'USER32.DLL'

include 'api\user32.inc'
include 'api\kernel32.inc'
    import kernel,\
           ExitProcess, 'ExitProcess',\
           HeapCreate,'HeapCreate',\
           HeapAlloc,'HeapAlloc'
  include 'api\kernel32.inc'
    import msvcrt,\
           printf, 'printf',\
           scanf, 'scanf',\
           getch, '_getch'
