section .code

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
_start:             mov edi, String
                    call Printf

                    mov eax, 1                  ; exit (ebx)
                    xor ebx, ebx
                    int 0x80

;                   PRINTF
;------------------------------------------------------------------------------------------------------------------
; Descr:
; Entry:    edi -> printing string
; Exit:     --
; Exp:      --
; Destr:    eax
;------------------------------------------------------------------------------------------------------------------

Printf:             push_ ebx, ecx, edx

                    call Strlen
                    mov edx, eax                ; string length
                    mov ecx, edi                ; string adr
                    mov ebx, 1                  ; stdout

                    mov eax, 4                  ; write (ebx, ecx, edx)
                    int 0x80

                    pop_ edx, ecx, ebx
                    ret

;                   STRLEN
;------------------------------------------------------------------------------------------------------------------
; Descr:    returns length of the string terminated by ASCII 0 byte
; Entry:    edi -> string
; Exit:     eax == string length
; Exp:      --
; Destr:    eax
;------------------------------------------------------------------------------------------------------------------

Strlen:             push edi

                    mov edx, edi
                    mov al, '%'
                    mov ah, 0

.check_1char:       cmp al, [edi]
                        jz .end
                    cmp ah, [edi]
                        jz .end
                    inc edi
                    jmp .check_1char

.end:               sub edi, edx
                    mov eax, edi

                    pop edi
                    ret

section .data

String:             db "Hello world!", 0