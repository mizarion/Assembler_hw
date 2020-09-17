format PE console
entry start
 
include 'win32a.inc'
 
;======================================
section '.data' data readable writeable
;======================================
 
hello_newline    db "Hello World!",10,0
hello_no_newline db "Hello World! (without a new line)",0
 
;=======================================
section '.code' code readable executable
;=======================================
 
start:
 
        ccall   [printf],hello_newline      ; Print 'Hello World!' and start a new line.
        ccall   [printf],hello_no_newline   ; Print 'Hello World!' without starting a new line.
 
        ccall   [getchar]                   ; I added this line to exit the application AFTER the user pressed any key.
        stdcall [ExitProcess],0             ; Exit the application
 
;====================================
section '.idata' import data readable
;====================================
 
library kernel,'kernel32.dll',\
        msvcrt,'msvcrt.dll'
 
import  kernel,\
        ExitProcess,'ExitProcess'
 
import  msvcrt,\
        printf,'printf',\
        getchar,'_fgetchar'