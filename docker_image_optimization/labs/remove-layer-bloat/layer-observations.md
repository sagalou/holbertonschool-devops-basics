# Layer Bloat Observations

## Checksum consistency
Both images print the same checksum: a0e8bdd8a312de8e45d2cea454dee228ede781730bfc321d96a6fced1b634090

## Image sizes
- layer-lab:unoptimized: 10084890 bytes
- layer-lab:optimized: 3790446 bytes
- Difference: 6294444 bytes (~6.0 MiB smaller), exceeding the required 5 MiB (5,242,880 bytes) minimum.

## docker image history comparison
Unoptimized (three separate RUN layers):
- RUN cp /mnt/build-payload.bin /tmp/build-payload.bin -> 6.3MB
- RUN sha256sum ... -> 8.19kB
- RUN rm -f /tmp/build-payload.bin -> 8.19kB (not 0B)

Optimized (single RUN layer):
- RUN cp ... && sha256sum ... && rm -f ... -> 8.19kB total

## Why the later rm hides the file but cannot remove earlier bytes
Each RUN instruction in Dockerfile.unoptimized commits its own immutable layer to the image. The `cp` step writes the 6.3MB payload into its layer, and that layer is sealed once the instruction finishes; nothing later can edit or shrink it. The following `rm -f` instruction runs in a new, separate layer. A layer cannot delete data from an earlier layer, it can only record a whiteout marker that tells the union filesystem "hide this path when merging layers for the final view." This is why the rm layer's size is 8.19kB rather than 0B or negative: it is adding a small marker file, not reclaiming space. The merged filesystem correctly shows no /tmp/build-payload.bin, but the 6.3MB written by the earlier cp layer is still physically stored inside the image and is pulled, stored, and transferred with it.

Dockerfile.optimized avoids this by performing the copy, checksum, and removal within a single RUN instruction chained with &&. Because all three commands execute inside one build step, only the filesystem state that exists when that single layer is committed gets persisted. The temporary payload file never exists in a layer of its own that could later be sealed with the data still inside it, so no whiteout is needed and no earlier layer retains the bytes.
