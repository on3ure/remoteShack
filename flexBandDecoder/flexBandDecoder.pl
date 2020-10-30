#!/usr/bin/perl

use Device::SerialPort;
use strict;

my $port = Device::SerialPort->new("/dev/ttyUSB0");

$| = 1;

$port->read_char_time(0);        # don't wait for each character
$port->read_const_time(1000);    # 1 second per unfulfilled "read" call

my $band;
while (1) {
    my $newband = 0;
    my ( $count, $saw ) = $port->read(255);    # will read _up to_ 255 chars
    $saw =~ s/\D//g;
    my $freq = $saw * 1;
    if ( $freq ne 0 ) {
        $freq = $freq / 1000000;

        if ( ( $freq > 430 ) && ( $freq < 440 ) ) {
            $newband = '70cm';
        }

        if ( ( $freq > 144 ) && ( $freq < 146 ) ) {
            $newband = '2m';
        }

        if ( ( $freq > 50 ) && ( $freq < 52 ) ) {
            $newband = '6m';
        }

        if ( ( $freq > 28 ) && ( $freq < 30 ) ) {
            $newband = '10m';
        }
        if ( ( $freq > 24 ) && ( $freq < 25 ) ) {
            $newband = '12m';
        }
        if ( ( $freq > 21 ) && ( $freq < 22 ) ) {
            $newband = '15m';
        }
        if ( ( $freq > 18 ) && ( $freq < 19 ) ) {
            $newband = '17m';
        }
        if ( ( $freq > 14 ) && ( $freq < 15 ) ) {
            $newband = '20m';
        }
        if ( ( $freq > 14 ) && ( $freq < 15 ) ) {
            $newband = '20m';
        }
        if ( ( $freq > 10 ) && ( $freq < 11 ) ) {
            $newband = '30m';
        }
        if ( ( $freq > 7 ) && ( $freq < 8 ) ) {
            $newband = '40m';
        }
        if ( ( $freq > 3 ) && ( $freq < 4 ) ) {
            $newband = '80m';
        }
        if ( ( $freq > 1 ) && ( $freq < 2 ) ) {
            $newband = '160m';
        }

        if ( ( $newband ne 0 ) && ( $band ne $newband ) ) {
            $band = $newband;
            print $band . " [" . $freq . " MHz]\n";
        }
    }
}
