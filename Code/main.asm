%include "macros.inc"

extern atoi
extern time
extern srand

global PLANE
global SHIP
global TRAIN

section .data
    PLANE   dd  1
    SHIP    dd  2
    TRAIN   dd  3
    f_read  db  "-f", 0x0
    ran     db  "-n", 0x0
    wr      db  "w", 0x0
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
    cnt_err db  "Amount of elements exceeds the max container size or equals 0.", 0xa
            db  "Enter a value: 0 < value <= 10000.", 0xa, 0x0
    count   dd  0

section .bss
    argc    resd    1
    istream resq    1
    ostream resq    1
    gen_cnt resd    1
    start_t resq    2
    end_t   resq    2
    delta_t resq    2
    cont    resb    200000

section .text
    global main
main:
    push    rbp                     ; prolog
    mov     rbp, rsp
    
    mov     r13, rsi
.checkArgCount:
    push    rdi

    mov     rax, 228
    xor     edi, edi
    lea     rsi, [start_t]
    syscall
    
    pop     rdi

    cmp     rdi, 4
    je      .checkMode
.argCountError:
    PrintBufData [stdout], arg_err
    
    mov     rax, 228
    xor     edi, edi
    lea     rsi, [end_t]
    syscall
    
    mov     rdi, start_t
    mov     rsi, end_t
    mov     rsi, [stdout]
    call    PrintTime
    
    Exit 1
.checkMode:
    mov     rdi, f_read
    mov     rsi, [r13+8]
    call    strcmp
    cmp     rax, 0
    je      .readFromFile
    
    mov     rdi, ran
    mov     rsi, [r13+8]
    call    strcmp
    cmp     rax, 0
    je      .randomGen
.modeError:
    PrintBufData [stdout], mod_err
    
    mov     rax, 228
    xor     edi, edi
    lea     rsi, [end_t]
    syscall
    
    mov     rdi, start_t
    mov     rsi, end_t
    mov     rsi, [stdout]
    call    PrintTime
    
    Exit 1
.readFromFile:
    OpenFileToDest [r13+16], "r", [istream]
    
    mov     rdx, [istream]
    mov     rsi, count
    mov     rdi, cont
    xor     rax, rax
    call    InContainer

    CloseFile [istream]
    
    jmp     .afterInput
.randomGen:
    mov     rdi, [r13+16]
    call    atoi
    mov     [gen_cnt], eax
    
    cmp     eax, 1
    jl      .countError
    
    cmp     eax, 10000
    jg      .countError
    
    xor     rdi, rdi
    xor     rax, rax
    call    time
    
    mov     rdi, rax
    xor     rax, rax
    call    srand
    
    mov     rdi, cont
    mov     rsi, count
    mov     rdx, [gen_cnt]
    call    InRndContainer
.afterInput:
    mov     rdi, [r13+24]
    mov     rsi, wr
    xor     rax, rax
    call    fopen
    mov     [ostream], rax

    mov     rdi, cont
    mov     rsi, [count]
    mov     rdx, [stdout]
    call    OutContainer
    
    mov     rdi, cont
    mov     rsi, [count]
    mov     rdx, [ostream]
    call    OutContainer
    
    mov     rdi, cont
    mov     rsi, count
    call    DeleteLessThanAvg
    
    mov     rax, 228
    xor     edi, edi
    lea     rsi, [end_t]
    syscall
    
    mov     rdi, cont
    mov     rsi, [count]
    mov     rdx, [stdout]
    call    OutContainer

    xor     rdi, rdi
    xor     rsi, rsi

    mov     rdi, start_t
    mov     rsi, end_t
    mov     rdx, [stdout]
    call    PrintTime
    
    mov     rdi, cont
    mov     rsi, [count]
    mov     rdx, [ostream]
    call    OutContainer

    CloseFile [ostream]
    
    jmp     .return
.countError:
    PrintBufData [stdout], cnt_err
    
    mov     rax, 228
    xor     edi, edi
    lea     rsi, [end_t]
    syscall
    
    mov     rdi, start_t
    mov     rsi, end_t
    mov     rsi, [stdout]
    call    PrintTime
    
    Exit 1
.return:
    Exit 0