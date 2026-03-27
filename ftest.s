section .text
global _start

_start:             mov rax, 0x3FE0000000000000
                    mov rbx, 0x3FF0000000000000

                    movq xmm10, rax
                    call Get_int_part

                    movq xmm10, rbx
                    call Get_int_part

                    mov rax, 0x3C      ; exit64 (rdi)
                    xor rdi, rdi
                    syscall

Get_int_part:       ;push_ rbx, rcx, rdx, r8

                    movq rax, xmm10

                    mov rbx, 0x7FF0000000000000
                    and rbx, rax                    ; exponent
                    sub rbx, 1023

                    mov rdx, 0x000FFFFFFFFFFFFF
                    and rdx, rax                    ; mantissa

                    mov r8, 1 << 63
                    xor rcx, rcx

                    test rdx, rdx
                        jz .mantissa_0

.count_lead_zero:   test rdx, r8
                        jz .continue
                    jmp .break
    .continue:      shr r8, 1
                    loop .count_lead_zero           ; rcx = - count_of_lead_zero

                    add rcx, 64
                    sub rcx, rbx                    ; rcx = count of shr
                    shr rdx, rcx

                    mov r8, 1
                    mov rcx, rbx
                    shl r8, rcx
.mantissa_0:        add rdx, r8

.break:            ; pop_ r8, rdx, rcx, rbx
                    ret
