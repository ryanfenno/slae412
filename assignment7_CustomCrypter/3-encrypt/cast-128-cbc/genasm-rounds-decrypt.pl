#!/usr/bin/perl
#
# genasm-rounds.pl
#
# generate the nasm code for the CAST-128 decryption
# rounds, 16 in total; see RFC 2144, Section 2/2.2, for
# details
#
use warnings;
use strict;

for my $i (reverse 1..16) {
    print   "    ; ---- Round $i\n";

    my $Kmi = 0x20 + 4*($i - 1);
    my $Kri = 0x60 + 4*($i - 1);
    printf "    mov  eax, [esp + 0x%x]   ; Km%u (K%u)\n", $Kmi, $i, $i;
    printf "    mov  cl,  [esp + 0x%x]   ; Kr%u (K%u)\n", $Kri, $i, $i+16;

    my $typeCheck = $i % 3;
    my @subs;
    if ($typeCheck == 1) {
        print "    ; -------- type 1 round function +/^/-/+\n";
        @subs = ('add', $i, '+', ($i-1), ($i-1), $i,
                 $i, $i,
                 'xor', '^',
                 'sub', '^', '-',
                 'add', '^', '-', '+',
                 $i, ($i-1), $i, ($i-1), ($i-1));
    } elsif ($typeCheck == 2) {
        print "    ; -------- type 2 round function ^/-/+/^\n";
        @subs = ('xor', $i, '^', ($i-1), ($i-1), $i,
                 $i, $i,
                 'sub', '-',
                 'add', '-', '+',
                 'xor', '-', '+', '^',
                 $i, ($i-1), $i, ($i-1), ($i-1));
    } elsif ($typeCheck == 0) {
        print "    ; -------- type 3 round function -/+/^/-\n";
        @subs = ('sub', $i, '-', ($i-1), ($i-1), $i,
                 $i, $i,
                 'add', '+',
                 'xor', '+', '^',
                 'sub', '+', '^', '-',
                 $i, ($i-1), $i, ($i-1), ($i-1));
    }
    printf "    %s  eax, edi            ; (Km%u %s D) mod 2**32, D = R%u, R%u = L%u\n"     .
           "    rol  eax, cl             ; I = ((Km%u + D) mod 2**32) << Kr%u\n"           .
           "    push eax                 ; I\n"                                            .
           "    mov  cl,  [esp + 0x3]    ; Ia\n"                                           .
           "    mov  eax, [ecx*4 + S1]   ; S1[Ia]\n"                                       .
           "    mov  cl,  [esp + 0x2]    ; Ib\n"                                           .
           "    mov  ebx, [ecx*4 + S2]   ; S2[Ib]\n"                                       .
           "    %s  eax, ebx            ; S1[Ia] %s S2[Ib]\n"                              .
           "    mov  cl,  [esp + 0x1]    ; Ic\n"                                           .
           "    mov  ebx, [ecx*4 + S3]   ; S3[Ic]\n"                                       .
           "    %s  eax, ebx            ; (S1[Ia] %s S2[Ib]) %s S3[Ic]\n"                  .
           "    mov  cl,  [esp + 0x0]    ; Id\n"                                           .
           "    mov  ebx, [ecx*4 + S4]   ; S4[Id]\n"                                       .
           "    %s  eax, ebx            ; f = ((S1[Ia] %s S2[Ib]) %s S3[Ic]) %s S4[Id]\n"  .
           "    pop  ebx                 ; junk I\n"                                       .
           "    mov  ebx, [esp + 0xA4]   ; R%u\n"                                          .
           "    xor  eax, ebx            ; L%u = R%u ^ f\n"                                .
           "    xchg eax, edi\n"                                                           .
           "    mov  [esp + 0xA0], edi   ; L%u\n"                                          .
           "    mov  [esp + 0xA4], eax   ; R%u\n", @subs;
}

