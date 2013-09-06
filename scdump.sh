#!/bin/bash
# see: http://www.commandlinefu.com/commands/view/6051/get-all-shellcode-on-binary-file-from-objdump

shellcode=$(objdump -d $1 | \
    grep '[0-9a-f]:'| grep -v 'file' | \
    cut -f2 -d: | cut -f1-6 -d' ' | \
    tr -s ' ' | tr '\t' ' ' | \
    sed 's/ $//g' | sed 's/ /\\x/g' | \
    paste -d '' -s)

# shellcode in c-style
count=0
printf "unsigned char s[] =\n\""
for byte in $(echo $shellcode | sed 's/\\x/ /g'); do
    (( count++ ))
    printf "\\"
    printf "x$byte"

    if [ $(( $count % 15 )) -eq 0 ]; then
        printf "\"\n\""
    fi
done
printf "\"\n"

# count bytes
length=$(echo -ne $shellcode | wc -c)
echo "[scdump] shellcode length: $length"

# test for null bytes
num_null=$(echo $shellcode | grep '\\x00' | wc -c)
if [ $num_null -gt 0 ]; then
    echo "[scdump] null byte(s) present!"
fi
