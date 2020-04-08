#!/usr/bin/perl
#

use v5.10;
use strict;
use utf8;
use RPi::Pin;
use RPi::Const qw(:all);
use Config::YAML;

my $config = Config::YAML->new( config => "input.yaml" );

my $input;
    foreach my $input_key ( keys %{ $config->{input} } ) {
        $input->{$input_key}
            = RPi::Pin->new( $config->{input}->{$input_key}->{gpio} );
        $input->{$input_key}->mode(INPUT);
    }

while (1) {

    foreach my $input_key ( keys %{ $config->{input} } ) {
      my $state = $input->{$input_key}->read;
      print $config->{input}->{$input_key}->{name} . " -> " . $state . "\n";

    sleep(1);
}
