#!/bin/bash -x

wget $( curl -sL https://api.github.com/repos/matejak/argbash/releases/latest | jq -r .tarball_url ) -O argbash.tar.gz
tar xvf argbash.tar.gz
mv matejak-argbash-*/ argbash/
argbash/bin/argbash entrypoint.m4 -o /opt/entrypoint