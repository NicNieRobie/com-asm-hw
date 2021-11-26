extern stdout
extern fprintf
extern printf
extern memcpy
extern memmove

%macro PrintBufData 2
    section .text
        mov     rdi, %1
        mov     rsi, %2
        xor     rax, rax
        call    fprintf
%endmacro

extern InTransport
extern InRndTransport
extern OutTransport
extern DistToDest

global InContainer
InContainer:
section .bss
    .cont   resq    1
    .count  resq    1
    .istr   resq    1
section .text
    push    rbp
    mov     rbp, rsp
    
    mov     [.cont], rdi
    mov     [.count], rsi
    mov     [.istr], rdx
    
    xor     rbx, rbx
    mov     rsi, rdx
.loopBody:
    push    rdi
    push    rbx
    
    mov     rsi, [.istr]
    xor     rax, rax
    call    InTransport
    cmp     rax, 0
    jle     .return
    
    pop     rbx
    inc     rbx
    
    pop     rdi
    add     rdi, 20
    
    jmp     .loopBody
.return:
    mov     rax, [.count]
    mov     [rax], rbx

leave
ret

global InRndContainer
InRndContainer:
section .bss
    .cont   resq    1
    .count  resq    1
    .size   resd    1
section .text
    push    rbp
    mov     rbp, rsp
    
    mov     [.cont], rdi
    mov     [.count], rsi
    mov     [.size], edx
    
    xor     ebx, ebx
.loopBody:
    cmp     ebx, edx
    jge     .return
    
    push    rdi
    push    rbx
    push    rdx
    
    call    InRndTransport
    cmp     rax, 0
    jle     .return
    
    pop     rdx
    
    pop     rbx
    inc     rbx
    
    pop     rdi
    add     rdi, 20
    
    jmp     .loopBody
.return:
    mov     rax, [.count]
    mov     [rax], ebx
    
leave
ret
    
global OutContainer
OutContainer:
section .data
    .index  db  "%d: ", 0x0
    .cntstr db  "Container contains %d elements.", 0xa, 0x0
    .empty  db  0xa, 0x0
section .bss
    .cont   resq    1
    .count  resd    1
    .ostr   resq    1
section .text
    push    rbp
    mov     rbp, rsp
    
    mov     [.cont], rdi
    mov     [.count], rsi
    mov     [.ostr], rdx
    
    push    rdi
    push    rsi
    push    rdx
    
    xor     rdi, rdi
    mov     rdi, [.ostr]
    mov     rsi, .cntstr
    mov     rdx, [.count]
    xor     rax, rax
    call    fprintf
    
    pop     rdx
    pop     rsi
    pop     rdi
    
    mov     rbx, rsi
    mov     rsi, rdx
    xor     ecx, ecx
.loopBody:
    cmp     ecx, ebx
    jge     .return
    
    push    rbx
    push    rcx
    
    mov     rdi, [.ostr]
    mov     rsi, .index
    xor     rdx, rdx
    mov     edx, ecx
    inc     edx
    xor     rax, rax
    call    fprintf
    
    mov     rdi, [.cont]
    mov     rsi, [.ostr]
    call    OutTransport
    
    pop     rcx
    inc     rcx
    
    pop     rbx
    
    mov     rax, [.cont]
    add     rax, 20
    mov     [.cont], rax
    jmp     .loopBody
.return:
    mov     rdi, [.ostr]
    mov     rsi, .empty
    xor     rax, rax
    call    fprintf
leave
ret

global GetContainerAverage
GetContainerAverage:
section .data
    .sum    dq  0.0
section .bss
    .count  resq    1
section .text
    push    rbp
    mov     rbp, rsp
    
    mov     [.count], rsi

    mov     ebx, esi
    xor     ecx, ecx
    cvtsi2sd    xmm2, ecx
.sumLoop:
    cmp     ecx, ebx
    jge     .afterSum
 
    mov     r8, rdi
    push    r8
    add     rdi, 4
    call    DistToDest
    addsd   xmm2, xmm0
    inc     ecx
    
    pop     r8
    add     r8, 20
    mov     rdi, r8
    jmp     .sumLoop
.afterSum:
    movsd       xmm0, xmm2
    cvtsi2sd    xmm2, ebx
    divsd       xmm0, xmm2
leave
ret

global InsertElements
InsertElements:
section .data
    .cont   dq  0
    .sptr   dq  0
    .ssize  dd  0
section .text
    push    rbp
    mov     rbp, rsp
    
    mov     [.cont], rdi
    mov     [.sptr], rsi
    mov     [.ssize], rdx
    
    xor     ecx, ecx
    mov     ebx, edx
.loopBody:
    cmp     ecx, ebx
    jge     .return
    
    xor     r10, r10
.loadLoop:
    cmp     r10, 5
    jge     .continue

    mov     r8, [rsi]
    mov     [rdi], r8
    
    add     rdi, 4
    add     rsi, 4
    
    inc     r10
    jmp     .loadLoop
.continue:
    inc     ecx
    
    jmp     .loopBody
.return:
leave
ret

global DeleteLessThanAvg
DeleteLessThanAvg:
section .data
    .avg    dq  0.0
section .bss
    .cont   resq  1
    .count  resq  1
section .text
    push    rbp
    mov     rbp, rsp
    
    mov     [.cont], rdi
    mov     [.count], rsi
    
    push    rdi
    push    rsi
    
    mov     rax, [.count]
    mov     rsi, [rax]
    call    GetContainerAverage
    movsd   [.avg], xmm0
    
    pop     rsi
    pop     rdi
    
    mov     rax, [.count]
    mov     ebx, [rax]
    xor     ecx, ecx
.loopBody:
    cmp     ecx, ebx
    jge     .return

    mov     r8, rdi
    add     rdi, 4
    push    r8
    call    DistToDest
    pop     r8
    comisd  xmm0, [.avg]
    jb      .delete
    
    jmp     .loopCont
.delete:    
    push    rbx
    push    r8
    push    rcx
    push    rdi
    
    mov     rdi, r8
    mov     rsi, rdi
    add     rsi, 20
    xor     rdx, rdx
    mov     rax, [.count]
    mov     edx, [rax]
    sub     edx, ecx
    dec     edx
    imul    edx, 20
    
    call    memmove
    
    xor     rdx, rdx
    xor     rax, rax
    mov     rax, [.count]
    mov     edx, [rax]
    dec     edx
    mov     [rax], rdx
    
    pop     rdi
    pop     rcx
    pop     r8
    pop     rbx
    
    dec     ecx
    mov     rax, [.count]
    mov     ebx, [rax]
    sub     r8, 20
.loopCont:
    inc     ecx
    
    add     r8, 20
    mov     rdi, r8
    jmp     .loopBody
.return:
leave
ret
    