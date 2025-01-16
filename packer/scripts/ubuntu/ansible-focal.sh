#!/bin/bash -eux

apt-get update -y
apt-get upgrade -y
apt-get install -y python3-dev curl git net-tools acl

curl -s https://bootstrap.pypa.io/pip/get-pip.py | python3.8
pip install ansible jmespath Jinja2==3.0.3

mkdir -p /etc/ansible

cat << EOF
[defaults]
allow_world_readable_tmpfiles = True

[ssh_connection]
pipelining = True
EOF
