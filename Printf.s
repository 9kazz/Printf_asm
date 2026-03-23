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
                    push String1
                    push 0x222
                    push 111
                    call Printf
                    pop_ rax, rax, rax

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
                    xor rcx, rcx                    ; arguments counter

get_char:           cmp byte [rsi], 0
                        je end_printf
                    cmp byte [rsi], '%'
                        je Specifier_handle
                    lodsb 
                    stosb
                    jmp get_char
                    
end_printf:         mov rsi, Str_buf                ; string adr
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

                    cmp bl, '%' 
                        je case_percent

                    sub bl, 'b' 
                        jl case_default
                    cmp bl, 'x' - 'b'
                        ja case_default

                    inc rcx
                    jmp [Jmp_table + rbx * 8]       ; jump to appropriate case

;                   === CASES ===

case_x:             mov rbx, 16
                        jmp case_xob
case_o:             mov rbx, 8
                        jmp case_xob
case_b:             mov rbx, 2

case_xob:           mov rdx, [rbp + 8 + rcx * 8]   ; get next argument                 
                    call Itoa_xob                
                    jmp get_char                    

case_c:             mov rax, [rbp + 8 + rcx * 8]
                    stosb
                    jmp get_char

case_d:             mov rax, [rbp + 8 + rcx * 8]
                    call Itoa_d
                    jmp get_char

case_s:             push rsi
                    mov rsi, [rbp + 8 + rcx * 8]   
                    call Display_str
                    pop rsi
                    jmp get_char

case_percent:       mov al, '%'       
                    stosb
                    jmp get_char

case_default:       jmp get_char                   ; continue reading


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

                    test rdx, rdx                   ; check if number is zero
                    jnz .check_system8
                    xor al, al
                    stosb
                    jmp .end

.check_system8:     cmp rbx, 8
                    jne .itoa
                    test rdx, 1<<63
                    jz .align8
                    mov al, 1
                    stosb
    .align8:        shl rdx, 1

.itoa:              dec rbx                         ; bit-mask
                    mov rax, rbx                    ; copy mask
                    xor cx, cx                      ; cl = bits in the one digit of appropriate digit system
                             
.get_shift:         inc cl
                    shr rax, 1
                    jnz .get_shift

                    ror rbx, cl                     ; new bit-mask

.del_lead_0:        test rdx, rbx
                    jnz .get_digit
                    shl rdx, cl
                    jmp .del_lead_0

.get_digit:         mov rax, rdx                    ; copy number
                    shl rdx, cl
                    and rax, rbx
                    rol rax, cl

                    cmp rax, 9
                    ja .trans2letter

    .trans2digit:   add rax, '0'                    ; rax = ASCII digit
    .end_of_cycle:  stosb                           ; store ASKII in buffer

                    test rdx, rdx
                    jnz .get_digit

.end:               pop_ rdx, rcx, rbx
                    ret

    .trans2letter:  add rax, 'A' - 10
                    jmp .end_of_cycle               ; rax = ASKII letter

;                   ITOA_D
;------------------------------------------------------------------------------------------------------------------
; Descr:    convert number into other number system (16-, 8- or 2-bit only) and store it as a string
; Entry:    rax == number to convert
;           rdi -> buffer for saving the string
; Exit:     rdi -> 1st byte in buffer after saved number
; Exp:      Temp_num_buf ;TODO
; Destr:    --
;------------------------------------------------------------------------------------------------------------------
Itoa_d:             push_ rbx, rcx, rdx, rsi

                    mov rbx, 10
                    mov rsi, Temp_num_buf
                    mov rcx, rsi

.get_digit:         xor rdx, rdx
                    div rbx
                    add dl, '0'
                    mov [rsi], dl
                    test rax, rax
                    jz .print_buf
                    inc rsi
                    jmp .get_digit

.print_buf:         mov al, [rsi]
                    dec rsi
                    stosb
                    cmp rsi, rcx
                    jae .print_buf

                    pop_ rsi, rdx, rcx, rbx
                    ret

;                   DISPLAY_STR
;------------------------------------------------------------------------------------------------------------------
; Descr:    convert number into other number system (16-, 8- or 2-bit only) and store it as a string
; Entry:    rsi -> string to display ending by terminate character \0
;           rdi -> buffer for saving the string
; Exit:     rdi -> 1st byte in buffer after saved number
; Exp:      Temp_num_buf ;TODO
; Destr:    al
;------------------------------------------------------------------------------------------------------------------
Display_str:        
.get_char:          cmp byte [rsi], 0
                        je .end
                    lodsb 
                    stosb
                    jmp .get_char

.end:               ret

;=================  DATA  =========================================================================================                    
section .data

Temp_num_buf        db 20 dup(0)
Jmp_table:          dq case_b
                    dq case_c
                    dq case_d
                    dq 'o' - 'd' - 1 dup(case_default)
                    dq case_o
                    dq 's' - 'o' - 1 dup(case_default)
                    dq case_s                         
                    dq 'x' - 's' - 1 dup(case_default)                                   
                    dq case_x
Str_buf             db 100 dup(0)
String:             db "Hello world!(%d)(%x)(%s)%%%%%%", 0
String1:             db "777", 0