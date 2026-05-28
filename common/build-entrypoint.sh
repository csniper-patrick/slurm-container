#!/bin/bash -x

# 1. Download and install argbash to generate the entrypoint script
wget $( curl -sL https://api.github.com/repos/matejak/argbash/releases/latest | jq -r .tarball_url ) -O argbash.tar.gz
tar xvf argbash.tar.gz
mv matejak-argbash-*/ argbash/

# 2. Generate the final /opt/entrypoint script from entrypoint.m4
argbash/bin/argbash entrypoint.m4 -o /opt/entrypoint
