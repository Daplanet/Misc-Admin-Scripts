#!/usr/bin/perl
# Pipe text in, this will pipe out a newline-separated list of CVE numbers present in the file.
# Maybe.

use strict;
use warnings;

my @text = <STDIN>;
my $nextline = 0;
my $prevline = 0;
my @cves = ();

foreach (@text) {
    chomp;

    if ($nextline) {
        if (m/((^-?\d{4}-\d{4})|(^-?\d{4}))/) {
            if (!$1) { print "Error parsing: $_\n"; die(1); }
            my $c = $prevline . $1;
            push @cves, $c;
            ($prevline, $nextline) = 0;
        } else {
            print "Error parsing: " . $_;
            die(2);
        }
    }

    while (m/(CVE-\d{4}-\d{4})/g) {
        push @cves, $1;
    }

    if (m/((CVE-\d{4}-?)|(CVE-?))$/) {
        $prevline = $1;
        $nextline = 1;
    }    
}

foreach (@cves) {
    print "$_\n";
}
