#!/bin/sh
SHELLCODE=$(cat openssl-tool-encrypting.in | xxd -r)
#KEY=E2FF473AD139FE1E3F8BC5B5B0111761
#IV=2292AB1B5D14D789
KEY=0123456712345678234567893456789A
IV=0
cat openssl-tool-decrypting.in | xxd -r | head -c 24 |
    openssl enc -d -v -cast5-cbc -nosalt \
    -K $KEY -iv $IV | \
    head -c 24
