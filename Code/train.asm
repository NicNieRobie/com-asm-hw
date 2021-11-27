; -------------------------------------------------------------------
;   train.asm - compilation unit containing procedures for
;     train-type data manipulation
; -------------------------------------------------------------------

%include "macros.inc"

extern TimeToDest

; -------------------------------------------------------------------
; Function that reads train-type data from input.
; Takes following parameters:
;   rdi - pointer to the data load destination
;   rsi - input stream pointer
global InTrain
InTrain:
section .bss
    .train      resq    1               ; data load destination pointer
    .istr       resq    1               ; input stream pointer
section .text
    push    rbp                         ; function prolog
    mov     rbp, rsp
    
    mov     [.train], rdi               ; loading destination pointer
    mov     [.istr], rsi                ; loading input stream pointer
    
    NumReadFromStream [.istr], [.train] ; reading parameter from stream
    
leave
ret

; -------------------------------------------------------------------
; Function that generates train-type data randomly.
; Takes following parameters:
;   rdi - pointer to the data load destination
global InRndTrain
InRndTrain:
section .bss
    .train  resq    1                   ; data load destination pointer
    .cars   resd    1                   ; amount of cars (generated)
section .text
    push    rbp                         ; function prolog
    mov     rbp, rsp
    
    mov     [.train], rdi               ; loading destination pointer
    
    mov     rdi, 3                      ; loading lower generation bound
    mov     rsi, 15                     ; loading upper generation bound
    xor     rax, rax
    call    RandInBounds                ; generating car amount in rax
    
    mov     rdi, [.train]               ; loading generated data to destination
    mov     [rdi], eax
    
leave
ret

; -------------------------------------------------------------------
; Function that prints train-type data.
; Takes following parameters:
;   rdi - pointer to the train-type data
;   rsi - pointer to output stream
global OutTrain
OutTrain:
section .data
    ; output format
    .outfmt db  "This is a train. Speed: %d, distance to destination: %d, "
            db  "time to destination: %lf, amount of cars: %d", 0xa, 0x0
section .bss
    .train  resq    1                   ; pointer to the train-type data
    .ostr   resq    1                   ; pointer to the output stream
section .text
    push    rbp                         ; function prolog
    mov     rbp, rsp
    
    mov     [.train], rdi               ; loading train-type data pointer
    mov     [.ostr], rsi                ; loading output stream pointer
    
    call    TimeToDest                  ; calculating time to destination
    
    mov     rdi, [.ostr]                ; loading output stream pointer
    mov     rsi, .outfmt                ; loading output format string
    mov     rax, [.train]               ; loading train-type data (speed, distance to destination, car amount)
    mov     edx, [rax]                  ; (speed)
    mov     ecx, [rax+4]                ; (distance to destination)
    mov     r8, [rax+8]                 ; (car amount)
    mov     rax, 1                      ; using 1 SSE register (xmm0 - time to destination)
    call    fprintf                     ; printing data
    
leave
ret