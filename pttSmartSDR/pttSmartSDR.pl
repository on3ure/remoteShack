#!/usr/bin/perl
#

use v5.10;
use strict;
use utf8;
use Mojolicious::Lite;
use Config::YAML;
use Mojo::IOLoop::Client;
use Mojo::IOLoop;

my $host = '172.16.30.6';
my $port = '5001';

# Config
my $config = Config::YAML->new( config => "pttSmartSDR.yaml" );

# UserAgent

# Mojo Config
my $mojoconfig = plugin Config => { file => 'mojo.conf' };

get '/frequp' => sub {
    my $self = shift;

    # reder when we are done
    my $state = 1;
    $self->render_later;

Mojo::IOLoop->client(address => $host, port => $port, sub {
    my ($loop, $err, $tcp) = @_;


    print( "TCP connection error: $err") if $err;
    $tcp->on(error => sub { print("TCP error: $_[1]") });

    $tcp->on(read => sub {
      my ($tcp, $bytes) = @_;
      print({binary => $bytes});
    });


    $tcp->write('ZZTX1;');

  });

    $state->{error}   = 'true';
    #$state->{message} = $category . " not found";

    $self->render( json => $state );
};

app->start;
