%include "macros.inc"

extern PLANE
extern SHIP
extern TRAIN

extern fscanf
extern printf

extern InPlane
extern InShip
extern InTrain
extern InRndPlane
extern InRndShip
extern InRndTrain
extern OutPlane
extern OutShip
extern OutTrain

global InTransport
InTransport:
section .data
    .tagfmt     db  "%d", 0x0
    .typefmt    db  "%d%d%d", 0x0
section .bss
    .tport  resq    1
    .istr   resq    1
section .text
    push    rbp
    mov     rbp, rsp
    
    mov     [.tport], rdi
    mov     [.istr], rsi
    
    mov     rdi, [.istr]
    mov     rsi, .typefmt
    mov     rdx, [.tport]
    mov     rcx, [.tport]
    add     rcx, 4
    mov     r8, [.tport]
    add     r8, 8
    mov     rax, 0
    call    fscanf
    
    mov     rcx, [.tport]
    mov     eax, [rcx]
    
    cmp     eax, [PLANE]
    je      .planeInput
    
    cmp     eax, [SHIP]
    je      .shipInput
    
    cmp     eax, [TRAIN]
    je      .trainInput
    
    xor     rax, rax
    jmp     .return
.planeInput:
    mov     rdi, [.tport]
    add     rdi, 12
    mov     rsi, [.istr]
    call    InPlane
    
    mov     rax, 1
    jmp     .return
.shipInput:
    mov     rdi, [.tport]
    add     rdi, 12
    mov     rsi, [.istr]
    call    InShip
    
    mov     rax, 1
    jmp     .return
.trainInput:
    mov     rdi, [.tport]
    add     rdi, 12
    mov     rsi, [.istr]
    call    InTrain
    
    mov     rax, 1
    jmp     .return
.return:
leave
ret

global InRndTransport
InRndTransport:
section .bss
    .tport  resq    1
    .key    resd    1
section .text
    push    rbp
    mov     rbp, rsp
    
    mov     [.tport], rdi
    
    mov     rdi, 1
    mov     rsi, 3
    xor     eax, eax
    call    RandInBounds
    
    mov     rdi, [.tport]
    mov     [rdi], eax
    mov     [.key], eax
    
    mov     rdi, 100
    mov     rsi, 700
    xor     eax, eax
    call    RandInBounds
    
    mov     rdi, [.tport]
    add     rdi, 4
    mov     [rdi], eax
    
    mov     rdi, 500
    mov     rsi, 3000
    xor     eax, eax
    call    RandInBounds
    
    mov     rdi, [.tport]
    add     rdi, 8
    mov     [rdi], eax
    
    xor     eax, eax
    mov     eax, [.key]
    
    cmp     eax, [PLANE]
    je      .planeGen
    
    cmp     eax, [SHIP]
    je      .shipGen
    
    cmp     eax, [TRAIN]
    je      .trainGen
    
    PrintInt [.key], [stdout]
    xor     rax, rax
    jmp     .return
.planeGen:
    mov     rdi, [.tport]
    add     rdi, 12
    call    InRndPlane
    
    mov     rax, 1
    jmp     .return
.shipGen:
    mov     rdi, [.tport]
    add     rdi, 12
    call    InRndShip
    
    mov     rax, 1
    jmp     .return
.trainGen:
    mov     rdi, [.tport]
    add     rdi, 12
    call    InRndTrain
    
    mov     rax, 1
    jmp     .return
.return:
leave
ret

global OutTransport
OutTransport:
section .data
    .error  db  "Invalid transport type.", 0xa, 0x0
section .text
    push    rbp
    mov     rbp, rsp
    
    mov     eax, [rdi]
    
    cmp     eax, [PLANE]
    je      .planeOut
    
    cmp     eax, [SHIP]
    je      .shipOut
    
    cmp     eax, [TRAIN]
    je      .trainOut
    
    mov     rdi, .error
    xor     rax, rax
    call    printf
.planeOut:
    add     rdi, 4
    call    OutPlane
    
    jmp     .return
.shipOut:
    add     rdi, 4
    call    OutShip
    
    jmp     .return
.trainOut:
    add     rdi, 4
    call    OutTrain
    
    jmp     .return
.return:
leave
ret

global DistToDest
DistToDest:
section .data
    fmt db  "%lf", 0xa, 0x0
section .text
    push    rbp
    mov     rbp, rsp

    cvtsi2sd    xmm0, dword[rdi+4]
    cvtsi2sd    xmm1, dword[rdi]
    divsd       xmm0, xmm1
leave
ret 