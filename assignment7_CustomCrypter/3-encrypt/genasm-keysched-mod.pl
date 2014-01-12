#!/usr/bin/perl
#
# genasm-keysched.pl
#
# generate the nasm code for the CAST-128 keyscheduling
# algorithm; see RFC 2144, Section 2.4, for details
#
use warnings;
use strict;

my @params = (
  # z0z1z2z3 =  x0x1x2x3 ^  S5   [xD] ^ S6   [xF] ^ S7   [xC] ^ S8   [xE] ^ S7   [x8]
  ['z0z1z2z3', 'x0x1x2x3', 'S5', 'xD', 'S6', 'xF', 'S7', 'xC', 'S8', 'xE', 'S7', 'x8'],
  # z4z5z6z7 =  x8x9xAxB ^  S5   [z0] ^ S6   [z2] ^ S7   [z1] ^ S8   [z3] ^ S8   [xA]
  ['z4z5z6z7', 'x8x9xAxB', 'S5', 'z0', 'S6', 'z2', 'S7', 'z1', 'S8', 'z3', 'S8', 'xA'],
  # z8z9zAzB =  xCxDxExF ^  S5   [z7] ^ S6   [z6] ^ S7   [z5] ^ S8   [z4] ^ S5   [x9]
  ['z8z9zAzB', 'xCxDxExF', 'S5', 'z7', 'S6', 'z6', 'S7', 'z5', 'S8', 'z4', 'S5', 'x9'],
  # zCzDzEzF =  x4x5x6x7 ^  S5   [zA] ^ S6   [z9] ^ S7   [zB] ^ S8   [z8] ^ S6   [xB]
  ['zCzDzEzF', 'x4x5x6x7', 'S5', 'zA', 'S6', 'z9', 'S7', 'zB', 'S8', 'z8', 'S6', 'xB'],
  # K1  = S5   [z8] ^ S6   [z9] ^ S7   [z7] ^ S8   [z6] ^ S5   [z2]
  ['K1', 'S5', 'z8', 'S6', 'z9', 'S7', 'z7', 'S8', 'z6', 'S5', 'z2'],
  # K2  = S5   [zA] ^ S6   [zB] ^ S7   [z5] ^ S8   [z4] ^ S6   [z6]
  ['K2', 'S5', 'zA', 'S6', 'zB', 'S7', 'z5', 'S8', 'z4', 'S6', 'z6'],
  # K3  = S5   [zC] ^ S6   [zD] ^ S7   [z3] ^ S8   [z2] ^ S7   [z9]
  ['K3', 'S5', 'zC', 'S6', 'zD', 'S7', 'z3', 'S8', 'z2', 'S7', 'z9'],
  # K4  = S5   [zE] ^ S6   [zF] ^ S7   [z1] ^ S8   [z0] ^ S8   [zC]
  ['K4', 'S5', 'zE', 'S6', 'zF', 'S7', 'z1', 'S8', 'z0', 'S8', 'zC'],
  # x0x1x2x3 =  z8z9zAzB ^  S5   [z5] ^ S6   [z7] ^ S7   [z4] ^ S8   [z6] ^ S7   [z0]
  ['x0x1x2x3', 'z8z9zAzB', 'S5', 'z5', 'S6', 'z7', 'S7', 'z4', 'S8', 'z6', 'S7', 'z0'],
  # x4x5x6x7 =  z0z1z2z3 ^  S5   [x0] ^ S6   [x2] ^ S7   [x1] ^ S8   [x3] ^ S8   [z2]
  ['x4x5x6x7', 'z0z1z2z3', 'S5', 'x0', 'S6', 'x2', 'S7', 'x1', 'S8', 'x3', 'S8', 'z2'],
  # x8x9xAxB =  z4z5z6z7 ^  S5   [x7] ^ S6   [x6] ^ S7   [x5] ^ S8   [x4] ^ S5   [z1]
  ['x8x9xAxB', 'z4z5z6z7', 'S5', 'x7', 'S6', 'x6', 'S7', 'x5', 'S8', 'x4', 'S5', 'z1'],
  # xCxDxExF =  zCzDzEzF ^  S5   [xA] ^ S6   [x9] ^ S7   [xB] ^ S8   [x8] ^ S6   [z3]
  ['xCxDxExF', 'zCzDzEzF', 'S5', 'xA', 'S6', 'x9', 'S7', 'xB', 'S8', 'x8', 'S6', 'z3'],
  # K5  = S5   [x3] ^ S6   [x2] ^ S7   [xC] ^ S8   [xD] ^ S5   [x8]
  ['K5', 'S5', 'x3', 'S6', 'x2', 'S7', 'xC', 'S8', 'xD', 'S5', 'x8'],
  # K6  = S5   [x1] ^ S6   [x0] ^ S7   [xE] ^ S8   [xF] ^ S6   [xD]
  ['K6', 'S5', 'x1', 'S6', 'x0', 'S7', 'xE', 'S8', 'xF', 'S6', 'xD'],
  # K7  = S5   [x7] ^ S6   [x6] ^ S7   [x8] ^ S8   [x9] ^ S7   [x3]
  ['K7', 'S5', 'x7', 'S6', 'x6', 'S7', 'x8', 'S8', 'x9', 'S7', 'x3'],
  # K8  = S5   [x5] ^ S6   [x4] ^ S7   [xA] ^ S8   [xB] ^ S8   [x7]
  ['K8', 'S5', 'x5', 'S6', 'x4', 'S7', 'xA', 'S8', 'xB', 'S8', 'x7'],
  # z0z1z2z3 =  x0x1x2x3 ^  S5   [xD] ^ S6   [xF] ^ S7   [xC] ^ S8   [xE] ^ S7   [x8]
  ['z0z1z2z3', 'x0x1x2x3', 'S5', 'xD', 'S6', 'xF', 'S7', 'xC', 'S8', 'xE', 'S7', 'x8'],
  # z4z5z6z7 =  x8x9xAxB ^  S5   [z0] ^ S6   [z2] ^ S7   [z1] ^ S8   [z3] ^ S8   [xA]
  ['z4z5z6z7', 'x8x9xAxB', 'S5', 'z0', 'S6', 'z2', 'S7', 'z1', 'S8', 'z3', 'S8', 'xA'],
  # z8z9zAzB =  xCxDxExF ^  S5   [z7] ^ S6   [z6] ^ S7   [z5] ^ S8   [z4] ^ S5   [x9]
  ['z8z9zAzB', 'xCxDxExF', 'S5', 'z7', 'S6', 'z6', 'S7', 'z5', 'S8', 'z4', 'S5', 'x9'],
  # zCzDzEzF =  x4x5x6x7 ^  S5   [zA] ^ S6   [z9] ^ S7   [zB] ^ S8   [z8] ^ S6   [xB]
  ['zCzDzEzF', 'x4x5x6x7', 'S5', 'zA', 'S6', 'z9', 'S7', 'zB', 'S8', 'z8', 'S6', 'xB'],
  # K9   = S5   [z3] ^ S6   [z2] ^ S7   [zC] ^ S8   [zD] ^ S5   [z9]
  ['K9',  'S5', 'z3', 'S6', 'z2', 'S7', 'zC', 'S8', 'zD', 'S5', 'z9'],
  # K10  = S5   [z1] ^ S6   [z0] ^ S7   [zE] ^ S8   [zF] ^ S6   [zC]
  ['K10', 'S5', 'z1', 'S6', 'z0', 'S7', 'zE', 'S8', 'zF', 'S6', 'zC'],
  # K11  = S5   [z7] ^ S6   [z6] ^ S7   [z8] ^ S8   [z9] ^ S7   [z2]
  ['K11', 'S5', 'z7', 'S6', 'z6', 'S7', 'z8', 'S8', 'z9', 'S7', 'z2'],
  # K12  = S5   [z5] ^ S6   [z4] ^ S7   [zA] ^ S8   [zB] ^ S8   [z6]
  ['K12', 'S5', 'z5', 'S6', 'z4', 'S7', 'zA', 'S8', 'zB', 'S8', 'z6'],
  # x0x1x2x3 =  z8z9zAzB ^  S5   [z5] ^ S6   [z7] ^ S7   [z4] ^ S8   [z6] ^ S7   [z0]
  ['x0x1x2x3', 'z8z9zAzB', 'S5', 'z5', 'S6', 'z7', 'S7', 'z4', 'S8', 'z6', 'S7', 'z0'],
  # x4x5x6x7 =  z0z1z2z3 ^  S5   [x0] ^ S6   [x2] ^ S7   [x1] ^ S8   [x3] ^ S8   [z2]
  ['x4x5x6x7', 'z0z1z2z3', 'S5', 'x0', 'S6', 'x2', 'S7', 'x1', 'S8', 'x3', 'S8', 'z2'],
  # x8x9xAxB =  z4z5z6z7 ^  S5   [x7] ^ S6   [x6] ^ S7   [x5] ^ S8   [x4] ^ S5   [z1]
  ['x8x9xAxB', 'z4z5z6z7', 'S5', 'x7', 'S6', 'x6', 'S7', 'x5', 'S8', 'x4', 'S5', 'z1'],
  # xCxDxExF =  zCzDzEzF ^  S5   [xA] ^ S6   [x9] ^ S7   [xB] ^ S8   [x8] ^ S6   [z3]
  ['xCxDxExF', 'zCzDzEzF', 'S5', 'xA', 'S6', 'x9', 'S7', 'xB', 'S8', 'x8', 'S6', 'z3'],
  # K13  = S5   [x8] ^ S6   [x9] ^ S7   [x7] ^ S8   [x6] ^ S5   [x3]
  ['K13', 'S5', 'x8', 'S6', 'x9', 'S7', 'x7', 'S8', 'x6', 'S5', 'x3'],
  # K14  = S5   [xA] ^ S6   [xB] ^ S7   [x5] ^ S8   [x4] ^ S6   [x7]
  ['K14', 'S5', 'xA', 'S6', 'xB', 'S7', 'x5', 'S8', 'x4', 'S6', 'x7'],
  # K15  = S5   [xC] ^ S6   [xD] ^ S7   [x3] ^ S8   [x2] ^ S7   [x8]
  ['K15', 'S5', 'xC', 'S6', 'xD', 'S7', 'x3', 'S8', 'x2', 'S7', 'x8'],
  # K16  = S5   [xE] ^ S6   [xF] ^ S7   [x1] ^ S8   [x0] ^ S8   [xD]
  ['K16', 'S5', 'xE', 'S6', 'xF', 'S7', 'x1', 'S8', 'x0', 'S8', 'xD'],
  # ==== AND THE SAME SET AGAIN FOR K9-K16 ====
  # z0z1z2z3 =  x0x1x2x3 ^  S5   [xD] ^ S6   [xF] ^ S7   [xC] ^ S8   [xE] ^ S7   [x8]
  ['z0z1z2z3', 'x0x1x2x3', 'S5', 'xD', 'S6', 'xF', 'S7', 'xC', 'S8', 'xE', 'S7', 'x8'],
  # z4z5z6z7 =  x8x9xAxB ^  S5   [z0] ^ S6   [z2] ^ S7   [z1] ^ S8   [z3] ^ S8   [xA]
  ['z4z5z6z7', 'x8x9xAxB', 'S5', 'z0', 'S6', 'z2', 'S7', 'z1', 'S8', 'z3', 'S8', 'xA'],
  # z8z9zAzB =  xCxDxExF ^  S5   [z7] ^ S6   [z6] ^ S7   [z5] ^ S8   [z4] ^ S5   [x9]
  ['z8z9zAzB', 'xCxDxExF', 'S5', 'z7', 'S6', 'z6', 'S7', 'z5', 'S8', 'z4', 'S5', 'x9'],
  # zCzDzEzF =  x4x5x6x7 ^  S5   [zA] ^ S6   [z9] ^ S7   [zB] ^ S8   [z8] ^ S6   [xB]
  ['zCzDzEzF', 'x4x5x6x7', 'S5', 'zA', 'S6', 'z9', 'S7', 'zB', 'S8', 'z8', 'S6', 'xB'],
  # K17  = S5   [z8] ^ S6   [z9] ^ S7   [z7] ^ S8   [z6] ^ S5   [z2]
  ['K17', 'S5', 'z8', 'S6', 'z9', 'S7', 'z7', 'S8', 'z6', 'S5', 'z2'],
  # K18  = S5   [zA] ^ S6   [zB] ^ S7   [z5] ^ S8   [z4] ^ S6   [z6]
  ['K18', 'S5', 'zA', 'S6', 'zB', 'S7', 'z5', 'S8', 'z4', 'S6', 'z6'],
  # K19  = S5   [zC] ^ S6   [zD] ^ S7   [z3] ^ S8   [z2] ^ S7   [z9]
  ['K19', 'S5', 'zC', 'S6', 'zD', 'S7', 'z3', 'S8', 'z2', 'S7', 'z9'],
  # K20  = S5   [zE] ^ S6   [zF] ^ S7   [z1] ^ S8   [z0] ^ S8   [zC]
  ['K20', 'S5', 'zE', 'S6', 'zF', 'S7', 'z1', 'S8', 'z0', 'S8', 'zC'],
  # x0x1x2x3 =  z8z9zAzB ^  S5   [z5] ^ S6   [z7] ^ S7   [z4] ^ S8   [z6] ^ S7   [z0]
  ['x0x1x2x3', 'z8z9zAzB', 'S5', 'z5', 'S6', 'z7', 'S7', 'z4', 'S8', 'z6', 'S7', 'z0'],
  # x4x5x6x7 =  z0z1z2z3 ^  S5   [x0] ^ S6   [x2] ^ S7   [x1] ^ S8   [x3] ^ S8   [z2]
  ['x4x5x6x7', 'z0z1z2z3', 'S5', 'x0', 'S6', 'x2', 'S7', 'x1', 'S8', 'x3', 'S8', 'z2'],
  # x8x9xAxB =  z4z5z6z7 ^  S5   [x7] ^ S6   [x6] ^ S7   [x5] ^ S8   [x4] ^ S5   [z1]
  ['x8x9xAxB', 'z4z5z6z7', 'S5', 'x7', 'S6', 'x6', 'S7', 'x5', 'S8', 'x4', 'S5', 'z1'],
  # xCxDxExF =  zCzDzEzF ^  S5   [xA] ^ S6   [x9] ^ S7   [xB] ^ S8   [x8] ^ S6   [z3]
  ['xCxDxExF', 'zCzDzEzF', 'S5', 'xA', 'S6', 'x9', 'S7', 'xB', 'S8', 'x8', 'S6', 'z3'],
  # K21  = S5   [x3] ^ S6   [x2] ^ S7   [xC] ^ S8   [xD] ^ S5   [x8]
  ['K21', 'S5', 'x3', 'S6', 'x2', 'S7', 'xC', 'S8', 'xD', 'S5', 'x8'],
  # K22  = S5   [x1] ^ S6   [x0] ^ S7   [xE] ^ S8   [xF] ^ S6   [xD]
  ['K22', 'S5', 'x1', 'S6', 'x0', 'S7', 'xE', 'S8', 'xF', 'S6', 'xD'],
  # K23  = S5   [x7] ^ S6   [x6] ^ S7   [x8] ^ S8   [x9] ^ S7   [x3]
  ['K23', 'S5', 'x7', 'S6', 'x6', 'S7', 'x8', 'S8', 'x9', 'S7', 'x3'],
  # K24  = S5   [x5] ^ S6   [x4] ^ S7   [xA] ^ S8   [xB] ^ S8   [x7]
  ['K24', 'S5', 'x5', 'S6', 'x4', 'S7', 'xA', 'S8', 'xB', 'S8', 'x7'],
  # z0z1z2z3 =  x0x1x2x3 ^  S5   [xD] ^ S6   [xF] ^ S7   [xC] ^ S8   [xE] ^ S7   [x8]
  ['z0z1z2z3', 'x0x1x2x3', 'S5', 'xD', 'S6', 'xF', 'S7', 'xC', 'S8', 'xE', 'S7', 'x8'],
  # z4z5z6z7 =  x8x9xAxB ^  S5   [z0] ^ S6   [z2] ^ S7   [z1] ^ S8   [z3] ^ S8   [xA]
  ['z4z5z6z7', 'x8x9xAxB', 'S5', 'z0', 'S6', 'z2', 'S7', 'z1', 'S8', 'z3', 'S8', 'xA'],
  # z8z9zAzB =  xCxDxExF ^  S5   [z7] ^ S6   [z6] ^ S7   [z5] ^ S8   [z4] ^ S5   [x9]
  ['z8z9zAzB', 'xCxDxExF', 'S5', 'z7', 'S6', 'z6', 'S7', 'z5', 'S8', 'z4', 'S5', 'x9'],
  # zCzDzEzF =  x4x5x6x7 ^  S5   [zA] ^ S6   [z9] ^ S7   [zB] ^ S8   [z8] ^ S6   [xB]
  ['zCzDzEzF', 'x4x5x6x7', 'S5', 'zA', 'S6', 'z9', 'S7', 'zB', 'S8', 'z8', 'S6', 'xB'],
  # K25   = S5   [z3] ^ S6   [z2] ^ S7   [zC] ^ S8   [zD] ^ S5   [z9]
  ['K25',  'S5', 'z3', 'S6', 'z2', 'S7', 'zC', 'S8', 'zD', 'S5', 'z9'],
  # K26  = S5   [z1] ^ S6   [z0] ^ S7   [zE] ^ S8   [zF] ^ S6   [zC]
  ['K26', 'S5', 'z1', 'S6', 'z0', 'S7', 'zE', 'S8', 'zF', 'S6', 'zC'],
  # K27  = S5   [z7] ^ S6   [z6] ^ S7   [z8] ^ S8   [z9] ^ S7   [z2]
  ['K27', 'S5', 'z7', 'S6', 'z6', 'S7', 'z8', 'S8', 'z9', 'S7', 'z2'],
  # K28  = S5   [z5] ^ S6   [z4] ^ S7   [zA] ^ S8   [zB] ^ S8   [z6]
  ['K28', 'S5', 'z5', 'S6', 'z4', 'S7', 'zA', 'S8', 'zB', 'S8', 'z6'],
  # x0x1x2x3 =  z8z9zAzB ^  S5   [z5] ^ S6   [z7] ^ S7   [z4] ^ S8   [z6] ^ S7   [z0]
  ['x0x1x2x3', 'z8z9zAzB', 'S5', 'z5', 'S6', 'z7', 'S7', 'z4', 'S8', 'z6', 'S7', 'z0'],
  # x4x5x6x7 =  z0z1z2z3 ^  S5   [x0] ^ S6   [x2] ^ S7   [x1] ^ S8   [x3] ^ S8   [z2]
  ['x4x5x6x7', 'z0z1z2z3', 'S5', 'x0', 'S6', 'x2', 'S7', 'x1', 'S8', 'x3', 'S8', 'z2'],
  # x8x9xAxB =  z4z5z6z7 ^  S5   [x7] ^ S6   [x6] ^ S7   [x5] ^ S8   [x4] ^ S5   [z1]
  ['x8x9xAxB', 'z4z5z6z7', 'S5', 'x7', 'S6', 'x6', 'S7', 'x5', 'S8', 'x4', 'S5', 'z1'],
  # xCxDxExF =  zCzDzEzF ^  S5   [xA] ^ S6   [x9] ^ S7   [xB] ^ S8   [x8] ^ S6   [z3]
  ['xCxDxExF', 'zCzDzEzF', 'S5', 'xA', 'S6', 'x9', 'S7', 'xB', 'S8', 'x8', 'S6', 'z3'],
  # K29  = S5   [x8] ^ S6   [x9] ^ S7   [x7] ^ S8   [x6] ^ S5   [x3]
  ['K29', 'S5', 'x8', 'S6', 'x9', 'S7', 'x7', 'S8', 'x6', 'S5', 'x3'],
  # K30  = S5   [xA] ^ S6   [xB] ^ S7   [x5] ^ S8   [x4] ^ S6   [x7]
  ['K30', 'S5', 'xA', 'S6', 'xB', 'S7', 'x5', 'S8', 'x4', 'S6', 'x7'],
  # K31  = S5   [xC] ^ S6   [xD] ^ S7   [x3] ^ S8   [x2] ^ S7   [x8]
  ['K31', 'S5', 'xC', 'S6', 'xD', 'S7', 'x3', 'S8', 'x2', 'S7', 'x8'],
  # K32  = S5   [xE] ^ S6   [xF] ^ S7   [x1] ^ S8   [x0] ^ S8   [xD]
  ['K32', 'S5', 'xE', 'S6', 'xF', 'S7', 'x1', 'S8', 'x0', 'S8', 'xD'],
);

my @endianMap = ('3', '2', '1', '0',
                 '7', '6', '5', '4',
                 'B', 'A', '9', '8',
                 'F', 'E', 'D', 'C');

my @keyAddresses = ('20', '24', '28', '2C',  # K1  - K4
                    '30', '34', '38', '3C',  # K5  - K8
                    '40', '44', '48', '4C',  # K9  - K12
                    '50', '54', '58', '5C',  # K13 - K16
                    '60', '64', '68', '6C',  # K17 - K20
                    '70', '74', '78', '7C',  # K21 - K24
                    '80', '84', '88', '8C',  # K24 - K28
                    '90', '94', '98', '9C'); # K28 - K32

for my $i ( 0 .. $#params ) {
    # string vars to be reset for each param set
    my $espOffset = '';
    my $term = '';
    my $j;

    my $key2Calc = "$params[$i][0]";
    print "    ; ---- $key2Calc\n"; # header

    # intermediate key term (for intermediate key calcs only)
    my $firstTerm = $params[$i][1];
    my $currentCalc = "";
    if ( $firstTerm =~ /^[xz]/ ) {
        $currentCalc = $firstTerm;
        if ( $firstTerm =~ /^x/ ) { 
            $espOffset .= '0';
        } elsif ( $firstTerm =~ /^z/ ) { 
            $espOffset .= '1';
        }
        $espOffset .= "$1" if ( $firstTerm =~ /^[xz]([0-9A-F])/ );
        print "    mov eax, [esp + 0x$espOffset]   ; $params[$i][1]\n";
    } else {    # if this is one of the Kn calcs, initialize eax to zero
        print "    xor eax, eax\n";
    }

    # second through fifth terms for intermediate keys;
    # first through fifth terms for keys
    my $lessTerm = 0;
    $lessTerm = -1 if ($params[$i][0] =~ /^K/ );
    for $j (1..5) {
        my $sbox = $params[$i][2*$j + $lessTerm];
        (my $sboxNum = $sbox) =~ s/S//;
        my $sboxArg = $params[$i][2*$j + 1 + $lessTerm];
        my $sboxOffset = '';
        if ( $sboxArg =~ /^x/ ) {
            $sboxOffset .= '0';
        } elsif ( $sboxArg =~ /^z/ ) {
            $sboxOffset .= '1';
        };  $sboxOffset .= $endianMap[hex(substr($sboxArg, 1, 1))];
        print "    mov cl,  [esp + 0x$sboxOffset]   ; $sboxArg\n";   # s-box val
        my $offset = ($sboxNum - 1) * 0x400;
        printf ("    add ebp, 0x%x\n", $offset);
        $term = "$sbox\[$sboxArg\]";
        print "    mov ebx, [ecx*4 + ebp]  ; $term\n";
        printf ("    sub ebp, 0x%x\n", $offset);
        $currentCalc .= " ^ $term";
        $currentCalc =~ s/^ \^ //;
        print "    xor eax, ebx            ; $currentCalc\n";
    }
    # store off key calc result
    if ( $key2Calc =~ /^x([048C])/ ) {
        $espOffset = "0$1";
    } elsif ( $key2Calc =~ /^z([048C])/ ) {
        $espOffset = "1$1";
    } elsif ( $key2Calc =~ /^K([0-9]+)/ ) {
        $espOffset = $keyAddresses[$1 - 1];
    };  print "    mov [esp + 0x$espOffset], eax\n";
#rdf
#exit;
#rdf
}

