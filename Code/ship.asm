%include "macros.inc"

extern DistToDest

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

global InRndShip
InRndShip:
section .bss
    .ship   resq    1
    .type   resd    1
    .disp   resd    1
section .text
    push    rbp
    mov     rbp, rsp
    
    mov     [.ship], rdi
    
    mov     rdi, 1
    mov     rsi, 3
    xor     rax, rax
    call    RandInBounds
    mov     [.type], eax
    
    mov     rdi, 1000
    mov     rsi, 15000
    xor     rax, rax
    call    RandInBounds
    mov     [.disp], eax
    
    mov     rax, [.ship]
    mov     rcx, [.type]
    mov     [rax], rcx
    
    add     rax, 4
    mov     rcx, [.disp]
    mov     [rax], rcx
leave
ret

global OutShip
OutShip:
section .data
    .linout db  "This is a ship. Speed: %d, distance to destination: %d, "
            db  "time to distance: %lf, ship type: liner, displacement: %d", 0xa, 0x0
    .tugout db  "This is a ship. Speed: %d, distance to destination: %d, "
            db  "time to distance: %lf, ship type: tugboat, displacement: %d", 0xa, 0x0
    .tanout db  "This is a ship. Speed: %d, distance to destination: %d, "
            db  "time to distance: %lf, ship type: tanker, displacement: %d", 0xa, 0x0
section .bss
    .ship  resq    1
    .ostr   resq    1
section .text
    push    rbp
    mov     rbp, rsp
    
    mov     [.ship], rdi
    mov     [.ostr], rsi
    
    call    DistToDest
    
    mov     rdi, [.ostr]
    mov     rax, [.ship]
    mov     edx, [rax]
    add     rax, 4
    mov     ecx, [rax]
    add     rax, 4
    mov     r10d, [rax]
    
    cmp     r10d, 1
    je      .linerPrint
    
    cmp     r10d, 2
    je      .tugbtPrint
    
    cmp     r10d, 3
    je      .tankrPrint
    
    jmp     .return
.linerPrint:
    mov     rsi, .linout
    add     rax, 4
    mov     r8, [rax]
    mov     rax, 1
    call    fprintf
    
    jmp     .return
.tugbtPrint:
    mov     rsi, .tugout
    add     rax, 4
    mov     r8, [rax]
    mov     rax, 1
    call    fprintf
    
    jmp     .return
.tankrPrint:
    mov     rsi, .tanout
    add     rax, 4
    mov     r8, [rax]
    mov     rax, 1
    call    fprintf
    
    jmp     .return
.return:
leave
ret