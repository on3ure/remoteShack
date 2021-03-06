#!/usr/bin/perl
#

use v5.10;
use strict;
use utf8;
use RPi::Pin;
use RPi::Const qw(:all);
use Config::YAML;
use Time::HiRes qw( usleep);
use Mojo::UserAgent;

# Config
my $config = Config::YAML->new( config => "input.yaml" );

# UserAgent
my $ua = Mojo::UserAgent->new;

my $input;
foreach my $input_key ( keys %{ $config->{input} } ) {
    $input->{$input_key}->{pin}
        = RPi::Pin->new( $config->{input}->{$input_key}->{gpio} );
    $input->{$input_key}->{pin}->mode($config->{$input_key}->{mode});
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
                    my $mapState = $config->{input}->{$input_key}->{map}
                        ->{ $input->{$input_key}->{togglestate} };
                    $input->{$input_key}->{togglestate} = 1;
                    foreach my $remote (
                        keys %{ $config->{input}->{$input_key}->{trigger} } )
                    {
                        if ( $config->{input}->{$input_key}->{trigger}
                            ->{$remote}->{active} eq 'true' )
                        {
                            if ( $config->{input}->{$input_key}->{trigger}
                                ->{$remote}->{checkstate} eq 'true' )
                            {
                                my $rstate
                                    = $ua->get(
                                    $config->{input}->{$input_key}->{trigger}
                                        ->{$remote}->{state} )->result->json;

                                my $rmapState
                                    = $config->{input}->{$input_key}->{map}
                                    ->{ $rstate->{state} };

                                if ( $rstate->{state} ne $rmapState ) {
                                    if ( $rmapState eq 'off' ) {
                                        $ua->get(
                                            $config->{input}->{$input_key}
                                                ->{trigger}->{$remote}->{on} )
                                            ->result->json;
                                    }
                                    else {
                                        $ua->get(
                                            $config->{input}->{$input_key}
                                                ->{trigger}->{$remote}->{off}
                                        )->result->json;
                                    }

                                }
                            }
                            else {
                                $ua->get(
                                    $config->{input}->{$input_key}->{trigger}
                                        ->{$remote}->{$mapState} )
                                    ->result->json;
                            }
                        }
                    }
                    usleep( 250 * 1000 );
                }
                elsif (( $state eq 0 )
                    && ( $input->{$input_key}->{togglestate} eq 1 ) )
                {
                    my $mapState = $config->{input}->{$input_key}->{map}
                        ->{ $input->{$input_key}->{togglestate} };
                    $input->{$input_key}->{togglestate} = 0;
                    foreach my $remote (
                        keys %{ $config->{input}->{$input_key}->{trigger} } )
                    {
                        if ( $config->{input}->{$input_key}->{trigger}
                            ->{$remote}->{active} eq 'true' )
                        {
                            $ua->get(
                                $config->{input}->{$input_key}->{trigger}
                                    ->{$remote}->{$mapState} )->result->json;
                        }
                    }
                    usleep( 250 * 1000 );
                }

            }
            else {
                if ( $input->{$input_key}->{state} ne $state ) {
                    foreach my $remote (
                        keys %{ $config->{input}->{$input_key}->{trigger} } )
                    {
                        if ( $config->{input}->{$input_key}->{trigger}
                            ->{$remote}->{active} eq 'true' )
                        {
                            my $mapState
                                = $config->{input}->{$input_key}->{map}
                                ->{$state};
                            $ua->get(
                                $config->{input}->{$input_key}->{trigger}
                                    ->{$remote}->{$mapState} )->result->json;
                        }
                    }
                    $input->{$input_key}->{state} = $state;

                }
            }

            $input->{$input_key}->{laststate} = $state;
        }
    }
    usleep(1000);
}
