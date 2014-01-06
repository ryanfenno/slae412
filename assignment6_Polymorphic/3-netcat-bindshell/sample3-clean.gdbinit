set disassembly-flavor intel
break _start
#break *0x080480d0
define hook-stop
  disassemble $eip,+20
  info registers
  x/16x $esp
  x/s $esi
end
run
