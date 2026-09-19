# Project Overview & Architecture

The project builds and containerizes Slurm services such as `slurmctld`, `slurmdbd`, `slurmd`, `slurmrestd`, and `sackd`. It allows users to deploy and run Slurm clusters in containerized and Kubernetes environments using Slurm's native token authentication mechanism (`AuthType=auth/slurm`), which eliminates munge dependencies.

The core of the project is a set of container images built for various Linux distributions (`deb12`, `deb13`, `el8`, `el9`, `el10`). The project is designed to be flexible, supporting configurations ranging from a minimal single-node setup to a high-availability (HA) cluster.

## Directory Mapping
* `common/`: Houses shared configuration templates (`slurm.conf.j2`, `slurmdbd.conf.j2`, `cgroup.conf.j2`), custom configuration extensions (`slurmd-extra.conf`), and the entrypoint template source (`entrypoint.m4`, `build-entrypoint.sh`).
* `slurm/`: Git submodule pointing to the upstream SchedMD Slurm repository.
* `json-web-key-generator/`: Git submodule containing the Java JWK generator library used to build token authentication keys.
* Distribution Folders (`deb12`, `deb13`, `el8`, `el9`, `el10`): Each contains a `Containerfile` and OS-specific scripts to compile and build packages from the Slurm source submodule.
* `gitlab-ci.d/`: CI templates (`container-build.yml.j2`, `container-tag.yml.j2`) used dynamically to generate pipeline jobs for GitLab CI.

