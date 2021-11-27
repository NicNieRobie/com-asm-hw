; -------------------------------------------------------------------
;   transport.asm - compilation unit containing procedures for
;     transport-type data manipulation
; -------------------------------------------------------------------

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

; -------------------------------------------------------------------
; Function that reads transport-type data from input.
; Takes following parameters:
;   rdi - pointer to the data load destination
;   rsi - input stream pointer
global InTransport
InTransport:
section .data
    .typefmt    db  "%d%d%d", 0x0       ; type data reading format
section .bss
    .tport      resq    1               ; data load destination pointer
    .istr       resq    1               ; input stream pointer
section .text
    push    rbp                         ; function prolog
    mov     rbp, rsp
    
    mov     [.tport], rdi               ; loading data load destination pointer
    mov     [.istr], rsi                ; loading input stream pointer
    
    mov     rdi, [.istr]                ; loading input stream pointer
    mov     rsi, .typefmt               ; loading scan format
    mov     rdx, [.tport]               ; loading pointer to data load destination (type key)
    mov     rcx, [.tport]               ; loading pointer to data load destination (speed)
    add     rcx, 4
    mov     r8, [.tport]                ; loading pointer to data load destination (distance)
    add     r8, 8
    mov     rax, 0                      ; no SSE registers used
    call    fscanf                      ; reading data
    
    mov     rcx, [.tport]
    mov     eax, [rcx]                  ; loading type key
    
    cmp     eax, [PLANE]                ; if input is a plane-type data
    je      .planeInput
    
    cmp     eax, [SHIP]                 ; if input is a ship-type data
    je      .shipInput
    
    cmp     eax, [TRAIN]                ; if input is a train-type data
    je      .trainInput
    
    xor     rax, rax                    ; returning 0 if read failed
    jmp     .return
.planeInput:
    mov     rdi, [.tport]               ; loading pointer to data-specific load destination 
    add     rdi, 12
    mov     rsi, [.istr]                ; loading pointer to input stream pointer
    call    InPlane                     ; reading plane-specific data
    
    mov     rax, 1
    jmp     .return                     ; returning 1 (successful read)
.shipInput:
    mov     rdi, [.tport]               ; loading pointer to data-specific load destination 
    add     rdi, 12
    mov     rsi, [.istr]                ; loading pointer to input stream pointer
    call    InShip                      ; reading ship-specific data
    
    mov     rax, 1
    jmp     .return                     ; returning 1 (successful read)
.trainInput:
    mov     rdi, [.tport]               ; loading pointer to data-specific load destination 
    add     rdi, 12
    mov     rsi, [.istr]                ; loading pointer to input stream pointer
    call    InTrain                     ; reading train-specific data
    
    mov     rax, 1
    jmp     .return                     ; returning 1 (successful read)
.return:
leave
ret

; -------------------------------------------------------------------
; Function that randomly generates transport-type data.
; Takes following parameters:
;   rdi - pointer to the data load destination
global InRndTransport
InRndTransport:
section .bss
    .tport  resq    1                   ; data load destination pointer
    .key    resd    1                   ; generated type key
section .text
    push    rbp                         ; function prolog
    mov     rbp, rsp
    
    mov     [.tport], rdi               ; loading data load destination pointer
    
    mov     rdi, 1
    mov     rsi, 3
    xor     eax, eax
    call    RandInBounds                ; generating type key
    
    mov     rdi, [.tport]
    mov     [rdi], eax
    mov     [.key], eax                 ; loading type key to reserved memory
    
    mov     rdi, 100
    mov     rsi, 700
    xor     eax, eax
    call    RandInBounds                ; generating speed
    
    mov     rdi, [.tport]
    add     rdi, 4
    mov     [rdi], eax                  ; loading speed to memory
    
    mov     rdi, 500
    mov     rsi, 3000
    xor     eax, eax
    call    RandInBounds                ; generating distance
    
    mov     rdi, [.tport]
    add     rdi, 8
    mov     [rdi], eax                  ; loading distance to memory
    
    xor     eax, eax
    mov     eax, [.key]                 ; loading key to eax register
    
    cmp     eax, [PLANE]                ; if generated data is of plane-type
    je      .planeGen
    
    cmp     eax, [SHIP]                 ; if generated data is of ship-type
    je      .shipGen
    
    cmp     eax, [TRAIN]                ; if generated data is of train-type
    je      .trainGen
    
    xor     rax, rax                    ; return 0 if generation has failed
    jmp     .return
.planeGen:
    mov     rdi, [.tport]               ; loading pointer to data-specific load destination 
    add     rdi, 12
    call    InRndPlane                  ; generating type-speciic data
    
    mov     rax, 1                      ; returning 1 (successful read)
    jmp     .return
.shipGen:
    mov     rdi, [.tport]               ; loading pointer to data-specific load destination 
    add     rdi, 12
    call    InRndShip                   ; generating type-speciic data
    
    mov     rax, 1                      ; returning 1 (successful read)
    jmp     .return
.trainGen:
    mov     rdi, [.tport]               ; loading pointer to data-specific load destination 
    add     rdi, 12
    call    InRndTrain                  ; generating type-speciic data
    
    mov     rax, 1                      ; returning 1 (successful read)
    jmp     .return
.return:
leave
ret

; -------------------------------------------------------------------
; Function that prints transport-type data.
; Takes following parameters:
;   rdi - pointer to the data source
global OutTransport
OutTransport:
section .data
    ; invalid key error message
    .error  db  "Invalid transport type.", 0xa, 0x0
section .text
    push    rbp                         ; function prolog
    mov     rbp, rsp
    
    mov     eax, [rdi]                  ; loading pointer to the data source
    
    cmp     eax, [PLANE]                ; if data is of plane type
    je      .planeOut
    
    cmp     eax, [SHIP]                 ; if data is of ship type
    je      .shipOut
    
    cmp     eax, [TRAIN]                ; if data is of train type
    je      .trainOut
    
    mov     rdi, .error                 ; loading error message
    xor     rax, rax
    call    printf                      ; printing error if data type key is invalid
.planeOut:
    add     rdi, 4                      ; adjusting pointer for it to point to type specific data
    call    OutPlane                    ; printing type specific data
    
    jmp     .return
.shipOut:
    add     rdi, 4                      ; adjusting pointer for it to point to type specific data
    call    OutShip                     ; printing type specific data
    
    jmp     .return
.trainOut:
    add     rdi, 4                      ; adjusting pointer for it to point to type specific data
    call    OutTrain                    ; printing type specific data
    
    jmp     .return
.return:
leave
ret

; -------------------------------------------------------------------
; Function that returns time needed for transport to reach its
;   destination.
; Takes following parameters:
;   rdi - pointer to the data source
global TimeToDest
TimeToDest:
section .text
    push    rbp                         ; function prolog
    mov     rbp, rsp

    cvtsi2sd    xmm0, dword[rdi+4]      ; loading distance to destination to xmm0
    cvtsi2sd    xmm1, dword[rdi]        ; loading speed to xmm1
    divsd       xmm0, xmm1              ; dividing xmm0 by xmm1
leave
ret 