#!/usr/bin/perl
#

use v5.10;
use strict;
use utf8;
use Term::ReadKey;
use YAML qw(DumpFile);

#use RPi::Pin;
#use RPi::Const qw(:all);

ReadMode('cbreak');

my $data;

for my $i ( ( 1 .. 26 ) ) {
    print "Testing GPIO " . $i . "\n";
    print "Saw relay movement ? (1..9) for relay id or any other key for nothing\n";

    my $return = ReadKey(0);
    if ( $return ne 'n' ) {
        $return                            = $return * 1;
        if ($return ne 0) {
        $data->{relay}->{$return}->{gpio}  = $i;
        $data->{relay}->{$return}->{state} = 'high';
        $data->{relay}->{$return}->{name}  = 'name ' . $i;
      }
    }

    #    $relay->{$relay_key}->mode(OUTPUT);
    #        $relay->{$relay_key}->write(LOW);
    #        $relay->{$relay_key}->write(HIGH);
}

DumpFile('findrelay.yaml', $data);
