extern fprintf
extern stdout
extern strcmp
extern fscanf

%macro PrintStr 2
    section .data
        %%str   db  %2, 0x0
    section .text
        mov     rdi, %1
        mov     rsi, %%str
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
        %%mode  db %2, 0x0
    section .text
        mov     rdi, %1
        mov     rsi, %%mode
        xor     rax, rax
        call    fopen
        mov     %3, rax
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