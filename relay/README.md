# relay

relay adressable via http rest

# install

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

### findrelay
```sh
perl findrelay.pl
```

This will test all gpios and writes a findrelay.yaml file ... edit this file (change names) and copy this over relay.yaml
