set disassembly-flavor intel
break _start
#break *0x080498c7
define hook-stop
  disassemble $eip,+50
  info registers
  x/44x $esp
end
run
