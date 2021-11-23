%include "macros.inc"

extern fscanf

extern PLANE
extern SHIP
extern TRAIN

global InTransport
InTransport:
section .data
    .typefmt db  "%d", 0x0
section .bss
    .tport  resq    1
    .istr   resq    1
section .text
    push    rbp
    mov     rbp, rsp
    
    mov     [.tport], rdi
    mov     [.istr], rsi
    
    NumReadFromStream [.istr], [.tport]
    
    mov     rcx, [.tport]
    mov     eax, [rcx]
    
    cmp     eax, [PLANE]
    je      _planeInput
    
    cmp     eax, [SHIP]
    je      _shipInput
    
    cmp     eax, [TRAIN]
    je      _trainInput
    
    xor     rax, rax
    jmp     _return
_planeInput:
    mov     rdi, [.tport]
    add     rdi, 4
    mov     rsi, [.istr]
    call    InPlane
    
    mov     rax, 1
    jmp     _return
_shipInput:
    mov     rdi, [.tport]
    add     rdi, 4
    mov     rsi, [.istr]
    call    InShip
    
    mov     rax, 1
    jmp     _return
_trainInput:
    mov     rdi, [.tport]
    add     rdi, 4
    mov     rsi, [.istr]
    call    InTrain
    
    mov     rax, 1
    jmp     _return
_return:
leave
ret

global InPlane
InPlane:
section .data
    .readfmt    db  "%d%d", 0x0
section .bss
    .plane      resq    1
    .istr       resq    1
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

global InShip
InShip:
section .data
    .readfmt    db  "%d%d", 0x0
section .bss
    .ship       resq    1
    .istr       resq    1
section .text
    push    rbp
    mov     rbp, rsp
    
    mov     [.ship], rdi
    mov     [.istr], rsi
    
    mov     rdi, [.istr]
    mov     rsi, .readfmt
    mov     rdx, [.ship]
    mov     rcx, [.ship]
    add     rcx, 4
    xor     rax, rax
    call    fscanf
    
leave
ret

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