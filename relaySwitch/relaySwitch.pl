#!/usr/bin/perl
#

use v5.10;
use strict;
use utf8;
use Mojolicious::Lite;
use Mojo::UserAgent;
use Config::YAML;
use Data::Dumper;

# Config
my $config = Config::YAML->new( config => "relaySwitch.yaml" );

# UserAgent
my $ua = Mojo::UserAgent->new;

# Mojo Config
my $mojoconfig = plugin Config => { file => 'mojo.conf' };

get '/:category/state' => sub {
    my $self = shift;

    # reder when we are done
    $self->render_later;

    my $category = $self->stash('category');

    my $state;

    if ( $config->{$category}->{active} eq 'true' ) {

        $state->{error} = 'false';

        foreach my $endpoint ( keys %{ $config->{$category}->{endpoint} } ) {
            if ( $config->{$category}->{endpoint}->{$endpoint}->{active} eq
                'true' )
            {
                my $res
                    = $ua->get(
                    $config->{$category}->{endpoint}->{$endpoint}->{state} )
                    ->result->json;
                $state->{$endpoint}
                    = $config->{$category}->{endpoint}->{$endpoint}->{map}
                    ->{ $res->{state} };
            }
        }
    }
    else {
        $state->{error} = 'true';
        $state->{message} = $category . " not found";
    }

    $self->render( json => $state );
};

#get '/:category/:endpoint/:state' => sub {
#    my $self = shift;
#
#    # reder when we are done
#    $self->render_later;
#
#    my $category = $self->stash('category');
#    my $endpoint= $self->stash('endpoint');
#    my $state= $self->stash('state');
#
#    my $state;
#
#    if ( $config->{$category}->{active} eq 'true' ) {
#
#        $state->{error} = 'false';
#
#        if ($
#
#        foreach my $endpoint ( keys %{ $config->{$category}->{endpoint} } ) {
#            if ( $config->{$category}->{endpoint}->{$endpoint}->{active} eq
#                'true' )
#            {
#                my $res
#                    = $ua->get(
#                    $config->{$category}->{endpoint}->{$endpoint}->{state} )
#                    ->result->json;
#                $state->{$endpoint}
#                    = $config->{$category}->{endpoint}->{$endpoint}->{map}
#                    ->{ $res->{state} };
#            }
#        }
#    }
#    else {
#        $state->{error} = 'true';
#        $state->{message} = $category . " not found";
#    }
#
#    $self->render( json => $state );
#};

app->start;
