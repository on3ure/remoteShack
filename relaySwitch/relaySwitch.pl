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

    if ( defined $config->{$category}->{active}
        && ( $config->{$category}->{active} eq 'true' ) )
    {
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
        $state->{error}   = 'true';
        $state->{message} = $category . " not found";
    }

    $self->render( json => $state );
};

get '/:category/:endpoint/state' => sub {
    my $self = shift;

    # reder when we are done
    $self->render_later;

    my $category = $self->stash('category');
    my $endpoint = $self->stash('endpoint');

    my $state;

    if ( $config->{$category}->{active} eq 'true' ) {
        $state->{error} = 'false';

        if (defined $config->{$category}->{endpoint}->{$endpoint}->{active}
            && ( $config->{$category}->{endpoint}->{$endpoint}->{active} eq
                'true' )
            )
        {
            my $res
                = $ua->get(
                $config->{$category}->{endpoint}->{$endpoint}->{state} )
                ->result->json;
            $state->{$endpoint}
                = $config->{$category}->{endpoint}->{$endpoint}->{map}
                ->{ $res->{state} };
        }
        else {
            $state->{error}   = 'true';
            $state->{message} = $endpoint . " not found";
        }
    }
    else {
        $state->{error}   = 'true';
        $state->{message} = $category . " not found";
    }

    $self->render( json => $state );
};

get '/:category/:endpoint/:switch' => sub {
    my $self = shift;

    # reder when we are done
    $self->render_later;

    my $category = $self->stash('category');
    my $endpoint = $self->stash('endpoint');
    my $switch   = lc( $self->stash('switch') );

    my $state;

    if ( defined $config->{$category}->{active}
        && ( $config->{$category}->{active} eq 'true' ) )
    {
        $state->{error} = 'false';
        if ( ( $switch eq 'on' ) || ( $switch eq 'off' ) ) {
            if ( $config->{$category}->{multiple} eq 'false' ) {
                foreach my $endpoint (
                    keys %{ $config->{$category}->{endpoint} } )
                {
                    if ( $config->{$category}->{endpoint}->{$endpoint}
                        ->{active} eq 'true' )
                    {
                        my $res
                            = $ua->get(
                            $config->{$category}->{endpoint}->{$endpoint}
                                ->{state} )->result->json;
                        if ( $config->{$category}->{endpoint}->{$endpoint}
                            ->{map}->{ $res->{state} } eq 'on' )
                        {
                            $ua->get(
                                $config->{$category}->{endpoint}->{$endpoint}
                                    ->{off} )->result->json;

                        }
                    }
                }

            }

            if (defined $config->{$category}->{endpoint}->{$endpoint}
                ->{active}
                && ( $config->{$category}->{endpoint}->{$endpoint}->{active}
                    eq 'true' )
                )
            {
                my $res
                    = $ua->get(
                    $config->{$category}->{endpoint}->{$endpoint}->{$switch} )
                    ->result->json;
                foreach my $endpoint (
                    keys %{ $config->{$category}->{endpoint} } )
                {
                    if ( $config->{$category}->{endpoint}->{$endpoint}
                        ->{active} eq 'true' )
                    {
                        my $res
                            = $ua->get(
                            $config->{$category}->{endpoint}->{$endpoint}
                                ->{state} )->result->json;
                        $state->{$endpoint}
                            = $config->{$category}->{endpoint}->{$endpoint}
                            ->{map}->{ $res->{state} };
                    }
                }
            }
            else {
                $state->{error}   = 'true';
                $state->{message} = $endpoint . " not found";
            }
        }
        else {
            $state->{error}   = 'true';
            $state->{message} = 'a switch can only by on or off';
        }
    }
    else {
        $state->{error}   = 'true';
        $state->{message} = $category . " not found";
    }

    $self->render( json => $state );
};

app->start;
