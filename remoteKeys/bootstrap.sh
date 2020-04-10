#!/bin/bash

sudo apt -y install python3-pip redis-server

sudo pip3 install RPi.GPIO spidev eybow redis 

curl -L https://cpanmin.us | sudo perl - App::cpanminus

sudo cpanm Config::YAML;
sudo cpanm Mojolicious::Lite
sudo cpanm Redis::Fast
