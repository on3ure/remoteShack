#!/usr/bin/perl
#

use v5.10;
use strict;
use utf8;
use Mojolicious::Lite;
use Redis::Fast;

my $redis= Redis::Fast->new(
    reconnect => 2,
    every     => 100,
    encoding  => 'utf8'
);

# Mojo Config
my $mojoconfig = plugin Config => { file => 'mojo.conf' };

get '/ptt/on' => sub {
    my $self = shift;

    # reder when we are done
    $self->render_later;

    $redis->set('ptt', 1);

    my $state;

    $state->{error}   = 'true';
    $state->{message} = 'ok';

    $self->render( json => $state );
};

get '/ptt/off' => sub {
    my $self = shift;

    # reder when we are done
    $self->render_later;

    $redis->del('ptt');

    my $state;

    $state->{error}   = 'true';
    $state->{message} = 'ok';

    $self->render( json => $state );
};

app->start;
