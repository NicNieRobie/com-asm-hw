; -------------------------------------------------------------------
;   main.asm - program entry point
; -------------------------------------------------------------------

%include "macros.inc"

extern atoi
extern time
extern srand

global PLANE
global SHIP
global TRAIN

section .data
    PLANE   dd  1                       ; number of plane alternative
    SHIP    dd  2                       ; number of ship alternative
    TRAIN   dd  3                       ; number of train alternative
    f_read  db  "-f", 0x0               ; file read mode argument
    ran     db  "-n", 0x0               ; random generation argument
    wr      db  "w", 0x0                ; file write mode flag
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
    count   dd  0                       ; number of elements in the container

section .bss
    argc    resd    1                   ; number of command line arguments
    istream resq    1                   ; input file stream
    ostream resq    1                   ; output file stream
    gen_cnt resd    1                   ; number of elements to be generated
    start_t resq    2                   ; program start time
    end_t   resq    2                   ; program finish time
    cont    resb    200000              ; the container

section .text
    global main
main:
    push    rbp                         ; function prolog
    mov     rbp, rsp
    
    mov     r13, rsi                    ; saving pointer to command line arguments array
.checkArgCount:
    push    rdi

    mov     rax, 228                    ; sys_clock_gettime syscall code
    xor     edi, edi                    ; using system clock (code 0)
    lea     rsi, [start_t]              ; saving to start_t
    syscall
    
    pop     rdi

    cmp     rdi, 4                      ; argument count check
    je      .checkMode
.argCountError:
    PrintBufData [stdout], arg_err      ; print error if argument count is invalid
    
    mov     rax, 228                    ; sys_clock_gettime syscall code
    xor     edi, edi                    ; using system clock (code 0)
    lea     rsi, [end_t]                ; saving to end_t
    syscall
    
    mov     rdi, start_t                ; loading arguments for PrintTime
    mov     rsi, end_t
    mov     rdx, [stdout]
    call    PrintTime                   ; printing execution time
    
    Exit 1                              ; exiting with error code 1
.checkMode:
    mov     rdi, f_read                 ; loading arguments for strcmp
    mov     rsi, [r13+8]
    call    strcmp                      ; checking if input mode is file input
    cmp     rax, 0
    je      .readFromFile
    
    mov     rdi, ran                    ; loading arguments for strcmp
    mov     rsi, [r13+8]
    call    strcmp                      ; checking if input mode is random generation
    cmp     rax, 0
    je      .randomGen
.modeError:
    PrintBufData [stdout], mod_err      ; if wrong input mode flag was specified
    
    mov     rax, 228                    ; sys_clock_gettime syscall code
    xor     edi, edi                    ; using system clock (code 0)
    lea     rsi, [end_t]                ; saving to end_t
    syscall
    
    mov     rdi, start_t                ; loading arguments for PrintTime
    mov     rsi, end_t
    mov     rdx, [stdout]
    call    PrintTime                   ; printing execution time
    
    Exit 1                              ; exiting with error code 1
.readFromFile:
    OpenFileToDest [r13+16], "r", [istream]     ; opening specified file for reading
    
    mov     rdx, [istream]              ; loading input stream
    mov     rsi, count                  ; loading elements count pointer
    mov     rdi, cont                   ; loading container pointer
    xor     rax, rax
    call    InContainer                 ; reading container content from input stream

    CloseFile [istream]                 ; closing the input stream
    
    jmp     .afterInput
.randomGen:
    mov     rdi, [r13+16]               ; loading numer of elements to be generated
    call    atoi                        ; calling atoi to convert string to integer
    mov     [gen_cnt], eax              ; saving to gen_cnt
    
    cmp     eax, 1                      ; checking if gen_cnt >= 1
    jl      .countError
    
    cmp     eax, 10000                  ; checking if gen_cnt <= 10000
    jg      .countError
    
    xor     rdi, rdi                    ; setting parameters for random integer generation
    xor     rax, rax
    call    time
    mov     rdi, rax
    xor     rax, rax
    call    srand
    
    mov     rdi, cont                   ; loading container pointer
    mov     rsi, count                  ; loading container size pointer
    mov     rdx, [gen_cnt]              ; loading the number of elements to be generated
    call    InRndContainer              ; generating container content
.afterInput:
    mov     rdi, [r13+24]               ; loading path to output file
    mov     rsi, wr                     ; loading access flag value
    xor     rax, rax                    ; no SSE-registers used
    call    fopen                       ; opening the output file
    mov     [ostream], rax              ; saving pointer to the output stream

    mov     rdi, cont                   ; loading pointer to container
    mov     rsi, [count]                ; loading the element count
    mov     rdx, [stdout]               ; printing to stdout
    call    OutContainer                ; printing container content
    
    mov     rdi, cont                   ; loading pointer to container
    mov     rsi, [count]                ; loading the element count
    mov     rdx, [ostream]              ; printing to output file
    call    OutContainer                ; printing container content
    
    mov     rdi, cont                   ; loading pointer to container
    mov     rsi, count                  ; loading pointer to element count
    call    DeleteLessThanAvg           ; deleting elements with TimeToDest value less than average value for container's elements
    
    mov     rax, 228                    ; sys_clock_gettime syscall code
    xor     edi, edi                    ; using system clock (code 0)
    lea     rsi, [end_t]                ; saving to end_t
    syscall
    
    mov     rdi, cont                   ; loading pointer to container
    mov     rsi, [count]                ; loading the element count
    mov     rdx, [stdout]               ; printing to stdout
    call    OutContainer                ; printing container content after function call

    xor     rdi, rdi
    xor     rsi, rsi

    mov     rdi, start_t                ; loading arguments for PrintTime
    mov     rsi, end_t
    mov     rdx, [stdout]
    call    PrintTime                   ; printing execution time
    
    mov     rdi, cont                   ; loading pointer to container
    mov     rsi, [count]                ; loading the element count
    mov     rdx, [ostream]              ; printing to output file
    call    OutContainer                ; printing container content after function call

    CloseFile [ostream]
    
    jmp     .return
.countError:
    PrintBufData [stdout], cnt_err      ; printing error
    
    mov     rax, 228                    ; sys_clock_gettime syscall code
    xor     edi, edi                    ; using system clock (code 0)
    lea     rsi, [end_t]                ; saving to end_t
    syscall
    
    mov     rdi, start_t                ; loading arguments for PrintTime
    mov     rsi, end_t
    mov     rdx, [stdout]
    call    PrintTime                   ; printing execution time
    
    Exit 1                              ; exiting with error code 1
.return:
    Exit 0                              ; exiting with error code 0