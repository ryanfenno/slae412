#!/bin/sh
SHELLCODE=$(cat openssl-tool-encrypting.in | xxd -r)
KEY=17612292C5B5B011FE1E3F8B473AD139
IV=D7897767AB1B5D14
cat openssl-tool-encrypting.in | xxd -r | head -c 32 |
    openssl enc -e -cast5-cbc -nosalt \
    -K $KEY -iv $IV | \
    head -c 32
