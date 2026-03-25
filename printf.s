section .text

global my_printf                                    ; entry point name for ld

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

%macro Dump_Str_buf 0
                    push_ rsi, rdx, rcx
                    mov rsi, Str_buf                ; string adr
                    mov rdx, rdi                    
                    sub rdx, Str_buf                ; rdx = string length
                    mov rax, 0x01                   ; write64 (rdi, rsi, rdx) ... r10, r8, r9
                    mov rdi, 1                      ; stdout
                    syscall
                    pop_ rcx, rdx, rsi
                    mov rdi, Str_buf
%endmacro                    
            
;==================================================================================================================                    

;                   MY_PRINTF
;------------------------------------------------------------------------------------------------------------------
; Descr:    print string into stdout according to format string (first argument).
;           Acceptable specifiers:
;           %b -- print number as binary
;           %o -- print number as octal
;           %d -- print number as decimal (only sign 32-bit numbers)
;           %x -- print number as hexadecimal
;           %c -- print character (according to ASCII conversation)
;           %s -- print string terminated by /0
;           %% -- print "%"
; Entry:    variable count of arguments (format, 5 args in regisgters, others in the stack)
;           rdi -> format string (must be the first argument)
;           rsi, rdx, rcx, r8, r9 -- firth 5 arguments 
;           other arguments in the stack
; Exit:     --
; Exp:      --
; Destr:    --
;------------------------------------------------------------------------------------------------------------------

my_printf:          push_ r9, r8, rcx, rdx, rsi, rdi

                    pop rsi                         ; get string adr 

                    push rbp
                    mov rbp, rsp

                    push_ rdi, rax                  ; save registers

                    mov rdi, Str_buf
                    xor rcx, rcx                    ; arguments counter

check_buf_size:     cmp rdi, Str_buf + Str_buf_size
                        jb get_char
                    Dump_Str_buf

get_char:           cmp byte [rsi], 0
                        je end_printf
                    cmp byte [rsi], '%'
                        je Specifier_handle
                    lodsb 
                    stosb
                    jmp check_buf_size
                    
end_printf:         Dump_Str_buf
                    pop_ rax, rdi                   ; recover saved registers
                    pop rbp
                    pop_ rsi, rdx, rcx, r8, r9
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
                    cmp rcx, 6                      ; according to Stdcall, first 6 arguments saved in registers
                        jne .skip_return_adr
                    inc rcx
                    
.skip_return_adr:   jmp [Jmp_table + rbx * 8]       ; jump to appropriate case

;                   === CASES ===

case_x:             mov rbx, 16
                        jmp case_xo
case_o:             mov rbx, 8
                        jmp case_xo
case_b:             mov rdx, [rbp + rcx * 8]   ; get next argument   
                    cmp rdx, 1 << Extra_space + 1
                        jb .continue_b
                    Dump_Str_buf
                                  
    .continue_b:    mov rbx, 2
                    call Itoa_xob                
                    jmp check_buf_size

case_xo:            mov rdx, [rbp + rcx * 8]  
                    call Itoa_xob                
                    jmp check_buf_size

case_c:             mov rax, [rbp + rcx * 8]
                    stosb
                    jmp check_buf_size

case_d:             mov eax, [rbp + rcx * 8]
                    call Itoa_d
                    jmp check_buf_size

case_s:             push rsi
                    mov rsi, [rbp + rcx * 8]   
                    call Display_str
                    pop rsi
                    jmp check_buf_size

case_percent:       mov al, '%'       
                    stosb
                    jmp check_buf_size

case_default:       jmp check_buf_size             ; continue reading

;                   ITOA_XOB
;------------------------------------------------------------------------------------------------------------------
; Descr:    convert number into other number system (16-, 8- or 2-bit only) and store it as a string
; Entry:    rdx == number to convert
;           rbx == number system
;           rdi -> buffer for saving the string
; Exit:     rdi -> first byte in buffer after saved number
; Exp:      --
; Destr:    rax
;------------------------------------------------------------------------------------------------------------------

Itoa_xob:           push_ rbx, rcx, rdx

                    xor cl, cl                      ; cl = bits in the one digit of appropriate digit system
                    mov ch, 64                      ; ch = bit counter

                    test rdx, rdx                   ; check if number is zero
                        jnz .check_system8
                    mov al, '0'
                    stosb
                    jmp .end

.check_system8:     cmp rbx, 8
                        jne .itoa
                    test rdx, 1<<63
                        jz .align8
                    mov al, 1
                    stosb
    .align8:        shl rdx, 1
                    dec ch

.itoa:              dec rbx                         ; bit-mask
                    mov rax, rbx                    ; copy mask

.get_shift:         inc cl
                    shr rax, 1
                        jnz .get_shift

                    ror rbx, cl                     ; new bit-mask

.del_lead_0:        test rdx, rbx
                        jnz .get_digit
                    shl rdx, cl
                    sub ch, cl
                    jmp .del_lead_0

.get_digit:         mov rax, rdx                    ; copy number
                    shl rdx, cl
                    sub ch, cl
                    and rax, rbx
                    rol rax, cl

                    cmp rax, 9
                        ja .trans2letter

    .trans2digit:   add rax, '0'                    ; rax = ASCII digit
    .end_of_cycle:  stosb                           ; store ASKII in buffer

                    test ch, ch
                        jnz .get_digit

.end:               pop_ rdx, rcx, rbx
                    ret

    .trans2letter:  add rax, 'A' - 10
                    jmp .end_of_cycle               ; rax = ASKII letter

;                   ITOA_D
;------------------------------------------------------------------------------------------------------------------
; Descr:    convert number into decimal number system and store it as a string
; Entry:    rax == number to convert
;           rdi -> buffer for saving the string
; Exit:     rdi -> first byte in buffer after saved number
; Exp:      created Temp_num_buf (capacity not less than 20 bytes) to temporary saving and reversing number
; Destr:    al
;------------------------------------------------------------------------------------------------------------------
Itoa_d:             push_ rbx, rdx, rsi

                    mov ebx, 10
                    mov rsi, Temp_num_buf

                    cmp eax, 0                      ; check sign bit
                        jns .get_digit
                    mov dl, '-'
                    mov [rdi], dl
                    inc rdi

                    neg rax
                    

.get_digit:         xor edx, edx
                    div ebx
                    add dl, '0'
                    mov [rsi], dl
                    test eax, eax
                        jz .print_buf
                    inc rsi
                    jmp .get_digit

.print_buf:         mov al, [rsi]
                    dec rsi
                    stosb
                    cmp rsi, Temp_num_buf
                    jae .print_buf

                    pop_ rsi, rdx, rbx
                    ret

;                   DISPLAY_STR
;------------------------------------------------------------------------------------------------------------------
; Descr:    store string in Str_buf
; Entry:    rsi -> string to store ending by terminate character \0
;           rdi -> buffer for saving the string
; Exit:     rdi -> first byte in buffer after saved number
; Exp:      --
; Destr:    al
;------------------------------------------------------------------------------------------------------------------
Display_str:        
.check_buf_size:    cmp rdi, Str_buf + Str_buf_size
                        jb .get_char
                    Dump_Str_buf

.get_char:          cmp byte [rsi], 0
                        je .end
                    lodsb 
                    stosb
                    jmp .check_buf_size

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

Str_buf_size        equ 128
Extra_space         equ 32                          ; extra space to print numbers 
Str_buf             db Str_buf_size + Extra_space dup(0)