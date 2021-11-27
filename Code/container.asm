; -------------------------------------------------------------------
;   container.asm - compilation unit containing procedures for
;     generalized transport-type container manipulation
; -------------------------------------------------------------------

extern stdout
extern fprintf
extern printf
extern memcpy
extern memmove

extern InTransport
extern InRndTransport
extern OutTransport
extern TimeToDest

; -------------------------------------------------------------------
; Function that reads transport-type data container content 
;   from input.
; Takes following parameters:
;   rdi - pointer to the container
;   rsi - container element count pointer
;   rdx - input stream pointer
global InContainer
InContainer:
section .bss
    .cont   resq    1                   ; container pointer
    .count  resq    1                   ; container element count pointer
    .istr   resq    1                   ; input stream pointer
section .text
    push    rbp                         ; function prolog
    mov     rbp, rsp
    
    mov     [.cont], rdi                ; loading pointer to container
    mov     [.count], rsi               ; loading container data count
    mov     [.istr], rdx                ; loading input stream pointer
    
    xor     rbx, rbx                    ; element counter init (=0)
    mov     rsi, rdx                    ; moving input stream pointer
.loopBody:
    push    rdi
    push    rbx
    
    mov     rsi, [.istr]                ; loading input stream pointer as function argument
    xor     rax, rax
    call    InTransport                 ; reading transport type data from stream
    cmp     rax, 0                      ; check if read was successful
    jle     .return                     ; return if read failed
    
    pop     rbx
    inc     rbx                         ; incrementing element counter
    
    pop     rdi
    add     rdi, 20                     ; moving to the next element
    
    jmp     .loopBody
.return:
    mov     rax, [.count]               ; saving the element count
    mov     [rax], rbx

leave
ret

; -------------------------------------------------------------------
; Function that generates transport-type data container content
;   randomly.
; Takes following parameters:
;   rdi - pointer to the container
;   rsi - container element count pointer
;   rdx - amount of elements to be generated
global InRndContainer
InRndContainer:
section .bss
    .cont   resq    1                   ; container pointer
    .count  resq    1                   ; container element count pointer
    .size   resd    1                   ; amount of elements to be generated
section .text
    push    rbp                         ; function prolog
    mov     rbp, rsp
    
    mov     [.cont], rdi                ; loading pointer to the container
    mov     [.count], rsi               ; loading pointer to container element count
    mov     [.size], edx                ; loading the amount of elements to be generated
    
    xor     ebx, ebx                    ; element counter (=0)
.loopBody:
    cmp     ebx, edx                    ; break if all elements have been generated
    jge     .return
    
    push    rdi
    push    rbx
    push    rdx
    
    call    InRndTransport              ; generating transport type data
    cmp     rax, 0                      ; checking if generation was successful
    jle     .return                     ; return if generation failed
    
    pop     rdx
    
    pop     rbx
    inc     rbx                         ; incrementing element count
    
    pop     rdi
    add     rdi, 20                     ; moving to the next element's position
    
    jmp     .loopBody
.return:
    mov     rax, [.count]               ; saving the element count
    mov     [rax], ebx
    
leave
ret

; -------------------------------------------------------------------
; Function that prints transport-type data container content.
; Takes following parameters:
;   rdi - pointer to the container
;   rsi - container element count
;   rdx - output stream pointer
global OutContainer
OutContainer:
section .data
    .index  db  "%d: ", 0x0             ; element index printing format
    .cntstr db  "Container contains %d elements.", 0xa, 0x0     ; element count printing format
    .empty  db  0xa, 0x0                ; '\n' string used for printing an empty line
section .bss
    .cont   resq    1                   ; container pointer
    .count  resd    1                   ; container element count
    .ostr   resq    1                   ; output stream pointer
section .text
    push    rbp                         ; function prolog
    mov     rbp, rsp
    
    mov     [.cont], rdi                ; loading pointer to the container
    mov     [.count], rsi               ; loading container element count
    mov     [.ostr], rdx                ; loading output stream pointer
    
    push    rdi
    push    rsi
    push    rdx
    xor     rdi, rdi
    
    mov     rdi, [.ostr]                ; loading output stream pointer
    mov     rsi, .cntstr                ; loading element count printing format
    mov     rdx, [.count]               ; loading element count
    xor     rax, rax                    ; no SSE registers used
    call    fprintf                     ; printing container element count
    
    pop     rdx
    pop     rsi
    pop     rdi
    
    mov     rbx, rsi                    ; loading container element count to rbx
    mov     rsi, rdx                    ; moving pointer to output stream
    xor     ecx, ecx                    ; amount of printed elements (=0)
.loopBody:
    cmp     ecx, ebx                    ; break if all elements have been printed
    jge     .return
    
    push    rbx
    push    rcx
    
    mov     rdi, [.ostr]                ; loading output stream pointer
    mov     rsi, .index                 ; loading index printing format
    xor     rdx, rdx
    mov     edx, ecx                    ; loading index
    inc     edx                         ; (printing ecx + 1)
    xor     rax, rax                    ; no SSE registers used
    call    fprintf                     ; printing current index
    
    mov     rdi, [.cont]                ; loading arguments for function
    mov     rsi, [.ostr]
    call    OutTransport                ; printing transport type data
    
    pop     rcx
    inc     rcx                         ; incrementing the amount of printed elements
    
    pop     rbx
    
    mov     rax, [.cont]
    add     rax, 20                     ; moving to the next element
    mov     [.cont], rax
    jmp     .loopBody
.return:
    mov     rdi, [.ostr]                ; loading output stream pointer
    mov     rsi, .empty                 ; loading newline string
    xor     rax, rax
    call    fprintf                     ; printing an empty line
leave
ret

; -------------------------------------------------------------------
; Function that returns an average value of TimeToDest in the
;   container.
; Takes following parameters:
;   rdi - pointer to the container
;   rsi - container element count
global GetContainerAverage
GetContainerAverage:
section .data
    .sum    dq  0.0                     ; sum of TimeToDest values of container elements
section .bss
    .count  resq    1                   ; container element count
section .text
    push    rbp                         ; function prolog
    mov     rbp, rsp
    
    mov     [.count], rsi               ; loading the container element count

    mov     ebx, esi                    ; moving container element count to ebx
    xor     ecx, ecx                    ; traversed element count (=0)
    cvtsi2sd    xmm2, ecx               ; defaulting xmm2 to 0
.sumLoop:
    cmp     ecx, ebx                    ; break if all elements have been traversed
    jge     .afterSum
 
    mov     r8, rdi                     ; saving current position in the container in r8
    push    r8
    add     rdi, 4                      ; skipping the key value
    call    TimeToDest                  ; calculating TimeToDest
    addsd   xmm2, xmm0                  ; increasing the sum
    inc     ecx                         ; incrementing the traversed elements count
    
    pop     r8
    add     r8, 20                      ; moving to the next element
    mov     rdi, r8
    jmp     .sumLoop
.afterSum:
    movsd       xmm0, xmm2
    cvtsi2sd    xmm2, ebx               ; converting element count to double
    divsd       xmm0, xmm2              ; calculating the average value (xmm0 / xmm2)
leave
ret

; -------------------------------------------------------------------
; Function that deletes elements with TimeTODest values less than
;   an average one from the container.
; Takes following parameters:
;   rdi - pointer to the container
;   rsi - pointer to the container element count
global DeleteLessThanAvg
DeleteLessThanAvg:
section .data
    .avg    dq  0.0                     ; average TimeToDest value
section .bss
    .cont   resq  1                     ; pointer to the container
    .count  resq  1                     ; pointer to the container element count
section .text
    push    rbp                         ; function prolog
    mov     rbp, rsp
    
    mov     [.cont], rdi                ; loading the container pointer
    mov     [.count], rsi               ; loading the container element count pointer
    
    push    rdi
    push    rsi
    
    mov     rax, [.count]
    mov     rsi, [rax]                  ; moving the container element count value to rsi
    call    GetContainerAverage         ; calculating the average TimeToDest value
    movsd   [.avg], xmm0                ; saving the average value
    
    pop     rsi
    pop     rdi
    
    mov     rax, [.count]
    mov     ebx, [rax]                  ; moving the container element count value to ebx
    xor     ecx, ecx                    ; current element's index (=0)
.loopBody:
    cmp     ecx, ebx                    ; break if all elements have been traversed
    jge     .return

    mov     r8, rdi                     ; saving current position in the container to r8
    add     rdi, 4                      ; skipping the key value
    push    r8
    call    TimeToDest                  ; calculating the TimeToDest value of the element
    pop     r8
    comisd  xmm0, [.avg]
    jb      .delete                     ; deleting the element if TimeToDest is less than average
    
    jmp     .loopCont
.delete:    
    push    rbx                         ; saving current registers' state
    push    r8
    push    rcx
    push    rdi
    
    mov     rdi, r8                     ; loading current element's address (position in container)
    mov     rsi, rdi
    add     rsi, 20                     ; loading the next element's address
    xor     rdx, rdx
    mov     rax, [.count]               ; calculating the amount of bytes to be moved
    mov     edx, [rax]
    sub     edx, ecx
    dec     edx                         ; edx = amount of elements to be shifted
    imul    edx, 20                     ; multiplying by the size of elements in bytes
    
    call    memmove                     ; moving the elements to current position
    
    xor     rdx, rdx
    xor     rax, rax
    
    mov     rax, [.count]               ; decreasing the container elements count
    mov     edx, [rax]
    dec     edx
    mov     [rax], rdx
    
    pop     rdi                         ; restoring registers' state
    pop     rcx
    pop     r8
    pop     rbx
    
    dec     ecx                         ; decrementing the traversed elements count
                                        ; (for it to remain the same on the next iteration)
    
    mov     rax, [.count]
    mov     ebx, [rax]                  ; updating the ebx value
    sub     r8, 20                      ; moving to the previous element
                                        ; (to remain on the same position on the next iteration)
.loopCont:
    inc     ecx                         ; incremeting the traversed elements count
    
    add     r8, 20                      ; moving to the next element
    mov     rdi, r8
    jmp     .loopBody
.return:
leave
ret
    