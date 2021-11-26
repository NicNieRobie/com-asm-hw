%include "macros.inc"

extern DistToDest

global InTrain
InTrain:
section .bss
    .train      resq    1
    .istr       resq    1
section .text
    push    rbp
    mov     rbp, rsp
    
    mov     [.train], rdi
    mov     [.istr], rsi
    
    NumReadFromStream [.istr], [.train]
    
leave
ret

global InRndTrain
InRndTrain:
section .bss
    .train  resq    1
    .cars   resd    1
section .text
    push    rbp
    mov     rbp, rsp
    
    mov     [.train], rdi
    
    mov     rdi, 3
    mov     rsi, 15
    xor     rax, rax
    call    RandInBounds
    
    mov     rdi, [.train]
    mov     [rdi], eax
    
leave
ret

global OutTrain
OutTrain:
section .data
    .outfmt db  "This is a train. Speed: %d, distance to destination: %d, "
            db  "time to distance: %lf, amount of cars: %d", 0xa, 0x0
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
    mov     ecx, [rax+4]
    mov     r8, [rax+8]
    mov     rax, 1
    call    fprintf
    
leave
ret