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
    $pm->start and next BROADCAST;
    if ( $config->{pttBroadcast}->{$broadcastName}->{active} eq 'true' ) {

        # UserAgent
        my $ua = Mojo::UserAgent->new;

        while (1) {
            my $res
                = $ua->get(
                $config->{pttBroadcast}->{$broadcastName}->{state} )
                ->result->json;
                print $config->{pttBroadcast}->{$broadcastName}->{map}->{$res->{state}}  . "\n";
            sleep(1);
            usleep( 10 * 1000 );
        }
        $pm->finish;    # do the exit in the child process
    }
}
$pm->wait_all_children;
