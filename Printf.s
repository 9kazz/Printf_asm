section .text

global _start                                   ; entry point name for ld

;=================  MACROSES  =====================================================================================                    

%macro push_ 1-*
                    %rep %0
                        push %1
                        %rotate 1
                    %endrep    
%endmacro
                    
%macro pop_ 1-*
                    %rep %0
                        pop %1
                        %rotate 1
                    %endrep    
%endmacro
            
;==================================================================================================================                    
_start:             mov rsi, String
                    call Printf

                    mov rax, 0x3C      ; exit64 (rdi)
                    xor rdi, rdi
                    syscall

;                   PRINTF
;------------------------------------------------------------------------------------------------------------------
; Descr:
; Entry:    rsi -> printing string
; Exit:     --
; Exp:      --
; Destr:    rax
;------------------------------------------------------------------------------------------------------------------

Printf:             push_ rsi, rdi

                    mov rdi, Str_buf

.get_1char:         cmp byte [rsi], 0
                        je .end
                    cmp byte [rsi], '%'
                        je .end
                    lodsb 
                    stosb
                    loop .get_1char
                    
.end:               mov rsi, Str_buf            ; string adr
                    call Strlen                 ; rdx = string length
                    mov rax, 0x01               ; write64 (rdi, rsi, rdx) ... r10, r8, r9
                    mov rdi, 1                  ; stdout
                    syscall

                    pop_ rdi, rsi
                    ret

;                   STRLEN
;------------------------------------------------------------------------------------------------------------------
; Descr:    returns length of the string terminated by ASCII 0 byte
; Entry:    rsi -> string
; Exit:     rdx == string length
; Exp:      --
; Destr:    --
;------------------------------------------------------------------------------------------------------------------

Strlen:             push rsi

                    mov rdx, rsi

.check_1char:       cmp byte [rsi], 0
                        je .end
                    inc rsi
                    jmp .check_1char

.end:               sub rsi, rdx
                    mov rdx, rsi

                    pop rsi
                    ret

section .data

Str_buf             db 50 dup(0)
String:             db "Hello world!", 0