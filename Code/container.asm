global InContainer
InContainer:
section .bss
    .cont   resq    1
    .count  resq    1
    .istr   resq    1
section .text
    push    rbp
    mov     rbp, rsp
    
    push    rdi
    push    rsi
    push    rbx
    
    mov     [.cont], rdi
    mov     [.count], rsi
    mov     [.istr], rdx
_loopBody:
    push    rdi
    push    rbx
    
    mov     rsi, [.istr]
    xor     rax, rax
    call    InTransport
    cmp     rax, 0
    jle     _return
    
    pop     rbx
    inc     rbx
    
    pop     rdi
    add     rdi, 24
_return:
    mov     rax, [.istr]
    mov     [.istr], rbx