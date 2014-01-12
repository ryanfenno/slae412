set disassembly-flavor intel
#break main
break _start
define hook-stop
  disassemble
  info registers
  x/16x $esp
end
run
