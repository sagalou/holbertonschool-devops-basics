# Dependency Cache Observations

## Problem with Dockerfile.unoptimized
Dockerfile.unoptimized copies the entire build context (COPY . .) in a single instruction before running `npm ci --omit=dev`. Because this one COPY layer includes both dependency manifests and application source together, any change to any file, including an unrelated comment added to src/server.js, invalidates that layer's cache fingerprint. Since the following `npm ci` layer depends on the previous layer's cache state, it is invalidated too and reruns from scratch, as confirmed below: after appending a comment to src/server.js and rebuilding, the `npm ci --omit=dev` step ran again (4.0s, "added 1 package, and audited 3 packages") instead of showing CACHED.

## Dockerfile.cached build order and cache result
Dockerfile.cached separates dependency installation from source code by copying, in order: package.json and package-lock.json, then the local packages/message-format/ dependency, then running `npm ci --omit=dev`, and only after that copying src/ and test/. After the first build of cache-lab:cached, a comment was appended to src/server.js only and the same build command was run again without --no-cache. The relevant build output was:

#9 [3/7] COPY package.json package-lock.json ./
#9 CACHED
#10 [4/7] COPY packages/message-format/ ./packages/message-format/
#10 CACHED
#12 [5/7] RUN npm ci --omit=dev && node -e "setTimeout(() => {}, 3000)"
#12 CACHED
#13 [6/7] COPY src/ ./src/
#13 DONE 0.0s
#14 [7/7] COPY test/ ./test/
#14 DONE 0.0s

The `npm ci --omit=dev` step reported CACHED, confirming the source-only change rebuilt only the source layer (COPY src/) and the layers after it, while the dependency-install layer was reused unchanged.
