# Makefile for building Slurm container images.
# Replaces build-local.sh.

# Determines the container engine to use. Prefers podman if available,
# otherwise falls back to docker.
# Can be overridden from the command line, e.g., `make PODMAN=docker`
PODMAN ?= $(shell which podman 2>/dev/null)
ifeq ($(PODMAN),)
	PODMAN = $(shell which docker 2>/dev/null)
	ifeq ($(PODMAN),)
		$(error "Neither podman nor docker are available in the PATH")
	endif
endif

# Extracts the Slurm version from the spec file.
SLURM_VER := $(shell grep "Version:" slurm/slurm.spec | head -n 1 | awk '{print $$2}' | cut -d. -f-2)

# Automatically discover distributions by finding directories containing a "Containerfile".
# This will produce a space-separated list of distro names (e.g., "deb12 el8 el9").
DISTROS := $(sort $(patsubst %/Containerfile,%,$(shell ls */Containerfile 2>/dev/null)))

# Mode selection: single (default) or ha (high-availability).
# Can be controlled via:
#   make up              # Single-node cluster (default)
#   make ha              # High-availability cluster
#   MODE=ha make up      # High-availability cluster via env var
MODE ?= $(if $(SLURM_MODE),$(SLURM_MODE),single)
COMPOSE_PROFILES ?= $(MODE)
export COMPOSE_PROFILES

COMPUTE_REPLICAS ?= 2
export COMPUTE_REPLICAS

# Image source selection: released (default) or local.
# Set IMAGE_SOURCE=local (or LOCAL_IMAGE=1) to use locally built images.
# Can be overridden directly via SLURM_IMAGE.
ifneq ($(filter 1 true yes,$(LOCAL_IMAGE) $(USE_LOCAL_IMAGE)),)
	IMAGE_SOURCE := local
endif
IMAGE_SOURCE ?= released

ifeq ($(IMAGE_SOURCE),local)
	TAG ?= el9
	SLURM_IMAGE ?= slurm:$(TAG)
else
	TAG ?= 26.05
	SLURM_IMAGE ?= docker.io/csniper/slurm:$(TAG)
endif
export SLURM_IMAGE
export TAG

# Phony targets don't represent files.
.PHONY: all build clean prune $(DISTROS) up ha down

# The default target when `make` is run without arguments.
# Builds all discovered distributions.
# To run in parallel, use `make -j<number_of_jobs>`.
all: $(DISTROS)

# A target to explicitly build all distros.
build: all

# Rule to build a container for a specific distribution.
# Example: `make el8`
$(DISTROS):
	@echo "Building slurm:$@ image..."
	@$(PODMAN) build --pull=newer -t slurm:$@ -t slurm:$(SLURM_VER)-$@ --squash -f $@/Containerfile . 2>&1 | tee $@-img-build.log

# Prune dangling container images and volumes across all cluster profiles.
prune:
	COMPOSE_PROFILES=single,ha $(PODMAN) compose down --volumes --remove-orphans
	$(PODMAN) image prune -f

# Start/stop slurm-container stack using compose.
up:
	$(PODMAN) compose up -d --remove-orphans --force-recreate

ha:
	@$(MAKE) up MODE=ha COMPOSE_PROFILES=ha

down:
	COMPOSE_PROFILES=single,ha $(PODMAN) compose down --remove-orphans

# Clean up generated files.
clean:
	@echo "Cleaning up generated files..."
	@rm -f *build.log
