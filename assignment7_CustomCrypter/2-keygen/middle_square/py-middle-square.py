#!/usr/bin/python

nseqmax = 0xff

for seed in range(0xffff,-1,-1):
    rand = seed
    print "****"
    print hex(seed)
    print "****"
    for _ in range(nseqmax):
        rand = (rand**2 / 0x100) % 0x10000
        print hex(rand)
        if rand == 0:
            break
