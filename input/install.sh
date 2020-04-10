#!/bin/bash

# run as root

mkdir -p /opt/remoteShack/input
cp input.pl /opt/remoteShack/input
cp mojo.conf /opt/remoteShack/input

cp input.service /lib/systemd/system/

systemctl --system daemon-reload

systemctl enable input
systemctl stop input
systemctl start input
