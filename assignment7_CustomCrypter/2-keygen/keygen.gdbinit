set disassembly-flavor intel
break _start
break midsqLoop
define hook-stop
  disassemble
  info registers
  x/16x $esp
  #x/s   $edi
end
run
set $esp = $esp - 0x1000
