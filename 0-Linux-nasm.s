;:================================================
;: 0-Linux-nasm.s                      (c)Ded,2012
;:================================================

; nasm -f elf -l 1-nasm.lst 1-nasm.s  ;  ld -s -m elf_i386 -o 1-nasm 1-nasm.o

section .code

global _start                  ; predefined entry point name for ld

_start:     mov eax, 4         ; write (ebx, ecx, edx)
            mov ebx, 1         ; stdout
            mov ecx, Msg
            mov edx, MsgLen    ; strlen (Msg)
            int 0x80
            
            mov eax, 1         ; exit (ebx)
            xor ebx, ebx
            int 0x80
            
section     .data
            
Msg:        db "__Hllwrld", 0x0a
MsgLen      equ $ - Msg

