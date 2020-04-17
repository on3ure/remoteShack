#!/usr/bin/perl -w
# broadcast receiver script
use strict;
use diagnostics;
use Socket;
use XML::Simple;
use JSON::MaybeXS;
use Config::YAML;
use Mojo::UserAgent;
use Try::Tiny;
use Data::Dumper;

# YAML based config
my $config = Config::YAML->new( config => "config.yaml" );

# Fancy pancy UserAgent
my $ua = Mojo::UserAgent->new;
$ua = $ua->connect_timeout(1);

# Plain old C Socket
my $sock;
socket( $sock, PF_INET, SOCK_DGRAM, getprotobyname('udp') ) || die "socket: $!";
setsockopt( $sock, SOL_SOCKET, SO_REUSEADDR, pack( "l", 1 ) )
  || die "setsockopt: $!";
bind( $sock, sockaddr_in( 12060, inet_aton('172.16.30.255') ) )
  || die "bind: $!";

# just loop forever listening for packets
while (1) {
    my $datastring = '';
    my $hispaddr = recv( $sock, $datastring, 256000, 0 );    # blocking recv
    if ( !defined($hispaddr) ) {
        print("recv failed: $!\n");
        next;
    }

    # Convert old-scool-xml to json
    my $data = XMLin( $datastring, KeepRoot => 1 );
    for my $server ( @{ $config->{http_servers} } ) {
        try {
          print Dumper $data;
          #$ua->post( $server => json => $data )->result->json;
        }
        catch {
            warn "caught error: $_";
        };
    }
}
