format PE console
include 'win32ax.inc'
.code
start:
        invoke  WriteConsole,<invoke GetStdHandle,STD_OUTPUT_HANDLE>,"Hello World !",13,0
        invoke  Sleep,-1
.end start