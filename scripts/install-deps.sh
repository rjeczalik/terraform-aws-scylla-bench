#!/bin/bash

set -eu

sudo apt install -y wget screen
sudo mkdir -p /etc/apt/keyrings
sudo gpg --homedir /tmp --no-default-keyring --keyring /etc/apt/keyrings/scylladb.gpg --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys d0a112e067426ab2
sudo wget -O /etc/apt/sources.list.d/scylla.list http://downloads.scylladb.com/deb/debian/scylla-5.1.list

sudo apt update

sudo apt install -y scylla-tools

mkdir -p ~/.ssh
touch ~/.ssh/authorized_keys
chmod 0700 ~/.ssh
chmod 0600 ~/.ssh/authorized_keys

cat <<EOF | while read key; do echo "$${key}" >> ~/.ssh/authorized_keys; done
${public_keys}
EOF
