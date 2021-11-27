; -------------------------------------------------------------------
;   time.asm - compilation unit containing time printing procedure
; -------------------------------------------------------------------

extern fprintf

; -------------------------------------------------------------------
; Function that prints program execution time.
; Takes following parameters:
;   rdi - time of program execution start
;   rsi - time of program execution end
;   rdx - output stream
global PrintTime
PrintTime:
section .data
    ; output format string
    .fmt     db  "Stop at %llu secs, %llu nsecs.", 0xa, 0x0
section .bss
    .ostr    resq   1                   ; output stream pointer
    .delta_t resq   2                   ; execution time duration pointer
section .text
    push    rbp                         ; function prolog
    mov     rbp, rsp
    
    mov     [.ostr], rdx                ; saving output stream pointer
    
    mov     rax, [rsi]                  ; calculating the amount of seconds passed
    sub     rax, [rdi]
    mov     rbx, [rsi+8]                ; calculating the amount of nanoseconds passed
    mov     rcx, [rdi+8]
    cmp     rbx, rcx                    
    jge     .subNanoDiff                ; checking if the difference in nanoseconds is positive
    
    dec     rax
    add     rbx, 1000000000
.subNanoDiff:
    sub     rbx, [rdi+8]
    mov     [.delta_t], rax             ; saving delta seconds
    mov     [.delta_t+8], rbx           ; saving delta nanoseconds

    mov     rdi, [.ostr]                ; setting output stream
    mov     rsi, .fmt                   ; setting output format
    mov     rdx, [.delta_t]             ; loading delta seconds
    mov     rcx, [.delta_t+8]           ; loading delta nanoseconds
    xor     rax, rax                    ; no SSE registers used
    call    fprintf                     ; printing execution time data

leave
ret