; -------------------------------------------------------------------
;   macros.inc - file containing macros' definitions.
; -------------------------------------------------------------------

extern fprintf
extern stdout
extern strcmp
extern fscanf
extern fopen
extern fclose
extern rand

extern InContainer
extern InRndContainer
extern OutContainer
extern RandInBounds
extern DeleteLessThanAvg
extern PrintTime

; -------------------------------------------------------------------
; Prints a null-terminated string saved in buffer.
; Takes following parameters:
;   %1 - output stream
;   %2 - string pointer
%macro PrintBufData 2
    section .text
        mov     rdi, %1                     ; loading output stream pointer
        mov     rsi, %2                     ; loading string for output
        xor     rax, rax                    ; no SSE registers used
        call    fprintf                     ; printing the string
%endmacro

; -------------------------------------------------------------------
; Compares two given strings and returns result to rax.
; Takes following parameters:
;   %1 - string 1
;   %2 - string 2
%macro StrCompare 2
    section .text
        mov     rdi, %1                     ; loading string 1
        mov     rsi, %2                     ; loading string 2
        call    strcmp                      ; comparing strings via strcmp
%endmacro

; -------------------------------------------------------------------
; Opens the file with given access parameters and passes the stream
;   pointer down to given destination buffer.
; Takes following parameters:
;   %1 - file path
;   %2 - access parameter
;   %3 - destination buffer
%macro OpenFileToDest 3
    section .data
        %%rw    db  %2,0                    ; access parameter string
    section .text
        mov     rdi, %1                     ; loading file path
        mov     rsi, %%rw                   ; loading access parameter string
        xor     rax, rax                    ; no SSE registers used
        call    fopen                       ; opening the file
        mov     %3, rax                     ; saving to buffer
%endmacro

; -------------------------------------------------------------------
; Closes the file stream on given address.
; Takes following parameters:
;   %1 - file stream pointer
%macro CloseFile 1
    section .text
        mov     rdi, %1                     ; loading stream pointer
        xor     rax, rax                    ; no SSE registers used
        call    fclose                      ; closing the stream
%endmacro

; -------------------------------------------------------------------
; Reads a number from given stream.
; Takes following parameters:
;   %1 - file stream pointer
;   %2 - destination pointer
%macro NumReadFromStream 2
    section .data
        %%sfmt  db  "%d", 0x0               ; read format
    section .text
        mov     rdi, %1                     ; loading stream pointer
        mov     rsi, %%sfmt
        mov     rdx, %2                     ; loading destination pointer
        xor     rax, rax                    ; no SSE registers used
        call    fscanf                      ; reading the value
%endmacro

; -------------------------------------------------------------------
; Exits the program with given error code.
; Takes following parameters:
;   %1 - error code
%macro Exit 1
    section .text
        ; performing sys_exit syscall
        mov     rax, 60
        mov     rdi, %1
        syscall
%endmacro