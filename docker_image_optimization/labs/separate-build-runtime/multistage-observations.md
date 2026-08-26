# Multi-Stage Build Observations

## Image sizes
- multistage-lab:single (single-stage): 79056724 bytes (~79.1MB)
- multistage-lab:optimized (multi-stage): 1355403 bytes (~1.35MB)
- The multi-stage image is about 98% smaller, since the final scratch stage contains only the compiled greeter binary, with no Go toolchain, no source tree, and no shell.

## Runtime behavior
Both images print the same output: {"service":"greeter","status":"ok"}

## Configured user
docker image inspect multistage-lab:optimized --format '{{.Config.User}}' reports 65532:65532, a non-root numeric user and group.

## Shell override attempt
Running `docker run --rm --entrypoint /bin/sh multistage-lab:optimized` fails with:
exec: "/bin/sh": stat /bin/sh: no such file or directory

## Why this failure is expected
The final stage is built FROM scratch, which is not a minimal Linux distribution but a literally empty filesystem with no base layer at all. The only thing added to it is the compiled greeter binary via COPY --from=build. Since CGO_ENABLED=0 was used, that binary is statically linked and needs no shared libraries, dynamic linker, or shell to run. There is therefore no /bin/sh anywhere in the image for --entrypoint to exec, so attempting to override the entrypoint with a shell fails at container startup with a "no such file or directory" error rather than opening an interactive session.

## Why this does not replace functional testing of the application binary
The failed shell command only proves the image contains no shell, it says nothing about whether the greeter program itself behaves correctly. Functional correctness was instead verified earlier by running the image with its normal entrypoint and checking that it printed the exact expected JSON output, and by go test ./... executing the application's unit tests inside the build stage before the binary was ever produced. A missing shell is a property of the image's contents; correct behavior is a property of the compiled program, and the two need separate evidence.
