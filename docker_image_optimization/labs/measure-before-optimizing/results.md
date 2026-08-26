# Baseline Observations
- Image size in bytes: 380984614
- Largest non-base instruction and evidence: `COPY . .` at 8.44MB (from `docker image history`), the largest layer added by Dockerfile.baseline itself, excluding the base Python image layers.
- Configured runtime user: "" (empty string, meaning the container runs as root by default, no non-root user configured)
- Unnecessary copied file or directory 1: tests/ (test_app.py was compiled and copied into the image, but the running API does not need its own test suite at runtime)
- Unnecessary copied file or directory 2: docs/ (architecture.md is documentation for developers, not something the running API process reads)

## Evidence-Based Optimization Targets
1. Reduce image size by switching to a slimmer base image. The current python:3.12-bookworm base pulls in ~381MB total, most of it from apt-get layers (619MB, 194MB, 52.3MB in the history) that are far larger than the 8.44MB the app itself contributes.
2. Add a .dockerignore and stop copying docs/, reports/, and tests/ into the runtime image. The COPY . . layer at 8.44MB includes files with no runtime purpose, confirmed by compileall listing docs/, reports/, and tests/ during the build.
3. Set a non-root USER in the Dockerfile. docker image inspect shows Config.User is empty, meaning the API currently runs as root inside the container, an avoidable security exposure.
