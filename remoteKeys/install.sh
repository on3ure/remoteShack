#!/bin/bash

# run as root

mkdir -p /opt/remoteShack/remoteKeys
cp remoteKeys.py /opt/remoteShack/remoteKeys
cp togglePtt.pl /opt/remoteShack/remoteKeys
cp mojo.conf /opt/remoteShack/remoteKeys
cp remoteKeys.yaml /opt/remoteShack/remoteKeys > /dev/null 2>&1

cp remoteKeys.service /lib/systemd/system/
cp togglePtt.service /lib/systemd/system/

systemctl --system daemon-reload

systemctl enable remoteKeys
systemctl stop remoteKeys
systemctl start remoteKeys

systemctl enable togglePtt
systemctl stop togglePtt
systemctl start togglePtt
