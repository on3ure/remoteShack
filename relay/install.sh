#!/bin/bash

# run as root

mkdir -p /opt/on3ure/relay
cp relay.pl /opt/on3ure/relay
cp mojo.conf /opt/on3ure/relay

cp relay.service /lib/systemd/system/

systemctl --system daemon-reload

systemctl enable relay
systemctl stop relay
systemctl start relay
