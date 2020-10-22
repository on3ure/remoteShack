#!/usr/bin/perl
#

use v5.10;
use strict;
use utf8;
use Config::YAML;
use Mojo::UserAgent;
use Time::HiRes qw( usleep);
use Parallel::ForkManager;

my $config = Config::YAML->new( config => "pttBroadcast.yaml" );

my $pm = Parallel::ForkManager->new(30);

BROADCAST:
foreach my $broadcastName ( keys %{ $config->{pttBroadcast} } ) {
    if ( $config->{pttBroadcast}->{$broadcastName}->{active} eq 'true' ) {
        $pm->start and next BROADCAST;

        # UserAgent
        my $ua = Mojo::UserAgent->new;

        my $currentstate = 'off';

        while (1) {
            my $res;
            eval {
                $res
                    = $ua->get(
                    $config->{pttBroadcast}->{$broadcastName}->{state} )
                    ->result->json;
            };
            if ($@) {
                warn $@;
                sleep 5;
            }
            if ( $config->{pttBroadcast}->{$broadcastName}->{map}->{ $res->{state} } ne $currentstate )
            {
                if ( $config->{pttBroadcast}->{$broadcastName}->{map}
                    ->{ $res->{state} } eq 'off' )
                {
                    foreach my $broadcastTarget (
                        keys %{
                            $config->{pttBroadcast}->{$broadcastName}
                                ->{broadcast}
                        }
                        )
                    {
                        eval {
                            $ua->get(
                                $config->{pttBroadcast}->{$broadcastName}
                                    ->{broadcast}->{$broadcastTarget}->{off} )
                                ->result->json;
                        };
                        if ($@) {
                            warn $@;
                            sleep 5;
                        }
                    }
                }
                if ( $config->{pttBroadcast}->{$broadcastName}->{map}
                    ->{ $res->{state} } eq 'on' )
                {
                    foreach my $broadcastTarget (
                        keys %{
                            $config->{pttBroadcast}->{$broadcastName}
                                ->{broadcast}
                        }
                        )
                    {
                        eval {
                            $ua->get(
                                $config->{pttBroadcast}->{$broadcastName}
                                    ->{broadcast}->{$broadcastTarget}->{on} )
                                ->result->json;
                        };
                        if ($@) {
                            warn $@;
                            sleep 5;
                        }
                    }
                }
                else {
                }
                $currentstate
                    = $config->{pttBroadcast}->{$broadcastName}->{map}
                    ->{ $res->{state} };

            }
            usleep( 200 * 1000 );
        }
        $pm->finish;    # do the exit in the child process
    }
}
$pm->wait_all_children;
