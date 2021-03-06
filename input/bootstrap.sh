#!/bin/bash

sudo apt -y install wiringpi curl

curl -L https://cpanmin.us | sudo perl - App::cpanminus

sudo cpanm WiringPi::API
sudo cpanm RPi::Pin;
sudo cpanm RPi::Const;
sudo cpanm Config::YAML;
sudo cpanm Mojolicious::Lite
sudo cpanm YAML
sudo cpanm Term::ReadKey
