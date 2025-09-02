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

# Phony targets don't represent files.
.PHONY: all build prune $(DISTROS)

# The default target when `make` is run without arguments.
# Builds all discovered distributions.
# To run in parallel, use `make -j<number_of_jobs>`.
all: $(DISTROS)

# A target to explicitly build all distros.
build: all

# Rule to build a container for a specific distribution.
# Example: `make el8`
$(DISTROS):
	$(PODMAN) build --pull=newer -t slurm:$@ -t slurm:$(SLURM_VER)-$@ --squash -f $@/Containerfile .

# Prune dangling container images.
prune:
	$(PODMAN) image prune -f
