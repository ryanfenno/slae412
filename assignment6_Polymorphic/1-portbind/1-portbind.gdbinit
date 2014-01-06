set disassembly-flavor intel
break _start
define hook-stop
  disassemble $eip,+16
  info registers
  x/8x $esp
end
run
