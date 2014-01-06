set disassembly-flavor intel
break *0x0804a040
define hook-stop
  disassemble $eip,+16
  info registers
  x/8x $esp
end
run
