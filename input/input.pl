#!/usr/bin/perl
#

use v5.10;
use strict;
use utf8;
use RPi::Pin;
use RPi::Const qw(:all);
use Config::YAML;
use Time::HiRes qw( usleep);

my $config = Config::YAML->new( config => "input.yaml" );

my $input;
foreach my $input_key ( keys %{ $config->{input} } ) {
    $input->{$input_key}->{pin}
        = RPi::Pin->new( $config->{input}->{$input_key}->{gpio} );
    $input->{$input_key}->{pin}->mode(INPUT);
    $input->{$input_key}->{state} = 1
        if $config->{input}->{$input_key}->{state} eq 'high';
    $input->{$input_key}->{state} = 0
        if $config->{input}->{$input_key}->{state} eq 'low';
    $input->{$input_key}->{togglestate} = 0
        if $config->{input}->{$input_key}->{toggle} eq 'true';
    $input->{$input_key}->{toggle} = 'true'
        if $config->{input}->{$input_key}->{toggle} eq 'true';

}

while (1) {

    foreach my $input_key ( keys %{ $config->{input} } ) {
        my $state = $input->{$input_key}->{pin}->read;
        if ( $input->{$input_key}->{laststate} ne $state ) {
            if ( $input->{$input_key}->{toggle} eq 'true' ) {
                if (   ( $state eq 0 )
                    && ( $input->{$input_key}->{togglestate} eq 0 ) )
                {
                    $input->{$input_key}->{togglestate} = 1;
                    print "on\n";
                    usleep( 250 * 1000 );
                }
                elsif (( $state eq 0 )
                    && ( $input->{$input_key}->{togglestate} eq 1 ) )
                {
                    $input->{$input_key}->{togglestate} = 0;
                    print "off\n";
                    usleep( 250 * 1000 );
                }

            }
            else {
                if ( $input->{$input_key}->{state} ne $state ) {
                    print $config->{input}->{$input_key}->{name} . " -> "
                        . $state . "\n";
                    $input->{$input_key}->{state} = $state;

                }
            }

            $input->{$input_key}->{laststate} = $state;
        }
    }
    usleep( 10 * 1000 );
}
