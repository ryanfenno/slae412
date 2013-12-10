set disassembly-flavor intel
break _start
define hook-stop
  disassemble $eip
  info registers
  x/8x $esp
end
run
