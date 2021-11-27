; -------------------------------------------------------------------
;   plane.asm - compilation unit containing procedures for
;     plane-type data manipulation
; -------------------------------------------------------------------

%include "macros.inc"

extern TimeToDest

; -------------------------------------------------------------------
; Function that reads plane-type data from input.
; Takes following parameters:
;   rdi - pointer to the data load destination
;   rsi - input stream pointer
global InPlane
InPlane:
section .data
    .readfmt    db  "%d%d", 0x0         ; data read format
section .bss
    .plane  resq    1                   ; data load destination pointer
    .istr   resq    1                   ; input stream pointer
section .text
    push    rbp                         ; function prolog
    mov     rbp, rsp
    
    mov     [.plane], rdi               ; loading destination pointer
    mov     [.istr], rsi                ; loading input stream pointer
    
    mov     rdi, [.istr]                ; loading input stream pointer
    mov     rsi, .readfmt               ; loading read format
    mov     rdx, [.plane]               ; loading destination pointer (max distance)
    mov     rcx, [.plane]               ; loading destination pointer (capacity)
    add     rcx, 4
    xor     rax, rax                    ; no SSE registers used
    call    fscanf                      ; reading data
    
leave
ret

; -------------------------------------------------------------------
; Function that generates plane-type data randomly.
; Takes following parameters:
;   rdi - pointer to the data load destination
global InRndPlane
InRndPlane:
section .bss
    .plane  resq    1                   ; data load destination pointer
    .dist   resd    1                   ; generated max distance
    .cap    resd    1                   ; generated capacity
section .text
    push    rbp                         ; function prolog
    mov     rbp, rsp
    
    mov     [.plane], rdi               ; loading data destination pointer
    
    mov     rdi, 500
    mov     rsi, 7000
    xor     rax, rax
    call    RandInBounds
    mov     [.dist], eax                ; generating max distance
    
    mov     rdi, 3
    mov     rsi, 300
    xor     rax, rax
    call    RandInBounds
    mov     [.cap], eax                 ; generating capacity
    
    mov     rax, [.plane]
    mov     rcx, [.dist]
    mov     [rax], rcx                  ; saving max distance
    
    add     rax, 4
    mov     rcx, [.cap]
    mov     [rax], rcx                  ; saving capacity
    
leave
ret

; -------------------------------------------------------------------
; Function that prints plane-type data.
; Takes following parameters:
;   rdi - pointer to the plane-type data
;   rsi - pointer to output stream
global OutPlane
OutPlane:
section .data
    ; data output format
    .outfmt db  "This is a plane. Speed: %d, distance to destination: %d, "
            db  "time to destination: %lf, maximum distance: %d, capacity: %d", 0xa, 0x0
section .bss
    .plane  resq    1                   ; pointer to the plane-type data
    .ostr   resq    1                   ; pointer to the output stream
section .text
    push    rbp                         ; function prolog
    mov     rbp, rsp
    
    mov     [.plane], rdi               ; loading plane-type data pointer
    mov     [.ostr], rsi                ; loading output stream pointer
    
    call    TimeToDest                  ; calculating time to destination
    
    mov     rdi, [.ostr]                ; loading output stream pointer
    mov     rsi, .outfmt                ; loading print format
    mov     rax, [.plane]               ; preparing data for print
    mov     edx, [rax]
    add     rax, 4
    mov     ecx, [rax]
    add     rax, 4
    mov     r8, [rax]
    add     rax, 4
    mov     r9, [rax]
    mov     rax, 1
    call    fprintf                     ; printing data
    
leave
ret