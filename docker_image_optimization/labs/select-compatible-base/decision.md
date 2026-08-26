# Base Image Decision

## Candidate sizes and base references
- base-lab:ubuntu — ubuntu:24.04 — 29756418 bytes (~29.8MB)
- base-lab:debian-slim — debian:12-slim — 28235697 bytes (~28.2MB)
- base-lab:alpine — alpine:3.22 — 3790782 bytes (~3.8MB)

## Selected base: Alpine 3.22
All three candidates satisfy the runtime requirements: Linux, a POSIX-compatible /bin/sh, and no package manager operation after build, confirmed by all three printing the same `{"runtime":"posix-shell","status":"ok"}` output. Since runtime-requirements.md explicitly states this application has no glibc-specific native extension dependency, Alpine's musl libc is not a compatibility risk here. Alpine is therefore the smallest candidate that satisfies every stated requirement, at roughly an eighth the size of the glibc-based alternatives.

## Why the selected base is appropriate for this application
The application only needs a POSIX shell to run a shell script, with no compiled dependency tying it to glibc. Alpine provides that shell in a much smaller footprint, which reduces pull time, storage, and the attack surface exposed at runtime, without sacrificing any capability this specific application actually uses.

## When Debian slim would be safer than Alpine despite being larger
An application that depends on precompiled binaries or native extensions linked against glibc (for example, many Python or Node.js packages with C extensions) can fail or behave unpredictably on Alpine's musl libc, sometimes silently. Debian slim keeps full glibc compatibility and access to the broader, vendor-supported Debian package ecosystem, which matters when a dependency has no musl-compatible build or when the team needs predictable behavior matching production Debian/Ubuntu servers.

## Versioned tag vs digest for an immutable base reference
A versioned tag like alpine:3.22 improves control by keeping the build understandable and letting a maintainer intentionally track a known minor release instead of silently drifting with `latest`. However, a tag is mutable: the registry maintainer can repoint alpine:3.22 to a different underlying image at any time, so two builds run weeks apart could pull different bytes despite using the same Dockerfile. A digest (`@sha256:...`) pins the exact, content-addressed image, so the same digest always resolves to the exact same bytes, which is what a truly immutable, reproducible base reference requires.
