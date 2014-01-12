set disassembly-flavor intel
break _start
#break *0x080492c4
define hook-stop
  disassemble $eip,+50
  info registers
  x/48x $esp
end
run
