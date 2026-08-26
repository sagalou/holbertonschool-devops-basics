# Build Context Observations

## Transferring context comparison
- Before (.dockerignore absent): `transferring context: 2.10MB` (from before-build.log)
- After (.dockerignore present): `transferring context: 175B` (from after-build.log)

## Runtime results
- Before: `docker run --rm context-lab:before` printed `context-contains-local-only-data`, confirming local-only files (.git, .env, local-only/, reports/, *.log) were present inside the image.
- After: `docker run --rm context-lab:after` printed `context-clean`, confirming none of that local-only data made it into the image.

## Why .dockerignore affects what COPY can access, not only transfer speed
The build context is not a live view of the local filesystem: it is a snapshot the client sends to the Docker daemon before any instruction runs. COPY and ADD can only reference files that exist inside that snapshot. .dockerignore is applied while that snapshot is being assembled, before the Dockerfile is even processed, so excluded files are never part of the context in the first place. A smaller transfer is a visible side effect, but the real mechanism is that COPY . . has nothing to copy for excluded paths, because they were never sent to the daemon. This is different from deleting files with a later RUN rm, which would still leave the data inside an earlier, immutable layer.
