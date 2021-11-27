; -------------------------------------------------------------------
;   ship.asm - compilation unit containing procedures for
;     ship-type data manipulation
; -------------------------------------------------------------------

%include "macros.inc"

extern TimeToDest

; -------------------------------------------------------------------
; Function that reads ship-type data from input.
; Takes following parameters:
;   rdi - pointer to the data load destination
;   rsi - input stream pointer
global InShip
InShip:
section .data
    .readfmt    db  "%d%d", 0x0         ; data read format
section .bss
    .ship       resq    1               ; data load destination pointer
    .istr       resq    1               ; input stream pointer
section .text
    push    rbp                         ; function prolog
    mov     rbp, rsp
    
    mov     [.ship], rdi                ; loading destination pointer
    mov     [.istr], rsi                ; loading input stream pointer
    
    mov     rdi, [.istr]                ; loading input stream pointer
    mov     rsi, .readfmt               ; loading read format
    mov     rdx, [.ship]                ; loading destination pointer (ship type)
    mov     rcx, [.ship]                ; loading destination pointer (displacement)
    add     rcx, 4
    xor     rax, rax                    ; no SSE registers used
    call    fscanf                      ; reading data
    
leave
ret

; -------------------------------------------------------------------
; Function that generates ship-type data randomly.
; Takes following parameters:
;   rdi - pointer to the data load destination
global InRndShip
InRndShip:
section .bss
    .ship   resq    1                   ; data load destination pointer
    .type   resd    1                   ; generated ship type
    .disp   resd    1                   ; generated displacement
section .text
    push    rbp                         ; function prolog
    mov     rbp, rsp
    
    mov     [.ship], rdi                ; loading data destination pointer
    
    mov     rdi, 1
    mov     rsi, 3
    xor     rax, rax
    call    RandInBounds
    mov     [.type], eax                ; generatng ship type
    
    mov     rdi, 1000
    mov     rsi, 15000
    xor     rax, rax
    call    RandInBounds
    mov     [.disp], eax                ; generating displacement
    
    mov     rax, [.ship]
    mov     rcx, [.type]
    mov     [rax], rcx                  ; saving ship type
    
    add     rax, 4
    mov     rcx, [.disp]
    mov     [rax], rcx                  ; saving displacement
leave
ret

; -------------------------------------------------------------------
; Function that prints ship-type data.
; Takes following parameters:
;   rdi - pointer to the ship-type data
;   rsi - pointer to output stream
global OutShip
OutShip:
section .data
    ; liner data output format
    .linout db  "This is a ship. Speed: %d, distance to destination: %d, "
            db  "time to destination: %lf, ship type: liner, displacement: %d", 0xa, 0x0
    ; tugboat data output format
    .tugout db  "This is a ship. Speed: %d, distance to destination: %d, "
            db  "time to destination: %lf, ship type: tugboat, displacement: %d", 0xa, 0x0
    ; tanker data output format
    .tanout db  "This is a ship. Speed: %d, distance to destination: %d, "
            db  "time to destination: %lf, ship type: tanker, displacement: %d", 0xa, 0x0
section .bss
    .ship  resq    1                    ; pointer to the ship-type data
    .ostr   resq    1                   ; pointer to the output stream
section .text
    push    rbp                         ; function prolog
    mov     rbp, rsp
    
    mov     [.ship], rdi                ; loading ship-type data pointer
    mov     [.ostr], rsi                ; loading output stream pointer
    
    call    TimeToDest                  ; calculating time to destination
    
    mov     rdi, [.ostr]                ; preparing data for print
    mov     rax, [.ship]
    mov     edx, [rax]
    add     rax, 4
    mov     ecx, [rax]
    add     rax, 4
    
    mov     r10d, [rax]                 ; ship type key in r10d
    
    cmp     r10d, 1                     ; if ship is a liner
    je      .linerPrint
    
    cmp     r10d, 2                     ; if ship is a tugboat
    je      .tugbtPrint
    
    cmp     r10d, 3                     ; if ship is a tanker
    je      .tankrPrint
    
    jmp     .return
.linerPrint:
    mov     rsi, .linout                ; setting output format and printing data
    add     rax, 4
    mov     r8, [rax]
    mov     rax, 1
    call    fprintf
    
    jmp     .return
.tugbtPrint:
    mov     rsi, .tugout                ; setting output format and printing data
    add     rax, 4
    mov     r8, [rax]
    mov     rax, 1
    call    fprintf
    
    jmp     .return
.tankrPrint:
    mov     rsi, .tanout                ; setting output format and printing data
    add     rax, 4
    mov     r8, [rax]
    mov     rax, 1
    call    fprintf
    
    jmp     .return
.return:
leave
ret