#!/usr/bin/perl
#

use v5.10;
use strict;
use utf8;
use Mojolicious::Lite;
use RPi::Pin;
use RPi::Const qw(:all);
use Config::YAML;

my $config = Config::YAML->new( config => "relay.yaml" );

# Mojo config
my $mojoconfig = plugin Config => { file => 'mojo.conf' };

my $relay;

foreach my $relay_key ( keys %{ $config->{relay} } ) {
    $relay->{$relay_key}
        = RPi::Pin->new( $config->{relay}->{$relay_key}->{gpio} );
    $relay->{$relay_key}->mode(OUTPUT);
    if ( $config->{relay}->{$relay_key}->{state} eq 'low' ) {
        $relay->{$relay_key}->write(LOW);
    }
    elsif ( $config->{relay}->{$relay_key}->{state} eq 'high' ) {
        $relay->{$relay_key}->write(HIGH);
    }
    else {
        print "config error\n";
    }
    print "Init relay ["
        . $relay_key
        . "] -> gpio -> ["
        . $config->{relay}->{$relay_key}->{gpio}
        . "] state ["
        . $config->{relay}->{$relay_key}->{state}
        . "] name ["
        . $config->{relay}->{$relay_key}->{name} . "]\n";
}

get '/:nr/:state' => sub {
    my $self = shift;

    # reder when we are done
    $self->render_later;

    my $nr    = $self->stash('nr');
    my $state = $self->stash('state');

    if ( $config->{relay}->{$nr}->{gpio} ) {
        if ( $state eq 'high' ) {
            $relay->{$nr}->write(HIGH);
            $self->render( text => 'ok|state|high' );
        }
        elsif ( $state eq 'low' ) {
            $relay->{$nr}->write(LOW);
            $self->render( text => 'ok|state|low' );
        }
        else {
            $self->render( text => 'err|wrong state' );
        }
    }
    else {
        $self->render( text => 'err|not found' );
    }
};

get '/:nr' => sub {
    my $self = shift;

    # reder when we are done
    $self->render_later;

    my $nr = $self->stash('nr');

    if ( $config->{relay}->{$nr}->{gpio} ) {
        my $read_state = $relay->{$nr}->read();
        if ( $read_state eq '0' ) {
            my $data = {
                'error' => 0,
                'state' => 'low',
                'name'  => $config->{relay}->{$nr}->{name}
            };
            $self->render( json => $data );
        }
        elsif ( $read_state eq '1' ) {
            my $data = {
                'error' => 0,
                'state' => 'high',
                'name'  => $config->{relay}->{$nr}->{name}
            };
            $self->render( json => $data );
        }
        else {
            my $data = {
                'error' => 0,
                'state' => 'error',
                'name'  => $config->{relay}->{$nr}->{name}
            };
            $self->render( json => $data );
        }
    }
    else {
        my $data = {
            'error' => 1,
            'state' => 'error',
        };
        $self->render( json => $data );
    }
};

app->start;
