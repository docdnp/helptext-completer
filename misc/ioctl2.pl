#!/usr/bin/perl
require "sys/ioctl.ph";
$file = shift;
open T, ">$file" or die "$!"; 
open D, ">/tmp/X" or warn "$!"; 
# *T = *STDOUT;
print D "\nDEBUG::: IOCTL: ";
do {
     print D $_ eq '\e' ? '\e' : $_,'|'; 
    ioctl(T, &TIOCSTI, $_); 
} for split "", join " ", @ARGV;
print D "\n\n";
