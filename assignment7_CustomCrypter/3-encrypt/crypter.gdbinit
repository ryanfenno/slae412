set disassembly-flavor intel
#break _start
#break *0x080492c4
#break *0x0804a13f
#break initPlain
break ENDDECRYPT
#break STORE
define hook-stop
  disassemble $eip,+25
  info registers
  x/66x $esp
end
run
