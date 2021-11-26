extern fprintf

global PrintTime
PrintTime:
section .data
    .fmt     db  "Stop at %llu secs, %llu nsecs.", 0xa, 0x0
section .bss
    .ostr    resq   1
    .delta_t resq   2
section .text
    push    rbp
    mov     rbp, rsp
    
    mov     [.ostr], rdx
    
    mov     rax, [rsi]
    sub     rax, [rdi]
    mov     rbx, [rsi+8]
    mov     rcx, [rdi+8]
    cmp     rbx, rcx
    jge     .subNanoDiff
    
    dec     rax
    add     rbx, 1000000000
.subNanoDiff:
    sub     rbx, [rdi+8]
    mov     [.delta_t], rax
    mov     [.delta_t+8], rbx

    mov     rdi, [.ostr]
    mov     rsi, .fmt
    mov     rdx, [.delta_t]
    mov     rcx, [.delta_t+8]
    xor     rax, rax
    call    fprintf

leave
ret