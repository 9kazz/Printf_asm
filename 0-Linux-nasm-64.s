;:================================================
;: 0-Linux-nasm-64.s                   (c)Ded,2012
;:================================================

; nasm -f elf64 -l 1-nasm.lst 1-nasm.s  ;  ld -s -o 1-nasm 1-nasm.o

section .text

global _start                  ; predefined entry point name for ld

_start:     mov rax, 0x01      ; write64 (rdi, rsi, rdx) ... r10, r8, r9
            mov rdi, 1         ; stdout
            mov rsi, Msg
            mov rdx, MsgLen    ; strlen (Msg)
            syscall
            
            mov rax, 0x3C      ; exit64 (rdi)
            xor rdi, rdi
            syscall
            
section     .data
            
Msg:        db "__Hllwrld", 0x0a
MsgLen      equ $ - Msg
