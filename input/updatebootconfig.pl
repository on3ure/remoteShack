#!/usr/bin/perl
#

use v5.10;
use strict;
use utf8;
use Config::YAML;

my $config = Config::YAML->new( config => "input.yaml" );

print "add this tis /boot/config.txt\n\n";

my @gpios;
foreach my $i (sort keys %{$config->{input}}) {
  push(@gpios, $config->{input}->{$i}->{gpio});
}

print "gpio=" . join(",", @gpios) . "=op,dh\n";
print "dtoverlay=pi3-disable-bt
dtparam=act_led_trigger=none
dtparam=act_led_activelow=on\n";

