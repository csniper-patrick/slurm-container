# Slurm Container - Agent Instructions

This file provides project overview, architectural context, developer conventions, and operational guidelines for AI agents working on this codebase.

## 1. Project Overview & Architecture

The project builds and containerizes Slurm services such as `slurmctld`, `slurmdbd`, `slurmd`, `slurmrestd`, and `sackd`. It allows users to deploy and run Slurm clusters in containerized and Kubernetes environments using Slurm's native token authentication mechanism (`AuthType=auth/slurm`), which eliminates munge dependencies.

### Directory Mapping
* `common/`: Houses shared configuration templates (`slurm.conf.j2`, `slurmdbd.conf.j2`, `cgroup.conf.j2`), custom configuration extensions (`slurmd-extra.conf`), and the entrypoint template source (`entrypoint.m4`, `build-entrypoint.sh`).
* `slurm/`: Git submodule pointing to the upstream SchedMD Slurm repository.
* `json-web-key-generator/`: Git submodule containing the Java JWK generator library used to build token authentication keys.
* Distribution Folders (`deb12`, `deb13`, `el8`, `el9`, `el10`): Each contains a `Containerfile` and OS-specific scripts to compile and build packages from the Slurm source submodule.
* `gitlab-ci.d/`: CI templates (`container-build.yml.j2`, `container-tag.yml.j2`) used dynamically to generate pipeline jobs for GitLab CI.

## 2. Key Conventions & Tooling

* **Container Engine:** Podman is preferred if present in the environment; otherwise, falls back to Docker.
* **Makefile Automation:** The `Makefile` dynamically discovers directories containing a `Containerfile` (distributions) and compiles images for them. Phony targets such as `all`, `build`, `prune`, `up`, `ha`, and `down` are supported.
* **Entrypoint Generation:** The `/opt/local/bin/entrypoint` script in target images is constructed by compiling `common/entrypoint.m4` using `argbash` via `common/build-entrypoint.sh`. Always edit the `common/entrypoint.m4` template to make changes to entrypoint logic, then re-generate the script.
* **Configuration Management:** System configuration files are generated dynamically inside the containers at startup using `jinja2-cli` with templates under `common/` based on environment variables or entrypoint arguments.

### Build and Run Commands

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

---

## 3. Agent Operating Rules

These rules apply to every task in this project unless explicitly overridden.
Bias: caution over speed on non-trivial work. Use judgment on trivial tasks.

*   **Rule 1 — Think Before Coding:**
    *   State assumptions explicitly. If uncertain, ask rather than guess.
    *   Present multiple interpretations when ambiguity exists.
    *   Push back when a simpler approach exists.
    *   Stop when confused. Name what's unclear.
*   **Rule 2 — Simplicity First:**
    *   Minimum code that solves the problem. Nothing speculative.
    *   No features beyond what was asked. No abstractions for single-use code, scripts, or configurations.
    *   Test: would a senior engineer say this is overcomplicated? If yes, simplify.
*   **Rule 3 — Surgical Changes:**
    *   Touch only what you must. Clean up only your own mess.
    *   Don't "improve" adjacent code, playbooks, comments, or formatting.
    *   Don't refactor what isn't broken. Match existing style.
*   **Rule 4 — Goal-Driven Execution:**
    *   Define success criteria. Loop until verified.
    *   Don't follow steps blindly. Define success and iterate.
    *   Strong success criteria let you loop independently.
*   **Rule 5 — Leverage Model Strengths:**
    *   Use LLMs for: large-scale context analysis, multi-modal data extraction, architectural drafting, and cross-file summarization.
    *   Do NOT use LLMs for: deterministic transforms, executing pipelines, or tasks where simple scripts suffice.
    *   If a native tool or code can answer, let it.
*   **Rule 6 — Keep Context Focused:**
    *   Do not unnecessarily bloat context with irrelevant logs or unrelated data dumps.
    *   If the project shifts to a completely new domain, summarize the current state and start fresh to maintain absolute precision.
    *   Surface any context drift. Do not silently lose track of the core objective.
*   **Rule 7 — Surface Conflicts, Don't Average Them:**
    *   If two patterns or configurations contradict, pick one (more recent / more tested).
    *   Explain why. Flag the other for cleanup.
    *   Don't blend conflicting architectures or patterns.
*   **Rule 8 — Read Before You Write:**
    *   Before adding code, read exports, immediate callers, shared utilities, and relevant deployment pipelines.
    *   "Looks orthogonal" is dangerous. If unsure why code or infrastructure is structured a certain way, ask.
*   **Rule 9 — Tests Verify Intent, Not Just Behavior:**
    *   Tests (and CI checks) must encode WHY behavior matters, not just WHAT it does.
    *   A test that can't fail when business logic or system state changes is wrong.
*   **Rule 10 — Checkpoint After Every Significant Step:**
    *   Summarize what was done, what's verified, what's left.
    *   Don't continue from a state you can't describe back.
    *   If you lose track of the state, stop and restate.
*   **Rule 11 — Match Project Conventions:**
    *   Conformance > taste inside the repository.
    *   If you genuinely think a convention is harmful, surface it. Don't fork silently or introduce divergent setups.
*   **Rule 12 — Fail Loud:**
    *   "Completed" is wrong if anything was skipped silently.
    *   "Pipelines pass" is wrong if any checks were bypassed.
    *   Default to surfacing system errors and uncertainty, not hiding them.
*   **Rule 13 — Explicit Commit Authorization:**
    *   Do not commit unless explicitly told by the user.

