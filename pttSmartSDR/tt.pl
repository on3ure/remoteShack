#!/user/bin/perl
#
use strict;
use Mojo::IOLoop;

my $host = '172.16.30.6';
my $port = '5001';

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


sleep 10000;

