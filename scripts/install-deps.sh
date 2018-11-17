#!/bin/bash

set -eu

sudo yum install -y epel-release wget screen
sudo wget -O /etc/yum.repos.d/scylla.repo http://repositories.scylladb.com/scylla/repo/2e2f1a5f-4195-4691-8e19-43f6af57b0e2/centos/scylladb-2018.1.repo
sudo yum install -y scylla-enterprise-tools

mkdir -p ~/.ssh
touch ~/.ssh/authorized_keys
chmod 0700 ~/.ssh
chmod 0600 ~/.ssh/authorized_keys

cat <<EOF | while read key; do echo "$${key}" >> ~/.ssh/authorized_keys; done
${public_keys}
EOF
