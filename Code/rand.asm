extern fprintf
extern stdout

%macro  PrintInt    2
    section .data
        %%arg1  db  "%d",10,0
    section .text
        mov rdi, %2
        mov rsi, %%arg1
        mov rdx, %1
        mov rax, 0
        call fprintf
%endmacro

extern rand

global RandInBounds
RandInBounds:
section .bss
    .ubnd   resq    1
    .lbnd   resq    1
section .text
    push    rbp
    mov     rbp, rsp
    
    mov     [.lbnd], rdi
    mov     [.ubnd], rsi
    
    push    rbx
    
    xor     rbx, rbx
    
    mov     rbx, [.ubnd]
    sub     rbx, [.lbnd]
    inc     rbx
    
    xor     rax, rax
    call    rand
    xor     rdx, rdx
    idiv    rbx
    mov     rax, rdx
    inc     rax
    
    pop     rbx
    
leave
ret