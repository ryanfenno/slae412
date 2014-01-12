set disassembly-flavor intel
break _start
define hook-stop
  disassemble
  info registers
  x/16x $esp
  x/s   $edi
end
run
set $esp = $esp - 0x1000
#disassemble 0x0804a042,+10
#continue
#disassemble 0x0804a04c,+18
#continue
#disassemble 0x0804a05e,+14
#continue
#disassemble 0x0804a06c,+12
