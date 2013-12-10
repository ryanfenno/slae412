set disassembly-flavor intel
break *0x0804a04a
break *0x0804a05c
break *0x0804a06a
break *0x0804a076
define hook-stop
  info registers
  x/16x $esp
end
run
set $esp = $esp - 0x1000
disassemble 0x0804a042,+10
continue
disassemble 0x0804a04c,+18
continue
disassemble 0x0804a05e,+14
continue
disassemble 0x0804a06c,+12
