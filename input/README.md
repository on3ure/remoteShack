# relay

relay adressable via http rest

# install and configure

## update system

```sh
apt -y update
apt -y full-upgrade
```

## install git
```sh
apt -y install git
```

## bootstrap
```sh
git clone https://github.com/on3ure/remoteShack.git
cd remoteShack/relay
sh -x bootstrap.sh
```

## findrelay
```sh
perl findrelay.pl
```

This will test all gpios and writes a relay.yaml file

## update boot config
```sh
perl updatebootconfig.pl
```

Add content to the bottom of /boot/config.txt

## install relay
```sh
sh -x ./install.sh
```

You can edit the /opt/remoteShack/relay/relay.yaml
