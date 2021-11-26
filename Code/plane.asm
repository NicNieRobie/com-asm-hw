%include "macros.inc"

extern DistToDest

global InPlane
InPlane:
section .data
    .readfmt    db  "%d%d", 0x0
section .bss
    .plane  resq    1
    .istr   resq    1
section .text
    push    rbp
    mov     rbp, rsp
    
    mov     [.plane], rdi
    mov     [.istr], rsi
    
    mov     rdi, [.istr]
    mov     rsi, .readfmt
    mov     rdx, [.plane]
    mov     rcx, [.plane]
    add     rcx, 4
    xor     rax, rax
    call    fscanf
    
leave
ret

global InRndPlane
InRndPlane:
section .bss
    .plane  resq    1
    .dist   resd    1
    .cap    resd    1
section .text
    push    rbp
    mov     rbp, rsp
    
    mov     [.plane], rdi
    
    mov     rdi, 500
    mov     rsi, 7000
    xor     rax, rax
    call    RandInBounds
    mov     [.dist], eax
    
    mov     rdi, 3
    mov     rsi, 300
    xor     rax, rax
    call    RandInBounds
    mov     [.cap], eax
    
    mov     rax, [.plane]
    mov     rcx, [.dist]
    mov     [rax], rcx
    
    add     rax, 4
    mov     rcx, [.cap]
    mov     [rax], rcx
    
leave
ret

global OutPlane
OutPlane:
section .data
    .outfmt db  "This is a plane. Speed: %d, distance to destination: %d, "
            db  "time to distance: %lf, maximum distance: %d, capacity: %d", 0xa, 0x0
section .bss
    .plane  resq    1
    .ostr   resq    1
section .text
    push    rbp
    mov     rbp, rsp
    
    mov     [.plane], rdi
    mov     [.ostr], rsi
    
    call    DistToDest
    
    mov     rdi, [.ostr]
    mov     rsi, .outfmt
    mov     rax, [.plane]
    mov     edx, [rax]
    add     rax, 4
    mov     ecx, [rax]
    add     rax, 4
    mov     r8, [rax]
    add     rax, 4
    mov     r9, [rax]
    mov     rax, 1
    call    fprintf
    
leave
ret