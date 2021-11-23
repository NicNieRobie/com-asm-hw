%include "macros.inc"

section .data
    PLANE   db  1
    SHIP    db  2
    TRAIN   db  3
    f_read  db  "-f", 0x0
    rand    db  "-n", 0x0
    arg_err db  "Incorrect number of arguments in the command line!", 0xa
            db  "  Expected:", 0xa
            db  "     processname -f infile outfile", 0xa
            db  "  Or:", 0xa
            db  "     processname -n number outfile", 0xa
            db  "  Or:", 0xa
            db  "     processname -g number dirpath", 0xa, 0x0
    mod_err db  "Incorrect input mode!", 0xa
            db  "  Expected:", 0xa
            db  "     processname -f infile outfile", 0xa
            db  "  Or:", 0xa
            db  "     processname -n number outfile", 0xa
            db  "  Or:", 0xa
            db  "     processname -g number dirpath", 0xa, 0x0
    count   dq  0

section .bss
    argc    resd    1
    istream resq    1
    ostream resq    1
    cont    resb    240000

section .text
    global main
main:
    push    rbp                     ; prolog
    mov     rbp, rsp
    
    mov     dword [argc], edi
    mov     r12, rsi
_checkArgCount:
    pop     rax
    cmp     rax, 4
    jne     _argCountError
_argCountError:
    PrintBufData [stdout], arg_err
    Exit 1
_checkMode:
    push    rsi
    push    rdi
    StrCompare [r12+8], f_read
    
    pop     rdi
    pop     rsi
    cmp     rax, 0
    je      _readFromFile
    
    push    rsi
    push    rdi
    
    StrCompare [r12+8], rand
    
    pop     rdi
    pop     rsi
    cmp     rax, 0
    je      _readFromFile
_modeError:
    PrintBufData [stdout], mod_err
    Exit 1
_readFromFile:
    OpenFileToDest [r12+16], "r", [istream]
    
    push    rdi
    push    rsi
    push    rdx
    
    mov     rdx, [istream]
    mov     rsi, count
    mov     rdi, cont
    call    InContainer
    
    pop     rdx
    pop     rsi
    pop     rdi
_randomGen:
    

    Exit 0