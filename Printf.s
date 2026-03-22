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
                    push 0x0
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
                        je Specifier_handle
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

Specifier_handle:   inc rsi                         ; rsi -> specifier (char after "%")
                    mov bl, [rsi]
                    inc rsi                         ; skip specifier 

                    sub bl, 'b' 
                    jl case_default
                    cmp bl, 2
                    ja case_default

                    jmp [Jmp_table + rbx * 8]       ; jump to appropriate case

;                   === CASES ===
case_c:             mov rax, [rbp + 16 + rcx * 8]   ; get next argument
                    stosb
                    jmp get_1char

case_x:             mov rdx, [rbp + 16 + rcx * 8]   ; get next argument
                    mov rbx, 16
                    call Itoa_xob
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

;                   ITOA_XOB
;------------------------------------------------------------------------------------------------------------------
; Descr:    convert number into other number system (16-, 8- or 2-bit only) and store it as a string
; Entry:    rdx == number to convert
;           rbx == number system
;           rdi -> buffer for saving the string
; Exit:     rdi -> 1st byte in buffer after saved number
; Exp:      --
; Destr:    --
;------------------------------------------------------------------------------------------------------------------

Itoa_xob:           push_ rbx, rcx, rdx

                    dec rbx                         ; bit-mask
                    mov rax, rbx                    ; copy mask
                    xor cx, cx                      ; cl = bits in the one digit of appropriate digit system
                                                    ; ch = cur count of handled bits
.get_shift:         inc cl
                    shr rax, 1
                    jnz .get_shift

.get_digit:         mov rax, rdx                    ; copy number
                    shr rdx, cl
                    or rax, rbx

                    cmp rax, 9
                    ja .trans2letter

    .trans2digit:   add rax, '0'                    ; rax = ASCII digit
    .end_of_cycle:  stosb                           ; store ASKII in buffer

                    add ch, cl
                    cmp ch, 64
                    jb .get_digit

                    pop_ rdx, rcx, rbx
                    ret

    .trans2letter:  add rax, 'A' - 10
                    jmp .end_of_cycle               ; rax = ASKII letter



section .data

Jmp_table:          dq case_default
                    dq case_c
                    dq case_x
Str_buf             db 100 dup(0)
String:             db "Hello world!%d", 0