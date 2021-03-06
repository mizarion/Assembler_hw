format PE console
entry start

include 'win32a.inc'

section '.data' data readable writable

        strVecSize   db 'size of vector = ', 0
        strIncorSize db 'Incorrect size of vector = %d', 10, 0
        strCountOfPositive db 'Positive numbers = %d', 10 ,0
        strVecElemI  db 'vector[%d] =  ', 0
        strScanInt   db '%d', 0
        strSumValue  db 'Summa = %d', 10, 0
        strVecElemOut  db '[%d] = %d', 10, 0

        vec_size     dd 0
        vec2_size    dd 0 ; ������ ������� �������
        positive_count dd 0 ; �� ��� ��� �������
        i            dd ?
        j            dd ? ;����������� ��������� �� vec2
        tmp          dd ?
        value        dd 0
        vec          rd 100
        vec2         rd 100 ;����������� ������ ��� ����� �������
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
; fail size - ������ ������ � ������� �� ���������
        push vec_size
        push strIncorSize
        call [printf]
        jmp finish
; continue...
getVector:
        xor ecx, ecx            ; ecx = 0 - ���������� ������� ecx
        mov eax, vec            ; ebx = &vec
        mov ebx, vec
getVecLoop:
        mov [tmp], ebx  ; ���������� � tmp ������� �������� �������

        ; if ecx >= vec_size {endInputVector} else {input}
        cmp ecx, [vec_size]
        jge endInputVector       ; to end of loop

        ; input element
        ; ����� 'vector[ecx] =  '
        mov [i], ecx
        push ecx
        push strVecElemI
        call [printf]

        ; ���������� � ebx �������� �������� ��������
        push ebx
        push strScanInt
        call [scanf]


        mov eax, 0
        cmp eax, [ebx]
        jge itsFalse

        ;���� ����� �������������
        ;����������� count



        ;��������� ������� � ������

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
        ; ����������� ������� �� 1
        mov ecx, [i]
        inc ecx

        ; ��������� � ���������� �������� (�������� ��������� �� 4 ����� ������)
        mov ebx, [tmp]
        add ebx, 4
       ; inc [index]
       mov eax, [index]
       add eax, 1
       mov [index], eax

        jmp getVecLoop ; ������
endInputVector:

        push dword [positive_count]
        push strCountOfPositive
        call [printf]


; 1 ������� ���-�� ������������� �����


; 2 ������� ������������ ������ vec2
; 3 �������� �� ������� vec1 � �������� ��� ������� � vec2
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
