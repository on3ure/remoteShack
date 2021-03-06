#!/bin/bash

# run as root

mkdir -p /opt/remoteShack/relay
cp relay.pl /opt/remoteShack/relay
cp mojo.conf /opt/remoteShack/relay
cp relay.yaml /opt/remoteShack/relay > /dev/null 2>&1

cp relay.service /lib/systemd/system/

systemctl --system daemon-reload

systemctl enable relay
systemctl stop relay
systemctl start relay
