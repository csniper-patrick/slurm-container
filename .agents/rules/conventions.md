# Key Conventions & Tooling

## Development Conventions
* **Containerization:** The project is based on containerization using `podman` (preferred) or `docker`.
* **Modularity:** The project is organized into modules for different distributions and common components.
* **High Availability:** The project supports a high-availability (HA) configuration for the Slurm control plane.
* **Makefile Automation:** The `Makefile` dynamically discovers directories containing a `Containerfile` (distributions) and compiles images for them. Phony targets such as `all`, `build`, `prune`, `up`, `ha`, and `down` are supported.
* **Entrypoint Generation:** The `/opt/local/bin/entrypoint` script in target images is constructed by compiling `common/entrypoint.m4` using `argbash` via `common/build-entrypoint.sh`. Always edit the `common/entrypoint.m4` template to make changes to entrypoint logic, then re-generate the script.
* **Configuration Management:** System configuration files are generated dynamically inside the containers at startup using `jinja2-cli` with templates under `common/` based on environment variables or entrypoint arguments.

## Build and Run Commands

* **Build all distribution images:**
  ```bash
  make all
  ```
* **Build a specific distribution image:**
  ```bash
  make <distribution>  # e.g., make el9, make deb12
  ```
* **Run simple single-node Slurm cluster:**
  ```bash
  make up
  # or directly:
  podman compose --profile single up -d
  ```
* **Run high-availability (HA) Slurm cluster:**
  ```bash
  make ha
  # or directly:
  podman compose --profile ha up -d
  ```
* **Use local images instead of released image:**
  ```bash
  make up IMAGE_SOURCE=local  # single node with local image
  make ha IMAGE_SOURCE=local  # HA with local image
  ```
* **Stop cluster:**
  ```bash
  make down
  # or directly:
  podman compose --profile single --profile ha down
  ```

