#!/bin/bash -x
PODMAN="$(which podman)"
PODMAN=${PODMAN:=$(which docker)}

distro=${@:-"el8 el9 deb12"}
slurm_ver=$(grep "Version:" slurm/slurm.spec | head -n 1 | awk '{print $2}' | cut -d. -f-2 )

echo ${distro} | xargs -n1 -I{} -P 3 ${PODMAN} build -t slurm:{} -t slurm:${slurm_ver}-{} --squash -f {}/Containerfile .
