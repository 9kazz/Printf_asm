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
                    push 'A'
                    call Printf
                    pop rax

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

Printf:             push rbp
                    mov rbp, rsp

                    push_ rsi, rdi

                    mov rdi, Str_buf
                    xor rcx, rcx                ; arguments counter

get_1char:          cmp byte [rsi], 0
                        je end
                    cmp byte [rsi], '%'
                        je specifier_handle
                    lodsb 
                    stosb
                    jmp get_1char
                    
end:                mov rsi, Str_buf                ; string adr
                    call Strlen                     ; rdx = string length
                    mov rax, 0x01                   ; write64 (rdi, rsi, rdx) ... r10, r8, r9
                    mov rdi, 1                      ; stdout
                    syscall

                    pop rbp
                    pop_ rdi, rsi
                    ret

specifier_handle:   inc rsi                         ; rsi -> specifier (char after "%")
                    mov bl, [rsi]
                    inc rsi                         ; skip specifier 

                    sub bl, 'b' 
                    jl case_default
                    cmp bl, 1
                    ja case_default

                    jmp [Jmp_table + rbx * 8]       ; jump to appropriate case

;                   === CASES ===
case_c:             mov rax, [rbp + 16 + rcx * 8]   ; get next argument
                    stosb
                    jmp get_1char

case_default:       jmp get_1char                   ; continue reading


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

Jmp_table:          dq case_default
                    dq case_c
Str_buf             db 100 dup(0)
String:             db "Hello world!%c", 0