# Slurm Container Project

## Project Overview

This project provides tools to build and run Slurm in containerized environments. It allows users to deploy various Slurm components, including `slurmctld`, `slurmdbd`, `slurmd`, `slurmrestd`, and `sackd`, as individual containers. The project is designed to be flexible, supporting different configurations from a minimal single-node setup to a high-availability (HA) cluster.

The core of the project is a set of container images that can be built for various Linux distributions (e.g., Debian 12, EL8, EL9). These images are configured using an entrypoint script that dynamically generates the necessary Slurm configuration files based on environment variables and command-line arguments.

## Building and Running

### Building the Container Images

The project uses a `Makefile` to automate the container image build process. The `Makefile` discovers the available distributions by looking for `Containerfile` in the subdirectories.

To build all the container images, run:

```bash
make all
```

To build a specific distribution, run:

```bash
make <distribution>
```

For example, to build the EL9 image, run:

```bash
make el9
```

### Running the Slurm Cluster

The project uses `compose.yml` with Compose profiles (`single` and `ha`) to run single-node or high-availability (HA) Slurm clusters.

To run the single-node cluster:

```bash
make up
# or:
podman-compose --profile single up -d
```

To run the HA cluster:

```bash
make ha
# or:
podman-compose --profile ha up -d
```

To use locally built images instead of published images:

```bash
make up IMAGE_SOURCE=local
make ha IMAGE_SOURCE=local
```

## Development Conventions

*   **Containerization:** The project is heavily based on containerization using `podman` and `docker`.
*   **Configuration Management:** The container entrypoint script uses `jinja2` templates to generate Slurm configuration files dynamically.
*   **Build Automation:** The `Makefile` automates the build process for the container images.
*   **Modularity:** The project is organized into modules for different distributions and common components.
*   **High Availability:** The project supports a high-availability configuration for the Slurm control plane.
