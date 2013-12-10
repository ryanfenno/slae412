set disassembly-flavor intel
break *0x0804a047
break *0x0804a063
break *0x0804a09a
break *0x0804a09f
define hook-stop
  info registers
  x/16x $esp
end
run
continue
continue
x/s 0x804a06b
continue
