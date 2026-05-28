#!/bin/bash -x

# 1. Install system dependencies for Slurm build
apt-get -y update
apt-get -y install fakeroot devscripts git wget munge libmunge-dev mariadb-server mariadb-client libmariadb-dev libllhttp-dev libhttp-parser-dev libjson-c5 libjson-c-dev libyaml-0-2 libyaml-dev libjwt2 libjwt-dev openssl libssl-dev wget curl bzip2 build-essential python3 libpmix-bin libpmix-dev libpmix2 systemd dpkg-dev vim gfortran libsysfs2 libsysfs-dev pkg-config lua5.4 lua5.4-dev libucx0 libucx-dev ucx-utils jq

# 2. Install NVIDIA Management Library (NVML) for GPU support
[[ $(uname -m) == x86_64 ]] && wget https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2404/x86_64/cuda-keyring_1.1-1_all.deb
[[ $(uname -m) == aarch64 ]] && wget https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2404/sbsa/cuda-keyring_1.1-1_all.deb
dpkg -i cuda-keyring_1.1-1_all.deb
apt-get update
apt-get -y install $(apt-cache search cuda-nvml-dev | grep -oE "^cuda-nvml-dev-[0-9]+-[0-9]+" | sort | tail -n1)

# Configure environment for NVML
export CPPFLAGS="$(pkg-config --cflags-only-I --keep-system-cflags $(pkg-config --list-all | grep -oE 'nvidia-ml-[0-9]+\.[0-9]+') ) ${CPPFLAGS}"
export LDFLAGS="$(pkg-config --libs-only-L --keep-system-libs $(pkg-config --list-all | grep -oE 'nvidia-ml-[0-9]+\.[0-9]+') ) ${LDFLAGS}"

# 3. Build Slurm Debian packages
cd slurm-src
yes | mk-build-deps -i debian/control
debuild -b -uc -us

# 4. Create a local Debian repository for Slurm packages
mkdir /opt/slurm-repo
cd /opt/slurm-repo
mv /*.deb /opt/slurm-repo
dpkg-scanpackages . /dev/null > Release
dpkg-scanpackages . /dev/null | gzip -9c > Packages.gz
cat > /etc/apt/sources.list.d/slurm.list <<EOF
deb [trusted=yes] file:/opt/slurm-repo /
EOF
