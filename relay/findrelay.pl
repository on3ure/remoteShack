#!/usr/bin/perl
#

use v5.10;
use strict;
use utf8;
use Term::ReadKey;
use YAML qw(DumpFile);

use RPi::Pin;
use RPi::Const qw(:all);

ReadMode('cbreak');

my $data;
my $relay;

for my $i ( ( 1 .. 26 ) ) {
    print "Testing GPIO " . $i . "\n";
    print
        "Saw relay movement ? (1..9) for relay id or any other key for nothing\n";

    $relay->{$i} = RPi::Pin->new($i);

    $relay->{$i}->mode(OUTPUT);
    $relay->{$i}->write(LOW);

    my $return = ReadKey(0);
    if ( $return ne 'n' ) {
        $return = $return * 1;
        if ( $return ne 0 ) {
            $data->{relay}->{$return}->{gpio}  = $i;
            $data->{relay}->{$return}->{state} = 'high';
            $data->{relay}->{$return}->{name}  = 'name ' . $i;
        }
    }

    $relay->{$i}->write(HIGH);
}

DumpFile( 'findrelay.yaml', $data );

ReadMode('restore');
