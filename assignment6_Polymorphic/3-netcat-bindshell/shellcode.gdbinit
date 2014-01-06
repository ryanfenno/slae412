set disassembly-flavor intel
#break main
#break *0x0804a040
break *0x0804a051
define hook-stop
  disassemble $eip,+20
  info registers
  x/16x $esp
  #x/26x $esi
  x/3s $esi
end
run
