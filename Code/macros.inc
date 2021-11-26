extern fprintf
extern stdout
extern strcmp
extern fscanf
extern fopen
extern fclose
extern rand

extern InContainer
extern InRndContainer
extern OutContainer
extern RandInBounds
extern DeleteLessThanAvg
extern PrintTime

%macro  PrintInt    2
    section .data
        %%arg1  db  "%d",0
    section .text
        mov rdi, %2
        mov rsi, %%arg1
        mov rdx, %1
        mov rax, 0
        call fprintf
%endmacro

%macro PrintStr 2
    section .data
        %%str   db  %2, 0x0
    section .text
        mov     rdi, %1
        mov     rsi, %%str
        xor     rax, rax
        call    fprintf
%endmacro

%macro PrintLine 2
    section .data
        %%ln    db  %2, 0xA, 0x0
    section .text
        mov     rdi, %1
        mov     rsi, %%ln
        xor     rax, rax
        call    fprintf
%endmacro

%macro PrintBufData 2
    section .text
        mov     rdi, %1
        mov     rsi, %2
        xor     rax, rax
        call    fprintf
%endmacro

%macro StrCompare 2
    section .text
        mov     rdi, %1
        mov     rsi, %2
        call    strcmp
%endmacro

%macro OpenFileToDest 3
    section .data
        %%rw    db  %2,0
    section .text
        mov     rdi, %1
        mov     rsi, %%rw
        xor     rax, rax
        call    fopen
        mov     %3, rax
%endmacro

%macro CloseFile 1
    section .text
        mov     rdi, %1
        xor     rax, rax
        call    fclose
%endmacro

%macro NumReadFromStream 2
    section .data
        %%sfmt  db  "%d", 0x0
    section .text
        mov     rdi, %1
        mov     rsi, %%sfmt
        mov     rdx, %2
        xor     rax, rax
        call    fscanf
%endmacro

%macro Exit 1
    section .text
        mov     rax, 60
        mov     rdi, %1
        syscall
%endmacro