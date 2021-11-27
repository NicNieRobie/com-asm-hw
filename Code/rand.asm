; -------------------------------------------------------------------
;   rand.asm - compilation unit containing procedure for
;     random integer generation
; -------------------------------------------------------------------

extern rand

; -------------------------------------------------------------------
; Function that generates a random integer in given bounds
;   inclusively.
; Takes following parameters:
;   rdi - lower bound
;   rsi - upper bound
global RandInBounds
RandInBounds:
section .bss
    .ubnd   resq    1                   ; upper bound
    .lbnd   resq    1                   ; lower bound
section .text
    push    rbp                         ; function prolog
    mov     rbp, rsp
    
    mov     [.lbnd], rdi                ; loading lower bound
    mov     [.ubnd], rsi                ; loading upper bound
    
    push    rbx
    
    ; calculating upperBound - lowerBound + 1
    xor     rbx, rbx
    mov     rbx, [.ubnd]
    sub     rbx, [.lbnd]
    inc     rbx
    
    ; calculating (rand() % (upperBound - lowerBound + 1)) + 1
    xor     rax, rax
    call    rand
    xor     rdx, rdx
    idiv    rbx
    mov     rax, rdx
    inc     rax
    
    pop     rbx
    
leave
ret